//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : toolTipWnd  - SCALEFORM UI
//
//------------------------------------------------------------------------------------------------------------------------
class toolTipWnd extends GFxUIScript;


var int currentScreenWidth, currentScreenHeight;

function OnRegisterEvent()
{
	registerEvent(EV_ResolutionChanged);
	RegisterEvent(EV_StateChanged);
}

function OnLoad()
{
	//registerState( "toolTipWnd", "GamingState" );
	//registerState( "toolTipWnd", "LoginState" );
	
	RegisterState( "toolTipWnd", "LoginState" );
	SetHUD();
	SetAnchor("", EAnchorPointType.ANCHORPOINT_TopLeft, EAnchorPointType.ANCHORPOINT_TopLeft, 0, 0);	
	
}

function OnShow()
{
	// Debug("AlterSkill!!!! onShow");
}

function OnFlashLoaded()
{
	SetRenderOnTop(true);
	SetAlwaysFullAlpha(true);
	IgnoreUIEvent(true);

	SetHavingFocus(false);

	setScreenResolution();
}

function setScreenResolution ()
{
	local array<GFxValue> args;
	local GFxValue invokeResult;

	if (!isShowWindow())
	{
		ShowWindow();
	}

	GetCurrentResolution (currentScreenWidth, currentScreenHeight);		

	AllocGFxValues(args, 2);		
	AllocGFxValue(invokeResult);

	args[0].SetInt(currentScreenWidth);
	args[1].SetInt(currentScreenHeight);

	// Debug("currentScreenWidth" @ currentScreenWidth);
	// Debug("currentScreenHeight" @ currentScreenHeight);
	Invoke("_root.setCurrentResolution", args, invokeResult);

	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);
}

function OnHide()
{
}

function OnCallUCLogic( int logicID, string param )
{
	if (logicID == 1)
	{
		// 생성
		// Invoke("_root.onEvent", args, invokeResult);
		Debug("생성");
	}
	else if (logicID == 2)
	{
		// 삭제
		Debug("삭제");
	}
}

/**
 * 
 * // 현재 사용 안함. 클라이언트에서 바로 swf->swf 로 데이타를 전송하는 형태로 변경 
 * nType (1) 생성
 * nType (2) 삭제 
 **/
function externalCall(int nType, string objectString)
{
	local array<GFxValue> args;
	local GFxValue invokeResult;

	Debug("------------------------->>>>>>>>>>>>");
	Debug("type :" @ nType);
	Debug("obj  : " @ objectString);
	

	ShowWindow();
	setScreenResolution();

	AllocGFxValues(args, 2);		
	AllocGFxValue(invokeResult);

	// 생성:1, 삭제:2
	args[0].SetInt(nType);
	// JSON 스트링 객체 
	CreateObject(args[1]);
	args[1].SetMemberString("objectData"  , objectString);

	Invoke("_root.onEvent", args, invokeResult);

	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);

}

function OnEvent(int Event_ID, string param)
{

	// local array<GFxValue> args;

	// local GFxValue invokeResult;

	
	// 해상도 
	// local int CurrentMaxWidth; 
	// local int CurrentMaxHeight;
	// end

	// Debug("toolTipWnd - " @ Event_ID);
	// Debug(" param : " @ param);

	if (Event_ID == EV_ResolutionChanged)
	{
		// 현재 해상도-> swf
		setScreenResolution();
	}
	else if (Event_ID == EV_StateChanged)
	{
		if (!isShowWindow())
		{
			ShowWindow();
		}
	}

}
defaultproperties
{
}
