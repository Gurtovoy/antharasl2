class KillPointCounterWnd extends UIScript;

const MAX_GAME_TIME_MIN = 20;
const TIMER_ID=1024;
const TIMER_DELAY=1000;

var WindowHandle Me, MEBtn;
var TextBoxHandle KillPointTxt,MinTxt,SecTxt, DividerTxt;
var int BITMin, Sec;
var string MinStr, SecStr;
var bool m_InGameBool;

function OnRegisterEvent()
{
	RegisterEvent( EV_CrataeCubeRecordMyItem );
	RegisterEvent( EV_CrataeCubeRecordBegin );
	RegisterEvent( EV_CrataeCubeRecordRetire );
}


function OnLoad()
{
	if(CREATE_ON_DEMAND==0)
	{
		Me 	= 		GetHandle("KillPointCounterWnd");
		//MEBtn =		GetHandle("KillPointRankTrigger");
		KillPointTxt	= 	TextBoxHandle(GetHandle("KillPointCounterWnd.KillPointTxt"));
		MinTxt	= 	TextBoxHandle(GetHandle("KillPointCounterWnd.MinTxt"));
		SecTxt	=	TextBoxHandle(GetHandle("KillPointCounterWnd.SecTxt"));
		DividerTxt 	= 	TextBoxHandle(GetHandle("KillPointCounterWnd.DividerTxt"));
	}
	else
	{
		Me 	= 		GetWindowHandle("KillPointCounterWnd");
		//MEBtn =		GetWindowHandle("KillPointRankTrigger");
		KillPointTxt	= 	GetTextBoxHandle("KillPointCounterWnd.KillPointTxt");
		MinTxt	= 	GetTextBoxHandle("KillPointCounterWnd.MinTxt");
		SecTxt	=	GetTextBoxHandle("KillPointCounterWnd.SecTxt");
		DividerTxt 	= 	GetTextBoxHandle("KillPointCounterWnd.DividerTxt");
	}
	//~ RegisterEvent( EV_CrataeCubeRecordMyItem );
	//~ RegisterEvent( EV_CrataeCubeRecordBegin );
	//~ RegisterEvent( EV_CrataeCubeRecordRetire );
}

function OnEvent(int Event_ID, string param)
{
	local int StatusInt;
	switch(Event_ID)
	{
		case EV_CrataeCubeRecordMyItem:
		
				if (!Me.IsShowWindow() && !m_InGameBool)
				{
					Me.ShowWindow();
					//MEBtn.ShowWindow();
					LaunchTimer();
				}
				UpdateMyKillPoint(param);
		break;
		case EV_CrataeCubeRecordBegin:
			ParseInt( param, "Status", StatusInt);
			switch (StatusInt)
			{
				case 2:
					m_InGameBool = false;
					Me.HideWindow();
					//MEBtn.HideWindow();
				break;
			}
		break;
		case EV_CrataeCubeRecordRetire:
			m_InGameBool = false;
			Me.HideWindow();
			//MEBtn.HideWindow();
		break;
	}
}

function UpdateMyKillPoint(string Param)
{
	local string KillPoint;
	ParseString(Param, "KillPoint", KillPoint);
	KillPointTxt.SetText(KillPoint);
}

function LaunchTimer()
{
	TimerReset();
	Me.SetTimer(TIMER_ID,TIMER_DELAY);
}


function OnTimer(int TimerID)
{
	if(TimerID == TIMER_ID)
	{
		if (BITMin == 0 && Sec < 9)
		{
			MinTxt.HideWindow();
			SecTxt.HideWindow();
			DividerTxt.HideWindow();
			Me.KillTimer( TIMER_ID );
		}
		else
		{
			MinTxt.ShowWindow();
			SecTxt.ShowWindow();
			DividerTxt.ShowWindow();
			UpdateTimerCount();
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
	
	MinTxt.SetText(MinStr);
	SecTxt.SetText(SecStr);
	
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

function TimerReset()
{
	BITMin = MAX_GAME_TIME_MIN;
	Sec = 0;
	MinStr = String(BITMin);
	SecStr = String(Sec);
	MinTxt.SetText(MinStr);
	SecTxt.SetText(SecStr);
	m_InGameBool = true;
}


function OnHide()
{
	Me.KillTimer( TIMER_ID );
}
defaultproperties
{
}
