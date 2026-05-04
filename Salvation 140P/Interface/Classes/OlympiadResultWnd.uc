class OlympiadResultWnd extends L2UIGFxScript;

function OnRegisterEvent()
{
	//registerEvent(EV_ReceiveOlympiadResult);
	RegisterGFxEvent(EV_ReceiveOlympiadResult);
}

function OnLoad()
{		
	//해당 함수는 
	SetClosingOnESC();

	registerState( "OlympiadResultWnd", "GamingState" );	

	// 어느 콘테이너에 넣을 건지 선언
	SetContainerWindow( WINDOWTYPE_DECO_NORMAL, 0 ); 

	//함수 실행 시 onStateOut, onStateIn 함수를 invoke 로 받음 
	//SetStateChangeNotification();

	//선언하면 처음 부터 보여지고 시작 함
	//SetDefaultShow(true);

	//SetAnchor("", EAnchorPointType.ANCHORPOINT_CenterCenter, EAnchorPointType.ANCHORPOINT_CenterCenter, 0 , 0);		
}
defaultproperties
{
}
