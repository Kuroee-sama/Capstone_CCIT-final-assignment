-- ============================================================
-- FIX RELASI DETAIL_TRANSAKSI.menu_id -> MENU.menu_id
-- Database: transaksi
--
-- Jalankan file ini SATU KALI di phpMyAdmin setelah memilih database `transaksi`.
-- Script ini aman untuk dijalankan ulang karena index dan constraint dicek dulu.
-- ============================================================

USE `transaksi`;

-- 1. Cek data detail_transaksi yang menu_id-nya tidak ada di tabel menu.
SELECT dt.*
FROM detail_transaksi dt
LEFT JOIN menu m ON m.menu_id = dt.menu_id
WHERE dt.menu_id IS NOT NULL
  AND m.menu_id IS NULL;

-- 2. Bersihkan data yatim supaya foreign key bisa dibuat.
-- Riwayat transaksi tetap aman karena menu_id dibuat NULL, bukan baris detail dihapus.
UPDATE detail_transaksi dt
LEFT JOIN menu m ON m.menu_id = dt.menu_id
SET dt.menu_id = NULL
WHERE dt.menu_id IS NOT NULL
  AND m.menu_id IS NULL;

-- 3. Tambahkan index menu_id jika belum ada.
SET @idx_exists := (
  SELECT COUNT(1)
  FROM information_schema.STATISTICS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'detail_transaksi'
    AND INDEX_NAME = 'idx_detail_transaksi_menu_id'
);

SET @sql := IF(
  @idx_exists = 0,
  'ALTER TABLE detail_transaksi ADD INDEX idx_detail_transaksi_menu_id (menu_id)',
  'SELECT ''Index idx_detail_transaksi_menu_id sudah ada'' AS info'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 4. Tambahkan foreign key jika belum ada.
SET @fk_exists := (
  SELECT COUNT(1)
  FROM information_schema.KEY_COLUMN_USAGE
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'detail_transaksi'
    AND COLUMN_NAME = 'menu_id'
    AND REFERENCED_TABLE_NAME = 'menu'
    AND REFERENCED_COLUMN_NAME = 'menu_id'
);

SET @sql := IF(
  @fk_exists = 0,
  'ALTER TABLE detail_transaksi ADD CONSTRAINT fk_detail_transaksi_menu FOREIGN KEY (menu_id) REFERENCES menu(menu_id) ON DELETE SET NULL ON UPDATE CASCADE',
  'SELECT ''Foreign key detail_transaksi.menu_id ke menu.menu_id sudah ada'' AS info'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 5. Verifikasi hasil.
SELECT
  CONSTRAINT_NAME,
  TABLE_NAME,
  COLUMN_NAME,
  REFERENCED_TABLE_NAME,
  REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'detail_transaksi'
  AND COLUMN_NAME = 'menu_id'
  AND REFERENCED_TABLE_NAME = 'menu';
