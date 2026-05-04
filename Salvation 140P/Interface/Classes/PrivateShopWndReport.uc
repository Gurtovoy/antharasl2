/***
 *   개인 상점 리포트
 **/
class PrivateShopWndReport extends UICommonAPI;

var WindowHandle Me;

var L2Util       util;

var ListCtrlHandle ItemList_ListCtrl;
var ButtonHandle   Edit_Btn;
var ButtonHandle   StopSell_Btn;
var ButtonHandle   EditorSetting_Btn;
var ButtonHandle   history_Btn;

// 아이템 정렬용 index 
//var int itemIndex;

// 얻은 아이템 목록
var array<ItemInfo>	getItemInfoArray;
// 판매, 구매한 아이템 개수
var array<int64> getItemNumArray;
//// 아이템 가격 
//var array<int64> getItemPriceArray;

// 팔기 전 처음 아이템 개수( 늘어나거나, 줄어든 개수만 체크 하면 되겠다. ) 
//var array<int64> firstItemNumArray;


// buy 인 경우 serverID가 다름, inventory addItem 이 들어 올 때 까지 잠시 들고 있음
var array<int>buyItemServerIDArray ;
var array<int64>buyItemNumArray ;
var array<String>buyUserNameArray;


var InventoryWnd  inventoryWndScript;


var EditBoxHandle SignEditInput_Edit;
var TextBoxHandle SignEditInput_Txt;
var TextBoxHandle SignEditInput_guide;

var TextBoxHandle privateShopTitle_Txt;
var TextBoxHandle Benefit_Input1_Txt;
var TextBoxHandle Benefit_Input2_Txt;

var TextBoxHandle BenefitTitle1_Txt ;
var TextBoxHandle BenefitTitle2_Txt ;

var  PrivateShopWnd privateShopScript ;

var string messageType;

const STRINGNUM_SALE_TITLE 		= 500;
const STRINGNUM_BUY_TITLE 		= 499;		
const STRINGNUM_SALE_BULK_TITLE = 1273;

var PrivateShopWndHistory PrivateShopWndHistoryScript;

//const DIALOG_EDIT_SHOP_MESSAGE  = 1234;


/*****************************************************************************
 * on 들
 ****************************************************************************/
function OnRegisterEvent()
{	
	RegisterEvent( EV_InventoryUpdateItem);
	//RegisterEvent( EV_DialogOK );
	RegisterEvent( EV_PrivateStoreBuyingResult );
	RegisterEvent( EV_PrivateStoreSellingResult );
}


function OnLoad()
{
	Initialize();
//	setDefaultShow(true);
}

function OnShow()
{
	messageType = getCurrentMessageType ();
	Edit_Btn.EnableWindow();
	updateList();
	setPrivateShopMessageText();
	Me.SetFocus();
}

function OnHide()
{
	init();
}

// OnClickButton
function OnClickButton( string Name )
{
	switch( Name )
	{		
		case "StopSell_Btn":
			 if ( !checkShoppingEnd() )  privateShopScript.stopSellFlag = true;
		case "Edit_Btn" :
			 handleQuit();
			 //OnStopSell_BtnClick();
			 break;
		case "history_Btn":
			Onhistory_BtnClick();
			break;
		case "EditorSetting_Btn":	
			togglePrivateShopEditor();
			break;
	}	
}

function OnLButtonDown( WindowHandle a_WindowHandle, int X, int Y )
{
	if ( a_WindowHandle == SignEditInput_guide || a_WindowHandle == SignEditInput_Txt ) 
		showPrivateShopEditor();
}


function onEvent ( int a_EventID, string a_Param ) 
{
	if ( ! Me.IsShowWindow() ) return;
	switch ( a_EventID ) {		
		case EV_InventoryUpdateItem :
			if ( buyItemServerIDArray.Length > 0 ) 				
				handleinventoryUpdateResult( a_Param ) ;
		break;
		//case EV_DialogOK :
		//	handleDialogOK () ;
		//break;
		case EV_PrivateStoreBuyingResult :		
			 handleBuyResult( a_Param ) ;
			 //Debug("onEvent EV_PrivateStoreBuyingResult " @ a_Param );
			 break;
		case EV_PrivateStoreSellingResult:
			 handleSellingResult( a_Param ) ;
			 //Debug("onEvent EV_PrivateStoreSellingResult " @ a_Param);
			 break;

	}
}


/*****************************************************************************
 * 초기화
 ****************************************************************************/
function Initialize()
{
	Me           = GetWindowHandle( "PrivateShopWndReport" );
	ItemList_ListCtrl = GetListCtrlHandle( "PrivateShopWndReport.ItemList_ListCtrl" );
	StopSell_Btn     = GetButtonHandle( "PrivateShopWndReport.StopSell_Btn" );
	Edit_Btn     = GetButtonHandle( "PrivateShopWndReport.Edit_Btn" );

	history_Btn     = GetButtonHandle( "PrivateShopWndReport.history_Btn" );

	EditorSetting_Btn     = GetButtonHandle( "PrivateShopWndReport.EditorSetting_Btn" );	

	util                = L2Util(GetScript("L2Util"));
	inventoryWndScript  = inventoryWnd(GetScript("inventoryWnd"));

	// 개인 상점 종류
	privateShopTitle_Txt     = GetTextBoxHandle( "PrivateShopWndReport.privateShopTitle_Txt" );

	// 내가 편집한 상점 제목
	SignEditInput_Txt = GetTextBoxHandle( "PrivateShopWndReport.SignEditInput_Txt" );
	// 상점 안내 메시지 
	SignEditInput_guide = GetTextBoxHandle( "PrivateShopWndReport.SignEditInput_guide" );
	// 편집 할 상점 제목	
	SignEditInput_Edit = GetEditBoxHandle( "PrivateShopWndReport.SignEditInput_Edit" );

	// 번돈??
	Benefit_Input1_Txt = GetTextBoxHandle( "PrivateShopWndReport.Benefit_Input1_Txt" );
	// 벌돈?? 
	Benefit_Input2_Txt = GetTextBoxHandle( "PrivateShopWndReport.Benefit_Input2_Txt" );

	BenefitTitle1_Txt = GetTextBoxHandle( "PrivateShopWndReport.BenefitTitle1_Txt" );
	BenefitTitle2_Txt = GetTextBoxHandle( "PrivateShopWndReport.BenefitTitle2_Txt" );

	PrivateShopWndHistoryScript = PrivateShopWndHistory(GetScript( "PrivateShopWndHistory" )) ;	

	ItemList_ListCtrl.SetSelectedSelTooltip(FALSE);	
	ItemList_ListCtrl.SetAppearTooltipAtMouseX(true);

	privateShopScript = PrivateShopWnd( GetScript ("PrivateShopWnd"));

	SignEditInput_guide.SetText ( GetSystemMessage( 334) ) ;

	init();
}


// 초기화
function init()
{
	//local DialogBox DialogBox;

	getItemInfoArray.Length = 0;
	getItemNumArray.Length = 0;

	buyItemServerIDArray.Length = 0; ;
	buyItemNumArray.Length = 0; ;
	buyUserNameArray.Length = 0 ;
	//itemIndex = 99999;
	ItemList_ListCtrl.DeleteAllItem();	

	//DialogBox = DialogBox(GetScript("DialogBox"));
	//if (class'UIAPI_WINDOW'.static.IsShowWindow("DialogBox"))
	//{
	//	if ( DialogIsMine() ) 
	//		DialogBox.HandleCancel();
	//}
	hidePrivateShopwEditor();
}


/*****************************************************************************
 * 아이템 갱신
 ****************************************************************************/

function handleBuyResult(string param ) 
{	
	local int serverId ; 
	local int64 amount;
	local string userName;
	
	parseInt ( param, "ItemID", serverId ) ;
	buyItemServerIDArray.Length = buyItemServerIDArray.Length + 1 ; ;
	buyItemServerIDArray[ buyItemServerIDArray.Length - 1 ] = serverId ;

	parseInt64 ( param, "Amount", amount ) ;	
	buyItemNumArray.Length = buyItemNumArray.Length + 1 ; 
	buyItemNumArray[ buyItemNumArray.Length - 1 ] = amount ;

	parseString ( param, "CharName", userName );
	buyUserNameArray.Length = buyUserNameArray.Length + 1 ;
	buyUserNameArray[buyUserNameArray.Length - 1] = userName;

}

function handleSellingResult( string param )
{	
	local int serverId ; 
	local int64 amount;
	local string userName;
	
	parseInt ( param, "ItemID", serverId ) ;
	parseInt64 ( param, "Amount", amount ) ;
	parseString ( param, "CharName", userName );

	findNModifyRecord ( serverId, amount, userName );
}

function handleinventoryUpdateResult( string param ) 
{
	local int count, i, index ;
	local itemInfo updatedItemInfo;
	local LVDataRecord Record;	
	local bool IsSame, isStackable;

	//ParseItemID(param, itemID);
	ParamToItemInfo( param, updatedItemInfo );

	// 서버 아이디 저장 된 수량 만큼 
	for ( i = 0 ; i < buyItemServerIDArray.Length ; i++ ) 
	{		
		if ( buyItemServerIDArray[i] == updatedItemInfo.ID.serverID ) 
		{
			// 레코드 리스트에서 찾아라. 
			for ( count = 0 ; count < ItemList_ListCtrl.GetRecordCount() ; count ++ ) 
			{
				ItemList_ListCtrl.GetRec( count , Record);
	
				index = int( Record.nReserved3 );
				// 다 팔리지 않았다면
				if ( getItemNumArray[index] != getItemInfoArray[index].itemNum ) 
				{	
					isStackable = IsStackableItem ( updatedItemInfo.ConsumeType );
					// 같은 클래스 아이디 확인
					if ( updatedItemInfo.ID.classID == getItemInfoArray[index].ID.classID  ) 
					{						
						if ( isStackable ) IsSame = true; 													
						else IsSame = compareItem ( getItemInfoArray[index], updatedItemInfo ) ; 
					}
					
					// 같은 아이템이면 처리하고 중단.
					if( IsSame ) 
					{
						Record = getModifyRecord ( Record, buyItemNumArray[i] ) ;
						
						ItemList_ListCtrl.ModifyRecord( count, Record );

						PrivateShopWndHistoryScript.addHistory( Record.LVDataList[0].szData, isStackable, buyItemNumArray[i], buyUserNameArray[i] ) ;			

						setCurrentTotalPrice();						

						buyItemServerIDArray.Remove( i , 1 ) ;
						buyItemNumArray.Remove( i , 1 ) ;
						buyUserNameArray.Remove( i, 1 ) ;

						if ( checkShoppingEnd() ) Edit_Btn.DisableWindow();
						
						//Debug ( "handleinventoryUpdateResult" @ buyItemServerIDArray.Length @ buyItemNumArray.length  ) ;
						return;
					}
				}
			}			
		}
	}
}

function LVDataRecord getModifyRecord ( LVDataRecord Record, int64 amount  ) 
{
	local int index ;

	index = int( Record.nReserved3 );

	getItemNumArray[index] = getItemNumArray[index] + amount ;	

	Record.LVDataList[0] = makeItemNameRecord( Record, getItemNumArray[index] );
	Record.LVDataList[1] = makeItemNumRecord( Record, getItemNumArray[index] );
	Record.LVDataList[2] = makeItemPriceRecord( Record, getItemNumArray[index] );
	Record.LVDataList[3] = makeItemTotalPrice( Record, getItemNumArray[index] );

	return Record;
}

function findNModifyRecord ( int serverID, int64 amount, string userName ) 
{
	local int count ;
	//local int64 numOfItem;
	local LVDataRecord Record;		
	getBuyItemInfo ( serverID ) ;
	for(count = 0 ; count < ItemList_ListCtrl.GetRecordCount(); count++)
	{	
		ItemList_ListCtrl.GetRec(count, Record);
		
		if ( Record.nReserved1 == serverID )
		{			
			Record = getModifyRecord ( Record, amount ) ;	

			ItemList_ListCtrl.ModifyRecord( count, Record );
			
			PrivateShopWndHistoryScript.addHistory( Record.LVDataList[0].szData, Record.LVDataList[2].hasIcon, amount, userName ) ;			

			setCurrentTotalPrice();

			if ( checkShoppingEnd() ) Edit_Btn.DisableWindow();

			return;
			//Debug ("step1" @ numOfItem @ info.itemNum @ info.ID.classID @ info.ID.serverID @ getItemInfoArray[index].ID.classID @ getItemInfoArray[index].ID.serverID @ IsStackableItem( info.ConsumeType ) @ compareItem( info, getItemInfoArray[index]) ) ;			
		}
	}
}

function  getBuyItemInfo ( int  serverID ) 
{
	local ItemInfo ResourceInfo;
	local itemID pItemID ;
	pItemID.serverID = serverID ;
	class'UIDATA_ITEM'.static.GetItemInfo(pItemID, ResourceInfo) ;
//	Debug ( "getBuyItemInfo" @ ResourceInfo.ID.classID ) ;
}

//아이템이 바뀜.
//function handleAddedItemInfo( string a_Param )
//{
//	local ItemInfo info;

//	// 필요한 정보 : 아이템 개수 클래스 아이디, 스태커블 타입
//	Debug ( "handleAddedItemInfo" @ a_Param ) ;
//	ParamToItemInfo ( a_Param, info ) ;
//	findNModifyRecord ( info );
//}   

//function int findIdx ( ItemInfo info ) 
//{
//	local int64 itemCount;
//	local int i;
//	for ( i = 0 ; i < getItemInfoArray.Length ; i++ )
//	{
//		if ( getItemInfoArray[i].ID.classID == info.ID.classID  ) 
//		{
//			itemCount = getAbs ( firstItemNumArray[i] - info.ItemNum );
			
//			// 다 사거나 팔리지 않았다면, index를 리턴
//			if ( getItemNumArray[i] != itemCount  ) 
//			{
//				getItemNumArray[i] = itemCount;
//				Debug ("findIdx" @ itemCount  @ firstItemNumArray[i] @ info.ItemNum);
//				return i ;
//			}
//		}
//	}
//	return -1;
//}


function startOpenPrivateShop( string param ) 
{
	Me.showWindow();
}

/***********************************************************************************
 * 타이틀 및 제목 관련 
 * **********************************************************************************/

/* 타이틀 */
function string getCurrentMessageType ()
{
	switch  (privateShopScript.m_type ) 
	{		
		case PT_SellList :
			if ( privateShopScript.m_bBulk )
			{
				return "bulksell";				
			}
			else 
			{
				return "sell";			
			}
		break;
		case PT_BuyList :
			return "buy";			
		break;
	}	
	return "" ;
}

function handleGuideMessage ( ) 
{
	if ( SignEditInput_Txt.GetText() == "" ) 
		SignEditInput_guide.ShowWindow();
	else SignEditInput_guide.HideWindow();
}

function togglePrivateShopEditor() 
{
	if ( SignEditInput_Edit.IsShowWindow() ) 
	{
		if ( GetPrivateShopMessage( messagetype ) != SignEditInput_Edit.GetString() && "" != SignEditInput_Edit.GetString() ) 
		{
			//Debug ("togglePrivateShopEditor" @  messageType @ SignEditInput_Edit.GetString() ) ;
			SetPrivateShopMessage( messageType, SignEditInput_Edit.GetString());
			SignEditInput_Txt.SetText ( SignEditInput_Edit.GetString() );
			handleGuideMessage();
		}

		hidePrivateShopwEditor();
	}
	else 
	{
		showPrivateShopEditor();
	}
}

function showPrivateShopEditor ( ) 
{
	//DialogSetDefaultOK();	
	//글자 25자 제한! 원래 25자 제한이었는데 진정이 폭주하여 29자로 늘림
	//DialogSetEditBoxMaxLength(29);	
	
	//DialogSetID( DIALOG_EDIT_SHOP_MESSAGE  );

	// 다이얼로그 창이 뜬 다음 스트링을 적용 시킨다.
	// 예전에는 edit 텍스트의 제한이 제대로 세팅 되지 않은 상태에서 스트링을 넣어서 문제가 생겨서 
	// 현재 고친 것이다.
	//DialogShow(DialogModalType_Modalless, DialogType_OKCancelInput, GetSystemMessage( 334 ), string(Self) );
	//DialogSetString(GetPrivateShopMessage( messagetype ));
	SignEditInput_Txt.hideWindow();
	SignEditInput_Edit.ShowWindow();
	
	SignEditInput_Edit.SetString(GetPrivateShopMessage( messagetype ) ) ;
	SignEditInput_Edit.SetFocus();	
	SignEditInput_guide.HideWindow();
	EditorSetting_Btn.SetTexture ( "L2UI_CT1.Button.completeBtn_df","L2UI_CT1.Button.completeBtn_down", "L2UI_CT1.Button.completeBtn_over" );
}

function hidePrivateShopwEditor () 
{
	SignEditInput_Txt.ShowWindow();
	SignEditInput_Edit.hideWindow();
	EditorSetting_Btn.SetTexture ( "L2UI_CT1.Button.SettingBtn_n", "L2UI_CT1.Button.SettingBtn_d", "L2UI_CT1.Button.SettingBtn_o" );
}

function setPrivateShopMessageText( )
{	
	local string shopTitle;
	local color messageColor;	
	
	switch ( messageType ) 
	{
		case "bulksell" :
			messageColor = getColor(255, 119, 119, 255);
			shopTitle = GetSystemString( STRINGNUM_SALE_BULK_TITLE );
			//ItemList_ListCtrl.SetColumnString(0, 137);
			//ItemList_ListCtrl.SetColumnString(1, 3597);
			ItemList_ListCtrl.SetColumnString(2, 2502);			
			ItemList_ListCtrl.SetColumnString(3, 3591) ;
			BenefitTitle1_Txt.SetText ( GetSystemString ( 3593 ));
			BenefitTitle2_Txt.SetText ( GetSystemString ( 3595 ));
		break;
		case "sell" :
			messageColor = getColor(221, 119, 238, 255);				
			shopTitle = GetSystemString( STRINGNUM_SALE_TITLE );
			//ItemList_ListCtrl.SetColumnString(0, 137);
			//ItemList_ListCtrl.SetColumnString(1, 3597);
			ItemList_ListCtrl.SetColumnString(2, 2502);
			ItemList_ListCtrl.SetColumnString(3, 3591);
			BenefitTitle1_Txt.SetText ( GetSystemString ( 3593 ));
			BenefitTitle2_Txt.SetText ( GetSystemString ( 3595 ));
		break;
		case "buy" :
			messageColor = getColor(170, 204, 17, 255);
			shopTitle = GetSystemString( STRINGNUM_BUY_TITLE );
			//ItemList_ListCtrl.SetColumnString(0, 137);
			//ItemList_ListCtrl.SetColumnString(1, 3597);
			ItemList_ListCtrl.SetColumnString(2, 3590);		
			ItemList_ListCtrl.SetColumnString(3, 3592);
			BenefitTitle1_Txt.SetText ( GetSystemString ( 3594 ));
			BenefitTitle2_Txt.SetText ( GetSystemString ( 3596 ));
		break;
	}
	
	privateShopTitle_Txt.SetText ( shopTitle );
	privateShopTitle_Txt.SetTextColor( messageColor ) ; 
	SignEditInput_Txt.SetTextColor( messageColor ) ;
	SignEditInput_Txt.SetText ( GetPrivateShopMessage( messagetype ) ) ;
	handleGuideMessage();
	//SignEditInput_Txt.SetTextColor( messageColor ) ;
}

//function handleDialogOK () 
//{
//	local int id;
//	id = DialogGetID();

//	if( DialogIsMine() )
//	{
//		switch ( id )
//		{
//			case DIALOG_EDIT_SHOP_MESSAGE :
//				SetPrivateShopMessage( messageType, DialogGetString() );

//				SignEditInput_Txt.SetText (  DialogGetString() ) ;

////				Debug ( messageType @ DialogGetString() @ GetPrivateShopMessage( messagetype ) );
//			break;
//		}
//	}
//}

/***********************************************************************************
 * 아이템을 더한다.
 * **********************************************************************************/
// 판매를 위해 추가된 아이템
function externalAddItem(ItemInfo addItemInfo)
{
	//local int64 currentItemCount ;
	local int len, i  ;	
	
	// 구매 시 가격이 다른 아이템을 여러개 올릴 수 있음, 가격 비교를 해야 함.
	if( privateShopScript.m_type == PT_BuyList ) 
	{		
		if ( !IsStackableItem ( addItemInfo.ConsumeType ) ) 
		{
			for ( i = 0 ; i <  getItemInfoArray.Length ; i ++ ) 
			{
				if ( getItemInfoArray[i].ID.classID == addItemInfo.ID.classID ) 
				{
					if ( compareItem( getItemInfoArray[i], addItemInfo ) )
					{					
						if ( addItemInfo.price != getItemInfoArray[i].price ) return ;
					}
				}
			}
		}
	}

	len = getItemInfoArray.Length + 1;
	getItemInfoArray.Length = len;
	getItemInfoArray[ len -1  ] = (addItemInfo);

	getItemNumArray.Length = len;
	getItemNumArray[ len - 1 ] = 0;
	
	//firstItemNumArray.Length = len;
	//firstItemNumArray[ len - 1 ] = inventoryWndScript.getItemCountByClassID ( addItemInfo.ID.classID ) ;
	//if ( !IsStackableItem( addItemInfo.ConsumeType) )firstItemNumArray[ len - 1 ] = 1;

	//Debug ( "externalAddItem" @ firstItemNumArray[ len - 1 ]  @ getItemInfoArray.Length  @ getItemNumArray.Length  @ firstItemNumArray.Length );

	if (Me.IsShowWindow()) updateList();
}

// 총 아이템 수량 
//function int getTotalItemCount()
//{
//	local int adenItem, itemLen;
//	local int i;
	
//	adenItem = 0;
//	itemLen = getItemInfoArray.Length;

//	// 아데나가 있나 검색
//	for(i = 0; i < itemLen; i++)
//	{
//		if(getItemInfoArray.Length > 0)
//		{
//			if(getItemInfoArray[i].Id.ClassID == 57)
//			{
//				// Debug("아데나 있음");
//				adenItem = -1;
//				break;
//			}
//		}
//	}

//	return getItemInfoArray.Length + adenItem;
//}

// 수량성 아이템인 경우 처리
//function sumStackableItem(ItemInfo addItemInfo)
//{
//	local int i;
//	local ItemInfo beforeItemInfo;
//	local bool bAdd;

//	for (i = 0; i < getItemInfoArray.Length; i++)
//	{
//		if (getItemInfoArray[i].ID.ClassID == addItemInfo.ID.ClassID)
//		{
//			inventoryWndScript.getInventoryItemInfo(addItemInfo.Id, beforeItemInfo, true);

//			// 빠진 경우도 update 이벤트로 오기 때문에 더해진 경우만..
//			if(beforeItemInfo.itemNum < addItemInfo.itemNum)		
//			{
//				addItemInfo.itemNum = getItemInfoArray[i].itemNum + (addItemInfo.itemNum - beforeItemInfo.itemNum);

//				getItemInfoArray.Remove(i, 1);

//				getItemInfoArray.Length = getItemInfoArray.Length + 1;
//				getItemInfoArray[ getItemInfoArray.Length - 1 ] = (addItemInfo);
//			}

//			bAdd = true;
//			break;
//		}
//	}

//	if(bAdd == false)
//	{
//		inventoryWndScript.getInventoryItemInfo(addItemInfo.Id, beforeItemInfo, true);

//		// 빠진 경우도 update 이벤트로 오기 때문에 더해진 경우만..
//		if(beforeItemInfo.itemNum < addItemInfo.itemNum)				
//		{
//			// 처음 들어 오는 수량성 아이템도 추가된 수량만 넣어야한다.
//			if (getItemInfoArray.Length > 0)
//			{
//				addItemInfo.itemNum = getItemInfoArray[i].itemNum + (addItemInfo.itemNum - beforeItemInfo.itemNum);
//			}
//			else
//			{
//				addItemInfo.itemNum = (addItemInfo.itemNum - beforeItemInfo.itemNum);
//			}

//			getItemInfoArray.Length = getItemInfoArray.Length + 1;
//			getItemInfoArray[ getItemInfoArray.Length - 1 ] = (addItemInfo);
//		}
//	}
//}


// 전체 목록 갱신 
function updateList()
{
	local int i;

	ItemList_ListCtrl.DeleteAllItem();
	
	if (getItemInfoArray.Length > 0)
	{
		for (i = 0 ; i < getItemInfoArray.Length ; i++)
		{
			// 아데나인 경우 리스트에 넣지 않음. (기획: 조희영)
			if(getItemInfoArray[i].Id.ClassID != 57)
			{
				addItem(i);
			}
		}
	}

	setCurrentTotalPrice();
}

// 현재 총 수익 과 남은 예상 수익 계산
function setCurrentTotalPrice() 
{
	local int count, index ;
	local int64 itemNum, price, currentPrice, totalprice ;
	local LVDataRecord Record;
	
	currentPrice = 0 ;
	totalprice = 0 ;

	for ( count = 0 ; count < ItemList_ListCtrl.GetRecordCount() ; count ++ ) 
	{
		ItemList_ListCtrl.GetRec(count, Record);

		index = int (Record.nReserved3);
		
		price = getItemInfoArray[ index ].price;
		itemNum = Record.nReserved2;
		
		currentPrice += getItemNumArray[index] * price ;
		totalprice += itemNum * price ;

		Benefit_Input1_Txt.SetText ( ConvertNumToTextNoAdena ( String ( currentPrice )));
		Benefit_Input2_Txt.SetText ( ConvertNumToTextNoAdena ( String ( totalprice - currentPrice )));
		if ( Benefit_Input1_Txt.GetText() == "" ) Benefit_Input1_Txt.SetText( "0");
		if ( Benefit_Input2_Txt.GetText() == "" ) Benefit_Input2_Txt.SetText( "0");
	}
}


// 아이템 총 가격 표시 
function LVData makeItemTotalPrice( LVDataRecord Record, int64 itemNum ) 
{
	local int64 price, totalPrice ;
	local string costString;
	
	price = getItemInfoArray[int(Record.nReserved3)].price ;
	
	totalPrice = price *  itemNum ;
	costString = MakeCostString( String ( totalPrice ) );	
	Record.LVDataList[3].buseTextColor = true;

	if ( itemNum == Record.nReserved2 )
	{	
		Record.LVDataList[3].TextColor = getColor(120, 120, 120, 255 ) ;
	}
	else 
		Record.LVDataList[3].textColor = GetNumericColor( costString );		

	Record.LVDataList[3].szData = ConvertNumToTextNoAdena ( String ( totalPrice ) );	
	
	return Record.LVDataList[3];
}

// 아이템 가격 표시 
function LVData makeItemPriceRecord( LVDataRecord Record, int64 itemNum ) 
{
	local int64 price, remainingItemNum, remainingItemPrice ;
	local string remainingString;
	
	if ( itemNum == Record.nReserved2 )
	{	
		Record.LVDataList[2].bUseTextColor = true;
		Record.LVDataList[2].TextColor = getColor(120, 120, 120, 255 ) ;
		Record.LVDataList[2].attrColor = Record.LVDataList[2].TextColor;
	}

	// 수량성 아이템이 아니면 판매 가격을 합계를 계산할 필요가 없음
	if ( Record.LVDataList[2].hasIcon ) 
	{
		price = getItemInfoArray[ int ( Record.nReserved3 ) ].price ;
		remainingItemNum = Record.nReserved2 - itemNum;
		remainingItemPrice = remainingItemNum * price; 


		if ( remainingItemNum == 0 ) 
			remainingString = "0";
		else
			remainingString = ConvertNumToTextNoAdena(String(remainingItemPrice));

		Record.LVDataList[2].attrStat[0] = MakeFullSystemMsg(GetSystemMessage(3657), remainingString);
	}

	return Record.LVDataList[2];
}

// 아이템 수량 표시 
function LVData makeItemNumRecord ( LVDataRecord Record, int64 itemNum ) 
{
	local string itemNumEasyRead;

	if(Record.nReserved2 > 9999) 
		itemNumEasyRead = "9999+";
	else 
		itemNumEasyRead = String(Record.nReserved2);

	if (itemNum > Record.nReserved2 ) itemNum = Record.nReserved2;
	
	// 수량 성인 경우 두 줄로 표시 되므로, ConsumeType == StackableItem 이다. 
	Record.LVDataList[1].szData = (Record.nReserved2 - itemNum) $"/"$itemNumEasyRead;	
	
	//if ( Record.LVDataList[2].hasIcon ) 	
	//	Record.LVDataList[1].szData = (Record.nReserved2 - itemNum) $"/"$itemNumEasyRead;	
	//else 	
	//	Record.LVDataList[1].szData = String(Record.nReserved2 - itemNum) ;
	
	//Record.LVDataList[1].HiddenStringForSorting = String(Record.nReserved2);	

	// 완료 시 메시지 변경 
	if ( itemNum == Record.nReserved2 )
	{
		Record.LVDataList[1].bUseTextColor = true;
		Record.LVDataList[1].TextColor = getColor(120, 120, 120, 255 ) ;
		Record.LVDataList[1].attrColor = Record.LVDataList[1].TextColor;

		if ( messageType == "buy" )  
			Record.LVDataList[1].attrStat[0] = GetSystemString( 3621 );	
		else 
			Record.LVDataList[1].attrStat[0] = GetSystemString( 3616 );	
	}
	else if ( messageType == "buy" ) 
		Record.LVDataList[1].attrStat[0] = GetSystemString(1434)$":"$itemNum;
	else 
		Record.LVDataList[1].attrStat[0] = GetSystemString(1157)$":"$itemNum;	
	
	
	return Record.LVDataList[1];
}


// 모두 판매 시 비활성 표시 
function LVData makeItemNameRecord ( LVDataRecord Record, int64 itemNum ) 
{
	if ( itemNum == Record.nReserved2 ) 
	{
		Record.LVDataList[0].bUseTextColor = true;
		Record.LVDataList[0].TextColor = getColor(120, 120, 120, 255 ) ;
		
		Record.LVDataList[0].iconPanelName = "L2UI_CT1.Windows.WindowDisable_BG";
		Record.LVDataList[0].panelOffsetXFromIconPosX=0;
		Record.LVDataList[0].panelOffsetYFromIconPosY=0;
		Record.LVDataList[0].panelWidth=32;
		Record.LVDataList[0].panelHeight=32;
		Record.LVDataList[0].panelUL=8;
		Record.LVDataList[0].panelVL=8;		
	}
	return Record.LVDataList[0];
}

function LVDataRecord makeRecord ( int index )
{
	local LVDataRecord Record;
	local string param, fullNameString, costString;	
	local itemInfo Info;

	// ParamToItemInfo(param, info);
	// ParamAdd(param, "ClassID", string(info.ID.ClassID));
	
	Info = getItemInfoArray [index];	

	fullNameString = GetItemNameAll ( info ) ;

	//if (itemNameClass == 0)		 //보급형 아이템 
	//{
	//	fullNameString = MakeFullSystemMsg(GetSystemMessage(2332), fullNameString);
	//}
	//else if (itemNameClass == 2) //희귀한 아이템
	//{
	//	fullNameString = MakeFullSystemMsg(GetSystemMessage(2331), fullNameString);
	//}
	//if (Len(additionalName) > 0 )
	//{
	//	fullNameString = fullNameString $ "(" $ additionalName $ ")";
	//}
	
	// 해당 아이템 정보 리스트에 넣을때꺼내올수 있도록 기억  <- 중국쪽에서 만든 api
	//class'UIDATA_ITEM'.static.GetItemInfoString(info.Id.ClassID, param);  

	// 툴팁을 저장하기 위해 param으로 분해 사용
	ItemInfoToParam(info, param);
	
	// 툴팁 정보
	Record.szReserved = param;	
	// 아이템 서버 아이디
	Record.nReserved1 = Int64(info.Id.ServerID);
	// 아이템 최대 값
	Record.nReserved2 = info.ItemNum ;
	// 아이템 정보의 index 값
	Record.nReserved3 = index;
	Record.LVDataList.length = 4;

	Record.LVDataList[0].szData = fullNameString;	

	Record.LVDataList[0].hasIcon = true;
	Record.LVDataList[0].nTextureWidth=32;
	Record.LVDataList[0].nTextureHeight=32;
	Record.LVDataList[0].nTextureU=32;
	Record.LVDataList[0].nTextureV=32;
	Record.LVDataList[0].szTexture = info.IconName; 
	Record.LVDataList[0].IconPosX=10;
	Record.LVDataList[0].FirstLineOffsetX=6;
	Record.LVDataList[0].HiddenStringForSorting = fullNameString;// $ util.makeZeroString(3, enchanted);
	// Record.LVDataList[0].HiddenStringForSorting = itemName $ util.makeZeroString(3, enchanted);
	
	// back texture 
	Record.LVDataList[0].iconBackTexName="l2ui_ct1.ItemWindow_DF_SlotBox_Default";
	Record.LVDataList[0].backTexOffsetXFromIconPosX=-2;
	Record.LVDataList[0].backTexOffsetYFromIconPosY=-1;
	Record.LVDataList[0].backTexWidth=36;
	Record.LVDataList[0].backTexHeight=36;
	Record.LVDataList[0].backTexUL=36;
	Record.LVDataList[0].backTexVL=36;

	// 아이콘 테두리 (기본 병기.pvp 무기등)
	Record.LVDataList[0].iconPanelName = info.iconPanel;
	Record.LVDataList[0].panelOffsetXFromIconPosX=0;
	Record.LVDataList[0].panelOffsetYFromIconPosY=0;
	Record.LVDataList[0].panelWidth=32;
	Record.LVDataList[0].panelHeight=32;
	Record.LVDataList[0].panelUL=32;
	Record.LVDataList[0].panelVL=32;	

	// IsStackableItem 을 Record.LVDataList[2].hasIcon == true 로 판단 하기 때문에 뒤에 수량을 넣음.
	// 수량성, 비수량성 모두 현재/전체 로 표시 하도록 함
	Record.LVDataList[1].hasIcon = true;
	Record.LVDataList[1].attrColor = getColor(170, 170, 170, 255);	
	Record.LVDataList[1].textAlignment=TA_Center;
	//Record.LVDataList[1].HiddenStringForSorting = String(Record.nReserved2);
	Record.LVDataList[1] = makeItemNumRecord( Record, getItemNumArray[index] );
	

	costString = MakeCostString( String ( info.Price ) );
	Record.LVDataList[2].szData = ConvertNumToTextNoAdena( String ( info.Price ) ) ;
	Record.LVDataList[2].buseTextColor = true;
	Record.LVDataList[2].textColor = GetNumericColor( costString );
	Record.LVDataList[2].textAlignment = TA_Right;	
	Record.LVDataList[2].HiddenStringForSorting = util.makeZeroString(20,info.Price );

	
	//Debug ( info.ConsumeType @ IsStackableItem( info.ConsumeType )) ;
	// 수량성 아이템이라면 총 가격 표시
	if ( IsStackableItem( info.ConsumeType ) )
	{
		// hasIcon = true; 두줄로 표기 하시오 
		Record.LVDataList[2].hasIcon = true;
		Record.LVDataList[2].attrColor = getColor(170, 170, 170, 255);
		Record.LVDataList[2].attrStat[0] = MakeFullSystemMsg(GetSystemMessage(3657), ConvertNumToTextNoAdena(String(info.Price * info.itemNum)));		
		Record.LVDataList[2].textAlignment=TA_Right;
	}

	costString = MakeCostString( String ( info.Price * getItemNumArray[index]) );	
	Record.LVDataList[3].buseTextColor = true;
	Record.LVDataList[3].textColor = GetNumericColor( costString );	
	//Record.LVDataList[3].HiddenStringForSorting = String(info.Price );
	Record.LVDataList[3].szData = costString;
	Record.LVDataList[3].textAlignment = TA_Right;
	//Record.LVDataList[3].hasIcon = true;
	//Record.LVDataList[3].attrColor = getColor(170, 170, 170, 255);
	//Record.LVDataList[3].attrStat[0] = "("$ getItemNumArray[index] $")";
	//Record.LVDataList[3].textAlignment=TA_Right;

	return record ;
}

/** 아이템을 추가 한다. */
function addItem(int index )
{
	ItemList_ListCtrl.InsertRecord( makeRecord (index) );
}

/***********************************************************************************
 * 닫는다
 * **********************************************************************************/
function bool checkShoppingEnd() 
{
	local int i ;
	for ( i = 0 ; i < getItemInfoArray.length ; i++ )
	{
		//Debug ( "checkShoppingEnd" @ getItemNumArray[i] @ getItemInfoArray[i].itemNum );
		if ( getItemNumArray[i] != getItemInfoArray[i].itemNum ) return false;
	}
	return true;
}

function Onhistory_BtnClick() 
{
	if ( class'UIAPI_WINDOW'.static.IsShowWindow("PrivateShopWndHistory") )
		class'UIAPI_WINDOW'.static.hideWindow("PrivateShopWndHistory") ;
	else 
		class'UIAPI_WINDOW'.static.showWindow("PrivateShopWndHistory") ;

}

//function OnStopSell_BtnClick()
//{
//	// 다 팔리거나, 종료 버튼 클릭 시	
//	//if ( checkShoppingEnd() ) Me.HideWindow();
//	//else handleQuit ();
//}

function handleQuit() 
{		
	if ( !checkShoppingEnd() ) 
		privateShopScript.contextMenuQuit();
	else if (  !IsPlayerStand()  ) ExecuteCommand( "/stand");	
	Me.HideWindow();
}

/***********************************************************************************
 * 아이템 비교
 * **********************************************************************************/
function bool compareItem( itemInfo info1, itemInfo info2  ) 
{
	if (
		info1.Enchanted                     != info2.Enchanted ||
		info1.Damaged                       != info2.Damaged ||
		info1.RefineryOp1                   != info2.RefineryOp1 ||
		info1.RefineryOp2                   != info2.RefineryOp2 ||
		info1.LookChangeItemID              != info2.LookChangeItemID ||
		info1.AttackAttributeType           != info2.AttackAttributeType ||
		info1.AttackAttributeValue          != info2.AttackAttributeValue ||
		info1.DefenseAttributeValueFire     != info2.DefenseAttributeValueFire ||
		info1.DefenseAttributeValueWater    != info2.DefenseAttributeValueWater ||
		info1.DefenseAttributeValueWind     != info2.DefenseAttributeValueWind ||
		info1.DefenseAttributeValueEarth    != info2.DefenseAttributeValueEarth ||
		info1.DefenseAttributeValueHoly     != info2.DefenseAttributeValueHoly ||
		info1.DefenseAttributeValueUnholy   != info2.DefenseAttributeValueUnholy ||	
		!compareParamEnSoul(info1, info2)
	) return false;

	return true;
}

function bool compareParamEnSoul(ItemInfo info1, ItemInfo info2 )
{
	local int i, n;
	local int cnt ;

	// 집혼 시스템 개편 (2015-02-09 추가)
	for(i=EIST_NORMAL; i<EIST_MAX; i++)
	{
		cnt = info1.EnsoulOption[i - EIST_NORMAL].OptionArray.Length;

		if ( cnt != info2.EnsoulOption[i - EIST_NORMAL].OptionArray.Length ) return false;

		for(n=EISI_START; n<EISI_START + cnt; n++)
		{			
			if ( info1.EnsoulOption[i - EIST_NORMAL].OptionArray[n - EISI_START] != info2.EnsoulOption[i - EIST_NORMAL].OptionArray[n - EISI_START]) return false;
		}
	}
	return true;
}

/** OnKeyUp */
function OnKeyUp( WindowHandle a_WindowHandle, EInputKey nKey )
{	
	// 키보드 누름으로 체크 	
	if ( SignEditInput_Edit.IsFocused() )
	{	
		// txtPath
		if (nKey == IK_Enter) 
		{	
			togglePrivateShopEditor();
		}
		else if ( nKey == IK_Escape ) 
		{
			hidePrivateShopwEditor();
		}
	}
}

//function onFocus ( bool bFlag, bool bTransparency) 
//{
//	Debug ( "onFocus" @ bFlag @ bTransparency  ) ;
//}


/********************************************************************************************************************
 * util
 *****************************************************************************************************************/
// 절대값 가져 오는 함수
//function int64 getAbs ( int64 num  )  { if ( num < 0 ) return - num ; return num; }
defaultproperties
{
}
