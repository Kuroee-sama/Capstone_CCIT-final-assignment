<?php

namespace App\Controllers\Api;

use App\Models\Karyawan;
use CodeIgniter\API\ResponseTrait;
use CodeIgniter\RESTful\ResourceController;
use Firebase\JWT\JWT;

class AuthController extends ResourceController
{
    use ResponseTrait;

    public function register()
    {
        $rules = [
            'username' => 'required|is_unique[karyawan.username]',
            'email'    => 'required|valid_email|is_unique[karyawan.email]',
            'password' => 'required|min_length(6)',
            'role'     => 'required|in_list[ADMIN,KARYAWAN]'
        ];

        if (!$this->validate($rules)) {
            return $this->fail($this->validator->getErrors());
        }

        $model = new Karyawan();
        $data = [
            'username'  => $this->request->getVar('username'),
            'email'     => $this->request->getVar('email'),
            'password'  => password_hash($this->request->getVar('password'), PASSWORD_BCRYPT),
            'role'      => $this->request->getVar('role'),
            'umur'      => $this->request->getVar('umur') ?? null,
            'alamat'    => $this->request->getVar('alamat') ?? null,
            'tgl_lahir' => $this->request->getVar('tgl_lahir') ?? null,
            'no_telp'   => $this->request->getVar('no_telp') ?? null,
        ];

        if ($model->insert($data)) {
            return $this->respondCreated(['message' => 'User registered successfully']);
        } else {
            return $this->failServerError('Failed to register user');
        }
    }

    public function login()
    {
        $rules = [
            'email'    => 'required|valid_email',
            'password' => 'required|min_length(6)'
        ];

        if (!$this->validate($rules)) {
            return $this->fail($this->validator->getErrors());
        }

        $model = new Karyawan();
        $user = $model->where('email', $this->request->getVar('email'))->first();

        if (!$user) {
            return $this->failNotFound('Email not found');
        }

        if (!password_verify($this->request->getVar('password'), $user['password'])) {
            return $this->fail('Invalid password');
        }

        $key = getenv('JWT_SECRET') ?: 'secret_key';
        $payload = [
            'iat' => time(),
            'exp' => time() + 3600,
            'uid' => $user['karyawan_id'],
            'role' => $user['role']
        ];

        $token = JWT::encode($payload, $key, 'HS256');

        return $this->respond([
            'message' => 'Login successful',
            'token' => $token,
            'user' => [
                'id' => $user['karyawan_id'],
                'username' => $user['username'],
                'email' => $user['email'],
                'role' => $user['role']
            ]
        ]);
    }

    public function health()
    {
        return $this->respond(['status' => 'Authentication Service is running']);
    }
}
