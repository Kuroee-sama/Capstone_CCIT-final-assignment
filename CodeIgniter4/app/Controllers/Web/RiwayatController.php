<?php namespace App\Controllers\Web;
use App\Controllers\BaseController;

class RiwayatController extends BaseController {
    
    public function index()
    {
        $db = \Config\Database::connect();
        $role = strtolower(session()->get('role') ?? 'karyawan');
        $karyawanId = session()->get('id');
        
        $builder = $db->table('transaksi')
            ->select('transaksi.*, karyawan.username')
            ->join('karyawan', 'karyawan.karyawan_id = transaksi.karyawan_id', 'left')
            ->orderBy('transaksi.tgl_transaksi', 'DESC');

        // KARYAWAN: Only see their own transactions
        if ($role !== 'admin') {
            $builder->where('transaksi.karyawan_id', $karyawanId);
        }

        $data['transaksi'] = $builder->get()->getResultArray();
        $data['role'] = $role;

        return view('admin/riwayat', $data);
    }

    public function detail($id)
    {
        $db = \Config\Database::connect();
        $role = strtolower(session()->get('role') ?? 'karyawan');
        $karyawanId = session()->get('id');

        // Ambil data transaksi
        $data['transaksi'] = $db->table('transaksi')
            ->select('transaksi.*, karyawan.username')
            ->join('karyawan', 'karyawan.karyawan_id = transaksi.karyawan_id', 'left')
            ->where('transaksi.transaksi_id', $id)
            ->get()
            ->getRowArray();

        if (!$data['transaksi']) {
            return redirect()->to('/admin/riwayat')->with('error', 'Transaksi tidak ditemukan.');
        }

        // KARYAWAN: Can only see own transaction detail
        if ($role !== 'admin' && $data['transaksi']['karyawan_id'] != $karyawanId) {
            return redirect()->to('/admin/riwayat')->with('error', 'Anda tidak memiliki akses ke transaksi ini.');
        }

        // Ambil detail transaksi JOIN menu and kategori via direct FK
        $data['detail'] = $db->table('detail_transaksi')
            ->select('detail_transaksi.*, menu.nama_item, kategori.nama_kategori')
            ->join('menu', 'menu.menu_id = detail_transaksi.menu_id', 'left')
            ->join('kategori', 'kategori.kategori_id = menu.kategori_id', 'left')
            ->where('detail_transaksi.transaksi_id', $id)
            ->get()
            ->getResultArray();

        return view('admin/riwayat_detail', $data);
    }

    public function hapus($id)
    {
        $db = \Config\Database::connect();

        // Restore stock before deleting
        $details = $db->table('detail_transaksi')
            ->where('transaksi_id', $id)
            ->get()
            ->getResultArray();

        foreach ($details as $detail) {
            if (!empty($detail['menu_id']) && !empty($detail['jumlah'])) {
                $db->table('menu')
                    ->where('menu_id', $detail['menu_id'])
                    ->set('stok', 'stok + ' . (int)$detail['jumlah'], false)
                    ->update();
            }
        }

        // Hapus detail_transaksi terlebih dahulu (foreign key)
        $db->table('detail_transaksi')->where('transaksi_id', $id)->delete();
        // Hapus transaksi
        $db->table('transaksi')->where('transaksi_id', $id)->delete();

        return redirect()->to('/admin/riwayat')->with('success', 'Transaksi berhasil dihapus.');
    }
}
