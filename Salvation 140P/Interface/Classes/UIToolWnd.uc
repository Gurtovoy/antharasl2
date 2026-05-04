class UIToolWnd extends UICommonAPI;

//const DIALOGID_Gohome = 0;

var string m_WindowName;
var WindowHandle Me;
var ButtonHandle transBtn;
var ButtonHandle debugBtn;
var ButtonHandle uiBtn;
var ButtonHandle reloaduiBtn;
var ButtonHandle evemsgBtn;
var ButtonHandle uioffBtn;
var ButtonHandle showWBtn;
var ButtonHandle skillBtn;
var ButtonHandle killBtn;
var ButtonHandle weightBtn;
var ButtonHandle diaBtn;

var EditBoxHandle HEdit0;
var EditBoxHandle HEdit;

var EditBoxHandle NEdit;

var ListCtrlHandle WindowListCtrl;

var array<string> arrWinList;

var UIEasyLoginWnd easyLoginScript;

//var DialogBox	dScript;

//var INT64 tempN;
//var bool tempB;
//var bool tempResultB;
//var String tempOper;
//var EditBoxHandle m_ResultEditBox;

var WindowHandle m_dialogWnd;

function OnLoad()
{
	SetClosingOnESC();

	OnRegisterEvent();
	
	Me = GetWindowHandle( "UIToolWnd" );
	transBtn = GetButtonHandle( "UIToolWnd.Tab0.transBtn" );
	debugBtn = GetButtonHandle( "UIToolWnd.Tab0.debugBtn" );
	uiBtn = GetButtonHandle( "UIToolWnd.Tab0.uiBtn" );
	reloaduiBtn = GetButtonHandle( "UIToolWnd.Tab0.reloaduiBtn" );
	evemsgBtn = GetButtonHandle( "UIToolWnd.Tab0.evemsgBtn" );
	uioffBtn = GetButtonHandle( "UIToolWnd.Tab0.uioffBtn" );
	showWBtn = GetButtonHandle( "UIToolWnd.Tab0.showWBtn" );
	skillBtn = GetButtonHandle( "UIToolWnd.Tab0.skillBtn" );
	killBtn = GetButtonHandle( "UIToolWnd.Tab0.killBtn" );
	weightBtn = GetButtonHandle( "UIToolWnd.Tab0.weightBtn" );
	diaBtn = GetButtonHandle( "UIToolWnd.Tab0.diaBtn" );

	HEdit0 = GetEditBoxHandle( "UIToolWnd.Tab1.HEdit0" );
	HEdit = GetEditBoxHandle( "UIToolWnd.Tab1.HEdit" );

	NEdit = GetEditBoxHandle( "UIToolWnd.Tab2.NEdit" );
	
	WindowListCtrl = GetListCtrlHandle( "UIToolWnd.Tab2.WindowListCtrl" );

	easyLoginScript = UIEasyLoginWnd(GetScript("UIEasyLoginWnd"));

	setArr();
}

function OnRegisterEvent()
{
	RegisterEvent( EV_DialogOK );
	RegisterEvent( EV_DialogCancel );

	// 테스트 용 이벤트 (다이얼로그 박스)
	//RegisterEvent( EV_Test_7 );
}

function OnEvent( int a_EventID, String a_Param )
{
	switch( a_EventID )
	{
		case EV_Test_7 :
			 dialogShowTest(a_Param);
			 break;
	}
}

function dialogShowTest(string param)
{
	local int nSystemString, nSystemMessage, nHtml, nWidth, nHeight;
	local string dialogStr, customIconTexture;

	ParseInt( param, "html"  , nHtml );

	ParseInt( param, "width" , nWidth );
	ParseInt( param, "height", nHeight );

	ParseInt( param, "systemString" , nSystemString );
	ParseInt( param, "systemMessage", nSystemMessage );

	ParseString( param, "string"            , dialogStr );
	ParseString( param, "customIconTexture" , customIconTexture );

	

	//htmlStr = "<br1><font name='hs9' color='FFDF4C'>아인하사드</font> <font name=\"hs9\" color='00DF4C'>크론비스트</font>의 힘을 받았다. 가공할 명중력과 공격력으로 그들의 적에게 공포를 주었고 특히, 그들의 가공할 연사 속도는 적들이 접근하기 전에 그들을 영원한 안식에 들게 했다.";

	DialogHide();
	DialogSetID( 34567891 );	
	
	if (dialogStr == "")
	{
		dialogStr = GetSystemMessage(nSystemMessage);
		if (dialogStr == "") dialogStr = GetSystemString(nSystemString);
	}

	if (nWidth == 0) nWidth = 319;
	if (nHeight == 0) nHeight = 143;
	
	DialogShow(DialogModalType_Modalless,DialogType_Warning, dialogStr, string(Self), nWidth, nHeight, numToBool(nHtml), customIconTexture);
}

function onHide()
{
	SetINIString("UIToolWnd", "nEdit", nEdit.GetString(), "UIDEV.ini");
}

function onShow()
{
	local string stringValue;

	stringValue = "";	

	// Event Param 
	GetINIString("UIToolWnd", "nEdit", stringValue, "UIDEV.ini");
	nEdit.SetString(stringValue);

	if (easyLoginScript.getUseEasyLogin())
		GetButtonHandle( "UIToolWnd.Tab0.EasyLogin").SetNameText("EasyLogin On");
	else
		GetButtonHandle( "UIToolWnd.Tab0.EasyLogin").SetNameText("EasyLogin Off");
}

/*
function OnEvent( int a_EventID, String a_Param )
{
	debug("UIToolWnd OnEvent " $ a_Param);

	switch( a_EventID )
	{
		case EV_DialogOK:
			debug("UIToolWnd???????????????????");
			HandleDialogOK();			
			break;
		case EV_DialogCancel:
			
			break;
	}
}

function HandleDialogOK()
{
	if( !DialogIsMine() )
		return;

	switch( DialogGetID() )
	{
	case DIALOGID_Gohome:
		OpenL2Home();
		debug("UIToolWnd22222");
		break;
	}
}
*/

function OnClickButton( String a_ButtonID )
{
	local UIDebugWnd util;
	local bool bFlag;

	util = UIDebugWnd( GetScript("UIDebugWnd") );
	

	switch( a_ButtonID )
	{
		case "initBtn":
			initButtonClick();
			break;
		case "transBtn":
			if( transBtn.GetButtonName() == "HideOff" )
			{
				ExecuteCommand("//hide off");
				transBtn.SetNameText( "HideOn" );
			}
			else
			{
				ExecuteCommand("//hide on");
				transBtn.SetNameText( "HideOff" );
			}
			break;

		case "debugBtn":
			ExecuteCommand("///uidebug");
			break;

		case "uiBtn":
			//Me.MoveTo( 1000, 0 );
			ExecuteCommand("///ui");			
			break;

		case "reloaduiBtn":
			ExecuteCommand("///reloadui");
			break;

		case "evemsgBtn":
			if( evemsgBtn.GetButtonName() == "EvMsgON" )
			{
				evemsgBtn.SetNameText( "EvMsgOFF" );
			}
			else
			{
				evemsgBtn.SetNameText( "EvMsgON" );
			}
			ExecuteCommand("///eventmsg");
			break;
			///gfx
			///delgfxall
			///delgfx "파일이름"

		case "showWBtn":			
			ExecuteCommand("///show windowname");
			break;

		case "skillBtn":			
			ExecuteCommand("//setskill 7029 3");
			break;

		case "killBtn":			
			ExecuteCommand("//죽어");
			break;
			
		case "weightBtn":
			if( weightBtn.GetButtonName() == "WeightOFF" )
			{
				ExecuteCommand("//무게 켬");
				weightBtn.SetNameText( "WeightON" );
			}
			else
			{
				ExecuteCommand("//무게 끔");
				weightBtn.SetNameText( "WeightOFF" );
			}
			break;	

		case "gfxBtn":			
			ExecuteCommand("///gfx");
			break;
		case "delgfxBtn":
			ExecuteCommand("///delgfxall");
			break;

		case "loadBtn":
			loadButtonClick();
			break;
		case "htmlBtn":
			htmlButtonClick();
			break;

		case "winBtn":
			winButtonClick();
			break;

		case "shoWBBtn":
			ExecuteCommand("///show windowbox");
			break;
		case "allBtn":
			ExecuteCommand("//올스킬");
			break;
		case "evnBtn":
			MakeEventBuff2();
			break;
		case "PowerTool":
			LoadWindowClick("UIPowerToolWnd");			
			break;
		case "UITrace":
			util.ShowWindow();
			break;

		// 중국 테스트 툴 추가 
		case "ServerHtml":
			LoadWindowClick("UIServerHtmlToolWnd");
			break;

		case "HtmlTool":
			LoadWindowClick("UIHtmlToolWnd");
			break;

		case "QuestTool":
			LoadWindowClick("UIQuestToolWnd");
			break;

		case "ItemTool":
			LoadWindowClick("UIItemToolWnd");
			break;
		case "GFXTester":
			callGfxFunction ( "containerHUD", "showDebugTool", "");
			break;

		case "ShowUI":
			LoadWindowClick("UIOpenToolWnd");	
			break;

		// 플래시로 만든 디버그
		case "GfxDebug":
			ExecuteEvent(EV_Test_8, "");
			break;

		case "EasyLogin" :
			bFlag = easyLoginScript.getUseEasyLogin();
			if (bFlag)
				GetButtonHandle( "UIToolWnd.Tab0.EasyLogin").SetNameText("EasyLogin Off");
			else
				GetButtonHandle( "UIToolWnd.Tab0.EasyLogin").SetNameText("EasyLogin On");
			
			easyLoginScript.setUseEasyLogin(!bFlag);
			
			break;
		case "GammaOff" :
			SetOptionFloat( "Video", "Gamma", 0 );
			break;
		case "JobTree":
			ShowWindow("JobTreeWnd");
			break;

		case "mapSearchButton" :
			toggleWindow("UISearchMapWnd", true);
			break;
	}
}


function LoadWindowClick(string windowName)
{	
	local WindowHandle NewWindow;

	NewWindow = GetWindowHandle( windowName );
	NewWindow.ShowWindow();
	NewWindow.SetFocus();
}

/*
function linkHomePage()
{
	DialogSetID( DIALOGID_Gohome );
	//DialogShow(DialogModalType_Modalless, DialogType_OKCancel, GetSystemMessage( 1221 ), string(Self) );
	DialogShow(DialogModalType_Modalless, DialogType_OKCancel, GetSystemMessage( 3208 ), string(Self) );

	//local DialogBox dsScript;
	//dsScript = DialogBox( GetScript("DialogBox") );	
	//dsScript.SetID  ( DIALOGID_Gohome );
	//dsScript.ShowDialog( DialogModalType_Modalless, DialogType_Warning, "리니지2 홈페이지로 이동하겠습니다. 계속하시겠습니까?", "UIToolWnd" );
}
*/

function initButtonClick()
{
	ExecuteCommand("//투명 끔");
	ExecuteCommand("//무적 on");
	ExecuteCommand("//속도 5");
	ExecuteCommand("///uidebug");
	ExecuteCommand("///autocom");
}


function loadButtonClick()
{
	local string str;
	local array<string> arrStr;
	
	//arrStr[0] = "";
	//arrStr[1] = "";

	str = HEdit0.GetString();	
	Split( str, ".", arrStr );

	if( arrStr[1] != "")
	{
		//debug("111@@@"$str);
		ExecuteCommand("//loadhtml "$str );
	}
	else
	{
		//debug("222@@@"$str);
		ExecuteCommand("//loadhtml "$str$".htm" );
	}
	
}


function htmlButtonClick()
{
	local ItemDescWnd Script;
	local string str;
	local array<string> arrStr;
	
	//arrStr[0] = "";
	//arrStr[1] = "";

	str = HEdit.GetString();	
	Split( str, ".", arrStr );

	// ShowWindow( "ItemDescWnd" );

	Script = ItemDescWnd( GetScript( "ItemDescWnd" ) );
	//Script.ShowWindow("ItemDescWnd");
	
	if( arrStr[1] != "" )
	{
		Script.ShowHelp( "..\\L2text\\"$str );
	}
	else
	{
		Script.ShowHelp( "..\\L2text\\"$str$".htm" );
	}
}


function winButtonClick()
{	
	local WindowHandle NewWindow;
	local string str;

	str = NEdit.GetString();

	if( str != "" )
	{
		NewWindow = GetWindowHandle( NEdit.GetString() );
		NewWindow.ShowWindow();
		NewWindow.SetFocus();
	}	
}

//레코드를 클릭하면....
function OnClickListCtrlRecord( string ListCtrlID )
{
	local LVDataRecord	record;	
	
	switch(ListCtrlID)
	{
		case "WindowListCtrl" :
			WindowListCtrl.GetSelectedRec( record );
			class'UIAPI_EDITBOX'.static.SetString( "UIToolWnd.NEdit", record.LVDataList[0].szData );
			break;
	}
}

//레코드를 더블클릭하면....
function OnDBClickListCtrlRecord( string ListCtrlID )
{
	local LVDataRecord	record;	
	local WindowHandle NewWindow;

	switch(ListCtrlID)
	{
		case "WindowListCtrl" :
			WindowListCtrl.GetSelectedRec( record );
			
			NewWindow = GetWindowHandle( record.LVDataList[0].szData );
			NewWindow.ShowWindow();
			NewWindow.SetFocus();
			break;
	}
}

function MakeWindowList()
{
	local LVDataRecord Record;
	local int i;	

	for( i = 0 ; i < arrWinList.Length ; i++)
	{
		Record.LVDataList.length = 1;
		Record.LVDataList[0].szData = arrWinList[i];
		class'UIAPI_LISTCTRL'.static.InsertRecord( "UIToolWnd.WindowListCtrl", Record );
	}	
}

function MakeEventBuff2()
{
	local string	        strParam;
	local int               i;


	/*
	ParseInt(param, "ServerID", info.ServerID);
	ParseInt(param, "Max", Max);
	
	Debug("<<<<>>>>>>" $ param);


	//debug("//////////////////////////test_abnormal////////////////////////" $ Max);
	for (i=0; i<Max; i++)
	{
		ParseItemIDWithIndex(param, info.ID, i);
		ParseInt(param, "SkillLevel_" $ i, info.Level);
		ParseInt(param, "RemainTime_" $ i, info.RemainTime);
		ParseString(param, "Name_" $ i, info.Name);
		ParseString(param, "IconName_" $ i, info.IconName);
		ParseString(param, "Description_" $ i, info.Description);
	*/

	ParamAdd(strParam, "ServerID", String(1229005689) );
	ParamAdd(strParam, "Max", String(70) );

	for( i = 0 ; i < 36 ; i++ )
	{
		ParamAdd(strParam, "ClassID_"$i, String(11259) );
		ParamAdd(strParam, "SkillLevel_"$i, String(4) );
		ParamAdd(strParam, "RemainTime_"$i, String(13) );
		ParamAdd(strParam, "Name_"$i, "쇠약의 낙인" );
		ParamAdd(strParam, "IconName_"$i, "icon.skill1263" );
		ParamAdd(strParam, "Description_"$i, "테스트용으로 마구 찍는 디버프ㅋㅋ" );
	}

	for( i = 36 ; i < 70 ; i++ )
	{
		ParamAdd(strParam, "ClassID_"$i, String(1040) );
		ParamAdd(strParam, "SkillLevel_"$i, String(1) );
		ParamAdd(strParam, "RemainTime_"$i, String(942) );
		ParamAdd(strParam, "Name_"$i, "실드" );
		ParamAdd(strParam, "IconName_"$i, "icon.skill1040" );
		ParamAdd(strParam, "Description_"$i, "테스트용으로 마구 찍는 디버프ㅋㅋ" );
	}
	/*
	for( i = 10 ; i < 20 ; i++ )
	{
		ParamAdd(strParam, "ClassID_"$i, String(11260) );
		ParamAdd(strParam, "SkillLevel_"$i, String(4) );
		ParamAdd(strParam, "RemainTime_"$i, String(13) );
		ParamAdd(strParam, "Name_"$i, "쇠약의 낙인" );
		ParamAdd(strParam, "IconName_"$i, "icon.skill1263" );
		ParamAdd(strParam, "Description_"$i, "테스트용으로 마구 찍는 디버프ㅋㅋ" );
	}
*/
	ExecuteEvent(EV_AbnormalStatusNormalItem, strParam);
}
function MakeEventBuff()
{
	local string	        strParam;
	local int               i;
	local TargetStatusWnd   script;

	script = TargetStatusWnd( GetScript( "TargetStatusWnd" ) );
	script.HandleSkillCancel();

	ParamAdd(strParam, "TargetID", String(100) );
	ParamAdd(strParam, "Max", String(40) );

	for( i = 0 ; i < 10 ; i++ )
	{
		ParamAdd(strParam, "Level_"$i, String(1) );
		ParamAdd(strParam, "Sec_"$i, String(100) );
		ParamAdd(strParam, "Count_"$i, String(1) );
		ParamAdd(strParam, "OwnerShip_"$i, String(1) );
	}

	ParamAdd(strParam, "ClassID_0", String(92) );
	ParamAdd(strParam, "ClassID_1", String(101) );
	ParamAdd(strParam, "ClassID_2", String(102) );
	ParamAdd(strParam, "ClassID_3", String(105) );
	ParamAdd(strParam, "ClassID_4", String(115) );
	ParamAdd(strParam, "ClassID_5", String(129) );
	ParamAdd(strParam, "ClassID_6", String(1069) );
	ParamAdd(strParam, "ClassID_7", String(1083) );
	ParamAdd(strParam, "ClassID_8", String(1160) );
	ParamAdd(strParam, "ClassID_9", String(1164) );


	for( i = 10 ; i < 20 ; i++ )
	{
		ParamAdd(strParam, "Level_"$i, String(1) );
		ParamAdd(strParam, "Sec_"$i, String(100) );
		ParamAdd(strParam, "Count_"$i, String(1) );
		ParamAdd(strParam, "OwnerShip_"$i, String(0) );
	}

	ParamAdd(strParam, "ClassID_10", String(92) );
	ParamAdd(strParam, "ClassID_11", String(101) );
	ParamAdd(strParam, "ClassID_12", String(102) );
	ParamAdd(strParam, "ClassID_13", String(105) );
	ParamAdd(strParam, "ClassID_14", String(115) );
	ParamAdd(strParam, "ClassID_15", String(129) );
	ParamAdd(strParam, "ClassID_16", String(1069) );
	ParamAdd(strParam, "ClassID_17", String(1083) );
	ParamAdd(strParam, "ClassID_18", String(1160) );
	ParamAdd(strParam, "ClassID_19", String(1164) );	

	for( i = 20 ; i < 30 ; i++ )
	{
		ParamAdd(strParam, "Level_"$i, String(1) );
		ParamAdd(strParam, "Sec_"$i, String(10) );
		ParamAdd(strParam, "Count_"$i, String(1) );
		ParamAdd(strParam, "OwnerShip_"$i, String(1) );
	}

	ParamAdd(strParam, "ClassID_20", String(77) );
	ParamAdd(strParam, "ClassID_21", String(78) );
	ParamAdd(strParam, "ClassID_22", String(82) );
	ParamAdd(strParam, "ClassID_23", String(91) );
	ParamAdd(strParam, "ClassID_24", String(99) );
	ParamAdd(strParam, "ClassID_25", String(112) );
	ParamAdd(strParam, "ClassID_26", String(113) );
	ParamAdd(strParam, "ClassID_27", String(118) );
	ParamAdd(strParam, "ClassID_28", String(121) );
	ParamAdd(strParam, "ClassID_29", String(137) );

	for( i = 30 ; i < 40 ; i++ )
	{
		ParamAdd(strParam, "Level_"$i, String(1) );
		ParamAdd(strParam, "Sec_"$i, String(10) );
		ParamAdd(strParam, "Count_"$i, String(1) );
		ParamAdd(strParam, "OwnerShip_"$i, String(0) );
	}

	ParamAdd(strParam, "ClassID_30", String(77) );
	ParamAdd(strParam, "ClassID_31", String(78) );
	ParamAdd(strParam, "ClassID_32", String(82) );
	ParamAdd(strParam, "ClassID_33", String(91) );
	ParamAdd(strParam, "ClassID_34", String(99) );
	ParamAdd(strParam, "ClassID_35", String(112) );
	ParamAdd(strParam, "ClassID_36", String(113) );
	ParamAdd(strParam, "ClassID_37", String(118) );
	ParamAdd(strParam, "ClassID_38", String(121) );
	ParamAdd(strParam, "ClassID_39", String(137) );

	ExecuteEvent(EV_TargetSpelledList, strParam);
}


function setArr()
{
	local int index;

	index = 0;
	//itemIDList.Insert(itemIDList.Length,1); itemIDList[itemIDList.Length - 1] = item;

	arrWinList[index++]="AbnormalStatusWnd";
	arrWinList[index++]="ActionWnd";
	arrWinList[index++]="AgeWnd";
	arrWinList[index++]="AITimerWnd";
	arrWinList[index++]="AttributeEnchantWnd";
	arrWinList[index++]="AttributeRemoveWnd";
	//arrWinList[index++]="AuctionBtnWnd";
	arrWinList[index++]="AuctionNextWnd";
	arrWinList[index++]="AuctionWnd";
	arrWinList[index++]="BenchMarkMenuWnd";
	arrWinList[index++]="BirthdayAlarmBtn";
	arrWinList[index++]="BirthdayAlarmWnd";
	arrWinList[index++]="BlockCounter";
	arrWinList[index++]="BlockCurTriggerWnd";
	arrWinList[index++]="BlockCurWnd";
	arrWinList[index++]="BlockEnterWnd";
	arrWinList[index++]="BoardWnd";
	arrWinList[index++]="CalculatorWnd";
	arrWinList[index++]="CharacterCreateMenuWnd";
	//arrWinList[index++]="ChatFilterWnd";
	arrWinList[index++]="ChatWnd";
	arrWinList[index++]="ClanDrawerWnd";
	arrWinList[index++]="ClanWnd";
	arrWinList[index++]="CleftCounter";
	arrWinList[index++]="CleftCurTriggerWnd";
	arrWinList[index++]="CleftCurWnd";
	arrWinList[index++]="CleftEnterWnd";
	arrWinList[index++]="ColorNickNameWnd";
	arrWinList[index++]="ConsoleWnd";
	arrWinList[index++]="CouponEventWnd";
	arrWinList[index++]="DeliverWnd";
	arrWinList[index++]="DepthOfField";
	arrWinList[index++]="DetailStatusWnd";
	arrWinList[index++]="DialogBox";
	arrWinList[index++]="DominionWarInfoWnd";
	arrWinList[index++]="DuelManager";
	arrWinList[index++]="EventMatchGMFenceWnd";
	arrWinList[index++]="EventMatchGMMsgWnd";
	arrWinList[index++]="EventMatchGMWnd";
	arrWinList[index++]="EventMatchObserverWnd";
	arrWinList[index++]="EventMatchSpecialMsgWnd";
	arrWinList[index++]="FileListWnd";
	arrWinList[index++]="FileRegisterWnd";
	arrWinList[index++]="FileWnd";
	arrWinList[index++]="FishViewportWnd";
	arrWinList[index++]="FlightShipCtrlWnd";
	arrWinList[index++]="FlightTeleportWnd";
	arrWinList[index++]="FlightTransformCtrlWnd";
	arrWinList[index++]="GametipWnd";
	arrWinList[index++]="GMClanWnd";
	arrWinList[index++]="GMDetailStatusWnd";
	arrWinList[index++]="GMFindTreeWnd";
	arrWinList[index++]="GMInventoryWnd";
	arrWinList[index++]="GMMagicSkillWnd";
	arrWinList[index++]="GMQuestWnd";
	arrWinList[index++]="GMSnoopWnd";
	arrWinList[index++]="GMWarehouseWnd";
	arrWinList[index++]="GMWnd";
	//arrWinList[index++]="GuideWnd";
	arrWinList[index++]="HelpWnd";
	arrWinList[index++]="HelpHtmlWnd";
	arrWinList[index++]="HennaInfoWnd";
	arrWinList[index++]="HennaListWnd";
	arrWinList[index++]="HeroTowerWnd";
	arrWinList[index++]="InventoryWnd";
	arrWinList[index++]="InviteClanPopWnd";
	arrWinList[index++]="ItemDescWnd";
	arrWinList[index++]="ItemEnchantWnd";
	arrWinList[index++]="KillpointCounterWnd";
	arrWinList[index++]="KillpointRankTrigger";
	arrWinList[index++]="KillPointRankWnd";
	arrWinList[index++]="LoadingAniWnd";
	arrWinList[index++]="LoadingWnd";
	arrWinList[index++]="LoadingWnd_cn";
	arrWinList[index++]="LoadingWnd_e";
	arrWinList[index++]="LoadingWnd_j";
	arrWinList[index++]="LoadingWnd_k";
	arrWinList[index++]="LoadingWnd_ph";
	arrWinList[index++]="LoadingWnd_th";
	arrWinList[index++]="LoadingWnd_tw";
	arrWinList[index++]="LobbyMenuWnd";
	arrWinList[index++]="LoginMenuWnd";
	arrWinList[index++]="MacroEditWnd";
	arrWinList[index++]="MacroListWnd";
	arrWinList[index++]="MagicSkillDrawerWnd";
	arrWinList[index++]="MagicskillGuideWnd";
	arrWinList[index++]="MagicSkillWnd";
	arrWinList[index++]="MailBtnWnd";
	arrWinList[index++]="ManorCropInfoChangeWnd";
	arrWinList[index++]="ManorCropInfoSettingWnd";
	arrWinList[index++]="ManorCropSellChangeWnd";
	arrWinList[index++]="ManorCropSellWnd";
	arrWinList[index++]="ManorInfoWnd";
	arrWinList[index++]="ManorSeedInfoChangeWnd";
	arrWinList[index++]="ManorSeedInfoSettingWnd";
	arrWinList[index++]="ManorShopWnd";
	arrWinList[index++]="MenuWnd";
	arrWinList[index++]="MiniGame1Wnd";
	//arrWinList[index++]="MiniMapDrawerWnd";
	arrWinList[index++]="MinimapWnd";
	//arrWinList[index++]="MinimapWnd_Expand";
	arrWinList[index++]="MoviePlayerWnd";
	arrWinList[index++]="MSViewerWnd";
	arrWinList[index++]="MultiSellWnd";
	arrWinList[index++]="NewPetitionFeedBackResultWnd";
	arrWinList[index++]="NewPetitionFeedBackWnd";
	arrWinList[index++]="NewPetitionFeedBackWnd_2nd";
	arrWinList[index++]="NewPetitionWnd";
	arrWinList[index++]="NewUserPetitionDrawerWnd";
	arrWinList[index++]="NewUserPetitionWnd";
	arrWinList[index++]="NPCDialogWnd";
	arrWinList[index++]="ObserverWnd";
	arrWinList[index++]="OlympiadBuff1Wnd";
	arrWinList[index++]="OlympiadBuff2Wnd";
	arrWinList[index++]="OlympiadBuffWnd";
	arrWinList[index++]="OlympiadControlWnd";
	arrWinList[index++]="OlympiadGuideWnd";
	arrWinList[index++]="OlympiadPlayer1Wnd";
	arrWinList[index++]="OlympiadPlayer2Wnd";
	arrWinList[index++]="OlympiadPlayerWnd";
	arrWinList[index++]="OlympiadTargetWnd";
	arrWinList[index++]="OnScreenMessageWnd";
	arrWinList[index++]="OptionWnd";
	arrWinList[index++]="PartyMatchMakeRoomWnd";
	arrWinList[index++]="PartyMatchOutWaitListWnd";
	arrWinList[index++]="PartyMatchRoomWnd";
	arrWinList[index++]="PartyMatchWaitListWnd";
	arrWinList[index++]="PartyMatchWnd";
	arrWinList[index++]="PartyMatchWndCommon";
	arrWinList[index++]="PartyWnd";
	arrWinList[index++]="PartyWndCompact";
	arrWinList[index++]="PartyWndOption";
	arrWinList[index++]="InfoWnd";
	arrWinList[index++]="PetitionFeedBackWnd";
	arrWinList[index++]="PetitionWnd";
	arrWinList[index++]="PetStatusWnd";
	arrWinList[index++]="PetWnd";
	arrWinList[index++]="PostBoxWnd";
	arrWinList[index++]="PostDetailWnd_General";
	arrWinList[index++]="PostDetailWnd_SafetyTrade";
	arrWinList[index++]="PostEffectTestWnd";
	arrWinList[index++]="PostReceiverListAddWnd";
	arrWinList[index++]="PostReceiverListWnd";
	arrWinList[index++]="PostWriteWnd";
	arrWinList[index++]="PremiumItemAlarmWnd";
		//arrWinList[index++]="PremiumItemBtnWnd";
	arrWinList[index++]="PremiumItemGetWnd";
	arrWinList[index++]="PrivateMarketWnd";
	arrWinList[index++]="PrivateShopWnd";
	arrWinList[index++]="ProgressBox";
	arrWinList[index++]="PVPCounter";
	arrWinList[index++]="PVPCounterTrigger";
	arrWinList[index++]="PVPDetailedWnd";
	arrWinList[index++]="QuestAlarmWnd";
	arrWinList[index++]="QuestBtnWnd";
	arrWinList[index++]="QuestHTMLWnd";
	arrWinList[index++]="QuestListWnd";
	arrWinList[index++]="QuestTreeDrawerWnd";
	arrWinList[index++]="QuestTreeWnd";
	arrWinList[index++]="RadarMapWnd";
	arrWinList[index++]="RadarOptionWnd";
	arrWinList[index++]="RecipeBookWnd";
	arrWinList[index++]="RecipeBuyListWnd";
	arrWinList[index++]="RecipeBuyManufactureWnd";
	arrWinList[index++]="RecipeManufactureWnd";
	arrWinList[index++]="RecipeShopWnd";
	arrWinList[index++]="RecipeTreeWnd";
	arrWinList[index++]="RecommendBonusHelpHtmlWnd";
	arrWinList[index++]="RecommendBonusWnd";
	arrWinList[index++]="RefineryWnd";
	arrWinList[index++]="ReplayListWnd";
	arrWinList[index++]="ReplayLogoWnd";
	arrWinList[index++]="ReplayLogoWnd_cn";
	arrWinList[index++]="ReplayLogoWnd_e";
	arrWinList[index++]="ReplayLogoWnd_j";
	arrWinList[index++]="ReplayLogoWnd_k";
	arrWinList[index++]="ReplayLogoWnd_ph";
	arrWinList[index++]="ReplayLogoWnd_th";
	arrWinList[index++]="ReplayLogoWnd_tw";
	arrWinList[index++]="RestartMenuWnd";
	arrWinList[index++]="SceneEditorDrawerWnd";
	arrWinList[index++]="SceneEditorSlideWnd";
	arrWinList[index++]="SceneEditorWnd";
	arrWinList[index++]="SeedShopWnd";
	arrWinList[index++]="SelectDeliverWnd";
	arrWinList[index++]="ShaderBuild";
	arrWinList[index++]="ShopWnd";
	arrWinList[index++]="Shortcut";
	arrWinList[index++]="ShortcutAssignWnd";
	arrWinList[index++]="ShortcutWnd";
	arrWinList[index++]="SiegeInfoWnd";
	arrWinList[index++]="SkillEnchantInfoWnd";
	arrWinList[index++]="SkillEnchantWnd";
	arrWinList[index++]="SkillTrainClanTreeWnd";
	arrWinList[index++]="SkillTrainInfoWnd";
	arrWinList[index++]="SkillTrainListWnd";
	arrWinList[index++]="SSAOWnd";
	arrWinList[index++]="SSQMainBoard";
	arrWinList[index++]="StatusWnd";
	arrWinList[index++]="SummonedStatusWnd";
	arrWinList[index++]="SummonedWnd";
	//arrWinList[index++]="SystemMenuWnd";
	arrWinList[index++]="SystemMsgWnd";
	//arrWinList[index++]="SystemTutorialBtnWnd";
	//arrWinList[index++]="SystemTutorialWnd";
	arrWinList[index++]="TargetStatusWnd";
	arrWinList[index++]="TeleportBookMarkDrawerWnd";
	arrWinList[index++]="TeleportBookMarkWnd";
	arrWinList[index++]="Tooltip";
	arrWinList[index++]="TownMapWnd";
	arrWinList[index++]="TradeWnd";
	arrWinList[index++]="TutorialBtnWnd";
	arrWinList[index++]="TutorialViewerWnd";
	arrWinList[index++]="UICommonAPI";
	arrWinList[index++]="UIDevWnd";
	arrWinList[index++]="UIEditor_ControlManager";
	arrWinList[index++]="UIEditor_DocumentInfo";
	arrWinList[index++]="UIEditor_FileManager";
	arrWinList[index++]="UIEditor_PropertyController";
	arrWinList[index++]="UIEditor_Worksheet";
	arrWinList[index++]="UITestWnd";
	arrWinList[index++]="UIToolWnd";
	arrWinList[index++]="UnionDetailWnd";
	arrWinList[index++]="UnionMatchDrawerWnd";
	arrWinList[index++]="UnionMatchMakeRoomWnd";
	arrWinList[index++]="UnionMatchWnd";
	arrWinList[index++]="UnionWnd";
	//arrWinList[index++]="UniversalToolTip";
	arrWinList[index++]="UnrefineryWnd";
	arrWinList[index++]="UserPetitionWnd";
	arrWinList[index++]="WarehouseWnd";
	arrWinList[index++]="WeatherWnd";
	arrWinList[index++]="XMasSealWnd";
	arrWinList[index++]="ZoneTitleWnd";
	arrWinList[index++]="PersonalConnectionsWnd";
	arrWinList[index++]="CharacterPasswordWnd";
	arrWinList[index++]="SellingAgencyWnd";
	arrWinList[index++]="AttendCheckWnd";
	arrWinList[index++]="EnsoulWnd";
	arrWinList[index++]="AgitDecoWnd";
	arrWinList[index++]="MacroPresetWnd";
	arrWinList[index++]="ClanGfxWnd";
	MakeWindowList();
}


/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( m_WindowName ).HideWindow();
}


defaultproperties
{
    m_WindowName="UIToolWnd"
}
