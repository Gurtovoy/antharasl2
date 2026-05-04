//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class VolumeTimer extends info;

var PhysicsVolume V;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(1.0, true);
	V = PhysicsVolume(Owner);
}

function Timer()
{
	V.TimerPop(self);
}

defaultproperties
{
}
