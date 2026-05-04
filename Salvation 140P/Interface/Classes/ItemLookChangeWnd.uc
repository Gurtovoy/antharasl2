class ItemLookChangeWnd extends UICommonAPI;

enum EShapeShiftingWindowType
{
	SST_WindowInvalid,
	SST_WindowNormal,
	SST_WindowBlessed,
	SST_WindowFixed,
	SST_WindowRestore,
	SST_WindowMax
};

enum EShapeWindowType
{
	SWT_InvalID,
	SWT_Weapon,
	SWT_Armor,
	SWT_Hair_Accessary,
	SWT_AllItem,
	SWT_Max
};


var WindowHandle Me;
var TextureHandle BackPattern;

var TextBoxHandle WeaponSlotTxt;
var TextBoxHandle LookSlotTxt;
var TextBoxHandle RestoreSlotTxt;
var TextBoxHandle InstructionTxt;
var TextBoxHandle AdenaText;

var ItemWindowHandle StoneItemSlot;
var ItemWindowHandle WeaponItemSlot;
var ItemWindowHandle LookItemSlot;
var ItemWindowHandle RestoreItemSlot;
var ItemWindowHandle EnchantedItemSlot;

var ButtonHandle EnchantBtn;
var ButtonHandle ExitBtn;
var ButtonHandle OkBtn;

var TextureHandle Groupbox2;
var TextureHandle Groupbox1;

var TextureHandle StoneItemSlotBackTex;
var TextureHandle WeaponItemSlotBackTex;
var TextureHandle LookItemSlotBackTex;
var TextureHandle RestoreItemSlotBackTex;
var TextureHandle EnchantedItemSlotBackTex;

var TextureHandle DropHighlight_StoneItem;
var TextureHandle DropHighlight_WeaponItem;
var TextureHandle DropHighlight_LookItem;
var TextureHandle DropHighlight_RestoreItem;

var AnimTextureHandle EnchantProgressAnim;
var ProgressCtrlHandle	m_hItemLookChangeWndEnchantProgress;

const DIALOG_RESULT_SUCCESS		= 303;
const DIALOG_RESULT_FAILURE		= 304;
const DIALOG_ONLY_NOTICE = 5555;							//아무동작도 안하는 알려주는 전용
const DIALOG_LOOKCHANGE_START = 4444;
const DIALOG_LOOKCHANGE_START_FINAL = 7777;
const DIALOG_RESTORELOOKCHANGE_START = 6666;

// 변수 목록
const C_ANIMLOOPCOUNT = 1;
var bool bItemLookChangebool, bItemLookChangedbool;
var int  mItemLookChangeType;
var INT64  mPriceAdena;
var bool bIsShopping;

var ItemInfo 		TempDropItemInfo;		// 선택한 아이템
var ItemInfo 		WeaponItemInfo;		// 선택한 아이템
var ItemInfo		LookWeaponItemInfo;

var EShapeShiftingWindowType eShapeShiftingWindow; //복원모드일때
var EShapeWindowType eShapeWindow;

//branch 111109
var bool bItemLookEnchantStart;
//end of branch

var InventoryWnd inventoryWndScript;

function OnLoad()
{
	SetClosingOnESC();

	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	if(CREATE_ON_DEMAND==0)
	{
		
		Me = GetHandle( "ItemLookChangeWnd" );
		EnchantProgressAnim = AnimTextureHandle ( GetHandle( "ItemLookChangeWnd.EnchantProgressAnim" ) );
		BackPattern = TextureHandle ( GetHandle( "ItemLookChangeWnd.BackPattern" ) );
	
		WeaponSlotTxt = TextBoxHandle ( GetHandle( "ItemLookChangeWnd.WeaponSlotTxt" ) );
		LookSlotTxt = TextBoxHandle ( GetHandle( "ItemLookChangeWnd.LookSlotTxt" ) );
		RestoreSlotTxt = TextBoxHandle ( GetHandle( "ItemLookChangeWnd.RestoreSlotTxt" ) );
		InstructionTxt = TextBoxHandle ( GetHandle( "ItemLookChangeWnd.InstructionTxt" ) );
		AdenaText = TextBoxHandle ( GetHandle( "ItemLookChangeWnd.AdenaText" ) );

		StoneItemSlot = ItemWindowHandle ( GetHandle( "ItemLookChangeWnd.StoneItemSlot" ) );
		WeaponItemSlot = ItemWindowHandle ( GetHandle( "ItemLookChangeWnd.WeaponItemSlot" ) );
		LookItemSlot = ItemWindowHandle ( GetHandle( "ItemLookChangeWnd.LookItemSlot" ) );
		RestoreItemSlot = ItemWindowHandle ( GetHandle( "ItemLookChangeWnd.RestoreItemSlot" ) );
		EnchantedItemSlot = ItemWindowHandle ( GetHandle( "ItemLookChangeWnd.EnchantedItemSlot" ) );
		
		EnchantBtn = ButtonHandle ( GetHandle( "ItemLookChangeWnd.EnchantBtn" ) );
		ExitBtn = ButtonHandle ( GetHandle( "ItemLookChangeWnd.ExitBtn" ) );
		OkBtn = ButtonHandle ( GetHandle( "ItemLookChangeWnd.OkBtn" ) );
		
		Groupbox2 = TextureHandle ( GetHandle( "ItemLookChangeWnd.Groupbox2" ) );
		Groupbox1 = TextureHandle ( GetHandle( "ItemLookChangeWnd.Groupbox1" ) );
		
		StoneItemSlotBackTex = TextureHandle ( GetHandle( "ItemLookChangeWnd.StoneItemSlotBackTex" ) );
		WeaponItemSlotBackTex = TextureHandle ( GetHandle( "ItemLookChangeWnd.WeaponItemSlotBackTex" ) );
		LookItemSlotBackTex = TextureHandle ( GetHandle( "ItemLookChangeWnd.LookItemSlotBackTex" ) );
		RestoreItemSlotBackTex = TextureHandle ( GetHandle( "ItemLookChangeWnd.RestoreItemSlotBackTex" ) );
		EnchantedItemSlotBackTex = TextureHandle ( GetHandle( "ItemLookChangeWnd.EnchantedItemSlotBackTex" ) );
		
		DropHighlight_StoneItem = TextureHandle ( GetHandle( "ItemLookChangeWnd.DropHighlight_StoneItem" ) );
		DropHighlight_WeaponItem = TextureHandle ( GetHandle( "ItemLookChangeWnd.DropHighlight_WeaponItem" ) );
		DropHighlight_LookItem = TextureHandle ( GetHandle( "ItemLookChangeWnd.DropHighlight_LookItem" ) );
		DropHighlight_RestoreItem = TextureHandle ( GetHandle( "ItemLookChangeWnd.DropHighlight_RestoreItem" ) );
	}
	else
	{
		Me = GetWindowHandle( "ItemLookChangeWnd" );
		EnchantProgressAnim = GetAnimTextureHandle (  "ItemLookChangeWnd.EnchantProgressAnim"  );
		BackPattern = GetTextureHandle (  "ItemLookChangeWnd.BackPattern"  );
		
		WeaponSlotTxt = GetTextBoxHandle (  "ItemLookChangeWnd.WeaponSlotTxt"  );
		LookSlotTxt = GetTextBoxHandle (  "ItemLookChangeWnd.LookSlotTxt"  );
		RestoreSlotTxt = GetTextBoxHandle (  "ItemLookChangeWnd.RestoreSlotTxt"  );
		InstructionTxt = GetTextBoxHandle (  "ItemLookChangeWnd.InstructionTxt"  );
		AdenaText = GetTextBoxHandle (  "ItemLookChangeWnd.AdenaText"  );
						
		StoneItemSlot = GetItemWindowHandle (  "ItemLookChangeWnd.StoneItemSlot"  );
		WeaponItemSlot = GetItemWindowHandle (  "ItemLookChangeWnd.WeaponItemSlot"  );
		LookItemSlot = GetItemWindowHandle (  "ItemLookChangeWnd.LookItemSlot"  );
		RestoreItemSlot = GetItemWindowHandle (  "ItemLookChangeWnd.RestoreItemSlot"  );
		EnchantedItemSlot = GetItemWindowHandle (  "ItemLookChangeWnd.EnchantedItemSlot"  );
		
		EnchantBtn = GetButtonHandle (  "ItemLookChangeWnd.EnchantBtn"  );
		ExitBtn = GetButtonHandle (  "ItemLookChangeWnd.ExitBtn"  );
		OkBtn = GetButtonHandle (  "ItemLookChangeWnd.OkBtn"  );
		
		Groupbox2 = GetTextureHandle (  "ItemLookChangeWnd.Groupbox2"  );
		Groupbox1 = GetTextureHandle (  "ItemLookChangeWnd.Groupbox1"  );
				
		StoneItemSlotBackTex = GetTextureHandle (  "ItemLookChangeWnd.StoneItemSlotBackTex"  );
		WeaponItemSlotBackTex = GetTextureHandle (  "ItemLookChangeWnd.WeaponItemSlotBackTex"  );
		LookItemSlotBackTex = GetTextureHandle (  "ItemLookChangeWnd.LookItemSlotBackTex"  );
		RestoreItemSlotBackTex = GetTextureHandle (  "ItemLookChangeWnd.RestoreItemSlotBackTex"  );
		EnchantedItemSlotBackTex = GetTextureHandle (  "ItemLookChangeWnd.EnchantedItemSlotBackTex"  );
		
		DropHighlight_StoneItem = GetTextureHandle (  "ItemLookChangeWnd.DropHighlight_StoneItem"  );
		DropHighlight_WeaponItem = GetTextureHandle (  "ItemLookChangeWnd.DropHighlight_WeaponItem"  );
		DropHighlight_LookItem = GetTextureHandle (  "ItemLookChangeWnd.DropHighlight_LookItem"  );
		DropHighlight_RestoreItem = GetTextureHandle (  "ItemLookChangeWnd.DropHighlight_RestoreItem"  );
		
		m_hItemLookChangeWndEnchantProgress=GetProgressCtrlHandle("ItemLookChangeWnd.EnchantProgress");
	}
	Initialize();
	Load();
}

function onShow()
{ 
	// 지정한 윈도우를 제외한 닫기 기능 
	getInstanceL2Util().ItemRelationWindowHide(getCurrentWindowName(String(self)), "InventoryWnd");
	
	// 레시피를 사용할 것인지를 물을 때
	// 아이템사용 시 지정된 팝업메시지를 띄울 때
	// 아이템을 바닥에 버릴 때(한개)
	// 아이템을 바닥에 버릴 때(여러개, 개수를 물어본다)
	// 아이템을 바닥에 버릴 때(MoveAll 상태일 때)
	// 아이템을 휴지통에 버릴 때(한개)
	// 아이템을 휴지통에 버릴 때(MoveAll 상태일 때)
	// 아이템을 휴지통에 버릴 때(여러개, 개수를 물어본다)
	// 아이템을 결정화 할때
	// 결정화가 불가능하다는 경고
	// 펫인벤에서 아이템이 드롭되었을 때

	// 해당 id로 열린 다이얼로그 박스가 인챈트 창을 열었을때 열려 있다면..
	// QA 요청 사항 : QA 김환수 요청
	switch(DialogGetID())
	{
		case 1111  :
		case 2222  :
		case 3333  :
		case 4444  :
		case 5555  :
		case 6666  :
		case 7777  :
		case 8888  :
		case 9998  :
		case 9999  :
		case 10000 : DialogHide(); break;
	}
}

function Initialize()
{
	mPriceAdena = 0;
	bItemLookChangebool = false;
	bItemLookChangedbool = false;
	bIsShopping = false;
	eShapeShiftingWindow = SST_WindowInvalid;
	eShapeWindow = SWT_Weapon;
}

function OnRegisterEvent()
{
	RegisterEvent( EV_ItemLookChangeShow );
	RegisterEvent( EV_ItemLookChangeHide );	
	RegisterEvent( EV_ItemLookChangeResult );
	RegisterEvent( EV_ItemLookChangePutTargetItemResult );
	RegisterEvent( EV_ItemLookChangePutSupportItemResult );
	
	RegisterEvent( EV_DialogOK );
}

function Load()
{
	inventoryWndScript = inventoryWnd(GetScript("inventoryWnd"));
}

function OnEvent(int Event_ID, string param)
{
	local int shape;
	local int showwindow;
	local ItemID cID;
	
	if (Event_ID == EV_ItemLookChangeShow)
	{
		// Debug("param" @ param);
		
		ParseInt(Param, "ShapeType", shape);
		ParseInt(Param, "ShapeShiftingType", showwindow);
		ParseItemID(param, cID);		
		
		eShapeShiftingWindow = GetShapeShiftingType(showwindow);
		eShapeWindow = GetShapeType(shape);
		
		if(!bIsShopping)
		{
			if( eShapeShiftingWindow == SST_WindowRestore )
			{
				HandleRestoreLookChangeShow(cID);
			}
			else
			{
				HandleLookChangeShow(cID);
			}			
		}
		else
		{
			class'ItemLookChangeAPI'.static.RequestExCancelItemLookChange();
		}
	}	
	else if ( Event_ID == EV_ItemLookChangePutTargetItemResult)
	{
		if( eShapeShiftingWindow == SST_WindowRestore )
		{
			HandleRestorePutTargetItemResult(param);
		}
		else
		{
			HandlePutTargetItemResult(param);
		}
		//~ debug ("EnchantLevel" @ mEnchantLevel);
	}
	else if ( Event_ID ==  EV_ItemLookChangePutSupportItemResult )
	{
		//debug ("Support Item Received" @ param);
		HandletPutSupportItemResult(param);
	}		
	else if (Event_ID == EV_ItemLookChangeResult)
	{
		Debug("Event_ID EV_ItemLookChangeResult" @ param);

		if( eShapeShiftingWindow == SST_WindowRestore )
		{
			Debug("SST_WindowRestore");
			HandlerRestoreLookChangeResult(param);
		}
		else
		{
			Debug("HandleLookChangeResult");
			HandleLookChangeResult(param);
		}
	}	
	else if ( Event_ID == EV_DialogOK)
	{
		// debug("EV_DialogOK");
		HandleDialogOK();
	}
	else if ( Event_ID == EV_DialogCancel)
	{
		
	}
}

function EShapeShiftingWindowType GetShapeShiftingType(int showwindow)
{
	if( showwindow == 0 )
		return SST_WindowInvalid;
	else if( showwindow == 1 )
		return SST_WindowNormal;
	else if( showwindow == 2 )
		return SST_WindowBlessed;
	else if( showwindow == 3 )
		return SST_WindowFixed;
	else if( showwindow == 4 )
		return SST_WindowRestore;
	
	return SST_WindowInvalid;	
}

function EShapeWindowType GetShapeType(int showwindow)
{
	
	if( showwindow == 1 )
		return SWT_Weapon;
	else if( showwindow == 2 )
		return SWT_Armor;
	else if( showwindow == 3 )
		return SWT_Hair_Accessary;
	else if( showwindow == 4 )
		return SWT_AllItem;
		
	return SWT_InvalID;	
}


function bool HandleDialogOK()
{
	local int id;	
	
	if( DialogIsMine() )
	{				
		id = DialogGetID();
		//debug("HandleDialogOK  " $ id);
		
		if (id == DIALOG_LOOKCHANGE_START)
		{	
			DialogShow(DialogModalType_Modal,DialogType_OKCancel, GetSystemMessage( 6114 ), string(Self) );
			DialogSetID(DIALOG_LOOKCHANGE_START_FINAL);								
		}				
		else if (id == DIALOG_RESTORELOOKCHANGE_START)
		{	
			OnRestoreLookChangeStart();		
			EnchantBtn.DisableWindow(); 			
			bItemLookEnchantStart = true;
			return true;
		}	
		else if( id == DIALOG_LOOKCHANGE_START_FINAL )
		{
			OnLookChangeStart();
 			EnchantBtn.DisableWindow(); 
 			bItemLookEnchantStart = true;			
			return true;
		}	
		else if( id == DIALOG_RESULT_FAILURE )
		{			
		}
	}	
	//debug("HandleDialogOK false");
	return false;
}


function OnClickButton( string Name )
{
	switch( Name )
	{
	case "EnchantBtn":
		DialogHide();
		if( eShapeShiftingWindow == SST_WindowRestore )
		{
			DialogShow(DialogModalType_Modal,DialogType_OKCancel, MakeFullSystemMsg( GetSystemMessage(6082), WeaponItemInfo.Name ), string(Self));
			DialogSetID(DIALOG_RESTORELOOKCHANGE_START);					
		}
		else
		{
			if( eShapeShiftingWindow == SST_WindowNormal || eShapeShiftingWindow == SST_WindowBlessed )
			{
				DialogShow(DialogModalType_Modal,DialogType_OKCancel, MakeFullSystemMsg( GetSystemMessage(6080), WeaponItemInfo.Name, LookWeaponItemInfo.Name ), string(Self));
				DialogSetID(DIALOG_LOOKCHANGE_START);								
			}
			else if( eShapeShiftingWindow == SST_WindowFixed )
			{
				DialogShow(DialogModalType_Modal,DialogType_OKCancel, MakeFullSystemMsg( GetSystemMessage(6081), WeaponItemInfo.Name ), string(Self));
				DialogSetID(DIALOG_LOOKCHANGE_START);					
			}						
		}
		break;
	case "ExitBtn":
		if (!bItemLookChangedbool)
		{
			class'ItemLookChangeAPI'.static.RequestExCancelItemLookChange();
			ProcCancel();			
			Me.HideWindow();
		}	
		else
		{
			Me.HideWindow();
		}	
		break;
	case "OkBtn":		
			Me.HideWindow();
		break;
	}
	
}

function HandleLookChangeShow(ItemID cID)
{
	local ItemID cFixID;
	local ItemInfo cItemInfo;
			
	class'UIDATA_ITEM'.static.GetItemInfo(cID, cItemInfo );
	
	bItemLookChangedbool = false;
	
	ResetUI();
	Me.ShowWindow();
	//~ EnchantBtn.ShowWindow();
	Me.SetFocus();
	ExitBtn.SetNameText( GetSystemString(646) );
	EnchantBtn.SetNameText( GetSystemString(428) );
	cItemInfo.ItemNum = 1;
	StoneItemSlot.SetItem( 0, cItemInfo );
	StoneItemSlot.AddItem( cItemInfo );
	
	Playsound("ItemSound3.enchant_input");
		
	mItemLookChangeType = 0;
	
	ItemLookChangeThreeSlot();
	
	if(eShapeShiftingWindow == SST_WindowFixed)
	{
		cFixID.ClassID = cItemInfo.LookChangeIconID;
		class'UIDATA_ITEM'.static.GetItemInfo(cFixID, LookWeaponItemInfo );	
	
		LookItemSlot.SetItem( 0, LookWeaponItemInfo );
		LookItemSlot.AddItem( LookWeaponItemInfo );
		
		//LookItemSlot.SetTexture("Icon.etc_i.etc_question_mark_i00");
		DropHighlight_LookItem.ShowWindow();
		DropHighlight_LookItem.SetTexture("L2UI_ch3.RefineryWnd.refineslot2");
		
		LookItemSlotBackTex.HideWindow();
	}
	
	if( eShapeWindow == SWT_Weapon )
	{		
		WeaponItemSlotBackTex.SetTexture("l2ui_ct1.ItemLookChangeWnd_SlotBg_Weapon");			
		LookItemSlotBackTex.SetTexture("BranchSys3.Icon.ItemLookChangeWnd_SlotBg_Look");	
	}
	else if( eShapeWindow == SWT_Armor )
	{
		
		WeaponItemSlotBackTex.SetTexture("BranchSys3.Icon.ItemLookChangeWnd_SlotBg_Armor");			
		LookItemSlotBackTex.SetTexture("BranchSys3.Icon.ItemLookChangeWnd_SlotBg_ArmorLook");	
	}
	else
	{
		WeaponItemSlotBackTex.SetTexture("BranchSys3.Icon.ItemLookChangeWnd_SlotBg_Cap");			
		LookItemSlotBackTex.SetTexture("BranchSys3.Icon.ItemLookChangeWnd_SlotBg_CapLook");	
	}	
}

function HandleRestoreLookChangeShow(ItemID cID)
{
	local ItemInfo cItemInfo;
		
	class'UIDATA_ITEM'.static.GetItemInfo(cID, cItemInfo );
	
	bItemLookChangedbool = false;
	
	ResetUI();
	Me.ShowWindow();
	//~ EnchantBtn.ShowWindow();
	Me.SetFocus();
	ExitBtn.SetNameText( GetSystemString(646) );
	EnchantBtn.SetNameText( GetSystemString(428) );
	cItemInfo.ItemNum = 1;
	WeaponItemSlot.SetItem( 0, cItemInfo );
	WeaponItemSlot.AddItem( cItemInfo );
	
	Playsound("ItemSound3.enchant_input");
		
	mItemLookChangeType = 0;
		
	RestoreLookChangeTwoSlot();
	
	if( eShapeWindow == SWT_Weapon )
	{
		RestoreItemSlotBackTex.SetTexture("l2ui_ct1.ItemLookChangeWnd_SlotBg_Weapon");			
		//RestoreItemSlotBackTex.SetTexture("BranchSys3.Icon.ItemLookChangeWnd_SlotBg_Look");	
	}
	else if( eShapeWindow == SWT_Armor )
	{
		RestoreItemSlotBackTex.SetTexture("BranchSys3.Icon.ItemLookChangeWnd_SlotBg_Armor");			
		//RestoreItemSlotBackTex.SetTexture("BranchSys3.Icon.ItemLookChangeWnd_SlotBg_ArmorLook");	
	}
	else if( eShapeWindow == SWT_Hair_Accessary )
	{
		RestoreItemSlotBackTex.SetTexture("BranchSys3.Icon.ItemLookChangeWnd_SlotBg_Cap");			
		//RestoreItemSlotBackTex.SetTexture("BranchSys3.Icon.ItemLookChangeWnd_SlotBg_CapLook");	
	}
	else
	{
		RestoreItemSlotBackTex.SetTexture("BranchSys3.Icon.ItemLookChangeWnd_SlotBg_Equip");					
	}
}

function ResetUI()
{
	OkBtn.HideWindow();
	EnchantProgressAnim.HideWindow();
	
	EnchantProgressAnim.HideWindow();
	EnchantProgressAnim.SetTexture("l2ui_ct1.ItemEnchant_DF_Effect_Loading_01");
	EnchantProgressAnim.HideWindow();
				
	ExitBtn.ShowWindow();
	EnchantBtn.ShowWindow();
	EnchantBtn.DisableWindow();
	OkBtn.HideWindow();
	
	WeaponItemSlot.SetAlpha(255,0);

	StoneItemSlot.Clear();
	WeaponItemSlot.Clear();	
	LookItemSlot.Clear();
	RestoreItemSlot.Clear();
	EnchantedItemSlot.Clear();

	EnchantedItemSlotBackTex.HideWindow();
	
	m_hItemLookChangeWndEnchantProgress.SetProgressTime(1500);
	m_hItemLookChangeWndEnchantProgress.SetPos(0);
		
	m_hItemLookChangeWndEnchantProgress.Reset();
	
	DropHighlight_WeaponItem.SetTexture("L2UI_ch3.RefineryWnd.refineslot1");
	DropHighlight_LookItem.SetTexture("L2UI_ch3.RefineryWnd.refineslot1");
	DropHighlight_RestoreItem.SetTexture("L2UI_ch3.RefineryWnd.refineslot1");
	
	WeaponItemInfo.ID.ClassID = 0;
	WeaponItemInfo.ID.ServerID = 0;
	LookWeaponItemInfo.ID.ClassID = 0;
	LookWeaponItemInfo.ID.ServerID = 0;
	mPriceAdena = 0;
	
	bItemLookEnchantStart = false; // branch 111109
	
}      

function ItemLookChangeThreeSlot()
{
	RestoreSlotTxt.HideWindow();
		
	RestoreItemSlot.HideWindow();
	RestoreItemSlotBackTex.HideWindow();
	DropHighlight_RestoreItem.HideWindow();
	
	StoneItemSlot.SetAnchor( "ItemLookChangeWnd", "TopLeft", "TopLeft", 141, 61 );
	StoneItemSlot.ClearAnchor();
	StoneItemSlot.ShowWindow();
	StoneItemSlotBackTex.ShowWindow();	
	
	WeaponItemSlot.SetAnchor( "ItemLookChangeWnd", "TopLeft", "TopLeft", 79, 107 );
	WeaponItemSlot.ClearAnchor();
	WeaponItemSlot.ShowWindow();
	WeaponItemSlotBackTex.ShowWindow();	
		
	LookItemSlot.SetAnchor( "ItemLookChangeWnd", "TopLeft", "TopLeft", 203, 107 );
	LookItemSlot.ClearAnchor();
	LookItemSlot.ShowWindow();
	LookItemSlotBackTex.ShowWindow();	
	
	WeaponSlotTxt.SetText(GetSystemString(5085));	
	WeaponSlotTxt.ShowWindow();
	LookSlotTxt.ShowWindow();
	
	DropHighlight_StoneItem.ShowWindow();
	DropHighlight_WeaponItem.ShowWindow();
	DropHighlight_LookItem.HideWindow();
	
	if( eShapeWindow == SWT_Weapon )
	{
		Me.SetWindowTitle(GetSystemString(5083));
		InstructionTxt.SetText(GetSystemString(5088));	//가공을 원하는 무기를 드래그하여 옮겨 주십시오.
	}
	else if( eShapeWindow == SWT_Armor )
	{
		Me.SetWindowTitle(GetSystemString(5102));
		InstructionTxt.SetText(GetSystemString(5104));	//가공을 원하는 방어구를 드래그하여 옮겨 주십시오
	}
	else if( eShapeWindow == SWT_Hair_Accessary )
	{
		Me.SetWindowTitle(GetSystemString(5112));
		InstructionTxt.SetText(GetSystemString(5116));	//가공을 원하는 헤어 액세서리를 드래그하여 옮겨 주십시오.
	}
	
		
	AdenaText.SetText( string(mPriceAdena) );	

}

function RestoreLookChangeTwoSlot()
{		
	WeaponSlotTxt.HideWindow();
	LookSlotTxt.HideWindow();
	
	StoneItemSlot.HideWindow();			
	StoneItemSlotBackTex.HideWindow();	
	
	LookItemSlot.HideWindow();
	LookItemSlotBackTex.HideWindow();	
		
	WeaponItemSlot.SetAnchor( "ItemLookChangeWnd", "TopLeft", "TopLeft", 79, 107 );
	WeaponItemSlot.ClearAnchor();
	WeaponItemSlot.ShowWindow();
	WeaponItemSlotBackTex.ShowWindow();	
		
	RestoreItemSlot.SetAnchor( "ItemLookChangeWnd", "TopLeft", "TopLeft", 203, 107 );
	RestoreItemSlot.ClearAnchor();
	RestoreItemSlot.ShowWindow();
	RestoreItemSlotBackTex.ShowWindow();
		
	RestoreSlotTxt.ShowWindow();	
	DropHighlight_RestoreItem.ShowWindow();
	
	DropHighlight_WeaponItem.SetTexture("L2UI_ch3.RefineryWnd.refineslot2");
	DropHighlight_WeaponItem.ShowWindow();
	DropHighlight_LookItem.HideWindow();
	DropHighlight_StoneItem.HideWindow();
	
	if( eShapeWindow == SWT_Weapon )
	{
		Me.SetWindowTitle(GetSystemString(5084));
		InstructionTxt.SetText(GetSystemString(5090));	//	복원을 원하는 무기를 드래그 하여 옮겨 주십시오
	}
	else if( eShapeWindow == SWT_Armor )
	{
		Me.SetWindowTitle(GetSystemString(5103));
		InstructionTxt.SetText(GetSystemString(5105));	//복원을 원하는 방어구를 드래그 하여 옮겨 주십시오.
	}
	else if( eShapeWindow == SWT_Hair_Accessary )
	{
		Me.SetWindowTitle(GetSystemString(5113));
		InstructionTxt.SetText(GetSystemString(5117));	//복원을 원하는 헤어 액세서리를 드래그하여 옮겨 주십시오.
	}
	else
	{
		Me.SetWindowTitle(GetSystemString(5114));
		InstructionTxt.SetText(GetSystemString(5118));	//복원을 원하는 방어구를 드래그 하여 옮겨 주십시오.
	}	
	
	
	AdenaText.SetText( string(mPriceAdena) );	
}

function OnLookChangeStart()
{
	local Rect Item1Rect;
	local Rect Item2Rect;
	local Rect Item3Rect;
	local Rect ResultRect;
	
	//DropHighlight_CloverItem.SetTexture("L2UI_ch3.RefineryWnd.refineslot2");
	EnchantProgressAnim.SetLoopCount( C_ANIMLOOPCOUNT );
	EnchantProgressAnim.Stop();
	EnchantProgressAnim.Play();
	Playsound("ItemSound3.enchant_process");
	EnchantProgressAnim.ShowWindow();
	bItemLookChangebool = true;
	
	m_hItemLookChangeWndEnchantProgress.Start();
		
	Item1Rect = StoneItemSlot.GetRect();
	Item2Rect = WeaponItemSlot.GetRect();
	Item3Rect = LookItemSlot.GetRect();
	ResultRect = EnchantedItemSlot.GetRect();

	StoneItemSlot.Move( ResultRect.nX - Item1Rect.nX, ResultRect.nY - Item1Rect.nY, 1.5f );
	WeaponItemSlot.Move( ResultRect.nX - Item2Rect.nX, ResultRect.nY - Item2Rect.nY, 1.5f );
	LookItemSlot.Move( ResultRect.nX - Item3Rect.nX, ResultRect.nY - (Item3Rect.nY), 1.5f );	

	StoneItemSlotBackTex.HideWindow();
	WeaponItemSlotBackTex.HideWindow();
	LookItemSlotBackTex.HideWindow();
	
	WeaponSlotTxt.HideWindow();
	LookSlotTxt.HideWindow();
	
	ExitBtn.SetNameText( GetSystemString(141) );
	EnchantBtn.SetNameText( GetSystemString(428) );
}

function ProcCancel()
{
	mPriceAdena = 0;
	eShapeShiftingWindow = SST_WindowInvalid;
	bItemLookChangebool = false;
	m_hItemLookChangeWndEnchantProgress.Stop();
	EnchantProgressAnim.Stop();

}


function OnTextureAnimEnd( AnimTextureHandle a_WindowHandle )
{

	//~ local ItemID SupportID;
	EnchantProgressAnim.HideWindow();
	EnchantProgressAnim.Stop();
	EnchantProgressAnim.HideWindow();
	switch ( a_WindowHandle )
	{
		case EnchantProgressAnim:
			if (bItemLookChangebool)
			{
				bItemLookChangebool = false;
				class'ItemLookChangeAPI'.static.RequestItemLookChange(WeaponItemInfo.ID);
			}
			else
			{
			}
					
		break;
	}
	EnchantProgressAnim.HideWindow();

}

function OnHide()
{
	mPriceAdena = 0;
	bItemLookChangebool = false;
	eShapeShiftingWindow = SST_WindowInvalid;
	class'ItemLookChangeAPI'.static.RequestExCancelItemLookChange();
}


function OnDropItem( String a_WindowID, ItemInfo a_ItemInfo, int X, int Y)
{
	if( bItemLookEnchantStart ) return; //branch 111109
	
	TempDropItemInfo = a_ItemInfo;			
	
	switch (a_WindowID)
	{
		case "WeaponItemSlot":							
				//mEnchantItemType = a_ItemInfo.SlotBitType;
				//Debug ("EnchantItemID" @  a_ItemInfo.ID.ServerID @ a_ItemInfo.ID.ClassID);
				class'ItemLookChangeAPI'.static.RequestExTryToPut_Shape_Shifting_TargetItem( a_ItemInfo.ID );						
		break;		
		
		case "LookItemSlot":
			if( eShapeShiftingWindow != SST_WindowFixed )
			{				
				class'ItemLookChangeAPI'.static.RequestExTryToPut_Shape_Shifting_EnchantSupportItem( WeaponItemInfo.ID, a_ItemInfo.ID );			
			}
									
		break;
		case "RestoreItemSlot":			
			//mEnchantItemType = a_ItemInfo.SlotBitType;
			//Debug ("EnchantItemID" @  a_ItemInfo.ID.ServerID @ a_ItemInfo.ID.ClassID);
			class'ItemLookChangeAPI'.static.RequestExTryToPut_Shape_Shifting_TargetItem( a_ItemInfo.ID );
		break;
	}
}


function HandlePutTargetItemResult(string param)
{
	local int ResultID;
	local INT64 Adena;
	ParseInt(Param, "Result", ResultID);
	ParseINT64(Param, "Adena", Adena);
		
	if (ResultID <=0 )
	{
		//가공 할 수 없는 아이템입니다.
		DialogHide();	// 이미 창이 떠있다면 지워준다.
		DialogShow(DialogModalType_Modalless,DialogType_Notice, GetSystemString(5091), string(Self));		
		DialogSetID(DIALOG_ONLY_NOTICE);		
	}
	else
	{
		WeaponItemInfo = TempDropItemInfo;
		WeaponItemSlot.SetItem( 0, WeaponItemInfo );
		WeaponItemSlot.AddItem( WeaponItemInfo );
				
		//~ DropHighlight_enchantitem.HideWindow();
		//DropHighlight_enchantitem.SetTexture("L2UI_ch3.RefineryWnd.refineslot2");
		//DropHighlight_enchantscript.SetTexture("L2UI_ch3.RefineryWnd.refineslot2");
		//~ DropHighlight_CloverItem.SetTexture("L2UI_ch3.RefineryWnd.refineslot2");
		// debug("====> " @ mEnchantItemType);
	
		DropHighlight_WeaponItem.SetTexture("L2UI_ch3.RefineryWnd.refineslot2");
		DropHighlight_LookItem.ShowWindow();
					
		StoneItemSlotBackTex.HideWindow();
		WeaponItemSlotBackTex.HideWindow();
		//~ LookItemSlotBackTex.HideWindow();
		//~ EnchantedItemSlotBackTex.HideWindow();
		
		if(eShapeShiftingWindow == SST_WindowFixed)
		{
			EnchantBtn.EnableWindow();
			InstructionTxt.SetText(MakeFullSystemMsg( GetSystemMessage(6075), WeaponItemInfo.Name )); //시작 버튼을 누르게 되면 $s1의 외형이 가공됩니다. 외형 추출된 아이템은 삭제됩니다.
		}
		else
		{
			InstructionTxt.SetText(GetSystemString(5089));
		}
		
		mPriceAdena = Adena;
		AdenaText.SetText( string(mPriceAdena) );	
	}
}


function HandletPutSupportItemResult(string param)
{
	local string StartTxt ;
	local int ResultID;
	ParseInt(Param, "Result", ResultID);
			
	if (ResultID <= 0)
	{
		//추출할 수 없는 아이템입니다		
		DialogHide();	// 이미 창이 떠있다면 지워준다.
		DialogShow(DialogModalType_Modalless,DialogType_Notice, GetSystemString(5092), string(Self));		
		DialogSetID(DIALOG_ONLY_NOTICE);		
	}
	else 
	{
		LookWeaponItemInfo = TempDropItemInfo;	
		LookItemSlot.SetItem( 0, LookWeaponItemInfo );
		LookItemSlot.AddItem( LookWeaponItemInfo );
		//~ DropHighlight_enchantitem.HideWindow();
		
		DropHighlight_LookItem.SetTexture("L2UI_ch3.RefineryWnd.refineslot2");
		
		StoneItemSlotBackTex.HideWindow();
		WeaponItemSlotBackTex.HideWindow();
		LookItemSlotBackTex.HideWindow();
		
		EnchantBtn.EnableWindow();
		
		if ( eShapeShiftingWindow == SST_WindowBlessed )
		{
			StartTxt = 	MakeFullSystemMsg( GetSystemMessage(6076), WeaponItemInfo.Name );
		}	
		else
		{
			StartTxt = 	MakeFullSystemMsg( GetSystemMessage(6075), WeaponItemInfo.Name );
		}	
		InstructionTxt.SetText( StartTxt );
	}	
}

function HandleLookChangeResult(string param)
{
	local int IntResult ;
	local int CurrentPeriod;
	local ItemID WeaponItemID ;
	local ItemID LookWeaponItemID ;
	local ItemInfo cResultWeaponItemID;

	local string EndTxt ;
	
	EnchantProgressAnim.HideWindow();
	//결과에 상관없이 무조건 Hide
	
	ParseInt(Param, "Result", IntResult );
	ParseInt(Param, "WeaponClassID", WeaponItemID.ClassID );
	ParseInt(Param, "LookWeaponClassID", LookWeaponItemID.ClassID );
	ParseInt(Param, "CurrentPeriod", CurrentPeriod ); //기간제 아이템 시간

	// 원래 장비의 인벤토리에 들어 있는 정보를 가져 오고..
	inventoryWndScript.getInventoryItemInfo(WeaponItemInfo.ID, cResultWeaponItemID);

	// Debug("룩 변경 창 바디파트> Look>" @ LookWeaponItemID.ClassID @ cResultLookWeaponItemID.BodyPart  @ "WeaponItem> " @ cResultWeaponItemID.ID.ClassID @ cResultWeaponItemID.BodyPart);
	// Debug("IntResult" @ IntResult);

	LookItemSlotBackTex.HideWindow();
	WeaponItemSlotBackTex.HideWindow();
	EnchantedItemSlotBackTex.HideWindow();
	LookItemSlotBackTex.HideWindow();
	
	EnchantBtn.HideWindow();
	ExitBtn.HideWindow();
		
	switch (IntResult)
	{
		// 실패
		case 0:
			bItemLookChangedbool = true; 
			EnchantProgressAnim.HideWindow();
			EnchantProgressAnim.SetTexture("l2ui_ct1.ItemEnchant_DF_Effect_Failed_01");
			EnchantProgressAnim.SetLoopCount( C_ANIMLOOPCOUNT );
			EnchantProgressAnim.Stop();
			EnchantProgressAnim.Play();
			Playsound("ItemSound3.enchant_fail");
			EnchantProgressAnim.ShowWindow();
		
			BackPattern.SetAlpha(0, 0);
			BackPattern.ShowWindow();
			BackPattern.SetAlpha(255, 2);
		
			EnchantedItemSlot.SetAlpha(0);
			EnchantedItemSlot.Clear();
			//EnchantedItemSlot.SetItem( 0, cResultWeaponItemID );
			EnchantedItemSlot.AddItem( cResultWeaponItemID );
			EnchantedItemSlot.ShowWindow();
			EnchantedItemSlot.SetAlpha(255,2);
			EndTxt = MakeFullSystemMsg(GetSystemMessage(6078), cResultWeaponItemID.Name );			
			InstructionTxt.SetText(EndTxt);
		
			LookItemSlot.HideWindow();
			WeaponItemSlot.HideWindow();
			//~ WeaponItemSlot.SetAlpha(0, 3);
			//~ WeaponItemSlot.HideWindow();
			StoneItemSlot.HideWindow();
			LookItemSlot.HideWindow();
			break;	

		// 성공
		case 1:
			bItemLookChangedbool = true;
			EnchantProgressAnim.HideWindow();
			EnchantProgressAnim.SetTexture("l2ui_ct1.ItemEnchant_DF_Effect_Success_00");
			EnchantProgressAnim.SetLoopCount( 1 );
			EnchantProgressAnim.Stop();
			EnchantProgressAnim.Play();
			Playsound("ItemSound3.enchant_success");
			EnchantProgressAnim.ShowWindow();
		
			BackPattern.SetAlpha(0, 0);
			BackPattern.ShowWindow();
			BackPattern.SetAlpha(255, 2);
			
			// 기간제 (시간)
			cResultWeaponItemID.CurrentPeriod      = CurrentPeriod;
			
			// 외형 변경 ID, 이름
			cResultWeaponItemID.LookChangeItemID   = LookWeaponItemID.ClassID;			
			cResultWeaponItemID.LookChangeItemName = class'UIDATA_ITEM'.static.GetItemName(LookWeaponItemID);

			//branch 111109
			//원피스나 드레스면						
			//기존 BodyPart가 9번으로 체크되어 있었음
			//28번으로 수정 2014-01-14 정우균 TTP:63216
			if( cResultWeaponItemID.BodyPart == 28 )
			{
				cResultWeaponItemID.LookChangeIconPanel	 = "BranchSys3.Icon.pannel_lookChange_All";
			}
			else
			{
				cResultWeaponItemID.LookChangeIconPanel = "BranchSys3.Icon.pannel_lookChange";
			}
			//end of branch
						
			EnchantedItemSlot.SetAlpha(0);
			EnchantedItemSlot.Clear();
			//EnchantedItemSlot.SetItem( 0, cResultWeaponItemID );
			EnchantedItemSlot.AddItem( cResultWeaponItemID );			
			EnchantedItemSlot.ShowWindow();
			EnchantedItemSlot.SetAlpha(255,2);
						
			EndTxt = MakeFullSystemMsg(GetSystemMessage(6085), cResultWeaponItemID.Name, cResultWeaponItemID.LookChangeItemName );			
			InstructionTxt.SetText(EndTxt);
			
			LookItemSlot.HideWindow();
			//~ WeaponItemSlot.SetAlpha(0, 2);
			WeaponItemSlot.HideWindow();
			StoneItemSlot.HideWindow();
			LookItemSlot.HideWindow();
			break;		

		default:
			EnchantProgressAnim.HideWindow();
			if (!bItemLookChangedbool) Me.HideWindow();
			break;
	}

	OkBtn.ShowWindow();	
}

function HandleRestorePutTargetItemResult(string param)
{
	local int ResultID;
	local INT64 Adena;
	ParseInt(Param, "Result", ResultID);
	ParseINT64(Param, "Adena", Adena);
		
	if (ResultID <=0 )
	{
		//조건에 맞지 않는 아이템입니다.
		DialogHide();	// 이미 창이 떠있다면 지워준다.
		DialogShow(DialogModalType_Modalless,DialogType_Notice, GetSystemString(5093), string(Self));		
		DialogSetID(DIALOG_ONLY_NOTICE);		
	}
	else
	{
		WeaponItemInfo = TempDropItemInfo;
		RestoreItemSlot.SetItem( 0, WeaponItemInfo );
		RestoreItemSlot.AddItem( WeaponItemInfo );
						
		DropHighlight_RestoreItem.SetTexture("L2UI_ch3.RefineryWnd.refineslot2");
				
		RestoreItemSlotBackTex.HideWindow();	
		
		EnchantBtn.EnableWindow();	
		
		mPriceAdena = Adena;
		AdenaText.SetText( string(mPriceAdena) );	
	}
}


function OnRestoreLookChangeStart()
{
	local Rect Item1Rect;
	local Rect Item2Rect;
	local Rect ResultRect;
	
	//DropHighlight_CloverItem.SetTexture("L2UI_ch3.RefineryWnd.refineslot2");
	EnchantProgressAnim.SetLoopCount( C_ANIMLOOPCOUNT );
	EnchantProgressAnim.Stop();
	EnchantProgressAnim.Play();
	Playsound("ItemSound3.enchant_process");
	EnchantProgressAnim.ShowWindow();
	bItemLookChangebool = true;
	
	m_hItemLookChangeWndEnchantProgress.Start();
		
	Item1Rect = RestoreItemSlot.GetRect();
	Item2Rect = WeaponItemSlot.GetRect();
	ResultRect = EnchantedItemSlot.GetRect();

	RestoreItemSlot.Move( ResultRect.nX - Item1Rect.nX, ResultRect.nY - (Item1Rect.nY), 1.5f );	
	WeaponItemSlot.Move( ResultRect.nX - Item2Rect.nX, ResultRect.nY - Item2Rect.nY, 1.5f );
	
	RestoreItemSlotBackTex.HideWindow();
	WeaponItemSlotBackTex.HideWindow();

	RestoreSlotTxt.HideWindow();
		
	ExitBtn.SetNameText( GetSystemString(141) );
	EnchantBtn.SetNameText( GetSystemString(428) );
}

// 장비 복원
function HandlerRestoreLookChangeResult(string param)
{
	local int IntResult ;
	local ItemID WeaponItemID ;	
	local ItemInfo cResultWeaponItemID;
	local string EndTxt ;
	
	EnchantProgressAnim.HideWindow();
	//결과에 상관없이 무조건 Hide
	//~ Me.HideWindow();
	//~ Clear();
	//debug (param);
	ParseInt(Param, "Result", IntResult );		
	ParseInt(Param, "WeaponClassID", WeaponItemID.ClassID );

	// 원래 장비의 인벤토리에 들어 있는 정보를 가져 오고..갱신된 정보가 아니라 바로 전에 있던 정보이다. 	
	inventoryWndScript.getInventoryItemInfo(WeaponItemInfo.ID, cResultWeaponItemID);
	
	//if( WeaponItemID.ClassID > 0 )
	//{
	//	class'UIDATA_ITEM'.static.GetItemInfo(WeaponItemID, cResultWeaponItemID );
	//}
	//else
	//{
	//	cResultWeaponItemID = WeaponItemInfo;
	//}
	
	EnchantBtn.HideWindow();
	ExitBtn.HideWindow();
		
	switch (IntResult)
	{		
		case 0:
			bItemLookChangedbool = true; 
			EnchantProgressAnim.HideWindow();
			EnchantProgressAnim.SetTexture("l2ui_ct1.ItemEnchant_DF_Effect_Failed_01");
			EnchantProgressAnim.SetLoopCount( C_ANIMLOOPCOUNT );
			EnchantProgressAnim.Stop();
			EnchantProgressAnim.Play();
			Playsound("ItemSound3.enchant_fail");
			EnchantProgressAnim.ShowWindow();
		
			BackPattern.SetAlpha(0, 0);
			BackPattern.ShowWindow();
			BackPattern.SetAlpha(255, 2);
					
			//debug ("Count2" @ string(int(Count)));
			EnchantedItemSlot.SetAlpha(0);
			//EnchantedItemSlot.SetItem( 0, cResultWeaponItemID );
			EnchantedItemSlot.Clear();
			EnchantedItemSlot.AddItem( cResultWeaponItemID );
			EnchantedItemSlot.ShowWindow();
			EnchantedItemSlot.SetAlpha(255,2);
			EndTxt = MakeFullSystemMsg(GetSystemMessage(6078), cResultWeaponItemID.Name );			
			InstructionTxt.SetText(EndTxt);
		
			LookItemSlot.HideWindow();
			WeaponItemSlot.HideWindow();
			//~ WeaponItemSlot.SetAlpha(0, 3);
			//~ WeaponItemSlot.HideWindow();
			
			WeaponItemSlot.HideWindow();
			RestoreItemSlot.HideWindow();									
		break;		
		case 1:
			bItemLookChangedbool = true;
			EnchantProgressAnim.HideWindow();
			EnchantProgressAnim.SetTexture("l2ui_ct1.ItemEnchant_DF_Effect_Success_00");
			EnchantProgressAnim.SetLoopCount( 1 );
			EnchantProgressAnim.Stop();
			EnchantProgressAnim.Play();
			Playsound("ItemSound3.enchant_success");
			EnchantProgressAnim.ShowWindow();
		
			BackPattern.SetAlpha(0, 0);
			BackPattern.ShowWindow();
			BackPattern.SetAlpha(255, 2);
		
			
			// 기간제 (시간), 외형 변경 아이템이였고, 기간제 가공이였다면...
			if(cResultWeaponItemID.LookChangeItemID > 0) cResultWeaponItemID.CurrentPeriod = 0;

			// 외형 변경 ID, 이름 초기화 
			cResultWeaponItemID.LookChangeItemID   = 0;
			cResultWeaponItemID.LookChangeItemName = "";
			cResultWeaponItemID.LookChangeIconID = 0;
			cResultWeaponItemID.LookChangeIconPanel = "";

			//EnchantedItemSlot.SetItem( 0, cResultWeaponItemID );
			EnchantedItemSlot.Clear();
			EnchantedItemSlot.AddItem( cResultWeaponItemID );
			
			EndTxt = MakeFullSystemMsg(GetSystemMessage(6086), cResultWeaponItemID.Name );
			
			InstructionTxt.SetText(EndTxt);
			EnchantedItemSlot.SetAlpha(0);
			EnchantedItemSlot.ShowWindow();
			EnchantedItemSlot.SetAlpha(255,2);
			
			WeaponItemSlot.HideWindow();
			RestoreItemSlot.HideWindow();						
		break;
	}

	OkBtn.ShowWindow();	
}

function SetIsShopping(bool isShopping)
{
	bIsShopping = isShopping;
	// debug("=============isShopping : " $ bIsShopping);
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	OnClickButton( "ExitBtn" );
}
defaultproperties
{
}
