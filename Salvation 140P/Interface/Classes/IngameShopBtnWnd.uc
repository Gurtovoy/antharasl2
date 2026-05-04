//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : 인게임샾 오프너 - SCALEFORM UI
//
//------------------------------------------------------------------------------------------------------------------------

class IngameShopBtnWnd extends L2UIGFxScript;

function OnRegisterEvent()
{
	RegisterGFxEvent( EV_BR_CashShopNewIconAnim );	
	RegisterGFxEvent( EV_VipInfo );		
	RegisterEvent( EV_VipInfo );		

	RegisterEvent( EV_StateChanged );

}

function OnLoad()
{		
	SetContainerWindow ( WINDOWTYPE_SIMPLE_DRAG, 0 );
	AddState( "GAMINGSTATE");
	SetHavingFocus( false );
	//setDefaultShow(true) ;
	//SetAnchor("", EAnchorPointType.ANCHORPOINT_CenterRight, EAnchorPointType.ANCHORPOINT_CenterRight, 0 , 0);
}


function OnEvent ( int Event_ID, string param)
{
	switch ( Event_ID ) 
	{
		case EV_StateChanged:
		if (param == "GAMINGSTATE")
		{
			checkNShowWindow();	
		}	
	}
}

function checkNShowWindow () 
{	
	local int bIsClassicShow;
	
	if ( ! GetINIBool("PrimeShop", "UseClassicPrimeShop", bIsClassicShow, "L2.ini") )  bIsClassicShow = 0;
	//GetINIBool("PrimeShop", "UseClassicPrimeShop", bIsClassShow, "L2.ini");
	//클래식 서버일 경우에만 보여지게 한다.
//	Debug ( "IngameShopBtnWnd UseClassicPrimeShop" @ GetINIBool("PrimeShop", "UseClassicPrimeShop", bIsClassicShow, "L2.ini") @ bIsClassicShow @  getInstanceUIData().getIsClassicServer()   );
	if( bIsClassicShow == 1 && getInstanceUIData().getIsClassicServer()  ) ShowWindow("IngameShopBtnWnd");
	else HideWindow( "IngameShopBtnWnd" );
}

//function OnClickButton( string Name )
//{
//	switch( Name )
//	{
//	case "BtnShowCashShop":
//		OnBtnShowCashShopClick();
//		break;
//	}
//}

//function OnBtnShowCashShopClick()
//{
//	//branch120516
//	local string BR_NewCashShop;
					
//	BR_NewCashShop = "InGameShopWnd";
	
//	if(IsShowWindow(BR_NewCashShop))
//	{
//		HideWindow(BR_NewCashShop);
//		PlaySound("InterfaceSound.inventory_close_01");
//	}
//	else
//	{
//		//ShowWindowWithFocus(BR_NewCashShop);	// 테스트용
//		ShowWindowWithFocus(BR_NewCashShop);	// 테스트용
//		//ExecuteEvent(EV_BR_CashShopToggleWindow);
//		PlaySound("InterfaceSound.inventory_open_01");
//		m_newAnim = false;
//		TexPrime_panel_new.HideWindow();
//	}
//	//end of branch
//}

//function OnShow()
//{
//	local int bShow;
//	local int bIsClassShow;
//	bShow = 0;
//	bIsClassShow = 0;
//	GetINIBool("PrimeShop", "UsePrimeShop", bShow, "L2.ini");
//	GetINIBool("PrimeShop", "UseClassicPrimeShop", bIsClassShow, "L2.ini");
	
//	//branch EP1.0 2014-9-17 luciper3 - 클래식은 인게임샵 안보이게 처리한다.
//	if( bShow == 1 && getInstanceUIData().getIsClassicServer() == true && bIsClassShow == 0 )
//		bShow = 0;

//	//debug("bShow=" $ bShow);
//	if ( bShow != 0 ) 
//	{
//		Me.ShowWindow();
//		//PlayAnimation();
//	} 
//	else 
//	{
//		Me.HideWindow();		
//	}
//}
defaultproperties
{
}
