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
    .cart-item .cart-right { display: flex; align-items: center; gap: 10px; }
    .cart-item .cart-subtotal { font-weight: bold; color: #2d3436; white-space: nowrap; }
    .btn-remove { background: #ff7675; color: white; border: none; width: 24px; height: 24px; border-radius: 5px; cursor: pointer; font-size: 14px; }

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
                <div class="menu-item-card" 
                     data-nama="<?= strtolower($m['nama_item']) ?>"
                     onclick="tambahKeKeranjang(<?= $m['menu_id'] ?>, '<?= htmlspecialchars($m['nama_item'], ENT_QUOTES) ?>', <?= $m['harga'] ?>)">
                    <span class="item-name"><?= $m['nama_item'] ?></span>
                    <span class="item-badge"><?= $m['nama_kategori'] ?? 'Lainnya' ?></span>
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
    function tambahKeKeranjang(menuId, nama, harga) {
        const key = menuId + '_' + nama;
        if (keranjang[key]) {
            keranjang[key].qty += 1;
        } else {
            keranjang[key] = { menu_id: menuId, nama: nama, harga: harga, qty: 1 };
        }
        updateCart();
    }

    function hapusItem(key) {
        if (keranjang[key].qty > 1) {
            keranjang[key].qty -= 1;
        } else {
            delete keranjang[key];
        }
        updateCart();
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
            
            html += `
                <div class="cart-item">
                    <div>
                        <strong>${item.nama}</strong>
                        <small>Rp ${item.harga.toLocaleString('id-ID')} x ${item.qty}</small>
                    </div>
                    <div class="cart-right">
                        <span class="cart-subtotal">Rp ${subtotal.toLocaleString('id-ID')}</span>
                        <button class="btn-remove" onclick="hapusItem('${key}')">-</button>
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
            return alert("Pilih menu terlebih dahulu!");
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
        fetch('<?= base_url("admin/transaksi/simpan") ?>', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                items: items,
                total_amount: total
            })
        })
        .then(res => res.json())
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
            } else {
                alert('Gagal menyimpan transaksi: ' + (data.message || 'Unknown error'));
            }
        })
        .catch(err => {
            console.error(err);
            alert('Terjadi kesalahan koneksi ke server.');
        });
    }

    function selesaiTransaksi() {
        location.reload();
    }
</script>
<?= $this->endSection() ?>