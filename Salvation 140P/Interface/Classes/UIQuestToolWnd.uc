/**
 *   GetQuestWnd 와 GmFindTreeWnd 를 조합해서 퀘스트 검색 툴 하나 만들었음 by Dongland
 *   
 *   이것도 개인용 용도라서.. 그냥 대략 짜집기로 만든거라.. 사용할 사람만.. -_-)/
 *
 **/
class UIQuestToolWnd extends UICommonAPI;

const TIMER_ID_CHANGETEXT    = 10234567;
const TIMER_ID_UPDATELOCINFO = 10234568;

var WindowHandle   Me;
var ListCtrlHandle questListCtrl;
var HtmlHandle     QuestHtmlViewer;
var ButtonHandle   searchItemBtn;
//var ComboBoxHandle QuestTypeComboBox;
//var ComboBoxHandle QuestGradeComboBox;
var EditBoxHandle  searchEditBox;
var EditBoxHandle  itemCountEditBox;
//var EditBoxHandle  descViewEditBox;
var ButtonHandle   InitBtn;
var ButtonHandle   getItemBtn;
//var TextBoxHandle  ItemDescTextBox;
var TextBoxHandle  etcTextBox;
var TextBoxHandle  cTextBox;

var TextBoxHandle  playerLocText;


var Color Gold;
// var MinimapCtrlHandle QuestMinimap;

var HtmlHandle        DetailInfoHtmlCtrl;

var string htmlMsg;
var string QuestDescription;
var string selectNPCName; // 선택한 npc이름

var int freeNum;        // 무료아이템
var int chargeNum;      // 유료아이템
var int selectQuestId;  // 선택한 퀘스트 아이디 
var int bicIconLen;

var ItemInfo BIT_itemInfo;
var Color redColor;

var bool apiChk;

function OnRegisterEvent()
{
	//RegisterEvent(  );
}

function OnLoad()
{
	SetClosingOnESC(); 
	//getInstanceUIData().addEscCloseWindow(getCurrentWindowName(string(Self)));	
	Initialize();
}

function Initialize()
{
	Me              = GetWindowHandle( "UIQuestToolWnd" );
	QuestListCtrl   = GetListCtrlHandle( "UIQuestToolWnd.QuestListCtrl" );
	QuestHtmlViewer = GetHtmlHandle( "UIQuestToolWnd.QuestHtmlViewer" );
	searchItemBtn   = GetButtonHandle( "UIQuestToolWnd.searchItemBtn" );

	//QuestTypeComboBox  = GetComboBoxHandle( "UIQuestToolWnd.QuestTypeComboBox" );
	//QuestGradeComboBox = GetComboBoxHandle( "UIQuestToolWnd.QuestGradeComboBox" );
	searchEditBox      = GetEditBoxHandle( "UIQuestToolWnd.searchEditBox" );
	itemCountEditBox   = GetEditBoxHandle( "UIQuestToolWnd.itemCountEditBox" );
	// descViewEditBox    = GetEditBoxHandle( "UIQuestToolWnd.descViewEditBox" );

	InitBtn    = GetButtonHandle( "UIQuestToolWnd.InitBtn" );
	getItemBtn = GetButtonHandle( "UIQuestToolWnd.getItemBtn" );

	// ItemDescTextBox = GetTextBoxHandle( "UIQuestToolWnd.ItemDescTextBox" );
	// QuestMinimap    = GetMinimapCtrlHandle( "UIQuestToolWnd.QuestMinimap" );

	DetailInfoHtmlCtrl = GetHtmlHandle("UIQuestToolWnd.DetailInfoHtmlCtrl");
	etcTextBox         = GetTextBoxHandle("UIQuestToolWnd.etcTextBox");
	cTextBox           = GetTextBoxHandle("UIQuestToolWnd.cTextBox");
	playerLocText      = GetTextBoxHandle("UIQuestToolWnd.playerLocText");

	Gold.R = 176;
	Gold.G = 153;
	Gold.B = 121;
	Gold.A = 100;
}

function OnTimer(int TimerID)
{
	local Vector pVec;
	local ELanguageType Language;	

	if (TimerID == TIMER_ID_CHANGETEXT)
	{
		Language = GetLanguage();

		if( Language == LANG_Korean)
		{	
			switch(Rand(7))
			{
				case  1 : cTextBox.SetText("검색한 퀘스트 목록에서 더블 클릭을 하면, 해당 퀘스트만 재검색 된다."); break;
				case  2 : cTextBox.SetText("지역, 퀘스트제목, 각 단계,npc 명으로 모두 검색이 가능하다."); break;
				case  3 : cTextBox.SetText("QuestName-k 정보와 UIDATA_Quest API를 사용해서 만들어졌다."); break;
				case  4 : cTextBox.SetText("Dongland에게 후원금 및 물품을 넣으면 기능이 향상 될수 있다."); break;
				case  5 : cTextBox.SetText("(-_-)/~~~~이 글은 한글 버전에서만 보입니다~ "); break;
				case  6 : cTextBox.SetText("중국 리니지2를 위한 퀘스트 검색 툴입니다."); break;
				default : cTextBox.SetText("아직 문제가 있는지 어떤지 테스트가 안되서 값에 버그가 있을 수 있으니 확인이 필요하다."); break;
			}
		}
	}
	else if (TimerID == TIMER_ID_UPDATELOCINFO) 
	{
		pVec = GetPlayerPosition();

		playerLocText.SetText("CurrentPlayer Position" $ "\\nx" $ int(pVec.x) $ " y" $ int(pVec.Y) $ " z" $ int(pVec.z));
	}
}

function OnShow()
{
	Me.KillTimer(TIMER_ID_CHANGETEXT);
	Me.SetTimer(TIMER_ID_CHANGETEXT, 10000);

	Me.KillTimer(TIMER_ID_UPDATELOCINFO);
	Me.SetTimer(TIMER_ID_UPDATELOCINFO, 100);

}

function OnHide()
{
	Me.KillTimer(TIMER_ID_CHANGETEXT);
}

function OnClickButton( string Name )
{
	switch( Name )
	{
		case "searchItemBtn":
			 OnsearchItemBtnClick();
			 break;

		case "InitBtn":
			 OnInitBtnClick();
			 break;

		case "getQuestButton":
			 getQuestButtonClick();
			 break;

		case "MoveStartNPCButton":
			 MoveStartNPCButtonClick();
			 break;

		case "MoveTargetLocButton":
			 MoveTargetLocButtonClick();
			 break;
	}
}

function OnsearchItemBtnClick()
{
	FindAllQuest(searchEditBox.GetString());
}

function OnInitBtnClick()
{
	searchEditBox.SetString("");
	questListCtrl.DeleteAllItem();
}

function getQuestButtonClick()
{
	local int questID, nSelect;
	local LVDataRecord dataRecord;		
	// local Vector loc;

	nSelect = questListCtrl.GetSelectedIndex();

	if (nSelect >= 0) 
	{  
		questListCtrl.GetSelectedRec(dataRecord);
		questID = int(dataRecord.LVDataList[0].szData);

		Debug("questID" @ questID);
		if (questID > 0) ProcessChatMessage("//setquest " $ questID $ " 1", 0);
	}
}

function MoveStartNPCButtonClick()
{
	local int questID, nSelect;
	local LVDataRecord dataRecord;		
	local Vector loc;

	nSelect = questListCtrl.GetSelectedIndex();

	if (nSelect >= 0) 
	{  
		questListCtrl.GetSelectedRec(dataRecord);

		questID = int(dataRecord.LVDataList[0].szData);
		loc     = class'UIDATA_QUEST'.static.GetStartNPCLoc(questID, 1 );

		if (loc.x + loc.y + loc.z != 0)	
		{
			Debug("teleport -> " @ loc.x @ loc.Y @ loc.Z );
			ProcessChatMessage("//teleport" @ loc.x @ loc.Y @ loc.Z, 0);
		}
		if (questID <= 0)
		{
			AddSystemMessageString("questID is wrong:" @ questID);
		}
	}
}

function MoveTargetLocButtonClick()
{
	local int questID, nSelect, questLevel;
	local LVDataRecord dataRecord;		
	local Vector loc;

	nSelect = questListCtrl.GetSelectedIndex();

	if (nSelect >= 0) 
	{  
		questListCtrl.GetSelectedRec(dataRecord);

		questID    = int(dataRecord.LVDataList[0].szData);
		questLevel = int(dataRecord.nReserved2);
		
		loc = class'UIDATA_QUEST'.static.GetTargetLoc(QuestID, questLevel);

		if (loc.x + loc.y + loc.z != 0)	
		{
			if (questID > 0) 
			{
				Debug("teleport -> " @ loc.x @ loc.Y @ loc.Z );
				ProcessChatMessage("//teleport" @ loc.x @ loc.Y @ loc.Z, 0);
			}
			else
			{
				AddSystemMessageString("questID is wrong:" @ questID);				
			}
		}
	}
}

function FindAllQuest( String a_Param )
{
	local int ID, i, NpcID;
	local string modifiedString, fullNameString, NpcName;
	local string JournalName, beforeJournalName;
	local string modifiedParam, zoneName;
	local int directQuestID;
	local Vector zoneLoc;
	
	// m_ComboList.Remove(0, m_ComboList.Length);

	questListCtrl.DeleteAllItem();			

	if (int(a_Param) > 0)
	{
		a_Param = class'UIDATA_QUEST'.static.GetQuestName( int(a_Param) );

		directQuestID = int(a_Param);
	}

	modifiedParam=Substitute(a_Param, " ", "", FALSE);
	
	for( ID = class'UIDATA_QUEST'.static.GetFirstID(); -1 != ID ; ID = class'UIDATA_QUEST'.static.GetNextID() )
	{		
		fullNameString  = class'UIDATA_QUEST'.static.GetQuestName( ID );

		//modifiedString = Substitute(fullNameString, " ", "", FALSE);

		NpcID           = class'UIDATA_QUEST'.static.GetStartNPCID(ID, 1 );
		NpcName         = class'UIDATA_NPC'.static.GetNPCName( NpcID );


		for(i = 0; i < 100; i++)
		{
			// 지역명 
			zoneLoc = class'UIDATA_QUEST'.static.GetTargetLoc(ID, i);

			zoneName = class'UIDATA_QUEST'.static.GetQuestName(class'UIDATA_QUEST'.static.GetQuestZone(id, i));
			// zoneName = GetZoneName(zoneLoc.x, zoneLoc.y, zoneLoc.z);

			JournalName = class'UIDATA_QUEST'.static.GetQuestJournalName( ID, i );
			JournalName = class'UIDATA_QUEST'.static.GetQuestJournalNameLine( JournalName );

			modifiedString = fullNameString $ JournalName $ NpcName $ zoneName;

			modifiedString = Substitute(modifiedString, " ", "", FALSE);

			// level 0 은 대제목,  소제목 , 저널이름이 없어서..예외 처리 
			if ((len(JournalName) <= 0 || i == 0))
			{
				continue;
			}
			else
			{
				if (len(JournalName) != 0 && beforeJournalName == JournalName)
				{
					continue;
				}
			}
			if ( InStr( modifiedString  , modifiedParam ) != -1)
			{
				addItem(ID, i, fullNameString, JournalName);
				beforeJournalName = JournalName;
			}
			else if (int(a_Param) > 0)
			{
				addItem(ID, i, fullNameString, JournalName);

				JournalName = class'UIDATA_QUEST'.static.GetQuestJournalName( ID, i );
				JournalName = class'UIDATA_QUEST'.static.GetQuestJournalNameLine( JournalName );

				beforeJournalName = JournalName;
			}
		}
	}
}

/** 아이템을 추가 한다. */
function addItem(int nItemID, int questLevel, string fullNameString, string JournalName)
{
	local LVDataRecord Record;
	local string questTypeStr, levelLimit, npcName;
	local int questType, minLevel, maxLevel;
	local int NpcID, clearedQuestID;
	local Vector loc;
	local bool bStartLoc, bTargetLoc;
	Record.nReserved1 = nItemID;
	Record.LVDataList.length = 8;

	questType    = class'UIDATA_QUEST'.static.GetQuestType( nItemID, questLevel );
	
	questTypeStr = getQuestTypeString(questType);

	minLevel        = class'UIDATA_QUEST'.static.GetMinLevel        ( nItemID, 1 );
	maxLevel        = class'UIDATA_QUEST'.static.GetMaxLevel        ( nItemID, 1 );

	// 추천레벨
	if ( minLevel > 0 && maxLevel > 0 )
	{
		levelLimit = minLevel $ "~" $ maxLevel;	
	}
	else if  ( minlevel > 0 )
	{
		levelLimit = minLevel $ " " $ GetSystemString(859); // 이상
	}
	else
	{
		levelLimit = GetSystemString(866); // 제한없음
	}
	record.nReserved2 = questLevel;
	record.LVDataList[0].szData        = string( nItemID );
	record.LVDataList[1].TextColor     = Gold;
	record.LVDataList[1].buseTextColor = True;
	record.LVDataList[1].szData        = questTypeStr;
	record.LVDataList[2].szData = levelLimit;
	record.LVDataList[3].buseTextColor = True;
	
	if (questLevel == 1) 
	{
		record.LVDataList[3].szData     = "[" $ fullNameString $ "]"; // $ ", " $ i $ GetSystemString(537) $ ":" @ JournalName;
		record.LVDataList[3].TextColor  = getInstanceL2Util().Yellow;
	}
	else
	{
		record.LVDataList[3].szData        = "   [" $ fullNameString $ "]"; // $ ", " $ i $ GetSystemString(537) $ ":" @ JournalName;
		record.LVDataList[3].TextColor     = Gold;
	}

	Record.LVDataList[3].hasIcon = true;
	Record.LVDataList[3].attrColor.R=170;
	Record.LVDataList[3].attrColor.G=170;
	Record.LVDataList[3].attrColor.B=170;

	Record.LVDataList[3].attrStat[0]   = Substitute("   " $ questLevel $ ": " $ JournalName, "\\n", "<br1>", FALSE);

	NpcID           = class'UIDATA_QUEST'.static.GetStartNPCID(nItemID, 1 );
	NpcName         = class'UIDATA_NPC'.static.GetNPCName( NpcID );
	
	Record.LVDataList[4].szData = npcName;	

	clearedQuestID = class'UIDATA_QUEST'.static.GetClearedQuest(nItemID, questLevel);

	// 지역명 
	loc = class'UIDATA_QUEST'.static.GetTargetLoc(nItemID, questLevel);

	record.LVDataList[5].szData = class'UIDATA_QUEST'.static.GetQuestName(class'UIDATA_QUEST'.static.GetQuestZone(nItemID, questLevel));
	
	//record.LVDataList[5].szData = GetZoneName(loc.x, loc.y, loc.z);

	if (isVectorZero(loc) == false)
	{
		bTargetLoc = true;
	}
	loc = class'UIDATA_QUEST'.static.GetStartNPCLoc(nItemID, questLevel);
	if (isVectorZero(loc) == false)
	{
		bStartLoc = true;
	}

	if (bTargetLoc == true && bStartLoc == true)
	{
		record.LVDataList[6].szData = "OK";
	}
	else if (bTargetLoc == true && bStartLoc == false)
	{   
		record.LVDataList[6].szData = "No StartNPCLoc";
	}
	else if (bTargetLoc == false && bStartLoc == true)
	{   
		record.LVDataList[6].szData = "No TargetLoc";	
	}
	else
	{
		record.LVDataList[6].szData = "No Loc(StartNpcLoc,TargetLoc)";	
	}

	if (clearedQuestID > 0)
	{
		record.LVDataList[7].buseTextColor = True;
		record.LVDataList[7].TextColor  = Gold;
		Record.LVDataList[7].szData = "QuestID:" $ String(clearedQuestID) $ ": "$ class'UIDATA_QUEST'.static.GetQuestName( clearedQuestID );
		Record.LVDataList[7].hasIcon = true;
		Record.LVDataList[7].attrColor.R=170;
		Record.LVDataList[7].attrColor.G=170;
		Record.LVDataList[7].attrColor.B=170;
		Record.LVDataList[7].attrStat[0] = GetSystemString(1201) $ ":" $ class'UIDATA_QUEST'.static.GetRequirement(nItemID, questLevel);
	}
	
	//Record.LVDataList[1].HiddenStringForSorting = util.makeZeroString(6, info.crystalType);
	//Record.LVDataList[1].textAlignment=TA_Left;

	//Record.LVDataList[2].szData = String(info.Id.ClassID);
	//Record.LVDataList[2].textAlignment=TA_Left;

	questListCtrl.InsertRecord( Record );
	
}

function OnRButtonClickListCtrl(string ListCtrlID, int SelectedIndex)
{
	if (ListCtrlID == "QuestListCtrl") 
	{
		// TargetLoc 으로 이동 
		OnClickButton("MoveTargetLocButton");
	}
}

function OnDBClickListCtrlRecord( string ListCtrlID)
{
	local int questID, nSelect, questLevel;
	local LVDataRecord dataRecord;		

	nSelect = questListCtrl.GetSelectedIndex();

	if (ListCtrlID == "QuestListCtrl") 
	{
		if (nSelect >= 0) 
		{  
			questListCtrl.GetSelectedRec(dataRecord);

			questID    = int(dataRecord.LVDataList[0].szData);
			questLevel = int(dataRecord.nReserved2);
			
			// loc = class'UIDATA_QUEST'.static.GetTargetLoc(QuestID, questLevel);
			
			if (questID > 0)	
			{
				// searchEditBox.SetString(string(questID));
				//OnClickButton( "searchItemBtn" );
				FindAllQuest(string(questID));
			}
		}
	}
}


/**
 * 퀘스트 상세정보  
 */
function showQuestDrawer( int QuestID, int level)
{
	local int i;

	//퀘스트 레벨
	// local int Level;
	//퀘스트 타입
	local int QuestType;

	//추천 레벨 최저, 최고
	local int MinLevel, MaxLevel;

	//퀘스트 아이템 param
	local string QuestParam;
	//퀘스트 아이템 개수
	local int Max;

	//퀘스트 필요 아이템 ID
	local array<int>		arrItemIDList;
	//퀘스트 필요 아이템 개수
	local array<int>		arrItemNumList;

	//보상 아이템 ID
	local Array<int> rewardIDList;	
	//보상 아이템 개수
	local Array<INT64> rewardNumList;
	
	//퀘스트 소 제목
	local string JournalName;
	local string titleName;

	local string npcName;

	local string targetString;
	local string levelText;
	local string questTypeText;

	///////////////////////////
	local Vector loc, targetLoc;
	local string locHtml;
	local int npcID;
	local int questZone;
	local string questArea;
	local string ItemNumStr;
	local string etcOutputStr;
	
	htmlMsg="";
	htmlMsg="<html><body>" $ htmlTableAdd();

	//Level = 1;

	MinLevel = class'UIDATA_QUEST'.static.GetMinLevel( QuestID, Level );
	MaxLevel = class'UIDATA_QUEST'.static.GetMaxLevel( QuestID, Level );

	npcID   = class'UIDATA_QUEST'.static.GetStartNPCID( QuestID, 1 );
	npcName = class'UIDATA_NPC'.static.GetNPCName( npcID );

	etcOutputStr = etcOutputStr $ "NpcID :" @ npcID $ ", npcName :" @ npcName $ "\\n\\n";

	QuestDescription = class'UIDATA_QUEST'.static.GetQuestDescription( QuestID, Level );
	QuestDescription = Substitute(QuestDescription, "\\n", "<br1>", FALSE);

	questZone       = class'UIDATA_QUEST'.static.GetQuestZone            ( QuestID, 1 );
	// questArea       = class'UIDATA_HUNTINGZONE'.static.GetHuntingZoneName( questZone ); 
	

	//퀘스트 소제목
	JournalName = class'UIDATA_QUEST'.static.GetQuestJournalName( QuestID, Level );
	JournalName = class'UIDATA_QUEST'.static.GetQuestJournalNameLine( JournalName );
	titleName = htmlAddText( "[" @ JournalName  @ "]", "hs10", "d4af6f" );

	//레벨 표시( 1~23, 11이상, 제한 없음 )
	//txtRecommandedLevelText.SetTextColor( util.Token1 );	
	if ( MaxLevel > 0 && MinLevel > 0)
		levelText =  MinLevel $ "~" $ MaxLevel;
	else if ( MinLevel > 0 )
		levelText =  MinLevel $ " " $ GetSystemString(859);
	else
		levelText = GetSystemString(866);

	//levelText = htmlAddText( levelText, "GameDefault", "ffe58f" );

	//퀘스트 타입
	questType = class'UIDATA_QUEST'.static.GetQuestType( questID, 1 );
	//QuestType = Class'UIDATA_QUEST'.static.GetQuestIscategory( QuestID, Level );

	// 퀘스트분류 메인, 서브...
	if( 0 <= questType && questType <= 13 ) questTypeText = getQuestTypeString(questType);

	questTypeText = htmlfontAdd( questTypeText $ "  [" );

	// 위치표시
	loc = class'UIDATA_QUEST'.static.GetStartNPCLoc( QuestID, 1 );

	etcOutputStr = etcOutputStr $ "startNpc Loc :" @ " x" $ int(loc.x) $ " y" $ int(loc.Y) $ " z" $ int(loc.z) $ "\\n\\n";

	// 시작 npc 정보가 없다면 targetLoc 을 참조
	if (loc.x ==0 && loc.y == 0 && loc.z == 0)	
	{
		loc = class'UIDATA_QUEST'.static.GetTargetLoc(QuestID, Level);
		etcOutputStr = etcOutputStr $ "TargetLoc :" @ " x" $ int(loc.x) $ " y" $ int(loc.Y) $ " z" $ int(loc.z) $ "\\n\\n";
	}
	else
	{
		targetLoc = class'UIDATA_QUEST'.static.GetTargetLoc(QuestID, Level);
		etcOutputStr = etcOutputStr $ "TargetLoc :" @ " x" $ int(targetLoc.x) $ " y" $ int(targetLoc.Y) $ " z" $ int(targetLoc.z) $ "\\n\\n";
	}

	etcOutputStr = etcOutputStr $ "TargetName :" @ class'UIDATA_QUEST'.static.GetTargetName(QuestID, Level)  $ "\\n\\n";

	etcOutputStr = etcOutputStr $ "bOnlyMinimap :" @ class'UIDATA_QUEST'.static.IsMinimapOnly(QuestID, Level)  $ "\\n\\n";
	
	// npc 시작 위치를 기준으로 존이름을 얻어야 좀더 명확한 지역명을 얻는다.
	//questArea    = GetZoneName(loc.x, loc.y, loc.z); // 중국 버전 함수인듯..
	etcOutputStr = etcOutputStr $ "ZoneLoc :" @ " x" $ int(loc.x) $ " y" $ int(loc.Y) $ " z" $ int(loc.z) $ "\\n";

	//Debug("loc.x" @ loc.x);
	//Debug("loc.y" @ loc.y);
	//Debug("loc.z" @ loc.z);

	npcName = Substitute( npcName, " ", "!!", FALSE);

	// ZoomTownMap=0 으로 수정, 전체가 다 월드맵으로 보이기 위해...
	//locHtml = "<a action="$ "\"" $ "event eventString=minimap X=" $ loc.x $" Y=" $ loc.y $ " Z=" $ loc.z 
	//		$ " ZoomTownMap=1 UseGrid=0 toolTipStr=" $ npcName $ "\"" $ ">" $ questArea @ GetSystemString(7199) $ "</a>"; //849ba2 8bc733

	locHtml = "(" $ npcName $ ")" $ questArea @ GetSystemString(7199) $ "<br>"; //849ba2 8bc733

	// 퀘스트이름, 추천체벨 : 레벨
	htmlMsg = htmlMsg $ titleName $ "<br1>" $ htmlfontAdd(GetSystemString(922) @":"@ levelText) 
		      $ "<br1>" $ questTypeText $ locHtml $ htmlfontAdd("]") $ "<br1></td></tr></table><br>";  

	QuestParam = class'UIDATA_QUEST'.static.GetQuestItem( QuestID, Level );

	ParseInt( QuestParam, "Max", Max );	
	arrItemIDList.Length = Max;	
	arrItemNumList.Length = Max;

	////////// 12.04.20 목표에 표시할 내용이 있는가? ////////////////////////////////////////////////////////////////////////

	for ( i = 0; i < Max; i++ )
	{
		//퀘스트 필요 아이템 ID
		ParseInt( QuestParam, "ItemID_" $ i, arrItemIDList[i] );
		//퀘스트 필요 아이템 개수
		ParseInt( QuestParam, "ItemNum_" $ i, arrItemNumList[i] );

		//수량이 0일 경우 
		if( arrItemNumList[i] == 0 )
		{
			ItemNumStr = GetSystemString( 7292 );
		}
		else
		{
			ItemNumStr = string(arrItemNumList[i]);
		}

		if( arrItemIDList[i] - 1000000 > 0 )
		{

			targetString = htmlfontAdd( targetString $ class'UIDATA_NPC'.static.GetNPCName( arrItemIDList[i] - 1000000) 
				@ ItemNumStr $ "NeedKill") $ "<br1>";  // 처치
		}
		else
		{
			targetString = htmlfontAdd( targetString $ class'UIDATA_ITEM'.static.GetItemName( GetItemID( arrItemIDList[i] ) )
				@ ItemNumStr $ "NeedItem" ) $ "<br1>"; // 획득
		}
	}

	if( Max > 0  ) // 목표 추가
	{
		targetString = htmlTableAdd() $ "<font name=hs10 color=\"d4af6f\">" $ GetSystemString(7259) $ "</font>" $ "<br1>" 
					   $ targetString $ "<br1></td></tr></table><br>"; 
		htmlMsg = htmlMsg @ targetString; 
	}

	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	rewardIDList.Remove(0, rewardIDList.Length);
	rewardNumList.Remove(0, rewardNumList.Length);

	class'UIDATA_QUEST'.static.GetQuestReward( QuestID, Level, rewardIDList, rewardNumList);

	// 보상 
	if ( rewardIDList.length > 0 )
	{
		setRewardItem( rewardIDList, rewardNumList );
	}

	etcTextBox.SetText(etcOutputStr);

}

/**
 * 상세정보 보상 아이템추가.
 */
function setRewardItem( array<int> rewardIDList, array<INT64> rewardNumList )
{
	local int i;
	local string iconName;
	local string itemName;

	//////////////
	local string rewardSmallIconHtml, rewardMsgHtml, rewardEndMsgHtml, itemText;
	local int tableIndex, smallIconIndex;

	local string addItemHtml, htmlString;

	tableIndex = 0;
	smallIconIndex = 0;
	bicIconLen = 0;

	rewardSmallIconHtml = "<table width=280 border=0 cellpadding=0 cellspacing=2 background=L2UI_CT1.HtmlWnd.HTMLWnd_GroupBox_DF_Center>";
	rewardMsgHtml = "<table width=280 border=0 cellpadding=0 cellspacing=2 background=L2UI_CT1.HtmlWnd.HTMLWnd_GroupBox_DF_Center>";

	for ( i = 0 ; i < rewardIDList.Length ; i++ )
	{
		if ( rewardIDList[i] != 57 && rewardIDList[i] != 15623 && rewardIDList[i] != 15624 && rewardIDList[i] != 47130)
		{
			bicIconLen++;
		}
	}
	
	if ( rewardIDList.length > 0 )
	{
		for( i = 0 ; i < rewardIDList.Length ; i++ )
		{

			if( i == 0 )
			{
				//addItemHtml = htmlTableAdd( "L2UI_CT1.HtmlWnd.HTMLWnd_GroupBox_DF_Up" ) $ 
				//			  "<font color=\"d4af6f\" name=name=GameDefault>" $ GetSystemString(1127) $ "</font>" $ 
				//			  "<br1><img src=L2UI_CT1.Divider.Divider_DF_Ver width=286 height=2><br1></td></tr></table>"; // 보상

				addItemHtml = // htmlTableAdd( "L2UI_CT1.HtmlWnd.HTMLWnd_GroupBox_DF_Up" ) $ 
							  htmlTableAdd( "L2UI_CT1.GroupBox.GroupBox_DF" ) $ 					
							  "<font color=\"ffcc00\" name=chatFontSize10>" $ GetSystemString(2006) $ "</font>" $ "</td></tr></table>"; // 보상 아이템
			}
							  
							  //"<br1><img src=L2UI_CT1.Divider.Divider_DF_Ver width=274 height=2><br></td></tr></table>"; // 보상


				switch (rewardIDList[i])
				{
					case 57: // 아데나 iconName = class'UIDATA_ITEM'.static.GetItemTextureName(GetItemID(57));	
					case 15623: // 경험치
					case 15624: // sp, 스킬포인트
					case 47130: // 우호도
						itemName = class'UIDATA_ITEM'.static.GetItemName(GetItemID(rewardIDList[i]));
						if( rewardIDList[i] == 57 )
						{
							iconName = "L2UI_CT1.HtmlWnd.HTMLWnd_adena";
							itemName = GetSystemString(469);
						}
						else if( rewardIDList[i] == 15623 )
						{
							if (getLanguageNumber() == 1)
							{
								// 미국 
								// 추후에 xp 아이콘으로 대체 하면 될듯..
							}

							iconName = "L2UI_CT1.HtmlWnd.HTMLWnd_EXP";
						}
						else if(  rewardIDList[i] == 15624 )
						{
							iconName = "L2UI_CT1.HtmlWnd.HTMLWnd_SP";
						}

						// 2015-11-23 FP 추가 (작은 아이콘)
						else if(  rewardIDList[i] == 47130 )
						{
							iconName = "L2UI_CT1.HtmlWnd.HTMLWnd_FP";
						}

						//미정
						if (rewardNumList[i] == 0)
						{
							itemText = GetSystemString(584);
						}
						else
						{
							// SP 인 경우 
							if (rewardIDList[i] == 15624)
							{
								//itemText = string(getInstanceUIData().getSPChangedValue(rewardNumList[i]));
								itemText = (String(rewardNumList[i]));
								// Debug("sp rewardNumList[i]" @ rewardNumList[i]);
							}
							// 그외
							else
							{
								itemText = (String(rewardNumList[i]));
							}
						}

						//$ " itemtooltip=\"" $ rewardIDList[i] $ "\"" 
						//rewardSmallIconHtml = rewardSmallIconHtml $ "<tr><td width=38 height=22 align=center valign=center><button width=32 height=16"											  
						//					  $	" back=\"" $ iconName $ "\"" $ " high=\"" $ iconName $ "\"" $ " fore=\"" $ iconName $ "\"></td><td height=22 width=246><font color=ba8860>" 
						//					  $ itemText $"</font>" @ htmlfontAdd(itemName) $ "</td></tr>";

						rewardSmallIconHtml = rewardSmallIconHtml $ "<tr><td width=45 height=23 align=center valign=center><Img width=32 height=18"											  
											  $	" src=\"" $ iconName $ "\"" $ "></td><td height=23 width=246><font color=ba8860>" 
											  $ itemText $"</font>" @ htmlfontAdd(itemName) $ "</td></tr>";

						smallIconIndex = smallIconIndex + 1;
						break;

					default:
						iconName = class'UIDATA_ITEM'.static.GetItemTextureName(GetItemID(rewardIDList[i]));
						itemName = class'UIDATA_ITEM'.static.GetItemName(GetItemID(rewardIDList[i]));

						// Debug("iconName" @ iconName);
						// Debug("rewardIDList[i]"  @ rewardIDList[i]);

						//아이템 개수
						//미정
						if (rewardNumList[i] == 0)
						{
							itemText = htmlfontAdd( GetSystemString(584), "ba8860" );
						}
						else
						{
							// 아래에 해당하는 경우 몇 "개" 표시가 안되어야 한다.
							if (rewardIDList[i] == 15623 ||   // 경험치  
								rewardIDList[i] == 15624 ||   // 스킬 포인트
								rewardIDList[i] == 15625 ||   // 물음표        
								rewardIDList[i] == 15626 ||   // 활력 포인트
								rewardIDList[i] == 15627 ||   // 혈맹 포인트
								rewardIDList[i] == 15628 ||   // 랜덤 보상
								rewardIDList[i] == 15629 ||   // 정산형 보상
								rewardIDList[i] == 15630 ||   // 추가 보상
								rewardIDList[i] == 15631 ||   // 서브 클래스 권한 획득
								rewardIDList[i] == 15632 ||   // PK 카운트 하락 
								rewardIDList[i] == 15633)
							{
								itemText = htmlfontAdd((string(rewardNumList[i])), "ba8860");
							}
							else
							{    
								itemText =MakeFullSystemMsg(htmlfontAdd(GetSystemMessage(1983)), htmlfontAdd((string(rewardNumList[i])),"ba8860"),"");
							}
						}

						// 큰사이즈 아이콘이 하나일때 말줄임표 안되게 
						if( bicIconLen == 1 )
						{
							rewardMsgHtml = rewardMsgHtml $ "<tr><td align=center valign=center width=43 height=39><button width=32 height=32" 
											$ " itemtooltip=\"" $ rewardIDList[i] $ "\"" $ " back=\"" $ iconName $ "\"" $ " high=\"" $ iconName 
											$ "\"" $  " fore=\"" $ iconName $ "\"></button></td><td width=240 hdight=39>" $ htmlfontAdd(itemName) 
											$ "<br1>"$ itemText $ "</td></tr>";
						}
						else
						{
							if( rewardIDList.Length > 0 && len(itemName) > 8 )
							{
								itemName = mid(itemName, 0 , 8) $ "..";
							}

							if( tableIndex % 2 > 0 ) // 첫번째 
							{
								rewardMsgHtml = mid(rewardMsgHtml, 0 , len(rewardMsgHtml)-5);
								rewardMsgHtml = rewardMsgHtml $ "<td align=center valign=center width=43 height=39><button width=32 height=32" 
												$ " itemtooltip=\"" $ rewardIDList[i] $ "\"" $ " back=\"" $ iconName $ "\"" $ " high=\"" $ iconName 
												$ "\"" $  " fore=\"" $ iconName $ "\"></button></td><td width=115 hdight=39>" $ htmlfontAdd(itemName) 
												$ "<br1>"$ itemText $ "<br1>" $"</td></tr>";
							}
							else 
							{
								rewardMsgHtml = rewardMsgHtml $ htmlTableTrAdd() $  "<tr><td align=center valign=center width=43 height=39><button width=32 height=32" 
												$ " itemtooltip=\"" $ rewardIDList[i] $ "\"" $ " back=\"" $ iconName $ "\"" $ " high=\"" $ iconName 
												$ "\"" $  " fore=\"" $ iconName $ "\"></button></td><td width=115 hdight=39>" $ htmlfontAdd(itemName) 
												$ "<br1>"$ itemText $ "</td></tr>";
							}
						}

						/// Debug("iconName" @ iconName);

						tableIndex = tableIndex + 1;
				}
			
		}

		///////// 리스트 없을 경우 삭제////////////////////////////////////
		if( tableIndex > 0 )
		{
			rewardMsgHtml = rewardMsgHtml $ "</table>";
		}
		else
		{
			rewardMsgHtml = "";
		}

		if( smallIconIndex > 0 )
		{
			rewardSmallIconHtml = rewardSmallIconHtml $ "</table>";
		}
		else
		{
			rewardSmallIconHtml = "";
		}
		/////////////////////////////////////////////////////////////////////
		
		htmlString = mid(htmlString, 6, len(htmlString)); //<html> 테그 삭제
		htmlString = mid(htmlString, 0, len(htmlString) - 7); //</html> 테그 삭제
		
		//rewardEndMsgHtml = "<table width=290 border=0 cellpadding=0 cellspacing=3 background=L2UI_Ct1_Cn.Deco.TitleBaseBarMini_HtmlTableDown><tr><td width=290></td></tr></table>";
		rewardEndMsgHtml = "<table width=278 border=0 cellpadding=0 cellspacing=1 background=L2UI_CT1.HtmlWnd.HTMLWnd_GroupBox_DF_Down><tr><td width=278></td></tr></table>";

		addItemHtml = htmlString $ addItemHtml $ rewardSmallIconHtml $ rewardMsgHtml $ rewardEndMsgHtml;

		//addItemHtml =  "<html><body>" $ addItemHtml $ "<br><table border=0 cellpadding=0 cellspacing=3 width=288 ><tr><td height=15 align=center valign=center><img src=L2UI_CT1_CN.Deco.Horizontal_Deco width=286 height=8></td></tr><tr><td></td></tr></table></body></html>";
		addItemHtml =  "<html><body>" $ addItemHtml $ "<br><table border=0 cellpadding=0 cellspacing=3 width=288 ><tr><td height=11 align=center valign=center></td></tr><tr><td></td></tr></table><br><br>" $ rewardEndMsgHtml $ QuestDescription $ "</body></html>";
		//addItemHtml =  "<html><body>" $ addItemHtml $ "<br><table border=0 cellpadding=0 cellspacing=3 width=288 ><tr><td height=15 align=center valign=center></td></tr><tr><td></td></tr></table></body></html>";

	//rewardEndMsgHtml = "<table width=290 border=0 cellpadding=0 cellspacing=3 background=L2UI_Ct1_Cn.Deco.TitleBaseBarMini_HtmlTableDown><tr><td width=290></td></tr></table>";

	//QuestDescription = "<br><table border=0 cellpadding=0 cellspacing=3 width=288 ><tr><td height=15 align=center valign=center><img src=L2UI_CT1_CN.Deco.Horizontal_Deco width=286 height=8></td></tr><tr><td>" $ QuestDescription $ "</td></tr></table>";

	//htmlMsg = htmlMsg $ rewardSmallIconHtml $ rewardMsgHtml $ rewardEndMsgHtml $ QuestDescription $ "</body></html>"; // 설명부분 추가
	
		DetailInfoHtmlCtrl.LoadHtmlFromString( addItemHtml );
	}
}

function string htmlTableAdd( optional string backgroundUrl )
{
	local string htmlStr;

	if( backgroundUrl == "" ) 
		htmlStr = "<table width=279 cellpadding=0 border=0 cellspacing=3" $ "><tr><td width=4></td><td width=273>";
	else 
		htmlStr = "<table width=279 cellpadding=0 border=0 cellspacing=3 background="$ backgroundUrl $"><tr><td width=0></td><td width=273>";
		// backgroundUrl = "L2UI_Ct1_Cn.Deco.TitleBaseBarMini";

	return htmlStr;
}

function string htmlTableTrAdd()
{
	return "<tr><td width=40 ></td><td width=115 ></td><td width=40 ></td><td width=115 ></td></tr>";
}

function string htmlfontAdd( string strText, optional string fontColor )
{
	local string targetHtml;
	if( fontColor == "" ) fontColor = "d3c5ae";
	
	targetHtml = "<font color=\"" $ fontColor $ "\"" $ ">" $ strText $ "</font>";

	return targetHtml;
}

/***
 * 리스트 컨트롤을 클릭 했을때 
 **/
function OnClickListCtrlRecord( string ListCtrlID )
{
	if ( ListCtrlID == "QuestListCtrl" )
	{ 
		addPinInTheMap( ListCtrlID, -1 );
	}
}

///** 맵에 핀을 꼽는다.  */
function addPinInTheMap( string ListCtrlID, int SelectedIndex )
{
	local LVDataRecord	record;	
	local int questID, level;

	if ( ListCtrlID == "QuestListCtrl" )
	{ 
		if ( SelectedIndex != -1 ) QuestListCtrl.SetSelectedIndex( SelectedIndex, false );

		QuestListCtrl.GetSelectedRec( record );
		questID = INT( record.nReserved1 ); 
		level = INT( record.nReserved2 ); 
		showQuestDrawer( questID, level );

		//// 맵이 열려 있으면 해당 위치로 맵을 이동
		//if ( GetWindowHandle("MiniMapWnd").IsShowWindow() )
		//{			
		//	loc     = class'UIDATA_QUEST'.static.GetStartNPCLoc( questID, 1 );
		//	// 시작 npc 정보가 없다면 targetLoc 을 참조
		//	if (loc.x + loc.y + loc.z != 0)	loc = class'UIDATA_QUEST'.static.GetTargetLoc(QuestID, 1);

		//	npcID   = class'UIDATA_QUEST'.static.GetStartNPCID( questID, 1 );
		//	npcName = class'UIDATA_NPC'.static.GetNPCName( npcID );
		//	npcName = Substitute( npcName, " ", "!!", FALSE);

		//	//ExecuteEvent(EV_ShowMinimapByHtml, "x=" $ loc.x @ 
		//	//								   "y=" $ loc.y @ 
		//	//								   "z=" $ loc.z @ 
		//	//								   "ZoomTownMap=1" @ 
		//	//								   "UseGrid=0" @ 
		//	//								   "toolTipStr=" $ npcName);

		//	// GetWindowHandle("miniMapWnd").SetFocus();
		//}

		// 퀘스트 리스트에 포커스를 준다
		if( SelectedIndex == -1 ) QuestListCtrl.SetFocus();

		//if( INT( record.nReserved2 ) == 1 )
		//{
		//	TeleportButton.DisableWindow();
		//}
		//else
		//{
		//	TeleportButton.EnableWindow();
		//}
	}
}


// 미국 xp 표현을 위해서..
function int getLanguageNumber()
{
	local ELanguageType Language;	
	local int languageNum;

	Language = GetLanguage();
		
	switch( Language )
	{	
		case LANG_Korean:
			languageNum = 0;
			break;	
		case LANG_English:
			languageNum = 1;
			break;
		case LANG_Japanese:
			languageNum = 2;
			break;
		case LANG_Taiwan:
			languageNum = 3;
			break;
		case LANG_Chinese:	
			languageNum = 4;
			break;
		case LANG_Thai:		
			languageNum = 5;
			break;
		case LANG_Philippine:
			languageNum = 6;
			break;
		case LANG_Indonesia:
			languageNum = 7;
			break;
		case LANG_Russia:	
			languageNum = 8;
			break;
		case LANG_Euro:	
			languageNum = 9;
			break;
		case LANG_Germany:	
			languageNum = 10;
			break;
		case LANG_France:	
			languageNum = 11;
			break;
		case LANG_Poland:	
			languageNum = 12;
			break;
		case LANG_Turkey:	
			languageNum = 13;
			break;
		//end of branch
		default:
			languageNum = 0;
			break;
	}	

	return languageNum;		

}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{	
	GetWindowHandle(getCurrentWindowName(string(Self))).HideWindow();
}




/** OnKeyUp */
function OnKeyUp( WindowHandle a_WindowHandle, EInputKey nKey )
{
	// 키보드 누름으로 체크 	
	if (searchEditBox.IsFocused())
	{	
		// txtPath
		if (nKey == IK_Enter) 
		{
			// 키보드 입력은 아무것도 입력 하지 않았을때 전체 검색을 허용하지 않는다.
			// 실수로 자꾸 누르는 경우가 있어서..
			if (trim(searchEditBox.GetString()) != "") OnsearchItemBtnClick();
		}
	}
}
defaultproperties
{
}
