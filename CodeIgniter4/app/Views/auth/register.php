<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Daftar Akun — Cafeínaja</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; min-height: 100vh; display: flex; align-items: center; justify-content: center; background: linear-gradient(135deg, #f5f7fa 0%, #ffecd2 100%); padding: 20px; }
        .register-box { width: 100%; max-width: 420px; background: white; padding: 45px 40px; border-radius: 24px; box-shadow: 0 20px 60px rgba(0,0,0,0.08); text-align: center; }
        h2 { color: #e67e22; font-size: 28px; margin-bottom: 8px; }
        p { color: #636e72; margin-bottom: 30px; font-size: 14px; }
        .form-group { margin-bottom: 14px; text-align: left; }
        input { width: 100%; padding: 14px 16px; border: 2px solid #eee; border-radius: 12px; font-size: 14px; outline: none; font-family: 'Inter', sans-serif; }
        input:focus { border-color: #e67e22; }
        .btn-register { background: linear-gradient(135deg, #e67e22, #d35400); color: white; border: none; width: 100%; padding: 16px; border-radius: 12px; font-weight: 700; cursor: pointer; font-size: 16px; font-family: 'Inter', sans-serif; margin-top: 10px; }
        .btn-register:hover { transform: translateY(-1px); box-shadow: 0 8px 25px rgba(230,126,34,0.3); }
        .alert { background: #fff5f5; color: #e74c3c; padding: 12px; border-radius: 10px; margin-bottom: 20px; font-size: 13px; border: 1px solid #fecaca; text-align: left; }
        .login-link { margin-top: 20px; color: #636e72; font-size: 14px; }
        .login-link a { color: #e67e22; font-weight: 700; text-decoration: none; }
        @media (max-width: 480px) { .register-box { padding: 35px 25px; } h2 { font-size: 24px; } }
    </style>
</head>
<body>
    <div class="register-box">
        <h2>Daftar Akun</h2>
        <p>Buat akun kasir baru</p>

        <?php if (session()->getFlashdata('error')): ?>
            <div class="alert"><?= session()->getFlashdata('error') ?></div>
        <?php endif; ?>

        <form action="<?= base_url('register/store') ?>" method="post">
            <?= csrf_field() ?>
            <div class="form-group">
                <input type="text" name="username" placeholder="Username" value="<?= old('username') ?>" required>
            </div>
            <div class="form-group">
                <input type="email" name="email" placeholder="Email" value="<?= old('email') ?>" required>
            </div>
            <div class="form-group">
                <input type="password" name="password" placeholder="Password" required>
            </div>
            <div class="form-group">
                <input type="text" name="no_telp" placeholder="No. Telepon (opsional)" value="<?= old('no_telp') ?>">
            </div>
            <button type="submit" class="btn-register">Daftar</button>
        </form>
        <div class="login-link">Sudah punya akun? <a href="<?= base_url('login') ?>">Masuk</a></div>
    </div>
</body>
</html>
