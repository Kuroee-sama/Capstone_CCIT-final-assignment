<?php

namespace App\Controllers\Api;

use CodeIgniter\RESTful\ResourceController;

class KaryawanController extends ResourceController
{
    protected $modelName = 'App\Models\Karyawan';
    protected $format    = 'json';

    public function index()
    {
        $rows = $this->model->findAll();
        return $this->respond(array_map([$this, 'withoutPassword'], $rows));
    }

    public function show($id = null)
    {
        $data = $this->model->find($id);
        if (!$data) {
            return $this->failNotFound('Karyawan not found');
        }
        return $this->respond($this->withoutPassword($data));
    }

    public function create()
    {
        $data = $this->normalize($this->payload());
        $rules = [
            'username' => 'required|min_length[3]|is_unique[karyawan.username]',
            'email'    => 'required|valid_email|is_unique[karyawan.email]',
            'password' => 'required|min_length[6]',
            'role'     => 'permit_empty|in_list[ADMIN,KARYAWAN]',
        ];

        if (!$this->validateData($data, $rules)) {
            return $this->fail($this->validator->getErrors());
        }

        $data['role'] = $data['role'] ?? 'KARYAWAN';
        $data['password'] = password_hash($data['password'], PASSWORD_BCRYPT);

        if ($this->model->insert($data)) {
            return $this->respondCreated($this->withoutPassword($this->model->find($this->model->getInsertID())));
        }

        return $this->failServerError('Failed to create karyawan');
    }

    public function createBulk()
    {
        $payload = $this->request->getJSON(true) ?: $this->request->getVar();
        if (!is_array($payload)) {
            return $this->fail('Invalid data format. Expected array of objects.');
        }

        $insertedIds = [];
        foreach ($payload as $row) {
            $data = $this->normalize((array) $row);
            if (empty($data['email']) || empty($data['username']) || empty($data['password'])) {
                continue;
            }
            $data['role'] = $data['role'] ?? 'KARYAWAN';
            $data['password'] = password_hash($data['password'], PASSWORD_BCRYPT);
            if ($this->model->insert($data)) {
                $insertedIds[] = $this->model->getInsertID();
            }
        }

        return $this->respondCreated(['message' => count($insertedIds) . ' karyawan created', 'ids' => $insertedIds]);
    }

    public function update($id = null)
    {
        if (!$this->model->find($id)) {
            return $this->failNotFound('Karyawan not found');
        }
        $data = $this->normalize($this->payload());
        if (isset($data['password']) && $data['password'] !== '') {
            $data['password'] = password_hash($data['password'], PASSWORD_BCRYPT);
        } else {
            unset($data['password']);
        }
        $this->model->update($id, $data);
        return $this->respond($this->withoutPassword($this->model->find($id)));
    }

    public function delete($id = null)
    {
        if ($this->model->delete($id)) {
            return $this->respondDeleted(['message' => 'Karyawan deleted successfully']);
        }
        return $this->failNotFound('Karyawan not found');
    }

    public function deleteBulk()
    {
        $payload = $this->request->getJSON(true) ?: $this->request->getVar();
        $ids = $payload['ids'] ?? null;
        if (!is_array($ids)) {
            return $this->fail('Invalid data format. Expected array of IDs.');
        }

        $deleted = 0;
        foreach ($ids as $id) {
            if ($this->model->delete($id)) {
                $deleted++;
            }
        }

        return $this->respondDeleted(['message' => $deleted . ' karyawan deleted']);
    }

    private function payload(): array
    {
        $json = $this->request->getJSON(true);
        if (is_array($json)) {
            return $json;
        }
        $raw = $this->request->getRawInput();
        return $raw ?: ($this->request->getPost() ?: []);
    }

    private function normalize(array $data): array
    {
        if (isset($data['tglLahir'])) {
            $data['tgl_lahir'] = $data['tglLahir'];
            unset($data['tglLahir']);
        }
        if (isset($data['noTelp'])) {
            $data['no_telp'] = $data['noTelp'];
            unset($data['noTelp']);
        }
        return $data;
    }

    private function withoutPassword(array $row): array
    {
        unset($row['password']);
        return $row;
    }
}
