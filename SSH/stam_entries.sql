CREATE TABLE `stam_entries` (
  `id` int(21) NOT NULL AUTO_INCREMENT,
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cat` varchar(255) NOT NULL,
  `txt` text NOT NULL,
  `state` enum('E','S') NOT NULL DEFAULT 'E',
  `src` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
