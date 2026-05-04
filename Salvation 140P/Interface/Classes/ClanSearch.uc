class ClanSearch extends L2UIGFxScript;

var int clanID;

function OnRegisterEvent()
{	
	//대기자 리스트 받기  9620
	RegisterGFxEvent( EV_PledgeDraftListStart );
	//대기자 리스트 아이템 9621
	RegisterGFxEvent( EV_PledgeDraftListItem );
	//가입 대기자리스트 9600
	RegisterGFxEvent( EV_PledgeWaitingListStart );
	//가입 대기자리스트 9601
	RegisterGFxEvent( EV_PledgeWaitingListItem );
	
	//검색결과 
	RegisterGFxEvent( EV_PledgeRecruitBoardStart );
	//검색결과아이템 9581
	RegisterGFxEvent( EV_PledgeRecruitBoardItem );
	//혈맹정보요청결과 9590
	RegisterGFxEvent( EV_PledgeRecruitBoardDetail );
	//혈맹 정보 받기 9582
	RegisterGFxEvent( EV_PledgeRecruitInfo );
	//혈맹 정보 받기 9583
	RegisterGFxEvent( EV_PledgeRecruitInfoItem );
	//가입 신청 메모 받기 9610
	RegisterGFxEvent( EV_PledgeWaitingUser );
	//가입 신청 조회 9591
	RegisterGFxEvent( EV_PledgeWaitingListApplied );
	//혈맹 신청 정보 조회 9640
	RegisterGFxEvent( EV_PledgeRecruitApplyInfo );

	//클랜정보 340
	RegisterGFxEvent( EV_ClanMyAuth );
	RegisterGFxEvent( EV_GFX_ClanMyAuth ); //               = 10520;

	//혈맹 이름등.. 정보 430
	RegisterGFxEvent( EV_ClanMemberInfo );
	RegisterGFxEvent( EV_GFX_ClanMemberInfoUpdate ); //     = 10510;

	//재접속시 정보삭제
	RegisterGFxEvent( EV_Restart );

	// 가입 성공 여부를 받음.
	//RegisterGFxEvent( EV_PledgeSigninForOpenJoiningMethod );

	// 혈맹 탈 퇴 시 들어오는 이벤트 임 420
	RegisterGFxEvent( EV_ClanDeleteAllMember );
	RegisterGFxEvent( EV_GFX_ClanDeleteAllMember ); //      = 10470;
	
}

function onShow() 
{
	getInstanceL2Util().checkIsPrologueGrowType ( string(self) );
}

function OnLoad()
{	
	//registerState( "ClanSearch", "GamingState" );	
	// 어느 콘테이너에 넣을 건지 선언
	//SetContainer( "ContainerWindow" );
	SetContainerWindow(WINDOWTYPE_DECO_NORMAL, 3068);
	AddState("GAMINGSTATE");
	
	//setDefaultShow(true);
}

function onCallUCFunction( string functionName, string param )
{
	//Debug("sampe's onCallUCFunction" @ functionName @ param);
	switch ( functionName ) 
	{
		case "getClanID" :
			getClanID();
		break;
		case "sendPost":
			sendPost(param);
		break;
		case "whisperToUser":
			whisperToUser(param);
		break;
		case "askJoin":
			askJoin(param);
		break;
		
	}
}

//클랜아이디 갖고오기
function getClanID() 
{
	local UserInfo userinfo;
	//local string names;

	if( GetPlayerInfo( userinfo ) )
	{	
		//names = userinfo.Name;
		clanID = userinfo.nClanID;
		//callGFxFunction( "ClanSearch", "getClanID", clanID);
		//callGFxFunction( "ClanSearch", "getClanID", "ClanID="$clanID@"Name="$names@"");
	}
}

//우편 발송
function sendPost(string userName)
{
	local PostBoxWnd postBoxWndScript;
	local PostWriteWnd postWriteWndScript;

	if (userName != "")
	{
		// 우편 창을 열고 해당 이름을 넣고 우편을 쓰도록 한다.
		postBoxWndScript = PostBoxWnd(GetScript("PostBoxWnd"));	
		postWriteWndScript = PostWriteWnd(GetScript("PostWriteWnd"));	

		postBoxWndScript.OnClickButton("PostSendBtn");
		postWriteWndScript.toWrite(userName);
	}	
}

//귓속말하기
function whisperToUser(string userName)
{
	local ChatWnd chatWndScript;
	if (userName != "")
	{
		//callGFxFunction("ChatMessage", "sendWhisper", userName);
		//클라쪽 귓속말 확인
		chatWndScript = ChatWnd(GetScript("ChatWnd"));
		chatWndScript.setChatEditBox("\"" $ userName $ " ");
	}
}
function askJoin(string userID)
{
	local int nID;
	local InviteClanPopWnd InviteClanPopWndScript;
	local InviteClanPopWndClassic InviteClanPopWndClassicScript;
	nID = int(userID);

	if( nID > 0 )
	{
		if ( getInstanceUIData().getIsClassicServer() ) 
		{	
			InviteClanPopWndClassicScript = InviteClanPopWndClassic( GetScript("InviteClanPopWndClassic" ) );
			InviteClanPopWndClassicScript.showByClanWnd();
		}
		else 
		{
			InviteClanPopWndScript = InviteClanPopWnd( GetScript("InviteClanPopWnd" ) );
			InviteClanPopWndScript.showByClanWnd();
		}
	}
}
defaultproperties
{
}
