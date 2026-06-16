<?php

namespace App\Controllers\Api;

use CodeIgniter\RESTful\ResourceController;

class MenuController extends ResourceController
{
    protected $modelName = 'App\Models\Menu';
    protected $format    = 'json';

    public function index()
    {
        $db = \Config\Database::connect();
        $data = $db->table('menu')
            ->select('menu.*, kategori.nama_kategori, kategori.k_description')
            ->join('kategori', 'kategori.kategori_id = menu.kategori_id', 'left')
            ->get()
            ->getResultArray();

        return $this->respond($data);
    }

    public function show($id = null)
    {
        $data = $this->model->find($id);
        if (!$data) {
            return $this->failNotFound('Menu item not found');
        }
        return $this->respond($data);
    }

    public function create()
    {
        $data = $this->normalize($this->payload());
        if (empty($data['nama_item']) || !isset($data['harga'])) {
            return $this->fail(['error' => 'namaItem/nama_item dan harga wajib diisi'], 400);
        }

        $data['stok'] = $data['stok'] ?? 0;

        if ($this->model->insert($data)) {
            return $this->respondCreated($this->model->find($this->model->getInsertID()));
        }

        return $this->failServerError('Failed to create menu');
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
            if (empty($data['nama_item']) || !isset($data['harga'])) {
                continue;
            }
            $data['stok'] = $data['stok'] ?? 0;
            if ($this->model->insert($data)) {
                $insertedIds[] = $this->model->getInsertID();
            }
        }

        return $this->respondCreated(['message' => count($insertedIds) . ' menu items created', 'ids' => $insertedIds]);
    }

    public function update($id = null)
    {
        if (!$this->model->find($id)) {
            return $this->failNotFound('Menu item not found');
        }

        $data = $this->normalize($this->payload());
        $this->model->update($id, $data);
        return $this->respond($this->model->find($id));
    }

    public function delete($id = null)
    {
        if ($this->model->delete($id)) {
            return $this->respondDeleted(['message' => 'Menu deleted successfully']);
        }
        return $this->failNotFound('Menu not found');
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

        return $this->respondDeleted(['message' => $deleted . ' menu items deleted']);
    }

    public function findByKategori($kategoriId = null)
    {
        return $this->respond($this->model->where('kategori_id', $kategoriId)->findAll());
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
        $map = [
            'menuId' => 'menu_id',
            'namaItem' => 'nama_item',
            'mDescription' => 'm_description',
            'kategoriId' => 'kategori_id',
        ];
        foreach ($map as $from => $to) {
            if (array_key_exists($from, $data)) {
                $data[$to] = $data[$from];
                unset($data[$from]);
            }
        }
        unset($data['kategori']);
        return $data;
    }
}
