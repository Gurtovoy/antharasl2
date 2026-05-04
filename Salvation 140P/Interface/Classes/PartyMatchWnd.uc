class PartyMatchWnd extends PartyMatchWndCommon;

var string m_WindowName;
//HandleList
var WindowHandle Me;
var ListCtrlHandle PartyMatchListCtrl;
var ComboBoxHandle LevelFilterComboBox;
var ButtonHandle PrevBtn;
var ButtonHandle NextBtn;
var ButtonHandle AutoJoinBtn;
var ButtonHandle RefreshBtn;

//Other Window
var WindowHandle PartyMatchMakeRoomWnd;
var WindowHandle PartyMatchWaitListWnd;
var WindowHandle PartyMatchOutWaitListWnd;
var EditBoxHandle PartyMatchOutWaitListWnd_MinLevel;
var EditBoxHandle PartyMatchOutWaitListWnd_MaxLevel;


// 클릭 방지 윈도우
var WindowHandle DisableWnd;

var WindowHandle PartyMatchHistory_Wnd;
var ListCtrlHandle WaitList_ListCtrl;

// 활동중인 파티 정보 출력
var TextBoxHandle ActivityPartyTitle_Text;
var TextBoxHandle ActivityParty_Text;
var TextBoxHandle ActivityPartyMemberTitle_Text;
var TextBoxHandle ActivityPartyMember_Text;

//선준 수정(2010.02.22 ~ 03.08) 완료
var ComboBoxHandle  JobFilterComboBox;
var EditBoxHandle   PartyMatchOutWaitListWnd_Name;
const               MAXMEMBER = 12;

//Global Variable
var int CompletelyQuitPartyMatching;
var bool bOpenStateLobby;
var int CUR_PAGE;

//연합매칭
var ListCtrlHandle UnionMatchListCtrl;
var ButtonHandle UnionPrevBtn;
var ButtonHandle UnionNextBtn;
var ButtonHandle UnionRefreshBtn;
var WindowHandle UnionMatchMakeRoomWnd;
var int CUR_PAGE_UNION;

var bool IsInParty;
function InitHandle()
{
	Me = m_hOwnerWnd;
	PartyMatchListCtrl = GetListCtrlHandle( "PartyMatchWnd.PartyMatchListCtrl" );
	UnionMatchListCtrl = GetListCtrlHandle( "PartyMatchWnd.UnionMatchListCtrl" );
	LevelFilterComboBox = GetComboBoxHandle( "PartyMatchWnd.LevelFilterComboBox" );
	PrevBtn = GetButtonHandle( "PartyMatchWnd.PrevBtn" );
	NextBtn = GetButtonHandle( "PartyMatchWnd.NextBtn" );
	AutoJoinBtn = GetButtonHandle( "PartyMatchWnd.AutoJoinBtn" );
	RefreshBtn = GetButtonHandle( "PartyMatchWnd.RefreshBtn" );
	
	//Other Window
	PartyMatchMakeRoomWnd = GetWindowHandle( "PartyMatchMakeRoomWnd" );
	PartyMatchWaitListWnd = GetWindowHandle( "PartyMatchWaitListWnd" );
	PartyMatchOutWaitListWnd = GetWindowHandle( "PartyMatchOutWaitListWnd" );
	PartyMatchOutWaitListWnd_MinLevel = GetEditBoxHandle( "PartyMatchOutWaitListWnd.MinLevel" );
	PartyMatchOutWaitListWnd_MaxLevel = GetEditBoxHandle( "PartyMatchOutWaitListWnd.MaxLevel" );
	//선준 수정(2010.02.22 ~ 03.08) 완료
	JobFilterComboBox = GetComboBoxHandle( "PartyMatchOutWaitListWnd.Job" );
	PartyMatchOutWaitListWnd_Name = GetEditBoxHandle( "PartyMatchOutWaitListWnd.Name" ); 

	//연합매칭
	UnionPrevBtn = GetButtonHandle( "PartyMatchWnd.UnionPrevBtn" );
	UnionNextBtn = GetButtonHandle( "PartyMatchWnd.UnionNextBtn" );
	UnionRefreshBtn = GetButtonHandle( "PartyMatchWnd.UnionRefreshBtn" );
	UnionMatchMakeRoomWnd = GetWindowHandle( "UnionMatchMakeRoomWnd" );

	// 클릭방지 윈도우
	DisableWnd = GetWindowHandle("PartyMatchWnd.DisableWnd");

	// 파티 히스토리 윈도우
	PartyMatchHistory_Wnd = GetWindowHandle("PartyMatchWnd.PartyMatchHistory_Wnd");

	// 파티 히스토리 목록
	WaitList_ListCtrl = GetListCtrlHandle("PartyMatchWnd.PartyMatchHistory_Wnd.WaitList_ListCtrl");

	// 파티중인 정보 출력
	ActivityPartyTitle_Text       = GetTextBoxHandle("PartyMatchWnd.ActivityPartyTitle_Text");
	ActivityParty_Text            = GetTextBoxHandle("PartyMatchWnd.ActivityParty_Text");
	ActivityPartyMemberTitle_Text = GetTextBoxHandle("PartyMatchWnd.ActivityPartyMemberTitle_Text");
	ActivityPartyMember_Text      = GetTextBoxHandle("PartyMatchWnd.ActivityPartyMember_Text");

	DisableWnd.DisableWindow();
}

function SetIsInParty(bool b)
{
	IsInParty = b;
}

function OnRegisterEvent()
{
	RegisterEvent( EV_PartyMatchStart );
	RegisterEvent( EV_PartyMatchList );
	RegisterEvent( EV_PartyMatchRoomStart );
	
	//연합매칭
	RegisterEvent( EV_ListMpccWaitingStart );
	RegisterEvent( EV_ListMpccWaitingRoomInfo );
	
	//파티창 토글 발생
	RegisterEvent( EV_UsePartyMatchAction );
	//
	RegisterEvent( EV_Restart );

	// 파티 히스토리 목록
	RegisterEvent( EV_PartyMatchingRoomHistory );
}

function OnLoad()
{
	SetClosingOnESC();
	InitHandle();
	Init();
}

function Init()
{
	CompletelyQuitPartyMatching = 0;
	bOpenStateLobby = false;
	
	CUR_PAGE = 0;
	CUR_PAGE_UNION = 0;	
	IsInParty = false;
	LevelFilterComboBox.SetSelectedNum( 1 );
}

function OnShow()
{
	PlayConsoleSound(IFST_WINDOW_OPEN);

	PartyMatchHistory_Wnd.HideWindow();	
	DisableCurrentWindow(false);

	PartyMatchListCtrl.ShowScrollBar( false );
	
	//연합매칭방 리스트 요청(1초의 딜레이 후에 패킷을 보낸다)
	UnionMatchListCtrl.DeleteAllItem();
	if ( !getInstanceUIData().getIsArenaServer() ) Me.SetTimer( 1, 1000 );
	callGfxFunction ( "ExpBar", "PartyMatchWndGFxEvent", "state=onShow windowName=PartyMatchWnd");
}

function OnTimer( int TimerID )
{
	if( TimerID == 1 )
	{
		RequestUnionRoomList( 1 );
		Me.KillTimer( 1 );
	}
}

//x버튼을 눌러서 윈도우를 닫으면, 대기자목록에서 빠진다.
function OnSendPacketWhenHiding()
{
	class'PartyMatchAPI'.static.RequestExitPartyMatchingWaitingRoom();
}

function OnHide()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	PartyMatchMakeRoomWnd.HideWindow();
	PartyMatchHistory_Wnd.HideWindow();
	DisableCurrentWindow(false);

	callGfxFunction ( "ExpBar", "PartyMatchWndGFxEvent", "state=onHide");	
}

function OnEvent(int a_EventID, String param)
{
	local PartyMatchMakeRoomWnd Script;
	
	//Debug( "parthMatchWnd" @ a_EventID @ param );

	switch( a_EventID )
	{
		case EV_PartyMatchStart:
			if (CompletelyQuitPartyMatching == 1)
			{
				class'PartyMatchAPI'.static.RequestExitPartyMatchingWaitingRoom();
				Me.HideWindow();
				
				Script = PartyMatchMakeRoomWnd( GetScript( "PartyMatchMakeRoomWnd" ) );
				Script.OnCancelButtonClick();
				
				CompletelyQuitPartyMatching = 0;
				SetWaitListWnd(false);
			}
			else 
			{
				//대기자리스트 업데이트
				UpdateWaitListWnd();
				
				if (Me.IsShowWindow() == false)
				{	
					Me.ShowWindow();
					PartyMatchListCtrl.ShowScrollBar( false );
				}		
				Me.SetFocus();
			}
			break;

		case EV_PartyMatchList:
			HandlePartyMatchList(param);
			break;

		case EV_PartyMatchRoomStart:
			Me.HideWindow();
			break;

		//연합매칭
		case EV_ListMpccWaitingStart:
			HandleListMpccWaitingStart( param );
			break;

		case EV_ListMpccWaitingRoomInfo:
			HandleListMpccWaitingRoomInfo( param );
			break;

		case EV_UsePartyMatchAction:
			HandlePartyToggle();		
			break;

		case EV_Restart:
			SetIsInParty(false);
			//선준 수정(2010.03.31) 완료
			bOpenStateLobby = false;
			break;	

		case EV_PartyMatchingRoomHistory :
			updatePartyMatchingRoomHistory(param);
			
			break;
	}
}

// 파티 목록 히스토리 갱신 
function updatePartyMatchingRoomHistory(string param)
{
	local int i, count;
	local string masterName, roomName;
	local LVDataRecord Record;

	Debug("파티 히스토리 " @ param);

	WaitList_ListCtrl.DeleteAllItem();
	//선준 수정(2010.02.22 ~ 03.08) 완료
	Record.LVDataList.length = 2;

	ParseInt(param, "Count", count);
	
	for( i = 0; i < count; i++ )
	{
		roomName = "";
		masterName = "";

		ParseString(param, "MasterName_" $ i, masterName);		
		ParseString(param, "RoomName_" $ i, roomName);			

		// 방제목, 파티장 이름
		Record.LVDataList[0].szData = roomName;
		Record.LVDataList[1].szData = masterName;

		WaitList_ListCtrl.InsertRecord( Record );
	}
}

function OnMinimize()
{
	callGfxFunction ( "ExpBar", "PartyMatchWndGFxEvent", "state=onMinimize");	
}


function HandlePartyToggle(){//파티창을 열고닫는 모든 커맨드. 아이콘. 숏컷. 액션사용. /파티매칭 입력시 이 함수가 호출된다. jdh84
							
	local WindowHandle TaskWnd;
	local WindowHandle TaskWnd2;
	local PartyMatchRoomWnd p2_script;

	TaskWnd=GetWindowHandle( "PartyMatchWnd" );
	TaskWnd2=GetWindowHandle( "PartyMatchRoomWnd" );
	p2_script = PartyMatchRoomWnd( GetScript( "PartyMatchRoomWnd" ) );
	
	if (TaskWnd.IsShowWindow()) //파티매치 창이 열려있다면
	{
		ClosePartyMatchingWnd(); //닫는다
	}
	else if(TaskWnd2.IsShowWindow()) //파티방이 열려있다면
	{
		TaskWnd2.HideWindow(); //닫는다
		p2_script.OnSendPacketWhenHiding();
	}
	else if ( class'UIAPI_WINDOW'.static.IsMinimizedWindow( "PartyMatchRoomWnd" ) ) //파티방이 미니마이즈 상태라면
	{
		TaskWnd2.ShowWindow();//파티방을 연다.
	}
	else
	{
		RequestPartyRoomListLocal( 1 ); //열린게 없을 경우에는 정보를 요청한다. 파티매치가 미니마이즈 돼 있을 경우에도 그렇게 한다.
	}
}



function ClosePartyMatchingWnd()//파티창을 
{
	local WindowHandle TaskWnd;
	local PartyMatchWnd p_script;
	p_script = PartyMatchWnd( GetScript( "PartyMatchWnd" ) );

	
	TaskWnd = GetWindowHandle("PartyMatchWnd");

	TaskWnd.HideWindow();
	p_script.OnSendPacketWhenHiding();
}

//5초가 지나면 버튼들의 Disable상태가 풀린다
function OnButtonTimer( bool bExpired )
{
	if (bExpired)
	{
		PrevBtn.EnableWindow();
		NextBtn.EnableWindow();
		AutoJoinBtn.EnableWindow();
		RefreshBtn.EnableWindow();
	}
	else
	{
		PrevBtn.DisableWindow();
		NextBtn.DisableWindow();
		AutoJoinBtn.DisableWindow();
		RefreshBtn.DisableWindow();
	}
}

function HandlePartyMatchList(string param)
{
	local int Count;
	local int i;
	local LVDataRecord Record;
	local int Number;
	local String PartyRoomName;
	local String PartyLeader;	
	local int MinLevel;
	local int MaxLevel;
	local int MinMemberCnt;
	local int MaxMemberCnt;

	//선준 수정(2010.02.22 ~ 03.08) 완료
	local int j;
	local int MemberCnt;
	local int MemberClassID;
	local string MemberName;
	local LVData data1;

	// 파티 매칭중인 맴버, 파티수 등 보여주는 것 추가 (2015-10-26)
	local int totalPartyMemberCount;
	local int totalPartyCount;

	// Debug("::----> HandlePartyMatchList: " @ param);

	ParseInt(param, "TotalPartyCount", totalPartyCount);
	ParseInt(param, "TotalPartyMemberCount", totalPartyMemberCount);

	// 활동중인 파티 정보 출력

	ActivityParty_Text.SetText(MakeFullSystemMsg( GetSystemMessage(1983), String(totalPartyCount)));
	ActivityPartyMember_Text.SetText(MakeFullSystemMsg( GetSystemMessage(3305), String(totalPartyMemberCount)));

	PartyMatchListCtrl.DeleteAllItem();
	//선준 수정(2010.02.22 ~ 03.08) 완료
	Record.LVDataList.length = 7 + ( MAXMEMBER / 2 );

	ParseInt(param, "PageNum", CUR_PAGE);
	ParseInt(param, "RoomCount", Count);
	for( i = 0; i < Count; ++i )
	{
		ParseInt(param, "RoomNum_" $ i, Number);
		ParseString(param, "Leader_" $ i, PartyLeader);		
		ParseInt(param, "MinLevel_" $ i, MinLevel);
		ParseInt(param, "MaxLevel_" $ i, MaxLevel);
		ParseInt(param, "CurMember_" $ i, MinMemberCnt);
		ParseInt(param, "MaxMember_" $ i, MaxMemberCnt);

		if ( !getInstanceUIData().getIsClassicServer() )
		{
			// 맥스 레벨 이상인 경우 getInstanceUIData().MAXLV2DISPLAY 로 보여 짐
			if ( MaxLevel == getInstanceUIData().MAXLV ) MaxLevel = getInstanceUIData().MAXLV2DISPLAY;
			if ( MinLevel == getInstanceUIData().MAXLV ) MinLevel = getInstanceUIData().MAXLV2DISPLAY;
			// getInstanceUIData().MAXLV2DISPLAY 이상인 경우 getInstanceUIData().MAXLV2DISPLAY 로 보여짐
			//if ( MaxLevel > getInstanceUIData().MAXLV2DISPLAY ) MaxLevel = getInstanceUIData().MAXLV2DISPLAY;
			//if ( MinLevel > getInstanceUIData().MAXLV2DISPLAY ) MinLevel = getInstanceUIData().MAXLV2DISPLAY;
		}	
		
		
		//Debug("HandlePartyMatchList MaxLevel" @ MaxLevel );


		ParseString(param, "RoomName_" $ i, PartyRoomName);
		ParseInt(param, "MemberCnt_" $ i, MemberCnt);

		Record.LVDataList[0].szData = String( Number );
		Record.LVDataList[1].szData = PartyLeader;
		Record.LVDataList[2].szData = PartyRoomName;		
		Record.LVDataList[3].szData = MinLevel $ "-" $ MaxLevel;
		Record.LVDataList[4].szData = MinMemberCnt $ "/" $ MaxMemberCnt;
		Record.LVDataList[5].szData = string( MemberCnt );

		//선준 수정(2010.02.22 ~ 03.08) 완료
		for( j = 0 ; j < MemberCnt ; ++j )
		{
			ParseString(param, "MemberName_" $ i $ "_" $ j, MemberName );			
			ParseInt(param, "MemberClassID_" $ i $ "_" $ j, MemberClassID );

			//debug( "[" $ i $ "]" $ "[" $ j $ "]==" $ MemberName );
			//debug( "[" $ i $ "]" $ "[" $ j $ "]==" $ MemberClassID );			
			
			data1.nReserved1 = MemberClassID;
			data1.szData = MemberName;

			Record.LVDataList[ 7 + j ] = data1;
		}

		PartyMatchListCtrl.InsertRecord( Record );
	}


}

/** 
 * 현재 윈도우를 비활성화 한다.
 * 윈도우 최상단에 큰 윈도우를 두고 그걸로 아래 있는 요소들이 클릭등이 안되도록 한다.
 **/
function DisableCurrentWindow(bool bFlag)
{
	DisableWnd.DisableWindow();
	// disableCurrentWindowFlag = bFlag; 
	if (bFlag)
	{		
		//DisableWnd.SetFocus();		
		DisableWnd.ShowWindow();
	}
	else 
	{		
		DisableWnd.HideWindow();
	}
}

function OnClickButton( string a_strButtonName )
{
	//Debug("a_strButtonName" @ a_strButtonName);
	switch( a_strButtonName )
	{
		case "RefreshBtn":
			OnRefreshBtnClick();
			break;

		case "PrevBtn":
			OnPrevBtnClick();
			break;

		case "NextBtn":
			OnNextBtnClick();
			break;

		case "MakeRoomBtn":
			OnMakeRoomBtnClick();
			break;

		case "AutoJoinBtn":
			OnAutoJoinBtnClick();
			break;

		case "WaitListButton":
			OnWaitListButton();
			break;

		//연합매칭
		case "UnionRefreshBtn":
			OnUnionRefreshBtn();
			break;

		case "UnionPrevBtn":
			OnUnionPrevBtn();
			break;

		case "UnionNextBtn":
			OnUnionNextBtn();
			break;

		case "PartyMatchHistory_Btn":
			// 대기자 보기 창이 열려 있다면 닫기
			if(GetWindowHandle("PartyMatchWaitListWnd").IsShowWindow())
			{
				SetWaitListWnd(false);
				ShowHideWaitListWnd();
			}

			DisableCurrentWindow(true);
			PartyMatchHistory_Wnd.ShowWindow();
			PartyMatchHistory_Wnd.SetFocus();
			Debug("Call --> RequestPartyMatchingHistory()");
			class'PartyMatchAPI'.static.RequestPartyMatchingHistory();
			break;

		// 히스토리 창, 닫기 버튼	
		case "CloseButton" :
		case "Close_Btn" :
			PartyMatchHistory_Wnd.HideWindow();
			DisableCurrentWindow(false);
			break;

		case "Refresh_Btn" :
			Debug("Call --> RequestPartyMatchingHistory()");
			class'PartyMatchAPI'.static.RequestPartyMatchingHistory();
			break;
	}
}

function OnWaitListButton()
{
	ToggleWaitListWnd();
	UpdateWaitListWnd();
}

function OnRefreshBtnClick()
{
	RequestPartyRoomListLocal( 1 );
}
 
function OnPrevBtnClick()
{
	local int WantedPageNum;

	if( 1 >= CUR_PAGE )
		WantedPageNum = 1;
	else
		WantedPageNum = CUR_PAGE - 1;

	RequestPartyRoomListLocal( WantedPageNum );
}

function OnNextBtnClick()
{
	RequestPartyRoomListLocal( CUR_PAGE + 1 );	
}

function RequestPartyRoomListLocal( int a_Page )
{
	class'PartyMatchAPI'.static.RequestPartyRoomList( a_Page, GetLocationFilter(), GetLevelFilter() );
}

function OnMakeRoomBtnClick()
{
	local PartyMatchMakeRoomWnd Script;
	local UserInfo PlayerInfo;

	local int MAX_Level;

	if ( getInstanceUIData().getIsClassicServer() ) 
	{
		MAX_Level = getInstanceUIData().MAXLV;
	}else 
	{
		MAX_Level = getInstanceUIData().MAXLV2DISPLAY;
	}

	Script = PartyMatchMakeRoomWnd( GetScript( "PartyMatchMakeRoomWnd" ) );
	if( Script != None )
	{
		Script.SetRoomNumber( 0 );
		Script.SetTitle( GetSystemMessage( 1398 ) );
		Script.SetMaxPartyMemberCount( 12 );
		if( GetPlayerInfo( PlayerInfo ) )
		{
			if( PlayerInfo.nLevel - 5 > 0 )
				Script.SetMinLevel( PlayerInfo.nLevel - 5 );
			else
				Script.SetMinLevel( 1 );

			if( PlayerInfo.nLevel + 5 <= MAX_Level )
				Script.SetMaxLevel( PlayerInfo.nLevel + 5 );
			else
				Script.SetMaxLevel( MAX_Level );
		}		
	}
	script.InviteState = Script.InviteStateType.MAKEROOM;
	
	PartyMatchMakeRoomWnd.ShowWindow();
	PartyMatchMakeRoomWnd.SetFocus();
}

function OnDBClickListCtrlRecord( String a_ListCtrlName )
{
	local int SelectedRecordIndex;
	local LVDataRecord Record;	

	if( a_ListCtrlName == "PartyMatchListCtrl" )
	{
		SelectedRecordIndex = PartyMatchListCtrl.GetSelectedIndex();
		PartyMatchListCtrl.GetRec(SelectedRecordIndex, Record);
		class'PartyMatchAPI'.static.RequestJoinPartyRoom( int( Record.LVDataList[0].szData ) );	
	}
	else if( a_ListCtrlName == "UnionMatchListCtrl" )
	{
		SelectedRecordIndex = UnionMatchListCtrl.GetSelectedIndex();
		UnionMatchListCtrl.GetRec(SelectedRecordIndex, Record);
		class'PartyMatchAPI'.static.RequestJoinMpccRoom( int( Record.LVDataList[0].szData ), 0 );	
	}
	return;
}

function OnAutoJoinBtnClick()
{
	class'PartyMatchAPI'.static.RequestJoinPartyRoomAuto( CUR_PAGE, GetLocationFilter(), GetLevelFilter() );
}


//20140309 위치 정보 정보가 삭제 됨
function int GetLocationFilter()
{
	/*
	* -1 일 경우 전체를 받는다.
	* -2 는 내 주위
	* 나머지 숫자는 zoneID 임.
	*/
	return -1;
}


function int GetLevelFilter()
{
	return LevelFilterComboBox.GetSelectedNum();
}

/////////////////////////////////////////////////////////////////////////////////
////// 대기자 리스트 관련 공통 함수
////// WaitListWnd는 2개가 있는데, Show/Hide의 설정을 한곳에서 관리하기 위함
/////////////////////////////////////////////////////////////////////////////////

//대기자리스트 Flag설정
function SetWaitListWnd(bool bShow)
{
	bOpenStateLobby = bShow;
}

//대기자리스트 표시
function ShowHideWaitListWnd()
{
	
	if (bOpenStateLobby)
	{
	
		PartyMatchOutWaitListWnd.ShowWindow();
		PartyMatchWaitListWnd.ShowWindow();
	}
	else 
	{
	
		PartyMatchOutWaitListWnd.HideWindow();
		PartyMatchWaitListWnd.HideWindow();
	}
}

//대기자리스트 업데이트
function UpdateWaitListWnd()
{
	local int MinLevel;
	local int MaxLevel;
	local string strName;

	if (IsShowWaitListWnd())
	{
		MinLevel = int(PartyMatchOutWaitListWnd_MinLevel.GetString());
		MaxLevel = int(PartyMatchOutWaitListWnd_MaxLevel.GetString());
		
		//선준 수정(2010.02.22 ~ 03.08) 완료
		strName = PartyMatchOutWaitListWnd_Name.GetString();
		RequestPartyMatchWaitList( 1, MinLevel, MaxLevel, JobFilterComboBox.GetSelectedNum(), strName );
	}	
}

//대기자리스트 토글
function ToggleWaitListWnd()
{
	bOpenStateLobby = !bOpenStateLobby;	
	ShowHideWaitListWnd();
}

function bool IsShowWaitListWnd()
{
	return bOpenStateLobby;
}

////////////////////////////////////////////////////
// 연합매칭 2009.3.17 ttmayrin /////////////////////
////////////////////////////////////////////////////
function HandleListMpccWaitingStart( string param )
{
	local int listCount;
	
	ParseInt(param, "Page", CUR_PAGE_UNION);
	ParseInt(param, "listCount", listCount);
	
	UnionMatchListCtrl.DeleteAllItem();
	
	if( CUR_PAGE_UNION > 1 )
		UnionPrevBtn.EnableWindow();
	if( listCount > 0 )
		UnionNextBtn.EnableWindow();
}
function HandleListMpccWaitingRoomInfo( string param )
{
	local LVDataRecord Record;
	local int RoomNum;
	local String Title;
	local String MasterName;
	local int MinLevelLimit;
	local int MaxLevelLimit;
	local int CurrentJoinMemberCnt;
	local int MaxMemberLimit;
		
	Record.LVDataList.length = 5;
	ParseInt(param, "RoomNum", RoomNum);
	ParseString(param, "Title", Title);
	ParseString(param, "MasterName", MasterName);
	ParseInt(param, "MinLevelLimit", MinLevelLimit);
	ParseInt(param, "MaxLevelLimit", MaxLevelLimit);
	ParseInt(param, "CurrentJoinMemberCnt", CurrentJoinMemberCnt);
	ParseInt(param, "MaxMemberLimit", MaxMemberLimit);
	
	Record.LVDataList[0].szData = String( RoomNum );
	Record.LVDataList[1].szData = Title;
	Record.LVDataList[2].szData = MasterName;
	Record.LVDataList[3].szData = MinLevelLimit $ "-" $ MaxLevelLimit;
	Record.LVDataList[4].szData = CurrentJoinMemberCnt $ "/" $ MaxMemberLimit;

	UnionMatchListCtrl.InsertRecord( Record );
}

function OnUnionRefreshBtn()
{
	RequestUnionRoomList( 1 );
}
 
function OnUnionPrevBtn()
{
	local int WantedPageNum;

	if( 1 >= CUR_PAGE_UNION )
		WantedPageNum = 1;
	else
		WantedPageNum = CUR_PAGE_UNION - 1;

	RequestUnionRoomList( WantedPageNum );
}

function OnUnionNextBtn()
{
	RequestUnionRoomList( CUR_PAGE_UNION + 1 );	
}

function RequestUnionRoomList( int a_Page )
{
	UnionPrevBtn.DisableWindow();
	UnionNextBtn.DisableWindow();
	class'PartyMatchAPI'.static.RequestListMpccWaiting( a_Page, GetLocationFilter(), GetLevelFilter() );
}


/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( m_WindowName ).HideWindow();
}

defaultproperties
{
    m_WindowName="PartyMatchWnd"
}
