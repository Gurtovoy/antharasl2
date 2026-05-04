//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class L2CenterdDiamond extends Actor
	placeable
	native;
	

var		float	HeightRate;
var		float	RadiusRate;
var		texture DiaTexture[4];
var		float	DiaSpeed[4];
var		float	DiaWeight[4];
var		Matrix	LocalToWorldMatrix;

	
defaultproperties
{
    HeightRate=1.00
    RadiusRate=1.00
    bNetTemporary=True
    bCheckChangableLevel=True
    RemoteRole=0
    bGameRelevant=True
}
