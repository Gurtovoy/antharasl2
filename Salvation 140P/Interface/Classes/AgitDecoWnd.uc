/**
 *  아지트 NPC 배치 UI
 *  
 *  http://wallis-devsub/redmine/issues/2053#change-6920
 *  http://wallis-devsub/redmine/issues/2113
 *  
 **/
class AgitDecoWnd extends UICommonAPI;

const POWER_ENVOY_TYPE = 1000; //세력 사절단 type

const TOP_MARGIN = 7;
const MAX_SLOT = 5;

// 각 슬롯별 저장 공간 
struct AgitDecoSlotData
{
	var int slotNum;                   // 슬롯 번호 0 부터 시작.
	var int decoNpcID;                 // 데코 npcID
	var int npcType;                   //
	var int factionType;
	var bool bResponseAvailability;    // 배치가 되어 있나?
};

var WindowHandle Me;
var ButtonHandle Close_Button;
var WindowHandle AgitSlot_Scroll;
	
var WindowHandle AgitSlot1, AgitSlot2, AgitSlot3, AgitSlot4, AgitSlot5;

// 사용 하는 슬롯 윈도우 수 
var int nUseSlotNum;

// 현재 선택된 슬롯 정보
var int nCurrentSlotNum;
var int nAgitID;

var array<int> domainArray;
var int domainGrade;

// 현재 슬롯에 배치된 decoNpcID
var int currentDecoNPCId;

var AgitDecoDrawerWnd AgitDecoDrawerWndScript;
var array<AgitDecoSlotData> agitDecoSlotDataArray;

	//getNpcTypeArray
function OnRegisterEvent()
{
	//RegisterEvent(  );
	RegisterEvent( EV_SendAgitFuncInfo );              // 10100
	RegisterEvent( EV_ResponseDecoNPCAvalability );    // 10110
}

function OnLoad()
{
	SetClosingOnESC();
	Initialize();
}

function OnHide()
{
	nCurrentSlotNum = -1;
	nAgitID = -1;
	agitDecoSlotDataArray.Length = 0;

	GetWindowHandle("AgitDecoDrawerWnd").HideWindow();
}

function Initialize()
{	
	Me           = GetWindowHandle( "AgitDecoWnd" );

	Close_Button = GetButtonHandle( "AgitDecoWnd.Close_Button" );

	AgitSlot_Scroll  = GetWindowHandle( "AgitDecoWnd.AgitSlot_ScrollAreaWnd.AgitSlot_Scroll" );

	AgitSlot1 = GetWindowHandle( "AgitDecoWnd.AgitSlot_ScrollAreaWnd.AgitSlot1" );
	AgitSlot2 = GetWindowHandle( "AgitDecoWnd.AgitSlot_ScrollAreaWnd.AgitSlot2" );
	AgitSlot3 = GetWindowHandle( "AgitDecoWnd.AgitSlot_ScrollAreaWnd.AgitSlot3" );
	AgitSlot4 = GetWindowHandle( "AgitDecoWnd.AgitSlot_ScrollAreaWnd.AgitSlot4" );
	AgitSlot5 = GetWindowHandle( "AgitDecoWnd.AgitSlot_ScrollAreaWnd.AgitSlot5" );

	agitDecoSlotDataArray.Length = 0;
	
	AgitDecoDrawerWndScript = AgitDecoDrawerWnd(GetScript("AgitDecoDrawerWnd"));

	hideAllSelect();
	//initWindowLoc();
}

// 윈도우 슬롯 배치(위치 및 스크롤 사이즈 세팅)
function initWindowLoc()
{
	local int i, nWndWidth, nWndHeight;

	//nUseSlotNum = 2;

	// 전체 슬롯 윈도우 보여줄 수량 만큼 show, hide 
	for(i = 1; i <= MAX_SLOT ;i++)	
	{
		if (i <= nUseSlotNum) getAgitSlotWnd(i).ShowWindow();
		else getAgitSlotWnd(i).HideWindow();
	}

	// 다음 윈도우의 앵커를 수정해준다. 
	for(i = 2; i <= nUseSlotNum ;i++)	
	{
		getAgitSlotWnd(i - 1).GetWindowSize(nWndWidth, nWndHeight);
		getAgitSlotWnd(i).ClearAnchor();
		getAgitSlotWnd(i).SetAnchor("AgitDecoWnd.AgitSlot_ScrollAreaWnd.AgitSlot" $ string(i - 1), 
						 "BottomCenter", "TopCenter", 0, TOP_MARGIN);
	}
		
	// 스크롤 사이즈를 재설정
	getAgitSlotWnd(nUseSlotNum - 1).GetWindowSize(nWndWidth, nWndHeight);
	AgitSlot_Scroll.SetScrollHeight((nWndHeight + TOP_MARGIN) * nUseSlotNum);
}

// 설정 정보 뷰 윈도우1~5
function WindowHandle getAgitSlotWnd(int i)
{
	return GetWindowHandle("AgitDecoWnd.AgitSlot_ScrollAreaWnd.AgitSlot" $ String(i));
}

// 슬롯 윈도우가 선택되면 선택되었다는 표시의 텍스쳐를 보여준다. 그걸 끄고 키는 기능
function setSelectSlot(int index, bool flag)
{
	if (flag)
	{
		GetTextureHandle("AgitDecoWnd.AgitSlot_ScrollAreaWnd.AgitSlot" $ index $ ".AgitSlot" $ index $ "_Selectbox_texture").ShowWindow();
		GetWindowHandle("AgitDecoDrawerWnd").ShowWindow();
		GetWindowHandle("AgitDecoDrawerWnd").SetFocus();

		GetTextBoxHandle("AgitDecoDrawerWnd.Title_Faction_text").SetText
			(GetTextBoxHandle("AgitDecoWnd.AgitSlot_ScrollAreaWnd.AgitSlot" $ index $ ".AgitSlot" $ index $ "Title_text").GetText());
	}
	else 
	{
		GetTextureHandle("AgitDecoWnd.AgitSlot_ScrollAreaWnd.AgitSlot" $ index $ ".AgitSlot" $ index $ "_Selectbox_texture").HideWindow();
	}

	nCurrentSlotNum = index - 1;	 
}

// 선택 텍스쳐 전부 안보이게..
function hideAllSelect()
{
	local int i;
	for(i = 1; i <= MAX_SLOT; i++) setSelectSlot(i, false);		
}

// 슬롯 윈도우 각항목에 값을 넣는다.
function setAgitSlotPropert(int index, string title, string npcName, string npcDesc, int remainingPeriodSec)
{
	local int dotWidth, dotHeight;

	Debug("-----------------------------------------");
	Debug("index:" @ index);
	Debug("title:" @ title);
	Debug("npcName:" @ npcName);
	Debug("npcDesc:" @ npcDesc);
	Debug("remainingPeriodSec:" @ remainingPeriodSec);

	GetTextBoxHandle("AgitDecoWnd.AgitSlot_ScrollAreaWnd.AgitSlot" $ index $ ".AgitSlot" $ index $ "Title_text").SetText(title);
	GetTextBoxHandle("AgitDecoWnd.AgitSlot_ScrollAreaWnd.AgitSlot" $ index $ ".AgitSlot" $ index $ "NPCname_text").SetText(npcName);

	// npcDesc 길이 pixel
	GetTextSize(npcDesc, "GameDefault", dotWidth, dotHeight);
	if (dotWidth > 185) 
	{		
		GetTextBoxHandle("AgitDecoWnd.AgitSlot_ScrollAreaWnd.AgitSlot" $ index $ ".AgitSlot" $ index $ "_ItemContents_text").SetText(makeShortStringByPixel(npcDesc, 186, ".."));
		GetButtonHandle("AgitDecoWnd.AgitSlot_ScrollAreaWnd.AgitSlot" $ String(index) $ ".AgitSlot" $ index $ "_MouseOverButton").SetTooltipType("text");
		GetButtonHandle("AgitDecoWnd.AgitSlot_ScrollAreaWnd.AgitSlot" $ String(index) $ ".AgitSlot" $ index $ "_MouseOverButton").SetTooltipCustomType(MakeTooltipSimpleText(npcDesc, 200));
	}
	else
	{
		GetTextBoxHandle("AgitDecoWnd.AgitSlot_ScrollAreaWnd.AgitSlot" $ index $ ".AgitSlot" $ index $ "_ItemContents_text").SetText(npcDesc);
		GetButtonHandle("AgitDecoWnd.AgitSlot_ScrollAreaWnd.AgitSlot" $ String(index) $ ".AgitSlot" $ index $ "_MouseOverButton").ClearTooltip();		
	}

	if (remainingPeriodSec >= 0)
		GetTextBoxHandle("AgitDecoWnd.AgitSlot_ScrollAreaWnd.AgitSlot" $ index $ ".AgitSlot" $ index $ "_ItemDateContents_text").SetText(getStringDayAndTime(remainingPeriodSec));
	else 
		GetTextBoxHandle("AgitDecoWnd.AgitSlot_ScrollAreaWnd.AgitSlot" $ index $ ".AgitSlot" $ index $ "_ItemDateContents_text").SetText(GetSystemString(27));
}

function OnEvent( int Event_ID, string param )
{
	// npc에게 대화를 걸어서 최초 오픈 할때..
	if (Event_ID == EV_SendAgitFuncInfo)
	{		
		sendAgitFuncInfoHandler(param);		
	} 
	// deco npc를 배치 한 결과
	else if (Event_ID == EV_ResponseDecoNPCAvalability)
	{
		ResponseDecoNPCAvalabilityHandler(param);
	}
}

/**
    deco npc를 배치 한 결과

	■SlotNum : 배치할 슬롯의 번호
	■ResponseAvailability (bool 값, true 면 설치가능, false 면 불가)
	■DecoNPCId : 서버로부터 확인받은 데코 npc 의 id
*/
function ResponseDecoNPCAvalabilityHandler(string param)
{
	local int result;
	//local int decoNPCId, expireTime, slotNum;
		
	// ParseInt( param, "SlotNum"  , slotNum );
	ParseInt( param, "Result", result );
	// ParseInt( param, "DecoNPCId", decoNPCId );
	// ParseInt( param, "ExpireTime ", expireTime );

	Debug("결과 ---> ResponseDecoNPCAvalability param : " @ param); 

	// 0 인 경우가 성공, 목록 갱신
	if (result == 0) class'UIDATA_AGIT'.static.RequestOpenDecoNPC(nAgitID);
}

// 고정된 슬롯 이름을 리턴한다. (기획쪽에서 정해준..)
function string getSlotName(int slotNum)
{   
	local string slotName;

	if(slotNum == 0)
	{
		// 팩션 사절단
		slotName = GetSystemString(3432);
	}
	else
	{
		// 전문가 및 장식품 1~
		slotName = GetSystemString(3447) $ " " $ string(slotNum);
	}

	return slotName;
}

/**
 * 
	■AgitID : 현재 UI 를 띄울 아지트의 id
	■TotalCnt : int, -1이면 창을 열 권한이 없음. 0 >= 이면 현재 가지고있는 deco npc 수
	(아래 값들은 TotalCnt 수만큼 패킹되어 전달됨)
	■SlotNum : 어느 슬롯에 배치되어 있는지
	■subType : UI 에 표기될 엔피씨 종류 이름으로, SysString 에서 치환 가능
	■Desc : 해당 특수기능 npc 에 대한 설명
	■RemainingPeriod : 남은 사용가능기간 -> 초 단위로 전달됨 
	■몇일 까지 -> 몇일 남음 으로 변경
*/
function sendAgitFuncInfoHandler(string param)
{
	local int totalCnt, slotNum, subType, remainingPeriodSec, factionType, decoNpcId, npcType;
	local string npcDesc, npcStr;
	local int domainCnt, domainValue;
	local int i, level;

	local L2FactionUIData factionData;

	Debug("sendAgitFuncInfoHandler Param: " @ param);

	ParseInt( param, "AgitID"  , nAgitID );
	ParseInt( param, "TotalCnt", totalCnt );

	if (totalCnt <= -1) return;
	else if(!Me.IsShowWindow()) Me.ShowWindow();

	// 보조창도 닫아 놓는다.
	GetWindowHandle("AgitDecoDrawerWnd").HideWindow();

	ParseInt( param, "Grade"    , domainGrade );
	ParseInt( param, "DomainCnt", domainCnt  );
	
	agitDecoSlotDataArray.Length = 0;
	domainArray.Length = 0;

	hideAllSelect();

	//Debug("domainCnt" @ domainCnt);

	for(i = 0; i < domainCnt; i++)
	{
		ParseInt( param, "Domain_" $ string(i), domainValue );	

		domainArray.Insert(domainArray.Length, 1);
		domainArray[i] = domainValue;

		//Debug("domainValue" @ domainValue);
	}

	// Debug("domainArray len " @ domainArray.Length);

	// 윈도우 슬롯 배치(위치 및 스크롤 사이즈 세팅)
	nUseSlotNum = totalCnt;
	initWindowLoc();

	for (i = 0; i < totalCnt; i++)
	{	
		npcType = 0;
		ParseInt( param, "SlotNum_" $ i, slotNum );
		ParseInt( param, "SubType_" $ i, subType );
		ParseInt( param, "RemainingPeriod_" $ i, remainingPeriodSec );
		ParseInt( param, "FactionType_" $ i, factionType );
		ParseInt( param, "DecoNPCId_" $ i, decoNpcId );
		ParseInt( param, "Level_" $ i, level );
		ParseInt( param, "NPCType_" $ i, npcType );

		ParseString( param, "Desc_" $ i, npcDesc);

		agitDecoSlotDataArray.Insert(agitDecoSlotDataArray.Length, 1);

		agitDecoSlotDataArray[i].slotNum = i;
		if (decoNpcId > 0) agitDecoSlotDataArray[i].bResponseAvailability = true;
		else agitDecoSlotDataArray[i].bResponseAvailability = false;
		agitDecoSlotDataArray[i].decoNpcID = decoNpcId;
		agitDecoSlotDataArray[i].factionType = factionType;

		// slotNum == 0 이면 세력 사절단이다. 세력 사절단의 npcType은 1000
		if (slotNum == 0)
			agitDecoSlotDataArray[i].npcType = POWER_ENVOY_TYPE;
		else 
			agitDecoSlotDataArray[i].npcType = npcType;
		
		if (factionType > 0)	
		{
			GetFactionData(factionType, factionData);
			npcStr = "Lv." $ level $ " " $ factionData.strFactionName $ "-" $ GetSystemString(subType);
		}
		else
		{
			npcStr = "Lv." $ level $ GetSystemString(subType);
		}
		
		// decoNpcId 값 여부에 따라 배치된 npc가 있냐 없냐를 판단한다.
		if(decoNpcId > 0)
		{
			setAgitSlotPropert(slotNum + 1, getSlotName(slotNum), npcStr, npcDesc, remainingPeriodSec);
		}
		else
		{
			setAgitSlotPropert(slotNum + 1, getSlotName(slotNum), GetSystemString(27), GetSystemString(27), -1);
		}
	}
}

function OnClickButton( string Name )
{
	switch( Name )
	{
		case "Close_Button":
			 OnClose_ButtonClick();
			 break;
			
		case "AgitSlot1_MouseOverButton" : hideAllSelect(); setSelectSlot(1, true); AgitDecoDrawerWndScript.updateComboAndList(getCurrentNpcType()); break;
		case "AgitSlot2_MouseOverButton" : hideAllSelect(); setSelectSlot(2, true); AgitDecoDrawerWndScript.updateComboAndList(getCurrentNpcType()); break;
		case "AgitSlot3_MouseOverButton" : hideAllSelect(); setSelectSlot(3, true); AgitDecoDrawerWndScript.updateComboAndList(getCurrentNpcType()); break;
		case "AgitSlot4_MouseOverButton" : hideAllSelect(); setSelectSlot(4, true); AgitDecoDrawerWndScript.updateComboAndList(getCurrentNpcType()); break;
		case "AgitSlot5_MouseOverButton" : hideAllSelect(); setSelectSlot(5, true); AgitDecoDrawerWndScript.updateComboAndList(getCurrentNpcType()); break;
	}
}

function OnClose_ButtonClick()
{
	Me.HideWindow();
}

//---------------------------------------------------------------------------------------------------------
// 외부에서 정보 꺼내 갈 수 있는 함수
//---------------------------------------------------------------------------------------------------------
// 현재 선택되어 있는 슬롯의 번호 -1 이면 선택 안된 값
function int getCurrentSelectedSlotNum()
{
	return nCurrentSlotNum;
}

function int getCurrentAgitID()
{
	return nAgitID;
}

function int getDomainGrade()
{
	return domainGrade;
}

function array<int> getDomainArray()
{
	return domainArray;
}

// 현재 배치된 슬롯인가? , decoNpcID로 검사 
function bool getCurrentDeployMentSlotByNpcID(int decoNpcID)
{
	local int i;

	for(i = 0; i < agitDecoSlotDataArray.Length; i++)
	{
		
		if (agitDecoSlotDataArray[i].slotNum == nCurrentSlotNum)
		{
			if (agitDecoSlotDataArray[i].decoNpcID == decoNpcID)
			{
				return true;
			}
		}
	}

	return false;
}


// 현재 슬롯의 팩션 타입
function int getCurrentFactionTypeBySlotNum(int slotNum)
{
	local int i;

	for(i = 0; i < agitDecoSlotDataArray.Length; i++)
	{
		
		if (agitDecoSlotDataArray[i].slotNum == slotNum)
		{
			return agitDecoSlotDataArray[i].factionType;
		}
	}

	return -1;
}


function onShow () 
{
	Me.SetFocus();
}


// 현재 배치된 슬롯인가? , decoNpcID로 검사 
function int getCurrentNpcType()
{
	local int i;

	for(i = 0; i < agitDecoSlotDataArray.Length; i++)
	{		
		if (agitDecoSlotDataArray[i].slotNum == nCurrentSlotNum)
		{
			return agitDecoSlotDataArray[i].npcType;
		}
	}

	return -1;
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
