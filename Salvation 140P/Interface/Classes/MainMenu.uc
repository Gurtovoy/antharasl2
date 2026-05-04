//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : MainMenu  예전 SystemMenuWnd의 스케일폼 버전 - SCALEFORM UI
//              : MenuWnd.uc + SystemMenuWnd.uc
//                메인 메뉴
//
//------------------------------------------------------------------------------------------------------------------------
class MainMenu extends L2UIGFxScript;
/*
//플래쉬 옵셋 좌표
const FLASH_XPOS = 0;
const FLASH_YPOS = -21;

//SubMenu 넓이 Flash 최대 250 ~ 최소 166까지 막아놓음.
const SUBMENUWIDTH  = 166;
// 중국 쪽은 메뉴가 총10개, 가로 5개 (202픽셀), 한국은166 가로4개 ,두줄 총 8개
const MAINMENUWIDTH = 166; 

//메인 메뉴 리스트 배열
var array<string> LIST;
//메인 메뉴 툴팁 배열
var array<string> LISTCOMMAND;
//메인 메뉴 이름 배열
var array<int> LISTMENUNAME;
//서브1 메뉴 리스트 배열
var array<string> LISTSUB1;
//서브2 메뉴의 서브1 배열
var array<int> LISTSUB2NUM;
//서브1 메뉴 툴팁 배열
var array<string> LISTSUB1COMMAND;
//서브2 메뉴 리스트 배열
var array<string> LISTSUB2;

//현재 지역 PeaceZone인가
var int IsPeaceZone;		

//메뉴를 한번 만들기 위한 변수
var bool IsStart;

//UI용 UC
var L2Util util;

var toolTipWnd toolTipWndGFXScript;

//단축키 툴팁용
var string groupName;

const DIALOGID_Gohome = 4420;
*/
function OnRegisterEvent()
{
	/*
	RegisterEvent( EV_GamingStateEnter );
	RegisterEvent( EV_ShowWindow );

	RegisterEvent( EV_DialogOK );
	RegisterEvent( EV_DialogCancel );

	RegisterEvent( EV_StateChanged );
	RegisterEvent( EV_SetRadarZoneCode ); //branch 111109*/
}

function OnLoad()
{
	/*
	SetClosingOnESC();

	registerState( "MainMenu", "GamingState" );
	//SetAlwaysFullAlpha( true );
	SetHavingFocus( false );
	
	SetHUD();//nextFocus 를 무시 기존에는 SetDefaultShow 가 둘다 처리 했으나 분리 
	SetDefaultShow(true);
	SetAnchor( "", EAnchorPointType.ANCHORPOINT_BottomRight, EAnchorPointType.ANCHORPOINT_TopLeft, 0, 0 );
	//SetAnchor( "", EAnchorPointType.ANCHORPOINT_BottomRight, EAnchorPointType.ANCHORPOINT_BottomRight, FLASH_XPOS, FLASH_YPOS );
	

	groupName = "GamingStateShortcut";
	IsStart = false;

	//메인 메뉴 생성용 배열 생성
	SetLISTDATA();	

	util = L2Util(GetScript("L2Util"));	

	toolTipWndGFXScript = toolTipWnd(GetScript("toolTipWnd"));	*/
}
/*
function OnShow()
{
	// empty
	
}

function OnFlashLoaded()
{
	// empty
}	

function OnHide(){}

function OnFocus(bool bFlag, bool bTransparency)
{
	local array<GFxValue> args;
	local GFxValue invokeResult;

	AllocGFxValues(args,2);	
	args[0].setbool(bflag);
	args[1].setbool(bTransparency);
	AllocGFxValue(invokeResult);
		
	Invoke("_root.onFocus", args, invokeResult);

	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);	
}

function OnCallUCLogic( int logicID, string param )
{	
	local string strSection;

	ParseString(param, "strSection", strSection);
	
	if( logicID == 0 )
	{
		switch( strSection )
		{
			//퀘스트
			case "Quest":
				ToggleOpenQuestWnd();
				break;
			//혈맹액션
			case "Clan":
				ToggleOpenClanWnd();
				break;
			//인맥관리
			case "Personal":
				ToggleOpenPersonalConnectionsWnd();
				break;
			//스킬&마법
			case "Skill":
				ToggleOpenSkillWnd();
				break;
			//캐릭터 정보
			case "Char":
				ToggleOpenCharInfoWnd();
				break;
			//인벤토리
			case "Inven":
				ToggleOpenInventoryWnd();
				break;
			//액션
			case "Action":
				ToggleOpenActionWnd();
				break;
			//지도
			case "Map":
				RequestOpenMinimap();
				break;
		}
	}

	//Sub1 메뉴에서 보내는 값
	else if( logicID == 1 )
	{
		switch( strSection )
		{
			case "Quit":
				ExecuteEvent(EV_OpenDialogQuit);
				break;
			case "Restart":
				ExecuteEvent(EV_OpenDialogRestart);
				break;
			//옵션창 열기
			case "Option":
				HandleShowOptionWnd();
				break;
			//매크로
			case "Macro":
				ExecuteEvent(EV_MacroShowListWnd);
				break;
			//단축키
			case "Shortcut":
				HandleShowShortcutAssignWnd();
				break;
			//서비스
			case "Service":
				//없음
				break;
			//추가기능
			case "Add":
				//없음
				break;
			//지도
			case "Map":
				RequestOpenMinimap();
				break;
			//박물관 > 삭제20121109
			/*
			case "Museum":
				ExecuteEvent(EV_StatisticWndshow);
				break;
			*/
			//게시판
			case "Board":
				HandleShowBoardWnd();
				break;
			//게시판/묻고답하기
			case "QABoard":
				handleShowQABoardWnd();
				break;
			//인맥관리
			case "Personal":
				ToggleOpenPersonalConnectionsWnd();
				break;
			//파티매칭
			case "Party":
				HandlePartyMatchWnd();
				break;
			//우편함
			case "Post":
				HandleShowPostBoxWnd();
				break;
			//개인상점
			case "Shop":
				//없음
				break;
			//상품 인벤토리
			case "Product":
				HandleShowProductInventory();
				break;
			//도움말
			case "Help":
				HandleShowHelpHtmlWnd();
				break;
			//진정
			case "Petition":
				HandleShowPetitionBegin();
				break;
			case "instanceZone":
				HandleShowInstanceZone();
				break;
			//PC방 이벤트
			case "PC":
				HandleShowPCWnd();
				break;
			//24Hz
			/*
			case "24Hz":
				W24HzShowWnd();
				break;
			*/      
			//동영상 녹화
			case "Rec":
				HandleShowMovieCaptureWnd();
				break;
			//리플레이 녹화
			case "reRec":
				DoAction( class'UICommonAPI'.static.GetItemID(55) );
				break;
			//홈페이지
			case "Home":
				linkHomePage();
				break;
			//판매상점
			case "SellStore":
				DoAction( class'UICommonAPI'.static.GetItemID(10) );
				break;
			//구매상점
			case "BuyStore":
				DoAction( class'UICommonAPI'.static.GetItemID(28) );
				break;
			//일괄판매상점
			case "AllSell":
				DoAction( class'UICommonAPI'.static.GetItemID(61) );
				break;
			//상점검색
			case "StoreSearch":
				DoAction( class'UICommonAPI'.static.GetItemID(57) );
				break;
			case "ClanSearch":
				HandleShowClanSearch();
				break;

			case "IngameNoticeWnd":
				handleShowInGameNoticeWnd();
		
				break;
			case "PathToAwakening":
				//9800 실행
				ExecuteEvent( EV_ShowWebPathMainPage );
				break;
			
		}
	}
	// 툴팁 생성
	else if( logicID == 10001 )
	{
		toolTipWndGFXScript.externalCall(1, param);
	}
	// 툴팁 제거
	else if( logicID == 10002 )
	{
		toolTipWndGFXScript.externalCall(2, "");
	}
}

function handleShowInGameNoticeWnd()
{
	local IngameNoticeWnd script;
	
	script = IngameNoticeWnd ( GetScript("IngameNoticeWnd") );
	script.MainMenuShow();
}

function HandleShowClanSearch()
{
	local string windowName;  

	windowName = "ClanSearch";

	if ( class'UIAPI_WINDOW'.static.IsShowWindow (windowName) )
	{
		class'UIAPI_WINDOW'.static.HideWindow(windowName);
	}
	else
	{
		class'UIAPI_WINDOW'.static.ShowWindow(windowName);
	}
	
}


function OnEvent(int Event_ID, string param)
{
	local int zonetype;

	if( Event_ID == EV_GamingStateEnter )
	{
		if( IsStart == false )
		{
			SetShowWindow();

			CreateMainMenu();
			CreateMainMenuTooltip();

			CreateMenuWidth();

			CreateSub1Menu();
			CreateSUB1Tooltip();

			CreateSub2Menu();
			IsStart = true;
		}
		else
		{
			SetShowWindow();
			CreateSub1Menu();
			CreateSUB1Tooltip();
			CreateSub2Menu();
		}
	}
	else if ( Event_ID == EV_SetRadarZoneCode )
	{
		ParseInt( param, "ZoneCode", zonetype );		
		if (zonetype == 12)
		{
			IsPeaceZone = 1;
		}
		else
		{
			IsPeaceZone = 0;
		}
	}
	else if( Event_ID == EV_DialogOK )
	{
		HandleDialogOK();
	}
	else if( Event_ID == EV_ShowWindow )
	{
		HandleSubMenuOpen( param );
	}
	else if( Event_ID == EV_StateChanged )
	{
		HandleStateChange( param );
	}
}

function changeEnterChat( string str )
{
	groupName = str;
	updateTooltip();
}


function updateTooltip()
{		
	CreateMainMenuTooltip();
	CreateSUB1Tooltip();
}


function HandleStateChange( String state )
{
	local	FlightShipCtrlWnd			scriptShip;
	local	FlightTransformCtrlWnd		scriptTrans;
	
	if( state == "GAMINGSTATE" )
	{
		scriptShip = FlightShipCtrlWnd ( GetScript("FlightShipCtrlWnd") );
		scriptTrans = FlightTransformCtrlWnd ( GetScript("FlightTransformCtrlWnd") ); 

		if(GetOptionBool( "CommunIcation", "EnterChatting" ))
		{	
			changeEnterChat( "TempStateShortcut" );			
		}
		else
		{
			changeEnterChat( "GamingStateShortcut" );
		}
		
		//
		if(scriptShip.isNowActiveFlightShipShortcut) 	// 비행정 조종 모드라면		
		{
			//if(GetOptionBool( "Game", "EnterChatting" ))	{class'ShortcutAPI'.static.DeactivateGroup("TempStateShortcut");}
			//Debug("isNowActiveFlightShipShortcut???? 비행정 조종 모드라면");
			changeEnterChat( "FlightStateShortcut" );
			//class'ShortcutAPI'.static.ActivateGroup("FlightStateShortcut");
		}
		else if (scriptTrans.isNowActiveFlightTransShortcut ) // 비행 변신체 모드라면
		{
			//Debug("isNowActiveFlightTransShortcut????  비행 변신체 모드");
			changeEnterChat("FlightTransformShortcut");
			//if(GetOptionBool( "Game", "EnterChatting" ))	{class'ShortcutAPI'.static.DeactivateGroup("TempStateShortcut");}
			//class'ShortcutAPI'.static.ActivateGroup("FlightTransformShortcut");
		}
	}
}


function HandleSubMenuOpen( string a_Param )
{
	local string WNDName;
	ParseString(a_Param, "Name", WNDName);

	if( WNDName == "SystemMenuWnd" )
	{
		//ShowWindowWithFocus();
		ShowWindow();
		SetFocus();
		OpenSub1Menu();
	}
}

/**
 * 메인 메뉴 만들기. 
 * 0번 호출
 */
function CreateMainMenu()
{
	dispatchEventToFlash_String(0 , TransArrayToString(LIST));
}

/**
 * 메뉴 넓이 
 */
function CreateMenuWidth()
{
	// 플래시 타입 데이타 인스턴스 생성
	local array<GFxValue> args;
	local GFxValue invokeResult;

	AllocGFxValues(args, 2);		
	AllocGFxValue(invokeResult);

	// 각성 알람 : 이벤트 번호 5번
	args[0].SetInt( 5 );

	CreateObject(args[1]);
	args[1].SetMemberInt( "MAINMENUWIDTH" , MAINMENUWIDTH );
	args[1].SetMemberInt( "SUBMENUWIDTH"  , SUBMENUWIDTH );	
	 
	Invoke( "_root.onEvent", args, invokeResult );

	DeallocGFxValue( invokeResult );
	DeallocGFxValues( args );	
}

/**
 * Sub1 메뉴 만들기.
 */
function CreateSub1Menu()
{
	
	LISTSUB1.remove( 0, LISTSUB1.Length );
	SetLISTSUB1DATA();	
	dispatchEventToFlash_String(10 , TransArrayToString(LISTSUB1));		
	//Debug("! --- CreateSub1Menu create" @ LISTSUB1.length );
}

/**
 * Sub2 메뉴 만들기.
 */
function CreateSub2Menu()
{
	
	LISTSUB2.remove( 0, LISTSUB2.Length );
	SetLISTSUB2DATA();	
	dispatchEventToFlash_String(20 , TransArrayToString(LISTSUB2));		
	//Debug("! --- CreateSub2Menu create" @ LISTSUB2.length);
}

/**
 * 서브 메뉴 열기.
 */
function OpenSub1Menu()
{
	dispatchEventToFlash_String(100 , "");		
}



/**
 * 한국어 메인 메뉴 설정.
 */
function SetLISTDATA()
{	
	local int MAINum;
	MAINum = 0;
	SetLIST(  MAINum, 434, "Char", "DetailStatusWnd" );     //캐릭터 정보
	SetLIST(++MAINum, 1,   "Inven","InventoryWnd");         //인벤토리
	SetLIST(++MAINum, 197, "Action","ActionWnd");           //액션
	SetLIST(++MAINum, 196, "Skill","MagicSkillWnd");        //스킬
	SetLIST(++MAINum, 198, "Quest","QuestTreeWnd");         //퀘스트
	SetLIST(++MAINum, 314, "Clan", "ClanWnd");              //혈맹액션
	SetLIST(++MAINum, 447, "Map", "MinimapWnd" );           //멥
	SetLIST(++MAINum, 2641,"Total","SystemMenuWnd");        //통합메뉴
}

function SetLIST (int MAINum, int stringNum, string menuID, string tooltipCommand)
{
	local string MenuName;
	MenuName = GetSystemString(stringNum);		
	LIST[MAINum] = MAINum $ "|" $ MenuName $ "|" $ menuID $ "|<NORMAL_FONT13>" $ MenuName $ "<br/>&lt;단축키:&gt;";	
	LISTMENUNAME[MAINum]= stringNum;
	LISTCOMMAND[MAINum] = tooltipCommand;
}

function CreateMainMenuTooltip()
{
	local int i;
	local array<string> LISTToolTip;
	for (i=0; i< LISTCOMMAND.Length ; i++)
	{
//		Debug("CreateMainMenuTooltip" @ LISTMENUNAME[i] @  LISTCOMMAND[i]);
		LISTToolTip[i] = setMainShortcutString( LISTMENUNAME[i], LISTCOMMAND[i]);
	}
	dispatchEventToFlash_String(1 , TransArrayToString(LISTToolTip));	
}

function string TransArrayToString( array<string> arr )
{
	local int i;
	local string str;

	for( i = 0 ; i < arr.Length ; i ++ )
	{
		if( i !=  arr.Length - 1 )
		{
			str = str $ arr[i] $ "!";
		}
		else
		{
			str = str $ arr[i];
		}
	}
	return str;
}

function SetLISTSUB1DATA()
{
	local ELanguageType Language;	
	local int sub1num;
	local int bValue;

	local bool isClassic;
	
	isClassic = getInstanceUIData().getIsClassicServer();

	Language = GetLanguage();
	sub1num=0;

	setLISTSUB1(  sub1num, 148,  "Quit",    false, 1, "");                  //게임 종료
	setLISTSUB1(++sub1num, 147,  "Restart", false, 1, "");                  //리스타트
	inputDivision( ); //분리선--------------------------------------------------------------------
	setLISTSUB1(++sub1num, 146,  "Option",  false, 1, "OptionWnd");         //옵션
	setLISTSUB1(++sub1num, 711,  "Macro",   false, 1, "MacroWnd");          //매크로
	setLISTSUB1(++sub1num, 1523, "Shortcut",false, 1, "");	                //단축키
	inputDivision( ); //분리선--------------------------------------------------------------------
	setLISTSUB1(++sub1num, 2643, "Service", true,  1, "");                  //서비스	
	inputDivision( ); //분리선--------------------------------------------------------------------
	setLISTSUB1(++sub1num, 2642, "Add_Tooltip", true, 1, "");	            //추가기능	
	//inputDivision( ); //분리선--------------------------------------------------------------------
	//setLISTSUB1(++sub1num, 2600, "Museum",  false, 1, "");                  //박물관 > 삭제20121109
	inputDivision( ); //분리선--------------------------------------------------------------------
	setLISTSUB1(++sub1num, 387,  "Board",   false, 1, "BoardWnd");          //게시판
	//13.02.27 이후 추가 됩니다.

	//해외에서 사용 하지 않는 메뉴 2013.12.06ㅣ;
	if (Language != ELanguageType.LANG_Korean) bValue = 0;else bValue = 1;	
	if ( isClassic ) bValue = 0;
	setLISTSUB1(++sub1num, 3136,  "QABoard",   false, bValue, "");          //게시판/묻고답하기	
	//setLISTSUB1(++sub1num, 387,  "QABoard",   false, 1, "QABoardWnd");          //게시판/묻고답하기	

	//13.01.23 이후 삭제 됩니다.
	// 중국 쪽에는 msn 이 없다.그에 따른 예외 처리
	//if (Language == ELanguageType.LANG_Chinese) GetINIBool("Localize", "UseMsn", bValue, "L2.ini"); //조건 조사
	//else bValue = 1;
	//setLISTSUB1(++sub1num, 896,  "MSN",     false, bValue, "");               //메신져

	setLISTSUB1(++sub1num, 2383, "Personal",false, 1, "PersonalConnectionsWnd");  //인맥
	setLISTSUB1(++sub1num, 389,  "Party",   false, 1, "PartyMatchWnd");     //파티메칭
	setLISTSUB1(++sub1num, 3068,  "ClanSearch",  false, 1, "");             //혈맹 가입
	setLISTSUB1(++sub1num, 2074, "Post",    false, 1, "PostWnd");	        //우편함
	inputDivision( ); //분리선--------------------------------------------------------------------
	setLISTSUB1(++sub1num, 498,  "Shop",    true , 1, "");	                //개인상점

	GetINIBool("PrimeShop", "UseGoodsInventory", bValue, "L2.ini");         //조건 조사
	setLISTSUB1(++sub1num, 2469, "Product", false, bValue, "");             //상품인벤토리
}

function setLISTSUB1(int sub1num, int stringNUm, string menuName,  bool useSubMenu, int bValue, string tooltip)
{
	if (bValue == 1)	//해당 조건이 맞으면
	{
		LISTSUB1[LISTSUB1.Length] = sub1num$"|"$GetSystemString(stringNUm)$"|"$menuName$"|"; // 메뉴 입력 아니면 삭제
	}
	if ( useSubMenu )   //서브 메뉴가 있으면
	{
			LISTSUB2NUM[LISTSUB2NUM.Length] = sub1num;  //서브메뉴 번호 입력
	}	
	LISTSUB1COMMAND[sub1num] = tooltip; //툴팁에 커맨드 입력
}

function CreateSUB1Tooltip( )
{	
	local int i;	
	local array<string> LISTSUB1ToolTip;
	for ( i =0 ; i< LISTSUB1COMMAND.Length ; i++)
	{
		LISTSUB1ToolTip[i] = setSubShortcutString(LISTSUB1COMMAND[i]);
	}
	dispatchEventToFlash_String(15 , TransArrayToString(LISTSUB1ToolTip));	
}

function inputDivision( ) 
{
	local string divisionStr ;
	divisionStr = "999|분리선Divi|false|Tooltip";
	if ( LISTSUB1[LISTSUB1.Length - 1] != divisionStr ) //옵션에 의해 메뉴가 통째로 사라지는 경우 디비젼이 두번 들어가는 걸 방지 
	{		
		LISTSUB1[LISTSUB1.Length] = divisionStr;	
	}	
}

function SetLISTSUB2DATA()
{	
	local int bValue ;
	local int sub2num ;
	local bool isClassic;

	local ELanguageType Language;	
	
	isClassic = getInstanceUIData().getIsClassicServer();
	Language = GetLanguage();

	sub2num =0;

	setLISTSUB2(LISTSUB2NUM[2],   sub2num, 2644, "|SellStore|false", 1);    //판매상점
	setLISTSUB2(LISTSUB2NUM[2], ++sub2num, 2645, "|BuyStore|false", 1);     //구매상점
	setLISTSUB2(LISTSUB2NUM[2], ++sub2num, 2646, "|AllSell|false", 1);      //일괄판매상점
	setLISTSUB2(LISTSUB2NUM[2], ++sub2num, 1283, "|StoreSearch|false", 1);  //상점검색
	/*-----------------------------------------------------------------------------------------------------------------------------*/		
	if ( isClassic ) bValue = 0;else bValue = 1;
	setLISTSUB2(LISTSUB2NUM[1], ++sub2num, 2796, "|InstanceZone|false", bValue); //인스턴스 존
	
	//클래식 서버에서는 PC방 포인트가 보이지 않음.
	GetINIBool("Localize", "UsePCBangPoint", bValue, "L2.ini");             //조건검색
	if ( isClassic ) bValue = 0;
	setLISTSUB2(LISTSUB2NUM[1], ++sub2num, 1277, "|PC|false", bValue);      //PC방 이벤트

	//GetINIBool("URL", "bUse24HZ", bValue, "L2.ini");                        //조건 검색
	//setLISTSUB2(LISTSUB2NUM[1], ++sub2num, 2410, "|24Hz|false", bValue);    //24Hz
	setLISTSUB2(LISTSUB2NUM[1], ++sub2num, 2448, "|Rec|false",  1);         //동영상 녹화
	setLISTSUB2(LISTSUB2NUM[1], ++sub2num, 2647, "|reRec|false",  1);	    //리플레이 녹화
	/*-----------------------------------------------------------------------------------------------------------------------------*/
	if ( isClassic ) bValue = 0;else bValue = 1;
	setLISTSUB2(LISTSUB2NUM[0], ++sub2num, 145, "|Help|false",  bValue);	    //도움말
	
	//한국 외에서는 1:1 진정 문의가 없음 그에 다른 예외 처리
	if (Language != ELanguageType.LANG_Korean) bValue = 0;else bValue = 1;	
	setLISTSUB2(LISTSUB2NUM[0], ++sub2num, 470, "|Petition|false",  bValue);    //진정
	//해외에서 사용 하지 않는 메뉴 2013.12.0
	if (Language != ELanguageType.LANG_Korean) bValue = 0;else bValue = 1;	
	setLISTSUB2(LISTSUB2NUM[0], ++sub2num, 3169, "|IngameNoticeWnd|false",  bValue);    //접속공지창
	setLISTSUB2(LISTSUB2NUM[0], ++sub2num, 2257, "|Home|false",  1);       //홈페이지
	//페스 투 어웨이큰
	if ( !GetINIBool("Localize", "UsePathToAwakening", bValue, "L2.ini")) bValue = 0;
	setLISTSUB2(LISTSUB2NUM[0], ++sub2num, 5178, "|PathToAwakening|false", bValue); 
}

function setLISTSUB2(int snub1num, int sub2num, int stringNUm, string etc,  int  bValue)					
{
	if (bValue == 1)
		 LISTSUB2[LISTSUB2.Length] = snub1num $ "||" $ sub2num $ "|" $ GetSystemString(stringNUm) $ etc;//Tool";
}



/**
 * ShowWindow 창이 열려 있을때 다시 열지 않기.
 */
function SetShowWindow()
{	
	if( IsShowWindow() == false )
	{
		ShowWindow();
	}
}


function string setMainShortcutString( int sysNum, string commandName )
{
	local ShortcutCommandItem   commandItem;
	local string                strShort;
	local OptionWnd     Script;

	Script = OptionWnd( GetScript( "OptionWnd" ) );

	strShort = "<NORMAL_FONT13>" $ GetSystemString( sysNum ) $ "<br>&lt;" $ GetSystemString(1523) $ ": ";

	//퀘스트
	class'ShortcutAPI'.static.GetAssignedKeyFromCommand( groupName, "ShowWindow Name=" $ commandName, commandItem);

	//단축키 설명...
	if( commandItem.subkey1 != "" )
	{
		strShort = strShort $ Script.GetUserReadableKeyName( commandItem.subkey1 ) $ "+";
	}
	if( commandItem.subkey2 != "" )
	{
		strShort = strShort $ Script.GetUserReadableKeyName( commandItem.subkey2 ) $ "+";
	}
	if( commandItem.Key != "" )
	{
		if( commandName == "InventoryWnd" )
		{
			strShort = strShort $ Script.GetUserReadableKeyName( commandItem.Key ) $ ",";			
		}
		else
			strShort = strShort $ Script.GetUserReadableKeyName( commandItem.Key ) $ "&gt;</NORMAL_FONT13>";
	}

	if( commandItem.subkey1 == "" && commandItem.subkey2 == "" && commandItem.Key == "" )
	{
		strShort = strShort $ "없음&gt;</NORMAL_FONT13>";
	}

	if( commandName == "InventoryWnd" )
	{
		class'ShortcutAPI'.static.GetAssignedKeyFromCommand( "GamingStateShortcut", "TabShowInventoryWindow", commandItem);

		if( commandItem.subkey1 != "" )
		{
			strShort =  strShort $ Script.GetUserReadableKeyName( commandItem.subkey1 ) $ "+";
		}
		if( commandItem.subkey2 != "" )
		{
			strShort = strShort $ Script.GetUserReadableKeyName( commandItem.subkey2 ) $ "+";
		}
		if( commandItem.Key != "" )
		{
			strShort = strShort $ Script.GetUserReadableKeyName( commandItem.Key ) $ "&gt;</NORMAL_FONT13>";
		}	
	}

	return strShort;
}

function string setSubShortcutString( string commandName )
{
	local ShortcutCommandItem   commandItem;
	local string                strShort;
	local OptionWnd     Script;

	if( commandName == "" )
	{
		return "";
	}

	Script = OptionWnd( GetScript( "OptionWnd" ) );

	strShort = "<NORMAL_FONT13>&lt;" $ GetSystemString(1523) $ ": ";

	//퀘스트
	class'ShortcutAPI'.static.GetAssignedKeyFromCommand( groupName, "ShowWindow Name=" $ commandName, commandItem);

	//단축키 설명...
	if( commandItem.subkey1 != "" )
	{
		strShort = strShort $ Script.GetUserReadableKeyName( commandItem.subkey1 ) $ "+";
	}
	if( commandItem.subkey2 != "" )
	{
		strShort = strShort $ Script.GetUserReadableKeyName( commandItem.subkey2 ) $ "+";
	}
	if( commandItem.Key != "" )
	{
		strShort = strShort $ Script.GetUserReadableKeyName( commandItem.Key ) $ "&gt;</NORMAL_FONT13>";
	}

	if( commandItem.subkey1 == "" && commandItem.subkey2 == "" && commandItem.Key == "" )
	{
		class'ShortcutAPI'.static.GetAssignedKeyFromCommand( "GamingStateShortcut", "ShowWindow Name=" $ commandName, commandItem);
		if( commandItem.subkey1 != "" )
		{
		strShort = strShort $ Script.GetUserReadableKeyName( commandItem.subkey1 ) $ "+";
		}
		if( commandItem.subkey2 != "" )
		{
			strShort = strShort $ Script.GetUserReadableKeyName( commandItem.subkey2 ) $ "+";
		}
		if( commandItem.Key != "" )
		{
			strShort = strShort $ Script.GetUserReadableKeyName( commandItem.Key ) $ "&gt;</NORMAL_FONT13>";
		}
	}

	if( commandItem.subkey1 == "" && commandItem.subkey2 == "" && commandItem.Key == "" )
	{
		strShort = "";
	}

	//strShort = substitute( strShort, "<", "&lt;", true );
	//strShort = substitute( strShort, ">", "&gt;", true );

	return strShort;
}

/*
function int Split( string strInput, string delim, out array<string> arrToken )
{
	local int arrSize;
	
	while ( InStr(strInput, delim)>0 )
	{
		arrToken.Insert(arrToken.Length, 1);
		arrToken[arrToken.Length-1] = Left(strInput, InStr(strInput, delim));
		strInput = Mid(strInput, InStr(strInput, delim)+1);
		arrSize = arrSize + 1;
	}
	arrToken.Insert(arrToken.Length, 1);
	arrToken[arrToken.Length-1] = strInput;
	arrSize = arrSize + 1;
	
	return arrSize;
}
*/



/**
 * 퀘스트 창 열기
 */
function ToggleOpenQuestWnd()
{
	local WindowHandle win;	
	win = GetWindowHandle( "QuestTreeWnd" );
	
	if( win.IsShowWindow() )
	{
		win.HideWindow();
		PlaySound("InterfaceSound.map_close_01");
	}
	else
	{
		win.ShowWindow();
		win.SetFocus();
		PlaySound("InterfaceSound.map_open_01");
		
	}	
}

/**
 * 혈맹 창 열기
 */
function ToggleOpenClanWnd()
{
	local WindowHandle win;

	win = getWindowHandleCheckClassic( "ClanWnd" );
	
	if( win.IsShowWindow() )
	{
		win.HideWindow();
		PlaySound("InterfaceSound.charstat_close_01");
	}
	else
	{
		win.ShowWindow();
		win.SetFocus();
		PlaySound("InterfaceSound.charstat_open_01");			
	}
}

/**
 * 인맥관리 시스템 열기 
 */
function ToggleOpenPersonalConnectionsWnd ()
{
	local WindowHandle win;
	win = GetWindowHandle( "PersonalConnectionsWnd" );
	
	if( win.IsShowWindow() )
	{
		win.HideWindow();
		PlaySound("ItemSound.window_close");
	}
	else
	{
		win.ShowWindow();
		win.SetFocus();
		PlaySound("ItemSound.window_open");			
	}
}

/** 
 * 스킬 창 열기
 */
function ToggleOpenSkillWnd()
{
	local WindowHandle win;
	win = GetWindowHandle( "MagicSkillWnd" );
	
	if( win.IsShowWindow() )
	{
		win.HideWindow();
		PlayConsoleSound(IFST_MAPWND_OPEN);
		
	}
	else
	{
		win.ShowWindow();
		win.SetFocus();
		PlayConsoleSound(IFST_MAPWND_CLOSE);
	}
}


function WindowHandle getWindowHandleCheckClassic( String winName)
{
	local WindowHandle win;
	//local bool _isClassicServer;
	//local UIData script;
	//script = getInstanceUIData();
	//_isClassicServer = true;	
	//Debug ( "isclassic?" @script.getIsClassicServer() );
	if ( getInstanceUIData().getIsClassicServer() )
	{
		//Debug ( "classic");
		win = GetWindowHandle( winName $ "Classic" );		
	}
	else 
	{
		//Debug ( "normal");
		win = GetWindowHandle( winName );
	}
	return win;
}

/**
 * 케릭터 정보 창 열기
 */
function ToggleOpenCharInfoWnd()
{
	local WindowHandle win;

	win = getWindowHandleCheckClassic( "DetailStatusWnd" );

	
	if( win.IsShowWindow() )
	{
		win.HideWindow();
		PlayConsoleSound(IFST_WINDOW_CLOSE);
	}
	else
	{
		win.ShowWindow();
		win.SetFocus();
		PlayConsoleSound(IFST_WINDOW_OPEN);
	}
}

/**
 * 인벤토리 창 열기
 */
function ToggleOpenInventoryWnd()
{
	local WindowHandle win;
	win = GetWindowHandle( "InventoryWnd" );
	
	if( win.IsShowWindow() )
	{
		win.HideWindow();
		PlaySound("InterfaceSound.inventory_close_01");
	}
	else
	{
		ExecuteEvent(EV_InventoryToggleWindow);
		PlaySound("InterfaceSound.inventory_open_01");	
	}
}

/**
 * 액션 창 열기
 */
function ToggleOpenActionWnd()
{
	local WindowHandle win;
	win = GetWindowHandle( "ActionWnd" );
	
	if( win.IsShowWindow() )
	{
		win.HideWindow();
		PlayConsoleSound(IFST_WINDOW_OPEN);
	}
	else
	{
		win.ShowWindow();
		win.SetFocus();
		ExecuteEvent(EV_ActionListStart);
		ExecuteEvent(EV_ActionList);
		ExecuteEvent(EV_LanguageChanged);
		ExecuteEvent(EV_ActionListNew);
		PlayConsoleSound(IFST_WINDOW_CLOSE);				
	}
}

/**
 * 옵션 창 열기
 */
function HandleShowOptionWnd()
{
	local OptionWnd win;
	win = OptionWnd( GetScript("OptionWnd") );
	win.ToggleOpenMeWnd(false); //옵션창만 열기
	//ExecuteEvent( EV_OptionWndShow ) ;//단축키 창 열기 
}

/**
 * 단축키 창 열기
 */
function HandleShowShortcutAssignWnd()
{

	local OptionWnd win;	
	win = OptionWnd( GetScript("OptionWnd") );
	win.ToggleOpenMeWnd(true);  //숏컷 창으로 열기 

}

/**
 * 게시판 열기
 */
function HandleShowBoardWnd()
{
	local string strParam;
	ParamAdd(strParam, "Init", "1");
	ExecuteEvent(EV_ShowBBS, strParam);
}

//게시판/묻고 답하기
function handleShowQABoardWnd()
{
	local string strParam;
	ParamAdd(strParam, "Index", "8");
	ExecuteEvent(EV_ShowBBS, strParam);
}

/**
 * 파티매칭 열기
 */
function HandlePartyMatchWnd()
{	
	ExecuteEvent( EV_ShowWindow, "Name=PartyMatchWnd" );	
}

/**
 * 우폄함 열기
 */
function HandleShowPostBoxWnd()
{
	local WindowHandle win;
	win = GetWindowHandle( "PostBoxWnd" );
	
	if( win.IsShowWindow() )
	{
		win.HideWindow();
		PlayConsoleSound(IFST_WINDOW_CLOSE);
	}
	else
	{
		PlayConsoleSound(IFST_WINDOW_OPEN);
		RequestRequestReceivedPostList();
		if (IsPeaceZone == 0)
			AddSystemMessage(3066);	
	}
}

/**
 * 도움말 열기
 */
function HandleShowHelpHtmlWnd()
{
	local AgeWnd script;	// 등급표시 스크립트 가져오기
	
	local string strParam;
	ParamAdd(strParam, "FilePath", "..\\L2text\\help.htm");
	ExecuteEvent(EV_ShowHelp, strParam);
	
	script = AgeWnd( GetScript("AgeWnd") );
	
	if(script.bBlock == false)	script.startAge();	//등급표시를 켜준다. 
}
/**
 * 인스턴스 존 창 열기
 */
function HandleShowInstanceZone()
{
	//Debug(" HandleShowInstanceZone" );
	RequestInzoneWaitingTime();
}

/**
 * 진정 창 열기
 */
function HandleShowPetitionBegin()
{
	local WindowHandle win;	
	local WindowHandle win1;	
	local WindowHandle win2;	
	local PetitionMethod useNewPetition;

	win = GetWindowHandle( "NewUserPetitionWnd" );
	win1 = GetWindowHandle( "UserPetitionWnd" );
	win2 = GetWindowHandle( "WebPetitionWnd" );

	useNewPetition = GetPetitionMethod();

	if( useNewPetition == PetitionMethod_New )
	{
		if(win.IsShowWindow())
		{
			PlayConsoleSound(IFST_WINDOW_CLOSE);
			win.HideWindow();
		}
		else
		{
			PlayConsoleSound(IFST_WINDOW_OPEN);
			RequestShowPetitionAsMethod();
		}
	}
	else if( useNewPetition == PetitionMethod_Default )
	{
		if (win1.IsShowWindow())
		{
			PlayConsoleSound(IFST_WINDOW_CLOSE);
			win1.HideWindow();
		}
		else
		{
			PlayConsoleSound(IFST_WINDOW_OPEN);
			win1.ShowWindow();
			win1.SetFocus();
		}
	}
	else if( useNewPetition == PetitionMethod_Web )
	{
		if (win2.IsShowWindow())
		{
			PlayConsoleSound(IFST_WINDOW_CLOSE);
			win2.HideWindow();
		}
		else
		{
			PlayConsoleSound(IFST_WINDOW_OPEN);
			RequestShowPetitionAsMethod();
		}
	}
}

/**
 * PC방 이벤트 열기
 */
function HandleShowPCWnd()
{
	local PCCafeEventWnd script;	
	script = PCCafeEventWnd( GetScript("PCCafeEventWnd") );
	
	script.HandleToggleShowPCCafeEventWnd();
	PlayConsoleSound(IFST_WINDOW_OPEN);
}

/**
 * 24Hz 열기
 
function W24HzShowWnd()
{
	local WindowHandle win;	
	win = GetWindowHandle( "W24HzWnd" );

	//보여지면 닫기
	if( win.isShowWindow())
	{
		PlayConsoleSound(IFST_WINDOW_CLOSE);
		win.HideWindow();
	}
	//아니면 열기
	else 
	{	
		PlayConsoleSound(IFST_WINDOW_OPEN);
		win.ShowWindow();
		win.SetFocus();
	}
}
*/

/**
 * 동영상 녹화 창 열기
 */
function HandleShowMovieCaptureWnd()
{
	local bool tmpBool;
	local WindowHandle win;	
	local WindowHandle win1;	

	win = GetWindowHandle( "MovieCaptureWnd_Expand" );
	win1 = GetWindowHandle( "MovieCaptureWnd" );

	tmpBool =IsNowMovieCapturing();

	//켑쳐 되고 있다면
	if(tmpBool)
	{
		win.HideWindow();
		//확장 창이 보여 진다면
		if ( win.IsShowWindow() )
		{
			PlayConsoleSound(IFST_WINDOW_CLOSE);
			win.HideWindow();
		}
		else 
		{			
			PlayConsoleSound(IFST_WINDOW_OPEN);
			win.ShowWindow();
			win.SetFocus();
		}
	} 
	//아니라면 일반 창 열고 닫기
	else 
	{
		if (win1.IsShowWindow())
		{
			PlayConsoleSound(IFST_WINDOW_CLOSE);
			win1.HideWindow();
		} 
		else
		{	
			PlayConsoleSound(IFST_WINDOW_OPEN);
			win1.ShowWindow();
			win1.SetFocus();

		}
	}	
}

/**
 * 홈페이지 열기
 */
function linkHomePage()
{
	class'UICommonAPI'.static.DialogSetID( DIALOGID_Gohome );
	class'UICommonAPI'.static.DialogShow( DialogModalType_Modalless, DialogType_OKCancel, GetSystemMessage( 3208 ), string(Self));
}

//홈페이지 링크(10.1.18 문선준 추가)
function HandleDialogOK()
{	
	if( ! class'UICommonAPI'.static.DialogIsOwnedBy( string(Self) ) )
		return;

	switch( class'UICommonAPI'.static.DialogGetID() )
	{
	case DIALOGID_Gohome:
		OpenL2Home();
		break;
	}
}

//상품 인벤토리 열기
function HandleShowProductInventory()
{
	local WindowHandle win;	
	local WindowHandle win1;	

	//local ShortcutAssignWnd sc;
	//sc = ShortcutAssignWnd( GetScript("ShortcutAssignWnd") );
	//debug( ">>>>>" $ sc.GetShortcutItemNameWithID(1) );

	win = GetWindowHandle( "ProductInventoryWnd" );
	win1 = GetWindowHandle( "ShopWnd" );

	//보여지면 닫기
	if( win.isShowWindow())
	{
		PlayConsoleSound(IFST_INVENWND_CLOSE);
		win.HideWindow();
	}
	//아니면 열기
	else 
	{	
		util.ItemRelationWindowHide( "ProductInventoryWnd" );

		if( !win1.IsShowWindow() )
		{
			PlayConsoleSound(IFST_INVENWND_OPEN);
			win.ShowWindow();
			win.SetFocus();
		}
	}
}

//Flash에 마우스 오버시 이벤트 발생.
event OnMouseOver( WindowHandle w )
{	
	
}
//Flash에 마우스 아웃시 이벤트 발생.
event OnMouseOut( WindowHandle w )
{
	//강제로 마우스 위치를 0,0으로.
	ForceToMoveMousePos( 0, 0 );
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 **/
function OnReceivedCloseUI()
{	
	local array<GFxValue> args;
	local GFxValue invokeResult;
	
	AllocGFxValues(args, 1);		
	
	Invoke("_root.onReceivedCloseUI", args, invokeResult);

	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);	
}


function dispatchEventToFlash_String(int Event_ID, string argString){
	local array<GFxValue> args;
	local GFxValue invokeResult;

	AllocGFxValues(args, 2);
	AllocGFxValue(invokeResult);
	args[0].SetInt(Event_ID);
	CreateObject(args[1]);

//	Debug("argString"@argString);
	args[1].SetMemberString("list", argString );

	Invoke("_root.onEvent", args, invokeResult);
	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);
}
*/


//function changeEnterChat( string str )
//{
//	//groupName = str;
//	//updateTooltip();
//}
//function updateTooltip()
//{		
//}
defaultproperties
{
}
