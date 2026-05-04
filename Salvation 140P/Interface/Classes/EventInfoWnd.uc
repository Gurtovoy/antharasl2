/**
 * 
 *  이벤트 정보 UI
 * 
 **/ 
class EventInfoWnd extends UICommonAPI;

const TIMER_ID = 112221;

var WindowHandle Me;
var WindowHandle EventInfoList_Wnd;

var ListCtrlHandle ToDoList_ListCtrl;
var WindowHandle EventDetailInfo_Wnd;
var ButtonHandle EssentialBtn;

var TextBoxHandle EventName_text;
var TextBoxHandle EventNameDetail_text;

var HtmlHandle EventDescription_HtmlViewer;
var TextureHandle EventIcon_texture;

var int clientStartSec, addTimeSec, currentTimeSec;

var l2UITime BIT_l2UITime;

var int serverStartTime;
var bool hasNoticeIcon;

const EVENTTYPE_13thANNIVE = 11;

function OnRegisterEvent()
{
	// 게임 접속 후, 한번 서버 타임을 얻는다.
	RegisterEvent( EV_CurrentserverTime );
	RegisterEvent( EV_Restart );
}

function OnLoad()
{
	SetClosingOnESC();
	Initialize();
}

function onShow()
{
	checkNeedNotice();
	refreshList();
}

// 이벤트 목록 리스트를 업데이트 한다.
function refreshList()
{
	local int nDataCount, i;
	local EventAlarmUIData eventData;

	local bool bTodayIsEventDay;

	ToDoList_ListCtrl.DeleteAllItem();

	nDataCount = GetEventAlarmDataCount();
	for(i = 0; i < nDataCount; i++)
	{
		GetEventAlarmDataByIndex(i, eventData);

		//Debug("eventData.nEventID" @ eventData.nEventID);
		if(eventData.nEventID > 0)
		{
			//Debug("isEventPeroid(eventData)" @ isEventPeroid(eventData));
			//Debug("isEventDay(eventData.nEventDay, BIT_l2UITime.nWeekDay) " @ isEventDay(eventData.nEventDay, BIT_l2UITime.nWeekDay));
			//Debug("isEventOnTime(eventData)) " @ isEventOnTime(eventData));
			// 활성화 여부

			if ( eventData.nEventType == EVENTTYPE_13thANNIVE ) continue ;

			bTodayIsEventDay = (isEventPeroid(eventData) && isEventDay(eventData.nEventDay, BIT_l2UITime.nWeekDay) && isEventOnTime(eventData));
			
			// 기간안에 들어간 경우만 리스트에 출력
			if (isEventPeroid(eventData) )
			{	
				AddListData(eventData.strTitle, eventData.strEventDesc, eventData.strNotifyIcon, eventData.nEventType, i, bTodayIsEventDay);
			}
		}
	}

	// 설명페이지를 열고, 다시 리스트에 포커스를 줘서 스크롤 가능하게 해준다.
	if(ToDoList_ListCtrl.GetRecordCount() > 0)
	{
		ToDoList_ListCtrl.SetSelectedIndex(0, true);

		OnClickListCtrlRecord("");
		//showDetailPage(0);
		ToDoList_ListCtrl.SetFocus(); 
	}
}

function Initialize()
{
	Me                  = GetWindowHandle( "EventInfoWnd" );
	EventInfoList_Wnd   = GetWindowHandle( "EventInfoWnd.EventInfoList_Wnd" );

	EventDetailInfo_Wnd = GetWindowHandle( "EventInfoWnd.EventDetailInfo_Wnd" );
	ToDoList_ListCtrl   = GetListCtrlHandle( "EventInfoWnd.EventInfoList_Wnd.ToDoList_ListCtrl" );

	EventName_text       = GetTextBoxHandle( "EventInfoWnd.EventDetailInfo_Wnd.EventName_text" );
	EventNameDetail_text = GetTextBoxHandle( "EventInfoWnd.EventDetailInfo_Wnd.EventNameDetail_text" );

	EventIcon_texture    = GetTextureHandle( "EventDetailInfo_Wnd.EventIcon_texture" );

	EventDescription_HtmlViewer = GetHtmlHandle( "EventInfoWnd.EventDetailInfo_Wnd.EventDescription_HtmlViewer" );

	EssentialBtn = GetButtonHandle( "EventInfoWnd.EssentialBtn" );
}

// ListCtrl Add
function AddListData(string title, string desc, string iconName, int nEventType, int index, bool bTodayIsEventDay)
{
	local LVDataRecord Record;

	Record.LVDataList.length = 1;
	// 아이템 
	Record.LVDataList[0].nReserved1 = index;
	Record.LVDataList[0].szData = getEventStr(nEventType);

	Record.LVDataList[0].buseTextColor = True;

	if(bTodayIsEventDay) Record.LVDataList[0].TextColor = getInstanceL2Util().Yellow;
	else Record.LVDataList[0].TextColor = getColor(175, 152, 120, 255); 

	Record.LVDataList[0].hasIcon = true;
	Record.LVDataList[0].nTextureWidth=32;
	Record.LVDataList[0].nTextureHeight=32;
	Record.LVDataList[0].nTextureU=32;
	Record.LVDataList[0].nTextureV=32;
	Record.LVDataList[0].szTexture = iconName; //getIconPath(nType);
	Record.LVDataList[0].IconPosX=10;
	Record.LVDataList[0].FirstLineOffsetX=6;

	//Record.LVDataList[0].HiddenStringForSorting = itemName $ util.makeZeroString(3, enchanted);
	
	// back texture 
	Record.LVDataList[0].iconBackTexName="l2ui_ct1.ItemWindow_DF_SlotBox_Default";
	Record.LVDataList[0].backTexOffsetXFromIconPosX=-2;
	Record.LVDataList[0].backTexOffsetYFromIconPosY=-1;
	Record.LVDataList[0].backTexWidth=36;
	Record.LVDataList[0].backTexHeight=36;
	Record.LVDataList[0].backTexUL=36;
	Record.LVDataList[0].backTexVL=36;

	if (bTodayIsEventDay == false)
	{
		Record.LVDataList[0].iconPanelName = "L2UI_CT1.Windows.WindowDisable_BG";
		Record.LVDataList[0].panelOffsetXFromIconPosX=0;
		Record.LVDataList[0].panelOffsetYFromIconPosY=0;
		Record.LVDataList[0].panelWidth=32;
		Record.LVDataList[0].panelHeight=32;
		Record.LVDataList[0].panelUL=8;
		Record.LVDataList[0].panelVL=8;
	}


	if(bTodayIsEventDay) 
	{
		Record.LVDataList[0].attrColor.R = 255;
		Record.LVDataList[0].attrColor.G = 255;
		Record.LVDataList[0].attrColor.B = 255;
	}
	else
	{
		Record.LVDataList[0].attrColor.R = 120;
		Record.LVDataList[0].attrColor.G = 120;
		Record.LVDataList[0].attrColor.B = 120;
	}
	Record.LVDataList[0].attrStat[0] = makeShortStringByPixel(title, 260 - 16, "..");  // 16은 스크롤 공간

	ToDoList_ListCtrl.InsertRecord(Record);
}


//------------------------------------------------------------------------------------------------------------------------------------------------
// OnEvent
//------------------------------------------------------------------------------------------------------------------------------------------------
function OnEvent(int Event_ID, String param)
{
	//debug("debug@" @ Event_ID);
	// 20230
	if (Event_ID == EV_CurrentserverTime)
	{
		//Debug("---> EV_CurrentserverTime" @ param);

		setCurrentserverTime(param);

	}
	else if (Event_ID == EV_Restart)
	{
		clientStartSec = 0;
		currentTimeSec = 0;
		addTimeSec     = 0;
		
		hasNoticeIcon = false;
		Me.KillTimer(TIMER_ID);
	}
}

// UI를 보여줄 기간인지 체크
function setCurrentserverTime(string param)
{
	//local int year, month, day, hour, min, sec;
	//local BIT_l2UITime uiTimeStruct;

	// Debug("GetAppSecondsQPC" @ 	GetAppSeconds());

	//if (clientStartSec <= 0) 
	clientStartSec = GetAppSeconds();
	addTimeSec = GetAppSeconds() - clientStartSec;

	// Debug("addTimeSecStr" @ addTimeSec);

	//ParseInt(param, "year" , year);
	//ParseInt(param, "month", month);
	//ParseInt(param, "day"  , day);
	//ParseInt(param, "year" , hour);
	//ParseInt(param, "min"  , min);
	//ParseInt(param, "sec"  , sec);

	// 서버 시간
	ParseInt(param, "ServerTime", serverStartTime);
	
	checkNeedNotice();
	// 10분 마다 체크
	Me.KillTimer(TIMER_ID);
	Me.SetTimer(TIMER_ID, 60000);  // 60000 == 10분
}

function OnTimer(int TimerID)
{
	if(TimerID == TIMER_ID)
	{
		// Debug("이벤트 정보 타이머 TIMER_ID" @ TimerID);
		checkNeedNotice();
	}

	//Me.KillTimer( TIMER_ID );
}

// 현재 시간 체크 후, 이벤트 기간 중인지를 리턴
function checkNeedNotice()
{
	local int nDataCount, i;
	local EventAlarmUIData eventData;
	local bool bShowNotice;

	addTimeSec = GetAppSeconds() - clientStartSec;

	currentTimeSec = serverStartTime + addTimeSec;
	
	GetTimeStruct(currentTimeSec, BIT_l2UITime);

	//Debug("serverStartTime" @ serverStartTime);
	//Debug("addTimeSec : "  @ addTimeSec);
	//Debug("currentTimeSec: "  @ currentTimeSec);
	//Debug("현재 시간 nYear" @ BIT_l2UITime.nYear);
	//Debug("현재 시간 nMonth" @ BIT_l2UITime.nMonth);
	//Debug("현재 시간 nDay" @ BIT_l2UITime.nDay);
	//Debug("현재 시간 nHour" @ BIT_l2UITime.nHour);
	//Debug("현재 시간 nMin" @ BIT_l2UITime.nMin);
	//Debug("현재 시간 nSec" @ BIT_l2UITime.nSec);
	//Debug("현재 시간 nWeekDay" @ BIT_l2UITime.nWeekDay);

	nDataCount = GetEventAlarmDataCount();
	for(i = 0; i < nDataCount; i++)
	{
		GetEventAlarmDataByIndex(i, eventData);

		// Debug("eventData.nEventID" @ eventData.nEventID);

		if (eventData.nEventID > 0)
		{
			// 정확한 기간(시간 포함) 으로 체크 하고,
			// 이벤트 요일이 있는 경우 라면 딱 그 요일만 알림을 나오게 한다. 지정한 날이 없다면 기간으로만 체크한다.

			
			// 기간안에 들어간 경우만 리스트에 출력

			if(isEventPeroid(eventData) && ((eventData.nEventDay.Length == 0) || isEventDay(eventData.nEventDay, BIT_l2UITime.nWeekDay)))
			{
				// 13주년 이벤트는 알림 아이콘을 출력 하지 않아야 한다.
				if ( eventData.nEventType == EVENTTYPE_13thANNIVE )				
				{
					ShowWindow ( "AnniveEventLauncher");	
					continue;
				}
				else
				{
					bShowNotice = true;
				}

				if (hasNoticeIcon == false)   // 중복적으로 알림 아이콘 갱신이 안되도록..
				{
					// Debug(":: 이벤트 정보 - 알림 버튼 보여줌");
					// 알림 아이콘 생성
					getInstanceNoticeWnd().EventInfoArrived();

					// 알림이 활성화 중인걸 저장
					hasNoticeIcon = true;
				}
			}			
		}
	}

	// 이벤트 정보 알림 아이콘 삭제
	if (bShowNotice == false)
	{
		//Debug(":: 이벤트 정보 - 알림 버튼 삭제");
		hasNoticeIcon = false;
		getInstanceNoticeWnd().hideNoticeButton_EventInfo();
	}
}

// 이벤트 (날짜) 기간인가?
function bool isEventPeroid(EventAlarmUIData eventData)
{
	//Debug("currentTimeSec" @ currentTimeSec);
	//Debug("eventData.nIntTimeStart" @ eventData.nIntTimeStart);
	//Debug("eventData.nIntTimeEnd" @ eventData.nIntTimeEnd);

	// 기간안에 현재시간이 들어 갔는지 체크 해서
	if (currentTimeSec >= eventData.nIntTimeStart && currentTimeSec <= eventData.nIntTimeEnd) return true;
	return false;
}

// 이벤트 시간안인가?
function bool isEventOnTime(EventAlarmUIData eventData)
{
	local String  hourStr, hourEndStr, minuteStr, minuteEndStr;
	local int startM, endM, currentM;
	// x.x.x정기점검 이전
	hourStr = "0";
	minuteStr = "0";
	if (eventData.nActivateTime > 0)
	{		
		hourStr   = Mid(getInstanceL2Util().makeZeroString(4, eventData.nActivateTime), 0, 2);
		minuteStr = Mid(getInstanceL2Util().makeZeroString(4, eventData.nActivateTime), 2, 2);
	}

	hourEndStr = "0";
	minuteEndStr = "0";
	if (eventData.nDeactivateTime > 0)
	{
		hourEndStr = Mid(getInstanceL2Util().makeZeroString(4, eventData.nDeactivateTime), 0, 2);
		minuteEndStr = Mid(getInstanceL2Util().makeZeroString(4, eventData.nDeactivateTime), 2, 2);
	}

	if (int(hourStr) <= 0 && int(minuteStr) <= 0 && int(hourEndStr) <= 0 && int(minuteEndStr) <= 0)
	{
		// 항시
		//Debug("항시!!!");
		return true;
	}
	else
	{
		//Debug("BIT_l2UITime.nHour" @BIT_l2UITime.nHour);
		//Debug("BIT_l2UITime.nMin" @BIT_l2UITime.nMin);

		//Debug("hourStr" @hourStr);
		//Debug("minuteStr" @minuteStr);
		
		// 02:00 ~ 12:00  종료 시간이 더 크면..
		if(getMinute(int(hourStr), int(minuteStr)) <= getMinute(int(hourEndStr), int(minuteEndStr)))
		{
			// 이벤트 시작~ 끝, 시간, 분 안에 들어 갔는지..
			if (getMinute(BIT_l2UITime.nHour, BIT_l2UITime.nMin) >= getMinute(int(hourStr), int(minuteStr)) && 
				getMinute(BIT_l2UITime.nHour, BIT_l2UITime.nMin) < getMinute(int(hourEndStr), int(minuteEndStr)))
			{
				//Debug("온 타임!!!");
				return true;
			}
		}
		// 16:00 ~ 02:00 이라면, 시작 시간이 더 크면 오른쪽 시간에 + 24시
		else
		{
			startM = getMinute(int(hourStr), int(minuteStr));
			endM   = getMinute(int(hourEndStr), int(minuteEndStr));

			currentM = getMinute(BIT_l2UITime.nHour, BIT_l2UITime.nMin);

			if(startM > currentM && currentM <= endM)
			{
				// 24시간을 더 해준다. 
				currentM = getMinute(BIT_l2UITime.nHour + 24, BIT_l2UITime.nMin);
			}

			endM = getMinute(int(hourEndStr) + 24, int(minuteEndStr));

			// 이벤트 시작~ 끝, 시간, 분 안에 들어 갔는지..
			if (currentM >= startM && currentM < endM)
			{
				//Debug("반대, 온 타임!!!");
				return true;
			}
		}
	}

	return false;
}

// 분으로 환산 
function int getMinute(int nHour, int nMin)
{
	return (nHour * 60) + nMin;
}

//------------------------------------------------------------------------------------------------------------------------------------------------
//  버튼 클릭 
//------------------------------------------------------------------------------------------------------------------------------------------------
function OnClickButton( string Name )
{
	switch( Name )
	{
		case "EssentialBtn":
			 OnEssentialBtnClick();
			 break;
	}
}

function OnEssentialBtnClick()
{
	Me.HideWindow();
}


//------------------------------------------------------------------------------------------------------------------------------------------------
//  리스트 클릭 
//------------------------------------------------------------------------------------------------------------------------------------------------
function OnClickListCtrlRecord( string ListCtrlID)
{
	local LVDataRecord Record;		

	//local string param;
	local int nSelect; //, itemType;

	nSelect = ToDoList_ListCtrl.GetSelectedIndex();

	if (nSelect >= 0) 
	{  
		ToDoList_ListCtrl.GetSelectedRec(record);

		// Record.LVDataList[0].szData
		// Record.LVDataList[0].attrStat[0]

		showDetailPage(Record.LVDataList[0].nReserved1);

		// 다시 리스트에 포커스를 줘서 스크롤 되도록..
		ToDoList_ListCtrl.SetFocus(); 

		//Debug("Record.LVDataList[0].nReserved1" @Record.LVDataList[0].nReserved1);
		//Debug("Click Item Record.nReserved1 =>" @ Record.LVDataList[0].nReserved1);
	}
}

// 자세한 내용, html 페이지로 보기
function showDetailPage(int index)
{
	local EventAlarmUIData eventData;
	local string htmlStr, addDate;

	GetEventAlarmDataByIndex(index, eventData);

	EventIcon_texture.SetTexture(eventData.strNotifyIcon);
	//EventName_text.SetText(eventData.strTitle);

	EventName_text.SetText(makeShortStringByPixel(eventData.strTitle, 260, ".."));

	EventName_text.SetTooltipString(eventData.strTitle);	


	EventNameDetail_text.SetText(getEventStr(eventData.nEventType));

	// 기간, 적용시간, 라인(줄)
	addDate = 
			 "<table width=290 cellpadding=0 border=0 cellspacing=0>" $
			 "<tr><td width=285>" $ htmlfontAdd(GetSystemString(1366) $ " : ", "dddddd") $ htmlfontAdd(getPeriodString(eventData) $ "<br1>", "bbaa88" ) $ "</td></tr><br>" $
			 "<tr><td width=285>" $ htmlfontAdd(GetSystemString(3605) $ " : ", "dddddd") $ htmlfontAdd(getEventTimeString(eventData) , "bbaa88" ) $ "</td></tr><br>" $
			 "<tr><td width=285><img src=L2UI_CT1.Divider.Divider_DF_Ver width=284 height=2></td></tr>" $
			 "<tr><td width=285><br>" $ htmlfontAdd(eventData.strEventDesc , "999999") $ "</td></tr>" $
			 "</table><br>";

	htmlStr =  "<html><body>" $ addDate $ "</body></html>";

	EventDescription_HtmlViewer.LoadHtmlFromString(htmlStr);
}

// 
function string getPeriodString( EventAlarmUIData eventData )
{
	local String yearStr, monthStr, dayStr, rStr;

	// x.x.x정기점검 이후
	yearStr  = Mid(getInstanceL2Util().makeZeroString(6, eventData.nStartDate), 0, 2);
	monthStr = Mid(getInstanceL2Util().makeZeroString(6, eventData.nStartDate), 2, 2);
	dayStr   = Mid(getInstanceL2Util().makeZeroString(6, eventData.nStartDate), 4, 2);
	rStr = MakeFullSystemMsg(GetSystemMessage(4464), yearStr, monthStr, dayStr);

	// x.x.x정기점검 이전
	yearStr  = Mid(getInstanceL2Util().makeZeroString(6, eventData.nEndDate), 0, 2);
	monthStr = Mid(getInstanceL2Util().makeZeroString(6, eventData.nEndDate), 2, 2);
	dayStr   = Mid(getInstanceL2Util().makeZeroString(6, eventData.nEndDate), 4, 2);
	rStr = rStr $ " ~ " $ MakeFullSystemMsg(GetSystemMessage(4463), yearStr, monthStr, dayStr);

	return rStr;
}

// 시간 , 몇시 까지.
function string getEventTimeString( EventAlarmUIData eventData )
{
	local String rStr, hourStr, hourEndStr, minuteStr, minuteEndStr;

	// x.x.x정기점검 이전
	hourStr = "0";
	minuteStr = "0";
	if (eventData.nActivateTime > 0)
	{
		hourStr   = Mid(getInstanceL2Util().makeZeroString(4, eventData.nActivateTime), 0, 2);
		minuteStr = Mid(getInstanceL2Util().makeZeroString(4, eventData.nActivateTime), 2, 2);
	}

	hourEndStr = "0";
	minuteEndStr = "0";
	if (eventData.nDeactivateTime > 0)
	{
		hourEndStr = Mid(getInstanceL2Util().makeZeroString(4, eventData.nDeactivateTime), 0, 2);
		minuteEndStr = Mid(getInstanceL2Util().makeZeroString(4, eventData.nDeactivateTime), 2, 2);
	}

	if (int(hourStr) <= 0 && int(minuteStr) <= 0 && int(hourEndStr) <= 0 && int(minuteEndStr) <= 0)
	{
		// 항시
		rStr = GetSystemString(3614);
	}
	else
	{
		// $s1 $s2시부터 $s3시까지
		rStr = MakeFullSystemMsg(GetSystemMessage(4465), getDayString(eventData.nEventDay), hourStr $ ":" $ minuteStr $ " ", hourEndStr $ ":" $ minuteEndStr $ " ");
	}

	return rStr;
}


// 이벤트 제목 리턴
function string getEventStr(int nType)
{
	local string rStr;

	switch(nType)
	{
		case 1 : rStr = GetSystemString(3599); break; // 부스팅 이벤트
		case 2 : rStr = GetSystemString(3600); break; // 수집 이벤트
		case 3 : rStr = GetSystemString(3601); break; // PC방 이벤트
		case 4 : rStr = GetSystemString(3602); break; // 추첨 이벤트
		case 5 : rStr = GetSystemString(3603); break; // 특별 이벤트

		case 6 : rStr = GetSystemString(3618); break; // 낚시 이벤트
		case 7 : rStr = GetSystemString(3619); break; // 할인 이벤트
		case 8 : rStr = GetSystemString(3620); break; // 웹 이벤트

	}

	return rStr;
}

// 요일 스트링으로 환산하여 리턴
function string getDayString(array<int> nEventDay)
{
	local int i, len, nCount;
	local string dayStr;
	len = nEventDay.Length;

	// 0000000  - > 일월화수목금토, 순으로 되어 있던 것이라. 금토일 표현이 아니라 일금토로 나옴 그래서 아래 금토일 같은
	// 표현이 되는 것으로 수정.
	//for(i = 0; i < len; i++)
	//{
	//	if(nEventDay[i] > 0)
	//	{
	//		nCount++;
	//		switch(i)
	//		{
	//			case 0 : if (dayStr != "") dayStr = dayStr $ ","; dayStr = dayStr $ GetSystemString(5140); break;  // 일 
	//			case 1 : if (dayStr != "") dayStr = dayStr $ ","; dayStr = dayStr $ GetSystemString(5134); break;  // 월
	//			case 2 : if (dayStr != "") dayStr = dayStr $ ","; dayStr = dayStr $ GetSystemString(5135); break;  // 화 
	//			case 3 : if (dayStr != "") dayStr = dayStr $ ","; dayStr = dayStr $ GetSystemString(5136); break;  // 수 
	//			case 4 : if (dayStr != "") dayStr = dayStr $ ","; dayStr = dayStr $ GetSystemString(5137); break;  // 목 
	//			case 5 : if (dayStr != "") dayStr = dayStr $ ","; dayStr = dayStr $ GetSystemString(5138); break;  // 금 
	//			case 6 : if (dayStr != "") dayStr = dayStr $ ","; dayStr = dayStr $ GetSystemString(5139); break;  // 토
	//		}
	//	}
	//}
	
	// ------------------
	if (len > 0)
	{
		for(i = 1; i < len; i++)
		{
			if(nEventDay[i] > 0)
			{
				nCount++;
				switch(i)
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
		if(nEventDay[0] > 0)
		{
			nCount++;
			if (dayStr != "") dayStr = dayStr $ ","; dayStr = dayStr $ GetSystemString(5140); // 일 
		}   
	}
	// ------------------


	// Debug("nCount" @ nCount);

	if (nCount > 6 || nCount == 0) dayStr = GetSystemString(3613);

	dayStr = "[" $  dayStr $ "]";

	return dayStr;
}

// 요일 스트링으로 환산하여 리턴
function bool isEventDay(array<int> nEventDay, int nToday)
{
	local int i, len, nCount;
	len = nEventDay.Length;

	for(i = 0; i < len; i++)
	{
		if(nEventDay[i] > 0)
		{
			nCount++;
			if (nToday == i) return true;
		}
	}

	if (nCount > 6 || nCount == 0) return true;

	return false;
}

// html 칼라 값 추가
function string htmlfontAdd( string strText, optional string fontColor )
{
	local string targetHtml;
	if( fontColor == "" ) fontColor = "d3c5ae";
	
	targetHtml = "<font color=\"" $ fontColor $ "\"" $ ">" $ strText $ "</font>";

	return targetHtml;
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

defaultproperties
{
}
