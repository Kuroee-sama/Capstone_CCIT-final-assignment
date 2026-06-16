<?php

namespace App\Controllers\Api;

use CodeIgniter\RESTful\ResourceController;

class KategoriController extends ResourceController
{
    protected $modelName = 'App\Models\Kategori';
    protected $format    = 'json';

    public function index()
    {
        return $this->respond($this->model->findAll());
    }

    public function show($id = null)
    {
        $data = $this->model->find($id);
        if (!$data) {
            return $this->failNotFound('Kategori not found');
        }
        return $this->respond($data);
    }

    public function create()
    {
        $data = $this->payload();
        $data = $this->normalize($data);

        if (empty($data['nama_kategori'])) {
            return $this->fail(['error' => 'namaKategori/nama_kategori is required'], 400);
        }

        if (!$this->model->insert($data)) {
            return $this->failServerError('Failed to create kategori');
        }

        return $this->respondCreated($this->model->find($this->model->getInsertID()));
    }

    public function update($id = null)
    {
        $data = $this->normalize($this->payload());
        if (!$this->model->find($id)) {
            return $this->failNotFound('Kategori not found');
        }
        $this->model->update($id, $data);
        return $this->respond($this->model->find($id));
    }

    public function delete($id = null)
    {
        if ($this->model->delete($id)) {
            return $this->respondDeleted(['message' => 'Kategori deleted successfully']);
        }
        return $this->failNotFound('Kategori not found');
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
        if (isset($data['namaKategori'])) {
            $data['nama_kategori'] = $data['namaKategori'];
            unset($data['namaKategori']);
        }
        if (isset($data['kDescription'])) {
            $data['k_description'] = $data['kDescription'];
            unset($data['kDescription']);
        }
        return $data;
    }
}
