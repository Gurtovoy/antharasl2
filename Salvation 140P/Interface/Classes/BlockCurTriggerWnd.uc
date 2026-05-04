class BlockCurTriggerWnd extends UIScript;

/**
 * CT3 버전에서 사용 하지 않음.
 */

var WindowHandle Me;
var ButtonHandle BlockCurTriggerBtn;
var WindowHandle BlockCurWnd;

function OnRegisterEvent()
{
	//registerEvent( EV_BlockStateTeam );
	//registerEvent( EV_BlockStatePlayer );
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
	Me = GetHandle("BlockCurTriggerWnd");
	BlockCurTriggerBtn = ButtonHandle(GetHandle("BlockCurTriggerBtn"));
	BlockCurWnd = GetHandle("BlockCurWnd");
}

function InitializeCOD()
{
	Me = GetWindowHandle("BlockCurTriggerWnd");
	BlockCurTriggerBtn = GetButtonHandle("BlockCurTriggerWnd.BlockTriggerBtn");
	BlockCurWnd = GetWindowHandle("BlockCurWnd");
}


function OnEvent( int a_EventID, String a_Param )
{
	switch( a_EventID )
	{
	case EV_BlockStateTeam:
		me.showwindow();
		break;
	case EV_BlockStatePlayer:
		me.showwindow();
		break;

	}
}






function OnClickButton( string Name )
{
	//~ debug ("Button Clicked1");
	switch( Name )
	{
		case "BlockCurTriggerBtn": 
			//~ debug("Trigger PVPCounterWnd");
			BlockCurWnd.ShowWindow();
			//RequestPVPMatchRecord();
			break;
	}
}
defaultproperties
{
}
