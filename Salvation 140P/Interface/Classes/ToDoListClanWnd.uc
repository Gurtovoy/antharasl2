/**  
 *   제목  : 혈맹 미션 
 **/
class ToDoListClanWnd extends UICommonAPI;

var WindowHandle Me;
var CheckBoxHandle AllLevelCheckBox;
var ListCtrlHandle ToDoList_ListCtrl;
var TextBoxHandle MissionName_Text;
var TextureHandle IconLock_texture;
var TextBoxHandle MissionDateName_Text;
var ButtonHandle RefreshBtn;
var ButtonHandle EssentialBtn;
var ButtonHandle RewardBtn;
var WindowHandle CompleteWnd_scrollarea;
var TextBoxHandle CompleteDescriotion_Text;
var WindowHandle ConditionWnd_scrollarea;
var TextBoxHandle ConditionDescriotion_Text;
var WindowHandle RewardInfoWnd_scrollarea;

var ItemWindowHandle DailyRewardItem;
var StatusBarHandle Completegage_statusbar;
var WindowHandle	areaScroll;

var TextBoxHandle ClanFameInput_Text;
var TextBoxHandle PrivateFameInput_Text;
var TextBoxHandle WeekMissionNum_Text;

var TextBoxHandle WeekMission_Text;
var ButtonHandle HelpButton;
var TabHandle ToDoListClan_TabCtrl;

var WindowHandle toDoDisable_Wnd;
var WindowHandle todoComplete_Wnd;


//정렬을 위한 struct 값 sort0, sort1로 정렬함.
struct ToDoListInfo
{
	var LVDataRecord        record;
	var int			        sort0;
	var int			        sort1;	
};
//정렬을 위한 배열
var Array<ToDoListInfo> todoArray;

//목록 갱신용 타이머 ID
const TIMER_CLICK       = 99901;
//목록 갱신용 타이머 딜레이 3초
const TIMER_DELAYC       = 3000;

// 현재 보상 수령한 수량
var int curRewardCount;
// 최대 보상 수령 가능 수량
var int maxRewardCount;

struct ToDoListClanData
{
	// 미션 ID	
	var int missionID ;
	// 현재 진행 수량
	var int progressCount;
	// 상태 (0:완료, 1: 수행불가, 2: 수행중지, 3: 수행중, 4:보상수령가능)
	var int curState; 
	// 구분 (1:일반, 2:심화, 3:업적, 4:이벤트 )
	var int category;
	// 이벤트 기간인지 여부
	var bool isEventPeroid;
};

const STATE_COMPLETE  = 0 ;
const STATE_BLOCK     = 1;
const STATE_PROCESS   = 2;
const STATE_REWARD    = 3;


//폰트 색상 노랑, 붉은, 보라
var color Y, R, V;

var int currentTabIndex ;

const TAB_NORMAL        = 1;
const TAB_DEEPENING     = 2;
const TAB_ACHIEVEMENTS  = 3;
const TAB_EVENT         = 4;

var array <ToDoListClanData> toDoClanArray;

var int serverStartTime;

var int numOfEventList;
var int numOfRewardList;

var int clientStartSec ;

function OnRegisterEvent()
{
	//혈맹 미션 정보 이벤트
	RegisterEvent(EV_PledgeMissionInfo);
	//혈맹 미션 보상 수량 정보(현재/최대) 이벤트
	RegisterEvent(EV_PledgeMissionRewardCount);

	RegisterEvent(EV_Restart);

//	RegisterEvent ( EV_test_7 ) ;

	RegisterEvent(EV_CurrentserverTime);
}

function Initialize()
{
	Me = GetWindowHandle( "ToDoListClanWnd" );
	AllLevelCheckBox = GetCheckBoxHandle( "ToDoListClanWnd.AllLevelCheckBox" );
	ToDoList_ListCtrl = GetListCtrlHandle( "ToDoListClanWnd.ToDoList_Wnd.ToDoList_ListCtrl" );
	MissionName_Text = GetTextBoxHandle( "ToDoListClanWnd.DetailInfo_Wnd.MissionName_Text" );
	IconLock_texture = GetTextureHandle( "ToDoListClanWnd.DetailInfo_Wnd.IconLock_texture" );
	MissionDateName_Text = GetTextBoxHandle( "ToDoListClanWnd.DetailInfo_Wnd.MissionDateName_Text" );

	RefreshBtn = GetButtonHandle( "ToDoListClanWnd.RefreshBtn" );
	EssentialBtn = GetButtonHandle( "ToDoListClanWnd.EssentialBtn" );

	areaScroll                  = GetWindowHandle       (   "ToDoListClanWnd.DetailInfo_Wnd.DetailInfo_ScrollArea" );

	RewardInfoWnd_scrollarea     = GetWindowHandle      (   "ToDoListClanWnd.DetailInfo_Wnd.DetailInfo_ScrollArea.RewardInfoWnd_scrollarea" );
	RewardBtn                   = GetButtonHandle       (   "ToDoListClanWnd.DetailInfo_Wnd.DetailInfo_ScrollArea.RewardInfoWnd_scrollarea.RewardBtn" );
	DailyRewardItem             = GetItemWindowHandle	(   "ToDoListClanWnd.DetailInfo_Wnd.DetailInfo_ScrollArea.RewardInfoWnd_scrollarea.DailyRewardItem" );

	CompleteDescriotion_Text    = GetTextBoxHandle      (   "ToDoListClanWnd.DetailInfo_Wnd.DetailInfo_ScrollArea.CompleteWnd_scrollarea.CompleteDescriotion_Text" );
	CompleteWnd_scrollarea      = GetWindowHandle       (   "ToDoListClanWnd.DetailInfo_Wnd.DetailInfo_ScrollArea.CompleteWnd_scrollarea" );
	//LocalfindBtn_BTN            = GetButtonHandle       (   "ToDoListClanWnd.DetailInfo_Wnd.DetailInfo_ScrollArea.CompleteWnd_scrollarea.LocalfindBtn_BTN" );
	Completegage_statusbar      = GetStatusBarHandle    (   "ToDoListClanWnd.DetailInfo_Wnd.DetailInfo_ScrollArea.CompleteWnd_scrollarea.Completegage_statusbar" );

	ConditionDescriotion_Text       = GetTextBoxHandle      (   "ToDoListClanWnd.DetailInfo_Wnd.DetailInfo_ScrollArea.ConditionWnd_scrollarea.ConditionDescriotion_Text" );
	ConditionWnd_scrollarea         = GetWindowHandle       (   "ToDoListClanWnd.DetailInfo_Wnd.DetailInfo_ScrollArea.ConditionWnd_scrollarea" );

	WeekMissionNum_Text         = GetTextBoxHandle      (   "ToDoListClanWnd.WeekMissionNum_Text" );

	WeekMission_Text            = GetTextBoxHandle      (   "ToDoListClanWnd.WeekMission_Text" );
	HelpButton                  = GetButtonHandle      (   "ToDoListClanWnd.HelpButton" );

	ClanFameInput_Text         = GetTextBoxHandle      (   "ToDoListClanWnd.DetailInfo_Wnd.RewardInfoWnd_scrollarea.ClanFameInput_Text" );
	PrivateFameInput_Text      = GetTextBoxHandle      (   "ToDoListClanWnd.DetailInfo_Wnd.RewardInfoWnd_scrollarea.PrivateFameInput_Text" );	

	ToDoListClan_TabCtrl        = GetTabHandle          ( "ToDoListClanWnd.ToDoListClan_TabCtrl" );	

	toDoDisable_Wnd             = GetWindowHandle      (   "ToDoListClanWnd.TodoDisable_Wnd" );
	todoComplete_Wnd            = GetWindowHandle      (   "ToDoListClanWnd.TodoComplete_Wnd" );;           

	
	R.R = 255;
	R.G = 153;
	R.B = 153;

	Y.R = 255;
	Y.G = 255;
	Y.B = 187;

	V.R = 238;
	V.G = 170;
	V.B = 255;

	numOfEventList = 0 ;
	numOfRewardList = 0 ;
}


/*************************************************************************************************** 
 *  이벤트 핸들
 *****************************************************************************************************/
/**  OnLoad  */
function OnLoad()
{		
	Initialize();	
	setResultEmpty();
	registerState(getCurrentWindowName(string(Self)), "GamingState" );
	SetClosingOnESC(); 
	//옵션 로드
	loadOptionToDo();
	refreshByTabIndexChage(TAB_NORMAL);

	HelpButton.SetTooltipCustomType(getCustomTooltip(GetSystemString(3688)));
}

/**  onShow  */
function onShow()
{	
	//목록 가져오기
	Me.SetTimer( TIMER_CLICK, TIMER_DELAYC );
	//버튼 비활성
	RefreshBtn.DisableWindow();
	//목록 갱신
	RequestPledgeMissionInfo();

	Me.SetFocus();
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
			refreshData ();
			break;
	}
}

/**
 * 시간 타이머 && 목록 갱신 타이머 이벤트
 ***/
function OnTimer(int TimerID) 
{
	if( TimerID == TIMER_CLICK )
	{
		RefreshBtn.EnableWindow();
		Me.KillTimer( TIMER_CLICK );
	}
}


/** 
 *  버튼 클릭 시
 **/
function OnClickButton( string Name )
{
	//Debug ( "OnClickButton" @ Name );
	switch( Name )
	{
		//목록 갱신 버튼 클릭
		case "RefreshBtn":
			//목록 갱신용 타이머 시작
			Me.SetTimer( TIMER_CLICK, TIMER_DELAYC );
			//버튼 비활성
			RefreshBtn.DisableWindow();
			//목록 갱신
			RequestPledgeMissionInfo();
			break;
		//닫기 버튼 클릭
		case "EssentialBtn":
			Me.HideWindow();
			break;
		//보상 받기 버튼 클릭
		case "RewardBtn":
			requestReward();			
			break;		
		case "ToDoListClan_TabCtrl0" :
			refreshByTabIndexChage ( TAB_NORMAL ) ;
			break;
		case "ToDoListClan_TabCtrl1" :
			refreshByTabIndexChage ( TAB_DEEPENING ) ;
			break;
		case "ToDoListClan_TabCtrl2" :
			refreshByTabIndexChage ( TAB_ACHIEVEMENTS ) ;
			break;
		case "ToDoListClan_TabCtrl3" :
			refreshByTabIndexChage ( TAB_EVENT ) ;
			break;
		case "WndHelp_Button" :
			ExecuteEvent(EV_ShowHelp, "152");
			break;
	}
}


/**  OnEvent  */
function OnEvent( int a_EventID, String param )
{
	//Debug ( "OnEvent " @ a_EventID @ param );
	switch( a_EventID )
	{		
		case EV_PledgeMissionInfo :		
			handlePledgeMissionInfo ( param ) ;
			//Debug ( "EV_PledgeMissionInfo" @ param ) ;
		break;
		case EV_PledgeMissionRewardCount :
			handlePledgeMissionRewardCount ( param ) ;
			//Debug ( "EV_PledgeMissionRewardCount" @ param ) ;
		break;
		// show 시키고 
		//case EV_test_7 : 
		//	Me.ShowWindow();
		break;
		// 리스트 클리어 
		case EV_Restart :
			ToDoList_ListCtrl.DeleteAllItem();
			toDoClanArray.Length = 0 ;
			numOfEventList = 0 ;
			clientStartSec = 0;
			numOfRewardList = 0 ;
		break;

		case  EV_CurrentserverTime :
			//Debug("---> EV_CurrentserverTime" @ param);
			setCurrentserverTime(param);
		break;
	}
}


/**  
 *   리스트 클릭
 **/
function OnClickListCtrlRecord( string ListCtrlID )
{	
	local LVDataRecord Record;
	/* 
	 * 혈맹 미션 
	 * */
	local PledgeMissionUIData pledgeMissionUIDataOut;

	//saveIndex = ToDoList_ListCtrl.GetSelectedIndex();

	//Debug ( "OnClickListCtrlRecord" @ ToDoList_ListCtrl.GetSelectedIndex() );

	if (ToDoList_ListCtrl.GetSelectedIndex() >= 0) 
	{
		ToDoList_ListCtrl.GetSelectedRec(Record);		
		
		GetPledgeMissionData ( int(Record.szReserved), pledgeMissionUIDataOut )  ;		
		//Debug ( "완료" @ pledgeMissionUIDataOut.GoalDesc @ pledgeMissionUIDataOut.Condition.PledgeLevel );
		
		// 개요
		setResultTitle ( Record.LVDataList[1].szData, pledgeMissionUIDataOut.isRepeat, toDoClanArray[ int(Record.nReserved1) ].curState ) ;
		// 보상
		setResultReward ( pledgeMissionUIDataOut.RewardItems, pledgeMissionUIDataOut.RewardPledgeNameValue, pledgeMissionUIDataOut.RewardPVPPoint, toDoClanArray[ int(Record.nReserved1) ].curState ) ; 
		// 수행 조건
		setResultConditions ( pledgeMissionUIDataOut.Condition );
		// 완료 조건
		setResultGoalCondition (pledgeMissionUIDataOut.GoalDesc, toDoClanArray[ int(Record.nReserved1) ].progressCount, pledgeMissionUIDataOut.GoalCount ) ;
		// 스크롤 변경
		//스크롤 초기화
		areaScroll.SetScrollPosition( 0 ) ;
		//크기에 따른 스크롤 셋팅
		areaScroll.SetScrollHeight( RewardInfoWnd_scrollarea.GetRect().nHeight + ConditionWnd_scrollarea.GetRect().nHeight + CompleteWnd_scrollarea.GetRect().nHeight );
	}	
}

/**********************************************************************************************
 * 이벤트 기간 처리
 * ************************************************************************************************/
function setCurrentserverTime(string param)
{
	// 서버 시간
	ParseInt(param, "ServerTime", serverStartTime);
	clientStartSec = GetAppSeconds();
}

// 이벤트 (날짜) 기간인가?
function bool isEventPeroid(PledgeMissionCondition condition)
{
	local L2UITime l2UITime;	
	//local string zeroString, dateString;	

	//Debug ( "isEventPeroid " @ condition.StartDate @  condition.StartTime @  condition.EndDate @  condition.EndTime );
	//Debug ( "isEventPeroid " @ l2UITime.nYear @  l2UITime.nMonth @  l2UITime.nDay );
	local int curDate, curTime;

	if ( condition.StartDate == 0  ) return true;
	GetTimeStruct( serverStartTime + GetAppSeconds() - clientStartSec, l2UITime) ;

    // 2017.01.02 => 170102 변환
    curDate = ((l2UITime.nYear % 100) * 10000) + (l2UITime.nMonth * 100) + l2UITime.nDay;

    // 18:30 => 1830 변환
    curTime = (l2UITime.nHour * 100) + l2UITime.nMin;

    // 기간(date + time) 검사.
    if (condition.StartDate > 0  && condition.EndDate > 0)
    {
        if (curDate < condition.StartDate || curDate > condition.EndDate)
            return false;

        if (curDate == condition.StartDate && curTime < condition.StartTime)
            return false;

        if (curDate == condition.EndDate && curTime >= condition.EndTime)
            return false;
    }

    return true;

	//zeroString = getInstanceL2Util().makeZeroString(6, condition.StartDate);
		
	//dateString = l2UITime.nYear $ getInstanceL2Util().makeZeroString(2, l2UITime.nMonth) $ getInstanceL2Util().makeZeroString(2, l2UITime.nDay);
	
	//if ( l2UITime.nYear < 2000 + int (Mid(zeroString, 0, 2) )) return false;
	//if ( l2UITime.nMonth < int (Mid(zeroString, 2, 2) )) return false;
	//if ( l2UITime.nDay < int (Mid(zeroString, 4, 2) )) return false;

	//// 시작 일자가 오늘이며, 시간이 0이 아닌 경우 
	////Debug ( dateString @  "20" $ zeroString @ dateString  == ( "20" $ zeroString ) ) ;
	//if ( dateString == ( "20" $ zeroString ) && condition.StartTime != 0 ) 
	//{
	//	zeroString = getInstanceL2Util().makeZeroString(4, condition.StartTime);
	//	if ( l2UITime.nHour < int (Mid(zeroString, 0, 2) )) return false;
	//	if ( l2UITime.nMin < int (Mid(zeroString, 2, 2) )) return false;
	//}

	//zeroString = getInstanceL2Util().makeZeroString(6, condition.EndDate);
	//if ( l2UITime.nYear > 2000 + int (Mid(zeroString, 0, 2) )) return false;
	//if ( l2UITime.nMonth > int (Mid(zeroString, 2, 2) )) return false;
	//if ( l2UITime.nDay > int (Mid(zeroString, 4, 2) )) return false;
	
	//if ( dateString == ( "20" $ zeroString ) && condition.EndTime != 0 ) 
	//{
	//	zeroString = getInstanceL2Util().makeZeroString(4, condition.EndTime);
	//	if ( l2UITime.nHour < int (Mid(zeroString, 0, 2) )) return false;
	//	if ( l2UITime.nMin < int (Mid(zeroString, 2, 2) )) return false;
	//}
	
	//return true;
}



/**********************************************************************************************
 * 이벤트 및 데이타 처리
 * ************************************************************************************************/
function handleEventMissionNum ( int idx, bool isEventPeroid  ) 
{	
	// 변경 시 
	if ( idx != -1 )
	{
		if ( isEventPeroid != toDoClanArray[idx].isEventPeroid)
			if ( isEventPeroid ) numOfEventList ++; else numOfEventList--;
	// 추가 시 
	} else if ( isEventPeroid ) numOfEventList ++ ;

	ToDoListClan_TabCtrl.SetDisable( 3 , numOfEventList == 0 ) ;
}

function handleCompletedMissionNum ( int idx, bool isRwardState, bool isEventPeroid ) 
{	
	// 변경 시 
	local NoticeWnd script ;
	local string param ;
	local int oldNumOfRewardList;

	script = NoticeWnd( GetScript( "NoticeWnd"));
	
	oldNumOfRewardList = numOfRewardList;
	//Debug ( "handleCompletedMissionNum" @ isRwardState  @ isEventPeroid) ;

	if ( idx != -1 )
	{
		// 이벤트 기간이나 완료 상태가 바뀐 경우
		if ( toDoClanArray[idx].isEventPeroid != isEventPeroid || isRwardState != (toDoClanArray[idx].curState == STATE_REWARD)) 
			if ( isRwardState && isEventPeroid ) numOfRewardList ++; else numOfRewardList--;
	// 추가 시 
	} else if ( isRwardState && isEventPeroid ) numOfRewardList ++ ;
	
	//Debug ( "handleCompletedMissionNum" @ numOfRewardList) ;
	// 알림 메시지 추가
	// 변경 된것이 없으면 알림에 메시지 주지 말 것
	if ( oldNumOfRewardList == numOfRewardList ) return;

	if ( numOfRewardList == 0 ) script.removeNoticeButton( script.ENoticeType.TYPE_TODOLIST ) ;	
	else 
	{
		param = "";
		paramAdd( param , "rewardCount", String(numOfRewardList) ) ;
		script.createNoticeButtonWithParam(script.ENoticeType.TYPE_TODOLIST, 3670, param); 
	}
}

function handlePledgeMissionInfo( string param ) 
{	
	local int idx, listIndex;
	local ToDoListClanData tmpToDoListClanDataOut;
	local PledgeMissionUIData tmpPledgeMissionUIData;		

	parseInt ( param , "MissionID" , tmpToDoListClanDataOut.missionID ) ;
	parseInt ( param , "ProgressCount" , tmpToDoListClanDataOut.progressCount ) ;
	parseInt ( param , "CurState" , tmpToDoListClanDataOut.curState) ;

	//Debug ( "!! handlePledgeMissionInfo " @ tmpToDoListClanDataOut.missionID  @ tmpToDoListClanDataOut.progressCount  @ tmpToDoListClanDataOut.curState) ;
	
	if ( !GetPledgeMissionData( tmpToDoListClanDataOut.missionID, tmpPledgeMissionUIData )) return;

	tmpToDoListClanDataOut.category = tmpPledgeMissionUIData.Category ;
	// 이벤트 기간인지를 받음 
	tmpToDoListClanDataOut.isEventPeroid = isEventPeroid( tmpPledgeMissionUIData.Condition );

	idx = findIdx ( tmpToDoListClanDataOut.missionID ) ;	

	handleEventMissionNum( idx, tmpToDoListClanDataOut.isEventPeroid ) ;
	handleCompletedMissionNum( idx, tmpToDoListClanDataOut.curState == STATE_REWARD, tmpToDoListClanDataOut.isEventPeroid ) ;

	// 처음 들어가는 경우 
	if ( idx == -1 ) 
	{
		idx = toDoClanArray.Length ;
		toDoClanArray.Length = toDoClanArray.Length + 1 ;
		toDoClanArray[idx] = tmpToDoListClanDataOut ;

		if ( tmpPledgeMissionUIData.Category == currentTabIndex ) listinsert ( idx ) ;
	}
	else 
	{	
		toDoClanArray[idx] = tmpToDoListClanDataOut;
		
		if ( tmpPledgeMissionUIData.Category == currentTabIndex ) 
		{			
			listIndex = findListIndex( idx ) ;
			
			// 리스트에 없는 경우 
			if ( listIndex == -1 ) listinsert ( idx ) ;
			// 리스트에 있는 경우
			else 
			{	
				if ( tmpPledgeMissionUIData.Category == TAB_EVENT && !tmpToDoListClanDataOut.isEventPeroid ) listDelete( listIndex ) ;
				else 
				{ 
					switch ( toDoClanArray[idx].curState )
					{
						// 블록 인 경우 체크 박스 상태에 따라 
						case STATE_BLOCK :
							if ( AllLevelCheckBox.IsChecked() ) listModify ( listIndex , idx) ;
							else listDelete( listIndex ) ;
						break;
						// 완료 인 경우 삭제
						case STATE_COMPLETE :
							listDelete( listIndex ) ;
						break;					
						default :
							listModify ( listIndex , idx ) ;
						break;
					}				
				}
			}			
		}
	}
	handleListEmpty() ;
}

function handleListEmpty () 
{
	if ( ToDoList_ListCtrl.GetRecordCount() == 0 ) 
	{
		// 일반 완료 시 
		if ( currentTabIndex == TAB_NORMAL && curRewardCount == maxRewardCount ) 
		{
			TodoDisable_Wnd.HideWindow();
			TodoComplete_Wnd.ShowWindow();			
		}
		else 
		{
			TodoComplete_Wnd.HideWindow();
			TodoDisable_Wnd.ShowWindow();			
		}
	}
	else 
	{
		TodoDisable_Wnd.HideWindow();
		TodoComplete_Wnd.HideWindow();
	}
}

function listinsert ( int idx ) 
{
	//Debug ("조건 1 " @ AllLevelCheckBox.IsChecked() || toDoClanArray[idx].curState != STATE_BLOCK ) ;
	//Debug ("조건 2 " @ toDoClanArray[idx].Category != TAB_EVENT || toDoClanArray[idx].isEventPeroid ) ;			
	//Debug ("조건 3 " @ currentTabIndex != TAB_NORMAL || curRewardCount != maxRewardCount ) ;
	if ( toDoClanArray[idx].curState != STATE_COMPLETE )
		if ( AllLevelCheckBox.IsChecked() || toDoClanArray[idx].curState != STATE_BLOCK ) 
			// 이벤트 텝이 아닌 경우 혹은 기간이 맞는 경우
			if ( toDoClanArray[idx].Category != TAB_EVENT || toDoClanArray[idx].isEventPeroid ) 				
				// 일반 탭이 아니거나, 일반 미션이 완료 되지 않은 경우
				if ( currentTabIndex != TAB_NORMAL || curRewardCount != maxRewardCount ) 
					ToDoList_ListCtrl.InsertRecord( makeMissionRecord ( idx ) ) ;
}

function listDelete ( int listIndex ) 
{		
	setResultEmpty();
	ToDoList_ListCtrl.DeleteRecord( listIndex ) ;
}

function listModify( int listIndex, int idx ) 
{
	ToDoList_ListCtrl.ModifyRecord ( listIndex , makeMissionRecord ( idx ) ) ;
	if ( listIndex == ToDoList_ListCtrl.GetSelectedIndex() ) OnClickListCtrlRecord("");
}

function refreshData ()
{
	local int i ; 

	ToDoList_ListCtrl.DeleteAllItem();

	for ( i = 0 ; i < toDoClanArray.Length ; i ++ ) 
		if ( toDoClanArray[i].Category == currentTabIndex )  
			listinsert ( i ) ;			
	
	handleListEmpty() ;
}


function handlePledgeMissionRewardCount ( string param ) 
{
	parseInt ( param , "CurRewardCount" , curRewardCount) ;
	parseInt ( param , "MaxRewardCount" , maxRewardCount) ;

	WeekMissionNum_Text.SetText( "("$String(curRewardCount)$"/"$String(maxRewardCount)$")");

	handleListEmpty();
	if ( currentTabIndex == TAB_NORMAL && curRewardCount == maxRewardCount ) 
	{
		ToDoList_ListCtrl.DeleteAllItem();
		TodoDisable_Wnd.HideWindow();
		TodoComplete_Wnd.ShowWindow();		
	}
}

function LVDataRecord makeMissionRecord ( int idx ) 
{
	local LVDataRecord record;
	local PledgeMissionUIData missionUIData;
	
	if ( !GetPledgeMissionData( toDoClanArray[idx].missionID,  missionUIData ) ) return record ;		

	/* 리스트에 필요한 정보 
	 * 수행 타입
	 * 미션 이름
	 * 상태
	 * */

	//3개
	record.LVDataList.Length = 3;
	//색상 들어감 3개다.
	record.LVDataList[0].buseTextColor = True;
	record.LVDataList[1].buseTextColor = True;		
	record.LVDataList[2].buseTextColor = True;

	
	//주기에 따른 색상 값 셋팅
	record.LVDataList[0].TextColor = setTextColor( missionUIData.IsRepeat );
	//주기별 시스템 메시지 
	if ( missionUIData.IsRepeat ) 
		record.LVDataList[0].szData = GetSystemString(1793);
	else 
		record.LVDataList[0].szData = GetSystemString(1792);
	
	//미션 제목 기본 값 셋팅 - 흰색
	record.LVDataList[1].TextColor = getInstanceL2Util().BrightWhite;

	// *2 이벤트 하드 코딩 부분
	if ( getIsEventMission (toDoClanArray[idx].missionID) ) 
	{
		record.LVDataList[1].hasIcon = true;

		record.LVDataList[1].szTexture = "L2UI_CT1.Clan.ClanMission_x2Icon";
		//record.LVDataList[1].IconPosX = getTextFieldWidth (missionUIData.MissionName) + 12;		
		record.LVDataList[1].IconPosX = 8;		
		record.LVDataList[1].nTextureWidth=24;
		record.LVDataList[1].nTextureHeight=24;
		record.LVDataList[1].nTextureU=24;
		record.LVDataList[1].nTextureV=24;

		//record.LVDataList[1].iconBackTexName = "L2UI_CT1.Clan.ClanMission_x2Icon";
		//record.LVDataList[1].backTexOffsetXFromIconPosX = getTextFieldWidth (missionUIData.MissionName) + 12;
		//record.LVDataList[1].backTexOffsetYFromIconPosY = 12;
		//record.LVDataList[1].backTexWidth = 24;
		//record.LVDataList[1].backTexHeight = 24;
		//record.LVDataList[1].backTexUL = 24;
		//record.LVDataList[1].backTexVL = 24 ;

		record.LVDataList[1].HiddenStringForSorting = "0" $ missionUIData.MissionName;		
	}
	else record.LVDataList[1].HiddenStringForSorting = "1" $ missionUIData.MissionName;

	record.LVDataList[1].szData         = missionUIData.MissionName;
	record.LVDataList[1].textAlignment  = TA_Left;		


	// 상태값 구분 
	switch( toDoClanArray[idx].curState )
	{
		// 수령가능
		case STATE_REWARD : 
			//색상 노랑
			record.LVDataList[2].TextColor = getInstanceL2Util().Yellow;
			//보상 수령 가능
			record.LVDataList[2].szData = GetSystemString(3586); 	
			record.LVDataList[2].HiddenStringForSorting = "0";
			break;
		// 잠김 or 진행중
		 case STATE_PROCESS :
			//진행도 StatusBar 추가		
			//Debug ( "안보일 때 progress"  @ record.bUseStatusBar);
			record.bUseStatusBar = true;
			record.nStatusBarIndex = 2; // 몇번째 컬럼에 추가할것인가.
			record.LVDataList[2].nStatusBarCurrentCount = toDoClanArray[idx].progressCount;
			record.LVDataList[2].nStatusBarMaxCount = missionUIData.GoalCount;

			//record.LVDataList[2].nTextureU=0;
			//record.LVDataList[2].nTextureV=0;

			record.strStatusBarForeLeftTex      = "L2UI_CT1.Gauges.Gauge_DF_Large_Weight_Left3";
			record.strStatusBarForeCenterTex    = "L2UI_CT1.Gauges.Gauge_DF_Large_Weight_Center3";
			record.strStatusBarForeRightTex     = "L2UI_CT1.Gauges.Gauge_DF_Large_Weight_Right3";

			record.strStatusBarBackLeftTex      = "L2UI_CT1.Gauges.Gauge_DF_Large_Weight_bg_Left3";
			record.strStatusBarBackCenterTex    = "L2UI_CT1.Gauges.Gauge_DF_Large_Weight_bg_Center3";
			record.strStatusBarBackRightTex     = "L2UI_CT1.Gauges.Gauge_DF_Large_Weight_bg_Right3";
			record.nStatusBarWidth = 110;
			record.nStatusBarHeight = 12;			
			record.LVDataList[2].HiddenStringForSorting = "1";
			break;
		//수행 불가
		case STATE_BLOCK :			
			//자물쇠 아이콘 추가
			record.LVDataList[2].hasIcon = true;
			record.LVDataList[2].nTextureWidth=14;
			record.LVDataList[2].nTextureHeight=14;
			record.LVDataList[2].nTextureU=14;
			record.LVDataList[2].nTextureV=14;
			record.LVDataList[2].szTexture = "L2UI_CT1.DailyMissionWnd_IconLock"; 
			record.LVDataList[2].IconPosX = 28;	
			record.LVDataList[2].FirstLineOffsetX=5;
			record.LVDataList[2].TextColor = R;
			record.LVDataList[2].szData = GetSystemString(3682);
			record.LVDataList[2].HiddenStringForSorting = "2";
			break;
	}	
	
	//0,2 정렬 센터
	record.LVDataList[0].textAlignment = TA_CENTER;
	record.LVDataList[2].textAlignment = TA_CENTER;

	//잠김 상태 유무(레벨, 요일) -- param 값에 추가하여 사용
	//ParamAdd( param, "rewardBool", rewardBool );
	//수령 가능 여부 -- param 값에 추가하여 사용
	//ParamAdd( param, "Block", String(Block) );
	//record에 추가.
	record.szReserved = String ( missionUIData.MissionID );
	record.nReserved1 = idx ; 
	//record.nReserved2 = serverID;
	//정렬을 위해 배열에 insert

	return record ;
}


/***********************************************************************************************
 * 결과
 * *********************************************************************************************/
/************************************* 비어 있음 *************************************/
function setResultEmpty ( ) 
{	
	local array<PledgeMissionRewardItem> emptyRewardItems;
	local PledgeMissionCondition emptyCondition;

	// 개요	
	MissionName_Text.SetText( "" );		
	MissionDateName_Text.SetText( "" );
	IconLock_texture.hideWindow();

	// 보상	
	setResultReward ( emptyRewardItems, 0, 0, STATE_BLOCK ) ; 
	// 수행 조건
	setResultConditions ( emptyCondition );
	// 완료 조건
	setResultGoalCondition ("", 0, 0 ) ;
	// 스크롤 변경
	//스크롤 초기화
	areaScroll.SetScrollPosition( 0 ) ;
	//크기에 따른 스크롤 셋팅
	areaScroll.SetScrollHeight( RewardInfoWnd_scrollarea.GetRect().nHeight + ConditionWnd_scrollarea.GetRect().nHeight + CompleteWnd_scrollarea.GetRect().nHeight );
}


/************************************ 완료 조건 ************************************/
function setResultGoalCondition (string goalDesc, int progressCount, int goalCount) 
{
	local int resultHeight;
	// 완료 조건
	//CompleteDescriotion_Text 완료 조건 표현 후 텍스트 높이
	//Debug ( GoalDesc ) ;
	resultHeight = setTextFieldHight( CompleteDescriotion_Text, GoalDesc );
	//CompleteDescriotion_Text, 텍스트 필드 시작 점 + 필드 크기 + 간격 + 스테터스 크기 및 간격 : 27
	CompleteWnd_scrollarea.SetWindowSize ( 266, resultHeight + 53 + 7 );
	//Completegage_statusbar
	Completegage_statusbar.SetPoint( progressCount, GoalCount );
}

function String setResultMakeJob ( bool jobMain, bool jobDual, bool jobSub, string conditionString ) 
{	
	local string classString ;
	
	if ( jobMain ) classString = GetSystemString ( 2340 );	
	if ( jobDual ) 
	{ 
		if ( classString != "" ) classString = classString $ ", " ; 
		classString = classString $ GetSystemString ( 2737 ); 
	}
	if ( jobSub ) 
	{ 
		if ( classString != "" ) classString =  classString $", " ; 
		classString = classString $ GetSystemString ( 2339 ); 
	};

	if ( classString != "" ) addConditionSring  ( classString, conditionString ) ;

	return conditionString ;
}

function string setResultMakeLevelString ( int minLevel, int maxLevel, string conditionString ) 
{	
	local String levelString;
	
	if ( minLevel > 0 ) levelString =  minLevel @ GetSystemString (859); 
	if ( maxLevel > 0 ) 
	{
		if ( levelString != "" ) levelString = levelString $ " ~ " ;
		levelString = levelString $ maxLevel @ GetSystemString(3692) ;		
	}
	
	if ( levelString != "" ) addConditionSring  ( GetSystemString( 2321) @ GetSystemString( 537) @ levelString, conditionString ) ;

	return conditionString ;
}

function string setResultMakeDateString ( int date ) 
{	
	local String yearStr, monthStr, dayStr, zeroString;

	//Debug ( "setResultMakeDateString" @ date );

	zeroString = getInstanceL2Util().makeZeroString(6, date);
	yearStr  = Mid(zeroString, 0, 2);
	monthStr = Mid(zeroString, 2, 2);
	dayStr   = Mid(zeroString, 4, 2);

	//return yearStr$"."$ monthStr $"."$ dayStr;
	return MakeFullSystemMsg(GetSystemMessage(4467), yearStr, monthStr, dayStr);
}

function string setResultMakeTimeString ( int time ) 
{
	local string zeroString;

	//Debug ( "setResultMakeTimeString" @ time );

	if ( time == 0 ) return "";
	zeroString = getInstanceL2Util().makeZeroString(4, time);		
	return " " $ Mid(zeroString, 0, 2)$":"$Mid(zeroString, 2, 4);
}

// 요일 스트링으로 환산하여 리턴
function string getDayString(array<int> AvailableDays)
{
	local int i, len, nCount;
	local string dayStr;
	len = AvailableDays.Length;		
	
	if (len > 0)
	{		
		for(i = 0; i < len; i++)
		{
			if(AvailableDays[i] > 0)
			{				
				nCount++;
				switch( AvailableDays[i])
				{
					//case 0 : if (dayStr != "") dayStr = dayStr $ ","; dayStr = dayStr $ GetSystemString(5140); break;  // 일 
					case 1 : if (dayStr != "") dayStr = dayStr $ ","; dayStr = dayStr $ GetSystemString(5134); break;  // 월
					case 2 : if (dayStr != "") dayStr = dayStr $ ","; dayStr = dayStr $ GetSystemString(5135); break;  // 화 
					case 3 : if (dayStr != "") dayStr = dayStr $ ","; dayStr = dayStr $ GetSystemString(5136); break;  // 수 
					case 4 : if (dayStr != "") dayStr = dayStr $ ","; dayStr = dayStr $ GetSystemString(5137); break;  // 목 
					case 5 : if (dayStr != "") dayStr = dayStr $ ","; dayStr = dayStr $ GetSystemString(5138); break;  // 금 
					case 6 : if (dayStr != "") dayStr = dayStr $ ","; dayStr = dayStr $ GetSystemString(5139); break;  // 토
				}
			}
		}
		// 일요일 추가 
		if(AvailableDays[0] == 0)
		{
			nCount++;
			if (dayStr != "") dayStr = dayStr $ ","; dayStr = dayStr $ GetSystemString(5140); // 일 
		}   
	}
	// Debug("nCount" @ nCount);

	if (nCount > 6 || nCount == 0) dayStr = GetSystemString(3613);

	dayStr = "[" $  dayStr $ "]";

	return dayStr;
}

function requestReward () 
{	
	local LVDataRecord Record;

	if (ToDoList_ListCtrl.GetSelectedIndex() >= 0) 
	{
		ToDoList_ListCtrl.GetSelectedRec(Record);		
		RequestPledgeMissionReward ( int(Record.szReserved) );	
	}
}



/************************************ 수행 조건 ************************************/
function setResultConditions( PledgeMissionCondition condition) 
{
	//높이 값
	local int resultHeight;
	local string conditionString;
	
	// 혈맹 레벨
	if ( condition.PledgeLevel > 0 ) addConditionSring ( MakeFullSystemMsg(GetSystemMessage ( 4546 ), String(condition.PledgeLevel) ), conditionString);
	// 혈맹 마스터리 조건
	if ( condition.PledgeMasteryName != "" ) addConditionSring ( condition.PledgeMasteryName, conditionString);
	// 레벨
	conditionString = setResultMakeLevelString (condition.MinLevel, condition.MaxLevel, conditionString );
	// 직업
	conditionString = setResultMakeJob ( condition.JobMain , condition.JobDual, condition.JobSub, conditionString ) ;
	// 선행 미션
	if ( condition.PreMissionID > 0 ) addConditionSring ( "\"" $ getMissionNameByID(condition.PreMissionID ) $"\"" @ GetSystemString ( 898 ) , conditionString);	
	
	//condition.StartDate = 888888;
	//condition.EndDate = 888888;	
	//condition.StartTime = 8888;	
	//condition.EndTime = 8888;	

	if ( condition.StartDate != 0 ) 
	{	
		addConditionSring ( GetSystemString (2099) , conditionString  ) ;
		if ( condition.StartTime != 0 ) conditionString = conditionString $"\\n   ";
		else conditionString = conditionString $ " : ";
		conditionString = conditionString $setResultMakeDateString (condition.StartDate) $ setResultMakeTimeString (condition.StartTime) @ "~" @ setResultMakeDateString (condition.EndDate) $ setResultMakeTimeString (condition.EndTime) ;		
	}
	
	if ( condition.ActivateTime != 0 ) 
	{
		addConditionSring ( GetSystemString (3605) $ " :", conditionString  ) ;		
		conditionString = conditionString $setResultMakeTimeString (condition.ActivateTime) @ "~" $ setResultMakeTimeString (condition.DeactivateTime) ;		
	}
	
	if ( condition.AvailableDays.Length > 0 ) 	
		addConditionSring ( GetSystemString (3693) $" : " $ getDayString ( condition.AvailableDays ), conditionString  ) ;
	
	//Debug ( conditionString ) ;
	//TimedDescriotion_Text 남은 시간 표현 후 텍스트 높이
	resultHeight = setTextFieldHight( ConditionDescriotion_Text, conditionString );
	//TimedWnd_scrollarea, 텍스트 필드 시작 점 + 필드 크기 + 간격
	ConditionWnd_scrollarea.SetWindowSize ( 266, resultHeight + 30 );	
}

function string getMissionNameByID ( int missionID ) 
{
	local PledgeMissionUIData pledgeMissionUIDataOut;
	GetPledgeMissionData( missionID, pledgeMissionUIDataOut ) ;
	return pledgeMissionUIDataOut.MissionName ;
}

function addConditionSring ( string str, out string conditionString)
{
	local string dot;	
	// 해외 폰트의 경우 유니 코드가 다를 수 있습니다.
	if (GetLanguage() == LANG_Korean ) dot = "·"; else dot = "-"; 
	if ( conditionString != "" ) conditionString = conditionString $"\\n";
	conditionString = conditionString $ dot $ str;
}
/************************************ 보상 ************************************/
function setResultReward ( array<PledgeMissionRewardItem> rewardItems, int rewardPledgeNameValue, int rewardPVPPoint, int curState ) 
{
	local int i;	

	DailyRewardItem.Clear ();

	for ( i = 0 ; i < rewardItems.Length ; i ++ ) 	
		setResultRewardItems ( rewardItems[i] );
	
	// 혈맹 명성치
	ClanFameInput_Text.SetText( MakeCostString ( String ( rewardPledgeNameValue ) ) ) ;	
	// 개인 명성치 
	PrivateFameInput_Text.SetText( MakeCostString ( String ( rewardPVPPoint ) ) ) ;	
	//보상 수령 가능 상태 일때
	if( curState == STATE_REWARD )
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
}

function setResultRewardItems( PledgeMissionRewardItem rewarditem )
{
	//아이템info
	local ItemInfo itemInfo;
	
	//아이템 ID
	local ItemID   itemID;	
	
	itemID.classID = rewarditem.ItemClassID;	

	//itemID로 아이템info 받기
	class'UIDATA_ITEM'.static.GetItemInfo( itemID, itemInfo );

	itemInfo.itemNum = rewarditem.ItemCount;
	//아이템 넣기
	DailyRewardItem.AddItem( itemInfo );
}

/************************************ 개요 ************************************/
function setResultTitle( string title, bool isRepeat, int curState ) 
{
	MissionName_Text.SetText( title );		
	//주기표기
	MissionDateName_Text.SetTextColor( setTextColor( isRepeat ) );

	if ( isRepeat ) MissionDateName_Text.SetText( GetSystemString(3679) );
	else MissionDateName_Text.SetText( GetSystemString(3582) );
	//잠김 상태라면 자물쇠 아이콘 생성
	if( curState == STATE_BLOCK)	
		IconLock_texture.ShowWindow();
	else		
		IconLock_texture.hideWindow();
}


/***************************************************************************
* util
 ***************************************************************************/
function int findIdx ( int missionID ) 
{
	local int i ;
	for ( i = 0 ; i < toDoClanArray.Length ; i ++ ) 
	
		if ( toDoClanArray[i].missionID == missionID ) return i;
	
	return -1;
}

function int findListIndex ( int idx ) 
{
	local int i ;
	local LVDataRecord Record;
	for ( i = 0 ; i < ToDoList_ListCtrl.GetRecordCount() ; i ++ )
	{
		ToDoList_ListCtrl.GetRec( i, Record) ;
		if ( Record.nReserved1 == idx ) return i ;
	}
	return -1;
}


/**
 * 텝 클릭 시 
 **/
function refreshByTabIndexChage ( int tabIndex )
{	
	if ( currentTabIndex != tabIndex ) 
	{
		currentTabIndex = tabIndex;
		setResultEmpty();
		refreshData ();		

		if ( currentTabIndex == TAB_NORMAL ) 
		{
			WeekMissionNum_Text.ShowWindow();
			WeekMission_Text.ShowWindow();
			HelpButton.ShowWindow();
		}
		else 
		{
			WeekMissionNum_Text.hideWindow();
			WeekMission_Text.hideWindow();
			HelpButton.hideWindow();
		}
	}
}

/**
 * 주기에 따른 색상 값 셋팅
 **/
function color setTextColor(bool isRefeat)
{		
	if ( isRefeat  ) return V;
	return Y ;
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
	sNextStringWithWidth = DivideStringWithWidth( txtWnd.GetText(), nWidth );
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
 * 텍스트 넓이를 얻어옴
 **/
//function int getTextFieldWidth ( String text ) 
//{
//	local int nWidth , nHeight;

//	GetTextSizeDefault(text, nWidth, nHeight);
	
//	return nWidth;
//}

/*
 *툴팁
 */
function CustomTooltip getCustomTooltip(string Text)
{
	local CustomTooltip Tooltip;
	local DrawItemInfo info;
	
	Tooltip.MinimumWidth = 144;
	
	Tooltip.DrawList.Length = 1;
	info.eType = DIT_TEXT;
	info.t_bDrawOneLine = true;
	info.t_color.R = 178;
	info.t_color.G = 190;
	info.t_color.B = 207;
	info.t_color.A = 255;
	info.t_strText = Text;
	Tooltip.DrawList[0] = info;

	return Tooltip;
}


/** 옵션을 세팅 : 항상 시작 할때 보여 줄 것인가? */
function SetOptionToDo()
{	
	local bool bChecked;

	bChecked = AllLevelCheckBox.IsChecked();
	SetOptionBool( "UI", "TodoListClan", bChecked );
}

/** 옵션 로드  */
function loadOptionToDo()
{
	local bool bChecked;

	bChecked = getOptionBool( "UI", "TodoListClan");
	AllLevelCheckBox.SetCheck(bChecked);
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







/***************************************************************************
* event 
 ***************************************************************************/

function bool getIsEventMission ( int ID ) 
{	
	// 더블 미션 이벤트 종료 0308
	return false ;
	switch ( ID ) 
	{   
		
		case 1001 : // 85레벨 이상 몬스터 사냥
		case 1003 : // 85~94 인스턴스존 탐험
		case 1004 : // 95~99 인스턴스존 탐험
		case 1005 : // 100~105 인스턴스존 탐험
		case 1007 : // 낚시 수행
		case 1014 : // 연합 인스턴스존 탐험 초급
		case 1015 : // 올림피아드 참여
		case 1016 : // 혼돈의 제전 참여
		case 1017 : // 연합 인스턴스존 탐험 중급
		case 2001 : // 85~94 필드보스 사냥
		case 2002 : // 100~105 필드보스 사냥
		case 2003 : // 크세르스 방어전 공략
		case 2004 : // 날쌘 물고기 낚시
		case 2006 : // 메사이아 성채 외성 공략
		case 2016 :	// 혼돈의 제전 승리 달성
			return true;
	}
	return false;
}
defaultproperties
{
}
