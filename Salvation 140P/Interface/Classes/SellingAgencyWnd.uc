////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
//  Program ID  : 판매대행 시스템 
//  위키 문서   : http://lineage2:8080/wiki/moin.cgi/_c0_a7_c5_b9_c6_c7_b8_c5#line5
//
//  ※ 관련 기획서 경로
//   UI 기획서
//	 VSS/GameDesign/UI/GD10 기획서/GD1_UI_아이템판매대행시스템.ppt
//	
//  시스템 기획서
//	 VSS/GameDesign/시스템디자인팀/GD1/기획서/GD1_UI_아이템판매대행시스템.doc
// 	 VSS/GameDesign/시스템디자인팀/GD1/기획서/GD1_UI_아이템판매대행시스템.ppt
//	 VSS/GameDesign/시스템디자인팀/GD1.1/111019/기획서/GD1.1_판매 대행 시스템.docx
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class SellingAgencyWnd extends UICommonAPI;

const TIMER_SEARCH_ID               = 2001001;
const TIMER_CATEGORYTREE_SEARCH_ID  = 2001002; 
// TTP #59728 - gorillazin 13.01.09.
const TIMER_RE_SEARCH_ID			= 2001003;
//

const TIMER_SEARCH_DELAY  = 700;                                // 서버는 0.7초 딜레이후 검색 기능이 작동 하도록 한다.
// TTP #59728 - gorillazin 13.01.09.
const TIMER_Re_SEARCH_DELAY = 350;
const SEARCH_FAIL_REASON_DELAY = -1;
//
 
const DIALOG_STACKABLE_ITEM_ACCOMPANY_TO_INVEN = 200000;		// ACCOMPANY 에서 INVEN으로 옮길때 스태커블한거 개수 물어보기
const DIALOG_STACKABLE_ITEM_INVEN_TO_ACCOMPANY = 200001;		// INVEN 에서 ACCOMPANY으로 옮길때 스태커블한거 개수 물어보기
const DIALOG_RECEIVE_ADENA                     = 200002;		// 받을 금액 설정
const DIALOG_NOTIFY_SEND_POST                  = 200003;	  	// 우편을 전송할 것인지 물어보는 다이얼로그
const DIALOG_ONLY_NOTICE                       = 200004;	  	// 아무동작도 안하는 알려주는 전용
const DIALOG_ASK_PRICE                         = 200005;					
const DIALOG_ASK_REGISTITEM                    = 200006;
const DIALOG_ASK_BUY                           = 200007;						
const DIALOG_ASK_DELETE                        = 200008;

//듀얼 과금제 0831
const DIALOG_FREEUSER_ONREGISTE                = 200009;


// 1)	등록 수수료 = (판매 아이템 1개의 가격)*(판매수량)*0.0001 * (등록기간) 
//  2)	판매 수수료 = (판매 아이템 1개의 가격)*(판매수량)*0.005 * (등록기간)

// const COMMISSION_RATE                          = 1;             // 등록 수수료 율 ( 하루당 0.0001% ), (COMMISSION_RATE / 10000) => 0.0001
// const COMMISSION_RATE_SELLCOMPLETE             = 5;             // 판매 수수료 (COMMISSION_MIN_PRICE / 1000) => 0.005

const COMMISSION_MIN_PRICE                     = 10000;         // 등록 수수료 1만 보다 작으면 최소 등록 수수료 적용
const COMMISSION_REGISTER_MIN_PRICE            = 1000;          // 최소 등록 수수료
const COMMISSION_REGISTER_MIN_PRICE_30         = 700;          // 최소 등록 수수료 30%

const MAX_SELLINGITEM_NUM                      = 10;            // 판매 가능한 최대 아이템수
const MAX_SELLING_AMOUNT                       = 99999;         // 수량성 아이템 최대 등록 가능수 : 자리수에 따라 DialogSetEditBoxMaxLength도 조절해야함

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  XML UI 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
var WindowHandle   Me;
var WindowHandle   DisableWnd;
var TabHandle      TabCtrl;
var TextureHandle  TabLineBg;
var TextureHandle  TabBg;

var WindowHandle   SellingListWnd;
var WindowHandle   DescriptionMsgWnd;
var TextBoxHandle  DescriptionMsg;
var TextBoxHandle  Type_Title;

var ComboBoxHandle Type_Combobox;
var TextBoxHandle  Grade_Title;
var ComboBoxHandle Grade_Combobox;
var TextBoxHandle  SearchWord_Title;
var EditBoxHandle  SearchWord_Editbox;
var ButtonHandle   SearchBtn;
var ButtonHandle   ResetBtn;
var TextureHandle  SearchGroupBox;
var TextBoxHandle  Sort_Title;

var TreeHandle     SortListTree;
var TextureHandle  SortGroupbox;
var WindowHandle   HelpHtmlWnd;
var TextBoxHandle  HelpHtmlWnd_Title;
var HtmlHandle     HtmlViewer;

var WindowHandle   SellingItemListWnd;
var TextBoxHandle  SellingItemList_Title;
var TextBoxHandle  SellingItemNumber;
var ListCtrlHandle SellingItemListCtrl;
var TextureHandle  SellingItemListCtrlDeco;
var TextureHandle  SellingItemListGroupbox;
var TextureHandle  SellingItemListCtrlGroupboxDivider;

var ButtonHandle   RefreshBtn;
var ButtonHandle   BuyBtn;
var WindowHandle   MyListWnd;
var TextBoxHandle  MyList_Title;
var TextBoxHandle  MySellingItemList_Title;
var TextBoxHandle  MySellingItemNumber;
var ListCtrlHandle MySellingItemListCtrl;
var TextureHandle  MySellingItemListCtrlDeco;
var ButtonHandle   SellCancelBtn;
var ButtonHandle   SellBtn;

var TextureHandle  MySellingItemListGroupbox;
var WindowHandle   SellingItemRegistrationWnd;
var TextBoxHandle  SellingItemRegistrationWind_Title;
var TextBoxHandle  SellingPossibItem_Title;

var ItemWindowHandle MySellingPossibItem;
var TextureHandle    MySellingPossibItembg;
var TextureHandle    MySellingPossibItemGroupbox;
var TextBoxHandle    MySellingItem_Title;
var ItemWindowHandle MySellingItemIcon;
var TextureHandle    MySellingItemSlotBg;
var NameCtrlHandle   MySellingItemName;
var TextureHandle    MySellingItemPropertyIcon_01;
var TextureHandle    MySellingItemPropertyIcon_02;
var TextureHandle    MySellingItemPropertyIcon_03;
var TextureHandle    MySellingItemPropertyIcon_04;
var TextBoxHandle    MySellingItemPropertyValue_01;
var TextBoxHandle    MySellingItemPropertyValue_02;
var TextBoxHandle    MySellingItemPropertyValue_03;
var TextBoxHandle    MySellingItemPropertyValue_04;
var TextureHandle    MySellingItemGroupbox;
var TextBoxHandle    MySellingItemUnitPrice_Title;
var ButtonHandle     MySellingItemUnitPriceEditBtn;
var TextureHandle    MySellingItemUnitPriceAdenaIcon;
var EditBoxHandle    MySellingItemUnitPriceEdit;

var TextBoxHandle    MySellingItemUnitPrice_ReadingText;
var TextBoxHandle    MySellingItemAmount_Title;
var TextBoxHandle    MySellingItemAmount;

var TextureHandle    GroupboxDivider_01;
var TextBoxHandle    MySellingItemRegistPeriod_Title;
var ComboBoxHandle   MySellingItemRegistPeriodComboBox;

var TextureHandle    GroupboxDivider_02;
var TextBoxHandle    MySellingItemTotalPrice_Title;

var TextureHandle    MySellingItemTotalPriceAdenaIcon;
var TextBoxHandle    MySellingItemTotalPrice;
var TextBoxHandle    MySellingItemTotalPrice_ReadingText;
					
var TextureHandle    GroupboxDivider_03;
var TextBoxHandle    MySellingItemCharge_Title;
var ButtonHandle     MySellingItemChargeEditBtn;
var TextureHandle    MySellingItemChargeAdenaIcon;

// 등록 수수료  (2011, 09, 08 추가)
var TextBoxHandle    MySellingItemSellCharge;

// 판매 수수료 
var TextBoxHandle    MySellingItemCharge;
var TextureHandle    MySellingItemChargeTextBoxBg;
//var TextBoxHandle    MySellingItemCharge_ReadingText;
var TextureHandle    GroupboxDivider_04;
var ButtonHandle     RegistBtn;
var ButtonHandle     CancelBtn;
var TextureHandle    MySellingItemInfoGroupbox;

var TextBoxHandle    MyAdena; 
var TextBoxHandle    MyAdena2; 

var WindowHandle     m_inventoryWnd;

var int              maxSellingItemNum;

var string           saveTreePath;
var bool             disableCurrentWindowFlag;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 관련 변수
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
var L2Util           util;

// 트리 메뉴 구성 
var array<string>	titleNameArray;
var array<string>	categoryTypeNameArray;
var array<string>	item1Array, item2Array, item3Array, item4Array, item5Array, item6Array;
//branch 110706
var array<CommissionPremiumItemInfo>	sellPremiumitemArray;
//end of branch

// 전체 트리의 노드 스트링을 넣는다.
var string treeParam;
var string openTreeParam;

// 현재 선택 되어진 트리노드
var string currentTreeNodeSelected;
var string beforeTreeNodeSelected;
var bool   beforeTreeNodeSelectedFlag;
// 실제 검색을 호출한 경우
var string beforeTreeNodeCalled;


// Combo 상태 값
var int nCurrentTypeCombo;
var int nCurrentGradeCombo;

// 현재 판매등록하려고 하는 아이템을 임시로 저장해놓고 , 서버에 이전에 올렸던 기록을 조회 하여 정보를 받아
// 올때 사용하는 변수들
var ItemInfo saveTempItemInfo;
var int nSaveTempItemIndex;
var int nItemCheckState;

// 현재 목록에 넣을 리스트 번호
var int listCommissionStatus;

// 인벤 -> 판매등록, 판매등록-> 인벤  즉 첫번째 윈도우 이름으로 구별.
var string startItemWIndowName; 

// 삭제할 내가 등록할 리스트의 인덱스
var int deleteIndexMySellingItemListCtrl;

// 이전 판매 정보 기억용
var INT64 beforeAmount, beforePrePrice;
var int beforePeriod;
var int beforeDiscountType; //branch 110824

var Rect MySellingItemListCtrlRect;

// 드래그 해서 전체 아이템을 넣었나? 
var bool allItemCountFlag;
var ItemInfo beforeDropItemInfo;

// 수수료
var string commissionStr, commissionSellCompleteStr;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 초기화 관련 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function OnRegisterEvent()
{
	// 창 열기
	RegisterEvent(EV_ItemCommissionWndShow );
	
	//branch 110706
	//해외용 유로아이템 리스트 추가
	RegisterEvent( EV_ItemCommissionWndSellingPremiumItemRegisterReset );
	RegisterEvent( EV_ItemCommissionWndSellingPremiumItemRegister );
	//end of branch

	// 각 판매할 아이템 리스트 얻기
	RegisterEvent(EV_ItemCommissionWndListStart);
	RegisterEvent(EV_ItemCommissionWndEachItem);

	// 판매 가능한 아이템 리스트 
	RegisterEvent(EV_ItemCommissionWndRegistrableItemCnt);
	RegisterEvent(EV_ItemCommissionWndRegistrableItemList);

	// 구매 한다고 했을 경우 
	RegisterEvent(EV_ItemCommissionWndBuyInfo);
	// 구매 결과  
	RegisterEvent(EV_ItemCommissionWndBuyResult);

	// 등록 하려고 아이템을 드래그,  더블클릭했을때 
	RegisterEvent(EV_ItemCommissionWndResponseInfo);

	// 판매할 아이템 등록 결과
	RegisterEvent(EV_ItemCommissionWndRegisterResult);

	// 판매할 아이템 삭제 결과 
	RegisterEvent(EV_ItemCommissionWndDeleteResult);

	RegisterEvent(EV_ItemCommissionWndSearchFail);


	// npc에서 거리가 멀어지면 창을 닫는다.
	RegisterEvent(EV_ItemCommissionWndCloseCauseOfLongDistance);

	RegisterEvent(EV_DialogOK);
	RegisterEvent(EV_DialogCancel);

	RegisterEvent(EV_Restart);
	
	RegisterEvent( EV_ItemCommissionRegisterWndCloseCauseOfFreeUser );



	//const EV_ItemCommissionWndShow = 5490;
	//const EV_ItemCommissionWndRegistrableItemCnt=5492;
	//const EV_ItemCommissionWndRegistrableItemList=5495;

	//const EV_ItemCommissionWndResponseInfo = 5500;
	//const EV_ItemCommissionWndListStart = 5510;
	//const EV_ItemCommissionWndEachItem = 5520;
	//const EV_ItemCommissionWndListEnd = 5530;

	//const EV_ItemCommissionWndBuyInfo = 5540;
	//const EV_ItemCommissionWndBuyResult = 5550;
	//const EV_ItemCommissionWndDeleteResult = 5560;
	//const EV_ItemCommissionWndRegisterResult = 5570;
}

/** onShow */
function OnShow()
{	
	PlayConsoleSound(IFST_WINDOW_OPEN);
	util.ItemRelationWindowHide("SellingAgencyWnd");
		

	// getInstanceL2Util().ItemRelationWindowHide(getCurrentWindowName(String(self)));
	updateRecordItemCount();
	resetUI();
}


/** OnLoad */
function OnLoad()
{
	SetClosingOnESC();
	// util 초기화 
	util = L2Util(GetScript("L2Util"));	
	Initialize();
	categoryTreeInit();
	//resetUI();
}

/** UI를 리셋 한다. */
function resetUI()
{
	// 등록 제한 , 개발망이면 99999 , 아니면 10개 
	if (IsBuilderPC() ) maxSellingItemNum = 99999;
	else maxSellingItemNum = 10;
	
	//branch 110706
	//프리미엄아이템 삭제
	sellPremiumitemArray.Length = 0;
	//end of branch

	DisableCurrentWindow(false);
	TabCtrl.SetTopOrder(0, false);
	// 판매 리스트 모두 삭제
	SellingItemListCtrl.DeleteAllItem();
	// 내가 등록한 판매 리스트 삭제
	MySellingItemListCtrl.DeleteAllItem();

	Type_Combobox.SetSelectedNum(0);
	Grade_Combobox.SetSelectedNum(0);

	SearchWord_Editbox.SetString("");
	MySellingItemNumber.SetText("");
	// 등록 폼 초기화 
	MySellingPossibItem.Clear();
	MySellingItemIcon.Clear(); 
	comboInit();
	initRegistItemForm();
	// "전체" 쪽에서 시작 하도록 초기화 한다.
	clickTreeState("root.list1");

	updateAdenaText();

	// SellingItemListCtrl.EnablePageBrowser(false);
	MySellingItemListCtrl.EnablePageBrowser(false);
}

/** Initialize */
function Initialize()
{
	Me = GetWindowHandle( "SellingAgencyWnd" );
	DisableWnd = GetWindowHandle( "SellingAgencyWnd.DisableWnd" );

	TabCtrl = GetTabHandle( "SellingAgencyWnd.TabCtrl" );
	TabLineBg = GetTextureHandle( "SellingAgencyWnd.TabLineBg" );
	TabBg = GetTextureHandle( "SellingAgencyWnd.TabBg" );
	SellingListWnd = GetWindowHandle( "SellingAgencyWnd.SellingListWnd" );
	DescriptionMsgWnd = GetWindowHandle( "SellingAgencyWnd.SellingListWnd.DescriptionMsgWnd" );
	DescriptionMsg = GetTextBoxHandle( "SellingAgencyWnd.SellingListWnd.DescriptionMsgWnd.DescriptionMsg" );
	Type_Title = GetTextBoxHandle( "SellingAgencyWnd.SellingListWnd.Type_Title" );

	// 종류 (콤보)
	Type_Combobox = GetComboBoxHandle( "SellingAgencyWnd.SellingListWnd.Type_Combobox" );
	Grade_Title = GetTextBoxHandle( "SellingAgencyWnd.SellingListWnd.Grade_Title" );
	// 아이템 등급 (콤보)
	Grade_Combobox = GetComboBoxHandle( "SellingAgencyWnd.SellingListWnd.Grade_Combobox" );
	SearchWord_Title = GetTextBoxHandle( "SellingAgencyWnd.SellingListWnd.SearchWord_Title" );
	// 검색어 입력 에디터 박스
	SearchWord_Editbox = GetEditBoxHandle( "SellingAgencyWnd.SellingListWnd.SearchWord_Editbox" );

	SearchBtn = GetButtonHandle( "SellingAgencyWnd.SellingListWnd.SearchBtn" );
	ResetBtn = GetButtonHandle( "SellingAgencyWnd.SellingListWnd.ResetBtn" );
	SearchGroupBox = GetTextureHandle( "SellingAgencyWnd.SellingListWnd.SearchGroupBox" );
	Sort_Title = GetTextBoxHandle( "SellingAgencyWnd.SellingListWnd.Sort_Title" );

	// 소지금 
	MyAdena  = GetTextBoxHandle( "SellingAgencyWnd.SellingListWnd.MyAdena" );
	MyAdena2 = GetTextBoxHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MyAdena2" );
		
	// 분류 (판매 목록 트리)
	SortListTree = GetTreeHandle( "SellingAgencyWnd.SellingListWnd.SortListTree" );

	SortGroupbox = GetTextureHandle( "SellingAgencyWnd.SellingListWnd.SortGroupbox" );
	HelpHtmlWnd = GetWindowHandle( "SellingAgencyWnd.SellingListWnd.HelpHtmlWnd" );
	HelpHtmlWnd_Title = GetTextBoxHandle( "SellingAgencyWnd.SellingListWnd.HelpHtmlWnd.HelpHtmlWnd_Title" );
	HtmlViewer = GetHtmlHandle( "SellingAgencyWnd.SellingListWnd.HelpHtmlWnd.HtmlViewer" );
	//SortGroupbox = GetTextureHandle( "SellingAgencyWnd.SellingListWnd.HelpHtmlWnd.SortGroupbox" );

	// 판매 리스트 윈도우
	SellingItemListWnd = GetWindowHandle( "SellingAgencyWnd.SellingListWnd.SellingItemListWnd" );
	SellingItemList_Title = GetTextBoxHandle( "SellingAgencyWnd.SellingListWnd.SellingItemListWnd.SellingItemList_Title" );
	SellingItemNumber = GetTextBoxHandle( "SellingAgencyWnd.SellingListWnd.SellingItemListWnd.SellingItemNumber" );
	SellingItemListCtrl = GetListCtrlHandle( "SellingAgencyWnd.SellingListWnd.SellingItemListWnd.SellingItemListCtrl" );
	SellingItemListCtrlDeco = GetTextureHandle( "SellingAgencyWnd.SellingListWnd.SellingItemListWnd.SellingItemListCtrlDeco" );
	SellingItemListGroupbox = GetTextureHandle( "SellingAgencyWnd.SellingListWnd.SellingItemListWnd.SellingItemListGroupbox" );
	SellingItemListCtrlGroupboxDivider = GetTextureHandle( "SellingAgencyWnd.MyListWnd.SellingItemListCtrlGroupboxDivider" );
	
	RefreshBtn = GetButtonHandle( "SellingAgencyWnd.SellingListWnd.RefreshBtn" );
	BuyBtn = GetButtonHandle( "SellingAgencyWnd.SellingListWnd.BuyBtn" );
	MyListWnd = GetWindowHandle( "SellingAgencyWnd.MyListWnd" );
	MyList_Title = GetTextBoxHandle( "SellingAgencyWnd.MyListWnd.MyList_Title" );
	MySellingItemList_Title = GetTextBoxHandle( "SellingAgencyWnd.MyListWnd.MySellingItemList_Title" );
	MySellingItemNumber = GetTextBoxHandle( "SellingAgencyWnd.MyListWnd.MySellingItemNumber" );
	// 내가 등록한 아이템 목록 
	MySellingItemListCtrl = GetListCtrlHandle( "SellingAgencyWnd.MyListWnd.MySellingItemListCtrl" );
	MySellingItemListCtrlDeco = GetTextureHandle( "SellingAgencyWnd.MyListWnd.MySellingItemListCtrlDeco" );
	SellCancelBtn = GetButtonHandle( "SellingAgencyWnd.MyListWnd.SellCancelBtn" );
	SellBtn = GetButtonHandle( "SellingAgencyWnd.MyListWnd.SellBtn" );
	MySellingItemListGroupbox = GetTextureHandle( "SellingAgencyWnd.MyListWnd.MySellingItemListGroupbox" );
	SellingItemRegistrationWnd = GetWindowHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd" );
	SellingItemRegistrationWind_Title = GetTextBoxHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.SellingItemRegistrationWind_Title" );
	SellingPossibItem_Title = GetTextBoxHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.SellingPossibItem_Title" );

	MySellingPossibItem = GetItemWindowHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingPossibItem" );
	MySellingPossibItembg = GetTextureHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingPossibItembg" );
	MySellingPossibItemGroupbox = GetTextureHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingPossibItemGroupbox" );
	MySellingItem_Title = GetTextBoxHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItem_Title" );
	MySellingItemIcon = GetItemWindowHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemIcon" );
	MySellingItemSlotBg = GetTextureHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemSlotBg" );
	MySellingItemName = GetNameCtrlHandle(   "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemName" );
	
	MySellingItemPropertyIcon_01 = GetTextureHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemPropertyIcon_01" );
	MySellingItemPropertyIcon_02 = GetTextureHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemPropertyIcon_02" );
	MySellingItemPropertyIcon_03 = GetTextureHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemPropertyIcon_03" );
	MySellingItemPropertyIcon_04 = GetTextureHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemPropertyIcon_04" );
	MySellingItemPropertyValue_01 = GetTextBoxHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemPropertyValue_01" );
	MySellingItemPropertyValue_02 = GetTextBoxHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemPropertyValue_02" );
	MySellingItemPropertyValue_03 = GetTextBoxHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemPropertyValue_03" );
	MySellingItemPropertyValue_04 = GetTextBoxHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemPropertyValue_04" );
	MySellingItemGroupbox = GetTextureHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemGroupbox" );
	MySellingItemUnitPrice_Title = GetTextBoxHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemUnitPrice_Title" );
	MySellingItemUnitPriceEditBtn = GetButtonHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemUnitPriceEditBtn" );
	MySellingItemUnitPriceAdenaIcon = GetTextureHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemUnitPriceAdenaIcon" );
	MySellingItemUnitPriceEdit = GetEditBoxHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemUnitPriceEdit" );
	MySellingItemUnitPrice_ReadingText = GetTextBoxHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemUnitPrice_ReadingText" );
	MySellingItemAmount_Title = GetTextBoxHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemAmount_Title" );
	MySellingItemAmount = GetTextBoxHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemAmount" );
	GroupboxDivider_01 = GetTextureHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.GroupboxDivider_01" );
	MySellingItemRegistPeriod_Title = GetTextBoxHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemRegistPeriod_Title" );
	MySellingItemRegistPeriodComboBox = GetComboBoxHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemRegistPeriodComboBox" );
	GroupboxDivider_02 = GetTextureHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.GroupboxDivider_02" );
	MySellingItemTotalPrice_Title = GetTextBoxHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemTotalPrice_Title" );
	//MySellingItemTotalPriceEditBtn = GetButtonHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemTotalPriceEditBtn" );
	MySellingItemTotalPriceAdenaIcon = GetTextureHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemTotalPriceAdenaIcon" );
	MySellingItemTotalPrice = GetTextBoxHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemTotalPrice" );
	MySellingItemTotalPrice_ReadingText = GetTextBoxHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemTotalPrice_ReadingText" );
	GroupboxDivider_03 = GetTextureHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.GroupboxDivider_03" );
	MySellingItemCharge_Title = GetTextBoxHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemCharge_Title" );
	MySellingItemChargeEditBtn = GetButtonHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemChargeEditBtn" );
	MySellingItemChargeAdenaIcon = GetTextureHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemChargeAdenaIcon" );

	MySellingItemCharge = GetTextBoxHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemCharge" );
	MySellingItemSellCharge = GetTextBoxHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemSellCharge" );
	
	MySellingItemChargeTextBoxBg = GetTextureHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemChargeTextBoxBg" );
	//MySellingItemCharge_ReadingText = GetTextBoxHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemCharge_ReadingText" );

	GroupboxDivider_04 = GetTextureHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.GroupboxDivider_04" );
	RegistBtn = GetButtonHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.RegistBtn" );
	CancelBtn = GetButtonHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.CancelBtn" );
	MySellingItemInfoGroupbox = GetTextureHandle( "SellingAgencyWnd.MyListWnd.SellingItemRegistrationWnd.MySellingItemInfoGroupbox" );

	m_inventoryWnd = GetWindowHandle( "InventoryWnd" );	//인벤토리의 윈도우 핸들을 얻어온다.

	MySellingItemListCtrlRect = MySellingItemListCtrl.GetRect();

	// 툴팁 클릭 안해도 나오도록..
	SellingItemListCtrl.SetSelectedSelTooltip(false);	
	SellingItemListCtrl.SetAppearTooltipAtMouseX(true);

	MySellingItemListCtrl.SetSelectedSelTooltip(false);
	MySellingItemListCtrl.SetAppearTooltipAtMouseX(true);
}

/***
 * 아데나 업데이트 
 **/
function updateAdenaText()
{
	local string adenaString;
	
	adenaString = MakeCostString( string(GetAdena()) );

	MyAdena.SetText(adenaString);
	MyAdena.SetTooltipString( ConvertNumToText(string(GetAdena())) );

	MyAdena2.SetText(adenaString);
	MyAdena2.SetTooltipString( ConvertNumToText(string(GetAdena())) );
}

/***
 * 콤보 박스 초기 세팅
 **/
function comboInit ()
{
	// 종류
	Type_Combobox.Clear();
	Type_Combobox.SYS_AddString(144);
	Type_Combobox.SYS_AddString(2611);
	Type_Combobox.SYS_AddString(2621);
	Type_Combobox.SetSelectedNum(0);

	// 등급
	Grade_Combobox.Clear();
	Grade_Combobox.SYS_AddString(144);  // 전체
	Grade_Combobox.SYS_AddString(2622); // 무급

	Grade_Combobox.SYS_AddString(2613); // D
	Grade_Combobox.SYS_AddString(2614); // C
	Grade_Combobox.SYS_AddString(2615); // B
	Grade_Combobox.SYS_AddString(2616); // A
	Grade_Combobox.SYS_AddString(2617); // S

	Grade_Combobox.SYS_AddString(2682); // S80
	//branch 110706_110804
	//Grade_Combobox.SYS_AddString(2683); // S84
	//end of beanch

	Grade_Combobox.SYS_AddString(2618); // R
	Grade_Combobox.SYS_AddString(2619); // R95
	Grade_Combobox.SYS_AddString(2620); // R99
	Grade_Combobox.SetSelectedNum(0);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 이벤트 -> 해당 이벤트 처리 핸들러
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function OnEvent( int Event_ID, string param )
{
	//Debug("==========================================================================");
	//Debug("Event_ID : " @ Event_ID);
	//Debug("param    : " @ param);

	switch (Event_ID)
	{
		// 창 열기
	    case EV_ItemCommissionWndShow               : updateAdenaText(); itemCommissionWndShowHandler(param); break;
	    //branch110706
	    case EV_ItemCommissionWndSellingPremiumItemRegisterReset : debug("판매대행 유로아이템 리셋" ); updateAdenaText(); SellingPremiumItemRegisterReset(param); break;
	    case EV_ItemCommissionWndSellingPremiumItemRegister : debug("판매대행 유로아이템" @ param); updateAdenaText(); SellingPremiumItemRegisterAdd(param); break;
	    //end of branch	    
		// 아이템 목록 받기 
		case EV_ItemCommissionWndListStart          : updateAdenaText(); startListHandler(param); break;
		case EV_ItemCommissionWndEachItem           : updateAdenaText(); addElementAtList(param); break;

		// 판매 가능한 아이템 리스트 받기 
		case EV_ItemCommissionWndRegistrableItemCnt : updateAdenaText(); itemCommissionWndListStartHandler(param);
													  break;
		// 등록 가능 아이템에 하나씩 추가													  
		case EV_ItemCommissionWndRegistrableItemList: updateAdenaText(); registrableItemAdd(param); break;

		// 이전 올렸다면 가격과 정보를 리턴 받는다.		
		case EV_ItemCommissionWndResponseInfo       : updateAdenaText(); itemCommissionWndResponseInfoHandler(param); break;

		// 등록 결과
		case EV_ItemCommissionWndRegisterResult     : updateAdenaText(); itemCommissionWndRegisterResultHandler(param); break;		

		// 등록 한 것 삭제
		case EV_ItemCommissionWndDeleteResult       : updateAdenaText(); ItemCommissionWndDeleteResultHandler(param); break;

		// 구입요청함수 이벤트
		case EV_ItemCommissionWndBuyInfo            : updateAdenaText(); askDialogBuyItem(param);  break;
  
		// 구입 결과
		case EV_ItemCommissionWndBuyResult          : updateAdenaText(); ItemCommmissionWndBuyResultHandler(param);  break;

		// 판매대행 npc와 일정 거리가 떨어지면 , 창을 닫는다.
		case EV_ItemCommissionWndCloseCauseOfLongDistance : OnReceivedCloseUI(); break;

		// TTP #59728 - gorillazin 13.01.09.
		//case EV_ItemCommissionWndSearchFail         : updateAdenaText(); itemCommissionWndSearchFailHandler(); break;
		case EV_ItemCommissionWndSearchFail         : updateAdenaText(); itemCommissionWndSearchFailHandler(param); break;
		//
		case EV_DialogOK                            : updateAdenaText(); HandleDialogOK(); break;
		case EV_DialogCancel                        : updateAdenaText(); HandleDialogCancel(); break;

		case EV_Restart: break;

		//무료 이용자가 판매 등록을 했을 때
		
		case EV_ItemCommissionRegisterWndCloseCauseOfFreeUser:		
			DialogSetID( DIALOG_FREEUSER_ONREGISTE  );
			DialogSetDefaultOK();
			DialogShow(DialogModalType_Modal, DialogType_OK, GetSystemMessage( 4049 ), string(Self) );
		break;


	}
}

function OnHide()
{
	if( DialogIsMine() )
	{
		PlayConsoleSound(IFST_WINDOW_CLOSE);
		DialogHide();
	}
	// 등록 시도시, 서버가 잡고 있는 아이템이 있으면 취소 시킨다.
	callRequestCommissionCancel();
	resetUI();
}

/**  아이템 판매 대행 윈도우 열기 */
function itemCommissionWndShowHandler(string param)
{
	local int Result;
	
	ParseInt(param, "Result", Result);

	if (Result == 1)
	{
		resetUI(); 
		Me.ShowWindow();
	}
}

/** 아이템 목록의 결과에 따른 처리 */
function itemCommissionWndListStartHandler(string param)
{
	local int cnt;
	
	ParseInt(param, "cnt", cnt);

	if (cnt <= 0) 
	{
		if (SellingListWnd.IsShowWindow())
		{
			DescriptionMsgWnd.ShowWindow();
			DescriptionMsg.SetText(GetSystemMessage(3369));

		}		
	}
	MySellingPossibItem.Clear();	
	MySellingItemIcon.Clear();  
	updateSellRegisterForm();
}

/** 검색 실패 */
// TTP #59728 - gorillazin 13.01.09.
//function itemCommissionWndSearchFailHandler()
function itemCommissionWndSearchFailHandler(string param)
//
{
	//Debug("--> 검색 실패 이벤트 발생" @ currentTreeNodeSelected);
	// TTP #59728 - gorillazin 13.01.09.
	local int failReason;
	ParseInt(param, "ErrorMsg", failReason);
	//

	// 내 아이템 목록 삭제
	if (TabCtrl.GetTopIndex() == 1) MySellingItemListCtrl.DeleteAllItem();	

	// TTP #59728 - gorillazin 13.01.09.
	if (failReason == SEARCH_FAIL_REASON_DELAY)
	{
		startReSearchDelay();

		return;
	}
	//

	if (currentTreeNodeSelected != "root.list0")
	{		
		SellingItemListCtrl.DeleteAllItem();
		
		DescriptionMsgWnd.ShowWindow();

		// 내가 등록한 아이템 목록 카운트 
		MySellingItemNumber.SetText( "(" $ String(MySellingItemListCtrl.GetRecordCount()) $ "/" $ maxSellingItemNum $ ")");

		//DescriptionMsg.SetText(GetSystemMessage(3372));

		if (SearchWord_Editbox.GetString() == "")
		{
			DescriptionMsg.SetText(GetSystemMessage(3372));
		}
		else
		{
			// DescriptionMsg.SetText("\"" $ SearchWord_Editbox.GetString() $ "\"" @ "\\n 가 판매 목록에 존재하지 않습니다.");
			DescriptionMsg.SetText(MakeFullSystemMsg(GetSystemMessage(3502), SearchWord_Editbox.GetString()));
		}
		
		// 3502 // $1 아이템이 판매 목록에 존재하지 않습니다.

		// 판매 중인 아이템 리스트
		SellingItemNumber.SetText( "(" $ String(SellingItemListCtrl.GetRecordCount()) $ ")");

	}
}

/***
 *  구매 완료 
 **/
function ItemCommmissionWndBuyResultHandler(string param)
{
	local int Result, Enchant, ClassId;
	local ItemID mItemID;
	local INT64 Amount;

	local ItemInfo targetItemInfo;
	
	ParseInt(param, "Result" , Result);
	ParseInt(param, "Enchant", Enchant);	
	ParseINT64(param, "Amount" , Amount);

	ParseInt(param, "ClassId", ClassId);

	mItemID.ClassID = ClassId;

	class'UIDATA_ITEM'.static.GetItemInfo(mItemID, targetItemInfo );
	
	if (Result == 1) 
	{
		// Debug("구매 완료 " @ param );
		targetItemInfo.Enchanted = Enchant;
		targetItemInfo.AllItemCount = Amount;
		
		AddSystemMessageString(MakeFullSystemMsg(GetSystemMessage(3530), 
							   getItemNameForSellingAgency(targetItemInfo), 
							   String(Amount))); 
				
	}

	else
	{
//		Debug("구매 중 오류 " @ param );
	}

	Me.EnableWindow();
	// 다시 현재 리스트를 받음.
	sellListSearch();
}

/** 내가 등록한 리스트 삭제 ItemCommissionWndDeleteResult   */
function ItemCommissionWndDeleteResultHandler(string param)
{
	local int Result;

	ParseInt(param, "Result", Result);

	// Debug("deleteIndexMySellingItemListCtrl:" @ deleteIndexMySellingItemListCtrl);

	if (Result == 1)
	{
		
		// if (deleteIndexMySellingItemListCtrl >= 0) { Debug("deleteIndexMySellingItemListCtrl" @ deleteIndexMySellingItemListCtrl); };
		// MySellingItemListCtrl.DeleteRecord(deleteIndexMySellingItemListCtrl);
	}
	else
	{
		//Debug("판매 취소! 실패 ");
	}

	// 아이템 카운트
	if (listCommissionStatus == 2)
	{
		// 내가 판매 등록한 아이템 리스트		
		MySellingItemNumber.SetText( "(" $ String(MySellingItemListCtrl.GetRecordCount()) $ "/" $ maxSellingItemNum $ ")");
		
	}
	else
	{
		// 판매 중인 아이템 리스트
		SellingItemNumber.SetText( "(" $ String(SellingItemListCtrl.GetRecordCount()) $ ")");
	}

	// 갱신 
	clickTabButton("TabCtrl1");

}


/** 판매대행 리스트에 등록 된 아이템 목록, 내가 등록한 아이템 목록을 받아 온다. */
function startListHandler(string param)
{
	local int moreThanMax, listType, continuousList;

	// TTP #59728 - gorillazin 13.01.09.
	DescriptionMsgWnd.HideWindow();
	DescriptionMsg.SetText("");
	//

	// 1000개 넘으면..
	ParseInt(param, "MoreThanMax", moreThanMax);

	ParseInt(param, "ListType", listType);
	ParseInt(param, "ContinuousList", continuousList);

	// 검색 결과가 출력 가능한 최대 범위를 초과하였습니다.
	if(moreThanMax != 0) AddSystemMessage(3489);

	listCommissionStatus = listType;
	// 새로 시작인 경우 기존의 데이타 삭제. 1이 들어 오면 연속해서 들어 오는 것이기 때문에 삭제 기존 값을 삭제 하지 않은.
	if (continuousList == 0)
	{
		// Debug(CommissionStatus.CsRegisteredOk);

		//  namespace CommissionStatus 
		//	enum Enum 
		//	{ 
		//	CsRegisteredFail = -2, 
		//	CsSearchFail = -1, 
		//	CsFail = 0, 
		//	CsOk, 
		//	CsRegisteredOk, 
		//	CsSearchOk, 
		//	CsStatusMAX 
		//	}; 

		switch(listType)
		{
			case 1 : SellingItemListCtrl.DeleteAllItem();   break;
			case 2 : MySellingItemListCtrl.DeleteAllItem(); break;
			case 3 : SellingItemListCtrl.DeleteAllItem();   break;
			case 4 : break;

			default : Debug("ListStart Error:" @ param);
		}
	}
}

/** 이벤트 : 등록 가능한지 결과,   */
function itemCommissionWndResponseInfoHandler (string param)
{
	local int Result, ClassID, Period;

	local INT64 prePrice, Amount;
	local itemInfo initInfo;

	ParseInt( param, "Result", Result );
	ParseInt( param, "ClassID", ClassID );
	ParseInt( param, "Period", Period );
	
	ParseINT64( param, "Amount", Amount );
	ParseINT64( param, "prePrice", prePrice );

	// Debug("Result: "@ Result);
	// Debug("ClassID: "@ ClassID);
	// Debug("prePrice: "@ prePrice);
	
	// Debug("startItemWIndowName: " @ startItemWIndowName);
	// Debug("nSaveTempItemIndex : " @ nSaveTempItemIndex);
	// Debug("MySellingPossibItem: " @ MySellingPossibItem);

	if (startItemWIndowName == "MySellingItemIcon")
	{
		MoveItemTopToBottom( nSaveTempItemIndex, false );
	}
	else if (startItemWIndowName == "MySellingPossibItem")
	{
		MoveItemBottomToTop( nSaveTempItemIndex, false );
	}

	if (Result == 1)
	{	
		// Debug("beforeDropItemInfo.itemNum" @ beforeDropItemInfo.itemNum);
		if (beforeDropItemInfo.AllItemCount > 0 ) 
		{
			// 4자리 최대 값 
			if (beforeDropItemInfo.itemNum > MAX_SELLING_AMOUNT)
			{
				// 넣을 수 있는 최대 아이템 수량 99999를 넣는다.
				DialogSetString(String(MAX_SELLING_AMOUNT));
			}
			else
			{
				// 현재 남은 모든 아이템수
				DialogSetString(String(beforeDropItemInfo.itemNum));
			}
		}
		else
		{
			// 이전에 저장 했던 정보 기억
			// 1보다 크다면 수량성으로 취급
			if (Amount >= 1) DialogSetString(String(Amount));
		}

		//debug("beforeDropItemInfo.AllItemCount" @ beforeDropItemInfo.AllItemCount);
		//debug("beforeDropItemInfo.itemNum---> " @ beforeDropItemInfo.itemNum);
		//debug("Amount---> " @ Amount);
		//debug("beforeDropItemInfo.ConsumeType : " @ beforeDropItemInfo.ConsumeType);
		//debug("IsStackableItem( beforeDropItemInfo.ConsumeType ): " @ IsStackableItem( beforeDropItemInfo.ConsumeType ));

		// 수량성 아이템이 아니면 다음으로 포커스 넘김
		if (beforeDropItemInfo.itemNum > 1 || Amount > 1 || IsStackableItem( beforeDropItemInfo.ConsumeType ))
		{
			// empty 아무것도 안함
		}
		else
		{
			MySellingItemUnitPriceEdit.SetFocus();
		}


		if (Period >= 0) MySellingItemRegistPeriodComboBox.SetSelectedNum(Period);
		if (prePrice > 0) MySellingItemUnitPriceEdit.SetString(string(prePrice));

		beforeAmount   = Amount;		
		beforePeriod   = Period;
		beforePrePrice = prePrice;

		updateSellRegisterForm();		
	}
	else
	{
		startItemWIndowName = "";
	}
	
	// 이전 드랍 했던 아이템 초기화
	beforeDropItemInfo = initInfo;
}

/** 이벤트 : 아이템 등록 완료 결과 */
function itemCommissionWndRegisterResultHandler (string param)
{
	local int Result, Ok;
	 
	ParseInt( param, "Result", Result );
	ParseInt( param, "Ok", Ok );

	if (Result == 1 || Ok == 1)
	{
		//Debug("아이템 등록 완료 -> RequestCommissionRegisteredItem 실행 ");
		// 등록한 아이템 보기
		// class'consignmentSaleAPI'.static.RequestCommissionRegisteredItem(); 
	}
	else
	{
		//Debug("아이템 등록 실패");
	}

	// 아이템 등록 성공, 실패 관계 없이 다시 "등록가능한 아이템" 갱신
	//class'consignmentSaleAPI'.static.RequestCommissionRegisteredItem(); 
	
	// 판매 대행 아이템 올라 간것 삭제
	// MySellingItemIcon.Clear();
	// 판매 대행에 올려진 아이템이 없다면.. 초기화
	//initRegistItemForm();

	// 등록 및 조회 부분 전체 초기화
	OnClickButton("TabCtrl1");
}


/***
 *  등록 가능 아이템 
 *  에 아이템을 추가 한다.  
 **/
function registrableItemAdd(string param)
{
	local ItemInfo info;
	
	ParamToItemInfo( param, info );	
	MySellingPossibItem.AddItem(info);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 아이템 윈도우를 더블 클릭 이벤트 (아이템을 상하로 이동)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/** Desc :  상하, 아이템 목록의 아이템을 "더블 클릭"  */
function OnDBClickItem( string ControlName, int index )
{
	local ItemInfo info;
	// local int nSelect; //, itemType;

	// Debug("ControlName:" @ControlName);
	if(ControlName == "MySellingPossibItem")
	{
		// MySellingItemIcon.GetItem(0, info);


		MySellingPossibItem.GetItem(index, info);
		nSaveTempItemIndex = index; // MySellingPossibItem.FindItem(info.ID );	        	

		// debug("index:" @ index);
		// debug("info.name:" @ info.name);
		// Debug("info.AllItemCount  : "  @ info.AllItemCount);
		// Debug("nSaveTempItemIndex : "  @ nSaveTempItemIndex);

		saveTempItemInfo = info;
		beforeDropItemInfo = info;
		startItemWIndowName = "MySellingItemIcon";
		callRequestCommissionInfo(info);
	}
	else if(ControlName == "MySellingItemIcon")
	{		
		MySellingItemIcon.GetItem(index, info);
		if( index >= 0 ) MoveItemBottomToTop( index, false );		
	}

}

//레코드를 더블클릭하면....
function OnDBClickListCtrlRecord( string ListCtrlID)
{
	//local LVDataRecord	record;	
	
	if (ListCtrlID == "SellingItemListCtrl")
	{
		OnBuyBtnClick();
	}
	if (ListCtrlID == "MySellingItemListCtrl")
	{
		// 등록 가능 상태가 아닐때 판매 취소 가능하니까..
		OnSellCancelBtnClick();		
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 아이템 윈도우 -> 드래그 이벤트
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/** Desc : 상하, 아이템을 "드랍"  */
function OnDropItem( string strID, ItemInfo info, int x, int y)
{
	local int index;
	local itemInfo initInfo;

	// debug("OnDropItem strID " $ strID $ ", src=" $ info.DragSrcName);
	
	index = -1;
	
	if( info.DragSrcName == "MySellingPossibItem") //&& strID == "MySellingItemIcon"  )
	{
		index = MySellingPossibItem.FindItem(info.ID );	        	
		nSaveTempItemIndex = index;
		saveTempItemInfo = info;
		startItemWIndowName = strID;
		
		beforeDropItemInfo = info;
		//if (info.AllItemCount > 0 ) allItemCountFlag = true;
		// else allItemCountFlag = false;

		callRequestCommissionInfo(info);
	}	
	else if(info.DragSrcName == "MySellingItemIcon") // && strID == "MySellingPossibItem")
	{
		beforeDropItemInfo = initInfo;
		//Find With ServerID
		index = MySellingItemIcon.FindItem(info.ID );	        
		if( index >= 0 ) MoveItemBottomToTop( index, info.AllItemCount > 0 );
	}
}


/**
 * 
 *  인벤토리 -> 판매 대행 등록 윈도우 아이템으로 이동
 *  (개인 상점 쪽에서 퍼왔음 -_-;)
 *  
 **/
function MoveItemTopToBottom( int index, bool bAllItem )
{
	local ItemInfo info, topInfo;
	local int topIndex;

	if( MySellingPossibItem.GetItem( index, info) )
	{

		// debug("info.ConsumeType" @ info.ConsumeType);
		// debug("info.ItemNum" @ info.ItemNum);
		// 몇개 옮길건지 물어본다
		if( !bAllItem && IsStackableItem( info.ConsumeType ) && info.ItemNum >= 1)		
		{

			DisableCurrentWindow(true);
			DialogSetID( DIALOG_STACKABLE_ITEM_INVEN_TO_ACCOMPANY  );
			DialogSetEditBoxMaxLength(6);
			// ServerID			
			DialogSetReservedItemID( info.ID );
			DialogSetParamInt64( info.ItemNum );
			DialogSetDefaultOK();
			
			// getItemNameForSellingAgency(targetItemInfo, targetItemInfo.name, targetItemInfo.AdditionalName, Enchant)


			DialogShow(DialogModalType_Modalless, DialogType_NumberPad, MakeFullSystemMsg( GetSystemMessage(3496), info.Name, "" ), string(Self) );
		}
		else
		{
			// 등록할 아이템과 현재 드래그 한 아이템이 다른 아이템 이라면..
			if (mysellingitemicon.finditem( info.id ) == -1 && mysellingitemicon.getItemNum() > 0)
			{
				// 전체를 이동
				moveItembottomtotop(0, true);				
			}

			// debug("mysellingitemicon.finditem( info.id )" @ mysellingitemicon.finditem( info.id ));

			MySellingPossibItem.DeleteItem( index );

			topindex = MySellingItemIcon.FindItem(info.ID );		                // ServerID

			if( topIndex >=0 && IsStackableItem( info.ConsumeType ) )	                	// 수량성 아이템이면 개수만 업데이트
			{
				MySellingItemIcon.GetItem( topIndex, topInfo );
				topInfo.ItemNum += info.ItemNum;
				MySellingItemIcon.SetItem( topIndex, topInfo );
			}
			else
			{
				MySellingItemIcon.AddItem( info );
			}

			// 속성 업데이트 
			updateAttributeRegistItemForm(info);
		}		
	}
	
	updateSellRegisterForm();
}

/**
 * 
 *   판매 대행 등록 윈도우 아이템 -> 인벤토리으로 이동
 *  
 **/
function MoveItemBottomToTop( int index, bool bAllItem )
{	
	local ItemInfo info, topInfo;
	local int topIndex;
	if( MySellingItemIcon.GetItem( index, info) )
	{
		// 몇개 옮길건지 물어본다
		if( !bAllItem && IsStackableItem( info.ConsumeType ) && info.ItemNum > 1 )		
		{
			DisableCurrentWindow(true);
			DialogSetID( DIALOG_STACKABLE_ITEM_ACCOMPANY_TO_INVEN  );
			DialogSetEditBoxMaxLength(6);
			// ServerID
			DialogSetReservedItemID( info.ID );			
			DialogSetParamInt64( info.ItemNum );
			
			DialogSetDefaultOK();	
			DialogShow(DialogModalType_Modalless, DialogType_NumberPad, MakeFullSystemMsg( GetSystemMessage(3496), info.Name, "" ), string(Self) );
		}
		else
		{
			//callRequestCommissionCancel();
			MySellingItemIcon.DeleteItem( index );

			topindex = MySellingPossibItem.FindItem(info.ID );		                // ServerID

			if( topIndex >=0 && IsStackableItem( info.ConsumeType ) )	           	// 수량성 아이템이면 개수만 업데이트
			{
				MySellingPossibItem.GetItem( topIndex, topInfo );
				topInfo.ItemNum += info.ItemNum;
				MySellingPossibItem.SetItem( topIndex, topInfo );
			}
			else
			{
				MySellingPossibItem.AddItem( info );
			}
		}	
	}
	updateSellRegisterForm();
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 다이얼로그 박스 처리 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/** Desc : 다이얼로그 윈도우를 열고 OK 버튼 누른 경우 */
function HandleDialogOK()
{
	local int id, bottomIndex, topIndex;
	local ItemInfo bottomInfo, topInfo;
	local ItemID scID;
	local ItemInfo scInfo;
	local INT64 inputNum;

	if( DialogIsMine() )
	{
		id = DialogGetID();
	
		inputNum = INT64( DialogGetString() );
		scID = DialogGetReservedItemID();
		DialogGetReservedItemInfo(scInfo);
		
		// 다이얼로그는 차례대로 가격 결정(DIALOG_ASK_PRICE)-> 
		// 가격이 기본 가격과 차이가 날 경우 가격 확인(DIALOG_CONFIRM_PRICE)->
		// 아이템이동(DIALOG_STACKABLE_ITEM_INVEN_TO_ACCOMPANY)의 순서대로 사용된다
		
		// 개수대로 아이템을 옮긴다.
		if( id == DIALOG_STACKABLE_ITEM_INVEN_TO_ACCOMPANY && inputNum > 0 )			         
		{
			MoveItemBottomToTop(0, true);
			// <- ServerID ->			
			topIndex = MySellingPossibItem.FindItem ( scID );        	 
			if( topIndex >= 0 )
			{
				MySellingPossibItem.GetItem( topIndex, topInfo );
				// <- ServerID ->
				bottomIndex = MySellingItemIcon.FindItem( scID );
				MySellingItemIcon.GetItem( bottomIndex, bottomInfo );
				
				// 아래쪽에 이미 있는 아이템이고 수량성 아이템이라면 가격을 엎어쓰고 개수는 더해준다.
				//if( bottomIndex >= 0 && IsStackableItem( bottomInfo.ConsumeType ) )			
				//{
				//	bottomInfo.Price = DialogGetReservedInt2();
				//	bottomInfo.ItemNum += Min64( inputNum, topInfo.ItemNum );
				//	MySellingItemIcon.SetItem( bottomIndex, bottomInfo );
				//}
				//// 새로운 아이템을 넣는다
				//else					
				//{
				//	if (MySellingItemIcon.FindItem( bottomInfo.ID ) == -1 && MySellingItemIcon.GetItemNum() > 0)
				//	{
				//		// 전체를 이동
				//		MoveItemBottomToTop(0, true);
				//	}
				//	bottomInfo = topInfo;
				//	bottomInfo.ItemNum = Min64( inputNum, topInfo.ItemNum );
				//	bottomInfo.Price = DialogGetReservedInt2();
				//	MySellingItemIcon.AddItem( bottomInfo );
				//}

				if (MySellingItemIcon.GetItemNum() > 0)
				{
					// 전체를 이동
					MoveItemBottomToTop(0, true);
				}
				bottomInfo = topInfo;
				bottomInfo.ItemNum = Min64( inputNum, topInfo.ItemNum );
				bottomInfo.Price = DialogGetReservedInt2();
				MySellingItemIcon.AddItem( bottomInfo );

				// 위쪽 아이템의 처리
				topInfo.ItemNum -= inputNum;
				if( topInfo.ItemNum <= 0 )
					MySellingPossibItem.DeleteItem( topIndex );
				else
					MySellingPossibItem.SetItem( topIndex, topInfo );
			}

			//if (beforeAmount > 1) DialogSetString(String(beforeAmount));
			if (beforePeriod >= 0) MySellingItemRegistPeriodComboBox.SetSelectedNum(beforePeriod);
			if (beforePrePrice > 0) MySellingItemUnitPriceEdit.SetString(string(beforePrePrice));

			updateSellRegisterForm();
		}
		// 아래쪽 것을 빼서 위로 옮겨준다.
		else if( id == DIALOG_STACKABLE_ITEM_ACCOMPANY_TO_INVEN && inputNum > 0 )		
		{

			// <- ServerID ->
			bottomIndex = MySellingItemIcon.FindItem( scID );
			if( bottomIndex >= 0 )
			{
				MySellingItemIcon.GetItem( bottomIndex, bottomInfo );

				// <- ServerID ->
				topIndex = MySellingPossibItem.FindItem( scID );

				if( topIndex >=0 && IsStackableItem( bottomInfo.ConsumeType ) )
				{
					MySellingPossibItem.GetItem( topIndex, topInfo );
					topInfo.ItemNum += Min64( inputNum, bottomInfo.ItemNum );
					MySellingPossibItem.SetItem( topIndex, topInfo );
				}
				else
				{
					topInfo = bottomInfo;
					topInfo.ItemNum = Min64( inputNum, bottomInfo.ItemNum );
					MySellingPossibItem.AddItem( topInfo );
				}

				bottomInfo.ItemNum -= inputNum;
				if( bottomInfo.ItemNum > 0 )
				{
					MySellingItemIcon.SetItem( bottomIndex, bottomInfo );
				}
				else 
				{
					//callRequestCommissionCancel();
					MySellingItemIcon.DeleteItem( bottomIndex );
				}
			}
			updateSellRegisterForm();
		}
		else if (id == DIALOG_ASK_PRICE)
		{
			MySellingItemUnitPriceEdit.SetString(String(inputNum));
		}
		else if (id == DIALOG_ASK_REGISTITEM)
		{
			// 현재 아이템을 등록 한다.
			callRequestCommissionRegister();
		}
		else if (id == DIALOG_ASK_BUY)
		{
			callRequestCommissionBuyItem();
		}
		else if (id == DIALOG_ASK_DELETE)
		{
			callRequestCommissionDelete();
			// callRequestCommissionBuyItem();			
		}
		else if ( id == DIALOG_FREEUSER_ONREGISTE ) 
		{
			TabCtrl.SetTopOrder(0, false);			
		}

		///////////////////
		updateSellRegisterForm();		
	}
	DisableCurrentWindow(false);
} 

/** Desc : 다이얼로그 윈도우를 열고 Cancel 버튼 누른 경우 */
function HandleDialogCancel() //파티루팅변경 동의창 
{
	if( DialogIsMine() )
	{
		// empty
	}

	// 다른 다이얼로그가 캔슬 되었을때도 비활성화를 풀어야 한다.
	DisableCurrentWindow(false);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// OnComboBoxItemSelected  콤보박스를 선택
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function OnComboBoxItemSelected( string comboName, int index ) 
{
	/// local PartyWnd script;

	//  Debug("comboName" @ comboName);
	//	Debug("index" @ index);
	switch( comboName )
	{
		case "Type_Combobox": 
			 // nCurrentTypeCombo = Type_Combobox.GetSelectedNum();
			 OnSearchBtnClick();
			 break;

		case "Grade_Combobox":	
			 OnSearchBtnClick();
			 // nCurrentGradeCombo = Grade_Combobox.GetSelectedNum();
			 break;
		case "MySellingItemRegistPeriodComboBox" : updateSellRegisterForm(); // 등록 기간 세팅, 폼 업데이트
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  리스트 클릭 (상세정보 요청)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function OnClickListCtrlRecord( string ListCtrlID)
{
	local LVDataRecord Record;		

	local string param;
	local int nSelect; //, itemType;

	nSelect = SellingItemListCtrl.GetSelectedIndex();

	if (nSelect >= 0) 
	{  
		SellingItemListCtrl.GetSelectedRec(record);

		param = Record.szReserved;
		// Debug("Click Item param=>" @ param);
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 버튼 클릭 - 각종 버튼 클릭 핸들러
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function OnClickButton( string Name )
{
	// Debug("OnClickButton" @ Name);
	switch( Name )
	{
		case "SearchBtn":
			OnSearchBtnClick();
			break;
		case "ResetBtn":
			OnResetBtnClick();
			break;
		case "RefreshBtn":
			OnRefreshBtnClick();
			break;
		case "BuyBtn":
			OnBuyBtnClick();
			break;
		case "SellBtn" : 	
			// 판매 등록 버튼을 클릭하여 판매 아이템 등록 창을 연다.
			SellingItemRegistrationWndShow();
			break;

		case "SellCancelBtn":
			//리스트에서 항목을 하나 선택해서 판매 취소 버튼 클릭하면 해당 아이템 등록 취소
			OnSellCancelBtnClick();
			break;
			
		case "MySellingItemUnitPriceEditBtn":
			// 현재 가격 계산기 나오도록 
			OnMySellingItemUnitPriceEditBtnClick();
			break;

		case "RegistBtn":
			// 서버에 판매 등록할 아이템을 올린다.
			// callRequestCommissionInfo();
			askDialogRegisterItem();
			// callRequestCommissionRegister();
			break;

		case "CancelBtn":
			callRequestCommissionCancel();
			// MySellingItemListCtrlExtend(true);
			break;
		case "TabCtrl0"  : 
		case "TabCtrl1"  : updateAdenaText(); clickTabButton(Name); break;
	}

	// 트리 클릭 
	clickTreeState (Name);
	
}

/** 탭 버튼을 클릭한 경우 처리 */
function clickTabButton(string tabName)
{	
	// Debug("GetTopIndex()" @ GetTabHandle("TabCtrl").GetTopIndex());
	switch(tabName)
	{
		case "TabCtrl0" : 
						  // callRequestCommissionCancel();  
						  // DisableCurrentWindow(false);
						  // Me.KillTimer( TIMER_SEARCH_ID );
						  //// clickTreeState(currentTreeNodeSelected);
						  OnSearchBtnClick();
				   		  break;

		case "TabCtrl1" : // 등록한 아이템 리스트 얻어 오기 					 
						  callRequestCommissionCancel();
						  SellingItemRegistrationWndShow();
						  class'consignmentSaleAPI'.static.RequestCommissionRegisteredItem(); 
						  
						  // 내가 팔고 있는 아이템 목록 확대
						  // MySellingItemListCtrlExtend(true);
						  // 이전에 타이머가 돌아 가고 있는게 있다면 작동을 멈추게 한다.
						  // Me.KillTimer( TIMER_SEARCH_ID );
						
						  DisableCurrentWindow(false);						  
						  break;
	}

	
	
}

/** 검색 버튼 클릭 */
function OnSearchBtnClick()
{
	// 도움말 상태가 아니라면..
	if (currentTreeNodeSelected != "root.list0" && disableCurrentWindowFlag == false)
	{
		if (currentTreeNodeSelected == "root.list1")
		{
			SellingItemListWnd.ShowWindow();
			// 전체 
			HelpHtmlWnd.HideWindow();
			if (SearchWord_Editbox.GetString() == "") 
			{
				SellingItemListCtrl.DeleteAllItem();				
				DescriptionMsgWnd.ShowWindow();
				DescriptionMsg.SetText(GetSystemMessage(3444));		
				SellingItemNumber.SetText("");
			}
			else
			{
				SellingItemListWnd.ShowWindow();
				SellingItemNumber.SetText("");
				sellListSearch();				
			}			
			//SearchWord_Editbox.EnableWindow();			
		}
		else
		{
			sellListSearch();	
		}
	}	
	
	SearchWord_Editbox.SetFocus();
}

/** 초기화 버튼 클릭 */
function OnResetBtnClick()
{
	// 종류, 등급, 검색어 초기화 
	SearchWord_Editbox.SetString("");
	Type_Combobox.SetSelectedNum(0);
	Grade_Combobox.SetSelectedNum(0);

	OnSearchBtnClick();
}

/** 아이템 목록 (구매목록) 갱신 버튼 */
function OnRefreshBtnClick()
{
	sellListSearch();
}

/** 구매 버튼을 클릭 (해당 아이템 확인 후 구매 프로세스) */
function OnBuyBtnClick()
{
	local int nSelect; //, itemType;

	nSelect = SellingItemListCtrl.GetSelectedIndex();

	if (nSelect >= 0) 
	{  
		callRequestCommissionBuyInfo();
	}
	else
	{
		// 아이템 목록에서 물품을 선택해주십시오.
		AddSystemMessage(3443);
	}
}

/** 판매 취소 */
function OnSellCancelBtnClick()
{
	local int nSelect;

	nSelect = MySellingItemListCtrl.GetSelectedIndex();
	
	if (nSelect >= 0) 
	{  
		askDialogDeleteItem();
	}
	else 
	{   
		// 아이템 목록에서 물품을 선택해주십시오.
		AddSystemMessage(3443);
	}
}

/** 개당 판매 가격 입력 계산기 */
function OnMySellingItemUnitPriceEditBtnClick()
{
	local ItemInfo info;

	if (MySellingItemIcon.GetItemNum() > 0)
	{
		MySellingItemIcon.GetItem(0, info);

		// Ask price
		DialogSetID( DIALOG_ASK_PRICE );
		DialogSetReservedItemID( info.ID );				// ServerID
		//DialogSetReservedInt3( int(bAllItem) );		// 전체이동이면 개수 묻는 단계를 생략한다
		DialogSetEditType("number");
		DialogSetParamInt64( -1 );
		DialogSetDefaultOK();
		DialogShow(DialogModalType_Modalless, DialogType_NumberPad, GetSystemMessage(322), string(Self) );
		DisableCurrentWindow(true);
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 클라이언트 - 서버 연동 API
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/***
 * 구매할 아이템 확인 API 
 **/
function callRequestCommissionBuyInfo()
{
	local LVDataRecord Record;		
	local INT64  commissionDBId, commissionItemType;

	local string param;
	local int nSelect; //, itemType;

	nSelect = SellingItemListCtrl.GetSelectedIndex();

	if (nSelect >= 0) 
	{  
		SellingItemListCtrl.GetSelectedRec(record);

		param = Record.szReserved;

		ParseINT64(param, "CommissionItemType", commissionItemType);
		ParseINT64(param, "CommissionDBId", commissionDBId);

		// ParseInt(param, "itemType", itemType);

		// 아이템구매 API 실행
		//Debug("아이템 구매 RequestCommissionBuyInfo -> ");
		//Debug("CommissionDBId " @ CommissionDBId);
		//Debug("commissionItemType " @ commissionItemType);
		// Debug("itemType " @ itemType);
		
		class'consignmentSaleAPI'.static.RequestCommissionBuyInfo(commissionDBId, Int(commissionItemType)); 
	}
}

/**
 * 아이템 구매 API
 **/
function callRequestCommissionBuyItem()
{
	local LVDataRecord Record;		
	local INT64 commissionItemType, commissionDBId;

	local string param;
	local int nSelect; //, itemType;

	nSelect = SellingItemListCtrl.GetSelectedIndex();

	if (nSelect >= 0) 
	{  
		SellingItemListCtrl.GetSelectedRec(record);

		param = Record.szReserved;

		ParseINT64(param, "CommissionDBId"    , commissionDBId);
		ParseINT64(param, "CommissionItemType", commissionItemType);

		
		//Debug("구매 시도 ! consignmentSaleAPI()-> ");
		//Debug("CommissionDBId !" @ CommissionDBId );
		//Debug("commissionItemType !" @ commissionItemType );
		
		class'consignmentSaleAPI'.static.RequestCommissionBuyItem(commissionDBId, Int(commissionItemType)); 
	}
}

/** 
 *  class'consignmentSaleAPI'.static.RequestCommissionInfo(int serverID); 
 *  parameter  설명  
 *	serverID  등록하려는Item의 serverID 
 *  
 **/
function callRequestCommissionInfo(ItemInfo info)
{
	// Debug("RequestCommissionInfo 아이템 서버 ID: info.Id.ServerID -> " @ info.Id.ServerID );		
	class'consignmentSaleAPI'.static.RequestCommissionInfo(info.Id.ServerID); 
}

/***
 *
 *  판매할 아이템 서버에 등록 
 *  function registerItem (ItemInfo info, string itemName, INT64 pricePerUnit, INT amount, int period)
 **/
function callRequestCommissionRegister()
{
	//branch 110706
	local int sellpremiumitemID;
	local CommissionPremiumItemInfo sellPremiumIteminfo;
	//end of branch
	
	local ItemInfo info;	
	local INT64 pricePerUnit, amount;

	// 갯수, 기간 CommissionExpired::Enum 참고  
	local int nPeriod; 
	
	if (MySellingItemIcon.GetItemNum() > 0)
	{
		MySellingItemIcon.GetItem(0, info);

		pricePerUnit = INT64(MySellingItemUnitPriceEdit.GetString());
					
		amount = info.ItemNum;
		
		nPeriod = MySellingItemRegistPeriodComboBox.GetSelectedNum();
		//branch110706
		if( nPeriod > 3 )
		{
			sellPremiumIteminfo = sellPremiumitemArray[ nPeriod - 4 ];
			sellpremiumitemID = sellPremiumIteminfo.commissionItemId;
//			Debug("sellpremiumitem:" @ sellpremiumitemID);	
		}
		else
		{
			sellpremiumitemID = 0;
		}
		//end of branch

		//Debug("등록 실행 -> RequestCommissionRegister ");
		//Debug("info.Name -> " @ info.Name);
		//Debug("pricePerUnit -> " @ pricePerUnit);
		//Debug("amount -> " @ amount);
		//Debug("nPeriod -> " @ nPeriod);
		// call 판매 등록
		
		class'consignmentSaleAPI'.static.RequestCommissionRegister(info.Id.ServerID, info.Name, pricePerUnit, amount, nPeriod, sellpremiumitemID); 
	}
}

/** 서버에서 현재 잡고 있는 아이템을 캔슬 한다. */
function callRequestCommissionCancel()
{
	if (MySellingItemIcon.GetItemNum() > 0) 
	{
		class'consignmentSaleAPI'.static.RequestCommissionCancel();
	}
}

/***
 * 내가 판매하고 있는 아이템을 삭제 한다.(판매취소)
 * callRequestCommissionDelete
 **/
function callRequestCommissionDelete()
{
	local INT64  commissionDBId;
	local int    periodType, commissionItemType;

	local LVDataRecord Record;		
	local string param;
	local int nSelect;

	nSelect = MySellingItemListCtrl.GetSelectedIndex();
	
	if (nSelect >= 0) 
	{  
		MySellingItemListCtrl.GetSelectedRec(record);
		param = Record.szReserved;

		ParseINT64(param, "CommissionDBId"    , commissionDBId);
		ParseInt(param,   "CommissionItemType", commissionItemType);	
		ParseInt(param,   "PeriodType"        , periodType);


		//Debug("================================================================");
		//Debug("commissionDBId:" @ commissionDBId);
		//Debug("commissionItemType:" @ commissionItemType);	
		//Debug("periodType:" @ periodType);
 
		class'consignmentSaleAPI'.static.RequestCommissionDelete(commissionDBId, commissionItemType, periodType); 
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 다이얼로그 박스 -  물어 보기 세팅
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/** 아이템을 구매 할꺼야?  */
function askDialogBuyItem (string param)
{
	local LVDataRecord Record;		

	local INT64 commissionDBId, commissionItemType, commissionPrice, amount;
	
	local int nSelect; //, itemType;

	local int    consumeType;
	local string itemName;

	nSelect = SellingItemListCtrl.GetSelectedIndex();

	if (nSelect >= 0) 
	{  
		//callRequestCommissionBuyInfo();
		SellingItemListCtrl.GetSelectedRec(record);

		// param = Record.szReserved;

		ParseString(param, "name", itemName);

		ParseINT64(param, "CommissionItemType", commissionItemType);
		ParseINT64(param, "CommissionDBId", commissionDBId);
		ParseINT64(param, "CommissionPrice"   , commissionPrice);

		ParseInt(param, "ConsumeType", consumeType);

		itemName = Record.LVDataList[0].szData;
		amount = INT64(Record.LVDataList[2].szData);
		
		DialogSetID( DIALOG_ASK_BUY );

		// 수량성 아이템이라면..		
		if (IsStackableItem( consumeType ))
		{			
			DialogShowWithResize
					  (DialogModalType_Modalless, DialogType_OKCancel, 
					   MakeFullSystemMsg(GetSystemMessage(3425), deleteRightSpeceString(itemName), 
					   String(amount), ConvertNumToText(String(CommissionPrice)), ConvertNumToText(String(CommissionPrice * amount))), -1, 224, string(Self));	
		}
		// 수량성 아이템이 아니라면..
		else
		{
			DialogShowWithResize
				(DialogModalType_Modalless, DialogType_OKCancel, MakeFullSystemMsg(GetSystemMessage(3424), 
				 deleteRightSpeceString(itemName), ConvertNumToText(String(CommissionPrice))), -1, 224, string(Self));	
		}

		DisableCurrentWindow(true);
	}
}

/** 정말 등록 할지 물어 보는 다이얼로그 열기 */
function askDialogRegisterItem ()
{
	local ItemInfo info;

	local INT64 pricePerUnit;
	local INT64 amount;
	// local int period;

	//class'consignmentSaleAPI'.static.RequestCommissionRegister(itemName, pricePerUnit, amount, period); 
	// local ItemInfo info;

	// 아이템이 하나라도 등록되어 있고, 가격이 0보다 크게 입력되어 있다면..
	if (MySellingItemIcon.GetItemNum() > 0 && Int(MySellingItemUnitPriceEdit.GetString()) > 0 )
	{
		MySellingItemIcon.GetItem(0, info);
		pricePerUnit = INT64(MySellingItemUnitPriceEdit.GetString());
		// period       = MySellingItemRegistPeriodComboBox.GetSelectedNum();
		amount       = info.ItemNum;

		// Ask price
		DialogSetID( DIALOG_ASK_REGISTITEM );
		// DialogSetReservedItemInfo(info);


		// 수량성 아이템이라면..
		if (IsStackableItem( info.ConsumeType ))
		{
			// 판매 등록하실 아이템은 $s1, $s2개이며 개당 판매 가격은 $s3, 총 판매 가격은 $s4아데나입니다. 정말로 등록하시겠습니까? 
			DialogShowWithResize
					  (DialogModalType_Modalless, DialogType_OKCancel, 
					   MakeFullSystemMsg(GetSystemMessage(3422), deleteRightSpeceString(info.Name), String(amount), 
					   ConvertNumToText(String(pricePerUnit)), ConvertNumToText(String(amount * pricePerUnit)),
					   ConvertNumToText(commissionStr)), -1, 352, string(Self));	
		}
		// 수량성 아이템이 아니라면..
		else
		{
			DialogShowWithResize
					   (DialogModalType_Modalless, DialogType_OKCancel, MakeFullSystemMsg(GetSystemMessage(3421), 
					   deleteRightSpeceString(getItemNameForSellingAgency(info)),
					   ConvertNumToText(String(pricePerUnit)),ConvertNumToText(commissionStr)), -1, 288, string(Self));	
		}	

		DisableCurrentWindow(true);
	}
	updateSellRegisterForm();

	
}

/** 삭제 할지 물어 보는 다이얼로그 열기 */
function askDialogDeleteItem ()
{
	local LVDataRecord Record;		
	local int nSelect, consumeType;
	local string param, itemName;
	local INT64 itemNum, CommissionPrice; 
	local int PeriodType;

	nSelect = MySellingItemListCtrl.GetSelectedIndex();
	
	if (nSelect >= 0) 
	{  
		MySellingItemListCtrl.GetRec(nSelect, Record);
		param =	Record.szReserved;

		ParseInt  ( param, "ConsumeType"    , consumeType );
		ParseInt  ( param, "PeriodType"     , PeriodType );
		ParseINT64( param, "CommissionPrice", CommissionPrice);
		ParseINT64( param, "itemNum"        , itemNum);

		itemName = Record.LVDataList[0].szData;
		// itemNum = INT64(Record.LVDataList[3].szData);

		// Ask price
		DialogSetID( DIALOG_ASK_DELETE );
		// DialogSetReservedItemInfo(info);

		// 수량성 아이템이라면..
		if (IsStackableItem( consumeType ))
		{	
			// 2012.08.17 수정 정우균
			DialogShowWithResize(DialogModalType_Modalless, DialogType_OKCancel, 
									   MakeFullSystemMsg(GetSystemMessage(3429), deleteRightSpeceString(itemName), String(itemNum), ConvertNumToText(String(CommissionPrice)), 
									   ConvertNumToText(String(CommissionPrice * itemNum)),
									   ConvertNumToText( getCommisionNum(itemNum, CommissionPrice, PeriodType) )),
									   -1,352, string(Self));
		}
		// 수량성 아이템이 아니라면..
		else
		{
			// 2012.08.17 수정 정우균
			DialogShowWithResize(DialogModalType_Modalless, DialogType_OKCancel, MakeFullSystemMsg(GetSystemMessage(3428), 
									   deleteRightSpeceString(itemName), ConvertNumToText(String(CommissionPrice)), 
									   ConvertNumToText( getCommisionNum(1, CommissionPrice, PeriodType) )),
									   -1,288, string(Self));
		}	
		DisableCurrentWindow(true);
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 종속 유틸 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/** 판매 아이템 등록 창 나오도록 세팅 */
function MySellingItemListCtrlExtend(bool bOpen)
{
	if (bOpen)
	{
		// 등록한 판매 리스트 컨트롤 사이즈를 크게 한다.
		// 기본 520, 448
		// MySellingItemListCtrl.SetResizable(true);

		// 판매 취소, 판매 등록 버튼 보이도록 한다.
		SellBtn.EnableWindow();
		SellCancelBtn.EnableWindow();

		MySellingItemListCtrl.SetWindowSize(MySellingItemListCtrlRect.nWidth + 248, MySellingItemListCtrlRect.nHeight);

		MySellingItemListCtrl.SetColumnWidth(0, 220 + 200 - 1);
		MySellingItemListCtrl.SetColumnWidth(4,  74 +  47);
		
		MySellingItemListCtrlDeco.SetWindowSize(522 + 247, 19);		
		MySellingItemListGroupbox.SetWindowSize(524 + 247, 459);

		SellingItemListCtrlGroupboxDivider.SetWindowSize(771, 1);	
		//// 등록 창 안보이게 세팅 
		SellingItemRegistrationWnd.HideWindow();
	}
	else
	{
		// 판매 취소, 판매 등록 버튼 안보이도록 한다.
		SellBtn.DisableWindow();
		SellCancelBtn.DisableWindow();

		// MySellingItemListCtrl.SetResizable(true);
		MySellingItemListCtrl.SetWindowSize(MySellingItemListCtrlRect.nWidth, MySellingItemListCtrlRect.nHeight);
	
		MySellingItemListCtrl.SetColumnWidth(0, 220 - 10);
		MySellingItemListCtrl.SetColumnWidth(4,  84);

		MySellingItemListCtrlDeco.SetWindowSize(522, 19);		
		MySellingItemListGroupbox.SetWindowSize(524, 459);

		SellingItemListCtrlGroupboxDivider.SetWindowSize(523, 1);		
		
		//// 등록 창 보이게 세팅 
		SellingItemRegistrationWnd.ShowWindow();			
	}
}

/**
 *  "판매 등록" 윈도우를 보이게 하고 초기화
 **/ 
function SellingItemRegistrationWndShow()
{	
	// 등록한 판매 리스트 컨트롤 사이즈를 크게 한다.	 
	// MySellingItemListCtrl.SetResizeFrameSize(520, 448);
	// 아이템 항목
	// MySellingItemListCtrl.AdjustColumnWidth(0, 220);
	// 남은 기간 항목 
	// MySellingItemListCtrl.AdjustColumnWidth(4,  74);	 
	// 등록 창 안보이게 세팅 
	
	SellingItemRegistrationWnd.ShowWindow();

	// 판매 가능한 인벤토리 아이템 리스트 얻기 
	class'consignmentSaleAPI'.static.RequestCommissionRegistrableItemList(); 

	// 판매 대행 아이템 올려 놓은것 초기화 
	MySellingItemIcon.Clear();

	// 등록윈도우 보이게 하고, 아이템 목록 리스트 축소
	// MySellingItemListCtrlExtend(false);

	// 등록 기간 콤보 세팅
	// 1, ,3 , 5, 7 일 
	MySellingItemRegistPeriodComboBox.Clear();
	
	MySellingItemRegistPeriodComboBox.AddString(MakeFullSystemMsg(GetSystemMessage(3418), "1"));
	MySellingItemRegistPeriodComboBox.AddString(MakeFullSystemMsg(GetSystemMessage(3418), "3"));
	MySellingItemRegistPeriodComboBox.AddString(MakeFullSystemMsg(GetSystemMessage(3418), "5"));
	MySellingItemRegistPeriodComboBox.AddString(MakeFullSystemMsg(GetSystemMessage(3418), "7"));

	// 첫번째 1일을 기본으로 지정.
	MySellingItemRegistPeriodComboBox.SetSelectedNum(3);
	//branch 110706
	//인벤토리서 판매기간 유로아이템 체크
	class'consignmentSaleAPI'.static.RequestCommissionSellingPremiumItemList();
	//end of branch
	
	initRegistItemForm();
}


//branch 110706

function SellingPremiumItemRegisterReset(string param)
{
	sellPremiumitemArray.Length = 0;
}

function SellingPremiumItemRegisterAdd(string param)
{
	local CommissionPremiumItemInfo info;	
			
	ParseInt(param, "ID", info.commissionItemId);
	ParseString(param, "Name", info.commissionItemName);	
	ParseInt(param, "Period", info.commissionPeriod);
	ParseInt(param, "Expired", info.commissionExpired);
	ParseInt(param, "Discount", info.commissionDiscountInfo);
	ParseInt(param, "DiscountType", info.commissionDiscountInfoType);
	
	
	//Debug("ID:" @ info.commissionItemId);
	//Debug("Name:" @ info.commissionItemName);
	//Debug("Expired:" @ info.commissionExpired);
	//Debug("Discount:" @ info.commissionDiscountInfo);
	
	sellPremiumitemArray.Length = sellPremiumitemArray.Length + 1;
	sellPremiumitemArray[ sellPremiumitemArray.Length - 1 ] = (info);
	//유료아이템이 있는지 가져온다.	
	MySellingItemRegistPeriodComboBox.AddString( info.commissionItemName );
	
}


function MySellingItemRegistPeriodComboBoxSelectNum(int Period, int DiscountType)
{
	local int i, check;
	
	Debug("SelectNum: Period" @ Period);
	Debug("SelectNum: DiscountType" @ DiscountType);
	
	check = 0;
	if( Period >= 3 && DiscountType >= 0 )
	{
		for( i =0 ; i < sellPremiumitemArray.Length ;i++)
		{
			if( sellPremiumitemArray[i].commissionPeriod == Period && sellPremiumitemArray[i].commissionDiscountInfoType == DiscountType )
			{
				Debug("SelectNum: OK");
				MySellingItemRegistPeriodComboBox.SetSelectedNum( 4 + i );
				check = 1;
				break;
			}
		}		
		if( check == 0 )
		{
			Debug("SelectNum: FALE");
			MySellingItemRegistPeriodComboBox.SetSelectedNum(3);
		}
	}
	else
	{
		Debug("SelectNum: FALE");
		MySellingItemRegistPeriodComboBox.SetSelectedNum(Period);
	}	
	
}

//end of branch
/**
 *  트리에서 클릭 한 경우
 **/
function clickTreeState (string Name)
{	
	local array<string> nodeArray;
	local string tempStr;
	// debug("GetExpandedNode " @ SortListTree.GetExpandedNode(Name));
	// Debug("currentTreeNodeSelected: " @ currentTreeNodeSelected);

	// 같은 클릭을 했으면 검색..
	//local bool beforeSameNodeFlag;

	//beforeSameNodeFlag = false;
	// Debug("Name" @ Name);

	// 인존 트리 
	if (Left(Name, 4) == "root") 
	{	
		tempStr = Right(Name, 13);
		tempStr = Left(tempStr, 12);

		//if (disableCurrentWindowFlag && tempStr == "categoryType") { saveTreePath = Name; return; }
		/*
		if (disableCurrentWindowFlag && )
		{
			return;
		}
		*/
		//SellingItemNumber.SetText("");
	
		currentTreeNodeSelected = Name;
		Split(Name, ".", nodeArray);

		if (SortListTree.GetExpandedNode(Name) != "") beforeTreeNodeSelectedFlag = false;

		if (beforeTreeNodeSelected == Name)	
		{ 
			beforeTreeNodeSelectedFlag = !beforeTreeNodeSelectedFlag; 			
		}
		else 
		{ 
			if (SortListTree.GetExpandedNode(Name) != "") beforeTreeNodeSelectedFlag = false;
			else beforeTreeNodeSelectedFlag = true; 
		}
		// 이전 선택 했던 노드를 닫는다.
		setTreeNode(beforeTreeNodeSelected, false);
		
		// 현재 클릭했던 노드를 저장하여 다음 클릭 할때 닫는 정보
		beforeTreeNodeSelected = Name;

		// 현재 트리 노드를 열어 준다.
		setTreeNode(Name, true); 

		// 비활성화 상태면 동작을 멈춤
		if (disableCurrentWindowFlag) { saveTreePath = Name; return; }
		else { saveTreePath = ""; }
		

		// 도움말 열기
		if (Name == "root.list0")
		{
			openHtmlHelp();
			SellingItemListWnd.HideWindow();
			
			DescriptionMsgWnd.HideWindow();
			DescriptionMsg.SetText("");
			SellingItemNumber.SetText("");
			// SearchWord_Editbox.DisableWindow();			
		}
		else if (Name == "root.list1")
		{
			// 전체 
			HelpHtmlWnd.HideWindow();
			SellingItemListWnd.ShowWindow();

			if (SearchWord_Editbox.GetString() == "") 
			{
				SellingItemListCtrl.DeleteAllItem();
				DescriptionMsgWnd.ShowWindow();
				DescriptionMsg.SetText(GetSystemMessage(3444));		
				SellingItemNumber.SetText("");
			}
			else
			{
			//	if (beforeTreeNodeSelectedFlag == true)
			//	{
					SellingItemListWnd.ShowWindow();
					SellingItemNumber.SetText("");
					sellListSearch();				
			//	}
			}			
			//SearchWord_Editbox.EnableWindow();
			//ttp 58620 관련 게임시작 시 판매대행 에디트박스에 포커스가 가는 문제 때문에 채팅창에 입력이 되지 않는다.
			//그래서 창이 열려있을 경우에만 포커스 가도록 수정. 정우균 2013-03-11
			if(Me.IsShowWindow())
			{
				SearchWord_Editbox.SetFocus();
			}

			// 전체에서는 트리를 클릭했을때 검색을 하지 않는다.
		}
		// 아이템 목록 나오는 부분 열기
		else
		{
			//if (beforeTreeNodeSelectedFlag == true)
			//{			
				HelpHtmlWnd.HideWindow();
				SellingItemListWnd.ShowWindow();
				sellListSearch();		
			//}
			//SearchWord_Editbox.EnableWindow();
			
			SearchWord_Editbox.SetFocus();

		}		
	}
}

/**
 *  판매 리스트 서치
 **/
function sellListSearch ()
{	
	local array<string> nodeArray;
	local string Name;
	local string searchString, tempStr;

	local int depth;
	local int depthType;
	local int nameClass;
	local int grade;

	tempStr = Right(currentTreeNodeSelected, 13);
	tempStr = Left(tempStr, 12);

	// Debug("tempStr :" @tempStr);

		//if (disableCurrentWindowFlag && tempStr == "categoryType") { saveTreePath = Name; return; }

	// TTP #59728 - gorillazin 13.01.09.
	//DescriptionMsgWnd.HideWindow();
	//DescriptionMsg.SetText("");
	SellingItemListCtrl.DeleteAllItem();
	DescriptionMsgWnd.ShowWindow();
	DescriptionMsg.SetText(GetSystemMessage(3107));
	//

	// 현재 트리노드
	Name = currentTreeNodeSelected;
	// 인존 트리 
	
	// 현재 클릭한 영역이 도움말이 아닌 경우 
	if (Left(Name, 4) == "root" && "root.list0" != name) 
	{	
		
		Split(Name, ".", nodeArray);
		// Debug("Name " @ Name);
		// Debug("nodeArray.Length" @ nodeArray.Length);   

		// 전체 -> 무기 -> 한손검 같은 식으로 0, 1, 2 리턴
		depth = nodeArray.Length - 2;
		
		depthType = 0;

		// depth가 0일 경우 0, 1일경우 (WEAPON=1, ARMOR=20, ACCESSARY=31, GOODS=38, PET=46, ETC=49, 중에 하나), 
		if (depth <= 0)
		{
			depthType = 0;
		}
		else if (depth == 1) 
		{
			// categoryType0~..  한자리를 자른다.			
			// 무기, 방어구, 악세사리... 
			// WEAPON=1, ARMOR=20, ACCESSARY=31, GOODS=38, PET=46, ETC=49, 중에 하나
			depthType = int(Right(Name, 1)); //getDepthTypeNum(int(Right(Name, 1)));
		}
		// 2일경우 Commission::Enum의 ItemType
		else if (depth == 2) 
		{			
			depthType = getDepthTypeNum(int(Right(nodeArray[2], 1)), Int(Mid(nodeArray[3], 4)));

			//debug("Int(Mid(nodeArray[3], 4))" @ Int(Mid(nodeArray[3], 4)));
			//debug("nodeArray[2]" @ nodeArray[2]);
			//debug("int(Right(Name, 1)" @ int(Right(Name, 1)));
		}

		// 전체, 일반, 희귀
		nameClass = getItemType();
		// 그레이드 -1 전체 부터.. 11까지 R97
		grade = getSerachGrade();
				
		searchString = SearchWord_Editbox.GetString();
		
		//Debug("실행 ! class'ConsignmentSaleAPI'.static.RequestCommissionList()..");
		//Debug("depth         :" @ depth);
		//Debug("depthType     :" @ depthType);
		//Debug("nameClass     :" @ nameClass);
		//Debug("grade         :" @ grade);
		//Debug("searchString  :" @ searchString);
		
		// getSystemStringArray().length		
		class'ConsignmentSaleAPI'.static.RequestCommissionList(depth, depthType, nameClass, grade, searchString);
		beforeTreeNodeCalled = currentTreeNodeSelected;

		if (tempStr == "categoryType") startCategoryTreeSearchDelay();
		else startSearchDelay();

	}
}

/**
 * depthType 얻기 (서버에 보낼 값)
 * WEAPON=1, ARMOR=20, ACCESSARY=31, GOODS=38, PET=46, ETC=49, 중에 하나
 * 
 *  변경 되었다. 
	enum Enum 
	{ 
		Weapon = 0, Armor, Accessary, Goods, Pet, Etc, FirstMAX, 
	}; 
* 
 **/ 
function int getDepthTypeNum(int depthType, int targetIndex)
{
	local int nReturn;
	nReturn = -1;

	switch(depthType)
	{
		case 0 : nReturn = 1  + targetIndex; break;
		case 1 : nReturn = 19 + targetIndex; break;
		case 2 : nReturn = 29 + targetIndex; break;
		case 3 : nReturn = 35 + targetIndex; break;
		case 4 : nReturn = 42 + targetIndex; break;
		case 5 : nReturn = 44 + targetIndex; break;
	}

	//Debug ( "getDepthTypeNum" @ targetIndex @ nReturn );
	
	// depthType 이 액세서리 인 경우
	if ( depthType == 2 ) 
	{
		// UI인덱스 번호가 34번인 경우 ( 아가시온 ) 62번으로 요청
		if ( nReturn == 34 ) return 62;
		// UI인덱스 번호가 35 번인 경우 34번으로 요청
		else if ( nReturn == 35 ) return 34;
	}

	return nReturn;
}

/***
 * 현재 검색할 그레이드를 리턴한다.
 **/
function int getSerachGrade ()
{
	// 전체, 무급, D급, C급, B급, A급, S급, S80, S84, R, R90, R95
	//return Grade_Combobox.GetSelectedNum() - 1;
	local int gradeindex;
	gradeindex = Grade_Combobox.GetSelectedNum() - 1;
	//branch 110804 //s84가 사라진 관계로 노가다 코드 시작
	if( gradeindex < 7 )
	{
		return gradeindex;
	}
	return gradeindex + 1;
	//end of beanch	
}

/***
 * 현재 검색할 아이템 타입을 리턴한다.
 **/
function int getItemType ()
{
	// nameCalss  전체를 검색할경우 -1, 일반만 검색하면 0, 희귀만 검색하면 1  
	return Type_Combobox.GetSelectedNum() - 1;
}

/**
 * 지정한 스트링의 노드를 열어 준다. 
 **/
function setTreeNode(string nodeStr,bool bOpen)
{
	local array<string> nodeArray;
	local string targetNodeStr;
	local int i;
	
	Split(nodeStr, ".", nodeArray);
	
	targetNodeStr = "";

	for (i = 0; i < nodeArray.Length; i++)
	{
		targetNodeStr = targetNodeStr $ nodeArray[i];

		if (bOpen == false)
		{
			// 무조건 다 닫기
			SortListTree.SetExpandedNode(targetNodeStr, false);
		}
		else
		{
			if (i == (nodeArray.Length - 1)) 
			{
				// [+] 확장 노드의 경우는 닫혔다 열렸다..
				switch (Left(nodeArray[i], 4))
				{
					case "list"         : 
					case "cate"         : SortListTree.SetExpandedNode(targetNodeStr, beforeTreeNodeSelectedFlag); break;			
					default             : SortListTree.SetExpandedNode(targetNodeStr, true);
				}
			}
			else 
			{
				// 무조건 열기
				SortListTree.SetExpandedNode(targetNodeStr, true);
			}
		}
		
		targetNodeStr = targetNodeStr $ ".";
	}
}

/**
 *  리스트에 아이템 추가 
 *  addElementAtList
 **/
function addElementAtList(string param)
{
	local ItemInfo info;

	local ListCtrlHandle targetList;
	local LVDataRecord Record;

	local int k, itemAttributeCount;

	local string itemName, iconName, iconPanel, additionalName, LookChangeiconPanelName; //branch 110824
	local INT64  commissionPrice, commissionDBId,  commissionItemType;
	local int    expireTime, periodType, itemNum, itemType, crystalType, enchanted, consumeType, itemSubType;

	local int AttackAttributeType, AttackAttributeValue,
			  DefenseAttributeValueFire, DefenseAttributeValueWater, 
			  DefenseAttributeValueWind, DefenseAttributeValueEarth, 
			  DefenseAttributeValueHoly, DefenseAttributeValueUnholy;


	local color TextColor;

	itemAttributeCount = 0;
	// 자기가 등록한 판매 아이템 목록
	if (listCommissionStatus == 2)
	{
		// 내가 판매 등록한 아이템 리스트
		targetList = MySellingItemListCtrl;
	}
	else
	{
		// 판매 중인 아이템 리스트
		targetList = SellingItemListCtrl;
	}

	// Debug("------------");
	// Debug("param" @ param);
	ParseString(param, "iconName", iconName);
	ParseString(param, "name", itemName);
	ParseString(param, "iconPanel", iconPanel);
	ParseString(param, "LookChangeIconPanel", LookChangeiconPanelName);//branch 110824

	ParseString(param, "additionalName", additionalName);

	ParseINT64(param, "CommissionPrice"   , commissionPrice);
	ParseINT64(param, "CommissionDBId"    , commissionDBId);
	ParseINT64(param, "CommissionItemType", commissionItemType);

	ParseInt(param, "ExpireTime", expireTime);
	ParseInt(param, "PeriodType", periodType);

	ParseInt(param, "itemNum", itemNum);
	ParseInt(param, "itemType", itemType);
	ParseInt(param, "ItemSubType", itemSubType);
	
	ParseInt(param, "crystalType", crystalType);
	ParseInt(param, "enchanted", enchanted);
	ParseInt(param, "consumeType", consumeType);

	ParseInt(param, "AttackAttributeType"        , AttackAttributeType);
	ParseInt(param, "AttackAttributeValue"       , AttackAttributeValue);
	ParseInt(param, "DefenseAttributeValueFire"  , DefenseAttributeValueFire);
	ParseInt(param, "DefenseAttributeValueWater" , DefenseAttributeValueWater);
	ParseInt(param, "DefenseAttributeValueWind"  , DefenseAttributeValueWind);
	ParseInt(param, "DefenseAttributeValueEarth" , DefenseAttributeValueEarth);
	ParseInt(param, "DefenseAttributeValueHoly"  , DefenseAttributeValueHoly);
	ParseInt(param, "DefenseAttributeValueUnholy", DefenseAttributeValueUnholy);
	
	// 해당 아이템 정보 리스트에 넣을때꺼내올수 있도록 기억
	Record.szReserved = param;
    
	// 레코드 구성
	Record.LVDataList.length = 7;


	info.name           = itemName;
	info.additionalName = additionalName;
	info.enchanted      = enchanted;
	info.ItemSubType    = ItemSubType;

	// 신규 집혼 정보 업데이트
	addEnsoulInfoToItemInfoByParamString(param, info);

	// 아이템 
	Record.LVDataList[0].szData = getItemNameForSellingAgency(info);

	Record.LVDataList[0].hasIcon = true;
	Record.LVDataList[0].nTextureWidth=32;
	Record.LVDataList[0].nTextureHeight=32;
	Record.LVDataList[0].nTextureU=32;
	Record.LVDataList[0].nTextureV=32;
	Record.LVDataList[0].szTexture = iconName; 
	Record.LVDataList[0].IconPosX=10;
	Record.LVDataList[0].FirstLineOffsetX=6;

	Record.LVDataList[0].HiddenStringForSorting = itemName $ util.makeZeroString(3, enchanted);
	
	// back texture 
	Record.LVDataList[0].iconBackTexName="l2ui_ct1.ItemWindow_DF_SlotBox_Default";
	Record.LVDataList[0].backTexOffsetXFromIconPosX=-2;
	Record.LVDataList[0].backTexOffsetYFromIconPosY=-1;
	Record.LVDataList[0].backTexWidth=36;
	Record.LVDataList[0].backTexHeight=36;
	Record.LVDataList[0].backTexUL=36;
	Record.LVDataList[0].backTexVL=36;

	// panel texture 
	// 기본 병기의 경우 icon.low_tab 텍스쳐임.
	//if (iconPanel == "icon.low_tab")
	//{
	//	Record.LVDataList[0].iconPanelName = "icon.low_tab";
	//}
	//else
	//{
	//	Record.LVDataList[0].iconPanelName = ""; //"icon.low_tab";
	//}

	// 아이콘 테두리 (기본 병기.pvp 무기등)
	Record.LVDataList[0].iconPanelName = iconPanel;
	Record.LVDataList[0].LookChangeiconPanelName = LookChangeiconPanelName; //branch 110824

	Record.LVDataList[0].panelOffsetXFromIconPosX=0;
	Record.LVDataList[0].panelOffsetYFromIconPosY=0;
	Record.LVDataList[0].panelWidth=32;
	Record.LVDataList[0].panelHeight=32;
	Record.LVDataList[0].panelUL=32;
	Record.LVDataList[0].panelVL=32;

	// 속성 세팅 3개~ 4개.. 
	// 총 3개 속성.. 1개는 그외.. 더 있다는 것을 알리는 텍스쳐 아이콘 
	Record.LVDataList[0].attrIconTexArray.Length=4;
	// 칼라 
	Record.LVDataList[0].attrColor.R=170;
	Record.LVDataList[0].attrColor.G=170;
	Record.LVDataList[0].attrColor.B=170;
	
	for(k=0; k<4; ++k)
	{	
		Record.LVDataList[0].attrIconTexArray[k].X=0;
		Record.LVDataList[0].attrIconTexArray[k].Y=2;
		Record.LVDataList[0].attrIconTexArray[k].Width=14;
		Record.LVDataList[0].attrIconTexArray[k].Height=14;
		Record.LVDataList[0].attrIconTexArray[k].U=0;
		Record.LVDataList[0].attrIconTexArray[k].V=0;
		Record.LVDataList[0].attrIconTexArray[k].UL=14;
		Record.LVDataList[0].attrIconTexArray[k].VL=14;
	}

	// Record.LVDataList[0].attrIconTexArray[0].objTex = GetTexture("L2UI_CT1.EmptyBtn");
	// Record.LVDataList[0].attrStat[itemAttributeCount]= "";

	// 그외 안보이게 일단 해놓고..
	Record.LVDataList[0].attrIconTexArray[0].objTex = GetTexture("L2UI_CT1.EmptyBtn");
	Record.LVDataList[0].attrStat[3]= "";

	// 무기 속성 : 무기 속성은 1개이다.
	if ( AttackAttributeType >= 0)
	{		
		Record.LVDataList[0].attrIconTexArray[0].objTex = GetTexture(attributeTypeToTextureString(AttackAttributeType, itemType));
		Record.LVDataList[0].attrStat[0]= String(AttackAttributeValue);
		itemAttributeCount++;
	}
	else
	{
		if ((DefenseAttributeValueUnholy + DefenseAttributeValueHoly + DefenseAttributeValueEarth + 
			 DefenseAttributeValueWind + DefenseAttributeValueWater + DefenseAttributeValueFire) > 0)
		{			
			// 방어구 : 속성 최대 3개였으나.. 속성 6개 짜리 망토가 추가 되어서 예외 처리를 하기로 했음. 추후 6개짜리 속성을 넣은 
			// 아이템을 만들지 않기로 했지만 이미 풀린 아이템때문에 고려는 하기로 했음.			 
			// 물, 불, 바람, 흙, 신성, 암흑 
			if (DefenseAttributeValueWater > 0 && itemAttributeCount < 3) 
			{   
				Record.LVDataList[0].attrIconTexArray[itemAttributeCount].objTex = GetTexture(attributeTypeToTextureString(1, itemType));
				Record.LVDataList[0].attrStat[itemAttributeCount]= String(DefenseAttributeValueWater);
				itemAttributeCount++;		
			}

			if (DefenseAttributeValueFire > 0 && itemAttributeCount < 3) 
			{ 			
				Record.LVDataList[0].attrIconTexArray[itemAttributeCount].objTex = GetTexture(attributeTypeToTextureString(0, itemType));
				Record.LVDataList[0].attrStat[itemAttributeCount]= String(DefenseAttributeValueFire);			
				itemAttributeCount++;
			}

			if (DefenseAttributeValueWind > 0 && itemAttributeCount < 3)
			{   
				Record.LVDataList[0].attrIconTexArray[itemAttributeCount].objTex = GetTexture(attributeTypeToTextureString(2, itemType));
				Record.LVDataList[0].attrStat[itemAttributeCount]= String(DefenseAttributeValueWind);
				itemAttributeCount++;		
			}

			if (DefenseAttributeValueEarth > 0 && itemAttributeCount < 3)
			{
				Record.LVDataList[0].attrIconTexArray[itemAttributeCount].objTex = GetTexture(attributeTypeToTextureString(3, itemType));
				Record.LVDataList[0].attrStat[itemAttributeCount]= String(DefenseAttributeValueEarth);
				itemAttributeCount++;
			}

			if (DefenseAttributeValueHoly > 0 && itemAttributeCount < 3)
			{ 
				Record.LVDataList[0].attrIconTexArray[itemAttributeCount].objTex = GetTexture(attributeTypeToTextureString(4, itemType));
				Record.LVDataList[0].attrStat[itemAttributeCount]= String(DefenseAttributeValueHoly);
				itemAttributeCount++;
			}

			if (DefenseAttributeValueUnholy > 0 && itemAttributeCount < 3)
			{ 
				Record.LVDataList[0].attrIconTexArray[itemAttributeCount].objTex = GetTexture(attributeTypeToTextureString(5, itemType));
				Record.LVDataList[0].attrStat[itemAttributeCount]= String(DefenseAttributeValueUnholy);
				itemAttributeCount++;
			}

			itemAttributeCount = 0;
			if (DefenseAttributeValueWater  > 0) itemAttributeCount++;
			if (DefenseAttributeValueFire   > 0) itemAttributeCount++;
			if (DefenseAttributeValueWind   > 0) itemAttributeCount++;
			if (DefenseAttributeValueEarth  > 0) itemAttributeCount++;
			if (DefenseAttributeValueHoly   > 0) itemAttributeCount++;
			if (DefenseAttributeValueUnholy > 0) itemAttributeCount++;

			// 3개 이상.. 속성이 있다면.. 
			// 그외.. 처리
			if (itemAttributeCount > 3) 
			{				
				Record.LVDataList[0].attrIconTexArray[3].objTex = GetTexture("l2ui_ct1.SellingAgencyWnd_df_ItemPropertyIcon_add");
				Record.LVDataList[0].attrStat[3]= GetSystemString(2672);
				//Debug("그외 처리!!! " @ itemAttributeCount);
			}
		}
	}
	if (itemAttributeCount > 0)
	{
		Record.LVDataList[0].attrIconTexArray[0].X=0;
		Record.LVDataList[0].attrIconTexArray[1].X=30;
		Record.LVDataList[0].attrIconTexArray[2].X=30;
		Record.LVDataList[0].attrIconTexArray[3].X=30;
	}
	// Debug("itemType->" @ itemType);
	// debug("util.getItemGradeSystemString(crystalType); " @ util.getItemGradeSystemString(crystalType));
	
	// 무기, 방어구, 악세사리 만 등급을 표기해준다.(혼돈의 악마의 단검 이런건.. ITEM_ETCITEM 으로 나와서.. )
	if (itemType == EItemType.ITEM_WEAPON || itemType == EItemType.ITEM_ACCESSARY || itemType == EItemType.ITEM_ARMOR) // || itemType == EItemType.ITEM_ETCITEM)
	{
		// 장비 등급
		Record.LVDataList[1].szData = util.getItemGradeSystemString(crystalType); 
	}
	else
	{
		// 무급이 아닌 경우 등급을 출력 한다.
		if (crystalType != 0)
			Record.LVDataList[1].szData = util.getItemGradeSystemString(crystalType);
		else
			Record.LVDataList[1].szData = "-";		
	}

	Record.LVDataList[1].HiddenStringForSorting = util.makeZeroString(6, crystalType);
	Record.LVDataList[1].textAlignment=TA_Center;

	// 수량 

	Record.LVDataList[2].szData = String(itemNum);
	Record.LVDataList[2].HiddenStringForSorting = util.makeZeroString(6, itemNum);

	Record.LVDataList[2].textAlignment=TA_Center;

	Record.LVDataList[3].buseTextColor = True;
	TextColor = GetNumericColor( MakeCostString( String( commissionPrice  ) ) ) ;
	Record.LVDataList[3].TextColor = TextColor;
	// 2013.01.14 총 가격당으로 바꾼다.
	Record.LVDataList[3].szData = ConvertNumToTextNoAdena(String(commissionPrice  ));
	Record.LVDataList[3].HiddenStringForSorting = util.makeZeroString(20, commissionPrice );
	
	// 수량성 아이템
	if ( IsStackableItem( consumeType ) )
	{
		// 2줄로 표시
		// 개당 가격 		
		
		//Record.LVDataList[3].szData = ConvertNumToTextNoAdena(string(commissionPrice)); //MakeFullSystemMsg(GetSystemMessage(3442), );
			
		// Record.LVDataList[2].attrIconTexArray.Length = 1;
		Record.LVDataList[3].hasIcon = true;

		Record.LVDataList[3].attrColor.R = 170;
		Record.LVDataList[3].attrColor.G = 170;
		Record.LVDataList[3].attrColor.B = 170;
		//TextColor = GetNumericColor( MakeCostString( String( commissionPrice * itemNum ))) ;
		//Record.LVDataList[3].attrColor = TextColor ;
		// 2013.01.14 개당으로 바꾼다.
		Record.LVDataList[3].attrStat[0] = MakeFullSystemMsg(GetSystemMessage(3657), ConvertNumToTextNoAdena(String(commissionPrice * itemNum)));
		//Record.LVDataList[3].attrStat[0] = "(합계:" $ ConvertNumToTextNoAdena(String(commissionPrice * itemNum)) $ ")";
		//Record.LVDataList[3].HiddenStringForSorting = util.makeZeroString(20, commissionPrice * itemNum);
		// 개당 가격으로 정렬 되도록 한다. 추가 요청 : UI기획 - 장미영 
	}

	// 수량성 아이템이 아니라면..
	//else
	//{	
		//Record.LVDataList[3].TextColor = TextColor;
		//Record.LVDataList[3].szData = ConvertNumToTextNoAdena(String(commissionPrice));
	//	Record.LVDataList[3].HiddenStringForSorting = util.makeZeroString(20, commissionPrice); // String(commissionPrice);
	//}
	// Debug("commissionPrice:" @ commissionPrice * itemNum);
	// Debug("String         :" @ Record.LVDataList[3].HiddenStringForSorting);

	Record.LVDataList[3].textAlignment=TA_Right;
	
	Record.LVDataList[4].szData = ConvertTimeToString(expireTime); //string(util.getDayStringBySec(expireTime));
	Record.LVDataList[4].textAlignment=TA_RIGHT;
	Record.LVDataList[4].HiddenStringForSorting = util.makeZeroString(20, expireTime);
	
	targetList.InsertRecord( Record );	

	// 아이템 카운트
	if (listCommissionStatus == 2)
	{
		// 내가 판매 등록한 아이템 리스트
		MySellingItemNumber.SetText( "(" $ String(MySellingItemListCtrl.GetRecordCount()) $ "/" $ maxSellingItemNum $ ")");
		
	}
	else
	{
		// 판매 중인 아이템 리스트
		SellingItemNumber.SetText( "(" $ String(SellingItemListCtrl.GetRecordCount()) $ ")");
	}

	updateRecordItemCount();
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 유틸 함수 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/***
 * 
 *   왼쪽 트리 카테고리 항목을 초기화 한다.
 *   (트리 메뉴 세팅)
 *   
 **/
function categoryTreeInit()
{
	local string treeName, rootName;
	
	local int maxtitle;
	local int titleCount, categoryTypeCount, itemTypeCount;

	local string listName, itemName;

	local CustomTooltip T;
	local bool bDrawBgTree1;

	// "tree1_1_1 , 단계 구성..
	treeParam = "";
	beforeTreeNodeSelected = "";
	beforeTreeNodeSelectedFlag = false;
	bDrawBgTree1 = false;
	// 전체, 도움말..	
	util.setSystemStringArrayByNumStr("145,144", titleNameArray);
	
	// 무기, 방어구, 액세사리... 같은 카테고리 스트링 
	util.setSystemStringArrayByNumStr("2520,2532,2537,5006,2547,49", categoryTypeNameArray);

	util.setSystemStringArrayByNumStr("2521,2522,45,1648,2523,1650,2524,1970,2525,2526,2527,2528,2529,48,1649,2530,46,2531", item1Array);

	util.setSystemStringArrayByNumStr("2533,2534,2535,2536,37,40,231,1987,28,234", item2Array);

	// 3638 아가시온 추가
	util.setSystemStringArrayByNumStr("239,237,238,2538,2539,3638,1024", item3Array);

	util.setSystemStringArrayByNumStr("2540,2541,2542,2543,2544,2545,2546", item4Array);

	util.setSystemStringArrayByNumStr("2548,2549", item5Array);

	util.setSystemStringArrayByNumStr("2550,2551,2552,2553,2554,2555,2556,2557,2558,2559,2560,2561,2562,2563,25,2564", item6Array);

	treeName = "SellingAgencyWnd.SellingListWnd.SortListTree";
	rootName = "root";

	SortListTree.Clear();
	maxtitle = 5;

	ParamAdd( treeParam, "tree" $ "_" $ "length", string(titleNameArray.Length) );
	
	// root 만듬
	util.TreeInsertRootNode( treeName,  rootName, "", 0, 4 );

	// 인존 정보, 맴버 리스트 정보 얻기
	for (titleCount = 0; titleCount < titleNameArray.Length; titleCount++)
	{
		listName = "list" $ string(titleCount);
		
		if (titleCount == 0)		
		{
			// util.TreeInsertItemTooltipNode( treeName, listName, rootName, -7, 0, 15, 0, 20, 15, util.getCustomTooltip());

			// util.TreeInsertTextureNodeItem( treeName, rootName $ "." $ listName, "L2UI_CH3.BloodHoodWnd.BloodHood_Logon", 15, 15, 0, 0);


			util.TreeInsertExpandBtnNode( treeName, listName, rootName, 14, 14, "L2UI_CT1.SellingAgencyWnd_df_HelpBtn", 
																				"L2UI_CT1.SellingAgencyWnd_df_HelpBtn_Over", 
																				"L2UI_CT1.SellingAgencyWnd_df_HelpBtn", 
																				"L2UI_CT1.SellingAgencyWnd_df_HelpBtn_Over", 0, -2);

			// 무조건..도움말 부분에 최초 선택되어짐
			currentTreeNodeSelected = rootName $ "." $ listName;
		}
		else 
		{
			util.TreeInsertExpandBtnNode( treeName, listName, rootName );
		}
		
		// treeCategoryTypeArray
		// treeItemTypeArray

		listName = rootName $ "." $ listName;
		ParamAdd( treeParam, "tree" $ titleCount    , (listName) );
		
		// 텍스트
		util.TreeInsertTextNodeItem( treeName, listName, titleNameArray[titleCount], 5, 0, util.ETreeItemTextType.COLOR_DEFAULT, true );
		
		// 무기, 방어구, 액세사리, 소모품, 펫 용품, 키타 (카테고리 만들기)
		if (titleCount == 1)		
		{
			// 카테고리 수 저장
			ParamAdd( treeParam, "tree" $ titleCount $ "_" $ "length", string(categoryTypeNameArray.Length) );

			for(categoryTypeCount = 0; categoryTypeCount < categoryTypeNameArray.Length; categoryTypeCount++)
			{	
				util.TreeInsertExpandBtnNode( treeName, "categoryType" $ categoryTypeCount, rootName $ "." $ "list" $ titleCount,,,,,,,15);

				// 노드 생성 
				listName = rootName $ "." $ "list" $ string(titleCount) $ "." $ "categoryType" $ categoryTypeCount;
								 
				ParamAdd( treeParam, "tree" $ titleCount $ "_" $ categoryTypeCount, (listName) );

				ParamAdd( treeParam, "tree" $ titleCount $ "_" $ categoryTypeCount $ "_" $ "length"     , string(getSystemStringArray(categoryTypeCount).Length) );

				util.TreeInsertTextNodeItem( treeName, listName, categoryTypeNameArray[categoryTypeCount], 5, 0, util.ETreeItemTextType.COLOR_DEFAULT, true );

				// Debug("getSystemStringArray(categoryTypeCount).Length" @ getSystemStringArray(categoryTypeCount).Length);
				
				for (itemTypeCount = 0; itemTypeCount < getSystemStringArray(categoryTypeCount).Length; itemTypeCount++)
				{
					// 3단계 (한손 마법둔기..같은 상세 타입)
					// 전체-무기-[한손검,한손마법검....] <- 이부분
					itemName = TreeInsertItemTooltipNodeWithTexBackHighlight( treeName, "item" $ itemTypeCount, listName, 10, 0, 15, 0,  1, 15, T);
					//util.TreeInsertExpandBtnNode( treeName, "items", listName,,,,,,,15);
					//strRetName = util.TreeInsertItemTooltipNode( TREENAME, ""$ ID $","$ Level, setTreeName, -7, 0, 38, 0, 32, 38, util.getCustomTooltip() );
					ParamAdd( treeParam, "tree" $ titleCount $ "_" $ categoryTypeCount $ "_" $ itemTypeCount, (itemName) );

					// Debug("itemName :" @ itemName);
					if( bDrawBgTree1 )
					{
						//Insert Node Item - 아이템 배경?
						util.TreeInsertTextureNodeItem( TREENAME, itemName, "L2UI_CH3.etc.textbackline",160,15,10,,,,);
					}
					else
					{
						util.TreeInsertTextureNodeItem( TREENAME, itemName, "L2UI_CT1.EmptyBtn", 161, 15, 10 );
					}

					bDrawBgTree1 = !bDrawBgTree1;

					util.TreeInsertTextNodeItem( treeName, itemName, getSystemStringArray(categoryTypeCount)[itemTypeCount], -159, 0, util.ETreeItemTextType.COLOR_DEFAULT, true );
				} 
			}
		}
	}
}

/** 트리 확장될때 배경 라인을 그리기 위해 추가 - L2Util 것으로 하지 않고 이걸 사용 */
function string TreeInsertItemTooltipNodeWithTexBackHighlight( string TreeName, string NodeName, string ParentName, 
									int nTexExpandedOffSetX, int nTexExpandedOffSetY, 
									int nTexExpandedHeight, int nTexExpandedRightWidth, 
									int nTexExpandedLeftUWidth, int nTexExpandedLeftUHeight,									
									CustomTooltip TooltipText, optional string strTexExpandedLeft, optional int offSetX, optional int offSetY )
{
	//트리 노드 정보
	local XMLTreeNodeInfo infNode;	
	
	if( strTexExpandedLeft == "" ) strTexExpandedLeft = "L2UI_CH3.etc.IconSelect2";

	infNode.strName = NodeName;
	infNode.Tooltip = TooltipText;
	infNode.nOffSetX = offSetX;
	infNode.nOffSetY = offSetY;
	infNode.bFollowCursor = true;
	//Expand되었을때의 BackTexture설정
	//스트레치로 그리기 때문에 ExpandedWidth는 없다. 끝에서 -2만큼 배경을 그린다.
	infNode.nTexExpandedOffSetX = nTexExpandedOffSetX;
	infNode.nTexExpandedOffSetY = nTexExpandedOffSetY;		
	infNode.nTexExpandedHeight = nTexExpandedHeight;		
	infNode.nTexExpandedRightWidth = nTexExpandedRightWidth;		
	infNode.nTexExpandedLeftUWidth = nTexExpandedLeftUWidth; 		
	infNode.nTexExpandedLeftUHeight = nTexExpandedLeftUHeight;
	infNode.strTexExpandedLeft = strTexExpandedLeft;

	infNode.bDrawBackground = 1;
	infNode.bTexBackHighlight = 0;
	infNode.nTexBackHighlightHeight = 14;
	infNode.nTexBackWidth = 160; 
	infNode.nTexBackUWidth = 160;
	infNode.nTexBackOffSetX = 10;
	infNode.nTexBackOffSetY = -1;
	infNode.nTexBackOffSetBottom = 1;

	return class'UIAPI_TREECTRL'.static.InsertNode( TreeName, ParentName, infNode );
}

/** 
 * 등록 가능 아이템 윈도우를 비활성
 * 초대 등록 가능 아이템 수가 가득 차면 더 이상 등록 못하도록 아이템 윈도우 비활성화
 **/
function updateRecordItemCount()
{
	//Debug("MySellingItemListCtrl.GetRecordCount()->" $ MySellingItemListCtrl.GetRecordCount() $ ", " $ maxSellingItemNum);
	if(MySellingItemListCtrl.GetRecordCount() >= maxSellingItemNum)
	{	
		MySellingPossibItem.DisableWindow();
	}
	else
	{
		MySellingPossibItem.EnableWindow();
	}
}

/**
 *  강제 트리 노드 닫기
 **/
function allCloseTreeNode()
{
	local int i, m, n, array1Count, array2Count, array3Count;
	local int max1, max2, max3;
	
	local string target;
	local array<string> node1Array, node2Array, node3Array;
	
	array1Count = 0;
	array2Count = 0;
	array3Count = 0;

	ParseInt(treeParam, "tree_length", max1);

	for (i = 0; i < max1; i++)
	{
		ParseInt(treeParam, "tree" $ i $ "_length", max2);
		ParseString(treeParam, "tree" $ i, target);
		node1Array[array1Count] = target;
		array1Count++;
		// SortListTree.SetExpandedNode(target, false );
		for (m = 0; m < max2; m++)
		{
			ParseInt(treeParam, "tree" $ i $ "_" $ m $ "_" $ "length", max3);
			ParseString(treeParam, "tree" $ i $ "_" $ m, target);
			
			// SortListTree.SetExpandedNode(target, false );
			node2Array[array2Count] = target;
			array2Count++;

			for (n = 0; n < max3; n++)
			{
				ParseString(treeParam, "tree" $ i $ "_" $ m $ "_" $ n, target);
				node3Array[array3Count] = target;
				array3Count++;

				// SortListTree.SetExpandedNode(target, false );
			}
		}
	}

	for (i = 0; i < node3Array.Length; i++)
	{
		SortListTree.SetExpandedNode(node3Array[i], false );		
	}
	for (i = 0; i < node2Array.Length; i++)
	{
		SortListTree.SetExpandedNode(node2Array[i], false );		
	}
	for (i = 0; i < node1Array.Length; i++)
	{
		SortListTree.SetExpandedNode(node1Array[i], false );		
	}
	//currentTreeNodeSelected
}

/***
 *  도움말 열기 
 **/
function openHtmlHelp()
{
	if (!HelpHtmlWnd.IsShowWindow())
	{		
		HelpHtmlWnd.ShowWindow();
		HtmlViewer.LoadHtml("..\\L2Text\\help_consignment.htm");
	}
}

/**
 *  트리 메뉴 구성에 사용
 *  시스템 스트링 덩어리의 배열을 타입에 따라서 리턴한다.
 **/ 
function array<string> getSystemStringArray(int type)
{
	local array<string> tempArray;

	switch (type)
	{
		case 0 : return item1Array; break;
		case 1 : return item2Array; break;
		case 2 : return item3Array; break;
		case 3 : return item4Array; break;
		case 4 : return item5Array; break;
		case 5 : return item6Array; break;

		default : Debug("Error SellingAgencyWnd : 트리 메뉴 구성 정보가 잘못 되었습니다. type: " @ type); return tempArray;
	}
}

/***
 *  각 노드의 값을 비교 한다.
 *  단계 indexDepth 로 각 단계별로 같은지 검사 
 **/
function bool compareNode(string node1, string node2, int indexDepth)
{
	local bool bReturn;
	local array<string> node1Array, node2Array;
	
		
	bReturn = false;
	Split(node1, ".", node1Array);
	Split(node2, ".", node2Array);
		
	// 둘다 배열이 초과 하지 않았다면..
	if (isArrayStringCheckIndexOver(node1Array, indexDepth) && isArrayStringCheckIndexOver(node2Array, indexDepth))
	{
		if (node1Array[indexDepth] == node2Array[indexDepth])
		{
			bReturn = true;
			// Debug("같다.");
		}
	}
	return bReturn;
}

/**
 *   배열이 범위를 넘었나를 체크 한다. true면 정상, false 이면 오버 된 상태 
 **/
function bool isArrayStringCheckIndexOver(out array<string> tempArray, int index)
{
	if (tempArray.Length <= index) return false;
	else return true;
}

/** 판매 아이템 등록 폼 초기화 */
function initRegistItemForm()
{	
	// Debug("----initRegistItemForm--------");
	// 판매 대행에 올려 놓은게 하나도 없다면..
	if (MySellingItemIcon.GetItemNum() <= 0)
	{
		MySellingItemUnitPriceEdit.DisableWindow();
		MySellingItemUnitPriceEditBtn.DisableWindow();	
		// 판매 수량
		MySellingItemAmount.SetText("");	
	}
	
	MySellingItemName.SetName("",NCT_Normal,TA_LEFT);
	
	// 속성 값 초기화
	//MySellingItemPropertyIcon_01.SetTexture("");
	//MySellingItemPropertyIcon_02.SetTexture("");
	//MySellingItemPropertyIcon_03.SetTexture("");

	getAttributeTextureHandle(1).SetTexture("L2UI_CT1.EmptyBtn");
	getAttributeTextureHandle(2).SetTexture("L2UI_CT1.EmptyBtn");
	getAttributeTextureHandle(3).SetTexture("L2UI_CT1.EmptyBtn");
	getAttributeTextureHandle(4).HideWindow();

	MySellingItemPropertyValue_01.SetText("");
	MySellingItemPropertyValue_02.SetText("");
	MySellingItemPropertyValue_03.SetText("");

	// 그외 (4개 이상 속성이 있으면.. 더 있다고..만 알려준다.)
	MySellingItemPropertyValue_04.HideWindow();

	// 개당 판매 가격 
	MySellingItemUnitPriceEdit.SetString("");

	MySellingItemUnitPrice_ReadingText.SetText("");

	// 총 판매 가격			
	MySellingItemTotalPrice_ReadingText.SetText("");		
	MySellingItemTotalPrice.SetText("");

	// 등록 기간 7일로 초기화
	MySellingItemRegistPeriodComboBox.SetSelectedNum(3);
	// 비활성
	MySellingItemRegistPeriodComboBox.DisableWindow();

	// 최종 등록 수수료 
	MySellingItemCharge.SetText("");
	// MySellingItemCharge_ReadingText.SetText("");

	// 판매 수수료 
	MySellingItemSellCharge.SetText("");

	MySellingItemCharge.SetTooltipCustomType(commissionRateToolTip("", getSystemString(2514), getSystemString(2777)));
	MySellingItemSellCharge.SetTooltipCustomType(commissionRateToolTip("", getSystemString(2776), getSystemString(2778)));

	// 등록 버튼 비활성화
	RegistBtn.DisableWindow();
}

/** 판매 아이템 등록의 텍스트 폼들을 갱신 한다. */
function updateSellRegisterForm()
{
	local ItemInfo info;
	
	local INT64 commission, commissionSellComplete;	
	local string textValue;

	local Color tcolor;

	tcolor.R = 170;
	tcolor.G = 170;
	tcolor.B = 170;
	tcolor.A = 255;

	// Debug("----updateSellRegisterForm--------");
	if (MySellingItemIcon.GetItemNum() > 0)
	{
		// 비활성화 되었던 것을 활성화
		MySellingItemUnitPriceEdit.EnableWindow();
		MySellingItemUnitPriceEditBtn.EnableWindow();
		MySellingItemRegistPeriodComboBox.EnableWindow();
		
		MySellingItemIcon.GetItem(0, info);		

		textValue = MySellingItemUnitPriceEdit.GetString();

		// 개당 판매 가격 한글로 (ex) 10억 5000만)
		if (textValue == "")
		{
			textValue = "0";
		}
		// 등록 버튼 상태 
		if (INT64(textValue) > 0)
		{
			RegistBtn.EnableWindow();
		}
		else 
		{
			RegistBtn.DisableWindow();
		}

		// 개당 판매 가격 			
		MySellingItemUnitPrice_ReadingText.SetText(ConvertNumToTextNoAdena(textValue));
		
		// 총 판매 가격
		MySellingItemTotalPrice.SetText(MakeCostString(String(info.ItemNum * INT64(textValue))));
		MySellingItemTotalPrice_ReadingText.SetText(ConvertNumToTextNoAdena(String(info.ItemNum * INT64(textValue))));
		
		/////////////////
		// 수수료 계산
		/////////////////

		// 등록 수수료 
 		commission = info.ItemNum * INT64(textValue) * getComboPeriod(MySellingItemRegistPeriodComboBox.GetSelectedNum());
 		commission = (commission * 1) / 10000; // 0.0001 수수료 
 		commissionStr = String(commission);

		// 판매 수수료
		commissionSellComplete = info.ItemNum * INT64(textValue) * getComboPeriod(MySellingItemRegistPeriodComboBox.GetSelectedNum());
		commissionSellComplete = (commissionSellComplete * 5) / 1000; // 0.005 수수료
		commissionSellCompleteStr = String(commissionSellComplete);
		
		// Debug("-->" @  (info.ItemNum * INT64(textValue) * getComboPeriod(MySellingItemRegistPeriodComboBox.GetSelectedNum())) );

		// Debug("commission" @ commission);
		// Debug("commissionStr" @ commissionStr);
		
		// 등록 수수료
		// 최소 수수료가 1만 아데나 보다 작다면 최소수수료로 1만 아데나를 물린다.		
		if (commission < COMMISSION_MIN_PRICE)
		{				
			// 1000아덴 수수료 적용 
			commission = COMMISSION_REGISTER_MIN_PRICE;
			commissionStr = string(commission);
		}

		// 판매 완료 수수료  
		if (commissionSellComplete < COMMISSION_MIN_PRICE)
		{				
			// 1000아덴 수수료 적용 
			commissionSellComplete = COMMISSION_REGISTER_MIN_PRICE;
			commissionSellCompleteStr = string(commissionSellComplete);
		}

		// 최종 등록 수수료 
		MySellingItemCharge.SetText(MakeCostString(commissionStr));
		//MySellingItemCharge_ReadingText.SetText(ConvertNumToTextNoAdena(commissionStr));
		MySellingItemCharge.SetTooltipCustomType(commissionRateToolTip(ConvertNumToTextNoAdena(commissionStr) $ " " $ GetSystemString(469), 
												 getSystemString(2514), getSystemString(2777)));

		// 판매 수수료 
		MySellingItemSellCharge.SetText(MakeCostString(commissionSellCompleteStr));
		MySellingItemSellCharge.SetTooltipCustomType(commissionRateToolTip(ConvertNumToTextNoAdena(commissionSellCompleteStr) $ " " $ GetSystemString(469) , 
											getSystemString(2776), getSystemString(2778)));
				
		// 아이템 이름 
		MySellingItemName.SetNameWithColor( getItemNameForSellingAgency(info), NCT_Normal, TA_LEFT, tcolor );

		// 판매 수량
		MySellingItemAmount.SetText(String(info.ItemNum));
	}
	else
	{
		// 판매 대행 아이템 올라 간것 삭제
		MySellingItemIcon.Clear();

		// 판매 대행에 올려진 아이템이 없다면.. 초기화
		initRegistItemForm();
	}
	}

/**
 * 수수료 부분, 아데나 표기 툴팁 
 **/
function CustomTooltip commissionRateToolTip (string adenaStr, string title, string desc)
{
	local CustomTooltip T;
	util.setCustomTooltip(T);
	
	util.ToopTipMinWidth(300);
	util.ToopTipInsertText(title $ " : " $ adenaStr, true, false,util.ETooltipTextType.COLOR_DEFAULT );
	util.TooltipInsertItemBlank(2);	
	util.TooltipInsertItemLine();
	util.TooltipInsertItemBlank(4);
	util.ToopTipInsertText(desc, false, false );
	
	return util.getCustomTooltip();
}

/** 속성 필드 업데이트 */
function updateAttributeRegistItemForm(ItemInfo info)
{
	local int itemAttributeCount;
	local int ItemType;
	local Color tcolor;

	tcolor.R = 170;
	tcolor.G = 170;
	tcolor.B = 170;
	tcolor.A = 255;

	ItemType = info.ItemType;
	
	if (MySellingItemIcon.GetItemNum() > 0)
	{
		MySellingItemIcon.GetItem(0, info);		

		MySellingItemName.SetNameWithColor( getItemNameForSellingAgency(info), NCT_Normal, TA_LEFT, tcolor );
	}
	else 
	{
		MySellingItemName.SetNameWithColor( "", NCT_Normal, TA_LEFT, tcolor );
	}
	
    //(1) 속성아이콘
    //  - 컬럼 CenterLeft기준  x 40  / y 2
    //  - 각 속성 아이콘 간 간격 : 30px
    //  - 리소스 사이즈 : w 14 / h 14
    //     * 물 : l2ui_ct1.SellingAgencyWnd_df_ItemPropertyIcon_Water
    //     * 불 : l2ui_ct1.SellingAgencyWnd_df_ItemPropertyIcon_Fire
    //     * 바람 : l2ui_ct1.SellingAgencyWnd_df_ItemPropertyIcon_Wind
    //     * 대지:l2ui_ct1.SellingAgencyWnd_df_ItemPropertyIcon_Earth
    //     * 암흑:l2ui_ct1.SellingAgencyWnd_df_ItemPropertyIcon_Dark
    //     * 신성:l2ui_ct1.SellingAgencyWnd_df_ItemPropertyIcon_Divine
	itemAttributeCount = 0;

	getAttributeTextureHandle(1).SetTexture("L2UI_CT1.EmptyBtn");
	getAttributeTextureHandle(2).SetTexture("L2UI_CT1.EmptyBtn");
	getAttributeTextureHandle(3).SetTexture("L2UI_CT1.EmptyBtn");

	MySellingItemPropertyValue_01.SetText("");
	MySellingItemPropertyValue_02.SetText("");
	MySellingItemPropertyValue_03.SetText("");
	
	//Debug("info.DefenseAttributeValueFire" @ info.DefenseAttributeValueFire);
	//Debug("info.DefenseAttributeValueWater" @ info.DefenseAttributeValueWater);
	//Debug("info.DefenseAttributeValueWind" @ info.DefenseAttributeValueWind);
	//Debug("info.DefenseAttributeValueEarth" @ info.DefenseAttributeValueEarth);
	//Debug("info.DefenseAttributeValueHoly" @ info.DefenseAttributeValueHoly);
	//Debug("info.DefenseAttributeValueUnholy" @ info.DefenseAttributeValueUnholy);

	//Debug("info.AttackAttributeType  :" @ info.AttackAttributeType);
	//Debug("info.AttackAttributeValue :" @ info.AttackAttributeValue);
	
	// 무기 속성 : 무기 속성은 1개이다.
	if ( info.AttackAttributeType >= 0)
	{
		getAttributeTextureHandle(1).SetTexture(attributeTypeToTextureString(info.AttackAttributeType, itemType));
		getAttributeTextBoxHandle(1).SetText(String(info.AttackAttributeValue));

	}
	else
	{
		// 방어구 속성  : 방어구 속성은 최대 3개 까지
		// 6가지 속성 값, 텍스쳐 채우기
		if (info.DefenseAttributeValueWater > 0 && itemAttributeCount < 3) 
		{   
			itemAttributeCount++;
			getAttributeTextureHandle(itemAttributeCount).SetTexture(attributeTypeToTextureString(1, itemType));
			getAttributeTextBoxHandle(itemAttributeCount).SetText(String(info.DefenseAttributeValueWater));
		}
		
		if (info.DefenseAttributeValueFire > 0 && itemAttributeCount < 3) 
		{ 
			itemAttributeCount++;		
			getAttributeTextureHandle(itemAttributeCount).SetTexture(attributeTypeToTextureString(0, itemType));
			getAttributeTextBoxHandle(itemAttributeCount).SetText(String(info.DefenseAttributeValueFire));
		}
		
		if (info.DefenseAttributeValueWind > 0 && itemAttributeCount < 3)
		{   
			itemAttributeCount++;
			getAttributeTextureHandle(itemAttributeCount).SetTexture(attributeTypeToTextureString(2, itemType));
			getAttributeTextBoxHandle(itemAttributeCount).SetText(String(info.DefenseAttributeValueWind));
		}

		if (info.DefenseAttributeValueEarth > 0 && itemAttributeCount < 3)
		{
			itemAttributeCount++;
			getAttributeTextureHandle(itemAttributeCount).SetTexture(attributeTypeToTextureString(3, itemType));
			getAttributeTextBoxHandle(itemAttributeCount).SetText(String(info.DefenseAttributeValueEarth));
		}
		
		if (info.DefenseAttributeValueHoly > 0 && itemAttributeCount < 3)
		{ 
			itemAttributeCount++;
			getAttributeTextureHandle(itemAttributeCount).SetTexture(attributeTypeToTextureString(4, itemType));
			getAttributeTextBoxHandle(itemAttributeCount).SetText(String(info.DefenseAttributeValueHoly));
		}
		
		if (info.DefenseAttributeValueUnholy > 0 && itemAttributeCount < 3)
		{ 
			itemAttributeCount++;
			getAttributeTextureHandle(itemAttributeCount).SetTexture(attributeTypeToTextureString(5, itemType));
			getAttributeTextBoxHandle(itemAttributeCount).SetText(String(info.DefenseAttributeValueUnholy));
		}

		
		itemAttributeCount = 0;
		if (info.DefenseAttributeValueWater  > 0) itemAttributeCount++;
		if (info.DefenseAttributeValueFire   > 0) itemAttributeCount++;
		if (info.DefenseAttributeValueWind   > 0) itemAttributeCount++;
		if (info.DefenseAttributeValueEarth  > 0) itemAttributeCount++;
		if (info.DefenseAttributeValueHoly   > 0) itemAttributeCount++;
		if (info.DefenseAttributeValueUnholy > 0) itemAttributeCount++;

		// 3개 이상.. 속성이 있다면.. 
		// 그외.. 처리
		if (itemAttributeCount > 3) 
		{							
			getAttributeTextureHandle(4).ShowWindow(); 
			getAttributeTextBoxHandle(4).ShowWindow();
			//Debug("그외 처리!!! " @ itemAttributeCount);
		}
		// debug("---> 그외 처리 itemAttributeCount: " @ itemAttributeCount);

		
	}
}


/** 속성 텍스쳐 핸들 리턴*/
function TextureHandle getAttributeTextureHandle(int num)
{
	local TextureHandle tempTextureHandle;

	switch(num)
	{
		case 1 : tempTextureHandle = MySellingItemPropertyIcon_01; break;
		case 2 : tempTextureHandle =  MySellingItemPropertyIcon_02; break;
		case 3 : tempTextureHandle =  MySellingItemPropertyIcon_03;	break;
		case 4 : tempTextureHandle =  MySellingItemPropertyIcon_04;	break;
	}

	return tempTextureHandle;
}


/** 속성 텍스트박스 핸들 */
function TextBoxHandle getAttributeTextBoxHandle(int num)
{
	local TextBoxHandle tempTextBoxHandle;

	switch(num)
	{
		case 1 : tempTextBoxHandle =  MySellingItemPropertyValue_01; break;
		case 2 : tempTextBoxHandle =  MySellingItemPropertyValue_02; break;
		case 3 : tempTextBoxHandle =  MySellingItemPropertyValue_03; break;	
		case 4 : tempTextBoxHandle =  MySellingItemPropertyValue_04; break;	
	}

	return tempTextBoxHandle;
}

/** 어떤.. 등록 기간을 선택 했는가.. 1,3,5,7 기간 콤보 박스를 선택 */
function int getComboPeriod(int index)
{
	local int returnDay;

	switch (index)
	{
		case 0 : returnDay = 1; break;
		case 1 : returnDay = 3; break;
		case 2 : returnDay = 5; break;
		case 3 : returnDay = 7; break;		
	}

	return returnDay;
}


/** 지연 시간 세팅*/
function startSearchDelay()
{
	// TIMER_ID
	Me.SetTimer(TIMER_SEARCH_ID, TIMER_SEARCH_DELAY);	
	DisableCurrentWindow(true);
	disableCurrentWindowFlag = true;
	// saveTreePath
}
function startCategoryTreeSearchDelay()
{
	// TIMER_ID
	Me.SetTimer(TIMER_CATEGORYTREE_SEARCH_ID, TIMER_SEARCH_DELAY);	
	DisableCurrentWindow(true);
	disableCurrentWindowFlag = true;
	// saveTreePath
}

// TTP #59728 - gorillazin 13.01.09.
function startReSearchDelay()
{
	Me.SetTimer(TIMER_RE_SEARCH_ID, TIMER_SEARCH_DELAY);
	DisableCurrentWindow(true);
	disableCurrentWindowFlag = true;
}
//

/** 지연 시간 처리 */
function OnTimer(int TimerID)
{
	// Debug("saveTreePath             :" @ saveTreePath);

	// 서버는 0.5초 이후에 검색을 받도록 세팅 되어 있다(GD1.0)
	if(TimerID == TIMER_CATEGORYTREE_SEARCH_ID)
	{
		Me.KillTimer( TIMER_CATEGORYTREE_SEARCH_ID );
		DisableCurrentWindow(false);				
	}

	else if(TimerID == TIMER_SEARCH_ID)
	{
		Me.KillTimer( TIMER_SEARCH_ID );
	}
	
	if (TimerID == TIMER_SEARCH_ID || TimerID == TIMER_CATEGORYTREE_SEARCH_ID)
	{
		DisableCurrentWindow(false);				
		disableCurrentWindowFlag = false;
		if (saveTreePath != "")
		{
			// if (currentTreeNodeSelected != beforeTreeNodeSelected)
			if (beforeTreeNodeCalled != saveTreePath)
			{
				clickTreeState(saveTreePath);
			}

			saveTreePath = "";
		}
	}

	// TTP #59728 - gorillazin 13.01.09.
	if (TimerID == TIMER_RE_SEARCH_ID)
	{
		DisableCurrentWindow(false);
		disableCurrentWindowFlag = false;

		Me.KillTimer(TIMER_RE_SEARCH_ID);
		sellListSearch();
	}
	//
}

/** 
 * 현재 윈도우를 비활성화 한다.
 * 윈도우 최상단에 큰 윈도우를 두고 그걸로 아래 있는 요소들이 클릭등이 안되도록 한다.
 **/
function DisableCurrentWindow(bool bFlag)
{
	// disableCurrentWindowFlag = bFlag; 
	if (bFlag)
	{
		DisableWnd.EnableWindow();
		DisableWnd.ShowWindow();
	}
	else 
	{
		DisableWnd.DisableWindow();
		DisableWnd.HideWindow();
	}
}

/**
 *  아이템 공격 속성 -> 텍스쳐 경로 
 **/
function string attributeTypeToTextureString(int attType, int itemType)
{
	local string returnStr;

	if (itemType == EItemType.ITEM_WEAPON)
	{
		// 무기류
		switch(attType)
		{
			case 0  : returnStr = "l2ui_ct1.SellingAgencyWnd_df_ItemPropertyIcon_Fire";   break;
			case 1  : returnStr = "l2ui_ct1.SellingAgencyWnd_df_ItemPropertyIcon_Water";  break;
			case 2  : returnStr = "l2ui_ct1.SellingAgencyWnd_df_ItemPropertyIcon_Wind";   break;
			case 3  : returnStr = "l2ui_ct1.SellingAgencyWnd_df_ItemPropertyIcon_Earth";  break;
			case 4  : returnStr = "l2ui_ct1.SellingAgencyWnd_df_ItemPropertyIcon_Divine"; break;
			case 5  : returnStr = "l2ui_ct1.SellingAgencyWnd_df_ItemPropertyIcon_Dark";   break;
			default : returnStr = "L2UI_CT1.EmptyBtn";
		}
	}
	else 
	{
		// 방어구
		switch(attType)
		{
			case 0 :returnStr = "l2ui_ct1.SellingAgencyWnd_df_ItemPropertyIcon_Water";  break;
			case 1 :returnStr = "l2ui_ct1.SellingAgencyWnd_df_ItemPropertyIcon_Fire";   break;
			case 2 :returnStr = "l2ui_ct1.SellingAgencyWnd_df_ItemPropertyIcon_Earth";  break;
			case 3 :returnStr = "l2ui_ct1.SellingAgencyWnd_df_ItemPropertyIcon_Wind";   break;
			case 4 :returnStr = "l2ui_ct1.SellingAgencyWnd_df_ItemPropertyIcon_Dark";   break;
			case 5 :returnStr = "l2ui_ct1.SellingAgencyWnd_df_ItemPropertyIcon_Divine"; break;
			default : returnStr = "L2UI_CT1.EmptyBtn";
		}
	}


	return returnStr;
}

/** 판매 대행용 아이템 이름 리턴기 */
function string getItemNameForSellingAgency (itemInfo mItemInfo)
{
	local EEtcItemType eEtcItemType;
	local String itemNameString;

	itemNameString = "";

	eEtcItemType = EEtcItemType(mItemInfo.ItemSubType);

	if (eEtcItemType == ITEME_PET_COLLAR)
	{
		// LV50 늑대목거리 (50랩짜리 늑돌이)
		itemNameString = "Lv" $ String(mItemInfo.Enchanted) $ " " $ mItemInfo.name;
	}
	else
	{
		// 일반 아이템들
		// 인챈트 값이 있다면..

		itemNameString = GetItemNameAll(mItemInfo);
	}

	return itemNameString;
}

/**
 *  뒤쪽 space만 삭제 한다.
 * ex)  "*  고양이 "  ===> "고양이"  , "생강을 먹는 고양이가 있다.   " => 생강을 먹는 고양이가 있다."  
 **/
function string deleteRightSpeceString(string tempStr)
{
	//tempStr

	local int i;

	if ( Len(tempStr) == 0 ) return tempStr;

	i = Len(tempStr);

	while ( Mid(tempStr,i - 1, 1) == " " || Mid(tempStr,i,1) == "\t" )
	{
		--i;
		tempStr = Left(tempStr, i);
	}

	return tempStr;
}


function OnKeyUp( WindowHandle a_WindowHandle, EInputKey nKey )
{
	local string MainKey;
	
	// 키보드 누름으로 체크 	
	if (MySellingItemUnitPriceEdit.IsFocused())
	{	
		updateSellRegisterForm();
	}
	else if (SearchWord_Editbox.IsFocused())
	{	
		// 엔터로 검색어 입력 가능 하도록..
		MainKey = class'InputAPI'.static.GetKeyString(nKey);
		if(MainKey == "ENTER")
		{
			// 비활성 모드가 아닌 상황이라면 검색 실행
			//if (!DisableWnd.IsEnableWindow()) 
			if (!disableCurrentWindowFlag) 			
			{
				
				// Debug("MainKey" @ MainKey);
				OnSearchBtnClick();	
			}
		}
	}
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( "SellingAgencyWnd" ).HideWindow();
}

//판매 취소 시 수수료 계산 - 2012.08.17 수정 정우균
function string getCommisionNum(INT64 itemNum, INT64 price, int PeriodType)
{
	local INT64 _commission;
	// 등록 수수료 
	_commission = itemNum * price * getComboPeriod( PeriodType ); //MySellingItemRegistPeriodComboBox.GetSelectedNum());
	_commission = (_commission * 1) / 10000; // 0.0001 수수료 
	// 최소 수수료가 1만 아데나 보다 작다면 최소수수료로 1만 아데나를 물린다.		
	if (_commission < COMMISSION_MIN_PRICE)
	{				
		// 1000아덴 수수료 적용 
		_commission = COMMISSION_REGISTER_MIN_PRICE;
	} 
	return String(_commission);
}
defaultproperties
{
}
