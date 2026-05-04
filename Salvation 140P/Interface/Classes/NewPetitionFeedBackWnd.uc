class NewPetitionFeedBackWnd extends UICommonAPI;

const MAX_FEEDBACK_STRING_LENGTH = 512;

const FEEBACKRATE_VeryGood = 0;
const FEEBACKRATE_Good = 1;
const FEEBACKRATE_Normal = 2;
const FEEBACKRATE_Bad = 3;
const FEEBACKRATE_VeryBad = 4;

var WindowHandle Me;

function OnRegisterEvent()
{
}

function OnLoad()
{
	Me = GetWindowHandle("NewPetitionFeedBackWnd");

	Me.ShowWindow();
	Me.SetFocus();
}

function OnShow()
{
	Me.ShowWindow();
	Me.SetFocus();
}

function OnHide()
{
	ExecuteEvent( EV_EnablePetitionFeedback, "Enable=0" );
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
	local String SelectedRadioButtonName;
	local int FeedbackRate;
	local String FeedbackMessage;

	local NewPetitionFeedBackWnd_2nd newPetitionFeedBackWnd_2ndScript;

	FeedbackMessage = "";

	newPetitionFeedBackWnd_2ndScript = NewPetitionFeedBackWnd_2nd(GetScript("NewPetitionFeedBackWnd_2nd"));

	SelectedRadioButtonName = class'UIAPI_WINDOW'.static.GetSelectedRadioButtonName( "NewPetitionFeedBackWnd", 1 );
	switch( SelectedRadioButtonName )
	{
	case "VeryGood":
		FeedbackRate = FEEBACKRATE_VeryGood;
		break;
	case "Good":
		FeedbackRate = FEEBACKRATE_Good;
		break;
	case "Normal":
		FeedbackRate = FEEBACKRATE_Normal;
		break;
	case "Bad":
		FeedbackRate = FEEBACKRATE_Bad;
		break;
	case "VeryBad":
		FeedbackRate = FEEBACKRATE_VeryBad;
		break;
	}

	if(FeedBackRate == FEEBACKRATE_Normal || FeedBackRate == FEEBACKRATE_Bad || FeedBackRate == FEEBACKRATE_VeryBad)
	{
		class'UIAPI_WINDOW'.static.ShowWindow("NewPetitionFeedBackResultWnd");
		newPetitionFeedBackWnd_2ndScript.SetSelectedRadioButton(FeedbackRate);
	}
	else
	{
		class'PetitionAPI'.static.RequestPetitionFeedBack(FeedbackRate, FeedbackMessage);
	}

	HideWindow("NewPetitionFeedBackWnd");
}


/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnKeyDown( WindowHandle a_WindowHandle, EInputKey Key )
{
	if( Key == IK_Escape )
	{
		PlayConsoleSound(IFST_WINDOW_CLOSE);
		GetWindowHandle( "NewPetitionFeedBackWnd" ).HideWindow();
	}
}
defaultproperties
{
}
