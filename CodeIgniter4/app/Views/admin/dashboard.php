<?= $this->extend('layouts/main') ?>

<?= $this->section('content') ?>
<style>
    .dash-container { padding: 20px 0; }
    .dash-header { text-align: center; margin-bottom: 40px; }
    .dash-header h1 { color: #2d3436; font-size: 2.2rem; margin-bottom: 8px; }
    .dash-header p { color: #636e72; font-size: 1rem; }

    .stats-grid { 
        display: grid; 
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); 
        gap: 20px; 
        margin-bottom: 40px; 
    }
    .stat-card { 
        background: white; 
        padding: 25px; 
        border-radius: 16px; 
        box-shadow: 0 4px 15px rgba(0,0,0,0.04); 
        display: flex; 
        align-items: center; 
        gap: 18px; 
    }
    .stat-icon { 
        width: 60px; height: 60px; 
        border-radius: 14px; 
        display: flex; align-items: center; justify-content: center; 
        font-size: 26px; 
    }
    .stat-label { font-size: 13px; color: #636e72; margin-bottom: 4px; }
    .stat-value { font-size: 22px; font-weight: 700; color: #2d3436; }

    .menu-grid { 
        display: grid; 
        grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); 
        gap: 25px; 
    }
    .menu-link { 
        text-decoration: none; 
        background: white; 
        padding: 28px; 
        border-radius: 20px; 
        box-shadow: 0 4px 15px rgba(0,0,0,0.03); 
        border-top: 5px solid transparent;
        transition: 0.3s; 
        display: flex; 
        align-items: center; 
        gap: 20px; 
    }
    .menu-link:hover { transform: translateY(-5px); box-shadow: 0 10px 25px rgba(0,0,0,0.08); }
    .menu-link .icon-box { 
        width: 65px; height: 65px; 
        border-radius: 15px; 
        display: flex; align-items: center; justify-content: center; 
        font-size: 28px; flex-shrink: 0;
    }
    .menu-link h3 { margin: 0; color: #2d3436; font-size: 1.2rem; }
    .menu-link p { margin: 5px 0 0; color: #636e72; font-size: 0.85rem; }

    @media (max-width: 600px) {
        .dash-header h1 { font-size: 1.6rem; }
        .stat-card { padding: 18px; }
        .stat-value { font-size: 18px; }
        .menu-link { padding: 20px; }
    }
</style>

<?php $role = strtolower(session()->get('role') ?? 'karyawan'); ?>

<div class="dash-container">
    <div class="dash-header">
        <h1><?= $role === 'admin' ? 'Dashboard Admin' : 'Dashboard Kasir' ?></h1>
        <p>Selamat datang, <strong><?= session()->get('nama') ?></strong>. 
           <?= $role === 'admin' ? 'Kelola operasional café Anda di sini.' : 'Siap untuk melayani pelanggan hari ini!' ?></p>
    </div>

    <div class="stats-grid">
        <?php if ($role === 'admin'): ?>
            <!-- ADMIN: Full stats -->
            <div class="stat-card">
                <div class="stat-icon" style="background: #fff3e0; color: #e67e22;"><i class="fas fa-money-bill-wave"></i></div>
                <div>
                    <div class="stat-label">Total Pendapatan</div>
                    <div class="stat-value">Rp <?= number_format($totalPendapatan, 0, ',', '.') ?></div>
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
                <div class="stat-icon" style="background: #e8f5e9; color: #2ecc71;"><i class="fas fa-utensils"></i></div>
                <div>
                    <div class="stat-label">Total Menu</div>
                    <div class="stat-value"><?= $totalMenu ?></div>
                </div>
            </div>
        <?php else: ?>
            <!-- KARYAWAN: Limited stats -->
            <div class="stat-card">
                <div class="stat-icon" style="background: #e3f2fd; color: #3498db;"><i class="fas fa-receipt"></i></div>
                <div>
                    <div class="stat-label">Transaksi Saya</div>
                    <div class="stat-value"><?= $totalTransaksiSaya ?? 0 ?></div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon" style="background: #e8f5e9; color: #2ecc71;"><i class="fas fa-utensils"></i></div>
                <div>
                    <div class="stat-label">Total Menu</div>
                    <div class="stat-value"><?= $totalMenu ?></div>
                </div>
            </div>
        <?php endif; ?>
    </div>

    <div class="menu-grid">
        <a href="<?= base_url('admin/transaksi') ?>" class="menu-link" style="border-top-color: #e67e22;">
            <div class="icon-box" style="background: #fff3e0;">🛒</div>
            <div>
                <h3>Transaksi Baru</h3>
                <p>Mulai pesanan baru.</p>
            </div>
        </a>
        
        <?php if ($role === 'admin'): ?>
            <a href="<?= base_url('admin/menu') ?>" class="menu-link" style="border-top-color: #2ecc71;">
                <div class="icon-box" style="background: #e8f5e9;">🍔</div>
                <div>
                    <h3>Kelola Menu</h3>
                    <p>Tambah, edit, hapus menu.</p>
                </div>
            </a>
        <?php endif; ?>
        
        <a href="<?= base_url('admin/riwayat') ?>" class="menu-link" style="border-top-color: #3498db;">
            <div class="icon-box" style="background: #e3f2fd;">📜</div>
            <div>
                <h3>Riwayat Transaksi</h3>
                <p><?= $role === 'admin' ? 'Lihat semua laporan penjualan.' : 'Lihat riwayat transaksi Anda.' ?></p>
            </div>
        </a>
        
        <?php if ($role === 'admin'): ?>
            <a href="<?= base_url('admin/karyawan') ?>" class="menu-link" style="border-top-color: #34495e;">
                <div class="icon-box" style="background: #eef2f7;">👥</div>
                <div>
                    <h3>Kelola Karyawan</h3>
                    <p>Tambah, edit, hapus akun.</p>
                </div>
            </a>

            <a href="<?= base_url('admin/pendapatan') ?>" class="menu-link" style="border-top-color: #9b59b6;">
                <div class="icon-box" style="background: #f3e5f5;">📊</div>
                <div>
                    <h3>Pendapatan Bulanan</h3>
                    <p>Rincian pendapatan per bulan.</p>
                </div>
            </a>
        <?php endif; ?>
    </div>
</div>
<?= $this->endSection() ?>