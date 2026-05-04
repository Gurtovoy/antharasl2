/**************************************************************************************************************************************
 * 
 *  추천 시스템 -> 활력 윈도우
 *  
 *  CT26P2_0825 버전 네비트의 강림이 추가되면서 활력 윈도우로 사용한다.
 *                                                          - 2010.8.4 winkey
 **************************************************************************************************************************************/
class RecommendBonusWnd extends UICommonAPI;

/************************ 네비트 강림 추가 ************************/
var		WindowHandle				Navit_Tooltip_Icon;
var		WindowHandle				Navit_Tooltip_Gauge;
var		TextureHandle				Navit_Tex_Glow;
var		TextureHandle				Navit_Tex_Icon;
var		TextureHandle				Navit_Tex_Gauge;
var		bool						m_bNavit;
var		int							m_Navit_Level;
var		int							m_NavitEffectRemainSec;
var		int							m_NavitIConFactor;			// 네비트 발동 시 아이콘 깜빡임에 관여
var		int							m_NavitGaugeFactor;			// 네비트 단계 변화 시에 깜빡일 횟수, 소멸에 관여

const 	NAVIT_TIMER_ID_TOOLTIP		= 7000;						// 네비트 발동 시 툴팁에 사용하는 타이머
const 	NAVIT_TIMER_ID_ICON			= 7001;						// 네비트 발동 시 아이콘 애니메이션에 사용하는 타이머
const 	NAVIT_TIMER_ID_GAUGE		= 7002;						// 네비트 단계 변화 시 효과에 사용하는 타이머
const 	NAVIT_TIMER_DELAY_TOOLTIP	= 1000;	
const 	NAVIT_TIMER_DELAY_ICON		= 500;	
const 	NAVIT_TIMER_DELAY_GAUGE		= 500;	
const 	NAVIT_MAX_POINT				= 7200;						// 네비트 강림 효과 발동 포인트
const 	NAVIT_MAX_TIME				= 14400;					// 네비트 보너스 시간 최대치
const 	ANIM_MIN_ALPHA				= 39;
const 	ANIM_MAX_ALPHA				= 197;
const 	ANIM_SPEEDFLOAT				= 0.40f;

const TIMER_ID=1050;                                            // ID (일정한 타이머 규칙은 없는듯, 없는 것을 검색해서 지정)
const TIMER_DELAY=1000;                                         // 1분 마다 delay

/** Wnd 핸들 정의 */
var WindowHandle Me;
var RecommendBonusHelpHtmlWnd RecommendBonusHelpHtmlWndScript;	// 추천 정보창 

var ButtonHandle helpHtmlPopupButton;
var ButtonHandle recommendBonusWndCloseButton;

var TextBoxHandle bonusExpTextBox2;                             // 보너스 Exp 표시
var TextBoxHandle bonusTimeLimitTextBox2;                       // 보너스 시간 표시

var int currentRemainTimeValue;                                 // 현재 보너스 시간

//branch : gorillazin 10. 04. 14. - new vote event
var bool m_bIsNewVoteEvent;
var bool m_bIsFirstNewVoteEventMessage;
//end of branch

/** 이벤트 등록 */
function OnRegisterEvent()
{
	RegisterEvent( EV_ReceiveNewVoteSystemInfo );	
	RegisterEvent( EV_NavitAdventPointInfo );
	RegisterEvent( EV_NavitAdventEffect );
	RegisterEvent( EV_NavitAdventTimeChange );
}

/** 타이머 발생  */
function OnTimer(int TimerID)
{
	if(TimerID == TIMER_ID)
	{
		currentRemainTimeValue = currentRemainTimeValue - 1;
		UpdateTime(currentRemainTimeValue);
	}

	else if( TimerID == NAVIT_TIMER_ID_TOOLTIP )		TimerNavitToolTip();
	else if( TimerID == NAVIT_TIMER_ID_ICON )			TimerNavitIconBlink();
	else if( TimerID == NAVIT_TIMER_ID_GAUGE )			TimerNavitGaugeBlink();
	
}

/** OnLoad */
function OnLoad()
{
	OnRegisterEvent();
	
	Me = GetWindowHandle("RecommendBonusWnd");

	recommendBonusWndCloseButton = GetButtonHandle("RecommendBonusWnd.recommendBonusWndCloseButton");
	helpHtmlPopupButton = GetButtonHandle("RecommendBonusWnd.helpHtmlPopupButton");

	bonusExpTextBox2 = GetTextboxHandle("RecommendBonusWnd.NavitBless_Txt_Prog_Sys");
	bonusTimeLimitTextBox2 = GetTextboxHandle("RecommendBonusWnd.NavitBless_Txt_Time_Sys");

	RecommendBonusHelpHtmlWndScript = RecommendBonusHelpHtmlWnd( GetScript("RecommendBonusHelpHtmlWnd") );

	Navit_Tooltip_Icon			= GetWindowHandle( "RecommendBonusWnd.NavitAdv_Tooltip_Icon" );
	Navit_Tooltip_Gauge			= GetWindowHandle( "RecommendBonusWnd.NavitAdv_Tooltip_Gauge" );
	Navit_Tex_Glow				= GetTextureHandle( "RecommendBonusWnd.NavitAdv_Tex_Glow" );
	Navit_Tex_Icon				= GetTextureHandle( "RecommendBonusWnd.NavitAdv_Tex_Icon" );
	Navit_Tex_Gauge				= GetTextureHandle( "RecommendBonusWnd.NavitAdv_Tex_Gauge" );

	// Init
	Navit_Tex_Glow.SetAlpha( 0 );
	
	//branch : gorillazin 10. 04. 14. - new vote event
	m_bIsNewVoteEvent = false;
	m_bIsFirstNewVoteEventMessage = false;
	//end of branch
}

/** OnShow */
function OnShow()
{
	//debug("onShow - recommend ");	
}

/** OnClickButton */
function OnClickButton( String a_ButtonID )
{
	// debug("a_ButtonID " @ a_ButtonID);
	switch( a_ButtonID )
	{
		case "VitalBonus_Btn_helpHtml":
			OnReCommendBonusHelpClick();
			break;

		case "VitalBonus_Btn_Close":
			// class'UIAPI_WINDOW'.static.HideWindow("RecommendBonusWnd");

			Me.HideWindow();
			break;
	}
}

/** OnEvent */
function OnEvent( int a_EventID, String a_Param )
{
	switch( a_EventID )
	{
		case EV_ReceiveNewVoteSystemInfo: getDataByServer(a_param);break;
		case EV_NavitAdventPointInfo		: HandleNavitPointInfo(a_Param);		break;
		case EV_NavitAdventEffect			: HandleNavitEffect(a_Param);			break;
		case EV_NavitAdventTimeChange		: HandleNavitTimeChange(a_Param);		break;
	}
}

/** 도움말 버튼 클릭 */
function OnReCommendBonusHelpClick()
{	

	local string strParam;
	
	if(IsShowWindow("RecommendBonusHelpHtmlWnd"))
	{
		HideWindow("RecommendBonusHelpHtmlWnd");		
	}
	else
	{
		class'UIAPI_WINDOW'.static.SetFocus("RecommendBonusHelpHtmlWnd");	
		ParamAdd(strParam, "FilePath", "..\\L2text\\event_2010_bless001.htm");
		ExecuteEvent(EV_ShowNewVoteSystemHelp);
	}
}

/** OnEnterState  */
function OnEnterState( name a_PreStateName )
{	
	//branch : gorillazin 10. 04. 14. - new vote event	
	if(m_bIsNewVoteEvent)
	{
		Me.ShowWindow();
	}
	else
	{
		Me.HideWindow();
	}
	//end of branch
}

/** OnExitState  */
function OnExitState( name a_NextStateName )
{
	// state 가 변경 될때 타이머를 정지 시키는게 맞는듯 하다. 하지만 정상적으로 서버쪽에서 상태가 바뀌고 다시 올때
	// 값을 주는지에 대한 것이 확실치 않아서 일단 정지 시키는 것은 사용하지 않았다. 
	// Me.KillTimer(TIMER_ID);	
	
	//branch : gorillazin 10. 04. 14. - new vote event	
	Me.HideWindow();
	//end of branch
}

/** 서버에서 새로운 값을 받으면 갱신 한다. */
function getDataByServer (string param)
{ 
	local int voteCount;
	local int bonusCount;
	local int leftBonusTime;
	local int bonusRate;
	local int isOverTime;

	Parseint(Param, "voteCount", voteCount) ;
	Parseint(Param, "bonusCount", bonusCount) ;
	Parseint(Param, "leftBonusTime", leftBonusTime);
	Parseint(Param, "bonusRate", bonusRate);
	Parseint(Param, "isOverTime", isOverTime);

	// debug(" voteCount : " @ voteCount);
	// debug(" bonusCount : " @ bonusCount);
	// debug("=======================================");

	// debug(" leftBonusTime : " @ leftBonusTime);
	// debug(" bonusRate : " @ bonusRate);	
	// debug("isOverTiemr: " @ isOverTime);
	
	//branch : gorillazin 10. 04. 14. - new vote event	
	//if(!m_bIsFirstNewVoteEventMessage)
	//{
	//	m_bIsNewVoteEvent = true;				
	//	m_bIsFirstNewVoteEventMessage = true;
	//}
	if(!m_bIsFirstNewVoteEventMessage)
	{
		if(!m_bIsNewVoteEvent)
		{
			Me.ShowWindow();
			m_bIsNewVoteEvent = true;
		}
		m_bIsFirstNewVoteEventMessage = true;
	}	
	//end of branch
	
	Me.KillTimer(TIMER_ID);	
		
	UpdateTime(leftBonusTime);


	// 타이머 작동 
	if (isOverTime==1 || leftBonusTime>0 && isOverTime==10 || isOverTime==11) // TTP 41591
	{
		bonusTimeLimitTextBox2.SetText (GetSystemString(2275));
		bonusExpTextBox2.SetText (bonusRate $ "%");
	}
	else 
	{
		if (0 < leftBonusTime)
		{
			bonusExpTextBox2.SetText (bonusRate $ "%");
			currentRemainTimeValue = leftBonusTime;

			//  타이머 시작 		
			Me.SetTimer( TIMER_ID, TIMER_DELAY );
		}
		else
		{
			bonusExpTextBox2.SetText ("0%");
		}
	}
}

/** 창을 감추고 보여주는 함수 */
function visibleToggleWnd()
{
	if(class'UIAPI_WINDOW'.static.IsShowWindow("RecommendBonusWnd"))
	{
		class'UIAPI_WINDOW'.static.HideWindow("RecommendBonusWnd");
	}
	else 
	{
		class'UIAPI_WINDOW'.static.ShowWindow("RecommendBonusWnd");
	}
}

/** 시간 갱신 */
function UpdateTime(int iRemainSecond)
{
	local int temp1;
	local int m_timeHour;
	local int m_timeMin;
	local int m_timeSec;
	
	// 시간 갱신.
	temp1 = iRemainSecond / 60;
	
	m_timeHour = temp1 / 60;		// 시
	m_timeMin = temp1 % 60;			// 분
	m_timeSec = iRemainSecond % 60;	// 초
	
	// debug(" m_timeHour : " $ m_timeHour $ "m_timeMin : "  $ m_timeMin$ "m_timeSec : "  $ m_timeSec);	
	
	// 시를 그려준다.
	if(m_timeHour > 0)
	{
		if (m_timeHour < 10 ) bonusTimeLimitTextBox2.setText( "0" $ string( m_timeHour ));
		else bonusTimeLimitTextBox2.setText( string( m_timeHour ));
	}
	else
	{
		bonusTimeLimitTextBox2.setText("00");
	}
	
	bonusTimeLimitTextBox2.SetText(bonusTimeLimitTextBox2.GetText() $ ":");

	// 분을 그려준다.
	if( m_timeMin > 0)
	{
		if (m_timeMin < 10 ) bonusTimeLimitTextBox2.setText(bonusTimeLimitTextBox2.GetText() $ "0" $ string( m_timeMin ));
		else bonusTimeLimitTextBox2.setText(bonusTimeLimitTextBox2.GetText() $ string( m_timeMin ));		
	}
	else
	{
		bonusTimeLimitTextBox2.setText(bonusTimeLimitTextBox2.GetText() $ "00");
	}
	
	// 시간이 0이 되면 정지
	if(m_timeHour <= 0 && m_timeMin <= 0 && m_timeSec <= 0)
	{
		me.KillTimer( TIMER_ID );
	}
	
	// 시간이 0보다 작거나 같으면 
	if (iRemainSecond <= 0)
	{
		bonusExpTextBox2.SetText ("0%");
		bonusTimeLimitTextBox2.SetText (GetSystemString(908));
	}
}



/************************ 네비트 강림 추가 ************************/
function HandleNavitPointInfo( String a_Param )
{
	local int point;
	local int level;
	local int percent;
	ParseInt( a_Param, "NavitPoint", point );
	level = point / ( NAVIT_MAX_POINT / 12 );
	percent = ( point * 100.0 ) / NAVIT_MAX_POINT;

	if( percent > 100 ) percent = 100;

	if( !m_bNavit )
	{
		NavitGaugeChange( level, false );
		Navit_Tooltip_Gauge.SetTooltipCustomType( MakeTooltipSimpleText( 
			MakeFullSystemMsg( GetSystemMessage(3271), String( percent )$"%", "" ) ) );
	}
}
function HandleNavitEffect( String a_Param )
{
	ParseInt( a_Param, "RemainSeconds", m_NavitEffectRemainSec );
	
	if( m_NavitEffectRemainSec > 0 )
	{
		//debug("$$$$$$$$$$$$$$$네비트 발동!!!! : " @ m_NavitEffectRemainSec );
		m_bNavit = true;
		NavitGaugeChange( 12, true );

		Me.KillTimer( NAVIT_TIMER_ID_TOOLTIP );
		Me.SetTimer( NAVIT_TIMER_ID_TOOLTIP, NAVIT_TIMER_DELAY_TOOLTIP );

		m_NavitIConFactor = 0;
		Me.KillTimer( NAVIT_TIMER_ID_ICON );
		Me.SetTimer( NAVIT_TIMER_ID_ICON, NAVIT_TIMER_DELAY_ICON );
	}
	else
	{
		//debug("$$$$$$$$$$$$$$$네비트 발동해제!!" );
		m_bNavit = false;
		NavitGaugeChange( m_Navit_Level, true );

		Me.KillTimer( NAVIT_TIMER_ID_TOOLTIP );
		Me.KillTimer( NAVIT_TIMER_ID_ICON );

		Navit_Tex_Glow.SetAlpha( 0, ANIM_SPEEDFLOAT );
	}
}
function HandleNavitTimeChange( String a_Param )
{
	local int bStart;
	local int navitTime;
	local string tooltip;

	ParseInt( a_Param, "bStart", bStart );
	ParseInt( a_Param, "navitTime", navitTime );
	
	if( navitTime > NAVIT_MAX_TIME )
	{
		// 종료
		tooltip = MakeFullSystemMsg( GetSystemMessage(3277), GetSystemString(908), "" );
		Navit_Tex_Icon.SetTexture( "BranchSys2.ui.Br_NavitIcon_B" );
	}
	else
	{
		if( bStart == 1 )
		{
			// 활성화 = 시간 표시
			tooltip = MakeFullSystemMsg( GetSystemMessage(3277), NavitUpdateTime( NAVIT_MAX_TIME - navitTime ), "" );
			Navit_Tex_Icon.SetTexture( "BranchSys2.ui.Br_NavitIcon_N" );
		}
		else
		{
			// 유지
			tooltip = MakeFullSystemMsg( GetSystemMessage(3277), GetSystemString(2320), "" );
			Navit_Tex_Icon.SetTexture( "BranchSys2.ui.Br_NavitIcon_B" );
		}	
	}

	Navit_Tooltip_Icon.SetTooltipCustomType( MakeTooltipSimpleText( tooltip ) );
}

function TimerNavitIconBlink()
{
	if( m_NavitIConFactor % 2 == 0 )			Navit_Tex_Glow.SetAlpha( ANIM_MIN_ALPHA, ANIM_SPEEDFLOAT );
	else										Navit_Tex_Glow.SetAlpha( ANIM_MAX_ALPHA, ANIM_SPEEDFLOAT );

	m_NavitIConFactor = m_NavitIConFactor + 1;
}
function TimerNavitGaugeBlink()
{
	if( m_NavitGaugeFactor % 2 == 0 )			Navit_Tex_Gauge.SetAlpha( ANIM_MIN_ALPHA, ANIM_SPEEDFLOAT );
	else										Navit_Tex_Gauge.SetAlpha( ANIM_MAX_ALPHA, ANIM_SPEEDFLOAT );
	
	if( m_NavitGaugeFactor > 16 )
	{
		Me.KillTimer( NAVIT_TIMER_ID_GAUGE );
		Navit_Tex_Gauge.SetAlpha( 255, ANIM_SPEEDFLOAT );
	}
	
	m_NavitGaugeFactor = m_NavitGaugeFactor + 1;
}
function TimerNavitToolTip()
{
	if( m_NavitEffectRemainSec > 0 ) m_NavitEffectRemainSec = m_NavitEffectRemainSec - 1;
	Navit_Tooltip_Gauge.SetTooltipCustomType( MakeTooltipSimpleText( MakeFullSystemMsg( GetSystemMessage(3270), String( m_NavitEffectRemainSec ), "" ) ) );
}
function string NavitUpdateTime( int RemainSec )
{
	local	int		Hour;
	local	int		Min;
	local	int		tmpSec;
	local	String	strTime;
	
	if( RemainSec > 0 )
	{
		// Convert Time
		tmpSec = RemainSec / 60;
		Min = tmpSec % 60;
		Hour = tmpSec / 60;
		

		if( Hour < 10 )	strTime = "0" $ String( Hour );
		else			strTime =		String( Hour );
		
		strTime = strTime $ ":";
		
		if( Min < 10 )	strTime = strTime $ "0" $ String( Min );
		else			strTime = strTime $ String( Min );
	}
	else
	{
		strTime = "00:00";
	}
	
	return strTime;
}
function NavitGaugeChange( int level, bool forceChange )
{
	local string texName;
	texName = "BranchSys2.ui.Br_NavitPoint_"$level;

	if( ( forceChange == true ) || ( m_Navit_Level != level ) )
	{
		Navit_Tex_Gauge.SetTexture( texName );
		
		if( level != 0 && level != 12 )					// 0단계, 12단계는 제외
		{
			// play animation
			m_NavitGaugeFactor = 0;
			Me.KillTimer( NAVIT_TIMER_ID_GAUGE );
			Me.SetTimer( NAVIT_TIMER_ID_GAUGE, NAVIT_TIMER_DELAY_GAUGE );
		}
	}

	m_Navit_Level = level;
}

defaultproperties
{
    m_Navit_Level=-1
}
