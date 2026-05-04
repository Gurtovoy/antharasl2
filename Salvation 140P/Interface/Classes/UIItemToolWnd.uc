/**
 *   UITool : 아이템 검색 툴 
 *   
 *   Dongland 나 쓰려고 만든거라..알아서..쓸사람만 쓰길 -ㅅ-;;
 *   
 *   중국 버전에서 가져옴.
 *   
 **/

class UIItemToolWnd extends UICommonAPI;

var WindowHandle    Me;
var ListCtrlHandle  ItemListCtrl;
var ComboBoxHandle  ItemTypeComboBox;
var ComboBoxHandle  ItemGradeComboBox;
var ComboBoxHandle  ItemOptionComboBox;
var ComboBoxHandle  ItemOption2ComboBox;



var ButtonHandle    searchItemBtn;
var ButtonHandle    getItemBtn;

var EditBoxHandle   searchEditBox;
var EditBoxHandle   itemCountEditBox;
var EditBoxHandle   descViewEditBox;
var TextBoxHandle   ItemDescTextBox;
var ButtonHandle    InitBtn;

var L2Util          util;

var int iconPanelTotalCount;

var ItemInfo targetItemInfo;
const DELAY1_ID = 102001;
const DELAY2_ID = 102002;


var ItemID cID;
var int searchItemID, filterItemType;
var ItemInfo tmItemInfo;
	
var String fullNameString;
var string modifiedString;
var string modifiedParam;

var int ItemCrystalType;
var bool useTick;
var bool switchBool;

var array < int > SLOTBITTYPE;

function OnRegisterEvent()
{	
	registerEvent( EV_ChatMessage );
}

function onShow()
{
	// 이건 수정 해야함
	// searchEditBox.SetString(getInstanceGMWnd().m_hEditBox.GetString());

	Me.DisableTick();
	useTick = false;
	Me.SetWindowTitle("UIPowerTools [ ItemTool ]");
	//searchEditBox.EnableWindow();	
}

function OnLoad()
{
	SetClosingOnESC(); 
	// 일괄 닫기용 인데.. 한국은 아직 없음
	// getInstanceUIData().addEscCloseWindow(getCurrentWindowName(string(Self)));
	// util 초기화 
	util = L2Util(GetScript("L2Util"));

	Initialize();
}

function Initialize()
{
	local int i;

	Me                = GetWindowHandle  ( "UIItemToolWnd" );
	itemListCtrl      = GetListCtrlHandle( "UIItemToolWnd.itemListCtrl" );
	searchItemBtn     = GetButtonHandle  ( "UIItemToolWnd.searchItemBtn" );
	getItemBtn        = GetButtonHandle  ( "UIItemToolWnd.getItemBtn" );
	ItemTypeComboBox  = GetComboBoxHandle( "UIItemToolWnd.ItemTypeComboBox" );
	ItemGradeComboBox = GetComboBoxHandle( "UIItemToolWnd.ItemGradeComboBox" );

	ItemOptionComboBox = GetComboBoxHandle( "UIItemToolWnd.ItemOptionComboBox" );
	ItemOption2ComboBox = GetComboBoxHandle( "UIItemToolWnd.ItemOption2ComboBox" );

	searchEditBox     = GetEditBoxHandle ( "UIItemToolWnd.searchEditBox" );
	itemCountEditBox  = GetEditBoxHandle ( "UIItemToolWnd.itemCountEditBox" );
	descViewEditBox   = GetEditBoxHandle ( "UIItemToolWnd.descViewEditBox" );
	InitBtn           = GetButtonHandle  ( "UIItemToolWnd.InitBtn" );

	ItemDescTextBox   = GetTextBoxHandle ( "UIItemToolWnd.ItemDescTextBox" );

	// 초기화 
	ItemTypeComboBox.Clear();
	ItemTypeComboBox.AddString("ITEM_WEAPON"   );  // 0
	ItemTypeComboBox.AddString("ITEM_ARMOR"    );  // 1
	ItemTypeComboBox.AddString("ITEM_ACCESSARY");  // 2
	ItemTypeComboBox.AddString("ITEM_QUESTITEM");  // 3
	ItemTypeComboBox.AddString("ITEM_ASSET"    );  // 4
	ItemTypeComboBox.AddString("ITEM_ETCITEM"  );  // 5	
	ItemTypeComboBox.AddString("Total"         );  // 6
	//ItemTypeComboBox.AddString("WEAPON + ARMOR");  // 7 -> FindNextID()때문에 삭제

	// 포탈을 기본으로
	ItemTypeComboBox.SetSelectedNum(6);

	// 그레이드 무급 부터,  R99 까지
	ItemGradeComboBox.Clear();
	for (i = 0; i < 11; i++)
	{
		ItemGradeComboBox.AddString(util.getItemGradeSystemString(i)); 
	}

	// 11은 전체 무관
	ItemGradeComboBox.AddString("Total"); 
	ItemGradeComboBox.SetSelectedNum(11);

	itemCountEditBox.SetString("1");

	// 상해 버전에만 있는 api , 툴팁 관련
	ItemListCtrl.SetSelectedSelTooltip(false);	
	ItemListCtrl.SetAppearTooltipAtMouseX(true);
	
	inputSlotBitType (); 

	setOptionComboBoxString( ItemGradeComboBox.GetSelectedNum() );
	setOptionComboBox2String( ItemGradeComboBox.GetSelectedNum()  );

	Me.SetWindowTitle("UIPowerTools [ ItemTool ]");
}

function inputSlotBitType () 
{
	SLOTBITTYPE.Length = 28;

	SLOTBITTYPE[0] = 1;             // SBT_UNDERWEAR
	SLOTBITTYPE[1] = 2;             // SBT_REAR
	SLOTBITTYPE[2] = 4;             // SBT_LEAR
	SLOTBITTYPE[3] = 6;             // SBT_RLEAR
	SLOTBITTYPE[4] = 8;             // SBT_NECK
	SLOTBITTYPE[5] = 16;            // SBT_RFINGER
	SLOTBITTYPE[6] = 32;            // SBT_LFINGER
	SLOTBITTYPE[7] = 48;            // SBT_RLFINGER
	SLOTBITTYPE[8] = 64;            // SBT_HEAD
	SLOTBITTYPE[9] = 128;           // SBT_RHAND
	SLOTBITTYPE[10] = 256;          // SBT_LHAND
	SLOTBITTYPE[11] = 512;          // SBT_GLOVES
	SLOTBITTYPE[12] = 1024;         // SBT_CHEST
	SLOTBITTYPE[13] = 2048;         // SBT_LEGS
	SLOTBITTYPE[14] = 4096;         // SBT_FEET
	SLOTBITTYPE[15] = 8192;         // SBT_BACK
	SLOTBITTYPE[16] = 16384;        // SBT_RLHAND
	SLOTBITTYPE[17] = 32768;        // SBT_ONEPIECE
	SLOTBITTYPE[18] = 65536;        // SBT_HAIR
	SLOTBITTYPE[19] = 131072;       // SBT_ALLDRESS
	SLOTBITTYPE[20] = 262144;       // SBT_HAIR2
	SLOTBITTYPE[21] = 524288;       // SBT_HAIRALL
	SLOTBITTYPE[22] = 1048576;      // SBT_RBracelet
	SLOTBITTYPE[23] = 2097152;      // SBT_LBracelet
	SLOTBITTYPE[24] = 4194304;      // SBT_Deco1;	
	SLOTBITTYPE[25] = 268435456;    // 망토?
	SLOTBITTYPE[26] = 536870912;    // Brooch 아이템의 경우
	SLOTBITTYPE[27] = 1073741824;   // Brooch_Jewel1;	
}

/*
function OnEvent(int Event_ID, String param)
{
	

	switch( Event_ID )
	{
		case EV_ChatMessage:
			 
			 break;
	}
}

function handleChatMessage ( string param ) 
{
	local int nType, nSysMsgIndex;
	
	if (!Me.IsShowWindow()) return;

	ParseInt(param, "Type", nType);
	ParseInt(param, "SysMsgIndex", nSysMsgIndex);
		 // debug (param);

		 if (nSysMsgIndex == 378 && nType == 5)
		 {				
			// 54가 아이템을 정상적으로 받으면 나오는..
			if (InStr(param, targetItemInfo.name) > 0 && nSysMsgIndex == 54)
			{
				Debug("착용");					
				Me.KillTimer(DELAY1_ID);
				Me.SetTimer(DELAY1_ID, 100);
			}
		 }
}
*/

function OnClickButton( string Name )
{
	switch( Name )
	{
		case "searchItemBtn":
			 OnsearchItemBtnClick();
			 break;

	    case "getItemBtn" :
			 OnGetItemBtnClick();
			 break;

		case "InitBtn":
			 Initialize();
			 OnInitBtnClick();
			 break;
	}
}



function debugItem( int64 cID )
{
	//local string param;
	local iteminfo tmItemInfo;
	local ItemID citemID;

	citemID.classID = int( cID );

	if (class'UIDATA_ITEM'.static.GetItemInfo( citemID, tmItemInfo))
	{
		//ItemInfoToParam ( tmItemInfo, param );
		Debug ( "debugItem" @ tmItemInfo.slotBitType @ tmItemInfo.ArmorType @ tmItemInfo.BodyPart );
	}
}

function OnGetItemBtnClick()
{
	local LVDataRecord Record;

	local int nItemCount;
	
	nItemCount = 1;
	
	if ( int(itemCountEditBox.GetString())  > 1) nItemCount = int(itemCountEditBox.GetString());

	ItemListCtrl.GetSelectedRec(Record);

	debugItem( record.nReserved1 );

	ProcessChatMessage("//summon" @ String(record.nReserved1) $ " "$string(nItemCount), 0);
}

function OnsearchItemBtnClick()
{	
	FindAllItem(searchEditBox.GetString());
}

function OnClickListCtrlRecord( string ListCtrlID)
{
	local LVDataRecord Record;
	local ItemID citemID;
	local ItemInfo itemInfo;

	if (ListCtrlID == "itemListCtrl") 
	{
		ItemListCtrl.GetSelectedRec(Record);
		citemID.classID = int(record.nReserved1);

		if (class'UIDATA_ITEM'.static.GetItemInfo(citemID, itemInfo))
		{
			descViewEditBox.SetString(itemInfo.Description $ "\n");
			descViewEditBox.SetEditable(false);

			// RequestUseItem(citemID);
			
			// 미리보기, 상해버전에만 있음
			//if (GetWindowHandle("UITestMyObjectViewportWnd").IsShowWindow())
			//{
			//	UITestMyObjectViewportWnd(GetScript("UITestMyObjectViewportWnd")).UpdateEquipForShop(itemInfo);
			//}
		}
	}	
}

function OnDBClickListCtrlRecord( string ListCtrlID)
{
	if (ListCtrlID == "itemListCtrl") OnGetItemBtnClick();
}


function OnInitBtnClick()
{
	FindAllItem("Init");
}

/** 검색 */
function FindAllItem( String a_Param )
{	
	ItemListCtrl.DeleteAllItem();
	
	if (a_Param == "Init") return;

	//trim(a_Param) == ""
	// 만약 아이템 번호로 검색한 경우..
	searchItemID = int(a_Param);
	if (int(a_Param) > 0)
	{
		cID.ClassID = searchItemID;

		if (class'UIDATA_ITEM'.static.GetItemInfo(cID, tmItemInfo))
		{
			addItem(tmItemInfo);
			return;
		}
	}

	searchItemID = 0;

	modifiedParam=Substitute(a_Param, " ", "", FALSE);

	cID = class'UIDATA_ITEM'.static.GetFirstID();
	//searchEditBox.DisableWindow();

	searchItemID = 0;
	useTick = true;

	// 틱 시작
	Me.EnableTick();
}

function bool compareSubType ( itemInfo info ) 
{	
	//local string tmpSlotTypeString , selectedString;
	local bool isTotal, isTotal2, condition, condition2;
	local int reserved, reserved2;	
	isTotal = ItemOptionComboBox.GetSelectedNum() == ItemOptionComboBox.GetNumOfItems() - 1 ;
	isTotal2 = ItemOption2ComboBox.GetSelectedNum() == ItemOption2ComboBox.GetNumOfItems() - 1 ;
	reserved = ItemOptionComboBox.GetReserved(ItemOptionComboBox.GetSelectedNum());
	reserved2 = ItemOption2ComboBox.GetReserved(ItemOption2ComboBox.GetSelectedNum());
	//SLOTBITTYPE
	//tmpSlotTypeString = GetSlotTypeString( info.itemType, info.SlotBitType, info.WeaponType );
	//selectedString = ItemOptionComboBox.GetString( ItemOptionComboBox.GetSelectedNum());        
	switch ( info.itemType ) 
	{
		case EItemType.ITEM_WEAPON:	
			condition = reserved == info.WeaponType;			
			condition2 = ItemOption2ComboBox.GetString(ItemOption2ComboBox.GetSelectedNum()) == GetSlotTypeString( info.itemType, info.SlotBitType, info.WeaponType );
		break;
		case EItemType.ITEM_ARMOR:
			//Debug ( "compareSubType" @ ItemOptionComboBox.GetString(ItemOptionComboBox.GetSelectedNum()) ==  GetSlotTypeString( info.itemType, info.SlotBitType, info.ArmorType ) ) ;
			//Debug ( "compareSubType" @ ItemOptionComboBox.GetSelectedNum() @ info.ArmorType );
			
			condition = ItemOptionComboBox.GetString(ItemOptionComboBox.GetSelectedNum()) == GetSlotTypeString( info.itemType, info.SlotBitType, info.ArmorType );			
			condition2 = reserved2 == info.ArmorType;
		break;
		case EItemType.ITEM_ACCESSARY:				
			condition = reserved == info.SlotBitType;
			condition2 = true;			
		break;
		case EItemType.ITEM_ETCITEM:	
			condition = reserved == EEtcItemType(info.ItemSubType);
			condition2 = true;	
		break;
		//case EItemType.ITEM_QUESTITEM:
		//case EItemType.ITEM_ASSET:
		default:	
			return true;
		break;
	}	
	return  (( isTotal || condition ) && ( isTotal2 || condition2 ));	
}

// 모든 무기 스트링을 받음
function setWeaponOptionComboBox ( ComboBoxHandle comboBox ) 
{
	local int i;
	local string comboBoxString ;
	for ( i = 0 ; i < 100 ; i ++ )
	{
		comboBoxString = GetWeaponTypeString( i ) ;				
		chkNAddString( comboBoxString, comboBox , i );	
	}
}

// 모든 방어구 종류 이름을 받음
function setArmorOptionComboBox ( ComboBoxHandle comboBox ) 
{
	setSlotTypeStringByItemType ( EItemType.ITEM_ARMOR, comboBox );		
}

// 모든 액세서리 종류 이름을 받음
function setAccessaryComboBox ( ComboBoxHandle comboBox ) 
{
	setSlotTypeStringByItemType ( EItemType.ITEM_ACCESSARY, comboBox );	
}

// 아이템 타입에 따라 정해준 comboBox에 스트링을 채워 넣음
function setSlotTypeStringByItemType( int itemType,  ComboBoxHandle comboBox  ) 
{
	local int i, k;
	local string comboBoxString ;
	for ( i = 0 ; i < 100 ; i ++ )
		for ( k = 0 ; k < SLOTBITTYPE.Length ; k ++ )			
		{			
			comboBoxString = GetSlotTypeString( itemType, SLOTBITTYPE[k], i );
			chkNAddString( comboBoxString, comboBox , SLOTBITTYPE[k] );			
		}
}

// etc 아이템 옵션 항목 UIEventManager 에 있는 EEtcItemType 구조체
function setEtcitemComboBox (  ComboBoxHandle comboBox ) 
{
	local int i;	
	chkNAddString( "NONE", comboBox , i ++ );	
	chkNAddString( "SCROLL", comboBox , i ++ );	
	chkNAddString( "ARROW", comboBox , i ++ );	
	chkNAddString( "POTION", comboBox , i ++ );	
	chkNAddString( "SPELLBOOK", comboBox , i ++ );	
	chkNAddString( "RECIPE", comboBox , i ++ );	
	chkNAddString( "MATERIAL", comboBox , i ++ );	
	chkNAddString( "PET_COLLAR", comboBox , i ++ );	
	chkNAddString( "CASTLE_GUARD", comboBox , i ++ );	
	chkNAddString( "DYE", comboBox , i ++ );	
	chkNAddString( "SEED", comboBox , i ++ );	
	chkNAddString( "SEED2", comboBox , i ++ );	
	chkNAddString( "HARVEST", comboBox , i ++ );	
	chkNAddString( "LOTTO", comboBox , i ++ );	
	chkNAddString( "RACE_TICKET", comboBox , i ++ );	
	chkNAddString( "TICKET_OF_LORD", comboBox , i ++ );	
	chkNAddString( "LURE", comboBox , i ++ );	
	chkNAddString( "CROP", comboBox , i ++ );	
	chkNAddString( "MATURECROP", comboBox , i ++ );	
	chkNAddString( "ENCHT_WP", comboBox , i ++ );	
	chkNAddString( "ENCHT_AM", comboBox , i ++ );	
	chkNAddString( "BLESS_ENCHT_WP", comboBox , i ++ );	
	chkNAddString( "BLESS_ENCHT_AM", comboBox , i ++ );	
	chkNAddString( "COUPON", comboBox , i ++ );	
	chkNAddString( "ELIXIR", comboBox , i ++ );	
	chkNAddString( "ENCHT_ATTR", comboBox , i ++ );	
	chkNAddString( "ENCHT_ATTR_CURSED", comboBox , i ++ );	
	chkNAddString( "BOLT", comboBox , i ++ );	
	chkNAddString( "ENCHT_ATTR_INC_PROP_ENCHT_WP", comboBox , i ++ );	
	chkNAddString( "ENCHT_ATTR_INC_PROP_ENCHT_AM", comboBox , i ++ );	
	chkNAddString( "ENCHT_ATTR_CRYSTAL_ENCHANT_AM", comboBox , i ++ );	
	chkNAddString( "ENCHT_ATTR_CRYSTAL_ENCHANT_WP", comboBox , i ++ );	
	chkNAddString( "ENCHT_ATTR_ANCIENT_CRYSTAL_ENCHANT_AM", comboBox , i ++ );	
	chkNAddString( "ENCHT_ATTR_ANCIENT_CRYSTAL_ENCHANT_WP", comboBox , i ++ );	
	chkNAddString( "ENCHT_ATTR_RUNE", comboBox , i ++ );	
	chkNAddString( "ENCHT_ATTRT_RUNE_SELECT", comboBox , i ++ );	
	chkNAddString( "TELEPORTBOOKMARK", comboBox , i ++ );	
	chkNAddString( "CHANGE_ATTR", comboBox , i ++ );	
	chkNAddString( "SOULSHOT", comboBox , i ++ );	
	chkNAddString( "SHAPE_SHIFTING_WP", comboBox , i ++ );	
	chkNAddString( "BLESS_SHAPE_SHIFTING_WP", comboBox , i ++ );	
	chkNAddString( "SHAPE_SHIFTING_WP_FIXED", comboBox , i ++ );	
	chkNAddString( "SHAPE_SHIFTING_AM", comboBox , i ++ );	
	chkNAddString( "BLESS_SHAPE_SHIFTING_AM", comboBox , i ++ );	
	chkNAddString( "SHAPE_SHIFTING_AM_FIXED", comboBox , i ++ );	
	chkNAddString( "SHAPE_SHIFTING_HAIRACC", comboBox , i ++ );	
	chkNAddString( "BLESS_SHAPE_SHIFTING_HAIRACC", comboBox , i ++ );	
	chkNAddString( "SHAPE_SHIFTING_HAIRACC_FIXED", comboBox , i ++ );	
	chkNAddString( "RESTORE_SHAPE_SHIFTING_WP", comboBox , i ++ );	
	chkNAddString( "RESTORE_SHAPE_SHIFTING_AM", comboBox , i ++ );	
	chkNAddString( "RESTORE_SHAPE_SHIFTING_HAIRACC", comboBox , i ++ );	
	chkNAddString( "RESTORE_SHAPE_SHIFTING_ALLITEM", comboBox , i ++ );	
	chkNAddString( "BLESS_INC_PROP_ENCHT_WP", comboBox , i ++ );	
	chkNAddString( "BLESS_INC_PROP_ENCHT_AM", comboBox , i ++ );	
	chkNAddString( "CARD_EVENT", comboBox , i ++ );	
	chkNAddString( "SHAPE_SHIFTING_ALLITEM_FIXED", comboBox , i ++ );	
	chkNAddString( "MULTI_ENCHT_WP", comboBox , i ++ );	
	chkNAddString( "MULTI_ENCHT_AM", comboBox , i ++ );	
	chkNAddString( "MULTI_INC_PROB_ENCHT_WP", comboBox , i ++ );	
	chkNAddString( "MULTI_INC_PROB_ENCHT_AM", comboBox , i ++ );	
	chkNAddString( "ENSOUL_STONE", comboBox , i ++ );	
}


function setOptionComboBoxString (int selectedID )
{	
	ItemOptionComboBox.Clear();	
	switch ( selectedID ) 
	{
		case EItemType.ITEM_WEAPON:
			setWeaponOptionComboBox( ItemOptionComboBox );			
		break;
		case EItemType.ITEM_ARMOR:
			setArmorOptionComboBox(ItemOptionComboBox );			
		break;
		case EItemType.ITEM_ACCESSARY:
			setAccessaryComboBox( ItemOptionComboBox );			
			//comboBoxString = GetWeaponTypeString( Item.WeaponType );
		break;
		case EItemType.ITEM_QUESTITEM:					
		break;
		case EItemType.ITEM_ASSET:			
		break;			
		case EItemType.ITEM_ETCITEM:		
			setEtcitemComboBox( ItemOptionComboBox);
		break;
		default:			
		break;
		
	}
	
	ItemOptionComboBox.AddString ( "Total");
	ItemOptionComboBox.SetSelectedNum( ItemOptionComboBox.GetNumOfItems () - 1 );
}

// 모든 무기 장착 이름을 받음( 한손 양손 ) 
function setWeaponOption2ComboBox ( ComboBoxHandle comboBox ) 
{
	setSlotTypeStringByItemType ( EItemType.ITEM_WEAPON , comboBox ); 	
}

function setArmorOption2ComboBox ( ComboBoxHandle comboBox )
{
	comboBox.AddStringWithReserved (GetSystemString(441), 0);
	comboBox.AddStringWithReserved (GetSystemString(245), 1);
	comboBox.AddStringWithReserved (GetSystemString(246), 2);
	comboBox.AddStringWithReserved (GetSystemString(244), 3);
	comboBox.AddStringWithReserved (GetSystemString(1987), 4);	
}


function setOptionComboBox2String ( int selectedID ) 
{
	ItemOption2ComboBox.Clear();	
	switch ( selectedID ) 
	{
		case EItemType.ITEM_WEAPON:
			setWeaponOption2ComboBox( ItemOption2ComboBox);						
		break;
		case EItemType.ITEM_ARMOR:					
			setArmorOption2ComboBox( ItemOption2ComboBox );												
		break;
		case EItemType.ITEM_ACCESSARY:
		case EItemType.ITEM_QUESTITEM:
		case EItemType.ITEM_ASSET:
		case EItemType.ITEM_ETCITEM:							
		break;
		default:
		break;
	}

	ItemOption2ComboBox.AddString ( "Total");
	ItemOption2ComboBox.SetSelectedNum( ItemOption2ComboBox.GetNumOfItems () - 1 );	
}

function chkNAddString ( string tmpString, ComboBoxHandle tmpCombox, int reversed  ) 
{
	local int i ;	
	if ( tmpString == "" ) return;
	for ( i = 0 ; i < tmpCombox.GetNumOfItems() ; i ++ )
	{
		if ( tmpCombox.GetString( i ) == tmpString ) return;
	}
	tmpCombox.AddStringWithReserved( tmpString, reversed );
}

// 틱당 검색
function tickProcess()
{
	local int itemType;
	local int crystalType;
	if (!IsValidItemID(cID))
	{
		// Debug("Tick 정지");
		Me.DisableTick();
		// searchEditBox.EnableWindow();
		useTick = false;
		Me.SetWindowTitle("UIPowerTools [ ItemTool ]");
		return;
	}

	itemType = ItemTypeComboBox.GetSelectedNum();
	if (itemType == 6) // 전체
		itemType = -1;
	// 7 인 무기, 방어구는 삭제

	crystalType = ItemGradeComboBox.GetSelectedNum();
	if (crystalType == 11)	// 등급 무관
		crystalType = -1;

	// 이름, ItemType, CrystalType으로 검색 함. type을 -1로 설정하면 전체
	cID = class'UIDATA_ITEM'.static.FindNextID(modifiedParam, itemType, crystalType);
	if(cID.ClassID >= 0)
	{
		class'UIDATA_ITEM'.static.GetItemInfo(cID, tmItemInfo);
		if ( compareSubType ( tmItemInfo ) )
			addItem(tmItemInfo);
		searchItemID++;
	}
	/* FindNextID()로 대체
	fullNameString  = class'UIDATA_ITEM'.static.GetItemName( cID );
	modifiedString = Substitute(fullNameString, " ", "", FALSE);

	if ( InStr( modifiedString  , modifiedParam ) != -1 )
	{
		// 클래스 타입
		// 등급
		ItemCrystalType = class'UIDATA_ITEM'.static.GetItemCrystalType(cID);

		// debug("GetItemCrystalType --> " @ class'UIDATA_ITEM'.static.GetItemCrystalType(cID));

		// 11은 등급 무관 

		if (ItemGradeComboBox.GetSelectedNum() == ItemCrystalType || ItemGradeComboBox.GetSelectedNum() == 11)
		{
			/// ItemType
			class'UIDATA_ITEM'.static.GetItemInfo(cID, tmItemInfo);

			filterItemType = ItemTypeComboBox.GetSelectedNum();

			// 각 타입
			if (filterItemType == tmItemInfo.itemType)
			{
				//Debug ( "tickProcess" @  compareSubType ( tmItemInfo )  ) ;
				if ( compareSubType ( tmItemInfo ) ) addItem(tmItemInfo);
			}
			// 무기, 방어구 
			else if (filterItemType == 7)
			{
				if (tmItemInfo.itemType == 0 || tmItemInfo.itemType == 1) if ( compareSubType ( tmItemInfo) ) addItem( tmItemInfo );
			}
			// 전체
			else if (filterItemType == 6)
			{
				if ( compareSubType ( tmItemInfo ) ) addItem( tmItemInfo );
			}
		}
		
		searchItemID++;
	}
	*/
}

function OnComboBoxItemSelected(string StrID, int IndexID)
{
	switch ( StrID ) 
	{
	case "ItemTypeComboBox":
		setOptionComboBoxString( IndexID );
		setOptionComboBox2String( IndexID );
		if ( ItemOptionComboBox.GetNumOfItems() > 1 ) 
			ItemOptionComboBox.ShowWindow();
		else 
			ItemOptionComboBox.HideWindow();

		if (ItemOption2ComboBox.GetNumOfItems() > 1 )  
		{
			ItemOptionComboBox.SetWindowSize( 107, 19 );
			ItemOption2ComboBox.ShowWindow();
		}
		else 
		{
			ItemOptionComboBox.SetWindowSize ( 180, 19) ;
			ItemOption2ComboBox.HideWindow();		
		}
		break;	
	}
}

function onTick()
{
	local int i;

	if (switchBool == false) { Me.SetWindowTitle("UIPowerTools [ ItemTool ]  - Searching.. "); switchBool = true; }
	else {Me.SetWindowTitle("UIPowerTools [ ItemTool ]  + Searching.... "); switchBool = false; }

	// tick당 10개
	for(i = 0; i < 300; i++)
	{
		if (!useTick) break;
		tickProcess();
	}
}

/** 아이템을 추가 한다. */
function addItem(itemInfo info)
{
	local LVDataRecord Record;
	local string param, additionalName, fullNameString;
	local int itemNameClass;

	// ParamToItemInfo(param, info);
	// ParamAdd(param, "ClassID", string(info.ID.ClassID));
	
	fullNameString = info.Name;

	itemNameClass  = class'UIDATA_ITEM'.static.GetItemNameClass( info.ID );			
	additionalName = class'UIDATA_ITEM'.static.GetItemAdditionalName( info.ID );

	if (itemNameClass == 0)		 //보급형 아이템 
	{
		fullNameString = MakeFullSystemMsg(GetSystemMessage(2332), fullNameString);
	}
	else if (itemNameClass == 2) //희귀한 아이템
	{
		fullNameString = MakeFullSystemMsg(GetSystemMessage(2331), fullNameString);
	}
	if (Len(additionalName) > 0 )
	{
		fullNameString = fullNameString $ "(" $ additionalName $ ")";
	}
	
	// 해당 아이템 정보 리스트에 넣을때꺼내올수 있도록 기억  <- 중국쪽에서 만든 api
	class'UIDATA_ITEM'.static.GetItemInfoString(info.Id.ClassID, param);  

	Record.szReserved = param;

	Record.nReserved1 = Int64(info.Id.ClassID);
	Record.LVDataList.length = 5;
	// 아이템 

	Record.LVDataList[0].szData = fullNameString;

	Record.LVDataList[0].hasIcon = true;
	Record.LVDataList[0].nTextureWidth=32;
	Record.LVDataList[0].nTextureHeight=32;
	Record.LVDataList[0].nTextureU=32;
	Record.LVDataList[0].nTextureV=32;
	Record.LVDataList[0].szTexture = info.IconName; 
	Record.LVDataList[0].IconPosX=10;
	Record.LVDataList[0].FirstLineOffsetX=6;

	// Record.LVDataList[0].HiddenStringForSorting = itemName $ util.makeZeroString(3, enchanted);
	
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

	if (info.iconPanel != "") iconPanelTotalCount++;

	// 아이콘 테두리 (기본 병기.pvp 무기등)
	Record.LVDataList[0].iconPanelName = info.iconPanel;
	Record.LVDataList[0].panelOffsetXFromIconPosX=0;
	Record.LVDataList[0].panelOffsetYFromIconPosY=0;
	Record.LVDataList[0].panelWidth=32;
	Record.LVDataList[0].panelHeight=32;
	Record.LVDataList[0].panelUL=32;
	Record.LVDataList[0].panelVL=32;

	// 무기, 방어구, 악세사리 만 등급을 표기해준다.(혼돈의 악마의 단검 이런건.. ITEM_ETCITEM 으로 나와서.. )
	if (info.itemType == EItemType.ITEM_WEAPON || info.itemType == EItemType.ITEM_ACCESSARY || info.itemType == EItemType.ITEM_ARMOR) // || itemType == EItemType.ITEM_ETCITEM)
	{
		// 장비 등급
		Record.LVDataList[1].szData = util.getItemGradeSystemString(info.crystalType); 
	}
	else
	{
		// 무급이 아닌 경우 등급을 출력 한다.
		if (info.crystalType != 0) Record.LVDataList[1].szData = util.getItemGradeSystemString(info.crystalType);
		else Record.LVDataList[1].szData = "-";		
	}

	Record.LVDataList[1].HiddenStringForSorting = util.makeZeroString(6, info.crystalType);
	Record.LVDataList[1].textAlignment=TA_Left;

	switch ( info.itemType ) 
	{
		case EItemType.ITEM_WEAPON:				
			itemListCtrl.SetColumnString(2, 55);
			itemListCtrl.SetColumnString(3, 98);		
			Record.LVDataList[2].szData = string( GetPhysicalDamage(info.WeaponType, info.SlotBitType, info.CrystalType, info.Enchanted, info.pAttack, info.Attribution));
			Record.LVDataList[3].szData = string( GetMagicalDamage(info.WeaponType, info.SlotBitType, info.CrystalType, info.Enchanted, info.mAttack, info.Attribution));
		break;
		case EItemType.ITEM_ARMOR:
			itemListCtrl.SetColumnString(2, 54);
			itemListCtrl.SetColumnString(3, 99);	
			Record.LVDataList[2].szData = String(int (info.pDefense + info.ShieldDefense));
			Record.LVDataList[3].szData = String(int (info.mDefense));			
		break;
		case EItemType.ITEM_ACCESSARY:				
			itemListCtrl.SetColumnString(2, 54);
			itemListCtrl.SetColumnString(3, 99);	
			Record.LVDataList[2].szData = String(int (info.pDefense + info.ShieldDefense));
			Record.LVDataList[3].szData = String(int (info.mDefense));			
		break;
			case EItemType.ITEM_ETCITEM:			
			Record.LVDataList[2].szData = String(0);
			Record.LVDataList[3].szData = String(0);
		break;		
	}
	
	Record.LVDataList[2].textAlignment=TA_Right;	
	Record.LVDataList[3].textAlignment=TA_Right;

	Record.LVDataList[4].szData = String(info.Id.ClassID);
	Record.LVDataList[4].textAlignment=TA_Left;

	// 수량 

	// Debug("consumeType----------> " @ consumeType);
	// 수량성 아이템
	// if (IsStackableItem( info.consumeType ) )
	
	
	// 설명
	//Record.LVDataList[3].szData = 
	//Record.LVDataList[3].textAlignment=TA_Right;
	
	ItemListCtrl.InsertRecord( Record );	
}



/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( "UIItemToolWnd" ).HideWindow();
}


//function getItemAndUse()
//{
//	local LVDataRecord Record;
//	local ItemID citemID;
//	local ItemInfo itemInfo;

//	ItemListCtrl.GetSelectedRec(Record);
//	citemID.classID = int(record.nReserved1);

//	// 초기화.
//	targetItemInfo = itemInfo;

//	if (class'UIDATA_ITEM'.static.GetItemInfo(citemID, itemInfo))
//	{
//		descViewEditBox.SetString(itemInfo.Description $ "\n");
//		descViewEditBox.SetEditable(false);

//		targetItemInfo = itemInfo;

//		ProcessChatMessage("//destroy_all_inven_item", 0);
//		ProcessChatMessage("//summon" @ String(citemID.classID) $ " "$string(1), 0);
		
//		// RequestUseItem(citemID);
//		Me.KillTimer(DELAY1_ID);
//		Me.SetTimer(DELAY1_ID, 100);

//	}
//}

//function OnTimer(int timeID)
//{
//	local int itemIndex;
//	if (DELAY1_ID == timeID)
//	{
//		itemIndex = getInstanceInventoryWnd().useItemOutSide(targetItemInfo);
//		if (itemIndex >= 0) Me.KillTimer(DELAY1_ID);		
//	}
//}

/** OnKeyUp */
function OnKeyUp( WindowHandle a_WindowHandle, EInputKey nKey )
{
	// local string MainKey;

	// 키보드 누름으로 체크 	
	if (searchEditBox.IsFocused())
	{	
		// txtPath
		if (nKey == IK_Enter) 
		{
			// 키보드 입력은 아무것도 입력 하지 않았을때 전체 검색을 허용하지 않는다.
			// 실수로 자꾸 누르는 경우가 있어서..
			if (trim(searchEditBox.GetString()) != "") OnsearchItemBtnClick();
		}
	}
		
	//MainKey = class'InputAPI'.static.GetKeyString(nKey);

	//// 미리 입히기 
	//if (MainKey == "SLASH" && Me.IsShowWindow() && !IsFinalRelease())
	//{		
	//	if (itemListCtrl.GetSelectedIndex()  < itemListCtrl.GetRecordCount())
	//	{
	//		itemListCtrl.SetSelectedIndex(itemListCtrl.GetSelectedIndex() + 1, true);
	//		OnClickListCtrlRecord("itemListCtrl");
			
	//		getItemAndUse();
	//	}
	//}
}
	
	
defaultproperties
{
}
