/**
 * 아지트 NPC 배치 보조창
 * 
 * http://wallis-devsub/redmine/issues/2053#change-6920
 * 
 **/
class AgitDecoDrawerWnd extends UICommonAPI;

const DIALOG_ID_ASK_DELOPY = 10212322;

const POWER_ENVOY_TYPE = 1000; //세력 사절단 type
const TOTAL_COMBO_TYPE = 9999; //전체 콤보 타입

var WindowHandle Me;

var TextBoxHandle Title_Faction_text;
var TextBoxHandle Title_NPCtype_text;
var TextBoxHandle Title_NPCcontents_text;

var ComboBoxHandle NPCType_Combobox;

var WindowHandle AgitNPC_ListWnd;
var ListCtrlHandle AgitNPCListCtrl;

var ButtonHandle Place_Button;
var ButtonHandle Close_Button;

var AgitDecoWnd AgitDecoWndScript;

var array<AgitDecoNPCData> AgitDecoNPCDataArray;
var array<AgitDecoNPCTypeList> NpcTypeArray;  

// 슬라이딩 메뉴로 나타날때, 클릭을 방지하는 체크 
var bool listClickedEnable;

function OnRegisterEvent()
{
	RegisterEvent( EV_DialogOK );
	RegisterEvent( EV_DialogCancel );	
}

function OnDrawerHideFinished()
{
	listClickedEnable = false;
}

function OnDrawerShowFinished()
{
	// 업데이트 될때는 클릭 방지를 세팅 해 놓는다.
	listClickedEnable = true;
	// Debug("들어가가 보여진다.");
}

function OnShow()
{
	local int i;
	SetClosingOnESC();

		//Debug("AgitDecoWndScript.getDomainGrade()" @ AgitDecoWndScript.getDomainGrade());
	NpcTypeArray.Length = 0;
	AgitDecoNPCDataArray.Length = 0;

	class'UIDATA_AGIT'.static.GetAllDecoNPCInfo(AgitDecoNPCDataArray, NpcTypeArray, AgitDecoWndScript.getDomainGrade(), AgitDecoWndScript.getDomainArray());

	//Debug("AgitDecoNPCDataArray len:" @ AgitDecoNPCDataArray.Length);
	//Debug("NpcTypeArray len" @ NpcTypeArray.Length);
	// NPCType 컴보박스 전체, 팩션 사절단, 보조마법, 아이템 생산 

	NPCType_Combobox.Clear();
	NPCType_Combobox.AddStringWithReserved(GetSystemString(1046), TOTAL_COMBO_TYPE);

	for(i = 0; i < NpcTypeArray.Length; i++)
	{
		//Debug("NpcTypeArray[i].NpcType" @ NpcTypeArray[i].NpcType);
		//Debug("NpcTypeArray[i].NpcTypeIdx" @ NpcTypeArray[i].NpcTypeIdx);
		NPCType_Combobox.AddStringWithReserved(GetSystemString(NpcTypeArray[i].NpcTypeIdx), NpcTypeArray[i].NpcType);
	}

	if (NpcTypeArray.Length > 0) 
	{
		NPCType_Combobox.SetSelectedNum(0);
		upateAgitDecoNpcData(NPCType_Combobox.GetReserved(0));
	}
}

// npc 콤보다 목록을 업데이트 한다. 
function updateComboAndList(int npcType)
{
	local int i;

	// 팩션 사절단은 팩션 사절단만 나오고
	if (npcType == POWER_ENVOY_TYPE)
	{		
		NPCType_Combobox.AddStringWithReserved(GetSystemString(NpcTypeArray[0].NpcTypeIdx), NpcTypeArray[0].NpcType);
		NPCType_Combobox.DisableWindow();

		upateAgitDecoNpcData(NpcTypeArray[0].NpcType);
	}
	else // 보조마법, 아이템 생산 만 나온다.
	{
		NPCType_Combobox.EnableWindow();

		// NPCType 컴보박스 전체, 팩션 사절단, 보조마법, 아이템 생산 
		NPCType_Combobox.Clear();
		NPCType_Combobox.AddStringWithReserved(GetSystemString(1046), TOTAL_COMBO_TYPE);

		// 세력 사절단을 뺀, 보조 마법, 아이템 생산 만 나오도록 1부터
		for(i = 1; i < NpcTypeArray.Length; i++)
		{
			NPCType_Combobox.AddStringWithReserved(GetSystemString(NpcTypeArray[i].NpcTypeIdx), NpcTypeArray[i].NpcType);
		}

		// 전체를 기본으로 업데이트 한다.
		NPCType_Combobox.SetSelectedNum(0);
		upateAgitDecoNpcData(TOTAL_COMBO_TYPE);
	}
}


// npcID로 아지트 데코 구조체를 리턴 받는다.
function AgitDecoNPCData getAgitDecoNPCDataByNpcID(int npcId)
{
	local int i;
	local AgitDecoNPCData rAgitDecoNPCData;

	for(i = 0; i < AgitDecoNPCDataArray.Length; i++)
	{
		if (AgitDecoNPCDataArray[i].NpcId == npcId)
		{
			rAgitDecoNPCData = AgitDecoNPCDataArray[i];
			break;			
		}
	}

	return rAgitDecoNPCData;
}

//function string getDecoNpcTypeString(int decoNpcType)
//{
//	local int i;

//	for(i = 0; i < NpcTypeArray.Length; i++)
//	{
//		Debug("NpcTypeArray[i].NpcType" @ NpcTypeArray[i].NpcType);
//		Debug("NpcTypeArray[i].NpcTypeIdx" @ NpcTypeArray[i].NpcTypeIdx);

//		if (NpcTypeArray[i].NpcType == decoNpcType)
//		{
//			return GetSystemString(NpcTypeArray[i].NpcTypeIdx);
//		}
//	}

//	return "";
//}

function OnLoad()
{
	Initialize();
}

function Initialize()
{
	Me = GetWindowHandle( "AgitDecoDrawerWnd" );
	
	Title_Faction_text = GetTextBoxHandle( "AgitDecoDrawerWnd.Title_Faction_text" );
	Title_NPCtype_text = GetTextBoxHandle( "AgitDecoDrawerWnd.Title_NPCtype_text" );
	Title_NPCcontents_text = GetTextBoxHandle( "AgitDecoDrawerWnd.Title_NPCcontents_text" );

	NPCType_Combobox = GetComboBoxHandle( "AgitDecoDrawerWnd.NPCType_Combobox" );
	AgitNPCListCtrl  = GetListCtrlHandle( "AgitDecoDrawerWnd.AgitNPC_ListWnd.AgitNPCListCtrl");

	Place_Button = GetButtonHandle( "AgitDecoDrawerWnd.Place_Button" );
	Close_Button = GetButtonHandle( "AgitDecoDrawerWnd.Close_Button" );

	AgitNPCListCtrl.DeleteAllItem();

	// 상해 버전에만 있는 api , 툴팁 관련
	AgitNPCListCtrl.SetSelectedSelTooltip(false);	
	AgitNPCListCtrl.SetAppearTooltipAtMouseX(true);

	AgitDecoWndScript = AgitDecoWnd(GetScript("AgitDecoWnd"));

	AgitDecoNPCDataArray.Length = 0;
}

function upateAgitDecoNpcData(int selectedNpcType)
{	
	local int i, n;

	local int currentDecoNpcType;

	// 배치 비용(툴팁에 전달하기 위해서 String 으로 변환)(아데나, 토큰 정보)
	local string priceTokenParam;

	local L2FactionUIData factionData;

	local string titleStr;
	local bool bDeployMent, bUseButton;
	local int addAdenaCnt;
	
	currentDecoNpcType = AgitDecoWndScript.getCurrentNpcType();

	Debug("currentDecoNpcType" @ currentDecoNpcType);

	AgitNPCListCtrl.DeleteAllItem();
	
	// 사용 안함 , 추가
	if (currentDecoNpcType != POWER_ENVOY_TYPE || (currentDecoNpcType <= 0)) // 팩션 사절단은 팩션 사절단만 나와야 하고, 배치 안함을 사용 하지 않음.
	{
		addItem(GetSystemString(869), priceTokenParam, "", 0, 0, false);
	}

	for (i = 0; i < AgitDecoNPCDataArray.Length; i++)
	{		
		// 같지 않으면 넣지 않음.  
		if (selectedNpcType != AgitDecoNPCDataArray[i].NpcType && selectedNpcType != TOTAL_COMBO_TYPE) continue;

		// 세력 사절단 버튼을 선택한 상황이 아닌 경우, 세력 사절단 목록을 보여주지 않는다.
		if (selectedNpcType != POWER_ENVOY_TYPE && AgitDecoNPCDataArray[i].NpcType == POWER_ENVOY_TYPE) continue;

		// 배치 비용
		priceTokenParam = "";
		addAdenaCnt = 0;
		if (AgitDecoNPCDataArray[i].PriceAdena > 0) addAdenaCnt++;
		ParamAdd(priceTokenParam, "totalCnt", String(addAdenaCnt + AgitDecoNPCDataArray[i].PriceToken.Length));

		// 아데나 
		ParamAdd(priceTokenParam, "item_0", String(57)); // 아데나 ItemId = 57
		ParamAdd(priceTokenParam, "count_0", String(AgitDecoNPCDataArray[i].PriceAdena));
		
			
		// 토큰
		for(n = 0; n < AgitDecoNPCDataArray[i].PriceToken.Length; n++)
		{
			ParamAdd(priceTokenParam, "item_" $ String(n + 1) , String(AgitDecoNPCDataArray[i].PriceToken[n].ItemClassID));
			ParamAdd(priceTokenParam, "count_" $ String(n + 1), String(AgitDecoNPCDataArray[i].PriceToken[n].Cnt));
		}		

		ParamAdd(priceTokenParam, "desc", AgitDecoNPCDataArray[i].Desc);
		ParamAdd(priceTokenParam, "period", String(AgitDecoNPCDataArray[i].Period));

		// http://wallis-devsub/redmine/issues/2113
		// 출력 String 형식  Level + Sub_type_desc + "-" + faction

		// Debug("AgitDecoNPCDataArray[i].FactionType" @ AgitDecoNPCDataArray[i].FactionType);

		if (AgitDecoNPCDataArray[i].FactionType > 0)	
		{
			GetFactionData(AgitDecoNPCDataArray[i].FactionType, factionData);
			titleStr = "Lv." $ AgitDecoNPCDataArray[i].Level $ " " $ 
					    factionData.strFactionName $ "-" $ GetSystemString(AgitDecoNPCDataArray[i].SubTypeIdx);
		}
		else
		{
			titleStr = "Lv." $ AgitDecoNPCDataArray[i].Level $ " " $ 
					   GetSystemString(AgitDecoNPCDataArray[i].SubTypeIdx);
		}

		//Debug("priceTokenParam" @ priceTokenParam);

		// 배치 되었나 체크
		bDeployMent = AgitDecoWndScript.getCurrentDeployMentSlotByNpcID(AgitDecoNPCDataArray[i].DecoNpcId);

		if (bDeployMent) bUseButton = true;
			
		addItem(titleStr, priceTokenParam, AgitDecoNPCDataArray[i].Desc, AgitDecoNPCDataArray[i].Period, AgitDecoNPCDataArray[i].DecoNpcId, bDeployMent);
	}
	// 배치 된 상태에서 팩션 사절단 목록이면 재배치 또는 배치 삭제가 안된다.
	if (bUseButton && currentDecoNpcType == POWER_ENVOY_TYPE)
	{
		Place_Button.DisableWindow();
	}
	else
	{
		Place_Button.EnableWindow();
	}
}

/** 
 * 아이템을 추가 한다.
 * - 스트링, 배치여부  
 **/
function addItem(string viewStr, string tokenPriceParam, string functionDesc, int periodSec, int decoNpcId, bool bDeployment)
{
	local LVDataRecord Record;

	Record.LVDataList.length = 1;

	Record.nReserved1 = decoNpcId;
	Record.nReserved2 = boolToNum(bDeployment);
	// 아이템 

	// "배치중" 인 경우 칼라 값을 다르게 한다.
	if (bDeployment) 
	{
		record.LVDataList[0].buseTextColor = True;
		Record.LVDataList[0].textColor = getColor(238, 170, 34, 255);
		viewStr = viewStr $ " " $ "(" $ GetSystemString(3441) $ ")"; // 배치 중
	}

	// 사용 안 함, 이면 칼라 값을 변경 시킨다.
	if (viewStr == GetSystemString(869))
	{
		record.LVDataList[0].buseTextColor = True;
		Record.LVDataList[0].textColor = getColor(255, 102, 102, 255);
	}
	
	// 리스트 텍스트
	Record.LVDataList[0].szData = viewStr;

	Record.LVDataList[0].textAlignment = TA_Left;
	//	Record.LVDataList[1].HiddenStringForSorting = String(info.ItemNum);

	// 비용, 아데타, 토큰 param 툴팁용
	Record.szReserved = tokenPriceParam;

	AgitNPCListCtrl.InsertRecord( Record );
}

function OnClickButton( string Name )
{
	switch( Name )
	{
		case "Place_Button":
			 OnPlace_ButtonClick();
			 break;

		case "Close_Button":
			 OnClose_ButtonClick();
	 		 break;
	}
}

function OnPlace_ButtonClick()
{
	Debug("배치 클릭");
	selectListNpc();
}

function OnClose_ButtonClick()
{
	Me.HideWindow();
}

//레코드를 클릭하면....
function OnDBClickListCtrlRecord( string ListCtrlID )
{
	switch(ListCtrlID)
	{
		case "AgitNPCListCtrl":
			
			// select = record.LVDataList[0].szData;			
			if (listClickedEnable) selectListNpc();
			break;
	}
}

function selectListNpc()
{
	local LVDataRecord record;
	local int messageNum;
	//select = record.LVDataList[0].szData;			
	
	if(Place_Button.IsEnableWindow())
	{
		if (AgitNPCListCtrl.GetSelectedIndex() >= 0)
		{
			AgitNPCListCtrl.GetSelectedRec( record );

			if (record.nReserved2 == 0)
			{
				Debug("record.LVDataList[0].szData" @ record.LVDataList[0].szData);

				DialogSetID( DIALOG_ID_ASK_DELOPY );

				//  팩션 사절단
				if(AgitDecoWndScript.getCurrentNpcType() == POWER_ENVOY_TYPE)
				{
					///세력 사절단장은 배치 비용이 없습니다. 배치된 세력 사절단장은 배치 기간 만료 전까지 변경이 불가능 하며, 배치 기간 만료되면 자동으로 철수합니다.
					// 계속 진행하시겠습니까?
					messageNum = 4383;
				}
				else 
				{
					// "사용 안 함" 이면..
					if (Record.LVDataList[0].szData == GetSystemString(869))
					{
						//현재 배치되어 있는 전문가를 철수시킵니다. 배치 비용은 환불되지 않습니다. 계속 진행하시겠습니까?
						messageNum = 4384;
					}
					else
					{
						// 배치 비용은 정해진 기간마다 자동으로 혈맹 창고에서 인출되고, 비용이 부족할 경우 자동으로 초기화 됩니다.계속 진행하시겠습니까?
						messageNum = 4366;
					}
				}
				DialogShow(DialogModalType_Modal, DialogType_OKCancel, GetSystemMessage(messageNum) , string(self));
			}
			else
			{
				Debug("이미 배치 된 경우다");
			}
		}
	}
	//DialogShow(DialogModalType_Modal, DialogType_OK, GetSystemMessage( systemMessageNum ) , string(self));	 
}

function OnEvent( int Event_ID, string param )
{
	if ( Event_ID == EV_DialogOK )
	{
		HandleDialogOK();	
	} 
	else if ( Event_ID == EV_DialogCancel )
	{	
		HandleDialogCancel();
	}
}

//선택 이름 삭제 시 확인 버튼 클릭 이벤트 
function HandleDialogOK()
{
	if( DialogIsMine() )
	{
		switch( DialogGetID() )
		{
			case DIALOG_ID_ASK_DELOPY:
				 requestDeployment();
				 break;
		}
	}
}

// 배치를 요청 
function requestDeployment()
{
	local int agitID, slotNum, decoNpcId;
	local LVDataRecord record;

	//select = record.LVDataList[0].szData;			

	AgitNPCListCtrl.GetSelectedRec( record );
	
	agitID    = AgitDecoWndScript.getCurrentAgitID();
	slotNum   = AgitDecoWndScript.getCurrentSelectedSlotNum();
	decoNpcId = int(record.nReserved1);

	class'UIDATA_AGIT'.static.RequestCheckAvailability(agitID, slotNum, decoNpcId);

	Debug("Call---- > RequestCheckAvailability()");
	Debug("agitID:"    @ agitID);
	Debug("slotNum:"   @ slotNum);
	Debug("decoNpcId:" @ decoNpcId);
}


//선택 이름 삭제 시 취소 버튼 클릭 이벤트 
function HandleDialogCancel()
{
	if( DialogIsMine() )
	{
		switch( DialogGetID() )
		{
			case DIALOG_ID_ASK_DELOPY:
		         Debug("안함 아무것도");
				 break;
		}
	}
}

function OnComboBoxItemSelected(string StrID, int IndexID)
{
	switch(strID)
	{
		case "NPCType_Combobox" : 			 
			 upateAgitDecoNpcData(NPCType_Combobox.GetReserved(IndexID));
			 break;
	}
}

function array<AgitDecoNPCTypeList> getNpcTypeArray()
{
	return NpcTypeArray;
}

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
