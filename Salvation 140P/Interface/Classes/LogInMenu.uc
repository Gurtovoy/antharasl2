//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : LogInMenu 스케일폼 버전 - SCALEFORM UI
//                게임 메뉴
//
//------------------------------------------------------------------------------------------------------------------------
class LogInMenu extends GFxUIScript;

//플래쉬 옵셋 좌표
const FLASH_XPOS = 0;
const FLASH_YPOS = 0;
const DLG_ID_WAITING = 100021;

//Gfx @ uc 연동을 위한 함수
var array<GFxValue> args;
var GFxValue invokeResult;

//UI용 UC
var L2Util util;
var DialogBox  dScript;

var int currentScreenWidth, currentScreenHeight;

function OnRegisterEvent()
{
	RegisterEvent( EV_LoginBegin );
	RegisterEvent( EV_ResolutionChanged );
	RegisterEvent( EV_StateChanged );

	//OpenGivenURL

	RegisterEvent( EV_LoginQueueTicket );	
	RegisterEvent( EV_DialogOK );
}

function OnLoad()
{
	//registerState( "LogInMenu", "LoginState" );
	//registerState( "LogInMenu", "ReplayState" );
	//registerState( "LogInMenu", "LOGINWAITSTATE" );
	//registerState( "LogInMenu", "EULAMSGSTATE" );
	//registerState( "LogInMenu", "SERVERLISTSTATE" );
	SetHavingFocus( false );	
	SetContainer("ContainerHUD");
	SetAnchor( "", EAnchorPointType.ANCHORPOINT_BottomLeft, EAnchorPointType.ANCHORPOINT_BottomLeft, FLASH_XPOS, FLASH_YPOS );

	dScript = DialogBox(GetScript("DialogBox"));
}

function OnShow()
{
	
}

function OnFlashLoaded()
{	
	SendCurrLanguage();
	//Debug( "laugnage" @ string(  language ) );
}

function OnFocus(bool bFlag, bool bTransparency){}

function OnHide()
{
	//RestartFlash();
}

function OnCallUCFunction( string logicID, string param )
{	
	local string	        strParam;

	//Debug ("OnCallUCLogic 로그인 메뉴" @ logicID);
	//branch 110720
	if( logicID == "0" )	
	{
		//태국어 예외처리
		if( IsNative() == false && getLanguageNum() == 5 )	
		{
			ParamAdd( strParam, "ErrorMsg", MakeFullSystemMsg( GetSystemMessage(6090) , GetSystemMessage(6088), GetSystemMessage(6089) ) );
		}
		else
		{
			ParamAdd( strParam, "ErrorMsg", GetSystemMessage(5019) );
		}		
		ExecuteEvent( EV_LoginFailFlash, strParam );
	}
	else if( logicID == "1" )
	{
		//태국어 예외처리
		if( IsNative() == false && getLanguageNum() == 5  )	
		{
			ParamAdd( strParam, "ErrorMsg", MakeFullSystemMsg( GetSystemMessage(6087) , GetSystemMessage(6088), GetSystemMessage(6089) ) );
		}
		else
		{
			ParamAdd( strParam, "ErrorMsg", GetSystemMessage(5020) );
		}			
		ExecuteEvent( EV_LoginFailFlash, strParam );
	}
	//end of branch
	else if( logicID == "2" )
	{
		OpenL2Home();
	}
	//크레딧.
	else if( logicID == "3" )
	{
		// SetUIState("CreditState");
		// InitCreditState();
		StartCredit();
	}
	else if( logicID == "4" )
	{
		SetUIState("ReplaySelectState");
	}
	else if( logicID == "5" )
	{
		HandleShowOptionWnd();
	}	
	else if( logicID == "6" )
	{		
		ParamAdd( strParam, "ErrorMsg", GetSystemMessage(4082) );		
		ExecuteEvent( EV_LoginFailFlash, strParam );
	}
}

function OnEvent(int Event_ID, string param)
{	
	if( Event_ID == EV_LoginBegin )
	{
		if( IsShowWindow() == false )
		{
			ShowWindow();
			SendScreenSize();
		}
		//Debug("Language"@ GetLanguage() );
	}
	else if( Event_ID == EV_ResolutionChanged )
	{		
		// 현재 해상도를 얻는다.
		SendScreenSize();
	}
	else if( Event_ID == EV_StateChanged )
	{
		switch( param )
		{
			case "LoginState":
				SendSetButtonVisible( true );
				break;
			case "ReplaySelectState":
			case "LOGINWAITSTATE":
			case "EULAMSGSTATE":
			case "SERVERLISTSTATE":
			case "PIAgreementState":
			case "LOGINWAITSTATE":
				ShowWindow();
				SendSetButtonVisible( false );
				break;
			default :
				HideWindow();
				/*

			case "ReplayState":
			case "CHARACTERSELECTSTATE":				
			case "CreditState":
			case "ShaderBuildState":
			case "PAWNVIEWERSTATE" :
				HideWindow();
				break;
*/
		}
	}
	// 대기열 발생
	else if( Event_ID == EV_LoginQueueTicket )
	{
		waitingProcess(param);
	}
	//   대기열 취소
	else if( Event_ID == EV_DialogOK )
	{
		if (!(dScript.GetTarget() == string(Self))) return;

		switch(dScript.GetID())
		{
		case DLG_ID_WAITING :
			debug("LoginState->" @ param);
			CancelWaitingQueueTicket();
			SetUIState("LoginState");
			break;
		}
	}
}

/** 대기열 처리 **/
function waitingProcess(string param)
{
	local int nResult;
	local int nWaiterCount;

	local string messageString;

	ParseInt(param, "nResult"     , nResult);	
	ParseInt(param, "nWaiterCount", nWaiterCount);

	messageString = "";	

	Debug("waitingProcess param" @ param);

	dScript.HideDialog();
	if (nResult == 1 && nWaiterCount > 0) 
	{
		// - "현재 서버 접속 대기 인원은 $s1명입니다. 취소 버튼을 누르시면 서버 접속을 종료 합니다." 
		messageString = MakeFullSystemMsg(GetSystemMessage(6830), String(nWaiterCount)); // 중국버전은 7202 시스템메시지를 사용하지만, 해외버전은 6830으로 변경함.
		if (len(messageString) > 0 )//|| !IsFinalRelease())
		{
			dScript.ShowDialog(DialogModalType_Modal, DialogType_Notice, messageString, string(Self) );
			dScript.SetID( DLG_ID_WAITING );
			dScript.SetButtonName(1342);  // 취소
		}
	}
	else if (nResult == 1 && nWaiterCount == 0) 
	{
		// 서버 입장
		// empty 
	}
	else
	{
		// - "서버 접속 대기 중에 오류가 발생하였습니다. 잠시 후에 다시 접속하시기 바랍니다."		
		messageString = MakeFullSystemMsg(GetSystemMessage(7203), String(nWaiterCount));
		dScript.ShowDialog(DialogModalType_Modal, DialogType_Notice, messageString, string(Self) );
		dScript.SetID( DLG_ID_WAITING );
	}
}

/*
 *	registerState( "LogInMenu", "ReplayState" );
	registerState( "LogInMenu", "LOGINWAITSTATE" );
	registerState( "LogInMenu", "EULAMSGSTATE" );
	registerState( "LogInMenu", "SERVERLISTSTATE" );*/

/**
 * 각 스테이지 별로 버튼의 상태 변경.
 */
function SendSetButtonVisible( bool b )
{
	//Debug( "SendSetButtonVisible" @ b );
	// 플래시 타입 데이타 인스턴스 생성
	//AllocGFxValues(args, 2);		
	//AllocGFxValue(invokeResult);

	// 이벤트 번호 50번
	//args[0].SetInt( 50 );
	//CreateObject(args[1]);

	callGFxFunction( "LogInMenu", "SendSetButtonVisible", "bool=" $ b);
	//args[1].SetMemberBool( "visible", b );
	//Invoke( "_root.onEvent", args, invokeResult );

	//DeallocGFxValue( invokeResult );
	//DeallocGFxValues( args );
}

function SendCurrLanguage()
{	
	local int languageNum;

	// 플래시 타입 데이타 인스턴스 생성
	AllocGFxValues(args, 2);
	AllocGFxValue(invokeResult);

	// 이벤트 번호 51번
	args[0].SetInt( 51 );
	CreateObject(args[1]);
		
		//branch 110706
	languageNum = getLanguageNum();
	if( IsNative() == false && getLanguageNum() == 5 )	
	{
		languageNum = 1;
	}

	callGFxFunction( "LogInMenu", "SendCurrLanguage", "language=" $ languageNum);
	args[1].SetMemberInt( "language", languageNum );
	Invoke( "_root.onEvent", args, invokeResult );
	//end of branch

	DeallocGFxValue( invokeResult );
	DeallocGFxValues( args );
}

function int getLanguageNum()
{
	local ELanguageType Language;
//	local int languageNum;
	Language = GetLanguage();
	return  int(Language) ;	
/*
	switch( Language )
	{	
		case LANG_Korean:
			languageNum = 0;
			break;	
		case LANG_English:
			languageNum = 1;
			break;
		case LANG_Japanese:
			languageNum = 2;
			break;
		case LANG_Taiwan:
			languageNum = 3;
			break;
		case LANG_Chinese:	
			languageNum = 4;
			break;
		case LANG_Thai:		
			languageNum = 5;
			break;
		case LANG_Philippine:
			languageNum = 6;
			break;
		case LANG_Indonesia:
			languageNum = 7;
			break;
		case LANG_Russia:	
			languageNum = 8;
			break;
		//branch 110824
		case LANG_Euro:	
			languageNum = 9;
			break;
		case LANG_Germany:	
			languageNum = 10;
			break;
		case LANG_France:	
			languageNum = 11;
			break;
		case LANG_Poland:	
			languageNum = 12;
			break;
		case LANG_Turkey:	
			languageNum = 13;
			break;
		default:
			languageNum = 0;
			break;
	}	
	return languageNum;	 //<< 가시 적으로 이렇게 팅겨 줘도 됨.
*/
}



/**
 * 해상도 변경.
 */
function SendScreenSize()
{
	GetCurrentResolution (currentScreenWidth, currentScreenHeight);

	// 플래시 타입 데이타 인스턴스 생성
	AllocGFxValues(args, 2);		
	AllocGFxValue(invokeResult);

	// 이벤트 번호 100번
	args[0].SetInt( 100 );
	CreateObject(args[1]);

	args[1].SetMemberInt( "screenW", currentScreenWidth );

	callGFxFunction( "LogInMenu", "SendScreenSize", "w=" $ currentScreenWidth);

	Invoke( "_root.onEvent", args, invokeResult );

	DeallocGFxValue( invokeResult );
	DeallocGFxValues( args );
}



/**
 * 옵션 창 열기
 */
function HandleShowOptionWnd()
{
	local OptionWnd win;	
	win = OptionWnd( GetScript("OptionWnd") );
	win.ToggleOpenMeWnd(false);  //그냥 열기 
	//ExecuteEvent( EV_OptionWndShow ) 
}
defaultproperties
{
}
