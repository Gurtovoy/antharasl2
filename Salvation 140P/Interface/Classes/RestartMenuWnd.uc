class RestartMenuWnd extends UICommonAPI;

//부활 재사용 타이머 상수
const TimerValue1 = 329;

var bool m_bShow;
var bool m_bRestartON;

var bool m_bVillage;
var bool m_bAgit;
var bool m_bCastle;
var bool m_bBattleCamp;
var bool m_bOriginal;
var bool m_bFotress;
var bool m_bUnPenaltyLimit; //모험가의 노래

//Handle List
var WindowHandle	m_wndTop;
var ButtonHandle	m_btnVillage;
var ButtonHandle	m_btnAgit;
var ButtonHandle	m_btnCastle;
var ButtonHandle	m_btnBattleCamp;
var ButtonHandle	m_btnOriginal;
var ButtonHandle	m_btnFortress;
var ButtonHandle	m_btnUnPenaltyLimit; //모험가의 노래
var TextBoxHandle   UnPenaltyTime;

//부활 재사용 시간
var int reLiveTime;

function OnRegisterEvent()
{
	RegisterEvent( EV_Die );
	RegisterEvent( EV_Restart );
	RegisterEvent( EV_RestartMenuShow );
	RegisterEvent( EV_RestartMenuHide );
}

function OnLoad()
{
	
	//Init Handle
	m_wndTop = GetWindowHandle( "RestartMenuWnd" );
	m_btnVillage = GetButtonHandle( "RestartMenuWnd.btnVillage" );
	m_btnAgit = GetButtonHandle( "RestartMenuWnd.btnAgit" );
	m_btnCastle = GetButtonHandle( "RestartMenuWnd.btnCastle" );
	m_btnBattleCamp = GetButtonHandle( "RestartMenuWnd.btnBattleCamp" );
	m_btnOriginal = GetButtonHandle( "RestartMenuWnd.BtnUnPenalty" );
	m_btnFortress = GetButtonHandle( "RestartMenuWnd.btnFortress" );
	UnPenaltyTime = GetTextBoxHandle ( "RestartMenuWnd.UnPenaltyTime" );
	m_btnUnPenaltyLimit = GetButtonHandle( "RestartMenuWnd.btnUnPenaltyLimit" ); //모험가의 노래

	m_bShow = false;
	m_bRestartON = false;
}

function OnShow()
{
	m_bShow = true;
}

function OnHide()
{
	m_bShow = false;
}

function OnEnterState( name a_PreStateName )
{
	if (m_bRestartON)
	{
		ShowMe();
	}
	else
	{
		HideMe();
	}
}

function OnEvent(int Event_ID, string param)
{
	if (Event_ID == EV_Die)
	{
		HandleDie(param);
	}
	else if (Event_ID == EV_Restart)
	{
		HandleRestart();
	}
	else if (Event_ID == EV_RestartMenuShow)
	{
		HandleRestartMenuShow();
	}
	else if (Event_ID == EV_RestartMenuHide)
	{
		HandleRestartMenuHide();
	}
}

function OnClickButton( string strID )
{
	switch( strID )
	{
	case "btnVillage":
		timerAllKill();
		OnVillageClick();
		break;
	case "btnAgit":
		timerAllKill();
		OnAgitClick();
		break;
	case "btnCastle":
		timerAllKill();
		OnCastleClick();
		break;
	case "btnBattleCamp":
		timerAllKill();
		OnBattleCampClick();
		break;
	case "BtnUnPenalty":
		timerAllKill();
		OnOriginalClick();
		break;
	case "btnFortress":
		timerAllKill();
		OnFortressClick();
		break;
	case "btnUnPenaltyLimit": //모험가의 노래
		timerAllKill();
		OnUnPenaltyLimitClick();
		break;
	}
}

//버튼 클릭 처리
function OnVillageClick()
{
	RequestRestartPoint(RPT_VILLAGE);
	HideMe();
	
}
function OnAgitClick()
{
	RequestRestartPoint(RPT_AGIT);
	HideMe();
}
function OnCastleClick()
{
	RequestRestartPoint(RPT_CASTLE);
	HideMe();
}
function OnBattleCampClick()
{
	RequestRestartPoint(RPT_BATTLE_CAMP);
	HideMe();
}
function OnOriginalClick()
{
	RequestRestartPoint(RPT_ORIGINAL_PLACE);
	HideMe();
}
function OnFortressClick()
{
	RequestRestartPoint(RPT_FORTRESS);
	HideMe();
}
function OnUnPenaltyLimitClick() //모험가의 노래
{
	RequestRestartPoint(RPT_ORIGINAL_PLACE_LIMIT);
	HideMe();
}

//리스타트 포인트를 받았을때
function HandleDie(string param)
{	
	local int Village;
	local int Agit;
	local int Castle;
	local int BattleCamp;
	local int Original;
	local int Fortress;	
	local int DelayToUseRebirthItem; //부활 재사용 시간
	local int AvailableCountRebirthItem; //모험가의 노래 : 오늘 남은 사용횟수
	
	local int WinSize; //모험가의 노래 : 윈도우 세로 사이즈
	WinSize = 175;  //모험가의 노래	
	
	ParseInt(param, "Village" ,Village);
	ParseInt(param, "Agit" ,Agit);
	ParseInt(param, "Castle" ,Castle);
	ParseInt(param, "BattleCamp" ,BattleCamp);
	ParseInt(param, "Original" ,Original);
	ParseInt(param, "Fortress" ,Fortress);
	ParseInt(param, "DelayToUseRebirthItem" ,DelayToUseRebirthItem);
	ParseInt(param, "AvailableCountRebirthItem" ,AvailableCountRebirthItem); //모험가의 노래

	Debug(param);

	m_bVillage = false;
	m_bAgit = false;
	m_bCastle = false;
	m_bBattleCamp = false;
	m_bOriginal = false;
	m_bFotress = false;	
	m_bUnPenaltyLimit = false; //모험가의 노래	

	if (Village>0)
		m_bVillage = true;
	if (Agit>0)
		m_bAgit = true;
	if (Castle>0)
		m_bCastle = true;
	if (BattleCamp>0)
		m_bBattleCamp = true;	
	if (Fortress>0)
		m_bFotress = true;
	//모험가의 노래	
	if (AvailableCountRebirthItem>0)
	{
		m_bUnPenaltyLimit = true;	
		UnPenaltyTime.SetText("");
	}
	if (Original>0)
	{
		m_bOriginal = true;

		if( DelayToUseRebirthItem != 0 )
		{
			timerAllKill();

			m_btnOriginal.DisableWindow();
			reLiveTime = DelayToUseRebirthItem - 1;
			setReLiveText();
			m_wndTop.SetTimer(TimerValue1, 1000);
			WinSize = 216; //모험가의 노래
		}
		else 
		{
			m_btnOriginal.EnableWindow();
			UnPenaltyTime.SetText(""); //모험가의 노래
			WinSize = 201; //모험가의 노래
		}
	}
		
	windowReSize(WinSize);	//모험가의 노래
}

function HandleRestartMenuShow()
{
	ShowMe();
}

function HandleRestartMenuHide()
{
	HideMe();
}

function HandleRestart()
{
	HideMe();
}

function ShowMe()
{
	if (!m_bVillage && !m_bAgit && !m_bCastle && !m_bBattleCamp && !m_bOriginal && !m_bFotress && !m_bUnPenaltyLimit) //모험가의 노래	
	{
	}
	else
	{
		m_bRestartON = true;
		m_wndTop.ShowWindow();
		
		if (m_bVillage)
			m_btnVillage.ShowWindow();
		else
			m_btnVillage.HideWindow();
		
		if (m_bAgit)
			m_btnAgit.ShowWindow();
		else
			m_btnAgit.HideWindow();
			
		if (m_bCastle)
			m_btnCastle.ShowWindow();
		else
			m_btnCastle.HideWindow();
			
		if (m_bBattleCamp)
			m_btnBattleCamp.ShowWindow();
		else
			m_btnBattleCamp.HideWindow();
		
		//축복받은 깃털 사용
		if (m_bOriginal)
			m_btnOriginal.ShowWindow();
		else
			m_btnOriginal.HideWindow();
		
		if (m_bFotress)
			m_btnFortress.ShowWindow();
		else
			m_btnFortress.HideWindow();
			
		//모험가의 노래
		if (m_bUnPenaltyLimit)
			m_btnUnPenaltyLimit.ShowWindow();
		else
			m_btnUnPenaltyLimit.HideWindow();
		
		m_wndTop.SetFocus();
	}
	
}

function HideMe()
{
	timerAllKill();
	m_bRestartON = false;
	m_wndTop.HideWindow();
}

//타이머
function OnTimer(int TimerID)
{
	if (TimerID==TimerValue1)
	{	
		//m_wndTop.KillTimer(TimerValue1);
		reLiveTime = reLiveTime - 1;		
		setReLiveText();

		/*
		if( reLiveTime != 0 )
		{
			m_wndTop.SetTimer( TimerValue1, 1000);
		}*/

		if( reLiveTime == 0 )
		{
			m_wndTop.KillTimer(TimerValue1);
			m_btnOriginal.EnableWindow();
			//windowReSize(false); //모험가의 노래
		}
	} 
}

//부할 재사용 타이머 삭제
function timerAllKill()
{
	m_wndTop.KillTimer(TimerValue1);
}

//창 사이즈 조절 - 모험가의 노래
function windowReSize( int size )
{
	m_wndTop.SetWindowSize( 135, size );
}

//축복받은 깃털 메시지 뿌려줌
function setReLiveText()
{
	local string str;

	str = MakeFullSystemMsg( GetSystemMessage(3278), string( reLiveTime ) );
	UnPenaltyTime.SetText( str );
}
defaultproperties
{
}
