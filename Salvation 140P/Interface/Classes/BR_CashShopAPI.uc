class BR_CashShopAPI extends UICommonAPI;

//branch121212
const	CASHSHOPPAYMENTTYPE_CASH			=	0;	
const 	CASHSHOPPAYMENTTYPE_ADENA			=	1;	
const	CASHSHOPPAYMENTTYPE_EVENTCOIN		=	2;	
//end of branch

const ITEM_INFO_WIDTH = 256;
const DRAWPANEL_ITEM_INFO_WIDTH = 208;

var DrawItemInfo m_kDrawInfoClear;
var array<string> m_UI_prime_panel_Main; 
var array<string> m_UI_prime_panel_Item; 

var bool	m_bCoinToMoney; //branch 110824
var bool	m_bPresent; //branch 110824
var float	m_fCoinMoneyValue; //branch 110824

var array< ProductInfo >	m_ProductList;

var array< ProductInfo >	m_RecentList; //최근구매
var array< ProductInfo >	m_BasketList; //장바구니

var bool m_bOpenBuyWnd;

const DAY_SUN = 0x00000001;
const DAY_MON = 0x00000002;
const DAY_TUE = 0x00000004;
const DAY_WED = 0x00000008;
const DAY_THU = 0x00000010;
const DAY_FRI = 0x00000020;
const DAY_SAT = 0x00000040;

//0:일반 1:이벤트 2:세일 3:신규 4:인기
enum EPreItemPanelType
{
	PIPT_EVENT,
	PIPT_SALE,	
	PIPT_NEW,	
	PIPT_STAR,
	PIPT_MAX,		
};

function OnRegisterEvent()
{
	RegisterEvent( EV_BR_CashShopAddItem );
	RegisterEvent( EV_BR_CashShopAddProductItem );	
	
	RegisterEvent( EV_BR_SetRecentProduct );
	RegisterEvent( EV_BR_SetNewList );
	RegisterEvent( EV_BR_SetBasketProduct );	
		
	RegisterEvent( EV_BR_AddBasketProductItem );		
	RegisterEvent( EV_BR_AddRecentProductItem );	
	
	RegisterEvent( EV_BR_RecentProductListEnd );		
	
}

function OnLoad()
{
	
	m_bCoinToMoney = IsBr_CashShopCoinToMoney(); //branch 110824
	if( m_bCoinToMoney )
	{
		m_fCoinMoneyValue = GetBr_CashShopCoinToMoneyValue();		
	}
	m_bPresent = IsBr_CashShopPresent();
	
	m_ProductList.Length = 0;
	m_RecentList.Length = 0;
	m_BasketList.Length = 0;
	m_bOpenBuyWnd = false;
	
	m_UI_prime_panel_Main.Length = ConvertPreItemPanelType(PIPT_MAX); 
	m_UI_prime_panel_Item.Length = ConvertPreItemPanelType(PIPT_MAX); 
	
	m_UI_prime_panel_Main[ConvertPreItemPanelType(PIPT_EVENT)] = "BranchSys3.ui.g_ui_prime_panel_event"; 
	m_UI_prime_panel_Main[ConvertPreItemPanelType(PIPT_SALE)] = "BranchSys3.ui.g_ui_prime_panel_sale"; 
	m_UI_prime_panel_Main[ConvertPreItemPanelType(PIPT_NEW)] = "BranchSys3.ui.g_ui_prime_panel_new"; 
	m_UI_prime_panel_Main[ConvertPreItemPanelType(PIPT_STAR)] = "BranchSys3.ui.g_ui_prime_panel_best"; 
	
	m_UI_prime_panel_Item[ConvertPreItemPanelType(PIPT_EVENT)] = "BranchSys3.ui.g_ui_prime_panel_event_s"; 	
	m_UI_prime_panel_Item[ConvertPreItemPanelType(PIPT_SALE)] = "BranchSys3.ui.g_ui_prime_panel_sale_s"; 	
	m_UI_prime_panel_Item[ConvertPreItemPanelType(PIPT_NEW)] = "BranchSys3.ui.g_ui_prime_panel_new_s"; 
	m_UI_prime_panel_Item[ConvertPreItemPanelType(PIPT_STAR)] = "BranchSys3.ui.g_ui_prime_panel_best_s"; 
}

function bool GetOpenBuyWnd()
{
	return m_bOpenBuyWnd;
}

function SetOpenBuyWnd(bool open)
{
	m_bOpenBuyWnd = open;
}


function ClearItemList(int allclear)
{
	if (allclear > 0)
	{
		m_ProductList.Length = 0;
	}	
}

function ClearBasketItemList()
{
	local int i;
	
	m_BasketList.Length = 0;
			
	for (i=0; i < m_ProductList.Length; i++)
	{
		m_ProductList[i].bMyShopBasketEnable = false;
	}
}

function ClearRecentList()
{
	m_RecentList.Length = 0;
}

function OnEvent(int Event_ID, string param)
{
	local int iResult;
	local int iProductType;
	
	switch( Event_ID )
	{
	case EV_BR_CashShopAddItem :
		AddProductItem(BRCSP_PRODUCT,param);
		break;	
	case EV_BR_CashShopAddProductItem :
		AddProductItemData(BRCSP_PRODUCT,param);
		break;	
	case EV_BR_SetRecentProduct:
		AddProductItem(BRCSP_RECENT,param);
		break;
	case EV_BR_SetBasketProduct:
		AddProductItem(BRCSP_BASKET,param);
		break;	
	case EV_BR_AddRecentProductItem :
		AddProductItemData(BRCSP_RECENT,param);
		break;	
	case EV_BR_AddBasketProductItem :
		AddProductItemData(BRCSP_BASKET,param);
		break;		
	case EV_BR_SetNewList :
		ParseInt(param, "Option", iResult );
		ParseInt(param, "ProductType", iProductType );				
		if( iProductType == 0 ) //BR_Product
		{
			ClearItemList(1);
		}
		else if( iProductType == 1 )//BR_Recent
		{
			ClearRecentList();
		}
		else if( iProductType == 2 )//BR_Basket
		{
			ClearBasketItemList();
		}
		break;	
	default:
			break;
	}
}

function array< ProductInfo > GetBasketProductList()
{
	return m_BasketList;	
}

function array< ProductInfo > GetRecentProductList()
{
	return m_RecentList;
}

function int ProductListCount()
{
	return m_ProductList.Length;
}

function ProductInfo ArrayProductItem(int index)
{
	return m_ProductList[index];
}

function bool UpdateBasketProductItem(ButtonHandle a_ButtonHandle, int ProductID, bool BasketCheck)
{
	local int SelectedProductID;
	
	SetBasketProductItem(ProductID,BasketCheck);
	SelectedProductID = a_ButtonHandle.GetButtonValue();		
	
	if( SelectedProductID < 0 ) //branch120703
		return false;
	
	if( SelectedProductID == ProductID )
	{		
		UpdateBasketProductWindow(a_ButtonHandle, BasketCheck); 			
		return true;
	}		
 		
	return false;
}

function DeleteBasketProductItem(int ProductID)
{
	local int i;
	for (i = 0; i < m_BasketList.Length; i++)
	{
		if (m_BasketList[i].iProductID == ProductID)
		{
			m_BasketList.Remove(i, 1);		
			SetBasketProductItem(ProductID, false);	
			break;
		}
	}	
}

function SetBasketProductItemData()
{
	local int i;
	local ProductInfo ProductItem;
	
	for (i=0; i < m_ProductList.Length; i++)
	{
		ProductItem = GetBasketProductItem(m_ProductList[i].iProductID);
		if ( ProductItem.iProductID > 0 ) 
		{
			m_ProductList[i].bMyShopBasketEnable = true;
		}
	}
}

function SetBasketProductItem(int id, bool enable)
{
	local int i;
	
	for (i=0; i < m_ProductList.Length; i++)
	{
		if ( m_ProductList[i].iProductID == id ) 
		{
			m_ProductList[i].bMyShopBasketEnable = enable;
		}
	}
}

function AddMyShopBasketProductItem(int id)
{
	local int iCurrentIndex;
	local ProductInfo ProductItem;
	
	ProductItem = GetBasketProductItem(id);
	
	if(ProductItem.iProductID < 0 )
	{
		ProductItem = GetProductItem(id);
	
		iCurrentIndex = m_BasketList.Length;
		m_BasketList.Length = iCurrentIndex + 1;
		
		m_BasketList[iCurrentIndex] = ProductItem;
	}
			
	debug("m_BasketList Count" $ m_BasketList.Length);	
}

function ProductInfo GetProductItem(int id)
{
	local int i;
	local ProductInfo ProductItem;
	ProductItem.iProductID = -1;

	for (i=0; i < m_ProductList.Length; i++)
	{
		if (m_ProductList[i].iProductID == id) 
		{
			return m_ProductList[i];
		}
	}
	
	return ProductItem;
}


function ProductInfo GetBasketProductItem(int id)
{
	local int i;
	local ProductInfo ProductItem;
	ProductItem.iProductID = -1;

	for (i=0; i < m_BasketList.Length; i++)
	{
		if (m_BasketList[i].iProductID == id) 
		{
			return m_BasketList[i];
		}
	}
	
	return ProductItem;
}




function AddProductItem(EBR_CashShopProduct type, string param)
{
	local int iId, category, paymenttype, itempaneltype, showtab, price;//branch121212
	local string itemname, iconname, desc, mainsubject;
	local int start_sale, end_sale, salepercent, minlevel;
	local int maxlevel, minbirthday, maxbirthday, restrictionday, availablecount; //branch121212
	local int day_week, start_hour, start_min, end_hour, end_min, stock, max_stock;
	
	local int iCurrentIndex;
	
	local ProductInfo ProductItem;
	
	ParseInt(param, "ID", iId);
	ParseInt(param, "Category", category);
	ParseInt(param, "PaymentType", paymenttype); //branch121212
	ParseInt(param, "ShowTab", showtab);
	ParseInt(param, "Price", price);
	ParseInt(param, "ItemPanelType", itempaneltype);
	ParseString(param, "ItemName", itemname);
	ParseString(param, "IconName", iconname);

	ParseInt(param, "StartSale", start_sale);
	ParseInt(param, "EndSale", end_sale);
	
	ParseInt(param, "DayWeek", day_week);
	ParseInt(param, "StartHour", start_hour);
	ParseInt(param, "StartMin", start_min);
	ParseInt(param, "EndHour", end_hour);
	ParseInt(param, "EndMin", end_min);
	ParseInt(param, "Stock", stock);
	ParseInt(param, "MaxStock", max_stock);
	ParseInt(param, "SalePercent", salepercent);
	ParseInt(param, "MinLevel", minlevel);
	
	//branch121212
	ParseInt(param, "MaxLevel", maxlevel);
	ParseInt(param, "MinBirthday", minbirthday);
	ParseInt(param, "MaxBirthday", maxbirthday);
	ParseInt(param, "RestrictionDay", restrictionday);
	ParseInt(param, "AvailableCount", availablecount);
	
	ParseString(param, "Desc", desc);
	
	

	ProductItem.iProductID = iId;
	ProductItem.iCategory = category;
	ProductItem.iPaymentType = paymenttype; //branch121212
	ProductItem.iShowTab = showtab;
	ProductItem.iPanel_Type = itempaneltype;
	ProductItem.iSale_Percent = salepercent;
	ProductItem.iPrice = price;
	ProductItem.strName = itemname;
	ProductItem.strIconName = iconname;
	
	ProductItem.iStartSale = start_sale;
	ProductItem.iEndSale = end_sale;
	
	ProductItem.iDayWeek = day_week;
	ProductItem.iStartHour = start_hour;
	ProductItem.iStartMin = start_min;
	ProductItem.iEndHour = end_hour;
	ProductItem.iEndMin = end_min;
	ProductItem.iStock = stock;
	ProductItem.iMaxStock = max_stock;
	ProductItem.bMyShopBasketEnable = false;
	ProductItem.iMinLevel = minlevel;
	
	//branch121212
	ProductItem.iMaxLevel = maxlevel;
	ProductItem.iMinBirthday = minbirthday;
	ProductItem.iMaxBirthday = maxbirthday;
	ProductItem.iRestrictionDay = restrictionday;
	ProductItem.iAvailableCount = availablecount;
	
	
	debug("===============add recent : "$ type $" " $ iCurrentIndex $ "," $ m_RecentList.Length);
	ProductItem.bLimited = false;
	if ( !(start_hour==0 && start_min==0 && end_hour==23 && end_min==59) || day_week != 127 
		|| BR_GetDayType(end_sale, 0) < 2037 )
		ProductItem.bLimited = true;
		
	ProductItem.bEnable = false;	
	ProductItem.strDesc = desc;
	
	if( type == BRCSP_PRODUCT )
	{
		ParseString(param, "MainSubject", mainsubject);
		ProductItem.strMainSubject = mainsubject;
		
		iCurrentIndex = m_ProductList.Length;
		m_ProductList.Length = iCurrentIndex + 1;
		m_ProductList[iCurrentIndex] = ProductItem;				
	}
	else if( type == BRCSP_RECENT )
	{
		iCurrentIndex = m_RecentList.Length;
		m_RecentList.Length = iCurrentIndex + 1;
		m_RecentList[iCurrentIndex] = ProductItem;
	}	
	else if( type == BRCSP_BASKET )
	{
		ProductItem.bMyShopBasketEnable = true;
		
		iCurrentIndex = m_BasketList.Length;
		m_BasketList.Length = iCurrentIndex + 1;
		m_BasketList[iCurrentIndex] = ProductItem;		
	}
}


function AddProductItemData(EBR_CashShopProduct type,string param)
{
	local int iId;	
	local int iAmount;	
	local int weight;	
	local int trade;
	local string desc;	
	
	local int iCurrentIndex;
	local int iitemIndex;
	local ProductItem item;
	
	ParseInt(param, "ID", iId );
	ParseInt(param, "Amount", iAmount );	
	ParseInt(param, "Weight", weight );
	ParseInt(param, "Trade", trade );
	ParseString(param, "Desc", desc);
	
	item.iItemID = iId;
	item.iAmount = iAmount;
	item.iWeight = weight;
	item.iTradable = trade;	
	item.strDesc = desc;
	
	if( type == BRCSP_PRODUCT )
	{		
		iCurrentIndex = m_ProductList.Length - 1;
		iitemIndex = m_ProductList[iCurrentIndex].itemarray.Length;
		m_ProductList[iCurrentIndex].itemarray.Length = iitemIndex + 1;
		m_ProductList[iCurrentIndex].itemarray[iitemIndex] = item;
	}
	else if( type == BRCSP_RECENT )	
	{
		iCurrentIndex = m_RecentList.Length - 1;
		iitemIndex = m_RecentList[iCurrentIndex].itemarray.Length;
		m_RecentList[iCurrentIndex].itemarray.Length = iitemIndex + 1;
		m_RecentList[iCurrentIndex].itemarray[iitemIndex] = item;
		
	}
	else if( type == BRCSP_BASKET )		
	{
		iCurrentIndex = m_BasketList.Length - 1;
		iitemIndex = m_BasketList[iCurrentIndex].itemarray.Length;
		m_BasketList[iCurrentIndex].itemarray.Length = iitemIndex + 1;
		m_BasketList[iCurrentIndex].itemarray[iitemIndex] = item;
	}				
	
}

function OnBtnBuyClick(int ProductID)
{
	//local int i;
	local string strParam;
	local ProductInfo ProductItem;
	
	ProductItem = GetProductItem(ProductID);
	
	if (ProductItem.iProductID > 0) {
		ParamAdd(strParam, "ID", string(ProductID));
		ParamAdd(strParam, "Price", string(ProductItem.iPrice));
		ParamAdd(strParam, "PaymentType", string(ProductItem.iPaymentType)); //branch121212
		ParamAdd(strParam, "ItemName", ProductItem.strName);
		ParamAdd(strParam, "IconName", ProductItem.strIconName);		
		if( m_bCoinToMoney )
		{
			ParamAdd(strParam, "CoinToMoney", string(1) );
			ParamAdd(strParam, "CoinToMoneyValue", string(m_fCoinMoneyValue) );
		}	
		else
		{
			ParamAdd(strParam, "CoinToMoney", string(0) );
		}	
		ExecuteEvent(EV_BR_SHOW_CONFIRM, strParam);
	}
}

//branch110706
function OnBtnPresentClick(int ProductID)
{
	//local int i;
	local string strParam;
	local ProductInfo ProductItem;
	
	ProductItem = GetProductItem(ProductID);
	
	if (ProductItem.iProductID > 0) {
		ParamAdd(strParam, "ID", string(ProductID));
		ParamAdd(strParam, "Price", string(ProductItem.iPrice));
		ParamAdd(strParam, "ItemName", ProductItem.strName);
		ParamAdd(strParam, "IconName", ProductItem.strIconName);		
		if( m_bCoinToMoney )
		{
			ParamAdd(strParam, "CoinToMoney", string(1) );
			ParamAdd(strParam, "CoinToMoneyValue", string(m_fCoinMoneyValue) );
		}	
		else
		{
			ParamAdd(strParam, "CoinToMoney", string(0) );
		}	
		ExecuteEvent(EV_BR_PRESENT_SHOW_CONFIRM, strParam);
	}
}
//end of branch

function InitMainProductWindow(WindowHandle itemwnd)
{
	local ButtonHandle btnCashItemIcon; 	 	
	local ButtonHandle btngo; 	 
	local TextureHandle TexPanel;		
	local TextureHandle TexSoldOut;	
	local TextBoxHandle TextCount; 	
 	 	 	
 	TexPanel = TextureHandle( itemwnd.GetChildWindow("TexPanel") );
 	TexPanel.HideWindow();
 	 	
 	btngo = ButtonHandle( itemwnd.GetChildWindow("BtnGo") ); 	
 	btngo.HideWindow();
 		
 	btnCashItemIcon = ButtonHandle( itemwnd.GetChildWindow("EventCashItem") );
 	if( btnCashItemIcon != None )
 	{
 		btnCashItemIcon.HideWindow(); 		
 	}
 	
	TexSoldOut = TextureHandle( itemwnd.GetChildWindow("TexSoldOut") );
 	TextCount = TextBoxHandle( itemwnd.GetChildWindow("TextCount") );		
 	TextCount.HideWindow();
	TexSoldOut.HideWindow();	
}

function SetMainProductWindow(WindowHandle itemwnd, ProductInfo info)
{
	local ButtonHandle btnCashItemIcon; 	 	
	local ButtonHandle btngo; 	 
	local TextureHandle TexPanel;		
	local TextureHandle TexSoldOut;	
	local TextBoxHandle TextCount; 	
 	local DrawPanelHandle drawpanel;
 	local TextBoxHandle descdrawpanel;
 	local DrawItemInfo kDrawInfo;
 	local string strCount;
 	local string strTemp;
 	
 	TexPanel = TextureHandle( itemwnd.GetChildWindow("TexPanel") );
	if(info.iPanel_Type > 0 && info.iPanel_Type <= ConvertPreItemPanelType(PIPT_MAX) )
	{		
		TexPanel.SetTexture(m_UI_prime_panel_Main[info.iPanel_Type - 1]);		
		TexPanel.ShowWindow();
	}	
	else
	{
		TexPanel.HideWindow();
	}
	
		 	 
 	drawpanel = DrawPanelHandle( itemwnd.GetChildWindow("CashItemDrawPanel") );
 	drawpanel.Clear();
 	 	 	
 	if( drawpanel == None )
 		return;
 	
 	btngo = ButtonHandle( itemwnd.GetChildWindow("BtnGo") );
 	btngo.SetButtonValue(info.iProductID); 	 	
 	btngo.ShowWindow();
 		
 	btnCashItemIcon = ButtonHandle( itemwnd.GetChildWindow("EventCashItem") );
 	if( btnCashItemIcon != None )
 	{
 		btnCashItemIcon.ShowWindow(); 
 		btnCashItemIcon.SetTexture(info.strIconName,info.strIconName,info.strIconName);
 		btnCashItemIcon.ClearTooltip();
 		SetTooltipProductInfo(btnCashItemIcon, info);  		 		
 		btnCashItemIcon.SetTooltipCalculateSize(ITEM_INFO_WIDTH);
 	}
 	 		
 	MakeDrawPanelInfo_Desc(kDrawInfo, info.strName, 227, 197, 80, 200);
	drawpanel.InsertDrawItem(kDrawInfo);
	
	// 가격
	strTemp = SetPaymentType(info.iPaymentType, info.iPrice);
// 	if( m_bCoinToMoney )
// 	{
// 		priceMoney = float(info.iPrice) * m_fCoinMoneyValue;
// 		strTemp =  (priceMoney) $ " " $ GetSystemString(5012);
// 	}
// 	else
// 	{
// 		strTemp =  info.iPrice $ " " $ GetSystemString(5012);
// 	}
	MakeDrawInfo_Text(kDrawInfo, strTemp, 220, 220, 220);
	kDrawInfo.bLineBreak = true;
	kDrawInfo.nOffSetY = 6;
	drawpanel.InsertDrawItem(kDrawInfo);	
	
	SeTimeLimitInfo(drawpanel, info); //한정판매
	
	drawpanel.SetMiddleAlign(true,200);
	
	descdrawpanel = TextBoxHandle( itemwnd.GetChildWindow("TextCashItemDescDrawPanel") );
	descdrawpanel.SetText(info.strMainSubject);
 		
	//MakeDrawPanelInfo_Desc(kDrawInfo, info.strMainSubject, 220, 220, 220, 275);
	//descdrawpanel.InsertDrawItem(kDrawInfo);
	
	//descdrawpanel.SetMiddleAlign(true,260);
	
	TexSoldOut = TextureHandle( itemwnd.GetChildWindow("TexSoldOut") );
 	TextCount = TextBoxHandle( itemwnd.GetChildWindow("TextCount") );		
	//무한대
	if( info.iStock < 0 )
	{		
		TextCount.HideWindow();
		TexSoldOut.HideWindow();
	}
	else if( info.iStock == 0 )
	{
		TexSoldOut.ShowWindow();
		TextCount.ShowWindow();
		strCount = GetSystemString(5027) $ " : " $ 0;
		TextCount.SetText(strCount);
	}
	else
	{
		TextCount.ShowWindow();			
		//strCount = GetSystemString(5027) $ " : " $ info.iStock;
		strCount = GetSystemString(5027) $ " : " $ info.iStock;
		TextCount.SetText(strCount);
		TexSoldOut.HideWindow();
	} 
}

function UpdateBasketProductWindow(ButtonHandle childBtnBasket, bool bMyShopBasketEnable)
{		
	if( bMyShopBasketEnable )
	{
		childBtnBasket.SetTexture("BranchSys3.UI.button_favorite_on","BranchSys3.UI.button_favorite_on","BranchSys3.UI.button_favorite_on");
	}
	else
	{
		childBtnBasket.SetTexture("BranchSys3.UI.button_favorite_off","BranchSys3.UI.button_favorite_off","BranchSys3.UI.button_favorite_off");
	}
}

function SetViewProductWindow(WindowHandle itemwnd, ProductInfo info, bool bMyShop, bool visableBasket)
{
 	local ButtonHandle btnCashItemIcon; 	
 	local ButtonHandle childBtnBuy;
 	local ButtonHandle childBtnPresent;
 	local ButtonHandle childBtnBasket;
 	local TextureHandle TexPanel;
 	local TextureHandle TexSoldOut;	 	
 	local DrawPanelHandle drawpanel;
 	local DrawItemInfo kDrawInfo;
 	local TextBoxHandle TextCount; 	
 	local TextBoxHandle TextPoint;
 	local string strCount;
 	local string strTemp;
 	 
 	drawpanel = DrawPanelHandle( itemwnd.GetChildWindow("CashItemDrawPanel") );
 	drawpanel.Clear();
 	
 	if( drawpanel == None )
 		return;
 		
 	TexPanel = TextureHandle( itemwnd.GetChildWindow("TexPanel") );
 		
 	if(info.iPanel_Type > 0 && info.iPanel_Type <= ConvertPreItemPanelType(PIPT_MAX) )
	{		
		TexPanel.SetTexture(m_UI_prime_panel_Item[info.iPanel_Type - 1]);
		TexPanel.ShowWindow();			
	}
	else
	{
		TexPanel.HideWindow();		
	}
	
 	childBtnBuy = ButtonHandle( itemwnd.GetChildWindow("BtnBuy") );
 	childBtnBuy.SetButtonValue(info.iProductID);
 	
 	childBtnPresent = ButtonHandle( itemwnd.GetChildWindow("BtnPresent") );
 	childBtnPresent.SetButtonValue(info.iProductID);
 	childBtnPresent.SetEnable(m_bPresent);
 	
 	
 	if( bMyShop )
 	{
 		childBtnBasket = ButtonHandle( itemwnd.GetChildWindow("BtnDelete") ); 		
 	}
 	else
 	{
 		childBtnBasket = ButtonHandle( itemwnd.GetChildWindow("BtnBasket") );
 	} 	
 	childBtnBasket.SetButtonValue(info.iProductID);
 	 		
 	btnCashItemIcon = ButtonHandle( itemwnd.GetChildWindow("CashItemIcon") );
 	if( btnCashItemIcon != None )
 	{
 		btnCashItemIcon.SetTexture(info.strIconName,info.strIconName,info.strIconName);
 		btnCashItemIcon.ClearTooltip();
 		SetTooltipProductInfo(btnCashItemIcon, info);  		 		
 		btnCashItemIcon.SetTooltipCalculateSize(ITEM_INFO_WIDTH);
 	}
 	 		
 	MakeDrawPanelInfo_Desc(kDrawInfo, info.strName, 220,220,220, DRAWPANEL_ITEM_INFO_WIDTH);
 	kDrawInfo.nOffSetY = 5;
	drawpanel.InsertDrawItem(kDrawInfo);

	//branch121212
	TextPoint = TextBoxHandle( itemwnd.GetChildWindow("TextPoint") );
	
// 	CASHSHOPPAYMENTTYPE_CASH			=	0;	
// 	CASHSHOPPAYMENTTYPE_ADENA			=	57;	
// 	CASHSHOPPAYMENTTYPE_EVENTCOIN		=	23805;	

	strTemp = SetPaymentType(info.iPaymentType, info.iPrice);
	
// 	if(info.iPaymentType == CASHSHOPPAYMENTTYPE_CASH)
// 	{
// 		if( m_bCoinToMoney )
// 		{
// 			priceMoney = float(info.iPrice) * m_fCoinMoneyValue;
// 			strTemp = (priceMoney) $ " " $ GetSystemString(5012);
// 		}
// 		else
// 		{
// 			strTemp = info.iPrice $ " " $ GetSystemString(5012);
// 		}
// 	}
// 	else if(info.iPaymentType == CASHSHOPPAYMENTTYPE_ADENA)
// 	{
// 		strTemp = info.iPrice $ " " $ GetSystemString(469);
// 	}
// 	else if(info.iPaymentType == CASHSHOPPAYMENTTYPE_EVENTCOIN)
// 	{
// 		strTemp = info.iPrice $ " " $ GetSystemString(5179);
// 	}
	
	TextPoint.SetText(strTemp);
	//end of branch
	// 가격	
	
	TexSoldOut = TextureHandle( itemwnd.GetChildWindow("TexSoldOut") );
 	TextCount = TextBoxHandle( itemwnd.GetChildWindow("TextCount") );		
	//무한대
	if( info.iStock < 0 )
	{		
		TextCount.HideWindow();
		TexSoldOut.HideWindow();
		childBtnBuy.ShowWindow();
 		childBtnPresent.ShowWindow();
 		childBtnBasket.ShowWindow(); 
	}
	else if( info.iStock == 0 )
	{
		TexSoldOut.ShowWindow();
		TextCount.ShowWindow();
		strCount = GetSystemString(5027) $ " : " $ 0;
		TextCount.SetText(strCount);
		childBtnBuy.HideWindow();
 		childBtnPresent.HideWindow();
 		childBtnBasket.HideWindow(); 		
	}
	else
	{
		TextCount.ShowWindow();			
		//strCount = GetSystemString(5027) $ " : " $ info.iStock;
		strCount = GetSystemString(5027) $ " : " $ info.iStock;
		TextCount.SetText(strCount);
		TexSoldOut.HideWindow();
		childBtnBuy.ShowWindow();
 		childBtnPresent.ShowWindow();
 		childBtnBasket.ShowWindow(); 
	} 
	
	if( visableBasket ) 
 	{
 		childBtnBasket.ShowWindow();
 		if( bMyShop == false )
 		{
 			UpdateBasketProductWindow(childBtnBasket, info.bMyShopBasketEnable); 			
 		} 		
 	}
 	else
 	{
 		childBtnBasket.HideWindow(); 		
 	}
	
	SeTimeLimitInfo(drawpanel, info); //한정판매
	
	if(info.iPaymentType == CASHSHOPPAYMENTTYPE_CASH && info.iAvailableCount <= 0) //계정당 구매제한이 있으면 선물막기
	{
		childBtnPresent.SetEnable(true);
 		//childBtnBasket.HideWindow(); 
	}
	else 
	{		
		childBtnPresent.SetEnable(false);
 		//childBtnBasket.HideWindow(); 
	}
	
	//drawpanel.SetMiddleAlign(true,DRAWPANEL_ITEM_INFO_WIDTH);
}

//한정판매 정보
function SeTimeLimitInfo(DrawPanelHandle wnd,ProductInfo kProductInfo)
{	
	local string strTemp;
	local DrawItemInfo kDrawInfo;
	local int bTimeLimit;
		
	if (kProductInfo.iProductID >= 0) 
	{
		kDrawInfo.bLineBreak = true;
		kDrawInfo.nOffSetY = 2;
		
		bTimeLimit = 0;
		if (!(kProductInfo.iStartHour==0 && kProductInfo.iStartMin==0 && kProductInfo.iEndHour==23 && kProductInfo.iEndMin==59)) 
		{
			bTimeLimit = 1;
		}
		
		//branch121212 //캐릭터 생성일
		if( kProductInfo.iRestrictionDay >= 1 && kProductInfo.iAvailableCount >= 1 ) // 몇 일 몇개 한정
		{
			//strTemp = "" $ kProductInfo.iRestrictionDay $ "" $ GetSystemString(5152) $ " " $ kProductInfo.iAvailableCount $ "" $ GetSystemString(5131) ;
			strTemp  = MakeFullSystemMsg(GetSystemMessage(6164), string(kProductInfo.iRestrictionDay), string(kProductInfo.iAvailableCount) );
			MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
			kDrawInfo.bLineBreak = true;
			kDrawInfo.nOffSetY = 2;
			wnd.InsertDrawItem(kDrawInfo);	
		}		
		else if( kProductInfo.iRestrictionDay < 0 && kProductInfo.iAvailableCount >= 1 ) // 개수 한정
		{
			//strTemp = GetSystemString(5151) $ " " $ kProductInfo.iAvailableCount $ "" $ GetSystemString(5131) ;
			strTemp  = MakeFullSystemMsg(GetSystemMessage(6165), string(kProductInfo.iAvailableCount), "" );
			MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
			kDrawInfo.bLineBreak = true;
			kDrawInfo.nOffSetY = 2;
			wnd.InsertDrawItem(kDrawInfo);	
		}		
		else if( kProductInfo.iMinBirthday > 0 || kProductInfo.iMaxBirthday > 0 ) //캐릭터 생성일
		{
			strTemp = GetSystemString(5149)  ;
			MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
			kDrawInfo.bLineBreak = true;
			kDrawInfo.nOffSetY = 2;
			wnd.InsertDrawItem(kDrawInfo);	
		}				
		else if( kProductInfo.iMinLevel > 0 || kProductInfo.iMaxLevel > 0 ) //레벨제한
		{
			if( kProductInfo.iMinLevel > 0 && kProductInfo.iMaxLevel > kProductInfo.iMinLevel )
			{
				strTemp = "" $ kProductInfo.iMinLevel $ "" $ GetSystemString(537) $ " ~ " $ kProductInfo.iMaxLevel $ "" $ GetSystemString(537) ;
				MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
				kDrawInfo.bLineBreak = true;
				kDrawInfo.nOffSetY = 2;
				wnd.InsertDrawItem(kDrawInfo);	
			}
			else if( kProductInfo.iMinLevel == kProductInfo.iMaxLevel )
			{
				strTemp = "" $ kProductInfo.iMinLevel $ "" $ GetSystemString(537) ;
				MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
				kDrawInfo.bLineBreak = true;
				kDrawInfo.nOffSetY = 2;
				wnd.InsertDrawItem(kDrawInfo);	
			}
			else if( kProductInfo.iMinLevel > 0 )
			{
				
				//strTemp = "" $ kProductInfo.iMinLevel $ "" $ GetSystemString(5146) ;
				strTemp = MakeFullSystemMsg(GetSystemMessage(6170), string(kProductInfo.iMinLevel), "" );
				MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
				kDrawInfo.bLineBreak = true;
				kDrawInfo.nOffSetY = 2;
				wnd.InsertDrawItem(kDrawInfo);	
			}
			else if( kProductInfo.iMaxLevel > 0 )
			{
				//strTemp = "" $ kProductInfo.iMaxLevel $ "" $ GetSystemString(5182) ;
				strTemp = MakeFullSystemMsg(GetSystemMessage(6171), string(kProductInfo.iMaxLevel), "" );
				MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
				kDrawInfo.bLineBreak = true;
				kDrawInfo.nOffSetY = 2;
				wnd.InsertDrawItem(kDrawInfo);	
			}			
		}		
		else if (bTimeLimit!=0) 
		{
			strTemp = "" $ ZERO_STR(kProductInfo.iStartHour) $ kProductInfo.iStartHour $ ":" 
						$ ZERO_STR(kProductInfo.iStartMin) $ kProductInfo.iStartMin $ "~" 
						$ ZERO_STR(kProductInfo.iEndHour) $ kProductInfo.iEndHour $ ":" 
						$ ZERO_STR(kProductInfo.iEndMin) $ kProductInfo.iEndMin;
			MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);	
			kDrawInfo.bLineBreak = true;
			kDrawInfo.nOffSetY = 2;		
			wnd.InsertDrawItem(kDrawInfo);
		}			
		else if (kProductInfo.iDayWeek != 127) 
		{
			
			strTemp = "" $ ConvertBRCashShopDayWeek(kProductInfo.iDayWeek) $ " " $ GetSystemString(5142) $ "";
			
			MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);			
			kDrawInfo.bLineBreak = true;
			kDrawInfo.nOffSetY = 2;
			wnd.InsertDrawItem(kDrawInfo);			
		}
		else if (BR_GetDayType(kProductInfo.iEndSale, 0) < 2037)  //한정판매
		{
			strTemp = "" $ BR_ConvertTimetoStr(kProductInfo.iStartSale, 2) $ "~" $ BR_ConvertTimetoStr(kProductInfo.iEndSale, 2) ;
			MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);			
			kDrawInfo.bLineBreak = true;
			kDrawInfo.nOffSetY = 2;
			wnd.InsertDrawItem(kDrawInfo);			
		}			 				
		else if( kProductInfo.iStock > 0 ) //한정수량
		{
			if(GetLanguage() == ELanguageType.LANG_Russia)
				strTemp = "" $ GetSystemString(3282) $ ": " $ kProductInfo.iMaxStock ;
			else if(GetLanguage() == ELanguageType.LANG_Euro)
				strTemp = "" $ GetSystemString(5131) $ ": " $ kProductInfo.iMaxStock ;
			else
				strTemp = "" $ kProductInfo.iMaxStock $ "" $ GetSystemString(5131) ;

			MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
			kDrawInfo.bLineBreak = true;
			kDrawInfo.nOffSetY = 2;
			wnd.InsertDrawItem(kDrawInfo);	
		}	
		else if( kProductInfo.iSale_Percent > 0 ) //세일
		{
			strTemp = "" $ kProductInfo.iSale_Percent $ "" $ GetSystemString(5132) ;
			MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
			kDrawInfo.bLineBreak = true;
			kDrawInfo.nOffSetY = 2;
			wnd.InsertDrawItem(kDrawInfo);	
		}	
	}	
}

// 툴팁 정보 창에 출력 - 상단 상품 정보
function SetTooltipProductInfo(WindowHandle wnd,ProductInfo kProductInfo)
{	
	local string strTemp;
	local DrawItemInfo kDrawInfo;
	local int LimitedMarginY;
	local int bTimeLimit;
	local int i;
			
	// 상품 이름
	//MakeDrawInfo_Text(kDrawInfo, kProductInfo.strName, 227,197,80);
 	MakeDrawTooltipInfo_Desc(kDrawInfo, kProductInfo.strName, 227,197,80);
 	wnd.InsertTooltipDrawItem(kDrawInfo);
		
	// 한정판매 정보	
	if (kProductInfo.iProductID >= 0) 
	{
		LimitedMarginY = 6;
		bTimeLimit = 0;
		if (!(kProductInfo.iStartHour==0 && kProductInfo.iStartMin==0 && kProductInfo.iEndHour==23 && kProductInfo.iEndMin==59)) {
			bTimeLimit = 1;
		}

		if (kProductInfo.iMaxStock > 0) 
		{		// 잔여량
			if(GetLanguage() == ELanguageType.LANG_Russia || GetLanguage() == ELanguageType.LANG_Euro)
			{
				strTemp = "[" $ GetSystemString(5133) $ "] " $ GetSystemString(5027)$ ": " $ kProductInfo.iStock;
				MakeDrawPanelInfo_Desc(kDrawInfo,strTemp,199,47,44,ITEM_INFO_WIDTH);
			}
			else
			{
				strTemp = "[" $ GetSystemString(5133) $ "] " $ kProductInfo.iMaxStock $ "" $ GetSystemString(5131) $ " " $ GetSystemString(5027)$ ": " $ kProductInfo.iStock;
				MakeDrawPanelInfo_Desc(kDrawInfo,strTemp,199,47,44,ITEM_INFO_WIDTH);
				//MakeDrawInfo_Text(kDrawInfo,strTemp,199,47,44);
			}
			kDrawInfo.bLineBreak = true;
			kDrawInfo.nOffSetY = LimitedMarginY;
			wnd.InsertTooltipDrawItem(kDrawInfo);
			LimitedMarginY = 0;
		}
		
		//branch121212 
		if( kProductInfo.iRestrictionDay >= 1 && kProductInfo.iAvailableCount >= 1 ) // 몇 일 몇개 한정
		{
			//strTemp = "[" $ GetSystemString(5150) $ "] " $ GetSystemString(5151) $ " " $ kProductInfo.iRestrictionDay $ "" $ GetSystemString(5152) $ " " $ kProductInfo.iAvailableCount $ "" $ GetSystemString(5131) ;
			strTemp  =  "[" $ GetSystemString(5150) $ "] " $ MakeFullSystemMsg(GetSystemMessage(6164), string(kProductInfo.iRestrictionDay), string(kProductInfo.iAvailableCount) );
			MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
			kDrawInfo.bLineBreak = true;
			kDrawInfo.nOffSetY = LimitedMarginY;
			wnd.InsertTooltipDrawItem(kDrawInfo);	
		}
		if( kProductInfo.iRestrictionDay < 0 && kProductInfo.iAvailableCount >= 1 ) // 개수 한정
		{
			//strTemp = "[" $ GetSystemString(5150) $ "] " $ GetSystemString(5151) $ " " $ kProductInfo.iRestrictionDay $ "" $ GetSystemString(5152) $ " " $ kProductInfo.iAvailableCount $ "" $ GetSystemString(5131) ;
			strTemp  =  "[" $ GetSystemString(5150) $ "] " $ MakeFullSystemMsg(GetSystemMessage(6165), string(kProductInfo.iAvailableCount), "" );
			MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
			kDrawInfo.bLineBreak = true;
			kDrawInfo.nOffSetY = LimitedMarginY;
			wnd.InsertTooltipDrawItem(kDrawInfo);	
		}
			
		if( kProductInfo.iMinBirthday > 0 || kProductInfo.iMaxBirthday > 0 ) //캐릭터 생성일
		{
			
			if ( kProductInfo.iMinBirthday > 0 && kProductInfo.iMaxBirthday > 0) 
			{
				strTemp = "[" $ GetSystemString(5149) $ "] " $ BR_ConvertTimetoStr(kProductInfo.iMinBirthday, 1);
				MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
				kDrawInfo.bLineBreak = true;
				kDrawInfo.nOffSetY = LimitedMarginY;
				LimitedMarginY = 0;
				wnd.InsertTooltipDrawItem(kDrawInfo);
				strTemp = "             ~ " $ BR_ConvertTimetoStr(kProductInfo.iMaxBirthday, 1) ;
				MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
				kDrawInfo.bLineBreak = true;
				kDrawInfo.nOffSetY = LimitedMarginY;
				LimitedMarginY = 0;
				wnd.InsertTooltipDrawItem(kDrawInfo);		
			}			
			else if (kProductInfo.iMinBirthday > 0) 
			{
				strTemp = "[" $ GetSystemString(5149) $ "] " $ BR_ConvertTimetoStr(kProductInfo.iMinBirthday, 1) $ " " $ GetSystemString(5153);
				MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
				kDrawInfo.bLineBreak = true;
				kDrawInfo.nOffSetY = LimitedMarginY;
				LimitedMarginY = 0;
				wnd.InsertTooltipDrawItem(kDrawInfo);
			}
			else if (kProductInfo.iMaxBirthday > 0) 
			{
				strTemp = "[" $ GetSystemString(5149) $ "] " $ BR_ConvertTimetoStr(kProductInfo.iMaxBirthday, 1)$ " " $ GetSystemString(1037);
				MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
				kDrawInfo.bLineBreak = true;
				kDrawInfo.nOffSetY = LimitedMarginY;
				LimitedMarginY = 0;
				wnd.InsertTooltipDrawItem(kDrawInfo);
					
			}
		}
				
		if( kProductInfo.iMinLevel > 0 || kProductInfo.iMaxLevel > 0 ) //레벨제한
		{
			if( kProductInfo.iMinLevel > 0 && kProductInfo.iMaxLevel > kProductInfo.iMinLevel )
			{
				strTemp = "[" $ GetSystemString(5145) $ "] " $ kProductInfo.iMinLevel $ "" $ GetSystemString(537) $ "~ " $ kProductInfo.iMaxLevel $ "" $ GetSystemString(537) ;
				MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
				kDrawInfo.bLineBreak = true;
				kDrawInfo.nOffSetY = LimitedMarginY;
				wnd.InsertTooltipDrawItem(kDrawInfo);	
			}
			else if( kProductInfo.iMinLevel == kProductInfo.iMaxLevel )
			{
				strTemp = "[" $ GetSystemString(5145) $ "] " $ kProductInfo.iMinLevel $ "" $ GetSystemString(537) ;
				MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
				kDrawInfo.bLineBreak = true;
				kDrawInfo.nOffSetY = LimitedMarginY;
				wnd.InsertTooltipDrawItem(kDrawInfo);	
			}
			else if( kProductInfo.iMinLevel > 0 )
			{
				strTemp = "[" $ GetSystemString(5145) $ "] " $ MakeFullSystemMsg(GetSystemMessage(6170), string(kProductInfo.iMinLevel), "" );
				MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
				kDrawInfo.bLineBreak = true;
				kDrawInfo.nOffSetY = LimitedMarginY;
				wnd.InsertTooltipDrawItem(kDrawInfo);	
			}
			else if( kProductInfo.iMaxLevel > 0 )
			{
				strTemp = "[" $ GetSystemString(5145) $ "] " $ MakeFullSystemMsg(GetSystemMessage(6171), string(kProductInfo.iMaxLevel), "" );				
				MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
				kDrawInfo.bLineBreak = true;
				kDrawInfo.nOffSetY = LimitedMarginY;
				wnd.InsertTooltipDrawItem(kDrawInfo);	
			}			
		}
		
		
		
		if (bTimeLimit!=0) 
		{
			strTemp = "[" $ GetSystemString(5029) $ "] " $ ZERO_STR(kProductInfo.iStartHour) $ kProductInfo.iStartHour $ ":" 
						$ ZERO_STR(kProductInfo.iStartMin) $ kProductInfo.iStartMin $ "~" 
						$ ZERO_STR(kProductInfo.iEndHour) $ kProductInfo.iEndHour $ ":" 
						$ ZERO_STR(kProductInfo.iEndMin) $ kProductInfo.iEndMin;
			MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
			kDrawInfo.bLineBreak = true;
			kDrawInfo.nOffSetY = LimitedMarginY;
			wnd.InsertTooltipDrawItem(kDrawInfo);
			LimitedMarginY = 0;
		}
		
		if (kProductInfo.iDayWeek != 127) 
		{
			strTemp = "[" $ GetSystemString(5028) $ "] "  $ ConvertBRCashShopDayWeek(kProductInfo.iDayWeek);
			MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
			kDrawInfo.bLineBreak = true;
			kDrawInfo.nOffSetY = LimitedMarginY;
			wnd.InsertTooltipDrawItem(kDrawInfo);
			LimitedMarginY = 0;
		}
				
		if( kProductInfo.iSale_Percent > 0 ) //세일
		{
			strTemp = "[" $ GetSystemString(5141) $ "] " $ kProductInfo.iSale_Percent $ "" $ GetSystemString(5132) ;
			MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
			kDrawInfo.bLineBreak = true;
			kDrawInfo.nOffSetY = LimitedMarginY;
			wnd.InsertTooltipDrawItem(kDrawInfo);	
		}
		if (BR_GetDayType(kProductInfo.iEndSale, 0) < 2037) 
		{
			strTemp = "[" $ GetSystemString(5035) $ "] " $ BR_ConvertTimetoStr(kProductInfo.iStartSale, bTimeLimit);
			MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
			kDrawInfo.bLineBreak = true;
			kDrawInfo.nOffSetY = LimitedMarginY;
			LimitedMarginY = 0;
			wnd.InsertTooltipDrawItem(kDrawInfo);
			strTemp = "             ~ " $ BR_ConvertTimetoStr(kProductInfo.iEndSale, bTimeLimit) ;
			MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
			kDrawInfo.bLineBreak = true;
			kDrawInfo.nOffSetY = LimitedMarginY;
			LimitedMarginY = 0;
			wnd.InsertTooltipDrawItem(kDrawInfo);		
		}
	}	
	
	
	
	// 상품 설명 (존재시)
	if ( Len(kProductInfo.strDesc) > 0 ) 
	{
		MakeDrawTooltipInfo_Desc(kDrawInfo, kProductInfo.strDesc, 220,220,220);
		kDrawInfo.nOffSetY = 12;
		wnd.InsertTooltipDrawItem(kDrawInfo);			
	}		
	
	//세부정보 아이템이 하나라면...
	if( kProductInfo.itemarray.Length <= 1 )
	{
		for( i=0 ; i < kProductInfo.itemarray.Length ; i++ )
		{
			SetTooltipProductItemInfo(wnd, kProductInfo.itemarray[i] );
		}
	}		
	else
	{				
		SetTooltipProductItem(wnd, kProductInfo );
		
		MakeDrawPanelInfo_Desc(kDrawInfo, GetSystemMessage(6118), 228, 218,188, ITEM_INFO_WIDTH);
		kDrawInfo.nOffSetY = 6;
		wnd.InsertTooltipDrawItem(kDrawInfo);		
	}			
}

function SetTooltipProductItem(WindowHandle wnd,ProductInfo kProductInfo )
{	
	local int i;
	local ItemInfo kItemInfo;
	local DrawItemInfo kDrawInfo;
	local ProductItem item;
	
	// 아이템 아이콘	
	MakeDrawInfo_Image(kDrawInfo, kProductInfo.strIconName, 32, 32);
	kDrawInfo.nOffSetY = 12;
	kDrawInfo.bLineBreak = true;	
	wnd.InsertTooltipDrawItem(kDrawInfo);
	
	MakeDrawTooltipInfo_Desc(kDrawInfo, kProductInfo.strName, 227,197,80); //branch 110824 이름 워드랩
	kDrawInfo.bLineBreak = false; //branch 110824 이름 워드랩	
	kDrawInfo.nOffSetY = 16;
	kDrawInfo.nOffSetX = 6;	
	wnd.InsertTooltipDrawItem(kDrawInfo);
	
	MakeDrawInfo_Text(kDrawInfo, GetSystemString(5064), 220, 220, 128);
	kDrawInfo.bLineBreak = true;
	kDrawInfo.nOffSetY = 12;
	wnd.InsertTooltipDrawItem(kDrawInfo);
	
	for( i=0 ; i < kProductInfo.itemarray.Length ; i++ )
	{
		item = kProductInfo.itemarray[i];
			
		class'UIDATA_ITEM'.static.GetItemInfo( GetItemID(item.iItemID), kItemInfo );
	
		MakeDrawTooltipInfo_Desc(kDrawInfo, kItemInfo.Name, 200,200,200); 
		kDrawInfo.bLineBreak = true; //branch 110824 이름 워드랩
		kDrawInfo.nOffSetX = 16;
		kDrawInfo.nOffSetY = 2;
		kDrawInfo.t_MaxWidth = ITEM_INFO_WIDTH - 16; //branch 111109
		wnd.InsertTooltipDrawItem(kDrawInfo);
	}	
}

function SetTooltipProductItemInfo(WindowHandle wnd,ProductItem item)
{	
	local string strWeight;
	local string strTrade;
	local string strTemp;
	local string strNum;
	local ItemInfo kItemInfo;
	local DrawItemInfo kDrawInfo;
	local bool IsPremium;
//	local int nHeight;
//	local int nWidth;
			
	//local int iHeight, iWidth;
	local Color NameColor;
				
	NameColor.R = 200;
	NameColor.G = 200;
	NameColor.B = 200;
	NameColor.A = 255;
	
	//debug("AddEachProductInfo : " $ iId $ "-" $ itemname $ "," $ iconname);
	class'UIDATA_ITEM'.static.GetItemInfo( GetItemID(item.iItemID), kItemInfo );
		
	
	// 아이템 아이콘	
	MakeDrawInfo_Image(kDrawInfo, kItemInfo.IconName, 32, 32);
	kDrawInfo.nOffSetY = 12;
	kDrawInfo.bLineBreak = true;
	
	wnd.InsertTooltipDrawItem(kDrawInfo);
			
	// 아이템 이름. 아이콘 옆에 위치
	// prime icon
	if (kItemInfo.IsBRPremium == 2) 
	{
		IsPremium = MakeCashItemIcon(kDrawInfo);
		if ( IsPremium == true ) {
			kDrawInfo.nOffSetX = 6;
			kDrawInfo.nOffSetY = 16;
			
			wnd.InsertTooltipDrawItem(kDrawInfo);
		}
	}

	// 이름
	if(Len(kItemInfo.AdditionalName)>0)
	{
		strTemp = ""$kItemInfo.Name$" "$kItemInfo.AdditionalName;
	}
	else
		strTemp = kItemInfo.Name;
	//MakeDrawInfo_Text(kDrawInfo, strTemp, 227,197,80);	
	MakeDrawTooltipInfo_Desc(kDrawInfo, strTemp, 227,197,80); //branch 110824 이름 워드랩
	kDrawInfo.bLineBreak = false; //branch 110824 이름 워드랩
	
	kDrawInfo.nOffSetY = 16;
	if ( IsPremium == false ) 
	{
		kDrawInfo.nOffSetX = 6;
	}
	
	wnd.InsertTooltipDrawItem(kDrawInfo);

	// additional name
// 	if (Len(kItemInfo.AdditionalName)>0) {
// 		GetTextSizeDefault(strTemp, nWidth, nHeight);
// 		MakeDrawInfo_Text(kDrawInfo, kItemInfo.AdditionalName, 255, 217, 105);
// 		kDrawInfo.nOffSetX = -nWidth;
// 		kDrawInfo.nOffSetY = 32;
// 		
// 		wnd.InsertTooltipDrawItem(kDrawInfo);
// 	}
	
	// 갯수
	if (item.iAmount > 1) 
	{
		strNum = GetSystemString(192) $ " : " $ item.iAmount;
		MakeDrawInfo_Text(kDrawInfo, strNum, 200, 200, 200);
		kDrawInfo.nOffSetY = 6;
		kDrawInfo.bLineBreak = true;
		
		wnd.InsertTooltipDrawItem(kDrawInfo);
	}

	// 무게
	strWeight = GetSystemString(52) $ " : " $ item.iWeight $ " (" $ GetSystemString(468) $ ")";
	MakeDrawInfo_Text(kDrawInfo, strWeight, 200, 200, 200);
	
	if ( item.iAmount <= 1) 
		kDrawInfo.nOffSetY = 6;
	kDrawInfo.bLineBreak = true;
	
	wnd.InsertTooltipDrawItem(kDrawInfo);

	// 교환여부
	if (item.iTradable == 0) 
	{
		strTrade = GetSystemString(1491);
		MakeDrawInfo_Text(kDrawInfo, strTrade, 200, 200, 200);
		kDrawInfo.bLineBreak = true;
		
		wnd.InsertTooltipDrawItem(kDrawInfo);
	}

	// 상세 설명
	if ( Len(item.strDesc) > 0 ) 
	{
		MakeDrawTooltipInfo_Desc(kDrawInfo, item.strDesc, 220,220,220);
		kDrawInfo.nOffSetY = 12;
		
		wnd.InsertTooltipDrawItem(kDrawInfo);
	}	
	
}

// 상세 정보 창에 출력 - 상단 상품 정보
function SetNewProductInfo(DrawPanelHandle wnd, int iId, int price, string itemname, string desc)
{
	local ProductInfo kProductInfo;
	local string strTemp;
	local DrawItemInfo kDrawInfo;
	local int LimitedMarginY;
	local int bTimeLimit;
	
	//debug("SetNewProductInfo : " $ iId $ "-" $ itemname );
	
	// 상품 이름
	//MakeDrawInfo_Text(kDrawInfo, itemname, 255, 255, 0);
	MakeDrawPanelInfo_Desc(kDrawInfo, itemname, 227,197,80, ITEM_INFO_WIDTH);
	wnd.InsertDrawItem(kDrawInfo);

	// 가격
	kProductInfo = GetProductItem(iId);
	
	strTemp = SetPaymentTypeDetail(kProductInfo.iPaymentType,price);
// 	if( m_bCoinToMoney )
// 	{
// 		priceMoney = float(price) * m_fCoinMoneyValue;
// 		strTemp = GetSystemString(190) $ " : " $ (priceMoney) $ " " $ GetSystemString(5012);
// 	}
// 	else
// 	{
// 		strTemp = GetSystemString(190) $ " : " $ price $ " " $ GetSystemString(5012);
// 	}	
	
	MakeDrawInfo_Text(kDrawInfo, strTemp, 220,220,220);
	kDrawInfo.bLineBreak = true;
	kDrawInfo.nOffSetY = 6;
	wnd.InsertDrawItem(kDrawInfo);
	
	// 한정판매 정보
	
	if (kProductInfo.iProductID >= 0) 
	{
		LimitedMarginY = 6;
		bTimeLimit = 0;
		if (!(kProductInfo.iStartHour==0 && kProductInfo.iStartMin==0 && kProductInfo.iEndHour==23 && kProductInfo.iEndMin==59)) 
		{
			bTimeLimit = 1;
		}

		if (kProductInfo.iMaxStock > 0) {		// 잔여량
			if(GetLanguage() == ELanguageType.LANG_Russia || GetLanguage() == ELanguageType.LANG_Euro)
			{
				strTemp = "[" $ GetSystemString(5133) $ "] " $ GetSystemString(5027)$ ": " $ kProductInfo.iStock;
				MakeDrawPanelInfo_Desc(kDrawInfo,strTemp,199,47,44,ITEM_INFO_WIDTH);
			}
			else
			{
				strTemp = "[" $ GetSystemString(5133) $ "] " $ kProductInfo.iMaxStock $ "" $ GetSystemString(5131) $ " " $ GetSystemString(5027)$ ": " $ kProductInfo.iStock;
				MakeDrawPanelInfo_Desc(kDrawInfo,strTemp,199,47,44,ITEM_INFO_WIDTH);
				//MakeDrawInfo_Text(kDrawInfo,strTemp,199,47,44);
			}
			kDrawInfo.bLineBreak = true;
			kDrawInfo.nOffSetY = LimitedMarginY;
			wnd.InsertDrawItem(kDrawInfo);
			LimitedMarginY = 0;
		}
		
		
		//branch121212 				
		if( kProductInfo.iRestrictionDay >= 1 && kProductInfo.iAvailableCount >= 1 ) // 몇 일 몇개 한정
		{
			//strTemp = "[" $ GetSystemString(5150) $ "] " $ GetSystemString(5151) $ " " $ kProductInfo.iRestrictionDay $ "" $ GetSystemString(5152) $ " " $ kProductInfo.iAvailableCount $ "" $ GetSystemString(5131) ;
			strTemp  =  "[" $ GetSystemString(5150) $ "] " $ MakeFullSystemMsg(GetSystemMessage(6164), string(kProductInfo.iRestrictionDay), string(kProductInfo.iAvailableCount) );
			MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
			kDrawInfo.bLineBreak = true;
			kDrawInfo.nOffSetY = LimitedMarginY;
			wnd.InsertDrawItem(kDrawInfo);	
		}
		if( kProductInfo.iRestrictionDay < 0 && kProductInfo.iAvailableCount >= 1 ) // 개수 한정
		{
			//strTemp = "[" $ GetSystemString(5150) $ "] " $ GetSystemString(5151) $ " " $ kProductInfo.iRestrictionDay $ "" $ GetSystemString(5152) $ " " $ kProductInfo.iAvailableCount $ "" $ GetSystemString(5131) ;
			strTemp  =  "[" $ GetSystemString(5150) $ "] " $ MakeFullSystemMsg(GetSystemMessage(6165), string(kProductInfo.iAvailableCount), "" );
			MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
			kDrawInfo.bLineBreak = true;
			kDrawInfo.nOffSetY = LimitedMarginY;
			wnd.InsertDrawItem(kDrawInfo);	
		}
		
		if( kProductInfo.iMinBirthday > 0 || kProductInfo.iMaxBirthday > 0 ) //캐릭터 생성일
		{
			
			if ( kProductInfo.iMinBirthday > 0 && kProductInfo.iMaxBirthday > 0) 
			{
				strTemp = "[" $ GetSystemString(5149) $ "] " $ BR_ConvertTimetoStr(kProductInfo.iMinBirthday, 1);
				MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
				kDrawInfo.bLineBreak = true;
				kDrawInfo.nOffSetY = LimitedMarginY;
				LimitedMarginY = 0;
				wnd.InsertDrawItem(kDrawInfo);
				strTemp = "             ~ " $ BR_ConvertTimetoStr(kProductInfo.iMaxBirthday, 1) ;
				MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
				kDrawInfo.bLineBreak = true;
				kDrawInfo.nOffSetY = LimitedMarginY;
				LimitedMarginY = 0;
				wnd.InsertDrawItem(kDrawInfo);		
			}			
			else if (kProductInfo.iMinBirthday > 0) 
			{
				strTemp = "[" $ GetSystemString(5149) $ "] " $ BR_ConvertTimetoStr(kProductInfo.iMinBirthday, 1) $ " " $ GetSystemString(5153);
				MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
				kDrawInfo.bLineBreak = true;
				kDrawInfo.nOffSetY = LimitedMarginY;
				LimitedMarginY = 0;
				wnd.InsertDrawItem(kDrawInfo);
			}
			else if (kProductInfo.iMaxBirthday > 0) 
			{
				strTemp = "[" $ GetSystemString(5149) $ "] " $ BR_ConvertTimetoStr(kProductInfo.iMaxBirthday, 1)$ " " $ GetSystemString(1037);
				MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
				kDrawInfo.bLineBreak = true;
				kDrawInfo.nOffSetY = LimitedMarginY;
				LimitedMarginY = 0;
				wnd.InsertDrawItem(kDrawInfo);
					
			}
		}
				
		if( kProductInfo.iMinLevel > 0 || kProductInfo.iMaxLevel > 0 ) //레벨제한
		{
			if( kProductInfo.iMinLevel > 0 && kProductInfo.iMaxLevel > kProductInfo.iMinLevel )
			{
				strTemp = "[" $ GetSystemString(5145) $ "] " $ kProductInfo.iMinLevel $ "" $ GetSystemString(537) $ "~ " $ kProductInfo.iMaxLevel $ "" $ GetSystemString(537) ;
				MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
				kDrawInfo.bLineBreak = true;
				kDrawInfo.nOffSetY = LimitedMarginY;
				wnd.InsertDrawItem(kDrawInfo);	
			}
			else if( kProductInfo.iMinLevel == kProductInfo.iMaxLevel )
			{
				strTemp = "[" $ GetSystemString(5145) $ "] " $ kProductInfo.iMinLevel $ "" $ GetSystemString(537) ;
				MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
				kDrawInfo.bLineBreak = true;
				kDrawInfo.nOffSetY = LimitedMarginY;
				wnd.InsertDrawItem(kDrawInfo);	
			}
			else if( kProductInfo.iMinLevel > 0 )
			{
				
				strTemp = "[" $ GetSystemString(5145) $ "] " $ MakeFullSystemMsg(GetSystemMessage(6170), string(kProductInfo.iMinLevel), "" );
				MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
				kDrawInfo.bLineBreak = true;
				kDrawInfo.nOffSetY = LimitedMarginY;
				wnd.InsertDrawItem(kDrawInfo);	
			}
			else if( kProductInfo.iMaxLevel > 0 )
			{
				strTemp = "[" $ GetSystemString(5145) $ "] " $ MakeFullSystemMsg(GetSystemMessage(6171), string(kProductInfo.iMaxLevel), "" );
				MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
				kDrawInfo.bLineBreak = true;
				kDrawInfo.nOffSetY = LimitedMarginY;
				wnd.InsertDrawItem(kDrawInfo);	
			}			
		}
		
		
		if (bTimeLimit!=0) 
		{
			strTemp = "[" $ GetSystemString(5029) $ "] " $ ZERO_STR(kProductInfo.iStartHour) $ kProductInfo.iStartHour $ ":" 
						$ ZERO_STR(kProductInfo.iStartMin) $ kProductInfo.iStartMin $ "~" 
						$ ZERO_STR(kProductInfo.iEndHour) $ kProductInfo.iEndHour $ ":" 
						$ ZERO_STR(kProductInfo.iEndMin) $ kProductInfo.iEndMin;
			MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
			kDrawInfo.bLineBreak = true;
			kDrawInfo.nOffSetY = LimitedMarginY;
			wnd.InsertDrawItem(kDrawInfo);
			LimitedMarginY = 0;
		}
		if (kProductInfo.iDayWeek != 127) 
		{
			strTemp = "[" $ GetSystemString(5028) $ "] "  $ ConvertBRCashShopDayWeek(kProductInfo.iDayWeek);			
			MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
			kDrawInfo.bLineBreak = true;
			kDrawInfo.nOffSetY = LimitedMarginY;
			wnd.InsertDrawItem(kDrawInfo);
			LimitedMarginY = 0;
		}
		
		if( kProductInfo.iSale_Percent > 0 ) //세일
		{
			strTemp = "[" $ GetSystemString(5141) $ "] " $ kProductInfo.iSale_Percent $ "" $ GetSystemString(5132) ;
			MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
			kDrawInfo.bLineBreak = true;
			kDrawInfo.nOffSetY = LimitedMarginY;
			wnd.InsertDrawItem(kDrawInfo);	
		}				
		
		if (BR_GetDayType(kProductInfo.iEndSale, 0) < 2037) 
		{
			strTemp = "[" $ GetSystemString(5035) $ "] " $ BR_ConvertTimetoStr(kProductInfo.iStartSale, bTimeLimit);
			MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
			kDrawInfo.bLineBreak = true;
			kDrawInfo.nOffSetY = LimitedMarginY;
			LimitedMarginY = 0;
			wnd.InsertDrawItem(kDrawInfo);
			strTemp = "             ~ " $ BR_ConvertTimetoStr(kProductInfo.iEndSale, bTimeLimit) ;
			MakeDrawInfo_Text(kDrawInfo, strTemp, 199,47,44);
			kDrawInfo.bLineBreak = true;
			kDrawInfo.nOffSetY = LimitedMarginY;
			LimitedMarginY = 0;
			wnd.InsertDrawItem(kDrawInfo);		
		}
		
	}	
	
	// 상품 설명 (존재시)
	if ( Len(desc) > 0 ) 
	{
		MakeDrawPanelInfo_Desc(kDrawInfo, desc, 220,220,220, ITEM_INFO_WIDTH);
		kDrawInfo.nOffSetY = 12;
		wnd.InsertDrawItem(kDrawInfo);
	}		
	
}

// 상세 정보 창에 출력 - 하단 아이템 정보
function AddEachProductInfo(DrawPanelHandle wnd, int iId, int iAmount, string itemname, string iconname, string desc, int weight, int trade)
{
	local string strWeight;
	local string strTrade;
	local string strTemp;
	local string strNum;
	local ItemInfo kItemInfo;
	local DrawItemInfo kDrawInfo;
	local bool IsPremium;
//	local int nHeight;
//	local int nWidth;

	//local int iHeight, iWidth;
	local Color NameColor;
	local int i;
	
	NameColor.R = 200;
	NameColor.G = 200;
	NameColor.B = 200;
	NameColor.A = 255;
	
	//debug("AddEachProductInfo : " $ iId $ "-" $ itemname $ "," $ iconname);
	class'UIDATA_ITEM'.static.GetItemInfo( GetItemID(iId), kItemInfo );

	//MakeDrawInfo_Blank(kDrawInfo, 12);
	//m_hDrawPanel.InsertDrawItem(kDrawInfo);
	
	// 아이템 아이콘	
	MakeDrawInfo_Image(kDrawInfo, iconname, 32, 32);
	kDrawInfo.nOffSetY = 12;
	kDrawInfo.bLineBreak = true;
	wnd.InsertDrawItem(kDrawInfo);

	// 아이템 이름. 아이콘 옆에 위치
	// prime icon
	if (kItemInfo.IsBRPremium == 2) 
	{
		IsPremium = MakeCashItemIcon(kDrawInfo);
		if ( IsPremium == true ) {
			kDrawInfo.nOffSetX = 6;
			kDrawInfo.nOffSetY = 16;
			wnd.InsertDrawItem(kDrawInfo);
		}
	}

	// 이름
	if(Len(kItemInfo.AdditionalName)>0)
	{
		strTemp = ""$itemname$" "$kItemInfo.AdditionalName;
	}
	else
		strTemp = itemname;
	//MakeDrawInfo_Text(kDrawInfo, strTemp, 227,197,80);	
	MakeDrawPanelInfo_Desc(kDrawInfo, strTemp, 227,197,80, ITEM_INFO_WIDTH); //branch 110824 이름 워드랩
	kDrawInfo.bLineBreak = false; //branch 110824 이름 워드랩
	
	kDrawInfo.nOffSetY = 16;
	if ( IsPremium == false ) 
	{
		kDrawInfo.nOffSetX = 6;
	}
	wnd.InsertDrawItem(kDrawInfo);

	// additional name
// 	if (Len(kItemInfo.AdditionalName)>0) {
// 		GetTextSizeDefault(strTemp, nWidth, nHeight);
// 		MakeDrawInfo_Text(kDrawInfo, kItemInfo.AdditionalName, 255, 217, 105);
// 		kDrawInfo.nOffSetX = -nWidth;
// 		kDrawInfo.nOffSetY = 32;
// 		wnd.InsertDrawItem(kDrawInfo);
// 	}
	
	// 갯수
	if (iAmount > 1) {
		strNum = GetSystemString(192) $ " : " $ iAmount;
		MakeDrawInfo_Text(kDrawInfo, strNum, 200, 200, 200);
		kDrawInfo.nOffSetY = 6;
		kDrawInfo.bLineBreak = true;
		wnd.InsertDrawItem(kDrawInfo);
	}

	// 무게
	strWeight = GetSystemString(52) $ " : " $ weight $ " (" $ GetSystemString(468) $ ")";
	MakeDrawInfo_Text(kDrawInfo, strWeight, 200, 200, 200);
	if (iAmount <= 1) kDrawInfo.nOffSetY = 6;
	kDrawInfo.bLineBreak = true;
	wnd.InsertDrawItem(kDrawInfo);

	// 교환여부
	if (trade == 0) {
		strTrade = GetSystemString(1491);
		MakeDrawInfo_Text(kDrawInfo, strTrade, 200, 200, 200);
		kDrawInfo.bLineBreak = true;
		wnd.InsertDrawItem(kDrawInfo);
	}

	// 상세 설명
	if ( Len(desc) > 0 ) 
	{
		MakeDrawPanelInfo_Desc(kDrawInfo, desc, 220,220,220, ITEM_INFO_WIDTH);
		kDrawInfo.nOffSetY = 12;
		wnd.InsertDrawItem(kDrawInfo);
	}
	
	// 팩 아이템 추가정보
	if ( kItemInfo.IncludeItem[0] > 0 ) {
		MakeDrawInfo_Text(kDrawInfo, GetSystemString(5064), 220, 220, 128);
		kDrawInfo.bLineBreak = true;
		kDrawInfo.nOffSetY = 12;
		wnd.InsertDrawItem(kDrawInfo);
		
		i = 0;
		while(kItemInfo.IncludeItem[i] > 0 && i < 10) {
			MakeDrawInfo_TextLink(kDrawInfo, kItemInfo.IncludeItem[i], 200, 200, 200);
			kDrawInfo.bLineBreak = true;
			kDrawInfo.nOffSetX = 16;
			kDrawInfo.nOffSetY = 2;
			kDrawInfo.t_MaxWidth = ITEM_INFO_WIDTH - 16; //branch 111109
			wnd.InsertDrawItem(kDrawInfo);
			debug("========id : " $ kItemInfo.IncludeItem[i]);
			i = i+1;
		}
	}	
}

function bool MakeCashItemIcon(out DrawItemInfo Info)
{
	local string TextureName;
	
	Info = m_kDrawInfoClear;
	//TextureName = GetItemGradeTextureName(5);
	TextureName = GetPrimeItemSymbolName();
	if (Len(TextureName)>0)
	{
		Info.eType = DIT_TEXTURE;
		Info.nOffSetX = 0;
		Info.nOffSetY = 0;
		Info.u_nTextureWidth = 16;
		Info.u_nTextureHeight = 16;
		Info.u_nTextureUWidth = 16;
		Info.u_nTextureUHeight = 16;
		Info.u_strTexture = TextureName;
		
		return true;
	}
	
	return false;
}

function MakeText(out DrawItemInfo Info, string str)
{
	Info = m_kDrawInfoClear;

	Info.eType = DIT_TEXT;
	Info.t_bDrawOneLine = true;
	Info.t_color.R = 255;
	Info.t_color.G = 255;
	Info.t_color.B = 255;
	Info.t_color.A = 255;
	Info.t_strText = str;
}

function MakeDrawInfo_Text(out DrawItemInfo Info, string str, int r, int g, int b)
{
	Info = m_kDrawInfoClear;

	Info.eType = DIT_TEXT;
	Info.t_bDrawOneLine = true;
	Info.t_color.R = r;
	Info.t_color.G = g;
	Info.t_color.B = b;
	Info.t_color.A = 255;
	Info.t_strText = str;
}

function MakeDrawTooltipInfo_Desc(out DrawItemInfo Info, string str, int r, int g, int b)
{
	Info = m_kDrawInfoClear;

	Info.eType = DIT_TEXT;
	Info.bLineBreak = true;
	Info.t_bDrawOneLine = false;
	Info.t_MaxWidth = ITEM_INFO_WIDTH;
	Info.t_color.R = r;
	Info.t_color.G = g;
	Info.t_color.B = b;
	Info.t_color.A = 255;
	Info.t_strText = str;
}

function MakeDrawPanelInfo_Desc(out DrawItemInfo Info, string str, int r, int g, int b, int MaxWidth)
{
	Info = m_kDrawInfoClear;

	Info.eType = DIT_TEXT;
	Info.bLineBreak = true;
	Info.t_bDrawOneLine = false;
	Info.t_MaxWidth = MaxWidth;
	Info.t_color.R = r;
	Info.t_color.G = g;
	Info.t_color.B = b;
	Info.t_color.A = 255;
	Info.t_strText = str;
}

function bool MakeDrawInfo_Image(out DrawItemInfo Info, string TextureName, int width, int height)
{
	Info = m_kDrawInfoClear;
	if (Len(TextureName)>0)
	{
		Info.eType = DIT_TEXTURE;
		Info.nOffSetX = 0;
		Info.nOffSetY = 0;
		Info.u_nTextureWidth = width;
		Info.u_nTextureHeight = height;
		Info.u_nTextureUWidth = width;
		Info.u_nTextureUHeight = height;
		Info.u_strTexture = TextureName;
		
		return true;
	}
	
	return false;
}

function MakeDrawInfo_Blank(out DrawItemInfo Info, int Height)
{
	Info = m_kDrawInfoClear;
	Info.eType = DIT_BLANK;
	Info.b_nHeight = Height;
}

function MakeDrawInfo_TextLink(out DrawItemInfo Info, int id, int r, int g, int b)
{
	Info = m_kDrawInfoClear;
	Info.eType = DIT_TEXTLINK;
	Info.t_ID = id;
	Info.t_color.R = r;
	Info.t_color.G = g;
	Info.t_color.B = b;
	Info.t_color.A = 255;
	Info.t_strText = "";
}

function string ZERO_STR(int num)
{
	if (num < 10)
		return "0";
	else
		return "";
}

function int ConvertPreItemPanelType(EPreItemPanelType type)
{
	if( type == PIPT_EVENT )
	{
		return 0;
	}
	else if( type == PIPT_SALE )
	{
		return 1;
	}
	else if( type == PIPT_NEW )
	{
		return 2;
	}
	else if( type == PIPT_STAR )
	{
		return 3;
	}
	else if( type == PIPT_MAX )
	{
		return 4;
	}
	
	return 0;	
}

function ProductItemSort(EBR_CashShopProduct productType, int eSortType,bool bSortDesc)
{		
	local int iCount;
		
	if( productType == BRCSP_PRODUCT )
	{
		iCount = m_ProductList.Length - 1;
	}
	else if( productType == BRCSP_RECENT )
	{
		iCount = m_RecentList.Length - 1;
	}	
	else if( productType == BRCSP_BASKET )
	{
		iCount = m_BasketList.Length - 1;
	}
	
	if(eSortType == 0)
	{
		quicksortIndex(productType, 0, iCount , bSortDesc);		
		NewProductItemSort(bSortDesc);		
	}
	else if(eSortType == 1)
	{
		quicksortIndex(productType, 0, iCount , false);
		quicksortPrice(productType, 0, iCount , bSortDesc);
	}
	else if(eSortType == 2)
	{
		quicksortchar(productType, 0, iCount , bSortDesc);	
	}	
}

function NewProductItemSort(bool bSortDesc)
{		
	local int i;
	local int size;
	local array< ProductInfo >	NewProductList;
	local array< ProductInfo >	TempProductList;
	
	for (i=0; i < m_ProductList.Length; i++)
	{
		if(m_ProductList[i].iPanel_Type - 1 == ConvertPreItemPanelType(PIPT_NEW) )
		{
			size = NewProductList.Length + 1;
			NewProductList[size-1] = m_ProductList[i];
		}
		else
		{
			size = TempProductList.Length + 1;
			TempProductList[size-1] = m_ProductList[i];
		}
	}
		
	if(bSortDesc)
	{	
		if( NewProductList.Length > 0 )
		{	
			m_ProductList.Length = 0;
			
			for (i=0; i < NewProductList.Length; i++)
			{
				size = m_ProductList.Length + 1;
				m_ProductList[size-1] = NewProductList[i];
			}
			
			for (i=0; i < TempProductList.Length; i++)
			{
				size = m_ProductList.Length + 1;
				m_ProductList[size-1] = TempProductList[i];
			}	
		}
	}
	else
	{		
		if( NewProductList.Length > 0 )
		{	
			m_ProductList.Length = 0;
									
			for (i=0; i < TempProductList.Length; i++)
			{
				size = m_ProductList.Length + 1;
				m_ProductList[size-1] = TempProductList[i];
			}	
			
			for (i=0; i < NewProductList.Length; i++)
			{
				size = m_ProductList.Length + 1;
				m_ProductList[size-1] = NewProductList[i];
			}
		}
	}
	
}

function swap(EBR_CashShopProduct productType, int i, int j)
{
	local ProductInfo ProductItem;
	
	if( productType == BRCSP_PRODUCT )
	{		
		ProductItem = m_ProductList[i];
		m_ProductList[i] = m_ProductList[j];
		m_ProductList[j] = ProductItem;
	}
	else if( productType == BRCSP_RECENT )
	{
		ProductItem = m_RecentList[i];
		m_RecentList[i] = m_RecentList[j];
		m_RecentList[j] = ProductItem;
	}	
	else if( productType == BRCSP_BASKET )
	{
		ProductItem = m_BasketList[i];
		m_BasketList[i] = m_BasketList[j];
		m_BasketList[j] = ProductItem;
	}	
}


function int partitionIndex( EBR_CashShopProduct productType, int low, int high, bool desc )
{
	local int pivot;
	local int i;
	local int j;
	local ProductInfo ProductItem;
	
	ProductItem = ArraySortProductItem(productType, low);
	
	pivot = ProductItem.iProductID;
	j = low;

	for(i = low + 1 ; i <= high ; i++)
	{
		if( desc )
		{
			if( ArraySortProductItem(productType, i).iProductID > pivot )
			{
				j++;
				swap(productType, i,j);
			}
		}
		else
		{
			if( ArraySortProductItem(productType, i).iProductID < pivot )
			{
				j++;
				swap(productType, i,j);
			}
		}		
	}
	
	swap(productType, low,j);
	return j;
}


function quicksortIndex(EBR_CashShopProduct productType, int left, int right, bool desc )
{
	local int q;

	if( right - left == 0 )
	{
		return;
	}
	else if( left < right )
	{
		q = partitionIndex(productType, left,right, desc);
		quicksortIndex(productType, left, q - 1, desc);
		quicksortIndex(productType, q + 1, right, desc);
	}
}

function int partitionPrice( EBR_CashShopProduct productType, int low, int high, bool desc )
{
	local int pivot;
	local int i;
	local int j;
	local ProductInfo ProductItem;
	ProductItem = ArraySortProductItem(productType, low);
	
	pivot = ProductItem.iPrice;	
	j = low;

	for(i = low + 1 ; i <= high ; i++)
	{
		if( desc )
		{
			if( ArraySortProductItem(productType, i).iPrice > pivot )
			{
				j++;
				swap(productType,i,j);																
			}
		}
		else
		{
			if( ArraySortProductItem(productType, i).iPrice < pivot )
			{
				j++;
				swap(productType,i,j);
			}
		}			
	}
	
	swap(productType,low,j);
	return j;
}


function quicksortPrice(EBR_CashShopProduct productType, int left, int right, bool desc )
{
	local int q;

	if( right - left == 0 )
	{
		return;
	}
	else if( left < right )
	{
		q = partitionPrice(productType,left,right, desc);
		quicksortPrice(productType,left, q - 1, desc);
		quicksortPrice(productType, q + 1, right, desc);
	}
}


function int partitionchar( EBR_CashShopProduct productType, int low, int high, bool desc )
{
	local string pivot;
	local string temp;
	local int i;
	local int j;
	local ProductInfo ProductItem;
	
	ProductItem = ArraySortProductItem(productType, low);
	
	pivot = Caps(ProductItem.strName);
	j = low;

	for(i = low + 1 ; i <= high ; i++)
	{
		temp = Caps(ArraySortProductItem(productType, i).strName);
		if( desc )
		{
			if( temp > pivot )
			{
				j++;
				swap(productType,i,j);
			}
		}
		else
		{
			if( temp < pivot )
			{
				j++;
				swap(productType,i,j);
			}
		}		
	}
	
	swap(productType,low,j);
	return j;
}

function quicksortchar(EBR_CashShopProduct productType, int left, int right, bool desc )
{
	local int q;

	if( right - left == 0 )
	{
		return;
	}
	else if( left < right )
	{
		q = partitionchar(productType,left,right, desc);
		quicksortchar(productType,left, q - 1, desc);
		quicksortchar(productType, q + 1, right, desc);
	}
}


function ProductInfo ArraySortProductItem(EBR_CashShopProduct productType, int i)
{
	local ProductInfo ProductItem;
	
	if( productType == BRCSP_PRODUCT )
	{
		ProductItem = m_ProductList[i];
	}
	else if( productType == BRCSP_RECENT )
	{
		ProductItem = m_RecentList[i];
	}	
	else if( productType == BRCSP_BASKET )
	{
		ProductItem = m_BasketList[i];
	}	
	return ProductItem;	
}

function string SetPaymentTypeDetail(int iPaymentType, int iPrice)
{
	local string strTemp;
	local float priceMoney;
	
	if(iPaymentType == CASHSHOPPAYMENTTYPE_CASH)
	{
		if( m_bCoinToMoney )
		{
			priceMoney = float(iPrice) * m_fCoinMoneyValue;
			strTemp = GetSystemString(190) $ " : " $ (priceMoney) $ " " $ GetSystemString(5012);
		}
		else
		{
			strTemp = GetSystemString(190) $ " : " $ iPrice $ " " $ GetSystemString(5012);
		}	
	}
	else if(iPaymentType == CASHSHOPPAYMENTTYPE_ADENA)
	{
		strTemp = GetSystemString(190) $ " : " $ iPrice $ " " $ GetSystemString(469);
	}
	else if(iPaymentType == CASHSHOPPAYMENTTYPE_EVENTCOIN)
	{
		strTemp = GetSystemString(190) $ " : " $ iPrice $ " " $ GetSystemString(5179);
	}
	
	return strTemp;
}

function string SetPaymentType(int iPaymentType, int iPrice)
{
	local string strTemp;
	local float priceMoney;

	if(iPaymentType == CASHSHOPPAYMENTTYPE_CASH)
	{
		if( m_bCoinToMoney )
		{
			priceMoney = float(iPrice) * m_fCoinMoneyValue;
			strTemp = (priceMoney) $ " " $ GetSystemString(5012);
		}
		else
		{
			strTemp = iPrice $ " " $ GetSystemString(5012);
		}
	}
	else if(iPaymentType == CASHSHOPPAYMENTTYPE_ADENA)
	{
		strTemp = iPrice $ " " $ GetSystemString(469);
	}
	else if(iPaymentType == CASHSHOPPAYMENTTYPE_EVENTCOIN)
	{
		strTemp = iPrice $ " " $ GetSystemString(5179);
	}
	
	return strTemp;
}

function string ErrorResultBuy(int iResult)
{
	//debug( "Buying Result [" $ iResult $ "] - " $ string(iGamePoint) );
	
	local string sysmeg;
	
	switch (iResult)
	{	
	case -7 :			// BR_BUY_BEFORE_SALE_DATE
	case -8 :			// BR_BUY_AFTER_SALE_DATE
		sysmeg = GetSystemMessage(6003);
		break;
	case -1 :			// BR_BUY_LACK_OF_POINT
		sysmeg = GetSystemMessage(6005);
		break;
	case -2 :			// BR_BUY_INVALID_PRODUCT
	case -5 :			// BR_BUY_CLOSED_PRODUCT
		sysmeg = GetSystemMessage(6008);
		break;
	case -4 :			// BR_BUY_INVENTROY_OVERFLOW
		//DialogShow( DialogModalType_Modal, DialogType_OK, GetSystemMessage(6006), string(Self) );
		sysmeg = GetSystemMessage(6006);
		break;
	case -9 :			// BR_BUY_INVALID_USER
	case -11 :			// BR_BUY_INVALID_USER_STATE
		//DialogShow( DialogModalType_Modal, DialogType_OK, GetSystemMessage(6007), string(Self) );
		sysmeg = GetSystemMessage(6007);
		break;
	case -10 :			// BR_BUY_INVALID_ITEM
		//DialogShow( DialogModalType_Modal, DialogType_OK, GetSystemMessage(6009), string(Self) );
		sysmeg = GetSystemMessage(6009);
		break;
	case -12 :		//BR_BUY_NOT_DAY_OF_WEEK
		//DialogShow( DialogModalType_Modal, DialogType_OK, GetSystemMessage(6019), string(Self) );
		sysmeg = GetSystemMessage(6019);
		break;
	case -13 :		//BR_BUY_NOT_TIME_OF_DAY
		//DialogShow( DialogModalType_Modal, DialogType_OK, GetSystemMessage(6020), string(Self) );
		sysmeg = GetSystemMessage(6020);
		break;
	case -14 :		//BR_BUY_SOLD_OUT
		//DialogShow( DialogModalType_Modal, DialogType_OK, GetSystemMessage(350), string(Self) );
		sysmeg = GetSystemMessage(350);
		break;
	case -17 :		//BR_BUY_INVALID_RECEIVER
		//DialogShow( DialogModalType_Modal, DialogType_OK, GetSystemMessage(3002), string(Self) );
		sysmeg = GetSystemMessage(3002);
		break;
	case -18 :		//BR_BUY_ME_TO_ME
		//DialogShow( DialogModalType_Modal, DialogType_OK, GetSystemMessage(3019), string(Self) );
		sysmeg = GetSystemMessage(3019);
		break;
	case -19 :		//BR_BUY_SEND_POST_COUNT
		sysmeg = GetSystemMessage(2968);
		break;
	case -20 :		//BR_BUY_RECEIVE_POST_COUNT
		sysmeg = GetSystemMessage(3077);
		break;
	case -21 :		//BR_BUY_BLOCKED
		sysmeg = GetSystemMessage(3082);
		break;
	case -22 :		//BR_BUY_MAX_ITEM_IN_POST
		sysmeg = GetSystemMessage(6070);
		break;
	case -23 :		//BR_BUY_PERIODIC_ITEM
		sysmeg = GetSystemMessage(6098);
		break;
	case -24 :		//BR_BUY_LEVEL_LIMIT
		sysmeg = GetSystemMessage(6129);
		break;
	case -25 :		//BR_BUY_LACK_OF_ADENA
		sysmeg = GetSystemMessage(279);
		break;
	case -26 :		//BR_BUY_LACK_OF_EVENTCOIN
		sysmeg = GetSystemMessage(6144);
		break;
	case -27 :		//BR_BUY_BIRTHDAY_LIMIT
		sysmeg = GetSystemMessage(6155);
		break;
	case -28 :		//BR_BUY_NUMBER_LIMIT
		sysmeg = GetSystemMessage(6823);
		break;
	case -3 :			// BR_BUY_USER_CANCEL
		sysmeg = GetSystemMessage(351);
		break;
	case -6 :			// BR_BUY_SERVER_ERROR
	default:
		sysmeg = GetSystemMessage(6002) $ " errorcode:" $ iResult;
		break;
	}
	
	return sysmeg;
}
defaultproperties
{
}
