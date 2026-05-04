class ManorCropInfoChangeWnd extends UICommonAPI;


var INT64 m_MinCropPrice;
var INT64 m_MaxCropPrice;
var INT64 m_TomorrowLimit;

function OnRegisterEvent()
{
	RegisterEvent( EV_ManorCropInfoChangeWndShow );
}

function OnLoad()
{
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();
}

function OnEvent( int Event_ID, string a_Param)
{
	switch( Event_ID )
	{
	case EV_ManorCropInfoChangeWndShow :
		HandleShow(a_Param);
		break;
	}
}

function HandleShow(string a_Param)
{
	local string CropName;
	local INT64 TomorrowVolumeOfBuy;
	local INT64 TomorrowLimit;
	local INT64 TomorrowPrice;
	local int TomorrowProcure;
	local INT64 MinCropPrice;
	local INT64 MaxCropPrice;

	local string TomorrowLimitString;


	ParseString(a_Param, "CropName", CropName);							// 작물이름
	ParseINT64(a_Param, "TomorrowVolumeOfBuy", TomorrowVolumeOfBuy);	// 내일 수매량
	ParseINT64(a_Param, "TomorrowLimit", TomorrowLimit);					// 내일 수매한도
	ParseINT64(a_Param, "TomorrowPrice", TomorrowPrice);					// 내일 수매가
	ParseInt(a_Param, "TomorrowProcure", TomorrowProcure);				// 내일 보상

	ParseINT64(a_Param, "MinCropPrice", MinCropPrice);						// 최소작물가격
	ParseINT64(a_Param, "MaxCropPrice", MaxCropPrice);						// 최대작물가격

	class'UIAPI_TEXTBOX'.static.SetText("ManorCropInfoChangeWnd.txtCropName", CropName);
	class'UIAPI_EDITBOX'.static.SetString("ManorCropInfoChangeWnd.ebTomorrowAmountOfPurchase", string(TomorrowVolumeOfBuy));

	m_TomorrowLimit=TomorrowLimit;
	TomorrowLimitString=MakeCostString(string(TomorrowLimit));
	class'UIAPI_TEXTBOX'.static.SetText("ManorCropInfoChangeWnd.txtVarTomorrowPurchaseLimit", TomorrowLimitString);
	class'UIAPI_EDITBOX'.static.SetString("ManorCropInfoChangeWnd.ebTomorrowPurchasePrice", string(TomorrowPrice));

	if(TomorrowProcure==0)
		TomorrowProcure=1;

	class'UIAPI_COMBOBOX'.static.SetSelectedNum("ManorCropInfoChangeWnd.cbTomorrowReward", TomorrowProcure-1);

	m_MinCropPrice=MinCropPrice;
	m_MaxCropPrice=MaxCropPrice;

	ShowWindowWithFocus("ManorCropInfoChangeWnd");
	class'UIAPI_WINDOW'.static.SetFocus("ManorCropInfoChangeWnd.ebTomorrowAmountOfPurchase");
}

function OnClickButton(string strID)
{
	switch(strID)
	{
	case "btnOk" :
		OnClickBtnOk();
		break;
	case "btnCancel" :
		HideWindow("ManorCropInfoChangeWnd");
		break;
	}
}

function OnClickBtnOk()
{
	local INT64 InputTomorrowAmountOfPurchase;
	local INT64 InputTomorrowPurchasePrice;
	local int InputTomorrowProcure;
	local string Procure;

	local int SelectedNum;

	local string ParamString;
	
	InputTomorrowAmountOfPurchase=INT64(class'UIAPI_EDITBOX'.static.GetString("ManorCropInfoChangeWnd.ebTomorrowAmountOfPurchase"));
	InputTomorrowPurchasePrice=INT64(class'UIAPI_EDITBOX'.static.GetString("ManorCropInfoChangeWnd.ebTomorrowPurchasePrice"));

	if(InputTomorrowAmountOfPurchase < 0 || InputTomorrowAmountOfPurchase > m_TomorrowLimit)
	{	
		ShowErrorDialog(0, m_TomorrowLimit, 1560);	
		return;
	}

	if(InputTomorrowAmountOfPurchase !=0 && (InputTomorrowPurchasePrice < m_MinCropPrice || InputTomorrowPurchasePrice > m_MaxCropPrice))
	{
		ShowErrorDialog(m_MinCropPrice, m_MaxCropPrice, 1559);
		return;
	}

	SelectedNum=class'UIAPI_COMBOBOX'.static.GetSelectedNum("ManorCropInfoChangeWnd.cbTomorrowReward");
	Procure=class'UIAPI_COMBOBOX'.static.GetString("ManorCropInfoChangeWnd.cbTomorrowReward", SelectedNum);
	
	InputTomorrowProcure=int(Procure);


	ParamAdd(ParamString, "TomorrowAmountOfPurchase", string(InputTomorrowAmountOfPurchase));
	ParamAdd(ParamString, "TomorrowPurchasePrice", string(InputTomorrowPurchasePrice));
	ParamAdd(ParamString, "TomorrowProcure", string(InputTomorrowProcure));
	ExecuteEvent(EV_ManorCropInfoSettingWndChangeValue, ParamString);

	HideWindow("ManorCropInfoChangeWnd");
}


function ShowErrorDialog(INT64 MinValue, INT64 MaxValue, int SystemStringIdx)
{
	local string ParamString;
	local string Message;

	ParamAdd(ParamString, "Type", string(int(ESystemMsgParamType.SMPT_NUMBER)));
	ParamAdd(ParamString, "param1", string(MinValue));
	AddSystemMessageParam(ParamString);
	ParamString="";
	ParamAdd(ParamString, "Type", string(int(ESystemMsgParamType.SMPT_NUMBER)));
	ParamAdd(ParamString, "param1", string(MaxValue));
	AddSystemMessageParam(ParamString);
	Message = EndSystemMessageParam(SystemStringIdx, true);

	DialogShow(DialogModalType_Modalless, DialogType_Notice, Message, string(Self) );
}
defaultproperties
{
}
