class ManorSeedInfoSettingWnd extends UICommonAPI;

var int m_ManorID;
var INT64 m_SumOfDefaultPrice;


const SEED_NAME=0;
const TODAY_VOLUME_OF_SALES=1;
const TODAY_PRICE=2;
const TOMORROW_VOLUME_OF_SALES=3;
const TOMORROW_PRICE=4;

const MINIMUM_CROP_PRICE=5;
const MAXIMUM_CROP_PRICE=6;
const SEED_LEVEL=7;
const REWARD_TYPE_1=8;
const REWARD_TYPE_2=9;

const COLUMN_CNT=10;

const DIALOG_ID_STOP=555;
const DIALOG_ID_SETTODAY=666;

var string m_WindowName;
var ListCtrlHandle m_hManorSeedInfoSettingWndManorSeedInfoSettingListCtrl;

function OnRegisterEvent()
{
	RegisterEvent( EV_ManorSeedInfoSettingWndShow );
	RegisterEvent( EV_ManorSeedInfoSettingWndAddItem );
	RegisterEvent( EV_ManorSeedInfoSettingWndAddItemEnd );

	RegisterEvent( EV_ManorSeedInfoSettingWndChangeValue );

	RegisterEvent( EV_DialogOK );
}

function OnLoad()
{
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	m_ManorID=-1;
	m_SumOfDefaultPrice=0;

	m_hManorSeedInfoSettingWndManorSeedInfoSettingListCtrl=GetListCtrlHandle(m_WindowName$".ManorSeedInfoSettingListCtrl");
}

function OnEvent( int Event_ID, string a_Param)
{
	switch( Event_ID )
	{
	case EV_ManorSeedInfoSettingWndShow :
		HandleShow(a_Param);
		break;

	case EV_ManorSeedInfoSettingWndAddItem :
		HandleAddItem(a_Param);
		break;
	case EV_ManorSeedInfoSettingWndAddItemEnd :
		CalculateSumOfDefaultPrice();
		ShowWindowWithFocus("ManorSeedInfoSettingWnd");
		break;
	case EV_ManorSeedInfoSettingWndChangeValue :
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

	RecordCnt=m_hManorSeedInfoSettingWndManorSeedInfoSettingListCtrl.GetRecordCount();


	//debug("카운트:"$RecordCnt);
	for(i=0; i<RecordCnt; ++i)
	{
		record = recordClear;		// 이렇게 삭제해주지 않으면 자꾸 늘어난다.
		m_hManorSeedInfoSettingWndManorSeedInfoSettingListCtrl.GetRec(i, record);
//		//debug("레코드인덱스:"$i$", 레코드길이(모두 10이어야 정상):"$record.LvDataList.Length);

		record.LVDataList[TOMORROW_VOLUME_OF_SALES].szData="0";
		record.LVDataList[TOMORROW_PRICE].szData="0";

		m_hManorSeedInfoSettingWndManorSeedInfoSettingListCtrl.ModifyRecord(i, record);
	}

	CalculateSumOfDefaultPrice();
}

function HandleSetToday()
{
	local int i;
	local int RecordCnt;
	local LVDataRecord record;
	local LVDataRecord recordClear;

	RecordCnt=m_hManorSeedInfoSettingWndManorSeedInfoSettingListCtrl.GetRecordCount();

	for(i=0; i<RecordCnt; ++i)
	{
		record = recordClear;
		m_hManorSeedInfoSettingWndManorSeedInfoSettingListCtrl.GetRec(i, record);

		record.LVDataList[TOMORROW_VOLUME_OF_SALES].szData=record.LVDataList[TODAY_VOLUME_OF_SALES].szData;
		record.LVDataList[TOMORROW_PRICE].szData=record.LVDataList[TODAY_PRICE].szData;

		m_hManorSeedInfoSettingWndManorSeedInfoSettingListCtrl.ModifyRecord(i, record);
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

	class'UIAPI_TEXTBOX'.static.SetText("ManorSeedInfoSettingWnd.txtManorName", ManorName);

	DeleteAll();
}

function HandleChangeValue(string a_Param)
{
	local INT64 TomorrowSalesVolume;
	local INT64 TomorrowPrice;

	local LVDataRecord record;
	local int SelectedIndex;

	ParseINT64(a_Param, "TomorrowSalesVolume", TomorrowSalesVolume);
	ParseINT64(a_Param, "TomorrowPrice", TomorrowPrice);

	SelectedIndex=class'UIAPI_LISTCTRL'.static.GetSelectedIndex("ManorSeedInfoSettingWnd.ManorSeedInfoSettingListCtrl");
	m_hManorSeedInfoSettingWndManorSeedInfoSettingListCtrl.GetSelectedRec(Record);

//	debug("수정된레코드의인덱스:"$SelectedIndex$", 길이:"$record.LVDataList.Length);
	
	record.LVDataList[TOMORROW_VOLUME_OF_SALES].szData=string(TomorrowSalesVolume);
	record.LVDataList[TOMORROW_PRICE].szData=string(TomorrowPrice);

	class'UIAPI_LISTCTRL'.static.ModifyRecord("ManorSeedInfoSettingWnd.ManorSeedInfoSettingListCtrl", SelectedIndex, record);

	CalculateSumOfDefaultPrice();
}


function DeleteAll()
{
	class'UIAPI_LISTCTRL'.static.DeleteAllItem("ManorSeedInfoSettingWnd.ManorSeedInfoSettingListCtrl");
}

function OnClickListCtrlRecord( string ListCtrlID)
{	
	switch( ListCtrlID )
	{
	case "ManorSeedInfoSettingListCtrl" :
		if (  class'UIAPI_WINDOW'.static.IsShowWindow("ManorSeedInfoChangeWnd")) 
			OnChangeBtn();
		break;
	}
}

function OnDBClickListCtrlRecord( String strID )
{
	switch(strID)
	{
	case "ManorSeedInfoSettingListCtrl" :
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
		break;
	case "btnCancel" :
		HideWindow("ManorSeedInfoSettingWnd");
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


	RecordCount=m_hManorSeedInfoSettingWndManorSeedInfoSettingListCtrl.GetRecordCount();

	ParamAdd(param, "ManorID", string(m_ManorID));
	ParamAdd(param, "SeedCnt", string(RecordCount));

	// 레코드 수만큼 돌면서 검색해서 넣는다
	for(i=0; i<RecordCount; ++i)
	{
		record=recordClear;
		m_hManorSeedInfoSettingWndManorSeedInfoSettingListCtrl.GetRec(i, record);
	
		ParamAdd(param, "SeedID"$i, string(record.nReserved1));
		ParamAdd(param, "TomorrowSalesVolume"$i, record.LVDataList[TOMORROW_VOLUME_OF_SALES].szData);
		ParamAdd(param, "TomorrowPrice"$i,record.LVDataList[TOMORROW_PRICE].szData);
	}

	RequestSetSeed(param);

	HideWindow("ManorSeedInfoSettingWnd");
}

function OnChangeBtn()
{
	local LVDataRecord record;
	local string param;

	if ( m_hManorSeedInfoSettingWndManorSeedInfoSettingListCtrl.GetSelectedIndex() == -1 )
	{
		AddSystemMessageString(getSystemMessage ( 326 ));	
		return;
	}

	m_hManorSeedInfoSettingWndManorSeedInfoSettingListCtrl.GetSelectedRec(Record);

	ParamAdd(param, "SeedName", record.LVDataList[SEED_NAME].szData);								// 씨앗이름
	ParamAdd(param, "TomorrowVolumeOfSales", record.LVDataList[TOMORROW_VOLUME_OF_SALES].szData);	// 내일 판매량
	ParamAdd(param, "TomorrowLimit", string(record.nReserved2));									// 내일 발매한도
	ParamAdd(param, "TomorrowPrice", record.LVDataList[TOMORROW_PRICE].szData);						// 내일 가격

	ParamAdd(param, "MinCropPrice", record.LVDataList[MINIMUM_CROP_PRICE].szData);					// 최소작물가격
	ParamAdd(param, "MaxCropPrice", record.LVDataList[MAXIMUM_CROP_PRICE].szData);					// 최대작물가격

	ExecuteEvent(EV_ManorSeedInfoChangeWndShow, param);
}



function HandleAddItem(string a_Param)
{
	local LVDataRecord record;

	local int SeedID;
	local string SeedName;
	local INT TodaySeedTotalCnt;
	local INT64 TodaySeedPrice;
	local INT64 NextSeedTotalCnt;
	local INT64 NextSeedPrice;
	local INT MinCropPrice;
	local INT MaxCropPrice;
	local int SeedLevel;
	local string RewardType1;
	local string RewardType2;
	local INT64 MaxSeedTotalCnt;
	local INT DefaultSeedPrice;

	ParseInt(a_Param, "SeedID", SeedID);
	ParseString(a_Param, "SeedName", SeedName);
	ParseINT(a_Param, "TodaySeedTotalCnt", TodaySeedTotalCnt);
	ParseINT64(a_Param, "TodaySeedPrice", TodaySeedPrice);
	ParseINT64(a_Param, "TodayNextSeedTotalCnt", NextSeedTotalCnt);
	ParseINT64(a_Param, "NextSeedPrice", NextSeedPrice);
	ParseINT(a_Param, "MinCropPrice", MinCropPrice);
	ParseINT(a_Param, "MaxCropPrice", MaxCropPrice);
	ParseInt(a_Param, "SeedLevel", SeedLevel);
	ParseString(a_Param, "RewardType1", RewardType1);
	ParseString(a_Param, "RewardType2", RewardType2);
	ParseINT64(a_Param, "MaxSeedTotalCnt", MaxSeedTotalCnt);
	ParseINT(a_Param, "DefaultSeedPrice", DefaultSeedPrice);


	record.LVDataList.Length=COLUMN_CNT;

	record.LVDataList[SEED_NAME].szData=SeedName;										// 씨앗이름
	record.LVDataList[TODAY_VOLUME_OF_SALES].szData=string(TodaySeedTotalCnt);			// 오늘 판매량
	record.LVDataList[TODAY_PRICE].szData=string(TodaySeedPrice);						// 오늘 가격
	record.LVDataList[TOMORROW_VOLUME_OF_SALES].szData=string(NextSeedTotalCnt);		// 내일 판매량
	record.LVDataList[TOMORROW_PRICE].szData=string(NextSeedPrice);						// 내일 가격

	record.LVDataList[MINIMUM_CROP_PRICE].szData=string(MinCropPrice);					
	record.LVDataList[MAXIMUM_CROP_PRICE].szData=string(MaxCropPrice);
	record.LVDataList[SEED_LEVEL].szData=string(SeedLevel);
	record.LVDataList[REWARD_TYPE_1].szData=RewardType1;
	record.LVDataList[REWARD_TYPE_2].szData=RewardType2;

	record.nReserved1=SeedID;
	record.nReserved2=MaxSeedTotalCnt;
	record.nReserved3=DefaultSeedPrice;

	class'UIAPI_LISTCTRL'.static.InsertRecord( "ManorSeedInfoSettingWnd.ManorSeedInfoSettingListCtrl", record );
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

	ItemCnt=m_hManorSeedInfoSettingWndManorSeedInfoSettingListCtrl.GetRecordCount();

	for(i=0; i<ItemCnt; ++i)
	{
		record=recordClear;
		m_hManorSeedInfoSettingWndManorSeedInfoSettingListCtrl.GetRec(i, record);	

		tmpMulti=record.nReserved3*INT64(record.LVDataList[TOMORROW_VOLUME_OF_SALES].szData);
		m_SumOfDefaultPrice+=tmpMulti;
	}

	AdenaString=MakeCostString(string(m_SumOfDefaultPrice));
	class'UIAPI_TEXTBOX'.static.SetText("ManorSeedInfoSettingWnd.txtVarNextTotalExpense", AdenaString);
}

defaultproperties
{
    m_WindowName="ManorSeedInfoSettingWnd"
}
