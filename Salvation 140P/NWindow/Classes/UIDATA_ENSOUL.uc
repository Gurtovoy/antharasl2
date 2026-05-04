class UIDATA_ENSOUL extends UIDataManager
	native;

native static function int GetEnsoulSlotCount(ItemID Id, int slotType);
native static function bool GetEnsoulOptionInfo(int optionId, out string optionInfo);
native static function bool GetEnsoulStoneInfo(ItemID Id, out string ensoulStoneInfo);
native static function bool GetEnsoulFeeInfo(int crystalType, bool bIsRefee, int slotType, int slotIndex, out string ensoulFeeInfo);

//branch EP2.5 2016.1.7 luciper3 - 해외 클래식 집혼 - 추출기능 추가
native static function bool GetEnsoulExtractionFeeInfo(int crystalType, int slotType, out string ensoulFeeInfo);
//end of branch
defaultproperties
{
}
