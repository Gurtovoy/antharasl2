//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : Menu 스케일폼 버전 - SCALEFORM UI
//                메인 메뉴
//
//------------------------------------------------------------------------------------------------------------------------
class Menu extends L2UIGFxScript;

//플래쉬 옵셋 좌표
const FLASH_XPOS = 0;
const FLASH_YPOS = -20;

function OnRegisterEvent()
{
	RegisterGFxEvent( EV_SetEnterChatting );
	RegisterGFxEvent( EV_UnSetEnterChatting );
	RegisterEvent( EV_GamingStateEnter );
	
}

function OnLoad()
{	
	// 어느 콘테이너에 넣을 건지 선언
	//SetContainer( "containerHUD" ); 
	SetContainerHUD(WINDOWTYPE_NONE, 0);
	AddState("GAMINGSTATE");
	AddState("ARENAGAMINGSTATE");
	AddState("ARENABATTLESTATE");
	AddState("ARENAOBSERVERSTATE");
	setDefaultShow(true);
	//setHUD();
	//SetAnchor("", EAnchorPointType.ANCHORPOINT_BottomRight, EAnchorPointType.ANCHORPOINT_BottomRight, FLASH_XPOS, FLASH_YPOS);
	
	SetAlwaysFullAlpha( true );
	SetHavingFocus( false );	
}



/* 메뉴 클릭 시 어떤 작동을 할지 적어 넣으면 됩니다. */
function onMenuClick ( string menuName ) 
{
	switch ( menuName ) 
	{
		//ex) case "Attend": RequestAttendanceWndOpen(); break;
	}
}


function setLISTDATA()
{	
	//상단 왼쪽에서부터 쌓이기 시작.
	if( getInstanceUIData().getIsArenaServer() ) 
	{		
		//인벤
		setLIST(0, 1,   "Inven",    "InventoryWnd" );   
		//액션
		setLIST(0, 127, "Action",   "ActionWnd" ); 
		//스킬
		setLIST(0, 119, "Skill",    "MagicskillWnd" );  		
		//모든 메뉴
		setLIST(0, 2641,"MenuAll",  "SystemMenuWnd" );  
	}
	else 
	{
		//캐릭터 정보
		setLIST(0, 434 ,"Char",     "DetailStatusWnd" );
		//인벤
		setLIST(0, 1,   "Inven",    "InventoryWnd" );   
		//액션
		setLIST(0, 127, "Action",   "ActionWnd" ); 
		//스킬
		setLIST(0, 119, "Skill",    "MagicskillWnd" );  
		//퀘스트
		setLIST(1, 198 ,"Quest",    "QuestTreeWnd" );   
		//혈맹
		setLIST(1, 314, "Clan",     "ClanWnd" );    
		//미니맵
		setLIST(1, 447, "Map",      "MinimapWnd" );    
		//모든 메뉴
		setLIST(1, 2641,"MenuAll",  "SystemMenuWnd" );  
	}
}

function StartMenu()
{
	callGFxFunction ( getCurrentWindowName(String(self)), "evMenuStart", "" );
}

function EndMenu()
{
	callGFxFunction ( getCurrentWindowName(String(self)), "evMenuEnd", "" );
}

function setLIST(int lineNum, int stringNum, string menuName, string tooltipKey)
{
	local string strParam;

	ParamAdd(strParam, "lineNum", String ( lineNum ) );		
	ParamAdd(strParam, "stringNumber", String( stringNum ) );
	ParamAdd(strParam, "menuName", menuName );	
	ParamAdd(strParam, "tooltipKey", tooltipKey );		
	callGFxFunction ( getCurrentWindowName(String(self)), "evMenuList", strParam);
	
}

/* 이벤트들 */
function OnEvent(int Event_ID, string param)
{
	if( Event_ID == EV_GamingStateEnter )
	{
		StartMenu();
		SetLISTDATA();		
		EndMenu();
	}
}

function onCallUCFunction( string functionName, string param )
{
	//local string strParam;
	//Debug("sampe's onCallUCFunction" @ functionName @ param);
	switch ( functionName ) 
	{	
		case "onMenuClick":
			onMenuClick( param ) ;
			break;
	}
}
defaultproperties
{
}
