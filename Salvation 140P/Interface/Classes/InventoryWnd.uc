class InventoryWnd extends UICommonAPI;

const DIALOG_USE_RECIPE				= 1111;				// ?    
const DIALOG_POPUP					= 2222;				// ?   ??  
const DIALOG_DROPITEM				= 3333;				//  ??  (?)
const DIALOG_DROPITEM_ASKCOUNT		= 4444;				//  ??  (,  ?)
const DIALOG_DROPITEM_ALL			= 5555;				//  ??  (MoveAll  )
const DIALOG_DESTROYITEM			= 6666;				//  ?  (?)
const DIALOG_DESTROYITEM_ALL		= 7777;				//  ?  (MoveAll  )
const DIALOG_DESTROYITEM_ASKCOUNT	= 8888;				//  ?  (,  ?)
const DIALOG_CRYSTALLIZE			= 9999;				//  ? ?
const DIALOG_NOTCRYSTALLIZE		= 9998;				// ? ??? 
const DIALOG_DROPITEM_PETASKCOUNT	= 10000;			// ?  ?? 

const TIMER_REQUEST_ITEMLIST        = 1718;
const TIMER_REQUEST_ITEMLIST_DELAY  = 5000;

const EQUIPITEM_Underwear = 0; 
const EQUIPITEM_Head = 1;
const EQUIPITEM_Hair = 2;
const EQUIPITEM_Hair2 = 3;
const EQUIPITEM_Neck = 4;
const EQUIPITEM_RHand = 5;
const EQUIPITEM_Chest = 6;
const EQUIPITEM_LHand = 7;
const EQUIPITEM_REar = 8;
const EQUIPITEM_LEar = 9;
const EQUIPITEM_Gloves = 10;
const EQUIPITEM_Legs = 11;
const EQUIPITEM_Feet = 12;
const EQUIPITEM_RFinger = 13;
const EQUIPITEM_LFinger = 14;
const EQUIPITEM_LBracelet = 15;
const EQUIPITEM_RBracelet = 16;
const EQUIPITEM_Deco1 = 17;
const EQUIPITEM_Deco2 = 18;
const EQUIPITEM_Deco3 = 19;
const EQUIPITEM_Deco4 = 20;
const EQUIPITEM_Deco5 = 21;
const EQUIPITEM_Deco6 = 22;
const EQUIPITEM_Cloak = 23;
const EQUIPITEM_Waist = 24;

const EQUIPITEM_Brooch = 25;

const EQUIPITEM_Jewel1 = 26;
const EQUIPITEM_Jewel2 = 27;
const EQUIPITEM_Jewel3 = 28;
const EQUIPITEM_Jewel4 = 29;
const EQUIPITEM_Jewel5 = 30;
const EQUIPITEM_Jewel6 = 31;

// ?
const EQUIPITEM_AGATHION_MAIN = 32;
const EQUIPITEM_AGATHION_SUB1 = 33;
const EQUIPITEM_AGATHION_SUB2 = 34;
const EQUIPITEM_AGATHION_SUB3 = 35;
const EQUIPITEM_AGATHION_SUB4 = 36;


const EQUIPITEM_Max = 37;

const INVENTORY_ITEM_TAB = 0;
const INVENTORY_ITEM_1_TAB = 1;
const INVENTORY_ITEM_2_TAB = 2;
const INVENTORY_ITEM_3_TAB = 3;
const INVENTORY_ITEM_4_TAB = 4;
const QUEST_ITEM_TAB = 5;

const ICON_WIDTH = 36;

const INVENTORYWND_MIN_WIDTH = 556;
const ITEMWINDOW_MIN_WIDTH = 339;
const TAB_BG_MIN_WIDTH = 350;
const TAB_BG_LING_MIN_WIDTH = 10;

const  TAB_LENGTH = 4;

var WindowHandle		m_hInventoryWnd;
var	String				m_WindowName;
var	ItemWindowHandle	m_invenItem;
var	ItemWindowHandle	m_questItem;
var	ItemWindowHandle	m_equipItem[ EQUIPITEM_Max ];
var	ItemWindowHandle	m_hHennaItemWindow;
var	ItemWindowHandle	m_hPremiumHennaItemWindow; //branch121212
var	TextBoxHandle		m_hAdenaTextBox;
var	TabHandle			m_invenTab;
var	ButtonHandle		m_sortBtn;
var	ButtonHandle 		m_BtnRotateLeft;
var	ButtonHandle		m_BtnRotateRight;

//var TextureHandle		m_CloakSlot_Disable;
var TextureHandle		m_Talisman_Disable[ 6 ];

//  ?? ? 
var TextureHandle		m_Jewel_Disable[ 6 ];

var	ItemWindowHandle	m_invenItem_1;
var	ItemWindowHandle	m_invenItem_2;
var	ItemWindowHandle	m_invenItem_3;
var	ItemWindowHandle	m_invenItem_4;

var	ItemWindowHandle	m_equipItem_Brooch;
var TextureHandle       m_BroochEquiped;


// ??2??
var ButtonHandle m_BtnWindowExpand;

// 6, 12???
var TextureHandle m_InventoryItembg;
var TextureHandle m_InventoryItembg_expand;

var TextureHandle m_tabbg;
var TextureHandle m_tabbgLine;

var TextBoxHandle m_itemCount;


// ??
var int currentInvenCol;

// ??   
var int pInventoryItemCount;

var 	CharacterViewportWindowHandle	m_ObjectViewport;

var	array<ItemID>		m_itemOrder;				// ??    ?.
var	Vector				m_clickLocation;			//  ?    ? ?.

var Array<ItemInfo>		m_EarItemList;
var Array<ItemInfo>		m_FingerItemLIst;
var Array<ItemInfo>		m_DecoItemList;

var int m_NormalInvenCount;	// Added by JoeyPark 2010/09/10   ? ? .
var int m_QuestInvenCount;	// Added by JoeyPark 2010/09/10   ? ? .
var bool m_bCurrentState;
var int m_MaxInvenCount;
var int m_MaxQuestItemInvenCount;
//var int m_ExtraInvenCount;
var int m_MeshType;
var int m_NpcID;

var ButtonHandle		m_hBtnCrystallize;

var WindowHandle ColorNickNameWnd;

var int m_selectedItemTab;

var string lastHandleAddItemParam;

var ButtonHandle        AdenacalculateButton;

// ?  ?
var ButtonHandle        EnchantJewelButton;
//  ?
var ButtonHandle        JewelButton;

//?   ?
var ButtonHandle        AlchemyOpenerBtn;

var bool m_bFirstOpen;

//?
var ButtonHandle        ViewHairButton;
//?
var ButtonHandle        ViewAccessoryButton;


// 
var WindowHandle		JewelWindow;

//? 
var WindowHandle		AlchemyOpenerWindow;

var ButtonHandle        AlchemyMixCubeWndBtn;
var ButtonHandle        AlchemyItemConversionWndBtn;
var ButtonHandle        AlchemyItemCreateWndBtn;

//?   ??  ? 
var string              cur_state;

var int mainClass ;

var bool bIsPremiumHennaSlot; //branch GD35_0828 2014-2-10 luciper3 - ? ?

var QuitReportWnd QuitReportWndScript;

var string m_EquipWindowName;
var WindowHandle m_EquipWindow;

/**************************************** ? ? ? **********************************************/
// ? ?
var WindowHandle        AgathionWindow;

// ?  ? ?
var ButtonHandle        AgathionBtn;

// ? ?? ?  ( main  ) 
var TextureHandle		m_Agathion_Disable[ 5 ];

var L2Util l2UtilScript;


//    clear  itemSwaped  true  tt 61481
var bool bIsSavedLocalItemIdx ;
var array<int> itemSwapedServerID;
var array<int> itemSwapedServerID_1;
var array<int> itemSwapedServerID_2;
var array<int> itemSwapedServerID_3;
var array<int> itemSwapedServerID_4;
var array<int> itemSwapedServerID_q;
var array<int> itemSwapedIdx;
var array<int> itemSwapedIdx_1;
var array<int> itemSwapedIdx_2;
var array<int> itemSwapedIdx_3;
var array<int> itemSwapedIdx_4;
var array<int> itemSwapedIdx_q;

//  ? ?? ?  , 
//   ? 
// ?  ?   .
var bool bIsQuestItemList;

// ?       .
var bool bIsRequestItemList;
var bool m_bCtrlAltDeleteEnabled;
var CheckBoxHandle m_CtrlAltDeleteCheckBox;

/*********************************************************************************************
 * On
 * *******************************************************************************************/
function OnRegisterEvent()
{
	RegisterEvent(EV_InventoryClear);
	RegisterEvent(EV_InventoryOpenWindow);
	RegisterEvent(EV_InventoryHideWindow);
	RegisterEvent(EV_InventoryAddItem);
	RegisterEvent(EV_InventoryUpdateItem);
	RegisterEvent(EV_InventoryItemListEnd);
	RegisterEvent(EV_InventoryAddHennaInfo);
	RegisterEvent(EV_InventoryAddPremiumHennaInfo);	 //branch121212
	RegisterEvent(EV_InventoryPremiumHennaInfoClear);	 //branch121212
	RegisterEvent(EV_InventoryToggleWindow);
	RegisterEvent(EV_UpdateHennaInfo);
	RegisterEvent(EV_UpdateUserInfo);
	RegisterEvent(EV_UpdateUserEquipSlotInfo);
	RegisterEvent(EV_DialogOK);
	RegisterEvent(EV_Restart);
	RegisterEvent(EV_SetMaxCount);
	RegisterEvent(EV_ChangeCharacterPawn );
	RegisterEvent(EV_HairAccessoryPriority);
	RegisterEvent( EV_StateChanged );
	RegisterEvent( EV_AlchemySkillListForXML );
	RegisterEvent( EV_ChangedSubjob );
	RegisterEvent( EV_NotifySubjob );
	RegisterEvent(EV_NeedResetUIData);	
}

function OnLoad()
{	
	l2UtilScript = L2Util(GetScript("L2Util"));

	GetWindowHandle(m_WindowName $".Equip_Live" ).HideWindow();
	GetWindowHandle(m_WindowName $".Equip_classic" ).HideWindow();

	SetClosingOnESC();

	InitHandleCOD();	
	
	// *    xml  ? ? ??.
	// onLoad  ? ?    ?  .
	setEquipWindowHandle();

	//?  ? 
	getHandles();	
	
	InitScrollBar();
	
	m_bCurrentState = false;
	m_selectedItemTab = INVENTORY_ITEM_TAB;

	currentInvenCol = GetOptionInt( "Game", "ItemInventoryCol");
	//debug("option " @ currentInvenCol);

	// ?  6~12, option.ini   : ?  ??  ??  6 
	if (currentInvenCol != 9 && currentInvenCol != 12) currentInvenCol = 9;

	m_bFirstOpen = false;
	m_bCtrlAltDeleteEnabled = GetOptionBool("Game", "EnableCtrlAltInventoryDelete");
	if (m_CtrlAltDeleteCheckBox != none)
		m_CtrlAltDeleteCheckBox.SetCheck(m_bCtrlAltDeleteEnabled);

	m_BroochEquiped.hideWindow();
	
	handlePremiumHenna ( );
	
	QuitReportWndScript = QuitReportWnd(GetScript("QuitReportWnd"));
	//end of branch
}

function OnEvent(int Event_ID, string param)
{
	local ELanguageType Language;

	//Debug ( "OnEvent " @ Event_ID ) ;	
	switch( Event_ID )
	{
		case EV_InventoryClear:         //2570
			HandleClear();
			break;
		case EV_InventoryOpenWindow:    //2580
			HandleOpenWindow(param);
			break;
		case EV_InventoryHideWindow:    //2590
			HandleHideWindow();
			break;  
		case EV_InventoryAddItem:       //2600			
			HandleAddItem(param);
			break;
		case EV_InventoryUpdateItem:    //2610		
			// ?, ?  
			if ( GetServerType() == 3 || Language != LANG_Korean ) showItemUpdateEffect( param );
			HandleUpdateItem(param);
			break;
		// ?  , ? ??
		// ?  , ? ??
		case EV_InventoryItemListEnd:   //2620		
			HandleItemListEnd();
			break;
		case EV_InventoryAddHennaInfo:  //2630
			UpdateHennaInfo();
			break;
		case EV_InventoryAddPremiumHennaInfo: //branch121212
			UpdatePremiumHennaInfo(false);
			break;
		case EV_InventoryPremiumHennaInfoClear: //branch121212
			UpdatePremiumHennaInfo(true);
			break;
		case EV_UpdateHennaInfo:        //260
			UpdateHennaInfo();		
			break;
		case EV_InventoryToggleWindow:  //2631
			HandleToggleWindow();
			break;
		case EV_DialogOK:               //1710
			HandleDialogOK();
			break;
		case EV_UpdateUserInfo:         //180
			HandleUpdateUserInfo();
			break;
		case EV_UpdateUserEquipSlotInfo:
			HandleUpdateUserEquipSlotInfo();
			break;
		case EV_Restart:                 //40  
			HandleRestart();
			//~ SaveInventoryOrder();
			break;
		case EV_SetMaxCount:            //2070
			HandleSetMaxCount(param);
			break;
		case EV_ChangeCharacterPawn:    //3810
			HandleChangeCharacterPawn(param);
			break;
		case EV_HairAccessoryPriority:
			ReceiveHairAccessoryPriority(param);
			break;
		case EV_StateChanged :	
			cur_state = param;		
			break;				
		case EV_ChangedSubjob:
			handleChangedSubjob( param );
		case EV_NotifySubjob:
			handleNotifySubjob( param );
			break;
		case EV_NeedResetUIData:			
			checkClassicForm();
			break;
		default:
			break;
	};
}

function OnShow()
{	
	m_bFirstOpen = true;

	if (IsShowWindow("PostWriteWnd"))
		HideWindow("InventoryWnd");
	else
		getInstanceL2Util().ItemRelationWindowHide
			(getCurrentWindowName(String(self)),"AttributeEnchantWnd,AttributeRemoveWnd,ItemEnchantWnd,RefineryWnd,UnrefineryWnd,CrystallizationWnd,ItemAttributeChangeWnd,ProgressBox,AlchemyMixCubeWnd");

	CheckShowCrystallizeButton();
	SetAdenaText();
	SetItemCount();

	UpdateHennaInfo();
	
	// ?  9 <-> 12 
	if (currentInvenCol == 9)
		m_InventoryItembg_expand.HideWindow();	
	else if (currentInvenCol == 12)		
		extendInventory(true);

	setAhclemyOpener();	
	m_hOwnerWnd.KillTimer( TIMER_REQUEST_ITEMLIST );
}

function OnHide()
{
	JewelWindow.HideWindow();
	JewelButton.SetTexture("L2UI_CT1.button.Button_DF_right", "L2UI_CT1.button.Button_DF_right_down", "L2UI_CT1.button.Button_DF_right_over");
	AlchemyOpenerWindow.HideWindow();
	if( m_bCurrentState ) SaveInventoryOrder();
	if(DialogIsMine()) DialogHide();	
	bIsRequestItemList = false;
}

function onTimer ( int TimerID ) 
{
	switch ( TimerID ) 
	{
		case TIMER_REQUEST_ITEMLIST:
			bIsRequestItemList = false;
		break;
	}
}

function OnLButtonDown (WindowHandle  a_WindowHandle, int X, int Y)
{	
	if (a_WindowHandle == m_BtnRotateLeft)
		m_ObjectViewport.StartRotation(false);
	else if (a_WindowHandle == m_BtnRotateRight)
		m_ObjectViewport.StartRotation(true);
}

function OnLButtonUp (WindowHandle  a_WindowHandle, int X, int Y)
{	
	if (a_WindowHandle == m_BtnRotateLeft)
		m_ObjectViewport.EndRotation();
	else if (a_WindowHandle == m_BtnRotateRight)
		m_ObjectViewport.EndRotation();
}

function OnEnterState( name a_PrevStateName )
{
	m_bCurrentState = true;
}

function OnExitState( name a_NextStateName )
{
	m_bCurrentState = false;
}

// ItemWindow Event
function OnDBClickItemWithHandle( ItemWindowHandle a_hItemWindow, int index )
{
	UseItem( a_hItemWindow, index );
}

function OnRClickItemWithHandle( ItemWindowHandle a_hItemWindow, int index )
{
	UseItem( a_hItemWindow, index );
}

function OnSelectItemWithHandle( ItemWindowHandle a_hItemWindow, int a_Index )
{
	local int i;
	local ItemInfo info;
	local string ItemName;

	//TextLink
	if( IsKeyDown( IK_Shift ) )
	{
		a_hItemWindow.GetSelectedItem( info );
		ItemName = class'UIDATA_ITEM'.static.GetRefineryItemName( info.Name, info.RefineryOp1, info.RefineryOp2 );
		SetItemTextLink( info.ID, ItemName );
	}

	if (m_bCtrlAltDeleteEnabled && IsKeyDown(IK_Ctrl) && IsKeyDown(IK_Alt))
	{
		if (a_hItemWindow == m_invenItem
			|| a_hItemWindow == m_invenItem_1
			|| a_hItemWindow == m_invenItem_2
			|| a_hItemWindow == m_invenItem_3
			|| a_hItemWindow == m_invenItem_4)
		{
			a_hItemWindow.GetSelectedItem(info);
			QuickDestroyInventoryItem(info);
			return;
		}
	}
	
	switch ( a_hItemWindow ) 
	{
		case m_invenItem :
		case m_invenItem_1 :
		case m_invenItem_2 :
		case m_invenItem_3 :
		case m_invenItem_4 :
		case m_questItem : return;			
	}	

	for( i = 0; i < EQUIPITEM_MAX; ++i )
	{
		if( a_hItemWindow != m_equipItem[ i ] )
			m_equipItem[ i ].ClearSelect();	
	}

	if (  a_hItemWindow != m_equipItem_Brooch )
		m_equipItem_Brooch.ClearSelect();
}

function QuickDestroyInventoryItem(ItemInfo info)
{
	local INT64 destroyCount;

	if (info.ID.ServerID == 0)
		return;

	destroyCount = 1;
	if (IsStackableItem(info.ConsumeType) && info.ItemNum > 1)
	{
		if (info.AllItemCount > 0)
			destroyCount = info.AllItemCount;
		else
			destroyCount = info.ItemNum;
	}

	RequestDestroyItem(info.ID, destroyCount);
}

function OnDropItem( String strTarget, ItemInfo info, int x, int y )
{
	local int toIndex, fromIndex;
	local CrystallizationWnd CrystallizationWndScript;		
	local ItemWindowHandle normalinven;

	// ? 
	CrystallizationWndScript = CrystallizationWnd(GetScript("CrystallizationWnd"));
	

	// ??   ?? ?? ?.
	if(! isDragSrcInventory ( info.DragSrcName )) return ;	
	
	if( strTarget == "InventoryItem" || strTarget == "InventoryItem_1" || strTarget == "InventoryItem_2" || strTarget == "InventoryItem_3" || strTarget == "InventoryItem_4" )
	{
		
		if( info.DragSrcName == strTarget )			// Change Item position
		{
			normalinven = getItemWindowHandleBystrTarget( strTarget );

			toIndex = normalinven.GetIndexAt( x, y, 1, 1 );
			
			// Exchange with another item
			if( toIndex >= 0 )
			{
				fromIndex = normalinven.FindItem(info.ID);
				if( toIndex != fromIndex )
					normalinven.SwapItems( fromIndex, toIndex );
			}
		}
		else if( -1 != InStr( info.DragSrcName, "EquipItem" ) )			// Unequip thie item
		{
			handleRequestUnequipItem( info.DragSrcName, info.ID, info.SlotBitType );			
		}
		else if( info.DragSrcName == "PetInvenWnd" )		// Pet -> Inventory
		{
			if( IsStackableItem(info.ConsumeType) && info.ItemNum > 1 )			// Multiple item?
			{
				if( info.AllItemCount > 0 )					//  ? ?
				{
					if ( CheckItemLimit( info.ID, info.AllItemCount ) )
					{
						class'PetAPI'.static.RequestGetItemFromPet( info.ID, info.AllItemCount, false);
					}
				}
				else
				{
					DialogSetID(DIALOG_DROPITEM_PETASKCOUNT);
					DialogSetReservedItemID(info.ID);	// ServerID
					DialogSetParamInt64(info.ItemNum);
					DialogShow(DialogModalType_Modalless, DialogType_NumberPad, MakeFullSystemMsg( GetSystemMessage(72), info.Name ), string(Self) );
				}
			}
			else																// Single item?
			{
				class'PetAPI'.static.RequestGetItemFromPet( info.ID, 1, false);
			}
		}
	}
	else if( strTarget == "QuestItem" )
	{
		if( info.DragSrcName == "QuestItem" )			// Change Item position
		{

			toIndex = m_questItem.GetIndexAt( x, y, 1, 1 );
			
			if( toIndex >= 0 )
			{
				fromIndex = m_questItem.FindItem(info.ID);
				if( toIndex != fromIndex )
					m_questItem.SwapItems( fromIndex, toIndex );
			}
		}
	}
	/* ?    "EquipItem"  ? ? . */
	// ? ?  
	//else if( ( -1 != InStr( info.DragSrcName, "AgathionMain" )) && (-1 != InStr( strTarget, "AgathionSub" )) )
	//{
	//	handleSwapAgathionSubMain ( strTarget ) ;	
	//}
	//// ? ?  
	//else if( ( -1 != InStr( info.DragSrcName, "AgathionSub" )) && (-1 != InStr( strTarget, "AgathionMain" )) )
	//{		
	//	handleSwapAgathionSubMain ( info.DragSrcName ) ;		
	//}
	//~ SaveInventoryOrder();
	else if( -1 != InStr( strTarget, "EquipItem" ) ||  strTarget == "ObjectViewportDispatchMsg" )		// Equip the item
	{
		//debug("Inven EquipItem: " $info.DragSrcName $" " $string(info.ItemType));
		if( info.DragSrcName == "PetInvenWnd" )				// Pet -> Equip
		{
			class'PetAPI'.static.RequestGetItemFromPet( info.ID, 1, true );
		}
		else if( -1 != InStr( info.DragSrcName, "EquipItem" ) )	//??  ?. 
		{
		}
		else if( EItemType(info.ItemType) != ITEM_ETCITEM )
		{	
			RequestUseItem(info.ID);
		}
	}
	else if( strTarget == "TrashButton" )					// Destroy item( after confirmation )
	{
		// ? 2013.2.6 ??   ?.
		if (IsShowWindow("AttributeEnchantWnd") == true)
		{
			AddSystemMessage(4148);
			return;
		}

		if( IsStackableItem(info.ConsumeType) && info.ItemNum > 1 )			// Multiple item?
		{
			if( info.AllItemCount > 0 )				//   ?
			{				
				DialogSetID(DIALOG_DESTROYITEM_ALL);
				DialogSetReservedItemID(info.ID);	// ServerID
				DialogSetReservedInt2(info.AllItemCount);
				DialogShow(DialogModalType_Modalless,DialogType_Warning, MakeFullSystemMsg(GetSystemMessage(74), info.Name, ""), string(Self));
			}
			else
			{
				DialogSetID(DIALOG_DESTROYITEM_ASKCOUNT);
				DialogSetReservedItemID(info.ID);	// ServerID
				DialogSetParamInt64(info.ItemNum);
				DialogShow(DialogModalType_Modalless, DialogType_NumberPad, MakeFullSystemMsg( GetSystemMessage(73), info.Name ), string(Self) );
			}
		}
		else																// Single item?
		{
			// ?? ?, ?  ?? ? ?
			if( class'UIDATA_PLAYER'.static.HasCrystallizeAbility() && class'UIDATA_ITEM'.static.IsCrystallizable(info.ID) )			
			{
				// DialogSetID(DIALOG_CRYSTALLIZE);
				// DialogSetReservedItemID(info.ID);
				// DialogShow(DialogModalType_Modalless,DialogType_Warning, MakeFullSystemMsg( GetSystemMessage(2232), info.Name ), string(Self) );
				CrystallizationWndScript.setItemInfo(info);
				RequestCrystallizeEstimate(info.ID, INT64(1));
			}
			else
			{
				DialogSetID(DIALOG_DESTROYITEM);
				DialogSetReservedItemID(info.ID);	// ServerID
				DialogShow(DialogModalType_Modalless, DialogType_Warning, MakeFullSystemMsg( GetSystemMessage(74), info.Name ), string(Self) );
			}
		}
	}
	else if( strTarget == "CrystallizeButton" )
	{
		// ? 2013.2.6 ??  ? ?.
		if (IsShowWindow("AttributeEnchantWnd") == true)
		{
			AddSystemMessage(4148);
			return;
		}
		if( info.DragSrcName == "InventoryItem" || info.DragSrcName == "InventoryItem_1" || info.DragSrcName == "InventoryItem_2" || info.DragSrcName == "InventoryItem_3" || info.DragSrcName == "InventoryItem_4" ||( -1 != InStr( info.DragSrcName, "EquipItem" ) ) )
		{
			if( class'UIDATA_PLAYER'.static.HasCrystallizeAbility() && class'UIDATA_ITEM'.static.IsCrystallizable(info.ID) )			// Show Dialog asking confirmation
			{				
				CrystallizationWndScript.setItemInfo(info);
				RequestCrystallizeEstimate(info.ID, INT64(1));

			}
			else
			{
				// ? ?  ?  ?
				CrystallizationWndScript.cancelCystallizeItem();
				// ? ? ?? ? 
				AddSystemMessage(2171);
			}
		}
	}	

	else if( strTarget == "AdenacalculateButton" )
	{		
		//      
		
		if ( IsAdena( info.ID ) && !class'UIAPI_WINDOW'.static.IsShowWindow ("AdenaDistributionWnd") ) 
		{
			callGfxFunction("AdenaDistributionWnd", "RequestDivideAdenaStart","");
		} else 
		addSystemMessage(4158);

	}	
	
	else if ( strTarget == "EnchantJewelButton" )
	{
		handleJewelDropedOnButton( info );
	}
}

//   ?  ?  OnDropItem  ?? ? ? ??  ? ???.
function OnDropItemSource( String strTarget, ItemInfo info )
{
	if ( strTarget != "Console" ) return; 
	if( !isDragSrcInventory ( info.DragSrcName) ) return;
	
	// ? ?  ??..  ?? ?? .
	if (IsShowWindow("ItemEnchantWnd") == false && IsShowWindow("AttributeEnchantWnd") == false  )
	{
		m_clickLocation = GetClickLocation();
		if( IsStackableItem(info.ConsumeType) && info.ItemNum > 1 )		//  ? 
		{
			if( info.AllItemCount > 0 )				//   ?
			{
				DialogHide();
				DialogSetID( DIALOG_DROPITEM_ALL );
				DialogSetReservedItemID(info.ID);	// ServerID
				DialogSetReservedInt2(info.AllItemCount);
				DialogShow(DialogModalType_Modalless,DialogType_Warning, MakeFullSystemMsg(GetSystemMessage(1833), info.Name, ""), string(Self));
			}
			else												// ? ? ?
			{
				DialogHide();
				DialogSetID( DIALOG_DROPITEM_ASKCOUNT );
				DialogSetReservedItemID(info.ID);	// ServerID
				DialogSetParamInt64(info.ItemNum);
				DialogShow(DialogModalType_Modalless,DialogType_NumberPad, MakeFullSystemMsg(GetSystemMessage(71), info.Name, ""), string(Self));
			}
		}
		else
		{
			DialogHide();
			DialogSetID( DIALOG_DROPITEM );
			DialogSetReservedItemID(info.ID);	// ServerID
			DialogShow(DialogModalType_Modalless,DialogType_Warning, MakeFullSystemMsg(GetSystemMessage(400), info.Name, ""), string(Self));
		}
	}
	// "? ? ?   ...."
	else if (IsShowWindow("AttributeEnchantWnd") == true)
		AddSystemMessage(4147);
	// "? ?  ??.    ?.";
	else
		AddSystemMessage(3656);
}


function OnClickButton( string strID )
{	
	switch( strID )
	{
		case "SortButton":
			switch ( m_selectedItemTab  ) 
			{
				case INVENTORY_ITEM_TAB:
					l2UtilScript.SortItem(m_invenItem);	//?? 
					SaveInventoryOrder();
				break;
				case INVENTORY_ITEM_1_TAB:
					l2UtilScript.SortItem(m_invenItem_1);
				break;
				case INVENTORY_ITEM_2_TAB:
					l2UtilScript.SortItem(m_invenItem_2);
				break;
				case INVENTORY_ITEM_3_TAB:
					l2UtilScript.SortItem(m_invenItem_3);
				break;
				case INVENTORY_ITEM_4_TAB:
					l2UtilScript.SortItem(m_invenItem_4);
				break;				
				case QUEST_ITEM_TAB:
					SortQuestItem();
				break;				
				default:
					l2UtilScript.SortItem(m_invenItem);	//?? 
					SaveInventoryOrder();
				break;
			}			
		break;
		case "InventoryTab0":	//??   ?			
			m_selectedItemTab = INVENTORY_ITEM_TAB;
			m_invenItem.SetScrollPosition(0);
			SetItemCount();			
			break;
		case "InventoryTab1":	//??   ?			
			m_selectedItemTab = INVENTORY_ITEM_1_TAB;
			m_invenItem_1.SetScrollPosition(0);
			SetItemCount();			
			break;
		case "InventoryTab2":	//??   ?			
			m_selectedItemTab = INVENTORY_ITEM_2_TAB;
			m_invenItem_2.SetScrollPosition(0);
			SetItemCount();			
			break;
		case "InventoryTab3":	//??   ?			
			m_selectedItemTab = INVENTORY_ITEM_3_TAB;
			m_invenItem_3.SetScrollPosition(0);
			SetItemCount();			
			break;
		case "InventoryTab4":	//??   ?			
			m_selectedItemTab = INVENTORY_ITEM_4_TAB;
			m_invenItem_4.SetScrollPosition(0);
			SetItemCount();			
			break;
		case "InventoryTab5":	//?   ?			
			m_selectedItemTab = QUEST_ITEM_TAB;
			m_questItem.SetScrollPosition(0);
			SetItemCount();
			break;
		case "BtnWindowExpand" :  // ????
			extendInventory(currentInvenCol == 9);
			break;			
		case "AdenacalculateButton" ://? ?  
			if ( !class'UIAPI_WINDOW'.static.IsShowWindow ("PrivateShopWndReport") )
				callGfxFunction("AdenaDistributionWnd", "RequestDivideAdenaStart","");
			else getInstanceL2Util().showGfxScreenMessage( GetSystemMessage(5104)) ;
			break;
		case "HairAccButton":			
		case "HairButton":
			ChangeViewAccessoryFunc();
			break;
		case "EnchantJewelButton":
			handleEnchantJewelButton();
			break;
		case "JewelButton":
		case "JewelCloseButton":
			toggleJewelWindow();
			break;
		case "AgathionButton":
		case "AgathionCloseButton":			
			toggleAgathionWindow();
			break;
		case "AlchemyOpenerBtn":
		case "AlchemyCloseButton":
			toggleAlchemyOpener();
			break;
		case "AlchemyItemCreateWndBtn":
			//toggleShowAlchemyWindow( "alchemyItemCreate");
			break;
		case "AlchemyItemConversionWndBtn":
			toggleShowAlchemyWindow( "AlchemyItemConversionWnd");
			AlchemyOpenerWindow.HideWindow();
			break;
		case "AlchemyMixCubeWndBtn":
			toggleShowAlchemyWindow( "AlchemyMixCubeWnd");
			AlchemyOpenerWindow.HideWindow();
			break;
	}
}

function OnClickCheckBox(string strID)
{
	if (strID == "CtrlAltDeleteCheckBox")
	{
		m_bCtrlAltDeleteEnabled = m_CtrlAltDeleteCheckBox.IsChecked();
		SetOptionBool("Game", "EnableCtrlAltInventoryDelete", m_bCtrlAltDeleteEnabled);
	}
}

/********************************************************************************************
 * ??  handle 
 * ******************************************************************************************/
function InitHandleCOD()
{
	m_hInventoryWnd=GetWindowHandle(m_WindowName);
	m_invenItem	= GetItemWindowHandle(m_WindowName $ ".InventoryItem");

	m_invenItem_1 = GetItemWindowHandle(m_WindowName $ ".InventoryItem_1");
	m_invenItem_2 = GetItemWindowHandle(m_WindowName $ ".InventoryItem_2");
	m_invenItem_3 = GetItemWindowHandle(m_WindowName $ ".InventoryItem_3");
	m_invenItem_4 = GetItemWindowHandle(m_WindowName $ ".InventoryItem_4");

	m_questItem	= GetItemWindowHandle(m_WindowName $ ".QuestItem");
	m_hAdenaTextBox = GetTextBoxHandle( m_WindowName $ ".AdenaText" );
	m_invenTab	= GetTabHandle(m_WindowName $ ".InventoryTab");
	m_sortBtn	= GetButtonHandle(m_WindowName $ ".SortButton");
	m_CtrlAltDeleteCheckBox = GetCheckBoxHandle(m_WindowName $ ".CtrlAltDeleteCheckBox");
	if (m_CtrlAltDeleteCheckBox != none)
	{
		// Place delete toggle to the right of synthesis button and center vertically.
		m_CtrlAltDeleteCheckBox.SetAnchor(m_WindowName $ ".AlchemyOpenerBtn", "TopLeft", "TopRight", 4, 13);
		m_CtrlAltDeleteCheckBox.SetWindowSize(14, 14);
		m_CtrlAltDeleteCheckBox.SetTooltipText("Ctrl+Alt+LMB: irreversible item delete");
		m_CtrlAltDeleteCheckBox.SetTooltipCustomType(MakeTooltipSimpleText("Ctrl+Alt+LMB: irreversible item delete"));
		m_CtrlAltDeleteCheckBox.BringToFront();
		class'UIAPI_WINDOW'.static.SetAlwaysOnTop(m_WindowName $ ".CtrlAltDeleteCheckBox", true);
		class'UIAPI_WINDOW'.static.BringToFront(m_WindowName $ ".CtrlAltDeleteCheckBox");
	}
		
	AlchemyOpenerWindow = GetWindowHandle(m_WindowName $ ".AlchemyOpener_Window" );

	AlchemyMixCubeWndBtn = GetButtonHandle(m_WindowName $ ".AlchemyOpener_Window.AlchemyMixCubeWndBtn");	  
	alchemyItemConversionWndBtn = GetButtonHandle(m_WindowName $ ".AlchemyOpener_Window.AlchemyItemConversionWndBtn");
	AlchemyItemCreateWndBtn = GetButtonHandle(m_WindowName $ ".AlchemyOpener_Window.AlchemyItemCreateWndBtn");

	m_hBtnCrystallize = GetButtonHandle(m_WindowName $ ".CrystallizeButton");

	EnchantJewelButton = GetButtonHandle(m_WindowName $ ".EnchantJewelButton");

	JewelButton = GetButtonHandle( m_WindowName $ ".Equip_Live.JewelButton" );

	AdenacalculateButton = GetButtonHandle(m_WindowName $ ".AdenacalculateButton");

	ColorNickNameWnd = GetWindowHandle("ColorNickNameWnd");

	AlchemyOpenerBtn = GetButtonHandle( m_WindowName $ ".AlchemyOpenerBtn" );

	// ???
	m_BtnWindowExpand = GetButtonHandle(m_WindowName $ ".BtnWindowExpand");
	
	m_InventoryItembg_expand = GetTextureHandle(m_WindowName $ ".InventoryItembg_expand");

	m_tabbg = GetTextureHandle(m_WindowName $ ".tabbg");
	m_tabbgLine = GetTextureHandle(m_WindowName $ ".tabbgLine");

	m_itemCount = GetTextBoxHandle(m_WindowName $ ".ItemCount");

	m_BtnRotateLeft= GetButtonHandle(m_WindowName $ ".Equip_Live.BtnRotateLeft");
	m_BtnRotateRight= GetButtonHandle(m_WindowName $ ".Equip_Live.BtnRotateRight");
	
	m_ObjectViewport = GetCharacterViewportWindowHandle(m_WindowName $ ".Equip_Live.ObjectViewport");

	m_hPremiumHennaItemWindow = GetItemWindowHandle( m_WindowName$".Equip_Live.PremiumHennaItem" ); //branch121212	
}

//   ? ?  
function getHandles()
{
	local string equipWindow ;
	equipWindow = m_WindowName$"."$ m_EquipWindowName;	
	
	//?   
	/*
	 *?
	 *
	 *? < 151015  ? 
	 * < 151015  ? 
	 *? <  ? 
	 *	
	*/
	ViewHairButton = GetButtonHandle(equipWindow $ ".HairButton");
	ViewAccessoryButton = GetButtonHandle(equipWindow $ ".HairAccButton");
	
	m_equipItem[ EQUIPITEM_Head ] = GetItemWindowHandle( equipWindow $ ".EquipItem_Head" );
	m_equipItem[ EQUIPITEM_Hair ] = GetItemWindowHandle( equipWindow $ ".EquipItem_Hair" );
	m_equipItem[ EQUIPITEM_Hair2 ] = GetItemWindowHandle( equipWindow $ ".EquipItem_Hair2" );
	m_equipItem[ EQUIPITEM_Neck ] = GetItemWindowHandle( equipWindow $ ".EquipItem_Neck" );
	m_equipItem[ EQUIPITEM_RHand ] = GetItemWindowHandle( equipWindow $ ".EquipItem_RHand" );
	m_equipItem[ EQUIPITEM_Chest ] = GetItemWindowHandle( equipWindow $ ".EquipItem_Chest" );
	m_equipItem[ EQUIPITEM_LHand ] = GetItemWindowHandle( equipWindow $ ".EquipItem_LHand" );
	m_equipItem[ EQUIPITEM_REar ] = GetItemWindowHandle( equipWindow $ ".EquipItem_REar" );
	m_equipItem[ EQUIPITEM_LEar ] = GetItemWindowHandle( equipWindow $ ".EquipItem_LEar" );
	m_equipItem[ EQUIPITEM_Gloves ] = GetItemWindowHandle( equipWindow $ ".EquipItem_Gloves" );
	m_equipItem[ EQUIPITEM_Legs ] = GetItemWindowHandle( equipWindow $ ".EquipItem_Legs" );
	m_equipItem[ EQUIPITEM_Feet ] = GetItemWindowHandle( equipWindow $ ".EquipItem_Feet" );
	m_equipItem[ EQUIPITEM_RFinger ] = GetItemWindowHandle( equipWindow $ ".EquipItem_RFinger" );
	m_equipItem[ EQUIPITEM_LFinger ] = GetItemWindowHandle( equipWindow $ ".EquipItem_LFinger" );
	m_equipItem[ EQUIPITEM_LBracelet ] = GetItemWindowHandle( equipWindow $ ".EquipItem_LBracelet" );

	m_equipItem[ EQUIPITEM_Cloak ] = GetItemWindowHandle( equipWindow $ ".EquipItem_Cloak" ); 
	m_equipItem[ EQUIPITEM_Waist ] = GetItemWindowHandle( equipWindow $ ".EquipItem_Waist" );	
	
	m_equipItem[ EQUIPITEM_Deco1 ] = GetItemWindowHandle( equipWindow $ ".EquipItem_Talisman1" );
	m_equipItem[ EQUIPITEM_Deco2 ] = GetItemWindowHandle( equipWindow $ ".EquipItem_Talisman2" );
	m_equipItem[ EQUIPITEM_Deco3 ] = GetItemWindowHandle( equipWindow $ ".EquipItem_Talisman3" );
	m_equipItem[ EQUIPITEM_Deco4 ] = GetItemWindowHandle( equipWindow $ ".EquipItem_Talisman4" );
	m_equipItem[ EQUIPITEM_Deco5 ] = GetItemWindowHandle( equipWindow $ ".EquipItem_Talisman5" );
	m_equipItem[ EQUIPITEM_Deco6 ] = GetItemWindowHandle( equipWindow $ ".EquipItem_Talisman6" );

	m_Talisman_Disable[ 0 ] = GetTextureHandle(equipWindow $ ".Talisman1_Disable");
	m_Talisman_Disable[ 1 ] = GetTextureHandle(equipWindow $ ".Talisman2_Disable");
	m_Talisman_Disable[ 2 ] = GetTextureHandle(equipWindow $ ".Talisman3_Disable");
	m_Talisman_Disable[ 3 ] = GetTextureHandle(equipWindow $ ".Talisman4_Disable");
	m_Talisman_Disable[ 4 ] = GetTextureHandle(equipWindow $ ".Talisman5_Disable");
	m_Talisman_Disable[ 5 ] = GetTextureHandle(equipWindow $ ".Talisman6_Disable");

	m_equipItem[ EQUIPITEM_RBracelet ] = GetItemWindowHandle( equipWindow $ ".EquipItem_RBracelet" );

	//classic ??  . ? ? ? ?    ??  
	m_equipItem[ EQUIPITEM_Underwear ] = GetItemWindowHandle( equipWindow $ ".EquipItem_Underwear" );
	
	m_equipItem[ EQUIPITEM_LHand ].SetDisableTex( "L2UI.InventoryWnd.Icon_dualcap" );
	m_equipItem[ EQUIPITEM_Head ].SetDisableTex( "L2UI.InventoryWnd.Icon_dualcap" );
	m_equipItem[ EQUIPITEM_Gloves ].SetDisableTex( "L2UI.InventoryWnd.Icon_dualcap" );
	m_equipItem[ EQUIPITEM_Legs ].SetDisableTex( "L2UI.InventoryWnd.Icon_dualcap" );
	m_equipItem[ EQUIPITEM_Feet ].SetDisableTex( "L2UI.InventoryWnd.Icon_dualcap" );
	m_equipItem[ EQUIPITEM_Hair2 ].SetDisableTex( "L2UI.InventoryWnd.Icon_dualcap" );
	
	                                                                                
	m_hHennaItemWindow = GetItemWindowHandle( equipWindow$".HennaItem"  );
	//currentInvenCol = 6;	
	
	m_equipItem[ EQUIPITEM_Head ].SetTooltipText(  GetSystemString(230) );
	m_equipItem[ EQUIPITEM_Hair ].SetTooltipText( GetSystemString(1024) );
	m_equipItem[ EQUIPITEM_Hair2 ].SetTooltipText(  GetSystemString(1024) );
	m_equipItem[ EQUIPITEM_Neck ].SetTooltipText(  GetSystemString(238) );
	//
	m_equipItem[ EQUIPITEM_RHand ].SetTooltipText(  GetSystemString( 2520 ) );
	m_equipItem[ EQUIPITEM_Chest ].SetTooltipText(  GetSystemString(38) );
	//
	m_equipItem[ EQUIPITEM_LHand ].SetTooltipText(  GetSystemString( 231 ) );
	m_equipItem[ EQUIPITEM_REar ].SetTooltipText(  GetSystemString( 237 ) );
	m_equipItem[ EQUIPITEM_LEar ].SetTooltipText(  GetSystemString( 237 ) );
	m_equipItem[ EQUIPITEM_Gloves ].SetTooltipText( GetSystemString(37) );
	m_equipItem[ EQUIPITEM_Legs ].SetTooltipText(  GetSystemString( 39 ) );
	m_equipItem[ EQUIPITEM_Feet ].SetTooltipText(  GetSystemString( 40) );
	m_equipItem[ EQUIPITEM_RFinger ].SetTooltipText(  GetSystemString( 239 ) );
	m_equipItem[ EQUIPITEM_LFinger ].SetTooltipText(  GetSystemString( 239 ) );
	m_equipItem[ EQUIPITEM_LBracelet ].SetTooltipText(  GetSystemString(1637) );

	m_equipItem[ EQUIPITEM_Cloak ].SetTooltipText(  GetSystemString(234) );
	m_equipItem[ EQUIPITEM_Waist ].SetTooltipText(  GetSystemString(2538) );	

	m_equipItem[ EQUIPITEM_RBracelet ].SetTooltipText(  GetSystemString(1636) );

	m_equipItem[ EQUIPITEM_Deco1 ].SetTooltipText(  GetSystemString(1638) );
	m_equipItem[ EQUIPITEM_Deco2 ].SetTooltipText(  GetSystemString(1638) );
	m_equipItem[ EQUIPITEM_Deco3 ].SetTooltipText(  GetSystemString(1638) );
	m_equipItem[ EQUIPITEM_Deco4 ].SetTooltipText(  GetSystemString(1638) );
	m_equipItem[ EQUIPITEM_Deco5 ].SetTooltipText(  GetSystemString(1638) );
	m_equipItem[ EQUIPITEM_Deco6 ].SetTooltipText(  GetSystemString(1638) );

	m_Talisman_Disable[ 0 ].SetTooltipText(  GetSystemString(1638) );
	m_Talisman_Disable[ 1 ].SetTooltipText(  GetSystemString(1638) );
	m_Talisman_Disable[ 2 ].SetTooltipText(  GetSystemString(1638) );
	m_Talisman_Disable[ 3 ].SetTooltipText(  GetSystemString(1638) );
	m_Talisman_Disable[ 4 ].SetTooltipText(  GetSystemString(1638) );
	m_Talisman_Disable[ 5 ].SetTooltipText(  GetSystemString(1638) );	

	//? ?? ?
	m_equipItem[ EQUIPITEM_Underwear ].SetTooltipText(  GetSystemString(28) );	
	m_hHennaItemWindow.SetTooltipText(  GetSystemString(3185) );	
	setCustomTooltip();
}

/*
 * ? ?   ? 
 * ? ??   ?  
 */
function setEquipWindowHandle() 
{
	local int UseClassicJewelEnchantBtn, i ;
	local string hyphen;
	local string strMainAgathion;
	local string strSubAgathion;
	
	if ( getInstanceUIData().getIsClassicServer() ) 
	{   
		// ? ?  ? UI   
		//   ?  "? ?", "?"  ?  ?, (    )   "?" 
		GetINIBool ( "Localize", "UseClassicJewelEnchantBtn", UseClassicJewelEnchantBtn, "L2.ini" );

		// ? ? ? ?
		if (getInstanceUIData().getIsArenaServer()) UseClassicJewelEnchantBtn = 0;

		if ( UseClassicJewelEnchantBtn == 1 ) 
		{
			setBottomButtonPostion (i, AdenacalculateButton);			
			setBottomButtonPostion (i, EnchantJewelButton);
			setBottomButtonPostion (i, m_hBtnCrystallize);
			EnchantJewelButton.ShowWindow();
		}
		else 
		{
			setBottomButtonPostion (i, AdenacalculateButton);
			setBottomButtonPostion (i, m_hBtnCrystallize);
			setBottomButtonPostion (i, EnchantJewelButton);			;
			EnchantJewelButton.HideWindow();			
		}

		m_EquipWindowName = "Equip_classic";
	}
	else 
	{
		setBottomButtonPostion (i, m_hBtnCrystallize);
		setBottomButtonPostion (i, AdenacalculateButton);
		setBottomButtonPostion (i, EnchantJewelButton);
		EnchantJewelButton.ShowWindow();	
		m_EquipWindowName = "Equip_Live";
		//Debug("-_-mainSever Equip_Live!!");
	}

	// ?  ?, 
	JewelButton = GetButtonHandle(m_WindowName $ "." $ m_EquipWindowName $ ".JewelButton" );
	JewelWindow = GetWindowHandle(m_WindowName $ "." $ m_EquipWindowName $ ".EquipItem_Jewel_Window" );

	
	m_equipItem_Brooch = GetItemWindowHandle( m_WindowName $ "." $ m_EquipWindowName $ ".EquipItem_Jewel_Window.EquipItem_Brooch" );
	m_BroochEquiped = GetTextureHandle ( m_WindowName $ "." $ m_EquipWindowName $ ".EquipItem_Jewel_Window.BroochEquiped" );

	m_equipItem[ EQUIPITEM_Brooch ] = GetItemWindowHandle( m_WindowName $ "." $ m_EquipWindowName $ ".EquipItem_Brooch" );
	m_equipItem[ EQUIPITEM_Jewel1 ] = GetItemWindowHandle( m_WindowName $ "." $ m_EquipWindowName $ ".EquipItem_Jewel_Window.EquipItem_Jewel1" );
	m_equipItem[ EQUIPITEM_Jewel2 ] = GetItemWindowHandle( m_WindowName $ "." $ m_EquipWindowName $ ".EquipItem_Jewel_Window.EquipItem_Jewel2" );
	m_equipItem[ EQUIPITEM_Jewel3 ] = GetItemWindowHandle( m_WindowName $ "." $ m_EquipWindowName $ ".EquipItem_Jewel_Window.EquipItem_Jewel3" );
	m_equipItem[ EQUIPITEM_Jewel4 ] = GetItemWindowHandle( m_WindowName $ "." $ m_EquipWindowName $ ".EquipItem_Jewel_Window.EquipItem_Jewel4" );
	m_equipItem[ EQUIPITEM_Jewel5 ] = GetItemWindowHandle( m_WindowName $ "." $ m_EquipWindowName $ ".EquipItem_Jewel_Window.EquipItem_Jewel5" );
	m_equipItem[ EQUIPITEM_Jewel6 ] = GetItemWindowHandle( m_WindowName $ "." $ m_EquipWindowName $ ".EquipItem_Jewel_Window.EquipItem_Jewel6" );

	m_Jewel_Disable[ 0 ] = GetTextureHandle(m_WindowName $ "." $ m_EquipWindowName $ ".EquipItem_Jewel_Window.Jewel1_Disable");
	m_Jewel_Disable[ 1 ] = GetTextureHandle(m_WindowName $ "." $ m_EquipWindowName $ ".EquipItem_Jewel_Window.Jewel2_Disable");
	m_Jewel_Disable[ 2 ] = GetTextureHandle(m_WindowName $ "." $ m_EquipWindowName $ ".EquipItem_Jewel_Window.Jewel3_Disable");
	m_Jewel_Disable[ 3 ] = GetTextureHandle(m_WindowName $ "." $ m_EquipWindowName $ ".EquipItem_Jewel_Window.Jewel4_Disable");
	m_Jewel_Disable[ 4 ] = GetTextureHandle(m_WindowName $ "." $ m_EquipWindowName $ ".EquipItem_Jewel_Window.Jewel5_Disable");
	m_Jewel_Disable[ 5 ] = GetTextureHandle(m_WindowName $ "." $ m_EquipWindowName $ ".EquipItem_Jewel_Window.Jewel6_Disable");	

	m_equipItem_Brooch.SetTooltipText(  GetSystemString(3186) );
	m_equipItem[ EQUIPITEM_Brooch ].SetTooltipText(  GetSystemString(3186) );

	/******************************************** ?   *********************************************/
	AgathionWindow = GetWindowHandle(m_WindowName $ "." $ m_EquipWindowName $ ".EquipItem_Agathion_Window");

	// ?  ? ?
	AgathionBtn = GetButtonHandle(m_WindowName $ "." $ m_EquipWindowName $ ".AgathionButton");

	// ? ?? ?  ( main  ) 
	m_Agathion_Disable[ 0 ] = GetTextureHandle(m_WindowName $ "." $ m_EquipWindowName $ ".EquipItem_Agathion_Window.AgathionMain_Disable");
	m_Agathion_Disable[ 1 ] = GetTextureHandle(m_WindowName $ "." $ m_EquipWindowName $ ".EquipItem_Agathion_Window.Agathion1_Disable");
	m_Agathion_Disable[ 2 ] = GetTextureHandle(m_WindowName $ "." $ m_EquipWindowName $ ".EquipItem_Agathion_Window.Agathion2_Disable");
	m_Agathion_Disable[ 3 ] = GetTextureHandle(m_WindowName $ "." $ m_EquipWindowName $ ".EquipItem_Agathion_Window.Agathion3_Disable");
	m_Agathion_Disable[ 4 ] = GetTextureHandle(m_WindowName $ "." $ m_EquipWindowName $ ".EquipItem_Agathion_Window.Agathion4_Disable");
	
	// ?   
	m_equipItem[ EQUIPITEM_AGATHION_MAIN ] = GetItemWindowHandle(m_WindowName $ "." $ m_EquipWindowName $ ".EquipItem_Agathion_Window.EquipItem_AgathionMain");
	m_equipItem[ EQUIPITEM_AGATHION_SUB1 ] = GetItemWindowHandle(m_WindowName $ "." $ m_EquipWindowName $ ".EquipItem_Agathion_Window.EquipItem_AgathionSub1");
	m_equipItem[ EQUIPITEM_AGATHION_SUB2 ] = GetItemWindowHandle(m_WindowName $ "." $ m_EquipWindowName $ ".EquipItem_Agathion_Window.EquipItem_AgathionSub2");
	m_equipItem[ EQUIPITEM_AGATHION_SUB3 ] = GetItemWindowHandle(m_WindowName $ "." $ m_EquipWindowName $ ".EquipItem_Agathion_Window.EquipItem_AgathionSub3");
	m_equipItem[ EQUIPITEM_AGATHION_SUB4 ] = GetItemWindowHandle(m_WindowName $ "." $ m_EquipWindowName $ ".EquipItem_Agathion_Window.EquipItem_AgathionSub4");	

	hyphen = getHyphenByLanguage();

	strMainAgathion = GetSystemString(2738) @  GetSystemString(3638);
	strSubAgathion = GetSystemString(2341) @  GetSystemString(3638);

	if(GetLanguage() != LANG_Korean)
	{
		strMainAgathion = GetSystemString(5864);
		strSubAgathion = GetSystemString(5865);
	}

	m_Agathion_Disable[0].SetTooltipCustomType(getAgathionTooltip(strMainAgathion,hyphen $GetSystemString(3642))) ;
	m_Agathion_Disable[1].SetTooltipCustomType(getAgathionTooltip(strSubAgathion,hyphen $GetSystemString(3643))) ;
	m_Agathion_Disable[2].SetTooltipCustomType(getAgathionTooltip(strSubAgathion,hyphen $GetSystemString(3643))) ;
	m_Agathion_Disable[3].SetTooltipCustomType(getAgathionTooltip(strSubAgathion,hyphen $GetSystemString(3643))) ;
	m_Agathion_Disable[4].SetTooltipCustomType(getAgathionTooltip(strSubAgathion,hyphen $GetSystemString(3643))) ;
	
	m_equipItem[EQUIPITEM_AGATHION_MAIN].SetTooltipText(strMainAgathion $"\\n" $ hyphen $ GetSystemString(3642));
	m_equipItem[EQUIPITEM_AGATHION_SUB1].SetTooltipText(strSubAgathion $"\\n" $ hyphen $ GetSystemString(3643));
	m_equipItem[EQUIPITEM_AGATHION_SUB2].SetTooltipText(strSubAgathion $"\\n" $ hyphen $ GetSystemString(3643));
	m_equipItem[EQUIPITEM_AGATHION_SUB3].SetTooltipText(strSubAgathion $"\\n" $ hyphen $ GetSystemString(3643));
	m_equipItem[EQUIPITEM_AGATHION_SUB4].SetTooltipText(strSubAgathion $"\\n" $ hyphen $ GetSystemString(3643));
	/****************************************************************************************************************/

	m_EquipWindow = GetWindowHandle(m_WindowName $"."$ m_EquipWindowName );	
}

function string getHyphenByLanguage () 
{	
	// ? ?   ?? ?  ??.
	if (GetLanguage() == LANG_Korean ) return ""; 
	return "-";
}


/********************************************************************************************
 * ?  
 * ******************************************************************************************/
function HandleRestart()
{
	m_bCurrentState = false;
	m_bFirstOpen = true;

	m_hInventoryWnd.HideWindow() ;
	bIsRequestItemList = false ;
	m_hOwnerWnd.KillTimer( TIMER_REQUEST_ITEMLIST );
}

/********************************************************************************************
 * ??  
 * ******************************************************************************************/
function HandleDialogOK()
{
	local int id;
	local INT64 reserved2;
	local ItemID sID;
	local INT64 number;
	
	if( DialogIsMine() )
	{
		id = DialogGetID();
		reserved2 = DialogGetReservedInt2();
		number = INT64(DialogGetString());
		sID = DialogGetReservedItemID();	// ItemID
		
		if( id == DIALOG_USE_RECIPE || id == DIALOG_POPUP )
		{
			RequestUseItem(sID);
		}
		else if( id == DIALOG_DROPITEM )
		{
			RequestDropItem( sID, 1, m_clickLocation );
		}
		else if( id == DIALOG_DROPITEM_ASKCOUNT )
		{
			if(number == 0) 
				number = 1;					// ? ? ?  1  
			RequestDropItem( sID, number, m_clickLocation );
		}
		else if( id == DIALOG_DROPITEM_ALL )
		{
			RequestDropItem( sID, reserved2, m_clickLocation );
		}
		else if( id == DIALOG_DESTROYITEM )
		{
			RequestDestroyItem(sID, 1);
			PlayConsoleSound(IFST_TRASH_BASKET);
		}
		else if( id == DIALOG_DESTROYITEM_ASKCOUNT )
		{
			RequestDestroyItem(sID, number);
			PlayConsoleSound(IFST_TRASH_BASKET);
		}
		else if( id == DIALOG_DESTROYITEM_ALL)
		{
			RequestDestroyItem(sID, reserved2);
			PlayConsoleSound(IFST_TRASH_BASKET);
		}
		else if( id == DIALOG_CRYSTALLIZE )
		{
			RequestCrystallizeItem(sID,1);
			PlayConsoleSound(IFST_TRASH_BASKET);
		}
		else if ( id == DIALOG_DROPITEM_PETASKCOUNT )
		{
			class'PetAPI'.static.RequestGetItemFromPet( sID, number, false);
		}
	}
}


/********************************************************************************************
 *   
 * ******************************************************************************************/
// ?? 
function ChangeViewAccessoryFunc()
{
	local ItemInfo infItem;
	infItem.ID.ClassID = 17192;
	UseSkill(infItem.ID, int(EShortCutItemType.SCIT_SKILL));
}

// ? 
function UseItem( ItemWindowHandle a_hItemWindow, int index )
{
	local ItemInfo	info;

	if( a_hItemWindow.GetItem(index, info) )
	{
		if( info.bDisabled == 0 )		// lpislhy
		{
			if( info.bRecipe )					// ()   ?
			{
				DialogSetReservedItemID(info.ID);	// ServerID
				DialogSetID(DIALOG_USE_RECIPE);
				DialogShow(DialogModalType_Modalless,DialogType_Warning, GetSystemMessage(798), string(Self));
			}
			else if( info.PopMsgNum > 0 )			// ? ? ?.
			{
				DialogSetID(DIALOG_POPUP);
				DialogSetReservedItemID(info.ID);	// ServerID
				DialogShow(DialogModalType_Modalless,DialogType_Warning, GetSystemMessage(info.PopMsgNum), string(Self));
			}
			else
			{
				RequestUseItem(info.ID);
			}
		}
	}
}

//   
function handleJewelDropedOnButton(  ItemInfo info ) 
{
	local ItemJewelEnchantWnd script;

	script = ItemJewelEnchantWnd(GetScript( "ItemJewelEnchantWnd"));
	script.handleDropedItem( info );
}


/*
 *? swap    
function handleSwapAgathionSubMain ( string subItemWindowName  ) 
{
	local itemInfo mainItem, subItem;

	Debug ( "subItemWindowName 0" @ subItemWindowName );
	//    
	m_equipItem[ EQUIPITEM_AGATHION_MAIN].GetItem( 0, mainItem ) ;
	int64(getAgathionSlotBitTypeString ( "n" ) );
	
	Debug ( "subItemWindowName 1" @ subItemWindowName );
	//   
	m_equipItem[ EQUIPITEM_AGATHION_MAIN + int(right ( subItemWindowName, 1 )) ].GetItem( 0, subItem ) ;	
	int64(getAgathionSlotBitTypeString ( right ( subItemWindowName, 1 ) ));

	Debug ("handleSwapAgathionSubMain!" @  mainItem.ID.serverID @ int64(getAgathionSlotBitTypeString ( "n" ) ) @ subItem.ID.serverID  @ int64(getAgathionSlotBitTypeString ( right ( subItemWindowName, 1 ) ))) ;
}
*/

/********************************************************************************************
 *  ? 
 * ******************************************************************************************/
// ??    ??
function UpdateItemUsability()
{
	m_invenItem.SetItemUsability();
	m_invenItem_1.SetItemUsability();
	m_invenItem_2.SetItemUsability();
	m_invenItem_3.SetItemUsability();
	m_invenItem_4.SetItemUsability();
	m_questItem.SetItemUsability();
}

//  ?
function HandleUpdateItem(string param)
{
	//local int		Order;
	local string	type;
	local ItemInfo	info;
	local int		index;
	local ItemWindowHandle detailItemWindowHandle;
	
	lastHandleAddItemParam = param;	
	ParseString( param, "type", type );
	ParamToItemInfo( param, info );
	
	if( type == "add" )
	{
		if( IsEquipItem(info) )
		{
			QuitReportWndScript.externalAddItem(info);

			EquipItemUpdate( info );
			
		}
		else if( IsQuestItem(info) )
		{			
			QuestInvenAddItem( info );				
		}
		else
		{			
			QuitReportWndScript.externalAddItem(info);
			NormalInvenAddItem( info );
						
		}
	}
	else if( type == "update" )
	{
		if( IsEquipItem(info) )
		{	
			if( EquipItemFind(info.ID) )		// match found
			{
				//debug(" ? " $ param);
				EquipItemUpdate( info );
				
			}
			else			// not found in equipItemList. In this case, move the item from InvenItemList to EquipItemList
			{
				InvenDelete( info );				
				EquipItemUpdate( info );
			}
		}
		else if( IsQuestItem(info) )
		{
			index = m_questItem.FindItem(info.ID);	// ServerID
			if( index != -1 )
			{
				m_questItem.SetItem(index, info);				
			}
			else		// In this case, Equipped item is being unequipped.
			{
				EquipItemDelete(info.ID);
				QuestInvenAddItem( info );
			}			
		}
		else
		{
			index = m_invenItem.FindItem(info.ID);	// ServerID

			if( index != -1 )
			{
				QuitReportWndScript.externalAddItem(info);

				m_invenItem.SetItem( index, info );
				detailItemWindowHandle = getItemWindowHandleByItemType( info );				
				detailItemWindowHandle.SetItem ( detailItemWindowHandle.FindItem( info.ID ) , info ) ;
			}
			else		// In this case, Equipped item is being unequipped.
			{
				EquipItemDelete(info.ID);				
				NormalInvenAddItem( info );
			}
		}
	}
	else if( type == "delete" )
	{
		if( IsEquipItem(info) )
		{
			EquipItemDelete(info.ID);
		}
		else if( IsQuestItem(info) )
		{
			QuestInvenDelete( info );
		}
		else
		{
			InvenDelete( info );
		}
	}

	UpdateItemUsability();

	SetAdenaText();
	SetItemCount();
}

//  ?? ?  .
// ?  ?
// ? ?
function HandleItemListEnd()
{	
	//  ?  ? ? 
	if ( !bIsQuestItemList ) 
	{
		bIsQuestItemList = true;
		return;
	}
	
	SetAdenaText();
	SetItemCount();
	UpdateItemUsability();
	
	if ( bIsSavedLocalItemIdx ) SaveInventoryOrder() ;
	if ( bIsRequestItemList ) 
	{
		
		l2UtilScript.SortItem(m_invenItem_1);
		l2UtilScript.SortItem(m_invenItem_2);
		l2UtilScript.SortItem(m_invenItem_3);
		l2UtilScript.SortItem(m_invenItem_4);	
		bIsRequestItemList = false;
		//m_hOwnerWnd.ShowWindowWithFocus();         
		ShowWindowWithFocus( "InventoryWnd" );
		PlayConsoleSound(IFST_INVENWND_OPEN);
	}	
}

/********************************************************************************************
 * item add 
 * ******************************************************************************************/
function HandleAddItem(string param)
{	
	local ItemInfo info;	
	
	ParamToItemInfo( param, info );

	if( IsEquipItem(info) )		
		EquipItemUpdate( info );		
	else if( IsQuestItem(info) )
		QuestInvenAddItem(info);
	else
		NormalInvenAddItem( info );
}

function NormalInvenAddItem( ItemInfo newItem )
{	
	local int idx;
	local int CurLimit;
	local int FindIdx;
	
	local ItemInfo curItem;

	local ItemWindowHandle detailItemWindow ;
	
	//local int FindIdxDetail;	

	FindIdx = -1;	

	CurLimit = m_invenItem.GetItemNum();
	//Debug("NormalInvenAddItem" @  newItem.ID.classID @ newItem.ID.serverID);

	if ( bIsSavedLocalItemIdx ) 	
		newItem.Order = getLocalItemOrder( newItem.ID.serverID, itemSwapedServerID, itemSwapedIdx, newItem.Order ) ;
	
	//? ?   
	if(  m_invenItem.GetItem( newItem.Order, curItem ) )
		if( !IsValidItemID( curItem.ID ) )	
			FindIdx = newItem.Order;
	
	
	//  
	if( FindIdx < 0 )
		for( idx=0; idx<CurLimit; idx++ )
			// idx ?
			if( m_invenItem.GetItem( idx, curItem ) )
				if( !IsValidItemID( curItem.ID ) )
				{	
					FindIdx = idx;
					break;
				}		
	
	if( FindIdx > -1 )
		m_invenItem.SetItem( FindIdx, newItem );				
	else
		m_invenItem.AddItem( newItem );
		
	m_NormalInvenCount++;
	
	// ? ?	
	detailItemWindow = getItemWindowHandleByItemType ( newItem );

	if ( bIsSavedLocalItemIdx ) 
		FindIdx = getLocalItemOrderByItemWindow( detailItemWindow, newItem.ID.serverID, -1 ) ;
	else 
	{
		FindIdx = -1;	
		//Debug ( "addNormalItem 0" @ newItem.Name @ FindIdx ) ;

		for( idx=0; idx<CurLimit; idx++ )
			if( detailItemWindow.GetItem( idx, curItem ) )
				if( !IsValidItemID( curItem.ID ) )
				{				
					FindIdx = idx;
					break;
				}
	}

	//Debug ( "addNormalItem 1" @ newItem.Name @ FindIdx ) ;
	if( FindIdx > -1 )	
		detailItemWindow.SetItem( FindIdx, newItem );		
	else
		detailItemWindow.AddItem( newItem );
}


function QuestInvenAddItem( ItemInfo newItem )
{
	local int idx;
	local int CurLimit;
	local int FindIdx;
	
	local ItemInfo curItem;	

	FindIdx = -1;
	
	if ( bIsSavedLocalItemIdx ) FindIdx = getLocalItemOrderByItemWindow( m_questItem, newItem.ID.serverID, -1 ) ;	
	else if( m_questItem.GetItem( newItem.Order, curItem ) )
		if( !IsValidItemID( curItem.ID ) ) FindIdx = newItem.Order ;	

	if( FindIdx < 0 )
	{
		CurLimit = m_questItem.GetItemNum();
		for( idx=0; idx<CurLimit; idx++ )
		{
			if( m_questItem.GetItem( idx, curItem ) )
			{
				if( !IsValidItemID( curItem.ID ) )
				{
					FindIdx = idx;
					break;
				}
			}
		}
	}
	
	if( FindIdx > -1 )
		m_questItem.SetItem( FindIdx, newItem );
	else
		m_questItem.AddItem( newItem );

	m_QuestInvenCount++;
}

/********************************************************************************************
 *  
 * ******************************************************************************************/
// ?  
function handleAgathionEquip ( itemInfo a_info ) 
{
	local int agathionIndex ;

	agathionIndex = GetAgathionIndex(a_info.Id ) ;
		
	if (agathionIndex != -1)
	{
		m_equipItem[ EQUIPITEM_AGATHION_MAIN + agathionIndex ].Clear();
		m_equipItem[ EQUIPITEM_AGATHION_MAIN + agathionIndex ].AddItem( a_info );
		m_equipItem[ EQUIPITEM_AGATHION_MAIN + agathionIndex ].EnableWindow();
	}
}

// ? ? 
function EarItemUpdate()
{
	local int i;
	local int LEarIndex, REarIndex;

	LEarIndex = -1;
	REarIndex = -1;

	for( i = 0; i < m_EarItemList.Length; ++i )
	{
		switch( IsLOrREar( m_EarItemList[i].ID ) )
		{
		case -1:
			LEarIndex = i;
			break;
		case 0:
			m_EarItemList.Remove( i, 1 );
			break;
		case 1:
			REarIndex = i;
			break;
		}
	}

	if( -1 != LEarIndex )
	{
		//~ debug(" ?");
		m_equipItem[ EQUIPITEM_LEar ].Clear();
		m_equipItem[ EQUIPITEM_LEar ].AddItem( m_EarItemList[ LEarIndex ] );
	}

	if( -1 != REarIndex )
	{
		//~ debug(" ?");
		m_equipItem[ EQUIPITEM_REar ].Clear();
		m_equipItem[ EQUIPITEM_REar ].AddItem( m_EarItemList[ REarIndex ] );
	}
}

//  ?
function FingerItemUpdate()
{
	local int i;
	local int LFingerIndex, RFingerIndex;

	LFingerIndex = -1;
	RFingerIndex = -1;

	for( i = 0; i < m_FingerItemList.Length; ++i )
	{
		switch( IsLOrRFinger( m_FingerItemList[i].ID ) )
		{
		case -1:
			LFingerIndex = i;
			break;
		case 0:
			m_FingerItemList.Remove( i, 1 );
			break;
		case 1:
			RFingerIndex = i;
			break;
		}
	}

	if( -1 != LFingerIndex )
	{
		m_equipItem[ EQUIPITEM_LFinger ].Clear();
		m_equipItem[ EQUIPITEM_LFinger ].AddItem( m_FingerItemList[ LFingerIndex ] );
	}

	if( -1 != RFingerIndex )
	{
		m_equipItem[ EQUIPITEM_RFinger ].Clear();
		m_equipItem[ EQUIPITEM_RFinger ].AddItem( m_FingerItemList[ RFingerIndex ] );
	}
}

//  ?
function EquipItemUpdate( ItemInfo a_info )
{
	local ItemWindowHandle hItemWnd;
	local ItemInfo TheItemInfo;
	local bool ClearLHand;
	local ItemInfo RHand;
	local ItemInfo LHand;
	local ItemInfo Legs;
	local ItemInfo Gloves;
	local ItemInfo Feet;
	local ItemInfo Hair2;
	local int i;
	//~ local int j;
	local int decoIndex;

	local int jewelIndex;	
	
	switch( a_Info.SlotBitType )
	{
	case 1:		// SBT_UNDERWEAR
		hItemWnd = m_equipItem[ EQUIPITEM_Underwear ];
		break;
	case 2:		// SBT_REAR
	case 4:		// SBT_LEAR
	case 6:		// SBT_RLEAR
		for( i = 0; i < m_EarItemList.Length; ++i )
		{
			if( IsSameServerID(m_EarItemList[ i ].ID, a_Info.ID) )
			{
				m_EarItemList[ i ] = a_Info;
				break;
			}
		}

		//  ?  ?
		if( i == m_EarItemList.Length )
		{
			m_EarItemList.Length = m_EarItemList.Length + 1;
			m_EarItemList[m_EarItemList.Length-1] = a_Info;
		}

		hItemWnd = None;
		EarItemUpdate();
		break;
	case 8:		// SBT_NECK
		hItemWnd = m_equipItem[ EQUIPITEM_Neck ];
		break;
	case 16:	// SBT_RFINGER
	case 32:	// SBT_LFINGER
	case 48:	// SBT_RLFINGER
		for( i = 0; i < m_FingerItemList.Length; ++i )
		{
			if( IsSameServerID(m_FingerItemList[ i ].ID, a_Info.ID) )
			{
				m_FingerItemList[ i ] = a_Info;
				break;
			}
		}

		//  ?  ?
		if( i == m_FingerItemList.Length )
		{
			m_FingerItemList.Length = m_FingerItemList.Length + 1;
			m_FingerItemList[m_FingerItemList.Length-1] = a_Info;
		}

		hItemWnd = None;
		FingerItemUpdate();
		break;
	case 64:	// SBT_HEAD
		hItemWnd = m_equipItem[ EQUIPITEM_Head ];
		hItemWnd.EnableWindow();	
		break;
	case 128:	// SBT_RHAND
		hItemWnd = m_equipItem[ EQUIPITEM_RHand ];
		break;
	case 256:	// SBT_LHAND
		hItemWnd = m_equipItem[ EQUIPITEM_LHand ];
		hItemWnd.EnableWindow();
		break;
	case 512:	// SBT_GLOVES
		hItemWnd = m_equipItem[ EQUIPITEM_Gloves ];
		hItemWnd.EnableWindow();		
		break;
	case 1024:	// SBT_CHEST
		hItemWnd = m_equipItem[ EQUIPITEM_Chest ];			
		break;
	case 2048:	// SBT_LEGS
		hItemWnd = m_equipItem[ EQUIPITEM_Legs ];
		hItemWnd.EnableWindow();
		break;
	case 4096:	// SBT_FEET
		hItemWnd = m_equipItem[ EQUIPITEM_Feet ];
		hItemWnd.EnableWindow();
		break;
	case 8192:	// SBT_BACK		
		hItemWnd = m_equipItem[ EQUIPITEM_Cloak ];		
		hItemWnd.EnableWindow();
		break;	
	case 16384:	// SBT_RLHAND
		hItemWnd = m_equipItem[ EQUIPITEM_RHand ];
		ClearLHand = true;	
		// RHand Bow ?, LHand ? ?  ? ? ? - NeverDie
		if( IsBowOrFishingRod( a_Info ) )		
			if( m_equipItem[ EQUIPITEM_LHand ].GetItem( 0, TheItemInfo ) )			
				if( IsArrow( TheItemInfo ) )
					ClearLHand = false;			
				
		//      ? ?. 
		if( IsBowOrFishingRod( a_Info ) )
			if( m_equipItem[ EQUIPITEM_LHand ].GetItem( 0, TheItemInfo ) )
				if( IsArrow( TheItemInfo ) )
					ClearLHand = false;		
		
		//LRHAND ? ex1 , ex2  ? ?  ??  ?? ???. ;; -innowind
		if( ClearLHand )	
		{
			if(Len(a_Info.IconNameEx1) !=0)
			{
				RHand = a_info;
				LHand = a_info;				
				RHand.IconIndex = 1;
				LHand.IconIndex = 2;
				//RHand.IconName = a_Info.IconNameEx1;
				//LHand.IconName = a_Info.IconNameEx2;
				m_equipItem[ EQUIPITEM_RHand ].Clear();
				m_equipItem[ EQUIPITEM_RHand ].AddItem( RHand );
				//m_equipItem[ EQUIPITEM_RHand ].DisableWindow();
				m_equipItem[ EQUIPITEM_LHand ].Clear();
				m_equipItem[ EQUIPITEM_LHand ].AddItem( LHand );
				m_equipItem[ EQUIPITEM_LHand ].DisableWindow();
				hItemWnd = None;	//  ?  ? ?  ?.
			}
			// ?? ? ? ? .
			else	
			{
				m_equipItem[ EQUIPITEM_LHand ].Clear();
				m_equipItem[ EQUIPITEM_LHand ].AddItem( a_Info );
				m_equipItem[ EQUIPITEM_LHand ].DisableWindow();				
			}
			
		}
		break;
	case 32768:	// SBT_ONEPIECE
		// 
		hItemWnd = m_equipItem[ EQUIPITEM_Chest ];
		a_Info.IconIndex = 1; //  
		// 
		Legs = a_Info;
		
		Legs.IconIndex = 2; //   ??. 
		m_equipItem[ EQUIPITEM_Legs ].Clear();
		m_equipItem[ EQUIPITEM_Legs ].AddItem( Legs );
		m_equipItem[ EQUIPITEM_Legs ].DisableWindow();
		break;
	case 65536:	// SBT_HAIR
		hItemWnd = m_equipItem[ EQUIPITEM_Hair ];
		break;
	case 131072:	// SBT_ALLDRESS
		hItemWnd = m_equipItem[ EQUIPITEM_Chest ];
		Hair2 = a_info;	// head ?  ?  hair2 ??. - innowind
		Gloves = a_info;
		Legs = a_info;
		Feet = a_info;
		Hair2.IconName = a_Info.IconNameEx1;
		Gloves.IconName = a_Info.IconNameEx2;
		Legs.IconName = a_Info.IconNameEx3;
		Feet.IconName = a_Info.IconNameEx4;
		m_equipItem[ EQUIPITEM_Head ].Clear();
		m_equipItem[ EQUIPITEM_Head ].AddItem( Hair2 );
		m_equipItem[ EQUIPITEM_Head ].DisableWindow();
		m_equipItem[ EQUIPITEM_Gloves ].Clear();
		m_equipItem[ EQUIPITEM_Gloves ].AddItem( Gloves );
		m_equipItem[ EQUIPITEM_Gloves ].DisableWindow();
		m_equipItem[ EQUIPITEM_Legs ].Clear();
		m_equipItem[ EQUIPITEM_Legs ].AddItem( Legs );
		m_equipItem[ EQUIPITEM_Legs ].DisableWindow();
		m_equipItem[ EQUIPITEM_Feet ].Clear();
		m_equipItem[ EQUIPITEM_Feet ].AddItem( Feet );
		m_equipItem[ EQUIPITEM_Feet ].DisableWindow();
		break;
	case 262144:	// SBT_HAIR2
		hItemWnd = m_equipItem[ EQUIPITEM_Hair2 ];
		hItemWnd.EnableWindow();
		break;
	case 524288:	// SBT_HAIRALL
		hItemWnd = m_equipItem[ EQUIPITEM_Hair ];		
		m_equipItem[ EQUIPITEM_Hair2 ].Clear();
		m_equipItem[ EQUIPITEM_Hair2 ].AddItem( a_info );
		m_equipItem[ EQUIPITEM_Hair2 ].DisableWindow();
		break;
	case 1048576: //SBT_RBracelet
		hItemWnd = m_equipItem[ EQUIPITEM_RBracelet ];
		m_equipItem[ EQUIPITEM_RBracelet ].Clear();
		m_equipItem[ EQUIPITEM_RBracelet ].AddItem( a_info );
		m_equipItem[ EQUIPITEM_RBracelet ].EnableWindow();	
		break;	
	case 4194304:	//SBT_Deco1;			
		decoIndex = GetDecoIndex(a_info.Id);	
		if (decoIndex != -1)
		{
			m_equipItem[ EQUIPITEM_Deco1 + decoIndex ].Clear();
			m_equipItem[ EQUIPITEM_Deco1 + decoIndex ].AddItem( a_info );
			m_equipItem[ EQUIPITEM_Deco1 + decoIndex ].EnableWindow();
		}
		break;
	case 268435456:
		hItemWnd = m_equipItem[ EQUIPITEM_Waist ];
		break;

	case 536870912: //Brooch  

		m_equipItem_Brooch.Clear();
		m_equipItem_Brooch.AddItem( a_info );
		m_equipItem_Brooch.EnableWindow();
		m_BroochEquiped.ShowWindow();

		hItemWnd = m_equipItem[ EQUIPITEM_Brooch ];
		m_equipItem[ EQUIPITEM_Brooch ].Clear();
		m_equipItem[ EQUIPITEM_Brooch ].AddItem( a_info );
		m_equipItem[ EQUIPITEM_Brooch ].EnableWindow();
		break;

	case 1073741824:	//Brooch_Jewel1;	
		jewelIndex = GetJewelIndex(a_info.Id); /// jewel api ?	
		
		if (jewelIndex != -1)
		{
			m_equipItem[ EQUIPITEM_Jewel1 + jewelIndex ].Clear();
			m_equipItem[ EQUIPITEM_Jewel1 + jewelIndex ].AddItem( a_info );
			m_equipItem[ EQUIPITEM_Jewel1 + jewelIndex ].EnableWindow();
		}
		break;
	// 16 12 ?  
	/* case  2097152: 	 //SBT_LBracelet
		hItemWnd = m_equipItem[ EQUIPITEM_LBracelet ];
		m_equipItem[ EQUIPITEM_LBracelet ].Clear();
		m_equipItem[ EQUIPITEM_LBracelet ].AddItem( a_info );
		m_equipItem[ EQUIPITEM_LBracelet ].EnableWindow();		
		// Updates Talisman Item slot activation when the Bracelet slot has not equipped. 
		//~ if (!m_equipItem[ EQUIPITEM_Deco1 ].IsEnableWindow())
		//~ {
		//~ UpdateTalismanSlotActivation();
		//~ }
	break;*/
	case 2097152:	//? ;	
		//~ debug (" ?" @ a_info.ItemType );	
		hItemWnd = m_equipItem[ EQUIPITEM_LBracelet ];
		m_equipItem[ EQUIPITEM_LBracelet ].Clear();
		m_equipItem[ EQUIPITEM_LBracelet ].AddItem( a_info );
		m_equipItem[ EQUIPITEM_LBracelet ].EnableWindow();
		break;
	//?  
	case 206158430208 : 
		handleAgathionEquip( a_info ) ;		 		
		break;
	}
	
	if( None != hItemWnd )
	{
		hItemWnd.Clear();	
		hItemWnd.AddItem( a_Info );		
	}
	
}

// ? 
function UpdatePremiumHennaInfo(bool clear)
{
	local int HennaID;
	local int IsActive;
	local ItemInfo HennaItemInfo;
	local bool hennacheck;
	
	//branch121212
	m_hPremiumHennaItemWindow.Clear(); //branch121212

	if( clear || bIsPremiumHennaSlot == false ) //branch GD35_0828 2014-2-10 luciper3 -    ? ?.
		return;
	
	if( class'HennaAPI'.static.GetPremiumHennaInfo( HennaID, IsActive ) )
	{
		hennacheck = class'UIDATA_HENNA'.static.GetItemCheck(HennaID);
		if( hennacheck )
		{
			HennaItemInfo.Name = class'UIDATA_HENNA'.static.GetItemNameS( HennaID );
			HennaItemInfo.AdditionalName = class'UIDATA_HENNA'.static.GetAddtionNameS( HennaID );
			HennaItemInfo.Description = class'UIDATA_HENNA'.static.GetDescriptionS( HennaID );
			HennaItemInfo.IconName = class'UIDATA_HENNA'.static.GetIconTexS( HennaID );
			HennaItemInfo.CurrentPeriod = class'HennaAPI'.static.GetPremiumHennaPeriod();
		}
			
		if( 0 == IsActive )
			HennaItemInfo.bDisabled = 1;
		else
			HennaItemInfo.bDisabled = 0;

		m_hPremiumHennaItemWindow.AddItem( HennaItemInfo );	
	}
}

// 
function UpdateHennaInfo()
{
	local int i;
	local int HennaInfoCount;
	local int HennaID;
	local int IsActive;
	local ItemInfo HennaItemInfo;
	local UserInfo PlayerInfo;
	local int ClassStep;
	local bool hennacheck; //branch121212	

	if( GetPlayerInfo( PlayerInfo ) )
	{
		ClassStep = GetClassStep( PlayerInfo.nSubClass );
		//debug("ClassStep: " @ ClassStep);
		switch( ClassStep )
		{
			case 1:
			case 2:
			case 3:
			case 4:
			case 5:
				    m_hHennaItemWindow.SetRow( ClassStep );
				    break;

			default:
				    m_hHennaItemWindow.SetRow( 0 );
				    break;
		}
	}

	m_hHennaItemWindow.Clear();

	HennaInfoCount = class'HennaAPI'.static.GetHennaInfoCount();
	
	if( HennaInfoCount > ClassStep )
		HennaInfoCount = ClassStep;


	for( i = 0; i < HennaInfoCount; ++i )
	{
		if( class'HennaAPI'.static.GetHennaInfo( i, HennaID, IsActive ) )
		{
			hennacheck = class'UIDATA_HENNA'.static.GetItemCheck(HennaID);
			if( hennacheck )
			{
				HennaItemInfo.Name = class'UIDATA_HENNA'.static.GetItemNameS( HennaID );
				HennaItemInfo.Description = class'UIDATA_HENNA'.static.GetDescriptionS( HennaID );
				HennaItemInfo.IconName = class'UIDATA_HENNA'.static.GetIconTexS( HennaID );
			}

			if( 0 == IsActive )
				HennaItemInfo.bDisabled = 1;
			else
				HennaItemInfo.bDisabled = 0;

			m_hHennaItemWindow.AddItem( HennaItemInfo );			
		}
	}
}

//  ?  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function HandleUpdateUserEquipSlotInfo()
{
	EarItemUpdate();
	FingerItemUpdate();
	UpdateTalismanSlotActivation();

	UpdateJewelSlotActivation();//bm
	UpdateAgathionSlotActivation();

 	//UpdateCloakSlotActivation();
}


/********************************************************************************************
 *  
 * ******************************************************************************************/
//   ?,   
function handleRequestUnequipItem( String DragSrcName, itemID infoID, int64 slotbitType )
{	
	local string  tmpSlotbitType;

	tmpSlotbitType = "";

	//Debug("getEquipItemSlotBit" @ DragSrcName);
	if ( -1 != InStr( DragSrcName, "Talisman" ) )
	{		
		//Debug(right ( DragSrcName, 1  ));
		switch ( right ( DragSrcName, 1 ))
		{
			case "1":
				tmpSlotbitType = "4194304";
			break;
			case "2":
				tmpSlotbitType = "8388608";
			break;
			case "3":
				tmpSlotbitType = "16777216";
			break;
			case "4":
				tmpSlotbitType = "33554432";
			break;
			case "5":
				tmpSlotbitType = "67108864";
			break;
			case "6":
				tmpSlotbitType = "134217728";
			break;
		}
	}
	else if ( -1 != InStr( DragSrcName, "Jewel" )  )
	{
		//Debug( right ( DragSrcName, 1  ));
		switch ( right ( DragSrcName, 1 ))
		{
			case "1":
				//Debug("1");
				tmpSlotbitType = "1073741824";
			break;
			case "2":
				//Debug("2");
				tmpSlotbitType = "2147483648";
			break;
			case "3":
				//Debug("3");
				tmpSlotbitType = "4294967296";
			break;
			case "4":
				//Debug("4");
				tmpSlotbitType = "8589934592";
			break;
			case "5":
				//Debug("5");
				tmpSlotbitType = "17179869184";
			break;
			case "6":
				//Debug("6");
				tmpSlotbitType = "34359738368";
			break;
		}
	}	
	else if ( -1 != InStr( DragSrcName, "Agathion" ) )
		tmpSlotbitType =  getAgathionSlotBitTypeString ( right ( DragSrcName, 1 ) ) ;
	
	if ( tmpSlotbitType == "" ) RequestUnequipItem(infoID, slotbitType);
	else RequestUnequipItem(infoID, INT64(tmpSlotbitType));
}

function EquipItemDelete( ItemID sID )
{
	local int i;
	local int Index;
	local ItemInfo TheItemInfo;

	//TooltipItem.name = "HIHI";
	//TooltipItem.IconName = "L2ui_ct1.emptyBtn";
	//ClearItemID( TooltipItem.ID );

	//GetTextureHandle( m_WindowName $ ".EquipItem_tooltip" ).ShowWindow(); 
	//GetTextureHandle( m_WindowName $ ".EquipItem_tooltip" ).EnableWindow(); 
	//GetTextureHandle( m_WindowName $ ".EquipItem_tooltip" ).SetTextureCtrlType( ETextureCtrlType.TCT_Control);
	//GetTextureHandle( m_WindowName $ ".EquipItem_tooltip" ).SetTooltipCustomType(MakeTooltipSimpleText("asdfassdf"));

	for( i = 0; i < EQUIPITEM_Max; ++i )
	{
		Index = m_equipItem[ i ].FindItem( sID );	// ServerID
		if( -1 != Index )
		{
			m_equipItem[ i ].Clear();

			//ttp 63832 ?  ?  enable ?
			m_equipItem[ i ].EnableWindow();

			//m_equipItem[ i ].HideWindow();
			//m_equipItem[ i ].AddItem( TooltipItem );
			//m_equipItem[ i ].DisableWindow();			

			// ?  , ? ?  ???.
			if( i == EQUIPITEM_LHand )
			{
				if( m_equipItem[ EQUIPITEM_RHand ].GetItem( 0, TheItemInfo ) )
				{
					if( TheItemInfo.SlotBitType == 16384 )
					{
						m_equipItem[ EQUIPITEM_LHand ].Clear();
						m_equipItem[ EQUIPITEM_LHand ].AddItem( TheItemInfo );
						m_equipItem[ EQUIPITEM_LHand ].DisableWindow();
					}
					
				}
			}
			//?  
			else if ( i == EQUIPITEM_Brooch ) 
			{
				m_equipItem_brooch.Clear();				
				m_BroochEquiped.HideWindow();
			}
		}
	}
}

/********************************************************************************************
 *  
 * ******************************************************************************************/
function InvenDelete( ItemInfo item )
{
	local int FindIdx;
	local int DetailFindIdx;
	local ItemInfo ClearItem;

	local itemWindowHandle detailItemWindow;

	detailItemWindow = getItemWindowHandleByItemType( item );
	
	ClearItemID( ClearItem.ID );
	
	// ?? ? ? 
	ClearItem.IconName = "L2ui_ct1.emptyBtn";
	FindIdx = m_invenItem.FindItem( item.ID );
	DetailFindIdx = detailItemWindow.FindItem( item.ID );

	//Debug("InvenDelete" @ FindIdx @  DetailFindIdx);
	if( FindIdx != -1 )
	{
		m_invenItem.SetItem( FindIdx, ClearItem );
		detailItemWindow.SetItem( DetailFindIdx, ClearItem );
		m_NormalInvenCount--;
	}
}

function QuestInvenDelete( ItemInfo item )
{
	local int FindIdx;
	local ItemInfo ClearItem;

	FindIdx = m_questItem.FindItem( item.ID );
	if( FindIdx != -1 )
	{
		// ?    ??.
		m_questItem.DeleteItem(FindIdx);
		m_QuestInvenCount--;

		ClearItemID( ClearItem.ID );
		ClearItem.IconName = "L2ui_ct1.emptyBtn";
		m_questItem.AddItem(ClearItem);		
	}
}

/********************************************************************************************
 *    ?
 * ******************************************************************************************/
function HandleClear()
{
	// tt 61481      ?   ??.
	if ( m_hOwnerWnd.IsShowWindow() ) saveLocalItemOrder();	

	InvenClear();
	invenItem_1Clear();
	invenItem_2Clear();
	invenItem_3Clear();
	invenItem_4Clear();
	QuestInvenClear();
	EquipItemClear();
	
	m_EarItemList.Length = 0;
	m_FingerItemLIst.Length = 0;
	m_DecoItemList.Length = 0;

	InvenLimitUpdate();

	bIsQuestItemList = false;
}

//   ? 
function EquipItemClear()
{
	local int i;

	for( i = 0; i < EQUIPITEM_Max; ++i )
		m_equipItem[ i ].Clear();

	m_equipItem_Brooch.Clear();
	m_BroochEquiped.HideWindow();
}

// ? ? ?
function InvenClear()
{	
	m_invenItem.Clear();	
	m_NormalInvenCount = 0;
}

function QuestInvenClear()
{	
	m_questItem.Clear();
	m_QuestInvenCount = 0;
}

function invenItem_1Clear()
{
	m_invenItem_1.Clear();
}

function invenItem_2Clear()
{
	m_invenItem_2.Clear();
}

function invenItem_3Clear()
{
	m_invenItem_3.Clear();
}

function invenItem_4Clear()
{
	m_invenItem_4.Clear();
}

/********************************************************************************************
 *  ? 
 * ******************************************************************************************/
//   local   .
//  ?  ?   ? 
function saveLocalItemOrder() 
{
	local int  i ;	
	
	bIsSavedLocalItemIdx = true;
	//Debug ( "saveLocalItemOrder" @ itemSwapedServerID.length ) ;
	for ( i = 0 ; i < m_invenItem.GetItemNum() ; i ++ ) 
	{		
		saveServerID ( m_invenItem, i, itemSwapedServerID, itemSwapedIdx ) ; 		
		saveServerID ( m_invenItem_1, i, itemSwapedServerID_1, itemSwapedIdx_1 ) ; 		
		saveServerID ( m_invenItem_2, i, itemSwapedServerID_2, itemSwapedIdx_2 ) ; 		
		saveServerID ( m_invenItem_3, i, itemSwapedServerID_3, itemSwapedIdx_3 ) ; 		
		saveServerID ( m_invenItem_4, i, itemSwapedServerID_4, itemSwapedIdx_4 ) ; 				
	}

	for ( i = 0 ; i < m_questItem.GetItemNum() ; i ++ ) 		
		saveServerID ( m_questItem, i, itemSwapedServerID_q, itemSwapedIdx_q ) ; 
}

function saveServerID ( ItemWindowHandle targetWindow, int idx,  out array<int> serverIDList, out array<int> SwapedIdx ) 
{		
	local iteminfo invenInfo;	

	targetWindow.GetItem( idx , invenInfo );
	
	if ( invenInfo.ID.serverID != -1 ) 
	{
		invenInfo.Order = idx;
		idx = serverIDList.length;
		serverIDList.length = serverIDList.length  + 1 ;
		serverIDList[ idx ] = invenInfo.ID.serverID;
		SwapedIdx[ idx ] = invenInfo.Order;

		//Debug (  "saveServerID" @ invenInfo.Name @  invenInfo.Order @ targetWindow.GetWindowName()) ;
	}
}


//  order ?
function int getLocalItemOrder( int serverID, array<int> serverIDList, array<int> SwapedIdx, int defaultOrder  ) 
{
	local int i ;
	for ( i = 0 ; i < serverIDList.Length ; i ++ )  	
	{		
		if ( serverIDList[ i ] == serverID ) 
			return SwapedIdx[ i ];
	}

	return defaultOrder;
}

function int getLocalItemOrderByItemWindow ( itemWindowHandle targetWindow, int serverID, int defaultOrder ) 
{
	switch ( targetWindow ) 
	{				
		case m_invenItem_1 :
			return getLocalItemOrder( serverID, itemSwapedServerID_1, itemSwapedIdx_1, defaultOrder ) ;		
		case m_invenItem_2 :
			return getLocalItemOrder( serverID, itemSwapedServerID_2, itemSwapedIdx_2, defaultOrder ) ;		
		case m_invenItem_3 :
			return getLocalItemOrder( serverID, itemSwapedServerID_3, itemSwapedIdx_3, defaultOrder ) ;		
		case m_invenItem_4 :
			return getLocalItemOrder( serverID, itemSwapedServerID_4, itemSwapedIdx_4, defaultOrder ) ;		
		case m_questItem :			
			return getLocalItemOrder( serverID, itemSwapedServerID_q, itemSwapedIdx_q, defaultOrder ) ;
	}
	return defaultOrder ;
}

//  ?   .
function SaveInventoryOrder()
{
	local int idx;
	local int InvenLimit;

	local ItemInfo item;
	local array<ItemID> IDList;
	local array<int> OrderList;
	
	InvenLimit = m_invenItem.GetItemNum();
	
	for( idx=0; idx<InvenLimit; idx++ )
	{
		if( m_invenItem.GetItem( idx, item ) )
			if( IsValidItemID( item.ID ) )
			{
				IDList.Insert(IDList.Length, 1);
				IDList[IDList.Length-1] = item.ID;
				
				OrderList.Insert(OrderList.Length, 1);
				OrderList[OrderList.Length-1] = item.Order;
			}
	}
	
	if( IDList.Length > 0 )
		RequestSaveInventoryOrder( IDList, OrderList );

	//  6, 12 ? ??    ?.
	SetOptionInt( "Game", "ItemInventoryCol",  currentInvenCol);

	// ??   false  ?.	
	bIsSavedLocalItemIdx = false;
	itemSwapedIdx.Length = 0 ;
	itemSwapedIdx_1.Length = 0 ;
	itemSwapedIdx_2.Length = 0 ;
	itemSwapedIdx_3.Length = 0 ;
	itemSwapedIdx_4.Length = 0 ;
	itemSwapedIdx_q.Length = 0 ;
	itemSwapedServerID.Length = 0 ;
	itemSwapedServerID_1.Length = 0 ;
	itemSwapedServerID_2.Length = 0 ;
	itemSwapedServerID_3.Length = 0 ;
	itemSwapedServerID_4.Length = 0 ;
	itemSwapedServerID_q.Length = 0 ;
}

/********************************************************************************************
 * ? ? 
 * ******************************************************************************************/

//  ?
function bool IsEquipItem( out ItemInfo info )
{
	return info.bEquipped;
}

// ?  ??
function bool IsQuestItem( out ItemInfo info )
{
	return EItemtype(info.ItemType) == ITEM_QUESTITEM;
}

// ? ??
function int IsLOrREar( ItemID sID )
{
	local ItemID LEar;
	local ItemID REar;
	local ItemID LFinger;
	local ItemID RFinger;

	GetAccessoryItemID( LEar, REar, LFinger, RFinger );

	if( IsSameServerID(sID, LEar) )
		return -1;
	else if( IsSameServerID(sID, REar) )
		return 1;
	else
		return 0;
}

//  ??
function int IsLOrRFinger( ItemID sID )
{
	local ItemID LEar;
	local ItemID REar;
	local ItemID LFinger;
	local ItemID RFinger;

	GetAccessoryItemID( LEar, REar, LFinger, RFinger );

	if( IsSameServerID(sID, LFinger) )
		return -1;
	else if( IsSameServerID(sID, RFinger) )
		return 1;
	else
		return 0;
}

//  ??
function bool IsBowOrFishingRod( ItemInfo a_Info )
{
	 //~ debug(" ??"@  a_Info.WeaponType);
	// ?, , ??,  ??
	if( 6 == a_Info.WeaponType || 10 == a_Info.WeaponType || 12 == a_Info.WeaponType || 17 == a_Info.WeaponType)	
		return true;

	return false;
}

// ? ??
function bool IsArrow( ItemInfo a_Info )
{
	return a_Info.bArrow;
}

// ? ? ?? ??
function bool isDragSrcInventory ( string DragSrcName )
{
	switch ( DragSrcName ) 
	{
		case "InventoryItem"   : 
		case "QuestItem"   : 
		case "PetInvenWnd"   : 
		case "InventoryItem_1"   : 
		case "InventoryItem_2"   : 
		case "InventoryItem_3"   : 
		case "InventoryItem_4"   : 
			return true;
	}
	
	if ( -1 != InStr( DragSrcName, "EquipItem" ) ) return true ;

	return false;	
}

/*
*  ?  
//   ????? 
function INT64 IsDecoItem( ItemInfo a_Info )	// INT -> INT64, Jewel ? - by y2jinc (2013. 9. 2)
{
	return a_Info.SlotBitType;
}

//?, ?, ??, ?, , ?, ?, ?, ?? ?   ? ?
//? ? ?  ?  --;; - innowind
function bool IsShowInventoryWndUponEvent()
{
	local WindowHandle m_warehouseWnd;
	local WindowHandle m_privateShopWnd;
	local WindowHandle m_tradeWnd;
	local WindowHandle m_shopWnd;
	local WindowHandle m_multiSellWnd;
	local WindowHandle m_deliverWnd;
	local PrivateShopWnd m_scriptPrivateShopWnd;
	local WindowHandle m_PostBoxWnd, m_PostWriteWnd, m_PostDetailWnd_General, m_PostDetailWnd_SafetyTrade; 

	local WindowHandle m_sellingAgencyWnd;
	
	m_warehouseWnd = GetWindowHandle( "WarehouseWnd" );					//?, ?, ??
	m_privateShopWnd = GetWindowHandle( "PrivateShopWnd" );					//?, ?
	m_tradeWnd = GetWindowHandle( "TradeWnd" );							//?
	m_shopWnd = GetWindowHandle( "ShopWnd" );							//, ?
	m_multiSellWnd = GetWindowHandle( "MultiSellWnd" );						//, ?
	m_deliverWnd = GetWindowHandle( "DeliverWnd" );							//?
	m_scriptPrivateShopWnd = PrivateShopWnd( GetScript("PrivateShopWnd") );

	m_PostBoxWnd = GetWindowHandle( "PostBoxWnd" );
	m_PostWriteWnd = GetWindowHandle( "PostWriteWnd" );
	m_PostDetailWnd_General = GetWindowHandle( "PostDetailWnd_General" );
	m_PostDetailWnd_SafetyTrade = GetWindowHandle( "PostDetailWnd_SafetyTrade" );

	m_sellingAgencyWnd = GetWindowHandle( "SellingAgencyWnd" ); // ??


	if( m_warehouseWnd.IsShowWindow() )
		return false;

	if( m_warehouseWnd.IsShowWindow() )
		return false;

	if( m_tradeWnd.IsShowWindow() )
		return false;
	
	if( m_shopWnd.IsShowWindow() )
		return false;
	
	if( m_multiSellWnd.IsShowWindow() )
		return false;
	
	if( m_deliverWnd.IsShowWindow() )
		return false;
	
	if( m_privateShopWnd.IsShowWindow() && m_scriptPrivateShopWnd.m_type == PT_Sell )
		return false;


	if (m_PostBoxWnd.IsShowWindow() || m_PostWriteWnd.IsShowWindow() || m_PostDetailWnd_General.IsShowWindow() || m_PostDetailWnd_SafetyTrade.IsShowWindow() )
		return false;

	if( m_sellingAgencyWnd.IsShowWindow() )
		return false;
	
	return true;
}
*/


/********************************************************************************************
 * data
 * ******************************************************************************************/
//   
function int EquipItemGetItemNum()
{
	local int i;
	local int ItemNum;

	for( i = 0; i < EQUIPITEM_Max; ++i )
	{
		if(m_equipItem[ i ].IsEnableWindow())	// ? ? . 
		{
			ItemNum = ItemNum + m_equipItem[ i ].GetItemNum();
		}
	}

	return ItemNum;
}

//  ?   ? ?
function bool EquipItemFind( ItemID sID )
{
	local int i;
	local int Index;

	for( i = 0; i < EQUIPITEM_Max; ++i )
	{
		Index = m_equipItem[ i ].FindItem( sID );	// ServerID
		if( -1 != Index )
			return true;
	}

	return false;
}


// ?? ?? ?? ?  
function int getCurrentInventoryItemCount()
{
	return pInventoryItemCount;
}

//?? ??    ?  
function bool getInventoryItemWndName(string str)
{
	local int i;
	for(i = 0; i <= TAB_LENGTH; ++i)
	{
		if(i == 0)
		{
			if(("InventoryItem") == str)
			{
				return true;
			}
		}
		else if(("InventoryItem_" $ i) == str)
		{
			return true;
		}
	}
	return false;
}

// ??,  ??  ,    . (2014.03.18, ? ?  )
// onlyUseClassID = true  serverID   ?  classID  ?. ( ? ? ?)
function bool getInventoryItemInfo(ItemID id, out ItemInfo InvenItemInfo, optional bool onlyUseClassID)
{
	local bool bHasItem;
	local int i, index;
	local ItemInfo tempOutItemInfo, tmpItemInfo;

	bHasItem = false;

	//   findItem   ? ? ? ??, classID  ?? ?.
	if (onlyUseClassID)	index = m_invenItem.FindItemByClassID(id);
	else index = m_invenItem.FindItem(id);
	
	if (index > -1) { m_invenItem.GetItem(index, InvenItemInfo); bHasItem = true; }

	// ?  
	index = m_questItem.FindItem(id);
	if (index > -1) { m_questItem.GetItem(index, InvenItemInfo); bHasItem = true; }

	//   
	for (i = 0; i < EQUIPITEM_Max; i++)
	{
		// index = m_equipItem[i].FindItem(id);
		if (onlyUseClassID)	index = m_equipItem[i].FindItemByClassID(id);
		else index = m_equipItem[i].FindItem(id);

		if (index > -1) 
		{
			m_equipItem[i].GetItem(index, tempOutItemInfo);

			switch ( i ) 
			{
				//       
				case EQUIPITEM_LHand :
					m_equipItem[EQUIPITEM_RHand].GetItem(0,tmpItemInfo);
				break;
				//  ? 1    
				case EQUIPITEM_Hair2:
					m_equipItem[EQUIPITEM_Hair].GetItem(0,tmpItemInfo);		
				break;
			}

			
			// 2015-06-03  ?  ? ? ? ? ? .
			if ( tempOutItemInfo.ID.serverID == tmpItemInfo.ID.serverID ) continue;
			// ..
			//if ( InvenItemInfo.ID.serverID == tmpItemInfo.ID.serverID ) continue;

			InvenItemInfo = tempOutItemInfo;
			bHasItem = true;
			break;
		}
	}

	return bHasItem;
}

// ? ??  ? ??
function INT64 getItemCountByClassID(int classID)
{
	local int i, itemNum;
	local INT64 totalCount;
	local ItemInfo tempOutItemInfo, tmpItemInfo, info;
	local ItemID ID;

	ID.ClassID = classID;

	class'UIDATA_ITEM'.static.GetItemInfo( ID, info );

	//  ??
	if(IsStackableItem( info.ConsumeType ))
	{
		if(getInventoryItemInfo(ID, tempOutItemInfo, true))
		{
			return tempOutItemInfo.ItemNum;
		}
	}
	else
	{
		// ?? Total
		totalCount = getItemWindowCountByClassID(classID, m_invenItem);
		
		// ?  
		totalCount = totalCount + getItemWindowCountByClassID(classID, m_questItem);
		
		//   
		for (i = 0; i < EQUIPITEM_Max; i++)
		{
			itemNum = m_equipItem[i].GetItemNum();
			
			if ( itemNum == 0 ) continue;

			m_equipItem[i].GetItem(0, tempOutItemInfo);

			switch ( i ) 
			{
				//       
				case EQUIPITEM_LHand :
					m_equipItem[EQUIPITEM_RHand].GetItem(0,tmpItemInfo);
				break;
				//  ? 1    
				case EQUIPITEM_Hair2:
					m_equipItem[EQUIPITEM_Hair].GetItem(0,tmpItemInfo);		
				break;
			}

			if ( tempOutItemInfo.ID.serverID != tmpItemInfo.ID.serverID ) 
			{
				totalCount = totalCount + getItemWindowCountByClassID(classID, m_equipItem[i]);
			}
		}
	}

	return totalCount;
}

//  ? ? ClassID   .
function INT64 getItemWindowCountByClassID(int ClassID, ItemWindowHandle targetItemWindow)
{
	local int i, cnt, index, totalItemNum;
	local ItemInfo tmInfo, tempOutItemInfo;
	
	local ItemInfo info;
	local ItemID ID;

	ID.ClassID = ClassID;

	class'UIDATA_ITEM'.static.GetItemInfo( ID, info );

	//  ??
	if(IsStackableItem( info.ConsumeType ))
	{
		index = m_invenItem.FindItemByClassID(ID);
		
		if(getInventoryItemInfo(ID, tempOutItemInfo, true))
		{
			return tempOutItemInfo.ItemNum;
		}
	}

	totalItemNum = targetItemWindow.GetItemNum();
	for (i = 0; i < totalItemNum; i++)
	{
		targetItemWindow.GetItem(i, tmInfo);

		if(tmInfo.Id.ClassID == ClassID)
		{
			cnt++;
		}
	}
	return cnt;
}


//      ?  ?.
// bExceptionEquipItem = true    ?.
function array<ItemInfo> getInventoryAllItemArray(optional bool bExceptionEquipItem)
{
	local int itemNum, index; //,i ;

	local array<ItemInfo> itemArray;

	local ItemInfo InvenItemInfo ;//, tmpItemInfo;//, leftWeaponInfo, nullInfo;

	itemNum = m_invenItem.GetItemNum();

	for (index = 0; index < itemNum; index++)
	{
		m_invenItem.GetItem(index, InvenItemInfo);

		if (InvenItemInfo.Id.ClassID <= 0) continue;
		itemArray.Length = itemArray.Length + 1;
		itemArray[ itemArray.Length - 1 ] = InvenItemInfo;
	}
	
	if (bExceptionEquipItem == false)
	{
		//  
		itemArray = L2Util(GetScript("L2Util")).pushItemInfoArray ( itemArray, getInventoryEquipItemArray());	
	}

	return itemArray;
}

// ? ? ?? 
function array<ItemInfo> getInventoryEquipItemArray()
{
	local int i, j ;//, itemNum ;

	local bool isSameItem;

	local array<ItemInfo> itemArray;

	local ItemInfo InvenItemInfo ;//, tmpItemInfo;
	
	// ?   (    ? ?  ? )    ? 
	m_equipItem[EQUIPITEM_Chest].GetItem( 0, InvenItemInfo  ) ;
	if ( IsValidItemID( InvenItemInfo.ID ) ) 
	{
		itemArray.Length = 1;
		itemArray[ 0 ] = InvenItemInfo;
	}

	//   
	for (i = 0; i < EQUIPITEM_Max; i++)
	{	
		ClearItemID( InvenItemInfo.ID );

		m_equipItem[i].GetItem(0, InvenItemInfo);
		
		if ( !IsValidItemID ( InvenItemInfo.id ) ) CONTINUE ;

		// TT 69146 : ?      ?  ?.
		// ?, ?, ?, , ? 
		isSameItem = false;

		for ( j = 0 ; j < itemArray.Length ; j ++ )
		{
			if ( IsSameServerID(itemArray[j].ID, InvenItemInfo.ID) )
			{	
				isSameItem = true;
				continue;
			}
		}

		if ( !isSameItem ) 
		{			
			itemArray.Length = itemArray.Length + 1;
			itemArray[ itemArray.Length - 1 ] = InvenItemInfo;			
		}		
	}

	return itemArray;
}


function int GetMyInventoryLimit()
{
	return m_MaxInvenCount;
}

function int GetQuestItemInventoryLimit()
{
	return m_MaxQuestItemInvenCount;
}

/********************************************************************************************
 * ?  ? ?
 * ******************************************************************************************/
// ?()     ?
function array<ItemInfo> getInventoryEnSoulExtractEnableItemArray()
{
	local int i, itemNum, index;

	local array<ItemInfo> itemArray;

	local ItemInfo InvenItemInfo;
	//local int enSoulNormalCount, enSoulBmCount;


	itemNum = m_invenItem.GetItemNum();

	for (index = 0; index < itemNum; index++)
	{
		m_invenItem.GetItem(index, InvenItemInfo);

		// ? ? 
		if (InvenItemInfo.Id.ClassID <= 0) continue;
		if (InvenItemInfo.itemType != EItemType.ITEM_WEAPON) continue;
		if ( InvenItemInfo.bSecurityLock ) continue;

		// ?   ?? ?  ??
		if(hasEnsoulOption(InvenItemInfo))
		{
			itemArray.Length = itemArray.Length + 1;
			itemArray[ itemArray.Length - 1 ] = InvenItemInfo;
		}
	}

	//   
	for (i = 0; i < EQUIPITEM_Max; i++)
	{
		itemNum = m_equipItem[i].GetItemNum();
		for (index = 0; index < itemNum; index++)
		{
			//   ,  ?    
			if (EQUIPITEM_LHand == i) continue;

			m_equipItem[i].GetItem(index, InvenItemInfo);

			// ? ? 
			if (InvenItemInfo.Id.ClassID <= 0) continue;
			if (InvenItemInfo.itemType != EItemType.ITEM_WEAPON) continue;  

			// ?   ?? ?  ??
			if(hasEnsoulOption(InvenItemInfo))
			{
				itemArray.Length = itemArray.Length + 1;
				itemArray[ itemArray.Length - 1 ] = InvenItemInfo;
			}
		}
	}

	return itemArray;
}


// ?    ?
function array<ItemInfo> getInventoryEnSoulEnableItemArray()
{
	local int i, itemNum, index;

	local array<ItemInfo> itemArray;

	local ItemInfo InvenItemInfo;
	local int enSoulNormalCount, enSoulBmCount;


	itemNum = m_invenItem.GetItemNum();

	for (index = 0; index < itemNum; index++)
	{
		m_invenItem.GetItem(index, InvenItemInfo);

		// ? ? 
		if (InvenItemInfo.Id.ClassID <= 0) continue;
		if (InvenItemInfo.itemType != EItemType.ITEM_WEAPON) continue;
		if ( InvenItemInfo.bSecurityLock ) continue;


		// ?  ?   		
		enSoulNormalCount = class'UIDATA_ENSOUL'.static.GetEnsoulSlotCount(InvenItemInfo.Id, EIST_NORMAL);   // ? ?  
		enSoulBmCount     = class'UIDATA_ENSOUL'.static.GetEnsoulSlotCount(InvenItemInfo.Id, EIST_BM);       //  ?  

		// ? ? 1 ?? ?  ? )
		if (enSoulNormalCount > 0 || enSoulBmCount > 0)
		{
			itemArray.Length = itemArray.Length + 1;
			itemArray[ itemArray.Length - 1 ] = InvenItemInfo;
		}
	}

	//   
	for (i = 0; i < EQUIPITEM_Max; i++)
	{
		itemNum = m_equipItem[i].GetItemNum();
		for (index = 0; index < itemNum; index++)
		{
			//   ,  ?    
			if (EQUIPITEM_LHand == i) continue;

			m_equipItem[i].GetItem(index, InvenItemInfo);


//			if ( InvenItemInfo.Id.ClassID > 0 ) Debug ( InvenItemInfo.Name @ InvenItemInfo.bSecurityLock ) ;

			// ? ? 
			if (InvenItemInfo.Id.ClassID <= 0) continue;
			if (InvenItemInfo.itemType != EItemType.ITEM_WEAPON) continue;  
			if ( InvenItemInfo.bSecurityLock ) continue;

			// ?  ?   
			enSoulNormalCount = class'UIDATA_ENSOUL'.static.GetEnsoulSlotCount(InvenItemInfo.Id, EIST_NORMAL);  // ? ?  
			enSoulBmCount     = class'UIDATA_ENSOUL'.static.GetEnsoulSlotCount(InvenItemInfo.Id, EIST_BM);      //  ?  

			// ? ? 1 ?? ?  ? )
			if (enSoulNormalCount > 0 || enSoulBmCount > 0)
			{
				itemArray.Length = itemArray.Length + 1;
				itemArray[ itemArray.Length - 1 ] = InvenItemInfo;
			}
		}
	}

	return itemArray;
}


// ?   ?
function array<ItemInfo> getInventoryEnSoulStoneArray()
{
	local int i, itemNum, index;

	local array<ItemInfo> itemArray;

	local ItemInfo InvenItemInfo;
	// local string tmpInfoStr;
	
	// local int enSoulNormalCount, enSoulBmCount;

	itemNum = m_invenItem.GetItemNum();

	// ?? ?
	for (index = 0; index < itemNum; index++)
	{
		m_invenItem.GetItem(index, InvenItemInfo);

		if (InvenItemInfo.ItemSubType == int(EEtcItemType.ITEME_ENSOUL_STONE))
		{
			itemArray.Length = itemArray.Length + 1;
			itemArray[ itemArray.Length - 1 ] = InvenItemInfo;
		}
	}

	//  ? ?
	for (i = 0; i < EQUIPITEM_Max; i++)
	{
		itemNum = m_equipItem[i].GetItemNum();
		for (index = 0; index < itemNum; index++)
		{
			m_equipItem[i].GetItem(index, InvenItemInfo);
			
			//  ?..
			if (InvenItemInfo.ItemSubType == int(EEtcItemType.ITEME_ENSOUL_STONE))
			{
				itemArray.Length = itemArray.Length + 1;
				itemArray[ itemArray.Length - 1 ] = InvenItemInfo;
			}
		}
	}

	return itemArray;
}


//#ifdef CT26P3
/********************************************************************************************
 * 
 * ******************************************************************************************/
function SortQuestItem()
{
	local int i, j;
	local int invenLimit;
	local ItemInfo item;	
	local itemInfo temp;
	local int numQuest;
	local Array<ItemInfo> QuestList;

	invenLimit = m_questItem.GetItemNum();

	// 1. ? 
	for (i = 0; i < invenLimit; i++ )
	{
		m_questItem.GetItem(i, item);

		if(!IsValidItemID(item.ID))
		{
			continue;
		}

		QuestList[numQuest] = item;
		numQuest = numQuest + 1;
	}

	m_questItem.Clear();
	
	ItemboxUpdate(m_questItem, GetQuestItemInventoryLimit() );

	for  ( i = 0 ;i < numQuest ; i++ ) 
	{
		for ( j = i ;j < numQuest ; ++j ) 
		{
			if (QuestList[i].ID.serverID  < QuestList[j].ID.serverID )
			{
				temp = QuestList[i];
				QuestList[i] = QuestList[j];
				QuestList[j] = temp;
			}
		}
	}
	
	for (i = 0; i < numQuest; ++i)
		m_questItem.SetItem( i, QuestList[i]);
}

/********************************************************************************************
 *  ,  ? ? 
 * ******************************************************************************************/
// ?   
function UpdateTalismanSlotActivation()
{

	local int Count;
	local int i;
	local UserInfo user;
	local ItemInfo DisableItem;
	
	DisableItem.IconName = "L2UI_CT1.Inventory_DF_TalismanSlot_Disable";   	//Find This and Fill Out with the Final.	
	
	
	if( GetPlayerInfo( user ) )
	{
		Count = user.nTalismanNum;

		if (Count > 0)
		{
			for (i = 0; i<Count; i++)
			{
				m_Talisman_Disable[ i ].HideWindow();				
				m_equipItem[ EQUIPITEM_Deco1 + i ].EnableWindow();
			}
			for (i = Count; i<6 ; i++)
			{
				m_Talisman_Disable[ i ].ShowWindow();				
				m_equipItem[ EQUIPITEM_Deco1 + i ].DisableWindow();
			}
		}
		else
		{
			for (i = 0; i<6; i++)   
			{
				m_Talisman_Disable[ i ].ShowWindow();				
				m_equipItem[ EQUIPITEM_Deco1 + i ].DisableWindow();
			}
		}		
	}
} 

// ?   
function UpdateAgathionSlotActivation()
{
	local int Count;
	local int i;
	local UserInfo user;	
	
	if( GetPlayerInfo( user ) )
	{	
		//    ??, 		
		if ( user.nAgathionMainNum > 0 ) 
		{
			m_Agathion_Disable[0].HideWindow();
			m_equipItem[EQUIPITEM_AGATHION_MAIN].EnableWindow();
		}
		//   ?? 
		else 
		{
			m_Agathion_Disable[0].ShowWindow();
			m_equipItem[EQUIPITEM_AGATHION_MAIN].DisableWindow();
		}

		Count = user.nAgathionSubNum;		

		if (Count > 0)
		{
			for (i = 1; i<Count + 1; i++)
			{
				m_Agathion_Disable[ i ].HideWindow();			
				m_equipItem[ EQUIPITEM_AGATHION_MAIN + i ].EnableWindow();
			}
			for (i = Count + 1; i<5 ; i++)
			{
				m_Agathion_Disable[ i ].ShowWindow();
				m_equipItem[ EQUIPITEM_AGATHION_MAIN + i ].DisableWindow();
				
			}
		}
		else
		{
			for (i = 1; i<5; i++)   
			{
				m_Agathion_Disable[ i ].ShowWindow();
				m_equipItem[ EQUIPITEM_AGATHION_MAIN + i ].DisableWindow();
			}
		}		
	}
} 

//     
function UpdateJewelSlotActivation()
{
	local int Count;
	local int i;
	local UserInfo user;
	local ItemInfo DisableItem;	
	
	DisableItem.IconName = "L2UI_CT1.Inventory_DF_TalismanSlot_Disable";   	//Find This and Fill Out with the Final.	
	
	
	if( GetPlayerInfo( user ) )
	{
		//
		Count = user.nJewelNum;				
		
		if (Count > 0)
		{
			for (i = 0; i<Count; i++)
			{
				m_Jewel_Disable[ i ].HideWindow();
				m_equipItem[ EQUIPITEM_Jewel1 + i ].EnableWindow();
				

			}
			for (i = Count; i<6 ; i++)
			{
				m_Jewel_Disable[ i ].ShowWindow();			
				m_equipItem[ EQUIPITEM_Jewel1 + i ].DisableWindow();
			}
		}
		else
		{
			for (i = 0; i<6; i++)   
			{
				m_Jewel_Disable[ i ].ShowWindow();		
				m_equipItem[ EQUIPITEM_Jewel1 + i ].DisableWindow();
			}
		}		
	}
} 

/********************************************************************************************
 *    
 * ******************************************************************************************/
// ?   
function handlePremiumHenna ( ) 
{
	//branch GD35_0828 2014-2-10 luciper3 - ? ?? ?.
	local int nUsePremiumHenna;
	local TextureHandle PremiumHennaTex;
	//end of branch

	//branch GD35_0828 2014-2-10 luciper3 - ? ?? ?.
	GetINIBool("Localize", "UsePremiumHennaSlot", nUsePremiumHenna, "L2.ini");

	if( nUsePremiumHenna == 1 ) bIsPremiumHennaSlot = true;

	if( bIsPremiumHennaSlot == false )
	{
		PremiumHennaTex = GetTextureHandle ( m_WindowName $ ".Charge_HennaSlotBg" );
		if( PremiumHennaTex != none )
			PremiumHennaTex.HideWindow();
		m_hPremiumHennaItemWindow.HideWindow();
	}
}


//      //////////////////////////////////////////////////////////////
function HandleUpdateUserInfo()
{
	// Debug ( "HandleUpdateUserInfo" ); 
	if( m_hOwnerWnd.IsShowWindow() )
	{
		setAhclemyOpener();
		InvenLimitUpdate();
		CheckShowCrystallizeButton();		
	}
}

function handleChangedSubjob ( string param ) 
{	
	parseint( param, "SubjobClassID_0", mainClass);
	//Debug("handleChangedSubjob" @ mainClass);
	setAhclemyOpener();
}

function handleNotifySubjob ( string param ) 
{
	parseint( param, "SubjobClassID_0", mainClass);
	setAhclemyOpener();
}

//  ? ?  
function CheckShowCrystallizeButton()
{
	if( class'UIDATA_PLAYER'.static.HasCrystallizeAbility() )
		m_hBtnCrystallize.ShowWindow();
	else
		m_hBtnCrystallize.HideWindow();
}

//  ? ? showHide
function ReceiveHairAccessoryPriority(string param)
{
	local int priority;

	ViewHairButton.HideWindow();
	ViewAccessoryButton.HideWindow();
	
	ParseInt(param, "priority", priority);
	
	if(priority == 0)
		ViewHairButton.ShowWindow();		
	else if(priority == 1)
		ViewAccessoryButton.ShowWindow();
}

// ?? ? ??.
function setAhclemyOpener ( ) 
{
	local userinfo info;	
	
	if ( !GetPlayerInfo( info ) ) return ;
	
	if ( info.Race == 6 ) 
	{
		AlchemyOpenerBtn.ShowWindow();
		if ( GetClassTransferDegree( info.nSubClass ) > 1 && mainClass == info.nSubClass )
		{
			toggleAlchemyOpenerTooltip ( true ) ;
			AlchemyOpenerBtn.EnableWindow();
			AlchemyOpenerBtn.ShowWindow();
			AlchemyOpenerBtn.SetTexture( "L2ui_ct1.InventoryWnd.Alchemyopener", "L2ui_ct1.InventoryWnd.InventoryWnd.Alchemyopener", "L2ui_ct1.InventoryWnd.Alchemyopener_drag");				
		}
		else 
		{
			toggleAlchemyOpenerTooltip ( false ) ;
			AlchemyOpenerBtn.disableWindow();
			AlchemyOpenerBtn.HideWindow();
			AlchemyOpenerBtn.SetTexture( "L2ui_ct1.InventoryWnd.Alchemyopener_disable", "L2ui_ct1.InventoryWnd.InventoryWnd.Alchemyopener_disable", "L2ui_ct1.InventoryWnd.Alchemyopener_disable");							
			AlchemyOpenerWindow.HideWindow();
		}
	}
	else 
	{
		AlchemyOpenerBtn.hideWindow();
	}	
}
// ?? 
function InitScrollBar()
{
	m_invenItem.SetScrollBarPosition( 0, 17, 0 );
	m_invenItem_1.SetScrollBarPosition( 0, 17, 0 );
	m_invenItem_2.SetScrollBarPosition( 0, 17, 0 );
	m_invenItem_3.SetScrollBarPosition( 0, 17, 0 );
	m_invenItem_4.SetScrollBarPosition( 0, 17, 0 );
	m_questItem.SetScrollBarPosition( 0, 17, 0 );
}


// ?   ? ?   
function setBottomButtonPostion (out int num, ButtonHandle tmpBottomButton ) 
{
	local int startX, btnW;	
	startX = 207; btnW = 39;
	tmpBottomButton.SetAnchor( m_WindowName, "TopLeft", "TopLeft",  startX + num * btnW ,352);
	++num ;
}


/**
 *  ???, ?.
 **/
function extendInventory (bool flag)
{
	local ItemWindowHandle tmpItemWindowHandle;	
	local int toExpandWidth ;	

	if (flag)
	{
		currentInvenCol = 12;
		toExpandWidth = 108 ;
		
		// ????(6, 12 )		
		m_InventoryItembg_expand.ShowWindow();
		
		// ?  ? ? 
		m_BtnWindowExpand.SetTexture("L2UI_CT1.frames_df_Btn_Minimize",
									 "L2UI_ct1.frames_df_btn_Minimize_down",
									 "L2UI_ct1.frames_df_btn_Minimize_over");	
			
	}
	else
	{
		//?  ?  
		currentInvenCol = 9;
		toExpandWidth = 0 ;
		// col  ? 36 ?. col ? ?  . 36   		
		
		// ????(6, 12 )		
		m_InventoryItembg_expand.HideWindow();

		// ?  ? ? 
		m_BtnWindowExpand.SetTexture("L2UI_ct1.frames_df_btn_Expand",
									 "L2UI_ct1.frames_df_btn_Expand_down",
									 "L2UI_ct1.frames_df_btn_Expand_over");
	}	
	
	//itemWindowWidth = ITEMWINDOW_MIN_WIDTH + toExpandWidth;	

	m_hInventoryWnd.SetWindowSize(INVENTORYWND_MIN_WIDTH + toExpandWidth, 394);

	m_invenItem.SetWindowSize(ITEMWINDOW_MIN_WIDTH + toExpandWidth, 288);

	m_invenItem_1.SetWindowSize(ITEMWINDOW_MIN_WIDTH + toExpandWidth , 288);
	m_invenItem_2.SetWindowSize(ITEMWINDOW_MIN_WIDTH + toExpandWidth , 288);
	m_invenItem_3.SetWindowSize(ITEMWINDOW_MIN_WIDTH + toExpandWidth , 288);
	m_invenItem_4.SetWindowSize(ITEMWINDOW_MIN_WIDTH + toExpandWidth , 288);
	m_questItem.SetWindowSize(ITEMWINDOW_MIN_WIDTH + toExpandWidth , 288);	
	m_tabbg.SetWindowSize(TAB_BG_MIN_WIDTH + toExpandWidth , 321);
	m_tabbgLine.SetWindowSize( TAB_BG_LING_MIN_WIDTH + toExpandWidth , 23);
	
	m_invenItem.SetCol( currentInvenCol );
	m_invenItem_1.SetCol( currentInvenCol );
	m_invenItem_2.SetCol( currentInvenCol );
	m_invenItem_3.SetCol( currentInvenCol );
	m_invenItem_4.SetCol( currentInvenCol );
	m_questItem.SetCol( currentInvenCol );

	// ?? , ? 

	if (m_selectedItemTab == INVENTORY_ITEM_TAB)
	{
		tmpItemWindowHandle = m_invenItem;	
	}
	if (m_selectedItemTab == INVENTORY_ITEM_1_TAB)
	{
		tmpItemWindowHandle = m_invenItem_1;			
	}
	if (m_selectedItemTab == INVENTORY_ITEM_2_TAB)
	{
		tmpItemWindowHandle = m_invenItem_2;		
	}
	if (m_selectedItemTab == INVENTORY_ITEM_3_TAB)
	{
		tmpItemWindowHandle = m_invenItem_3;
	}
	if (m_selectedItemTab == INVENTORY_ITEM_4_TAB)
	{
		tmpItemWindowHandle = m_invenItem_4;
	}
	else if (m_selectedItemTab == QUEST_ITEM_TAB)
	{
		tmpItemWindowHandle = m_questItem;
	}

	tmpItemWindowHandle.SetScrollPosition(0);
	tmpItemWindowHandle.ResizeScrollBar();
	tmpItemWindowHandle.SetFocus();
}

// ? ?  
function checkClassicForm () 
{	
	m_EquipWindow.HideWindow();
	setEquipWindowHandle();
	m_EquipWindow.ShowWindow();
		//InitHandleCOD()
	getHandles();	
	//Debug("checkClassicForm" @ m_EquipWindowName @ m_EquipWindow );
}


/********************************************************************************************
 * ?  ? 
 * ******************************************************************************************/
// ?
function SetAdenaText()
{
	local string adenaString;
	
	adenaString = MakeCostString( string(GetAdena()) );

	m_hAdenaTextBox.SetText(adenaString);
	m_hAdenaTextBox.SetTooltipString( ConvertNumToText(string(GetAdena())) );
}
//  
function SetItemCount()
{
	local int limit;
	local int count;
	
	if(m_selectedItemTab == QUEST_ITEM_TAB)
	{
		count = m_QuestInvenCount;
		limit = GetQuestItemInventoryLimit();
	}
	else //if(m_selectedItemTab == INVENTORY_ITEM_TAB )
	{
		count = m_NormalInvenCount + EquipItemGetItemNum();
		limit = GetMyInventoryLimit();
	}
	
	m_itemCount.SetText("(" $ count $ "/" $ limit $ ")");

	// ? 
	pInventoryItemCount = limit - count;
}

// ??  ? 
function InvenLimitUpdate()
{
	// Changed by JoeyPark 2010/09/09	

	ItemboxUpdate(m_invenItem, GetMyInventoryLimit() );

	ItemboxUpdate(m_invenItem_1, GetMyInventoryLimit() );
	ItemboxUpdate(m_invenItem_2, GetMyInventoryLimit() );
	ItemboxUpdate(m_invenItem_3, GetMyInventoryLimit() );
	ItemboxUpdate(m_invenItem_4, GetMyInventoryLimit() );

	ItemboxUpdate(m_questItem, GetQuestItemInventoryLimit() );
	// End changing
}

// ?? ?  ? 1
function ItemboxUpdate(ItemWindowHandle hItemWnd, int iInvenLimit)
{
	local int iCount;
	local int iItemCount;
	local int iAddedCount;
	local int iDeletedCount;
	local ItemInfo kClearItem;
	local ItemInfo kCurItem;
	
	kClearItem.IconName = "L2ui_ct1.emptyBtn";
	ClearItemID( kClearItem.ID );
	iItemCount = hItemWnd.GetItemNum();

	if( iItemCount < iInvenLimit )
	{		
		IAddedCount = iInvenLimit - iItemCount;
		for( iCount=0; iCount<iAddedCount; iCount++ )
		{
			hItemWnd.AddItem( kClearItem );	
		}
	}
	else if ( iItemCount > iInvenLimit )
	{
		iDeletedCount = iItemCount - iInvenLimit;
		for ( iCount = hItemWnd.GetItemNum()- 1; iCount >= 0; iCount-- )
		{
			if (iDeletedCount > 0)
			{
				hItemWnd.GetItem(iCount, kCurItem );
				if (!IsValidItemID(kCurItem.ID))
				{
					hItemWnd.DeleteItem(iCount);
					iDeletedCount--;
				}
				if (iDeletedCount <= 0)
				{
					break;
				}					
			}
		}
	}
}

// ?? ? 
function HandleSetMaxCount(string param)
{
	local int ExtraBeltCount;
	ParseInt (param, "Inventory", m_MaxInvenCount);
	ParseInt (param, "questItem", m_MaxQuestItemInvenCount);
	ParseInt (param, "extrabelt", ExtraBeltCount);
	
	//debug("SetMaxCount Called");
	m_invenItem.SetExpandItemNum(0, ExtraBeltCount);
	InvenLimitUpdate();
	SetItemCount();
}


/********************************************************************************************
 *   show<>hide ?
 * ******************************************************************************************/
function HandleToggleWindow()
{
	if( m_hOwnerWnd.IsShowWindow() )
	{
		m_hOwnerWnd.HideWindow();
		PlayConsoleSound(IFST_INVENWND_CLOSE);
	}
	else
	{		
		//  ?    ? 
		//   ?  ? .
		// RequestItemList   ?   toggleWindow   ??  ?. 		
		if ( bIsRequestItemList ) return;
		bIsRequestItemList = true;		
		RequestItemList();
		m_hOwnerWnd.setTimer ( TIMER_REQUEST_ITEMLIST, TIMER_REQUEST_ITEMLIST_DELAY );
	}
}


function HandleOpenWindow(string param)
{
	local int open;

	//? ?  ;
	//Debug( "HandleOpenWindow"  @ cur_state  ) ;
	if ( cur_state == "BEAUTYSHOPSTATE" ) return;
	// ? ?  ? ? show 
	if ( bIsRequestItemList ) return;

	ParseInt(param, "Open", open);

	if(open==0) return;
	
	OpenWindow();
}

function OpenWindow()
{
	m_hInventoryWnd.ShowWindow();
	m_hInventoryWnd.SetFocus();
}

function HandleHideWindow()
{
	//branch 110804
	DialogHide();
	HideWindow(m_WindowName);
	//end of branch
}

function handleEnchantJewelButton()
{	
	local ItemJewelEnchantWnd script;		
	script = ItemJewelEnchantWnd( GetScript("ItemJewelEnchantWnd"));
	script.toggleShowWindow();	
}

function toggleShowAlchemyWindow ( string winName ) 
{
	if( class'UIAPI_WINDOW'.static.IsShowWindow(winName) ) class'UIAPI_WINDOW'.static.HideWindow(winName);
	else class'UIAPI_WINDOW'.static.ShowWindow(winName);
}

function toggleAlchemyOpener()
{	
	if( AlchemyOpenerWindow.IsShowWindow()) AlchemyOpenerWindow.HideWindow();
	else AlchemyOpenerWindow.ShowWindow();
}

function toggleAgathionWindow()
{
	if ( AgathionWindow.isShowWindow())
	{		
		if ( getInstanceUIData().getIsClassicServer()  ) 
			AgathionBtn.SetTexture("L2UI_CT1.button.BtnEditDown", "L2UI_CT1.button.BtnEditDown_down", "L2UI_CT1.button.BtnEditDown_over");
		else AgathionBtn.SetTexture("L2UI_CT1.button.BtnEditUp", "L2UI_CT1.button.BtnEditUp_down", "L2UI_CT1.button.BtnEditUp_over"); 

		AgathionWindow.HideWindow();
	}
	else 
	{
		if ( getInstanceUIData().getIsClassicServer()  ) 
			AgathionBtn.SetTexture("L2UI_CT1.button.BtnEditUp", "L2UI_CT1.button.BtnEditUp_down", "L2UI_CT1.button.BtnEditUp_over"); 			
		else AgathionBtn.SetTexture("L2UI_CT1.button.BtnEditDown", "L2UI_CT1.button.BtnEditDown_down", "L2UI_CT1.button.BtnEditDown_over"); 		

		//  ? 
		JewelWindow.HideWindow();
		JewelButton.SetTexture("L2UI_CT1.button.Button_DF_right", "L2UI_CT1.button.Button_DF_right_down", "L2UI_CT1.button.Button_DF_right_over");

		AgathionWindow.ShowWindow();
		AgathionWindow.SetFocus();
	}
}

function toggleJewelWindow()
{
	if ( JewelWindow.isShowWindow())
	{		
		JewelButton.SetTexture("L2UI_CT1.button.Button_DF_right", "L2UI_CT1.button.Button_DF_right_down", "L2UI_CT1.button.Button_DF_right_over");
		JewelWindow.HideWindow();
	}
	else 
	{
		// ? 
		AgathionWindow.HideWindow();
		if ( getInstanceUIData().getIsClassicServer()  ) 
			AgathionBtn.SetTexture("L2UI_CT1.button.BtnEditDown", "L2UI_CT1.button.BtnEditDown_down", "L2UI_CT1.button.BtnEditDown_over");
		else AgathionBtn.SetTexture("L2UI_CT1.button.BtnEditUp", "L2UI_CT1.button.BtnEditUp_down", "L2UI_CT1.button.BtnEditUp_over"); 


		JewelButton.SetTexture("L2UI_CT1.button.Button_DF_left", "L2UI_CT1.button.Button_DF_left_down", "L2UI_CT1.button.Button_DF_left_over");
		JewelWindow.ShowWindow();
		JewelWindow.SetFocus();
	}
}

/********************************************************************************************
 * pawn 
 * ******************************************************************************************/
function HandleChangeCharacterPawn(string param)
{
	ParseInt (param, "MeshType", m_MeshType);
	switch (m_MeshType)
	{
		case 0:
		// ?__
		m_ObjectViewport.SetCharacterScale(1.f);
		m_ObjectViewport.SetCharacterOffsetX(-2);
		m_ObjectViewport.SetCharacterOffsetY(-6);                                       
		break;
		case 1:
		// ?__
		m_ObjectViewport.SetCharacterScale(1.03f);
		m_ObjectViewport.SetCharacterOffsetX(-2);
		m_ObjectViewport.SetCharacterOffsetY(-8);                                       
		break;
		case 8:
		// ?__
		m_ObjectViewport.SetCharacterScale(1.047f);
		m_ObjectViewport.SetCharacterOffsetX(2);
		m_ObjectViewport.SetCharacterOffsetY(-8);                                       
		break;
		case 9:
		// ?__
		m_ObjectViewport.SetCharacterScale(1.07f);
		m_ObjectViewport.SetCharacterOffsetX(-1);
		m_ObjectViewport.SetCharacterOffsetY(-9);                                       
		break;
		case 6:
		// __
		m_ObjectViewport.SetCharacterScale(0.98f);
		m_ObjectViewport.SetCharacterOffsetX(-2);
		m_ObjectViewport.SetCharacterOffsetY(-7);                                       
		break;
		case 7:
		// __
		m_ObjectViewport.SetCharacterScale(1.04f);
		m_ObjectViewport.SetCharacterOffsetX(-4);
		m_ObjectViewport.SetCharacterOffsetY(-8);                                       
		break;
		// case q
		// __
		// SetCharacterOffsetX(-2);
		// SetCharacterOffsetY(-7);
		// __
		// SetCharacterOffsetX(-4);
		// SetCharacterOffsetY(-8);
		case 2:
		// ?__
		m_ObjectViewport.SetCharacterScale(0.99f);
		m_ObjectViewport.SetCharacterOffsetX(-1);
		m_ObjectViewport.SetCharacterOffsetY(-7);                                       
		break;
		case 3:
		// ?__
		m_ObjectViewport.SetCharacterScale(1.015f);
		m_ObjectViewport.SetCharacterOffsetX(-1);
		m_ObjectViewport.SetCharacterOffsetY(-7);
		break;
		// ?__
		// SetCharacterOffsetX(-1);
		// SetCharacterOffsetY(-7);
		// ?__
		// SetCharacterOffsetX(-1);
		// SetCharacterOffsetY(-7);
		case 10:
		// ?__                             
		m_ObjectViewport.SetCharacterScale(0.953f);
		m_ObjectViewport.SetCharacterOffsetX(0);
		m_ObjectViewport.SetCharacterOffsetY(-9);                                       
		break;
		case 11:
		// ?__
		m_ObjectViewport.SetCharacterScale(0.97f);
		m_ObjectViewport.SetCharacterOffsetX(2);
		m_ObjectViewport.SetCharacterOffsetY(-8);                                       
		break;
		case 12:
		// ?__
		m_ObjectViewport.SetCharacterScale(0.955f);
		m_ObjectViewport.SetCharacterOffsetX(-2);
		m_ObjectViewport.SetCharacterOffsetY(-8);                                       
		break;
		case 13:
		// ?__
		m_ObjectViewport.SetCharacterScale(0.985f);
		m_ObjectViewport.SetCharacterOffsetX(0);
		m_ObjectViewport.SetCharacterOffsetY(-8);                                       
		break;
		case 4:
		// _
		m_ObjectViewport.SetCharacterScale(1.043f);
		m_ObjectViewport.SetCharacterOffsetX(0);
		m_ObjectViewport.SetCharacterOffsetY(-2);                                       
		break;
		case 5:
		// _
		m_ObjectViewport.SetCharacterScale(1.09f);
		m_ObjectViewport.SetCharacterOffsetX(0);
		m_ObjectViewport.SetCharacterOffsetY(-6);                                       
		break;
		case 14:
		// ?_
		m_ObjectViewport.SetCharacterScale(0.993f);
		m_ObjectViewport.SetCharacterOffsetX(-5);
		m_ObjectViewport.SetCharacterOffsetY(-6);                                       
		break;
		case 15:
		// ?_
		m_ObjectViewport.SetCharacterScale(1.01f);
		m_ObjectViewport.SetCharacterOffsetX(0);
		m_ObjectViewport.SetCharacterOffsetY(-6);                                       
		break;
	}
}

/********************************************************************************************
 * Gfx ? ? ?    ?
 * ******************************************************************************************/
/* 
 * 1.   ? 
 * 2.  ??   
 */
function showItemUpdateEffect ( string param )  
{
	local int index, i;
	local ItemInfo info, newItem, tmpItem;
	local ItemWindowHandle targetItemWnd;
	local string type, strParam;

	ParseString( param, "type", type );
	ParamToItemInfo( param, newItem );	

	for ( i = 0 ; i < EQUIPITEM_Max ; i ++ )
	{
		m_equipItem[i].GetItem( 0, tmpItem ); 
		if ( IsSameServerID( tmpItem.ID, newItem.ID )) return;
	}


	if ( type =="delete") return;

	if ( IsEquipItem( newItem ) ) 
		return;
	else if ( IsQuestItem( newItem ))	
		targetItemWnd = m_questItem;	
	else
		targetItemWnd = m_invenItem;

	index = targetItemWnd.FindItem ( newItem.ID );
	targetItemWnd.GetItem (index, info );

	// Debug ( "showItemUpdateEffect" @ info.itemNum @  newItem.itemNum );
	if ( info.itemNum < newItem.itemNum ) 
	{
		strParam = "iconName=" $ newItem.iconName;
		strParam = strParam @ "itemNum="$string( newItem.itemNum - info.itemNum );
		//ParamAdd( strParam, "iconName", newItem.iconName);
		//ParamAdd( strParam, "itemNum", string( newItem.itemNum - info.itemNum ));
		getInstanceL2Util().showGfxScreenMessage( strParam , getInstanceL2Util().EGfxScreenMsgType.MSGType_AddItemEffect );
	}
}


/********************************************************************************************
 * 
 * ******************************************************************************************/
function CustomTooltip getAgathionTooltip (  string title, string desc ) 
{
	local CustomTooltip T;	
	local L2Util util;
	util = L2Util(GetScript("L2Util"));//bluesun ??  
	util.setCustomTooltip(T);//bluesun ?? 
	util.ToopTipInsertText( title , true, false, util.ETooltipTextType.COLOR_GRAY);
	util.ToopTipInsertText( desc , true, true, util.ETooltipTextType.COLOR_GRAY);
	return util.getCustomTooltip();
}

function setCustomTooltip ()
{
	local L2Util util;
	local CustomTooltip T;
	//local string tmpTooltipString;	

	//T.MinimumWidth = 125;
	util = L2Util(GetScript("L2Util"));//bluesun ??  
	util.setCustomTooltip(T);//bluesun ?? 	

	util.ToopTipMinWidth(150);
	util.ToopTipInsertText( GetSystemString (3265), true, false);
	util.TooltipInsertItemBlank(4);	

	util.ToopTipInsertText( GetSystemString (3270), false, true,util.ETooltipTextType.COLOR_GRAY);			
	AlchemyMixCubeWndBtn.SetTooltipCustomType(util.getCustomTooltip());	
	
	util.setCustomTooltip(T);//bluesun ?? 
	util.ToopTipMinWidth(150);
	util.ToopTipInsertText( GetSystemString (3266), true, false);
	util.TooltipInsertItemBlank(4);	
	util.ToopTipInsertText( GetSystemString (3271), false, true,util.ETooltipTextType.COLOR_GRAY);			
	AlchemyItemConversionWndBtn.SetTooltipCustomType(util.getCustomTooltip());

	AlchemyItemCreateWndBtn.DisableWindow();
	util.setCustomTooltip(T);//bluesun ?? 	
	util.ToopTipInsertText( GetSystemString (3312), true, false);
	util.TooltipInsertItemBlank(4);
	util.ToopTipInsertText( GetSystemString (3272), false, true,util.ETooltipTextType.COLOR_GRAY);
	AlchemyItemCreateWndBtn.SetTooltipCustomType(util.getCustomTooltip());
}

function toggleAlchemyOpenerTooltip ( bool isOn)
{
	local L2Util util;
	local CustomTooltip T;
	
	util = L2Util(GetScript("L2Util"));//bluesun ?? 
	util.setCustomTooltip(T);//bluesun ?? 
	
	util.ToopTipInsertText( GetSystemString (3257), true, false);

	if ( !isOn ) 
	{		
		util.ToopTipMinWidth(150);
		util.TooltipInsertItemBlank(4);
		util.ToopTipInsertText( GetSystemMessage (4263), false, true,util.ETooltipTextType.COLOR_GRAY);			
	}	
	AlchemyOpenerBtn.SetTooltipCustomType(util.getCustomTooltip());
}


/********************************************************************************************
 * etc, util
 * ******************************************************************************************/
// int 64 ?  uc  ? int  ? ?. string  ??  ?  .
function String getAgathionSlotBitTypeString ( String keyword) 
{	
	switch ( keyword ) 
	{
		// ? 
		case "n":
			return "68719476736";
		break;
		case "1":
			return "137438953472";
		break;
		case "2":
			return "274877906944";
		break;
		case "3":
			return "549755813888";
		break;
		case "4":
			return "1099511627776";
		break;			
	}
	return "";
}

// ?   ? ?
function itemWindowHandle getItemWindowHandleBystrTarget( string strTarget )
{
	switch ( strTarget )
	{
		case "InventoryItem":
			return m_invenItem;
		break;	
		case "InventoryItem_1":
			return m_invenItem_1;
		break;
		case "InventoryItem_2":
			return m_invenItem_2;
		break;
		case "InventoryItem_3":
			return m_invenItem_3;
		break;
		case "InventoryItem_4":
			return m_invenItem_4;
		break;		
	}
}

// ?   ?
function ItemWindowHandle getItemWindowHandleByItemType ( ItemInfo item )
{
	if(!IsValidItemID(item.ID))
		return m_invenItem_4;
	
	switch ( class'UIDATA_ITEM'.static.GetInventoryType ( item.ID.classID ) ) 
	{
		case EIIT_EQUIPMENT:			
			return m_invenItem_1;
		break;
		case EIIT_CONSUMABLE:
			return m_invenItem_2;
		break;
		case EIIT_MATERIAL:
			return m_invenItem_3;
		break;		
		case EIIT_ETC:
		case EIIT_NONE:
			return m_invenItem_4;
		break;
		case EIIT_QUEST:
			return m_questItem;
	}	
}




/**
 *  ESC ? ?  
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( m_WindowName ).HideWindow();
}


defaultproperties
{
    m_WindowName="InventoryWnd"
}
