class CardExchangeC extends L2UIGFxScript;

function OnRegisterEvent()
{
	RegisterGFxEvent(EV_CardRewardStart);
	RegisterGFxEvent(EV_CardListProperty);
	RegisterGFxEvent(EV_CardProperty);
}

function OnLoad()
{	
	AddState( "GAMINGSTATE" ) ;	
	SetContainerWindow(WINDOWTYPE_DECO_NORMAL, 3129);
}
defaultproperties
{
}
