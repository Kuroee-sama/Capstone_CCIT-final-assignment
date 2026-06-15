-- Tambah kolom gambar ke tabel menu
ALTER TABLE `menu` ADD `gambar` VARCHAR(255) DEFAULT NULL AFTER `deskripsi`;
