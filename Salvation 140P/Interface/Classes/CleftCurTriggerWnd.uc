class CleftCurTriggerWnd extends UIScript;

/**
 * CT3 버전에서 사용 하지 않음.
 */

var WindowHandle Me;
var ButtonHandle CleftCurTriggerBtn;
var WindowHandle CleftCurWnd;

function OnRegisterEvent()
{
	//registerEvent( EV_CleftStateTeam );
	//registerEvent( EV_CleftStatePlayer );
}
function OnLoad()
{
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	if(CREATE_ON_DEMAND==0)
		Initialize();
	else
		InitializeCOD();

	Me.HideWindow();
}

function Initialize()
{
	Me = GetHandle("CleftCurTriggerWnd");
	CleftCurTriggerBtn = ButtonHandle(GetHandle("CleftCurTriggerWnd.CleftCurTriggerBtn"));
	CleftCurWnd = GetHandle("CleftCurWnd");
}

function InitializeCOD()
{
	Me = GetWindowHandle("CleftCurTriggerWnd");
	CleftCurTriggerBtn = GetButtonHandle("CleftCurTriggerWnd.CleftCurTriggerBtn");
	CleftCurWnd = GetWindowHandle("CleftCurWnd");
}


function OnEvent( int a_EventID, String a_Param )
{
	switch( a_EventID )
	{
	case EV_CleftStateTeam:
		me.showwindow();
		break;
	case EV_CleftStatePlayer:
		me.showwindow();
		break;

	}
}






function OnClickButton( string Name )
{
	//~ debug ("Button Clicked1");
	switch( Name )
	{
		case "CleftCurTriggerBtn": 
			//~ debug("Trigger PVPCounterWnd");
			CleftCurWnd.ShowWindow();
			//RequestPVPMatchRecord();
			break;
	}
}
defaultproperties
{
}
