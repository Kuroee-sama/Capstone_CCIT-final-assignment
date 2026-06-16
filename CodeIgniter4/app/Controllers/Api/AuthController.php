<?php

namespace App\Controllers\Api;

use App\Models\Karyawan;
use CodeIgniter\API\ResponseTrait;
use CodeIgniter\RESTful\ResourceController;

class AuthController extends ResourceController
{
    use ResponseTrait;

    public function register()
    {
        $payload = $this->payload();
        $rules = [
            'username' => 'required|min_length[3]|is_unique[karyawan.username]',
            'email'    => 'required|valid_email|is_unique[karyawan.email]',
            'password' => 'required|min_length[6]',
            'role'     => 'permit_empty|in_list[ADMIN,KARYAWAN]',
        ];

        if (!$this->validateData($payload, $rules)) {
            return $this->fail($this->validator->getErrors());
        }

        $model = new Karyawan();
        $data = [
            'username'  => $payload['username'],
            'email'     => $payload['email'],
            'password'  => password_hash($payload['password'], PASSWORD_BCRYPT),
            'role'      => $payload['role'] ?? 'KARYAWAN',
            'umur'      => $payload['umur'] ?? null,
            'alamat'    => $payload['alamat'] ?? null,
            'tgl_lahir' => $payload['tgl_lahir'] ?? ($payload['tglLahir'] ?? null),
            'no_telp'   => $payload['no_telp'] ?? ($payload['noTelp'] ?? null),
        ];

        if (!$model->insert($data)) {
            return $this->failServerError('Failed to register user');
        }

        $user = $model->find($model->getInsertID());
        return $this->respondCreated($this->authResponse($user, 'Registrasi berhasil'));
    }

    public function login()
    {
        $payload = $this->payload();
        $identity = $payload['username'] ?? $payload['email'] ?? null;
        $password = $payload['password'] ?? null;

        if (!$identity || !$password) {
            return $this->fail(['error' => 'Username/email dan password wajib diisi'], 400);
        }

        $model = new Karyawan();
        $user = $model->groupStart()
            ->where('username', $identity)
            ->orWhere('email', $identity)
            ->groupEnd()
            ->first();

        if (!$user || !password_verify($password, $user['password'])) {
            return $this->failUnauthorized('Username/email atau password salah');
        }

        return $this->respond($this->authResponse($user, 'Login berhasil'));
    }

    public function health()
    {
        return $this->respond([
            'status' => 'UP',
            'message' => 'Auth service is running',
        ]);
    }

    private function payload(): array
    {
        $json = $this->request->getJSON(true);
        if (is_array($json)) {
            return $json;
        }
        return $this->request->getPost() ?: [];
    }

    private function authResponse(array $user, string $message): array
    {
        return [
            'token' => $this->createToken($user),
            'tokenType' => 'Bearer',
            'message' => $message,
            'karyawan' => [
                'karyawanId' => (int) $user['karyawan_id'],
                'username' => $user['username'],
                'email' => $user['email'],
                'umur' => isset($user['umur']) ? (int) $user['umur'] : null,
                'alamat' => $user['alamat'] ?? null,
                'noTelp' => $user['no_telp'] ?? null,
                'role' => $user['role'] ?? 'KARYAWAN',
            ],
        ];
    }

    private function createToken(array $user): string
    {
        $header = ['typ' => 'JWT', 'alg' => 'HS256'];
        $now = time();
        $payload = [
            'sub' => $user['username'],
            'id' => (int) $user['karyawan_id'],
            'email' => $user['email'],
            'role' => $user['role'] ?? 'KARYAWAN',
            'iat' => $now,
            'exp' => $now + 86400,
        ];

        $segments = [
            $this->base64UrlEncode(json_encode($header)),
            $this->base64UrlEncode(json_encode($payload)),
        ];
        $signingInput = implode('.', $segments);
        $signature = hash_hmac('sha256', $signingInput, $this->jwtSecret(), true);
        $segments[] = $this->base64UrlEncode($signature);

        return implode('.', $segments);
    }

    private function base64UrlEncode(string $data): string
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    private function jwtSecret(): string
    {
        return getenv('JWT_SECRET') ?: 'local-dev-secret-change-this';
    }
}
