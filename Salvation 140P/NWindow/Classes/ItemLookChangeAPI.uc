class ItemLookChangeAPI extends UIEventManager
	native;
	
//branch 111109
native static function RequestItemLookChange(ItemID a_sTargetID);
native static function RequestExTryToPut_Shape_Shifting_TargetItem( ItemID a_sTargetID );
native static function RequestExTryToPut_Shape_Shifting_EnchantSupportItem( ItemID a_sTargetID, ItemID a_sSupportID );
native static function RequestExCancelItemLookChange();
defaultproperties
{
}
