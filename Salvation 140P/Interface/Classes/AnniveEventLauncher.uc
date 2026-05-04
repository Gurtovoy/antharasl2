class AnniveEventLauncher extends L2UIGFxScript;

function OnRegisterEvent()
{
	RegisterGFxEvent(EV_BR_10thAnniBannerShow);
	//RegisterGFxEvent(EV_BR_13thAnniBannerShow);
}

function OnLoad()
{
	registerState( "AnniveEventLauncher", "GamingState" );
	// 어느 콘테이너에 넣을 건지 선언
	SetContainerHUD(WINDOWTYPE_NOBG_NODRAG, 0);
	AddState("GAMINGSTATE");
	NotUseESC();
	setHUD();
	//setDefaultShow(true);
	SetHavingFocus( false );
	//SetAnchor("", EAnchorPointType.ANCHORPOINT_TopRight, EAnchorPointType.ANCHORPOINT_TopRight, 348 , 253);
}



function onCallUCFunction( string functionName, string param )
{
	
}
defaultproperties
{
}
