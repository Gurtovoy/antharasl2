class PersonalConnectionAPI extends UIDataManager
	native;
	
native static function RequestAddFriend(string name);
native static function RequestRemoveFriend(string name);

native static function RequestFriendInfoList();
native static function RequestFriendDetailInfo(string name);
native static function RequestUpdateFriendMemo(string name, string memo);

native static function RequestAddBlock(string name);
native static function RequestRemoveBlock(string name);

native static function RequestBlockInfoList();
native static function RequestBlockDetailInfo(string name);
native static function RequestUpdateBlockMemo(string name, string memo);

native static function RequestInzonePartyInfoHistory();
native static function RequestPledgeMemberList();

native static function int GetFriendServerID(string name);

native static function RequestFriendChat(string name);

// mentor
native static function RequestMenteeAdd(string MenteeName);
native static function ConfirmMenteeAdd(string MentorName, int Ok);
native static function RequestMentorList();
native static function RequestMentorCancel(int ImMentor, string TargetName);
defaultproperties
{
}
