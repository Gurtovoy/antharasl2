/***
 *
 *   Ç÷¸Í Ã¢¼³, Ç÷¸Í ¸®´º¾ó 
 * 
 **/
class PledgeCreateWnd extends UICommonAPI;

var WindowHandle Me;

var EditBoxHandle PledgeNameInput_Edit;
var ButtonHandle PledgeCreateBtn_Button;

function OnRegisterEvent()
{
	RegisterEvent(EV_PledgeCreateShow);
}

function OnLoad()
{
	SetClosingOnESC();
	Initialize();
}

function Initialize()
{
	Me = GetWindowHandle( "PledgeCreateWnd" );
	PledgeNameInput_Edit   = GetEditBoxHandle( "PledgeCreateWnd.PledgeNameInput_Edit" );
	PledgeCreateBtn_Button = GetButtonHandle( "PledgeCreateWnd.PledgeCreateBtn_Button" );

	GetTextBoxHandle("PledgeCreateWnd.CreateConditionTitle_text").SetText(GetSystemString(3763) $ " : " $ GetSystemString(2381) $ "10 " $ GetSystemString(3692));
}

function OnShow()
{
	PledgeNameInput_Edit.SetString("");
	PledgeNameInput_Edit.SetFocus();
}

function OnEvent(int Event_ID, String param)
{
	//debug("debug@" @ Event_ID);
	if (Event_ID == EV_PledgeCreateShow)
	{
		Me.ShowWindow();
	}
}

function OnClickButton( string Name )
{
	switch( Name )
	{
		case "PledgeCreateBtn_Button":
			OnPledgeCreateBtn_ButtonClick();
			break;

		case "WndBTNHelp_Button":
			ExecuteEvent(EV_ShowHelp, "147");
			break;
	}
}

function OnPledgeCreateBtn_ButtonClick()
{
	local string clanName;
	
	clanName = PledgeNameInput_Edit.GetString();

	if (clanName != "") 
	{
		RequestCreatePledge(clanName);
		Me.HideWindow();
	}
}


/**
 * À©µµ¿ì ESC Å°·Î ´Ý±â Ã³¸® 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( getCurrentWindowName(string(Self))).HideWindow();
}
defaultproperties
{
}
