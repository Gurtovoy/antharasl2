class AnniveEvent extends L2UIGFxScript;

function OnRegisterEvent()
{	
	RegisterGFxEvent(EV_CardRewardStart);
	RegisterGFxEvent(EV_CardListProperty);
	RegisterGFxEvent(EV_CardProperty);
	RegisterGFxEvent(EV_EventAttendanceInfo); //6000
}

function OnLoad()
{	
	//registerState( "AnniveEvent", "GamingState" );
	// 어느 콘테이너에 넣을 건지 선언
	//SetContainer( "ContainerWindow" );
	
	SetContainerWindow(WINDOWTYPE_DECO_NORMAL, 3208);
	AddState("GAMINGSTATE");
	
	//setDefaultShow(true);
	SetAnchor("", EAnchorPointType.ANCHORPOINT_CenterCenter, EAnchorPointType.ANCHORPOINT_CenterCenter, 0 , 0);
}
defaultproperties
{
}
