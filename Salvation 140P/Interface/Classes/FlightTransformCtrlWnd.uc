class FlightTransformCtrlWnd extends UIScript;

// 디파인
const MAX_ShortcutPerPage = 12;	// 12칸의 숏컷을 지원한다. 
const FTShortcutPage = 20;		// 비행변신체는 10번 페이지를 사용한다.  //branch EP3.0 2016.7.27 luciper3 - 일본 요청으로 페이지 10 -> 20 으로 변경

const SelectTex_X = 1;
const SelectTex_Y = 1;

const FT_TIME = 45000;	// 시스템 튜토리얼이 랜덤하게 보이는 시간	//45초에 1회씩
const FT_TIME1 = 1000;	// 고도는 1초에 한번씩 갱신한다. 

const FT_TIMER_ID = 150;	// 타이머 아이디
const FT_TIMER_ID1 = 152;	// 타이머 아이디 // 151은 radarmap 에 있다. -_-;;?

// 전역 변수
var WindowHandle Me;
var WindowHandle ShortcutWnd;

//var RadarMapWnd scriptRadarMapWnd;	// 레이더 스크립트 가져오기

//var	CheckBoxHandle 	Chk_EnterChatting;	//shortcut assign wnd의 엔터채팅 모드 체크박스.
//var	CheckBoxHandle 	Chk_EnterChatting1;	//shortcut assign wnd의 엔터채팅 모드 체크박스.

var	ButtonHandle	LockBtn;			// 잠금 버튼
var	ButtonHandle	UnlockBtn;			// 잠금 해제 버튼
var	ButtonHandle	JoypadBtn;			// 조이패드

var	TextureHandle	SelectTex;			// 선택된 아이템을 알려주는 텍스쳐

var  ShortcutWnd 	scriptShortcutWnd;	

var	int i;							//루프 돌릴때 사용하는 변수
var	bool 		preEnterChattingOption;

var	bool isNowActiveFlightTransShortcut;	// 현재 변신체모드인지를 저장한다. 향상된 세이더같이 게임중 로딩이 나올 수 있으므로.

var 	bool m_IsLocked;	// 숏컷 잠금 변수
var	int preSlot;			// 이전에 활성화된 슬롯을 저장해둔다.

// 이벤트 등록
function OnRegisterEvent()
{
	RegisterEvent( EV_FlightTransform );
	
	RegisterEvent( EV_ShortcutUpdate );
	RegisterEvent( EV_ShortcutClear );
	RegisterEvent( EV_ShortcutPageUpdate );
	RegisterEvent( EV_ShortcutCommandSlot );	//숏컷 이벤트
	RegisterEvent( EV_ReserveShortCut);		// 예약된 숏컷 이벤트
	
	registerEvent( EV_GamingStateExit );	// 리스타트 할 경우
}

function OnLoad()
{
	
	Me = GetWindowHandle( "FlightTransformCtrlWnd" );
	ShortcutWnd = GetWindowHandle( "ShortcutWnd" );
	//엔터 채팅용.
	//Chk_EnterChatting	    =	GetCheckBoxHandle( "ShortcutAssignWnd.Chk_EnterChatting" );
	//Chk_EnterChatting1	    =	GetCheckBoxHandle( "ShortcutAssignWnd.Chk_EnterChatting1" );

	SelectTex = GetTextureHandle( "FlightTransformCtrlWnd.SelectTex");		
	LockBtn = GetButtonHandle ( "FlightTransformCtrlWnd.FlightShortCut.LockBtn");
	UnlockBtn = GetButtonHandle ( "FlightTransformCtrlWnd.FlightShortCut.UnlockBtn");
	JoypadBtn = GetButtonHandle ( "FlightTransformCtrlWnd.FlightShortCut.JoypadBtn");		
	
	// scriptRadarMapWnd = RadarMapWnd( GetScript("RadarMapWnd") );
	scriptShortcutWnd = ShortcutWnd( GetScript("ShortcutWnd") );	
	JoypadBtn.HideWindow();
	isNowActiveFlightTransShortcut = false;
	preSlot = -1;
	updateLockButton();	// 잠금 상태를 업데이트 한다. 
	ShortCutUpdateAll();
}

function updateLockButton()
{
	/*
	local int tmpInt;
	GetINIInt ( "ShortcutWnd", "l",  tmpInt, "WindowsInfo.ini");
	m_IsLocked = bool ( tmpInt );
*/
	m_IsLocked = GetOptionBool( "Game", "IsLockShortcutWnd" );
	if(m_IsLocked)
	{
		if(!LockBtn.isShowwindow()) LockBtn.ShowWindow();
		if(UnlockBtn.isShowwindow()) UnlockBtn.HideWindow();
	}
	else
	{
		if(LockBtn.isShowwindow()) LockBtn.HideWindow();
		if(!UnlockBtn.isShowwindow()) UnlockBtn.ShowWindow();
	}
	scriptShortcutWnd.ArrangeWnd();
}

function OnClickButton( String strID )
{
	switch( strID )
	{
	case "LockBtn":
		m_IsLocked = false;		
		//SetINIInt ( "ShortcutWnd", "l",  0, "WindowsInfo.ini");	
		SetOptionBool( "Game", "IsLockShortcutWnd", false );
		updateLockButton();
		break;
	case "UnlockBtn":
		m_IsLocked = true;
		//SetINIInt ( "ShortcutWnd", "l",  1, "WindowsInfo.ini");	
		SetOptionBool( "Game", "IsLockShortcutWnd", true );
		updateLockButton();
		break;
	}
}

//쉐이더 빌더 스테이트 삭제로 쓰임이 없어짐
/*
function OnEnterState( name a_PreStateName )
{
	
	if(isNowActiveFlightTransShortcut)	// 조종모드였었다면
	{
		if( a_PreStateName == 'ShaderBuildState')
		{			
			if(!Me.isShowwindow()) Me.ShowWindow();					//전용 숏컷으로 변경
			if(ShortcutWnd.isShowwindow()) ShortcutWnd.HideWindow();
			
			Me.SetTimer( FT_TIMER_ID1, FT_TIME1 );	// 고도를 가져오는 타이머를 켠다.			
			if(!scriptRadarMapWnd.FlightStatusAltitude.isShowWindow()) scriptRadarMapWnd.FlightStatusAltitude.ShowWindow();		//고도 보여주기	
		}
	}

}*/

function OnExitState( name a_NextStateName )
{
	//local OptionWnd win;	
	//win = OptionWnd( GetScript("OptionWnd") );
		
	////쉐이더 빌더 스테이트 삭제로 쓰임이 없어짐
	///*
	//if( a_NextStateName != 'ShaderBuildState')	// 쉐이더 상테로 나갈 경우가 아니라면,  체크박스의 디스에이블을 풀어준다. 
	//{
	
	//}*/
	//win.dispatchEventToFlash_Int(200, 3); //디서블 해제

	CallGFxFunction( "OptionWnd", "onSwitchDisableEnterChatting", string ( false ) ) ;
}

// 이벤트 처리
function OnEvent( int a_EventID, String a_Param )
{
	switch( a_EventID )
	{
	case EV_FlightTransform:
		OnFlightTransformState( a_Param );
		break;
	case EV_ShortcutCommandSlot:
		ExecuteShortcutCommandBySlot(a_Param);	// 단축키 실행 이벤트
		break;
	case EV_ReserveShortCut:
		OnReserveShortCut( a_Param );
		break;
	case EV_GamingStateExit:
		Me.KillTimer( FT_TIMER_ID );				// 타이머를 죽여준다.
		Me.KillTimer( FT_TIMER_ID1 );		
		// if(scriptRadarMapWnd.FlightStatusAltitude.isShowWindow()) scriptRadarMapWnd.FlightStatusAltitude.HideWindow();		//고도 숨김
		break;
	case EV_ShortcutUpdate:
		HandleShortcutUpdate( a_Param );
		break;
	case EV_ShortcutPageUpdate:	// 페이지가 없기 때문에 전체를 업데이트 한다.
		ShortCutUpdateAll();
		break;
	case EV_ShortcutClear:
		HandleShortcutClear();
		updateLockButton();
		break;
	default:
		break;
	}
}

// 온타이머 이벤트!
function OnTimer(int TimerID)
{
	local vector MyPosition;
	if(TimerID == FT_TIMER_ID)
	{
		if(!GetOptionBool( "ScreenInfo", "SystemTutorialBox" ))	// 시스템 튜토리얼 체크박스를 확인해 주어야 한다. 
		{	
			ShowAirTutorial(-1);	// 시스템 메세지 랜덤 추가
		}
		else
		{
			Me.KillTimer( FT_TIMER_ID );	// 타이머를 죽여준다.
		}
	}
	else if(TimerID == FT_TIMER_ID1)	// 고도를 갱신해주는 타이머.
	{
		MyPosition = GetPlayerPosition();	// 내 위치 갱신
		
		// scriptRadarMapWnd.updateAltitudeTex( MyPosition.z );
	}
}


function OnFlightTransformState( string a_Param )
{	
	local int       IsFlying;
	//local MainMenu	scriptMain;
	//local OptionWnd scriptOptionWnd;	
	
	//scriptOptionWnd = OptionWnd( GetScript("OptionWnd") );
	//scriptMain = MainMenu ( GetScript("MainMenu") );
	
	ParseInt( a_Param, "IsFly", IsFlying );
	
	//debug ("EV_FlightTransform : " $ IsFlying);
	
	if(IsFlying > 0)	// 비행 상태
	{		
		if(!GetOptionBool( "ScreenInfo", "SystemTutorialBox" ))
		{
			ShowAirTutorial(2493);	// 시스템 메세지로 간단히 설명해준다.
			ShowAirTutorial(2495);
			// 여기서 타이머를 켠다.
			Me.SetTimer( FT_TIMER_ID,FT_TIME );
		}	
		
		Me.SetTimer( FT_TIMER_ID1, FT_TIME1 );	// 고도를 가져오는 타이머를 켠다.
		//if(!scriptRadarMapWnd.FlightStatusAltitude.isShowWindow()) scriptRadarMapWnd.FlightStatusAltitude.ShowWindow();		//고도 보여주기			
		
		preEnterChattingOption = GetChatFilterBool ( "Global", "EnterChatting");		
		SetChatFilterBool ( "Global", "EnterChatting", true);		
		//preEnterChattingOption = GetOptionBool("CommunIcation", "EnterChatting");		//기존 엔터채팅 옵션을 저장해둔다. 		
		//SetOptionBool( "CommunIcation", "EnterChatting", true );	//강제 엔터 채팅

		//scriptOptionWnd.dispatchEventToFlash_Int(200, 1); //체크
		//scriptOptionWnd.dispatchEventToFlash_Int(200, 2); //디서블
		Debug ( "OnFlightTransformState true"  ) ;
		CallGFxFunction( "OptionWnd", "onSwitchEnterChatting", String ( true ) );		
		CallGFxFunction( "OptionWnd", "onSwitchDisableEnterChatting", String ( true ) );		
		
		updateLockButton();	// 잠금 상태를 업데이트 한다. 
		class'ShortcutAPI'.static.ActivateGroup("FlightTransformShortcut");	//숏컷 그룹 지정		
		//scriptMain.changeEnterChat( "FlightTransformShortcut" );
		if(!Me.isShowwindow()) 
		{
			Me.ShowWindow();					//전용 숏컷으로 변경
			ShortcutWnd.HideWindow();
		}
		
		isNowActiveFlightTransShortcut = true;
	}
	else	// 비행 상태 해제
	{
		//if(scriptRadarMapWnd.FlightStatusAltitude.isShowWindow()) scriptRadarMapWnd.FlightStatusAltitude.HideWindow();		//고도 숨김
			
		Me.KillTimer( FT_TIMER_ID );	// 타이머를 죽여준다.
		Me.KillTimer( FT_TIMER_ID1 );
		
		//scriptOptionWnd.dispatchEventToFlash_Int(200, 3); //디서블해제		
		CallGFxFunction( "OptionWnd", "onSwitchDisableEnterChatting", String ( false ) );		
		
		class'ShortcutAPI'.static.DeactivateGroup("FlightTransformShortcut"); // 숏컷 그룹 해제
		
		//SetOptionBool( "CommunIcation", "EnterChatting", preEnterChattingOption );	//백업해둔 엔터채팅 옵션을 다시 넣어준다.	
		SetChatFilterBool ( "Global", "EnterChatting", preEnterChattingOption);			
		if(preEnterChattingOption)	// 변신전 백업 상태에 따라 엔터 채팅을 활성화 해준다.			
		{			
			class'ShortcutAPI'.static.ActivateGroup("TempStateShortcut");
			//scriptMain.changeEnterChat( "TempStateShortcut" );
		}
		//else
		//{
		//	scriptMain.changeEnterChat( "GamingStateShortcut" );
		//}

		CallGFxFunction ( "Menu", "onSetShortcut", "");
		CallGFxFunction ( "MenuWnd", "onSetShortcut", "");

		Debug ( "OnFlightTransformState" @ preEnterChattingOption ) ;
		CallGFxFunction( "OptionWnd", "onSwitchEnterChatting", String ( preEnterChattingOption ) );		
		
		//if (preEnterChattingOption ) 
		//{
		//	scriptOptionWnd.dispatchEventToFlash_Int(200, 1); //체크 엔터 채팅 체크
		//}
		//else 
		//{
		//	scriptOptionWnd.dispatchEventToFlash_Int(200, 0); //체크 엔터 채팅 체크
		//}
		//Chk_EnterChatting.SetCheck(preEnterChattingOption);	
		//Chk_EnterChatting1.SetCheck(preEnterChattingOption);	
		
		if(Me.isShowwindow())	
		{
			Me.HideWindow();					// 원래 숏컷으로 돌려놓음
			ShortcutWnd.ShowWindow();
		}
		
		isNowActiveFlightTransShortcut = false;
	}
}

function ShortCutUpdateAll()
{
	local int nShortcutID;
	
	nShortcutID = MAX_ShortcutPerPage * FTShortcutPage;
	
	for( i = 0; i < MAX_ShortcutPerPage; ++i )
	{
		class'UIAPI_SHORTCUTITEMWINDOW'.static.UpdateShortcut( "FlightTransformCtrlWnd.FlightShortCut.Shortcut" $ ( i + 1 ), nShortcutID );
		nShortcutID++;
	}
}


// 숏컷 업데이트
function HandleShortcutUpdate(string param)
{
	local int nShortcutID;
	local int nShortcutNum;
	
	ParseInt(param, "ShortcutID", nShortcutID);
	nShortcutNum = ( nShortcutID - MAX_ShortcutPerPage * FTShortcutPage) + 1;
	
	if((nShortcutNum > 0 ) && ( nShortcutNum  < MAX_ShortcutPerPage + 1 ))	// 비행숏컷일 경우에만  업데이트
	{
		class'UIAPI_SHORTCUTITEMWINDOW'.static.UpdateShortcut( "FlightTransformCtrlWnd.FlightShortCut.Shortcut" $ nShortcutNum, nShortcutID );
		
	}
}

 //숏컷 클리어
function HandleShortcutClear()
{		
	for( i = 0; i < MAX_ShortcutPerPage; ++i )
	{
		class'UIAPI_SHORTCUTITEMWINDOW'.static.clear( "FlightTransformCtrlWnd.FlightShortCut.Shortcut" $ ( i + 1 ) );
	}
}

function HandleShortcutPageUpdate(string param)	// 페이지 업데이트
{
	//~ local int i;
	//~ local int nShortcutID;
	local int ShortcutPage;
	
	if( ParseInt(param, "ShortcutPage", ShortcutPage) )
	{
		debug ("----------------ShortcutPage " $ ShortcutPage);
		if( ShortcutPage == FTShortcutPage)	ShortCutUpdateAll();
	}
}

function ExecuteShortcutCommandBySlot( string a_Param )
{
	local int slot;
	local int slotFromOne;
	ParseInt(a_Param, "Slot", slot);
	
	// 120번부터 131번까지의 슬롯이 들어오면 실행해준다. 
	if( (slot >= MAX_ShortcutPerPage * FTShortcutPage) && ( slot < MAX_ShortcutPerPage * (FTShortcutPage + 1)))
	{	
		slotFromOne = slot - MAX_ShortcutPerPage * FTShortcutPage + 1;
		class'ShortcutAPI'.static.ExecuteShortcutBySlot(slot);
		SelectTex.SetAnchor( "FlightTransformCtrlWnd.F" $ slotFromOne $ "Tex" , "TopLeft", "TopLeft", SelectTex_X, SelectTex_Y );
	}
}

function OnReserveShortCut( string a_Param )
{
	local int slot;
	local int slotFromOne;
	ParseInt(a_Param, "Slot", slot);
	
	// 120번부터 131번까지의 슬롯이 들어오면 실행해준다. 
	if( (slot >= MAX_ShortcutPerPage * FTShortcutPage) && ( slot < MAX_ShortcutPerPage * (FTShortcutPage + 1)))
	{	
		slotFromOne = slot - MAX_ShortcutPerPage * FTShortcutPage + 1;
		SelectTex.SetAnchor( "FlightTransformCtrlWnd.F" $ slotFromOne $ "Tex" , "TopLeft", "TopLeft", SelectTex_X, SelectTex_Y );
		
		if( preSlot == slotFromOne )	// 이미 선택된 상태에서 한번 더 누르면 실행된다.
		{
			class'ShortcutAPI'.static.ExecuteShortcutBySlot(slot);
		}
		else
		{
			preSlot = slotFromOne;
		}
	}
}

function ShowAirTutorial( int SystemMsgID)
{
	local int RandVal;
	local int RandSystemMsgID;
	
	if(SystemMsgID < 0)	// 0보다 작으면 랜덤한 시스템 메세지를 보여준다. 
	{
		RandVal = Rand(4);
		
		RandSystemMsgID = 2493;	// 만약을 위해 디폴트값 -_-
		
		switch(RandVal)
		{
			case 0:	RandSystemMsgID = 2493;		break;		// 각각의 시스템 메세지 아이디를 적어준다
			case 1:	RandSystemMsgID = 2495;		break;
			case 2:	RandSystemMsgID = 2496;		break;
			case 3:	RandSystemMsgID = 2497;		break;
		}
	}
	else
	{
		RandSystemMsgID = SystemMsgID;
	}
	
	if(!GetOptionBool( "ScreenInfo", "SystemTutorialBox" ))	// 시스템 튜토리얼 체크박스를 확인해 주어야 한다. 
	{	
		AddSystemMessage(RandSystemMsgID);	// 시스템 메세지 추가
	}
	else
	{
		Me.KillTimer( FT_TIMER_ID );	// 타이머를 죽여준다.
	}
}
defaultproperties
{
}
