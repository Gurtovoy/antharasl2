class PrivateMarketWnd extends UICommonAPI;

var WindowHandle Me;
var ListCtrlHandle m_hBuyListCtrlHandle;

function OnRegisterEvent()
{
	registerEvent(EV_ShowPrivateMarketList);
	registerEvent(EV_AddPrivateMarketList);
}

function OnLoad()
{
	OnRegisterEvent();

	Me = GetWindowHandle("PrivateMarketWnd");
	m_hBuyListCtrlHandle = GetListCtrlHandle("PrivateMarketWnd.BuyList");

	Me.ShowWindow();
	Me.SetFocus();
}

function OnHide()
{
	Clear();
}

function OnEvent(int a_EventID, string a_Param)
{
	switch(a_EventID)
	{
	case EV_ShowPrivateMarketList:
		Clear();
		Me.ShowWindow();
		Me.SetFocus();
		break;
	case EV_AddPrivateMarketList:
		HandleAddPrivateMarketList(a_Param);
		break;
	}

}

function OnClickButton(String a_ControlID)
{
	if(a_ControlID == "btnClose")
	{
		Me.HideWindow();
	}
	else if(a_ControlID == "btnRefresh")
	{
		// Request Private Market
		Clear();
		RefreshPrivateMarketInfo();
	}
}

function OnDBClickListCtrlRecord(String a_ListCtrlID)
{
	local LVDataRecord selectedRecord;

	if(a_ListCtrlID == "BuyList")
	{		
		m_hBuyListCtrlHandle.GetSelectedRec(selectedRecord);

		// 해당 상인의 id를 param으로 넘긴다.
		RequestMoveToMerchant(int(selectedRecord.nReserved2));
	}
}

function Clear()
{
	ClearAllPrivateMarketInfo();
	DeleteAllRecords();
}

function HandleAddPrivateMarketList(string Param)
{
	local String merchantName;
	local String itemName;
	local int itemId;
	local int merchantId;
	local INT64 price;
	local String priceString;

	local LVDataRecord Record;
	local LVData merchantNameData;
	local LVData itemNameData;
	local LVData priceData;

	//debug("gorilla");
	ParseString(Param, "merchantName", merchantName);
	ParseString(Param, "itemName", itemName);
	ParseInt(Param, "itemId", itemId);
	ParseInt(Param, "merchantId", merchantId);
	ParseInt64(Param, "price", price);

	merchantNameData.szData = merchantName;
	itemNameData.szData = itemName;
	priceString = MakeCostString(String(price));
	priceData.szData = priceString;

	Record.nReserved1 = itemId;
	Record.nReserved2 = merchantId;
	Record.LVDataList[0] = merchantNameData;
	Record.LVDataList[1] = itemNameData;
	Record.LVDataList[2] = priceData;

	m_hBuyListCtrlHandle.InsertRecord(Record);
}

function DeleteAllRecords()
{
	m_hBuyListCtrlHandle.DeleteAllItem();
}
defaultproperties
{
}
