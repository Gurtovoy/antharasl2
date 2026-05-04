//=============================================================================
// Scout used for path generation.
//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class Scout extends Pawn
	native
	notplaceable;

var const float MaxLandingVelocity;

function PreBeginPlay()
{
	Destroy(); //scouts shouldn't exist during play
}

defaultproperties
{
     AccelRate=1.000000
     CollisionRadius=52.000000
     bCollideActors=False
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=False
     bPathColliding=True
}
