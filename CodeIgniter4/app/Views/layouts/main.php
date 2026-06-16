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


        .app-toast-root {
            position: fixed;
            top: 82px;
            right: 22px;
            z-index: 20000;
            width: min(380px, calc(100vw - 32px));
            display: flex;
            flex-direction: column;
            gap: 12px;
            pointer-events: none;
        }
        .app-toast {
            pointer-events: auto;
            display: grid;
            grid-template-columns: 42px 1fr 28px;
            gap: 12px;
            align-items: start;
            background: #fff;
            border-radius: 16px;
            padding: 14px 14px;
            box-shadow: 0 18px 55px rgba(45,52,54,.16);
            border: 1px solid #f1f2f6;
            transform: translateX(24px);
            opacity: 0;
            transition: .22s ease;
        }
        .app-toast.show { transform: translateX(0); opacity: 1; }
        .app-toast.closing { transform: translateX(24px); opacity: 0; }
        .app-toast-icon {
            width: 42px;
            height: 42px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
        }
        .app-toast-body strong { display: block; font-size: 14px; color: #2d3436; margin-bottom: 3px; }
        .app-toast-body span { display: block; font-size: 13px; color: #636e72; line-height: 1.45; }
        .app-toast-close { border: 0; background: transparent; color: #b2bec3; font-size: 22px; cursor: pointer; line-height: 1; padding: 0; }
        .app-toast-success .app-toast-icon { background: #eafaf1; color: #27ae60; }
        .app-toast-error .app-toast-icon { background: #fff5f5; color: #e74c3c; }
        .app-toast-warning .app-toast-icon { background: #fff3e0; color: #e67e22; }
        .app-toast-info .app-toast-icon { background: #e3f2fd; color: #2196f3; }

        .app-confirm-overlay {
            display: none;
            position: fixed;
            inset: 0;
            z-index: 19999;
            background: rgba(45,52,54,.48);
            backdrop-filter: blur(4px);
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .app-confirm-overlay.active { display: flex; }
        .app-confirm-card {
            width: min(430px, 100%);
            background: #fff;
            border-radius: 22px;
            padding: 28px;
            box-shadow: 0 24px 80px rgba(0,0,0,.2);
        }
        .app-confirm-icon {
            width: 54px;
            height: 54px;
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 16px;
            font-size: 20px;
        }
        .app-confirm-warning { background: #fff3e0; color: #e67e22; }
        .app-confirm-danger { background: #fff5f5; color: #e74c3c; }
        .app-confirm-success { background: #eafaf1; color: #27ae60; }
        .app-confirm-info { background: #e3f2fd; color: #2196f3; }
        .app-confirm-card h3 { margin: 0 0 8px; color: #2d3436; font-size: 21px; }
        .app-confirm-card p { margin: 0; color: #636e72; line-height: 1.55; font-size: 14px; }
        .app-confirm-actions { display: flex; gap: 10px; margin-top: 22px; }
        .app-btn { flex: 1; border: 0; border-radius: 12px; padding: 13px 16px; font-weight: 700; font-family: 'Inter', sans-serif; cursor: pointer; }
        .app-btn-secondary { background: #f1f2f6; color: #636e72; }
        .app-btn-danger { background: #e74c3c; color: #fff; }
        @media (max-width: 600px) {
            .app-toast-root { top: 78px; left: 16px; right: 16px; width: auto; }
            .app-confirm-card { padding: 24px; }
        }

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
                    <a href="<?= base_url('admin/karyawan') ?>"><i class="fas fa-users"></i> Karyawan</a>
                <?php endif; ?>
                
                <a href="<?= base_url('admin/riwayat') ?>"><i class="fas fa-history"></i> Riwayat</a>
                
                <?php if ($role === 'admin'): ?>
                    <!-- Pendapatan only visible to ADMIN -->
                    <a href="<?= base_url('admin/pendapatan') ?>"><i class="fas fa-chart-bar"></i> Pendapatan</a>
                <?php endif; ?>
                
                <a href="<?= base_url('logout') ?>" class="btn-logout"><i class="fas fa-sign-out-alt"></i> Keluar</a>
            <?php else: ?>
                <a href="<?= base_url('login') ?>"><i class="fas fa-sign-in-alt"></i> Login</a>
                <a href="<?= base_url('register') ?>"><i class="fas fa-user-plus"></i> Daftar</a>
            <?php endif; ?>
        </div>
    </nav>
    <div class="container"><?= $this->renderSection('content') ?></div>

    <div id="appToastRoot" class="app-toast-root" aria-live="polite" aria-atomic="true"></div>

    <div id="appConfirmOverlay" class="app-confirm-overlay" role="dialog" aria-modal="true" aria-labelledby="appConfirmTitle">
        <div class="app-confirm-card">
            <div id="appConfirmIcon" class="app-confirm-icon app-confirm-warning"><i class="fas fa-question"></i></div>
            <h3 id="appConfirmTitle">Konfirmasi</h3>
            <p id="appConfirmMessage">Apakah Anda yakin?</p>
            <div class="app-confirm-actions">
                <button type="button" class="app-btn app-btn-secondary" id="appConfirmCancel">Batal</button>
                <button type="button" class="app-btn app-btn-danger" id="appConfirmOk">Ya, lanjutkan</button>
            </div>
        </div>
    </div>

    <script>
        (function () {
            const toastRoot = document.getElementById('appToastRoot');
            const overlay = document.getElementById('appConfirmOverlay');
            const confirmTitle = document.getElementById('appConfirmTitle');
            const confirmMessage = document.getElementById('appConfirmMessage');
            const confirmIcon = document.getElementById('appConfirmIcon');
            const confirmCancel = document.getElementById('appConfirmCancel');
            const confirmOk = document.getElementById('appConfirmOk');
            let confirmCallback = null;

            const toastMeta = {
                success: { icon: 'fa-check', title: 'Berhasil' },
                error: { icon: 'fa-times', title: 'Gagal' },
                warning: { icon: 'fa-exclamation', title: 'Perhatian' },
                info: { icon: 'fa-info', title: 'Informasi' },
            };

            window.showAppToast = function (message, type = 'info', title = null, duration = 4200) {
                if (!message || !toastRoot) return;
                const safeType = toastMeta[type] ? type : 'info';
                const meta = toastMeta[safeType];
                const toast = document.createElement('div');
                toast.className = 'app-toast app-toast-' + safeType;
                toast.innerHTML = `
                    <div class="app-toast-icon"><i class="fas ${meta.icon}"></i></div>
                    <div class="app-toast-body">
                        <strong>${title || meta.title}</strong>
                        <span></span>
                    </div>
                    <button type="button" class="app-toast-close" aria-label="Tutup">&times;</button>
                `;
                toast.querySelector('.app-toast-body span').textContent = message;
                toast.querySelector('.app-toast-close').addEventListener('click', () => closeToast(toast));
                toastRoot.appendChild(toast);
                requestAnimationFrame(() => toast.classList.add('show'));
                if (duration > 0) setTimeout(() => closeToast(toast), duration);
            };

            function closeToast(toast) {
                if (!toast || toast.classList.contains('closing')) return;
                toast.classList.add('closing');
                toast.classList.remove('show');
                setTimeout(() => toast.remove(), 220);
            }

            window.showAppConfirm = function (options) {
                if (!overlay) return;
                const config = Object.assign({
                    title: 'Konfirmasi',
                    message: 'Apakah Anda yakin?',
                    type: 'warning',
                    confirmText: 'Ya, lanjutkan',
                    cancelText: 'Batal',
                    onConfirm: null,
                }, options || {});

                confirmCallback = typeof config.onConfirm === 'function' ? config.onConfirm : null;
                confirmTitle.textContent = config.title;
                confirmMessage.textContent = config.message;
                confirmOk.textContent = config.confirmText;
                confirmCancel.textContent = config.cancelText;
                confirmIcon.className = 'app-confirm-icon app-confirm-' + (['danger', 'warning', 'success', 'info'].includes(config.type) ? config.type : 'warning');
                confirmIcon.innerHTML = '<i class="fas ' + (config.type === 'danger' ? 'fa-trash' : config.type === 'success' ? 'fa-check' : config.type === 'info' ? 'fa-info' : 'fa-exclamation') + '"></i>';
                overlay.classList.add('active');
                confirmCancel.focus();
            };

            function closeConfirm() {
                overlay.classList.remove('active');
                confirmCallback = null;
            }

            confirmCancel.addEventListener('click', closeConfirm);
            confirmOk.addEventListener('click', function () {
                const cb = confirmCallback;
                closeConfirm();
                if (cb) cb();
            });
            overlay.addEventListener('click', function (e) { if (e.target === overlay) closeConfirm(); });
            window.addEventListener('keydown', function (e) { if (e.key === 'Escape' && overlay.classList.contains('active')) closeConfirm(); });

            <?php if (session()->getFlashdata('success')): ?>
                showAppToast(<?= json_encode(strip_tags((string) session()->getFlashdata('success'))) ?>, 'success');
            <?php endif; ?>
            <?php if (session()->getFlashdata('error')): ?>
                showAppToast(<?= json_encode(strip_tags((string) session()->getFlashdata('error'))) ?>, 'error');
            <?php endif; ?>
            <?php if (session()->getFlashdata('warning')): ?>
                showAppToast(<?= json_encode(strip_tags((string) session()->getFlashdata('warning'))) ?>, 'warning');
            <?php endif; ?>
        })();
    </script>

</body>
</html>