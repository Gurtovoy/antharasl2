-- Costume (FORMAL_WEAR) was stored at paperdoll loc_data 38; server now uses brooch slot 31 only.
UPDATE `items` SET `loc_data` = 31 WHERE `loc` = 'PAPERDOLL' AND `loc_data` = 38;
