//아데나 분배 창
class AdenaDistributionResultWnd extends L2UIGFxScript;

function OnRegisterEvent()
{	
	//아데나 업데이트를 받기 위한 
	RegisterGFxEvent( EV_DivideAdenaDone ); //9710
}

function OnLoad()
{	
	registerState( "AdenaDistributionResultWnd", "GamingState" );	
	SetContainerWindow( WINDOWTYPE_DECO_NORMAL, 0 );
	SetAnchor("", EAnchorPointType.ANCHORPOINT_CenterCenter, EAnchorPointType.ANCHORPOINT_CenterCenter, 0 , 0);	
}
defaultproperties
{
}
