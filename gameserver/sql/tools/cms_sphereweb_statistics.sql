-- Запросы для Sphere CMS / SphereWeb: статистика кланов и замков.
-- Сборка L2S / этот репозиторий: в clan_data НЕТ колонки hasCastle (удалена в updates 2016_06_29).
-- Владелец замка: таблица castle, поле owner_id = clan_id.
-- Главный сабклан в clan_subpledges: type = 0 (SUBUNIT_MAIN_CLAN), НЕ 100 (это Royal 1).

-- === Клан (Clan) — подставьте в настройки SQL CMS вместо варианта с hasCastle ===
SELECT
	(SELECT c2.`id` FROM `castle` c2 WHERE c2.`owner_id` = `clan_data`.`clan_id` LIMIT 1) AS `castle_id`,
	`clan_data`.`reputation_score` AS `reputation_score`,
	`clan_subpledges`.`leader_id`,
	`characters`.`char_name` AS `player_name`,
	`characters`.`pvpkills` AS `pvp`,
	`characters`.`pkkills` AS `pk`,
	`characters`.`online`,
	`characters`.`onlinetime` AS `time_in_game`,
	`characters`.`sex`,
	`clan_subpledges`.`name` AS `clan_name`,
	`clan_data`.`clan_level`,
	`clan_data`.`crest` AS `clan_crest`,
	`ally_data`.`crest` AS `alliance_crest`,
	(SELECT COUNT(*) FROM `characters` chm WHERE chm.`clanid` = `clan_data`.`clan_id`) AS `clan_count_members`
FROM `clan_data`
INNER JOIN `clan_subpledges` ON `clan_data`.`clan_id` = `clan_subpledges`.`clan_id` AND `clan_subpledges`.`type` = 0
INNER JOIN `characters` ON `clan_subpledges`.`leader_id` = `characters`.`obj_Id`
LEFT JOIN `ally_data` ON `clan_data`.`ally_id` = `ally_data`.`ally_id`
ORDER BY `clan_data`.`reputation_score` DESC, `clan_count_members` DESC
LIMIT 10;

-- === Замок (Castle) — порядок колонок как в SphereWeb2 (Go Scan по позициям):
--   0 castle_id (int), 1 treasury, 2 siege_date (int), 3 last_siege_date (int),
--   4 clan_name (string), 5 clan_level (int), 6 player_name, 7 clan_crest, 8 alliance_crest.
-- Четвёртое поле ОБЯЗАНО быть числом (last_siege_date). Если на его месте cp.name,
-- получите: Scan column index 3 "clan_name": converting NULL to int is unsupported.
SELECT
	c.`id` AS `castle_id`,
	c.`treasury`,
	c.`siege_date` AS `siege_date`,
	COALESCE(c.`last_siege_date`, 0) AS `last_siege_date`,
	IFNULL(cp.`name`, '') AS `clan_name`,
	COALESCE(cd.`clan_level`, 0) AS `clan_level`,
	IFNULL(ch.`char_name`, '') AS `player_name`,
	cd.`crest` AS `clan_crest`,
	ad.`crest` AS `alliance_crest`
FROM `castle` c
LEFT JOIN `clan_data` cd
	ON c.`owner_id` = cd.`clan_id`
	AND cd.`expelled_member` = 0
LEFT JOIN `clan_subpledges` cp
	ON cd.`clan_id` = cp.`clan_id`
	AND cp.`type` = 0
LEFT JOIN `characters` ch
	ON cp.`leader_id` = ch.`obj_Id`
LEFT JOIN `ally_data` ad
	ON cd.`ally_id` = ad.`ally_id`;
