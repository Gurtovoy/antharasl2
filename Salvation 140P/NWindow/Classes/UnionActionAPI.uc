class UnionActionAPI extends UIEventManager
	native;

native static function RequestUnionJoin(int unionID);
native static function RequestUnionChange(int unionID);
native static function RequestUnionWithdraw();
native static function RequestUnionRequest(int requestType);
native static function RequestUnionAdjust();
native static function RequestUnionSummon(int npcType);
native static function RequestUnionStart(int npcType);
defaultproperties
{
}
