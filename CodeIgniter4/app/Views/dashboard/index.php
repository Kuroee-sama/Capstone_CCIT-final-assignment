<?= $this->extend('layouts/main') ?>

<?= $this->section('content') ?>
<style>
    /* Layout Utama - Dibuat terpusat tanpa sidebar */
    .wrapper { 
        display: block; 
        min-height: 100vh; 
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
        background: #f5f7fa;
    }

    /* Area Konten - Lebar maksimal 1200px agar proporsional di tengah */
    .content { 
        max-width: 1200px; 
        margin: 0 auto; 
        padding: 40px 20px; 
    }

    .header-section { text-align: center; margin-bottom: 40px; }
    .header-section h1 { font-size: 32px; font-weight: 700; color: #1e1e2d; margin-bottom: 10px; }

    /* Search & Filter Bar */
    .top-bar { 
        display: flex; 
        justify-content: space-between; 
        align-items: center; 
        margin-bottom: 40px; 
        gap: 20px;
        background: white;
        padding: 15px 25px;
        border-radius: 15px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.05);
    }
    
    .search-input { flex-grow: 1; padding: 12px 20px; border-radius: 10px; border: 1px solid #eee; outline: none; background: #f8f9fa; }
    .btn-filter { padding: 10px 25px; border-radius: 20px; border: 1px solid #eee; background: white; cursor: pointer; font-weight: 600; transition: 0.3s; }
    .btn-filter.active { background: #e67e22; color: white; border-color: #e67e22; }

    /* Grid Menu - Menampilkan 3 kolom sesuai desain */
    .menu-grid { 
        display: grid; 
        grid-template-columns: repeat(3, 1fr); 
        gap: 30px; 
    }

    .menu-card { 
        background: white; 
        border-radius: 20px; 
        overflow: hidden; 
        box-shadow: 0 4px 15px rgba(0,0,0,0.05); 
        display: flex; 
        flex-direction: column;
        transition: transform 0.3s ease;
    }
    
    .menu-card:hover { transform: translateY(-5px); }
    .card-img { width: 100%; height: 200px; object-fit: cover; }
    .card-body { padding: 25px; flex-grow: 1; display: flex; flex-direction: column; }
    .card-badge { background: #fff4e5; color: #e67e22; font-size: 11px; padding: 4px 12px; border-radius: 8px; width: fit-content; margin-bottom: 12px; text-transform: uppercase; font-weight: 700; }
    .card-title { font-size: 20px; font-weight: 700; color: #181c32; margin-bottom: 10px; }
    .card-desc { font-size: 14px; color: #7e8299; margin-bottom: 20px; flex-grow: 1; line-height: 1.6; }
    .card-price { font-size: 20px; font-weight: 800; color: #e67e22; }

    /* Responsif untuk layar kecil */
    @media (max-width: 992px) { .menu-grid { grid-template-columns: repeat(2, 1fr); } }
    @media (max-width: 600px) { .menu-grid { grid-template-columns: 1fr; } .top-bar { flex-direction: column; } }
</style>

<div class="wrapper">
    <main class="content">
        <div class="header-section">
            <h1>Katalog Menu</h1>
            <p class="text-muted">Selamat datang di Cafe'in aja</p>
        </div>

        <div class="top-bar">
            <input type="text" id="searchInput" class="search-input" placeholder="Cari menu favoritmu...">
            <div class="filter-group">
                <button class="btn-filter active" onclick="filterMenu('semua', this)">Semua</button>
                <button class="btn-filter" onclick="filterMenu('minuman', this)">Minuman</button>
                <button class="btn-filter" onclick="filterMenu('makanan', this)">Makanan</button>
            </div>
        </div>

        <div class="menu-grid" id="menuGrid">
            <?php
            // Mengambil data simulasi sesuai database yang kamu punya
            $menus = [
                ['nama' => 'Espresso', 'kat' => 'minuman', 'harga' => '25.000', 'desc' => 'Kopi espresso Italia yang kuat dan aromatik.', 'img' => 'https://images.unsplash.com/photo-1510591509098-f4fdc6d0ff04?w=400'],
                ['nama' => 'Cappuccino', 'kat' => 'minuman', 'harga' => '35.000', 'desc' => 'Perpaduan sempurna espresso dengan susu berbusa.', 'img' => 'https://images.unsplash.com/photo-1534778101976-62847782c213?w=400'],
                ['nama' => 'Latte', 'kat' => 'minuman', 'harga' => '38.000', 'desc' => 'Kopi susu dengan foam lembut di atasnya.', 'img' => 'https://images.unsplash.com/photo-1570968915860-54d5c301fa9f?w=400'],
                ['nama' => 'Croissant', 'kat' => 'makanan', 'harga' => '28.000', 'desc' => 'Pastry Prancis yang renyah dan lembut.', 'img' => 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400'],
                ['nama' => 'Sandwich', 'kat' => 'makanan', 'harga' => '45.000', 'desc' => 'Sandwich dengan isian daging dan sayuran segar.', 'img' => 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=400'],
                ['nama' => 'Cake Slice', 'kat' => 'makanan', 'harga' => '32.000', 'desc' => 'Potongan kue lezat dengan berbagai rasa.', 'img' => 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400'],
            ];

            foreach ($menus as $m) : ?>
                <div class="menu-card" data-category="<?= $m['kat'] ?>">
                    <img src="<?= $m['img'] ?>" class="card-img">
                    <div class="card-body">
                        <span class="card-badge"><?= $m['kat'] ?></span>
                        <h3 class="card-title"><?= $m['nama'] ?></h3>
                        <p class="card-desc"><?= $m['desc'] ?></p>
                        <div class="card-price">Rp <?= $m['harga'] ?></div>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>
    </main>
</div>

<script>
    // Logika Filter Kategori
    function filterMenu(category, btn) {
        document.querySelectorAll('.btn-filter').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');

        document.querySelectorAll('.menu-card').forEach(card => {
            if (category === 'semua' || card.dataset.category === category) {
                card.style.display = 'flex';
            } else {
                card.style.display = 'none';
            }
        });
    }

    // Logika Pencarian Menu
    document.getElementById('searchInput').addEventListener('input', function() {
        const val = this.value.toLowerCase();
        document.querySelectorAll('.menu-card').forEach(card => {
            const title = card.querySelector('.card-title').innerText.toLowerCase();
            card.style.display = title.includes(val) ? 'flex' : 'none';
        });
    });
</script>
<?= $this->endSection() ?>