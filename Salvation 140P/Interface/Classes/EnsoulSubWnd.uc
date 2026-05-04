//------------------------------------------------------------------------------------------------------------------------
// 집혼 UI 보조 인벤토리
//------------------------------------------------------------------------------------------------------------------------
class EnsoulSubWnd extends UICommonAPI;

const STATE_INSERT_WEAPON         = "STATE_INSERT_WEAPON";
const STATE_INSERT_ENSOULSTONE    = "STATE_INSERT_ENSOULSTONE";
const STATE_SELECT_ENSOUL         = "STATE_SELECT_ENSOUL";
const STATE_CONFIRM_ENSOUL        = "STATE_CONFIRM_ENSOUL";
const STATE_ASK_OVERWRITE         = "STATE_ASK_OVERWRITE";
const STATE_RESULT                = "STATE_RESULT";

var WindowHandle Me;
var TextureHandle SlotBg1_Texture;
var ItemWindowHandle EnsoulSubWnd_Item1;
var ItemWindowHandle EnsoulSubWnd_Item2;
var TabHandle EnsoulSubWnd_Tab;
var TextureHandle tabbgLine;
var TextureHandle tabbg;

var L2Util util;
var InventoryWnd inventoryWndScript;
var EnsoulWnd    ensoulWndScript;

function OnRegisterEvent()
{
	//RegisterEvent(  );
}

function OnShow()
{
	syncInventory();
}

// 무기, 집혼석 관련 아이템 윈도우 업데이트
function syncInventory()
{
	local array<ItemInfo> itemArray;
	local int i, nStackableNum;

	// Debug("EnsoulSubWnd_Tab" @ EnsoulSubWnd_Tab.GetTopIndex());

	if (EnsoulSubWnd_Tab.GetTopIndex() == 0)
	{
		itemArray = inventoryWndScript.getInventoryEnSoulEnableItemArray();
		EnsoulSubWnd_Item1.Clear();
		for (i = 0; i < itemArray.Length;i++)
		{
			// 집혼UI에서 사용 중인 아이템인가?
			if (!ensoulWndScript.externalCheckUsingItem(itemArray[i]))
				EnsoulSubWnd_Item1.AddItem(itemArray[i]);
		}
	}
	else if (EnsoulSubWnd_Tab.GetTopIndex() == 1)
	{
		itemArray = inventoryWndScript.getInventoryEnSoulStoneArray();
		EnsoulSubWnd_Item2.Clear();
		for (i = 0; i < itemArray.Length;i++)
		{
			nStackableNum = 0;
			// 2016_0801 버전, [수량성] 아이템 관련 기능 추가			
			// 수량성 아이템이 장착 되어 있나?
			if(IsStackableItem(itemArray[i].ConsumeType))
			{				
				if (ensoulWndScript.externalCheckUsingItem(itemArray[i], nStackableNum)) 
				{
					// 장착된 1개 아이템 만큼 빼준다.
					itemArray[i].ItemNum = itemArray[i].ItemNum - nStackableNum; 
				}
				
				if (itemArray[i].ItemNum > 0) EnsoulSubWnd_Item2.AddItem(itemArray[i]);
				else EnsoulSubWnd_Item2.DeleteItem(i);
			}
			else 
			{
				// 집혼UI에서 사용 중인 아이템인가?
				if (!ensoulWndScript.externalCheckUsingItem(itemArray[i]))
					EnsoulSubWnd_Item2.AddItem(itemArray[i]);
			}
		}
	}
}

function setLock(bool bLock)
{

	if (bLock)
	{
		EnsoulSubWnd_Item1.DisableWindow();
		EnsoulSubWnd_Item2.DisableWindow();
	}
	else
	{
		EnsoulSubWnd_Item1.EnableWindow();
		EnsoulSubWnd_Item2.EnableWindow();
	}
	
}

function OnLoad()
{
	Initialize();
}

function OnClickButton( string Name )
{
	// Debug("OnClickButton Name" @ Name);
	OnShow();
	switch( Name )
	{
		case "EnsoulInfo_Button":
			 break;
	}
}

// 더블 클릭하면, 무기, 집혼석 슬롯은 삭제
function OnDBClickItem( string ControlName, int index )
{
	local itemInfo info;

	// 클릭 무시
	if (ControlName == "EnsoulSubWnd_Item1" && EnsoulSubWnd_Item1.IsEnableWindow() == false) return;
	if (ControlName == "EnsoulSubWnd_Item2" && EnsoulSubWnd_Item2.IsEnableWindow() == false) return;

	// 무기
	if(ensoulWndScript.getCurrentEnsoulState() == STATE_INSERT_WEAPON || 
	   ensoulWndScript.getCurrentEnsoulState() == STATE_INSERT_ENSOULSTONE || 
	   ensoulWndScript.getCurrentEnsoulState() == STATE_SELECT_ENSOUL)
	{
		if ( ControlName == "EnsoulSubWnd_Item1")
		{	
			EnsoulSubWnd_Item1.GetItem(index, info);
			ensoulWndScript.InsertWeapon(info);
		}	
		// 집혼석
		else if ( ControlName == "EnsoulSubWnd_Item2")
		{	
			EnsoulSubWnd_Item2.GetItem(index, info);
			ensoulWndScript.InsertEnsoulStone(-1, info);
		}
	}
}

function OnRClickItem( String strID, int index )
{
	OnDBClickItem(strID, index);
}

function Initialize()
{
	Me                 = GetWindowHandle( "EnsoulSubWnd" );
	SlotBg1_Texture    = GetTextureHandle( "EnsoulSubWnd.SlotBg1_Texture" );

	EnsoulSubWnd_Item1 = GetItemWindowHandle( "EnsoulSubWnd.EnsoulSubWnd_Item1" );
	EnsoulSubWnd_Item2 = GetItemWindowHandle( "EnsoulSubWnd.EnsoulSubWnd_Item2" );

	EnsoulSubWnd_Tab   = GetTabHandle( "EnsoulSubWnd.EnsoulSubWnd_Tab" );
	tabbgLine          = GetTextureHandle( "EnsoulSubWnd.tabbgLine" );

	tabbg              = GetTextureHandle( "EnsoulSubWnd.tabbg" );

	util               = L2Util(GetScript("L2Util"));
	inventoryWndScript = inventoryWnd(GetScript("inventoryWnd"));

	ensoulWndScript    = EnsoulWnd(GetScript("EnsoulWnd"));
}

// 강제로 탭 이동
function setTabIndex(int nIndex)
{
	EnsoulSubWnd_Tab.SetTopOrder(nIndex, false);

	syncInventory();
}
defaultproperties
{
}
