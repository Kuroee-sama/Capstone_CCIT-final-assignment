<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login — Cafeínaja</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { 
            font-family: 'Inter', sans-serif; 
            min-height: 100vh; 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            background: linear-gradient(135deg, #f5f7fa 0%, #ffecd2 100%); 
            padding: 20px;
        }
        .login-box { 
            width: 100%; 
            max-width: 420px; 
            background: white; 
            padding: 50px 40px; 
            border-radius: 24px; 
            box-shadow: 0 20px 60px rgba(0,0,0,0.08); 
            text-align: center; 
        }
        .login-box h2 { color: #e67e22; font-size: 28px; margin-bottom: 8px; }
        .login-box p { color: #636e72; margin-bottom: 30px; font-size: 14px; }
        .form-group { margin-bottom: 18px; text-align: left; }
        .form-group label { display: block; font-size: 13px; font-weight: 600; color: #2d3436; margin-bottom: 6px; }
        .form-group input { 
            width: 100%; 
            padding: 14px 16px; 
            border: 2px solid #eee; 
            border-radius: 12px; 
            font-size: 14px; 
            transition: border-color 0.3s;
            outline: none;
            font-family: 'Inter', sans-serif;
        }
        .form-group input:focus { border-color: #e67e22; }
        .btn-login { 
            background: linear-gradient(135deg, #e67e22, #d35400); 
            color: white; 
            border: none; 
            width: 100%; 
            padding: 16px; 
            border-radius: 12px; 
            font-weight: 700; 
            cursor: pointer; 
            font-size: 16px; 
            transition: transform 0.2s, box-shadow 0.2s;
            font-family: 'Inter', sans-serif;
            margin-top: 10px;
        }
        .btn-login:hover { transform: translateY(-2px); box-shadow: 0 8px 25px rgba(230,126,34,0.3); }
        .alert { background: #fff5f5; color: #e74c3c; padding: 12px; border-radius: 10px; margin-bottom: 20px; font-size: 13px; border: 1px solid #fecaca; }
        
        @media (max-width: 480px) {
            .login-box { padding: 35px 25px; }
            .login-box h2 { font-size: 24px; }
        }
    </style>
</head>
<body>
    <div class="login-box">
        <h2>Selamat Datang</h2>
        <p>Masuk ke sistem Cafeínaja</p>
        
        <?php if (session()->getFlashdata('error')): ?>
            <div class="alert"><?= session()->getFlashdata('error') ?></div>
        <?php endif; ?>
        
        <form action="<?= base_url('login/auth') ?>" method="post">
            <div class="form-group">
                <label>Email</label>
                <input type="email" name="email" placeholder="contoh@cafe.com" required>
            </div>
            <div class="form-group">
                <label>Password</label>
                <input type="password" name="password" placeholder="Masukkan password" required>
            </div>
            <button type="submit" class="btn-login">Masuk Sistem</button>
        </form>
    </div>
</body>
</html>