//------------------------------------------------------------------------------------------------------------------------
// 집혼 UI 보조 인벤토리
//------------------------------------------------------------------------------------------------------------------------
class ItemLockSubWnd extends UICommonAPI;

const STATE_INSERT_WEAPON         = "STATE_INSERT_WEAPON";
const STATE_INSERT_ENSOULSTONE    = "STATE_INSERT_ENSOULSTONE";
const STATE_SELECT_ENSOUL         = "STATE_SELECT_ENSOUL";
const STATE_CONFIRM_ENSOUL        = "STATE_CONFIRM_ENSOUL";
const STATE_ASK_OVERWRITE         = "STATE_ASK_OVERWRITE";
const STATE_RESULT                = "STATE_RESULT";

var WindowHandle Me;

var ItemWindowHandle ItemLockSubWnd_Item1;

var L2Util util;
var InventoryWnd inventoryWndScript;
var ItemLockWnd ItemLockWndScript;


function Initialize()
{
	Me                 = GetWindowHandle( "ItemLockSubWnd" );

	ItemLockSubWnd_Item1 = GetItemWindowHandle( "ItemLockSubWnd.ItemLockSubWnd_Item1" );	
	
	util               = L2Util(GetScript("L2Util"));
	inventoryWndScript = inventoryWnd(GetScript("inventoryWnd"));

	ItemLockWndScript = ItemLockWnd ( GetScript( "ItemLockWnd"));
}

function OnLoad()
{
	Initialize();
}

function OnShow()
{
	
}

// 무기, 집혼석 관련 아이템 윈도우 업데이트
function syncInventory()
{
	local int i;
	local array<ItemInfo> itemArray;
	// Debug("EnsoulSubWnd_Tab" @ EnsoulSubWnd_Tab.GetTopIndex());
	itemArray = inventoryWndScript.getInventoryAllItemArray();
	ItemLockSubWnd_Item1.Clear();
	for (i = 0; i < itemArray.Length;i++)
	{
		// 장착 가능 아이템만 추가
//		Debug (  "bSecurityLockable:" $ 

//itemArray[i].bSecurityLockable ) ;
		if ( itemArray[i].bSecurityLockable ) 
		//if ( itemArray[i].ItemType  == EItemType.ITEM_WEAPON  || itemArray[i].ItemType  == EItemType.ITEM_ARMOR  || itemArray[i].ItemType  == EItemType.ITEM_ACCESSARY  )
		{			
			if ( ItemLockWndScript.currentWindowType == ItemLockWndScript.windowType.LOCK ) 
			{
				// 봉인 안 된 것만.
				if ( !itemArray[i].bSecurityLock ) ItemLockSubWnd_Item1.AddItem(itemArray[i]);
			}
			else 
			{
				// 봉인 된 것만.
				if ( itemArray[i].bSecurityLock ) ItemLockSubWnd_Item1.AddItem(itemArray[i]);
			}
		}	
	}
}

function setLock(bool bLock)
{

	if (bLock)
	{
		ItemLockSubWnd_Item1.DisableWindow();		
	}
	else
	{
		ItemLockSubWnd_Item1.EnableWindow();		
	}
}


function OnRClickItem( String strID, int index )
{
	OnDBClickItem(strID, index);
}

function OnDBClickItem( String strID, int index )
{
	local itemInfo info ; 
	
	ItemLockSubWnd_Item1.GetItem( index, info ) ;
	if( IsValidItemID( info.ID) ) ItemLockWndScript.setItemInfo ( info ) ;	
}
defaultproperties
{
}
