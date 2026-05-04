//class DetailStatusWnd extends UIScript;
class DetailStatusWnd extends UICommonAPI;

const DIALOG_DetailStatusWnd = 90005;
const NSTATUS_SMALLBARSIZE = 85;
const NSTATUS_BARHEIGHT = 12;

struct SubjobInfo
{
	var int		Id;
	var int		ClassID;
	var int		Level;
	var int		Type;
}; 

var String m_WindowName;
var int m_UserID;
var HennaInfo m_HennaInfo;
//var UserInfo currentUserInfo;

var WindowHandle		Me;

//Handle
var TextBoxHandle txtClassName;
var TextBoxHandle txtSP;
var TextBoxHandle txtName1;
var TextBoxHandle txtName2;
var TextBoxHandle txtHeadPledge;
var TextBoxHandle txtPledge;
var TextBoxHandle txtLvHead;
var TextBoxHandle txtLvName;
var TextBoxHandle txtHeadRank;
var TextBoxHandle txtRank;
var StatusBarHandle texHP;
var StatusBarHandle texMP;
var StatusBarHandle texExp;
var StatusBarHandle texCP;
var TextBoxHandle txtPhysicalAttack;
var TextBoxHandle txtPhysicalDefense;
var TextBoxHandle txtHitRate;
var TextBoxHandle txtCriticalRate;
var TextBoxHandle txtPhysicalAttackSpeed;
var TextBoxHandle txtMagicalAttack;
var TextBoxHandle txtMagicDefense;
var TextBoxHandle txtPhysicalAvoid;
var TextBoxHandle txtGmMoving;
var TextBoxHandle txtHeadMovingSpeed;
var TextBoxHandle txtMovingSpeed;
var TextBoxHandle txtHeadMagicCastingSpeed;
var TextBoxHandle txtMagicCastingSpeed;
var TextBoxHandle txtSTR;
var TextBoxHandle txtDEX;
var TextBoxHandle txtCON;
var TextBoxHandle txtINT;
var TextBoxHandle txtWIT;
var TextBoxHandle txtMEN;
var TextBoxHandle txtCriminalRate;
var TextBoxHandle txtPVP;
var TextBoxHandle txtSociality;
var TextBoxHandle txtRemainSulffrage;
var TextBoxHandle txtRaidPoint;
var TextureHandle texHero;
var TextureHandle texPledgeCrest;
var TextureHandle VitalityTex;
var TextBoxHandle txtLUC;
var TextBoxHandle txtCHA;

var TextBoxHandle txtAttrAttackType;
var TextBoxHandle txtAttrAttackValue;
var TextBoxHandle txtAttrDefenseValFire;
var TextBoxHandle txtAttrDefenseValWater;
var TextBoxHandle txtAttrDefenseValWind;
var TextBoxHandle txtAttrDefenseValEarth;
var TextBoxHandle txtAttrDefenseValHoly;
var TextBoxHandle txtAttrDefenseValUnholy;

var TextBoxHandle txtHeadSTR;
var TextBoxHandle txtHeadDEX;
var TextBoxHandle txtHeadCON;
var TextBoxHandle txtHeadINT;
var TextBoxHandle txtHeadWIT;
var TextBoxHandle txtHeadMEN;

var TextBoxHandle txtHeadLUC;
var TextBoxHandle txtHeadCHA;

var ButtonHandle AbilityOpen;

var StatusBarHandle texVP;//ldw

var AnimTextureHandle APActive;

var int MaxVitality; //ldw

//var int nCanUseAP; //ldw

var L2Util util;//bluesun 툴팁 제어 용



//------------------------------
//    클래스변경메인
//------------------------------
// 깜빡이는현재클래스, 이펙트
var AnimTextureHandle ClassChangeLightBig;

// 현재클래스텍스쳐
// 메인: l2ui_ct1.PlayerStatusWnd_ClassBgMain_Big  (빨강)
// 서브: l2ui_ct1.PlayerStatusWnd_ClassBgSub_Big   (청색)
var TextureHandle ClassBgMain_Big;

// 클래스마크텍스쳐
var TextureHandle ClassMarkBig;

//------------------------------
//     클래스변경버튼
//------------------------------
var AnimTextureHandle ClassChangeLightSmall1, ClassChangeLightSmall2, ClassChangeLightSmall3;

// 클래스배경텍스쳐1,2,3
var TextureHandle ClassBgMain_Small1, ClassBgMain_Small2, ClassBgMain_Small3;

// 클래스마크
var TextureHandle ClassMarkSmall1, ClassMarkSmall2, ClassMarkSmall3;

// 듀얼, 서브클래스변경버튼
var ButtonHandle ClassFrameBtn1, ClassFrameBtn2, ClassFrameBtn3;

// 섭잡정보
var array<SubjobInfo> subjobInfoArray;
var SubjobInfo beforeSubjobInfo;

// 현재활성화되어있는클래스
var int currentSubjobClassNum;

// 현재 듀얼 클래스 서브잡이 있는가?
var bool    isDualClass;

// 임시로 듀얼 클래스 , 서브잡 정보를 저장해서 창이 열릴때 마다 갱신 할때 사용한다.
// var string  saveUpdateSubjobInfoParam;

// 마지막으로 받은 서브잡, 듀얼 관련 이벤트 값 저장
// var int updateSubjobLastEvent;
/*
History: UObject::ProcessEvent <- (DamageText Transient.DamageText, Function Interface.DamageText.OnEvent) <- 
GFxUIManager::ExecuteUIEvent <- ID:580, param:Index=361 Param1=1209048809 Param2=1209050262 <- ExecuteUIEvent
<- NSystemMessageManager::EndSystemMessageParam <- NConsoleWnd::EndSystemMessageParam <- SystemMessagePacket <- 
UNetworkHandler::Tick <- Function Name=SystemMessagePa <- UGameEngine::Tick <- UpdateWorld <- MainLoop
 **/
 
var int race;
/**
 * OnRegisterEvent
 **/
function OnRegisterEvent()
{
	//Level과Exp는UserInfo패킷으로처리한다.
	RegisterEvent( EV_UpdateUserInfo );
	RegisterEvent( EV_UpdateHennaInfo );
	
	//JYLee, 의미없는 함수호출을 막기 위해 status 정보를 내 정보와 다른 캐릭터의 정보로 분리
	RegisterEvent( EV_UpdateMyHP );
	RegisterEvent( EV_UpdateMyMaxHP );
	RegisterEvent( EV_UpdateMyMP );
	RegisterEvent( EV_UpdateMyMaxMP );
	RegisterEvent( EV_UpdateMyCP );
	RegisterEvent( EV_UpdateMyMaxCP );

	// 활력업데이트
	RegisterEvent( EV_VitalityPointInfo );	

	// 다이얼로그( 서브클래스변경확인용)
	RegisterEvent( EV_DialogOK );
	RegisterEvent( EV_DialogCancel );

	//듀얼클래스및서브클래스리스트
	RegisterEvent(EV_NotifySubjob);
	// CurrentSubjobClassID=3 Count=3 SubjobID_1 SubjobClassID_1=44 SubjobLevel_1=55 SubjobType_1
	RegisterEvent(EV_CreatedSubjob);
	RegisterEvent(EV_ChangedSubjob);

// CurrentSubjobClassID=117 Count=3 SubjobID_1=1 SubjobClassID_1=3 SubjobLevel_1=55 SubjobType_1=0 SubjobID_2=1 SubjobClassID_2=73 SubjobLevel_2=55 SubjobType_2=1 SubjobID_3=1 SubjobClassID_3=131 SubjobLevel_3=55 SubjobType_3=2
	// 듀얼클래스및서브클래스리스트
	// const EV_NotifySubjob = 5310;
	// const EV_CreatedSubjob = 5311;
	// const EV_ChangedSubjob = 5312;
	// 길드그랜드마스터한테가서
	// 일회성퀘스트234 1
	// 일회성퀘스트235 1
	// 서브추가

	//branch
	// F2P 서비스 활력 개선 - gorillazin
	RegisterEvent(EV_VitalityEffectInfo);	
	//
	//end of branch
	
	//branch120703
	RegisterEvent(EV_ToggleDetailStatusWnd);
	
}

function OnLoad()
{
	SetClosingOnESC();
	
	InitializeCOD();

	Me.EnableWindow();

	// 클래스변경버튼비활성화
	initClassChangeButton(false);

	MaxVitality=GetMaxVitality();//ldw

	txtHeadRank.HideWindow();
	txtRank.HideWindow();

	//nCanUseAP = 0;
}
/*
function getCanUseAP( string param )
{
	local int GotAP, UsedAP;

	parseInt ( param ,"UsedAP", UsedAP) ;
	parseInt ( param ,"GotAP", GotAP) ;

	nCanUseAP = GotAP - UsedAP;
}	
*/

/*
function onCallUCFunction( string functionName, string param )
{
	switch ( functionName )
	{
		case "UpdateUseAP" :
			nCanUseAP = int(param);
			handleAbilityBtnTooltip();
		break;
	}
}


function handleAbilityBtnTooltip()
{
	local CustomTooltip T;
	local string tmpTooltipString;	

	T.MinimumWidth = 125; // 125 로 수정해야함

	util = L2Util(GetScript("L2Util"));//bluesun 커스터마이즈 툴팁 
	util.setCustomTooltip(T);//bluesun 커스터마이즈 툴팁	
	
	

//	Debug("handleAbilityBtnTooltip1");
	//버튼 활성		
	//어빌리티 포이트 : 몇 포인트 라는 메시지 		
	tmpTooltipString = MakeFullSystemMsg(GetSystemMessage(4194), String(nCanUseAP) );
	util.ToopTipInsertText( tmpTooltipString , false, false);
	AbilityOpen.SetTooltipCustomType(util.getCustomTooltip());//bluesun 커스터마이즈 툴팁
}
*/

function handleAbilityBtn( bool enable, int nCanUseAP )
{
	local CustomTooltip T;
	local string tmpTooltipString;	
	
	if( enable )
	{
		T.MinimumWidth = 125;
	}
	else
	{
		T.MinimumWidth = 180;
	}
	
	util = L2Util(GetScript("L2Util"));//bluesun 커스터마이즈 툴팁 
	util.setCustomTooltip(T);//bluesun 커스터마이즈 툴팁

	APActive.HideWindow();

	if( enable )
	{
		//버튼 활성
		GetTextureHandle( m_WindowName $ ".abilityIconSlotBlank").HideWindow();
		AbilityOpen.ShowWindow();
		//어빌리티 포이트 : 몇 포인트 라는 메시지
		tmpTooltipString = MakeFullSystemMsg(GetSystemMessage(4194),string( nCanUseAP) );		

		//Debug ( tmpTooltipString @ nCanUseAP ) ;
		if ( nCanUseAP > 0 ) 
		{
			APActive.ShowWindow();
			APActive.SetLoopCount( 999 );
			APActive.Play();
		}
		
//Debug ( "어빌리티 포인트 사용 가능 한 조건에 도달 했음 깜빡일 것" );
		util.ToopTipInsertText( tmpTooltipString , false, false);
		AbilityOpen.SetTooltipCustomType(util.getCustomTooltip());
	}
	else 
	{	
		AbilityOpen.HideWindow();
		GetTextureHandle( m_WindowName $ ".abilityIconSlotBlank").ShowWindow();
		//99레벨 이상, 노블레스일 때..............뭐뭐 하실 수 있습니다.... 라는 메시지 
		tmpTooltipString = GetSystemMessage(4195);
		util.ToopTipInsertText( tmpTooltipString , false, false);
		GetTextureHandle( m_WindowName $ ".abilityIconSlotBlank").SetTooltipCustomType(util.getCustomTooltip());
	}
}

/**
 * 클래스변경버튼비활성화
 **/ 
function initClassChangeButton (bool visibleFlag)
{
	local int i;

	// 버튼비활성화
	for (i = 1; i < 4; i++)
	{
		// 버튼비활성, 자물쇠보이도록세팅
		setClassTexture(i, "", "", false);
		
		GetButtonHandle( m_WindowName $ ".ClassFrameBtn" $ i ).DisableWindow();
		GetButtonHandle( m_WindowName $ ".ClassFrameBtn" $ i ).SetTexture("L2UI_ct1.Misc_DF_Blank",
																		  "L2UI_ct1.Misc_DF_Blank",
																		  "L2UI_ct1.Misc_DF_Blank");

		GetButtonHandle( m_WindowName $ ".ClassFrameBtn" $ i ).SetTooltipCustomType(subjobButtonToolTips(-1));

		if (visibleFlag) 
		{   

			// GetTextureHandle( m_WindowName $ ".ClassSlotBlank" $ i ).ShowWindow();
			// GetTextureHandle( m_WindowName $ ".ClassFrameBtn" $ i).ShowWindow();

		}
		else 
		{   
			// GetTextureHandle( m_WindowName $ ".ClassSlotBlank" $ i).HideWindow();
			// GetTextureHandle( m_WindowName $ ".ClassFrameBtn" $ i).HideWindow();			
		}
	}
}

function InitializeCOD()
{

	Me = GetWindowHandle( "DetailStatusWnd" );

	// 클래스변경깜빡이텍스쳐
	ClassChangeLightBig    = GetAnimTextureHandle (m_WindowName $ ".ClassChangeLightBig" );
	ClassChangeLightSmall1 = GetAnimTextureHandle( m_WindowName $ ".ClassChangeLightSmall1" );
	ClassChangeLightSmall2 = GetAnimTextureHandle( m_WindowName $ ".ClassChangeLightSmall2" );
	ClassChangeLightSmall3 = GetAnimTextureHandle( m_WindowName $ ".ClassChangeLightSmall3" );

	// 클래스변경배경텍스쳐
	ClassBgMain_Big    = GetTextureHandle( m_WindowName $ ".ClassBgMain_Big" );
	ClassBgMain_Small1 = GetTextureHandle( m_WindowName $ ".ClassBgMain_Small1" );
	ClassBgMain_Small2 = GetTextureHandle( m_WindowName $ ".ClassBgMain_Small2" );
	ClassBgMain_Small3 = GetTextureHandle( m_WindowName $ ".ClassBgMain_Small3" );

	// 클래스변경버튼	
	ClassFrameBtn1 = GetButtonHandle ( m_WindowName $ ".ClassFrameBtn1" );
	ClassFrameBtn2 = GetButtonHandle ( m_WindowName $ ".ClassFrameBtn2" );
	ClassFrameBtn3 = GetButtonHandle ( m_WindowName $ ".ClassFrameBtn3" );

	// 클래스변경마크
	ClassMarkBig    = GetTextureHandle( m_WindowName $ ".ClassMarkBig" );
	ClassMarkSmall1 = GetTextureHandle( m_WindowName $ ".ClassMarkSmall1" );
	ClassMarkSmall2 = GetTextureHandle( m_WindowName $ ".ClassMarkSmall2" );
	ClassMarkSmall3 = GetTextureHandle( m_WindowName $ ".ClassMarkSmall3" );

	txtClassName = GetTextBoxHandle (  m_WindowName $ ".txtClassName" );
	txtSP = GetTextBoxHandle( m_WindowName $ ".txtSP" );
	txtName1 = GetTextBoxHandle( m_WindowName $ ".txtName1" );
	txtName2 = GetTextBoxHandle( m_WindowName $ ".txtName2" );
	txtHeadPledge = GetTextBoxHandle( m_WindowName $ ".txtHeadPledge" );
	txtPledge = GetTextBoxHandle( m_WindowName $ ".txtPledge" );
	txtLvHead = GetTextBoxHandle( m_WindowName $ ".txtLvHead" );
	txtLvName = GetTextBoxHandle( m_WindowName $ ".txtLvName" );
	txtHeadRank = GetTextBoxHandle( m_WindowName $ ".txtHeadRank" );
	txtRank = GetTextBoxHandle( m_WindowName $ ".txtRank" );
	texHP = GetStatusBarHandle( m_WindowName $ ".texHP" );
	texMP = GetStatusBarHandle( m_WindowName $ ".texMP" );
	texExp = GetStatusBarHandle( m_WindowName $ ".texExp" );
	texCP = GetStatusBarHandle( m_WindowName $ ".texCP" );
	txtPhysicalAttack = GetTextBoxHandle( m_WindowName $ ".txtPhysicalAttack" );
	txtPhysicalDefense = GetTextBoxHandle( m_WindowName $ ".txtPhysicalDefense" );
	txtHitRate = GetTextBoxHandle( m_WindowName $ ".txtHitRate" );
	txtCriticalRate = GetTextBoxHandle( m_WindowName $ ".txtCriticalRate" );
	txtPhysicalAttackSpeed = GetTextBoxHandle( m_WindowName $ ".txtPhysicalAttackSpeed" );
	txtMagicalAttack = GetTextBoxHandle( m_WindowName $ ".txtMagicalAttack" );
	txtMagicDefense = GetTextBoxHandle( m_WindowName $ ".txtMagicDefense" );
	txtPhysicalAvoid = GetTextBoxHandle( m_WindowName $ ".txtPhysicalAvoid" );
	txtGmMoving = GetTextBoxHandle( m_WindowName $ ".txtGmMoving" );
	txtMovingSpeed = GetTextBoxHandle( m_WindowName $ ".txtMovingSpeed" );
	txtMagicCastingSpeed = GetTextBoxHandle( m_WindowName $ ".txtMagicCastingSpeed" );
	txtHeadMovingSpeed = GetTextBoxHandle( m_WindowName $ ".txtHeadMovingSpeed" );
	txtHeadMagicCastingSpeed = GetTextBoxHandle( m_WindowName $ ".txtHeadMagicCastingSpeed" );
	txtSTR = GetTextBoxHandle( m_WindowName $ ".txtSTR" );
	txtDEX = GetTextBoxHandle( m_WindowName $ ".txtDEX" );
	txtCON = GetTextBoxHandle( m_WindowName $ ".txtCON" );
	txtINT = GetTextBoxHandle( m_WindowName $ ".txtINT" );
	txtWIT = GetTextBoxHandle( m_WindowName $ ".txtWIT" );
	txtMEN = GetTextBoxHandle( m_WindowName $ ".txtMEN" );
	txtCriminalRate = GetTextBoxHandle( m_WindowName $ ".txtCriminalRate" );
	txtPVP = GetTextBoxHandle( m_WindowName $ ".txtPVP" );
	txtSociality = GetTextBoxHandle( m_WindowName $ ".txtSociality" );
	txtRemainSulffrage = GetTextBoxHandle( m_WindowName $ ".txtRemainSulffrage" );
	txtRaidPoint = GetTextBoxHandle( m_WindowName $ ".txtRaidPoint" );
	texHero = GetTextureHandle( m_WindowName $ ".texHero" );
	texPledgeCrest = GetTextureHandle( m_WindowName $ ".texPledgeCrest" );
	txtAttrAttackType = GetTextBoxHandle( m_WindowName $ ".txtAttrAttackType" );
	txtAttrAttackValue = GetTextBoxHandle( m_WindowName $ ".txtAttrAttackValue" );
	txtAttrDefenseValFire = GetTextBoxHandle( m_WindowName $ ".txtAttrDefenseValFire" );
	txtAttrDefenseValWater = GetTextBoxHandle( m_WindowName $ ".txtAttrDefenseValWater" );
	txtAttrDefenseValWind = GetTextBoxHandle( m_WindowName $ ".txtAttrDefenseValWind" );
	txtAttrDefenseValEarth = GetTextBoxHandle( m_WindowName $ ".txtAttrDefenseValEarth" );
	txtAttrDefenseValHoly = GetTextBoxHandle( m_WindowName $ ".txtAttrDefenseValHoly" );
	txtAttrDefenseValUnholy = GetTextBoxHandle( m_WindowName $ ".txtAttrDefenseValUnholy" );
	VitalityTex = GetTextureHandle( m_WindowName $ ".LifeForceTex") ;

	txtLUC = GetTextBoxHandle( m_WindowName $ ".txtLUC" );
	txtCHA = GetTextBoxHandle( m_WindowName $ ".txtCHA" );

	texVP = GetStatusBarHandle( m_WindowName $".texVP" );//ldw //branch121212

	AbilityOpen = GetButtonHandle( m_WindowName $ ".AbilityOpen" );//ldw

	txtHeadSTR = GetTextBoxHandle( "DetailStatusWnd.txtHeadSTR" );
	txtHeadDEX = GetTextBoxHandle( "DetailStatusWnd.txtHeadDEX" );
	txtHeadCON = GetTextBoxHandle( "DetailStatusWnd.txtHeadCON" );
	txtHeadINT = GetTextBoxHandle( "DetailStatusWnd.txtHeadINT" );
	txtHeadWIT = GetTextBoxHandle( "DetailStatusWnd.txtHeadWIT" );
	txtHeadMEN = GetTextBoxHandle( "DetailStatusWnd.txtHeadMEN" );
	txtHeadLUC = GetTextBoxHandle( "DetailStatusWnd.txtHeadLUC" );
	txtHeadCHA = GetTextBoxHandle( "DetailStatusWnd.txtHeadCHA" );

	txtHeadSTR.SetTooltipCustomType( MakeTooltipSimpleText( GetSystemString(3366), 154 ) );
	txtHeadDEX.SetTooltipCustomType( MakeTooltipSimpleText( GetSystemString(3368), 154 ) );
	txtHeadCON.SetTooltipCustomType( MakeTooltipSimpleText( GetSystemString(3370), 154 ) );
	txtHeadINT.SetTooltipCustomType( MakeTooltipSimpleText( GetSystemString(3367), 154 ) );
	txtHeadWIT.SetTooltipCustomType( MakeTooltipSimpleText( GetSystemString(3369), 154 ) );
	txtHeadMEN.SetTooltipCustomType( MakeTooltipSimpleText( GetSystemString(3371), 154 ) );

	txtHeadLUC.SetTooltipCustomType( MakeTooltipSimpleText( GetSystemString(3372), 154 ) );
	txtHeadCHA.SetTooltipCustomType( MakeTooltipSimpleText( GetSystemString(3373), 154 ) );

	APActive = GetAnimTextureHandle ( "DetailStatusWnd.APActive");

	isDualClass = false;
}

//branch
// F2P 서비스 활력 개선 - gorillazin
function UpdateVp (int Vitality )//ldw 수정
{
	//local CustomTooltip T;//bluesun 커스터마이즈 툴팁 
	//local string tmpStr;	

	if(Vitality < 2205 && Vitality > 0){ // 최대 140000 일 경우 1806 부터 스탯창에 눈금이 없어 vp가 없어 보인다는 수정 내용을 위한 예외 처리 , statusbarWnd, lobbyMenuWnd 에도 같이 처리 되었음 ldw 2011.02.23
		texVP.SetPoint(2205, MaxVitality);		

	} else {
		texVP.SetPoint(Vitality, MaxVitality);		
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
	//}
	//texVP.SetTooltipCustomType(util.getCustomTooltip());//bluesun 커스터마이즈 툴팁	
}
// 이 function의 필요 없는 부분 주석 처리
//end of branch


function OnEnterState( name a_PreStateName )
{
	HandleUpdateUserInfo();
}

function OnShow()
{
	HandleUpdateUserInfo();

	// 서브잡,듀얼 클래스 관련 버튼, 업데이트
	// EV_CreatedSubjob 일땐 업데이트 안하는 이유는 빤짝이는 효과가 중복으로 나오지 않게 하기 위해서..
	// if (updateSubjobLastEvent != EV_CreatedSubjob) updateSubjobInfo(saveUpdateSubjobInfoParam, EV_NotifySubjob);

	

}

function OnEvent(int Event_ID, string param)
{
	if (Event_ID == EV_UpdateUserInfo)
	{
		HandleUpdateUserInfo();		
	}
	else if (Event_ID == EV_UpdateHennaInfo)
	{
		HandleUpdateHennaInfo(param);
	}
	else if (Event_ID == EV_UpdateMyHP)
	{
		HandleUpdateStatusGauge(param, 0);
	}
	else if (Event_ID == EV_UpdateMyMaxHP)
	{
		HandleUpdateStatusGauge(param, 0);
	}
	else if (Event_ID == EV_UpdateMyMP)
	{
		HandleUpdateStatusGauge(param,1);
	}
	else if (Event_ID == EV_UpdateMyMaxMP)
	{
		HandleUpdateStatusGauge(param,1);
	}
	else if (Event_ID == EV_UpdateMyCP)
	{
		HandleUpdateStatusGauge(param,2);
	}
	else if (Event_ID == EV_UpdateMyMaxCP)
	{
		HandleUpdateStatusGauge(param,2);
	}
	else if(Event_ID == EV_ToggleDetailStatusWnd )
	{
		HandleToggle();
	}
	else if(Event_ID == EV_VitalityPointInfo)	// 활력정보업데이트
	{
		HandleVitalityPointInfo( param);
	}
	else if(Event_ID == EV_NotifySubjob)
	{
		//Debug("-------------------------------");
		//Debug("EV_NotifySubjob:" @ param);
		// updateSubjobLastEvent = Event_ID;
		updateSubjobInfo(param, Event_ID);	

	}
	else if(Event_ID == EV_CreatedSubjob)
	{		
		updateSubjobInfo(param, Event_ID);
		
		// 아레나 인 경우 자동 열기 기능을 사용 하지 않는다.
		if (Me.IsShowWindow() == false && !getInstanceUIData().getIsArenaServer())
		{
			Me.ShowWindow();
			Me.SetFocus();
		}
		ExecuteEvent(EV_NPCDialogWndHide);
	}
	else if(Event_ID == EV_ChangedSubjob)
	{
		// updateSubjobLastEvent = Event_ID;
		//Debug("EV_ChangedSubjob" @ param);
		updateSubjobInfo(param, Event_ID);
		ExecuteEvent(EV_NPCDialogWndHide);
	}

	else if	 (Event_ID == EV_DialogOK)
	{
		HandleDialogOK();
	}
	else if	 (Event_ID == EV_DialogCancel)
	{
		Me.EnableWindow();
		// Me.EnableWindow();
		
	}
	//~ else if (Event_ID == EV_ShowWindow)
	//~ {
		//~ if (param == DetailStatusWnd)
		//~ {
			//~ ToggleOpenCharInfoWnd();
		//~ }
	//~ }

	//branch
	// F2P 서비스 활력 개선 - gorillazin
	else if (Event_ID == EV_VitalityEffectInfo)
	{
		HandleVitalityEffectInfo(param);
	}
	//
	//end of branch
}

function hideAlchemyWindow(  string winName  ) 
{	
	if( class'UIAPI_WINDOW'.static.IsShowWindow(winName) )
	{
		class'UIAPI_WINDOW'.static.HideWindow(winName);
	}	
}

/**
 *  최초들어오는서브잡, 듀얼등의정보를받아기록한다.
 **/
function updateSubjobInfo (string param, int Event_ID)
{	
	local int count, i;

	local int currentSubjobClassID;
	
	local UserInfo myUserInfo;

	local bool bFlag;

	local SubjobInfo tempSubjobInfo;

	// 종족
	//local int  race;

	isDualClass = false;

	hideAlchemyWindow( "AlchemyItemConversionWnd");			
	hideAlchemyWindow( "AlchemyMixCubeWnd");

	// saveUpdateSubjobInfoParam = param;

	//GetMyUserInfo(myUserInfo);
	GetPlayerInfo(myUserInfo);


//	debug("현재 클래스 : " @ GetClassType ( myUserInfo.nSubClass ));
//	debug("현재전직상태: " @ GetClassTransferDegree( myUserInfo.nSubClass ));

	// 해당직업수를리턴받는다.
	ParseInt(param, "Count"  , count);
	
	// 현재중인클래스아이디
	ParseInt(param, "currentSubjobClassID", currentSubjobClassID);

//	debug("현재전직상태->: " @ GetClassTransferDegree( currentSubjobClassID ));
	//Debug("현재classID ->: " @ currentSubjobClassID);
	// 삭제
	if (subjobInfoArray.Length > 0)
	{
		subjobInfoArray.Remove(0, subjobInfoArray.Length);
	}

	bFlag = false;
		

	
	ParseInt(param, "Race", race);

//	debug("종족 race:" @ Race);
	//debug("종족이름 :" @ getRaceString(Race));

	// 서브잡리스트를받는다. (0메인, 서브듀얼개1,2,3(최대))
	for (i = 0; i < count; i++)
	{
		subjobInfoArray.Insert(subjobInfoArray.Length, 1);
		
		ParseInt(param, "SubjobClassID_" $ i, subjobInfoArray[i].ClassID);
		ParseInt(param, "SubjobID_"      $ i, subjobInfoArray[i].Id);
		ParseInt(param, "SubjobLevel_"   $ i, subjobInfoArray[i].Level);
		ParseInt(param, "SubjobType_"    $ i, subjobInfoArray[i].Type);

		// Debug("subjobInfoArray[i].ClassID" @ subjobInfoArray[i].ClassID);
		// Debug("subjobInfoArray[i].Id" @ subjobInfoArray[i].Id);
		// Debug("subjobInfoArray[i].Level" @ subjobInfoArray[i].Level);
		// Debug("subjobInfoArray[i].Type" @ subjobInfoArray[i].Type);

		// 듀얼 클래스가 하나라도 있다면..
		if (subjobInfoArray[i].Type == 1) 
		{ 
			isDualClass = true; 
		//	Debug("듀얼이 있다! ");
		}
	}
	for (i = 0; i < count; i++)
	{
		if (currentSubjobClassID == subjobInfoArray[i].ClassID)
		{
//			Debug("같다 subjobInfoArray[i].ClassID" @ subjobInfoArray[i].ClassID);
			//			currentSubjobClassNum = i;

			// 서로교체
			tempSubjobInfo = subjobInfoArray[i];
			subjobInfoArray[i] = subjobInfoArray[0];
			subjobInfoArray[0] = tempSubjobInfo;

			currentSubjobClassNum = 0;
			break;
		}
	}

//	debug("subjobInfoArray ::::: " @ subjobInfoArray.Length);

	// 서브 클래스가 있다면.. 버튼들이 보이도록 초기화
	if (count > 0) initClassChangeButton(true);
	else initClassChangeButton(false);

	// 직업정보업데이트
	//  1,2,3 까지들어올수있음. 현재캐릭터1 + 서버(듀얼) 3개= 총4개
	for (i = 1; i < 4; i++)
	{
		if (i < count)
		{
			// Debug("-------------" @ i);
//			Debug("subjobInfoArray[i].ClassID" @ subjobInfoArray[i].ClassID);
			//---- 3종버튼업데이트-----
			// Debug("버튼배치작은거" @ subjobInfoArray[i].ClassID);

			// 이전의상태와같은것이였다면.. 깜빡이는이팩트
			if(beforeSubjobInfo.ClassID == subjobInfoArray[i].ClassID) bFlag = true;
			else bFlag = false;

			// Debug("서브, 메인검사 subjobInfoArray[i].Type : " @subjobInfoArray[i].Type);
			// debug("GetClassTransferDegree( myUserInfo.nSubClass )"@ GetClassTransferDegree( myUserInfo.nSubClass ));
			// debug("종족 race:" @ myUserInfo.Race);
			// debug("종족이름 :" @ getRaceString(myUserInfo.Race));

			// 메인:0, 듀얼:1 서브:2

			// 서브: 청색
			if (subjobInfoArray[i].Type == 2)
			{
				if (GetClassTransferDegree( subjobInfoArray[i].ClassID ) > 1)
					setclasstexture(i, "l2ui_ct1.playerstatuswnd_ClassBgSub_Small", "l2ui_ct1.PlayerStatusWnd_ClassMark_" $ subjobInfoArray[i].ClassID $ "_Small", bFlag);
				else 
					setclasstexture(i, "l2ui_ct1.playerstatuswnd_ClassBgSub_Small", "l2ui_ct1.PlayerStatusWnd_ClassMark_" $ getRaceString(race) $ "_Small", bFlag);
			}			
			// 듀얼 : 파랑
			else if (subjobInfoArray[i].Type == 1)
			{	
				if (GetClassTransferDegree( subjobInfoArray[i].ClassID ) > 1)
					setClassTexture(i, "l2ui_ct1.PlayerStatusWnd_ClassBgDual_Small", "l2ui_ct1.PlayerStatusWnd_ClassMark_" $ subjobInfoArray[i].ClassID $ "_Small", bFlag);
				else
					setClassTexture(i, "l2ui_ct1.PlayerStatusWnd_ClassBgDual_Small", "l2ui_ct1.PlayerStatusWnd_ClassMark_" $ getRaceString(race) $ "_Small", bFlag);
			}
			//메인 :빨강
			else if (subjobInfoArray[i].Type == 0)
			{
				if (GetClassTransferDegree( subjobInfoArray[i].ClassID ) > 1)
					setClassTexture(i, "l2ui_ct1.PlayerStatusWnd_ClassBgMain_Small", "l2ui_ct1.PlayerStatusWnd_ClassMark_" $ subjobInfoArray[i].ClassID $ "_Small", bFlag);
				else
					setClassTexture(i, "l2ui_ct1.PlayerStatusWnd_ClassBgMain_Small", "l2ui_ct1.PlayerStatusWnd_ClassMark_" $ getRaceString(race) $ "_Small", bFlag);
			}

			GetButtonHandle( m_WindowName $ ".ClassFrameBtn" $ i).EnableWindow();
			GetButtonHandle( m_WindowName $ ".ClassFrameBtn" $ i).ShowWindow();

			// Debug("버튼 " @ m_WindowName $ ".ClassFrameBtn" $ i);
			// GetButtonHandle( m_WindowName $ ".ClassFrameBtn" $ i + 1).ShowWindow();

			GetButtonHandle( m_WindowName $ ".ClassFrameBtn" $ i).SetTexture("L2UI_ct1.PlayerStatusWnd_ClassFrameBtn",
																			 "L2UI_ct1.PlayerStatusWnd_ClassFrameBtn_down",
																			 "L2UI_ct1.PlayerStatusWnd_ClassFrameBtn_over");

			GetButtonHandle( m_WindowName $ ".ClassFrameBtn" $ i).SetTooltipCustomType(subjobButtonToolTips(i));
			GetTextureHandle( m_WindowName $ ".ClassSlotBlank" $ i ).HideWindow();
		}
		//아르 테이어 종족이 아닐 경우에만 보여 준다.
		else if ( race != 6 ) 
		{
			
			// Debug("------자물쇠 -------" @ i);
			// 버튼비활성, 자물쇠보이도록세팅
			setClassTexture(i, "", "", false);
			// GetButtonHandle( m_WindowName $ ".ClassFrameBtn" $ i + 1).HideWindow();
			
			GetButtonHandle( m_WindowName $ ".ClassFrameBtn" $ i ).DisableWindow();
			GetButtonHandle( m_WindowName $ ".ClassFrameBtn" $ i ).SetTexture("L2UI_ct1.Misc_DF_Blank",
																			  "L2UI_ct1.Misc_DF_Blank",
																			  "L2UI_ct1.Misc_DF_Blank");

			GetButtonHandle( m_WindowName $ ".ClassFrameBtn" $ i ).SetTooltipCustomType(subjobButtonToolTips(-1));			

			GetTextureHandle( m_WindowName $ ".ClassSlotBlank" $ i ).ShowWindow();
		}
	}

	// ---- 큰클래스이미지업데이트-----
	// 2차전직이상이라면..

	// 3차 전직 이상한 캐릭터가 있고 , 서브 잡 1개 이상 있다면, 지정한 클래스 아이콘을 적용
	//if (GetClassTransferDegree( myUserInfo.nSubClass ) > 1 && count > 1)

	// debug("myUserInfo.nSubClass >: " @ myUserInfo.nSubClass);
	// debug("GetClassTransferDegree( myUserInfo.nSubClass ) >: " @ GetClassTransferDegree( myUserInfo.nSubClass ));

	// 메인:0, 듀얼:1 서브:2
	// 4차 전직 된 캐릭터라면..
//	Debug("subjobInfoArray[currentSubjobClassNum].ClassID" @ subjobInfoArray[currentSubjobClassNum].ClassID);
	if (GetClassTransferDegree( subjobInfoArray[currentSubjobClassNum].ClassID ) > 1)
	{
		// 교체된상태라면이팩트출력
		if (EV_ChangedSubjob == Event_ID) bFlag = true;
		else bFlag = false;

		// debug("서브애들:" @ subjobInfoArray[currentSubjobClassNum].Type);
		// 서브면청색
		if (subjobInfoArray[currentSubjobClassNum].Type == 2)
		{
			setClassTexture(0, "l2ui_ct1.PlayerStatusWnd_ClassBgSub_Big", 
							   "l2ui_ct1.PlayerStatusWnd_ClassMark_" $ subjobInfoArray[currentSubjobClassNum].ClassID $ "_Big", bFlag);
			
		}
		// 듀얼,메인은빨강0: 메인, 1 듀얼
		else if (subjobInfoArray[currentSubjobClassNum].Type == 1)
		{			
			setClassTexture(0, "l2ui_ct1.PlayerStatusWnd_ClassBgDual_Big", 
							   "l2ui_ct1.PlayerStatusWnd_ClassMark_" $ subjobInfoArray[currentSubjobClassNum].ClassID $ "_Big", bFlag);
			
		}
		else if(subjobInfoArray[currentSubjobClassNum].Type == 0)
		{
			setClassTexture(0, "l2ui_ct1.PlayerStatusWnd_ClassBgMain_Big", 
							   "l2ui_ct1.PlayerStatusWnd_ClassMark_" $ subjobInfoArray[currentSubjobClassNum].ClassID $ "_Big", bFlag);

		}

	}
	else
	{
		// 서브면청색
		if (subjobInfoArray[currentSubjobClassNum].Type == 2)
		{
			setClassTexture(0, "l2ui_ct1.PlayerStatusWnd_ClassBgSub_Big", 
							   "l2ui_ct1.PlayerStatusWnd_ClassMark_" $ getRaceString(race) $ "_Big", false);
			
		}
		// 듀얼,메인은빨강0: 메인, 1 듀얼
		else if (subjobInfoArray[currentSubjobClassNum].Type == 1 )
		{			
				
			// 서브잡을 안한.. 1차 전직도 안한 유저의 아이콘
			//initClassChangeButton(false);
			// 각종족별심볼이미지
			setClassTexture(0, "l2ui_ct1.PlayerStatusWnd_ClassBgDual_Big", 
							   "l2ui_ct1.PlayerStatusWnd_ClassMark_" $ getRaceString(race) $ "_Big", false);		
		}
		else if (subjobInfoArray[currentSubjobClassNum].Type == 0)
		{
			setClassTexture(0, "l2ui_ct1.PlayerStatusWnd_ClassBgMain_Big", 
							   "l2ui_ct1.PlayerStatusWnd_ClassMark_" $ getRaceString(race) $ "_Big", false);		

		}
		
		// UserInfo(
		// 수정해야함race
		// Debug("종족별---::" @ myUserInfo.race);
		
		//GetRaceTicketString( int Blessed );
	}

	beforeSubjobInfo = subjobInfoArray[currentSubjobClassNum];

	// Type : 0 메인, 1 듀얼. 2 서브
	// debug("myUserInfo.Class : " @ GetClassRoleName(classID) );
	
		//native final function string GetClassRoleName(classID) ;
	// CurrentSubjobClassID=3 Count=3 SubjobID_1=1 SubjobClassID_1=117 SubjobLevel_1=55 SubjobType_1=0 SubjobID_2=1 SubjobClassID_2=73 SubjobLevel_2=55 SubjobType_2=1 SubjobID_3=1 SubjobClassID_3=131 SubjobLevel_3=55 SubjobType_3=2
	// CurrentSubjobClassID=3 Count=3 SubjobID_1=1 SubjobClassID_1=117 SubjobLevel_1=55 SubjobType_1=1 SubjobID_2=1 SubjobClassID_2=73 SubjobLevel_2=55 SubjobType_2=1 SubjobID_3=1 SubjobClassID_3=131 SubjobLevel_3=55 SubjobType_3=1 
	// CurrentSubjobClassID=3 Count=1 SubjobID_1=1 SubjobClassID_1=134 SubjobLevel_1=55 SubjobType_1=1
}

/** 다이얼로그박스OK 클릭시*/
function HandleDialogOK()
{
	local int dialogValue;
	local ItemInfo infItem;

	
	if (DialogIsMine())
	{
		if( DialogGetID() == DIALOG_DetailStatusWnd )
		{					
			
			dialogValue = DialogGetReservedInt();
			
			switch(dialogValue)
			{
				// subjobInfoArray[dialogValue].Type  // 0메인, 1듀얼, 2서브
				case 0 : 
				case 1 : 
				case 2 : 
				case 3 :
						ExecuteEvent(EV_NPCDialogWndHide);
						// Debug("subjobInfoArray[dialogValue].Type  "  @ subjobInfoArray[dialogValue].Type );
						// 메인, 듀얼이라면..
						if (subjobInfoArray[dialogValue].Type == 0)
						{
							// 스킬 번호임 
							infItem.ID.ClassID = 1566;

							//infItem.ID.ServerID = 1566;
							// 메인클래스로변경
							// Debug("메인 스킬사용" @ infItem.ID.ClassID);
							UseSkill(infItem.ID, int(EShortCutItemType.SCIT_SKILL));
							// ExecuteCommand("//use_skill 1566 1");
						}
						else
						{
							// 듀얼 이라면.. 처리
							if(subjobInfoArray[dialogValue].Type == 1) 
							{
								// 현재 없음
								// empty
							}

							// 1567, 1568, 1569 순서되로.. 서브슬롯1,2,3 변경
							infItem.ID.ClassID = 1567 + (dialogValue - 1);
							//infItem.ID.ServerID = 1568 + (dialogValue - 1);

							// Debug("스킬사용" @ infItem.ID.ClassID);
							UseSkill(infItem.ID, int(EShortCutItemType.SCIT_SKILL));
							// ExecuteCommand("//use_skill " $ String(infItem.ID.ClassID) $ " 1");
						}
			}

			// 변경스킬사용
			Me.EnableWindow();
		}
	}
}

/**
 * 다이얼로그박스(서브클래스로변신할지물어보는다이얼로그)
 * 0..1..2 
 **/
function askDialogBox (int currentClickSubjobNum)
{
	local WindowHandle m_dialogWnd;	
	m_dialogWnd = GetWindowHandle( "DialogBox" );
	if( !m_dialogWnd.IsShowWindow())
	{
		// 현재클래스와클릭한서브클래스가같지않다면.. 변신을물어본다.
		if (subjobInfoArray[0].ClassID != subjobInfoArray[currentClickSubjobNum].ClassID)
		{
			DialogSetID( DIALOG_DetailStatusWnd );

			DialogSetReservedInt( currentClickSubjobNum );

			// 메인클래스, 둠브링거, 서브소울테이커, 로변경하시겠습니까?   이런식
			Me.DisableWindow();
			DialogSetCancelD(DIALOG_DetailStatusWnd);
			DialogShow(DialogModalType_Modalless, DialogType_Warning, 
						MakeFullSystemMsg( GetSystemMessage(3280), 
										   "<" $ GetClassType(subjobInfoArray[0].ClassID) $ "> " $ getSubjobTypeStr(subjobInfoArray[0].Type) $ "", 
										   "<" $ GetClassType(subjobInfoArray[currentClickSubjobNum].ClassID) $ "> "$ getSubjobTypeStr(subjobInfoArray[currentClickSubjobNum].Type) $ ""),
										   string(Self));
		}
	}
}


/***
 *  현재서브잡스트링을리턴받는다.
 **/
function string getSubjobTypeStr(int nType)
{	
	local string tempStr;
	
	// 0 메인, 1 듀얼(현재는메인으로처리-듀얼이라는용어는아직사용안함) , 2 서브
	switch (nType)
	{
		case 0 : tempStr = GetSystemString(2340); break; // 메인클래스
		case 1 : tempStr = GetSystemString(2737); break; // 듀얼클래스
		case 2 : tempStr = GetSystemString(2339); break; // 서브클래스
	}

	return tempStr;
}

/**
 * OnClickButton
 **/
function OnClickButton( string strID )
{
	// debug("strID : " $ strID);
	switch( strID )
	{
		case "AbilityOpen":
			if ( class'UIAPI_WINDOW'.static.IsShowWindow ("AbilityWnd") )
			{
				class'UIAPI_WINDOW'.static.HideWindow("AbilityWnd");
			}
			else
			{
				class'UIAPI_WINDOW'.static.ShowWindow("AbilityWnd");
			}

			break;


		case "ClassFrameBtn1" : if (GetButtonHandle( m_WindowName $ ".ClassFrameBtn1").IsEnableWindow() && subjobInfoArray.Length > 1) 
								{ ExecuteEvent(EV_NPCDialogWndHide); effectAniTexture(1); askDialogBox(1); } break;
		case "ClassFrameBtn2" : if (GetButtonHandle( m_WindowName $ ".ClassFrameBtn2").IsEnableWindow() && subjobInfoArray.Length > 2) 
								{ ExecuteEvent(EV_NPCDialogWndHide); effectAniTexture(2); askDialogBox(2); } break;
		case "ClassFrameBtn3" : if (GetButtonHandle( m_WindowName $ ".ClassFrameBtn3").IsEnableWindow() && subjobInfoArray.Length > 3) 
								{ ExecuteEvent(EV_NPCDialogWndHide); effectAniTexture(3); askDialogBox(3); } break;
	}

	 
}

/**
 *  버튼애니이팩트(1 ~ 3 번버튼효과) 
 **/
function effectAniTexture(int targetType)
{
	GetAnimTextureHandle(m_WindowName $ ".ClassChangeLightSmall" $ targetType).SetTexture("l2ui_ct1.PlayerStatusWnd_ClassChangeLightSmall_00");
	GetAnimTextureHandle(m_WindowName $ ".ClassChangeLightSmall" $ targetType).ShowWindow();
	GetAnimTextureHandle(m_WindowName $ ".ClassChangeLightSmall" $ targetType).SetLoopCount(1);
	GetAnimTextureHandle(m_WindowName $ ".ClassChangeLightSmall" $ targetType).Stop();
	GetAnimTextureHandle(m_WindowName $ ".ClassChangeLightSmall" $ targetType).Play();
}

/**
 * setClassTexture 
 * 
 * 클래스변경시, 텍스쳐교체, 종족별마크텍스쳐, 빤짝거리는효과보여줄것인지..
 **/
function setClassTexture(int targetType, string bgTexture, string markTextureStr, bool effectFlag)
{
	if (targetType == 0)
	{

		// 큰메인클래스(현재클래스)

		// 배경
		ClassBgMain_Big.SetTexture(bgTexture);
		// debug("bgTexture" @ bgTexture);

		// 마크변경
		//debug("markTextureStr : " @ markTextureStr);
		ClassMarkBig.SetTexture(markTextureStr);
		// ClassMarkBig.HideWindow();

		// 깜빡이는효과보여주기
		if (effectFlag == true)
		{			
			GetAnimTextureHandle(m_WindowName $ ".ClassChangeLightBig").SetTexture("l2ui_ct1.PlayerStatusWnd_ClassChangeLightBig_00");
			GetAnimTextureHandle(m_WindowName $ ".ClassChangeLightBig").ShowWindow();
			GetAnimTextureHandle(m_WindowName $ ".ClassChangeLightBig").SetLoopCount(1);
			GetAnimTextureHandle(m_WindowName $ ".ClassChangeLightBig").Stop();
			GetAnimTextureHandle(m_WindowName $ ".ClassChangeLightBig").Play();
		}
	}
	else
	{
		// 배경
		GetTextureHandle( m_WindowName $ ".ClassBgMain_Small" $ targetType).SetTexture(bgTexture);
		
		// GetTextureHandle( m_WindowName $ ".ClassBgMain_Small" $ targetType).SetAlpha(255);
		// Debug("배경bgTexture " @ bgTexture);

		// 마크변경
		GetTextureHandle( m_WindowName $ ".ClassMarkSmall" $ targetType).SetTexture(markTextureStr);
		GetTextureHandle( m_WindowName $ ".ClassMarkSmall" $ targetType).ShowWindow();
		

		// 깜빡이는효과보여주기
		//GetTextureHandle( m_WindowName $ ".ClassChangeLightSmall" $ targetType).SetTexture("");		

		if (effectFlag == true)
		{			
			effectAniTexture(targetType);
		}
	}
}


function HandleToggle()
{
	if ( getInstanceUIData().getIsClassicServer() ) return;
	if( m_hOwnerWnd.IsShowWindow() )
	{
		m_hOwnerWnd.HideWindow();
	}
	else
	{
		m_hOwnerWnd.ShowWindow();
		m_hOwnerWnd.SetFocus();
	}
}

//~ function ToggleOpenCharInfoWnd()
//~ {
	//~ if(DetailStatusWnd.IsShowWindow() == true)
	//~ {
		//~ HideWindow("DetailStatusWnd");
		//~ PlaySound("InterfaceSound.charstat_close_01");
	//~ }
	//~ else
	//~ {
		//~ ShowWindowWithFocus("DetailStatusWnd");
		//~ PlaySound("InterfaceSound.charstat_open_01");			
	//~ }
//~ }

//게이지만업데이트
function HandleUpdateStatusGauge(string param, int Type)
{
	local int ServerID;
	
	if( m_hOwnerWnd.IsShowWindow() )	// lpislhy
	{
		ParseInt( param, "ServerID", ServerID );
		if( m_UserID == ServerID )
			HandleUpdateUserGauge( Type );
	}
}

//플레이어의문양정보처리
function HandleUpdateHennaInfo(string param)
{
	ParseInt(param, "HennaID", m_HennaInfo.HennaID);
	ParseInt(param, "ClassID", m_HennaInfo.ClassID);
	ParseInt(param, "Num", m_HennaInfo.Num);
	ParseInt(param, "Fee", m_HennaInfo.Fee);
	ParseInt(param, "CanUse", m_HennaInfo.CanUse);
	ParseInt(param, "INTnow", m_HennaInfo.INTnow);
	ParseInt(param, "INTchange", m_HennaInfo.INTchange);
	ParseInt(param, "STRnow", m_HennaInfo.STRnow);
	ParseInt(param, "STRchange", m_HennaInfo.STRchange);
	ParseInt(param, "CONnow", m_HennaInfo.CONnow);
	ParseInt(param, "CONchange", m_HennaInfo.CONchange);
	ParseInt(param, "MENnow", m_HennaInfo.MENnow);
	ParseInt(param, "MENchange", m_HennaInfo.MENchange);
	ParseInt(param, "DEXnow", m_HennaInfo.DEXnow);
	ParseInt(param, "DEXchange", m_HennaInfo.DEXchange);
	ParseInt(param, "WITnow", m_HennaInfo.WITnow);
	ParseInt(param, "WITchange", m_HennaInfo.WITchange);

	//신규스탯 카리스마 럭키
	ParseInt(param, "LUCnow", m_HennaInfo.LUCnow);
	ParseInt(param, "LUCchange", m_HennaInfo.LUCchange);

	ParseInt(param, "CHAnow", m_HennaInfo.CHAnow);
	ParseInt(param, "CHAchange", m_HennaInfo.CHAchange);
}

function bool GetMyUserInfo( out UserInfo a_MyUserInfo )
{
	return GetPlayerInfo( a_MyUserInfo );
}

function String GetMovingSpeed( UserInfo a_UserInfo )
{
	local float MovingSpeed;
	local EMoveType	MoveType;
	local EEnvType	EnvType;

	// Moving Speed
	MoveType			= class'UIDATA_PLAYER'.static.GetPlayerMoveType();
	EnvType				= class'UIDATA_PLAYER'.static.GetPlayerEnvironment();

	// debug("MovingSpeed : STEP 1" $a_UserInfo.fNonAttackSpeedModifier);
	if (MoveType == MVT_FAST)
	{
		MovingSpeed = float(a_UserInfo.nGroundMaxSpeed) * a_UserInfo.fNonAttackSpeedModifier;
		// debug("MovingSpeed : STEP 2" $a_UserInfo.nGroundMaxSpeed);
		switch (EnvType)
		{
		case ET_UNDERWATER:
			MovingSpeed = float(a_UserInfo.nWaterMaxSpeed) * a_UserInfo.fNonAttackSpeedModifier;
			// debug("MovingSpeed : STEP 3"$a_UserInfo.nWaterMaxSpeed );
			break;
		case ET_AIR:
			MovingSpeed = float(a_UserInfo.nAirMaxSpeed) * a_UserInfo.fNonAttackSpeedModifier;
			// debug("MovingSpeed : STEP 4" $a_UserInfo.nAirMaxSpeed $"  " $a_UserInfo.fNonAttackSpeedModifier);
			break;
		}
	}
	else if (MoveType == MVT_SLOW)
	{
		MovingSpeed = float(a_UserInfo.nGroundMinSpeed) * a_UserInfo.fNonAttackSpeedModifier;
		// debug("MovingSpeed : STEP 5" );
		switch (EnvType)
		{
		case ET_UNDERWATER:
			MovingSpeed = float(a_UserInfo.nWaterMinSpeed) * a_UserInfo.fNonAttackSpeedModifier;
			// debug("MovingSpeed : STEP 6" $a_UserInfo.nWaterMinSpeed);
			break;
		case ET_AIR:
			MovingSpeed = float(a_UserInfo.nAirMinSpeed) * a_UserInfo.fNonAttackSpeedModifier;
			// debug("MovingSpeed : STEP 7" $a_UserInfo.nAirMinSpeed);
			break;
		}
	}
	//debug("MovingSpeed : STEP 8 : " $ MovingSpeed);
	return String( int(MovingSpeed));
}

function float GetMyExpRate()
{
	return class'UIDATA_PLAYER'.static.GetPlayerEXPRate() * 100.0f;
}

//플레이어게이지정보처리
function HandleUpdateUserGauge( int Type )
{
	local int CurValue;
	local int MaxValue;
	local int Vitality;	
	local UserInfo info;

	
	if (GetMyUserInfo(info))
	{
		Vitality = info.nVitality;
		m_UserID = info.nID;
		
		switch( Type )
		{
		case 0:
			CurValue = info.nCurHP;
			MaxValue = info.nMaxHP;
			UpdateHPBar(CurValue, MaxValue);
		break;
		case 1:
			CurValue = info.nCurMP;
			MaxValue = info.nMaxMP;
			UpdateMPBar(CurValue, MaxValue);
		break;
		case 2:
			CurValue = info.nCurCP;
			MaxValue = info.nMaxCP;
			UpdateCPBar(CurValue, MaxValue);
		break;

		UpdateVp(Vitality);
		}
	}
}

//플레이어정보처리
function HandleUpdateUserInfo()
{
	if( m_hOwnerWnd.IsShowWindow() )	// lpislhy
		UpdateInterface();
}


function setSubjobSlot( bool isEr ) 
{
	local Rect rectWnd;
	rectWnd = m_hOwnerWnd.GetRect();


	if ( isEr )
	{		
		GetTextureHandle( m_WindowName $ ".ClassSlotBlank1" ).MoveTo( rectWnd.nX + 234, rectWnd.nY + 95);
		ClassBgMain_Small1.MoveTo(rectWnd.nX +  236, rectWnd.nY + 98);
		ClassMarkSmall1.MoveTo(rectWnd.nX +  236, rectWnd.nY + 98);
		ClassFrameBtn1.MoveTo(rectWnd.nX + 236, rectWnd.nY + 98);

		/*
		GetTextureHandle( m_WindowName $ ".ClassSlotBlank2" ).MoveTo( rectWnd.nX + 234, rectWnd.nY + 95);
		ClassBgMain_Small2.MoveTo(rectWnd.nX +  236, rectWnd.nY + 98);
		ClassMarkSmall2.MoveTo(rectWnd.nX +  236, rectWnd.nY + 98);
		ClassFrameBtn2.MoveTo(rectWnd.nX +  236, rectWnd.nY + 98);
		ClassChangeLightSmall2.MoveTo(rectWnd.nX +  236, rectWnd.nY + 98);
		GetTextureHandle( m_WindowName $ ".ClassSlotBlank3" ).MoveTo( rectWnd.nX + 234, rectWnd.nY + 95);
		ClassBgMain_Small3.MoveTo(rectWnd.nX +  236, rectWnd.nY + 98);
		ClassMarkSmall3.MoveTo(rectWnd.nX +  236, rectWnd.nY + 98);
		ClassFrameBtn3.MoveTo(rectWnd.nX +  236, rectWnd.nY + 98);
		ClassChangeLightSmall3.MoveTo(rectWnd.nX +  236, rectWnd.nY + 98);
*/
		
		GetTextureHandle( m_WindowName $ ".ClassSlotBlank2" ).hideWindow();
		ClassBgMain_Small2.hideWindow();
		ClassMarkSmall2.hideWindow();
		ClassFrameBtn2.hideWindow();
		ClassChangeLightSmall2.hideWindow();
		GetTextureHandle( m_WindowName $ ".ClassSlotBlank3" ).hideWindow();
		ClassBgMain_Small3.hideWindow();
		ClassMarkSmall3.hideWindow();
		ClassFrameBtn3.hideWindow();
		ClassChangeLightSmall3.hideWindow();

	}
	else 
	{
		//class'UIAPI_WINDOW'.static.MoveTo(m_WindowName $ ".ClassSlotBlank1", rectWnd.nX + 10, 10);		
		
		GetTextureHandle( m_WindowName $ ".ClassSlotBlank1" ).MoveTo(rectWnd.nX + 188, rectWnd.nY + 95);
		ClassBgMain_Small1.MoveTo(rectWnd.nX + 190, rectWnd.nY + 98);
		ClassMarkSmall1.MoveTo(rectWnd.nX + 190, rectWnd.nY + 98);
		ClassFrameBtn1.MoveTo(rectWnd.nX + 190, rectWnd.nY + 98);
		//ClassChangeLightSmall1.SetAnchor(0

		GetTextureHandle( m_WindowName $ ".ClassSlotBlank2" ).showWindow();
		ClassBgMain_Small2.showWindow();
		ClassMarkSmall2.showWindow();
		ClassFrameBtn2.showWindow();
		ClassChangeLightSmall2.showWindow();
		GetTextureHandle( m_WindowName $ ".ClassSlotBlank3" ).showWindow();
		ClassBgMain_Small3.showWindow();
		ClassMarkSmall3.showWindow();
		ClassFrameBtn3.showWindow();
		ClassChangeLightSmall3.showWindow();
	}
}

function UpdateInterface()
{
	local Rect rectWnd;
	local int Width1;
	local int Height1;
	local int Width2;
	local int Height2;
	
	local string	Name;
	local string	NickName;
	local color	NameColor;
	local color	NickNameColor;
	local int		SubClassID;
	local string	ClassName;
	local string	UserRank;
	local int		HP;
	local int		MaxHP;
	local int		MP;
	local int		MaxMP;
	local int		CP;
	local int		MaxCP;
	local INT64		SP;
	local int		Level;
	//local float		fExpRate;
	
	local int		PledgeID;
	local string	PledgeName;
	local texture	PledgeCrestTexture;
	local bool		bPledgeCrestTexture;
	local color	PledgeNameColor;
	
	local string	HeroTexture;
	local bool		bHero;
	local int		nNobless;
	
	local int		nSTR;
	local int		nDEX;
	local int		nCON;
	local int		nINT;
	local int		nWIT;
	local int		nMEN;
	local string	strTmp;
	//신규스탯 카리스마 럭키
	local int		nLUC;
	local int		nCHA;
	
	local int		PhysicalAttack;
	local int		PhysicalDefense;
	local int		HitRate;
	local int		CriticalRate;
	local int		PhysicalAttackSpeed;
	local int		MagicalAttack;
	local int		MagicDefense;
	local int		PhysicalAvoid;
	local String	MovingSpeed;
	local int		MagicCastingSpeed;
	
	local int		CriminalRate;
	local int		iNameColorRate;
	local string	strCriminalRate;
	local int		DualCount;
	local int		PKCount;
	local int		PvPPoint;
	
	local int		Sociality;
	local int		RemainSulffrage;

	local int       RaidPoint;
	
	
	// 속성수치
	local int AttrAttackType;
	local int AttrAttackValue;
	local int AttrDefenseValFire;
	local int AttrDefenseValWater;
	local int AttrDefenseValWind;
	local int AttrDefenseValEarth;
	local int AttrDefenseValHoly;
	local int AttrDefenseValUnholy;
	local string AttrAttackTypeTxt;

	local int nMagicAvoid, nMagicHitRate, nMagicCriticalRate;

	
	//변신관련데이터
	//local int nTransformID;
	local bool m_bPawnChanged;
	
	local UserInfo	info;
	
	//활력
	local int Vitality;
	
	//초기화
	texPledgeCrest.SetTexture("");
	
	rectWnd = m_hOwnerWnd.GetRect();
	
	
	if (GetMyUserInfo(info))
	{

		// ClassChangeLightBig.SetTexture("");
		// ClassChangeLightSmall1.SetTexture("");
		// ClassChangeLightSmall2.SetTexture("");
		//ClassChangeLightSmall3.SetTexture(""); 
		// Debug("info race"  @ info.race);

		m_UserID = info.nID;
		
		Name = info.Name;
		NickName = info.strNickName;
		SubClassID = info.nSubClass;
		ClassName = GetClassType(SubClassID);
		//ClassName = GetClassType(info.Class);
		
		SP = info.nSP;
		Level = info.nLevel;
		UserRank = GetUserRankString(info.nUserRank);
		HP = info.nCurHP;
		MaxHP = info.nMaxHP;
		MP = info.nCurMP;
		MaxMP = info.nMaxMP;
		CP = info.nCurCP;
		MaxCP = info.nMaxCP;
		//fExpRate = GetMyExpRate();
		
		PledgeID = info.nClanID;
		bHero = info.bHero;
		nNobless = info.nNobless;
		NickNameColor = info.NicknameColor;
		
		//플레이어상세정보
		nSTR	= info.nStr;
		nDEX	= info.nDex;
		nCON	= info.nCon;
		nINT	= info.nInt;
		nWIT	= info.nWit;
		nMEN	= info.nMen;
		
		//신규스탯 카리스마, 럭키
		nLUC    = info.nLuc;
		nCHA    = info.nCha;

		
		PhysicalAttack			= info.nPhysicalAttack;
		PhysicalDefense		= info.nPhysicalDefense;
		HitRate				= info.nHitRate;
		CriticalRate			= info.nCriticalRate;
		PhysicalAttackSpeed	= info.nPhysicalAttackSpeed;
		MagicalAttack			= info.nMagicalAttack;
		MagicDefense			= info.nMagicDefense;
		PhysicalAvoid			= info.nPhysicalAvoid;
		MagicCastingSpeed		= info.nMagicCastingSpeed;
		
		MovingSpeed = GetMovingSpeed( info );
		
		CriminalRate		= info.nCriminalRate;
		DualCount		= info.nDualCount;
		PKCount			= info.nPKCount;
		PvPPoint			= info.PvPPoint;
		Sociality			= info.nSociality;
		RemainSulffrage	= info.nRemainSulffrage;

		RaidPoint = info.RaidPoint;
		
		Vitality = info.nVitality;
		
		//속성정보세팅
		
		AttrAttackType = info.AttrAttackType;
		//debug( "속성타입번호" @ info.AttrAttackType);
		AttrAttackValue= info.AttrAttackValue;
		AttrDefenseValFire = info.AttrDefenseValFire;
		AttrDefenseValWater = info.AttrDefenseValWater;
		AttrDefenseValWind = info.AttrDefenseValWind;
		AttrDefenseValEarth = info.AttrDefenseValEarth;
		AttrDefenseValHoly = info.AttrDefenseValHoly;
		AttrDefenseValUnholy = info.AttrDefenseValUnholy;

		//변신정보세팅
		//nTransformID = info.nTransformID;
		m_bPawnChanged = info.m_bPawnChanged;

		// 신규 추가  2010.10.11 CT3 스탯 정보 개선
		nMagicAvoid = info.nMagicAvoid; 
		nMagicHitRate = info.nMagicHitRate; 
		nMagicCriticalRate = info.nMagicCriticalRate; 

		

		// debug("nMagicAvoid:"@ nMagicAvoid);
		// debug("nMagicHitRate:"@ nMagicHitRate);
		// debug("nMagicCriticalRate:"@ nMagicCriticalRate);

		//~ debug ("속성정보: " @ AttrAttackType );
		//~ debug ("속성정보: " @  AttrAttackValue);
		//~ debug ("속성정보: " @  AttrDefenseValFire);
		//~ debug ("속성정보: " @  AttrDefenseValWater );
		//~ debug ("속성정보: " @  AttrDefenseValWind );
		//~ debug ("속성정보: " @ AttrDefenseValEarth );
		//~ debug ("속성정보: " @ AttrDefenseValHoly );
		//~ debug ("속성정보: " @ AttrDefenseValUnholy);
		
		Switch(AttrAttackType)
		{
			case -2:
				AttrAttackTypeTxt = GetSystemString(27);
				break;
			case 0:
				AttrAttackTypeTxt = GetSystemString(1630);
				break;
			case 1:
				AttrAttackTypeTxt = GetSystemString(1631);
				break;
			case 2:
				AttrAttackTypeTxt = GetSystemString(1632);
				break;
			case 3:
				AttrAttackTypeTxt = GetSystemString(1633);
				break;
			case 4:
				AttrAttackTypeTxt = GetSystemString(1634);
				break;
			case 5:
				AttrAttackTypeTxt = GetSystemString(1635);
				break;
		}
		
		//debug ("활력도:" @ Vitality);
		UpdateVp (Vitality );
		
		//~ switch(Vitality)
		//~ {
			//~ case 0:
			//~ VitalityTex.SetTexture("l2ui_ct1.Icon_df_LifeForce_01");
			//~ break;
			//~ case 1:
			//~ VitalityTex.SetTexture("l2ui_ct1.Icon_df_LifeForce_02");
			//~ break;
			//~ case 2:
			//~ VitalityTex.SetTexture("l2ui_ct1.Icon_df_LifeForce_03");
			//~ break;
			//~ case 3:
			//~ VitalityTex.SetTexture("l2ui_ct1.Icon_df_LifeForce_04");
			//~ break;
			//~ case 4:
			//~ VitalityTex.SetTexture("l2ui_ct1.Icon_df_LifeForce_05");
			//~ break;
			//~ case 5:
			//~ VitalityTex.SetTexture("l2ui_ct1.Icon_df_LifeForce_01");
			//~ break;
		//~ }
		

		//아르테이어 종족일 경우 
		setSubjobSlot ( info.Race == 6 ) ;
					
	}     
	
	// Change by JoeyPark
	if( CriminalRate > 0 )
	{
		iNameColorRate = Min( ( 100 + ( CriminalRate / 100 ) ), 255 );
		NameColor.R = 0;
		NameColor.G = iNameColorRate;
		NameColor.B = 0;
		NameColor.A = 255;
		
		if (CriminalRate>999999)
			strCriminalRate = string(999999) $ " (+)";	
		else			
			strCriminalRate = string(CriminalRate);		
	}
	else if( CriminalRate < 0 )
	{
		iNameColorRate = Min( ( 100 + ( -CriminalRate / 100 ) ), 255 );		
		NameColor.R = iNameColorRate;
		NameColor.G = 0;
		NameColor.B = 0;
		NameColor.A = 255;

		if (CriminalRate<-999999)
			strCriminalRate = string(-999999) $ " (+)";	
		else			
			strCriminalRate = string(CriminalRate);	
		
	}
	else // if CriminalRate == 0
	{
		NameColor.R = 255;
		NameColor.G = 255;
		NameColor.B = 255;
		NameColor.A = 255;
		strCriminalRate = "" $ CriminalRate;
	}
	// End Change	
	
	if (Len(NickName)>0)
	{
		GetTextSizeDefault(Name, Width1, Height1);
		GetTextSizeDefault(NickName, Width2, Height2);
		if (Width1 + Width2 > 220)
		{
			if (Width1 > 109)
			{
				Name = Left(Name, 8);
				GetTextSizeDefault(Name, Width1, Height1);
			}
			if (Width2 > 109)
			{
				NickName = Left(NickName, 8);
				GetTextSizeDefault(NickName, Width2, Height2);
			}
		}
		txtName1.SetText(NickName);
		txtName1.SetTextColor(NickNameColor);
		txtName2.SetText(Name);
		txtName2.SetTextColor(NameColor);
		txtName2.MoveTo(rectWnd.nX + 15 + Width2 + 47, rectWnd.nY +41);
			//~ debug("음..:rectWnd: " @ rectWnd.nY  );
	}
	else
	{
		txtName1.SetText(Name);
		txtName1.SetTextColor(NameColor);
		txtName2.SetText("");
	}
	
	if ( getInstanceL2Util().getIsPrologueGrowType ( SubClassID ) ) 
	{
		if ( GetLanguage() == LANG_Korean )
		{
			txtLvName.SetText( "∞");
		}
		else 
		{
			txtLvName.SetText( "--");
		}
	}
	else txtLvName.SetText("" $ Level);
	txtClassName.SetText(ClassName);
	// Debug("=====:: ClassName " @ ClassName);
	// 지위 개선 작업 라이브에서는 지위가 보이지 않는다.
	//txtRank.SetText(UserRank);
	txtSP.SetText(string(SP));
	
	//혈맹
	if (PledgeID>0)
	{
		//텍스쳐
		bPledgeCrestTexture = class'UIDATA_CLAN'.static.GetCrestTexture(PledgeID, PledgeCrestTexture);
		PledgeName = class'UIDATA_CLAN'.static.GetName(PledgeID);
		PledgeNameColor.R = 176;
		PledgeNameColor.G = 155;
		PledgeNameColor.B = 121;
		PledgeNameColor.A = 255;
	}
	else
	{
		PledgeName = GetSystemString(431);
		PledgeNameColor.R = 255;
		PledgeNameColor.G = 255;
		PledgeNameColor.B = 255;
		PledgeNameColor.A = 255;
	}
	txtPledge.SetText(PledgeName);
	txtPledge.SetTextColor(PledgeNameColor);

	// 혈맹이미지가있다면..
	if (bPledgeCrestTexture)
	{
		texPledgeCrest.SetTextureWithObject(PledgeCrestTexture);
		txtPledge.MoveTo(rectWnd.nX + 110 , rectWnd.nY + 57);
		//수정
	}
	else
	{
		// 혈맹이미지가없다면..
		txtPledge.MoveTo(rectWnd.nX + 86, rectWnd.nY + 57);
	}
	
	//영웅,노블레스
		
	if (bHero)
	{
		HeroTexture = "L2UI_CH3.PlayerStatusWnd.myinfo_heroicon";
	}
	//노블레스 ver EP2.0 6.25 버젼에 추가
	else if ( nNobless == 1 )
	{
		HeroTexture = "L2UI_CH3.PlayerStatusWnd.myinfo_nobleicon";
	}
	//아너스 ver EP2.0 6.25 버젼에 추가
	else if ( nNobless == 2 )
	{
		//Debug( "노블레스 2 로드 함");
		HeroTexture = "L2UI_CH3.PlayerStatusWnd.myinfo_nobleicon2";
	}
	//Debug( HeroTexture @ nNobless);
	texHero.SetTexture(HeroTexture);
	
	//상세정보
	if (m_HennaInfo.STRchange > 0)
	{
		strTmp = nSTR $ "(+" $ m_HennaInfo.STRchange $ ")";
	}
	else if (m_HennaInfo.STRchange < 0)
	{
		strTmp = nSTR $ "(" $ m_HennaInfo.STRchange $ ")";
	}
	else
	{
		strTmp = string(nSTR);
	}
	txtSTR.SetText(strTmp);
	
	if (m_HennaInfo.DEXchange > 0)
	{
		strTmp = nDEX $ "(+" $ m_HennaInfo.DEXchange $ ")";
	}
	else if (m_HennaInfo.DEXchange < 0)
	{
		strTmp = nDEX $ "(" $ m_HennaInfo.DEXchange $ ")";
	}
	else
	{
		strTmp = string(nDEX);
	}
	txtDEX.SetText(strTmp);
	
	if (m_HennaInfo.CONchange > 0)
	{
		strTmp = nCON $ "(+" $ m_HennaInfo.CONchange $ ")";
	}
	else if (m_HennaInfo.CONchange < 0)
	{
		strTmp = nCON $ "(" $ m_HennaInfo.CONchange $ ")";
	}
	else
	{
		strTmp = string(nCON);
	}
	txtCON.SetText(strTmp);
	
	if (m_HennaInfo.INTchange > 0)
	{
		strTmp = nINT $ "(+" $ m_HennaInfo.INTchange $ ")";
	}
	else if (m_HennaInfo.INTchange < 0)
	{
		strTmp = nINT $ "(" $ m_HennaInfo.INTchange $ ")";
	}
	else
	{
		strTmp = string(nINT);
	}
	txtINT.SetText(strTmp);
	
	if (m_HennaInfo.WITchange > 0)
	{
		strTmp = nWIT $ "(+" $ m_HennaInfo.WITchange $ ")";
	}
	else if (m_HennaInfo.WITchange < 0)
	{
		strTmp = nWIT $ "(" $ m_HennaInfo.WITchange $ ")";
	}
	else
	{
		strTmp = string(nWIT);
	}
	txtWIT.SetText(strTmp);
	
	if (m_HennaInfo.MENchange > 0)
	{
		strTmp = nMEN $ "(+" $ m_HennaInfo.MENchange $ ")";
	}
	else if (m_HennaInfo.MENchange < 0)
	{
		strTmp = nMEN $ "(" $ m_HennaInfo.MENchange $ ")";
	}
	else
	{
		strTmp = string(nMEN);
	}
	txtMEN.SetText(strTmp);

	//신규스탯 럭키
	if (m_HennaInfo.LUCchange > 0)
	{
		strTmp = nLUC $ "(+" $ m_HennaInfo.LUCchange $ ")";
	}
	else if (m_HennaInfo.LUCchange < 0)
	{
		strTmp = nLUC $ "(" $ m_HennaInfo.LUCchange $ ")";
	}
	else
	{
		strTmp = string(nLUC);
	}
	txtLUC.SetText(strTmp);

	//신규스탯 카리스마
	if (m_HennaInfo.CHAchange > 0)
	{
		strTmp = nCHA $ "(+" $ m_HennaInfo.CHAchange $ ")";
	}
	else if (m_HennaInfo.CHAchange < 0)
	{
		strTmp = nCHA $ "(" $ m_HennaInfo.CHAchange $ ")";
	}
	else
	{
		strTmp = string(nCHA);
	}
	txtCHA.SetText(strTmp);


	nMagicAvoid = info.nMagicAvoid;
	nMagicHitRate = info.nMagicHitRate; 
	nMagicCriticalRate = info.nMagicCriticalRate; 

	GetTextBoxHandle(m_WindowName $ ".txtMagicAvoid").SetText(String(nMagicAvoid));
	GetTextBoxHandle(m_WindowName $ ".txtMagicHit").SetText(String(nMagicHitRate));
	GetTextBoxHandle(m_WindowName $ ".txtMagicCritical").SetText(String(nMagicCriticalRate));

	// debug("nMagicAvoid:"@ nMagicAvoid);
	// debug("nMagicHitRate:"@ nMagicHitRate);
	// debug("nMagicCriticalRate:"@ nMagicCriticalRate);

	
	
	txtPhysicalAttack.SetText(string(PhysicalAttack));
	txtPhysicalDefense.SetText(string(PhysicalDefense));
	txtHitRate.SetText(string(HitRate));
	txtCriticalRate.SetText(string(CriticalRate));
	txtPhysicalAttackSpeed.SetText(string(PhysicalAttackSpeed));
	txtMagicalAttack.SetText(string(MagicalAttack));
	txtMagicDefense.SetText(string(MagicDefense));
	txtPhysicalAvoid.SetText(string(PhysicalAvoid));
	txtMovingSpeed.SetText(MovingSpeed);
	txtMagicCastingSpeed.SetText(string(MagicCastingSpeed));
	
	txtCriminalRate.SetText( strCriminalRate);
	txtPVP.SetText(string(PvPPoint));
	txtSociality.SetText(DualCount $ " / " $ PKCount);
	txtRemainSulffrage.SetText(string(Sociality) $ " / " $  string(RemainSulffrage));

	txtRaidPoint.SetText( string(RaidPoint) );
	
	UpdateHPBar(HP, MaxHP);
	UpdateMPBar(MP, MaxMP);
	UpdateCPBar(CP, MaxCP);
	UpdateEXPBar(info.fExpPercentRate);
	//UpdateEXPBar(int(fExpRate), 100);
	
	// 속성데이터세팅
	txtAttrAttackType.SetText(""$ AttrAttackTypeTxt);
	txtAttrAttackValue.SetText(""$ AttrAttackValue );
	txtAttrDefenseValFire.SetText(""$ AttrDefenseValFire );
	txtAttrDefenseValWater.SetText(""$ AttrDefenseValWater ); 
	txtAttrDefenseValWind.SetText(""$ AttrDefenseValWind );
	txtAttrDefenseValEarth.SetText(""$ AttrDefenseValEarth );
	txtAttrDefenseValHoly.SetText(""$ AttrDefenseValHoly );
	txtAttrDefenseValUnholy.SetText(""$ AttrDefenseValUnholy );
	
	// 변신정보세팅
	if (m_bPawnChanged) 
	{
		//~ iGender = info.nSex;
		//~ TransformedID = class'UIDATA_TRANSFORM'.static.GetNpcID( nTransformID, iGender);
		//~ debug ("변신아이디"@ TransformedID);
		//~ TransformedName = class'UIDATA_NPC'.static.GetNPCName(TransformedID);
		//~ txtLvName.SetText(Level $ " " $ TransformedName);
		//~ RunTransformManage();
	}
	else
	{
		RunUnTransformManage();
	}

	//6.25 아너스 추가
	//GD4.0 05 85이상 1렙업 시 AP 사용 가능
	
	handleAbilityBtn( Level >= 85, info.nRemainAbilityPoint );
}




//HP바갱신
function UpdateHPBar(int Value, int MaxValue)
{
	/*
	local int Size;
	Size = 0;
	if (MaxValue>0)
	{
		Size = NSTATUS_SMALLBARSIZE;
		if (Value<MaxValue)
		{
			Size = NSTATUS_SMALLBARSIZE* Value / MaxValue;
		}
		
	}
	texHP.SetWindowSize(Size, NSTATUS_BARHEIGHT);*/
	texHP.SetPoint(Value, MaxValue);
}

//MP바갱신
function UpdateMPBar(int Value, int MaxValue)
{
	/*
	local int Size;
	Size = 0;
	if (MaxValue>0)
	{
		Size = NSTATUS_SMALLBARSIZE;
		if (Value<MaxValue)
		{
			Size = NSTATUS_SMALLBARSIZE* Value / MaxValue;
		}
		
	}
	texMP.SetWindowSize(Size, NSTATUS_BARHEIGHT);*/
	texMP.SetPoint(Value, MaxValue);
}

//EXP바갱신
function UpdateEXPBar(float ExpPercent)
{
	texEXP.SetPointExpPercentRate(ExpPercent);
}

//CP바갱신
function UpdateCPBar(int Value, int MaxValue)
{
	/*local int Size;
	Size = 0;
	if (MaxValue>0)
	{
		Size = NSTATUS_SMALLBARSIZE;
		if (Value<MaxValue)
		{
			Size = NSTATUS_SMALLBARSIZE* Value / MaxValue;
		}
	}
	texCP.SetWindowSize(Size, NSTATUS_BARHEIGHT);*/
	texCP.SetPoint(Value, MaxValue);
}

function ToggleOpenCharInfoWnd()
{
	switch (m_hOwnerWnd.IsShowWindow())
	{
	case true:
		m_hOwnerWnd.HideWindow();
		PlaySound("InterfaceSound.charstat_close_01");
	break;
	case false:
		m_hOwnerWnd.ShowWindow();
		m_hOwnerWnd.SetFocus();
		PlaySound("InterfaceSound.charstat_open_01");			
	break;
	}
}

function HandleVitalityPointInfo( string param )	// 활력수치만업데이트
{
	local int nVitality;
	
	ParseInt( param, "Vitality", nVitality );
	
	UpdateVp( nVitality );	// 활력게이지를업데이트한다.
}

//branch
// F2P 서비스 활력 개선 - gorillazin
function HandleVitalityEffectInfo(string param)
{
	local CustomTooltip T;
	local string tmpStr;
	local string sSysMsgParamString;
	local int nVitality;
	local int nVitalityBonus;
	local int nVitalityItemRestoreCount;
	local int nVitalityExtraBonus;
	local string sBonusString, sExtraBonusString;

	ParseInt(param, "vitalityPoint", nVitality);
	ParseInt(param, "vitalityBonus", nVitalityBonus);
	ParseInt(param, "restoreCount", nVitalityItemRestoreCount);
	// maxRestoreCount 에 대한 내용은 이 UI에서는 사용하지 않습니다.

	util = L2Util(GetScript("L2Util"));
	util.setCustomTooltip(T);
	util.ToopTipInsertText(GetSystemString(2494), true, false );

	// 활력 BM 추가 2015.05
	ParseInt(param, "vitalityExtraBonus", nVitalityExtraBonus);
	
	sBonusString = nVitalityBonus $ "%";
	if ( nVitalityExtraBonus > 0 ) 
	{
		sExtraBonusString = "(+" $ nVitalityExtraBonus $ "%)";
	}	

	//Debug  ( "활력 개선 HandleVitalityEffectInfo "  @ nVitality @ nVitalityBonus @ nVitalityItemRestoreCount @ nVitalityItemMaxRestoreCount @ nVitalityExtraBonus );

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
	
	texVP.SetTooltipCustomType(util.getCustomTooltip());//bluesun 커스터마이즈 툴팁
}
//
//end of branch

/*function UpdateVp (int Vitality )
{	
	if(Vitality > 20000) // 여기는에러
	{
		VitalityTex.SetTexture("l2ui_ct1.Icon_df_LifeForce_01");
	}
	else if(Vitality >= 17000) 		//활력4단계. 경험치보너스300%. 사이값3000
	{
		VitalityTex.SetTexture("l2ui_ct1.Icon_df_LifeForce_05");
	}
	else if(Vitality >=13000)	// 활력3단계. 경험치보너스250%. 사이값4000
	{
		VitalityTex.SetTexture("l2ui_ct1.Icon_df_LifeForce_04");
	}
	else if(Vitality >= 2000)		//활력2단계. 경험치보너스200%. 사이값11000 
	{
		VitalityTex.SetTexture("l2ui_ct1.Icon_df_LifeForce_03");
	}
	else if(Vitality >= 240)		//활력1단계. 경험치보너스150%. 사이값1760
	{
		VitalityTex.SetTexture("l2ui_ct1.Icon_df_LifeForce_02");
	}
	else// 활력0단계. 경험치보너스없음. 사이값240.
	{
		VitalityTex.SetTexture("l2ui_ct1.Icon_df_LifeForce_01");
	}	
}*/

function RunTransformManage()
{
	
}

function RunUnTransformManage()
{
	
}

/**
 * 커스텀툴팁(서브잡클래스변환버튼에사용)
 **/
function CustomTooltip subjobButtonToolTips (int targetType)
{
	local CustomTooltip m_Tooltip;
	
	local int subjobSlotStringNum;
	// Debug("targetType tool " @ targetType);

	// 서브클래스를등록하는자리입니다.. 같은안내맨트..
	if (targetType == -1)
	{
		m_Tooltip.DrawList.Length = 1;
		m_Tooltip.MinimumWidth = 210;//160->183px 로 수정됨
		m_Tooltip.DrawList[0].eType = DIT_TEXT;
		m_Tooltip.DrawList[0].t_color.R = 220;
		m_Tooltip.DrawList[0].t_color.G = 220;
		m_Tooltip.DrawList[0].t_color.B = 220;
		m_Tooltip.DrawList[0].t_color.A = 255;		

		//아르테이어의 경우 툴팁 텍스트가 다름
		subjobSlotStringNum = 2342;

		if ( race == 6 ) 
		{				
			subjobSlotStringNum = 3315;
		}


		m_Tooltip.DrawList[0].t_strText = GetSystemString(subjobSlotStringNum);
	}
	else
	{
		m_Tooltip.DrawList.Length = 5;
		m_Tooltip.MinimumWidth = 214;
		
		
		m_Tooltip.DrawList[0].eType = DIT_TEXT;
		m_Tooltip.DrawList[0].t_color.R = 170;
		m_Tooltip.DrawList[0].t_color.G = 170;
		m_Tooltip.DrawList[0].t_color.B = 170;
		m_Tooltip.DrawList[0].t_color.A = 255;
		m_Tooltip.DrawList[0].t_strText = "Lv";
		
		m_Tooltip.DrawList[1].eType = DIT_TEXT;
		m_Tooltip.DrawList[1].t_color.R = 175;
		m_Tooltip.DrawList[1].t_color.G = 152;
		m_Tooltip.DrawList[1].t_color.B = 120;
		m_Tooltip.DrawList[1].t_color.A = 255;
		m_Tooltip.DrawList[1].t_strText = subjobInfoArray[targetType].Level @ GetClassType(subjobInfoArray[targetType].ClassID);


		m_Tooltip.DrawList[2].eType = DIT_TEXT;
		m_Tooltip.DrawList[2].t_color.R = 170;
		m_Tooltip.DrawList[2].t_color.G = 170;
		m_Tooltip.DrawList[2].t_color.B = 170;
		m_Tooltip.DrawList[2].t_color.A = 255;

		// Debug("GetClassType(subjobInfoArray[targetType].ClassID)" @ subjobInfoArray[targetType].ClassID);
		// Debug("GetClassType(subjobInfoArray[targetType] 이름: )" @ GetClassType(subjobInfoArray[targetType].ClassID));

		// 메인:0, 듀얼:1 서브:2
		// 서브클래스라면..
		if (subjobInfoArray[targetType].Type == 2)
		{
			// "서브" 
			m_Tooltip.DrawList[2].t_strText = " (" $ GetSystemString(2341) $ ")";			
		}
		else if (subjobInfoArray[targetType].Type == 1)
		{
			// "듀얼" 
			m_Tooltip.DrawList[2].t_strText = " (" $ GetSystemString(2739) $ ")";			
		}
		else
		{
			m_Tooltip.DrawList[2].t_strText = " (" $ GetSystemString(2738) $ ")";
		}	
		//m_Tooltip.DrawList[2].t_bDrawOneLine = true;
		//m_Tooltip.DrawList[2].bLineBreak = true;

		 
		m_Tooltip.DrawList[3].eType = DIT_TEXT;

		// m_Tooltip.DrawList[3].nOffSetY = 2;
		m_Tooltip.DrawList[3].bLineBreak = true;
		m_Tooltip.DrawList[3].t_color.R = 220;
		m_Tooltip.DrawList[3].t_color.G = 220;
		m_Tooltip.DrawList[3].t_color.B = 220;
		m_Tooltip.DrawList[3].t_color.A = 255;

		m_Tooltip.DrawList[3].t_strText = GetSystemString(2343);
		// 서브라면..
		// 80레벨이후메인클래스로성장할수있습니다. 메세지보여줌
		m_Tooltip.DrawList[4].eType = DIT_TEXT;

		// 듀얼 클래스가 하나도 없는 경우
		// 80레벨 이후 메인클래스로 성장할 수 있습니다 
		// 라는 툴팁을 보여준다. 
		if (subjobInfoArray[targetType].Type == 2 && isDualClass == false)
		{
			m_Tooltip.DrawList[4].bLineBreak = true;
			m_Tooltip.DrawList[4].t_color.R = 110;
			m_Tooltip.DrawList[4].t_color.G = 140;
			m_Tooltip.DrawList[4].t_color.B = 170;
			m_Tooltip.DrawList[4].t_color.A = 255;
			m_Tooltip.DrawList[4].t_strText = GetSystemString(2344);
		}
		else
		{
			m_Tooltip.DrawList[4].t_strText = "";
		}
	}

	return m_Tooltip;
}

/**
 *  종족스트링을리턴한다.
 **/
function string getRaceString(int nRace)
{
	local string returnV;

	switch (nRace)
	{
		case 0  : returnV = "human";   break;
		case 1  : returnV = "elf";     break;
		case 2  : returnV = "darkelf"; break;
		case 3  : returnV = "orc";     break;
		case 4  : returnV = "dwarf";   break;
		case 5  : returnV = "kamael";  break;
		case 6  : returnV = "Ertheia"; break;
		default : returnV = "";
	}

	return returnV;
}

/**
 * 윈도우ESC 키로닫기처리
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( m_WindowName ).HideWindow();
}


defaultproperties
{
    m_WindowName="DetailStatusWnd"
}
