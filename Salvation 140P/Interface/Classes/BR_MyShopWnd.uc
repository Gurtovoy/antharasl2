class BR_MyShopWnd extends UICommonAPI;

const DIALOG_PRODUCT_QUANTITY		= 351;
const DIALOG_CLOSED_SHOP			= 352;
const DIALOG_BASKET_ALL_CLEAR		= 353;
const ITEM_INFO_WIDTH = 256;

var int m_iCurrentHeight;
var DrawItemInfo m_kDrawInfoClear;

const PAGE_MAX			= 5;

var array< ProductInfo >	m_CurrentProductList; //branch120516
var int		m_nCurrentTabPage;
var int 	m_iCurrentTabTotalPage;

var bool	m_bCoinToMoney; //branch 110824
var float	m_fCoinMoneyValue; //branch 110824
var int		m_iCurrentTab;

var WindowHandle Me;

//branch120516
var TabHandle TabCategory;
var array< WindowHandle >	BR_MyShop_Item;
var ButtonHandle BtnClear;

var TextBoxHandle TextViewPageNum;

//캐쉬샵 공통 함수
var BR_CashShopAPI m_CashShopAPI;
//end of branch

function OnRegisterEvent()
{		
	
	RegisterEvent( EV_BR_AddMyShopBasketProductItem );		
	RegisterEvent( EV_BR_DeleteMyShopBasketProductItem );		
	
	RegisterEvent( EV_BR_SetNewList );
			
	RegisterEvent( EV_BR_RecentProductListEnd );		
	RegisterEvent( EV_BR_BasketProductListEnd );			
		
	RegisterEvent( EV_DialogOK );
}

function OnLoad()
{
	RegisterState( "BR_MyShopWnd", "TRAININGROOMSTATE" );
	
	if (CREATE_ON_DEMAND==0)
		OnRegisterEvent();
		
	InitHandle();
	Initialize();	
}

function InitHandle()
{
	if (CREATE_ON_DEMAND==0) {
		Me = GetHandle( "BR_MyShopWnd" );
		//
		BtnClear = ButtonHandle ( GetHandle( "BR_MyShopWnd.BtnClear" ) );
		//branch110706
		TabCategory = TabHandle ( GetHandle( "BR_MyShopWnd.TabCategory" ) );

		//branch120516				
		BR_MyShop_Item.Length = 5;
		BR_MyShop_Item[0] = GetHandle("BR_MyShopWnd.CashItemData_1");
		BR_MyShop_Item[1] = GetHandle("BR_MyShopWnd.CashItemData_2");
		BR_MyShop_Item[2] = GetHandle("BR_MyShopWnd.CashItemData_3");
		BR_MyShop_Item[3] = GetHandle("BR_MyShopWnd.CashItemData_4");
		BR_MyShop_Item[4] = GetHandle("BR_MyShopWnd.CashItemData_5");
		
		TextViewPageNum = TextBoxHandle( GetHandle ( "BR_MyShopWnd.TextViewPageNum" ) );
		
	}
	else {
		Me = GetWindowHandle( "BR_MyShopWnd" );
		
		BtnClear = GetButtonHandle ( "BR_MyShopWnd.BtnClear" );
		
		TabCategory = GetTabHandle ( "BR_MyShopWnd.TabCategory" );
		
		//branch120516				
		BR_MyShop_Item.Length = 5;
		BR_MyShop_Item[0] = GetWindowHandle("BR_MyShopWnd.CashItemData_1");
		BR_MyShop_Item[1] = GetWindowHandle("BR_MyShopWnd.CashItemData_2");
		BR_MyShop_Item[2] = GetWindowHandle("BR_MyShopWnd.CashItemData_3");
		BR_MyShop_Item[3] = GetWindowHandle("BR_MyShopWnd.CashItemData_4");
		BR_MyShop_Item[4] = GetWindowHandle("BR_MyShopWnd.CashItemData_5");
		
		//end of branch
		
		TextViewPageNum = GetTextBoxHandle ( "BR_MyShopWnd.TextViewPageNum" );
	}
}
	
function Initialize()
{
	m_iCurrentTab = 0;
			
	m_bCoinToMoney = IsBr_CashShopCoinToMoney(); //branch 110824
	if( m_bCoinToMoney )
	{
		m_fCoinMoneyValue = GetBr_CashShopCoinToMoneyValue();		
	}
			
	
	m_CurrentProductList.Length = 0; //branch120516
	m_nCurrentTabPage = 0;
	m_iCurrentTabTotalPage = 0;
			
	TabCategory.SetButtonName( 2, "" );	
	TabCategory.SetDisable( 2, true );	
	TabCategory.SetButtonDisableTexture( 2, "L2UI_CT1.tab.Tab_DF_Bg_line" );
			
	m_CashShopAPI = BR_CashShopAPI(GetScript("BR_CashShopAPI"));	
}

function selectedInit()
{
 	m_CashShopAPI.ClearBasketItemList();
 	m_CashShopAPI.ClearRecentList();
 	
 	RequestBR_ProductList(BRCSP_RECENT);	// 최근구매목록		
 	RequestBR_ProductList(BRCSP_BASKET);	 //장바구니 업데이트	
}

function OnEvent(int Event_ID, string param)
{
	local int iResult;
	local int ProductID;
	
	
	switch( Event_ID )
	{
	case EV_BR_AddMyShopBasketProductItem:
		HandleAddBasketProduct(param);
		break;
	case EV_BR_RecentProductListEnd:
		if(m_iCurrentTab == 1)
		{
			OnTabList(m_CashShopAPI.GetRecentProductList(), true);		
		}
		break;
	case EV_BR_BasketProductListEnd:
		if(m_iCurrentTab == 0)
		{
			OnTabList(m_CashShopAPI.GetBasketProductList(), false);		
		}
		break;		
	case EV_BR_SetNewList :
		ParseInt(param, "Option", iResult );
		if (iResult == -1) 
		{
			PrepareProductList(iResult);
		}
		
		break;
	case EV_BR_DeleteMyShopBasketProductItem:
	
		ParseInt(param, "ID", ProductID);	
		RequestBR_DeleteBasketProductInfo( ProductID);		
		m_CashShopAPI.DeleteBasketProductItem(ProductID);
		
		if( m_iCurrentTab == 0 )
		{
			OnTabList(m_CashShopAPI.GetBasketProductList(), false);
		}	
		break;
	case EV_DialogOK:
		//debug("handle dialog ok");
		HandleDialogOK();
		break;
	}
}

function OnClickButtonWithHandle( ButtonHandle a_ButtonHandle )
{
	local int SelectedProductID;
	local string btnName;
		
	if( a_ButtonHandle == None )
		return;
	
	if( m_CashShopAPI.GetOpenBuyWnd() )
		return;
	
	btnName = a_ButtonHandle.GetWindowName();
	SelectedProductID = a_ButtonHandle.GetButtonValue();
	
	if( SelectedProductID < 0 ) //branch120703
		return;
		
	switch (btnName)
	{	
	case "BtnBuy":		
		debug("OnClickButtonWithHandle BtnBuy" $ SelectedProductID );
		m_CashShopAPI.OnBtnBuyClick(SelectedProductID);		
		break;				
	case "BtnPresent":	
		debug("OnClickButtonWithHandle BtnPresent" $ SelectedProductID);	
		m_CashShopAPI.OnBtnPresentClick(SelectedProductID);
		break;	
	case "BtnDelete":	
		debug("OnClickButtonWithHandle BtnDelete" $ SelectedProductID);	
		OnBtnDeleteClick(SelectedProductID);
		break;	
	}		
}

function OnClickButton( string Name )
{
	switch( Name )
	{
	//	
	case "BtnClear":
		OnBtnClear();
		debug("BtnClear");
		break;						
	case "BtnViewPreEnd":
		if( m_nCurrentTabPage > 1 )
		{
			m_nCurrentTabPage = 1;	
			SetViewProductList();		
		}
		debug("BtnViewPreEnd");
		break;
	case "BtnViewPre":
		if( m_nCurrentTabPage > 1 )
		{
			m_nCurrentTabPage = m_nCurrentTabPage - 1;	
			SetViewProductList();	
		}
		debug("BtnViewPre");
		break;
	case "BtnViewNext":
		if( m_nCurrentTabPage < m_iCurrentTabTotalPage )
		{
			m_nCurrentTabPage = m_nCurrentTabPage + 1;	
			SetViewProductList();				
		}
		debug("BtnViewNext");	
		break;
	case "BtnViewNextEnd":		
		if( m_nCurrentTabPage != m_iCurrentTabTotalPage)
		{
			m_nCurrentTabPage = m_iCurrentTabTotalPage;		
			SetViewProductList();
		}			
		debug("BtnViewNextEnd");
		break;
	case "TabCategory0":	//장바구니
		OnTabList(m_CashShopAPI.GetBasketProductList(), false);			
		break;				
	case "TabCategory1":	// 최근 구매 탭		
		OnTabList(m_CashShopAPI.GetRecentProductList(), true);					
		break;
	default :		
		break;
	}
}

function ClearItemList()
{		
	local int i;
						
	m_CurrentProductList.Length = 0;
	
	for( i = 0; i < 5 ;i++)
	{
		BR_MyShop_Item[i].HideWindow();
	}
}

function HandleAddBasketProduct(string param)
{
	local int ProductID;	
		
	ParseInt(param, "ID", ProductID);
	
	m_CashShopAPI.AddMyShopBasketProductItem(ProductID);	
			
	RequestBR_AddBasketProductInfo(ProductID);
			
	if( Me.IsShowWindow() )
	{
		if( m_iCurrentTab == 0 )
		{
			OnTabList(m_CashShopAPI.GetBasketProductList(), false);
		}
	}	
	
}

function HandleDialogOK()
{
	local int id, num;
	local WindowHandle m_BuyWnd;	// 인벤토리 핸들 선언.
	
	if( DialogIsMine() ) {
		id = DialogGetID();
		num = int( DialogGetString() );
		if( id == DIALOG_BASKET_ALL_CLEAR )
		{
			if( m_iCurrentTab == 0 )
			{
				RequestBR_DeleteBasketProductInfo(0);	//장바구니					
				m_CashShopAPI.ClearBasketItemList();				
				OnTabList(m_CashShopAPI.GetBasketProductList(), false);
				ExecuteEvent(EV_BR_DeleteAllBasketProductItem);
				
			}			
		}
		else if ( id == DIALOG_CLOSED_SHOP ) {
			m_BuyWnd = GetWindowHandle( "BR_BuyingWnd" );
			if ( m_BuyWnd.IsShowWindow() )
			{
				m_BuyWnd.HideWindow();
			}
			if( m_hOwnerWnd.IsShowWindow() )
			{
				m_hOwnerWnd.HideWindow();
			}
		}
	}
}

function PrepareProductList(int iOption)	// 올바를 리스트를 받으면 초기화하고, -1 인 경우 상점 불가
{
	local WindowHandle m_NewBuyWnd;

	ClearItemList();
		
	if (iOption==-1) 
	{
		m_NewBuyWnd = GetWindowHandle( "BR_NewBuyingWnd" );
		if( m_hOwnerWnd.IsShowWindow() || m_NewBuyWnd.IsShowWindow() ) {
			DialogSetID( DIALOG_CLOSED_SHOP );
			DialogSetDefaultOK();
			DialogShow( DialogModalType_Modal, DialogType_Warning, MakeFullSystemMsg( GetSystemMessage(1474), GetSystemString(5021) ), string(Self) ); //branch 110824
		}
	}
}

function OnTabList(array< ProductInfo >	productList, bool desc)
{
	local int currentindex;
	local int i;
	local int TotalPage;

	ClearItemList();
	m_iCurrentTab = TabCategory.GetTopIndex();
	
	debug("OnTabList" $ productList.Length);	
		
// 	if( desc )
// 	{
// 		for (i= 0 ; i < productList.Length ; i++)
// 		{
// 			m_CurrentProductList.Length = m_CurrentProductList.Length + 1;
// 			currentindex = m_CurrentProductList.Length - 1;	
// 			m_CurrentProductList[currentindex] = productList[i];	
// 		}
// 	}
// 	else
// 	{
// 		for (i=productList.Length - 1 ; i >= 0 ; i--)
// 		{
// 			m_CurrentProductList.Length = m_CurrentProductList.Length + 1;
// 			currentindex = m_CurrentProductList.Length - 1;	
// 			m_CurrentProductList[currentindex] = productList[i];	
// 		}
// 	}	

	for (i= 0 ; i < productList.Length ; i++)
	{
		m_CurrentProductList.Length = m_CurrentProductList.Length + 1;
		currentindex = m_CurrentProductList.Length - 1;	
		m_CurrentProductList[currentindex] = productList[i];	
	}
	
	debug("OnTabList CurrentProductList" $ m_CurrentProductList.Length);	
			
	if(productList.Length <= 0)
	{
		m_nCurrentTabPage = 1;
		m_iCurrentTabTotalPage = 1;
	}
	else
	{
		TotalPage = m_CurrentProductList.Length % PAGE_MAX;
		if( TotalPage > 0 )
		{
			
			m_iCurrentTabTotalPage = (m_CurrentProductList.Length / PAGE_MAX) + 1;
		}
		else
		{
			m_iCurrentTabTotalPage = (m_CurrentProductList.Length / PAGE_MAX);	
		}	
		m_nCurrentTabPage = 1;	
	}
	
	//최근구매면..
 	if( m_iCurrentTab == 1 ) 
 	{
 		BtnClear.HideWindow();
 	}
 	else
 	{
 		BtnClear.ShowWindow();
 	}
					
	SetViewProductList();	
}

function SetViewProductList()
{
	local int i;
	local int j;	
	local ProductInfo info;
	local bool visableDelete;
	
	//최근구매는 삭제가 안됨
	if( m_iCurrentTab == 1 )
	{
		visableDelete = false;		
	}
	else
	{
		visableDelete = true;		
	}
	
	debug("OnTabList m_iCurrentTab" $ m_iCurrentTab);	
	
	j = 0;
	for (i=(m_nCurrentTabPage - 1) * PAGE_MAX; i < m_nCurrentTabPage * PAGE_MAX ; i++)
	{		
		BR_MyShop_Item[j].HideWindow();
		
		if( i < m_CurrentProductList.Length )
		{
			info = m_CurrentProductList[i];	
			m_CashShopAPI.SetViewProductWindow(BR_MyShop_Item[j],info,true, visableDelete);		
			BR_MyShop_Item[j].ShowWindow();
		}		
		j++;
	}		
	
	TextViewPageNum.SetText("" $ m_nCurrentTabPage $ "/" $ m_iCurrentTabTotalPage);
}


function OnBtnClear()
{
	if( m_CashShopAPI.GetOpenBuyWnd() )
		return;
		
	DialogSetID( DIALOG_BASKET_ALL_CLEAR );
	DialogSetDefaultOK();
	DialogShow( DialogModalType_Modal, DialogType_Warning, GetSystemMessage(6115), string(Self) ); //branch 110824
}

function OnBtnDeleteClick(int ProductID)
{
	local string strParam;
	
	m_CashShopAPI.DeleteBasketProductItem(ProductID);
	RequestBR_DeleteBasketProductInfo( ProductID);		
		
	ParamAdd(strParam, "ID", string(ProductID));
	ExecuteEvent(EV_BR_DeleteCashShopBasketProductItem, strParam);		
			
	if(m_iCurrentTab == 0)
	{		
		if( Me.IsShowWindow() )
		{
			OnTabList(m_CashShopAPI.GetBasketProductList(), false);
		}					
	}		
}

//end of branch
defaultproperties
{
}
