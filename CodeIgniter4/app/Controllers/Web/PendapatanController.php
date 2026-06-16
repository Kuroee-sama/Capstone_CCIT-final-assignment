<?php

namespace App\Controllers\Web;

use App\Controllers\BaseController;

class PendapatanController extends BaseController
{
    public function index()
    {
        $db = \Config\Database::connect();

        // Data pendapatan per bulan.
        // Catatan: garis grafik memakai rata-rata pendapatan per transaksi,
        // bukan jumlah transaksi, agar satuannya sama dengan total pendapatan, yaitu Rupiah.
        $pendapatan = $db->query(""
            . "SELECT "
            . "YEAR(tgl_transaksi) AS tahun, "
            . "MONTH(tgl_transaksi) AS bulan, "
            . "COUNT(*) AS jumlah_transaksi, "
            . "COALESCE(SUM(total_amount), 0) AS total_pendapatan, "
            . "COALESCE(AVG(total_amount), 0) AS rata_rata_transaksi "
            . "FROM transaksi "
            . "GROUP BY YEAR(tgl_transaksi), MONTH(tgl_transaksi) "
            . "ORDER BY tahun DESC, bulan DESC"
        )->getResultArray();

        $totalAll = $db->table('transaksi')
            ->selectSum('total_amount')
            ->get()
            ->getRow();

        $totalTransaksi = $db->table('transaksi')
            ->countAllResults();

        $namaBulan = [
            1 => 'Januari',
            2 => 'Februari',
            3 => 'Maret',
            4 => 'April',
            5 => 'Mei',
            6 => 'Juni',
            7 => 'Juli',
            8 => 'Agustus',
            9 => 'September',
            10 => 'Oktober',
            11 => 'November',
            12 => 'Desember',
        ];

        return view('admin/pendapatan', [
            'pendapatan'     => $pendapatan,
            'namaBulan'      => $namaBulan,
            'totalAll'       => $totalAll->total_amount ?? 0,
            'totalTransaksi' => $totalTransaksi,
        ]);
    }
}
