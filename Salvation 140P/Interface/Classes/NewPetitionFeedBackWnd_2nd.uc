class NewPetitionFeedBackWnd_2nd extends UICommonAPI;

const MAX_FEEDBACK_STRING_LENGTH = 512;

var MultiEditBoxHandle m_hFeedbackMsgBox;
var int m_selectedRadioButton;

var WindowHandle Me;

function OnRegisterEvent()
{
}

function OnLoad()
{
	OnRegisterEvent();

	m_hFeedbackMsgBox = GetMultiEditBoxHandle("NewPetitionFeedBackWnd_2nd.MultiEdit");
	m_selectedRadioButton = 0;

	Me = GetWindowHandle("NewPetitionFeedBackWnd_2nd");
}

function OnShow()
{
	Me.ShowWindow();
	Me.SetFocus();
}

function OnHide()
{
	Clear();
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
	m_hFeedbackMsgBox.SetString("");
}

function OnClickOKButton()
{
	local String SelectedRadioButtonName;
	local String SelectedRadioButtonContents;
	local String FeedbackMessage;

	SelectedRadioButtonName = class'UIAPI_WINDOW'.static.GetSelectedRadioButtonName( "NewPetitionFeedBackWnd_2nd", 1 );
	switch( SelectedRadioButtonName )
	{
	case "Unkind":
		SelectedRadioButtonContents = GetSystemString(2025);		
		break;
	case "Inaccurate":
		SelectedRadioButtonContents = GetSystemString(2026);
		break;
	case "LateAnswer":
		SelectedRadioButtonContents = GetSystemString(2027);
		break;
	}

	FeedbackMessage = class'UIAPI_MULTIEDITBOX'.static.GetString("NewPetitionFeedBackWnd_2nd.MultiEdit");

	FeedbackMessage = SelectedRadioButtonContents $ FeedbackMessage;

	if( Len( FeedbackMessage ) > MAX_FEEDBACK_STRING_LENGTH )
		AddSystemMessageString(FeedbackMessage);

	class'PetitionAPI'.static.RequestPetitionFeedBack(m_selectedRadioButton, FeedbackMessage);

	m_hFeedbackMsgBox.SetString("");
	HideWindow("NewPetitionFeedBackWnd_2nd");
}

function SetSelectedRadioButton(int select)
{
	m_selectedRadioButton = select;
}
defaultproperties
{
}
