/**
 *  합성 UI 보조창
 **/
class ItemJewelEnchantSubWnd extends UICommonAPI;

var WindowHandle Me;
var TextureHandle SlotBg1_Texture;
var ItemWindowHandle ItemJewelEnchantSubWnd_ItemWnd;

var array<ItemInfo>	ItemInfoArray;

var ItemJewelEnchantWnd ItemJewelEnchantWndScript;
var L2Util util;

function OnRegisterEvent()
{
	registerEvent( EV_AdenaInvenCount );
}

function OnLoad()
{
	Initialize();
}

function OnShow()
{
	refresh();
}

function Initialize()
{

	Me = GetWindowHandle( "ItemJewelEnchantSubWnd" );

	ItemJewelEnchantSubWnd_ItemWnd = GetItemWindowHandle( "ItemJewelEnchantSubWnd.ItemJewelEnchantSubWnd_ItemWnd" );

	util = L2Util(GetScript("L2Util"));

	ItemJewelEnchantWndScript = ItemJewelEnchantWnd(GetScript("ItemJewelEnchantWnd"));

	// - 합성 가능 재료 아이템 리스트 얻기 
	// int GetMaterialItemForEnchant(int OneSlotItemClassID, int TwoSlotItemClassID, out array<ItemInfo> MaterialItems) - count 리턴 (in class NewEnchantAPI) 
}


function OnRClickItem( String strID, int index )
{
	OnDBClickItem(strID, index);
}


function OnDBClickItem( string ControlName, int index )
{
	local ItemInfo info;

	ItemJewelEnchantSubWnd_ItemWnd.GetItem(index, info);

	if (info.Id.ClassID > 0) ItemJewelEnchantWndScript.dropProcess(info, 0);
}


function OnEvent(int Event_ID, string param)
{
	//debug("Inven Event ID :" $string(Event_ID)$" "$param);
	switch( Event_ID )
	{
		case EV_AdenaInvenCount:
		// case EV_SetMaxCount    :       //2070
			 //Me.ShowWindow();
			 if (Me.IsShowWindow()) 
			 {
				Debug("refresh! ");
				refresh();
			 }
			 break;
	}
}

function int getSlotClassID(int nClassID)
{
	local int nValue;

	if (nClassID > 0) nValue = nClassID;
	else nValue = -1;

	return nValue;
}

// desc 설명
function setDescTextBox(bool bShowMessage)
{
	GetTextBoxHandle("ItemJewelEnchantSubWnd.DescriptionMsgWnd.descTextBox").SetText(GetSystemMessage(4222));

	if (bShowMessage)
		GetWindowHandle("ItemJewelEnchantSubWnd.DescriptionMsgWnd").ShowWindow();
	else 
		GetWindowHandle("ItemJewelEnchantSubWnd.DescriptionMsgWnd").HideWindow();
		
}

delegate int OnSortCompare( ItemInfo a, ItemInfo b )
{
    if (a.Id.ClassID > b.Id.ClassID) // 오름 차순. 조건문에 < 이면 내림차순.
    {
        return -1;  // 자리를 바꿔야할때 -1를 리턴 하게 함.
    }
    else
    {
        return 0;
    }
}

function refresh()
{
	local int i;
	local int slot1_ClassID, slot2_ClassID;
	local bool bSlot1Dec, bSlot2Dec, bIsWorkingEnchant;

	bSlot1Dec = true; bSlot2Dec = true;

	slot1_ClassID = ItemJewelEnchantWndScript.getSlotItemWindowByIndex(1);
	slot2_ClassID = ItemJewelEnchantWndScript.getSlotItemWindowByIndex(2);
	//인챈 중이거나 인챈 완료 시 

	bIsWorkingEnchant = ItemJewelEnchantWndScript.isWorkingEnchant();

	//class'NewEnchantAPI'.static.GetMaterialItemForEnchantFromInven(getSlotClassID(slot1_ClassID), getSlotClassID(slot2_ClassID), ItemInfoArray);
	// 두번째 슬롯 넣어서 아이템 갱신 하는 부분은 현재는 사용 안함.
	class'NewEnchantAPI'.static.GetMaterialItemForEnchantFromInven(getSlotClassID(slot1_ClassID), -1, ItemInfoArray);

	ItemInfoArray = util.SortItemArray(ItemInfoArray);
	//GetMaterialItemForEnchantFromEquip

	// ItemInfoArray.Sort(OnSortCompare);
	
	Debug("ItemInfoArray Length: "@ ItemInfoArray.Length);
	Debug("getSlotClassID(slot1_ClassID)" @ getSlotClassID(slot1_ClassID));
	Debug("getSlotClassID(slot2_ClassID)" @ getSlotClassID(slot2_ClassID));

	ItemJewelEnchantSubWnd_ItemWnd.Clear();

	for (i = 0; i < ItemInfoArray.Length; i++)
	{
		// 작업 중이면, 슬롯에 꼽힌 것 제외 처리 안함.
		if (bIsWorkingEnchant == false)
		{
			// 슬롯1
			// 각 슬롯에 아이템이 있을 경우, 보조 인벤에서 그 아이템을 넣지 않는 처리 
			if (ItemInfoArray[i].Id.ClassID == slot1_ClassID && bSlot1Dec)
			{
				//수량성인 경우
				if(IsStackableItem(ItemInfoArray[i].ConsumeType))
				{
					// 슬롯은 무조건 1개의 아이템을 넣을 수 있다. 1개를 빼준다.
					ItemInfoArray[i].ItemNum = ItemInfoArray[i].ItemNum - 1;
				}
				else
				{
					bSlot1Dec = false;
					continue;
				}
			}

			// 슬롯 2
			if (ItemInfoArray[i].Id.ClassID == slot2_ClassID && bSlot2Dec)
			{
				//수량성인 경우
				if(IsStackableItem(ItemInfoArray[i].ConsumeType))
				{
					// 슬롯은 무조건 1개의 아이템을 넣을 수 있다. 1개를 빼준다.
					ItemInfoArray[i].ItemNum = ItemInfoArray[i].ItemNum - 1;			
				}
				else
				{
					bSlot2Dec = false;		
					continue;
				}
			}
		}

		// 수량성인 경우 0보다 클때만 추가 한다.
		if(IsStackableItem(ItemInfoArray[i].ConsumeType))
		{
			if (ItemInfoArray[i].ItemNum > 0) ItemJewelEnchantSubWnd_ItemWnd.AddItem(ItemInfoArray[i]);
		}
		else
		{
			ItemJewelEnchantSubWnd_ItemWnd.AddItem(ItemInfoArray[i]);
		}

		//Debug("add:" @ ItemInfoArray[i].name);
	}

	// 재료 아이템이 없다면..
	if (ItemJewelEnchantSubWnd_ItemWnd.GetItemNum() <= 0)
		setDescTextBox(true);
	else
		setDescTextBox(false);
}

function int getSubIvenItemNum()
{
	return ItemJewelEnchantSubWnd_ItemWnd.GetItemNum();
}

function int getIndexSubIvenItem(int classID)
{
	local ItemInfo info;
	local int itemNum, i;

	itemNum = ItemJewelEnchantSubWnd_ItemWnd.GetItemNum();

	for(i = 0; i < itemNum; i++)
	{
		ItemJewelEnchantSubWnd_ItemWnd.GetItem(i, info);

		if(info.Id.ClassID == classID)
		{
			return i;
		}
	}

	return -1;
}


function OnHide()
{
	ItemJewelEnchantSubWnd_ItemWnd.Clear();
	setDescTextBox(false);
}
defaultproperties
{
}
