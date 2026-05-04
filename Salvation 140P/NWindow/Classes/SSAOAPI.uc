class SSAOAPI extends Object
	native;

native static function SSAO_Level( int Level );
native static function SSAO_Blend( int Mode );
native static function SSAO_Strength( float value );
native static function SSAO_MaxIntensity( float value );
native static function SSAO_FadeFront( float value );
native static function SSAO_DepthDifference( float value );
native static function SSAO_NoiseScale( float value );
native static function SSAO_SampleDistance( float value );
native static function SSAO_BlurIntensity( float value );
native static function SSAO_BlurDepthDifference( float value );
native static function SSAO_BlurNormalDifference( float value );
defaultproperties
{
}
