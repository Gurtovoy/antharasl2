class BR_EventHtmlWndC extends UICommonAPI;

var WindowHandle Me;
var HtmlHandle HtmlViewer;

function OnRegisterEvent()
{
	RegisterEvent( EV_BR_EventCommonHtml3 );	
}

function OnLoad()
{
	Initialize();
	Load();
}

function Initialize()
{
	if (CREATE_ON_DEMAND==0) {
		Me = GetHandle( "BR_EventHtmlWndC" );
		HtmlViewer = HtmlHandle ( GetHandle( "BR_EventHtmlWndC.HtmlViewer3" ) );
	}
	else
	{
		Me = GetWindowHandle( "BR_EventHtmlWndC" );
		HtmlViewer = GetHtmlHandle( "BR_EventHtmlWndC.HtmlViewer3" );
	}
}

function Load()
{
}

function OnEvent(int Event_ID, String param)
{
	if (Event_ID == EV_BR_EventCommonHtml3)
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
