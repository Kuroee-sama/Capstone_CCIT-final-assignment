-- ============================================================
-- FINAL UNIFIED DATABASE SCHEMA
-- Database: transaksi
-- Used by: Spring Boot (REST API) + CodeIgniter4 (Web Admin)
-- ============================================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

-- ============================================================
-- DROP EXISTING TABLES (in correct order for FK constraints)
-- ============================================================
DROP TABLE IF EXISTS `detail_transaksi`;
DROP TABLE IF EXISTS `transaksi`;
DROP TABLE IF EXISTS `menu`;
DROP TABLE IF EXISTS `kategori`;
DROP TABLE IF EXISTS `menu_kategori`;
DROP TABLE IF EXISTS `karyawan`;

-- ============================================================
-- TABLE: karyawan
-- ============================================================
CREATE TABLE `karyawan` (
  `karyawan_id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `umur` int(11) DEFAULT NULL,
  `alamat` text DEFAULT NULL,
  `tgl_lahir` date DEFAULT NULL,
  `no_telp` varchar(20) DEFAULT NULL,
  `role` varchar(20) NOT NULL DEFAULT 'KARYAWAN',
  PRIMARY KEY (`karyawan_id`),
  UNIQUE KEY `uk_karyawan_username` (`username`),
  UNIQUE KEY `uk_karyawan_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ============================================================
-- TABLE: kategori
-- ============================================================
CREATE TABLE `kategori` (
  `kategori_id` int(11) NOT NULL AUTO_INCREMENT,
  `nama_kategori` varchar(100) NOT NULL,
  `k_description` text DEFAULT NULL,
  PRIMARY KEY (`kategori_id`),
  UNIQUE KEY `uk_kategori_nama` (`nama_kategori`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ============================================================
-- TABLE: menu
-- With kategori_id FK for simple one-to-many relation
-- ============================================================
CREATE TABLE `menu` (
  `menu_id` int(11) NOT NULL AUTO_INCREMENT,
  `nama_item` varchar(100) NOT NULL,
  `harga` decimal(10,2) NOT NULL,
  `m_description` text DEFAULT NULL,
  `gambar` varchar(255) DEFAULT NULL,
  `stok` int(11) NOT NULL DEFAULT 0,
  `kategori_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`menu_id`),
  KEY `idx_menu_kategori` (`kategori_id`),
  CONSTRAINT `fk_menu_kategori` FOREIGN KEY (`kategori_id`) REFERENCES `kategori` (`kategori_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ============================================================
-- TABLE: transaksi
-- ============================================================
CREATE TABLE `transaksi` (
  `transaksi_id` int(11) NOT NULL AUTO_INCREMENT,
  `karyawan_id` int(11) DEFAULT NULL,
  `tgl_transaksi` timestamp NOT NULL DEFAULT current_timestamp(),
  `total_amount` decimal(10,2) DEFAULT NULL,
  `metode_pembayaran` varchar(20) DEFAULT 'CASH',
  `bayar` decimal(10,2) DEFAULT NULL,
  `kembalian` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`transaksi_id`),
  KEY `karyawan_id` (`karyawan_id`),
  CONSTRAINT `fk_transaksi_karyawan` FOREIGN KEY (`karyawan_id`) REFERENCES `karyawan` (`karyawan_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ============================================================
-- TABLE: detail_transaksi
-- ============================================================
CREATE TABLE `detail_transaksi` (
  `detail_id` int(11) NOT NULL AUTO_INCREMENT,
  `transaksi_id` int(11) DEFAULT NULL,
  `menu_id` int(11) DEFAULT NULL,
  `jumlah` int(11) DEFAULT NULL,
  `harga` decimal(10,2) DEFAULT NULL,
  `total_harga` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`detail_id`),
  KEY `transaksi_id` (`transaksi_id`),
  KEY `menu_id` (`menu_id`),
  CONSTRAINT `fk_detail_transaksi` FOREIGN KEY (`transaksi_id`) REFERENCES `transaksi` (`transaksi_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_detail_menu` FOREIGN KEY (`menu_id`) REFERENCES `menu` (`menu_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ============================================================
-- SEED DATA: karyawan
-- Password for all: password123
-- ============================================================
INSERT INTO `karyawan` (`karyawan_id`, `username`, `email`, `password`, `umur`, `alamat`, `tgl_lahir`, `no_telp`, `role`) VALUES
(1, 'kasir_andi', 'andi@cafe.com', '$2a$12$kFBQzXe8WLcUiVfIgmcBsugmlgnhFCgc3.vVUAK/6Q52L/KdMRu52', 24, 'Jl. Melati No. 10, Jakarta', '2000-03-15', '082111222333', 'KARYAWAN'),
(2, 'kasir_dewi', 'dewi@cafe.com', '$2a$12$kFBQzXe8WLcUiVfIgmcBsugmlgnhFCgc3.vVUAK/6Q52L/KdMRu52', 26, 'Jl. Mawar No. 20, Bandung', '1998-07-20', '082111222334', 'KARYAWAN'),
(3, 'admin_rio', 'rio@cafe.com', '$2a$12$kFBQzXe8WLcUiVfIgmcBsugmlgnhFCgc3.vVUAK/6Q52L/KdMRu52', 35, 'Jl. Anggrek No. 30, Jakarta', '1989-11-10', '082111222335', 'ADMIN');

-- ============================================================
-- SEED DATA: kategori
-- ============================================================
INSERT INTO `kategori` (`kategori_id`, `nama_kategori`, `k_description`) VALUES
(1, 'Kopi', 'Menu minuman berbasis kopi'),
(2, 'Pastry', 'Menu roti dan pastry'),
(3, 'Makanan', 'Menu makanan berat/snack');

-- ============================================================
-- SEED DATA: menu
-- ============================================================
INSERT INTO `menu` (`menu_id`, `nama_item`, `harga`, `m_description`, `gambar`, `stok`, `kategori_id`) VALUES
(1, 'Espresso', 25000.00, 'Kopi espresso Italia yang kuat dan aromatik', NULL, 50, 1),
(2, 'Cappuccino', 35000.00, 'Perpaduan sempurna espresso dengan susu berbusa', NULL, 45, 1),
(3, 'Latte', 38000.00, 'Kopi susu dengan foam lembut', NULL, 40, 1),
(4, 'Croissant', 28000.00, 'Pastry Prancis yang renyah dan lembut', NULL, 30, 2),
(5, 'Sandwich', 45000.00, 'Sandwich dengan isian daging dan sayuran segar', NULL, 25, 3),
(6, 'Cake Slice', 32000.00, 'Potongan kue lezat dengan berbagai rasa', NULL, 20, 2);

-- ============================================================
-- SEED DATA: transaksi
-- ============================================================
INSERT INTO `transaksi` (`transaksi_id`, `karyawan_id`, `tgl_transaksi`, `total_amount`, `metode_pembayaran`) VALUES
(1, 1, '2025-01-10 10:30:00', 88000.00, 'CASH'),
(2, 1, '2025-01-11 14:45:00', 143000.00, 'CASH'),
(3, 2, '2025-01-12 09:15:00', 60000.00, 'CASH'),
(4, 1, '2025-01-13 16:00:00', 108000.00, 'CASH'),
(5, 2, '2025-01-14 11:20:00', 56000.00, 'CASH');

-- ============================================================
-- SEED DATA: detail_transaksi
-- ============================================================
INSERT INTO `detail_transaksi` (`detail_id`, `transaksi_id`, `menu_id`, `jumlah`, `harga`, `total_harga`) VALUES
(1, 1, 1, 2, 25000.00, 50000.00),
(2, 1, 3, 1, 38000.00, 38000.00),
(3, 2, 2, 2, 35000.00, 70000.00),
(4, 2, 5, 1, 45000.00, 45000.00),
(5, 2, 4, 1, 28000.00, 28000.00),
(6, 3, 1, 1, 25000.00, 25000.00),
(7, 3, 2, 1, 35000.00, 35000.00),
(8, 4, 3, 2, 38000.00, 76000.00),
(9, 4, 6, 1, 32000.00, 32000.00),
(10, 5, 4, 2, 28000.00, 56000.00);

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
