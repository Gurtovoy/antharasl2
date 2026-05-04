class PostWndAPI extends UIEventManager
	native;

native static function RequestFriendList();
native static function RequestAddingPostFriend(string name);
native static function RequestDeletingPostFriend( string name );
native static function RequestPostFriendList();
native static function RequestPledgeMemberList();
defaultproperties
{
}
