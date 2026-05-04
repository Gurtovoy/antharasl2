class EnchantAPI extends UIEventManager
	native;
	
native static function RequestEnchantItem(ItemID a_sTargetID, ItemID a_sSupportID);
native static function RequestEnchantItemAttribute(ItemID sID, INT64 Num);
native static function RequestRemoveAttribute(ItemID sID, int type);

// æ∆¿Ã≈€ ¿Œ√æ∆Æ Ver2, ttmayrin
native static function RequestExTryToPutEnchantTargetItem( ItemID a_sTargetID );
native static function RequestExTryToPutEnchantSupportItem( ItemID a_sTargetID, ItemID a_sSupportID );
native static function RequestExAddEnchantScrollItem( ItemID a_sTargetID, ItemID a_sScrollID );
native static function RequestExRemoveEnchantSupportItem();
native static function RequestExCancelEnchantItem();

// ∫¿¿Œ
native static function RequestLockedItem( int TargetItemID );
native static function RequestLockedItemCancel();
native static function RequestUnlockedItem( int TargetItemID );
native static function RequestUnlockedItemCancel();
defaultproperties
{
}
