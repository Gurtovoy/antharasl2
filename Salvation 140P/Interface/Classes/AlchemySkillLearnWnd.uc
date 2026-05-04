class AlchemySkillLearnWnd extends UICommonAPI;

//////////////////////////////////////////////////////////////////////////////
// CONSTc
//////////////////////////////////////////////////////////////////////////////

const SKILLTYPE_ALCHEMYSKILL = 140;

const OFFSET_X_ICON_TEXTURE=0;
const OFFSET_Y_ICON_TEXTURE=4;
const OFFSET_Y_SECONDLINE = -14;

const OFFSET_Y_MPCONSUME=3;
const OFFSET_Y_CASTRANGE=0;
const OFFSET_Y_SP=120;

const WINDOW_W = 304;
const WINDOW_H_MAX = 510;
const WINDOW_H_MIN = 276;

var int m_iType;
var int m_iID;
var int m_iLevel;
var int m_iSubLevel;

var WindowHandle Me;
var AlchemySkillWnd alchemySkillWndScript;

var String m_WindowName;

var Color colorItemName;

//**스킬 정보 관련(상단)

//스킬 아이콘
var TextureHandle texIcon;
//액티브/패시브 아이콘
var TextureHandle iconActive;

var TextureHandle IconPanel;

//스킬 이름
var TextBoxHandle txtName;
//txtLevel
var TextBoxHandle txtLevel;
//소모MP 수치
var TextBoxHandle txtMP;
//시전시간 수치
var TextBoxHandle txtUseTime;
//재사용시간 수치
var TextBoxHandle txtReuseTime;

//스킬 설명
//var TextBoxHandle txtDescription;
var TreeHandle SkillTrainInfoTree;

//캐릭터Lv 수치
var TextBoxHandle txtNeedChaLv;
//필요SP 수치
var TextBoxHandle txtNeedSP;
//필요아이템[sysstring="2380"]
var TextBoxHandle txtNeedItemString;
//필요아이템 이름
var NameCtrlHandle txtNeedItemName;

//듀얼 클래스용
//SystemString(2969) : 듀얼 클래스 Lv
var TextBoxHandle txtNeedDualLvString;
//중간 콜론
var TextBoxHandle txtColoneDualLv;
//캐릭터 듀얼 클래스 v 수치
var TextBoxHandle txtNeedDualLv;

//소모MP 아이콘
var TextureHandle iconMP;
//시전시간 아이콘
var TextureHandle iconUse;
//재사용 아이콘
var TextureHandle iconReuse;

//var TextureHandle spBg;

var WindowHandle PrevSkillListBox;

var WindowHandle PrevSkillListNone;


var string TREENAME;


//스킬 배우기용 변수
var L2Util util;

//getSkillRequestLevel


function OnRegisterEvent()
{
	RegisterEvent( EV_SkillTrainInfoWndShow );
	// RegisterEvent( EV_SkillTrainInfoWndHide );
	RegisterEvent( EV_SkillTrainInfoWndAddExtendInfo );
	
	// RegisterEvent( EV_SkillLearningDetailInfo );
}

function OnLoad()
{
//	if(CREATE_ON_DEMAND==0)
	SetClosingOnESC();

	OnRegisterEvent();

	Me = GetWindowHandle( "AlchemySkillLearnWnd" );

	texIcon = GetTextureHandle( "AlchemySkillLearnWnd.texIcon" );
	iconActive = GetTextureHandle( "AlchemySkillLearnWnd.iconActive" );
	IconPanel = GetTextureHandle( "AlchemySkillLearnWnd.IconPanel" );

	txtName = GetTextBoxHandle ( "AlchemySkillLearnWnd.txtName" );
	txtLevel = GetTextBoxHandle ( "AlchemySkillLearnWnd.txtLevel" );
	txtMP = GetTextBoxHandle ( "AlchemySkillLearnWnd.txtMP" );
	txtUseTime = GetTextBoxHandle ( "AlchemySkillLearnWnd.txtUseTime" );
	txtReuseTime = GetTextBoxHandle ( "AlchemySkillLearnWnd.txtReuseTime" );
	//txtDescription = GetTextBoxHandle ( "AlchemySkillLearnWnd.txtDescription" );
	txtNeedChaLv = GetTextBoxHandle ( "AlchemySkillLearnWnd.txtNeedChaLv" );
	txtNeedSP = GetTextBoxHandle ( "AlchemySkillLearnWnd.txtNeedSP" );
	txtNeedItemString = GetTextBoxHandle ( "AlchemySkillLearnWnd.txtNeedItemString" );
	txtNeedItemName = GetNameCtrlHandle ( "AlchemySkillLearnWnd.txtNeedItemName" );

	txtNeedDualLvString = GetTextBoxHandle ( "AlchemySkillLearnWnd.txtNeedDualLvString" );
	txtColoneDualLv = GetTextBoxHandle ( "AlchemySkillLearnWnd.txtColoneDualLv" );
	txtNeedDualLv = GetTextBoxHandle ( "AlchemySkillLearnWnd.txtNeedDualLv" );

	iconMP = GetTextureHandle( "AlchemySkillLearnWnd.iconMP" );
	iconUse = GetTextureHandle( "AlchemySkillLearnWnd.iconUse" );
	iconReuse = GetTextureHandle( "AlchemySkillLearnWnd.iconReuse" );
	
	//spBg = GetTextureHandle( "AlchemySkillLearnWnd.spBg" );

	PrevSkillListBox = GetWindowHandle( "AlchemySkillLearnWnd.PrevSkillListBox" );
	PrevSkillListNone = GetWindowHandle( "AlchemySkillLearnWnd.PrevSkillListNone" );

	util = L2Util(GetScript("L2Util"));	
	alchemySkillWndScript = AlchemySkillWnd(GetScript("AlchemySkillWnd"));	

	txtNeedDualLv.HideWindow();
	txtNeedDualLvString.HideWindow();
	txtColoneDualLv.HideWindow();

	txtMP.HideWindow();
	txtUseTime.HideWindow();
	txtUseTime.HideWindow();
	txtReuseTime.HideWindow();

	iconMP.HideWindow();
	iconUse.HideWindow();
	iconReuse.HideWindow();

	iconActive.HideWindow();

	colorItemName.R = 175;
	colorItemName.G = 152;
	colorItemName.B = 120;
}

function OnClickButton( string strBtnID )
{
	switch(strBtnID)
	{
		case "btnLearn" :
			 OnLearn();
			 HideWindow("AlchemySkillLearnWnd");
			 break;

		case "btnGoBackList" :
			 HideWindow("AlchemySkillLearnWnd");
			 //ShowWindowWithFocus("SkillTrainListWnd");
			 break;
	}
}

function OnLearn()
{
// 임시 - lancelot 2007. 3. 26.
	//local int type;
	//type=-1;
	
	//switch(m_iType)
	//{
	//case ESTT_NORMAL :
	//case ESTT_FISHING :
	//case ESTT_CLAN :
	//case ESTT_TRANSFORM :
	//case 5:
	//		// 서브잡스킬
	//case 6:
	//		//채집스킬

	/*
		Debug("RequestAcquireSkill");
		Debug("m_iID" @ m_iID);
		Debug("m_iLevel" @ m_iLevel);
		Debug("m_iType" @ m_iType);
*/

		RequestAcquireSkill(m_iID, m_iLevel, m_iSubLevel, m_iType);

		//case ESTT_SUB_CLAN:
		//RequestAcquireSkillSubClan(m_iID, m_iLevel, m_iType, 0);			// 여기 4번째 인자로 하위 혈맹의 인덱스를 넣을 것. -lpislhy
		//break;
	//default:
	//	break;
	//}
}

function OnHide()
{
	// local MagicSkillWnd sc;

	m_iType = -1;

	//sc = AlchemySkillWnd( GetScript( "AlchemySkillWnd" ) );
	//sc.closeTreeNode();
}


function OnEvent(int Event_ID, string param)
{
	local string strIconName;
	local string strName;
	local INT64 iNumOfItem;

	local int iType;
	local int iID;
	local int iLevel;
	local int iSubLevel;
	
	switch(Event_ID)
	{
		case EV_SkillTrainInfoWndShow :
			 // Debug("-EV_SkillTrainInfoWndShow" @ param);
			 ParseInt(param, "Type", iType);

			 if(iType == SKILLTYPE_ALCHEMYSKILL) 
			 {
				ParseInt(param, "iID", iID);
				ParseInt(param, "iLevel", iLevel);
				ParseInt(param, "iSubLevel", iSubLevel);

				m_iType  = iType;
				m_iID    = iID;
				m_iLevel = iLevel;
				m_iSubLevel = iSubLevel;
				
				Me.ShowWindow();
				Me.SetFocus();

				SkillLearningDetailInfo(param);

				if (!GetWindowHandle("AlchemySkillWnd").IsShowWindow())
				{
					Me.HideWindow();
				}
			 }
			 break;

		case EV_SkillTrainInfoWndAddExtendInfo :
			 //  Debug("EV_SkillTrainInfoWndAddExtendInfo" @ param);			 				
			 // Debug("m_iType" @ m_iType);
			 if(m_iType == SKILLTYPE_ALCHEMYSKILL) 
			 {
				 ParseString(param, "strIconName", strIconName); 
				 ParseString(param, "strName", strName);
				 ParseINT64(param, "iNumOfItem", iNumOfItem);
				
				 AddSkillTrainInfoExtend(strIconName, strName, iNumOfItem);
				 
				 // 스크롤을 위해서 포커스 이동
				 GetWindowHandle("AlchemySkillWnd").SetFocus();
			 }
			 break;

		case EV_SkillTrainInfoWndHide :
			// Debug("EV_SkillTrainInfoWndHide" @ param);
			//if(m_iType == SKILLTYPE_ALCHEMYSKILL) 
			//{
			//	if(IsShowWindow("AlchemySkillLearnWnd"))
			//		HideWindow("AlchemySkillLearnWnd");
			//}
			break;
	}
}



function AddSkillTrainInfo(string strIconName, string strName, int iID, int iLevel, string strOperateType, int iMPConsume, int iCastRange, string strDescription, int iSPConsume, INT64 iEXPConsume, string strEnchantName, string strEnchantDesc, int iPercent)
{
	// 아이템 아이콘
	class'UIAPI_TEXTURECTRL'.static.SetTexture("AlchemySkillLearnWnd.SkillTrainTreeWnd_List1.texIcon", strIconName);
	// 스킬이름
	class'UIAPI_TEXTBOX'.static.SetText("AlchemySkillLearnWnd.SkillTrainTreeWnd_List1.txtName", strName);

	// level 숫자
	class'UIAPI_TEXTBOX'.static.SetInt("AlchemySkillLearnWnd.SkillTrainTreeWnd_List1.txtLevel", iLevel);
	// 작동타입
	// class'UIAPI_TEXTBOX'.static.SetText("AlchemySkillLearnWnd.SkillTrainTreeWnd_List1.txtOperateType", strOperateType);
	// 소모MP
	class'UIAPI_TEXTBOX'.static.SetInt("AlchemySkillLearnWnd.SkillTrainTreeWnd_List1.txtMP", iMPConsume);
	// 스킬설명 
	//class'UIAPI_TEXTBOX'.static.SetText("AlchemySkillLearnWnd.SubWndNormal.txtDescription", strDescription);

	//switch(m_iType)
	//{
	//case ESTT_CLAN :			// 혈맹스킬일때는 필요 혈맹명성치
	//case ESTT_SUB_CLAN:
	//	class'UIAPI_TEXTBOX'.static.SetText("AlchemySkillLearnWnd.SubWndNormal.txtNeedSPString", GetSystemString(1437));
	//	break;
	////case ESTT_NORMAL :			// 그냥은 필요SP
	////case ESTT_FISHING :
	//default:
	//	class'UIAPI_TEXTBOX'.static.SetText("AlchemySkillLearnWnd.SubWndNormal.txtNeedSPString", GetSystemString(365));
	//	break;
	//}
	// 필요SP 숫자
	//class'UIAPI_TEXTBOX'.static.SetInt("AlchemySkillLearnWnd.SubWndNormal.txtNeedSP", iSPConsume);
	
	//if(iCastRange>=0)
	//{
	//	// 보여주고
	//	ShowWindow("AlchemySkillLearnWnd.txtCastRangeString");
	//	ShowWindow("AlchemySkillLearnWnd.txtColoneCastRange");
	//	ShowWindow("AlchemySkillLearnWnd.txtCastRange");
	//	class'UIAPI_TEXTBOX'.static.SetInt("AlchemySkillLearnWnd.txtCastRange", iCastRange);
	//}
	//else
	//{
	//	// 숨겨준다
	//	HideWindow("AlchemySkillLearnWnd.txtCastRangeString");
	//	HideWindow("AlchemySkillLearnWnd.txtColoneCastRange");
	//	HideWindow("AlchemySkillLearnWnd.txtCastRange");
	//}
}

function AddSkillTrainInfoExtend(string strIconName, string strName, INT64 iNumOfItem)
{

	// 아이템 아이콘
	//class'UIAPI_TEXTURECTRL'.static.SetTexture("AlchemySkillLearnWnd.texNeedItemIcon", strIconName);

	// 스킬이름
	//class'UIAPI_TEXTBOX'.static.SetText("AlchemySkillLearnWnd.txtNeedItemName", ConvertNumToText(String(iNUmOfItem)));	

	// 아데나인 경우 
	if (GetSystemString(469) == strName)
	{			
		txtNeedItemName.SetNameWithColor(MakeFullSystemMsg(getSystemMessage(2932), MakeCostStringINT64(iNUmOfItem)), NCT_Normal,TA_Left, colorItemName);
		
		//class'UIAPI_'.static.SetText("AlchemySkillLearnWnd.txtNeedItemName", MakeFullSystemMsg(getSystemMessage(2932), MakeCostStringINT64(iNUmOfItem)));	
	}
	else
	{
		txtNeedItemName.SetNameWithColor(strName @ MakeFullSystemMsg(getSystemMessage(1983), MakeCostStringINT64(iNUmOfItem)), NCT_Normal,TA_Left, colorItemName);
		//class'UIAPI_TEXTBOX'.static.SetText("AlchemySkillLearnWnd.txtNeedItemName",strName @ MakeFullSystemMsg(getSystemMessage(1983), MakeCostStringINT64(iNUmOfItem)));	
	}

	// txtNeedItemString.SetText(strName$" X "$ string(iNUmOfItem));
}

function OnShow()
{
	// HideWindow("AlchemySkillLearnWnd.SubWndEnchant");
	// ShowWindow("AlchemySkillLearnWnd.SubWndNormal");

	// 스킬 창이 닫혀 있다면.. 다시 닫는다.
	if (!GetWindowHandle("AlchemySkillWnd").IsShowWindow())
	{
		Me.HideWindow();
	}
	// 필요한 아이템 정보 숨겨준다
	//HideWindow("AlchemySkillLearnWnd.SubWndNormal.texNeedItemIcon");
	//HideWindow("AlchemySkillLearnWnd.SubWndNormal.txtNeedItemName");
	//~ ShowWindow("AlchemySkillLearnWnd.txtColoneCastRange");	
}


function ShowNeedItems()
{
	// 아이템아이콘과 이름
	// ShowWindow("AlchemySkillLearnWnd.SubWndNormal.texNeedItemIcon");
	// ShowWindow("AlchemySkillLearnWnd.SubWndNormal.txtNeedItemName");
}

function SkillLearningDetailInfo( string param )
{
	//
	local SkillInfo skillinfo;
	
	//스킬 아이디.
	local int ID;
	//스킬 레벨
	local int Level;

	//스킬 서브 레벨
	local int SubLevel;

	//소모 SP
	local INT64 SpConsume;
	//요구레벨 ( 플레이어의 현재 레벨과 비교해서 못배우는 것인지를 판단하면됨)
	local int RequiredLevel;
	//요구레벨 ( 플레이어의 듀얼 클래스 레벨과 비교 하여 못 배우는 것인지를 판단.)
	// local int RequiredDualLevel;

	//Player 정보
	local UserInfo userinfo;

	//스킬 아이디.
	local ItemID cID;

	local string strName;
	local string strIconName;
	
	local string strIconPanel;

	ParseInt(param, "iID", ID);
	ParseInt(param, "iLevel", Level);
	ParseInt(param, "iSubLevel", SubLevel);

	ParseInt64(param, "iSPConsume", SpConsume);

	// 배우기 가능한, 요구 레벨 얻기
	RequiredLevel = alchemySkillWndScript.getSkillRequestLevel(ID, Level);

	if (RequiredLevel == -1) 
	{
		GetWindowHandle("AlchemySkillLearnWnd").HideWindow();
		return;
	}

	// Debug("RequiredLevel" @ RequiredLevel);

	cID = GetItemID(ID);
	GetSkillInfo( ID , Level, SubLevel, skillInfo );
	GetPlayerInfo( userinfo );

	strName = skillInfo.SkillName;
	strIconPanel = skillinfo.IconPanel;
	strIconName = class'UIDATA_SKILL'.static.GetIconName( cID, Level, SubLevel );
	
	texIcon.SetTexture( strIconName );
	
	// if( TypeCheck( skillinfo ) == true )
	// {
		//Insert Node Item - 아이템 아이콘

	// iconActive.SetTexture( "l2ui_ct1.SkillWnd_DF_ListIcon_Active" );
	
	//iconMP.ShowWindow();
	//iconUse.ShowWindow();
	//iconReuse.ShowWindow();

	//스킬 이름
	// 4번은 마스터? 스킬 (주요 스킬이라 노란색으로 표시 하기 위해서..)
	
	if (GetAlchemySkillGradeType(ID, Level) == 4)
		txtName.SetTextColor(util.Yellow03);				
	else
		txtName.SetTextColor(util.BrightWhite);
	
	txtName.SetText( strName );

	//스킬 레벨
	txtLevel.SetText( string( Level ) );

		////스킬 MP 소모량
		//txtMP.SetText( string(skillInfo.MpConsume) );
		////스킬 시전 시간
		//txtUseTime.SetText( util.MakeTimeString( skillInfo.HitTime, skillInfo.CoolTime ) );
		////스킬 재사용 시간
		//txtReuseTime.SetText( util.MakeTimeString( skillInfo.ReuseDelay) );
	//}
	//else
	//{
	//	iconActive.SetTexture( "l2ui_ct1.SkillWnd_DF_ListIcon_Passive" );
		
	//	//iconMP.HideWindow();
	//	//iconUse.HideWindow();
	//	//iconReuse.HideWindow();

	//	//스킬 이름
	//	txtName.SetText( strName );
	//	//스킬 레벨
	//	txtLevel.SetText( string( Level ) );

	//	////스킬 MP 소모량
	//	//txtMP.SetText( "" );
	//	////스킬 시전 시간
	//	//txtUseTime.SetText( "" );
	//	////스킬 재사용 시간
	//	//txtReuseTime.SetText( "" );
	//}

	//스킬 설명	
	util.TreeClear( TREENAME );
	//Root 노드 생성.
	util.TreeInsertRootNode( TREENAME, "root", "" );
	//Insert Node Item - 아이템 이름
	util.TreeInsertTextNodeItem( TREENAME, "root", class'UIDATA_SKILL'.static.GetDescription( cID, Level, 0 ) );

	//캐릭터Lv 수치
	txtNeedChaLv.SetText( string( RequiredLevel ) );

	reSizeWindow();

	//------------------------IconPanel------------------------------->	
	if( strIconPanel == "" ) { strIconPanel = ""; }
	IconPanel.SetTexture( strIconPanel );
	//<------------------------------------------------------------------
	// class'UIAPI_TEXTBOX'.static.SetText("AlchemySkillLearnWnd.txtSP", string( userinfo.nSP ) );
}

function reSizeWindow( optional bool b )
{	
	if( b == true )
	{
		// PrevSkillListBox.ShowWindow();
		// PrevSkillListNone.HideWindow();
		//spBg.SetAnchor( "AlchemySkillLearnWnd.SkillTrainTreeWnd_List1", "BottomLeft", "TopLeft", 0, 5 );
		Me.SetWindowSize( WINDOW_W, WINDOW_H_MAX );
		//needBg.SetTextureSize( 287, 72 );
	}
	else
	{
		//PrevSkillListBox.HideWindow();
		//PrevSkillListNone.ShowWindow();
		//spBg.SetAnchor( "AlchemySkillLearnWnd.SkillTrainTreeWnd_List1", "BottomLeft", "TopLeft", 0, 5 );
		Me.SetWindowSize( WINDOW_W, WINDOW_H_MIN );
		//needBg.SetTextureSize( 287, 47 );
	}
}

function bool TypeCheck( SkillInfo info )
{
	local bool b;

	switch ( info.IconType )
	{
		//------------------ 액티브
		case 0:
		case 1:
		case 2:
		case 3:
		case 4:
		case 5:
		case 6:	// 토글 스킬
		case 7:
		case 8:	// 마법 속성 아이콘
			b = true;
			break;
	}

	return b;
}


/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( m_WindowName ).HideWindow();
}

defaultproperties
{
    m_WindowName="AlchemySkillLearnWnd"
    TREENAME="AlchemySkillLearnWnd.SkillTrainInfoTree"
}
