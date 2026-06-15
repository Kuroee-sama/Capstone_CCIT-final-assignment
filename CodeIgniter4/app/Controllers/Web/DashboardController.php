<?php namespace App\Controllers\Web;

use App\Controllers\BaseController;
use App\Models\Menu;
use App\Models\Kategori;

class DashboardController extends BaseController {
    public function index() {
        $db = \Config\Database::connect();
        $kategoriFilter = $this->request->getVar('kategori');

        // Build query using direct FK instead of menu_kategori junction
        $builder = $db->table('menu')
            ->select('menu.*, kategori.nama_kategori')
            ->join('kategori', 'kategori.kategori_id = menu.kategori_id', 'left');

        // Jika ada filter kategori dari tombol
        if ($kategoriFilter && $kategoriFilter != 'Semua') {
            $builder->where('kategori.nama_kategori', $kategoriFilter);
        }

        $data['menu'] = $builder->get()->getResultArray();
        $data['selectedKategori'] = $kategoriFilter ?? 'Semua';

        // Ambil daftar semua kategori untuk filter buttons
        $kategoriModel = new Kategori();
        $data['kategori'] = $kategoriModel->findAll();
        
        return view('customer/katalog', $data);
    }
}