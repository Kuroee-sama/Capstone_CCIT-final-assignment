<?php

namespace App\Controllers\Api;

use App\Models\Transaksi;
use App\Models\DetailTransaksi;
use App\Models\Menu;
use CodeIgniter\RESTful\ResourceController;
use Throwable;

class TransaksiController extends ResourceController
{
    protected $modelName = 'App\Models\Transaksi';
    protected $format    = 'json';

    public function index()
    {
        return $this->respond($this->withKaryawanUsername($this->model->orderBy('transaksi_id', 'DESC')->findAll()));
    }

    public function my()
    {
        $karyawanId = $this->currentKaryawanId();
        if (!$karyawanId) {
            return $this->failUnauthorized('Unauthorized');
        }

        $rows = $this->model->where('karyawan_id', $karyawanId)->orderBy('transaksi_id', 'DESC')->findAll();
        return $this->respond($this->withKaryawanUsername($rows));
    }

    public function show($id = null)
    {
        $data = $this->model->find($id);
        if (!$data) {
            return $this->failNotFound('Transaction not found');
        }

        $data['detailList'] = $this->details($id);
        return $this->respond($data);
    }

    public function detail($id = null)
    {
        if (!$this->model->find($id)) {
            return $this->failNotFound('Transaction not found');
        }
        return $this->respond($this->details($id));
    }

    public function create()
    {
        $payload = $this->payload();
        $items = $payload['items'] ?? null;
        if (!is_array($items) || empty($items)) {
            return $this->fail(['error' => 'Items tidak boleh kosong'], 400);
        }

        $karyawanId = $payload['karyawan_id'] ?? $payload['karyawanId'] ?? $this->currentKaryawanId();
        if (!$karyawanId) {
            return $this->fail(['error' => 'karyawan_id is required'], 400);
        }

        $db = \Config\Database::connect();
        $db->transBegin();

        try {
            $menuModel = new Menu();
            $detailModel = new DetailTransaksi();
            $totalAmount = 0;
            $processedItems = [];

            foreach ($items as $row) {
                $item = (array) $row;
                $menuId = $item['menuId'] ?? $item['menu_id'] ?? null;
                $jumlah = (int) ($item['jumlah'] ?? $item['qty'] ?? 0);

                if (!$menuId || $jumlah <= 0) {
                    throw new \InvalidArgumentException('menuId/menu_id dan jumlah wajib valid');
                }

                $menu = $menuModel->find($menuId);
                if (!$menu) {
                    throw new \RuntimeException('Menu not found with id: ' . $menuId);
                }
                if ((int) $menu['stok'] < $jumlah) {
                    throw new \InvalidArgumentException('Stok tidak mencukupi untuk item: ' . $menu['nama_item']);
                }

                $harga = (float) $menu['harga'];
                $subtotal = $harga * $jumlah;
                $totalAmount += $subtotal;
                $processedItems[] = [
                    'menu_id' => (int) $menuId,
                    'jumlah' => $jumlah,
                    'harga' => $harga,
                    'total_harga' => $subtotal,
                ];

                $db->table('menu')
                    ->where('menu_id', $menuId)
                    ->set('stok', 'stok - ' . $jumlah, false)
                    ->update();
            }

            $bayar = isset($payload['bayar']) ? (float) $payload['bayar'] : null;
            $transaksiData = [
                'karyawan_id' => (int) $karyawanId,
                'tgl_transaksi' => date('Y-m-d H:i:s'),
                'total_amount' => $totalAmount,
                'metode_pembayaran' => $payload['metodePembayaran'] ?? $payload['metode_pembayaran'] ?? 'CASH',
                'bayar' => $bayar,
                'kembalian' => $bayar !== null ? $bayar - $totalAmount : null,
            ];

            $this->model->insert($transaksiData);
            $transaksiId = $this->model->getInsertID();

            foreach ($processedItems as $detail) {
                $detail['transaksi_id'] = $transaksiId;
                $detailModel->insert($detail);
            }

            $db->transCommit();

            $created = $this->model->find($transaksiId);
            $created['detailList'] = $this->details($transaksiId);
            return $this->respondCreated($created);
        } catch (\InvalidArgumentException $e) {
            $db->transRollback();
            return $this->fail(['error' => $e->getMessage()], 400);
        } catch (Throwable $e) {
            $db->transRollback();
            return $this->failServerError($e->getMessage());
        }
    }

    public function delete($id = null)
    {
        $db = \Config\Database::connect();
        $transaction = $this->model->find($id);
        if (!$transaction) {
            return $this->failNotFound('Transaction not found');
        }

        $db->transBegin();
        try {
            $details = (new DetailTransaksi())->where('transaksi_id', $id)->findAll();
            foreach ($details as $detail) {
                if (!empty($detail['menu_id']) && !empty($detail['jumlah'])) {
                    $db->table('menu')
                        ->where('menu_id', $detail['menu_id'])
                        ->set('stok', 'stok + ' . (int) $detail['jumlah'], false)
                        ->update();
                }
            }
            (new DetailTransaksi())->where('transaksi_id', $id)->delete();
            $this->model->delete($id);
            $db->transCommit();
            return $this->respondDeleted(['message' => 'Transaction deleted successfully']);
        } catch (Throwable $e) {
            $db->transRollback();
            return $this->failServerError($e->getMessage());
        }
    }

    private function payload(): array
    {
        $json = $this->request->getJSON(true);
        if (is_array($json)) {
            return $json;
        }
        $raw = $this->request->getRawInput();
        return $raw ?: ($this->request->getPost() ?: []);
    }

    private function details($transaksiId): array
    {
        return (new DetailTransaksi())
            ->select('detail_transaksi.*, menu.nama_item, menu.harga as menu_harga')
            ->join('menu', 'menu.menu_id = detail_transaksi.menu_id', 'left')
            ->where('detail_transaksi.transaksi_id', $transaksiId)
            ->findAll();
    }

    private function withKaryawanUsername(array $rows): array
    {
        if (empty($rows)) {
            return [];
        }

        $ids = array_map(static fn ($row) => (int) $row['transaksi_id'], $rows);
        $db = \Config\Database::connect();
        return $db->table('transaksi')
            ->select('transaksi.*, karyawan.username as karyawanUsername')
            ->join('karyawan', 'karyawan.karyawan_id = transaksi.karyawan_id', 'left')
            ->whereIn('transaksi.transaksi_id', $ids)
            ->orderBy('transaksi.transaksi_id', 'DESC')
            ->get()
            ->getResultArray();
    }

    private function currentKaryawanId(): ?int
    {
        $header = $this->request->getHeaderLine('Authorization');
        if (!str_starts_with($header, 'Bearer ')) {
            return null;
        }
        $token = substr($header, 7);
        $parts = explode('.', $token);
        if (count($parts) < 2) {
            return null;
        }
        $payload = json_decode(base64_decode(strtr($parts[1], '-_', '+/')), true);
        $id = $payload['id'] ?? $payload['uid'] ?? null;
        return $id ? (int) $id : null;
    }
}
