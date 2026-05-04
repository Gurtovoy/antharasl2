class MailBtnWnd extends UICommonAPI;

/**
 * 알림아이콘 통합으로 사용되지 않음.
 */

var ButtonHandle btnItemPop;
var int buttonType;

var int IsPeaceZone;		//현재 지역 PeaceZone인가

function OnRegisterEvent()
{
	//RegisterEvent( EV_ArriveNewMail );
	//RegisterEvent( EV_Notice_Post_Arrived );
	//RegisterEvent( EV_SetRadarZoneCode );
}
function OnLoad()
{
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	buttonType = 0;
	Initialize();
}
function Initialize()
{
	if(CREATE_ON_DEMAND==0)
	{
		btnItemPop = ButtonHandle ( GetHandle( "MailBtnWnd.btnMail" ) );
	}
	else
	{
		btnItemPop = GetButtonHandle ("MailBtnWnd.btnMail" );
	}
		
	btnItemPop.SetTooltipCustomType(MakeTooltipSimpleText(GetSystemMessage(3064)));	// 툴팁. 
	IsPeaceZone = 1;
}
function OnEvent( int Event_ID, string param )
{
	local int iEffectNumber;
	local int zonetype;

	ParseInt(param, "IdxMail", iEffectNumber);

	switch( Event_ID )
	{
	case EV_ArriveNewMail :
		ShowWindowWithFocus("MailBtnWnd");
		class'UIAPI_EFFECTBUTTON'.static.BeginEffect("MailBtnWnd.btnMail", iEffectNumber);
		buttonType = 1;
		break;
	case EV_Notice_Post_Arrived:
		ShowWindowWithFocus("MailBtnWnd");
		class'UIAPI_EFFECTBUTTON'.static.BeginEffect("MailBtnWnd.btnMail", iEffectNumber);
		buttonType = 2;
		break;
	case EV_SetRadarZoneCode:
		ParseInt( param, "ZoneCode", zonetype );		
		if (zonetype == 12)
		{
			IsPeaceZone = 1;
		}
		else
		{
			IsPeaceZone = 0;
		}	
		break;
	}
}

function OnClickButton(string strID)
{
	switch(strID)
	{
	case "btnMail" :
		HideWindow("MailBtnWnd");
		if (buttonType == 2 )
		{
			if (IsPeaceZone == 1)
				RequestRequestReceivedPostList();
			else
				AddSystemMessage(3066);
		}
		break;
	}
}
defaultproperties
{
}
