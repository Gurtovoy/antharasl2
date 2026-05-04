//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : VIPInfoWnd  ( VIP 정보 창 ) - SCALEFORM UI
//
//------------------------------------------------------------------------------------------------------------------------
class VIPInfoWnd extends L2UIGFxScript;

function OnRegisterEvent()
{
	registerGfxEvent(EV_VIPInfo);	
	registerGfxEvent(EV_VIPInfoRemainTime);		
}

function OnLoad()
{	
	AddState( "GAMINGSTATE" );
	SetContainerWindow(WINDOWTYPE_DECO_NORMAL, 5819);	
}
defaultproperties
{
}
