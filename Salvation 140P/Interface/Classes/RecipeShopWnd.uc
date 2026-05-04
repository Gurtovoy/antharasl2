class RecipeShopWnd extends UICommonAPI;

const RECIPESHOP_MAX_ITEM_SELL = 20;

var int		m_ShopItemMaxCount_Dwarf;
var int		m_ShopItemMaxCount_Normal;

var int		m_BookItemCount;
var int		m_ShopItemCount;

var int		m_BookType;
var ItemInfo	m_HandleItem;

var bool isStartCraft;

function OnRegisterEvent()
{
	RegisterEvent( EV_RecipeShopShowWnd );
	RegisterEvent( EV_RecipeShopAddBookItem );
	RegisterEvent( EV_RecipeShopAddShopItem );
	RegisterEvent( EV_SetMaxCount );
	RegisterEvent( EV_DialogOK );
}

function OnLoad()
{
	SetClosingOnESC();
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();
}

function OnShow()
{
	PlayConsoleSound(IFST_WORKSHOP_OPEN);

	// 지정한 윈도우를 제외한 닫기 기능 
	getInstanceL2Util().ItemRelationWindowHide(getCurrentWindowName(String(self)));
}

function OnClickButton( string strID )
{
	switch( strID )
	{
	case "btnEnd":
		//class'RecipeAPI'.static.RequestRecipeShopManageQuit();
		CloseWindow();
		break;
	case "btnMsg":
		DialogSetEditBoxMaxLength(29);
		DialogShow(DialogModalType_Modalless,DialogType_OKCancelInput, GetSystemMessage(334), string(Self));
		DialogSetID(0);
		DialogSetString(class'UIDATA_PLAYER'.static.GetRecipeShopMsg());
		break;
	case "btnStart":
		
		StartRecipeShop();
		CloseWindow();
		break;
	case "btnMoveUp":
		HandleMoveUpItem();
		break;
	case "btnMoveDown":
		HandleMoveDownItem();
		break;
	}
}

function OnEvent(int Event_ID, string param)
{
	local string strPrice;
	
	local int RecipeID;
	local int CanbeMade;
	local INT64 MakingFee;
	local INT64 Price;
	if (Event_ID == EV_RecipeShopShowWnd)
	{
		Clear();
		
		//Show
		class'UIAPI_WINDOW'.static.ShowWindow("RecipeShopWnd");
		class'UIAPI_WINDOW'.static.SetFocus("RecipeShopWnd");
		
		//enum RecipeBookClass
		//{
		//	RBC_DWARF  = 0,	//드워프용 레시피샵
		//	RBC_NORMAL		//개인 레시피샵
		//};
		ParseInt(param, "Type", m_BookType);
		if (m_BookType == 1)
		{
			class'UIAPI_WINDOW'.static.SetWindowTitle("RecipeShopWnd", 1212);
		}
		else
		{
			class'UIAPI_WINDOW'.static.SetWindowTitle("RecipeShopWnd", 1213);
		}
	}
	else if (Event_ID == EV_RecipeShopAddBookItem)
	{
		ParseInt( param, "RecipeID", RecipeID );
		AddRecipeBookItem( RecipeID );
	}
	else if (Event_ID == EV_RecipeShopAddShopItem)
	{
		ParseInt( param, "RecipeID", RecipeID );
		ParseInt( param, "CanbeMade", CanbeMade );
		ParseInt64( param, "MakingFee", MakingFee );
		AddRecipeShopItem( RecipeID, CanbeMade, MakingFee );
	}
	else if (Event_ID == EV_SetMaxCount)
	{
		HandleSetMaxCount(param);
	}
	else if (Event_ID == EV_DialogOK)
	{
		if (DialogIsMine())
		{	
			//메시지 입력
			if (DialogGetID() == 0 )
			{
				class'RecipeAPI'.static.RequestRecipeShopMessageSet(DialogGetString());
			}
			else if (DialogGetID() == 1 )
			{
				//가격이 "0"원이라도, 뭔가 입력한 게 있어야만 아이템을 추가
				strPrice = DialogGetString();
				if (Len(strPrice)>0)
				{
					//입력한 가격이 20억이 넘으면 수량 초과 에러를 뿌려준다.
					Price = INT64(strPrice);
					if( Price >= INT64("1000000000000") )
					{
						DialogSetID(2);
						DialogShow(DialogModalType_Modalless,DialogType_Warning, GetSystemMessage(1369), string(Self));
					}
					else
					{
						m_HandleItem.Price = Price;
						UpdateShopItem(m_HandleItem);
					}
				}
				ClearHandleItem();
			}
		}
	}
}

//Frame의 "X"를 눌렀을 때 (따로 사운드를 출력할 필요가 없음)
function OnSendPacketWhenHiding()
{
	//class'RecipeAPI'.static.RequestRecipeShopManageQuit();
	Clear();
}

//윈도우 닫기
function CloseWindow()
{
	Clear();
	class'UIAPI_WINDOW'.static.HideWindow("RecipeShopWnd");
	//class'RecipeAPI'.static.RequestRecipeShopManageQuit();
}

//ItemWindow더블 클릭 처리
function OnDBClickItem( string strID, int index )
{
	local int Max;
	local int i;
	local ItemInfo infItem;
	local ItemInfo DeleteItem;
	
	ClearHandleItem();
	
	if (strID == "BookItemWnd" && m_BookItemCount>index)
	{
		class'UIAPI_ITEMWINDOW'.static.GetItem( "RecipeShopWnd.BookItemWnd", index, infItem);
			
		// 이미 아래에 존재하는 아이템이라면 삭제해줘야 한다. 
		Max = class'UIAPI_ITEMWINDOW'.static.GetItemNum( "RecipeShopWnd.ShopItemWnd");
		for (i=0; i<Max; i++)
		{
			if (class'UIAPI_ITEMWINDOW'.static.GetItem( "RecipeShopWnd.ShopItemWnd", i, DeleteItem))
			{
				if (IsSameClassID(DeleteItem.ID, infItem.ID))
				{
					DeleteShopItem(infItem);	// 해당아이템을 삭제하고 리턴한다. 
					return;
				}
			}
		}
			
		//위에서 리턴되지 않고 넘어왔다면, 가격을 입력하는 창으로 이동.		
		class'UIAPI_ITEMWINDOW'.static.GetItem( "RecipeShopWnd.BookItemWnd", index, infItem);
		ShowShopItemAddDialog(infItem);
	}
	//Shop에서 더블클릭을 하면 다이얼로그가 나타나고 가격을 입력하지만, 실제로는 아무런 작동을 하지않는다.(원래 이렇삼)
	//원래 이런게 아닌가봅니다. TTP가 날라왔네요. 아래부분에서 더블클릭하면 아이템을 삭제합니다. -innowind
	else if (strID == "ShopItemWnd" && m_ShopItemCount>index)
	{
		class'UIAPI_ITEMWINDOW'.static.GetItem( "RecipeShopWnd.ShopItemWnd", index, infItem);
		DeleteShopItem(infItem);	// 해당아이템을 삭제한다. 
		//ShowShopItemAddDialog(infItem);
	}
}

//아이템 드롭 처리
function OnDropItem( string strID, ItemInfo infItem, int x, int y)
{
	if (strID == "BookItemWnd")
	{
		if (infItem.DragSrcName == "ShopItemWnd")
		{
			//Shop에서 Book으로 드랍한 경우, Shop의 아이템을 삭제한다.
			DeleteShopItem(infItem);
		}
	}
	else if (strID == "ShopItemWnd")
	{
		if (infItem.DragSrcName == "BookItemWnd")
		{
			//Book에서 Shop으로 드랍한 경우, Shop에 아이템을 추가한다.
			ShowShopItemAddDialog(infItem);
		}
	}
}

//초기화
function Clear()
{
	ClearHandleItem();	
	m_BookItemCount = 0;
	m_ShopItemCount = 0;
	UpdateShopItemCount(0);
	
	class'UIAPI_ITEMWINDOW'.static.Clear("RecipeShopWnd.BookItemWnd");
	class'UIAPI_ITEMWINDOW'.static.Clear("RecipeShopWnd.ShopItemWnd");
}

//Handle아이템 클리어
function ClearHandleItem()
{
	local ItemInfo ItemClear;
	m_HandleItem = ItemClear;
}

//레시피샵 아이템 추가
function AddRecipeBookItem(int RecipeID)
{
	local ItemInfo	infItem;
	local int		ProductID;
	
	//Product ID
	ProductID = class'UIDATA_RECIPE'.static.GetRecipeProductID(RecipeID);
	
	//레시피정보
	infItem.ID = class'UIDATA_RECIPE'.static.GetRecipeItemID(RecipeID);
	infItem.Level = class'UIDATA_RECIPE'.static.GetRecipeLevel(RecipeID);
	
	infItem.Name = class'UIDATA_ITEM'.static.GetItemName(infItem.ID);
	infItem.Description = class'UIDATA_ITEM'.static.GetItemDescription(infItem.ID);
	infItem.Weight = class'UIDATA_ITEM'.static.GetItemWeight(infItem.ID);

	//생산물정보
	infItem.IconName = class'UIDATA_ITEM'.static.GetItemTextureName(GetItemID(ProductID));
	infItem.CrystalType = class'UIDATA_RECIPE'.static.GetRecipeCrystalType(RecipeID);
	
	//ItemWnd에 추가
	class'UIAPI_ITEMWINDOW'.static.AddItem( "RecipeShopWnd.BookItemWnd", infItem);
	
	m_BookItemCount++;
}

//이미 등록한  아이템 추가
function AddRecipeShopItem(int RecipeID, int CanbeMade, INT64 MakingFee)
{
	local ItemInfo	infItem;
	local int		ProductID;
	
	//Product ID
	ProductID = class'UIDATA_RECIPE'.static.GetRecipeProductID(RecipeID);
	
	//레시피정보
	infItem.ID = class'UIDATA_RECIPE'.static.GetRecipeItemID(RecipeID);
	infItem.Level = class'UIDATA_RECIPE'.static.GetRecipeLevel(RecipeID);
	infItem.Price = MakingFee;
	infItem.Reserved = CanbeMade;
	
	infItem.Name = class'UIDATA_ITEM'.static.GetItemName(infItem.ID);
	infItem.Description = class'UIDATA_ITEM'.static.GetItemDescription(infItem.ID);
	infItem.Weight = class'UIDATA_ITEM'.static.GetItemWeight(infItem.ID);

	//생산물정보
	infItem.IconName = class'UIDATA_ITEM'.static.GetItemTextureName(GetItemID(ProductID));
	infItem.CrystalType = class'UIDATA_RECIPE'.static.GetRecipeCrystalType(RecipeID);
	
	//ItemWnd에 추가
	class'UIAPI_ITEMWINDOW'.static.AddItem( "RecipeShopWnd.ShopItemWnd", infItem);
	
	m_ShopItemCount++;
	UpdateShopItemCount(m_ShopItemCount);
}

//레시피샵에 아이템 추가 다이얼로그 박스 표시
function ShowShopItemAddDialog(ItemInfo AddItem)
{
	m_HandleItem = AddItem;
	DialogSetID(1);
	DialogSetParamInt64(-1);
	DialogSetDefaultOK();	
	DialogShow(DialogModalType_Modalless,DialogType_NumberPad, GetSystemMessage(963), string(Self));
}

//레시피샵에 아이템 추가
function UpdateShopItem(ItemInfo AddItem)
{
	local int		i;
	local int		Max;
	local ItemInfo	infItem;
	local bool		bDuplicated;
	
	bDuplicated = false;
	
	Max = class'UIAPI_ITEMWINDOW'.static.GetItemNum( "RecipeShopWnd.ShopItemWnd");
	for (i=0; i<Max; i++)
	{
		if (class'UIAPI_ITEMWINDOW'.static.GetItem( "RecipeShopWnd.ShopItemWnd", i, infItem))
		{
			if (IsSameClassID(AddItem.ID, infItem.ID))
			{
				bDuplicated = true;
				break;
			}
		}
	}
	if (!bDuplicated)
	{
		class'UIAPI_ITEMWINDOW'.static.AddItem( "RecipeShopWnd.ShopItemWnd", AddItem);
		m_ShopItemCount++;
		UpdateShopItemCount(m_ShopItemCount);
	}
}

//레시피샵의 아이템 삭제
function DeleteShopItem(ItemInfo DeleteItem)
{
	local int		i;
	local int		Max;
	local ItemInfo	infItem;
	
	Max = class'UIAPI_ITEMWINDOW'.static.GetItemNum( "RecipeShopWnd.ShopItemWnd");
	for (i=0; i<Max; i++)
	{
		if (class'UIAPI_ITEMWINDOW'.static.GetItem( "RecipeShopWnd.ShopItemWnd", i, infItem))
		{
			if (IsSameClassID(DeleteItem.ID, infItem.ID))
			{
				class'UIAPI_ITEMWINDOW'.static.DeleteItem( "RecipeShopWnd.ShopItemWnd", i);
				m_ShopItemCount--;
				UpdateShopItemCount(m_ShopItemCount);
				break;
			}
		}
	}
}

//등록된 아이템 갯수 갱신
function UpdateShopItemCount(int Count)
{
	if (m_BookType == 1)
	{
		class'UIAPI_TEXTBOX'.static.SetText("RecipeShopWnd.txtCount", "(" $ Count $ "/" $ m_ShopItemMaxCount_Normal $ ")");	
	}
	else
	{
		class'UIAPI_TEXTBOX'.static.SetText("RecipeShopWnd.txtCount", "(" $ Count $ "/" $ m_ShopItemMaxCount_Dwarf $ ")");	
	}		
}

//레시피샵 시작
function StartRecipeShop()
{
	local int		i;
	local int		Max;
	local ItemInfo	infItem;
	
	local string	param;
	local INT64		Price;
	
	Max = class'UIAPI_ITEMWINDOW'.static.GetItemNum( "RecipeShopWnd.ShopItemWnd");
	ParamAdd(param, "Max", string(Max));
	
	for (i=0; i<Max; i++)
	{
		Price = 0;
		if (class'UIAPI_ITEMWINDOW'.static.GetItem( "RecipeShopWnd.ShopItemWnd", i, infItem))
		{
			Price = infItem.Price;
		}
		ParamAddItemIDWithIndex(param, infItem.ID, i);
		ParamAdd(param, "Price_" $ i, string(Price));
	}

	isStartCraft = true;
	class'RecipeAPI'.static.RequestRecipeShopListSet( param );
}

//아이템 업
function HandleMoveUpItem()
{
	local ItemInfo infItem;
	
	if (class'UIAPI_ITEMWINDOW'.static.GetSelectedItem( "RecipeShopWnd.ShopItemWnd", infItem))
	{
		DeleteShopItem(infItem);
	}
}

//아이템 다운
function HandleMoveDownItem()
{
	local ItemInfo infItem;
	
	if (class'UIAPI_ITEMWINDOW'.static.GetSelectedItem( "RecipeShopWnd.BookItemWnd", infItem))
	{
		ShowShopItemAddDialog(infItem);
	}
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{		
	CloseWindow();
}

function onHide()
{
	PlayConsoleSound(IFST_WORKSHOP_CLOSE);

	//정상 (버튼 클릭) 시작 시 공방 취소 이벤트가 가지 않도록 수정
	//서버 쪽에서 예외 처리 되던 것을 로그 문제 때문에 풀었다고 함.
	if ( !isStartCraft ) class'RecipeAPI'.static.RequestRecipeShopManageQuit();
	isStartCraft = false;
}

function HandleSetMaxCount( string param )
{
	ParseInt( param, "dwarvenRecipeShop", m_ShopItemMaxCount_Dwarf );	
	ParseInt(param, "recipeShop", m_ShopItemMaxCount_Normal);
}
defaultproperties
{
}
