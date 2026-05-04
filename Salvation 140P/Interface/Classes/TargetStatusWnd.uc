class TargetStatusWnd extends UICommonAPI;
	
const TimerValue1 = 1351;
const TimerValue2 = 6346;
const TimerValue3 = 4858;
const TimerValue4 = 7337;
const TimerValue5 = 3474;
const TimerValue6 = 5269;
const TimerValue7 = 5270; // 슬롯 1번의 스킬 완료시.
const TimerValue8 = 5271; // 슬롯 2번의 스킬 완료시.
const TimerValue9 = 5272; // 캔슬 완료시.

const CONTRACT_HEIGHT = 46;
const EXPAND_HEIGHT = 76;


var bool m_bExpand;

var int	m_TargetLevel;
var int	m_TargetID;
var bool m_rotated;
var bool m_bShow;
var string g_NameStr;

var vector targetLoc;	//타겟의 위치벡터

var WindowHandle Me1;
var WindowHandle Me2;
var WindowHandle Me;
var BarHandle barMP;
var BarHandle barHP;
var TextBoxHandle txtPledgeAllianceName;
var TextureHandle texPledgeAllianceCrest;
var TextBoxHandle txtAlliance;
var TextBoxHandle txtPledgeName;
var TextureHandle texPledgeCrest;
var TextBoxHandle txtPledge;
var NameCtrlHandle RankName;
var NameCtrlHandle UserName;
var ButtonHandle btnClose;
//~ var WindowHandle BackTex;
//~ var TextureHandle BackTex3;
//~ var TextureHandle BackTex2;
//~ var TextureHandle BackTex1;
//~ var WindowHandle BackExpTex;
//~ var TextureHandle BackExpTex3;
//~ var TextureHandle BackExpTex2;
//~ var TextureHandle BackExpTex1;
var TreeHandle NpcInfo;
//~ var ButtonHandle btnRotate1;
//~ var ButtonHandle btnRotate2;
//~ var ButtonHandle btnContext1;
//~ var ButtonHandle btnContext2;
//~ var ButtonHandle btnContext3;
//~ var ButtonHandle btnContext4;
//~ var ButtonHandle btnContext5;
//~ var ButtonHandle btnContext6;
//~ var ButtonHandle btnContext7;
//~ var NameCtrlHandle NameTxt;

var ButtonHandle btnExpand;
var ButtonHandle btnContract;


//선준
//TargetBuff 창
var WindowHandle TargetStatusBuff1Wnd;
var WindowHandle TargetStatusBuff2Wnd;

var WindowHandle BuffWnd;

//추가 버프에 대한 버튼
var ButtonHandle btnBuffMoreView1;
var ButtonHandle btnBuffMoreView2;

//추가 디버프의 y좌표 값
var int yPosView2;

//버프 보여 줄 StatusIconHandle
var StatusIconHandle	StatusIcons;

//각 버프 정보를 넣을 배열
var array<StatusIconInfo> arrMyBuff;
var array<StatusIconInfo> arrOtherBuff;
var array<StatusIconInfo> arrMyDebuff;
var array<StatusIconInfo> arrOtherDebuff;

//버프 라인수 카운트
var int lineCount;

var string strSelectTarget;

var ProgressCtrlHandle barSkillProgress1;
var NameCtrlHandle skillProgressName1;

var TextureHandle barSkillProgressEff1_Left;
var TextureHandle barSkillProgressEff1_Center;
var TextureHandle barSkillProgressEff1_Right;

var ProgressCtrlHandle barSkillProgress2;
var NameCtrlHandle skillProgressName2;

var TextureHandle barSkillProgressEff2_Left;
var TextureHandle barSkillProgressEff2_Center;
var TextureHandle barSkillProgressEff2_Right;
var TextureHandle texMark;

const BUFF_SIZE_BIG = 24;
const BUFF_SIZE_SMALL = 16;

var bool bIsShowBackup;
var int  m_TargetIDBackup;

var string m_WindowName;

function OnRegisterEvent()
{
	RegisterEvent( EV_TargetUpdate );
	RegisterEvent( EV_TargetHideWindow );
	
	RegisterEvent( EV_UpdateHP );
	RegisterEvent( EV_UpdateMP );
	RegisterEvent( EV_UpdateMaxHP );
	RegisterEvent( EV_UpdateMaxMP );
	
	RegisterEvent( EV_UpdateMyHP );
	RegisterEvent( EV_UpdateMyMP );
	RegisterEvent( EV_UpdateMyMaxHP );
	RegisterEvent( EV_UpdateMyMaxMP );

	RegisterEvent( EV_ReceiveTargetLevelDiff );

	//RegisterEvent( EV_AbnormalStatusNormalItem );
	//선준(타켓의 버프 정보를 보내주는 Event)
	RegisterEvent( EV_TargetSpelledList );
	//타겟의 스킬 시전 정보 보내주는 Event
	RegisterEvent( EV_TargetSkillInfo );
	//타겟의 스킬 시전 취소 정보 보내주는 Event
	RegisterEvent( EV_TargetSkillCancel );
	
	// 타겟이 잡힌 상태에서 
	RegisterEvent( EV_GamingStateExit );

	// 게임상태가 변경되면 Show 처리하기위해 추가 
	RegisterEvent( EV_GamingStateEnter );
	RegisterEvent( EV_GamingStatePreExit );

	RegisterEvent( EV_Restart );

		// RequestTargetCancel()
}

function OnLoad()
{
	local bool nOption;

	SetClosingOnESC();
	
	
	InitializeCOD();

	OnShowProcess();
	Load();

	//옵션 처음 셋팅.
	nOption = GetOptionBool( "ScreenInfo", "SkillCastingBox" );	
	//SkillCastingBoxShow( nOption );

	nOption = GetOptionBool( "ScreenInfo", "StrangeStateBox" );
	StateBoxShow( nOption );
}

function InitializeCOD()
{
	Me = GetWindowHandle( m_WindowName );
	barMP =GetBarHandle( m_WindowName $ ".barMP" );
	barHP = GetBarHandle( m_WindowName $ ".barHP" );
	txtPledgeAllianceName = GetTextBoxHandle ( m_WindowName $ ".txtPledgeAllianceName" );
	texPledgeAllianceCrest = GetTextureHandle ( m_WindowName $ ".texPledgeAllianceCrest" );
	txtAlliance = GetTextBoxHandle ( m_WindowName $ ".txtAlliance" );
	txtPledgeName = GetTextBoxHandle ( m_WindowName $ ".txtPledgeName" );
	texPledgeCrest = GetTextureHandle ( m_WindowName $ ".texPledgeCrest" );
	txtPledge = GetTextBoxHandle ( m_WindowName $ ".txtPledge" );
	RankName = GetNameCtrlHandle ( m_WindowName $ ".RankName"  );
	UserName = GetNameCtrlHandle ( m_WindowName $ ".UserName"  );
	btnClose = GetButtonHandle ( m_WindowName $ ".btnClose" );

	NpcInfo = GetTreeHandle ( m_WindowName $ ".NpcInfo" );
	Me1 = GetWindowHandle( m_WindowName );
	
	btnExpand = GetButtonHandle ( m_WindowName $ ".btnExpand" );
	btnContract= GetButtonHandle ( m_WindowName $ ".btnContract" );

	//선준
	BuffWnd = GetWindowHandle( m_WindowName $ ".BuffWnd" );
	TargetStatusBuff1Wnd = GetWindowHandle( "TargetStatusBuff1Wnd" );
	TargetStatusBuff2Wnd = GetWindowHandle( "TargetStatusBuff2Wnd" );
	StatusIcons = GetStatusIconHandle( m_WindowName $ ".BuffWnd.StatusIcons" );
	btnBuffMoreView1 = GetButtonHandle(m_WindowName $ ".BuffWnd.btnBuffMoreView1");
	btnBuffMoreView2 = GetButtonHandle(m_WindowName $ ".BuffWnd.btnBuffMoreView2");

	barSkillProgress1 = GetProgressCtrlHandle( m_WindowName $ ".SkillProgressWnd1.barSkillProgress1" );
	skillProgressName1 = GetNameCtrlHandle( m_WindowName $ ".SkillProgressWnd1.SkillProgressName1" );

	barSkillProgressEff1_Left = GetTextureHandle ( m_WindowName $ ".SkillProgressWnd1.barSkillProgressEff1_Left" );
	barSkillProgressEff1_Center = GetTextureHandle ( m_WindowName $ ".SkillProgressWnd1.barSkillProgressEff1_Center" );
	barSkillProgressEff1_Right = GetTextureHandle ( m_WindowName $ ".SkillProgressWnd1.barSkillProgressEff1_Right" );

	barSkillProgress2 = GetProgressCtrlHandle( m_WindowName $ ".SkillProgressWnd2.barSkillProgress2" );
	skillProgressName2 = GetNameCtrlHandle( m_WindowName $ ".SkillProgressWnd2.SkillProgressName2" );

	barSkillProgressEff2_Left = GetTextureHandle ( m_WindowName $ ".SkillProgressWnd2.barSkillProgressEff2_Left" );
	barSkillProgressEff2_Center = GetTextureHandle ( m_WindowName $ ".SkillProgressWnd2.barSkillProgressEff2_Center" );
	barSkillProgressEff2_Right = GetTextureHandle ( m_WindowName $ ".SkillProgressWnd2.barSkillProgressEff2_Right" );

	texMark = GetTextureHandle ( m_WindowName $ ".texMark" );
}

function Load()
{	
	SetExpandMode(false, false);
	
	g_NameStr = "";
	m_bShow = false;
	m_TargetID = -1;
	m_rotated = false;
	
	skillBarVisible( false, 1 );
	showBuffMoreBtn( false, 1 );
	skillBarVisible( false, 2 );
	showBuffMoreBtn( false, 2 );

	yPosView2 = 0;

	strSelectTarget = "Friendly";
}


function OnShowProcess()
{
}

function OnRotate1()
{
	//~ debug ("Rotate1");
	Me2.SetAlpha(0);
	Me2.ShowWindow();
	Me.SetTimer(TimerValue1, 150);
//	Me2.Rotate(False, 1500);
//	Me1.Rotate(False, 1500);
	//~ btnRotate1.DisableWindow();
	//~ btnRotate2.DisableWindow();
}      

function OnRotate2()
{
	//~ debug ("Rotate2");
	Me1.SetAlpha(0);
	Me1.ShowWindow();
	Me.SetTimer( TimerValue2, 150);
//	Me2.Rotate(False, 1500);
//	Me1.Rotate(False, 1500);
	//~ btnRotate1.DisableWindow();
	//~ btnRotate2.DisableWindow();
}

function OnRotateClose()
{
	//~ 
	if ( GetGameStateName() != "SPECIALCAMERASTATE" )
	{
		Me1.SetAlpha(0);
		Me1.ShowWindow();
		Me.SetTimer(TimerValue5, 150);
	}
//	Me2.Rotate(False, 1500);
//	Me1.Rotate(False, 1500);
	//~ btnRotate1.DisableWindow();
	//~ btnRotate2.DisableWindow();
}


function OnRotateReset()
{
	Me1.ShowWindow();
	Me2.HideWindow();
//	Me2.Rotate(False, 9999);
//	Me1.Rotate(False, 9999);
	Me1.SetAlpha(255);
	Me2.SetAlpha(0);
	m_rotated = false;
	HandleTargetUpdate();

}


function OnTimer(int TimerID)
{	
	if (TimerID==TimerValue1)	
	{	
		Me.KillTimer(TimerValue1);
		Me2.SetAlpha(255, 0.4f);
		Me1.SetAlpha(0);
		Me.SetTimer( TimerValue3,300);
	} 	
	if(TimerID==TimerValue3)	
	{	
		Me.KillTimer( TimerValue3);
		Me1.HideWindow();
		m_rotated = true;
		//~ btnRotate1.EnableWindow();
		//~ btnRotate2.EnableWindow();
	}	
	if (TimerID==TimerValue2)	
	{	
		Me.KillTimer( TimerValue2);
		Me1.SetAlpha(255, 0.4f);
		Me2.SetAlpha(0,);
		Me.SetTimer(TimerValue4,300);
	} 	
	if(TimerID==TimerValue4)	
	{	
		Me.KillTimer( TimerValue4);
		Me2.HideWindow();
		m_rotated = false;
		//~ btnRotate1.EnableWindow();
		//~ btnRotate2.EnableWindow();
	}	
	if (TimerID==TimerValue5)	
	{	
		Me.KillTimer( TimerValue5);
		Me1.SetAlpha(255, 0.4f);
		Me2.SetAlpha(0,);
		Me.SetTimer( TimerValue6,300);
	} 	
	if(TimerID==TimerValue6)	
	{	
		Me.KillTimer( TimerValue6);
		Me2.HideWindow();
		Me1.HideWindow();
		m_rotated = false;
		//~ btnRotate1.EnableWindow();
		//~ btnRotate2.EnableWindow();
	}

	if(TimerID==TimerValue7)	
	{			
		Me.KillTimer( TimerValue7 );
		skillBarVisible(false, 1);
	}
	if(TimerID==TimerValue8)
	{
		Me.KillTimer( TimerValue8 );
		skillBarVisible(false, 2);
	}
	if(TimerID==TimerValue9)
	{		
		Me.KillTimer( TimerValue9 );
		skillBarVisible(false, 1);
		skillBarVisible(false, 2);
	}	
}


function OnShow()
{	
	m_bShow = true;
}

function OnHide()
{
	m_bShow = false;
	g_NameStr = "";
	m_TargetID = 0;
}

function OnEnterState( name a_PreStateName )
{
	local int tmpInt;
	GetINIInt ( "TargetStatusWnd", "e", tmpInt, "WindowsInfo.ini");
	m_bExpand = bool ( tmpInt ) ;
	SetExpandMode(m_bExpand, true);
}

function OnEvent(int Event_ID, string param)
{
	if (Event_ID == EV_TargetUpdate)
	{
		//~ debug("2");
		if (m_rotated )
			OnRotateReset();
		else
			HandleTargetUpdate();
		
		// 만약 UI에 포커스가 없는 상태에서 ESC키를 누른 경우, 포커스를 다시 타겟에 잡고
		// 안보이게 해서 UI에 포커스를 오도록 한다. 
		// 그래서 esc 키로 열려 있는 UI를 닫을 수 있도록 하기 위해서다.
		// 엔터 채팅시 문제 발생.. api 로 해야 할듯.
		/*
		if (!Me.IsShowWindow())
		{
			Me.ShowWindow();
			Me.SetFocus();
			Me.HideWindow();				
		}
		*/

	}
	else if (Event_ID == EV_TargetHideWindow)
	{
		HandleTargetHideWindow();
	}
	else if (Event_ID == EV_ReceiveTargetLevelDiff)
	{
		//~ debug("1");
		HandleReceiveTargetLevelDiff(param);
		
	}
	else if (Event_ID == EV_UpdateHP || Event_ID == EV_UpdateMyHP)
	{
		HandleUpdateGauge(param,0);
	}
	else if (Event_ID == EV_UpdateMaxHP || Event_ID == EV_UpdateMyMaxHP)
	{
		HandleUpdateGauge(param,0);
	}
	else if (Event_ID == EV_UpdateMP || Event_ID == EV_UpdateMyMP)
	{
		HandleUpdateGauge(param,1);
	}
	else if (Event_ID == EV_UpdateMaxMP || Event_ID == EV_UpdateMyMaxMP)
	{
		HandleUpdateGauge(param,1);
	}
	//선준 추가 이벤트
	//타겟의 버프 받아옴.
	else if (Event_ID == EV_TargetSpelledList)
	{			
		HandleTargetSpelledList(param);
	}
	//타겟의 스킬 시전 정보 받아옴.
	else if(Event_ID == EV_TargetSkillInfo)
	{	
		
		HandleTargetSkillInfo(param);
	}
	//타겟의 스킬 시전 취소 정보 받아옴.
	else if( Event_ID == EV_TargetSkillCancel )
	{		
		HandleSkillCancel();
	}
	// GamingState 에서 씬 연출등으로 변경될때 타겟이 잡혀 있으면..
	else if (Event_ID == EV_GamingStateExit )
	{
		RequestTargetCancel();
	}
	else if (Event_ID == EV_GamingStateEnter )
	{
		if( bIsShowBackup)
		{		
			//Me.ShowWindow();
			if (m_TargetIDBackup > 0) RequestTargetUser(m_TargetIDBackup);
		}
	}
	else if (Event_ID == EV_GamingStatePreExit )
	{
		bIsShowBackup = Me.IsShowWindow();
		m_TargetIDBackup = m_TargetID;
		RequestTargetCancel();
	}
	else if (Event_ID == EV_Restart )
	{
		bIsShowBackup = false;
		m_TargetIDBackup = -1;
	}

}

function HandleTargetHideWindow()
{
	if (m_rotated )
		OnRotateClose();
	else
		Me.HideWindow();
}

function OnClickButton( string strID )
{
	switch( strID )
	{
	case "btnClose":
		OnCloseButton();
		break;
	case "RotateButton1":
		OnRotate1();
		break;
	case "RotateButton2":
		OnRotate2();
		break;
	case "btnExpand":
		SetExpandMode(false, true);
		break;
	case "btnContract":
		SetExpandMode(true, true);
		break;
	}
}

//종료
function OnCloseButton()
{
	RequestTargetCancel();
	PlayConsoleSound(IFST_WINDOW_CLOSE);
}

//HP,MP 업데이트
function HandleUpdateGauge(string param, int Type)
{
	local int ServerID;
	
	if (m_bShow)
	{
		ParseInt( param, "ServerID", ServerID );
		if (m_TargetID == ServerID)
			HandleTargetUpdateGauge( Type );
	}
}

//타겟과의 레벨 차이
function HandleReceiveTargetLevelDiff(string param)
{
	
	ParseInt(param, "LevelDiff", m_TargetLevel);
	//~ debug ("레벨차이" @ m_TargetLevel);
	HandleTargetUpdate();
	
}

//타겟 정보 업데이트 처리(HP, MP)
function HandleTargetUpdateGauge( int Type )
{
	local UserInfo	info;
	local int		TargetID;
	
	//타겟ID 얻어오기
	TargetID = class'UIDATA_TARGET'.static.GetTargetID();
	if (TargetID<1)
	{
		if (m_rotated )
			OnRotateClose();
		else
			Me.HideWindow();
		return;
	}
	m_TargetID = TargetID;
	
	GetTargetInfo(info);
	
	switch( Type )
	{
	case 0:
		UpdateHPBar(info.nCurHP, info.nMaxHP);
	break;
	case 1:
		UpdateMPBar(info.nCurMP, info.nMaxMP);
	break;
	}	
}

//타겟 정보 업데이트 처리
function HandleTargetUpdate()
{
	local Rect rectWnd;
	local string strTmp;
	
	local int		TargetID;
	local int		PlayerID;
	local int		PetID;
	local int		ClanType;
	local int		ClanNameValue;
	
	//타겟 속성 정보
	local bool		bIsServerObject;
	local bool		bIsHPShowableNPC;	//공성진지
	local bool		bIsVehicle;
	
	local string	Name;
	local string	NameRank;
	local color	TargetNameColor;
	
	//ServerObject
	local int ServerObjectNameID;
	local Actor.EL2ObjectType ServerObjectType;
	
	//Vehicle
	local Vehicle	VehicleActor;
	local string	DriverName;
	
	//HP,MP
	local bool		bShowHPBar;
	local bool		bShowMPBar;
	
	//혈맹 정보
	local bool		bShowPledgeInfo;
	local bool		bShowPledgeTex;
	local bool		bShowPledgeAllianceTex;
	local string	PledgeName;
	local string	PledgeAllianceName;
	local texture	PledgeCrestTexture;
	local texture	PledgeAllianceCrestTexture;
	local color	PledgeNameColor;
	local color	PledgeAllianceNameColor;
	
	//NPC특성
	local bool		 bShowNpcInfo;
	local Array<int>	 arrNpcInfo;
	
	//새로운Target인가?
	local bool		IsTargetChanged;
	
	local bool  WantHideName;
	
	local UserInfo	info;
	local PetInfo   petInfo;
	
	local Color WhiteColor;	//  하얀색을 설정.

//	local int PledgeTxtLen;
//	local int PledgeAllianceTxtLen;

	// 동맹혈맹,이미지에 따른 위치 보정용 Rect
	local Rect textRect;

	WhiteColor.R = 0;
	WhiteColor.G = 0;
	WhiteColor.B = 0;
	
	
	//타겟ID 얻어오기
	TargetID = class'UIDATA_TARGET'.static.GetTargetID();

	// Debug("타겟 갱신 " @ TargetID);

	if (TargetID<1)
	{
		if (m_rotated )
		{
			OnRotateClose();
		}
		else
		{
			// ESC 닫기 관련.
			// Me.SetFocus();
			Me.HideWindow();
		}		
		
		return;
	}

	//~ if (nMasterID>0)
	//~ {
		
	//타겟이 바뀌었는가?
	if (m_TargetID!=TargetID)
	{
		IsTargetChanged = true;	
		
	}
	m_TargetID = TargetID;
	
	GetTargetInfo(info);

	//추가될 내용.
	if( info.TacticSign == 0 )
	{
		texMark.HideWindow();
		UserName.SetWindowSizeRel( 1.0f, 0, -33, 14 );
		UserName.SetAnchor(m_WindowName , "TopLeft", "TopLeft", 18, 8 );
	}
	else
	{
		texMark.ShowWindow();
		texMark.SetTexture( "l2ui_Ct1.TargetStatusWnd_DF_mark_0" $ string(info.TacticSign) );
		UserName.SetWindowSizeRel( 1.0f, 0, -54, 14 );
		UserName.SetAnchor(m_WindowName, "TopLeft", "TopLeft", 36, 8 );
	}

	WantHideName= info.WantHideName;
	
	//초기화
	rectWnd = Me.GetRect();
	PledgeName = GetSystemString(431);
	PledgeAllianceName = GetSystemString(591);
	PledgeNameColor.R = 128;
	PledgeNameColor.G = 128;
	PledgeNameColor.B = 128;
	PledgeAllianceNameColor.R = 128;
	PledgeAllianceNameColor.G = 128;
	PledgeAllianceNameColor.B = 128;
	
	//타겟 이름 색깔
	TargetNameColor = GetTargetNameColor(m_TargetLevel);
	
	bIsServerObject = class'UIDATA_TARGET'.static.IsServerObject();
	bIsVehicle = class'UIDATA_TARGET'.static.IsVehicle();
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	//StaticObject ( door 등등 )
	if (bIsServerObject)
	{
		ServerObjectType = class'UIDATA_STATICOBJECT'.static.GetServerObjectType(m_TargetID);
		
		if (ServerObjectType == EL2_AIRSHIPKEY)
		{
			Name = GetSystemString( 1966 );	//조종 키
			NameRank = "";
		}
		else if(ServerObjectType == EL2_STATUE)
		{
			Name = class'UIDATA_STATICOBJECT'.static.GetServerObjectName(m_TargetID);
			NameRank = "";
		}
		else
		{
			ServerObjectNameID = class'UIDATA_STATICOBJECT'.static.GetServerObjectNameID(m_TargetID);
			if (ServerObjectNameID>0)
			{
				Name = class'UIDATA_STATICOBJECT'.static.GetStaticObjectName(ServerObjectNameID);
				NameRank = "";
			}
		}		
		
		UserName.SetName(Name, NCT_Normal,TA_Center);
		//~ NameTxt.SetName(Name, NCT_Normal,TA_Center);
		RankName.SetName(NameRank, NCT_Normal,TA_Center);
		
		//HP표시
		if (ServerObjectType == EL2_DOOR)
		{
			if( class'UIDATA_STATICOBJECT'.static.GetStaticObjectShowHP( m_TargetID ) )
			{
				bShowHPBar = true;
				UpdateHPBar(class'UIDATA_STATICOBJECT'.static.GetServerObjectHP(m_TargetID), class'UIDATA_STATICOBJECT'.static.GetServerObjectMaxHP(m_TargetID));
			}
		}
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	//탈것인가?
	else if( bIsVehicle )
	{
		//비행선 타겟은 일단 보류한다, ttmayrin 2009.7.7
		HandleTargetHideWindow();
		return;
		
		//TO DO : 배이름, 나중에 SYSSTRING또는 서버에서 얻어오는 것으로 하자.
		UserName.SetName("AirShip", NCT_Normal,TA_Center);
		
		VehicleActor = Vehicle(class'UIDATA_TARGET'.static.GetTargetActor());
		if( VehicleActor != None )
		{
			//선장 이름
			if(VehicleActor.DriverID > 0 )
				DriverName = class'UIDATA_USER'.static.GetUserName( VehicleActor.DriverID );
			if( Len(DriverName) < 1 )
				DriverName = GetSystemString( 1967 );	// 조종사 없음
			RankName.SetName( DriverName, NCT_Normal,TA_Center );
			
			//Fuel
			//VehicleActor.MaxFuel
			//VehicleActor.CurFuel
			
			//HP
			//VehicleActor.MaxHP
			//VehicleActor.CurHP
		}		
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	//타겟ID는 있는데 이름을 알수없다면, 멀리있는 파티멤버로 가정
	else if (Len(info.Name)<1)
	{		
		Name = class'UIDATA_PARTY'.static.GetMemberVirtualName(m_TargetID);
		if ( Name == "")
		{
			Name = class'UIDATA_PARTY'.static.GetMemberName(m_TargetID);
		}
		NameRank = "";
		//debug("m_TargetID" $ m_TargetID $ ", info.Name : " $ info.Name $ ", Name : " $ Name );
		UserName.SetName(Name, NCT_Normal,TA_Center);
		//~ NameTxt.SetName(Name, NCT_Normal,TA_Center);
		RankName.SetName(NameRank, NCT_Normal,TA_Center);

		//일단 추가
		if( class'UIDATA_PARTY'.static.GetMemberTacticalSign(m_TargetID) == 0 )
		{
			texMark.HideWindow();
			UserName.SetWindowSizeRel( 1.0f, 0, -33, 14 );
			UserName.SetAnchor(m_WindowName, "TopLeft", "TopLeft", 18, 8 );
		}
		else
		{
			texMark.ShowWindow();
			texMark.SetTexture( "l2ui_Ct1.TargetStatusWnd_DF_mark_0" $ string(class'UIDATA_PARTY'.static.GetMemberTacticalSign(m_TargetID) - 1) );
			UserName.SetWindowSizeRel( 1.0f, 0, -54, 14 );
			UserName.SetAnchor(m_WindowName, "TopLeft", "TopLeft", 36, 8 );
		}
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Npc or Pc 의 경우
	else
	{
		PlayerID = class'UIDATA_PLAYER'.static.GetPlayerID();

		// 2010.7.13
		GetPetInfo(petInfo);
		PetID = info.nID; // class'UIDATA_PET'.static.GetPetID();
		
		bIsHPShowableNPC = class'UIDATA_TARGET'.static.IsHPShowableNPC();

		//if ((info.bNpc && !info.bPet && info.bCanBeAttacked ) ||	//몹의경우
		if ((info.bNpc && !info.bPet && bIsHPShowableNPC) ||	//몹의경우
			(PlayerID>0 && m_TargetID == PlayerID) ||		//나의경우
			(info.bNpc && info.bPet && m_TargetID == PetID) ||	//펫의경우
			(info.bNpc && bIsHPShowableNPC)	)		//공성진지
		{
			//일반 몹중에 항상 흰색으로 표시해 줄 필요가 있는 몬스터일 경우
			if(IsAllWhiteID(info.nClassID))
			{
				Name = info.Name;
				NameRank = "";
				//debug("m_TargetID" $ m_TargetID $ ", info.Name : " $ info.Name $ ", Name : " $ Name );
				UserName.SetName(Name, NCT_Normal,TA_Center);
				//~ NameTxt.SetName(Name, NCT_Normal,TA_Center);
				RankName.SetName(NameRank, NCT_Normal,TA_Center);
					
				//HP표시
				if(! (IsNoBarID(info.nClassID)))
				{
					bShowHPBar = true;
					UpdateHPBar(info.nCurHP, info.nMaxHP);
				}
			}
			else
			{
				Name = info.Name;
				NameRank = "";	
				UserName.SetNameWithColor(Name, NCT_Normal,TA_Center,TargetNameColor);
				//~ NameTxt.SetNameWithColor(Name, NCT_Normal,TA_Center,TargetNameColor);
				RankName.SetName(NameRank, NCT_Normal,TA_Center);
				
				//HP표시
				//branch gd35_0828
				// 대만 패킷 최적화 - gorillazin 13.10.15.
				if (info.nMaxHP > 0)
				{
					bShowHPBar = true;
					UpdateHPBar(info.nCurHP, info.nMaxHP);
				}
				//end of branch

				//MP표시
				//if (!(info.bNpc && !info.bPet && info.bCanBeAttacked))
				if (!(info.bNpc && !info.bPet))
				{
					//branch gd35_0828
					// 대만 패킷 최적화 - gorillazin 13.10.15.
					if (info.nMaxMP > 0)
					{
						bShowMPBar = true;
						UpdateMPBar(info.nCurMP, info.nMaxMP);
					}
					//end of branch
				}
				
				//공중 몬스터인지 구분할 수 있다면	-- 비행 변신체 관련 추가
				//~ if( info.bNpc && !info.bPet && bIsHPShowableNPC )
				//~ {
					//~ UpdateTargetLoc( info.Loc );
					//~ UpdateAltitudeIcon();	// 각도 체크 업데이트
					//~ UpdateDistIcon();	// 거리 체크 업데이트
				//~ }
				
			}
		}
		//Npc or Other Pc
		else
		{
			Name = info.Name;
			
			if (WantHideName)
			{
				RankName.hideWindow();	
				
			}
			if (info.bNpc)
			{
				NameRank = "";	
				g_NameStr = "";
			}
			else
			{
				// 지위 비활성화
				if ( getInstanceUIData().getIsLiveServer() ) NameRank = "";
				else NameRank = GetUserRankString(info.nUserRank);
				g_NameStr = Name;
			}
			UserName.SetName(Name, NCT_Normal,TA_Center);
			//~ NameTxt.SetName(Name, NCT_Normal,TA_Center);
			RankName.SetName(NameRank, NCT_Normal,TA_Center);
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/// 추가 정보 표시
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		if (m_bExpand)
		{
			if (info.bNpc && 0 >= info.nMasterID)
			{
				if (class'UIDATA_NPC'.static.GetNpcProperty(info.nClassID, arrNpcInfo))
				{
					bShowNpcInfo = true;
					
					//트리컨트롤에 Npc특성아이콘 추가
					//타겟이 바뀌었을때만 정보를 갱신한다. 안그럼 HP만 갱신될 때 깜박거림
					if (IsTargetChanged)
						UpdateNpcInfoTree(arrNpcInfo);
				}				
			}
			else
			{
				bShowPledgeInfo = true;
//				debug ("nClanID.info" @ info.nClanID);
				if (info.nClanID>0)
						
	
	//~ debug ("bShowPledgeInfo" @ bShowPledgeInfo);
	//~ debug ("WantHideName" @ WantHideName);
				{
					//혈맹이름
					PledgeName = class'UIDATA_CLAN'.static.GetName(info.nClanID);
					PledgeNameColor.R = 176;
					PledgeNameColor.G = 152;
					PledgeNameColor.B = 121;
					if( PledgeName != "" && class'UIDATA_USER'.static.GetClanType( m_TargetID, ClanType ) && class'UIDATA_CLAN'.static.GetNameValue(info.nClanID, ClanNameValue) )
					{
						if( ClanType == CLAN_ACADEMY )
						{
							PledgeNameColor.R = 209;
							PledgeNameColor.G = 167;
							PledgeNameColor.B = 2;
						}
						else if( ClanNameValue > 0 )
						{
							PledgeNameColor.R = 0;
							PledgeNameColor.G = 130;
							PledgeNameColor.B = 255;
						}
						else if( ClanNameValue < 0 )
						{
							PledgeNameColor.R = 255;
							PledgeNameColor.G = 0;
							PledgeNameColor.B = 0;
						}
					}
					
					//혈맹 텍스쳐 얻어오기
					if (class'UIDATA_CLAN'.static.GetCrestTexture(info.nClanID, PledgeCrestTexture))
					{
						bShowPledgeTex = true;
						texPledgeCrest.SetTextureWithObject(PledgeCrestTexture);
					}
					else
					{
						bShowPledgeTex = false;
					}
					
					//동맹이름 및 마크
					strTmp = class'UIDATA_CLAN'.static.GetAllianceName(info.nClanID);
					if (Len(strTmp)>0)
					{
						//동맹 이름 색깔
						PledgeAllianceName = strTmp;
						PledgeAllianceNameColor.R = 176;
						PledgeAllianceNameColor.G = 155;
						PledgeAllianceNameColor.B = 121;
						
						//동맹 텍스쳐 얻어오기
						if (class'UIDATA_CLAN'.static.GetAllianceCrestTexture(info.nClanID, PledgeAllianceCrestTexture))
						{
							bShowPledgeAllianceTex = true;
							texPledgeAllianceCrest.SetTextureWithObject(PledgeAllianceCrestTexture);
						}
						else
						{
							bShowPledgeAllianceTex = false;
						}
					}
				}
			}
		}
	}
	if (!Me.IsShowWindow() && GetGameStateName() != "SPECIALCAMERASTATE" )
	{
		Me.ShowWindow();
		Me.SetFocus();
		SetExpandMode(m_bExpand, false);

		// Debug("포커스가 들어온다");
		// 타겟 아이디가 있으면 컨텍스트 메뉴를 생성한다.
	}

	if (ContextMenu(GetScript("ContextMenu")).getContextEventInfo().ID > 0)
	{
	//	Debug("우클릭 메뉴 만들어");
		ContextMenu(GetScript("ContextMenu")).makeContextMenu();
		ContextMenu(GetScript("ContextMenu")).clearInfo();
	}
	
	//HP,MP표시
	if (bShowHPBar && GetGameStateName() != "SPECIALCAMERASTATE" )
	{
		barHP.ShowWindow();
	}
	else
	{
		barHP.HideWindow();
	}
	if (bShowMPBar && GetGameStateName() != "SPECIALCAMERASTATE" )
	{
		barMP.ShowWindow();
	}
	else
	{
		barMP.HIdeWindow();
	}
	
	//Hide Cursed PC Name, ttmayrin
	if( info.nClanID < 0 )
		bShowPledgeInfo = false;
	
	//debug ("nClanID" @ info.nClanID);	
	//debug ("bShowPledgeInfo" @ bShowPledgeInfo);
	//debug ("WantHideName" @ WantHideName);
	
	//혈맹정보 표시
	if (bShowPledgeInfo)
	{
		 if (!WantHideName && GetGameStateName() != "SPECIALCAMERASTATE" )
		{
			txtPledge.ShowWindow();
			txtAlliance.ShowWindow();
			txtPledgeName.ShowWindow();
			txtPledgeAllianceName.ShowWindow();
			txtPledgeName.SetText(PledgeName);
			txtPledgeAllianceName.SetText(PledgeAllianceName);
			txtPledgeName.SetTextColor(PledgeNameColor);
			txtPledgeAllianceName.SetTextColor(PledgeAllianceNameColor);
		
			// 혈맹, 혈맹이미지, 혈맹명  

			// txtPledge 은 혈맹 텍스트, 라벨용도
			textRect = txtPledge.GetRect();

			if (bShowPledgeTex)
			{
				texPledgeCrest.ShowWindow();
				texPledgeCrest.MoveTo(textRect.nX + textRect.nWidth + 1, rectWnd.nY + 43 + 1);

				// 18은, 혈맹이미지 16 * 12,  2픽셀 정도 간격을 더해서 18.
				txtPledgeName.MoveTo(textRect.nX + textRect.nWidth + 18, rectWnd.nY + 43);
			}
			else
			{
				texPledgeCrest.HideWindow();
				txtPledgeName.MoveTo(textRect.nX + textRect.nWidth + 2, rectWnd.nY + 43);
			}
			
			// txtAlliance 은 동맹 텍스트, 라벨용도
			textRect = txtAlliance.GetRect();

			// 동맹, 동맹이미지, 동맹명  
			if (bShowPledgeAllianceTex)
			{
				texPledgeAllianceCrest.ShowWindow();
				texPledgeAllianceCrest.MoveTo(textRect.nX + textRect.nWidth + 1, rectWnd.nY + 59);

				// 10은, 동맹이미지 8 * 12,  2픽셀 정도 간격을 더해서 10.
				txtPledgeAllianceName.MoveTo(textRect.nX + textRect.nWidth + 10, rectWnd.nY + 59);
			}
			else
			{
				texPledgeAllianceCrest.HideWindow();
				txtPledgeAllianceName.MoveTo(textRect.nX + textRect.nWidth + 2, rectWnd.nY + 59);
			}
		}
		
		else
		{		
			txtPledge.HideWindow();
			txtAlliance.HideWindow();
			txtPledgeName.HideWindow();
			txtPledgeAllianceName.HideWindow();
			texPledgeCrest.HideWindow();
			texPledgeAllianceCrest.HideWindow();
				
		}
	}
	else
	{
		txtPledge.HideWindow();
		txtAlliance.HideWindow();
		txtPledgeName.HideWindow();
		txtPledgeAllianceName.HideWindow();
		texPledgeCrest.HideWindow();
		texPledgeAllianceCrest.HideWindow();
		
	}
	
	//NPC특성 표시
	if (bShowNpcInfo && GetGameStateName() != "SPECIALCAMERASTATE")
	{
		NpcInfo.ShowWindow();
		NpcInfo.ShowScrollBar(false);
	}
	else
	{
		NpcInfo.HideWindow();
	}


}

//Expand상태에 따른 여러가지 처리

// 타겟과의 레벨 차이에 따른 색상 값 얻어오기
function Color GetTargetNameColor(int TargetLevelDiff)
{
	local Color OutColor;
	//~ local Color ClearColor;
	local UserInfo userinfo;
	local int myLevel;
	//~ debug ("타겟 레벨 바뀌.."@ TargetLevelDiff);
	//~ OutColor = ClearColor;

	GetPlayerInfo( userinfo );
	myLevel = userinfo.nLevel;
	
	OutColor.A = 255;
	//클래식, 아레나 예외처리
	if ( getInstanceUIData().getIsClassicServer() || getInstanceUIData().getIsArenaServer() )
    {
		if (myLevel < 78 )
		{
			if (TargetLevelDiff <= -11)
			{
				OutColor.R=255;
				OutColor.G=0;
				OutColor.B=0;
			}
			else if (TargetLevelDiff > -11 &&TargetLevelDiff <= -6)
			{
				OutColor.R=255;
				OutColor.G=145;
				OutColor.B=145;
			}
			else if (TargetLevelDiff > -6 &&TargetLevelDiff <= -3)
			{
				OutColor.R=250;
				OutColor.G=254;
				OutColor.B=145;
			}
			else if (TargetLevelDiff > -3 &&TargetLevelDiff <= 2)
			{
				OutColor.R=255;
				OutColor.G=255;
				OutColor.B=255;
			}
			else if (TargetLevelDiff > 2 &&TargetLevelDiff <= 5)
			{
				OutColor.R=162;
				OutColor.G=255;
				OutColor.B=171;
			}
			else if (TargetLevelDiff > 5 &&TargetLevelDiff <= 10)
			{
				OutColor.R=162;
				OutColor.G=168;
				OutColor.B=252;
			}
			else if (TargetLevelDiff > 10)
			{
				OutColor.R=0;
				OutColor.G=0;
				OutColor.B=255;
			}
		}
		// 유저레벨 78 ~ 84 일 경우 레벨 차이 색상 표시를 줄여 보여준다. 
		else if( myLevel >= 78 && myLevel < 85 )
		{		
			if (TargetLevelDiff <= -11)
			{
				OutColor.R=255;
				OutColor.G=0;
				OutColor.B=0;
			}
			else if (TargetLevelDiff > -11 &&TargetLevelDiff <= -4)
			{
				OutColor.R=255;
				OutColor.G=145;
				OutColor.B=145;
			}
			else if (TargetLevelDiff > -4 &&TargetLevelDiff <= -2)
			{
				OutColor.R=250;
				OutColor.G=254;
				OutColor.B=145;
			}
			else if (TargetLevelDiff > -2 &&TargetLevelDiff <= 1)
			{
				OutColor.R=255;
				OutColor.G=255;
				OutColor.B=255;
			}
			else if (TargetLevelDiff > 1 &&TargetLevelDiff <= 3)
			{
				OutColor.R=162;
				OutColor.G=255;
				OutColor.B=171;
			}
			else if (TargetLevelDiff > 3 &&TargetLevelDiff <= 10)
			{
				OutColor.R=162;
				OutColor.G=168;
				OutColor.B=252;
			}
			else if (TargetLevelDiff > 10)
			{
				OutColor.R=0;
				OutColor.G=0;
				OutColor.B=255;
			}
		}
		// 유저레벨 85이상 일 경우 레벨 차이 색상 표시를 줄여 보여준다. 
		else
		{
			if (TargetLevelDiff <= -11)
			{
				OutColor.R=255;
				OutColor.G=0;
				OutColor.B=0;
			}
			else if (TargetLevelDiff > -11 &&TargetLevelDiff <= -3)
			{
				OutColor.R=255;
				OutColor.G=145;
				OutColor.B=145;
			}
			else if (TargetLevelDiff > -3 &&TargetLevelDiff <= -2)
			{
				OutColor.R=250;
				OutColor.G=254;
				OutColor.B=145;
			}
			else if (TargetLevelDiff > -2 &&TargetLevelDiff <= 1)
			{
				OutColor.R=255;
				OutColor.G=255;
				OutColor.B=255;
			}
			else if (TargetLevelDiff > 1 &&TargetLevelDiff <= 2)
			{
				OutColor.R=162;
				OutColor.G=255;
				OutColor.B=171;
			}
			else if (TargetLevelDiff > 2 &&TargetLevelDiff <= 10)
			{
				OutColor.R=162;
				OutColor.G=168;
				OutColor.B=252;
			}
			else if (TargetLevelDiff > 10)
			{
				OutColor.R=0;
				OutColor.G=0;
				OutColor.B=255;
			}
		}
    }
	//라이브는 77레벨 이하 규칙으로 전 레벨 동일하게 변경
	else
	{
		if (TargetLevelDiff <= -11)
		{
			OutColor.R=255;
			OutColor.G=0;
			OutColor.B=0;
		}
		else if (TargetLevelDiff > -11 &&TargetLevelDiff <= -6)
		{
			OutColor.R=255;
			OutColor.G=145;
			OutColor.B=145;
		}
		else if (TargetLevelDiff > -6 &&TargetLevelDiff <= -3)
		{
			OutColor.R=250;
			OutColor.G=254;
			OutColor.B=145;
		}
		else if (TargetLevelDiff > -3 &&TargetLevelDiff <= 2)
		{
			OutColor.R=255;
			OutColor.G=255;
			OutColor.B=255;
		}
		else if (TargetLevelDiff > 2 &&TargetLevelDiff <= 5)
		{
			OutColor.R=162;
			OutColor.G=255;
			OutColor.B=171;
		}
		else if (TargetLevelDiff > 5 &&TargetLevelDiff <= 10)
		{
			OutColor.R=162;
			OutColor.G=168;
			OutColor.B=252;
		}
		else if (TargetLevelDiff > 10)
		{
			OutColor.R=0;
			OutColor.G=0;
			OutColor.B=255;
		}
	}

	//~ debug ("레벨"@ TargetLevelDiff);
	//~ debug ("색상"@ OutColor.R @ OutColor.G @ OutColor.B);
	return OutColor;
}

function SetExpandMode(bool bExpand, bool bUseTargetUpdate)
{
	local int nWndWidth, nWndHeight;	// 윈도우 사이즈 받기 변수
	Me.GetWindowSize(nWndWidth, nWndHeight);
	
	m_bExpand = bExpand;
	
	// TargetStatusWnd.uc의 서로 무한 반복 호출되는 함수 로직 수정
	// Game Bug #1935 http://wallis-devsub/redmine/issues/1935
	if (bUseTargetUpdate)
	{
		m_TargetID = -1;
		HandleTargetUpdate();
	}
	
	if (bExpand)
	{
		//~ BackTex.HideWindow();
		//~ BackExpTex.ShowWindow();
		btnExpand.ShowWindow();
		btnContract.HideWindow();
		Me.SetWindowSize(nWndWidth, EXPAND_HEIGHT);

		barSkillProgressEff1_Center.SetWindowSizeRel( 1, 0.40, -35, 0 );
		barSkillProgressEff2_Center.SetWindowSizeRel( 1, 0.40, -35, 0 );
	}
	else
	{
		//~ BackTex.ShowWindow();
		//~ BackExpTex.HideWindow();
		btnExpand.HideWindow();
		btnContract.ShowWindow();
		Me.SetWindowSize(nWndWidth, CONTRACT_HEIGHT);

		barSkillProgressEff1_Center.SetWindowSizeRel( 1, 0.70, -35, 0 );
		barSkillProgressEff2_Center.SetWindowSizeRel( 1, 0.70, -35, 0 );
	}

	SetINIInt ( "TargetStatusWnd", "e", int ( bExpand ), "WindowsInfo.ini");
}

//HP바 갱신
function UpdateHPBar(int HP, int MaxHP)
{
	//branch gd35_0828
	// 대만 패킷 최적화 - gorillazin 13.10.15.
	if (MaxHP > 0)
	{
		barHP.SetValue(MaxHP, HP);
	}
	else
	{
		barHP.HideWindow();
	}
	//end of branch
}

//MP바 갱신
function UpdateMPBar(int MP, int MaxMP)
{
	//branch gd35_0828
	// 대만 패킷 최적화 - gorillazin 13.10.15.
	if (MaxMP > 0)
	{
		barMP.SetValue(MaxMP, MP);
	}
	else
	{
		barMP.HideWindow();
	}
	//end of branch
}

//~ //타겟과 나의 고도 표기를 변경해준다.
//~ function UpdateAltitudeIcon()
//~ {
	//~ //local UserInfo	MyInfo;
	//~ local vector myLoc;
	//~ local vector targetMyLoc;
	//~ local vector targetNormalV;
	//~ local vector targetProjectionLoc;
	//~ local vector zeroV;
	
	//~ local float cosAngle;
	//~ local float angle;	
	
	//~ local float a;
	//~ local float b;
	//~ local float c;
	
	//~ //GetPlayerInfo( MyInfo );
	//~ myLoc = GetPlayerPosition();

	//~ targetMyLoc.x = targetLoc.x - myLoc.x;
	//~ targetMyLoc.y = targetLoc.y - myLoc.y;
	//~ targetMyLoc.z = targetLoc.z - myLoc.z;
	//~ targetNormalV = Normal(targetMyLoc);		// 노말 벡터로 변경
	
	//~ zeroV.x = 0;
	//~ zeroV.y = 0;
	//~ zeroV.z = 0;
		
	//~ targetProjectionLoc.x = targetNormalV.x;
	//~ targetProjectionLoc.y = targetNormalV.y;
	//~ targetProjectionLoc.z = 0;
	
	//~ a = sqrt( ( targetNormalV.x)^2 + (targetNormalV.y)^2 + (targetNormalV.z)^2);
	//~ b = sqrt( ( targetProjectionLoc.x)^2 + (targetProjectionLoc.y)^2 + ( targetProjectionLoc.z)^2);
	//~ c = sqrt( (targetNormalV.x - targetProjectionLoc.x)^2  + (targetNormalV.y - targetProjectionLoc.y)^2 + (targetNormalV.z - targetProjectionLoc.z)^2 );	

	//~ cosAngle = (b^2 + c^2 - a^2) / 2 * b* c ;
	
	//~ //angle = 90 - ( Atan( cosAngle / sqrt(1- cosAngle^2)));
	//~ //if( angle < 0) angle = angle * ( -1);
		
	//~ debug("------------- cosAngle = " $ cosAngle);
	
//~ }

//~ //타겟과 나의 거리 표기를 변경해준다.
//~ function UpdateDistIcon()
//~ {
	//~ local vector myLoc;
	//~ local int distance;
	
//~ }

//~ // 타겟의 위치를 업데이트 한다.
//~ function UpdateTargetLoc( vector m_TargetPosition )
//~ {
	//~ targetLoc.x = m_TargetPosition.x;
	//~ targetLoc.y = m_TargetPosition.y;
	//~ targetLoc.z = m_TargetPosition.z;
//~ }

//트리컨트롤에 Npc특성아이콘 추가
function UpdateNpcInfoTree(array<int> arrNpcInfo)
{
	local int i;
	local int SkillID;
	local int SkillLevel;
	
	local string				strNodeName;
	local XMLTreeNodeInfo		infNode;
	local XMLTreeNodeItemInfo	infNodeItem;
	local XMLTreeNodeInfo		infNodeClear;
	local XMLTreeNodeItemInfo	infNodeItemClear;
	
	//초기화
	NpcInfo.Clear();
	
	//루트 추가
	infNode.strName = "root";
	strNodeName = NpcInfo.InsertNode("", infNode);
	if (Len(strNodeName) < 1)
	{
		//~ debug("ERROR: Can't insert root node. Name: " $ infNode.strName);
		return;
	}
	
	for (i=0; i<arrNpcInfo.Length; i+=2)
	{
		SkillID = arrNpcInfo[i];
		SkillLevel = arrNpcInfo[i+1];
		
		//////////////////////////////////////////////////////////////////////////////////////////////////////
		//Insert Node
		infNode = infNodeClear;
		infNode.nOffSetX = ((i/2)%8)*18;
		if ((i/2)%8==0)
		{
			if (i>0)
			{
				infNode.nOffSetY = 3;
			}
			else
			{
				infNode.nOffSetY = 0;
			}
		}
		else
		{
			infNode.nOffSetY = -15;
		}
		
		infNode.strName = "" $ i/2;
		infNode.bShowButton = 0;
		//Tooltip
		infNode.ToolTip = SetNpcInfoTooltip(SkillID, SkillLevel);
		strNodeName = NpcInfo.InsertNode("root", infNode);
		if (Len(strNodeName) < 1)
		{
			Log("ERROR: Can't insert node. Name: " $ infNode.strName);
			return;
		}
		//Node Tooltip Clear
		infNode.ToolTip.DrawList.Remove(0, infNode.ToolTip.DrawList.Length);
		
		//////////////////////////////////////////////////////////////////////////////////////////////////////
		//Insert NodeItem
		infNodeItem = infNodeItemClear;
		infNodeItem.eType = XTNITEM_TEXTURE;
		infNodeItem.u_nTextureWidth = 15;
		infNodeItem.u_nTextureHeight = 15;
		infNodeItem.u_nTextureUWidth = 32;
		infNodeItem.u_nTextureUHeight = 32;
		// !문제 있는지 확인
		infNodeItem.u_strTexture = class'UIDATA_SKILL'.static.GetIconName(GetItemID(SkillID), SkillLevel, 0);
		NpcInfo.InsertNodeItem(strNodeName, infNodeItem);
	}
}

function CustomTooltip SetNpcInfoTooltip(int ID, int Level)
{
	local CustomTooltip Tooltip;
	local DrawItemInfo info;
	local DrawItemInfo infoClear;
	local ItemInfo Item;
	local ItemID cID;
	
	cID = GetItemID(ID);
	
	Item.Name = class'UIDATA_SKILL'.static.GetName(cID, Level, 0);
	Item.Description = class'UIDATA_SKILL'.static.GetDescription(cID, Level, 0);
	
	Tooltip.DrawList.Length = 1;
	
	//이름
	info = infoClear;
	info.eType = DIT_TEXT;
	info.t_bDrawOneLine = true;
	info.t_strText = Item.Name;
	Tooltip.DrawList[0] = info;

	//설명
	if (Len(Item.Description)>0)
	{
		Tooltip.MinimumWidth = 144;
		Tooltip.DrawList.Length = 2;
		
		info = infoClear;
		info.eType = DIT_TEXT;
		info.nOffSetY = 6;
		info.bLineBreak = true;
		info.t_color.R = 178;
		info.t_color.G = 190;
		info.t_color.B = 207;
		info.t_color.A = 255;
		info.t_strText = Item.Description;
		Tooltip.DrawList[1] = info;	
	}
	return Tooltip;
}

//항상 흰색으로 표시해 줄 몬스터를 체크하는 함수
function bool IsAllWhiteID(int m_TargetID)
{
	local bool	bIsAllWhiteName;
	bIsAllWhiteName = false;
	
	switch( m_TargetID )
	{
		case 12775:	//박
		case 12776:
		case 12778:
		case 12779:
		case 13016:
		case 13017:	// 박
		case 13031:	//거대 돼지
		case 13032:	//거대 돼지 리더
		case 13033:	//거대 돼지 부하
		case 13034:	//초거대 돼지
		case 13035:	//황금 돼지
		case 13036:	//연금술사의 보물상자
		case 13098:	//보물찾기 보물상자
		case 13120:	//거대 쥐
		case 13121:	
		case 13122:	
		case 13123:	
		case 13124:	

		// 수박 이벤트 2009. 8.14 추가 
		case 13271:
		case 13272:
		case 13273:
		case 13274:
		case 13275:
		case 13276:
		case 13277:
		case 13278:

		// 소 이벤트 2009. 8.14 추가 
		case 13187:
		case 13188:
		case 13189:
		case 13190:
		case 13191:
		case 13192:

		// 백호 이벤트 2019. 2.29 추가 
		case 13286: // 아기 백호
		case 13287: // 아기 백호 대장
		case 13288: // 우울한 아기 백호
		case 13289: // 우울한 아기 백호 대장
		case 13290: // 백호
		case 13291: // 백호 대장
		case 13292: // 마법 연구소 직원

		// 테르시아의 빛 이벤트 2011. 7.21 추가
		case 13342: // 빛의 환영
		case 13343: // 신비한 빛의 환영
		case 13344: // 신비한 빛의 환영
		case 13345: // 신비한 빛의 환영
		case 13346: // 빛의 환영
		case 13347: // 빛의 환영
		case 13348: // 빛의 환영
		case 13349: // 빛의 환영
		
		// 눈대박이벤트 2012.12.17 추가
		case 13400: // 눈대박이벤트
		case 13401: // 눈대박이벤트 
		case 13402: // 눈대박이벤트
		case 13404: // 눈대박이벤트
		case 13405: // 눈대박이벤트
		case 13406: // 눈대박이벤트

		// 10주년이벤트 2013.9.27 추가
		case 26089: // 아덴 정복을 꿈꾸는 오크
		case 13419: // 우량박
		case 13420: // 불량박
		case 13421: // 우량대박
		case 13422: // 불량대박

		// 사업팀 프로모션 아덴정복 오크 2013.12.02 추가
		case 26091: // 아덴 정복을 꿈꾸는 오크

		// 13주년 이벤트
		case 26248: // 아덴 정복을 꿈꾸는 오크
		case 13551: // 마법 장작 더미
		case 13552: // 커다란 마법 장작 더미


			 bIsAllWhiteName = true;
			 break;
	}	
	return bIsAllWhiteName;
}

//HP 바도 표시하면 안되는 몬스터인지 체크하는 함수
function bool IsNoBarID(int m_TargetID)
{
	local bool	bIsNoBarName;
	bIsNoBarName = false;
	
	switch( m_TargetID )
	{
		case 13036:	//연금술사의 보물상자
		case 13098:	//보물찾기 보물상자
			bIsNoBarName = true;
			break;
	}	
	return bIsNoBarName;
}


//타겟 버프 생성
function HandleTargetSpelledList(string param)
{
	local int i;
	local int Max;
	local int b;
	local int TargetID;	

	local StatusIconInfo info;
	
	ClearAll();	

	ParseInt(param, "ID", TargetID);
	ParseInt(param, "Max", Max);

	//Debug(">>>>>>>"$string(TargetID)$string(StatusIcons)$string(Max));
	
	for( i = 0 ; i < Max ; i++ )
	{
		//Skill ClassID
		ParseInt(param, "ClassID_" $ i, info.ID.ClassID);
		ParseInt(param, "Level_" $ i, info.Level);
		ParseInt(param, "SubLevel_" $ i, info.SubLevel);

		// 토핑 버프인 경우 add 하지 않음.
		if ( class'UIDATA_SKILL'.static.IsToppingSkill( info.ID, info.Level, info.SubLevel) ) 
		{			
			continue ;
		}

		ParseInt(param, "Sec_" $ i, info.RemainTime);
		ParseInt(param, "OwnerShip_" $ i, b);
				
		info.Name           = class'UIDATA_SKILL'.static.GetName(info.ID, info.Level, info.SubLevel);
		info.IconName       = class'UIDATA_SKILL'.static.GetIconName(info.ID, info.Level, info.SubLevel);
		info.Description    = class'UIDATA_SKILL'.static.GetDescription(info.ID, info.Level, info.SubLevel );
	
		if( b == 0 )
		{
			info.bOwnerShip = false;			
		}
		else
		{
			info.bOwnerShip = true;
		}

		info = SelectTexture(info);	
	}
	

	MyBuffDraw();
	OtherBuffDraw();
	MyDebuffDraw();
	OtherDebuffDraw();

	moveBuffWndMoreView2();
}

//버프의 라인 추가순서상 1번째로 그려줌.(1번째 라인, 자신의 버프)
function MyBuffDraw()
{
	local int i;
	local int length;
	local array<StatusIconInfo> temp;
	local TargetStatusBuff1Wnd script;
	
	script = TargetStatusBuff1Wnd( GetScript("TargetStatusBuff1Wnd") );	
	script.ResetBuffIcon();

	length = arrMyBuff.Length;

	if( length > 0 && length < 9)
	{
		//추가 버프에 대한 버튼 사라짐.
		showBuffMoreBtn( false, 1 );

		StatusIcons.AddRow();
		for( i = 0 ; i < length ; i++ )
		{
			StatusIcons.AddCol( lineCount, arrMyBuff[i] );

			//test코드..
			//temp.Insert( temp.Length, 1 );
			//temp[temp.Length -1 ] = arrMyBuff[i];
			//debug( string(i)$">>>"$string(arrMyBuff[i].Level)$"__"$string(arrMyBuff[i].RemainTime)$"__"$arrMyBuff[i].Name$"__"$arrMyBuff[i].IconName$"__"$arrMyBuff[i].Description$"__ i="$string(i)); 
		}		
		
		//test코드..
		//script.showBuff( temp );

		lineCount++;
	}
	else if ( length >= 9 )
	{
		//추가 버프에 대한 버튼 나타남.
		showBuffMoreBtn( true, 1 );

		StatusIcons.AddRow();
		for( i = 0 ; i < length ; i++ )
		{
			if( i > length - 9 )
			{
				StatusIcons.AddCol( lineCount, arrMyBuff[i] );
			}
			else
			{
				temp.Insert( temp.Length, 1 );
				temp[temp.Length -1 ] = arrMyBuff[i];
			}
		}
		script.showBuff( temp );
		lineCount++;
	}
}

//버프의 라인 추가순서상 2번째로 그려줌.(2번째 라인, 타인의 버프)
function OtherBuffDraw()
{
	local int i;

	if( arrOtherBuff.Length > 0 )
	{
		StatusIcons.AddRow();
		for( i = 0 ; i < arrOtherBuff.Length ; i++ )
		{
			if( i > arrOtherBuff.length - 13 )
			{
				arrOtherBuff[i].bHideRemainTime = true;
				StatusIcons.AddCol( lineCount, arrOtherBuff[i] );
			}			
			//debug( string(i)$">>>"$string(arrOtherBuff[i].Level)$"__"$string(arrOtherBuff[i].RemainTime)$"__"$arrOtherBuff[i].Name$"__"$arrOtherBuff[i].IconName$"__"$arrOtherBuff[i].Description$"__ i="$string(i)); 
		}
		lineCount++;
	}
}

//버프의 라인 추가순서상 3번째로 그려줌.(3번째 라인, 자신의 디버프)
function MyDebuffDraw()
{
	local int i;
	local int length;
	local array<StatusIconInfo> temp;
	local TargetStatusBuff2Wnd script;
	
	script = TargetStatusBuff2Wnd( GetScript("TargetStatusBuff2Wnd") );	
	script.ResetBuffIcon();

	length = arrMyDebuff.Length;

	if( length > 0 && length < 9)
	{
		//추가 버프에 대한 버튼 사라짐.
		showBuffMoreBtn( false, 2 );

		StatusIcons.AddRow();
		for( i = 0 ; i < length ; i++ )
		{
			StatusIcons.AddCol( lineCount, arrMyDebuff[i] );
			//test코드..
			//temp.Insert( temp.Length, 1 );
			//temp[temp.Length -1 ] = arrMyDebuff[i];
			//debug( string(i)$">>>"$string(arrMyDebuff[i].Level)$"__"$string(arrMyDebuff[i].RemainTime)$"__"$arrMyDebuff[i].Name$"__"$arrMyDebuff[i].IconName$"__"$arrMyDebuff[i].Description$"__ i="$string(i)); 
		}		
		
		//test코드..
		//script.showBuff( temp );

		lineCount++;
	}
	else if ( length >= 9 )
	{
		//추가 버프에 대한 버튼 나타남.
		showBuffMoreBtn( true, 2 );

		StatusIcons.AddRow();
		for( i = 0 ; i < length ; i++ )
		{
			if( i > length - 9 )
			{
				StatusIcons.AddCol( lineCount, arrMyDebuff[i] );
			}
			else
			{
				temp.Insert( temp.Length, 1 );
				temp[temp.Length -1 ] = arrMyDebuff[i];
			}
		}
		script.showBuff( temp );
		lineCount++;
	}
}

//버프의 라인 추가순서상 4번째로 그려줌.(4번째 라인, 타인의 디버프)
function OtherDebuffDraw()
{
	local int i;
	local int num;

	num = 0;

	if( arrOtherDebuff.Length > 0 )
	{
		StatusIcons.AddRow();
		for( i = 0 ; i < arrOtherDebuff.Length ; i++ )
		{
			if( i > arrOtherDebuff.length - 25 )
			{
				if( num == 12 )
				{
					StatusIcons.AddRow();
					lineCount++;
				}
				num++;
				arrOtherDebuff[i].bHideRemainTime = true;
				StatusIcons.AddCol( lineCount, arrOtherDebuff[i] );
			}			
			//debug( string(i)$">>>"$string(arrOtherDebuff[i].Level)$"__"$string(arrOtherDebuff[i].RemainTime)$"__"$arrOtherDebuff[i].Name$"__"$arrOtherDebuff[i].IconName$"__"$arrOtherDebuff[i].Description$"__ i="$string(i)); 
		}
		lineCount++;
	}
}


//버프 관련 초기화
function ClearAll()
{
	lineCount = 0;

	showBuffMoreBtn( false, 1 );
	showBuffMoreBtn( false, 2 );

	ResetArray();
	ResetBuffIcon();
}

//배열 초기화
function ResetArray()
{
	arrMyBuff.Remove        ( 0, arrMyBuff.length );
	arrOtherBuff.Remove     ( 0, arrOtherBuff.length );
	arrMyDebuff.Remove      ( 0, arrMyDebuff.length );
	arrOtherDebuff.Remove   ( 0, arrOtherDebuff.length );
}

//버프 아이콘 All Clear
function ResetBuffIcon()
{
	StatusIcons.Clear();	
}

//StatusIconInfo Setting ( 크기, Back 텍스쳐 선택, 배열에 insert)
function StatusIconInfo SelectTexture( StatusIconInfo info )
{
	//아이콘 보여줌.
	info.bShow = true;

	//디버프에 대한 StatusIconInfo정보 입력
	if ( GetDebuffType( info.ID, info.Level, info.SubLevel ) != 0 )
	{
		//자신의 디버프 일때.
		if( info.bOwnerShip )
		{
			info.Size = BUFF_SIZE_BIG;			
			info.BackTex = "L2UI_CT1.Buff.DeBuffFrame_24";
			arrMyDebuff.Insert( arrMyDebuff.Length, 1 );
			arrMyDebuff[arrMyDebuff.Length -1 ] = info;
		}
		//타인의 디버프 일때.
		else
		{			
			info.Size = BUFF_SIZE_SMALL;			
			info.BackTex = "L2UI_CT1.Buff.DeBuffFrame_16";
			arrOtherDebuff.Insert( arrOtherDebuff.Length, 1 );
			arrOtherDebuff[arrOtherDebuff.Length -1 ] = info;
			
		}
	}
	//발동 스킬에 대한 StatusIconInfo정보 입력
	else if( IsTriggerSkill( info.ID, info.Level, info.SubLevel ) == true )
	{
		//자신의 발동 스킬 일때.
		if( info.bOwnerShip )
		{
			info.Size = BUFF_SIZE_BIG;			
			info.BackTex = "L2UI_CT1.Buff.BuffFrame_24_3";
			arrMyBuff.Insert( arrMyBuff.Length, 1 );
			arrMyBuff[arrMyBuff.Length -1 ] = info;
		}
		//타인의 발동 스킬 일때.
		else
		{
			info.Size = BUFF_SIZE_SMALL;			
			info.BackTex = "L2UI_CT1.Buff.BuffFrame_16_3";
			arrOtherBuff.Insert( arrOtherBuff.Length, 1 );
			arrOtherBuff[arrOtherBuff.Length -1 ] = info;
		}
	}
	//송댄스 스킬에 대한 StatusIconInfo정보 입력
	else if(IsSongDance( info.ID, info.Level, info.SubLevel) == true )
	{
		//자신의 송댄스 스킬 일때.
		if( info.bOwnerShip )
		{
			info.Size = BUFF_SIZE_BIG;			
			info.BackTex = "L2UI_CT1.Buff.BuffFrame_24_2";
			arrMyBuff.Insert( arrMyBuff.Length, 1 );
			arrMyBuff[arrMyBuff.Length -1 ] = info;
		}
		//타인의 송댄스 스킬 일때.
		else
		{
			info.Size = BUFF_SIZE_SMALL;			
			info.BackTex = "L2UI_CT1.Buff.BuffFrame_16_2";
			arrOtherBuff.Insert( arrOtherBuff.Length, 1 );
			arrOtherBuff[arrOtherBuff.Length -1 ] = info;
		}
	}
	//버프에 대한 StatusIconInfo정보 입력
	else
	{
		//자신의 버프 일때.
		if( info.bOwnerShip )
		{
			info.Size = BUFF_SIZE_BIG;			
			info.BackTex = "L2UI_CT1.Buff.BuffFrame_24_1";
			arrMyBuff.Insert( arrMyBuff.Length, 1 );
			arrMyBuff[arrMyBuff.Length -1 ] = info;
		}
		//타인의 버프 일때.
		else
		{
			info.Size = BUFF_SIZE_SMALL;			
			info.BackTex = "L2UI_CT1.Buff.BuffFrame_16_1";
			arrOtherBuff.Insert( arrOtherBuff.Length, 1 );
			arrOtherBuff[arrOtherBuff.Length -1 ] = info;
		}
	}

	return info;
}

//추가 버프에 대한 버튼의 show/hide
function showBuffMoreBtn( bool b, int n )
{
	if( b == true )
	{	
		GetButtonHandle(m_WindowName $ ".BuffWnd.btnBuffMoreView"$n).ShowWindow();
	}
	else
	{
		GetButtonHandle(m_WindowName $ ".BuffWnd.btnBuffMoreView"$n).HideWindow();
	}
}

//추가 디버프 버프에 따른 위치 이동
function moveBuffWndMoreView2()
{	
	if( arrMyBuff.Length > 0 )
	{
		yPosView2 = 26;
	}
	else
	{
		yPosView2 = 0;
	}

	if( arrOtherBuff.Length > 0 )
	{
		yPosView2 = yPosView2 + 18;
	}		
	btnBuffMoreView2.MoveTo( BuffWnd.GetRect().nX, BuffWnd.GetRect().nY + yPosView2 );
}

//추가 버프에 대한 버튼에 마우스 오버시 창 나타남.
event OnMouseOver( WindowHandle w )
{	
	if( btnBuffMoreView1 == w )
	{
		TargetStatusBuff1Wnd.ShowWindow();
	}
	else if( btnBuffMoreView2 == w )
	{
		TargetStatusBuff2Wnd.ShowWindow();
	}
}

//추가 버프에 대한 버튼에 마우스 아웃시 창 사라짐.
event OnMouseOut( WindowHandle w )
{	
	if( btnBuffMoreView1 == w )
	{		
		TargetStatusBuff1Wnd.HideWindow();
	}
	else if( btnBuffMoreView2 == w )
	{
		TargetStatusBuff2Wnd.HideWindow();
	}
}










//타겟 스킬 시전 EV 받음
function HandleTargetSkillInfo(string param)
{
	local int bIsHostile;
	
	local int bUseSlot1;
	local float fTotalTimeSlot1;
	local float fElapsedTimeSlot1;
	local string SkillNameSlot1;
	local int Resistcast1;

	local int bUseSlot2;
	local float fTotalTimeSlot2;
	local float fElapsedTimeSlot2;
	local string SkillNameSlot2;
	local int Resistcast2;

	local Color White;
	local Color Red;

	Red.R = 255;
	Red.G = 0;
	Red.B = 0;
	Red.A = 255;

	White.R = 255;
	White.G = 255;
	White.B = 255;
	White.A = 255;

	// 적대적, 우호적에 대한 구분
	ParseInt(param, "bIsHostile", bIsHostile);	
	if(bIsHostile ==  0)
	{
		strSelectTarget ="Friendly";
	}
	else 
	{
		strSelectTarget ="Enemy";
	}	
	
	ParseInt(param, "bUseSlot1", bUseSlot1);
	ParseFloat(param, "fTotalTimeSlot1", fTotalTimeSlot1);
	ParseFloat(param, "fElapsedTimeSlot1", fElapsedTimeSlot1);
	ParseString(param, "SkillNameSlot1", SkillNameSlot1);
	ParseInt(param, "ResistCast1", ResistCast1 );

	ParseInt(param, "bUseSlot2", bUseSlot2);
	ParseFloat(param, "fTotalTimeSlot2", fTotalTimeSlot2);
	ParseFloat(param, "fElapsedTimeSlot2", fElapsedTimeSlot2);
	ParseString(param, "SkillNameSlot2", SkillNameSlot2);
	ParseInt(param, "ResistCast2", ResistCast2 );

	//Debug( string( GetOptionBool( "ScreenInfo", "SkillCastingBox" ) ) );

	if( GetOptionBool( "ScreenInfo", "SkillCastingBox" ) == false )
	{
		return;
	}
	
	if( bUseSlot1 != 0 )
	{
		//시간이 마이너스 일 경우 제외
		if( fTotalTimeSlot1 > 0 )
		{
			Me.KillTimer( TimerValue7 );
			Me.KillTimer( TimerValue9 ); //타이머를 죽이지 않으면, HandleSkillCancel 타이머 캔슬에서 1초 뒤 모든 값을 초기화 시키므로 
			SetTextureBar("Progress", 1);
			SetEffectTexture("Progress", 1);
			showSkillSlot( fTotalTimeSlot1, fElapsedTimeSlot1, 1 );			
			//취소 불능 스킬 이름 빨간색으로.
			if( ResistCast1 == 1 )
			{
				skillProgressName1.SetNameWithColor( SkillNameSlot1, NCT_Normal, TA_Center, Red );
			}
			else
			{
				skillProgressName1.SetNameWithColor( SkillNameSlot1, NCT_Normal, TA_Center, White );
			}
		}
	}
	else
	{
		skillBarVisible( false, 1 );
		barSkillProgress1.Reset();
	}

	if( bUseSlot2 != 0 )
	{
		//시간이 마이너스 일 경우 제외
		if( fTotalTimeSlot1 > 0 )
		{
			Me.KillTimer( TimerValue8 );
			Me.KillTimer( TimerValue9 ); //타이머를 죽이지 않으면, HandleSkillCancel 타이머 캔슬에서 1초 뒤 모든 값을 초기화 시키므로 
			SetTextureBar("Progress", 2);
			SetEffectTexture("Progress", 2);
			showSkillSlot( fTotalTimeSlot2, fElapsedTimeSlot2, 2 );
			//취소 불능 스킬 이름 빨간색으로.
			if( ResistCast2 == 1 )
			{
				skillProgressName2.SetNameWithColor( SkillNameSlot2, NCT_Normal, TA_Center, Red );
			}
			else
			{
				skillProgressName2.SetNameWithColor( SkillNameSlot2, NCT_Normal, TA_Center, White );
			}
		}
	}
	else
	{
		skillBarVisible( false, 2 );
		barSkillProgress2.Reset();
	}
	//Debug( string(bIsHostile)$"&&"$string(fTotalTimeSlot1)$"&&"$string(fElapsedTimeSlot1) );
}

//슬롯의 스킬 시전.
function showSkillSlot(float total, float elapsed, int slot)
{
	skillBarVisible( true, slot );

	GetProgressCtrlHandle(m_WindowName $".SkillProgressWnd" $ slot $ "." $"barSkillProgress"$slot).Stop();
	GetProgressCtrlHandle(m_WindowName $".SkillProgressWnd" $ slot $ "." $"barSkillProgress"$slot).Reset();
	GetProgressCtrlHandle(m_WindowName $".SkillProgressWnd" $ slot $ "." $"barSkillProgress"$slot).SetProgressTime( int(total) );
	GetProgressCtrlHandle(m_WindowName $".SkillProgressWnd" $ slot $ "." $"barSkillProgress"$slot).SetPos( int( total - elapsed ) );
	GetProgressCtrlHandle(m_WindowName $".SkillProgressWnd" $ slot $ "." $"barSkillProgress"$slot).Start();	
}


function OnProgressTimeUp( string strID )
{
//	Debug("OnProgressTimeUp" @ strID);
	if( strID == "barSkillProgress1" )
	{
		SetTextureBar("Success", 1 );
		SetEffectTexture("Success", 1 );
		Me.SetTimer( TimerValue7, 1000);
	}
	else if( strID == "barSkillProgress2" )
	{
		SetTextureBar("Success", 2 );
		SetEffectTexture("Success", 2 );
		Me.SetTimer( TimerValue8, 1000);
	}
}

/** 스킬시전중취소된경우*/
function HandleSkillCancel()
{
	/*
	local int currentTargetID;
	local int AttackerID;

	currentTargetID = class'UIDATA_TARGET'.static.GetTargetID();
	ParseInt(param, "AttackerID", AttackerID);	
	debug("SkillCanecl - Attacker ID " @ AttackerID);

	// 현재타겟의스킬이취소된경우
	if (currentTargetID == AttackerID)
	{
		// 시전바정지
		barSkillProgress.Stop();

		// 스킬취소텍스처
		SetEffectTexture("Failed");
		SetTextureForCtrlBar("Failed");
		Me.SetTimer(TimerValue8, 400);
	}
	*/
	//skillBarVisible( true, 1 );
	//skillBarVisible( true, 2 );
	//showSkillSlot( 5000, 0, 1 );
	//showSkillSlot( 5000, 0, 2 );
	SetTextureBar("Failed", 1 );
	SetEffectTexture("Failed", 1 );
	barSkillProgress1.Stop();
	SetTextureBar("Failed", 2 );
	SetEffectTexture("Failed", 2 );
	barSkillProgress2.Stop();

	Me.SetTimer( TimerValue9, 1000);
}



/** 스킬시전관련요소를보이고안보이도록세팅 */
function skillBarVisible(bool flag, int slot)
{
	//Debug("skillBarVisible" @ flag @ slot);
	if (flag == true) 
	{
		/*
		if( GetOptionBool( "ScreenInfo", "SkillCastingBox" ) == true )
		{
			ShowWindow( m_WindowName $ ".SkillProgressWnd1" );
			ShowWindow( m_WindowName $ ".SkillProgressWnd2" );
			//barSkillProgress1.Reset();
			//barSkillProgress2.Reset();
		}*/

		GetNameCtrlHandle( m_WindowName $".SkillProgressWnd" $ slot $ "." $"skillProgressName"$slot).ShowWindow();
		GetProgressCtrlHandle(m_WindowName $".SkillProgressWnd" $ slot $ "." $"barSkillProgress"$slot).ShowWindow();

		GetTextureHandle ( m_WindowName $".SkillProgressWnd" $ slot $ "." $"barSkillProgressEff"$slot$"_Left").ShowWindow();
		GetTextureHandle ( m_WindowName $".SkillProgressWnd" $ slot $ "." $"barSkillProgressEff"$slot$"_Center").ShowWindow();
		GetTextureHandle ( m_WindowName $".SkillProgressWnd" $ slot $ "." $"barSkillProgressEff"$slot$"_Right").ShowWindow();
	}
	else
	{
		if( slot == 1 )
		{
			barSkillProgress1.Reset();
			//HideWindow( m_WindowName $ ".SkillProgressWnd1" );
		}
		else
		{
			barSkillProgress2.Reset();
			//HideWindow( m_WindowName $ ".SkillProgressWnd2" );	
		}

		GetNameCtrlHandle(m_WindowName $".SkillProgressWnd" $ slot $ "." $"skillProgressName"$slot).HideWindow();		
		GetProgressCtrlHandle(m_WindowName $".SkillProgressWnd" $ slot $ "." $"barSkillProgress"$slot).HideWindow();
		GetProgressCtrlHandle(m_WindowName $".SkillProgressWnd" $ slot $ "." $"barSkillProgress"$slot).Reset();

		GetTextureHandle (m_WindowName $".SkillProgressWnd" $ slot $ "." $ "barSkillProgressEff"$slot$"_Left").HideWindow();
		GetTextureHandle (m_WindowName $".SkillProgressWnd" $ slot $ "." $"barSkillProgressEff"$slot$"_Center").HideWindow();
		GetTextureHandle (m_WindowName $".SkillProgressWnd" $ slot $ "." $"barSkillProgressEff"$slot$"_Right").HideWindow();
	}
}


/**  
 *   스킬 시전 컨트롤바 , 텍스쳐 변경 , 3가지 상태에 따라 텍스쳐를 변경 한다. ( 적대적 대상 )
 *   Success, progress, Failed
 **/
function SetTextureBar(string stateString, int slot)
{	
	GetProgressCtrlHandle(m_WindowName $".SkillProgressWnd" $ slot $ "." $"barSkillProgress"$slot).SetBackTex("L2UI_ct1.SkillOperate_DF_" $ strSelectTarget $ "_" $ stateString $ "_Bg_Left", 
																"L2UI_ct1.SkillOperate_DF_" $ strSelectTarget $ "_" $ stateString $ "_Bg_Center", 
																"L2UI_ct1.SkillOperate_DF_" $ strSelectTarget $ "_" $ stateString $ "_Bg_Right");

	GetProgressCtrlHandle(m_WindowName $".SkillProgressWnd" $ slot $ "." $"barSkillProgress"$slot).SetBarTex("L2UI_ct1.SkillOperate_DF_" $ strSelectTarget $ "_" $ stateString $ "_Gage_Left", 
																"L2UI_ct1.SkillOperate_DF_" $ strSelectTarget $ "_" $ stateString $ "_Gage_Center", 
																 "L2UI_ct1.SkillOperate_DF_" $ strSelectTarget $ "_" $ stateString $ "_Gage_Right");

}


/**  
 *   스킬 시전 이팩트 텍스쳐 변경 , 3가지 상태에 따라 텍스쳐를 변경 한다. 
 *   Success, progress, Failed
 **/
function SetEffectTexture(string stateString, int slot)
{
	
	
	GetTextureHandle(m_WindowName $".SkillProgressWnd" $ slot $ "." $"barSkillProgressEff" $ slot $"_Left").SetTexture("L2UI_ct1.SkillOperate_DF_" $ strSelectTarget $ "_" $ stateString  $ "_Eff_Left");
	GetTextureHandle(m_WindowName $".SkillProgressWnd" $ slot $ "." $"barSkillProgressEff" $ slot $"_Center").SetTexture("L2UI_ct1.SkillOperate_DF_" $ strSelectTarget $ "_" $ stateString  $ "_Eff_Center");
	GetTextureHandle(m_WindowName $".SkillProgressWnd" $ slot $ "." $"barSkillProgressEff" $ slot $"_Right").SetTexture("L2UI_ct1.SkillOperate_DF_" $ strSelectTarget $ "_" $ stateString  $ "_Eff_Right");
}



/**
 * 옵션용 타겟에 스킬시전바 표시 on/off
 */
/*
function SkillCastingBoxShow( bool b )
{
	if( b == true )
	{
		barSkillProgress1.Reset();
		barSkillProgress2.Reset();
		ShowWindow( m_WindowName $ ".SkillProgressWnd1" );
		ShowWindow( m_WindowName $ ".SkillProgressWnd2" );
	}
	else
	{
		barSkillProgress1.Reset();
		barSkillProgress2.Reset();
		HideWindow( m_WindowName $ ".SkillProgressWnd1" );
		HideWindow( m_WindowName $ ".SkillProgressWnd2" );
		skillBarVisible( false, 1 );
		skillBarVisible( false, 2 );
	}
}*/

/**
 * 옵션용 타겟에 이상상태 표시 on/off
 */
function StateBoxShow( bool b )
{
	if( b == true )
	{
		BuffWnd.ShowWindow();
	}
	else
	{
		BuffWnd.HideWindow();
	}
}

// 타겟에서 , 마우스 오른쪽 버튼 클릭
function OnRButtonDown( WindowHandle a_WindowHandle, int X, int Y )
{
	// local UserInfo	info;
	local Rect      rectWnd;
	local int		TargetID;	
	local string    userName;
	local UserInfo  myInfo;
	// strParam = "";

	rectWnd = Me.GetRect();
	
	//타겟ID 얻어오기
	TargetID = class'UIDATA_TARGET'.static.GetTargetID();

	if (TargetID > 0)
	{		
		GetPlayerInfo(myInfo);
		// GetTargetInfo(info);

		if (X > rectWnd.nX && X < rectWnd.nX + rectWnd.nWidth) 
		{
			if (Y > rectWnd.nY && Y < rectWnd.nY + rectWnd.nHeight) 
			{
				// 컨텍스트 메뉴 구성을 위한 정보 save
				userName = class'UIDATA_USER'.static.GetUserName(TargetID);

				if (userName != "")	getInstanceContextMenu().execContextEvent(userName, TargetID, X, Y);				

				//Debug("myInfo.Name : " @ myInfo.Name);
				//Debug("userName    : " @ userName);
				//Debug("X : " @ X);
				//Debug("Y : " @ Y);
				//Debug("rectWnd.nX  : " @ rectWnd.nX );
				//Debug("rectWnd.nY  : " @ rectWnd.nY );
			}
		}
	}
}

function int getTargetID()
{
	return m_targetID;
}


/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	// PlayConsoleSound(IFST_WINDOW_CLOSE);	
	OnCloseButton();
}
 
defaultproperties
{
    m_WindowName="TargetStatusWnd"
}
