class InviteClanPopWnd extends UICommonAPI;

const SHOW_TYPE_ClanWnd                          = 1;
const SHOW_TYPE_PersonalConnectionsWnd           = 2;
const SHOW_TYPE_PersonalConnectionsWndByUserName = 3;

var string m_userName;
var array<int>	m_knighthoodIndex;

var int showType;

var WindowHandle  Me;

// 인맥 관리에서 호출한 정보 저장
var int friendServerID, friendClanType;
var string targetUserName;

function OnRegisterEvent()
{
	registerEvent( EV_GamingStateExit );
}

function OnLoad()
{
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	Me = GetWindowHandle( "InviteClanPopWnd" );


	m_knighthoodIndex.Length = CLAN_KNIGHTHOOD_COUNT;
	m_knighthoodIndex[0] = 0;
	m_knighthoodIndex[1] = 100;
	m_knighthoodIndex[2] = 200;
	m_knighthoodIndex[3] = 1001;
	m_knighthoodIndex[4] = 1002;
	m_knighthoodIndex[5] = 2001;
	m_knighthoodIndex[6] = 2002;
	m_knighthoodIndex[7] = -1;
}

function OnShow()
{
	
}


// 혈맹 창에서 혈맹초대
function showByClanWnd()
{
	Me.ShowWindow();
	showType = SHOW_TYPE_ClanWnd;
	InitializeComboBox();
}

// 인맥관리 에서 혈맹초대 (사용 안할듯.. 아래 이름으로 추가 하는 함수가 있어서)
function showByPersonalConnectionsWnd(int serverID)
{
	// Debug("날 열어@");
	Me.ShowWindow();

	showType = SHOW_TYPE_PersonalConnectionsWnd;
	friendServerID = serverID;

	InitializeComboBox();
}

// 인맥관리 에서 혈맹초대, 유저 이름을 사용
function showByPersonalConnectionsWndUsingUserName(string userName)
{
	// Debug("날 열어@" @ userName);
	Me.ShowWindow();

	showType = SHOW_TYPE_PersonalConnectionsWndByUserName;
	targetUserName = userName;

	InitializeComboBox();
}

function OnEvent( int a_EventID, String a_Param )
{
	switch( a_EventID )
	{
		case EV_GamingStateExit:
			class'UIAPI_WINDOW'.static.HideWindow("InviteClanPopWnd");
			break;
		
		default:
			break;
	}
}

function OnClickButton( string strID )
{
	if( strID == "InviteClandPopOkBtn" )
	{
//		Debug("showType" @ showType);
		if (showType == SHOW_TYPE_PersonalConnectionsWnd)
		{
			AskJoinByPersonalConnectionsWnd();
		}
		else if (showType == SHOW_TYPE_PersonalConnectionsWndByUserName)
		{
			AskJoinByPersonalConnectionsWndByUserName();
		}
		else
		{
			AskJoin();
		}
		class'UIAPI_WINDOW'.static.HideWindow("InviteClanPopWnd");
	}
	else if( strID == "InviteClandPopCancelBtn" )
	{
		class'UIAPI_WINDOW'.static.HideWindow("InviteClanPopWnd");
	}
}

/** 혈맹 창에서 초대한 경우 - 타겟 베이스 */
function AskJoin()
{
	local UserInfo user;
	local int	index;
	local int	knighthoodID;

	if( GetTargetInfo( user ) )
	{
		if( user.nID > 0 )
		{
			index = class'UIAPI_COMBOBOX'.static.GetSelectedNum("InviteClanPopWnd.ComboboxInviteClandPopWnd");
			if( index >= 0 )
			{
				knighthoodID = class'UIAPI_COMBOBOX'.static.GetReserved("InviteClanPopWnd.ComboboxInviteClandPopWnd", index);

				//debug("AskJoin : id " $ user.nID $ " name " $ user.Name $ " clanType " $ knighthoodID );
				RequestClanAskJoin( user.nID, knighthoodID );
			}
		}
	}
}

/** 인맥 쪽에서 초대한 경우 - 지정한 캐릭의 서버 아이디로 거리 상관 없이 */
function AskJoinByPersonalConnectionsWnd()
{
	// local UserInfo user;
	local int	index;
	local int	knighthoodID;
	
	if (friendServerID > 0)
	{

		index = class'UIAPI_COMBOBOX'.static.GetSelectedNum("InviteClanPopWnd.ComboboxInviteClandPopWnd");
		if( index >= 0 )
		{
			knighthoodID = class'UIAPI_COMBOBOX'.static.GetReserved("InviteClanPopWnd.ComboboxInviteClandPopWnd", index);

			//debug("AskJoin : id " $ user.nID $ " name " $ user.Name $ " clanType " $ knighthoodID );
			//Debug("knighthoodID" @knighthoodID);
			RequestClanAskJoin( friendServerID, knighthoodID );
		}
	}
}

/** 인맥 쪽에서 초대한 경우 - 지정한 캐릭의 유저 아이디로 거리 상관 없이 */
function AskJoinByPersonalConnectionsWndByUserName()
{
	// local UserInfo user;
	local int	index;
	local int	knighthoodID;
	
	index = class'UIAPI_COMBOBOX'.static.GetSelectedNum("InviteClanPopWnd.ComboboxInviteClandPopWnd");
	if( index >= 0 )
	{
		knighthoodID = class'UIAPI_COMBOBOX'.static.GetReserved("InviteClanPopWnd.ComboboxInviteClandPopWnd", index);
		// 이름 으로 클린을 가입 하도록 하는 함수, 클라: 정동현 추가 해줌			
		RequestClanAskJoinByName(targetUserName, knighthoodID);
	}
}


function InitializeComboBox()
{
	local int i;
	local ClanWnd	script;
	local int addedCount;
	local string countnum;
	local string countnum2;
	local int cnt1;
	local int cnt2;
	local string m_sName;
	
	class'UIAPI_COMBOBOX'.static.Clear("InviteClanPopWnd.ComboboxInviteClandPopWnd");	

	script = ClanWnd( GetScript("ClanWnd") );
	countnum2 = "" $ script.m_myClanType;		

	cnt1 = len(countnum2);

	for( i=0 ; i < CLAN_KNIGHTHOOD_COUNT ; ++i )
	{
		countnum = "" $ m_knighthoodIndex[i];
		m_sName = script.m_memberList[i].m_sName;
		//debug(countnum);
		cnt2 = len(countnum);

		//Debug( "InitializeComboBox1:" @ i @ "/" $ script.m_memberList[i].m_sName $ "/" ) ;

		if( m_sName != "" )
		{
			//Debug ( "InitializeComboBox2:" @ i @ "/" $ script.m_memberList[i].m_sName $ "/" );
			if ( m_knighthoodIndex[i] == -1 )
			{
				class'UIAPI_COMBOBOX'.static.AddStringWithReserved("InviteClanPopWnd.ComboboxInviteClandPopWnd", m_sName, m_knighthoodIndex[i] );
				++addedCount;
			}
			else if (cnt1 <= cnt2)
			{
				class'UIAPI_COMBOBOX'.static.AddStringWithReserved("InviteClanPopWnd.ComboboxInviteClandPopWnd", m_sName, m_knighthoodIndex[i] );
				++addedCount;
			}
		}
	}
	if( addedCount > 0 )
		class'UIAPI_COMBOBOX'.static.SetSelectedNum("InviteClanPopWnd.ComboboxInviteClandPopWnd", 0);		// 제일 처음 아이템이 보이도록
}
defaultproperties
{
}
