class UIDATA_USER extends UIDataManager
	native;

native static function string GetUserName(int ServerID);
native static function bool GetClanType( int ID, out int type );

// #4606 성장구간 그룹화 - UI API / Event 작업 - y2jinc
//   int ID - UserID
//	 out int nPrologue - 프롤로그 성장 타입인지 0 or 1
//   @return : 해당 유저 정보가 없다면 false or true(리턴값 확인필요)
native static function bool GetPrologueGrowType(int ID, out int nPrologue);

// #4606 성장구간 그룹화 - UI API / Event 작업 - y2jinc
//   int nClassID - UserInfo의 nClassID
//   @return : 프롤로그 성장 타입인지 true or false 리턴
native static function bool IsPrologueGrowType(int nClassID);
defaultproperties
{
}
