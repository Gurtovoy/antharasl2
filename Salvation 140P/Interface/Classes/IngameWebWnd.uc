class IngameWebWnd extends UICommonAPI;

var string              m_WindowName;

var WindowHandle	    m_hIngameWebWnd;
var WebBrowserHandle	m_hBrowserViewer;
var WebBrowserHandle	m_hBrowserForSessionRefresh; // 세션 연장

var bool				m_bCheckFinishPageForSession;
var String				m_strRequestURL;			// 요청한 페이지 URL

const LINEAGE2_WEB_ID = 32;					// 리니지2 고정값
const TIMER_ID_WEB_SESSION = 8989;			// 웹 세션 타이머 ID
const INGAMEWEB_SECTION_CLASSIC = "IngameWeb_Classic"; // L2.INI 에 클래식용 인게임웹 URL의 섹션 이름
const INGAMEWEB_SECTION_LIVE = "IngameWeb_Live";	   // 아직은 사용 되지 않음.

// 웹 세션 갱신 타임(40분) - 1시간 동안 세션이 유지되지만 안정적으로 40분으로 함.
// Aion은 20분, 블쏘는 50분으로 한다고 함. - y2jinc
const REFRESH_WEB_SESSION_TIME = 2400000;	// 1초가 1000 * 60 * 40 = 2400000 (40 분)
//const REFRESH_WEB_SESSION_TIME = 5000;	// 세션 연장 테스트시 5초에 하는 부분 (확인시 귀찮아서 주석으로 남겨놓음)

var string lastShowCategory;

function OnLoad()
{
	SetClosingOnESC();
	
	m_hIngameWebWnd = GetWindowHandle(m_WindowName);
	m_hBrowserViewer = GetWebBrowserHandle(m_WindowName$".WebBrowser");
	m_hBrowserForSessionRefresh = GetWebBrowserHandle(m_WindowName$".WebBrowserForSession");
	m_hBrowserForSessionRefresh.HideWindow();
	
	m_bCheckFinishPageForSession = FALSE;
}

function OnRegisterEvent()
{
	RegisterEvent(EV_WebBrowser_FinishedLoading);
	RegisterEvent(EV_InGameWebWnd_Info);
	//10140
	RegisterEvent(EV_GotoWorldRaidServer);	

	// 타이틀이 바뀌었을때 오는 이벤트 - y2jinc
	RegisterEvent(EV_WebBrowser_ReceivedTitle);
}

function OnEvent(int Event_ID, String param)
{
	switch (Event_ID)
	{
		case EV_WebBrowser_FinishedLoading:
			 OnWebBrowser_FinishedLoading(param);
			 break;

		case EV_InGameWebWnd_Info:		
			 if ( !getInstanceUIData().getIsArenaServer() )  NavigatePage(param);
			 break;

		// 차원 공선전 이동 후
		case EV_GotoWorldRaidServer:
			 getInstanceL2Util().showGfxScreenMessage( GetSystemMessage(4047));
			 m_hIngameWebWnd.HideWindow();
			 break;

		case EV_WebBrowser_ReceivedTitle:
			 OnWebBrowser_ReceivedTitle(param);
			 break;

		case EV_Restart :
			 lastShowCategory = "";
			 break;
	}
}

function NavigatePage(String param)
{
	local string category;
	local string message;
	local string strURL;

	parseString(param, "Category", category);
	parseString(param, "Message", message);

	if (category == "url")
	{
		NavigateUrlPage(message);
	}	
	else if (category == "test_url")
	{
		NavigateUrlPageWithoutNPToken(message);
	}
	else if (category == "check_session")
	{
		TestCheckSession();
	}
	else
	{
		// 알림 버튼이나 메뉴에서 현재 열려 있는 카테고리로 다시 열기를 요청 했다면 닫히도록 처리
		if (lastShowCategory == category && IsShowWindow("InGameWebWnd"))
		{
			HideWindow("InGameWebWnd");
			return;
		}
		
		// 일단 url 말고는 카테고리 뒤져서 처리하도록 했지만
		// 실제 작업 진행 하다가 구분을 해야하는 경우가 생기면
		// else if 로 카테고리 명으로 분기해야 함.
		if (GetUrlPageAtL2INI(category, strURL))
		{
			lastShowCategory = category;
			NavigateUrlPage(strURL);
		}
	}
}

////// Awesomium ver 1.6.6 사용 시. CEF 교체 후 삭제할 것. /////////////////////////////////
// sample: "gcsweblin2.plaync.com/home/main?target={petition_id}&server_id={server_num}&char_name={user_name}"
/*function String GetParameterForNPSession(String strURL)
{
	local UserInfo userinfo;
	local int serverNo;
	local int lineage2WebID;
	local string strReturnURL;
	local string strURLEncoded;

	local string strExtraParam;
	local int ParamIndex;	
	
	ParamIndex = InStr(strURL, "?");
	if (ParamIndex > 0)
	{
		// ? 이후에 파라메터를 얻는다.
		strExtraParam = Mid(strURL, ParamIndex+1);
	
		// ? 이후에 붙은 파라메터를 제외하고 URL를 얻는다.
		strURL = Left(strURL, ParamIndex);	

		//debug("[InGameWebWnd]strURL="$strURL$" ExtraParam="$strExtraParam);
	}

	// default setting for in game browser petition 
	lineage2WebID = LINEAGE2_WEB_ID;
	serverNo = GetServerNo();
	GetPlayerInfo(userinfo);

	// 캐릭터명만 URL Encoding.
	strURLEncoded = m_hBrowserViewer.GetURLEncodedAsUTF8(userinfo.Name);
	strReturnURL = strURL$"?"$"target="$lineage2WebID$"&"$"server_id="$serverNo$"&"$"char_name="$strURLEncoded;
	if (Len(strExtraParam) > 0 )
	{
		strReturnURL = strReturnURL$"&"$strExtraParam;
	}

	//debug("[InGameWebWnd]strReturnURL="$strReturnURL$"==================================");
	
	// parameter 포함 전체 경로 URL Encoding.
	strURLEncoded = m_hBrowserViewer.GetURLEncodedAsUTF8(strReturnURL);

	return strURLEncoded;
}*/
////// Awesomium ver 1.6.6 사용 시. CEF 교체 후 삭제할 것. /////////////////////////////////

// sample: "gcsweblin2.plaync.com/home/main?target={petition_id}&server_id={server_num}&char_name={user_name}"
function String GetParameterForNPSession(String strURL, out array<WebRequestParam> arrParams)
{
	local UserInfo userinfo;
	local int serverNo;
	local int lineage2WebID;

	local string strExtraParam;
	local int nStrIndex;
	local int nArrayIndex;
	local string strKey;
	local string strValue;
	
	nStrIndex = InStr(strURL, "?");
	if (nStrIndex > 0)
	{
		// ? 이후에 파라메터를 얻는다.
		strExtraParam = Mid(strURL, nStrIndex+1);
	
		// ? 이후에 붙은 파라메터를 제외하고 URL를 얻는다.
		strURL = Left(strURL, nStrIndex);	

		//debug("[InGameWebWnd]strURL="$strURL$" ExtraParam="$strExtraParam);
	}

	// default setting for in game browser petition 
	lineage2WebID = LINEAGE2_WEB_ID;
	serverNo = GetServerNo();
	GetPlayerInfo(userinfo);
	
	nArrayIndex = arrParams.Length;
	
	arrParams.Insert(nArrayIndex, 1);
	arrParams[nArrayIndex].strKey = "target";
	arrParams[nArrayIndex].strValue = string(lineage2WebID);
	nArrayIndex++;
	
	arrParams.Insert(nArrayIndex, 1);
	arrParams[nArrayIndex].strKey = "server_id";
	arrParams[nArrayIndex].strValue = string(serverNo);
	nArrayIndex++;
	
	arrParams.Insert(nArrayIndex, 1);
	arrParams[nArrayIndex].bNeedUrlEncode = true;	// 캐릭터명만 URL Encoding.
	arrParams[nArrayIndex].strKey = "char_name";
	arrParams[nArrayIndex].strValue = userinfo.Name;
	nArrayIndex++;
	
	if (Len(strExtraParam) > 0)
	{
		nStrIndex = InStr(strExtraParam, "=");
		while (nStrIndex > 0)
		{
			// '=' 이전 문자열(key값)을 얻는다.
			strKey = Left(strExtraParam, nStrIndex);
			
			// '=' 이후 문자열에 '&' 문자가 있는지 검사.
			strExtraParam = Mid(strExtraParam, nStrIndex+1);
			nStrIndex = InStr(strExtraParam, "&");
			if (nStrIndex > 0 )
			{
				// '&' 문자 이전 문자열(value값)을 얻는다.
				strValue = Left(strExtraParam, nStrIndex);
				strExtraParam = Mid(strExtraParam, nStrIndex+1);
			}
			else
			{
				// 나머지 문자열을 value 값으로 넣는다.
				strValue = strExtraParam;
			}
			
			// parameter array에 추가.
			arrParams.Insert(nArrayIndex, 1);
			arrParams[nArrayIndex].strKey = strKey;
			arrParams[nArrayIndex].strValue = strValue;
			nArrayIndex++;
			
			nStrIndex = InStr(strExtraParam, "=");
		}
	}

	return strURL;
}

function CloseAnotherWebWnd()
{
	// todo : 여기서 기존에 열려있던 NP 토큰으로 세션 생성을 진행한 창들은 닫는다.
	// 현재는 진정창 이다. -> 진정창이 뜰때도 해당 창이 닫혀야 한다. - y2jinc
}

function bool GetUrlPageAtL2INI(String category, out String outURL)
{
	local String strSection;

	// 라이브도 들어가게되면 라이블일때도 섹션 이름 정해서 들어가야 함.
	if (getInstanceUIData().getIsClassicServer())
	{
		strSection = INGAMEWEB_SECTION_CLASSIC;
	}
	else 
	{
		strSection = INGAMEWEB_SECTION_LIVE;
	}
	
	if (GetINIString(strSection, category, outURL, "l2.ini"))
	{
		return true;
	}

	//debug("[InGameWebWnd] >> section :" @ strSection @ "category : " @ category @ "is not exist.(l2.ini)");

	return false;
}

// 특정 URL을 NP 서버로 부터 토큰 정보를 받아 온 후 
// 페이지를 요청 하는 함수.
function NavigateUrlPage(String strURL)
{
//	local String strParameter;
	local String strNpLoginWebURL;
	local WebRequestInfo requestInfo;

	// 차원 이동 후 
	if ( IsPlayerOnWorldRaidServer() ) 
	{
		getInstanceL2Util().showGfxScreenMessage( GetSystemMessage(4047));
		return;
	}

	m_hIngameWebWnd.ShowWindow();
	m_hIngameWebWnd.SetFocus();

	debug("[InGameWebWnd]NavigateUrlPage URL :" @ strURL);

	// 게임서버로부터 받은 session_id로 인증받던 WSM 기반 방식에서 Cligate를 통해 받은 AuthnToken 값으로 인증 받는 NP 기반 방식으로 변경 됨.
	if (GetINIString("URL", "NPLoginWebURL", strNpLoginWebURL, "l2.ini"))
	{
		CloseAnotherWebWnd();

	////// Awesomium ver 1.6.6 사용 시. CEF 교체 후 삭제할 것. /////////////////////////////////
	/*	m_hBrowserViewer.BeginParam("");

		m_bCheckFinishPageForSession = TRUE; // 세션 연장 관련해서 필요한 플래그.
		m_hIngameWebWnd.KillTimer(TIMER_ID_WEB_SESSION);
		m_hBrowserViewer.WithWebSession();	 // NP 로 부터 세션 정보를 받기위해서는 해당 함수를 불러줘야 함.

		// 아래 parameter 정보는 결국 strNpLoginWebURL$strParameter 형식으로 페이지를 요청 하게 됨.
		strParameter = GetParameterForNPSession(strURL);
		m_hBrowserViewer.PushParam("return_url", strParameter);

		// "/sso"는 NP 로그인웹의 토큰으로 로그인 요청 페이지.
		m_hBrowserViewer.NavigateAsGet(strNpLoginWebURL$"/sso");*/
	////// Awesomium ver 1.6.6 사용 시. CEF 교체 후 삭제할 것. /////////////////////////////////
	
		m_bCheckFinishPageForSession = TRUE; // 세션 연장 관련해서 필요한 플래그.
		m_hIngameWebWnd.KillTimer(TIMER_ID_WEB_SESSION);
	
		requestInfo.eMethodType = EWMT_GET;
		requestInfo.strRequestUrl = GetParameterForNPSession(strURL, requestInfo.arrRequestParams);
		requestInfo.strNPAuthTokenLoginUrl = strNpLoginWebURL $ "/sso";
		requestInfo.arrHeaderParams.Length = 1;
		requestInfo.arrHeaderParams[0].strKey = "User-Agent";
		requestInfo.arrHeaderParams[0].strValue = "Lineage2";
		
		m_hBrowserViewer.Navigate(requestInfo);

		m_strRequestURL = strURL;
	}
}

// 특정 URL을 NP 서버로 부터 토큰 정보를 받아 올 필요 없이 
// 페이지를 요청 하는 함수. - 테스트 용도로 만듬 - y2jinc
function NavigateUrlPageWithoutNPToken(String strURL)
{
	local WebRequestInfo requestInfo;
	
	m_hIngameWebWnd.ShowWindow();

	debug("[InGameWebWnd]NavigateUrlPageWithoutNPToken URL :" @ strURL);	
	
////// Awesomium ver 1.6.6 사용 시. CEF 교체 후 삭제할 것. /////////////////////////////////
/*	m_hBrowserViewer.WithoutWebSession();
	m_hBrowserViewer.BeginParam("");	

	m_hBrowserViewer.NavigateAsGet(strURL);*/
////// Awesomium ver 1.6.6 사용 시. CEF 교체 후 삭제할 것. /////////////////////////////////
	
	requestInfo.eMethodType = EWMT_GET;
	requestInfo.strRequestUrl = strURL;
	
	// 테스트 페이지에서도 User-Agent 값 변경 기능을 테스트 할 수 있도록 추가한 것.
	requestInfo.arrHeaderParams.Length = 1;
	requestInfo.arrHeaderParams[0].strKey = "User-Agent";
	requestInfo.arrHeaderParams[0].strValue = "Lineage2";
	
	m_hBrowserViewer.Navigate(requestInfo);
	
	m_strRequestURL = strURL;
}

// 세션 연결 확인.(개발망만 가능)
function bool TestCheckSession()
{
	local WebRequestInfo requestInfo;

////// Awesomium ver 1.6.6 사용 시. CEF 교체 후 삭제할 것. /////////////////////////////////
/*	m_hBrowserViewer.BeginParam("");
	m_hBrowserViewer.WithoutWebSession();
	m_hBrowserViewer.NavigateAsGet("http://mlogin.plaync.com/test/ingamesso");*/
////// Awesomium ver 1.6.6 사용 시. CEF 교체 후 삭제할 것. /////////////////////////////////
	
	requestInfo.eMethodType = EWMT_GET;
	requestInfo.strRequestUrl = "http://dev.mlogin.plaync.com/test/ingamesso";
	
	m_hBrowserViewer.Navigate(requestInfo);

	debug("[InGameWebWnd]TestCheckSession");
	return true;
}


// 세션연장 하기(1 시간 연장 된다)
function bool RefreshWebSession()
{
	local String strNpLoginWebURL;
	local WebRequestInfo requestInfo;

	if (GetINIString("URL", "NPLoginWebURL", strNpLoginWebURL, "l2.ini"))
	{
	////// Awesomium ver 1.6.6 사용 시. CEF 교체 후 삭제할 것. /////////////////////////////////
	/*	m_hBrowserForSessionRefresh.BeginParam("");
		m_hBrowserForSessionRefresh.WithoutWebSession();	// NP로부터 세션 정보를 받을 필요 없을때 부름.		
		m_hBrowserForSessionRefresh.NavigateAsGetJson(strNpLoginWebURL$"/check"$"?return_url=about:blank");*/
	////// Awesomium ver 1.6.6 사용 시. CEF 교체 후 삭제할 것. /////////////////////////////////
		
		requestInfo.eMethodType = EWMT_GET;
		requestInfo.strRequestUrl = strNpLoginWebURL$"/check";
		requestInfo.arrRequestParams.Length = 1;
		requestInfo.arrRequestParams[0].strKey = "return_url";
		requestInfo.arrRequestParams[0].strValue = "about:blank";
		requestInfo.arrHeaderParams.Length = 1;
		requestInfo.arrHeaderParams[0].strKey = "Accept";
		requestInfo.arrHeaderParams[0].strValue = "application/json";
		
		m_hBrowserForSessionRefresh.Navigate(requestInfo);
	}

	debug("[InGameWebWnd]RefreshWebSession");
	return true;
}

function OnHide()
{
	m_hIngameWebWnd.KillTimer(TIMER_ID_WEB_SESSION);
	m_bCheckFinishPageForSession = FALSE;

	lastShowCategory = "";

////// Awesomium ver 1.6.6 사용 시. CEF 교체 후 삭제할 것. /////////////////////////////////
/*	// 닫을 때 초기화 목적으로 빈 페이지 불러준다.
	m_hBrowserViewer.BeginParam("");
	m_hBrowserViewer.WithoutWebSession();	
	m_hBrowserViewer.NavigateAsGet("about:blank");*/
////// Awesomium ver 1.6.6 사용 시. CEF 교체 후 삭제할 것. /////////////////////////////////
	
	m_hBrowserViewer.HideWindow();
	m_hBrowserForSessionRefresh.HideWindow();
}

function OnTimer(int TimerID)
{
	if (TimerID == TIMER_ID_WEB_SESSION)
	{
		RefreshWebSession();
		m_hIngameWebWnd.KillTimer(TIMER_ID_WEB_SESSION);
		m_hIngameWebWnd.SetTimer(TIMER_ID_WEB_SESSION, REFRESH_WEB_SESSION_TIME);
	}
}

function OnWebBrowser_FinishedLoading(String param)
{
	local string url;
	local String strNpLoginWebURL;
	local int Index;

	ParseString(param, "url", url);

	// 세션 연장 처리 관련
	// url 이 로그인 요청 페이지로 시작 됐으면 성공 한거당.
	if (m_bCheckFinishPageForSession && GetINIString("URL", "NPLoginWebURL", strNpLoginWebURL, "l2.ini"))
	{
		Index = InStr(url, m_strRequestURL);
		if (Index >= 0)
		{
			m_hIngameWebWnd.KillTimer(TIMER_ID_WEB_SESSION);
			m_hIngameWebWnd.SetTimer(TIMER_ID_WEB_SESSION, REFRESH_WEB_SESSION_TIME);
			m_bCheckFinishPageForSession = FALSE;
		}	
	}

	debug("[InGameWebWnd]EV_WebBrowser_FinishedLoading >> " @ url @ m_bCheckFinishPageForSession);
	debug("[InGameWebWnd]EV_WebBrowser_FinishedLoading >> GetURL" @ m_hBrowserViewer.GetUrl());
}

function OnWebBrowser_ReceivedTitle(string param)
{
	local string WindowName;
	local string Title;

	ParseString(param, "WindowName", WindowName);
	ParseString(param, "Title", Title);

	if (InStr(WindowName, "IngameWebWnd") >= 0 && Len(Title) > 0)
	{
		m_hIngameWebWnd.SetWindowTitle(Title);
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

	Debug("m_WindowName>>>>>>" @ m_WindowName);
}

function onShow()
{	
	if ( class'UIAPI_WINDOW'.static.IsShowWindow ( "WebPetitionWnd") ) 
		class'UIAPI_WINDOW'.static.HideWindow( "WebPetitionWnd");
		
	m_hBrowserViewer.ShowWindow();
}

defaultproperties
{
    m_WindowName="IngameWebWnd"
}
