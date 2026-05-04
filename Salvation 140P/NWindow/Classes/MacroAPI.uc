class MacroAPI extends UIEventManager
	native;

native static function RequestMacroList();
native static function RequestUseMacro(ItemID cID);
native static function RequestDeleteMacro(ItemID cID);
native static function bool RequestMakeMacro(ItemID cID, string Name, string IconName, int IconNum, int IconSkillID, string Description, array<string> CommandList);

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
defaultproperties
{
}
