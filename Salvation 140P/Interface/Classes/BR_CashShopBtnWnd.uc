class BR_CashShopBtnWnd extends UICommonAPI;

const	TIMER_ID	=	1410;	
const 	TIMER_DELAY	=	500;	

var WindowHandle Me;
var ButtonHandle BtnShowCashShop;
var WindowHandle Drawer; // by sr

var TextureHandle TexPrime_panel_new;

var array<string> m_UI_prime_panel_new; 
var int m_currentAnim; 
var bool m_newAnim; 
var int m_SubJobClassID;

function OnRegisterEvent()
{
	RegisterEvent( EV_BR_CashShopNewIconAnim );	
	RegisterEvent(EV_ChangedSubjob);

	RegisterEvent(EV_Restart);
}

function OnLoad()
{	
	RegisterState( "BR_CashShopBtnWnd", "TRAININGROOMSTATE" );
	
	InitHandle();	
	Load();
}

function InitHandle()
{
	if (CREATE_ON_DEMAND==0) 
	{
		Me = GetHandle( "BR_CashShopBtnWnd" );
		BtnShowCashShop = ButtonHandle ( GetHandle( "BR_CashShopBtnWnd.BtnShowCashShop" ) );
		TexPrime_panel_new = TextureHandle ( GetHandle( "BR_CashShopBtnWnd.TexNew" ) );
	}
	else 
	{
		Me = GetWindowHandle( "BR_CashShopBtnWnd" );
		BtnShowCashShop = GetButtonHandle ( "BR_CashShopBtnWnd.BtnShowCashShop" );
		TexPrime_panel_new = GetTextureHandle ( "BR_CashShopBtnWnd.TexNew" );
	}
	
	m_UI_prime_panel_new.Length = 2;
	m_UI_prime_panel_new[0] = "BranchSys3.ui.g_ui_prime_button_new_ani1";
	m_UI_prime_panel_new[1] = "BranchSys3.ui.g_ui_prime_button_new_ani2";
	m_currentAnim = 0;
	m_SubJobClassID = 0;
	m_newAnim = false;
	TexPrime_panel_new.HideWindow();
}

function Load()
{
	RequestBR_CashShopNewICon();
}

function OnEvent(int Event_ID, string param)
{
	local int iResult;
	local int bShow;
	bShow = 0;
	GetINIBool("PrimeShop","UsePrimeShop",bShow,"L2.ini");
	
	switch( Event_ID )
	{		
	case EV_BR_CashShopNewIconAnim :
		ParseInt(param, "NewIConAnim", iResult);	
		if( iResult > 0 )
		{
			TexPrime_panel_new.ShowWindow();
			m_newAnim = true;
			PlayAnimation();
		}
		break;
	case EV_ChangedSubjob:
		if(param != "")
		{
			ParseInt(param,"CurrentSubjobClassID",m_SubJobClassID);
			if(!getInstanceL2Util().getIsPrologueGrowType(m_SubJobClassID) && bShow == 1)
			{
				Me.ShowWindow();
			}
		}
		break;
	case EV_Restart:
		m_SubJobClassID = 0;
		break;
	default:
		break;
	}
}

function OnClickButton( string Name )
{
	switch( Name )
	{
	case "BtnShowCashShop":
		OnBtnShowCashShopClick();
		break;
	}
}

function OnBtnShowCashShopClick()
{
	//branch120516
	local string BR_NewCashShop;
					
	BR_NewCashShop = "BR_NewCashShopWnd";
	
	if(IsShowWindow(BR_NewCashShop))
	{
		HideWindow(BR_NewCashShop);
		PlaySound("InterfaceSound.inventory_close_01");
	}
	else
	{
		//ShowWindowWithFocus(BR_NewCashShop);	// 테스트용
		ExecuteEvent(EV_BR_CashShopToggleWindow);
		PlaySound("InterfaceSound.inventory_open_01");
		m_newAnim = false;
		TexPrime_panel_new.HideWindow();
	}
	//end of branch
}

function OnShow()
{
	local int bShow;
	local bool bIsGrow;
	bShow = 0;
	GetINIBool("PrimeShop", "UsePrimeShop", bShow, "L2.ini");
	

	bIsGrow = getInstanceL2Util().checkIsPrologueGrowType(string(self));

	// 발터스 기사단인지 체크해서 아닐때만 쇼~
	if(m_SubJobClassID == 0 && bIsGrow)
	{
		bShow = 0;
	}

	//branch EP1.0 2014-9-17 luciper3 - 클래식은 인게임샵 안보이게 처리한다.
	if(bShow == 0 || getInstanceUIData().getIsClassicServer())
	{
		Me.HideWindow();
	}
		
		//bShow = 0;

	//debug("bShow=" $ bShow);
	//if ( bShow != 0 ) 
	//{
	//	Me.ShowWindow();
	//	//PlayAnimation();
	//} 
	//else 
	//{
	//	Me.HideWindow();		
	//}

	//Me.HideWindow();		
}

function OnTimer(int TimerID)
{
	if( m_newAnim == false )
		return;

	if(TimerID == TIMER_ID)
	{
		if( m_currentAnim == 0 )
		{
			m_currentAnim = 1;
			TexPrime_panel_new.SetTexture(m_UI_prime_panel_new[m_currentAnim]);
		}
		else
		{
			m_currentAnim = 0;
			TexPrime_panel_new.SetTexture(m_UI_prime_panel_new[m_currentAnim]);
		}
	}
}

function PlayAnimation()
{
	if( m_newAnim )
	{
		Me.KillTimer( TIMER_ID );	
		Me.SetTimer(TIMER_ID,TIMER_DELAY);
	}
	else
	{
		Me.KillTimer( TIMER_ID );	
	}
}
defaultproperties
{
}
