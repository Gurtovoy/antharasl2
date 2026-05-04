/////////////////////////////////////////////////////////////////////////////////////////////
//								퀘스트 알리미 창 									     //
//														- create by innowind 2007.10.17	     //
/////////////////////////////////////////////////////////////////////////////////////////////

class QuestAlarmWnd extends UICommonAPI;
	
// 디파인 지정
// 확장 타이머
/*
const TIMER_ID=11;
const TIMER_DELAY=2000;			// 이 딜레이만큼 오버되면 창이 확장된다.
// 축소 타이머
const TIMER_ID2=12;
const TIMER_DELAY2=500;			// 이 딜레이만큼 오버되면 창이 축소된다.
*/

const EXPEND_CONTRACT_GAP = 37;

const CONTRACT_WIN_WIDTH = 213;
const EXPEND_WIN_WIDTH = 250;		// 확장된 전체 윈도우 넓이

const CONTRACT_QUEST_NAME_WIDTH = 198;
const EXPEND_QUEST_NAME_WIDTH = 235;	// 퀘스트 이름 넓이

const CONTRACT_ITEM_NAME_WIDTH = 113;
const EXPEND_ITEM_NAME_WIDTH = 150;	// 아이템 이름 넓이

const QUEST_ITEM_NUM_DEFAULT = 85;		// 퀘스트 아이템 넓이


const TEXT_HEIGHT = 18;				// 텍스트 기본 높이
//const TEXT_HEIGHT_MARGIN = 2;			// 텍스트 간격

const WINDOW_HEIGHT_MARGIN = 10;		// 윈도우 사이의 간격

const MAX_ITEM = 5;				// 최대 아이템 수
const MAX_QUEST = 5;			// 최대 퀘스트 수
const MAX_QUEST_ALL = 25;		//위의 두 값을 곱한값 ;;

// 전역변수 선언부
//var bool isWaitExpand;		// 창을 확장하기 위해 기다리고 있는가?
//var bool isWaitContract;	// 창을 축소 되기 위해 기다리고 있는가?
//var bool isExpand;		// 창이 현재 확장된 상태인가?



var bool isClickedAdd;		// 버튼 클릭으로 애드 했는지 확인하는 함수

var int m_NumOfQuest;		// 현재 보여지고 있는 퀘스트의 갯수

var int i, j;				// for 루프를 위한 변수

var Color Gold;
var Color White;
var Color Gray;

// 핸들 선언부
var WindowHandle Me;
//var WindowHandle QuestWndOverCheck;
var ButtonHandle btnClose;

var WindowHandle QuestWnd[MAX_QUEST];
var NameCtrlHandle QuestAlarmName[MAX_QUEST];
var int QuestAlarmNameID[MAX_QUEST];
var NameCtrlHandle QuestItemName[MAX_QUEST_ALL];
var int QuestItemNameID[MAX_QUEST_ALL];
var TextBoxHandle QuestItemNum[MAX_QUEST_ALL];
var INT64 QuestItemNumInt[MAX_QUEST_ALL];
var int QuestAlarmLevel[MAX_QUEST];



var int         MonsterQuestID;
var array<int>  MonsterNpcId;  
var array<int>  QuestStringType; //ldw 1014 스트링 형 퀘스트 (퀘스트 이름을 스트링으로 받음)
var array<int>  MonsterNumOfKillMonsters;

var QuestTreeWnd scQuestTree;
var QuestTreeDrawerWnd scQuestTreeDrawer;
var bool bOptionQuestAlarm;

var L2Util util;

function OnRegisterEvent()
{
	RegisterEvent( EV_GamingStateExit );
	RegisterEvent( EV_MouseOver );
	RegisterEvent( EV_MouseOut );

	RegisterEvent( EV_ExpandQuestAlarmKillMonsterStart );
	RegisterEvent( EV_ExpandQuestAlarmKillMonster );
	RegisterEvent( EV_ExpandQuestAlarmKillMonsterEnd );

	RegisterEvent( EV_InventoryAddItem );
	RegisterEvent( EV_InventoryUpdateItem );
	
	RegisterEvent( EV_QuestList );
}

function OnLoad()
{
	OnRegisterEvent();

	Initialize();
	Load();
	InitData();	//해당 윈도우의 초기화작업
	FitWindowSize();	//사이즈 조절작업

	scQuestTree = QuestTreeWnd( GetScript( "QuestTreeWnd" ) );
	scQuestTreeDrawer = QuestTreeDrawerWnd( GetScript( "QuestTreeDrawerWnd" ) );

	util = L2Util( GetScript( "L2Util"));
}

// InfoWnd 의 height에 맞춰 기본 위치를 수정
function onDefaultPosition() 
{		
	local WindowHandle InfoWnd;		
	local Rect infoRectWnd, MeRectWnd;

	local int currentScreenWidth, currentScreenHeight;	

	if( !Me.IsShowWindow() ) return;

	GetCurrentResolution (currentScreenWidth, currentScreenHeight);

	InfoWnd = GetWindowHandle ( "InfoWnd");
	
	infoRectWnd = InfoWnd.GetRect();
	MeRectWnd = Me.GetRect();
	
	// 높이는 절대 값 + 으로 수정 해야 함. 212 는 InfoWnd.의 시작 위치
	Me.MoveTo( currentScreenWidth - 3 - MeRectWnd.nWidth , 212 + 5 + infoRectWnd.nHeight );
}

// 핸들 초기화
function Initialize()
{
	//핸들 생성부
	Me = GetWindowHandle( "QuestAlarmWnd" );
	//QuestWndOverCheck = GetWindowHandle( "QuestWndOverCheck" );
	btnClose = GetButtonHandle ( "QuestAlarmWnd.btnClose" );
	
	for(i=0 ; i<MAX_QUEST ; i++)
	{
		QuestWnd[i] =  GetWindowHandle( "QuestAlarmWnd.QuestWnd" $ i+1 );
		QuestAlarmName[i] = GetNameCtrlHandle ( "QuestAlarmWnd.QuestWnd" $ i + 1 $ ".QuestAlarmName1");
		for (j=0 ; j<MAX_ITEM ; j++)
		{			
			QuestItemName[i * 5 + j] = GetNameCtrlHandle ( "QuestAlarmWnd.QuestWnd" $ i + 1 $ ".QuestItemName" $ j + 1);
			QuestItemNum[i*5 + j] = GetTextBoxHandle ( "QuestAlarmWnd.QuestWnd" $ i + 1 $ ".QuestItemNum" $ j + 1);
			QuestItemNum[i*5 + j].SetAnchor("QuestAlarmWnd.QuestWnd" $ i + 1 $ ".QuestItemName" $ j + 1, "TopRight", "TopLeft", 3, 0);
		}

		//GetButtonHandle ( "QuestAlarmWnd.hideButton" $ i + 1 ).HideWindow();
	}	

	bOptionQuestAlarm = GetOptionBool("Game", "autoQuestAlarm");
}

function Load()
{	
	Gold.R = 175;
	Gold.G = 152;
	Gold.B = 120;
	Gold.A = 255;
	
	White.R = 250;
	White.G = 250;
	White.B = 250;
	White.A = 255;
	
	Gray.R = 135;
	Gray.G = 135;
	Gray.B = 135;
	Gray.A = 255;
}

function InitData()
{	
//	isWaitExpand = false;
//  isExpand = false;
	
	for(i=0 ; i<MAX_QUEST ; i++)
	{
		QuestAlarmNameID[i] = -1;	// -1이면 빈슬롯
		QuestAlarmName[i].SetName("", NCT_Normal,TA_Left);
		for (j=0 ; j<MAX_ITEM ; j++)
		{			
			QuestItemNameID[i*5 + j] = -1; 	// -1이면 빈슬롯
			QuestItemName[i*5 + j].SetName("", NCT_Normal,TA_Left);
			QuestItemNum[i*5 + j].SetText("");			
		}
		//GetButtonHandle ( "QuestAlarmWnd.hideButton" $ i + 1 ).HideWindow();
	}	
	m_NumOfQuest= 0;
	
	isClickedAdd = false;

	bOptionQuestAlarm = GetOptionBool("Game", "autoQuestAlarm");

}

function UpdateOptionData()
{
	bOptionQuestAlarm = GetOptionBool("Game", "autoQuestAlarm");
}

function HandleQuestList( String param )
{
	//필요 한 정보 ** 현재 진행 중인 값.
	
	local int i;

	local int QuestID;
	local int Level; 	

	//local string GoalName;
	local int needQuestItemNum;
	local int NeedItemID;
	local int Completed;
	local int GoalType;

	//퀘스트 아이템 param
	local string QuestParam, alarmTitleStr;
	//필요 아이템 Max 값
	local int Max;		
	local int count; 

	local bool oneCall;
	
	ParseInt( param, "QuestID", QuestID );
	ParseInt( param, "Level", Level );
	ParseInt( param, "Completed", Completed );

	count   = 0;	
	oneCall = false;

	if (Completed == 0 ) 
	{
		if (bOptionQuestAlarm == true)
		{
			// 알람 등록 안함.
			return;
		}

		QuestParam = class'UIDATA_QUEST'.static.GetQuestItem( QuestID, Level );	
		ParseInt( QuestParam, "Max", Max );	
		
		/// Debug("QuestParam" @ QuestParam);
		for ( i = 0; i < Max; i++ )
		{	
			//퀘스트 필요 아이템 ID
			ParseInt( QuestParam, "GoalID_" $ i, NeedItemID );
			//퀘스트 필요 아이템 개수
			ParseInt( QuestParam, "GoalNum_" $ i, needQuestItemNum);
			//퀘스트 스트링 타입 여부
			ParseInt( QuestParam, "GoalType_" $ i, GoalType);
			// Debug("_" @ NeedItemID @ needQuestItemNum @ GoalType );

			//Goalname = "";//class'UIDATA_QUEST'.static.GetQuestGoalName( QuestID, setLevel) ;
					
			// npcString을 통해, 특히 누구 만나기 등을 구현 하는 형태
			if(GoalType == 1) 
			{
				alarmTitleStr = GetNpcString(NeedItemID);
				count = needQuestItemNum;
				// Debug("==GoalType형? npc alarmTitleStr" @ alarmTitleStr);
			}
			// 처치형
			else if( NeedItemID >= 1000000 )
			{
				alarmTitleStr = class'UIDATA_NPC'.static.GetNPCName( NeedItemID - 1000000) $ " " $ GetSystemString(2240) ;				
				count = needQuestItemNum;
				//  Debug("==처치형 alarmTitleStr" @ alarmTitleStr);
			}
			// 보통 수집..
			else
			{
				alarmTitleStr = class'UIDATA_ITEM'.static.GetItemName( GetItemID( NeedItemID ));
				count = int(GetInventoryItemCount( GetItemID( NeedItemID)));
				//  Debug("==수집 일반형 alarmTitleStr" @ alarmTitleStr);
				//m_scriptAlarm.AddQuestAlarm( SelectQuestID, SelectLevel, SelectarrItemID[i], SelectarrItemNumList[i] );
				//선택한 Quest의 마지막 것으로 요청한다.
			}

// 			alarmTitleStr = class'UIDATA_ITEM'.static.GetItemName( GetItemID( NeedItemID ) );
// 			count = int ( GetInventoryItemCount( GetItemID( NeedItemID )));			

			if (bOptionQuestAlarm == false)
			{
				AddQuestAlarmNew
				( 
					QuestID, 
					class'UIDATA_QUEST'.static.GetQuestName(QuestID, Level), 
					NeedItemID,
					alarmTitleStr,  //npc 네임으로 
					count, 
					needQuestItemNum,
					Level
				);
			}
			
			//if (IsThereDiffQuestType(i) && oneCall == false)
			if (oneCall == false)
			{								
				oneCall = true;
				RequestAddExpandQuestAlarm(questId);
			}			
		}
	}
}


function OnEvent( int a_EventID, String a_Param )
{
	//local string CurrentWndName;
	//local string ParentWndName;
	
	local int ClassID;
	local int questId;
	local int npcId;
	local int numOfKillMonsters;
	local int isStringType; //ldw 1014	

	switch( a_EventID )
	{
	
	 case EV_QuestList :
		ParseInt( a_Param, "QuestID", questId );
		// Debug("EV_QuestList" @ questId);
		// Debug("scQuestTree.m_recentlyQuestID" @ scQuestTree.m_recentlyQuestID);
		
		if ( scQuestTree.m_recentlyQuestID == questId )
		{	
			HandleQuestList( a_Param );
			//RequestAddExpandQuestAlarm(questId);			
			//scQuestTree.m_recentlyQuestID  = 0;?? 
		}	
		break;
	/*
	case EV_MouseOver: //3060 
		
			ParseString(a_Param, "Name", CurrentWndName);
			ParseString(a_Param, "TopWndName", ParentWndName);
			Debug ( "mouseOver "  @ CurrentWndName @ ParentWndName );
		break;
	
	case EV_MouseOver: //3060
		ParseString(a_Param, "Name", CurrentWndName);
		ParseString(a_Param, "TopWndName", ParentWndName);
		//debug("mouse over!! Name : " $ CurrentWndName $ " parent : " $ ParentWndName);
		if(CurrentWndName == "QuestWndOverCheck" || ParentWndName == "QuestWndOverCheck")
		{
			// 창이 축소된 상태에서만 확장된 상태로 만들 수 있음
			if(isExpand == false)	
			{
				Me.SetTimer(TIMER_ID,TIMER_DELAY);
				isWaitExpand = true;
			}
		}
		break;
	
	case EV_MouseOut: //3070
		ParseString(a_Param, "Name", CurrentWndName);
		ParseString(a_Param, "TopWndName", ParentWndName);
		//debug("mouse out!! Name : " $ CurrentWndName $ " parent : " $ ParentWndName);
		if(CurrentWndName == "QuestWndOverCheck" || ParentWndName == "QuestWndOverCheck")
		{			
			// 확장된 상태에서만 줄여줄 수 있다.
			if(isExpand == true)	 
			{
				ContractWindowSize();
				isExpand = false;
				isWaitContract = false;
			}
			isWaitExpand = false;
		}
		break;
	*/
	//나갈때 초기화해주기
	case EV_MouseOut: break;
	case EV_GamingStateExit:
		InitData();
		break;

	//몬스터를 잡았을 경우 시작
	case EV_ExpandQuestAlarmKillMonsterStart: //4931
		//초기화.
		//Debug("EV_ExpandQuestAlarmKillMonsterStart");
		MonsterQuestID = 0;
		MonsterNpcId.Remove(0, MonsterNpcId.Length);
		QuestStringType.Remove(0, QuestStringType.Length); //ldw 1014
		MonsterNumOfKillMonsters.Remove(0, MonsterNumOfKillMonsters.Length);
		break;	

	//몬스터를 잡았을 경우
	case EV_ExpandQuestAlarmKillMonster:		//4930
		//Debug("EV_ExpandQuestAlarmKillMonster");
		ParseInt( a_Param, "questId", questId);
		ParseInt( a_Param, "npcId", npcId );
		ParseInt( a_Param, "numOfKillMonsters", numOfKillMonsters );
		ParseInt( a_Param, "type", isStringType );	
		
		if ( npcId == -1 && numOfKillMonsters == -1 ) 
		{
			//Debug("EV_ExpandQuestAlarmKillMonster" @  questId @ npcId @numOfKillMonsters@ isStringType );		//둘다 -1일 경우 한번도 죽인 적이 없는  경우임
		}

		MonsterQuestID = questId;		
		
		if( npcId == -1 )
		{				
			MonsterZeroCount();
			return;
		}				
		MonsterNpcId.Insert( 0, 1 ) ;
		MonsterNpcId[0] = npcId ;
		MonsterNumOfKillMonsters.Insert( 0, 1 ) ;
		MonsterNumOfKillMonsters[0] = numOfKillMonsters ;
		QuestStringType.Insert( 0, 1 ) ;
		QuestStringType[0] = isStringType ;
		
		//CountKillMonsterUpdate( questId, npcId, numOfKillMonsters );
		break;

	//몬스터를 잡았을 경우 끝
	case EV_ExpandQuestAlarmKillMonsterEnd: //4932
		// Debug("EV_ExpandQuestAlarmKillMonsterEnd");	
		MonsterCountUpdate();

		break;	

	//아이템
	//case EV_InventoryAddItem:
	case EV_InventoryUpdateItem: //2600		
		if(Me.IsShowWindow())
		{
			ParseInt( a_Param, "classID", ClassID );	
			UpdateItemCount(ClassID);
		 }		 		
		break;
	}
}


/**
 * 몬스터 잡은 갯수를 파악하여 업데이트.
 */
function MonsterCountUpdate()
{	
	local int i;
	local int j;
	local int k;
	local int count;
	local int isStringType;
//	Debug ("MonsterCountUpdate" @ MonsterQuestID);
	//전체 퀘스트
	for( i = 0 ; i < scQuestTree.ArrQuest.Length ; i ++ )
	{
		//퀘스트에 필요한 아이템 또는 처치 몬스터.
		for( j = 0 ; j < scQuestTree.ArrQuest[i].arrNeedItemIDList.Length ; j ++ )
		{			
			//Debug ("MonsterCountUpdate" @ MonsterQuestID @ scQuestTree.ArrQuest[i].QuestID );
			//같은 퀘스트 목록.
			if( MonsterQuestID == scQuestTree.ArrQuest[i].QuestID )
			{
				count = 0;
				//잡은 몬스터 배열.
				for( k = 0 ; k < MonsterNpcId.Length ; k ++ )
				{
					if( MonsterNpcId[k] == scQuestTree.ArrQuest[i].arrNeedItemIDList[j] ) //
					{
						count = MonsterNumOfKillMonsters[k];
						isStringType = QuestStringType[k];
					}
				}
				
				//Debug("isStringType" @ isStringType);
				CountKillMonsterUpdate( MonsterQuestID, scQuestTree.ArrQuest[i].arrNeedItemIDList[j], count, isStringType);
			}
		}
	}
}

/**
 * 몬스터를 한마리도 잡지 않았을 경우.
 */
function MonsterZeroCount()
{
	local int i;
	local int j;
	local int setLevel;
	local int GoalType;
	local string QuestParam;

	//전체 퀘스트
	for( i = 0 ; i < scQuestTree.ArrQuest.Length ; i ++ )
	{
		//퀘스트에 필요한 아이템 또는 처치 몬스터.
		for( j = 0 ; j < scQuestTree.ArrQuest[i].arrNeedItemIDList.Length ; j ++ )
		{			
			//같은 퀘스트 목록.
			if( MonsterQuestID ==  scQuestTree.ArrQuest[i].QuestID )
			{				
				setLevel = util.getQuestLevelForID( MonsterQuestID ); //getLevel(MonsterQuestID);
				QuestParam = class'UIDATA_QUEST'.static.GetQuestItem( MonsterQuestID, setLevel );
				ParseInt( QuestParam, "GoalType_" $ j, GoalType);// 골 타입으로 받아도 될 듯.
				//Debug("GoalType" @ GoalType  );
				CountKillMonsterUpdate( MonsterQuestID, scQuestTree.ArrQuest[i].arrNeedItemIDList[j], 0, GoalType );
			}
		}
	}
}

function CountKillMonsterUpdate( int QuestID, int npcId, int numOfKillMonsters, int isStringType)
{
	local int i;

	//필요 퀘스트 아이템 최대 개수
	local int Max;
	//퀘스트 필요 아이템 ID
	local array<int> needQuestItemID;
	//퀘스트 필요 아이템 개수
	local array<int> needQuestItemNum;
	
	local string QuestParam;	
	//퀘스트의 레벨 값
	local int setLevel;

	local string    Goalname;
	local int       Count;

	local int       GoalType;

	//Debug ("CountKillMonsterUpdate ok");
	setLevel = util.getQuestLevelForID( QuestID);

	QuestParam = class'UIDATA_QUEST'.static.GetQuestItem( QuestID, setLevel );

	ParseInt( QuestParam, "Max", Max );	
	needQuestItemID.Length = Max;	
	needQuestItemNum.Length = Max;

	for ( i = 0; i < Max; i++ )
	{
		//퀘스트 필요 아이템 ID

		ParseInt( QuestParam, "GoalID_" $ i, needQuestItemID[i] );
		//퀘스트 필요 아이템 개수
		ParseInt( QuestParam, "GoalNum_" $ i, needQuestItemNum[i] );		
		//퀘스트 스트링 타입 여부
		ParseInt( QuestParam, "GoalType_" $ i, GoalType);// 골 타입으로 받아도 될 듯.

		// Debug("QuestParam" @QuestParam);
		//Debug( "i" @ i  @  npcId @  needQuestItemID[i]);
		//if( npcId == needQuestItemID[i] && isStringType == GoalType )
		if( npcId == needQuestItemID[i])
		{
			
			//debug( class'UIDATA_NPC'.static.GetNPCName( needQuestItemID[i] - 1000000 )$"를 "$ numOfKillMonsters$"/"$needQuestItemNum[i] );			
			//몬스터를 잡았을 경우 업뎃 함.
			Goalname = "";//class'UIDATA_QUEST'.static.GetQuestGoalName( QuestID, setLevel) ;

			
			//타입이 스트링 형식일 경우 			
			if(GoalType == 1 ) 
			{
				//Debug("numOfKillMonsters" @ numOfKillMonsters );
				UpdateAlarmItem( needQuestItemID[i], numOfKillMonsters );
				if ( Goalname == "" ) 	
				{
					//Debug ("1 GetNpcString" @ Goalname);
					Goalname = GetNpcString(npcId) ;				
				}
					//Goalname = class'UIDATA_NPC'.static.GetNpcString(npcId) ;				

				Count = numOfKillMonsters;				

			} 
			else if( needQuestItemID[i] - 1000000 > 0 ) //학살형 일 경우
			{
				//Debug("Monster" @ needQuestItemID[i] @ Goalname);
				//Debug("numOfKillMonsters" @ numOfKillMonsters);
				UpdateAlarmItem( needQuestItemID[i], numOfKillMonsters, QuestID );
				if ( Goalname == "" ) 	
				{
					Goalname = class'UIDATA_NPC'.static.GetNPCName( needQuestItemID[i] - 1000000) $ " " $ GetSystemString(2240) ;				
					//Debug ("2 GetNpcString" @ Goalname);
				}

				Count = numOfKillMonsters;				
			}
			//아이템 구하는 내용과 같이 있을 수 있음 아이템일 경우 업뎃.
			//모으는 아이템이 있을 경우.
			else
			{				
				if ( Goalname == "" ) 
				{
					//Debug ("3 GetNpcString" @ Goalname);
					Goalname = class'UIDATA_ITEM'.static.GetItemName( GetItemID( needQuestItemID[i] ) );
				}

//				Debug("Item" @ needQuestItemID[i] @ Goalname);

				Count = int( GetInventoryItemCount( GetItemID( needQuestItemID[i] ) ) ) ;
			}

			if (bOptionQuestAlarm == false)
			{
				AddQuestAlarmNew
				( 
					QuestID, 
					class'UIDATA_QUEST'.static.GetQuestName(QuestID, setLevel), 
					needQuestItemID[i],
					GoalName, 
					Count, 
					needQuestItemNum[i],
					setLevel
				);			
			}
		}
	}	
	scQuestTree.ButtonEnableCheck();
}



//퀘스트 아이템 갯수 갱신(ClassID=0이면 전체 아이템을 갱신, a_ItemCount 기본값 0)
function UpdateItemCount( int ClassID, optional INT64 a_ItemCount )
{	
	local int       i;
	local int       j;
	local int       k;
	local INT64     ItemCount;
	local int       localQuestID;
	local int       localQuestLv;
	local string    Goalname ;
	local ItemID    itemID;
	local bool      isAddedQuest;


	isAddedQuest = false;

	// Debug("누구냐 난UpdateItemCount ");
	for( i = 0 ; i < scQuestTree.ArrQuest.Length ; i ++ )
	{
		for( j = 0 ; j < scQuestTree.ArrQuest[i].arrNeedItemIDList.Length ; j ++ )
		{			
			if (scQuestTree.ArrQuest[i].arrGoalType[j] == 0) // 골타입이 0이고,
			{
				if( ClassID == scQuestTree.ArrQuest[i].ArrNeedItemIDList[j] )//같은게 있네요 이 퀘스트 업데이트 하거나 등록 하죠?
				{
					//우선 퀘스트 ID와 레벨 값을 받읍시다.
					localQuestID = scQuestTree.ArrQuest[i].QuestID;
					localQuestLv = scQuestTree.ArrQuest[i].Level;

					//퀘스트 업데이트가 있었으니, goalType가 0인 것도 리퀘스트 할 수 있도록 플래그를 바꿉니다.
					isAddedQuest = true;

					for ( k = 0 ; k < scQuestTree.ArrQuest[i].ArrNeedItemIDList.Length ; k++ )//
					{	
						if ( scQuestTree.ArrQuest[i].arrGoalType[k] == 0 ) // arrGoalType 이 0 인 것만 등록합니다.
						{
							
							//다른 아이템도 받아서 갱신 되도록 수정
							itemID = GetItemID( scQuestTree.ArrQuest[i].ArrNeedItemIDList[k] );
							ItemCount = GetInventoryItemCount( itemID );
							UpdateAlarmItem( scQuestTree.ArrQuest[i].ArrNeedItemIDList[k], ItemCount );
							Goalname = class'UIDATA_ITEM'.static.GetItemName( itemID );

							if (bOptionQuestAlarm == false)
							{
								AddQuestAlarmNew( 
												localQuestID,
												class'UIDATA_QUEST'.static.GetQuestName( localQuestID, localQuestLv ),
												scQuestTree.ArrQuest[i].ArrNeedItemIDList[k],
												Goalname,
												int(ItemCount),
												scQuestTree.ArrQuest[ i ].ArrNeedItemNumList[ k ],
												localQuestLv
												);
							}
						}
					}					
				}
				
				if (isAddedQuest) //퀘트가 등록 됐으면
				{
					if ( IsThereDiffQuestType (i) ) //다른 타입이 있는지 검색 해서
					{
						if (GetOptionBool("Game", "autoQuestAlarm") == false)
							RequestAddExpandQuestAlarm( localQuestID ); //리퀘스트 하여라 
					}
					scQuestTree.ButtonEnableCheck();		

					return;
				}
			}
		}
	}
}

function bool IsThereDiffQuestType( int QuestNum )
{
	local int i;
	
	for( i = 0 ; i < scQuestTree.ArrQuest[QuestNum].arrNeedItemIDList.Length ; i ++ )
	{
		if ( scQuestTree.ArrQuest[QuestNum].arrGoalType[i] == 1)
			return true;
		if ( scQuestTree.ArrQuest[QuestNum].arrNeedItemIDList[i] >= 1000000 )
			return true;
	}
	return false;
}



// 타이머 기동
/*
function OnTimer(int TimerID)
{
	if(TimerID == TIMER_ID)
	{
		if(isExpand == false && isWaitExpand == true )	// 창이 확장되지 않은 상태에서만 확장해준다.
		{
			ExpendWindowSize();
			
			isExpand = true;
			isWaitExpand = false;
		}
		Me.KillTimer( TIMER_ID );
	}
}*/

function OnClickButton( string Name )
{
	//local string buttonStr;
	//local int buttonIndex;

	// Debug("Name" @ Name);
	switch( Name )
	{
		case "btnClose":
			OnbtnCloseClick();
			break;
	}

	//Debug("---?" @ Left(Name, 10));

	//if (Left(Name, 10) == "hideButton")
	//{
	//	buttonIndex = int(Right(Name, 1));	//버튼의 제일 끝 숫자를 따낸다. 
	//	Debug("buttonIndex" @ buttonIndex);

	//	if (QuestAlarmNameID[buttonIndex - 1] > 0)
	//	{
	//		scQuestTree.selectQuestTree("root." $ QuestAlarmNameID[buttonIndex - 1], false);
	//	}
		
	//	//QuestAlarmName[idx].SetNameWithColor(QuestName, NCT_Normal,TA_Left, Gold);
	//	//QuestAlarmNameID[idx] = QuestID;
	//	//QuestAlarmLevel[idx] = Level;


	//}
}

function OnbtnCloseClick()
{
	InitData();
	if(Me.isShowWindow()) Me.HideWindow();
}

// 확장될 경우 윈도우 사이즈 변화들
function ExpendWindowSize()
{
	local int Height;
	local String tempStr;
	local int nWidth, nHeight;
	
	Me.GetWindowSize(i, Height);	//넓이는 어짜피 사용하지 않기 때문에 그냥 변수(i) 재활용
	
	Me.SetWindowSize( EXPEND_WIN_WIDTH,  Height );
	
	for(i = 0; i<MAX_QUEST ; i++)
	{
		QuestWnd[i].GetWindowSize(j , Height); //넓이는 어짜피 사용하지 않기 때문에 그냥 변수(j) 재활용
		QuestWnd[i].SetWindowSize( EXPEND_QUEST_NAME_WIDTH,  Height );
		QuestAlarmName[i].SetWindowSize( EXPEND_QUEST_NAME_WIDTH,  TEXT_HEIGHT );
	}
	
	for(i = 0 ; i< MAX_QUEST_ALL ; i++)
	{
		tempStr = QuestItemName[i].GetName();
		GetTextSizeDefault(tempStr, nWidth, nHeight);
		if(nWidth < EXPEND_ITEM_NAME_WIDTH && nWidth > 5)	// 5은 그냥 가라. (아이템 이름이 5픽셀 이하일 수 없기 때문에 ) 매우 작은 윈도우 사이즈 ("") 를 기준으로 사이즈를 맞추려고 하지 못하게 하기 위해
		{
			QuestItemName[i].SetWindowSize( nWidth,  TEXT_HEIGHT );
		}
		else
		{		
			QuestItemName[i].SetWindowSize( EXPEND_ITEM_NAME_WIDTH,  TEXT_HEIGHT );
		}
	}
	
	Me.MoveEx(CONTRACT_WIN_WIDTH - EXPEND_WIN_WIDTH  ,0);	// 갭만큼 이동시켜 준다.
}

// 축소될 경우 윈도우 사이즈 변화들
/*
function ContractWindowSize()
{
	local int Height;
	local String tempStr;
	local int nWidth, nHeight;
	
	Me.GetWindowSize(i, Height);	//넓이는 어짜피 사용하지 않기 때문에 그냥 변수(i) 재활용	
	Me.SetWindowSize( CONTRACT_WIN_WIDTH,  Height );
	
	for(i = 0; i<MAX_QUEST ; i++)
	{
		QuestWnd[i].GetWindowSize(j , Height); //넓이는 어짜피 사용하지 않기 때문에 그냥 변수(j) 재활용
		QuestWnd[i].SetWindowSize( CONTRACT_QUEST_NAME_WIDTH,  Height );
		QuestAlarmName[i].SetWindowSize( CONTRACT_QUEST_NAME_WIDTH,  TEXT_HEIGHT );
	}
	
	for(i = 0 ; i< MAX_QUEST_ALL ; i++)
	{
		tempStr = QuestItemName[i].GetName();
		GetTextSizeDefault(tempStr, nWidth, nHeight);
		if(nWidth < CONTRACT_ITEM_NAME_WIDTH  && nWidth > 5) // 5은 그냥 가라. (아이템 이름이 5픽셀 이하일 수 없기 때문에 ) 매우 작은 윈도우 사이즈 ("") 를 기준으로 사이즈를 맞추려고 하지 못하게 하기 위해
		{
			QuestItemName[i].SetWindowSize( nWidth,  TEXT_HEIGHT );
		}
		else
		{		
			QuestItemName[i].SetWindowSize( CONTRACT_ITEM_NAME_WIDTH,  TEXT_HEIGHT );
		}
	}
	
	Me.MoveEx(EXPEND_WIN_WIDTH - CONTRACT_WIN_WIDTH   ,0);	// 갭만큼 이동시켜 준다.
}*/

// 현재 등록된 퀘스트들에 맞게 윈도우 사이즈를 조절한다.  (주로 세로 사이즈)
function FitWindowSize()
{

	local int Width, Height;
	
	local int totalHeight; //총 윈도우의 높이
	local int oneWinHeight;	// 윈도우 하나의 높이
	
	totalHeight = 0;
	m_NumOfQuest = 0;
	for(i = 0; i<MAX_QUEST ; i++)	// 퀘스트가 등록되었다면, 퀘스트 윈도우를 쇼우 해준다. 
	{
		if( QuestAlarmNameID[i] == -1)	
		{
			if(QuestWnd[i].IsShowWindow())		//등록되지 않았는데 show 되고있다면 하이드 시켜준다.
			{
				QuestWnd[i].HideWindow();
				// GetButtonHandle ( "QuestAlarmWnd.hideButton" $ i + 1 ).HideWindow();
			}
		}
		else
		{
			m_NumOfQuest++;	// 표시되고 있는 퀘스트의 수를 증가시킨다.
			if(!QuestWnd[i].IsShowWindow())
			{
				QuestWnd[i].showWindow();
				// GetButtonHandle ( "QuestAlarmWnd.hideButton" $ i + 1 ).showWindow();
			}
			
			oneWinHeight = 0;
			
			oneWinHeight = oneWinHeight + TEXT_HEIGHT;	//퀘스트 이름줄			
			
			for(j=0 ; j<MAX_ITEM ; j++)
			{
				if( QuestItemNameID[i * 5 + j] != -1)	
				{
					oneWinHeight = oneWinHeight + TEXT_HEIGHT;
				}
			}
			totalHeight = totalHeight + oneWinHeight +WINDOW_HEIGHT_MARGIN;
			
			QuestWnd[i].GetWindowSize(Width, Height);
			QuestWnd[i].SetWindowSize(Width, oneWinHeight);
			
			//GetButtonHandle ( "QuestAlarmWnd.hideButton" $ i + 1 ).MoveTo(QuestWnd[i].GetRect().nX, QuestWnd[i].GetRect().nY);
			//GetButtonHandle ( "QuestAlarmWnd.hideButton" $ i + 1 ).SetWindowSize(Width, oneWinHeight);

			// QuestWnd[i].SetTooltipText("니 하오! " @ i);
		}
	}
	
	if(m_NumOfQuest == 0)	
	{
		if(Me.IsShowWindow()) Me.HideWindow();
	}
	else
	{
		//debug("totalHeight = " $ totalHeight);
		Me.GetWindowSize(Width, Height);
		Me.SetWindowSize(Width, totalHeight);
		if(!Me.IsShowWindow()) Me.ShowWindow();	
	}
}

// 새로 만든 퀘스트 알람에 등록
// 알림 등록을 했을 때
// forceOpen 은 퀘스트 옵션 autoQuestAlarm 에 관계 없이 열고 닫고를 해줄때 사용
function AddQuestAlarmNew( int QuestID, string QuestName, int ItemID, string ItemName, int itemCount, INT64 ItemNum, int Level)
{
	//local string QuestName, ItemName;
	local int idx, idxItem, idxItemSomeID;
	//local INT64 itemCount;
	local String tempStr;
	//local int nWidth, nHeight;
	local Color tmpColor;
	//local bool QuestAutoAlarm;

	//local CustomTooltip T;
	
	//Debug("AddQuestAlarmNew"@QuestID@QuestName@ItemID@ItemName@itemCount);
	//QuestAutoAlarm = GetOptionBool("Game", "autoQuestAlarm"); 

	//// 옵션이 체크되어 있으면 그냥 리턴
	// if (QuestAutoAlarm == true && forceOpen == false) return;

	//아이템 이름이 아부것도 없으면 잘 못 전달 된 것이므로 리턴 함.
	if ( ItemName == "") return;
	
	idx = QuestSlotIdx(QuestID);
	// 퀘스트 아이디로 이미 등록된 퀘스트인지 검색한다.	
	if( idx == -1) 	// 이미 등록되어 있지 않은 퀘스트임.
	{
		idx = FindEmptyQuestSlot();

		// Debug("빈슬롯 idx " @ idx);
		// Debug("isClickedAdd " @ isClickedAdd);

		if(idx == -1)	// 빈슬롯이 없으면 꺼져!
		{
			// 5개 이상 등록할 수 없습니다. 시스템 메세지 보여주기.
			if(isClickedAdd == true)
			{
				AddSystemMessage(2279);
			}			
			isClickedAdd = false;
			return;
		}
		else
		{
			QuestAlarmName[idx].SetNameWithColor(QuestName, NCT_Normal,TA_Left, Gold);			
			/* 퀘스트 알람 툴팁 / 퀘스트 등록시 툴팁을 보여 준다.*/
			/* 퀘스트 파트 기획 내용 확인 후 진행 할 것.
			QuestWnd[idx].SetTooltipType("text");			
			QuestWnd[idx].SetTooltipCustomType( getQuestToolTip(QuestID, Level) );
			*/
			//Debug ( "툴팁 처리 " $ getQuestToolTip(QuestID, Level) );			
			
			QuestAlarmNameID[idx] = QuestID;
			QuestAlarmLevel[idx] = Level;
		}
	}

	// 아이템 이름 넣어주기.	
	idxItem = FindEmptyItemSlot(idx);	// 특정 퀘스트의 아이템 슬롯중 남은 것을 체크
	if(idxItem == -1)	// 빈슬롯이 없으면 꺼져!
	{
		//버그는 아니고 같은거 또 ADD 하면 여리 들어옴	
		return;
	}
	else
	{
		idxItemSomeID = QuestItemSlotIdx(idx, ItemID);		
		
		if(idxItemSomeID == -1)	//같은 아이템이 없다면 추가
		{
			//Debug( "itemCount>>>>" $ string(itemCount));
			//Debug( "ItemNum>>>>" $ string(ItemNum));
			
			if( ItemNum < 0 )
				ItemNum = -ItemNum;			

			tempStr = "- " $ ItemName;			

			if(itemCount < ItemNum || ItemNum == 0)			
				tmpColor = White;
			else			
				tmpColor = Gray;

			QuestItemName[idx*5 + idxItem].SetNameWithColor( tempStr, NCT_Normal,TA_Left, tmpColor);
			QuestItemNum[idx*5 + idxItem].SetTextColor(tmpColor);

			/*
			GetTextSizeDefault(tempStr, nWidth, nHeight);

			if(nWidth < CONTRACT_ITEM_NAME_WIDTH)
			{
				QuestItemName[idx*5 + idxItem].GetWindowSize( i , nHeight);	// i는 사용하지 않는 변수.
				QuestItemName[idx*5 + idxItem].SetWindowSize(nWidth , nHeight);
			}*/

			// 아이템 숫자 표시
			//if(ItemNum == 0)	QuestItemNum[idx*5 + idxItem].SetText( "(" $ itemCount $ "/" $ "∞ )");
			//if(ItemNum == 0)	QuestItemNum[idx*5 + idxItem].SetText( "(" $ itemCount $ "/" $ GetSystemString(858) $ ")");

			// Debug( "// 무제한 퀘는 현재 아이템의 개수만 표시해준다.>>>" $ string(ItemNum) );
			// 무제한 퀘는 현재 아이템의 개수만 표시해준다.
			if(ItemNum == 0 )
			{
				QuestItemNum[idx*5 + idxItem].SetText( "(" $ string(itemCount) $ ")");
			}
			else				
			{				
				QuestItemNum[idx*5 + idxItem].SetText( "(" $ string(itemCount) $ "/" $ string(ItemNum) $ ")");
				//if( itemCount < ItemNum )		QuestItemNum[idx*5 + idxItem].SetText( "(" $ itemCount $ "/" $ ItemNum $ ")");
				//else 						QuestItemNum[idx*5 + idxItem].SetText( "(" $ ItemNum $ "/" $ ItemNum $ ")");
			}
				
			QuestItemNameID[idx*5 + idxItem] = ItemID;	
			QuestItemNumInt[idx*5 + idxItem] = ItemNum;			
			setItemWindowSize( idx*5 + idxItem, tempStr);
		}
	}
	// Debug("idx" @ idx);
	// GetButtonHandle ( "QuestAlarmWnd.hideButton" $ idx + 1 ).SetTooltipCustomType(getQuestToolTip(QuestID, Level));
	
	FitWindowSize();
}

function setItemWindowSize( int index, string tmpStr )
{
	local int nWidth, nWidth2, nHeight;
	local Rect myRectWnd ;
	// 보이지 않는 값 ( 텍스트 시작위치, 텍스트 박스간의 간격 과, 배경보더 고려 )
	local int offSetX ;	
	offSetX = 25;
	myRectWnd = Me.GetRect() ;

	GetTextSizeDefault( tmpStr, nWidth, nHeight);
	GetTextSizeDefault( QuestItemNum[index].GetText(), nWidth2, nHeight);

	QuestItemNum[index].GetWindowSize( nWidth2, nHeight );	

	if ( nWidth + nWidth2 + offSetX > myRectWnd.nWidth)
	{
		nWidth = myRectWnd.nWidth - nWidth2 - offSetX;	
	}
	
	QuestItemName[index].SetWindowSize ( nWidth, nHeight );
}

/**
 * 커스텀툴팁(서브잡클래스변환버튼에사용)
 **/
function CustomTooltip getQuestToolTip (int QuestID, int Level)
{
	local CustomTooltip m_Tooltip;
	local string questDesc, trimStr, huntingStr, tempStr, journalName;

	local Vector questZoneLoc;
	local int questZoneID, tooltipLine;

	
	questZoneLoc    = class'UIDATA_QUEST'.static.GetTargetLoc(QuestID, Level);
	
	questZoneID		= class'UIDATA_QUEST'.static.GetQuestZone(QuestID, Level);
	// questZoneName   = GetInZoneNameWithZoneID(questZoneID) @ ":::" @ class'UIDATA_HUNTINGZONE'.static.GetHuntingZoneName(questZoneID);

	journalName     = class'UIDATA_QUEST'.static.GetQuestJournalName(QuestID, Level);

	questDesc       = class'UIDATA_QUEST'.static.GetQuestDescription( QuestID, Level);
		
	trimstr = trim(questdesc);

	questdesc  = substitute( questdesc, "\\n", " ", false);

	huntingstr = cutthestr(questdesc, GetSystemString(3318), true);   // 사냥할 몬스터 를 기준으로 커팅
	tempstr    = cutthestr(questdesc, GetSystemString(3318), false);

	if (len(tempstr) > 0) questdesc = tempstr;

	if (len(huntingstr) > 0) tooltipLine = 4;
	else tooltipLine = 3;
	
	// 제품 설명 
	if (Len(questDesc)>0)
	{	
		m_Tooltip.DrawList.Length = tooltipLine;
		
		m_Tooltip.MinimumWidth = 230;
		m_Tooltip.DrawList[0].eType = DIT_TEXT;
		m_Tooltip.DrawList[0].t_color.R = 255;
		m_Tooltip.DrawList[0].t_color.G = 255;
		m_Tooltip.DrawList[0].t_color.B = 255;
		m_Tooltip.DrawList[0].t_color.A = 255;
		m_Tooltip.DrawList[0].t_strText = journalName;

		m_Tooltip.DrawList[1].eType = DIT_BLANK;
		m_Tooltip.DrawList[1].b_nHeight = 3;
		
		/*
		m_Tooltip.DrawList[2].eType = DIT_SPLITLINE;
		m_Tooltip.DrawList[2].u_nTextureWidth = 230;			
		m_Tooltip.DrawList[2].u_nTextureHeight = 1;
		m_Tooltip.DrawList[2].u_strTexture ="L2ui_ch3.tooltip_line";*/
		
		m_Tooltip.DrawList[2].eType = DIT_TEXT;
		m_Tooltip.DrawList[2].nOffSetY = 4;
		m_Tooltip.DrawList[2].bLineBreak = true;
		m_Tooltip.DrawList[2].t_color.R = 178;
		m_Tooltip.DrawList[2].t_color.G = 190;
		m_Tooltip.DrawList[2].t_color.B = 207;
		m_Tooltip.DrawList[2].t_color.A = 255;
		m_Tooltip.DrawList[2].t_strText = questDesc;

		if (tooltipLine > 3)
		{
			// 빨간색으로 몬스터 표시
			m_Tooltip.DrawList[3].eType = DIT_TEXT;
			m_Tooltip.DrawList[3].nOffSetY = 10;
			m_Tooltip.DrawList[3].bLineBreak = true;
			m_Tooltip.DrawList[3].t_color.R = 211;
			m_Tooltip.DrawList[3].t_color.G = 30;
			m_Tooltip.DrawList[3].t_color.B = 30;
			m_Tooltip.DrawList[3].t_color.A = 255;
			// m_Tooltip.DrawList[4].t_strFontName = "hs10";
			m_Tooltip.DrawList[3].t_strText = huntingStr;
		}
	}	

	return m_Tooltip;
}

function string TrimRight(string S)
{
	S = Left(S, Len(S) - 1);
	return S;
}

/** 지정한 스트링 부터, 끝까지 문자열을 짤라 낸다. **/
function string cutTheStr(string s, string t, bool cutStringEnd)
{
	local int i;
	
	i = InStr(s , t);

	if (i <= -1) return "";
	else 
	{
		if (cutStringEnd) return Mid(s, i , len(s));	
		else return Mid(s, 0, i);	
	}
	
}

// 퀘스트 알람에서 삭제
function DeleteQuestAlarm(int QuestID )	
{
	local int idx;
	local Color tempColor;
	local int nWidth, nHeight;
	
	idx = QuestSlotIdx(QuestID); 
	
	if( idx == -1) 	// 이미 등록되어 있지 않은 퀘스트라면 아무것도 하지 않는다.
	{
		return; 
	}
	else
	{		
		// 아래 퀘스트들 땡겨주기
		for(i = idx + 1 ;  i < MAX_QUEST ; i++)
		{
			QuestAlarmName[i -1].SetNameWithColor( QuestAlarmName[i].GetName(), NCT_Normal,TA_Left, Gold);
			//QuestWnd[i -1].SetTooltipType("text");
			//QuestWnd[i -1].SetTooltipText( "툴팁이 보이는지2 ?" );
			//QuestAlarmName[i -1].SetTooltipCustomType( getQuestToolTip(QuestAlarmNameID[i], QuestAlarmLevel[i]) );

			QuestAlarmNameID[i-1] = QuestAlarmNameID[i];
			QuestAlarmLevel[i-1] = QuestAlarmLevel[i];
	
			for (j=0 ; j<MAX_ITEM ; j++)
			{		
				tempColor =  QuestItemNum[i*5 + j].GetTextColor();
				
				QuestItemName[(i-1)*5 + j].SetNameWithColor(QuestItemName[i*5 + j].GetName() , NCT_Normal,TA_Left, tempColor);
				QuestItemName[i*5 + j].GetWindowSize(nWidth, nHeight);			// 윈도우 사이즈를 옮겨준다.
				QuestItemName[(i-1)*5 + j].SetWindowSize(nWidth, nHeight);
				QuestItemNameID[(i-1)*5 + j] = QuestItemNameID[i*5 + j]; 	
				QuestItemNum[(i-1)*5 + j].SetText( QuestItemNum[i*5 + j].GetText() );
				QuestItemNum[(i-1)*5 + j].SetTextColor (tempColor);
				QuestItemNumInt[(i-1)*5 + j] = QuestItemNumInt[i*5 + j];
			}
		}
		
		idx = MAX_QUEST - 1;
		QuestAlarmName[idx].SetName("", NCT_Normal,TA_Left);
		QuestAlarmNameID[idx] = -1;	
		QuestAlarmLevel[idx] = -1;
		for (j=0 ; j<MAX_ITEM ; j++)
		{		
			QuestItemName[idx*5 + j].SetName("", NCT_Normal,TA_Left);			
			QuestItemNameID[idx*5 + j] = -1; 	// -1이면 빈슬롯
			QuestItemNum[idx*5 + j].SetText("");
			QuestItemNumInt[idx*5 + j] = -1;
		}
	}
	
	 FitWindowSize();
}

// 특정 아이디에 해당하는 퀘스트 아이템의 개수를 갱신하여 준다.
function UpdateAlarmItem(int ItemID , INT64 Count, optional int questID)
{
	local string NameTemp1;
	local INT64 counts;
	
	for( i = 0; i < MAX_QUEST_ALL; i++ )
	{
		//Debug( "UpdateAlarmItem" @ questID @ Count ) ;
		// QuestItemNameID[ i ] == ItemID 
		// questID == QuestAlarmNameID[i]  ☞ 몬스터 처치의 경우 퀘스트 아이디가 같은 것만 갱신 한다. 
		// QuestAlarmNameID[i] == -1  ☞ 생성 되지 않는 경우 
		if( QuestItemNameID[ i ] == ItemID && ( questID == QuestAlarmNameID[i] || questID == 0 || QuestAlarmNameID[i] == -1) )	
		{	
			//debug( "[Count]" $string(Count) );
			//debug( "[QuestItemNumInt[ i ]]" $string(QuestItemNumInt[ i ]) );
			
			if( QuestItemNumInt[ i ] < 0 )
				counts = -(QuestItemNumInt[ i ]);
			else
				counts= QuestItemNumInt[ i ];

			if( Count < counts || counts == 0 )	
			{	
				NameTemp1 = QuestItemName[ i ].GetName();
				QuestItemName[ i ].SetNameWithColor( NameTemp1, NCT_Normal,TA_Left, White );
				QuestItemNum[ i ].SetTextColor( White );	
			}
			else
			{	
				NameTemp1 = QuestItemName[ i ].GetName();
				QuestItemName[ i ].SetNameWithColor( NameTemp1, NCT_Normal,TA_Left, Gray );
				QuestItemNum[ i ].SetTextColor( Gray );
			}

			if( counts == 0 )
			{
				QuestItemNum[i].SetText( "(" $ string( Count ) $ ")");
			}
			else
			{	
				QuestItemNum[i].SetText( "(" $ string( Count) $ "/" $ string( counts )  $ ")");
			}

			setItemWindowSize( i, NameTemp1);
		}
	}
}

function UpdateAlarmExpand(int npcId , int Count)
{
	local string NameTemp1;

	for( i = 0; i<MAX_QUEST_ALL ; i++ )
	{
		if( QuestItemNameID[ i ] == npcId )	
		{			
			if( Count < QuestItemNumInt[ i ]  || QuestItemNumInt[ i ] == 0)	
			{	
				NameTemp1 = QuestItemName[ i ].GetName();
				QuestItemName[ i ].SetNameWithColor( NameTemp1, NCT_Normal,TA_Left, White );
				QuestItemNum[ i ].SetTextColor( White );	
			}
			else
			{	
				NameTemp1 = QuestItemName[ i ].GetName( );
				QuestItemName[ i ].SetNameWithColor( NameTemp1, NCT_Normal,TA_Left, Gray );
				QuestItemNum[ i ].SetTextColor( Gray );
			}
			
			if( QuestItemNumInt[i] == 0 )	
			{
				QuestItemNum[ i ].SetText( " (" $ string(Count) $ ")");
			}
			else				
			{	
				QuestItemNum[i].SetText( " (" $ string(Count) $ "/" $ string(QuestItemNumInt[i])  $ ")");
			}				
		}
	}
}

// 빈 퀘스트 슬롯을 찾는다. -1이면 꽉 찼음
function int FindEmptyQuestSlot()
{
	local int slotID;
	
	slotID = -1;
	
	for(i = 0; i<MAX_QUEST ; i++)
	{
		if( QuestAlarmNameID[i] == -1)	
		{
			slotID = i;
			break;
		}
	}
	
	return slotID;
}

//해당 퀘스트 아이디의 인텍스를 리턴한다. 
function int QuestSlotIdx(int QuestID)
{
	local int slotID;
	
	slotID = -1;
	
	for(i = 0; i<MAX_QUEST ; i++)
	{
		if( QuestAlarmNameID[i] == QuestID)
		{
			slotID = i;
			break;
		}
	}
	
	return slotID;
}

// 빈 퀘스트 아이템 슬롯을 찾는다. -1이면 꽉 찼음
function int FindEmptyItemSlot(int QuestIdx)
{
	local int itemSlotID;
	
	itemSlotID = -1;
	for(i = 0; i<MAX_ITEM ; i++)
	{
		if( QuestItemNameID[QuestIdx * 5 + i] == -1)	
		{
			itemSlotID = i;
			break;
		}
	}
	
	return itemSlotID;
}

//해당 퀘스트 아이템의 아이디 인텍스를 리턴한다. 
function int QuestItemSlotIdx(int QuestIdx , int ItemID)
{
	local int itemSlotID;
	
	itemSlotID = -1;	
	for(i = 0; i<MAX_ITEM ; i++)
	{
		if(QuestItemNameID[QuestIdx * 5 + i]== ItemID)
		{
			itemSlotID = i;
			break;
		}
	}
	
	return itemSlotID;
}


// 퀘스트 알람에 등록한다.
/*
 * 사용 하는 곳이 없음 .
function AddQuestAlarm(int QuestID, int Level, int ItemID, INT64 ItemNum)
{
	local string QuestName, ItemName;
	local int idx, idxItem, idxItemSomeID;
	local INT64 itemCount;
	local String tempStr;
	local int nWidth, nHeight;
	
	//local int nItemNumWidth, nItemNumHeight;
		
	QuestName = class'UIDATA_QUEST'.static.GetQuestName(QuestID, Level);
	ItemName = class'UIDATA_ITEM'.static.GetItemName(GetItemID(ItemID));
	
	//debug( "QuestName>>" $ QuestName );
	//debug( "ItemName>>" $ ItemName );

	// Debug("AddQuestAlarm"@QuestID@QuestName@ItemID@ItemName@itemCount);

	// 퀘스트 아이디로 이미 등록된 퀘스트인지 검색한다.	
	idx = QuestSlotIdx(QuestID);
	if( idx == -1) 	// 이미 등록되어 있지 않은 퀘스트임.
	{
		idx = FindEmptyQuestSlot();
		if(idx == -1)	// 빈슬롯이 없으면 꺼져!
		{
			// 5개 이상 등록할 수 없습니다. 시스템 메세지 보여주기.
			if(isClickedAdd == true)
			{
				AddSystemMessage(2279);
			}			
			isClickedAdd = false;
			return;
		}
		else
		{
			QuestAlarmName[idx].SetNameWithColor(QuestName, NCT_Normal,TA_Left, Gold);
			//QuestWnd[idx].SetTooltipCustomType( getQuestToolTip(QuestID, Level) );
			//QuestWnd[idx].SetTooltipType("text");
			//QuestWnd[idx].SetTooltipText( "툴팁이 보이는지 ?" );//getQuestToolTip(QuestID, Level) );
			QuestAlarmNameID[idx] = QuestID;
		}
	}	
	
	// 아이템 이름 넣어주기.	
	idxItem = FindEmptyItemSlot(idx);	// 특정 퀘스트의 아이템 슬롯중 남은 것을 체크

	if(idxItem == -1)	// 빈슬롯이 없으면 꺼져!
	{
		//버그는 아니고 같은거 또 ADD 하면 여리 들어옴	
		return;
	}
	else
	{
		idxItemSomeID = QuestItemSlotIdx(idx, ItemID);
		
		if(idxItemSomeID == -1)	//같은 아이템이 없다면 추가
		{
			itemCount = GetInventoryItemCount(GetItemID(ItemID));		
			
			//debug("itemcount  = " $ string(itemCount));
			
			if(itemCount < ItemNum || ItemNum == 0)
			{
				tempStr = "- " $ ItemName;				
				GetTextSizeDefault(tempStr, nWidth, nHeight);				
				QuestItemName[idx*5 + idxItem].SetNameWithColor( tempStr, NCT_Normal,TA_Left, White);
				QuestItemNum[idx*5 + idxItem].SetTextColor(White);
				
				if(nWidth < CONTRACT_ITEM_NAME_WIDTH)
				{
					QuestItemName[idx*5 + idxItem].GetWindowSize( i , nHeight);	// i는 사용하지 않는 변수. 
					QuestItemName[idx*5 + idxItem].SetWindowSize(nWidth , nHeight);
				}
			}

			else
			{
				tempStr = "- " $ ItemName;
				GetTextSizeDefault(tempStr, nWidth, nHeight);
				QuestItemName[idx*5 + idxItem].SetNameWithColor(tempStr, NCT_Normal,TA_Left, Gray);
				QuestItemNum[idx*5 + idxItem].SetTextColor(Gray);
				
				if(nWidth < CONTRACT_ITEM_NAME_WIDTH)
				{
					QuestItemName[idx*5 + idxItem].GetWindowSize( i , nHeight);	// i는 사용하지 않는 변수. 
					QuestItemName[idx*5 + idxItem].SetWindowSize(nWidth , nHeight);
				}
				//Debug ( "AddQuestAlarm" @ tempStr);
			}
			 
			// 아이템 숫자 표시
			//if(ItemNum == 0)	QuestItemNum[idx*5 + idxItem].SetText( "(" $ itemCount $ "/" $ "∞ )");
			//if(ItemNum == 0)	QuestItemNum[idx*5 + idxItem].SetText( "(" $ itemCount $ "/" $ GetSystemString(858) $ ")");
			if(ItemNum < 1)	{QuestItemNum[idx*5 + idxItem].SetText( "(" $ string(itemCount) $ ")");}	// 무제한 퀘는 현재 아이템의 개수만 표시해준다.
			else				
			{				
				QuestItemNum[idx*5 + idxItem].SetText( "(" $ string(itemCount) $ "/" $ string(ItemNum) $ ")");
				//if( itemCount < ItemNum )		QuestItemNum[idx*5 + idxItem].SetText( "(" $ itemCount $ "/" $ ItemNum $ ")");
				//else 						QuestItemNum[idx*5 + idxItem].SetText( "(" $ ItemNum $ "/" $ ItemNum $ ")");
			}
				
			QuestItemNameID[idx*5 + idxItem] = ItemID;	
			QuestItemNumInt[idx*5 + idxItem] = ItemNum;
		}
	}

	// Debug("idx" @ idx);
	// GetButtonHandle ( "QuestAlarmWnd.hideButton" $ idx + 1 ).SetTooltipCustomType(getQuestToolTip(QuestID, Level));
	
	FitWindowSize();
	
	isClickedAdd = false;
}

function AddQuestAlarmExpand(int questID, int questLevel, int npcId, int numOfKillMonsters, INT64 npcMaxCount )
{
	local int npcCurrentCount;

	local string questName, npcName;
	local int existQuestIndex ;//, emptySlotIndex;
	local int emptyNpcSlotIndex, existNpcSlotIndex;

	local string tempStr;
	local int nWidth, nHeight;

	questName = class'UIDATA_QUEST'.static.GetQuestName( questId, questLevel );

	//if( questType == 0)
	//{
	npcName = class'UIDATA_NPC'.static.GetNPCName( npcId - 1000000 );
	//}

	//debug( "questName>>" $ questName );
	//debug( "npcName>>" $ npcName );

	// 처치 : 2240
	npcName = npcName $ " " $ GetSystemString(2240);

	npcCurrentCount = numOfKillMonsters;

	existQuestIndex = QuestSlotIdx( questId );
	if( existQuestIndex == -1 )
	{
		existQuestIndex = FindEmptyQuestSlot( );
		if( existQuestIndex == -1 )
		{
			if( isClickedAdd == true )
			{
				AddSystemMessage( 2279 );
			}	
			isClickedAdd = false;
			return;
		}
		else
		{
			QuestAlarmName[existQuestIndex].SetNameWithColor( questName, NCT_Normal, TA_Left, Gold );
			//QuestAlarmName[existQuestIndex].SetTooltipCustomType( getQuestToolTip(QuestID, questLevel) );
			//QuestWnd[existQuestIndex].SetTooltipType("text");
			//QuestWnd[existQuestIndex].SetTooltipText( "툴팁이 보이는지 ?" );

			
			QuestAlarmNameID[existQuestIndex] = questId;
		}
	}

	emptyNpcSlotIndex = FindEmptyItemSlot( existQuestIndex );
	if(emptyNpcSlotIndex == -1)	
	{
		return;
	}
	else
	{
		existNpcSlotIndex = QuestItemSlotIdx( existQuestIndex, npcId );

		if( existNpcSlotIndex == -1 )
		{
			if( npcCurrentCount < npcMaxCount || npcMaxCount == 0 )
			{
				tempStr = "- " $ npcName;
				GetTextSizeDefault( tempStr, nWidth, nHeight );
				QuestItemName[ existQuestIndex * 5 + emptyNpcSlotIndex ].SetNameWithColor( tempStr, NCT_Normal, TA_Left, White );
				QuestItemNum[ existQuestIndex * 5 + emptyNpcSlotIndex ].SetTextColor( White );

				if( nWidth < CONTRACT_ITEM_NAME_WIDTH )
				{
					QuestItemName[existQuestIndex * 5 + emptyNpcSlotIndex].GetWindowSize( i , nHeight );
					QuestItemName[existQuestIndex * 5 + emptyNpcSlotIndex].SetWindowSize( nWidth , nHeight );
				}
			}
			else
			{
				tempStr = "- " $ npcName;
				GetTextSizeDefault( tempStr, nWidth, nHeight );
				QuestItemName[ existQuestIndex * 5 + emptyNpcSlotIndex ].SetNameWithColor( tempStr, NCT_Normal, TA_Left, Gray );
				QuestItemNum[ existQuestIndex * 5 + emptyNpcSlotIndex ].SetTextColor( Gray );

				if( nWidth < CONTRACT_ITEM_NAME_WIDTH )
				{
					QuestItemName[existQuestIndex * 5 + emptyNpcSlotIndex].GetWindowSize( i , nHeight );
					QuestItemName[existQuestIndex * 5 + emptyNpcSlotIndex].SetWindowSize( nWidth , nHeight );
				}
			}

			if( npcMaxCount < 1 )
			{
				QuestItemNum[existQuestIndex * 5 + emptyNpcSlotIndex ].SetText( " (" $ string( npcCurrentCount ) $ ")" );
			}
			else				
			{		
				QuestItemNum[existQuestIndex * 5 + emptyNpcSlotIndex ].SetText( " (" $ string( npcCurrentCount ) $ "/" $ string( npcMaxCount ) $ ")" );
			}
				
			QuestItemNameID[existQuestIndex * 5 + emptyNpcSlotIndex ] = npcId;
			QuestItemNumInt[existQuestIndex * 5 + emptyNpcSlotIndex ] = npcMaxCount;
		}
	}

	FitWindowSize();	
	isClickedAdd = false;	
}

function int getLevel (int QuestID)
{
	local int i;
	
	// 마지막 레벨을 받아야 하므로 뒤에서 부터 돌린다.
	for( i = scQuestTree.ArrQuest.Length - 1 ; i >= 0  ; i -- )
	{
		if( QuestID == scQuestTree.ArrQuest[i].QuestID )
		{			
			return scQuestTree.ArrQuest[i].Level ;			
		}		
	}
	return 0 ;
}*/
defaultproperties
{
}
