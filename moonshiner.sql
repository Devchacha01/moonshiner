-- RSG-Moonshiner Database Table
CREATE TABLE IF NOT EXISTS `moonshiner` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `object` varchar(255) NOT NULL DEFAULT '',
  `xpos` float NOT NULL,
  `ypos` float NOT NULL,
  `zpos` float NOT NULL,
  `actif` int(11) DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
