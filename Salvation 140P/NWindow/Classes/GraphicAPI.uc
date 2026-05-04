class GraphicAPI extends Object
	native;

// Depth of Field
native static function DoFSetFocusActor(actor a_FocusActor);
native static function DoFSetFocusPlayer();
native static function DoFSetFocusLocation(vector a_FocusLocation);
native static function DoFSetFocusDistance(float a_FocusDistance);
native static function DoFSetStartDistance(float a_StartDistance);
native static function DoFSetEndDistance(float a_EndDistance);
native static function DoFPause();
native static function DoFResume();
defaultproperties
{
}
