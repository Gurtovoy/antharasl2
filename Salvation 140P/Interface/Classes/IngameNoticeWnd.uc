class IngameNoticeWnd extends UICommonAPI;

var string              m_WindowName;

var WindowHandle	    m_hIngameNoticeWnd;
var WebBrowserHandle	m_hBrowserViewer;

function OnLoad()
{
	SetClosingOnESC();
	
	m_hIngameNoticeWnd=GetWindowHandle(m_WindowName);
	m_hBrowserViewer=GetWebBrowserHandle(m_WindowName$".WebBrowser");

}

function OnShow()
{
	local string strGetUrl;
	m_hBrowserViewer.ShowWindow();
	
	// 현재 열려있는 URL 주소가 없다는 것은 메인 메뉴에 의해 창이 열린 것.
	strGetUrl = m_hBrowserViewer.GetUrl();
	if(strGetUrl == "" || strGetUrl == "about:blank")
	{
		MainMenuShow();
	}
}

function OnHide()
{
	log("-----HideWindow1");
	m_hBrowserViewer.HideWindow();
}

function OnRegisterEvent()
{
	RegisterEvent(EV_WebBrowser_FinishedLoading);
	RegisterEvent(EV_GameStart); //최초 접속 시 오는 이벤트로 교체
	RegisterEvent(EV_WebBrowser_NoticeOpenStatus);
}

function NavigateToPetitionPage()
{
	local UserInfo userinfo;
	local int serverNo;
	local string cookieKey,lineage2NoticeURL;

	m_hBrowserViewer.BeginParam("UTF-8");

	serverNo = GetServerNo();
	m_hBrowserViewer.PushParam("server_id",string(serverNo));

	GetPlayerInfo(userinfo);
	m_hBrowserViewer.PushParam("char_name",userinfo.Name);

	cookieKey = userinfo.Name $ "_" $ string(serverNo) $ "_not_notice_again";

	//데브 더미페이지
	//http://lineage2/account/test.asp

	if(GetINIString("URL","L2InGameBrowserNoticeURL",lineage2NoticeURL,"l2.ini"))
	{
		if(m_hBrowserViewer.GetCookie(lineage2NoticeURL,cookieKey) == "")
		{
			m_hBrowserViewer.NavigateAsPost(lineage2NoticeURL);
		}
		else
		{
			m_hIngameNoticeWnd.HideWindow();
		}
	}
}


function MainMenuShow()
{
	local UserInfo userinfo;
	local int serverNo;
	local string lineage2NoticeURL;

	m_hBrowserViewer.BeginParam("UTF-8");

	serverNo = GetServerNo();
	m_hBrowserViewer.PushParam("server_id",string(serverNo));

	GetPlayerInfo(userinfo);
	m_hBrowserViewer.PushParam("char_name",userinfo.Name);

	//데브 더미페이지
	//http://lineage2/account/test.asp

	//debug("주소>" @ GetINIString( "URL", "L2InGameBrowserNoticeURL", lineage2NoticeURL, "l2.ini" ));

	if(GetINIString("URL","L2InGameBrowserNoticeURL",lineage2NoticeURL,"l2.ini"))
	{
		m_hBrowserViewer.NavigateAsPost(lineage2NoticeURL);
	}
}


function IsOpenWnd(String param)
{
	local string str;
	local string url;

	ParseString(param,"url",url);

	if(url == m_hBrowserViewer.GetUrl())
	{
		m_hBrowserViewer.ExecuteJavaScriptWithStringResult("getNoticeOpenStatus()",str);
		if(str == "Y")
		{
			m_hIngameNoticeWnd.ShowWindow();
			m_hIngameNoticeWnd.SetFocus();
		}
		else
		{
			m_hIngameNoticeWnd.HideWindow();
		}
	}
}

function OnEvent(int Event_ID, String param)
{
	switch(Event_ID)
	{		
	case EV_WebBrowser_FinishedLoading:
		log("-----EV_WebBrowser_FinishedLoading");
		IsOpenWnd(param);
		break;

	//게임 시작할 때 최초	
	case EV_GameStart:
		log("-----EV_GameStart");
		NavigateToPetitionPage();
		break;
	}
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	log("-----HideWindow3");
	GetWindowHandle( m_WindowName ).HideWindow();

	Debug("m_WindowName>>>>>>" @ m_WindowName);
}

defaultproperties
{
    m_WindowName="IngameNoticeWnd"
}
