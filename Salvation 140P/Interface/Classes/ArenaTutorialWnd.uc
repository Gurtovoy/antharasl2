class ArenaTutorialWnd extends UICommonAPI;


var string m_WindowName;

var WindowHandle	m_hNPCDialogViewPortWnd;
var WindowHandle    m_hViewPortWndMonster;
var HtmlHandle		m_hHtmlViewer;
var ViewPortWndMonster     m_hViewPortWndMonsterScript;

//var bool	m_bRecievedCloseUI;
//var bool	m_bNpcZoomMode;

//var Vector locPosition;

//const TIMER_UPDATE_LOC = 0 ;
//const TIMER_UPDATEDELAY = 10 ;

function OnRegisterEvent()
{
	//RegisterEvent(EV_NPCDialogWndShow);
	//RegisterEvent(EV_NPCDialogWndHide);
	//RegisterEvent(EV_NPCDialogWndLoadHtmlFromString);
	//RegisterEvent(EV_QuestIDWndLoadHtmlFromString);

	RegisterEvent(EV_HtmlWithNPCViewport);
	RegisterEvent(EV_HtmlWithNPCViewportClose);
	 

	// register gamingstate enter/exit event 
	// - 등록하지 않으면, 처음 호출될때 OnEnter와 OnExit가 호출되지 않음.
	//RegisterEvent(EV_GamingStateEnter);
	//RegisterEvent(EV_GamingStateExit);	
}

function OnLoad()
{
	SetClosingOnESC();
	
	m_hNPCDialogViewPortWnd=GetWindowHandle(m_WindowName);
	m_hHtmlViewer=GetHtmlHandle(m_WindowName$".HtmlViewer");
	m_hViewPortWndMonster = GetWindowHandle("ViewPortWndMonster");
	m_hViewPortWndMonsterScript = ViewPortWndMonster( GetScript( "ViewPortWndMonster"));
}


function OnSetFocus ( WindowHandle a_WindowHandle, bool isFocused ) 
{	
	if ( isFocused )  m_hViewPortWndMonster.BringToFront();
}

function onShow()
{	
	//getInstanceL2Util().syncWindowLoc(getCurrentWindowName(string(Self)), "QuestHTMLWnd,m_hNPCDialogViewPortWnd");
	// 멀티셀이 열려 있다면 닫는다.
	//if(GetWindowHandle("MultiSellWnd").IsShowWindow()) GetWindowHandle("MultiSellWnd").HideWindow();	
}

function OnHide()
{
	//ProcCloseNPCDialogWnd();
	//getInstanceL2Util().syncWindowLocAuto("QuestHTMLWnd,m_hNPCDialogViewPortWnd");
	m_hViewPortWndMonster.HideWindow();
	m_hViewPortWndMonster.ClearAnchor();	

//	m_hNPCDialogViewPortWnd.KillTimer(TIMER_UPDATE_LOC);	
}


function OnEvent(int Event_ID, String param)
{
	//Debug( "OnEvent" @ Event_ID @ param );
	switch(Event_ID)
	{
	//case EV_NPCDialogWndShow :
	//	ShowNPCDialogWnd();
	//	break;
		
	//case EV_NPCDialogWndHide :
	//	HideNPCDialogWnd();
	//	break;
		
	//case EV_NPCDialogWndLoadHtmlFromString :
	//	m_hNPCDialogViewPortWnd.SetWindowTitle(GetSystemString(444));	 //타이틀을 "대화"로 바꿔준다. 
	//	HandleLoadHtmlFromString(param);
	//	break;
	//case EV_QuestIDWndLoadHtmlFromString:
	//	m_hNPCDialogViewPortWnd.HideWindow();
	//	break;
	case EV_HtmlWithNPCViewportClose :
		m_hNPCDialogViewPortWnd.HideWindow();
		break;
	case EV_HtmlWithNPCViewport :		
		handleHtmlViewPort (param);
		break;
	}
}

function handleHtmlViewPort ( string param ) 
{		
	local int ID, Show, SocialAnim, AttackAnim ;
	local string htmlStr ;

	ParseInt ( param, "ID", ID );

	if ( ID == -1 ) 
		m_hNPCDialogViewPortWnd.HideWindow();

	ParseInt ( param, "Show", Show );	
	ParseString ( param, "HtmlStr", htmlStr );
	loadHtml( htmlStr ) ;

	ShowWindowWithFocus(m_WindowName);

	m_hViewPortWndMonsterScript.SetNPCViewportData( ID ) ;
	
	if ( Show == 1 ) m_hViewPortWndMonsterScript.SpawnNPC();

	ParseInt ( param, "AttackAnim", AttackAnim );
	ParseInt ( param, "SocialAnim", SocialAnim );

	m_hViewPortWndMonster.ShowWindow();
	m_hViewPortWndMonster.SetAnchor( m_WindowName, "CenterRight", "CenterLeft", 0, 0 );

	m_hViewPortWndMonster.BringToFront() ;	
	
	if ( AttackAnim > -1 )  m_hViewPortWndMonsterScript.PlayAnimation( AttackAnim ) ;
	else if ( SocialAnim > -1 ) m_hViewPortWndMonsterScript.PlayAnimation( SocialAnim ) ;
}

//function OnHtmlMsgHideWindow(HtmlHandle a_HtmlHandle)
//{
//	if(a_HtmlHandle==m_hHtmlViewer)	
//		m_hNPCDialogViewPortWnd.HideWindow();		
//}

//function HandleLoadHtmlFromString(string param)
//{
//	local string htmlString;
//	ParseString(param, "HTMLString", htmlString);

//	m_hHtmlViewer.LoadHtmlFromString(htmlString);
//}

/******************************************************************************************************************************
 * desc를 불러 오는 곳
 * ****************************************************************************************************************************/
function loadHtml ( string param )
{	
	m_hHtmlViewer.LoadHtmlFromString(htmlSetHtmlStart(param));
	m_hNPCDialogViewPortWnd.SetFocus();
}

function string htmlSetHtmlStart(string targetHtml)
{
	return "<html><body>" $ targetHtml $ "</body></html>";
}

//function ShowNPCDialogWnd()
//{	
//	m_hNPCDialogViewPortWnd.ShowWindow();
//	m_hNPCDialogViewPortWnd.SetFocus();
//	handleSetTargetData();
//}

//function HideNPCDialogWnd()
//{
//	m_hNPCDialogViewPortWnd.HideWindow();
//}

//function ProcCloseNPCDialogWnd()
//{
//	if( m_bRecievedCloseUI && m_bNpcZoomMode )
//	{
//		// must first m_bReShowNPCDialogWnd be false because calling recursive function.	
//		m_bRecievedCloseUI = false;		
//		RequestFinishNPCZoomCamera();		
//	}
//}

//
//function handleSetTargetData () 
//{
//	local UserInfo	info;	

//	GetTargetInfo(info);	
//	if ( info.nID < 1 )  
//	{
//	//	m_hNPCDialogViewPortWnd.HideWindow();
////		m_hNPCDialogViewPortWnd.KillTimer ( TIMER_UPDATE_LOC );
//		return;
//	}	
	
//	locPosition = info.Loc;

//	m_hNPCDialogViewPortWnd.SetWindowTitle(info.strNickName $ "­" $ info.Name ) ;
//	m_hViewPortWndMonster.ShowWindow();
//	m_hViewPortWndMonster.SetAnchor( "NPCDialogViewPortWnd", "CenterRight", "CenterCenter", 60, 70 );
//	m_hViewPortWndMonster.BringToFront() ;
//	m_hViewPortWndMonsterScript.SetNPCInfo( info.nClassID );
//	m_hViewPortWndMonsterScript.SpawnNPC();
//	m_hViewPortWndMonsterScript.PlayAnimation( 0 ) ;

//	//m_hNPCDialogViewPortWnd.SetTimer(TIMER_UPDATE_LOC, TIMER_UPDATEDELAY);
//}

// 거리에 따라 창을 닫음
//function OnTimer(int TimerID)
//{
//	local userinfo myInfo ;
//	local int c ;
//	if(TimerID == TIMER_UPDATE_LOC)
//	{
//		GetPlayerInfo ( myInfo  );		
		
//		// 거리 구하는 공식.... ㄷㄷ 
//		// 각도에 따라 더하고 빼는 순서를 바꿔야 한다.
//		c = sqrt( (locPosition.x - myInfo.Loc.x)^2  + (locPosition.y - myInfo.Loc.y)^2 + (locPosition.z - myInfo.Loc.z)^2 );
//		//if (  < c  ) 
//		//Debug( "OnTimer" @ TimerID @ c ) ;
//	}
//}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{	
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	m_hNPCDialogViewPortWnd.HideWindow();	
}

defaultproperties
{
    m_WindowName="ArenaTutorialWnd"
}
