<?php

namespace App\Controllers\Api;

use App\Models\Transaksi;
use App\Models\DetailTransaksi;
use App\Models\Menu;
use CodeIgniter\RESTful\ResourceController;
use CodeIgniter\Database\Exceptions\DatabaseException;

class TransaksiController extends ResourceController
{
    protected $modelName = 'App\Models\Transaksi';
    protected $format    = 'json';

    public function index()
    {
        return $this->respond($this->model->findAll());
    }

    public function show($id = null)
    {
        $data = $this->model->find($id);
        if (!$data) {
            return $this->failNotFound('Transaction not found');
        }

        // Get details
        $detailModel = new DetailTransaksi();
        $details = $detailModel->where('transaksi_id', $id)->findAll();
        
        $data['details'] = $details;

        return $this->respond($data);
    }

    public function create()
    {
        $rules = [
            'karyawan_id' => 'required|integer',
            'items'       => 'required' // Expecting array of {menu_id, jumlah}
        ];

        if (!$this->validate($rules)) {
            return $this->fail($this->validator->getErrors());
        }

        $items = $this->request->getVar('items');

        // Start Transaction
        $db = \Config\Database::connect();
        $db->transStart();

        try {
            $menuModel = new Menu();
            $totalAmount = 0;

            // Hitung total amount dari semua item
            foreach ($items as $item) {
                $menuId = $item->menu_id ?? $item['menu_id'];
                $jumlah = $item->jumlah ?? $item['jumlah'];
                $menu = $menuModel->find($menuId);
                if ($menu) {
                    $totalAmount += $menu['harga'] * $jumlah;
                }
            }

            // Insert Transaksi
            $transaksiData = [
                'tgl_transaksi' => date('Y-m-d H:i:s'),
                'karyawan_id'   => $this->request->getVar('karyawan_id'),
                'total_amount'  => $totalAmount,
            ];
            
            $this->model->insert($transaksiData);
            $transaksiId = $this->model->getInsertID();

            // Insert Details
            $detailModel = new DetailTransaksi();
            foreach ($items as $item) {
                $menuId = $item->menu_id ?? $item['menu_id'];
                $jumlah = $item->jumlah ?? $item['jumlah'];
                $menu = $menuModel->find($menuId);
                $harga = $menu ? $menu['harga'] : 0;

                $detailData = [
                    'transaksi_id' => $transaksiId,
                    'menu_id'      => $menuId,
                    'jumlah'       => $jumlah,
                    'harga'        => $harga,
                    'total_harga'  => $harga * $jumlah,
                ];
                $detailModel->insert($detailData);
            }

            $db->transComplete();

            if ($db->transStatus() === false) {
                return $this->failServerError('Transaction failed');
            }

            return $this->respondCreated(['id' => $transaksiId, 'message' => 'Transaction created successfully']);

        } catch (DatabaseException $e) {
            return $this->failServerError($e->getMessage());
        }
    }
}
