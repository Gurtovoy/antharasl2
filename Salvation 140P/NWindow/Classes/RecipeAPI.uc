class RecipeAPI extends UIEventManager
	native;

native static function RequestRecipeShopMakeInfo( int nServerID, int nRecipeID );
native static function RequestRecipeShopSellList( int nServerID );

//branch EP1.0 2014.11.24 luciper3 <http://wallis-devsub/redmine/issues/1217>
// #define RECIPE_OFFERING_ENABLE
native static function RequestRecipeShopMakeDo(int MerchantID, int RecipeID, INT64 Adena, optional int OfferingCount, optional array<OfferingItemList> OfferItemList);
//native static function RequestRecipeShopMakeDo( int MerchantID, int RecipeID, INT64 Adena);
native static function RequestRecipeItemMakeSelf(int RecipeID, optional int OfferingCount, optional array<OfferingItemList> OfferItemList);
//native static function RequestRecipeItemMakeSelf( int RecipeID );
//end of branch

native static function RequestRecipeItemMakeInfo( ItemID sID );
native static function RequestRecipeBookOpen( int Type );
native static function RequestRecipeItemDelete( ItemID sID );
native static function RequestRecipeShopManageQuit();
native static function RequestRecipeShopMessageSet( string strMsg );
native static function RequestRecipeShopListSet( string param );
defaultproperties
{
}
