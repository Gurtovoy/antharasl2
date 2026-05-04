// ----------------------------------------------------------------------------------------------------------
// 
// Name : MagicSkillWnd 를 기준으로 제작된 연금술 UI
// 
//  npc 베로아 , 제피라, 에게서 스킬을 습득 한다. 
// ----------------------------------------------------------------------------------------------------------
class AlchemySkillWnd extends UICommonAPI;

const Skill_MAX_COUNT     = 24;
const Skill_GROUP_COUNT   = 8;

//스킬 가로 갯수
const SKILL_COL_COUNT     = 7;

const Skill_GROUP_COUNT_P = 6;	//패시브용

const SKILL_ITEMWND_WIDTH = 260;
const SKILL_SLOTBG_WIDTH  = 252;
const TOP_MARGIN = 5;
const NAME_WND_HEIGHT     = 20;
const BETWEEN_NAME_ITEM   = 3;

// 스킬 그룹 번호
const SKILL_NORMAL     = 0; // 보통 스킬. 데미지 및 힐, 마법 포함.
const SKILL_BUF        = 1;	// 버프
const SKILL_DEBUF      = 2;	// 디버프
const SKILL_TOGGLE     = 3;	// 토글
const SKILL_SONG_DANCE = 4;	// 송댄스
const SKILL_ITEM       = 5; // 아이템 스킬
const SKILL_HERO       = 6;	// 영웅 스킬
const SKILL_CHANGE     = 7;	// 변신 스킬

const SKILLTYPE_ALCHEMYSKILL = 140;


//////////////////////////////////////////////////////////////////////////////
// CONST
//////////////////////////////////////////////////////////////////////////////
const OFFSET_X_ICON_TEXTURE=0;
const OFFSET_Y_ICON_TEXTURE=4;
const OFFSET_Y_SECONDLINE = -17;

var WindowHandle	m_wndTop;
var WindowHandle	m_wndSkillDrawWnd;
// 액티브용

var bool m_bShow;
var String m_WindowName;

var int currentUserLevel;
var WindowHandle	Drawer;

//스킬 배우기용 변수
var L2Util util;

var bool bDrawBgTree1;
var bool bDrawBgTree2;
var bool bDrawBgTree3;

var string TREENAME;
var string ROOTNAME;
var string LIST1;
var string LIST2;
var string LIST3;

var int selectedRequestLevel, totalSkillCount, addCount;

var string beforeTreeName;

var int nScrollHeight;	   	  // 전체 윈도우의 스크롤 크기 결정

// var AnimTextureHandle TexTabLightActive;

// var AnimTextureHandle TexTabLightPassive;

var TreeHandle m_UITree;

// var ButtonHandle ResearchButton;

// 트리 노드 이름 배열
var array<string> treeNodeNameNewSkillArray;
var array<string> treeNodeNameLevelUpArray;
var string clickedTreeNodeName;

var array<SkillTrainInfo> skillTrainInfoArray;

var int clickedTreeNodeIndex;

var WindowHandle SkillTrainInfoWndScript;

var int levelUpSkillIndex, newSkillIndex;

var UserInfo playerInfo;

var bool bRefreshSelect;
var int mainLevel;

//var int dualLevel;
// var int currentType;

function OnRegisterEvent()
{
	RegisterEvent( EV_SkillTrainListWndShow );
	//RegisterEvent( EV_SkillTrainListWndHide );
	RegisterEvent( EV_SkillTrainListWndAddSkill );

	RegisterEvent(EV_UpdateUserInfo);

	// RegisterEvent(EV_RESTART);
}

function OnLoad()
{
	SetClosingOnESC();

	OnRegisterEvent();

	InitHandle();

	util = L2Util(GetScript("L2Util"));	
	SkillTrainInfoWndScript = GetWindowHandle("AlchemySkillLearnWnd");

	m_bShow = false;
}

function InitHandle()
{
	m_UITree = GetTreeHandle("AlchemySkillWnd.SkillTrainTree");
}

function OnShow()
{
	GetPlayerInfo(playerInfo);
	currentUserLevel = playerInfo.nLevel;
	// 배우기 클릭 상태 초기화
	clickedTreeNodeName = "";
	clickedTreeNodeIndex = -1;

	// RequestSkillList();
	m_bShow = true;
}

function OnHide()
{
	m_bShow = false;

	if (GetWindowHandle("AlchemySkillLearnWnd").IsShowWindow())
		GetWindowHandle("AlchemySkillLearnWnd").HideWindow();
}

function OnEvent(int Event_ID, String param)
{
	//local string strIconName;
	//local string strName;
	//local int iID;
	//local int iLevel;
	//local int iSPConsume;
	//local string strEnchantName;
	//local int NewSkillID;
	//local SkillInfo skillInfo;
	//local UserInfo userinfo;
			
	local int iType;


	// 에르테이아 연금술 스킬 타입 이라면..
	
	// SKILLTYPE_ALCHEMYSKILL : 연금술 타입	
	
	switch(Event_ID)
	{
		case EV_SkillTrainListWndShow :
			 
			 ParseInt(param, "Type"	, iType);

			 if (iType == SKILLTYPE_ALCHEMYSKILL)
			 {   
				ParseInt(param, "Count"	, totalSkillCount);	
				
				//스킬 개수가 없을 때 창을 닫는다 
				//EV_SkillTrainListWndHide 이벤트는 쓰지 않음
				if(totalSkillCount == 0)
				{
					if(IsShowWindow("AlchemySkillWnd"))
						HideWindow("AlchemySkillWnd");

					return;
				}

				GetPlayerInfo(playerInfo);
				currentUserLevel = playerInfo.nLevel;
				TreeClear();
				ShowSkillTree();
				levelUpSkillIndex = 0;
				newSkillIndex = 0;
				bRefreshSelect = false;
				treeNodeNameNewSkillArray.Remove(0, treeNodeNameNewSkillArray.Length);
				treeNodeNameLevelUpArray.Remove(0, treeNodeNameLevelUpArray.Length);
				skillTrainInfoArray.Remove(0, skillTrainInfoArray.Length);

				if(!IsShowWindow("AlchemySkillWnd"))
			 		ShowWindow("AlchemySkillWnd");
			 }
			 break;

		case EV_SkillTrainListWndAddSkill :
			 Debug("스킬 추가" @ param);
			 ParseInt(param, "iType"	, iType);
			 if (iType == SKILLTYPE_ALCHEMYSKILL) 
			 {
				AddSkillTrainListItem(param);
				buildTree();
			 }
			 break;
		
		case EV_UpdateUserInfo :
			 GetPlayerInfo(playerInfo);

			 // 창을 열고 있는 중간에 레벨이 변하면 창을 닫는다.
			 if (currentUserLevel != playerInfo.nLevel)
			 {
				 if(IsShowWindow("AlchemySkillWnd"))
					 HideWindow("AlchemySkillWnd");
			 }
			 currentUserLevel = playerInfo.nLevel;

		     break;
		/*
		case EV_SkillTrainListWndHide:
			 
			 //ParseInt(param, "iType"	, iType);
		     Debug("스킬창 닫는다>>>>>>>>>>>>>");
			
			 if(iType == SKILLTYPE_ALCHEMYSKILL) 
			 {
				if(IsShowWindow("AlchemySkillWnd"))
					 HideWindow("AlchemySkillWnd");
			 }
			 break;	*/	
	}
}

function buildTree()
{
	local int i;

	local bool bGetInfo;

	if (skillTrainInfoArray.Length >= totalSkillCount)
	{
		// 정렬
		quicksortchar(0, skillTrainInfoArray.Length - 1 , false);

		for(i = 0; i < skillTrainInfoArray.Length; i++)
		{
			createTreeNode(skillTrainInfoArray[i]);
			//Debug("clickedTreeNodeName" @ clickedTreeNodeName);
			//Debug("Left(clickedTreeNodeName, 15):" @  Left(clickedTreeNodeName, 15));

			switch(Left(clickedTreeNodeName, 15))
			{
				// 새로운 스킬 습득 트리
				case "root.SKILLLIST1" :  
										  
					 if (bGetInfo == false && treeNodeNameNewSkillArray.Length - 1 >= clickedTreeNodeIndex)
					 {
						// Debug("뉴 스킬" @ clickedTreeNodeName);
								
						beforeTreeName = treeNodeNameNewSkillArray[clickedTreeNodeIndex];
						OnClickButton(treeNodeNameNewSkillArray[clickedTreeNodeIndex]);
						bGetInfo = true;
					 }
					 break;

				// 레벨 업 트리
				case "root.SKILLLIST2" : 
					 if (bGetInfo == false && treeNodeNameLevelUpArray.Length - 1 >= clickedTreeNodeIndex)
					 {
						 // Debug("레벨업 스킬" @ clickedTreeNodeName);
						 beforeTreeName = treeNodeNameLevelUpArray[clickedTreeNodeIndex];
						 OnClickButton(treeNodeNameLevelUpArray[clickedTreeNodeIndex]);
						 bGetInfo = true;
					 }
					 break;
			}
		}	
	}
}

// 버튼클릭 이벤트
function OnClickButton( string strID )
{
//	local int index;

	//Tree용 변수
	local Array<string> Result;
	local string treelist;
	local array<string> SkillIDLevel;
	
//	index = int(Right(strID, 1));	//버튼의 제일 끝 숫자를 따낸다. 

	treelist = Left(strID, 4);
	
	// Debug("트리 클릭 " @ strID);

	//Tree를 클릭 했을 시에만 
	if( treelist == ROOTNAME )
	{			
		Split( strID, ".", Result );

		// Debug("트리 클릭 확인" @ strID);

		if( Result.Length > 2)
		{
			if( Result[1] == LIST1 || Result[1] == LIST2 )// || Result[1] == LIST3 )
			{
				if( beforeTreeName != strID )
				{
					m_UITree.SetExpandedNode( beforeTreeName, false );
				}
				else
				{
					m_UITree.SetExpandedNode( beforeTreeName, true );
				}

				beforeTreeName = strID;
			}
			else
			{
				m_UITree.SetExpandedNode( strID, false );
			}

			if( Result[1] == LIST1 || Result[1] == LIST2 )
			{				
				Split( Result[2], ",", SkillIDLevel );				
				clickedTreeNodeName = strID;
				clickedTreeNodeIndex = int(SkillIDLevel[2]);

				//Debug("- 클릭인덱스" @ SkillIDLevel[2]);
				//Debug("SkillIDLevel[0]" @ SkillIDLevel[0]);
				//Debug("SkillIDLevel[1]" @ SkillIDLevel[1]);
				
				// selectedRequestLevel = 

				//GetWindowHandle("AlchemySkillWnd.SkillTrain").GetWindowSize(nWndWidth, nWndHeight);

				//Debug("nWndWidth" @ nWndWidth);
				//Debug("nWndHeight" @ nWndHeight);
				//Debug("nWndHeight" @ GetWindowHandle("AlchemySkillWnd.SkillTrain").);

				// nScrollHeight = nScrollHeight - nWndHeight - BETWEEN_NAME_ITEM;	// 사이즈가 변했기 때문에 스크롤 높이를 조절해준다. 
				
				//연금술 서브 스킬레벨은 0입니다. 하지만 서브 스킬 받는 방법을 연구해서 처리 하도록 할 것
				Debug("-------> RequestAcquireSkillInfo");
				RequestAcquireSkillInfo( int(SkillIDLevel[0]), int(SkillIDLevel[1]), 0,  SKILLTYPE_ALCHEMYSKILL );
			}
		}
	}
}

// 트리 비우기
function TreeClear()
{
	class'UIAPI_TREECTRL'.static.Clear( TREENAME );
}

function ShowSkillTree()
{	
	//Root 노드 생성.
	util.TreeHandleInsertRootNode( m_UITree, ROOTNAME, "", 0, 4 );
	//+버튼 있는 상위 노드 생성
	util.TreeHandleInsertExpandBtnNode( m_UITree, LIST1, ROOTNAME );
	//위의 노드에 글씨 아이템 추가
	util.TreeHandleInsertTextNodeItem( m_UITree, ROOTNAME$"."$LIST1, GetSystemString(2370), 5, 0, util.ETreeItemTextType.COLOR_DEFAULT, true );
	
	//+버튼 있는 상위 노드 생성
	util.TreeHandleInsertExpandBtnNode( m_UITree, LIST2, ROOTNAME );
	//위의 노드에 글씨 아이템 추가
	util.TreeHandleInsertTextNodeItem( m_UITree, ROOTNAME$"."$LIST2, GetSystemString(2371), 5, 0, util.ETreeItemTextType.COLOR_DEFAULT, true );

	//+버튼 있는 상위 노드 생성
	util.TreeHandleInsertExpandBtnNode( m_UITree, LIST3, ROOTNAME );
	//위의 노드에 글씨 아이템 추가
	util.TreeHandleInsertTextNodeItem( m_UITree, ROOTNAME$"."$LIST3, GetSystemString(2372), 5, 0, util.ETreeItemTextType.COLOR_DEFAULT, true );

	m_UITree.SetExpandedNode( ROOTNAME$"."$LIST1, true );
	m_UITree.SetExpandedNode( ROOTNAME$"."$LIST2, true );
	m_UITree.SetExpandedNode( ROOTNAME$"."$LIST3, true );
}

// requestLevel을 얻어 낸다. 
function int getSkillRequestLevel(int nSkillID, int nSkillLevel)
{
	local int i, rValue;

	// 값이 없다면.. -1
	rValue = -1;

	for (i = 0; i < skillTrainInfoArray.Length; i++)
	{
		if (skillTrainInfoArray[i].id == nSkillID  && skillTrainInfoArray[i].level == nSkillLevel)
		{
			rValue = skillTrainInfoArray[i].requiredLevel;
			break;
		}
	}

	return rValue;
}

//function AddSkillTrainListItem(string strIconName, string strName, int iID, int iLevel, int iSPConsume, string strEnchantName)
function AddSkillTrainListItem( string param )
{
	//스킬 아이디.
	local int ID;
	//스킬 레벨
	local int Level;
	local int SubLevel;
	//소모 SP
	local INT64 SpConsume;
	//요구레벨 ( 플레이어의 현재 레벨과 비교해서 못배우는 것인지를 판단하면됨)
	local int RequiredLevel;
	
	//요구레벨 ( 플레이어의 듀얼 클래스 레벨과 비교 하여 못 배우는 것인지를 판단.)
	// local int RequiredDualLevel;

	local string strName;
	local string strIconName;

	local string strEnchantName;
	local SkillTrainInfo Info;

		
	

	ParseString(param, "strIconName", strIconName); 
	ParseString(param, "strName", strName);
	ParseString(param, "strEnchantName", strEnchantName);

	ParseInt(param   , "iID", ID);
	ParseInt(param   , "iLevel", Level);	
	ParseInt(param   , "iSubLevel", SubLevel);	

	
	
	ParseInt(param   , "iRequiredLevel", RequiredLevel);
	ParseInt64(param , "iSPConsume", SPConsume);
	
	if (ID <= 0) return;

	addCount++;
	Info.id = ID;
	Info.level = Level;
	Info.sublevel = SubLevel;
	Info.spConsume = SPConsume;
	Info.requiredLevel = RequiredLevel;
	
	Info.strName = strName;
	Info.strIconName = strIconName;
	Info.strEnchantName = strEnchantName;

	skillTrainInfoArray[skillTrainInfoArray.Length] = Info;
}

function createTreeNode(SkillTrainInfo info)
{
	local SkillInfo skillinfo;
	local string setTreeName;
	local string panelName;
	local int Level, ID, RequiredLevel;
	local string strName;	
	local string strIconName;


	//Player 정보
	local UserInfo userinfo;

	//스킬 아이디.
	local ItemID cID;

	local string strRetName;
	local CustomTooltip T;

	local bool isMaster;

	// Debug("skillTrainInfoArray"@ skillTrainInfoArray.Length);

	ID = info.ID;
	RequiredLevel = info.requiredLevel;

	cID = GetItemID(info.ID);
	//연금술 스킬은 subLevel 이 0임
	GetSkillInfo( info.ID , info.Level, info.SubLevel, skillInfo );
	GetPlayerInfo( userinfo );

	strName = skillInfo.SkillName;
	strIconName = class'UIDATA_SKILL'.static.GetIconName( cID, info.level, info.SubLevel );
	panelName = skillInfo.IconPanel;
	Level = info.level;
	
	// Debug("param  ->" @ param);
	
	// Debug( "strName>>>>" $  strName );
	// Debug( "ID>>>>>" $ string( ID ) );
	// Debug( "Level>>>>>" $ string( Level ) );	
	// Debug( "SpConsume>>>>>" $ string( SpConsume ) );	
	//Debug( "RequiredLevel>>>>>" $ string( RequiredLevel ) );	
	//Debug( "RequiredDualLevel>>>>>" $ string( RequiredDualLevel ) );	
	//debug("class'UIDATA_SKILL'.static.SkillIsNewOrUp( cID )>>>" $ string( class'UIDATA_SKILL'.static.SkillIsNewOrUp( cID ) ) );
	

	//툴팁생성.
	util.setCustomTooltip( T );
	util.ToopTipMinWidth( 200 );
	
	MakeSkillToolTip( strName, cID, Level, info );	

	// 4번은 마스터? 스킬 (주요 스킬이라 노란색으로 표시 하기 위해서..)
	if (GetAlchemySkillGradeType(ID, Level) == 4)
		isMaster = true;
	else
		isMaster = false;

	// Debug("isMaster" @ isMaster);

	//if(RequiredDualLevel > 0 )
	//{
	//	currentMainLevel = mainLevel;	
	//	currentDualLevel = dualLevel;
	//}
	//else
	//{
	//	currentMainLevel = userinfo.nLevel;
	//	currentDualLevel = userinfo.nLevel;
	//}

	//userinfo.nLevel

	// if( RequiredLevel <= currentMainLevel && RequiredDualLevel <= currentDualLevel)
	if( RequiredLevel <= playerInfo.nLevel)	
	{
		//if( class'UIDATA_SKILL'.static.SkillIsNewOrUp( cID ) == 0 )
		// 레벨이 1과 같다면 새로 배울 스킬, 그게 아니면 레벨업 할 스킬
		if( Level == 1 )
		{		
			// 새로 배울 스킬
			setTreeName = ROOTNAME$"."$LIST1;			
			strRetName = util.TreeInsertItemTooltipNode( TREENAME, ""$ ID $","$ Level  $","$ newSkillIndex, setTreeName, -7, 0, 38, 0, 30, 38, util.getCustomTooltip() );

			treeNodeNameNewSkillArray[newSkillIndex] = strRetName;
			//Debug("treeNodeNameNewSkillArray[newSkillIndex]->" @ treeNodeNameNewSkillArray[newSkillIndex]);
			newSkillIndex++;

			if( bDrawBgTree1 )
			{
				//Insert Node Item - 아이템 배경?
				util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "L2UI_CH3.etc.textbackline", 262, 38, , , , ,14 );
			}
			else
			{
				util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "L2UI_CT1.EmptyBtn", 262, 38 );
			}

			bDrawBgTree1 = !bDrawBgTree1;

			//********************************************************************************************************************************************************************

			//Insert Node Item - 아이템슬롯 배경
			util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "L2UI_ct1.ItemWindow.ItemWindow_df_slotbox_2x2", 36, 36, -251, 2 );
			//Insert Node Item - 아이템 아이콘
			util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, strIconName, 32, 32, -34, OFFSET_Y_ICON_TEXTURE - 1 );
			
			//-----------------------------------------------IconPanel--------------------------------------------------------------------------------------->
			if( skillInfo.IconPanel != "" )
				util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, panelName, 32, 32, -32, OFFSET_Y_ICON_TEXTURE - 1 );
			//<--------------------------------------------------------------------------------------------------------------------------------------------------

			//Operate Type(액티브/패시브)
			//if( TypeCheck( skillinfo ) == true )
			//if( class'UIDATA_SKILL'.static.GetOperateType(cID, Level) == GetSystemString(311) )
			//{
				//Insert Node Item - 아이템 아이콘
				// util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "l2ui_ct1.SkillWnd_DF_ListIcon_Active", 32, 32, -33, OFFSET_Y_ICON_TEXTURE - 2 );
				
				if (isMaster)
				{
					util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, strName, 5, 5, util.ETreeItemTextType.YELLOW03, true );
				}
				else
				{
					//Insert Node Item - 아이템 이름
					util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, strName, 5, 5, util.ETreeItemTextType.COLOR_DEFAULT, true );
				}
				//Insert Node Item - "Lv"
				util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, GetSystemString(88), 46, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GRAY, true, true );
				//Insert Node Item - 레벨 값
				util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, string(Level), 2, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GOLD );

				////Insert Node Item - MP물약 아이콘 ( 소모엠피 )
				//util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "L2UI_CT1.SkillWnd_DF_ListIcon_MP", 15, 15, 5, OFFSET_Y_SECONDLINE + 1 );
				////Insert Node Item - "소모엠피 값"
				//util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, string(skillInfo.MpConsume), 0, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GRAY );
				////Insert Node Item - 시간 아이콘 ( 시전시간 )
				//util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "L2UI_CT1.SkillWnd_DF_ListIcon_use", 15, 15, 5, OFFSET_Y_SECONDLINE + 1 );
				////Insert Node Item - "시전시간 값"
				//util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, util.MakeTimeString( skillInfo.HitTime, skillInfo.CoolTime ), 0, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GRAY );
				////Insert Node Item - 시간 아이콘 ( 재사용시간 )
				//util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "L2UI_CT1.SkillWnd_DF_ListIcon_Reuse", 15, 15, 5, OFFSET_Y_SECONDLINE + 1 );
				////Insert Node Item - "재사용시간 값"
				//util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, util.MakeTimeString( skillInfo.ReuseDelay ) , 0, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GRAY );
			//}
			//else
			//{
			//	util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "l2ui_ct1.SkillWnd_DF_ListIcon_Passive", 32, 32, -33, OFFSET_Y_ICON_TEXTURE - 2 );

			//	//Insert Node Item - 아이템 이름
			//	util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, strName, 5, 5, util.ETreeItemTextType.COLOR_DEFAULT, true );
			//	//Insert Node Item - "Lv"
			//	util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, GetSystemString(88), 46, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GRAY, true, true );
			//	//Insert Node Item - 레벨 값
			//	util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, string(Level), 2, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GOLD );
			//}
		}
		else
		{	
			//if( RequiredLevel <= _currentMainLevel && RequiredDualLevel <= _currentDualLevel)
			if( RequiredLevel <= playerInfo.nLevel)
			{
				// 레벨업 할 스킬 
				setTreeName = ROOTNAME$"."$LIST2;
				strRetName = util.TreeInsertItemTooltipNode( TREENAME, ""$ ID $","$ Level $","$ levelUpSkillIndex , setTreeName, -7, 0, 38, 0, 32, 38, util.getCustomTooltip() );
				treeNodeNameLevelUpArray[levelUpSkillIndex] = strRetName;
				//Debug("treeNodeNameNewSkillArray[newSkillIndex]->" @ treeNodeNameLevelUpArray[levelUpSkillIndex]);

				levelUpSkillIndex++;

				if( bDrawBgTree2 )
				{
					//Insert Node Item - 아이템 배경?
					util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "L2UI_CH3.etc.textbackline", 257, 38, , , , ,14 );
				}
				else
				{
					util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "L2UI_CT1.EmptyBtn", 257, 38 );
				}

				bDrawBgTree2 = !bDrawBgTree2;

				//********************************************************************************************************************************************************************

				//Insert Node Item - 아이템슬롯 배경
				util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "L2UI_ct1.ItemWindow.ItemWindow_df_slotbox_2x2", 36, 36, -251, 2 );
				//Insert Node Item - 아이템 아이콘
				util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, strIconName, 32, 32, -34, OFFSET_Y_ICON_TEXTURE - 1 );

				//-----------------------------------------------IconPanel--------------------------------------------------------------------------------------->
				if( skillInfo.IconPanel != "" )
					util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, panelName, 32, 32, -32, OFFSET_Y_ICON_TEXTURE - 1 );
				//<--------------------------------------------------------------------------------------------------------------------------------------------------
				
				if (isMaster)
				{
					util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, strName, 5, 5, util.ETreeItemTextType.YELLOW03, true );
				}
				else
				{
					//Insert Node Item - 아이템 이름
					util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, strName, 5, 5, util.ETreeItemTextType.COLOR_DEFAULT, true );
				}
				//insert node item - "lv"
				util.treehandleinserttextnodeitem( m_uitree, strretname, getsystemstring(88), 46, offset_y_secondline, util.etreeitemtexttype.color_gray, true, true );
				//insert node item - 레벨 값
				util.treehandleinserttextnodeitem( m_uitree, strretname, string(level), 2, offset_y_secondline, util.etreeitemtexttype.color_gold );

				////Operate Type(액티브/패시브)
				////if( class'UIDATA_SKILL'.static.GetOperateType(cID, Level) == GetSystemString(311) )
				//if( TypeCheck( skillinfo ) == true )
				//{
				//	//Insert Node Item - 아이템 아이콘
				//	util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "l2ui_ct1.SkillWnd_DF_ListIcon_Active", 32, 32, -34, OFFSET_Y_ICON_TEXTURE - 1 );

				//	//Insert Node Item - 아이템 이름
				//	util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, strName, 5, 5, util.ETreeItemTextType.COLOR_DEFAULT, true );
				//	//Insert Node Item - "Lv"
				//	util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, GetSystemString(88), 46, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GRAY, true, true );
				//	//Insert Node Item - 레벨 값
				//	util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, string(Level), 2, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GOLD );
				//	////Insert Node Item - MP물약 아이콘 ( 소모엠피 )
				//	//util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "L2UI_CT1.SkillWnd_DF_ListIcon_MP", 15, 15, 5, OFFSET_Y_SECONDLINE + 1 );
				//	////Insert Node Item - "소모엠피 값"
				//	//util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, string(skillInfo.MpConsume), 0, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GRAY );
				//	////Insert Node Item - 시간 아이콘 ( 시전시간 )
				//	//util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "L2UI_CT1.SkillWnd_DF_ListIcon_use", 15, 15, 5, OFFSET_Y_SECONDLINE + 1 );
				//	////Insert Node Item - "시전시간 값"
				//	//util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, util.MakeTimeString( skillInfo.HitTime, skillInfo.CoolTime ), 0, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GRAY );
				//	////Insert Node Item - 시간 아이콘 ( 재사용시간 )
				//	//util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "L2UI_CT1.SkillWnd_DF_ListIcon_Reuse", 15, 15, 5, OFFSET_Y_SECONDLINE + 1 );
				//	////Insert Node Item - "재사용시간 값"
				//	//util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, util.MakeTimeString( skillInfo.ReuseDelay ) , 0, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GRAY );
				//}
				//else
				//{
				//	util.treehandleinserttexturenodeitem( m_uitree, strretname, "l2ui_ct1.skillwnd_df_listicon_passive", 32, 32, -34, offset_y_icon_texture - 1 );

				//	//insert node item - 아이템 이름
				//	util.treehandleinserttextnodeitem( m_uitree, strretname, strname, 5, 5, util.etreeitemtexttype.color_default, true );
				//	//insert node item - "lv"
				//	util.treehandleinserttextnodeitem( m_uitree, strretname, getsystemstring(88), 46, offset_y_secondline, util.etreeitemtexttype.color_gray, true, true );
				//	//insert node item - 레벨 값
				//	util.treehandleinserttextnodeitem( m_uitree, strretname, string(level), 2, offset_y_secondline, util.etreeitemtexttype.color_gold );
				//}
			}
		}	
	}
	else
	{		
		setTreeName = ROOTNAME$"."$LIST3;
		strRetName = util.TreeInsertItemTooltipNode( TREENAME, ""$ ID $","$ Level, setTreeName, -7, 0, 38, 0, 32, 38, util.getCustomTooltip() );

		if( bDrawBgTree3 )
		{
			//Insert Node Item - 아이템 배경?
			util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "L2UI_CH3.etc.textbackline", 257, 38, , , , ,14 );
		}
		else
		{
			util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "L2UI_CT1.EmptyBtn", 257, 38 );
		}

		bDrawBgTree3 = !bDrawBgTree3;

		//********************************************************************************************************************************************************************

		//Insert Node Item - 아이템슬롯 배경
		util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "L2UI_ct1.ItemWindow.ItemWindow_df_slotbox_2x2", 36, 36, -251, 2 );
		//Insert Node Item - 아이템 아이콘
		util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, strIconName, 32, 32, -34, OFFSET_Y_ICON_TEXTURE - 1 );

		util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "l2ui_ct1.ItemWindow_IconDisable", 32, 32, -32, OFFSET_Y_ICON_TEXTURE - 1 );

		//Operate Type(액티브/패시브)
		//if( class'UIDATA_SKILL'.static.GetOperateType(cID, Level) == GetSystemString(311) )
		if( TypeCheck( skillinfo ) == true )
		{
			//Insert Node Item - 아이템 아이콘
			util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "l2ui_ct1.SkillWnd_DF_ListIcon_Active", 32, 32, -34, OFFSET_Y_ICON_TEXTURE - 1 );		}
		else
		{
			//Insert Node Item - 아이템 아이콘
			util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "l2ui_ct1.SkillWnd_DF_ListIcon_Passive", 32, 32, -34, OFFSET_Y_ICON_TEXTURE - 1 );
		}

		//Insert Node Item - 아이템 이름
		util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, strName, 5, 5, util.ETreeItemTextType.COLOR_DEFAULT, true );

		//Insert Node Item - "캐릭터 Lv"
		util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, GetSystemString(2381) $ " : ", 46, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GRAY, true, true );

		//Insert Node Item - 요구 레벨 값
		util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, string(RequiredLevel), 2, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_RED );
		//********************************************************************************************************************************************************************
	}


	//if (addCount >= totalSkillCount)
	//{
	//	if (bRefreshSelect == false)
	//	{
	//		switch(Left(clickedTreeNodeName, 15))
	//		{
	//			case "root.SKILLLIST1" :  
										  
	//									 if (treeNodeNameNewSkillArray.Length - 1 >= clickedTreeNodeIndex)
	//									 {
	//										for (i = 0; i < treeNodeNameNewSkillArray.Length; i++)
	//										{
	//											if (clickedTreeNodeName == treeNodeNameNewSkillArray[i])
	//											{
	//												Debug("뉴 스킬" @ clickedTreeNodeName);
													
	//												beforeTreeName = treeNodeNameNewSkillArray[clickedTreeNodeIndex];
	//												OnClickButton(treeNodeNameNewSkillArray[clickedTreeNodeIndex]);
	//												break;
	//											}
	//										}
	//										bRefreshSelect = true;

	//									 }
	//									 break;

	//			case "root.SKILLLIST2" : 
	//									 if (treeNodeNameLevelUpArray.Length - 1 >= clickedTreeNodeIndex)
	//									 {
	//										for (i = 0; i < treeNodeNameLevelUpArray.Length; i++)
	//										{
	//											if (clickedTreeNodeName == treeNodeNameLevelUpArray[i])
	//											{
	//												Debug("레벨업 스킬" @ clickedTreeNodeName);
	//												 bRefreshSelect = true;
	//												 beforeTreeName = treeNodeNameLevelUpArray[clickedTreeNodeIndex];
	//												 OnClickButton(treeNodeNameLevelUpArray[clickedTreeNodeIndex]);
	//												 break;
	//											}
	//										}
	//									 }
	//									 break;
	//		}
	//	}
	//}

	/*
	switch(m_iType)
	{
	case ESTT_CLAN :
	case ESTT_SUB_CLAN:
		infNodeItem.t_strText = GetSystemString(1437)$" : ";
		break;
	//case ESTT_NORMAL :
	//case ESTT_FISHING :
	//case 4:
	default:
		infNodeItem.t_strText = GetSystemString(365)$" : ";
		break;
	}
	*/
}

function MakeSkillToolTip( string strName, ItemID ID, int Level, SkillTrainInfo pSkillTrainInfo )
{	
	local SkillInfo skillinfo;

	local int skillID;

	//요구레벨 ( 플레이어의 현재 레벨과 비교해서 못배우는 것인지를 판단하면됨)
	local int RequiredLevel;
	//요구레벨 ( 플레이어의 듀얼 클래스 레벨과 비교 하여 못 배우는 것인지를 판단.)
	// local int RequiredDualLevel;

	//스킬에 필요한 아이템 갯수 
	// local int RequiredItemTotalCnt;
	//ItemID (위에 총 갯수만큼 반복) 
	// local int requiredItemID;
	//Item 필요갯수 (위에 총 갯수만큼 반복) 
	// local int requiredItemCnt;


	//스킬에 필요한 선행 스킬 갯수 
	//local INT64 RequiredSkillCnt;
	//필요 Skill의 ID (위에 총 갯수만큼 반복) 
	// local int requiredSkillID;
	//필요 Skill의 level (위에 총 갯수만큼 반복) 
	// local int requiredSkillLevel;


	// local itemID requiredID;

	// local int i;

	//local string additionalName;
	local int nTmp;


	if ( !m_bShow ) return;

	//ParseInt(param, "iID", skillID);

	skillID = pSkillTrainInfo.id;
	RequiredLevel = pSkillTrainInfo.requiredLevel;
	
	GetSkillInfo( skillID , Level, 0, skillInfo );

	// ParseInt(param, "iRequiredLevel", RequiredLevel);
	// ParseInt(param, "RequiredDualLevel", RequiredDualLevel);

	// ParseInt(param, "RequiredItemTotalCnt", RequiredItemTotalCnt);
	// ParseINT64(param, "RequiredSkillCnt", RequiredSkillCnt);

	//additionalName = class'UIDATA_ITEM'.static.GetItemAdditionalName( ID );

	//아이템 이름
	// Debug("-----" @ strName);
	if (GetAlchemySkillGradeType(skillID, Level) == 4)
	{
		util.ToopTipInsertText( strName, true, false, util.ETooltipTextType.COLOR_YELLOW03 );	
		// Debug("isMaster" @ true @ "skillID" @ skillID @ "Level" @ Level);
	}
	else
	{
		util.ToopTipInsertText( strName, true, false, util.ETooltipTextType.COLOR_DEFAULT );	
		// Debug("isMaster" @ true @ "skillID" @ skillID @ "Level" @ Level);
	}
	
	//ex) " Lv "
	util.ToopTipInsertText( " " $ GetSystemString(88), true, false, util.ETooltipTextType.COLOR_GRAY );
	//스킬 레벨
	util.ToopTipInsertText( " " $ string(Level), true, false, util.ETooltipTextType.COLOR_GOLD );
	
	//인챈트 내용
	//util.ToopTipInsertText( additionalName, true, false, util.ETooltipTextType.COLOR_GOLD, 5 );

	//Operate Type(액티브/패시브)
	util.ToopTipInsertText( class'UIDATA_SKILL'.static.GetOperateType( ID, Level, 0 ), true, true, util.ETooltipTextType.COLOR_GOLD, 0, 6 );

	util.TooltipInsertItemBlank( 6 );

	//소모HP
	nTmp = class'UIDATA_SKILL'.static.GetHpConsume( ID, Level, 0 );
	if (nTmp>0)
	{
		util.TwoWordCombineColon( GetSystemString(1195), string( nTmp ), util.ETooltipTextType.COLOR_GRAY, util.ETooltipTextType.COLOR_GOLD, true );
	}

	//소모MP
	nTmp = class'UIDATA_SKILL'.static.GetMpConsume( ID, Level, 0 );
	if (nTmp>0)
	{
		util.TwoWordCombineColon( GetSystemString(320), string( nTmp ), util.ETooltipTextType.COLOR_GRAY, util.ETooltipTextType.COLOR_GOLD, true );
	}

	////유효거리
	//nTmp = class'UIDATA_SKILL'.static.GetCastRange( ID, Level );
	//if (nTmp>=0)
	//{
	//	util.TwoWordCombineColon( GetSystemString(321), string( nTmp ), util.ETooltipTextType.COLOR_GRAY, util.ETooltipTextType.COLOR_GOLD, true );
	//}
	
	////시전시간 값
	//if( class'UIDATA_SKILL'.static.GetOperateType( ID, Level ) == GetSystemString(311) )
	//{
	//	util.TwoWordCombineColon( GetSystemString(2377), util.MakeTimeString( int(skillInfo.HitTime ), int(skillInfo.CoolTime ) ), util.ETooltipTextType.COLOR_GRAY, util.ETooltipTextType.COLOR_GOLD, true );
	//}

	////재사용시간
	//if( class'UIDATA_SKILL'.static.GetOperateType( ID, Level ) == GetSystemString(311) )
	//{
	//	util.TwoWordCombineColon( GetSystemString(2378), util.MakeTimeString( int(skillInfo.ReuseDelay ) ), util.ETooltipTextType.COLOR_GRAY, util.ETooltipTextType.COLOR_GOLD, true );
	//}

	//스킬 설명
	util.ToopTipInsertText( class'UIDATA_SKILL'.static.GetDescription( ID, Level, 0 ), false, true, util.ETooltipTextType.COLOR_GRAY, 0, 6 );

	util.TooltipInsertItemBlank( 6 );
	util.TooltipInsertItemLine();
	util.TooltipInsertItemBlank( 3 );

	//<배우기 조건>
	util.ToopTipInsertText( "<"$GetSystemString(2375)$">", true, true );
	util.TwoWordCombineColon( GetSystemString(2381), string(RequiredLevel), util.ETooltipTextType.COLOR_GRAY, util.ETooltipTextType.COLOR_GOLD, true );
}

/**
 * 스킬 타입 구분
 **/ 
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

///**
// * 외부에서 스킬 학습을 배울때 콜 한다.
// **/
//function externalCallLearnSkill()
//{
//	// 윈도우 열기
//	m_wndTop.ShowWindow();

//	// 스킬 배우기 탭으로 이동
//	GetTabHandle("AlchemySkillWnd.TabCtrl").SetTopOrder(2, false);

//	// 탭 누른 경우 처리 
//	onClickButton("TabCtrl2");	
//}

 /**
  *  트리 닫기
  */
function closeTreeNode()
{
	m_UITree.SetExpandedNode( beforeTreeName, false );
	beforeTreeName = "";
}

/**
 * 정렬, level 기준으로 
 * @example quicksortchar(0, productInfoArray.Length - 1 , true);
 */
function quickSortChar(int left, int right, bool desc )
{
	local int q;

	if( right - left == 0 )
	{
		return;
	}
	else if( left < right )
	{
		q = partitionChar(left,right, desc);
		quickSortChar(left, q - 1, desc);
		quickSortChar( q + 1, right, desc);
	}
}

/** 정렬, partitionChar */
function int partitionChar(int low, int high, bool desc )
{
	local string pivot;
	local string temp;
	local int i;
	local int j;
	//productInfoArray[low].sortString;
		
	pivot = Caps(skillTrainInfoArray[low].level);
	j = low;

	for(i = low + 1 ; i <= high ; i++)
	{
		temp = Caps(skillTrainInfoArray[i].level);
		if( desc )
		{
			if( temp > pivot )
			{
				j++;
				swap(i,j);
			}
		}
		else
		{
			if( temp < pivot )
			{
				j++;
				swap(i,j);
			}
		}		
	}	
	swap(low,j);
	return j;
}

/** 정렬, swap */
function swap(int i, int j)
{
	local SkillTrainInfo info;
	info = skillTrainInfoArray[i];
	skillTrainInfoArray[i] = skillTrainInfoArray[j];
	skillTrainInfoArray[j] = info;
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
    m_WindowName="AlchemySkillWnd"
    TREENAME="AlchemySkillWnd.SkillTrainTree"
    ROOTNAME="root"
    LIST1="SKILLLIST1"
    LIST2="SKILLLIST2"
    LIST3="SKILLLIST3"
}
