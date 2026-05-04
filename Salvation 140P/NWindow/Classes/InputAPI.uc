class InputAPI extends UIEventManager
	native;

// Keyboard API
native static function bool IsShiftPressed();
native static function bool IsCtrlPressed();
native static function bool IsAltPressed();
native static function string GetKeyString( EInputKey key );
native static function EInputKey GetInputKey( string keyString );
defaultproperties
{
}
