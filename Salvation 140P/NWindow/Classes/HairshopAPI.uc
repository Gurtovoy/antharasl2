class HairshopAPI extends UIEventManager
	native;

native static function UpdateCharHairInfo();
native static function ApplyCharHairInfo(bool bUseNewHair, int type, bool bUseHairColor, int nColorR, int nColorG, int nColorB);
native static function ApplyHairType(int type);
defaultproperties
{
}
