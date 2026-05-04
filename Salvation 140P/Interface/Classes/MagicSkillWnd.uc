class MagicSkillWnd extends UICommonAPI;

const Skill_MAX_COUNT = 24;
const Skill_GROUP_COUNT = 8;

//스킬 가로 갯수
const SKILL_COL_COUNT = 7;

const Skill_GROUP_COUNT_P = 6;	//패시브용

//const SKILL_MAX_HERO = 6;
//const SKILL_MAX_ITEM = 1000;
//const SKILL_MAX_CHANGE = 20;

const SKILL_ITEMWND_WIDTH = 260;
const SKILL_SLOTBG_WIDTH = 252;
const TOP_MARGIN = 5;
const NAME_WND_HEIGHT = 20;
const BETWEEN_NAME_ITEM = 3;

// 스킬 그룹 번호
const SKILL_NORMAL = 0;		// 보통 스킬. 데미지 및 힐, 마법 포함.
const SKILL_BUF = 1;			// 버프
const SKILL_DEBUF = 2;		// 디버프
const SKILL_TOGGLE = 3;		// 토글
const SKILL_SONG_DANCE = 4;	// 송댄스
const SKILL_ITEM = 5;			// 아이템 스킬
const SKILL_HERO = 6;		// 영웅 스킬
const SKILL_CHANGE = 7;		// 변신 스킬


//////////////////////////////////////////////////////////////////////////////
// CONST
//////////////////////////////////////////////////////////////////////////////
const OFFSET_X_ICON_TEXTURE=0;
const OFFSET_Y_ICON_TEXTURE=4;
const OFFSET_Y_SECONDLINE = -17;

var WindowHandle	m_wndTop;
var WindowHandle	m_wndSkillDrawWnd;
// 액티브용
var WindowHandle	m_wndName[Skill_GROUP_COUNT];
var TextBoxHandle	m_NameStr[Skill_GROUP_COUNT];
var TextureHandle	m_NameBtn[Skill_GROUP_COUNT];
var TextureHandle	m_ItemBg[Skill_GROUP_COUNT];
var WindowHandle	m_wnd[Skill_GROUP_COUNT];
var ItemWindowHandle	m_Item[Skill_GROUP_COUNT];
var ButtonHandle		m_HiddenBtn[Skill_GROUP_COUNT];
var WindowHandle	areaScroll;
//패시브용
var WindowHandle	m_wndName_p[Skill_GROUP_COUNT_P];
var TextBoxHandle	m_NameStr_p[Skill_GROUP_COUNT_P];
var TextureHandle	m_NameBtn_p[Skill_GROUP_COUNT_P];
var TextureHandle	m_ItemBg_p[Skill_GROUP_COUNT_P];
var WindowHandle	m_wnd_p[Skill_GROUP_COUNT_P];
var ItemWindowHandle	m_Item_p[Skill_GROUP_COUNT_P];
var ButtonHandle		m_HiddenBtn_p[Skill_GROUP_COUNT_P];
var WindowHandle	areaScroll_p;

//var array<int> m_HeroSkillID;
//var array<int> m_ItemSkillID;
//var array<int> m_ChangeSkillID;

var bool m_bShow;
var String m_WindowName;
// 액티브용
var int m_bExistSkill[Skill_GROUP_COUNT];	// 1이면 해당 그룹 스킬이 없는것, 2이면 해당 그룹 스킬이 있고 열려있는 것. 3 이면 해당 그룹 스킬이 있고 닫혀 있는 것
var int nScrollHeight;					// 전체 윈도우의 스크롤 크기 결정

// 패시브용
var int m_bExistSkill_p[Skill_GROUP_COUNT_P];
var int nScrollHeight_p;					// 전체 윈도우의 스크롤 크기 결정

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

var string beforeTreeName;

var AnimTextureHandle TexTabLightActive;

var AnimTextureHandle TexTabLightPassive;

var TreeHandle m_UITree;

var ButtonHandle ResearchButton;

// 트리 노드 이름 배열
var array<string> treeNodeNameNewSkillArray;
var array<string> treeNodeNameLevelUpArray;
var string clickedTreeNodeName;

var int clickedTreeNodeIndex;

var WindowHandle SkillTrainInfoWndScript;

var int levelUpSkillIndex, newSkillIndex;

struct SubjobInfo
{
	var int		Id;
	var int		ClassID;
	var int		Level;
	var int		Type;
};

// 섭잡정보
var array<SubjobInfo> subjobInfoArray;
var SubjobInfo beforeSubjobInfo;

// 현재 듀얼 클래스 서브잡이 있는가?
var bool    isDualClass;

// 현재활성화되어있는클래스
//var int currentSubjobClassNum;


var int mainLevel;
var int dualLevel;
var int currentType;


function OnRegisterEvent()
{
	RegisterEvent(EV_SkillListStart);
	RegisterEvent(EV_SkillList);
	RegisterEvent(EV_LanguageChanged);
	RegisterEvent(Ev_SkillEnchantInfoWndShow);

	RegisterEvent(EV_ApplySkillAvailability);


	//스킬습득 테스트용
	RegisterEvent( EV_SkillLearningTabAddSkillBegin );
	RegisterEvent( EV_SkillLearningTabAddSkillItem );
	RegisterEvent( EV_SkillLearningTabAddSkillEnd );
	RegisterEvent( EV_SkillListEnd );

	RegisterEvent( EV_SkillLearningNewArrival );

	//듀얼클래스및서브클래스리스트
	RegisterEvent(EV_NotifySubjob);
	RegisterEvent(EV_CreatedSubjob);
	RegisterEvent(EV_ChangedSubjob);
	RegisterEvent(EV_UpdateUserInfo);
	// CurrentSubjobClassID=3 Count=3 SubjobID_1 SubjobClassID_1=44 SubjobLevel_1=55 SubjobType_1

	RegisterEvent(EV_NeedResetUIData);	
}

function OnLoad()
{
	SetClosingOnESC();

	InitHandle();
	
	//TREENAME = "MagicSkillWnd.SkillTrainTree";
	//ROOTNAME = "root";

	util = L2Util(GetScript("L2Util"));	
	SkillTrainInfoWndScript = GetWindowHandle("SkillLearnWnd");

	m_bShow = false;

	if ( getInstanceUIData().getIsArenaServer() )ResearchButton.HideWindow();
}

function InitHandle()
{
	local int i;

	m_UITree = GetTreeHandle("MagicSkillWnd.SkillTrainTree");

	m_wndTop = GetWindowHandle( m_WindowName );
	Drawer = GetWindowHandle( "MagicSkillDrawerWnd");
	areaScroll = GetWindowHandle( m_WindowName $ ".ASkillScroll" );
	areaScroll_p = GetWindowHandle( m_WindowName $ ".PSkillScroll" );

	TexTabLightActive = GetAnimTextureHandle ( "MagicSkillWnd.TexTabLightActive" );
	TexTabLightPassive = GetAnimTextureHandle ( "MagicSkillWnd.TexTabLightPassive" );

	ResearchButton = GetButtonHandle( "MagicSkillWnd.ResearchButton" );
	
	for(i=0; i<Skill_GROUP_COUNT ; i++)
	{
		m_wndName[i] = GetWindowHandle( m_WindowName $".ASkill.ASkillName" $ i ); 
		m_wnd[i] = GetWindowHandle( m_WindowName $ ".ASkill.ASkill" $ i ); 
		m_NameStr[i] = GetTextBoxHandle ( m_WindowName $ ".ASkill.ASkillName" $  i $ ".ASkillNameStr" $ i ); 
		m_NameBtn[i] = GetTextureHandle( m_WindowName $ ".ASkill.ASkillName" $  i $ ".ASkillBtn" $ i ); 
		m_Item[i] = GetItemWindowHandle ( m_WindowName $ ".ASkill.ASkill" $  i $ ".ASkillItem" $ i ); 
		m_ItemBg[i] = GetTextureHandle( m_WindowName $ ".ASkill.ASkill" $  i $ ".ASkillSlotBg" $ i ); 
		m_HiddenBtn[i] = GetButtonHandle ( m_WindowName $ ".ASkill.ASkillName" $  i $ ".ASkillHiddenBtn" $ i ); 
		m_HiddenBtn[i].SetAlpha(255);
	}
	
	for(i=0; i<Skill_GROUP_COUNT_P ; i++)
	{
		m_wndName_p[i] = GetWindowHandle( m_WindowName $".PSkill.PSkillName" $ i ); 
		m_wnd_p[i] = GetWindowHandle( m_WindowName $ ".PSkill.PSkill" $ i ); 
		m_NameStr_p[i] = GetTextBoxHandle ( m_WindowName $ ".PSkill.PSkillName" $  i $ ".PSkillNameStr" $ i ); 
		m_NameBtn_p[i] = GetTextureHandle( m_WindowName $ ".PSkill.PSkillName" $  i $ ".PSkillBtn" $ i ); 
		m_Item_p[i] = GetItemWindowHandle ( m_WindowName $ ".PSkill.PSkill" $  i $ ".PSkillItem" $ i ); 
		m_ItemBg_p[i] = GetTextureHandle( m_WindowName $ ".PSkill.PSkill" $  i $ ".PSkillSlotBg" $ i ); 
		m_HiddenBtn_p[i] = GetButtonHandle ( m_WindowName $ ".PSkill.PSkillName" $  i $ ".PSkillHiddenBtn" $ i ); 
		m_HiddenBtn_p[i].SetAlpha(255);
	}

	TexTabLightActive.HideWindow();
	TexTabLightPassive.HideWindow();

}

function OnShow()
{
	// 배우기 클릭 상태 초기화
	clickedTreeNodeName = "";
	clickedTreeNodeIndex = -1;

	RequestSkillList();
	m_bShow = true;


}

function OnHide()
{
	//local MagicSkillDrawerWnd script_a;	

	m_bShow = false;

	//script_a = MagicSkillDrawerWnd(GetScript("MagicSkillDrawerWnd"));
	//script_a.HideAgathion();
	
	MagicSkillDrawerWnd(GetScript("MagicSkillDrawerWnd")).setMagicSkillItemsType(false);	
	MagicSkillDrawerWnd(GetScript("MagicSkillDrawerWnd")).OnTextureAnimEnd(MagicSkillDrawerWnd(GetScript("MagicSkillDrawerWnd")).EnchantProgressAnim);
	if ( Drawer.IsShowWindow () ) 
	{
		Drawer.HideWindow();	
		MagicSkillDrawerWnd(GetScript("MagicSkillDrawerWnd")).isHiding = true;
	}
	SkillTrainInfoWndScript.HideWindow();
}

function OnEvent(int Event_ID, String param)
{
	//local string strIconName;
	//local string strName;
	//local int iID;
	//local int iLevel;
	//local int iSPConsume;
	//local string strEnchantName;
	local int NewSkillID;
	local SkillInfo skillInfo;
	local UserInfo userinfo;
			
	//Debug("------스킬 습득 ----- ");
	//Debug("Event_ID" @ Event_ID);
	//Debug("param" @ param);
	
	
	if (Event_ID == EV_SkillListStart)                  //1280
	{
		//debug("!!!Skill!!! List 패킷 날아옴");
		//updateSubjobInfo(param, EV_NotifySubjob);
		HandleSkillListStart();
	}

	// 레벨업 시 서브잡의 정보를 갱신한다
	else if(Event_ID == EV_UpdateUserInfo)              //180
	{
		GetPlayerInfo(userinfo);
		
		if(currentType == 0)
			mainLevel = userinfo.nLevel;
		else if (currentType == 1)
			dualLevel = userinfo.nLevel;
	}
	
	else if(Event_ID == EV_NotifySubjob)
	{
		updateSubjobInfo(param, Event_ID);	
	}

	else if(Event_ID == EV_CreatedSubjob)
	{
		updateSubjobInfo(param, Event_ID);	
	}

	else if(Event_ID == EV_ChangedSubjob)
	{	
		updateSubjobInfo(param, Event_ID);
		ExecuteEvent(EV_NPCDialogWndHide);
		class'UIAPI_WINDOW'.static.HideWindow("MagicSkillWnd");
	}

	else if (Event_ID == EV_SkillList)                  //1290
	{

		HandleSkillList(param);
		//ComputeItemWndHeight();
		//ComputeItemWndAnchor();
	}
	else if (Event_ID == EV_LanguageChanged)
	{
		HandleLanguageChanged();
	}
	/*
	else if (Event_ID == Ev_SkillEnchantInfoWndShow)
	{

		if ( m_wndTop.IsShowWindow() ) 
		{
			Debug ( "MagicSkill Ev_SkillEnchantInfoWndShow" @  m_wndTop.IsShowWindow() );
			Drawer.ShowWindow();
		}
	}
*/
	else if (Event_ID == EV_ApplySkillAvailability)
	{
		ApplySkillAvailability();
	}
	//스킬습득 테스트용
	else if ( Event_ID == EV_SkillLearningTabAddSkillBegin )            //2055
	{			
		TreeClear();
		ShowSkillTree();
		levelUpSkillIndex = 0;
		newSkillIndex = 0;
		treeNodeNameNewSkillArray.Remove(0, treeNodeNameNewSkillArray.Length);
		treeNodeNameLevelUpArray.Remove(0, treeNodeNameLevelUpArray.Length);
	}
	else if ( Event_ID == EV_SkillLearningTabAddSkillItem )             //2056
	{
		//ParseString(param, "strIconName", strIconName); 
		//ParseString(param, "strName", strName);
		//ParseInt(param, "iID", iID);
		//ParseInt(param, "iLevel", iLevel);
		//ParseInt(param, "iSPConsume", iSPConsume);
		//ParseString(param, "strEnchantName", strEnchantName);

		//AddSkillTrainListItem(strIconName, strName, iID, iLevel, iSPConsume, strEnchantName);		
		AddSkillTrainListItem( param );
	}
	else if( Event_ID == EV_SkillListEnd )                              //1291
	{
		ComputeItemWndHeight();
		ComputeItemWndAnchor();

		ParseInt(param, "NewSkillID", NewSkillID);
		// !문제 있는지 확인 
		GetSkillInfo( NewSkillID , 1, 0, skillInfo );
		
		//Debug("EV_SkillListEnd>>>>>>>>>>>>>>>>>>>>>>>" $ string( TypeCheck( skillinfo ) ) $ param );
		if( NewSkillID != 0 )
		{
			if( TypeCheck( skillinfo ) == true )
			//if( class'UIDATA_SKILL'.static.GetOperateType( GetItemID(NewSkillID), 1) == GetSystemString(311) )
			{
				TexTabLightActive.ShowWindow();
				TexTabLightActive.SetLoopCount( 1 );		
				TexTabLightActive.Stop();
				TexTabLightActive.Play();
			}
			//else if(class'UIDATA_SKILL'.static.GetOperateType( GetItemID(NewSkillID), 1) == GetSystemString(312) )
			else
			{
				TexTabLightPassive.ShowWindow();
				TexTabLightPassive.SetLoopCount( 1 );
				TexTabLightPassive.Stop();
				TexTabLightPassive.Play();
			}
		}
	}
	else if( Event_ID == EV_SkillLearningNewArrival )                   //2059
	{
		// Debug("EV_SkillLearningNewArrivalEV_SkillLearningNewArrivalEV_SkillLearningNewArrivalEV_SkillLearningNewArrival");
		RequestSkillList();
	}

	else if( Event_ID == EV_SkillLearningTabAddSkillEnd )               //2057
	{
		
		// Debug("clickedTreeNodeName" @ clickedTreeNodeName);
		switch(Left(clickedTreeNodeName, 15))
		{
			case "root.SKILLLIST1" : 
									 if (treeNodeNameNewSkillArray.Length - 1 >= clickedTreeNodeIndex)
									 {
										beforeTreeName = treeNodeNameNewSkillArray[clickedTreeNodeIndex];

										// 마지막이면 나오지 않도록, 새로 배울 스킬은 반복 습득을 하는게 아니라, 다시 습득 창을 나오지
										// 않게 해도 된다.
										if (treeNodeNameNewSkillArray.Length - 1 != clickedTreeNodeIndex)
											OnClickButton(treeNodeNameNewSkillArray[clickedTreeNodeIndex]);
									 }
									 break;

			case "root.SKILLLIST2" :
									 if (treeNodeNameLevelUpArray.Length - 1 >= clickedTreeNodeIndex)
									 {
										 beforeTreeName = treeNodeNameLevelUpArray[clickedTreeNodeIndex];
										 OnClickButton(treeNodeNameLevelUpArray[clickedTreeNodeIndex]);
									 }
									 break;
		}

	}
	else if( Event_ID == EV_NeedResetUIData )  
	{
		checkClassicForm();
	}
}


function checkClassicForm() 
{
	if ( getInstanceUIData().getisClassicServer()  )
	{
		ResearchButton.setButtonName(646);
	}
	else 
	{			
		ResearchButton.setButtonName(2070);
	}
}

//스킬의 클릭
function OnClickItem( string strID, int index )
{
	local ItemInfo 	infItem;
	local int		GroupID;
	local MagicSkillDrawerWnd script_a;
	
	if ( InStr( strID ,"ASkillItem" ) > -1 && index>-1)
	{
		GroupID = int(Right(strID, 1));
		if(m_Item[GroupID].GetItem(index, infItem))
		{			
			if ( Drawer.IsShowWindow() ) 
			{				
				script_a = MagicSkillDrawerWnd(GetScript("MagicSkillDrawerWnd"));
				script_a.handleSetCurrentSkill( infItem );
				//class'UIAPI_WINDOW'.static.IsShowWindow("AttributeRemoveWnd");				
			}
			else
			{
				// 10.04.5 동현씨 수정 요청 
				UseSkill(infItem.ID, infItem.ItemSubType);
			}
		}
	}
}

// 버튼클릭 이벤트
function OnClickButton( string strID )
{
	local int i;				// for를 돌리기 위한 변수
	local int index;
	local int nWndWidth, nWndHeight; // 윈도우 사이즈 받기 변수
	local MagicSkillDrawerWnd script_a;

	//Tree용 변수
	local Array<string> Result;
	local string treelist;
	local array<string> SkillIDLevel;	
	
	index = int(Right(strID, 1));	//버튼의 제일 끝 숫자를 따낸다. 

	treelist = Left(strID, 4);
	
	// Debug("트리 클릭 " @ strID);
	if( InStr( strID ,"ASkillHiddenBtn" ) > -1)
	{
		if (m_bExistSkill[index] == 1)		// 안접혀 있으면 접어준다. 
		{
			m_wnd[index].GetWindowSize(nWndWidth, nWndHeight);	// width는 버린다 -_-;; Height만 사용
			nScrollHeight = nScrollHeight - nWndHeight - BETWEEN_NAME_ITEM;	// 사이즈가 변했기 때문에 스크롤 높이를 조절해준다. 
			m_NameBtn[index].SetTexture("l2ui_ch3.QuestWnd.QuestWndPlusBtn");
			m_bExistSkill[index] = 2;
			m_wnd[index].HideWindow();	
			
			// 다음 윈도우의 앵커를 수정해준다.  (네임 바로 밑에 붙여줌)
			if(index <Skill_GROUP_COUNT)
			{
				for(i = index + 1 ; i<Skill_GROUP_COUNT ; i++)	
				{
					if(m_bExistSkill[i]  >0)	// 다음 윈도우가 접혔는지 펼쳐져 있는지는 신경쓰지 않는다. 
					{
						m_wndName[i].ClearAnchor();
						m_wndName[i].SetAnchor(m_WindowName $ ".ASkill.ASkillName" $ index, "BottomCenter", "TopCenter", 0, TOP_MARGIN);
						break;
					}
				}
			}
		}
		else if(m_bExistSkill[index] == 2)		// 접혀있으면 펴준다.
		{
			m_wnd[index].GetWindowSize(nWndWidth, nWndHeight);	// width는 버린다 -_-;; Height만 사용
			nScrollHeight = nScrollHeight + nWndHeight + BETWEEN_NAME_ITEM;	// 사이즈가 변했기 때문에 스크롤 높이를 조절해준다. 
			m_NameBtn[index].SetTexture("l2ui_ch3.QuestWnd.QuestWndMinusBtn");
			m_bExistSkill[index] = 1;
			m_wnd[index].ShowWindow();
			
			// 다음 윈도우의 앵커를 수정해준다. 
			if(index <Skill_GROUP_COUNT)
			{
				for(i = index + 1; i<Skill_GROUP_COUNT ; i++)	
				{
					if(m_bExistSkill[i]  >0)	// 다음 윈도우가 접혔는지 펼쳐져 있는지는 신경쓰지 않는다. 
					{
						m_wndName[i].ClearAnchor();
						m_wndName[i].SetAnchor(m_WindowName $ ".ASkill.ASkillName" $ index, "BottomCenter", "TopCenter", 0, nWndHeight + BETWEEN_NAME_ITEM + TOP_MARGIN);
						break;
					}
				}
			}
		}
		areaScroll.SetScrollHeight(nScrollHeight);
		//areaScroll.SetScrollPosition( 0 );
	}
	else if( InStr( strID ,"PSkillHiddenBtn" ) > -1)
	{
		if (m_bExistSkill_p[index] == 1)		// 안접혀 있으면 접어준다. 
		{
			m_wnd_p[index].GetWindowSize(nWndWidth, nWndHeight);	// width는 버린다 -_-;; Height만 사용
			nScrollHeight_p = nScrollHeight_p - nWndHeight - BETWEEN_NAME_ITEM;	// 사이즈가 변했기 때문에 스크롤 높이를 조절해준다. 
			m_NameBtn_p[index].SetTexture("l2ui_ch3.QuestWnd.QuestWndPlusBtn");
			m_bExistSkill_p[index] = 2;
			m_wnd_p[index].HideWindow();	
			
			// 다음 윈도우의 앵커를 수정해준다.  (네임 바로 밑에 붙여줌)
			if(index <Skill_GROUP_COUNT_P)
			{
				for(i = index + 1 ; i<Skill_GROUP_COUNT_P ; i++)	
				{
					if(m_bExistSkill_p[i]  >0)	// 다음 윈도우가 접혔는지 펼쳐져 있는지는 신경쓰지 않는다. 
					{
						m_wndName_p[i].ClearAnchor();
						m_wndName_p[i].SetAnchor(m_WindowName $ ".PSkill.PSkillName" $ index, "BottomCenter", "TopCenter", 0, TOP_MARGIN);
						break;
					}
				}
			}
		}
		else if(m_bExistSkill_p[index] == 2)		// 접혀있으면 펴준다.
		{
			m_wnd_p[index].GetWindowSize(nWndWidth, nWndHeight);	// width는 버린다 -_-;; Height만 사용
			nScrollHeight_p = nScrollHeight_p + nWndHeight + BETWEEN_NAME_ITEM;	// 사이즈가 변했기 때문에 스크롤 높이를 조절해준다. 
			m_NameBtn_p[index].SetTexture("l2ui_ch3.QuestWnd.QuestWndMinusBtn");
			m_bExistSkill_p[index] = 1;
			m_wnd_p[index].ShowWindow();
			
			// 다음 윈도우의 앵커를 수정해준다. 
			if(index <Skill_GROUP_COUNT_P)
			{
				for(i = index + 1; i<Skill_GROUP_COUNT_P ; i++)	
				{
					if(m_bExistSkill_p[i]  >0)	// 다음 윈도우가 접혔는지 펼쳐져 있는지는 신경쓰지 않는다. 
					{
						m_wndName_p[i].ClearAnchor();
						m_wndName_p[i].SetAnchor(m_WindowName $ ".PSkill.PSkillName" $ index, "BottomCenter", "TopCenter", 0, nWndHeight + BETWEEN_NAME_ITEM + TOP_MARGIN);
						break;
					}
				}
			}
		}
		areaScroll_p.SetScrollHeight(nScrollHeight_p);
	}
	
	else if ( strID == "ResearchButton" ) //스킬 인챈트 버튼 클릭
	{
		if ( getInstanceUIData().getIsClassicServer() ) 
		{
			class'UIAPI_WINDOW'.static.HideWindow("MagicSkillWnd");		
		}
		else 
		{
			script_a = MagicSkillDrawerWnd(GetScript("MagicSkillDrawerWnd"));

			if (Drawer.IsShowWindow())
			{
				Drawer.HideWindow();
				script_a.isHiding = true;
				//script_a.HideAgathion();
				script_a.setMagicSkillItemsType(false);
				script_a.SkillInfoClear();
				RequestSkillList();
				//debug("CanEnchant"$iCnaEnchant);
				//script_a.txtMySp.SetText(MakeCostString( string(0) ));			
			}
			else 
			{
				Drawer.ShowWindow();
				script_a.SkillInfoClear();
				script_a.txtMySp.SetText(MakeCostString( string(GetUserSP()) ));
				RequestSkillList();
				//debug("CanEnchant"$iCnaEnchant);
			}
		}
	}
	
	//Tree를 클릭 했을 시에만 
	if( treelist == ROOTNAME )
	{			
		//Debug("clickTree");
		

		Split( strID, ".", Result );
	
		/*
		for ( i = 0 ; i < Result.Length ; i ++ )
		{
			Debug ( "Tree를 클릭 했을 시에만" @ Result.Length @  Result[i] );
		}
		*/


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
				// 뉴스킬과 
				clickedTreeNodeName = strID;
				clickedTreeNodeIndex = int(SkillIDLevel[2]);

				// Debug("클릭인덱스" @ SkillIDLevel[2]);

				/* subLevel 분석 후 작업 필요  */
				RequestAcquireSkillInfo( int(SkillIDLevel[0]), int(SkillIDLevel[1]), int(SkillIDLevel[3]), 0 );
			}
		}
	}

	//스킬 텝에 불들어 온거 감추기
	if( strID == "TabCtrl0" )
	{
		if ( !getInstanceUIData().getIsArenaServer() ) ResearchButton.ShowWindow();
		TexTabLightActive.HideWindow();
		SkillTrainInfoWndScript.HideWindow();
	}
	else if( strID == "TabCtrl1" )
	{
		if ( !getInstanceUIData().getIsArenaServer() ) ResearchButton.ShowWindow();
		TexTabLightPassive.HideWindow();
		SkillTrainInfoWndScript.HideWindow();

	}
	else if( strID == "TabCtrl2" )
	{		
		if (Drawer.IsShowWindow())
		{
			Drawer.HideWindow();
			MagicSkillDrawerWnd(GetScript("MagicSkillDrawerWnd")).isHiding = true;
		//	MagicSkillDrawerWnd(GetScript("MagicSkillDrawerWnd")).HideAgathion();
			MagicSkillDrawerWnd(GetScript("MagicSkillDrawerWnd")).SkillInfoClear();
			MagicSkillDrawerWnd(GetScript("MagicSkillDrawerWnd")).setMagicSkillItemsType(false);
			RequestSkillList();
		}
		ResearchButton.HideWindow();
	}
}


function HandleLanguageChanged()
{
	RequestSkillList();
}

function ApplySkillAvailability()
{
	local int i, j;
	local int itemNum;

	local int id, level, subLevel, skillDisabled;

	//0~7 active
	for ( i = 0; i < 8; ++i )
	{
		itemNum = m_Item[i].GetItemNum();
		for ( j = 0; j < itemNum; ++j )
		{
			m_Item[i].GetItemIdLevel(j, id, level, subLevel);
			if(id>0 && level>0)
			{
				skillDisabled = GetSkillAvailability(id, level, subLevel );

				m_Item[i].SetItemSkillDisabled(j,skillDisabled);
			}
		}
	}
	//8~14 passive
	for ( i = 8; i < 14; ++i )
	{
		itemNum = m_Item_p[i-8].GetItemNum();
		for ( j = 0; j < itemNum; ++j )
		{
			m_Item_p[i-8].GetItemIdLevel(j, id, level, subLevel);

			if(id>0 && level> 0)
			{
				skillDisabled = GetSkillAvailability(id, level, subLevel );
									
				m_Item_p[i-8].SetItemSkillDisabled(j,SkillDisabled);
			}
		}
	}
}


function HandleSkillListStart()
{
	Clear();
}

function Clear()
{
	local int i;
	
	// 스킬 플레그 초기화
	for(i =0; i<Skill_GROUP_COUNT ; i++)
	{
		m_bExistSkill[ i ] = 0;
		m_NameBtn[i].SetTexture("l2ui_ch3.QuestWnd.QuestWndMinusBtn");
		m_wnd[i].HideWindow();
		m_wndName[i].HideWindow();
		m_Item[i].Clear();
	}
	
	for(i =0; i<Skill_GROUP_COUNT_P ; i++)
	{
		m_bExistSkill_p[ i ] = 0;
		m_NameBtn_p[i].SetTexture("l2ui_ch3.QuestWnd.QuestWndMinusBtn");
		m_wnd_p[i].HideWindow();
		m_wndName_p[i].HideWindow();
		m_Item_p[i].Clear();
	}
}

function HandleSkillList(string param)
{
	local int Tmp;
	//local ESkillCategory Type;
	local int SkillLevel;
	local int SkillSubLevel;
	local int Lock;
	local string strIconName;
	local string strSkillName;
	local string strDescription;
	local string strEnchantName;
	local string strCommand;
	local string strIconPanel;
	local int iCanEnchant;
	local int ReuseDelayShareGroupID;
	local int iSkillDisabled;
	
	local ItemInfo	infItem;
	
	ParseItemID(param, infItem.ID);
	ParseInt(param, "Type", Tmp);
	ParseInt(param, "Level", SkillLevel);
	ParseInt(param, "SubLevel", SkillSubLevel);
	ParseInt(param, "Lock", Lock);
	ParseString(param, "Name", strSkillName);
	ParseString(param, "IconName", strIconName);
	ParseString(param, "IconPanel", strIconPanel);
	ParseString(param, "Description", strDescription);
	ParseString(param, "EnchantName", strEnchantName);
	ParseString(param, "Command", strCommand);
	ParseInt(param, "CanEnchant", iCanEnchant);
	ParseInt(param, "ReuseDelayShareGroupID", ReuseDelayShareGroupID);
	ParseInt(param, "iSkillDisabled", iSkillDisabled);
	
	//Debug(" Type : " $ Tmp $ "SkillLevel : " $ SkillLevel $ " strSkillName : " $ strSkillName $ " Command : " $ strCommand  $ "strEnchantName: " $ strEnchantName);
	//Debug("panel: " $ strIconPanel);
	//Debug("CanEnchant"$iCanEnchant);

	infItem.Level = SkillLevel;
	infItem.SubLevel = SkillSubLevel;
	infItem.Name = strSkillName;
	infItem.AdditionalName = strEnchantName;
	infItem.IconName = strIconName;
	infItem.IconPanel = strIconPanel;
	infItem.Description = strDescription;
	infItem.ItemSubType = int(EShortCutItemType.SCIT_SKILL);
	infItem.MacroCommand = strCommand;
	infItem.ReuseDelayShareGroupID = ReuseDelayShareGroupID;
	
	infItem.iSkillDisabled = iSkillDisabled;
	
	if (Lock>0)
	{
		infItem.bIsLock = true;
	}
	else
	{
		infItem.bIsLock = false;
	}

	infItem.Reserved = iCanEnchant;
	
	if(Drawer.IsShowWindow())
	{
		if (iCanEnchant>0)
		{
			infItem.bDisabled = 0;

		}else
		{
			infItem.bDisabled = 1;
		}

		//테스트용 코드임 반드시 삭제 할 것 서버에서 iCanEnchant 을 수정 해서 보내주기로 했음
		//if ( SkillSubLevel > 0 ) infItem.bDisabled = 0;
	}

	//ItemWnd에 추가
	//Type = ESkillCategory(Tmp);
	
	GroupingSkill(infItem.ID.ClassID , SkillLevel, SkillSubLevel, infItem);

	
}

function ComputeItemWndHeight()
{	
	local int i;			// for문을 돌리기 위한 변수
	local int nItemNum;	// 해당 아이템 윈도우에 들어있는 스킬의 갯수
	local int nItemWndHeight;	// 아이템윈도우의 높이
	local int nWndWidth;	
	
	//---------------- 액티브 스킬의 높이 계산
	nScrollHeight = 0;
	for (i=0 ; i<Skill_GROUP_COUNT ; i++)
	{
		nItemNum = m_Item[i].GetItemNum();
		
		if(nItemNum <1)	// 스킬이 없으면
		{			
			m_bExistSkill[i] = 0; //창을 보여주지 않는다. 초기화때 해주지만 그래도 혹시 모르니깐!
			m_wnd[i].GetWindowSize(nWndWidth, nItemWndHeight);	
			m_wnd[i].SetWindowSize(nWndWidth, 0);
		}
		else
		{			
			m_bExistSkill[i] = 1; // 펼쳐짐. 접기는 클릭이벤트에서
			
			nItemWndHeight = ((nItemNum - 1) / SKILL_COL_COUNT + 1) * 32 + ((nItemNum - 1) / SKILL_COL_COUNT) * 4 + 12;	// 위아래 갭 + 그룹박스 여백을 합치면 12!!
			m_wnd[i].SetWindowSize( SKILL_ITEMWND_WIDTH , nItemWndHeight);
			m_ItemBg[i].SetWindowSize( SKILL_SLOTBG_WIDTH , nItemWndHeight - 8);
			m_Item[i].SetRow((nItemNum - 1) / SKILL_COL_COUNT + 2);	//??
			
			// 창이 안떠있으면 띄워준다. 
			if( !m_wnd[i].IsShowWindow()) m_wnd[i].ShowWindow();
			if( !m_wndName[i] .IsShowWindow()) m_wndName[i].ShowWindow();
			
			nScrollHeight = nScrollHeight + TOP_MARGIN + NAME_WND_HEIGHT + BETWEEN_NAME_ITEM + nItemWndHeight ;	// 누적시킨다
			//debug("!!!!SKill !! Height " $"   " $i $"    " $nScrollHeight $"  " $nItemWndHeight);
		}
	}	
	//debug("!!!Skill!!! Height 재조정" $ nScrollHeight);
	if (areaScroll.IsShowWindow())
		areaScroll.SetScrollHeight(nScrollHeight);
	//debug("!!!Skill!!! Height Refresh");
	if (!areaScroll.IsShowWindow())
		areaScroll.SetScrollPosition( 0 );
	
	// ---------------패시브 스킬의 높이 계산
	
	nScrollHeight_p = 0;
	for (i=0 ; i<Skill_GROUP_COUNT_P ; i++)
	{
		nItemNum = m_Item_p[i].GetItemNum();
		
		if(nItemNum <1)	// 스킬이 없으면
		{
			m_bExistSkill_p[i] = 0; //창을 보여주지 않는다. 초기화때 해주지만 그래도 혹시 모르니깐!
			m_wnd_p[i].GetWindowSize(nWndWidth, nItemWndHeight);	
			m_wnd_p[i].SetWindowSize(nWndWidth, 0);
		}
		else
		{
			m_bExistSkill_p[i] = 1; // 펼쳐짐. 접기는 클릭이벤트에서
			
			nItemWndHeight = ((nItemNum - 1) / SKILL_COL_COUNT + 1) * 32 + ((nItemNum - 1) / SKILL_COL_COUNT) * 4 + 12;	// 위아래 갭 + 그룹박스 여백을 합치면 12!!
			m_wnd_p[i].SetWindowSize( SKILL_ITEMWND_WIDTH , nItemWndHeight);
			m_ItemBg_p[i].SetWindowSize( SKILL_SLOTBG_WIDTH , nItemWndHeight - 8);
			m_Item_p[i].SetRow((nItemNum - 1) / SKILL_COL_COUNT + 2);	//??
			
			// 창이 안떠있으면 띄워준다. 
			if( !m_wnd_p[i].IsShowWindow()) m_wnd_p[i].ShowWindow();
			if( !m_wndName_p[i] .IsShowWindow()) m_wndName_p[i].ShowWindow();
			
			nScrollHeight_p = nScrollHeight_p + TOP_MARGIN + NAME_WND_HEIGHT + BETWEEN_NAME_ITEM + nItemWndHeight ;	// 누적시킨다
			//debug("!!!!SKill2 !! Height " $"   " $i $"    " $nScrollHeight_p $"  " $nItemWndHeight);
		}
	}
	
	//debug("!!!Skill2!!! Height 재조정" $ nScrollHeight_p);
	if (areaScroll_p.IsShowWindow())
	areaScroll_p.SetScrollHeight(nScrollHeight_p);
	//debug("!!!Skill2!!! Height Refresh" );
	if (!areaScroll_p.IsShowWindow())
		areaScroll_p.SetScrollPosition( 0 );
}

function ComputeItemWndAnchor()
{	
	local int i, j;			// for문을 돌리기 위한 변수
	local int nWndWidth, nWndHeight;	// 윈도우 사이즈 받기 변수
	
	//------------- 액티브의 앵커 잡아주기
	//첫번째 창이 닫혀있을 경우

	//areaScroll.SetScrollPosition( 0 );
	//Debug("--ComputeItemWndAnchor");
	areaScroll.SetScrollPosition( 0 );

	//첫 스킬 그룹이 보이지 않을 경우 물리 스킬이 없을 경우
	if(m_bExistSkill[0] == 0) 
	{
		for (i = 1 ; i < Skill_GROUP_COUNT ; i++)
		{
			// 활성화 중인 첫번째 창을 붙여준다. 
			if(m_bExistSkill[i] > 0)
			{				
				m_wndName[i].SetAnchor(m_WindowName $ ".ASkillScroll", "TopLeft", "TopLeft", 5, 4);	// 스크롤이 먹통되는 현상의 원인
				//m_wndName[i].SetAnchor(m_WindowName $ ".ASkillScroll", "TopLeft", "TopLeft", 5, -50);	// 스크롤이 먹통되는 현상의 원인
				//Debug("ComputeItemWndAnchor m_wndName" @ m_wndName[i]);
				m_wndName[i].ClearAnchor();
				break;
			}		
		}
	}


	
	// 0번째는 잡아주지 않아도 된다. 
	for (i = 0 ; i < Skill_GROUP_COUNT ; i++)
	{
		// 활성화 중일때만 앵커
		if(m_bExistSkill[i] > 0)
		{
			for(j=i+1 ; j<Skill_GROUP_COUNT; j++)
			{
				if(m_bExistSkill[j] > 0)	// 다음 활성화된 창을 검색 후 붙여준다.
				{
					if( m_bExistSkill[i] == 1)	// 아이템 윈도우가 열려있을 경우
					{
						m_wnd[i].GetWindowSize(nWndWidth, nWndHeight);	// width는 버린다 -_-;;
						m_wndName[j].SetAnchor(m_WindowName $ ".ASkill.ASkillName" $ i, "BottomCenter", "TopCenter", 0, nWndHeight + BETWEEN_NAME_ITEM + TOP_MARGIN);
						break;
					}
					else if( m_bExistSkill[i] == 2)	// 아이템 윈도우가 접혀있을 경우
					{	
						m_wndName[j].SetAnchor(m_WindowName $ ".ASkill.ASkillName" $ i, "BottomCenter", "TopCenter", 0, TOP_MARGIN);
						break;
					}
				}
			}			
		}		
	}
	
	//------------- 패시브의 앵커 잡아주기
	//첫번째 창이 닫혀있을 경우
	if(m_bExistSkill_p[0] == 0) 
	{
		for (i = 1 ; i < Skill_GROUP_COUNT_P ; i++)
		{
			// 활성화 중인 첫번째 창을 붙여준다. 
			if(m_bExistSkill_p[i] > 0)
			{
				m_wndName_p[i].SetAnchor(m_WindowName $ ".PSkillScroll", "TopLeft", "TopLeft", 5, 4);	// 스크롤이 먹통되는 현상의 원인
				m_wndName_p[i].ClearAnchor();
				break;
			}		
		}
	}
	
	// 0번째는 잡아주지 않아도 된다. 
	for (i = 0 ; i < Skill_GROUP_COUNT_P ; i++)
	{
		// 활성화 중일때만 앵커
		if(m_bExistSkill_p[i] > 0)
		{
			for(j=i+1 ; j<Skill_GROUP_COUNT_P; j++)
			{
				if(m_bExistSkill_p[j] > 0)	// 다음 활성화된 창을 검색 후 붙여준다.
				{
					if( m_bExistSkill_p[i] == 1)	// 아이템 윈도우가 열려있을 경우
					{
						m_wnd_p[i].GetWindowSize(nWndWidth, nWndHeight);	// width는 버린다 -_-;;
						m_wndName_p[j].SetAnchor(m_WindowName $ ".PSkill.PSkillName" $ i, "BottomCenter", "TopCenter", 0, nWndHeight + BETWEEN_NAME_ITEM + TOP_MARGIN);
						break;
					}
					else if( m_bExistSkill_p[i] == 2)	// 아이템 윈도우가 접혀있을 경우
					{	
						m_wndName_p[j].SetAnchor(m_WindowName $ ".PSkill.PSkillName" $ i, "BottomCenter", "TopCenter", 0, TOP_MARGIN);
						break;
					}
				}
			}			
		}		
	}
}

// ID를 가지고 정보를 구해 해당 스킬의 구분을 확정짓는다.
function GroupingSkill( int  SkillID , int SkillLevel, int SkillSubLevel, ItemInfo infItem )
{	
	local SkillInfo info;
	
	// ID를 가지고 스킬의 정보를 얻어온다. 없으면 패배
	if( !GetSkillInfo( SkillID, SkillLevel , SkillSubLevel, info ) )
	{
		//debug("ERROR - no skill info!!");
		return;
	}
	
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
			m_Item[info.IconType].AddItem(infItem);
			break;
		case 8:	// 마법 속성 아이콘
			infItem.ItemSubType = int(EShortCutItemType.SCIT_ATTRIBUTE);
			m_Item[6].AddItem(infItem);
			break;

		//------------------ 패시브
		case 11:
		case 12:
		case 13:
		case 14:
		case 15:
		case 16:
			m_Item_p[info.IconType-11].AddItem(infItem);
			break;
		default:
			break;
	}
}

//영웅 스킬 검사
function bool IsHeroSkillID(int SkillID)
{
	switch(SkillID)
	{
		case 395:
		case 396:
		case 1374:
		case 1375:
		case 1376:
			return true;
		
		default:
			return false;
	}
}

// 아이템 스킬 검사
function bool IsItemSkillID(int SkillID)
{
	switch(SkillID)
	{
		default:
			return false;
	}
}

//변신 스킬 검사
function bool IsChangeSkillID(int SkillID)
{
	switch(SkillID)
	{
		default:
			return false;
	}
}


function OnDropItem( String a_WindowID, ItemInfo a_ItemInfo, int X, int Y)
{
	local MagicSkillDrawerWnd script_a;
	local string dragsrcName;
	
	
	
	script_a = MagicSkillDrawerWnd(GetScript("MagicSkillDrawerWnd"));

	dragsrcName = Left(a_ItemInfo.DragSrcName,10);
	//RequestSkillList();

	
	//debug("CanEnchant");
	switch (a_WindowID)
	{		
		case "ResearchButton":
		if ( getInstanceUIData().getIsClassicServer() )
		{ 
			//닫기 버튼으로 변경 되어 있음 
		}
		else if (dragsrcName== "PSkillItem" || dragsrcName == "ASkillItem" )
		{

				
				if ( a_ItemInfo.Reserved == 0)
				{
					RequestSkillList();
					script_a.SkillInfoClear();
					script_a.SetAdenaSpInfo();
					script_a.ResearchGuideDesc.SetText(GetSystemString(2041));
					script_a.AddSystemMessage(3070);//바꿔야 함
					
				} else
				{
					RequestExEnchantSkillInfo(a_ItemInfo.ID.ClassID, a_ItemInfo.Level, a_ItemInfo.SubLevel); 
					script_a.SetCurSkillInfo(a_ItemInfo);
					script_a.txtMySp.SetText(MakeCostString( string(GetUserSP()) ));
					RequestSkillList();
				}
		}
	
		break;

	}
}

//SP 수치를 표현한다.
function INT64 GetuserSP()
{

	local UserInfo infoPlayer;
	local INT64 iPlayerSP;

	GetPlayerInfo(infoPlayer);
	iPlayerSP=infoPlayer.nSP;

	return iPlayerSP;
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



/**
 *  최초들어오는서브잡, 듀얼등의정보를받아기록한다.
 **/
function updateSubjobInfo (string param, int Event_ID)
{
	local int count, i;

	local int currentSubjobClassID;
	
	local UserInfo myUserInfo;

	//local SubjobInfo tempSubjobInfo;

	// 종족
	local int  race;
	//local bool bFlag;
	isDualClass = false;

	//GetMyUserInfo(myUserInfo);
	GetPlayerInfo(myUserInfo);
	
	// 해당직업수를리턴받는다.
	ParseInt(param, "Count"  , count);
	
	// 현재중인클래스아이디
	ParseInt(param, "currentSubjobClassID", currentSubjobClassID);

	if (subjobInfoArray.Length > 0)
	{
		subjobInfoArray.Remove(0, subjobInfoArray.Length);
	}
	
	ParseInt(param, "Race", race);

	//_currentSubjobClassID = currentSubjobClassID;

	// 서브잡리스트를받는다. (0메인, 서브듀얼개1,2,3(최대))
	for (i = 0; i < count; i++)
	{
		subjobInfoArray.Insert(subjobInfoArray.Length, 1);
		
		ParseInt(param, "SubjobClassID_" $ i, subjobInfoArray[i].ClassID);
		ParseInt(param, "SubjobID_"      $ i, subjobInfoArray[i].Id);
		ParseInt(param, "SubjobLevel_"   $ i, subjobInfoArray[i].Level);
		ParseInt(param, "SubjobType_"    $ i, subjobInfoArray[i].Type);

		// 듀얼 클래스가 하나라도 있다면..
		if (subjobInfoArray[i].Type == 1) { isDualClass = true; }
	}
	for (i = 0; i < count; i++)
	{
		if (subjobInfoArray[i].Type == 0)
			mainLevel = subjobInfoArray[i].Level;
		else if (subjobInfoArray[i].Type == 1)
			dualLevel = subjobInfoArray[i].Level;

		if (currentSubjobClassID == subjobInfoArray[i].ClassID)
		{
			currentType = subjobInfoArray[i].Type;
		}
	}
}


//function AddSkillTrainListItem(string strIconName, string strName, int iID, int iLevel, int iSPConsume, string strEnchantName)
function AddSkillTrainListItem( string param )
{
	local SkillInfo skillinfo;
	
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
	local int RequiredDualLevel;

	//Player 정보
	local UserInfo userinfo;

	//스킬 아이디.
	local ItemID cID;

	local string strRetName;
	local CustomTooltip T;

	local string strName;
	local string strIconName;

	local string setTreeName;

	local string panelName;
	
	local int currentMainLevel;
	local int currentDualLevel;

	local int _currentMainLevel;
	local int _currentDualLevel;
	local int IsNewSkill;

	//local UserInfo myUserInfo;

	ParseInt(param, "ID", ID);
	ParseInt(param, "Level", Level);
	ParseInt(param, "SubLevel", SubLevel);	
	ParseInt64(param, "SpConsume", SpConsume);
	ParseInt(param, "RequiredLevel", RequiredLevel);
	ParseInt(param, "RequiredDualLevel", RequiredDualLevel);	
	ParseInt(param,"IsNewSkill",IsNewSkill);

	//Debug ( "배워야 할 목록 들 AddSkillTrainListItem" @ SubLevel ) ;
	cID = GetItemID(ID);
	GetSkillInfo( ID , Level, SubLevel, skillInfo );
	GetPlayerInfo( userinfo );

	strName = skillInfo.SkillName;
	strIconName = class'UIDATA_SKILL'.static.GetIconName( cID, Level, SubLevel );
	panelName = skillInfo.IconPanel;	


	/*
	Debug( "strName>>>>" $  strName );
	Debug( "ID>>>>>" $ string( ID ) );
	Debug( "Level>>>>>" $ string( Level ) );	
	Debug( "SpConsume>>>>>" $ string( SpConsume ) );	
	Debug( "RequiredLevel>>>>>" $ string( RequiredLevel ) );	
	Debug( "RequiredDualLevel>>>>>" $ string( RequiredDualLevel ) );	
	debug("class'UIDATA_SKILL'.static.SkillIsNewOrUp( cID )>>>" $ string( class'UIDATA_SKILL'.static.SkillIsNewOrUp( cID ) ) );
	*/

	//툴팁생성.
	util.setCustomTooltip( T );
	util.ToopTipMinWidth( 200 );
	
	MakeSkillToolTip( strName, cID, Level, SubLevel, param );	

	if(RequiredDualLevel > 0 )
	{
		currentMainLevel = mainLevel;	
		currentDualLevel = dualLevel;
	}
	else
	{
		currentMainLevel = userinfo.nLevel;
		currentDualLevel = userinfo.nLevel;
	}	
	
	if( RequiredLevel <= currentMainLevel && RequiredDualLevel <= currentDualLevel)
	{
		if(IsNewSkill == 1)
		{		
			// 새로 배울 스킬
			setTreeName = ROOTNAME$"."$LIST1;			
			strRetName = util.TreeInsertItemTooltipNode( TREENAME, ""$ ID $","$ Level  $","$ newSkillIndex $","$SubLevel, setTreeName, -7, 0, 38, 0, 30, 38, util.getCustomTooltip() );

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
			if( TypeCheck( skillinfo ) == true )
			//if( class'UIDATA_SKILL'.static.GetOperateType(cID, Level) == GetSystemString(311) )
			{
				//Insert Node Item - 아이템 아이콘
				util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "l2ui_ct1.SkillWnd_DF_ListIcon_Active", 32, 32, -33, OFFSET_Y_ICON_TEXTURE - 2 );

				//Insert Node Item - 아이템 이름
				util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, strName, 5, 5, util.ETreeItemTextType.COLOR_DEFAULT, true );
				//Insert Node Item - "Lv"
				util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, GetSystemString(88), 46, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GRAY, true, true );
				//Insert Node Item - 레벨 값
				util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, string(Level), 2, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GOLD );
				//Insert Node Item - MP물약 아이콘 ( 소모엠피 )
				util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "L2UI_CT1.SkillWnd_DF_ListIcon_MP", 15, 15, 5, OFFSET_Y_SECONDLINE + 1 );
				//Insert Node Item - "소모엠피 값"
				util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, string(skillInfo.MpConsume), 0, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GRAY );
				//Insert Node Item - 시간 아이콘 ( 시전시간 )
				util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "L2UI_CT1.SkillWnd_DF_ListIcon_use", 15, 15, 5, OFFSET_Y_SECONDLINE + 1 );
				//Insert Node Item - "시전시간 값"
				util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, util.MakeTimeString( skillInfo.HitTime, skillInfo.CoolTime ), 0, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GRAY );
				//Insert Node Item - 시간 아이콘 ( 재사용시간 )
				util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "L2UI_CT1.SkillWnd_DF_ListIcon_Reuse", 15, 15, 5, OFFSET_Y_SECONDLINE + 1 );
				//Insert Node Item - "재사용시간 값"
				util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, util.MakeTimeString( skillInfo.ReuseDelay ) , 0, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GRAY );
			}
			else
			{
				util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "l2ui_ct1.SkillWnd_DF_ListIcon_Passive", 32, 32, -33, OFFSET_Y_ICON_TEXTURE - 2 );

				//Insert Node Item - 아이템 이름
				util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, strName, 5, 5, util.ETreeItemTextType.COLOR_DEFAULT, true );
				//Insert Node Item - "Lv"
				util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, GetSystemString(88), 46, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GRAY, true, true );
				//Insert Node Item - 레벨 값
				util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, string(Level), 2, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GOLD );
			}

			//********************************************************************************************************************************************************************

		}
		else
		{	
			//메인클래스 레벨과 듀얼클래스 레벨을 비교한다.
			//if( RequiredLevel <=  currentMainLevel && RequiredDualLevel <= currentDualLevel)
			if(RequiredDualLevel > 0 )
			{
				_currentMainLevel = mainLevel;
				_currentDualLevel = dualLevel;
				
			}
			else
			{
				_currentMainLevel = userinfo.nLevel;
				_currentDualLevel = userinfo.nLevel;
				
			}
			

			if( RequiredLevel <= _currentMainLevel && RequiredDualLevel <= _currentDualLevel)
			{
				// 레벨업 할 스킬 
				setTreeName = ROOTNAME$"."$LIST2;
				strRetName = util.TreeInsertItemTooltipNode( TREENAME, ""$ ID $","$ Level $","$ levelUpSkillIndex $","$SubLevel , setTreeName, -7, 0, 38, 0, 32, 38, util.getCustomTooltip() );
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
				
				//Operate Type(액티브/패시브)
				//if( class'UIDATA_SKILL'.static.GetOperateType(cID, Level) == GetSystemString(311) )
				if( TypeCheck( skillinfo ) == true )
				{
					//Insert Node Item - 아이템 아이콘
					util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "l2ui_ct1.SkillWnd_DF_ListIcon_Active", 32, 32, -34, OFFSET_Y_ICON_TEXTURE - 1 );

					//Insert Node Item - 아이템 이름
					util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, strName, 5, 5, util.ETreeItemTextType.COLOR_DEFAULT, true );
					//Insert Node Item - "Lv"
					util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, GetSystemString(88), 46, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GRAY, true, true );
					//Insert Node Item - 레벨 값
					util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, string(Level), 2, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GOLD );
					//Insert Node Item - MP물약 아이콘 ( 소모엠피 )
					util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "L2UI_CT1.SkillWnd_DF_ListIcon_MP", 15, 15, 5, OFFSET_Y_SECONDLINE + 1 );
					//Insert Node Item - "소모엠피 값"
					util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, string(skillInfo.MpConsume), 0, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GRAY );
					//Insert Node Item - 시간 아이콘 ( 시전시간 )
					util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "L2UI_CT1.SkillWnd_DF_ListIcon_use", 15, 15, 5, OFFSET_Y_SECONDLINE + 1 );
					//Insert Node Item - "시전시간 값"
					util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, util.MakeTimeString( skillInfo.HitTime, skillInfo.CoolTime ), 0, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GRAY );
					//Insert Node Item - 시간 아이콘 ( 재사용시간 )
					util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "L2UI_CT1.SkillWnd_DF_ListIcon_Reuse", 15, 15, 5, OFFSET_Y_SECONDLINE + 1 );
					//Insert Node Item - "재사용시간 값"
					util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, util.MakeTimeString( skillInfo.ReuseDelay ) , 0, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GRAY );
				}
				else
				{
					util.TreeHandleInsertTextureNodeItem( m_UITree, strRetName, "l2ui_ct1.SkillWnd_DF_ListIcon_Passive", 32, 32, -34, OFFSET_Y_ICON_TEXTURE - 1 );

					//Insert Node Item - 아이템 이름
					util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, strName, 5, 5, util.ETreeItemTextType.COLOR_DEFAULT, true );
					//Insert Node Item - "Lv"
					util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, GetSystemString(88), 46, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GRAY, true, true );
					//Insert Node Item - 레벨 값
					util.TreeHandleInsertTextNodeItem( m_UITree, strRetName, string(Level), 2, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GOLD );
				}
			}
			//********************************************************************************************************************************************************************
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

function MakeSkillToolTip( string strName, ItemID ID, int Level, int SubLevel, string param )
{	
	local SkillInfo skillinfo;

	local int skillID;

	//요구레벨 ( 플레이어의 현재 레벨과 비교해서 못배우는 것인지를 판단하면됨)
	local int RequiredLevel;
	//요구레벨 ( 플레이어의 듀얼 클래스 레벨과 비교 하여 못 배우는 것인지를 판단.)
	local int RequiredDualLevel;

	//스킬에 필요한 아이템 갯수 
	local int RequiredItemTotalCnt;
	//ItemID (위에 총 갯수만큼 반복) 
	local int requiredItemID;
	//Item 필요갯수 (위에 총 갯수만큼 반복) 
	local int requiredItemCnt;


	//스킬에 필요한 선행 스킬 갯수 
	local INT64 RequiredSkillCnt;
	//필요 Skill의 ID (위에 총 갯수만큼 반복) 
	local int requiredSkillID;
	//필요 Skill의 level (위에 총 갯수만큼 반복) 
	local int requiredSkillLevel;


	local itemID requiredID;

	local int i;

	//local string additionalName;
	local int nTmp;


	if ( !m_bShow ) return;

	ParseInt(param, "ID", skillID);

	GetSkillInfo( skillID , Level, SubLevel, skillInfo );

	ParseInt(param, "RequiredLevel", RequiredLevel);
	ParseInt(param, "RequiredDualLevel", RequiredDualLevel);

	ParseInt(param, "RequiredItemTotalCnt", RequiredItemTotalCnt);
	ParseINT64(param, "RequiredSkillCnt", RequiredSkillCnt);
	
	//additionalName = class'UIDATA_ITEM'.static.GetItemAdditionalName( ID );

	//아이템 이름
	util.ToopTipInsertText( strName, true );	
	//ex) " Lv "
	util.ToopTipInsertText( " " $ GetSystemString(88), true, false, util.ETooltipTextType.COLOR_GRAY );
	//스킬 레벨
	util.ToopTipInsertText( " " $ string(Level), true, false, util.ETooltipTextType.COLOR_GOLD );
	
	//인챈트 내용
	//util.ToopTipInsertText( additionalName, true, false, util.ETooltipTextType.COLOR_GOLD, 5 );

	//Operate Type(액티브/패시브)
	util.ToopTipInsertText( class'UIDATA_SKILL'.static.GetOperateType( ID, Level, SubLevel), true, true, util.ETooltipTextType.COLOR_GOLD, 0, 6 );

	util.TooltipInsertItemBlank( 6 );

	//소모HP
	nTmp = class'UIDATA_SKILL'.static.GetHpConsume( ID, Level, SubLevel );
	if (nTmp>0)
	{
		util.TwoWordCombineColon( GetSystemString(1195), string( nTmp ), util.ETooltipTextType.COLOR_GRAY, util.ETooltipTextType.COLOR_GOLD, true );
	}

	//소모MP
	nTmp = class'UIDATA_SKILL'.static.GetMpConsume( ID, Level, SubLevel );
	if (nTmp>0)
	{
		util.TwoWordCombineColon( GetSystemString(320), string( nTmp ), util.ETooltipTextType.COLOR_GRAY, util.ETooltipTextType.COLOR_GOLD, true );
	}

	//유효거리
	nTmp = class'UIDATA_SKILL'.static.GetCastRange( ID, Level, SubLevel );
	if (nTmp>=0)
	{
		util.TwoWordCombineColon( GetSystemString(321), string( nTmp ), util.ETooltipTextType.COLOR_GRAY, util.ETooltipTextType.COLOR_GOLD, true );
	}
	
	//시전시간 값
	if( class'UIDATA_SKILL'.static.GetOperateType( ID, Level,SubLevel ) == GetSystemString(311) )
	{
		util.TwoWordCombineColon( GetSystemString(2377), util.MakeTimeString( int(skillInfo.HitTime ), int(skillInfo.CoolTime ) ), util.ETooltipTextType.COLOR_GRAY, util.ETooltipTextType.COLOR_GOLD, true );
	}

	//재사용시간
	if( class'UIDATA_SKILL'.static.GetOperateType( ID, Level, SubLevel ) == GetSystemString(311) )
	{
		util.TwoWordCombineColon( GetSystemString(2378), util.MakeTimeString( int(skillInfo.ReuseDelay ) ), util.ETooltipTextType.COLOR_GRAY, util.ETooltipTextType.COLOR_GOLD, true );
	}

	//스킬 설명
	util.ToopTipInsertText( class'UIDATA_SKILL'.static.GetDescription( ID, Level, SubLevel ), false, true, util.ETooltipTextType.COLOR_GRAY, 0, 6 );

	util.TooltipInsertItemBlank( 6 );
	util.TooltipInsertItemLine();
	util.TooltipInsertItemBlank( 3 );

	//<배우기 조건>
	util.ToopTipInsertText( "<"$GetSystemString(2375)$">", true, true );
	util.TwoWordCombineColon( GetSystemString(2381), string(RequiredLevel), util.ETooltipTextType.COLOR_GRAY, util.ETooltipTextType.COLOR_GOLD, true );

	//듀얼클래스 레벨
	if( RequiredDualLevel > 0 )
	{
		//듀얼 클래스 Lv
		util.TwoWordCombineColon( GetSystemString(2969), string(RequiredDualLevel), util.ETooltipTextType.COLOR_GRAY, util.ETooltipTextType.COLOR_GOLD, true );
	}

	//필요 아이템	
	if( RequiredItemTotalCnt > 0 )
	{
		util.TooltipInsertItemBlank( 6 );
		util.ToopTipInsertText( "<"$GetSystemString(2380)$">", true, true );

		for(  i = 1 ; i <= RequiredItemTotalCnt ; i++ )
		{
			Parseint( param, "requiredItemID"$i, requiredItemID );
			ParseInt(param, "requiredItemCnt"$i, requiredItemCnt);
			util.ToopTipInsertText( class'UIDATA_ITEM'.static.GetItemName( GetItemID( requiredItemID ) ) $ " X " $string(requiredItemCnt), false, true, util.ETooltipTextType.COLOR_GOLD );
		}   
	}
	
	//스킬에 필요한 선행 스킬 갯수 
	if( RequiredSkillCnt > 0 )
	{
		util.TooltipInsertItemBlank( 6 );
		util.ToopTipInsertText( "<"$GetSystemString(2376)$">", true );

		for( i = 1 ; i <= RequiredSkillCnt ; i++ )
		{			
			ParseInt(param, "requiredSkillID"$i, requiredSkillID);
			ParseInt(param, "requiredSkillLevel"$i, requiredSkillLevel);
			
			requiredID = GetItemID( requiredSkillID );
			
			util.TooltipInsertItemBlank( 3 );
			// !문제 있는지 확인 할 것 
			util.ToopTipInsertTexture( class'UIDATA_SKILL'.static.GetIconName( requiredID, requiredSkillLevel, 0 ), true, true );
			if( class'UIDATA_SKILL'.static.SkillIsNewOrUp(requiredID) == 0 )
			{
				util.ToopTipInsertTexture( "l2ui_ct1.ItemWindow_IconDisable" , , , -16);
				util.ToopTipInsertText( class'UIDATA_SKILL'.static.GetName( requiredID, requiredSkillLevel, 0 ), true, false, util.ETooltipTextType.COLOR_GRAY, 5 );
			}
			else
			{
				util.ToopTipInsertText( class'UIDATA_SKILL'.static.GetName( requiredID, requiredSkillLevel, 0 ), true, false, , 5 );
			}
		}		
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
 * 외부에서 스킬 학습을 배울때 콜 한다.
 **/
function externalCallLearnSkill()
{
	// 윈도우 열기
	m_wndTop.ShowWindow();
	m_wndTop.SetFocus();

	// 스킬 배우기 탭으로 이동
	GetTabHandle("MagicSkillWnd.TabCtrl").SetTopOrder(2, false);

	// 탭 누른 경우 처리 
	onClickButton("TabCtrl2");	
}

/**
 * 외부에서 스킬 학습을 배울때 콜 한다.
 **/
function bool isSkillLearnTab()
{
	// 스킬 습득 탭이면.. true
	return (GetTabHandle("MagicSkillWnd.TabCtrl").GetTopIndex() == 2);
}

/**
 * 
 */
function closeTreeNode()
{
	m_UITree.SetExpandedNode( beforeTreeName, false );
	beforeTreeName = "";
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
    m_WindowName="MagicSkillWnd"
    TREENAME="MagicSkillWnd.SkillTrainTree"
    ROOTNAME="root"
    LIST1="SKILLLIST1"
    LIST2="SKILLLIST2"
    LIST3="SKILLLIST3"
}
