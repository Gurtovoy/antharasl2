class KillPointRankTrigger extends UIScript;

/**
 * CT3 버전에서 사용 하지 않음.
 */

var WindowHandle Me;
var WindowHandle KillPointRankWnd;

function OnRegisterEvent()
{
	//RegisterEvent( EV_CrataeCubeRecordBegin );
	//RegisterEvent( EV_CrataeCubeRecordMyItem );
	//RegisterEvent( EV_CrataeCubeRecordRetire );
}


function OnLoad()
{
	if(CREATE_ON_DEMAND==0)
	{
		Me = GetHandle( "KillPointRankTrigger");
		KillPointRankWnd = GetHandle("KillPointRankWnd");
	}
	else
	{
		Me = GetWindowHandle( "KillPointRankTrigger");
		KillPointRankWnd = GetWindowHandle("KillPointRankWnd");
	}
	
	//~ RegisterEvent( EV_CrataeCubeRecordBegin );
	//~ RegisterEvent( EV_CrataeCubeRecordMyItem );
	//~ RegisterEvent( EV_CrataeCubeRecordRetire );
}

function OnEvent(int Event_ID, string param)
{
	local int StatusInt;
	switch(Event_ID)
	{
		case EV_CrataeCubeRecordMyItem:

				Me.ShowWindow();
		break;
		case EV_CrataeCubeRecordBegin:
			ParseInt( param, "Status", StatusInt);
			switch (StatusInt)
			{
				case 0:
					Me.ShowWindow();
				break;
				case 2:
					Me.HideWindow();
				break;
			}
		break;
		case EV_CrataeCubeRecordRetire:
			Me.HideWindow();
		break;
	}
}

function OnClickButton( string Name )
{
	//~ local WindowHandle KillPointRankWnd;
	//~ KillPointRankWnd = GetHandle("KillPointRankWnd");
	if (Name == "KillPointRankTrigger")
	{
		KillPointRankWnd.ShowWindow();
		//~ RequestStartShowCrataeCubeRank();
		RequestStartShowCrataeCubeRank();
	}
}
defaultproperties
{
}
