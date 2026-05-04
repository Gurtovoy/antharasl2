class BR_NewBuyingWnd extends UICommonAPI;

//branch121212
const	CASHSHOPPAYMENTTYPE_CASH			=	0;	
const 	CASHSHOPPAYMENTTYPE_ADENA			=	1;	
const	CASHSHOPPAYMENTTYPE_EVENTCOIN		=	2;	
//end of branch

const FEE_OFFSET_Y_EQUIP = -18;

const DIALOG_RESULT_SUCCESS		= 301;
const DIALOG_RESULT_FAILURE		= 302;
const DIALOG_PRODUCT_QUANTITY		= 351;

const ITEM_INFO_WIDTH = 256;
const ITEM_INFO_LEFT_MARGIN = 10;
const ITEM_INFO_BLANK_HEIGHT = 10;
const MAX_BUY_COUNT		= 99;

var bool m_bDrawBg;
var bool m_bInConfirm;

// current product
var int 	m_iProductID;
var int		m_iPrice;
var int		m_iAmount;
var int		m_iPaymentType; //branch121212
var string	m_strName;
var string 	m_strIconName;
var INT64 m_iGamePoint;
var INT64 m_iAdena; //branch121212
var INT64 m_iEventCoin;//branch121212
var bool	m_bCoinToMoney; // branch 110824
var float	m_fCoinMoneyValue; //branch 110824

var WindowHandle Me;
var TextBoxHandle TextCurCash;
var TextBoxHandle TextBalance;
var TextBoxHandle TextPrice;
var WindowHandle ScrollItemInfo;
var ButtonHandle BtnCancel;
var ButtonHandle BtnBuy;
var ButtonHandle BtnCharge;
var TextureHandle TexPriceInfoBG;
var TextureHandle TexItemInfoBG;
var TextBoxHandle StaticCurCash;
var TextBoxHandle StaticWarning;
var DrawPanelHandle m_hDrawPanel;
var EditBoxHandle EditBuyCount;
var ButtonHandle BtnChange;

var int m_iCurrentHeight;
var DrawItemInfo m_kDrawInfoClear;

//캐쉬샵 공통 함수
var BR_CashShopAPI m_CashShopAPI;

function OnLoad()
{
	
	RegisterState( "BR_NewBuyingWnd", "TRAININGROOMSTATE" );
	
	if (CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	m_bInConfirm = false;
	m_iAmount = 1;			
	
	InitHandle();
	
	BtnChange.HideWindow();
	m_CashShopAPI = BR_CashShopAPI(GetScript("BR_CashShopAPI"));	
	
}

function InitHandle()
{
	if (CREATE_ON_DEMAND==0) {
		Me = GetHandle( "BR_NewBuyingWnd" );
		TextCurCash = TextBoxHandle ( GetHandle( "BR_NewBuyingWnd.TextCurCash" ) );
		TextBalance = TextBoxHandle ( GetHandle( "BR_NewBuyingWnd.TextBalance" ) );
		TextPrice = TextBoxHandle ( GetHandle( "BR_NewBuyingWnd.TextPrice" ) );
		
		EditBuyCount = EditBoxHandle ( GetHandle( "BR_NewBuyingWnd.EditBuyCount" ) );
		BtnChange = ButtonHandle ( GetHandle( "BR_NewBuyingWnd.BtnChange" ) );
		
		ScrollItemInfo = GetHandle("BR_NewBuyingWnd.ScrollItemInfo");	
				
		BtnCancel = ButtonHandle ( GetHandle( "BR_NewBuyingWnd.BtnCancel" ) );
		BtnBuy = ButtonHandle ( GetHandle( "BR_NewBuyingWnd.BtnBuy" ) );
		BtnCharge = ButtonHandle ( GetHandle( "BR_NewBuyingWnd.BtnCharge" ) );
		TexPriceInfoBG = TextureHandle ( GetHandle( "BR_NewBuyingWnd.TexPriceInfoBG" ) );
		TexItemInfoBG = TextureHandle ( GetHandle( "BR_NewBuyingWnd.TexItemInfoBG" ) );
		
		StaticCurCash = TextBoxHandle ( GetHandle( "BR_NewBuyingWnd.StaticCurCash" ) );
		StaticWarning = TextBoxHandle ( GetHandle( "BR_NewBuyingWnd.StaticWarning" ) );
	}
	else {
		Me = GetWindowHandle( "BR_NewBuyingWnd" );
		
		EditBuyCount = GetEditBoxHandle ( "BR_NewBuyingWnd.EditBuyCount" );
		BtnChange = GetButtonHandle ( "BR_NewBuyingWnd.BtnChange" );
		
		TextCurCash = GetTextBoxHandle ( "BR_NewBuyingWnd.TextCurCash" );
		TextBalance = GetTextBoxHandle ( "BR_NewBuyingWnd.TextBalance" );
		TextPrice = GetTextBoxHandle ( "BR_NewBuyingWnd.TextPrice" );
		
		ScrollItemInfo = GetWindowHandle("BR_NewBuyingWnd.ScrollItemInfo");		
				
		BtnCancel = GetButtonHandle ( "BR_NewBuyingWnd.BtnCancel" );
		BtnBuy = GetButtonHandle ( "BR_NewBuyingWnd.BtnBuy" );
		BtnCharge = GetButtonHandle ( "BR_NewBuyingWnd.BtnCharge" );
		TexPriceInfoBG = GetTextureHandle ( "BR_NewBuyingWnd.TexPriceInfoBG" );
		TexItemInfoBG = GetTextureHandle ( "BR_NewBuyingWnd.TexItemInfoBG" );
		
		StaticCurCash = GetTextBoxHandle ( "BR_NewBuyingWnd.StaticCurCash" );
		StaticWarning = GetTextBoxHandle ( "BR_NewBuyingWnd.StaticWarning" );
	}
	
	
	
}

function OnRegisterEvent()
{
	RegisterEvent( EV_BR_SetNewProductInfo );
	RegisterEvent( EV_BR_AddEachProductInfo );
	RegisterEvent( EV_BR_SHOW_CONFIRM );
	RegisterEvent( EV_BR_HIDE_CONFIRM );
	RegisterEvent( EV_BR_SETGAMEPOINT );
	RegisterEvent( EV_BR_SETEVENTCOIN ); //branch121212
	RegisterEvent( EV_BR_RESULT_BUY_PRODUCT );
	RegisterEvent( EV_DialogOK );
}

function OnClickButton( string Name )
{
	// debug("BR_NewBuyingWnd Show Confirm " $ m_bInConfirm);
	
	if (m_bInConfirm)
		return;
		
	switch( Name )
	{
	case "BtnCancel":
		OnBtnCancelClick();
		break;
	case "BtnBuy":
		OnBtnBuyClick();
		break;
	case "BtnCharge":
		OnBtnChargeClick();
		break;
	case "BtnChange":
		//OnBtnInputQuantity();
		break;
	}
}

function OnEvent(int Event_ID, string param)
{
	local int iResult;
	local int iCoinToMoney; //branch 110824
	
	local int iId;
	local string desc;	
	local string itemname;
	local int price;	
	local int weight;
	local int iAmount;	
	local string iconname;
	local int trade;
	
	switch( Event_ID )
	{
	case EV_BR_SETGAMEPOINT :
		ParseInt64(param, "GamePoint", m_iGamePoint);
		if (m_bInConfirm==false)
			CalculateBalance();
		break;
	//branch121212
	case EV_BR_SETEVENTCOIN :
		ParseInt64(param, "Adena", m_iAdena);
		ParseInt64(param, "EventCoin", m_iEventCoin);
		break;
	case EV_BR_RESULT_BUY_PRODUCT :
		ParseInt(param, "Result", iResult );
		//ParseInt64(param, "GamePoint", m_iGamePoint);
		ResultBuy(iResult, m_iGamePoint);
		//RequestBR_GamePoint();
		break;
	case EV_BR_SHOW_CONFIRM :
		debug("EV_BR_SHOW_CONFIRM : " $ param);
		ParseInt(param, "ID", m_iProductID);
		ParseInt(param, "Price", m_iPrice);
		ParseInt(param, "PaymentType", m_iPaymentType); //branch121212
		ParseString(param, "ItemName", m_strName);
		ParseString(param, "IconName", m_strIconName);		
		//branch 110824
		ParseInt(param, "CoinToMoney", iCoinToMoney);
		if( iCoinToMoney == 0 )
		{
			m_bCoinToMoney = false;
		}
		else
		{
			m_bCoinToMoney = true;
			ParseFloat(param, "CoinToMoneyValue", m_fCoinMoneyValue);
		}
		//end of branch

		ShowBuyWindow(true);
		m_bInConfirm = false;
		ClearItemInfo();
		CalculateBalance();
		RequestBR_ProductInfo(m_iProductID, false);				
		break;
		
	case EV_BR_SetNewProductInfo :		
		ParseInt(param, "ID", iId);
		ParseInt(param, "Price", price);
		ParseString(param, "ItemName", itemname);
		ParseString(param, "Desc", desc);
		
		ClearItemInfo();
		m_CashShopAPI.SetNewProductInfo(m_hDrawPanel, iID, price, itemname, desc);
		
		break;
	case EV_BR_AddEachProductInfo :
		ParseInt(param, "ID", iId );
		ParseInt(param, "Amount", iAmount );
		ParseString(param, "ItemName", itemname );
		ParseString(param, "IconName", iconname );
		ParseString(param, "Desc", desc );
		ParseInt(param, "Weight", weight );
		ParseInt(param, "Trade", trade );
	
		m_CashShopAPI.AddEachProductInfo(m_hDrawPanel, iId, iAmount, itemname, iconname, desc, weight, trade);
		
		ResetScrollHeight();
		
		break;
	
	case EV_DialogOK:
		if( HandleDialogOK() )
		{
			return;			
		}
		ShowBuyWindow(false);
		m_bInConfirm = false;
		break;
	case EV_DialogCancel:
		m_bInConfirm = false;
		break;
	}
}

function bool HandleDialogOK()
{
	local int id;	
	local int num;	
	
	if( DialogIsMine() )
	{
		id = DialogGetID();
		debug("HandleDialogOK  " $ id);		
		if( id == DIALOG_PRODUCT_QUANTITY )
		{		
			num = int( DialogGetString() );
			if( num > 0 )
			{
				if (num > MAX_BUY_COUNT)
					num = MAX_BUY_COUNT;
					
				m_iAmount = num;
				EditBuyCount.SetString(string(m_iAmount));							
			}			
			CalculateBalance();
		}
		else if( id == DIALOG_RESULT_FAILURE || id == DIALOG_RESULT_SUCCESS )
		{
			ShowBuyWindow(false);
			m_bInConfirm = false;				
			RequestBR_ProductList(BRCSP_PRODUCT);	
			RequestBR_ProductList(BRCSP_BASKET);	
			RequestBR_ProductList(BRCSP_RECENT);	// 최근구매목록		
		}
	}
	else
	{
		return false;
	}
	return true;
}

function OnHide()
{
	DialogHide();

	ExecuteEvent(EV_BR_HIDE_CONFIRM);
	PlaySound("InterfaceSound.inventory_close_01");
	
	m_bInConfirm = false;
}

function OnShow()
{
	CalculateBalance();
}


function OnChangeEditBox( String strID )
{	
	local string strCount;
	
	if ( strID == "EditBuyCount" )
	{
		strCount = EditBuyCount.GetString();
		m_iAmount = int(strCount);
		if ( m_iAmount > MAX_BUY_COUNT ) 
		{
			m_iAmount = MAX_BUY_COUNT;
			EditBuyCount.SetString( string(m_iAmount) );
		}
		
		CalculateBalance();
		
	}
}

function OnBtnCancelClick()
{
	ShowBuyWindow(false);
	m_bInConfirm = false;
	ClearItemInfo();	
}

function OnBtnBuyClick()
{
	if (m_iProductID > 0 && m_iAmount > 0) {
		m_bInConfirm = true;
		RequestBR_BuyProduct(m_iProductID, m_iAmount);
	}
}

function OnBtnInputQuantity()
{
	local ProductInfo ProductItem;
	ProductItem = m_CashShopAPI.GetProductItem(m_iProductID);
	
	if (ProductItem.iProductID > 0) 
	{
		DialogSetID( DIALOG_PRODUCT_QUANTITY );
		//DialogSetReservedItemID( info.ID );
		DialogSetDefaultOK();
		DialogSetParamInt64( MAX_BUY_COUNT );
		DialogShow( DialogModalType_Modalless, DialogType_NumberPad, MakeFullSystemMsg( GetSystemMessage(570), ProductItem.strName, "" ), string(Self) );
	}
}

function OnBtnChargeClick()
{

	if( IsUseSteam() ) // GL2UseSteam
		CashShopCoinChargeForSteam();
	else
		ShowCashChargeWebSite();

	RequestBR_GamePoint();
}

//branch 110824
function CalculateBalance()
{
	local INT64 iTotalPrice;
	local INT64 iBalance;
	
	iTotalPrice = m_iPrice * m_iAmount;
		
	//branch121212
	if(m_iPaymentType == CASHSHOPPAYMENTTYPE_CASH)
	{
		iBalance = m_iGamePoint - iTotalPrice;
		
		if( m_bCoinToMoney )
		{
			TextPrice.SetText("" $ float(iTotalPrice) * m_fCoinMoneyValue $ " " $ GetSystemString(5012));	
			TextCurCash.SetText("" $ float(m_iGamePoint) * m_fCoinMoneyValue $ " " $ GetSystemString(5012));			
			TextBalance.SetText("" $ float(iBalance) * m_fCoinMoneyValue $ " " $ GetSystemString(5012));
		}
		else
		{
			TextPrice.SetText("" $ string(iTotalPrice) $ " " $ GetSystemString(5012));	
			TextCurCash.SetText("" $ string(m_iGamePoint) $ " " $ GetSystemString(5012));			
			TextBalance.SetText("" $ string(iBalance) $ " " $ GetSystemString(5012));
		}
		
		StaticCurCash.SetText(GetSystemString(5014));
		StaticWarning.ShowWindow();
		BtnCharge.ShowWindow();
		BtnCancel.MoveC(104,376);
		BtnBuy.MoveC(6,376);
		
	}
	else if(m_iPaymentType == CASHSHOPPAYMENTTYPE_ADENA)
	{
		iBalance = m_iAdena - iTotalPrice;
		
		TextPrice.SetText("" $ string(iTotalPrice) $ " " $ GetSystemString(469));	
		TextCurCash.SetText("" $ string(m_iAdena) $ " " $ GetSystemString(469));			
		TextBalance.SetText("" $ string(iBalance) $ " " $ GetSystemString(469));
		
		StaticWarning.HideWindow();		
		StaticCurCash.SetText(GetSystemString(3001));
		BtnCharge.HideWindow();
		BtnCancel.MoveC(154,376);
		BtnBuy.MoveC(56,376);
	}
	else if(m_iPaymentType == CASHSHOPPAYMENTTYPE_EVENTCOIN)
	{
		iBalance = m_iEventCoin - iTotalPrice;
		
		TextPrice.SetText("" $ string(iTotalPrice) $ " " $ GetSystemString(5179));	
		TextCurCash.SetText("" $ string(m_iEventCoin) $ " " $ GetSystemString(5179));			
		TextBalance.SetText("" $ string(iBalance) $ " " $ GetSystemString(5179));
		
		StaticWarning.HideWindow();
		StaticCurCash.SetText(GetSystemString(5180));
		BtnCharge.HideWindow();
		BtnCancel.MoveC(154,376);
		BtnBuy.MoveC(56,376);
	}		
}
//end of branch

function ResultBuy(int iResult, INT64 iGamePoint)
{
	//debug( "Buying Result [" $ iResult $ "] - " $ string(iGamePoint) );
	
	local string sysmeg;
	
	if( iResult == 1 )
	{
		m_iGamePoint = iGamePoint;
		CalculateBalance();
		DialogSetID( DIALOG_RESULT_SUCCESS );
		DialogSetDefaultOK();
		DialogShow( DialogModalType_Modal, DialogType_OK, GetSystemMessage(6001), string(Self) );
	}
	else
	{
		sysmeg = m_CashShopAPI.ErrorResultBuy(iResult);
		
		DialogSetID( DIALOG_RESULT_FAILURE );
		DialogSetDefaultOK();
		DialogShow( DialogModalType_Modal, DialogType_OK, sysmeg, string(Self) );
	}
}

function ShowBuyWindow(bool bShow)
{
	m_bDrawBg = true;
	
	// debug("Show Confirm " $ bShow);
	if ( bShow == true )
	{
		Me.ShowWindow();
		Me.SetFocus();
		RequestBR_GamePoint();
		PlaySound("InterfaceSound.inventory_open_01");
	}
	else 
	{
		Me.HideWindow();
	}
}

function ClearItemInfo()
{
	
	if (m_hDrawPanel == None) {
		m_hDrawPanel = DrawPanelHandle( ScrollItemInfo.AddChildWnd(XCT_DrawPanel) );
		m_hDrawPanel.SetWindowSize( ITEM_INFO_WIDTH, 168 );
		m_hDrawPanel.Move(ITEM_INFO_LEFT_MARGIN, ITEM_INFO_LEFT_MARGIN);
		m_hDrawPanel.SetBackTexture("");
	}
	m_hDrawPanel.Clear();

	m_iCurrentHeight = 0;
	ResetScrollHeight();	
	
	m_iAmount = 1;
	EditBuyCount.SetString(string(m_iAmount));			
}

function ResetScrollHeight()
{
	local int iWidth, iHeight;
	
	m_hDrawPanel.PreCheckPanelSize(iWidth, iHeight);
	m_hDrawPanel.SetWindowSize(ITEM_INFO_WIDTH, iHeight+16);

	m_iCurrentHeight = iHeight;
	
	ScrollItemInfo.SetScrollHeight(m_iCurrentHeight+30);
	ScrollItemInfo.SetScrollPosition( 0 );
}
defaultproperties
{
}
