<?= $this->extend('layouts/main') ?>

<?= $this->section('content') ?>
<style>
    .trans-container { font-family: 'Inter', sans-serif; }
    .trans-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; flex-wrap: wrap; gap: 10px; }
    .trans-header h2 { margin: 0; color: #2d3436; }
    .trans-header p { margin: 5px 0 0; color: #636e72; }
    .trans-header a { text-decoration: none; color: #e67e22; font-weight: 600; }

    .trans-grid { display: grid; grid-template-columns: 1.5fr 1fr; gap: 30px; }

    .panel { background: #fff; padding: 25px; border-radius: 20px; box-shadow: 0 4px 12px rgba(0,0,0,0.03); }
    .panel-header { margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px; }
    .panel-header h3 { margin: 0; color: #2d3436; }

    #cariMenu { 
        padding: 10px 15px; border-radius: 10px; border: 1px solid #dfe6e9; 
        width: 250px; max-width: 100%; outline: none; font-family: 'Inter', sans-serif;
        transition: border-color 0.3s;
    }
    #cariMenu:focus { border-color: #e67e22; }

    .menu-items-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 15px; }
    .menu-item-card { 
        background: #fdfdfd; padding: 18px; border-radius: 15px; 
        border: 1px solid #f1f2f6; transition: 0.3s; cursor: pointer; 
    }
    .menu-item-card:hover { border-color: #e67e22; transform: translateY(-2px); }
    .menu-item-card .item-name { display: block; font-size: 15px; font-weight: 600; color: #2d3436; }
    .menu-item-card .item-badge { 
        display: inline-block; margin-top: 5px; background: #fff3e0; color: #e67e22; 
        padding: 2px 8px; border-radius: 5px; font-size: 11px; font-weight: bold; text-transform: uppercase; 
    }
    .menu-item-card .stock-line { margin-top: 10px; font-size: 12px; color: #636e72; display: flex; align-items: center; justify-content: space-between; gap: 8px; }
    .stock-badge { display: inline-flex; align-items: center; justify-content: center; min-width: 54px; padding: 4px 8px; border-radius: 999px; font-size: 11px; font-weight: 800; }
    .stock-safe { background: #eafaf1; color: #1e8449; }
    .stock-low { background: #fff4de; color: #b7791f; }
    .stock-out { background: #ffe8e8; color: #c0392b; }
    .menu-item-card .item-footer { margin-top: 15px; display: flex; justify-content: space-between; align-items: center; }
    .menu-item-card .item-price { font-weight: 700; color: #2d3436; }
    .menu-item-card .item-add { 
        background: #2d3436; color: white; width: 28px; height: 28px; 
        border-radius: 8px; display: flex; align-items: center; justify-content: center; 
        font-size: 18px; border: none; cursor: pointer;
    }
    .menu-item-card.hidden-card { display: none; }

    .checkout-panel { height: fit-content; position: sticky; top: 90px; }
    .checkout-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; border-bottom: 1px solid #f1f2f6; padding-bottom: 15px; }
    .btn-clear { background: none; border: none; color: #ff7675; cursor: pointer; font-size: 13px; font-weight: 600; font-family: 'Inter', sans-serif; }

    #isi-keranjang { min-height: 150px; max-height: 400px; overflow-y: auto; margin-bottom: 20px; }
    .cart-empty { text-align: center; color: #b2bec3; padding: 40px 0; }

    .cart-item { 
        display: flex; justify-content: space-between; align-items: center; 
        margin-bottom: 12px; background: #fff; padding: 10px; border-radius: 10px; border: 1px solid #f1f2f6; 
    }
    .cart-item strong { font-size: 14px; display: block; }
    .cart-item small { color: #636e72; }
    .cart-item .cart-main { min-width: 0; flex: 1; }
    .cart-item .cart-right { display: flex; flex-direction: column; align-items: flex-end; gap: 8px; }
    .cart-item .cart-subtotal { font-weight: bold; color: #2d3436; white-space: nowrap; }
    .qty-control { display: flex; align-items: center; gap: 6px; margin-top: 9px; flex-wrap: wrap; }
    .qty-btn { width: 28px; height: 28px; border: none; border-radius: 8px; background: #2d3436; color: #fff; font-weight: 800; cursor: pointer; line-height: 1; }
    .qty-btn:hover { filter: brightness(1.08); }
    .qty-input { width: 58px; height: 28px; border: 1px solid #dfe6e9; border-radius: 8px; text-align: center; font-weight: 700; color: #2d3436; outline: none; font-family: 'Inter', sans-serif; }
    .qty-input:focus { border-color: #e67e22; box-shadow: 0 0 0 3px rgba(230,126,34,0.12); }
    .qty-max { height: 28px; border: none; border-radius: 8px; padding: 0 10px; background: #fff3e0; color: #d35400; font-size: 11px; font-weight: 800; cursor: pointer; font-family: 'Inter', sans-serif; }
    .btn-remove { background: #ff7675; color: white; border: none; width: 24px; height: 24px; border-radius: 5px; cursor: pointer; font-size: 14px; }
    .btn-remove-item { background: #fff0f0; color: #d63031; border: none; min-width: 28px; height: 28px; border-radius: 8px; cursor: pointer; font-size: 16px; font-weight: 800; }

    .totals { background: #f8f9fa; padding: 20px; border-radius: 15px; }
    .total-row { display: flex; justify-content: space-between; margin-bottom: 10px; color: #636e72; }
    .total-final { display: flex; justify-content: space-between; margin-bottom: 20px; font-weight: bold; font-size: 22px; color: #2d3436; border-top: 2px dashed #dfe6e9; padding-top: 15px; }
    .btn-proses { 
        width: 100%; background: linear-gradient(135deg, #e67e22, #d35400); color: white; 
        border: none; padding: 18px; border-radius: 12px; font-weight: bold; font-size: 16px; 
        cursor: pointer; transition: 0.3s; font-family: 'Inter', sans-serif;
    }
    .btn-proses:hover { transform: translateY(-2px); box-shadow: 0 8px 25px rgba(230,126,34,0.3); }

    /* Modal Struk */
    .modal-overlay { 
        display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; 
        background: rgba(0,0,0,0.7); align-items: center; justify-content: center; 
        z-index: 9999; backdrop-filter: blur(5px); padding: 20px;
    }
    .modal-content { 
        background: white; width: 100%; max-width: 380px; padding: 30px; 
        border-radius: 20px; text-align: center; max-height: 90vh; overflow-y: auto;
    }
    .modal-content.modal-alert-box { max-width: 430px; text-align: left; }
    .alert-icon {
        width: 54px; height: 54px; border-radius: 16px; display: flex; align-items: center; justify-content: center;
        background: #fff4de; color: #d35400; font-size: 26px; margin-bottom: 18px;
    }
    .alert-title { margin: 0 0 8px; color: #2d3436; font-size: 20px; }
    .alert-message { margin: 0 0 18px; color: #636e72; line-height: 1.55; font-size: 14px; }
    .alert-detail-box { background: #fff8ed; border: 1px solid #ffe3b8; color: #8a4b00; border-radius: 12px; padding: 12px 14px; margin-bottom: 18px; font-size: 13px; line-height: 1.45; display: none; }
    .btn-alert-ok {
        width: 100%; border: none; padding: 14px 16px; border-radius: 12px; background: #2d3436; color: #fff;
        font-weight: 700; font-family: 'Inter', sans-serif; cursor: pointer;
    }
    .success-icon { 
        background: #2ecc71; color: white; width: 60px; height: 60px; border-radius: 50%; 
        display: flex; align-items: center; justify-content: center; margin: 0 auto 20px; font-size: 30px; 
    }
    .struk-area { 
        text-align: left; margin: 25px 0; font-family: 'Courier New', monospace; font-size: 13px; 
        background: #fafafa; padding: 20px; border: 1px solid #eee; border-radius: 8px;
    }
    .struk-header { text-align: center; margin-bottom: 15px; border-bottom: 1px dashed #ccc; padding-bottom: 10px; }
    .struk-total-row { 
        border-top: 1px dashed #ccc; margin-top: 10px; padding-top: 10px; 
        font-weight: bold; display: flex; justify-content: space-between; font-size: 16px; 
    }
    .btn-selesai { 
        width: 100%; background: #2d3436; color: white; border: none; padding: 15px; 
        border-radius: 12px; cursor: pointer; font-weight: bold; font-family: 'Inter', sans-serif;
    }

    @media (max-width: 900px) {
        .trans-grid { grid-template-columns: 1fr; }
        .checkout-panel { position: static; }
    }
    @media (max-width: 600px) {
        .menu-items-grid { grid-template-columns: repeat(auto-fill, minmax(140px, 1fr)); }
        #cariMenu { width: 100%; }
        .total-final { font-size: 18px; }
    }
</style>

<div class="trans-container">
    <div class="trans-header">
        <div>
            <h2>Panel Transaksi</h2>
            <p>Kelola pesanan pelanggan secara langsung</p>
        </div>
        <a href="<?= base_url('admin/dashboard') ?>">← Kembali ke Dashboard</a>
    </div>

    <div class="trans-grid">
        <div class="panel">
            <div class="panel-header">
                <h3>Daftar Menu Café</h3>
                <input type="text" id="cariMenu" placeholder="Cari makanan/minuman...">
            </div>
            <div class="menu-items-grid">
                <?php foreach($menu as $m): ?>
                <?php
                    $stokMenu = (int) ($m['stok'] ?? 0);
                    $stockClass = $stokMenu <= 0 ? 'stock-out' : ($stokMenu <= 10 ? 'stock-low' : 'stock-safe');
                ?>
                <div class="menu-item-card" 
                     data-nama="<?= strtolower($m['nama_item']) ?>"
                     data-stok="<?= $stokMenu ?>"
                     onclick="tambahKeKeranjang(<?= $m['menu_id'] ?>, '<?= htmlspecialchars($m['nama_item'], ENT_QUOTES) ?>', <?= $m['harga'] ?>, <?= $stokMenu ?>)">
                    <span class="item-name"><?= $m['nama_item'] ?></span>
                    <span class="item-badge"><?= $m['nama_kategori'] ?? 'Lainnya' ?></span>
                    <div class="stock-line">
                        <span>Stok tersedia</span>
                        <span class="stock-badge <?= $stockClass ?>"><?= $stokMenu ?></span>
                    </div>
                    <div class="item-footer">
                        <span class="item-price">Rp <?= number_format($m['harga'], 0, ',', '.') ?></span>
                        <button class="item-add" type="button">+</button>
                    </div>
                </div>
                <?php endforeach; ?>
            </div>
        </div>

        <div class="panel checkout-panel">
            <div class="checkout-header">
                <h3>Checkout</h3>
                <button class="btn-clear" onclick="kosongkanKeranjang()">🗑️ Bersihkan</button>
            </div>

            <div id="isi-keranjang">
                <p class="cart-empty">Belum ada item dipilih</p>
            </div>

            <div class="totals">
                <div class="total-row">
                    <span>Total Barang</span>
                    <span id="qty-total" style="font-weight: 600;">0</span>
                </div>
                <div class="total-final">
                    <span>TOTAL</span>
                    <span id="total-harga" style="color: #e67e22;">Rp 0</span>
                </div>
                <button class="btn-proses" onclick="prosesPembayaran()">PROSES PEMBAYARAN</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal Struk -->
<div id="modal-struk" class="modal-overlay">
    <div class="modal-content">
        <div class="success-icon">✓</div>
        <h3 style="margin: 0; color: #2d3436;">Transaksi Sukses</h3>
        
        <div class="struk-area">
            <div class="struk-header">
                <strong style="font-size: 18px;">CAFE'IN AJA</strong><br>
                <small><?= date('d/m/Y H:i') ?></small>
            </div>
            <div id="struk-items"></div>
            <div class="struk-total-row">
                <span>TOTAL</span>
                <span id="struk-total"></span>
            </div>
        </div>
        
        <button class="btn-selesai" onclick="selesaiTransaksi()">SELESAI & REFRESH</button>
    </div>
</div>

<!-- Modal Peringatan / Error Transaksi -->
<div id="modal-alert" class="modal-overlay">
    <div class="modal-content modal-alert-box">
        <div id="alertIcon" class="alert-icon">!</div>
        <h3 id="alertTitle" class="alert-title">Peringatan</h3>
        <p id="alertMessage" class="alert-message">Terjadi kesalahan.</p>
        <div id="alertDetail" class="alert-detail-box"></div>
        <button type="button" class="btn-alert-ok" onclick="closeAppAlert()">Mengerti</button>
    </div>
</div>

<script>
    let keranjang = {};

    // ==========================================
    // SEARCH MENU — Fitur pencarian yang berfungsi
    // ==========================================
    document.getElementById('cariMenu').addEventListener('input', function() {
        const val = this.value.toLowerCase().trim();
        document.querySelectorAll('.menu-item-card').forEach(card => {
            const nama = card.getAttribute('data-nama');
            if (nama.includes(val)) {
                card.classList.remove('hidden-card');
            } else {
                card.classList.add('hidden-card');
            }
        });
    });

    // ==========================================
    // KERANJANG — Tambah, hapus, update
    // ==========================================
    function tambahKeKeranjang(menuId, nama, harga, stok) {
        stok = Number(stok) || 0;
        const key = menuId + '_' + nama;
        const qtySekarang = keranjang[key] ? keranjang[key].qty : 0;

        if (qtySekarang >= stok) {
            showStockLimitAlert({ nama, stok, qtySekarang, requestedQty: qtySekarang + 1 });
            return;
        }

        if (keranjang[key]) {
            keranjang[key].qty += 1;
        } else {
            keranjang[key] = { menu_id: menuId, nama: nama, harga: harga, stok: stok, qty: 1 };
        }
        updateCart();
    }

    function tambahQtyCheckout(key) {
        const item = keranjang[key];
        if (!item) return;

        if (item.qty >= item.stok) {
            showStockLimitAlert({
                nama: item.nama,
                stok: item.stok,
                qtySekarang: item.qty,
                requestedQty: item.qty + 1
            });
            return;
        }

        item.qty += 1;
        updateCart();
    }

    function kurangiQtyCheckout(key) {
        const item = keranjang[key];
        if (!item) return;

        if (item.qty > 1) {
            item.qty -= 1;
        } else {
            delete keranjang[key];
        }
        updateCart();
    }

    function ubahQtyCheckout(key, value) {
        const item = keranjang[key];
        if (!item) return;

        let requestedQty = parseInt(value, 10);
        if (Number.isNaN(requestedQty)) {
            updateCart();
            return;
        }

        if (requestedQty <= 0) {
            delete keranjang[key];
            updateCart();
            return;
        }

        if (requestedQty > item.stok) {
            showStockLimitAlert({
                nama: item.nama,
                stok: item.stok,
                qtySekarang: item.qty,
                requestedQty: requestedQty
            });
            item.qty = item.stok;
            updateCart();
            return;
        }

        item.qty = requestedQty;
        updateCart();
    }

    function setQtyMaxCheckout(key) {
        const item = keranjang[key];
        if (!item) return;
        item.qty = item.stok;
        updateCart();
    }

    function hapusItem(key) {
        kurangiQtyCheckout(key);
    }

    function hapusSemuaItem(key) {
        if (!keranjang[key]) return;
        delete keranjang[key];
        updateCart();
    }

    function showStockLimitAlert({ nama, stok, qtySekarang, requestedQty }) {
        showAppAlert({
            title: 'Stok Tidak Cukup',
            message: `Pesanan ${nama} tidak dapat ditambahkan karena jumlah melebihi stok yang tersedia.`,
            detail: `Stok tersedia: ${stok}<br>Jumlah di keranjang: ${qtySekarang}<br>Jumlah diminta: ${requestedQty}`
        });
    }

    function updateCart() {
        const list = document.getElementById('isi-keranjang');
        const totalHarga = document.getElementById('total-harga');
        const totalQty = document.getElementById('qty-total');
        
        let html = '';
        let total = 0;
        let qty = 0;

        Object.keys(keranjang).forEach(key => {
            let item = keranjang[key];
            let subtotal = item.harga * item.qty;
            total += subtotal;
            qty += item.qty;
            const safeKey = key.replace(/\\/g, '\\\\').replace(/'/g, "\\'");
            
            html += `
                <div class="cart-item">
                    <div class="cart-main">
                        <strong>${item.nama}</strong>
                        <small>Rp ${item.harga.toLocaleString('id-ID')} · stok ${item.stok}</small>
                        <div class="qty-control">
                            <button class="qty-btn" type="button" onclick="kurangiQtyCheckout('${safeKey}')">−</button>
                            <input class="qty-input" type="number" min="1" max="${item.stok}" value="${item.qty}" onchange="ubahQtyCheckout('${safeKey}', this.value)">
                            <button class="qty-btn" type="button" onclick="tambahQtyCheckout('${safeKey}')">+</button>
                            <button class="qty-max" type="button" onclick="setQtyMaxCheckout('${safeKey}')">MAX</button>
                        </div>
                    </div>
                    <div class="cart-right">
                        <span class="cart-subtotal">Rp ${subtotal.toLocaleString('id-ID')}</span>
                        <button class="btn-remove-item" type="button" onclick="hapusSemuaItem('${safeKey}')" title="Hapus item">×</button>
                    </div>
                </div>
            `;
        });

        list.innerHTML = html || '<p class="cart-empty">Belum ada item dipilih</p>';
        totalHarga.innerText = 'Rp ' + total.toLocaleString('id-ID');
        totalQty.innerText = qty;
    }

    function kosongkanKeranjang() {
        keranjang = {};
        updateCart();
    }

    // ==========================================
    // PROSES PEMBAYARAN — Simpan ke database
    // ==========================================
    function prosesPembayaran() {
        if (Object.keys(keranjang).length === 0) {
            showAppAlert({ title: 'Keranjang Masih Kosong', message: 'Pilih minimal satu menu sebelum memproses pembayaran.' });
            return;
        }

        // Siapkan data items untuk dikirim ke server
        let items = [];
        let total = 0;

        Object.keys(keranjang).forEach(key => {
            let item = keranjang[key];
            let subtotal = item.harga * item.qty;
            total += subtotal;
            items.push({
                menu_id: item.menu_id,
                nama: item.nama,
                harga: item.harga,
                qty: item.qty
            });
        });

        // Kirim ke server via fetch
        const prosesButton = document.querySelector('.btn-proses');
        prosesButton.disabled = true;
        prosesButton.innerText = 'MEMPROSES...';

        fetch('<?= base_url("admin/transaksi/simpan") ?>', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                items: items,
                total_amount: total
            })
        })
        .then(async res => {
            const data = await res.json().catch(() => ({ status: 'error', message: 'Respons server tidak valid.' }));
            if (!res.ok && data.status !== 'success') {
                return data;
            }
            return data;
        })
        .then(data => {
            if (data.status === 'success') {
                // Tampilkan struk
                let htmlStruk = '';
                Object.keys(keranjang).forEach(key => {
                    let item = keranjang[key];
                    let sub = item.harga * item.qty;
                    htmlStruk += `<div style="display:flex; justify-content:space-between; margin-bottom:5px;">
                                    <span>${item.nama} (x${item.qty})</span>
                                    <span>Rp ${sub.toLocaleString('id-ID')}</span>
                                  </div>`;
                });

                document.getElementById('struk-items').innerHTML = htmlStruk;
                document.getElementById('struk-total').innerText = 'Rp ' + total.toLocaleString('id-ID');
                document.getElementById('modal-struk').style.display = 'flex';
                prosesButton.disabled = false;
                prosesButton.innerText = 'PROSES PEMBAYARAN';
            } else {
                showAppAlert({
                    title: data.code === 'INSUFFICIENT_STOCK' ? 'Stok Tidak Cukup' : 'Transaksi Gagal',
                    message: data.message || 'Transaksi tidak dapat disimpan.',
                    detail: data.code === 'INSUFFICIENT_STOCK'
                        ? `Menu: ${data.menu_name || '-'}<br>Stok tersedia: ${data.available_stock ?? '-'}<br>Jumlah diminta: ${data.requested_qty ?? '-'}`
                        : ''
                });
                prosesButton.disabled = false;
                prosesButton.innerText = 'PROSES PEMBAYARAN';
            }
        })
        .catch(err => {
            console.error(err);
            showAppAlert({ title: 'Koneksi Bermasalah', message: 'Terjadi kesalahan koneksi ke server. Pastikan CodeIgniter dan database masih berjalan.' });
            prosesButton.disabled = false;
            prosesButton.innerText = 'PROSES PEMBAYARAN';
        });
    }

    function showAppAlert({ title = 'Peringatan', message = 'Terjadi kesalahan.', detail = '' } = {}) {
        document.getElementById('alertTitle').innerText = title;
        document.getElementById('alertMessage').innerHTML = message;

        const detailBox = document.getElementById('alertDetail');
        if (detail) {
            detailBox.innerHTML = detail;
            detailBox.style.display = 'block';
        } else {
            detailBox.innerHTML = '';
            detailBox.style.display = 'none';
        }

        document.getElementById('modal-alert').style.display = 'flex';
    }

    function closeAppAlert() {
        document.getElementById('modal-alert').style.display = 'none';
    }

    document.getElementById('modal-alert').addEventListener('click', function(e) {
        if (e.target === this) closeAppAlert();
    });

    function selesaiTransaksi() {
        location.reload();
    }
</script>
<?= $this->endSection() ?>