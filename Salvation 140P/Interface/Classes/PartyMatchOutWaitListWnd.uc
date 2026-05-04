class PartyMatchOutWaitListWnd extends PartyMatchWndCommon;
var int entire_page;
var int current_page;
var int minLevel;
var int maxLevel;

var string			m_WindowName;
var ListCtrlHandle	m_hPartyMatchOutWaitListWndWaitListCtrl;

//선준 수정(2010.02.22 ~ 03.08) 완료
var ComboBoxHandle  JobFilterComboBox;
var string          strName;
var int             job;
const               MINLV = 1;
var ButtonHandle	searchBtn;


function OnRegisterEvent()
{
	RegisterEvent( EV_PartyMatchWaitListStart );
	RegisterEvent( EV_PartyMatchWaitList );
	//선준 수정(2010.03.31) 완료
	RegisterEvent( EV_Restart );
	RegisterEvent( EV_NeedResetUIData);
}
 
function OnLoad()
{	
	local int MAX_LEVEL;
	entire_page = 1;
	current_page = 1;


	class'UIAPI_EDITBOX'.static.SetString( "PartyMatchOutWaitListWnd.MinLevel", "1");

	if ( getInstanceUIData().getIsClassicServer() ) 
	{
		MAX_LEVEL = getInstanceUIData().MAXLV;
		
	} else 
	{
		MAX_LEVEL = getInstanceUIData().MAXLV2DISPLAY;
	}

	class'UIAPI_EDITBOX'.static.SetString( "PartyMatchOutWaitListWnd.MaxLevel", String( MAX_LEVEL ));
		
	m_hPartyMatchOutWaitListWndWaitListCtrl=GetListCtrlHandle(m_WindowName$".WaitListCtrl");

	searchBtn = GetButtonHandle( "PartyMatchOutWaitListWnd.btn_Search" );

	JobFilterComboBox = GetComboBoxHandle( "PartyMatchOutWaitListWnd.Job" );
	setRoleStringJobCombox( ) ;
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
	class'UIAPI_EDITBOX'.static.SetFocus( "PartyMatchOutWaitListWnd.MaxLevel");
}

function OnEvent( int a_EventID, String param )
{
	local int MAX_LEVEL;

	switch( a_EventID )
	{
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
	case EV_NeedResetUIData:		
		if ( getInstanceUIData().getIsClassicServer() ) 
		{
			//getInstanceUIData().MAXLV 로 받지 않는다. 같은 이벤트에 다시 받기 때문에 순서가 뒤바뀜
			MAX_LEVEL = GetMaxLevel();//getInstanceUIData().MAXLV;
			
		} else 
		{
			MAX_LEVEL = getInstanceUIData().MAXLV2DISPLAY;
		}

		class'UIAPI_EDITBOX'.static.SetString( "PartyMatchOutWaitListWnd.MaxLevel",string ( MAX_LEVEL ));		
		break;
	}
}

//선준 수정(2010.03.31) 완료
function HandleRestart()
{
	class'UIAPI_EDITBOX'.static.SetString( "PartyMatchOutWaitListWnd.Name", "" );
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

	class'UIAPI_TEXTBOX'.static.SetText( "PartyMatchOutWaitListWnd.MemberCount", page_info );	
	class'UIAPI_LISTCTRL'.static.DeleteAllItem( "PartyMatchOutWaitListWnd.WaitListCtrl" );
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

	class'UIAPI_LISTCTRL'.static.InsertRecord( "PartyMatchOutWaitListWnd.WaitListCtrl", Record );
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

	MinLevel = int(class'UIAPI_EDITBOX'.static.GetString( "PartyMatchOutWaitListWnd.MinLevel"));
	MaxLevel = int(class'UIAPI_EDITBOX'.static.GetString( "PartyMatchOutWaitListWnd.MaxLevel"));
	
	//선준 수정(2010.02.22 ~ 03.08) 완료
	job = JobFilterComboBox.GetSelectedNum();
	strName = class'UIAPI_EDITBOX'.static.GetString( "PartyMatchOutWaitListWnd.Name");

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
	MinLevel = int(class'UIAPI_EDITBOX'.static.GetString( "PartyMatchOutWaitListWnd.MinLevel"));
	MaxLevel = int(class'UIAPI_EDITBOX'.static.GetString( "PartyMatchOutWaitListWnd.MaxLevel"));
	
	//선준 수정(2010.02.22 ~ 03.08) 완료
	job = JobFilterComboBox.GetSelectedNum();
	strName = class'UIAPI_EDITBOX'.static.GetString( "PartyMatchOutWaitListWnd.Name");

	current_page = 1;

	RequestPartyMatchWaitList( current_page, MinLevel, MaxLevel, job, strName );
	//debug("PartyMatchOutWaitListWnd.Name ---> " @ strName );
	//debug("Job ComboBox--->" @  JobFilterComboBox.GetSelectedNum() );
	//debug("Job --->" @  job );
	//debug("Job ComboBox22--->" @  JobFilterComboBox.GetSelectedNum() );
}

function OnWhisperButtonClick()
{
	local LVDataRecord Record;
	local string szData1;
	
	m_hPartyMatchOutWaitListWndWaitListCtrl.GetSelectedRec( record );
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

	m_hPartyMatchOutWaitListWndWaitListCtrl.GetSelectedRec( record );
	//RequestInviteParty( Record.LVDataList[0].szData );
	MakeRoomFirst( int(Record.nReserved1), Record.LVDataList[0].szData );
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

	m_hPartyMatchOutWaitListWndWaitListCtrl.GetSelectedRec( record );
	SetChatMessage( "\"" $ Record.LVDataList[0].szData $ " " );
	//callGFxFunction("ChatMessage","sendWhisper", Record.LVDataList[0].szData);

}

//선준 수정(2010.02.22 ~ 03.08) 완료
function OnResetbuttonClick()
{
	local int MAX_LEVEL ;
	class'UIAPI_EDITBOX'.static.SetString( "PartyMatchOutWaitListWnd.MinLevel", string(MINLV) );

	if ( getInstanceUIData().getIsClassicServer() ) 
	{
		MAX_LEVEL = getInstanceUIData().MAXLV;
		
	} else 
	{
		MAX_LEVEL = getInstanceUIData().MAXLV2DISPLAY;
	}
	class'UIAPI_EDITBOX'.static.SetString( "PartyMatchOutWaitListWnd.MaxLevel", string ( MAX_LEVEL ) );			
	 
	
	
	JobFilterComboBox.SetSelectedNum( 0 );
	
	class'UIAPI_EDITBOX'.static.SetString( "PartyMatchOutWaitListWnd.Name", "" );

	MinLevel = MINLV;
	MaxLevel = getInstanceUIData().MAXLV;
	
	job = 0;
	strName = "";

	//debug("reset!!!!!~~~~~");
}

//5초가 지나면 버튼들의 Disable상태가 풀린다
function OnButtonTimer( bool bExpired )
{
	//debug("5초~~~타이머...");
	/*
	if (bExpired)
	{
		searchBtn.EnableWindow();

	}
	else
	{
		searchBtn.DisableWindow();
	}
	*/
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
	class'UIAPI_WINDOW'.static.EnableWindow("PartyMatchOutWaitListWnd.prev_btn");
	class'UIAPI_WINDOW'.static.EnableWindow("PartyMatchOutWaitListWnd.next_btn");
	if (current_page == 1)
	{
	class'UIAPI_WINDOW'.static.DisableWindow("PartyMatchOutWaitListWnd.prev_btn");
	}
	if (current_page == entire_page)
	{
	class'UIAPI_WINDOW'.static.DisableWindow("PartyMatchOutWaitListWnd.next_btn");
	}
}

defaultproperties
{
    m_WindowName="PartyMatchOutWaitListWnd"
}
