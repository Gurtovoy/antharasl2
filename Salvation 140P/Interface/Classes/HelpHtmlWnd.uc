class HelpHtmlWnd extends UICommonAPI;

var bool	m_bShow;
var string m_WindowName;
var HtmlHandle	m_hHelpHtmlWndHtmlViewer;


function OnRegisterEvent()
{
	RegisterEvent(EV_ShowHelp);
	RegisterEvent(EV_LoadHelpHtml);
}

function OnLoad()
{
	SetClosingOnESC();

	RegisterState( "HelpHtmlWnd", "GamingState" );
	RegisterState( "HelpHtmlWnd", "LoginState" );
	
	m_hHelpHtmlWndHtmlViewer=GetHtmlHandle("HelpHtmlWnd.HtmlViewer");

	m_bShow = false;
}

function OnShow()
{
	m_bShow = true;
}

function OnHide()
{
	m_bShow = false;
}

function OnEvent(int Event_ID, String param)
{		
	// 서버 선택 시 도움말 
	if(GetGameStateName()  != "SERVERLISTSTATE") //return;
	{
		// 서버 선택 스테이트가 아니라면, 클래식에서만 이벤트를 받는다.
		if(!getInstanceUIData().getIsClassicServer()) return;
	}

	if (Event_ID == EV_ShowHelp)
	{
		HandleShowHelp(param);
	}
	else if (Event_ID == EV_LoadHelpHtml)
	{
		HandleLoadHelpHtml(param);
	}
}

function HandleShowHelp(string param)
{
	local string strPath;
	
	if (m_bShow)
	{
		PlayConsoleSound(IFST_WINDOW_CLOSE);
		class'UIAPI_WINDOW'.static.HideWindow("HelpHtmlWnd");
	}
	else
	{
		if (param == "FilePath=..\\L2text\\125")
		{
			m_hHelpHtmlWndHtmlViewer.LoadHtml("..\\L2text\\help_item_upgrade.htm");

			PlayConsoleSound(IFST_WINDOW_OPEN);	
			class'UIAPI_WINDOW'.static.ShowWindow("HelpHtmlWnd");
			class'UIAPI_WINDOW'.static.SetFocus("HelpHtmlWnd");

			return;
		}

		ParseString(param, "FilePath", strPath);

		if (Len(strPath)>0)
		{
			//서버 선택의 도움말에서 서버 선택창에 가려지는 현상 때문에 추가.
			if( strPath == "..\\L2text\\server_help.htm")
			{
				class'UIAPI_WINDOW'.static.SetAlwaysOnTop( "HelpHtmlWnd", true );
			}
			else 
			{
				class'UIAPI_WINDOW'.static.SetAlwaysOnTop( "HelpHtmlWnd", false );
			}

			m_hHelpHtmlWndHtmlViewer.LoadHtml(strPath);
			PlayConsoleSound(IFST_WINDOW_OPEN);	
			class'UIAPI_WINDOW'.static.ShowWindow("HelpHtmlWnd");
			class'UIAPI_WINDOW'.static.SetFocus("HelpHtmlWnd");
		}		
	}
}

function HandleLoadHelpHtml(string param)
{
	local string strHtml;
	
	ParseString(param, "HtmlString", strHtml);
	if (Len(strHtml)>0)
	{
		m_hHelpHtmlWndHtmlViewer.LoadHtmlFromString(strHtml);
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
    m_WindowName="HelpHtmlWnd"
}
