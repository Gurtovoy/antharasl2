//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class UserDefinableMaterial extends Material
	native
	noexport;

//#ifdef SEPERATE_MESHDATA
var() Texture BackGroundTexture;
var() Texture OnlyTestTexture;
var	transient Combiner OnlyTestFinalCombiner;	

//#endif

defaultproperties
{
}
