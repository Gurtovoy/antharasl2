class TutorialBtnWnd extends UICommonAPI;

/**
 * 알림아이콘 통합으로 사용되지 않음.
 */

function OnRegisterEvent()
{
	//RegisterEvent( EV_ArriveNewTutorialQuestion );
}
	
function OnLoad()
{
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();
}

function OnEvent( int Event_ID, string param )
{
	local int iEffectNumber;

	ParseInt(param, "QuestionID", iEffectNumber);

	switch( Event_ID )
	{
	case EV_ArriveNewTutorialQuestion :
		ShowWindowWithFocus("TutorialBtnWnd");
		class'UIAPI_EFFECTBUTTON'.static.BeginEffect("TutorialBtnWnd.btnTutorial", iEffectNumber);
		break;
	}
}

function OnClickButton(string strID)
{
	switch(strID)
	{
	case "btnTutorial" :
		HideWindow("TutorialBtnWnd");
		break;
	}
}
defaultproperties
{
}
