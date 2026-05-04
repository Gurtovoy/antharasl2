//=============================================================================
// ActionMoveCamera:
//
// Moves the camera to a specified interpolation point.
//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class ActionMoveCamera extends MatAction
	native;

var(Path) config enum EPathStyle
{
	PATHSTYLE_Linear,
	PATHSTYLE_Bezier,
} PathStyle;

defaultproperties
{
}
