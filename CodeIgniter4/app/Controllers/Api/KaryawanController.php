<?php

namespace App\Controllers\Api;

use App\Models\Karyawan;
use CodeIgniter\RESTful\ResourceController;

class KaryawanController extends ResourceController
{
    protected $modelName = 'App\Models\Karyawan';
    protected $format    = 'json';

    public function index()
    {
        return $this->respond($this->model->findAll());
    }

    public function show($id = null)
    {
        $data = $this->model->find($id);
        if (!$data) {
            return $this->failNotFound('Karyawan not found');
        }
        return $this->respond($data);
    }

    public function create()
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

        $data = $this->request->getPost();
        // Hash password sebelum insert
        if (isset($data['password'])) {
            $data['password'] = password_hash($data['password'], PASSWORD_BCRYPT);
        }

        if ($this->model->insert($data)) {
            return $this->respondCreated(['id' => $this->model->getInsertID(), 'message' => 'Karyawan created successfully']);
        }

        return $this->failServerError('Failed to create karyawan');
    }

    public function createBulk()
    {
        $data = $this->request->getVar();
        if (!is_array($data)) {
            return $this->fail('Invalid data format. Expected array of objects.');
        }

        $insertedIds = [];
        foreach ($data as $row) {
             if (empty($row->email) || empty($row->username)) continue;

             $rowData = (array)$row;
             if (isset($rowData['password'])) {
                 $rowData['password'] = password_hash($rowData['password'], PASSWORD_BCRYPT);
             }

             if ($this->model->insert($rowData)) {
                 $insertedIds[] = $this->model->getInsertID();
             }
        }

        return $this->respondCreated(['message' => count($insertedIds) . ' karyawan created', 'ids' => $insertedIds]);
    }

    public function update($id = null)
    {
        $data = $this->request->getRawInput();
        // Hash password jika diupdate
        if (isset($data['password'])) {
            $data['password'] = password_hash($data['password'], PASSWORD_BCRYPT);
        }
        $this->model->update($id, $data);
        return $this->respond(['message' => 'Karyawan updated successfully']);
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
        $ids = $this->request->getVar('ids');
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
}
