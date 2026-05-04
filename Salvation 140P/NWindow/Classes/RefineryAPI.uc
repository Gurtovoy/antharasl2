class RefineryAPI extends UIEventManager
	native;

native static function ConfirmTargetItem( ItemID sID );
native static function ConfirmRefinerItem( ItemID a_TargetItemID, ItemID a_RefinerItemID );
native static function ConfirmGemStone( ItemID a_TargetItemID, ItemID a_RefinerItemID, ItemID a_GemStoneID, INT64 a_GemStoneCount );
native static function RequestRefine( ItemID a_TargetItemID, ItemID a_RefinerItemID, ItemID a_GemStoneID, INT64 a_GemStoneCount );

native static function ConfirmCancelItem( ItemID a_CancelItemID );
native static function RequestRefineCancel( ItemID a_CancelItemID );
defaultproperties
{
}
