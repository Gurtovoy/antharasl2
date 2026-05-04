class HennaAPI extends Object
	native;

native static function int GetHennaInfoCount();
native static function bool GetHennaInfo( int a_Index, out int a_HennaID, out int a_IsActive );
native static function bool GetPremiumHennaInfo( out int a_HennaID, out int a_IsActive ); //branch121212
native static function int GetPremiumHennaPeriod(); //branch121212
defaultproperties
{
}
