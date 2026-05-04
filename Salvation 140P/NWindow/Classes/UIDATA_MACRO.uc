class UIDATA_MACRO extends UIDataManager
	native;

native static function bool GetMacroInfo(ItemID cID, out MacroInfo info);
native static function int GetMacroCount();

native static function ItemID GetUseSkillID(string command);
native static function GetMacroCommandList(ItemID cID, out Array<string> Commands);
native static function GetMacroSkillIDList(ItemID cID, out Array<ItemID> SkillIDs);

native static function int GetMacroPresetIDs(out Array<int> IDs);
native static function bool GetMacroPresetInfo(int PresetID, out MacroPresetInfo info);
defaultproperties
{
}
