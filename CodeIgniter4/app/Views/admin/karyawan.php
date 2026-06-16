<?= $this->extend('layouts/main') ?>

<?= $this->section('content') ?>
<style>
    .page-head { display: flex; justify-content: space-between; align-items: center; gap: 16px; margin-bottom: 28px; }
    .page-head h1 { margin: 0; color: #2d3436; font-size: 2rem; }
    .page-head p { margin: 8px 0 0; color: #636e72; }
    .btn-primary { background: #e67e22; color: #fff; border: 0; border-radius: 12px; padding: 13px 18px; font-weight: 700; cursor: pointer; text-decoration: none; display: inline-flex; gap: 8px; align-items: center; }
    .alert { padding: 13px 15px; border-radius: 12px; margin-bottom: 18px; font-size: 14px; }
    .alert-success { background: #f0fff4; color: #27ae60; border: 1px solid #bbf7d0; }
    .alert-error { background: #fff5f5; color: #e74c3c; border: 1px solid #fecaca; }
    .card { background: #fff; border-radius: 18px; box-shadow: 0 4px 15px rgba(0,0,0,.04); overflow: hidden; }
    table { width: 100%; border-collapse: collapse; }
    th, td { padding: 15px 18px; border-bottom: 1px solid #eee; text-align: left; vertical-align: top; }
    th { color: #636e72; font-size: 13px; font-weight: 700; background: #fafafa; }
    td { color: #2d3436; font-size: 14px; }
    .role { display: inline-block; padding: 5px 10px; border-radius: 999px; font-size: 11px; font-weight: 800; }
    .role-admin { background:#e8f5e9; color:#2ecc71; }
    .role-karyawan { background:#e3f2fd; color:#3498db; }
    .actions { display: flex; gap: 8px; flex-wrap: wrap; }
    .btn-edit, .btn-delete { border: 0; border-radius: 999px; padding: 8px 12px; font-size: 13px; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 5px; }
    .btn-edit { color: #0984e3; background: #e3f2fd; }
    .btn-delete { color: #e74c3c; background: #fff5f5; }
    .modal { display:none; position:fixed; inset:0; background:rgba(0,0,0,.45); z-index:999; align-items:center; justify-content:center; padding:20px; }
    .modal.active { display:flex; }
    .modal-box { width:100%; max-width:620px; max-height:92vh; overflow:auto; background:#fff; border-radius:20px; padding:26px; }
    .modal-box h2 { margin:0 0 18px; color:#2d3436; }
    .form-grid { display:grid; grid-template-columns:1fr 1fr; gap:14px; }
    .form-group { text-align:left; }
    .form-group.full { grid-column:1 / -1; }
    label { display:block; font-size:12px; color:#636e72; font-weight:700; margin-bottom:6px; }
    input, select, textarea { width:100%; border:2px solid #eee; border-radius:12px; padding:12px 13px; font-family:Inter,sans-serif; outline:none; }
    input:focus, select:focus, textarea:focus { border-color:#e67e22; }
    .field-invalid { border-color:#e74c3c !important; box-shadow:0 0 0 4px rgba(231,76,60,.10); }
    textarea { resize:vertical; min-height:80px; }
    .modal-actions { display:flex; justify-content:flex-end; gap:10px; margin-top:20px; }
    .btn-secondary { background:#f3f4f6; color:#374151; border:0; border-radius:12px; padding:12px 16px; cursor:pointer; font-weight:700; }
    @media(max-width:760px){ .page-head{align-items:flex-start; flex-direction:column;} .table-wrap{overflow-x:auto;} table{min-width:850px;} .form-grid{grid-template-columns:1fr;} }
</style>

<div class="page-head">
    <div>
        <h1>Kelola Karyawan</h1>
        <p>Tambah, edit, dan hapus akun admin atau karyawan.</p>
    </div>
    <button class="btn-primary" onclick="openCreateModal()"><i class="fas fa-user-plus"></i> Tambah Karyawan</button>
</div>


<div class="card table-wrap">
    <table>
        <thead>
            <tr>
                <th>No</th>
                <th>Username</th>
                <th>Email</th>
                <th>Role</th>
                <th>No. Telepon</th>
                <th>Umur</th>
                <th>Aksi</th>
            </tr>
        </thead>
        <tbody>
        <?php if (empty($karyawan)): ?>
            <tr><td colspan="7" style="text-align:center;color:#636e72;">Belum ada data karyawan.</td></tr>
        <?php endif; ?>
        <?php foreach ($karyawan as $i => $row): ?>
            <?php $role = strtoupper($row['role'] ?? 'KARYAWAN'); ?>
            <tr>
                <td><?= $i + 1 ?></td>
                <td><strong><?= esc($row['username']) ?></strong></td>
                <td><?= esc($row['email']) ?></td>
                <td><span class="role <?= $role === 'ADMIN' ? 'role-admin' : 'role-karyawan' ?>"><?= esc($role) ?></span></td>
                <td><?= esc($row['no_telp'] ?? '-') ?></td>
                <td><?= esc($row['umur'] ?? '-') ?></td>
                <td>
                    <div class="actions">
                        <button class="btn-edit" onclick='openEditModal(<?= json_encode($row, JSON_HEX_APOS|JSON_HEX_QUOT) ?>)'><i class="fas fa-edit"></i> Edit</button>
                        <?php if ((int) session()->get('id') !== (int) $row['karyawan_id']): ?>
                            <button class="btn-delete" type="button" onclick="confirmDeleteKaryawan(<?= (int) $row['karyawan_id'] ?>, <?= json_encode($row['username']) ?>)"><i class="fas fa-trash"></i> Hapus</button>
                        <?php endif; ?>
                    </div>
                </td>
            </tr>
        <?php endforeach; ?>
        </tbody>
    </table>
</div>

<div class="modal" id="karyawanModal">
    <div class="modal-box">
        <h2 id="modalTitle">Tambah Karyawan</h2>
        <form id="karyawanForm" action="<?= base_url('admin/karyawan/simpan') ?>" method="post" novalidate onsubmit="return validateKaryawanForm()">
            <?= csrf_field() ?>
            <div class="form-grid">
                <div class="form-group">
                    <label>Username</label>
                    <input type="text" name="username" id="username" required>
                </div>
                <div class="form-group">
                    <label>Email</label>
                    <input type="email" name="email" id="email" required>
                </div>
                <div class="form-group">
                    <label>Password <span id="passwordNote"></span></label>
                    <input type="password" name="password" id="password">
                </div>
                <div class="form-group">
                    <label>Role</label>
                    <select name="role" id="role" required>
                        <option value="KARYAWAN">KARYAWAN</option>
                        <option value="ADMIN">ADMIN</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Umur</label>
                    <input type="number" name="umur" id="umur" min="0">
                </div>
                <div class="form-group">
                    <label>Tanggal Lahir</label>
                    <input type="date" name="tgl_lahir" id="tgl_lahir">
                </div>
                <div class="form-group">
                    <label>No. Telepon</label>
                    <input type="text" name="no_telp" id="no_telp">
                </div>
                <div class="form-group full">
                    <label>Alamat</label>
                    <textarea name="alamat" id="alamat"></textarea>
                </div>
            </div>
            <div class="modal-actions">
                <button type="button" class="btn-secondary" onclick="closeModal()">Batal</button>
                <button type="submit" class="btn-primary">Simpan</button>
            </div>
        </form>
    </div>
</div>

<script>
function openCreateModal(){
    document.getElementById('modalTitle').innerText = 'Tambah Karyawan';
    document.getElementById('karyawanForm').action = '<?= base_url('admin/karyawan/simpan') ?>';
    document.getElementById('karyawanForm').reset();
    document.getElementById('password').required = true;
    document.getElementById('passwordNote').innerText = '';
    document.getElementById('karyawanModal').classList.add('active');
}
function openEditModal(row){
    document.getElementById('modalTitle').innerText = 'Edit Karyawan';
    document.getElementById('karyawanForm').action = '<?= base_url('admin/karyawan/update') ?>/' + row.karyawan_id;
    document.getElementById('username').value = row.username || '';
    document.getElementById('email').value = row.email || '';
    document.getElementById('password').value = '';
    document.getElementById('password').required = false;
    document.getElementById('passwordNote').innerText = '(kosongkan jika tidak diganti)';
    document.getElementById('role').value = (row.role || 'KARYAWAN').toUpperCase();
    document.getElementById('umur').value = row.umur || '';
    document.getElementById('tgl_lahir').value = row.tgl_lahir || '';
    document.getElementById('no_telp').value = row.no_telp || '';
    document.getElementById('alamat').value = row.alamat || '';
    document.getElementById('karyawanModal').classList.add('active');
}
function closeModal(){ document.getElementById('karyawanModal').classList.remove('active'); }

function notifyInvalid(fieldId, message) {
    showAppToast(message, 'warning', 'Data belum lengkap');
    const field = document.getElementById(fieldId);
    if (field) {
        field.focus({ preventScroll: false });
        field.classList.add('field-invalid');
        setTimeout(function () { field.classList.remove('field-invalid'); }, 1400);
    }
    return false;
}

function validateKaryawanForm(){
    const username = document.getElementById('username').value.trim();
    const email = document.getElementById('email').value.trim();
    const password = document.getElementById('password');
    const role = document.getElementById('role').value;
    if (!username) return notifyInvalid('username', 'Username wajib diisi.');
    if (username.length < 3) return notifyInvalid('username', 'Username minimal 3 karakter.');
    if (!email) return notifyInvalid('email', 'Email wajib diisi.');
    if (!email.includes('@')) return notifyInvalid('email', 'Format email belum valid.');
    if (password.required && password.value.length < 6) return notifyInvalid('password', 'Password minimal 6 karakter.');
    if (!role) return notifyInvalid('role', 'Role wajib dipilih.');
    showAppToast('Menyimpan data karyawan...', 'info', 'Diproses', 1800);
    return true;
}

function confirmDeleteKaryawan(id, username){
    showAppConfirm({
        title: 'Hapus Karyawan',
        message: 'Akun ' + username + ' akan dihapus. Data transaksi terkait dapat ikut terpengaruh sesuai relasi database.',
        type: 'danger',
        confirmText: 'Hapus Karyawan',
        onConfirm: function () { window.location.href = '<?= base_url('admin/karyawan/hapus') ?>/' + id; }
    });
}

window.addEventListener('keydown', function(e){ if(e.key === 'Escape') closeModal(); });
</script>

<?= $this->endSection() ?>
