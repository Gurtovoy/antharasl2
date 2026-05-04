class PartyMatchWaitListWnd extends PartyMatchWndCommon;
var int entire_page;
var int current_page;
var int minLevel;
var int maxLevel;

var int RoomNumber;
var int MaxPartyMemberCount;
var int LootingMethodID;
//var int RoomZoneID;

var string			m_WindowName;
var ListCtrlHandle	m_hPartyMatchWaitListWndWaitListCtrl;

//선준 수정(2010.02.22 ~ 03.08) 완료
var ComboBoxHandle  JobFilterComboBox;
var string          strName;
var int             job;
//const               MAXLV = 85;
//const               MINLV = 1;

var EditBoxHandle   m_MinLevelEditBox;
var EditBoxHandle   m_MaxLevelEditBox;

var int MyMembershipType;


function OnRegisterEvent()
{
	RegisterEvent( EV_PartyMatchRoomStart );
	RegisterEvent( EV_PartyMatchWaitListStart );
	RegisterEvent( EV_PartyMatchWaitList );
	//선준 수정(2010.03.31) 완료
	RegisterEvent( EV_Restart );
}
 
function OnLoad()
{	
	entire_page = 1;
	current_page = 1;

	m_MinLevelEditBox = GetEditBoxHandle("PartyMatchWaitListWnd.MinLevel");
	m_MinLevelEditBox.DisableWindow();
	
	m_MaxLevelEditBox = GetEditBoxHandle("PartyMatchWaitListWnd.MaxLevel");
	m_MaxLevelEditBox.DisableWindow();

	//m_MinLevelEditBox.SetString("22");
	//class'UIAPI_EDITBOX'.static.SetString( "PartyMatchWaitListWnd.MinLevel", "11");
	//class'UIAPI_EDITBOX'.static.SetString( "PartyMatchWaitListWnd.MaxLevel", string(GetMaxLevel()));
		
	m_hPartyMatchWaitListWndWaitListCtrl=GetListCtrlHandle(m_WindowName$".WaitListCtrl");


	JobFilterComboBox = GetComboBoxHandle( "PartyMatchWaitListWnd.Job" );	
	setRoleStringJobCombox();
}

function setRoleStringJobCombox( ) 
{	
	local int i ;	
	JobFilterComboBox.AddStringWithReserved( GetSystemString( 1046 ), 0);		
	for ( i = 1 ; i <= getInstanceUIData().ROLETYPEMAX ; i ++ )
		JobFilterComboBox.AddStringWithReserved( GetClassRoleNameByRole( EClassRoleType(i)), i);
}

function OnShow()
{
	current_page = 1;
	//class'UIAPI_EDITBOX'.static.SetFocus( "PartyMatchWaitListWnd.MaxLevel");
}

function OnEvent( int a_EventID, String param )
{
	//Debug( "OnEvent" @ a_EventID );
	switch( a_EventID )
	{
	case EV_PartyMatchRoomStart:
		HandlePartyMatchRoomStart( param );
		break;
	case EV_PartyMatchWaitListStart:
		HandlePartyMatchWaitListStart( param );
		break;
	case EV_PartyMatchWaitList:
		HandlePartyMatchWaitList( param );
		break;
	//선준 수정(2010.03.31) 완료
	case EV_Restart:
		HandleRestart();
		break;
	}
}

//선준 수정(2010.03.31) 완료
function HandleRestart()
{
	class'UIAPI_EDITBOX'.static.SetString( "PartyMatchWaitListWnd.Name", "" );
}


//partyMatchRoomWnd 에서  EV_PartyMatchRoomMember 처리 후 실행
function updateMyMemberShipType ( int MembershipType)
{
	MyMembershipType = MembershipType;

	if ( getInstanceUIData().getIsClassicServer() ) 
	{		
		m_MinLevelEditBox.SetString(string(MinLevel));
		m_MaxLevelEditBox.SetString(string(MaxLevel));
	}
	else 
	{	
		switch ( MyMembershipType ) 
		{
		//내가 만든 방일 경우 
		case 1:			
			MinLevel = int ( class'UIAPI_EDITBOX'.static.GetString( "PartyMatchMakeRoomWnd.MinLevelEditBox" ));
			MaxLevel = int ( class'UIAPI_EDITBOX'.static.GetString( "PartyMatchMakeRoomWnd.MaxLevelEditBox" ));
			if ( MinLevel == 0 ) MinLevel = 1 ;
			if ( MaxLevel == 0 ) MaxLevel = 1;
			if ( MinLevel > MaxLevel ) MaxLevel = MinLevel;			
			m_MinLevelEditBox.SetString ( String( MinLevel ) );
			m_MaxLevelEditBox.SetString ( String( MaxLevel ) );
		break;
		// 그 외
		case 0:		
		case 2:			
			// 맥스 레벨 이상인 경우 getInstanceUIData().MAXLV2DISPLAY 로 보여 짐
			if ( MaxLevel == getInstanceUIData().MAXLV ) MaxLevel = getInstanceUIData().MAXLV2DISPLAY; 
			if ( MinLevel == getInstanceUIData().MAXLV ) MinLevel = getInstanceUIData().MAXLV2DISPLAY;
			// getInstanceUIData().MAXLV2DISPLAY 이상인 경우 getInstanceUIData().MAXLV2DISPLAY 로 보여짐
			//if ( MaxLevel > getInstanceUIData().MAXLV2DISPLAY ) MaxLevel = getInstanceUIData().MAXLV2DISPLAY; 
			//if ( MinLevel > getInstanceUIData().MAXLV2DISPLAY ) MinLevel = getInstanceUIData().MAXLV2DISPLAY;
			m_MinLevelEditBox.SetString(string(MinLevel));
			m_MaxLevelEditBox.SetString(string(MaxLevel));
		break;
		}
	}
}



function HandlePartyMatchRoomStart( String param )
{
	//local partyMatchRoomWnd script ;

	ParseInt(param, "RoomNum", RoomNumber);
	ParseInt(param, "MaxMember", MaxPartyMemberCount);
	ParseInt(param, "MinLevel", MinLevel);	
	ParseInt(param, "MaxLevel", MaxLevel);

	ParseInt(param, "LootingMethodID", LootingMethodID);
	//ParseInt(param, "ZoneID", RoomZoneID);
}

function HandlePartyMatchWaitListStart( String param )
{
	local int AllCount;
	local int Count;
	local string totalPages;
	local string currentPage;
	local string page_info;
	
	ParseInt(param, "AllCount", AllCount);
	ParseInt(param, "Count", Count);
	
	totalPages = string((AllCount/64)+1);
	entire_page = (AllCount/64)+1;
	currentPage = string(current_page);
	page_info = currentPage $ "/" $ totalPages;
	
	class'UIAPI_TEXTBOX'.static.SetText( "PartyMatchWaitListWnd.MemberCount", page_info );	
	class'UIAPI_LISTCTRL'.static.DeleteAllItem( "PartyMatchWaitListWnd.WaitListCtrl" );
	CheckButtonAlive();
}

function HandlePartyMatchWaitList( String param )
{
	local String Name;
	local int ClassID;
	local int Level;
	local LVDataRecord Record;

	//local int       LocationZoneID;
	local int       RestrictZoneCnt;
	local string    RestrictZoneID;
	local int       temp;
	local int       i;
	
	RestrictZoneID = "";

	ParseString(param, "Name", Name);
	ParseInt(param, "ClassID", ClassID);
	ParseInt(param, "Level", Level);
	

	//선준 수정(2010.02.22 ~ 03.08) 완료
	//ParseInt(param, "LocationZoneID", LocationZoneID);
	ParseInt(param, "RestrictZoneCnt", RestrictZoneCnt);
	
	if( RestrictZoneCnt == 0 )
	{
		RestrictZoneID = "";
	}

	for(i = 0; i < RestrictZoneCnt ; i++)
	{
		ParseInt(param, "RestrictZoneID_" $ i, temp);
		if( i != 0 )
		{
			RestrictZoneID = RestrictZoneID $ "," $ GetInZoneNameWithZoneID( temp );
		}
		else
		{
			RestrictZoneID = GetInZoneNameWithZoneID( temp );
		}
	}

	//debug( "LocationZoneID --> " @  LocationZoneID );
	//debug( "RestrictZoneCnt --> " @  RestrictZoneCnt );
	//debug( "RestrictZoneID?? --> " @  RestrictZoneID );
	
	Record.LVDataList.length = 5;
	Record.LVDataList[0].szData = Name;
	Record.LVDataList[1].szTexture = GetClassRoleIconName( ClassID );
	Record.LVDataList[1].nTextureWidth = 11;
	Record.LVDataList[1].nTextureHeight = 11;
	Record.LVDataList[1].szData = String(ClassID) ;
	Record.LVDataList[1].HiddenStringForSorting = String (GetClassRoleType( ClassID ));
	Record.LVDataList[2].szData = GetAmbiguousLevelString( Level, false );
	//Record.LVDataList[3].szReserved = String( LocationZoneID );
	//Record.LVDataList[3].szData = String( LocationZoneID );
	Record.LVDataList[3].szData = RestrictZoneID;

	Record.nReserved1 = Level;	

	class'UIAPI_LISTCTRL'.static.InsertRecord( "PartyMatchWaitListWnd.WaitListCtrl", Record );
}

function OnClickButton( string a_strButtonName )
{
	switch( a_strButtonName )
	{
	case "RefreshButton":
		OnRefreshButtonClick();
		break;
	case "WhisperButton":
		OnWhisperButtonClick();
		break;
	case "PartyInviteButton":
		OnInviteButtonClick();
		break;
	case "CloseButton":
		OnCloseButtonClick();
		break;
	case "btn_Search":
		OnSearchBtnClick();
		break;
	case "prev_btn":
		OnPrevbuttonClick();
		break;
	case "next_btn":
		OnNextbuttonClick();
		break;
	case "btn_Reset":
		OnResetbuttonClick();
	}
}

function OnRefreshButtonClick()
{
	//debug("Job ComboBox--->" @  JobFilterComboBox.GetSelectedNum() );

	MinLevel = int(class'UIAPI_EDITBOX'.static.GetString( "PartyMatchWaitListWnd.MinLevel"));
	MaxLevel = int(class'UIAPI_EDITBOX'.static.GetString( "PartyMatchWaitListWnd.MaxLevel"));
	
	//선준 수정(2010.02.22 ~ 03.08) 완료
	job = JobFilterComboBox.GetSelectedNum();
	strName = class'UIAPI_EDITBOX'.static.GetString( "PartyMatchWaitListWnd.Name");

	RequestPartyMatchWaitList( current_page, MinLevel, MaxLevel, job, strName );
}
 
function OnNextbuttonClick()
{
	current_page = current_page +1;
	//선준 수정(2010.02.22 ~ 03.08) 완료
	RequestPartyMatchWaitList(current_page, minLevel, maxLevel, job, strName );	
}

function OnPrevbuttonClick()
{
	current_page = current_page -1;
	//선준 수정(2010.02.22 ~ 03.08) 완료
	RequestPartyMatchWaitList(current_page, minLevel, maxLevel, job, strName );
}

function OnSearchBtnClick()
{
	MinLevel = int(class'UIAPI_EDITBOX'.static.GetString( "PartyMatchWaitListWnd.MinLevel"));
	MaxLevel = int(class'UIAPI_EDITBOX'.static.GetString( "PartyMatchWaitListWnd.MaxLevel"));
	
	if ( MinLevel > GetMaxLevel()) MinLevel = GetMaxLevel();
	if ( MaxLevel > GetMaxLevel()) MaxLevel = GetMaxLevel();

	//Debug( "OnSearchBtnClick" @ MinLevel @ MaxLevel );
	
	//선준 수정(2010.02.22 ~ 03.08) 완료
	job = JobFilterComboBox.GetSelectedNum();
	strName = class'UIAPI_EDITBOX'.static.GetString( "PartyMatchWaitListWnd.Name");

	current_page = 1;

	RequestPartyMatchWaitList( current_page, MinLevel, MaxLevel, job, strName );
	//debug("PartyMatchWaitListWnd.Name ---> " @ strName );
	//debug("Job ComboBox--->" @  JobFilterComboBox.GetSelectedNum() );
	//debug("Job --->" @  job );
	//debug("Job ComboBox22--->" @  JobFilterComboBox.GetSelectedNum() );
}

function OnWhisperButtonClick()
{
	local LVDataRecord Record;
	local string szData1;
	
	m_hPartyMatchWaitListWndWaitListCtrl.GetSelectedRec( record );
	szData1 = Record.LVDataList[0].szData;
	if (szData1 != "")
	{
		//callGFxFunction("ChatMessage","sendWhisper", szData1);
		SetChatMessage( "\"" $ szData1 $ " " );
	}
}

function OnInviteButtonClick()
{
	local LVDataRecord Record;

	m_hPartyMatchWaitListWndWaitListCtrl.GetSelectedRec( record );
	//RequestInviteParty( Record.LVDataList[0].szData );
	//MakeRoomFirst( int(Record.nReserved1), Record.LVDataList[0].szData );

	class'PartyMatchAPI'.static.RequestAskJoinPartyRoom( Record.LVDataList[0].szData );
}

function OnCloseButtonClick()
{
	local PartyMatchWnd Script;
	Script = PartyMatchWnd( GetScript( "PartyMatchWnd" ) );

	if( Script != None )
	{
		Script.SetWaitListWnd(false);
		Script.ShowHideWaitListWnd();
	}
}

function OnDBClickListCtrlRecord( String a_ListCtrlName )
{
	local LVDataRecord Record;

	if( a_ListCtrlName != "WaitListCtrl" )
		return;

	m_hPartyMatchWaitListWndWaitListCtrl.GetSelectedRec( record );
	//callGFxFunction("ChatMessage","sendWhisper", Record.LVDataList[0].szData);
	SetChatMessage( "\"" $ Record.LVDataList[0].szData $ " " );
}

//선준 수정(2010.02.22 ~ 03.08) 완료
function OnResetbuttonClick()
{
	//class'UIAPI_EDITBOX'.static.SetString( "PartyMatchWaitListWnd.MinLevel", string(MINLV) );
	//class'UIAPI_EDITBOX'.static.SetString( "PartyMatchWaitListWnd.MaxLevel", string(MAXLV) );
	
	JobFilterComboBox.SetSelectedNum( 0 );
	
	class'UIAPI_EDITBOX'.static.SetString( "PartyMatchWaitListWnd.Name", "" );

	//MinLevel = MINLV;
	//MaxLevel = MAXLV;
	
	job = 0;
	strName = "";

	//debug("reset!!!!!~~~~~");
}



function MakeRoomFirst(int TargetLevel, string InviteTargetName)
{
	local PartyMatchMakeRoomWnd Script;
	local UserInfo PlayerInfo;
	local int LevelMin;
	local int LevelMax;

	local int MAX_Level;

	if ( getInstanceUIData().getIsClassicServer() ) 
	{
		MAX_Level=getInstanceUIData().MAXLV;
	}else 
	{
		MAX_Level = getInstanceUIData().MAXLV2DISPLAY;
	}
	//MAX_Level=getInstanceUIData().MAXLV;

	Script = PartyMatchMakeRoomWnd( GetScript( "PartyMatchMakeRoomWnd" ) );
	if( Script != None )
	{
		Script.InviteState = Script.InviteStateType.INVITE_MAKEROOM;
		Script.InvitedName = InviteTargetName;
		Script.SetRoomNumber( 0 );
		Script.SetTitle( GetSystemMessage( 1398 ) );
		Script.SetMaxPartyMemberCount( 12 );

		if( GetPlayerInfo( PlayerInfo ) )
		{
			//debug ("내 레벨" @ PlayerInfo.nLevel);
			//debug ("Target 레벨" @ TargetLevel);
			if (TargetLevel < PlayerInfo.nLevel)
			{
				LevelMin = TargetLevel;
				LevelMax = PlayerInfo.nLevel;
			}
			else 
			{
				LevelMin = PlayerInfo.nLevel;
				LevelMax = TargetLevel;
			}

			
			if( LevelMin - 5 > 0 )
				Script.SetMinLevel( LevelMin - 5 );
			else
				Script.SetMinLevel( 1 );

			if( LevelMax + 5 <= MAX_Level )
				Script.SetMaxLevel( LevelMax + 5 );
			else
				Script.SetMaxLevel( Max_Level );
		}		
	}

	class'UIAPI_WINDOW'.static.ShowWindow( "PartyMatchMakeRoomWnd" );
	class'UIAPI_WINDOW'.static.SetFocus( "PartyMatchMakeRoomWnd" );
}


function CheckButtonAlive()
{
	class'UIAPI_WINDOW'.static.EnableWindow("PartyMatchWaitListWnd.prev_btn");
	class'UIAPI_WINDOW'.static.EnableWindow("PartyMatchWaitListWnd.next_btn");
	if (current_page == 1)
	{
	class'UIAPI_WINDOW'.static.DisableWindow("PartyMatchWaitListWnd.prev_btn");
	}
	if (current_page == entire_page)
	{
	class'UIAPI_WINDOW'.static.DisableWindow("PartyMatchWaitListWnd.next_btn");
	}
}

defaultproperties
{
    m_WindowName="PartyMatchWaitListWnd"
}
