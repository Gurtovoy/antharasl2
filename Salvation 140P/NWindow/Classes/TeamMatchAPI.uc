class TeamMatchAPI extends UIEventManager
	native;

//Cleft
native static function RequestCleftAllData();
native static function RequestExCleftEnter( int a_TeamID );

//Block Game
native static function RequestBlockGameAllData();
native static function RequestExBlockGameEnter( int a_Stage, int a_TeamID );
native static function RequestExBlockGameVote( int a_Stage, int a_Start );
defaultproperties
{
}
