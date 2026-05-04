class AudioAPI extends Object
	native;

native static function PlaySound( String a_SoundName );
native static function PlayMusic( String a_MusicName, FLOAT a_FadeInTime );	//solasys
native static function StopMusic();	//solasys
defaultproperties
{
}
