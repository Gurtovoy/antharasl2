//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class Sound extends Object
    native
	hidecategories(Object)
    noexport;

var native const byte Data[28]; // sizeof (FSoundData) :(
var native const Name FileType;
var native const String FileName;
var native const int OriginalSize;
var native const float Duration;
var native const int Handle;
var native const int Flags;

var(Sound) native float Likelihood;
var(Sound) float BaseRadius;
var(Sound) float VelocityScale;

defaultproperties
{
     BaseRadius=2000.000000
}
