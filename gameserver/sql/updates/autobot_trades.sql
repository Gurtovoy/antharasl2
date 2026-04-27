CREATE TABLE IF NOT EXISTS `autobot_trade_zones` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `x1` INT NOT NULL, `y1` INT NOT NULL,
  `x2` INT NOT NULL, `y2` INT NOT NULL,
  `z` INT NOT NULL,
  `max_traders` INT NOT NULL DEFAULT 30,
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `autobot_traders` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `bot_id` INT UNSIGNED NOT NULL,
  `zone_id` INT UNSIGNED NOT NULL,
  `slot_index` INT NOT NULL DEFAULT -1,
  `trade_type` ENUM('sell','buy') NOT NULL DEFAULT 'sell',
  `store_name` VARCHAR(100) DEFAULT 'Trade Bot',
  `items_json` LONGTEXT NOT NULL,
  `is_active` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `bot_zone` (`bot_id`, `zone_id`)
);
