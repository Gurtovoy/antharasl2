//-----------------------------------------------------------------------------------------------------------
//  멀티셀 개선 UI , 2015-04-10 (작업 시작일)

//
//카페포인트 1000
//pccafe on
//

// //multisell 551     <- 혈맹관련 포인트
// //multisell 917     <- pvp 포인트 사용 멀티셀 917~924
// //multisell 890     <- raid 포인트 사용 멀티셀 890

//-----------------------------------------------------------------------------------------------------------

class MultiSellWnd extends UICommonAPI;

const DIALOG_ASK_PRICE                         = 1123;					
const MULTISELLWND_DIALOG_OK                   = 1122;

const OFFSET_X_ICON_TEXTURE=0;
const OFFSET_Y_ICON_TEXTURE=4;
const OFFSET_Y_SECONDLINE = -14;

const TREENAME = "MultiSellWnd.NeededItem_TreeCtrl";
const ROOTNAME = "root";
const ITEMNAME_TOTAL_WIDTH = 240;

const TIMER_UPDATE_ID   = 1235552;
const TIMER_UPDATEDELAY = 10;

var WindowHandle Me;

var TextBoxHandle ItemInfo_Text;
var TextBoxHandle NeedItem_Text;
var TextBoxHandle ExchangeNum_Text;

// 검색이 항목이 없으면 여기다..
var TextBoxHandle DescriptionMsg_Text;

var TabHandle     MultiSellTab;

// 전체 목록 윈도우
var WindowHandle     MultisellTabTotalWnd;
var ItemWindowHandle MultisellTabTotalWnd_ItemWindow;
var ListCtrlHandle   MultisellTabTotalWnd_ListCtrl;

// 교환 가능한 윈도우
var WindowHandle     MultisellTabEnableWnd;
var ItemWindowHandle MultisellTabEnableWnd_ItemWindow;
var ListCtrlHandle   MultisellTabEnableWnd_ListCtrl;

var WindowHandle     DisableWnd;

// 검색 입력 텍스트
var EditBoxHandle  Search_EditBox;

// 아이템 수량 입력 에디터
var EditBoxHandle  ItemCount_EditBox;

// 아이템 정보, 필요 아이템 트리
// var TreeHandle     ItemInfo_TreeCtrl;
var TreeHandle     NeededItem_TreeCtrl;

//var MultiSellInfo multiSellItemInfo;

// 보조 인벤토리 뷰어 호출 버튼
var ButtonHandle InventoryViewerCall_Button;

// 검색, 갱신, 초기화
var ButtonHandle Search_Button;
var ButtonHandle Refrash_Button;
var ButtonHandle Clear_Button;

// 교환, 닫기 
var ButtonHandle ExChange_Button;
var ButtonHandle Close_Button;

var ButtonHandle IconTabIcon_Button;
var ButtonHandle ListTabIcon_Button;

// 입력기 버튼
var ButtonHandle MultiSell_Up_Button;
var ButtonHandle MultiSell_Down_Button;
var ButtonHandle MultiSell_Input_Button;



//-----------------------------------------------------------------------------------------------------------
// Var
//-----------------------------------------------------------------------------------------------------------
struct MultiSellInfo
{
	var int 				MultiSellInfoID;
	var int 				MultiSellType;

	var INT64 				NeededItemNum;

	// 서버 한테 보낼때 필요한 아이템 정보
	var	ItemInfo			ResultItemInfo;

	// 교환 될 아이템 목록
	var array< ItemInfo >	OutputItemInfoList;

	// 필요한 아이템 목록
	var array< ItemInfo >	InputItemInfoList;
};

struct NoStackableItemData
{
	var int 				ClassID;
	var INT64 				count;
	//var bool                bNoEnchantName; // 인챈트나 집혼 같은 부가적인 정보를 담는 이름을 사용안함
};


// 저장할 대표 리스트 목록
var array< MultiSellInfo>	m_MultiSellInfoList;

var int						m_MultiSellGroupID;
var int						m_nSelectedMultiSellInfoIndex;
var int						m_nCurrentMultiSellInfoIndex;

struct multiSellData
{
	var int 				pcCafePoint;
	var int 				clanPoint;
	var int 				pvpPoint;
	var	int			        raidPoint;
	var INT64 				adena;
};

// PVP, Raid 포인트를 얻어올때 사용
var UserInfo playerInfo;

var multiSellData mData; 
var L2Util util;
//var InventoryWnd InventoryWndScript;
var UIData UIDataScript;

// 창을 열었을때 한번만 처리 할 것들을 위한 flag
var bool bFirstAdd, bClose;

// 멀티셀 세팅 값 (AI에서 설정한..)
var int nShowAll, nRepeat, nKeepEnchant;

// 결과 이후, 입력 아이템 카운트
var int nRepeatTimeCurrentInputItemInfoIndex;

// 최종 선택 했던 아이템 정보 기억 했다가 복원 할때 사용
var ItemInfo lastSelectItemInfo;

var String dialogMessage;

// tick 당 갱신 및 추가를 위한 변수
var bool useTick;
var int  tickIndex;
var int  tickItemListIndex;

// 검색어 string 
var string searchStr;

// 검색어를 입력 한 상태인지..
var bool   searchMode;

// 강제 갱신
var bool bForceUpdate;

// ShowVariationItem
var int bShowVariationItem;

//-----------------------------------------------------------------------------------------------------------
// Init
//-----------------------------------------------------------------------------------------------------------
function OnRegisterEvent()
{
	registerEvent( EV_MultiSellInfoListBegin );
	registerEvent( EV_MultiSellResultItemInfo );
	registerEvent( EV_MultiSellOutputItemInfo );
	registerEvent( EV_MultiSellInputItemInfo );
	registerEvent( EV_MultiSellInfoListEnd );

	registerEvent( EV_DialogOK );
	registerEvent( EV_DialogCancel );   
	registerEvent( EV_MultiSellResult ); 

	registerEvent( EV_AdenaInvenCount );
}

function OnLoad()
{
	SetClosingOnESC();
	Initialize();
}

// 드래그가 없는 것은 Down으로 처리 했다. 
function OnLButtonDown(WindowHandle a_WindowHandle, int nX, int nY)
{
	 if(GetWindowHandle("InventoryViewer").IsShowWindow())
	 {
		GetWindowHandle("InventoryViewer").SetFocus();
		GetWindowHandle(getCurrentWindowName(string(Self))).SetFocus();
		if(GetWindowHandle("DialogBox").IsShowWindow()) GetWindowHandle("DialogBox").SetFocus();
	 }
}

function OnShow()
{	
	getInstanceL2Util().ItemRelationWindowHide(getCurrentWindowName(String(self)));
	getInstanceInventoryViewer().showWindowByParentWindow(Me);

	bFirstAdd = true;
	Search_EditBox.SetString("");
	ItemCount_EditBox.SetString("1");
	disableWindowWithText(false, "");
	DisableWnd.HideWindow();
}

function OnHide()
{
	local ItemInfo nullInfo;
	lastSelectItemInfo = nullInfo;

	bClose = false;
	Me.DisableTick();
	useTick = false;
	
	if(DialogIsMine()) DialogHide();
	
	Me.KillTimer( TIMER_UPDATE_ID );
	iniListWithItemWindow();
	if(GetWindowHandle("InventoryViewer").IsShowWindow()) GetWindowHandle("InventoryViewer").HideWindow();
}

function Initialize()
{
	util               = L2Util(GetScript("L2Util"));
	UIDataScript       = UIData(GetScript("UIData"));
	//InventoryWndScript = InventoryWnd(GetScript("InventoryWnd"));
	
	Me         = GetWindowHandle( "MultiSellWnd" );
	DisableWnd = GetWindowHandle("MultiSellWnd.DisableWnd");
	
	ItemInfo_Text       = GetTextBoxHandle( "MultiSellWnd.ItemInfo_Text" );
	NeedItem_Text       = GetTextBoxHandle( "MultiSellWnd.NeedItem_Text" );
	ExchangeNum_Text    = GetTextBoxHandle( "MultiSellWnd.ExchangeNum_Text" );
	DescriptionMsg_Text = GetTextBoxHandle( "MultiSellWnd.DescriptionMsgWnd.DescriptionMsg_Text" );

	MultiSellTab                    = GetTabHandle( "MultiSellWnd.MultiSellTab" );

	MultisellTabTotalWnd            = GetWindowHandle( "MultiSellWnd.MultisellTabTotalWnd" );
	MultisellTabTotalWnd_ListCtrl   = GetListCtrlHandle  ( "MultiSellWnd.MultisellTabTotalWnd.MultisellTabTotalWnd_ListCtrl" );
	MultisellTabTotalWnd_ItemWindow = GetItemWindowHandle( "MultiSellWnd.MultisellTabTotalWnd.MultisellTabTotalWnd_ItemWindow" );

	MultisellTabEnableWnd            = GetWindowHandle( "MultiSellWnd.MultisellTabEnableWnd" );
	MultisellTabEnableWnd_ListCtrl   = GetListCtrlHandle  ( "MultiSellWnd.MultisellTabEnableWnd.MultisellTabEnableWnd_ListCtrl" );
	MultisellTabEnableWnd_ItemWindow = GetItemWindowHandle( "MultiSellWnd.MultisellTabEnableWnd.MultisellTabEnableWnd_ItemWindow" );
	
	Search_EditBox    = GetEditBoxHandle( "MultiSellWnd.Search_EditBox" );
	ItemCount_EditBox = GetEditBoxHandle( "MultiSellWnd.ItemCount_EditBox" );

	// 아이템정보, 필요아이템 트리 
	//ItemInfo_TreeCtrl   = GetTreeHandle( "MultiSellWnd.ItemInfo_TreeCtrl" );
	NeededItem_TreeCtrl = GetTreeHandle( "MultiSellWnd.NeededItem_TreeCtrl" );

	// 버튼
	Search_Button      = GetButtonHandle( "MultiSellWnd.Search_Button" );
	Refrash_Button     = GetButtonHandle( "MultiSellWnd.Refrash_Button" );
	Clear_Button       = GetButtonHandle( "MultiSellWnd.Clear_Button" );
	ExChange_Button    = GetButtonHandle( "MultiSellWnd.ExChange_Button" );
	Close_Button       = GetButtonHandle( "MultiSellWnd.Close_Button" );

	IconTabIcon_Button = GetButtonHandle( "MultiSellWnd.IconTabIcon_Button" );
	ListTabIcon_Button = GetButtonHandle( "MultiSellWnd.ListTabIcon_Button" );

	MultiSell_Up_Button    = GetButtonHandle( "MultiSellWnd.MultiSell_Up_Button" );
	MultiSell_Down_Button  = GetButtonHandle( "MultiSellWnd.MultiSell_Down_Button" );
	MultiSell_Input_Button = GetButtonHandle( "MultiSellWnd.MultiSell_Input_Button" );
	InventoryViewerCall_Button = GetButtonHandle( "MultiSellWnd.InventoryViewerCall_Button" );
	
	//MultiSellTab.SetTopOrder(1, false);

	MultisellTabTotalWnd_ListCtrl.SetSelectedSelTooltip(FALSE);	
	MultisellTabTotalWnd_ListCtrl.SetAppearTooltipAtMouseX(true);

	MultisellTabEnableWnd_ListCtrl.SetSelectedSelTooltip(FALSE);	
	MultisellTabEnableWnd_ListCtrl.SetAppearTooltipAtMouseX(true);

	IconTabIcon_Button.SetTooltipText(GetSystemString(3397));
	ListTabIcon_Button.SetTooltipText(GetSystemString(3397));

	// 초기화 토글
	toggleListWithIconWindow(true);
}

// 아이콘 윈도우, 리스트 컨트롤로 토글 하면서 보여주도록
function toggleListWithIconWindow(optional bool bInit)
{
	if (bInit)
	{
		// 리스트를 기본으로.. 
		IconTabIcon_Button.HideWindow();
		ListTabIcon_Button.ShowWindow();
	}

	if (ListTabIcon_Button.IsShowWindow())
	{
		// 아이콘 목록이 보이게
		IconTabIcon_Button.ShowWindow();
		ListTabIcon_Button.HideWindow();

		MultisellTabTotalWnd_ItemWindow.HideWindow();
		MultisellTabTotalWnd_ListCtrl.ShowWindow();

		MultisellTabEnableWnd_ItemWindow.HideWindow();
		MultisellTabEnableWnd_ListCtrl.ShowWindow();

		GetTextureHandle("MultiSellWnd.MultisellTabTotalWnd.listSlotBg1_Texture_MultisellTabIconWnd").HideWindow();
		GetTextureHandle("MultiSellWnd.MultisellTabTotalWnd.listSlotBg2_Texture_MultisellTabIconWnd").HideWindow();

		GetTextureHandle("MultiSellWnd.MultisellTabEnableWnd.listSlotBg1_Texture_MultisellTabIconWnd").HideWindow();
		GetTextureHandle("MultiSellWnd.MultisellTabEnableWnd.listSlotBg2_Texture_MultisellTabIconWnd").HideWindow();

		GetTextureHandle("MultiSellWnd.MultisellTabEnableWnd.listGroupBg_Texture_MultisellTabIistWnd").ShowWindow();
		GetTextureHandle("MultiSellWnd.MultisellTabTotalWnd.listGroupBg_Texture_MultisellTabIistWnd").ShowWindow();
	}
	else
	{
		// 리스트 목록이 보이게
		IconTabIcon_Button.HideWindow();
		ListTabIcon_Button.ShowWindow();

		MultisellTabTotalWnd_ListCtrl.HideWindow();
		MultisellTabTotalWnd_ItemWindow.ShowWindow();

		MultisellTabEnableWnd_ListCtrl.HideWindow();
		MultisellTabEnableWnd_ItemWindow.ShowWindow();

		GetTextureHandle("MultiSellWnd.MultisellTabTotalWnd.listSlotBg1_Texture_MultisellTabIconWnd").ShowWindow();
		GetTextureHandle("MultiSellWnd.MultisellTabTotalWnd.listSlotBg2_Texture_MultisellTabIconWnd").ShowWindow();

		GetTextureHandle("MultiSellWnd.MultisellTabEnableWnd.listSlotBg1_Texture_MultisellTabIconWnd").ShowWindow();
		GetTextureHandle("MultiSellWnd.MultisellTabEnableWnd.listSlotBg2_Texture_MultisellTabIconWnd").ShowWindow();

		GetTextureHandle("MultiSellWnd.MultisellTabEnableWnd.listGroupBg_Texture_MultisellTabIistWnd").HideWindow();
		GetTextureHandle("MultiSellWnd.MultisellTabTotalWnd.listGroupBg_Texture_MultisellTabIistWnd").HideWindow();
	}
}

//-----------------------------------------------------------------------------------------------------------
// OnEvent
//-----------------------------------------------------------------------------------------------------------
function OnEvent(int Event_ID, string param)
{
	switch( Event_ID )
	{
		case EV_MultiSellInfoListBegin:
			 Debug("시작: EV_MultiSellInfoListBegin" @ param);
			 if(!bClose) HandleMultiSellInfoListBegin( param );
			 
			 
			 break;

		case EV_MultiSellResultItemInfo:
			 //if(!(nRepeat == 1 && nShowAll == 1)) 
			 //{
				//HandleMultiSellResultItemInfo( param );
				//// Debug("----- EV_MultiSellResultItemInfo" @ param);
			 //}
			 if(!bClose) HandleMultiSellResultItemInfo( param );
			 break;

		case EV_MultiSellOutputItemInfo:
			 if(!bClose) HandelMultiSellOutputItemInfo( param );
			 //Debug("HandelMultiSellOutputItemInfo" @ param);
			 break;

			 // 필요 아이템 목록
		case EV_MultiSellInputItemInfo:
			 //if(!(nRepeat == 1 && nShowAll == 1))
			 if(!bClose) HandelMultiSellInputItemInfo( param );
			 
			 //Debug("필요 아이템 : EV_MultiSellInputItemInfo" @ param);
			 break;

		case EV_MultiSellInfoListEnd:
			 //if(!(nRepeat == 1 && nShowAll == 1)) 

			 Me.DisableTick();
			 useTick = false;		
			 Me.KillTimer( TIMER_UPDATE_ID );
 
			 if(bClose)
			 {
				Me.HideWindow();
			 }
			 else
			 {
				 HandleMultiSellInfoListEnd( param );

				 ShowItemList(); //updateUIControl();

				 //Me.SetTimer(TIMER_UPDATE_ID, TIMER_UPDATEDELAY);
			 }
			 break;

		case EV_DialogOK:
			 HandleDialogOK(true);
			 break;

	    case EV_DialogCancel : 
			 HandleDialogOK(false);
			 break;

		case EV_MultiSellResult :
			 HandleMultiSellResult(param);
			 break;

		//case EV_InventoryUpdateItem :
	    case EV_AdenaInvenCount:
			 if (Me.IsShowWindow()) 
			 {
				updateMultiSellData();
				updateUIControl();	
			 }
			 
			 break;

		default:
			 break;
	};
}

function OnTimer(int TimerID)
{
	if(TimerID == TIMER_UPDATE_ID)
	{
		Me.DisableTick();
		useTick = false;

		//ShowItemList(); //updateUIControl();
		//setSelectItem(lastSelectItemInfo);
		//updateUIControl();
		
		// Me.SetTimer(TIMER_SELECT_ITEM, 100);

		// 교환창만, 선택 복원을 한다.
		if(isExchangeWindowState())
		{
			setSelectItem(lastSelectItemInfo);
		}
		
		updateUIControl();

		Me.KillTimer( TIMER_UPDATE_ID );
	}


	//if(TimerID == TIMER_SELECT_ITEM)
	//{
	//	Me.KillTimer( TIMER_SELECT_ITEM );
	//}
}

// 다시 사용 안하기로 함. -_-..
// 인챈트, 집혼, 등 경고를 할 멀티셀 목록 
//function bool isWarningByMultiSellGroupID()
//{
//	Debug("=========> m_MultiSellGroupID" @ m_MultiSellGroupID);
//	// 기획담당: 최유리
//	// 기획에서 5~50까지 MultiSellGroupID 는 인챈트 하면 날라가는 경고가 뜨는 영역이라고 지정 해준것이다.
//	if (m_MultiSellGroupID >= 5 && m_MultiSellGroupID <= 50)
//	{
//		return true;
//	}

//	return false;
//}

//  초기화
function ClearAll()
{
	Me.KillTimer( TIMER_UPDATE_ID );
	//Me.KillTimer( TIMER_SELECT_ITEM );

	m_nCurrentMultiSellInfoIndex = 0;
	m_MultiSellInfoList.Length = 0;
	m_MultiSellGroupID = 0;

	ItemCount_EditBox.SetString("1");

	disableWindowWithText(false, "");
	DisableWnd.HideWindow();
	
	iniListWithItemWindow();
}

// 기본 컨트롤 초기화
function iniListWithItemWindow()
{
	ItemCount_EditBox.SetString("1");

	// 교환할 아이템 목록, 아이템 윈도우, 리스트 초기화
	MultisellTabTotalWnd_ListCtrl.DeleteAllItem();
	MultisellTabTotalWnd_ItemWindow.Clear();

	MultisellTabEnableWnd_ItemWindow.Clear();
	MultisellTabEnableWnd_ListCtrl.DeleteAllItem();

	// 아이템 정보, 필요 아이템 트리 초기화
	class'UIAPI_MULTISELLITEMINFO'.static.Clear("MultiSellWnd.multiSellItemInfo");
	NeededItem_TreeCtrl.Clear();
}

// HandleMultiSellInfoListBegin
function HandleMultiSellInfoListBegin( string param )
{
	local ItemInfo nullInfo;

	bShowVariationItem = 0;

	ParseInt( param, "ShowAll", nShowAll );
	ParseInt( param, "Repeat" , nRepeat );
	ParseInt(param,"ShowVariationItem",bShowVariationItem);
	ParseInt( param, "KeepEnchant" , nKeepEnchant );
	
	// 구매 완료후 Repeat는 1이 넘어온다.  가변적 목록이면 무조건 목록을 갱신
	if(!(nRepeat == 1 && nShowAll == 1)) 
	{
		bFirstAdd = true;
		ClearAll();
	}

	if (nRepeat == 0) lastSelectItemInfo = nullInfo;

	ParseInt( param, "MultiSellGroupID", m_MultiSellGroupID );

	// 내부 데이타를 다시 갱신한다. 
	if (nRepeat == 1)
	{
		m_nCurrentMultiSellInfoIndex = 0;
		m_MultiSellInfoList.Length = 0;
	}

		
	//ParseInt( param, "ShowType", ShowType );  // 현재 사용 안하는 것으로 판단됨.
	// HandleShowType( showType );
}

/*---------------------------------------------------------------------------------------------------------
  구매 시도 후 결과
 ---------------------------
  Success -> 1은 성공, 0은 실패
  NumPoint -> 아래 type, point 페어 갯수
  Type0 -> 첫번째 포인트 타입(타입 EnuM은 미정)
  Point0 -> 변경된 포인트
  Type1 -> 두번째 포인트 타입
  Point1 -> 변경된 포인트
---------------------------------------------------------------------------------------------------------*/
function HandleMultiSellResult(string param)
{
	local int success;
	//local ItemInfo lastSelectItemInfo;

	Debug("--------HandleMultiSellResult param" @ param);

	if(Me.IsShowWindow())
	{
		Me.DisableTick();
		useTick = false;
		Me.KillTimer( TIMER_UPDATE_ID );

		if(dialogMessage == GetSystemMessage(4363) && hasExceptionMultiSellID() == false)
		{
			Debug("멀티셀 닫기 예약");
			bClose = true; 
			// Me.HideWindow();	
		}		
		else
		{
			ParseInt( param, "Success",	success );

			getCurrentSelectedItemInfo(lastSelectItemInfo);
			//lastSelectedIndex = rItemInfo.Reserved;

			updateMultiSellData(param);

			bClose = false;
			//ShowItemList();
			Debug("멀티셀 갱신");
		}

		//ParseInt( param, "Success",	success );

		//getCurrentSelectedItemInfo(lastSelectItemInfo);
		////lastSelectedIndex = rItemInfo.Reserved;

		//updateMultiSellData(param);

		//ShowItemList();
		//Debug("유지해");

	}

	//setSelectItem(lastSelectItemInfo);
	//updateUIControl();
}

// 강제 닫기를 안하게 할 멀티셀 ID 
// 방어구, 세트 등을 다시 환불 받는데 멀티셀이 닫힐 경우 하나 하나 다시 열기 너무 힘듬. 그걸 위한 하드코딩
function bool hasExceptionMultiSellID()
{
	local bool bFlag;

	switch(m_MultiSellGroupID)
	{
		case 903  : bFlag = true;  // 강철의 문 주화 교환 시스템 TTP 69204 
		case 2196 : bFlag = true;  // 별자리 아가시온 TTP 71768
	}

	return bFlag;
}

// HandleShowType
//function HandleShowType( int showType )
//{	
//	switch ( showType ) 
//	{
//		case 0 :
//			// 아이템 정보, 필요한 아이템
//			ItemInfo_Text.SetText(GetSystemString(564));
//			ItemInfo_Text.SetText(GetSystemString(565));
//			break;

//		case 1 :
//			// 필요한 아이템, 교환할 아이템
//			ItemInfo_Text.SetText(GetSystemString(565));
//			ItemInfo_Text.SetText(GetSystemString(3134));
//			break;
//	}
//}

// HandleMultiSellResultItemInfo
function HandleMultiSellResultItemInfo( string param)
{
	local int		nMultiSellInfoID;
	local int		nBuyType;
	local ItemInfo	info;

	// 신규 집혼 적용
	local int       ensoulNormalSlot, ensoulBmSlot;

	ParseInt( param, "MultiSellInfoID",			nMultiSellInfoID );
	ParseInt( param, "BuyType",					nBuyType );
	ParseInt( param, "Enchant",					info.Enchanted );
	ParseInt( param, "RefineryOp1",				info.RefineryOp1 );
	ParseInt( param, "RefineryOp2",				info.RefineryOp2 );
	ParseInt( param, "AttrAttackType",			info.AttackAttributeType );
	ParseInt( param, "AttrAttackValue",			info.AttackAttributeValue );
	ParseInt( param, "AttrDefenseValueFire",	info.DefenseAttributeValueFire );
	ParseInt( param, "AttrDefenseValueWater",	info.DefenseAttributeValueWater );
	ParseInt( param, "AttrDefenseValueWind",	info.DefenseAttributeValueWind );
	ParseInt( param, "AttrDefenseValueEarth",	info.DefenseAttributeValueEarth );
	ParseInt( param, "AttrDefenseValueHoly",	info.DefenseAttributeValueHoly );
	ParseInt( param, "AttrDefenseValueUnholy",	info.DefenseAttributeValueUnholy );

	// 신규 집혼 추가 (2015-03-09)
	ParseInt( param, "EnsoulOptionNum_" $ EIST_BM    , ensoulBmSlot );
	ParseInt( param, "EnsoulOptionNum_" $ EIST_NORMAL, ensoulNormalSlot );

	// 아이템에 집혼 정보를 적용 시킴
	addEnsoulInfo(EIST_BM     , ensoulBmSlot, param, info);
	addEnsoulInfo(EIST_NORMAL , ensoulNormalSlot, param, info);
	
	m_nCurrentMultiSellInfoIndex = m_MultiSellInfoList.Length;
	m_MultiSellInfoList.Length   = m_MultiSellInfoList.Length + 1;

	nRepeatTimeCurrentInputItemInfoIndex = 0;
	
	//Debug("nMultiSellInfoID" @ nMultiSellInfoID);

	m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].MultiSellInfoID	= nMultiSellInfoID;
	m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].MultiSellType		= nBuyType;
	m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].ResultItemInfo	= info;
}

// HandelMultiSellOutputItemInfo
function HandelMultiSellOutputItemInfo( string param )
{
	local int		nMultiSellInfoID;
	local int		nCurrentOutputItemInfoIndex;
	local ItemInfo	info;
	local int		nItemClassID;
	// 신규 집혼 적용
	local int       ensoulNormalSlot, ensoulBmSlot;

	//~ local ItemInfo	info;
	//~ ParseItemID( param, info.Id );	
	//~ ParseInt( param, "MultiSellInfoID",			nMultiSellInfoID );
		
	// Debug("입력값-------------param" @ param);
	ParseItemID( param, info.ID );
	class'UIDATA_ITEM'.static.GetItemInfo( info.ID, info );

	ParseInt( param, "ClassID",					nItemClassID );
	ParseInt( param, "MultiSellInfoID",			nMultiSellInfoID );
	ParseInt64( param, "SlotBitType",			info.SlotBitType ); // INT -> INT64, JEWEL 추가 - by y2jinc (2013. 9. 2)
	ParseInt( param, "ItemType",				info.ItemType );
	ParseInt64( param, "ItemCount",				info.ItemNum);
	ParseInt( param, "Enchant",					info.Enchanted );
	ParseInt( param, "RefineryOp1",				info.RefineryOp1);
	ParseInt( param, "RefineryOp2",				info.RefineryOp2);
	ParseInt( param, "AttrAttackType",			info.AttackAttributeType );
	ParseInt( param, "AttrAttackValue",			info.AttackAttributeValue );
	ParseInt( param, "AttrDefenseValueFire",	info.DefenseAttributeValueFire );
	ParseInt( param, "AttrDefenseValueWater",	info.DefenseAttributeValueWater );
	ParseInt( param, "AttrDefenseValueWind",	info.DefenseAttributeValueWind );
	ParseInt( param, "AttrDefenseValueEarth",	info.DefenseAttributeValueEarth );
	ParseInt( param, "AttrDefenseValueHoly",	info.DefenseAttributeValueHoly );
	ParseInt( param, "AttrDefenseValueUnholy",	info.DefenseAttributeValueUnholy );
	
	// 신규 집혼 추가 (2015-03-09)
	ParseInt( param, "EnsoulOptionNum_" $ EIST_BM    , ensoulBmSlot );
	ParseInt( param, "EnsoulOptionNum_" $ EIST_NORMAL, ensoulNormalSlot );

	// 아이템에 집혼 정보를 적용 시킴
	addEnsoulInfo(EIST_BM     , ensoulBmSlot, param, info);
	addEnsoulInfo(EIST_NORMAL , ensoulNormalSlot, param, info);

	if(m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].MultiSellInfoID != nMultiSellInfoID)
	{
		//debug("MultiSellWnd::HandelMultiSellOutputItemInfo - Invalid nMultiSellInfoID");
		return;
	}

	if( nItemClassID == MSIT_PCCAFE_POINT )
	{
		info.Name = GetSystemString(1277);
		info.IconName = GetPcCafeItemIconPackageName();//"icon.etc_i.etc_pccafe_point_i00";
		info.Enchanted = 0;
		info.ItemType = -1;
		info.Id.ClassID = 0;
	}
	else if( nItemClassID == MSIT_PLEDGE_POINT )
	{
		info.Name = GetSystemString( 1311 );
		info.IconName = "icon.etc_i.etc_bloodpledge_point_i00";
		info.Enchanted = 0;
		info.ItemType = -1;
		info.Id.ClassID = 0;
	}	
	else if( nItemClassID == MSIT_PVP_POINT )
	{
		info.Name = GetSystemString( 102 );
		info.IconName = "icon.pvp_point_i00";
		info.Enchanted = 0;
		info.ItemType = -1;
		info.Id.ClassID = 0;
	}
	else if ( nItemClassID == MSIT_RAID_POINT )
	{
		info.Name  = GetSystemString( 3183 );
		info.IconName = "icon.etc_i.etc_rp_point_i00";
		info.Enchanted = 0;
		info.ItemType = -1;
		info.Id.ClassID = 0;
	}

	// 투영병기의 경우 강제로, 100% Durability를 표시하게 합니다 - NeverDie
	if( 0 < info.Durability )
	{
		info.CurrentDurability = info.Durability;
	}

	nCurrentOutputItemInfoIndex = m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].OutputItemInfoList.Length;
	m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].OutputItemInfoList.Length = nCurrentOutputItemInfoIndex + 1;
	m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].OutputItemInfoList[nCurrentOutputItemInfoIndex] = info;

	// 현재 출력되고 있는 전체 목록의 index를 임시로 저장시킨다.
	m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].OutputItemInfoList[nCurrentOutputItemInfoIndex].Reserved = m_nCurrentMultiSellInfoIndex;
}

// HandelMultiSellInputItemInfo
function HandelMultiSellInputItemInfo( string param )
{
	local int		nMultiSellInfoID;
	local int		nCurrentInputItemInfoIndex;
	local int		nItemClassID;
	local ItemInfo	info;

	// 신규 집혼 적용
	local int       ensoulNormalSlot, ensoulBmSlot;

	ParseItemID( param, info.Id );
	class'UIDATA_ITEM'.static.GetItemInfo( info.Id, info );

	ParseInt( param, "MultiSellInfoID",			nMultiSellInfoID );
	ParseInt( param, "ClassID",					nItemClassID );
	ParseInt( param, "ItemType",				info.ItemType );
	ParseInt64( param, "ItemCount",				info.ItemNum);
	ParseInt( param, "Enchant",					info.Enchanted );
	ParseInt( param, "RefineryOp1",				info.RefineryOp1);
	ParseInt( param, "RefineryOp2",				info.RefineryOp2);
	ParseInt( param, "AttrAttackType",			info.AttackAttributeType );
	ParseInt( param, "AttrAttackValue",			info.AttackAttributeValue );
	ParseInt( param, "AttrDefenseValueFire",	info.DefenseAttributeValueFire );
	ParseInt( param, "AttrDefenseValueWater",	info.DefenseAttributeValueWater );
	ParseInt( param, "AttrDefenseValueWind",	info.DefenseAttributeValueWind );
	ParseInt( param, "AttrDefenseValueEarth",	info.DefenseAttributeValueEarth );
	ParseInt( param, "AttrDefenseValueHoly",	info.DefenseAttributeValueHoly );
	ParseInt( param, "AttrDefenseValueUnholy",	info.DefenseAttributeValueUnholy );

	// 신규 집혼 추가 (2015-03-09)
	ParseInt( param, "EnsoulOptionNum_" $ EIST_BM    , ensoulBmSlot );
	ParseInt( param, "EnsoulOptionNum_" $ EIST_NORMAL, ensoulNormalSlot );

	// 아이템에 집혼 정보를 적용 시킴
	addEnsoulInfo(EIST_BM     , ensoulBmSlot, param, info);
	addEnsoulInfo(EIST_NORMAL , ensoulNormalSlot, param, info);

	if(m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].MultiSellInfoID != nMultiSellInfoID)
	{
		//debug("MultiSellWnd::HandelMultiSellInputItemInfo - Invalid nMultiSellInfoID");
		return;
	}
	
	if( nItemClassID == MSIT_PCCAFE_POINT )
	{
		info.Name = GetSystemString(1277);
		info.IconName = GetPcCafeItemIconPackageName();//"icon.etc_i.etc_pccafe_point_i00";
		info.Enchanted = 0;
		info.ItemType = -1;
		info.Id.ClassID = 0;
	}
	else if( nItemClassID == MSIT_PLEDGE_POINT )
	{
		info.Name = GetSystemString( 1311 );
		info.IconName = "icon.etc_i.etc_bloodpledge_point_i00";
		info.Enchanted = 0;
		info.ItemType = -1;
		info.Id.ClassID = 0;
	}	
	else if( nItemClassID == MSIT_PVP_POINT )
	{
		info.Name = GetSystemString( 102 );
		info.IconName = "icon.pvp_point_i00";
		info.Enchanted = 0;
		info.ItemType = -1;
		info.Id.ClassID = 0;
	}
	else if ( nItemClassID == MSIT_RAID_POINT )
	{
		info.Name  = GetSystemString( 3183 );
		info.IconName = "icon.etc_i.etc_rp_point_i00";
		info.Enchanted = 0;
		info.ItemType = -1;
		info.Id.ClassID = 0;
	}
	else
	{
		info.Name = class'UIDATA_ITEM'.static.GetItemName( info.Id );
		info.IconName = class'UIDATA_ITEM'.static.GetItemTextureName( info.Id );
	}

	// 이걸 왜 이렇게 하는지 의문.. 아이템 타입이 아니다. 
	// info.ItemType = class'UIDATA_ITEM'.static.GetItemDataType( info.Id );
	info.CrystalType = class'UIDATA_ITEM'.static.GetItemCrystalType( info.Id );
	
	//-400 필드사이클일 경우 아무 데이터도 삽입 안하는 것으로 처리 함. 
	if (nItemClassID != MSIT_FIELD_CYCLE_POINT )
	{
		// 결과 이후, 모두 보여줄때와, 입력 데이타만 업데이트
		//if (nRepeat == 1 && nShowAll == 1)
		//{
		//	if(m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].InputItemInfoList.Length > nRepeatTimeCurrentInputItemInfoIndex)
		//	{
		//		m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].InputItemInfoList[nRepeatTimeCurrentInputItemInfoIndex] = info;
		//		nRepeatTimeCurrentInputItemInfoIndex++;
		//	}
		//}
		//else
		//{
		//}

			nCurrentInputItemInfoIndex = m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].InputItemInfoList.Length;
			m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].InputItemInfoList.Length = nCurrentInputItemInfoIndex + 1;
			m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].InputItemInfoList[nCurrentInputItemInfoIndex] = info;

	}
}

// HandleMultiSellInfoListEnd
function HandleMultiSellInfoListEnd( string param )
{
	// local ItemInfo nullInfo;


	if(!Me.IsShowWindow()) 
	{
		Me.ShowWindow();
		// Me.SetFocus();
	}
	
	updateMultiSellData();
	//ShowItemList();
	
	//if (nRepeat <= 0 || nShowAll <= 0) 
	//{		
	//	Debug("다시 목록 갱신 HandleMultiSellInfoListEnd");
		
	//}
	//else
	//{
	//	Debug("암함 목록 갱신 HandleMultiSellInfoListEnd");
	//}

	//Debug("lastSelectItemInfo.Id.ClassID" @ lastSelectItemInfo.Id.ClassID);
	//Debug("Name:::" @ lastSelectItemInfo.Name);
	//Debug("Name:::" @ lastSelectItemInfo.Reserved);
	

	//if (lastSelectItemInfo.Id.ClassID > 0) setSelectItem(lastSelectItemInfo);

	//updateUIControl();

	//lastSelectItemInfo = nullInfo;


//	setTreeItemInfo();
}
//	// 틱 시작
//	Me.EnableTick();


	
function onTick()
{
	local int i;

	// tick당 돌릴 수량
	//for(i = tickItemListIndex; i < m_MultiSellInfoList.Length; i++)
	//{		
		
	//	//tickItemListIndex++;
	//}

	for(i = 0; i < 50; i++)
	{
		tickItemAdd();

		tickItemListIndex++;	

		if(tickItemListIndex >= m_MultiSellInfoList.Length) 
		{
			Me.DisableTick();
			useTick = false;

			Debug("최종 bForceUpdate" @ bForceUpdate);
			bFirstAdd = false;
			bForceUpdate = false;
			

			// 검색모드와 전체목록 모드에 따라 아이템이 없을떄 나오는 disable 메세지를 다
			if(searchMode)
			{
				// 전체 목록
				if (MultiSellTab.GetTopIndex() == 0)
				{
					if (MultisellTabTotalWnd_ItemWindow.GetItemNum() <= 0)
						disableWindowWithText(true, MakeFullSystemMsg(GetSystemMessage(4356), searchStr)); // <$s1>\n검색어에 해당되는 아이템이 없습니다
					
					else
						disableWindowWithText(false, ""); 
				}
				else
				{
					if (MultisellTabEnableWnd_ItemWindow.GetItemNum() <= 0)
						disableWindowWithText(true, MakeFullSystemMsg(GetSystemMessage(4356), searchStr)); // <$s1>\n검색어에 해당되는 아이템이 없습니다
					else
						disableWindowWithText(false, "");   
				}
			}
			else
			{
				// 교환가능 탭이고, 교환가능한 아이템이 없으면..
				if (MultiSellTab.GetTopIndex() == 1 && MultisellTabEnableWnd_ItemWindow.GetItemNum() <= 0) 
					disableWindowWithText(true, GetSystemMessage(4357)); // 교환 가능한 아이템이 없습니다.
				else 
					disableWindowWithText(false, "");
			}

			Me.KillTimer(TIMER_UPDATE_ID);
			Me.SetTimer(TIMER_UPDATE_ID, TIMER_UPDATEDELAY);

			break;
		}
	}
}

function tickItemAdd()
{
	local int i;
	local ItemInfo info;
	local string fullNameString;
	local array<NoStackableItemData> NoStackableItemDataArray;
	local bool bNoExchange, bCheck;
	local int arrayIndex, n;
	
	i = tickItemListIndex;

	if (m_MultiSellInfoList.Length > i)
	{
		info = m_MultiSellInfoList[i].OutputItemInfoList[0];

		if (bFirstAdd || isExchangeWindowState()) Search_EditBox.AddNameToAdditionalSearchList(info.name, ESearchListType.SLT_ADDITIONAL_LIST);

		fullNameString = GetItemNameAll(info);

		// 키워드가 매칭될때,  검색모드가 아니면 그냥 통과
		if (findMatchString(fullNameString, searchStr) != -1 || searchMode == false)
		{
			bNoExchange = false;

			NoStackableItemDataArray.Length = 0; 
			
			for(n=0; n < m_MultiSellInfoList[i].InputItemInfoList.Length; n++)
			{				
				// 수량성 아이템인가?
				if (IsStackableItem(m_MultiSellInfoList[i].InputItemInfoList[n].ConsumeType))
				{
					

					bCheck = compareWithInven(m_MultiSellInfoList[i].InputItemInfoList[n]);

					//bCheck = class'UIDATA_INVENTORY'.static.HasItemByClassID(m_MultiSellInfoList[i].InputItemInfoList[n].Id.ClassID);
					//Debug("m_MultiSellInfoList[i].InputItemInfoList[n].Id.ClassID" @ m_MultiSellInfoList[i].InputItemInfoList[n].Id.ClassID);
					Debug("수량성 아이템인지.. bCheck" @ bCheck);


				}
				else
				{
					arrayIndex = getNoStackableItemCountArrayIndex(m_MultiSellInfoList[i].InputItemInfoList[n], NoStackableItemDataArray, true);
					bCheck = compareWithInven(m_MultiSellInfoList[i].InputItemInfoList[n], NoStackableItemDataArray[arrayIndex]);
				}

				if(bCheck == false) bNoExchange = true;
			}

			if (bNoExchange == false)
			{

				// 교환 가능한 아이콘
				info.ForeTexture = "L2UI_CT1.SellablePanel";									

				// 구매 가능한 목록 추가				
				MultisellTabEnableWnd_ItemWindow.AddItem(info);
				addItem_ListCtrl(MultisellTabEnableWnd_ListCtrl, info);
			}
				
			// Debug("bForceUpdate" @ bForceUpdate);
			// 최초로 목록이 들어 올때 전체 탭에 추가, 그외에는 검색에서 강제로 추가 
			if (bFirstAdd || bForceUpdate)
			{
				// 전체 목록에 추가
				MultisellTabTotalWnd_ItemWindow.AddItem(info);
				addItem_ListCtrl(MultisellTabTotalWnd_ListCtrl, info);
				// Debug("추가 MultisellTabTotalWnd_ListCtrl :" @ info.Name);
			}
			else
			{
				// 전체 탭 상태일때만 업데이트
				if (isExchangeWindowState() == false)
				{
					MultisellTabTotalWnd_ItemWindow.SetItem(i, info);
					setItem_ListCtrl(MultisellTabTotalWnd_ListCtrl, i, info);
					// Debug("업데이트 MultisellTabTotalWnd_ListCtrl : " @ i  @ info.Name );
				}
			}
		}
	}
}

// 아이템 목록을 추가한다. 
function ShowItemList()
{
	//local ItemInfo info;
	//local int i, n;
	//local bool bNoExchange, bCheck;
	
	//
	//local int arrayIndex;//index, , nClassID;
	//local Int64 noStackableNeedItemNum;

	//local array<NoStackableItemData> NoStackableItemDataArray;

	//local ItemInfo rItemInfo;
	//local string fullNameString, searchStr;
	//local bool searchMode;
	//local int nfindMatch;

	// 무언가 들어 있다면.. 

	//disableWindowWithText(true, "");

	searchStr = Search_EditBox.GetString();
	
	// 전체 목록을 보여 주는 모드와 키워드 검색을 할 수 있는 모드가 있다. 
	if (searchStr != "") 
	{
		searchMode = true;
		bFirstAdd = true;

		Debug("검색모드 On");
	}
	else
	{
		//if (nShowAll == 1 && bFirstAdd == true)
		//{
		//}
		
		searchMode = false;
		Debug("전체 갱신 모드 On");
	}
	
	
	setButtonEnable(false);

	Debug("searchMode: " @ searchMode);
	Debug("bFirstAdd: " @ bFirstAdd);

	// 아이템 정보, 필요아이템 부분, 초기화
	class'UIAPI_MULTISELLITEMINFO'.static.Clear("MultiSellWnd.multiSellItemInfo");
	NeededItem_TreeCtrl.Clear();
	
	//updateMultiSellData();
	
	if (bFirstAdd || bForceUpdate)
	{
		Debug("-------> 리스트, 아이템 윈도우 초기화");
		iniListWithItemWindow();
		Search_EditBox.ClearAdditionalSearchList(ESearchListType.SLT_ADDITIONAL_LIST);
	}

	//  교환가능, 창 상태면 무조건 업데이트를 해야한다. 
	if(isExchangeWindowState())
	{
		Debug("-------> 교환 가능 관련 윈도우 초기화");
		ItemCount_EditBox.SetString("1");

		MultisellTabEnableWnd_ItemWindow.Clear();
		MultisellTabEnableWnd_ListCtrl.DeleteAllItem();
	}

	tickItemListIndex = 0;
	useTick = true;
	Me.EnableTick();
}

function bool isExchangeWindowState()
{
	return (MultiSellTab.GetTopIndex() == 1 || bForceUpdate);
}

//// 아이템 목록을 추가한다. 
//function fildAndShowItemList(string searchStr)
//{
//	local ItemInfo info;
//	local int i, n, arrayIndex;
//	local string fullNameString;
//	local bool bNoExchange, bCheck;
//	local array<NoStackableItemData> NoStackableItemDataArray;

//	iniListWithItemWindow();	
//	setButtonEnable(false);
//	bFirstAdd = true;

//	for( i=0 ; i < m_MultiSellInfoList.Length ; ++i )
//	{
//		info = m_MultiSellInfoList[i].OutputItemInfoList[0];
//		fullNameString = GetItemNameAll(info);

//		if (findMatchString(fullNameString, searchStr) != -1)
//		{
//			bNoExchange = false;

//			NoStackableItemDataArray.Length = 0;
//			// 필요 아이템이 있는지 조사
//			for(n=0; n < m_MultiSellInfoList[i].InputItemInfoList.Length; ++n)
//			{
//				if (IsStackableItem(m_MultiSellInfoList[i].InputItemInfoList[n].ConsumeType))
//				{
//					bCheck = compareWithInven(m_MultiSellInfoList[i].InputItemInfoList[n]);
//				}
//				else
//				{
//					arrayIndex = getNoStackableItemCountArrayIndex(m_MultiSellInfoList[i].InputItemInfoList[n], NoStackableItemDataArray);
//					bCheck = compareWithInven(m_MultiSellInfoList[i].InputItemInfoList[n], NoStackableItemDataArray[arrayIndex]);
//				}
					
//				if(bCheck == false) bNoExchange = true;
//			}

//			if (bNoExchange == false)
//			{
//				// 교환 가능한 아이콘
//				info.ForeTexture = "L2UI_CT1.SellablePanel";
				
//				// 구매 가능한 목록 추가 
//				MultisellTabEnableWnd_ItemWindow.AddItem(info);
//				addItem_ListCtrl(MultisellTabEnableWnd_ListCtrl, info);
//			}

//			// 전체 목록에 추가
//			MultisellTabTotalWnd_ItemWindow.AddItem(info);
//			addItem_ListCtrl(MultisellTabTotalWnd_ListCtrl, info);
//		}
//	}

//	// 전체 목록
//	if (MultiSellTab.GetTopIndex() == 0)
//	{
//		if (MultisellTabTotalWnd_ItemWindow.GetItemNum() <= 0)
//			disableWindowWithText(true, MakeFullSystemMsg(GetSystemMessage(4356), searchStr)); // <$s1>\n검색어에 해당되는 아이템이 없습니다
		
//		else
//			disableWindowWithText(false, ""); 
//	}
//	else
//	{
//		if (MultisellTabEnableWnd_ItemWindow.GetItemNum() <= 0)
//			disableWindowWithText(true, MakeFullSystemMsg(GetSystemMessage(4356), searchStr)); // <$s1>\n검색어에 해당되는 아이템이 없습니다
//		else
//			disableWindowWithText(false, "");   
//	}

//	// -_-..주석해봤음..6.18
//	//updateUIControl();
//}

// 검색 후 결과 값이 없으면 보여줄 텍스트 
function disableWindowWithText(bool bShow, string msgTxt)
{
	
	if(bShow)
	{
		DescriptionMsg_Text.SetText(msgTxt);
		GetWindowHandle("MultiSellWnd.DescriptionMsgWnd").ShowWindow();	
	}
	else
	{
		GetWindowHandle("MultiSellWnd.DescriptionMsgWnd").HideWindow();	
		
	}
}

// 인벤토리와 비교
function bool compareWithInven(ItemInfo info, optional NoStackableItemData noStackableItemDataInfo)
{
	local ItemInfo InvenItemInfo;
	local bool flag;
	local int hasItemCount;
	local array<ItemInfo> itemInfoArr;

	// MSIT_PCCAFE_POINT 
	if( info.IconName == GetPcCafeItemIconPackageName()) 
	{	
		// Debug("pcUIDataScript.getCurrentPcCafePoint()" @ UIDataScript.getCurrentPcCafePoint());
		if (mData.pcCafePoint >= info.ItemNum) return true;
	}
	// MSIT_PLEDGE_POINT
	else if( info.IconName == "icon.etc_i.etc_bloodpledge_point_i00" ) 
	{
		if (mData.clanPoint >= info.ItemNum) return true;
	}	
	// MSIT_PVP_POINT
	else if( info.IconName == "icon.pvp_point_i00")
	{
		if (mData.pvpPoint >= info.ItemNum) return true;
	}
	// MSIT_RAID_POINT
	else if ( info.IconName == "icon.etc_i.etc_rp_point_i00") 
	{
		if (mData.raidPoint >= info.ItemNum) return true;
	}
	// 인벤토리에 있나
	else
	{
		if (info.ID.ClassID > 0)
		{
			// 아이템이 인벤에 있나? classID 로 비교
			itemInfoArr.Length = 0;
			hasItemCount = getInstanceL2Util().FindItemByClassID (info.ID.ClassID, itemInfoArr, getInstanceL2Util().EItemLockedCheckType.UNLOCK );
			//hasItemCount = class'UIDATA_INVENTORY'.static.FindItemByClassID(info.ID.ClassID, itemInfoArr);
			// Debug("info.Name" @ info.Name @ "hasItemCount" @ hasItemCount);
			
			if(hasItemCount > 0)
			{
				// 아이템을 가지고 있다면
				InvenItemInfo = itemInfoArr[0];
				// 수량에 맞게 있나?
				if(IsStackableItem( InvenItemInfo.ConsumeType ))
				{
					if (InvenItemInfo.ItemNum >= info.ItemNum) return true;
				}
				else
				{
					// 비수량성 아이템은 별도의 수량을 표시 하지 않고 존재 한다는 의미로 1 를 넣는다.
					if (noStackableItemDataInfo.ClassID > 0)
					{
						if (noStackableItemDataInfo.count > 0) flag = true;
					}

					return flag;
				}
			}
		}
	}

	return false;
}

/** 아이템을 추가 한다. */
function addItem_ListCtrl(ListCtrlHandle ItemListCtrl, itemInfo info)
{
	local LVDataRecord Record;
	local string param, fullNameString;
	
	fullNameString = GetItemNameAll(info);

	ItemInfoToParam(info, param);
	
	Record.szReserved = param;

	Record.nReserved1 = Int64(info.Id.ClassID);
	Record.LVDataList.length = 2;

	// 수량성 아이템은 (1) 표시
	if ( IsStackableItem( info.ConsumeType ) ) 
	{   
		fullNameString = makeShortStringByPixel(fullNameString, 212, "..");
		
		if (info.ItemNum > 0) fullNameString = fullNameString $ "(" $ info.ItemNum $ ")"; 
		else fullNameString = fullNameString $ "(1)";
	}
	else
	{
		 fullNameString = makeShortStringByPixel(fullNameString, 230, "..");
	}

	// 툴팁 정보 넣기
	ItemInfoToParam(info, param);	
	Record.szReserved = param;

	Record.LVDataList[0].szData = fullNameString;
	Record.LVDataList[0].hasIcon = true;
	Record.LVDataList[0].nTextureWidth=32;
	Record.LVDataList[0].nTextureHeight=32;
	Record.LVDataList[0].nTextureU=32;
	Record.LVDataList[0].nTextureV=32;
	Record.LVDataList[0].szTexture = info.IconName; 
	Record.LVDataList[0].IconPosX=10;
	Record.LVDataList[0].FirstLineOffsetX=6;

	//Record.LVDataList[0].HiddenStringForSorting = String(itemIndex);// $ util.makeZeroString(3, enchanted);
	// Record.LVDataList[0].HiddenStringForSorting = itemName $ util.makeZeroString(3, enchanted);
	
	// back texture 
	Record.LVDataList[0].iconBackTexName="l2ui_ct1.ItemWindow_DF_SlotBox_Default";
	Record.LVDataList[0].backTexOffsetXFromIconPosX=-2;
	Record.LVDataList[0].backTexOffsetYFromIconPosY=-1;
	Record.LVDataList[0].backTexWidth=36;
	Record.LVDataList[0].backTexHeight=36;
	Record.LVDataList[0].backTexUL=36;
	Record.LVDataList[0].backTexVL=36;

	// 아이콘 테두리 (기본 병기.pvp 무기등)
	Record.LVDataList[0].iconPanelName = info.iconPanel;
	Record.LVDataList[0].panelOffsetXFromIconPosX=0;
	Record.LVDataList[0].panelOffsetYFromIconPosY=0;
	Record.LVDataList[0].panelWidth=32;
	Record.LVDataList[0].panelHeight=32;
	Record.LVDataList[0].panelUL=32;
	Record.LVDataList[0].panelVL=32;

	Record.LVDataList[0].foreTextureName = info.foreTexture;	

	ItemListCtrl.InsertRecord( Record );
}

function setItem_ListCtrl(ListCtrlHandle ItemListCtrl, int sindex, itemInfo info)
{
	local LVDataRecord Record;
	local string param, fullNameString;
	
	fullNameString = GetItemNameAll(info);

	ItemInfoToParam(info, param);
	
	Record.szReserved = param;

	Record.nReserved1 = Int64(info.Id.ClassID);
	Record.LVDataList.length = 2;

	// 수량성 아이템은 (1) 표시
	if ( IsStackableItem( info.ConsumeType ) ) 
	{   
		fullNameString = makeShortStringByPixel(fullNameString, 212, "..");
		//fullNameString = fullNameString $ "(1)";

		if (info.ItemNum > 0) fullNameString = fullNameString $ "(" $ info.ItemNum $ ")"; 
		else fullNameString = fullNameString $ "(1)";
	}
	else
	{
		 fullNameString = makeShortStringByPixel(fullNameString, 230, "..");
	}

	// 툴팁 정보 넣기
	ItemInfoToParam(info, param);	
	Record.szReserved = param;

	Record.LVDataList[0].szData = fullNameString;
	Record.LVDataList[0].hasIcon = true;
	Record.LVDataList[0].nTextureWidth=32;
	Record.LVDataList[0].nTextureHeight=32;
	Record.LVDataList[0].nTextureU=32;
	Record.LVDataList[0].nTextureV=32;
	Record.LVDataList[0].szTexture = info.IconName; 
	Record.LVDataList[0].IconPosX=10;
	Record.LVDataList[0].FirstLineOffsetX=6;

	//Record.LVDataList[0].HiddenStringForSorting = String(itemIndex);// $ util.makeZeroString(3, enchanted);
	// Record.LVDataList[0].HiddenStringForSorting = itemName $ util.makeZeroString(3, enchanted);
	
	// back texture 
	Record.LVDataList[0].iconBackTexName="l2ui_ct1.ItemWindow_DF_SlotBox_Default";
	Record.LVDataList[0].backTexOffsetXFromIconPosX=-2;
	Record.LVDataList[0].backTexOffsetYFromIconPosY=-1;
	Record.LVDataList[0].backTexWidth=36;
	Record.LVDataList[0].backTexHeight=36;
	Record.LVDataList[0].backTexUL=36;
	Record.LVDataList[0].backTexVL=36;

	// 아이콘 테두리 (기본 병기.pvp 무기등)
	Record.LVDataList[0].iconPanelName = info.iconPanel;
	Record.LVDataList[0].panelOffsetXFromIconPosX=0;
	Record.LVDataList[0].panelOffsetYFromIconPosY=0;
	Record.LVDataList[0].panelWidth=32;
	Record.LVDataList[0].panelHeight=32;
	Record.LVDataList[0].panelUL=32;
	Record.LVDataList[0].panelVL=32;

	Record.LVDataList[0].foreTextureName = info.foreTexture;	

	ItemListCtrl.ModifyRecord(sindex, Record);
}


// 멀티셀 에서 사용하는 데이타를 갱신한다.
function updateMultiSellData(optional string serverUpdateParam)
{
	// 서버 결과 값에 따라서 여기서 
	local int nPointCount, nPoint, nType, n;

	// Debug("--------이벤트 param" @ serverUpdateParam);

	// 유저 정보를 새로 받고..
	GetPlayerInfo(playerInfo);

	ParseInt( serverUpdateParam, "NumPoint", nPointCount );
	
	for (n = 0; n < nPointCount; n++)
	{
		ParseInt( serverUpdateParam, "Type"  $ String(n), nType );
		ParseInt( serverUpdateParam, "Point" $ String(n), nPoint );

		if (MSIT_RAID_POINT == nType)
		{
			mData.pvpPoint = nPoint;
		}
		else if (MSIT_PVP_POINT == nType)
		{
			mData.pvpPoint = nPoint;			
		}
		else if (MSIT_PLEDGE_POINT == nType)
		{
			mData.clanPoint = nPoint;
			UIDataScript.setCurrentClanNameValue(nPoint);
		}
		else if (MSIT_PCCAFE_POINT == nType)
		{   
			mData.pcCafePoint = nPoint;
			UIDataScript.setPcCafePoint(nPoint);

			

			Debug("mData.pcCafePoint" @ mData.pcCafePoint);
		}
	}
	
	//Debug("nPointCount" @ nPointCount);

	// 서버에서 지정한 값으로 업데이트가 아닌 경우 내부 정보로 업데이트
	if (nPointCount <= 0)
	{
		mData.pvpPoint    = playerInfo.PvPPoint;
		mData.raidPoint   = playerInfo.RaidPoint;
		mData.pcCafePoint = UIDataScript.getCurrentPcCafePoint();
		mData.clanPoint   = UIDataScript.getCurrentClanNameValue();
	}
}


//-----------------------------------------------------------------------------------------------------------
// HandleDialogOK
//-----------------------------------------------------------------------------------------------------------
function HandleDialogOK(bool bOK)
{
	local string param;
	local int SelectedIndex, id, tryExchangeCount;
	local INT64 inputNum;
		
	if( DialogIsMine() )
	{
		DisableWnd.HideWindow();
		
		id = DialogGetID();
		// ok를 눌렀을때 
		if (bOK)
		{
			if (id == DIALOG_ASK_PRICE)
			{
				inputNum = INT64( DialogGetString() );
				// 0은 입력 못하도록..
				if (inputNum <= 0) inputNum = 1;
				ItemCount_EditBox.SetString(String(inputNum));
				setTreeNeedItemInfo();
			}
			else
			{
				tryExchangeCount = int(ItemCount_EditBox.GetString());

				ItemCount_EditBox.SetString("1");
				setTreeNeedItemInfo();

				SelectedIndex = DialogGetReservedInt();

				if( SelectedIndex >= m_MultiSellInfoList.Length )
				{
					//debug("MultiSellWnd::HandleDialogOK - Invalid SelectIndex(" $ SelectedIndex $ ")" );
					return;
				}
				
				ParamAdd( param, "MultiSellGroupID",		string( m_MultiSellGroupID ) );
				ParamAdd( param, "MultiSellInfoID",			string( m_MultiSellInfoList[SelectedIndex].MultiSellInfoID ) );
				ParamAdd( param, "ItemCount",				string( DialogGetReservedInt2() ) );
				ParamAdd( param, "Enchant",					string( m_MultiSellInfoList[SelectedIndex].ResultItemInfo.Enchanted ) );
				ParamAdd( param, "RefineryOp1",				string( m_MultiSellInfoList[SelectedIndex].ResultItemInfo.RefineryOp1 ) );
				ParamAdd( param, "RefineryOp2",				string( m_MultiSellInfoList[SelectedIndex].ResultItemInfo.RefineryOp2 ) );
				ParamAdd( param, "AttrAttackType",			string( m_MultiSellInfoList[SelectedIndex].ResultItemInfo.AttackAttributeType ) );
				ParamAdd( param, "AttrAttackValue",			string( m_MultiSellInfoList[SelectedIndex].ResultItemInfo.AttackAttributeValue ) );
				ParamAdd( param, "AttrDefenseValueFire",	string( m_MultiSellInfoList[SelectedIndex].ResultItemInfo.DefenseAttributeValueFire ) );
				ParamAdd( param, "AttrDefenseValueWater",	string( m_MultiSellInfoList[SelectedIndex].ResultItemInfo.DefenseAttributeValueWater ) );
				ParamAdd( param, "AttrDefenseValueWind",	string( m_MultiSellInfoList[SelectedIndex].ResultItemInfo.DefenseAttributeValueWind ) );
				ParamAdd( param, "AttrDefenseValueEarth",	string( m_MultiSellInfoList[SelectedIndex].ResultItemInfo.DefenseAttributeValueEarth ) );
				ParamAdd( param, "AttrDefenseValueHoly",	string( m_MultiSellInfoList[SelectedIndex].ResultItemInfo.DefenseAttributeValueHoly ) );
				ParamAdd( param, "AttrDefenseValueUnholy",	string( m_MultiSellInfoList[SelectedIndex].ResultItemInfo.DefenseAttributeValueUnholy ) );

				addParamEnsoulOptionInfo(m_MultiSellInfoList[SelectedIndex].ResultItemInfo, param); 

				Debug("RequestMultiSellChoose : " @ param);
				RequestMultiSellChoose( param );
			}
		}
		else
		{
			DisableWnd.HideWindow();
		}
	}
}


//-----------------------------------------------------------------------------------------------------------
// OnClickItem, OnClickListCtrlRecord, OnClickButton
//-----------------------------------------------------------------------------------------------------------
function OnDBClickItem( string Name, int index )
{
	// Debug("Name" @ Name);

	if (Name == "MultisellTabTotalWnd_ItemWindow" || Name == "MultisellTabEnableWnd_ItemWindow" )
	{
		OnExChange_ButtonClick();
	}
}

function OnDBClickListCtrlRecord(string ListCtrlID)
{
	// Debug("ListCtrlID" @ ListCtrlID);
	if (Me.IsShowWindow()) OnExChange_ButtonClick();
}

function OnClickItem(string strID, int index )
{	
	if (strID == "MultisellTabTotalWnd_ItemWindow")
	{		
		updateMultiSellData();
		MultisellTabTotalWnd_ListCtrl.SetSelectedIndex(index, true);		
		Me.KillTimer( TIMER_UPDATE_ID );
		updateUIControl();
	}
	else if (strID == "MultisellTabEnableWnd_ItemWindow")
	{		
		updateMultiSellData();
		MultisellTabEnableWnd_ListCtrl.SetSelectedIndex(index, true);
		Me.KillTimer( TIMER_UPDATE_ID );
		updateUIControl();
	}
}

function OnClickListCtrlRecord( string ListCtrlID)
{	
	switch( ListCtrlID )
	{
		case "MultisellTabTotalWnd_ListCtrl" :
			 updateMultiSellData();
			 MultisellTabTotalWnd_ItemWindow.SetSelectedNum(MultisellTabTotalWnd_ListCtrl.GetSelectedIndex());
			 Me.KillTimer( TIMER_UPDATE_ID );
			 updateUIControl();
			 break;

		case "MultisellTabEnableWnd_ListCtrl" :
			 updateMultiSellData();
			 MultisellTabEnableWnd_ItemWindow.SetSelectedNum(MultisellTabEnableWnd_ListCtrl.GetSelectedIndex());
			 Me.KillTimer( TIMER_UPDATE_ID );
			 updateUIControl();
			 break;
	}
}

function OnClickButton( string Name )
{
	// Debug("Name" @Name);
	switch( Name )
	{
		case "InventoryViewerCall_Button":
			 //toggleWindow("InventoryViewer");
			 //Me.SetFocus();
			 getInstanceInventoryViewer().showWindowByParentWindow(Me, true);
			 
			 break;

		case "Search_Button":
			 OnSearch_ButtonClick();
			 break;

		// 검색 초기화
		case "Refrash_Button":
			 OnRefrash_ButtonClick();
			 break;

		case "Clear_Button":
			 OnClear_ButtonClick();
			 break;

		// 교환
		case "ExChange_Button":
			 OnExChange_ButtonClick();
			 break;

		case "Close_Button":
			 OnClose_ButtonClick();
			 break;

		case "IconTabIcon_Button":
		case "ListTabIcon_Button":
			 toggleListWithIconWindow();
			 break;

		// 수량 입력 부분
		case "MultiSell_Up_Button":
		 	 OnMultiSell_Up_ButtonClick();
			 break;

		case "MultiSell_Down_Button":
			 updateMultiSellData();
			 OnMultiSell_Down_ButtonClick();
			 break;

		case "MultiSell_Input_Button":
			 updateMultiSellData();
			 OnPriceEditBtnHandler();
			 break;

		// 전체 탭
		case "MultiSellTab0" : MultiSellTab.SetTopOrder(0, true); disableWindowWithText(false, "");
							   
							   // TTP 69235
							   // 검색어를 입력하여 검색 한후, 검색어를 지우고, 교환탭 클릭-> 다시 전체 탭 클릭 했을때 전체 갱신을 하도록 하기 위해..
							   if(Search_EditBox.GetString() == "" && MultisellTabTotalWnd_ItemWindow.GetItemNum() != m_MultiSellInfoList.Length)
							   {
									bForceUpdate = true;
							   }
							   else
							   {
									bForceUpdate = false;
							   }


							   ShowItemList(); updateUIControl(); 
							   break;

		// 교환 가능
		case "MultiSellTab1" : MultiSellTab.SetTopOrder(1, true); disableWindowWithText(false, ""); 
							   bForceUpdate = false; 				   
							   ShowItemList(); updateUIControl(); 
							   break;
	}
}

// 교환 버튼 클릭
function OnExChange_ButtonClick()
{
	local int i, selectedIndex, inputItemLen;
	local INT64 itemNum;
	local ItemInfo rItemInfo, inputItemInfo;
	local bool hasEItemcheck;
		
	if(getCurrentSelectedItemInfo(rItemInfo))
	{
		selectedIndex = rItemInfo.Reserved;
		itemNum = INT64(ItemCount_EditBox.GetString());

		// debug("HandleOKButton selectedIndex: " $ selectedIndex $ ", itemNum: " $ itemNum );
		
		inputItemLen = m_MultiSellInfoList[selectedIndex].InputItemInfoList.Length;
		
		//--------------------------------------------------------------
		// 필요 아이템이 무기, 방어구, 악세사리가 포함되어 있다면..  이걸 사용 안하고, 멀티셀그룹 아이디로 구분 하기로 함.
		for (i = 0; i < inputItemLen; i++)
		{
			
			inputItemInfo = m_MultiSellInfoList[selectedIndex].InputItemInfoList[i];

			// 필요 아이템에 무기, 방어구, 악세사리가 포함되어 있다면.. 
			//if (nKeepEnchant != 1 ||
			if (inputItemInfo.ItemType == EItemType.ITEM_WEAPON ||
				inputItemInfo.ItemType == EItemType.ITEM_ARMOR ||
				inputItemInfo.ItemType == EItemType.ITEM_ACCESSARY)
			{				
				// Debug("m_MultiSellInfoList[selectedIndex].InputItemInfoList[i].ItemType" @inputItemInfo.ItemType);
				// Debug("inputItemInfo.Id.ClassID" @inputItemInfo.Id.ClassID);
				// Debug("inputItemInfo.Name" @inputItemInfo.Name);

				// 무기 타입이 0인가로 들어와서 이것도 체크..
				// 각종 포인트이 아닌 경우만.. 
				if(isPointType(inputItemInfo) == false)
				{
					// 무기, 방어구, 악세사리를 집혼하려고 할때..
					hasEItemcheck = true;
				}
			}
		}
		 
		// 다이얼로그 메세지 상황에 따라 다르게..
		if (hasEItemcheck) 
			dialogMessage = GetSystemMessage(4363); // 인챈트 등 아이템 속성이 날라간다 경고 			
		else
			dialogMessage = GetSystemMessage(1383); // 기본 메세지로 출력

		// Debug("dialogMessage" @ dialogMessage);

		if( selectedIndex >= 0 )
		{
			DisableWnd.ShowWindow();
			DisableWnd.SetFocus();
			DialogSetReservedInt( selectedIndex );
			DialogSetReservedInt2( itemNum );
			DialogSetID( MULTISELLWND_DIALOG_OK );
			DialogSetCancelD(MULTISELLWND_DIALOG_OK);
			DialogSetString("");
			DialogShow(DialogModalType_Modalless,DialogType_Warning, dialogMessage, string(Self));
			m_nSelectedMultiSellInfoIndex = selectedIndex;
		}
	}
}

/** 개당 판매 가격 입력 계산기 */
function OnPriceEditBtnHandler()
{
	local ItemInfo info;
	
	DisableWnd.ShowWindow();
	DisableWnd.SetFocus();
	// Ask price
	DialogSetID( DIALOG_ASK_PRICE );
	
	DialogSetEditBoxMaxLength(6);
	DialogSetCancelD(DIALOG_ASK_PRICE);
	DialogSetReservedItemID( info.ID );				// ServerID
	//DialogSetReservedInt3( int(bAllItem) );		// 전체이동이면 개수 묻는 단계를 생략한다
	DialogSetEditType("number");
	DialogSetParamInt64( -1 );
	DialogSetDefaultOK();
	// 구매개수를 입력해주세요.
	DialogShow(DialogModalType_Modalless, DialogType_NumberPad, GetSystemMessage(4362), string(Self) );
}

// 목록에서 검색
function OnSearch_ButtonClick()
{
	local string searchStr;

	searchStr = Search_EditBox.GetString();

	if (searchStr == "")
		OnRefrash_ButtonClick();
	else
		ShowItemList();
		//fildAndShowItemList(searchStr);  
}

// 검색 초기화 버튼
function OnRefrash_ButtonClick()
{
	ItemCount_EditBox.SetString("1");
	//itemCountButtonEnable(false);

	disableWindowWithText(false, "");
	DisableWnd.HideWindow();
	
	// MultisellTabTotalWnd_ItemWindow.SetSelectedNum(-1);
	// MultisellTabTotalWnd_ListCtrl.SetSelectedIndex(-1, false);
	
	// 강제 갱신을 위해 , 초기화 버튼을 누르면 
	bForceUpdate = true;
	
	Search_EditBox.SetString("");
	updateMultiSellData();
	ShowItemList();
	updateUIControl();
}

function OnClear_ButtonClick()
{
	ItemCount_EditBox.SetString("1");
	updateMultiSellData();
	updateItemInfo();
	setTreeNeedItemInfo();
}

function OnClose_ButtonClick()
{
	Me.HideWindow();
}

function OnMultiSell_Up_ButtonClick()
{
	local string numStr;
	local int count;

	numStr = ItemCount_EditBox.GetString();
	count = int(numStr);

	if (checkEnableExchange(count + 1))
	{
		// 추가 가능여부 체크해야함
		count++;
		ItemCount_EditBox.SetString(String(count));
		setTreeNeedItemInfo();
	}
}

function OnMultiSell_Down_ButtonClick()
{
	local string numStr;
	local int count;

	numStr = ItemCount_EditBox.GetString();
	count = int(numStr);

	if (count > 1)
	{
		count--;
		ItemCount_EditBox.SetString(String(count));
		setTreeNeedItemInfo();

		//if (checkEnableExchange(count - 1))
		//{
		//}
	}	
}

//-----------------------------------------------------------------------------------------------------------
// OnKeyUp
//-----------------------------------------------------------------------------------------------------------
function OnKeyUp( WindowHandle a_WindowHandle, EInputKey nKey )
{
	local string MainKey;
	
	// 키보드 누름으로 체크 	
	if (Search_EditBox.IsFocused())
	{	
		// 엔터로 검색어 입력 가능 하도록..
		MainKey = class'InputAPI'.static.GetKeyString(nKey);

		if(MainKey == "ENTER")
		{
			ShowItemList();
			//fildAndShowItemList(Search_EditBox.GetString());        		
		}
	}
	else if (ItemCount_EditBox.IsFocused())
	{	
		if (ItemCount_EditBox.GetString() == "0") 
		{
			ItemCount_EditBox.SetString("1");
		}
		
		if (ItemCount_EditBox.GetString() != "") setTreeNeedItemInfo();
	}
}

//-----------------------------------------------------------------------------------------------------------
// Tree 구성 , 아이템 정보, 필요 아이템
//-----------------------------------------------------------------------------------------------------------

// 멀티셀 아이템 정보, 필요 아이템 트리, 수량 입력 부분 업데이트
function updateUIControl( )
{
	setEditStateItemCount();
	updateItemInfo();
	setTreeNeedItemInfo();	
}

// 멀티셀 아이템 정보  업데이트
function updateItemInfo()
{
	local int i, index;
	local ItemInfo rItemInfo;

	if(getCurrentSelectedItemInfo(rItemInfo))
	{
		index = rItemInfo.Reserved;

		if (index <= -1) return;

		class'UIAPI_MULTISELLITEMINFO'.static.Clear("MultiSellWnd.multiSellItemInfo");

		if( index >= 0 && index < m_MultiSellInfoList.Length )
		{
			for(i=0; i < m_MultiSellInfoList[index].OutputItemInfoList.Length; i++ )
			{
				class'UIAPI_MULTISELLITEMINFO'.static.SetItemInfo("MultiSellWnd.multiSellItemInfo", i, m_MultiSellInfoList[index].OutputItemInfoList[i]);

				//***************************************************************************************** 
				// 추후 꼭 빼야 할 부분.
				// 명성치 TTP 69194 는 아이템이 아니기 때문에 아이템 정보 뷰어로 보여 줄수 없다.
				// 그래서 XML과 UI에서 하드코딩으로 텍스트 필드를 넣어서 아이템 정보 뷰어에서 보여 주는 것 처럼 
				// 꾸민 것이다. 
				// 기획쪽(강정원)에서도 빼는 방향으로 한다고 했고 추후 작업을 해야한다
				//*****************************************************************************************
				if (m_MultiSellInfoList[index].OutputItemInfoList[i].IconName == "icon.pvp_point_i00")
				{
					class'UIAPI_WINDOW'.static.ShowWindow("MultiSellWnd.PointItemName");
					class'UIAPI_WINDOW'.static.ShowWindow("MultiSellWnd.txtPointItemDescription");
					class'UIAPI_TEXTBOX'.static.SetText("MultiSellWnd.PointItemName", GetSystemString(102)$"x"$string(m_MultiSellInfoList[index].OutputItemInfoList[i].ItemNum));
					class'UIAPI_TEXTBOX'.static.SetText("MultiSellWnd.txtPointItemDescription", GetSystemMessage(2334));
				}
				else
				{
					class'UIAPI_WINDOW'.static.HideWindow("MultiSellWnd.PointItemName");
					class'UIAPI_WINDOW'.static.HideWindow("MultiSellWnd.txtPointItemDescription");
					class'UIAPI_TEXTBOX'.static.SetText("MultiSellWnd.PointItemName","");
					class'UIAPI_TEXTBOX'.static.SetText("MultiSellWnd.txtPointItemDescription","");
				}
			}
		}
	}
}

function int getIndexArray(int classID, out array<NoStackableItemData> NoStackableItemDataArray)
{
	local int i;

	for(i = 0; i < NoStackableItemDataArray.Length; i++)
	{
		if(NoStackableItemDataArray[i].ClassID == classID)
		{
			return i;
		}
	}
	
	return -1;
}

// onlyUNLOCKTYPE : 봉인 안 된 아이템만 검색
function int getNoStackableItemCountArrayIndex(ItemInfo inputItemInfo, out array<NoStackableItemData> NoStackableItemDataArray, optional bool onlyUNLOCKTYPE )
{
	local int arrayIndex, nClassID;
	local Int64 noStackableNeedItemNum;
	local array<ItemInfo> hasItemInfoArray;
	
	// 수량성 아이템이 아닌..
	if(!IsStackableItem(inputItemInfo.ConsumeType)) 
	{
		// 아이템의 수량 
		nClassID = inputItemInfo.ID.ClassID;
		//noStackableNeedItemNum = inventoryWndScript.getItemCountByClassID(nClassID);
		
		if ( onlyUNLOCKTYPE ) noStackableNeedItemNum = util.FindItemByClassID(nClassID, hasItemInfoArray, Util.EItemLockedCheckType.UNLOCK );
		else  noStackableNeedItemNum =  class'UIDATA_INVENTORY'.static.FindItemByClassID(nClassID, hasItemInfoArray);

		arrayIndex = getIndexArray(nClassID, NoStackableItemDataArray);
		
		// 해당 클래스 아이디를 가진 요소가 없다면.. 배열에 추가
		if (arrayIndex == -1)
		{
			NoStackableItemDataArray.Length = NoStackableItemDataArray.Length + 1;
			
			if (NoStackableItemDataArray.Length > 0)
			{
				NoStackableItemDataArray[NoStackableItemDataArray.Length - 1].ClassID = nClassID;
				NoStackableItemDataArray[NoStackableItemDataArray.Length - 1].count = noStackableNeedItemNum;

				// 동일 클래스 id를 가진 값이 1개 보다 크면 인챈, 집혼등 이름을 표시 안하기 위한 표기
				//if (noStackableNeedItemNum > 1) NoStackableItemDataArray[NoStackableItemDataArray.Length - 1].bNoEnchantName = true;
			}

			if (arrayIndex == -1) arrayIndex = NoStackableItemDataArray.Length - 1;
		}
		else 
		{
			// 있다면 1씩 뺀다.
			if (NoStackableItemDataArray[arrayIndex].count > 0)
				NoStackableItemDataArray[arrayIndex].count = NoStackableItemDataArray[arrayIndex].count - 1;
		}
	}

	return arrayIndex;
}

// 필요 아이템 트리 업데이트 
function setTreeNeedItemInfo()
{
	local int i, index, arrayIndex;

	local array<NoStackableItemData> NoStackableItemDataArray;

	local ItemInfo rItemInfo;

	if(getCurrentSelectedItemInfo(rItemInfo))
	{
		index = rItemInfo.Reserved;

		// Debug("index--->" @ index);

		// 특정 아이템을 선택되지 않았다.
		if (index <= -1) return;

		util.TreeClear(TREENAME);
		util.TreeInsertRootNode( TREENAME, ROOTNAME, "", 0, 4 );

		//itemCountButtonEnable(true);
		itemCountTextEditEnable(true);
		
		// Debug("rItemInfo.ConsumeType" @ rItemInfo.ConsumeType);
		// Debug("IsStackableItem(rItemInfo.ConsumeType)" @ IsStackableItem(rItemInfo.ConsumeType));

		// 목록에 비수량성 아이템이면 1개씩만 구매 가능하도록..
		if(!IsStackableItem(rItemInfo.ConsumeType)) 
		{
			itemCountTextEditEnable(false);
		}

		if( index >= 0 && index < m_MultiSellInfoList.Length )
		{

			for( i=0 ; i < m_MultiSellInfoList[index].InputItemInfoList.Length ; i++ )
			{
				
				// 수량성 아이템 이라면..
				if (IsStackableItem(m_MultiSellInfoList[index].InputItemInfoList[i].ConsumeType))
				{
					addTreeNode("LIST" $ i + 1, m_MultiSellInfoList[index].InputItemInfoList[i]);
				}
				// 비수량성 아이템 이라면..
				else
				{
					arrayIndex = getNoStackableItemCountArrayIndex(m_MultiSellInfoList[index].InputItemInfoList[i], NoStackableItemDataArray, true);
					if (arrayIndex == -1)
						addTreeNode("LIST" $ i + 1, m_MultiSellInfoList[index].InputItemInfoList[i], NoStackableItemDataArray[NoStackableItemDataArray.Length - 1]);
					else 
						addTreeNode("LIST" $ i + 1, m_MultiSellInfoList[index].InputItemInfoList[i], NoStackableItemDataArray[arrayIndex]);
				}


				//// 수량성 아이템이 아닌..
				//if(!IsStackableItem(m_MultiSellInfoList[index].InputItemInfoList[i].ConsumeType)) 
				//{
				//	// 아이템의 수량 
				//	nClassID = m_MultiSellInfoList[index].InputItemInfoList[i].ID.ClassID;
				//	noStackableNeedItemNum = inventoryWndScript.getItemCountByClassID(nClassID);

				//	arrayIndex = getIndexArray(nClassID, NoStackableItemDataArray);
					
				//	// 해당 클래스 아이디를 가진 요소가 없다면.. 배열에 추가
				//	if (arrayIndex == -1)
				//	{
				//		NoStackableItemDataArray.Length = NoStackableItemDataArray.Length + 1;
						
				//		if (NoStackableItemDataArray.Length > 0)
				//		{
				//			NoStackableItemDataArray[NoStackableItemDataArray.Length - 1].ClassID = nClassID;
				//			NoStackableItemDataArray[NoStackableItemDataArray.Length - 1].count = noStackableNeedItemNum;
				//		}
				//	}
				//	else 
				//	{
				//		// 있다면 1씩 뺀다.
				//		if (NoStackableItemDataArray[arrayIndex].count > 0)
				//			NoStackableItemDataArray[arrayIndex].count = NoStackableItemDataArray[arrayIndex].count - 1;
				//	}
					
				//	if (arrayIndex == -1)
				//		addTreeNode("LIST" $ i + 1, m_MultiSellInfoList[index].InputItemInfoList[i], NoStackableItemDataArray[NoStackableItemDataArray.Length - 1]);
				//	else 
				//		addTreeNode("LIST" $ i + 1, m_MultiSellInfoList[index].InputItemInfoList[i], NoStackableItemDataArray[arrayIndex]);
				//}
				//else
				//{
				//	addTreeNode("LIST" $ i + 1, m_MultiSellInfoList[index].InputItemInfoList[i]);
				//}


				// 필요 아이템이 없는 경우가 있다면..
				// if (bHasItem == false) itemCountButtonEnable(false);

				// 포인트 타입이 아니고, 비수량성 아이템이 하나라도 있으면..
				if(IsStackableItem( m_MultiSellInfoList[index].InputItemInfoList[i].ConsumeType ) == false 
					&& isPointType(m_MultiSellInfoList[index].InputItemInfoList[i]) == false)
				{
					itemCountTextEditEnable(false);
				}
			}
		}

		//ExChange_Button.EnableWindow();
		setButtonEnable(true);
	}
}

// 교환 가능한 수량 인가? 
function bool checkEnableExchange(int tryExchangeCount)
{
	local int i, index;
	local bool bHasItem;

	local ItemInfo rItemInfo, info;

	getCurrentSelectedItemInfo(rItemInfo);

	index = rItemInfo.Reserved;

	// 특정 아이템을 선택되지 않았다.
	if (index <= -1) return false;

	bHasItem = true;

	if( index >= 0 && index < m_MultiSellInfoList.Length )
	{
		for( i=0 ; i < m_MultiSellInfoList[index].InputItemInfoList.Length ; i++ )
		{
			info = m_MultiSellInfoList[index].InputItemInfoList[i];
			
			if (info.ItemNum * tryExchangeCount > getHasItemOrPointCount(m_MultiSellInfoList[index].InputItemInfoList[i]))
			{
				bHasItem = false;
			}
		}
	}

	return bHasItem;
}

// 특수 포인트 타입인가? 인벤토리에 없는..
function bool isPointType(ItemInfo info)
{
	local bool rValue;

	// MSIT_PCCAFE_POINT 
	if( Info.IconName == GetPcCafeItemIconPackageName()) 
	{	
		rValue = true;
	}
	// MSIT_PLEDGE_POINT
	else if( Info.IconName == "icon.etc_i.etc_bloodpledge_point_i00" ) 
	{
		rValue = true;
	}	
	// MSIT_PVP_POINT
	else if( Info.IconName == "icon.pvp_point_i00")
	{
		rValue = true;
	}       
	// MSIT_RAID_POINT
	else if ( Info.IconName == "icon.etc_i.etc_rp_point_i00") 
	{
		rValue = true;
	}

	return rValue;
}

// 가지고 있는 아이템, 또는 포인트 카운트
function Int64 getHasItemOrPointCount(ItemInfo info)
{
	local Int64 hasNum;
	local array<ItemInfo> itemInfoArray;
	local int itemCount;

	// MSIT_PCCAFE_POINT 
	if( Info.IconName == GetPcCafeItemIconPackageName()) 
	{	
		hasNum = mData.pcCafePoint;
	}
	// MSIT_PLEDGE_POINT
	else if( Info.IconName == "icon.etc_i.etc_bloodpledge_point_i00" ) 
	{
		hasNum = mData.clanPoint;
	}	
	// MSIT_PVP_POINT
	else if( Info.IconName == "icon.pvp_point_i00")
	{
		hasNum = mData.pvpPoint;
	}       
	// MSIT_RAID_POINT
	else if ( Info.IconName == "icon.etc_i.etc_rp_point_i00") 
	{
		hasNum = mData.raidPoint;
	}
	// 인벤토리에 있나
	else
	{
		// 아이템이 인벤에 있나? classID 로 비교
		itemCount = class'UIDATA_INVENTORY'.static.FindItemByClassID(info.Id.ClassID, itemInfoArray);

		if(itemCount > 0)
		{
			hasNum = itemInfoArray[0].ItemNum;
		}
	}

	return hasNum;
}

// 필요 아이템의 각 아이템을 추가 한다.
function bool addTreeNode(string nodeLine, ItemInfo info, optional NoStackableItemData noStackableItemDataInfo)
{
	local ItemInfo InvenItemInfo;

	local string strRetName, gradeTextureName;
	local int textHeight;

	local string enchantedStr, itemName, additionalName, stackableAddStr;
	local string shortItemName, ensoulOptionAllName;
	local int enchantedStr_width, additionalName_width, stackableAddStr_width, ensoulOptionAllName_width, gradeTextureName_width;

	local Int64 hasNum;
	local bool bHasItem;
	local int tryExchangeCount;

	local array<ItemInfo> itemInfoArray;
	local int itemCount;

	tryExchangeCount = int(ItemCount_EditBox.GetString());

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
	
	//if(noStackableItemDataInfo.bNoEnchantName == false)
	//{
	//	if(info.Enchanted > 0) enchantedStr = "+"$ String(info.Enchanted);
	//}

	if(info.Enchanted > 0) enchantedStr = "+"$ String(info.Enchanted);
	GetTextSizeDefault(enchantedStr, enchantedStr_width, textHeight);

	// 집혼 이름
	// Debug("------ noStackableItemDataInfo.bNoEnchantName ---" @ noStackableItemDataInfo.bNoEnchantName);
	 //if(noStackableItemDataInfo.bNoEnchantName == false) ensoulOptionAllName = GetEnsoulOptionNameAll(info);
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

	//Debug("-------------------------------------------------------------");
	//Debug("enchantedStr" @ enchantedStr);
	//Debug("ensoulOptionAllName" @ ensoulOptionAllName);
	//Debug("shortItemName" @ shortItemName);
	
	//if (additionalName == "")
	//	util.TreeInsertItemTooltipSimpleNode( TREENAME, nodeLine, ROOTNAME, -7, 0, 38, 0, 32, 38, itemName);
	//else 
	//	util.TreeInsertItemTooltipSimpleNode( TREENAME, nodeLine, ROOTNAME, -7, 0, 38, 0, 32, 38, itemName $ " " $ additionalName);

	//util.TreeInsertItemTooltipSimpleNode( TREENAME, nodeLine, ROOTNAME, -7, 0, 38, 0, 32, 38, GetItemNameAll(info));
	util.TreeInsertItemTooltipSimpleNode( TREENAME, nodeLine, ROOTNAME, -7, 0, 38, 0, 32, 38, GetItemNameAll(info));
	///

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

	util.TreeInsertTextNodeItem( TREENAME, strRetName, "x " $ MakeCostString(String(Info.ItemNum * tryExchangeCount)), 45, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GOLD, false, true );

	// MSIT_PCCAFE_POINT 
	if( Info.IconName == GetPcCafeItemIconPackageName()) 
	{	
		hasNum = mData.pcCafePoint;
		if (hasNum >= Info.ItemNum * tryExchangeCount) bHasItem = true;
	}
	// MSIT_PLEDGE_POINT
	else if( Info.IconName == "icon.etc_i.etc_bloodpledge_point_i00" ) 
	{
		hasNum = mData.clanPoint;
		if (hasNum >= Info.ItemNum * tryExchangeCount) bHasItem = true;
	}	
	// MSIT_PVP_POINT
	else if( Info.IconName == "icon.pvp_point_i00")
	{
		hasNum = mData.pvpPoint;
		if (hasNum >= Info.ItemNum * tryExchangeCount) bHasItem = true;
	}       
	// MSIT_RAID_POINT
	else if ( Info.IconName == "icon.etc_i.etc_rp_point_i00") 
	{
		hasNum = mData.raidPoint;
		if (hasNum >= Info.ItemNum * tryExchangeCount) bHasItem = true;
	}
	// 인벤토리에 있나
	else
	{
		itemCount = Util.FindItemByClassID( info.Id.ClassID, itemInfoArray, Util.EItemLockedCheckType.UNLOCK ) ;
		//itemCount = class'UIDATA_INVENTORY'.static.FindItemByClassID(info.Id.ClassID, itemInfoArray);

		// 아이템이 인벤에 있다면..
		if(itemCount > 0)
		{
			InvenItemInfo = itemInfoArray[0];

			// Debug("--- InvenItemInfo.ServerID" @ InvenItemInfo.Id.ServerID);
			// Debug("--- info.ServerID" @ info.Id.ServerID);
			// Debug("--- info.ItemNum" @ InvenItemInfo.ItemNum);

			// Debug("아이템 수량" @ inventoryWndScript.getItemCountByClassID(info.ID.ClassID));
			if(!IsStackableItem( InvenItemInfo.ConsumeType ))
			{
				// 비수량성 아이템은 별도의 수량을 표시 하지 않고 존재 한다는 의미로 1 를 넣는다.
				if (noStackableItemDataInfo.ClassID > 0)
				{
					if (noStackableItemDataInfo.count > 0) hasNum = 1;
				}
			}
			else
			{
				hasNum = InvenItemInfo.ItemNum;
			}
			if (hasNum >= info.ItemNum * tryExchangeCount) bHasItem = true;


			//Debug("--- bHasItem" @ bHasItem);
		}
	}
	
	if (bHasItem)
	{
		if (hasNum != -1)
			util.TreeInsertTextNodeItem( TREENAME, strRetName,"(" $ MakeCostString(String(hasNum)) $ ")", 4 , OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_BRIGHT_BLUE);
	}
	else 
	{
		util.TreeInsertTextNodeItem( TREENAME, strRetName,"(" $ MakeCostString(String(hasNum)) $ ")", 4 , OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_RED);
	}

	return bHasItem;
}

// 수량 입력 에디터 , 활성 비활성
function itemCountTextEditEnable(bool bEnable)
{
	if (bEnable)
	{
		MultiSell_Input_Button.EnableWindow();
		ItemCount_EditBox.EnableWindow();

		MultiSell_Up_Button.EnableWindow();
		MultiSell_Down_Button.EnableWindow();
		MultiSell_Input_Button.EnableWindow();
	}
	else
	{
		MultiSell_Input_Button.DisableWindow();
		ItemCount_EditBox.DisableWindow();

		MultiSell_Up_Button.DisableWindow();
		MultiSell_Down_Button.DisableWindow();
		MultiSell_Input_Button.DisableWindow();
	}
}

//----------------------------------------------------------------------------------------------------------------------------------
// 전용 util
//----------------------------------------------------------------------------------------------------------------------------------

// 현재 선택되어 있는 아이템 정보을 리턴한다.
function bool getCurrentSelectedItemInfo(out ItemInfo rItemInfo)
{
	local bool bFlag; 

	// 전체 탭
	if (MultiSellTab.GetTopIndex() == 0)
	{
		bFlag = MultisellTabTotalWnd_ItemWindow.GetSelectedItem(rItemInfo);
	}
	// 교환 가능 탭
	else
	{
		bFlag = MultisellTabEnableWnd_ItemWindow.GetSelectedItem(rItemInfo);
	}

	return bFlag;
}

// 현재 선택되어 있는 아이템 목록의 index 번호를 리턴한다.
function int getCurrentSelectedIndex()
{
	local int rValue;

	rValue = -1;

	// 전체 탭
	if (MultiSellTab.GetTopIndex() == 0)
	{
		rValue = MultisellTabTotalWnd_ItemWindow.GetSelectedNum();
	}
	// 교환 가능 탭
	else
	{
		rValue = MultisellTabEnableWnd_ItemWindow.GetSelectedNum();
	}

	// Debug("버튼 " @ rValue);
	return rValue;
}

// 구매 완료 후 다시 선택되도록 하는 용도로 사용
function setSelectItem(ItemInfo info)
{
	local int lastSelectedIndex, n;
	local ItemInfo tempInfo;

	lastSelectedIndex = info.Reserved;	
	
	// 전체 목록은 목록을 유지 해서 필요 없고, 교환가능 목록만 검색해서 찾는다.
	// 아이템 정보가 동일한게 있는 경우도 있어서, Reserved 값으로 전체 index 고유 값으로 찾아서 이동하게
	// 만들었다. 

	if(info.Name == "") return;
	//Debug(" 선택 복원" @ info.Name);

	// 전체 탭 
	if (MultiSellTab.GetTopIndex() == 0)
	{
		// 전체 목록
		for (n = 0; n < MultisellTabTotalWnd_ItemWindow.GetItemNum(); n++)
		{
			MultisellTabTotalWnd_ItemWindow.GetItem(n, tempInfo);

			if (tempInfo.Reserved == lastSelectedIndex)
			{
				MultisellTabTotalWnd_ItemWindow.SetSelectedNum(n);
				MultisellTabTotalWnd_ListCtrl.SetSelectedIndex(n, true);
				break;				
			}
		}		
	}
	// 교환 가능 탭
	else
	{
		// 교환 가능 목록
		for (n = 0; n < MultisellTabEnableWnd_ItemWindow.GetItemNum(); n++)
		{
			MultisellTabEnableWnd_ItemWindow.GetItem(n, tempInfo);

			if (tempInfo.Reserved == lastSelectedIndex)
			{
				MultisellTabEnableWnd_ItemWindow.SetSelectedNum(n);
				MultisellTabEnableWnd_ListCtrl.SetSelectedIndex(n, true);
				break;				
			}
		}
	}
}

//-----------------------------------------------------------------------------------------------------------
// UTIL
//-----------------------------------------------------------------------------------------------------------

// 문자열 검색 
function int findMatchString( string targetStr, string a_Param )
{
	local array <string> modifiedParamArr;
	local int i ;
	local string delim, modifiedString;
	local int _inStr;

	local string strTemp1;
	local string strTemp2;

	modifiedString = Substitute(targetStr, " ", "", FALSE);

	delim  = " ";

	_inStr = InStr(a_Param, delim);
	while ( _inStr > -1  )
	{
		modifiedParamArr.Insert(modifiedParamArr.Length, 1);
		modifiedParamArr[modifiedParamArr.Length-1] = Left(a_Param, _inStr );		
		a_Param = Mid(a_Param, _inStr + 1);
		_inStr = InStr(a_Param, delim);
	}

	modifiedParamArr.Insert(modifiedParamArr.Length, 1);
	modifiedParamArr[modifiedParamArr.Length-1] = a_Param;

	for ( i = 0 ; i < modifiedParamArr.Length ; i++ )
	{	
		strTemp1 = Caps(modifiedString);
		strTemp2 = Caps(modifiedParamArr[i]);
		if ( InStr( strTemp1, strTemp2 ) == -1 && modifiedParamArr[i] != " " ) 
			return -1;
	}

	return 1;
}

// 신규 집혼 관련 데이타 추가
function addEnsoulInfo(int slotType, int slotCount, string param, out ItemInfo info)
{
	local int n, nEOptionID;

	for(n = EISI_START; n < slotCount + EISI_START; n++)
	{
		ParseInt(param, "EnsoulOptionID_" $ slotType $ "_" $ n, nEOptionID);

		info.EnsoulOption[slotType - 1].OptionArray[n - EISI_START] = nEOptionID;
	}
}

// 아이템 
function setEditStateItemCount()
{
	ItemCount_EditBox.SetString("1");	
}


// 지우기, 교환 버튼, 활성 비활성
function setButtonEnable(bool bEnable)
{
	if (bEnable)
	{
		ExChange_Button.EnableWindow();
		Clear_Button.EnableWindow();
	}
	else
	{
		ExChange_Button.DisableWindow();
		Clear_Button.DisableWindow();
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
}
