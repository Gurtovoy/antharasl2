class FishViewportWnd extends UICommonAPI;


const EFFECT_TIMER_ID=2;
const EFFECT_TIMER_DELAY=1000;
const STATUS_TIMER_ID=3;
const STATUS_TIMER_DELAY=0;

const REELING_TIMER_ID=5;
const PUMPING_TIMER_ID=4;
const PUMPING_TIMER_DELAY=80;

const FAKE_TIMER_ID=7;


var string m_WindowName;

var WindowHandle m_hFishViewportWnd;

var WindowHandle m_hPumpingIcon;
var TextBoxHandle m_hPumpingText;
var WindowHandle m_hReelingIcon;
var TextBoxHandle m_hReelingText;

var WIndowHandle m_hFishHPBarEffect;
var BarHandle m_hFishHPBar;
var BarHandle m_hFishHPBarFake;
var TextBoxHandle m_hTbSec;
var WindowHandle m_hTexClock;

var WindowHandle m_hWndStatus;
var TextBoxHandle m_hTbStatus;
var TextBoxHandle m_hTbDeltaHP;

var WindowHandle m_hFakeIcon;

var int m_OriginalFishHP;
var int m_OriginalFishTime;
var int m_CurrentFishHP;

var int m_PumpintTimerCount;

var int m_FakeTimerCount;

var int m_FishLevel;

var string m_FishState;

//쉐이더 빌더 스테이트 삭제로 쓰임이 없어짐
//var bool bShow;

function OnRegisterEvent()
{
	//쉐이더 빌더 스테이트 삭제로 쓰임이 없어짐
//	RegisterEvent( EV_Restart);

	RegisterEvent( EV_FishViewportWndShow );
	RegisterEvent( EV_FishViewportWndHide );
	RegisterEvent( EV_FishRankEventButtonShow );
	RegisterEvent( EV_FishRankEventButtonHide );

	RegisterEvent( EV_FishViewportWndFinalAction );
	RegisterEvent( EV_FishViewportWndInitFishStatus );
	RegisterEvent( EV_FishViewportWndSetFishStatus );
}

function OnLoad()
{
	/*
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	if(CREATE_ON_DEMAND==0)
		InitHandle();
	else*/

	InitHandleCOD();

	HideHPBarNEtc();

	m_hFishHPBarEffect.HideWindow();

	m_OriginalFishHP=0;
	m_FishState = "stanby";

	registerState( "FishViewportWnd", "GamingState" );	
}

/* 쉐이더 빌드 스테이트 삭제 20130829 LDW
* 쉐이더 빌더 스테이트 삭제로 쓰임이 없어짐
function onEnterState ( name a_PreStateName  )
{	
	
	if ( a_PreStateName == 'ShaderBuildState' )	
	{
		//쉐이더 빌드에 들어왔었을 때 			
		if ( bShow ) 
		{
			m_hFishViewportWnd.ShowWindow();
			m_hFishViewportWnd.SetFocus();
		}
	}
}
*/
/*
function InitHandle()
{
	m_hPumpingIcon = GetHandle( m_WindowName$".texPumping" );
	m_hPumpingText = TextBoxHandle(GetHandle(m_WindowName$".txtPumping"));
	m_hReelingIcon = GetHandle( m_WindowName$".texReeling" );
	m_hReelingText = TextBoxHandle(GetHandle(m_WindowName$".txtReeling"));

	m_hFishHPBar = BarHandle(GetHandle( m_WindowName $ ".barFishHp" ));
	m_hFishHPBarFake= BarHandle(GetHandle( m_WindowName $ ".barFishHpFake" ));
	m_hFishHPBarEffect = GetHandle( m_WindowName$".wndEffect" );
	m_hFishViewportWnd = GetHandle( m_WindowName );
	m_hTbSec=TextBoxHandle(GetHandle(m_WindowName$".txtVarSec"));
	m_hTexClock=GetHandle(m_WindowName$".texClock");

	m_hWndStatus=GetHandle(m_WindowName$".wndStatus");
	m_hTbStatus=TextBoxHandle(GetHandle(m_WindowName$".wndStatus.txtVarStatus"));
	m_hTbDeltaHP=TextBoxHandle(GetHandle(m_WindowName$".wndStatus.txtVarDeltaHP"));

	m_hFakeIcon
}*/



function InitHandleCOD()
{
	m_hPumpingIcon = GetWindowHandle( m_WindowName$".texPumping" );
	m_hPumpingText = TextBoxHandle(GetWindowHandle(m_WindowName$".txtPumping"));
	m_hReelingIcon = GetWindowHandle( m_WindowName$".texReeling" );
	m_hReelingText = TextBoxHandle(GetWindowHandle(m_WindowName$".txtReeling"));

	m_hFishHPBar = GetBarHandle( m_WindowName $ ".barFishHp" );
	m_hFishHPBarFake= GetBarHandle( m_WindowName $ ".barFishHpFake" );
	m_hFishHPBarEffect = GetWindowHandle( m_WindowName$".wndEffect" );
	m_hFishViewportWnd = GetWindowHandle( m_WindowName );
	m_hTbSec=GetTextBoxHandle(m_WindowName$".txtVarSec");
	m_hTexClock=GetWindowHandle(m_WindowName$".texClock");

	m_hWndStatus=GetWindowHandle(m_WindowName$".wndStatus");
	m_hTbStatus=GetTextBoxHandle(m_WindowName$".wndStatus.txtVarStatus");
	m_hTbDeltaHP=GetTextBoxHandle(m_WindowName$".wndStatus.txtVarDeltaHP");

	m_hFakeIcon = GetWindowHandle( m_WindowName$".texFakeIcon" );
}

function OnEvent( int Event_ID, string param )
{	
	switch( Event_ID )
	{
		/*
		 *쉐이더 빌더 스테이트 삭제로 쓰임이 없어짐
	case EV_Restart:
		bShow = false;
		break;
*/
	
	case EV_FishViewportWndShow :
		m_hFakeIcon.HideWindow();
		m_hFishViewportWnd.ShowWindow();
		m_hFishViewportWnd.SetFocus();

		HideHPBarNEtc();

		m_hFishHPBarEffect.HideWindow();

//		bShow = true;

		break;

	case EV_FishViewportWndHide :
		m_hFishViewportWnd.HideWindow();

		//쉐이더 빌더 스테이트 삭제로 쓰임이 없어짐
		//bShow = false;
		break;

	case EV_FishViewportWndFinalAction :
		if(m_hFishHPBar.IsShowWindow() || m_hFishHPBarFake.IsShowWindow())
			ShowEffect();
		break;

	case EV_FishViewportWndInitFishStatus :		
		HandleInitFishStatus(param);
		break;

	case EV_FishViewportWndSetFishStatus :		
		HandleSetFishStatus(param);
		break;

	case EV_FishRankEventButtonShow :
		ShowWindow(m_WindowName$".btnRanking");
		break;
	case EV_FishRankEventButtonHide :		
		HideWindow(m_WindowName$".btnRanking");
		break;
	}
}

function ShowHPBarNEtc(int ShowType, int Guts)
{
	m_hFishHPBar.ShowWindow();
	m_hTexClock.ShowWindow();
	m_hTbSec.ShowWindow();

	if(ShowType == 4) // 낚시 종료시 더이상 표시하지 않음
	{
		m_hPumpingIcon.HideWindow();
		m_hPumpingText.HideWindow();
		m_hReelingIcon.HideWindow();
		m_hReelingText.HideWindow();
	}
	else if(m_FishLevel == 0)	// 초보 낚시일때
	{
		if(Guts == 0)	// 근성 상태가 아님 -> 펌핑
		{
			m_hPumpingIcon.ShowWindow();
			m_hPumpingText.ShowWindow();
			m_hReelingIcon.HideWindow();
			m_hReelingText.HideWindow();

			if(m_FishState != "pumping")
			{
				m_hPumpingIcon.SetTimer(PUMPING_TIMER_ID, PUMPING_TIMER_DELAY);
				m_FishState = "pumping";
			}
		}
		else			// 근성 상태 -> 릴링
		{
			m_hPumpingIcon.HideWindow();
			m_hPumpingText.HideWindow();
			m_hReelingIcon.ShowWindow();
			m_hReelingText.ShowWindow();
			if(m_FishState != "reeling")
			{
				m_hReelingIcon.SetTimer(REELING_TIMER_ID, PUMPING_TIMER_DELAY);
				m_FishState = "reeling";
			}
		}
	}
}

function HideHPBarNEtc()
{
	m_hFishHPBar.HideWindow();
	m_hFishHPBarFake.HideWindow();
	m_hTexClock.HideWindow();
	m_hTbSec.HideWindow();
	
	m_hPumpingIcon.HideWindow();
	m_hPumpingText.HideWindow();
	m_hReelingIcon.HideWindow();
	m_hReelingText.HideWindow();
}

function HandleInitFishStatus(string param)
{
	ParseInt(param, "OriginalFishHP", m_OriginalFishHP);
	ParseInt(param, "OriginalFishTime", m_OriginalFishTime);
	ParseInt(param, "FishLevel", m_FishLevel);
	m_CurrentFishHP=m_OriginalFishHP;
}

function HandleSetFishStatus(string param)
{
	local int FishHP;
	local int TimeCount;
	local int DeltaHP;
	local int ShowType;
	local int Guts;
	local int Effect;
	local int Penalty;
	local int Fake;

	ParseInt(param, "CurrentFishHP", FishHP);
	ParseInt(param, "TimeCount", TimeCount);
	ParseInt(param, "ShowType", ShowType);
	ParseInt(param, "Effect", Effect);
	ParseInt(param, "Guts", Guts);
	ParseInt(param, "Penalty", Penalty);
	ParseInt(param, "Fake", Fake);

	DeltaHP=FishHP-m_CurrentFishHP;

	// ShowType == 4 이면 낚시성공이므로 물고기HP와 시간을 업데이트할 필요가 없다.

	if(ShowType!=4)
	{
		m_CurrentFishHP=FishHP;

		m_hFishHPBar.SetValue(m_OriginalFishHP*2, FishHP);
		m_hFishHPBarFake.SetValue(m_OriginalFishHP*2, FishHP);
		m_hTbSec.SetText(string(TimeCount));
	}


	ShowHPBarNEtc(ShowType, Guts);

	// 입질 시작후 3초가 지나면 HP바와 설명(초보 물고기인 경우)을 보여준다.
	if( !m_hFishHPBar.IsShowWindow() &&  (m_OriginalFishTime-TimeCount)>=3 )
	{
		ShowHPBarNEtc(ShowType, Guts);
	}

	if(ShowType==3)		// 입질성공
	{
		ShowFishString(1261, 0);
	}
	else if(ShowType == 4)	// 낚시성공
	{
		ShowFishString(1264, 0);
	}

	if(m_hFishHPBar.IsShowWindow() || m_hFishHPBarFake.IsShowWindow())
	{
		if(Effect != 0)
		{
			ShowEffect();
		}
		if(ShowType == 1)
		{
			if(DeltaHP < 0)	// 펌핑성공
			{
				if(Penalty > 0)
					ShowFishStringWithPenalty(1672, DeltaHP, Penalty);
				else
					ShowFishString(1256, DeltaHP);
			}
			else				// 펌핑실패
				ShowFishString(1258, DeltaHP);
		}
		else if(ShowType == 2)
		{
			if(DeltaHP < 0)	// 릴링성공
			{
				if(Penalty > 0)
					ShowFishStringWithPenalty(1671, DeltaHP, Penalty);
				else
					ShowFishString(1257, DeltaHP);
			}
			else				// 릴링실패
				ShowFishString(1259, DeltaHP);
		}

		if(Fake!=0)
		{
			m_hFishHPBarFake.ShowWindow();
			m_hFishHPBar.HideWindow();
			m_hFakeIcon.HideWindow();

			//찌속임 아이콘 표시
			if ( m_FishLevel == 0 ) 
			{
				m_hFakeIcon.setTimer( FAKE_TIMER_ID, PUMPING_TIMER_DELAY );
				m_hFakeIcon.ShowWindow();
			}
			else
				m_hFakeIcon.HideWindow();
		}
		else
		{
			m_hFishHPBarFake.HideWindow();
			m_hFishHPBar.ShowWindow();
			m_hFakeIcon.HideWindow();
		}
	}
}

function ShowEffect()
{

	m_hFishHPBarEffect.ShowWindow();
	m_hFishHPBarEffect.SetTimer(EFFECT_TIMER_ID,EFFECT_TIMER_DELAY);	
}

function ShowFishString(INT StrID, INT DeltaHP)
{
	local color col;

	if(DeltaHP > 0)
	{
		col.R=255;
		col.G=0;
		col.B=0;
	}
	else
	{
		col.R=220;
		col.G=220;
		col.B=220;
	}

	m_hTbStatus.SetTextColor(col);
	m_hTbDeltaHP.SetTextColor(col);

	m_hTbStatus.SetText(GetSystemString(StrID));
	if(DeltaHP!=0)
		m_hTbDeltaHP.SetText(string(DeltaHP));
	else
		m_hTbDeltaHP.SetText("");


	m_hWndStatus.ShowWindow();
	m_hWndStatus.SetTimer(STATUS_TIMER_ID, STATUS_TIMER_DELAY);
}

function ShowFishStringWithPenalty(INT StrID, INT DeltaHP, INT Penalty)
{
	local color col;

	col.R=255;
	col.G=0;
	col.B=0;

	m_hTbStatus.SetTextColor(col);
	m_hTbDeltaHP.SetTextColor(col);

	m_hTbStatus.SetText(GetSystemMessageWithParamNumber(StrID, Penalty));
	if(DeltaHP!=0)
		m_hTbDeltaHP.SetText(string(DeltaHP));
	else
		m_hTbDeltaHP.SetText("");

	m_hWndStatus.ShowWindow();
	m_hWndStatus.SetTimer(STATUS_TIMER_ID, STATUS_TIMER_DELAY);	
}

function OnClickButton(string strID)
{
	switch(strID)
	{
	case "btnRanking" :
		RequestFishRanking();
		break;
	}
}

function OnTimer(int TimerID)
{
	switch(TimerID)
	{
	case FAKE_TIMER_ID :
		++m_FakeTimerCount;

		if(m_FakeTimerCount % 2 == 0)
		{
			m_hFakeIcon.ShowWindow();			
		}
		else if (m_FakeTimerCount % 2 == 1)
		{			
			m_hFakeIcon.HideWindow();			
		}

		if(m_FakeTimerCount> 2)
		{
			m_hFakeIcon.KillTimer(FAKE_TIMER_ID);			
			m_hFakeIcon.ShowWindow();
			m_FakeTimerCount = 0;
		}
		break;
	break;
	case EFFECT_TIMER_ID :
		m_hFishHPBarEffect.KillTimer(TimerID);
		m_hFishHPBarEffect.HideWindow();
		break;
	case STATUS_TIMER_ID :
		m_hWndStatus.Killtimer(TimerID);
		m_hWndStatus.HideWindow();
		break;
	case PUMPING_TIMER_ID:
		//Debug("펌핑 낚시중");
		++m_PumpintTimerCount;

		if(m_PumpintTimerCount % 2 == 0)
		{
			m_hPumpingIcon.ShowWindow();
			m_hPumpingText.ShowWindow();
			m_hReelingIcon.HideWindow();
			m_hReelingText.HideWindow();
		}
		else if (m_PumpintTimerCount % 2 == 1)
		{
			m_hPumpingIcon.HideWindow();
			m_hPumpingText.HideWindow();
			m_hReelingIcon.HideWindow();
			m_hReelingText.HideWindow();
		}

		if(m_PumpintTimerCount> 2)
		{
			m_hPumpingIcon.KillTimer(PUMPING_TIMER_ID);
			m_PumpintTimerCount = 0;
			m_hPumpingIcon.ShowWindow();
			m_hPumpingText.ShowWindow();
		}
		break;
	case REELING_TIMER_ID:
		//Debug("릴링 낚시중");
		++m_PumpintTimerCount;

		if(m_PumpintTimerCount % 2 == 0)
		{
			m_hReelingIcon.ShowWindow();
			m_hReelingText.ShowWindow();
			m_hPumpingIcon.HideWindow();
			m_hPumpingText.HideWindow();
		}
		else if (m_PumpintTimerCount % 2 == 1)
		{	
			m_hReelingIcon.HideWindow();
			m_hReelingText.HideWindow();
			m_hPumpingIcon.HideWindow();
			m_hPumpingText.HideWindow();
		}

		if(m_PumpintTimerCount> 2)
		{
			m_hReelingIcon.KillTimer(REELING_TIMER_ID);
			m_PumpintTimerCount = 0;
			m_hReelingIcon.ShowWindow();
			m_hReelingText.ShowWindow();
		}
		break;
	}
}

function ClearTimer(int TimerID)
{
	if(TimerID == PUMPING_TIMER_ID)
	{
		m_hPumpingIcon.ShowWindow();
		m_hPumpingText.ShowWindow();
		m_FishState = "pumping";
	}
	if(TimerID == REELING_TIMER_ID)
	{
		m_hReelingIcon.ShowWindow();
		m_hReelingText.ShowWindow();
		m_FishState = "reeling";
	}
}

defaultproperties
{
    m_WindowName="FishViewportWnd"
}
