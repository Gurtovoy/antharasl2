class UserAlertMessage extends L2UIGFxScript;

function OnRegisterEvent()
{
	//RegisterGFxEvent(6110); //6110
	RegisterGFxEvent(EV_ExtraWorldChattingCnt); //6110
	//RegisterEvent(EV_StateChanged); 
	RegisterGFxEvent(EV_ScenePlayStart);
	//RegisterEvent(EV_ScenePlay);
}

function OnLoad()
{	
	registerState( "UserAlertMessage", "GamingState" );	
	// 어느 콘테이너에 넣을 건지 선언
	SetContainerHUD(WINDOWTYPE_NONE, 0);
	AddState("GAMINGSTATE");
	AddState( "ARENABATTLESTATE" );
	AddState( "ARENAGAMINGSTATE" );

	SetHavingFocus(false);
	//setDefaultShow(true);
	SetAnchor("", EAnchorPointType.ANCHORPOINT_BottomRight, EAnchorPointType.ANCHORPOINT_TopLeft, 0 , 0);
}
defaultproperties
{
}
