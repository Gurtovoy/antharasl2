//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : 결정화 시스템 
//
// 내용         : 4차 전직 이후에는 드워프이외의 모든 종족이 결정화를 할 수 있다.
//                결정화 시 결정 뿐만아니라 랜덤으로 다른 보상 아이템등을 받을 수 있는 기능이 추가 되었다.
//                결정화 윈도우를 호출하는 부분은 InventoryWnd.uc 이다.
//------------------------------------------------------------------------------------------------------------------------

class CrystallizationWnd extends UICommonAPI;

const LINE_MAX = 6;

var string       m_WindowName;
var WindowHandle Me;

var ItemWindowHandle CrystallizationItem;
var TextBoxHandle CrystallizationItemName;
var WindowHandle CrystallizationGetItemWnd;

var ButtonHandle OKButton;
var ButtonHandle CancelButton;

// 결정화 시도할 아이템 정보
var ItemInfo tryItemInfo;

// 결정화 후 나올 아이템 Height 
var int cHeight;

// 결정화 습득 아이템 수 
var int lineCount;

var bool isCrystallizeItem;

/**
 * 
 * OnRegisterEvent
 * 
 **/
function OnRegisterEvent()
{
	//RegisterEvent(EV_Restart);
	RegisterEvent(EV_CrystalizingEstimationList);
	RegisterEvent(EV_CrystalizingEstimationListEnd);
	RegisterEvent(EV_CrystalizingFail);	
}

/**
 *  
 * OnLoad
 * 
 **/
function OnLoad()
{
	SetClosingOnESC();

	Initialize();
	PlayConsoleSound(IFST_WINDOW_OPEN);
}

function onShow()
{
	// 지정한 윈도우를 제외한 닫기 기능 
	isCrystallizeItem = false;
	getInstanceL2Util().ItemRelationWindowHide(getCurrentWindowName(String(self)), "InventoryWnd");
}

function onHide()
{
	//ㅇㅋ 버튼 눌럿으면 취소하지 말아라 > x로 창을 닫을 때, 판매 대행 시스템이 등록 되지 않는 문제로 추가 됨 121106
	if ( isCrystallizeItem )
	{
		RequestCrystallizeItem(tryItemInfo.ID, 1);
	}
	else 
	{
		RequestCrystallizeItemCancel();
	}
}

/**
 * 
 * Initialize
 * 
 **/
function Initialize()
{
	Me = GetWindowHandle( "CrystallizationWnd" );

	CrystallizationItem       = GetItemWindowHandle( "CrystallizationWnd.CrystallizationItem" );
	CrystallizationItemName   = GetTextBoxHandle( "CrystallizationWnd.CrystallizationItemName" );
	CrystallizationGetItemWnd = GetWindowHandle( "CrystallizationWnd.CrystallizationGetItemWnd" );

	OKButton     = GetButtonHandle( "CrystallizationWnd.OKButton" );
	CancelButton = GetButtonHandle( "CrystallizationWnd.CancelButton" );
}

/**
 *
 *  결정화시스템 관련이벤트
 *  const EV_CrystalizingEstimationList = 5140; //결정화 견적
 *  const EV_CrystalizingEstimationListEnd = 5141; //결정화 견적 종료
 *  const EV_CrystalizingFail = 5142; //결정화 실패
 **/
function OnEvent(int Event_ID, string param)
{

	//debug("Event_ID :" @ Event_ID @ " param:" @ param);

	switch( Event_ID )
	{
		case EV_CrystalizingEstimationList:
			getCrystalizingEstimation(param);
			break;

		case EV_CrystalizingEstimationListEnd:

			showCrystalizingEstimationList();
			break;

		case EV_CrystalizingFail:

			// 결정화 취소 
			cancelCystallizeItem();
			break;
	}
}

/**
 * 인벤토리에서 결정화 할 아이템의 아이템 정보를 보낸다.
 * 결정화를 시도 하면 인벤토리에서 이 함수를 호출 한다.
 * 즉 가장 먼저 실행되는 함수다.
 **/
function setItemInfo( ItemInfo cItemInfo)
{
	local int lineNum;

	// 혹시 있을 이전 작업들을 취소
	RequestCrystallizeItemCancel();

	tryItemInfo = cItemInfo;

	cHeight = 0;
	lineCount = 0;	

	CrystallizationItem.Clear();
	CrystallizationItemName.SetText("");

	for (lineNum = 1; lineNum <= LINE_MAX; lineNum++)
	{
		GetItemWindowHandle( "CrystallizationWnd.CrystallizationGetItemWnd.CrystallizationGetItem0" $ lineNum).Clear();
		GetTextBoxHandle( "CrystallizationWnd.CrystallizationGetItemWnd.CrystallizationGetItemName0" $ lineNum).SetText("");
		GetTextBoxHandle( "CrystallizationWnd.CrystallizationGetItemWnd.CrystallizationGetItemCount0" $ lineNum).SetText("");
		GetTextBoxHandle( "CrystallizationWnd.CrystallizationGetItemWnd.CrystallizationItemProbability0" $ lineNum).SetText("");
	}
}
/**
 *  아이템을 결정화 했을때 나오는 아이템 리스트를 받는다.
 **/
function getCrystalizingEstimation( string param )
{
	local int nitemID;
	local int crystalCnt;
	local float probability;
	
	local ItemID   cItemID;
	local ItemInfo cItemInfo;

	lineCount++;

	CrystallizationItem.AddItem(tryItemInfo);
	//CrystallizationItemName.SetText(tryItemInfo.Name);

	getInstanceL2Util().textBox_setToolTipWithShortString(CrystallizationItemName, tryItemInfo.Name, -4);

	CrystallizationItem.SetSelectedNum(0);
	
	ParseInt(param, "ItemID", nitemID);
	ParseInt(param, "CrystalCnt", crystalCnt);
	ParseFloat(param, "Probability", probability);
	
	//cItemID.ClassID = nitemID;
	cItemID = GetItemID(nitemID);
	
	class'UIDATA_ITEM'.static.GetItemInfo(cItemID, cItemInfo );
	
	//cItemInfo.Description = class'UIDATA_ITEM'.static.GetItemDescription(cItemID);
	// cItemInfo.Weight = class'UIDATA_ITEM'.static.GetItemWeight(cItemID);
	cItemInfo.ItemNum = INT64(crystalCnt);
	
	//Debug(cItemInfo.Description);

	// 툴팁에 나오게 하기 위해서 전체 무게를 구한다.

	//cItemInfo.Weight = class'UIDATA_ITEM'.static.GetItemWeight(infItem.ID);
	// cItemInfo.Weight = 1000;
	// Debug("nitemID" @ nitemID);
	// Debug("무게:"@ class'UIDATA_ITEM'.static.GetItemWeight(cItemID));
	
	setItemLine(lineCount, cItemInfo, crystalCnt, probability);	
}


/**
 * 창을 열고 리사이즈를 통해서 정당한 크기로 조절 한다.
 **/
function showCrystalizingEstimationList ()
{

	cHeight = cHeight + (38 * (5 - lineCount));
	CrystallizationGetItemWnd.SetWindowSize(286, (194 - cHeight) );

//	Me.SetWindowSize(298, 420 - (cHeight));
	
	Me.ShowWindow();
	Me.SetFocus();
}

/**
 *  아이템을 결정화 했을때 나오는 아이템 리스트를 받는다.
 *   - 경정화 시 획득 가능 아이템 의 아이템 라인 번호
 *   - itemInfo 
 *   - 획득 가능한 아이템 수 
 *   - 획득 가능성
 **/
function setItemLine(int lineNum, ItemInfo cItemInfo, int crystalCnt, float probability)
{
	local string probabilityStr;
	local array<string>	arrSplit;
	local TextBoxHandle tx;

	if (probability <= 10)
	{
		probabilityStr = "???";
	}
	else
	{
		if (probability == 100)
		{
			probabilityStr = "100%";
			
		}
		else
		{
			// 소수점 99.00 두자리 만 나오도록..
			Split( string(probability), ".", arrSplit);
			if (arrSplit.Length == 2)
			{
				if (Len(arrSplit[1]) >= 2)
				{
					probabilityStr = arrSplit[0] $ "." $ Mid(arrSplit[1],0,2) $ "%";
				}
				else 
				{
					
					probabilityStr = string(probability) $ "%";
				}
			}
			else
			{
				probabilityStr = string(probability) $ "%";
			}
		}
	}

	GetItemWindowHandle( "CrystallizationWnd.CrystallizationGetItemWnd.CrystallizationGetItem0" $ lineNum).AddItem(cItemInfo);
	//GetTextBoxHandle( "CrystallizationWnd.CrystallizationGetItemWnd.CrystallizationGetItemName0" $ lineNum).SetText(cItemInfo.Name);

	tx = GetTextBoxHandle( "CrystallizationWnd.CrystallizationGetItemWnd.CrystallizationGetItemName0" $ lineNum);
	getInstanceL2Util().textBox_setToolTipWithShortString(tx, cItemInfo.Name, -7);
	
	GetTextBoxHandle( "CrystallizationWnd.CrystallizationGetItemWnd.CrystallizationGetItemCount0" $ lineNum).SetText(string(crystalCnt) $ GetSystemString(932));	
	GetTextBoxHandle( "CrystallizationWnd.CrystallizationGetItemWnd.CrystallizationItemProbability0" $ lineNum).SetText(probabilityStr);
}

/**
 *  OnClickButton
 **/
function OnClickButton( string Name )
{
	switch( Name )
	{
		case "OKButton":
			OnOKButtonClick();

			break;
		case "CancelButton":
			cancelCystallizeItem();
			break;
	}
}

/**
 *  결정화 하기
 **/
function OnOKButtonClick()
{
	isCrystallizeItem = true;
		
	Me.HideWindow();
}

/**
 *  결정화 취소
 **/
function cancelCystallizeItem()
{		
	Me.HideWindow();
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	cancelCystallizeItem();
}

defaultproperties
{
    m_WindowName="CrystallizationWnd"
}
