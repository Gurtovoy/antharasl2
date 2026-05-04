class ManorCropInfoSettingWnd extends UICommonAPI;

var int m_ManorID;
var INT64 m_SumOfDefaultPrice;

const CROP_NAME=0;
const TODAY_CROP_TOTOAL_CNT=1;
const TODAY_CROP_PRICE=2;
const TODAY_PROCURE_TYPE=3;
const NEXT_CROP_TOTAL_CNT=4;
const NEXT_CROP_PRICE=5;
const NEXT_PROCURE_TYPE=6;
const MIN_CROP_PRICE=7;
const MAX_CROP_PRICE=8;
const CROP_LELEL=9;
const REWARD_TYPE_1=10;
const REWARD_TYPE_2=11;

const COLUMN_CNT=12;


const DIALOG_ID_STOP=777;
const DIALOG_ID_SETTODAY=888;

var string m_WindowName;
var ListCtrlHandle m_hManorCropInfoSettingWndManorCropInfoSettingListCtrl;

function OnRegisterEvent()
{
	RegisterEvent( EV_ManorCropInfoSettingWndShow );
	RegisterEvent( EV_ManorCropInfoSettingWndAddItem );
	RegisterEvent( EV_ManorCropInfoSettingWndAddItemEnd );

	RegisterEvent( EV_ManorCropInfoSettingWndChangeValue );

	RegisterEvent( EV_DialogOK );
}

function OnLoad()
{
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	m_ManorID=-1;
	m_SumOfDefaultPrice=0;

	m_hManorCropInfoSettingWndManorCropInfoSettingListCtrl=GetListCtrlHandle(m_WindowName$".ManorCropInfoSettingListCtrl");
}


function OnEvent( int Event_ID, string a_Param)
{
	switch( Event_ID )
	{
	case EV_ManorCropInfoSettingWndShow :
		HandleShow(a_Param);
		break;

	case EV_ManorCropInfoSettingWndAddItem :
		HandleAddItem(a_Param);
		break;
	case EV_ManorCropInfoSettingWndAddItemEnd :
		CalculateSumOfDefaultPrice();
		ShowWindowWithFocus("ManorCropInfoSettingWnd");
		break;
	case EV_ManorCropInfoSettingWndChangeValue :
		HandleChangeValue(a_Param);
		break;
	case EV_DialogOK :
		HandleDialogOk();
		break;
	}
}


function HandleDialogOk()
{
	local int DialogID;

	if(!DialogIsMine())
		return;

	DialogID=DialogGetID();

	switch(DialogID)
	{
	case DIALOG_ID_STOP :
		HandleStop();
		break;
	case DIALOG_ID_SETTODAY :
		HandleSetToday();
		break;
	}
}


function HandleStop()
{
	local int i;
	local int RecordCnt;
	local LVDataRecord record;
	local LVDataRecord recordClear;

	RecordCnt=m_hManorCropInfoSettingWndManorCropInfoSettingListCtrl.GetRecordCount();


//	debug("카운트:"$RecordCnt);
	for(i=0; i<RecordCnt; ++i)
	{
		record = recordClear;		// 이렇게 삭제해주지 않으면 자꾸 늘어난다.
		m_hManorCropInfoSettingWndManorCropInfoSettingListCtrl.GetRec(i,record);
//		debug("레코드인덱스:"$i$", 레코드길이(모두 10이어야 정상):"$record.LvDataList.Length);

		record.LVDataList[NEXT_CROP_TOTAL_CNT].szData="0";
		record.LVDataList[NEXT_CROP_PRICE].szData="0";
		record.LVDataList[NEXT_PROCURE_TYPE].szData="0";

		class'UIAPI_LISTCTRL'.static.ModifyRecord("ManorCropInfoSettingWnd.ManorCropInfoSettingListCtrl", i, record);
	}

	CalculateSumOfDefaultPrice();
}

function HandleSetToday()
{
	local int i;
	local int RecordCnt;
	local LVDataRecord record;
	local LVDataRecord recordClear;

	RecordCnt=m_hManorCropInfoSettingWndManorCropInfoSettingListCtrl.GetRecordCount();

	for(i=0; i<RecordCnt; ++i)
	{
		record = recordClear;
		m_hManorCropInfoSettingWndManorCropInfoSettingListCtrl.GetRec(i, record);

		record.LVDataList[NEXT_CROP_TOTAL_CNT].szData=record.LVDataList[TODAY_CROP_TOTOAL_CNT].szData;
		record.LVDataList[NEXT_CROP_PRICE].szData=record.LVDataList[TODAY_CROP_PRICE].szData;
		record.LVDataList[NEXT_PROCURE_TYPE].szData=record.LVDataList[TODAY_PROCURE_TYPE].szData;

		class'UIAPI_LISTCTRL'.static.ModifyRecord("ManorCropInfoSettingWnd.ManorCropInfoSettingListCtrl", i, record);
	}

	CalculateSumOfDefaultPrice();
}



function HandleShow(string a_Param)
{
	local int ManorID;
	local string ManorName;

	ParseInt(a_Param, "ManorID", ManorID);
	ParseString(a_Param, "ManorName", ManorName);

	m_ManorID=ManorID;

	class'UIAPI_TEXTBOX'.static.SetText("ManorCropInfoSettingWnd.txtManorName", ManorName);

	DeleteAll();
}


function DeleteAll()
{
	class'UIAPI_LISTCTRL'.static.DeleteAllItem("ManorCropInfoSettingWnd.ManorCropInfoSettingListCtrl");
}

function OnClickListCtrlRecord( string ListCtrlID)
{	
	switch( ListCtrlID )
	{
	case "ManorCropInfoSettingListCtrl" :
		if (  class'UIAPI_WINDOW'.static.IsShowWindow("ManorCropInfoChangeWnd")) 
			OnChangeBtn();
		break;
	}
}

function OnDBClickListCtrlRecord( String strID )
{
	switch(strID)
	{
	case "ManorCropInfoSettingListCtrl" :
		OnChangeBtn();
		break;
	}
}

function OnClickButton(string strID)
{
	//debug(" "$strID);

	switch(strID)
	{
	case "btnChangeSell" :
		OnChangeBtn();
		break;
	case "btnSetToday" :
		DialogSetID(DIALOG_ID_SETTODAY);
		DialogShow(DialogModalType_Modalless, DialogType_Warning, GetSystemMessage(1601), string(Self));
		break;
	case "btnStop" :
		DialogSetID(DIALOG_ID_STOP);
		DialogShow(DialogModalType_Modalless, DialogType_Warning, GetSystemMessage(1600), string(Self));
		break;
	case "btnOk" :
		OnOk();
		HideWindow("ManorCropInfoSettingWnd");	
		break;
	case "btnCancel" :
		HideWindow("ManorCropInfoSettingWnd");
		break;
	}
}


function OnOk()
{
	local int RecordCount;
	local LVDataRecord record;
	local LVDataRecord recordClear;

	local int i;

	local string param;

	RecordCount=m_hManorCropInfoSettingWndManorCropInfoSettingListCtrl.GetRecordCount();

	ParamAdd(param, "ManorID", string(m_ManorID));
	ParamAdd(param, "CropCnt", string(RecordCount));

	// 레코드 수만큼 돌면서 검색해서 넣는다
	for(i=0; i<RecordCount; ++i)
	{
		record=recordClear;
		m_hManorCropInfoSettingWndManorCropInfoSettingListCtrl.GetRec(i, record);
	
		ParamAdd(param, "CropID"$i, string(record.nReserved1));
		ParamAdd(param, "BuyCnt"$i, record.LVDataList[NEXT_CROP_TOTAL_CNT].szData);
		ParamAdd(param, "Price"$i, record.LVDataList[NEXT_CROP_PRICE].szData);
		ParamAdd(param, "ProcureType"$i,record.LVDataList[NEXT_PROCURE_TYPE].szData);
	}

	RequestSetCrop(param);
}


function HandleAddItem(string a_Param)
{
	local LVDataRecord record;

	local int CropID;
	local string CropName;
	local INT64 TodayCropTotalCnt;
	local INT64 TodayCropPrice;
	local int TodayProcureType;
	local INT64 NextCropTotalCnt;
	local INT64 NextCropPrice;
	local int NextProcureType;
	local INT MinCropPrice; 
	local INT MaxCropPrice; 
	local int CropLevel;
	local string RewardType1;
	local string RewardType2;
	local INT  MaxCropTotalCnt;
	local INT  DefaultCropPrice;


	ParseInt(a_Param, "CropID", CropID);
	ParseString(a_Param, "CropName", CropName);
	ParseINT64(a_Param, "TodayCropTotalCnt", TodayCropTotalCnt);
	ParseINT64(a_Param, "TodayCropPrice", TodayCropPrice);
	ParseInt(a_Param, "TodayProcureType", TodayProcureType);
	ParseINT64(a_Param, "NextCropTotalCnt", NextCropTotalCnt);
	ParseINT64(a_Param, "NextCropPrice", NextCropPrice);
	ParseInt(a_Param, "NextProcureType", NextProcureType);
	ParseINT(a_Param, "MinCropPrice", MinCropPrice);
	ParseINT(a_Param, "MaxCropPrice", MaxCropPrice);
	ParseInt(a_Param, "CropLevel", CropLevel);
	ParseString(a_Param, "RewardType1", RewardType1);
	ParseString(a_Param, "RewardType2", RewardType2);

	ParseINT(a_Param, "MaxCropTotalCnt", MaxCropTotalCnt);
	ParseINT(a_Param, "DefaultCropPrice", DefaultCropPrice);


	record.LVDataList.Length=COLUMN_CNT;

	record.LVDataList[CROP_NAME].szData=CropName;
	record.LVDataList[TODAY_CROP_TOTOAL_CNT].szData=string(TodayCropTotalCnt);
	record.LVDataList[TODAY_CROP_PRICE].szData=string(TodayCropPrice);
	record.LVDataList[TODAY_PROCURE_TYPE].szData=string(TodayProcureType);
	record.LVDataList[NEXT_CROP_TOTAL_CNT].szData=string(NextCropTotalCnt);
	record.LVDataList[NEXT_CROP_PRICE].szData=string(NextCropPrice);
	record.LVDataList[NEXT_PROCURE_TYPE].szData=string(NextProcureType);
	record.LVDataList[MIN_CROP_PRICE].szData=string(MinCropPrice);
	record.LVDataList[MAX_CROP_PRICE].szData=string(MaxCropPrice);
	record.LVDataList[CROP_LELEL].szData=string(CropLevel);
	record.LVDataList[REWARD_TYPE_1].szData=RewardType1;
	record.LVDataList[REWARD_TYPE_2].szData=RewardType2;

	record.nReserved1=CropID;
	record.nReserved2=MaxCropTotalCnt;
	record.nReserved3=DefaultCropPrice;

	class'UIAPI_LISTCTRL'.static.InsertRecord( "ManorCropInfoSettingWnd.ManorCropInfoSettingListCtrl", record );
}


function CalculateSumOfDefaultPrice()
{
	local LVDataRecord record;
	local LVDataRecord recordClear;
	local int ItemCnt;
	local int i;
	local INT64 tmpMulti;

	local string AdenaString;

	m_SumOfDefaultPrice=0;

	ItemCnt=m_hManorCropInfoSettingWndManorCropInfoSettingListCtrl.GetRecordCount();

	for(i=0; i<ItemCnt; ++i)
	{
		record=recordClear;
		m_hManorCropInfoSettingWndManorCropInfoSettingListCtrl.GetRec( i, record );	

		tmpMulti=INT64(record.LVDataList[NEXT_CROP_PRICE].szData)*INT64(record.LVDataList[NEXT_CROP_TOTAL_CNT].szData);
		m_SumOfDefaultPrice+=tmpMulti;
	}

	AdenaString=MakeCostString(string(m_SumOfDefaultPrice));
	class'UIAPI_TEXTBOX'.static.SetText("ManorCropInfoSettingWnd.txtVarNextTotalExpense", AdenaString);
}

function OnChangeBtn()
{
	local LVDataRecord record;
	local string param;

	if ( m_hManorCropInfoSettingWndManorCropInfoSettingListCtrl.GetSelectedIndex() == -1 )
	{
		AddSystemMessageString( getSystemMessage (326) );	
		return;
	}

	m_hManorCropInfoSettingWndManorCropInfoSettingListCtrl.GetSelectedRec(record);

	ParamAdd(param, "CropName", record.LVDataList[CROP_NAME].szData);							// 작물이름
	ParamAdd(param, "TomorrowVolumeOfBuy", record.LVDataList[NEXT_CROP_TOTAL_CNT].szData);		// 내일 수매량
	ParamAdd(param, "TomorrowLimit", string(record.nReserved2));								// 내일 수매한도
	ParamAdd(param, "TomorrowPrice", record.LVDataList[NEXT_CROP_PRICE].szData);				// 내일 수매가격
	ParamAdd(param, "TomorrowProcure", record.LVDataList[NEXT_PROCURE_TYPE].szData);			// 내일 보상타입
	ParamAdd(param, "MinCropPrice", record.LVDataList[MIN_CROP_PRICE].szData);					// 최소작물가격
	ParamAdd(param, "MaxCropPrice", record.LVDataList[MAX_CROP_PRICE].szData);					// 최대작물가격

	ExecuteEvent(EV_ManorCropInfoChangeWndShow, param);
}


function HandleChangeValue(string a_Param)
{
	local INT64 TomorrowAmountOfPurchase;
	local INT64 TomorrowPurchasePrice;
	local int TomorrowProcure;

	local LVDataRecord record;
	local int SelectedIndex;

	ParseINT64(a_Param, "TomorrowAmountOfPurchase", TomorrowAmountOfPurchase);
	ParseINT64(a_Param, "TomorrowPurchasePrice", TomorrowPurchasePrice);
	ParseInt(a_Param, "TomorrowProcure", TomorrowProcure);


	SelectedIndex=class'UIAPI_LISTCTRL'.static.GetSelectedIndex("ManorCropInfoSettingWnd.ManorCropInfoSettingListCtrl");
	m_hManorCropInfoSettingWndManorCropInfoSettingListCtrl.GetSelectedRec(Record);

//	debug("수정된레코드의인덱스:"$SelectedIndex$", 길이:"$record.LVDataList.Length);

 	record.LVDataList[NEXT_CROP_TOTAL_CNT].szData=string(TomorrowAmountOfPurchase);
	record.LVDataList[NEXT_CROP_PRICE].szData=string(TomorrowPurchasePrice);
	record.LVDataList[NEXT_PROCURE_TYPE].szData=string(TomorrowProcure);

	class'UIAPI_LISTCTRL'.static.ModifyRecord("ManorCropInfoSettingWnd.ManorCropInfoSettingListCtrl", SelectedIndex, record);

	CalculateSumOfDefaultPrice();
}

defaultproperties
{
    m_WindowName="ManorCropInfoSettingWnd"
}
