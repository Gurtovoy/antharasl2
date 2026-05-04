class UIDATA_RECIPE extends UIDataManager
	native;

native static function ItemID GetRecipeItemID(int id);
native static function string GetRecipeIconName(int id);
native static function int GetRecipeProductID(int id);
native static function int GetRecipeProductNum(int id);
native static function int GetRecipeCrystalType(int id);
native static function int GetRecipeMpConsume(int id);
native static function int GetRecipeLevel(int id);
native static function string GetRecipeDescription(int id);
native static function int GetRecipeSuccessRate(int id);
native static function int GetRecipeIsMultipleProduct(int id); //제조옵션, ttmayrin
native static function string GetRecipeMaterialItem(int id);

//branch EP1.0 2014.11.24 luciper3 <http://wallis-devsub/redmine/issues/1217>
// #define RECIPE_OFFERING_ENABLE
native static function bool IsOfferingItem(ItemID Id, optional bool IsShop);
//end of branch

/*
native static function string GetRecipeNameBy2Condition(int id, int nSuccessRate);
native static function string GetRecipeIconNameBy2Condition(int id, int nSuccessRate);
native static function string GetRecipeDescriptionBy2Condition(int id, int nSuccessRate);
native static function string GetRecipeMaterialItemBy2Condition(int id, int nSuccessRate);
*/
defaultproperties
{
}
