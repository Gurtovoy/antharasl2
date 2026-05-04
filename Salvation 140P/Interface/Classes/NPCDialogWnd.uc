class NPCDialogWnd extends UICommonAPI;


var string m_WindowName;

var WindowHandle	m_hNPCDialogWnd;
var HtmlHandle		m_hHtmlViewer;

var bool	m_bRecievedCloseUI;
var bool	m_bNpcZoomMode;

function OnRegisterEvent()
{
	RegisterEvent(EV_NPCDialogWndShow);
	RegisterEvent(EV_NPCDialogWndHide);
	RegisterEvent(EV_NPCDialogWndLoadHtmlFromString);
	RegisterEvent(EV_QuestIDWndLoadHtmlFromString);
	
	// register gamingstate enter/exit event 
	// - 등록하지 않으면, 처음 호출될때 OnEnter와 OnExit가 호출되지 않음.
	RegisterEvent(EV_GamingStateEnter);
	RegisterEvent(EV_GamingStateExit);	
}

function OnLoad()
{
	SetClosingOnESC();

	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	if(CREATE_ON_DEMAND==0)
	{
		m_hNPCDialogWnd=GetHandle(m_WindowName);
		m_hHtmlViewer=HtmlHandle(GetHandle(m_WindowName$".HtmlViewer"));
	}
	else
	{
		m_hNPCDialogWnd=GetWindowHandle(m_WindowName);
		m_hHtmlViewer=GetHtmlHandle(m_WindowName$".HtmlViewer");
	}
}

function onShow()
{
	getInstanceL2Util().syncWindowLoc(getCurrentWindowName(string(Self)), "QuestHTMLWnd,NPCDialogWnd");

	// 멀티셀이 열려 있다면 닫는다.
	if(GetWindowHandle("MultiSellWnd").IsShowWindow()) GetWindowHandle("MultiSellWnd").HideWindow();
}

function OnHide()
{
	ProcCloseNPCDialogWnd();
	getInstanceL2Util().syncWindowLocAuto("QuestHTMLWnd,NPCDialogWnd");
}

function OnEvent(int Event_ID, String param)
{
	switch(Event_ID)
	{
	case EV_NPCDialogWndShow :
		ShowNPCDialogWnd();
		break;
		
	case EV_NPCDialogWndHide :
		HideNPCDialogWnd();
		break;
		
	case EV_NPCDialogWndLoadHtmlFromString :
		m_hNpcDialogWnd.SetWindowTitle(GetSystemString(444));	 //타이틀을 "대화"로 바꿔준다. 
		HandleLoadHtmlFromString(param);
		break;
	case EV_QuestIDWndLoadHtmlFromString:
		m_hNPCDialogWnd.HideWindow();
		break;
	}
}

function OnHtmlMsgHideWindow(HtmlHandle a_HtmlHandle)
{
	if(a_HtmlHandle==m_hHtmlViewer)
	{
		HideNPCDialogWnd();
	}
}

function HandleLoadHtmlFromString(string param)
{
	local string htmlString;
	ParseString(param, "HTMLString", htmlString);

	m_hHtmlViewer.LoadHtmlFromString(htmlString);
}


function PressCloseButton()
{
	if(m_bNpcZoomMode)
	{
		m_bRecievedCloseUI = true;
	}
}

function OnClickButton( string Name )
{
	PressCloseButton();
}

function BeginNpcZoomMode()
{
	m_bRecievedCloseUI = false;
	m_bNpcZoomMode = true;
}

function EndNpcZoomMode()
{
	ProcCloseNPCDialogWnd();
	
	m_bRecievedCloseUI = false;
	m_bNpcZoomMode = false;
}

function OnExitState(name a_NextStateName )
{
	
	if( a_NextStateName == 'NpcZoomCameraState')
	{
		BeginNpcZoomMode();
	}
}

function OnEnterState( name a_PreStateName )
{
	
	if( a_PreStateName == 'NpcZoomCameraState' )
	{
		EndNpcZoomMode();
	}	
}

function ShowNPCDialogWnd()
{
	ExecuteEvent(EV_QuestHtmlWndHide);
	m_hNPCDialogWnd.ShowWindow();
	m_hNPCDialogWnd.SetFocus();
}

function HideNPCDialogWnd()
{
	m_hNpcDialogWnd.HideWindow();
}

function ProcCloseNPCDialogWnd()
{
	if( m_bRecievedCloseUI && m_bNpcZoomMode )
	{
		// must first m_bReShowNPCDialogWnd be false because calling recursive function.	
		m_bRecievedCloseUI = false;		
		RequestFinishNPCZoomCamera();		
	}
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PressCloseButton();
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( "NPCDialogWnd" ).HideWindow();	
}
defaultproperties
{
    m_WindowName="NPCDialogWnd"
}
