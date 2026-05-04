class UIDebugWnd extends GFxUIScript;

var array<GFxValue> args;
var GFxValue invokeResult;

var bool bShow;

function OnRegisterEvent()
{
	//메일 알림 이벤트
	RegisterEvent( EV_FlashDebugMsg );
}

function OnLoad()
{
	registerState( "UIDebugWnd", "GamingState" );
}

function OnShow()
{
	bShow = true;
	//Debug("UIDebug!!!! onShow");	
}
function OnFlashLoaded()
{	
}
function OnHide()
{	
	bShow = false;
}

function OnEvent(int Event_ID, string param)
{
	if ( Event_ID == EV_FlashDebugMsg )
	{
		//ShowWindow();
		//Debug( param );
		if( bShow == true )
		{
			SendFlashDebug( param );
		}
	}
}

function SendFlashDebug( string param )
{
	// 플래시 타입 데이타 인스턴스 생성
	AllocGFxValues(args, 2);		
	AllocGFxValue(invokeResult);

	// 발동 스킬 생성 : 이벤트 번호 0번
	args[0].SetInt( 0 );

	CreateObject(args[1]);
	args[1].SetMemberString( "Trace" , param );

	Invoke( "_root.onEvent", args, invokeResult );

	DeallocGFxValue( invokeResult );
	DeallocGFxValues( args );
}
defaultproperties
{
}
