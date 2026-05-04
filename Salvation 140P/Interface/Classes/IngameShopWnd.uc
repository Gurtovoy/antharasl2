//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : 인게임샾 - SCALEFORM UI
//
//------------------------------------------------------------------------------------------------------------------------
class InGameShopWnd extends L2UIGFxScript;

function OnRegisterEvent()
{
	// 10070
	registerGfxEvent( EV_VipProductItemStart );
	// 10071
	registerGfxEvent( EV_VipProductItem );
	// 10072
	registerGfxEvent( EV_VipProductItemEnd );
	// 10060
	registerGfxEvent( EV_VIPInfo );	
	// 9015
	registerGfxEvent( EV_BR_CashShopNewIconAnim );	

	// 9060
	registerGfxEvent( EV_BR_RESULT_BUY_PRODUCT );	

	// 10080
	registerGfxEvent( EV_VipLuckyGameInfo ); 

	// 9050
	registerGfxEvent( EV_BR_SETGAMEPOINT );		

	// 2610 
	RegisterGFxEventForLoaded(EV_InventoryUpdateItem);        
	
}

function OnLoad()
{	
	AddState( "GAMINGSTATE" );
	SetContainerWindow(WINDOWTYPE_DECO_NORMAL, 5001);	
}
defaultproperties
{
}
