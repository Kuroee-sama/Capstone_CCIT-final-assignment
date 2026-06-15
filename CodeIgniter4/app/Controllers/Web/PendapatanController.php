<?php namespace App\Controllers\Web;
use App\Controllers\BaseController;

class PendapatanController extends BaseController {
    
    public function index()
    {
        $db = \Config\Database::connect();
        
        // Query pendapatan per bulan (GROUP BY YEAR-MONTH)
        $pendapatan = $db->query("
            SELECT 
                YEAR(tgl_transaksi) as tahun,
                MONTH(tgl_transaksi) as bulan,
                COUNT(*) as jumlah_transaksi,
                SUM(total_amount) as total_pendapatan
            FROM transaksi
            GROUP BY YEAR(tgl_transaksi), MONTH(tgl_transaksi)
            ORDER BY tahun DESC, bulan DESC
        ")->getResultArray();

        // Total keseluruhan
        $totalAll = $db->table('transaksi')->selectSum('total_amount')->get()->getRow();
        $totalTransaksi = $db->table('transaksi')->countAllResults();

        // Nama bulan Indonesia
        $namaBulan = [
            1 => 'Januari', 2 => 'Februari', 3 => 'Maret', 4 => 'April',
            5 => 'Mei', 6 => 'Juni', 7 => 'Juli', 8 => 'Agustus',
            9 => 'September', 10 => 'Oktober', 11 => 'November', 12 => 'Desember'
        ];

        return view('admin/pendapatan', [
            'pendapatan'     => $pendapatan,
            'namaBulan'      => $namaBulan,
            'totalAll'       => $totalAll->total_amount ?? 0,
            'totalTransaksi' => $totalTransaksi,
        ]);
    }
}
