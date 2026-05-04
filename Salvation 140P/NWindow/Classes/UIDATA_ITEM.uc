class UIDATA_ITEM extends UIDataManager
	native;

native static function ItemID GetFirstID();
native static function ItemID GetNextID();
// 아이템 검색용 함수. 인자로  -1 일 시 해당 타입 검사하지 않음
native static function ItemID FindNextID(string strItemName, int ItemType, int ItemCrystalType);

native static function int GetDataCount();
native static function string GetItemName(ItemID Id);
native static function string GetItemAdditionalName(ItemID Id);
native static function string GetItemTextureName(ItemID Id);
native static function string GetItemDescription(ItemID Id);
native static function int GetItemWeight(ItemID Id);
native static function int GetItemDataType(ItemID Id);
native static function int GetItemCrystalType(ItemID Id);
native static function bool GetItemInfo(ItemID Id, out ItemInfo info );
native static function bool GetItemInfoString(int ItemClassID, out string info); // by y2jinc 
native static function bool IsCrystallizable(ItemID Id);
native static function bool IsMagicWeapon(ItemID Id);
native static function string GetRefineryItemName(string strItemName, int RefineryOp1, int RefineryOp2);
native static function int GetSetItemNum(ItemID Id, int setIdId);
native static function bool IsExistSetItem(ItemID Id, int setId, int index);
native static function int GetSetItemFirstID(ItemID Id, int setId, int index);
native static function bool GetSetItemID(ItemID Id, int setId, int index, out array<ItemID> arrID);
native static function int GetItemSetEnchantEffectNum(ItemID id);
native static function int GetSetItemEnchantConditionalValue(ItemID Id, int index);
native static function string GetSetItemEnchantEffectDescription(ItemID Id, int index);
native static function string GetEtcItemTextureName(ItemID Id);

native static function int GetSetItemPeaceEffectNum(ItemID Id, int SetId);
native static function string GetSetItemPeaceEffectDescription(ItemID Id, int SetId, int EffectIndex);

//보급,고급형 아이템, ttmayrin
native static function int GetItemNameClass(ItemID Id);

native static function EItemInventoryType GetInventoryType(int ClassID);

//branch EP1.0 2014-2-25 luciper3 - 아이템 디스크립션 수정
native static function GetItemDescriptionAdditionData(ItemID Id, out string NotAvailable, out string Available);
//end of branch
defaultproperties
{
}
