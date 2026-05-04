/***
 *   종료 리포트 (종료, 리스타트 창), 보조 아이템 목록 보기 창
 **/
class QuitReportDrawerWnd extends UICommonAPI;

var WindowHandle Me;

var ListCtrlHandle ItemListCtrl;
var ButtonHandle   closeBtn;

// 아이템 정렬용 index 
var int itemIndex;

// 얻은 아이템 목록
var array<ItemInfo>	getItemInfoArray;
var L2Util util;
var InventoryWnd  inventoryWndScript;
var QuitReportWnd QuitReportWndScript;

function OnRegisterEvent()
{
	//RegisterEvent(  );
}

function OnLoad()
{
	SetClosingOnESC();
	Initialize();
}


function OnShow()
{
	updateList();
}

function OnHide()
{
}

function Initialize()
{
	Me           = GetWindowHandle( "QuitReportDrawerWnd" );
	ItemListCtrl = GetListCtrlHandle( "QuitReportDrawerWnd.InstanceDungeon_ListCtrl" );
	closeBtn     = GetButtonHandle( "QuitReportDrawerWnd.EnsoulInfoBtn" );

	util                = L2Util(GetScript("L2Util"));
	inventoryWndScript  = inventoryWnd(GetScript("inventoryWnd"));
	QuitReportWndScript = QuitReportWnd(GetScript("QuitReportWnd"));

	ItemListCtrl.SetSelectedSelTooltip(FALSE);	
	ItemListCtrl.SetAppearTooltipAtMouseX(true);

	init();
}

// OnClickButton
function OnClickButton( string Name )
{
	switch( Name )
	{
		case "EnsoulInfoBtn":
			 OnEnsoulInfoBtnClick();
			 break;
	}
}

// 외부(인벤토리) 에서 아이템을 추가 하는 것
function externalAddItem(ItemInfo addItemInfo)
{
	// Debug("addItemInfo:::" @ addItemInfo.Id.ClassID);

	// 수량성 아이템이면
	if ( IsStackableItem( addItemInfo.ConsumeType ))
	{
		// Debug("수량성 아이템 처리-----------");
		sumStackableItem(addItemInfo);
	}
	else
	{
		// Debug("일반 아이템 처리-----------");
		// 수량성 아이템이 아니면 그냥 그대로 넣는다.
		getItemInfoArray.Length = getItemInfoArray.Length + 1;
		getItemInfoArray[ getItemInfoArray.Length - 1 ] = (addItemInfo);
	}

	if (Me.IsShowWindow()) updateList();
}

function int getTotalItemCount()
{
	local int adenItem, itemLen;
	local int i;
	
	adenItem = 0;
	itemLen = getItemInfoArray.Length;

	// 아데나가 있나 검색
	for(i = 0; i < itemLen; i++)
	{
		if(getItemInfoArray.Length > 0)
		{
			if(getItemInfoArray[i].Id.ClassID == 57)
			{
				// Debug("아데나 있음");
				adenItem = -1;
				break;
			}
		}
	}

	return getItemInfoArray.Length + adenItem;
}


// 초기화
function init()
{
	if (getItemInfoArray.Length > 0)
		getItemInfoArray.Remove(0, getItemInfoArray.Length);

	itemIndex = 99999;
	itemListCtrl.DeleteAllItem();
}
// 수량성 아이템인 경우 처리
function sumStackableItem(ItemInfo addItemInfo)
{
	local int i;
	local ItemInfo beforeItemInfo;
	local bool bAdd;

	for (i = 0; i < getItemInfoArray.Length; i++)
	{
		if (getItemInfoArray[i].ID.ClassID == addItemInfo.ID.ClassID)
		{
			inventoryWndScript.getInventoryItemInfo(addItemInfo.Id, beforeItemInfo, true);

			// 빠진 경우도 update 이벤트로 오기 때문에 더해진 경우만..
			if(beforeItemInfo.itemNum < addItemInfo.itemNum)				
			{
				addItemInfo.itemNum = getItemInfoArray[i].itemNum + (addItemInfo.itemNum - beforeItemInfo.itemNum);

				getItemInfoArray.Remove(i, 1);

				getItemInfoArray.Length = getItemInfoArray.Length + 1;
				getItemInfoArray[ getItemInfoArray.Length - 1 ] = (addItemInfo);
			}

			bAdd = true;
			break;
		}
	}

	if(bAdd == false)
	{
		inventoryWndScript.getInventoryItemInfo(addItemInfo.Id, beforeItemInfo, true);

		// 빠진 경우도 update 이벤트로 오기 때문에 더해진 경우만..
		if(beforeItemInfo.itemNum < addItemInfo.itemNum)				
		{
			// 처음 들어 오는 수량성 아이템도 추가된 수량만 넣어야한다.
			if (getItemInfoArray.Length > 0)
			{
				addItemInfo.itemNum = getItemInfoArray[i].itemNum + (addItemInfo.itemNum - beforeItemInfo.itemNum);
			}
			else
			{
				addItemInfo.itemNum = (addItemInfo.itemNum - beforeItemInfo.itemNum);
			}

			getItemInfoArray.Length = getItemInfoArray.Length + 1;
			getItemInfoArray[ getItemInfoArray.Length - 1 ] = (addItemInfo);
		}
	}
}

// 전체 목록 갱신 
function updateList()
{
	local int i;

	itemListCtrl.DeleteAllItem();
	
	if (getItemInfoArray.Length > 0)
	{
		for (i = getItemInfoArray.Length - 1; i > -1; i--)
		{
			// 아데나인 경우 리스트에 넣지 않음. (기획: 조희영)
			if(getItemInfoArray[i].Id.ClassID != 57)
			{
				addItem(getItemInfoArray[i]);
			}
		}
	}

	// 목록이 갱신 되면 메인창도 갱신해준다.
	QuitReportWndScript.UpdateUserInfoHandler();
}

/** 아이템을 추가 한다. */
function addItem(itemInfo info)
{
	local LVDataRecord Record;
	local string param, additionalName, fullNameString, itemNumEasyRead;
	local int itemNameClass;

	// ParamToItemInfo(param, info);
	// ParamAdd(param, "ClassID", string(info.ID.ClassID));
	
	itemIndex--;

	fullNameString = info.Name;

	itemNameClass  = class'UIDATA_ITEM'.static.GetItemNameClass( info.ID );			
	additionalName = class'UIDATA_ITEM'.static.GetItemAdditionalName( info.ID );

	if (itemNameClass == 0)		 //보급형 아이템 
	{
		fullNameString = MakeFullSystemMsg(GetSystemMessage(2332), fullNameString);
	}
	else if (itemNameClass == 2) //희귀한 아이템
	{
		fullNameString = MakeFullSystemMsg(GetSystemMessage(2331), fullNameString);
	}
	if (Len(additionalName) > 0 )
	{
		fullNameString = fullNameString $ "(" $ additionalName $ ")";
	}
	
	// 해당 아이템 정보 리스트에 넣을때꺼내올수 있도록 기억  <- 중국쪽에서 만든 api
	//class'UIDATA_ITEM'.static.GetItemInfoString(info.Id.ClassID, param);  

	ItemInfoToParam(info, param);
	
	Record.szReserved = param;

	Record.nReserved1 = Int64(info.Id.ClassID);
	Record.LVDataList.length = 4;
	// 아이템 
	////record.LVDataList[0].buseTextColor = True;
	//if ( IsStackableItem( info.ConsumeType ) )
	//{
	//	 Record.LVDataList[0].textColor =  getColor(100,111,22, 255);
	//}
	//else Record.LVDataList[0].textColor = getColor(100,30,3, 255);

	Record.LVDataList[0].szData = fullNameString;

	Record.LVDataList[0].hasIcon = true;
	Record.LVDataList[0].nTextureWidth=32;
	Record.LVDataList[0].nTextureHeight=32;
	Record.LVDataList[0].nTextureU=32;
	Record.LVDataList[0].nTextureV=32;
	Record.LVDataList[0].szTexture = info.IconName; 
	Record.LVDataList[0].IconPosX=10;
	Record.LVDataList[0].FirstLineOffsetX=6;

	Record.LVDataList[0].HiddenStringForSorting = String(itemIndex);// $ util.makeZeroString(3, enchanted);
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

	// 수량성 아이템
	if ( IsStackableItem( info.ConsumeType ) )
	{

		if(info.ItemNum > 9999) itemNumEasyRead = "9999+";
		else itemNumEasyRead = String(info.ItemNum);

		Record.LVDataList[1].szData = itemNumEasyRead;
		Record.LVDataList[1].textAlignment = TA_Center;
		Record.LVDataList[1].HiddenStringForSorting =  util.makeZeroString(13, info.ItemNum);
	}
	else
	{
		Record.LVDataList[1].HiddenStringForSorting = util.makeZeroString(13, info.ItemNum);
	}

	ItemListCtrl.InsertRecord( Record );
}

function OnEnsoulInfoBtnClick()
{   
	// 오픈 버튼 "<-" 텍스쳐 교체
	QuitReportWndScript.setDrawerButtonState(true);
	Me.HideWindow();
}

///**
// * 윈도우 ESC 키로 닫기 처리 
// * "Esc" Key
// ***/
//function OnKeyUp( WindowHandle a_WindowHandle, EInputKey Key )
//{
//	if( Key == IK_Escape )
//	{
//		// 오픈 버튼 "<-" 텍스쳐 교체
//		QuitReportWndScript.setDrawerButtonState(true);

//		PlayConsoleSound(IFST_WINDOW_CLOSE);		
//		GetWindowHandle( getCurrentWindowName(string(Self))).HideWindow();
//	}
//}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( getCurrentWindowName(string(Self))).HideWindow();
}
defaultproperties
{
}
