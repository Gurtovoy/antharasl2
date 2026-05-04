class FlightShipCtrlWnd extends UIScript;

// 디파인
const MAX_ShortcutPerPage = 12;	// 12칸의 숏컷을 지원한다.  //branch EP3.0 2016.7.27 luciper3 - 일본 요청으로 페이지 10 -> 20 으로 변경
const FSShortcutPage = 21;		// 비행정은 11번 페이지를 사용한다. 
const Relative_Altitude = 4000;	// 실 좌표계에 +a 하는 값

const SelectTex_X = 1;
const SelectTex_Y = 1;

// 전역 변수
var WindowHandle Me;
var WindowHandle ShortcutWnd;

//var	CheckBoxHandle 	Chk_EnterChatting;	//shortcut assign wnd의 엔터채팅 모드 체크박스.
//var	CheckBoxHandle 	Chk_EnterChatting1;	//shortcut assign wnd의 엔터채팅 모드 체크박스.

var	TextBoxHandle	AltitudeTxt;		//고도 텍스트박스
var	TextureHandle	SelectTex;			// 선택된 아이템을 알려주는 텍스쳐

var	ButtonHandle	UpButton;			// 고도 상승
var	ButtonHandle	DownButton;		// 고도 하강?
var	ButtonHandle	LockBtn;			// 잠금 버튼
var	ButtonHandle	UnlockBtn;			// 잠금 해제 버튼
var	ButtonHandle	JoypadBtn;			// 조이패드

//채팅 창 리뉴얼 20120905
//채팅 롤백
var 	EditBoxHandle ChatEditBox;			// 채팅 에디트 박스

var  	ShortcutWnd 	scriptShortcutWnd;		

var	int i;							//루프 돌릴때 사용하는 변수

var	bool 		preEnterChattingOption;

var 	bool m_IsLocked;	// 숏컷 잠금 변수

var	bool	m_preDriver;	// 이전 상태에서 드라이버였는지를 저장한다.

var	bool isNowActiveFlightShipShortcut;	// 현재 조종모드인지를 저장한다. 향상된 세이더같이 게임중 로딩이 나올 수 있으므로.

var	int preSlot;			// 이전에 활성화된 슬롯을 저장해둔다.

// 이벤트 등록
function OnRegisterEvent()
{
	RegisterEvent( EV_AirShipState );
	RegisterEvent( EV_AirShipAltitude);
	
	RegisterEvent( EV_ShortcutCommandSlot );	//숏컷 이벤트
	RegisterEvent( EV_ReserveShortCut);		// 예약된 숏컷 이벤트	
	
	RegisterEvent( EV_ShortcutPageUpdate );
	RegisterEvent( EV_ShortcutUpdate );
	RegisterEvent( EV_ShortcutClear );	
}

function OnLoad()
{	
	Me = GetWindowHandle( "FlightShipCtrlWnd" );
	ShortcutWnd = GetWindowHandle( "ShortcutWnd" );
	//엔터 채팅용.
	//Chk_EnterChatting	    =	GetCheckBoxHandle( "ShortcutAssignWnd.Chk_EnterChatting" );
	//Chk_EnterChatting1	    =	GetCheckBoxHandle( "ShortcutAssignWnd.Chk_EnterChatting1" );

	AltitudeTxt = GetTextBoxHandle( "FlightShipCtrlWnd.AltitudeTxt");
	SelectTex = GetTextureHandle( "FlightShipCtrlWnd.FlightShortCut.SelectTex");
	
	UpButton = GetButtonHandle( "FlightShipCtrlWnd.FlightSteerWnd.UpButton");
	DownButton = GetButtonHandle ( "FlightShipCtrlWnd.FlightSteerWnd.DownButton");
	LockBtn = GetButtonHandle ( "FlightShipCtrlWnd.FlightShortCut.LockBtn");
	UnlockBtn = GetButtonHandle ( "FlightShipCtrlWnd.FlightShortCut.UnlockBtn");
	JoypadBtn = GetButtonHandle ( "FlightShipCtrlWnd.FlightShortCut.JoypadBtn");	
	
	//채팅 롤백
	ChatEditBox = GetEditBoxHandle( "ChatWnd.ChatEditBox" );	
	
	scriptShortcutWnd = ShortcutWnd( GetScript("ShortcutWnd") );	
	isNowActiveFlightShipShortcut = false;
	m_preDriver = false;
	preSlot = -1;
	JoypadBtn.HideWindow();	
	updateLockButton();	// 잠금 상태를 업데이트 한다. 
	ShortCutUpdateAll();
}
//쉐이더 빌더 스테이트 삭제로 쓰임이 없어짐
/*
function OnEnterState( name a_PreStateName )
{
	
	if(isNowActiveFlightShipShortcut)	// 조종모드였었다면
	{
		if( a_PreStateName == 'ShaderBuildState')
		{
			if(!Me.isShowwindow()) Me.ShowWindow();					//전용 숏컷으로 변경
			if(ShortcutWnd.isShowwindow()) ShortcutWnd.HideWindow();
		}
	}
}
*/

function OnExitState( name a_NextStateName )
{
	//local OptionWnd win;	
	//쉐이더 빌더 스테이트 삭제로 쓰임이 없어짐
	/*
	if( a_NextStateName != 'ShaderBuildState')	// 쉐이더 상테로 나갈 경우가 아니라면,  체크박스의 디스에이블을 풀어준다. 
	{	
		win = OptionWnd( GetScript("OptionWnd") );
		win.dispatchEventToFlash_Int(200, 3); //엔터 채팅 체크 
	}*/
	CallGFxFunction( "OptionWnd", "onSwitchDisableEnterChatting", string ( false ) ) ;
	//win = OptionWnd( GetScript("OptionWnd") );
	//win.dispatchEventToFlash_Int(200, 3); //엔터 채팅 체크 
}

function updateLockButton()
{
	/*
	local int tmpInt;
	GetINIInt ( "ShortcutWnd", "l",  tmpInt, "WindowsInfo.ini");
	m_IsLocked = bool ( tmpInt );*/
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


// 이벤트 처리
function OnEvent( int a_EventID, String a_Param )
{
	switch( a_EventID )
	{
	case EV_AirShipState:
		OnAirShipState( a_Param );
		break;
	case EV_AirShipAltitude:
		OnAirShipAltitude( a_Param);
		break;
	case EV_ShortcutCommandSlot:
		ExecuteShortcutCommandBySlot(a_Param);	// 단축키 실행 이벤트
		break;
	case EV_ReserveShortCut:
		OnReserveShortCut( a_Param );
		break;
	case EV_ShortcutUpdate:
		HandleShortcutUpdate( a_Param );
		break;
	case EV_ShortcutPageUpdate:	// 페이지가 없기 때문에 전체를 업데이트 한다.
		ShortCutUpdateAll();
		break;
	case EV_ShortcutClear:
		HandleShortcutClear();
		updateLockButton();	// 잠금 상태를 업데이트 한다. 			
		break;
	default:
		break;
	}
}

function OnAirShipState( string a_Param )
{
	local int       VehicleID;
	local int       IsDriver;
	//local MainMenu	scriptMain;
	//local OptionWnd scriptOptionwin;	

	//scriptOptionwin = OptionWnd( GetScript("OptionWnd") );
	//scriptMain = MainMenu ( GetScript("MainMenu") );

	
	ParseInt( a_Param, "VehicleID", VehicleID );	// 비행정 위의 비행정 고도 및 HP 연료 등 UI는 RadarMapWnd.uc에서 처리하도록 한다. 
	ParseInt( a_Param, "IsDriver", IsDriver );
	
	//debug("VehicleID = " $ VehicleID $" IsDriver = " $ IsDriver);
	
	if( IsDriver > 0 )	//조종사 단축키 모드
	{
		if(VehicleID > 0)	// 조종 모드 보이기, 해제에서는 항상 비행정 아이디가 존재하여야 한다. 
		{	
			preEnterChattingOption = GetChatFilterBool ( "Global", "EnterChatting");
			SetChatFilterBool ( "Global", "EnterChatting", true);
			//preEnterChattingOption = GetOptionBool("CommunIcation", "EnterChatting");		//기존 엔터채팅 옵션을 저장해둔다. 					
			//SetOptionBool( "CommunIcation", "EnterChatting", true );	//강제 엔터 채팅

			Debug ( "OnAirShipState true" ) ;
			CallGFxFunction( "OptionWnd", "onSwitchEnterChatting", String ( true ) );		
			CallGFxFunction( "OptionWnd", "onSwitchDisableEnterChatting", String ( true ) );
			//scriptOptionwin.dispatchEventToFlash_Int(200, 1); //체크 엔터 채팅 체크
			//scriptOptionwin.dispatchEventToFlash_Int(200, 2); //디세블
			
			class'ShortcutAPI'.static.ActivateGroup("FlightStateShortcut");		//숏컷 그룹 지정	
//			scriptMain.changeEnterChat( "FlightStateShortcut" );
			updateLockButton();	// 잠금 상태를 업데이트 한다. 			
			if(!Me.isShowwindow()) 
			{
				Me.ShowWindow();					//전용 숏컷으로 변경
				ShortcutWnd.HideWindow();
			}
			
			//채팅 롤백
			ChatEditBox.ReleaseFocus();
			
			isNowActiveFlightShipShortcut = true;
			m_preDriver = true;
		}
	}
	else	// 조종사 해제 isDriver == 0
	{
		if(VehicleID > 0 && m_preDriver == true)		// 이전 상태가 조종모드였을때만 조종을 해제한다.
		{		
			
			//scriptOptionwin.dispatchEventToFlash_Int(200, 3); //디세블
			CallGFxFunction( "OptionWnd", "onSwitchDisableEnterChatting", String ( false ) );
			
			class'ShortcutAPI'.static.DeactivateGroup("FlightStateShortcut"); 	// 숏컷 그룹 해제		
			
			//SetOptionBool( "CommunIcation", "EnterChatting", preEnterChattingOption );	//백업해둔 엔터채팅 옵션을 다시 넣어준다.
			SetChatFilterBool ( "Global", "EnterChatting", preEnterChattingOption);
			
			if(preEnterChattingOption)	// 변신전 백업 상태에 따라 엔터 채팅을 활성화 해준다.			
			{			
				class'ShortcutAPI'.static.ActivateGroup("TempStateShortcut");
				//scriptMain.changeEnterChat( "TempStateShortcut" );
			}
			//else
			//{
			//	//scriptMain.changeEnterChat( "GamingStateShortcut" );
			//}

			//메인 메뉴 단축키 초기화
			CallGFxFunction ( "Menu", "onSetShortcut", "");
			CallGFxFunction ( "MenuWnd", "onSetShortcut", "");
			
			Debug ( "OnAirShipState2  " @ preEnterChattingOption ) ;
			CallGFxFunction( "OptionWnd", "onSwitchEnterChatting", String ( preEnterChattingOption ) );	

			//if (preEnterChattingOption ) 
			//{
			//	CallGFxFunction( getCurrentWindowName(String(self)), "onSwitchEnterChatting", String ( true ) );
			//	//scriptOptionwin.dispatchEventToFlash_Int(200, 1); //체크 엔터 채팅 체크
			//}
			//else 
			//{
			//	CallGFxFunction( getCurrentWindowName(String(self)), "onSwitchEnterChatting", String ( false ) );
			//	//scriptOptionwin.dispatchEventToFlash_Int(200, 0); //체크 엔터 채팅 체크
			//}
			//Chk_EnterChatting.SetCheck(preEnterChattingOption);
			//Chk_EnterChatting1.SetCheck(preEnterChattingOption);
			
			if(Me.isShowwindow())	
			{
				Me.HideWindow();					// 원래 숏컷으로 돌려놓음
				ShortcutWnd.ShowWindow();
			}
			
			isNowActiveFlightShipShortcut = false;			
			
			//채팅 롤백
			ChatEditBox.ReleaseFocus();
		}
	}
}

function OnAirShipAltitude( string a_Param )
{
	local int m_nZ;
	
	ParseInt( a_Param, "Z" , m_nZ);
	
	AltitudeTxt.SetText(string(m_nZ + 4000));	// 고도를 업데이트 해준다. 
	
}

function ShortCutUpdateAll()
{
	local int nShortcutID;
	
	nShortcutID = MAX_ShortcutPerPage * FSShortcutPage;
	
	for( i = 0; i < MAX_ShortcutPerPage; ++i )
	{
		class'UIAPI_SHORTCUTITEMWINDOW'.static.UpdateShortcut( "FlightShipCtrlWnd.FlightShortCut.Shortcut" $ ( i + 1 ), nShortcutID );
		nShortcutID++;
	}
}

// 숏컷 업데이트
function HandleShortcutUpdate(string param)
{
	local int nShortcutID;
	local int nShortcutNum;
	
	ParseInt(param, "ShortcutID", nShortcutID);
	nShortcutNum = ( nShortcutID - MAX_ShortcutPerPage * FSShortcutPage) + 1;
	
	//debug(" ----------fs------------- id : " $ nShortcutID $ " nShortcutNum " $ nShortcutNum );
	
	if((nShortcutNum > 0 ) && ( nShortcutNum  < MAX_ShortcutPerPage + 1 ))	// 비행숏컷일 경우에만  업데이트
	{
		class'UIAPI_SHORTCUTITEMWINDOW'.static.UpdateShortcut( "FlightShipCtrlWnd.FlightShortCut.Shortcut" $ nShortcutNum, nShortcutID );
	}
}

 //숏컷 클리어
function HandleShortcutClear()
{		
	for( i = 0; i < MAX_ShortcutPerPage; ++i )
	{
		class'UIAPI_SHORTCUTITEMWINDOW'.static.clear( "FlightShipCtrlWnd.FlightShortCut.Shortcut" $ ( i + 1 ) );
	}
}

function ExecuteShortcutCommandBySlot( string a_Param )
{
	local int slot;
	//local int slotFromOne;
	ParseInt(a_Param, "Slot", slot);
	
	// 132번부터 143번까지의 슬롯이 들어오면 실행해준다. 
	if( (slot >= MAX_ShortcutPerPage * FSShortcutPage) && ( slot < MAX_ShortcutPerPage * (FSShortcutPage + 1)))
	{	
		//slotFromOne = slot - MAX_ShortcutPerPage * FSShortcutPage + 1;
		class'ShortcutAPI'.static.ExecuteShortcutBySlot(slot);
		//SelectTex.SetAnchor( "FlightShipCtrlWnd.FlightShortCut.F" $ slotFromOne $ "Tex" , "TopLeft", "TopLeft", SelectTex_X, SelectTex_Y );
	}
}

function OnReserveShortCut( string a_Param )
{
	local int slot;
	local int slotFromOne;
	ParseInt(a_Param, "Slot", slot);
	
	// 132번부터 143번까지의 슬롯이 들어오면 광을 내준다.
	if( (slot >= MAX_ShortcutPerPage * FSShortcutPage) && ( slot < MAX_ShortcutPerPage * (FSShortcutPage + 1)))
	{	
		slotFromOne = slot - MAX_ShortcutPerPage * FSShortcutPage + 1;
		SelectTex.SetAnchor( "FlightShipCtrlWnd.FlightShortCut.F" $ slotFromOne $ "Tex" , "TopLeft", "TopLeft", SelectTex_X, SelectTex_Y );
		
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

// 고도 상승, 하강 버튼
function OnClickButton( String strID )
{
	switch( strID )
	{
	case "UpButton":
		Class'VehicleAPI'.static.AirShipMoveUp();	//고도 상승
		break;
	case "DownButton":
		Class'VehicleAPI'.static.AirShipMoveDown(); // 고도 하강
		break;
	case "LockBtn":
		m_IsLocked = false;		
		//SetINIInt ( "ShortcutWnd", "l", 0 , "WindowsInfo.ini");		
		SetOptionBool( "Game", "IsLockShortcutWnd", false );
		updateLockButton();
		break;
	case "UnlockBtn":
		m_IsLocked = true;
		//SetINIInt ( "ShortcutWnd", "l", 1 , "WindowsInfo.ini");		
		SetOptionBool( "Game", "IsLockShortcutWnd", true );
		updateLockButton();
		break;
	}
}
defaultproperties
{
}
