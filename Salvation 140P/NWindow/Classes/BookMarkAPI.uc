// BookMarkAPI

class BookMarkAPI extends UIEventManager
	native;

native static function bool RequestBookMarkSlotInfo();
native static function bool RequestShowBookMark();
native static function bool RequestSaveBookMarkSlot(string slotTitle, int iconID, string iconTitle);
native static function bool RequestModifyBookMarkSlot(ItemID slotID, string slotTitle, int iconID, string iconTitle);
native static function bool RequestDeleteBookMarkSlot(ItemID slotID);
native static function bool RequestTelePortBookMark(ItemID slotID);
native static function bool RequestChangeBookMarkSlot(ItemID slotID1, ItemID slotID2);
native static function bool RequestGetBookMarkPos(ItemID slotID, out vector pos);
defaultproperties
{
}
