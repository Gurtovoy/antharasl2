class UIDATA_INVENTORY extends UIDataManager
	native;

// 아래 함수들 검색 순서는 인벤토리, 장비, 퀘스트 아이템 순으로...

native static function bool HasItem( int a_ServerID );
native static function bool HasItemByClassID( int a_ClassID );

native static function bool FindItem( int a_ServerID, out ItemInfo info );
native static function int FindItemByClassID( int a_ClassID, out array<ItemInfo> info );

native static function bool IsEquipItem( int a_ServerID );
native static function bool IsEquipItemByClassID( int a_ClassID );

native static function bool IsQuestItem( int a_ServerID );
native static function bool IsQuestItemByClassID( int a_ClassID );

native static function int GetAllItem( out array<ItemInfo> info );
native static function int GetAllEquipItem( out array<ItemInfo> info );
native static function int GetAllInvenItem( out array<ItemInfo> info );
native static function int GetAllQuestItem( out array<ItemInfo> info );
defaultproperties
{
}
