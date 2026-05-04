class PetAPI extends UIEventManager
	native;

native static function RequestPetInventoryItemList();
native static function RequestPetUseItem(ItemID sID);
native static function RequestGiveItemToPet(ItemID sID, INT64 Num);
native static function RequestGetItemFromPet(ItemID sID, INT64 Num, bool IsEquipItem);
defaultproperties
{
}
