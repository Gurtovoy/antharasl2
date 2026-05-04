class ActionAPI extends Object
	native;

native static function RequestActionList();
native static function RequestPetActionList();
native static function RequestSummonedCommonActionList(int serverID);
native static function RequestSummonedAllSkillActionList();
native static function GetActionNameBySocialIndex(int socialIndex, string retString);
defaultproperties
{
}
