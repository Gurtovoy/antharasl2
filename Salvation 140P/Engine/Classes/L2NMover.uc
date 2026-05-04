//=============================================================================
// NMover.
//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class L2NMover extends Actor
	native;

struct NMoverTarget
{
	var int bTarget;
	var int bOwnedTarget;
	var vector Loc;
	var actor Target;
};

var bool bLoop;
var bool bMoveStart;
var bool bMoveEnd;
var bool bMovePause;
var float MoveStartDelay;
var vector OwnerOrigin;
var int TargetIndex;
var array<NMoverTarget> MoverTargets;
var float MoveSpeed;
var float CurMoveSpeed;
var float AccelRate;
var float AccelAccelRate;
var float CurAccelRate;
var float MaxSpeed;
var float MinSpeed;
var float MaxAccelRate;
var float MinAccelRate;
var actor ForceBounceActor;
var float MoveDuration;
var float CurMoveTime;

defaultproperties
{
    MoveSpeed=100.00
    MaxSpeed=2000.00
    MinSpeed=1.00
    MaxAccelRate=1000.00
    MinAccelRate=-1000.00
    DrawType=0
    bHidden=True
    CollisionRadius=1.00
    CollisionHeight=1.00
}
