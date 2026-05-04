class InventoryViewer extends UICommonAPI;

var WindowHandle     Me;
var ItemWindowHandle totalInven_ItemWnd;

var int baseWidth, baseHeight;
var InventoryWnd inventoryWndScript;
var TextBoxHandle   InvenoryCount;
var TextBoxHandle   AdenaText;	

var WindowHandle     ParentWindow;

function OnRegisterEvent()
{
	RegisterEvent(EV_InventoryClear);
	RegisterEvent(EV_AdenaInvenCount);
	RegisterEvent(EV_SetMaxCount);
}

function OnLoad()
{
	Initialize();
}

function Initialize()
{
	Me                 = GetWindowHandle( getCurrentWindowName(String(self)) );
	totalInven_ItemWnd = GetItemWindowHandle( getCurrentWindowName(String(self)) $ ".InventoryItem_ItemWnd" );
	InvenoryCount = GetTextBoxHandle( getCurrentWindowName(String(self)) $ ".InventoryCount_TextBox" );
	AdenaText = GetTextBoxHandle( getCurrentWindowName(String(self)) $ ".AdenaText" );
	
	inventoryWndScript = inventoryWnd(GetScript("inventoryWnd"));
}

function OnDefaultPosition()
{

}

function OnLButtonDown(WindowHandle a_WindowHandle, int nX, int nY)
{
	// Debug("a_WindowHandle-> " @ a_WindowHandle.GetWindowName() @ nX @ nY);
	ParentWindow.SetFocus();
	Me.SetFocus();
}

//function OnSetFocus( WindowHandle a_WindowHandle, bool bFocused )
//{
//	Debug("a_WindowHandle " @ a_WindowHandle.GetWindowName() @ bFocused);

//	if(a_WindowHandle.GetWindowName() == Me.getWin && bFocused == true)
//	{
//		if(ParentWindow.GetWindowName() != "")
//		{
//			ParentWindow.SetFocus();		
//			Me.SetFocus();
//		}
//	}   
//}

function showWindowByParentWindow(WindowHandle pWnd, optional bool bToggleShow)
{	
	ParentWindow = pWnd;
	//getInstanceL2Util().windowMoveToSide(pWnd, Me);	
	getInstanceL2Util().windowAnchorToSide(pWnd, Me, 2, 29);	

	if (!Me.IsShowWindow())
	{
		Me.ShowWindow();
		Me.SetFocus();
		pWnd.SetFocus();
	}
	else 
	{
		if(bToggleShow) Me.HideWindow();
	}
}

function SetAdenaText()
{
	local string adenaString;
	
	adenaString = MakeCostString( string(GetAdena()) );

	AdenaText.SetText(adenaString);
	AdenaText.SetTooltipString( ConvertNumToText(string(GetAdena())) );
}

function OnShow()
{
	SetAdenaText();
	SetItemCount();
	syncInventory();
}

function onClickButton ( string StrID )
{
	if ( StrID == "CloseButton")  Me.HideWindow();
}

function SetItemCount()
{
	local int limit;
	local int count;

	count = inventoryWndScript.m_NormalInvenCount + inventoryWndScript.EquipItemGetItemNum();
	limit = inventoryWndScript.GetMyInventoryLimit();
	//Debug ( "(" $ count $ "/" $ limit $ ")");
	InvenoryCount.SetText("(" $ count $ "/" $ limit $ ")");

	getInstanceL2Util().ItemboxUpdate ( totalInven_ItemWnd , limit);
}

// 무기, 집혼석 관련 아이템 윈도우 업데이트
function syncInventory()
{
	local array<ItemInfo> itemArray, equipItemArray;
	local int i;//, totalLen;
	local ItemInfo kClearItem;

	kClearItem.IconName = "L2ui_ct1.emptyBtn";
	ClearItemID( kClearItem.ID );

	// 인벤에서, 아이템 목록, 착용한 장비 목록을 따로 얻어오기
	itemArray = getInstanceL2Util().SortItemArray ( inventoryWndScript.getInventoryAllItemArray(true)) ;
	equipItemArray = getInstanceL2Util().SortItemArray ( inventoryWndScript.getInventoryEquipItemArray() );			
	
	for(i = 0; i < equipItemArray.Length; i++) 
	{
		equipItemArray[i].ForeTexture = "L2UI_CT1.Icon.WearPanel";
		totalInven_ItemWnd.SetItem( i, equipItemArray[i]);
	}

	// 일반 아이템 추가
	for(i = 0; i < itemArray.Length ; i++) totalInven_ItemWnd.SetItem ( i + equipItemArray.Length, itemArray[i]);
	
	// 빈 아이템 추가
	for ( i = equipItemArray.Length + itemArray.Length ; i < inventoryWndScript.GetMyInventoryLimit() ; i ++ ) 
	{
		//Debug ("syncInventory" @  i );
		totalInven_ItemWnd.SetItem( i,  kClearItem ) ;
	}
}

function OnEvent(int Event_ID, string param)
{
	//debug("Inven Event ID :" $string(Event_ID)$" "$param);
	switch( Event_ID )
	{
		//case EV_InventoryAddItem:         
		//case EV_InventoryUpdateItem:    
		//case EV_InventoryClear:    
		//case EV_UpdateUserEquipSlotInfo:
	 //   case EV_InventoryItemListEnd:

		//case EV_UpdateUserInfo:
		case EV_AdenaInvenCount:
		case EV_SetMaxCount    :       //2070

			//Me.ShowWindow();
			if (Me.IsShowWindow()) 
			{
				SetAdenaText();
				SetItemCount();
				syncInventory();
			}
	    break;
	    case EV_InventoryClear :
			totalInven_ItemWnd.Clear();
	    break;
	    //case EV_SetMaxCount:
//			handleSetMaxCount();
		//break;

	}
}
/*
function handleSetMaxCount ()
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
}*/
defaultproperties
{
}
