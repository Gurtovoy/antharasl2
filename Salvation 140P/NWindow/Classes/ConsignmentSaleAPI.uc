class ConsignmentSaleAPI extends Object
	native;
// 아이템 위탁판매 - lancelot 2010. 10. 12.
native static function RequestCommissionInfo(int serverID);
native static function RequestCommissionRegistrableItemList();

//branch110706
native static function RequestCommissionSellingPremiumItemList();
native static function RequestCommissionRegister(int ServerID, string ItemName, int64 PricePerUnit, int64 Amount, int Period, int premiumItemID);
//end of branch

native static function RequestCommissionCancel();
native static function RequestCommissionDelete(int64 CommissionDBId, int ItemType, int PeriodType);
native static function RequestCommissionList(int Depth, int DepthType, int NameCalss, int Grade, string SearchString);
native static function RequestCommissionBuyInfo(int64 CommissionDBId, int ItemType);
native static function RequestCommissionBuyItem(int64 CommissionDBId, int ItemType);
native static function RequestCommissionRegisteredItem();
native static function int GetCommissionSellerID();
defaultproperties
{
}
