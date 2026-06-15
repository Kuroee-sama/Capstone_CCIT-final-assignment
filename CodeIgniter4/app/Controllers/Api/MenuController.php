<?php

namespace App\Controllers\Api;

use App\Models\Menu;
use CodeIgniter\RESTful\ResourceController;

class MenuController extends ResourceController
{
    protected $modelName = 'App\Models\Menu';
    protected $format    = 'json';

    public function index()
    {
        return $this->respond($this->model->findAll());
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
        $rules = [
            'nama_item' => 'required',
            'harga'     => 'required|numeric',
        ];

        if (!$this->validate($rules)) {
            return $this->fail($this->validator->getErrors());
        }

        $data = [
            'nama_item' => $this->request->getVar('nama_item'),
            'harga'     => $this->request->getVar('harga'),
            'm_description' => $this->request->getVar('m_description') ?? null,
            'gambar'    => $this->request->getVar('gambar') ?? null,
        ];

        if ($this->model->insert($data)) {
            $menuId = $this->model->getInsertID();

            // Insert relasi kategori jika ada
            $kategoriId = $this->request->getVar('kategori_id');
            if ($kategoriId) {
                $db = \Config\Database::connect();
                $db->table('menu_kategori')->insert([
                    'menu_id'     => $menuId,
                    'kategori_id' => $kategoriId,
                ]);
            }

            return $this->respondCreated(['id' => $menuId, 'message' => 'Menu created successfully']);
        }

        return $this->failServerError('Failed to create menu');
    }

    public function createBulk()
    {
        $data = $this->request->getVar();
        if (!is_array($data)) {
             return $this->fail('Invalid data format. Expected array of objects.');
        }

        $insertedIds = [];
        foreach ($data as $row) {
             if (empty($row->nama_item) || empty($row->harga)) continue;

             if ($this->model->insert((array)$row)) {
                 $insertedIds[] = $this->model->getInsertID();
             }
        }

        return $this->respondCreated(['message' => count($insertedIds) . ' menu items created', 'ids' => $insertedIds]);
    }
    
    public function update($id = null)
    {
        $data = $this->request->getRawInput();
        
        // Pisahkan kategori_id dari data menu
        $kategoriId = $data['kategori_id'] ?? null;
        unset($data['kategori_id']);
        
        $this->model->update($id, $data);

        // Update relasi kategori jika ada
        if ($kategoriId !== null) {
            $db = \Config\Database::connect();
            $db->table('menu_kategori')->where('menu_id', $id)->delete();
            $db->table('menu_kategori')->insert([
                'menu_id'     => $id,
                'kategori_id' => $kategoriId,
            ]);
        }

        return $this->respond(['message' => 'Menu updated successfully']);
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
        
        return $this->respondDeleted(['message' => $deleted . ' menu items deleted']);
    }

    public function findByKategori($kategoriId = null)
    {
        $db = \Config\Database::connect();
        $data = $db->table('menu')
            ->select('menu.*')
            ->join('menu_kategori', 'menu_kategori.menu_id = menu.menu_id')
            ->where('menu_kategori.kategori_id', $kategoriId)
            ->get()
            ->getResultArray();
        
        return $this->respond($data);
    }
}
