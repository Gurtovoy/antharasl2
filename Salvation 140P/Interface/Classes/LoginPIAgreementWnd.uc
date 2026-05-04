//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : LoginPIAgreementWnd 스케일폼 버전 - SCALEFORM UI
//                게임 로그인
//
//------------------------------------------------------------------------------------------------------------------------
class LoginPIAgreementWnd extends GFxUIScript;

//플래쉬 옵셋 좌표
const FLASH_XPOS = 0;
const FLASH_YPOS = 0;

//Gfx @ uc 연동을 위한 함수
var array<GFxValue> args;
var GFxValue invokeResult;

var int currentScreenWidth, currentScreenHeight;

//UI용 UC
var L2Util util;

function OnRegisterEvent(){}

function OnFlashLoaded()
{
	
}

function onShow()
{
	// 플래시 타입 데이타 인스턴스 생성
	AllocGFxValues(args, 1);		
	AllocGFxValue(invokeResult);

	// 각성 알람 : 이벤트 번호 10번
	args[0].SetInt( 0 );
	
	Invoke( "_root.onEvent", args, invokeResult );

	DeallocGFxValue( invokeResult );
	DeallocGFxValues( args );
}

function OnLoad()
{
	registerState( "LoginPIAgreementWnd", "PIAgreementState" );//스테이트 이름 바궈야 함.
	SetAlwaysOnTop(true);
	SetAnchor("", EAnchorPointType.ANCHORPOINT_BottomRight, EAnchorPointType.ANCHORPOINT_TopLeft, 0, 0 );
	SetDefaultShow(true);
	SetContainer("ContainerHUD");
}
defaultproperties
{
}
