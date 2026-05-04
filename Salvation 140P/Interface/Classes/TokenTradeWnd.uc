//  마몬의 대장장이 호출 하여 테스트
// //생성 1031126

class TokenTradeWnd extends UICommonAPI;

const DelaySelectedTimerID = 12131212;
const DelayTimer = 50;

var WindowHandle Me;
var ButtonHandle TradeBtn;
var ButtonHandle CancelBtn;
var TextBoxHandle ItemTypeText;
var TextBoxHandle TradePossibleText;
var TextBoxHandle ItemExplainText;

//var TextBoxHandle NeedItemText;
//var TextBoxHandle NeedItemNameText;
//var TextBoxHandle NeedItemNumberText;

var TreeHandle ItemTypeTree;
var TreeHandle NeedItemTree;
var ListCtrlHandle TradePossibleListCtrl;

var TextureHandle NeedItemIcon;

//스킬 배우기용 변수
var L2Util util;

//음 아직 어떤용도 인지 모름.
struct MultiSellInfo
{
	var int 				MultiSellInfoID;
	var int 				MultiSellType;
	var INT64 				NeededItemNum;
	var	ItemInfo			ResultItemInfo;
	var array< ItemInfo >	OutputItemInfoList;
	var array< ItemInfo >	InputItemInfoList;
	var array<  int     >   Per;
	var array<  string  >   Param;
};

var array< MultiSellInfo >	m_MultiSellInfoList;
var int						m_MultiSellGroupID;
var int						m_nSelectedMultiSellInfoIndex;
var int						m_nCurrentMultiSellInfoIndex;

const TOKENSELLWND_DIALOG_OK = 1124;

// 최종 선택 했던 아이템 정보 기억 했다가 복원 할때 사용
var int lastSelectNitemID;
var int lastSelectIndex;

function OnRegisterEvent()
{
	registerEvent( EV_NewMultiSellInfoListBegin );
	registerEvent( EV_NewMultiSellResultItemInfo );
	registerEvent( EV_NewMultiSellOutputItemInfo );
	registerEvent( EV_NewMultiSellInputItemInfo );
	registerEvent( EV_NewMultiSellInfoListEnd );


	registerEvent( EV_AdenaInvenCount );
	//registerEvent( EV_MultiSellInfoListBegin );
	//registerEvent( EV_MultiSellResultItemInfo );
	//registerEvent( EV_MultiSellOutputItemInfo );
	//registerEvent( EV_MultiSellInputItemInfo );
	//registerEvent( EV_MultiSellInfoListEnd );

	registerEvent( EV_DialogOK );
}

function OnLoad()
{
	SetClosingOnESC();

	Initialize();
	Load();
}

function onShow()
{
	Me.KillTimer(DelaySelectedTimerID);
	lastSelectNitemID = 0;

	// 지정한 윈도우를 제외한 닫기 기능 
	getInstanceL2Util().ItemRelationWindowHide(getCurrentWindowName(String(self)));
}

function Initialize()
{
	Me = GetWindowHandle( "TokenTradeWnd" );
	TradeBtn = GetButtonHandle( "TokenTradeWnd.TradeBtn" );
	CancelBtn = GetButtonHandle( "TokenTradeWnd.CancelBtn" );
	ItemTypeText = GetTextBoxHandle( "TokenTradeWnd.ItemTypeText" );
	TradePossibleText = GetTextBoxHandle( "TokenTradeWnd.TradePossibleText" );
	ItemExplainText = GetTextBoxHandle( "TokenTradeWnd.ItemExplainText" );
	ItemTypeTree = GetTreeHandle( "TokenTradeWnd.ItemTypeTree" );


	//NeedItemText = GetTextBoxHandle( "TokenTradeWnd.NeedItemText" );
	//NeedItemNameText = GetTextBoxHandle( "TokenTradeWnd.NeedItemNameText" );
	//NeedItemNumberText = GetTextBoxHandle( "TokenTradeWnd.NeedItemNumberText" );	

	NeedItemTree = GetTreeHandle( "TokenTradeWnd.NeedItemTree" );

	TradePossibleListCtrl = GetListCtrlHandle( "TokenTradeWnd.TradePossibleListCtrl" );
	NeedItemIcon = GetTextureHandle( "TokenTradeWnd.NeedItemIcon" );

	TradePossibleListCtrl.SetSelectedSelTooltip(FALSE);	
	TradePossibleListCtrl.SetAppearTooltipAtMouseX(true);

	//TradePossibleTree.SetTooltipType( "Inventory" );
}

function Load()
{
	util = L2Util(GetScript("L2Util"));	
}

function OnClickButton( string strID )
{
	//Tree용 변수
	local Array<string> Result;
	local string treelist;
	
	treelist = Left(strID, 4);

	if( strID == "TradeBtn" )
	{
		OnTradeBtnClick();
	}
	else if( strID == "CancelBtn" )
	{
		OnCancelBtnClick();
	}

	if( treelist == "Root" )
	{
		Split( strID, ".", Result );
		SelectChangeItem(int(Result[1]));
	}
}

function OnTradeBtnClick()
{	
	local Array<string> Result;
	local string treelist;
	local int selectedIndex;

	treelist = class'UIAPI_TREECTRL'.static.GetExpandedNode( "TokenTradeWnd.ItemTypeTree", "Root" );
	Split( treelist, ".", Result );	

	if( treelist != "" )
	{
		selectedIndex = int( Result[1] );

		DialogSetReservedInt( selectedIndex );
		DialogSetReservedInt2( 1 );
		DialogSetID( TOKENSELLWND_DIALOG_OK );
		DialogShow(DialogModalType_Modalless,DialogType_Warning, GetSystemMessage(1383), string(Self));
		m_nSelectedMultiSellInfoIndex = selectedIndex;

		lastSelectNitemID = m_MultiSellInfoList[m_nSelectedMultiSellInfoIndex].MultiSellInfoID;
	}	
}

function OnCancelBtnClick()
{
	Clear();
	Me.HideWindow();
}

function OnHide()
{
	Me.KillTimer(DelaySelectedTimerID);
	lastSelectNitemID = 0;
}

function HandleDialogOK()
{
	local string param;
	local int SelectedIndex;

	if( DialogIsMine() )
	{
		SelectedIndex = DialogGetReservedInt();

		if( SelectedIndex >= m_MultiSellInfoList.Length )
		{
			//debug("MultiSellWnd::HandleDialogOK - Invalid SelectIndex(" $ SelectedIndex $ ")" );
			return;
		}
		
		ParamAdd( param, "MultiSellGroupID",		string( m_MultiSellGroupID ) );
		ParamAdd( param, "MultiSellInfoID",			string( m_MultiSellInfoList[SelectedIndex].MultiSellInfoID ) );
		ParamAdd( param, "ItemCount",				string( DialogGetReservedInt2() ) );
		ParamAdd( param, "Enchant",					string( m_MultiSellInfoList[SelectedIndex].ResultItemInfo.Enchanted ) );
		ParamAdd( param, "RefineryOp1",				string( m_MultiSellInfoList[SelectedIndex].ResultItemInfo.RefineryOp1 ) );
		ParamAdd( param, "RefineryOp2",				string( m_MultiSellInfoList[SelectedIndex].ResultItemInfo.RefineryOp2 ) );
		ParamAdd( param, "AttrAttackType",			string( m_MultiSellInfoList[SelectedIndex].ResultItemInfo.AttackAttributeType ) );
		ParamAdd( param, "AttrAttackValue",			string( m_MultiSellInfoList[SelectedIndex].ResultItemInfo.AttackAttributeValue ) );
		ParamAdd( param, "AttrDefenseValueFire",	string( m_MultiSellInfoList[SelectedIndex].ResultItemInfo.DefenseAttributeValueFire ) );
		ParamAdd( param, "AttrDefenseValueWater",	string( m_MultiSellInfoList[SelectedIndex].ResultItemInfo.DefenseAttributeValueWater ) );
		ParamAdd( param, "AttrDefenseValueWind",	string( m_MultiSellInfoList[SelectedIndex].ResultItemInfo.DefenseAttributeValueWind ) );
		ParamAdd( param, "AttrDefenseValueEarth",	string( m_MultiSellInfoList[SelectedIndex].ResultItemInfo.DefenseAttributeValueEarth ) );
		ParamAdd( param, "AttrDefenseValueHoly",	string( m_MultiSellInfoList[SelectedIndex].ResultItemInfo.DefenseAttributeValueHoly ) );
		ParamAdd( param, "AttrDefenseValueUnholy",	string( m_MultiSellInfoList[SelectedIndex].ResultItemInfo.DefenseAttributeValueUnholy ) );

		//ParamAdd( param, "Attribution",	string( m_MultiSellInfoList[SelectedIndex].ResultItemInfo.Attribution ) );

		addParamEnsoulOptionInfo(m_MultiSellInfoList[SelectedIndex].ResultItemInfo, param); 

		// RequestMultiSellChoose( param );
		// Debug("-----------집혼 정보 추가 param" @ param);

		RequestMultiSellChoose( param );

		//Me.HideWindow();	// 랜덤 멀티셀의 경우 뽑기식 아이템 교환이라
							// 아이템 교환을 누를 때마다 창이 닫히면 불편할 수 있다는
							// ttp 48532번에 따라 수정 - jumper
	}
}

function OnEvent(int Event_ID, string param)
{	
	switch( Event_ID )
	{
		case EV_NewMultiSellInfoListBegin:
			//Debug("EV_NewMultiSellInfoListBegin: " @ param);
			HandleMultiSellInfoListBegin( param );
			break;

		case EV_NewMultiSellResultItemInfo:
			HandleMultiSellResultItemInfo( param );
			break;

		case EV_NewMultiSellOutputItemInfo:
			HandelMultiSellOutputItemInfo( param );
			break;

		case EV_NewMultiSellInputItemInfo:
			HandelMultiSellInputItemInfo( param );
			break;

		case EV_NewMultiSellInfoListEnd:
			HandleMultiSellInfoListEnd( param );
			break;

		case EV_DialogOK:
			HandleDialogOK();
			break;

		case EV_AdenaInvenCount:
			 if (Me.IsShowWindow()) needItemUpdate(lastSelectIndex); 
			 break;

		default:
			break;
	};
}


/**
 * 상품 받기 시작.
 */
function HandleMultiSellInfoListBegin( string param )
{
	Clear();
	ParseInt( param, "MultiSellGroupID", m_MultiSellGroupID );
}


function HandleMultiSellResultItemInfo( string param)
{
	local int		nMultiSellInfoID;
	local int		nBuyType;
	local ItemInfo	info;

	// 신규 집혼 적용
	local int       ensoulNormalSlot, ensoulBmSlot;
	
	// Debug( "HandleMultiSellResultItemInfo>>" $ param );

	ParseInt( param, "MultiSellInfoID",			nMultiSellInfoID );
	ParseInt( param, "BuyType",					nBuyType );
	ParseInt( param, "Enchant",					info.Enchanted );
	ParseInt( param, "RefineryOp1",				info.RefineryOp1 );
	ParseInt( param, "RefineryOp2",				info.RefineryOp2 );
	ParseInt( param, "AttrAttackType",			info.AttackAttributeType );
	ParseInt( param, "AttrAttackValue",			info.AttackAttributeValue );
	ParseInt( param, "AttrDefenseValueFire",	info.DefenseAttributeValueFire );
	ParseInt( param, "AttrDefenseValueWater",	info.DefenseAttributeValueWater );
	ParseInt( param, "AttrDefenseValueWind",	info.DefenseAttributeValueWind );
	ParseInt( param, "AttrDefenseValueEarth",	info.DefenseAttributeValueEarth );
	ParseInt( param, "AttrDefenseValueHoly",	info.DefenseAttributeValueHoly );
	ParseInt( param, "AttrDefenseValueUnholy",	info.DefenseAttributeValueUnholy );

	// 신규 집혼 추가 (2015-03-09)
	ParseInt( param, "EnsoulOptionNum_" $ EIST_BM    , ensoulBmSlot );
	ParseInt( param, "EnsoulOptionNum_" $ EIST_NORMAL, ensoulNormalSlot );

	// 아이템에 집혼 정보를 적용 시킴
	addEnsoulInfo(EIST_BM     , ensoulBmSlot, param, info);
	addEnsoulInfo(EIST_NORMAL , ensoulNormalSlot, param, info);

	
	m_nCurrentMultiSellInfoIndex = m_MultiSellInfoList.Length;
	m_MultiSellInfoList.Length = m_nCurrentMultiSellInfoIndex + 1;
	
	m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].MultiSellInfoID	= nMultiSellInfoID;
	m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].MultiSellType		= nBuyType;
	m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].ResultItemInfo	= info;
}


function HandelMultiSellOutputItemInfo( string param )
{
	local int		nMultiSellInfoID;
	local int		nCurrentOutputItemInfoIndex;
	local ItemInfo	info;
	local int		nItemClassID;
	local int       Per;

	// 신규 집혼 적용
	local int       ensoulNormalSlot, ensoulBmSlot;

	// Debug( "HandelMultiSellOutputItemInfo : " $ param );

	ParseItemID( param, info.ID );
	class'UIDATA_ITEM'.static.GetItemInfo( info.ID, info );
	ParseInt( param, "ClassID",					nItemClassID );
	ParseInt( param, "MultiSellInfoID",			nMultiSellInfoID );
	ParseInt64( param, "SlotBitType",			info.SlotBitType ); // INT -> INT64, JEWEL 추가 - by y2jinc (2013. 9. 2)
	ParseInt( param, "ItemType",				info.ItemType );
	ParseInt64( param, "ItemCount",				info.ItemNum);
	ParseInt( param, "Enchant",					info.Enchanted );
	ParseInt( param, "RefineryOp1",				info.RefineryOp1);
	ParseInt( param, "RefineryOp2",				info.RefineryOp2);
	ParseInt( param, "AttrAttackType",			info.AttackAttributeType );
	ParseInt( param, "AttrAttackValue",			info.AttackAttributeValue );
	ParseInt( param, "AttrDefenseValueFire",	info.DefenseAttributeValueFire );
	ParseInt( param, "AttrDefenseValueWater",	info.DefenseAttributeValueWater );
	ParseInt( param, "AttrDefenseValueWind",	info.DefenseAttributeValueWind );
	ParseInt( param, "AttrDefenseValueEarth",	info.DefenseAttributeValueEarth );
	ParseInt( param, "AttrDefenseValueHoly",	info.DefenseAttributeValueHoly );
	ParseInt( param, "AttrDefenseValueUnholy",	info.DefenseAttributeValueUnholy );

		// 추가ttp 66923 
	ParseInt( param, "Attribution",         	info.Attribution );

	Parseint( param, "Probability",             Per );

	// 신규 집혼 추가 (2015-03-09)
	ParseInt( param, "EnsoulOptionNum_" $ EIST_BM    , ensoulBmSlot );
	ParseInt( param, "EnsoulOptionNum_" $ EIST_NORMAL, ensoulNormalSlot );

	// 아이템에 집혼 정보를 적용 시킴
	addEnsoulInfo(EIST_BM     , ensoulBmSlot, param, info);
	addEnsoulInfo(EIST_NORMAL , ensoulNormalSlot, param, info);


	if(m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].MultiSellInfoID != nMultiSellInfoID)
	{
		//debug("MultiSellWnd::HandelMultiSellOutputItemInfo - Invalid nMultiSellInfoID");
		return;
	}

	if( nItemClassID == -300 )
	{
		info.Name = GetSystemString( 102 );
		info.IconName = "icon.pvp_point_i00";
		info.Enchanted = 0;
		info.ItemType = -1;
		info.Id.ClassID = 0;
	}

	// 투영병기의 경우 강제로, 100% Durability를 표시하게 합니다 - NeverDie
	if( 0 < info.Durability )
	{
		info.CurrentDurability = info.Durability;
	}

	nCurrentOutputItemInfoIndex = m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].OutputItemInfoList.Length;
	m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].Per.Length = nCurrentOutputItemInfoIndex + 1;
	m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].Per[nCurrentOutputItemInfoIndex] = Per;

	m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].Param.Length = nCurrentOutputItemInfoIndex + 1;
	m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].Param[nCurrentOutputItemInfoIndex] = Param;

	m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].OutputItemInfoList.Length = nCurrentOutputItemInfoIndex + 1;	
	m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].OutputItemInfoList[nCurrentOutputItemInfoIndex] = info;
}


function HandelMultiSellInputItemInfo( string param )
{
	local int		nMultiSellInfoID;
	local int		nCurrentInputItemInfoIndex;
	local int		nItemClassID;
	local ItemInfo	info;

	// 신규 집혼 적용
	local int       ensoulNormalSlot, ensoulBmSlot;

	// Debug(":::::::::::: HandelMultiSellInputItemInfo>>>" @ param);

	ParseItemID( param, info.Id );
	class'UIDATA_ITEM'.static.GetItemInfo( info.Id, info );

	ParseInt( param, "MultiSellInfoID",			nMultiSellInfoID );
	ParseInt( param, "ClassID",					nItemClassID );
	ParseInt( param, "ItemType",				info.ItemType );
	ParseInt64( param, "ItemCount",				info.ItemNum);
	ParseInt( param, "Enchant",					info.Enchanted );
	ParseInt( param, "RefineryOp1",				info.RefineryOp1);
	ParseInt( param, "RefineryOp2",				info.RefineryOp2);
	ParseInt( param, "AttrAttackType",			info.AttackAttributeType );
	ParseInt( param, "AttrAttackValue",			info.AttackAttributeValue );
	ParseInt( param, "AttrDefenseValueFire",	info.DefenseAttributeValueFire );
	ParseInt( param, "AttrDefenseValueWater",	info.DefenseAttributeValueWater );
	ParseInt( param, "AttrDefenseValueWind",	info.DefenseAttributeValueWind );
	ParseInt( param, "AttrDefenseValueEarth",	info.DefenseAttributeValueEarth );
	ParseInt( param, "AttrDefenseValueHoly",	info.DefenseAttributeValueHoly );
	ParseInt( param, "AttrDefenseValueUnholy",	info.DefenseAttributeValueUnholy );

	// 추가ttp 66923 
	ParseInt( param, "Attribution",         	info.Attribution );

	// 신규 집혼 추가 (2015-03-09)
	ParseInt( param, "EnsoulOptionNum_" $ EIST_BM    , ensoulBmSlot );
	ParseInt( param, "EnsoulOptionNum_" $ EIST_NORMAL, ensoulNormalSlot );

	//Debug("ensoulBmSlot" @ ensoulBmSlot);
	//Debug("ensoulBmSlot" @ ensoulNormalSlot);

	// 아이템에 집혼 정보를 적용 시킴
	addEnsoulInfo(EIST_BM     , ensoulBmSlot, param, info);
	addEnsoulInfo(EIST_NORMAL , ensoulNormalSlot, param, info);

	if(m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].MultiSellInfoID != nMultiSellInfoID)
	{
		//debug("MultiSellWnd::HandelMultiSellInputItemInfo - Invalid nMultiSellInfoID");
		return;
	}
	
	if( nItemClassID == -100 )
	{
		info.Name = GetSystemString(1277);
		info.IconName = GetPcCafeItemIconPackageName();//"icon.etc_i.etc_pccafe_point_i00";
		info.Enchanted = 0;
		info.ItemType = -1;
		info.Id.ClassID = 0;
	}
	else if( nItemClassID == -200 )
	{
		info.Name = GetSystemString( 1311 );
		info.IconName = "icon.etc_i.etc_bloodpledge_point_i00";
		info.Enchanted = 0;
		info.ItemType = -1;
		info.Id.ClassID = 0;
	}
	else if( nItemClassID == -300 )
	{
		info.Name = GetSystemString( 102 );
		info.IconName = "icon.pvp_point_i00";
		info.Enchanted = 0;
		info.ItemType = -1;
		info.Id.ClassID = 0;
	}
	else
	{
		info.Name = class'UIDATA_ITEM'.static.GetItemName( info.Id );
		//if (info.Enchanted > 0) info.Name = "+" $ String(info.Enchanted) @ GetEnsoulOptionNameAll(info);
		//else info.Name = GetEnsoulOptionNameAll(info);

		//Debug("GetEnsoulOptionNameAll(info);" @ GetEnsoulOptionNameAll(info));
		//info.IconName = class'UIDATA_ITEM'.static.GetItemTextureName( info.Id );
	}

	info.ItemType = class'UIDATA_ITEM'.static.GetItemDataType( info.Id );
	info.CrystalType = class'UIDATA_ITEM'.static.GetItemCrystalType( info.Id );
	
	//-400 필드사이클일 경우 아무 데이터도 삽입하지 안ㅅ는 식으로 처리 함. 
	if (nItemClassID != -400 )
	{
		nCurrentInputItemInfoIndex = m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].InputItemInfoList.Length;
		m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].InputItemInfoList.Length = nCurrentInputItemInfoIndex + 1;
		m_MultiSellInfoList[m_nCurrentMultiSellInfoIndex].InputItemInfoList[nCurrentInputItemInfoIndex] = info;
	}
}

function HandleMultiSellInfoListEnd( string param )
{
	local WindowHandle m_inventoryWnd;
	
	//인벤토리
	m_inventoryWnd = GetWindowHandle( "InventoryWnd" );
	
	//인벤토리 창이 열려있으면 닫아준다. 
	if( m_inventoryWnd.IsShowWindow() )			
	{
		m_inventoryWnd.HideWindow();
	}	
	
	ShowWindow("TokenTradeWnd");
	class'UIAPI_WINDOW'.static.SetFocus("TokenTradeWnd");
	ShowItemList();
}

function ShowItemList()
{
	local ItemInfo info;
	local int i;
	local string TREENAME;
	local bool bDrawBgTree;
	local string setTreeName;
	local string strRetName;

	local string itemAllName;
	
	TREENAME = "TokenTradeWnd.ItemTypeTree";
	TreeClear( TREENAME );

	//Root 노드 생성.
	util.TreeInsertRootNode( TREENAME, "Root", "", 0, 0 );
	setTreeName = "Root";	

	for( i=0 ; i < m_MultiSellInfoList.Length ; ++i )
	{
		info = m_MultiSellInfoList[i].OutputItemInfoList[0];
	
		strRetName = util.TreeInsertItemTooltipSimpleNode( TREENAME, string(i), setTreeName, -7, 0, 38, 0, 30, 38 );

		if( bDrawBgTree )
		{
			//Insert Node Item - 아이템 배경?
			util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_CH3.etc.textbackline", 245, 38, , , , ,14 );
		}
		else
		{
			util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_CT1.EmptyBtn", 245, 38 );
		}
		bDrawBgTree = !bDrawBgTree;

		//Insert Node Item - 아이템슬롯 배경
		util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_ct1.ItemWindow.ItemWindow_df_slotbox_2x2", 36, 36, -244, 2);
		//Insert Node Item - 아이템 아이콘
		util.TreeInsertTextureNodeItem( TREENAME, strRetName, info.IconName, 32, 32, -34, 3 );
		//Insert Node Item - 아이템 이름
		//util.TreeInsertTextNodeItem( TREENAME, strRetName, info.Name, 5, 12, util.ETreeItemTextType.COLOR_DEFAULT, true );

		if (info.Enchanted > 0) itemAllName = "+" $ String(info.Enchanted) @ info.Name @ info.AdditionalName @ GetEnsoulOptionNameAll(info);
		else itemAllName = info.Name @ info.AdditionalName @ GetEnsoulOptionNameAll(info);

		 util.TreeInsertTextMultiNodeItem( TREENAME, strRetName, itemAllName, 4, 0, 38, util.ETreeItemTextType.COLOR_DEFAULT );
		//util.TreeInsertTextMultiNodeItem( TREENAME, strRetName, goodsName, 4, 0, 38, util.ETreeItemTextType.COLOR_DEFAULT );
		//Insert Node Item - 아이템 이름
		//util.TreeInsertTextNodeItem( TREENAME, strRetName, info.AdditionalName, 5, 12, util.ETreeItemTextType.COLOR_YELLOW, true );		
		//util.TreeInsertTextMultiNodeItem( TREENAME, strRetName, info.AdditionalName, 5, 12, util.ETreeItemTextType.COLOR_YELLOW );		

		 if (lastSelectNitemID == m_MultiSellInfoList[i].MultiSellInfoID)
		 {
			lastSelectIndex = i;
		 }
	}

	// 저장된 상태를 복원 
	if (lastSelectNitemID > 0 && lastSelectIndex > 0)
	{		
		ItemTypeTree.SetExpandedNode( "Root." $ lastSelectIndex, true );
		
		Me.SetTimer(DelaySelectedTimerID, DelayTimer);
		// SelectChangeItem(selectIndex);
	}
	else
	{
		//처음꺼 선택.
		ItemTypeTree.SetExpandedNode( "Root.0", true );
		SelectChangeItem(0);
	}
}

function OnTimer(int TimerID)
{
	if (TimerID == DelaySelectedTimerID)
	{
		SelectChangeItem(lastSelectIndex);
		Me.KillTimer(DelaySelectedTimerID);
	}
}

function SelectChangeItem( int num )
{
	local ItemInfo info;

	local LVDataRecord Record;


	local string strParam;

	////트리 배경용.
	//local bool bDrawBgTree;
	////Tree 이름.
	//local string TREENAME;

	//local string setTreeName;
	//local string strRetName;

	////보유 아이템 string
	//local string strNeed;

	local int i, ensoulBmSlot, ensoulNormalSlot;
	local string enchantedStr;


	TradePossibleListCtrl.DeleteAllItem();

	for( i=1 ; i < m_MultiSellInfoList[num].OutputItemInfoList.Length ; ++i )
	{
		info = m_MultiSellInfoList[num].OutputItemInfoList[i];

		if( info.Enchanted <= 0 )
		{
			enchantedStr = "";
		}
		else
		{
			enchantedStr = "+" $ string(info.Enchanted) $ " ";
		}

		//Debug( "NEW???" $ param );
		//ParseString(param, "iconName", iconName);
		//ParseString(param, "name", itemName);
		
		//multisell 716
		strParam = m_MultiSellInfoList[num].Param[i];

		// Debug("------------------------------------------------------------------");
		// Debug(strParam);
		//무기용 툴팁
		ParamAdd(strParam, "name", info.Name );
		ParamAdd(strParam, "WeaponType", string(info.WeaponType) );
		ParamAdd(strParam, "Enchanted", string(info.Enchanted) );
		ParamAdd(strParam, "Weight", string(info.Weight) );
		ParamAdd(strParam, "Description", info.Description );
		ParamAdd(strParam, "IconName", info.IconName );
		ParamAdd(strParam, "SoulshotCount", string(info.SoulshotCount) );
		ParamAdd(strParam, "SpiritshotCount", string(info.SpiritshotCount) );
		ParamAdd(strParam, "CrystalType", string(info.CrystalType) );
		ParamAdd(strParam, "AdditionalName", info.AdditionalName );
		
		//branch121212
		ParamAdd(strParam,"pAttack", String(info.pAttack));
		ParamAdd(strParam,"mAttack", String(info.mAttack));
		
		ParamAdd(strParam,"pCriRate", String(info.pCriRate));
		ParamAdd(strParam,"mCriRate", String(info.mCriRate));
		//end of branch
		
		ParamAdd(strParam, "pAttackSpeed", String(info.pAttackSpeed) );
		ParamAdd(strParam, "mAttackSpeed", String(info.mAttackSpeed) );
		//ParamAdd(strParam, "PhysicalAttackSpeed", info.PhysicalAttackSpeed );

		//debug( info.Description );

		//방어구용 툴팁
		ParamAdd(strParam, "pDefense", string(info.pDefense) );
		ParamAdd(strParam, "ShieldDefense", string(info.ShieldDefense) );
		ParamAdd(strParam, "pAvoid", string(info.pAvoid) );
		ParamAdd(strParam, "ArmorType", string(info.ArmorType) );

		// 마법 저항 추가
		ParamAdd(strParam, "mDefense", string(info.mDefense) );
		
		// 추가ttp 66923 
		ParamAdd( strParam, "Attribution",         string(info.Attribution));

		// 신규 집혼 추가 (2015-03-09)
		ParseInt( strParam, "EnsoulOptionNum_" $ EIST_BM    , ensoulBmSlot );
		ParseInt( strParam, "EnsoulOptionNum_" $ EIST_NORMAL, ensoulNormalSlot );

		// 아이템에 집혼 정보를 적용 시킴
		addEnsoulInfo(EIST_BM     , ensoulBmSlot    , strParam, info);
		addEnsoulInfo(EIST_NORMAL , ensoulNormalSlot, strParam, info);

		// 해당 아이템 정보 리스트에 넣을때꺼내올수 있도록 기억
		Record.szReserved = strParam;

		// 레코드 구성
		Record.LVDataList.length = 2;

		// 아이템 이름 
		if (info.Enchanted > 0) 
		{
			Record.LVDataList[0].szData = "+" $ String(info.Enchanted) @ info.Name @ 
										  info.AdditionalName @ GetEnsoulOptionNameAll(info);
		}
		else
		{
			Record.LVDataList[0].szData = info.Name @ info.AdditionalName @ GetEnsoulOptionNameAll(info);
		}

		// Record.LVDataList[0].szData = enchantedStr $ info.Name $ " " $ info.AdditionalName;

		Record.LVDataList[0].hasIcon = true;
		Record.LVDataList[0].nTextureWidth=32;
		Record.LVDataList[0].nTextureHeight=32;
		Record.LVDataList[0].nTextureU=32;
		Record.LVDataList[0].nTextureV=32;
		Record.LVDataList[0].szTexture = info.IconName; 
		Record.LVDataList[0].IconPosX=4;
		Record.LVDataList[0].FirstLineOffsetX=6;
		
		// 패널
		Record.LVDataList[0].iconBackTexName="l2ui_ct1.ItemWindow_DF_SlotBox_Default";
		Record.LVDataList[0].backTexOffsetXFromIconPosX=-2;
		Record.LVDataList[0].backTexOffsetYFromIconPosY=-1;
		Record.LVDataList[0].backTexWidth=36;
		Record.LVDataList[0].backTexHeight=36;
		Record.LVDataList[0].backTexUL=36;
		Record.LVDataList[0].backTexVL=36;

		Record.LVDataList[0].attrColor.R=170;
		Record.LVDataList[0].attrColor.G=170;
		Record.LVDataList[0].attrColor.B=170;
		Record.LVDataList[0].attrStat[0] = "x" $ string(info.ItemNum);	

		Record.LVDataList[1].buseTextColor = True;

		if( m_MultiSellInfoList[num].Per[i] > 30 )
		{
			Record.LVDataList[1].TextColor = util.Token0;
			Record.LVDataList[1].szData = GetSystemString(1234);			
		}
		else if( m_MultiSellInfoList[num].Per[i] <= 30 && m_MultiSellInfoList[num].Per[i] >=11 )
		{	
			Record.LVDataList[1].TextColor = util.Token1;
			Record.LVDataList[1].szData = GetSystemString(225);
		}
		else if( m_MultiSellInfoList[num].Per[i] <= 10 && m_MultiSellInfoList[num].Per[i] >=5 )
		{
			Record.LVDataList[1].TextColor = util.Token2;
			Record.LVDataList[1].szData = GetSystemString(1236);
		}
		else
		{
			Record.LVDataList[1].TextColor = util.Token3;
			Record.LVDataList[1].szData = GetSystemString(1237);
		}

		Record.LVDataList[1].textAlignment=TA_Center;
		TradePossibleListCtrl.InsertRecord( Record );
	}

	needItemUpdate(num);

	/*
	예전 Tree List로 바뀌기전.
	local int i;
	local string TREENAME;
	local bool bDrawBgTree;
	local string setTreeName;
	local string strRetName;
	*/

	//TradePossibleListCtrl

	/*
	TREENAME = "TokenTradeWnd.TradePossibleTree";
	TreeClear( TREENAME );

	//Roots 노드 생성.
	util.TreeInsertRootNode( TREENAME, "List", "", 0, 2 );
	setTreeName = "List";

	for( i=1 ; i < m_MultiSellInfoList[num].OutputItemInfoList.Length ; ++i )
	{
		info = m_MultiSellInfoList[num].OutputItemInfoList[i];

		//strRetName = util.TreeInsertItemTooltipSimpleNode( TREENAME, string(i), setTreeName, -7, 0, 38, 0, 30, 38 );
		strRetName = util.TreeInsertItemNode( TREENAME, string(i), setTreeName, false, -4, -2 );

		if( bDrawBgTree )
		{
			//Insert Node Item - 아이템 배경?
			util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_CH3.etc.textbackline", 244, 38, , , , ,14 );
		}
		else
		{
			util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_CT1.EmptyBtn", 244, 38 );
		}
		bDrawBgTree = !bDrawBgTree;

		//Insert Node Item - 아이템슬롯 배경
		util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_ct1.ItemWindow.ItemWindow_df_slotbox_2x2", 36, 36, -238, 2 );
		//Insert Node Item - 아이템 아이콘
		util.TreeInsertTextureNodeItem( TREENAME, strRetName, info.IconName, 32, 32, -34, 3 );

		if( info.Enchanted != 0 )
		{
			//Insert Node Item - 아이템 이름
			util.TreeInsertTextNodeItem( TREENAME, strRetName, "+"$string(info.Enchanted)$" "$info.Name, 5, 6, util.ETreeItemTextType.COLOR_DEFAULT, true, ,info.Id.ClassID );
		}
		else
		{
			//Insert Node Item - 아이템 이름			
			util.TreeInsertTextNodeItem( TREENAME, strRetName, info.Name, 5, 6, util.ETreeItemTextType.COLOR_DEFAULT, true, ,info.Id.ClassID );
		}	

		//Insert Node Item - 아이템 이름
		//util.TreeInsertTextNodeItem( TREENAME, strRetName, GetSystemString(2651) $ " " $ string(m_MultiSellInfoList[num].Per[i]), 46, -17, util.ETreeItemTextType.COLOR_GRAY, true, true );
		util.TreeInsertTextNodeItem( TREENAME, strRetName, GetSystemString(2651) $ " ", 46, -17, util.ETreeItemTextType.COLOR_GRAY, true, true );

		if( m_MultiSellInfoList[num].Per[i] > 30 )
		{
			util.TreeInsertTextNodeItem( TREENAME, strRetName, GetSystemString(1234), 0, -17, util.ETreeItemTextType.TOKEN0 );
		}
		else if( m_MultiSellInfoList[num].Per[i] <= 30 && m_MultiSellInfoList[num].Per[i] >=11 )
		{			
			util.TreeInsertTextNodeItem( TREENAME, strRetName, GetSystemString(225), 0, -17, util.ETreeItemTextType.TOKEN1 );
		}
		else if( m_MultiSellInfoList[num].Per[i] <= 10 && m_MultiSellInfoList[num].Per[i] >=5 )
		{
			util.TreeInsertTextNodeItem( TREENAME, strRetName, GetSystemString(1236), 0, -17, util.ETreeItemTextType.TOKEN2 );
		}
		else
		{
			util.TreeInsertTextNodeItem( TREENAME, strRetName, GetSystemString(1237), 0, -17, util.ETreeItemTextType.TOKEN3 );
		}
	}
	*/



	//Debug( "m_MultiSellInfoList[num].InputItemInfoList.Length" $ string(m_MultiSellInfoList[num].InputItemInfoList.Length) );
	
	//infoNeed = m_MultiSellInfoList[num].InputItemInfoList[0];
	//NeedItemIcon.SetTexture( infoNeed.IconName );
	//NeedItemNameText.SetText( infoNeed.Name );
	//NeedItemNumberText.SetText( "x" $ string( infoNeed.ItemNum ) );
}

function needItemUpdate(int num)
{
	//트리 배경용.
	local bool bDrawBgTree;
	//Tree 이름.
	local string TREENAME;

	local string setTreeName;
	local string strRetName;

	//보유 아이템 string
	local string strNeed;

	//필요 아이템.
	local ItemInfo infoNeed, tempInfo;

	local int i;
	
	TREENAME = "TokenTradeWnd.NeedItemTree";
	TreeClear( TREENAME );

	//Root 노드 생성.
	util.TreeInsertRootNode( TREENAME, "Need", "", 0, 2 );
	setTreeName = "Need";	

	for( i=0 ; i < m_MultiSellInfoList[num].InputItemInfoList.Length ; ++i )
	{
		infoNeed = m_MultiSellInfoList[num].InputItemInfoList[i];
	
		strRetName = util.TreeInsertItemNode( TREENAME, string(i), setTreeName, false, -6, -2);//, 38, 0, 30, 38 );
		if( bDrawBgTree )
		{
			//Insert Node Item - 아이템 배경?
			util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_CH3.etc.textbackline", 545, 38, , , , ,14 );
		}
		else
		{
			util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_CT1.EmptyBtn", 545, 38 );
		}
		bDrawBgTree = !bDrawBgTree;

		//Insert Node Item - 아이템슬롯 배경
		util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_ct1.ItemWindow.ItemWindow_df_slotbox_2x2", 36, 36, -538, 2 );

		switch ( infoNeed.Id.ClassID )
		{
			case 57:
				//아데나 일 경우
				//Insert Node Item - 아이템 아이콘
				util.TreeInsertTextureNodeItem( TREENAME, strRetName, infoNeed.IconName, 32, 32, -34, 3 );
				//Insert Node Item - 아이템 이름
				//[퀘스트 아이템 툴팁 추가] 퀘스트 아이템에 툴팁을 표시하기 위한 item class id를 저장.
				util.TreeInsertTextNodeItem( TREENAME, strRetName, infoNeed.Name, 5, 6, util.ETreeItemTextType.COLOR_DEFAULT, true );
			
				//아데나 양
				//아이템 개수			
				strNeed = "x" $ string( infoNeed.ItemNum ) $ " / " $ GetSystemString(2035) $ " " $ GetInventoryItemCount( infoNeed.Id );				
				util.TreeInsertTextNodeItem( TREENAME, strRetName, strNeed, 48, -18, util.ETreeItemTextType.COLOR_GRAY, ,true );
				
				//미정
				/*
				if ( rewardNumList[i] == 0 )
					util.TreeInsertTextNodeItem( TREENAME, strRetName, GetSystemString(584), 48, -18, util.ETreeItemTextType.COLOR_GOLD, ,true );
				else 
					util.TreeInsertTextNodeItem( TREENAME, strRetName, MakeFullSystemMsg(GetSystemMessage(2932), string(rewardNumList[i]),""), 48, -18, util.ETreeItemTextType.COLOR_GOLD, , true );
				*/
				break;

			default:
				//Insert Node Item - 아이템 아이콘
				util.TreeInsertTextureNodeItem( TREENAME, strRetName, infoNeed.IconName, 32, 32, -34, 3 );

				class'UIDATA_ITEM'.static.GetItemInfo(GetItemID(infoNeed.Id.ClassID), tempInfo);	
				
				Debug("tempInfo.IconPanel:" @ infoNeed.Id.ClassID);
				Debug("tempInfo.IconPanel:" @ tempInfo.IconPanel);

				if (tempInfo.IconPanel != "")
				{
					util.TreeInsertTextureNodeItem( TREENAME, strRetName, tempInfo.IconPanel, 32, 32, -34, 3 );
					Debug("패널 적용 :" @ tempInfo.IconPanel);
				}
				
				//Insert Node Item - 아이템 이름
				//[퀘스트 아이템 툴팁 추가] 퀘스트 아이템에 툴팁을 표시하기 위한 item class id를 저장.
				util.TreeInsertTextNodeItem( TREENAME, strRetName, infoNeed.Name @ infoNeed.AdditionalName, 5, 6, util.ETreeItemTextType.COLOR_DEFAULT, true, , infoNeed.Id.ClassID );

				//아이템 개수			
				strNeed = "x" $ string( infoNeed.ItemNum ) $ " / " $ GetSystemString(2035) $ " " $ GetInventoryItemCount( infoNeed.Id );				
				util.TreeInsertTextNodeItem( TREENAME, strRetName, strNeed, 48, -18, util.ETreeItemTextType.COLOR_GRAY, ,true );

				/*
				//미정
				if (rewardNumList[i] == 0)
					util.TreeInsertTextNodeItem( TREENAME, strRetName, GetSystemString(584), 48, -18, util.ETreeItemTextType.COLOR_GOLD, ,true );
				*/
		}
		
	}
}

// 트리 비우기
function TreeClear( string str )
{
	class'UIAPI_TREECTRL'.static.Clear( str );	
}

/**
 * 트리, 변수, 텍스트, 텍스쳐 등등 초기화.
 */
function Clear()
{
	TreeClear("TokenTradeWnd.ItemTypeTree");
	TreeClear("TokenTradeWnd.NeedItemTree");
	//TreeClear("TokenTradeWnd.TradePossibleTree");
	TradePossibleListCtrl.DeleteAllItem();
	m_nCurrentMultiSellInfoIndex = 0;
	m_MultiSellInfoList.Length = 0;
	m_MultiSellGroupID = 0;


	//NeedItemIcon.SetTexture( "L2UI_CT1.Misc.Misc_DF_Blank" );
	//NeedItemNameText.SetText( "" );
	//NeedItemNumberText.SetText( "" );
}

// 신규 집혼 관련 데이타 추가
function addEnsoulInfo(int slotType, int slotCount, string param, out ItemInfo info)
{
	local int n, nEOptionID;

	for(n = EISI_START; n < slotCount + EISI_START; n++)
	{
		ParseInt(param, "EnsoulOptionID_" $ slotType $ "_" $ n, nEOptionID);

		info.EnsoulOption[slotType - 1].OptionArray[n - EISI_START] = nEOptionID;
	}
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	OnCancelBtnClick();
}
defaultproperties
{
}
