<?= $this->extend('layouts/main') ?>

<?= $this->section('content') ?>
<style>
    .riwayat-container { max-width: 1100px; margin: 0 auto; }
    .riwayat-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; flex-wrap: wrap; gap: 10px; }
    .riwayat-header h2 { margin: 0; color: #2d3436; }
    .riwayat-header a { text-decoration: none; color: #e67e22; font-weight: 600; }

    .alert-box { padding: 14px 20px; border-radius: 12px; margin-bottom: 20px; font-size: 14px; font-weight: 500; }
    .alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
    .alert-error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }

    .table-wrapper { background: white; border-radius: 20px; box-shadow: 0 4px 15px rgba(0,0,0,0.04); overflow: hidden; }
    .table-scroll { overflow-x: auto; }
    table { width: 100%; border-collapse: collapse; min-width: 550px; }
    thead { background: #f8f9fa; }
    th { padding: 16px 20px; text-align: left; font-size: 13px; color: #636e72; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; }
    td { padding: 16px 20px; border-top: 1px solid #f1f2f6; font-size: 14px; color: #2d3436; }
    tr:hover td { background: #fafafa; }

    .btn-action { 
        padding: 8px 14px; border-radius: 8px; border: none; 
        font-size: 12px; font-weight: 600; cursor: pointer; 
        font-family: 'Inter', sans-serif; transition: 0.2s; margin-right: 5px;
        text-decoration: none; display: inline-block;
    }
    .btn-detail { background: #e3f2fd; color: #2196f3; }
    .btn-detail:hover { background: #2196f3; color: white; }
    .btn-hapus { background: #fff5f5; color: #e74c3c; }
    .btn-hapus:hover { background: #e74c3c; color: white; }

    .empty-state { text-align: center; padding: 60px 20px; color: #b2bec3; }
    .empty-state i { font-size: 48px; margin-bottom: 15px; display: block; }

    @media (max-width: 600px) {
        th, td { padding: 12px 14px; font-size: 13px; }
    }
</style>

<div class="riwayat-container">
    <div class="riwayat-header">
        <div>
            <h2>Riwayat Transaksi</h2>
            <p style="margin: 5px 0 0; color: #636e72;">Daftar semua transaksi yang telah dilakukan</p>
        </div>
        <a href="<?= base_url('admin/dashboard') ?>">← Kembali ke Dashboard</a>
    </div>

    <?php if (session()->getFlashdata('success')): ?>
        <div class="alert-box alert-success"><?= session()->getFlashdata('success') ?></div>
    <?php endif; ?>
    <?php if (session()->getFlashdata('error')): ?>
        <div class="alert-box alert-error"><?= session()->getFlashdata('error') ?></div>
    <?php endif; ?>

    <div class="table-wrapper">
        <?php if (!empty($transaksi)): ?>
        <div class="table-scroll">
            <table>
                <thead>
                    <tr>
                        <th>No</th>
                        <th>ID Transaksi</th>
                        <th>Tanggal</th>
                        <th>Kasir</th>
                        <th>Total</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($transaksi as $i => $t): ?>
                    <tr>
                        <td><?= $i + 1 ?></td>
                        <td><strong>#<?= $t['transaksi_id'] ?></strong></td>
                        <td><?= date('d M Y H:i', strtotime($t['tgl_transaksi'])) ?></td>
                        <td><?= $t['username'] ?? 'N/A' ?></td>
                        <td><strong>Rp <?= number_format($t['total_amount'], 0, ',', '.') ?></strong></td>
                        <td>
                            <a href="<?= base_url('admin/riwayat/detail/' . $t['transaksi_id']) ?>" class="btn-action btn-detail"><i class="fas fa-eye"></i> Detail</a>
                            <?php if (isset($role) && $role === 'admin'): ?>
                                <button class="btn-action btn-hapus" onclick="confirmHapus(<?= $t['transaksi_id'] ?>)"><i class="fas fa-trash"></i> Hapus</button>
                            <?php endif; ?>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
        <?php else: ?>
            <div class="empty-state">
                <i class="fas fa-receipt"></i>
                <p>Belum ada riwayat transaksi.</p>
            </div>
        <?php endif; ?>
    </div>
</div>

<script>
    function confirmHapus(id) {
        if (confirm('Yakin ingin menghapus transaksi #' + id + '? Data detail transaksi juga akan dihapus.')) {
            window.location.href = '<?= base_url("admin/riwayat/hapus/") ?>' + id;
        }
    }
</script>
<?= $this->endSection() ?>
