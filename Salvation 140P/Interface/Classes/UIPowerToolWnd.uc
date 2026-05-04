/**
 *  이벤트 강제 발생 UI 개발 유틸 (툴)
 *  
 **/
class UIPowerToolWnd extends UICommonAPI;

var WindowHandle  Me;

var ButtonHandle  event1Btn, event2Btn, event3Btn, InitBtn;

var EditBoxHandle param1Edit, param2Edit, param3Edit;
var EditBoxHandle eventNum1Edit, eventNum2Edit, eventNum3Edit;


//-----------------------------------------------------------------------------------------------------------
//  Init
//-----------------------------------------------------------------------------------------------------------
function OnRegisterEvent()
{
	//RegisterEvent(  );
}

function OnShow()
{
	loadEditByINI(1);
	loadEditByINI(2);
	loadEditByINI(3);

	// SetINIString("EventPowerToolWnd", "event1", bValue, "UIDEV.ini");
}

function OnHide()
{
	setEditByINI(1);
	setEditByINI(2);
	setEditByINI(3);
}

function OnLoad()
{
	SetClosingOnESC(); 
	// getInstanceUIData().addEscCloseWindow(getCurrentWindowName(string(Self)));

	Initialize();
}

function Initialize()
{
	Me = GetWindowHandle( "UIPowerToolWnd" );

	// 초기화
	InitBtn    = GetButtonHandle( "UIPowerToolWnd.InitBtn" );

	// 이벤트 보내기, 버튼
	event1Btn  = GetButtonHandle( "UIPowerToolWnd.event1Btn" );
	event2Btn  = GetButtonHandle( "UIPowerToolWnd.event2Btn" );
	event3Btn  = GetButtonHandle( "UIPowerToolWnd.event3Btn" );

	// 이벤트 매개변수 스트링, 에디터 
	param1Edit = GetEditBoxHandle( "UIPowerToolWnd.param1Edit" );
	param2Edit = GetEditBoxHandle( "UIPowerToolWnd.param2Edit" );
	param3Edit = GetEditBoxHandle( "UIPowerToolWnd.param3Edit" );
	
	// 이벤트 번호, 에디터 
	eventNum1Edit = GetEditBoxHandle( "UIPowerToolWnd.eventNum1Edit" );
	eventNum2Edit = GetEditBoxHandle( "UIPowerToolWnd.eventNum2Edit" );
	eventNum3Edit = GetEditBoxHandle( "UIPowerToolWnd.eventNum3Edit" );	

	Me.SetWindowTitle("UIPowerTools [ EventTool ]");
}

function OnClickButton( string Name )
{
	switch( Name )
	{
		case "event1Btn":
			event1BtnClick();
			break;
		case "event2Btn":
			event2BtnClick();
			break;
		case "event3Btn":
			event3BtnClick();
			break;
		case "InitBtn" :
			InitBtnClick();
	}
}

//-----------------------------------------------------------------------------------------------------------
//  Handle
//-----------------------------------------------------------------------------------------------------------
function event1BtnClick()
{
	ExecuteEvent(int(eventNum1Edit.GetString()), param1Edit.GetString());
	setEditByINI(1);
}

function event2BtnClick()
{
	ExecuteEvent(int(eventNum2Edit.GetString()), param2Edit.GetString());
	setEditByINI(2);
}

function event3BtnClick()
{
	ExecuteEvent(int(eventNum3Edit.GetString()), param3Edit.GetString());
	setEditByINI(3);
}

function InitBtnClick()
{
	param1Edit.SetString("");
	param2Edit.SetString("");
	param3Edit.SetString("");
	eventNum1Edit.SetString("");
	eventNum2Edit.SetString("");
	eventNum3Edit.SetString(""); 
}

//-----------------------------------------------------------------------------------------------------------
//  function
//-----------------------------------------------------------------------------------------------------------
/** init load */
function loadEditByINI(int index)
{
	local string stringValue;

	stringValue = "";	

	// Event Param 
	GetINIString("EventPowerToolWnd", "event"    $ index, stringValue, "UIDEV.ini");
	GetEditBoxHandle( "UIPowerToolWnd.param"     $ index $ "Edit" ).SetString(stringValue);

	// Event Number 
	GetINIString("EventPowerToolWnd", "eventNum" $ index, stringValue, "UIDEV.ini");
	GetEditBoxHandle( "UIPowerToolWnd.eventNum"  $ index $ "Edit" ).SetString(stringValue);
}

/** init load */
function setEditByINI(int index)
{
	// Event Param 
	SetINIString("EventPowerToolWnd", "event"    $ index, GetEditBoxHandle( "UIPowerToolWnd.param"     $ index $ "Edit" ).GetString(), "UIDEV.ini");
	// Event Number 
	SetINIString("EventPowerToolWnd", "eventNum" $ index, GetEditBoxHandle( "UIPowerToolWnd.eventNum"  $ index $ "Edit" ).GetString(), "UIDEV.ini");
}


/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( "UIPowerToolWnd" ).HideWindow();
}
defaultproperties
{
}
