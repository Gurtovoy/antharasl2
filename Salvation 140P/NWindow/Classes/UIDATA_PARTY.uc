class UIDATA_PARTY extends UIDataManager
	native;

native static function string GetMemberName(int ID);
native static function string MovePartyMember(int SrcPos, int TarPos);
native static function string GetMemberVirtualName(int iD);
native static function int GetMemberTacticalSign(int iD);
defaultproperties
{
}
