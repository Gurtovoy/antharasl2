class CampaignAlarmWnd extends UICommonAPI;

const MAX_COUNT = 6;

const TIMER_ID = 501;

const TIMER_DELAY = 5000;


var WindowHandle Me;

//?표 버튼
var ButtonHandle CampaignInfoButton;

var TextBoxHandle CampaignTitle;
//시간표시
var TextBoxHandle TimeTitle;
//남은시간
var TextBoxHandle Time;

//결과 버튼
var ButtonHandle Resultbtn;
//창 나눔 줄.
var TextureHandle Divider;

//게이지 바
var BarHandle GoalGage1;
var BarHandle GoalGage2;
var BarHandle GoalGage3;
var BarHandle GoalGage4;
var BarHandle GoalGage5;
var BarHandle GoalGage6;

//게이지 바 6개 배열
var array<BarHandle> arrStatus;

//항목
var TextBoxHandle GoalTitle1;
var TextBoxHandle GoalTitle2;
var TextBoxHandle GoalTitle3;
var TextBoxHandle GoalTitle4;
var TextBoxHandle GoalTitle5;
var TextBoxHandle GoalTitle6;

//항목 6개 배열
var array<TextBoxHandle> arrGoalTitle;

var bool bAccpept;

var int BITmID;
var int mSTEP;
var int mState;

var L2Util util;

function OnRegisterEvent()
{
	RegisterEvent( EV_CampaignArrived );
	RegisterEvent( EV_CampaignProgressInfo );
	RegisterEvent( EV_CampaignFinish );

	RegisterEvent( EV_Restart );
}

function OnLoad()
{
	

	Me = GetWindowHandle( "CampaignAlarmWnd" );
	Resultbtn = GetButtonHandle( "CampaignAlarmWnd.Resultbtn" );
	Divider = GetTextureHandle ( "CampaignAlarmWnd.Divider" );
	
	CampaignTitle = GetTextBoxHandle ( "CampaignAlarmWnd.CampaignTitle" );
	TimeTitle = GetTextBoxHandle ( "CampaignAlarmWnd.TimeTitle" );
	Time = GetTextBoxHandle ( "CampaignAlarmWnd.Time" );
	  
	GoalGage1 = GetBarHandle( "CampaignAlarmWnd.GoalGage1" );
	GoalGage2 = GetBarHandle( "CampaignAlarmWnd.GoalGage2" );
	GoalGage3 = GetBarHandle( "CampaignAlarmWnd.GoalGage3" );
	GoalGage4 = GetBarHandle( "CampaignAlarmWnd.GoalGage4" );
	GoalGage5 = GetBarHandle( "CampaignAlarmWnd.GoalGage5" );
	GoalGage6 = GetBarHandle( "CampaignAlarmWnd.GoalGage6" );

	GoalTitle1 = GetTextBoxHandle ( "CampaignAlarmWnd.GoalTitle1" );
	GoalTitle2 = GetTextBoxHandle ( "CampaignAlarmWnd.GoalTitle2" );
	GoalTitle3 = GetTextBoxHandle ( "CampaignAlarmWnd.GoalTitle3" );
	GoalTitle4 = GetTextBoxHandle ( "CampaignAlarmWnd.GoalTitle4" );
	GoalTitle5 = GetTextBoxHandle ( "CampaignAlarmWnd.GoalTitle5" );
	GoalTitle6 = GetTextBoxHandle ( "CampaignAlarmWnd.GoalTitle6" );
	  
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

	OnRegisterEvent();
}

// 버튼클릭 이벤트
function OnClickButton( string strID )
{
	//Debug("strID>>>" $ strID );

	if( strID == "CampaignInfoButton" )
	{
		//Debug( "BITmID-->" $ string( BITmID ) );
		//Debug( "mSTEP-->" $ string( mSTEP ) );
		RequestDynamicContentHtml( BITmID, mSTEP );
	}
	else if( strID == "Resultbtn" )
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
		//Debug("OnTimer?? OnTimer");
		RequestDynamicQuestProgressInfo( BITmID, mSTEP );
	}
}

function OnEvent( int Event_ID, string param )
{
	switch( Event_ID )
	{
		//존퀘스트 왔을 때
		case EV_CampaignArrived :
			//Debug("EV_CampaignArrived");
			CampaignArrived( param );
			break;
		//존 퀘스트 진행 중
		case EV_CampaignProgressInfo :
			//Debug("EV_CampaignProgressInfo");
			CampaignProgressInfo( param );
			break;
		//존 퀘스트 완료
		case EV_CampaignFinish :
			//Debug("EV_CampaignFinish");
			CampaignFinish( param );
			break;
		
		//리스타트시 초기화
		case EV_Restart :
			initCampaign();
			break;
	}
}

function initCampaign()
{
	bAccpept = false;
	Me.KillTimer( TIMER_ID );
}

function CampaignArrived( string param )
{
	//5210
	//ID=1 STEP=1 STATE=1

	//dquest dc_start 1 1
	//dquest accept 1 1
	//dquest accept 1 campaignId

	local int ID;
	local int STEP;

	initCampaign();

	ParseInt(param, "ID", ID);
	ParseInt(param, "STEP", STEP);

	BITmID = ID;
	mSTEP = STEP;
	mState = 0;

	//Debug( "ID-->" $ string( ID ) );
	//Debug( "STEP-->" $ string( STEP ) );
	
	// class'UIAPI_WINDOW'.static.ShowWindow("RadarMapWnd.CampaignBtn");
	/// class'UIAPI_EFFECTBUTTON'.static.BeginEffect("RadarMapWnd.CampaignBtn", 0);		
}

function CampaignProgressInfo( string param )
{
	//5230
	//ID=1 STEP=1 STATE=1 ParticipantsCnt=0 RemainTimeInSec=3600 GoalCnt=2 CurValue_0=0 GoalValue_0=10 CurValue_1=3 GoalValue_1=10 
	//dquest info 1 1
	//dquest point 1 1 101 1 1
	//dquest ranking 1 1
	//dquest reward 1 1
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

	local NoticeWnd notice;
	
	if( bAccpept == false )
	{
		//캠페인 알림 버튼 삭제.
		notice = NoticeWnd( GetScript("NoticeWnd") );
		notice.ClearCampaignBtn();
		Me.ShowWindow();
		bAccpept = true;
		Me.SetTimer( TIMER_ID, TIMER_DELAY );
	}
		
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

	/*
	Debug( "ID-->" $ string( ID ) );
	Debug( "STEP-->" $ string( STEP ) );
	Debug( "STATE-->" $ string( STATE ) );
	Debug( "GoalCnt-->" $ string( GoalCnt ) );
	Debug( "ParticantsCnt-->" $ string( ParticipantsCnt ) );
	Debug( "RemainTimeInSec-->" $ string( RemainTimeInSec ) );
*/

	GetDynamicContentInfo( ID, STEP, info );
	
	//남은 시간 보여주기
	Time.SetText( util.TimeNumberToHangulHourMin( RemainTimeInSec ) );	

	setWindowSize( GoalCnt, STATE );
	setWindowShow( GoalCnt, info );	

	for( i = 0 ; i < GoalCnt ; i++ )
	{
		ParseInt(param, "CurValue_"$i, CurValue );
		ParseInt(param, "GoalValue_"$i, GoalValue );
		//Debug("CurValue_"$string(i) $ ">>>>>>>>>"$ string(CurValue) );
		//Debug("GoalValue_"$string(i) $ ">>>>>>>>>"$ string(GoalValue) );

		//BarHandle임
		arrStatus[i].SetValue( GoalValue, CurValue );
	}
}

function CampaignFinish( string param )
{
	local int ID;
	local int STEP;

	ParseInt(param, "ID", ID);
	ParseInt(param, "STEP", STEP);

	BITmID = ID;
	mSTEP = STEP;
	mState = 0;

	//Debug( "ID-->" $ string( ID ) );
	//Debug( "STEP-->" $ string( STEP ) );

	// class'UIAPI_WINDOW'.static.HideWindow("RadarMapWnd.CampaignBtn");
	getInstanceNoticeWnd().hideNoticeButton_CAMPAIGN();
	
	Me.HideWindow();

	initCampaign();
}


//창크기 셋팅 및 남은시간 타이틀
function setWindowSize( int count, int State )
{
	local int size;
	local int h;

	switch( State )
	{
		//진행중
		case 1:
			size = 93;
			h = size + ( 33 * (count - 1) );

			//남은시간
			TimeTitle.SetText( GetSystemString(1108) );

			Resultbtn.HideWindow();
			Divider.HideWindow();
			break;
		
		//보상중
		case 2:
			size = 125;
			h = size + ( 33 * (count - 1) );
			
			//보상가능 시간
			TimeTitle.SetText( GetSystemString(2423) );
			
			Resultbtn.SetButtonName( 2279 );
			Resultbtn.ShowWindow();
			Divider.ShowWindow();
			break;

		//보상받음
		case 3:
			size = 125;
			h = size + ( 33 * (count - 1) );

			//보상가능 시간
			TimeTitle.SetText( GetSystemString(2423) );

			Resultbtn.SetButtonName( 2426 );
			Resultbtn.ShowWindow();
			Divider.ShowWindow();
			break;
		
		//실패함
		case 4:
			size = 125;
			h = size + ( 33 * (count - 1) );

			//종료까지 남은시간
			TimeTitle.SetText( GetSystemString(2424) );

			Resultbtn.SetButtonName( 2425 );
			Resultbtn.ShowWindow();
			Divider.ShowWindow();
			break;
	}

	Me.SetWindowSize( 213, h );
}

//창 내용 업데이트
function setWindowShow( int count, DynamicContentInfo info )
{
	local int i;
	
	//CampaignTitle.SetText( info.Title );
	CampaignTitle.SetText( info.Name );
	CampaignTitle.SetTextEllipsisWidth( 160 );

	CampaignTitle.SetTooltipString( info.Tooltip );
	
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
			GetTextBoxHandle( "CampaignAlarmWnd.GoalTitle"$i ).ShowWindow();
			GetTextBoxHandle( "CampaignAlarmWnd.GoalTitle"$i ).SetText( "- " $ info.GoalDescription[i - 1] );
			GetBarHandle( "CampaignAlarmWnd.GoalGage" $ i ).ShowWindow();
		}
		else
		{
			GetTextBoxHandle( "CampaignAlarmWnd.GoalTitle"$i ).HideWindow();
			GetBarHandle( "CampaignAlarmWnd.GoalGage" $ i ).HideWindow();
		}
	}*/
}

//레이더 버튼 클릭 했을 경우.
function RaderButtonClick()
{
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
	}
}


function int getCampaignState()
{
	return mState;
}
defaultproperties
{
}
