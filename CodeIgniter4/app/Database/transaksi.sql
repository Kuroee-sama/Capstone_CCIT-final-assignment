-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 02, 2026 at 08:39 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `transaksi`
--

-- --------------------------------------------------------

--
-- Table structure for table `detail_transaksi`
--

CREATE TABLE `detail_transaksi` (
  `detail_id` int(11) NOT NULL,
  `transaksi_id` int(11) DEFAULT NULL,
  `menu_id` int(11) DEFAULT NULL,
  `jumlah` int(11) DEFAULT NULL,
  `harga` decimal(10,2) DEFAULT NULL,
  `total_harga` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `detail_transaksi`
--

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
(10, 5, 4, 2, 28000.00, 56000.00),
(11, 6, 2, 2, 35000.00, 70000.00),
(12, 6, 4, 1, 28000.00, 28000.00),
(13, 7, 5, 2, 45000.00, 90000.00),
(14, 7, 3, 2, 38000.00, 76000.00),
(15, 8, 1, 1, 25000.00, 25000.00),
(16, 8, 4, 1, 28000.00, 28000.00),
(17, 9, 2, 1, 35000.00, 35000.00),
(18, 9, 5, 1, 45000.00, 45000.00),
(19, 9, 4, 1, 28000.00, 28000.00),
(20, 10, 1, 2, 25000.00, 50000.00),
(21, 10, 5, 1, 45000.00, 45000.00),
(22, 11, 7, 2, 9999.00, 19998.00),
(23, 12, 1, 1, 20000.00, 20000.00),
(24, 12, 2, 1, 35000.00, 35000.00),
(25, 12, 3, 1, 38000.00, 38000.00),
(26, 13, 1, 1, 20000.00, 20000.00),
(27, 13, 2, 1, 35000.00, 35000.00),
(28, 14, 1, 1, 20000.00, 20000.00),
(29, 14, 2, 1, 35000.00, 35000.00),
(30, 15, 1, 2, 20000.00, 40000.00),
(31, 15, 5, 2, 45000.00, 90000.00),
(32, 15, 2, 2, 35000.00, 70000.00),
(33, 15, 3, 2, 38000.00, 76000.00),
(34, 15, 4, 2, 28000.00, 56000.00),
(35, 15, 6, 2, 32000.00, 64000.00),
(36, 16, 4, 1, 28000.00, 28000.00);

-- --------------------------------------------------------

--
-- Table structure for table `karyawan`
--

CREATE TABLE `karyawan` (
  `karyawan_id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `umur` int(11) DEFAULT NULL,
  `alamat` text DEFAULT NULL,
  `tgl_lahir` date DEFAULT NULL,
  `no_telp` varchar(20) DEFAULT NULL,
  `role` varchar(20) DEFAULT 'KARYAWAN'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `karyawan`
--

INSERT INTO `karyawan` (`karyawan_id`, `username`, `email`, `password`, `umur`, `alamat`, `tgl_lahir`, `no_telp`, `role`) VALUES
(1, 'kasir_andi', 'andi@cafe.com', '$2a$12$kFBQzXe8WLcUiVfIgmcBsugmlgnhFCgc3.vVUAK/6Q52L/KdMRu52', 24, 'Jl. Melati No. 10, Jakarta', '2000-03-15', '082111222333', 'KARYAWAN'),
(2, 'kasir_dewi', 'dewi@cafe.com', '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzYYKnFz1W0mB6o5mG2', 26, 'Jl. Mawar No. 20, Bandung', '1998-07-20', '082111222334', 'KARYAWAN'),
(3, 'manager_rio', 'rio@cafe.com', '$2a$12$GlpQ8ZMz.j.6S3NrK44PeuLmPWHZ1P8MEqRNJJCzBWGaX1vGzfzkS', 35, 'Jl. Anggrek No. 30, Jakarta', '1989-11-10', '082111222335', 'ADMIN');

-- --------------------------------------------------------

--
-- Table structure for table `menu`
--

CREATE TABLE `menu` (
  `menu_id` int(11) NOT NULL,
  `nama_item` varchar(100) NOT NULL,
  `harga` decimal(10,2) NOT NULL,
  `m_description` text DEFAULT NULL,
  `gambar` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `menu`
--

INSERT INTO `menu` (`menu_id`, `nama_item`, `harga`, `m_description`, `gambar`) VALUES
(1, 'Espresso', 20000.00, 'Kopi espresso Italia yang kuat dan aromatik', '1772350960_ed458c674146755692b1.jpeg'),
(2, 'Cappuccino', 35000.00, 'Perpaduan sempurna espresso dengan susu berbusa', '1772350971_4a47e873c2bfda7d9f38.jpeg'),
(3, 'Latte', 38000.00, 'Kopi susu dengan foam lembut', '1772350981_f07fca931997ccbd28cd.jpeg'),
(4, 'Croissant', 28000.00, 'Pastry Prancis yang renyah dan lembut', '1772349776_502b614628c484e3b01c.jpeg'),
(5, 'Sandwich', 45000.00, 'Sandwich dengan isian daging dan sayuran segar', '1772350992_eb9e59ed50523e2084ba.jpeg'),
(6, 'Cake Slice', 32000.00, 'Potongan kue lezat dengan berbagai rasa', '1772351025_0c47cdf513b1efb0b96d.jpeg');

-- --------------------------------------------------------

--
-- Table structure for table `transaksi`
--

CREATE TABLE `transaksi` (
  `transaksi_id` int(11) NOT NULL,
  `karyawan_id` int(11) DEFAULT NULL,
  `tgl_transaksi` timestamp NOT NULL DEFAULT current_timestamp(),
  `total_amount` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `transaksi`
--

INSERT INTO `transaksi` (`transaksi_id`, `karyawan_id`, `tgl_transaksi`, `total_amount`) VALUES
(1, 1, '2025-01-10 10:30:00', 88000.00),
(2, 1, '2025-01-11 14:45:00', 135000.00),
(3, 2, '2025-01-12 09:15:00', 60000.00),
(4, 1, '2025-01-13 16:00:00', 118000.00),
(5, 2, '2025-01-14 11:20:00', 73000.00),
(6, 1, '2025-01-15 08:30:00', 101000.00),
(7, 2, '2025-01-16 13:00:00', 166000.00),
(8, 1, '2025-01-17 15:45:00', 53000.00),
(9, 2, '2025-01-18 10:00:00', 108000.00),
(10, 1, '2025-01-19 12:30:00', 95000.00),
(11, 3, '2026-03-01 05:39:26', 19998.00),
(12, 3, '2026-03-01 05:51:04', 93000.00),
(13, 3, '2026-03-01 05:53:26', 55000.00),
(14, 3, '2026-03-01 07:27:52', 55000.00),
(15, 3, '2026-03-01 08:05:53', 396000.00),
(16, 3, '2026-03-01 08:07:38', 28000.00);


-- --------------------------------------------------------
-- Table structure for table `kategori`
-- --------------------------------------------------------

CREATE TABLE `kategori` (
  `kategori_id` int(11) NOT NULL,
  `nama_kategori` varchar(100) NOT NULL,
  `k_description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------
-- Table structure for table `menu_kategori`
-- (relasi kategori <-> menu, merujuk ke menu_id)
-- --------------------------------------------------------

CREATE TABLE `menu_kategori` (
  `menu_id` int(11) NOT NULL,
  `kategori_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- --------------------------------------------------------
-- (OPSIONAL) Dumping data contoh kategori
-- --------------------------------------------------------
INSERT INTO `kategori` (`kategori_id`, `nama_kategori`, `k_description`) VALUES
(1, 'Kopi', 'Menu minuman berbasis kopi'),
(2, 'Pastry', 'Menu roti dan pastry'),
(3, 'Makanan', 'Menu makanan berat/snack');

-- (OPSIONAL) Mapping menu ke kategori (sesuaikan dengan data menu kamu)
-- Espresso(1), Cappuccino(2), Latte(3) => Kopi(1)
-- Croissant(4), Cake Slice(6) => Pastry(2)
-- Sandwich(5) => Makanan(3)
INSERT INTO `menu_kategori` (`menu_id`, `kategori_id`) VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 2),
(6, 2),
(5, 3);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `detail_transaksi`
--
ALTER TABLE `detail_transaksi`
  ADD PRIMARY KEY (`detail_id`),
  ADD KEY `transaksi_id` (`transaksi_id`),
  ADD KEY `menu_id` (`menu_id`);

--
-- Indexes for table `karyawan`
--
ALTER TABLE `karyawan`
  ADD PRIMARY KEY (`karyawan_id`),
  ADD UNIQUE KEY `uk_karyawan_username` (`username`),
  ADD UNIQUE KEY `uk_karyawan_email` (`email`);

--
-- Indexes for table `menu`
--
ALTER TABLE `menu`
  ADD PRIMARY KEY (`menu_id`);

--
-- Indexes for table `transaksi`
--
ALTER TABLE `transaksi`
  ADD PRIMARY KEY (`transaksi_id`),
  ADD KEY `karyawan_id` (`karyawan_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `detail_transaksi`
--
ALTER TABLE `detail_transaksi`
  MODIFY `detail_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT for table `karyawan`
--
ALTER TABLE `karyawan`
  MODIFY `karyawan_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `menu`
--
ALTER TABLE `menu`
  MODIFY `menu_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `transaksi`
--
ALTER TABLE `transaksi`
  MODIFY `transaksi_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;


-- --------------------------------------------------------
-- Indexes for added tables
-- --------------------------------------------------------

ALTER TABLE `kategori`
  ADD PRIMARY KEY (`kategori_id`),
  ADD UNIQUE KEY `uk_kategori_nama` (`nama_kategori`);

ALTER TABLE `menu_kategori`
  ADD PRIMARY KEY (`menu_id`, `kategori_id`),
  ADD KEY `idx_menu_kategori_kategori` (`kategori_id`);


-- --------------------------------------------------------
-- AUTO_INCREMENT for added table
-- --------------------------------------------------------

ALTER TABLE `kategori`
  MODIFY `kategori_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;


-- --------------------------------------------------------
-- Foreign key constraints for added table
-- --------------------------------------------------------

ALTER TABLE `menu_kategori`
  ADD CONSTRAINT `fk_menu_kategori_menu`
    FOREIGN KEY (`menu_id`) REFERENCES `menu` (`menu_id`)
    ON UPDATE CASCADE ON DELETE CASCADE,
  ADD CONSTRAINT `fk_menu_kategori_kategori`
    FOREIGN KEY (`kategori_id`) REFERENCES `kategori` (`kategori_id`)
    ON UPDATE CASCADE ON DELETE CASCADE;