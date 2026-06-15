<?= $this->extend('layouts/main') ?>

<?= $this->section('content') ?>
<style>
    .detail-container { max-width: 800px; margin: 0 auto; }
    .detail-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; flex-wrap: wrap; gap: 10px; }
    .detail-header h2 { margin: 0; color: #2d3436; }
    .detail-header a { text-decoration: none; color: #e67e22; font-weight: 600; }

    .info-card { 
        background: white; padding: 25px; border-radius: 20px; 
        box-shadow: 0 4px 15px rgba(0,0,0,0.04); margin-bottom: 25px; 
    }
    .info-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; }
    .info-item label { display: block; font-size: 12px; color: #636e72; text-transform: uppercase; font-weight: 600; margin-bottom: 4px; }
    .info-item span { font-size: 16px; font-weight: 600; color: #2d3436; }
    .info-item .total-highlight { color: #e67e22; font-size: 20px; }

    .table-wrapper { background: white; border-radius: 20px; box-shadow: 0 4px 15px rgba(0,0,0,0.04); overflow: hidden; }
    .table-scroll { overflow-x: auto; }
    table { width: 100%; border-collapse: collapse; min-width: 450px; }
    thead { background: #f8f9fa; }
    th { padding: 14px 20px; text-align: left; font-size: 13px; color: #636e72; font-weight: 600; text-transform: uppercase; }
    td { padding: 14px 20px; border-top: 1px solid #f1f2f6; font-size: 14px; color: #2d3436; }
    tr:hover td { background: #fafafa; }
    .badge { display: inline-block; padding: 3px 10px; border-radius: 6px; font-size: 11px; font-weight: 700; text-transform: uppercase; }
    .badge-kategori { background: #fff3e0; color: #e67e22; }

    @media (max-width: 600px) {
        .info-card { padding: 18px; }
        th, td { padding: 12px 14px; }
    }
</style>

<div class="detail-container">
    <div class="detail-header">
        <h2>Detail Transaksi #<?= $transaksi['transaksi_id'] ?></h2>
        <a href="<?= base_url('admin/riwayat') ?>">← Kembali ke Riwayat</a>
    </div>

    <div class="info-card">
        <div class="info-grid">
            <div class="info-item">
                <label>Tanggal Transaksi</label>
                <span><?= date('d M Y, H:i', strtotime($transaksi['tgl_transaksi'])) ?></span>
            </div>
            <div class="info-item">
                <label>Kasir</label>
                <span><?= $transaksi['username'] ?? 'N/A' ?></span>
            </div>
            <div class="info-item">
                <label>Total Pembayaran</label>
                <span class="total-highlight">Rp <?= number_format($transaksi['total_amount'], 0, ',', '.') ?></span>
            </div>
        </div>
    </div>

    <h3 style="color: #2d3436; margin-bottom: 15px;">Item yang Dibeli</h3>
    <div class="table-wrapper">
        <div class="table-scroll">
            <table>
                <thead>
                    <tr>
                        <th>No</th>
                        <th>Nama Item</th>
                        <th>Kategori</th>
                        <th>Harga</th>
                        <th>Jumlah</th>
                        <th>Subtotal</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($detail as $i => $d): ?>
                    <tr>
                        <td><?= $i + 1 ?></td>
                        <td><strong><?= $d['nama_item'] ?? 'Item dihapus' ?></strong></td>
                        <td><span class="badge badge-kategori"><?= $d['nama_kategori'] ?? '-' ?></span></td>
                        <td>Rp <?= number_format($d['harga'], 0, ',', '.') ?></td>
                        <td><?= $d['jumlah'] ?></td>
                        <td><strong>Rp <?= number_format($d['total_harga'], 0, ',', '.') ?></strong></td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>
<?= $this->endSection() ?>
