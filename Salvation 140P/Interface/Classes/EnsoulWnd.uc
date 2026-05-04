//-----------------------------------------------------------------------------------------------------------
//  신규 집혼 슬롯 UI , 2015-03-11
//
// 담당 UI기획: 조희영, 담당자 시스템 기획 최유리 
//-----------------------------------------------------------------------------------------------------------
class EnsoulWnd extends UICommonAPI;
 
const STATE_INSERT_WEAPON         = "STATE_INSERT_WEAPON";
const STATE_INSERT_ENSOULSTONE    = "STATE_INSERT_ENSOULSTONE";
const STATE_SELECT_ENSOUL         = "STATE_SELECT_ENSOUL";
const STATE_CONFIRM_ENSOUL        = "STATE_CONFIRM_ENSOUL";
const STATE_ASK_OVERWRITE         = "STATE_ASK_OVERWRITE";
const STATE_RESULT                = "STATE_RESULT";

const TEXTBOX_DOT_GAP             = 12;

var WindowHandle  Me;

var TextureHandle EnsoulGroupbox1_Texture;
var TextureHandle EnsoulGroupbox2_Texture;

var ButtonHandle  EnsoulInfo_Button;

var ButtonHandle  EnsoulOK_Button;
var ButtonHandle  EnsoulCancelBtn;

var TextBoxHandle EnsoulDiscription_TextBox;

var WindowHandle  EnsoulProgressWnd;
var TextBoxHandle EnsoulProgressWnd_Title_TextBox;
var ProgressCtrlHandle EnsoulProgressWnd_ProgressBar;

var WindowHandle  EnsoulDefaultWnd;

var TextureHandle EnsoulDefaultWnd_SlotBg1Light_Texture;
var TextureHandle EnsoulDefaultWnd_SlotBg2Light_Texture;
var TextureHandle EnsoulDefaultWnd_SlotBg3Light_Texture;

var TextureHandle EnsoulDefaultWnd_Select1_Texture;
var TextureHandle EnsoulDefaultWnd_Select2_Texture;
var TextureHandle EnsoulDefaultWnd_Groupbox1_Texture;
var TextureHandle EnsoulDefaultWnd_Groupbox2_Texture;
var TextureHandle EnsoulDefaultWnd_Step1_Texture;
var TextureHandle EnsoulDefaultWnd_Step2_Texture;
var TextureHandle EnsoulDefaultWnd_BM_Texture;
var TextureHandle EnsoulDefaultWnd_SlotBg1_Texture;
var TextureHandle EnsoulDefaultWnd_SlotBg2_Texture;
var TextureHandle EnsoulDefaultWnd_SlotBg3_Texture;
var TextureHandle EnsoulDefaultWnd_SlotBg4_Texture;
var TextureHandle EnsoulDefaultWnd_Divider1;
var TextureHandle EnsoulDefaultWnd_Divider2;
var TextureHandle EnsoulDefaultWnd_Divider3;
var TextureHandle EnsoulDefaultWnd_Step1block_Texture;
var TextureHandle EnsoulDefaultWnd_Step2block_Texture;
var TextureHandle EnsoulDefaultWnd_BMblock_Texture;

var ItemWindowHandle EnsoulDefaultWnd_Item1_ItemWnd;
var ItemWindowHandle EnsoulDefaultWnd_Item2_ItemWnd;
var ItemWindowHandle EnsoulDefaultWnd_Item3_ItemWnd;

var ItemWindowHandle EnsoulDefaultWnd_ItemBM_ItemWnd;

var TextBoxHandle EnsoulDefaultWnd_TitleWeapon_TextBox;
var TextBoxHandle EnsoulDefaultWnd_WeaponName_TextBox;
var TextBoxHandle EnsoulDefaultWnd_TitleSoul_TextBox;
var TextBoxHandle EnsoulDefaultWnd_SoulName1_TextBox;
var TextBoxHandle EnsoulDefaultWnd_Soul1_TextBox;
var TextBoxHandle EnsoulDefaultWnd_SoulName2_TextBox;
var TextBoxHandle EnsoulDefaultWnd_Soul2_TextBox;
var TextBoxHandle EnsoulDefaultWnd_SoulName3_TextBox;
var TextBoxHandle EnsoulDefaultWnd_Soul3_TextBox;

var WindowHandle  EnsoulOptionWnd;
var TextureHandle EnsoulOptionWnd_Groupbox1_Texture;
var TextureHandle EnsoulOptionWnd_Groupbox2_Texture;
var TextureHandle EnsoulOptionWnd_Groupbox3_Texture;
var TextureHandle EnsoulOptionWnd_SlotBg1_Texture;
var TextureHandle EnsoulOptionWnd_SlotBg2_Texture;

var ItemWindowHandle EnsoulOptionWnd_ITEM1_ItemWnd;
var ItemWindowHandle EnsoulOptionWnd_ITEM2_ItemWnd;

var TextBoxHandle  EnsoulOptionWnd_TitleWeapon_TextBox;
var TextBoxHandle  EnsoulOptionWnd_WeaponName_TextBox;
var TextBoxHandle  EnsoulOptionWnd_TitleSoul_TextBox;
var TextBoxHandle  EnsoulOptionWnd_SoulName_TextBox;
var TextBoxHandle  EnsoulOptionWnd_Soul_TextBox;
var TextBoxHandle  EnsoulOptionWnd_Souloption_TextBox;
var TextureHandle  EnsoulOptionWnd_ListGroupbox1_Texture;
var TextureHandle  EnsoulOptionWnd_Divider_Texture;
var ListCtrlHandle EnsoulOptionWnd_ListCtrl;
var TextBoxHandle  EnsoulOptionWnd_ChargeTitle_TextBox;
var TextBoxHandle  EnsoulOptionWnd_Charge1_TextBox;
var TextBoxHandle  EnsoulOptionWnd_Charge2_TextBox;
var TextBoxHandle  EnsoulOptionWnd_Charge3_TextBox;

var WindowHandle   EnsouEffectWnd;
var TextBoxHandle  EnsouEffectWnd_TitleBefore_TextBox;
var TextBoxHandle  EnsouEffectWnd_TitleAfter_TextBox;
var TextBoxHandle  EnsouEffectWnd_TitleCharge_TextBox;
var TextBoxHandle  EnsouEffectWnd_Charge1_TextBox;
var TextBoxHandle  EnsouEffectWnd_Charge2_TextBox;
var TextBoxHandle  EnsouEffectWnd_Charge3_TextBox;
var TextureHandle  EnsouEffectWnd_Arrow_Texture;
var TextureHandle  EnsouEffectWnd_ChargeGroupbox_Texture;
var TextureHandle  EnsouEffectWnd_ListGroupbox1_Texture;
var ListCtrlHandle EnsouEffectWnd_Before_ListCtrl;
var TextureHandle  EnsouEffectWnd_ListGroupbox2_Texture;

var ListCtrlHandle EnsouEffectWnd_After_ListCtrl;
var AnimTextureHandle EnsoulProgress_AnimTex;

var WindowHandle DisableWnd;
var WindowHandle EnsoulWnd_ResultWnd;

var L2Util util;
var InventoryWnd inventoryWndScript;
var EnsoulSubWnd EnsoulSubWndScript;

// 서브창 윈도우의 아이템 윈도우 , 무기 집혼석
var ItemWindowHandle EnsoulSubWnd_WeaponItemWindow;
var ItemWindowHandle EnsoulSubWnd_EnsoulItemWindow;

// 집혼창의 상태 단계 
var string currentEnsoulState;

// 1,2,3 -1,  어떤 슬롯을 오픈 해서 집홉 옵션 효과를 선택하게 창을  열었나를 기억
var int currentOpenEnsoulStoneSlot;

// 집혼을 하기 위한 최종 정보

// 0~1 Normal, 2번은 BM 배열
struct ItemEnsoulRequest
{
	var int selectedOptionID;
	var int selectedOptionType;
	var int ensoulStoneServerID;
	var int clientSlotIndex;  // 일반 1,2 , BM은 1
	var int clientSlotType;	  
};

// UI에서 옵션을 선택한 각 설정을 저장한다. 최종 결과에 보내줄 값이 된다. 
var array<ItemEnsoulRequest> itemEnsoulRequestInfo;

// UI 집혼석 슬롯
struct EnsoulStoneSlot
{
	var ItemInfo info;
	// 선택된 옵션 정보
	var EnsoulOptionUIInfo eOptionUIInfo;
	var int slotIndex;
	var int slotType;
};

// 무기에 이미 적용된 옵션 정보를 저장해 놓는다.
var array<EnsoulStoneSlot> alreadyHasOptionSlotArray;

// 현재 선택되어진 슬롯의 정보를 저장한다.
var array<EnsoulOptionUIInfo> selectedOptionSlotArray;

// 옵션 선택창에서 최종 선택한 옵션 정보
var EnsoulOptionUIInfo selectedEnsoulOptionUIInfo;

// 각 슬롯 마다 1~3번 젬스톤 수량을 기억 시킨다.
var array<Int64> slotJamStoneFee;

var int overwriteSlotIndex;
var ItemInfo overwriteItemInfo;

// 무기에 소속된 슬롯 수량 // 일반 슬롯, BM 슬롯 수
var int normalSlotCount, bmSlotCount;

//-----------------------------------------------------------------------------------------------------------
// OnRegisterEvent, OnShow, Hide, OnLoad 부분
//-----------------------------------------------------------------------------------------------------------
function OnRegisterEvent()
{
	// 집혼 창 열기
	RegisterEvent( EV_EnsoulWndShow );
	// 집혼 결과 : param "Result" = 0(실패) or 1(성공)
	RegisterEvent( EV_EnsoulResult );

	RegisterEvent( EV_DialogOK );
	RegisterEvent( EV_DialogCancel );

	RegisterEvent( EV_Restart );
}

function OnShow()
{	
	// 지정한 윈도우를 제외한 닫기 기능 
	getInstanceL2Util().ItemRelationWindowHide(getCurrentWindowName(String(self)));

	//Debug("Array ---------------->" @ inventoryWndScript.getInventoryEnSoulEnableItemArray().length);
	//Debug("Array ---------------->" @ inventoryWndScript.getInventoryEnSoulStoneArray().length);

	//setWindowStateSetting("InsertWeapon");
	//setWindowStateSetting("selectEnsoulState");
	//setWindowStateSetting("checkEnsoulState");
	//setWindowStateSetting(STATE_RESULT);

	setWindowStateSetting(STATE_INSERT_WEAPON);
	GetWindowHandle("EnsoulSubWnd").ShowWindow();		
}

function OnHide()
{
	GetWindowHandle("EnsoulSubWnd").HideWindow();
}

//function OnSetFocus( WindowHandle a_WindowHandle, bool bFocused )
//{
//	if ("EnsoulWnd" == a_WindowHandle.GetWindowName() && bFocused) GetWindowHandle("EnsoulSubWnd").SetFocus();	
//}

function OnLoad()
{
	SetClosingOnESC();

	Initialize();
}

//-----------------------------------------------------------------------------------------------------------
// Initialize
//-----------------------------------------------------------------------------------------------------------
function Initialize()
{
	util                       = L2Util(GetScript("L2Util"));
	inventoryWndScript         = inventoryWnd(GetScript("inventoryWnd"));
	EnsoulSubWndScript         = EnsoulSubWnd(GetScript("EnsoulSubWnd"));

	Me = GetWindowHandle( "EnsoulWnd" );

	EnsoulProgress_AnimTex = GetAnimTextureHandle( "EnsoulWnd.EnsoulWnd_ResultWnd.EnsoulProgress_AnimTex" );

	EnsoulGroupbox1_Texture = GetTextureHandle( "EnsoulWnd.EnsoulGroupbox1_Texture" );
	EnsoulGroupbox2_Texture = GetTextureHandle( "EnsoulWnd.EnsoulGroupbox2_Texture" );
	EnsoulInfo_Button = GetButtonHandle( "EnsoulWnd.EnsoulInfo_Button" );
	EnsoulOK_Button = GetButtonHandle( "EnsoulWnd.EnsoulOK_Button" );
	EnsoulCancelBtn = GetButtonHandle( "EnsoulWnd.EnsoulCancelBtn" );
	EnsoulDiscription_TextBox = GetTextBoxHandle( "EnsoulWnd.EnsoulDiscription_TextBox" );
	EnsoulProgressWnd = GetWindowHandle( "EnsoulWnd.EnsoulProgressWnd" );
	EnsoulProgressWnd_Title_TextBox = GetTextBoxHandle( "EnsoulWnd.EnsoulProgressWnd.EnsoulProgressWnd_Title_TextBox" );
	EnsoulProgressWnd_ProgressBar = GetProgressCtrlHandle("EnsoulWnd.EnsoulProgressWnd.EnsoulProgressWnd_ProgressBar");

	EnsoulDefaultWnd = GetWindowHandle( "EnsoulWnd.EnsoulDefaultWnd" );

	EnsoulDefaultWnd_SlotBg1Light_Texture = GetTextureHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_SlotBg1Light_Texture" );
	EnsoulDefaultWnd_SlotBg2Light_Texture = GetTextureHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_SlotBg2Light_Texture" );
	EnsoulDefaultWnd_SlotBg3Light_Texture = GetTextureHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_SlotBg3Light_Texture" );

	EnsoulDefaultWnd_Select1_Texture = GetTextureHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_Select1_Texture" );
	EnsoulDefaultWnd_Select2_Texture = GetTextureHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_Select2_Texture" );
	EnsoulDefaultWnd_Groupbox1_Texture = GetTextureHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_Groupbox1_Texture" );
	EnsoulDefaultWnd_Groupbox2_Texture = GetTextureHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_Groupbox2_Texture" );
	EnsoulDefaultWnd_Step1_Texture = GetTextureHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_Step1_Texture" );
	EnsoulDefaultWnd_Step2_Texture = GetTextureHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_Step2_Texture" );
	EnsoulDefaultWnd_BM_Texture = GetTextureHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_BM_Texture" );
	EnsoulDefaultWnd_SlotBg1_Texture = GetTextureHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_SlotBg1_Texture" );
	EnsoulDefaultWnd_SlotBg2_Texture = GetTextureHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_SlotBg2_Texture" );
	EnsoulDefaultWnd_SlotBg3_Texture = GetTextureHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_SlotBg3_Texture" );
	EnsoulDefaultWnd_SlotBg4_Texture = GetTextureHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_SlotBg4_Texture" );
	EnsoulDefaultWnd_Divider1 = GetTextureHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_Divider1" );
	EnsoulDefaultWnd_Divider2 = GetTextureHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_Divider2" );
	EnsoulDefaultWnd_Divider3 = GetTextureHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_Divider3" );
	EnsoulDefaultWnd_Step1block_Texture = GetTextureHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_Step1block_Texture" );
	EnsoulDefaultWnd_Step2block_Texture = GetTextureHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_Step2block_Texture" );
	EnsoulDefaultWnd_BMblock_Texture = GetTextureHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_BMblock_Texture" );
	EnsoulDefaultWnd_Item1_ItemWnd = GetItemWindowHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_Item1_ItemWnd" );
	EnsoulDefaultWnd_Item2_ItemWnd = GetItemWindowHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_Item2_ItemWnd" );
	EnsoulDefaultWnd_Item3_ItemWnd = GetItemWindowHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_Item3_ItemWnd" );

	EnsoulDefaultWnd_ItemBM_ItemWnd = GetItemWindowHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_ItemBM_ItemWnd" );
	EnsoulDefaultWnd_TitleWeapon_TextBox = GetTextBoxHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_TitleWeapon_TextBox" );
	EnsoulDefaultWnd_WeaponName_TextBox = GetTextBoxHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_WeaponName_TextBox" );
	EnsoulDefaultWnd_TitleSoul_TextBox = GetTextBoxHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_TitleSoul_TextBox" );
	EnsoulDefaultWnd_SoulName1_TextBox = GetTextBoxHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_SoulName1_TextBox" );
	EnsoulDefaultWnd_Soul1_TextBox = GetTextBoxHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_Soul1_TextBox" );
	EnsoulDefaultWnd_SoulName2_TextBox = GetTextBoxHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_SoulName2_TextBox" );
	EnsoulDefaultWnd_Soul2_TextBox = GetTextBoxHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_Soul2_TextBox" );
	EnsoulDefaultWnd_SoulName3_TextBox = GetTextBoxHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_SoulName3_TextBox" );
	EnsoulDefaultWnd_Soul3_TextBox = GetTextBoxHandle( "EnsoulWnd.EnsoulDefaultWnd.EnsoulDefaultWnd_Soul3_TextBox" );

	EnsoulOptionWnd = GetWindowHandle( "EnsoulWnd.EnsoulOptionWnd" );
	EnsoulOptionWnd_Groupbox1_Texture = GetTextureHandle( "EnsoulWnd.EnsoulOptionWnd.EnsoulOptionWnd_Groupbox1_Texture" );
	EnsoulOptionWnd_Groupbox2_Texture = GetTextureHandle( "EnsoulWnd.EnsoulOptionWnd.EnsoulOptionWnd_Groupbox2_Texture" );
	EnsoulOptionWnd_Groupbox3_Texture = GetTextureHandle( "EnsoulWnd.EnsoulOptionWnd.EnsoulOptionWnd_Groupbox3_Texture" );
	EnsoulOptionWnd_SlotBg1_Texture = GetTextureHandle( "EnsoulWnd.EnsoulOptionWnd.EnsoulOptionWnd_SlotBg1_Texture" );
	EnsoulOptionWnd_SlotBg2_Texture = GetTextureHandle( "EnsoulWnd.EnsoulOptionWnd.EnsoulOptionWnd_SlotBg2_Texture" );
	EnsoulOptionWnd_ITEM1_ItemWnd = GetItemWindowHandle( "EnsoulWnd.EnsoulOptionWnd.EnsoulOptionWnd_ITEM1_ItemWnd" );
	EnsoulOptionWnd_ITEM2_ItemWnd = GetItemWindowHandle( "EnsoulWnd.EnsoulOptionWnd.EnsoulOptionWnd_ITEM2_ItemWnd" );
	EnsoulOptionWnd_TitleWeapon_TextBox = GetTextBoxHandle( "EnsoulWnd.EnsoulOptionWnd.EnsoulOptionWnd_TitleWeapon_TextBox" );
	EnsoulOptionWnd_WeaponName_TextBox = GetTextBoxHandle( "EnsoulWnd.EnsoulOptionWnd.EnsoulOptionWnd_WeaponName_TextBox" );
	EnsoulOptionWnd_TitleSoul_TextBox = GetTextBoxHandle( "EnsoulWnd.EnsoulOptionWnd.EnsoulOptionWnd_TitleSoul_TextBox" );
	EnsoulOptionWnd_SoulName_TextBox = GetTextBoxHandle( "EnsoulWnd.EnsoulOptionWnd.EnsoulOptionWnd_SoulName_TextBox" );
	EnsoulOptionWnd_Soul_TextBox = GetTextBoxHandle( "EnsoulWnd.EnsoulOptionWnd.EnsoulOptionWnd_Soul_TextBox" );
	EnsoulOptionWnd_Souloption_TextBox = GetTextBoxHandle( "EnsoulWnd.EnsoulOptionWnd.EnsoulOptionWnd_Souloption_TextBox" );
	EnsoulOptionWnd_ListGroupbox1_Texture = GetTextureHandle( "EnsoulWnd.EnsoulOptionWnd.EnsoulOptionWnd_ListGroupbox1_Texture" );
	EnsoulOptionWnd_Divider_Texture = GetTextureHandle( "EnsoulWnd.EnsoulOptionWnd.EnsoulOptionWnd_Divider_Texture" );
	EnsoulOptionWnd_ListCtrl = GetListCtrlHandle( "EnsoulWnd.EnsoulOptionWnd.EnsoulOptionWnd_ListCtrl" );
	EnsoulOptionWnd_ChargeTitle_TextBox = GetTextBoxHandle( "EnsoulWnd.EnsoulOptionWnd.EnsoulOptionWnd_ChargeTitle_TextBox" );
	EnsoulOptionWnd_Charge1_TextBox = GetTextBoxHandle( "EnsoulWnd.EnsoulOptionWnd.EnsoulOptionWnd_Charge1_TextBox" );
	EnsoulOptionWnd_Charge2_TextBox = GetTextBoxHandle( "EnsoulWnd.EnsoulOptionWnd.EnsoulOptionWnd_Charge2_TextBox" );
	EnsoulOptionWnd_Charge3_TextBox = GetTextBoxHandle( "EnsoulWnd.EnsoulOptionWnd.EnsoulOptionWnd_Charge3_TextBox" );

	// 최종 확인 윈도우
	EnsouEffectWnd                         = GetWindowHandle ( "EnsoulWnd.EnsouEffectWnd" );
	EnsouEffectWnd_TitleBefore_TextBox     = GetTextBoxHandle( "EnsoulWnd.EnsouEffectWnd.EnsouEffectWnd_TitleBefore_TextBox" );
	EnsouEffectWnd_TitleAfter_TextBox      = GetTextBoxHandle( "EnsoulWnd.EnsouEffectWnd.EnsouEffectWnd_TitleAfter_TextBox" );
	EnsouEffectWnd_TitleCharge_TextBox     = GetTextBoxHandle( "EnsoulWnd.EnsouEffectWnd.EnsouEffectWnd_TitleCharge_TextBox" );
	EnsouEffectWnd_Charge1_TextBox         = GetTextBoxHandle( "EnsoulWnd.EnsouEffectWnd.EnsouEffectWnd_Charge1_TextBox" );
	EnsouEffectWnd_Charge2_TextBox         = GetTextBoxHandle( "EnsoulWnd.EnsouEffectWnd.EnsouEffectWnd_Charge2_TextBox" );
	EnsouEffectWnd_Charge3_TextBox         = GetTextBoxHandle( "EnsoulWnd.EnsouEffectWnd.EnsouEffectWnd_Charge3_TextBox" );
	EnsouEffectWnd_Arrow_Texture           = GetTextureHandle( "EnsoulWnd.EnsouEffectWnd.EnsouEffectWnd_Arrow_Texture" );
	EnsouEffectWnd_ChargeGroupbox_Texture  = GetTextureHandle( "EnsoulWnd.EnsouEffectWnd.EnsouEffectWnd_ChargeGroupbox_Texture" );
	EnsouEffectWnd_ListGroupbox1_Texture   = GetTextureHandle( "EnsoulWnd.EnsouEffectWnd.EnsouEffectWnd_ListGroupbox1_Texture" );
	EnsouEffectWnd_ListGroupbox2_Texture   = GetTextureHandle( "EnsoulWnd.EnsouEffectWnd.EnsouEffectWnd_ListGroupbox2_Texture" );

	EnsoulProgress_AnimTex.Stop();
	EnsoulProgress_AnimTex.HideWindow();

	EnsouEffectWnd_Before_ListCtrl         = GetListCtrlHandle( "EnsoulWnd.EnsouEffectWnd.EnsouEffectWnd_Before_ListCtrl" );
	EnsouEffectWnd_After_ListCtrl          = GetListCtrlHandle( "EnsoulWnd.EnsouEffectWnd.EnsouEffectWnd_After_ListCtrl" );

	DisableWnd = GetWindowHandle( "EnsoulWnd.DisableWnd" );
	EnsoulWnd_ResultWnd = GetWindowHandle( "EnsoulWnd.EnsoulWnd_ResultWnd" );


	// 서브창 무기, 집혼석 아이템 윈도우
	EnsoulSubWnd_WeaponItemWindow = GetItemWindowHandle( "EnsoulSubWnd.EnsoulSubWnd_Item1" );
	EnsoulSubWnd_EnsoulItemWindow = GetItemWindowHandle( "EnsoulSubWnd.EnsoulSubWnd_Item2" );


	//  옵션 선택 리스트 툴팁, 선택 안해도 나오도록
	EnsoulOptionWnd_ListCtrl.SetSelectedSelTooltip(FALSE);	
	EnsoulOptionWnd_ListCtrl.SetAppearTooltipAtMouseX(true);

	EnsouEffectWnd_After_ListCtrl.SetSelectedSelTooltip(FALSE);	
	EnsouEffectWnd_After_ListCtrl.SetAppearTooltipAtMouseX(true);

	EnsouEffectWnd_Before_ListCtrl.SetSelectedSelTooltip(FALSE);	
	EnsouEffectWnd_Before_ListCtrl.SetAppearTooltipAtMouseX(true);

	// DisableWnd
	// EnsoulProgressWnd
	// EnsoulDefaultWnd
	// EnsoulOptionWnd
	// EnsoulWnd_ResultWnd
}

//-----------------------------------------------------------------------------------------------------------
// 기본 컨트롤 참조 함수들 , 슬롯 관련 정보등 위주
//-----------------------------------------------------------------------------------------------------------


// 슬롯 기본 윈도우 리턴
function ItemWindowHandle getItemSlotWindow(int slotIndex)
{
	local ItemWindowHandle targetItemWndow;

	if (slotIndex == 0) targetItemWndow = EnsoulDefaultWnd_Item1_ItemWnd;
	else if (slotIndex == 1) targetItemWndow = EnsoulDefaultWnd_Item2_ItemWnd;
	else if (slotIndex == 2) targetItemWndow = EnsoulDefaultWnd_Item3_ItemWnd;
	else if (slotIndex == 3) targetItemWndow = EnsoulDefaultWnd_ItemBM_ItemWnd;
	else Debug("Error (getItemSlotWindow) : Index is " @ slotIndex);

	return targetItemWndow;
}

// 슬롯 기본 윈도우 리턴
function bool hasItemInSlot(int slotIndex)
{
	local ItemInfo info;
	local bool flag;

	info = getItemSlotInfo(slotIndex);
	//Debug("slotIndex ClassID" @ info.IconName);
	//Debug("isOpendEnsoulSlot(slotIndex)" @ slotIndex @ ":::" @ isOpendEnsoulSlot(slotIndex));
	//return (getItemSlotWindow(slotIndex).GetItemNum() > 0) && !isOpendEnsoulSlot(slotIndex);
	if (getItemSlotWindow(slotindex).GetItemNum() > 0)
	{
		// 해외에서 해제가 들어 가서 추가 (2016-01-14)
		info = getItemSlotInfo(slotIndex);
		// 해당 슬롯에는 아이템 정보가 들어 있지 않고 텍스쳐 정보만 들어 있어서 이걸로 구분한다.
		if (info.IconName != "") flag = true;
	}

	return flag;
}

// 슬롯 아이템 정보 리턴 
function ItemInfo getItemSlotInfo(int slotIndex)
{
	local ItemWindowHandle targetItemWndow;
	local ItemInfo info;

	if (slotIndex == 0) targetItemWndow = EnsoulDefaultWnd_Item1_ItemWnd;
	else if (slotIndex == 1) targetItemWndow = EnsoulDefaultWnd_Item2_ItemWnd;
	else if (slotIndex == 2) targetItemWndow = EnsoulDefaultWnd_Item3_ItemWnd;
	else if (slotIndex == 3) targetItemWndow = EnsoulDefaultWnd_ItemBM_ItemWnd;
	else Debug("Error (getItemSlotWindow) : Index is " @ slotIndex);

	targetItemWndow.GetItem(0, info);
	
	return info;
}

function checkButtonState()
{
	//버튼 상태
	// 취소 버튼 닫기로 세팅
	

	// 646  닫기
	// 1342 취소

	//// 집혼석 슬롯이 한개라도 뭔가 들어 있다면..
	//if (getItemSlotWindow(1).GetItemNum() > 0 ||
	//    getItemSlotWindow(2).GetItemNum() > 0 ||
	//    getItemSlotWindow(3).GetItemNum() > 0)

	//EnsoulOK_Button
}

// 기본 윈도우 초기화
function InitWindows()
{

	// 선택박스
	EnsoulDefaultWnd_Select1_Texture.HideWindow();
	EnsoulDefaultWnd_Select2_Texture.HideWindow();

	// 집혼석 기능, 블럭 박스 (이것들은 show가 가려진 상태)
	EnsoulDefaultWnd_Step1block_Texture.ShowWindow();
	EnsoulDefaultWnd_Step2block_Texture.ShowWindow();
	EnsoulDefaultWnd_BMblock_Texture.ShowWindow();

	//// 이미 무기에 옵션이 되어 있는 슬롯 표시
	//EnsoulDefaultWnd_SlotBg1Light_Texture.HideWindow();
	//EnsoulDefaultWnd_SlotBg2Light_Texture.HideWindow();
	//EnsoulDefaultWnd_SlotBg3Light_Texture.HideWindow();

	// 기본 윈도우
	EnsoulDefaultWnd.HideWindow();
	
	// 옵션 선택 윈도우 
	EnsoulOptionWnd.HideWindow();

	// 최종 체크 윈도우 , 진행할까요? 묻는 윈도우
	EnsouEffectWnd.HideWindow();

	// ok 누르면 보여지게 하는 프로그레시브바
	EnsoulProgressWnd.HideWindow();

	// 최종 결과 겸 물어보기 윈도우로 사용.
	EnsoulWnd_ResultWnd.HideWindow();

	// 클릭 방지
	DisableWnd.HideWindow();

	EnsoulSubWndScript.setLock(false);

	//  OK 버튼
	EnsoulOK_Button.HideWindow();

	// 버튼명 변경	
	EnsoulCancelBtn.SetButtonName(3387);  // 집혼 시작
}

function setWeaponEnsoulOptionSlot(ItemInfo tempInfo)
{
	local int n;

	// 일반 슬롯, BM 슬롯 수 조회
	n = class'UIDATA_ENSOUL'.static.GetEnsoulSlotCount(tempInfo.Id, EIST_NORMAL);

	// 일반 슬롯 갯수, 1,2슬롯 활성화 여부
	if (n == 1)
	{
		EnsoulDefaultWnd_Step1block_Texture.HideWindow();
	}
	else if (n == 2)
	{
		EnsoulDefaultWnd_Step1block_Texture.HideWindow();
		EnsoulDefaultWnd_Step2block_Texture.HideWindow();
	}

	// BM슬롯
	n = class'UIDATA_ENSOUL'.static.GetEnsoulSlotCount(tempInfo.Id, EIST_BM );
	if (n > 0) EnsoulDefaultWnd_BMblock_Texture.HideWindow();
}

// 무기에 열려 있는 슬롯 체크
function bool isOpendEnsoulSlot(int slotIndex)
{
	local bool rValue;

	switch(slotIndex)
	{
		case 1 : rValue = !EnsoulDefaultWnd_Step1block_Texture.IsShowWindow();
		         break;
		case 2 : rValue = !EnsoulDefaultWnd_Step2block_Texture.IsShowWindow();
		         break;
		case 3 : rValue = !EnsoulDefaultWnd_BMblock_Texture.IsShowWindow();
		         break;

        default : Debug("Error isUseEnsoulSlot-> 잘못된 값을 넣었어!");
	}

	return rValue;
}

/**
 *   윈도우 상태 값  
 *   setWindowStateSetting("InsertWeapon");
 *   setWindowStateSetting("selectEnsoulState");
 *   setWindowStateSetting("checkEnsoulState");
 *   setWindowStateSetting("resultEnsoulState");
 *   
 **/
function setWindowStateSetting(string wndStateString)
{
	// 무기 슬롯이 차 있으면 , 1,2 슬롯과 bm슬롯의 텍스쳐 상태를 업데이트한다.
	//local ItemInfo tempInfo;
	//local int i, n;
	//local int cnt;
	//local EnsoulOptionUIInfo eOptionInfo;

	currentEnsoulState = wndStateString;

	if(wndStateString == STATE_INSERT_WEAPON)
	{
		//RequestItemList();
		InitWindows();

		// 각 슬롯 초기화
		clearWeponSlot();
		clearEnsoulStoneSlot();		
		clearEnsoulOptionWnd();

		// 슬롯 세팅 초기화
		itemEnsoulRequestInfo.Length = 0;
		itemEnsoulRequestInfo.Length = 3;

		// Debug("초기화2 STATE_INSERT_WEAPON");

		// 무기 선택박스
		EnsoulDefaultWnd_Select1_Texture.ShowWindow();

		// 기본 윈도우
		EnsoulDefaultWnd.ShowWindow();

		// 서브 인벤토리 무기 탭으로 강제 이동
		// 강제 아래 tabindex가 실행되면 최신 정보로 서브 인벤토리 갱신
		EnsoulSubWndScript.setTabIndex(0);
	
		// 무기 슬롯에 집혼할 무기를 드롭해 주세요.
		EnsoulDiscription_TextBox.SetText(GetSystemMessage(4327));

		if(isChangedWeaponEnsoulOption()) EnsoulCancelBtn.EnableWindow();
		else EnsoulCancelBtn.DisableWindow();

		// 무기에 적용되어 있는 집혼 정보를 UI에서 표시한다.
		//applyWeaponEnsoulInfo(info);
	}
	else if(wndStateString == STATE_INSERT_ENSOULSTONE)
	{
		InitWindows();

		clearEnsoulOptionWnd();

		// 옵션 선택 박스
		EnsoulDefaultWnd_Select2_Texture.ShowWindow();

		// 기본 윈도우
		EnsoulDefaultWnd.ShowWindow();

		if(isChangedWeaponEnsoulOption()) EnsoulCancelBtn.EnableWindow();
		else EnsoulCancelBtn.DisableWindow();

		// 무기 아이템 윈도우 
		if (getItemSlotWindow(0).GetItemNum() > 0)
		{
			setWeaponEnsoulOptionSlot(getItemSlotInfo(0));

			//// 일반 슬롯, BM 슬롯 수 조회
			//n = class'UIDATA_ENSOUL'.static.GetEnsoulSlotCount(tempInfo.Id, EIST_NORMAL);

			//// 일반 슬롯 갯수, 1,2슬롯 활성화 여부
			//if (n == 1)
			//{
			//	EnsoulDefaultWnd_Step1block_Texture.HideWindow();
			//}
			//else if (n == 2)
			//{
			//	EnsoulDefaultWnd_Step1block_Texture.HideWindow();
			//	EnsoulDefaultWnd_Step2block_Texture.HideWindow();
			//}

			//// BM슬롯
			//n = class'UIDATA_ENSOUL'.static.GetEnsoulSlotCount(tempInfo.Id, EIST_BM );
			//if (n > 0) EnsoulDefaultWnd_BMblock_Texture.HideWindow();

			//Debug("bm slot count " @ n);

			// 서브 인벤토리 집혼석 탭으로 강제 이동
			EnsoulSubWndScript.setTabIndex(1);
		}

		// 집혼석 슬롯에 집혼석을 드롭해 주세요.
		EnsoulDiscription_TextBox.SetText(GetSystemMessage(4328));
	}
	else if(wndStateString == STATE_SELECT_ENSOUL)
	{
		InitWindows();

		EnsoulSubWndScript.setLock(true);
		// 옵션 선택 박스
		//EnsoulDefaultWnd_Select2_Texture.ShowWindow();
		// 옵션 선택 윈도우 
		EnsoulOptionWnd.ShowWindow();

		//사용할 집혼 효과를 선택해 주세요.
		EnsoulDiscription_TextBox.SetText(GetSystemMessage(4330));

		// 버튼명 변경
		EnsoulOK_Button.EnableWindow();
		EnsoulOK_Button.ShowWindow();	
		EnsoulOK_Button.SetButtonName(2234); // 등록 

		EnsoulCancelBtn.EnableWindow();
		EnsoulCancelBtn.ShowWindow();
		EnsoulCancelBtn.SetButtonName(141); // 취소
	}
	else if(wndStateString == STATE_CONFIRM_ENSOUL)
	{
		InitWindows();

		EnsoulSubWndScript.setLock(true);
		// 최종 체크 윈도우 , 진행할까요? 묻는 윈도우
		EnsouEffectWnd.ShowWindow();

		EnsoulProgressWnd.HideWindow();
		EnsoulProgressWnd_ProgressBar.HideWindow();

		askEnsoulLastProcess(true);
		
		EnsoulOK_Button.EnableWindow();
		EnsoulOK_Button.ShowWindow();	
		EnsoulOK_Button.SetButtonName(1337); // 확인 

		EnsoulCancelBtn.ShowWindow();
		EnsoulCancelBtn.SetButtonName(141); // 취소

		
	}
 	else if(wndStateString == STATE_RESULT)
	{
		InitWindows();

		EnsoulSubWndScript.setLock(true);

		// 최종 체크 윈도우 , 진행할까요? 묻는 윈도우
		EnsouEffectWnd.ShowWindow();

		// ok 누르면 보여지게 하는 프로그레시브바
		EnsoulProgressWnd.ShowWindow();

		// 최종 결과
		EnsoulWnd_ResultWnd.ShowWindow();

		// 클릭 방지
		DisableWnd.ShowWindow();
	}		
}

//// 버튼의 상태를 체크 
//function ButtonStateCheck()
//{
//	local int nSelect;

//	if (currentEnsoulState == STATE_SELECT_ENSOUL)
//	{
//		// 옵션 선택창에서 리스트 목록을 선택 했으면 ok버튼 활성화
//		nSelect = EnsoulOptionWnd_ListCtrl.GetSelectedIndex();

//		if (nSelect >= 0)
//		{
//			EnsoulOK_Button.EnableWindow();
//		}
//		else
//		{
//			EnsoulOK_Button.DisableWindow();
//		}
//	}
//}

//-----------------------------------------------------------------------------------------------------------
// OnEvent
//-----------------------------------------------------------------------------------------------------------
function OnEvent(int Event_ID, string param)
{
	//debug("Inven Event ID :" $string(Event_ID)$" "$param);
	//debug("Inven Event ID :" $string(Event_ID) );

	switch( Event_ID )
	{
		case EV_EnsoulWndShow:  
			 Me.ShowWindow();
			 break;

		case EV_EnsoulResult :
			 showResult(param);
			 break;

		case EV_DialogOK :
			 break;

		case EV_DialogCancel :
			 break;

		case EV_Restart :
			 break;
	}
}

//-----------------------------------------------------------------------------------------------------------
// OnClickButton
//-----------------------------------------------------------------------------------------------------------
function OnClickButton( string Name )
{
	local LVDataRecord Record;		
	local ItemInfo info;
	//local int nSelect;
	local EnsoulStoneUIInfo refEnsoulStoneUIInfo;

	// Debug("Name" @ Name);
	switch( Name )
	{
		//case "EnsoulInfo_Button":
		//	 OnEnsoulInfo_ButtonClick();
		//	 break;

		//case "EnsoulOK_Button":
		//	 OnEnsoulOK_ButtonClick();
		//	 break;

		//case "EnsoulCancelBtn":
		//	 OnEnsoulCancelBtnClick();
		//	 break;

		//----------------------------------------------------
		// 집혼 옵션 선택창
		case "EnsoulOK_Button":

			// Debug("getCurrentEnsoulState()" @ getCurrentEnsoulState());
			 if (getCurrentEnsoulState() == STATE_SELECT_ENSOUL)
			 {
				 if (EnsoulOptionWnd_ListCtrl.GetSelectedIndex() > -1)
				 {
					EnsoulOptionWnd_ListCtrl.GetSelectedRec(record);

					// record.LVDataList[0].nReserved1  옵션타입
					// record.LVDataList[0].nReserved2  옵션ID
					// Debug("선택옵션 타입:" @ record.LVDataList[0].nReserved1);
					// Debug("선택옵션 ID  :" @ record.LVDataList[0].nReserved2);
					if (record.LVDataList[0].nReserved2 > 0)
					{
						GetEnsoulOptionUIInfo(record.LVDataList[0].nReserved2, selectedEnsoulOptionUIInfo);

						if(EnsoulOptionWnd_ITEM2_ItemWnd.GetItemNum() > 0)
						{
							EnsoulOptionWnd_ITEM2_ItemWnd.GetItem(0, info);

							// 메인창에 옵션이 선택된 집혼석을 적용시킨다.
							if (overwriteSlotIndex > 0)
								applySelectdEnsoulOption(overwriteSlotIndex, info, record.LVDataList[0].nReserved2);
							else
								applySelectdEnsoulOption(currentOpenEnsoulStoneSlot, info, record.LVDataList[0].nReserved2);

							// 집혼석 넣기 가능 상태로 변경 
							setWindowStateSetting(STATE_INSERT_ENSOULSTONE);
						}
					}
				 }
				 else 
				 {
					// 사용할 집혼 효과를 선택해 주세요
					//EnsoulDiscription_TextBox.SetTextColor(getColor(255,0,0));
					EnsoulDiscription_TextBox.SetText(GetSystemMessage(4345));

					// 채팅창에도 출력한다.
					AddSystemMessage(4345);
				 }
			 }
			 // 
			 else if (getCurrentEnsoulState() == STATE_INSERT_ENSOULSTONE)
			 {				
				setWindowStateSetting(STATE_CONFIRM_ENSOUL);

				// 여기 고쳐야 한다. 그냥 넘어 가면 안되고... 슬롯, 재집혼 슬롯을 체크 하여
				// 수정된 또는 새로 들어간 슬롯이 있을 경우만 처리 해야 한다.
			 }
			 // 최종 확인창에서 OK 버튼
			 else if (getCurrentEnsoulState() == STATE_CONFIRM_ENSOUL)
			 {
				EnsoulOK_Button.DisableWindow();
				EnsoulProgressWnd.ShowWindow();
				EnsoulProgressWnd_ProgressBar.ShowWindow();
				EnsoulProgressWnd_ProgressBar.Reset();				
				EnsoulProgressWnd_ProgressBar.SetProgressTime( 1500 );
				
				// 프로그레스 바를 설정 및 초기화.
				EnsoulProgressWnd_ProgressBar.Start();

				EnsoulDiscription_TextBox.SetText(GetSystemMessage(4336));

				Playsound("ItemSound3.enchant_process");
				//setWindowStateSetting(STATE_CONFIRM_ENSOUL);
				//class'EnsoulAPI'.static.RequestItemEnsoul("");
			 }

			 break;

		case "EnsoulCancelBtn":
			 // 최종 확인 단계라면..
			 if(currentEnsoulState == STATE_SELECT_ENSOUL)
			 {
				// 취소 하면 젬스톤 수량도 해당 슬롯에서 삭제 한다.
				//Debug("- slotJamStoneFee currentOpenEnsoulStoneSlot::::" @ currentOpenEnsoulStoneSlot);
				
				slotJamStoneFee[currentOpenEnsoulStoneSlot - 1] = 0;					

				setWindowStateSetting(STATE_INSERT_ENSOULSTONE);
			 }
			 else if(currentEnsoulState == STATE_CONFIRM_ENSOUL)
			 {
				 // 최종 확인창에서 캔슬 버튼
				 if (EnsoulProgressWnd_ProgressBar.IsShowWindow())
				 {			 
					StopSound("ItemSound3.enchant_process");					

					EnsoulDiscription_TextBox.SetText(GetSystemMessage(4335));

					EnsoulProgressWnd_ProgressBar.Stop();
					EnsoulProgressWnd_ProgressBar.Reset();
					EnsoulProgressWnd_ProgressBar.HideWindow();
					EnsoulOK_Button.EnableWindow();
				 }
				 else
				 {
					 setWindowStateSetting(STATE_INSERT_ENSOULSTONE);					 
				 }
			 }
			 // 집혼 시작 
			 else if(currentEnsoulState == STATE_INSERT_ENSOULSTONE ||  currentEnsoulState == STATE_INSERT_WEAPON)
			 {
				if (isChangedWeaponEnsoulOption()) setWindowStateSetting(STATE_CONFIRM_ENSOUL);									
			 }
			 break;


	    // 도움말
		case "EnsoulInfo_Button":
			 // Debug("EnsoulInfo_Button 도움말 " );
			 OnHelpBtnClick();
			 break;

		//--------------------------------------------------
		// 집혼 옵션 덮어 쓰기 수락
		case "OK_Button":
			 //InsertEnsoulStone(currentOpenEnsoulStoneSlot, getItemSlotInfo(currentOpenEnsoulStoneSlot) );
			 //Debug("currentOpenEnsoulStoneSlot" @ currentOpenEnsoulStoneSlot);
			 //Debug("selectedEnsoulOptionUIInfo.optionID" @ selectedEnsoulOptionUIInfo.optionID);
		
  			 //InsertEnsoulStone(2, a_ItemInfo);

			 //applySelectdEnsoulOption(currentOpenEnsoulStoneSlot, getItemSlotInfo(currentOpenEnsoulStoneSlot), selectedEnsoulOptionUIInfo.optionID);

			 // 덮어 쓸 옵션 선택창 열기
			 //InsertEnsoulStone(overwriteSlotIndex, overwriteItemInfo);
			

			 
			 // 덮어 쓰기 전에 해당 슬롯을 삭제하고, 만약 옵션을 확정하지 않고, 취소를 하면 복원해줘야 한다.
			 // removeEnsoulStone(overwriteSlotIndex);

			 //setWindowStateSetting(STATE_SELECT_ENSOUL, overwriteItemInfo);

			 // 옵션 선택창 모드로 변경
			 setWindowStateSetting(STATE_SELECT_ENSOUL);
			
			 GetEnsoulStoneUIInfo(overwriteItemInfo.Id, refEnsoulStoneUIInfo); 

			 Debug("overwriteSlotIndex" @ overwriteSlotIndex);

			 // 재집혼 중이면 빼준다, 두번째 param 은 true는 메세제를 출력 안함 예외 처리
			 // 만약 적용 중이라면 빼주지 않는다.
			 if (overwriteSlotIndex > 0) removeEnsoulStone(overwriteSlotIndex, true);

			 // 무기, 집혼석,  정보로 집혼 옵션 선택창 열기
			 applySelectOptionInEnsoulStone(overwriteSlotIndex, getItemSlotInfo(0), overwriteItemInfo, refEnsoulStoneUIInfo, true);

			 // 재집혼 할꺼냐고 물어 보는 창, 숨기기
			 askOverwriteEnsoulOption(false);

			 break;

		// 집혼 옵션 덮어 쓰기 취소
		case "Cancel_Button":			 
			askOverwriteEnsoulOption(false);
			 //setWindowStateSetting(STATE_INSERT_ENSOULSTONE);
			 break;

		// 결과창 확인
		case "singleOK_Button":

			 // Debug("singleOK_Button");
			 //STATE_RESULT
			 // askOverwriteEnsoulOption(false);
			 // EnsoulProgress_AnimTex.Pause();
			 // EnsoulProgress_AnimTex.HideWindow();
			 setWindowStateSetting(STATE_INSERT_WEAPON);
			 break;

		 //--------------------------------------------------
	}
}

// 도움말 열기 
function OnHelpBtnClick()
{
	local string strParam;

	if (getInstanceUIData().getIsClassicServer())
	{
		ParamAdd(strParam, "FilePath", "..\\L2text_Classic\\blacksmith_ensoul_help_classic.htm");
		ExecuteEvent(EV_ShowHelp, strParam);
	}
	else 
	{		
		ExecuteEvent(EV_ShowHelp, "40");
	}
	//Debug("OnHelpBtnClick:" @strParam);	
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  리스트 클릭 (집혼 효과) - 옵션 선택 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function OnClickListCtrlRecord( string ListCtrlID )
{
	local LVDataRecord Record;		

	local int nSelect;

	// Debug("ListCtrlID" @ ListCtrlID);

	nSelect = EnsoulOptionWnd_ListCtrl.GetSelectedIndex();

	// Debug("nSelect : " @ nSelect);

	if (nSelect >= 0) 
	{  
		EnsoulOptionWnd_ListCtrl.GetSelectedRec(record);

		// Debug("선택한 옵션 타입 :" @ record.LVDataList[0].nReserved1);
	}
}

//-----------------------------------------------------------------------------------------------------------
// OnDropItemSourc, OnDropItem, OnDBClickItem 처리 
//-----------------------------------------------------------------------------------------------------------

// 아이콘을 밖으로 빼낼때..
function OnDropItemSource( String strTarget, ItemInfo info )
{
	//if ( bEnchantbool || bEnchantedbool) return;//인챈 중이거나 인챈 완료 시 

	// Debug( "OnDropItemSource" @ strTarget  @ info.DragSrcName );

	if ( strTarget == "Console")
	{		
		switch (info.DragSrcName  )
		{
			// 무기 
			case "EnsoulDefaultWnd_Item1_ItemWnd":
				 removeWeaponItem();
			 	 break;

			// 집혼석 슬롯 1, 2, BM
			case "EnsoulDefaultWnd_Item2_ItemWnd":
				 removeEnsoulStone(1);
				 break;

			case "EnsoulDefaultWnd_Item3_ItemWnd":
				 removeEnsoulStone(2);
				 break;

		    // BM
			case "EnsoulDefaultWnd_Item3_ItemWnd":
				 removeEnsoulStone(3);
				 break;
		}		
	}
}

// OnDropItem
function OnDropItem( String a_WindowID, ItemInfo a_ItemInfo, int X, int Y)
{	
	local Rect rectWnd;

	// 무기 등록, 집혼석 등록 영역의 사이즈width, height 를 사용
	local Rect DragDropItemRect1, DragDropItemRect2, DragDropItemRect3, DragDropItemRectBM, DragDropItemRectAll;
	
	// 집혼 옵션 선택창에서, 집혼석 넣는 공간
	local Rect OptionSelectEnsoulStoneRect;

	rectWnd = Me.GetRect();	

	// 무기 영역
	DragDropItemRect1        = EnsoulOptionWnd_Groupbox1_Texture.GetRect();	

	// 집혼석 , 1,2,BM슬롯 영역
	DragDropItemRect2        = EnsoulDefaultWnd_Step1block_Texture.GetRect();	
	DragDropItemRect3        = EnsoulDefaultWnd_Step2block_Texture.GetRect();	
	DragDropItemRectBM       = EnsoulDefaultWnd_BMblock_Texture.GetRect();	

	// 2,3, BM 영역 (그룹)
	DragDropItemRectAll      = EnsoulDefaultWnd_Groupbox2_Texture.GetRect();	
	
	// 집혼 옵션 선택창
	// 집혼 옵션 선택창에서, 집혼석 넣는 공간
	OptionSelectEnsoulStoneRect = EnsoulOptionWnd_Groupbox2_Texture.GetRect();   // 전체 그룹 영역


	if (a_ItemInfo.DragSrcName == "EnsoulSubWnd_Item1" || a_ItemInfo.DragSrcName == "EnsoulSubWnd_Item2")
	{
		// Debug("정상적인 보조 인벤에서 드래그 " @ a_WindowID  @ a_ItemInfo.DragSrcName);
		// 계속 진행
	}
	else 
	{
		// Debug("비 정상 인벤에서 드래그: 동작 무시 " @ a_WindowID  @ a_ItemInfo.DragSrcName);
		return;
	}
	
	if (currentEnsoulState == STATE_INSERT_WEAPON || currentEnsoulState == STATE_INSERT_ENSOULSTONE)
	{
		if (X > DragDropItemRect1.nX && X <  DragDropItemRect1.nX + DragDropItemRect1.nWidth && 
			Y > DragDropItemRect1.nY && Y <  DragDropItemRect1.nY + DragDropItemRect1.nHeight) //범위 지정
		{	
			// Debug("무기 무기 윈도우  :::" @ a_WindowID);
			// 무기 추가 
			
			InsertWeapon(a_ItemInfo);
		}		
		// 옵션 창 영역
		else if (X > DragDropItemRect2.nX && X <  DragDropItemRect2.nX + DragDropItemRect2.nWidth && 
			Y > DragDropItemRect2.nY && Y <  DragDropItemRect2.nY + DragDropItemRect2.nHeight) //범위 지정
		{
			// Debug("집혼석 집혼석 1 :::" @ a_WindowID);
			InsertEnsoulStone(1, a_ItemInfo);
		}
		else if (X > DragDropItemRect3.nX && X <  DragDropItemRect3.nX + DragDropItemRect3.nWidth && 
				 Y > DragDropItemRect3.nY && Y <  DragDropItemRect3.nY + DragDropItemRect3.nHeight) //범위 지정
		{
			// Debug("집혼석 집혼석 2  :::" @ a_WindowID);
			InsertEnsoulStone(2, a_ItemInfo);
		}

		else if(X > DragDropItemRectBM.nX && X <  DragDropItemRectBM.nX + DragDropItemRectBM.nWidth && 
				Y > DragDropItemRectBM.nY && Y <  DragDropItemRectBM.nY + DragDropItemRectBM.nHeight) //범위 지정
		{
			// Debug("집혼석 집혼석 BM :::" @ a_WindowID);
			InsertEnsoulStone(3, a_ItemInfo);
		}

		else if(X > DragDropItemRectAll.nX && X <  DragDropItemRectAll.nX + DragDropItemRectAll.nWidth && 
				Y > DragDropItemRectAll.nY && Y <  DragDropItemRectAll.nY + DragDropItemRectAll.nHeight) //범위 지정
		{
			InsertEnsoulStone(-1, a_ItemInfo);
			
			// Debug("** 집혼석 그룹 영역 :::" @ a_WindowID);
		}	
	}
	else if (currentEnsoulState == STATE_SELECT_ENSOUL)
	{
		if(X > OptionSelectEnsoulStoneRect.nX && X <  OptionSelectEnsoulStoneRect.nX + OptionSelectEnsoulStoneRect.nWidth && 
		   Y > OptionSelectEnsoulStoneRect.nY && Y <  OptionSelectEnsoulStoneRect.nY + OptionSelectEnsoulStoneRect.nHeight) //범위 지정
		{
			// Debug("우르차차 " @ currentOpenEnsoulStoneSlot);
			InsertEnsoulStone(currentOpenEnsoulStoneSlot, a_ItemInfo);
		}
	}

	// ButtonStateCheck();
}

// 더블 클릭하면, 무기, 집혼석 슬롯은 삭제
function OnDBClickItem( string ControlName, int index )
{
	//if ( bEnchantbool ) return;
	// Debug( ControlName @ String ( index ));	

	// 무기 
	if ( ControlName == "EnsoulDefaultWnd_Item1_ItemWnd")
	{		
		removeWeaponItem();
	}	
	// 집혼석 슬롯 1, 2, BM
	else if ( ControlName == "EnsoulDefaultWnd_Item2_ItemWnd")
	{		
		removeEnsoulStone(1);
	}	
	else if ( ControlName == "EnsoulDefaultWnd_Item3_ItemWnd")
	{		
		removeEnsoulStone(2);
	}	
	else if ( ControlName == "EnsoulDefaultWnd_ItemBM_ItemWnd")
	{		
		removeEnsoulStone(3);
	}	


	// 집혼 옵션 선택창, 무기를 더블 클릭-> 무기 삭제
	else if ( ControlName == "EnsoulOptionWnd_ITEM1_ItemWnd")
	{		
		// removeWeaponItem();
		// Debug("옵션 선택 무기 - 더블클릭-> 아무것도 안함");
	}
	// 집혼 옵션 선택창, 집혼석 더블 클릭-> 아무 작동 안함
	else if ( ControlName == "EnsoulOptionWnd_ITEM2_ItemWnd")
	{		
		// Debug("옵션 선택 집혼석 - 더블클릭-> 아무것도 안함");
	}
}

function OnRClickItem( String strID, int index )
{
	OnDBClickItem(strID, index);
}

//--------------------------------------------------------------------------------------------------------------------
//  EnsoulDefaultWnd 기본 상태 윈도우, 무기 넣기, 집혼석 넣기, 집혼석 텍스트 채우기 등 
//--------------------------------------------------------------------------------------------------------------------

// 무기 아이템 주고 받기
function InsertWeapon(ItemInfo info)
{
	local string fullName;

	Playsound("ItemSound3.enchant_input");

	setWindowStateSetting(STATE_INSERT_WEAPON);

	// 무기가 아니라면 아무작동 안함.
	if (info.itemType != EItemType.ITEM_WEAPON) return;

	// 이미 다른 무기가 들어 있다면..
	if (EnsoulDefaultWnd_Item1_ItemWnd.GetItemNum() > 0)
	{
		// 보조 아이템 윈도우 에서 무기 아이템원도우 을 -> 집혼 UI 무기 항목 아이템 윈도우에 이동		
		util.ItemWIndow_ItemMoveByIndex(getItemSlotWindow(0), EnsoulSubWnd_WeaponItemWindow, 0);
		
		EnsoulDefaultWnd_WeaponName_TextBox.SetTooltipType("");
		EnsoulDefaultWnd_WeaponName_TextBox.ClearTooltip();
	}

	// 보조 인벤(무기) -> 집혼할 무기 인벤으로 
	util.ItemWIndow_ItemMoveByItemID(EnsoulSubWnd_WeaponItemWindow, getItemSlotWindow(0), info.Id);

	// 무기 이름 출력
	if(info.Id.ClassID > 0)
	{		

		// 일반 슬롯, BM 슬롯 수 갱신
		normalSlotCount = class'UIDATA_ENSOUL'.static.GetEnsoulSlotCount(info.Id, EIST_NORMAL);
		bmSlotCount = class'UIDATA_ENSOUL'.static.GetEnsoulSlotCount(info.Id, EIST_BM );

		// 이미 무기에 옵션이 되어 있는 슬롯 표시 숨김.
		EnsoulDefaultWnd_SlotBg1Light_Texture.HideWindow();
		EnsoulDefaultWnd_SlotBg2Light_Texture.HideWindow();
		EnsoulDefaultWnd_SlotBg3Light_Texture.HideWindow();


		fullName = GetItemNameAll(info);
		//ensoulOptionAllName = GetEnsoulOptionNameAll(info);
		
		//// 인챈트, 옵션, AdditionalName
		//if(info.Enchanted > 0) fullName = "+"$ String(info.Enchanted);	

		//fullName = fullName $ " " $ info.name;

		//if (len(ensoulOptionAllName) > 0) fullName = fullName $ " " $ ensoulOptionAllName $ " ";
		//if (len(info.AdditionalName) > 0) fullName = fullName $ "(" $ info.AdditionalName $ ")";		

		// 무기 이름 "..",  툴팁 추가 
		util.textBox_setToolTipWithShortString(EnsoulDefaultWnd_WeaponName_TextBox, fullName);
			
		// 슬롯 다 삭제..
		clearEnsoulStoneSlot();
		
		// 집혼석 넣는 상태로 변경
		//setWindowStateSetting(STATE_INSERT_ENSOULSTONE, info);
		setWindowStateSetting(STATE_INSERT_ENSOULSTONE);

		//// 무기에 적용되어 있는 집혼 정보를 UI에서 표시한다.
		applyWeaponEnsoulInfo(info);
	}
}

// 집혼석 넣기
function InsertEnsoulStone(int slotIndex, ItemInfo eInfo)
{
	// local int i;

	local EnsoulStoneUIInfo refEnsoulStoneUIInfo;
	// local ItemWindowHandle targetItemWndow;
	local ItemInfo weaponInfo, nullInfo;

	Playsound("ItemSound3.enchant_input");

	if (getItemSlotInfo(0).Id.ClassID <= 0)
	{
		Debug("error : InsertEnsoulStone(..) --> 무기를 넣으세요");
		// 무기를 등록해주세요.
		AddSystemMessage(4326);
		return;
	}

	// 집혼석 타입이 아니라면 처리 안함.
	if (eInfo.ItemSubType != int(EEtcItemType.ITEME_ENSOUL_STONE))
	{
		Debug("error : InsertEnsoulStone(..) --> 집혼석이 아닙니다");
		// 무기를 등록해주세요.
		AddSystemMessage(4329);
		return;
	}

	// 수량성 이면 무조건 1개를 넣은 것으로 처리한다.
	if(IsStackableItem(eInfo.ConsumeType))
	{
		eInfo.ItemNum = 1;
	}

	GetEnsoulStoneUIInfo(eInfo.Id, refEnsoulStoneUIInfo);

	//if (slotIndex == -1) slotIndex = currentOpenEnsoulStoneSlot;
	//else currentOpenEnsoulStoneSlot = slotIndex;

	//Debug(" -> slotIndex - > " @ slotIndex);		
	//Debug("refEnsoulStoneUIInfo.OptionId_Array.Length" @ refEnsoulStoneUIInfo.OptionId_Array.Length);
	//Debug("refEnsoulStoneUIInfo.SlotType" @ refEnsoulStoneUIInfo.SlotType);	
	//Debug("EnsoulDefaultWnd_Item2_ItemWnd.GetItemNum()"  @ EnsoulDefaultWnd_Item2_ItemWnd.GetItemNum() );
	//Debug("EnsoulDefaultWnd_Item3_ItemWnd.GetItemNum()"  @ EnsoulDefaultWnd_Item3_ItemWnd.GetItemNum() );
	
	Debug("넣은 아이템의 슬롯 타입 refEnsoulStoneUIInfo.SlotType" @ refEnsoulStoneUIInfo.SlotType);
	
	// 집혼석 정보 얻기
	if (refEnsoulStoneUIInfo.SlotType == EIST_NORMAL)
	{
		// Debug("checkAlreadyEOptionedSlot해라.." @ slotIndex);
		// Debug("currentOpenEnsoulStoneSlot" @ currentOpenEnsoulStoneSlot);

		// 일반 슬롯이 2개 일때, 1개 일때는 BM슬롯과 동일하게 움직여야 한다.
		if (normalSlotCount >= 2)
		{
			// 1번, 2번, normal 슬롯이 비었다면 1번 슬롯에 넣기.
			if(!hasItemInSlot(1) && !hasItemInSlot(2)) slotIndex = 1;
			else if (slotIndex == 3 || slotIndex == -1) 
			{
				// 1번 슬롯이 비어 있고, 2번이 들어 있다면 1번에 넣기
				if(!hasItemInSlot(1) && hasItemInSlot(2)) slotIndex = 1;
				// 1번 슬롯이 들어 있고, 2번이 비어 있다면 
				else if(hasItemInSlot(1) && !hasItemInSlot(2)) slotIndex = 2;
				else 
				{
					// 잘못된 타입의 슬롯에 집혼석 등록을 시도할 때
					if (slotIndex == 3 && refEnsoulStoneUIInfo.SlotType == EIST_NORMAL)
					{
						// 잘못된 집혼석입니다.
						AddSystemMessage(4349);
					}
					else
					{
						// 등록 가능한 슬롯을 모두 사용했습니다. 단, 재집혼인 경우에는 재집혼할 슬롯에 집혼석을 직접 끌어다 넣을 수 있습니다.
						AddSystemMessage(4350);
					}

					// Debug("중지.."@ slotIndex);
					return;  // 슬롯이 1,2번 차 있으면 아무것도 안한다.
				}
			}
		}
		// 일반 슬롯이 없다면..
		else if (normalSlotCount <= 0)
		{
			// 잘못된 집혼석입니다.
			AddSystemMessage(4349);

			return;  // 슬롯이 없으니 아무것도 안함.
		}
		// 1개 일때 
		else
		{
			// 잘못된 타입의 슬롯에 집혼석 등록을 시도할 때
			if (slotIndex == 3 && refEnsoulStoneUIInfo.SlotType == EIST_NORMAL)
			{
				// 잘못된 집혼석입니다.
				AddSystemMessage(4349);
				return;
			}

			// 있던 없던 무조건 1번 슬롯에...
			slotIndex = 1;
		}


		// Debug("=========== 킹왕짱" @ slotIndex);

		// 무기의 해당 슬롯에 원래 집혼된 옵션 값이 있었다면..
		if (checkAlreadyEOptionedSlot(slotIndex))
		{
			overwriteSlotIndex = slotIndex;
			overwriteItemInfo = eInfo;
			currentOpenEnsoulStoneSlot = slotIndex;
			askOverwriteEnsoulOption(true, eInfo);
			// Debug("덮어쓰기 물어보기!");

			return;
		}
		else
		{
			overwriteSlotIndex = 0;
			overwriteItemInfo = nullInfo;
		}

		// 슬롯이 1,2번 일때만 넣는다.
		if (slotIndex == 1 || slotIndex == 2)
		{
			// 1,2번 일반 슬롯이 비어 있다면..
			//setWindowStateSetting(STATE_SELECT_ENSOUL, eInfo);
			setWindowStateSetting(STATE_SELECT_ENSOUL);

			// 무기 아이템 정보 
			weaponInfo = getItemSlotInfo(0);

			// 기존 슬롯을 무조건 비우고 (무기에 적용 된 거면 비우지 못함) //2016-01-26 해외에서 수정하면서 추가(71824 ttp관련)
			removeEnsoulStone(slotIndex, true);

			currentOpenEnsoulStoneSlot = slotIndex;
			
			// 무기, 집혼석,  정보로 집혼 옵션 선택창 열기
			applySelectOptionInEnsoulStone(currentOpenEnsoulStoneSlot, weaponInfo, eInfo, refEnsoulStoneUIInfo);
			// Debug("Normal Apply!!");
		}
	}
	else if (refEnsoulStoneUIInfo.SlotType == EIST_BM)
	{

		if(bmSlotCount <= 0)
		{
			// 잘못된 집혼석입니다.
			AddSystemMessage(4349);

			return;  // 슬롯이 없으니 아무것도 안함.
		}
		else
		{
			// bm은 하나이기 때문에 무조건 3번 슬롯
			slotIndex = 3;

			// 무기의 해당 슬롯에 원래 집혼된 옵션 값이 있었다면..
			if (checkAlreadyEOptionedSlot(slotIndex))
			{
				overwriteSlotIndex = slotIndex;
				overwriteItemInfo = eInfo;

				askOverwriteEnsoulOption(true, eInfo);
				// Debug("덮어쓰기 물어보기!");
				return;
			}
			else
			{
				overwriteSlotIndex = 0;
				overwriteItemInfo = nullInfo;
			}
			
			currentOpenEnsoulStoneSlot = slotIndex;

			//setWindowStateSetting(STATE_SELECT_ENSOUL, eInfo);
			setWindowStateSetting(STATE_SELECT_ENSOUL);

			// 무기 아이템 정보 
			weaponInfo = getItemSlotInfo(0);

			currentOpenEnsoulStoneSlot = slotIndex;

			// 무기, 집혼석,  정보로 집혼 옵션 선택창 열기

			applySelectOptionInEnsoulStone(currentOpenEnsoulStoneSlot, weaponInfo, eInfo, refEnsoulStoneUIInfo);

			// Debug("BM Apply!!");
		}
	}
}

/**
 *  집혼석 슬롯에 선택된 값을 출력, 삭제 처리
 **/
function setEnsoulSlotText(int slotIndex, EnsoulOptionUIInfo eOptionInfo, optional bool bDelete, optional string applyAddString, optional Color applyColor)
{
	local TextBoxHandle soulNameTextBox, soulDescTextBox;
	local CustomTooltip cTooltip;

	if (slotIndex == 1) 
	{
		soulNameTextBox = EnsoulDefaultWnd_SoulName1_TextBox;
		soulDescTextBox = EnsoulDefaultWnd_Soul1_TextBox;
	}
	else if (slotIndex == 2) 
	{
		soulNameTextBox = EnsoulDefaultWnd_SoulName2_TextBox;
		soulDescTextBox = EnsoulDefaultWnd_Soul2_TextBox;

	}
	else if (slotIndex == 3) 
	{ 
		soulNameTextBox = EnsoulDefaultWnd_SoulName3_TextBox;
		soulDescTextBox = EnsoulDefaultWnd_Soul3_TextBox;
	}

	if (applyColor.R != 0 && applyColor.G != 0 && applyColor.B != 0)
		soulNameTextBox.SetTextColor(applyColor);

	if (bDelete)
	{
		textBoxClear(soulNameTextBox);
		textBoxClear(soulDescTextBox);
	}
	else
	{
		if (eOptionInfo.OptionStep > 0)
		{
			// 아이템 이름
			util.textBox_setToolTipWithShortString(soulNameTextBox, MakeFullSystemMsg(GetSystemMessage(4347), 
																	applyAddString $ eOptionInfo.Name, string(eOptionInfo.OptionStep)));
		}
		else
		{
			util.textBox_setToolTipWithShortString(soulNameTextBox, applyAddString $ eOptionInfo.Name);
		}

		// 설명
		util.textBox_setToolTipWithShortString(soulDescTextBox, eOptionInfo.desc);

		// 설명 툴팁 적용
		addToolTipDrawList(cTooltip, addDrawItemTexture(eOptionInfo.IconPanelTex, false, false, 2));
		addToolTipDrawList(cTooltip, addDrawItemTexture(eOptionInfo.IconTex, false, false, -16));
		
		addToolTipDrawList(cTooltip, addDrawItemText(eOptionInfo.name, util.White, "", false));
		addToolTipDrawList(cTooltip, addDrawItemText(" : ", util.White , "", false));
		addToolTipDrawList(cTooltip, addDrawItemText(eOptionInfo.desc, util.ColorDesc , "", false));
		addToolTipDrawList(cTooltip, addDrawItemBlank(1));  

		soulDescTextBox.SetTooltipType("text");
		soulDescTextBox.SetTooltipCustomType(cTooltip);
	}
}

// 무기 슬롯을 비우고, 아이템이 있다면 서브 아이템 무기창에 다시 넣어준다.
function removeEnsoulStone(int slotIndex, optional bool noSystemMessage)
{
	local ItemWindowHandle  targetItemWnd;
	local TextBoxHandle     soulNameTextBox, soulDescTextBox;
	local EnsoulOptionUIInfo eOptionInfo;
	local ItemInfo tmInfo;

	local ItemEnsoulRequest nullItemEnsoulRequestInfo;  // 초기화용

	// 1번 슬롯이 빠질때 2번 슬롯이 들어 있다면 1번 슬롯으로 이동 할지..
	local bool needSwapSlot;

	// 이미 적용된 효과를 빼려고 하면 안되도록..
	if (getItemSlotWindow(slotIndex).GetItemNum() > 0)
	{
		tmInfo = getItemSlotInfo(slotIndex);

		if (tmInfo.Id.ClassID <= 0 && tmInfo.name == "")
		{
			// 집혼 효과가 적용된 아이템을 빼려고 할때..
			if (noSystemMessage == false) AddSystemMessage(4348);
			return;
		}
	}

	// 취소 하면 젬스톤 수량도 해당 슬롯에서 삭제 한다.
	slotJamStoneFee[slotIndex - 1] = 0;	

	if (slotIndex == 1) 
	{
		targetItemWnd = EnsoulDefaultWnd_Item2_ItemWnd;
		soulNameTextBox = EnsoulDefaultWnd_SoulName1_TextBox;
		soulDescTextBox = EnsoulDefaultWnd_Soul1_TextBox;

		itemEnsoulRequestInfo[0] = nullItemEnsoulRequestInfo;

		// 1번 슬롯을 뺼때, 2번 슬롯이 차 있다면 , 2번 슬롯을 1번으로 이동 시킨다.
		if (itemEnsoulRequestInfo[1].selectedOptionID > 0) needSwapSlot = true;			
		
	}
	else if (slotIndex == 2) 
	{
		targetItemWnd = EnsoulDefaultWnd_Item3_ItemWnd;
		soulNameTextBox = EnsoulDefaultWnd_SoulName2_TextBox;
		soulDescTextBox = EnsoulDefaultWnd_Soul2_TextBox;

		itemEnsoulRequestInfo[1] = nullItemEnsoulRequestInfo;
	}
	else if (slotIndex == 3) 
	{ 
		targetItemWnd = EnsoulDefaultWnd_ItemBM_ItemWnd;
		soulNameTextBox = EnsoulDefaultWnd_SoulName3_TextBox;
		soulDescTextBox = EnsoulDefaultWnd_Soul3_TextBox;

		itemEnsoulRequestInfo[2] = nullItemEnsoulRequestInfo;
	}


	if (slotIndex > 0)
	{
		if (targetItemWnd.GetItemNum() > 0)
		{
			// 지정한 아이템을 외부 인벤토리에 다시 돌려줌.
			util.ItemWIndow_ItemMoveByIndex(targetItemWnd, EnsoulSubWnd_EnsoulItemWindow, 0, true);
			
			// 해당 슬롯 텍스트 박스 초기화
			textBoxClear(soulNameTextBox);
			textBoxClear(soulDescTextBox);
		}	
	}	

	if(isChangedWeaponEnsoulOption()) EnsoulCancelBtn.EnableWindow();
	else EnsoulCancelBtn.DisableWindow();

	// 슬롯을 강제로 빼주면 만약에 원래 값이 있었다면 다시 복원해줘야 한다. 
	if(checkAlreadyEOptionedSlot(slotIndex))
	{
		applyWeaponEnsoulInfo(getItemSlotInfo(0));

		// Debug("슬롯 복원 코드 ");
		return;
	}

	// 1번 슬롯이 빠지고, 2번 슬롯을 1번으로 내리기 
	if(needSwapSlot)
	{
		swapItemWithSubInven(getItemSlotWindow(2), getItemSlotWindow(1), getItemSlotInfo(2));
		
		util.ItemWIndow_ItemMoveByIndex(getItemSlotWindow(2), getItemSlotWindow(1), 0);
		
		// 1번 슬롯에 정보들 갱신하고 텍스트 필드도 갱신 
		itemEnsoulRequestInfo[0] = itemEnsoulRequestInfo[1];
		itemEnsoulRequestInfo[1] = nullItemEnsoulRequestInfo;
		itemEnsoulRequestInfo[0].clientSlotIndex = 1;  // 슬롯 인덱스도 1로 변경.

		GetEnsoulOptionUIInfo(itemEnsoulRequestInfo[0].selectedOptionID, eOptionInfo);
		
		// 1번 슬롯에 정보 갱신, 2번 슬롯 텍스트들 삭제
		setEnsoulSlotText(1, eOptionInfo);
		setEnsoulSlotText(2, eOptionInfo, true);
	}
}

//// 배열에 특정 슬롯이 있다면 삭제 하는 함수
//function removeItemEnsoulRequestInfo()
//{

//}

// 무기 슬롯을 비우고, 아이템이 있다면 서브 아이템 무기창에 다시 넣어준다.
function removeWeaponItem()
{
	if (getItemSlotWindow(0).GetItemNum() > 0)
	{
		// 무기 슬롯 아이템을 외부 인벤토리에 다시 돌려줌.
		util.ItemWIndow_ItemMoveByIndex(getItemSlotWindow(0), EnsoulSubWnd_WeaponItemWindow, 0);

		// 다시 무기 추가 상태로
		setWindowStateSetting(STATE_INSERT_WEAPON);
	}	
}

// 무기 슬롯 삭제
function clearWeponSlot()
{
	getItemSlotWindow(0).Clear();

	// 무기 이름 텍스트 박스 초기화
	textBoxClear(EnsoulDefaultWnd_WeaponName_TextBox);
}

// 집혼석 슬롯들 삭제
function clearEnsoulStoneSlot()
{
	// 집혼석 슬롯들 일반, BM
	getItemSlotWindow(1).Clear();
	getItemSlotWindow(2).Clear();
	getItemSlotWindow(3).Clear();

	textBoxClear(EnsoulDefaultWnd_Soul1_TextBox);
	textBoxClear(EnsoulDefaultWnd_Soul2_TextBox);
	textBoxClear(EnsoulDefaultWnd_Soul3_TextBox);

	textBoxClear(EnsoulDefaultWnd_SoulName1_TextBox);
	textBoxClear(EnsoulDefaultWnd_SoulName2_TextBox);
	textBoxClear(EnsoulDefaultWnd_SoulName3_TextBox);
}

// 지정한 인벤과 아이템 교체
function swapItemWithSubInven(ItemWindowHandle targetItemWnd, ItemWindowHandle subInvenItemWnd, itemInfo info)
{

	
	// 이미 다른 무기가 들어 있다면..
	if (targetItemWnd.GetItemNum() > 0)
	{
		// 보조 아이템 윈도우 에서 무기 아이템원도우 을 -> 집혼 인벤 보조 아이템 윈도우에 이동		
		util.ItemWIndow_ItemMoveByIndex(targetItemWnd, subInvenItemWnd, 0);
	}

	targetItemWnd.Clear();

	// 보조 인벤(집혼) -> 집혼할 옵션이 선택된 인벤으로 적용
	util.ItemWIndow_ItemMoveByItemID(subInvenItemWnd, targetItemWnd, info.Id);
}

// 선택된 집혼 옵션, 적용
function applySelectdEnsoulOption(int slotIndex,ItemInfo eStoneitemInfo, int selectedOptionID)
{
	local ItemWindowHandle targetItemWndow;
	local EnsoulOptionUIInfo eOptionInfo;
	local itemEnsoulRequest tempItemEnsoulRequest;

	targetItemWndow = getItemSlotWindow(slotIndex);
	
	targetItemWndow.Clear();
	targetItemWndow.AddItem(eStoneitemInfo);

	// 보조 인벤에서 타겟 인벤으로 집혼석을 넣는다.
	//swapItemWithSubInven(EnsoulSubWnd_EnsoulItemWindow, targetItemWndow, eStoneitemInfo);

	GetEnsoulOptionUIInfo(selectedOptionID, eOptionInfo);

	// 덮어쓴 경우, (재집혼) 이런 표시를 해준다.
	if (slotIndex == overwriteSlotIndex)
	{
		setEnsoulSlotText(slotIndex, eOptionInfo,,"(" $ GetSystemString(3395) $ ") ", util.ColorYellow);
	}
	else 
	{		
		setEnsoulSlotText(slotIndex, eOptionInfo,,,util.ColorYellow);
	}

	// 슬롯에 현재 적용된 정보를 저장해놓는다.
	selectedOptionSlotArray[slotIndex - 1] = eOptionInfo;
	//Debug("eOptionInfo 이미 옵션된.." @ eOptionInfo.name);

	//Debug("slotIndex" @ slotIndex);
	//Debug("eStoneitemInfo.Id.ServerID" @ eStoneitemInfo.Id.ServerID);
	//Debug("selectedOptionID" @ selectedOptionID);
	//Debug("getSlotIndexForClient(slotIndex)" @ getSlotIndexForClient(slotIndex));
	//Debug("getSlotTypeForClient(slotIndex);" @ getSlotTypeForClient(slotIndex));

	tempItemEnsoulRequest.ensoulStoneServerID = eStoneitemInfo.Id.ServerID;
	tempItemEnsoulRequest.selectedOptionID    = selectedOptionID;

	tempItemEnsoulRequest.selectedOptionType  =	eOptionInfo.optionType;
	tempItemEnsoulRequest.clientSlotIndex     = getSlotIndexForClient(slotIndex);
	tempItemEnsoulRequest.clientSlotType      = getSlotTypeForClient(slotIndex);

	itemEnsoulRequestInfo[slotIndex - 1]      = tempItemEnsoulRequest;

	// Debug("==>itemEnsoulRequestInfo[slotIndex - 1].ensoulStoneServerID"  @ itemEnsoulRequestInfo[slotIndex - 1].ensoulStoneServerID);
}

// 무기의 집혼 정보를 UI에 표시 한다.
function applyWeaponEnsoulInfo(ItemInfo info)
{
	local int n, i , cnt, optionID, rIndex;
	local EnsoulOptionUIInfo optionInfo;
	local ItemInfo esInfo;
	
	alreadyHasOptionSlotArray.Length = 0;

	// 선택된 옵션 값 초기화
	selectedOptionSlotArray.Length = 0;
	selectedOptionSlotArray.Length = 3;

	// 각 슬롯마다 필요 잼스톤 수량
	slotJamStoneFee.Length = 0;
	slotJamStoneFee.Length = 3;
	slotJamStoneFee[0] = 0;
	slotJamStoneFee[1] = 0;
	slotJamStoneFee[2] = 0;

	//itemEnsoulRequestInfo.Length = 0;
	//itemEnsoulRequestInfo.Length = 3;

	// Debug("초기화 applyWeaponEnsoulInfo" );

	//selectedOptionSlotArray[0] = optionInfo;
	//selectedOptionSlotArray[1] = optionInfo;
	//selectedOptionSlotArray[2] = optionInfo;
		
	// 무기에서 집혼 정보를 얻어 온다.
	// Normal, BM 각 타입별
	for(i=EIST_NORMAL; i<EIST_MAX; i++)
	{
		// 각 타입의 옵션 수
		cnt = info.EnsoulOption[i - EIST_NORMAL].OptionArray.Length;

		for(n=EISI_START; n<EISI_START + cnt; n++)
		{
			optionID = info.EnsoulOption[i - EIST_NORMAL].OptionArray[n - EISI_START];

			Debug("무기 조회 optionID" @ optionID);

			// 집혼 옵션에 대한 정보를 읽는다.
			if (optionID > 0) GetEnsoulOptionUIInfo(optionID, optionInfo);
			else continue;
			
			// 무기에 이미 적용되어 있던 옵션을 넣는다.
			if (optionID > 0)
			{
				alreadyHasOptionSlotArray.Length = alreadyHasOptionSlotArray.Length + 1;
				alreadyHasOptionSlotArray[ alreadyHasOptionSlotArray.Length - 1 ].info = info; // 무기 정보
				alreadyHasOptionSlotArray[ alreadyHasOptionSlotArray.Length - 1 ].eOptionUIInfo = optionInfo;
				
				alreadyHasOptionSlotArray[ alreadyHasOptionSlotArray.Length - 1 ].slotType = i;

				// 1,2,3 슬롯으로 index값을 변환
				// bm 슬롯은 1개 이다. 무조건 3이다.
				if(i == EIST_BM) rIndex = 3;
				else rIndex = n;

				alreadyHasOptionSlotArray[ alreadyHasOptionSlotArray.Length - 1 ].slotIndex = rIndex;			
				
				//Debug("무기 옵션 index :" @ alreadyHasOptionSlotArray[ alreadyHasOptionSlotArray.Length - 1 ].slotIndex);						
				//Debug("무기에 옵션이 있다 :" @ optionInfo.name);						
				//Debug("optionType :" @ optionInfo.optionType);

				esInfo.IconName = optionInfo.IconTex;

				// optionInfo.IconTex = 
				// alreadyHasOptionSlotArray[ alreadyHasOptionSlotArray.Length - 1 ].optionInfo
				// esInfo

				if (i == EIST_NORMAL )
				{
					// Debug("일반");
					// 1번째 칸 부터 채우기
					if (n == EISI_START)
					{
						// Debug("n값 "@n);
						if (getItemSlotWindow(1).GetItemNum() == 0)
						{
							// Debug("슬롯 1채우기");
							getItemSlotWindow(1).AddItem(esInfo);
							setEnsoulSlotText(1, optionInfo,,"(" $ GetSystemString(3351) $ ") ", util.ColorLightBrown);
							//EnsoulDefaultWnd_SoulName1_TextBox.SetText(optionInfo.name);
							//EnsoulDefaultWnd_Soul1_TextBox.SetText(optionInfo.desc);
							EnsoulDefaultWnd_SlotBg1Light_Texture.ShowWindow();
						}
					}
					// 2번째 칸
					else
					{
						// Debug("n값 "@n);
						if (getItemSlotWindow(2).GetItemNum() == 0)
						{
							// Debug("슬롯 2채우기");
							getItemSlotWindow(2).AddItem(esInfo);							
							setEnsoulSlotText(2, optionInfo,,"(" $ GetSystemString(3351) $ ") ", util.ColorLightBrown);
							//EnsoulDefaultWnd_SoulName2_TextBox.SetText(optionInfo.name);
							//EnsoulDefaultWnd_Soul2_TextBox.SetText(optionInfo.desc);
							EnsoulDefaultWnd_SlotBg2Light_Texture.ShowWindow();
						}
					}
				}
				// BM 슬롯은 한개이다.
				else if (i == EIST_BM)
				{		
					/// Debug("bm");
					if (getItemSlotWindow(3).GetItemNum() == 0)
					{		
						getItemSlotWindow(3).AddItem(esInfo);
						setEnsoulSlotText(3, optionInfo,,"(" $ GetSystemString(3351) $ ") ", util.ColorLightBrown);
						//EnsoulDefaultWnd_SoulName3_TextBox.SetText(optionInfo.name);
						//EnsoulDefaultWnd_Soul3_TextBox.SetText(optionInfo.desc);
						EnsoulDefaultWnd_SlotBg3Light_Texture.ShowWindow();
					}
				}
			}
		}		
	}
}

// 클라쪽에 다시 보내주어야 하는 슬롯 인덱스
// slotNumber는 
function int getSlotIndexForClient(int slotIndex)
{
	local int rValue;

	if(slotIndex == 1 || slotIndex == 2) rValue = slotIndex; // 일반
	else if(slotIndex == 3) rValue = 1;              // BM
	else Debug("Error : getSlotIndexForClient ->" @ slotIndex);
	return rValue;
}

// 클라쪽에 다시 보내주어야 하는 슬롯 인덱스
// slotNumber는 
function int getSlotTypeForClient(int slotIndex)
{
	local int rValue;

	if(slotIndex == 1 || slotIndex == 2) rValue = EIST_NORMAL;
	else if(slotIndex == 3) rValue = EIST_BM;
	else Debug("Error : getSlotTypeForClient ->" @ slotIndex);
	return rValue;
}

// 집혼석의 옵션을 선택하게 하도록 집혼석의 정보를 세팅한다
function applySelectOptionInEnsoulStone(int slotIndex, ItemInfo weaponInfo, ItemInfo eInfo , EnsoulStoneUIInfo esinfo, optional bool isOverwriteOption)
{
	local EnsoulOptionUIInfo optionInfo;
	local EnsoulFeeUIInfo ensoulFeeInfo;

	local int i;

	local LVDataRecord	record;
	local ItemInfo jamStoneInfo, InvenJamStoneInfo;

	// 다른 슬롯에서 사용한 잼스톤 총합.
	local Int64 decUseJamStone;

	local string jamStoneValueComma;
	
	//Debug("=== esinfo.SlotType == " @ esinfo.SlotType);
	//Debug("=== applySelectOptionInEnsoulStone == " @ slotIndex);

	EnsoulOptionWnd_ListCtrl.DeleteAllItem();
	EnsoulOptionWnd_ListCtrl.ShowWindow();
	
	// 무기, 집혼석 이름
	util.textBox_setToolTipWithShortString(EnsoulOptionWnd_WeaponName_TextBox, weaponInfo.name);
	util.textBox_setToolTipWithShortString(EnsoulOptionWnd_SoulName_TextBox, eInfo.name);

	// 옵션 팝업창에 무기 아이템
	EnsoulOptionWnd_ITEM1_ItemWnd.Clear();
	EnsoulOptionWnd_ITEM1_ItemWnd.AddItem(weaponInfo);

	// 집혼석 아이템
	//EnsoulOptionWnd_ITEM2_ItemWnd.Clear();
	//EnsoulOptionWnd_ITEM2_ItemWnd.AddItem(eInfo);

	//if (getItemSlotWindow(currentOpenEnsoulStoneSlot).GetItemNum() > 0)
	//{
	//	// 집혼 인벤 보조 아이템 윈도우에 이동		
	//	util.ItemWIndow_ItemMoveByIndex(getItemSlotWindow(currentOpenEnsoulStoneSlot), EnsoulSubWnd_EnsoulItemWindow, 0);
	//	// 만약 옵션 선택을 취소 하면 다시 원래의 아이템을 슬롯에 복원해야한다.
	//}

	// 옵션 팝업창에 집혼석 슬롯
	EnsoulOptionWnd_ITEM2_ItemWnd.Clear();
	EnsoulOptionWnd_ITEM2_ItemWnd.AddItem(eInfo);

	//util.textBox_setToolTipWithShortString(EnsoulOptionWnd_SoulName_TextBox, info.name, 168 - TEXTBOX_DOT_GAP);

	Debug("esinfo.OptionId_Array.Length" @ esinfo.OptionId_Array.Length);

	for (i = 0; i < esinfo.OptionId_Array.Length; i++)
	{
		GetEnsoulOptionUIInfo(esinfo.OptionId_Array[i], optionInfo);
		
		//Debug("===============================================");
		//Debug("slotIndex" @ slotIndex);
		//Debug("optionInfo.Name" @ optionInfo.Name);
		//Debug("optionInfo.desc" @ optionInfo.desc);
		//Debug("optionInfo.optionType" @ optionInfo.optionType);

		// 재집혼 되는 경우: 
		// 1.옵션 타입으로 선택할 집혼 목록을 제한 하지 않고, 같은 옵션 아이디가 없으면 사용을 한다.(집혼 단계를 올리는 식으로 사용) 

		// -_-.. 하다 보니.. 덮어쓰기랑 나눌 필요가 없게 된듯..-_-.. 혹시 버그 있을까봐 일단 나둔다. 나중에 버그 없으면 둘이 합치면 되겠다.
		if (isOverwriteOption == true && 
		   	hasSelectedEnsoulOptionTypeOtherSlot(optionInfo.optionType, slotIndex) == false &&
			hasSelectedEnsoulOptionIdOtherSlot(optionInfo.optionID) == false &&
		 	hasWeaponOptionTypeOtherSlot(optionInfo.optionType, slotIndex) == false &&
			hasWeaponOptionIdOtherSlot(optionInfo.optionID) == false)
		{
			record.LVDataList.Length = 1;
			record.LVDataList[0].buseTextColor = True;
			record.LVDataList[0].TextColor = util.ColorDesc;

			if (optionInfo.OptionStep > 0)
			{
				record.LVDataList[0].szData        = makeShortStringByPixel(MakeFullSystemMsg(GetSystemMessage(4347), 
																			optionInfo.Name, string(optionInfo.OptionStep)), 230, "..");
			}
			else
			{
				record.LVDataList[0].szData        = makeShortStringByPixel(optionInfo.Name, 230, "..");
			}
			
			record.LVDataList[0].nReserved1    = optionInfo.optionType;    // 집혼 타입 : 일반, BM
			record.LVDataList[0].nReserved2    = esinfo.OptionId_Array[i]; // 집혼 옵션 ID

			Debug("리스트에 넣는다. .Name" @ optionInfo.Name);
			EnsoulOptionWnd_ListCtrl.InsertRecord(record);
 		}

		// 다른 슬롯에 집혼된 집혼 타입을 선택 못한다.
		// 다른 슬롯에서 선택한 옵션 타입은 중복으로 선택 못하도록 목록에서 뺀다.
		else if (isOverwriteOption == false && 
			   	 hasSelectedEnsoulOptionTypeOtherSlot(optionInfo.optionType, slotIndex) == false && 
				 hasSelectedEnsoulOptionIdOtherSlot(optionInfo.optionID) == false &&
		 		 hasWeaponOptionTypeOtherSlot(optionInfo.optionType, slotIndex) == false &&
				 hasWeaponOptionIdOtherSlot(optionInfo.optionID) == false)

		{
			record.LVDataList.Length = 1;
			record.LVDataList[0].buseTextColor = True;
			record.LVDataList[0].TextColor = util.ColorDesc;

			if (optionInfo.OptionStep > 0)
			{
				record.LVDataList[0].szData        = makeShortStringByPixel(MakeFullSystemMsg(GetSystemMessage(4347), 
																			optionInfo.Name, string(optionInfo.OptionStep)), 230, "..");
			}
			else
			{
				record.LVDataList[0].szData        = makeShortStringByPixel(optionInfo.Name, 230, "..");

			}
			
			record.LVDataList[0].nReserved1    = optionInfo.optionType;    // 집혼 타입 : 일반, BM
			record.LVDataList[0].nReserved2    = esinfo.OptionId_Array[i]; // 집혼 옵션 ID

			EnsoulOptionWnd_ListCtrl.InsertRecord(record);
		}
	}

	// 집혼에 필요한 젬스톤 수량 얻기
	GetEnsoulFeeUIInfo(weaponInfo.CrystalType, checkAlreadyEOptionedSlot(slotIndex), esinfo.SlotType, getSlotIndexForClient(slotIndex), ensoulFeeInfo);
	//GetEnsoulFeeUIInfo(weaponInfo.CrystalType, isChangedOptionSlot(slotIndex), esinfo.SlotType, getSlotIndexForClient(slotIndex), ensoulFeeInfo);

	//Debug("가격 산출 :isChangedOptionSlot(slotIndex) " @ isChangedOptionSlot(slotIndex));
	//Debug(":esinfo.SlotType " @ esinfo.SlotType);
	//Debug("getSlotIndexForClient(slotIndex)" @ getSlotIndexForClient(slotIndex));
	//Debug("ensoulFeeInfo.ItemCount " @ ensoulFeeInfo.ItemCount);

	inventoryWndScript.getInventoryItemInfo(GetItemID(ensoulFeeInfo.nID), InvenJamStoneInfo);

	// 젬스톤 아이템 정보 얻기
	class'UIDATA_ITEM'.static.GetItemInfo(GetItemID(ensoulFeeInfo.nID), jamStoneInfo);

	// 해당 가격 기억 하기
	// Debug("slotIndex" @ slotIndex);
	slotJamStoneFee[slotIndex - 1] = ensoulFeeInfo.ItemCount;

	// 1,2,3번 슬롯에서 사용한 잼스톤 합치기
	for (i = 0; i < 3; i++)
	{
		if (slotIndex != (i + 1))
		{
			decUseJamStone = decUseJamStone + slotJamStoneFee[i];
		}
	}
	
	// Debug("->>>> decUseJamStone " @ decUseJamStone);
	//EnsoulOptionWnd_Charge1_TextBox.SetText(jamStoneInfo.name);
	// 젬스톤 이름 
	util.textBox_setToolTipWithShortString(EnsoulOptionWnd_Charge1_TextBox, jamStoneInfo.name);

	EnsoulOptionWnd_Charge2_TextBox.SetText("x" @ String(ensoulFeeInfo.ItemCount));
	
	//Debug("ensoulFeeInfo.nID" @ ensoulFeeInfo.nID);
	//Debug("ensoulFeeInfo.ItemCount" @ ensoulFeeInfo.ItemCount);

	//Debug("InvenJamStoneInfo.name" @ InvenJamStoneInfo.name);
	//Debug("InvenJamStoneInfo.ItemNum" @ InvenJamStoneInfo.ItemNum);

	EnsoulCancelBtn.EnableWindow();
	if (ensoulFeeInfo.ItemCount <= (InvenJamStoneInfo.ItemNum - decUseJamStone))
	{
		EnsoulOptionWnd_Charge3_TextBox.SetTextColor(getColor(85,170,255,255));		
		EnsoulOK_Button.EnableWindow();
	}
	else
	{
		// 젬스톤이 부족하다는 메세지
		EnsoulOptionWnd_Charge3_TextBox.SetTextColor(getColor(255,0,0,255));		
		EnsoulDiscription_TextBox.SetText(MakeFullSystemMsg(GetSystemMessage(1473), jamStoneInfo.name));
		EnsoulOK_Button.DisableWindow();
	}

	EnsoulOptionWnd_Charge3_TextBox.SetText("(" $ maxCountLimitString(InvenJamStoneInfo.ItemNum - decUseJamStone, 9999, "9999+") $ ")");
	
	if (InvenJamStoneInfo.ItemNum > 9999)
	{
		jamStoneValueComma = MakeCostString(String(InvenJamStoneInfo.ItemNum - decUseJamStone));
		EnsoulOptionWnd_Charge3_TextBox.SetTooltipType("text");
		EnsoulOptionWnd_Charge3_TextBox.SetTooltipText(jamStoneValueComma);
	}
	else
	{
		EnsoulOptionWnd_Charge3_TextBox.SetTooltipType("");
		EnsoulOptionWnd_Charge3_TextBox.SetTooltipText("");
	}

	//decUseJamStone = decUseJamStone + ensoulFeeInfo.ItemCount;
}

// 덥어 쓰기 물어 보기 확인창 세팅
function askOverwriteEnsoulOption(bool bShow, optional ItemInfo info)
{
	local ItemInfo tempInfo;

	if (bShow)
	{
		DisableWnd.ShowWindow();
		DisableWnd.SetFocus();

		tempInfo.IconName = "L2UI_ct1.Icon.ICON_DF_Exclamation";

		//setWindowStateSetting(STATE_ASK_OVERWRITE);
		
		EnsoulWnd_ResultWnd.ShowWindow();
		//233, 171
		EnsoulWnd_ResultWnd.SetWindowSize(233, 250);

		GetWindowHandle( "EnsoulWnd.EnsoulWnd_ResultWnd.OK_Button" ).ShowWindow();
		GetWindowHandle( "EnsoulWnd.EnsoulWnd_ResultWnd.Cancel_Button" ).ShowWindow();
		GetWindowHandle( "EnsoulWnd.EnsoulWnd_ResultWnd.singleOK_Button" ).HideWindow();

		//EnsoulProgress_AnimTex.Pause();
		EnsoulProgress_AnimTex.Stop();		
		EnsoulProgress_AnimTex.HideWindow();
		
		GetItemWindowHandle( "EnsoulWnd.EnsoulWnd_ResultWnd.Result_ItemWnd" ).Clear();
		GetItemWindowHandle( "EnsoulWnd.EnsoulWnd_ResultWnd.Result_ItemWnd" ).AddItem(tempInfo);
		GetItemWindowHandle( "EnsoulWnd.EnsoulWnd_ResultWnd.Result_ItemWnd" ).SetTooltipType("");
		GetItemWindowHandle( "EnsoulWnd.EnsoulWnd_ResultWnd.Result_ItemWnd" ).ClearTooltip();

		// 재집혼 시 기존의 집혼 효과는 더 이상 적용되지 않습니다.\n계속 진행하시겠습니까?
		GetTextBoxHandle( "EnsoulWnd.EnsoulWnd_ResultWnd.Discription_TextBox" ).SetText(GetSystemMessage(4332));
	}
	else
	{
		DisableWnd.HideWindow();		
		EnsoulWnd_ResultWnd.HideWindow();
	}
}

//-----------------------------------------------------------------------------------------------------------------------
// 최종 결과 확인 창 -> 집혼 완료. 실패 처리를 담당한다.
//-----------------------------------------------------------------------------------------------------------------------
// 집혼 결과를 확인 창을 연다.
function confirmResultEnsoulOption(bool bSuccess, ItemInfo info)
{	
	local ItemInfo tempInfo;
	
	setWindowStateSetting(STATE_RESULT);

	//EnsoulWnd_ResultWnd.ShowWindow();
	//EnsoulWnd_ResultWnd.SetFocus();

	if (bSuccess)
	{
		
		EnsoulWnd_ResultWnd.SetWindowSize(233, 200);

		GetWindowHandle( "EnsoulWnd.EnsoulWnd_ResultWnd.OK_Button" ).HideWindow();
		GetWindowHandle( "EnsoulWnd.EnsoulWnd_ResultWnd.Cancel_Button" ).HideWindow();
		GetWindowHandle( "EnsoulWnd.EnsoulWnd_ResultWnd.singleOK_Button" ).ShowWindow();

		// EnsoulProgress_AnimTex.HideWindow();
		// EnsoulProgress_AnimTex.SetTexture("l2ui_ct1.ItemEnchant_DF_Effect_Success_00");
		EnsoulProgress_AnimTex.SetLoopCount(1);
		EnsoulProgress_AnimTex.Stop();
		EnsoulProgress_AnimTex.Play();
		Playsound("ItemSound3.enchant_success");
		EnsoulProgress_AnimTex.ShowWindow();
						
		GetItemWindowHandle( "EnsoulWnd.EnsoulWnd_ResultWnd.Result_ItemWnd" ).Clear();
		GetItemWindowHandle( "EnsoulWnd.EnsoulWnd_ResultWnd.Result_ItemWnd" ).ClearTooltip();
		GetItemWindowHandle( "EnsoulWnd.EnsoulWnd_ResultWnd.Result_ItemWnd" ).AddItem(info);
		GetItemWindowHandle( "EnsoulWnd.EnsoulWnd_ResultWnd.Result_ItemWnd" ).SetTooltipType("Inventory");
		
		// 아이템 집혼에 성공했습니다.  @ info.name
		GetTextBoxHandle( "EnsoulWnd.EnsoulWnd_ResultWnd.Discription_TextBox" ).SetText(GetSystemMessage(4333));
	}
	else
	{
		Playsound("ItemSound3.enchant_fail");

		EnsoulWnd_ResultWnd.SetWindowSize(233, 250);
		
		tempInfo.IconName = "L2UI_ct1.Icon.ICON_DF_Exclamation";

		GetWindowHandle( "EnsoulWnd.EnsoulWnd_ResultWnd.OK_Button" ).HideWindow();
		GetWindowHandle( "EnsoulWnd.EnsoulWnd_ResultWnd.Cancel_Button" ).HideWindow();
		GetWindowHandle( "EnsoulWnd.EnsoulWnd_ResultWnd.singleOK_Button" ).ShowWindow();

		EnsoulProgress_AnimTex.Stop();
		//EnsoulProgress_AnimTex.Pause();
		EnsoulProgress_AnimTex.HideWindow();

		GetItemWindowHandle( "EnsoulWnd.EnsoulWnd_ResultWnd.Result_ItemWnd" ).ShowWindow();
		GetItemWindowHandle( "EnsoulWnd.EnsoulWnd_ResultWnd.Result_ItemWnd" ).Clear();
		GetItemWindowHandle( "EnsoulWnd.EnsoulWnd_ResultWnd.Result_ItemWnd" ).AddItem(tempInfo);
		GetItemWindowHandle( "EnsoulWnd.EnsoulWnd_ResultWnd.Result_ItemWnd" ).SetTooltipType("");
		GetItemWindowHandle( "EnsoulWnd.EnsoulWnd_ResultWnd.Result_ItemWnd" ).ClearTooltip();

		// 시스템 오류로 진행할 수 없습니다. 잠시 후 다시 시도해 주세요.
		GetTextBoxHandle( "EnsoulWnd.EnsoulWnd_ResultWnd.Discription_TextBox" ).SetText(GetSystemMessage(4334));
	}
}

//-----------------------------------------------------------------------------------------------------------------------
// 최종 확인 리포트 -> 진행 여부를 물어 보는 윈도우
//-----------------------------------------------------------------------------------------------------------------------
function askEnsoulLastProcess(bool bShow)
{
	local ItemInfo tempInfo, InvenJamStoneInfo, jamStoneInfo;
	local int i, n;
	local Int64 jamStoneTotalCount;
	local string jamStoneValueComma; 

	local EnsoulFeeUIInfo ensoulFeeInfo;
	local EnsoulOptionUIInfo eOptionInfo;

	jamStoneTotalCount = 0;

	if (bShow)
	{
		EnsouEffectWnd_Before_ListCtrl.DeleteAllItem();
		EnsouEffectWnd_After_ListCtrl.DeleteAllItem();
		
		// 현재 효과 리스트 - 채우기
		for(i = 0; i < alreadyHasOptionSlotArray.Length; i++)
		{
			// 변경된 옵션만 넣기
			if (isChangedOptionSlot(alreadyHasOptionSlotArray[i].slotIndex))
				addListESOption(EnsouEffectWnd_Before_ListCtrl, alreadyHasOptionSlotArray[i].eOptionUIInfo, util.ColorLightBrown);
			else
				addListESOption(EnsouEffectWnd_Before_ListCtrl, alreadyHasOptionSlotArray[i].eOptionUIInfo, util.ColorGray);				
		}

		// 집혼 후 효과 리스트 - 채우기
		for (n = 0; n < 3; n++)
		{
			// 이미 적용된 슬롯인가?
			if (checkAlreadyEOptionedSlot(n + 1))
			{
				//getItemSlotInfo(n + 1)
				//itemEnsoulRequestInfo[n].

				// 바꾼게 있나?
				//getChangedOptionUIInfo(n + 1)
					
				if(isChangedOptionSlot(n + 1))
				{					
					eOptionInfo = getChangedOptionUIInfo(n + 1);
					// Debug("바꾼게 : " @ eOptionInfo.name);
					addListESOption(EnsouEffectWnd_After_ListCtrl, eOptionInfo, util.ColorYellow);					
				}
				// 원래 있던 거라면..
				else
				{
					eOptionInfo = getAlreadyHasOptionUIInfo(n + 1);
					// Debug("원래 있던거냐. : " @ eOptionInfo.name);
					if (eOptionInfo.optionID > 0)
					{
						// Debug("원래 있던거니 회색처리로 넣자: " @ eOptionInfo.name);
						addListESOption(EnsouEffectWnd_After_ListCtrl, eOptionInfo, util.ColorGray);
					}
					else
					{
						// Debug("원래 있던게 아니다. 새로  추가 하자: " @ eOptionInfo.name);
						// 원래 있던 옵션 아이디를 넣어준다.
						eOptionInfo = getAlreadyHasOptionUIInfo(n + 1);
						addListESOption(EnsouEffectWnd_After_ListCtrl, eOptionInfo, util.ColorGray);
					}
				}				
			}
			// 새로 들어간 옵션 아이디
			else
			{				
				eOptionInfo = getChangedOptionUIInfo(n + 1);
				// Debug("새로 시도 : " @ eOptionInfo.name);
				if (eOptionInfo.optionID > 0)
				{
					addListESOption(EnsouEffectWnd_After_ListCtrl, eOptionInfo, util.ColorYellow);					

					// Debug("새로 추가? : " @ eOptionInfo.name);
				}
			}
		}

		// 데이타가 없으면 "집혼 효과 없음" 스트링 찍어 놓음.
		if(EnsouEffectWnd_Before_ListCtrl.GetRecordCount() <= 0) addListString(EnsouEffectWnd_Before_ListCtrl, "  " $ GetSystemString(3393));
		
		// 필요 젬스톤 최종 결과 산출
		for(i = 1; i < 4; i++)
		{
			tempInfo = getItemSlotInfo(i);

			if(tempInfo.Id.ClassID > 0)
			{
				//addListESOption(EnsouEffectWnd_After_ListCtrl, selectedOptionSlotArray[i - 1], util.ColorYellow);
				// 집혼에 필요한 젬스톤 수량 얻기
				// 무기의 크리스탈 타입
				GetEnsoulFeeUIInfo(getItemSlotInfo(0).CrystalType, checkAlreadyEOptionedSlot(i),
								   getSlotTypeForClient(i), getSlotIndexForClient(i), ensoulFeeInfo);
				
				// Debug("#####################################");
				// Debug("isChangedOptionSlot(i)" @  isChangedOptionSlot(i));
				// Debug("최종 결과, 가격 산출");
				
				// Debug("ensoulFeeInfo.ItemCount" @ ensoulFeeInfo.ItemCount);
				// Debug("ensoulFeeInfo.nID" @ ensoulFeeInfo.nID);				

				inventoryWndScript.getInventoryItemInfo(GetItemID(ensoulFeeInfo.nID), InvenJamStoneInfo);

				// 젬스톤 아이템 정보 얻기
				class'UIDATA_ITEM'.static.GetItemInfo(GetItemID(ensoulFeeInfo.nID), jamStoneInfo);
				
				jamStoneTotalCount = jamStoneTotalCount + ensoulFeeInfo.ItemCount;
			}
		}
		
		// 젬스톤 이름
		//EnsouEffectWnd_Charge1_TextBox.SetText(jamStoneInfo.name);
		util.textBox_setToolTipWithShortString(EnsouEffectWnd_Charge1_TextBox, jamStoneInfo.name);

		// 젬스톤 전체 필요 수량 
		EnsouEffectWnd_Charge2_TextBox.SetText("x" @ String(jamStoneTotalCount));

		// 젬스톤 인벤 소유 수량 
		EnsouEffectWnd_Charge3_TextBox.SetText("(" $ maxCountLimitString(InvenJamStoneInfo.ItemNum, 9999, "9999+") $ ")");

		if (InvenJamStoneInfo.ItemNum > 9999)
		{
			jamStoneValueComma = MakeCostString(String(InvenJamStoneInfo.ItemNum));
			EnsouEffectWnd_Charge3_TextBox.SetTooltipType("text");
			EnsouEffectWnd_Charge3_TextBox.SetTooltipText(jamStoneValueComma);
		}
		else
		{
			EnsouEffectWnd_Charge3_TextBox.SetTooltipType("");
			EnsouEffectWnd_Charge3_TextBox.SetTooltipText("");
		}

		// 젬스톤을 필요량 만큼 소유 하고 있나?
		if (ensoulFeeInfo.ItemCount <= InvenJamStoneInfo.ItemNum)
		{
			EnsouEffectWnd_Charge3_TextBox.SetTextColor(getColor(85,170,255,255));
			// 위와 같이 집혼을 진행 하시겠습니까?
			//EnsoulDiscription_TextBox.SetText(MakeFullSystemMsg(GetSystemMessage(4335), jamStoneInfo.name));
			EnsoulDiscription_TextBox.SetText(GetSystemMessage(4335));
			EnsoulOK_Button.EnableWindow();
		}
		else
		{
			EnsouEffectWnd_Charge3_TextBox.SetTextColor(getColor(255,0,0,255));
			// "젬스톤 ".. 부족합니다. 같은 멘트
			EnsoulDiscription_TextBox.SetText(MakeFullSystemMsg(GetSystemMessage(1473), jamStoneInfo.name));
			EnsoulOK_Button.DisableWindow();
		}
	}
	else
	{
		setWindowStateSetting(STATE_INSERT_ENSOULSTONE);
	}
}

function addListESOption(ListCtrlHandle list, EnsoulOptionUIInfo optionInfo, Color applyColor)
{
	local LVDataRecord record;		
	
	record.LVDataList.Length = 1;
	
	record.LVDataList[0].bUseTextColor = true;
	record.LVDataList[0].TextColor = applyColor;

	// 파워 1 단계 <- 뭐 이런식..
	if (optionInfo.OptionStep > 0)
	{
		record.LVDataList[0].szData = "  " $ makeShortStringByPixel(MakeFullSystemMsg(GetSystemMessage(4347), 
															 optionInfo.Name, string(optionInfo.OptionStep)), 230, "..");
	}
	else
	{
		record.LVDataList[0].szData = "  " $makeShortStringByPixel(optionInfo.Name, 230, "..");
	}

	

	record.LVDataList[0].nReserved1    = optionInfo.optionType; // 집혼 타입 : 일반, BM
	record.LVDataList[0].nReserved2    = optionInfo.optionID;   // 집혼 옵션 ID

	list.InsertRecord(record);

	// Debug("확인--------> optionInfo.Name" @ list.GetWindowName() @ ":"@ optionInfo.Name);
}

function addListString(ListCtrlHandle list, string str)
{
	local LVDataRecord record;		
	
	record.LVDataList.Length = 1;
	
	record.LVDataList[0].bUseTextColor = true;
	record.LVDataList[0].TextColor = util.ColorDesc;

	record.LVDataList[0].szData        = str;

	record.LVDataList[0].nReserved1    = 0;
	record.LVDataList[0].nReserved2    = 0;

	list.InsertRecord(record);
}


//-----------------------------------------------------------------------------------------------------------------------
// 기타  
//-----------------------------------------------------------------------------------------------------------------------

// 다이얼로그의 시간이 다했음
function OnProgressTimeUp( string strID )
{
	if( strID == "EnsoulProgressWnd_ProgressBar" )
	{
		EnsoulProgressWnd_ProgressBar.HideWindow();
		requestItemEnsoulProcess();
		// setWindowStateSetting(STATE_RESULT);
	}
}

//  서버에 집혼 요청 보내기
//  집혼 시도 요청 API(EnsoulAPI.uc)
//- RequestItemEnsoul( string strParam )
//- param 구조
//"TargetItemID" : 대상 아이템 서버 ID
//"NumOfChangedSlot" : 바뀐 슬롯 수
//           "SlotType_%d" : 슬롯 타입(ENSOUL_TYPE_NORMAL / ENSOUL_TYPE_BM)
//           "SlotIndex_%d" : 타입별 슬롯 인덱스 번호 (첫 번째 슬롯 1, 두 번째 슬롯 2)
//           "InputItemID_%d" : 집혼석 아이템 서버 ID
//           "OptionID_%d" : 선택한 옵션 ID

function requestItemEnsoulProcess()
{
	local string param;

	param = makeRequestEnsoulParam();

	class'EnsoulAPI'.static.RequestItemEnsoul(param);

	// Debug(" 실행 --- class'EnsoulAPI'.static.RequestItemEnsoul() --> param: " @ param);
}

//  추가 되거나 변한 옵션이 있나?
function bool isChangedWeaponEnsoulOption()
{
	local string param;

	local int NumOfChangedSlot;
	param = makeRequestEnsoulParam();

	parseInt(param, "NumOfChangedSlot", NumOfChangedSlot);

	return NumOfChangedSlot > 0;
}

// param 
function string makeRequestEnsoulParam()
{
	local string param;
	local int i, chanagedCount;
	local int targetWeaponServerID;
	
	chanagedCount = 0;

	// 무기의 서버 아이디
	targetWeaponServerID = getItemSlotInfo(0).Id.ServerID;
	ParamAdd( param, "TargetItemID", string(targetWeaponServerID) );

	for (i = 0; i < itemEnsoulRequestInfo.Length;i++)
	{
		if (itemEnsoulRequestInfo[i].ensoulStoneServerID > 0)
		{	
			ParamAdd( param, "SlotType_"    $ chanagedCount, string(itemEnsoulRequestInfo[i].clientSlotType) );
			ParamAdd( param, "SlotIndex_"   $ chanagedCount, string(itemEnsoulRequestInfo[i].clientSlotIndex) );
			ParamAdd( param, "InputItemID_" $ chanagedCount, string(itemEnsoulRequestInfo[i].ensoulStoneServerID) );
			ParamAdd( param, "OptionID_"    $ chanagedCount, string(itemEnsoulRequestInfo[i].selectedOptionID) );
			chanagedCount++;
		}
	}

	ParamAdd( param, "NumOfChangedSlot", string(chanagedCount));

	return param;
}

// 집혼 결과 보여주는 팝업창
function showResult(string param)
{
	local int resultValue;
	local ItemInfo weaponInfo;

	local int EnsoulOptionNum;
	local int n,i, nEOptionID;
		
	weaponInfo = getItemSlotInfo(0);

	// Debug("이벤트 결과, RequestItemEnsoul 결과 : param" @param);

	ParseInt( param, "Result", resultValue );

	for(i=EIST_NORMAL; i<EIST_MAX; i++)
	{
		ParseInt( param, "EnsoulOptionNum_" $ i , EnsoulOptionNum);

		for(n=EISI_START; n<EISI_START + EnsoulOptionNum; n++)
		{
			ParseInt(param, "EnsoulOptionID_" $ i $ "_" $ n, nEOptionID);
			weaponInfo.EnsoulOption[i - EIST_NORMAL].OptionArray[n - EISI_START] = nEOptionID;
		}
	}

	if (resultValue > 0)
	{
		confirmResultEnsoulOption(true, weaponInfo);
	}
	else
	{
		confirmResultEnsoulOption(false, getItemSlotInfo(0));
	}

}


// 모션이 끝나면 숨기기.
function OnTextureAnimEnd( AnimTextureHandle a_AnimTextureHandle )
{
	switch (a_AnimTextureHandle.GetWindowName())
	{
		case "EnsoulProgress_AnimTex" :  			 
			// 인챈트 것과 동일하게.. 			 
			 a_AnimTextureHandle.HideWindow();
			 //a_AnimTextureHandle.Stop();
			 break;
	}

	Debug("---------------------OnTextureAnimEnd : " @ a_AnimTextureHandle.GetWindowName());
}

// 현재 슬롯에 꼽아서 사용 중인 아이템 과 같은게 있나 체크 , 서브 인벤에서 사용
function bool externalCheckUsingItem(ItemInfo info, optional out int nStackableNum)
{
	local itemInfo innerItemInfo;
	local bool rValue;

	// 무기 슬롯
	if (getItemSlotWindow(0).GetItemNum() > 0)
	{
		getItemSlotWindow(0).GetItem(0, innerItemInfo);
		if (innerItemInfo.Id == Info.Id) rValue = true;
	}

	// 일반 집혼석 슬롯
	if (getItemSlotWindow(1).GetItemNum() > 0)
	{
		getItemSlotWindow(1).GetItem(0, innerItemInfo);
		if (innerItemInfo.Id == Info.Id) 
		{
			rValue = true;
			nStackableNum++;
		}
	}
	if (getItemSlotWindow(2).GetItemNum() > 0)
	{
		getItemSlotWindow(2).GetItem(0, innerItemInfo);
		if (innerItemInfo.Id == Info.Id) 
		{
			rValue = true;
			nStackableNum++;
		}
	}

	// BM
	if (getItemSlotWindow(3).GetItemNum() > 0)
	{
		getItemSlotWindow(3).GetItem(0, innerItemInfo);
		if (innerItemInfo.Id == Info.Id) 
		{
			rValue = true;
			nStackableNum++;
		}
	}

	return rValue;
}

//--------------------------------------------------------------------------------------------------------------
//  조건 체크나 상태 체크 함수
//--------------------------------------------------------------------------------------------------------------

// 해당 옵션값이, 다른 슬롯에서 선택한 옵션Type 있나?
function bool hasSelectedEnsoulOptionTypeOtherSlot(int nSelectedOptionType, optional int exceptionSlotIndex)
{
	local int n;
	local bool rValue;

	local int clientSlotIndex, exceptionSlotType;

	// itemEnsoulRequestInfo 배열의 slotIndex는 1,2,3 이 아니고, normal 1,2 , bm 1 이런식 구성이다	
	if (exceptionSlotIndex >= 3) 
	{
		exceptionSlotType = EIST_BM;
		clientSlotIndex = 1;
	}
	else
	{
		if (exceptionSlotIndex > 0)
		{
			exceptionSlotType = EIST_NORMAL;
			clientSlotIndex = exceptionSlotIndex;
		}
	}

	//Debug("예외 exceptionSlotIndex " @ exceptionSlotIndex);
	//Debug("예외 exceptionSlotType " @ exceptionSlotType);
	//Debug("예외 clientSlotIndex " @ clientSlotIndex);
	//Debug("itemEnsoulRequestInfo.Length" @ itemEnsoulRequestInfo.Length);
	
	for (n = 0; n < itemEnsoulRequestInfo.Length; n++)
	{
		//Debug("====== hasSelectedEnsoulOptionTypeOtherSlot  ======");
		//Debug("itemEnsoulRequestInfo[n].clientSlotType " @ itemEnsoulRequestInfo[n].clientSlotType );
		//Debug("itemEnsoulRequestInfo[n].clientSlotIndex " @ itemEnsoulRequestInfo[n].clientSlotIndex );
		//Debug("itemEnsoulRequestInfo[n].selectedOptionType " @ itemEnsoulRequestInfo[n].selectedOptionType );

		//Debug("exceptionSlotType" @ exceptionSlotType);
		//Debug("clientSlotIndex" @ clientSlotIndex);

		//Debug("nSelectedOptionType " @ nSelectedOptionType);

		if (itemEnsoulRequestInfo[n].clientSlotIndex != clientSlotIndex || itemEnsoulRequestInfo[n].clientSlotType != exceptionSlotType)
		{
			if (itemEnsoulRequestInfo[n].selectedOptionType == nSelectedOptionType)
			{
				rValue = true;
				// Debug("---> 같은 옵션 타입이 있다      : " @ nSelectedOptionType);	
				// Debug("---> 같은 옵션 selectedOptionID : " @ itemEnsoulRequestInfo[n].selectedOptionID);	
				break;
			}
		}
	}   
	return rValue;
}

// 해당 옵션값이, 다른 슬롯에서 선택한 옵션ID 있나?
function bool hasSelectedEnsoulOptionIdOtherSlot(int nSelectedOptionID, optional int exceptionSlotIndex)
{
	local int n;
	local bool rValue;

	local int clientSlotIndex, exceptionSlotType;

	// itemEnsoulRequestInfo 배열의 slotIndex는 1,2,3 이 아니고, normal 1,2 , bm 1 이런식 구성이다	
	if (exceptionSlotIndex >= 3) 
	{
		exceptionSlotType = EIST_BM;
		clientSlotIndex = 1;
	}
	else
	{
		if (exceptionSlotIndex > 0)
		{
			exceptionSlotType = EIST_NORMAL;
			clientSlotIndex = exceptionSlotIndex;
		}
	}

	for (n = 0; n < itemEnsoulRequestInfo.Length; n++)
	{
		if (itemEnsoulRequestInfo[n].clientSlotIndex != clientSlotIndex || itemEnsoulRequestInfo[n].clientSlotType != exceptionSlotType)
		{
			if (itemEnsoulRequestInfo[n].selectedOptionID == nSelectedOptionID)
			{
				rValue = true;
				Debug("---> 같은 옵션 selectedOptionID : " @ itemEnsoulRequestInfo[n].selectedOptionID);	
				break;
			}
		}
	}   
	return rValue;
}

// 이미 무기에 옵션된 슬롯에 해당 옵션이 있는지 여부를 리턴한다.
function bool hasWeaponOptionTypeOtherSlot(int nSelectedOptionType, optional int exceptionSlotIndex)
{
	local int n;
	local bool rValue;

	for (n = 0; n < alreadyHasOptionSlotArray.Length; n++)
	{
		if (alreadyHasOptionSlotArray[n].slotIndex != exceptionSlotIndex || exceptionSlotIndex == 0)
		{
			// 빈 슬롯 상태이라면.. (집혼된 것을 표현하기 위해, Item 껍데기가 들어간 경우다)
			//if (getItemSlotInfo(alreadyHasOptionSlotArray[n].slotIndex).Id.ClassID <= 0)
			//{
				// 무기에 이미 적용된 값을 찾아서 비교한다.
				if(alreadyHasOptionSlotArray[n].eOptionUIInfo.optionType == nSelectedOptionType)
				{
					// Debug("== alreadyHasOptionSlotArray 있다 있어" @ alreadyHasOptionSlotArray[n].eOptionUIInfo.name);
					// Debug("== alreadyHasOptionSlotArray 있다 있어" @ nSelectedOptionType);
					rValue = true;
				}	
			//}
		}
	}

	return rValue;
}

// 무기에 집혼된 해당 옵션ID가 있나?
function bool hasWeaponOptionIdOtherSlot(int applyEOptionID, optional int exceptionSlotIndex)
{
	local int n;
	local bool rValue;

	for (n = 0; n < alreadyHasOptionSlotArray.Length; n++)
	{
		if (alreadyHasOptionSlotArray[n].slotIndex != exceptionSlotIndex || exceptionSlotIndex == 0)
		{
			// 빈 슬롯 상태이라면.. (집혼된 것을 표현하기 위해, Item 껍데기가 들어간 경우다)
			//if (getItemSlotInfo(alreadyHasOptionSlotArray[n].slotIndex).Id.ClassID <= 0)
			//{
				// 무기에 이미 적용된 값을 찾아서 비교한다.
				if(alreadyHasOptionSlotArray[n].eOptionUIInfo.optionID == applyEOptionID)
				{
					rValue = true;
				}	
			//}
		}
	}

	return rValue;
}

// 무기에 집혼된 해당 옵션ID가 있나?, 몇번쨰 슬롯에..
function bool hasWeaponOptionIDInTargetSlot(int slotindex, int applyEOptionID)
{
	local int n;
	local bool rValue;

	for (n = 0; n < alreadyHasOptionSlotArray.Length; n++)
	{
		if (alreadyHasOptionSlotArray[n].slotIndex == slotindex)
		{
			// 무기에 이미 적용된 값을 찾아서 비교한다.
			if(alreadyHasOptionSlotArray[n].eOptionUIInfo.optionID == applyEOptionID)
			{
				rValue = true;
			}	
		}
	}

	return rValue;
}

// 지정한 옵션 슬롯이 변경 되었나?
function bool isChangedOptionSlot(int slotIndex)
{
	local int i, clientSlotIndex, slotType;

	// itemEnsoulRequestInfo 배열의 slotIndex는 1,2,3 이 아니고, normal 1,2 , bm 1 이런식 구성이다	
	if (slotIndex >= 3) 
	{
		slotType = EIST_BM;
		clientSlotIndex = 1;
	}
	else
	{
		slotType = EIST_NORMAL;
		clientSlotIndex = slotIndex;
	}
	
	for (i = 0; i < itemEnsoulRequestInfo.Length;i++)
	{
		if (itemEnsoulRequestInfo[i].clientSlotIndex == clientSlotIndex && itemEnsoulRequestInfo[i].clientSlotType == slotType)
		{
			if (itemEnsoulRequestInfo[i].ensoulStoneServerID > 0) return true;
		}
	}

	return false;
}

// 변경된 슬롯의 옵션 정보를 리턴한다. 
function EnsoulOptionUIInfo getChangedOptionUIInfo(int slotIndex)
{
	local int i, clientSlotIndex, slotType;
	local EnsoulOptionUIInfo rEnsoulStoneUIInfo;

	// itemEnsoulRequestInfo 배열의 slotIndex는 1,2,3 이 아니고, normal 1,2 , bm 1 이런식 구성이다	
	if (slotIndex >= 3) 
	{
		slotType = EIST_BM;
		clientSlotIndex = 1;
	}
	else
	{
		slotType = EIST_NORMAL;
		clientSlotIndex = slotIndex;
	}
	
	for (i = 0; i < itemEnsoulRequestInfo.Length;i++)
	{
		if (itemEnsoulRequestInfo[i].clientSlotIndex == clientSlotIndex && itemEnsoulRequestInfo[i].clientSlotType == slotType)
		{
			if (itemEnsoulRequestInfo[i].ensoulStoneServerID > 0) 
			{
				GetEnsoulOptionUIInfo(itemEnsoulRequestInfo[i].selectedOptionID, rEnsoulStoneUIInfo);

				return rEnsoulStoneUIInfo;
			}
		}
	}

	return rEnsoulStoneUIInfo;
}

// 원래 있던 옵션의 정보를 리턴한다. 
function EnsoulOptionUIInfo getAlreadyHasOptionUIInfo(int slotIndex)
{
	local int i;
	local EnsoulOptionUIInfo rEnsoulStoneUIInfo;
	
	for (i = 0; i < alreadyHasOptionSlotArray.Length;i++)
	{
		if (alreadyHasOptionSlotArray[i].slotIndex == slotIndex)
		{
			return alreadyHasOptionSlotArray[i].eOptionUIInfo;
		}
	}

	return rEnsoulStoneUIInfo;
}


// 이미 옵션된 슬롯인가?
function bool checkAlreadyEOptionedSlot(int slotIndex)
{
	local int n;
	local bool rValue;

	if (slotIndex <= 0) return false;

	for (n = 0; n < alreadyHasOptionSlotArray.Length; n++)
	{
		//alreadyHasOptionSlotArray[n];
		// Debug("옵션된 슬롯 검사..슬롯 번호 검사중.. " @ alreadyHasOptionSlotArray[n].slotIndex);
		// Debug("옵션된 slotIndex " @ slotIndex);
		if (alreadyHasOptionSlotArray[n].slotIndex == slotIndex) 
		{
			// Debug("옵션된 거다..인덱스 리턴 " @ alreadyHasOptionSlotArray[n].slotIndex);
			rValue = true;
		}
		//// 3번 슬롯 부터 bm
		//if (2 < slotIndex && alreadyHasOptionSlotArray[n].clientSlotType == EIST_BM) 
		//{
		//	rValue = true;
		//}
	}   


	// Debug("checkAlreadyEOptionedSlot 옵션 슬롯" @ rValue);
	return rValue;
}

//--------------------------------------------------------------------------------------------------------------
//  UTIL
//--------------------------------------------------------------------------------------------------------------
function textBoxClear(TextBoxHandle txtBox)
{
	txtBox.SetText("");
	txtBox.SetTooltipType("");
	txtBox.SetText("");
}

// 집혼 옵션 선택창 - 초기화
function clearEnsoulOptionWnd()
{
	EnsoulOptionWnd_ITEM1_ItemWnd.Clear();
	EnsoulOptionWnd_ITEM2_ItemWnd.Clear();

	// 텍스트 필드 관련 등을 더 처리 하는게 좋음..
}

// 현재 진행 중인 상태를 리턴한다.
function string getCurrentEnsoulState()
{
	return currentEnsoulState;
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
}
