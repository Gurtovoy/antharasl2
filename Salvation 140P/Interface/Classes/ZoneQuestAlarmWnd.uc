class ZoneQuestAlarmWnd extends UICommonAPI;

const MAX_COUNT = 6;

const TIMER_ID = 502;

const TIMER_DELAY = 5000;

var WindowHandle Me;

//?표 버튼
var ButtonHandle ZoneQuestInfoButton;
//상단 타이틀
var TextBoxHandle ZoneQuestTitle;

//시간표시
var TextBoxHandle TimeTitle;
//남은시간
var TextBoxHandle Time;
//참여 인원수
var TextBoxHandle ParticipantsCounter;


//상황정보
var ButtonHandle Situationbtn;
//보상받기
var ButtonHandle Rewardbtn;
//결과 버튼
var ButtonHandle Resultbtn;
//창 나눔 줄.
var TextureHandle Divider;

//게이지 바
var StatusBarHandle GoalGage1;
var StatusBarHandle GoalGage2;
var StatusBarHandle GoalGage3;
var StatusBarHandle GoalGage4;
var StatusBarHandle GoalGage5;
var StatusBarHandle GoalGage6;

//게이지 바 6개 배열
var array<StatusBarHandle> arrStatus;

//항목
var TextBoxHandle GoalTitle1;
var TextBoxHandle GoalTitle2;
var TextBoxHandle GoalTitle3;
var TextBoxHandle GoalTitle4;
var TextBoxHandle GoalTitle5;
var TextBoxHandle GoalTitle6;

//항목 6개 배열
var array<TextBoxHandle> arrGoalTitle;

var int BITmID;
var int mSTEP;
var int mState;

var bool bAccpept;

var L2Util util;

function OnRegisterEvent()
{
	RegisterEvent( EV_ZoneQuestArrived );
	RegisterEvent( EV_ZoneQuestProgressInfo );
	RegisterEvent( EV_ZoneQuestFinish );

	RegisterEvent( EV_Restart );
}

function OnLoad()
{
	OnRegisterEvent();

	Me = GetWindowHandle( "ZoneQuestAlarmWnd" );

	Situationbtn = GetButtonHandle( "ZoneQuestAlarmWnd.Situationbtn" );
	Rewardbtn = GetButtonHandle( "ZoneQuestAlarmWnd.Rewardbtn" );
	Resultbtn = GetButtonHandle( "ZoneQuestAlarmWnd.Resultbtn" );
	Divider = GetTextureHandle ( "ZoneQuestAlarmWnd.Divider" );
	
	ZoneQuestTitle = GetTextBoxHandle ( "ZoneQuestAlarmWnd.ZoneQuestTitle" );
	TimeTitle = GetTextBoxHandle ( "ZoneQuestAlarmWnd.TimeTitle" );
	Time = GetTextBoxHandle ( "ZoneQuestAlarmWnd.Time" );
	ParticipantsCounter = GetTextBoxHandle ( "ZoneQuestAlarmWnd.ParticipantsCounter" );

	GoalGage1 = GetStatusBarHandle( "ZoneQuestAlarmWnd.GoalGage1" );
	GoalGage2 = GetStatusBarHandle( "ZoneQuestAlarmWnd.GoalGage2" );
	GoalGage3 = GetStatusBarHandle( "ZoneQuestAlarmWnd.GoalGage3" );
	GoalGage4 = GetStatusBarHandle( "ZoneQuestAlarmWnd.GoalGage4" );
	GoalGage5 = GetStatusBarHandle( "ZoneQuestAlarmWnd.GoalGage5" );
	GoalGage6 = GetStatusBarHandle( "ZoneQuestAlarmWnd.GoalGage6" );

	GoalTitle1 = GetTextBoxHandle ( "ZoneQuestAlarmWnd.GoalTitle1" );
	GoalTitle2 = GetTextBoxHandle ( "ZoneQuestAlarmWnd.GoalTitle2" );
	GoalTitle3 = GetTextBoxHandle ( "ZoneQuestAlarmWnd.GoalTitle3" );
	GoalTitle4 = GetTextBoxHandle ( "ZoneQuestAlarmWnd.GoalTitle4" );
	GoalTitle5 = GetTextBoxHandle ( "ZoneQuestAlarmWnd.GoalTitle5" );
	GoalTitle6 = GetTextBoxHandle ( "ZoneQuestAlarmWnd.GoalTitle6" );
	  
    util = L2Util(GetScript("L2Util"));

	arrStatus.Length = MAX_COUNT;
	arrGoalTitle.Length = MAX_COUNT;

	arrStatus[0] = GoalGage1;
	arrStatus[1] = GoalGage2;
	arrStatus[2] = GoalGage3;
	arrStatus[3] = GoalGage4;
	arrStatus[4] = GoalGage5;
	arrStatus[5] = GoalGage6;

	arrGoalTitle[0] = GoalTitle1;
	arrGoalTitle[1] = GoalTitle2;
	arrGoalTitle[2] = GoalTitle3;
	arrGoalTitle[3] = GoalTitle4;
	arrGoalTitle[4] = GoalTitle5;
	arrGoalTitle[5] = GoalTitle6;
}

function onShow()
{
	RequestDynamicQuestProgressInfo( BITmID, mSTEP );
}

// 버튼클릭 이벤트
function OnClickButton( string strID )
{
	//Debug("strID>>>" $ strID );
	//Debug( "BITmID-->" $ string( BITmID ) );
	//Debug( "mSTEP-->" $ string( mSTEP ) );

	if( strID == "ZoneQuestInfoButton" )
	{
		RequestDynamicContentHtml( BITmID, mSTEP );
	}
	else if( strID == "Situationbtn" )
	{
		//진행중 || 보상받음(결과확인)
		if( mState == 1 || mState == 3 )
		{
			ShowWindow("ZoneQuestSituationWnd");
			RequestDynamicQuestScoreInfo( BITmID, mSTEP );
		}
		else
		{			
			RequestDynamicContentHtml( BITmID, mSTEP );
		}
	}
	//결과확인
	else if( strID == "Resultbtn" )
	{
		ShowWindow("ZoneQuestSituationWnd");
		RequestDynamicQuestScoreInfo( BITmID, mSTEP );
	}
	//보상받기
	else if(strID == "Rewardbtn" )
	{
		RequestDynamicContentHtml( BITmID, mSTEP );
	}
	else if( strID == "CloseButton" )
	{
		Me.HideWindow();
	}
}

function OnTimer(int TimerID)
{
	if( TimerID == TIMER_ID )
	{
		//Debug("OnTimer?? OnTimer2222");
		RequestDynamicQuestProgressInfo( BITmID, mSTEP );
	}
}

function OnEvent( int Event_ID, string param )
{
	switch( Event_ID )
	{
		//존퀘스트 왔을 때
		case EV_ZoneQuestArrived :
			//Debug("EV_ZoneQuestArrived");
			ZoneQuestArrived( param );
			break;
		//존 퀘스트 진행 중
		case EV_ZoneQuestProgressInfo :
			//Debug("EV_ZoneQuestProgressInfo");
			ZoneQuestProgressInfo( param );
			break;
		//존 퀘스트 완료
		case EV_ZoneQuestFinish :
			//Debug("EV_ZoneQuestFinish");
			ZoneQuestFinish( param );
			break;

		//리스타트시 초기화
		case EV_Restart :
			initZoneQuest();
			break;
	}
}

function initZoneQuest()
{
	bAccpept = false;
	Me.KillTimer( TIMER_ID );
}

function ZoneQuestArrived( string param )
{
	//텔 198679,89754,-192
	//5220
	//ID=1 STEP=1
	//dquest dc_start 2 1
	//dquest accept 2 1

	local int ID;
	local int STEP;

	initZoneQuest();

	ParseInt(param, "ID", ID);
	ParseInt(param, "STEP", STEP);

	BITmID = ID;
	mSTEP = STEP;
	mState = 0;

	//Debug( "ID-->" $ string( ID ) );
	//Debug( "STEP-->" $ string( STEP ) );
	
	// class'UIAPI_WINDOW'.static.ShowWindow("RadarMapWnd.ZoneQuestBtn");
	///class'UIAPI_EFFECTBUTTON'.static.BeginEffect("RadarMapWnd.ZoneQuestBtn", 0);
}

function ZoneQuestProgressInfo( string param )
{
	//5240
	//ID=1 STEP=1 STATE=1 ParticipantsCnt=2500 RemainTimeInSec=3600 GoalCnt=2 CurValue_0=5 GoalValue_0=10 CurValue_1=3 GoalValue_1=10 
	//dquest info 1 1
	local int i;
	local int ID;
	local int STEP;
	local int STATE;
	local int GoalCnt;
	local int ParticipantsCnt;
	local int RemainTimeInSec;

	local int CurValue;
	local int GoalValue;

	local DynamicContentInfo info;

	local ZoneQuestSituationWnd script;

	script = ZoneQuestSituationWnd( GetScript( "ZoneQuestSituationWnd" ) );
	//Debug(param);
		
	ParseInt(param, "ID", ID);
	ParseInt(param, "STEP", STEP);
	ParseInt(param, "STATE", STATE);
	ParseInt(param, "GoalCnt", GoalCnt);
	//참여자 수 (캠페인은 0)
	ParseInt(param, "ParticipantsCnt", ParticipantsCnt);
	//남은 시간
	ParseInt(param, "RemainTimeInSec", RemainTimeInSec);
	
	//TEST용임...지금은 
	//ParseInt(param, "ParticipantsCnt", RemainTimeInSec);
	//ParseInt(param, "RemainTimeInSec", ParticipantsCnt);

	BITmID = ID;
	mSTEP = STEP;
	mState = STATE;

	//Debug( "ID-->" $ string( ID ) );
	//Debug( "STEP-->" $ string( STEP ) );
	//Debug( "STATE-->" $ string( STATE ) );
	//Debug( "GoalCnt-->" $ string( GoalCnt ) );
	//Debug( "ParticantsCnt-->" $ string( ParticipantsCnt ) );
	//Debug( "RemainTimeInSec-->" $ string( RemainTimeInSec ) );

	GetDynamicContentInfo( ID, STEP, info );
	
	//남은 시간 보여주기
	Time.SetText( util.TimeNumberToHangulHourMin( RemainTimeInSec ) );
	ParticipantsCounter.SetText( string(ParticipantsCnt) $ GetSystemString(1013) );

	//시간, 참여 인원 넣어 주기.
	script.showTimeCounter( util.TimeNumberToHangulHourMin( RemainTimeInSec ), string(ParticipantsCnt) $ GetSystemString(1013) );

	setWindowSize( GoalCnt, STATE );
	setWindowShow( GoalCnt, info );

	for( i = 0 ; i < GoalCnt ; i++ )
	{
		ParseInt(param, "CurValue_"$i, CurValue );
		ParseInt(param, "GoalValue_"$i, GoalValue );
		//Debug("CurValue_"$string(i) $ ">>>>>>>>>"$ string(CurValue) );
		//Debug("GoalValue_"$string(i) $ ">>>>>>>>>"$ string(GoalValue) );

		//StatusBarHandle임
		arrStatus[i].SetPoint( CurValue, GoalValue );
	}

	RequestDynamicQuestScoreInfo( BITmID, mSTEP );
}



function ZoneQuestFinish( string param )
{
	local int ID;
	local int STEP;

	initZoneQuest();

	ParseInt(param, "ID", ID);
	ParseInt(param, "STEP", STEP);

	BITmID = ID;
	mSTEP = STEP;
	mState = 0;

	//Debug( "ID-->" $ string( ID ) );
	//Debug( "STEP-->" $ string( STEP ) );

	// class'UIAPI_WINDOW'.static.HideWindow("RadarMapWnd.ZoneQuestBtn");
	getInstanceNoticeWnd().hideNoticeButton_ZONE();
	Me.HideWindow();
}


//창크기 셋팅 및 남은시간 타이틀
function setWindowSize( int count, int State )
{
	local int size;
	local int h;

	size = 139;
	h = size + ( 33 * (count - 1) );

	switch( State )
	{
		//진행중
		case 1:
			//남은시간
			TimeTitle.SetText( GetSystemString(1108) );

			Situationbtn.SetButtonName( 2437 );			
			Situationbtn.ShowWindow();

			Resultbtn.HideWindow();
			Rewardbtn.HideWindow();
			break;
		
		//보상중
		case 2:			
			//보상가능 시간
			TimeTitle.SetText( GetSystemString(2423) );
			
			Situationbtn.HideWindow();

			Resultbtn.ShowWindow();
			Rewardbtn.ShowWindow();
			break;

		//보상받음
		case 3:
			//보상가능 시간
			TimeTitle.SetText( GetSystemString(2423) );

			//결과 확인
			Situationbtn.SetButtonName( 2426 );
			Situationbtn.ShowWindow();

			Resultbtn.SetButtonName( 2426 );

			Resultbtn.HideWindow();
			Rewardbtn.HideWindow();
			break;
		
		//실패함
		case 4:
			//종료까지 남은시간
			TimeTitle.SetText( GetSystemString(2424) );

			//퀘스트 실패
			Situationbtn.SetButtonName( 2438 );			
			Situationbtn.ShowWindow();

			Resultbtn.HideWindow();
			Rewardbtn.HideWindow();
			break;
	}

	Me.SetWindowSize( 213, h );
}

//창 내용 업데이트
function setWindowShow( int count, DynamicContentInfo info )
{
	local int i;

	ZoneQuestTitle.SetText( info.Name );
	ZoneQuestTitle.SetTextEllipsisWidth( 160 );

	ZoneQuestTitle.SetTooltipString( info.Tooltip );
	
	for( i = 0 ; i < MAX_COUNT ; i++ )
	{
		if( i < count )
		{
			arrGoalTitle[i].ShowWindow();
			arrGoalTitle[i].SetText( "- " $ info.GoalDescription[i] );
			arrStatus[i].ShowWindow();
		}
		else
		{
			arrGoalTitle[i].HideWindow();
			arrStatus[i].HideWindow();
		}
	}
	/*
	for( i = 1 ; i <= MAX_COUNT ; i++ )
	{
		if( i <= count )
		{	
			GetTextBoxHandle( "ZoneQuestAlarmWnd.GoalTitle"$i ).ShowWindow();
			GetTextBoxHandle( "ZoneQuestAlarmWnd.GoalTitle"$i ).SetText( "- " $ info.GoalDescription[i - 1] );
			GetStatusBarHandle( "ZoneQuestAlarmWnd.GoalGage" $ i ).ShowWindow();			
		}
		else
		{
			GetTextBoxHandle( "ZoneQuestAlarmWnd.GoalTitle"$i ).HideWindow();
			GetStatusBarHandle( "ZoneQuestAlarmWnd.GoalGage" $ i ).HideWindow();
		}
	}*/
}

//레이더 버튼 클릭 했을 경우.
function RaderButtonClick()
{
	//존 퀘스트 알림 버튼 삭제. 
	local NoticeWnd notice;
	
	notice = NoticeWnd( GetScript("NoticeWnd") );
	notice.ClearZoneQuestBtn();

	if( mState == 0 )
	{
		//Debug( "BITmID-->" $ string( BITmID ) );
		//Debug( "mSTEP-->" $ string( mSTEP ) );
		RequestDynamicContentHtml( BITmID, mSTEP );
	}
	else 
	{
		if( !Me.IsShowWindow() )
			Me.ShowWindow();
		else 
			Me.HideWindow();

		if( bAccpept == false )
		{		
			bAccpept = true;
			Me.SetTimer( TIMER_ID, TIMER_DELAY );
		}
		
	}
}

function int getZoneQuestID()
{
	return BITmID;
}

function int getZoneQuestSTEP()
{
	return mSTEP;
}

function int getZoneQuestState()
{
	return mState;
}
defaultproperties
{
}
