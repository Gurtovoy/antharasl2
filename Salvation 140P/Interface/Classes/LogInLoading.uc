//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : LogInLoading 스케일폼 버전 - SCALEFORM UI
//                게임 로딩, 전화인증
//
//------------------------------------------------------------------------------------------------------------------------
class LogInLoading extends GFxUIScript;

//플래쉬 옵셋 좌표
const FLASH_XPOS = 0;
const FLASH_YPOS = 0;

//Gfx @ uc 연동을 위한 함수
var array<GFxValue> args;
var GFxValue invokeResult;
var int CurrEventID;

//UI용 UC
var L2Util util;

function OnRegisterEvent()
{
	RegisterEvent( EV_LoginWait );
	RegisterEvent( EV_LoginTelephoneWait );
	RegisterEvent( EV_LoginSecurityCard );
	RegisterEvent( EV_LoginGoogleOtp );
	RegisterEvent( EV_StateChanged );
}

function OnLoad()
{
	registerState( "LogInLoading", "LOGINWAITSTATE" );
	registerState( "LogInLoading", "TelephoneAuthState" );
	SetAnchor("", EAnchorPointType.ANCHORPOINT_BottomRight, EAnchorPointType.ANCHORPOINT_TopLeft, 0, 0 );
	//SetFixedPositionRate( 0.5f, 0.59f );
	SetContainer( "ContainerHUD" );
	SetAlwaysOnTop(true);
	CurrEventID = 0;
}

function OnShow(){}
function OnFlashLoaded(){}	
function OnHide(){}
function OnFocus(bool bFlag, bool bTransparency){}

function OnCallUCFunction( string logicID, string param )
{
	local string cardNum;

	//로그인 정보를 받음
	if( logicID == "0" )
	{
		//카드 번호
		ParseSTring( param, "cardNum", cardNum );
		
		if(CurrEventID == EV_LoginGoogleOtp)
		{
			// google otp
			RequestGoogleOtpLogin(cardNum);
		}
		else
		{
			//로그인 요청 API
			RequestSecurityCardLogin(param);
		}
	}
	//나가기
	else if( logicID == "1" )
	{
		if(CurrEventID == EV_LoginGoogleOtp)
		{
			RequestExit();
		}
		else
		{
			RequestCardKeyLoginCancel();
		}
	}
	//로그인 취소
	else if( logicID == "2" )
	{		
		StopLogin();
	}
}

function OnEvent( int Event_ID, string param )
{
	if( Event_ID == EV_LoginWait )
	{	
		if( IsShowWindow() == false )
		{
			ShowWindow();
			SendLoading( param );
		}
	}	
	else if( Event_ID == EV_LoginTelephoneWait )
	{
		if( IsShowWindow() == false )
		{	
			ShowWindow();
			SendTelephoneWait( param );
		}
	}
	if(Event_ID == EV_LoginSecurityCard)
	{
		if( IsShowWindow() == false )
		{	
			ShowWindow();
			SendSecurityCard( param );
		}
	}
	if(Event_ID == EV_LoginGoogleOtp)
	{
		CurrEventID = Event_ID;
		ShowWindow();
		SendSecurityCard(param);
	}
	if( Event_ID == EV_StateChanged)
	{
		callGFxFunction( "LogInLoading", "StateChange", "state=" $ param);
		HideWindow();
	}
}

//로딩일 경우.
function SendLoading( string param )
{
	local string msg;
	ParseString( param, "WaitMsg", msg );

	// 플래시 타입 데이타 인스턴스 생성
	//AllocGFxValues(args, 2);		
	//AllocGFxValue(invokeResult);


	callGFxFunction( "LogInLoading", "SendLoading", "eventID=0 msg=" $ msg);

	//이벤트 번호 0번
	//args[0].SetInt( 0 );
	//CreateObject(args[1]);

	//args[1].SetMemberString( "msg", msg );
	//Invoke( "_root.onEvent", args, invokeResult );

	//DeallocGFxValue( invokeResult );
	//DeallocGFxValues( args );
}

function SendTelephoneWait( string param )
{
	local string msg;
	ParseString( param, "WaitMsg", msg );

	// 플래시 타입 데이타 인스턴스 생성
	//AllocGFxValues(args, 2);		
	//AllocGFxValue(invokeResult);

	callGFxFunction( "LogInLoading", "SendTelephoneWait", "eventID=5 msg=" $ msg);

	//이벤트 번호 5번
	//args[0].SetInt( 5 );
	//CreateObject(args[1]);

	//args[1].SetMemberString( "msg", msg );
	//Invoke( "_root.onEvent", args, invokeResult );

	//DeallocGFxValue( invokeResult );
	//DeallocGFxValues( args );
}

//보안카드 일 경우.
function SendSecurityCard( string param )
{
	local string msg;
	ParseString( param, "msg", msg );

	// 플래시 타입 데이타 인스턴스 생성
	//AllocGFxValues(args, 2);		
	//AllocGFxValue(invokeResult);
	
	callGFxFunction( "LogInLoading", "SendSecurityCard", "eventID=10 msg=" $ msg);

	//이벤트 번호 10번
	//args[0].SetInt( 10 );
	//CreateObject(args[1]);

	//args[1].SetMemberString( "msg", msg );
	//Invoke( "_root.onEvent", args, invokeResult );

	//DeallocGFxValue( invokeResult );
	//DeallocGFxValues( args );
}
defaultproperties
{
}
