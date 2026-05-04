class AttributeEnchantWnd extends UICommonAPI;

const DIALOG_ASK_ITEM_COUNT                         = 55555;
const DIALOG_ENCHANT_COMPLETE                       = 55556;

//Handle List
var WindowHandle		Me;
var WindowHandle        DisableWnd;
var ItemWindowHandle	ItemWnd;
var	ItemWindowHandle	InventoryItemHandle;
var TextBoxHandle	    TextBox;
var TextBoxHandle	    ItemCountTextBox;
var ButtonHandle		OkButton;
var ButtonHandle        AttributeCountEditBtn;


// 변수 목록
var ItemInfo 		    SelectItemInfo;		    // 선택한 아이템
var ItemInfo 		    ResourceInfo;		    // 재료 아이템
var int 			    ScrollCID;			    // 스크롤의 종류를 저장한다. 
var INT64               LoopEnchantItemCount;   // 반복시킬 최대 개수
var INT64               ResourceItemCount;      // 재료 아이템 중첩 개수
var int                 ItemClassID;

var EditBoxHandle    AttributeCountEditBox;
function OnRegisterEvent()
{
	RegisterEvent( EV_AttributeEnchantItemShow );
	RegisterEvent( EV_EnchantHide );
	RegisterEvent( EV_AttributeEnchantItemList );
	RegisterEvent( EV_AttributeEnchantResult );
	RegisterEvent( EV_DialogOK );
	RegisterEvent( EV_DialogCancel );
}

function OnLoad()
{
	SetClosingOnESC();

	DisableWnd = GetWindowHandle( "AttributeEnchantWnd.DisableWnd" );
	
	Me = GetWindowHandle( "AttributeEnchantWnd" );
	ItemWnd = GetItemWindowHandle( "AttributeEnchantWnd.ItemWnd" );
	TextBox = GetTextBoxHandle( "AttributeEnchantWnd.txtScrollName" );
	OkButton = GetButtonHandle( "AttributeEnchantWnd.btnOK" );	
	AttributeCountEditBtn = GetButtonHandle( "AttributeEnchantWnd.AttributeCountEditBtn" );
	AttributeCountEditBox = GetEditBoxHandle( "AttributeEnchantWnd.AttributeCountEditBox" );
	InventoryItemHandle = GetItemWindowHandle( "InventoryWnd.InventoryItem" );
	ItemCountTextBox = GetTextBoxHandle( "AttributeEnchantWnd.itemCountTxt" );

	AttributeCountEditBox.SetMaxLength(6);
}

function onShow()
{
	// 지정한 윈도우를 제외한 닫기 기능  
	getInstanceL2Util().ItemRelationWindowHide(getCurrentWindowName(String(self)), "InventoryWnd");
}

function OnEvent(int Event_ID, string param)
{
	if (Event_ID == EV_AttributeEnchantItemShow)
	{
		// 속성 해제 창이 열렸을때는 속성 인첸트를 못하게 막는다.
		if( class'UIAPI_WINDOW'.static.IsShowWindow("AttributeRemoveWnd") )	
		{	
			// 왜 속성 인첸트를 창을 못여는지 안내
			AddSystemMessage(3161);	
			OnCancelClick();
		}
		else
		{
			HandleAttributeEnchantShow(param);	
		}
	}
	else if (Event_ID == EV_EnchantHide)
	{
		HandleAttributeEnchantHide();
	}
	else if (Event_ID == EV_AttributeEnchantItemList)
	{
		HandleAttributeEnchantItemList(param);
	}
	else if (Event_ID == EV_AttributeEnchantResult)
	{
		HandleAttributeEnchantResult(param);
	}
	else if(Event_ID == EV_DialogOK)
	{
		HandleDialogOK();
	}
	else if(Event_ID == EV_DialogCancel)
	{
		HandleDialogCancel();
	}
}

function HandleDialogOK()
{
	local int id;
	local ItemID scID;
	local ItemInfo scInfo;
	local INT64 inputNum;

	if( DialogIsMine() )
	{
		id = DialogGetID();
	
		inputNum = INT64( DialogGetString() );

		if(ResourceItemCount < inputNum)
			inputNum = ResourceItemCount;
		scID = DialogGetReservedItemID();
		DialogGetReservedItemInfo(scInfo);
		
		if (id == DIALOG_ASK_ITEM_COUNT)
		{
			AttributeCountEditBox.SetString(String(inputNum));
			if(ResourceItemCount < inputNum)
				inputNum = ResourceItemCount;

			LoopEnchantItemCount = inputNum;
		}
	}
	
	DisableCurrentWindow(false);
} 

/** Desc : 다이얼로그 윈도우를 열고 Cancel 버튼 누른 경우 */
function HandleDialogCancel()
{
	if( DialogIsMine() )
	{
		DisableCurrentWindow(false);
	}
	//Me.HideWindow();
	// 다른 다이얼로그가 캔슬 되었을때도 비활성화를 풀어야 한다.
//	DisableCurrentWindow(false);
}

//액션의 클릭
function OnClickItem( string strID, int index )
{	
	if (strID == "ItemWnd")
	{		
		OkButton.EnableWindow();
	}
}

function OnClickButton( string strID )
{
	local INT64 itemCount;
	
	itemCount = Int64(AttributeCountEditBox.GetString());

	switch( strID )
	{
	case "btnOK":
		DisableCurrentWindow(true);
		if(ResourceItemCount < Int64(AttributeCountEditBox.GetString()))
			itemCount = ResourceItemCount;
		AttributeCountEditBox.SetString(String(itemCount));
		LoopEnchantItemCount = itemCount;
		OnOkClickProgress();
		break;
	case "btnCancel":
		OnCancelClick();
		break;
	case "AttributeCountEditBtn":
		CountBtnClick();
		break;
	}
}


function CountBtnClick()
{
	local ItemInfo info;
	
	if (ItemWnd.GetItemNum() > 0)
	{
		ItemWnd.GetItem(0, info);

		// Ask price
		DialogSetID( DIALOG_ASK_ITEM_COUNT);
		DialogSetReservedItemID( info.ID );				// ServerID
		//DialogSetReservedInt3( int(bAllItem) );		// 전체이동이면 개수 묻는 단계를 생략한다
		DialogSetEditType("number");
		DialogSetEditBoxMaxLength(6);
		DialogSetParamInt64( ResourceItemCount );
		DialogSetDefaultOK();
		debug(GetSystemMessage(4142));
		DialogShow(DialogModalType_Modalless, DialogType_NumberPad, GetSystemMessage(4142), string(Self) );	
		DisableCurrentWindow(true);
	}
}

function OnOkClickProgress()
{	
	local ProgressBox script;
	
	// 선택한 아이템의 정보를 받아온다. 
	ItemWnd.GetSelectedItem(SelectItemInfo);

	if(SelectItemInfo.ID.ClassID != 0)	// 선택된 아이템이 있을 경우만 진행
	{
		if(IsShowWindow("ItemEnchantWnd"))	//아이템 인첸트가 먼저 떠있다면 인챈트를 진행시키지 않는다. 
		{
			AddSystemMessage(2188);
			DisableCurrentWindow(false);
		}
		// 밑의 이유 c++ 코드부분
// enum AttributeResult
// {
// 	ATTR_ENCHAN_POSSIBLE,
// 	ATTR_ENCHAN_OPPOSITE_ATTR,
// 	ATTR_ENCHAN_MAX_NUM_WEAPON,
// 	ATTR_ENCHAN_MAX_NUM_ARMOR,
// 	ATTR_ENCHAN_MAX_ATTR,
// 	ATTR_ENCHAN_IMPOSSIBLE,
// 	ATTR_ENCHAN_FULL //3속성이 다찼다
// };
		else if(SelectItemInfo.Reserved != 0) //인챈할수 없는 아이템이라면
		{
			if(SelectItemInfo.Reserved == 1)
				AddSystemMessage(3117);			
			if(SelectItemInfo.Reserved == 2)
				AddSystemMessage(3154);			
			if(SelectItemInfo.Reserved == 4)
				AddSystemMessage(3153);			
			if(SelectItemInfo.Reserved == 6)
				AddSystemMessage(3155);			

			DisableCurrentWindow(false);
		}

		else
		{
			// 프로그레스 바를 띄워준다. 
			//Me.HideWindow();			
			script = ProgressBox( GetScript("ProgressBox") );
			script.Initialize();
			script.ShowDialog(MakeFullSystemMsg(GetSystemMessage(4140), ResourceInfo.Name, String(LoopEnchantItemCount), SelectItemInfo.Name), "AttributeEnchantWnd", 2000, ResourceInfo, SelectItemInfo);
		}
	}
}

function OnOKClick()
{
	//class'EnchantAPI'.static.RequestEnchantItemAttribute(SelectItemInfo.ID);
	class'EnchantAPI'.static.RequestEnchantItemAttribute(SelectItemInfo.ID, LoopEnchantItemCount);
}


function OnCancelClick()
{
	local ItemID ID;
	
	ID = GetItemID(-1);
	//debug("request attribute cancle");
	class'EnchantAPI'.static.RequestEnchantItemAttribute(ID, LoopEnchantItemCount);
	Me.HideWindow();
	Clear();
}

function Clear()
{
	ItemWnd.Clear();
}

function HandleAttributeEnchantShow(string param)
{
	local ItemID cID;
	local INT64 count;
	Clear();
	ParseItemID(param, cID);
	ParseINT64(param, "ItemCount", count);
	ResourceItemCount = count;
	ScrollCID = cID.ClassID;				// 스크롤 아이디 저장
	TextBox.SetText(class'UIDATA_ITEM'.static.GetItemName(cID));
	ItemClassID = cID.ClassID;	

	class'UIDATA_ITEM'.static.GetItemInfo( cID, ResourceInfo );	

	ItemCountTextBox.SetText("x");
	AttributeCountEditBox.SetString("1");
	OkButton.DisableWindow();				// 처음 뿌려줄 때는 아이템을 선택하지 않았기 때문에 무조건 확인 버튼을 disable 시켜준다. 

	Me.ShowWindow();
	Me.SetFocus();
	DisableCurrentWindow(false);
}

function DisableCurrentWindow(bool bFlag)
{
	if (bFlag)
	{
		DisableWnd.EnableWindow();
		DisableWnd.ShowWindow();
	}
	else 
	{
		DisableWnd.DisableWindow();
		DisableWnd.HideWindow();
	}
}

function HandleAttributeEnchantHide()
{
	//Me.HideWindow();
	//Clear();
}

// 밑의 이유 c++ 코드부분
// enum AttributeResult
// {
// 	ATTR_ENCHAN_POSSIBLE,
// 	ATTR_ENCHAN_OPPOSITE_ATTR,
// 	ATTR_ENCHAN_MAX_NUM_WEAPON,
// 	ATTR_ENCHAN_MAX_NUM_ARMOR,
// 	ATTR_ENCHAN_MAX_ATTR,
// 	ATTR_ENCHAN_IMPOSSIBLE,
// 	ATTR_ENCHAN_FULL //3속성이 다찼다
// };

function HandleAttributeEnchantItemList(string param)
{
	local ItemInfo infItem;
	local int Ispossible;
	ParseInt(param, "Ispossible", Ispossible);
	ParamToItemInfo(param, infItem);
	infItem.Reserved = Ispossible;
	
	//debug("Name :" $ infItem.Name $ " SlotBitType: "  $ infItem.SlotBitType $ " ShieldDefense : " $ infItem.ShieldDefense $ " CrystalType :"  $infItem.CrystalType);
	
	// item 정보로 판단하여 사용 가능한 아이템만 insert 한다.  - 친절한 UI정책 ^^ - innowind 
	// S급 이상의 무기/ 방어구만 속성 인챈트 가능
	
	//ItemWnd.AddItem(infItem);	// 서버에서 알아서 걸러주는것 같으니 아래 코드는 필요 없다.
	
	//S급 이상의 아이템만 추가. S80을 위해 부등호를 사용하였다. 
	//방패는 제외한다. 방패도 itemType이 1로 들어오기 때문에 shieldDefense 변수를 사용.
	if( !infItem.bSecurityLock &&  (infItem.CrystalType > 4) && (infItem.ShieldDefense == 0) && (infItem.SlotBitType != 268435456) && (infItem.ArmorType != 4) && (infItem.SlotBitType != 1))
	{
		if(Ispossible == 0) //ATTR_ENCHAN_POSSIBLE
			ItemWnd.AddItem(infItem);
		else
			ItemWnd.AddItemWithFaded(infItem);
	}
}

function String GetPropString(int id)
{
	switch(id)
	{
		case 9546:
			return GetSystemString(2753);
		break;
		case 9547:
			return GetSystemString(2754);
		break;
		case 9549:
			return GetSystemString(2755);
		break;
		case 9548:
			return GetSystemString(2756);
		break;
		case 9551:
			return GetSystemString(2757);
		break;
		case 9550:
			return GetSystemString(2758);
		break;
	}
}


function HandleAttributeEnchantResult(string param)
{	
	local int result, isWeapon, attrType, beforeAttrValue, afterAttrValue, failCount;
	local INT64 successCount;
	local ItemInfo iInfo;
	
	ParseInt(param, "Result", result);
	ParseInt(param, "IsWeapon", isWeapon);
	ParseInt(param, "AttrType", attrType);
	ParseInt(param, "BeforeAttrValue", beforeAttrValue);
	ParseInt(param, "AfterAttrValue", afterAttrValue);
	ParseInt(param, "FailCount", failCount);
	ParseINT64(param, "SuccessCount", successCount);

	//class'EnchantAPI'.static.RequestEnchantItemAttribute(SelectItemInfo.ID);

	InventoryItemHandle.GetItem(InventoryItemHandle.FindItem( ResourceInfo.ID ), iInfo);//d
	
	if(result != 2)
	{
		DialogSetID( DIALOG_ENCHANT_COMPLETE );
		DialogShowWithResize(DialogModalType_Modalless, DialogType_OK, 
	    MakeFullSystemMsg(GetSystemMessage(4141), 		
		ResourceInfo.Name,                                         //리소스 아이템 이름
		String(LoopEnchantItemCount),                              //반복개수
	    String(successCount),                                      //성공횟수
		String(failCount),                                         //실패횟수
		string(LoopEnchantItemCount - (successCount + failCount))),//남은개수
		-1, 260, string(Self));					  
	}
	
	DisableCurrentWindow(false);
	//결과에 상관없이 무조건 Hide*/
	Me.HideWindow();
	Clear();
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);		
	HandleAttributeEnchantHide();
	OnCancelClick();
}
defaultproperties
{
}
