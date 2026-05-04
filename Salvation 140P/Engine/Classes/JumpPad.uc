//=============================
// Jumppad - bounces players/bots up
// not directly placeable.  Make a subclass with appropriate sound effect etc.
//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class JumpPad extends NavigationPoint
	native;

var vector JumpVelocity;
var Actor JumpTarget;
var() float JumpZModifier;	// for tweaking Jump, if needed
var() sound JumpSound;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

event Touch(Actor Other)
{
	if ( Pawn(Other) == None )
		return;

	PendingTouch = Other.PendingTouch;
	Other.PendingTouch = self;
}

event PostTouch(Actor Other)
{
	local Pawn P;

	P = Pawn(Other);
	if ( P == None )
		return;

	if ( AIController(P.Controller) != None )
	{
		P.Controller.Movetarget = JumpTarget;
		P.Controller.Focus = JumpTarget;
		P.Controller.MoveTimer = 2.0;
		P.DestinationOffset = JumpTarget.CollisionRadius;
	}
	if ( P.Physics == PHYS_Walking )
		P.SetPhysics(PHYS_Falling);
	P.Velocity =  JumpVelocity;
	P.Acceleration = vect(0,0,0);
	if ( JumpSound != None )
		P.PlaySound(JumpSound);
}

defaultproperties
{
     JumpVelocity=(Z=1200.000000)
     JumpZModifier=1.000000
     bDestinationOnly=True
     bCollideActors=True
}
