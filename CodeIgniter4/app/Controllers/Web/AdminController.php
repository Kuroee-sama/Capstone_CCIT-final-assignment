<?php namespace App\Controllers\Web;
use App\Controllers\BaseController;
use App\Models\Menu;
use App\Models\Transaksi;
use App\Models\DetailTransaksi;

class AdminController extends BaseController {
    
    public function index()
    {
        $db = \Config\Database::connect();
        $role = strtolower(session()->get('role') ?? 'karyawan');
        
        // Total menu (for all roles)
        $totalMenu = $db->table('menu')->countAllResults();

        if ($role === 'admin') {
            // ADMIN: Full stats
            $queryPendapatan = $db->table('transaksi')
                                  ->selectSum('total_amount')
                                  ->get()
                                  ->getRow();
            $totalPendapatan = $queryPendapatan->total_amount ?? 0;
            $totalTransaksi = $db->table('transaksi')->countAllResults();

            return view('admin/dashboard', [
                'totalPendapatan' => $totalPendapatan,
                'totalTransaksi'  => $totalTransaksi,
                'totalMenu'       => $totalMenu,
            ]);
        } else {
            // KARYAWAN: Limited stats (own transactions only)
            $karyawanId = session()->get('id');
            $totalTransaksiSaya = $db->table('transaksi')
                                     ->where('karyawan_id', $karyawanId)
                                     ->countAllResults();

            return view('admin/dashboard', [
                'totalMenu'          => $totalMenu,
                'totalTransaksiSaya' => $totalTransaksiSaya,
            ]);
        }
    }

    public function transaksi() 
    {
        $db = \Config\Database::connect();
        
        // Query menu with JOIN to kategori (using direct FK now)
        $data['menu'] = $db->table('menu')
            ->select('menu.*, kategori.nama_kategori')
            ->join('kategori', 'kategori.kategori_id = menu.kategori_id', 'left')
            ->where('menu.stok >', 0)
            ->get()
            ->getResultArray();
        
        return view('admin/transaksi', $data);
    }

    public function simpanTransaksi()
    {
        $db = \Config\Database::connect();
        $json = $this->request->getJSON();

        // Validasi data
        if (!$json || !isset($json->items) || empty($json->items)) {
            return $this->response->setJSON(['status' => 'error', 'message' => 'Data tidak valid'])->setStatusCode(400);
        }

        // Gunakan transaction database untuk keamanan
        $db->transStart();

        // SERVER-SIDE CALCULATION: Never trust client total
        $totalAmount = 0;
        $processedItems = [];

        foreach ($json->items as $item) {
            // Get price from database, NOT from request
            $menu = $db->table('menu')
                ->where('menu_id', $item->menu_id)
                ->get()
                ->getRow();
            
            if (!$menu) {
                $db->transRollback();
                return $this->response->setJSON([
                    'status' => 'error', 
                    'message' => 'Menu tidak ditemukan: ' . $item->menu_id
                ])->setStatusCode(400);
            }

            // Check stock
            $requestedQty = (int) ($item->qty ?? 0);
            if ($requestedQty <= 0) {
                $db->transRollback();
                return $this->response->setJSON([
                    'status' => 'error',
                    'code' => 'INVALID_QTY',
                    'message' => 'Jumlah item tidak valid untuk: ' . $menu->nama_item,
                    'menu_name' => $menu->nama_item,
                    'requested_qty' => $requestedQty,
                ])->setStatusCode(400);
            }

            if ((int) $menu->stok < $requestedQty) {
                $db->transRollback();
                return $this->response->setJSON([
                    'status' => 'error',
                    'code' => 'INSUFFICIENT_STOCK',
                    'message' => 'Stok ' . $menu->nama_item . ' tidak mencukupi. Stok tersedia ' . (int) $menu->stok . ', jumlah diminta ' . $requestedQty . '.',
                    'menu_id' => (int) $menu->menu_id,
                    'menu_name' => $menu->nama_item,
                    'available_stock' => (int) $menu->stok,
                    'requested_qty' => $requestedQty,
                ])->setStatusCode(400);
            }

            $subtotal = $menu->harga * $requestedQty;
            $totalAmount += $subtotal;

            $processedItems[] = [
                'menu_id'    => $item->menu_id,
                'jumlah'     => $requestedQty,
                'harga'      => $menu->harga,
                'total_harga' => $subtotal,
            ];

            // Reduce stock
            $db->table('menu')
                ->where('menu_id', $item->menu_id)
                ->set('stok', 'stok - ' . $requestedQty, false)
                ->update();
        }

        // 1. Insert ke tabel transaksi
        $transaksiData = [
            'karyawan_id'   => session()->get('id'),
            'tgl_transaksi' => date('Y-m-d H:i:s'),
            'total_amount'  => $totalAmount,
            'metode_pembayaran' => 'CASH',
        ];
        $db->table('transaksi')->insert($transaksiData);
        $transaksiId = $db->insertID();

        // 2. Insert detail transaksi
        foreach ($processedItems as $detail) {
            $detail['transaksi_id'] = $transaksiId;
            $db->table('detail_transaksi')->insert($detail);
        }

        $db->transComplete();

        if ($db->transStatus() === false) {
            return $this->response->setJSON(['status' => 'error', 'message' => 'Gagal menyimpan transaksi'])->setStatusCode(500);
        }

        return $this->response->setJSON([
            'status'       => 'success',
            'transaksi_id' => $transaksiId,
            'total_amount' => $totalAmount,
            'message'      => 'Transaksi berhasil disimpan'
        ]);
    }
}