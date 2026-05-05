class StatusWnd extends UICommonAPI;


const	TIMER_ID1	=	1310;	
const 	TIMER_DELAY1	=	500;	
const	TIMER_ID2	= 	1311;
const	TIMER_DELAY2	=	20000;

//branch
const	TIMER_PREM1	= 1312;
const	TIMER_PREM_DELAY1	= 600;
const	TIMER_PREM2	= 1313;
const	TIMER_PREM_DELAY2	= 30000;
//end of branch

const 	ANIMMINALPHA	=	39;
const 	ANIMMAXALPHA	=	197;
//~ const	ANIMSPEED		=	15;
const	ANIMSPEEDFLOAT	=	0.40f;

var int m_UserID;
var bool m_bReceivedUserInfo;
var int GlobalAlpha;
var bool GlobalAlphaBool; 
var bool AnimTexKill;


//var bool isVPApplyChecked;//활력이 적용 되고 있는 부분을 체크 했는 가?
var bool isAfterStatusNormaEvent; // 버프 이벤트 이후 활력 메시지 출력인가.
var bool isVPApply;//활력이 적용 되고 있는가? 

//var int m_Vitality; //ldw 주석 처리

var WindowHandle Me;
var StatusBarHandle CPBar;
var StatusBarHandle HPBar;
var StatusBarHandle MPBar;

//var StatusBarHandle EXPBar;//ldw
var NameCtrlHandle UserName;
var TextBoxHandle StatusWnd_LevelTextBox;
//var TextureHandle VitalityTex;//ldw 주석 처리
//var TextureHandle LifeForceAnimTex_Left;//ldw 주석
//var TextureHandle LifeForceAnimTex_Center;//ldw 주석
//var TextureHandle LifeForceAnimTex_Right;//ldw 주석
//var WindowHandle Statustooltipwnd;//20130611 xml 에서 삭제 
//var BarHandle VpDetailBar;					// 활력 퍼센트를 표시해주는 게이지 추가 by innowind 2008년 CT2_Final //ldw 주석 처리
var StatusBarHandle VpDetailBar;




var BarHandle barFATIGUE;
//~ var ButtonHandle LifeForceBtn;

// 네비트의 강림 - 2010.7.8 winkey
var TextureHandle 		texNavitGaugeLeft;
var TextureHandle 		texNavitGaugeMid;
var TextureHandle		texNavitGaugeRight;
var int					m_NavitEffectRemainSec;
var int					m_NavitGradeEffectFactor;		// 단계 변화 시에 깜빡일 횟수, 소멸에 관여
const NAVIT_TIMER_ID2		= 7001;		// 네비트 발동 시 Gauge Effect에 사용하는 타이머
const NAVIT_TIMER_DELAY2	= 500;	

//궁극기 추가
var WindowHandle FinalityGageWnd;

var BarHandle FinalityBar01;
var TextureHandle FinalityGageEff1_Left;
var TextureHandle FinalityGageEff1_Center;
var TextureHandle FinalityGageEff1_Right;

var BarHandle FinalityBar02;
var TextureHandle FinalityGageEff2_Left;
var TextureHandle FinalityGageEff2_Center;
var TextureHandle FinalityGageEff2_Right;

var BarHandle FinalityBar03;
var TextureHandle FinalityGageEff3_Left;
var TextureHandle FinalityGageEff3_Center;
var TextureHandle FinalityGageEff3_Right;

var TextureHandle StatusWndBg;

var int preFinalityLev;
var int nowFinalityLev;

const ULTIMATE_SKILL_POINT_BOUNDARY_LEVEL1 = 500;
const ULTIMATE_SKILL_POINT_BOUNDARY_LEVEL2 = 1000;
const ULTIMATE_SKILL_POINT_BOUNDARY_LEVEL3 = 1500;

//const WINDOW_MIN_SIZE_HEIGHT = 66;//ldw 주석
//const WINDOW_MAX_SIZE_HEIGHT = 84;//ldw 주석
const WINDOW_MIN_SIZE_HEIGHT = 82;//ldw 활력 게이지로 수치를 18 늘림
const WINDOW_MAX_SIZE_HEIGHT = 102;//ldw 활력 게이지로 수치를 18 늘림

const WINDOW_CLASSIC_SIZE_HEIGHT = 68;//클래식 서버용 VP 없는 수치


const FINALITYSPEEDFLOAT = 0.40f;
const FINALITYSPEEDFLOAT2 = 0.20f;

const TIMER_BAR = 1410;
const TIMER_BAR_DELAY = 400;

//var int VitalityPer20;//ldw 주석 처리
var int MaxVitality; //ldw
//const MaxVitalityTime = 20;//ldw 20시간 주석 처리
//활력 보너스 추가 2015.05
var int nVitalityExtraBonus;
var int nVitalityBonus;
var int nVitalityItemMaxRestoreCount ;

//자동 파티 시스템 버튼
//var ButtonHandle AutoPartyMatchingBtn;
//자동 파티 시스템 아이콘
//var TextureHandle AutoPartyMatchingIcon;

var L2Util util;//bluesun 툴팁 제어 용

//branch 프리미엄유저
var bool AnimTexKillPremium;
var int m_CurPremiumState;
var bool m_AlphaIncrese;
//end of branch

//branch
var WindowHandle LevelBoxTexPremium;
//end of branch

var TextureHandle StatusWnd_LevelTextBox_back;
var TextBoxHandle StatusWnd_LevelTextBoxAfter100;

var WindowHandle LevelWindowUnder100;
var WindowHandle LevelWindowAfter100;

var WindowHandle LevelBoxTexPremium100;


function OnRegisterEvent()
{
	RegisterEvent( EV_RegenStatus );
	
	//Level과 Exp는 UserInfo패킷으로 처리한다.
	RegisterEvent( EV_UpdateUserInfo );
	
	//JYLee, 의미없는 함수호출을 막기 위해 status 정보를 내 정보와 다른 캐릭터의 정보로 분리
	RegisterEvent( EV_UpdateMyHP );
	RegisterEvent( EV_UpdateMyMaxHP );
	RegisterEvent( EV_UpdateMyMP );
	RegisterEvent( EV_UpdateMyMaxMP );
	RegisterEvent( EV_UpdateMyCP );
	RegisterEvent( EV_UpdateMyMaxCP );

	//RegisterEvent( EV_VitalityPointInfo );	// 활력 업데이트
	RegisterEvent( EV_NavitAdventEffect );	// 네비트의 강림 - 2010.7.8 winkey

	//궁극기 스킬 Point 값
	RegisterEvent( EV_UpdateUltimateSkillPoint );

	//branch
	// F2P 서비스 활력 개선 - gorillazin
	RegisterEvent(EV_VitalityEffectInfo);	
	//end of branch
	
	//branch
	RegisterEvent( EV_BR_PREMIUM_STATE );
	//end of branch

	
	RegisterEvent( EV_NeedResetUIData );


	// 활력 추가 보너스 표시를 버프 이후 보여주기 위해 이벤트 등록
	RegisterEvent( EV_AbnormalStatusNormalItem );
}





//이벤트 등록
function OnLoad()
{		
	//local UserInfo userinfo;//ldw 임시
	//local int Vitality;	//ldw 임시
	//Vitality = userinfo.nVitality;//ldw 임시
	
	
	InitHandleCOD();
	
	
	GlobalAlpha = 0;
	GlobalAlphaBool = true;
//	m_Vitality = 6; //ldw 주석 처리
	//VpDetailBar.SetValue(0, 0); //ldw 주석 처리
	
	InitAnimation();
	
	/*texNavitGaugeLeft.HideWindow();   //ldw 주석 처리
	texNavitGaugeMid.HideWindow();      //ldw 주석 처리
	texNavitGaugeRight.HideWindow();    //ldw 주석 처리
*/

	
	//Statustooltipwnd.ShowWindow();//20130611 xml 에서 삭제 

	FinalityBar01.SetValue(0 , 0);
	FinalityBar02.SetValue(0 , 0);
	FinalityBar03.SetValue(0 , 0);

	 
	preFinalityLev = 0;
	nowFinalityLev = 0;

	
	MaxVitality=GetMaxVitality();//ldw
	//VitalityPer20=MaxVitality/MaxVitalityTime;//ldw	
	
//	AutoPartyMatchingIcon.HideWindow();
	
	//branch
	LevelBoxTexPremium.HideWindow();
	LevelBoxTexPremium100.HideWindow();
	//end of branch
}

function InitHandleCOD()
{
	Me = GetWindowHandle( "StatusWnd" );
	CPBar = GetStatusBarHandle( "StatusWnd.CPBar" );
	HPBar = GetStatusBarHandle( "StatusWnd.HPBar" );
	MPBar = GetStatusBarHandle( "StatusWnd.MPBar" );
	//EXPBar = GetStatusBarHandle( "StatusWnd.EXPBar" ); //ldw 주석
	UserName = GetNameCtrlHandle( "StatusWnd.UserName" );
	StatusWnd_LevelTextBox = GetTextBoxHandle( "StatusWnd.StatusWnd_LevelTextBox_back.StatusWnd_LevelTextBox" );
	//VitalityTex = GetTextureHandle ( "StatusWnd.LifeForceTex"); //ldw 주석
	//LifeForceAnimTex_Left= GetTextureHandle ( "StatusWnd.LifeForceAnimTex_Left"); //ldw 주석
	//LifeForceAnimTex_Center= GetTextureHandle ( "StatusWnd.LifeForceAnimTex_Center"); //ldw 주석
	//LifeForceAnimTex_Right= GetTextureHandle ( "StatusWnd.LifeForceAnimTex_Right"); //ldw 주석
	//Statustooltipwnd = GetWindowHandle( "StatusWnd.Statustooltipwnd");//20130611 xml 에서 삭제 
	//VpDetailBar = GetBarHandle( "StatusWnd.VpDetailBar" );//ldw
	VpDetailBar = GetStatusBarHandle( "StatusWnd.VpDetailBar" );//ldw
	//texNavitGaugeLeft	= GetTextureHandle( "StatusWnd.NavitGaugeLeft" );
	//texNavitGaugeMid	= GetTextureHandle( "StatusWnd.NavitGaugeMid" );
	//texNavitGaugeRight	= GetTextureHandle( "StatusWnd.NavitGaugeRight" );

	FinalityGageWnd = GetWindowHandle( "StatusWnd.FinalityGageWnd.FinalityGageWnd" );

	FinalityBar01 = GetBarHandle( "StatusWnd.FinalityGageWnd.FinalityBar01" );
	FinalityGageEff1_Left = GetTextureHandle ("StatusWnd.FinalityGageWnd.FinalityGageEff1_Left");
	FinalityGageEff1_Center = GetTextureHandle ("StatusWnd.FinalityGageWnd.FinalityGageEff1_Center");
	FinalityGageEff1_Right = GetTextureHandle ("StatusWnd.FinalityGageWnd.FinalityGageEff1_Right");

	FinalityBar02 = GetBarHandle( "StatusWnd.FinalityGageWnd.FinalityBar02" );
	FinalityGageEff2_Left = GetTextureHandle ("StatusWnd.FinalityGageWnd.FinalityGageEff2_Left");
	FinalityGageEff2_Center = GetTextureHandle ("StatusWnd.FinalityGageWnd.FinalityGageEff2_Center");
	FinalityGageEff2_Right = GetTextureHandle ("StatusWnd.FinalityGageWnd.FinalityGageEff2_Right");

	FinalityBar03 = GetBarHandle( "StatusWnd.FinalityGageWnd.FinalityBar03" );
	FinalityGageEff3_Left = GetTextureHandle ("StatusWnd.FinalityGageWnd.FinalityGageEff3_Left");
	FinalityGageEff3_Center = GetTextureHandle ("StatusWnd.FinalityGageWnd.FinalityGageEff3_Center");
	FinalityGageEff3_Right = GetTextureHandle ("StatusWnd.FinalityGageWnd.FinalityGageEff3_Right");

	StatusWndBg = GetTextureHandle ("StatusWnd.FinalityGageWnd.StatusWndBg");

	//AutoPartyMatchingBtn = GetButtonHandle( "StatusWnd.AutoPartyMatchingBtn" );
	//AutoPartyMatchingIcon = GetTextureHandle( "StatusWnd.AutoPartyMatchingIcon" );
	
	//branch
	LevelBoxTexPremium = GetWindowHandle ("StatusWnd.StatusWnd_LevelTextBox_back.WndLevelBackPremium");
	//end of branch

	//StatusWnd_LevelTextBox_back = GetTextureHandle ("StatusWnd.StatusWnd_LevelTextBox_back");

	LevelWindowUnder100 = GetWindowHandle ("StatusWnd.StatusWnd_LevelTextBox_back");
	LevelWindowAfter100 = GetWindowHandle ("StatusWnd.StatusWnd_LevelTextBox_back_lv100");

	StatusWnd_LevelTextBoxAfter100 = GetTextBoxHandle ( "StatusWnd.StatusWnd_LevelTextBox_back_lv100.StatusWnd_LevelTextBox");
	LevelBoxTexPremium100 = GetWindowHandle ("StatusWnd.StatusWnd_LevelTextBox_back_lv100.WndLevelBackPremium_Lv100");

}

function OnTimer(int TimerID)
{
	/*
	if(TimerID == TIMER_ID1)
	{
		if (GlobalAlphaBool)
		{
			LifeForceAnimTex_Left.SetAlpha(ANIMMAXALPHA, ANIMSPEEDFLOAT);
			LifeForceAnimTex_Center.SetAlpha(ANIMMAXALPHA, ANIMSPEEDFLOAT);
			LifeForceAnimTex_Right.SetAlpha(ANIMMAXALPHA, ANIMSPEEDFLOAT);
			GlobalAlphaBool = false;
		}
		else if (!GlobalAlphaBool)
		{
			if (AnimTexKill)
			{
				Me.KillTimer( TIMER_ID1 );
				Me.KillTimer( TIMER_ID2 );
				LifeForceAnimTex_Left.SetAlpha(0, 1f);
				LifeForceAnimTex_Center.SetAlpha(0,1f);
				LifeForceAnimTex_Right.SetAlpha(0, 1f);
			}
			else
			{
				LifeForceAnimTex_Left.SetAlpha(ANIMMINALPHA, ANIMSPEEDFLOAT);
				LifeForceAnimTex_Center.SetAlpha(ANIMMINALPHA,ANIMSPEEDFLOAT);
				LifeForceAnimTex_Right.SetAlpha(ANIMMINALPHA, ANIMSPEEDFLOAT);
			}
			GlobalAlphaBool = true;
		}
	}
	*/
	if(TimerID == TIMER_ID2)
	{
		AnimTexKill = true;
		//~ Me.KillTimer( TIMER_ID1 );
		//~ Me.KillTimer( TIMER_ID2 );
	}
	if( TimerID == NAVIT_TIMER_ID2 )
	{
		OnTimerNavit();
	}

	if( TimerID == TIMER_BAR )
	{
		FinalityBarSetAlpha();
		Me.KillTimer( TIMER_BAR );
	}
	
	//branch
	if (TimerID == TIMER_PREM1)
	{
		if (m_AlphaIncrese)
		{
			LevelBoxTexPremium.SetAlpha(ANIMMAXALPHA, ANIMSPEEDFLOAT);
			LevelBoxTexPremium100.SetAlpha(ANIMMAXALPHA, ANIMSPEEDFLOAT);
			m_AlphaIncrese = false;
		}
		else if (!m_AlphaIncrese)
		{
			if (AnimTexKillPremium)
			{
				Me.KillTimer( TIMER_PREM1 );
				Me.KillTimer( TIMER_PREM2 );
				LevelBoxTexPremium.SetAlpha(255, 1f);
				LevelBoxTexPremium100.SetAlpha(255, 1f);
			}
			else
			{
				LevelBoxTexPremium.SetAlpha(ANIMMINALPHA, ANIMSPEEDFLOAT);
				LevelBoxTexPremium100.SetAlpha(ANIMMINALPHA, ANIMSPEEDFLOAT);
			}
			m_AlphaIncrese = true;
		}	
	}
	if (TimerID == TIMER_PREM2)
	{
		AnimTexKillPremium = true;
		//debug("on timer TIMER_PREM2");
	}
	//end of branch
}

function FinalityBarSetAlpha()
{
	local int i;
	
	for( i = 1 ; i <= 3 ; i ++ )
	{
		GetTextureHandle ( "StatusWnd.FinalityGageWnd.FinalityGageEff"$i$"_Left").SetAlpha(125, FINALITYSPEEDFLOAT);
		GetTextureHandle ( "StatusWnd.FinalityGageWnd.FinalityGageEff"$i$"_Center").SetAlpha(125, FINALITYSPEEDFLOAT);
		GetTextureHandle ( "StatusWnd.FinalityGageWnd.FinalityGageEff"$i$"_Right").SetAlpha(125, FINALITYSPEEDFLOAT);
	}
}


function PlayAnimation()
{
	Me.KillTimer( TIMER_ID1 );
	Me.KillTimer( TIMER_ID2 );	
	AnimTexKill = false;
	Me.SetTimer(TIMER_ID1,TIMER_DELAY1);
	Me.SetTimer(TIMER_ID2,TIMER_DELAY2);
}

function InitAnimation()
{
	Me.KillTimer( TIMER_ID1 );
	Me.KillTimer( TIMER_ID2 );	
	//LifeForceAnimTex_Left.SetAlpha(0); 
	//LifeForceAnimTex_Center.SetAlpha(0);
	//LifeForceAnimTex_Right.SetAlpha(0);
	
	//branch
	Me.KillTimer( TIMER_PREM1 );
	Me.KillTimer( TIMER_PREM2 );
	LevelBoxTexPremium.SetAlpha(1);	
	LevelBoxTexPremium100.SetAlpha(ANIMMINALPHA, ANIMSPEEDFLOAT);
	//end of branch
}

function OnEnterState( name a_PreStateName )
{

	//isVPApplyChecked = false;
	m_bReceivedUserInfo = false;
	isAfterStatusNormaEvent = false;
	//UpdateUserInfo(); //
	
}

function UpdateUserGauge( int Type )
{
	local UserInfo userinfo;

	if( GetPlayerInfo( userinfo ) )
	{
		m_UserID = userinfo.nID;
		
		switch( Type )
		{
		case 0:
			HPBar.SetPoint(userinfo.nCurHP,userinfo.nMaxHP);
		break;
		case 1:
			MPBar.SetPoint(userinfo.nCurMP,userinfo.nMaxMP);
		break;
		case 2:
			CPBar.SetPoint(userinfo.nCurCP,userinfo.nMaxCP);
		break;
		}
	}
}

function UpdateUserInfo()
{
	local UserInfo userinfo;
	local int Vitality;	
	
	//local TextureHandle LevelBoxTexPremium_texture ;
		
//	LevelBoxTexPremium_texture = GetTextureHandle ("StatusWnd.WndLevelBackPremium");

	if( GetPlayerInfo( userinfo ) )
	{
		
		m_UserID = userinfo.nID;
		Vitality = userinfo.nVitality;

		CPBar.SetPoint(userinfo.nCurCP,userinfo.nMaxCP);
		HPBar.SetPoint(userinfo.nCurHP,userinfo.nMaxHP);
		MPBar.SetPoint(userinfo.nCurMP,userinfo.nMaxMP);

		VpDetailBar.SetPoint(Vitality, MaxVitality);

		//EXPBar.SetPointExpPercentRate(userinfo.fExpPercentRate); 
		UserName.SetName(userinfo.Name,NCT_Normal,TA_Left);

		if ( class'UIDATA_USER'.static.IsPrologueGrowType ( userinfo.nSubClass ) && !getInstanceUIData().getIsArenaServer()) 
		{
			if ( GetLanguage() == LANG_Korean )
			{
				StatusWnd_LevelTextBox.SetText( "∞");
			}
			else 
			{
				StatusWnd_LevelTextBox.SetText( "--");
			}
		}			
		else StatusWnd_LevelTextBox.SetInt(userinfo.nLevel);
		StatusWnd_LevelTextBoxAfter100.SetInt(userinfo.nLevel);

		if ( userinfo.nLevel > 99 )
		{			
			userName.SetAnchor("StatusWnd", "TopLeft", "TopLeft", 53, 8);
			//Debug( userinfo.nLevel @ "UpdateUserInfo" );
			LevelWindowUnder100.HideWindow();
			LevelWindowAfter100.ShowWindow();
			//StatusWnd_LevelTextBox_back.HideWindow();
			//LevelBoxTexPremium_texture.HideWindow();			
			
			//세 자리수 텍스쳐로 변경
		}
		else 
		{
			userName.SetAnchor("StatusWnd", "TopLeft", "TopLeft", 45, 8);
			LevelWindowUnder100.ShowWindow();
			LevelWindowAfter100.HideWindow();

			//Debug( userinfo.nLevel @ "UpdateUserInfo2" );			
		}
		
		/*if (Vitality != m_Vitality)//ldw
		{
			UpdateVp( Vitality );	// 활력 게이지를 업데이트 한다.		
		}*/
		UpdateVp( Vitality );
		//setSizeWindow( GetClassTransferDegree( userinfo.Class ) );
		UpdateUltimateSkillPoint( userinfo.UltimateSkillPoint );
		
		//debug("myUserInfo.Class : " @ GetClassType( userinfo.Class ));
		//debug("현재 전직 상태 :" @ GetClassTransferDegree( userinfo.Class ));
		
		//자신의 자동 파티 매칭 상태
		//if( userinfo.nSubstitute == 0 )
			//AutoPartyMatchingIcon.HideWindow();
		//else 
			//AutoPartyMatchingIcon.ShowWindow();

	}
}

//궁극기 게이지 4차 전직시 보여주기. 삭제 됨
/*
function setSizeWindow( int level )
{
	local int w;
	local int h;

	Me.GetWindowSize( w, h );

	/*
	//지금 안보이도록 해달라는 요청.
	if( level > 3 )//ldw 궁극게이지가 보이려면 0으로 기본 3.....
	{
		Me.SetWindowSize( w, WINDOW_MAX_SIZE_HEIGHT );
		HPBar.SetWindowSizeRel( 1, 0, -24, 13);
		MPBar.SetWindowSizeRel( 1, 0, -24, 13);
		CPBar.SetWindowSizeRel( 1, 0, -24, 13);

		/*HPBar.SetWindowSizeRel( 1, 0.16, -24, 0 );
		MPBar.SetWindowSizeRel( 1, 0.16, -24, 0 );
		CPBar.SetWindowSizeRel( 1, 0.16, -24, 0 );*/

		StatusWndBg.SetWindowSizeRel( 1, 1, -14, -15 );

		FinalityGageWnd.ShowWindow();
	}
	else
	{
*/
		Me.SetWindowSize( w, WINDOW_MIN_SIZE_HEIGHT );
		/*HPBar.SetWindowSizeRel( 1, 0.2, -24, 0 );
		MPBar.SetWindowSizeRel( 1, 0.2, -24, 0 );
		CPBar.SetWindowSizeRel( 1, 0.2, -24, 0 );*/

		HPBar.SetWindowSizeRel( 1, 0, -24, 13);
		MPBar.SetWindowSizeRel( 1, 0, -24, 13);
		CPBar.SetWindowSizeRel( 1, 0, -24, 13);

		StatusWndBg.SetWindowSizeRel( 1, 1, -14, 4 );//ldw

		FinalityGageWnd.HideWindow();
	//}
}*/

//궁극기 게이지 update
function UpdateUltimateSkillPoint( int point )
{
	//set_us_gauge 1000
	local int UltimateSkillLevel;
	local string ani;

	UltimateSkillLevel = GetActivityUltimateSkillLevel();
	nowFinalityLev = UltimateSkillLevel;

	if( preFinalityLev < UltimateSkillLevel )
	{
		ani = "up";
	}
	else if( preFinalityLev > UltimateSkillLevel )
	{
		ani = "down";
	}
	else
	{
		if( UltimateSkillLevel == 0 )
		{
			ani = "zero";
		}
		else
		{
			ani = "none";
		}
	}

	if( UltimateSkillLevel == 0 )
	{
		FinalityBar01.SetValue( 500, point );		
		FinalityBar02.SetValue( 0, 10 );
		FinalityBar03.SetValue( 0, 10 );
	}
	if( UltimateSkillLevel == 1 )
	{
		FinalityBar01.SetValue( 10, 10 );
		FinalityBar02.SetValue( 500, point - ULTIMATE_SKILL_POINT_BOUNDARY_LEVEL1 );
		FinalityBar03.SetValue( 0, 10 );
	}
	else if ( UltimateSkillLevel == 2 )
	{
		FinalityBar01.SetValue( 10, 10 );
		FinalityBar02.SetValue( 10, 10 );
		FinalityBar03.SetValue( 500, point - ULTIMATE_SKILL_POINT_BOUNDARY_LEVEL2 );
	}
	else if ( UltimateSkillLevel == 3 )
	{
		FinalityBar01.SetValue( 10, 10 );
		FinalityBar02.SetValue( 10, 10 );
		FinalityBar03.SetValue( 10, 10 );
		//debug( string( point - ULTIMATE_SKILL_POINT_BOUNDARY_LEVEL3 ) );
	}

	OnOffFinalityGage( ani );
}

function setInitFinalityBar()
{
	local int i;
	
	for( i = 1 ; i <= 3 ; i ++ )
	{
		GetBarHandle( "FinalityBar0"$i).SetValue(0 , 0);
	}
}

function OnOffFinalityGage( string ani )
{
	//set_us_gauge 1000
	local int i;		
	//Debug("ani>>>>>>>"$ ani);

	if( ani == "up" )
	{
		for( i = 1 ; i <= 3 ; i++ )
		{
			if( i > preFinalityLev && i <= nowFinalityLev )
			{
				//값을 채울 바.
				//debug("UP된 Bar 는??i>>>>>>>>>>>> 채울바"$string(i));
				GetTextureHandle ( "StatusWnd.FinalityGageWnd.FinalityGageEff"$i$"_Left").ShowWindow();
				GetTextureHandle ( "StatusWnd.FinalityGageWnd.FinalityGageEff"$i$"_Center").ShowWindow();
				GetTextureHandle ( "StatusWnd.FinalityGageWnd.FinalityGageEff"$i$"_Right").ShowWindow();

				GetTextureHandle ( "StatusWnd.FinalityGageWnd.FinalityGageEff"$i$"_Left").SetAlpha(0);
				GetTextureHandle ( "StatusWnd.FinalityGageWnd.FinalityGageEff"$i$"_Center").SetAlpha(0);
				GetTextureHandle ( "StatusWnd.FinalityGageWnd.FinalityGageEff"$i$"_Right").SetAlpha(0);

				GetTextureHandle ( "StatusWnd.FinalityGageWnd.FinalityGageEff"$i$"_Left").SetAlpha(255, FINALITYSPEEDFLOAT);
				GetTextureHandle ( "StatusWnd.FinalityGageWnd.FinalityGageEff"$i$"_Center").SetAlpha(255, FINALITYSPEEDFLOAT);
				GetTextureHandle ( "StatusWnd.FinalityGageWnd.FinalityGageEff"$i$"_Right").SetAlpha(255, FINALITYSPEEDFLOAT);

				Me.SetTimer( TIMER_BAR, TIMER_BAR_DELAY );
			}
			else if( i > nowFinalityLev )
			{
				//비어 있는 바.
				//debug("UP안 된 Bar 는?????i>>>>>>>>>>>> 빈바."$string(i));
				GetTextureHandle ( "StatusWnd.FinalityGageWnd.FinalityGageEff"$i$"_Left").HideWindow();
				GetTextureHandle ( "StatusWnd.FinalityGageWnd.FinalityGageEff"$i$"_Center").HideWindow();
				GetTextureHandle ( "StatusWnd.FinalityGageWnd.FinalityGageEff"$i$"_Right").HideWindow();
			}
			else
			{
				//이미 차 있는바.
			}
		}
	}
	else if( ani == "down" )
	{
		for( i = 1 ; i <= 3 ; i++ )
		{
			if( i <= preFinalityLev && i > nowFinalityLev )
			{
				//게이지 비울 바
				//debug("Down된 Bar 는??i>>>>>>>>>>>>"$string(i));								
				GetTextureHandle ( "StatusWnd.FinalityGageWnd.FinalityGageEff"$i$"_Left").SetAlpha(0, FINALITYSPEEDFLOAT2);
				GetTextureHandle ( "StatusWnd.FinalityGageWnd.FinalityGageEff"$i$"_Center").SetAlpha(0, FINALITYSPEEDFLOAT2);
				GetTextureHandle ( "StatusWnd.FinalityGageWnd.FinalityGageEff"$i$"_Right").SetAlpha(0, FINALITYSPEEDFLOAT2);
			}
		}
	}
	else if ( ani == "zero" )
	{
		for( i = 1 ; i <= 3 ; i++ )
		{
			GetTextureHandle ( "StatusWnd.FinalityGageWnd.FinalityGageEff"$i$"_Left").SetAlpha(0);
			GetTextureHandle ( "StatusWnd.FinalityGageWnd.FinalityGageEff"$i$"_Center").SetAlpha(0);
			GetTextureHandle ( "StatusWnd.FinalityGageWnd.FinalityGageEff"$i$"_Right").SetAlpha(0);
		}
	}

	preFinalityLev = nowFinalityLev;
}


/*
function int getCurrVitalityHou(int Vitality){//ldw 활력 남은 시간 계산.
	return (Vitality/VitalityPer20)%20;
}

function int getCurrVitalityMin(int Vitality){//ldw 활력 남은 분 계산.	
	return (Vitality / 60) % 60;	
}

function int getCurrVitalitySec(int Vitality){//ldw 활력 남은 초 계산.	
	return Vitality % 60;	
}*/


//branch
// F2P 서비스 활력 개선 - gorillazin
function UpdateVp (int Vitality )//ldw 수정
{
	//local int now_vp_lv;
	//local int pre_vp_lv;
	//local int curVitalityHou;
	//local int curVitalityMin;
	//local int curVitalitySec;	

	//local CustomTooltip T;//bluesun 커스터마이즈 툴팁 
	//local string tmpStr;	

	if(Vitality < 1807 && Vitality > 0){
		VpDetailBar.SetPoint(1807, MaxVitality);
	} else {
		VpDetailBar.SetPoint(Vitality, MaxVitality);
	}

	//util = L2Util(GetScript("L2Util"));//bluesun 커스터마이즈 툴팁 
	//util.setCustomTooltip(T);//bluesun 커스터마이즈 툴팁	
	//util.ToopTipInsertText(GetSystemString(2494), true, false );//bluesun 커스터마이즈 툴팁 	
	//활력이 0일 경우, 활력이 20일 경우 그 외 경우로 나눠 짐.
	//if (Vitality <= 0){//활력 0일 경우
	//	tmpStr = GetSystemString(2496);		
	//	util.ToopTipInsertText(tmpStr, true, false, util.ETooltipTextType.COLOR_GRAY );
	//} else {		
	//	tmpStr = GetSystemString(2495);
	//	util.ToopTipInsertText(tmpStr, true, false);
		/*util.ToopTipInsertText( tmpStr, true, true );//bluesun 커스터마이즈 툴팁
		if( Vitality >= MaxVitality){//활력 20일 경우
			VpDetailBar.SetPoint(MaxVitalityTime, MaxVitalityTime);
			tmpStr = MakeFullSystemMsg( GetSystemMessage(3406), string(MaxVitalityTime));//20시간
		} else {//기타			
			curVitalityHou = getCurrVitalityHou(Vitality);//시
			curVitalityMin = getCurrVitalityMin(Vitality);//분
			//curVitalitySec = getCurrVitalitySec(Vitality);//초
			VpDetailBar.SetPoint(curVitalityHou+1, MaxVitalityTime);
			if( Vitality < 60 ){				
				tmpStr = MakeFullSystemMsg( GetSystemMessage(3390), String(1));//0분 초과 60분 이하 => 1분
				tmpStr = MakeFullSystemMsg( GetSystemMessage(3408), tmpStr);//0분 초과 60분 이하 => 1분 미만
			}
			else if( Vitality < VitalityPer20 )
				tmpStr = MakeFullSystemMsg( GetSystemMessage(3390), String(curVitalityMin));//0분 초과 60분 이하 => 분
			else if ( Vitality < VitalityPer20)
				tmpStr = MakeFullSystemMsg( GetSystemMessage(3390), String(curVitalityMin));//0분 초과 60분 이하 => 분
			else if ( curVitalityMin ==0)//분이 0일 경우 
				tmpStr = MakeFullSystemMsg( GetSystemMessage(3406), string(curVitalityHou));//분이 0일 경우 => 시간만 표시
			else 
				tmpStr = MakeFullSystemMsg( GetSystemMessage(3304), String(curVitalityHou), String(curVitalityMin));//남은 시간 한시간 이상일 경우 분이 0이 아닐 경우 => 시 분 표시	
		}			
		tmpStr = MakeFullSystemMsg( GetSystemMessage(3360), tmpStr);//"남음." 붙임
	*/
	//}
	//VpDetailBar.SetTooltipCustomType(util.getCustomTooltip());//bluesun 커스터마이즈 툴팁VpDetailBar.SetPoint(MaxVitalityTime, MaxVitalityTime);	

	
	// 기존 값과 비교하여 VP 단계의 변화가 있을 경우 애니메이션을 플레이해준다. 
	//now_vp_lv = LevelOfVitality(Vitality);
	//pre_vp_lv = LevelOfVitality(m_Vitality);
	
	//m_Vitality = Vitality;
	
	/*
	if(Vitality > 20000)
	{
		//debug("ERROR!! - Vitality can not be over 20000");
		VitalityTex.SetTexture("l2ui_ct1.LifeForce.Icon_df_LifeForce_StatusWnd_01");
		//Statustooltipwnd.SetTooltipCustomType(MakeTooltipSimpleText(MakeFullSystemMsg(GetSystemMessage(2329),"0",MakeFullSystemMsg(GetSystemMessage(2330),"0",""))));
		VpDetailBar.SetValue(0 , 0);
	}
	else if(Vitality >= 17000) 	//활력 4단계. 경험치 보너스 300%. 사이값 3000
	{
		VitalityTex.SetTexture("l2ui_ct1.LifeForce.Icon_df_LifeForce_StatusWnd_05");
		//Statustooltipwnd.SetTooltipCustomType(MakeTooltipSimpleText(MakeFullSystemMsg(GetSystemMessage(2329),"4",MakeFullSystemMsg(GetSystemMessage(2330),"300%",""))));
		VpDetailBar.SetValue(3000 ,Vitality - 17000); 
	}
	else if(Vitality >=13000)	// 활력 3단계. 경험치 보너스 250%. 사이값 4000
	{
		VitalityTex.SetTexture("l2ui_ct1.LifeForce.Icon_df_LifeForce_StatusWnd_04");
		//Statustooltipwnd.SetTooltipCustomType(MakeTooltipSimpleText(MakeFullSystemMsg(GetSystemMessage(2329),"3",MakeFullSystemMsg(GetSystemMessage(2330),"250%",""))));
		VpDetailBar.SetValue(4000 ,Vitality - 13000 ); 
	}
	else if(Vitality >= 2000)		//활력 2단계. 경험치 보너스 200%. 사이값 11000 
	{
		VitalityTex.SetTexture("l2ui_ct1.LifeForce.Icon_df_LifeForce_StatusWnd_03");
		//Statustooltipwnd.SetTooltipCustomType(MakeTooltipSimpleText(MakeFullSystemMsg(GetSystemMessage(2329),"2",MakeFullSystemMsg(GetSystemMessage(2330),"200%",""))));
		VpDetailBar.SetValue(11000 , Vitality - 2000 ); 
	}
	else if(Vitality >= 240)		//활력 1단계. 경험치 보너스 150%. 사이값 1760
	{
		VitalityTex.SetTexture("l2ui_ct1.LifeForce.Icon_df_LifeForce_StatusWnd_02");
		//Statustooltipwnd.SetTooltipCustomType(MakeTooltipSimpleText(MakeFullSystemMsg(GetSystemMessage(2329),"1",MakeFullSystemMsg(GetSystemMessage(2330),"150%",""))));
		VpDetailBar.SetValue(1760 , Vitality - 240); 
	}
	else	// 활력 0단계. 경험치 보너스 없음. 사이값 240.
	{
		VitalityTex.SetTexture("l2ui_ct1.LifeForce.Icon_df_LifeForce_StatusWnd_01");
		//Statustooltipwnd.SetTooltipCustomType(MakeTooltipSimpleText(MakeFullSystemMsg(GetSystemMessage(2329),"0",MakeFullSystemMsg(GetSystemMessage(2330),"0",""))));
		VpDetailBar.SetValue(240 , Vitality);
	}*/
	
	//if(now_vp_lv != pre_vp_lv)	PlayAnimation();	// 레벨이 변경되었을 경우에는 반짝반짝 애니메이션을 틀어준다. 


	//if (! isVPApplyChecked ) {
	//	checkVP(Vitality);
	//	isVPApplyChecked = true;
	//} else if (isVPApply){
	//		if ( Vitality  == 0 ){	
	//			//AddSystemMessageString("활력이 적용되지 않았습니다." @ Vitality);
	//			AddSystemMessage(3526); //활력이 적용되지 않았습니다.
	//			isVPApply = false;
	//		}
	//} else if ( Vitality > 0 ) {		
	//	//AddSystemMessageString("활력이 적용 되었습니다." @ Vitality);		
	//	AddSystemMessage(3525); //활력이 적용 되었습니다.
	//	isVPApply = true;
	//}
}
// 이 function 의 필요 없는 부분 주석 처리 - gorillazin
//end of branch

//branch
// F2P 서비스 활력 개선 - gorillazin
//function checkVP(int Vitality){ //활력 체크 isVPApplyChecked가 false일 경우 만 체크, 첫 로딩때만 보여짐
//	if ( Vitality  > 0 ){
//		AddSystemMessage(3525);				
//		isVPApply = true;
//	} else {
//		AddSystemMessage(3526);		
//		isVPApply = false;
//	} 
//}
// 이 function이 오히려 헷갈려 삭제 - gorillazin
//end of branch


//들어오는 활력 값에 따라 활력 레벨을 리턴해준다. 
/*function int LevelOfVitality ( int Vitality)//ldw 주석 처리
{
	if(Vitality > 20000)		return 0;			
	else if(Vitality >= 17000) 	return 4;	//활력 4단계. 경험치 보너스 300%. 
	else if(Vitality >= 13000)	return 3;	//활력 3단계. 경험치 보너스 250%.
	else if(Vitality >= 2000)		return 2;	//활력 2단계. 경험치 보너스 200%.
	else if(Vitality >= 240)		return 1;	//활력 1단계. 경험치 보너스 150%.
	else					return 0;	//활력 0단계. 경험치 보너스 없음.
}*/

//창 클릭했을때 타겟되기
function OnLButtonDown(WindowHandle a_WindowHandle, int X,int Y)
{
	local Rect rectWnd;
	
	switch (a_WindowHandle)
	{
		case CPBar:
		case HPBar:
		case MPBar:
		//case EXPBar: //ldw 주석
		case UserName:
		case StatusWnd_LevelTextBox:
		case VpDetailBar:
		//case VitalityTex:
		//case LifeForceAnimTex_Left: //ldw 주석
		//case LifeForceAnimTex_Center: //ldw 주석
		//case LifeForceAnimTex_Right: //ldw 주석
		//case Statustooltipwnd://20130611 xml 에서 삭제 
		case texNavitGaugeLeft :
		case texNavitGaugeMid :
		case texNavitGaugeRight :
			rectWnd = a_WindowHandle.GetRect();
			if (X > rectWnd.nX && X < rectWnd.nX + rectWnd.nWidth)
			{
				RequestSelfTarget();
			}
		break;
		case Me:
			rectWnd = Me.GetRect();
			if (X > rectWnd.nX + 13 && X < rectWnd.nX + rectWnd.nWidth -10)
			{
				RequestSelfTarget();
			}
		break;
	}
}

function OnEvent( int a_EventID, string a_Param )
{
	switch( a_EventID )
	{
	case EV_GamingStateExit:
		InitAnimation();
		//m_Vitality = 6; //ldw 주석 처리
		break;
	case EV_UpdateUserInfo:
		UpdateUserInfo();
		break;
	case EV_UpdateMyHP:
		HandleUpdateGauge(a_Param,0);
		break;
	case EV_UpdateMyMaxHP:
		HandleUpdateGauge(a_Param,0);
		break;
	case EV_UpdateMyMP:
		HandleUpdateGauge(a_Param,1);
		break;
	case EV_UpdateMyMaxMP:
		HandleUpdateGauge(a_Param,1);
		break;
	case EV_UpdateMyCP:
		HandleUpdateGauge(a_Param,2);
		break;
	case EV_UpdateMyMaxCP:
		HandleUpdateGauge(a_Param,2);
		break;
	case EV_RegenStatus:
		HandleRegenStatus(a_Param);
		break;
	/*case EV_VitalityPointInfo:
		Debug("VitalityPointInfo");//ldw
		HandleVitalityPointInfo( a_Param);//ldw
		break;*/
	case EV_NavitAdventEffect:
		//HandleNavitAdventEffect(a_Param);
		break;
	//궁극기 스킬 포인트 업데이트.
	case EV_UpdateUltimateSkillPoint:
		HandleUpdateUltimateSkillPoint(a_Param);
		break;
	//branch
	// F2P 서비스 활력 개선 - gorillazin
	case EV_VitalityEffectInfo:		
		if ( !getInstanceUIData().getIsClassicServer() ) 
			HandleVitalityEffectInfo(a_Param);		
		break;
	//end of branch
	//branch
	case EV_BR_PREMIUM_STATE:
		HandlePremiumState(a_Param);
		break;
	//end of branch
	case EV_NeedResetUIData :
		checkClassicForm();
		break;

	case EV_AbnormalStatusNormalItem :
		if ( !getInstanceUIData().getIsClassicServer() ) 
		{
			if ( !isAfterStatusNormaEvent ) 
			{
				isAfterStatusNormaEvent = true;
				showSystemMsg();
			}
		}
		break;
	default:
		break;
	}
}

function checkClassicForm() 
{
	local int w;
	local int h;

	Me.GetWindowSize( w, h );

	if ( getInstanceUIData().getisClassicServer() || getInstanceUIData().getisArenaServer() )
	{		
		VpDetailBar.HideWindow();
		Me.SetWindowSize( w  , WINDOW_CLASSIC_SIZE_HEIGHT ); 
		
	}
	else 
	{					
		VpDetailBar.ShowWindow();
		Me.SetWindowSize( w  , WINDOW_MIN_SIZE_HEIGHT );
	}
	StatusWndBg.SetWindowSizeRel( 1, 1, -14, 4 );
}

// 네비트의 강림 - 2010.7.8 winkey
function HandleNavitAdventEffect( String a_Param )
{
	ParseInt( a_Param, "RemainSeconds", m_NavitEffectRemainSec );
	
	if( m_NavitEffectRemainSec > 0 )
	{
		// play animation	
		m_NavitGradeEffectFactor = 0;
		Me.KillTimer( NAVIT_TIMER_ID2 );
		Me.SetTimer( NAVIT_TIMER_ID2, NAVIT_TIMER_DELAY2 );

		texNavitGaugeLeft.ShowWindow();
		texNavitGaugeMid.ShowWindow();
		texNavitGaugeRight.ShowWindow();
		texNavitGaugeLeft.SetAlpha( 0 );
		texNavitGaugeMid.SetAlpha( 0 );
		texNavitGaugeRight.SetAlpha( 0 );
	}
	else
	{
		Me.KillTimer( NAVIT_TIMER_ID2 );
		texNavitGaugeLeft.HideWindow();
		texNavitGaugeMid.HideWindow();
		texNavitGaugeRight.HideWindow();
	}
}

function OnTimerNavit()
{
	if( m_NavitGradeEffectFactor % 2 == 0 )
	{
		texNavitGaugeLeft.SetAlpha( ANIMMINALPHA, ANIMSPEEDFLOAT );
		texNavitGaugeMid.SetAlpha( ANIMMINALPHA, ANIMSPEEDFLOAT );
		texNavitGaugeRight.SetAlpha( ANIMMINALPHA, ANIMSPEEDFLOAT );
	}
	else
	{
		texNavitGaugeLeft.SetAlpha( ANIMMAXALPHA, ANIMSPEEDFLOAT );	
		texNavitGaugeMid.SetAlpha( ANIMMAXALPHA, ANIMSPEEDFLOAT );	
		texNavitGaugeRight.SetAlpha( ANIMMAXALPHA, ANIMSPEEDFLOAT );	
	}
	m_NavitGradeEffectFactor = m_NavitGradeEffectFactor + 1;
}

// 활력 수치만 업데이트
function HandleVitalityPointInfo( string param )
{
	local int nVitality;
	
	ParseInt( param, "Vitality", nVitality );
	
	UpdateVp( nVitality );	// 활력 게이지를 업데이트 한다.
}

//게이지만 업데이트
function HandleUpdateGauge(string param, int Type)
{
	local int ServerID;
	
	if( !m_bReceivedUserInfo )
	{
		m_bReceivedUserInfo = true;
		UpdateUserInfo();
	}
	else
	{
		ParseInt( param, "ServerID", ServerID );
		if( m_UserID == ServerID )
			UpdateUserGauge( Type );
	}
}

//전체정보 업데이트
function HandleUpdateInfo(string param)
{
	local int ServerID;
	ParseInt( param, "ServerID", ServerID );
	
	//아직 User에 대한 정보를 받지못했다면, 무조건 Update를 실시한다.
	if (m_UserID == ServerID || !m_bReceivedUserInfo)
	{
		m_bReceivedUserInfo = true;
		UpdateUserInfo();
	}
}

function HandleRegenStatus( String a_Param )
{
	local int type;
	local int duration;
	local int ticks;
	local float amount;

	ParseInt( a_Param, "Type", type );

	//type이 1일 경우 : HP 리젠상태를 보여줌 =>현재 1만 서버에서 보내줌
	if( type==1 )
	{
		ParseInt( a_Param, "Duration", duration );
		ParseInt( a_Param, "Ticks", ticks );
		ParseFloat( a_Param, "Amount", amount );
		HPBar.SetRegenInfo(duration,ticks,amount);
	}
}

function HandleUpdateUltimateSkillPoint( string param )
{
	local int ServerID;
	local int CurrentUltimateSkillPoint;

	ParseInt( param, "ServerID", ServerID );
	ParseInt( param, "CurrentUltimateSkillPoint", CurrentUltimateSkillPoint );

	//Debug(">>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<");/ldw 주석

	UpdateUltimateSkillPoint( CurrentUltimateSkillPoint );
}

//branch
function PlayAnimationPrem()
{
	Me.KillTimer( TIMER_PREM1 );
	Me.KillTimer( TIMER_PREM2 );	
	AnimTexKillPremium = false;
	Me.SetTimer(TIMER_PREM1,TIMER_PREM_DELAY1);
	Me.SetTimer(TIMER_PREM2,TIMER_PREM_DELAY2);
	m_AlphaIncrese = true;
}
//end of branch


//branch
function HandlePremiumState( String a_Param )
{
	local int premiumstate;
	ParseInt( a_Param, "PREMIUMSTATE", premiumstate );
	
	if (m_CurPremiumState == premiumstate)
		return;
		
	m_CurPremiumState = premiumstate;
	
	if (m_CurPremiumState == 1) 
	{		
		LevelBoxTexPremium.ShowWindow();
		LevelBoxTexPremium100.ShowWindow();
		PlayAnimationPrem();
	}
	else 
	{		
		LevelBoxTexPremium.HideWindow();
		LevelBoxTexPremium100.HideWindow();
		InitAnimation();
	}
}
//end of branch

//branch
// F2P 서비스 활력 개선 - gorillazin
function HandleVitalityEffectInfo(string param)
{	
	local CustomTooltip T;
	local string tmpStr;
	local int nVitality, nVitalityItemRestoreCount;	
	
	local string sSysMsgParamString;
	//local string sMessage;

	local string sBonusString;
	local string sExtraBonusString;

	ParseInt(param, "vitalityPoint", nVitality);
	ParseInt(param, "vitalityBonus", nVitalityBonus);
	ParseInt(param, "restoreCount", nVitalityItemRestoreCount);
	ParseInt(param, "maxRestoreCount", nVitalityItemMaxRestoreCount);

	// 활력 추가 보너스 표시 2015.05
	ParseInt(param, "vitalityExtraBonus", nVitalityExtraBonus);
	
	//Debug ( "" @ nVitalityExtraBonus  @ isVPApplyChecked);

	sBonusString = nVitalityBonus $ "%";
	if ( nVitalityExtraBonus > 0 ) 
	{
		sExtraBonusString = "(+" $ nVitalityExtraBonus $ "%)";
	}	

	util = L2Util(GetScript("L2Util"));
	util.setCustomTooltip(T);

	// 활력 보너스:
	util.ToopTipInsertText( GetSystemString(2494), true, false );
	
	// 활력이 0 인 경우 미적용 표시
	if (nVitality <= 0)
	{		
		util.ToopTipInsertText(GetSystemString(2496), true, false, util.ETooltipTextType.COLOR_GRAY);
		util.ToopTipInsertText(", ", true, false);		
	}
	// 활력 0 이상인 경우 
	else
	{
		util.ToopTipInsertText(sBonusString, true, false);	
		//util.ToopTipInsertText(sExtraBonusString, true, false, util.ETooltipTextType.COLOR_GREEN);
		util.ToopTipInsertText(sExtraBonusString, true, false, util.ETooltipTextType.COLOR_YELLOW03);		
		util.ToopTipInsertText(" " $ GetSystemString(2495) $ ". " , true, false);
	}
	
	// 사용 할 수 있는 아이템 개수 
	sSysMsgParamString = "";
	tmpStr = "";		
	ParamAdd(sSysMsgParamString, "Type", string(int(ESystemMsgParamType.SMPT_NUMBER)));
	ParamAdd(sSysMsgParamString, "param1", string(nVitalityItemRestoreCount));
	AddSystemMessageParam(sSysMsgParamString);
	tmpStr = EndSystemMessageParam(6073, true);

	util.ToopTipInsertText(tmpStr, true, false);

	VpDetailBar.SetTooltipCustomType(util.getCustomTooltip());

	sSysMsgParamString = "";	

	// 활력 적용, 미적용이 변경 되는 경우에 시스템 메시지 출력 	
	if ( (isVPApply && nVitality == 0 ) || ( !isVPApply && nVitality  > 0 ) ) showSystemMsg();	
}

// 맨 처음 게임에 들어갔을 때 활력 관련 메시지를 출력 함.
// 활력 적용, 미적용이 변경 되는 경우에 시스템 메시지 출력 
function showSystemMsg() 
{
	local string sBonusString;
	local string sExtraBonusString;

	local string sSysMsgParamString ;
	local UserInfo userinfo; 
	local int nVitality ; 
	local string sMessage;

	if( !GetPlayerInfo( userinfo ) ) return;		
	
	nVitality = userinfo.nVitality ;

	sBonusString = nVitalityBonus $ "%";
	if ( nVitalityExtraBonus > 0 ) 
	{
		sExtraBonusString = "(+" $ nVitalityExtraBonus $ "%)";
	}	
	
	// 추가 보너스 정상 표시를 위해
	// 버프를 다 받고 나면, 활력 관련 메시지를 출력 할 수 있도록 함.
	if ( isAfterStatusNormaEvent )
	{
		isVPApply = nVitality > 0;
		
		// 활력 포인트가 0보다 큰 경우 적용 상태
		if ( isVPApply )
		{		
			//AddSystemMessage(3525);
			ParamAdd(sSysMsgParamString, "Type", string(int(ESystemMsgParamType.SMPT_STRING)));
			ParamAdd(sSysMsgParamString, "param1", sBonusString$sExtraBonusString );
			AddSystemMessageParam(sSysMsgParamString);
			sSysMsgParamString="";
			ParamAdd(sSysMsgParamString, "Type", string(int(ESystemMsgParamType.SMPT_NUMBER)));
			ParamAdd(sSysMsgParamString, "param1", string(nVitalityItemMaxRestoreCount));
			AddSystemMessageParam(sSysMsgParamString);
			sMessage = EndSystemMessageParam(6067, true);
			AddSystemMessageString(sMessage);
			isVPApply = true;
		}
		// 미적용 상태
		else 
		{
			//AddSystemMessage(3526);
			ParamAdd(sSysMsgParamString, "Type", string(int(ESystemMsgParamType.SMPT_NUMBER)));
			ParamAdd(sSysMsgParamString, "param1", string(nVitalityItemMaxRestoreCount));
			AddSystemMessageParam(sSysMsgParamString);
			sMessage = EndSystemMessageParam(6068, true);
			AddSystemMessageString(sMessage);
			isVPApply = false;
		}
	}
}



//
//end of branch
// 마우스 오른쪽 버튼 클릭
function OnRButtonDown( WindowHandle a_WindowHandle, int X, int Y )
{
	local Rect      rectWnd;
	local int		TargetID;	
	local string    userName;
	local UserInfo  targetUserInfo;

	rectWnd = Me.GetRect();
	
	//타겟ID 얻어오기
	TargetID = m_UserID;

	if (TargetID > 0)
	{		
		if (X > rectWnd.nX && X < rectWnd.nX + rectWnd.nWidth) 
		{
			if (Y > rectWnd.nY && Y < rectWnd.nY + rectWnd.nHeight) 
			{
				// 컨텍스트 메뉴 구성을 위한 정보 save
				userName = class'UIDATA_USER'.static.GetUserName(TargetID);

				if (userName != "")	
				{
					if (GetTargetInfo(targetUserInfo))
					{
						// empty
					}

					if (targetUserInfo.nID != TargetID) setTargetByServerID(TargetID);

					getInstanceContextMenu().execContextEvent(userName, TargetID, X, Y);				
				}
			}
		}
	}
}

defaultproperties
{
}
