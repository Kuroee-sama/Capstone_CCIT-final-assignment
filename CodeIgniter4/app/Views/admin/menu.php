<?= $this->extend('layouts/main') ?>

<?= $this->section('content') ?>
<style>
    .menu-container { max-width: 1100px; margin: 0 auto; }
    .menu-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; flex-wrap: wrap; gap: 15px; }
    .menu-header h2 { margin: 0; color: #2d3436; }
    .btn-tambah { 
        background: linear-gradient(135deg, #e67e22, #d35400); color: white; 
        border: none; padding: 12px 24px; border-radius: 12px; 
        font-weight: 600; cursor: pointer; font-family: 'Inter', sans-serif; 
        font-size: 14px; transition: 0.3s; text-decoration: none;
    }
    .btn-tambah:hover { transform: translateY(-2px); box-shadow: 0 8px 25px rgba(230,126,34,0.3); }
    .btn-kategori {
        background: linear-gradient(135deg, #6c5ce7, #a29bfe); color: white;
        border: none; padding: 12px 24px; border-radius: 12px;
        font-weight: 600; cursor: pointer; font-family: 'Inter', sans-serif;
        font-size: 14px; transition: 0.3s; text-decoration: none;
    }
    .btn-kategori:hover { transform: translateY(-2px); box-shadow: 0 8px 25px rgba(108,92,231,0.3); }
    .header-buttons { display: flex; gap: 10px; flex-wrap: wrap; }

    .alert-box { padding: 14px 20px; border-radius: 12px; margin-bottom: 20px; font-size: 14px; font-weight: 500; }
    .alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
    .alert-error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }

    .table-wrapper { background: white; border-radius: 20px; box-shadow: 0 4px 15px rgba(0,0,0,0.04); overflow: hidden; }
    .table-scroll { overflow-x: auto; }
    table { width: 100%; border-collapse: collapse; min-width: 860px; }
    thead { background: #f8f9fa; }
    th { padding: 16px 20px; text-align: left; font-size: 13px; color: #636e72; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; }
    td { padding: 14px 20px; border-top: 1px solid #f1f2f6; font-size: 14px; color: #2d3436; vertical-align: middle; }
    tr:hover td { background: #fafafa; }
    .badge { display: inline-block; padding: 4px 12px; border-radius: 8px; font-size: 11px; font-weight: 700; text-transform: uppercase; }
    .badge-kategori { background: #fff3e0; color: #e67e22; }
    .stock-pill { display: inline-flex; align-items: center; justify-content: center; min-width: 54px; padding: 6px 10px; border-radius: 999px; font-size: 12px; font-weight: 800; letter-spacing: .2px; }
    .stock-safe { background: #eafaf1; color: #1e8449; }
    .stock-low { background: #fff4de; color: #b7791f; }
    .stock-out { background: #ffe8e8; color: #c0392b; }
    .btn-action { 
        padding: 8px 14px; border-radius: 8px; border: none; 
        font-size: 12px; font-weight: 600; cursor: pointer; 
        font-family: 'Inter', sans-serif; transition: 0.2s; margin-right: 5px;
    }
    .btn-edit { background: #e3f2fd; color: #2196f3; }
    .btn-edit:hover { background: #2196f3; color: white; }
    .btn-hapus { background: #fff5f5; color: #e74c3c; }
    .btn-hapus:hover { background: #e74c3c; color: white; }

    .thumb-img { 
        width: 55px; height: 55px; border-radius: 10px; object-fit: cover; 
        border: 2px solid #f1f2f6; background: #fafafa;
    }
    .thumb-placeholder { 
        width: 55px; height: 55px; border-radius: 10px; background: #fff3e0; 
        display: flex; align-items: center; justify-content: center; font-size: 24px; 
    }

    /* Section Title */
    .section-title { 
        margin: 40px 0 20px; padding-bottom: 12px; 
        border-bottom: 2px solid #f1f2f6; color: #2d3436; font-size: 18px; 
    }
    .section-title i { margin-right: 8px; color: #6c5ce7; }

    /* Modal */
    .modal-overlay { 
        display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; 
        background: rgba(0,0,0,0.5); align-items: center; justify-content: center; 
        z-index: 9999; backdrop-filter: blur(3px); padding: 20px;
    }
    .modal-box { 
        background: white; width: 100%; max-width: 500px; padding: 35px; 
        border-radius: 20px; box-shadow: 0 20px 60px rgba(0,0,0,0.15);
        max-height: 90vh; overflow-y: auto;
    }
    .modal-box h3 { margin: 0 0 25px; color: #2d3436; font-size: 20px; }
    .form-group { margin-bottom: 18px; }
    .form-group label { display: block; font-size: 13px; font-weight: 600; color: #2d3436; margin-bottom: 6px; }
    .form-group input, .form-group select, .form-group textarea { 
        width: 100%; padding: 12px 14px; border: 2px solid #eee; border-radius: 10px; 
        font-size: 14px; outline: none; transition: border-color 0.3s; font-family: 'Inter', sans-serif;
    }
    .form-group input:focus, .form-group select:focus, .form-group textarea:focus { border-color: #e67e22; }
    .field-invalid { border-color: #e74c3c !important; box-shadow: 0 0 0 4px rgba(231,76,60,.10); }
    .form-group textarea { resize: vertical; min-height: 80px; }
    .form-group input[type="file"] { padding: 10px; border-style: dashed; background: #fafafa; cursor: pointer; }

    .img-preview-wrap { margin-top: 10px; }
    .img-preview { 
        max-width: 150px; max-height: 120px; border-radius: 10px; object-fit: cover; 
        border: 2px solid #f1f2f6; display: none;
    }
    .img-current { 
        max-width: 100px; max-height: 80px; border-radius: 8px; object-fit: cover; 
        border: 2px solid #f1f2f6; margin-top: 8px;
    }

    .modal-actions { display: flex; gap: 10px; margin-top: 10px; }
    .modal-actions button { flex: 1; padding: 14px; border-radius: 10px; border: none; font-weight: 600; cursor: pointer; font-size: 14px; font-family: 'Inter', sans-serif; }
    .btn-submit { background: linear-gradient(135deg, #e67e22, #d35400); color: white; }
    .btn-submit-kategori { background: linear-gradient(135deg, #6c5ce7, #a29bfe); color: white; }
    .btn-cancel { background: #f1f2f6; color: #636e72; }

    .empty-state { text-align: center; padding: 60px 20px; color: #b2bec3; }
    .empty-state i { font-size: 48px; margin-bottom: 15px; display: block; }

    @media (max-width: 600px) {
        .menu-header { flex-direction: column; align-items: stretch; }
        .btn-tambah, .btn-kategori { text-align: center; }
        th, td { padding: 12px 14px; }
    }
</style>

<div class="menu-container">
    <div class="menu-header">
        <div>
            <h2>Kelola Menu & Kategori</h2>
            <p style="margin: 5px 0 0; color: #636e72;">Tambah, edit, atau hapus menu dan kategori café</p>
        </div>
        <div class="header-buttons">
            <button class="btn-kategori" onclick="openKategoriModal()"><i class="fas fa-tags"></i> Tambah Kategori</button>
            <button class="btn-tambah" onclick="openModal()"><i class="fas fa-plus"></i> Tambah Menu</button>
        </div>
    </div>


    <!-- ======================== TABEL KATEGORI ======================== -->
    <h3 class="section-title"><i class="fas fa-tags"></i> Daftar Kategori</h3>
    <div class="table-wrapper" style="margin-bottom: 30px;">
        <?php if (!empty($kategori)): ?>
        <div class="table-scroll">
            <table>
                <thead>
                    <tr>
                        <th>No</th>
                        <th>Nama Kategori</th>
                        <th>Deskripsi</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($kategori as $i => $k): ?>
                    <tr>
                        <td><?= $i + 1 ?></td>
                        <td><strong><?= $k['nama_kategori'] ?></strong></td>
                        <td><?= $k['k_description'] ?? '-' ?></td>
                        <td>
                            <button class="btn-action btn-edit" onclick='openEditKategoriModal(<?= json_encode($k, JSON_HEX_APOS | JSON_HEX_QUOT) ?>)'><i class="fas fa-edit"></i> Edit</button>
                            <button class="btn-action btn-hapus" onclick="confirmHapusKategori(<?= $k['kategori_id'] ?>)"><i class="fas fa-trash"></i> Hapus</button>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
        <?php else: ?>
            <div class="empty-state">
                <i class="fas fa-tags"></i>
                <p>Belum ada kategori. Klik "Tambah Kategori" untuk mulai.</p>
            </div>
        <?php endif; ?>
    </div>

    <!-- ======================== TABEL MENU ======================== -->
    <h3 class="section-title"><i class="fas fa-utensils"></i> Daftar Menu</h3>
    <div class="table-wrapper">
        <?php if (!empty($menu)): ?>
        <div class="table-scroll">
            <table>
                <thead>
                    <tr>
                        <th>No</th>
                        <th>Gambar</th>
                        <th>Nama Item</th>
                        <th>Kategori</th>
                        <th>Harga</th>
                        <th>Stok</th>
                        <th>Deskripsi</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($menu as $i => $m): ?>
                    <tr>
                        <td><?= $i + 1 ?></td>
                        <td>
                            <?php if (!empty($m['gambar'])): ?>
                                <img src="<?= base_url('uploads/menu/' . $m['gambar']) ?>" class="thumb-img" alt="<?= $m['nama_item'] ?>">
                            <?php else: ?>
                                <div class="thumb-placeholder">🍽️</div>
                            <?php endif; ?>
                        </td>
                        <td><strong><?= $m['nama_item'] ?></strong></td>
                        <td><span class="badge badge-kategori"><?= $m['nama_kategori'] ?? 'Tanpa Kategori' ?></span></td>
                        <td>Rp <?= number_format($m['harga'], 0, ',', '.') ?></td>
                        <?php
                            $stokMenu = (int) ($m['stok'] ?? 0);
                            $stockClass = $stokMenu <= 0 ? 'stock-out' : ($stokMenu <= 10 ? 'stock-low' : 'stock-safe');
                            $stockText = $stokMenu <= 0 ? 'Habis' : $stokMenu;
                        ?>
                        <td><span class="stock-pill <?= $stockClass ?>"><?= $stockText ?></span></td>
                        <td><?= $m['m_description'] ?? '-' ?></td>
                        <td>
                            <button class="btn-action btn-edit" onclick='openEditModal(<?= json_encode($m, JSON_HEX_APOS | JSON_HEX_QUOT) ?>)'><i class="fas fa-edit"></i> Edit</button>
                            <button class="btn-action btn-hapus" onclick="confirmHapus(<?= $m['menu_id'] ?>)"><i class="fas fa-trash"></i> Hapus</button>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
        <?php else: ?>
            <div class="empty-state">
                <i class="fas fa-utensils"></i>
                <p>Belum ada menu. Klik "Tambah Menu" untuk mulai.</p>
            </div>
        <?php endif; ?>
    </div>
</div>

<!-- ======================== MODAL TAMBAH/EDIT MENU ======================== -->
<div id="modalMenu" class="modal-overlay">
    <div class="modal-box">
        <h3 id="modalTitle">Tambah Menu Baru</h3>
        <form id="formMenu" method="post" enctype="multipart/form-data" novalidate onsubmit="return validateMenuForm()">
            <input type="hidden" id="isEditMode" value="0">
            <div class="form-group">
                <label>Nama Item</label>
                <input type="text" name="nama_item" id="inp_nama" placeholder="Contoh: Cappuccino">
            </div>
            <div class="form-group">
                <label>Kategori</label>
                <select name="kategori_id" id="inp_kategori" size="1">
                    <option value="">-- Pilih Kategori --</option>
                    <?php if (!empty($kategori)): ?>
                        <?php foreach ($kategori as $k): ?>
                            <option value="<?= $k['kategori_id'] ?>"><?= $k['nama_kategori'] ?></option>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </select>
            </div>
            <div class="form-group">
                <label>Harga (Rp)</label>
                <input type="number" name="harga" id="inp_harga" placeholder="35000" min="0">
            </div>
            <div class="form-group">
                <label>Stok</label>
                <input type="number" name="stok" id="inp_stok" placeholder="100" min="0" step="1">
            </div>
            <div class="form-group">
                <label>Deskripsi</label>
                <textarea name="m_description" id="inp_deskripsi" placeholder="Deskripsi menu..."></textarea>
            </div>
            <div class="form-group">
                <label>Gambar Menu</label>
                <input type="file" name="gambar" id="inp_gambar" accept="image/*" onchange="previewImage(this)">
                <div class="img-preview-wrap">
                    <img id="imgPreview" class="img-preview" alt="Preview">
                    <div id="currentImgWrap" style="display:none;">
                        <small style="color:#636e72;">Gambar saat ini:</small><br>
                        <img id="currentImg" class="img-current" alt="Current">
                    </div>
                </div>
            </div>
            <div class="modal-actions">
                <button type="button" class="btn-cancel" onclick="closeModal()">Batal</button>
                <button type="submit" class="btn-submit">Simpan</button>
            </div>
        </form>
    </div>
</div>

<!-- ======================== MODAL TAMBAH/EDIT KATEGORI ======================== -->
<div id="modalKategori" class="modal-overlay">
    <div class="modal-box">
        <h3 id="modalKategoriTitle">Tambah Kategori Baru</h3>
        <form id="formKategori" method="post" novalidate onsubmit="return validateKategoriForm()">
            <div class="form-group">
                <label>Nama Kategori</label>
                <input type="text" name="nama_kategori" id="inp_nama_kategori" placeholder="Contoh: Kopi">
            </div>
            <div class="form-group">
                <label>Deskripsi Kategori</label>
                <textarea name="k_description" id="inp_k_description" placeholder="Deskripsi kategori..."></textarea>
            </div>
            <div class="modal-actions">
                <button type="button" class="btn-cancel" onclick="closeKategoriModal()">Batal</button>
                <button type="submit" class="btn-submit-kategori">Simpan</button>
            </div>
        </form>
    </div>
</div>

<script>
    // ========================================
    // IMAGE PREVIEW
    // ========================================
    function previewImage(input) {
        const preview = document.getElementById('imgPreview');
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = function(e) {
                preview.src = e.target.result;
                preview.style.display = 'block';
            };
            reader.readAsDataURL(input.files[0]);
        } else {
            preview.style.display = 'none';
            preview.src = '';
        }
    }

    // ========================================
    // MODAL MENU — Open / Close / Edit
    // ========================================
    function openModal() {
        document.getElementById('modalTitle').innerText = 'Tambah Menu Baru';
        document.getElementById('formMenu').action = '<?= base_url("admin/menu/simpan") ?>';
        document.getElementById('isEditMode').value = '0';
        document.getElementById('inp_nama').value = '';
        document.getElementById('inp_kategori').value = '';
        document.getElementById('inp_harga').value = '';
        document.getElementById('inp_stok').value = '';
        document.getElementById('inp_deskripsi').value = '';
        document.getElementById('inp_gambar').value = '';
        document.getElementById('imgPreview').style.display = 'none';
        document.getElementById('currentImgWrap').style.display = 'none';
        document.getElementById('modalMenu').style.display = 'flex';
    }

    function openEditModal(item) {
        document.getElementById('modalTitle').innerText = 'Edit Menu';
        document.getElementById('formMenu').action = '<?= base_url("admin/menu/update/") ?>' + item.menu_id;
        document.getElementById('isEditMode').value = '1';
        document.getElementById('inp_nama').value = item.nama_item;
        document.getElementById('inp_kategori').value = item.kategori_id || '';
        document.getElementById('inp_harga').value = item.harga;
        document.getElementById('inp_stok').value = item.stok ?? 0;
        document.getElementById('inp_deskripsi').value = item.m_description || '';
        document.getElementById('inp_gambar').value = '';
        document.getElementById('imgPreview').style.display = 'none';
        
        if (item.gambar) {
            document.getElementById('currentImgWrap').style.display = 'block';
            document.getElementById('currentImg').src = '<?= base_url("uploads/menu/") ?>' + item.gambar;
        } else {
            document.getElementById('currentImgWrap').style.display = 'none';
        }
        
        document.getElementById('modalMenu').style.display = 'flex';
    }

    function closeModal() {
        document.getElementById('modalMenu').style.display = 'none';
    }

    function confirmHapus(id) {
        showAppConfirm({
            title: 'Hapus Menu',
            message: 'Menu ini akan dihapus dari daftar. Tindakan ini tidak dapat dibatalkan.',
            type: 'danger',
            confirmText: 'Hapus Menu',
            onConfirm: function () { window.location.href = '<?= base_url("admin/menu/hapus/") ?>' + id; }
        });
    }

    document.getElementById('modalMenu').addEventListener('click', function(e) {
        if (e.target === this) closeModal();
    });

    // ========================================
    // MODAL KATEGORI — Open / Close / Edit
    // ========================================
    function openKategoriModal() {
        document.getElementById('modalKategoriTitle').innerText = 'Tambah Kategori Baru';
        document.getElementById('formKategori').action = '<?= base_url("admin/kategori/simpan") ?>';
        document.getElementById('inp_nama_kategori').value = '';
        document.getElementById('inp_k_description').value = '';
        document.getElementById('modalKategori').style.display = 'flex';
    }

    function openEditKategoriModal(item) {
        document.getElementById('modalKategoriTitle').innerText = 'Edit Kategori';
        document.getElementById('formKategori').action = '<?= base_url("admin/kategori/update/") ?>' + item.kategori_id;
        document.getElementById('inp_nama_kategori').value = item.nama_kategori;
        document.getElementById('inp_k_description').value = item.k_description || '';
        document.getElementById('modalKategori').style.display = 'flex';
    }

    function closeKategoriModal() {
        document.getElementById('modalKategori').style.display = 'none';
    }

    function confirmHapusKategori(id) {
        showAppConfirm({
            title: 'Hapus Kategori',
            message: 'Kategori akan dihapus. Menu yang terhubung dapat kehilangan kategori.',
            type: 'danger',
            confirmText: 'Hapus Kategori',
            onConfirm: function () { window.location.href = '<?= base_url("admin/kategori/hapus/") ?>' + id; }
        });
    }

    document.getElementById('modalKategori').addEventListener('click', function(e) {
        if (e.target === this) closeKategoriModal();
    });

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

    // ========================================
    // VALIDASI FORM MENU
    // ========================================
    function validateMenuForm() {
        const nama = document.getElementById('inp_nama').value.trim();
        const kategori = document.getElementById('inp_kategori').value;
        const harga = document.getElementById('inp_harga').value.trim();
        const stok = document.getElementById('inp_stok').value.trim();
        const deskripsi = document.getElementById('inp_deskripsi').value.trim();
        const gambar = document.getElementById('inp_gambar');
        const isEdit = document.getElementById('isEditMode').value === '1';

        // Cek field kosong
        if (!nama) return notifyInvalid('inp_nama', 'Nama item wajib diisi.');
        if (!kategori) return notifyInvalid('inp_kategori', 'Kategori wajib dipilih.');
        if (!harga) return notifyInvalid('inp_harga', 'Harga wajib diisi.');
        if (Number(harga) < 0) return notifyInvalid('inp_harga', 'Harga tidak boleh bernilai negatif.');
        if (stok === '') return notifyInvalid('inp_stok', 'Stok wajib diisi.');
        if (!Number.isInteger(Number(stok)) || Number(stok) < 0) return notifyInvalid('inp_stok', 'Stok harus berupa bilangan bulat dan tidak boleh negatif.');
        if (!deskripsi) return notifyInvalid('inp_deskripsi', 'Deskripsi menu wajib diisi.');

        // Gambar wajib saat tambah baru, opsional saat edit
        if (!isEdit && (!gambar.files || gambar.files.length === 0)) {
            return notifyInvalid('inp_gambar', 'Gambar menu wajib dipilih saat menambah menu baru.');
        }

        // Validasi panjang karakter
        if (nama.length < 5) return notifyInvalid('inp_nama', 'Nama item minimal 5 karakter.');
        if (deskripsi.length < 15) return notifyInvalid('inp_deskripsi', 'Deskripsi menu minimal 15 karakter.');

        showAppToast(isEdit ? 'Menyimpan perubahan menu...' : 'Menyimpan menu baru...', 'info', 'Diproses', 1800);
        return true;
    }

    // ========================================
    // VALIDASI FORM KATEGORI
    // ========================================
    function validateKategoriForm() {
        const nama = document.getElementById('inp_nama_kategori').value.trim();
        const deskripsi = document.getElementById('inp_k_description').value.trim();

        // Cek field kosong
        if (!nama) return notifyInvalid('inp_nama_kategori', 'Nama kategori wajib diisi.');
        if (!deskripsi) return notifyInvalid('inp_k_description', 'Deskripsi kategori wajib diisi.');

        // Validasi panjang karakter
        if (nama.length < 5) return notifyInvalid('inp_nama_kategori', 'Nama kategori minimal 5 karakter.');
        if (deskripsi.length < 15) return notifyInvalid('inp_k_description', 'Deskripsi kategori minimal 15 karakter.');

        showAppToast('Menyimpan kategori...', 'info', 'Diproses', 1800);
        return true;
    }
</script>
<?= $this->endSection() ?>
