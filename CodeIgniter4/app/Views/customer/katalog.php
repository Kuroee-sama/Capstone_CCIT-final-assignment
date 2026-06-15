<?= $this->extend('layouts/main') ?>

<?= $this->section('content') ?>
<style>
    .wrapper { display: block; min-height: 80vh; }
    .content { max-width: 1200px; margin: 0 auto; padding: 20px 0; }
    .header-section { text-align: center; margin-bottom: 40px; }
    .header-section h1 { font-size: 32px; font-weight: 700; color: #1e1e2d; margin-bottom: 10px; }
    .header-section p { color: #7e8299; font-size: 15px; }

    .top-bar { 
        display: flex; justify-content: space-between; align-items: center; 
        margin-bottom: 40px; gap: 15px; background: white; padding: 15px 25px; 
        border-radius: 15px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); flex-wrap: wrap;
    }
    .search-input { 
        flex-grow: 1; padding: 12px 20px; border-radius: 10px; border: 1px solid #eee; 
        outline: none; background: #f8f9fa; font-family: 'Inter', sans-serif; font-size: 14px;
        transition: border-color 0.3s; min-width: 200px;
    }
    .search-input:focus { border-color: #e67e22; }
    .filter-group { display: flex; gap: 8px; flex-wrap: wrap; }
    .btn-filter { 
        padding: 10px 25px; border-radius: 20px; border: 1px solid #eee; 
        background: white; cursor: pointer; font-weight: 600; transition: 0.3s; 
        font-family: 'Inter', sans-serif; font-size: 13px;
    }
    .btn-filter.active { background: #e67e22; color: white; border-color: #e67e22; }
    .btn-filter:hover { border-color: #e67e22; }

    .menu-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 30px; }
    .menu-card { 
        background: white; border-radius: 20px; overflow: hidden; 
        box-shadow: 0 4px 15px rgba(0,0,0,0.05); display: flex; 
        flex-direction: column; transition: transform 0.3s ease;
    }
    .menu-card:hover { transform: translateY(-5px); }
    .menu-card.hidden-card { display: none; }
    
    .card-img-real { width: 100%; height: 220px; object-fit: cover; }
    .card-img-placeholder { 
        width: 100%; height: 220px; object-fit: cover; 
        background: linear-gradient(135deg, #fff3e0, #ffecd2); 
        display: flex; align-items: center; justify-content: center; 
        font-size: 60px;
    }
    .card-body { padding: 25px; flex-grow: 1; display: flex; flex-direction: column; }
    .card-badge { 
        background: #fff4e5; color: #e67e22; font-size: 11px; padding: 4px 12px; 
        border-radius: 8px; width: fit-content; margin-bottom: 12px; 
        text-transform: uppercase; font-weight: 700; 
    }
    .card-title { font-size: 20px; font-weight: 700; color: #181c32; margin-bottom: 10px; }
    .card-desc { font-size: 14px; color: #7e8299; margin-bottom: 20px; flex-grow: 1; line-height: 1.6; }
    .card-price { font-size: 20px; font-weight: 800; color: #e67e22; }

    @media (max-width: 992px) { .menu-grid { grid-template-columns: repeat(2, 1fr); } }
    @media (max-width: 600px) { 
        .menu-grid { grid-template-columns: 1fr; } 
        .top-bar { flex-direction: column; align-items: stretch; }
        .header-section h1 { font-size: 24px; }
    }
</style>

<div class="wrapper">
    <main class="content">
        <div class="header-section">
            <h1>Katalog Menu</h1>
            <p>Selamat datang di Cafe'in aja — Jelajahi menu kami</p>
        </div>

        <div class="top-bar">
            <input type="text" id="searchInput" class="search-input" placeholder="Cari menu favoritmu...">
            <div class="filter-group">
                <button class="btn-filter active" onclick="filterMenu('semua', this)">Semua</button>
                <?php if (!empty($kategori)): ?>
                    <?php foreach ($kategori as $k): ?>
                        <button class="btn-filter" onclick="filterMenu('<?= strtolower($k['nama_kategori']) ?>', this)"><?= $k['nama_kategori'] ?></button>
                    <?php endforeach; ?>
                <?php endif; ?>
            </div>
        </div>

        <div class="menu-grid" id="menuGrid">
            <?php foreach ($menu as $m): ?>
                <div class="menu-card" data-category="<?= strtolower($m['nama_kategori'] ?? '') ?>" data-nama="<?= strtolower($m['nama_item']) ?>">
                    <?php if (!empty($m['gambar'])): ?>
                        <img src="<?= base_url('uploads/menu/' . $m['gambar']) ?>" class="card-img-real" alt="<?= $m['nama_item'] ?>">
                    <?php else: ?>
                        <div class="card-img-placeholder">🍴</div>
                    <?php endif; ?>
                    <div class="card-body">
                        <span class="card-badge"><?= $m['nama_kategori'] ?? 'Lainnya' ?></span>
                        <h3 class="card-title"><?= $m['nama_item'] ?></h3>
                        <p class="card-desc"><?= $m['m_description'] ?? 'Menu lezat dari café kami.' ?></p>
                        <div class="card-price">Rp <?= number_format($m['harga'], 0, ',', '.') ?></div>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>
    </main>
</div>

<script>
    function filterMenu(category, btn) {
        document.querySelectorAll('.btn-filter').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');

        document.querySelectorAll('.menu-card').forEach(card => {
            if (category === 'semua' || card.dataset.category === category) {
                card.classList.remove('hidden-card');
            } else {
                card.classList.add('hidden-card');
            }
        });
    }

    document.getElementById('searchInput').addEventListener('input', function() {
        const val = this.value.toLowerCase().trim();
        document.querySelectorAll('.menu-card').forEach(card => {
            const nama = card.getAttribute('data-nama');
            card.classList.toggle('hidden-card', !nama.includes(val));
        });
        document.querySelectorAll('.btn-filter').forEach(b => b.classList.remove('active'));
        document.querySelector('.btn-filter').classList.add('active');
    });
</script>
<?= $this->endSection() ?>