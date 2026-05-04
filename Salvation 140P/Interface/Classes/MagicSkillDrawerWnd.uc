class MagicSkillDrawerWnd extends UICommonAPI;

const MIN_ENCHANT_LEVEL = 1;
const MAX_ENCHANT_LEVEL = 30;
const SKILL_ENCHANT_NUM = 6;
const ENCHANT_TYPE_NUM = 3;         // 인첸트 타입 수

//인텐트 상태
const ENCHANT_START = -1;
const ENCHANT_NORMAL = 0;			// 보통 인챈트
const ENCHANT_SAFETY = 1;			// 세이프티 인챈트
const ENCHANT_UNTRAIN = 2;			// 인챈트 언트레인
const ENCHANT_ROUTE_CHANGE = 3;		// 인챈트 루트 체인지
const ENCHANT_PASS_TICKET = 4;		// 인챈트 루트 체인지

const ENCHANT_MATERIAL_NUM = 3;		// 재료의 수
//const ARROW_NUM = 9;				// 아이콘 사이에 들어가는 텍스쳐 숫자

const DIALOGID_ResearchClick = 0;

const ENCHANT_TYPE_UINT = 1000;

var Color White;

var String m_WindowName;
var WindowHandle Me;
var WindowHandle MagicskillGuideWnd;
var TextureHandle ResearchSkill;
//var TextureHandle SelectSkill;
//스킬 강화 화살표 아이콘 들
//var TextureHandle ResearchSkillArrow_Right;
//var TextureHandle ResearchSkillArrow_Left;
//var TextureHandle ResearchSkillArrow_Down;
//var TextureHandle ResearchSkillArrow_Up;
var ItemWindowHandle ResearchSkillIcon;
var TextureHandle ResearchSkillIconSlotBg;
var TextBoxHandle ResearchSkillTitle;
var NameCtrlHandle ResearchSkillName;
//스킬 강화 이름을 표시 하던 부분
//var TextBoxHandle ResearchSkillRoot;
var TextBoxHandle ResearchSkillDesc;
var TextBoxHandle ResearchSkillLv;
//스킬 강화 현재 단계를 표시 하던 부분
//var TextBoxHandle ResearchSkillRootLv;
var ItemWindowHandle ExpectationSkillIcon;
var TextureHandle ExpectationSkillIconSlotBg;
var TextBoxHandle ExpectationSkillTitle;

//스킬 강화 후 표시 했던 이름 부분
//var NameCtrlHandle ExpectationSkillName;

var TextBoxHandle ExpectationSkillRoot;
var TextBoxHandle ExpectationSkillDesc;
//스킬 강화 후 표시 했던 스킬 레벨 이름
//var TextBoxHandle ExpectationSkillLv;
//var TextBoxHandle ExpectationSkillRootLv;
var TextBoxHandle SucessProbablity;

var ItemWindowHandle ResearchRootIcon[SKILL_ENCHANT_NUM];
var ButtonHandle ResearchRootBTN[SKILL_ENCHANT_NUM];
var TextBoxHandle ResearchRootText[ SKILL_ENCHANT_NUM ];
var TextBoxHandle ResearchRootText2[ SKILL_ENCHANT_NUM ];

//var ButtonHandle ResearchRoot_2[SKILL_ENCHANT_NUM];
//var ButtonHandle ResearchRoot_3[SKILL_ENCHANT_NUM];

var int	ResearchRootID[SKILL_ENCHANT_NUM];
var int ResearchRootSubLevel[SKILL_ENCHANT_NUM];
//var int ResearchRootLevel[SKILL_ENCHANT_NUM];
var string ResearchRootSkillIconName[SKILL_ENCHANT_NUM];
var string ResearchRootSkillName[SKILL_ENCHANT_NUM];



var TextBoxHandle ResearchRootTitle;
var TextureHandle ResearchRootSlotBg;
//var CheckBoxHandle normEnchant;
//var CheckBoxHandle SafeEnchant;
//var CheckBoxHandle PassEnchant;
var CheckBoxHandle enchatTypeRadioBtn[ ENCHANT_TYPE_NUM ];
var TextBoxHandle EnchantMaterialTitle;

var TextBoxHandle EnchantMaterialName;
var TextBoxHandle EnchantMaterialInfo[ENCHANT_MATERIAL_NUM];

//비전서 아이템 수량 정보 
var TextBoxHandle EnchantMaterialInfo2;
var ItemWindowHandle EnchantMaterialIcon;
var TextureHandle EnchantMaterialIconBg;
var TextBoxHandle ResearchGuideTitle;
var TextBoxHandle ResearchGuideDesc;
var CharacterViewportWindowHandle ObjectViewport;
var ButtonHandle btnGuide;
var ButtonHandle btnResearch;
var ButtonHandle btnClose;
var TextureHandle ResearchSkillBg;
var TextureHandle ExpectationSkillBg;
var TextureHandle ResearchRootBg;
var TextureHandle ResearchMaterialIconBg;
var TextureHandle ResearchGuideBg;
var TextBoxHandle txtMySpStr;
var TextBoxHandle txtMySp;
var TextureHandle MyAdenaIcon;
var TextBoxHandle txtMyAdenaStr;
var TextBoxHandle txtMyAdena;
var AnimTextureHandle EnchantProgressAnim;
var int curEnchantType;
var int EnchantState;	 //현재 진행 중인 인챈트 기능 저장

var TextureHandle ResearchRoot_Select_1_0Y;
var TextureHandle ResearchRoot_Select_1_0B;

var int enableTrain;

var TextureHandle ResearchSkillSelectbox;
var TextureHandle ResearchRootSelectbox;

// 현재 상태의 스킬 정보
var int curSkillID; 
var int curLevel;
var int curSubLevel;
// 현재 내가 인챈트,루트,언트레인 하고싶은 스킬의 정보
var int curWantedSkillID;
var int curWantedSubLevel;

//현재 강화 방식의 인덱스 
var int curIndex;

var int64 needSPConsume;
var int64 needAdena;

//닫히는 도중에 show 시키는 reqe
var bool isHiding;


function setMagicSkillItemsType( bool isOn )
{
	local MagicSkillWnd script_a;
	local int i;

	script_a = MagicSkillWnd(GetScript("MagicSkillWnd"));

	//Debug ( "setMagicSkillItemsType"  @ isOn);
	for ( i = 0 ; i <  script_a.Skill_GROUP_COUNT ; i++ )
	{		
		if (isOn)
		{
			script_a.m_Item[i].SetIconDrawType(ITEMWND_IconDraw_NoConditionalEffect);
		}
		else 
		{
			script_a.m_Item[i].SetIconDrawType(ITEMWND_IconDraw_Default); ///이건 안되네.
		}
	}
}

function OnLoad()
{
	White.R = 250;
	White.G = 250;
	White.B = 250;
	White.A = 255;

	Initialize();
}


function OnRegisterEvent()
{
	RegisterEvent( EV_SkillEnchantInfoWndShow );
	RegisterEvent( EV_SkillEnchantInfoWndAddSkill );
//	RegisterEvent( EV_SkillEnchantInfoWndHide );
	RegisterEvent( EV_SkillEnchantInfoWndAddExtendInfo );
	RegisterEvent( EV_SkillEnchantResult );
	RegisterEvent( EV_DialogOK );
	RegisterEvent( EV_DialogCancel );


	//SP 변경 시 
	RegisterEvent( EV_UpdateUserInfo );		
	RegisterEvent( EV_InventoryUpdateItem );	

	RegisterEvent( EV_InventoryItemListEnd );	
	
}


function Initialize()
{
	local int i;
	Me = GetWindowHandle( m_WindowName );
	MagicskillGuideWnd = GetWindowHandle( "MagicskillGuideWnd");
	ResearchSkill = GetTextureHandle (   m_WindowName$".ResearchSkill"  );

	ResearchSkillIcon = GetItemWindowHandle (   m_WindowName$".ResearchSkillWnd.ResearchSkillIcon"  );
	ResearchSkillIconSlotBg = GetTextureHandle (   m_WindowName$".ResearchSkillWnd.ResearchSkillIconSlotBg"  );
	ResearchSkillTitle = GetTextBoxHandle (   m_WindowName$".ResearchSkillWnd.ResearchSkillTitle"  );
	ResearchSkillName = GetNameCtrlHandle (   m_WindowName$".ResearchSkillWnd.ResearchSkillName"  );

	ResearchSkillDesc = GetTextBoxHandle (   m_WindowName$".ResearchSkillWnd.ResearchSkillDesc"  );
	ResearchSkillLv = GetTextBoxHandle(   m_WindowName$".ResearchSkillWnd.ResearchSkillLv"  );

	ExpectationSkillIcon = GetItemWindowHandle (   m_WindowName$".ResearchSkillWnd.ExpectationSkillIcon"  );
	ExpectationSkillIconSlotBg = GetTextureHandle (   m_WindowName$".ResearchSkillWnd.ExpectationSkillIconSlotBg"  );
	ExpectationSkillTitle = GetTextBoxHandle (   m_WindowName$".ResearchSkillWnd.ExpectationSkillTitle"  );	
	ExpectationSkillRoot = GetTextBoxHandle (   m_WindowName$".ResearchSkillWnd.ExpectationSkillRoot"  );
	ExpectationSkillDesc = GetTextBoxHandle (   m_WindowName$".ResearchSkillWnd.ExpectationSkillDesc"  );
	SucessProbablity = GetTextBoxHandle (   m_WindowName$".ResearchSkillWnd.SucessProbablity"  );
	
	for (i =0; i < SKILL_ENCHANT_NUM; i++)
	{
		ResearchRootIcon[i] = GetItemWindowHandle ( m_WindowName$".ResearchRootIcon_"$string(i));
		ResearchRootBTN[i] = GetButtonHandle(m_WindowName$".ResearchRootBTN"$string(i));
		ResearchRootText[i] = GetTextBoxHandle(m_WindowName$".ResearchRootText"$string(i));
		ResearchRootText2[i] = GetTextBoxHandle(m_WindowName$".ResearchRootText"$string(i)$"_1");
	}

	ResearchRoot_Select_1_0Y =  GetTextureHandle(m_WindowName$".ResearchRoot_Select_1_0Y");
	ResearchRoot_Select_1_0B =  GetTextureHandle(m_WindowName$".ResearchRoot_Select_1_0B");

	ResearchRootTitle = GetTextBoxHandle (   m_WindowName$".ResearchRootTitle"  );
	ResearchRootSlotBg = GetTextureHandle (   m_WindowName$".ResearchRootSlotBg"  );

	enchatTypeRadioBtn[0] = GetCheckBoxHandle (   m_WindowName$".NormalEnchant"  );
	enchatTypeRadioBtn[1] = GetCheckBoxHandle (   m_WindowName$".SafeEnchant"  );
	enchatTypeRadioBtn[2] = GetCheckBoxHandle (   m_WindowName$".PassEnchant"  );	

	EnchantMaterialTitle = GetTextBoxHandle (   m_WindowName$".EnchantMaterialTitle"  );

	for (i = 0; i < ENCHANT_MATERIAL_NUM; i++)
	{		
		EnchantMaterialInfo[i] = GetTextBoxHandle (   m_WindowName$".EnchantMaterialInfo_"$string(i) );
	}

	EnchantMaterialName = GetTextBoxHandle (   m_WindowName$".EnchantMaterialName_0" );
	EnchantMaterialIcon = GetItemWindowHandle (   m_WindowName$".EnchantMaterialIcon_0" );
	EnchantMaterialIconBg = GetTextureHandle (   m_WindowName$".EnchantMaterialIconBg_0"  );

	EnchantMaterialInfo2 = GetTextBoxHandle ( m_WindowName$".EnchantMaterialInfo2");
	
	ResearchGuideTitle = GetTextBoxHandle ( m_WindowName$".ResearchGuideTitle"  );
	ResearchGuideDesc = GetTextBoxHandle ( m_WindowName$".ResearchGuideDesc"  );
	ObjectViewport = GetCharacterViewportWindowHandle (   m_WindowName$".ObjectViewport"  );
	btnGuide = GetButtonHandle (   m_WindowName$".btnGuide"  );
	btnResearch = GetButtonHandle (   m_WindowName$".btnResearch"  );
	btnClose = GetButtonHandle (   m_WindowName$".btnClose"  );
	ResearchSkillBg = GetTextureHandle (   m_WindowName$".ResearchSkillBg"  );
	ExpectationSkillBg = GetTextureHandle (   m_WindowName$".ExpectationSkillBg"  );
	ResearchRootBg = GetTextureHandle (   m_WindowName$".ResearchRootBg"  );
	ResearchMaterialIconBg = GetTextureHandle (   m_WindowName$".ResearchMaterialIconBg"  );
	ResearchGuideBg = GetTextureHandle (   m_WindowName$".ResearchGuideBg"  );
	txtMySpStr = GetTextBoxHandle (   m_WindowName$".txtMySpStr"  );
	txtMySp = GetTextBoxHandle (   m_WindowName$".txtMySp"  );
	txtMyAdenaStr = GetTextBoxHandle (   m_WindowName$".txtMyAdenaStr"  );
	txtMyAdena = GetTextBoxHandle (   m_WindowName$".txtMyAdena"  );
	MyAdenaIcon = GetTextureHandle (   m_WindowName$".MyAdenaIcon"  );
	EnchantProgressAnim = GetAnimTextureHandle (  m_WindowName$".EnchantProgressAnim"  );

	ResearchSkillSelectbox = GetTextureHandle ( m_WindowName$".ResearchSkillWnd.ResearchSkillSelectbox");
	ResearchRootSelectbox = GetTextureHandle ( m_WindowName$".ResearchRootSelectbox");

	EnchantProgressAnim.hidewindow();

	setRadioTooltip ( enchatTypeRadioBtn[0], 3357 );
	setRadioTooltip ( enchatTypeRadioBtn[1], 3358 );
	setRadioTooltip ( enchatTypeRadioBtn[2], 3359 );
}

function setRadioTooltip ( CheckBoxHandle radioBtn, int strNum)
{
	local CustomTooltip T;

	local L2Util util;
	
	T.MinimumWidth = 125; // 125 로 수정해야함

	util = L2Util(GetScript("L2Util"));//bluesun 커스터마이즈 툴팁 

	util.setCustomTooltip( T );

	util.ToopTipMinWidth( 220 );		
	
	util.ToopTipInsertText( GetSystemString (strNum), false, true, util.ETooltipTextType.COLOR_DEFAULT, 0, 0 );	

	radioBtn.SetTooltipCustomType ( util.getCustomTooltip() );	
}

function OnDrawerShowFinished()
{
	isHiding = false;
	setMagicSkillItemsType(true);
}

function OnClickButton( string Name )
{
	local int		rootID;	

	if ( InStr( Name ,"ResearchRootBTN") > -1 )
	{
		rootID = int(Right(Name, 1));		
		OnResearchRootBTNClick(rootID);
	}

	switch( Name )
	{
	
	case "btnGuide":
		OnbtnGuideClick();
		break;
	case "btnResearch":
		OnbtnResearchClick( );
		break;
	case "btnClose":
		OnbtnCloseClick( );
		break;
	}
}

/*
 *버튼들을 래디오 버튼 처럼 사용하게 함.
 */
function byRadioButton(string strID)
{
	local int checkNum ;

	checkNum = -1;
	switch (strID) 
	{	
		case "NormalEnchant" :	
			EnchantState = ENCHANT_NORMAL;
			checkNum = 0;			
		break;
		case "SafeEnchant":
			EnchantState = ENCHANT_SAFETY;
			checkNum = 1;			
		break;
		case "PassEnchant":
			EnchantState = ENCHANT_PASS_TICKET;
			checkNum = 2;			
		break;
		
	}		

	enchatTypeRadioBtn[0].SetCheck ( false ) ;
	enchatTypeRadioBtn[1].SetCheck ( false ) ;
	enchatTypeRadioBtn[2].SetCheck ( false ) ;
//	Debug ( "byRadioButton"  @ checkNum  @ strID @ EnchantState );

	if ( checkNum != -1 ) enchatTypeRadioBtn[checkNum].SetCheck( true ) ;
}

/*
 *채크 된 상태에 따라 text 내용을 교체
 */
function setTextByEnchantType()
{
	local string  btnResearchLabel;     //버튼 이름 변화
	local string  GuideDesc;            //상단 설명 변화
	
	btnResearch.EnableWindow();
	if (enchatTypeRadioBtn[2].IsChecked())
	{			
		btnResearchLabel = GetSystemString( 3112 );
		GuideDesc = GetSystemString( 3111 );
	}
	//축복 받은
	else if (enchatTypeRadioBtn[1].IsChecked())
	{	
		btnResearchLabel = GetSystemString(2069);
		GuideDesc =	GetSystemString(2050);	
	}	
	//현재 타입과 변경하고자 하는 타입이 같으면 일반	
	else if ( enchatTypeRadioBtn[0].IsChecked() )
	//curSubLevel /ENCHANT_TYPE_UINT == curWantedSubLevel / ENCHANT_TYPE_UINT || curSubLevel == 0) 
	{			
		btnResearchLabel = GetSystemString(2070) ;
		GuideDesc =	GetSystemString(2051);		
	}
	//최대 레벨일 경우 
	else if ( enableTrain == 0 && curSubLevel /ENCHANT_TYPE_UINT == curWantedSubLevel / ENCHANT_TYPE_UINT)  
	{		
		btnResearchLabel = GetSystemString (2070);
		GuideDesc =	GetSystemString(3354);
		btnResearch.DisableWindow();
	}	
	//루트 체인지 일 경우 
	else 
	{
		btnResearchLabel = GetSystemString( 2068 ) ;
		GuideDesc =	GetSystemString(2052);
	}

	btnResearch.SetNameText( btnResearchLabel );
	ResearchGuideDesc.SetText( GuideDesc );
	//RequestExEnchantSkillInfoDetail( EnchantState, curWantedSkillID, curLevel, curWantedSubLevel);			
}



function OnClickCheckBox( String strID)
{
	byRadioButton( strID );
	//setTextByEnchantType();	
	//언제 리퀘스를 하는 가? 
	RequestExEnchantSkillInfoDetail( EnchantState, curWantedSkillID, curLevel, curWantedSubLevel);
}

//각 버튼 클릭 시 상태에 따른 라디오 버튼 변화 
function setRadioBtnsByEnchantStep( ) 
{
	/*
	"NormalEnchant"
	"PassEnchant"			
	"SafeEnchant"*/				
	
	local bool canUseBtns;

	//두가지 문제 발생 
	//1 현재 선택 되어 있는 인첸트 타입이 계속 적용 안됨.
	//2 최대 레벨일 경우처음 들일 경우 정상 반영이 안됨.

	//둘다 ENCHANT_START 일 경우 발생 됩니다.
	
	//아무것도 클릭 하지 않았던 경우 
	//1. 선택 된 강화 방식이 최대 레벨일 경우 모두 비활 성화 처리 해야 함.
	if ( EnchantState == ENCHANT_START && enableTrain == 1  ) 
	{
		//레디오 버튼이 체크 되어 있는 것이 있을 경우 
		//무조건 노멀이 아니라 조건에 따라 다르게 해야 함.		
		if ( enchatTypeRadioBtn[1].IsChecked() )
		{
			byRadioButton ( "SafeEnchant");
		}
		else if ( enchatTypeRadioBtn[2].IsChecked() ) 
		{
			byRadioButton ( "PassEnchant");
		}
		else byRadioButton ( "NormalEnchant" );			
		canUseBtns = true;
	}
	//버튼 선택 시   //최대 선택 된 방식이 최대 레벨인 경우		
	else if ( enableTrain == 0 && curSubLevel/ENCHANT_TYPE_UINT == curWantedSubLevel/ENCHANT_TYPE_UINT)
	{		
		EnchantState = ENCHANT_NORMAL;
		byRadioButton ("");
		
	}
	//버튼 선택 시   //변경 시 비활성화  
	else if ( curSubLevel/ENCHANT_TYPE_UINT != curWantedSubLevel/ENCHANT_TYPE_UINT && curSubLevel > 0) 
	{		
		byRadioButton ("");	
		EnchantState = ENCHANT_ROUTE_CHANGE;
	}
	//그 외 모든 경우 
	else 
	{		
		if ( EnchantState == ENCHANT_ROUTE_CHANGE ) 
		{			
			byRadioButton ( "NormalEnchant" );
		}	
		canUseBtns = true;
	}

	if ( canUseBtns ) 
	{
		enchatTypeRadioBtn[0].EnableWindow();
		enchatTypeRadioBtn[1].EnableWindow();
		enchatTypeRadioBtn[2].EnableWindow();
	}
	else 
	{
		enchatTypeRadioBtn[0].DisableWindow();
		enchatTypeRadioBtn[1].DisableWindow();
		enchatTypeRadioBtn[2].DisableWindow();
	}
}


function OnResearchRootBTNClick(int index)
{
	local int infoid;
	local int infoSublevel;
	
	//반복 클릭 일 경우 리턴
//	Debug ( "OnResearchRootBTNClick1" @ curEnchantType @ ResearchRootSubLevel[index]);
	if ( curEnchantType == ResearchRootSubLevel[index]/ENCHANT_TYPE_UINT ) return;
	
	//Debug (  "OnResearchRootBTNClick"@curSubLevel/ENCHANT_TYPE_UINT  @  ResearchRootSubLevel[index]/ENCHANT_TYPE_UINT  @  curSubLevel );
	//노란 하일라이트를 파란 하일라이트가 보일 수 있도록 숨김	
	if ( curSubLevel/ENCHANT_TYPE_UINT == ResearchRootSubLevel[index]/ENCHANT_TYPE_UINT || curSubLevel == 0  ) 
	{
		ResearchRoot_Select_1_0Y.HideWindow();
	} 
	else 
	{
		ResearchRoot_Select_1_0Y.ShowWindow();
	}	

	ResearchRoot_Select_1_0B.ClearAnchor();
	ResearchRoot_Select_1_0B.SetAnchor( "MagicSkillDrawerWnd.ResearchRootBTN"$index, "TopLeft", "TopLeft", 0, 0 );
	ResearchRoot_Select_1_0B.ShowWindow();		
		
	infoSublevel = ResearchRootSubLevel[index];		
	infoid = ResearchRootID[index];
	//infoLevel = ResearchLevel[index];
	//curWnatedLevel = infoLevel;
	curWantedSkillID = infoid;
	curWantedSubLevel = infoSublevel;	
		
	//스킬 업 타입이 다르면서, curSubLevel이 0보다 큰 경우
	//Debug ( "ENCHANT_ROUTE_CHANGE 타입인가?" @ curSubLevel/ENCHANT_TYPE_UINT @  ResearchRootSubLevel[index]/ENCHANT_TYPE_UINT @ curSubLevel );
	/*
	if ( curSubLevel/ENCHANT_TYPE_UINT != ResearchRootSubLevel[index]/ENCHANT_TYPE_UINT  && curSubLevel > 0 ) 
	{		
		//EnchantState = ENCHANT_ROUTE_CHANGE;		
		btnResearch.SetNameText(GetSystemString(2068));								
	}*/

	//Debug ( "OnResearchRootBTNClick" @ EnchantState@curWantedSkillID@curWantedSubLevel );
	
	SucessProbablity.SetText("");
	SucessProbablity.HideWindow();
	
	//SetAdenaSpInfo();	

	setRadioBtnsByEnchantStep();

	//setTextByEnchantType();	

	RequestExEnchantSkillInfoDetail(EnchantState, curWantedSkillID, curLevel, curWantedSubLevel);

/*
	if ( enableTrain == 0 ) 
	{
		//최대 레벨일 경우 
		if ( curSubLevel/ENCHANT_TYPE_UINT == ResearchRootSubLevel[index]/ENCHANT_TYPE_UINT ) 
		{	
			btnResearch.DisableWindow();			
		}
		else 
		{
			btnResearch.EnableWindow();
		}
	}
	else 
	{
		btnResearch.EnableWindow();
	}
*/
}

function OnbtnGuideClick()
{
	if (MagicskillGuideWnd.IsShowWindow())
	{
		MagicskillGuideWnd.HideWindow();		
	}
	else 
	{
		MagicskillGuideWnd.ShowWindow();
		MagicskillGuideWnd.SetFocus();
	}
}

function OnbtnResearchClick()
{		
	DialogSetID( DIALOGID_ResearchClick);
	DialogShow(DialogModalType_Modal, DialogType_OKCancel, GetSystemString( 2054 ), string(Self) );	

	//SetAdenaSpInfo();	
}

function OnbtnCloseClick()
{
	local MagicSkillWnd script_a;

	script_a = MagicSkillWnd(GetScript("MagicSkillWnd"));

	script_a.RequestSkillList();	

	me.HideWindow();
	isHiding = true;
	setMagicSkillItemsType(false);
//	HideAgathion();	
	SkillInfoClear();

}

function OnEvent(int Event_ID, String param)
{	
	//Debug ("onEvent" @ Event_ID @ param );
	switch (Event_ID)
	{
		case EV_SkillEnchantInfoWndShow:                    //2064
			
			OnEVSkillEnchantInfoWndShow(param);
			break;			
		case EV_SkillEnchantInfoWndAddSkill:                //2065
			OnEVSkillEnchantInfoWndAddSkill(param);
			break;
	//	case EV_SkillEnchantInfoWndHide:
	//		OnEVSkillEnchantInfoWndHide(param);
	//		break;
		case EV_SkillEnchantInfoWndAddExtendInfo:           //2067
			OnEVSkillEnchantInfoWndAddExtendInfo(param);			
			break;
		case EV_SkillEnchantResult:                         //4600
			OnEVSkillEnchantResult(param);			
			break;
		case EV_DialogOK:
			HandleDialogOK();
			break;
		case EV_DialogCancel:
			HandleDialogCancel();
			break;
		case EV_UpdateUserInfo :
			if (! Me.IsShowWindow() ) return;
			SetSpInfo();
			break;		
		case EV_InventoryUpdateItem:    //2610	
		case EV_InventoryItemListEnd:
			if (! Me.IsShowWindow() ) return;
			SetAdenaInfo( string ( GetAdena() ));
			break;
	}
}

function SetSpInfo()
{	
	txtMySp.SetText(MakeCostString( string(GetUserSP()) ));
	txtMySp.SetTooltipString( ConvertNumToTextNoAdena(string(GetUserSP())) );

	if (  needSPConsume > GetUserSP() ) 		
	{		
		ResearchGuideDesc.SetText( GetSystemString ( 3361 ) );
		btnResearch.DisableWindow();
	}	
}


function SetAdenaInfo( string adena)
{	//GetAdena() 으로 기존에 받았으나, 돈과 ,sp 가 업데이트 되기 전에 이벤트가 들어오는 경우가 있어서 수정		
	txtMyAdena.SetText(MakeCostString( adena ));
	txtMyAdena.SetText(MakeCostString( adena ));
	txtMyAdena.SetTooltipString( ConvertNumToText( adena) );
	txtMyAdenaStr.SetText(GetSystemString(469));

	if (  needAdena > int64 (adena) ) 		
	{		
		ResearchGuideDesc.SetText( GetSystemString ( 3361 ) );
		btnResearch.DisableWindow();
	}	
}

function HandleDialogOK()
{
	if( !DialogIsMine() )
		return;

	switch( DialogGetID() )
	{
		case DIALOGID_ResearchClick:	
			//if ( EnchantState != -1 @  curWantedSkillID @ curLevel @  curWantedSubLevel
			//Debug ( "HandleDialogOK" @ EnchantState @  curWantedSkillID @ curLevel @  curWantedSubLevel );
			btnResearch.DisableWindow();
			RequestExEnchantSkill(EnchantState, curWantedSkillID, curLevel, curWantedSubLevel);			
		break;
	}
	//m_hVpAgathion.PlayAnimation(2);
}

function HandleDialogCancel()
{
	if( !DialogIsMine() )
		return;
}

function OnEVSkillEnchantInfoWndShow(string param)
{
	local int Count;
	local int SkillID;
	local int CurSkillLevel;
	local int CurSkillSubLevel;
	local ItemInfo info;

	//서버에서 EnableTrain 값이 1 로 들어 옴
	ParseInt(Param, "EnableTrain", EnableTrain);
	//ParseInt(Param, "EnableUntrain", EnableUntrain);
	ParseInt(Param, "Count", Count);
	ParseInt(Param, "SkillID", SkillID);
	ParseInt(Param, "CurSkillLevel", CurSkillLevel);
	ParseInt(Param, "CurSkillSubLevel", CurSkillSubLevel);	
	
	info.ID.ClassID = curSkillID;
	info.Level = CurSkillLevel;
	info.SubLevel = CurSkillSubLevel;

	//스킬 창이 닫힌 경우 처리하지 말것.
	//Debug( "OnEVSkillEnchantInfoWndShow" @ isHiding ) ;
	if ( IsShowWindow( "MagicSkillWnd") && !isHiding) 
	{		
		Me.ShowWindow();		
	}
	
	SkillInfoClear();
	
	SetCurSkillInfo(info);

	//SetAdenaSpInfo();

	curSkillID = SkillID; 
	curLevel = CurSkillLevel;
	curSubLevel = CurSkillSubLevel;

	if ( enableTrain == 0 )
	{		
		ResearchGuideDesc.SetText("");
		ResearchGuideDesc.SetText(GetSystemString(2041));
		//ResearchGuideDesc.SetText("스킬 강화가 불가능한 스킬입니다..");

		//SetAdenaSpInfo();
		SucessProbablity.Hidewindow();
	}

	ResearchGuideDesc.SetText(GetSystemString(2043)); //"강화 방식을 선택하세요. $ 축복받은 스킬 강화, 불변의 비전서 스킬 강화는 아래에서 한 번 더 선택해 주세요.
	
	Me.Setfocus();		
}

function onShow () 
{
	//열릴 때 sp, 아데나 정보 가져오기
	SetAdenaSpInfo () ;	
}

function SetAdenaSpInfo () 
{
	SetSpInfo();
	SetAdenaInfo( string ( GetAdena() ));
}

/*
function setHidingFlag( bool flag ) 
{
	//만약 창이 닫혀있는 상태에서 플래그를 true로 설정 하려 한다면 플래그를 flase로 바꿔 줌.
	if ( !Me.IsShowWindow() ) 
	{
		if ( flag ) flag = false;
	}

	isHiding = flag;
}
*/



function OnDrawerHideFinished ()
{
	isHiding = false;	
	//setMagicSkillItemsType(false);
	OnTextureAnimEnd (EnchantProgressAnim  );
	if( DialogIsMine() )
	{
		class'UIAPI_WINDOW'.static.HideWindow("DialogBox");
	}
}
function onHide ()
{	
	if( DialogIsMine() )
	{
		class'UIAPI_WINDOW'.static.HideWindow("DialogBox");
	}
	
}

function SkillInfoClear() //기존의 스킬 정보를 다 지우는 기능
{
	local int i;
	
	ResearchSkillIcon.clear();
	ResearchSkillName.SetNameWithColor("",NCT_Normal,TA_Left, White);
	ResearchSkillDesc.SetText("");
	ResearchSkillLv.SetText("");
	
	ExpectationSkillIcon.clear();	
	ExpectationSkillRoot.SetText("");
	ExpectationSkillDesc.SetText("");
	SucessProbablity.SetText("");
	ResearchRoot_Select_1_0Y.HideWindow();
	ResearchRoot_Select_1_0B.HideWindow();

	for (i = 0; i < SKILL_ENCHANT_NUM; i++)
	{
		ResearchRootIcon[i].Clear();
		ResearchRootBTN[i].DisableWindow();
		ResearchRootText[i].SetText("");
		ResearchRootText2[i].SetText("");
		ResearchRootBTN[i].SetTooltipCustomType(MakeTooltipSimpleText(""));
	}	
	
	EnchantMaterialName.SetText("");
	EnchantMaterialIcon.clear();	
	
	for (i = 0; i < ENCHANT_MATERIAL_NUM; i++)
	{		
		EnchantMaterialInfo[i].SetText("");		
	}	
	
	EnchantMaterialInfo2.SetText("");

	ResearchRoot_Select_1_0B.HideWindow();
	ResearchGuideDesc.SetText(GetSystemString(2048)$"\\n"$GetSystemString(2049));  //"스킬 연구를 시작하겠습니다.\n-먼저 연구하고자 하는 스킬을 연구 전 스킬로 옮겨 주세요."시스템 메시지로 바꿔야 함
	
	btnResearch.SetNameText(GetSystemString(2070));
	btnResearch.DisableWindow();
	//SetAdenaSpInfo();

	//txtMySp.SetText("");
	enchatTypeRadioBtn[0].disableWindow();
	enchatTypeRadioBtn[1].disableWindow();
	enchatTypeRadioBtn[2].disableWindow();	
	curSkillID = 0; 
	curLevel = 0;
	curSubLevel = 0;
	curWantedSkillID = 0;
	curWantedSubLevel = 0;
	curIndex = -1;

	EnchantState = ENCHANT_START;
	curEnchantType = -1;

	ResearchRootSelectbox.HideWindow();
	ResearchSkillSelectbox.ShowWindow();	
}

function string getEnchantSkillName (  itemID itemID, int iLevel, int iSubLevel) 
{
	local string enchantSkillName ;
	local int iLength ;
	enchantSkillName = class'UIDATA_SKILL'.static.GetEnchantName( itemID, iLevel,  iSubLevel/ENCHANT_TYPE_UINT  * ENCHANT_TYPE_UINT +1 );	

	//+1을 뺀 글자
	iLength=Len(enchantSkillName)-3;

	if(iLength>0)
	{
		enchantSkillName=Right(enchantSkillName, iLength);		
	}

	return enchantSkillName;
}


function setBTNTooltip (  int index, ItemID itemID, int iLevel, int iSubLevel) 
{
	local CustomTooltip T;

	local L2Util util;
	local string strSkillName;

	local SkillInfo skillinfo;
	local string changeTitle;
	
	T.MinimumWidth = 125; // 125 로 수정해야함

	util = L2Util(GetScript("L2Util"));//bluesun 커스터마이즈 툴팁 

	util.setCustomTooltip( T );
	util.ToopTipMinWidth( 200 );

	if ( curSubLevel > 0 ) 
	{
		GetSkillInfo(curSkillID, curLevel, curSubLevel, skillInfo);
		strSkillName = class'UIDATA_SKILL'.static.GetEnchantName( itemID, curLevel, curSubLevel );
		util.ToopTipInsertText( GetSystemString (3352) , false, true, util.ETooltipTextType.COLOR_YELLOW, 0, 0 );
		util.ToopTipInsertText( strSkillName, false, true, util.ETooltipTextType.COLOR_DEFAULT, 0, 6 );
		util.ToopTipInsertText( skillInfo.EnchantDesc, false, true, util.ETooltipTextType.COLOR_DEFAULT, 0, 0 );

		util.TooltipInsertItemBlank( 6 );
		util.TooltipInsertItemLine();
		util.TooltipInsertItemBlank( 3 );
	}	
	
	//타입도 같고 이후 서브 레벨도 같은 경우
	if ( curSubLevel == iSubLevel  ) 
	{
		//3356 더이상 강화를 진행 할 수 없습니다.
		util.ToopTipInsertText( GetSystemString ( 3356 ), false, true, util.ETooltipTextType.COLOR_DEFAULT, 0, 0 );	
	}
	else 
	{
		//타입이 같은 경우 현재 서브 레벨이 0인 경우 ( 처음 배우는 경우
		if ( iSubLevel/ENCHANT_TYPE_UINT == curSubLevel /ENCHANT_TYPE_UINT || curSubLevel == 0 )
		{
			//강화 후
			changeTitle = GetSystemString ( 3353 ) ;
		}else 
		{
			//변경 후
			changeTitle = GetSystemString ( 3360 ) ;
		}
		GetSkillInfo(curSkillID, curLevel, iSubLevel, skillInfo);
		strSkillName = class'UIDATA_SKILL'.static.GetEnchantName( itemID, iLevel, iSubLevel );
		util.ToopTipInsertText( changeTitle , false, true, util.ETooltipTextType.COLOR_BLUE, 0, 0 );
		util.ToopTipInsertText( strSkillName, false, true, util.ETooltipTextType.COLOR_DEFAULT, 0, 0 );	
		util.ToopTipInsertText( skillInfo.EnchantDesc, false, true, util.ETooltipTextType.COLOR_DEFAULT, 0, 0 );
	}
	
		
	ResearchRootBTN[index].SetTooltipCustomType(util.getCustomTooltip());
}


function OnEVSkillEnchantInfoWndAddSkill(string param)
{
	local int iID;
	local ItemID itemID;
	local int iLevel;
	local int iSubLevel;
	local string strSkillIconName;
	local string strSkillName;	
	local iteminfo info;
	local int index;


	ParseInt(Param, "iID", iID);
	ParseInt(Param, "iLevel", iLevel);
	ParseInt(Param, "iSubLevel", iSubLevel);
	ParseString(Param, "strSkillIconName", strSkillIconName);
	ParseString(Param, "strSkillName",strSkillName);
	
	//Debug ( "OnEVSkillEnchantInfoWndAddSkill" @ curSubLevel @ param ) ;
	itemID.classID = iID;
	strSkillIconName = class'UIDATA_SKILL'.static.GetEnchantIcon( itemID, iLevel, iSubLevel );
	strSkillName = class'UIDATA_SKILL'.static.GetEnchantName( itemID, iLevel,iSubLevel );
	
	curIndex ++ ;

	//Debug ( "iSubLevel" @ iSubLevel);
	//만약 최대 수치와 같으면 리턴 할 것.
	if ( curIndex >= SKILL_ENCHANT_NUM ) return;

	index = curIndex ;//iSubLevel / ENCHANT_TYPE_UINT - 1;

//	debug(strSkillIconName @ strSkillName @ iID @ "iLevel:"$iLevel@"index:"$index @"iSubLevel:"$iSubLevel);	

	ResearchRootID[index] = iID;
	
	ResearchRootSubLevel[index] = iSubLevel;
//	ResearchRootLevel[index] = iLevel;
	
	ResearchRootSkillIconName[index] = "l2ui_ct1.SkillWnd_DF_Icon_Enchant_"$strSkillIconName;      //아이콘 명이 너무 길어서 스킬 인챈트 아이콘의 공통적인 아이콘명을 UC에서 지정
	ResearchRootSkillName[index] = strSkillName;
	
	info.iconName = ResearchRootSkillIconName[index];//"l2ui_ct1.SkillWnd_DF_Icon_Enchant_"$strSkillIconName; 
																   //스킬 아이콘을 인챈트 아이콘으로 변경
	ResearchRootIcon[index].Clear();
	ResearchRootIcon[index].AddItem( info );
	
	ResearchRootText[index].SetText (makeShortStringByPixel (getEnchantSkillName ( itemID ,iLevel , iSubLevel ), 144, ".." ));
	//ResearchRootText[index].SetText (makeShortStringByPixel ("asdfasdfasdfasdfasdfasdfasdfasdfasdfasdf", 144, ".." ));
	
	SucessProbablity.Hidewindow();		
	
	setBTNTooltip (index, itemID, iLevel, iSubLevel);
	//Debug ( curSubLevel == iSubLevel );
	//Debug ("addCkill" @ curSubLevel/ENCHANT_TYPE_UINT  @  ResearchRootSubLevel[index]/ENCHANT_TYPE_UINT  );
	if ( curSubLevel/ENCHANT_TYPE_UINT == iSubLevel/ENCHANT_TYPE_UINT )
	{			
		//ResearchRootBTN[index].DisableWindow();
		ResearchRoot_Select_1_0Y.ClearAnchor();
		ResearchRoot_Select_1_0Y.SetAnchor( "MagicSkillDrawerWnd.ResearchRootBTN"$index, "TopLeft", "TopLeft", 0, 0);
		ResearchRoot_Select_1_0Y.ShowWindow();

		ResearchRootText[index].SetAnchor ( "MagicSkillDrawerWnd.ResearchRootBTN"$index, "TopLeft", "TopLeft", 44, 7 );
		ResearchRootText2[index].SetText ( "("$GetSystemString ( 3351 )$")" );

		//if ( enableTrain != 0 ) 
		OnResearchRootBTNClick(index);
	} 
	else 
	{
		ResearchRootText[index].SetAnchor ( "MagicSkillDrawerWnd.ResearchRootBTN"$index, "TopLeft", "TopLeft", 44, 16 );
	}

	ResearchRootBTN[index].EnableWindow();
}

function OnTextureAnimEnd( AnimTextureHandle a_WindowHandle )
{
	EnchantProgressAnim.HideWindow();
	EnchantProgressAnim.Stop();
	EnchantProgressAnim.HideWindow();
	switch ( a_WindowHandle )
	{
		case EnchantProgressAnim:
			break;
	}
}

function OnEVSkillEnchantResult(string param)
{
	local int iSuccess;
	
	ParseInt(param, "success", iSuccess);
	
	//	debug("success:"$iSuccess);
	if (iSuccess == 1)
	{
//				m_hVpAgathion.PlayAnimation(2);
		EnchantProgressAnim.SetTexture("l2ui_ct1.ItemEnchant_DF_Effect_Success_00");
		EnchantProgressAnim.ShowWindow();
		EnchantProgressAnim.SetLoopCount( 1 );
		EnchantProgressAnim.Stop();
		EnchantProgressAnim.SetTimes(0.8);
		EnchantProgressAnim.Play();

		// 아레나 서버용 사운드
		if ( getInstanceUIData().getIsArenaServer() ) 
			PlaySound ( "ItemSound3.arena_skill_powerup" );
		else 
			Playsound("ItemSound3.enchant_success");

		ResearchGuideDesc.SetText(GetSystemString(2054)$"\\n"$GetSystemString(2055));		//"스킬 인챈트에 성공하였습니다.\n-인챈트 스킬의 Lv이 상승 하였습니다."
	}
	else
	{
//		m_hVpAgathion.PlayAnimation(2);
		EnchantProgressAnim.SetTexture("l2ui_ct1.ItemEnchant_DF_Effect_Failed_01");
		EnchantProgressAnim.ShowWindow();
		EnchantProgressAnim.SetLoopCount( 1 );
		EnchantProgressAnim.Stop();
		EnchantProgressAnim.Play();
		Playsound("ItemSound3.enchant_fail");

		ResearchGuideDesc.SetText(GetSystemString(2062)$"\\n"$GetSystemString(2063));		//"스킬 인챈트에 실패하였습니다.\n-인챈트 스킬이 오리지널 스킬로 초기화 됩니다.."

	}
}


function OnEVSkillEnchantInfoWndAddExtendInfo(string param)
{
	local int SkillID;
	local int Level;
	local int SubLevel;
	local INT64 SPConsume;
	local int Percent;
	local int itemclassid[2];
	local string strItemIconName[2];
	local string strItemName[2];
	local string strSkillIconName;
	local string strSkillName;

	local int ItemSort;
	local int ItemNum[2];
	local int i;
	local int adenaID;	//아데나
	local int haguinID;	//하거인의비젼서 ID
	local int haguinItemID ; //하거인의비젼서 ID

	//Debug ( "OnEVSkillEnchantInfoWndAddExtendInfo" @ EnchantState);
	if ( EnchantState == ENCHANT_START ) return;

	ResearchRootSelectbox.HideWindow();
	
	ParseInt(Param, "SkillID", SkillID);
	ParseInt(Param, "Level", Level);
	ParseInt(Param, "SubLevel", SubLevel);
	ParseInt(Param, "Percent", Percent);	
	Parseint(Param, "ItemSort", ItemSort);

	for(i = 0; i < ItemSort; i++ )
	{
		ParseInt(Param, "ItemClassID_"$i, itemclassid[i]);
		ParseString(Param, "strItemIconName_"$i,strItemIconName[i]  );
		ParseString(Param, "strItemName_"$i,strItemName[i]);
		ParseInt(Param, "ItemNum_"$i, ItemNum[i]);
	}
	
	if (itemclassid[0] == 57)
	{
		adenaID = 0;
		haguinID = 1;
	}
	else
	{
		adenaID = 1;
		haguinID = 0;
	}
	
	haguinItemID = itemclassid[haguinID];

	ParseString(Param, "strSkillIconName",strSkillIconName);
	ParseString(Param, "strSkillName",strSkillName);
	ParseInt64(Param, "SPConsume", SPConsume);
	
	SetAfterSkillInfo( EnchantState, SkillID, Level, SubLevel, strSkillIconName, strSkillName );
	
//	Debug ( "OnEVSkillEnchantInfoWndAddExtendInfo" @  haguinID @ adenaID @ SPConsume @ Percent @ EnchantState);
	
	setTextByEnchantType();

	//인첸트 최대 레벨일 경우  재료 정보 삭제
	if ( curSubLevel == SubLevel )
	{
		EnchantMaterialName.SetText("");
		EnchantMaterialIcon.clear();
		
		for (i = 0; i < ENCHANT_MATERIAL_NUM; i++)
		{		
			EnchantMaterialInfo[i].SetText("");		
		}	
		EnchantMaterialInfo2.SetText("");
	}
	
	else SetEnchantConsumeInfo ( haguinItemID,  ItemNum[haguinID],  strItemIconName[adenaID],  strItemName[adenaID],  ItemNum[adenaID], SPConsume, Percent, EnchantState);	
}


// 스킬 연구 전 스킬의 정보
function SetCurSkillInfo (ItemInfo info)
{
	local SkillInfo skillinfo;
	
	curSkillID = info.ID.ClassID; 
	curLevel = info.Level;
	curSubLevel = info.SubLevel;

	GetSkillInfo(curSkillID, curLevel, curSubLevel, skillInfo);
	info.Name = skillInfo.SkillName;
	info.Level = skillInfo.SkillLevel;

	info.SubLevel = skillInfo.SkillSubLevel;
	
	info.IconName = class'UIDATA_SKILL'.static.GetIconName( info.ID , info.Level, info.SubLevel );
	info.Description = skillInfo.SkillDesc;
	info.AdditionalName = skillInfo.EnchantName;
	info.IconPanel = skillInfo.IconPanel;
	info.ItemSubType = int(EShortCutItemType.SCIT_SKILL);
	//skillinfo.EnchantSkillLevel = class'UIDATA_SKILL'.static.GetEnchantSkillLevel( info.ID, info.Level );
	
	//i = GetSystemString(88)@skillInfo.EnchantSkillLevel;	// 인챈트 스킬의 오리지널 스킬의 Lv을 표현
	//j = 		// 오리지널 스킬의 Lv을 표현	

	ResearchSkillLv.SetText(GetSystemString(88)@skillInfo.SkillLevel);
	
	ResearchSkillName.SetNameWithColor(makeShortStringByPixel (skillInfo.SkillName, 154, ".." ),NCT_Normal,TA_Left, White);
	//ResearchSkillName.SetNameWithColor(makeShortStringByPixel ("asdfasdfasdfasdfasdfasdfasdfasdfasdf", 154, ".." ),NCT_Normal,TA_Left, White);
	//curEnchantType = info.SubLevel / ENCHANT_TYPE_UINT;

	//Debug ( "SetCurSkillInfo curEnchantType" @ curEnchantType );
	
	if ( info.SubLevel == 0)
	{			
		ResearchSkillDesc.SetText(GetSystemString(2040));		//"인챈트 되지 않은 오리지널 스킬"		
	} 
	else 
	{		
		ResearchSkillDesc.SetText(GetSystemString(2207)); //"현재의 강화 스킬"			
	}

	ResearchSkillIcon.clear( );
	ResearchSkillIcon.AddItem( info );
	//SetAdenaSpInfo();
	ResearchSkillSelectbox.HideWindow();
	ResearchRootSelectbox.ShowWindow();
}

// 스킬 연구 후 스킬 정보

function SetAfterSkillInfo (int EnchantState, int SkillID, int Level, int SubLevel, string strSkillIconName, string strSkillName )
{
	local SkillInfo skillinfo;
	local Iteminfo info;
	//local string i; 
	//local string j;	
	
	info.ID.classID = SkillID;
	info.Level = Level;
	info.SubLevel = SubLevel;
	info.IconName = "l2ui_ct1.SkillWnd_DF_Icon_Enchant_"$ class'UIDATA_SKILL'.static.GetEnchantIcon( info.ID, Level, SubLevel );//strSkillIconName;
	Info.Name = class'UIDATA_SKILL'.static.GetEnchantName( info.ID, Level, SubLevel );//strSkillIconName;strSkillName;	

	//Debug ( "skillName2"@ info.IconName @ info.Name  @ info.ID.classID @ Level @ SubLevel);

	GetSkillInfo(SkillID, Level, SubLevel, skillInfo);	
	
	//i = GetSystemString(88)@skillInfo.EnchantSkillLevel;	// 인챈트 스킬의 오리지널 스킬의 Lv을 표현
	//j = GetSystemString(88)@skillInfo.SkillLevel;			// 오리지널 스킬의 Lv을 표현

	ExpectationSkillIcon.clear();	
	ExpectationSkillIcon.Additem( info);

	ExpectationSkillRoot.SetText(makeShortStringByPixel (skillinfo.EnchantName, 154, ".." ));	
	//ExpectationSkillRoot.SetText(makeShortStringByPixel ("asdfasdfasdfasdfasdfasdfasdfasdfasdfasdf", 154, ".." ));

	//더이상 진행 할 수 없는 경우 
	if ( curSubLevel ==  SubLevel ) 
	{
		ExpectationSkillDesc.SetText(GetSystemString(3356));
	}
	else 
	{
		ExpectationSkillDesc.SetText(skillinfo.EnchantDesc);
	}
//	ExpectationSkillRootLv.SetText("");

	curEnchantType = SubLevel/ENCHANT_TYPE_UINT;
	//Debug ( "SetAfterSkillInfo" @ curEnchantType );

	//Debug ( "SetAfterSkillInfo curEnchantType" @ curEnchantType );

	if ( EnchantState == ENCHANT_ROUTE_CHANGE)
	{	
		if ( curLevel == curWantedSubLevel ) ExpectationSkillDesc.SetText(GetSystemString(2210)); //현재의 강화 방식. 다른 기능 선택하세요.
	}	
}

/*
 *소모 되는 아이템 정보
 */

function SetEnchantConsumeInfo (int haguinClassID, int codexNum, string adenaIconName, string adenaName, int adenaNum, INT64 SPConsume, int Percent, int EnchantState)
{
	local ItemID	haguinID;
	local Iteminfo info_a; //하거인
	local Iteminfo info_b; //아데나
	local ItemInfo Info_c; //SP
	local int i;

	local Color EnchantMaterialInfo2Color;

	local ItemWindowHandle InventoryItem;	

	local iteminfo SupportInfo;

	//Debug ( "SetEnchantConsumeInfo"@ haguinClassID @ codexNum @  adenaIconName @ adenaName @  adenaNum @  SPConsume@  Percent@ EnchantState );

	haguinID.ClassID = haguinClassID;
	class'UIDATA_ITEM'.static.GetItemInfo(haguinID, info_a );

	InventoryItem = GetItemWindowHandle( "InventoryWnd.InventoryItem");

	InventoryItem.GetItem(InventoryItem.FindItem( haguinID ), SupportInfo);
	//debug ( "SetEnchantConsumeInfo" @ SupportInfo.itemNum );

	info_b.IconName = adenaIconName;
	Info_b.Name = adenaName;

	Info_c.IconName = "icon.etc_i.etc_sp_point_i00";
	Info_c.Name = "SP";
	//SetEnchantConsumeInfo ( strItemIconName[0], strItemName[0],  ItemNum[0],  strItemIconName[1],  strItemName[1],  ItemNum[1], SPConsume, Percent, EnchantState);		
	
	if ( EnchantState == ENCHANT_NORMAL )
	{	
		//비전서 아이템 표시		
		EnchantMaterialName.SetText(makeShortStringByPixel (info_a.Name, 158, ".." ));		
		//EnchantMaterialName.SetText(makeShortStringByPixel ("asdfasdfasdfasdfasdfasdfasdfasdfasdfasdf", 160, ".." ));		
		EnchantMaterialInfo[0].SetText(GetSystemString(1514) @ string(codexNum) ) ;
		EnchantMaterialInfo2.SetText ("("$ SupportInfo.itemNum $")");
		EnchantMaterialIcon.Clear();
		EnchantMaterialIcon.Additem(info_a);

		
		//아데나 표시		
		EnchantMaterialInfo[2].SetText(MakeCostString(string(adenaNum)));

		//SP 표시		
		EnchantMaterialInfo[1].SetText(MakeCostString(string(SPConsume)));		

		//성공확률 표시
		SucessProbablity.ShowWindow();
		SucessProbablity.SetText("");
		SucessProbablity.SetText(GetSystemString(642)@string(Percent)@GetSystemString(2042));

		//SetAdenaSpInfo();


	} else if ( EnchantState == ENCHANT_SAFETY )
		//ldw 추가
	{	
		//비전서 아이템 표시
		EnchantMaterialName.SetText(makeShortStringByPixel (info_a.Name, 158, ".." ));
		EnchantMaterialInfo[0].SetText(GetSystemString(1514)@string(codexNum));
		EnchantMaterialInfo2.SetText ("("$ SupportInfo.itemNum $")");
		EnchantMaterialIcon.Clear();
		EnchantMaterialIcon.Additem(info_a);

		//SP 표시		
		EnchantMaterialInfo[1].SetText(MakeCostString(string(SPConsume)));		
		
		//아데나 표시		
		EnchantMaterialInfo[2].SetText(MakeCostString(string(adenaNum)));		

		//성공확률 표시
		SucessProbablity.ShowWindow();
		SucessProbablity.SetText("");
		SucessProbablity.SetText(GetSystemString(642)@string(Percent)@GetSystemString(2042));			

		//SetAdenaSpInfo();		

	} 
	//값을 받아서 하게 되면 ENCHANT_SAFETY 와 같음 
	else if ( EnchantState == ENCHANT_PASS_TICKET)
	{
		//비전서 아이템 표시
		EnchantMaterialName.SetText(makeShortStringByPixel (info_a.Name, 158, ".." ));
		EnchantMaterialInfo[0].SetText(GetSystemString(1514)@string(codexNum));
		EnchantMaterialInfo2.SetText ("("$ SupportInfo.itemNum $")");
		EnchantMaterialIcon.Clear();
		EnchantMaterialIcon.Additem(info_a);			

		//SP 표시		
		EnchantMaterialInfo[1].SetText(MakeCostString(string( SPConsume )));		

		//아데나 표시		
		EnchantMaterialInfo[2].SetText(MakeCostString(string( adenaNum )));		

		//성공확률 표시
		SucessProbablity.ShowWindow();
		SucessProbablity.SetText("");
		SucessProbablity.SetText(GetSystemString(642)@string(Percent)@GetSystemString(2042));

		//SetAdenaSpInfo();
	}else if ( EnchantState == ENCHANT_ROUTE_CHANGE)
	{
		if (curLevel == curWantedSubLevel )
		{
			for (i = 0; i < ENCHANT_MATERIAL_NUM; i++)
			{
				
				EnchantMaterialInfo[i].SetText("");
				
			}
			EnchantMaterialName.SetText("");
			EnchantMaterialInfo2.SetText ("");
			EnchantMaterialIcon.clear();

		} else
		{
			//비전서 아이템 표시
			EnchantMaterialName.SetText(makeShortStringByPixel (info_a.Name, 158, ".." ));
			EnchantMaterialInfo[0].SetText(GetSystemString(1514)@string(codexNum));
			EnchantMaterialInfo2.SetText ("("$ SupportInfo.itemNum $")");
			EnchantMaterialIcon.Clear();
			EnchantMaterialIcon.Additem(info_a);

			//SP 표시
			EnchantMaterialInfo[1].SetText(MakeCostString(string(SPConsume)));

			//아데나 표시
			EnchantMaterialInfo[2].SetText(MakeCostString(string(adenaNum)));

			SucessProbablity.SetText("");
			SucessProbablity.HideWindow();

			//SetAdenaSpInfo();
		}
	}

	if ( SupportInfo.itemNum < codexNum ) 
	{
		//레드
		EnchantMaterialInfo2Color.R = 255;
		EnchantMaterialInfo2Color.G = 111;
		EnchantMaterialInfo2Color.B = 111;
	}
	else 
	{
		//블루
		EnchantMaterialInfo2Color.R = 111;
		EnchantMaterialInfo2Color.G = 111;
		EnchantMaterialInfo2Color.B = 255;		
	}

	EnchantMaterialInfo2.setTextColor ( EnchantMaterialInfo2Color );

	//아이템 개수가 부족 한 경우 

	//Debug ("아이템이 부족 한가?" @ SupportInfo.itemNum @ codexNum @ SPConsume @ GetUserSP() @ adenaNum @ GetAdena() );
	if ( SupportInfo.itemNum < codexNum || SPConsume > GetUserSP() || adenaNum > GetAdena() ) 		
	{		
		ResearchGuideDesc.SetText( GetSystemString ( 3361 ) );
		btnResearch.DisableWindow();
	}	

	needSPConsume =  SPConsume;
	needAdena = adenaNum;
}


function INT64 GetuserSP()
{

	local UserInfo infoPlayer;
	local INT64 iPlayerSP;

	GetPlayerInfo(infoPlayer);
	iPlayerSP = infoPlayer.nSP;

	return iPlayerSP;
}

function handleSetCurrentSkill ( ItemInfo a_ItemInfo )
{	
	//이미 들어간 대상은 다시 넣지 않는다.
	if ( a_ItemInfo.ID.ClassID == curSkillID && curLevel == a_ItemInfo.Level ) return;

	if ( a_ItemInfo.bDisabled > 0 )
	{
		SkillInfoClear();
		//SetAdenaSpInfo();
		ResearchGuideDesc.SetText(GetSystemString(2041));
		AddSystemMessage(3070);
	}
	//닫히고 잇는 중이라면 창을 열지 않는다.
	else 
	{
		SkillInfoClear();	
		byRadioButton ( "" ) ;
		RequestExEnchantSkillInfo(a_ItemInfo.ID.ClassID, a_ItemInfo.Level, a_ItemInfo.SubLevel ); 
		SetCurSkillInfo(a_ItemInfo);
		//SetAdenaSpInfo();
	}
}

function OnDropItem( String a_WindowID, ItemInfo a_ItemInfo, int X, int Y)
{
	local string dragsrcName;
	//local MagicSkillWnd script_a;	

	//script_a = MagicSkillWnd(GetScript("MagicSkillWnd"));
	
	RequestSkillList();
	dragsrcName = Left(a_ItemInfo.DragSrcName,10);

	if ((dragsrcName== "PSkillItem" || dragsrcName == "ASkillItem") )
	{
		handleSetCurrentSkill ( a_ItemInfo );
	}
}


defaultproperties
{
    m_WindowName="MagicSkillDrawerWnd"
}
