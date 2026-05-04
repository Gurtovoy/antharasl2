class ProductInventoryDrawerWnd extends UICommonAPI;

const DIALOGID_RECIEVE = 6460;

var WindowHandle Me;
var TextBoxHandle ProductInventoryDrawerWndTitle;
var TreeHandle ProductItemName;
var TreeHandle ProductItemInfo;
var TextureHandle BIT_ProductItem;

var TextBoxHandle ProductItemDetailListTitle;
var TextBoxHandle ProductItemDetailListCounter;
var TreeHandle ProductItemDetailList;
var TextureHandle ProductItemDetailListBg;
var TextBoxHandle PresentMessageTitle;
var TextBoxHandle SenderTitle;
var NameCtrlHandle Sender;
var TreeHandle ProductItemDetailList2;

var TextBoxHandle ProductBuyInfoTitle;
var TextBoxHandle ProductBuyInfo;

var ButtonHandle RecieveBtn;
var ButtonHandle CloseBtn;

var bool bDrawBgTree;

var int goodsCondition;

var ProductInventoryWnd ProductInventory;

//UI용 UC
var L2Util util;

var int SelectItemNum;

function OnRegisterEvent()
{
	RegisterEvent( EV_GoodsInventoryItemDesc );
	RegisterEvent( EV_DialogOK );
	RegisterEvent( EV_DialogCancel );
}

function OnLoad()
{
	Initialize();
	Load();
}

function Initialize()
{
	Me = GetWindowHandle( "ProductInventoryDrawerWnd" );
	ProductInventoryDrawerWndTitle = GetTextBoxHandle( "ProductInventoryDrawerWnd.ProductInventoryDrawerWndTitle" );
	ProductItemName = GetTreeHandle( "ProductInventoryDrawerWnd.ProductItemName" );
	ProductItemInfo = GetTreeHandle( "ProductInventoryDrawerWnd.ProductItemInfo" );
	BIT_ProductItem = GetTextureHandle( "ProductInventoryDrawerWnd.ProductItem" );

	//ProductInfoBg = GetTextureHandle( "ProductInventoryDrawerWnd.ProductInfoBg" );
	ProductItemDetailListTitle = GetTextBoxHandle( "ProductInventoryDrawerWnd.ProductItemDetailListTitle" );
	ProductItemDetailListCounter = GetTextBoxHandle( "ProductInventoryDrawerWnd.ProductItemDetailListCounter" );
	ProductItemDetailList = GetTreeHandle( "ProductInventoryDrawerWnd.ProductItemDetailList" );

	PresentMessageTitle = GetTextBoxHandle( "ProductInventoryDrawerWnd.PresentMessageTitle" );
	SenderTitle = GetTextBoxHandle( "ProductInventoryDrawerWnd.SenderTitle" );
	Sender = GetNameCtrlHandle( "ProductInventoryDrawerWnd.Sender" );
	ProductItemDetailList2 = GetTreeHandle( "ProductInventoryDrawerWnd.ProductItemDetailList2" );

	ProductBuyInfoTitle = GetTextBoxHandle( "ProductInventoryDrawerWnd.ProductBuyInfoTitle" );
	ProductBuyInfo = GetTextBoxHandle( "ProductInventoryDrawerWnd.ProductBuyInfo" );

	RecieveBtn = GetButtonHandle( "ProductInventoryDrawerWnd.RecieveBtn" );
	CloseBtn = GetButtonHandle( "ProductInventoryDrawerWnd.CloseBtn" );

	ProductItemDetailList.SetTooltipType( "Inventory" );
}

function Load()
{
	util = L2Util(GetScript("L2Util"));
	ProductInventory = ProductInventoryWnd( GetScript("ProductInventoryWnd") );

	class'UIAPI_TREECTRL'.static.ShowScrollBar("ProductInventoryDrawerWnd.ProductItemName", false);
}

function OnClickButton( string Name )
{
	local Array<string> Result;
	Split( Name, ".", Result );

	switch( Name )
	{
	case "RecieveBtn":
		OnRecieveBtnClick();
		break;
	case "CloseBtn":
		OnCloseBtnClick();
		break;
	}
}

function OnEvent( int Event_ID, string param )
{
	switch( Event_ID )
	{
		case EV_GoodsInventoryItemDesc :			
			OnGoodsInventroyItemDesc( param );
			break;
		case EV_DialogOK :
			HandleDialogOK();
			break;
		case EV_DialogCancel :
			HandleDialogCancel();
			break;
	}
}

function HandleDialogOK()
{
	if( !DialogIsMine() )
	{
		if (!RecieveBtn.IsEnableWindow())
		{
			// 만약 비활성화 되어 있다면 풀어 준다.
			ProductInventory.SetDisableTree( true );
			RecieveBtn.EnableWindow();
			CloseBtn.EnableWindow();
		}
		return;
	}

	switch( DialogGetID() )
	{
		case DIALOGID_RECIEVE:		
			//debug("index>>>>" $ string( ProductInventory.GetSelectIndex() ) );
			//RequestUseGoodsInventoryItem( ProductInventory.GetSelectIndex() );
			RequestUseGoodsInventoryItem( SelectItemNum );
			ProductInventory.SetDisableTree( true );
			RecieveBtn.EnableWindow();
			CloseBtn.EnableWindow();
			break;
	}
}

function HandleDialogCancel()
{
	if( !DialogIsMine() )
	{
		if (!RecieveBtn.IsEnableWindow())
		{
			// 만약 비활성화 되어 있다면 풀어 준다.
			ProductInventory.SetDisableTree( true );
			RecieveBtn.EnableWindow();
			CloseBtn.EnableWindow();
		}
		return;
	}

	switch( DialogGetID() )
	{
		case DIALOGID_RECIEVE:		
			ProductInventory.SetDisableTree( true );
			RecieveBtn.EnableWindow();
			CloseBtn.EnableWindow();
			break;
	}
}

function OnGoodsInventroyItemDesc( string param )
{
	local int i;

	local int index;
	//상품 타입(0:비타민,1:상품아이콘)
	local int goodsType;	
	//상품 IconID
	local int goodsIconID;
	//상품이름
	local string goodsName;
	//0:환불불가, 1:환불 가능
	//local int goodsCondition;
	//상품설명
	local string goodsDesc;
	//0:선물 아이템 아님, 1:선물 아이템
	local int goodsGift;
	//선물 보낸이
	local string goodsSender;
	//선물 메시지
	local string goodsSenderMessage;
	//상품 구매 일시
	local string goodsDate;

	//게임 아이템 리스트의 개수
	local int gameItemCount;
	//게임 아이템의 클래스 ID( 위의 갯수 만큼 )
	local int gameItemClassID;
	//게임 아이템 수량
	local int gameItemQuantity;

	local ItemID cID;

	local Color clr;
	local string str;

	ParseInt(param, "index", index);
	
	if( index == -1 )
	{
		return;
	}

	SelectItemNum = index;
	ProductInventory.SetExpandedOpen( string(SelectItemNum) );

	ParseInt(param, "goodsType", goodsType);
	ParseInt(param, "goodsIconID", goodsIconID);
	ParseString(param, "goodsName", goodsName);
	ParseInt(param, "goodsCondition", goodsCondition);
	ParseString(param, "goodsDesc", goodsDesc);
	ParseInt(param, "goodsGift", goodsGift);
	ParseString(param, "goodsSender", goodsSender);
	ParseString(param, "goodsSenderMessage", goodsSenderMessage);
	ParseString(param, "goodsDate", goodsDate);
	ParseInt(param, "gameItemCount", gameItemCount);
	
	TreeClear( "ProductInventoryDrawerWnd.ProductItemDetailList" );
	ShowSkillTree();
	
	//아이콘...
	if( goodsType == 0 )
	{
		//debug( string(goodsIconID));
		//debug( class'UIDATA_ITEM'.static.GetItemTextureName( GetItemID( goodsIconID ) ));
		BIT_ProductItem.SetTexture( class'UIDATA_ITEM'.static.GetItemTextureName( GetItemID( goodsIconID ) ) );
	}
	else
	{
		//debug(GetGoodsIconName( goodsIconID ) );
		BIT_ProductItem.SetTexture( GetGoodsIconName( goodsIconID ) );
	}

	/**
	 * 상품 이름
	 */
	util.TreeClear( "ProductInventoryDrawerWnd.ProductItemName" );
	//Root 노드 생성.
	util.TreeInsertRootNode( "ProductInventoryDrawerWnd.ProductItemName", "root", "" );
	//Insert Node Item - 아이템 이름
	if( goodsCondition == 0 || goodsCondition == 2 )
	{
		util.TreeInsertTextMultiNodeItem( "ProductInventoryDrawerWnd.ProductItemName", "root", goodsName, 4, -2, 38, util.ETreeItemTextType.COLOR_DEFAULT );
	}
	else if( goodsCondition == 1 )
	{
		util.TreeInsertTextMultiNodeItem( "ProductInventoryDrawerWnd.ProductItemName", "root", goodsName, 4, -2, 38, util.ETreeItemTextType.COLOR_YELLOW );
	}


	/**
	 *  상품 설명
	 */
	//스킬 설명	
	util.TreeClear( "ProductInventoryDrawerWnd.ProductItemInfo" );
	//Root 노드 생성.
	util.TreeInsertRootNode( "ProductInventoryDrawerWnd.ProductItemInfo", "root", "" );
	//Insert Node Item - 아이템 이름
	util.TreeInsertTextNodeItem( "ProductInventoryDrawerWnd.ProductItemInfo", "root", goodsDesc );

	//<TextColor R="175" G="152" B="120"/>	
	clr.R = 175;
	clr.G = 152;
	clr.B = 120;
	clr.A = 255;

	//보낸이
	if( goodsGift == 0 )
	{
		Sender.SetNameWithColor( GetSystemString(2475), NCT_Normal,TA_Left, clr );
	}
	else
	{
		str = substitute( goodsSender, "_", "/", true );
		Sender.SetNameWithColor( str, NCT_Normal,TA_Left, clr );
	}

	/**
	 * 보낸이 메시지
	 */
	util.TreeClear( "ProductInventoryDrawerWnd.ProductItemDetailList2" );
	//Root 노드 생성.
	util.TreeInsertRootNode( "ProductInventoryDrawerWnd.ProductItemDetailList2", "root", "" );
	//Insert Node Item - 아이템 이름
	util.TreeInsertTextNodeItem( "ProductInventoryDrawerWnd.ProductItemDetailList2", "root", goodsSenderMessage );

	ProductBuyInfo.SetText( goodsDate );

	for( i = 0 ; i < gameItemCount ; i++ )
	{
		ParseInt( param, "gameItemClassID_" $ i, gameItemClassID );
		ParseInt( param, "gameItemQuantity_"$i, gameItemQuantity );

		cID = GetItemID( gameItemClassID );
		
		MakeTreeNode( cID, class'UIDATA_ITEM'.static.GetItemName( cID ) , i , gameItemClassID, gameItemQuantity );
	}

	ProductItemDetailListCounter.SetText("("$string(gameItemCount)$"/10)");

	Me.ShowWindow();
}

/*
function testCall()
{
	local Color clr;
	local string str;

	str = "얼마_나길어야 튀어나가는건지 알수가 없네 젠장 그리고 색상은 왜 안바뀌는지?";
	
	str = substitute( str, "_", "/", true );
	
	clr.R = 175;
	clr.G = 152;
	clr.B = 120;
	clr.A = 255;

	Sender.SetNameWithColor( str, NCT_Normal,TA_Left, clr );

	ProductItemDetailListCounter.SetText("(3/10)");
}
*/


function MakeTreeNode( ItemID cID, string goodsName,int index, int id, int itemnum )
{
	local string setTreeName;
	local string TREENAME;
	local string strRetName;
	local string stritemName;
	
	setTreeName = "root";
	TREENAME = "ProductInventoryDrawerWnd.ProductItemDetailList";
	
	strRetName = util.TreeInsertItemNode( TREENAME, "" $ index , setTreeName );

	if( bDrawBgTree == true )
	{
		//Insert Node Item - 아이템 배경?
		util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_CH3.etc.textbackline", 298, 38, , , , ,14 );
	}
	else
	{
		util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_CT1.EmptyBtn", 298, 38 );
	}

	bDrawBgTree = !bDrawBgTree;	

	//Insert Node Item - 아이템슬롯 배경
	util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_ct1.ItemWindow.ItemWindow_df_slotbox_2x2", 36, 36, -291, 2 );
	//Insert Node Item - 아이템 아이콘
	util.TreeInsertTextureNodeItem( TREENAME, strRetName, class'UIDATA_ITEM'.static.GetItemTextureName( cID ), 32, 32, -34, 3 );

	stritemName = "" $ goodsName $ " (" $ String(itemnum) $ ")";
	
	util.TreeInsertTextMultiNodeItem( TREENAME, strRetName, stritemName, 4, 0, 38, util.ETreeItemTextType.COLOR_DEFAULT, , id, itemnum );
}

function OnRecieveBtnClick()
{
	if( SelectItemNum != -1 )
	{
		if( goodsCondition == 0 || goodsCondition == 2 )
		{
			RequestUseGoodsInventoryItem( SelectItemNum );
		}
		else if( goodsCondition == 1)
		{
			ProductInventory.SetDisableTree( false );
			RecieveBtn.DisableWindow();
			CloseBtn.DisableWindow();
			DialogSetID( DIALOGID_RECIEVE );
			//DialogShow( DIALOG_Modalless, DIALOG_WARNING, "선택하신 상품 아이템을 본인 캐릭터의 인벤토리에서 수령하게 되면 해당 아이템을 사용한 것으로 간주되어 청약철회가 제한됩니다.\\n\\n정말로 선택한 아이템을 수령하시겠습니까?" );
			DialogShow( DialogModalType_Modalless, DialogType_Warning, GetSystemMessage(3387), string(Self) );
		}
	}
}

function OnCloseBtnClick()
{
	RequestGoodsInventoryItemDesc( -1 );
	SelectItemNum = -1;
	ProductInventory.SetSelectClear();
	Me.HideWindow();
}

// 트리 비우기
function TreeClear( string TREENAME )
{
	class'UIAPI_TREECTRL'.static.Clear( TREENAME );
}

function ShowSkillTree()
{	
	//Root 노드 생성.
	util.TreeInsertRootNode( "ProductInventoryDrawerWnd.ProductItemDetailList", "root", "", 0, 4 );
}
defaultproperties
{
}
