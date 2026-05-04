class WarehouseWnd extends UICommonAPI;

const KEEPING_PRICE = 30;			// 한칸 당 보관료

const DEFAULT_MAX_COUNT = 200;		// 개인 창고를 제외한 다른 창고들의 최대 개수

const DIALOG_TOP_TO_BOTTOM = 111;
const DIALOG_BOTTOM_TO_TOP = 222;

enum WarehouseCategory
{
	WC_None,			// dummy
	WC_Private,
	WC_Clan,
	WC_Castle,
	WC_Etc,
};

enum WarehouseType
{
	WT_Deposit,
	WT_Withdraw,
};

var WarehouseCategory	m_category;
var WarehouseType		m_type;
var int					m_maxPrivateCount;
// Added by JoeyPark 2010/09/09
var int					m_maxInventoryCount;
var int					m_curWarehouseCount;
var int					m_curInventoryCount;
var int                 m_numPossibleSlotCount;
// End adding
var String				m_WindowName;

var ItemWindowHandle	m_topList;
var ItemWindowHandle	m_bottomList;

var WindowHandle m_dialogWnd;

// 수량성아이템, 창고 보관 목록에 들어가 있는 리스트 
var array<int> hasStackableItemArray;

// 추가 (창고에 이미 있는 수량성 아이템)
function addHasStackableItemArray(int classID)
{
	//targetArray.Remove(0, targetArray.Length);
	// Debug("추가 " @ classID);	

	// 추가 한 아이템이 기존에 넣었던게 아니라면.. 
	if (findHasStackableItemArray(classID) == -1)
	{
		hasStackableItemArray[hasStackableItemArray.Length] = classID;
	}
	// Debug("hasStackableItemArray length -> " @ hasStackableItemArray.Length);
}

// 검색  (창고에 이미 있는 수량성 아이템)
function int findHasStackableItemArray(int classID)
{
	local int i, returnV;

	returnV = -1;

	// Debug("----------");

	for (i = 0; i < hasStackableItemArray.Length; i++)
	{	
		// Debug("==>" @ hasStackableItemArray[i]);
		
		if (hasStackableItemArray[i] == classID)			
		{
			returnV = i;
			break;
		}
	}
	
	return returnV;
}

// 삭제 (창고에 이미 있는 수량성 아이템)
function removeHasStackableItemArray(int classID)
{
	local int index;

	index = findHasStackableItemArray(classID);

	if (index != -1)
	{
		hasStackableItemArray.Remove(index, 1);
	}
}



function OnRegisterEvent()
{
	registerEvent( EV_WarehouseOpenWindow );
	registerEvent( EV_WarehouseAddItem );
	registerEvent( EV_WarehouseDeleteItem );
	registerEvent( EV_SetMaxCount );
	registerEvent( EV_DialogOK );
}

function OnLoad()
{
	SetClosingOnESC();

	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	InitHandle();
}

function onShow()
{
	// 배열 전체 삭제
	hasStackableItemArray.Remove(0, hasStackableItemArray.Length);

	// 지정한 윈도우를 제외한 닫기 기능 
	getInstanceL2Util().ItemRelationWindowHide(getCurrentWindowName(String(self)));

	PlayConsoleSound(IFST_WINDOW_OPEN);
} 

function onHide()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	// 배열 전체 삭제
	hasStackableItemArray.Remove(0, hasStackableItemArray.Length);
}

/*
function OnKeyDown(WindowHandle a_WindowHandle, EInputKey Key)
{
	if (a_WindowHandle == GetWindowHandle(String(self)))
	{
		bAltKey = class'InputAPI'.static.IsAltPressed();

		Debug("키입력 " @ bAltKey);
	}
}
*/

function InitHandle()
{
	if(CREATE_ON_DEMAND==0)
	{
		m_dialogWnd = GetHandle( "DialogBox" );
		m_topList = ItemWindowHandle( GetHandle( m_WindowName$".TopList" ) );
		m_bottomList = ItemWindowHandle( GetHandle( m_WindowName$".BottomList" ) );
	}
	else
	{
		m_dialogWnd = GetWindowHandle( "DialogBox" );
		m_topList = GetItemWindowHandle( m_WindowName$".TopList" );
		m_bottomList = GetItemWindowHandle( m_WindowName$".BottomList" );
	}
}

function Clear()
{
	m_type = WT_Deposit;
	m_category = WC_None;

	m_topList.Clear();
	m_bottomList.Clear();

	class'UIAPI_TEXTBOX'.static.SetText(m_WindowName $ ".PriceText", "0");
	class'UIAPI_TEXTBOX'.static.SetTooltipString(m_WindowName $ ".PriceText", "");

	class'UIAPI_TEXTBOX'.static.SetText(m_WindowName $ ".AdenaText", "0");
	class'UIAPI_TEXTBOX'.static.SetTooltipString(m_WindowName $ ".AdenaText", "");

	class'UIAPI_INVENWEIGHT'.static.ZeroWeight("WarehouseWnd.InvenWeight");
}

function OnEvent(int Event_ID,string param)
{
	switch( Event_ID )
	{
	case EV_WarehouseOpenWindow:
		HandleOpenWindow(param);
		break;
	case EV_WarehouseAddItem:
		HandleAddItem(param);
		break;
	case EV_WarehouseDeleteItem:
		HandleDeleteItem(param);
		break;
	case EV_SetMaxCount:
		HandleSetMaxCount(param);		
		break;
	case EV_DialogOK:
		HandleDialogOK();
		break;
	default:
		break;
	}
}

function OnClickButton( string ControlName )
{
	// Change by JoeyPark
	// 기존에 있던 UpButton, DownButton으로의 분기 삭제함. 더 이상 필요 없음.
	// End Change

	if( ControlName == "OKButton" )
	{
		HandleOKButton();
	}
	else if( ControlName == "CancelButton" )
	{
		Clear();
		HideWindow(m_WindowName);
	}
	else if (ControlName == "SortButton")
	{
		getInstanceL2Util().SortItem(m_topList);
	}
}

/**
 *  창고나 인벤에 수량성 아이템이 있나를 체크
 **/ 
function bool HasStackableItemCheck(int category, int itemClassID)
{
	local bool bReturn;

	bReturn = false;

	// 창고에 넣을때
	if (m_type == WT_Deposit)
	{
		bReturn = HasStackableItemInWareHouse(category, itemClassID);
		Debug("HasStackableItemInWareHouse " @ category @ " , " @ itemClassID);
	}
	//창고에서 꺼낼때 
	else 
	{
		bReturn = HasStackableItemInInventory(category, itemClassID);
		Debug("HasStackableItemInInventory " @ category @ " , " @ itemClassID);
	}

	return bReturn;
}

function OnDBClickItem( string ControlName, int index )
{
	local ItemInfo info;
	local int nitemCount;

	if(ControlName == "TopList")
	{
		if( index >= 0 )
		{
			m_topList.GetSelectedItem(info);
			// 최대 넣기 가능한 수가 

			// debug("ser:" @ info.Id.ServerID);
			// debug("class:" @ info.Id.ClassID);
	
			//debug("m_category" @ m_category);
			// debug("__class:" @ HasStackableItemInWareHouse(m_category, info.Id.ClassID));
			
			Debug("hasStackableItemArray.Length" @ hasStackableItemArray.Length);

			if (m_bottomList.GetItemNum() > 0) nItemCount = m_bottomList.GetItemNum() - hasStackableItemArray.Length;
			else nItemCount = 0;

			// (HasStackableItemInWareHouse(m_category, info.Id.ClassID) && IsStackableItem( info.ConsumeType ))
			// HasStackableItemInWareHouse : 창고에 수량성 아이템이 있나? 를 체크 
			if (m_numPossibleSlotCount > nItemCount || 
			    (HasStackableItemCheck(m_category, info.Id.ClassID) && IsStackableItem( info.ConsumeType )) && 
				 m_numPossibleSlotCount >= nItemCount)
			{				
				// Debug("info.AllItemCount:" @ info.AllItemCount);
				// Debug("info.ItemNum:" @ info.ItemNum);
				MoveItemTopToBottom( index, class'InputAPI'.static.IsAltPressed());
			}
			else 
			{
				// 창고에 넣을때
				if (m_type == WT_Deposit) AddSystemMessage(3674);
				// 창고에서 뺄때 
				else AddSystemMessage(3675);
			}
		}

	}
	else if(ControlName == "BottomList")
	{
		MoveItemBottomToTop( index, class'InputAPI'.static.IsAltPressed() );
	}

}

// 아이템을 클릭하였을 경우 (더블클릭 아님)
function OnClickItem( string ControlName, int index )
{
	if(ControlName == "TopList")
	{
		if( DialogIsMine() && m_dialogWnd.IsShowWindow())
		{
			DialogHide();
			m_dialogWnd.HideWindow();
		}		
		
	}
}

function OnDropItem( string strID, ItemInfo info, int x, int y)
{
	local int index;
	local int nItemCount;

	// debug("OnDropItem.Enchanted : " @ info.Enchanted);
	
	if( strID == "TopList" && info.DragSrcName == "BottomList" )
	{
		//index = m_bottomList.FindItem( info.ID );
		index = m_bottomList.FindItemWithAllProperty( info );

		if( index >= 0 )
		{			
			//if (HasStackableItemCheck(m_category, info.Id.ClassID)) 
			MoveItemBottomToTop( index, info.AllItemCount > 0 );
		}
	}
	else if( strID == "BottomList" && info.DragSrcName == "TopList" )
	{
		// Top-> Bottom

		//index = m_topList.FindItem( info.ID );
		index = m_topList.FindItemWithAllProperty( info );

		// Debug("m_numPossibleSlotCount" @ m_numPossibleSlotCount);
		// Debug("m_bottomList.GetItemNum()" @ m_bottomList.GetItemNum());

		if (m_bottomList.GetItemNum() > 0) nItemCount = m_bottomList.GetItemNum() - hasStackableItemArray.Length;
		else nItemCount = 0;

		if( index >= 0 )
		{
			// Debug("hasStackableItemArray.Length" @ hasStackableItemArray.Length);
			// 최대 넣기 가능한 수가 
			if (m_numPossibleSlotCount > nItemCount || 
				(HasStackableItemCheck(m_category, info.Id.ClassID) && IsStackableItem( info.ConsumeType )) && 
				 m_numPossibleSlotCount >= nItemCount)
			{
				MoveItemTopToBottom( index, info.AllItemCount > 0 );
			}
			else
			{
				// 창고에 넣을때
				if (m_type == WT_Deposit) AddSystemMessage(3674);
				// 창고에서 뺄때 
				else AddSystemMessage(3675);
			}
		}
	}

}

function MoveItemTopToBottom( int index, bool bAllItem )
{
	local ItemInfo topInfo, bottomInfo;
	local int bottomIndex;
	if( m_topList.GetItem( index, topInfo) )
	{
		// 1일경우 수량을 입력하는 다이얼로그는 출력하지 않는다. 
		if( !bAllItem && IsStackableItem( topInfo.ConsumeType ) && (topInfo.ItemNum>1) )		// stackable?
		{
			DialogSetID( DIALOG_TOP_TO_BOTTOM );
			DialogSetReservedItemID( topInfo.ID );
			DialogSetParamInt64( topInfo.ItemNum );
			DialogSetDefaultOK();	
			DialogShow(DialogModalType_Modalless, DialogType_NumberPad, MakeFullSystemMsg( GetSystemMessage(72), topInfo.Name, "" ), string(Self) );
		}
		else
		{
			bottomIndex = m_bottomList.FindItem( topInfo.ID );

			if( bottomIndex != -1 && IsStackableItem( topInfo.ConsumeType ) )				// 숫자만 합치기
			{
				m_bottomList.GetItem( bottomIndex, bottomInfo );
				bottomInfo.ItemNum += topInfo.ItemNum;
				m_bottomList.SetItem( bottomIndex, bottomInfo );
			}
			else
			{
				m_bottomList.AddItem( topInfo );
			}

			m_topList.DeleteItem( index );		// 물건을 팔 경우 자신의 인벤토리 목록에서 아이템을 제거

			// 창고에서 물건을 찾을때....
			if( m_type == WT_Withdraw )
			{
				class'UIAPI_INVENWEIGHT'.static.AddWeight( "WarehouseWnd.InvenWeight", topInfo.ItemNum * topInfo.Weight );		// 무게 바에 더해주기
			}
			else if (m_type == WT_Deposit)
			{
				class'UIAPI_INVENWEIGHT'.static.ReduceWeight("WarehouseWnd.InvenWeight", topInfo.ItemNum * topInfo.Weight);
			}
			// 창고에 수량성, 아이템이 존재 하면.. 카운트를 하지 않기 위해 배열에 저장
			if (HasStackableItemCheck(m_category, topInfo.Id.ClassID))
			{
				addHasStackableItemArray(topInfo.Id.ClassID);
			}

			AdjustPrice();
			AdjustCount();
		}
	}
}

function MoveItemBottomToTop( int index, bool bAllItem )
{
	local ItemInfo bottomInfo, topInfo;
	local int	topIndex;
	if( m_bottomList.GetItem(index, bottomInfo) )
	{
		if( !bAllItem && IsStackableItem( bottomInfo.ConsumeType ) && (bottomInfo.ItemNum > 1) )		// 개수 물어보기
		{
			DialogSetID( DIALOG_BOTTOM_TO_TOP );
			DialogSetReservedItemID( bottomInfo.ID );
			DialogSetParamInt64( bottomInfo.ItemNum );
			DialogSetDefaultOK();
			DialogShow(DialogModalType_Modalless, DialogType_NumberPad, MakeFullSystemMsg( GetSystemMessage(72), bottomInfo.Name, "" ), string(Self) );
		}
		else
		{
			topIndex = m_topList.FindItem( bottomInfo.ID );
			if( topIndex != -1 && IsStackableItem( bottomInfo.ConsumeType ) )				// 숫자만 합치기
			{
				m_topList.GetItem( topIndex, topInfo );
				topInfo.ItemNum += bottomInfo.ItemNum;
				m_topList.SetItem( topIndex, topInfo );
			}
			else
			{
				m_topList.AddItem( bottomInfo );
			}
			m_bottomList.DeleteItem( index );

			if( m_type == WT_Withdraw )
				class'UIAPI_INVENWEIGHT'.static.ReduceWeight( "WarehouseWnd.InvenWeight", bottomInfo.ItemNum * bottomInfo.Weight );		// 무게 바에서 빼 주시
			else if (m_type == WT_Deposit)
				class'UIAPI_INVENWEIGHT'.static.AddWeight("WarehouseWnd.InvenWeight", bottomInfo.ItemNum * bottomInfo.Weight);
			
			// 창고에 수량성, 아이템이 존재 하면.. 카운트를 하지 않기 위해 
			// 배열에 넣었던 것을 다시 삭제 해준다. 
			if (findHasStackableItemArray(bottomInfo.Id.ClassID) != -1)
			{
				removeHasStackableItemArray(bottomInfo.Id.ClassID);
			}

			AdjustPrice();
			AdjustCount();
		}
	}
}

function HandleDialogOK()
{
	local int id, index, topIndex;
	local INT64 num;
	local ItemInfo info, topInfo;
	local ItemID cID;

	if( DialogIsMine() )
	{
		id = DialogGetID();
		// Change by JoeyPark
		num = INT64( DialogGetString() );
		// End Change
		cID = DialogGetReservedItemID();
		if( id == DIALOG_TOP_TO_BOTTOM && num > 0 )
		{
			topIndex = m_topList.FindItem( cID );
			if( topIndex >= 0 )
			{
				m_topList.GetItem( topIndex, topInfo );
				// Change by JoeyPark
				num = Min64( num, topInfo.ItemNum );
				// End Change
				index = m_bottomList.FindItem( cID );
				if( index >= 0 )
				{
					m_bottomList.GetItem( index, info );
					info.ItemNum += num;
					m_bottomList.SetItem( index, info );
				}
				else
				{
					info = topInfo;
					info.ItemNum = num;
					info.bShowCount = false;
					m_bottomList.AddItem( info );
				}
	
				if( m_type == WT_Withdraw )
					class'UIAPI_INVENWEIGHT'.static.AddWeight("WarehouseWnd.InvenWeight", num * info.Weight);		// 무게 바에 더해주기
				else if (m_type == WT_Deposit)
					class'UIAPI_INVENWEIGHT'.static.ReduceWeight("WarehouseWnd.InvenWeight", num * info.Weight);

				topInfo.ItemNum -= num;
				if( topInfo.ItemNum <= 0 )
					m_topList.DeleteItem( topIndex );
				else
					m_topList.SetItem( topIndex, topInfo );
				
				// 창고에 수량성, 아이템이 존재 하면.. 카운트를 하지 않기 위해 배열에 저장
				if (HasStackableItemCheck(m_category, topInfo.Id.ClassID))
				{
					addHasStackableItemArray(topInfo.Id.ClassID);
				}
			}
		}
		else if( id == DIALOG_BOTTOM_TO_TOP && num > 0 )
		{
			index = m_bottomList.FindItem( cID );
			if( index >= 0 )
			{
				m_bottomList.GetItem( index, info );				
				// Change by JoeyPark
				num = Min64( num, info.ItemNum );
				// End Change
				info.ItemNum -= num;
				if( info.ItemNum > 0 )
				{
					m_bottomList.SetItem( index, info );
				}
				else 
				{
					// 창고에 수량성, 아이템이 존재 하면.. 카운트를 하지 않기 위해 
					// 배열에 넣었던 것을 다시 삭제 해준다. 
					if (findHasStackableItemArray(info.Id.ClassID) != -1)
					{
						removeHasStackableItemArray(info.Id.ClassID);
					}

					m_bottomList.DeleteItem( index );
				}

				topIndex = m_topList.FindItem( cID );
				if( topIndex >=0 && IsStackableItem( info.ConsumeType ) )
				{
					m_topList.GetItem( topIndex, topInfo );
					topInfo.ItemNum += num;
					m_topList.SetItem( topIndex, topInfo );
				}
				else
				{
					info.ItemNum = num;
					m_topList.AddItem( info );
				}

				if( m_type == WT_Withdraw )
					class'UIAPI_INVENWEIGHT'.static.ReduceWeight("WarehouseWnd.InvenWeight", num * info.Weight);		// 무게 바에서 빼 주기
				else if (m_type == WT_Deposit)
					class'UIAPI_INVENWEIGHT'.static.AddWeight("WarehouseWnd.InvenWeight", num * info.Weight);

			}
		}
		AdjustPrice();
		AdjustCount();
	}
}

function HandleOpenWindow( string param )
{
	local string type;
	local int tmpInt;
	local int itemCount;
	local string adenaString;
	local WindowHandle m_inventoryWnd;

	local INT64 adena;

	if(CREATE_ON_DEMAND==0)
		m_inventoryWnd = GetHandle( "InventoryWnd" );	//인벤토리의 윈도우 핸들을 얻어온다.
	else
		m_inventoryWnd = GetWindowHandle( "InventoryWnd" );	//인벤토리의 윈도우 핸들을 얻어온다.

	Clear();

	ParseString( param, "type", type );
	ParseInt( param, "category", tmpInt ); 
	m_category = WarehouseCategory( tmpInt );
	ParseInt64( param, "adena", adena );
	ParseInt( param, "itemCount", itemCount );
	
	switch( m_category )
	{
		case WC_Private:
			class'UIAPI_WINDOW'.static.SetWindowTitle(m_WindowName, 1216);
			break;
		case WC_Clan:
			class'UIAPI_WINDOW'.static.SetWindowTitle(m_WindowName, 1217);
			break;
		case WC_Castle:
			class'UIAPI_WINDOW'.static.SetWindowTitle(m_WindowName, 1218);
			break;
		case WC_Etc:
			class'UIAPI_WINDOW'.static.SetWindowTitle(m_WindowName, 131);
			break;
		default:
			break;
	};
	
	if( type == "deposit" )
	{
		m_type = WT_Deposit;
		m_curWarehouseCount = itemCount;
	}
	else if( type == "withdraw" )
	{
		m_type = WT_Withdraw;
		m_curInventoryCount = itemCount;
	}	

	// debug("ITEM_COUNT: " $itemCount);

	adenaString = MakeCostString( string(adena) );
	class'UIAPI_TEXTBOX'.static.SetText(m_WindowName $ ".AdenaText", adenaString);
	class'UIAPI_TEXTBOX'.static.SetTooltipString(m_WindowName $ ".AdenaText", ConvertNumToText(string(adena)) );

	/*
	if( m_inventoryWnd.IsShowWindow() )			//인벤토리 창이 열려있으면 닫아준다. 
	{
		m_inventoryWnd.HideWindow();
	}
	*/
	ShowWindow( m_WindowName );
	class'UIAPI_WINDOW'.static.SetFocus(m_WindowName);

	if( m_type == WT_Deposit )
	{
		class'UIAPI_TEXTBOX'.static.SetText( m_WindowName $ ".TopText", GetSystemString(138) );
		class'UIAPI_TEXTBOX'.static.SetText( m_WindowName $ ".BottomText", GetSystemString(132) );
	}
	else if( m_type == WT_Withdraw )
	{
		class'UIAPI_TEXTBOX'.static.SetText( m_WindowName $ ".TopText", GetSystemString(132) );
		class'UIAPI_TEXTBOX'.static.SetText( m_WindowName $ ".BottomText", GetSystemString(133) );
	}
	AdjustCount();
	ShowWindow( m_WindowName $ ".BottomCountText" );
}

function HandleAddItem( string param )
{
	local ItemInfo info;
	
	ParamToItemInfo( param, info );
	m_topList.AddItem( info );
	AdjustCount();	
}

function HandleDeleteItem(string param)
{
	local int index;
	local ItemInfo info;
	ParamToItemInfo( param, info );
	index = m_topList.FindItem(info.ID);
	if (index != -1)
	{
		m_topList.DeleteItem(index);
	}
	index = m_bottomList.FindItem(info.ID);
	if (index != -1)
	{
		m_bottomList.DeleteItem(index);
	}	
	AdjustCount();
}
// 한 칸당 KEEPING_PRICE 씩 만큼
function AdjustPrice()
{
	local string adena;
	local int count;
	if( m_type == WT_Deposit )
	{
		count = m_bottomList.GetItemNum();
		adena = MakeCostString( string(count*KEEPING_PRICE) );
		class'UIAPI_TEXTBOX'.static.SetText(m_WindowName $ ".PriceText", adena);
		class'UIAPI_TEXTBOX'.static.SetTooltipString(m_WindowName $ ".PriceText", ConvertNumToText(string(count*KEEPING_PRICE)) );
	}
}

function AdjustCount()
{
	// Changed by JoeyPark 2010/09/09
	local int num, maxNum, numPossibleSlot;
 	if( m_category == WC_Private )
 		maxNum = m_maxPrivateCount;
 	else 
 		maxNum = DEFAULT_MAX_COUNT;

	if( m_type == WT_Deposit )
	{
		num = m_bottomList.GetItemNum();
		//여분의 창고 슬롯 = 총 보관 가능 갯수 - 현재 보관한 아이템 갯수
		numPossibleSlot = maxNum - m_curWarehouseCount;
		if(numPossibleSlot < 0)
			numPossibleSlot = 0;
		class'UIAPI_TEXTBOX'.static.SetText(m_WindowName $ ".BottomCountText", "(" $ string(num - hasStackableItemArray.Length) $ "/" $ string(numPossibleSlot) $ ")");
	}
	else if( m_type == WT_Withdraw )
	{		
		num = m_bottomList.GetItemNum();
		//여분의 인벤 슬롯 = 총 인벤토리 갯수 - 인벤의 아이템 갯수
		numPossibleSlot = m_maxInventoryCount - m_curInventoryCount;
		if(numPossibleSlot < 0)
			numPossibleSlot = 0;
		class'UIAPI_TEXTBOX'.static.SetText(m_WindowName $ ".BottomCountText", "(" $ string(num - hasStackableItemArray.Length) $ "/" $ string(numPossibleSlot) $ ")");
	}
	m_numPossibleSlotCount = numPossibleSlot;

	// End changing
}

function HandleOKButton()
{
	local string	param;
	local int		bottomCount, bottomIndex;
	local ItemInfo	bottomInfo;

	bottomCount = m_bottomList.GetItemNum();
	if( m_type == WT_Deposit )
	{
		// pack every item in BottomList
		ParamAdd( param, "num", string(bottomCount) );
		for( bottomIndex=0 ; bottomIndex < bottomCount; ++bottomIndex )
		{
			m_bottomList.GetItem( bottomIndex, bottomInfo );
			ParamAdd( param, "dbID" $ bottomIndex, string(bottomInfo.Reserved) );
			ParamAdd( Param, "count" $ bottomIndex, string(bottomInfo.ItemNum) );
		}
		RequestWarehouseDeposit( param );
	}
	else if( m_type == WT_Withdraw )
	{
		// pack every item in BottomList
		ParamAdd( param, "num", string(bottomCount) );
		for( bottomIndex=0 ; bottomIndex < bottomCount; ++bottomIndex )
		{
			m_bottomList.GetItem( bottomIndex, bottomInfo );
			ParamAdd( param, "dbID" $ bottomIndex, string(bottomInfo.Reserved) );
			ParamAdd( Param, "count" $ bottomIndex, string(bottomInfo.ItemNum) );
		}

		RequestWarehouseWithdraw( param );
	}

	HideWindow(m_WindowName);
}

function HandleSetMaxCount( string param )
{
	ParseInt( param, "warehousePrivate", m_maxPrivateCount );	
	ParseInt(param, "Inventory", m_maxInventoryCount);
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	GetWindowHandle( "WarehouseWnd" ).HideWindow();
}


defaultproperties
{
    m_WindowName="WarehouseWnd"
}
