SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

-- --------------------------------------------------------

--
-- Table structure for table `categorization`
--

DROP TABLE IF EXISTS `categorization`;
CREATE TABLE `categorization` (
  `id` char(32) COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `domain` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `category` varchar(32) COLLATE utf8mb4_unicode_520_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--
-- Table structure for table `stats`
--

DROP TABLE IF EXISTS `stats`;
CREATE TABLE `stats` (
  `action` varchar(32) COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `value` varchar(64) COLLATE utf8mb4_unicode_520_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--
-- Table structure for table `unique_domain`
--

DROP TABLE IF EXISTS `unique_domain`;
CREATE TABLE `unique_domain` (
  `id` int NOT NULL,
  `url` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--
-- Table structure for table `url_origin`
--

DROP TABLE IF EXISTS `url_origin`;
CREATE TABLE `url_origin` (
  `origin` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `target` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `created` datetime NOT NULL,
  `amount` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--
-- Table structure for table `url_to_fetch`
--

DROP TABLE IF EXISTS `url_to_fetch`;
CREATE TABLE `url_to_fetch` (
  `id` char(32) COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `url` text COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `baseurl` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `created` datetime NOT NULL,
  `last_fetched` datetime DEFAULT NULL,
  `fetch_failed` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--
-- Table structure for table `url_to_ignore`
--

DROP TABLE IF EXISTS `url_to_ignore`;
CREATE TABLE `url_to_ignore` (
  `id` int NOT NULL,
  `searchfor` varchar(255) COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `created` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

--
-- Dumping data for table `url_to_ignore`
--

INSERT INTO `url_to_ignore` (`id`, `searchfor`, `created`) VALUES
(1, 'mailto:', '2022-01-05 10:46:10'),
(2, 'javascript:', '2022-01-05 10:46:10'),
(3, 'google.', '2022-01-05 10:46:29'),
(4, 'amazon.', '2022-01-05 10:46:29'),
(5, 'youtube.', '2022-01-05 10:46:47'),
(6, '.onion', '2022-01-05 17:21:45'),
(7, 'instagram.', '2022-01-05 20:15:21'),
(8, 'twitter.', '2022-01-05 20:16:31'),
(9, 'facebook.', '2022-01-05 20:16:31'),
(10, 'skype:', '2022-01-05 21:29:53'),
(11, 'xmpp:', '2022-01-05 21:30:22'),
(12, 'tel:', '2022-01-05 21:30:50'),
(13, 'fax:', '2022-01-05 21:30:50'),
(14, 'whatsapp:', '2022-01-05 21:31:24'),
(15, 'intent:', '2022-01-05 21:31:24'),
(16, 'ftp:', '2022-01-05 21:33:34'),
(17, 'youtu.', '2022-01-05 21:50:26'),
(18, 'pinterest.', '2022-01-05 21:51:31'),
(19, 'microsoft.', '2022-01-05 21:52:30'),
(20, 'apple.', '2022-01-05 21:52:30'),
(21, 'xing.', '2022-01-05 22:03:07'),
(22, 'linked.', '2022-01-05 22:03:07'),
(26, 't.co', '2022-01-05 22:05:07'),
(27, 'tinyurl.', '2022-01-05 22:07:03'),
(28, 'bitly.', '2022-01-05 22:07:03'),
(29, 'bit.ly', '2022-01-05 22:07:23'),
(30, 'wikipedia.', '2022-01-06 09:58:46'),
(31, 'gstatic.', '2022-01-06 09:59:47'),
(32, 'wikimedia.', '2022-01-06 10:00:20'),
(33, 'goo.', '2022-01-06 10:02:11'),
(34, 'cdn.', '2022-01-06 10:02:59'),
(35, 'flickr.', '2022-01-06 10:05:46'),
(36, '.mp3', '2022-01-07 13:11:49'),
(38, 't.me', '2024-08-04 09:51:03'),
(39, 'kleinanzeige', '2024-08-04 10:25:00'),
(40, 'vergleich.', '2024-08-04 10:26:44'),
(41, 'amzn.', '2024-08-04 10:51:19'),
(43, 'media.', '2024-08-04 10:51:34'),
(46, 'linkedin.', '2024-08-04 11:32:16'),
(48, 'amazn.to', '2024-09-07 11:21:29'),
(49, 'threema:', '2024-09-07 15:29:44'),
(50, 'webcal:', '2024-09-07 15:31:02'),
(51, 'fb-messenger:', '2024-09-07 15:47:54'),
(52, 'tell:', '2024-09-07 15:48:44'),
(53, 'sms:', '2024-09-07 15:57:42'),
(54, 'codecheck:', '2024-09-07 15:57:42'),
(55, 'fon:', '2024-09-08 09:53:50'),
(56, 'viber:', '2024-10-28 14:12:54');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `categorization`
--
ALTER TABLE `categorization`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `stats`
--
ALTER TABLE `stats`
  ADD PRIMARY KEY (`action`);

--
-- Indexes for table `unique_domain`
--
ALTER TABLE `unique_domain`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `url` (`url`);

--
-- Indexes for table `url_origin`
--
ALTER TABLE `url_origin`
  ADD UNIQUE KEY `origin` (`origin`,`target`);

--
-- Indexes for table `url_to_fetch`
--
ALTER TABLE `url_to_fetch`
  ADD PRIMARY KEY (`id`),
  ADD KEY `baseurl` (`baseurl`),
  ADD KEY `last_fetched` (`last_fetched`),
  ADD KEY `fetch_failed` (`fetch_failed`);

--
-- Indexes for table `url_to_ignore`
--
ALTER TABLE `url_to_ignore`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `url` (`searchfor`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `unique_domain`
--
ALTER TABLE `unique_domain`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `url_to_ignore`
--
ALTER TABLE `url_to_ignore`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=57;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
