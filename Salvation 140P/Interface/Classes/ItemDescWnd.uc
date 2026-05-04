class ItemDescWnd extends UICommonAPI;


var string m_WindowName;
var WindowHandle	m_hItemDescWnd;
var HtmlHandle		m_hHtmlViewer;

function OnRegisterEvent()
{
	RegisterEvent(EV_ItemDescWndShow);
	RegisterEvent(EV_ItemDescWndLoadHtmlFromString);
	RegisterEvent(EV_ItemDescWndSetWindowTitle);
}

function OnLoad()
{
	SetClosingOnESC();

	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	if(CREATE_ON_DEMAND==0)
	{
		m_hItemDescWnd=GetHandle(m_WindowName);
		m_hHtmlViewer=HtmlHandle(GetHandle(m_WindowName$".HtmlViewer"));
	}
	else
	{
		m_hItemDescWnd=GetWindowHandle(m_WindowName);
		m_hHtmlViewer=GetHtmlHandle(m_WindowName$".HtmlViewer");
	}
}

function OnEvent(int Event_ID, String param)
{
	switch(Event_ID)
	{
	case EV_ItemDescWndShow :
		m_hItemDescWnd.ShowWindow();
		m_hItemDescWnd.SetFocus();
		break;
	case EV_ItemDescWndLoadHtmlFromString :
		HandleLoadHtmlFromString(param);
		break;
	case EV_ItemDescWndSetWindowTitle :
		HandleWindowTitle(param);
		break;
	}
}

function HandleWindowTitle(string param)
{
	local string title;

	ParseString(param, "Title", title);

	m_hItemDescWnd.SetWindowTitle(title);
}

function HandleLoadHtmlFromString(string param)
{
	local string htmlString;
	ParseString(param, "HTMLString", htmlString);

	m_hHtmlViewer.LoadHtmlFromString(htmlString);
}

/**
 * l2text 의 html 파일을 직접 연다.
 **/
function ShowHelp(string strPath)
{
	if (Len(strPath)>0)
	{		
		m_hHtmlViewer.LoadHtml(strPath);

		m_hItemDescWnd.ShowWindow();
		m_hItemDescWnd.SetFocus();
	}			
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
    m_WindowName="ItemDescWnd"
}
