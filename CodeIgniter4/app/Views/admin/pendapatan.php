<?= $this->extend('layouts/main') ?>

<?= $this->section('content') ?>
<style>
    .pendapatan-container { max-width: 1100px; margin: 0 auto; }
    .pendapatan-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; flex-wrap: wrap; gap: 10px; }
    .pendapatan-header h2 { margin: 0; color: #2d3436; }
    .pendapatan-header a { text-decoration: none; color: #e67e22; font-weight: 600; }

    .stats-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 20px; margin-bottom: 30px; }
    .stat-card { 
        background: white; padding: 22px; border-radius: 16px; 
        box-shadow: 0 4px 15px rgba(0,0,0,0.04); display: flex; align-items: center; gap: 15px; 
    }
    .stat-icon { 
        width: 50px; height: 50px; border-radius: 12px; 
        display: flex; align-items: center; justify-content: center; font-size: 22px; flex-shrink: 0;
    }
    .stat-label { font-size: 12px; color: #636e72; margin-bottom: 2px; }
    .stat-value { font-size: 20px; font-weight: 700; color: #2d3436; }

    .chart-wrapper { 
        background: white; border-radius: 20px; box-shadow: 0 4px 15px rgba(0,0,0,0.04); 
        padding: 25px; margin-bottom: 30px; 
    }
    .chart-wrapper h3 { margin: 0 0 20px; color: #2d3436; }
    .chart-container { position: relative; height: 350px; width: 100%; }

    .table-wrapper { background: white; border-radius: 20px; box-shadow: 0 4px 15px rgba(0,0,0,0.04); overflow: hidden; }
    .table-wrapper h3 { margin: 0; padding: 20px 20px 0; color: #2d3436; }
    .table-scroll { overflow-x: auto; }
    table { width: 100%; border-collapse: collapse; min-width: 500px; }
    thead { background: #f8f9fa; }
    th { padding: 14px 20px; text-align: left; font-size: 13px; color: #636e72; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; }
    td { padding: 14px 20px; border-top: 1px solid #f1f2f6; font-size: 14px; color: #2d3436; }
    tr:hover td { background: #fafafa; }
    .amount-cell { font-weight: 700; color: #e67e22; }

    .empty-state { text-align: center; padding: 60px 20px; color: #b2bec3; }

    @media (max-width: 600px) {
        .chart-container { height: 250px; }
        th, td { padding: 12px 14px; font-size: 13px; }
    }
</style>

<div class="pendapatan-container">
    <div class="pendapatan-header">
        <div>
            <h2><i class="fas fa-chart-bar" style="color: #e67e22;"></i> Rincian Pendapatan</h2>
            <p style="margin: 5px 0 0; color: #636e72;">Laporan pendapatan per bulan</p>
        </div>
        <a href="<?= base_url('admin/dashboard') ?>">← Kembali ke Dashboard</a>
    </div>

    <div class="stats-row">
        <div class="stat-card">
            <div class="stat-icon" style="background: #fff3e0; color: #e67e22;"><i class="fas fa-money-bill-wave"></i></div>
            <div>
                <div class="stat-label">Total Pendapatan Keseluruhan</div>
                <div class="stat-value">Rp <?= number_format($totalAll, 0, ',', '.') ?></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: #e3f2fd; color: #3498db;"><i class="fas fa-receipt"></i></div>
            <div>
                <div class="stat-label">Total Transaksi</div>
                <div class="stat-value"><?= $totalTransaksi ?></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background: #e8f5e9; color: #2ecc71;"><i class="fas fa-calendar-alt"></i></div>
            <div>
                <div class="stat-label">Jumlah Bulan Aktif</div>
                <div class="stat-value"><?= count($pendapatan) ?></div>
            </div>
        </div>
    </div>

    <?php if (!empty($pendapatan)): ?>
    <div class="chart-wrapper">
        <h3>Grafik Pendapatan Bulanan</h3>
        <div class="chart-container">
            <canvas id="chartPendapatan"></canvas>
        </div>
    </div>

    <div class="table-wrapper">
        <h3 style="padding: 20px 20px 15px;">Rincian Per Bulan</h3>
        <div class="table-scroll">
            <table>
                <thead>
                    <tr>
                        <th>No</th>
                        <th>Bulan</th>
                        <th>Jumlah Transaksi</th>
                        <th>Total Pendapatan</th>
                        <th>Rata-rata / Transaksi</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($pendapatan as $i => $p): ?>
                    <tr>
                        <td><?= $i + 1 ?></td>
                        <td><strong><?= $namaBulan[(int)$p['bulan']] ?> <?= $p['tahun'] ?></strong></td>
                        <td><?= $p['jumlah_transaksi'] ?> transaksi</td>
                        <td class="amount-cell">Rp <?= number_format($p['total_pendapatan'], 0, ',', '.') ?></td>
                        <td>Rp <?= number_format($p['total_pendapatan'] / $p['jumlah_transaksi'], 0, ',', '.') ?></td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
    <?php else: ?>
        <div class="table-wrapper">
            <div class="empty-state">
                <i class="fas fa-chart-bar"></i>
                <p>Belum ada data pendapatan.</p>
            </div>
        </div>
    <?php endif; ?>
</div>

<!-- Chart.js CDN -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
<?php if (!empty($pendapatan)): ?>
    // Siapkan data (urutan kronologis: balik array karena query DESC)
    const dataReversed = <?= json_encode(array_reverse($pendapatan)) ?>;
    const namaBulan = <?= json_encode($namaBulan) ?>;
    
    const labels = dataReversed.map(d => namaBulan[parseInt(d.bulan)] + ' ' + d.tahun);
    const values = dataReversed.map(d => parseFloat(d.total_pendapatan));
    const counts = dataReversed.map(d => parseInt(d.jumlah_transaksi));

    const ctx = document.getElementById('chartPendapatan').getContext('2d');
    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [
                {
                    label: 'Total Pendapatan (Rp)',
                    data: values,
                    backgroundColor: 'rgba(230, 126, 34, 0.7)',
                    borderColor: '#e67e22',
                    borderWidth: 2,
                    borderRadius: 8,
                    order: 1
                },
                {
                    label: 'Jumlah Transaksi',
                    data: counts,
                    type: 'line',
                    borderColor: '#3498db',
                    backgroundColor: 'rgba(52, 152, 219, 0.1)',
                    fill: true,
                    tension: 0.4,
                    yAxisID: 'y1',
                    pointBackgroundColor: '#3498db',
                    pointRadius: 5,
                    order: 0
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: { intersect: false, mode: 'index' },
            plugins: {
                legend: { position: 'top', labels: { usePointStyle: true, padding: 20 } },
                tooltip: {
                    callbacks: {
                        label: function(ctx) {
                            if (ctx.dataset.label.includes('Pendapatan')) {
                                return 'Pendapatan: Rp ' + ctx.parsed.y.toLocaleString('id-ID');
                            }
                            return 'Transaksi: ' + ctx.parsed.y;
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        callback: function(val) { return 'Rp ' + (val / 1000).toFixed(0) + 'K'; }
                    },
                    grid: { color: '#f1f2f6' }
                },
                y1: {
                    beginAtZero: true,
                    position: 'right',
                    ticks: { stepSize: 1 },
                    grid: { display: false }
                },
                x: { grid: { display: false } }
            }
        }
    });
<?php endif; ?>
</script>
<?= $this->endSection() ?>
