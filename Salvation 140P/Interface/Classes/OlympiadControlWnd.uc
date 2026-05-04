class OlympiadControlWnd extends UIScript;

var WindowHandle Me;
var ButtonHandle btnRecord;
var ButtonHandle btnGuide;
var ButtonHandle btnOtherGame;
var ButtonHandle btnStop;

//선준 수정(10.04.01) 완료
var WindowHandle OlympiadGuideWnd;

function OnLoad()
{
	Initialize();
	Load();
}

function Initialize()
{
	Me = GetWindowHandle( "OlympiadControlWnd" );
	btnRecord = GetButtonHandle( "OlympiadControlWnd.btnRecord" );
	btnGuide = GetButtonHandle( "OlympiadControlWnd.btnGuide" );
	btnOtherGame = GetButtonHandle( "OlympiadControlWnd.btnOtherGame" );
	btnStop = GetButtonHandle( "OlympiadControlWnd.btnStop" );

	//선준 수정(10.04.01) 완료
	OlympiadGuideWnd = GetWindowHandle( "OlympiadGuideWnd" );
}

function Load()
{
}

function OnRegisterEvent()
{
	//선준 수정(10.04.01) 완료
	RegisterEvent( EV_ReplayRecStarted );
	RegisterEvent( EV_ReplayRecEnded );
}

//선준 수정(10.04.01) 완료
function OnEvent( int Event_ID, String Param )
{
	switch(Event_ID)
	{

	case EV_ReplayRecStarted:
		btnRecord.SetButtonName( 2301 );
		//debug("EV_ReplayRecStart~~~~");
		break;

	case EV_ReplayRecEnded:
		btnRecord.SetButtonName( 2300 );
		//debug("EV_ReplayRecEnded~~~~");
		break;
	}
}


function OnClickButton(string strID)
{
	local OlympiadGuideWnd script;
	switch (strID)
	{
		case "btnStop":
			class'OlympiadAPI'.static.RequestOlympiadObserverEnd();
			break;
		case "btnOtherGame":
			class'OlympiadAPI'.static.RequestOlympiadMatchList();
			break;

			//선준 수정(10.04.01) 완료
		case "btnRecord":
			ToggleReplayRec();
			break;
		case "btnGuide":
			script = OlympiadGuideWnd(GetScript("OlympiadGuideWnd"));
			script.OpenCloseGuide();
			break;
	}
}
defaultproperties
{
}
