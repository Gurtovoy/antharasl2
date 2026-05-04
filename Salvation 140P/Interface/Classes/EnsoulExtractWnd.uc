/**-------------------------------------------------------------------------------------------------------------------------------------------------------
 제목 : 룬 해제(집혼 해제 시스템)

 ---------------------------------
  테스트 방법)
 ---------------------------------
	 무기 생성
	//생성 70190

	젬스톤 D그레이드
	//생성 2130 5000

	테스트용 룬 생성
	//생성 29818
	//생성 29905
	//생성 29944    bm
	//생성 29963    추출 불가

	NPC 생성
	//생성 1030512


	오픈 이벤트
	10062* 
 -------------------------------------------------------------------------------------------------------------------------------------------------------**/
class EnsoulExtractWnd extends UICommonAPI;

const OFFSET_X_ICON_TEXTURE=0;
const OFFSET_Y_ICON_TEXTURE=4;
const OFFSET_Y_SECONDLINE = -14;

const TREENAME = "EnsoulExtractWnd.EnsoulExtractResultWnd.NeededItem_TreeCtrl";
const ITEMNAME_TOTAL_WIDTH = 240;
const ROOTNAME = "root";

var WindowHandle Me;

var WindowHandle DisableWnd;
var TextureHandle EnsoulGroupbox1_Texture;
var TextureHandle EnsoulGroupbox2_Texture;
var TextBoxHandle EnsoulExtractDiscription_TextBox;

var WindowHandle  EnsoulExtractProgressWnd;

var ProgressCtrlHandle EnsoulProgressWnd_ProgressBar;

var TextBoxHandle EnsoulProgressWnd_Title_TextBox;

var WindowHandle  EnsoulExtractDefaultWnd;
var ButtonHandle  EnsoulExtractDefaultWnd_extract1_Button;
var ButtonHandle  EnsoulExtractDefaultWnd_extract2_Button;
var ButtonHandle  EnsoulExtractDefaultWnd_extract3_Button;
//var ButtonHandle  EnsoulExtractInfo_Button;
var ButtonHandle  EnsoulExtract_Btn;

var TextureHandle EnsoulExtractDefaultWnd_Select1_Texture;
var TextureHandle EnsoulExtractDefaultWnd_Select2_Texture;
var TextureHandle EnsoulExtractDefaultWnd_Groupbox1_Texture;
var TextureHandle EnsoulExtractDefaultWnd_Groupbox2_Texture;
var TextureHandle EnsoulExtractDefaultWnd_Step1_Texture;
var TextureHandle EnsoulExtractDefaultWnd_Step2_Texture;
var TextureHandle EnsoulExtractDefaultWnd_BM_Texture;
var TextureHandle EnsoulExtractDefaultWnd_SlotBg1_Texture;
//var TextureHandle EnsoulExtractDefaultWnd_SlotBg1Light_Texture;
var TextureHandle EnsoulExtractDefaultWnd_SlotBg2_Texture;
//var TextureHandle EnsoulExtractDefaultWnd_SlotBg2Light_Texture;
var TextureHandle EnsoulExtractDefaultWnd_SlotBg3_Texture;
//var TextureHandle EnsoulExtractDefaultWnd_SlotBg3Light_Texture;
var TextureHandle EnsoulExtractDefaultWnd_SlotBg4_Texture;
var TextureHandle EnsoulExtractDefaultWnd_Divider1;
var TextureHandle EnsoulExtractDefaultWnd_Divider2;
var TextureHandle EnsoulExtractDefaultWnd_Divider3;
var TextureHandle EnsoulExtractDefaultWnd_Step1block_Texture;
var TextureHandle EnsoulExtractDefaultWnd_Step2block_Texture;
var TextureHandle EnsoulExtractDefaultWnd_BMblock_Texture;

var ItemWindowHandle EnsoulExtractDefaultWnd_Item1_ItemWnd;
var ItemWindowHandle EnsoulExtractDefaultWnd_Item2_ItemWnd;
var ItemWindowHandle EnsoulExtractDefaultWnd_Item3_ItemWnd;
var ItemWindowHandle EnsoulExtractDefaultWnd_ItemBM_ItemWnd;

var TextBoxHandle EnsoulExtractDefaultWnd_TitleWeapon_TextBox;
var TextBoxHandle EnsoulExtractDefaultWnd_WeaponName_TextBox;
var TextBoxHandle EnsoulExtractDefaultWnd_TitleSoul_TextBox;
var TextBoxHandle EnsoulExtractDefaultWnd_SoulName1_TextBox;
var TextBoxHandle EnsoulExtractDefaultWnd_Soul1_TextBox;
var TextBoxHandle EnsoulExtractDefaultWnd_SoulName2_TextBox;
var TextBoxHandle EnsoulExtractDefaultWnd_Soul2_TextBox;
var TextBoxHandle EnsoulExtractDefaultWnd_SoulName3_TextBox;
var TextBoxHandle EnsoulExtractDefaultWnd_Soul3_TextBox;

var WindowHandle EnsoulExtractResultWnd;
var ButtonHandle EnsoulExtractInfo_Button;
var ButtonHandle EnsoulOK_Btn;
var ButtonHandle EnsoulCancel_Btn;

var TextureHandle ExtractResultWnd_Groupbox1_Texture;
var TextureHandle ExtractResultWnd_Divider_Texture;
var TextureHandle ExtractResultWnd_ListGroupbox1_Texture;
var TextureHandle ExtractResultWnd_SlotBg1_Texture;

var ItemWindowHandle ExtractResultWnd_ITEM_ItemWnd;

var TextBoxHandle ExtractResultWnd_Title_TextBox;
var TextBoxHandle ExtractResultWnd_Name_TextBox;
var TextBoxHandle ExtractResultWnd_notice_TextBox;
var TextBoxHandle ExtractResultWnd_ChargeTitle_TextBox;

var TreeHandle NeededItem_TreeCtrl;

//var ListCtrlHandle ExtractResultWnd_ListCtrl;

var WindowHandle EnsoulExtractWnd_ResultWnd;

// 서브창 윈도우의 아이템 윈도우 , 무기 집혼석
var ItemWindowHandle EnsoulExtractSubWnd_WeaponItemWindow;
var ItemWindowHandle EnsoulExtractSubWnd_EnsoulItemWindow;

var AnimTextureHandle EnsoulProgress_AnimTex;

var L2Util util;
var EnsoulExtractSubWnd EnsoulExtractSubWndScript;
var InventoryWnd inventoryWndScript;

// 무기에 소속된 슬롯 수량 // 일반 슬롯, BM 슬롯 수
var int normalSlotCount, bmSlotCount;
var int currentSlotIndex, currentSlotType;


// 현재 슬롯 정보
var EnsoulOptionUIInfo ensoulOptionInfoSlot1;
var EnsoulOptionUIInfo ensoulOptionInfoSlot2;
var EnsoulOptionUIInfo ensoulOptionInfoSlotBM;

function OnRegisterEvent()
{
	// UI 오픈 10062
	RegisterEvent( EV_EnsoulExtractionWndShow );

	// 추출 버튼 클릭후 서버에서 오는 추출 성공여부
	RegisterEvent( EV_EnsoulExtractionResult  );
}

function OnShow()
{	
	// 지정한 윈도우를 제외한 닫기 기능 
	getInstanceL2Util().ItemRelationWindowHide(getCurrentWindowName(String(self)));
	GetWindowHandle("EnsoulExtractSubWnd").ShowWindow();		
	initProcess();
}

function initProcess()
{
	DisableWnd.HideWindow();
	// 노란 포커싱 박스텍스쳐 , 아래쪽으로 포커스 이동
	EnsoulExtractDefaultWnd_Select1_Texture.ShowWindow();
	EnsoulExtractDefaultWnd_Select2_Texture.HideWindow();

	// 무기 슬롯
	getItemSlotWindow(0).Clear();
	EnsoulExtractDefaultWnd_WeaponName_TextBox.SetTooltipType("");
	EnsoulExtractDefaultWnd_WeaponName_TextBox.ClearTooltip();
	EnsoulExtractDefaultWnd_WeaponName_TextBox.SetText("");


	// 집혼해제 버튼 숨기기
	EnsoulExtractDefaultWnd_extract1_Button.HideWindow();
	EnsoulExtractDefaultWnd_extract2_Button.HideWindow();
	EnsoulExtractDefaultWnd_extract3_Button.HideWindow();

	// 집혼석(룬) 슬롯 초기화
	clearEnsoulStoneSlot();

	// 프로그레시브바 숨기기
	EnsoulExtractProgressWnd.HideWindow();

	// 기본 윈도우 초기화 (무기 등록을 보이도록)
	EnsoulExtractDefaultWnd.ShowWindow();
	EnsoulExtractResultWnd.HideWindow();
	EnsoulExtractWnd_ResultWnd.HideWindow();

	// 무기창 드래그 잠금 해제
	EnsoulExtractSubWndScript.setLock(false);
	EnsoulExtractSubWndScript.syncInventory();

	// 먼저 룬을 추출할 무기를 등록하고 추출 버튼을 눌러주세요.
	EnsoulExtractDiscription_TextBox.ShowWindow();
	EnsoulExtractDiscription_TextBox.SetText(GetSystemString(3496));
}

function OnHide()
{
	GetWindowHandle("EnsoulExtractSubWnd").HideWindow();
	initProcess();
}


function OnLoad()
{
	SetClosingOnESC();

	Initialize();
	Load();
}

function Initialize()
{
	util                           = L2Util(GetScript("L2Util"));
	inventoryWndScript             = inventoryWnd(GetScript("inventoryWnd"));
	
	EnsoulExtractSubWndScript    = EnsoulExtractSubWnd(GetScript("EnsoulExtractSubWnd"));

	Me = GetWindowHandle( "EnsoulExtractWnd" );

	EnsoulProgress_AnimTex = GetAnimTextureHandle( "EnsoulExtractWnd.EnsoulExtractWnd_ResultWnd.EnsoulProgress_AnimTex" );

	DisableWnd = GetWindowHandle( "EnsoulExtractWnd.DisableWnd" );

	EnsoulGroupbox1_Texture = GetTextureHandle( "EnsoulExtractWnd.EnsoulGroupbox1_Texture" );
	EnsoulGroupbox2_Texture = GetTextureHandle( "EnsoulExtractWnd.EnsoulGroupbox2_Texture" );
	EnsoulExtractDiscription_TextBox = GetTextBoxHandle( "EnsoulExtractWnd.EnsoulExtractDiscription_TextBox" );

	EnsoulExtractProgressWnd = GetWindowHandle( "EnsoulExtractWnd.EnsoulExtractProgressWnd" );
	EnsoulProgressWnd_ProgressBar = GetProgressCtrlHandle("EnsoulExtractWnd.EnsoulExtractProgressWnd.EnsoulProgressWnd_ProgressBar");

	EnsoulProgressWnd_Title_TextBox = GetTextBoxHandle( "EnsoulExtractWnd.EnsoulExtractProgressWnd.EnsoulProgressWnd_Title_TextBox" );

	EnsoulExtractDefaultWnd = GetWindowHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd" );
	EnsoulExtractDefaultWnd_extract1_Button = GetButtonHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_extract1_Button" );
	EnsoulExtractDefaultWnd_extract2_Button = GetButtonHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_extract2_Button" );
	EnsoulExtractDefaultWnd_extract3_Button = GetButtonHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_extract3_Button" );

	EnsoulExtractInfo_Button = GetButtonHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractInfo_Button" );
	EnsoulExtract_Btn = GetButtonHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtract_Btn" );

	EnsoulExtractDefaultWnd_Select1_Texture = GetTextureHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_Select1_Texture" );
	EnsoulExtractDefaultWnd_Select2_Texture = GetTextureHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_Select2_Texture" );
	EnsoulExtractDefaultWnd_Groupbox1_Texture = GetTextureHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_Groupbox1_Texture" );
	EnsoulExtractDefaultWnd_Groupbox2_Texture = GetTextureHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_Groupbox2_Texture" );
	EnsoulExtractDefaultWnd_Step1_Texture = GetTextureHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_Step1_Texture" );
	EnsoulExtractDefaultWnd_Step2_Texture = GetTextureHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_Step2_Texture" );
	EnsoulExtractDefaultWnd_BM_Texture = GetTextureHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_BM_Texture" );
	EnsoulExtractDefaultWnd_SlotBg1_Texture = GetTextureHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_SlotBg1_Texture" );
	//EnsoulExtractDefaultWnd_SlotBg1Light_Texture = GetTextureHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_SlotBg1Light_Texture" );
	EnsoulExtractDefaultWnd_SlotBg2_Texture = GetTextureHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_SlotBg2_Texture" );
	//EnsoulExtractDefaultWnd_SlotBg2Light_Texture = GetTextureHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_SlotBg2Light_Texture" );
	EnsoulExtractDefaultWnd_SlotBg3_Texture = GetTextureHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_SlotBg3_Texture" );
	//EnsoulExtractDefaultWnd_SlotBg3Light_Texture = GetTextureHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_SlotBg3Light_Texture" );
	EnsoulExtractDefaultWnd_SlotBg4_Texture = GetTextureHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_SlotBg4_Texture" );
	EnsoulExtractDefaultWnd_Divider1 = GetTextureHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_Divider1" );
	EnsoulExtractDefaultWnd_Divider2 = GetTextureHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_Divider2" );
	EnsoulExtractDefaultWnd_Divider3 = GetTextureHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_Divider3" );
	EnsoulExtractDefaultWnd_Step1block_Texture = GetTextureHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_Step1block_Texture" );
	EnsoulExtractDefaultWnd_Step2block_Texture = GetTextureHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_Step2block_Texture" );
	EnsoulExtractDefaultWnd_BMblock_Texture = GetTextureHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_BMblock_Texture" );

	EnsoulExtractDefaultWnd_Item1_ItemWnd = GetItemWindowHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_Item1_ItemWnd" );
	EnsoulExtractDefaultWnd_Item2_ItemWnd = GetItemWindowHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_Item2_ItemWnd" );
	EnsoulExtractDefaultWnd_Item3_ItemWnd = GetItemWindowHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_Item3_ItemWnd" );

	EnsoulExtractDefaultWnd_ItemBM_ItemWnd = GetItemWindowHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_ItemBM_ItemWnd" );
	EnsoulExtractDefaultWnd_TitleWeapon_TextBox = GetTextBoxHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_TitleWeapon_TextBox" );
	EnsoulExtractDefaultWnd_WeaponName_TextBox = GetTextBoxHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_WeaponName_TextBox" );
	EnsoulExtractDefaultWnd_TitleSoul_TextBox = GetTextBoxHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_TitleSoul_TextBox" );
	EnsoulExtractDefaultWnd_SoulName1_TextBox = GetTextBoxHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_SoulName1_TextBox" );
	EnsoulExtractDefaultWnd_Soul1_TextBox = GetTextBoxHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_Soul1_TextBox" );
	EnsoulExtractDefaultWnd_SoulName2_TextBox = GetTextBoxHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_SoulName2_TextBox" );
	EnsoulExtractDefaultWnd_Soul2_TextBox = GetTextBoxHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_Soul2_TextBox" );
	EnsoulExtractDefaultWnd_SoulName3_TextBox = GetTextBoxHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_SoulName3_TextBox" );
	EnsoulExtractDefaultWnd_Soul3_TextBox = GetTextBoxHandle( "EnsoulExtractWnd.EnsoulExtractDefaultWnd.EnsoulExtractDefaultWnd_Soul3_TextBox" );

	EnsoulExtractResultWnd = GetWindowHandle( "EnsoulExtractWnd.EnsoulExtractResultWnd" );
	EnsoulExtractInfo_Button = GetButtonHandle( "EnsoulExtractWnd.EnsoulExtractResultWnd.EnsoulExtractInfo_Button" );

	EnsoulOK_Btn = GetButtonHandle( "EnsoulExtractWnd.EnsoulExtractResultWnd.EnsoulOK_Btn" );
	EnsoulCancel_Btn = GetButtonHandle( "EnsoulExtractWnd.EnsoulExtractResultWnd.EnsoulCancel_Btn" );

	ExtractResultWnd_Groupbox1_Texture = GetTextureHandle( "EnsoulExtractWnd.EnsoulExtractResultWnd.ExtractResultWnd_Groupbox1_Texture" );
	ExtractResultWnd_Divider_Texture = GetTextureHandle( "EnsoulExtractWnd.EnsoulExtractResultWnd.ExtractResultWnd_Divider_Texture" );
	ExtractResultWnd_ListGroupbox1_Texture = GetTextureHandle( "EnsoulExtractWnd.EnsoulExtractResultWnd.ExtractResultWnd_ListGroupbox1_Texture" );
	ExtractResultWnd_SlotBg1_Texture = GetTextureHandle( "EnsoulExtractWnd.EnsoulExtractResultWnd.ExtractResultWnd_SlotBg1_Texture" );

	ExtractResultWnd_ITEM_ItemWnd = GetItemWindowHandle( "EnsoulExtractWnd.EnsoulExtractResultWnd.ExtractResultWnd_ITEM_ItemWnd" );
	ExtractResultWnd_Title_TextBox = GetTextBoxHandle( "EnsoulExtractWnd.EnsoulExtractResultWnd.ExtractResultWnd_Title_TextBox" );
	ExtractResultWnd_Name_TextBox = GetTextBoxHandle( "EnsoulExtractWnd.EnsoulExtractResultWnd.ExtractResultWnd_Name_TextBox" );
	ExtractResultWnd_notice_TextBox = GetTextBoxHandle( "EnsoulExtractWnd.EnsoulExtractResultWnd.ExtractResultWnd_notice_TextBox" );
	ExtractResultWnd_ChargeTitle_TextBox = GetTextBoxHandle( "EnsoulExtractWnd.EnsoulExtractResultWnd.ExtractResultWnd_ChargeTitle_TextBox" );
	//ExtractResultWnd_ListCtrl = GetListCtrlHandle( "EnsoulExtractWnd.EnsoulExtractResultWnd.ExtractResultWnd_ListCtrl" );

	NeededItem_TreeCtrl = GetTreeHandle("EnsoulExtractWnd.EnsoulExtractResultWnd.NeededItem_TreeCtrl");

	EnsoulExtractWnd_ResultWnd = GetWindowHandle( "EnsoulExtractWnd.EnsoulExtractWnd_ResultWnd" );


	// 서브창 무기, 집혼석 아이템 윈도우
	EnsoulExtractSubWnd_WeaponItemWindow = GetItemWindowHandle( "EnsoulExtractSubWnd.EnsoulSubWnd_Item1" );
	EnsoulExtractSubWnd_EnsoulItemWindow = GetItemWindowHandle( "EnsoulExtractSubWnd.EnsoulSubWnd_Item2" );

	// 결과 창, 버튼, 확인 버튼 하나만 보이도록..
	GetWindowHandle( "EnsoulExtractWnd.EnsoulExtractWnd_ResultWnd.OK_Button" ).HideWindow();
	GetWindowHandle( "EnsoulExtractWnd.EnsoulExtractWnd_ResultWnd.Cancel_Button" ).HideWindow();
	GetWindowHandle( "EnsoulExtractWnd.EnsoulExtractWnd_ResultWnd.singleOK_Button" ).ShowWindow();

}

function Load()
{
}

//-----------------------------------------------------------------------------------------------------------
// OnEvent
//-----------------------------------------------------------------------------------------------------------
function OnEvent(int Event_ID, string param)
{
	debug("Inven Event ID :" $string(Event_ID)$" "$param);
	debug("Inven Event ID :" $string(Event_ID) );

	switch( Event_ID )
	{
		case EV_EnsoulExtractionWndShow:  
			 Me.ShowWindow();
			 break;

		case EV_EnsoulExtractionResult :
			 Debug("EV_EnsoulExtractionResult"@ param);
			 showResult(param);
			 break;

		//case EV_DialogOK :
		//	 break;

		//case EV_DialogCancel :
		//	 break;

		//case EV_Restart :
		//	 break;
	}
}

function OnClickButton( string Name )
{
	switch( Name )
	{
		// 추출 버튼
		case "EnsoulExtractDefaultWnd_extract1_Button":
			 showConfirm(1);
			 break;

		case "EnsoulExtractDefaultWnd_extract2_Button":
			 showConfirm(2);
			 break;

		case "EnsoulExtractDefaultWnd_extract3_Button":
			 showConfirm(3);
			 break;

		case "EnsoulExtractInfo_Button":
			 helpButtonClick();			 
			 break;

		case "EnsoulExtract_Btn":
			 Me.HideWindow();
			 Debug("EnsoulExtract_Btn");
			 break;

			 // 추출 시도 
		case "EnsoulOK_Btn":
			 OnEnsoulOK_BtnClick();			 
			 break;

			 // 캔슬
		case "EnsoulCancel_Btn":
			 OnEnsoulCancel_BtnClick();
			 break;

			 // 결과 후 ok 버튼 클릭
		case "singleOK_Button" :
			 Debug("singleOK_Button");
			 initProcess();
			 break;
	}
}

// 집혼 해제 확인창 호출
function showConfirm(int slotIndex)
{
	local ItemInfo ensoulItemInfo, weaponInfo;
	local string ensoulFeeInfoParam;
	local int slotType;

	Debug("slotIndex" @ slotIndex);

	DisableWnd.HideWindow();

	EnsoulExtractDefaultWnd.HideWindow();
	EnsoulExtractWnd_ResultWnd.HideWindow();

	// 무기창 드래그 잠금
	EnsoulExtractSubWndScript.setLock(true);
		
	// 추출 윈도우
	EnsoulExtractResultWnd.ShowWindow();

	// 3497 : 위와 같이 룬을 추출 하시겠습니까?
	EnsoulExtractDiscription_TextBox.SetText(GetSystemString(3497));

	// 집혼 슬롯 1~3, (1,2,3:bm)
	ensoulItemInfo = getltemInfoBySlotIndex(slotIndex);

	Debug("ensoulItemInfo.Id.ClassID : " @ ensoulItemInfo.Id.ClassID);

	// 슬롯에 정보 채우기 (집혼석은 아이템 정보로 가지고 있지 않음)
	if(ensoulItemInfo.IconName != "")
	{
		// 집혼석 아이콘 추가
		ExtractResultWnd_ITEM_ItemWnd.Clear();
		ExtractResultWnd_ITEM_ItemWnd.AddItem(ensoulItemInfo);

		// 집혼석 이름, 설명 추가(툴팁포함)
		setEnsoulSlotText(slotIndex, getEnsoulOptionInfoBySlotIndex(slotIndex),,"", util.ColorLightBrown, true);
	}

	
	// 무기 정보
	weaponInfo = getltemInfoBySlotIndex(0);

	// SlotType 세팅
	if (slotIndex == 1 || slotIndex == 2)
		slotType = EIST_NORMAL;
	else 
		slotType = EIST_BM;

	// 현재 작업중 인덱스와 슬롯 타입 저장.
	currentSlotIndex = slotIndex;
	currentSlotType  = slotType;

	class'UIDATA_ENSOUL'.static.GetEnsoulExtractionFeeInfo(weaponInfo.CrystalType, slotType, ensoulFeeInfoParam);

	setTreeNeedItemInfo(ensoulFeeInfoParam);
}

// 필요 아이템 (추출 수수료), 트리로 만듬. 
function setTreeNeedItemInfo(string ensoulFeeInfoParam)
{
	local ItemInfo feeItemInfo;
	local int nFeeItemNum, nFeeItemID, i;
	local Int64 nFeeItemCount;

	local ItemInfo InvenFeeItemInfo;

	ParseInt(ensoulFeeInfoParam, "FeeItemCount", nFeeItemNum);

	util.TreeClear(TREENAME);
	util.TreeInsertRootNode( TREENAME, ROOTNAME, "", 0, 4 );

	// 추출 버튼 활성화
	EnsoulOK_Btn.EnableWindow();
	// 먼저 룬을 추출할 무기를 등록하고 추출 버튼을 눌러주세요.
	EnsoulExtractDiscription_TextBox.SetText(GetSystemString(3496));

	for(i = 1; i < nFeeItemNum + 1; i++)
	{
		ParseInt(ensoulFeeInfoParam, "ItemID_" $ i , nFeeItemID);
		ParseInt64(ensoulFeeInfoParam, "ItemCount_" $ i , nFeeItemCount);
		class'UIDATA_ITEM'.static.GetItemInfo(getItemID(nFeeItemID), feeItemInfo);	
		
		//Debug("-> "@ );
		addTreeNode("LIST" $ i + 1, feeItemInfo, nFeeItemCount);
	}

	// Debug("ensoulFeeInfoParam----> " @ ensoulFeeInfoParam);

	inventoryWndScript.getInventoryItemInfo(getItemID(nFeeItemID), InvenFeeItemInfo);
}

// 필요 아이템의 각 아이템을 추가 한다.
function bool addTreeNode(string nodeLine, ItemInfo info, Int64 needItemCount)
{
	local ItemInfo InvenItemInfo;

	local string strRetName, gradeTextureName;
	local int textHeight;

	local string enchantedStr, itemName, additionalName, stackableAddStr;
	local string shortItemName, ensoulOptionAllName;
	local int enchantedStr_width, additionalName_width, stackableAddStr_width, ensoulOptionAllName_width, gradeTextureName_width;

	local Int64 hasNum;
	local bool bHasItem;
	//local int tryExchangeCount;

	local array<ItemInfo> itemInfoArray;
	local int itemCount;

	//tryExchangeCount = int(ItemCount_EditBox.GetString());

	// 그레이드 아이콘
	gradeTextureName = GetItemGradeTextureName(info.CrystalType);

	if( Len(gradeTextureName) > 0 )
	{
		gradeTextureName_width = 16;
		// S80 그레이드일 경우에 한해 아이콘 텍스쳐 크기를 2배로 늘린다. 6, 7
		// R95, R99 그레이드일 경우에 한해 아이콘 텍스쳐 크기를 2배로 늘린다. 9, 10
		if( Info.CrystalType == CrystalType.CRT_S80 || Info.CrystalType == CrystalType.CRT_S84 || Info.CrystalType == CrystalType.CRT_R95 || Info.CrystalType == CrystalType.CRT_R99 )
		{
			gradeTextureName_width = 32;
		}
	}

	// 수량성 아이템에 붙는 x1
	stackableAddStr ="x1";
	GetTextSizeDefault(stackableAddStr, stackableAddStr_width, textHeight);

	if(info.Enchanted > 0) enchantedStr = "+"$ String(info.Enchanted);
	GetTextSizeDefault(enchantedStr, enchantedStr_width, textHeight);

	ensoulOptionAllName = GetEnsoulOptionNameAll(info);

	GetTextSizeDefault(ensoulOptionAllName, ensoulOptionAllName_width, textHeight);

	// 기간제, 등 추가 이름
	additionalName = class'UIDATA_ITEM'.static.GetItemAdditionalName( info.ID );
	GetTextSizeDefault(additionalName, additionalName_width, textHeight);

	itemName = class'UIDATA_ITEM'.static.GetItemName( info.ID );
	if(itemName == "") itemName = info.Name;

	shortItemName = makeShortStringByPixel(itemName, ITEMNAME_TOTAL_WIDTH - (stackableAddStr_width + additionalName_width + gradeTextureName_width + 7), "..");
	
	//Root 노드 생성.	
	strRetName = ROOTNAME $ "." $ nodeLine;

	util.TreeInsertItemTooltipSimpleNode( TREENAME, nodeLine, ROOTNAME, -7, 0, 38, 0, 32, 38, GetItemNameAll(info));

	//아이템 배경 만들기(있는넘)
	//util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_CH3.etc.textbackline", 257, 38, , , , ,14 );
	//아이템 배경 만들기(없는넘)
	util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_CT1.EmptyBtn", 257, 38 );

	//Insert Node Item - 아이템슬롯 배경
	util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_ct1.ItemWindow.ItemWindow_df_slotbox_2x2", 36, 36, -251, 2 );

	//Insert Node Item - 아이템 아이콘, 패널
	util.TreeInsertTextureNodeItem( TREENAME, strRetName, info.IconName, 32, 32, -34, OFFSET_Y_ICON_TEXTURE - 1 );
	util.TreeInsertTextureNodeItem( TREENAME, strRetName, Info.iconPanel, 32, 32, -32, OFFSET_Y_ICON_TEXTURE - 1 );
				
	//Insert Node Item - 아이템 이름
	if (enchantedStr != "") util.TreeInsertTextNodeItem( TREENAME, strRetName, enchantedStr, 7, 5, util.ETreeItemTextType.COLOR_DEFAULT, true );

	util.TreeInsertTextNodeItem( TREENAME, strRetName, shortItemName, 5, 5, util.ETreeItemTextType.COLOR_DEFAULT, true );
	
	if (ensoulOptionAllName != "") util.TreeInsertTextNodeItem( TREENAME, strRetName, ensoulOptionAllName, 5, 5, util.ETreeItemTextType.COLOR_YELLOW, true );
	if (additionalName      != "") util.TreeInsertTextNodeItem( TREENAME, strRetName, additionalName, 5, 5, util.ETreeItemTextType.COLOR_YELLOW, true );	

	// 그레이드 아이콘
	if (gradeTextureName_width > 0)	util.TreeInsertTextureNodeItem( TREENAME, strRetName, gradeTextureName, gradeTextureName_width, 16, 2, 5);

	util.TreeInsertTextNodeItem( TREENAME, strRetName, "x " $ MakeCostString(String(needItemCount)), 45, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GOLD, false, true );


	itemCount = class'UIDATA_INVENTORY'.static.FindItemByClassID(info.Id.ClassID, itemInfoArray);

	// 아이템이 인벤에 있다면..
	if(itemCount > 0)
	{
		InvenItemInfo = itemInfoArray[0];

		// Debug("아이템 수량" @ inventoryWndScript.getItemCountByClassID(info.ID.ClassID));
		if(!IsStackableItem( InvenItemInfo.ConsumeType ))
		{

			hasNum = 1;
		}
		else
		{
			hasNum = InvenItemInfo.ItemNum;
		}
		if (hasNum >= needItemCount) bHasItem = true;
	}
	
	//Debug("bHasItem" @ bHasItem);
	//Debug("hasNum" @ hasNum);
	//Debug("info.ItemNum" @ info.ItemNum);
	//Debug("needItemCount" @ needItemCount);

	if (bHasItem)
	{
		if (hasNum != -1)
			util.TreeInsertTextNodeItem( TREENAME, strRetName,"(" $ MakeCostString(String(hasNum)) $ ")", 4 , OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_BRIGHT_BLUE);
	}
	else 
	{
		util.TreeInsertTextNodeItem( TREENAME, strRetName,"(" $ MakeCostString(String(hasNum)) $ ")", 4 , OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_RED);

		// 추출 버튼 비활성화
		EnsoulOK_Btn.DisableWindow();

		// 추출 수수료가 부족합니다/ 
		EnsoulExtractDiscription_TextBox.SetText(MakeFullSystemMsg(GetSystemMessage(1473), GetSystemString(3494)));
	}

	return bHasItem;
}

function helpButtonClick()
{
	local string strParam;

	//if (getInstanceUIData().getIsClassicServer())
	//{
	//	ParamAdd(strParam, "FilePath", "..\\L2text_Classic\\blacksmith_ensoul_help_classic.htm");
	//}
	//else 
	//{
	//	ParamAdd(strParam, "FilePath", "..\\L2text\\blacksmith_ensoul_help.htm");
	//}

	ParamAdd(strParam, "FilePath", "..\\L2text_Classic\\blacksmith_ensoul_extract_help_classic.htm");

	Debug("OnHelpBtnClick:" @strParam);
	ExecuteEvent(EV_ShowHelp, strParam);}

function OnEnsoulExtract_BtnClick()
{
}

// 추출 하기 버튼 
function OnEnsoulOK_BtnClick()
{
	// 프로그레시브바 숨기기
	EnsoulExtractProgressWnd.ShowWindow();

	EnsoulProgressWnd_ProgressBar.Reset();				
	EnsoulProgressWnd_ProgressBar.SetProgressTime( 1500 );

	// 프로그레스 바를 설정 및 초기화.
	EnsoulProgressWnd_ProgressBar.Start();

	Playsound("ItemSound3.enchant_process");

	EnsoulExtractDiscription_TextBox.HideWindow();
	//EnsoulExtractDiscription_TextBox.SetText(GetSystemMessage(4336));

	Debug("해제 시도 EnsoulOK_Btn");
}

// 다이얼로그의 시간이 다했음
function OnProgressTimeUp( string strID )
{
	Debug("strID" @ strID);

	if( strID == "EnsoulProgressWnd_ProgressBar" )
	{
		if(Me.IsShowWindow())
		{
			DisableWnd.ShowWindow();
			Debug("EnsoulProgressWnd_ProgressBar 창 열기");
			EnsoulExtractProgressWnd.HideWindow();
			requestItemEnsoulProcess();
		}
	}
}

// 룬 추출 
function requestItemEnsoulProcess()
{
	local string param;

	param = makeRequestEnsoulExtractionParam();

	class'EnsoulAPI'.static.RequestItemExtraction(param);

	Debug(" 실행 --- class'EnsoulAPI'.static.RequestItemExtraction() --> param: " @ param);
}

// 서버에 보낼 해제 Param 스트링 생성
function string makeRequestEnsoulExtractionParam()
{
	local string param;
	local int targetWeaponServerID, slotIndex;
	
	// 무기의 서버 아이디
	targetWeaponServerID = getltemInfoBySlotIndex(0).Id.ServerID;

	// slotIndex는 1,2,3 이 아니고, normal 1,2 , bm 1 이런식 구성이다	
	if (EIST_BM == currentSlotType) slotIndex = 1;
	else slotIndex = currentSlotIndex;

	ParamAdd( param, "TargetItemID", string(targetWeaponServerID) );
	ParamAdd( param, "SlotType"  , String(currentSlotType));
	ParamAdd( param, "SlotIndex" , String(slotIndex));

	return param;
}

// 캔슬 버튼 눌러서 초기 상태로 돌아감.
function OnEnsoulCancel_BtnClick()
{
	initProcess();
	StopSound("ItemSound3.enchant_process");
	
	//// 기본 윈도우 초기화 (무기 등록을 보이도록)
	//EnsoulExtractDefaultWnd.ShowWindow();
	//EnsoulExtractResultWnd.HideWindow();
	//EnsoulExtractWnd_ResultWnd.HideWindow();

	//// 무기창 드래그 잠금 해제
	//EnsoulExtractSubWndScript.setLock(false);
	
	//// 먼저 룬을 추출할 무기를 등록하고 추출 버튼을 눌러주세요.
	//EnsoulExtractDiscription_TextBox.SetText(GetSystemString(3496));
}

// 집혼 결과 보여주는 팝업창
function showResult(string param)
{
	local int resultValue, i, n, EnsoulOptionNum, nEOptionID;
	local ItemInfo weaponInfo;


	// 무기, 인벤토리 정보 가져오기
	getItemSlotWindow(0).GetItem(0, weaponInfo);

	// 갱신된 룬 정보 무기에 적용시키기
	for(i=EIST_NORMAL; i<EIST_MAX; i++)
	{
		ParseInt( param, "EnsoulOptionNum_" $ i , EnsoulOptionNum);

		for(n=EISI_START; n<EISI_START + EnsoulOptionNum; n++)
		{
			ParseInt(param, "EnsoulOptionID_" $ i $ "_" $ n, nEOptionID);
			weaponInfo.EnsoulOption[i - EIST_NORMAL].OptionArray[n - EISI_START] = nEOptionID;
		}
	}

	// 클릭 방지
	DisableWnd.SetFocus();
	DisableWnd.ShowWindow();
	DisableWnd.SetFocus();	

	// 최종 결과
	//EnsoulExtractDefaultWnd.HideWindow();
	//EnsoulExtractResultWnd.ShowWindow();
	EnsoulExtractWnd_ResultWnd.ShowWindow();

	ParseInt( param, "ExtractionResult", resultValue );

	// ParseInt( param, "ExtractionItemID", ExtractionItemID );
	//class'UIDATA_ITEM'.static.GetItemInfo(getItemID(ExtractionItemID), tmInfo);	
	// if (tmInfo.Id.ClassId > 0) inventoryWndScript.getInventoryItemInfo(tmInfo.Id, weaponInfo);

	if (resultValue > 0)
		confirmResultEnsoulOption(true, weaponInfo);	
	else 
		confirmResultEnsoulOption(false, weaponInfo);	
}

//-----------------------------------------------------------------------------------------------------------------------
// 최종 결과 확인 창 -> 집혼 완료. 실패 처리를 담당한다.
//-----------------------------------------------------------------------------------------------------------------------
// 집혼 결과를 확인 창을 연다.
function confirmResultEnsoulOption(bool bSuccess, ItemInfo info)
{	
	local ItemInfo tempInfo;
	
	if (bSuccess)
	{		
		Debug("애니 돌리기");
		EnsoulExtractWnd_ResultWnd.SetWindowSize(233, 200);

		GetWindowHandle( "EnsoulExtractWnd.EnsoulExtractWnd_ResultWnd.OK_Button" ).HideWindow();
		GetWindowHandle( "EnsoulExtractWnd.EnsoulExtractWnd_ResultWnd.Cancel_Button" ).HideWindow();
		GetWindowHandle( "EnsoulExtractWnd.EnsoulExtractWnd_ResultWnd.singleOK_Button" ).ShowWindow();

		// EnsoulProgress_AnimTex.HideWindow();
		// EnsoulProgress_AnimTex.SetTexture("l2ui_ct1.ItemEnchant_DF_Effect_Success_00");
		EnsoulProgress_AnimTex.SetLoopCount(1);
		EnsoulProgress_AnimTex.Stop();
		EnsoulProgress_AnimTex.Play();
		Playsound("ItemSound3.enchant_success");
		EnsoulProgress_AnimTex.ShowWindow();
						
		GetItemWindowHandle( "EnsoulExtractWnd.EnsoulExtractWnd_ResultWnd.Result_ItemWnd" ).Clear();
		GetItemWindowHandle( "EnsoulExtractWnd.EnsoulExtractWnd_ResultWnd.Result_ItemWnd" ).ClearTooltip();
		GetItemWindowHandle( "EnsoulExtractWnd.EnsoulExtractWnd_ResultWnd.Result_ItemWnd" ).AddItem(info);
		GetItemWindowHandle( "EnsoulExtractWnd.EnsoulExtractWnd_ResultWnd.Result_ItemWnd" ).SetTooltipType("Inventory");
		
		// 룬 추출에 성공했습니다.
		GetTextBoxHandle( "EnsoulExtractWnd.EnsoulExtractWnd_ResultWnd.Discription_TextBox" ).SetText(GetSystemString(3498));
	}
	else
	{
		Playsound("ItemSound3.enchant_fail");

		EnsoulExtractWnd_ResultWnd.SetWindowSize(233, 250);
		
		tempInfo.IconName = "L2UI_ct1.Icon.ICON_DF_Exclamation";

		GetWindowHandle( "EnsoulExtractWnd.EnsoulExtractWnd_ResultWnd.OK_Button" ).HideWindow();
		GetWindowHandle( "EnsoulExtractWnd.EnsoulExtractWnd_ResultWnd.Cancel_Button" ).HideWindow();
		GetWindowHandle( "EnsoulExtractWnd.EnsoulExtractWnd_ResultWnd.singleOK_Button" ).ShowWindow();

		EnsoulProgress_AnimTex.Stop();
		//EnsoulProgress_AnimTex.Pause();
		EnsoulProgress_AnimTex.HideWindow();

		GetItemWindowHandle( "EnsoulExtractWnd.EnsoulExtractWnd_ResultWnd.Result_ItemWnd" ).ShowWindow();
		GetItemWindowHandle( "EnsoulExtractWnd.EnsoulExtractWnd_ResultWnd.Result_ItemWnd" ).Clear();
		GetItemWindowHandle( "EnsoulExtractWnd.EnsoulExtractWnd_ResultWnd.Result_ItemWnd" ).AddItem(tempInfo);
		GetItemWindowHandle( "EnsoulExtractWnd.EnsoulExtractWnd_ResultWnd.Result_ItemWnd" ).SetTooltipType("");
		GetItemWindowHandle( "EnsoulExtractWnd.EnsoulExtractWnd_ResultWnd.Result_ItemWnd" ).ClearTooltip();

		// -- 시스템 오류로 진행할 수 없습니다. 잠시 후 다시 시도해 주세요.: 
		// -- 일단 사용 안함,  추후 각 케이스 별로 예외 처리 하는 걸 추천
		// -
		// 인벤토리의 무게/수량 제한을 초과하여 해당 작업을 진행할 수 없습니다.
		GetTextBoxHandle( "EnsoulExtractWnd.EnsoulExtractWnd_ResultWnd.Discription_TextBox" ).SetText(GetSystemMessage(3646));
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


//--------------------------------------------------------------------------------------------------------------------
//  EnsoulExtractDefaultWnd 기본 상태 윈도우, 무기 넣기, 집혼석 넣기, 집혼석 텍스트 채우기 등 
//--------------------------------------------------------------------------------------------------------------------

// 무기 아이템 주고 받기
function InsertWeapon(ItemInfo info)
{
	local string fullName;

	Playsound("ItemSound3.enchant_input");

	// 무기가 아니라면 아무작동 안함.
	if (info.itemType != EItemType.ITEM_WEAPON) return;

	// 집혼석 기능, 블럭 박스 (이것들은 show가 가려진 상태)
	EnsoulExtractDefaultWnd_Step1block_Texture.ShowWindow();
	EnsoulExtractDefaultWnd_Step2block_Texture.ShowWindow();
	EnsoulExtractDefaultWnd_BMblock_Texture.ShowWindow();

	EnsoulExtractDefaultWnd_extract1_Button.HideWindow();
	EnsoulExtractDefaultWnd_extract2_Button.HideWindow();
	EnsoulExtractDefaultWnd_extract3_Button.HideWindow();

	// 이미 다른 무기가 들어 있다면..
	if (EnsoulExtractDefaultWnd_Item1_ItemWnd.GetItemNum() > 0)
	{
		// 보조 아이템 윈도우 에서 무기 아이템원도우 을 -> 집혼 UI 무기 항목 아이템 윈도우에 이동		
		util.ItemWIndow_ItemMoveByIndex(getItemSlotWindow(0), EnsoulExtractSubWnd_WeaponItemWindow, 0);
		
		EnsoulExtractDefaultWnd_WeaponName_TextBox.SetTooltipType("");
		EnsoulExtractDefaultWnd_WeaponName_TextBox.ClearTooltip();
	}

	// 보조 인벤(무기) -> 집혼할 무기 인벤으로 
	util.ItemWIndow_ItemMoveByItemID(EnsoulExtractSubWnd_WeaponItemWindow, getItemSlotWindow(0), info.Id);

	// 무기 이름 출력
	if(info.Id.ClassID > 0)
	{		
		// 노란 포커싱 박스텍스쳐 , 아래쪽으로 포커스 이동
		EnsoulExtractDefaultWnd_Select1_Texture.HideWindow();
		EnsoulExtractDefaultWnd_Select1_Texture.ShowWindow();

		// 일반 슬롯, BM 슬롯 수 갱신
		normalSlotCount = class'UIDATA_ENSOUL'.static.GetEnsoulSlotCount(info.Id, EIST_NORMAL);
		bmSlotCount = class'UIDATA_ENSOUL'.static.GetEnsoulSlotCount(info.Id, EIST_BM );

		// 이미 무기에 옵션이 되어 있는 슬롯 표시 숨김.
		EnsoulExtractDefaultWnd_SlotBg1_Texture.HideWindow();
		EnsoulExtractDefaultWnd_SlotBg2_Texture.HideWindow();
		EnsoulExtractDefaultWnd_SlotBg3_Texture.HideWindow();

		fullName = GetItemNameAll(info);

		// 무기 이름 "..",  툴팁 추가 
		util.textBox_setToolTipWithShortString(EnsoulExtractDefaultWnd_WeaponName_TextBox, fullName);
			
		// 슬롯 다 삭제..
		clearEnsoulStoneSlot();
		
		// 무기에 적용되어 있는 집혼 정보를 UI에서 표시한다.
		applyWeaponEnsoulInfo(info);
	}

	// 무기 아이템 윈도우 
	setWeaponEnsoulOptionSlot(info);
}

// 무기의 집혼 정보를 UI에 표시 한다.
function applyWeaponEnsoulInfo(ItemInfo info)
{
	local int n, i , cnt, optionID, rIndex;

	local EnsoulOptionUIInfo optionInfo;
	local ItemInfo esInfo;
	
	Debug("초기화 applyWeaponEnsoulInfo" );

	// 무기에서 집혼 정보를 얻어 온다.
	// Normal, BM 각 타입별
	for(i=EIST_NORMAL; i<EIST_MAX; i++)
	{
		// 각 타입의 옵션 수
		cnt = info.EnsoulOption[i - EIST_NORMAL].OptionArray.Length;

		for(n=EISI_START; n<EISI_START + cnt; n++)
		{
			optionID = info.EnsoulOption[i - EIST_NORMAL].OptionArray[n - EISI_START];

			// Debug("무기 조회 optionID" @ optionID);

			// 집혼 옵션에 대한 정보를 읽는다.
			if (optionID > 0) GetEnsoulOptionUIInfo(optionID, optionInfo);
			else continue;
			
			// 무기에 이미 적용되어 있던 옵션을 넣는다.
			if (optionID > 0)
			{

				// 1,2,3 슬롯으로 index값을 변환
				// bm 슬롯은 1개 이다. 무조건 3이다.
				if(i == EIST_BM) rIndex = 3;
				else rIndex = n;
				
				// Debug("무기에 옵션이 있다 :" @ optionInfo.name);						
				// Debug("optionType :" @ optionInfo.optionType);

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
						Debug("optionInfo.ExtractionItemID :::: " @ optionInfo.ExtractionItemID);

						if (getItemSlotWindow(1).GetItemNum() == 0)
						{
							ensoulOptionInfoSlot1 = optionInfo;
							// Debug("슬롯 1채우기");
							getItemSlotWindow(1).AddItem(esInfo);
							setEnsoulSlotText(1, optionInfo,,"", util.ColorLightBrown);
							EnsoulExtractDefaultWnd_SlotBg1_Texture.ShowWindow();
							EnsoulExtractDefaultWnd_extract1_Button.ShowWindow();

							if (optionInfo.ExtractionItemID == 0)
							{
								EnsoulExtractDefaultWnd_extract1_Button.SetButtonName(460);
								EnsoulExtractDefaultWnd_extract1_Button.DisableWindow();
							}
							else
							{
								EnsoulExtractDefaultWnd_extract1_Button.SetButtonName(3492);
								EnsoulExtractDefaultWnd_extract1_Button.EnableWindow();
							}
						}
					}
					// 2번째 칸
					else
					{
						// Debug("n값 "@n);
						if (getItemSlotWindow(2).GetItemNum() == 0)
						{
							ensoulOptionInfoSlot2 = optionInfo;
							// Debug("슬롯 2채우기");
							getItemSlotWindow(2).AddItem(esInfo);							
							setEnsoulSlotText(2, optionInfo,,"", util.ColorLightBrown);
							EnsoulExtractDefaultWnd_SlotBg2_Texture.ShowWindow();
							EnsoulExtractDefaultWnd_extract2_Button.ShowWindow();

							if (optionInfo.ExtractionItemID == 0)
							{
								EnsoulExtractDefaultWnd_extract2_Button.DisableWindow();
								EnsoulExtractDefaultWnd_extract2_Button.SetButtonName(460);
							}
							else
							{
								EnsoulExtractDefaultWnd_extract2_Button.SetButtonName(3492);
								EnsoulExtractDefaultWnd_extract2_Button.EnableWindow();
							}

						}
					}
				}
				// BM 슬롯은 한개이다.
				else if (i == EIST_BM)
				{		
					ensoulOptionInfoSlotBM = optionInfo;
					/// Debug("bm");
					if (getItemSlotWindow(3).GetItemNum() == 0)
					{		
						getItemSlotWindow(3).AddItem(esInfo);
						setEnsoulSlotText(3, optionInfo,,"", util.ColorLightBrown);
						EnsoulExtractDefaultWnd_SlotBg3_Texture.ShowWindow();
						EnsoulExtractDefaultWnd_extract3_Button.ShowWindow();

						if (optionInfo.ExtractionItemID == 0)
						{
							EnsoulExtractDefaultWnd_extract3_Button.SetButtonName(460);
							EnsoulExtractDefaultWnd_extract3_Button.DisableWindow();
						}
						else
						{
							EnsoulExtractDefaultWnd_extract3_Button.SetButtonName(3492);
							EnsoulExtractDefaultWnd_extract3_Button.EnableWindow();
						}
					}
				}
			}
		}		
	}
}


/**
 *  집혼석 슬롯에 선택된 값을 출력, 삭제 처리 (bConfirmWnd == true라면 확인창 텍스트 필드로 교체)
 **/
function setEnsoulSlotText(int slotIndex, EnsoulOptionUIInfo eOptionInfo, optional bool bDelete, optional string applyAddString, optional Color applyColor, optional bool bConfirmWnd)
{
	local TextBoxHandle soulNameTextBox, soulDescTextBox;
	local CustomTooltip cTooltip;

	if(bConfirmWnd == false)
	{
		if (slotIndex == 1) 
		{
			soulNameTextBox = EnsoulExtractDefaultWnd_SoulName1_TextBox;
			soulDescTextBox = EnsoulExtractDefaultWnd_Soul1_TextBox;
		}
		else if (slotIndex == 2) 
		{
			soulNameTextBox = EnsoulExtractDefaultWnd_SoulName2_TextBox;
			soulDescTextBox = EnsoulExtractDefaultWnd_Soul2_TextBox;

		}
		else if (slotIndex == 3) 
		{ 
			soulNameTextBox = EnsoulExtractDefaultWnd_SoulName3_TextBox;
			soulDescTextBox = EnsoulExtractDefaultWnd_Soul3_TextBox;
		}
	}
	else
	{
			soulNameTextBox = ExtractResultWnd_Name_TextBox;
			soulDescTextBox = ExtractResultWnd_notice_TextBox ;
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

// 집혼석 슬롯들 삭제
function clearEnsoulStoneSlot()
{
	// 집혼석 슬롯들 일반, BM
	getItemSlotWindow(1).Clear();
	getItemSlotWindow(2).Clear();
	getItemSlotWindow(3).Clear();

	textBoxClear(EnsoulExtractDefaultWnd_Soul1_TextBox);
	textBoxClear(EnsoulExtractDefaultWnd_Soul2_TextBox);
	textBoxClear(EnsoulExtractDefaultWnd_Soul3_TextBox);

	textBoxClear(EnsoulExtractDefaultWnd_SoulName1_TextBox);
	textBoxClear(EnsoulExtractDefaultWnd_SoulName2_TextBox);
	textBoxClear(EnsoulExtractDefaultWnd_SoulName3_TextBox);
}

	// 슬롯 기본 윈도우 리턴
function EnsoulOptionUIInfo getEnsoulOptionInfoBySlotIndex(int slotIndex)
{
	local EnsoulOptionUIInfo enInfo;

	if (slotIndex == 1) enInfo = ensoulOptionInfoSlot1;
	else if (slotIndex == 2) enInfo = ensoulOptionInfoSlot2;
	else if (slotIndex == 3) enInfo = ensoulOptionInfoSlotBM;
	else Debug("Error (getEnsoulOptionInfoBySlotIndex) : Index is " @ slotIndex);

	return enInfo;
}


// 슬롯 기본 윈도우 리턴
function ItemWindowHandle getItemSlotWindow(int slotIndex)
{
	local ItemWindowHandle targetItemWndow;

	if (slotIndex == 0) targetItemWndow = EnsoulExtractDefaultWnd_Item1_ItemWnd;
	else if (slotIndex == 1) targetItemWndow = EnsoulExtractDefaultWnd_Item2_ItemWnd;
	else if (slotIndex == 2) targetItemWndow = EnsoulExtractDefaultWnd_Item3_ItemWnd;
	else if (slotIndex == 3) targetItemWndow = EnsoulExtractDefaultWnd_ItemBM_ItemWnd;
	else Debug("Error (getItemSlotWindow) : Index is " @ slotIndex);

	return targetItemWndow;
}

// 아이템 정보를 리턴 (0:무기, 1:슬롯, 2:슬롯, 3:bm);
function ItemInfo getltemInfoBySlotIndex(int slotIndex)
{
	local ItemInfo tm;

	//Debug("ItemNum: " @ getItemSlotWindow(slotIndex).GetItemNum());

	getItemSlotWindow(slotIndex).GetItem(0, tm);

	return tm;
}

// 슬롯 
function setWeaponEnsoulOptionSlot(ItemInfo tempInfo)
{
	local int n;

	// 일반 슬롯, BM 슬롯 수 조회
	n = class'UIDATA_ENSOUL'.static.GetEnsoulSlotCount(tempInfo.Id, EIST_NORMAL);

	// 일반 슬롯 갯수, 1,2슬롯 활성화 여부
	if (n == 1)
	{
		EnsoulExtractDefaultWnd_Step1block_Texture.HideWindow();				
	}
	else if (n == 2)
	{
		EnsoulExtractDefaultWnd_Step1block_Texture.HideWindow();
		EnsoulExtractDefaultWnd_Step2block_Texture.HideWindow();
	}

	// BM슬롯
	n = class'UIDATA_ENSOUL'.static.GetEnsoulSlotCount(tempInfo.Id, EIST_BM );
	if (n > 0)
	{
		EnsoulExtractDefaultWnd_BMblock_Texture.HideWindow();
	}
}

// 현재 슬롯에 꼽아서 사용 중인 아이템 과 같은게 있나 체크 , 서브 인벤에서 사용
function bool externalCheckUsingItem(ItemInfo info)
{
	local itemInfo innerItemInfo;
	local bool rValue;

	// 무기 슬롯
	if (getItemSlotWindow(0).GetItemNum() > 0)
	{
		getItemSlotWindow(0).GetItem(0, innerItemInfo);
		if (innerItemInfo.Id == Info.Id) rValue = true;
	}

	return rValue;
}


// OnDropItem
function OnDropItem( String a_WindowID, ItemInfo a_ItemInfo, int X, int Y)
{	
	// 창 영역의 사이즈width, height 를 사용
	local Rect  rectWnd;

	rectWnd = Me.GetRect();	

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
	
	if (X > rectWnd.nX && X <  rectWnd.nX + rectWnd.nWidth && 
		Y > rectWnd.nY && Y <  rectWnd.nY + rectWnd.nHeight) //범위 지정
	{	
		// Debug("무기 무기 윈도우  :::" @ a_WindowID);
		// 무기 추가 
		
		InsertWeapon(a_ItemInfo);
	}
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
