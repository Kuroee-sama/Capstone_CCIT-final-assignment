<?php namespace App\Controllers\Web;
use App\Controllers\BaseController;
use App\Models\Karyawan;

class AuthController extends BaseController {
    public function index() {
        if (session()->get('isLoggedIn')) {
            return redirect()->to('/admin/dashboard');
        }
        return view('auth/login');
    }

    public function login() {
        $model = new Karyawan();
        $email = trim((string) $this->request->getPost('email'));
        $password = (string) $this->request->getPost('password');

        $user = $model->where('email', $email)->first();

        if ($user && password_verify($password, $user['password'])) {
            $this->setUserSession($user);
            return redirect()->to('/admin/dashboard');
        }

        return redirect()->back()->with('error', 'Email atau Password salah')->withInput();
    }

    public function register() {
        if (session()->get('isLoggedIn')) {
            return redirect()->to('/admin/dashboard');
        }
        return view('auth/register');
    }

    public function storeRegister() {
        $model = new Karyawan();

        $rules = [
            'username' => 'required|min_length[3]|max_length[50]|is_unique[karyawan.username]',
            'email'    => 'required|valid_email|max_length[100]|is_unique[karyawan.email]',
            'password' => 'required|min_length[6]',
            'no_telp'  => 'permit_empty|max_length[20]',
        ];

        if (!$this->validate($rules)) {
            return redirect()->back()
                ->with('error', implode('<br>', $this->validator->getErrors()))
                ->withInput();
        }

        $data = [
            'username' => trim((string) $this->request->getPost('username')),
            'email'    => trim((string) $this->request->getPost('email')),
            'password' => password_hash((string) $this->request->getPost('password'), PASSWORD_BCRYPT),
            'no_telp'  => trim((string) $this->request->getPost('no_telp')) ?: null,
            'role'     => 'KARYAWAN',
        ];

        $id = $model->insert($data);
        if (!$id) {
            return redirect()->back()->with('error', 'Registrasi gagal. Silakan coba lagi.')->withInput();
        }

        $user = $model->find($id);
        $this->setUserSession($user);
        return redirect()->to('/admin/dashboard');
    }

    public function logout() {
        session()->destroy();
        return redirect()->to('/katalog');
    }

    private function setUserSession(array $user): void {
        session()->set([
            'id'         => $user['karyawan_id'],
            'nama'       => $user['username'],
            'role'       => strtolower($user['role']),
            'isLoggedIn' => true,
        ]);
    }
}
