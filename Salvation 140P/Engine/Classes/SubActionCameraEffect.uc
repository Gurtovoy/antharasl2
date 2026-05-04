//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class SubActionCameraEffect extends MatSubAction
	native
	noexport
	collapsecategories;

var() editinline CameraEffect	CameraEffect;
var() float						StartAlpha,
								EndAlpha;
var() bool						DisableAfterDuration;

defaultproperties
{
     EndAlpha=1.000000
     Icon=Texture'Engine.SubActionFade'
     Desc="Camera effect"
}
