class UIDATA_AGIT extends UIDataManager
	native;

native static function GetAllDecoNPCInfo(out array<AgitDecoNPCData> AgitDecoNPCDataList, out array<AgitDecoNPCTypeList> NpcTypeList, int Grade, array<int> Domains);
native static function bool GetDecoNPCInfo(int DecoNPCId, out AgitDecoNPCData DecoData);
native static function RequestOpenDecoNPC(int AgitID);
native static function RequestCheckAvailability(int AgitID, int SlotNum, int DecoNPCId);
defaultproperties
{
}
