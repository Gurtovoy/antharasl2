class BoardWnd extends UIScript;

var bool	m_bShow;
var bool	m_bBtnLock;
var string 	m_Command[8];

var HtmlHandle	m_hBoardWndHtmlViewer;

var TabHandle	m_hBoardWndTabCtrl;

function OnRegisterEvent()
{
	RegisterEvent( EV_ShowBBS );
	RegisterEvent( EV_ShowBoardPacket );
}

function OnLoad()
{
	SetClosingOnESC();

	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();


	m_hBoardWndHtmlViewer=GetHtmlHandle("BoardWnd.HtmlViewer");
	m_hBoardWndTabCtrl=GetTabHandle("BoardWnd.TabCtrl");

	m_bShow = false;
	m_bBtnLock = false;
}

function OnShow()
{
	m_bShow = true;
}

function OnHide()
{
	m_bShow = false;
	//class'UIAPI_WINDOW'.static.SetFocus("ChatWnd");	//LDW 2011.09.05 ttp 28561 처리
}

function OnEvent(int Event_ID, string param)
{
	//Debug("OnEvent" @ param) ;
	if (Event_ID == EV_ShowBBS)
	{
		HandleShowBBS(param);
	}
	else if (Event_ID == EV_ShowBoardPacket)
	{
		HandleShowBoardPacket(param);
	}
}

function OnClickButton( string strID )
{	
	//Debug( "-->" @ strID );


	switch( strID )
	{
	case "btnBookmark":
		OnClickBookmark();
		break;
	}
	
	//탭버튼 클릭
	TabButtonClick(strID);
}

function OnRClickButton(string strID) // 우클릭도 처리한다.
{
	TabButtonClick(strID);
}

function TabButtonClick(string strID)
{
	//탭버튼 클릭
	if(Left(strID,7) == "TabCtrl")
	{
		strID = Mid(strID,7);
		if(!class'UIAPI_WINDOW'.static.IsMinimizedWindow("BoardWnd"))
		{
			ShowBBSTab(int(strID));
		}
	}
}

//초기화
function Clear()
{
	
}

function HandleShowBBS(string param)
{
	local int Index;
	local int Init;
	
	ParseInt(param, "Index", Index);
	ParseInt(param, "Init", Init);
	
	//초기상태로 여는가? (SystemMenu로부터)	
	if ( m_bShow )
	{
		PlayConsoleSound(IFST_WINDOW_CLOSE);
		class'UIAPI_WINDOW'.static.HideWindow("BoardWnd");
		return;
	}

	if (Init>0)
	{
		if (!m_hBoardWndHtmlViewer.IsPageLock())
		{
			m_hBoardWndHtmlViewer.SetPageLock(true);
			m_hBoardWndTabCtrl.SetTopOrder(0, false);
			m_hBoardWndHtmlViewer.Clear();
			RequestBBSBoard();
		}		
	//나중에 HandleShowBoardPacket에서 ShowWindow를 한다.
	}
	else
	{
		if ( Index == 8 )
		{
			m_hBoardWndTabCtrl.SetTopOrder(0, false);
		}
		else m_hBoardWndTabCtrl.SetTopOrder(Index, false);
		m_hBoardWndHtmlViewer.Clear();
		ShowBBSTab(Index);
	}
}

function HandleShowBoardPacket(string param)
{
	local int idx;
	local int OK;
	local string Address;
	
	ParseInt(param, "OK", OK);
	if (OK<1)
	{
		class'UIAPI_WINDOW'.static.HideWindow("BoardWnd");
		return;
	}
	
	//Clear
	for (idx=0; idx<8; idx++)
		m_Command[idx] = "";
	
	ParseString(param, "Command1", m_Command[0]);
	ParseString(param, "Command2", m_Command[1]);
	ParseString(param, "Command3", m_Command[2]);
	ParseString(param, "Command4", m_Command[3]);
	ParseString(param, "Command5", m_Command[4]);
	ParseString(param, "Command6", m_Command[5]);
	ParseString(param, "Command7", m_Command[6]);
	ParseString(param, "Command8", m_Command[7]);
	m_bBtnLock = false;
	
	ParseString(param, "Address", Address);
	m_hBoardWndHtmlViewer.SetHtmlBuffData(Address);
	if (!m_bShow)
	{
		PlayConsoleSound(IFST_WINDOW_OPEN);
		class'UIAPI_WINDOW'.static.ShowWindow("BoardWnd");
		class'UIAPI_WINDOW'.static.SetFocus("BoardWnd");
	}
}

function ShowBBSTab(int Index)
{
	local string strBypass;
	local EControlReturnType Ret;
	
	switch( Index )
	{
	//처음으로
	case 0:
		strBypass = "bypass _bbshome";
		break; 
	//즐겨찾기
	case 1:
		strBypass = "bypass _bbsgetfav"; 
		break;
	//홈페이지 링크(10.1.11 문선준 수정)
	case 2:
		strBypass = "bypass _bbslink";
		break;
	////지역링크  2015-09-21 삭제
	//case 3:
	//	strBypass = "bypass _bbsloc";
	//	break;

	//혈맹링크
	case 3:
		strBypass = "bypass _bbsclan";
		break;
	//메모
	case 4:
		strBypass = "bypass _bbsmemo";
		break;
	//메일
	case 5:
		strBypass = "bypass _maillist_0_1_0_";
		break; 
	//친구관리
	case 6:
		strBypass = "bypass _friendlist_0_"; 
		break;
	//게시판/묻고 답하기 - 메인 메뉴, 경험치 바에서 확인 함.
	case 8:
		switch ( GetReleaseMode() ) 
		{
			case RM_DEV :
			//개발망
				strBypass = "bypass _bbslist_1023_1";
				break;
			//RC
			case RM_RC : 		
				strBypass = "bypass _bbslist_8_1";
				break;		
			//test
			case RM_TEST : 
				strBypass = "bypass _bbslist_44_1";
				break;
			//라이브
			case RM_LIVE :
				strBypass = "bypass _bbslist_20_1";
				break;
		}
	}

	Debug("strBypass" @ strBypass);
	
	if (Len(strBypass)>0)
	{
		Ret = m_hBoardWndHtmlViewer.ControllerExecution(strBypass);
		if (Ret == CRTT_CONTROL_USE)
		{
			m_bBtnLock = true;
		}
	}	
}


function OnClickBookmark()
{
	local EControlReturnType Ret;
	
	if (Len(m_Command[7])>0 && !m_bBtnLock)
	{
		Ret = m_hBoardWndHtmlViewer.ControllerExecution(m_Command[7]);
		if (Ret == CRTT_CONTROL_USE)
		{
			m_bBtnLock = true;
		}
	}
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( "BoardWnd" ).HideWindow();
}
defaultproperties
{
}
