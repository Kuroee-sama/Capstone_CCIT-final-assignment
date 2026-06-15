<?php namespace App\Controllers\Web;
use App\Controllers\BaseController;
use App\Models\Menu;
use App\Models\Kategori;

class MenuController extends BaseController {
    
    public function index()
    {
        $db = \Config\Database::connect();
        
        // Query menu using direct FK instead of menu_kategori junction
        $menuData = $db->table('menu')
            ->select('menu.*, kategori.nama_kategori')
            ->join('kategori', 'kategori.kategori_id = menu.kategori_id', 'left')
            ->get()
            ->getResultArray();

        $kategoriModel = new Kategori();
        
        $data['menu'] = $menuData;
        $data['kategori'] = $kategoriModel->findAll();
        return view('admin/menu', $data);
    }

    public function simpan()
    {
        $model = new Menu();

        $data = [
            'nama_item' => $this->request->getPost('nama_item'),
            'harga'     => $this->request->getPost('harga'),
            'm_description' => $this->request->getPost('m_description'),
            'stok'      => $this->request->getPost('stok') ?? 0,
            'kategori_id' => $this->request->getPost('kategori_id') ?: null,
        ];

        // Handle upload gambar
        $gambar = $this->request->getFile('gambar');
        if ($gambar && $gambar->isValid() && !$gambar->hasMoved()) {
            $namaFile = $gambar->getRandomName();
            $gambar->move(FCPATH . 'uploads/menu', $namaFile);
            $data['gambar'] = $namaFile;
        }

        $model->insert($data);

        return redirect()->to('/admin/menu')->with('success', 'Menu berhasil ditambahkan.');
    }

    public function update($id)
    {
        $model = new Menu();

        $data = [
            'nama_item' => $this->request->getPost('nama_item'),
            'harga'     => $this->request->getPost('harga'),
            'm_description' => $this->request->getPost('m_description'),
            'stok'      => $this->request->getPost('stok'),
            'kategori_id' => $this->request->getPost('kategori_id') ?: null,
        ];

        // Handle upload gambar baru
        $gambar = $this->request->getFile('gambar');
        if ($gambar && $gambar->isValid() && !$gambar->hasMoved()) {
            // Hapus gambar lama jika ada
            $oldMenu = $model->find($id);
            if ($oldMenu && !empty($oldMenu['gambar'])) {
                $oldPath = FCPATH . 'uploads/menu/' . $oldMenu['gambar'];
                if (file_exists($oldPath)) {
                    unlink($oldPath);
                }
            }
            // Upload gambar baru
            $namaFile = $gambar->getRandomName();
            $gambar->move(FCPATH . 'uploads/menu', $namaFile);
            $data['gambar'] = $namaFile;
        }

        $model->update($id, $data);

        return redirect()->to('/admin/menu')->with('success', 'Menu berhasil diperbarui.');
    }

    public function hapus($id)
    {
        $model = new Menu();
        
        // Hapus file gambar dari disk
        $menu = $model->find($id);
        if ($menu && !empty($menu['gambar'])) {
            $path = FCPATH . 'uploads/menu/' . $menu['gambar'];
            if (file_exists($path)) {
                unlink($path);
            }
        }
        
        $model->delete($id);
        return redirect()->to('/admin/menu')->with('success', 'Menu berhasil dihapus.');
    }
}
