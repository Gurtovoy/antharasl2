//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class L2Dice extends Actor
	placeable
	native
	nativereplication;
	
struct NActionPtr
{
	var	int		Ptr;
};

var rotator TargetRotation;
var rotator DeltaRotation;
var sound	DropSound;
var vector	CheckLocation;
var NActionPtr Action;	
var bool bActionOn;

defaultproperties
{
    DrawType=2
    NoCheatCollision=True
    bNeedCleanup=False
    bOrientOnSlope=True
    bAlwaysRelevant=True
    bCheckChangableLevel=True
    NetUpdateFrequency=8.00
    NetPriority=1.40
    Texture=Texture'S_Inventory'
    CollisionRadius=0.10
    CollisionHeight=0.10
    bCollideActors=True
    bProjTarget=True
    bFixedRotationDir=True
}
