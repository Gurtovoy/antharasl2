/**  
 *   제목  : 오늘의 할일
 *   메모  : 상하이팀 최초 추가 (중국 버전용으로 제작)
 *   해외 모드로 다시 만듦(선준)
 **/
class ToDoListWnd extends UICommonAPI;

var WindowHandle Me;
var CheckBoxHandle AllLevelCheckBox;
var WindowHandle ToDoList_Wnd;
var ListCtrlHandle ToDoList_ListCtrl;
var WindowHandle DetailInfo_Wnd;
var TextBoxHandle DetailInfoTitle_Text;
var TextBoxHandle MissionName_Text;
var TextureHandle IconLock_texture;
var TextBoxHandle MissionDateName_Text;
var TextureHandle divider_texture;
var TextureHandle DetailInfoMissionGroupbox_texture;
var TextureHandle DetailInfoMissionGroupboxDeco_texture;
var TextureHandle scrollGroupBox_Texture;
var TextureHandle DailyMissionListWndGroupBox_Texture;
var TextureHandle DailyMissionInfoWndGroupBox_Texture;
var ButtonHandle RefreshBtn;
var ButtonHandle EssentialBtn;
var ButtonHandle RewardBtn;
var WindowHandle CompleteWnd_scrollarea;
var TextBoxHandle CompleteDescriotion_Text;
var WindowHandle TimedWnd_scrollarea;
var TextBoxHandle TimedDescriotion_Text;
var WindowHandle RewardInfoWnd_scrollarea;
var ButtonHandle LocalfindBtn_BTN;
var ItemWindowHandle DailyRewardItem;
var StatusBarHandle Completegage_statusbar;
var WindowHandle	areaScroll;



//선택한 보상 ID, ServerID
var int selectRewardID, selectServerID; 
// 보상조건
var string rewardDesc; 
// 보상기간-이라는데 아님 보상완료 조건 rewardPeriod = RequestOneDayRewardPeriod( rewardID );
var string rewardPeriod; 
//폰트 색상 빨강, 노랑, 파랑
var color R, Y, B;
//이전에 선택한 List index값
var int saveIndex;
//일일 남은시간
var int DayRemainTime;
//주간 남은시간
var int WeekRemainTime;
//월간 남은시간
var int MonthRemainTime;
//서버 요일
var int ServerDay;
//정렬을 위한 struct 값 sort0, sort1로 정렬함.
struct ToDoListInfo
{
	var LVDataRecord        record;
	var int			        sort0;
	var int			        sort1;	
};
//정렬을 위한 배열
var Array<ToDoListInfo> todoArray;

//시간표시를 위한 변수
var int nResetPeriod;
//시간용 타이머 ID
const TIMER_ID          = 99900;
//시간용 타이머 딜레이 1초
const TIMER_DELAY       = 1000;
//목록 갱신용 타이머 ID
const TIMER_CLICK       = 99901;
//목록 갱신용 타이머 딜레이 3초
const TIMER_DELAYC       = 3000;

function OnRegisterEvent()
{
	RegisterEvent(EV_TodoListShow);	
	// 일일보상 시스템목록 
	RegisterEvent(EV_OneDayRewardListStart);
	RegisterEvent(EV_OneDayRewardList);
	RegisterEvent(EV_OneDayRewardListEnd);
	// 일일보상 시스템 아이템 목록 
	RegisterEvent(EV_OneDayRewardItemListStart);
	RegisterEvent(EV_OneDayRewardItemList);
	RegisterEvent(EV_OneDayRewardItemListEnd);
}

/**  onShow  */
function onShow()
{
	//옵션 로드
	loadOptionToDo();
	//목록 가져오기
	RefreshList();

	Me.SetFocus();
}

/**  onHide  */
function onHide()
{	
	//미니맵 
	class'UIAPI_MINIMAPCTRL'.static.SetDailyQuest( "MinimapWnd.Minimap", false, selectRewardID );
}

/** OnDefaultPosition */
function OnDefaultPosition(){}

/**  OnLoad  */
function OnLoad()
{
	registerState(getCurrentWindowName(string(Self)), "GamingState" );
	SetClosingOnESC(); 
	Initialize();
}

function Initialize()
{
	Me = GetWindowHandle( "ToDoListWnd" );
	AllLevelCheckBox = GetCheckBoxHandle( "ToDoListWnd.AllLevelCheckBox" );
	ToDoList_Wnd = GetWindowHandle( "ToDoListWnd.ToDoList_Wnd" );
	ToDoList_ListCtrl = GetListCtrlHandle( "ToDoListWnd.ToDoList_Wnd.ToDoList_ListCtrl" );
	DetailInfo_Wnd = GetWindowHandle( "ToDoListWnd.DetailInfo_Wnd" );
	DetailInfoTitle_Text = GetTextBoxHandle( "ToDoListWnd.DetailInfo_Wnd.DetailInfoTitle_Text" );
	MissionName_Text = GetTextBoxHandle( "ToDoListWnd.DetailInfo_Wnd.MissionName_Text" );
	IconLock_texture = GetTextureHandle( "ToDoListWnd.DetailInfo_Wnd.IconLock_texture" );
	MissionDateName_Text = GetTextBoxHandle( "ToDoListWnd.DetailInfo_Wnd.MissionDateName_Text" );
	divider_texture = GetTextureHandle( "ToDoListWnd.DetailInfo_Wnd.divider_texture" );
	DetailInfoMissionGroupbox_texture = GetTextureHandle( "ToDoListWnd.DetailInfo_Wnd.DetailInfoMissionGroupbox_texture" );
	DetailInfoMissionGroupboxDeco_texture = GetTextureHandle( "ToDoListWnd.DetailInfo_Wnd.DetailInfoMissionGroupboxDeco_texture" );
	scrollGroupBox_Texture = GetTextureHandle( "ToDoListWnd.DetailInfo_Wnd.scrollGroupBox_Texture" );
	DailyMissionListWndGroupBox_Texture = GetTextureHandle( "ToDoListWnd.DailyMissionListWndGroupBox_Texture" );
	DailyMissionInfoWndGroupBox_Texture = GetTextureHandle( "ToDoListWnd.DailyMissionInfoWndGroupBox_Texture" );	
	RefreshBtn = GetButtonHandle( "ToDoListWnd.RefreshBtn" );
	EssentialBtn = GetButtonHandle( "ToDoListWnd.EssentialBtn" );

	areaScroll                  = GetWindowHandle       (   "ToDoListWnd.DetailInfo_Wnd.DetailInfo_ScrollArea" );

	RewardInfoWnd_scrollarea     = GetWindowHandle      (   "ToDoListWnd.DetailInfo_Wnd.DetailInfo_ScrollArea.RewardInfoWnd_scrollarea" );
	RewardBtn                   = GetButtonHandle       (   "ToDoListWnd.DetailInfo_Wnd.DetailInfo_ScrollArea.RewardInfoWnd_scrollarea.RewardBtn" );
	DailyRewardItem             = GetItemWindowHandle	(   "ToDoListWnd.DetailInfo_Wnd.DetailInfo_ScrollArea.RewardInfoWnd_scrollarea.DailyRewardItem" );

	CompleteDescriotion_Text    = GetTextBoxHandle      (   "ToDoListWnd.DetailInfo_Wnd.DetailInfo_ScrollArea.CompleteWnd_scrollarea.CompleteDescriotion_Text" );
	CompleteWnd_scrollarea      = GetWindowHandle       (   "ToDoListWnd.DetailInfo_Wnd.DetailInfo_ScrollArea.CompleteWnd_scrollarea" );
	LocalfindBtn_BTN            = GetButtonHandle       (   "ToDoListWnd.DetailInfo_Wnd.DetailInfo_ScrollArea.CompleteWnd_scrollarea.LocalfindBtn_BTN" );
	Completegage_statusbar      = GetStatusBarHandle    (   "ToDoListWnd.DetailInfo_Wnd.DetailInfo_ScrollArea.CompleteWnd_scrollarea.Completegage_statusbar" );

	TimedDescriotion_Text       = GetTextBoxHandle      (   "ToDoListWnd.DetailInfo_Wnd.DetailInfo_ScrollArea.TimedWnd_scrollarea.TimedDescriotion_Text" );
	TimedWnd_scrollarea         = GetWindowHandle       (   "ToDoListWnd.DetailInfo_Wnd.DetailInfo_ScrollArea.TimedWnd_scrollarea" );

	
	R.R = 255;
	R.G = 153;
	R.B = 153;

	Y.R = 255;
	Y.G = 255;
	Y.B = 187;

	B.R = 136;
	B.G = 255;
	B.B = 255;

	saveIndex = 0;
}

/**  OnEvent  */
function OnEvent( int a_EventID, String param )
{
	switch( a_EventID )
	{
		case EV_TodoListShow :  
			debug("EV_TodoListShow : " @ param);
			openProcess(param);
			break;
		//일일 미션 리스트 받기 시작
		case EV_OneDayRewardListStart :
			OneDayRewardListStart( param );			
			break;
		//일일 미션 리스트 받음
		case EV_OneDayRewardList : 
			Debug( param );
			OneDayRewardList( param );
			break;
		//일일 미션 리스트 받음 완료
		case EV_OneDayRewardListEnd : 
			OneDayRewardListEnd( param );											
			//checkNoneNoticeHtml();
			break;

		// 일일 미션 시스템 보상 목록 받기 시작
		case EV_OneDayRewardItemListStart : 
			DailyRewardItem.Clear();
			break;
		// 일일 미션 시스템 보상 목록 받기
		case EV_OneDayRewardItemList :
			OneDayRewardItemList( param );
			break;
		// 일일 미션 시스템 보상 목록 받기 완료
		case EV_OneDayRewardItemListEnd : 								
			break;
	}
}
/**
 * 일일 미션 리스트 받기 시작
 * DayRemainTime(일일 남은시간), WeekRemainTime(주간 남은 시간), MonthRemainTime(월간 남은시간), ServerDay(서버 요일)
 * **/
function OneDayRewardListStart( string param )
{
	//정렬 배열 초기화
	todoArray.Remove( 0, todoArray.Length );
	//주기별 남은 시간들 받음
	ParseINT(param,   "DayRemainTime"     , DayRemainTime);
	ParseINT(param,   "WeekRemainTime"    , WeekRemainTime);
	ParseINT(param,   "MonthRemainTime"   , MonthRemainTime);
	ParseINT(param,   "ServerDay"         , ServerDay);
	//리스트 아이템 초기화
	ToDoList_ListCtrl.DeleteAllItem();
	//남은 시간 표시용 타이머 초기화
	Me.KillTimer( TIMER_ID );
	//남은 시간 표시용 타이머 시작
	Me.SetTimer( TIMER_ID, TIMER_DELAY );
}
/**
 *  일일 미션 리스트 받음
 *  (serverID(서버ID(int), rewardID(보상ID(int)), rewardName(미션 명(string)), rewardStatus(보상수령상태(int))
 */
function OneDayRewardList( string param )
{
	/***  param 값 ----- ***/
	//미션 오픈 조건 요일
	local int CanConditionDay, CanConditionDayCount;
	//미션 가능 최소 레벨
	local int CanConditionLvMin;
	//미션 가능 최대 레벨
	local int CanConditionLvMax;
	//미션 ID, 서버ID 값
	local int rewardID, serverID;
	//미션 보상 수령 상태
	local int rewardStatus;
	//미션 진행도 값
	local int CurrentCount;
	//미션 진행도 완료 값
	local int MaxCount;
	//미션 Event, New 값 new=1 event=2
	local int NewEvent;
	//사냥 미션 여부(출현지역) 1=사냥미션 0=사냥미션아님
	local int ShowQuestRange;
	//미션 주기
	local int ResetPeriod;
	//미션 제목
	local string rewardName;
	/***  param 값 ----- ***/

	local int i;
	//유저 레벨 사용
	local UserInfo playerInfo;
	//정렬 상태 기준
	local int nSort;
	//ToDoList_ListCtrl에 들어갈 record 값
	local LVDataRecord record;

	//잠김 상태 유무(레벨, 요일) -- param 값에 추가하여 사용
	local bool Block;
	//수령 가능 여부 -- param 값에 추가하여 사용
	local string rewardBool;

	//기본값 셋팅
	Block = false;
	nSort = 0;
	rewardBool = "f";

	//유저 정보 받음
	GetPlayerInfo(playerInfo);
	
	/***  param 값 셋팅 ----- ***/	
	ParseINT(param,    "CanConditionDayCount"       , CanConditionDayCount);
	ParseINT(param,    "rewardID"                   , rewardID);
	ParseINT(param,    "serverID"                   , serverID);
	ParseINT(param,    "rewardStatus"               , rewardStatus);
	ParseINT(param,    "NewEvent"                   , NewEvent);
	ParseINT(param,    "CurrentCount"               , CurrentCount);
	ParseINT(param,    "MaxCount"                   , MaxCount);
	ParseINT(param,    "ResetPeriod"                , ResetPeriod);
	ParseINT(param,    "CanConditionLvMin"          , CanConditionLvMin);
	ParseINT(param,    "CanConditionLvMax"          , CanConditionLvMax);
	ParseINT(param,    "ShowQuestRange"             , ShowQuestRange);
	ParseString(param, "rewardName"                 , rewardName);
	/***  param 값 셋팅 ----- ***/

	//레벨과 상관 없이 모두 할 수 있는 것은 값이 0이 와서 999로 수정해줌. 
	if( CanConditionLvMax == 0 )
	{
		CanConditionLvMax = 999;
	}

	//잠김 상태 확인 레벨
	if ( playerInfo.nLevel < CanConditionLvMin ||  playerInfo.nLevel > CanConditionLvMax )
	{
		Block = true;
	}
	//잠김 확인 요일
	if( CanConditionDayCount != 0 )
	{
		for( i = 0 ; i < CanConditionDayCount ; i++ )
		{
			//요일 받음 1=일 2=월 3=화 4=수 5=목 6=금 7=토
			ParseInt( param, "CanConditionDay" $ i, CanConditionDay );
			
			//서버 요일과 같은 요일이 있으면 열림
			if( ServerDay  == CanConditionDay )
			{
				Block = false;
				break;
			}
			//서버 요일과 같은 요일이 없으면 잠김
			else
			{
				Block = true;
			}
		}
	}

	//3개
	record.LVDataList.Length = 3;
	//색상 들어감 3개다.
	record.LVDataList[0].buseTextColor = True;
	record.LVDataList[1].buseTextColor = True;		
	record.LVDataList[2].buseTextColor = True;

	
	//주기에 따른 색상 값 셋팅
	record.LVDataList[0].TextColor = setTextColor( ResetPeriod );
	//주기별 시스템 메시지 
	switch( ResetPeriod )
	{
		//일일
		case 1:
			record.LVDataList[0].szData         = GetSystemString(3579);
			break;
		//주간
		case 2:
			record.LVDataList[0].szData         = GetSystemString(3580);
			break;
		//월간
		case 3:
			record.LVDataList[0].szData         = GetSystemString(3581);
			break;
		//일회성
		case 4:
			record.LVDataList[0].szData         = GetSystemString(1792);
			break;
	}
	//미션 제목 기본 값 셋팅 - 흰색
	record.LVDataList[1].TextColor = getInstanceL2Util().BrightWhite;

	// 상태값 구분 
	switch( rewardStatus )
	{
		// 수령가능
		case 1 : 
			//색상 노랑
			record.LVDataList[2].TextColor = getInstanceL2Util().Yellow;
			//보상 수령 가능
			record.LVDataList[2].szData = GetSystemString(3586); 
			rewardBool = "t";
			nSort = 1;
			break;

		// 잠김 or 진행중
		case 2 :
			//잠김
			if ( Block )
			{
				nSort = 3;
				//자물쇠 아이콘 추가
				record.LVDataList[2].hasIcon = true;
				record.LVDataList[2].nTextureWidth=14;
				record.LVDataList[2].nTextureHeight=14;
				record.LVDataList[2].nTextureU=14;
				record.LVDataList[2].nTextureV=14;
				record.LVDataList[2].szTexture = "L2UI_CT1.DailyMissionWnd_IconLock"; 
				record.LVDataList[2].IconPosX = 46;	
				record.LVDataList[2].FirstLineOffsetX=5;
				record.LVDataList[2].TextColor = R;
				record.LVDataList[2].szData = GetSystemString(3587);
			}
			//진행중
			else
			{
				nSort = 2;
				//진행도 StatusBar 추가
				record.bUseStatusBar = true;
				record.nStatusBarIndex = 2; // 몇번째 컬럼에 추가할것인가.
				record.LVDataList[record.nStatusBarIndex].nStatusBarCurrentCount = CurrentCount;
				record.LVDataList[record.nStatusBarIndex].nStatusBarMaxCount = MaxCount;
				
				record.strStatusBarForeLeftTex      = "L2UI_CT1.Gauges.Gauge_DF_Large_Weight_Left3";
				record.strStatusBarForeCenterTex    = "L2UI_CT1.Gauges.Gauge_DF_Large_Weight_Center3";
				record.strStatusBarForeRightTex     = "L2UI_CT1.Gauges.Gauge_DF_Large_Weight_Right3";

				record.strStatusBarBackLeftTex      = "L2UI_CT1.Gauges.Gauge_DF_Large_Weight_bg_Left3";
				record.strStatusBarBackCenterTex    = "L2UI_CT1.Gauges.Gauge_DF_Large_Weight_bg_Center3";
				record.strStatusBarBackRightTex     = "L2UI_CT1.Gauges.Gauge_DF_Large_Weight_bg_Right3";
				record.nStatusBarWidth = 110;
				record.nStatusBarHeight = 12;
			}
			break;

		//수령완료
		case 3 :
			nSort = 4;
			//색상 회색
			record.LVDataList[1].TextColor = getInstanceL2Util().Gray;
			record.LVDataList[2].TextColor = getInstanceL2Util().Gray;
			record.LVDataList[2].szData = GetSystemString(898);
			break;
	}
	
	//new 아이콘 추가
	if( NewEvent == 1 )
	{
		record.LVDataList[1].hasIcon = true;
		record.LVDataList[1].iconPostion = true;
		record.LVDataList[1].nTextureWidth=41;
		record.LVDataList[1].nTextureHeight=19;
		record.LVDataList[1].nTextureU=41;
		record.LVDataList[1].nTextureV=19;
		record.LVDataList[1].szTexture = "L2UI_CT1.DailyMissionWnd_IconNewt"; 
		record.LVDataList[1].IconPosX = 2;	
		record.LVDataList[1].FirstLineOffsetX = 4;
	}
	//evnet 아이콘 추가
	else if( NewEvent == 2 )
	{
		record.LVDataList[1].hasIcon = true;
		record.LVDataList[1].iconPostion = true;
		record.LVDataList[1].nTextureWidth=41;
		record.LVDataList[1].nTextureHeight=19;
		record.LVDataList[1].nTextureU=41;
		record.LVDataList[1].nTextureV=19;
		record.LVDataList[1].szTexture = "L2UI_CT1.DailyMissionWnd_IconEvent"; 
		record.LVDataList[1].IconPosX = 2;	
		record.LVDataList[1].FirstLineOffsetX=4;
	}
	
	record.LVDataList[1].szData         = rewardName;
	record.LVDataList[1].textAlignment  = TA_Left;

	// 대만 중국을 제외 하면 왼쪽 정렬
	Debug ("해외 확인이 필요함!!!.");
	/*
	switch(GetLanguageCustom()) 
	{
		case ELanguageType.LANG_Taiwan  :
		case ELanguageType.LANG_Chinese : record.LVDataList[1].textAlignment = TA_CENTER; break;	
		default : record.LVDataList[1].textAlignment = TA_LEFT;
	}*/
	
	//0,2 정렬 센터
	record.LVDataList[0].textAlignment = TA_CENTER;
	record.LVDataList[2].textAlignment = TA_CENTER;

	//잠김 상태 유무(레벨, 요일) -- param 값에 추가하여 사용
	ParamAdd( param, "rewardBool", rewardBool );
	//수령 가능 여부 -- param 값에 추가하여 사용
	ParamAdd( param, "Block", String(Block) );
	//record에 추가.
	record.szReserved = param;
	record.nReserved1 = rewardID; 
	record.nReserved2 = serverID;
	//정렬을 위해 배열에 insert
	todoArray.Insert( todoArray.Length, 1 );
	todoArray[ todoArray.Length - 1].record = record;
	todoArray[ todoArray.Length - 1].sort0 = nSort;
	todoArray[ todoArray.Length - 1].sort1 = NewEvent;
}

/**
 *  일일 미션 리스트 받음 완료
 **/
function OneDayRewardListEnd( string param )
{
	local int i;
	//정렬 New, Event 기준
	//todoArray.Sort(OnSortCompare1);
	//정렬 상태 기준
	//todoArray.Sort(OnSortCompare);

	for( i = 0 ; i < todoArray.Length ; i++ )
	{
		//"전체 미션 보기" 체크 시 전부 보여줌
		if( AllLevelCheckBox.IsChecked() )
		{	
			ToDoList_ListCtrl.InsertRecord( todoArray[ i ].record );
		}
		//"전체 미션 보기" 해제 시 잠금 상태 보여 주지 않음
		else
		{
			if( todoArray[i].sort0 != 3 )
			{
				ToDoList_ListCtrl.InsertRecord( todoArray[ i ].record );
			}
		}   
	}	
	//이전에 선택된 것이 있다면 선택
	if( saveIndex < 1 )
	{
		ToDoList_ListCtrl.SetSelectedIndex( 0, true );
	}
	else
	{
		ToDoList_ListCtrl.SetSelectedIndex( saveIndex, true );
	}
	//리스트 클릭 함수
	OnClickListCtrlRecord("DailyRewardListCtrl");
}

/** 
 *  일일 미션 시스템 보상 목록 받기 (classID(아이템클래스ID(int)), itemCount(아이템개수(int))) 
 **/
function OneDayRewardItemList( string param )
{
	//아이템info
	local ItemInfo itemInfo;
	/***  param 값 ----- ***/
	//아이템 ID
	local ItemID   itemID;
	//아이템 개수
	local int itemCount;
	/***  param 값 ----- ***/

	/***  param 값 셋팅 ----- ***/	
	ParseItemID( param, itemID );
	ParseINT(param, "itemCount", itemCount);
	/***  param 값 셋팅 ----- ***/	

	//itemID로 아이템info 받기
	class'UIDATA_ITEM'.static.GetItemInfo( itemID, itemInfo );

	itemInfo.itemNum = itemCount;
	//아이템 넣기
	DailyRewardItem.AddItem( itemInfo );
}

/** 
 *  체크 박스 클릭 시
 **/
function OnClickCheckBox( String strID )
{
	switch( strID )
	{
		//"전체 미션 보기" 체크 박스 클릭 시
		case "AllLevelCheckBox": 
			SetOptionToDo();
			RefreshList();
			break;
	}
}
/** 
 *  버튼 클릭 시
 **/
function OnClickButton( string Name )
{
	switch( Name )
	{
		//목록 갱신 버튼 클릭
		case "RefreshBtn":
			//목록 갱신용 타이머 시작
			Me.SetTimer( TIMER_CLICK, TIMER_DELAYC );
			//버튼 비활성
			RefreshBtn.DisableWindow();
			//목록 갱신
			RefreshList();
			break;
		//닫기 버튼 클릭
		case "EssentialBtn":
			Me.HideWindow();
			break;
		//보상 받기 버튼 클릭
		case "RewardBtn":
			RequestOneDayRewardReceive(selectServerID);
			break;
		//출현지역 버튼 클릭
		case "LocalfindBtn_BTN":
			LocalfindBtnClick();
			break;
	}
}
/**
 * 출현지역 버튼 클릭
 **/
function LocalfindBtnClick()
{
	local LVDataRecord Record;
	//좌표 벡터 값
	local Vector XYZ;
	//좌표 x,y,z 값
	local float x, y, z;
	local string param;
	//미니맵
	local MinimapWnd            mapScript ;
	//미니맵 컨트롤
	local MinimapCtrlHandle     m_MiniMap;

	mapScript = MinimapWnd( GetScript( "MinimapWnd"));
	m_MiniMap = GetMinimapCtrlHandle( "MinimapWnd.Minimap" );
	
	//저장된 index로 record 값 받음
	ToDoList_ListCtrl.GetRec( saveIndex, Record );
	param = Record.szReserved;
	
	//미니맵 열기
	if (!GetWindowHandle("MinimapWnd").IsShowWindow())
	{
		GetWindowHandle("MinimapWnd").ShowWindow();	
		GetWindowHandle("MinimapWnd").SetFocus();
	}
	
	//x,y,z 값 받음
	ParseFloat ( param, "TargetX", x );
	ParseFloat ( param, "TargetY", y );
	ParseFloat ( param, "TargetZ", z );
	//벡터 생성
	XYZ.x = int(x) ;
	XYZ.y = int(y) ;
	XYZ.z = int(z) ;

	//위치 이동
	mapScript.SetContinent(m_MiniMap.GetContinent(XYZ));	
	class'UIAPI_MINIMAPCTRL'.static.AdjustMapView( "MinimapWnd.Minimap", XYZ, false );
	//원 그리기
	class'UIAPI_MINIMAPCTRL'.static.SetDailyQuest( "MinimapWnd.Minimap", true, selectRewardID );
}

/** 
 *  오픈 처리
 **/
function openProcess(string a_param)
{	
	local UserInfo myInfo;
	local int nforceOpen;

	if ( !GetPlayerInfo (myInfo ) ) return;
	ParseInt(a_param, "forceOpen", nforceOpen);

	//  1랩은 예외 처리 , forceOpen 1과 같다면 무조건 열기 
	if (myInfo.nLevel > 1 || nforceOpen == 1) getInstanceL2Util().toggleWindow("ToDoListWnd", true);	
}


/**  
 *   리스트 클릭
 **/
function OnClickListCtrlRecord( string ListCtrlID )
{
	local int rewardID, serverID, CurrentCount, MaxCount;
	local LVDataRecord Record;
	local string param, rewardBool;
	local int ResetPeriod;
	local int ShowQuestRange;
	local string Block;

	saveIndex = ToDoList_ListCtrl.GetSelectedIndex();

	if (saveIndex >= 0) 
	{
		ToDoList_ListCtrl.GetSelectedRec(Record);
		
		param = Record.szReserved;

		ParseINT(param,    "ResetPeriod"        , ResetPeriod);
		ParseINT(param,    "rewardID"           , rewardID);
		ParseINT(param,    "serverID"           , serverID);
		ParseINT(param,    "ShowQuestRange"     , ShowQuestRange);
		ParseINT(param,    "CurrentCount"       , CurrentCount);
		ParseINT(param,    "MaxCount"           , MaxCount);

		ParseString(param, "rewardBool"         , rewardBool);
		ParseString(param, "Block"              , Block);

		selectRewardID = rewardID;
		selectServerID = serverID;

		//미션 이름 넣기
		MissionName_Text.SetText( Record.LVDataList[1].szData );		
		//주기
		MissionDateName_Text.SetTextColor( setTextColor( ResetPeriod ) );
		switch( ResetPeriod )
		{
			//일일
			case 1:
				MissionDateName_Text.SetText( GetSystemString(3583) );
				break;
			//주간
			case 2:
				MissionDateName_Text.SetText( GetSystemString(3584) );
				break;
			//월간
			case 3:
				MissionDateName_Text.SetText( GetSystemString(3585) );
				break;
			//일회성
			case 4:
				MissionDateName_Text.SetText( GetSystemString(3582) );
				break;
		}

		//보상 아이템 리스트 요청 
		RequestOneDayRewardItemList( rewardID ); 
		//보상조건
		rewardDesc = RequestOneDayRewardDesc( rewardID ); 		

		//보상 수령 가능 상태 일때
		if( rewardBool == "t" )
		{
			//보상 받기
			RewardBtn.SetButtonName( 2279 );
			RewardBtn.enableWindow();
		}
		else
		{
			//수령 불가
			RewardBtn.SetButtonName( 3604 );
			RewardBtn.disableWindow(); 
		}
		//사냥 미션이 아닐 경우
		if( ShowQuestRange == 0 )
		{
			//출현 지역 버튼 제거
			LocalfindBtn_BTN.DisableWindow();
			LocalfindBtn_BTN.HideWindow();
		}
		else
		{
			//출현 지역 버튼 보여줌
			LocalfindBtn_BTN.showWindow();
			LocalfindBtn_BTN.enableWindow();			
		}		
		//잠김 상태라면
		if( Block == "True")
		{
			//자물쇠 아이콘 생성
			IconLock_texture.ShowWindow();
		}
		else
		{
			//자물쇠 아이콘 제거
			IconLock_texture.hideWindow();
		}
		//statusbar 숫자 추가
		Completegage_statusbar.SetPoint( CurrentCount, MaxCount );

		rewardInfo();
	}	
}


/** 
 *  완료 조건, 남은 시간 표현 및 스크롤 on/off
 **/
function rewardInfo()
{	
	//높이 값
	local int resultHeight;
	selectIndexPeriod();

	//TimedDescriotion_Text 남은 시간 표현 후 텍스트 높이
	resultHeight = setTextFieldHight( TimedDescriotion_Text, timeToString() );
	//TimedWnd_scrollarea, 텍스트 필드 시작 점 + 필드 크기 + 간격
	TimedWnd_scrollarea.SetWindowSize ( 266, resultHeight + 30 );	
	
	//CompleteDescriotion_Text 완료 조건 표현 후 텍스트 높이
	resultHeight = setTextFieldHight( CompleteDescriotion_Text, rewardDesc );
	//CompleteDescriotion_Text, 텍스트 필드 시작 점 + 필드 크기 + 간격
	CompleteWnd_scrollarea.SetWindowSize ( 266, resultHeight + 53 );	
	
	//스크롤 초기화
	areaScroll.SetScrollPosition( 0 ) ;
	//크기에 따른 스크롤 셋팅
	areaScroll.SetScrollHeight( RewardInfoWnd_scrollarea.GetRect().nHeight + TimedWnd_scrollarea.GetRect().nHeight + CompleteWnd_scrollarea.GetRect().nHeight );
}

/**
 * 텍스트 길이에 맞춰 텍스트 높이를 조절 함. 동원이가 만듦
 **/
function int setTextFieldHight ( TextBoxHandle txtWnd, String text ) 
{
	local int nWidth, nHeight, defaultHeight, i, descHeight ;
	local string sNextStringWithWidth;

	txtWnd.SetText ( text );

	// defaultHeight 를 얻어 옴
	GetTextSizeDefault(text, nWidth, defaultHeight);

	// nWidth 를 얻어 옴
	CompleteDescriotion_Text.GetWindowSize( nWidth, nHeight );

	// 총 몇줄로 나뉘는지 얻어 옴 
	i = 0;
	sNextStringWithWidth = DivideStringWithWidth( text, nWidth );	
	while ( sNextStringWithWidth != "" ) 
	{
		sNextStringWithWidth = NextStringWithWidth(nWidth);	
		i ++ ;
	}
	
	descHeight = i * ( defaultHeight + 1 ) ; 
	txtWnd.SetWindowSize ( nWidth, descHeight );

	return descHeight;
}

/**
 * 시간 타이머 && 목록 갱신 타이머 이벤트
 ***/
function OnTimer(int TimerID) 
{
	//각 시간 업데이트
	if( TimerID == TIMER_ID )
	{
		DayRemainTime--;
		WeekRemainTime--;
		MonthRemainTime--;

		TimedDescriotion_Text.SetText( timeToString() );
	}
	//목록갱신 버튼 활성화
	else if( TimerID == TIMER_CLICK )
	{
		RefreshBtn.EnableWindow();
		Me.KillTimer( TIMER_CLICK );
	}
}


/**
 * 각 주기별 시간 정보를 표시
 **/
function string timeToString()
{
	local string str;

	switch( selectIndexPeriod() )
	{
		//일일
		case 1:			
			str = getTimeStringBySec( DayRemainTime );
			break;
		//주간
		case 2:			
			str = getTimeStringBySec( WeekRemainTime );
			break;
		//월간
		case 3:
			str = getTimeStringBySec( MonthRemainTime );
			break;
		//일회
		case 4:
			str = GetSystemString(1792);
			break;
	}
	return str;
}

/**
 * 일/시간/분 || 시간/분 || //분 || //1분미만 으로 시간 바꿔줌
 **/
function string getTimeStringBySec(int sec)
{
	local int timeTemp, timeTemp0, timeTemp1;
	local string returnStr;

	returnStr = "";
	timeTemp = ((sec / 60) / 60 / 24);
	timeTemp0 = ((sec / 60) / 60);
	timeTemp1 = ((sec / 60));

	if( timeTemp > 0 )
	{
		//일/시간/분
		returnStr =  MakeFullSystemMsg(GetSystemMessage(4466), string(timeTemp), string(int( (sec / 60) / 60 % 24 ) ), string(int((sec / 60) % 60)));
	}
	else if( timeTemp0 > 0 )
	{
		//시간/분
		returnStr = MakeFullSystemMsg(GetSystemMessage(3304), string(timeTemp0), string(int((sec / 60) % 60)));
	}
	else if( timeTemp1 > 0 )
	{
		//분
		returnStr = MakeFullSystemMsg(GetSystemMessage(3390), string(timeTemp0));
	}
	else
	{
		//1분미만
		returnStr = GetSystemMessage(4360);
	}
	return returnStr;	 
}

/**
 * 선택한 list index의 주기
 **/
function int selectIndexPeriod()
{
	local LVDataRecord Record;	
	local string param;

	ToDoList_ListCtrl.GetSelectedRec( Record );

	//선택한 list가 없는 경우가 있음
	if( Record.szReserved != "" ) 
	{
		param = Record.szReserved;
		//그래서 local 변수 사용 하면 않됨.
		ParseINT( param, "ResetPeriod", nResetPeriod );
	}
	return nResetPeriod;
}

/**
 * 주기에 따른 색상 값 셋팅
 **/
function color setTextColor(int n)
{	
	local color returnColor;

	switch( n )
	{
		//일일
		case 1:
			returnColor      = Y;
			break;
		//주간
		case 2:
			returnColor      = R;
			break;
		//월간
		case 3:
			returnColor      = B;
			break;
		//일회
		case 4:
			returnColor      = Y;
			break;
	}
	return returnColor;
}


/** 옵션을 세팅 : 항상 시작 할때 보여 줄 것인가? */
function SetOptionToDo()
{	
	local bool bChecked;

	bChecked = AllLevelCheckBox.IsChecked();
	SetOptionBool( "UI", "TodoList", bChecked );
}

/** 옵션 로드  */
function loadOptionToDo()
{
	local bool bChecked;

	bChecked = getOptionBool( "UI", "TodoList");
	AllLevelCheckBox.SetCheck(bChecked);
}

/** 
 *  목록갱신  
 *  */
function RefreshList()
{
	RequestTodoListOneDayReward();
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( getCurrentWindowName(string(Self))).HideWindow();
}

delegate int OnSortCompare( ToDoListInfo a, ToDoListInfo b )
{
    if (a.sort0 > b.sort0) // 오름 차순. 조건문에 < 이면 내림차순.
    {
        return -1;  // 자리를 바꿔야할때 -1를 리턴 하게 함.
    }
    else
    {
        return 0;
    }
}
delegate int OnSortCompare1( ToDoListInfo a, ToDoListInfo b )
{
    if (a.sort1 < b.sort1) // 오름 차순. 조건문에 < 이면 내림차순.
    {
        return -1;  // 자리를 바꿔야할때 -1를 리턴 하게 함.
    }
    else
    {
        return 0;
    }
}
defaultproperties
{
}
