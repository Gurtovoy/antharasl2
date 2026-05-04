class ArenaAPI extends Object
	native;

native static function RequestMatchGroup();
native static function RequestMatchGroupAsk( string TargetUserName );
native static function RequestMatchGroupAnswer( bool Result );
native static function RequestMatchGroupWithdraw();
native static function RequestMatchGroupOust( string TargetUserName );
native static function RequestMatchGroupChangeMaster( string TargetUserName );
defaultproperties
{
}
