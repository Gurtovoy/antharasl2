//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class PawnSheathingMgr extends Object
	dynamicrecompile
			native;

const WEAPONTYPE_CNT=14;

var name 	RightAttachBoneName[WEAPONTYPE_CNT];
var rotator	RightAttachRotation[WEAPONTYPE_CNT];
var vector	RightAttachOffset[WEAPONTYPE_CNT];
var vector	RightOffsetForMantle[WEAPONTYPE_CNT];
var int		RightHideSheathing[WEAPONTYPE_CNT];		

var name 	LeftAttachBoneName[WEAPONTYPE_CNT];
var rotator	LeftAttachRotation[WEAPONTYPE_CNT];
var vector	LeftAttachOffset[WEAPONTYPE_CNT];
var vector	LeftOffsetForMantle[WEAPONTYPE_CNT];
var int		LeftHideSheathing[WEAPONTYPE_CNT];		

defaultproperties
{
}
