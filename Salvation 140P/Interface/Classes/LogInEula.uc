//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : LogIn 스케일폼 버전 - SCALEFORM UI
//                게임 로그인
//
//------------------------------------------------------------------------------------------------------------------------
class LogInEula extends GFxUIScript;

//플래쉬 옵셋 좌표
const FLASH_XPOS = 0;
const FLASH_YPOS = 0;

//Gfx @ uc 연동을 위한 함수
var array<GFxValue> args;
var GFxValue invokeResult;

var int currentScreenWidth, currentScreenHeight;

//UI용 UC
var L2Util util;

function OnRegisterEvent()
{
	RegisterEvent( EV_ShowEula );	
	RegisterEvent( EV_ShowChinaEula );	
	RegisterEvent( EV_ResolutionChanged );

	RegisterEvent( EV_LoginFailFlash );
}

function OnLoad()
{
	registerState( "LogInEula", "EULAMSGSTATE" );
	SetContainer( "ContainerHUD" );	
	SetAlwaysOnTop(true);	
	SetAnchor("", EAnchorPointType.ANCHORPOINT_BottomRight, EAnchorPointType.ANCHORPOINT_TopLeft, 0, 0 );
	//SetFixedPositionRate( 0.5f, 0.46f );	
}

function OnShow(){}
function OnFlashLoaded(){}	
function OnHide()
{
	//RestartFlash();
}

function OnFocus(bool bFlag, bool bTransparency)
{
	/*
	local array<GFxValue> args;
	local GFxValue invokeResult;

	AllocGFxValues(args,2);	
	args[0].setbool(bflag);
	args[1].setbool(bTransparency);
	AllocGFxValue(invokeResult);
		
	Invoke("_root.onFocus", args, invokeResult);

	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);	
*/
}

function OnCallUCFunction( string logicID, string param )
{
	//사용자 동의 함
	if( logicID == "0" )
	{
		EulaAgree( true );
	}
	//사용자 비동의 함
	else if( logicID == "1" )
	{		
		EulaAgree( false );
	}
}

function OnEvent(int Event_ID, string param)
{	
	//local string Eula;
	local string Eula1;
	local string Eula2;

	if( Event_ID == EV_ShowEula )
	{
		if( IsShowWindow() == false )
		{
			//ParseString( param, "EulaTxt", Eula );
			ShowWindow();
			SendEula();
		}
	}
	else if( Event_ID == EV_ShowChinaEula )
	{
		if( IsShowWindow() == false )
		{
			ParseString( param, "EulaTxt1", Eula1 );
			ParseString( param, "EulaTxt2", Eula2 );
			ShowWindow();
			SendChinaEula( Eula1, Eula2 );			
		}
	}
	else if( Event_ID == EV_ResolutionChanged )
	{		
		// 현재 해상도를 얻는다.
		SendScreenSize();
	}
}

//사용자 약관 보내기.
function SendEula()
{
	/*
	// 플래시 타입 데이타 인스턴스 생성
	AllocGFxValues(args, 2);		
	AllocGFxValue(invokeResult);

	// 이벤트 번호 0번
	args[0].SetInt( 0 );
	CreateObject(args[1]);

	SetEulaText(args[1], "Eula"); //branch 111109
	//str = String(args[1]);	
	//args[1].SetMemberString( "Eula", Eula );
	Invoke( "_root.onEvent", args, invokeResult );
*/
	callGFxFunction("LoginEula", "SendEula", "");
	//DeallocGFxValue( invokeResult );
	//DeallocGFxValues( args );

	
	SendScreenSize();
}

//사용자 약관 보내기. 중국
function SendChinaEula( string Eula1, string Eula2 )
{
	// 플래시 타입 데이타 인스턴스 생성
	AllocGFxValues(args, 2);		
	AllocGFxValue(invokeResult);

	// 각성 알람 : 이벤트 번호 1번
	args[0].SetInt( 1 );
	CreateObject(args[1]);

	args[1].SetMemberString( "Eula1", Eula1 );
	args[1].SetMemberString( "Eula2", Eula2 );
	Invoke( "_root.onEvent", args, invokeResult );

	callGFxFunction("LoginEula", "SendChinaEula", "Eula1="$Eula1 @ "Eula2="$Eula2);

	DeallocGFxValue( invokeResult );
	DeallocGFxValues( args );
	

	SendScreenSize();
}

function SendScreenSize()
{
	GetCurrentResolution (currentScreenWidth, currentScreenHeight);

	// 플래시 타입 데이타 인스턴스 생성
	AllocGFxValues(args, 2);		
	AllocGFxValue(invokeResult);

	// 각성 알람 : 이벤트 번호 100번
	args[0].SetInt( 100 );
	CreateObject(args[1]);

	args[1].SetMemberInt( "screenW", currentScreenWidth );
	args[1].SetMemberInt( "screenH", currentScreenHeight );
	Invoke( "_root.onEvent", args, invokeResult );

	DeallocGFxValue( invokeResult );
	DeallocGFxValues( args );
}
defaultproperties
{
}
