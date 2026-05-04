class BlockCounter extends UIScript;

const TIMER_ID=1010;
const TIMER_DELAY=1000;
const TeamRed_ID = 1;
const TeamBlue_ID = 0;

const CHAT_UNION_MAX = 20;

var WindowHandle Me;
var TextboxHandle TeamRedCount;
var TextboxHandle TeamBlueCount;


//타이머 숫자를 삽입하는 곳
var TextboxHandle TimerCount; 
var TextboxHandle TimerCountTitle;
var TextboxHandle CountCenter;
//var TextboxHandle CountCen;

var int BITMin;
var int Sec;
var string MinStr;
var string SecStr;

function OnRegisterEvent()
{
	registerEvent( EV_BlockStateTeam );
	registerEvent( EV_BlockStatePlayer );
	registerEvent( EV_BlockStateResult );
}

function OnLoad()
{
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	if(CREATE_ON_DEMAND==0)
		Initialize();
	else
		InitializeCOD();
	
	
	Me.HideWindow();
}

function Initialize()
{
	Me = GetHandle("BlockCounter");
	TeamRedCount = TextboxHandle(GetHandle("BlockCounter.TeamRedCount"));
	TeamBlueCount = TextboxHandle(GetHandle("BlockCounter.TeamBlueCount"));
	TimerCount = TextboxHandle(GetHandle("BlockCounter.TimerCount"));
	TimerCountTitle = TextboxHandle(GetHandle("BlockCounter.TimerCountTitle"));
	CountCenter = TextboxHandle(GetHandle("BlockCounter.CountCenter"));
	//RemainSec = TextboxHandle(GetHandle("BlockCurWnd.RemainSec"));
	//RemainSecTitle = TextboxHandle(GetHandle("BlockCurWnd.RemainSecTitle"));
	//CountCen = TextboxHandle(GetHandle("BlockCurWnd.CountCen"));
}

function InitializeCOD()
{
	Me = GetWindowHandle("BlockCounter");
	
	TeamRedCount = GetTextboxHandle("BlockCounter.TeamRedCount");
	TeamBlueCount = GetTextboxHandle("BlockCounter.TeamBlueCount");
	TimerCount = GetTextboxHandle("BlockCounter.TimerCount");
	TimerCountTitle = GetTextboxHandle("BlockCounter.TimerCountTitle");
	CountCenter = GetTextboxHandle("BlockCounter.CountCenter");
	//RemainSec = GetTextboxHandle("BlockCurWnd.RemainSec");
	//RemainSecTitle = GetTextboxHandle("BlockCurWnd.RemainSecTitle");
	//CountCen = GetTextboxHandle("BlockCurWnd.CountCen");
}

function OnEvent( int a_EventID, String a_Param )
{
	switch( a_EventID )
	{
	case EV_BlockStateTeam:
		HandleBlockStateTeam(a_Param);
		break;
	case EV_BlockStatePlayer:
		HandleBlockStatePlayer(a_Param);
		break;
	case EV_BlockStateResult:
		HandleHide();
		break;
	}
}

function OnHide()
{
	//debug("timer 꽥");
	Me.KillTimer( TIMER_ID );
}


function OnShow()
{
	local Color A;
	local Color B;
	
	A.R = 255;
	A.G = 111;
	A.B = 111;
	
	B.R = 111;
	B.G = 111;
	B.B = 255;
	
	//debug("Timer 시작됨");
	TeamRedCount.SetTextColor( A );
	TeamBlueCount.SetTextColor( B );
	Me.SetTimer(TIMER_ID,TIMER_DELAY);
	//~ CountADetail.SetTextColor( A );
	//~ CountBDetail.SetTextColor( B );
}

function HandleBlockStateTeam(string Param)
{	
	local int TeamID;
	local int TeamScore;
	local int RemainSec;
		
	ParseInt(Param, "TeamID", TeamID );
	ParseInt(Param, "TeamScore", TeamScore);
	ParseInt(Param, "RemainSec", RemainSec);
	//debug ("data" @ TeamID  @TeamScore @RemainSec);
	TimerReset(RemainSec);
	if (TeamID == TeamRed_ID)
	{
		TeamRedCount.SetText(String(TeamScore));
	//	TimerCount.SetText(String(RemainSec));
		TimerReset(RemainSec);
		DrawTimerCount();
	}
	if (TeamID ==TeamBlue_ID)
	{
		TeamBlueCount.SetText(String(TeamScore));
	//	TimerCount.SetText(String(RemainSec));
		TimerReset(RemainSec);
		DrawTimerCount();
	}
}

function HandleBlockStatePlayer(string Param)
{	
	local int RemainSec;
	ParseInt(Param, "RemainSec", RemainSec);
	
	TimerReset(RemainSec);
	DrawTimerCount();
}

function OnClickButton( string Name )
{
//	debug ("Button Clicked1");
}

function OnTimer(int TimerID)
{

	//debug ("타이머 작동중-1");
	if(TimerID == TIMER_ID)
	{
			
			

		
		//debug ("타이머 작동중");
		if (BITMin == 0 && Sec < 10)
		{
			if (BITMin == 0 && sec == 5)
			{
				

				AddSystemMessage(2922);
			}
			
			if (BITMin == 0 && sec == 4)
			{

				AddSystemMessage(2923);
			}
			
			if (BITMin == 0 && sec == 3)
			{
	
				AddSystemMessage(2925);
			}
			if (BITMin == 0 && sec == 2)
			{
	
				AddSystemMessage(2926);
			}
			
			if (BITMin == 0 && sec == 1)
			{
		
				AddSystemMessage(2927);
			}
			//debug ("타이머 작동중1");
			TimerCount.HideWindow();
			//RemainSec.HideWindow();
			TimerCountTitle.HideWindow();
			//RemainSecTitle.HideWindow();
			//CountCenter.HideWindow();
			//CountCen.HideWindow();
			
			//DrawTimerCount();
			UpdateTimerCount();
				
		}
		else
		{
			//debug ("타이머 작동중2");
			TimerCount.ShowWindow();
			//RemainSec.ShowWindow();
			TimerCountTitle.ShowWindow();
			//RemainSecTitle.ShowWindow();
			//CountCenter.ShowWindow();
			//CountCen.ShowWindow();
			DrawTimerCount();
			UpdateTimerCount();

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
	if (Sec == 0)
		{
			Sec = 59;
			BITMin = BITMin -1;
		} 
		else 
		{
			Sec = Sec -1;
		}
	}
/*
function ResetWnd()
{
	TimerCount.ShowWindow();
	TimerCount.SetText("");
	//~ TimerCountDetail.ShowWindow();
	//~ TimerCountDetail.SetText("");
	TimerReset();
	//~ PartyNameA.SetText("");
	//~ PartyNameB.SetText("");
	ResetCurrentStat();
}
*/
function TimerReset(int RemainTime)
{
	BITMin = RemainTime / 60;
	Sec = RemainTime % 60; 
}


/*function UpdateCurrentStat(int BlueCountInt, int RedCountInt)
{
	TeamACount.SetText(String(BlueCountInt));
	
	TeamACount.SetText(String(RedCountInt));
	
}*/

function ResetCurrentStat()
{
	TeamRedCount.SetText("0");
	TeamBlueCount.SetText("0");
	//~ CountADetail.SetText("0");
	//~ CountBDetail.SetText("0");
}
function HandleHide()
{
	me.hidewindow();
}


defaultproperties
{
}
