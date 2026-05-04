/***
 *   종료 리포트 (종료, 리스타트 창)
 *   
 *   - 인존 정보 삭제 버전
 **/
class QuitReportWnd extends UICommonAPI;

const TIMER_ID = 999001;

var WindowHandle  Me;
var WindowHandle  PlayReportWnd;

var TextureHandle texQuitReportWnd_Groupbox1;
var TextureHandle texQuitReportWnd_Groupbox3;

var TextureHandle  ButtonIconImg_Texture;

var TextureHandle PlayReportWnd_Groupbox;

var TextBoxHandle txtPlayReportWnd_Title;

var TextBoxHandle txtPlayReportWnd_expHead;
var TextBoxHandle txtPlayReportWnd_adenaHead;
var TextBoxHandle txtPlayReportWnd_itemHead;


var TextBoxHandle txtPlayReportWnd_exp;
var TextBoxHandle txtPlayReportWnd_adena;
var TextBoxHandle txtPlayReportWnd_item;

var ButtonHandle   ITEMButton_Right;
var ButtonHandle   ITEMButton_Reset;
// var WindowHandle   InstanceDungeonWnd;

// var TextureHandle  InstanceDungeon_ListBG;
// var TextBoxHandle  txtInstanceDungeon_Title;

// var ListCtrlHandle InstanceDungeon_ListCtrl;

var ButtonHandle BtnRestart;
var ButtonHandle BtnCancel;


var int64 beforeExp, BIT_exp, beforeAdena, adena;  //, beforeNPKCount;

var bool firstSetting, firstAdenaSetting;

var string quitOrRestartExeStr;

// 얻은 아이템 목록
var array<ItemInfo>	getItemInfoArray;

var L2Util util;
var InventoryWnd inventoryWndScript;
var QuitReportDrawerWnd QuitReportDrawerWndScript;

var UserInfo playerInfo;

// RequestInzoneWaitingTime() 의 이벤트를 받기전에 true로 되어 있을때만 받음.
//var bool enableRequestAPI;

function OnRegisterEvent()
{
	RegisterEvent(EV_Restart);
	RegisterEvent(EV_UpdateUserInfo);
	// registerEvent(EV_InzoneWaitingInfo)
	// 
	RegisterEvent( EV_AdenaInvenCount );

	RegisterEvent( EV_OpenDialogQuit );
	RegisterEvent( EV_OpenDialogRestart );

	RegisterEvent( EV_ChangedSubjob );
}

function OnLoad()
{
	SetClosingOnESC();
	Initialize();
	
	// 끄기로 했음(사업부에서 끄기로 했음)
	// Me.SetModal(true);
}

function OnShow()
{
	Me.SetFocus();
	UpdateUserInfoHandler();

	//Me.BringToFront();
}

function Initialize()
{
	Me = GetWindowHandle( "QuitReportWnd" );

	texQuitReportWnd_Groupbox1 = GetTextureHandle( "QuitReportWnd.texQuitReportWnd_Groupbox1" );
	texQuitReportWnd_Groupbox3 = GetTextureHandle( "QuitReportWnd.texQuitReportWnd_Groupbox3" );

	PlayReportWnd_Groupbox     = GetTextureHandle( "QuitReportWnd.PlayReportWnd.PlayReportWnd_Groupbox" );

	txtPlayReportWnd_Title     = GetTextBoxHandle( "QuitReportWnd.PlayReportWnd.txtPlayReportWnd_Title" );
	txtPlayReportWnd_expHead   = GetTextBoxHandle( "QuitReportWnd.PlayReportWnd.txtPlayReportWnd_expHead" );
	txtPlayReportWnd_adenaHead = GetTextBoxHandle( "QuitReportWnd.PlayReportWnd.txtPlayReportWnd_adenaHead" );
	txtPlayReportWnd_itemHead  = GetTextBoxHandle( "QuitReportWnd.PlayReportWnd.txtPlayReportWnd_itemHead" );

	txtPlayReportWnd_item  = GetTextBoxHandle( "QuitReportWnd.PlayReportWnd.txtPlayReportWnd_item" );
	txtPlayReportWnd_exp   = GetTextBoxHandle( "QuitReportWnd.PlayReportWnd.txtPlayReportWnd_exp" );
	txtPlayReportWnd_adena = GetTextBoxHandle( "QuitReportWnd.PlayReportWnd.txtPlayReportWnd_adena" );

	//InstanceDungeonWnd = GetWindowHandle( "QuitReportWnd.InstanceDungeonWnd" );

	//InstanceDungeon_ListBG   = GetTextureHandle( "QuitReportWnd.InstanceDungeonWnd.InstanceDungeon_ListBG" );
	//txtInstanceDungeon_Title = GetTextBoxHandle( "QuitReportWnd.InstanceDungeonWnd.txtInstanceDungeon_Title" );

	//InstanceDungeon_ListCtrl = GetListCtrlHandle( "QuitReportWnd.InstanceDungeonWnd.InstanceDungeon_ListCtrl" );

	ITEMButton_Right = GetButtonHandle( "QuitReportWnd.PlayReportWnd.ITEMButton_Right" );
	ITEMButton_Reset = GetButtonHandle( "QuitReportWnd.PlayReportWnd.ITEMButton_Reset" );

	BtnRestart = GetButtonHandle( "QuitReportWnd.BtnRestart" );
	BtnCancel  = GetButtonHandle( "QuitReportWnd.BtnCancel" );

	// 종료 버튼 이미지 
	ButtonIconImg_Texture = GetTextureHandle("QuitReportWnd.ButtonIconImg_Texture");

	util                       = L2Util(GetScript("L2Util"));
	inventoryWndScript         = inventoryWnd(GetScript("inventoryWnd"));
	QuitReportDrawerWndScript  = QuitReportDrawerWnd(GetScript( "QuitReportDrawerWnd"));

	init();
}

// 초기화
function init()
{
	//quitOrRestartExeStr = "quit";
	beforeExp = 0;
	BIT_exp = 0;

	adena = 0;
	beforeAdena = GetAdena();
	
	//beforeNPKCount = -1;
	firstSetting = false;
	firstAdenaSetting = false;
	//enableRequestAPI = false;

	//QuitReportDrawerWndScript.init();

	txtPlayReportWnd_exp.SetText(MakeFullSystemMsg(GetSystemMessage(4323), "0"));
	txtPlayReportWnd_item.SetText(MakeFullSystemMsg(GetSystemMessage(1983), "0"));	
	txtPlayReportWnd_adena.SetText(MakeFullSystemMsg(GetSystemMessage(2932), "0"));

	// RequestInzoneWaitingTime();
	if (GetWindowHandle("QuitReportDrawerWnd").IsShowWindow())
	{
		setDrawerButtonState(true);
		GetWindowHandle("QuitReportDrawerWnd").HideWindow();
	}
}

// 보조 윈도우, 열고 닫을때, >  < 버튼 텍스쳐 변경
function setDrawerButtonState(bool bShow)
{
	if (bShow)
	{
		ITEMButton_Right.SetTexture("L2UI_CT1.Button.Button_DF_Right_Down", 
									"L2UI_CT1.Button.Button_DF_Right_Down",
									"L2UI_CT1.Button.Button_DF_Right_Over");
	}
	else
	{
		ITEMButton_Right.SetTexture("L2UI_CT1.Button.Button_DF_Left_Down", 
									"L2UI_CT1.Button.Button_DF_Left_Down", 
									"L2UI_CT1.Button.Button_DF_Left_Over");
	}	
}

//-----------------------------------------------------------------------------------------------------------
// OnClickButton
//-----------------------------------------------------------------------------------------------------------
function OnClickButton( string Name )
{
	switch( Name )
	{
		case "ITEMButton_Right":
			 if(!GetWindowHandle("QuitReportDrawerWnd").IsShowWindow())
			 {
				setDrawerButtonState(false);
		 		GetWindowHandle("QuitReportDrawerWnd").ShowWindow();
			 }
			 else 
			 {
				setDrawerButtonState(true);				
				GetWindowHandle("QuitReportDrawerWnd").HideWindow();
			 }
			 break;

		case "ITEMButton_Reset":
			 OnITEMButton_ResetClick();
			 break;

		case "BtnRestart":
			 ExecuteQuitOrRestart();
			 Me.HideWindow();
			 break;

		case "BtnCancel":
			 OnBtnCancelClick();

			 break;
	}
}

// 종료, 리스타트 처리
function ExecuteQuitOrRestart()
{
	local InventoryWnd Script;
	Script = InventoryWnd(GetScript("InventoryWnd"));
	Script.SaveInventoryOrder();

	if (quitOrRestartExeStr == "quit")
	{
		ExecQuit();
	}
	else
	{
		//리스타트시 숨길 윈도우(기존에 있던거라 넣음)
		//GetWindowHandle("SystemMenuWnd").HideWindow();		
		ExecRestart();
	}
}

// 초기화
function OnITEMButton_ResetClick()
{

	GetPlayerInfo(playerInfo);

	beforeExp      = playerInfo.nCurExp;
	//beforeExp = 0;
	BIT_exp = 0;

	adena = 0;
	beforeAdena = GetAdena();
	
	//beforeNPKCount = -1;
	firstSetting = true;
	firstAdenaSetting = true;
	//enableRequestAPI = false;

	QuitReportDrawerWndScript.init();

	txtPlayReportWnd_exp.SetText(MakeFullSystemMsg(GetSystemMessage(4323), "0"));
	txtPlayReportWnd_item.SetText(MakeFullSystemMsg(GetSystemMessage(1983), "0"));	
	txtPlayReportWnd_adena.SetText(MakeFullSystemMsg(GetSystemMessage(2932), "0"));

	// RequestInzoneWaitingTime();
	if (GetWindowHandle("QuitReportDrawerWnd").IsShowWindow())
	{
		setDrawerButtonState(true);
		GetWindowHandle("QuitReportDrawerWnd").HideWindow();
	}
}

function OnBtnCancelClick()
{
	Me.HideWindow();
}

//-----------------------------------------------------------------------------------------------------------
// Evnet
//-----------------------------------------------------------------------------------------------------------
function OnEvent( int a_EventID, String a_Param )
{
	local int64 pAdena;
	if(a_EventID == EV_AdenaInvenCount)
	{
		ParseINT64 (a_Param, "Adena", pAdena);
		//Debug("EV_AdenaInvenCount: " @ a_Param);
		UpdateAdena(pAdena);
	}
	else if( a_EventID == EV_Restart )
	{
		init();
		QuitReportDrawerWndScript.init();
		// InstanceDungeon_ListCtrl.DeleteAllItem();
	}
	else if( a_EventID == EV_OpenDialogQuit )
	{
		quitOrRestartExeStr = "quit";
		ButtonIconImg_Texture.SetTexture("L2UI_CT1.Icon.QuitIcon");
		BtnRestart.SetButtonName(148);
		Me.SetWindowTitle(GetSystemString(148));

		// enableRequestAPI = true;
		// RequestInzoneWaitingTime();

		Me.ShowWindow();
		Me.SetFocus();
	}
	else if( a_EventID == EV_OpenDialogRestart )
	{
		quitOrRestartExeStr = "restart";
		ButtonIconImg_Texture.SetTexture("L2UI_CT1.Icon.RestartIcon");
		BtnRestart.SetButtonName(147);
		Me.SetWindowTitle(GetSystemString(147));

		// enableRequestAPI = true;
		// RequestInzoneWaitingTime();

		Me.ShowWindow();
		Me.SetFocus();
	}
	else if( a_EventID == EV_UpdateUserInfo )
	{
		//  Debug("EV_UpdateUserInfo" @ EV_UpdateUserInfo);
		UpdateUserInfoHandler();
	}
	// 듀얼 서브 변신 할때, exp 초기화 
	else if (a_EventID  == EV_ChangedSubjob )
	{		
		// 경험치 부분만 초기화
		firstSetting = false;
		beforeExp = 0;
		BIT_exp = 0;
		txtPlayReportWnd_exp.SetText(MakeFullSystemMsg(GetSystemMessage(4323), "0"));
	}

	//else if( a_EventID == EV_InzoneWaitingInfo )
	//{
	//	if (enableRequestAPI)
	//	{
	//		handleInzoneWaitingInfo(a_Param);
	//		enableRequestAPI = false;
	//	}
	//	//Debug("handleInzoneWaitingInfo : " @ a_Param);
	//}
}

//// 인스턴스 던전 이용 제한 시간 
//function string handleInzoneWaitingInfo(string param)
//{
//	local int currentInzoneID;
//	local int sizeOfBlockedInzone ;
//	local int blockedInzoneID ;
//	local int blockedInzoneLeftSeconds ;
//	local string currentInzoneName;
//	local string blockedInzoneName;
//	local string LeftTime;

//	local int i;

//	local string strParam ;
	
//	parseInt (param, "currentInzoneID" , currentInzoneID );
//	currentInzoneName = GetInZoneNameWithZoneID(currentInzoneID);
//	if (currentInzoneName == "Invalid inzone ID") currentInzoneName =  "";

//	ParamAdd( strParam, "currentInzoneName", currentInzoneName ) ;
	
//	parseInt (param, "sizeOfBlockedInzone" , sizeOfBlockedInzone );	
//	ParamAdd( strParam, "sizeOfBlockedInzone", String ( sizeOfBlockedInzone ) ) ;
	
//	//Debug("sizeOfBlockedInzone=== " @ sizeOfBlockedInzone);

//	//InstanceDungeon_ListCtrl.DeleteAllItem();

//	for (i = 0 ; i <  sizeOfBlockedInzone ; i++ ) 
//	{
//		parseInt (param, "blockedInzoneID_"$i, blockedInzoneID );		
//		parseInt (param, "blockedInzoneLeftSeconds_"$i , blockedInzoneLeftSeconds );		
//		blockedInzoneName = GetInZoneNameWithZoneID(blockedInzoneID);
//		LeftTime = setTimeString ( blockedInzoneLeftSeconds );

//		ParamAdd( strParam, "blockedInzoneName_"$i, blockedInzoneName );
//		ParamAdd( strParam, "blockedInzoneTimeString_"$i, LeftTime );
//		ParamAdd( strParam, "blockedInzoneTime_"$i, String( blockedInzoneLeftSeconds ) );

//		// 인존이름, 남은 시간
//		addInzoneListItem(blockedInzoneName, LeftTime);
//	}

//	// Debug("blockedInzoneName" @ blockedInzoneName);
//	// Debug("LeftTime" @ LeftTime);

//	return strParam;
//}

/** 아이템을 추가 한다. */
function addInzoneListItem(string inzoneName, string remainTimeStr)
{
	local LVDataRecord Record;

	Record.LVDataList.length = 2;
	//Record.LVDataList[0].textColor = getColor(100,30,3, 255);
	Record.LVDataList[0].szData = inzoneName;
	Record.LVDataList[1].szData = remainTimeStr;

	//InstanceDungeon_ListCtrl.InsertRecord( Record );
}

function string setTimeString(int tmpTime)
{
	//규칙 1시간 이상은 시간만
	//1시간 이하는 분만
	//1분 이하는 1분 이하
	local string timeStr;
	local int timeHour;
	local int timeMin;
	//local int stringNum
	//Debug("타임을 세팅합니다.");
	//Debug("tmpTime=== " @ tmpTime);
	if ( tmpTime < 60 ) //분 미만으로
	{ 			
		timeStr = MakeFullSystemMsg( GetSystemMessage(3390), string(1)); //1 분
		timeStr = MakeFullSystemMsg( GetSystemMessage(3408), timeStr);   //미만
	} 
	else if ( tmpTime < 3600 ) {//몇 분으로	
		tmpTime = tmpTime/60;
		timeStr = MakeFullSystemMsg( GetSystemMessage(3390), string(tmpTime));			
	} 
	else {//시간
		//tmpTime = tmpTime/3600;
		//timeStr = MakeFullSystemMsg( GetSystemMessage(3406), string(tmpTime));	
		//timeHour = 	tmpTime/3600;	
			

		timeHour = tmpTime/3600;
		timeMin	= (tmpTime - timeHour*3600)/60;
		//Debug("timeHour=== " @ timeHour);
		//Debug("timeMin=== " @ timeMin);
		if(timeMin > 0){
			timeStr = MakeFullSystemMsg( GetSystemMessage(3406), string(timeHour)) @ MakeFullSystemMsg( GetSystemMessage(3390), string(timeMin));
		}else {
			timeStr = MakeFullSystemMsg( GetSystemMessage(3406), string(timeHour));
		}
		
	}
	//Debug("timeStr=== " @ timeStr);
	return timeStr;
}

// 아데나 업데이트
function UpdateAdena(Int64 pAdena)
{
	// 최초 정보를 받았을때만..
	if (firstAdenaSetting == false)
	{	
		adena = 0;
		beforeAdena = pAdena;
		firstAdenaSetting = true;
	}

	if (pAdena > beforeAdena)
	{   
		adena = adena + (pAdena - beforeAdena);
	}
	beforeAdena = pAdena;

	if (adena > 0)
		txtPlayReportWnd_adena.SetText(MakeFullSystemMsg(GetSystemMessage(2932), MakeCostString(String(adena))));	
	else 
		txtPlayReportWnd_adena.SetText(MakeFullSystemMsg(GetSystemMessage(2932), "0"));
}

// 유저 정보가 업데이트 될때 
function UpdateUserInfoHandler()
{	
	//local string HtmlString;
	local int64 itemCount;

	// 게이밍 스테이트인 동안만
	if (GetGameStateName() != "GAMINGSTATE") return;

	GetPlayerInfo(playerInfo);

	// 최초 정보를 받았을때만..
	if (firstSetting == false)
	{		
		firstSetting   = true;
		beforeExp      = playerInfo.nCurExp;
		BIT_exp            = 0;

		// Debug("- playerInfo.nCurExp" @ playerInfo.nCurExp);
		if (Me.IsShowWindow())
		{
			if (BIT_exp > 0) 
				txtPlayReportWnd_exp.SetText(MakeFullSystemMsg(GetSystemMessage(4323), MakeCostString(String(BIT_exp))));
			else 
				txtPlayReportWnd_exp.SetText(MakeFullSystemMsg(GetSystemMessage(4323), "0"));
		}
	}

	if (playerInfo.nCurExp > beforeExp)
	{   
		BIT_exp = BIT_exp + (playerInfo.nCurExp - beforeExp);
	}
	beforeExp = playerInfo.nCurExp;

	// 일질적으로 창이 열려 있을때만 갱신한다.
	if (Me.IsShowWindow())
	{
		itemCount = QuitReportDrawerWndScript.getTotalItemCount();
		//adena     = QuitReportDrawerWndScript.getTotalAdena();

		if (BIT_exp > 0) 
			txtPlayReportWnd_exp.SetText(MakeFullSystemMsg(GetSystemMessage(4323), MakeCostString(String(BIT_exp))));
		else 
			txtPlayReportWnd_exp.SetText(MakeFullSystemMsg(GetSystemMessage(4323), "0"));

		if (itemCount > 0) 
			txtPlayReportWnd_item.SetText(MakeFullSystemMsg(GetSystemMessage(1983), MakeCostString(String(itemCount))));	
		else 
			txtPlayReportWnd_item.SetText(MakeFullSystemMsg(GetSystemMessage(1983), "0"));
	}
}

function OnTimer(int TimerID)
{
	if( TimerID == TIMER_ID)
	{
		beforeAdena    = GetAdena();
		Me.KillTimer( TIMER_ID );
	}
}

// 외부(인벤토리) 에서 아이템을 추가 하는 것
function externalAddItem(ItemInfo addItemInfo)
{
	// 아데나 카운트 갱신 
	QuitReportDrawerWndScript.externalAddItem(addItemInfo);
}

///**
// * 윈도우 ESC 키로 닫기 처리 
// * "Esc" Key
// ***/
//function OnKeyUp( WindowHandle a_WindowHandle, EInputKey Key )
//{
//	if( Key == IK_Escape )
//	{
//		PlayConsoleSound(IFST_WINDOW_CLOSE);		
//		GetWindowHandle( getCurrentWindowName(string(Self))).HideWindow();
//	}
//}
/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( getCurrentWindowName(string(Self))).HideWindow();
}
defaultproperties
{
}
