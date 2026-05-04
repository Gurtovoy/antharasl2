class BR_PathWnd extends UICommonAPI;

const N_MAX_WEB_RES_X = 1024;
const N_MAX_WEB_RES_Y = 1024;
const N_BUTTON_HEAD_AREA_BUFFER = 75;

var string m_WindowName;

var WindowHandle	m_hPathWnd;
var WebBrowserHandle	m_hBrowserViewer;
var EditBoxHandle	ChatEditBox;
var bool m_firstOpen;

function OnRegisterEvent()
{
	RegisterEvent(EV_ShowWebPathMainPage);
	RegisterEvent(EV_ShowWebPathListPage);
	RegisterEvent(EV_ShowWebPathAlarm);	
	RegisterEvent( EV_ResolutionChanged );
}

function OnLoad()
{
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	if(CREATE_ON_DEMAND==0)
	{
		m_hPathWnd=GetHandle(m_WindowName);
		m_hBrowserViewer=WebBrowserHandle(GetHandle(m_WindowName$".WebBrowser"));
	}
	else
	{
		m_hPathWnd=GetWindowHandle(m_WindowName);
		m_hBrowserViewer=GetWebBrowserHandle(m_WindowName$".WebBrowser");
	}

//	ChatEditBox = EditBoxHandle( GetHandle( "ChatWnd.ChatEditBox" )); COD-_-
//	ChatEditBox = GetEditBoxHandle( "ChatWnd.ChatEditBox" );
	
	m_firstOpen = false;
}

function OnShow()
{
	m_hBrowserViewer.ShowWindow();
}

function OnHide()
{
	m_hBrowserViewer.HideWindow();
}

function NavigateToPathPage(String additionalURL)
{
	local string lineage2PathMapURL;
	local WebRequestInfo requestInfo;

	////// Awesomium ver 1.6.6 사용 시. CEF 교체 후 삭제할 것. /////////////////////////////////
	// 그런데 이 창은 '미국용 레벨업 네비게이션 맵'이라고 하는데 쓰고 있는건지 잘 모르겠다. - moonhj

	// default setting for in game browser petition 
	//m_hBrowserViewer.WithWebSession();

	// 아래 사항들은 인게임 1:1 문의시에 해당 URL에서 필요한 정보들입니다.
	// 수정시엔 플랫폼팀에 문의하시기 바랍니다.
	/*	m_hBrowserViewer.BeginParam( "UTF-8" );

	// 	lineage2PetitionID = 32; // 고정된 값
	// 	m_hBrowserViewer.PushParam( "target", string(lineage2PetitionID) );
	//
	// 	serverNo = GetServerNo();
	// 	m_hBrowserViewer.PushParam( "server_id", string(serverNo) );
	//
	// 	GetPlayerInfo( userinfo );
	// 	m_hBrowserViewer.PushParam( "char_name", userinfo.Name );

	if( additionalURL == "main" )
	{
	if( GetINIString( "URL", "L2InGameBrowserPathMapURL", lineage2PathMapURL, "l2.ini" ) )
	{
	//m_hBrowserViewer.NavigateAsPost( lineage2PathMapURL$"/"$additionalURL );
	m_hBrowserViewer.NavigateAsPost( lineage2PathMapURL );
	}
	}
	else
	{
	m_hBrowserViewer.NavigateAsPost( additionalURL );
	}*/
	////// Awesomium ver 1.6.6 사용 시. CEF 교체 후 삭제할 것. /////////////////////////////////

	requestInfo.eMethodType = EWMT_POST;
	if(additionalURL == "main")
	{
		if(GetINIString("URL","L2InGameBrowserPathMapURL",lineage2PathMapURL,"l2.ini"))
		{
			requestInfo.strRequestUrl = lineage2PathMapURL;
		}
	}
	else
	{
		requestInfo.strRequestUrl = additionalURL;
	}

	m_hBrowserViewer.Navigate(requestInfo);
}
function HandleShowWebPathMapMainPage(String param)
{
	local string url;
	
	ParseString(param, "Message", url);

	if( url == "" ) 
	{
		url = "main";
	}
	
	if( m_firstOpen == false )
	{
		m_firstOpen = true;
		CheckResolution();
	}
	
	ChatEditBox.ReleaseFocus();
	m_hPathWnd.ShowWindow();
	m_hPathWnd.SetFocus();
	
	// 메인 페이지
	NavigateToPathPage(url);
}

function HandleShowWebPathMapListPage()
{
	m_hPathWnd.ShowWindow();
	m_hPathWnd.SetFocus();
	
	// 문의 내역 페이지
	NavigateToPathPage("list");
}

function HandleShowWebPathAlarm(String param)
{
	local int PathToAwakeningAlarmType; 
	local int PathToAwakeningAlarmValue; 
	
	PathToAwakeningAlarmType = 0;
	PathToAwakeningAlarmValue = 0;
	
	m_hPathWnd.ShowWindow();
	m_hPathWnd.SetFocus();
	
	ParseInt(param, "Type", PathToAwakeningAlarmType); // 0 None 1 Level
	ParseInt(param, "Value", PathToAwakeningAlarmValue); // type 0일때는 사용안함
	
	debug(" ShowWebPathAlarm Type" @ PathToAwakeningAlarmType @ "Value" @ PathToAwakeningAlarmValue ) ;
	
	// 문의 내역 페이지
	NavigateToPathPage("list");
}


function OnEvent(int Event_ID, String param)
{
	switch(Event_ID)
	{		
	case EV_ShowWebPathMainPage:
		HandleShowWebPathMapMainPage(param);		
		break;
		
	case EV_ShowWebPathListPage:
		HandleShowWebPathMapListPage();
		break;
	case EV_ShowWebPathAlarm:
		HandleShowWebPathAlarm(param);
		break;		
	case EV_ResolutionChanged :
		HandleResolutionChanged(param);
		break;
	}
}

function OnClickButton( string Name )
{
	switch( Name )
	{
	case "HomeButton":
		NavigateToPathPage("main");
		break;
// 	case "PrevButton":
// 		m_hBrowserViewer.GoToHistoryOffset(-1);
// 		break;
// 	case "NextButton":
// 		m_hBrowserViewer.GoToHistoryOffset(1);
// 		break;		
	}	
}

function HandleResolutionChanged(String aParam)
{
	local int NewWidth;
	local int NewHeight;
	ParseInt(aParam, "NewWidth", NewWidth);
	ParseInt(aParam, "NewHeight", NewHeight);

	//branch EP1.0 luciper3 - 창 최소화 할때 값이 0이 오는데 0을 셋팅해버려서 게임내 웹페이지가 사라짐
	if( NewWidth <= 0 || NewHeight <= 0 )
		return;
	//end of branch

	ResetWebSize(NewWidth, NewHeight);
}

function CheckResolution()
{
	local int CurrentMaxWidth; 
	local int CurrentMaxHeight;


	GetCurrentResolution (CurrentMaxWidth, CurrentMaxHeight);
	ResetWebSize(CurrentMaxWidth, CurrentMaxHeight);
}

function ResetWebSize(int CurrentWidth, int CurrentHeight)
{
	local int adjustedwidth;
	local int adjustedheight;
	local int MainMapWidth;
	local int MainMapHeight;

	//~ debug("MinimapExpandWnd - ResetMinimapSize");
	
	MainMapWidth = CurrentWidth;
	MainMapHeight = CurrentHeight;

	adjustedwidth = CurrentWidth - 19 ;
	adjustedheight = CurrentHeight - N_BUTTON_HEAD_AREA_BUFFER - 5 ;
	
	if (CurrentWidth > N_MAX_WEB_RES_X )
	{
		adjustedwidth = N_MAX_WEB_RES_X - 19;
		MainMapWidth = N_MAX_WEB_RES_X ;
				
		
	}
	if (CurrentHeight > N_MAX_WEB_RES_Y)
	{
		adjustedheight = N_MAX_WEB_RES_Y - N_BUTTON_HEAD_AREA_BUFFER;
		MainMapHeight = N_MAX_WEB_RES_Y;		
	}
	
	m_hPathWnd.SetWindowSize(MainMapWidth+2 , MainMapHeight-2);
	m_hBrowserViewer.SetWindowSize(adjustedwidth+2, adjustedheight-2);		
	
}

defaultproperties
{
    m_WindowName="BR_PathWnd"
}
