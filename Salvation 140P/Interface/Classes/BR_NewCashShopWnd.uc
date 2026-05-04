class BR_NewCashShopWnd extends UICommonAPI;

const	TIMER_EVENT_ID					=	1410;	
const 	TIMER_EVENT_DELAY				=	10000;	

const	TIMER_SCROLL_ID					=	1411;	
const 	TIMER_SCROLL_DELAY				=	100;	

const DIALOG_CLOSED_SHOP			= 352;
const DIALOG_MYSHOP_BASKET			= 353;

const FEE_OFFSET_Y_EQUIP = -18;
const ITEM_INFO_LEFT_MARGIN = 10;
const ITEM_INFO_BLANK_HEIGHT = 10;

const PAGE_MAX			= 10;

const TAB_MASK = 0;
const TAB_CATEGORY = 1;
const TAB_RECENT = 2;

const PRODUCT_TAB_ADVERTISING = 0x00000001;
const PRODUCT_TAB_RECOMMEND = 0x00000002;
const PRODUCT_TAB_POPULAR = 0x00000004;

var DrawItemInfo m_kDrawInfoClear;

var bool m_bInitMainRand; //branch120516
var bool m_bInitHandle; 
var bool m_bSetFocusChange; 

struct ViewProductInfo
{
	var int 	iCategory;
	var int		iShowTab;
	var int		iTabType;
	var string 	strTitleName;
};
var array< ViewProductInfo >	m_ViewProductInfo;

var array< int >	m_CurrentProductList; //branch120516
var int		m_nCurrentTabPage;
var int 	m_iCurrentTabTotalPage;

var array< int >	m_MainGoodProductList; //branch120516
var int		m_nMainGoodTabPage;
var int 	m_iMainGoodTabTotalPage;
var array< int >	m_MainStarProductList; //branch120516
var int		m_nMainStarTabPage;
var int 	m_iMainStarTabTotalPage;
var array< int >	m_EventProductList; //branch120516
var int		m_nMainEventTabPage;

var int		m_iCurrentTab;
var int		m_iAllItemTab; //branch 110824
var bool	m_bInConfirm;
var bool	m_bSortDesc;
var bool	m_bCoinToMoney; //branch 110824
var float	m_fCoinMoneyValue; //branch 110824
var bool	m_bSearch;
var bool	m_bInitOpen;
var bool	m_bMainDisable;
var int		m_scrollheight;

//캐쉬샵 공통 함수
var BR_CashShopAPI m_CashShopAPI;

enum EPrItemSortType
{
	PR_ITEM_INDEX,
	PR_ITEM_PRICE,
	PR_ITEM_NAME,	
};

var WindowHandle Me;
var EditBoxHandle EditItemSearch;
var ButtonHandle BtnItemSearch;
var ButtonHandle BtnItemIndexSort;
var ButtonHandle BtnItemPointSort;
var ButtonHandle BtnItemNameSort;

var TabHandle TabCategory;

var ButtonHandle BtnCashCharge;
var TextBoxHandle TextCurrentCash;
var TextureHandle TexCategoryUpper;
var WindowHandle ScrollItemInfo;

var WindowHandle Drawer; // by sr

//branch120516
var WindowHandle BR_MainCashShopTab;
var WindowHandle BR_ViewCashShopTab;
var WindowHandle BR_MainCashShopTab_Main;
var array< WindowHandle >	BR_MainGoodCashShopTab_Item;
var array< WindowHandle >	BR_MainStarCashShopTab_Item;
var array< WindowHandle >	BR_ViewCashShopTab_Item;

var TextBoxHandle TextViewPageNum;
var TextBoxHandle EventPageNum;
var TextBoxHandle GoodPageNum;
var TextBoxHandle StarPageNum;

var WindowHandle  BR_MyShopWnd;
var bool bOpenMyShopReceiverWnd;
//end of branch

function OnRegisterEvent()
{
	RegisterEvent( EV_BR_CashShopToggleWindow );		
	RegisterEvent( EV_BR_ProductListEnd );	
	RegisterEvent( EV_BR_BasketProductListEnd );	
	
	RegisterEvent( EV_BR_SETGAMEPOINT );
	RegisterEvent( EV_BR_SETEVENTCOIN ); //branch121212
	RegisterEvent( EV_BR_SHOW_CONFIRM );
	RegisterEvent( EV_BR_HIDE_CONFIRM );
	//branch110706
	RegisterEvent( EV_BR_CashShopCateroyAdd );	
	RegisterEvent( EV_BR_CashShopCateroyTabRemove );	
	RegisterEvent( EV_BR_CashShopCateroyTabClear );			
	RegisterEvent( EV_BR_PRESENT_SHOW_CONFIRM );
	RegisterEvent( EV_BR_PRESENT_HIDE_CONFIRM );
	//end of branch
	
	RegisterEvent( EV_BR_DeleteCashShopBasketProductItem );		
	RegisterEvent( EV_BR_DeleteAllBasketProductItem );		
		
	RegisterEvent( EV_DialogOK );	
}

function OnLoad()
{
	if (CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	bOpenMyShopReceiverWnd = false;
	m_bInitMainRand = false;
	m_bInitHandle = false;

	RegisterState( "BR_NewCashShopWnd", "TRAININGROOMSTATE" );

	InitHandle();
	Initialize();	
}

function InitHandle()
{
	if (CREATE_ON_DEMAND==0) {
		Me = GetHandle( "BR_NewCashShopWnd" );		
		//
		EditItemSearch = EditBoxHandle ( GetHandle( "BR_NewCashShopWnd.EditItemSearch" ) );
		BtnItemSearch = ButtonHandle ( GetHandle( "BR_NewCashShopWnd.BtnItemSearch" ) );
		BtnItemIndexSort = ButtonHandle ( GetHandle( "BR_NewCashShopWnd.BtnItemIndexSort" ) );
		BtnItemPointSort = ButtonHandle ( GetHandle( "BR_NewCashShopWnd.BtnItemPointSort" ) );
		BtnItemNameSort = ButtonHandle ( GetHandle( "BR_NewCashShopWnd.BtnItemNameSort" ) );
		//
				
		
		TabCategory = TabHandle ( GetHandle( "BR_NewCashShopWnd.TabCategory" ) );
		
		BtnCashCharge = ButtonHandle ( GetHandle( "BR_NewCashShopWnd.BtnCashCharge" ) );
		TextCurrentCash = TextBoxHandle ( GetHandle( "BR_NewCashShopWnd.TextCurrentCash" ) );
		TexCategoryUpper = TextureHandle ( GetHandle( "BR_NewCashShopWnd.TexCategoryUpper" ) );	
		
		ScrollItemInfo = GetHandle("BR_NewCashShopWnd.BR_ViewCashShopTab.ScrollItemInfo");	



		Drawer = GetHandle( "PopupWnd"); // br sr
		
		//branch120516
		BR_MyShopWnd = GetHandle("BR_MyShopWnd");
				
		BR_MainCashShopTab = GetHandle("BR_NewCashShopWnd.BR_MainCashShopTab");
		BR_ViewCashShopTab = GetHandle("BR_NewCashShopWnd.BR_ViewCashShopTab");
		BR_MainCashShopTab_Main = GetHandle("BR_NewCashShopWnd.BR_MainCashShopTab.BR_MainCashShopTab_Main");
		
		EventPageNum = TextBoxHandle ( GetHandle( "BR_NewCashShopWnd.BR_MainCashShopTab.BR_MainCashShopTab_Main.EventPageNum" ) );
		GoodPageNum = TextBoxHandle ( GetHandle( "BR_NewCashShopWnd.BR_MainCashShopTab.GoodPageNum" ) );
		StarPageNum = TextBoxHandle ( GetHandle( "BR_NewCashShopWnd.BR_MainCashShopTab.StarPageNum" ) );
		
		BR_MainGoodCashShopTab_Item.Length = 3;
		BR_MainGoodCashShopTab_Item[0] = GetHandle("BR_NewCashShopWnd.BR_MainCashShopTab.GoodItem1");
		BR_MainGoodCashShopTab_Item[1] = GetHandle("BR_NewCashShopWnd.BR_MainCashShopTab.GoodItem2");
		BR_MainGoodCashShopTab_Item[2] = GetHandle("BR_NewCashShopWnd.BR_MainCashShopTab.GoodItem3");
		BR_MainStarCashShopTab_Item.Length = 3;
		BR_MainStarCashShopTab_Item[0] = GetHandle("BR_NewCashShopWnd.BR_MainCashShopTab.StarItem1");
		BR_MainStarCashShopTab_Item[1] = GetHandle("BR_NewCashShopWnd.BR_MainCashShopTab.StarItem2");
		BR_MainStarCashShopTab_Item[2] = GetHandle("BR_NewCashShopWnd.BR_MainCashShopTab.StarItem3");
		
		BR_ViewCashShopTab_Item.Length = 10;
		BR_ViewCashShopTab_Item[0] = GetHandle("BR_NewCashShopWnd.BR_ViewCashShopTab.CashItemData_1");
		BR_ViewCashShopTab_Item[1] = GetHandle("BR_NewCashShopWnd.BR_ViewCashShopTab.CashItemData_2");
		BR_ViewCashShopTab_Item[2] = GetHandle("BR_NewCashShopWnd.BR_ViewCashShopTab.CashItemData_3");
		BR_ViewCashShopTab_Item[3] = GetHandle("BR_NewCashShopWnd.BR_ViewCashShopTab.CashItemData_4");
		BR_ViewCashShopTab_Item[4] = GetHandle("BR_NewCashShopWnd.BR_ViewCashShopTab.CashItemData_5");
		BR_ViewCashShopTab_Item[5] = GetHandle("BR_NewCashShopWnd.BR_ViewCashShopTab.CashItemData_6");
		BR_ViewCashShopTab_Item[6] = GetHandle("BR_NewCashShopWnd.BR_ViewCashShopTab.CashItemData_7");
		BR_ViewCashShopTab_Item[7] = GetHandle("BR_NewCashShopWnd.BR_ViewCashShopTab.CashItemData_8");
		BR_ViewCashShopTab_Item[8] = GetHandle("BR_NewCashShopWnd.BR_ViewCashShopTab.CashItemData_9");
		BR_ViewCashShopTab_Item[9] = GetHandle("BR_NewCashShopWnd.BR_ViewCashShopTab.CashItemData_10");
		
		TextViewPageNum = TextBoxHandle ( GetHandle( "BR_NewCashShopWnd.BR_ViewCashShopTab.TextViewPageNum" ) );
				
		//end of branch
	}
	else {
		Me = GetWindowHandle( "BR_NewCashShopWnd" );
		//
		EditItemSearch = GetEditBoxHandle( "BR_NewCashShopWnd.EditItemSearch" );
		BtnItemSearch = GetButtonHandle( "BR_NewCashShopWnd.BtnItemSearch" );
		BtnItemIndexSort = GetButtonHandle( "BR_NewCashShopWnd.BtnItemIndexSort" );
		BtnItemPointSort = GetButtonHandle( "BR_NewCashShopWnd.BtnItemPointSort" );
		BtnItemNameSort = GetButtonHandle( "BR_NewCashShopWnd.BtnItemNameSort" );
		//

		
		TabCategory = GetTabHandle ( "BR_NewCashShopWnd.TabCategory" );
		
		BtnCashCharge = GetButtonHandle ( "BR_NewCashShopWnd.BtnCashCharge" );
		TextCurrentCash = GetTextBoxHandle ( "BR_NewCashShopWnd.TextCurrentCash" );
		TexCategoryUpper = GetTextureHandle ( "BR_NewCashShopWnd.TexCategoryUpper" );
		
		ScrollItemInfo = GetWindowHandle("BR_NewCashShopWnd.BR_ViewCashShopTab.ScrollItemInfo");	
		

		Drawer = GetWindowHandle( "PopupWnd"); // by sr	
		
		//branch120516
		BR_MyShopWnd = GetWindowHandle( "BR_MyShopWnd" );
		
		BR_MainCashShopTab = GetWindowHandle("BR_NewCashShopWnd.BR_MainCashShopTab");
		BR_ViewCashShopTab = GetWindowHandle("BR_NewCashShopWnd.BR_ViewCashShopTab");
		BR_MainCashShopTab_Main = GetWindowHandle("BR_NewCashShopWnd.BR_MainCashShopTab.BR_MainCashShopTab_Main");
		
		EventPageNum = GetTextBoxHandle( "BR_NewCashShopWnd.BR_MainCashShopTab.BR_MainCashShopTab_Main.EventPageNum" ) ;
		GoodPageNum = GetTextBoxHandle( "BR_NewCashShopWnd.BR_MainCashShopTab.GoodPageNum" ) ;
		StarPageNum = GetTextBoxHandle( "BR_NewCashShopWnd.BR_MainCashShopTab.StarPageNum" ) ;
		
		BR_MainGoodCashShopTab_Item.Length = 3;
		BR_MainGoodCashShopTab_Item[0] = GetWindowHandle("BR_NewCashShopWnd.BR_MainCashShopTab.GoodItem1");
		BR_MainGoodCashShopTab_Item[1] = GetWindowHandle("BR_NewCashShopWnd.BR_MainCashShopTab.GoodItem2");
		BR_MainGoodCashShopTab_Item[2] = GetWindowHandle("BR_NewCashShopWnd.BR_MainCashShopTab.GoodItem3");
		BR_MainStarCashShopTab_Item.Length = 3;
		BR_MainStarCashShopTab_Item[0] = GetWindowHandle("BR_NewCashShopWnd.BR_MainCashShopTab.StarItem1");
		BR_MainStarCashShopTab_Item[1] = GetWindowHandle("BR_NewCashShopWnd.BR_MainCashShopTab.StarItem2");
		BR_MainStarCashShopTab_Item[2] = GetWindowHandle("BR_NewCashShopWnd.BR_MainCashShopTab.StarItem3");
		
		BR_ViewCashShopTab_Item.Length = 10;
		BR_ViewCashShopTab_Item[0] = GetWindowHandle("BR_NewCashShopWnd.BR_ViewCashShopTab.CashItemData_1");
		BR_ViewCashShopTab_Item[1] = GetWindowHandle("BR_NewCashShopWnd.BR_ViewCashShopTab.CashItemData_2");
		BR_ViewCashShopTab_Item[2] = GetWindowHandle("BR_NewCashShopWnd.BR_ViewCashShopTab.CashItemData_3");
		BR_ViewCashShopTab_Item[3] = GetWindowHandle("BR_NewCashShopWnd.BR_ViewCashShopTab.CashItemData_4");
		BR_ViewCashShopTab_Item[4] = GetWindowHandle("BR_NewCashShopWnd.BR_ViewCashShopTab.CashItemData_5");
		BR_ViewCashShopTab_Item[5] = GetWindowHandle("BR_NewCashShopWnd.BR_ViewCashShopTab.CashItemData_6");
		BR_ViewCashShopTab_Item[6] = GetWindowHandle("BR_NewCashShopWnd.BR_ViewCashShopTab.CashItemData_7");
		BR_ViewCashShopTab_Item[7] = GetWindowHandle("BR_NewCashShopWnd.BR_ViewCashShopTab.CashItemData_8");
		BR_ViewCashShopTab_Item[8] = GetWindowHandle("BR_NewCashShopWnd.BR_ViewCashShopTab.CashItemData_9");
		BR_ViewCashShopTab_Item[9] = GetWindowHandle("BR_NewCashShopWnd.BR_ViewCashShopTab.CashItemData_10");
		//end of branch
		
		TextViewPageNum = GetTextBoxHandle ( "BR_NewCashShopWnd.BR_ViewCashShopTab.TextViewPageNum" );
		
	}
}

// by sr
function ClickPopupItemList( int ProductID, int ShowTab )
{
// 	local int i;
// 			
// 		
// 	RequestBR_ProductInfo( ProductID, false ); // 클릭된 상품을 상품 설명란에 표시	
// 	
// 	for( i = 0 ; i < m_ViewProductInfo.Length ; i++)
// 	{		
// 		if( m_ViewProductInfo[i].iShowTab == ShowTab )
// 		{
// 			OnTabCategory( i ); // 이벤트 상품 리스트 
// 			TabCategory.SetTopOrder( i, false ); // 이벤트 탭으로
// 			return;
// 		}
// 	}	
}
// by sr
	
function Initialize()
{
	
	m_bInConfirm = false;
	m_bSortDesc = false;
	m_bSearch = false;
	
	m_bCoinToMoney = IsBr_CashShopCoinToMoney(); //branch 110824
	if( m_bCoinToMoney )
	{
		m_fCoinMoneyValue = GetBr_CashShopCoinToMoneyValue();		
	}
	
	m_bMainDisable = IsBr_CashShopMainDisable();
	if(m_bMainDisable)
	{
		m_iCurrentTab = 1;
		TabCategory.SetDisable( 0, true );	
		TabCategory.SetTopOrder(1, false);
	}
	else
	{
		m_iCurrentTab = 0;
	}
									
	ClearItemInfo();
			
	m_ViewProductInfo.Length = 7;	
	//메인
	m_ViewProductInfo[0].iCategory = 0;	
	m_ViewProductInfo[0].iShowTab = 0;	
	m_ViewProductInfo[0].iTabType = TAB_MASK;	
	m_ViewProductInfo[0].strTitleName = GetSystemString(5119);		
	// 0x02 - 전체
	m_ViewProductInfo[1].iCategory = 0;
	m_ViewProductInfo[1].iShowTab = 0;	
	m_ViewProductInfo[1].iTabType = TAB_MASK;	
	m_ViewProductInfo[1].strTitleName = GetSystemString(5002);	//전체
	m_iAllItemTab = 1;
	// 0x01 - 꾸미기
	m_ViewProductInfo[2].iCategory = 3;
	m_ViewProductInfo[2].iShowTab = 0;
	m_ViewProductInfo[2].iTabType = TAB_CATEGORY;
	m_ViewProductInfo[2].strTitleName = GetSystemString(5007);	//
	// 강화
	m_ViewProductInfo[3].iCategory = 1;
	m_ViewProductInfo[3].iShowTab = 0;
	m_ViewProductInfo[3].iTabType = TAB_CATEGORY;
	m_ViewProductInfo[3].strTitleName = GetSystemString(5005);
	// 소모품	
	m_ViewProductInfo[4].iCategory = 2;
	m_ViewProductInfo[4].iShowTab = 0;
	m_ViewProductInfo[4].iTabType = TAB_CATEGORY;
	m_ViewProductInfo[4].strTitleName = GetSystemString(5006);	
	// 패키지	
	m_ViewProductInfo[5].iCategory = 4;
	m_ViewProductInfo[5].iShowTab = 0;
	m_ViewProductInfo[5].iTabType = TAB_CATEGORY;	
	m_ViewProductInfo[5].strTitleName = GetSystemString(5008);
	// 기타
	m_ViewProductInfo[6].iCategory = 5;
	m_ViewProductInfo[6].iShowTab = 0;
	m_ViewProductInfo[6].iTabType = TAB_CATEGORY;	
	m_ViewProductInfo[6].strTitleName = GetSystemString(5009);
		
	SetTabCategory();
	RemoveTabCateroy(7);
	RemoveTabCateroy(8);
	
	BR_MainCashShopTab_Main.ShowWindow();	
	BR_MainCashShopTab.ShowWindow();		
	
	BR_ViewCashShopTab.HideWindow();		
	BR_ViewCashShopTab_Item[0].ShowWindow();
	BR_ViewCashShopTab_Item[1].ShowWindow();
	BR_ViewCashShopTab_Item[2].ShowWindow();
	BR_ViewCashShopTab_Item[3].ShowWindow();
	BR_ViewCashShopTab_Item[4].ShowWindow();
	BR_ViewCashShopTab_Item[5].ShowWindow();
	BR_ViewCashShopTab_Item[6].ShowWindow();
	BR_ViewCashShopTab_Item[7].ShowWindow();
	BR_ViewCashShopTab_Item[8].ShowWindow();
	BR_ViewCashShopTab_Item[9].ShowWindow();
				
	m_CurrentProductList.Length = 0; //branch120516
	m_nCurrentTabPage = 1;
	m_iCurrentTabTotalPage = 1;
	
	m_nMainGoodTabPage = 1;
	m_iMainGoodTabTotalPage = 1;
	m_nMainStarTabPage = 1;
	m_iMainStarTabTotalPage = 1;
	m_nMainEventTabPage = 1;	

	m_CashShopAPI = BR_CashShopAPI(GetScript("BR_CashShopAPI"));	
	
	Me.KillTimer( TIMER_EVENT_ID );	
	//Me.SetTimer(TIMER_EVENT_ID,TIMER_EVENT_DELAY);
	
	Me.KillTimer( TIMER_SCROLL_ID );	
	//Me.SetTimer(TIMER_SCROLL_ID,TIMER_SCROLL_DELAY);
	
	//branch 120703
	TextViewPageNum.SetText("");
	EventPageNum.SetText("");
	GoodPageNum.SetText("");
	StarPageNum.SetText("");	
	
	m_CashShopAPI.InitMainProductWindow(BR_MainCashShopTab_Main);
	//end of branch
	
	
	m_bInitOpen = true;
	m_bInitHandle = true;
	m_bSetFocusChange = false;

}

function SetTabCategory()
{
	local int i;
			
	for( i = 0 ; i < m_ViewProductInfo.Length ; i++)
	{		
		TabCategory.SetButtonName( i, m_ViewProductInfo[i].strTitleName );	
		TabCategory.SetDisable( i, false );
	}
}

function AddTabCateroy(string param)
{
	local int index;
	local int category;
	local int tabType;
	local int showtab;
	local int nameindex;
	
	ParseInt(param, "Category", category);	
	ParseInt(param, "TabType", tabType);
	ParseInt(param, "ShowTab", showtab);
	ParseInt(param, "NameIndex", nameindex);
	
	m_ViewProductInfo.Length = m_ViewProductInfo.Length + 1;
	index = m_ViewProductInfo.Length - 1;
	m_ViewProductInfo[index].iCategory = category;
	m_ViewProductInfo[index].iTabType = tabType;	
	m_ViewProductInfo[index].iShowTab = showtab;	
	m_ViewProductInfo[index].strTitleName = GetSystemString(nameindex);		
		
	if(tabType == TAB_MASK && category == 0)
	{
		m_iAllItemTab = index;
	}
}

function RemoveTabCateroy(int index)
{	
	TabCategory.SetButtonName( index, "" );	
	TabCategory.SetDisable( index, true );	
	TabCategory.SetButtonDisableTexture( index, "L2UI_CT1.tab.Tab_DF_Bg_line" );
}


function OnEvent(int Event_ID, string param)
{
	local INT64 iGamePoint;
	local int iResult;
	local int i;
	
	switch( Event_ID )
	{
		
	case EV_BR_CashShopToggleWindow :
		HandleToggleWindow();
		break;
	case EV_BR_CashShopCateroyAdd:
		AddTabCateroy(param);
		break;
	case EV_BR_CashShopCateroyTabRemove:
		ParseInt(param, "Index", i);	
		RemoveTabCateroy(i);
		break;			
	case EV_BR_CashShopCateroyTabClear:
		m_ViewProductInfo.Length = 0;
		break;
	case EV_BR_ProductListEnd:
		m_CashShopAPI.ProductItemSort(BRCSP_PRODUCT, 0, true);
		AddMainProductItem();				
		if( m_bInitOpen )
		{
			m_bInitOpen = false;			
			if( m_EventProductList.Length == 0 && m_MainGoodProductList.Length == 0 && m_MainStarProductList.Length == 0)
			{			
				TabCategory.SetTopOrder(1, false);
				OnTabCategory(TabCategory.GetTopIndex(), false);
			}	
			else
			{
				if( m_iCurrentTab == 0 )
				{
					OnTabMain(false);
				}
				else
				{
					OnTabCategory(TabCategory.GetTopIndex(),false);
				}
			}	
		}
		else
		{
			if( m_iCurrentTab == 0 )
			{
				OnTabMain(false);
			}
			else
			{
				OnTabCategory(TabCategory.GetTopIndex(),false);
			}
		}
		break;
	case EV_BR_BasketProductListEnd:
		m_CashShopAPI.SetBasketProductItemData();
		UpdateCurrentBasketViewProductList(false);
		break;
	case EV_BR_SETGAMEPOINT :
		ParseInt64(param, "GamePoint", iGamePoint);
		SetGamePoint(iGamePoint);
		break;
	case EV_BR_SHOW_CONFIRM :
		m_CashShopAPI.SetOpenBuyWnd(true);
		m_bInConfirm = true;
		HandleToggleWindow();		
		break;
	case EV_BR_HIDE_CONFIRM :
		m_CashShopAPI.SetOpenBuyWnd(false);
		m_bInConfirm = false;
		ClearItemInfo();
		HandleToggleWindow();
		break;
	//branch110706
	case EV_BR_PRESENT_SHOW_CONFIRM :
		m_CashShopAPI.SetOpenBuyWnd(true);
		m_bInConfirm = true;
		HandleToggleWindow();		
		break;
	case EV_BR_PRESENT_HIDE_CONFIRM :
		m_CashShopAPI.SetOpenBuyWnd(false);
		m_bInConfirm = false;
		ClearItemInfo();
		HandleToggleWindow();
		break;
	//end of branch	
	case EV_BR_DeleteCashShopBasketProductItem:
		ParseInt(param, "ID", iResult);	
		UpdateBasketViewProductList(iResult,false);
		break;
	case EV_BR_DeleteAllBasketProductItem:
		UpdateCurrentBasketViewProductList(true);
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
	case "BtnBasket":	
		debug("OnClickButtonWithHandle BtnBasket" $ SelectedProductID);	
		OnBtnBasketClick(a_ButtonHandle, SelectedProductID);
		break;	
	case "BtnGo":			
		OnBtnGoClick(SelectedProductID);
		debug("OnClickButtonWithHandle BtnGo" $ SelectedProductID );	
		break;	
	default:
		break;
	}		
}

function OnClickButton( string Name )
{
	switch( Name )
	{
	//
	case "BtnItemSearch":
		OnBtnItemSearchClick(EditItemSearch.GetString());		
		break;
	case "BtnItemIndexSort":
		OnBtnItemSortClick(PR_ITEM_INDEX);
		break;
	case "BtnItemPointSort":
		OnBtnItemSortClick(PR_ITEM_PRICE);
		break;
	case "BtnItemNameSort":
		OnBtnItemSortClick(PR_ITEM_NAME);
		break;
		//	
	case "BtnCashCharge":
		OnBtnCashChargeClick();
		break;	
	case "BtnMyShop":
		OnMyShopButton();
		break;
	//view
	case "BtnViewPreEnd":
		if( m_nCurrentTabPage > 1 )
		{
			m_nCurrentTabPage = 1;	
			SetViewProductList();		
			ScrollItemInfo.SetScrollPosition( 500 * (m_nCurrentTabPage - 1) );							
		}
		debug("BtnViewPreEnd");
		break;
	case "BtnViewPre":
		if( m_nCurrentTabPage > 1 )
		{
			m_nCurrentTabPage = m_nCurrentTabPage - 1;	
			SetViewProductList();		
			ScrollItemInfo.SetScrollPosition( 500 * (m_nCurrentTabPage - 1) );							
		}
		debug("BtnViewPre");
		break;
	case "BtnViewNext":
		if( m_nCurrentTabPage < m_iCurrentTabTotalPage )
		{
			m_nCurrentTabPage = m_nCurrentTabPage + 1;	
			SetViewProductList();		
			ScrollItemInfo.SetScrollPosition( 500 * (m_nCurrentTabPage - 1) );					
		}
		debug("BtnViewNext");	
		break;
	case "BtnViewNextEnd":		
		if( m_nCurrentTabPage != m_iCurrentTabTotalPage)
		{
			m_nCurrentTabPage = m_iCurrentTabTotalPage;		
			SetViewProductList();
			ScrollItemInfo.SetScrollPosition( 500 * (m_nCurrentTabPage - 1) );					
		}			
		debug("BtnViewNextEnd");
		break;
	//main
	case "BtnEventPre":
		SetMainEventViewProductList(false);
		Me.KillTimer( TIMER_EVENT_ID );	
		debug("BtnEventPre");
		break;
	case "BtnEventNext":
		SetMainEventViewProductList(true);
		Me.KillTimer( TIMER_EVENT_ID );	
		debug("BtnEventNext");	
		break;
	case "BtnGoodPre":
		if( m_nMainGoodTabPage > 1 )
		{
			m_nMainGoodTabPage = m_nMainGoodTabPage - 1;	
			SetMainGoodViewProductList();
		}
		debug("BtnGoodPre");
		break;
	case "BtnGoodNext":
		if( m_nMainGoodTabPage < m_iMainGoodTabTotalPage )
		{
			m_nMainGoodTabPage = m_nMainGoodTabPage + 1;	
			SetMainGoodViewProductList();		
		}
		debug("BtnGoodNext");	
		break;
	case "BtnStarPre":
		if( m_nMainStarTabPage > 1 )
		{
			m_nMainStarTabPage = m_nMainStarTabPage - 1;	
			SetMainStarViewProductList();
		}
		debug("BtnStarPre");
		break;
	case "BtnStarNext":
		if( m_nMainStarTabPage < m_iMainStarTabTotalPage )
		{
			m_nMainStarTabPage = m_nMainStarTabPage + 1;	
			SetMainStarViewProductList();			
		}
		debug("BtnStarNext");	
		break;
	case "TabCategory0":	//탭이 클릭된 경우			
		OnTabMain(true);
		m_bSetFocusChange = true;
		break;
	case "TabCategory1":		
	case "TabCategory2":
	case "TabCategory3":
	case "TabCategory4":
	case "TabCategory5":
	case "TabCategory6":
	case "TabCategory7":
	case "TabCategory8":	// 최근 구매 탭						
		if( m_ViewProductInfo.Length <= TabCategory.GetTopIndex() )
		{
			return;
		}
		m_nCurrentTabPage = 1;
		m_iCurrentTabTotalPage = 1;		
		OnTabCategory(TabCategory.GetTopIndex(),true);
		m_bSetFocusChange = true;
		break;
	default :		
		break;
	}
}

function SetBoolMyShop( bool b )
{	
	bOpenMyShopReceiverWnd = b;	
	if (bOpenMyShopReceiverWnd == false)
	{			
		BR_MyShopWnd.HideWindow();		
	}
}

function OnMyShopButton()
{		
	local BR_MyShopWnd Script;
	
	bOpenMyShopReceiverWnd = !bOpenMyShopReceiverWnd;	
	
	debug("OnReceiverMyShopButton OpenMyShopWnd"$ bOpenMyShopReceiverWnd);	
	if (bOpenMyShopReceiverWnd)
	{	
		Script = BR_MyShopWnd( GetScript( "BR_MyShopWnd" ) );	
		Script.selectedInit();
				
		BR_MyShopWnd.ShowWindow();		
	}
	else 
	{			
		BR_MyShopWnd.HideWindow();		
	}		
}

function OnHide()
{
	Drawer.KillTimer( 2009 ); // by sr
	if(IsShowWindow("PopupWnd")) Drawer.HideWindow(); // by sr
	
	Me.KillTimer( TIMER_SCROLL_ID );		
}

function SetGamePoint(INT64 iGamePoint)
{
	local string strGamePoint;
	
	if( m_bCoinToMoney ) //branch 110824
	{
		strGamePoint = "" $ float(iGamePoint) * m_fCoinMoneyValue;
		strGamePoint = strGamePoint;// $ " " $ GetSystemString(5012);
		TextCurrentCash.SetText(strGamePoint);
	}
	else
	{
		strGamePoint = "" $ string(iGamePoint);
		strGamePoint = MakeCostString(strGamePoint);// $ " " $ GetSystemString(5012);
		TextCurrentCash.SetText(strGamePoint);
	}	
}

function ClearItemList(int allclear)
{	
	
	if (allclear > 0)
	{	
		m_MainGoodProductList.Length = 0; //branch120516
		m_MainStarProductList.Length = 0; //branch120516
		m_EventProductList.Length = 0; //branch120516
		
		m_nMainGoodTabPage = 1;
		m_iMainGoodTabTotalPage = 1;
		m_nMainStarTabPage = 1;
		m_iMainStarTabTotalPage = 1;
		m_nMainEventTabPage = 1;	
	}
			
	m_CashShopAPI.ClearItemList(allclear);		
	m_CurrentProductList.Length = 0;
	//m_nCurrentTabPage = 1;
	//m_iCurrentTabTotalPage = 1;
}

function ClearItemInfo()
{
	//local string ChildName;
	//local DrawItemInfo kDrawInfo;


	EditItemSearch.SetString("");
	
}

function HandleToggleWindow()
{
// 	if( m_hOwnerWnd.IsShowWindow() )
// 	{		
// 		m_hOwnerWnd.HideWindow();		
// 		PlaySound("InterfaceSound.inventory_close_01");
// 		SetBoolMyShop( false );
// 	}
// 	else 
	if (m_bInConfirm == false)
	{		
		ShowCashShopWnd();			
		RequestBR_GamePoint();		
		RequestBR_ProductList(BRCSP_PRODUCT);		
		RequestBR_ProductList(BRCSP_BASKET);		
		RequestBR_ProductList(BRCSP_RECENT);
		ClearItemList(1);		
	}
}

function HandleDialogOK()
{
	local int id, num;
	local WindowHandle m_NewBuyWnd;	// 인벤토리 핸들 선언.
	
	if( DialogIsMine() ) {
		id = DialogGetID();
		num = int( DialogGetString() );
		if ( id == DIALOG_CLOSED_SHOP ) 
		{
			m_NewBuyWnd = GetWindowHandle( "BR_NewBuyingWnd" );
			if ( m_NewBuyWnd.IsShowWindow() )
			{
				m_NewBuyWnd.HideWindow();
			}
			if( m_hOwnerWnd.IsShowWindow() )
			{
				m_hOwnerWnd.HideWindow();
			}
		}
	}
}

function OnTabMain(bool tabbuttonClieck)
{
	local int TotalPage;
	
	BR_MainCashShopTab.ShowWindow();
	BR_ViewCashShopTab.HideWindow();
	
	BtnItemIndexSort.HideWindow();
	BtnItemPointSort.HideWindow();
	BtnItemNameSort.HideWindow();

	m_iCurrentTab = 0;
	
	TotalPage = m_MainGoodProductList.Length % 3;
	if( TotalPage > 0 )
	{
		
		m_iMainGoodTabTotalPage = (m_MainGoodProductList.Length / 3) + 1;
	}
	else
	{
		m_iMainGoodTabTotalPage = (m_MainGoodProductList.Length / 3);	
	}	
		
	TotalPage = m_MainStarProductList.Length % 3;
	if( TotalPage > 0 )
	{
		
		m_iMainStarTabTotalPage = (m_MainStarProductList.Length / 3) + 1;
	}
	else
	{
		m_iMainStarTabTotalPage = (m_MainStarProductList.Length / 3);	
	}	
	
	if( tabbuttonClieck || m_bInitMainRand == false )
	{
		m_bInitMainRand = true;
		m_nMainGoodTabPage = rand(m_iMainGoodTabTotalPage);	
		if( m_nMainGoodTabPage <= 0 )
		{
			m_nMainGoodTabPage = 1;		
		}
		m_nMainStarTabPage = rand(m_iMainStarTabTotalPage);	
		if( m_nMainStarTabPage <= 0 )
		{
			m_nMainStarTabPage = 1;		
		}
		m_nMainEventTabPage = rand(m_EventProductList.Length);
		if( m_nMainEventTabPage <= 0 )
		{
			m_nMainEventTabPage = 1;		
		}
	}
	else
	{
		if(m_nMainGoodTabPage > m_iMainStarTabTotalPage)
		{
			m_nMainGoodTabPage = m_iMainStarTabTotalPage;
		}
		if(m_nMainStarTabPage > m_iMainStarTabTotalPage)
		{
			m_nMainStarTabPage = m_iMainStarTabTotalPage;
		}
		if(m_nMainEventTabPage > m_iMainStarTabTotalPage)
		{
			m_nMainEventTabPage = m_EventProductList.Length;
		}
	}
	
	debug("m_MainGoodProductList:"$m_MainGoodProductList.Length);
	debug("m_MainStarProductList:"$m_MainStarProductList.Length);
	debug("m_EventProductList:"$m_EventProductList.Length);

	SetMainEventViewProductList(false);
	
	SetMainGoodViewProductList();
	SetMainStarViewProductList();	
	
	Me.KillTimer( TIMER_EVENT_ID );	
	Me.SetTimer(TIMER_EVENT_ID,TIMER_EVENT_DELAY);	
}

function SetMainEventViewProductList(bool bNext)
{
	local ProductInfo info;	
 	 	
 	if( m_EventProductList.Length <= 0 )
 		return;
	
	if( bNext )	
	{
		if( m_nMainEventTabPage >= m_EventProductList.Length )
		{
			m_nMainEventTabPage = 1;
		}
		else
		{
			m_nMainEventTabPage = m_nMainEventTabPage + 1;
		}		
	}
	else
	{
		if( m_nMainEventTabPage <= 1 )
		{
			m_nMainEventTabPage = m_EventProductList.Length;
		}
		else
		{
			m_nMainEventTabPage = m_nMainEventTabPage - 1;
		}	
	}	
	
	info = m_CashShopAPI.GetProductItem( m_EventProductList[m_nMainEventTabPage - 1] );
	
	EventPageNum.SetText("" $ m_nMainEventTabPage $ "/" $ m_EventProductList.Length);
	
	m_CashShopAPI.SetMainProductWindow(BR_MainCashShopTab_Main, info);
	
}


function SetMainGoodViewProductList()
{
	local int i;
	local int j;	
	local ProductInfo info;
		
	if( m_MainGoodProductList.Length <= 0 )
		return;
		
	j = 0;
	for (i=(m_nMainGoodTabPage - 1) * 3; i < m_nMainGoodTabPage * 3 ; i++)
	{		
		BR_MainGoodCashShopTab_Item[j].HideWindow();
		
		if( i < m_MainGoodProductList.Length )
		{
			info = m_CashShopAPI.GetProductItem( m_MainGoodProductList[i] );	
			m_CashShopAPI.SetViewProductWindow(BR_MainGoodCashShopTab_Item[j],info, false, true);		
			BR_MainGoodCashShopTab_Item[j].ShowWindow();
		}		
		j++;
	}	
	
	GoodPageNum.SetText("" $ m_nMainGoodTabPage $ "/" $ m_iMainGoodTabTotalPage);
}

function SetMainStarViewProductList()
{
	local int i;
	local int j;	
	local ProductInfo info;
	
	if( m_MainStarProductList.Length <= 0 )
		return;
	
	j = 0;
	for (i=(m_nMainStarTabPage - 1) * 3; i < m_nMainStarTabPage * 3 ; i++)
	{		
		BR_MainStarCashShopTab_Item[j].HideWindow();
		
		if( i < m_MainStarProductList.Length )
		{
			info = m_CashShopAPI.GetProductItem( m_MainStarProductList[i] );	
			m_CashShopAPI.SetViewProductWindow(BR_MainStarCashShopTab_Item[j],info, false, true);		
			BR_MainStarCashShopTab_Item[j].ShowWindow();
		}		
		j++;
	}	
	
	StarPageNum.SetText("" $ m_nMainStarTabPage $ "/" $ m_iMainStarTabTotalPage);
}


function OnTabCategory(int tabindex, bool tabbuttonClieck)
{	
	
	BR_MainCashShopTab.HideWindow();
	BR_ViewCashShopTab.ShowWindow();
			
	BtnItemIndexSort.ShowWindow();
	BtnItemPointSort.ShowWindow();
	BtnItemNameSort.ShowWindow();
			
	m_iCurrentTab = tabindex;	
		
	AddFilteredProductListAll(tabbuttonClieck);
	
	ScrollItemInfo.SetScrollHeight(500 * m_iCurrentTabTotalPage);
	ScrollItemInfo.SetScrollUnit(500, true );
	ScrollItemInfo.SetScrollPosition( 500 * (m_nCurrentTabPage - 1) );							
		
}

function OnBtnGoClick(int id)
{
	local int index;
	
	if( id <= 0 )
		return;
	
	
	TabCategory.SetTopOrder( m_iAllItemTab, false ); // 전체상품 탭으로					
	OnTabCategory(m_iAllItemTab,true);		
	
	ClearItemList(0);
	
	m_CurrentProductList.Length = 0;
		
	m_CurrentProductList.Length = m_CurrentProductList.Length + 1;
	index = m_CurrentProductList.Length - 1;	
	m_CurrentProductList[index] = id;			
			
	m_nCurrentTabPage = 1;	
	m_iCurrentTabTotalPage = 1;
	ScrollItemInfo.SetScrollHeight(500 * m_iCurrentTabTotalPage);				
	ScrollItemInfo.SetScrollUnit(500, true );
	SetViewProductList();
}

function OnBtnItemSearchClick(string strSearch)
{
	local int TotalPage;

	if( ItemSearchClick(strSearch, true) == false )
		return;
	
	debug("OnBtnItemSearchClick " $ strSearch );	
	
	TabCategory.SetTopOrder( m_iAllItemTab, false ); // 전체상품 탭으로		
			
	OnTabCategory(m_iAllItemTab, true);		
		
	ItemSearchClick(strSearch, false);
	
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
	ScrollItemInfo.SetScrollHeight(500 * m_iCurrentTabTotalPage);
	
	ScrollItemInfo.SetScrollUnit(500, true );
			
	SetViewProductList();
}

function bool ItemSearchClick(string strSearch, bool bCheck)
{
	local int i;
	local int index;
	local int searchcount;
	local ProductInfo ProductItem;
	
	searchcount = 0; 	
 	if( strSearch == "" ) return false;
	
	if( bCheck == false )
	{	
		ClearItemList(0);
	}
		
	//strSearch = ToLower( Substitute(strSearch, " ", "", FALSE) );	
	strSearch = ToLower( strSearch );	
	
	for (i=0; i < m_CashShopAPI.ProductListCount(); i++)
	{
		ProductItem = m_CashShopAPI.ArrayProductItem(i);
 		if(InStr( ToLower( ProductItem.strName ) , strSearch) > -1 )
 		{ 
			if( bCheck )
			{
				debug("ItemSearchClick ok" );
				return true;
			}
			else
			{
				m_CurrentProductList.Length = m_CurrentProductList.Length + 1;
				index = m_CurrentProductList.Length - 1;	
				m_CurrentProductList[index] = ProductItem.iProductID;					
				searchcount++;
			}				
		}
	}	
	
	if( searchcount > 0 )
	{
		debug("ItemSearchClick ok" $ searchcount );
		return true;
	}
	
	return false;
}


function OnBtnItemSortClick(EPrItemSortType eType)
{	
	m_bSortDesc = !m_bSortDesc;
	
	if(eType == PR_ITEM_INDEX)
	{
		m_CashShopAPI.ProductItemSort(BRCSP_PRODUCT, 0, m_bSortDesc);
	}
	else if(eType == PR_ITEM_PRICE)
	{
		m_CashShopAPI.ProductItemSort(BRCSP_PRODUCT, 1,m_bSortDesc);
	}
	else if(eType == PR_ITEM_NAME)
	{
		m_CashShopAPI.ProductItemSort(BRCSP_PRODUCT, 2,m_bSortDesc);
	}

	AddFilteredProductListAll(true);
}

function OnBtnBasketClick(ButtonHandle a_ButtonHandle, int ProductID)
{
	//local int i;
	local string strParam;
	local ProductInfo ProductItem;
	
	if (ProductID > 0) 
	{
		ProductItem = m_CashShopAPI.GetProductItem(ProductID);
				
		if( ProductItem.bMyShopBasketEnable )
		{			
			m_CashShopAPI.UpdateBasketProductItem(a_ButtonHandle, ProductID, false);			
			
			ParamAdd(strParam, "ID", string(ProductID));
			ExecuteEvent(EV_BR_DeleteMyShopBasketProductItem, strParam);			
			
		}
		else
		{
			m_CashShopAPI.UpdateBasketProductItem(a_ButtonHandle, ProductID, true);
											
			DialogSetID( DIALOG_MYSHOP_BASKET );
			DialogSetDefaultOK();
			DialogShow( DialogModalType_Modal, DialogType_OK, MakeFullSystemMsg( GetSystemMessage(6116), ProductItem.strName, "" ), string(Self) ); //branch 110824
				
			ParamAdd(strParam, "ID", string(ProductID));
			ExecuteEvent(EV_BR_AddMyShopBasketProductItem, strParam);		
		}		
	}
}

function OnBtnCashChargeClick()
{
	if( m_CashShopAPI.GetOpenBuyWnd() )
		return;
		
	if( IsUseSteam() ) // GL2UseSteam
		CashShopCoinChargeForSteam();
	else
		ShowCashChargeWebSite();

	RequestBR_GamePoint();
}

function ShowCashShopWnd()
{
	local WindowHandle m_inventoryWnd;	// 인벤토리 핸들 선언.
	
	//초기화
	//branch 110824
	if( RequestBr_CashShopCateoryIndex() )
	{		
		SetTabCategory();	
	}
	//end of branch
	
	m_inventoryWnd = GetWindowHandle( "InventoryWnd" );	//인벤토리의 윈도우 핸들을 얻어온다.
	ShowWindow("BR_NewCashShopWnd");
	class'UIAPI_WINDOW'.static.SetFocus("BR_NewCashShopWnd");

	PlaySound("InterfaceSound.inventory_open_01");
		
	if( m_inventoryWnd.IsShowWindow() )			//인벤토리 창이 열려있으면 닫아준다. 
	{
		m_inventoryWnd.HideWindow();
	}
	
	m_CashShopAPI.SetOpenBuyWnd(false);
	
	Me.KillTimer( TIMER_SCROLL_ID );	
	Me.SetTimer(TIMER_SCROLL_ID,TIMER_SCROLL_DELAY);
	
}

function bool CheckTabIndex(int category, int showtab)
{
	//local int i;
	local int iCurIndex;
	//local int num;
	
	if (m_ViewProductInfo[m_iCurrentTab].iTabType == TAB_RECENT ) //최근목록
	{
		return true;
	}
	else if (m_ViewProductInfo[m_iCurrentTab].iTabType == TAB_MASK) 
	{
		if(m_ViewProductInfo[m_iCurrentTab].iCategory == 0 ) // 전체목록
		{
			return true;
		}
		
		iCurIndex = (showtab & m_ViewProductInfo[m_iCurrentTab].iShowTab);
		debug("Check : showtab=" $ showtab $ ", index=" $ iCurIndex);
		
		if (iCurIndex == 0) 
		{
			return false;
		}
		else 
		{	
			return true;
		}
	}
	else if (m_ViewProductInfo[m_iCurrentTab].iTabType == TAB_CATEGORY) 
	{
		if (m_ViewProductInfo[m_iCurrentTab].iCategory == category) 
		{
			return true;
		}
		else 
		{
			return false;
		}
	}
		
	return false;
}

function AddFilteredProductListAll(bool tabbuttonClieck)
{
	local int i;
	local int TotalPage;
	
	ClearItemList(0);
		
	
	for (i=0; i < m_CashShopAPI.ProductListCount(); i++)
	{				
		AddFilteredProductCurrenrtList( m_CashShopAPI.ArrayProductItem(i) );
	}
	
	TotalPage = m_CurrentProductList.Length % PAGE_MAX;
	if( TotalPage > 0 )
	{
		
		m_iCurrentTabTotalPage = (m_CurrentProductList.Length / PAGE_MAX) + 1;
	}
	else
	{
		m_iCurrentTabTotalPage = (m_CurrentProductList.Length / PAGE_MAX);	
	}	
	if( tabbuttonClieck )
	{
		m_nCurrentTabPage = 1;	
	}
	
	
			
	SetViewProductList();
	
}

function AddFilteredProductCurrenrtList(ProductInfo info)
{
	local int index;
	
	if (CheckTabIndex(info.iCategory, info.iShowTab) == false) {
		return;
	}
	
	m_CurrentProductList.Length = m_CurrentProductList.Length + 1;
	index = m_CurrentProductList.Length - 1;	
	m_CurrentProductList[index] = info.iProductID;	
}


function SetViewProductList()
{
	local int i;
	local int j;	
	local ProductInfo info;
	
	j = 0;
	for (i=(m_nCurrentTabPage - 1) * PAGE_MAX; i < m_nCurrentTabPage * PAGE_MAX ; i++)
	{		
		BR_ViewCashShopTab_Item[j].HideWindow();
		
		if( i < m_CurrentProductList.Length )
		{
			info = m_CashShopAPI.GetProductItem(m_CurrentProductList[i]);	
			m_CashShopAPI.SetViewProductWindow(BR_ViewCashShopTab_Item[j], info, false, true);		
			BR_ViewCashShopTab_Item[j].ShowWindow();
		}		
		j++;
	}	
	
	TextViewPageNum.SetText("" $ m_nCurrentTabPage $ "/" $ m_iCurrentTabTotalPage);
	
	
	
	
	m_scrollheight = 0;
}

function UpdateCurrentBasketViewProductList(bool AllDelete)
{
	local int i;
	local ProductInfo info;
	local ButtonHandle childBtnBasket;
			
	for (i=0 ; i < m_CurrentProductList.Length ; i++)
	{
		if( AllDelete )
		{
			childBtnBasket = ButtonHandle( BR_ViewCashShopTab_Item[i].GetChildWindow("BtnBasket") );	
			m_CashShopAPI.UpdateBasketProductWindow(childBtnBasket, false);					
		}
		else
		{
			info = m_CashShopAPI.GetBasketProductItem(m_CurrentProductList[i]);			
			if( info.iProductID > 0 )
			{		
				childBtnBasket = ButtonHandle( BR_ViewCashShopTab_Item[i].GetChildWindow("BtnBasket") );	
				m_CashShopAPI.UpdateBasketProductWindow(childBtnBasket, true);					
			}		
		}		
	}
	
	if( m_MainGoodProductList.Length <= 0 )
			return;
			
	for (i=0; i < 3 ; i++)
	{		
		if( AllDelete )
		{
			childBtnBasket = ButtonHandle( BR_MainGoodCashShopTab_Item[i].GetChildWindow("BtnBasket") );	
			m_CashShopAPI.UpdateBasketProductWindow(childBtnBasket, false);				
		}
		else
		{
			info = m_CashShopAPI.GetBasketProductItem(m_MainGoodProductList[i]);			
			if( info.iProductID > 0 )
			{		
				childBtnBasket = ButtonHandle( BR_MainGoodCashShopTab_Item[i].GetChildWindow("BtnBasket") );	
				m_CashShopAPI.UpdateBasketProductWindow(childBtnBasket, true);					
			}				
		}
		
	}	
	
	if( m_MainStarProductList.Length <= 0 )
		return;
	
	for (i=0; i < 3 ; i++)
	{				
		if( AllDelete )
		{
			childBtnBasket = ButtonHandle( BR_MainStarCashShopTab_Item[i].GetChildWindow("BtnBasket") );	
			m_CashShopAPI.UpdateBasketProductWindow(childBtnBasket, false);				
		}
		else
		{
			info = m_CashShopAPI.GetBasketProductItem(m_MainStarProductList[i]);			
			if( info.iProductID > 0 )
			{		
				childBtnBasket = ButtonHandle( BR_MainStarCashShopTab_Item[i].GetChildWindow("BtnBasket") );	
				m_CashShopAPI.UpdateBasketProductWindow(childBtnBasket, true);					
			}				
		}
	}	
}

function UpdateBasketViewProductList(int Productid, bool BasketCheck)
{
	local int i;
	local bool succ;
	local ButtonHandle childBtnBasket;
	
	if( m_iCurrentTab == 0 )
	{
	
		if( m_MainGoodProductList.Length <= 0 )
			return;
			
		for (i=0; i < 3 ; i++)
		{		
			childBtnBasket = ButtonHandle( BR_MainGoodCashShopTab_Item[i].GetChildWindow("BtnBasket") );	
			if( Productid == 0 )
			{
				m_CashShopAPI.UpdateBasketProductWindow(childBtnBasket, false);				
			}
			else
			{
				succ = m_CashShopAPI.UpdateBasketProductItem(childBtnBasket, Productid, BasketCheck);				
				if( succ )
					break;
			}
			
		}	
		
		if( m_MainStarProductList.Length <= 0 )
			return;
		
		for (i=0; i < 3 ; i++)
		{				
			childBtnBasket = ButtonHandle( BR_MainStarCashShopTab_Item[i].GetChildWindow("BtnBasket") );	
			if( Productid == 0 )
			{
				m_CashShopAPI.UpdateBasketProductWindow(childBtnBasket, false);				
			}
			else
			{
				succ = m_CashShopAPI.UpdateBasketProductItem(childBtnBasket, Productid, BasketCheck);				
				if( succ )
					return;
			}
		}	
	
	}
	else
	{
		for (i = 0; i < PAGE_MAX ; i++)
		{			
			childBtnBasket = ButtonHandle( BR_ViewCashShopTab_Item[i].GetChildWindow("BtnBasket") );	
			if( Productid == 0 )
			{
				m_CashShopAPI.UpdateBasketProductWindow(childBtnBasket, false);				
			}
			else
			{
				succ = m_CashShopAPI.UpdateBasketProductItem(childBtnBasket, Productid, BasketCheck);				
				if( succ )
					return;
			}
		}	
	}			
}

function AddMainProductItem() //branch120516
{
	local int i;	
	local int flag;	
	local int iMainGoodCurrentIndex;
	local int iMainStarCurrentIndex;
	local int iEventCurrentIndex;
	local ProductInfo ProductItem;
	
	m_EventProductList.Length = 0;
	m_MainGoodProductList.Length = 0;
	m_MainStarProductList.Length = 0;
		
	for (i=0; i < m_CashShopAPI.ProductListCount() ; i++)
	{
		ProductItem = m_CashShopAPI.ArrayProductItem(i);
		
		flag = ProductItem.iShowTab & PRODUCT_TAB_ADVERTISING;
		debug("AddMainProductItem PRODUCT_TAB_ADVERTISING flag" $ flag );
		if( flag > 0 )
		{
			iEventCurrentIndex = m_EventProductList.Length;
			m_EventProductList.Length = iEventCurrentIndex + 1;
		
			m_EventProductList[iEventCurrentIndex] = ProductItem.iProductID;
		}
		flag = ProductItem.iShowTab & PRODUCT_TAB_RECOMMEND;
		debug("AddMainProductItem PRODUCT_TAB_RECOMMEND flag" $ flag );
		if( flag > 0 )
		{
			iMainGoodCurrentIndex = m_MainGoodProductList.Length;
			m_MainGoodProductList.Length = iMainGoodCurrentIndex + 1;
			
			m_MainGoodProductList[iMainGoodCurrentIndex] = ProductItem.iProductID;
		}
		flag = ProductItem.iShowTab & PRODUCT_TAB_POPULAR;
		debug("AddMainProductItem PRODUCT_TAB_POPULAR flag" $ flag );
		if( flag > 0 )
		{
			iMainStarCurrentIndex = m_MainStarProductList.Length;
			m_MainStarProductList.Length = iMainStarCurrentIndex + 1;
			
			m_MainStarProductList[iMainStarCurrentIndex] = ProductItem.iProductID;
		}		
	}		
	
}

function OnTimer(int TimerID)
{
	local int height;	
	
	if( m_bInitHandle && m_bSetFocusChange )
	{	
		if( m_iCurrentTab == 0 )
		{
			BR_MainCashShopTab.SetFocus();
		}
		else
		{
			BR_ViewCashShopTab.SetFocus();
		}
		m_bSetFocusChange = false;
	}
	
	
	if(TimerID == TIMER_EVENT_ID)
	{
		SetMainEventViewProductList(true);
	}
	else if( TimerID == TIMER_SCROLL_ID )
	{
		height = ScrollItemInfo.GetScrollHeight() / 495;		
		
		debug( "scrollheight" $ height);
		if( height + 1 != m_nCurrentTabPage)
		{
			if( height + 1 > m_nCurrentTabPage)
			{
				//OnClickButton("BtnViewNext");
				
				if( m_nCurrentTabPage < m_iCurrentTabTotalPage )
				{
					m_nCurrentTabPage = m_nCurrentTabPage + 1;	
					SetViewProductList();							
				}
				debug("BtnViewNext");	
			}
			else
			{
				//OnClickButton("BtnViewPre");
				
				if( m_nCurrentTabPage > 1 )
				{
					m_nCurrentTabPage = m_nCurrentTabPage - 1;	
					SetViewProductList();				
				}
				debug("BtnViewPre");
			}			
		}		
	}
}
defaultproperties
{
}
