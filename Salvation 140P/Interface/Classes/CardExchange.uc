class CardExchange extends L2UIGFxScript;

function OnRegisterEvent()
{
	RegisterGFxEvent(EV_CardRewardStart);
	RegisterGFxEvent(EV_CardListProperty);
	RegisterGFxEvent(EV_CardProperty);
}

function OnLoad()
{	
	registerState( "CardExchange", "GamingState" );	
	// 어느 콘테이너에 넣을 건지 선언
	SetContainerWindow(WINDOWTYPE_DECO_NORMAL, 0);
	//setDefaultShow(true);
}

function onCallUCFunction( string functionName, string param )
{	
	//switch ( functionName ) 
}
defaultproperties
{
}
