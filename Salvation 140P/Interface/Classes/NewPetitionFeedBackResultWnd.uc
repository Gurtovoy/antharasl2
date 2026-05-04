class NewPetitionFeedBackResultWnd extends UICommonAPI;

var WindowHandle Me;
var TextBoxHandle m_hResultTextBoxHandle;

function OnRegisterEvent()
{
}

function OnLoad()
{
	Me = GetWindowHandle("NewPetitionFeedBackResultWnd");
	m_hResultTextBoxHandle = GetTextBoxHandle("NewPetitionFeedBackResultWnd.PetitionFeedBackResultText");

	Me.ShowWindow();
	Me.SetFocus();
	m_hResultTextBoxHandle.SetText(GetSystemMessage(3004));
}

function OnShow()
{
	//Me.ShowWindow();
	Me.SetFocus();
}

function OnEvent(int a_EventID, string a_Param)
{
}

function OnClickButton( String a_ControlID )
{
	switch( a_ControlID )
	{
	case "OKButton":
		OnClickOKButton();
		break;
	}
}

function Clear()
{
}

function OnClickOKButton()
{
	class'UIAPI_WINDOW'.static.ShowWindow("NewPetitionFeedBackWnd_2nd");

	HideWindow("NewPetitionFeedBackResultWnd");
}
defaultproperties
{
}
