class UIAPI_INVENWEIGHT extends UIAPI_WINDOW
	native;

native static function AddWeight(string ControlName, INT64 weight);
native static function ReduceWeight(string ControlName, INT64 weight);
native static function ZeroWeight(string ControlName);
defaultproperties
{
}
