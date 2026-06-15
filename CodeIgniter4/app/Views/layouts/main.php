<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cafeínaja</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        * { box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; margin: 0; background: #f5f7fa; color: #333; }
        .navbar { 
            background: white; 
            padding: 15px 30px; 
            display: flex; 
            justify-content: space-between; 
            align-items: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05); 
            position: sticky;
            top: 0;
            z-index: 100;
        }
        .navbar-brand { font-weight: 700; font-size: 20px; text-decoration: none; color: #333; }
        .orange-text { color: #e67e22; }
        .navbar-links { display: flex; align-items: center; gap: 15px; }
        .navbar-links a { text-decoration: none; color: #636e72; font-weight: 600; font-size: 14px; padding: 8px 15px; border-radius: 8px; transition: 0.3s; }
        .navbar-links a:hover { background: #f0f0f0; color: #2d3436; }
        .btn-logout { color: #f1416c !important; background: #fff5f8 !important; }
        .btn-logout:hover { background: #f1416c !important; color: white !important; }
        .role-badge { 
            display: inline-block; 
            padding: 4px 10px; 
            border-radius: 6px; 
            font-size: 11px; 
            font-weight: 700; 
            text-transform: uppercase; 
            margin-right: 5px;
        }
        .role-admin { background: #e8f5e9; color: #2ecc71; }
        .role-karyawan { background: #e3f2fd; color: #3498db; }
        .container { padding: 30px; }

        @media (max-width: 768px) {
            .navbar { padding: 12px 15px; flex-wrap: wrap; gap: 10px; }
            .navbar-links { gap: 8px; flex-wrap: wrap; }
            .navbar-links a { font-size: 12px; padding: 6px 10px; }
            .container { padding: 15px; }
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <a href="<?= base_url('katalog') ?>" class="navbar-brand">Cafeín<span class="orange-text">aja</span></a>
        <div class="navbar-links">
            <?php if (session()->get('isLoggedIn')): ?>
                <?php $role = strtolower(session()->get('role') ?? 'karyawan'); ?>
                <span class="role-badge <?= $role === 'admin' ? 'role-admin' : 'role-karyawan' ?>">
                    <?= strtoupper($role) ?>
                </span>
                <a href="<?= base_url('admin/dashboard') ?>"><i class="fas fa-home"></i> Dashboard</a>
                <a href="<?= base_url('admin/transaksi') ?>"><i class="fas fa-cash-register"></i> Transaksi</a>
                
                <?php if ($role === 'admin'): ?>
                    <!-- Menu items only visible to ADMIN -->
                    <a href="<?= base_url('admin/menu') ?>"><i class="fas fa-utensils"></i> Menu</a>
                <?php endif; ?>
                
                <a href="<?= base_url('admin/riwayat') ?>"><i class="fas fa-history"></i> Riwayat</a>
                
                <?php if ($role === 'admin'): ?>
                    <!-- Pendapatan only visible to ADMIN -->
                    <a href="<?= base_url('admin/pendapatan') ?>"><i class="fas fa-chart-bar"></i> Pendapatan</a>
                <?php endif; ?>
                
                <a href="<?= base_url('logout') ?>" class="btn-logout"><i class="fas fa-sign-out-alt"></i> Keluar</a>
            <?php else: ?>
                <a href="<?= base_url('login') ?>"><i class="fas fa-sign-in-alt"></i> Login</a>
            <?php endif; ?>
        </div>
    </nav>
    <div class="container"><?= $this->renderSection('content') ?></div>
</body>
</html>