-- phpMyAdmin SQL Dump
-- version 4.6.5.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Feb 08, 2026 at 07:54 AM
-- Server version: 10.1.21-MariaDB
-- PHP Version: 7.1.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `gudang_fk`
--

-- --------------------------------------------------------

--
-- Table structure for table `atk_keluar`
--

CREATE TABLE `atk_keluar` (
  `id` int(11) NOT NULL,
  `nama` varchar(255) DEFAULT NULL,
  `nama_barang` varchar(255) DEFAULT NULL,
  `jumlah` varchar(255) DEFAULT NULL,
  `foto` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `atk_keluar`
--

INSERT INTO `atk_keluar` (`id`, `nama`, `nama_barang`, `jumlah`, `foto`) VALUES
(1, 'fajar', 'bolpen', '5', '1763458051_barang_keluar_1.png'),
(2, 'fajar', 'pensil', '2', '1763488174_ChatGPT_Image_20_Okt_2025_08.41.24.png');

-- --------------------------------------------------------

--
-- Table structure for table `barang_masuk`
--

CREATE TABLE `barang_masuk` (
  `id` int(11) NOT NULL,
  `no_bmn` varchar(100) NOT NULL,
  `tanggal_barang_datang` date NOT NULL,
  `spesifikasi` varchar(255) DEFAULT NULL,
  `nama_barang` varchar(150) NOT NULL,
  `jumlah` int(255) DEFAULT NULL,
  `nama_ruangan` varchar(150) DEFAULT NULL,
  `lantai` int(11) DEFAULT NULL,
  `no_barcode` varchar(100) DEFAULT NULL,
  `foto_barang` varchar(255) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `B` int(11) DEFAULT '0',
  `RB` int(11) DEFAULT '0',
  `RR` int(11) DEFAULT '0',
  `kategori` varchar(255) DEFAULT NULL,
  `satuan` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;

--
-- Dumping data for table `barang_masuk`
--

INSERT INTO `barang_masuk` (`id`, `no_bmn`, `tanggal_barang_datang`, `spesifikasi`, `nama_barang`, `jumlah`, `nama_ruangan`, `lantai`, `no_barcode`, `foto_barang`, `updated_at`, `created_at`, `B`, `RB`, `RR`, `kategori`, `satuan`) VALUES
(1, '1212323', '2021-12-09', 'Lenovo', 'Laptop', 5, 'Lab. komputer ', 4, '9876543234', '1760946273_1458873483_4690761998_1756132487685.png', '2025-11-24 06:56:47', '2025-10-20 08:30:06', 5, 0, 0, 'gudang', 'buah'),
(4, '0192737372', '2025-10-23', 'Infinix ', 'Handphone ', 10, 'Ruang kelas', 3, '372265282939', '1761204500_scaled_a07ff3d6-01a1-4623-9a4d-5555cd7639054851752913310072993.jpg', '2025-12-02 08:35:46', '2025-10-23 07:28:20', 10, 0, 1, 'gudang', 'buah'),
(6, '123456', '2025-11-04', 'axioo', 'komputer', 1, 'TU', 1, '123456', '1762225409_scaled_f9b402cc-3e12-4715-a642-2bff9a337dad3242941571235699958.jpg', '2025-11-24 06:56:47', '2025-11-04 03:03:29', 0, 0, 0, 'gudang', 'buah'),
(8, '234567898', '2025-11-06', 'Aqua', 'Galon Air', 24, 'semua ruangan', 2, '2345676543', '1762411699_aqua_galon.png', '2025-11-24 06:56:47', '2025-11-06 06:48:19', 24, 0, 0, 'gudang', 'buah'),
(16, '5473', '2025-11-20', 'meme', 'kuda', 10, NULL, NULL, '5688', '1763626419_scaled_1746682871914-01.jpg', '2025-12-29 02:17:28', '2025-11-20 08:13:39', 9, 0, 1, 'ATK', 'buah'),
(17, '12345678', '2025-10-13', 'sharf', 'tv', 1, 'anatomi', 7, '12345678', '1763628686_scaled_dcc5830c-ee5e-45c6-9b0f-4715136257ee6643415260462360916.jpg', '2025-11-24 06:57:22', '2025-11-20 08:51:26', 0, 0, 0, 'gudang', 'buah'),
(18, '019', '2025-11-20', 'Lenovo', 'Charger', 1, 'TU', 1, '12345678', '1763632109_scaled_e6bbb10a-5668-4650-a7d5-24e1d95b114f5929946630831399392.jpg', '2025-11-24 06:57:22', '2025-11-20 09:48:29', 0, 0, 0, 'gudang', 'buah'),
(29, '876567890', '2025-12-01', 'LG', 'TV', 10, 'semua kelas', 2, '6789098765', '1764557987_Gemini_Generated_Image_t2s0nrt2s0nrt2s0.png', '2025-12-01 02:59:47', '2025-12-01 02:59:47', 10, 0, 0, 'gudang', 'buah'),
(31, '89876543', '2025-11-02', 'LG', 'TV', 5, 'kelas', 5, '876543', '1764656749_Gemini_Generated_Image_yixwptyixwptyixw.png', '2025-12-02 06:25:49', '2025-12-02 06:25:49', 5, 0, 0, 'gudang', 'buah');

-- --------------------------------------------------------

--
-- Table structure for table `pemesanan`
--

CREATE TABLE `pemesanan` (
  `id` int(11) NOT NULL,
  `nama_pemesan` varchar(100) NOT NULL,
  `tanggal_pemesanan` date NOT NULL,
  `jumlah` int(11) NOT NULL,
  `nama_barang` varchar(100) NOT NULL,
  `nama_ruangan` varchar(100) NOT NULL,
  `harga` int(100) NOT NULL,
  `link_pembelian` varchar(255) DEFAULT NULL,
  `foto` varchar(255) DEFAULT NULL,
  `satuan` varchar(255) DEFAULT NULL,
  `spesifikasi` varchar(255) DEFAULT NULL,
  `kategori` varchar(255) DEFAULT NULL,
  `pemesanan_berakhir` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pemesanan`
--

INSERT INTO `pemesanan` (`id`, `nama_pemesan`, `tanggal_pemesanan`, `jumlah`, `nama_barang`, `nama_ruangan`, `harga`, `link_pembelian`, `foto`, `satuan`, `spesifikasi`, `kategori`, `pemesanan_berakhir`) VALUES
(1, 'fajar', '2025-10-31', 12, 'Hp Samsung', 'Lab Teknologi', 25000000, 'https://www.samsung.com/id/smartphones/all-smartphones/', '1761881630_nailong_under.png', '1 lusin', 'Hp Samsung S24 Ultra', 'gudang', NULL),
(2, 'Andhika', '2025-11-25', 24, 'Galon Air', 'Semua Ruangan di Lantai 1', 30000, 'https://www.sehataqua.co.id/product/aqua-galon/', 'pemesanan_2_rumah.png', '2 lusin', 'Galon Air Aqua', 'gudang', NULL),
(3, 'andhika', '2025-11-26', 10, 'pensil', '', 12000, 'https://www.joyko.co.id/', '1764129309_scaled_dcc3daa9-f1ee-4876-b646-b8346d06f4d26688181286059361343.jpg', 'buah', 'pensil joyko', 'ATK', '2026-11-26');

-- --------------------------------------------------------

--
-- Table structure for table `pemesanan_status`
--

CREATE TABLE `pemesanan_status` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `is_open` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pemesanan_status`
--

INSERT INTO `pemesanan_status` (`id`, `is_open`) VALUES
(1, 0),
(2, 0);

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `id` int(11) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `role` varchar(255) DEFAULT 'user'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`id`, `nama`, `password`, `email`, `role`) VALUES
(1, 'admin', '$2b$12$Viua8ebL45jhDROrcTqIM.othDBcXmZ.8wskglM2JHSwMp9hnpc8y', 'admin_fk@gmail.com', 'admin'),
(2, 'users', '$2b$12$3VQqD8OAAlfUrKHCRViVyef.9/84MwNNE4yUAn94BSLkf4GQxHfmy', 'users@gmail.com', 'user');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `atk_keluar`
--
ALTER TABLE `atk_keluar`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `barang_masuk`
--
ALTER TABLE `barang_masuk`
  ADD PRIMARY KEY (`id`),
  ADD KEY `nama_barang` (`nama_barang`),
  ADD KEY `kategori` (`kategori`);

--
-- Indexes for table `pemesanan`
--
ALTER TABLE `pemesanan`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `pemesanan_status`
--
ALTER TABLE `pemesanan_status`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `atk_keluar`
--
ALTER TABLE `atk_keluar`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT for table `barang_masuk`
--
ALTER TABLE `barang_masuk`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;
--
-- AUTO_INCREMENT for table `pemesanan`
--
ALTER TABLE `pemesanan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `pemesanan_status`
--
ALTER TABLE `pemesanan_status`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
