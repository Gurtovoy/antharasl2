//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : Menu 스케일폼 버전 - SCALEFORM UI
//                메인 메뉴
//
//------------------------------------------------------------------------------------------------------------------------
class MenuWnd extends L2UIGFxScript;

// var int underMenuCount  ;

var bool isPrologueGrowTypeState;

function OnRegisterEvent()
{
	RegisterEvent( EV_GamingStateEnter );
	//RegisterGFxEvent( EV_ResolutionChanged );
	RegisterGFxEvent( EV_SetEnterChatting );
	RegisterGFxEvent( EV_UnSetEnterChatting );
	RegisterGFxEvent( EV_ShowWindow );
	RegisterEvent( EV_StateChanged );
	registerEvent( EV_ChangedSubjob );
}

function OnLoad()
{	
	// 어느 콘테이너에 넣을 건지 선언
	SetContainerWindow(WINDOWTYPE_NOBG_NODRAG, 0);
	AddState("ARENAGAMINGSTATE");
	AddState("ARENABATTLESTATE");
	AddState("GAMINGSTATE");	
	AddState("ARENAOBSERVERSTATE");
	/*
	 * 열릴 때 포커스가 컨테이너에서 각 창으로 옮겨 짐
	 * 그 때 포커스를 잃어 버린 것으로 되어 다시 닫히는 현상을 방지
	 * SetFocus() 는 manager 에서 show 할 때 처리 됩니다.
	 */
	SetHavingFocus( false );
}

/* 메뉴 클릭 시 어떤 작동을 할지 적어 넣으면 됩니다. */
function onMenuClick ( string menuName ) 
{
	switch ( menuName ) 
	{
		case "Attend": RequestAttendanceWndOpen(); break;
		case "nShop" : clickNShopMenu(); break;
		default : showHide ( menuName ) ;
	}
}

// n샵 클릭 
function clickNShopMenu()
{
	NoticeWnd(GetScript("NoticeWnd")).showHideL2InGameWeb("nshop", "");
}

function showHide ( string menuName ) 
{	
	if ( class'UIAPI_WINDOW'.static.IsShowWindow(menuName) )
		class'UIAPI_WINDOW'.static.HideWindow (menuName) ;
	else 
		class'UIAPI_WINDOW'.static.ShowWindow (menuName) ;
}


/* 첫 서브 메뉴 */
function SetLISTSUBDATA()
{
	local ELanguageType Language;		
	local bool isClassic, isKorean, isArena;

	isArena = getInstanceUIData().getIsArenaServer();
	isClassic = getInstanceUIData().getIsClassicServer();	

	Language = GetLanguage();
	isKorean = Language == ELanguageType.LANG_Korean;

	//* 상품인벤토리 - UseGoodsInventory 옵션 없으면 사용 하지 않음.
	setList( 2469, "Productinven", "", !GetINIBool2Bool( "PrimeShop", "UseGoodsInventory" ) || isArena || isPrologueGrowTypeState ); 
	//개인상점
	setList( 498,  "Shop", "", isArena || isPrologueGrowTypeState );	                
	inputDivision( ); // 분리선 /*------------------------------------------------------------------- */  		
	//* 출석부- UseVIPAttendance 옵션에 따라 사용 하지 않음.
	setLIST( 5190, "Attend", "AttendCheckWnd", !getUseVipAttendance() || isPrologueGrowTypeState);
	//* 몬스터 도감 윈도우 - 클래식, 아레나에서 사용하지 않음.
	setLIST( 3511, "MonsterBookWnd", "MonsterBookWnd", isClassic || isArena || isPrologueGrowTypeState);
	//* 세력 윈도우 - 클래식, 아레나에서 사용하지 않음.
	setLIST( 3443, "Faction", "FactionWnd", isClassic || isArena || isPrologueGrowTypeState);
	//우편함
	setList( 2074, "Post",  "PostWnd", isArena || isPrologueGrowTypeState);	                
	//혈맹 가입
	setList( 3068, "ClanSearch","",  isArena || isPrologueGrowTypeState);
	// 아레나 랭킹 
	setList( 4528,  "ArenaRanking",  "ArenaRankingWnd", !isArena || isPrologueGrowTypeState );
	//파티메칭
	setList( 389,  "PartyMatch",  "PartyMatchWnd", isArena || isPrologueGrowTypeState);	
	//인맥	
	setList( 2383, "PersonalConnection", "PersonalConnectionsWnd" , isPrologueGrowTypeState );  	
	//* 게시판/묻고답하기 - 클래식 이거나 해외 사용안함. 2013.12.06 
	setLIST( 3136,  "Qna", "", ( isClassic || !isKorean || isArena ));
	//게시판
	setList( 387,  "Bbs", "BoardWnd", isArena);          
	inputDivision( ); // 분리선 /*------------------------------------------------------------------- */  	
	//추가기능
	setList( 2642, "Add");	                    
	inputDivision( ); // 분리선 /*------------------------------------------------------------------- */  
	//서비스
	setList( 2643, "Service");  	
	//리니지2 홈 - 해외 아레나에서 사용 안함. 
	setLIST( 3471, "IngameWeb", "IngameWebWnd",isArena || !isKorean || getInstanceUIData().getIsArenaServer() ); 

	// n샵 (스트링 
	setLIST( 3634, "NShop", "IngameWebWnd",isArena || !isKorean || isPrologueGrowTypeState ); 

	inputDivision( ); // 분리선 /*------------------------------------------------------------------- */  
	 //단축키
	setList( 1523, "ShortcutAssign");	                 
	//매크로
	setList( 711,  "Macro", "MacroWnd", isArena);           
	//옵션
	setList( 146,  "Option", "OptionWnd");          
	inputDivision( ); // 분리선 /*------------------------------------------------------------------- */  
	//리스타트
	setList( 147,  "Restart", "", GetGameStateName() == "ARENABATTLESTATE");      	
	//게임 종료
	setList( 148,  "Exit");                   
}

/* 2차 서브 메뉴 */
function setLISTUnderDATA()
{		
	local bool isArena, isClassic, isKorean;
	local string parentName ;
	local ELanguageType Language;		
	
	Language = GetLanguage();
	isKorean = Language == ELanguageType.LANG_Korean;
	isArena = getInstanceUIData().getIsArenaServer();
	isClassic = getInstanceUIData().getIsClassicServer();
	
	parentName = "Shop" ; // 판매	    /* --------------------------------------------------------------------- */ 
	//판매상점
	setLISTSUB( parentName, 2644, "ShopSell"); 
	//구매상점
	setLISTSUB( parentName, 2645, "ShopBuy");     
	//일괄판매상점
	setLISTSUB( parentName, 2646, "ShopSellAll");
	//상점검색
	setLISTSUB( parentName, 1283, "ShopSearch"); 	
	
	parentName = "Add" ; // 추가기능	/* --------------------------------------------------------------------- */ 	
	//인스턴스 존 - 2015.12.09 클래식 몬스터 투기장 추가로 클래식에서도 보이도록 수정
	setLISTSUB( parentName, 2796, "InstancedZone", "", isArena); 
	//* PC방 이벤트 - 클래식 혹은 UsePCBangPoint 옵션에 따라 사용 안함.
	setLISTSUB( parentName, 1277, "PcRoom", "", ( isArena || isClassic || !GetINIBool2Bool ("Localize", "UsePCBangPoint")));      
	//동영상 녹화
	setLISTSUB( parentName, 2448, "Rec");         
	//리플레이 녹화
	setLISTSUB( parentName, 2647, "ReplayRec");
	
	parentName = "Service" ; // 서비스	/* --------------------------------------------------------------------- */ 	
	//* 도움말 - 클래식 도움말이 없나?? 
	setLISTSUB( parentName, 145, "Help", "", isClassic || isArena);	
	//* 1:1문의 - 해외에서 사용 안함. 	
	setLISTSUB( parentName, 470, "Petition", "", !isKorean || isArena);  	
	//* 리니지2 소식 - 해외에서 사용 하지 않는 메뉴 2013.12.0	// 18.02.20 해외도 이제 사용함.
	setLISTSUB(parentName,3169,"IngameNotice","",(!isKorean && Language != ELanguageType.LANG_Japanese));
	//홈페이지
	setLISTSUB( parentName, 2257, "Homepage");      
	//* 페스 투 어웨이큰 - 옵션 값에 따라 적용
	setLISTSUB( parentName, 5178, "PathToAwakening", "",  !GetINIBool2Bool("Localize", "UsePathToAwakening"));	
	//* 나이 제한 정보 - 한국에만 보여짐
	setLISTSUB( parentName, 3327, "PlayerAge", "", !isKorean);
}

function StartSubMenu()
{
	callGFxFunction ( getCurrentWindowName(String(self)), "evMenuSubStart", "" );
}

function EndSubMenu()
{
	callGFxFunction ( getCurrentWindowName(String(self)), "evMenuSubEnd", "" );
}

function inputDivision()
{	
	callGFxFunction ( getCurrentWindowName(String(self)), "evMenuSubList", "");
}

function setList ( int stringNum, string menuName, optional string tooltipKey, optional bool notUse ) 
{
	setLISTSUB ( "", stringNum, menuName, tooltipKey,  notUse == true) ;
}

function setLISTSUB( string parentMenuName, int stringNum, string menuName, optional string tooltipKey, optional bool notUse)
{
	local string strParam;
		
	if ( notUse ) return;
	ParamAdd(strParam, "parentMenuName", parentMenuName );
	ParamAdd(strParam, "stringNumber", String( stringNum ) );	
	ParamAdd(strParam, "menuName", menuName );	
	ParamAdd(strParam, "tooltipKey", tooltipKey );
	
	callGFxFunction ( getCurrentWindowName(String(self)), "evMenuSubList", strParam);
}

/* 형 번환 함수 들 */
function int  b2i( bool value) { if ( value ) return 1; else return 0;}
function bool i2b( int value ) { if ( value == 0 ) return false; else return true;}
function bool GetINIBool2Bool ( string category, string itemname ) 
{
	local int bValue ;
	if ( ! GetINIBool( category, itemname, bValue, "L2.ini") ) return false;
	return i2b ( bValue ) ;
}

// 출석체크 조건 받기 
function bool getUseVipAttendance ( ) 
{
	local string UseVIPAttendanceItemName;
	
	if (getInstanceUIData().getIsClassicServer())
		UseVIPAttendanceItemName = "UseVIPAttendanceClassic";
	else
		UseVIPAttendanceItemName = "UseVIPAttendanceLive";

	return GetINIBool2Bool("Localize", UseVIPAttendanceItemName);//조건검색	
}

// 프롤로그 전직 
function handleChangedSubjob( string param ) 
{
	local bool tmpIsPrologueGrowTypeState ;

	tmpIsPrologueGrowTypeState = getisPrologueGrowTypeState( param ) ;
	if ( tmpIsPrologueGrowTypeState != isPrologueGrowTypeState )
	{
		isPrologueGrowTypeState = tmpIsPrologueGrowTypeState;
		StartSubMenu();
		SetLISTSUBDATA();
		SetLISTUnderDATA();
		EndSubMenu();
	}
}

function bool getisPrologueGrowTypeState ( string param ) 
{
	local int currentClassID ;

	if ( param != "" )  ParseInt(param, "CurrentSubjobClassID", currentClassID) ;
	return getInstanceL2Util().getIsPrologueGrowType( currentClassID );
}

/* 이벤트들 */
function OnSHow ( ) 
{
	handleChangedSubjob( "" ) ;
}

function OnEvent(int Event_ID, string param)
{
	if( Event_ID == EV_GamingStateEnter )
	{
		isPrologueGrowTypeState = getisPrologueGrowTypeState( "" );

		StartSubMenu();
		SetLISTSUBDATA();
		SetLISTUnderDATA();
		EndSubMenu();
	}
	else if ( Event_ID == EV_ChangedSubjob ) 
	{
		handleChangedSubjob( param );
	}
	else if( Event_ID == EV_StateChanged)
	{
		if ( !getInstanceUIData().getIsArenaServer() )  return;
		StartSubMenu();
		SetLISTSUBDATA();
		SetLISTUnderDATA();
		EndSubMenu();
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
