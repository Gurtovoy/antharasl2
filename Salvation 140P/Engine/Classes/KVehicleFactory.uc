//=============================================================================
// KVehicle spawner location.
//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
#exec Texture Import File=Textures\S_KVehFact.pcx Name=S_KVehFact Mips=Off MASKED=1
class KVehicleFactory extends Actor 
	placeable;

var()	class<KVehicle>		VehicleClass;
var()	int					MaxVehicleCount;

var		int					VehicleCount;

event Trigger( Actor Other, Pawn EventInstigator )
{
	local KVehicle CreatedVehicle;

	if(VehicleCount >= MaxVehicleCount)
		return;

	if(VehicleClass != None)
	{
		CreatedVehicle = spawn(VehicleClass, , , Location, Rotation);
		VehicleCount++;
		CreatedVehicle.ParentFactory = self;
	}
}

defaultproperties
{
     RemoteRole=ROLE_None
     bHidden=True
     bNoDelete=True
     Texture=Texture'Engine.S_KVehFact'
     bDirectional=True
}
