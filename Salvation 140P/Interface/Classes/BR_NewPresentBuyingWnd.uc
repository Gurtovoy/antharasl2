class BR_NewPresentBuyingWnd extends UICommonAPI;

const FEE_OFFSET_Y_EQUIP = -18;

const DIALOG_RESULT_SUCCESS		= 303;
const DIALOG_RESULT_FAILURE		= 304;
const DIALOG_PRODUCT_QUANTITY		= 351;

const ITEM_INFO_WIDTH = 256;
const ITEM_INFO_LEFT_MARGIN = 10;
const ITEM_INFO_BLANK_HEIGHT = 10;
const MAX_BUY_COUNT		= 99;

var bool m_bDrawBg;
var bool m_bInConfirm;
var bool bOpenCashShopReceiverListWnd;

// current product
var int 	m_iProductID;
var int		m_iPrice;
var int		m_iAmount;
var string	m_strName;
var string 	m_strIconName;
var INT64 m_iGamePoint;
var INT64 m_iAdena; //branch121212
var INT64 m_iEventCoin;//branch121212
var bool	m_bCoinToMoney; //branch 110824
var float	m_fCoinMoneyValue; //branch 110824

var WindowHandle Me;
var TextBoxHandle TextCurCash;
var TextBoxHandle TextBalance;
var TextBoxHandle TextPrice;
var ButtonHandle BtnCancel;
var ButtonHandle BtnBuy;
var ButtonHandle BtnCharge;
var ButtonHandle BtnChange;
var TextureHandle TexPriceInfoBG;
var TextureHandle TexItemInfoBG;
var WindowHandle  BR_NewCashShopReceiverListWnd;
var EditBoxHandle ReceiverID;
var MultiEditBoxHandle PresentPostContents;
var EditBoxHandle EditBuyCount;

var WindowHandle ScrollItemInfo;
var int m_iCurrentHeight;
var DrawItemInfo m_kDrawInfoClear;

var DrawPanelHandle m_hDrawPanel;

const DIALOG_ONLY_NOTICE = 5555;							//아무동작도 안하는 알려주는 전용
const DIALOG_NOTIFY_SEND_PRESENTBUY = 4444;

const MAX_CHAR_LENGTH = 24;
const MAX_TITLE_LENGTH = 60;
const MAX_CONTENTS_LENGTH = 1000;

//캐쉬샵 공통 함수
var BR_CashShopAPI m_CashShopAPI;

function OnLoad()
{
	RegisterState( "BR_NewPresentBuyingWnd", "TRAININGROOMSTATE" );
	
	if (CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	m_bInConfirm = false;
	bOpenCashShopReceiverListWnd = false;
	m_iAmount = 1;			
				
	InitHandle();
	
	BtnChange.HideWindow();
	m_CashShopAPI = BR_CashShopAPI(GetScript("BR_CashShopAPI"));	
			
	ClearAll();	
}

function InitHandle()
{
	if (CREATE_ON_DEMAND==0) {
		Me = GetHandle( "BR_NewPresentBuyingWnd" );
		
		EditBuyCount = EditBoxHandle ( GetHandle( "BR_NewPresentBuyingWnd.EditBuyCount" ) );
		BtnChange = ButtonHandle ( GetHandle( "BR_NewPresentBuyingWnd.BtnChange" ) );
		
		BR_NewCashShopReceiverListWnd = GetHandle( "BR_NewCashShopReceiverListWnd" );
		TextCurCash = TextBoxHandle ( GetHandle( "BR_NewPresentBuyingWnd.TextCurCash" ) );
		TextBalance = TextBoxHandle ( GetHandle( "BR_NewPresentBuyingWnd.TextBalance" ) );
		TextPrice = TextBoxHandle ( GetHandle( "BR_NewPresentBuyingWnd.TextPrice" ) );		
		BtnCancel = ButtonHandle ( GetHandle( "BR_NewPresentBuyingWnd.BtnCancel" ) );
		BtnBuy = ButtonHandle ( GetHandle( "BR_NewPresentBuyingWnd.BtnBuy" ) );
		BtnCharge = ButtonHandle ( GetHandle( "BR_NewPresentBuyingWnd.BtnCharge" ) );
		
		TexPriceInfoBG = TextureHandle ( GetHandle( "BR_NewPresentBuyingWnd.TexPriceInfoBG" ) );
		TexItemInfoBG = TextureHandle ( GetHandle( "BR_NewPresentBuyingWnd.TexItemInfoBG" ) );
		ReceiverID=EditBoxHandle(GetHandle("BR_NewPresentBuyingWnd.ReceiverID"));
		PresentPostContents = MultiEditBoxHandle(GetHandle("BR_NewPresentBuyingWnd.PresentPostContents"));	
		
		ScrollItemInfo = GetHandle("BR_NewPresentBuyingWnd.ScrollItemInfo");	
	}
	else {
		Me = GetWindowHandle( "BR_NewPresentBuyingWnd" );
		EditBuyCount = GetEditBoxHandle ( "BR_NewPresentBuyingWnd.EditBuyCount" );
		BtnChange = GetButtonHandle ( "BR_NewPresentBuyingWnd.BtnChange" );
		
		BR_NewCashShopReceiverListWnd = GetWindowHandle( "BR_NewCashShopReceiverListWnd" );
		TextCurCash = GetTextBoxHandle ( "BR_NewPresentBuyingWnd.TextCurCash" );
		TextBalance = GetTextBoxHandle ( "BR_NewPresentBuyingWnd.TextBalance" );
		TextPrice = GetTextBoxHandle ( "BR_NewPresentBuyingWnd.TextPrice" );
		BtnCancel = GetButtonHandle ( "BR_NewPresentBuyingWnd.BtnCancel" );
		BtnBuy = GetButtonHandle ( "BR_NewPresentBuyingWnd.BtnBuy" );
		BtnCharge = GetButtonHandle ( "BR_NewPresentBuyingWnd.BtnCharge" );
		TexPriceInfoBG = GetTextureHandle ( "BR_NewPresentBuyingWnd.TexPriceInfoBG" );
		TexItemInfoBG = GetTextureHandle ( "BR_NewPresentBuyingWnd.TexItemInfoBG" );
		ReceiverID=GetEditBoxHandle("BR_NewPresentBuyingWnd.ReceiverID");		
		PresentPostContents = GetMultiEditBoxHandle("BR_NewPresentBuyingWnd.PresentPostContents");	
		
		ScrollItemInfo = GetWindowHandle("BR_NewPresentBuyingWnd.ScrollItemInfo");		
	}	
}

function OnRegisterEvent()
{
	RegisterEvent( EV_BR_SetPresentNewProductInfo );
	RegisterEvent( EV_BR_AddPresentEachProductInfo );
	
	RegisterEvent( EV_BR_PRESENT_SHOW_CONFIRM );
	RegisterEvent( EV_BR_PRESENT_HIDE_CONFIRM );
	RegisterEvent( EV_BR_SETGAMEPOINT );
	RegisterEvent( EV_BR_SETEVENTCOIN ); //branch121212
	RegisterEvent( EV_BR_RESULT_PRESENT_BUY_PRODUCT );
	RegisterEvent( EV_DialogOK );
}

function ClearAll()
{
	ReceiverID.SetString("");
	ReceiverID.SetMaxLength(MAX_CHAR_LENGTH);
	PresentPostContents.SetString("");
		
}

function OnClickButton( string Name )
{
	// debug("BR_NewPresentBuyingWnd Show Confirm " $ m_bInConfirm);
	
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
	case "CharacterReceiverListBtn":		
		OnReceiverListButton();
		break;
	case "CharacterNameResetBtn":
		OnReceiverIDReset();
		break;
	case "BtnChange":
		//OnBtnInputQuantity();
		break;
	}
}

function OnReceiverIDReset()
{
	ReceiverID.SetString("");
}

function PostListUpdate()
{
	debug("BR_NewPresentBuyingWnd PostListUpdate");
	class'PostWndAPI'.static.RequestFriendList();
	class'PostWndAPI'.static.RequestPledgeMemberList();
	class'PostWndAPI'.static.RequestPostFriendList();
}

function SetBoolCashShopReceiverList( bool b )
{
	local BR_NewCashShopReceiverListWnd Script;
	
	bOpenCashShopReceiverListWnd = b;
	
	if (bOpenCashShopReceiverListWnd == false)
	{	
		Script = BR_NewCashShopReceiverListWnd( GetScript( "BR_NewCashShopReceiverListWnd" ) );	
		Script.selectedInit();
		BR_NewCashShopReceiverListWnd.HideWindow();		
	}
}


function OnReceiverListButton()
{	
	local BR_NewCashShopReceiverListWnd Script;
	
	Script = BR_NewCashShopReceiverListWnd( GetScript( "BR_NewCashShopReceiverListWnd" ) );	

	bOpenCashShopReceiverListWnd = !bOpenCashShopReceiverListWnd;	
	
	debug("OnNewReceiverListButton OpenCashShopReceiverListWnd "$ bOpenCashShopReceiverListWnd);	
	if (bOpenCashShopReceiverListWnd)
	{	
		BR_NewCashShopReceiverListWnd.ShowWindow();
		PostListUpdate();
	}
	else 
	{	
		Script.selectedInit();
		BR_NewCashShopReceiverListWnd.HideWindow();		
	}		
}

function OnEvent(int Event_ID, string param)
{
	local int iResult;
	local int iCoinToMoney;
	
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
	case EV_BR_RESULT_PRESENT_BUY_PRODUCT :
		ParseInt(param, "Result", iResult );
		//ParseInt64(param, "GamePoint", m_iGamePoint);
		ResultBuy(iResult, m_iGamePoint);
		//RequestBR_GamePoint();
		break;
	case EV_BR_PRESENT_SHOW_CONFIRM :
		debug("EV_BR_PRESENT_SHOW_CONFIRM : " $ param);
		ParseInt(param, "ID", m_iProductID);
		ParseInt(param, "Price", m_iPrice);
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
		ShowPresentBuyWindow(true);
		m_bInConfirm = false;
		
		ClearItemInfo();
		RequestBR_ProductInfo(m_iProductID, true);						
		ClearAll();
		CalculateBalance();
		break;
	case EV_BR_SetPresentNewProductInfo :
		
		ParseInt(param, "ID", iId);
		ParseInt(param, "Price", price);
		ParseString(param, "ItemName", itemname);
		ParseString(param, "Desc", desc);
		
		ClearItemInfo();
		m_CashShopAPI.SetNewProductInfo(m_hDrawPanel, iID, price, itemname, desc);
		
		break;
	case EV_BR_AddPresentEachProductInfo :
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
		// debug("EV_DialogOK");
		if( HandleDialogOK() )
			return;		
		ShowPresentBuyWindow(false);
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
				EditBuyCount.SetString("" $ m_iAmount);	
			}
		}
		else if (id == DIALOG_NOTIFY_SEND_PRESENTBUY)
		{
			m_bInConfirm = true;			
			RequestBR_PresentBuyProduct(m_iProductID, m_iAmount, ReceiverID.GetString(), PresentPostContents.GetString());
			return true;
		}				
		else if( id == DIALOG_RESULT_FAILURE|| id == DIALOG_RESULT_SUCCESS )
		{
			ShowPresentBuyWindow(false);
			m_bInConfirm = false;				
			RequestBR_ProductList(BRCSP_PRODUCT);	
			RequestBR_ProductList(BRCSP_BASKET);	
			RequestBR_ProductList(BRCSP_RECENT);	// 최근구매목록		
		}
	}	
	debug("HandleDialogOK false");
	return false;
}


function OnHide()
{
	DialogHide();

	ExecuteEvent(EV_BR_PRESENT_HIDE_CONFIRM);
	PlaySound("InterfaceSound.inventory_close_01");
		
	m_bInConfirm = false;
}

function OnShow()
{
	CalculateBalance();
	
	ReceiverID.Setfocus();
}

function OnChangeEditBox( String strID )
{	
	local string strCount;
	
	//debug("OnchangeEditBox : " $ strID);
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

function OnBtnCancelClick()
{
	ShowPresentBuyWindow(false);	
	m_bInConfirm = false;	
}

function OnBtnBuyClick()
{
	if (Len(PresentPostContents.GetString()) > MAX_CONTENTS_LENGTH)
	{
		DialogHide();	// 이미 창이 떠있다면 지워준다.
		DialogShow(DialogModalType_Modalless,DialogType_Notice, GetSystemMessage(3076), string(Self));		
		DialogSetID(DIALOG_ONLY_NOTICE);
	}
	else if (Len(ReceiverID.GetString()) > MAX_CHAR_LENGTH)
	{
		DialogHide();	// 이미 창이 떠있다면 지워준다.
		DialogShow(DialogModalType_Modalless,DialogType_Notice, GetSystemMessage(3074), string(Self));		
		DialogSetID(DIALOG_ONLY_NOTICE);
	}	
	else if (m_iProductID > 0 && m_iAmount > 0) 
	{
		DialogHide();
		DialogShow(DialogModalType_Modal,DialogType_OKCancel, MakeFullSystemMsg( GetSystemMessage(6064), ReceiverID.GetString() ), string(Self));
		DialogSetID(DIALOG_NOTIFY_SEND_PRESENTBUY);
	
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
		DialogShow( DialogModalType_Modal, DialogType_OK, GetSystemMessage(6071), string(Self) );
	}
	else
	{
		sysmeg = m_CashShopAPI.ErrorResultBuy(iResult);
		
		DialogSetID( DIALOG_RESULT_FAILURE );
		DialogSetDefaultOK();
		DialogShow( DialogModalType_Modal, DialogType_OK, sysmeg, string(Self) );
	}
}

function ShowPresentBuyWindow(bool bShow)
{
	m_bDrawBg = true;
	
	debug("BR_NewPresentBuyingWnd Show Confirm " $ bShow);
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
		SetBoolCashShopReceiverList( false );
	}
}

function OnKeyUp( WindowHandle a_WindowHandle, EInputKey nKey )
{
	if(nKey == EInputKey.IK_Tab)
	{
		if (ReceiverID.IsFocused())
		{
			PresentPostContents.Setfocus();
		}		
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
	EditBuyCount.SetString("" $ m_iAmount);		
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
