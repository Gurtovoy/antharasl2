class UIEventManager extends Interactions
	dynamicrecompile
	native;	

const MAX_PartyMemberCount = 9;
const CREATE_ON_DEMAND = 1;

enum EGMCommandType
{
	GMCOMMAND_None,
	GMCOMMAND_StatusInfo,
	GMCOMMAND_ClanInfo,
	GMCOMMAND_SkillInfo,
	GMCOMMAND_QuestInfo,
	GMCOMMAND_InventoryInfo,
	GMCOMMAND_WarehouseInfo,
};

enum ELanguageType
{
	LANG_Korean,
	LANG_English,
	LANG_Japanese,
	LANG_Taiwan,
	LANG_Chinese,
	LANG_Thai,
	LANG_Philippine,
	LANG_Indonesia,
	LANG_Russia,
	//branch 110824
	LANG_Euro,
	LANG_Germany,
	LANG_France,
	LANG_Poland,
	LANG_Turkey,
};

enum EIMEType
{
	IME_NONE,
	IME_KOR,
	IME_ENG,
	IME_JPN,
	IME_CHN,
	IME_TAIWAN_CHANGJIE,
	IME_TAIWAN_DAYI,
	IME_TAIWAN_NEWPHONETIC,
	IME_TAIWAN_BOSHAMY,
	IME_CHN_MS,
	IME_CHN_JB,
	IME_CHN_ABC,
	IME_CHN_WUBI,
	IME_CHN_WUBI2,
	IME_THAI,
	IME_RUSSIA,
	//branch 110824	
	IME_GERMANY,
	IME_FRANCE,
	IME_POLAND,
	IME_TURKEY,
};

enum EXMLControlType
{
	XCT_None,
	XCT_FrameWnd,
	XCT_Button,
	XCT_TextBox,
	XCT_EditBox,
	XCT_TextureCtrl,
	XCT_ChatListBox,
	XCT_TabControl,
	XCT_ItemWnd,
	XCT_CheckBox,
	XCT_ComboBox,
	XCT_ProgressCtrl,
	XCT_MultiEdit,
	XCT_ListCtrl,
	XCT_ListBox,
	XCT_StatusBarCtrl,
	XCT_NameCtrl,
	XCT_MinimapWnd,
	XCT_ShortcutItemWnd,
	XCT_XMLTreeCtrl,
	XCT_SliderCtrl,
	XCT_EffectButton,
	XCT_TextListBox,
	XCT_RadarWnd,
	XCT_HtmlViewer,
	XCT_RadioButton,
	XCT_InvenWeightWnd,
	XCT_StatusIconCtrl,
	XCT_BarCtrl,
	XCT_ScrollWnd,
	XCT_FishViewportWnd,
	XCT_VIPShopItemInfoWnd,
	XCT_VIPShopNeededItemWnd,
	XCT_DrawPanel,
	XCT_RadarMapCtrl,
	XCT_PropertyController,
	XCT_FlashCtrl,
	XCT_CharacterViewportWnd,
	XCT_SceneCameraCtrl,
	XCT_SceneNpcCtrl,
	XCT_ScenePcCtrl,
	XCT_SceneScreenCtrl,
	XCT_SceneMusicCtrl
};

enum ETrackerAlignType
{
	TAT_Left,
	TAT_Center,
	TAT_Right,
	TAT_Width,
	TAT_Height
};

enum EControlPropertyGroupType
{
	CPGT_None,
	CPGT_Single,			//체크박스가 나온다						ex) <Iconable> <Frame>
	CPGT_SingleRequired,	//아무것도 안나온다						ex) <DefaultProperty>
	CPGT_Multiple,			//부모에 +버튼이 나오고, X버튼이 등장	ex) <ComboBox>의 <ComboItem>
	CPGT_MultipleRequired,	//부모에 +버튼이 나오고, X버튼이 등장하지만 모두 지울수는 없음	ex) <ListCtrl>의 <ListColumnType>
	CPGT_Choice,			//옵션버튼이 나온다						ex) <Size>의 <RelativeSize>와 <AbsoluteSize>
};

enum EControlPropertyItemType
{
	CPIT_None,
	CPIT_Boolean,
	CPIT_Integer,
	CPIT_String
};

enum EControlPropertyRestrictionType
{
	CPRT_None,
	CPRT_Integer,
	CPRT_String
};

enum ETextLinkType
{
	TLT_None,
	TLT_ServerItem,	//서버에 Request하거나 Cache에서 받아옴
	TLT_LocalItem,	//Client의 Item정보를 이용
	TLT_User,		//자동 귓속말
	TLT_SKill,		//Client의 Skill정보를 이용
	TLT_URL			//URL 링크 타입
};

enum EControlOrderWay
{
	COW_None,
	COW_Top,
	COW_Up,
	COW_Down,
	COW_Bottom,
};

enum EProgressBarType
{
	PBT_None,
	PBT_RightLeft,
	PBT_LeftRight,
	PBT_TopBottom,
	PBT_BottomTop,
};

enum ETextureAutoRotateType
{
	ETART_None,
	ETART_Camera,
	ETART_Pawn
};
enum EItemWindowType
{
	ITEMWNDTYPE_ScrollType,
	ITEMWNDTYPE_SideButtonType,
	ITEMWNDTYPE_UpDownButtonType
};

enum EItemWindowIconDrawType
{
	ITEMWND_IconDraw_Default,
	ITEMWND_IconDraw_NoConditionalEffect,
};

enum EAnchorPointType
{
	ANCHORPOINT_None,
	ANCHORPOINT_TopLeft,
	ANCHORPOINT_TopCenter,
	ANCHORPOINT_TopRight,
	ANCHORPOINT_CenterLeft,
	ANCHORPOINT_CenterCenter,
	ANCHORPOINT_CenterRight,
	ANCHORPOINT_BottomLeft,
	ANCHORPOINT_BottomCenter,
	ANCHORPOINT_BottomRight,
};

enum EStatisticUnitType
{
	SUT_NONE,
	SUT_HOUR,
	SUT_MINUTE,
	SUT_SECOND,
	SUT_RAID,
	SUT_TIME,
};

enum EMinimapTargetIcon
{
	TARGET_QUEST,
	TARGET_ME
};

// 월드맵 개선(#3326) - moonhj
enum EMinimapRegionType
{
	MRT_Castle,
	MRT_Fortress,
	MRT_Agit,
	MRT_HuntingZone_Base,
	MRT_Faction,
	MRT_HuntingZone_Mission,
	MRT_InstantZone,
	MRT_Raid,
	MRT_Etc,
};

enum EAttributeType
{
	ATTRIBUTE_FIRE,
	ATTRIBUTE_WATER,
	ATTRIBUTE_WIND,
	ATTRIBUTE_EARTH,
	ATTRIBUTE_HOLY,
	ATTRIBUTE_UNHOLY,
};

enum EMixMagicType
{
	MIXMAGICTYPE_DEFAULT,
	MIXMAGICTYPE_EARTHTOGGLE,
	MIXMAGICTYPE_WINDTOGGLE,
	MIXMAGICTYPE_WATERTOGGLE,
	MIXMAGICTYPE_FIRETOGGLE,
	MIXMAGICTYPE_HOLYTOGGLE,
	MIXMAGICTYPE_UNHOLYTOGGLE,
	MIXMAGICTYPE_APPLIEDSKILL,
	MIXMAGICTYPE_ALTERSKILL,
	MIXMAGICTYPE_ULTIMATEMAX,
};
/*
enum EUIStateType
{
	UISTATE_None,
	UISTATE_Debug,
	UISTATE_Login,
	UISTATE_CharacterSelect,
	UISTATE_Gaming,
	UISTATE_EulaMsg,
	UISTATE_ChinaWarnMsg,
	UISTATE_ServerList,
	UISTATE_WarnMsg,
	UISTATE_Loading,
	UISTATE_CharacterCreate,
	UISTATE_Credit,
	UISTATE_ReplaySelect,
	UISTATE_Replay,
	UISTATE_BenchMarkMenu,
	UISTATE_BenchMarkPlay,
	UISTATE_BenchMarkResult,
	UISTATE_ThaiHtmlWordWrap,
	UISTATE_OlympiadObserver,
	UISTATE_BroadcastUserObserver,
	UISTATE_SlideQuest,
	UISTATE_SpecialCamera,
	UISTATE_NpcZoomCamera
};
*/

const EV_UI_Internal_Event	= 5;		// UI script 내부에서 사용할 이벤트 번호.
const EV_Test	= 10;
const EV_Test_1	= 11;
const EV_Test_2	= 12;
const EV_Test_3	= 13;
const EV_Test_4	= 14;
const EV_Test_5	= 15;
const EV_Test_6	= 16;
const EV_Test_7	= 17;
const EV_Test_8	= 18;
const EV_Test_9 = 19;

// ui system event
const EV_Paste			= 20;

const EV_Restart		= 40;
const EV_Die			= 50;
const EV_CardKeyLogin	= 60;
const EV_RegenStatus	= 70;
const EV_RadarTransitionFinished	= 80;
const EV_ShortcutCommand	= 90;			// 스트링으로 커맨드를 실행한다.
const EV_ShortcutCommandSlot = 91;			// 번호로 단축키를 실행한다.
const EV_MagicSkillList	= 100;
const EV_SetRadarZoneCode	= 110;
const EV_RaidRecord	= 120;
const EV_ShowGuideWnd	= 130;
const EV_ShowScreenMessage	= 140;
const EV_ShowScreenNPCZoomMessage = 141;
const EV_GamingStateEnter	= 150;
const EV_GamingStateExit	= 160;
const EV_GamingStatePreExit	= 161; //branch EP1.0 2014-3-17 luciper3 - 160번 이벤트는 각UI의 본체가 Hide 된 후 발생하는데, 161번은 Hide전에 발생한다.
const EV_ServerAgeLimitChange	= 170;

const EV_UpdateUserInfo				= 180;
const EV_UpdateUserEquipSlotInfo	= 181; // uiPacket 이 ExUserinfo, ExUserInfoEquipSlot 등등으로 분리되면서 필요
const EV_PreUpdateUserInfo			= 182; // LevelChanged 등을 미리 계산해 놓기 위해 추가

const EV_UpdateHP		= 190;
const EV_UpdateMyHP		= 191;
const EV_UpdateMaxHP	= 200;
const EV_UpdateMyMaxHP	= 201;
const EV_UpdateMP		= 210;
const EV_UpdateMyMP		= 211;
const EV_UpdateMaxMP	= 220;
const EV_UpdateMyMaxMP	= 221;
const EV_UpdateCP		= 230;
const EV_UpdateMyCP		= 231;
const EV_UpdateMaxCP	= 240;
const EV_UpdateMyMaxCP	= 241;

const EV_UpdatePetInfo				= 250;
const EV_UpdateSummonInfo			= 251;
const EV_UpdateHennaInfo			= 260;
//const EV_InventoryItem			= 270;		//사용안함 2006.11.6 ttmayrin
const EV_ReceiveAttack				= 280;
const EV_ReceiveMagicSkillUse		= 290;
const EV_ReceiveTargetLevelDiff		= 300;
const EV_ShowReplayQuitDialogBox	= 310;

const EV_ClanInfo					= 320;
const EV_ClanInfoUpdate				= 330;
const EV_ClanMyAuth					= 340;
const EV_ClanAuthGradeList			= 350;
const EV_ClanCrestChange			= 360;
const EV_ClanAuth					= 370;
const EV_ClanAuthMember				= 380;
const EV_ClanSetAcademyMaster		= 390;	//todo : 지우자 - lpislhy
const EV_ClanAddMember				= 400;
const EV_ClanAddMemberMultiple		= 410;
const EV_ClanDeleteAllMember		= 420;
const EV_ClanMemberInfo				= 430;
const EV_ClanMemberInfoUpdate		= 440;
const EV_ClanDeleteMember			= 450;
const EV_ClanWarList				= 460;
const EV_ClanClearWarList			= 470;
const EV_ClanSubClanUpdated			= 480;
const EV_ClanSkillList				= 490;
const EV_ClanSkillListRenew			= 500;

const EV_MinFrameRateChanged		= 510;
const EV_PartyMemberChanged			= 520;
const EV_ShowPCCafeCouponUI			= 530;
const EV_ToggleShowPCCafeEventWnd	= 531;

const EV_ChatMessage				= 540;
const EV_ReceiveChatMessage			= 541;
const EV_GFxScrMessage				= 542;

const EV_ChatWndStatusChange		= 550;
const EV_ChatWndOnResize			= 555;
const EV_ChatWndSetString			= 560;
const EV_ChatWndSetFocus			= 570;
const EV_ChatWndMsnStatus			= 571;
const EV_ChatWndMacroCommand		= 572;
const EV_SystemMessage				= 580;
const EV_MessageWndString			= 581;

const EV_JoypadLButtonDown			= 590;
const EV_JoypadLButtonUp			= 600;
const EV_JoypadRButtonDown			= 610;
const EV_JoypadRButtonUp			= 620;

const EV_ShortcutUpdate				= 630;
const EV_ShortcutPageUpdate			= 640;
const EV_ShortcutClear				= 650;
const EV_ShortcutJoypad				= 660;
const EV_ShortcutPageDown			= 670;
const EV_ShortcutPageUp				= 680;
const EV_ShowShortcutWnd			= 690;
const EV_ShortcutInit				= 691;
const EV_ShortcutDataReceived		= 692;
const EV_ShortcutKeyAssignChanged	= 693;
const EV_QuestListStart				= 700;
const EV_QuestList					= 710;
const EV_QuestListEnd				= 720;
const EV_QuestSetCurrentID			= 730;
const EV_SSQStatus					= 740;
const EV_SSQMainEvent				= 750;
const EV_SSQSealStatus				= 760;
const EV_SSQPreInfo					= 770;
const EV_RecipeShowBuyListWnd		= 780;
const EV_RecipeShopSellItem			= 790;
const EV_RecipeShopItemInfo			= 800;
const EV_RecipeShowRecipeTreeWnd	= 810;
const EV_RecipeShowBookWnd			= 820;
const EV_RecipeAddBookItem			= 830;
const EV_RecipeItemMakeInfo			= 840;
const EV_RecipeShopShowWnd			= 850;
const EV_RecipeShopAddBookItem		= 860;
const EV_RecipeShopAddShopItem		= 870;
const EV_HeroShowList				= 880;
const EV_HeroRecord					= 890;
const EV_OlympiadTargetShow			= 900;
const EV_OlympiadMatchEnd			= 910;
const EV_OlympiadUserInfo			= 920;
const EV_OlympiadBuffShow			= 930;
const EV_OlympiadBuffInfo			= 940;
const EV_AbnormalStatusNormalItem	= 950;
const EV_AbnormalStatusEtcItem		= 960;
const EV_AbnormalStatusShortItem	= 970;
const EV_TargetUpdate				= 980;
const EV_TargetSkillInfo			= 981;
const EV_TargetSkillCancel			= 982;
const EV_TargetHideWindow			= 990;
const EV_ShowBuffIcon				= 1000;
const EV_PetWndShow					= 1010;
const EV_PetWndShowNameBtn			= 1020;
const EV_PetWndRegPetNameFailed		= 1030;
const EV_PetStatusShow				= 1040;
const EV_PetStatusSpelledList		= 1050;
const EV_PetStatusSpelledListDelete	= 1052;
const EV_PetStatusSpelledListInsert	= 1053;
const EV_PetInventoryItemStart		= 1060;
const EV_PetInventoryItemList		= 1070;
const EV_PetInventoryItemUpdate		= 1080;
const EV_SummonedWndShow			= 1090;
const EV_SummonedStatusShow			= 1100;
const EV_SummonedStatusSpelledList	= 1110;
const EV_SummonedStatusSpelledListDelete	= 1112;
const EV_SummonedStatusSpelledListInsert	= 1113;
const EV_SummonedStatusRemainTime	= 1120;
const EV_PetStatusClose				= 1130;
const EV_SummonedStatusClose		= 1131;
const EV_SummonedDelete				= 1132;
const EV_PartyAddParty				= 1140;
const EV_PartyUpdateParty			= 1150;
const EV_PartyDeleteParty			= 1160;
const EV_PartyDeleteAllParty		= 1170;
const EV_PartySpelledList			= 1180;
const EV_PartyRenameMember			= 1181;
const EV_PartySpelledListDelete		= 1182;
const EV_PartySpelledListInsert		= 1183;
const EV_ShowBBS					= 1190;
const EV_ShowBoardPacket			= 1200;
const EV_ShowHelp					= 1210;
const EV_LoadHelpHtml				= 1220;
const EV_LoadPetitionHtml			= 1221;
const EV_MacroShowListWnd			= 1230;
const EV_MacroUpdate				= 1240;
const EV_MacroList					= 1250;
const EV_MacroShowEditWnd			= 1260;
const EV_MacroDeleted				= 1270;
const EV_SkillListStart				= 1280;
const EV_SkillList					= 1290;
const EV_SkillListEnd				= 1291;
const EV_ActionListStart			= 1300;
const EV_ActionList					= 1310;
const EV_ActionListNew				= 1311;
const EV_ActionPetListStart			= 1320;
const EV_ActionPetList				= 1330;
const EV_ActionSummonedCommonListStart	= 1340;
const EV_ActionSummonedCommonList		= 1350;
const EV_ActionSummonedAllSkillListStart= 1351;
const EV_ActionSummonedAllSkillList		=1352;
const EV_CommandChannelStart		= 1360;
const EV_CommandChannelEnd			= 1370;
const EV_CommandChannelInfo			= 1380;
const EV_CommandChannelPartyList	= 1390;
const EV_CommandChannelPartyUpdate	= 1395;
const EV_CommandChannelRoutingType	= 1400;
const EV_CommandChannelPartyMember	= 1420;
const EV_RestartMenuShow			= 1430;
const EV_RestartMenuHide			= 1440;
const EV_SiegeInfo					= 1450;
const EV_SiegeInfoClanListStart		= 1460;
const EV_SiegeInfoClanList			= 1470;
const EV_SiegeInfoClanListEnd		= 1480;
const EV_SiegeInfoSelectableTime	= 1490;
const EV_IMEStatusChange			= 1500;
const EV_ArriveNewTutorialQuestion	= 1510; // deleted
const EV_ArriveTutorial				= 1511;
const EV_ArriveShowQuest			= 1520;
const EV_ArriveNewMail				= 1530;
const EV_PartyMatchStart			= 1540;
const EV_PartyMatchRoomStart		= 1550;
const EV_PartyMatchingRoomHistory	= 1551;
const EV_PartyMatchRoomClose		= 1560;
const EV_PartyMatchList				= 1570;
const EV_PartyMatchRoomMember		= 1580;
const EV_PartyMatchRoomMemberUpdate	= 1590;
const EV_PartyMatchChatMessage		= 1600;
const EV_PartyMatchWaitListStart	= 1610;
const EV_PartyMatchWaitList			= 1620;
const EV_PartyMatchCommand			= 1630;
const EV_HennaListWndShowHideEquip	= 1640;
const EV_HennaListWndAddHennaEquip	= 1650;
const EV_HennaInfoWndShowHideEquip	= 1660;
const EV_HennaInfoWndShowHidePremiumEquip	= 1661;//branch121212
const EV_HennaListWndShowHideUnEquip	= 1670;
const EV_HennaListWndClose				= 1671; //branch GD35_0828 2014-5-23 luciper3 - 서버에서 특정상황에 문양 목록창을 닫기위해 -1을 보내면 목록창을 닫는다.
const EV_HennaListWndAddHennaUnEquip	= 1680;
const EV_HennaInfoWndShowHideUnEquip	= 1690;
const EV_HennaInfoWndShowHidePremiumUnEquip	= 1691;//branch121212
const EV_CalculatorWndShowHide		= 1700;
const EV_DialogOK					= 1710;
const EV_DialogCancel				= 1720;

const EV_RadarAddTarget				= 1730;
const EV_RadarDeleteTarget			= 1740;
const EV_RadarDeleteAllTarget		= 1750;
const EV_RadarColor					= 1760;
const EV_ShowTownMap				= 1770;

const EV_ShowMinimap				= 1780;
const EV_MinimapAddTarget			= 1790;
const EV_MinimapDeleteTarget		= 1800;
const EV_MinimapDeleteAllTarget		= 1810;
const EV_MinimapShowQuest			= 1820;
const EV_MinimapHideQuest			= 1830;
const EV_MinimapChangeZone			= 1840;
const EV_MinimapCursedWeaponList	= 1850;
const EV_MinimapCursedWeaponLocation= 1860;
//const EV_MinimapCursedWeaponTooltipShow = 1861;
//const EV_MinimapCursedWeaponTooltipHide = 1862;
const EV_MinimapShowReduceBtn		= 1870;
const EV_MinimapHideReduceBtn		= 1880;
const EV_MinimapUpdateGameTime		= 1890;
const EV_MinimapShowMultilayer		= 1891;
const EV_MinimapCloseMultilayer		= 1892;
const EV_MinimapAdjustViewLocation	= 1893;

const EV_LanguageChanged			= 1900;
const EV_PCCafePointInfo			= 1910;
const EV_ShowPetitionWnd			= 1920;
const EV_ShowUserPetitionWnd		= 1921;
const EV_PetitionChatMessage		= 1930;
const EV_EnablePetitionFeedback		= 1940;
const EV_TradeStart					= 1950;
const EV_TradeAddItem				= 1960;
const EV_TradeDone					= 1970;
const EV_TradeOtherOK				= 1980;
const EV_TradeUpdateInventoryItem	= 1990;
const EV_TradeRequestStartExchange	= 2000;

const EV_SkillTrainListWndShow		= 2010;
const EV_SkillTrainListWndHide		= 2020;
const EV_SkillTrainListWndAddSkill	= 2030;
const EV_SkillTrainInfoWndShow		= 2040;
const EV_SkillTrainInfoWndHide		= 2050;
const EV_SkillTrainInfoWndAddExtendInfo	= 2051;
// 스킬 습득 변경 - lancelot 2010. 10. 23.
const EV_SkillLearningTabAddSkillBegin	= 2055;
const EV_SkillLearningTabAddSkillItem	= 2056;
const EV_SkillLearningTabAddSkillEnd	= 2057;
const EV_SkillLearningDetailInfo		= 2058;
const EV_SkillLearningNewArrival		= 2059;

const EV_SkillEnchantInfoWndShow			= 2064;
const EV_SkillEnchantInfoWndAddSkill		= 2065;
//const EV_SkillEnchantInfoWndHide			= 2066;
const EV_SkillEnchantInfoWndAddExtendInfo	= 2067;


const EV_SetMaxCount				= 2070;
const EV_ShopOpenWindow				= 2080;
const EV_OnEndTransactionList		= 2081;
const EV_ShopAddItem				= 2090;
const EV_WarehouseOpenWindow		= 2100;
const EV_WarehouseAddItem			= 2110;
const EV_WarehouseDeleteItem		= 2111;
const EV_PrivateShopOpenWindow		= 2120;
const EV_PrivateShopAddItem			= 2130;
const EV_SelectDeliverClear			= 2140;
const EV_SelectDeliverAddName		= 2150;
const EV_DeliverOpenWindow			= 2160;
const EV_DeliverAddItem				= 2170;
const EV_ShowEventMatchGMWnd		= 2180;
const EV_EventMatchCreated			= 2190;
const EV_EventMatchDestroyed		= 2200;
const EV_EventMatchManage			= 2210;
const EV_EventMatchPartyLeader		= 2211;
const EV_StartEventMatchObserver	= 2220;
const EV_EventMatchUpdateTeamName	= 2230;
const EV_EventMatchUpdateScore		= 2240;
const EV_EventMatchUpdateTeamInfo	= 2250;
const EV_EventMatchUpdateUserInfo	= 2260;
const EV_EventMatchGMMessage		= 2270;
const EV_ShowGMWnd					= 2280;
const EV_GMObservingUserInfoUpdate	= 2290;
const EV_GMObservingSkillListStart	= 2300;
const EV_GMObservingSkillList		= 2310;
const EV_GMObservingQuestListStart	= 2320;
const EV_GMObservingQuestList		= 2330;
const EV_GMObservingQuestListEnd	= 2340;
const EV_GMObservingQuestItem		= 2350;
const EV_GMObservingWarehouseItemListStart	= 2360;
const EV_GMObservingWarehouseItemList		= 2370;
const EV_GMObservingClan			= 2380;
const EV_GMObservingClanMemberStart	= 2390;
const EV_GMObservingClanMember		= 2400;
const EV_GMObservingInventoryAddItem= 2401;
const EV_GMObservingInventoryClear	= 2402;
const EV_GMAddHennaInfo				= 2403;
const EV_GMUpdateHennaInfo			= 2404;
const EV_GMAddPremiumHennaInfo		= 2405;//branch121212
const EV_GMSnoop					= 2410;
const EV_BeginShowZoneTitleWnd		= 2420;
const EV_TutorialViewerWndShow		= 2430;
const EV_TutorialViewerWndShowHtmlFile	= 2431;
const EV_TutorialViewerWndHide		= 2440;
const EV_ObserverWndShow			= 2450;
const EV_ObserverWndHide			= 2460;

// fishviewport
const EV_FishViewportWndShow		= 2470;
const EV_AutoFishStart				= 2471;
const EV_FishViewportWndHide		= 2480;
const EV_AutoFishEnd				= 2481;
//const EV_FishViewportWndInit		= 2490; // 쓰이는 곳이 없어 용도변경
const EV_AutoFishAvailable			= 2490;
const EV_FishRankEventButtonShow	= 2500;
const EV_FishRankEventButtonHide	= 2510;
const EV_FishViewportWndInitFishStatus	= 2520;
const EV_FishViewportWndSetFishStatus	= 2521;
const EV_FishViewportWndFinalAction		= 2522;

const EV_MultiSellInfoListBegin		= 2530;
const EV_NewMultiSellInfoListBegin	= 2531;
const EV_MultiSellResultItemInfo	= 2535;
const EV_NewMultiSellResultItemInfo	= 2536;
const EV_MultiSellOutputItemInfo	= 2540;
const EV_NewMultiSellOutputItemInfo = 2541;
const EV_MultiSellInputItemInfo		= 2550;
const EV_NewMultiSellInputItemInfo	= 2551;
const EV_MultiSellInfoListEnd		= 2560;
const EV_NewMultiSellInfoListEnd	= 2561;
const EV_MultiSellResult			= 2565;

const EV_InventoryClear				= 2570;
const EV_InventoryOpenWindow		= 2580;
const EV_InventoryHideWindow		= 2590;
const EV_InventoryAddItem			= 2600;
const EV_InventoryUpdateItem		= 2610;
const EV_InventoryItemListEnd		= 2620;
const EV_InventoryAddHennaInfo		= 2630;
const EV_InventoryToggleWindow		= 2631;
const EV_InventoryAddPremiumHennaInfo		= 2632; //branch121212
const EV_InventoryPremiumHennaInfoClear		= 2633; //branch121212

// manor
const EV_ManorCropSellWndShow				= 2640;
const EV_ManorCropSellWndAddItem			= 2645;
const EV_ManorCropSellWndSetCropSell		= 2646;
const EV_ManorCropSellChangeWndShow			= 2647;
const EV_ManorCropSellChangeWndAddItem		= 2648;
const EV_ManorCropSellChangeWndSetCropNameAndRewardType	= 2649;

const EV_ManorInfoWndSeedShow				= 2650;
const EV_ManorInfoWndSeedAdd				= 2651;
const EV_ManorInfoWndCropShow				= 2652;
const EV_ManorInfoWndCropAdd				= 2653;
const EV_ManorInfoWndDefaultShow			= 2654;
const EV_ManorInfoWndDefaultAdd				= 2655;

const EV_ManorSeedInfoSettingWndShow		= 2656;
const EV_ManorSeedInfoSettingWndAddItem		= 2657;
const EV_ManorSeedInfoSettingWndAddItemEnd	= 2658;
const EV_ManorSeedInfoSettingWndChangeValue	= 2659;
const EV_ManorSeedInfoChangeWndShow			= 2660;
const EV_ManorCropInfoSettingWndShow		= 2665;
const EV_ManorCropInfoSettingWndAddItem		= 2666;
const EV_ManorCropInfoSettingWndAddItemEnd	= 2667;
const EV_ManorCropInfoSettingWndChangeValue	= 2668;
const EV_ManorCropInfoChangeWndShow			= 2670;

const EV_ManorShopWndOpen					= 2680;
const EV_ManorShopWndAddItem				= 2690;

const EV_DuelAskStart						= 2700;
const EV_DuelReady							= 2710;
const EV_DuelStart							= 2720;
const EV_DuelEnd							= 2730;
const EV_DuelUpdateUserInfo					= 2740;
const EV_DuelEnemyRelation					= 2750;
const EV_ShowRefineryInteface				= 2760;
const EV_RefineryConfirmTargetItemResult	= 2770;
const EV_RefineryConfirmRefinerItemResult	= 2780;
const EV_RefineryConfirmGemStoneResult		= 2790;
const EV_RefineryRefineResult				= 2800;
const EV_ShowRefineryCancelInteface			= 2810;
const EV_RefineryConfirmCancelItemResult	= 2820;
const EV_RefineryRefineCancelResult			= 2830;

//QuestListWnd
const EV_QuestInfoStart		= 2840;
const EV_QuestInfo			= 2850;

//ItemEnchantWnd
const EV_EnchantShow		= 2860;
const EV_EnchantHide		= 2865;
// const EV_EnchantItemList	= 2880;
const EV_EnchantResult		= 2870;

// 아이템 인첸트 Ver2, ttmayrin
const EV_EnchantPutTargetItemResult			= 2880;
const EV_EnchantPutSupportItemResult		= 2881;
const EV_EnchantPutScrollItemResult			= 2882;
const EV_EnchantRemoveSupportItemResult		= 2883;

// AttributeEnchant
const EV_AttributeEnchantItemShow			= 2893;
const EV_AttributeEnchantItemList			= 2894;
const EV_AttributeEnchantResult				= 2895;
const EV_RemoveAttributeEnchantWndShow		= 2896;
const EV_RemoveAttributeEnchantItemData		= 2897;
const EV_RemoveAttributeEnchantResult		= 2898;

const EV_ResolutionChanged					= 2900;

//Tracker
const EV_TrackerAttach						= 2920;
const EV_TrackerDetach						= 2930;

//UIEditor
const EV_EditorSetProperty					= 2940;
const EV_EditorUpdateProperty				= 2950;

//Tooltip
const EV_RequestTooltipInfo					= 2960;

// PC, NPC 정보 보내줌 - lancelot 2007. 2. 14.
const EV_NotifyObject						= 2970;
const EV_NotifyPartyMemberPosition			= 2971;

// Builder Minimap Travel Event - neverdie 2007. 3. 14.
const EV_MinimapTravel						= 2980;

const EV_MinimapRegionInfoBtnClick			= 2990;

const EV_TextLinkLButtonClick				= 3000;
const EV_TextLinkRButtonClick				= 3010;

// lobby
const EV_LobbyMenuButtonEnable				= 3020;
const EV_LobbyAddCharacterName				= 3021;
const EV_LobbyCharacterSelect				= 3022;
const EV_LobbyClearCharacterName			= 3023;
const EV_LobbyStartButtonClick				= 3024;
const EV_LobbyShowDialog					= 3025;
const EV_LobbyGetSelectedCharacterIndex		= 3026;
const EV_LobbyCharacterReceivingFinished	= 3027;
//branch
// 듀얼요금제 - F2P 시스템 활성 캐릭터 수 제한 - gorillazin 11.09.20.
const EV_LobbyShowPremiumLevelInfo			= 3028;
const EV_LobbyShowDormantUserCouponWnd		= 3029;
//end of branch

//#ifdef USE_DSHOW
// solasys-동영상
//const EV_ShowMoviePlayer					= 3030;
//const EV_EndMoviePlayer					= 3040;
//#endif
const EV_ITEM_AUCTION_INFO					= 3050;
const EV_ITEM_AUCTION_NEXT_INFO				= 3051;
const EV_ITEM_AUCTION_NEXT_NOTEXIST			= 3052;
const EV_ITEM_AUCTION_UPDATED_BIDDING_INFO	= 3053;

// Mouse Over,Out
const EV_MouseOver							= 3060;
const EV_MouseOut							= 3070;

const EV_ShowWindow							= 3080;		// EV_ShowWindow Name="WindowName"

//#ifdef USE_DSHOW
// solasys-동영상
//const EV_ResizeMoviePlayer				= 3090;
//const EV_FullScreenMoviePlayer			= 3100;
//#endif
//MultiSummon by elsacred
//for pet window, ttmayrin
const EV_PartyPetAdd						= 3110;
const EV_PartyPetUpdate						= 3120;
const EV_PartyPetDelete						= 3130;


const EV_PartySummonAdd						= 3131;
const EV_PartySummonUpdate					= 3132;
const EV_PartySummonDelete					= 3133;
//
// 영지정보관련
const EV_ShowCastleInfo						= 3140;
const EV_AddCastleInfo						= 3150;
const EV_ShowFortressInfo					= 3160;
const EV_AddFortressInfo					= 3170;
const EV_ShowAgitInfo						= 3180;
const EV_AddAgitInfo						= 3190;
const EV_ShowFortressSiegeInfo				= 3200;

const EV_ShowFortressMapInfo				= 3201;
const EV_FortressMapBarrackInfo				= 3202;

// Character Create
const EV_CharacterCreateSetClassDesc		= 3210;
const EV_CharacterCreateClearClassDesc		= 3220;
const EV_CharacterCreateClearSetupWnd		= 3230;
const EV_CharacterCreateClearWnd			= 3240;
const EV_CharacterCreateClearName			= 3250;
const EV_CharacterCreateEnableRotate		= 3260;

// NPC 대화창
const EV_NPCDialogWndShow					= 3270;
const EV_NPCDialogWndHide					= 3280;
const EV_NPCDialogWndLoadHtmlFromString		= 3290;

const EV_ItemDescWndShow					= 3300;
const EV_ItemDescWndLoadHtmlFromString		= 3310;
const EV_ItemDescWndSetWindowTitle			= 3320;
const EV_QuestIDWndLoadHtmlFromString		= 3321;
const EV_QuestHtmlWndLoadHtmlFromString		= 3322;
const EV_QuestHtmlWndShow					= 3323;
const EV_QuestHtmlWndHide					= 3324;

// XMas Seal
const EV_ToggleXMasSealWndShowHide			= 3330;
const EV_OpenDialogQuit						= 3340;
const EV_OpenDialogRestart					= 3350;

const EV_FinishRotate						= 3360;

// 지하 콜로세움 PVP
const EV_PVPMatchRecord						= 3370;
const EV_PVPMatchRecordEachUserInfo 		= 3380;
const EV_PVPMatchUserDie					= 3390;

const EV_ToggleDetailStatusWnd				= 3400;

const EV_StateChanged						= 3410;
const EV_NotifyBeforeStateChanged			= 3411;

//solasys-포그테스트
const EV_AirStateOn							= 3420;
const EV_AirStateOff						= 3430;

const EV_ShowChangeNicknameNColor			= 3440;
//Premium Service - UserBookMark .. by elsacred
const EV_BookMarkList						= 3450;
const EV_BookMarkShow						= 3451;
const EV_SetShowAllStateInfo				= 3452;

//Premium Service - PremiumItem .. by elsacred
const EV_PremiumItemAlarm					= 3460;
const EV_PremiumItemList					= 3461;

// 크라테큐브 - lancelot 2008. 6. 16.
const EV_CrataeCubeRecordBegin				= 3470;
const EV_CrataeCubeRecordItem				= 3480;
const EV_CrataeCubeRecordEnd				= 3490;
const EV_CrataeCubeRecordMyItem				= 3500;
const EV_CrataeCubeRecordRetire				= 3501;

// Reset Device - NeverDie
const EV_ResetDevice						= 3510;
const EV_ShowMiniGame1						= 3520;

// AirShip, ttmayrin
const EV_AirShipUpdate						= 3530;
const EV_AirShipState						= 3540;
const EV_AirShipAltitude					= 3541;
const EV_AirShipTeleportListStart			= 3542;
const EV_AirShipTeleportList				= 3543;

// AI-UI event
const EV_AITimer							= 3550;

const EV_BirthdayItemAlarm					= 3560;

// 영지전 - lancelot 2008. 8. 22.
const EV_ShowDominionWarJoinListStart		= 3570;
const EV_ShowDominionWarJoinListEnemyDominionInfo = 3571;
const EV_ShowDominionWarJoinListEnd			= 3572;

const EV_ResultJoinDominionWar				= 3580;
const EV_DominionInfoCnt					= 3590;
const EV_DominionInfo						= 3600;
const EV_DominionsOwnPos					= 3610;
const EV_DominionWarChannelSet				= 3620;
const EV_DominionWarStart					= 3630;
const EV_DominionWarEnd						= 3640;

// Cleft, ttmayrin
const EV_CleftListInfo						= 3690;
const EV_CleftListStart						= 3700;
const EV_CleftListAdd						= 3710;
const EV_CleftListRemove					= 3720;
const EV_CleftListClose						= 3730;
const EV_CleftStateTeam						= 3740;
const EV_CleftStatePlayer					= 3750;
const EV_CleftStateResult					= 3760;

// FlightTransform
const EV_FlightTransform					= 3800;
const EV_ReserveShortCut					= 3801;

// CharacterViewport
const EV_ChangeCharacterPawn				= 3810;

// Block 뒤집기, elsacred
const EV_BlockRemainTime					= 3820;
const EV_BlockListStart						= 3830;
const EV_BlockListAdd						= 3840;
const EV_BlockListRemove					= 3850;
const EV_BlockListClose						= 3860;
const EV_BlockListVote						= 3870;
const EV_BlockListTimeUpset					= 3880;
const EV_BlockStateTeam						= 3890;
const EV_BlockStatePlayer					= 3900;
const EV_BlockStateResult					= 3910;

// 연합매칭 - lancelot
const EV_MpccRoomInfo						= 4000;
const EV_ListMpccWaitingStart				= 4010;
const EV_ListMpccWaitingRoomInfo			= 4020;
const EV_ListMpccWaitingCount				= 4021;
const EV_DismissMpccRoom					= 4030;
const EV_ManageMpccRoomMember				= 4040;
const EV_MpccRoomMemberStart				= 4050;
const EV_MpccRoomMemberInfo					= 4060;
const EV_MpccRoomChatMessage				= 4070;
const EV_MpccPartyMasterList				= 4080;

// 활력 시스템 활력 포인트 - elsacred
const EV_VitalityPointInfo					= 4100;

//branch
// F2P 서비스 활력 개선 - gorillazin
const EV_VitalityEffectInfo					= 4110;
const EV_GMVitalityEffectInfo				= 4111; //branch121212
const EV_LoginVitalityEffectInfo			= 4120;
//end of branch

// 시드(Seed) 주기(Phase) 정보 - elsacred
const EV_ShowSeedMapInfo					= 4200;

// PawnViewer
const EV_PawnViewerWndAddItem				= 4300;
const EV_PawnViewerWndAddHairMeshName		= 4320;
const EV_PawnViewerWndAddFaceTextureName	= 4330;
const EV_PawnViewerWndUpdateHairAccCoord	= 4340;

const EV_PawnViewerWndClearAnimList			= 4350;
const EV_PawnViewerWndAddAnimName			= 4360;

const EV_MSViewerWndAddSkill				= 4400;
const EV_MSViewerWndShow					= 4410;
const EV_MSViewerWndDeleteAllSkill			= 4420;

const EV_MSProfilingResult					= 4430;
const EV_MSProfilingClear					= 4431;

// SceneEditor
const EV_SceneListUpdate					= 4500;
const EV_SceneDataUpdate					= 4510;
const EV_SceneDataSave						= 4520;
const EV_UpdateSceneTreeData				= 4530;
const EV_CurSceneIndexInit					= 4540;
const EV_SlideShow							= 4550;
const EV_ScenePlayStart						= 4560;
const EV_ScenePlay							= 4570;

//SkillEnchant Result
const EV_SkillEnchantResult					= 4600;

// 우편 시스템 - elsacred
const EV_Notice_Post_Arrived				= 4700;
const EV_StartReceivedPostList				= 4710;
const EV_AddReceivedPostList				= 4720;
const EV_EndReceivedPostList				= 4730;
const EV_MailCommisionValue					= 4731;
const EV_ReplyReceivedPostStart				= 4740;
const EV_ReplyReceivedPostAddItem			= 4741;
const EV_ReplyReceivedPostEnd				= 4742;
const EV_StartSentPostList					= 4750;
const EV_AddSentPostList					= 4760;
const EV_EndSentPostList					= 4770;
const EV_ReplySentPostStart					= 4780;
const EV_ReplySentPostAddItem				= 4781;
const EV_ReplySentPostEnd					= 4782;
const EV_PostWriteOpen						= 4790;
const EV_PostWriteAddItem					= 4791;
const EV_PostWriteEnd						= 4792;
const EV_DeleteReceivedPost					= 4793;
const EV_OpenStateReceivedPost				= 4794;
const EV_ReceivedStateReceivedPost			= 4795;
const EV_DeleteSentPost						= 4796;
const EV_OpenStateSentPost					= 4797;
const EV_ReceivedStateSentPost				= 4798;
const EV_ReplyWritePost						= 4799;

// 진정 개선 - jin 2009.03.31.
const EV_ShowNewUserPetitionWnd				= 4800;
const EV_AddNewUserPetitionCategoryStepOne	= 4810;
const EV_ShowNewUserPetitionDescription		= 4820;
const EV_AddNewUserPetitionCategoryStepTwo	= 4830;
const EV_ShowNewUserPetitionContents		= 4840;
const EV_ShowNewUserPetitionHtml			= 4850;

//
const EV_ShowPrivateMarketList				= 4860;
const EV_AddPrivateMarketList				= 4861;

//
const EV_UsePartyMatchAction				= 4870;

const EV_EffectViewerAddEffect				= 4880; //add Effectitem to EffectViwer
const EV_EffectViewerShow					= 4881;	//show EffectViwer

// couple action - lancelot 2009. 10. 14.
const EV_ShowAskCoupleActionDialog			= 4900;

// For PartyLootingModfication system - jdh84 2009.10.20
const EV_AskPartyLootingModify		= 4910; //파티루팅변경을 물어옴
const EV_PartyLootingHasModified	= 4911; //파티루팅이 변경됨
const EV_MembershipType				= 4912; //멤버쉽상태를 알려줌
											//      0: 무소속 1: 파티장 2: 파티원 3: 방장이면서 파티장 4: 방장
											//      5:방에 입장한 파티원 6: 파티에 소속되지 않고 방에만 입장한 유저)
const EV_PartyHasDismissed			= 4913; //파티가 해체되었다는 메시지. 모든 파티원들에게
const EV_BecamePartyMember			= 4914; //파티의 멤버가됨
const EV_BecamePartyMaster			= 4915; //파티장이됨
const EV_OustPartyMember			= 4916; //파티에서 추방당함
const EV_WithdrawParty				= 4917; //파티에서 탈퇴함
const EV_HandOverPartyMaster        = 4918; //파티장을 양도함
const EV_RecvPartyMaster			= 4919; //파티장을 양도받음

//동맹문장등록 
const EV_CommandAddAllianceCrestFile	= 4920;

//branch - 아래에 지정되어 있다.
// For halloween event - lancelot 2009. 10. 7
//const EV_BR_EventHalloweenHelp	= 9100;
//const EV_BR_EventHalloweenShow	= 9101;
//const EV_BR_EventRankerNowList	= 9102;
//const EV_BR_EventRankerLastList	= 9103;
//end of branch

// For expand quest alarm - by jin
const EV_ExpandQuestAlarmKillMonster		= 4930;
const EV_ExpandQuestAlarmKillMonsterStart	= 4931;
const EV_ExpandQuestAlarmKillMonsterEnd		= 4932;

// For new vote system = by jin
const EV_ReceiveNewVoteSystemInfo	= 4940;
const EV_ShowNewVoteSystemHelp		= 4941;

// For Controling PostEffect - by elsacred 2010.01.13
const EV_PostEffectShow				= 4950;

//URL Link has clicked - jdh84 
const EV_UrlLinkClick				= 4960;


const EV_ReceiveFriendList			= 4970;	// 친구 목록 보내주는 event
const EV_ConfirmAddingPostFriend	= 4980; // 추가 친구 추가 성공 여부 알려주는 event
const EV_ReceivePostFriendList		= 4990;	// 추가 친구 목록 보내주는 event
const EV_ReceivePledgeMemberList	= 5000; // 혈맹원 목록 보내주는 event
//#ifdef L2_WEATHER_SYSTEM
const EV_ShowWeatherWnd				= 5010;
//#endif

const EV_ReplayRecStarted			= 5020;
const EV_ReplayRecEnded				= 5021;

const EV_EnterOlympiadObserverMode	= 5030;

const EV_ListCtrlLoseSelected		= 5040; //리스트컨트롤이 셀렉트를 취소할때 가는 이벤트

// For Controling HDR render - by sori
const EV_HDRRenderTestWndShow		= 5050;

const EV_SkillCancel				= 5060;
const EV_NatureRenderShow			= 5070;
const EV_ReceiveOlympiadGameList	= 5080;
const EV_ReceiveOlympiadResult		= 5081;

const EV_SetEnterChatting			= 5090;
const EV_UnSetEnterChatting			= 5091;

// 네비트 강림 관련 - 2010.7.7. winkey
const EV_NavitAdventPointInfo		= 5100; 
const EV_NavitAdventEffect			= 5110;
const EV_NavitAdventTimeChange		= 5120;

const EV_TargetSpelledList			= 5120;
const EV_TargetStatusWndShow		= 5121;
const EV_TargetStatusWndHide		= 5122;

const EV_ActivateAlterSkill			= 5130;
const EV_InactivateAlterSkill		= 5131;
const EV_UseActiveAlterSkill		= 5132;

//결정화시스템 관련
const EV_CrystalizingEstimationList		= 5140; //결정화 견적
const EV_CrystalizingEstimationListEnd	= 5141; //결정화 견적 종료
const EV_CrystalizingFail				= 5142; //결정화 실패

const EV_UpdateUltimateSkillPoint	= 5150;
const EV_RegisterUltimateSkill		= 5151;

const EV_ShowSheathingWnd			= 5160;
const EV_SheathingInfo				= 5170;

const EV_RequestStartPledgeWar		= 5180;
const EV_RequestStopPledgeWar		= 5181; // PledgeV2

const EV_JumpWayPointUpdate			= 5190;
const EV_JumpWayPointHide			= 5200;

const EV_CampaignArrived			= 5210;
const EV_ZoneQuestArrived			= 5220;
const EV_CampaignProgressInfo		= 5230;
const EV_ZoneQuestProgressInfo		= 5240;
const EV_CampaignFinish				= 5250;
const EV_ZoneQuestFinish			= 5260;
const EV_CampaignRewardStart		= 5270;
const EV_ZoneQuestRewardStart		= 5280;
const EV_CampaignRewardFinish		= 5290;
const EV_ZoneQuestRewardFinish		= 5300;
const EV_CampaignResult				= 5301;
const EV_ZoneQuestResult			= 5302;

const EV_MinimapShowCampaign		= 5303;
const EV_MinimapHideCampaign		= 5304;

//듀얼 클래스 및 서브 클래스 리스트
const EV_NotifySubjob				= 5310;
const EV_CreatedSubjob				= 5311;
const EV_ChangedSubjob				= 5312;

const EV_HeadDisplayUpdate			= 5320;
const EV_OwnSkillHasLaunched		= 5330;
const EV_OwnSkillHasCanceled		= 5340;

//지스타용 임시 이벤트
const EV_GStarObtainSkill			= 5350;
const EV_GstarShowMissionGuide		= 5351;
const EV_GstarPlayFlashMovie		= 5352;
const EV_GstarUIInit				= 5353;
const EV_GstarCloseSkill			= 5354;
const EV_GstarZoneChange			= 5355;
const EV_GstarSceneStateEnter		= 5356;
const EV_GstarCommandLineIcon		= 5357;
const EV_GstarGameEnd				= 5358;
const EV_GstarNotifyMonsterCount	= 5359;

//사용할 수 없는 스킬 비활성화
const EV_ApplySkillAvailability					= 5360;

//데미지 텍스트
const EV_DamageTextCreate	= 5370;
const EV_DamageTextUpdate	= 5371;

// 튜토리얼퀘스트의 미니맵 노출 기능(사용안함)
const EV_NotifyTutorialQuest	= 5380;
const EV_ClearTutorialQuest		= 5381;

//인맥관리
const EV_FriendInfoListEmpty	= 5390;
const EV_FriendAdded			= 5391;
const EV_FriendRemoved			= 5392;
const EV_FriendInfoUpdate		= 5393;
const EV_FriendDetailInfoUpdate	= 5394;

const EV_BlockInfoListEmpty		= 5400;
const EV_BlockAdded				= 5401;
const EV_BlockRemoved			= 5402;
const EV_BlockInfoUpdate		= 5403;
const EV_BlockDetailInfoUpdate	= 5404;

const EV_InzonePartyHistoryUpdate	= 5410;
const EV_ShowPersonalConnectionWnd	= 5411;

//동영상캡쳐
const EV_MovieCaptureStarted		= 5420;
const EV_MovieCaptureEnded			= 5430;
const EV_MovieCaptureFailDiskSpace	= 5440;

// 24hz컨트롤러 Update
const EV_24HzControllerInfo				= 5460;
const EV_24HzDisconnected				= 5461;
const EV_24HzAlreadyConnected			= 5462;
const EV_24HzFileCorrupted				= 5463;
const EV_24HzWebCertificationNotRespond	= 5464;
const EV_24HzOnOff						= 5465;

const EV_CallToChangeClass		= 5470;
const EV_ChangeToAwakenedClass	= 5480;

// 아이템 위탁판매 - lancelot 2010. 10. 12.
const EV_ItemCommissionWndShow = 5490;
const EV_ItemCommissionWndRegistrableItemCnt		= 5492;
const EV_ItemCommissionWndRegistrableItemList		= 5495;
const EV_ItemCommissionWndResponseInfo				= 5500;
const EV_ItemCommissionWndListStart					= 5510;
const EV_ItemCommissionWndEachItem					= 5520;
const EV_ItemCommissionWndListEnd					= 5530;
const EV_ItemCommissionWndSearchFail				= 5535;
const EV_ItemCommissionWndBuyInfo					= 5540;
const EV_ItemCommissionWndBuyResult					= 5550;
const EV_ItemCommissionWndDeleteResult				= 5560;
const EV_ItemCommissionWndRegisterResult			= 5570;
const EV_ItemCommissionWndCloseCauseOfLongDistance	= 5571;
//branch
// 듀얼요금제 - 판매대행 등록 제한 - gorillzin 12.08.30.
const EV_ItemCommissionRegisterWndCloseCauseOfFreeUser = 5572;
//end of branch
//branch110706
const EV_ItemCommissionWndSellingPremiumItemRegisterReset = 5498;
const EV_ItemCommissionWndSellingPremiumItemRegister = 5499;
//end of branch

// 플래시 디버그 메시지
const EV_FlashDebugMsg				 = 5580;

const EV_StatisticWndShow			 = 5590;
const EV_StatisticHotLinkWndShow	 = 5591;
const EV_StatisticNameInfo			 = 5592;
const EV_StatisticAllNameInfo		 = 5593;
const EV_StatisticWorldRecord		 = 5594;
const EV_StatisticUserRecord		 = 5595;


// NEW_GOODS_INVENTORY : 상품 인벤토리 - 2010.11.3 winkey
const EV_ShowGoodsInventoryWnd		= 5600;
const EV_GoodsInventoryItemList		= 5601;
const EV_GoodsInventoryItemDesc		= 5602;
const EV_GoodsInventoryNoti			= 5603;
const EV_GoodsInventoryResult		= 5604;

// SECONDARY_AUTH : 2차 비밀번호 - 2010.11.6 winkey
const EV_SecondaryAuthCreate		= 5610;
const EV_SecondaryAuthVerify		= 5611;
const EV_SecondaryAuthBlocked		= 5612;
const EV_SecondaryAuthSuccess		= 5613;
const EV_SecondaryAuthCreateFail	= 5614;
const EV_SecondaryAuthVerifyFail	= 5615;
const EV_SecondaryAuthFailEtc		= 5616;

// 캐릭터명 중복 검사
const EV_CharacterNameCreatable		= 5618;

const EV_ShowSceneClipView			= 5620;
const EV_DeleteSceneClipView		= 5621;
const EV_ShowUsm					= 5622; //서버로부터 요청이 옴i
const EV_ShowFullSceneClipView      = 5623; //풀스크린 동영상
const EV_DeleteFullSceneClipView    = 5624; //풀스크린 동영상 종료

//GD 1.0 로그인 UI 개선 
const EV_LoginBegin					= 5630;
const EV_LoginFail					= 5640;
const EV_LoginFailFlash				= 5641;
const EV_LoginOK					= 5650;
//branch EP2.5 2015.10.26 luciper3 - 대기열 로그인 기능 추가
const EV_LoginQueueTicket			= 5651;
//end of branch
const EV_LoginWait					= 5660;
const EV_LoginTelephoneWait			= 5661;
const EV_LoginSecurityCard			= 5670;
const EV_LoginGoogleOtp				= 5671;
const EV_ShowEula					= 5680;
const EV_ShowChinaEula				= 5681;
const EV_ServerListStart			= 5690;
const EV_ServerList					= 5691;
const EV_ServerListEnd				= 5692;
const EV_LoginUIGetFocus			= 5700;

const EV_CreditXMLString			= 5710;

const EV_OptionHasApplied			= 5720; 

// 속성 변경 시스템
const EV_ChangeAttribute_CandidateListClear	= 5730;
const EV_ChangeAttribute_CandidateItem		= 5731;
const EV_ChangeAttribute_ItemDetail			= 5732;
const EV_ChangeAttribute_ItemResult			= 5733;

// web browser 관련 event
const EV_WebBrowser_ShowFileRegisterWnd = 5740;
const EV_WebBrowser_FinishedLoading		= 5750;
const EV_WebBrowser_ReceivedTitle		= 5751;	// 웹 페이지를 열때 타이틀에 설정된 정보가 넘어온다.
	// WindowName
    // Title - 웹페이지를 열었을때 넘어오는 타이틀 (<title>리니지2 홈</title>)
const EV_WebBrowser_NoticeOpenStatus	= 5752;

// Mentor - lancelot 2011. 7. 12.
const EV_ConfirmMentee				= 5800;
const EV_MentorMenteeListStart		= 5810;
const EV_MentorMenteeListInfo		= 5820;

// 멘티 대기자
const EV_MenteeWaitingListStart     = 5830;
const EV_MenteeWaitingList			= 5840;
const EV_MenteeWaitingListEnd       = 5850;

const EV_InzoneWaitingInfo			= 5860;

// GFx OptionWnd 이벤트
const EV_OptionWndShow				= 5870;			// OptionWnd를 Show 하는 이벤트(서버와 화
const EV_SetFullScreenCheck			= 5871;			// FullScreen 토글시 CheckBox 변경 이벤트

const EV_EventAttendanceInfo		= 6000;

// 업적 - ithing
const EV_HonorListStart				= 6010;
const EV_HonorListAdd				= 6020;
const EV_HonorListEnd				= 6030;
const EV_HonorAttainment			= 6040;
const EV_HonorAccomplish			= 6050;

const EV_ExtraWorldChattingCnt		= 6110;

//레이더맵 개선 - jylee
const EV_UpdateQuestMarkRadarMap	= 6120;
const EV_UpdateTargetSelectedRadarMap = 6130;

// ini 서버저장 - ithing
const EV_ReceiveWindowsInfo			= 6200;
const EV_ReceiveChatFilter			= 6210;
const EV_ReceiveOption				= 6220;




//for classic server - innocentree
const EV_NeedResetUIData = 8000;

// 아레나
//#ifdef ARENA

// 그룹
const EV_MatchGroup					= 8200;
const EV_MatchGroupAsk				= 8210;
const EV_MatchGroupWithdraw			= 8220;
const EV_MatchGroupOust				= 8230;

// 매칭
const EV_RequestMatchArena			= 8300;
const EV_CompleteMatchArena			= 8310;
const EV_ConfirmMatchArena			= 8320;
const EV_CancelMatchArena			= 8330;

// 클래스선택
const EV_StartChooseClassArena		= 8340;
const EV_ChangeClassArena			= 8350;
const EV_ConfirmClassArena			= 8360;

// 시작
const EV_StartBattleReadyArena		= 8370;
const EV_BattleReadyArena			= 8380;

// 종료
const EV_BattleResultArena			= 8400;
const EV_BattleResultArenaReward	= 8401;
const EV_BattleResultArenaStat		= 8402;
const EV_ExitArena					= 8410;
const EV_ClosingArena				= 8420;
const EV_ClosedArena				= 8430;

// 상황판, 전광판
const EV_ArenaDashboard				= 8500;
const EV_ArenaUpdateEquipSlot		= 8510;
const EV_ArenaKillInfo				= 8520;

// 핑
const EV_ArenaCustomNotification	= 8600;
const EV_ArenaShowEnemyParty		= 8610;

// 랭킹
const EV_ArenaRankAll				= 8650;
const EV_ArenaMyRank				= 8660;

// 아레나 튜토리얼
const EV_HtmlWithNPCViewport		= 8700;
const EV_HtmlWithNPCViewportClose	= 8701;

// 아레나 이벤트 9000번까지 예약해놓을께요
const EV_ArenaEnd					= 9000;

//#endif


////////////////////////////////////////////////////////////////////////////
//branch !! Edited by Overseas Branch : Enyheid

const EV_BR_CashShopToggleWindow	= 9010;
const EV_BR_CashShopCateroyAdd		= 9011;
const EV_BR_CashShopCateroyTabRemove= 9012;

const EV_BR_RecentProductListEnd	= 9013;			//branch120516
const EV_BR_BasketProductListEnd	= 9014;			//branch120516
const EV_BR_CashShopNewIconAnim		= 9015;			//branch120516
const EV_BR_CashShopCateroyTabClear	= 9016;	//branch120703

const EV_BR_CashShopAddItem			= 9020;
const EV_BR_SetNewList				= 9021;
const EV_BR_ProductListEnd			= 9022;
const EV_BR_CashShopAddProductItem	= 9023;			//branch120516
const EV_BR_SetRecentProduct		= 9025;
const EV_BR_SetBasketProduct		= 9026;			//branch120516
const EV_BR_AddRecentProductItem	= 9027;			//branch120516
const EV_BR_AddBasketProductItem	= 9028;			//branch120516
const EV_BR_SetNewProductInfo		= 9030;
const EV_BR_SetPresentNewProductInfo		= 9031; //branch120516
const EV_BR_AddMyShopBasketProductItem		= 9032;	//branch120516
const EV_BR_DeleteMyShopBasketProductItem	= 9033;	//branch120516
const EV_BR_DeleteCashShopBasketProductItem	= 9034;	//branch120516
const EV_BR_DeleteAllBasketProductItem		= 9035;	//branch120516
const EV_BR_AddEachProductInfo				= 9040;
const EV_BR_AddPresentEachProductInfo		= 9041;	//branch120516
const EV_BR_SETGAMEPOINT			= 9050;
const EV_BR_SETEVENTCOIN			= 9051;
const EV_BR_RESULT_BUY_PRODUCT		= 9060;
const EV_BR_SHOW_CONFIRM			= 9070;
const EV_BR_HIDE_CONFIRM			= 9071;
//branch 110824
const EV_BR_PRESENT_SHOW_CONFIRM	= 9072;
const EV_BR_PRESENT_HIDE_CONFIRM	= 9073;
const EV_BR_RESULT_PRESENT_BUY_PRODUCT = 9061;
//end of branch
const EV_BR_PREMIUM_STATE			= 9080;
const EV_BR_FireEventStateInfo		= 9090;
const EV_BR_FireEventTimeInfo		= 9091;

// For halloween event - lancelot 2009. 10. 7
const EV_BR_EventHalloweenHelp		= 9100;
const EV_BR_EventHalloweenShow		= 9101;
const EV_BR_EventRankerNowList		= 9102;
const EV_BR_EventRankerLastList		= 9103;
const EV_BR_EventChristmasShow		= 9110;
const EV_BR_EventCommonHtml1		= 9111;
const EV_BR_EventCommonHtml2		= 9112;
const EV_BR_EventCommonHtml3		= 9113;
const EV_BR_MinigameMyRanking		= 9120;
const EV_BR_MinigameAllRanking		= 9121;
const EV_BR_EventValentineShow		= 9130;
const EV_BR_Die_EnableNPC			= 9140;

// TTP #42287 NPC 자가 부활 아이템 버튼을 Disable 해야 할 때도 있습니다. - gorillazin 10.10.15.
const EV_BR_RestartByNPCButtonEnable = 9150;

//by elsacred
const EV_CurrentAutoSubstituteStatus	= 9160;	// 현재 SUBSTITUTE 상태를 반환해줌 //찾아라,취소해라..
const EV_WaitWaitingSubstitute			= 9170;	// 파티를 찾고 있다라는 상태를 보여줌
const EV_CancelWaitingSubstitute		= 9175;	// 파티를 차고 있다라는 상태를 해제함
const EV_RegistWaitingSubstituteOk		= 9180;	// 사냥터 파티에 합류하시겠습니까?
const EV_RegistPartySubstitute			= 9190;	// 파장의 대타 신청 성공유무
const EV_DeletePartySubstitute			= 9200; // 파장의 대타 취소 신청 성공유무
const EV_TimeOverPartySubstitute		= 9210;	// 타임오버
const EV_ExchangeSubstitute				= 9211;	// Party Member를 바꾸시겠습니까?
const EV_StartCountDownSubstitute		= 9212;	// 바뀌기에 5초 남았다.
const EV_TurnOnSubstituteTimer			= 9213;	// 모레시계 타이머 켜세요.
const EV_TurnOffSubstituteTimer			= 9214;	// 모레시계 타이머 끄세요.
//const EV

const EV_NotifyImportedCrestImage	= 9220;

const EV_FlyMoveText				= 9230;		// param: string. if the string is empty, hide text.
const EV_NotifyFlyMoveStart			= 9231;

const EV_BeastTestShow				= 9240;
const EV_EnvTestShow				= 9250;

//branch 110824
//ItemLookChangeWnd
const EV_ItemLookChangeShow					= 9260;
const EV_ItemLookChangeHide					= 9270;
const EV_ItemLookChangeResult				= 9280;
const EV_ItemLookChangePutTargetItemResult	= 9290;
const EV_ItemLookChangePutSupportItemResult	= 9300;
//end of branch

//end of branch !! Edited by Overseas Branch : Enyheid
////////////////////////////////////////////////////////////////////////////

const EV_CuriousHouseWaitState			= 9310;  
const EV_CuriousHouseEnter				= 9320;
const EV_CuriousHouseLeave				= 9330;
const EV_CuriousHouseMemberListStart	= 9340;
const EV_CuriousHouseMemberList			= 9341;
const EV_CuriousHouseMemberListEnd		= 9342;
const EV_CuriousHouseMemberUpdate		= 9350;
const EV_CuriousHouseRemainTime			= 9360;
const EV_CuriousHouseResultIsVictory	= 9370;
const EV_CuriousHouseResultListStart	= 9380;
const EV_CuriousHouseResultList			= 9381;
const EV_CuriousHouseResultListEnd		= 9382;
const EV_CuriousHouseObserveListStart	= 9390;
const EV_CuriousHouseObserveList		= 9391;
const EV_CuriousHouseObserveListEnd		= 9392;
const EV_CuriousHouseObserveModeON		= 9400;
const EV_CuriousHouseObserveModeOFF		= 9401;

//jylee, hairshop event
const EV_UpdateHaircolorData = 9410;

//jylee, 혈맹 조합 활동
const EV_ReceivePledgeUnionStateInfo	= 9420;
const EV_ReceiveUnionPoint				= 9421;
const EV_ReceivePledgeUnionOpenNPC		= 9422;
const EV_RequestOpenClanUnionInfoWnd	= 9425;
const EV_SendIsActiveUnionInfoBtn		= 9426;
const EV_SendRequestResult				= 9427;

//sunrice, 칼리에의 축복 이벤트
const EV_EventKalieState				= 9430;
const EV_EventKalieJackpotUser			= 9431;
const EV_EventKalieDisable				= 9432;
// 발터스의 보급품 이벤트
const EV_EventBalthusState				= 9433;
const EV_EventBalthusJackpotUser		= 9434;
const EV_EventBalthusDisable			= 9435;

//jylee, 뷰티샵
const EV_HairAccessoryPriority			= 9439;
const EV_OpenBeautyshopWindow			= 9440;
const EV_ReceiveBeautyItemList			= 9441;
const EV_OpenBeautyshopResetWindow		= 9442;
const EV_SendUserAdenaAndCoin			= 9443;
const EV_IsSuccessBuyingStyle			= 9444;
const EV_CurrentUserStyle				= 9445;
const EV_OldUserStyle					= 9446;
const EV_EndSocialAction				= 9447;
const EV_ExitBeautyshop					= 9448;
const EV_PurchaseItemList				= 9449;

//sori, 웹 진정 서비스
const EV_ShowWebPetitionMainPage		= 9450;
const EV_ShowWebPetitionListPage		= 9451;
const EV_WebPetitionReplyAlarm			= 9452;

//branch120516 이벤트켐페인
const EV_BR_Event_CampaignArrived		= 9500;
const EV_BR_Event_CampaignProgressInfo	= 9510;
const EV_BR_Event_CampaignFinish		= 9520;
const EV_BR_Event_CampaignResult		= 9530;
//end of branch

//jylee, 단일 메시 존 입장 / 퇴장 시 이벤트
const EV_EnterSingleMeshZone			= 9540;
const EV_ExitSingleMeshZone				= 9541;


const EV_UnReadMailCount				= 9550;
const EV_PledgeCount					= 9560;
const EV_AdenaInvenCount				= 9570;

//sunrice, 혈맹 가입 시스템
const EV_PledgeRecruitBoardStart		= 9580;
const EV_PledgeRecruitBoardItem			= 9581;
const EV_PledgeRecruitInfo				= 9582;
const EV_PledgeRecruitInfoItem			= 9583;
const EV_PledgeRecruitBoardDetail		= 9590;
const EV_PledgeWaitingListApplied		= 9591;
const EV_PledgeWaitingListStart			= 9600;
const EV_PledgeWaitingListItem			= 9601;
const EV_PledgeWaitingUser				= 9610;
const EV_PledgeDraftListStart			= 9620;
const EV_PledgeDraftListItem			= 9621;
const EV_PledgeWaitingListAlarm			= 9630;
const EV_PledgeSigninForOpenJoiningMethod = 9631;	// 공개형 혈맹 가입에 따른 응답
const EV_PledgeRecruitApplyInfo			= 9640;

// 소원이 내리는 나무 이벤트
const EV_ShowEventChristmasWnd			= 9650;

// 카드이벤트..2013.2
const EV_CardRewardStart			= 9660;
const EV_CardListProperty			= 9670;
const EV_CardProperty				= 9680;
//branch GD35_0828 2013-11-15 luciper3 - 10주년 이벤트 배너 토글
const EV_BR_10thAnniBannerShow		= 9681;
//end of branch

// 레이드 정산 시스템
const EV_DivideAdenaStart			= 9690;
const EV_DivideAdenaCancel			= 9700;
const EV_DivideAdenaDone			= 9710;

// 어빌리티 시스템
const EV_AbilityListStart			= 9720;
const EV_AbilityListItem			= 9721;
const EV_AbilityWndShow				= 9730;
const EV_AbilityWndClose			= 9731;

const EV_CharacterDeleteFail		= 9740;

const EV_GameStart					= 9750;

//------------------------------------------
// JEWEL 추가 - by y2jinc (2013. 9. 3) - 합성 이라 부르게 됨.
	// 첫번째 인첸트 대상 아이템 올리기 성공	
const EV_NewEnchantPushOneOK		= 9760;	
	// 첫번째 인첸트 대상 아이템 올리기 실패	
const EV_NewEnchantPushOneFail		= 9770;
	// 두번째 인첸트 대상 아이템 올리기 성공
const EV_NewEnchantPushTwoOK		= 9780;
	// 두번째 인첸트 대상 아이템 올리기 실패
const EV_NewEnchantPushTwoFail		= 9790;
	// 첫번째 인첸트 대상 아이템 내리기 성공
const EV_NewEnchantRemoveOneOK		= 9800;
	// 첫번째 인첸트 대상 아이템 내리기 실패
const EV_NewEnchantRemoveOneFail	= 9810;
	// 두번째 인첸트 대상 아이템 내리기 성공
const EV_NewEnchantRemoveTwoOK		= 9820;
	// 두번째 인첸트 대상 아이템 내리기 실패
const EV_NewEnchantRemoveTwoFail	= 9830;
	// 인첸트 시도 성공
	//  - ItemClassID : 성공한 Item Class ID
const EV_NewEnchantTrySuccess		= 9840;
	// 인첸트 시도 실패
	//  - ItemClassID : 성공한 Item Class ID ( 0이 온 경우엔 비정상 실패이기때문에 창을 닫아줘야함. )
const EV_NewEnchantTryFail			= 9850;
	// 인첸트 계속하기 시도 성공
const EV_NewEnchantRetryPutItemsOK	= 9851;
	// 인첸트 계속하기 시도 실패
const EV_NewEnchantRetryPutItemsFail = 9852;
//------------------------------------------

const EV_ContextMenu				= 9860;

//------------------------------------------
// 연금술 작업 - y2jinc (2013. 9. 26)
// @참고 : http://lineage2:8080/wiki/연금술작업
const EV_AlchemySkillList			= 9870;
const EV_AlchemySkillListForXML		= 9873;
const EV_AlchemyMixCubeInfo			= 9875;
const EV_AlchemyTryMixCube			= 9880;
const EV_AlchemyConversion			= 9890;	
const EV_AlchemySkillInfoFromScript	= 9900;
const EV_AlchemyPushItemOnMixCube	= 9910;
const EV_AlchemyAdditionPushItemOnMixCube = 9920;
//------------------------------------------


//GFXDebug
const EV_GFXDEBUG_EVENT				= 9990;
const EV_GFXDEBUG_CALL				= 9991;
const EV_GFXDEBUG_RETURN			= 9992;
const EV_GFXDEBUG_RUNTIME_ERROR		= 9993;
const EV_GFXDEBUG_INVOKE_ERROR		= 9994;


//branch120703
const EV_BR_EventFastivalInkMax 	= 10000;	//잉크이벤트
const EV_BR_EventFastivalInkEnergy 	= 10001; 	//잉크이벤트


//branch 121212 미국 path 웹
const EV_ShowWebPathMainPage		= 10010;
const EV_ShowWebPathListPage		= 10011;
const EV_ShowWebPathAlarm			= 10012;

//branch121212 럭키게임
const EV_ShowLuckyGame				= 10021;
const EV_LuckyGameStart				= 10022;
const EV_LuckyGameResult			= 10023;

//branch121212 왕립훈련소
const EV_ShowTrainingRoom			= 10030;
const EV_TrainingRoomStart			= 10031;
const EV_TrainingRoomStutus			= 10032;
const EV_TrainingRoomEnd			= 10033;
const EV_TrainingRoomStart_SecondInfo = 10034;  //branch GD35_0828 2014-6-2 luciper3 - 훈련소 초단위까지 맞추기위해..

//branch121212
const EV_PathToAwakeningAlarm		= 10040;
const EV_InitEnterChattingSelectMode= 10041;

//branch EP1.0 2014.11.3 luciper3 <http://wallis-devsub/redmine/issues/1134>
// 출석부
// #ifdef VIP_ATTENDANCE_ENABLE
const EV_VipAttendanceItemList		= 10050;
const EV_VipAttendanceCheck			= 10051;
//end of branch

// renewal ensoul
const EV_EnsoulWndShow				= 10060;
const EV_EnsoulResult				= 10061;
const EV_EnsoulExtractionWndShow	= 10062; //branch EP2.5 2016.1.7 luciper3 - 해외 클래식 집혼 - 추출기능 추가
const EV_EnsoulExtractionResult		= 10063; //branch EP2.5 2016.1.7 luciper3 - 해외 클래식 집혼 - 추출기능 추가
// end of renewal ensoul

//branch EP2.0 2015.6.29 luciper3 - 특화서버 - 공성전 시즌 정보와 보상받기
const EV_CastleWarSeasonResult		= 10070;
const EV_CastleWarSeasonReward		= 10071;
//end of branch

// Faction System(#2029) - moonhj
const EV_FactionInfo				= 10080;

//branch EP1.0 2015.1.27 luciper3 <http://wallis-devsub/redmine/issues/1344>
const EV_VipBotCaptchaInfo			= 10090;
const EV_VipBotCaptchaResult		= 10091;
//end of branch

// 아지트 개선 : 특수 기능 NPC 추가
const EV_SendAgitFuncInfo			= 10100;
const EV_ResponseDecoNPCAvalability = 10110;

// 인게임 웹 윈도우 - by y2jinc (2015. 10. 22)
const EV_InGameWebWnd_Info			= 10120;

// #2601 경쟁형 PVE 컨텐츠 몬스터 투기장 - 패킷 / UI 이벤트 작업 - y2jinc
// 몬스터 투기장 스테이지 클리어에 따른 획득 점수
// - InstantZoneID : 인존 ID
// - StageNum : 스테이지 번호
// - CurStageScore : 현재 스테이지 점수
// - TotalStageScore : 총 스테이지 점수
const EV_AI_CONTENT_MONSTER_ARENA_SCORE	= 10130;

// 차원 서버로 이동시 발생하는 이벤트 (#3069)
const EV_GotoWorldRaidServer		= 10140;

// 몬스터 도감
const EV_MonsterBookStart			= 10150;
const EV_MonsterBookInfo			= 10151;
const EV_MonsterBookEnd				= 10152;
const EV_MonsterBookRewardIcon		= 10160;
const EV_MonsterBookOpenResult		= 10161;
const EV_MonsterBookCloseForce		= 10162;
const EV_FactionInfoRewardIcon		= 10170;
const EV_FactionLevelUpNotify		= 10171;

// 월드맵 개선(#3328) - moonhj
const EV_AddAgitSiegeInfo			= 10180;
const EV_RaidBossSpawnInfo			= 10181;
const EV_RaidServerInfo				= 10182;
const EV_ItemAuctionStatus			= 10183;

// 업그레이드 시스템(#4275) - by moonhj
const EV_ShowUpgradeSystem			= 10190;
const EV_UpgradeSystemResult		= 10191;

//-------------------------------------------------------------------------
// #3380 크세르스 연합군 기지 방어전 - UI API / 이벤트
// 크세르스 연합군 기지 방어전의 단계, 중간중간에 서버에서 보내지고, 이벤트가 끝나면 remain_sec가 0으로 온다
// - Step[int] : 현재 단계 값
// - RemainTime[INT] : 남은 시간(초) 0 이면 이벤트 종료.
// - GoalPoint[INT] : 달성 해야할 포인트
const EV_KserthFieldEventStep		= 10200;

// 크세르스 연합군 기지 방어전의 이벤트 포인트 정보
// - CurPoint : 현재 포인트
const EV_KserthFieldEventPoint		= 10210;
//-------------------------------------------------------------------------

// #3963 개인 상점 리포트
const EV_PrivateStoreBuyingResult	= 10220;	// 플레이어의 구매 이벤트(int nItemSID, __int64 nAmount, string charName)
const EV_PrivateStoreSellingResult	= 10221;	// 플레이어의 판매 이벤트(int nItemSID, __int64 nAmount, string charName)

//이벤트 알람을 위한 엔터월드 시 서버 타임 전송
const EV_CurrentServerTime			= 10230;

// #4288 숫자 카드 게임
const EV_CardUpdownGameStart		= 10240;	// 숫자 카드 게임 시작(short remain_time, short max pick try count)
const EV_CardUpdownGamePickResult	= 10250;	// 숫자 카드 게임 선택 결과(char CardUpDownGame::PickResultType)
const EV_CardUpdownGamePrepReward	= 10260;	// 숫자 카드 게임 보상 보여주기(int id, int amount, int id, int amount)
const EV_CardUpdownGameRewardReply	= 10270;	// 숫자 카드 게임 보상 받기 결과(char result: success=1/fail=0)
const EV_CardUpdownGameQuit			= 10280;	// 숫자 카드 게임 종료(char CardUpDownGame::GameQuitReason)

// #4342 혈맹 개선 (PledgeV2)
// 1.혈맹 레벨 성장 관련

const EV_PledgeContributionRank		= 10350;	//혈맹공헌도 랭킹
const EV_PledgeContributionInfo		= 10360;	//혈맹공헌도 정보
const EV_PledgeContributionReward	= 10370;	//혈맹공헌도 보상

const EV_PledgeRaidRank				= 10400;	//혈맹레이드 랭킹
const EV_PledgeRaidInfo				= 10410;	//혈맹레이드 내혈맹 정보

const EV_PledgeLevelUp				= 10420;	//혈맹 레벨 업
const EV_PledgeShowInfoUpdate		= 10430;	//혈맹 기본 정보 업데이트

// 혈맹 미션 시스템(#4596) - by moonhj
const EV_PledgeMissionInfo			= 10440;	// 혈맹 미션 정보
const EV_PledgeMissionRewardCount	= 10441;	// 혈맹 미션 보상 수량

//PledgeV2 기존 MXLUI Event로 보내주고 있는 혈맹 관련 이벤트들 GFX 전용으로 변경
const EV_GFX_ClanInfo				= 10450;
const EV_GFX_ClanInfoEnd			= 10451;
const EV_GFX_ClanInfoUpdate			= 10460;
const EV_GFX_ClanDeleteAllMember	= 10470;
const EV_GFX_ClanAddMember			= 10480;
const EV_GFX_ClanAddMemberMultiple	= 10490;
const EV_GFX_ClanDeleteMember		= 10500;
const EV_GFX_ClanMemberInfoUpdate	= 10510;
const EV_GFX_ClanMyAuth				= 10520;
const EV_GFX_ClanAuth				= 10530;
const EV_GFX_ClanAuthMember			= 10540;
const EV_GFX_ClanAuthGradeList		= 10550;
const EV_GFX_ClanSubClanUpdated		= 10560;
const EV_GFX_ResultJoinDominionWar	= 10570;
const EV_GFX_AskStartPledgeWar		= 10580;
const EV_GFX_ClanCrestChange		= 10590;
const EV_GFX_ClanMemberInfo			= 10600;
const EV_GFX_ClanSkillList			= 10610;
const EV_GFX_ClanSkillListRenew		= 10620;
const EV_GFX_ClanWarList			= 10630;
const EV_GFX_ClanClearWarList		= 10640;
const EV_GFX_ReceivePledgeMemberList	= 10650;
const EV_GFX_AskStopPledgeWar		= 10660;

//Pledge Mastery (PledgeV2)
const EV_PledgeMasteryInfo			= 10670;
const EV_PledgeMasterySet			= 10680;
const EV_PledgeMasteryReset			= 10690;

//도움말 개선(#4540)
const EV_TutorialShowID				= 10700;

//Pledge Mastery 추가
const EV_PledgeSkillInfo			= 10710;
const EV_PledgeSkillActivate		= 10720;
const EV_PledgeItemList				= 10730;
const EV_PledgeItemActivate			= 10740;
const EV_PledgeAnnounce				= 10750;
const EV_PledgeAnnounceSet			= 10760;

//혈맹 문장/마크 관련

const EV_PledgeCrestSet				= 10770;
const EV_PledgeEmblemSet			= 10780;
const EV_AllyCrestSet				= 10790;

//혈맹 창설 UI 개선(#4736)
const EV_PledgeCreateShow			= 10800;

//Pledge 상점

const EV_PledgeItemInfo				= 10810;
const EV_PledgeItemBuy				= 10820;

//혈맹 해체, 제명, 탈퇴

const EV_DismissPledge				= 10830;
const EV_OustPledge					= 10840;
const EV_WithdrawPledge				= 10850;

//branch - Classic Elemental System - luciper3
const EV_ElementalSpiritInfo		= 10860;
const EV_ElementalSpiritExtractInfo = 10870;
const EV_ElementalSpiritEvolutionInfo = 10880;
const EV_ElementalSpiritEvolution   = 10890;
const EV_ElementalSpiritSetTalent   = 10900;
const EV_ElementalSpiritAbsorbInfo  = 10910;
const EV_ElementalSpiritAbsorb		= 10920;
//end of branch

//봉인
const EV_LockedItemShow				= 11000;
const EV_LockedResult				= 11010;

//NextTarget(#5716)
const EV_NextTargetModeChange		= 11030;	// 다음타겟모드변경

//-------------------------------------------------------------------------
// 20000 번대는 해외 작업을 위한 번호대역 입니다. 

//branch EP1.0 2015.1.27 luciper3 <http://wallis-devsub/redmine/issues/1343>
// VIP 인게임샵 개편
const EV_VipProductItemStart		= 20140;
const EV_VipProductItem				= 20141;
const EV_VipProductItemEnd			= 20142;
const EV_VipLuckyGameInfo			= 20143;
const EV_VipLuckyGameItemList		= 20144;
const EV_VipLuckyGameResult			= 20145;
//end of branch

//branch EP1.0 2015.1.27 luciper3 <http://wallis-devsub/redmine/issues/1342>
// VIP 정보창
const EV_VipInfo					= 20150;
const EV_VipInfoRemainTime			= 20151;
//end of branch

//branch EP2.0 2015.7.31 luciper3 - Todo_List
const EV_TodoListShow				= 20160;	// 오늘의 이벤트 창을 띄울때(처음 접속시 옵션 켜져있을 경우도 포함)
const EV_TodoList					= 20161;	// 오늘의 이벤트 리스트를 호출할때
const EV_TodoListHTML				= 20162;	// 이벤트 리스트 각 항목의 HTML을 호출할때
const EV_TodoListRecommandRenew		= 20163;	// 이벤트를 갱신할때
const EV_TodoListInzoneRenew		= 20164;	// 이벤트를 갱신할때
const EV_TodoListRecommandEnd		= 20165;	// 이벤트가 끝났을때
const EV_TodoListInzoneEnd			= 20166;	// 이벤트가 끝났을때

const EV_OneDayRewardListStart		= 20170;    // 일일보상 시스템 목록시작
const EV_OneDayRewardList			= 20171;    // 일일보상 시스템 (serverID(서버ID(int), rewardID(보상ID(int)), rewardName(보상명(string)), rewardStatus(보상수령상태(int)))
const EV_OneDayRewardListEnd		= 20172;    // 일일보상 시스템 목록끝
const EV_OneDayRewardItemListStart	= 20173;    // 일일보상 시스템 아이템목록 시작
const EV_OneDayRewardItemList		= 20174;    // 일일보상 시스템 아이템목록 (classID(아이템클래스ID(int)), itemCount(아이템개수(int)))
const EV_OneDayRewardItemListEnd	= 20175;    // 일일보상 시스템 아이템목록 끝
const EV_ConnectedTimeAndGettableReward = 20176;    // 일일보상 시스템에서 접속시간 및 받을수있는 일일보상 개수 및 QT 접속시간 및 받을수있는 보삭 개수 (int accessTime, int rewardCount, int QTAccessTime, int QTRewardCount)
const EV_OneDayRewardCount			= 20177;    // 일일보상 수령 가능 개수
//end of branch

//branch EP2.0 2015.8.3 luciper3 - AutoEquip_SoulShot 정령탄 자동 사용
const EV_SoulShotUpdate				= 20180;	// 정령탄 슬롯 갱신(int type, int have, int activate, ItemInfo itemInfo)
const EV_MyPetSummonEvent			= 20181;    // 팻 소환/해제 (int isSummon,int petId, int petType)
const EV_BeginSoulShotUpdate		= 20182;    // 정령탄 슬롯 갱신 전 이벤트 (ItemInfo weaponInfo)
//end of branch

//branch EP2.0 2015.8.19 luciper3 - 혈맹 보너스
const EV_PledgeBonusOpen			= 20190;    // 혈맹 보너스 윈도우 정보창
const EV_PledgeBonusList			= 20191;    // 혈맹 보너스 보상 아이템,스킬
const EV_PledgeBonusMarkReset		= 20192;    // 혈맹 보너스 혈맹활동 마크 갱신
const EV_PledgeBonusUpdate			= 20193;    // 혈맹 보너스 접속,사냥 갱신
const EV_PledgeClassicRaidInfo		= 20194;    // 혈맹 레이드 정보
//end of branch

//branch 2017-4-17 luciper3 - Ban 유저에 대한 코멘트 관련
const EV_UserBanInfo				= 20240;

// 20000 번대는 해외 작업을 위한 번호대역 입니다. 
//-------------------------------------------------------------------------


enum ESearchListType
{
	SLT_FRIEND_LIST,
	SLT_PLEDGEMEMBER_LIST,
	SLT_ADDITIONALFRIEND_LIST,
	SLT_ADDITIONAL_LIST,
};

enum EEventMatchObsMsgType
{
	MESSAGE_GM,
	MESSAGE_Finish,
	MESSAGE_Start,
	MESSAGE_GameOver,
	MESSAGE_1,
	MESSAGE_2,
	MESSAGE_3,
	MESSAGE_4,
	MESSAGE_5,
};

enum ETextAlign
{
	TA_Undefined,
	TA_Left, 
	TA_Center,
	TA_Right,
	TA_MacroIcon,
};

enum ETextVAlign
{
	TVA_Undefined,
	TVA_Top, 
	TVA_Middle,
	TVA_Bottom,
};
  
enum ETextureCtrlType
{
	TCT_Stretch,
	TCT_Normal,
	TCT_Tile,
	TCT_Draggable,
	TCT_Control,	//툴팁을 표시할 수 있다
	TCT_Mask,
};
 
enum ETextureLayer
{
	TL_None,
	TL_Normal,
	TL_Background,	
};

enum ENameCtrlType
{
	NCT_Normal,
	NCT_Item
};

enum EItemType
{
	ITEM_WEAPON, 
	ITEM_ARMOR, 
	ITEM_ACCESSARY, 	
	ITEM_QUESTITEM, 
	ITEM_ASSET, 
	ITEM_ETCITEM
};

enum EItemParamType
{
	ITEMP_WEAPON,
	ITEMP_ARMOR,
	ITEMP_SHIELD,
	ITEMP_ACCESSARY, 
	ITEMP_ETC,
};

enum EEtcItemType
{
	ITEME_NONE,
	ITEME_SCROLL,
	ITEME_ARROW,
	ITEME_POTION,
	ITEME_SPELLBOOK,
	ITEME_RECIPE,
	ITEME_MATERIAL,
	ITEME_PET_COLLAR,
	ITEME_CASTLE_GUARD,
	ITEME_DYE,
	ITEME_SEED,
	ITEME_SEED2,
	ITEME_HARVEST,
	ITEME_LOTTO,
	ITEME_RACE_TICKET,
	ITEME_TICKET_OF_LORD,
	ITEME_LURE,
	ITEME_CROP,
	ITEME_MATURECROP,
	ITEME_ENCHT_WP,
	ITEME_ENCHT_AM,
	ITEME_BLESS_ENCHT_WP,
	ITEME_BLESS_ENCHT_AM,
	ITEME_COUPON,
	ITEME_ELIXIR,
	ITEME_ENCHT_ATTR,	//CT26P3 - gorillazin
	ITEME_ENCHT_ATTR_CURSED,
	ITEME_BOLT, //#ifdef L2_KAMAEL // solasys
	ITEME_ENCHT_ATTR_INC_PROP_ENCHT_WP,
	ITEME_ENCHT_ATTR_INC_PROP_ENCHT_AM,

	//branch: 러시아 캐시 아이템을 위해 추가
	ITEME_ENCHT_ATTR_CRYSTAL_ENCHANT_AM,			
	ITEME_ENCHT_ATTR_CRYSTAL_ENCHANT_WP,			
	ITEME_ENCHT_ATTR_ANCIENT_CRYSTAL_ENCHANT_AM,	
	ITEME_ENCHT_ATTR_ANCIENT_CRYSTAL_ENCHANT_WP,
	ITEME_ENCHT_ATTR_RUNE,
	ITEME_ENCHT_ATTRT_RUNE_SELECT,
	//end of branch

	ITEME_TELEPORTBOOKMARK,
	ITEME_CHANGE_ATTR,
	ITEME_SOULSHOT,

	//branch
	// 무기 가공 시스템 - gorillazin 11.08.31.
	ITEME_SHAPE_SHIFTING_WP,
	ITEME_BLESS_SHAPE_SHIFTING_WP,
	//EIT_RESTORE_SHAPE_SHIFTING_WP,
	ITEME_SHAPE_SHIFTING_WP_FIXED,
	//end of branch

	//branch
	// 방어구 가공 시스템 - gorillazin 11.11.24.
	ITEME_SHAPE_SHIFTING_AM,
	ITEME_BLESS_SHAPE_SHIFTING_AM,
	ITEME_SHAPE_SHIFTING_AM_FIXED,

	ITEME_SHAPE_SHIFTING_HAIRACC,
	ITEME_BLESS_SHAPE_SHIFTING_HAIRACC,
	ITEME_SHAPE_SHIFTING_HAIRACC_FIXED,

	ITEME_RESTORE_SHAPE_SHIFTING_WP,
	ITEME_RESTORE_SHAPE_SHIFTING_AM,
	ITEME_RESTORE_SHAPE_SHIFTING_HAIRACC,
	ITEME_RESTORE_SHAPE_SHIFTING_ALLITEM,
	//end of branch

	//solasys-enchantsupportadd
	ITEME_BLESS_INC_PROP_ENCHT_WP,
	ITEME_BLESS_INC_PROP_ENCHT_AM,
	//solasys-end

	ITEME_CARD_EVENT,

	//branch121212
	ITEME_SHAPE_SHIFTING_ALLITEM_FIXED,
	
	//branch GD30 gorillazin
	// 인챈트 보조석 기능 추가 - gorillazin 13.05.02.
	ITEME_MULTI_ENCHT_WP,
	ITEME_MULTI_ENCHT_AM,
	ITEME_MULTI_INC_PROB_ENCHT_WP,
	ITEME_MULTI_INC_PROB_ENCHT_AM,
	//end of branch

	ITEME_ENSOUL_STONE,		//renewal ensoul

	// 호칭 색상 변경 아이템 
	ITEME_NICK_COLOR_OLD,
	ITEME_NICK_COLOR_NEW,

	// Agathion 리뉴얼 #4444
	// 아가시온 성장 주문서
	ITEME_ENCHT_AG,
	ITEME_BLESS_ENCHT_AG,
	ITEME_MULTI_ENCHT_AG,
	ITEME_ANCIENT_CRYSTAL_ENCHANT_AG,

	// 아가시온 성장 보조석
	ITEME_INC_PROP_ENCHT_AG,
	ITEME_BLESS_INC_PROP_ENCHT_AG,
	ITEME_MULTI_INC_PROB_ENCHT_AG,
	// Agathion 리뉴얼 END

	// 봉인
	ITEME_LOCK_ITEM,
	ITEME_UNLOCK_ITEM,

//	ITEME_BULLET, //branch Lineage2_Spec 17.03.14 sora615 신규 무기 타입 추가
};

enum ESkillCategory
{
	SKILL_Active,
	SKILL_Passive,
};

enum EActionCategory
{
	ACTION_NONE,
	ACTION_BASIC,
	ACTION_PARTY,
	ACTION_TACTICALSIGN,
	ACTION_SOCIAL,
	ACTION_PET,
	ACTION_SUMMON,
	ACTION_SUMMON_DIRECT,
	ACTION_SUMMON_AI,
	ACTION_SUMMON_REACT,
	ACTION_SUMMON_SKILL,
};

enum EXMLTreeNodeItemType
{
	XTNITEM_BLANK,
	XTNITEM_TEXT,
	XTNITEM_TEXTURE,
};

enum EServerAgeLimit
{
	SERVER_AGE_LIMIT_15,
	SERVER_AGE_LIMIT_18,
	SERVER_AGE_LIMIT_Free,
};

enum EInterfaceSoundType
{
	IFST_CLICK1,
	IFST_CLICK2,
	IFST_CLICK_FAILED,
	IFST_PICKUP,
	IFST_TRASH_BASKET,
	IFST_WINDOW_OPEN,
	IFST_WINDOW_CLOSE,
	IFST_QUEST_TUTORIAL,
	IFST_MINIMAP_OPEN_CLOSE,
	IFST_COOLTIME_END,
	IFST_PETITION,
	IFST_STATUSWND_OPEN,
	IFST_STATUSWND_CLOSE,
	IFST_INVENWND_OPEN,
	IFST_INVENWND_CLOSE,
	IFST_MAPWND_OPEN,
	IFST_MAPWND_CLOSE,
	IFST_SYSTEMWND_OPEN,
	IFST_SYSTEMWND_CLOSE,
	IFST_WORKSHOP_OPEN,
	IFST_WORKSHOP_CLOSE,
	IFST_SYSTEMWND_TELEAUTHFAIL
};

enum EChatType
{
	CHAT_NORMAL,
	CHAT_SHOUT,		// '!'
	CHAT_TELL,		// '\'
	CHAT_PARTY,		// '#'
	CHAT_CLAN,		// '@'
	CHAT_SYSTEM,		// ''
	CHAT_USER_PET,	// '&'
	CHAT_GM_PET,		// '*'
	CHAT_MARKET,		// '+'
	CHAT_ALLIANCE,	// '%'	
	CHAT_ANNOUNCE,	// ''
	CHAT_CUSTOM,		// ''
	CHAT_L2_FRIEND,	// ''
	CHAT_MSN_CHAT,	// ''
	CHAT_PARTY_ROOM_CHAT,	// ''		14
	CHAT_COMMANDER_CHAT,				// 15
	CHAT_INTER_PARTYMASTER_CHAT,
	CHAT_HERO,
	CHAT_CRITICAL_ANNOUNCE,
	CHAT_SCREEN_ANNOUNCE,
	CHAT_DOMINIONWAR,					// 20
	CHAT_MPCC_ROOM,
	CHAT_NPC_NORMAL,		// NPC 대사 필터링 - 2010.9.8 winkey
	CHAT_NPC_SHOUT,
	CHAT_FRIEND_ANNOUNCE,
	CHAT_WORLD,
};

enum ESystemMsgType
{
	SYSTEM_NONE,
	SYSTEM_BATTLE,
	SYSTEM_SERVER,
	SYSTEM_DAMAGE,
	SYSTEM_POPUP,
	SYSTEM_ERROR,
	SYSTEM_PETITION,
	SYSTEM_USEITEMS,
	SYSTEM_POPUPWITHMSG,
	SYSTEM_DAMAGETEXT,
	SYSTEM_CLIENT_DEBUG_MSG,	// 클라이언트 디버그 메세지용 - lancelot 2010. 8. 2.
};

enum ESystemMsgParamType
{
	SMPT_STRING,
	SMPT_NUMBER,
	SMPT_NPCID,
	SMPT_ITEMID,
	SMPT_SKILLID,
	SMPT_CASTLEID,
	SMPT_BIGNUMBER,
	SMPT_ZONENAME,
};

enum EMoveType
{
	MVT_NONE,
    MVT_SLOW,
    MVT_FAST,
};

enum EEnvType
{
	ET_NONE,
	ET_GROUND,
	ET_UNDERWATER,
	ET_AIR,
	ET_HOVER,
};

enum EControlReturnType
{
	CRTT_NO_CONTROL_USE,
	CRTT_CONTROL_USE,
	CRTT_USE_AND_HIDE,
};

enum EShortCutItemType
{
	SCIT_NONE,
	SCIT_ITEM,
	SCIT_SKILL,
	SCIT_ACTION,
	SCIT_MACRO,
	SCIT_RECIPE,
	SCIT_BOOKMARK,
	SCIT_ATTRIBUTE,
};

enum EInventoryUpdateType
{
	IVUT_NONE,
	IVUT_ADD,
	IVUT_UPDATE,
	IVUT_DELETE,
};

enum ERestartPointType
{
	RPT_VILLAGE,
	RPT_AGIT,
	RPT_CASTLE,
	RPT_FORTRESS,
	RPT_BATTLE_CAMP,
	RPT_ORIGINAL_PLACE,
	//branch
	RPT_VILLAGE_BY_DISMOUNT,		// branch 0303 국내 버전에서 누락되어서 추가. 다음 merge에서 확인 필요
	RPT_ORIGINAL_PLACE_LIMIT,		// branch 0804 모험가의 노래
	RPT_ARENA
	//RPT_BRANCH_START=20,			// 아래로 이동
	//RPT_AGATHION,
	//RPT_NPC
	//end of branch
};

//branch : ERestartPointType에 들어가야 하지만 uc는 enum에 숫자를 부여할 수 없어서 이렇게...
const RPT_BRANCH_START=20;
const RPT_AGATHION=21;
const RPT_NPC=22;
//end of branch

enum ECastleSiegeDefenderType
{
	CSDT_NOT_DEFENDER,
	CSDT_CASTLE_OWNER,
	CSDT_WAITING_CONFIRM,
	CSDT_APPROVED,
	CSDT_REJECTED,
};

enum ETooltipSourceType
{
	NTST_TEXT,
	NTST_ITEM,
	NTST_LIST,
};

//branch120516
enum EBR_CashShopProduct
{
	BRCSP_PRODUCT,
	BRCSP_RECENT,
	BRCSP_BASKET,	
};
//end of branch

//////////////////////////////////////////////
// @deprecate - 작업 이후 삭제 할 것. - y2jinc
enum EClassIconType
{
	CICON_LEVEL_TWO_WARRIOR,		// 2차 격수
	CICON_LEVEL_TWO_ROGUE,			// 2차 로그
	CICON_LEVEL_TWO_ARCHER,			// 2차 궁수
	CICON_LEVEL_TWO_FIGHTER,		// 2차 탱
	CICON_LEVEL_TWO_SONGDANCER,		// 2차 가무
	CICON_LEVEL_TWO_WIZARD,			// 2차 위자
	CICON_LEVEL_TWO_HEALER,			// 2차 힐러
	CICON_LEVEL_TWO_SUMMONER,		// 2차 소환사
	CICON_LEVEL_ONE_WARRIOR,		// 1차 격수
	CICON_LEVEL_ONE_WIZARD,			// 1차 법사
	CICON_LEVEL_THREE_WARRIOR,		// 3차 격수
	CICON_LEVEL_THREE_ROGUE,		// 3차 로그
	CICON_LEVEL_THREE_ARCHER,		// 3차 궁수
	CICON_LEVEL_THREE_FIGHTER,		// 3차 탱
	CICON_LEVEL_THREE_SONGDANCER,	// 3차 가무
	CICON_LEVEL_THREE_WIZARD,		// 3차 위자
	CICON_LEVEL_THREE_HEALER,		// 3차 힐러
	CICON_LEVEL_THREE_SUMMONER,		// 3차 소환사
	CICON_LEVEL_FOUR_FIGHTER,		// 4차 탱
	CICON_LEVEL_FOUR_WARRIOR,		// 4차 격수
	CICON_LEVEL_FOUR_ROGUE,			// 4차 로그
	CICON_LEVEL_FOUR_ARCHER,		// 4차 궁수
	CICON_LEVEL_FOUR_WIZARD,		// 4차 위자
	CICON_LEVEL_FOUR_ENCHANTER,		// 4차 인챈터
	CICON_LEVEL_FOUR_SUMMONER,		// 4차 소환사
	CICON_LEVEL_FOUR_HEALER,		// 4차 힐러
	CICON_LEVEL_FIVE_FIGHTER,		// 5차 탱
	CICON_LEVEL_FIVE_WARRIOR,		// 5차 격수
	CICON_LEVEL_FIVE_ROGUE,			// 5차 로그
	CICON_LEVEL_FIVE_ARCHER,		// 5차 궁수
	CICON_LEVEL_FIVE_WIZARD,		// 5차 위자
	CICON_LEVEL_FIVE_ENCHANTER,		// 5차 인챈터
	CICON_LEVEL_FIVE_SUMMONER,		// 5차 소환사
	CICON_LEVEL_FIVE_HEALER,		// 5차 힐러	
};
//////////////////////////////////////////////

enum EClassRoleType
{
	ECRT_NONE,		// 0: none
	ECRT_KNIGHT,	// 1: 나이트	
	ECRT_WARRIOR,	// 2: 워리어	
	ECRT_ROGUE, 	// 3: 로그  	
	ECRT_ARCHOR,	// 4: 아처  	
	ECRT_WIZARD,	// 5: 위자드	
	ECRT_SUMMONER,	// 6: 서머너	
	ECRT_ENCHANTER,	// 7: 인챈터	
	ECRT_SUPPORT,	// 8: 힐러  	
	ECRT_NOVICE,	// 9: 모험가	
};

enum EItemInventoryType
{
	EIIT_NONE,
	EIIT_EQUIPMENT,
	EIIT_CONSUMABLE,
	EIIT_MATERIAL,
	EIIT_ETC,
	EIIT_QUEST,
};

enum ECharacterDeleteFailType
{
	ECDFT_NONE,					// 사용하지 않는 타입 번호
	ECDFT_UNKNOWN,
	ECDFT_PLEDGE_MEMBER,
	ECDFT_PLEDGE_MASTER,
	ECDFT_PROHIBIT_CHAR_DELETION,
	ECDFT_COMMISSION,	
	ECDFT_MENTOR,		
	ECDFT_MENTEE,		
	ECDFT_MAIL,			
};

//enum MultiSellPointItemType
const MSIT_RAID_POINT=-500;
const MSIT_FIELD_CYCLE_POINT=-400;
const MSIT_PVP_POINT=-300;
const MSIT_PLEDGE_POINT=-200;
const MSIT_PCCAFE_POINT=-100;


//enum EtcSkillAcquireType
const	ESTT_NORMAL=0;
const	ESTT_FISHING=1;	// 낚시
const	ESTT_CLAN=2;		// 혈맹
const 	ESTT_SUB_CLAN=3;	// 하위 혈맹 스킬
const	ESTT_TRANSFORM=4;		// 변신 스킬
const	ESTT_SUBJOB=5;		// CT1.5
const	ESTT_COLLECT=6;		// CT2 Final
const	ESTT_BISHOP_SHARING=7;		// CT2.5 Skill Sharing	
const	ESTT_ELDER_SHARING=8;		// CT2.5 Skill Sharing	
const	ESTT_SILEN_ELDER_SHARING=9;			// CT2.5 Skill Sharing

// 이거말고 UIScript.uc에 있는 GetMaxLevel() 함수 써주세요 - lancelot 2007. 11. 13.
//const	MAX_Level = 80;

const	CLAN_AUTH_VIEW = 1;
const	CLAN_AUTH_EDIT = 2;

const	CLAN_MAIN = 0;
const	CLAN_KNIGHT1 = 100;
const	CLAN_KNIGHT2 = 200;
const	CLAN_KNIGHT3 = 1001;
const	CLAN_KNIGHT4 = 1002;
const	CLAN_KNIGHT5 = 2001;
const	CLAN_KNIGHT6 = 2002;
const	CLAN_ACADEMY = -1;

const	CLAN_KNIGHTHOOD_COUNT = 8;

const	CLAN_MEMBERTYPE_COUNT = 2;

const	CLAN_AUTH_GRADE1 = 1;
const	CLAN_AUTH_GRADE2 = 2;
const	CLAN_AUTH_GRADE3 = 3;
const	CLAN_AUTH_GRADE4 = 4;
const	CLAN_AUTH_GRADE5=5;
const	CLAN_AUTH_GRADE6=6;
const	CLAN_AUTH_GRADE7=7;
const	CLAN_AUTH_GRADE8=8;
const	CLAN_AUTH_GRADE9=9;

//these const variables are used for bit flag.
const DisabledByStat = 1;
const DisabledByItem = 2;
const DisabledByCost = 4;
const DisabledByCasterAbnormalState = 8;
const DisabledByTargetAbnormalState = 16;
const DisabledByUltimateSkillPoint = 32;

struct native constructive ArmorEnchantBonusValue
{
	var float PhysicalDamage;
	var float MagicalDamage;
	var float PhysicalCriRate;
	var float MagicalCriRate;
	var float PhysicalAttackSpeed;
	var float MagicalAttackSpeed;
	var float MoveSpeed;	
	var float PhysicalAvoid;
	var float MagicalAvoid;
	var float PhysicalHitRate;
	var float MagicalHitRate;
};

struct native constructive ItemEnchantBonusValue
{	
	var float PhysicalDamage;
	var float MagicalDamage;
	var float PhysicalCriRate;
	var float MagicalCriRate;
	var float PhysicalAttackSpeed;
	var float MagicalAttackSpeed;
	var float MoveSpeed;	
	var float PhysicalAvoid;
	var float MagicalAvoid;
	var float PhysicalHitRate;
	var float MagicalHitRate;	
};

struct native constructive DynamicContentInfo
{
	var string Title;
	var string Name;
	var string Tooltip;
	var int	GoalCnt;
	var array<INT> GoalID;
	var array<string> GoalDescription;
};

//branch120516
struct native constructive EventContentInfo
{
	var string Title;	
	var string Name;
	var string Tooltip;
	var int	GoalCnt;
	var array<INT> GoalID;
	var array<string> GoalDescription;
};

//end of branch

struct native constructive ItemID
{
	var int ClassID;
	var int ServerID;
};

// [N토핑 버프]클라이언트 UI 관련 이벤트 및 API 작업(#1695) - y2jinc
// 토핑 스킬 부가 정보
struct native constructive ToppingSkillExtraInfo
{
	var int		ID;				// 스킬 ID
	var int		Level;			// 스킬 Level
	var int		SubLevel;		// 스킬 SubLevel
	var int		SlotIndex;		// 슬롯 순서
	var bool	bIsDefault;		// 기본 표시
};

struct native constructive AgitDecoPriceToken
{
	var int		ItemClassID;
	var int		Cnt;
};
struct native constructive AgitDecoNPCData
{
	var int		DecoNpcId;
	var int		NpcId;
	var int		Level;
	var int		FactionType;
	var int		NpcType;
	var int		NpcTypeIdx;
	var int		SubType;
	var int		SubTypeIdx;
	var INT64	PriceAdena;
	var array<AgitDecoPriceToken>	PriceToken;
	var int		Period;
	var string	Desc;
};
struct native constructive AgitDecoNPCTypeList
{
	var int		NpcType;
	var int		NpcTypeIdx;
};
const MAX_RELATED_QUEST = 10;
//branch
const MAX_INCLUDE_ITEM = 10;
//end of branch

// renewal ensoul
//enum EnsoulItemSlotType
const EIST_INVALID = 0;
const EIST_NORMAL = 1;
const EIST_BM = 2;
const EIST_MAX = 3;	// Max값이 바뀌면 아래 EISI_MAX 값도 바꿔야 한다.(EnsoulItem::EIST_MAX - EnsoulItem::EISI_START)

//enum EnsoulItemSlotIndex
const EISI_INVALID = -1;
const EISI_START = 1;
const EISI_MAX = 2;

// uc에서 array 변수를 배열로 선언(ex. var array<INT> element[2])이 안되서 struct로 wrap ㅠㅠ
struct native constructive EnsoulOptionInfo
{
	var array<INT> OptionArray;
};
// end of renewal ensoul


struct native constructive ItemInfo
{
	var ItemID Id;
	var string Name;
	var string AdditionalName;
	var string IconName;
	var string IconNameEx1;
	var string IconNameEx2;
	var string IconNameEx3;
	var string IconNameEx4;
	var string ForeTexture;
	var string Description;
	var string DragSrcName;
	var string IconPanel;
	var int DragSrcReserved;
	var string MacroCommand;
	var int ItemType;
	var int ItemSubType;
	var INT64 ItemNum;
	var INT64 Price;
	var int Level;
	var int SubLevel;
	var INT64 SlotBitType;	// by y2jinc
	var int Weight;
	var int MaterialType;
	var int WeaponType;
	
	var float pDefense;
	var float mDefense;
	var float pAttack;
	var float mAttack;
	var float pAttackSpeed;
	var float mAttackSpeed;	
	var float pHitRate;
	var float mHitRate;
	var float pCriRate;
	var float mCriRate;
	var float MoveSpeed;
	var float ShieldDefense;
	var float ShieldDefenseRate;
	var float pAvoid;
	var float mAvoid;
	var int enchant_bonus;
	
	var INT64 n64DefaultPriceFromScript;	// 연금술 작업 - by y2jinc (2013. 10. 8)
	
	//must be removed jdh84. 기존의 스텟수치 변수 삭제
// 	var int PhysicalDamage;
// 	var int MagicalDamage;
// 	var int PhysicalDefense;
// 	var int MagicalDefense;
// 	var int ShieldDefense;
// 	var int ShieldDefenseRate;
// 	var int Critical;
// 	var int HitModify;
// 	var int AttackSpeed;
// 	var int AvoidModify;
	
	var int Durability; 
	var int CrystalType;
	var int RandomDamage;
	
	var int MpConsume;
	var int ArmorType;
	
	var int Damaged;
	var int Enchanted;
	var int MpBonus;
	var int SoulshotCount;
	var int SpiritshotCount;
	var int PopMsgNum;
	var int BodyPart;
	var int RefineryOp1;
	var int RefineryOp2;
	var int CurrentDurability;
	var int CurrentPeriod;
	// [칠월칠석, 방어구 각인] item enchant option - by jin 09/08/05
	var int EnchantOption1;
	var int EnchantOption2;
	var int EnchantOption3;
	//
	var int Reserved;
	var INT64 Reserved64;
	var INT64 DefaultPrice;
	var int ConsumeType;
	var int Blessed;
	var INT64 AllItemCount;
	var int IconIndex;
	var bool bEquipped;
	var bool bRecipe;  
	var bool bArrow; 
	var bool bShowCount;
	var int bDisabled;
	var int iSkillDisabled;
// iSkillDisabled contain multiple 'disable' types. iSkillDisabled must be a bit flag.
// modified by jumper
	
//	var bool bDisabled;
//	var bool bDisabledByItem;
//	var bool bDisabledByCost;
//	var bool bDisabledByStat;
//	var bool bDisabledByTargetBuff;
//	var bool bDisabledByCasterBuff;
//	var bool bDisabledByUltimateSkillPoint;

	var bool bIsLock; // var bool bSkillLock;
	var bool bSecurityLockable;
	var bool bSecurityLock;

	var int AttackAttributeType;		// 속성 - lancelot 2007. 4.27.
	var int AttackAttributeValue;
	var int DefenseAttributeValueFire;
	var int DefenseAttributeValueWater;
	var int DefenseAttributeValueWind;
	var int DefenseAttributeValueEarth;
	var int DefenseAttributeValueHoly;
 	var int DefenseAttributeValueUnholy;
	var int RelatedQuestID[MAX_RELATED_QUEST];
	
	var int ReuseDelayShareGroupID;

	var int Attribution;
	var int PropertyParams;

	var bool IsToggleSkill;
	var bool IsToggle;	
	//branch
	var int IsBRPremium;
	var int IncludeItem[MAX_INCLUDE_ITEM];
	var int BR_CurrentEnergy;
	var int BR_MaxEnergy;
	var int LookChangeIconID; //branch 111109
	//end of branch
	//branch 110824 무기외형변경
	var int LookChangeItemID;
	var string LookChangeItemName;
	var string LookChangeIconPanel; //branch 110824 무기외형패널
	//end of branch

	var EnsoulOptionInfo EnsoulOption[EISI_MAX];	// renewal ensoul

	// 서버로 부터 받은 아이템의 인벤토리에서의 순서를 저장 - gorillazin 11.02.18.
	var int Order;
	var string tooltipTexutre;

	// 확정 보상 지급 아이템(#4949) - by moonhj
	var int CurUseCount;
	var int MaxUseCount;
	var float RemainReuseDelay;
	var float MaxReuseDelay;
	var float ReceivedAppSec;
};

struct native constructive LVTexture
{
	var texture objTex;
	var int		X;
	var int		Y;
	var int		Width;
	var int		Height;
	var int		U;
	var int		V;
	var int		UL;
	var int		VL;
};

struct native constructive LVData
{
	var bool hasIcon;//텍스쳐와 스트링을 동시에 사용. 텍스쳐는 아이콘처럼 사용
	var int nsortPrior;
	var bool iconPostion;//아이콘 포지션 false:좌측, true우측 - kachanim

	var string szData;
	var string szReserved;
	var string HiddenStringForSorting;		// 여기를 채워놓으면 szData대신에 이걸로 sorting을 함. 판매대행에서 사용 - lancelot 2010.12. 09.
	var int FirstLineOffsetX;
	var ETextAlign textAlignment;

	var bool bUseTextColor;
	var Color TextColor;

	var int nReserved1;
	var int nReserved2;
	var int nReserved3;
	
	// 속성표시줄
	var string AttrStat[6];
	var array<LVTexture> AttrIconTexArray;
	var Color AttrColor;

	//Main Texture(텍스쳐 하나만 설정할때, Centeralign된다)
	var string szTexture;
	var int nTextureWidth;
	var int nTextureHeight;
	var int nTextureU;
	var int nTextureV;
	var int IconPosX;		// Y는 중간정렬할꺼기때문에 없다.

	// icon의 BackTexture
	var string iconBackTexName;
	var int backTexOffsetXFromIconPosX;
	var int backTexOffsetYFromIconPosY;
	var int backTexWidth;
	var int backTexHeight;
	var int backTexUL;
	var int backTexVL;

	// icon 위에 얹히는 패널
	var string iconPanelName;
	var int panelOffsetXFromIconPosX;
	var int panelOffsetYFromIconPosY;
	var int panelWidth;
	var int panelHeight;
	var int panelUL;
	var int panelVL;
	
	// 아래 두 텍스처는 Panel과 동일한 위치 정보를 사용한다.
	var string foreTextureName;				// for ItemInfo::ForeTexture; 
	var string LookChangeiconPanelName;		//branch 110824 무기외형변경

	//Texture Array
	var array<LVTexture> arrTexture;

	//#ifdef USE_STATUSBAR_IN_LISTCTRL
	var int nStatusBarCurrentCount;
	var int nStatusBarMaxCount;
	//#endif //USE_STATUSBAR_IN_LISTCTRL
};

struct native constructive LVDataRecord
{	
	var array<LVData> LVDataList;
	var string szReserved;
	var INT64 nReserved1;
	var INT64 nReserved2;
	var INT64 nReserved3;

	//#ifdef USE_STATUSBAR_IN_LISTCTRL
	var BOOL bUseStatusBar;
	var int nStatusBarIndex;
	var string strStatusBarForeLeftTex;
	var string strStatusBarForeCenterTex;
	var string strStatusBarForeRightTex;
	var string strStatusBarBackLeftTex;
	var string strStatusBarBackCenterTex;
	var string strStatusBarBackRightTex;
	var int nStatusBarWidth;
	var int nStatusBarHeight;
	//#endif //USE_STATUSBAR_IN_LISTCTRL
};

struct native constructive UserInfo
{
	var int nID;
	var string Name;
	var string strNickName;
	var string RealName;
	var int nSex;
	var int Race;
	var int Class;
	var int nLevel;
	var int nClassID;
	var int nSubClass;	// 현재 활성화되어 있는 class id
	var INT64 nSP;
	var int nCurHP;
	var int nMaxHP;
	var int nCurMP;
	var int nMaxMP;
	var int nCurCP;
	var int nMaxCP;
	var INT64 nCurExp;
	
	var int nUserRank;
	var int nClanID;
	var int nAllianceID;
	var int nCarryWeight;
	var int nCarringWeight;
	
	var int nPhysicalAttack;
	var int nPhysicalDefense;
	var int nHitRate;
	var int nCriticalRate;
	var int nPhysicalAttackSpeed;
	var int nMagicalAttack;
	var int nMagicDefense;
	var int nMagicAvoid;
	var int nMagicHitRate;
	var int nMagicCriticalRate;
	var int nPhysicalAvoid;
	var int nWaterMaxSpeed;
	var int nWaterMinSpeed;
	var int nAirMaxSpeed;
	var int nAirMinSpeed;
	var int nGroundMaxSpeed;
	var int nGroundMinSpeed;
	var float fNonAttackSpeedModifier;
	var int nMagicCastingSpeed;
	
	var int nStr;
	var int nDex;
	var int nCon;
	var int nInt;
	var int nWit;
	var int nMen;
	var int nLuc;
	var int nCha;
	
	var int nCriminalRate;
	var int nDualCount;
	var int nPKCount;
	var int nSociality;
	var int nRemainSulffrage;
	var int nNobless;
	
	var bool bHero;
	var bool bNpc;
	var bool bPet;
	var bool bCanBeAttacked;
	
	// 변신
	var bool m_bPawnChanged;

	var bool WantHideName;

	var vector Loc;

	// 캐릭터 속성 - lancelot 2007. 5. 18.
	var int AttrAttackType;
	var int AttrAttackValue;
	var int AttrDefenseValFire;
	var int AttrDefenseValWater;
	var int AttrDefenseValWind;
	var int AttrDefenseValEarth;
	var int AttrDefenseValHoly;
	var int AttrDefenseValUnholy;
	
	// 변신
	var int nTransformID;
	
	//Inven Item Order, ttmayrin
	var int nInvenLimit;

	// 2008/03/05 PvP Point Restrain - NeverDie
	var int PvPPointRestrain;

	// 2008/03/05 PvP Point - NeverDie
	var int PvPPoint;
	
	var int RaidPoint;

	var color NicknameColor;

	var int nVitality;
	var int nVitalBonus;
	var int nVitalItem;

	// Decoy - anima
	var int nMasterID;

	// 2008/8/4 Talisman Num
	var int nTalismanNum;
	var int nJewelNum;      // JEWEL 추가 - by y2jinc (2013. 9. 2)
	var int nAgathionMainNum;		// Agathion 리뉴얼
	var int nAgathionSubNum;		// Agathion 리뉴얼
	// 2008/8/7 FullArmor Check
	var int nFullArmor;

	var int JoinedDominionID;		// lancelot 2008. 8. 28.
	var int DominionIDForVirtualName;
	
	// EXP percent rate - 2010/05/19 sori
	var float fExpPercentRate;
	
	var int UltimateSkillPoint;
	var int TacticSign;

//	var int nSubstitute; 자동대타 제거

	var int nRemainAbilityPoint;
};

struct native constructive SkillInfo
{
	var String SkillName;
	var String SkillDesc;
	var int SkillID;
	var int SkillLevel;
	var int SkillSubLevel;
	var int OperateType;	// 0 - A1 이상상태를 걸지 않는 액티브 스킬, 1 - A2 이상상태를 거는 액티브 스킬, 2 - P 패시브 스킬, 3 - T 토글 스킬 	
	var int MpConsume;
	var int HpConsume;
	var int CastRange;
	var int CastStyle;
	var float HitTime;
	var float CoolTime;
	var float ReuseDelay;
//	var bool ReuseDelayLock;
	var bool IsUsed;
	var int IsMagic;
	var int IsDouble;
	var String AnimName;
	var String SkillPresetName;
	var String TexName;
	var String IconPanel;
	var int	IconType;		// Skill 그룹핑
//MultiSummon by elsacred
	var int Debuff;
	var String EnchantName;
	var String EnchantDesc;
	var int Enchanted;
	var int EnchantSkillLevel;
	var String EnchantIcon;
	var int RumbleSelf;
	var int RumbleTarget;
	var int MagicType;		// EMixMagicType
};

struct native constructive PetInfo
{
	var int nServerID;
	var int nClassID;
	var string Name;
	var int nLevel;
	var INT64 nSP;
	var int nCurHP;
	var int nMaxHP;
	var int nCurMP;
	var int nMaxMP;
	var INT64 nCurExp;
	var INT64 nMaxExp;
	var INT64 nMinExp;
	
	var int nCarryWeight;
	var int nCarringWeight;
	
	var int nPhysicalAttack;
	var int nPhysicalDefense;
	var int nHitRate;
	var int nCriticalRate;
	var int nPhysicalAttackSpeed;
	var int nPhysicalAvoid;
	var int nMagicalAttack;
	var int nMagicDefense;
	var int nMagicalAvoid;
	var int nMagicalHitRate;
	var int nMagicalCritical;
	var int nMovingSpeed;
	var int nMagicCastingSpeed;
	var int nSoulShotCosume;
	var int nSpiritShotConsume;
	
	var int nFatigue;
	var int nMaxFatigue;
	var int PetOrSummoned;
	var int nEvolutionID;
};

struct native constructive SummonInfo
{
	var int nServerID;
	var int nClassID;
	var string Name;
	var int nLevel;
	var INT64 nSP;
	var int nCurHP;
	var int nMaxHP;
	var int nCurMP;
	var int nMaxMP;
	var INT64 nCurExp;
	var INT64 nMaxExp;
	var INT64 nMinExp;
	
	var int nCarryWeight;
	var int nCarringWeight;
	
	var int nPhysicalAttack;
	var int nPhysicalDefense;
	var int nHitRate;
	var int nCriticalRate;
	var int nPhysicalAttackSpeed;
	var int nMagicalAttack;
	var int nMagicDefense;
	var int nMagicalHitRate;
	var int nMagicalAvoid;
	var int nMagicalCritical;
	var int nPhysicalAvoid;
	var int nMovingSpeed;
	var int nMagicCastingSpeed;
	var int nSoulShotCosume;
	var int nSpiritShotConsume;
	
	var int nFatigue;
	var int nMaxFatigue;
	var int PetOrSummoned;
	var int nEvolutionID;
//	var int nDoubleSummoned;
//	var int nSummonedPoint;
//	var int nSummonablePoint;
};

struct native constructive MacroInfo
{
	var int		Id;
	var string	Name;
	var string	IconName;
	var string	IconTextureName;
	var int		IconSkillId;
	var string	Description;
	var string	CommandList[12];
};

struct native constructive MacroPresetInfo
{
	var int		Id;
	var string	Name;
	var string	IconName;
	var string	IconTextureName;
	var string	Description;
	var string	PresetDescription;
	var string	CommandList[12];
};

struct native Rect
{
	var int nX;
	var int nY;
	var int nWidth;
	var int nHeight;
};

struct native constructive ClanMemberInfo
{
	var	int	clanType;
	var	string	sName;
	var	int	Level;
	var	int	ClassID;
	var	int	gender;
	var	int	Race;
	var	int	Id;
	var int bActive; //branch EP2.0 2015.8.19 luciper3 - 혈맹 보너스
	var	int	bHaveMaster;
};

struct native constructive ClanInfo
{
	var array<ClanMemberInfo>	m_array;
	var string					m_sName;
	var string					m_sMasterName;
};

struct native ResolutionInfo
{
	var int nWidth;
	var int nHeight;
	var int nColorBit;
};

struct native constructive FileNameInfo
{
	var string fileName;
	var bool bIsFile;
};
struct native constructive DriveInfo
{
	var string driveChar;
};
enum EDrawItemType
{
	DIT_BLANK,
	DIT_TEXT,
	DIT_TEXTURE,
	DIT_SPLITLINE,
	//branch
	DIT_TEXTLINK,
	//end of branch
};

enum EDrawItemAlignType
{
	DIAT_LEFT,
	DIAT_CENTER,
	DIAT_RIGHT
};

struct native constructive DrawItemInfo
{
	var EDrawItemType eType;
	
	var int		nOffSetX;
	var int		nOffSetY;
	var bool	bLineBreak;
	
	//For BLANK
	var int		b_nHeight;
	
	//For TEXT
	var int		t_ID;
	var string	t_strText;
	var color	t_color;
	var bool	t_bDrawOneLine;
	//branch : one line이 아닐 때 text width를 설정할 수 있게
	var int		t_MaxWidth;

	var string  t_strFontName;
	
	//For TEXTURE
	var int		u_nTextureWidth;
	var int		u_nTextureHeight;
	var int		u_nTextureUWidth;	// ex) 32*32 아이콘을 16*16으로 그리고싶을때 Width=16, UWidth=32 이런식으로 셋팅해주시면됩니다.
	var int		u_nTextureUHeight;
	var string	u_strTexture;	
	
	//For Dynamic Text
	var string Condition;

	var EDrawItemAlignType	eAlignType;
};

struct native constructive CustomTooltip
{
	var int MinimumWidth;
	var int SimpleLineCount;
	var Array<DrawItemInfo> DrawList;
};

struct native constructive XMLTreeNodeItemInfo
{
	var EXMLTreeNodeItemType eType;
	
	var int		nOffSetX;
	var int		nOffSetY;
	var bool	bLineBreak;
	var bool	bStopMouseFocus;
	
	//For E_XMLTREE_NODEITEM_BLANK
	var int		b_nHeight;
	
	//For E_XMLTREE_NODEITEM_TEXT
	var int		t_nTextID;
	var string	t_strText;
	var color	t_color;
	var bool	t_bDrawOneLine;

	var ETextVAlign t_vAlign;
	var int		t_nMaxHeight;
	var	int		t_nMaxWidth;
	
	//For E_XMLTREE_NODEITEM_TEXTURE
	var int		u_nTextureWidth;
	var int		u_nTextureHeight;
	var int		u_nTextureUWidth;
	var int		u_nTextureUHeight;
	var string	u_strTexture;
	var string	u_strTextureMouseOn;
	var string	u_strTextureExpanded;

	//Reserved
	var int		nReserved;	
	var int		nReserved2;	
};

struct native constructive XMLTreeNodeInfo
{
	var string	strName;
	
	var int		nOffSetX;
	var int		nOffSetY;
	
	var int		bDrawBackground;
	
	//For Back Texture
	var int		bTexBackHighlight;
	var int		nTexBackHighlightHeight;
	var int		nTexBackWidth;
	var int		nTexBackUWidth;
	var int		nTexBackOffSetX;
	var int		nTexBackOffSetY;
	var int		nTexBackOffSetBottom;
	
	//Expanded Texture
	var string	strTexExpandedLeft;
	var string	strTexExpandedRight;
	var int		nTexExpandedOffSetX;
	var int		nTexExpandedOffSetY;
	var int		nTexExpandedHeight;
	var int		nTexExpandedRightWidth;
	var int		nTexExpandedLeftUWidth;
	var int		nTexExpandedLeftUHeight;
	var int		nTexExpandedRightUWidth;
	var int		nTexExpandedRightUHeight;
	
	//For Tree Expand Button
	var int		bShowButton;
	var int		nTexBtnWidth;
	var int		nTexBtnHeight;
	var int		nTexBtnOffSetX;
	var int		nTexBtnOffSetY;
	var string	strTexBtnExpand;
	var string	strTexBtnCollapse;
	var string	strTexBtnExpand_Over;
	var string	strTexBtnCollapse_Over;
	
	//For Tooltip
	var CustomTooltip ToolTip;
	var bool bFollowCursor;
};

struct native constructive StatusIconInfo
{
	var int		ServerID;
	var string	Name;
	var string	IconName;
	var int		Size;
	var string	Description;
	var string  BackTex;

	var int		RemainTime;
	var ItemID	Id;
	var int		Level;
	var int		SubLevel;
	
	var bool	bOwnership;
	var bool	bShow;
	var bool	bShortItem;
	var bool	bEtcItem;
//MultiSummon by elsacred
	var int		Debuff;
	var int		SpellerID;
	var bool	bHideRemainTime;
};

struct native constructive GameTipData
{
	var int Id;
	var int Priority;
	var int TargetLevel;
	var bool Validity;
	var String TipMsg;
	var String TipImg;
};

struct native constructive HennaInfo
{
	var int HennaID;
	var int ClassID; 
	var int Num;
	var int Fee;
	var int CanUse;
	var int INTnow;
	var int INTchange;
	var int STRnow;
	var int STRchange;
	var int CONnow;
	var int CONchange;
	var int MENnow;
	var int MENchange;
	var int DEXnow;
	var int DEXchange;
	var int WITnow;
	var int WITchange;
	var int LUCnow;
	var int LUCchange;
	var int CHAnow;
	var int CHAchange;
};

struct native constructive EventMatchUserData
{
	var int UserID;
	var String UserName;
	var int HPNow;
	var int HPMax;
	var int MPNow;
	var int MPMax;
	var int CPNow;
	var int CPMax;
	var int UserLv;
	var int UserClass;
	var int UserGender;
	var int UserRace;
	var Array<int> BuffIDList;
	var Array<int> BuffRemainList;
};

// lancelot 2006. 10. 11.
struct native constructive SystemMsgData
{
	var String Group;
	var Color FontColor;
	var String Sound;
	var String Voice;
	var int WindowType;
	var int FontType;
	var int LifeTime;
	var int AnimationType;
	var int BackgroundType;
	var String SysMsg;
	var String OnScrMsg;
	var string GFxScrMsg;
	var string GFxScrParam;
};


struct native constructive EventMatchTeamData
{
	var int Score;
	var String TeamName;
	var int PartyMemberCount;
	var EventMatchUserData User[ MAX_PartyMemberCount ];
};

struct native constructive ShortcutCommandItem
{
	var string sCommand;
	var string Key;
	var string subkey1;
	var string subkey2;
	var string sState;
	var string sCategory;
	var string sAction;
	var int		id;
};

struct native constructive ShortcutScriptData
{
	var int id;
	var string sCommand;
	var int sysString;
	var int sysMsg;
};

struct native EventMatchData
{
	var EventMatchTeamData Team[ 2 ];
};

struct native constructive RequestItem
{
	var int id;
	var INT64 amount;
};

struct native constructive PartyMemberInfo
{
	var int creatureID;
	var string name;
	var int curHP;
	var int maxHP;
	var int curMP;
	var int maxMP;
	var int curCP;
	var int maxCP;
	var int vitality;
	var int classID;
	var int level;
	var bool curHavePet;
	var int curSummonNum;
	var int iSubstitute;
};

struct native constructive PartyMemberPetInfo
{
	var int creatureID;
	var int petID;
	var int petClassID;
	var int Type;
	var int petHP;
	var int petMaxHP;
	var int petMP;
	var int petMaxMP;
};
struct native constructive PartyMemberSummonedInfo
{
	var int creatureID;
	var int summonedID;
	var int summonedClassID;
	var int Type;
	var int summonedHP;
	var int summonedMaxHP;
	var int summonedMP;
	var int summonedMaxMP;
};

// 연금술 작업 - by y2jinc (2013. 9. 23)
// @desc : 연금시 사용되는 재료 및 완성 아이템 관련 정보를 담는 Structure.
struct native constructive AlchemyDataInfo
{
	var int			SkillID;
	var int			SkillLevel;
	var int			SkillMaxLevel;
	var bool		GradeType;
	var int			CategoryType;
	var int			StringID;
	var array<int>	RecipeItemClassIDs;
	var array<int>	RecipeItemNums;
	var int			ResultItemClassID;
	var int			ResultItemNum;
};

//branch 110824
//판매대행 등록기간 유료아이템
struct native constructive CommissionPremiumItemInfo
{
	var int commissionItemId;
	var string commissionItemName;
	var int commissionPeriod;
	var int commissionExpired;
	var int commissionDiscountInfoType;	
	var int commissionDiscountInfo;	
};
//end of branch

//branch120516
struct native constructive ProductItem
{
	var int iItemID;
	var int iAmount;
	var int iWeight;
	var int iTradable;
	var string	strDesc;
};
//인게임샵데이터
struct native constructive ProductInfo
{
	var int 	iProductID;
	var int 	iCategory;
	var int 	iPaymentType; //branch121212
	var int		iShowTab;
	var int		iPanel_Type;
	var int		iMinLevel; //branch120703
	var int		iMaxLevel; //branch121212
	var int		iMinBirthday; //branch121212
	var int		iMaxBirthday; //branch121212
	var int		iRestrictionDay; //branch121212
	var int		iAvailableCount; //branch121212
	var int		iSale_Percent;
	var int		iPrice;
	var string	strName;
	var string 	strIconName;
	var int		iDayWeek;
	var int		iStartSale;
	var int		iEndSale;
	var int		iStartHour;
	var int		iStartMin;
	var int		iEndHour;
	var int		iEndMin;
	var int		iStock;
	var int		iMaxStock;
	var bool	bLimited;
	var bool	bEnable;
	var bool	bMyShopBasketEnable;
	var string 	strDesc;
	var string 	strMainSubject;
	var array<ProductItem>	itemarray;
};
//end of branch

// Faction System(#2029) - moonhj
enum EFactionRequsetType
{
	FIRT_NONE,
	FIRT_SHOW,
	FIRT_REFRESH,
};

struct native constructive L2UserFactionUIInfo
{
	var int		nFactionID;
	var int		nFactionLevel;
	var float	fFactionPointRate;
	var bool	bIsFactionLevelLimited;
	var bool	bIsFactionRewardIcon;
};

struct native constructive L2FactionLevelUIData
{
	var int		nFactionLevel;
	var string	strIconTexture;
	var array<int> arrQuestID;
	var array<int> arrQuestLevel;
	var array<string> arrQuestName;

	var array<string> arrFactionRewardTitle;
	var array<string> arrFactionRewardDesc;
	var array<int> arrFactionRewardGroup;
};

struct native constructive L2FactionUIData
{
	var int		nFactionID;
	var string	strFactionName;
	var string	strEmblemTexture;
	var string	strEmblemBigTexture;
	var string	strFactionDesc;
	var array<string> arrFactionNPCName;
	var array<int> arrFactionAreaZoneID;
	var array<string> arrFactionAreaName;
	var array<int> arrFactionAreaLevel;
	var int		nRegionID;				// 월드맵 개선(#3328) - moonhj
	var int		nMonsterbookUse;
	var array<L2FactionLevelUIData>	arrLevelData;
};
// end of Faction System

struct native constructive L2MonsterBookUIData
{
	var int		nMonsterBookID;
	var int		nSortOrder;
	var int		nNpcID;
	var int		nNpcLevel;
	var string	strNpcName;
	var string	strNpcNick;
	var INT64	nNpcHP;
	var INT64	nNpcMP;
	var array<int>		arrNpcProperty;
	var int		nTrophyLevel;	// 단계(별 개수, 4: clear)
	var int		nTrophyCount;	// 현재
	var int		nTrophyMax;		// 목표, Count == Max -> 보상
	var array<int>		arrDropItemID;
	var array<string>	arrDropItemName;	// for search
	var string	strCardTexture;
	var string	strCardPanel;
	var int		nZoneID;
	var string	strZoneName;
	var int		nFactionID;
	var string	strFactionName;
	var string	strFactionEmblem;
	var array<int>		arrRewardFP;
	var array<INT64>	arrRewardExp;
	var array<int>		arrRewardSP;
	var array<int>		arrRewardItem1;
	var array<int>		arrRewardItem2;
	var array<int>		arrRewardItem3;
	var array<int>		arrRewardItem4;
	var int		nViewX;
	var int		nViewY;
	var float	fViewScale;
	var int		nViewRot;
	var int		nViewDist;
};

//branch EP1.0 2014.11.24 luciper3 <http://wallis-devsub/redmine/issues/1217>
// #define RECIPE_OFFERING_ENABLE
struct native constructive OfferingItemList
{
	var int nItemID;
	var INT64 nAmount;
};
//end of branch

// 월드맵 개선(#3326) - moonhj
struct native constructive MinimapRegionIconData
{
	var	string	strIconNormal;
	var	string	strIconOver;
	var	string	strIconPushed;
	var int		nWorldLocX;
	var int		nWorldLocY;
	var int		nWorldLocZ;
	var	int		nWidth;
	var	int		nHeight;
	var	int		nIconOffsetX;
	var	int		nIconOffsetY;
	var	int		nDescOffsetX;
	var	int		nDescOffsetY;
	var	string	strDescFontName;
	var	bool	bIgnoreMouseInput;
};

struct native constructive MinimapRegionInfo
{
	var	EMinimapRegionType	eType;
	var	int		nIndex;
	var	string	strDesc;
	var Color	DescColor;
	var	string	strTooltip;
	var	MinimapRegionIconData	IconData;
};

struct native constructive HuntingZoneUIData
{
	var string		strName;
	var int			nType;
	var int			nMinLevel;
	var int			nMaxLevel;
	var vector		nWorldLoc;
	var	int			nSearchZoneID;
	var int			nRegionID;
	var int			nNpcID;
	var array<int>	arrQuestIDs;
	var int			nInstantZoneID;
};

struct native constructive EventAlarmUIData
{
	var int		nEventID;
	var int		nEventType;
	var string	strNotifyIcon;
	var string	strTitle;
	var int		nStartDate;
	var int		nEndDate;
	var int		nStartTime;
	var int		nEndTime;
	var int     nActivateTime;
	var int     nDeactivateTime;
	var array<int> nEventDay;
	var string	strEventDesc;
	var int		nIntTimeStart;
	var int		nIntTimeEnd;
};

struct native constructive L2UITime
{
	var int		nYear;		//1900년부터 계산
	var int		nMonth;		//0~11
	var int		nDay;		//1~31
	var int		nHour;		//0~23
	var int		nMin;		//0~59
	var int		nSec;		//0~59
	var int		nWeekDay;	//요일(0일~6토)
	var int		nYDay;		//올해 몇번째 날인가(0~365)
};


// for ingame web browser
enum EWebMethodType
{
	EWMT_GET,
	EWMT_POST,
};

struct native constructive WebRequestParam
{
	var bool	bNeedUrlEncode;
	var string	strKey;
	var string	strValue;
};

struct native constructive WebRequestInfo
{
	var EWebMethodType	eMethodType;
	var string	strRequestUrl;
	var string	strNPAuthTokenLoginUrl;
	var array<WebRequestParam>	arrRequestParams;
	var array<WebRequestParam>	arrHeaderParams;
};

// 도움말 개선(#4620)
struct native constructive TutorialIndex
{
	var int ID;
	var int Category;
	var int LevelCount;
	var string Name;
	var int Order;
};

struct native constructive TutorialBody
{
	var string Description;
	var int DisplayType;
};

// 혈맹 미션 시스템(#4596) - by moonhj
struct native constructive PledgeMissionRewardItem
{
	var	int		ItemClassID;
	var	int		ItemCount;
};

struct native constructive PledgeMissionCondition
{
	var	int		PledgeLevel;
	var	string	PledgeMasteryName;
	var	int		MinLevel;
	var	int		MaxLevel;
	var	bool	JobMain;
	var	bool	JobDual;
	var	bool	JobSub;
	var	int		PreMissionID;
	var	int		StartDate;			// ex) 161206 : 2016년 12월 06일
	var int		EndDate;			// StartDate와 동일
	var int		StartTime;			// ex) 1830 : 18시 30분
	var	int		EndTime;			// StartTime과 형식 동일
	var	int		ActivateTime;		// StartTime과 형식 동일
	var	int		DeactivateTime;		// StartTime과 형식 동일
	var	array<int>	AvailableDays;	// ex) {0,5,6} : 일금토 (0:일~6:토), {}(empty) : 모든 요일 가능
};

struct native constructive PledgeMissionUIData
{
	var	int		MissionID;
	var	int		Category;	// 1:일반, 2:심화, 3:업적, 4:이벤트
	var bool	IsRepeat;	// false:일회성, true:반복성

	var	string	MissionName;

	// 수행 조건
	var	PledgeMissionCondition	Condition;
	
	// 완료 조건
	var	string	GoalDesc;
	var	int		GoalCount;

	// 보상 내용
	var	int		RewardPledgeNameValue;	// 혈맹 명성치
	var	int		RewardPVPPoint;			// 개인 명성치
	var	array<PledgeMissionRewardItem>	RewardItems;
};


native function ExecuteEvent( int a_EventID, optional string a_Param );

//Param
native function ParamAdd( out string strParam, string strName, string strValue );
native function ParamAddINT64( out string strParam, string strName, INT64 sValue );
native function bool ParseString( string a_strCmd, string a_strMatch, out string a_strResult );
native function bool ParseInt( string a_strCmd, string a_strMatch, out int a_Result );
native function bool ParseINT64( string a_strCmd, string a_strMatch, out INT64 a_Result );
native function bool ParseFloat( string a_strCmd, string a_strMatch, out float a_Result );

native function RegisterEvent( int ev);
native function RegisterState(string WindowName, string state);
native function SetUIState(string State);
native function MessageBox(string Msg);
native function SMessageBox(int SystemMsgNum);
native function string GetUIState();
defaultproperties
{
}
