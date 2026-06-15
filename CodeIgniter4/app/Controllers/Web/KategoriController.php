<?php namespace App\Controllers\Web;
use App\Controllers\BaseController;
use App\Models\Kategori;

class KategoriController extends BaseController {

    public function simpan()
    {
        $model = new Kategori();

        $data = [
            'nama_kategori'  => $this->request->getPost('nama_kategori'),
            'k_description'  => $this->request->getPost('k_description'),
        ];

        $model->insert($data);
        return redirect()->to('/admin/menu')->with('success', 'Kategori berhasil ditambahkan.');
    }

    public function update($id)
    {
        $model = new Kategori();

        $data = [
            'nama_kategori'  => $this->request->getPost('nama_kategori'),
            'k_description'  => $this->request->getPost('k_description'),
        ];

        $model->update($id, $data);
        return redirect()->to('/admin/menu')->with('success', 'Kategori berhasil diperbarui.');
    }

    public function hapus($id)
    {
        $model = new Kategori();
        
        // menu_kategori akan terhapus otomatis karena ON DELETE CASCADE
        $model->delete($id);
        return redirect()->to('/admin/menu')->with('success', 'Kategori berhasil dihapus.');
    }
}
