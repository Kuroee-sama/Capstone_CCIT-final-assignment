<?php namespace App\Controllers\Web;

use App\Controllers\BaseController;
use App\Models\Karyawan;

class KaryawanController extends BaseController
{
    public function index()
    {
        $model = new Karyawan();
        $data['karyawan'] = $model->orderBy('karyawan_id', 'ASC')->findAll();
        return view('admin/karyawan', $data);
    }

    public function simpan()
    {
        $model = new Karyawan();
        $data = $this->validatedPayload(true);
        if ($data instanceof \CodeIgniter\HTTP\RedirectResponse) {
            return $data;
        }

        $data['password'] = password_hash($data['password'], PASSWORD_BCRYPT);
        if (!$model->insert($data)) {
            return redirect()->back()->with('error', 'Karyawan gagal ditambahkan.')->withInput();
        }

        return redirect()->to('/admin/karyawan')->with('success', 'Karyawan berhasil ditambahkan.');
    }

    public function update($id)
    {
        $model = new Karyawan();
        $existing = $model->find($id);
        if (!$existing) {
            return redirect()->to('/admin/karyawan')->with('error', 'Karyawan tidak ditemukan.');
        }

        $data = $this->validatedPayload(false, (int) $id);
        if ($data instanceof \CodeIgniter\HTTP\RedirectResponse) {
            return $data;
        }

        $password = (string) $this->request->getPost('password');
        if ($password !== '') {
            $data['password'] = password_hash($password, PASSWORD_BCRYPT);
        }

        $model->update($id, $data);
        if ((int) session()->get('id') === (int) $id) {
            session()->set('nama', $data['username']);
            session()->set('role', strtolower($data['role']));
        }

        return redirect()->to('/admin/karyawan')->with('success', 'Data karyawan berhasil diperbarui.');
    }

    public function hapus($id)
    {
        if ((int) session()->get('id') === (int) $id) {
            return redirect()->to('/admin/karyawan')->with('error', 'Akun yang sedang login tidak boleh dihapus.');
        }

        $model = new Karyawan();
        if (!$model->find($id)) {
            return redirect()->to('/admin/karyawan')->with('error', 'Karyawan tidak ditemukan.');
        }

        $model->delete($id);
        return redirect()->to('/admin/karyawan')->with('success', 'Karyawan berhasil dihapus.');
    }

    private function validatedPayload(bool $isCreate, ?int $id = null)
    {
        $uniqueUsername = $isCreate ? 'is_unique[karyawan.username]' : "is_unique[karyawan.username,karyawan_id,{$id}]";
        $uniqueEmail = $isCreate ? 'is_unique[karyawan.email]' : "is_unique[karyawan.email,karyawan_id,{$id}]";

        $rules = [
            'username' => "required|min_length[3]|max_length[50]|{$uniqueUsername}",
            'email'    => "required|valid_email|max_length[100]|{$uniqueEmail}",
            'role'     => 'required|in_list[ADMIN,KARYAWAN]',
            'umur'     => 'permit_empty|integer',
            'alamat'   => 'permit_empty',
            'tgl_lahir'=> 'permit_empty|valid_date[Y-m-d]',
            'no_telp'  => 'permit_empty|max_length[20]',
        ];

        if ($isCreate) {
            $rules['password'] = 'required|min_length[6]';
        } else {
            $rules['password'] = 'permit_empty|min_length[6]';
        }

        if (!$this->validate($rules)) {
            return redirect()->back()
                ->with('error', implode('<br>', $this->validator->getErrors()))
                ->withInput();
        }

        return [
            'username'  => trim((string) $this->request->getPost('username')),
            'email'     => trim((string) $this->request->getPost('email')),
            'umur'      => $this->request->getPost('umur') !== '' ? (int) $this->request->getPost('umur') : null,
            'alamat'    => trim((string) $this->request->getPost('alamat')) ?: null,
            'tgl_lahir' => $this->request->getPost('tgl_lahir') ?: null,
            'no_telp'   => trim((string) $this->request->getPost('no_telp')) ?: null,
            'role'      => strtoupper((string) $this->request->getPost('role')),
        ];
    }
}
