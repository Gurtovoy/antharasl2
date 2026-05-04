class VehicleAPI extends UIEventManager
	native;

native static function vehicle GetVehicle( int a_VehicleID );

//For AirShip
native static function RequestExAirShipTeleport( int a_SpotID );
native static function AirShipMoveUp();
native static function AirShipMoveDown();
defaultproperties
{
}
