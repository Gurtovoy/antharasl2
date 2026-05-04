class ShortcutAPI extends UIEventManager
	native;

native static function SetShortcutPage( int a_ShortcutPage );

native static function bool AssignSpecialKey( ShortcutCommandItem command );
native static function bool AssignCommand( string groupName, ShortcutCommandItem command );
native static function GetGroupCommandList( string groupName, out array<ShortcutCommandItem> commands );
native static function GetGroupList( out array<string> groups );
native static function GetActiveGroupList( out array<string> groups );
native static function GetAssignedKeyFromCommand(string groupName, string command, out ShortcutCommandItem commandItem);

native static function LockShortcut();
native static function UnlockShortcut();

native static function Save();
native static function RequestList();

native static function bool RequestShortcutScriptData(int id, out ShortcutScriptData data);
native static function ExecuteShortcutBySlot(int slot);
native static function ActivateGroup( string groupName );
native static function DeactivateGroup( string groupName );
native static function DeactivateAll();
native static function RestoreDefault();
native static function Clear();
defaultproperties
{
}
