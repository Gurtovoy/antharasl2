class ProductInventoryWnd extends UICommonAPI;

var WindowHandle Me;
var TextBoxHandle txtItemList;
var TreeHandle ProductListTree;
var ButtonHandle HelpHtmlBtn;
var TextureHandle ProductListBack;
var WindowHandle HelpHtmlWnd;

var string TREENAME;
var string ROOTNAME;

var bool bDrawBgTree;

var int selectItemIndex;

var string beforeTreeName;

var WindowHandle     m_inventoryWnd;

//UI용 UC
var L2Util util;


function OnRegisterEvent()
{
	RegisterEvent( EV_GoodsInventoryItemList );
	RegisterEvent( EV_GoodsInventoryResult );
}

function OnLoad()
{
	SetClosingOnESC();

	Initialize();
	Load();
}

function Initialize()
{
	Me = GetWindowHandle( "ProductInventoryWnd" );
	txtItemList = GetTextBoxHandle( "ProductInventoryWnd.txtItemList" );
	ProductListTree = GetTreeHandle( "ProductInventoryWnd.ProductListTree" );
	HelpHtmlBtn = GetButtonHandle( "ProductInventoryWnd.HelpHtmlBtn" );
	ProductListBack = GetTextureHandle( "ProductInventoryWnd.ProductListBack" );

	HelpHtmlWnd = GetWindowHandle( "ProductInventoryHelpHtmlWnd" );

	m_inventoryWnd = GetWindowHandle( "InventoryWnd" );	//인벤토리의 윈도우 핸들을 얻어온다.
} 

function Load()
{
	util = L2Util(GetScript("L2Util"));	
}

function OnShow()
{
	//if( m_inventoryWnd.IsShowWindow() )			//인벤토리 창이 열려있으면 닫아준다. 
	//{
	//	m_inventoryWnd.HideWindow();
	//}
	// 지정한 윈도우를 제외한 닫기 기능 
	getInstanceL2Util().ItemRelationWindowHide(getCurrentWindowName(String(self)));

	PlayConsoleSound(IFST_WINDOW_OPEN);
	
	//창을 열때 List 재 생성. 
	TreeClear();
	class'UIAPI_TREECTRL'.static.Clear( "ProductInventoryDrawerWnd.ProductItemDetailList" );
	RequestGoodsInventoryItemList();
}

function OnHide()
{
	DescHide();
	PlayConsoleSound(IFST_WINDOW_CLOSE);

	if( DialogIsMine() )
	{		
		DialogHide();
	}
}

function DescHide()
{
	local WindowHandle win;	
	win = GetWindowHandle( "ProductInventoryDrawerWnd" );
	
	DialogHide();
	class'UIAPI_WINDOW'.static.EnableWindow("ProductInventoryDrawerWnd.RecieveBtn");
	class'UIAPI_WINDOW'.static.EnableWindow("ProductInventoryDrawerWnd.CloseBtn");
	beforeTreeName = "";
	SetDisableTree( true );

	if( win.IsShowWindow() )
	{
		win.HideWindow();
		RequestGoodsInventoryItemDesc( -1 );
		SetSelectClear();
	}
}

function OnClickButton( string strID )
{
	local Array<string> Result;	

	//debug( strID );

	//local ProductInventoryDrawerWnd sc;
	//sc = ProductInventoryDrawerWnd(GetScript("ProductInventoryDrawerWnd"));	

	Split( strID, ".", Result );

	if( strID == "HelpHtmlBtn" )
	{
		OnHelpHtmlBtnClick();
		//class'UIAPI_WINDOW'.static.ShowWindow("ProductInventoryDrawerWnd");
		//sc.testCall();
	}

	if( Result[0] == ROOTNAME )
	{
		if( beforeTreeName != strID )
		{
			ProductListTree.SetExpandedNode( beforeTreeName, false );
			ProductListTree.SetExpandedNode( strID, true );
			selectItemIndex = int( Result[1]);
			RequestGoodsInventoryItemDesc( selectItemIndex );
		}
		else
		{
			ProductListTree.SetExpandedNode( beforeTreeName, true );
		}

		beforeTreeName = strID;
	}
}

function OnEvent( int Event_ID, string param )
{
	switch( Event_ID )
	{
		case EV_GoodsInventoryItemList :
			//Me.ShowWindow();
			OnGoodsInventoryItemList(param);
			break;

		case EV_GoodsInventoryResult :
			OnGoodsInventoryResult( param );
			break;
	}
}

function OnGoodsInventoryItemList( string param )
{
	//15
	//goodsCount=12 goodsIconID_0=1 goodsName_0=이름0 goodsCondition_0=0 goodsIconID_1=2 goodsName_1=이름1 goodsCondition_1=1 goodsIconID_2=3 goodsName_2=이름2 goodsCondition_2=0 goodsIconID_3=4 goodsName_3=이름3 goodsCondition_3=1
 	local int i;

	local int goodsCount;
	local int goodsType;
	local int goodsIconID;  
	local string goodsName;
	//0:환불불가, 1:환불 가능
	local int goodsCondition;

	local string strTexture;

	local ItemID cID;

	TreeClear();
	ShowSkillTree();

	//debug(param);

	ParseInt(param, "goodsCount", goodsCount);
	
	for( i = 0 ; i < goodsCount ; i++)
	{
		ParseInt( param, "goodsType_"$i, goodsType );
		ParseInt( param, "goodsIconID_"$i, goodsIconID );
		ParseString( param, "goodsName_"$i, goodsName );
		ParseInt( param, "goodsCondition_"$i, goodsCondition );

		//굿즈 네임이 40자 넘어갈 경우 ...으로 표현
		if ( Len( goodsName ) > 40 ) 
		{
			goodsName = Left(goodsName, 37) $"..."; 			
		}

		cID = GetItemID( goodsIconID );

		//MakeTreeNode( cID, goodsName, goodsCondition, goodsIconID );
		if( goodsType == 0 )
		{
			strTexture = class'UIDATA_ITEM'.static.GetItemTextureName( cID );
		}
		else
		{
			strTexture = GetGoodsIconName( goodsIconID );
		}
		MakeTreeNode( cID, goodsName, goodsCondition, i, strTexture );			
	}

}

/**
 * 각 아이템 Tree 노드 생성.
 */
function MakeTreeNode( ItemID cID, string goodsName, int goodsCondition, int index, string Texture )
{
	local string setTreeName;
	local string strRetName;

	setTreeName = ROOTNAME;
	//strRetName = util.TreeInsertItemTooltipNode( TREENAME, "" $ index , setTreeName, -2, 0, 38, 0, 30, 38, util.getCustomTooltip() );
	strRetName = util.TreeInsertItemTooltipSimpleNode( TREENAME, "" $ index , setTreeName, -2, 0, 38, 0, 30, 38 );

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
	util.TreeInsertTextureNodeItem( TREENAME, strRetName, Texture, 32, 32, -34, 3 );
	//util.TreeInsertTextureNodeItem( TREENAME, strRetName, GetGoodsIconName( 0 ), 32, 32, -34, 3 );
	//debug( GetGoodsIconName( 1 ) );

	if( goodsCondition == 0 || goodsCondition == 2 )
	{
		util.TreeInsertTextMultiNodeItem( TREENAME, strRetName, goodsName, 4, 0, 38, util.ETreeItemTextType.COLOR_DEFAULT );
	}
	else if( goodsCondition == 1 )
	{
		util.TreeInsertTextMultiNodeItem( TREENAME, strRetName, goodsName, 4, 0, 38, util.ETreeItemTextType.COLOR_YELLOW );
	}
}

/**
 * 예외 처리 및 결과 처리.
 */
function OnGoodsInventoryResult( string param )
{
	local int Result;

	ParseInt(param, "Result", Result);
		
	if( Result == 1 )
	{
		//상품조회 성공		
	}	
	else if( Result == 2 )
	{
		//상품 수령 성공
		AddSystemMessage( 3412 );
		DescHide();
	}

	/**
	 * Server Error
	 */
	if( Result < 0 )
	{
		Me.HideWindow();
		DescHide();

		if( Result == -1 )
		{
			//잘못된 요청 (각종 오류)
			//3377 : 요청이 잘못되었습니다.
			DialogShow( DialogModalType_Modalless, DialogType_Notice, GetSystemMessage(3377), string(self) );
		}
		else if( Result == -2 )
		{
			//알 수 없는 시스템 오류
			//3385 : 시스템 오류로 상품 인벤토리를 이용하실 수 없습니다. 잠시 후 다시 시도해주세요.
			DialogShow( DialogModalType_Modalless, DialogType_Notice, GetSystemMessage(3385), string(self) );
		}
		else if( Result == -3 )
		{
			//게임 인벤토리 용량 초과
			//3386 : 게임 인벤토리의 무게/수량 제한을 초과하여 상품을 받을 수 없습니다. 인벤토리의 무게/수량이 80퍼센트 미만일 때만 받을 수 있습니다.
			DialogShow( DialogModalType_Modalless, DialogType_Notice, GetSystemMessage(3386), string(self) );
		}
		else if( Result == -4 )
		{
			//SA 서버 접속 불가
			//3411 : 현재 상품 관리 서버에 접속할 수 없습니다. 잠시 후 다시 시도해주세요.
			DialogShow( DialogModalType_Modalless, DialogType_Notice, GetSystemMessage(3411), string(self) );
		}
		else if( Result == -5 )
		{
			//현재 거래 중
			//3413 : 거래 중, 개인 상점 및 공방 개설 중에는 상품 인벤토리를 이용하실 수 없습니다.
			//AddSystemMessage( 3413 );
			DialogShow( DialogModalType_Modalless, DialogType_Notice, GetSystemMessage(3413), string(self) );
		}
		else if( Result == -6 )
		{
			//수령 할 상품 존재하지 않음
			//3417 : 현재 상품 인벤토리 내에 수령할 상품이 존재하지 않습니다.
			DialogShow( DialogModalType_Modalless, DialogType_Notice, GetSystemMessage(3417), string(self) );
		}

		/**
		 * SA Error
		 */
		else if( Result == -101 )
		{
			//현재 처리 중인 작업이 많아 상품 인벤토리를 갱신할 수 없음. (-101)
			//현재 이용자가 많아 상품 인벤토리를 조회할 수 없습니다. 잠시 후 다시 시도해주세요.
			//DialogShow( DIALOG_Modalless, DIALOG_Notice, "현재 이용자가 많아 상품 인벤토리를 조회할 수 없습니다. 잠시 후 다시 시도해주세요." );
			DialogShow( DialogModalType_Modalless, DialogType_Notice, GetSystemMessage(3378), string(self) );
		}
		else if( Result == -102 )
		{
			//수령 시 SA 서버 사용자 많음
			//3410 : 현재 이용자가 많아 상품을 수령하실 수 없습니다. 잠시 후 다시 시도해주세요.
			DialogShow( DialogModalType_Modalless, DialogType_Notice, GetSystemMessage(3410), string(self) );
		}
		else if( Result == -103 )
		{
			//이전 작업 진행 중
			//3379 : 이전 요청이 아직 완료되지 않았습니다. 잠시 기다려주세요.
			//AddSystemMessage( 3379 );
			DialogShow( DialogModalType_Modalless, DialogType_Notice, GetSystemMessage(3379), string(self) );
		}
		else if( Result == -104 )
		{
		}
		else if( Result == -105 )
		{
			//요구 상품 이미 청약철회
			//3381 : 상품이 이미 청약철회 처리되었습니다.
			DialogShow( DialogModalType_Modalless, DialogType_Notice, GetSystemMessage(3381), string(self) );
		}
		else if( Result == -106 )
		{
			//요구 상품 이미 수령
			//3382 : 상품을 이미 수령하셨습니다.
			DialogShow( DialogModalType_Modalless, DialogType_Notice, GetSystemMessage(3382), string(self) );
		}
		else if( Result == -107 )
		{
			//상품을 수령할 수 없는 월드
			//3383 : 이 서버에서는 선택하신 상품을 수령하실 수 없습니다.
			DialogShow( DialogModalType_Modalless, DialogType_Notice, GetSystemMessage(3383), string(self) );
		}
		else if( Result == -108 )
		{
			//상품을 수령할 수 없는 캐릭터
			//3384 : 이 캐릭터로는 선택하신 상품을 수령하실 수 없습니다.
			DialogShow( DialogModalType_Modalless, DialogType_Notice, GetSystemMessage(3384), string(self) );
		}
	}
}


function OnHelpHtmlBtnClick()
{
	HelpHtmlWnd.ShowWindow();
}


// 트리 비우기
function TreeClear()
{
	ProductListTree.SetScrollPosition(0);
	class'UIAPI_TREECTRL'.static.Clear( TREENAME );
}

function ShowSkillTree()
{	
	//Root 노드 생성.
	util.TreeInsertRootNode( TREENAME, ROOTNAME, "", 0, 4 );
}

function int GetSelectIndex()
{
	return selectItemIndex;
}

function SetSelectClear()
{
	ProductListTree.SetExpandedNode( beforeTreeName, false );
	beforeTreeName = "";
}

/**
 * Tree 비활성화.
 */
function SetDisableTree( bool b )
{
	if( b == true )
	{
		ProductListTree.EnableWindow();
	}
	else
	{
		ProductListTree.DisableWindow();
	}
}

/**
 * 목록이 열려 있을때 새로운 아이템이 들어오면 새로운 node 열어줌.
 */
function SetExpandedOpen( string NodeName )
{
	local string openNode;

	openNode = ProductListTree.GetExpandedNode( "root" );

	if( openNode == "" )
	{
		ProductListTree.SetExpandedNode( "root."$NodeName, true );
	}
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	Me.HideWindow();
}


defaultproperties
{
    TREENAME="ProductInventoryWnd.ProductListTree"
    ROOTNAME="root"
}
