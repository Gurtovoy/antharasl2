/**
 *   UI 관련 편의 함수  
 **/
class L2Util extends UICommonAPI;

/*
   ex) 
   var L2Util util;
   util = L2Util(GetScript("L2Util"));
*/

// 칼라
var Color White;
var Color Yellow;
var Color Blue;
var Color BrightWhite;
var Color Gold;
var Color Gray;
var Color Yellow03;
var Color ColorDesc;
var Color ColorYellow;




var Color ColorGray;
var Color ColorLightBrown;
var Color ColorGold;
var Color ColorMinimapFont;



//branch GD35_0828 2014-1-13 luciper3 - 배우자를 표시할때 핑크로 할려고 추가함. 핫핑크 온라인, 파우더핑크 오프라인
var Color HotPink;
var Color PowderPink;
//end of branch

var Color Token0;
var Color Token1;
var Color Token2;
var Color Token3;

var Color DarkGray;
var Color BWhite;
var Color DRed;

var Color BLUE01;
 

/*
 		case ETreeItemTextType.TOKEN0:
			infNodeItem.t_color.R = 211;
			infNodeItem.t_color.G = 192;
			infNodeItem.t_color.B = 82;
			infNodeItem.t_color.A = 255;
			break;		
		case ETreeItemTextType.TOKEN1:
			infNodeItem.t_color.R = 170;
			infNodeItem.t_color.G = 152;
			infNodeItem.t_color.B = 120;
			infNodeItem.t_color.A = 255;
			break;		
		case ETreeItemTextType.TOKEN2:
			infNodeItem.t_color.R = 168;
			infNodeItem.t_color.G = 103;
			infNodeItem.t_color.B = 53;
			infNodeItem.t_color.A = 255;
			break;		
		case ETreeItemTextType.TOKEN3:
			infNodeItem.t_color.R = 175;
			infNodeItem.t_color.G = 42;
			infNodeItem.t_color.B = 39;
			infNodeItem.t_color.A = 255;
			break;
*/
/**
 *  Tree 용 **************************************************************************************************************
 **/
enum ETreeItemTextType
{
	COLOR_DEFAULT,
	COLOR_GRAY,
	COLOR_GOLD,
	COLOR_RED,
	COLOR_YELLOW,
	COLOR_DESC,
	COLOR_BLUE,
	COLOR_BRIGHT_BLUE,
	TOKEN0,
	TOKEN1,
	TOKEN2,
	TOKEN3,
	YELLOW03
};
//************************************************************************************************************************


/**
 *  ToopTip 용 ***********************************************************************************************************
 **/
var CustomTooltip TooltipText;
var DrawItemInfo TooltipInfo;

enum ETooltipTextType
{
	COLOR_DEFAULT,
	COLOR_GRAY,
	COLOR_GOLD,
	COLOR_YELLOW,
	COLOR_YELLOW03,
	COLOR_RED, 
	COLOR_BLUE
};
//************************************************************************************************************************

/**
 *  GfxScreenMessage 용
 */
  
enum EGfxScreenMsgType
{
	MSGType_Normal,
	MSGType_AddItemEffect,
	MSGType_Chatting
};
//************************************************************************************************************************

// 아이템 관계된 윈도우 이름 배열 스트링 
var array<string>	ItemRelationWindowArrayStr;
var string	        ItemRelationWindowString;

var PrivateShopWnd          privateShopWndScript;
var RefineryWnd             RefineryWndScript;
var UnrefineryWnd           UnrefineryWndScript;
var AttributeRemoveWnd      AttributeRemoveWndScript;
var AttributeEnchantWnd     AttributeEnchantWndScript;

var CrystallizationWnd          CrystallizationWndScript;
var ItemEnchantWnd              ItemEnchantWndScript;
var ItemLookChangeWnd           ItemLookChangeWndScript; //branch 111109
var MultiSellWnd                MultiSellWndScript;
var WarehouseWnd                WarehouseWndScript;
var TradeWnd                    TradeWndScript;
var DeliverWnd					DeliverWndScript;
var ItemAttributeChangeWnd      ItemAttributeChangeWndScript;

//2012.09.12 웹링크 추가 
const DIALOGID_GoWeb = 10;
//Url 값 저장.
var string Url;
var string Text;
//////


/**
 *  봉인 타입 ***********************************************************************************************************
 **/
enum EItemLockedCheckType
{
	ANY,
	LOCK,
	UNLOCK,
	NOT_LOCK,
	NOT_UNLOCK
};


var string m_reservedInt2;

// 한번만 ini 로드를 하기 위해서..
var bool bCheckUsePledgeV2;

var int nUsePledgeV2Classic, nUsePledgeV2Live;

delegate bool myDelegate(bool bFirst, string str);

function OnRegisterEvent()
{	
	RegisterEvent( EV_UrlLinkClick );   //4960
	RegisterEvent( EV_DialogOK );
	RegisterEvent( EV_DialogCancel );

	RegisterEvent( EV_Restart );
}

/**
 * OnEvent
 **/
function OnEvent( int Event_ID, string param )
{
	switch ( Event_ID )
	{
		case EV_UrlLinkClick:
			linkWebPage( param );
			break;

		case EV_DialogOK:
			HandleDialogOK();
			break;

		case EV_DialogCancel:
			break;

		case EV_Restart :
			bCheckUsePledgeV2 = false;
			nUsePledgeV2Classic = 0;
			nUsePledgeV2Live = 0;
			break;
	}
}

function bool isClanV2()
{	
	local bool bValue;

	// 클래식
	if ( getInstanceUIData().getisClassicServer() )
	{
		if(bCheckUsePledgeV2 == false)
		{
			bCheckUsePledgeV2 = true;
			GetINIBool ( "Localize", "UsePledgeV2Classic", nUsePledgeV2Classic, "L2.ini" );

			Debug("- GetINIBool UsePledgeV2Classic" @ nUsePledgeV2Classic);
		}

		// 혈맹 리뉴얼 UI 사용
		if (nUsePledgeV2Classic > 0)
			bValue = true;
	}
	else
	{
		// 라이브
		if(bCheckUsePledgeV2 == false)
		{
			bCheckUsePledgeV2 = true;
			GetINIBool ( "Localize", "UsePledgeV2Live", nUsePledgeV2Live, "L2.ini" );

			Debug("- GetINIBool UsePledgeV2Live" @ nUsePledgeV2Live);
		}

		// 혈맹 리뉴얼 UI 사용
		if (nUsePledgeV2Live > 0)
			bValue = true;
	}

	// Debug("혈v2 " @ bValue);

	return bValue;

}


function HandleDialogOK()
{
	if( !DialogIsMine() )
		return;

	switch( DialogGetID() )
	{
	case DIALOGID_GoWeb:		
		OpenGivenURL( Url );
		break;
	}
}

function linkWebPage( string param )
{	
	local ELanguageType Language;	 //branch121212

	if ( !ParseString(param, "Url", Url) )
	return;

	if ( !ParseString(param, "Text", Text) )
	{
		Text = "";
	}

	//debug( "Url---->" $ Url @ GetSystemString( 2265 ));
	//debug( "Text---->" $ Text );
	DialogHide();
	DialogSetID( DIALOGID_GoWeb );
	if( Text != "" )
	{
		DialogShow( DialogModalType_Modalless, DialogType_OKCancel, MakeFullSystemMsg( GetSystemMessage( 3211 ) , Text, "" ), string(Self) );
	}
	else
	{
		//branch121212
		Language = GetLanguage();
		if( Language != LANG_Korean )
		{
			DialogShow( DialogModalType_Modalless, DialogType_OKCancel, MakeFullSystemMsg( GetSystemMessage( 6172 ) , "", "" ), string(Self) );
			return;
		}
		//end of branch
	
		if( Url == GetSystemString( 2265 ) )
		{
			DialogShow( DialogModalType_Modalless, DialogType_OKCancel, MakeFullSystemMsg( GetSystemMessage( 3211 ) , GetSystemString( 2259 ), "" ), string(Self) );
		}
		else if( Url == GetSystemString( 2266 ) )
		{
			DialogShow( DialogModalType_Modalless, DialogType_OKCancel, MakeFullSystemMsg( GetSystemMessage( 3211 ) , GetSystemString( 2261 ), "" ), string(Self) );
		}
		else if( Url == GetSystemString( 2267 ) )
		{
			DialogShow( DialogModalType_Modalless, DialogType_OKCancel, MakeFullSystemMsg( GetSystemMessage( 3211 ) , GetSystemString( 2263 ), "" ), string(Self) );
		}
		else if( Url == GetSystemString( 2762 ) )//파워북 링크
		{
			DialogShow( DialogModalType_Modalless, DialogType_OKCancel, MakeFullSystemMsg( GetSystemMessage( 3211 ) , GetSystemString( 2760 ), "" ), string(Self) );
		}
		else if( Url == GetSystemString( 2775 ) ) //멘토링(가이드) 링크
		{
			// 2773: 멘토링 가이드
			DialogShow( DialogModalType_Modalless, DialogType_OKCancel, MakeFullSystemMsg( GetSystemMessage( 3211 ) , GetSystemString( 2773 ), "" ), string(Self) );
		}
		else
		{
			if (Url != "")
			{
				// 901 : 정보
				DialogShow( DialogModalType_Modalless, DialogType_OKCancel, MakeFullSystemMsg( GetSystemMessage( 3211 ) , GetSystemString( 901 ), "" ), string(Self) );
			}
		}
	}
}


/**
 * OnLoad
 **/
function OnLoad()
{
	initColor();

	ItemRelationWindowString = "MultiSellWnd,WarehouseWnd,ShopWnd,TradeWnd,DeliverWnd,SellingAgencyWnd,PostBoxWnd,PostWriteWnd,PostDetailWnd_General,AttendCheckWnd," $
							   "PostDetailWnd_SafetyTrade,ProductInventoryWnd,PrivateShopWnd,PremiumItemGetWnd,ManorShopWnd,AttributeEnchantWnd,AttributeRemoveWnd," $
							   "ItemEnchantWnd,RefineryWnd,UnrefineryWnd,CrystallizationWnd,InventoryWnd,ItemAttributeChangeWnd,ItemLookChangeWnd,ProgressBox,RecipeShopWnd," $
							   "TokenTradeWnd,AdenaDistributionWnd,ItemJewelEnchantWnd,AlchemyMixCubeWnd,AlchemyItemConversionWnd,EnsoulWnd,EnsoulExtractWnd,ItemJewelEnchantWnd," $
							   "ItemUpgrade,ItemLockWnd"; 
	
	// 아이템 관계된 윈도우 이름 배열
	Split(ItemRelationWindowString, ",", ItemRelationWindowArrayStr);


	privateShopWndScript = PrivateShopWnd(GetScript("PrivateShopWnd"));
	RefineryWndScript    = RefineryWnd(GetScript("RefineryWnd"));
	UnrefineryWndScript  = UnrefineryWnd(GetScript("UnrefineryWnd"));

	UnrefineryWndScript        = UnrefineryWnd(GetScript("UnrefineryWnd"));
	AttributeRemoveWndScript   = AttributeRemoveWnd(GetScript("AttributeRemoveWnd"));
	AttributeEnchantWndScript  = AttributeEnchantWnd(GetScript("AttributeEnchantWnd"));

	CrystallizationWndScript        = CrystallizationWnd(GetScript("CrystallizationWnd"));
	ItemEnchantWndScript            = ItemEnchantWnd(GetScript("ItemEnchantWnd"));
	ItemLookChangeWndScript         = ItemLookChangeWnd(GetScript("ItemLookChangeWnd")); //branch 111109
	MultiSellWndScript              = MultiSellWnd(GetScript("MultiSellWnd"));
	WarehouseWndScript              = WarehouseWnd(GetScript("WarehouseWnd"));
	TradeWndScript                  = TradeWnd(GetScript("TradeWnd"));
	DeliverWndScript                = DeliverWnd(GetScript("DeliverWnd"));
	ItemAttributeChangeWndScript    = ItemAttributeChangeWnd(GetScript("ItemAttributeChangeWnd"));
	
}

/**
 *  칼라 값들 세팅 
 **/ 
function initColor()
{
	BrightWhite.R = 255;
	BrightWhite.G = 255;
	BrightWhite.B = 255;	
	BrightWhite.A = 255;

	White.R = 170;
	White.G = 170;
	White.B = 170;
	White.A = 255;

	Yellow.R = 235;
	Yellow.G = 205;
	Yellow.B = 0;
	Yellow.A = 255;

	Blue.R = 102;
	Blue.G = 150;
	Blue.B = 253;
	Blue.A = 255;

	Gold.R = 176;
	Gold.G = 153;
	Gold.B  = 121;
	Gold.A = 255;

	Gray.R = 120;
	Gray.G = 120;
	Gray.B = 120;
	Gray.A = 255;

	//branch GD35_0828 2014-1-13 luciper3 - 배우자를 표시할때 핑크로 할려고 추가함.
	HotPink.R = 195;
	HotPink.G = 46;
	HotPink.B = 97;
	HotPink.A = 255;

	PowderPink.R = 255;
	PowderPink.G = 192;
	PowderPink.B = 203;
	PowderPink.A = 255;
	//end of branch

	Token0.R = 211;
	Token0.G = 192;
	Token0.B = 82;
	Token0.A = 255;
		
	Token1.R = 170;
	Token1.G = 152;
	Token1.B = 120;
	Token1.A = 255;

	Token2.R = 168;
	Token2.G = 103;
	Token2.B = 53;
	Token2.A = 255;

	Token3.R = 175;
	Token3.G = 42;
	Token3.B = 39;
	Token3.A = 255;

	Yellow03.R = 255;
	Yellow03.G = 204;
	Yellow03.B = 0;
	Yellow03.A = 255;

	// --- 이제 부터 이런식으로 Color를 붙여서.. 
	ColorDesc.R = 175;
	ColorDesc.G = 185;
	ColorDesc.B = 205;
	ColorDesc.A = 255;

	ColorYellow.R = 255;
	ColorYellow.G = 221;
	ColorYellow.B = 102;
	ColorYellow.A = 255;

	ColorGray.R = 153;
	ColorGray.G = 153;
	ColorGray.B = 153;
	ColorGray.A = 255;

	ColorGold.R = 176;
	ColorGold.G = 153;
	ColorGold.B = 121;
	ColorGold.A = 255;

	ColorMinimapFont.R = 181;
	ColorMinimapFont.G = 181;
	ColorMinimapFont.B = 170;
	ColorMinimapFont.A = 255;

	ColorLightBrown.R = 238;
	ColorLightBrown.G = 170;
	ColorLightBrown.B = 34;
	ColorLightBrown.A = 255;

	DarkGray.R = 68;
	DarkGray.G = 68;
	DarkGray.B = 68;
	DarkGray.A = 255;

	BWhite.R = 211;
	BWhite.G = 211;
	BWhite.B = 211;
	BWhite.A = 255;

	DRed.R = 255;
	DRed.G = 102;
	DRed.B = 102;
	DRed.A = 255;

	BLUE01.R = 85;
	BLUE01.G = 153;
	BLUE01.B = 255;
	BLUE01.A = 255;

}

/**
 * 버튼의 텍스트를 변경한다. 이때 시스템스트링의 인덱스를 주어 텍스트를 선택한다
 * 
 * @param
 * controlPath   : xml 컨트롤 경로
 * texturePath   : 패키징 된 텍스쳐 경로
 * playLoopCount : 재생되는 루프 카운트 
 * 
 * @return
 * void
 * 
 * @example 
 * animTexturePlay("testWnd.montionTexture", "l2_state_l2_...", 1);
 * 
 * */
function animTexturePlay(string controlPath, string texturePath,int playLoopCount)
{	
	GetAnimTextureHandle(controlPath).SetTexture(texturePath);
	GetAnimTextureHandle(controlPath).ShowWindow();
	GetAnimTextureHandle(controlPath).SetLoopCount(playLoopCount);
	GetAnimTextureHandle(controlPath).Stop();
	GetAnimTextureHandle(controlPath).Play();
}



/*
 * ex)	
 * //Root 노드 생성.
 * util.TreeInsertRootNode( TREENAME, ROOTNAME, "", 0, 4 );
 * //+버튼 있는 상위 노드 생성
 * util.TreeInsertExpandBtnNode( TREENAME, "LIST1", ROOTNAME );
 * //위의 노드에 글씨 아이템 추가
 * util.TreeInsertTextNodeItem( TREENAME, ROOTNAME$"."$"LIST1", GetSystemString(2370), 5, 0, util.ETreeItemTextType.COLOR_DEFAULT, true );
 * 
 * //아이템 배경 만들기(있는넘)
 * util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_CH3.etc.textbackline", 257, 38, , , , ,14 );
 * //아이템 배경 만들기(없는넘)
 * util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_CT1.EmptyBtn", 257, 38 );
 * 아이템 만들기..아래.
	//Insert Node Item - 아이템슬롯 배경
	util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_ct1.ItemWindow.ItemWindow_df_slotbox_2x2", 36, 36, -251, 2 );
	//Insert Node Item - 아이템 아이콘
	util.TreeInsertTextureNodeItem( TREENAME, strRetName, strIconName, 32, 32, -34, OFFSET_Y_ICON_TEXTURE - 1 );
	//Insert Node Item - 아이템 이름
	util.TreeInsertTextNodeItem( TREENAME, strRetName, strName, 5, 5, util.ETreeItemTextType.COLOR_DEFAULT, true );
	//Insert Node Item - "Lv"
	util.TreeInsertTextNodeItem( TREENAME, strRetName, GetSystemString(88),46, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GRAY, true, true );
	//Insert Node Item - 레벨 값
	util.TreeInsertTextNodeItem( TREENAME, strRetName, string(iLevel), 2, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GOLD );
	//Insert Node Item - MP물약 아이콘 ( 소모엠피 )
	util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_CT1.SkillWnd_DF_ListIcon_MP", 15, 15, 5, OFFSET_Y_SECONDLINE + 1 );
	//Insert Node Item - "Test 값"
	util.TreeInsertTextNodeItem( TREENAME, strRetName, "630", 0, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GRAY );
	//Insert Node Item - 시간 아이콘 ( 시전시간 )
	util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_CT1.SkillWnd_DF_ListIcon_use", 15, 15, 5, OFFSET_Y_SECONDLINE + 1 );
	//Insert Node Item - "Test 값"
	util.TreeInsertTextNodeItem( TREENAME, strRetName, "2초", 0, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GRAY );
	//Insert Node Item - 시간 아이콘 ( 재사용시간 )
	util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_CT1.SkillWnd_DF_ListIcon_Reuse", 15, 15, 5, OFFSET_Y_SECONDLINE + 1 );
	//Insert Node Item - "Test 값"
	util.TreeInsertTextNodeItem( TREENAME, strRetName, "2분", 0, OFFSET_Y_SECONDLINE, util.ETreeItemTextType.COLOR_GRAY );
 */

//** 선준 Code 추가 Tree용 Node, NodeItem에 관한 코드 *******************************************************************************************************************************************************

/**
 *  트리 ROOT 노드 추가  
 *  [TreeName:노드 추가할 Tree 네임:string]   
 *  [NodeName:노드 네임:string]    
 *  [ParentName:추가할 노드의 상위 노드:string]  
 *  [offSetX:노드 x 위치:optional int]   
 *  [offSetY:노드 y 위치:optional int]
 */
function TreeInsertRootNode( string TreeName, string NodeName, string ParentName, optional int offSetX, optional int offSetY )
{
	//트리 노드 정보
	local XMLTreeNodeInfo infNode;
	
	infNode.strName = NodeName;	
	infNode.nOffSetX = offSetX;
	infNode.nOffSetY = offSetY;

	class'UIAPI_TREECTRL'.static.InsertNode( TreeName, ParentName, infNode );
}


/**
 * TreeInsertRootNode 와 같으나, 속도 개선을 위해. TreeHandle로 받아 처리 합니다.
 */

function TreeHandleInsertRootNode( TreeHandle m_UITree, string NodeName, string ParentName, optional int offSetX, optional int offSetY )
{
	//트리 노드 정보
	local XMLTreeNodeInfo infNode;
	
	infNode.strName = NodeName;	
	infNode.nOffSetX = offSetX;
	infNode.nOffSetY = offSetY;

	m_UITree.InsertNode ( ParentName, infNode );
	//class'UIAPI_TREECTRL'.static.InsertNode( TreeName, ParentName, infNode );
}

/**
 *  트리 Expand 버튼 노드 추가
 *  [TreeName:노드 추가할 Tree 네임:string]
 *  [NodeName:노드 네임:string]
 *  [ParentName:추가할 노드의 상위 노드:string]
 *  [nTexBtnWidth:Expand버튼 넓이:int]
 *  [nTexBtnHeight:Expand버튼 높이:int]
 *  [strTexBtnExpand:Tree열림버튼 텍스쳐:optional string]
 *  [strTexBtnExpand_Over:Tree열림버튼 오버 텍스쳐:optional string]
 *  [strTexBtnCollapse:Tree닫힘버튼 텍스쳐:optional string]
 *  [strTexBtnCollapse_Over:Tree열림버튼 오버 텍스쳐:optional string]
 *  [offSetX:노드 x 위치:optional int]   
 *  [offSetY:노드 y 위치:optional int]
 *  [bUseStrTexExpandedLeft : 선택하는 혀 optional bool ]
 */
function TreeInsertExpandBtnNode( string TreeName, string NodeName, string ParentName, optional int nTexBtnWidth, optional int nTexBtnHeight, 
									optional string strTexBtnExpand, optional string strTexBtnExpand_Over, optional string strTexBtnCollapse, optional string strTexBtnCollapse_Over,
									optional int offSetX, optional int offSetY, optional bool bUseStrTexExpandedLeft)
{
	//트리 노드 정보
	local XMLTreeNodeInfo infNode;

	if( nTexBtnWidth == 0 ) nTexBtnWidth = 15;
	if( nTexBtnHeight == 0 ) nTexBtnHeight = 15;
	if( strTexBtnExpand == "" ) strTexBtnExpand = "L2UI_CH3.QUESTWND.QuestWndPlusBtn";
	if( strTexBtnExpand_Over == "" ) strTexBtnExpand_Over = "L2UI_CH3.QUESTWND.QuestWndPlusBtn_over";
	if( strTexBtnCollapse == "" ) strTexBtnCollapse = "L2UI_CH3.QUESTWND.QuestWndMinusBtn";
	if( strTexBtnCollapse_Over == "" ) strTexBtnCollapse_Over = "L2UI_CH3.QUESTWND.QuestWndMinusBtn_over";

	infNode.strName = NodeName;
	infNode.bShowButton = 1;
	infNode.nTexBtnWidth = nTexBtnWidth;
	infNode.nTexBtnHeight = nTexBtnHeight;
	infNode.nOffSetX = offSetX;
	infNode.nOffSetY = offSetY;
	infNode.strTexBtnExpand = strTexBtnExpand;
	infNode.strTexBtnExpand_Over = strTexBtnExpand_Over;
	infNode.strTexBtnCollapse = strTexBtnCollapse;
	infNode.strTexBtnCollapse_Over = strTexBtnCollapse_Over;

	class'UIAPI_TREECTRL'.static.InsertNode( TreeName, ParentName, infNode );
}

/**
 * TreeInsertExpandBtnNode 와 같으나, 속도 개선을 위해 TreeHandle를 받아 사용 
 */
function TreeHandleInsertExpandBtnNode( TreeHandle m_UITree, string NodeName, string ParentName, optional int nTexBtnWidth, optional int nTexBtnHeight, 
									optional string strTexBtnExpand, optional string strTexBtnExpand_Over, optional string strTexBtnCollapse, optional string strTexBtnCollapse_Over,
									optional int offSetX, optional int offSetY, optional bool bUseStrTexExpandedLeft)
{
	//트리 노드 정보
	local XMLTreeNodeInfo infNode;

	if( nTexBtnWidth == 0 ) nTexBtnWidth = 15;
	if( nTexBtnHeight == 0 ) nTexBtnHeight = 15;
	if( strTexBtnExpand == "" ) strTexBtnExpand = "L2UI_CH3.QUESTWND.QuestWndPlusBtn";
	if( strTexBtnExpand_Over == "" ) strTexBtnExpand_Over = "L2UI_CH3.QUESTWND.QuestWndPlusBtn_over";
	if( strTexBtnCollapse == "" ) strTexBtnCollapse = "L2UI_CH3.QUESTWND.QuestWndMinusBtn";
	if( strTexBtnCollapse_Over == "" ) strTexBtnCollapse_Over = "L2UI_CH3.QUESTWND.QuestWndMinusBtn_over";

	infNode.strName = NodeName;
	infNode.bShowButton = 1;
	infNode.nTexBtnWidth = nTexBtnWidth;
	infNode.nTexBtnHeight = nTexBtnHeight;
	infNode.nOffSetX = offSetX;
	infNode.nOffSetY = offSetY;
	infNode.strTexBtnExpand = strTexBtnExpand;
	infNode.strTexBtnExpand_Over = strTexBtnExpand_Over;
	infNode.strTexBtnCollapse = strTexBtnCollapse;
	infNode.strTexBtnCollapse_Over = strTexBtnCollapse_Over;

	m_UITree.InsertNode( ParentName, infNode  );
}


/**
 *  트리 ITEM 노드 추가
 *  [TreeName:노드 추가할 Tree 네임:string]
 *  [NodeName:노드 네임:string]
 *  [ParentName:추가할 노드의 상위 노드:string]
 *  [nTexBtnWidth:Expand버튼 넓이:int]
 *  [nTexBtnHeight:Expand버튼 높이:int]
 *  [strTexBtnExpand:Tree열림버튼 텍스쳐:optional string]
 *  [strTexBtnExpand_Over:Tree열림버튼 오버 텍스쳐:optional string]
 *  [strTexBtnCollapse:Tree닫힘버튼 텍스쳐:optional string]
 *  [strTexBtnCollapse_Over:Tree열림버튼 오버 텍스쳐:optional string]
 *  [offSetX:노드 x 위치:optional int]   
 *  [offSetY:노드 y 위치:optional int]
 */
function string TreeInsertItemTooltipSimpleNode( string TreeName, string NodeName, string ParentName, 
									int nTexExpandedOffSetX, int nTexExpandedOffSetY, 
									int nTexExpandedHeight, int nTexExpandedRightWidth, 
									int nTexExpandedLeftUWidth, int nTexExpandedLeftUHeight,									
									optional string TooltipSimpleText, optional string strTexExpandedLeft, optional int offSetX, optional int offSetY )
{
	//트리 노드 정보
	local XMLTreeNodeInfo infNode;
	
	if( TooltipSimpleText != "" ) infNode.Tooltip = MakeTooltipSimpleText( TooltipSimpleText );
	if( strTexExpandedLeft == "" ) strTexExpandedLeft = "L2UI_CH3.etc.IconSelect2";

	infNode.strName = NodeName;
	infNode.nOffSetX = offSetX;
	infNode.nOffSetY = offSetY;
	infNode.bFollowCursor = true;
	//Expand되었을때의 BackTexture설정
	//스트레치로 그리기 때문에 ExpandedWidth는 없다. 끝에서 -2만큼 배경을 그린다.
	infNode.nTexExpandedOffSetX = nTexExpandedOffSetX;
	infNode.nTexExpandedOffSetY = nTexExpandedOffSetY;		
	infNode.nTexExpandedHeight = nTexExpandedHeight;		
	infNode.nTexExpandedRightWidth = nTexExpandedRightWidth;		
	infNode.nTexExpandedLeftUWidth = nTexExpandedLeftUWidth; 		
	infNode.nTexExpandedLeftUHeight = nTexExpandedLeftUHeight;
	infNode.strTexExpandedLeft = strTexExpandedLeft;

	return class'UIAPI_TREECTRL'.static.InsertNode( TreeName, ParentName, infNode );
}

function string TreeInsertItemTooltipNode( string TreeName, string NodeName, string ParentName, 
									int nTexExpandedOffSetX, int nTexExpandedOffSetY, 
									int nTexExpandedHeight, int nTexExpandedRightWidth, 
									int nTexExpandedLeftUWidth, int nTexExpandedLeftUHeight,									
									CustomTooltip TooltipText, optional string strTexExpandedLeft, optional int offSetX, optional int offSetY )
{
	//트리 노드 정보
	local XMLTreeNodeInfo infNode;	
	
	if( strTexExpandedLeft == "" ) strTexExpandedLeft = "L2UI_CH3.etc.IconSelect2";

	infNode.strName = NodeName;
	infNode.Tooltip = TooltipText;
	infNode.nOffSetX = offSetX;
	infNode.nOffSetY = offSetY;
	infNode.bFollowCursor = true;
	//Expand되었을때의 BackTexture설정
	//스트레치로 그리기 때문에 ExpandedWidth는 없다. 끝에서 -2만큼 배경을 그린다.
	infNode.nTexExpandedOffSetX = nTexExpandedOffSetX;
	infNode.nTexExpandedOffSetY = nTexExpandedOffSetY;		
	infNode.nTexExpandedHeight = nTexExpandedHeight;		
	infNode.nTexExpandedRightWidth = nTexExpandedRightWidth;		
	infNode.nTexExpandedLeftUWidth = nTexExpandedLeftUWidth; 		
	infNode.nTexExpandedLeftUHeight = nTexExpandedLeftUHeight;
	infNode.strTexExpandedLeft = strTexExpandedLeft;

	return class'UIAPI_TREECTRL'.static.InsertNode( TreeName, ParentName, infNode );
}

function string TreeInsertItemNode( string TreeName, string NodeName, string ParentName, optional bool bFollowCursor, optional int offSetX, optional int offSetY )
{
	//트리 노드 정보
	local XMLTreeNodeInfo infNode;

	infNode.strName = NodeName;
	//infNode.Tooltip = TooltipText;
	infNode.nOffSetX = offSetX;
	infNode.nOffSetY = offSetY;
	infNode.bFollowCursor = bFollowCursor;

	return class'UIAPI_TREECTRL'.static.InsertNode( TreeName, ParentName, infNode );
}

/**
 *  트리 노드에 Text 아이템 추가
 *  [TreeName:노드 추가할 Tree 네임]
 *  [NodeName:노드 네임]
 *  [ItemName:Text에 추가되 내용]
 *  [offSetX:Text x 위치]   
 *  [offSetY:Text y 위치]
 *  [E:Text 색상 ETreeItemTextType 값]
 *  [OneLine:t_bDrawOneLine 값]
 *  [bLineBreak:bLineBreak 값]
 */
function TreeInsertTextNodeItem( string TreeName, string NodeName, string ItemName, optional int offSetX, optional int offSetY, optional ETreeItemTextType E, 
									optional bool OneLine, optional bool bLineBreak, optional int reserved )
{
	//트리 노드아이템 정보
	local XMLTreeNodeItemInfo infNodeItem;

	infNodeItem.eType = XTNITEM_TEXT;
	infNodeItem.t_strText = ItemName;
	infNodeItem.t_bDrawOneLine = OneLine;
	infNodeItem.bLineBreak = bLineBreak;
	infNodeItem.nOffSetX = offSetX;
	infNodeItem.nOffSetY = offSetY;
	
	infNodeItem = setTreeTextColor( E, infNodeItem );

	if( reserved != 0 )
	{
		infNodeItem.nReserved = reserved;
	}

	class'UIAPI_TREECTRL'.static.InsertNodeItem( TreeName, NodeName, infNodeItem );
}

/**
 *TreeInsertTextNodeItem 와 동일 하지만 속도 개선을 위해 TreeName 대신 TreeHandle을 받음
 */
function TreeHandleInsertTextNodeItem( TreeHandle m_UITree, string NodeName, string ItemName, optional int offSetX, optional int offSetY, optional ETreeItemTextType E, 
									optional bool OneLine, optional bool bLineBreak, optional int reserved )
{
	//트리 노드아이템 정보
	local XMLTreeNodeItemInfo infNodeItem;

	infNodeItem.eType = XTNITEM_TEXT;
	infNodeItem.t_strText = ItemName;
	infNodeItem.t_bDrawOneLine = OneLine;
	infNodeItem.bLineBreak = bLineBreak;
	infNodeItem.nOffSetX = offSetX;
	infNodeItem.nOffSetY = offSetY;
	
	infNodeItem = setTreeTextColor( E, infNodeItem );

	if( reserved != 0 )
	{
		infNodeItem.nReserved = reserved;
	}

	m_UITree.InsertNodeItem(NodeName, infNodeItem);	
}

/**
 *  트리 노드에 Text 아이템 추가
 *  [TreeName:노드 추가할 Tree 네임]
 *  [NodeName:노드 네임]
 *  [ItemName:Text에 추가되 내용]
 *  [offSetX:Text x 위치]   
 *  [offSetY:Text y 위치]
 *  [E:Text 색상 ETreeItemTextType 값]
 *  [OneLine:t_bDrawOneLine 값]
 *  [bLineBreak:bLineBreak 값]
 */
function TreeInsertTextMultiNodeItem( string TreeName, string NodeName, string ItemName, optional int offSetX, optional int offSetY, 
										optional int MaxHeight, optional ETreeItemTextType E, optional bool bLineBreak, optional int reserved, optional int reserved2 )
{
	//트리 노드아이템 정보
	local XMLTreeNodeItemInfo infNodeItem;

	if( MaxHeight == 0 ) MaxHeight = 38;

	infNodeItem.eType = XTNITEM_TEXT;
	infNodeItem.t_strText = ItemName;
	infNodeItem.t_bDrawOneLine = false;
	infNodeItem.bLineBreak = bLineBreak;
	infNodeItem.nOffSetX = offSetX;
	infNodeItem.nOffSetY = offSetY;
	infNodeItem.t_nMaxHeight = MaxHeight;
	infNodeItem.t_vAlign = TVA_Middle;
	
	infNodeItem = setTreeTextColor( E, infNodeItem );

	if( reserved != 0 )
	{
		infNodeItem.nReserved = reserved;
	}
	
	infNodeItem.nReserved2 = 0;
	if( reserved2 > 0 )
	{
		infNodeItem.nReserved2 = reserved2;
	}

	class'UIAPI_TREECTRL'.static.InsertNodeItem( TreeName, NodeName, infNodeItem );
}


/**
 *  트리 노드에 Text 아이템의 글씨 색상
 */
function XMLTreeNodeItemInfo setTreeTextColor( ETreeItemTextType E, XMLTreeNodeItemInfo infNodeItem )
{
	switch( E )
	{
		case ETreeItemTextType.COLOR_DEFAULT:
			infNodeItem.t_color.R = 255;
			infNodeItem.t_color.G = 255;
			infNodeItem.t_color.B = 255;
			infNodeItem.t_color.A = 255;
			break;
		
		case ETreeItemTextType.COLOR_GRAY:
			infNodeItem.t_color.R = 163;
			infNodeItem.t_color.G = 163;
			infNodeItem.t_color.B = 163;
			infNodeItem.t_color.A = 255;
			break;

		case ETreeItemTextType.COLOR_GOLD:
			infNodeItem.t_color.R = 176;
			infNodeItem.t_color.G = 155;
			infNodeItem.t_color.B = 121;
			infNodeItem.t_color.A = 255;
			break;
		case ETreeItemTextType.COLOR_RED:
			infNodeItem.t_color.R = 250;
			infNodeItem.t_color.G = 50;
			infNodeItem.t_color.B = 0;
			infNodeItem.t_color.A = 255;
			break;
		case ETreeItemTextType.COLOR_YELLOW:
			infNodeItem.t_color.R = 240;
			infNodeItem.t_color.G = 214;
			infNodeItem.t_color.B = 54;
			infNodeItem.t_color.A = 255;
			break;
		case ETreeItemTextType.COLOR_DESC:
			infNodeItem.t_color.R = 175;
			infNodeItem.t_color.G = 185;
			infNodeItem.t_color.B = 205;
			infNodeItem.t_color.A = 255;
			break;

		case ETreeItemTextType.COLOR_BLUE:
			infNodeItem.t_color.R = 102;
			infNodeItem.t_color.G = 150;
			infNodeItem.t_color.B = 253;
			infNodeItem.t_color.A = 255;
			break;

		case ETreeItemTextType.COLOR_BRIGHT_BLUE:
			infNodeItem.t_color.R = 85;
			infNodeItem.t_color.G = 170;
			infNodeItem.t_color.B = 255;
			infNodeItem.t_color.A = 255;
			break;

		case ETreeItemTextType.TOKEN0:
			infNodeItem.t_color.R = 211;
			infNodeItem.t_color.G = 192;
			infNodeItem.t_color.B = 82;
			infNodeItem.t_color.A = 255;
			break;		
		case ETreeItemTextType.TOKEN1:
			infNodeItem.t_color.R = 170;
			infNodeItem.t_color.G = 152;
			infNodeItem.t_color.B = 120;
			infNodeItem.t_color.A = 255;
			break;		
		case ETreeItemTextType.TOKEN2:
			infNodeItem.t_color.R = 168;
			infNodeItem.t_color.G = 103;
			infNodeItem.t_color.B = 53;
			infNodeItem.t_color.A = 255;
			break;		
		case ETreeItemTextType.TOKEN3:
			infNodeItem.t_color.R = 175;
			infNodeItem.t_color.G = 42;
			infNodeItem.t_color.B = 39;
			infNodeItem.t_color.A = 255;
			break;

		case ETreeItemTextType.YELLOW03:
			infNodeItem.t_color.R = 255;
			infNodeItem.t_color.G = 204;
			infNodeItem.t_color.B = 0;
			infNodeItem.t_color.A = 255;
			break;
	}
	return infNodeItem;
}

/**
 *  트리 노드에 Text 아이템 추가
 *  [TreeName:노드 추가할 Tree 네임:string]
 *  [NodeName:노드 네임:string]
 *  [TextureName:텍스쳐 이름:string]
 *  [TextureWidth:텍스쳐 넓이:int]
 *  [TextureHeight:텍스쳐 높이:int]
 *  [offSetX:Text x 위치]   
 *  [offSetY:Text y 위치]
 *  [OneLine:t_bDrawOneLine 값]
 *  [bLineBreak:bLineBreak 값]
 *  [TextureUHeight:TextureUHeight 값 ??? ]
 */
function TreeInsertTextureNodeItem( string TreeName, string NodeName, string TextureName, int TextureWidth, int TextureHeight, optional int offSetX, optional int offSetY, 
										optional bool OneLine, optional bool bLineBreak, optional int TextureUHeight )
{
	//트리 노드아이템 정보
	local XMLTreeNodeItemInfo infNodeItem;

	infNodeItem.eType = XTNITEM_TEXTURE;
	infNodeItem.t_bDrawOneLine = OneLine;
	infNodeItem.bLineBreak = bLineBreak;
	infNodeItem.nOffSetX = offSetX;
	infNodeItem.nOffSetY = offSetY;
	infNodeItem.u_nTextureUHeight = TextureUHeight;
	infNodeItem.u_nTextureWidth = TextureWidth;
	infNodeItem.u_nTextureHeight = TextureHeight;
	infNodeItem.u_strTexture = TextureName;

	class'UIAPI_TREECTRL'.static.InsertNodeItem( TreeName, NodeName, infNodeItem );
} 

/**
 * TreeInsertTextureNodeItem 와 동일 하지만 속도 개선을 위해 TreeHandle 를 받음 
 */
function TreeHandleInsertTextureNodeItem( TreeHandle m_UITree, string NodeName, string TextureName, int TextureWidth, int TextureHeight, optional int offSetX, optional int offSetY, 
										optional bool OneLine, optional bool bLineBreak, optional int TextureUHeight )
{
	//트리 노드아이템 정보
	local XMLTreeNodeItemInfo infNodeItem;

	infNodeItem.eType = XTNITEM_TEXTURE;
	infNodeItem.t_bDrawOneLine = OneLine;
	infNodeItem.bLineBreak = bLineBreak;
	infNodeItem.nOffSetX = offSetX;
	infNodeItem.nOffSetY = offSetY;
	infNodeItem.u_nTextureUHeight = TextureUHeight;
	infNodeItem.u_nTextureWidth = TextureWidth;
	infNodeItem.u_nTextureHeight = TextureHeight;
	infNodeItem.u_strTexture = TextureName;

	m_UITree.InsertNodeItem( NodeName, infNodeItem );
} 

/**
 *  트리 노드에 Blank 아이템 추가 Insert Node Item - Blank::레시피 Tree에서 사용.
 *  [TreeName:노드 추가할 Tree 네임]
 *  [NodeName:노드 네임]
 */
function TreeInsertBlankNodeItem( string TreeName, string NodeName )
{
	//트리 노드아이템 정보
	local XMLTreeNodeItemInfo infNodeItem;

	infNodeItem.eType = XTNITEM_BLANK;
	infNodeItem.bStopMouseFocus = true;
	infNodeItem.b_nHeight = 4;
	class'UIAPI_TREECTRL'.static.InsertNodeItem( TreeName, NodeName, infNodeItem );
}


function TreeClear( string str )
{
	class'UIAPI_TREECTRL'.static.Clear( str );
}

//** 선준 Code 추가 Tree용 Node, NodeItem에 관한 코드 END****************************************************************************************************************************************************






//** 선준 Code 추가 ToolTip에 관한 코드 *********************************************************************************************************************************************************************

/**
 *  툴팁 값 셋팅
 *  [T:셋팅 될 툴팁:CustomTooltip]
 */
function setCustomTooltip( CustomTooltip T )
{
	TooltipText = T;
}

function CustomTooltip getCustomTooltip()
{
	return TooltipText;
}

function ToopTipMinWidth( int width )
{
	TooltipText.MinimumWidth = width;
}

function ToopTipInsertText( string Text, optional bool OneLine, optional bool bLineBreak,optional ETooltipTextType E, optional int offSetX, optional int offSetY )
{
	if( Len( Text ) == 0 ) return;

	StartItem();
	TooltipInfo.eType = DIT_TEXT;
	TooltipInfo.t_bDrawOneLine = OneLine;
	TooltipInfo.bLineBreak = bLineBreak;
	TooltipInfo.t_strText = Text;
	TooltipInfo.nOffSetX = offSetX;
	TooltipInfo.nOffSetY = offSetY;
	TooltipInfo = setToopTipTextColor( E, TooltipInfo );
	EndItem();
}

// title : 내용   등 의 툴팁을 만드는 함수 추가
function ToopTipInsertTitleContents( string title, string Text, int r, int g, int b, optional bool OneLine, optional bool bLineBreak, optional bool iamFirst, optional int offSetX, optional int offSetY )
{
	if( Len( Text ) == 0 ) return;
	
	if(title != "")
	{
		StartItem();
		TooltipInfo.eType = DIT_TEXT;
		TooltipInfo.t_bDrawOneLine = true;
		TooltipInfo.bLineBreak = true;
		TooltipInfo.t_color.R = 163;
		TooltipInfo.t_color.G = 163;
		TooltipInfo.t_color.B = 163;
		TooltipInfo.t_color.A = 255;
		if(!iamFirst)
			TooltipInfo.nOffSetY = 6;
		TooltipInfo.t_strText = title;		
		EndItem();
	}

	if(Text != "")
	{
		if(title != "")
		{
			StartItem();
			TooltipInfo.eType = DIT_TEXT;
			TooltipInfo.t_bDrawOneLine = true;			
			TooltipInfo.t_color.R = 163;
			TooltipInfo.t_color.G = 163;
			TooltipInfo.t_color.B = 163;
			TooltipInfo.t_color.A = 255;
			if(!iamFirst)
				TooltipInfo.nOffSetY = 6;
			TooltipInfo.t_strText = " : ";
			EndItem();

		}
		StartItem();
		TooltipInfo.eType = DIT_TEXT;
		TooltipInfo.t_bDrawOneLine = true;
		
		if(title == "")
			TooltipInfo.bLineBreak = true;

		TooltipInfo.t_color.R = r;
		TooltipInfo.t_color.G = g;
		TooltipInfo.t_color.B = b;
		TooltipInfo.t_color.A = 255;
		
		TooltipInfo.t_strText = Text;		
		if(!iamFirst)
			TooltipInfo.nOffSetY = 6;
		
		EndItem();

	}
}


/**
 *  툴팁에 Text 아이템의 글씨 색상
 */
function DrawItemInfo setToopTipTextColor( ETooltipTextType E, DrawItemInfo info )
{
	switch( E )
	{
		case ETooltipTextType.COLOR_DEFAULT:
			info.t_color.R = 255;
			info.t_color.G = 255;
			info.t_color.B = 255;
			info.t_color.A = 255;
			break;
		
		case ETooltipTextType.COLOR_GRAY:
			info.t_color.R = 163;
			info.t_color.G = 163;
			info.t_color.B = 163;
			info.t_color.A = 255;
			break;

		case ETooltipTextType.COLOR_GOLD:
			info.t_color.R = 176;
			info.t_color.G = 155;
			info.t_color.B = 121;
			info.t_color.A = 255;
			break;		

		case ETooltipTextType.COLOR_YELLOW:
			info.t_color.R = 240;
			info.t_color.G = 214;
			info.t_color.B = 54;
			info.t_color.A = 255;
			break;

		case ETooltipTextType.COLOR_YELLOW03:
			info.t_color.R = 255;
			info.t_color.G = 204;
			info.t_color.B = 0;
			info.t_color.A = 255;
			break;
		case ETooltipTextType.COLOR_RED:
			info.t_color.R = 250;
			info.t_color.G = 50;
			info.t_color.B = 0;
			info.t_color.A = 255;
			break;
		case ETooltipTextType.COLOR_BLUE:
			info.t_color.R = 100;
			info.t_color.G = 100;
			info.t_color.B = 250;
			info.t_color.A = 255;
			break;
	}
	return info;
}

function TwoWordCombineColon( string word1, string word2, optional ETooltipTextType E1, optional ETooltipTextType E2, optional bool bLineBreak, optional int offSetX, optional int offSetY )
{
	ToopTipInsertText( word1, false, bLineBreak, E1, offSetX, offSetY );
	ToopTipInsertText( " : ", false, false, ETooltipTextType.COLOR_GRAY, offSetX, offSetY );
	ToopTipInsertText( word2, false, false, E2, offSetX, offSetY );

}

function ToopTipInsertTexture( string Texture, optional bool OneLine, optional bool bLineBreak, optional int offSetX, optional int offSetY )
{
	StartItem();
	TooltipInfo.eType = DIT_TEXTURE;
	TooltipInfo.t_bDrawOneLine = OneLine;
	TooltipInfo.bLineBreak = bLineBreak;
	TooltipInfo.u_nTextureWidth = 16;
	TooltipInfo.u_nTextureHeight = 16;
	TooltipInfo.nOffSetX = offSetX;
	TooltipInfo.nOffSetY = offSetY;
	TooltipInfo.u_nTextureUWidth = 32;
	TooltipInfo.u_nTextureUHeight = 32;

	TooltipInfo.u_strTexture = Texture;
	EndItem();
}

//빈공간의 TooltipItem을 추가한다.
function TooltipInsertItemBlank( int Height )
{
	StartItem();
	TooltipInfo.eType = DIT_BLANK;
	TooltipInfo.b_nHeight = Height;
	EndItem();
}

//빈공간의 TooltipItem을 추가한다.
function TooltipInsertItemLine()
{
	StartItem();
	TooltipInfo.eType = DIT_SPLITLINE;
	TooltipInfo.u_nTextureWidth = TooltipText.MinimumWidth;			
	TooltipInfo.u_nTextureHeight = 1;
	TooltipInfo.u_strTexture ="L2ui_ch3.tooltip_line";
	EndItem();
}

function StartItem()
{
	local DrawItemInfo infoClear;
	TooltipInfo = infoClear;
}

function EndItem()
{
	TooltipText.DrawList.Length = TooltipText.DrawList.Length + 1;
	TooltipText.DrawList[ TooltipText.DrawList.Length - 1 ] = TooltipInfo;
}

//**  선준 Code 추가 ToolTip에 관한 코드 END*****************************************************************************************************************************************************************



/**
 * 시간 --> XX : XX 으로 만듬.
 * 스케일 폼에서 사용하려 했으나 지금은 안됨..;;
 */
function String TimeNumberToString( int time )
{
	local int Min;
	local int Sec;
	
	local string strTime;
	local string SecString;

	Min = time / 60;
	Sec = time % 60;

	SecString = string( Sec );

	if(Sec < 10)
	{
		SecString = "0" $ string( Sec );
	}

	if( time > 60 )
	{
		strTime = "0" $string( Min ) $ ":" $ SecString;
	}
	else
	{
		strTime = "00:" $ SecString;
	}

	return strTime;
}

/**
 * 시간 --> XX시 XX분 으로 만듬.
 */
function String TimeNumberToHangulHourMin( int time )
{
	local int Hour;
	local int Min;
	local int Sec;	

	local string strMin;

	Min = time / 60;
	Hour = Min / 60;
	Min = Min % 60;
	Sec = time % 60;	

	strMin = string(Min);

	if( Min < 10 )
	{
		strMin = "0"$string(Min);
	}

	return MakeFullSystemMsg( GetSystemMessage(3304), string(Hour), strMin );
}


/**
 * Float 시간 + 초 만들어줌.
 */
function string MakeTimeString( float Time1, optional float Time2 )
{
	local int i;
	local float Time;
	local string strTime;
	local array<string>	arrSplit;
	
	if( Time2 != 0 )
	{
		Time = Time1+ Time2;		
	}
	else
	{
		Time = Time1;
	}

	strTime = string( Time );

	for( i = 0 ; i < Len(strTime) ; i++ )
	{
		if( Right( strTime, 1 ) == "0" )
		{
			strTime = Left( strTime, Len(strTime) - 1 );
			
		}
		else if( Right( strTime, 1 ) == "." )
		{
			break;
		}
	}		
	
	Split( strTime, ".", arrSplit);

	if( Len( arrSplit[1]) == 0 )
	{
		return arrSplit[0] $ GetSystemString(2001);
	}

	return strTime $ GetSystemString(2001);
}



function test(int a, int b, optional int x, optional string str)
{
	if (x == 0)
	{
		Debug("영이래!");
	}

	if (str =="")
	{
		Debug("스트링 꽝!");
	}
	
}

function onCallUCFunction ( string functionName, string param ) 
{
	//Debug( "onCallUCFunction L2Util" @ functionName @ param) ;
	switch ( functionName ) 
	{
		case "handleDialogBox":
			handleDialogBox( param );
		break;
		case "BrintToFront" :			
			class'UIAPI_WINDOW'.static.BringToFront ( param );
		break;
		case "MoveTo" :
			handleMoveTo ( param ) ;
		break;		
	}
}

function handleMoveTo ( string param )
{	
	local string windowName ;
	local int x, y, targetOffsetX, targetOffsetY, anchorPoint ;
	local Rect tempRect ;	

	parseString ( param, "windowName", windowName );
	if ( !class'UIAPI_WINDOW'.static.isShowWindow ( windowName ) ) return;	
	
	parseInt ( param , "x", x) ;
	parseInt ( param , "y", y) ;
	parseInt ( param , "anchorPoint", anchorPoint);

	tempRect = GetWindowHandle(windowName).GetRect();
	//tempRect.nX;
	//tempRect.nY;
	//tempRect.nWidth;
	//tempRect.nHeight;
	targetOffsetX = 0 ;
	targetOffsetY = 0 ;
	switch ( anchorPoint ) 
	{
		case EAnchorPointType.ANCHORPOINT_None :
			break;
		case EAnchorPointType.ANCHORPOINT_TopLeft:
			break;
		case EAnchorPointType.ANCHORPOINT_TopCenter:
			targetOffsetX = - tempRect.nWidth /2;
			break;
		case EAnchorPointType.ANCHORPOINT_TopRight:
			targetOffsetX = - tempRect.nWidth ;
			break;
		case EAnchorPointType.ANCHORPOINT_CenterLeft:			
			targetOffsetY = - tempRect.nHeight /2 ;
			break;
		case EAnchorPointType.ANCHORPOINT_CenterCenter:
			targetOffsetX = - tempRect.nWidth /2;
			targetOffsetY = - tempRect.nHeight /2 ;
			break;
		case EAnchorPointType.ANCHORPOINT_CenterRight:
			targetOffsetX = - tempRect.nWidth ;
			targetOffsetY = - tempRect.nHeight /2 ;
			break;
		case EAnchorPointType.ANCHORPOINT_BottomLeft:			
			targetOffsetY = - tempRect.nHeight;
			break;
		case EAnchorPointType.ANCHORPOINT_BottomCenter:
			targetOffsetX = - tempRect.nWidth /2 ;
			targetOffsetY = - tempRect.nHeight;
			break;
		case EAnchorPointType.ANCHORPOINT_BottomRight:
			targetOffsetX = - tempRect.nWidth ;
			targetOffsetY = - tempRect.nHeight;
			break;
	}
	GetWindowHandle( windowName).MoveTo(  x + targetOffsetX , y + targetOffsetY);
	//Debug ( x + targetOffsetX @  y + targetOffsetY  @ anchorPoint  ) ;
}


///////////////////////////////////////////////
// 다이얼로그 박스 유틸
///////////////////////////////////////////////

function handleDialogBox(string param)
{
	local string functionName;

	parseString (param, "functionName", functionName );

	//Debug ( "handleDialogBox" @ functionName @ param ) ;
	switch ( functionName ) 
	{
		case "DialogShow":
			handleDialogShow( param ) ;
		break;
		
		case "DialogSetButtonName":
			handleDialogSetButtonName( param );
		break;
		case "DialogSetButtonWidthSize":
			handleDialogSetButtonWidthSize( param ) ;
		break;
		case "DialogShowWithResize":
			handleDialogShowWithResize( param ) ;
		break;		
		case "DialogHide" :
			DialogHide();
		break;
		case "DialogSetDefaultOK":
			DialogSetDefaultOK();
		break;
		case "DialogSetDefaultCancle":
			DialogSetDefaultCancle();
		break;
		case "DialogSetID":
			handleDialogSetID( param );
		break;
		case "DialogSetEditType":
			handleDialogSetEditType( param ) ;
		break;
		case "DialogSetString":
			handleDialogSetString( param ) ;
		break;
		case "DialogGetReservedInt2":
			handleDialogGetReservedInt2() ;
		break;
		case "DialogSetParamInt64":
			handleDialogSetParamInt64( param ) ;
		break;
		case "DialogSetReservedInt":
			handleDialogSetReservedInt( param ) ;
			break;
		case "DialogSetReservedInt2":
			handleDialogSetReservedInt2( param ) ;
			break;
		case "DialogSetReservedInt3":
			handleDialogSetReservedInt3( param ) ;
			break;
		case "DialogSetEditBoxMaxLength":
			handleDialogSetEditBoxMaxLength( param );
			break;
		case "DialogSetIconTexture" :
			handleDialogSetIconTexture ( param );
			break;
		/*case "DialogSetModal":
			handleDialogModaType( param ) ;
			break;

*/
		case "DialogSetCancelD" :
			handleDialogSetCancelD( param ) ;
			break;
	}
}

function handleDialogSetCancelD(string param)
{
	local int targetCancelDialogID;
	parseInt ( param,   "targetCancelDialogID", targetCancelDialogID);
	DialogSetCancelD ( targetCancelDialogID );
}

/*
function handleDialogModaType (string param ) 
{
	local DialogBox script ;
	local int isModal;

	parseInt ( param , "isModal", isModal );
	script = DialogBox ( GetScript ( "DialogBox" )) ;
	script.m_dialogHandle.SetModal ( bool ( isModal) );
}*/

function handleDialogSetIconTexture ( string param ) 
{
	local string iconTextureStr;
	parseString (param, "iconTextureStr", iconTextureStr) ;
	DialogSetIconTexture( iconTextureStr );
}

function handleDialogSetEditBoxMaxLength( string param ) 
{
	local int maxLength;
	parseInt (param, "maxLength", maxLength) ;
	DialogSetEditBoxMaxLength( maxLength );
}

//int64는 받을 수 있는 api가 없어서 스트링으로 전환 후 가져감.
function handleDialogGetReservedInt2( )
{		
	m_reservedInt2 = string ( DialogGetReservedInt2() );	
}

function handleDialogSetReservedInt3( string param ) 
{
	local int value;
	parseInt (param, "value", value) ;
	DialogSetReservedInt3( value ) ;
}

function handleDialogSetReservedInt2( string param ) 
{
	local INT64 value;
	parseInt64 (param, "value", value);
	DialogSetReservedInt2( value ) ;	
}

function handleDialogSetReservedInt( string param ) 
{
	local int value;
	parseInt (param, "value", value);
	DialogSetReservedInt( value ) ;
}

function handleDialogSetParamInt64( string param ) 
{
	local INT64 value;
	parseINT64(param, "param", value  );
	DialogSetParamInt64( value ) ;
}

function handleDialogSetString( string param )
{
	local string strInput;
	parseString(param, "strInput", strInput  );
	DialogSetString( strInput ) ;
}

function handleDialogSetEditType ( string param ) 
{
	local string strType;
	parseString(param, "strType", strType  );
	DialogSetEditType( strType ) ;
}

function handleDialogSetID( string param )
{
	local int id;	
	parseInt(param, "id", id  );
	DialogSetID( id );
}

function handleDialogSetButtonWidthSize ( string param ) 
{
	local int indexOK;
	local int indexCancel;
	parseInt(param, "indexOK", indexOK  );
	parseInt(param, "indexCancel", indexCancel  );
	
	DialogSetButtonWidthSize( indexOK, indexCancel );
}


function handleDialogSetButtonName ( string param ) 
{
	local int indexOK;
	local int indexCancel;
	parseInt(param, "indexOK", indexOK  );
	parseInt(param, "indexCancel", indexCancel  );	
	DialogSetButtonName( indexOK, indexCancel );
}

function handleDialogShowWithResize ( string param )
{		
	local int modalType;
	local int dialogType;
	local string strMessage;	
	local int changeWidth;
	local int changeHeight;
	local string strControlName;	

	parseInt(param, "modalType", modalType  );
	parseInt(param, "dialogType", dialogType  );
	parseString(param, "strMessage", strMessage  );	
	parseInt(param, "changeWidth", changeWidth  );
	parseInt(param, "changeHeight", changeHeight  );
	parseString(param, "strControlName", strControlName  );

	DialogShowWithResize( EDialogModalType(modalType), EDialogType(dialogType), strMessage, changeWidth, changeHeight, strControlName);
}

function handleDialogShow ( string param )
{		
	local int modalType;
	local int dialogType;
	local string strMessage;
	local string strControlName;
	local int dialogWeight;
	local int dialogHeight;
	local int  UseHtml;
	local string customIconTexture;

	parseInt(param, "modalType", modalType  );
	parseInt(param, "dialogType", dialogType  );
	parseString(param, "strMessage", strMessage  );
	parseString(param, "strControlName", strControlName  );
	parseInt(param, "dialogWeight", dialogWeight  );
	parseInt(param, "dialogHeight", dialogHeight  );
	parseInt(param, "bUseHtml", UseHtml  );
	parseString(param, "customIconTexture", customIconTexture  );

	DialogShow( EDialogModalType(modalType), EDialogType(dialogType), strMessage, strControlName, dialogWeight, dialogHeight, bool( UseHtml), customIconTexture);
}




////////////////////////////////////////////
// 리스트 컨트롤 유틸
////////////////////////////////////////////

/**
 *  컨트롤 리스트에서 이름을 기준으로 검색하여 해당 인덱스를 리턴
 *  첫번째 헤더가 대부분 "이름" 이라 만든 유틸 -_-;
 **/ 
function int ctrlListSearchByName (ListCtrlHandle listCtrl, string name)
{
	// parse var
	local LVDataRecord record;
	local int i, nReturn;

	nReturn = -1;

	for (i = 0; i < listCtrl.GetRecordCount(); i++)
	{
		listCtrl.GetRec(i, record);
		if (record.LVDataList[0].szData == name)
		{
			nReturn = i;
			break;
		}
	}
	return nReturn;
}

/**
 *  현재 또는 이전에 선택되었던 친구 리스트의 값을 기준으로 Record 값을 리턴한다.
 **/
function LVDataRecord getListSelectedRecord(ListCtrlHandle list, int index)
{	
	local LVDataRecord record;

	list.SetSelectedIndex(index, true);
	list.GetRec(index, record);

	return record;
}

/**
 *  int 형 배열 셔플 함수 
 * ex)
  	local Array<int> testArr; 
 	local int i;

	testArr[0] = 0;
	testArr[1] = 1;
	testArr[2] = 2;
	testArr[3] = 3;
	testArr[4] = 4;
	testArr[5] = 5;
	testArr[6] = 6;
	testArr[7] = 7;
	testArr[8] = 8;
	testArr[9] = 9;
	util.arrayShuffleInt(testArr);
	for(i = 0; i < 10; i++) Debug("testArr: " $ testArr[i]);
 **/
function arrayShuffleInt(out array<int> tempArray)
{
	local int i, ran, tempArrayLen;
	local array<int> changeArray;

	changeArray = tempArray;

	tempArrayLen = tempArray.Length;
	tempArray.Remove(0, tempArray.Length);

	for (i = 0; i < tempArrayLen; i++)
	{
		ran = rand(changeArray.Length);
		
		tempArray[i] = changeArray[ran];
		changeArray.Remove(ran, 1);
	}
}

/**
 * SEC 초를 넣으면 시 분 , 1시간 미만은 %분 
 * 같은 형식으로 스트링을 리턴한다.
 * 2시간 50분 ,  1시간 ,  48분
 * getTimeStringBySec(5000, true); --> "1시간"
 * getTimeStringBySec(5000, true); --> "1시간"
 * getTimeStringBySec(100 , true); --> "1시간 미만"
 * getTimeStringBySec(5000, true , true); --> "1시간 23분" 
 * getTimeStringBySec( 500, true , true); --> " 8분" 
 * getTimeStringBySec(5000, false, true); --> "83분"  
 **/
function string getTimeStringBySec(int sec, optional bool hourFlag, optional bool minFlag)
{
	local int timeTemp;
	local string returnStr;

	returnStr = "";
	timeTemp = ((sec / 60) / 60);
	
	if (timeTemp > 0)
	{		
		// 시 분 , 시 ,  분  타입으로 나오는 것 세팅 
		if (hourFlag && minFlag) returnStr = MakeFullSystemMsg(GetSystemMessage(3304), string(timeTemp), string(int((sec / 60) % 60)));		
		else if (hourFlag && minFlag == false) returnStr = MakeFullSystemMsg(GetSystemMessage(3406), string(timeTemp));
		else if (hourFlag == false && minFlag) returnStr = MakeFullSystemMsg(GetSystemMessage(3390), string(timeTemp));
	}
	else 
	{
		// 시간만 나오는 거라면..
		if (hourFlag && minFlag == false) 
		{
			// 1시간 미만 
			if (sec <= 0)
			{
				returnStr = MakeFullSystemMsg(GetSystemMessage(3407 ), "0");
			}
			else
			{
				returnStr = MakeFullSystemMsg(GetSystemMessage(3407 ), "1");
			}
		}
		else 
		{
			// 한 시간 미만이면..  분으로 나온다.
			// 분 계산 

			timeTemp = (sec / 60);
			// 분이 0이 나온 경우 0보다 작
			if (timeTemp <= 0) timeTemp = 1;				
			returnStr = MakeFullSystemMsg( GetSystemMessage(3390), string(timeTemp));
		}
	}

	return returnStr;
	 
}

/**
 *  시스템 스트링 번호를 실제 매칭 되는 문자로 넣는다.
 *  
 *  local array<string>	titleNameArray;
 *  arraySystemStringNumToString("144,145", titleNameArray);
 *  --> ["전체", "도움말"] 배열이 채워 진다.
 **/
function setSystemStringArrayByNumStr(string systemStringNum, out array<string> targetArray)
{
	local int i;
	local array<string> tempArray;

	Split(systemStringNum, ",", tempArray);
	
	targetArray.Remove(0, targetArray.Length);

	for (i = 0; i < tempArray.Length; i++)
	{
		targetArray[i] = GetSystemString(int(tempArray[i]));
	}
}


/**  무급, D, C ... 등급의 스트링을 리턴한다. */
function string getItemGradeSystemString(int nCrystalType)
{
	local string returnStr;

	switch(nCrystalType)
	{
		case 0  : returnStr = GetSystemString(2622); break; // 무급
		case 1  : returnStr = GetSystemString(2613); break; // D
		case 2  : returnStr = GetSystemString(2614); break; // C
		case 3  : returnStr = GetSystemString(2615); break; // B
		case 4  : returnStr = GetSystemString(2616); break; // A
		case 5  : returnStr = GetSystemString(2617); break; // S
		case 6  : returnStr = GetSystemString(2682); break; // s80
		case 7  : returnStr = GetSystemString(2683); break; // s84
		case 8  : returnStr = GetSystemString(2618); break; // R
		case 9  : returnStr = GetSystemString(2619); break; // R95
		case 10 : returnStr = GetSystemString(2620); break; // R99
	    default : returnStr = "";
	}

	return returnStr;
}


/**
 * 
 *  발터스 기사단 성장 구간 체크 후 창을 닫는다. 
 *  공통적으로 onShow 에 넣어 준다.
 *  
 **/
function bool checkIsPrologueGrowType ( string windowName ) 
{	
	if ( getIsPrologueGrowType() ) 
	{
		getInstanceL2Util().showGfxScreenMessage( GetSystemMessage(4533));
		class'UIAPI_WINDOW'.static.HideWindow( getCurrentWindowName( windowName ));
		return true;
	}
	return false;
}

/**
 * 
 *  발터스 기사단 성장 구간 체크 
 *  현재 클래스 ID로 체크 합니다. 
 *  EV_ChangedSubjob 이벤트 때 바로 실행 하면 맞지 않습니다. 해당 param CurrentSubjobClassID를 파싱 해서 사용 해야 합니다.
 *  아레나에서는 해당 클래스가 사용 되지만, 발터스 기사단 구분이 없습니다.
 *  라이브에서만 체크 되도록 작업했습니다.
 *  
 **/ 
function bool getIsPrologueGrowType ( optional int CurrentSubjobClassID) 
{
	local userInfo myUserInfo ;	
	local bool isPrologueGrowType;

	if ( CurrentSubjobClassID > 0 ) 	
		isPrologueGrowType = class'UIDATA_USER'.static.IsPrologueGrowType ( CurrentSubjobClassID ) ;
	else if ( GetPlayerInfo  ( myUserInfo ) ) 
		isPrologueGrowType = class'UIDATA_USER'.static.IsPrologueGrowType ( myUserInfo.nSubClass ) ;
	else return false;
	
	return ( isPrologueGrowType && getInstanceUIData().getIsLiveServer() ) ;
}



/**
 * 
 *  currentWindowName 현재 지정한 윈도우가 아닌 아이템 거래 교환 관계된 윈도우는 모두 닫는다. 
 *  
 *  exceptionWindowNameWithComma : "RefineryWnd,PrivateShopWnd"  <- 이런식으로 스트링을 넣는다 
 *  
 *  
 **/
function ItemRelationWindowHide(string currentWindowName, optional string exceptionWindowNameWithComma)
{

	local int i, len;	
	len = ItemRelationWindowArrayStr.Length;
	// Debug("현재 윈도우 " @ currentWindowName);



	for(i = 0; i < len; i++)
	{
		// Debug(ItemRelationWindowArrayStr[i]);
		// 아이템 관계된 목록이 추가 되면 추가 해야 한다. 
		hideTargetWindow(currentWindowName, ItemRelationWindowArrayStr[i], exceptionWindowNameWithComma);
	}	
}

/**
 *  현재 윈도우만 나두고, 나머지 아이템 관련된 모든 윈도우를 닫아 버린다.
 *  
 *  -  주의!!! --
 *  닫을때는 각 윈도우 마다 고유 닫는 형식으로 닫아 주게 만들었다.
 *  혹시 추가 할때 이런식으로 일일이 찾아서 해당 닫기 함수를 실행 해야 하니 주의 바란다.
 *  
 **/
function hideTargetWindow(string currentWindowName, string WindowHandleString, optional string exceptionWindowNameWithComma)
{
	local int i;
	local array<string>	exceptionArray;


	if (exceptionWindowNameWithComma != "")
	{
		Split(exceptionWindowNameWithComma, ",", exceptionArray);

		if (exceptionArray.Length <= 1)
		{
			// , 가 없는 경우라면..
			exceptionArray[0] = exceptionWindowNameWithComma;
			// Debug("하나 "@ exceptionArray[0]);
		}		
	}

	for (i = 0; i< exceptionArray.Length; i++)
	{
		// Debug("WindowHandleString" @ WindowHandleString);
		// Debug("exceptionArray[i]" @ exceptionArray[i]);
		// 예외 윈도우에 있으면 닫지 않는다.
		if (WindowHandleString == exceptionArray[i]) return;
	}

	// 현재 윈도우와 같지 않은 경우, 같다면 나둔다. 
	if (currentWindowName != WindowHandleString)
	{		
		// 해당 윈도우가 열려 있다면!
		//GFx 윈도우 들은 아래서 처리 해야 함. GetWindowHandle 이 함수가 작동 안 되기 때문
		//AlchemyMixCubeWnd,AlchemyItemConvesionWnd"
		/*
		if (WindowHandleString == "AdenaDistributionWnd" )
		{
			if ( class'UIAPI_WINDOW'.static.IsShowWindow(WindowHandleString) )
			{
				switch ( WindowHandleString )
				{
					case "AdenaDistributionWnd"     :
						CallGFxFunction (WindowHandleString, "RequestDivideAdenaCancel", "" );
						class'UIAPI_WINDOW'.static.hideWindow( WindowHandleString );
						break;
					Default : class'UIAPI_WINDOW'.static.hideWindow( WindowHandleString );
				}
			}
		}

		else */
		if ( class'UIAPI_WINDOW'.static.isShowWindow( WindowHandleString ) )
		{
			// 윈도우를 닫아 버린다. 
			// 닫을때 각 윈도우 마다 그냥 hideWindow 하면 안되는 경우가 있다.
			// debug("WindowHandleString:---> " @ WindowHandleString);
			switch(WindowHandleString)				
			{
				case "PrivateShopWnd"           : privateShopWndScript.OnClickButton("StopButton"); break;
				case "RefineryWnd"              : RefineryWndScript.OnClickCancelButton(); break;
				case "UnrefineryWnd"            : UnrefineryWndScript.OnClickButton("btnClose");	break;		
				case "AttributeRemoveWnd"       : AttributeRemoveWndScript.OnbtnCancelClick(); break;
				case "AttributeEnchantWnd"      : AttributeEnchantWndScript.OnReceivedCloseUI(); break;
				case "CrystallizationWnd"       : CrystallizationWndScript.cancelCystallizeItem(); break;
				case "ItemEnchantWnd"           : ItemEnchantWndScript.OnClickButton( "ExitBtn" ); break;
				case "ItemLookChangeWnd"        : ItemLookChangeWndScript.OnClickButton( "ExitBtn" ); break; //branch 111109
				case "MultiSellWnd"             : MultiSellWndScript.OnClickButton( "Close_Button"); break;
				case "TradeWnd"                 : TradeWndScript.OnClickButton("CancelButton"); GetWindowHandle(WindowHandleString).HideWindow(); break; //AnswerTradeRequest( false );
				case "DeliverWnd"               : DeliverWndScript.OnClickButton( "CancelButton"); break;		
				case "ItemAttributeChangeWnd"   : ItemAttributeChangeWndScript.OnClickButton( "CancelBtn"); break;
				case "AdenaDistributionWnd"     : CallGFxFunction (WindowHandleString, "RequestDivideAdenaCancel", "" ); break;

				default : class'UIAPI_WINDOW'.static.HideWindow( WindowHandleString );
			}			
		}
	}
}

/**
 * 현재 아이템 관계 윈도우가 열려 있다면.. 현재 윈도우를 열지 않고 
 * 다시 숨긴다. 
 * 아이템들이 열려 있다면..
 * 
 * 정책상 현재 사용안하게 되었음..
 **/
function ItemRelationWindowsShowChecker(string currentWindowName)
{	
	privateShopWndScript = PrivateShopWnd(GetScript("PrivateShopWnd"));

	// 한개라도 열려 있다면...
	if (isItemRelationWindowsShow(currentWindowName))
	{
		if (GetWindowHandle(currentWindowName).IsShowWindow())
		{
			// 해당 윈도우를 닫는다. 
			hideTargetWindow("", currentWindowName);
			// GetWindowHandle(currentWindowName).HideWindow();
		}
	}
}

/**  아이템 관련된 윈도우가 열려 있나? (현재 지정한 윈도우 제외) */
function bool isItemRelationWindowsShow(string currentWindowName)
{
	local bool checkFlag;	
	local int i, len;

	len       = ItemRelationWindowArrayStr.Length;
	checkFlag = false;
	
	// Debug("ItemRelationWindowArrayStr : "  @ ItemRelationWindowString);
	// Debug("i = " @ len);

	for(i = 0; i < len; i++)
	{
		// Debug("ItemRelationWindowArrayStr[i]" @ ItemRelationWindowArrayStr[i]);
		if (currentWindowName != ItemRelationWindowArrayStr[i])
		{		
			if (GetWindowHandle(ItemRelationWindowArrayStr[i]).IsShowWindow()) { checkFlag = true; break; }
		}
	}

	return checkFlag;
}

/**
 *  "0" 제로 생성기 
 *  
 *  매개변수 
 *    len    : 5  -> 글자수 지정
 *    num    : 696
 *    리턴값 : --> 00696 스트링으로 리턴
 **/
function string makeZeroString(int strLen, INT64 num)
{
	local int i;
	local string sum;

	sum = string(num);

	for (i = 0; i < strLen; i++)
	{	
		if (len(sum) >= strLen) 
		{
			break;
		}
		else
		{
			sum = "0" $ sum;
		}
	}

	// Debug("sum:::" @ sum);
	return sum;
}

/** 
 * 
 * 윈도우 이름을 받는다.
 * 
 * getWindowName (string(Self)) 
 * 
 **/
function string getSliceWindowName (string targetString)
{
	local array<string>	ArrayStr;

	
	Split(targetString, ".", ArrayStr);

	return ArrayStr[1];
}


//************************************************************************************************************************
// 데이타 관련 : 하드 코딩 
//************************************************************************************************************************
/**
 *  캐릭터 생성 관련 스트링 모음
 **/

// Gfx CharacterData.as 코드에 정의
//function array<int> getRaceBasicSkillID(int race)
//{
//	local array<int>ArrayRaceBasicSkillID;
//	switch(race) {
//	case 0 : //휴먼은 스킬이 없습니다.
//		break;
//	case 1 :
//		ArrayRaceBasicSkillID[0] = 58; 
//		break;
//	case 2 :
//		ArrayRaceBasicSkillID[0] = 294;		
//		break;
//	case 3 :
//		ArrayRaceBasicSkillID[0] = 134;
//		ArrayRaceBasicSkillID[1] = 295;
//		break;
//	case 4 : 
//		ArrayRaceBasicSkillID[0] = 150;
//		ArrayRaceBasicSkillID[1] = 1321;
//		break;
//	case 5 : 
//		ArrayRaceBasicSkillID[0] = 467;		
//		break;
//	case 6 : 
//		//아르테이어는 베이직 스킬이 없습니다.
//		//ArrayRaceBasicSkillID[0] = 467;		
//		break;
//	}
//	//Debug( "Util.ArrayRaceBasicSkillID.length" @ArrayRaceBasicSkillID.length);
//	return ArrayRaceBasicSkillID;
//}

//function array<int> getRaceAwakenSkillID(int race) 
//{
//	local array<int>ArrayRaceAwakenSkillID;	
//	//직업 세분화로 120829 수정
//	switch(race) {
//	case 0 : //휴먼 2

//		ArrayRaceAwakenSkillID[0] = 1901; //시작 번호
//		ArrayRaceAwakenSkillID[1] = 1902; 
//		//ArrayRaceAwakenSkillID[2] = 1903; 
//		//ArrayRaceAwakenSkillID[3] = 1904; 
//		break;
//	case 1 ://엘프 2
//		//ArrayRaceAwakenSkillID[0] = 1905; 
//		ArrayRaceAwakenSkillID[0] = 1906; 
//		//ArrayRaceAwakenSkillID[2] = 1907; 
//		ArrayRaceAwakenSkillID[1] = 1908; 
//		break;
//	case 2 ://다엘 2
//		ArrayRaceAwakenSkillID[0] = 1909; 
//		//ArrayRaceAwakenSkillID[1] = 1910; 
//		ArrayRaceAwakenSkillID[1] = 1911; 
//		//ArrayRaceAwakenSkillID[3] = 1912; 
//		//ArrayRaceAwakenSkillID[4] = 1913; 
//		break;
//	case 3 ://오크 2
//		//ArrayRaceAwakenSkillID[0] = 1914; 
//		ArrayRaceAwakenSkillID[0] = 1915; 
//		ArrayRaceAwakenSkillID[1] = 1916; 
//		//ArrayRaceAwakenSkillID[3] = 1917; 
//		break;
//	case 4 : //드워프 2 
//		ArrayRaceAwakenSkillID[0] = 1919; 
//		//ArrayRaceAwakenSkillID[1] = 1920; 
//		ArrayRaceAwakenSkillID[1] = 1921; 
//		//ArrayRaceAwakenSkillID[3] = 1922; 
//		//2011 05 30 세개 스킬 추가 해야 한다는 내용으로 ttp가 왔으나 내용 확인 중
//		//ArrayRaceAwakenSkillID[4] = 19088; 
//		//ArrayRaceAwakenSkillID[5] = 19089; 
//		//ArrayRaceAwakenSkillID[6] = 19090; 
//		break;
//	case 5 ://카마엘 3
//		ArrayRaceAwakenSkillID[0] = 1923; 
//		ArrayRaceAwakenSkillID[1] = 1924; 
//		//ArrayRaceAwakenSkillID[2] = 1925; 
//		ArrayRaceAwakenSkillID[2] = 1926; 
//		break;
//	case 6 ://아르테이아 4
//		ArrayRaceAwakenSkillID[0] = 30400; 
//		ArrayRaceAwakenSkillID[1] = 30401; 		
//		ArrayRaceAwakenSkillID[2] = 30402; 
//		break;
//	}
//	return ArrayRaceAwakenSkillID;
//}

function int getInitClassID( int race, int option ) {
	local array<int> initClassID ;

	switch ( race ) {
		case 0 :
			initClassID [0] = 0    ;//휴먼 파이터
			initClassID [1] = 10   ;//휴먼 메이지
			break;
		case 1 :
			initClassID [0] = 18   ;//엘븐 파이터
			initClassID [1] = 25   ;//엘븐 메이지
			break;
		case 2 :
			initClassID [0] = 31   ;//다크 파이터
			initClassID [1] = 38   ;//다크 메이지
			break;
		case 3 :
			initClassID [0] = 44   ;//오크 파이터
			initClassID [1] = 49   ;//오크 메이지
			break;
		case 4 : 
			initClassID [0] = 53   ;//드워븐 파이터
			initClassID [1] = 53   ;//드워븐 파이터
			break;
		case 5 :
			initClassID [0] = 123  ;//카마엘 솔져 남
			initClassID [1] = 124  ;//카마엘 솔져 여	
			break;
		case 6 :
			initClassID [0] = 182  ;//아르테이어 파이터 여
			initClassID [1] = 183  ;//아르테이어 메이지 여
			break;
	}
	

	return initClassID[option];
}

// 무게에 따라 배열을 정리 하는 함수 
function array<itemInfo> sortByName( array<itemInfo> itemList ) 
{
	local int len;		
	local ItemInfo temp;
	local int i;
	local int j;
	len = itemList.Length;	
	for (i = 0; i < len; ++i)
	{
		for (j = 0; j < len - i; ++j)
		{
			if (j < len - 1)
			{
				if (GetItemNameWithAdditional(itemList[j]) > GetItemNameWithAdditional(itemList[j + 1]))
				{
					temp = itemList[j];
					itemList[j] = itemList[j + 1];
					itemList[j + 1] = temp;
				}
			}
		}
	}
	return itemList;
}

// 무게에 따라 배열을 정리 하는 함수 
function array<itemInfo> sortByWeight( array<itemInfo> itemList ) 
{
	local int len;		
	local ItemInfo temp;
	local int i;
	local int j;
	len = itemList.Length;	
	for (i = 0; i < len; ++i)
	{
		for (j = 0; j < len - i; ++j)
		{
			if (j < len - 1)
			{
				if (itemList[j].Weight < itemList[j + 1].Weight)
				{
					temp = itemList[j];
					itemList[j] = itemList[j + 1];
					itemList[j + 1] = temp;
				}
			}
		}
	}
	return itemList;
}

// 무게에 따라 배열을 정리 하는 함수 
function array<int> sortByInt( array<int> itemList ) 
{
	local int len;		
	local int temp;
	local int i;
	local int j;
	len = itemList.Length;	
	for (i = 0; i < len; ++i)
	{
		for (j = 0; j < len - i; ++j)
		{
			if (j < len - 1)
			{
				if (itemList[j] < itemList[j + 1])
				{
					temp = itemList[j];
					itemList[j] = itemList[j + 1];
					itemList[j + 1] = temp;
				}
			}
		}
	}
	return itemList;
}

// defaultPrice 에 따라 배열을 정리 하는 함수 
function array<itemInfo> sortByDP( array<itemInfo> itemList ) 
{
	local int len;
	local ItemInfo temp;
	local int i;
	local int j;	
	len = itemList.Length;	
	for (i = 0; i < len; ++i)
	{
		for (j = 0; j < len - i; ++j)
		{
			if (j < len - 1)
			{
				//Debug ( "sortByDP" @ itemList[j].Name @ itemList[j].n64DefaultPriceFromScript @ itemList[j + 1].n64DefaultPriceFromScript ) ;				
				if (itemList[j].n64DefaultPriceFromScript < itemList[j + 1].n64DefaultPriceFromScript)
				{
					temp = itemList[j];
					itemList[j] = itemList[j + 1];
					itemList[j + 1] = temp;
				}
			}
		}
	}
	return itemList;
}

function array<itemInfo> pushItemInfo( array<ItemInfo> itemList, ItemInfo info ) 
{	
	itemList.Length = itemList.Length + 1;
	itemList[itemList.Length - 1] = info;
	return itemList;
}

function array<itemInfo> pushItemInfoArray( array<itemInfo> itemList, array<ItemInfo> pushList )
{
	local int i ;
	local int itemListRen;
	itemListRen = itemList.Length;
	itemList.Length = itemListRen + pushList.Length ;
	for ( i = 0 ; i < pushList.Length ; i++ ) 
	{
		itemList[ itemListRen + i ] = pushList[i] ;//  = pushItemInfo (itemList, pushList[i] ) ;		
	}
	return itemList;
}

//************************************************************************************************************************************************
// Item윈도우 , 아이템 정렬 기능 - 인벤토리에서 빼와서 좀 수정함
//************************************************************************************************************************************************
function array<itemInfo> SortItemArray( array<ItemInfo> itemList)
{
	local int i ;
	local int itemNum ;
	local ItemInfo item ;
	local EItemType eItemType ;

	local Array<ItemInfo> AssetList ;
	local Array<ItemInfo> WeaponList ;
	local Array<ItemInfo> ArmorList ;
	local Array<ItemInfo> AccesaryList ;
	local Array<ItemInfo> EtcItemList ;

	// etc item 구분
	local Array<ItemInfo> AncientCrystalEnchantAmList;
	local Array<ItemInfo> AncientCrystalEnchantWpList;
	local Array<ItemInfo> CrystalEnchantAmList;
	local Array<ItemInfo> CrystalEnchantWpList;

	local Array<ItemInfo> BlessEnchantAmList;
	local Array<ItemInfo> BlessEnchantWpList;

	local Array<ItemInfo> EnchantAmList;
	local Array<ItemInfo> EnchantWpList;

	local Array<ItemInfo> IncEnchantPropAmList;
	local Array<ItemInfo> IncEnchantPropWpList;

	local Array<ItemInfo> PotionList;
	local Array<ItemInfo> ElixirList;

	local Array<ItemInfo> ArrowList;
	local Array<ItemInfo> BoltList;

	local Array<ItemInfo> RecipeList;

	itemNum = itemList.Length;
	
	// 1. 아이템들을 종류별로 구분
	for (i = 0; i < itemNum; ++i)
	{
		item = itemList[i];

		if(!IsValidItemID(item.ID))
		{
			continue;
		}

		eItemType = EItemType(item.ItemType);

		switch (eItemType)
		{
		case ITEM_ASSET:
			AssetList = pushItemInfo (AssetList, item ) ;
			break;

		case ITEM_WEAPON:			
			WeaponList = pushItemInfo (WeaponList, item ) ;			
			break;

		case ITEM_ARMOR:
			ArmorList = pushItemInfo (ArmorList, item ) ;			
			break;

		case ITEM_ACCESSARY:
			AccesaryList = pushItemInfo (AccesaryList, item ) ;
			break;

		case ITEM_ETCITEM:
			// testInt = item.ItemSubType;
			//debug(int(item.ItemSubType));
			switch (EEtcItemType(item.ItemSubType))
			{
			case ITEME_ENCHT_ATTR_ANCIENT_CRYSTAL_ENCHANT_AM:
				AncientCrystalEnchantAmList = pushItemInfo (AncientCrystalEnchantAmList, item ) ;					
				break;
			case ITEME_ENCHT_ATTR_ANCIENT_CRYSTAL_ENCHANT_WP:
				AncientCrystalEnchantWpList = pushItemInfo (AncientCrystalEnchantWpList, item ) ;
				break;
			case ITEME_ENCHT_ATTR_CRYSTAL_ENCHANT_AM:
				CrystalEnchantAmList = pushItemInfo (CrystalEnchantAmList, item ) ;													
				break;
			case ITEME_ENCHT_ATTR_CRYSTAL_ENCHANT_WP:
				CrystalEnchantWpList = pushItemInfo (CrystalEnchantWpList, item ) ;																	
				break;
			case ITEME_BLESS_ENCHT_AM:
				BlessEnchantAmList = pushItemInfo (BlessEnchantAmList, item ) ;																					
				break;
			case ITEME_BLESS_ENCHT_WP:
				BlessEnchantWpList = pushItemInfo (BlessEnchantWpList, item ) ;																									
				break;
			case ITEME_ENCHT_AM:
				EnchantAmList = pushItemInfo (EnchantAmList, item ) ;																									
				break;
			case ITEME_ENCHT_WP:
				EnchantWpList = pushItemInfo (EnchantWpList, item ) ;																													
				break;
			case ITEME_ENCHT_ATTR_INC_PROP_ENCHT_AM:
				IncEnchantPropAmList = pushItemInfo (IncEnchantPropAmList, item ) ;	
				break;
			case ITEME_ENCHT_ATTR_INC_PROP_ENCHT_WP:
				IncEnchantPropWpList = pushItemInfo (IncEnchantPropWpList, item ) ;	
				break;
			case ITEME_POTION:
				PotionList = pushItemInfo (PotionList, item ) ;					
				break;
			case ITEME_ELIXIR:
				ElixirList = pushItemInfo (ElixirList, item ) ;									
				break;
			case ITEME_ARROW:
				ArrowList = pushItemInfo (ArrowList, item ) ;					
				break;
			case ITEME_BOLT:
				BoltList = pushItemInfo (BoltList, item ) ;
				break;
			case ITEME_RECIPE:
				RecipeList = pushItemInfo (RecipeList, item ) ;				
				break;
			default:
				EtcItemList = pushItemInfo (EtcItemList, item ) ;					
				break;
			}
			break;

		default:
			EtcItemList = pushItemInfo (EtcItemList, item ) ;		
			break;
		}
	}

	// 2. 구분 된 아이템들을 각 리스트 당 DP 순으로 정렬	
	AssetList = sortByName (AssetList);
	WeaponList = sortByName (WeaponList);
	ArmorList = sortByName (ArmorList);
	AccesaryList = sortByName (AccesaryList);
	AncientCrystalEnchantAmList = sortByName (AncientCrystalEnchantAmList);
	AncientCrystalEnchantWpList = sortByName (AncientCrystalEnchantWpList);
	CrystalEnchantAmList = sortByName (CrystalEnchantAmList);
	CrystalEnchantWpList = sortByName (CrystalEnchantWpList);
	BlessEnchantAmList = sortByName (BlessEnchantAmList);
	BlessEnchantWpList = sortByName (BlessEnchantWpList);
	EnchantAmList = sortByName (EnchantAmList);
	EnchantWpList = sortByName (EnchantWpList);
	IncEnchantPropAmList = sortByName (IncEnchantPropAmList);		
	IncEnchantPropWpList = sortByName (IncEnchantPropWpList);			
	PotionList = sortByName (PotionList);
	ElixirList = sortByName (ElixirList);
	ArrowList = sortByName (ArrowList);
	BoltList = sortByName (BoltList);
	RecipeList = sortByName (RecipeList);	
	EtcItemList = sortByName (EtcItemList);
	
	// 3. 순서대로 다시 입력 	
	itemList.Remove(0, itemList.Length);
	itemList = pushItemInfoArray (itemList, AssetList) ;	
	itemList = pushItemInfoArray (itemList, WeaponList) ;	
	itemList = pushItemInfoArray (itemList, ArmorList) ;	
	itemList = pushItemInfoArray (itemList, AccesaryList) ;	
	itemList = pushItemInfoArray (itemList, AncientCrystalEnchantAmList) ;	
	itemList = pushItemInfoArray (itemList, AncientCrystalEnchantWpList) ;	
	itemList = pushItemInfoArray (itemList, CrystalEnchantAmList) ;
	itemList = pushItemInfoArray (itemList, CrystalEnchantWpList) ;
	itemList = pushItemInfoArray (itemList, BlessEnchantAmList) ;
	itemList = pushItemInfoArray (itemList, BlessEnchantWpList) ;
	itemList = pushItemInfoArray (itemList, EnchantAmList) ;
	itemList = pushItemInfoArray (itemList, EnchantWpList) ;
	itemList = pushItemInfoArray (itemList, IncEnchantPropAmList) ;
	itemList = pushItemInfoArray (itemList, IncEnchantPropWpList) ;
	itemList = pushItemInfoArray (itemList, PotionList) ;
	itemList = pushItemInfoArray (itemList, ElixirList) ;
	itemList = pushItemInfoArray (itemList, ArrowList) ;
	itemList = pushItemInfoArray (itemList, BoltList) ;
	itemList = pushItemInfoArray (itemList, RecipeList) ;
	itemList = pushItemInfoArray (itemList, EtcItemList) ;

	return itemList;
}


//************************************************************************************************************************************************
// Item윈도우 , 아이템 정렬 기능 - 인벤토리에서 빼와서 좀 수정함
//************************************************************************************************************************************************
function SortItem( ItemWindowHandle m_topList)
{
	local int i ;
	local int invenLimit;
	local ItemInfo item;
	local EItemType eItemType;
	
	local int nextSlot;

	local Array<ItemInfo> AssetList;
	local Array<ItemInfo> WeaponList;
	local Array<ItemInfo> ArmorList;
	local Array<ItemInfo> AccesaryList;
	local Array<ItemInfo> EtcItemList;

	// etc item 구분
	local Array<ItemInfo> AncientCrystalEnchantAmList;
	local Array<ItemInfo> AncientCrystalEnchantWpList;
	local Array<ItemInfo> CrystalEnchantAmList;
	local Array<ItemInfo> CrystalEnchantWpList;

	local Array<ItemInfo> BlessEnchantAmList;
	local Array<ItemInfo> BlessEnchantWpList;

	local Array<ItemInfo> EnchantAmList;
	local Array<ItemInfo> EnchantWpList;

	local Array<ItemInfo> IncEnchantPropAmList;
	local Array<ItemInfo> IncEnchantPropWpList;

	local Array<ItemInfo> PotionList;
	local Array<ItemInfo> ElixirList;

	local Array<ItemInfo> ArrowList;
	local Array<ItemInfo> BoltList;

	local Array<ItemInfo> RecipeList;

	invenLimit = m_topList.GetItemNum();	
	
	// 1. 아이템들을 종류별로 구분
	for (i = 0; i < invenLimit ; ++i)
	{
		m_topList.GetItem(i, item);

		if(!IsValidItemID(item.ID))
		{
			continue;
		}

		eItemType = EItemType(item.ItemType);

		switch (eItemType)
		{
		case ITEM_ASSET:
			AssetList = pushItemInfo (AssetList, item ) ;
			break;

		case ITEM_WEAPON:			
			WeaponList = pushItemInfo (WeaponList, item ) ;
			break;

		case ITEM_ARMOR:
			ArmorList = pushItemInfo (ArmorList, item ) ;
			break;

		case ITEM_ACCESSARY:
			AccesaryList = pushItemInfo (AccesaryList, item ) ;
			break;

		case ITEM_ETCITEM:
			// testInt = item.ItemSubType;
			//debug(int(item.ItemSubType));
			switch (EEtcItemType(item.ItemSubType))
			{
			case ITEME_ENCHT_ATTR_ANCIENT_CRYSTAL_ENCHANT_AM:
				AncientCrystalEnchantAmList = pushItemInfo (AncientCrystalEnchantAmList, item ) ;				
				break;
			case ITEME_ENCHT_ATTR_ANCIENT_CRYSTAL_ENCHANT_WP:
				AncientCrystalEnchantWpList = pushItemInfo (AncientCrystalEnchantWpList, item ) ;
				break;
			case ITEME_ENCHT_ATTR_CRYSTAL_ENCHANT_AM:
				CrystalEnchantAmList = pushItemInfo (CrystalEnchantAmList, item ) ;													
				break;
			case ITEME_ENCHT_ATTR_CRYSTAL_ENCHANT_WP:
				CrystalEnchantWpList = pushItemInfo (CrystalEnchantWpList, item ) ;																	
				break;
			case ITEME_BLESS_ENCHT_AM:
				BlessEnchantAmList = pushItemInfo (BlessEnchantAmList, item ) ;																					
				break;
			case ITEME_BLESS_ENCHT_WP:
				BlessEnchantWpList = pushItemInfo (BlessEnchantWpList, item ) ;																									
				break;
			case ITEME_ENCHT_AM:
				EnchantAmList = pushItemInfo (EnchantAmList, item ) ;																									
				break;
			case ITEME_ENCHT_WP:
				EnchantWpList = pushItemInfo (EnchantWpList, item ) ;																													
				break;
			case ITEME_ENCHT_ATTR_INC_PROP_ENCHT_AM:
				IncEnchantPropAmList = pushItemInfo (IncEnchantPropAmList, item ) ;	
				break;
			case ITEME_ENCHT_ATTR_INC_PROP_ENCHT_WP:
				IncEnchantPropWpList = pushItemInfo (IncEnchantPropWpList, item ) ;	
				break;
			case ITEME_POTION:
				PotionList = pushItemInfo (PotionList, item ) ;					
				break;
			case ITEME_ELIXIR:
				ElixirList = pushItemInfo (ElixirList, item ) ;									
				break;
			case ITEME_ARROW:
				ArrowList = pushItemInfo (ArrowList, item ) ;					
				break;
			case ITEME_BOLT:
				BoltList = pushItemInfo (BoltList, item ) ;
				break;
			case ITEME_RECIPE:
				RecipeList = pushItemInfo (RecipeList, item ) ;				
				break;
			default:
				EtcItemList = pushItemInfo (EtcItemList, item ) ;					
				break;
			}
			break;

		default:
			EtcItemList = pushItemInfo (EtcItemList, item ) ;		
			break;
		}
	}

	// 2. 구분 된 아이템들을 각 리스트 당 무게순으로 정렬	
	AssetList = sortByName (AssetList);	
	WeaponList = sortByName (WeaponList);
	ArmorList = sortByName (ArmorList);	
	AccesaryList = sortByName (AccesaryList);
	AncientCrystalEnchantAmList = sortByName (AncientCrystalEnchantAmList);
	AncientCrystalEnchantWpList = sortByName (AncientCrystalEnchantWpList);
	CrystalEnchantAmList = sortByName (CrystalEnchantAmList);
	CrystalEnchantWpList = sortByName (CrystalEnchantWpList);
	BlessEnchantAmList = sortByName (BlessEnchantAmList);
	BlessEnchantWpList = sortByName (BlessEnchantWpList);
	EnchantAmList = sortByName (EnchantAmList);
	EnchantWpList = sortByName (EnchantWpList);		
	IncEnchantPropAmList = sortByName (IncEnchantPropAmList);		
	IncEnchantPropWpList = sortByName (IncEnchantPropWpList);			
	PotionList = sortByName (PotionList);
	ElixirList = sortByName (ElixirList);
	ArrowList = sortByName (ArrowList);
	BoltList = sortByName (BoltList);
	RecipeList = sortByName (RecipeList);	
	EtcItemList = sortByName (EtcItemList);	
	
	//Debug ( "SortItem" @ AssetList.Length @ WeaponList.Length  );
	// 3. 인벤에 다시 삽입
	m_topList.Clear();

	ItemboxUpdate(m_topList, invenLimit);
	
	for (i = 0; i < AssetList.Length; ++i)
	{
		m_topList.SetItem( nextSlot + i, AssetList[i]);
	}

	nextSlot = nextSlot + AssetList.Length;

	for (i = 0; i < WeaponList.Length; ++i)
	{
		m_topList.SetItem(nextSlot + i, WeaponList[i]);
	}

	nextSlot = nextSlot + WeaponList.Length;

	for (i = 0; i < ArmorList.Length; ++i)
	{
		m_topList.SetItem(nextSlot + i, ArmorList[i]);
	}
	nextSlot = nextSlot + ArmorList.Length;

	for (i = 0; i < AccesaryList.Length; ++i)
	{
		m_topList.SetItem(nextSlot + i, AccesaryList[i]);
	}
	nextSlot = nextSlot + AccesaryList.Length;

	for (i = 0; i < AncientCrystalEnchantAmList.Length; ++i)
	{
		m_topList.SetItem(nextSlot + i, AncientCrystalEnchantAmList[i]);
	}
	nextSlot = nextSlot + AncientCrystalEnchantAmList.Length;

	for (i = 0; i < AncientCrystalEnchantWpList.Length; ++i)
	{
		m_topList.SetItem(nextSlot + i, AncientCrystalEnchantWpList[i]);
	}
	nextSlot = nextSlot + AncientCrystalEnchantWpList.Length;

	for (i = 0; i < CrystalEnchantAmList.Length; ++i)
	{
		m_topList.SetItem(nextSlot + i, CrystalEnchantAmList[i]);
	}
	nextSlot = nextSlot + CrystalEnchantAmList.Length;

	for (i = 0; i < CrystalEnchantWpList.Length; ++i)
	{
		m_topList.SetItem(nextSlot + i, CrystalEnchantWpList[i]);
	}
	nextSlot = nextSlot + CrystalEnchantWpList.Length;

	for (i = 0; i < BlessEnchantAmList.Length; ++i)
	{
		m_topList.SetItem(nextSlot + i, BlessEnchantAmList[i]);
	}
	nextSlot = nextSlot + BlessEnchantAmList.Length;

	for (i = 0; i < BlessEnchantWpList.Length ; ++i)
	{
		m_topList.SetItem(nextSlot + i, BlessEnchantWpList[i]);
	}
	nextSlot = nextSlot + BlessEnchantWpList.Length;

	for (i = 0; i < EnchantAmList.Length ; ++i)
	{
		m_topList.SetItem(nextSlot + i, EnchantAmList[i]);
	}
	nextSlot = nextSlot + EnchantAmList.Length;

	for (i = 0; i < EnchantWpList.Length ; ++i)
	{
		m_topList.SetItem(nextSlot + i, EnchantWpList[i]);
	}
	nextSlot = nextSlot + EnchantWpList.Length;

	for (i = 0; i < IncEnchantPropAmList.Length ; ++i)
	{
		m_topList.SetItem(nextSlot + i, IncEnchantPropAmList[i]);
	}
	nextSlot = nextSlot + IncEnchantPropAmList.Length;

	for (i = 0; i < IncEnchantPropWpList.Length ; ++i)
	{
		m_topList.SetItem(nextSlot + i, IncEnchantPropWpList[i]);
	}
	nextSlot = nextSlot + IncEnchantPropWpList.Length;

	for (i = 0; i < PotionList.Length ; ++i)
	{
		m_topList.SetItem(nextSlot + i, PotionList[i]);
	}
	nextSlot = nextSlot + PotionList.Length;

	for (i = 0; i < ElixirList.Length ; ++i)
	{
		m_topList.SetItem(nextSlot + i, ElixirList[i]);
	}
	nextSlot = nextSlot + ElixirList.Length;

	for (i = 0; i < ArrowList.Length ; ++i)
	{
		m_topList.SetItem(nextSlot + i, ArrowList[i]);
	}
	nextSlot = nextSlot + ArrowList.Length;

	for (i = 0; i < BoltList.Length ; ++i)
	{
		m_topList.SetItem(nextSlot + i, BoltList[i]);
	}
	nextSlot = nextSlot + BoltList.Length;

	for (i = 0; i < RecipeList.Length ; ++i)
	{
		m_topList.SetItem(nextSlot + i, RecipeList[i]);
	}
	nextSlot = nextSlot + RecipeList.Length;

	for (i = 0; i < EtcItemList.Length ; ++i)
	{
		m_topList.SetItem(nextSlot + i, EtcItemList[i]);
	}

	// m_NormalInvenCount = nextSlot;

	// debug("[Sorting Inven Item]" $ nextSlot $ "items sorted complete!!");
}


//************************************************************************************************************************************************
// classID 로 아이템을 찾음, 봉인 타입으로 체크 
//************************************************************************************************************************************************
function int FindItemByClassID( int classID, out array<ItemInfo> itemInfoArray, optional EItemLockedCheckType lockType  )
{
	local int i, itemCount ;
	local array<ItemInfo> tmpItemArray;
	
	itemCount = class'UIDATA_INVENTORY'.static.FindItemByClassID(classID, tmpItemArray);

	if ( lockType == EItemLockedCheckType.ANY ) return  itemCount;

	for ( i = 0  ; i < itemCount ; i ++ ) 
	{			
		// locked 목록 만 받음, // unlocked 목록 만 받음. // locked 를 제외, // unlocked 를 제외
		if ( ( lockType == EItemLockedCheckType.LOCK && tmpItemArray[i].bSecurityLock) || 
			 ( lockType == EItemLockedCheckType.UNLOCK && !tmpItemArray[i].bSecurityLock) )
		{	
			itemInfoArray.Length = itemInfoArray.Length + 1 ;
			itemInfoArray [itemInfoArray.Length -1 ] = tmpItemArray[i];
		}
	}

	return itemInfoArray.Length ;
}

function bool FindItemByServerID(int ServerID,out ItemInfo ServeritemInfo,optional EItemLockedCheckType lockType)
{
	local ItemInfo tmpItem;

	class'UIDATA_INVENTORY'.static.FindItem(ServerID,tmpItem);

	if(lockType == EItemLockedCheckType.ANY ||
		(lockType == EItemLockedCheckType.LOCK && tmpItem.bSecurityLock) || (lockType == EItemLockedCheckType.UNLOCK && !tmpItem.bSecurityLock))
	{
		ServeritemInfo = tmpItem;
	}

	if(ServeritemInfo.ItemNum < 1)
		return false;

	return true;
}

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

/***
 *  윈도우 위치 XY 좌표 싱크 하기 
 *  syncWindowLoc("Inventory", "aaWnd,bbWnd,ccWnd")  --> Inventory 윈도우의 좌표로 해당 윈도우들 이동
 **/
function syncWindowLoc(string currentWindowName, string windowNamesStr)
{
	local array<string>	windowNameArray;
	local Rect tempRect;
	local int i;

	Split(windowNamesStr, ",", windowNameArray);

	if (windowNameArray.Length <= 1)
	{
		// , 가 없는 경우라면..
		windowNameArray[0] = windowNamesStr;
	}		

	tempRect = GetWindowHandle(currentWindowName).GetRect();

	//Debug("currentWindowName" @ currentWindowName);
	//Debug("tempRect" @ tempRect.nX);
	//Debug("tempRect" @ tempRect.nY);

	for(i = 0; i < windowNameArray.Length; i++)
	{
		if  (currentWindowName != windowNameArray[i])
			GetWindowHandle(windowNameArray[i]).MoveTo(tempRect.nX, tempRect.nY);
	}
}

/***
 *  윈도우 위치 XY 좌표 싱크 하기 
 *  syncWindowLoc("aaWnd,bbWnd,ccWnd")  --> 현재 화면에 나와 있는것을 찾아서 그걸 기준으로.. 
 **/
function syncWindowLocAuto(string windowNamesStr)
{
	local array<string>	windowNameArray;
	local Rect tempRect;
	local int i;

	local bool bFindWindow;

	Split(windowNamesStr, ",", windowNameArray);

	// , 가 없는 경우라면..
	if (windowNameArray.Length <= 1) windowNameArray[0] = windowNamesStr;
	
	// 현재 열려 있는 윈도우를 찾고
	for(i = 0; i < windowNameArray.Length; i++)
	{
		if  (GetWindowHandle(windowNameArray[i]).IsShowWindow()) 
		{
			tempRect = GetWindowHandle(windowNameArray[i]).GetRect();
			bFindWindow = true;
			break;			
		}
	}

	// 열려 있는 것을 발견한 경우만..
	if (bFindWindow)
	{
		// 좌표 이동 적용
		for(i = 0; i < windowNameArray.Length; i++) GetWindowHandle(windowNameArray[i]).MoveTo(tempRect.nX, tempRect.nY);
	}
}

/***
 *  윈도우 위치 XY 좌표 싱크 하기 
 *  syncWindowLoc("Inventory", "aaWnd,bbWnd,ccWnd")  --> Inventory 윈도우의 좌표로 해당 윈도우들 이동
 **/
function hideGroupWindow(string currentWindowName, string windowNamesStr)
{
	local array<string>	windowNameArray;
	local int i;

	Split(windowNamesStr, ",", windowNameArray);

	if (windowNameArray.Length <= 1)
	{
		// , 가 없는 경우라면..
		windowNameArray[0] = windowNamesStr;
	}		

	for(i = 0; i < windowNameArray.Length; i++)
	{
		// Debug("conversationRelationWndNames" @ windowNameArray[i]);
		if  (currentWindowName != windowNameArray[i])
			GetWindowHandle(windowNameArray[i]).HideWindow();
	}
}


/***
 *  루팅 타입에 따른루팅 스트링 반환 
 **/
function string getLootingString( int ID)
{		
	switch ( ID ) 
	{
	case 0 :
		return GetSystemString( 487 );		
	break;
	case 1 :
		return GetSystemString( 488 );		
	break;
	case 2 :
		return GetSystemString( 798 );		
	break;
	case 3 :
		return GetSystemString( 799 );		
	break;
	case 4 :
		return GetSystemString( 800 );		
	break;
	}
	
}

//----------------------------------------------------------------------------------------------------------------------------------------
// XML UI컨트롤 보조 유틸 
//----------------------------------------------------------------------------------------------------------------------------------------

/**
 *  아이템 윈도우 컨트롤 간에 아이템을 이동 시키는 함수
 *  아이템을 itemWnd1 -> itemWnd2 로 이동
 *  
  **/
function ItemWIndow_ItemMoveByIndex(ItemWindowHandle itemWnd1, ItemWindowHandle itemWnd2, int itemWnd1_Index, optional bool useAddStackableItem)
{
	local itemInfo tempInfo, tmItem;
	local int itemCount, i;
	local bool hasItem;
	
	itemWnd1.GetItem(itemWnd1_Index, tempInfo);

	if (tempInfo.Id.ClassID > 0)
	{
		// 수량성 아이템이라면..
		if(IsStackableItem(tempInfo.ConsumeType) && useAddStackableItem)
		{			
			itemCount = itemWnd2.GetItemNum();
			
			for(i = 0; i < itemCount; i++)
			{
				if( itemWnd2.GetItem( i, tmItem ) )
				{
					// 같은 ID가 있으면 합쳐 준다.
					if(tempInfo.Id.ClassID == tmItem.Id.ClassID)
					{
						tmItem.ItemNum = tempInfo.ItemNum + tmItem.itemNum;
						itemWnd2.SetItem(i, tmItem);
						hasItem = true;
						break;
					}
				}
			}

			// 만약 아이템이 존재 하지 않는다면 그냥 넣는다.
			if (hasItem == false) itemWnd2.AddItem(tempInfo);
		}
		else
		{
			itemWnd2.AddItem(tempInfo);
		}

		itemWnd1.DeleteItem(itemWnd1_Index);
	}
	else
	{
		Debug("Error: L2Util ItemWIndow_ItemMoveByIndex -> Wrong Index ");
	}
}

/**
 *  아이템 윈도우 컨트롤 간에 아이템을 이동 시키는 함수
 *  아이템을 itemWnd1 -> itemWnd2 로 이동
 *  
 *  [수량성 아이템이 아닌 경우 사용]
 **/

function int ItemWIndow_ItemMoveByItemID(ItemWindowHandle itemWnd1, ItemWindowHandle itemWnd2, ItemID idInfo)
{
	local itemInfo tempInfo;
	local int index;

	index = ItemWIndow_searchItemByItemID(itemWnd1, idInfo);

	// index 는 0부터 시작, -1은 아이템 없음.
	if (index > -1)
	{
		itemWnd1.GetItem(index, tempInfo);
		itemWnd2.AddItem(tempInfo);
		itemWnd1.DeleteItem(index);
	}

	return index;
}

/**
 *   아이템 윈도우에서 아이템 index를 검색하여 리턴한다.
 *   없으면 -1을 리턴
 **/
function int ItemWIndow_searchItemByItemID(ItemWindowHandle itemWnd, ItemID idInfo)
{
	local int i, returnN;
	local itemInfo tempInfo;

	// 없으면 -1을 리턴
	returnN = -1;

	for (i = 0; i < itemWnd.GetItemNum(); i++)
	{
		itemWnd.GetItem(i, tempInfo);

		// 같은 ID가 있다면..
		if(idInfo == tempInfo.iD)
		{
			returnN = i;
			break;
		}
	}		

	return returnN;
}

/**
 *  텍스트 필드에 지정한 사이즈를 넘어가면 .. 을 끝에 찍고 툴팁을 넣어주는 역활
 *  
 *  ex) 
 *  util.textBox_setToolTipWithShortString(EnsoulDefaultWnd_WeaponName_TextBox);
 *  noSimpleTool 툴팁 사용 여부, true면 사용안함.
 **/
function textBox_setToolTipWithShortString(TextBoxHandle textBox, string context, optional int wTextField)
{
	local int textWidth, textHeight;
	local int wTextWidth, hTextHeight;

	textBox.GetWindowSize(wTextWidth, hTextHeight);

	GetTextSize(context, "GameDefault", textWidth, textHeight);

	if (textWidth > wTextWidth)
	{
		textBox.SetTooltipType("text");
		textBox.SetTooltipText(context);

		// 무기 이름 텍스트 필드 출력
		context = makeShortStringByPixel(context, wTextWidth - 8 + wTextField, "..");
	}

	textBox.SetText(context);
}

/** 메인 윈도우의 서브 윈도우가 중앙에 위치 하여 보이도록 하는 함수 */
function childWindowMoveToCenter(WindowHandle mainWindow, WindowHandle subWindow)
{
	local RECT pRect, cRect;
	local int currentWidth; 
	local int currentHeight;
	local int setX, setY;
	
	GetCurrentResolution (currentWidth, currentHeight);
			
	pRect = mainWindow.GetRect();
	cRect = subWindow.GetRect();
			
	setX = pRect.nx + (pRect.nWidth  / 2) - (cRect.nWidth  / 2);
	setY = pRect.ny + (pRect.nHeight / 2) - (cRect.nHeight / 2);
		
	// 화면에 넘어 가지 않도록 보정 처리 
	if (setX > currentWidth  - cRect.nWidth ) setX = currentWidth  - cRect.nWidth;
	else if (setX < 0) setX = 0;
	if (setY > currentHeight - cRect.nHeight) setY = currentHeight - cRect.nHeight;
	
	//	화면 중앙에 나오도록 세팅
	subWindow.ClearAnchor();
	subWindow.Move(0, 0);
	subWindow.MoveTo(setX, setY);			  
}

/** 기본적으로 해당 창의 오른쪽, 자리가 없다면 왼쪽으로 나오도록 하는 함수 */
function windowMoveToSide(WindowHandle mainWindow, WindowHandle subWindow)
{
	local RECT pRect, cRect;
	local int currentWidth; 
	local int currentHeight;
	local int setX, setY;
	
	GetCurrentResolution (currentWidth, currentHeight);
	
	pRect = mainWindow.GetRect();
	cRect = subWindow.GetRect();
	
	// 가로 해상도가 서브 창보다 커야만 작동 시킨다.
	if (currentWidth > cRect.nWidth)
	{
		setX = pRect.nx + (pRect.nWidth) + 5;
		setY = pRect.ny;
		
		// 화면에 넘어 가지 않도록 보정 처리 
		if (setX > currentWidth  - cRect.nWidth ) setX = pRect.nx - (cRect.nWidth + 5);
		else if (setX < 0) setX = 0;
		// if (setY > currentHeight - cRect.nHeight) setY = currentHeight - cRect.nHeight;
		
		//	화면 중앙에 나오도록 세팅
		subWindow.ClearAnchor();
		subWindow.Move(0, 0);
		subWindow.MoveTo(setX, setY);			  
	}
}

/** 기본적으로 해당 창의 오른쪽, 자리가 없다면 왼쪽으로 나오도록 하는 함수 */
function windowAnchorToSide(WindowHandle mainWindow, WindowHandle subWindow, optional int addX, optional int addY)
{
	local RECT pRect, cRect;
	local int currentWidth; 
	local int currentHeight;
	local int setX, setY;
	
	GetCurrentResolution (currentWidth, currentHeight);
	
	pRect = mainWindow.GetRect();
	cRect = subWindow.GetRect();
	
	// 가로 해상도가 서브 창보다 커야만 작동 시킨다.
	if (currentWidth > cRect.nWidth)
	{
		setX = pRect.nx + (pRect.nWidth) + 5;
		setY = pRect.ny;
		
		// 화면에 넘어 가지 않도록 보정 처리 
		if (setX > currentWidth  - cRect.nWidth ) 
		{
			//	화면 중앙에 나오도록 세팅
			subWindow.SetAnchor(mainWindow.GetWindowName(), "TopLeft", "TopLeft", -(cRect.nWidth + addX), addY );		
		}
		else
		{
			//	화면 중앙에 나오도록 세팅
			subWindow.SetAnchor(mainWindow.GetWindowName(), "TopLeft", "TopLeft", (pRect.nWidth + addX), addY );		
		}
		// if (setY > currentHeight - cRect.nHeight) setY = currentHeight - cRect.nHeight;
		
	}
}

function int getQuestLevelForID( int QuestID )
{
	local int i;
	local QuestTreeWnd scQuestTree;
	scQuestTree = QuestTreeWnd( GetScript( "QuestTreeWnd" ) );
	// 마지막 레벨을 받아야 하므로 뒤에서 부터 돌린다.
	for( i = scQuestTree.ArrQuest.Length - 1 ; i >= 0  ; i -- )
	{
		if( QuestID == scQuestTree.ArrQuest[i].QuestID )
		{			
			return scQuestTree.ArrQuest[i].Level ;			
		}		
	}
	return 0 ;
}


/*
 *  Gfx 스크린 메시지 
 *
 */
function showGfxScreenMessage ( string Msg, optional int type ) 
{
	local string strParam;
	ParamAdd(strParam, "Msg", Msg);
	ParamAdd(strParam, "type", String ( type ));
	CallGFxFunction ( "GfxScreenMessage" , "showMessage", strParam );
}

//----------------------------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------------------------
defaultproperties
{
}
