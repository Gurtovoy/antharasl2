class TradeWnd extends UICommonAPI;

const DIALOG_ID_TRADE_REQUEST = 323;
const DIALOG_ID_ITEM_NUMBER = 324;

var string m_WindowName;
var L2Util util;
function OnRegisterEvent()
{
	registerEvent( EV_DialogOK );
	registerEvent( EV_DialogCancel );

	registerEvent( EV_TradeStart );
	registerEvent( EV_TradeAddItem );
	registerEvent( EV_TradeDone );
	registerEvent( EV_TradeOtherOK );
	registerEvent( EV_TradeUpdateInventoryItem );
	registerEvent( EV_TradeRequestStartExchange );
}

function OnLoad()
{	
	SetClosingOnESC();

//	if(CREATE_ON_DEMAND==0)
	OnRegisterEvent();
}

function onShow()
{ 
	// 지정한 윈도우를 제외한 닫기 기능 
	getInstanceL2Util().ItemRelationWindowHide(getCurrentWindowName(String(self)));
}

function OnSendPacketWhenHiding()
{
	RequestTradeDone( false );
}

function OnHide()
{
	Clear();
}

function OnEvent( int eventID, string param )
{
	//debug("eventID " $ eventID $ ", param : " $ param );
	switch( eventID )
	{
		case EV_TradeStart:
			HandleStartTrade(param);
			break;
		case EV_TradeAddItem:
			HandleTradeAddItem(param);
			break;
		case EV_TradeDone:
			HandleTradeDone(param);
			break;
		case EV_TradeOtherOK:
			HandleTradeOtherOK(param);
			break;
		case EV_TradeUpdateInventoryItem:
			HandleTradeUpdateInventoryItem(param);
			break;
		case EV_TradeRequestStartExchange:
			HandleReceiveStartTrade(param);
			break;
		case EV_DialogOK:
			HandleDialogOK();
			break;
		case EV_DialogCancel:
			// debug("-- DialogCancel DIALOG_ID_TRADE_REQUEST");
			HandleDialogCancel();
			break;
		default:
			break;
	};
}

function OnClickButton( string ControlName )
{
	//debug("ControlName : " $ ControlName);
	if( ControlName == "OKButton" )
	{
		// 교환 수락.
		class'UIAPI_ITEMWINDOW'.static.SetFaded( "TradeWnd.MyList", true );
		RequestTradeDone( true );
		DialogHide();
		//HideWindow( "TradeWnd" );
	}
	else if( ControlName == "CancelButton" )
	{
		RequestTradeDone( false );
		DialogHide();
		//HideWindow( "TradeWnd" );
	}
	else if( ControlName == "MoveButton" )
	{
		HandleMoveButton();
	}
}

function OnDBClickItem( string ControlName, int index )
{
	local ItemInfo info;
	if(ControlName == "InventoryList")	// remove the item from InventoryList and move it to MyList
	{
		if( class'UIAPI_ITEMWINDOW'.static.GetItem("TradeWnd.InventoryList", index, info) )
		{
			if( IsStackableItem( info.ConsumeType ) &&  (info.ItemNum!=1))		// stackable? //1개면 수량입력창을 띄우지 않는다.
			{
				DialogSetID( DIALOG_ID_ITEM_NUMBER );
				DialogSetReservedItemID( info.ID );	// ServerID
				DialogSetParamInt64( info.ItemNum );
				DialogShow(DialogModalType_Modalless, DialogType_NumberPad, MakeFullSystemMsg( GetSystemMessage(72), info.Name, "" ), string(Self) );
			}
			else
				RequestAddTradeItem( info.ID, 1 );
		}
	}
}

function OnDropItem( string strID, ItemInfo info, int x, int y)
{
	if( strID == "MyList" && info.DragSrcName == "InventoryList" )
	{
		if( IsStackableItem( info.ConsumeType ) )		// stackable?
		{
			if( info.AllItemCount > 0 )				// 전체이동
			{
				RequestAddTradeItem( info.ID, info.AllItemCount );
			}
			else if( info.ItemNum==1)
			{
				RequestAddTradeItem( info.ID, 1);
			}
			else
			{
				DialogSetID( DIALOG_ID_ITEM_NUMBER );
				DialogSetReservedItemID( info.ID );	// ServerID
				DialogSetParamInt64( info.ItemNum );
				DialogShow(DialogModalType_Modalless, DialogType_NumberPad, MakeFullSystemMsg( GetSystemMessage(72), info.Name, "" ), string(Self) );
			}
		}
		else
			RequestAddTradeItem( info.ID, 1 );
	}
}

function MoveToMyList( int index, INT64 num )
{
	local ItemInfo info;
	if( class'UIAPI_ITEMWINDOW'.static.GetItem("TradeWnd.InventoryList", index, info) )	// success returns true
	{
		RequestAddTradeItem( info.ID, num );
	}
}

function HandleMoveButton()
{
	local int selected;
	local ItemInfo info;
	selected = class'UIAPI_ITEMWINDOW'.static.GetSelectedNum("TradeWnd.InventoryList");
	if( selected >= 0 )
	{
		class'UIAPI_ITEMWINDOW'.static.GetItem("TradeWnd.InventoryList", selected, info);
		if( info.ItemNum == 1 )		// stackable??
			MoveToMyList(selected, 1);
		else 
		{
			DialogSetID( DIALOG_ID_ITEM_NUMBER );
			DialogSetReservedItemID( info.ID );	// ServerID
			DialogSetParamInt64( info.ItemNum );
			DialogShow(DialogModalType_Modalless, DialogType_NumberPad, MakeFullSystemMsg( GetSystemMessage(72), info.Name, "" ), string(Self) );
		}
	}
}

function HandleStartTrade( string param )
{
	local int targetID, targetLevel, isFriend, isPledge, isMentoring, isAlliance, isGM;	
	local UserInfo targetInfo;
	local string clanName, colorString, addStr, levelString;
	local string Name;
	local Rect itemWindowRect;

	//각종 윈도우 핸들을 얻어온다.
	//if(CREATE_ON_DEMAND==0)
	//{
	//	m_inventoryWnd = GetHandle( "InventoryWnd" );	//인벤토리
	//	m_warehouseWnd = GetHandle( "WarehouseWnd" );		//개인창고, 혈맹창고, 화물창고
	//	m_privateShopWnd = GetHandle( "PrivateShopWnd" );	//개인판매, 개인구매
	//	m_shopWnd = GetHandle( "ShopWnd" );				//상점구매, 판매
	//	m_multiSellWnd = GetHandle( "MultiSellWnd" );			//멀티셀
	//}
	//else
	//{
	//	m_inventoryWnd = GetWindowHandle( "InventoryWnd" );	//인벤토리
	//	m_warehouseWnd = GetWindowHandle( "WarehouseWnd" );		//개인창고, 혈맹창고, 화물창고
	//	m_privateShopWnd = GetWindowHandle( "PrivateShopWnd" );	//개인판매, 개인구매
	//	m_shopWnd = GetWindowHandle( "ShopWnd" );				//상점구매, 판매
	//	m_multiSellWnd = GetWindowHandle( "MultiSellWnd" );			//멀티셀
	//}
	/*
	if( m_inventoryWnd.IsShowWindow() )			//인벤토리 창이 열려있으면 닫아준다. 
	{
		m_inventoryWnd.HideWindow();
	}	
	if( m_warehouseWnd.IsShowWindow() )			//창고 창이 열려있으면 닫아준다. 
	{
		m_warehouseWnd.HideWindow();
	}	
	if( m_privateShopWnd.IsShowWindow() )		//개인상점 창이 열려있으면 닫아준다. 
	{
		m_privateShopWnd.HideWindow();
	}	
	if( m_shopWnd.IsShowWindow() )				//상점 창이 열려있으면 닫아준다. 
	{
		m_shopWnd.HideWindow();
	}
	if( m_multiSellWnd.IsShowWindow() )			//멀티셀 창이 열려있으면 닫아준다. 
	{
		m_multiSellWnd.HideWindow();
	}
	*/
	
	class'UIAPI_WINDOW'.static.ShowWindow("TradeWnd");
	class'UIAPI_WINDOW'.static.SetFocus("TradeWnd");

	ParseInt( param, "targetId",            targetID );
	ParseInt( param, "targetLevel",         targetLevel );
	ParseInt( param, "IsFriend",			isFriend );
	ParseInt( param, "IsPledge",			isPledge );
	ParseInt( param, "IsMentoring",         isMentoring );
	ParseInt( param, "IsAlliance",          isAlliance );
	ParseInt( param, "IsGM",                isGM );
	
	if( targetID > 0 )
	{
		GetUserInfo( targetID, targetInfo );
		if( targetInfo.nClanID > 0 )
		{
			clanName = GetClanName( targetInfo.nClanID );
			if (targetInfo.WantHideName &&  targetInfo.JoinedDominionID >0)
			{
				Name = targetInfo.RealName;
			}
			else
			{
				Name = targetInfo.Name;
			}

			if(clanName != "")
			{
				addStr = " - ";
			}
			else
			{
				addStr = "";
			}

			// debug ("With Clan Name" @ Name);
			class'UIAPI_TEXTBOX'.static.SetText( "TradeWnd.Targetname", Name $ addStr $ clanName );
		}
		else
		{
			if (targetInfo.WantHideName &&  targetInfo.JoinedDominionID >0)
			{
				Name = targetInfo.RealName;
			}
			else
			{
				Name = targetInfo.Name;
			}
			// debug ("Without Clan Name" @ Name);
			class'UIAPI_TEXTBOX'.static.SetText( "TradeWnd.Targetname", Name);		//혈맹이 없어도 이름을 표시해준다.
		}

		itemWindowRect = GetItemWindowHandle("TradeWnd.InventoryList").GetRect();   

		// 위에 아이템윈도우 사이즈로 "..." 말줄임을 넣는다. 
		GetTextBoxHandle("TradeWnd.Targetname").SetTextEllipsisWidth(itemWindowRect.nWidth);

		// 말줄임을 했으니, 툴팁으로 나오도록 한다. 
		GetTextBoxHandle("TradeWnd.Targetname").SetTooltipType("Text");
		GetTextBoxHandle("TradeWnd.Targetname").SetTooltipText(Name $ addStr $ clanName);

		//거래 사기 방지.
		//타겟 정보를 넣는다. 친구관계 동맹관계 등등
		if(isFriend != 0 || isPledge != 0 || isMentoring != 0 || isAlliance != 0 || isGM != 0)
		{
			//자신과 관계가 있는 사람이면 초록색으로 표시
			colorString = "Green";
		}
		else
		{
			//관계 없으면 빨간색
			colorString = "Red";
		}

		SetTooltipString(param);

		levelString = Left(colorString, 1) $ GetTargetLevelIconIndex( targetLevel );
		
		//지엠일 경우 다른 아이콘을 표시한다 배경도 초록색
		if(isGM != 0)
		{
			levelString = "GM";
			colorString = "Green";
		}

		//레벨 텍스쳐
		GetTextureHandle( "TradeWnd.ChatLevel" ).SetTexture("L2UI_CT1.ChatWindow.ChatLevelIcon_"$ levelString);
		//버튼 텍스쳐 색깔
		GetButtonHandle("TradeWnd.ChatLevelIcon_Btn").SetTexture("L2UI_CT1.ChatWindow.ChatLevelIcon_Btn"$colorString, "L2UI_CT1.ChatWindow.ChatLevelIcon_Btn"$colorString$"_down", "L2UI_CT1.ChatWindow.ChatLevelIcon_Btn"$colorString$"_over");
	}
}

function SetTooltipString(string param)
{
	local CustomTooltip T;
	local string charName;
	local int isFriend, isGM, isPledge, isAlliance, isMentoring;
	
	T.MinimumWidth = 125;
	util = L2Util(GetScript("L2Util"));//bluesun 커스터마이즈 툴팁 
	util.setCustomTooltip(T);//bluesun 커스터마이즈 툴팁


	ParseString(param, "CharName",      charName);
	ParseInt( param,   "IsFriend",		isFriend );
	ParseInt( param,   "IsPledge",		isPledge );
	ParseInt( param,   "IsMentoring",   isMentoring );
	ParseInt( param,   "IsAlliance",    isAlliance );
	ParseInt( param,   "IsGM",          isGM );
	
	//친구
	if(isFriend != 0)
	{
		util.ToopTipInsertTitleContents(GetSystemString(2273), GetSystemString(3175), 77, 255, 99, true, true, true);
	}
	else
	{
		util.ToopTipInsertTitleContents(GetSystemString(2273), GetSystemString(3176), 255, 66, 66, true, true, true);
	}
	
	//혈맹
	if(isPledge != 0)
	{
		util.ToopTipInsertTitleContents(GetSystemString(314), GetSystemString(3179), 77, 255, 99, true, true, false);
	}
	else
	{
		util.ToopTipInsertTitleContents(GetSystemString(314), GetSystemString(3180), 255, 66, 66, true, true, false);
	}
		

	//멘토
	if(isMentoring != 0 && !getInstanceUIData().getIsClassicServer())
	{
		util.ToopTipInsertTitleContents(GetSystemString(2767), GetSystemString(3177), 77, 255, 99, true, true, false);
	}
	else if ( !getInstanceUIData().getIsClassicServer() )
	{
		util.ToopTipInsertTitleContents(GetSystemString(2767), GetSystemString(3178), 255, 66, 66, true, true, false);
	}
		
	
	//동맹
	if(isAlliance != 0)
	{
		util.ToopTipInsertTitleContents(GetSystemString(490), GetSystemString(3181), 77, 255, 99, true, true, false);
	}
	else
	{
		util.ToopTipInsertTitleContents(GetSystemString(490), GetSystemString(3182), 255, 66, 66, true, true, false);
	}

	GetButtonHandle("TradeWnd.ChatLevelIcon_Btn").SetTooltipCustomType(util.getCustomTooltip());
}

function string GetTargetLevelIconIndex(int userLevel)
{
	local int num;
	
	num = userLevel / 10;

	if(num == 0) { return "01"; }
	else { return num $ "0"; }
	
	return "01";
}

function HandleTradeAddItem( string param )
{
	local string	strDest;
	local ItemInfo	itemInfo;
	//local ItemInfo	tempInfo;
	local int		index;

	ParseString( param, "destination", strDest );

	ParamToItemInfo( param, itemInfo );
	if( strDest == "inventoryList" )
	{
		strDest = "TradeWnd.InventoryList";
	}
	else if( strDest == "myList" )
	{
		strDest = "TradeWnd.MyList";
		class'UIAPI_INVENWEIGHT'.static.ReduceWeight( "TradeWnd.InvenWeight", itemInfo.ItemNum * itemInfo.Weight );
		//debug("AddWeight " $ itemInfo.ItemNum * itemInfo.Weight );
	}
	else if( strDest == "otherList" )
	{
		strDest = "TradeWnd.OtherList";
		class'UIAPI_INVENWEIGHT'.static.AddWeight( "TradeWnd.InvenWeight", itemInfo.ItemNum * itemInfo.Weight );
		//debug("ReduceWeight " $ itemInfo.ItemNum * itemInfo.Weight );
	}

	index = class'UIAPI_ITEMWINDOW'.static.FindItem( strDest, itemInfo.ID );	// ServerID
	//debug( "HandleTradeAddItem " $ strDest $ ", index " $ index );
	if( index >= 0 )
	{
		if( IsStackableItem( ItemInfo.ConsumeType ) )
		{
			//class'UIAPI_ITEMWINDOW'.static.GetItem( strDest, index, tempInfo );
			//itemInfo.ItemNum += tempInfo.ItemNum;
			class'UIAPI_ITEMWINDOW'.static.SetItem( strDest, index, itemInfo );
		}
		// 아이템이 이미 있고 수량성 아이템도 아니라면 아무것도 하지 않는다.
	}
	else
	{
		class'UIAPI_ITEMWINDOW'.static.AddItem( strDest, itemInfo );
	}
}

// 교환이 끝났음
function HandleTradeDone( string param )
{
	class'UIAPI_WINDOW'.static.HideWindow("TradeWnd");
}

// 다른 쪽에서 OK 버튼을 눌러서 더이상 변경할 수 없음. 상대방의 아이템 리스트를 변경 불가 상태로 변경.
function HandleTradeOtherOK( string param )
{
	class'UIAPI_ITEMWINDOW'.static.SetFaded( "TradeWnd.OtherList", true );
}

// 아이템을 옮기거나 할때 자신의 인벤토리 상황을 업데이트 한다.
function HandleTradeUpdateInventoryItem( string param )
{
	local ItemInfo info;
	local string type;
	local int	index;

	ParseString( param, "type", type );
	ParamToItemInfo( param, info );
	if( type == "add" )
	{
		class'UIAPI_ITEMWINDOW'.static.AddItem( "TradeWnd.InventoryList", info );
	}
	else if( type == "update" )
	{
		index = class'UIAPI_ITEMWINDOW'.static.FindItem( "TradeWnd.InventoryList", info.ID );	// ServerID
		if( index >= 0 )
			class'UIAPI_ITEMWINDOW'.static.SetItem( "TradeWnd.InventoryList", index, info );
	}
	else if( type == "delete" )
	{
		index = class'UIAPI_ITEMWINDOW'.static.FindItem( "TradeWnd.InventoryList", info.ID );	// ServerID
		if( index >= 0 )
			class'UIAPI_ITEMWINDOW'.static.DeleteItem( "TradeWnd.InventoryList", index );
	}
}

function HandleReceiveStartTrade( string param )
{
	local int targetID;
	local UserInfo info;
	local string Name;
	local bool bOption;

	bOption = GetOptionBool( "Communication", "IsRejectingTrade" );
	ParseInt( param, "targetID", targetID );

	if (bOption == true)
	{
		// 옵션에서 거부 상태를 체크 해놓으면 취소한 것으로 보낸다.		
		AnswerTradeRequest( false );
	}
	else if( targetID > 0 && GetUserInfo( targetID, info ) )
	{
		if ( IsShowWindow("DialogBox"))
		{
			RequestTradeDone(false);
			return;
		}
		if (info.WantHideName &&  info.JoinedDominionID >0)
		{
			Name = info.RealName;
		}
		else
		{
			Name =  info.Name;
		}		
		DialogSetID( DIALOG_ID_TRADE_REQUEST );
		DialogSetCancelD(DIALOG_ID_TRADE_REQUEST);
		DialogSetParamInt64( 10*1000 );			// 10 seconds  
		DialogSetEnterDoNothing();
		DialogShow(DialogModalType_Modalless, DialogType_Progress, MakeFullSystemMsg(GetSystemMessage(100), Name, "" ), string(Self) );
	}
}

function HandleDialogOK()
{
	local ItemID sID;
	local INT64 num;
	if( DialogIsMine() )
	{
		if( DialogGetID() == DIALOG_ID_TRADE_REQUEST )
		{
			AnswerTradeRequest( true );
		}
		else if( DialogGetID() == DIALOG_ID_ITEM_NUMBER )
		{
			sID = DialogGetReservedItemID();
			num = INT64( DialogGetString() );
			RequestAddTradeItem( sID, num );
		}
	}
}



function HandleDialogCancel()
{
	//if(DialogIsMine())
	//{
	//	if (DialogIsProgressBarWorking())
	//	{			
	//		if(DialogProgressCancelDialogID() == DIALOG_ID_TRADE_REQUEST)
	//		{
	//			AnswerTradeRequest( false );
	//		}
	//	}
	//}

	if(DialogIsMine())
	{
		if(DialogCheckCancelByID(DIALOG_ID_TRADE_REQUEST))
		{
			AnswerTradeRequest( false );
		}
	}
}

function Clear()
{
	class'UIAPI_ITEMWINDOW'.static.Clear( "TradeWnd.InventoryList" );
	class'UIAPI_ITEMWINDOW'.static.Clear( "TradeWnd.MyList" );
	class'UIAPI_ITEMWINDOW'.static.Clear( "TradeWnd.OtherList" );
	class'UIAPI_TEXTBOX'.static.SetText( "TradeWnd.TargetName", "" );
	class'UIAPI_INVENWEIGHT'.static.ZeroWeight( "TradeWnd.InvenWeight" );
	DialogHide();
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	AnswerTradeRequest( false );
	class'UIAPI_WINDOW'.static.HideWindow(m_WindowName);		
}

defaultproperties
{
    m_WindowName="TradeWnd"
}
