//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class L2Indicator extends Emitter
	placeable
	native
	nativereplication;

var int		Type;

defaultproperties
{
    DrawType=2
    NoCheatCollision=True
    bOrientOnSlope=True
    bAlwaysRelevant=True
    bCheckChangableLevel=False
    RemoteRole=1
    NetUpdateFrequency=8.00
    NetPriority=1.40
    CollisionRadius=0.10
    CollisionHeight=0.10
    bCollideActors=True
    bProjTarget=True
    bFixedRotationDir=True
}
