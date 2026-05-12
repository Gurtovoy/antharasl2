-- Adds the column that backs Player.hideCostume(). The "costume" feature reuses the FORMAL_WEAR
-- body slot but stores the item in a virtual paperdoll slot (PAPERDOLL_COSTUME=38) so the player
-- keeps their real armor + stats; this flag controls whether the costume visual is currently shown.
ALTER TABLE `characters`
	ADD COLUMN `hide_costume` TINYINT UNSIGNED NOT NULL DEFAULT '0' AFTER `hide_head_accessories`;
