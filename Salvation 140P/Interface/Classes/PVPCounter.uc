class PVPCounter extends UIScript;

const TIMER_ID=1023;
const TIMER_DELAY=1000;

var WindowHandle Me;
//파티의 이름을 삽입하는 곳
//~ var TextboxHandle PartyNameA;
//~ var TextboxHandle PartyNameB;
//카운트 점수를 삽입하는 곳
var TextboxHandle CountA;
var TextboxHandle CountB;
//~ var TextboxHandle CountADetail;
//~ var TextboxHandle CountBDetail;

//타이머 숫자를 삽입하는 곳
var TextboxHandle TimerCount; 
var TextboxHandle TimerCountDetail;
var TextboxHandle TimerCountTitle;
var TextboxHandle TimerCountTitleDetail;

var int BITMin;
var int Sec;
var string MinStr;
var string SecStr;

var string m_WindowName;

function OnRegisterEvent()
{
    registerEvent( EV_PVPMatchRecord );
	registerEvent( EV_PVPMatchRecordEachUserInfo );
	registerEvent( EV_PVPMatchUserDie );
}

function OnLoad()
{
	OnRegisterEvent();

	InitializeCOD();
	
	Me.HideWindow();
}

function InitializeCOD()
{
	Me = GetWindowHandle(m_WindowName);
	
	CountA = GetTextBoxHandle(m_WindowName$".CountA");
	CountB = GetTextBoxHandle(m_WindowName$".CountB");
	TimerCount = GetTextBoxHandle(m_WindowName$".TimerCount");
	TimerCountDetail = GetTextBoxHandle("PVPDetailedWnd.TimerCount");
	TimerCountTitle = GetTextBoxHandle("PVPDetailedWnd.TimerCountTitle");
	TimerCountTitleDetail = GetTextBoxHandle("PVPDetailedWnd.TimerCountTitle");
}

function OnEvent( int a_EventID, String a_Param )
{
	switch( a_EventID )
	{
	case EV_PVPMatchRecord:
		HandlePVPMatchRecord(a_Param);
		break;
	case EV_PVPMatchRecordEachUserInfo:
		HandlePVPMatchRecordEachUserInfo(a_Param);
		break;
	case EV_PVPMatchUserDie:
		HandlePVPMatchUserDie(a_Param);
		break;
	}
}

function OnHide()
{
	Me.KillTimer( TIMER_ID );
}


function OnShow()
{
	local Color A;
	local Color B;
	
	A.R = 114;
	A.G = 173;
	A.B = 255;
	
	B.R = 254;
	B.G = 151;
	B.B = 66;
	
	CountA.SetTextColor( A );
	CountB.SetTextColor( B );
}

function HandlePVPMatchRecord(string Param)
{
	local int CurrentState;
	local int BlueTeamTotalKillCnt;
	local int RedTeamTotalKillCnt;
	
	ParseInt(Param, "CurrentState", CurrentState );
	ParseInt(Param, "BlueTeamTotalKillCnt", BlueTeamTotalKillCnt);
	ParseInt(Param, "RedTeamTotalKillCnt", RedTeamTotalKillCnt);
	
	
	switch (CurrentState)
	{
		case 0:
			//경기시작
			TimerReset();
			ResetCurrentStat();
			Me.ShowWindow();
			Me.SetTimer(TIMER_ID,TIMER_DELAY);
			break;
		case 1:
			//경기 중
			UpdateCurrentStat(BlueTeamTotalKillCnt, RedTeamTotalKillCnt);
			break;
		case 2:
			//경기종료
			Me.HideWindow();
			ResetWnd();
			break;
	}
}


function HandlePVPMatchRecordEachUserInfo(string Param)
{
	local int Team;
	local String PlayerName;
	local int KillCnt;
	local int DeathCnt;
	
	ParseInt(Param, "Team", Team);
	ParseInt(Param, "KillCnt", KillCnt);
	ParseInt(Param, "DeathCnt", DeathCnt);
	ParseString(Param, "PlayerName", PlayerName);
	
}

function HandlePVPMatchUserDie(string Param)
{
	local int BlueTeamKillCnt;
	local int RedTeamKillCnt;
	
	ParseInt(Param, "BlueTeamKillCnt", BlueTeamKillCnt);
	ParseInt(Param, "RedTeamKillCnt", RedTeamKillCnt );
	
	UpdateCurrentStat(BlueTeamKillCnt, RedTeamKillCnt);
	
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
		if (BITMin == 0 && Sec < 9)
		{
			//~ debug ("타이머 작동중1");
			TimerCount.HideWindow();
			TimerCountDetail.HideWindow();
			TimerCountTitle.HideWindow();
			TimerCountDetail.HideWindow();
			Me.KillTimer( TIMER_ID );
		}
		else
		{
			//~ debug ("타이머 작동중2");
			TimerCount.ShowWindow();
			TimerCountDetail.ShowWindow();
			TimerCountTitle.ShowWindow();
			TimerCountDetail.ShowWindow();

			UpdateTimerCount();
			//~ Me.SetTimer(TIMER_ID,TIMER_DELAY);
		}
	}
}

function UpdateTimerCount()
{
	MinStr = String(BITMin);
		SecStr = String(Sec);
		
		if (BITMin < 10)
			MinStr = "0" $ MinStr;
		
		if (Sec < 10)
			SecStr = "0" $ SecStr;
		
		TimerCount.SetText(MinStr $ ":" $ SecStr);
		TimerCountDetail.SetText(MinStr $ ":" $ SecStr);
		
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

function ResetWnd()
{
	TimerCount.ShowWindow();
	TimerCount.SetText("");
	TimerReset();
	ResetCurrentStat();
}

function TimerReset()
{
	BITMin = 10;
	Sec = 0;
	
		MinStr = String(BITMin);
		SecStr = String(Sec);
	
	TimerCount.SetText(MinStr $ ":" $ SecStr);
}


function UpdateCurrentStat(int BlueCountInt, int RedCountInt)
{
	CountA.SetText(String(BlueCountInt));
	CountB.SetText(String(RedCountInt));
}

function ResetCurrentStat()
{
	CountA.SetText("0");
	CountB.SetText("0");
}

defaultproperties
{
    m_WindowName="PVPCounter"
}
