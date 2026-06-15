-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 23 Des 2025 pada 14.25
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

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
-- Struktur dari tabel `detail_transaksi`
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
-- Dumping data untuk tabel `detail_transaksi`
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
(21, 10, 5, 1, 45000.00, 45000.00);

-- --------------------------------------------------------

--
-- Struktur dari tabel `karyawan`
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
-- Dumping data untuk tabel `karyawan`
--

INSERT INTO `karyawan` (`karyawan_id`, `username`, `email`, `password`, `umur`, `alamat`, `tgl_lahir`, `no_telp`, `role`) VALUES
(1, 'kasir_andi', 'andi@cafe.com', '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzYYKnFz1W0mB6o5mG2', 24, 'Jl. Melati No. 10, Jakarta', '2000-03-15', '082111222333', 'KARYAWAN'),
(2, 'kasir_dewi', 'dewi@cafe.com', '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzYYKnFz1W0mB6o5mG2', 26, 'Jl. Mawar No. 20, Bandung', '1998-07-20', '082111222334', 'KARYAWAN'),
(3, 'manager_rio', 'rio@cafe.com', '$2a$10$dXJ3SW6G7P50lGmMkkmwe.20cQQubK3.HZWzYYKnFz1W0mB6o5mG2', 35, 'Jl. Anggrek No. 30, Jakarta', '1989-11-10', '082111222335', 'ADMIN');

-- --------------------------------------------------------

--
-- Struktur dari tabel `menu`
--

CREATE TABLE `menu` (
  `menu_id` int(11) NOT NULL,
  `nama_item` varchar(100) NOT NULL,
  `kategori` enum('makanan','minuman') NOT NULL,
  `harga` decimal(10,2) NOT NULL,
  `deskripsi` text DEFAULT NULL,
  `stok` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `menu`
--

INSERT INTO `menu` (`menu_id`, `nama_item`, `kategori`, `harga`, `deskripsi`, `stok`) VALUES
(1, 'Espresso', 'minuman', 25000.00, 'Kopi espresso Italia yang kuat dan aromatik', 50),
(2, 'Cappuccino', 'minuman', 35000.00, 'Perpaduan sempurna espresso dengan susu berbusa', 45),
(3, 'Latte', 'minuman', 38000.00, 'Kopi susu dengan foam lembut', 40),
(4, 'Croissant', 'makanan', 28000.00, 'Pastry Prancis yang renyah dan lembut', 30),
(5, 'Sandwich', 'makanan', 45000.00, 'Sandwich dengan isian daging dan sayuran segar', 25),
(6, 'Cake Slice', 'makanan', 32000.00, 'Potongan kue lezat dengan berbagai rasa', 20);

-- --------------------------------------------------------

--
-- Struktur dari tabel `transaksi`
--

CREATE TABLE `transaksi` (
  `transaksi_id` int(11) NOT NULL,
  `karyawan_id` int(11) DEFAULT NULL,
  `tgl_transaksi` timestamp NOT NULL DEFAULT current_timestamp(),
  `total_amount` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `transaksi`
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
(10, 1, '2025-01-19 12:30:00', 95000.00);

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `detail_transaksi`
--
ALTER TABLE `detail_transaksi`
  ADD PRIMARY KEY (`detail_id`),
  ADD KEY `transaksi_id` (`transaksi_id`),
  ADD KEY `menu_id` (`menu_id`);

--
-- Indeks untuk tabel `karyawan`
--
ALTER TABLE `karyawan`
  ADD PRIMARY KEY (`karyawan_id`),
  ADD UNIQUE KEY `uk_karyawan_username` (`username`),
  ADD UNIQUE KEY `uk_karyawan_email` (`email`);

--
-- Indeks untuk tabel `menu`
--
ALTER TABLE `menu`
  ADD PRIMARY KEY (`menu_id`);

--
-- Indeks untuk tabel `transaksi`
--
ALTER TABLE `transaksi`
  ADD PRIMARY KEY (`transaksi_id`),
  ADD KEY `karyawan_id` (`karyawan_id`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `detail_transaksi`
--
ALTER TABLE `detail_transaksi`
  MODIFY `detail_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT untuk tabel `karyawan`
--
ALTER TABLE `karyawan`
  MODIFY `karyawan_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `menu`
--
ALTER TABLE `menu`
  MODIFY `menu_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `transaksi`
--
ALTER TABLE `transaksi`
  MODIFY `transaksi_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `detail_transaksi`
--
ALTER TABLE `detail_transaksi`
  ADD CONSTRAINT `detail_transaksi_ibfk_1` FOREIGN KEY (`transaksi_id`) REFERENCES `transaksi` (`transaksi_id`),
  ADD CONSTRAINT `detail_transaksi_ibfk_2` FOREIGN KEY (`menu_id`) REFERENCES `menu` (`menu_id`);

--
-- Ketidakleluasaan untuk tabel `transaksi`
--
ALTER TABLE `transaksi`
  ADD CONSTRAINT `fk_karyawan_id` FOREIGN KEY (`karyawan_id`) REFERENCES `karyawan` (`karyawan_id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
