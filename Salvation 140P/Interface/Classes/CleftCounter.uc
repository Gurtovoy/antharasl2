class CleftCounter extends UIScript;

const TIMER_ID=1023;
const TIMER_DELAY=1000;
const TeamA_ID = 0;
const TeamB_ID = 1;

var WindowHandle Me;
var TextboxHandle TeamACount;
var TextboxHandle TeamBCount;
//~ var TextboxHandle CountADetail;
//~ var TextboxHandle CountBDetail;

//타이머 숫자를 삽입하는 곳
var TextboxHandle TimerCount; //시간 표시창
//var TextboxHandle RemainSec;
var TextboxHandle TimerCountTitle; //시간 표시창 제목
//var TextboxHandle RemainSecTitle;
var TextboxHandle CountCenter;
//var TextboxHandle CountCen;

var int BITMin;
var int Sec;
var string MinStr;
var string SecStr;

function OnRegisterEvent()
{
	registerEvent( EV_CleftStateTeam );
	registerEvent( EV_CleftStatePlayer );
	registerEvent( EV_CleftStateResult );
}

function OnLoad()
{
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	if(CREATE_ON_DEMAND==0)
		Initialize();
	else
		InitializeCOD();
	
	//LaunchTimer();
	Me.HideWindow();
}

function Initialize()
{
	Me = GetHandle("CleftCounter");
	
	TeamACount = TextboxHandle(GetHandle("TeamACount"));
	TeamBCount = TextboxHandle(GetHandle("TeamBCount"));
	TimerCount = TextboxHandle(GetHandle("TimerCount"));
	TimerCountTitle = TextboxHandle(GetHandle("TimerCountTitle"));
	CountCenter = TextboxHandle(GetHandle("CountCenter"));
	//RemainSec = TextboxHandle(GetHandle("CleftCurWnd.RemainSec"));
	//RemainSecTitle = TextboxHandle(GetHandle("CleftCurWnd.RemainSecTitle"));
	//CountCen = TextboxHandle(GetHandle("CleftCurWnd.CountCen"));
}

function InitializeCOD()
{
	Me = GetWindowHandle("CleftCounter");
	
	TeamACount = GetTextboxHandle("CleftCounter.TeamACount");
	TeamBCount = GetTextboxHandle("CleftCounter.TeamBCount");
	TimerCount = GetTextboxHandle("CleftCounter.TimerCount");
	TimerCountTitle = GetTextboxHandle("CleftCounter.TimerCountTitle");
	CountCenter = GetTextboxHandle("CleftCounter.CountCenter");
	//RemainSec = GetTextboxHandle("CleftCurWnd.RemainSec");
	//RemainSecTitle = GetTextboxHandle("CleftCurWnd.RemainSecTitle");
	//CountCen = GetTextboxHandle("CleftCurWnd.CountCen");
}

function OnEvent( int a_EventID, String a_Param )
{
	switch( a_EventID )
	{
	case EV_CleftStateTeam:
		HandleCleftStateTeam(a_Param);
		break;
	case EV_CleftStatePlayer:
		HandleCleftStatePlayer(a_Param);
		break;
	case EV_CleftStateResult:
		HandleHide();
		break;
	}
}

function OnHide()
{
	Me.KillTimer( TIMER_ID );
}


function OnShow()
{
	/*local Color A;
	local Color B;
	
	A.R = 114;
	A.G = 173;
	A.B = 255;
	
	B.R = 254;
	B.G = 151;
	B.B = 66;
	
	TeamACount.SetTextColor( A );
	TeamBCount.SetTextColor( B );*/
	Me.SetTimer(TIMER_ID,TIMER_DELAY);
	//~ CountADetail.SetTextColor( A );
	//~ CountBDetail.SetTextColor( B );
}

function HandleCleftStateTeam(string Param)
{
	local int TeamID;
	local int TeamPoint;
	local int RemainSec;
		
	ParseInt(Param, "TeamID", TeamID );
	ParseInt(Param, "TeamPoint", TeamPoint);
	ParseInt(Param, "RemainSec", RemainSec);
	
	TimerReset(RemainSec);
	DrawTimerCount();
		
	if (TeamID == TeamA_ID)
	{
		TeamACount.SetText(String(TeamPoint));
	}
	else if (TeamID ==TeamB_ID)
	{
		TeamBCount.SetText(String(TeamPoint));
	}
}

function HandleCleftStatePlayer(string Param)
{
	local int RemainSec;
	ParseInt(Param, "RemainSec", RemainSec);
	
	TimerReset(RemainSec);
	DrawTimerCount();
}

function OnClickButton( string Name )
{
	//debug ("Button Clicked1");
}

function OnTimer(int TimerID)
{
	if(TimerID == TIMER_ID)
	{
		//~ debug ("타이머 작동중");
		
		if (BITMin == 1 && sec == 0)
		{
			AddSystemMessage(2420);
		}
		
		if (BITMin == 0 && sec == 10)
		{
			AddSystemMessage(2421);
		}
		
		if (BITMin == 0 && Sec < 9)
		{
			//~ debug ("타이머 작동중1");
			TimerCount.HideWindow();
			//RemainSec.HideWindow();
			TimerCountTitle.HideWindow();
			//RemainSecTitle.HideWindow();
			//CountCenter.HideWindow();
			//CountCen.HideWindow();
			//Me.KillTimer( TIMER_ID );
			//DrawTimerCount();
			UpdateTimerCount();
		}
		else
		{
			//~ debug ("타이머 작동중2");
			TimerCount.ShowWindow();
			//RemainSec.ShowWindow();
			TimerCountTitle.ShowWindow();
			//RemainSecTitle.ShowWindow();
			//CountCenter.ShowWindow();
			//CountCen.ShowWindow();
			DrawTimerCount();
			UpdateTimerCount();
			//~ Me.SetTimer(TIMER_ID,TIMER_DELAY);
		}
	}
}

function DrawTimerCount()
{
		MinStr = String(BITMin);
		SecStr = String(Sec);
		
		if (BITMin < 10)
			MinStr = "0" $ MinStr;
		
		if (Sec < 10)
			SecStr = "0" $ SecStr;
		
		TimerCount.SetText(MinStr $ ":" $ SecStr);
		
		//~ debug (MakeFullSystemMsg(GetSystemMessage(2278), MinStr , SecStr));
		
	
		//~ debug ("다음넘버"  @ BITMin @ Sec);
}


function UpdateTimerCount()
{


		
		//~ debug (MakeFullSystemMsg(GetSystemMessage(2278), MinStr , SecStr));
		
		if (Sec == 0)
		{
			Sec = 59;
			BITMin = BITMin -1;
		} 
		else 
		{
			Sec = Sec -1;
		}
		//~ debug ("다음넘버"  @ BITMin @ Sec);
}

/*function ResetWnd()
{
	TimerCount.ShowWindow();
	TimerCount.SetText("");
	TimerReset();
	ResetCurrentStat();
	//~ TimerCountDetail.ShowWindow();
	//~ TimerCountDetail.SetText("");
	//~ PartyNameA.SetText("");
	//~ PartyNameB.SetText("");
}*/

function TimerReset(int RemainTime)
{
	
	BITMin = RemainTime / 60;
	Sec = RemainTime % 60; 
	/*BITMin = 25;
	Sec = 0;
	
	MinStr = String(BITMin);
	SecStr = String(Sec);
	
	TimerCount.SetText(MinStr $ ":" $ SecStr);*/
	//~ TimerCountDetail.SetText(MinStr $ ":" $ SecStr);
}


/*function UpdateCurrentStat(int BlueCountInt, int RedCountInt)
{
	TeamACount.SetText(String(BlueCountInt));
	
	TeamACount.SetText(String(RedCountInt));
	
}*/

function ResetCurrentStat()
{
	TeamACount.SetText("0");
	TeamBCount.SetText("0");
	//~ CountADetail.SetText("0");
	//~ CountBDetail.SetText("0");
}
function HandleHide()
{
	me.hidewindow();
}
/*function LaunchTimer()
{
	TimerReset();
	Me.SetTimer(TIMER_ID,TIMER_DELAY);
}*/
defaultproperties
{
}
