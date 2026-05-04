class BR_EventHtmlWndA extends UICommonAPI;

var WindowHandle Me;
var HtmlHandle HtmlViewer;

function OnRegisterEvent()
{
	RegisterEvent( EV_BR_EventCommonHtml1 );	
}

function OnLoad()
{
	Initialize();
	Load();
}

function Initialize()
{
	if (CREATE_ON_DEMAND==0) {
		Me = GetHandle( "BR_EventHtmlWndA" );
		HtmlViewer = HtmlHandle ( GetHandle( "BR_EventHtmlWndA.HtmlViewer1" ) );
	}
	else
	{
		Me = GetWindowHandle( "BR_EventHtmlWndA" );
		HtmlViewer = GetHtmlHandle( "BR_EventHtmlWndA.HtmlViewer1" );
	}
}

function Load()
{
}

function OnEvent(int Event_ID, String param)
{
	if (Event_ID == EV_BR_EventCommonHtml1)
	{
		ShowEventHtml(param);
	}
}

function ShowEventHtml(string param)
{
	local string strPath;
	local string strTitle;

	ParseString(param, "FilePath", strPath);
	ParseString(param, "Title", strTitle);
	
	if (Len(strPath)>0)
	{		
		HtmlViewer.LoadHtml(strPath);
	}			
	
	Me.SetWindowTitle(strTitle);
}
defaultproperties
{
}
