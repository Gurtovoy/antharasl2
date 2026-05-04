class AttributeRemoveWnd extends UICommonAPI;

var WindowHandle Me;
var TextBoxHandle txtRemoveAdenaStr;
var TextBoxHandle txtRemoveAdena;
var TextBoxHandle txtItemSelectStr;
var ItemWindowHandle ItemWnd;
var TextureHandle ItemWndBg;
var TextureHandle txtRemoveAdenaBg;
var TextureHandle ItemWndScrollBg;
var ButtonHandle btnOK;
var ButtonHandle btnCancel;

var ButtonHandle btnHideBarButton0;             // 해제할 속성 선택 에서 3가지 투명 버튼  
var ButtonHandle btnHideBarButton1;
var ButtonHandle btnHideBarButton2;

var Tooltip toolTipScript;                      // 툴팁에 정의된 속성 메소드 사용을 위해서..

// 각 속성을 표현할 게이지 컨트롤 
var BarHandle gageAttributeSelect0;
var BarHandle gageAttributeSelect1;
var BarHandle gageAttributeSelect2;

var CheckBoxHandle btnAttributeSelect0;
var CheckBoxHandle btnAttributeSelect1;
var CheckBoxHandle btnAttributeSelect2;

var TextBoxHandle txtAttributeSelect0;
var TextBoxHandle txtAttributeSelect1;
var TextBoxHandle txtAttributeSelect2;

var ItemInfo 	  SelectItemInfo;		        // 선택한 아이템
var Array<string> tooltipStr;
var Array<string> attributeWord;
var Array<int>    attributerTypeRadio;
var Array<int>    memoryAttributeSelectedRadio; // 현재 선택된 라디오 버튼의 위치를 기억 시킨다.

var int beforeClickedItem;                      // 이전에 클릭된 속성 해제 아이템 번호
var int radioButtonCount;


const DIALOG_ATTRIBUTE_REMOVE = 9001;
const EQUIPITEM_Max = 23;				        // 장착 아이템의 MAX갯수

const ATTRIBUTE_FIRE 	= 0;
const ATTRIBUTE_WATER 	= 1;
const ATTRIBUTE_WIND 	= 2;
const ATTRIBUTE_EARTH 	= 3;
const ATTRIBUTE_HOLY 	= 4;
const ATTRIBUTE_UNHOLY 	= 5;

var InventoryWnd script;                        //서버 아이디를 가지고 아이템 정보를 받기 위해 인벤토리 스크립트를 가져온다. 


/****************************************************************************************************
 * 
 *  기초 세팅
 *  
 ****************************************************************************************************/

/** onLoad */
function OnLoad()
{
	SetClosingOnESC();

	Initialize();

	// 속성 게이지등을 초기화 하고 , 안보이게 한다.
	initAttributeElements(false);
}

/** OnShow */
function OnShow()
{
	// 지정한 윈도우를 제외한 닫기 기능 
	getInstanceL2Util().ItemRelationWindowHide(getCurrentWindowName(String(self)), "InventoryWnd");
 
	initAttributeElements(false); 
}

/** OnRegisterEvent */
function OnRegisterEvent()
{
	RegisterEvent( EV_RemoveAttributeEnchantWndShow );
	RegisterEvent( EV_RemoveAttributeEnchantItemData );
	RegisterEvent( EV_RemoveAttributeEnchantResult );

	RegisterEvent( EV_DialogOK );
	RegisterEvent( EV_DialogCancel );
}

/** OnEvent */
function OnEvent(int Event_ID, string param)
{
	if (Event_ID == EV_RemoveAttributeEnchantWndShow)
	{
		// IsShowWindow
		// 속성 인첸트 창이 열려 있다면 열지 않는다.
		if( class'UIAPI_WINDOW'.static.IsShowWindow("AttributeEnchantWnd") )			// 혈맹 정보 창이 보여지고 있다면 업데이트 해준다.
		{
			AddSystemMessage(3161);
		}
		else
		{
			HandleAttributeRemoveShow(param);			
		}		
	}
	else if (Event_ID == EV_RemoveAttributeEnchantItemData)
	{
		HandleAttributeRemoveItemData(param);
	}
	else if (Event_ID == EV_RemoveAttributeEnchantResult)
	{
		HandleAttributeRemoveResult(param); 
	}
	else if	 (Event_ID == EV_DialogOK)
	{
		HandleDialogOK();
	}
	else if	 (Event_ID == EV_DialogCancel)
	{
		Me.EnableWindow();
	}
}

/** 속성 해제, 닫기 버튼 등 처리 */
function OnClickButton( string Name )
{
	switch( Name )
	{
		// 속성 해제
		case "btnOK":
			OnbtnOKClick();
			break;
		
		// 닫기 
		case "btnCancel":
			OnbtnCancelClick();
			break;
		
		// 투명 버튼 처리 
		case "btnListSelect0":
			if (gageAttributeSelect0.IsShowWindow()) setRadioButton(0);
			break;
		case "btnListSelect1":
			if (gageAttributeSelect1.IsShowWindow()) setRadioButton(1);
			break;
		case "btnListSelect2":
			if (gageAttributeSelect2.IsShowWindow()) setRadioButton(2);
			break;
	}
}

/** Init */
function Initialize()
{
	if(CREATE_ON_DEMAND==0)
	{
		OnRegisterEvent();
	}

	Me = GetWindowHandle( "AttributeRemoveWnd" );
	txtRemoveAdenaStr = GetTextBoxHandle ( "AttributeRemoveWnd.txtRemoveAdenaStr" );
	txtRemoveAdena = GetTextBoxHandle ( "AttributeRemoveWnd.txtRemoveAdena" );
	txtItemSelectStr = GetTextBoxHandle ( "AttributeRemoveWnd.txtItemSelectStr" );
	ItemWnd = GetItemWindowHandle ("AttributeRemoveWnd.ItemWnd" );
	ItemWndBg = GetTextureHandle ( "AttributeRemoveWnd.ItemWndBg" );
	txtRemoveAdenaBg = GetTextureHandle ( "AttributeRemoveWnd.txtRemoveAdenaBg" );
	ItemWndScrollBg = GetTextureHandle ( "AttributeRemoveWnd.ItemWndScrollBg" );
	btnOK = GetButtonHandle ( "AttributeRemoveWnd.btnOK" );
	btnCancel = GetButtonHandle ( "AttributeRemoveWnd.btnCancel" );

	btnHideBarButton0 = GetButtonHandle ( "AttributeRemoveWnd.btnListSelect0" );
	btnHideBarButton1 = GetButtonHandle ( "AttributeRemoveWnd.btnListSelect1" );
	btnHideBarButton2 = GetButtonHandle ( "AttributeRemoveWnd.btnListSelect2" );

	gageAttributeSelect0 = GetBarHandle ( "AttributeRemoveWnd.gageAttributeSelect0" );
	gageAttributeSelect1 = GetBarHandle ( "AttributeRemoveWnd.gageAttributeSelect1" );
	gageAttributeSelect2 = GetBarHandle ( "AttributeRemoveWnd.gageAttributeSelect2" );

	btnAttributeSelect0 = GetCheckBoxHandle( "AttributeRemoveWnd.btnAttributeSelect0" ); 
	btnAttributeSelect1 = GetCheckBoxHandle( "AttributeRemoveWnd.btnAttributeSelect1" ); 
	btnAttributeSelect2 = GetCheckBoxHandle( "AttributeRemoveWnd.btnAttributeSelect2" ); 

	txtAttributeSelect0 = GetTextBoxHandle ( "AttributeRemoveWnd.txtAttributeSelect0" ); 
	txtAttributeSelect1 = GetTextBoxHandle ( "AttributeRemoveWnd.txtAttributeSelect1" ); 
	txtAttributeSelect2 = GetTextBoxHandle ( "AttributeRemoveWnd.txtAttributeSelect2" ); 

	script = InventoryWnd( GetScript("InventoryWnd") );
	toolTipScript = Tooltip( GetScript( "Tooltip" ) );
	
	attributeWord[0] = "Fire";
	attributeWord[1] = "Water";
	attributeWord[2] = "Wind";
	attributeWord[3] = "Earth";
	attributeWord[4] = "Divine";
	attributeWord[5] = "Dark";

	beforeClickedItem = -1;
	// btnCancel.SetAlpha(0);	
}

/** 속성 해제 라디오 버튼과 게이지, 텍스트등을 초기화, 보이고 안보이기 세팅 */
function initAttributeElements(bool visibleFlag)
{
	txtRemoveAdena.SetText("");

	gageAttributeSelect0.Clear();
	gageAttributeSelect1.Clear();
	gageAttributeSelect2.Clear();

	txtAttributeSelect0.SetText(""); 
	txtAttributeSelect1.SetText(""); 
	txtAttributeSelect2.SetText("");

	btnAttributeSelect0.SetCheck(false);
	btnAttributeSelect1.SetCheck(false);
	btnAttributeSelect2.SetCheck(false);

	if (visibleFlag == false)
	{
		btnAttributeSelect0.HideWindow();
		btnAttributeSelect1.HideWindow();
		btnAttributeSelect2.HideWindow();

		gageAttributeSelect0.HideWindow();
		gageAttributeSelect1.HideWindow();
		gageAttributeSelect2.HideWindow();

		txtAttributeSelect0.HideWindow();
		txtAttributeSelect1.HideWindow(); 
		txtAttributeSelect2.HideWindow();		
	}
	else
	{
		btnAttributeSelect0.ShowWindow();
		btnAttributeSelect1.ShowWindow();
		btnAttributeSelect2.ShowWindow();

		gageAttributeSelect0.ShowWindow();
		gageAttributeSelect1.ShowWindow();
		gageAttributeSelect2.ShowWindow();

		txtAttributeSelect0.ShowWindow();
		txtAttributeSelect1.ShowWindow(); 
		txtAttributeSelect2.ShowWindow();	
	}
}

/****************************************************************************************************
 * 
 *  속성 해제 관련 함수
 *  
 ****************************************************************************************************/

/** 속성 번호를 넣으면 해당 속성 스트링을 리턴 한다. */
function string getAttributeNumToStr(int num)
{
	local string returnStr;
	returnStr = "";

	switch(num)
	{
		case ATTRIBUTE_FIRE:
			returnStr = GetSystemString(1622);
			break;
		case ATTRIBUTE_WATER:
			returnStr = GetSystemString(1623);
			break;
		case ATTRIBUTE_WIND:
			returnStr = GetSystemString(1624);
			break;
		case ATTRIBUTE_EARTH:
			returnStr = GetSystemString(1625);
			break;
		case ATTRIBUTE_HOLY:
			returnStr = GetSystemString(1626);
			break;
		case ATTRIBUTE_UNHOLY:
			returnStr = GetSystemString(1627);
			break;
		default :
			debug("UC Error : 잘못된 속성 타입 번호를 getAttributeNumToStr 메소드에 삽입하였습니다.");
	}

	return returnStr;
}

/** 
 *  속성을 해제를 클라이언트 함수를 호출 한다. 
 *  해제할 번호를 매개변수로 입력  
 **/
function applyAttribute(int attributeNum)
{
	// 선택한 아이템의 정보를 받아온다. 
	ItemWnd.GetSelectedItem(SelectItemInfo);

	if(SelectItemInfo.AttackAttributeValue > 0) 
	{
		// 공격템
		class'EnchantAPI'.static.RequestRemoveAttribute(SelectItemInfo.ID, SelectItemInfo.AttackAttributeType);	
	}
	else
	{
		// 방어템
		class'EnchantAPI'.static.RequestRemoveAttribute(SelectItemInfo.ID, attributeNum);

		// debug(" == > att " $ attributeNum);

	}
}


/****************************************************************************************************
 * 
 *  속성 해제 관련 UI 메소드 
 *  
 ****************************************************************************************************/

/** 속성 해제가 클릭된 경우  */
function OnBtnOkClick()
{
	local string strName;
	local int attributeTypeByRadio;
	local int currentAttributerTypeRadio;

	strName = class'UIDATA_ITEM'.static.GetItemName( SelectItemInfo.ID );


	// debug("==> Attack: " @ SelectItemInfo.AttackAttributeValue);

	attributeTypeByRadio = attributerTypeRadio[getRadioButtonSelected()];

	if(SelectItemInfo.AttackAttributeValue > 0) 
	{
		// debug("==> call  " @ SelectItemInfo.AttackAttributeValue);
		currentAttributerTypeRadio = attributeTypeByRadio;
	}
	else
	{
		// debug("==> def attributeTypeByRadio  " @ attributeTypeByRadio);
		// 반대 속성 맨트를 보여 지도록 세팅, (예: 방어는 물 내성인 경우 불 속성을 가진 경우와 같다)
		if (attributeTypeByRadio == 0)
		{
			currentAttributerTypeRadio = 1;
		}
		else if (attributeTypeByRadio == 1)
		{
			currentAttributerTypeRadio = 0;
		}
		else if (attributeTypeByRadio == 2)
		{
			currentAttributerTypeRadio = 3;
		}
		else if (attributeTypeByRadio == 3)
		{
			currentAttributerTypeRadio = 2;
		}
		else if (attributeTypeByRadio == 4)
		{
			currentAttributerTypeRadio = 5;
		}
		else if (attributeTypeByRadio == 5)
		{
			currentAttributerTypeRadio = 4;
		}		
	}

	// 현재 클라이언트 단에 저장되어 있는 아데나의 값을 얻어서 수수료가 없으면 메세지 출력
	if ( GetAdena() >= Int64(txtRemoveAdena.GetText()) )
	{
		me.DisableWindow();

		DialogSetID( DIALOG_ATTRIBUTE_REMOVE );

		DialogSetReservedInt( attributerTypeRadio[getRadioButtonSelected()] );

		// 3146 : 정말로 $s1의 $s2 속성을 해제하시겠습니까?
		//DialogShow(DialogModalType_Modal, DialogType_Warning, MakeFullSystemMsg( GetSystemMessage(3146), strName, getAttributeNumToStr(attributerTypeRadio[getRadioButtonSelected()])), string(Self));
		DialogShow(DialogModalType_Modalless, DialogType_Warning, MakeFullSystemMsg( GetSystemMessage(3146), strName, getAttributeNumToStr(currentAttributerTypeRadio)), string(Self));
	}
	else
	{
		// 수수료가 부족 하다는 메세지 출력 
		AddSystemMessage(3156);
	}


}

/** 다이얼로그 박스 OK 클릭시 */
function HandleDialogOK()
{
	if (DialogIsMine())
	{
		if( DialogGetID() == DIALOG_ATTRIBUTE_REMOVE )
		{
			// 해제할 속성 적용 
			applyAttribute(DialogGetReservedInt());
			Me.EnableWindow();
		}
	}
}


/** 닫기 버튼을 클릭 */
function OnbtnCancelClick()
{
	Me.HideWindow();
	ItemWnd.Clear();
}

/** 속성 해제 아이템 선택 에서 아이템을 선택 -> OnClickItem 실행 */
function OnClickItem( string strID, int index )
{	
	local ItemInfo infItem;
	local int Price;
	if (strID == "ItemWnd")
	{			
		// 현재 선택된 아이템의 라디오 버튼 상태를 기억
		// 하여 추후 다시 해당 아이템을 클릭 했을때 라디오 버튼 위치를 복구 시키기 위해 사용한다.

		if (beforeClickedItem != -1)
		{
			memoryAttributeSelectedRadio[beforeClickedItem] = getRadioButtonSelected();
		}

		// debug("memoryAttributeSelectedRadio[beforeClickedItem]: " @ memoryAttributeSelectedRadio[index]);
		
		// debug("ItemWnd.GetSelectedNum() :  " @ ItemWnd.GetSelectedNum() @ "  :   " @ getRadioButtonSelected());
		
		ItemWnd.GetItem( index, infItem );				
		
		// 선택한 아이템의 정보를 받아온다. 
		ItemWnd.GetSelectedItem(SelectItemInfo);
		
		btnOK.EnableWindow();
		// getRadioButtonSelected();

		// Load();
		// 게이지와 속성 텍스트를 세팅한다
		// memoryAttributeSelectedRadio[index]

		setAttributeGages(infItem, memoryAttributeSelectedRadio[index]);
		// debug("index selected == > " @ index);

		Price = int(infItem.DefaultPrice);
		txtRemoveAdena.SetText(MakeCostString(string(Price)));

		beforeClickedItem = index;
	}

}

/** 속성 해제 버튼 비활성화로 초기화 */
function HandleAttributeRemoveShow(string param)
{
	//~ local ItemID cID;	
	ItemWnd.Clear();
	initAttributeElements(false);
	btnOK.DisableWindow();				// 처음 뿌려줄 때는 아이템을 선택하지 않았기 때문에 무조건 확인 버튼을 disable 시켜준다. 
	Me.ShowWindow();
	Me.SetFocus();
	Me.EnableWindow();
}

/**  해제할 아이템을 ItemWnd 아이템 윈도우에 등록 시킨다. */
function HandleAttributeRemoveItemData(string param)
{
	local int invenIdx;
	local int i;
	local int Index;
	local INT64 adena;
	local ItemID sID;
	local ItemInfo infItem;
	
	ParseItemID(param, sID);
	ParseINT64(param, "Adena", adena);
	
	// debug ("Param : " @ Param);
	invenIdx = script.m_invenItem.FindItem(sID);		//받은 아이디로 인벤토리의 아이템 인덱스를 뒤진다. 
	// memoryAttributeSelectedRadio
		

	if(invenIdx == -1)						//인벤토리에 없으면 장착창을 뒤진다. 
	{
		for( i = 0; i < EQUIPITEM_Max; ++i )
		{
			Index = script.m_equipItem[ i ].FindItem( sID );	// ServerID
			// 라디오 버튼의 디폴트 상태를 첫번째 것으로 초기화 
			memoryAttributeSelectedRadio[i] = 0;
			// debug("n등록 index :" @  i);

			if( -1 != Index )
			{
				// 라디오 버튼의 디폴트 상태를 첫번째 것으로 초기화 
				memoryAttributeSelectedRadio[i] = 0;

				// debug("등록 index :" @  i);					
				script.m_equipItem[i].GetItem( Index, infItem );
				infItem.DefaultPrice = adena;						//수수료를 DP에 넣어둔다. 
				break;
			}
		}
	}
	else
	{	
		script.m_invenItem.GetItem( invenIdx, infItem );
		infItem.DefaultPrice = adena;					//수수료를 DP에 넣어둔다. 
	}
		
	// item 정보로 판단하여 사용 가능한 아이템만 insert 한다.  - 친절한 UI정책 ^^ - innowind 
	// S급 이상의 무기/ 방어구만 속성 인챈트 가능
	
	//	if((infItem.CrystalType > 4))
	//	{
	ItemWnd.AddItem(infItem);	//해제니까 특별히 걸러줄 필요는 없다. 
	//	}
}

/** 속성 해제가 완료 된 경우 처리 */
function HandleAttributeRemoveResult(string param)
{
	
	local int result, removedAttr;
	local int getItemNum;

	local ItemID sID;

	local ItemInfo targetItem;
	
	// 윈도우를 활성화 시킨다.
	Me.EnableWindow();

	ParseInt(param, "Result", Result );
	ParseInt(param, "RemovedAttr", removedAttr );
	ParseInt(param, "itemID", sID.ServerID );

	sID.ClassID = 0;

	// ParseItemID(param, sID);

	// debug("--> EV_RemoveAttributeEnchantResult" @ Result);
	// debug("--> removedAttr " @ removedAttr);
	// debug("--> item ID:  " @ sID);
	// debug("--> ID " @ itemID);


	// 속성이 삭제된 아이템을 찾고	
	getItemNum = ItemWnd.FindItem(sID);

	// class'UIDATA_ITEM'.static.GetItemInfo(sID, targetItem );

	// getItemNum = script.m_invenItem.FindItem(sID);

	ItemWnd.GetItem(getItemNum, targetItem);

	// debug("아이템      : " @ getItemNum);
	// debug("아이템 이름 : " @ targetItem.Name);
	
	if (Result == 1)
	{
		// 공격 속성이 있다.
		if (targetItem.AttackAttributeValue > 0)
		{
			// debug("공격 무기 속성 해제 : ");
			targetItem.AttackAttributeValue = 0;

			// itemWnd 에서 속성 해제 되어 속성이 남아 있지 않은 아이템 삭제 
			// 공격 속성은 하나이기 때문에 무조건 삭제
			ItemWnd.DeleteItem( getItemNum );		
			memoryAttributeSelectedRadio.Remove(getItemNum, 1);

			// 만약 ItemWnd 에 아이템이 존재 하면 다음 아이템을 자동으로 선택해주고, 아이템이 0이 되면, 창을 닫는다
			if (ItemWnd.GetItemNum() > 0)
			{
				ItemWnd.SetSelectedNum(getItemNum - 1);
				OnClickItem("ItemWnd", getItemNum - 1);
			}
			else
			{
				ItemWnd.Clear();
				initAttributeElements(false);
				btnOK.DisableWindow();
			}
		}
		else if (getDefenseAttributeValue(targetItem) > 0)
		{
				
			// 삭제 되는 속성에 따라 값을 0으로 세팅
			switch( removedAttr )
			{
				case ATTRIBUTE_FIRE :
					targetItem.DefenseAttributeValueFire = 0;
					break;
				case ATTRIBUTE_WATER :
					targetItem.DefenseAttributeValueWater = 0;
					break;
				case ATTRIBUTE_WIND :
					targetItem.DefenseAttributeValueWind = 0;
					break;
				case ATTRIBUTE_EARTH :
					targetItem.DefenseAttributeValueEarth = 0;
					break;
				case ATTRIBUTE_HOLY :
					targetItem.DefenseAttributeValueHoly = 0;
					break;
				case ATTRIBUTE_UNHOLY :
					targetItem.DefenseAttributeValueUnholy = 0;
					break;
			}
			
			// 방어 속성이 남아 있다. 
			if (getDefenseAttributeValue(targetItem) > 0)
			{
				// itemWnd 의 아이템을 갱신 
				ItemWnd.SetItem( getItemNum, targetItem );

				// debug("1 memoryAttributeSelectedRadio[getItemNum] " @ memoryAttributeSelectedRadio[getItemNum]);

				if (memoryAttributeSelectedRadio[getItemNum] > 0) 
				{
					memoryAttributeSelectedRadio[getItemNum] = memoryAttributeSelectedRadio[getItemNum] - 1;
				}
				else
				{
					memoryAttributeSelectedRadio[getItemNum] = 0;
				}

				// 수동으로 이전에 클릭되었던 것을, 자동 정보 갱신을 하지 않도록 한다.
				beforeClickedItem = -1;

				// 만약 ItemWnd 에 아이템이 존재 하면 다음 아이템을 자동으로 선택해주고, 아이템이 0이 되면, 창을 닫는다
				ItemWnd.SetSelectedNum(getItemNum);

				// debug("1.5 memoryAttributeSelectedRadio[getItemNum] " @ memoryAttributeSelectedRadio[getItemNum]);
				OnClickItem("ItemWnd", getItemNum);

				// debug("2 memoryAttributeSelectedRadio[getItemNum] " @ memoryAttributeSelectedRadio[getItemNum]);
				// debug("d SetSelectedNum : " @ getItemNum);
			}
			// 방어 속성이 모두 해제 되었다. itemWnd 에서 삭제 되어야 한다.
			else
			{
				// debug("방어구 속성 해제 : " @ getItemNum);
				// itemWnd 에서 속성 해제 되어 속성이 남아 있지 않은 아이템 삭제 
				ItemWnd.DeleteItem( getItemNum );
				memoryAttributeSelectedRadio.Remove(getItemNum, 1);

				// 만약 ItemWnd 에 아이템이 존재 하면 다음 아이템을 자동으로 선택해주고, 아이템이 0이 되면, 창을 닫는다
				if (ItemWnd.GetItemNum() > 0)
				{
					if (ItemWnd.GetItemNum() == getItemNum)
					{
						ItemWnd.SetSelectedNum(getItemNum - 1);
						OnClickItem("ItemWnd", getItemNum - 1);
						// debug("SetSelectedNum : " @ getItemNum - 1);

					}
					else
					{
						ItemWnd.SetSelectedNum(getItemNum);
						OnClickItem("ItemWnd", getItemNum);
						// debug("SetSelectedNum : " @ getItemNum);
					}
					
				}
				else 
				{
					// 해제할 요소가 없어도 닫히게 하지 않는다. : 기획요소
					// Me.HideWindow();
					// ItemWnd.Clear();
					ItemWnd.Clear();
					initAttributeElements(false);
					btnOK.DisableWindow();
				}
			}

		}
		else
		{

		}
	}
	else
	{
		// 실패 했다면 창을 닫아 준다. (속성해제에는 실패가 없다,  문제가 생긴 경우일때 대비)
		Me.HideWindow();
		ItemWnd.Clear();
	}


	// debug("아이템 : " @ );	// memoryAttributeSelectedRadio.Remove(ItemWnd.GetSelectedNum(), 1);

	//결과에 상관없이 무조건 Hide
	// Me.HideWindow();
	// ItemWnd.Clear();
	
		
}

/** 방어 속성이 설정된 상태 인가? 0이면 방어 속성이 없는것이고 0보다 크면 특정 방어 속성이 세팅된 상태 */
function int getDefenseAttributeValue (ItemInfo targetItem)
{
	return (targetItem.DefenseAttributeValueFire + targetItem.DefenseAttributeValueWater + 
			targetItem.DefenseAttributeValueWind + targetItem.DefenseAttributeValueEarth +
			targetItem.DefenseAttributeValueHoly + targetItem.DefenseAttributeValueUnholy);
}

/** 현재 어떤 라디오 버튼을 눌렀는가 */
function int getRadioButtonSelected()
{
	local int returnValueM;
		
	//local String SelectedRadioButtonName;

	//SelectedRadioButtonName = class'UIAPI_WINDOW'.static.GetSelectedRadioButtonName( "AttributeRemoveWnd", 1 );

	//Debug ("getRadioButtonSelected" @  SelectedRadioButtonName);

	if ( btnAttributeSelect2.IsChecked() ) 
	{
		returnValueM = 2;
	}
	else if ( btnAttributeSelect1.IsChecked() )
	{
		returnValueM = 1;
	}
	else 
	{
		returnValueM = 0;
	}	

	//Debug( "getRadioButtonSelected" @ btnAttributeSelect0.IsChecked() @  btnAttributeSelect1.IsChecked() @  btnAttributeSelect2.IsChecked());
	
	return returnValueM;
}

/** 라디오 버튼을 하나만 클릭 되도록 클릭 */
function setRadioButton (int selectNum)
{
	btnAttributeSelect0.SetCheck(false);
	btnAttributeSelect1.SetCheck(false);
	btnAttributeSelect2.SetCheck(false);

	if (selectNum == 1)
	{
		btnAttributeSelect1.SetCheck(true);
	}
	else if (selectNum == 2)
	{
		btnAttributeSelect2.SetCheck(true);
	}
	else
	{
		btnAttributeSelect0.SetCheck(true);
	}
}

/****************************************************************************************************
 * 
 *  속성 바 컨트롤 세팅
 *  
 ****************************************************************************************************/

/** 속성 게이지 그려주기  (ToolTip 에 있던 내용을 커스터 마이징) */
function setAttributeGages(ItemInfo Item, int selectedRadioButtonNum)
{
	local int i;
	//local int highAttrValue[6];

	local BarHandle currentGage;
	local TextBoxHandle currentTextBox;
	local CheckBoxHandle currentRadioButton;

	for(i = 0; i < 6; i++)
	{
		tooltipStr[i] = "";
	}

	for(i = 0; i < 3; i++)
	{
		// 0~ 5 가지 각 속성을 기억한다. 9999은 세팅 안된 값
		attributerTypeRadio[i] = 999;
	}
	
	initAttributeElements(false);

	radioButtonCount = 0;
	// 공격 아이템 속성
	if (Item.AttackAttributeValue  > 0)
	{
		
		toolTipScript.SetAttackAttribute(Item.AttackAttributeValue,ATTRIBUTE_FIRE);
		toolTipScript.SetAttackAttribute(Item.AttackAttributeValue,ATTRIBUTE_WATER);
		toolTipScript.SetAttackAttribute(Item.AttackAttributeValue,ATTRIBUTE_WIND);
		toolTipScript.SetAttackAttribute(Item.AttackAttributeValue,ATTRIBUTE_EARTH);
		toolTipScript.SetAttackAttribute(Item.AttackAttributeValue,ATTRIBUTE_HOLY);
		toolTipScript.SetAttackAttribute(Item.AttackAttributeValue,ATTRIBUTE_UNHOLY); //레벨과 현제값등을 구한다.

		switch(Item.AttackAttributeType)
		{
			case ATTRIBUTE_FIRE:
				tooltipStr[ATTRIBUTE_FIRE] = GetSystemString(1622) $ " Lv " $ String(toolTipScript.AttackAttLevel[ATTRIBUTE_FIRE]) $ " ("$ GetSystemString(1622) $ " " $ 
											 GetSystemString(55) $ " " $ String(Item.AttackAttributeValue) $")";
			
				break;

			case ATTRIBUTE_WATER:
				tooltipStr[ATTRIBUTE_WATER] = GetSystemString(1623) $ " Lv " $ String(toolTipScript.AttackAttLevel[ATTRIBUTE_WATER]) $ " ("$ GetSystemString(1623) $ " " $ 
											  GetSystemString(55) $ " " $String(Item.AttackAttributeValue) $ ")";
				break;
			case ATTRIBUTE_WIND:
				tooltipStr[ATTRIBUTE_WIND] = GetSystemString(1624) $ " Lv " $ String(toolTipScript.AttackAttLevel[ATTRIBUTE_WIND]) $ " ("$ GetSystemString(1624) $ " " $ 
											 GetSystemString(55) $ " " $String(Item.AttackAttributeValue) $ ")";
				break;
			case ATTRIBUTE_EARTH:
				tooltipStr[ATTRIBUTE_EARTH] = GetSystemString(1625) $ " Lv " $ String(toolTipScript.AttackAttLevel[ATTRIBUTE_EARTH]) $ " ("$ GetSystemString(1625) $ " " $ 
											  GetSystemString(55) $ " " $ String(Item.AttackAttributeValue) $")";
				break;
			case ATTRIBUTE_HOLY:
				tooltipStr[ATTRIBUTE_HOLY] = GetSystemString(1626) $ " Lv " $ String(toolTipScript.AttackAttLevel[ATTRIBUTE_HOLY]) $ " ("$ GetSystemString(1626) $ " " $ 
											 GetSystemString(55) $ " " $String(Item.AttackAttributeValue) $ ")";
				break;
			case ATTRIBUTE_UNHOLY:
				tooltipStr[ATTRIBUTE_UNHOLY] = GetSystemString(1627) $ " Lv " $ String(toolTipScript.AttackAttLevel[ATTRIBUTE_UNHOLY]) $ " ("$ GetSystemString(1627) $ " " $ 
											   GetSystemString(55) $ " " $String(Item.AttackAttributeValue) $ ")";
				break;
		}
	} 
	// 방어 아이템 속성 인 경우
	else
	{
		toolTipScript.SetDefAttribute(Item.DefenseAttributeValueFire,ATTRIBUTE_FIRE);
		toolTipScript.SetDefAttribute(Item.DefenseAttributeValueWater,ATTRIBUTE_WATER);
		toolTipScript.SetDefAttribute(Item.DefenseAttributeValueWind,ATTRIBUTE_WIND);
		toolTipScript.SetDefAttribute(Item.DefenseAttributeValueEarth,ATTRIBUTE_EARTH);
		toolTipScript.SetDefAttribute(Item.DefenseAttributeValueHoly,ATTRIBUTE_HOLY);
		toolTipScript.SetDefAttribute(Item.DefenseAttributeValueUnholy,ATTRIBUTE_UNHOLY); //레벨과 현재값등을 구한다.

		if(Item.DefenseAttributeValueFire != 0) //파이어 속성 툴팁 그리기
		{
			tooltipStr[ATTRIBUTE_FIRE] = GetSystemString(1623) $ " Lv " $ String(toolTipScript.DefAttLevel[ATTRIBUTE_FIRE]) $ " ("$ GetSystemString(1622) $ " " $ 
										 GetSystemString(54) $ " " $ String(Item.DefenseAttributeValueFire) $")";
		}
		if(Item.DefenseAttributeValueWater != 0) //물 속성 툴팁 그리기
		{
			tooltipStr[ATTRIBUTE_WATER] = GetSystemString(1622) $ " Lv " $ String(toolTipScript.DefAttLevel[ATTRIBUTE_WATER]) $ " ("$ GetSystemString(1623) $ " " $ 
										  GetSystemString(54) $ " " $String(Item.DefenseAttributeValueWater) $ ")";
		}
		if(Item.DefenseAttributeValueWind != 0) //바람 속성 툴팁 그리기
		{
			tooltipStr[ATTRIBUTE_WIND] = GetSystemString(1625) $ " Lv " $ String(toolTipScript.DefAttLevel[ATTRIBUTE_WIND]) $ " ("$ GetSystemString(1624) $ " " $ 
										 GetSystemString(54) $ " " $String(Item.DefenseAttributeValueWind) $")";
		}
		if(Item.DefenseAttributeValueEarth != 0) //땅 속성 툴팁 그리기
		{
			tooltipStr[ATTRIBUTE_EARTH] = GetSystemString(1624) $ " Lv " $ String(toolTipScript.DefAttLevel[ATTRIBUTE_EARTH]) $ " ("$ GetSystemString(1625) $ " " $ 
										  GetSystemString(54) $ " " $String(Item.DefenseAttributeValueEarth) $ ")";
		}
		if(Item.DefenseAttributeValueHoly != 0) //신성 속성 툴팁 그리기
		{
			tooltipStr[ATTRIBUTE_HOLY] = GetSystemString(1627) $ " Lv " $ String(toolTipScript.DefAttLevel[ATTRIBUTE_HOLY]) $ " ("$ GetSystemString(1626) $ " " $ 
										 GetSystemString(54) $ " " $ String(Item.DefenseAttributeValueHoly) $")";
		}
		if(Item.DefenseAttributeValueUnholy != 0) //암흑 속성 툴팁 그리기
		{
			tooltipStr[ATTRIBUTE_UNHOLY] = GetSystemString(1626) $ " Lv " $ String(toolTipScript.DefAttLevel[ATTRIBUTE_UNHOLY]) $ " ("$ GetSystemString(1627) $ " " $ 
											GetSystemString(54) $ " " $String(Item.DefenseAttributeValueUnholy) $ ")";
		}
	}

	if (Item.AttackAttributeValue  > 0)//공격속성일경우
	{
		for(i = 0; i < 6; i++)
		{
			// debug("==공격==> " @ tooltipStr[i]);

			if(tooltipStr[i] == "") 
			{   
				continue;
			}
			else 
			{

				// debug("toolTipScript.AttackAttMaxValue[i] ==> " @ toolTipScript.AttackAttMaxValue[i]);
				// debug("toolTipScript.AttackAttCurrValue[i] ==> " @ toolTipScript.AttackAttCurrValue[i]);

				currentGage = GetBarHandle ( "AttributeRemoveWnd.gageAttributeSelect" $ String(radioButtonCount) );
				currentTextBox = GetTextBoxHandle ( "AttributeRemoveWnd.txtAttributeSelect" $ String(radioButtonCount) );
				currentRadioButton = GetCheckBoxHandle( "AttributeRemoveWnd.btnAttributeSelect" $ String(radioButtonCount) ); 

				currentGage.Clear();
				currentGage.SetValue(toolTipScript.AttackAttMaxValue[i], toolTipScript.AttackAttCurrValue[i]);
				setColorBar(currentGage, i);
				
				currentGage.ShowWindow();
				currentTextBox.ShowWindow();
				currentRadioButton.ShowWindow();
					
				currentTextBox.SetText(tooltipStr[i]);		

				// 라디오 버튼이 현재 가진 내성 타입을 기억 시킨다. 
				attributerTypeRadio[radioButtonCount] = i;
				
				/*
				// 첫 번째 라디오 버튼은 선택되어진 상태로 세팅
				if (radioButtonCount == 0)
				{
					btnAttributeSelect0.SetCheck(true);
				}
				*/

		
				radioButtonCount++;
			}

		}
	
	}
	else
	{ 
		//방어 속성일 경우
		for(i = 0; i < 6; i++)
		{
			// debug("==방어==> " @ string(i)  @ " == " @ tooltipStr[i]);
			if(tooltipStr[i] == "") 
			{   
				continue;
			}
			else 
			{
				// debug("toolTipScript.DefAttMaxValue[i] ==> " @ toolTipScript.DefAttMaxValue[i]);
				// debug("toolTipScript.DefAttCurrValue[i] ==> " @ toolTipScript.DefAttCurrValue[i]);

				currentGage = GetBarHandle ( "AttributeRemoveWnd.gageAttributeSelect" $ String(radioButtonCount) );
				currentTextBox = GetTextBoxHandle ( "AttributeRemoveWnd.txtAttributeSelect" $ String(radioButtonCount) );
				currentRadioButton = GetCheckBoxHandle( "AttributeRemoveWnd.btnAttributeSelect" $ String(radioButtonCount) ); 
				
				currentGage.Clear();
				
				currentGage.SetValue(toolTipScript.DefAttMaxValue[i], toolTipScript.DefAttCurrValue[i]);
				setColorBar(currentGage, i);
				
				currentGage.ShowWindow();
				currentTextBox.ShowWindow();
				currentRadioButton.ShowWindow();

				currentTextBox.SetText(tooltipStr[i]);	

				// 라디오 버튼이 현재 가진 내성 타입을 기억 시킨다. 
				attributerTypeRadio[radioButtonCount] = i;
				/*
				// 첫 번째 라디오 버튼은 선택되어진 상태로 세팅
				if (radioButtonCount == 0)
				{
					btnAttributeSelect0.SetCheck(true);
				}
				*/

				radioButtonCount++;
			}

		}
	}

	/*
	if (selectedRadioButtonNum == 1)
	{
		btnAttributeSelect1.SetCheck(true);
	}
	else if (selectedRadioButtonNum == 2)
	{
		btnAttributeSelect2.SetCheck(true);
	}
	else
	{
		btnAttributeSelect0.SetCheck(true);
	}
	*/
	setRadioButton(selectedRadioButtonNum);
}

/**
 * 
 *  게이지 바의 색(텍스쳐를 교체 하여 변화된 색을 표현 하도록 한다.)
 *  변경시킬 barHandler, 각 변화 시킬 타입 번호 (불0, 물1, 바람2, 땅3, 신성4, 암흑5) 
 *  
 **/
function setColorBar(BarHandle bar, int selectNum)
{
	// 0:ForeLeft 1:ForeTexture 2:ForeRightTexture 3:BackLeftTexture 4:BackTexture 5:BackRightTexture
	bar.SetTexture(0, "L2UI_CT1.Gauge_DF_Attribute_" $ attributeWord[selectNum] $ "_Left");
	bar.SetTexture(1, "L2UI_CT1.Gauge_DF_Attribute_" $ attributeWord[selectNum] $ "_Center");
	bar.SetTexture(2, "L2UI_CT1.Gauge_DF_Attribute_" $ attributeWord[selectNum] $ "_Right");
	bar.SetTexture(3, "L2UI_CT1.Gauge_DF_Attribute_" $ attributeWord[selectNum] $ "_Bg_Left");
	bar.SetTexture(4, "L2UI_CT1.Gauge_DF_Attribute_" $ attributeWord[selectNum] $ "_Bg_Center");
	bar.SetTexture(5, "L2UI_CT1.Gauge_DF_Attribute_" $ attributeWord[selectNum] $ "_Bg_Right");	
}


/** 현재 0~ 2 까지 3개의 게이지를 번호에 따라 리턴 한다. */
function BarHandle selectBarHandle(int selectNum)
{
	local BarHandle returnValueM;

	if (selectNum == 0)
	{
		returnValueM = gageAttributeSelect0;
	}
	else if (selectNum == 1)
	{
		returnValueM = gageAttributeSelect1;
	}
	else if (selectNum == 2)
	{
		returnValueM = gageAttributeSelect2;
	}

	return returnValueM;
}
			

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);		
	OnbtnCancelClick();
}
defaultproperties
{
}
