<?php namespace App\Controllers\Web;
use App\Controllers\BaseController;
use App\Models\Karyawan;

class AuthController extends BaseController {
    public function index() {
        // Jika sudah login, langsung arahkan ke dashboard admin
        if (session()->get('isLoggedIn')) {
            return redirect()->to('/admin/dashboard');
        }
        return view('auth/login');
    }

    public function login() {
        $model = new Karyawan();
        $email = $this->request->getPost('email');
        $password = $this->request->getPost('password');
        
        // Mencari user berdasarkan email dari tabel karyawan
        $user = $model->where('email', $email)->first();

        if ($user && password_verify($password, $user['password'])) {
            $sessData = [
                'id'         => $user['karyawan_id'],
                'nama'       => $user['username'],
                'role'       => strtolower($user['role']),
                'isLoggedIn' => true
            ];
            session()->set($sessData);
            // Semua karyawan diarahkan ke admin dashboard
            return redirect()->to('/admin/dashboard');
        }
        return redirect()->back()->with('error', 'Email atau Password salah');
    }

    public function logout() {
        session()->destroy();
        return redirect()->to('/login');
    }
}