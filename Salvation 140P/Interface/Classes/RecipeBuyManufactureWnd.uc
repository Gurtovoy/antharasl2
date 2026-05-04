class RecipeBuyManufactureWnd extends UICommonAPI;

//////////////////////////////////////////////////////////////////////////////
// RECIPE CONST
//////////////////////////////////////////////////////////////////////////////
const RECIPEWND_MAX_MP_WIDTH = 165.0f;

const CRYSTAL_TYPE_WIDTH = 14;
const CRYSTAL_TYPE_HEIGHT = 14;

const DIALOG_STACKABLE_ITEM_REMOVE  = 1230;
const DIALOG_STACKABLE_ITEM_ADD     = 1240;
const DIALOG_100PER_CHECK			= 1250;

var string  m_WindowName;
var int		m_MerchantID;	//판매자의 ServerID
var int		m_RecipeID;	//RecipeID
var int		m_SuccessRate;	//성공률
var INT64	m_Adena;		//아데나
var int		m_MaxMP;
var int		m_CurrRate; // 현재 성공확률
var BarHandle MPBar;

//공물 아이템 윈도우
var ItemWindowHandle m_TributeItemWnd;
var TextBoxHandle    m_offeringRateTextBox;
var int               m_offering;

var ItemWindowHandle m_ItemWnd;

function OnRegisterEvent()
{
	RegisterEvent( EV_RecipeShopItemInfo );
	RegisterEvent( EV_UpdateMP );
	RegisterEvent( EV_UpdateMyMP );
	
	RegisterEvent( EV_InventoryAddItem );
	RegisterEvent( EV_InventoryUpdateItem );

	RegisterEvent( EV_DialogOK );	
}

function OnLoad()
{
	SetClosingOnESC();

	MPBar = GetBarHandle( "RecipeBuyManufactureWnd.barMp" );
	
	m_ItemWnd = GetItemWindowHandle ( ( m_WindowName$".ItemWnd")); 

	m_TributeItemWnd = GetItemWindowHandle ( m_WindowName$".TributeWnd.TributeItemWnd");
	m_offeringRateTextBox = GetTextBoxHandle ( m_WindowName$".txtOfferingRate" );

	GetTextBoxHandle ( m_WindowName$".txtOffering" ).SetText ( GetSystemString (654 )$GetSystemString (642 ) );
}

function OnEvent(int Event_ID, string param)
{
	local Rect 	rectWnd;
	local int		ServerID;
	local int		MPValue;

	// 2006/07/10 NeverDie
	local int		MerchantID;
	local int		RecipeID;
	local int		CurrentMP;
	local int		MaxMP;
	local int		MakingResult;
	local INT64		Adena;
	
	if (Event_ID == EV_RecipeShopItemInfo)
	{	
		
		Clear();
		
		//윈도우의 위치를 RecipeBuyListWnd에 맞춤
		
		if ( IsShowWindow ( "RecipeBuyListWnd" ) ) 
		{
			rectWnd = class'UIAPI_WINDOW'.static.GetRect("RecipeBuyListWnd");
			class'UIAPI_WINDOW'.static.MoveTo("RecipeBuyManufactureWnd", rectWnd.nX, rectWnd.nY);
			class'UIAPI_WINDOW'.static.HideWindow("RecipeBuyListWnd");
		}		
		
		//show
		class'UIAPI_WINDOW'.static.ShowWindow("RecipeBuyManufactureWnd");
		class'UIAPI_WINDOW'.static.SetFocus("RecipeBuyManufactureWnd");
		
		ParseInt( param, "MerchantID", MerchantID );
		ParseInt( param, "RecipeID", RecipeID );
		ParseInt( param, "CurrentMP", CurrentMP );
		ParseInt( param, "MaxMP", MaxMP );
		ParseInt( param, "MakingResult", MakingResult );
		ParseINT64( param, "Adena", Adena );

		ParseInt( param, "UseOffering", m_offering );
		
		ReceiveRecipeShopSellList( MerchantID, RecipeID, CurrentMP, MaxMP, MakingResult, Adena );

		setTributeWnd ();
		setOfferingRate() ;
		//setOfferingRateString( setOfferingRate() );
//		debug("MP" $CurrentMP $"  " $MaxMP);		
	}
	else if (Event_ID == EV_UpdateMP || Event_ID == EV_UpdateMyMP)
	{
		ParseInt(param, "ServerID", ServerID);
		ParseInt(param, "CurrentMP", MPValue );
		if (m_MerchantID==ServerID && m_MerchantID>0)
		{
			SetMPBar(MPValue);
		}
	}
	else if( Event_ID == EV_InventoryAddItem || Event_ID == EV_InventoryUpdateItem )
	{
		HandleInventoryItem(param);
	}

	else if ( Event_ID == EV_DialogOK ) HandleDialogOK();	
}

function HandleDialogOK()
{
	local ItemInfo scInfo;
	local INT64 inputNum;	
	local int tributeID;
	local ItemInfo tributeItemInfo;
	local bool allItemMove; // 모든 아이템을 옮기는 것인가? 스태커블한 경우 모든 아이템을 a에서 b로 옮기는 것이라면 a에서 없애주어야한다.
	local int id;

	//재료로 있는 아이템인 경우 필요 수를 감안 한 값.
	if (DialogIsMine() )
	{
		id = DialogGetID();
	
		if (id == DIALOG_STACKABLE_ITEM_REMOVE || id == DIALOG_STACKABLE_ITEM_ADD)
		{
			DialogGetReservedItemInfo( scInfo );
			inputNum =  INT64(DialogGetString() );

			// 요청한 개수는 0보다 커야한다.
			if ( inputNum <= 0 ) return;		
			
			// 입력 된 수가 아이템 개수 보다 크다면,
			if ( inputNum >= scInfo.itemNum )
			{
				// 현재가지고 있는 수로 수정해준다. Maximum임..					
				inputNum = scInfo.itemNum; 

				// Maixmum상태를 저장한다.
				allItemMove = true; 
			}

			tributeID = m_TributeItemWnd.FindItem( scInfo.id);

			// 아이템 삭제
			if ( id == DIALOG_STACKABLE_ITEM_REMOVE)
			{	
				if (allItemMove) 
				{
					// 완전 옮기는 것이므로 없애준다.
					m_TributeItemWnd.DeleteItem( tributeID );
				}
				else	
				{
					// 일부만 옮겨주므로 개수를 수정한다.
					scInfo.ItemNum -= inputNum;
					m_TributeItemWnd.SetItem( tributeID , scInfo);
				}
			}

			// 아이템 더하기
			else if (id == DIALOG_STACKABLE_ITEM_ADD )
			{	
				// 만약 공물에 아이템이 있다면 겹쳐줘야 한다.
				if (tributeID >= 0)
				{
					m_TributeItemWnd.GetItem(tributeID, tributeItemInfo);
					//들어 오는 item의 값을 더해 준다.
					tributeItemInfo.ItemNum += inputNum;
					
					//최대 값 계산 
					if ( scInfo.itemNum < tributeItemInfo.ItemNum ) tributeItemInfo.ItemNum =  scInfo.itemNum;

					m_TributeItemWnd.SetItem(tributeID, tributeItemInfo);
				}
				else //
				{				
					scInfo.itemNum = inputNum;
					m_TributeItemWnd.AddItem ( scInfo ) ;
				}
			}		

			setOfferingRate() ;
		}
		else if(id == DIALOG_100PER_CHECK)
		{
			ManufactureWidthTribute();
		}
	}
}

/*
 *
 * 아이템 이동 시 다이얼로그를 보여줄 지 말지 결정
 */
function bool isShowDialogOnMoveStackableItem ( ItemInfo infItem ) 
{
	//Debug ( "다이얼로그 보일 건지 체크 " @ IsStackableItem( infItem.ConsumeType) @ infItem.ItemNum @ infItem.AllItemCount @ class'InputAPI'.static.IsAltPressed() );
	if (IsStackableItem( infItem.ConsumeType) && infItem.ItemNum != 1)
	{		
		//infItem.AllItemCount <= 0
		if ( !class'InputAPI'.static.IsAltPressed() )
		{		
			return true;
		}				
	}	
	return false;
}


/*
 * 공물 아이템을 remove 방식 선택
 */
function deleteTributeItem(ItemInfo infItem)
{	
	local int tributeItemID;
	
	tributeItemID = m_TributeItemWnd.FindItem( infItem.id );

	if ( isShowDialogOnMoveStackableItem ( infItem ) )
	{		
		showStackItemDialog( DIALOG_STACKABLE_ITEM_REMOVE, infItem ) ;		
	}
	else
	{
		m_TributeItemWnd.DeleteItem(tributeItemID);

		setOfferingRate() ;
	}
}

/*
 * 스택 다이얼로그 보여주세요
 */
function showStackItemDialog ( int ID, iteminfo infItem  ) 
{
	local string systemMsg;

	DialogSetID(ID);	

	if ( ID == DIALOG_STACKABLE_ITEM_REMOVE) 
	{
		systemMsg = GetSystemMessage(6193);
	}
	else if ( ID == DIALOG_STACKABLE_ITEM_ADD )
	{
		systemMsg = GetSystemMessage(6192);
	}
	else systemMsg = GetSystemMessage(72);	

	DialogSetReservedItemInfo(infItem);
	DialogSetParamInt64(infItem.ItemNum);
	DialogShow(DialogModalType_Modalless, DialogType_NumberPad, MakeFullSystemMsg( systemMsg, infItem.Name, "" ), string(Self));
}


/*
 * 아이템 핸들러에 따라 삭제 할지 결정
 */
function handleRemoveItem ( ItemWindowHandle a_hItemWindow, int index ) 
{	
	local ItemInfo info;

	if (!a_hItemWindow.GetItem(index, info)) return;
	
	switch ( a_hItemWindow.GetWindowName() ) 
	{
		case "TributeItemWnd" :
			deleteTributeItem( info );
			break;
	}
}

/*
 *공물 아이템을 삭제 하는 세가지 경우 
 *
 *  OnDBClickItemWithHandle         : 더블 클릭
 *  OnRClickItemWithHandle          : 우 클릭
 *  OnDropItemSource                : 드랍의 경우
 */
function OnDBClickItemWithHandle( ItemWindowHandle a_hItemWindow, int index )
{
	handleRemoveItem( a_hItemWindow, index );
}

function OnRClickItemWithHandle( ItemWindowHandle a_hItemWindow, int index )
{
	handleRemoveItem( a_hItemWindow, index );
}

//여기서 드래그 시작 햇을 때, 다른 곳에 드랍 할 경우 발생
function OnDropItemSource( String strTarget, ItemInfo info )
{	
	if ( strTarget == "Console")
	{		
		switch (info.DragSrcName  )
		{
			case "TributeItemWnd":		
				deleteTributeItem ( info );
			break;
		}		
	}
}

/*
 * 공물 아이템을 넣음
 */
function OnDropItem( String a_WindowID, ItemInfo a_ItemInfo, int X, int Y)
{	
	local int tributeID;
	local itemInfo tributeItemInfo;

	if(!(
		a_ItemInfo.DragSrcName == "InventoryItem"     ||		
		a_ItemInfo.DragSrcName == "InventoryItem_1"   ||
		a_ItemInfo.DragSrcName == "InventoryItem_2"   ||
		a_ItemInfo.DragSrcName == "InventoryItem_3"   ||
		a_ItemInfo.DragSrcName == "InventoryItem_4"   ||
		a_ItemInfo.DragSrcName == "PetInvenWnd"       ||
		-1 != InStr( a_ItemInfo.DragSrcName, "EquipItem" ))) 
		return ;

	/*
	 * 펫 인벤토리에서 들어 오는 경우 
	 * 펫 인벤토리에 있는아이템은 공물로 사용할 수 없습니다. 메시지 출력
	 */	
	if ( a_ItemInfo.DragSrcName == "PetInvenWnd" ) 
	{
		AddSystemMessage( 6184 );
		return;
	}

	if ( a_WindowID == "TributeItemWnd" )
	{
		//공물 가능한 아이템인지 판단
		if ( !Class'UIDATA_RECIPE'.static.IsOfferingItem( a_ItemInfo.ID, true ) )
			if ( !IsAdena ( a_ItemInfo.ID ) ) 
			{
				AddSystemMessage(6190);
				return;	
			}		

		//꽉찬 경우 			
		if ( m_TributeItemWnd.GetItemNum() == 12 ) 
		{
			AddSystemMessage( 6191 );
			return ;
		}

		/* 
		 *  재료가 공물이 되는 경우 올리지 않음 아데나인 경우 아이템 최대 수량을 가격 만큼 제함
		 */
		a_ItemInfo.itemNum = getMaxTributeItemNum( a_ItemInfo );
		
		if ( a_ItemInfo.itemNum <= 0 ) 
		{
			if ( IsAdena ( a_ItemInfo.ID ) ) 
			{
				//아데나가 부족하여 수행 할 수 없습니다.
				AddSystemMessage( 4157 );
			}
			else 
			{
				//재료가 부족 합니다.
				AddSystemMessage( 341 );
			}
			return;
		}
		
		//스태커블 체크
		if ( isShowDialogOnMoveStackableItem ( a_ItemInfo ) )
		{				
			showStackItemDialog( DIALOG_STACKABLE_ITEM_ADD, a_ItemInfo );
		}
		else 
		{	
			tributeID = m_TributeItemWnd.FindItem( a_ItemInfo.id);

			// 만약 공물에 아이템이 있다면.

			if ( tributeID >= 0 )
			{
				m_TributeItemWnd.GetItem( tributeID, tributeItemInfo);										
				tributeItemInfo.itemNum = a_ItemInfo.itemNum;
				m_TributeItemWnd.SetItem( tributeID, tributeItemInfo);
			}
			else
			{	
				m_TributeItemWnd.AddItem(a_ItemInfo);								
			}

			setOfferingRate() ;
		}				
	}
}

/*
 * 추가확률 값 갱신
 */
function setOfferingRateString ( int64 OfferingRate ) 
{
	local string strTmp;
	local L2Util util;

	local Color offeringRateColor;
	util = L2Util( getScript ( "L2Util"));	
	
	strTmp = OfferingRate$"%";// $ "/"$maxOffering$"%";

	if ( ( 100 - m_SuccessRate ) <= OfferingRate ) 
	{
		strTmp = strTmp $ GetSystemString ( 2610 );
		offeringRateColor.R = 255;
		offeringRateColor.G = 102;
		offeringRateColor.B = 102;
		//m_offeringRate.SetTextColor( util.COLOR_RED );
		
	} else 
	{
		offeringRateColor = util.Yellow03;
	}

	m_offeringRateTextBox.SetTextColor( offeringRateColor );
	m_offeringRateTextBox.SetText( strTmp );	
}


/*
 * 공물 아이템의 전체 DP를 갱신
 */
function setOfferingRate() 
{
	local int64 totalDefaultPrice;
	local int i;
	local itemInfo tributeItemInfo;

	totalDefaultPrice = 0;

	for ( i = 0 ; i < m_TributeItemWnd.GetItemNum() ; i ++ ) 
	{
		m_TributeItemWnd.GetItem(i, tributeItemInfo ) ; 
		totalDefaultPrice += tributeItemInfo.itemNum * tributeItemInfo.n64DefaultPriceFromScript;
	}	

	m_CurrRate = RefreshRecipeOfferingRate(totalDefaultPrice,true);

	setOfferingRateString(m_CurrRate);
}

/*
 * 공물 윈도우를 보였다 없애는 함수
 */
function setTributeWnd() 
{
	if ( m_offering > 0  ) 	
	{
		//공물 가능
		GetWindowHandle( m_WindowName$".TributeWnd" ).ShowWindow();
		GetWindowHandle( m_WindowName ).SetWindowSize(254, 537);
		GetTextureHandle( m_WindowName$".RecipeBg" ).SetWindowSize( 241, 107 );	

		GetTextBoxHandle( m_WindowName$".txtOffering" ).ShowWindow();
		GetTextBoxHandle( m_WindowName$".txtOfferMid" ).ShowWindow();
		//GetTextBoxHandle( m_WindowName$".txtOfferingRate" ).ShowWindow();
		m_offeringRateTextBox.ShowWindow();
	}
	else
	{	
		GetWindowHandle( m_WindowName$".TributeWnd" ).HideWindow(); 
		GetWindowHandle( m_WindowName ).SetWindowSize(254, 407);
		GetTextureHandle( m_WindowName$".RecipeBg" ).SetWindowSize( 241, 92 );
		GetTextBoxHandle( m_WindowName$".txtOffering" ).Hidewindow();
		GetTextBoxHandle( m_WindowName$".txtOfferMid" ).Hidewindow();
		m_offeringRateTextBox.HideWindow();
		//GetTextBoxHandle( m_WindowName$".txtOfferingRate" ).Hidewindow();		
	}	
}

/* 
 * 공물이 아데나인 경우 필요한 경비를 두고 계산 함.
 */
function int64 getMaxTributeItemNum ( itemInfo tributeItem )
{	
	local itemInfo infItem ;
	local int idx ;
	local int64 needNum;

	needNum = 0;
	idx = m_ItemWnd.FindItemByClassID ( tributeItem.ID ) ;

	if ( idx > -1 ) 
	{	
		m_ItemWnd.GetItem ( idx, infItem ) ;
		needNum = infItem.Reserved64;
		
		/*
		 * 비 스택형 아이템 들은 재료인 경우 공물로 넣을 수 없다.		 
		 */		
	}

    else if ( isAdena( tributeItem.ID ) ) 
	{
		needNum = m_Adena;		
	}
	
	return tributeItem.itemNum - needNum;	
}

/*
 * 공물 아이템의 리스트를 만들어서 보내줌.
 */
function ManufactureWidthTribute( )
{
	local Array<OfferingItemList> tributeItemList ;
	local int i;
	local iteminfo tributeItem;

	tributeItemList.Length = m_TributeItemWnd.GetItemNum();
	for ( i = 0 ; i < tributeItemList.Length ; i++ )
	{
		m_TributeItemWnd.GetItem(i, tributeItem);
		tributeItemList[i].nItemID = tributeItem.ID.serverID;	
		tributeItemList[i].nAmount = tributeItem.itemNum;
	}
	//Debug ( "ManufactureWidthTribute" @ m_TributeItemWnd.GetItemNum()@ tributeItemList[0].nItemID @ tributeItemList[0].nAmount );
	class'RecipeAPI'.static.RequestRecipeShopMakeDo(m_MerchantID, m_RecipeID, m_Adena, m_TributeItemWnd.GetItemNum(), tributeItemList);	
}

function OnClickButton( string strID )
{
	local string param;
	local Rect   	rectWnd;

	local string systemMsg;
	local int nDefaultRate;
	
	switch( strID )
	{
	case "btnClose":
		CloseWindow();
		break;
	case "btnPrev":
		//RecipeBuyListWnd로 돌아감
		class'RecipeAPI'.static.RequestRecipeShopSellList(m_MerchantID);

		rectWnd = class'UIAPI_WINDOW'.static.GetRect(m_WindowName);		
		class'UIAPI_WINDOW'.static.MoveTo("RecipeBuyListWnd", rectWnd.nX, rectWnd.nY);
		
		CloseWindow();
		break;

	case "btnRecipeTree":
		if (class'UIAPI_WINDOW'.static.IsShowWindow("RecipeTreeWnd"))
		{
			class'UIAPI_WINDOW'.static.HideWindow("RecipeTreeWnd");	
		}
		else
		{
			ParamAdd(param, "RecipeID", string(m_RecipeID));
			ParamAdd(param, "SuccessRate", string(m_SuccessRate));
			ExecuteEvent( EV_RecipeShowRecipeTreeWnd, param);
		}
		break;
	case "btnManufacture":
		if(m_offering > 0)
		{
			DialogSetID(DIALOG_100PER_CHECK);
			systemMsg = GetSystemMessage(6206);
			nDefaultRate = class'UIDATA_RECIPE'.static.GetRecipeSuccessRate(m_RecipeID);
			nDefaultRate += m_CurrRate;
			DialogShow(DialogModalType_Modal,DialogType_OKCancel,MakeFullSystemMsg(systemMsg,string(nDefaultRate)),string(Self));
		}
		else
		{
			class'RecipeAPI'.static.RequestRecipeShopMakeDo(m_MerchantID,m_RecipeID,m_Adena);
		}
		break;
	}
}

//윈도우 닫기
function CloseWindow()
{
	Clear();
	class'UIAPI_WINDOW'.static.HideWindow("RecipeBuyManufactureWnd");
	PlayConsoleSound(IFST_WINDOW_CLOSE);
}

//초기화
function Clear()
{
	m_MerchantID = 0;
	m_RecipeID = 0;
	m_SuccessRate = 0;
	m_Adena = 0;
	m_MaxMP = 0;
	m_ItemWnd.Clear();
	//class'UIAPI_ITEMWINDOW'.static.Clear("RecipeBuyManufactureWnd.ItemWnd");
	//창이 열린 상태 즉 제작을 계속 시도 하는 경우 공물을 clear 하지 말아라. 
	if ( !IsShowWindow( m_WindowName ) ) m_TributeItemWnd.Clear();	
	m_offering = 0;
}

//기본정보 셋팅
function ReceiveRecipeShopSellList(int MerchantID,int RecipeID,int CurrentMP,int MaxMP,int MakingResult,INT64 Adena)
{
	local int			i;
	
	local string		strTmp;
	local int			nTmp;
	local int			nTmp2;
	
	local int			ProductID;
	local int			ProductNum;
	local string		ItemName;
	
	local string		param;
	local ItemInfo		infItem, newItem;
	
	//전역변수 설정
	m_MerchantID = MerchantID;
	m_RecipeID = RecipeID;
	m_SuccessRate = class'UIDATA_RECIPE'.static.GetRecipeSuccessRate(RecipeID);
	m_Adena = Adena;
	m_MaxMP = MaxMP;
	
	//윈도우 타이틀 설정
	strTmp = GetSystemString(663) $ " - " $ class'UIDATA_USER'.static.GetUserName(MerchantID);
	class'UIAPI_WINDOW'.static.SetWindowTitleByText("RecipeBuyManufactureWnd", strTmp);
	
	//Product ID
	ProductID = class'UIDATA_RECIPE'.static.GetRecipeProductID(RecipeID);
	
	//(아이템)텍스쳐	
	class'UIDATA_ITEM'.static.GetItemInfo ( GetItemID(ProductID) , newItem  );	
	class'UIAPI_ITEMWINDOW'.static.Clear("RecipeBuyManufactureWnd.texItem");
	class'UIAPI_ITEMWINDOW'.static.AddItem( "RecipeBuyManufactureWnd.texItem" , newItem ) ;		
	
	//Crystal Type(Grade Emoticon출력)
	nTmp = class'UIDATA_RECIPE'.static.GetRecipeCrystalType(RecipeID);

	strTmp = GetItemGradeTextureName(nTmp);
	class'UIAPI_TEXTURECTRL'.static.SetTexture("RecipeBuyManufactureWnd.texGrade", strTmp);
	
	// S80 그레이드일 경우에 한해 아이콘 텍스쳐 크기를 2배로 늘린다. 6
	// R95, R99 그레이드일 경우에 한해 아이콘 텍스쳐 크기를 2배로 늘린다. 8, 9
	// EVENT 그레이드일 경우에 2배로 늘리는 곳이 있고 아닌 곳이 있다. 왜그런지 모르니까 일단은 냅둠 10
	if( nTmp == CrystalType.CRT_S80 || nTmp == CrystalType.CRT_R95 || nTmp == CrystalType.CRT_R99 || nTmp == CrystalType.CRT_EVENT )
	{
		class'UIAPI_WINDOW'.static.SetWindowSize( "RecipeManufactureWnd.texGrade", CRYSTAL_TYPE_WIDTH * 2, CRYSTAL_TYPE_HEIGHT );
	}
	else	//나머지는 원래 사이즈로
	{
		class'UIAPI_WINDOW'.static.SetWindowSize( "RecipeManufactureWnd.texGrade", CRYSTAL_TYPE_WIDTH, CRYSTAL_TYPE_HEIGHT );
	}

	//아이템 이름
	ItemName = MakeFullItemName(ProductID);
	class'UIAPI_TEXTBOX'.static.SetText("RecipeBuyManufactureWnd.txtName", ItemName);	
	
	//MP소비량
	nTmp = class'UIDATA_RECIPE'.static.GetRecipeMpConsume(RecipeID);
	class'UIAPI_TEXTBOX'.static.SetText("RecipeBuyManufactureWnd.txtMPConsume", "" $ nTmp);
	
	//성공확률
	class'UIAPI_TEXTBOX'.static.SetText("RecipeBuyManufactureWnd.txtSuccessRate", m_SuccessRate $ "%");
	
	//결과물수
	ProductNum = class'UIDATA_RECIPE'.static.GetRecipeProductNum(RecipeID);
	class'UIAPI_TEXTBOX'.static.SetText("RecipeBuyManufactureWnd.txtResultValue", "" $ ProductNum);
	
	//MP바 표시
	//debug("CurrentMP" $CurrentMP);
	SetMPBar(CurrentMP);
	
	//보유갯수
	class'UIAPI_TEXTBOX'.static.SetText("RecipeBuyManufactureWnd.txtCountValue", "" $ string(GetInventoryItemCount(GetItemID(ProductID))));
	
	//제작결과
	strTmp = "";
	if (MakingResult == 0)
	{
		strTmp = MakeFullSystemMsg(GetSystemMessage(960), ItemName, "");
	}
	else if (MakingResult == 1)
	{
		strTmp = MakeFullSystemMsg(GetSystemMessage(959), ItemName, "" $ ProductNum);
	}
	class'UIAPI_TEXTBOX'.static.SetText("RecipeBuyManufactureWnd.txtMsg", strTmp);
	
	//ItemWnd에 추가
	param = class'UIDATA_RECIPE'.static.GetRecipeMaterialItem(RecipeID);
	ParseInt(param, "Count", nTmp);
	for (i=0; i<nTmp; i++)
	{
		//Set ItemID
		ParseInt(param, "ID_" $ i, nTmp2);
		infItem.ID = GetItemID(nTmp2);
		
		class'UIDATA_ITEM'.static.GetItemInfo ( GetItemID(nTmp2) , infItem  );
		
		//NeedNum 
		ParseINT64(param, "NeededNum_" $ i, infItem.Reserved64);	
		infItem.ItemNum = GetInventoryItemCount(infItem.ID);
		if (infItem.Reserved64>infItem.ItemNum)
			infItem.bDisabled = 1;
		else
			infItem.bDisabled = 0;
		class'UIAPI_ITEMWINDOW'.static.AddItem( "RecipeBuyManufactureWnd.ItemWnd", infItem);
	}
}

//MP Bar
function SetMPBar(int CurrentMP)
{
	/*
	local int	nTmp;
	local int	nMPWidth;
	
	nTmp = RECIPEWND_MAX_MP_WIDTH * CurrentMP;
	nMPWidth = nTmp / m_MaxMP;
	if (nMPWidth>RECIPEWND_MAX_MP_WIDTH)
	{
		nMPWidth = RECIPEWND_MAX_MP_WIDTH;
	}
	class'UIAPI_WINDOW'.static.SetWindowSize("RecipeBuyManufactureWnd.texMPBar", nMPWidth, 12);
	*/
//	debug("MP STATUS" $m_MaxMP $" " $CurrentMP);
	MPBar.SetValue(m_MaxMP , CurrentMP);
}

//인벤아이템이 업데이트되면 아이템의 현재보유수를 바꿔준다
function HandleInventoryItem(string param)
{
	local ItemID cID;
	local int idx;
	local ItemInfo infItem;	
	local int64 invenItemCount;

	//아이템 필요 수 
	local int64 needNum ;

	local string type ;

	if ( !IsShowWindow( m_WindowName ) ) return;

	if (ParseItemID( param, cID ))
	{
		needNum = 0;
		//이벤트로 받은 아이템의 serverID 값이 0이다.
		//cID.serverID = 0;
		idx = m_ItemWnd.FindItemByClassID( cID );	// ClassID

		if (idx>-1)
		{
			m_ItemWnd.GetItem( idx, infItem);
			infItem.ItemNum = GetInventoryItemCount(infItem.ID);			

			if (infItem.Reserved64>infItem.ItemNum)
				infItem.bDisabled = 1;
			else
				infItem.bDisabled = 0;
			m_ItemWnd.SetItem( idx, infItem);
			needNum = infItem.Reserved64;
		}
		
		idx = m_TributeItemWnd.FindItem( cID );		
		
		if (idx>-1)
		{
			ParseString( param, "type", type );

			m_TributeItemWnd.GetItem( idx, infItem);
			
			if( type == "update" )
			{
				invenItemCount = GetInventoryItemCount(infItem.ID) - needNum;				
				if ( invenItemCount <= 0 ) 
				{
					m_TributeItemWnd.DeleteItem ( idx );
				}
				else if ( invenItemCount < infItem.ItemNum )
				{
					infItem.ItemNum = invenItemCount;
					m_TributeItemWnd.SetItem( idx, infItem);
				}	
			}
			else if( type == "delete" )
			{
				m_TributeItemWnd.DeleteItem ( idx ) ;
			}
			//add인 경우는 필요 없음
			else if( type == "add" ){}			

//			Debug ( "HandleInventoryItem" @ cID.serverID @ idx @ GetInventoryItemCount(infItem.ID));

			setOfferingRate() ;
		}
	}
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( "RecipeBuyManufactureWnd" ).HideWindow();
}

defaultproperties
{
    m_WindowName="RecipeBuyManufactureWnd"
}
