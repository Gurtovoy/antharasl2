/**
 * 
 *   혈맹 보상 UI (스팀 초최 업데이트 때 들어감), 클래식도 들어가야 해서 추가
 *   
 *   
 *   bool IsUsePledgeBonus()

	l2.ini
	[Localize]
	UsePledgeBonus=true
	설정에 따라 보이고 안보이고 하는 식으로 분기 됩니다.
 *   
 **/


/**
 *  
 *   bool IsUsePledgeBonus()

	l2.ini
	[Localize]
	UsePledgeBonus=true
	설정에 따라 보이고 안보이고 하는 식으로 분기 됩니다.

	빌드 명령어
	- 출석 보너스 추가
	//pledge_bonus access [value]

	- 사냥 보너스 추가
	//pledge_bonus hunt [value]

	- 다음 날로 변경
	-      현재 값으로 보상 결정하고 모든 값을 초기화 시킴)
	//pledge_bonus pass
 *   
 **/
class ClanPledgeBonusDrawerWndClassic extends UICommonAPI;

const ACCESS_TYPE = 0;
const HUNT_TYPE = 1;

var WindowHandle Me;

var ItemWindowHandle JoinYesterdayBonus_Item_ItemWnd;
var ItemWindowHandle HuntYesterdayBonus_Item_ItemWnd;

var string JoinWndPath;
var string HuntWndPath;
var bool hasPledgeBonusList;

var string m_WindowName;

var string m_ClanPledgeRaidWindowName;

// 접속 보상 최대값, 사냥 보상 최대 값 
var int accessBonusMax, huntBonusMax;

function OnRegisterEvent()
{
	// 10140
	RegisterEvent( EV_PledgeBonusOpen ); 
	RegisterEvent( EV_PledgeBonusList );

	RegisterEvent( EV_PledgeBonusUpdate );
	RegisterEvent( EV_PledgeBonusMarkReset );

	RegisterEvent( EV_Restart );

	RegisterEvent( EV_PledgeClassicRaidInfo );
	//RegisterEvent( EV_Test_7 );	
}

function OnLoad()
{
	local string strStep;
	SetClosingOnESC();
	Initialize();

	strStep = GetSystemString(898) @ GetSystemString(2980) @ ":";
	// 단계 표시
	if(GetLanguage() == ELanguageType.LANG_Russia || GetLanguage() == ELanguageType.LANG_Euro)
		strStep = GetSystemString(3655) @ ":";

	GetTextBoxHandle(m_WindowName$"."$m_ClanPledgeRaidWindowName$"."$"ClanRaidStageTitle_Text").SetText(strStep);
}

function Initialize()
{
	Me = GetWindowHandle( m_WindowName );

	JoinWndPath = m_WindowName $ ".ClanPledgeBonus_Window.JoinBonusWnd";
	HuntWndPath = m_WindowName $ ".ClanPledgeBonus_Window.HuntBonusWnd";
	
	JoinYesterdayBonus_Item_ItemWnd = GetItemWindowHandle( m_WindowName $ ".ClanPledgeBonus_Window.JoinBonusWnd.JoinYesterdayBonus_Item_ItemWnd" );
	HuntYesterdayBonus_Item_ItemWnd = GetItemWindowHandle( m_WindowName $ ".ClanPledgeBonus_Window.HuntBonusWnd.HuntYesterdayBonus_Item_ItemWnd" );

	hasPledgeBonusList = false;
}

function OnShow()
{
	if(getInstanceUIData().getIsClassicServer())
	{
		if(GetWindowHandle("ClanDrawerWndClassic").IsShowWindow())
			ClanDrawerWndClassic(GetScript("ClanDrawerWndClassic")).HideClanWindow();
	}
	else
	{
		if(GetWindowHandle("ClanDrawerWnd").IsShowWindow())
			ClanDrawerWnd(GetScript("ClanDrawerWnd")).HideClanWindow();
	}

	//Debug("창이 열린다.. -_-IsClassicServer()" @ getInstanceUIData().getIsClassicServer());
}


/************************************************************************************
 * ClanPledgeBonus_Window
 * **********************************************************************************/
// 개별 실시간 업데이트 추가
function PlegeBonusUpdate(string param)
{
	local int missionType, currPoint;

	if(Me.IsShowWindow())
	{
		ParseInt( param, "MissionType", missionType );  
		ParseInt( param, "CurrPoint"  , currPoint );  

		if (missionType == HUNT_TYPE)
		{
			if (huntBonusMax > 0)
			{
				GetTextBoxHandle (HuntWndPath $ ".HuntBonus_MemberCount1_Text").SetText(String(currPoint));
				GetTextBoxHandle (HuntWndPath $ ".HuntBonus_MemberCount2_Text").SetText("/" $ string(huntBonusMax));
				setStateProgress(missionType, huntBonusMax, currPoint);
			}
		}
		else
		{
			if (accessBonusMax > 0)
			{
				GetTextBoxHandle (JoinWndPath $ ".JoinBonus_MemberCount1_Text").SetText(String(currPoint));
				GetTextBoxHandle (JoinWndPath $ ".JoinBonus_MemberCount2_Text").SetText("/" $ string(accessBonusMax));
				setStateProgress(missionType, accessBonusMax, currPoint);
			}
		}
	}
}

// 보너스 윈도우 초기화 정보입니다.
function PledgeBonusOpenHandler(string param)
{
	local int accessBonusCurr, accessRewardID,accessRewardSkillLV, accessBtnActive;
	local int huntBonusCurr, huntRewardID, huntRewardLV, huntBtnActive;

	local SkillInfo accessBonusSkillInfo, huntRewardSkillInfo;
	local ItemInfo  accessBonusItemInfo, huntRewardItemInfo;

	local int AccessRewardType, HuntRewardType;

	// Debug("PledgeBonusOpenHandler param:" @ param);
	// (accessBonusMax / 4) 
	if(!Me.IsShowWindow()) Me.ShowWindow();

	ParseInt( param, "AccessRewardType", AccessRewardType );          // 보상이 스킬이냐 아이템이냐

	ParseInt( param, "AccessBonusMax", accessBonusMax );            // 총 4단계의 맥스값입니다.  200이면 나누기 4 하여 각 단계는 50씩입니다.
	ParseInt( param, "AccessBonusCurr", accessBonusCurr );          // 현재 누적값입니다.
	ParseInt( param, "AccessRewardID", accessRewardID );            // 보상 받게 될 스킬 ID
	ParseInt( param, "AccessRewardLV", accessRewardSkillLV );       // 보상 받게 될 스킬 level
	ParseInt( param, "AccessBtnActive", accessBtnActive );          // 접속 보너스 보상받기 버튼 활성화 여부

	//AccessRewardLV 

	ParseInt( param, "HuntRewardType"  , HuntRewardType );      // 보상이 스킬이냐 아이템이냐

	ParseInt( param, "HuntBonusMax"    , huntBonusMax );        // 접속 보너스와 동일
	ParseInt( param, "HuntBonusCurr"   , huntBonusCurr );       // 접속 보너스와 동일
	ParseInt( param, "HuntRewardID"    , huntRewardID );        // 보상 받게 될 아이템 또는 스킬 ID
	ParseInt( param, "HuntRewardLV"    , huntRewardLV );        // 보상 받게 될 아이템 level
	ParseInt( param, "HuntBtnActive"   , huntBtnActive );       // 사냥 보너스 보상받기 버튼 활성화 여부

	

	// 전일 접속 보상 스킬 정보
	
	JoinYesterdayBonus_Item_ItemWnd.Clear();
	JoinYesterdayBonus_Item_ItemWnd.ClearTooltip();
	JoinYesterdayBonus_Item_ItemWnd.SetTooltipType("");

	if (accessRewardID > 0)
	{
		// 1=아이템 
		if(AccessRewardType == 1)
		{
			class'UIDATA_ITEM'.static.GetItemInfo(GetItemID(accessRewardID), accessBonusItemInfo);	
			JoinYesterdayBonus_Item_ItemWnd.AddItem(accessBonusItemInfo);
			JoinYesterdayBonus_Item_ItemWnd.SetTooltipType("Inventory");			
		}
		// 2=스킬
		else
		{
			GetSkillInfo(accessRewardID,1,0,accessBonusSkillInfo);
			JoinYesterdayBonus_Item_ItemWnd.AddItem(getItemInfoBySkillInfo(accessBonusSkillInfo));
			JoinYesterdayBonus_Item_ItemWnd.SetTooltipType("Skill");
		}		
	}

	GetTextBoxHandle (JoinWndPath $ ".JoinBonus_MemberCount1_Text").SetText(String(accessBonusCurr));
	GetTextBoxHandle (JoinWndPath $ ".JoinBonus_MemberCount2_Text").SetText("/" $ string(accessBonusMax));

	if (accessRewardID > 0) 
	{
		// 1=아이템 
		if(AccessRewardType == 1)
		{
			GetTextBoxHandle (JoinWndPath $ ".JoinYesterdayBonusLV_Text").SetText("");
			GetNameCtrlHandle(JoinWndPath $ ".JoinYesterdaydayBonusName_Text").SetName(accessBonusItemInfo.Name, NCT_Normal, TA_Left);
		}
		// 2=스킬
		else
		{
			GetTextBoxHandle (JoinWndPath $ ".JoinYesterdayBonusLV_Text").SetText("Lv" $ accessRewardSkillLV);
			GetNameCtrlHandle(JoinWndPath $ ".JoinYesterdaydayBonusName_Text").SetName(accessBonusSkillInfo.SkillName, NCT_Normal, TA_Left);
		}
	}
	else
	{
		GetTextBoxHandle (JoinWndPath $ ".JoinYesterdayBonusLV_Text").SetText("");
		GetNameCtrlHandle(JoinWndPath $ ".JoinYesterdaydayBonusName_Text").SetName(GetSystemString(5852), NCT_Normal, TA_Left);
	}

	setStateProgress(ACCESS_TYPE, accessBonusMax, accessBonusCurr);

	HuntYesterdayBonus_Item_ItemWnd.Clear();
	HuntYesterdayBonus_Item_ItemWnd.ClearTooltip();
	HuntYesterdayBonus_Item_ItemWnd.SetTooltipType("");

	if (huntRewardID > 0)
	{
		// 1=아이템 
		if(HuntRewardType == 1)
		{
			// 전일 사냥 보상 스킬 정보
			class'UIDATA_ITEM'.static.GetItemInfo(GetItemID(huntRewardID), huntRewardItemInfo);
			HuntYesterdayBonus_Item_ItemWnd.AddItem(huntRewardItemInfo);
			HuntYesterdayBonus_Item_ItemWnd.SetTooltipType("Inventory");
			
		}
		// 2=스킬
		else
		{
			GetSkillInfo(huntRewardID, 1, 0, huntRewardSkillInfo);
			HuntYesterdayBonus_Item_ItemWnd.AddItem(getItemInfoBySkillInfo(huntRewardSkillInfo));
			HuntYesterdayBonus_Item_ItemWnd.SetTooltipType("Skill");			
		}
	}

	GetTextBoxHandle (HuntWndPath $ ".HuntBonus_MemberCount1_Text").SetText(String(huntBonusCurr));
	GetTextBoxHandle (HuntWndPath $ ".HuntBonus_MemberCount2_Text").SetText("/" $ string(huntBonusMax));

	if (huntRewardLV > 0) 
	{
		GetTextBoxHandle (HuntWndPath $ ".HuntYesterdaydayBonusLV_Text").SetText("Lv" $ huntRewardLV);
		GetNameCtrlHandle(HuntWndPath $ ".HuntYesterdaydayBonusName_Text").SetName(huntRewardItemInfo.Name, NCT_Normal, TA_Left);
	}
	else 
	{
		GetTextBoxHandle (HuntWndPath $ ".HuntYesterdaydayBonusLV_Text").SetText("");
		GetNameCtrlHandle(HuntWndPath $ ".HuntYesterdaydayBonusName_Text").SetName(GetSystemString(5852), NCT_Normal, TA_Left);
	}

	setStateProgress(HUNT_TYPE, huntBonusMax, huntBonusCurr);

	// 버튼, 활성, 비활성
	// ------------------
	// 접속 보상 버튼
	if(accessBtnActive > 0)
		GetButtonHandle(JoinWndPath $ ".Clan1_ManageBtn").EnableWindow();
	else
		GetButtonHandle(JoinWndPath $ ".Clan1_ManageBtn").DisableWindow();

	// 사냥 보상 버튼
	if (huntBtnActive > 0) 
		GetButtonHandle(HuntWndPath $ ".Clan2_ManageBtn").EnableWindow();
	else
		GetButtonHandle(HuntWndPath $ ".Clan2_ManageBtn").DisableWindow();
}

//HuntWndPath $ ".
//JoinWndPath $ ".
// 진행 상황  nStep : 1~4,  nProgress : 1~3
function setStateProgress(int bonusType, int nMax, int nCur)
{
	local string taretPath, arrowTexture;
	local string stateWnd;
	local float maxStep;          // 1~4 단계
	//local int nProgressStep;    // 각 단계안에는 또 3단계로 구분
	local float fProgressStep;    // 각 단계안에는 또 3단계로 구분

	local int nLevel, nProgress;
	local float fProgress;
	local int i, n;

	if (bonusType == ACCESS_TYPE) 
	{
		stateWnd = JoinWndPath;
		arrowTexture = ".PledgeArrow";
	}
	else
	{
		stateWnd = HuntWndPath;
		arrowTexture = ".HuntArrow";
	}
	
	maxStep = float(nMax) / 4;
	nLevel = (nCur / maxStep) + 1;

	//fLevel = (nCur / maxStep);

	//nProgressStep = maxStep / 3;
	fProgressStep = maxStep / 3;

	//nProgress = (nCur % maxStep) / nProgressStep;
	fProgress = (nCur % maxStep) / fProgressStep;
	nProgress = appCeil(fProgress);

	//Debug("-------------------------------");
	//Debug("nMax" @ nMax);
	//Debug("maxStep" @ maxStep);
	//Debug("nLevel" @ nLevel);
	//Debug("nProgressStep" @ nProgressStep);
	//Debug("nCur % maxStep" @ nCur % maxStep);
	//Debug("nProgress" @ nProgress);
	//Debug("fProgress" @ fProgress);

	// 한 범위의 마지막칸 3번째를 갈때만..
	//if(hasPoint(fProgress) && nProgress < fProgress) 
	//{
	//	if (nProgress <= 2) nProgress = nProgress + 1;
	//}
	
	//Debug("==> nProgress" @ nProgress);

	// 비활성화 
	for (i = 1; i < 5; i++)
	{
		for (n = 1; n < 4; n++)
		{
			taretPath = stateWnd $ arrowTexture $ i $ "_" $ n $ "_disable_Texture";
			
			// 지나온거
			if (i == nLevel && n < nProgress)
			{
				GetTextureHandle(taretPath).SetTexture("l2ui_ct1.PledgeArrow_normal");
				// Debug("같은 레벨 지나온거 " @ taretPath);
			}
			else if (i < nLevel)
			{
				GetTextureHandle(taretPath).SetTexture("l2ui_ct1.PledgeArrow_normal");
				//GetTextureHandle(taretPath).SetTexture("l2ui_ct1.PledgeArrow_disable");
				// Debug("이전 레벨 지나온거 " @ taretPath);
			}
			// 현재, n = 1번째는 첫번째 칸, 한칸도 불이 안들어온 상태에서 한칸보다 약간이라도 값이 들어 있으면 한칸을 킨다.
			else if (i == nLevel && n == nProgress)
			{
				GetTextureHandle(taretPath).SetTexture("l2ui_ct1.PledgeArrow_get");
			}
			// 비활성
			else
			{
				// Debug("비활성 " @ taretPath);
				GetTextureHandle(taretPath).SetTexture("l2ui_ct1.PledgeArrow_disable");
			}

			// Debug("비활성 taretPath : " @ taretPath);
			// GetTextureHandle(taretPath).SetTexture("L2ui_ct1.clan_DF_warlist_arrow5");
		}

		taretPath = stateWnd $ "." $ "PledgeSelectPanel0" $ i $ "_ani";

		GetAnimTextureHandle(taretPath).Stop();
		GetAnimTextureHandle(taretPath).Pause();
		GetAnimTextureHandle(taretPath).HideWindow();

		if (nLevel > i)
			setEnablePledgeBonus(bonusType, i, true);
		else 
			setEnablePledgeBonus(bonusType, i, false);
	}

	if (nLevel > 1)
	{
		taretPath = stateWnd $ "." $ "PledgeSelectPanel0" $ nLevel - 1 $ "_ani";

		GetAnimTextureHandle(taretPath).SetLoopCount(9999999);
		GetAnimTextureHandle(taretPath).ShowWindow();		
		GetAnimTextureHandle(taretPath).Play();

		// setEnablePledgeBonus(bonusType, nLevel - 1, true);
	}

	if (nCur > 0) setEnableFlagTexture(bonusType, true);
	else setEnableFlagTexture(bonusType, false);

}

// 혈맹 마크 첫번째 깃발 텍스쳐 활성, 비활성
function setEnableFlagTexture(int bonusType, bool bFlag)
{
	local string stateWnd;

	if (bonusType == ACCESS_TYPE) 
	{
		stateWnd = JoinWndPath;
	}
	else
	{
		stateWnd = HuntWndPath;
	}

	// 혈맹 깃발 불 켜진 것
	if (bFlag)
	{
		GetTextureHandle(stateWnd $ ".PledgeflagIcon2_texture").SetTexture("L2UI_CT1.PledgeflagIcon3");
	}
	else
	{
		// 혈맹 깃발 불 꺼진 것 
		GetTextureHandle(stateWnd $ ".PledgeflagIcon2_texture").SetTexture("L2UI_CT1.PledgeflagIcon2");
	}
}

// 소수점이 있나? 0은 없다로 취급
function bool hasPoint(float num)
{
	local string temp;
	local Array<string> result;

	temp = String(num);

	Split( temp, ".", result );

	return int(result[1]) > 0;
}

function addItemSlot(ItemWindowHandle itemWnd, ItemInfo pIteminfo)
{
	itemWnd.Clear();
	itemWnd.AddItem(pIteminfo);
}

function ItemInfo getItemInfoBySkillInfo(SkillInfo rSkilInfo)
{
	local itemInfo infItem;
	infItem.ID.classID  = rSkilInfo.SkillID;
	
	infItem.Level = 1;    // rSkilInfo.SkillLevel;
	infItem.SubLevel = 0; //rSkilInfo.SkillSubLevel;
	infItem.Name = rSkilInfo.SkillName;
	//infItem.AdditionalName = rSkilInfo.strEnchantName;
	infItem.IconName = rSkilInfo.TexName;
	infItem.IconPanel = rSkilInfo.IconPanel;
	infItem.Description = rSkilInfo.SkillDesc;
	infItem.ItemSubType = int(EShortCutItemType.SCIT_SKILL);

	infItem.ItemType = 1; // rSkilInfo.OperateType;

	return infItem;
}

// 접속보너스 스킬 ID 4종, 사냥보너스 아이템 ID 4종
function PledgeBonusListHandler(string param)
{
	local int accessReward;
	local int huntReward;

	local SkillInfo mSkillInfo, tempSkillInfo;
	local ItemInfo mItemInfo, tempItemInfo;
	local int i;

	local int accessType, huntType;

	ParseInt( param, "AccessType", accessType);  
	ParseInt( param, "HuntType"  , huntType );        

	hasPledgeBonusList = true;

	for(i = 1; i < 5; i++)
	{
		ParseInt( param, "AccessReward" $ i, accessReward );  
		ParseInt( param, "HuntReward" $ i, huntReward );      

		GetItemWindowHandle(JoinWndPath $ ".BonusItem" $ i $ "_ItemWin").Clear();
		GetItemWindowHandle(JoinWndPath $ ".BonusItem" $ i $ "_ItemWin").ClearTooltip();
		GetItemWindowHandle(JoinWndPath $ ".BonusItem" $ i $ "_ItemWin").SetTooltipType("");

		GetItemWindowHandle(HuntWndPath $ ".BonusItem" $ i $ "_ItemWin").Clear();
		GetItemWindowHandle(HuntWndPath $ ".BonusItem" $ i $ "_ItemWin").ClearTooltip();
		GetItemWindowHandle(HuntWndPath $ ".BonusItem" $ i $ "_ItemWin").SetTooltipType("");

		// 1=아이템 
		if (accessType == 1)
		{
			// 혈맹 보상 			
			if (accessReward > 0)
			{
				mItemInfo = tempItemInfo;
				class'UIDATA_ITEM'.static.GetItemInfo(GetItemID(accessReward), mItemInfo);
				addItemSlot(GetItemWindowHandle(JoinWndPath $ ".BonusItem" $ i $ "_ItemWin"), mItemInfo);
				GetItemWindowHandle(JoinWndPath $ ".BonusItem" $ i $ "_ItemWin").SetTooltipType("Inventory");
			}
		}
		// 2=스킬
		else
		{
			// 혈맹 보상 			
			if (accessReward > 0)
			{
				// Debug("accessReward "@ i @ accessReward);
				mSkillInfo = tempSkillInfo;
				GetSkillInfo(accessReward, 1, 0, mSkillInfo);
				addItemSlot(GetItemWindowHandle(JoinWndPath $ ".BonusItem" $ i $ "_ItemWin"), getItemInfoBySkillInfo(mSkillInfo));
				GetItemWindowHandle(JoinWndPath $ ".BonusItem" $ i $ "_ItemWin").SetTooltipType("Skill");
				// Debug("SkillName "@ i @ mSkillInfo.SkillName);
			}

		}
		
		// 1=아이템
		if (huntType == 1)
		{
			// 사냥 보상			
			if (huntReward > 0)
			{
				mItemInfo = tempItemInfo;
				class'UIDATA_ITEM'.static.GetItemInfo(GetItemID(huntReward), mItemInfo);
				addItemSlot(GetItemWindowHandle(HuntWndPath $ ".BonusItem" $ i $ "_ItemWin"), mItemInfo);
				GetItemWindowHandle(HuntWndPath $ ".BonusItem" $ i $ "_ItemWin").SetTooltipType("Inventory");
			}
		}
		// 2=스킬
		else
		{
			// 사냥 보상			
			if (huntReward > 0)
			{
				mSkillInfo = tempSkillInfo;
				GetSkillInfo(huntReward, 1, 0, mSkillInfo);
				addItemSlot(GetItemWindowHandle(HuntWndPath $ ".BonusItem" $ i $ "_ItemWin"), getItemInfoBySkillInfo(mSkillInfo));
				GetItemWindowHandle(HuntWndPath $ ".BonusItem" $ i $ "_ItemWin").SetTooltipType("Skill");
			}
		}
	}
}

// 보상 받을 스킬, 아이템을 활성, 비활성으로 보이도록  index : 1~4, 
function setEnablePledgeBonus(int bonusType, int index, bool bEnable)
{
	local ItemInfo info;
	local string wndPath;

	if(bonusType == ACCESS_TYPE) wndPath = JoinWndPath;
	else wndPath = HuntWndPath;

	if (GetItemWindowHandle(wndPath $ ".BonusItem" $ index $ "_ItemWin").GetItemNum() > 0)
	{
		GetItemWindowHandle(wndPath $ ".BonusItem" $ index $ "_ItemWin").GetItem(0, info);
		GetItemWindowHandle(wndPath $ ".BonusItem" $ index $ "_ItemWin").Clear();		

		if (bEnable) info.ForeTexture = "";
		else info.ForeTexture = "L2UI_CT1.WindowDisable_BG";

		//info.ForeTexture = "L2UI_CT1.ItemWindow.ItemWindow_IconDisable";

		// 

		GetItemWindowHandle(wndPath $ ".BonusItem" $ index $ "_ItemWin").AddItem(info);
	}
}

function OnClickButton( string Name )
{
		switch( Name )
		{
			case "FrameCloseButton":
				 OnFrameCloseButtonClick();
				 break;

			case "FrameResetButton":
				 OnFrameResetButtonClick();
				 break;

			case "CloseBtn":
			case "ClanRaid_CloseBtn":
				 OnCloseBtnClick();
				 break;

			case "Clan1_ManageBtn":
				 OnClan1_ManageBtnClick();
				 break;

			case "Clan2_ManageBtn":
				 OnClan2_ManageBtnClick();
				 break;

		    case "HelpButton" :
				 OnHelpBtnClick();
				 break;
		}
}

// 도움말 열기 
function OnHelpBtnClick()
{
	local string strParam;

	ParamAdd(strParam, "FilePath", "..\\L2text\\Pledge_help001.htm");
	ExecuteEvent(EV_ShowHelp, strParam);
}

function OnFrameCloseButtonClick()
{
	Me.HideWindow();
}

function OnFrameResetButtonClick()
{
	PledgeBonusOpen();
}

function OnCloseBtnClick()
{
	Me.HideWindow();
}

function OnClan1_ManageBtnClick()
{
	// Debug("Call Api ----> PledgeBonusReward (0)");
	PlaySound("ItemSound3.sys_bonus_login");
	PledgeBonusReward(0);
}

function OnClan2_ManageBtnClick()
{
	// Debug("Call Api ----> PledgeBonusReward (1)");
	PlaySound("ItemSound3.sys_bonus_hunt");
	PledgeBonusReward(1);
}

// 접속, 사냥 보너스 스킬, 아이템 정보를 받았나 여부
function bool getHasPledgeBonusList()
{
	return hasPledgeBonusList;
}

/*********************************************************************************************************************************
 * 혈맹 레이드
 * *******************************************************************************************************************************/
function setRaidSkill( int index, int skillID, int skillLevel, int lastRaidPhase) 
{	
	local string windowName;
	local SkillInfo skillInfo;
	local ItemInfo info;
	local ItemID cID;
	local int activeLevel , levelGap;
	
	//Debug ( "setRaidSkill" @ index @ skillID  @ skillLevel )  ;
	if ( ! GetSkillInfo( skillID, skillLevel, 0, skillInfo ) ) return;

	windowName = m_WindowName$"."$m_ClanPledgeRaidWindowName$"."$"Stage0"$ index $"_Window" ;

	//Debug( "setRaidSkill" @  index @ skillID @  skillLevel @ windowName ) ;
	// 스킬 아이템
	cID.classID = skillID ;
	info.ID = cID;
	info.Level = skillLevel;
	info.Name = class'UIDATA_SKILL'.static.GetName( info.ID, info.Level, 0 );	
	info.IconName = class'UIDATA_SKILL'.static.GetIconName( info.ID, info.Level, 0 );
	info.Description = class'UIDATA_SKILL'.static.GetDescription( info.ID, info.Level, 0  );
	info.AdditionalName = class'UIDATA_SKILL'.static.GetEnchantName( info.ID, info.Level, 0 );
	
	//각 레벨 별 5차이씩 더해 준다.
	activeLevel = ( index + 1) * 5;

	// 스테이지 레벨 
	GetTextBoxHandle( windowName$".StageLvNum_text" ).SetText ( string ( activeLevel ) );	
	//스킬 이름
	GetTextBoxHandle( windowName$".Skill_Name_text" ).SetText ( info.Name ) ;
	// 스킬 레벨
	GetTextBoxHandle( windowName$".Skill_LvNum_text").SetText( String (skillLevel)) ;	

	GetWindowHandle( windowName ).SetTooltipType("text");	

	levelGap = lastRaidPhase - activeLevel ;		

	// 활성중 : 레벨 차이가 6 이상 나면 
	if ( levelGap >= 5 ) 
	{
		GetTextureHandle( windowName$".FlagComplete_Icon").SetTexture("L2UI_CT1.PledgeBonusWnd.PledgeFlagCompleteIcon") ;
		GetTextureHandle( windowName$".StageComplete_Icon").SetTexture("L2UI_CT1.PledgeBonusWnd.PledgeStageComplete_Icon") ;
		GetTextureHandle( windowName$".PledgeSelectPanel").SetTexture("L2UI_CT1.EmptyBtn") ;
		GetWindowHandle( windowName ).SetTooltipText( "" ) ;
		info.bDisabled = 0 ;
	}
	// 진행중 : 레벨 차이가 0 이상 5 이하면 
	else if ( levelGap >= 0  ) 
	{	
		GetTextureHandle( windowName$".FlagComplete_Icon").SetTexture("L2UI_CT1.PledgeBonusWnd.PledgeFlagProcessingIcon") ;	
		GetTextureHandle( windowName$".StageComplete_Icon").SetTexture("L2UI_CT1.PledgeBonusWnd.PledgeStageProcessing_Icon") ;	
		GetTextureHandle( windowName$".PledgeSelectPanel").SetTexture("L2UI_CT1.PledgeBonusWnd.PledgeSelectPanel") ;	
		GetWindowHandle( windowName ).SetTooltipText( GetSystemString ( 3351) );
		info.bDisabled = 0;
	}
	// 비활성 상태
	else 
	{	
		GetTextureHandle( windowName$".FlagComplete_Icon").SetTexture("L2UI_CT1.PledgeBonusWnd.PledgeFlagLockIcon") ;	
		GetTextureHandle( windowName$".StageComplete_Icon").SetTexture("L2UI_CT1.PledgeBonusWnd.PledgeStageLock_Icon") ;		
		GetTextureHandle( windowName$".PledgeSelectPanel").SetTexture("L2UI_CT1.PledgeBonusWnd.PledgeCover") ;				
		GetWindowHandle( windowName ).SetTooltipText( GetSystemString ( 2496 ) );		
	}

	class'UIAPI_ITEMWINDOW'.static.Clear( windowName$".StageSkill_ItemWnd" );
	class'UIAPI_ITEMWINDOW'.static.AddItem( windowName$".StageSkill_ItemWnd", info );	
}

function handleSetRaidSkillInfos ( string param ) 
{
	local int i, skillCount, skillID, skillLv, lastRaidPhase ;	
	
	parseInt ( param, "SkillCount", skillCount )  ;
	parseInt ( param, "LastRaidPhase", lastRaidPhase )  ;

	for ( i = 0 ; i < skillCount ; i ++ ) 
	{
		parseInt ( param, "SkillID_"$i, skillID ) ;
		parseInt ( param, "SkillLV_"$i, skillLv ) ;		
		setRaidSkill ( i , skillID, skillLv, lastRaidPhase );
	}
		
	if ( lastRaidPhase == 0 ) GetTextBoxHandle( m_WindowName$"."$m_ClanPledgeRaidWindowName$"."$"ClanRaidMyStage_Text").SetText ( GetSystemString ( 27 ));
	else GetTextBoxHandle( m_WindowName$"."$m_ClanPledgeRaidWindowName$"."$"ClanRaidMyStage_Text").SetText ( GetSystemString ( 88 ) @ string ( lastRaidPhase ));
}




/*********************************************************************************************************************************/
// event
function OnEvent( int a_EventID, String param )
{
	if(!getInstanceUIData().getIsClassicServer()) return;

	switch( a_EventID )
	{	
		case EV_PledgeBonusOpen :	// Enter world 할때 지워 버려야함
			 //Debug("EV_PledgeBonusOpen " @ param);
			if(!Me.IsShowWindow()) Me.ShowWindow();
	         PledgeBonusOpenHandler(param);
			 
			 break;

		case EV_PledgeBonusList :   // 접속보너스 스킬 ID 4종, 사냥보너스 아이템 ID 4종
			 Debug("EV_PledgeBonusList " @ param);
			 PledgeBonusListHandler(param);			 
			 break;

	    case EV_PledgeBonusMarkReset : // 아침 6시 30분이 되면 초기화 리셋
			 //PledgeBonusOpenHandler("");
			 hasPledgeBonusList = false;
			 Me.HideWindow();
			 break;

	    case EV_PledgeBonusUpdate :
			 PlegeBonusUpdate(param);
			 break;

		case EV_Restart:
			 hasPledgeBonusList = false;
			 Me.HideWindow();
			 break;
		case EV_PledgeClassicRaidInfo :		
		// case EV_Test_7 :		
			 handleSetRaidSkillInfos( param )  ;
			 break;
	}
}


/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( getCurrentWindowName(string(Self))).HideWindow();
}


defaultproperties
{
    m_WindowName="ClanPledgeBonusDrawerWndClassic"
    m_ClanPledgeRaidWindowName="ClanPledgeRaid_Window"
}
