class AlchemyOpener extends L2UIGFxScript;

function OnLoad()
{
	
	registerState( "AlchemyOpener", "GamingState" );
	SetContainerWindow( WINDOWTYPE_DECO_NORMAL, 3257);
	AddState("GAMINGSTATE");

	SetAnchor("", EAnchorPointType.ANCHORPOINT_CenterCenter, EAnchorPointType.ANCHORPOINT_CenterCenter, 0 , 0);

	//함수 실행 시 onStateOut, onStateIn 함수를 invoke 로 받음 
	//SetStateChangeNotification();

	//선언하면 처음 부터 보여지고 시작 함
	//SetDefaultShow(true);

	//SetAnchor("", EAnchorPointType.ANCHORPOINT_BottomRight, EAnchorPointType.ANCHORPOINT_TopLeft, 0 , 0);		
}
defaultproperties
{
}
