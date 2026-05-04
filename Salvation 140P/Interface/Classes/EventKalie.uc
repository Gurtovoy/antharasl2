class EventKalie extends GFxUIScript;
var int currentScreenWidth, currentScreenHeight;

var bool saveShow;


//플래쉬 옵셋 좌표
const FLASH_XPOS = -190;
const FLASH_YPOS = 0;

function OnRegisterEvent()
{
	registerGfxEvent(EV_EventBalthusState);
	registerGfxEvent(EV_EventBalthusJackpotUser);
	registerGfxEvent(EV_EventBalthusDisable);

	// registerGfxEvent(EV_EventBalthusDisable);

	RegisterEvent( EV_ResolutionChanged);
	//RegisterEvent( EV_EventBalthusState);
	RegisterEvent( EV_StateChanged );

	RegisterEvent( EV_Restart );


}

function OnLoad()
{
	SetClosingOnESC();
	registerState( "EventKalie", "GamingState" );
	//반투명 없음
	SetAlwaysFullAlpha( true );
	//포커스 잡지 않음
	SetHavingFocus( false );

	saveShow = false;
}

function OnShow()
{
	saveShow = true;
}


function OnFlashLoaded()
{
	local float xLoc;
	local float yLoc;	

	local array<GFxValue> args;
	local GFxValue invokeResult;

	// 지워도 되지 않을까 싶은데 일단 나둔다. 사용하지 않음.
	RegisterDelegateHandler(EDHandler_EventKalieWnd);	//GetRewardItem()

	//창의 기본 위치 지정 및 세이브 된 창위치로 이동.
	if( IsSavedInfo() )
	{
		SetGFxFromSavedInfo();
	}
	else
	{		
		// 플래시 타입 데이타 인스턴스 생성
		AllocGFxValues(args, 2);		
		AllocGFxValue(invokeResult);

		GetAnchorPointFromWindow( xLoc, yLoc, EAnchorPointType.ANCHORPOINT_TopRight );

		args[0].SetInt( int(xLoc) + FLASH_XPOS );
		args[1].SetInt( int(yLoc) + FLASH_YPOS );

		Invoke( "onMove", args, invokeResult );

		DeallocGFxValue( invokeResult );
		DeallocGFxValues( args );
	}
	setScreenResolution();
}

function setScreenResolution ()
{
	local array<GFxValue> args;
	local GFxValue invokeResult;

	GetCurrentResolution (currentScreenWidth, currentScreenHeight);		

	AllocGFxValues(args, 2);		
	AllocGFxValue(invokeResult);

	args[0].SetInt(currentScreenWidth);
	args[1].SetInt(currentScreenHeight);

	// Debug("currentScreenWidth" @ currentScreenWidth);
	// Debug("currentScreenHeight" @ currentScreenHeight);
	Invoke("setCurrentResolution", args, invokeResult);

	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);
}

function OnEvent(int Event_ID, string param)
{
	local array<GFxValue> args;
	local GFxValue invokeResult;

	if (Event_ID == EV_ResolutionChanged)
	{
		// 현재 해상도-> swf
		setScreenResolution();
	}

	if( Event_ID == EV_StateChanged )
	{
		if (param == "GAMINGSTATE")
		{
			if( saveShow == true )
			{
				SetShowWindow();
			}
		}
		else if(param == "CHARACTERSELECTSTATE")
		{
			
		}
	}
	else if (Event_ID == EV_Restart)
	{
		if( saveShow )
		{
			AllocGFxValues(args, 2);
			AllocGFxValue(invokeResult);
			args[0].SetInt(EV_EventBalthusDisable);
			CreateObject(args[1]);

			Invoke("onEvent", args, invokeResult);
			DeallocGFxValue(invokeResult);
			DeallocGFxValues(args);
			saveShow = false;
		}
		
	}
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

event OnMouseOut( WindowHandle w )
{
	dispatchEventToFlash_String(0, "");
	//강제로 마우스 위치를 0,0으로.
	//ForceToMoveMousePos( 0, 0 );
}

event onMouseOver ( WindowHandle w )
{
	dispatchEventToFlash_String(1, "");
}


function dispatchEventToFlash_String(int Event_ID, string argString){
	local array<GFxValue> args;
	local GFxValue invokeResult;

	AllocGFxValues(args, 2);
	AllocGFxValue(invokeResult);
	args[0].SetInt(Event_ID);
	CreateObject(args[1]);

//	Debug("argString"@argString);
	args[1].SetMemberString("string", argString );

	Invoke("onEvent", args, invokeResult);
	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);
}
defaultproperties
{
}
