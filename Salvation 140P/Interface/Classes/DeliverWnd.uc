class DeliverWnd extends UICommonAPI;

const DIALOG_TOP_TO_BOTTOM = 111;
const DIALOG_BOTTOM_TO_TOP = 222;

var		int		m_targetID;

function OnRegisterEvent()
{
	registerEvent( EV_DeliverOpenWindow );
	registerEvent( EV_DeliverAddItem );
	registerEvent( EV_DialogOK );
}


function onShow()
{
	// 지정한 윈도우를 제외한 닫기 기능 
	getInstanceL2Util().ItemRelationWindowHide(getCurrentWindowName(String(self)));
}
 

function OnLoad()
{
	SetClosingOnESC();

	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();
}

function Clear()
{
	class'UIAPI_ITEMWINDOW'.static.Clear("DeliverWnd.TopList");
	class'UIAPI_ITEMWINDOW'.static.Clear("DeliverWnd.BottomList");

	class'UIAPI_TEXTBOX'.static.SetText("DeliverWnd.PriceText", "0");
	class'UIAPI_TEXTBOX'.static.SetTooltipString("DeliverWnd.PriceText", "");

	class'UIAPI_TEXTBOX'.static.SetText("DeliverWnd.AdenaText", "0");
	class'UIAPI_TEXTBOX'.static.SetTooltipString("DeliverWnd.AdenaText", "");
}

function OnEvent(int Event_ID,string param)
{
	switch( Event_ID )
	{
	case EV_DeliverOpenWindow:
		//debug ("EV_DeliverOpenWindow");
		HandleOpenWindow(param);
		break;
	case EV_DeliverAddItem:
		//debug ("EV_DeliverAddItem");
		HandleAddItem(param);
		break;
	case EV_DialogOK:
		//debug ("EV_DialogOK");
		HandleDialogOK();
		break;
	default:
		break;
	}
}

function OnClickButton( string ControlName )
{
	local int index;
	if( ControlName == "UpButton" )
	{
		index = class'UIAPI_ITEMWINDOW'.static.GetSelectedNum( "DeliverWnd.BottomList" );
		MoveItemBottomToTop( index, 0 );
	}
	else if( ControlName == "DownButton" )
	{
		index = class'UIAPI_ITEMWINDOW'.static.GetSelectedNum( "DeliverWnd.TopList" );
		MoveItemTopToBottom( index, 0 );
	}
	else if( ControlName == "OKButton" )
	{
		HandleOKButton();
	}
	else if( ControlName == "CancelButton" )
	{
		Clear();
		HideWindow("DeliverWnd");
	}
}

function OnDBClickItem( string ControlName, int index )
{
	if(ControlName == "TopList")
	{
		MoveItemTopToBottom( index, 0 );
	}
	else if(ControlName == "BottomList")
	{
		MoveItemBottomToTop( index, 0 );
	}
}

// 아이템을 클릭하였을 경우 (더블클릭 아님)
function OnClickItem( string ControlName, int index )
{
	local WindowHandle m_dialogWnd;

	if(CREATE_ON_DEMAND==0)
		m_dialogWnd = GetHandle( "DialogBox" );
	else
		m_dialogWnd = GetWindowHandle( "DialogBox" );

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
	if( strID == "TopList" && info.DragSrcName == "BottomList" )
	{
		index = class'UIAPI_ITEMWINDOW'.static.FindItem( "DeliverWnd.BottomList", info.ID );
		if( index >= 0 )
			MoveItemBottomToTop( index, info.AllItemCount );
	}
	else if( strID == "BottomList" && info.DragSrcName == "TopList" )
	{
		index = class'UIAPI_ITEMWINDOW'.static.FindItem( "DeliverWnd.TopList", info.ID );
		if( index >= 0 )
			MoveItemTopToBottom( index, info.AllItemCount );
	}
}

function MoveItemTopToBottom( int index, int64 allItemCount )
{
	local ItemInfo info;
	if( class'UIAPI_ITEMWINDOW'.static.GetItem("DeliverWnd.TopList", index, info) )
	{
		if( IsStackableItem( info.ConsumeType ) && (info.ItemNum>1))		// stackable?
		{
			if ( allItemCount > 0 )
			{
				ItemTopToBottom ( info.ID, allItemCount );
				AdjustPrice();	//branch
			}
			else
			{
				DialogSetID( DIALOG_TOP_TO_BOTTOM );
				DialogSetReservedItemID( info.ID );
				DialogSetParamInt64( info.ItemNum );
				DialogSetDefaultOK();
				DialogShow(DialogModalType_Modalless, DialogType_NumberPad, MakeFullSystemMsg( GetSystemMessage(72), info.Name, "" ), string(Self) );
			}			
		}
		else
		{
			info.ItemNum = 1;
			info.bShowCount = false;
			class'UIAPI_ITEMWINDOW'.static.AddItem( "DeliverWnd.BottomList", info );
			class'UIAPI_ITEMWINDOW'.static.DeleteItem( "DeliverWnd.TopList", index );		// 물건을 팔 경우 자신의 인벤토리 목록에서 아이템을 제거

			AdjustPrice();
		}
	}
}

function MoveItemBottomToTop( int index, INT64 allItemCount )
{
	local ItemInfo info;
	if( class'UIAPI_ITEMWINDOW'.static.GetItem("DeliverWnd.BottomList", index, info) )
	{
		if( IsStackableItem( info.ConsumeType ) && (info.ItemNum>INT64(1)))		// stackable?
		{
			if ( allItemCount>0 )
			{
				ItemBottomToTop ( info.ID, allItemCount );
				AdjustPrice();	//branch
			}
			else
			{
				DialogSetID( DIALOG_BOTTOM_TO_TOP );
				DialogSetReservedItemID( info.ID );
				DialogSetParamInt64( info.ItemNum );
				DialogSetDefaultOK();
				DialogShow(DialogModalType_Modalless, DialogType_NumberPad, MakeFullSystemMsg( GetSystemMessage(72), info.Name, "" ), string(Self) );
			}			
		}
		else
		{
			class'UIAPI_ITEMWINDOW'.static.DeleteItem( "DeliverWnd.BottomList", index );
			class'UIAPI_ITEMWINDOW'.static.AddItem( "DeliverWnd.TopList", info );
			AdjustPrice();
		}
	}
}

function HandleDialogOK()
{
	local int id;
	local INT64 num;
	local ItemID cID;
	
	if( DialogIsMine() )
	{
		id = DialogGetID();
		num = INT64( DialogGetString() );
		cID = DialogGetReservedItemID();
		
		if( id == DIALOG_TOP_TO_BOTTOM && num>0  )
		{
			ItemTopToBottom ( cID, num );
		}
		else if( id == DIALOG_BOTTOM_TO_TOP && num>0  )
		{
			ItemBottomToTop( cID, num );
		}
		AdjustPrice();
	}
}

function ItemTopToBottom( ItemID cID, INT64 num )
{
	local int index, topIndex;
	local ItemInfo info, topInfo;
	
	topIndex = class'UIAPI_ITEMWINDOW'.static.FindItem( "DeliverWnd.TopList", cID );
	if( topIndex >= 0 )
	{
		class'UIAPI_ITEMWINDOW'.static.GetItem( "DeliverWnd.TopList", topIndex, topInfo );
		index = class'UIAPI_ITEMWINDOW'.static.FindItem( "DeliverWnd.BottomList", cID );
		if( index >= 0 )
		{
			class'UIAPI_ITEMWINDOW'.static.GetItem( "DeliverWnd.BottomList", index, info );
			info.ItemNum += num;
			class'UIAPI_ITEMWINDOW'.static.SetItem( "DeliverWnd.BottomList", index, info );
		}
		else
		{
			info = topInfo;
			info.ItemNum = num;
			info.bShowCount = false;
			class'UIAPI_ITEMWINDOW'.static.AddItem( "DeliverWnd.BottomList", info );
		}

		topInfo.ItemNum -= num;
		if( topInfo.ItemNum<=0 )
			class'UIAPI_ITEMWINDOW'.static.DeleteItem( "DeliverWnd.TopList", topIndex );
		else
			class'UIAPI_ITEMWINDOW'.static.SetItem( "DeliverWnd.TopList", topIndex, topInfo );
	}
}

function ItemBottomToTop( ItemID cID, INT64 num )
{
	local int index, topIndex;
	local ItemInfo info, topInfo;
	
	index = class'UIAPI_ITEMWINDOW'.static.FindItem( "DeliverWnd.BottomList", cID );
	if( index >= 0 )
	{
		class'UIAPI_ITEMWINDOW'.static.GetItem( "DeliverWnd.BottomList", index, info );
		info.ItemNum -= num;
		if( info.ItemNum>0 )
			class'UIAPI_ITEMWINDOW'.static.SetItem( "DeliverWnd.BottomList", index, info );
		else 
			class'UIAPI_ITEMWINDOW'.static.DeleteItem( "DeliverWnd.BottomList", index );

		topIndex = class'UIAPI_ITEMWINDOW'.static.FindItem( "DeliverWnd.TopList", cID );
		if( topIndex >=0 && IsStackableItem( info.ConsumeType ) )
		{
			class'UIAPI_ITEMWINDOW'.static.GetItem( "DeliverWnd.TopList", topIndex, topInfo );
			topInfo.ItemNum += num;
			class'UIAPI_ITEMWINDOW'.static.SetItem( "DeliverWnd.TopList", topIndex, topInfo );
		}
		else
		{
			info.ItemNum = num;
			class'UIAPI_ITEMWINDOW'.static.AddItem( "DeliverWnd.TopList", info );
		}
	}
}

function HandleOpenWindow( string param )
{
	local INT64 adena;
	local string adenaString;
	local WindowHandle m_inventoryWnd;


	if(CREATE_ON_DEMAND==0)
		m_inventoryWnd = GetHandle( "InventoryWnd" );	//인벤토리의 윈도우 핸들을 얻어온다.
	else
		m_inventoryWnd = GetWindowHandle( "InventoryWnd" );	//인벤토리의 윈도우 핸들을 얻어온다.

	Clear();
	ParseINT64( param, "adena", adena );
	ParseInt( param, "destinationID", m_targetID );

	adenaString = MakeCostString( string(adena) );
	class'UIAPI_TEXTBOX'.static.SetText("DeliverWnd.AdenaText", adenaString);
	class'UIAPI_TEXTBOX'.static.SetTooltipString("DeliverWnd.AdenaText", ConvertNumToText(string(adena)) );

	// if( m_inventoryWnd.IsShowWindow() )			//인벤토리 창이 열려있으면 닫아준다. 
	// {
	//	m_inventoryWnd.HideWindow();
	// }

	ShowWindow("DeliverWnd");
	class'UIAPI_WINDOW'.static.SetFocus("DeliverWnd");
}

function HandleAddItem( string param )
{
	local ItemInfo info;
	
	ParamToItemInfo( param, info );
	class'UIAPI_ITEMWINDOW'.static.AddItem( "DeliverWnd.TopList", info );
}

function AdjustPrice()
{
	local string adena;
	local int count;
	count = class'UIAPI_ITEMWINDOW'.static.GetItemNum( "DeliverWnd.BottomList" );
	adena = MakeCostString( string(count * 1000) );
	class'UIAPI_TEXTBOX'.static.SetText("DeliverWnd.PriceText", adena);
	class'UIAPI_TEXTBOX'.static.SetTooltipString("DeliverWnd.PriceText", ConvertNumToText(string( count * 1000 )) );
}

function HandleOKButton()
{
	local string	param;
	local int		count, index;
	local ItemInfo	itemInfo;

	count = class'UIAPI_ITEMWINDOW'.static.GetItemNum( "DeliverWnd.BottomList" );
	// pack every item in BottomList
	ParamAdd( param, "targetID", string(m_targetID) );
	ParamAdd( param, "num", string(count) );
	for( index=0 ; index < count; ++index )
	{
		class'UIAPI_ITEMWINDOW'.static.GetItem( "DeliverWnd.BottomList", index, itemInfo );
		ParamAdd( param, "dbID" $ index, string(itemInfo.Reserved) );
		ParamAdd( Param, "count" $ index, string(itemInfo.ItemNum) );
	}

	RequestPackageSend( param );

	HideWindow("DeliverWnd");
}


/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	OnClickButton( "CancelButton" );	
}
defaultproperties
{
}
