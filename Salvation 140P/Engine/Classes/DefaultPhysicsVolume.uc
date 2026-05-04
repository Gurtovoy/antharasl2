//=============================================================================
// DefaultPhysicsVolume:  the default physics volume for areas of the level with 
// no physics volume specified
//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class DefaultPhysicsVolume extends PhysicsVolume
	native
	notplaceable;

function Destroyed()
{
	log(self$" destroyed!");
	assert(false);
}

defaultproperties
{
     bStatic=False
     bNoDelete=False
}
