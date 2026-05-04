//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class NAgathion extends Pawn
	native
	dynamicrecompile;

// - gorillazin 10.06.23.
var enum EAgathionType
{
	EAT_DEFAULT,
	EAT_ATTACHED,
} AgathionType;

var enum EAttachedBone
{
	EAB_NONE,
	EAB_HEADBONE,
	EAB_SPINEBONE,
	EAB_R_HANDBONE,
	EAB_L_HANDBONE,
	EAB_R_ARMBONE,
	EAB_L_ARMBONE,
	EAB_R_FOOTBONE,
	EAB_L_FOOTBONE,
} AttachedBone;

var enum EAgathionMovementType
{
	EAMT_FOLLOW,
	EAMT_FLOAT,
	EAMT_ONVEHICLE,
	EAMT_ATTACH,
} MovementType;

var vector		DestLocation;
var Rotator		OriginalRotationRate;
var int			RandomAnimPercent;
var int			RandomSpecialAnimationState;	// -1 to decide, 0 failed, 1 success
var bool		NeedMaster;						// for 3D UI
var pawn		Master;
var int			MasterWaitType;
var float		MasterWaitTypeChangeUpdate;

defaultproperties
{
    OriginalRotationRate=(Pitch=0,Yaw=30000,Roll=0),
    RandomAnimPercent=20
    NeedMaster=True
    bCollideActors=False
    bCollideWorld=False
}
