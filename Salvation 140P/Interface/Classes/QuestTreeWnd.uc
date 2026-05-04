class QuestTreeWnd extends UICommonAPI;

const QUESTTREEWND_MAX_COUNT = 40;

const QUEST_WINDOW_ONE = 0;
const QUEST_WINDOW_REPEAT  = 1;
const QUEST_WINDOW_EPIC = 2;
const QUEST_WINDOW_JOB = 3;
const QUEST_WINDOW_SPECIAL = 4;

var WindowHandle Me;
var TabHandle QuestTreeTab;
var TextureHandle TexTabBg;
var TextureHandle TexTabBgLine;
var TextBoxHandle txtQuestTreeTitle;
var TextBoxHandle txtQuestNum;

var TreeHandle MainTree0;
var TreeHandle MainTree1;
var TreeHandle MainTree2;
var TreeHandle MainTree3;
var TreeHandle MainTree4;
var TreeHandle CurTree;

var CheckBoxHandle chkAssignNotifier;
var CheckBoxHandle chkNpcPosBox;
var ButtonHandle btnDetailInfo;

//Tree Root 이름.
var string ROOTNAME;
//일회성 퀘스트 Tree
var string TREE0;
//반복성 퀘스트 Tree
var string TREE1;
//에픽 퀘스트 Tree
var string TREE2;
//전직 퀘스트 Tree
var string TREE3;
//특수 퀘스트 Tree
var string TREE4;

struct QuestUseInfo
{
	//퀘스트 아이디 저장
	var int                 QuestID;
	//퀘스트 레벨 저장
	var int                 Level;
	//퀘스트 완료 저장
	var int                 Completed;
	//퀘스트 타입 저장
	var int                 QuestType;

	//?? 먼지 머름..;;
	var bool                bShowCompletionItem;

	//퀘스트 필요 아이템 ID
	var array<int>		    ArrNeedItemIDList;
	//퀘스트 필요 아이템 개수
	var array<int>		    ArrNeedItemNumList;
	//퀘스트 골 타입 
	var array<int>		    ArrGoalType;

	
	//보상 아이템 ID
	var Array<int>          RewardIDList;	
	//보상 아이템 개수
	var Array<INT64>          RewardNumList;
};

//퀘스트 정보의 배열
var array<QuestUseInfo> ArrQuest;

//tree 배경용 변수
var bool bDrawBgTree;

var string beforeTreeName;

var QuestAlarmWnd       scQuestAlarm;
var QuestTreeDrawerWnd  scTreeDrawer;
	
var ButtonHandle      m_btnAddAlarm;
var ButtonHandle      m_btnDeleteAlarm;


//Tree 생성용 변수
var L2Util util;

var int     QuestID_Alarm;
var int     QuestLevel_Alarm;
var int     QuestEnd_Alarm;

//현재 퀘스트 갯수
var int		m_QuestNum;	
//이전 퀘스트 번호
var int		m_OldQuestID;

//미니멥 추적 도구 퀘스트
var ListCtrlHandle 					ListTrackItem1;
var array<LVDataRecord>				m_QuestTrackData;
var int	m_TrackID;

var int		    m_DeleteQuestID;
var string		m_DeleteNodeName;

//GM Tool 용.
var String 		m_WindowName;

var int         m_recentlyQuestID; //새로 들어온 퀘스트 임시 저장  (getExpandQuestID가 제대로 작동 되지 않음)

var NoticeWnd      noticeWndScript;

// 현재 방향을 가르키고 있는 (월드맵에서)
var vector currentQuestDirectTargetPos;
var string currentQuestDirectTargetString;

//var Bool        m_IsShowArrow; //ldw 3D 화살표가 보여 지고 있는지 여부 -> 퀘스트 창에서만 3d 화살표를 끄고 킬 수 있도록 하는 기능에 들어감.

//var EMinimapTargetIcon DirIconDestType; //ldw 지금 보여 지고 있는 타겟화살표 타입

function OnRegisterEvent()
{	
	RegisterEvent( EV_QuestListStart );
	RegisterEvent( EV_QuestList );
	RegisterEvent( EV_QuestListEnd );
	RegisterEvent( EV_QuestSetCurrentID );	
	RegisterEvent( EV_DialogOK );
	RegisterEvent( EV_Restart );
	
}

function OnLoad()
{
	SetClosingOnESC();

	Initialize();

	util = L2Util(GetScript("L2Util"));	
	scQuestAlarm = QuestAlarmWnd( GetScript( "QuestAlarmWnd" ) );
	scTreeDrawer = QuestTreeDrawerWnd(GetScript("QuestTreeDrawerWnd"));
	noticeWndScript = NoticeWnd(GetScript("NoticeWnd"));

	//	m_IsShowArrow = false;
	CurTree = MainTree0;
	chkNpcPosBox.SetCheck(true);
	bDrawBgTree = false;
	m_QuestNum = 0;
	m_OldQuestID = 0;
	m_recentlyQuestID = 0;


}

function Initialize()
{
	Me =                    GetWindowHandle( m_WindowName );
	QuestTreeTab =          GetTabHandle(m_WindowName$".QuestTreeTab" );
	TexTabBg =              GetTextureHandle( m_WindowName$".TexTabBg" );
	TexTabBgLine =          GetTextureHandle( m_WindowName$".TexTabBgLine" );
	txtQuestTreeTitle =     GetTextBoxHandle( m_WindowName$".txtQuestTreeTitle" );
	txtQuestNum =           GetTextBoxHandle( m_WindowName$".txtQuestNum" );
	
	MainTree0 =             GetTreeHandle( m_WindowName$".MainTree0" );
	MainTree1 =             GetTreeHandle( m_WindowName$".MainTree1" );
	MainTree2 =             GetTreeHandle( m_WindowName$".MainTree2" );
	MainTree3 =             GetTreeHandle( m_WindowName$".MainTree3" );
	MainTree4 =             GetTreeHandle( m_WindowName$".MainTree4" );
	chkAssignNotifier =     GetCheckBoxHandle( m_WindowName$".chkAssignNotifier" );
	chkNpcPosBox =          GetCheckBoxHandle( m_WindowName$".chkNpcPosBox" );
	btnDetailInfo =         GetButtonHandle( m_WindowName$".btnDetailInfo" );

	m_btnAddAlarm =         GetButtonHandle("QuestTreeDrawerWnd.btnAddAlarm");
	m_btnDeleteAlarm =      GetButtonHandle("QuestTreeDrawerWnd.btnDeleteAlarm");

	//ListTrackItem1 = GetListCtrlHandle( "MiniMapDrawerWnd.ListTrackItem1" );
}

function OnDefaultPosition()
{
	QuestTreeTab.MergeTab(QUEST_WINDOW_ONE);
	QuestTreeTab.MergeTab(QUEST_WINDOW_REPEAT);
	QuestTreeTab.MergeTab(QUEST_WINDOW_EPIC);
	QuestTreeTab.MergeTab(QUEST_WINDOW_JOB);
	QuestTreeTab.MergeTab(QUEST_WINDOW_SPECIAL);
	QuestTreeTab.SetTopOrder(0, true);
}


function OnShow()
{
	local bool      QuestAutoAlarm;
	local string    ExpandedNode;
	local int       nQuestType;

	//Debug ( " onShow");
	QuestTreeTab.InitTabCtrl();		

	//ldw 퀘스트 연동을 위해 추가 된 부분
	ExpandedNode = GetExpandedNode();
	nQuestType = Class'UIDATA_QUEST'.static.GetQuestIscategory(getCurQuestID(), 1);
//	Debug("nQuestType" @ nQuestType @ "getCurQuestID()"@getCurQuestID() @"ExpandedNode"@ExpandedNode);
	//ldw 퀘스트 연동을 위해 추가 된 부분
//	InsertQuestTrackList();
	
	ShowQuestList();	//원래 있던 부분 리스트를 다시 받음
	
	CurTree = GetTreeHandle( m_WindowName$".MainTree"$nQuestType );

	if (ExpandedNode != "NULL"){	
		QuestTreeTab.SetTopOrder(nQuestType, false); //텝 바꾸고
		CurTree.SetExpandedNode( ExpandedNode, true);//노드 확장		
		//Debug("OnShow "@ ExpandedNode);
		CheckQuestTrackList();                       //미니맵의 체크 상태 바꿈
	}
	

	//InsertQuestTrackList();
	
	//Debug("GetExpandedNode()4"@ GetExpandedNode());
	
	QuestAutoAlarm = GetOptionBool("Game", "autoQuestAlarm");
	scQuestAlarm.UpdateOptionData();
	
	if(QuestAutoAlarm == true)
	{
		chkAssignNotifier.SetCheck(true);
	}
	else
	{
		chkAssignNotifier.SetCheck(false);
	}
	//MainTree0.HideWindow();
	//MainTree1.HideWindow();
	//MainTree2.HideWindow();
	//MainTree3.HideWindow();
	//MainTree4.HideWindow();
	
	
	/*if (CurTree == MainTree0)
	{
		QuestTreeTab.SetTopOrder(0,false);
	}
	else if (CurTree == MainTree1)
	{
		QuestTreeTab.SetTopOrder(1,false);
	}
	else if (CurTree == MainTree2)
	{
		QuestTreeTab.SetTopOrder(2,false);
	}
	else if (CurTree == MainTree3)
	{
		QuestTreeTab.SetTopOrder(3,false);
	}
	else if (CurTree == MainTree4)
	{
		QuestTreeTab.SetTopOrder(4,false);
	}*/
	CurTree.Setfocus();
}

//////////////////////
//Request Quest List
function ShowQuestList()
{
	class'QuestAPI'.static.RequestQuestList();		//EV_QuestListStart -> EV_QuestList -> EV_QuestListEnd	
}

function OnClickButton( string strID )
{
	// Debug("onClickButton"@strID);
	
	switch( strID )
	{
		case "btnClose":
			if (class'UIAPI_WINDOW'.static.IsShowWindow("QuestTreeDrawerWnd"))
			{
				class'UIAPI_WINDOW'.static.HideWindow( "QuestTreeDrawerWnd" );	
			}
			else 
			{
				UpdateTargetInfo();
				class'UIAPI_WINDOW'.static.ShowWindow( "QuestTreeDrawerWnd" );	
			}
			break;	

		case "QuestTreeTab0":
			setTabChange(0);
			break;

		case "QuestTreeTab1":
			setTabChange(1);
			break;

		case "QuestTreeTab2":
			setTabChange(2);
			break;

		case "QuestTreeTab3":
			setTabChange(3);
			break;

		case "QuestTreeTab4":
			setTabChange(4);
			break;

		case "btnDetailInfo":
			OnbtnDetailInfoClick();
			break;
	}

	selectQuestTree(strID, true);
	
//	HandleQuestSetCurrentID(strID);

	/*
	if ( Left( strID, 4 ) == ROOTNAME )
	{	
		UpdateTargetInfo();
		//GetCurrentJournalID(strID);
		//Drawer_btnGiveUpCurrentQuest.EnableWindow();		
		// 클릭 된 퀘스트가 첫번째 노드인 경우 마지막 노드의 퀘스트를 보여 줄 것.
		scTreeDrawer.showQuestDrawer( strID );

		//showQuestDrawerLstChild(); ldw 만들다 만 것임
		
		ButtonEnableCheck();ui4 
	}
}*/

}

// 퀘스트 트리 오픈
function selectQuestTree(string strID, bool isButtonClick)
{
	local int SplitCount ;//, questCategory;
	local array<string>	arrSplit;	

	if ( Left( strID, 4 ) == ROOTNAME )
	{			

		// 클릭 된 퀘스트가 첫번째 노드인 경우 마지막 노드의 퀘스트를 보여 줄 것.
		SplitCount = Split( strID, ".", arrSplit );

		//questCategory = Class'UIDATA_QUEST'.static.GetQuestType(int(arrSplit[1]), 1 );

		//Debug("quest num :" @ arrSplit[1]);

		// 강제로 함수를 실행시켜서 트리를 선택하는 것과 트리에 버튼을 클릭 하는 것 구분
		if (isButtonClick == false)	CurTree.SetExpandedNode(strID, true);

		m_recentlyQuestID = 0;
		UpdateTargetInfo();		
		if (getExpandedNode() == "" )  //확장 된 노드가 없을 
		{		
			if (class'UIAPI_WINDOW'.static.IsShowWindow("QuestTreeDrawerWnd"))
			{
				class'UIAPI_WINDOW'.static.HideWindow( "QuestTreeDrawerWnd" );	
			}
			//ListTrackItem1.SetSelectedIndex(-1, false);//미니맵의 퀘스트 선택 끄기
		} 
		else 
		{   			
			//GetCurrentJournalID(strID);
			//Drawer_btnGiveUpCurrentQuest.EnableWindow();					
			//setMiniMapDrawerQuest();
			
			if( SplitCount == 2 )
			{
				scTreeDrawer.showQuestDrawer( LastNodeName( int(arrSplit[1]), 1, Class'UIDATA_QUEST'.static.GetQuestIscategory( int( arrSplit[1] ), 1 ) ) );			
			}
			else if( SplitCount == 4 )
			{
				scTreeDrawer.showQuestDrawer( strID );
			}
			ButtonEnableCheck();
		}
	}		
}


/*function showQuestDrawerLstChild()
{
	local array<string>		arrSplit;
	local int				SplitCount;
	
	local int QuestID;
	local int Level;
	local int Completed;
	
	local string strChildList;
	local string strTargetNode;
	
	local string strNodeName;
	local string strTargetName;
	local vector vTargetPos;
	local bool bOnlyMinimap;

	//위치표시 체크박스
	if ( !chkNpcPosBox.IsChecked() )
	{
		 SetQuestOff();
		 return;
	}
	
	strNodeName = GetExpandedNode();

	if (Len(strNodeName)<1)
	{
		SetQuestOff();
		return;
	}

	///////////////////////////////////////////////////////////////////////
	//Expanded된 노드가 가리키는 퀘스트의 Target표시용 저널을 찾아야함
	///////////////////////////////////////////////////////////////////////
	
	// 1. Child노드를 구한다.
	strChildList = CurTree.GetChildNode(strNodeName);
	
	// 2. Child가 있으면, Child중에서 가장 마지막 Child가 Target표시용 저널
	if (Len(strChildList)>0)
	{
		SplitCount = Split(strChildList, "|", arrSplit);
		strTargetNode = arrSplit[SplitCount-1];
		Debug("strTargetNode" @ strTargetNode);
	}
	else
	{
		SetQuestOff();
		return;
	}
	// 3. 이름을 분석해서, QuestID와 Level을 취득  필요 없음 퀘스트 노드만 필요
	arrSplit.Remove(0,arrSplit.Length);
	SplitCount = Split( strTargetNode, ".", arrSplit );
	QuestID = int( arrSplit[1] );

	if( SplitCount == 2 )
	{
		Level = 1;
		Completed = 0;
	}
	else if( SplitCount == 4 )
	{
		Level = int( arrSplit[2] );
		Completed = int( arrSplit[3] );
	}

	if ( QuestID > 0 && Level > 0 )
	{
		//Target이름 취득
		strTargetName = class'UIDATA_QUEST'.static.GetTargetName(QuestID, Level);
		vTargetPos = class'UIDATA_QUEST'.static.GetTargetLoc(QuestID, Level);
		
		if (Completed==0 && Len(strTargetName)>0)
		{
			bOnlyMinimap = class'UIDATA_QUEST'.static.IsMinimapOnly(QuestID, Level);
			if (bOnlyMinimap)
			{
				class'QuestAPI'.static.SetQuestTargetInfo( true, false, false, strTargetName, vTargetPos, QuestID);
				m_IsShowArrow = false;
			}
			else
			{
				class'QuestAPI'.static.SetQuestTargetInfo( true, true, true, strTargetName, vTargetPos, QuestID);
				m_IsShowArrow = true;
			}
		}
		else
		{
			SetQuestOff();
		}
	}	
}*/

/**
 * 텝 이동시 셋팅. 
 */
function setTabChange( int select )
{	

	local array<string>		arrSplit;
	local int				SplitCount;

	local string            expandedNode;

	CurTree.HideWindow();	
	CurTree = GetTreeHandle( m_WindowName$".MainTree" $ string(select) );
	GetTreeHandle( m_WindowName$".MainTree" $ string(select) ).ShowWindow();	
	scTreeDrawer.btnGiveUpCurrentQuest.DisableWindow();

	// ldw 보여 지고 있는 탭의 확장 된 노드의 퀘스트를 활성화 해야 함.
	expandedNode =  GetExpandedNode(); 
	UpdateTargetInfo();
	if (expandedNode == "") 
	{
			if (class'UIAPI_WINDOW'.static.IsShowWindow("QuestTreeDrawerWnd"))
			{
				class'UIAPI_WINDOW'.static.HideWindow( "QuestTreeDrawerWnd" );	
			}
			//ListTrackItem1.SetSelectedIndex(-1, false);//미니맵의 퀘스트 선택 끄기		
	}
	else 
	{
		if ( Left( GetExpandedNode(), 4 ) == ROOTNAME )
		{				
			//setMiniMapDrawerQuest();
			//GetCurrentJournalID(strID);
			//Drawer_btnGiveUpCurrentQuest.EnableWindow();		

			// 클릭 된 퀘스트가 첫번째 노드인 경우 마지막 노드의 퀘스트를 보여 줄 것.
			SplitCount = Split( expandedNode, ".", arrSplit );
			
			if( SplitCount == 2 )
			{
				scTreeDrawer.showQuestDrawer( LastNodeName( int(arrSplit[1]), 1, Class'UIDATA_QUEST'.static.GetQuestIscategory( int( arrSplit[1] ), 1 ) ) );			
			}
			else if( SplitCount == 4 )
			{
				scTreeDrawer.showQuestDrawer( expandedNode );			
			}
			ButtonEnableCheck();
		}
	}


	if( select != 4 )
		class'UIAPI_WINDOW'.static.ShowWindow( m_WindowName$".txtQuestNum" );
	else
		class'UIAPI_WINDOW'.static.HideWindow( m_WindowName$".txtQuestNum" );

}

function OnClickCheckBox( String strID )
{
	switch( strID )
	{
		case "chkNpcPosBox":
			UpdateTargetInfo();
		/*
		if ( chkNpcPosBox.IsChecked() )
		{
			UpdateTargetInfo();
		}
		*/ 
		break;
		 
		case "chkAssignNotifier":
		//퀘스트 알림이 자동 해제가 체크되어 있을 경우
		if( chkAssignNotifier.IsChecked() )		
			SetOptionBool("Game", "autoQuestAlarm",true);
		else 
			SetOptionBool("Game", "autoQuestAlarm",false);

		scQuestAlarm.UpdateOptionData();
		
		break;
	 }
}

function OnbtnDetailInfoClick()
{
	//local QuestTreeDrawerTestWnd Drawer;
	//Drawer =  GetWindowHandle( "QuestTreeDrawerTestWnd" );
	//Drawer.ShowWindow();
	class'UIAPI_WINDOW'.static.ShowWindow( "QuestTreeDrawerWnd" );	
}

function OnEvent(int Event_ID,String param)
{	
	if( Event_ID == EV_QuestListStart )
	{		
		//Debug ("EV_QuestListStart" @ param);		
		HandleQuestListStart();		
		//Me.ShowWindow();
	}
	else if( Event_ID == EV_QuestList )
	{	
		//Debug ("EV_QuestList" @ param);		
		HandleQuestList( param );				
	}
	else if( Event_ID == EV_QuestListEnd )
	{	
		//Debug ("EV_QuestListEnd" @ param);
		
		HandleQuestListEnd(); // 이 이후로 GetExpandedNode 를 쓸 수 있음 활성화 된다.
		
		InsertQuestTrackList();		
		//curTree.SetExpandedNode( "root.10322", true);//확장은 된다. 내용 활성화가 안됨.
		//scTreeDrawer.showQuestDrawer( "root.10322" );

		//.ButtonEnableCheck()

		ButtonEnableCheck();

			
//		Debug( "EV_QuestListEnd3" @ curTree.GetExpandedNode( "root" ) );
	}
	else if( Event_ID == EV_QuestSetCurrentID )
	{
		//Debug("알림 아이콘으로 호출 하여 열 경우 수정전~ param EV_QuestSetCurrentID>>" $ param );
		HandleQuestSetCurrentID( param );
		CurTree.Setfocus();
		Me.SetFocus();
	}
	else if ( Event_ID == EV_DialogOK )
	{
		if (DialogIsMine())
		{
			//Cancel
			if (DialogGetID() == 0 )
			{
				scQuestAlarm.DeleteQuestAlarm( m_DeleteQuestID );	// 알리미에서도 삭제
				
				class'QuestAPI'.static.RequestDestroyQuest(m_DeleteQuestID);
				SetQuestOff();
				
				//노드 삭제
				CurTree.DeleteNode(m_DeleteNodeName);
				
				m_DeleteQuestID = 0;
				m_DeleteNodeName = "";
				class'UIAPI_WINDOW'.static.HideWindow("QuestTreeDrawerWnd");
			}
			//Cannot Cancel
			else
			{
			}
		}
	}
	else if( Event_ID == EV_Restart ){
		SetQuestOff();
//		m_IsShowArrow = false;
	}
}

function curQuestExpand(int QuestID){
	
	m_recentlyQuestID = QuestID;
	//curTree.SetExpandedNode( "root."$QuestID, true);

	//Debug ("curQuestExpand2" @ curTree.GetExpandedNode( "root" ) );
}

/**
 * 퀘스트 리스트 시작.
 */
function HandleQuestListStart()
{
	//초기화
	
	InitTree();	
	initVars();	
}

/**
 * 퀘스트 리스트 내용 저장.
 */
function HandleQuestList( String param )
{
	
	local int i;

	local int QuestID;
	local int Level; 
	local int Completed;
	local int nQuestType;

	//퀘스트 아이템 param
	local string QuestParam;
	//필요 아이템 Max 값
	local int Max;	

	ParseInt( param, "QuestID", QuestID );
	ParseInt( param, "Level", Level );
	ParseInt( param, "Completed", Completed );
	
	nQuestType = Class'UIDATA_QUEST'.static.GetQuestIscategory(QuestID, Level);
	
	
	ArrQuest.insert( ArrQuest.Length, 1 );
	//퀘스트 아이디 저장.
	ArrQuest[ ArrQuest.Length -1 ].QuestID         = QuestID;
	//퀘스트 레벨 저장
	ArrQuest[ ArrQuest.Length -1 ].Level           = Level;
	//퀘스트 완료 저장
	ArrQuest[ ArrQuest.Length -1 ].Completed       = Completed;
	//퀘스트 타입 저장
	ArrQuest[ ArrQuest.Length -1 ].QuestType       = nQuestType;

	if( Completed == 0 )
	{
		QuestParam = class'UIDATA_QUEST'.static.GetQuestItem( QuestID, Level );	

		ParseInt( QuestParam, "Max", Max );	
		ArrQuest[ ArrQuest.Length -1 ].arrNeedItemIDList.Length = Max;	
		ArrQuest[ ArrQuest.Length -1 ].arrNeedItemNumList.Length = Max;
		ArrQuest[ ArrQuest.Length -1 ].arrGoalType.Length = Max;		

		for ( i = 0; i < Max; i++ )
		{
			//퀘스트 필요 아이템 ID
			ParseInt( QuestParam, "GoalID_" $ i, ArrQuest[ ArrQuest.Length -1 ].arrNeedItemIDList[i] );
			//퀘스트 필요 아이템 개수
			ParseInt( QuestParam, "GoalNum_" $ i, ArrQuest[ ArrQuest.Length -1 ].arrNeedItemNumList[i] );
			//퀘스트 골 타입
			ParseInt( QuestParam, "GoalType_" $ i, ArrQuest[ ArrQuest.Length -1 ].arrGoalType[i] );
		}

		//보상 아이템
		class'UIDATA_QUEST'.static.GetQuestReward( QuestID, Level, ArrQuest[ ArrQuest.Length -1 ].rewardIDList, ArrQuest[ ArrQuest.Length -1 ].rewardNumList );
	}

	if (m_OldQuestID != QuestID)
	{
		if ( nQuestType != 4 )
			m_QuestNum++;
	}

	m_OldQuestID = QuestID;	
}

/** 외부에서 현재 받아진 퀘스트 ID를 검색한다 */
function bool isQuestIDSearch( int questID )
{
	local int  i, questLen;
	local bool flag;

	flag = false;
	questLen = ArrQuest.Length;
	
	for(i = 0; i < questLen; i++)
	{   
		// 같다면 true 리턴
		if (questID == ArrQuest[i].QuestID)
		{
			flag = true;
			break;
		}
	}
	
	return flag;
		
}

/**
 * 퀘스트 리스트 끝
 */
function HandleQuestListEnd()
{
	local int       i;
	local int       j;
	local int       nQuestType;	

	//TTP #47783
	//퀘스트가 없을 경우 창닫기.
	//Debug("m_QuestNum>>>" $ string(m_QuestNum) );
	if( m_QuestNum == 0 )
	{
		class'UIAPI_WINDOW'.static.HideWindow("QuestTreeDrawerWnd");
		scTreeDrawer.AllClear();
		//btnDetailInfo.DisableWindow();
	}
	else
	{
		//btnDetailInfo.EnableWindow();
	}
	setTreeQuestList();	//이후 GetExpandedNode가 가능함
	
	//완료 되었을 경우 제거.
	for( i = 0 ; i < ArrQuest.Length ; i ++ )
	{
		for ( j = 0 ; j < 5 ; j ++ )
		{
			//Debug( "ArrQuest[i].QuestID == scQuestAlarm.QuestAlarmNameID[j]" $ string(ArrQuest[i].QuestID) $ "==" $ string(scQuestAlarm.QuestAlarmNameID[j]) );
			//Debug( "ArrQuest[i].Level == scQuestAlarm.QuestAlarmLevel[j]" $ string(ArrQuest[i].Level) $ "==" $ string(scQuestAlarm.QuestAlarmLevel[j]) );
			if( ArrQuest[i].QuestID == scQuestAlarm.QuestAlarmNameID[j] && ArrQuest[i].Level == scQuestAlarm.QuestAlarmLevel[j] )
			{
				if( ArrQuest[i].Completed == 1 )
				{
					//Debug( "ArrQuest[i].QuestID == scQuestAlarm.QuestAlarmNameID[j]" $ string(ArrQuest[i].QuestID) $ "==" $ string(scQuestAlarm.QuestAlarmNameID[j]) );
					//Debug( "ArrQuest[i].Level == scQuestAlarm.QuestAlarmLevel[j]" $ string(ArrQuest[i].Level) $ "==" $ string(scQuestAlarm.QuestAlarmLevel[j]) );
					//Debug( "J는??-->" $ string(j) );
					scQuestAlarm.DeleteQuestAlarm( scQuestAlarm.QuestAlarmNameID[ j ] );
				}
			}
		}
	}
	//완료 및 퀘스트가 제거 되었을 경우 알림 제거.
	for ( j = 0 ; j < 5 ; j ++ )
	{
		if( scQuestAlarm.QuestAlarmNameID[j] != -1 )
		{
			findNowQuestExist( scQuestAlarm.QuestAlarmNameID[j] );
		}
	}
	UpdateQuestCount();	
	/*
	//QuestAlarmNameID[MAX_QUEST]를 가져다 쓸수 없어 25개 돌려야 합니다.
	// 알리미에는 있는데 퀘스트에 없으면 해당 알리미는 삭제하여준다.
	// 하드코딩 죄송합니다. (__)
	for( all = 0; all < 25 ; all++ )	
	{
		tempItemID = scQuestAlarm.QuestItemNameID[all];

		if( tempItemID  == -1 )
			return;		

		for( i = 0 ; i < ArrQuest.Length ; i ++ )
		{
			for( j = 0 ; j < ArrQuest[i].arrNeedItemIDList.Length ; j ++ )
			{
				debug( "HandleQuestListEnd 제거용!!>>>" $ class'UIDATA_ITEM'.static.GetItemName( GetItemID( ArrQuest[i].ArrNeedItemIDList[j] ) ) );
				if( tempItemID == ArrQuest[i].ArrNeedItemIDList[j] )
				{
					isExist = true;	
					break;
				}
			}
		}

		if(isExist == false)
		{
			debug("222222지워 지워?? 지워222" $ string( all / 5 ) );
			scQuestAlarm.DeleteQuestAlarm( scQuestAlarm.QuestAlarmNameID[ all / 5 ] );
		}
	}*/	
	if ( m_recentlyQuestID != 0 )
	{
		nQuestType = Class'UIDATA_QUEST'.static.GetQuestIscategory(m_recentlyQuestID, 1);
		QuestTreeTab.SetTopOrder(nQuestType, false); //텝 바꾸고
		//setTabChange( nQuestType );
		getCurTree( nQuestType );
		CurTree.SetExpandedNode( "root."$m_recentlyQuestID, true);
		scTreeDrawer.showQuestDrawer( "root."$m_recentlyQuestID );
			
		scTreeDrawer.showQuestDrawer( LastNodeName( m_recentlyQuestID, 1, nQuestType ) );			
		//ExpandclildNode( m_recentlyQuestID );//차일드가 있으면 그걸로 익스팬드
		CheckQuestTrackList();                       //미니맵의 체크 상태 바꿈
		//scTreeDrawer.showQuestDrawer( arrSplit[SplitCount-1] );
	}
	Detele3DArrow(); // 퀘스트 시 3d화살표와 미니맵의 화살표를 삭제 한다.
	//UpdateTargetInfo(); // 퀘스트를 받거나 퀘스트 완료 시 3d화살표가 보여지거나 없어짐, 퀘스트창을 열어 두건 닫아 두건 상관 없음
}

/*function gedExpandclildNode(int QuestID)
{
	local string            strChildList;	
	local array<string>		arrSplit;
	local int				SplitCount;
	
	strChildList = CurTree.GetChildNode("root."$QuestID);
	if (Len(strChildList)>0)
	{
		SplitCount = Split(strChildList, "|", arrSplit);
		strTargetNode = arrSplit[SplitCount-1];
	}
	// 3. 이름을 분석해서, QuestID와 Level을 취득
	arrSplit.Remove(0,arrSplit.Length);
	SplitCount = Split( strTargetNode, ".", arrSplit );
	QuestID = int( arrSplit[1] );
}*/

function Detele3DArrow()
{
//	local int i;
	//local bool b3Darrow;
	local int QuestID;
	//local int n3DLevel;

	//local string strTargetName;
	local vector vTargetPos;

	//b3Darrow = false;
	QuestID = getCurQuestID(); //펼쳐진 퀘스트 ID 가 없을 경우 퀘스트 관련 아이콘, 3D 화살표 삭제
	//Debug("getCurQuestID()" @ getCurQuestID());
	//완료 되었을 경우 제거.
	/*for( i = 0 ; i < ArrQuest.Length ; i ++ )
	{
		if( n3DQuest == ArrQuest[i].QuestID )
		{
			b3Darrow = true;
			n3DLevel = ArrQuest[i].Level;
		}		
	}*/
	
	
	//UpdateTargetInfo();
	if (QuestID == 0) // 펼처진 퀘스트가 없으면 삭제 
	//if( !b3Darrow )
	{
		//n3DLevel = ArrQuest[i].Level;
		//strTargetName = class'UIDATA_QUEST'.static.GetTargetName(n3DQuest, n3DLevel);
		//vTargetPos = class'UIDATA_QUEST'.static.GetTargetLoc(n3DQuest, n3DLevel);
		//class'QuestAPI'.static.SetQuestTargetInfo( false, false, false, strTargetName, vTargetPos, n3DQuest, n3DLevel);	
		class'QuestAPI'.static.SetQuestTargetInfo( false, false, false, "", vTargetPos, QuestID, 0);	
		DisableAllDirIcon();
		class'UIAPI_WINDOW'.static.HideWindow( "QuestTreeDrawerWnd" );	
		//scTreeDrawer.HideWindow();
		CallGFxFunction("RadarMapWnd", "hideQuestTargetInfo" , "" ) ;
	} 
	else 
	{
		
	}
}


/**
 * 퀘스트가 없다면 알림을 없애준다.
 */
function findNowQuestExist( int QuestID )
{
	local int i;
	local bool isExist;

	for( i = 0 ; i < ArrQuest.Length ; i ++ )
	{
		if( ArrQuest[i].QuestID == QuestID )
		{
			isExist = true;	
			break;
		}
	}

	if( !isExist )
	{
		scQuestAlarm.DeleteQuestAlarm( QuestID );

		// 개발망만 작동 하도록..
		if(GetReleaseMode() == RM_DEV) 
		{
			// 개발망에서 reloadfs 후 자꾸 다운 되는 문제가 있어서 개발망에서만 사용 안함.
			// empty
		}
		else
		{
			if(class'UIAPI_WINDOW'.static.IsShowWindow("NoticeWnd"))
			{
				// 퀘스트가 끝났을때 필요 없는 퀘스트 알림을 삭제해준다.
				noticeWndScript.hideNoticeButton_QUEST();
			}
		}
	}
}

//트리 초기화.
function initTree()
{
	MainTree0.Clear();
	MainTree1.Clear();
	MainTree2.Clear();
	MainTree3.Clear();
	MainTree4.Clear();
}

//변수 초기화
function initVars()
{
	m_QuestNum = 0;
	m_OldQuestID = 0;
	m_TrackID = 0;

	m_DeleteQuestID = 0;
	m_DeleteNodeName = "";

	ArrQuest.Remove(0, ArrQuest.Length);
}


function setTreeQuestList()
{
	local int i;
	//추가 할 Tree 이름
	local string TreeName;
	//퀘스트 제목
	local string QuestName;
	//퀘스트 소 제목
	local string JournalName;	
	//
	local string setTreeName;

	local string strRetName;
	
	local LVDataRecord Record;
	local LVData data1;
	local LVData data2;	
	
	for( i = 0 ; i < ArrQuest.Length ; i ++ )
	{		
		TreeName = m_WindowName$".MainTree" $ ArrQuest[i].QuestType;
		setTreeName = ROOTNAME$"."$string( ArrQuest[i].QuestID );			
		JournalName = class'UIDATA_QUEST'.static.GetQuestJournalName( ArrQuest[i].QuestID, ArrQuest[i].Level );
		//branch 110720_0804
		JournalName = class'UIDATA_QUEST'.static.GetQuestJournalNameSplit( JournalName, ArrQuest[i].Completed );
		//end of branch
		//Debug("JournalName" @ JournalName);
		// 만약 퀘스트 노드가 존재 한다면 
		
		if (class'UIAPI_TREECTRL'.static.IsNodeNameExist( TreeName, setTreeName))
		{			
			//제목을 바꿀 것
			QuestName = class'UIDATA_QUEST'.static.GetQuestName( ArrQuest[i].QuestID, ArrQuest[i].Level);
			class'UIAPI_TREECTRL'.static.SetNodeItemText ( TreeName, setTreeName, 0, QuestName) ;
			//Debug ( TreeName @ setTreeName @ ROOTNAME @ QuestName @ i ) ;

		}
		//if( ArrQuest[i].Level == 1 )
		else 
		{				
			QuestName = class'UIDATA_QUEST'.static.GetQuestName( ArrQuest[i].QuestID, ArrQuest[i].Level);			
			
			//Root 노드 생성.
			
			util.TreeInsertRootNode( TreeName, ROOTNAME, "", 0, 4 );
			//+버튼 있는 상위 노드 생성
			//붙은 후 확장 됨 혹은 확장 된 상태로 붙음
			
			//Debug(TreeName @ string( ArrQuest[i].QuestID ) @  ROOTNAME);
			//Debug( "확장0" @ curTree.GetExpandedNode( "root" ) );
			util.TreeInsertExpandBtnNode( TreeName, string( ArrQuest[i].QuestID ), ROOTNAME );	/********/ //여기서 확장된다기 보단.. 확장 된 값을 받음.					
			//Debug(TreeName @ string( ArrQuest[i].QuestID ) @  ROOTNAME);
			//Debug( "확장1" @ curTree.GetExpandedNode( "root" ) );
			//위의 노드에 글씨 아이템 추가
			util.TreeInsertTextNodeItem( TreeName, ROOTNAME$"."$string( ArrQuest[i].QuestID ), QuestName, 5, 0, util.ETreeItemTextType.COLOR_DEFAULT, true );			
			//setTreeQuestList( ArrQuest[i].QuestID, ArrQuest[i].Level, ArrQuest[i].QuestType );
			data1.nReserved1 = ArrQuest[i].QuestID;
			data2.nReserved2 = ArrQuest[i].Level;
			data1.nReserved3 = ArrQuest[i].QuestType;
			data1.szData = QuestName;
			Record.LVDataList[0] = data1;
			Record.LVDataList[1] = data2;
			m_QuestTrackData[m_TrackID] = Record;
			m_TrackID = m_TrackID + 1;
		}		
	
		
		//퀘스트 소제목 Node생성
		strRetName = QuestJournalNodeMake( TREENAME, setTreeName, ArrQuest[i].Level, ArrQuest[i].Completed );		

		if( bDrawBgTree )
		{
			//Insert Node Item - 배경 색상 배뀜
			util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_CH3.etc.textbackline", 209, 24, 4,,,,14 );
		}
		else
		{
			util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_CT1.EmptyBtn", 209, 24, 4 );
		}
		bDrawBgTree = !bDrawBgTree;		
		
		//Insert Node Item - 아이템 이름
		//util.TreeInsertTextNodeItem( TREENAME, strRetName, JournalName, -202, 7, util.ETreeItemTextType.COLOR_GRAY, true );				
		//(완료) 표시
		//branch 110720_0804
		if( ArrQuest[i].Completed == 1 )
		{
			util.TreeInsertTextNodeItem( TREENAME, strRetName, "("$GetSystemString(898)$")", -202, 7, util.ETreeItemTextType.COLOR_GOLD, true );		
			util.TreeInsertTextNodeItem( TREENAME, strRetName, JournalName, 4, 7, util.ETreeItemTextType.COLOR_GRAY, true );				
		}
		else
		{
			util.TreeInsertTextNodeItem( TREENAME, strRetName, JournalName, -202, 7, util.ETreeItemTextType.COLOR_GRAY, true );				
		}
		//end of branch
			
	}
}

function setMiniMapTrackInsert( int QuestID, int Level, int nQuestType )
{

}

/**
 * 제목 하위 소제목 node 만듦
 */
function string QuestJournalNodeMake( string TreeName, string ParentName, int Level, int Completed )
{
	//트리 노드의 구조 자체를 정의
	local XMLTreeNodeInfo		infNode;					

	infNode.strName = "" $ Level $ "." $ Completed;
	infNode.nOffSetX = 14;
	infNode.bShowButton = 0;
	infNode.bDrawBackground = 1;

	infNode.bTexBackHighlight = 0;
	infNode.nTexBackHighlightHeight = 15;
	infNode.nTexBackWidth = 211; 
	infNode.nTexBackUWidth = 211;
	infNode.nTexBackOffSetX = 3;
	infNode.nTexBackOffSetY = 0;
	infNode.nTexBackOffSetBottom = 1;

	return class'UIAPI_TREECTRL'.static.InsertNode( TreeName, ParentName, infNode );
}

function DirIconDest(EMinimapTargetIcon Type , vector vTargetPos, string toolTipString)
{
	local vector emptyLoc;

	local MinimapCtrlHandle m_MiniMap;
	//local MinimapCtrlHandle m_MiniMap_Expand;
	m_MiniMap = GetMinimapCtrlHandle( "MinimapWnd.Minimap" );	
	//m_MiniMap_Expand = GetMinimapCtrlHandle( "MinimapWnd_Expand.Minimap" );	
	
	//조건 타운맵이 아니며 대륙이 같아야 하며, 위치 값이 있어야 한다.
	if ((vTargetPos.x != 0 && vTargetPos.y != 0 && vTargetPos.z != 0))
	{		
		//if(MinimapWnd(GetScript("MinimapWnd")).isSameContinent())
		//{
		//	// Debug("SetDirIconDest실행");
		//	m_MiniMap.SetDirIconDest( Type ,  vTargetPos , toolTipString );		
		//}
		m_MiniMap.SetDirIconDest( Type ,  vTargetPos , toolTipString );		
		currentQuestDirectTargetPos = vTargetPos;
		currentQuestDirectTargetString = toolTipString;

		//Debug("---퀘스트 화살표 보정x" @ vTargetPos.x);
		//Debug("---퀘스트 화살표 보정y" @ vTargetPos.y);
		//Debug("---퀘스트 화살표 보정z" @ vTargetPos.z);

		//m_MiniMap_Expand.SetDirIconDest( Type ,  vTargetPos , toolTipString );		
	} else 
	{
		m_MiniMap.DisableDirIcon( Type );	
		currentQuestDirectTargetPos = emptyLoc;
		currentQuestDirectTargetString = "";

		//m_MiniMap_Expand.DisableDirIcon( Type );	
	}
}

function updateDirIconDest()
{
	if (currentQuestDirectTargetString != "")
	DirIconDest(EMinimapTargetIcon.TARGET_QUEST , currentQuestDirectTargetPos, currentQuestDirectTargetString);
}


function vector getCurrentQuestDirectTargetPos()
{
	return currentQuestDirectTargetPos;
}

function string getCurrentQuestDirectTargetString()
{
	return currentQuestDirectTargetString;
}

//function int GetContinent(vector loc)
//{
//	if (loc.X < -163840)
//	{
//		return 1;		//Gracia
//	}
//	else
//	{
//		return 0;		//Aden
//	}
//}

function string DirIconDestGetToolTip (int QuestID, int QuestLevel) 
{
	local string strToolTip;
	local String strQuestName ;
	local string strTargetName;
	strQuestName = class'UIDATA_QUEST'.static.GetQuestName(QUESTID, QuestLevel);
	strTargetName = class'UIDATA_QUEST'.static.GetTargetName(QuestID, QuestLevel);
	strToolTip = strTargetName$"\\n"$strQuestName;
	return strToolTip;
}

function UpdateTargetNoneCheckPosBox(bool showArrow){
	local array<string>		arrSplit;
	local int				SplitCount;
	
	local int QuestID;
	local int Level;
	local int Completed;
	
	local string strChildList;
	local string strTargetNode;
	
	local string strNodeName;
	local string strTargetName;
	local vector vTargetPos;
	local bool bOnlyMinimap;

	local string strParam;

	strNodeName = GetExpandedNode();	

	if ( Len(strNodeName) < 1 )
	{
		SetQuestOff();
		return;
	}

	///////////////////////////////////////////////////////////////////////
	//Expanded된 노드가 가리키는 퀘스트의 Target표시용 저널을 찾아야함
	///////////////////////////////////////////////////////////////////////
	
	// 1. Child노드를 구한다.
	strChildList = CurTree.GetChildNode(strNodeName);
	
	// 2. Child가 있으면, Child중에서 가장 마지막 Child가 Target표시용 저널
	if (Len(strChildList)>0)
	{
		SplitCount = Split(strChildList, "|", arrSplit);
		strTargetNode = arrSplit[SplitCount-1];
	}
	else
	{
		SetQuestOff();
		return;
	}
	// 3. 이름을 분석해서, QuestID와 Level을 취득
	arrSplit.Remove(0,arrSplit.Length);
	SplitCount = Split( strTargetNode, ".", arrSplit );
	QuestID = int( arrSplit[1] );

	if( SplitCount == 2 )
	{
		Level = 1;
		Completed = 0;
	}
	else if( SplitCount == 4 )
	{
		Level = int( arrSplit[2] );
		Completed = int( arrSplit[3] );
	}

	if ( QuestID > 0 && Level > 0 )
	{
		//Target이름 취득
		strTargetName = class'UIDATA_QUEST'.static.GetTargetName(QuestID, Level);
		vTargetPos = class'UIDATA_QUEST'.static.GetTargetLoc(QuestID, Level);

		ParamAdd(strParam, "X", string ( vTargetPos.x ));
		ParamAdd(strParam, "Y", string ( vTargetPos.y ));
		ParamAdd(strParam, "Z", string ( vTargetPos.z ));
		ParamAdd(strParam, "targetName", strTargetName);

		ParamAdd(strParam, "QuestID",  string (QuestID));
		ParamAdd(strParam, "QuestLevel",  string (Level));

		ParamAdd(strParam, "questName", class'UIDATA_QUEST'.static.GetQuestName( QuestID, Level ));
		CallGFxFunction("RadarMapWnd", "showQuestTargetInfo" , strParam ) ;

		if (Completed==0 && Len(strTargetName)>0)
		{
			bOnlyMinimap = class'UIDATA_QUEST'.static.IsMinimapOnly(QuestID, Level);				
			

			if (bOnlyMinimap)
			{				
				class'QuestAPI'.static.SetQuestTargetInfo( true, false, false, strTargetName, vTargetPos, QuestID, Level);	
//				m_IsShowArrow = false;
			}
			else
			{
				class'QuestAPI'.static.SetQuestTargetInfo( true, true, showArrow, strTargetName, vTargetPos, QuestID, Level);
//				m_IsShowArrow = true;
			}
			
			//Debug("DirIconDest"@vTargetPos @ DirIconDestGetToolTip( QuestID, Level) );

			DirIconDest(EMinimapTargetIcon.TARGET_QUEST , vTargetPos, DirIconDestGetToolTip( QuestID, Level)  );
			
		}
		else
		{
			//m_MiniMap.DisableDirIcon( EMinimapTargetIcon.TARGET_QUEST );
			SetQuestOff();
		}
	}	
}

//퀘스트 목적지 표시 관련
function UpdateTargetInfo()
{

	//위치표시 체크박스
	if ( !chkNpcPosBox.IsChecked() )
	{
		 SetQuestOff();
		 return;
	}

	UpdateTargetNoneCheckPosBox(true);
}

/*20110419 ldw gd1.0 개선 사항 및 이후 위치표시와 관련된 개선을 위한 함수 : 
*1 .위치표시와 상관 없는 퀘스트 위치 표시
*2. 퀘스트에서 3D 화살표가 켜져 있을 경우 화살표 도 같이 표시 -> 이 부분은 관련 없음
*/
/*
function UpdateTargetInfoNoneChkNPCPosBox()
{
	local array<string>		arrSplit;
	local int				SplitCount;
	
	local int QuestID;
	local int Level;
	local int Completed;
	
	local string strChildList;
	local string strTargetNode;
	
	local string strNodeName;
	local string strTargetName;
	local vector vTargetPos;
	local bool bOnlyMinimap;
	
	strNodeName = GetExpandedNode();

	if (Len(strNodeName)<1)
	{
		SetQuestOff();
		return;
	}

	///////////////////////////////////////////////////////////////////////
	//Expanded된 노드가 가리키는 퀘스트의 Target표시용 저널을 찾아야함
	///////////////////////////////////////////////////////////////////////
	
	// 1. Child노드를 구한다.
	strChildList = CurTree.GetChildNode(strNodeName);
	
	// 2. Child가 있으면, Child중에서 가장 마지막 Child가 Target표시용 저널
	if (Len(strChildList)>0)
	{
		SplitCount = Split(strChildList, "|", arrSplit);
		strTargetNode = arrSplit[SplitCount-1];
	}
	else
	{
		SetQuestOff();
		return;
	}
	// 3. 이름을 분석해서, QuestID와 Level을 취득
	arrSplit.Remove(0,arrSplit.Length);
	SplitCount = Split( strTargetNode, ".", arrSplit );
	QuestID = int( arrSplit[1] );

	if( SplitCount == 2 )
	{
		Level = 1;
		Completed = 0;
	}
	else if( SplitCount == 4 )
	{
		Level = int( arrSplit[2] );
		Completed = int( arrSplit[3] );
	}

	if ( QuestID > 0 && Level > 0 )
	{
		//Target이름 취득
		strTargetName = class'UIDATA_QUEST'.static.GetTargetName(QuestID, Level);
		vTargetPos = class'UIDATA_QUEST'.static.GetTargetLoc(QuestID, Level);
		
		if (Completed==0 && Len(strTargetName)>0)
		{
			bOnlyMinimap = class'UIDATA_QUEST'.static.IsMinimapOnly(QuestID, Level);
			if (bOnlyMinimap)
				class'QuestAPI'.static.SetQuestTargetInfo( true, false, false, strTargetName, vTargetPos, QuestID, Level);
			else				
				class'QuestAPI'.static.SetQuestTargetInfo( true, true, true, strTargetName, vTargetPos, QuestID, Level);//m_IsShowArrow, strTargetName, vTargetPos, QuestID);
		}
		else
		{
			SetQuestOff();
		}
	}	
}
*/

function DisableAllDirIcon () 
{
	local vector emptyLoc;
	local MinimapCtrlHandle m_MiniMap;	
	//local MinimapCtrlHandle m_MiniMap_Expand;	
	m_MiniMap = GetMinimapCtrlHandle( "MinimapWnd.Minimap" );
	//m_MiniMap_Expand = GetMinimapCtrlHandle( "MinimapWnd_Expand.Minimap" );

	m_MiniMap.DisableDirIcon(EMinimapTargetIcon.TARGET_QUEST);//EMinimapTargetIcon(DirIconDestType));	

	currentQuestDirectTargetPos = emptyLoc;
	currentQuestDirectTargetString = "";

	//m_MiniMap_Expand.DisableDirIcon(EMinimapTargetIcon.TARGET_QUEST);//EMinimapTargetIcon(DirIconDestType));	
}

function SetQuestOff()
{
	local vector vVector, emptyLoc;

	class'QuestAPI'.static.SetQuestTargetInfo( false, false, false, "", vVector, 0, 0);

	CallGFxFunction("RadarMapWnd", "hideQuestTargetInfo" , "" ) ;

//	Debug ( "SetQuestOff");

	DisableAllDirIcon () ;
//	m_IsShowArrow = false;
		
	QuestID_Alarm = -1;
	QuestLevel_Alarm = -1;
	QuestEnd_Alarm = -1;
	m_recentlyQuestID = 0;

	currentQuestDirectTargetPos = emptyLoc;
	currentQuestDirectTargetString = "";
}


function string GetExpandedNode()
{
	local array<string>	arrSplit;
	local int		SplitCount;
	local string	strNodeName;	

	strNodeName = CurTree.GetExpandedNode("root");
	//Debug ("GetExpandedNode" @  strNodeName) ;
	SplitCount = Split(strNodeName, "|", arrSplit);
	if (SplitCount>0)
	{
		strNodeName = arrSplit[0];
	}	
	return strNodeName;
}

//expanded 된 노드를 기준으로 버튼을 활성화 할 지 말지를 처리한다. 
function ButtonEnableCheck()
{	
	local int   i, m;	
	local int   QuestIDSlot;
	local bool  isCanBeAddAlarm, questAutoAlarm;

	questAutoAlarm = GetOptionBool("Game", "autoQuestAlarm");

	GetNodeInfo_Alarm();	
	// 퀘스트가 알림이를 표시할 수 있는지 검사한다.
	
	isCanBeAddAlarm = false;	

	// 알림이 필요한지 않한지 확인.
	// 빠져 있다..npc goal 타입 체크 하는 걸..
	for ( i = 0 ; i < ArrQuest.Length ; i++ )
	{
		if( ArrQuest[ i ].QuestID == QuestID_Alarm )
		{
			//ArrQuest[ i ].ArrGoalType[]
			if( ArrQuest[ i ].arrNeedItemIDList.Length > 0 )
			{
				isCanBeAddAlarm = true;
				break;
			}

			// goal 타입 체크
			for ( m = 0; m < ArrQuest[i].ArrGoalType.Length; m++ )
			{
				if(ArrQuest[i].ArrGoalType[m] == 1)
				{
					isCanBeAddAlarm = true;
					break;
				}
			}
		}
	}
	
	QuestIDSlot = scQuestAlarm.QuestSlotIdx( QuestID_Alarm );

	if( QuestID_Alarm <= 0 )
	{	
		m_btnAddAlarm.DisableWindow();
		m_btnDeleteAlarm.DisableWindow();
	}
	else
	{
		// 등록되지 않은 퀘스트중 아이템 표시 가능할 경우  : 등록 버튼 enable, 등록 해제 버튼 disable
		if( QuestIDSlot < 0 )
		{			
			if(isCanBeAddAlarm == true)	
			{	
				m_btnAddAlarm.EnableWindow();	
				m_btnDeleteAlarm.DisableWindow();
			}
			else					
			{	
				m_btnAddAlarm.DisableWindow();	
				m_btnDeleteAlarm.DisableWindow();
			}			
		}
		else	// 이미 등록된 퀘스트를 검색. 등록버튼 disable, 등록 해제 버튼 enable
		{
			m_btnAddAlarm.DisableWindow();
			m_btnDeleteAlarm.EnableWindow();
		}
	}
}

// EXPand 노드에서 QuestID, QuestLevel, 완료 여부를 전역변수에 저장한다.
function GetNodeInfo_Alarm()
{	
	local string strNodeName;
	local string strTargetNode;
	
	local int		i;
	local array<string>	arrSplit;
	local int		SplitCount;
	
	local string strChildList;	
	

	strNodeName = GetExpandedNode();
	
	// 1. Child노드를 구한다.
	strChildList = CurTree.GetChildNode(strNodeName);
	
	// 2. Child가 있으면, Child중에서 가장 마지막 Child가 Target표시용 저널
	if (Len(strChildList)>0)
	{
		SplitCount = Split(strChildList, "|", arrSplit);
		strTargetNode = arrSplit[SplitCount-1];
	}
	else
	{
		SetQuestOff();
		return;
	}
	// 3. 이름을 분석해서, QuestID와 Level을 취득
	arrSplit.Remove( 0 , arrSplit.Length );
	SplitCount = Split(strTargetNode, ".", arrSplit);

	for (i=0; i < SplitCount; i++)
	{
		switch(i)
		{
			//"root"
			case 0:
				break;
			//"QuestID"
			case 1:
				QuestID_Alarm = int(arrSplit[i]);
				break;
			//"QuestLevel"
			case 2:
				QuestLevel_Alarm = int(arrSplit[i]);
				break;
			//"IsCompleted"
			case 2:
				QuestEnd_Alarm = int(arrSplit[i]);
				break;
		}
	}	
}


// 퀘스트 알리미에서 해제
function HandleDeleteAlarm()
{
	local int		i;
		
	GetNodeInfo_Alarm();
	
	// 퀘스트 아이디로 등록할 퀘스트 아이템을 등록한다. 
	//알림이 필요한지 않한지 확인.
	for ( i = 0 ; i < ArrQuest.Length ; i++ )
	{
		if( ArrQuest[ i ].QuestID == QuestID_Alarm )
		{
			scQuestAlarm.DeleteQuestAlarm( QuestID_Alarm );
		}
	}	
	ButtonEnableCheck();
}

//현재 퀘스트 갯수 갱신
function UpdateQuestCount()
{
	txtQuestNum.SetText("(" $ m_QuestNum $ "/" $ QUESTTREEWND_MAX_COUNT $ ")");
}
function getCurTree(int nQuestType)
{	
	switch(	nQuestType )
	{
		case 0 : CurTree = MainTree0; break;
		case 1 : CurTree = MainTree1; break;
		case 2 : CurTree = MainTree2; break;
		case 3 : CurTree = MainTree3; break;
		case 4 : CurTree = MainTree4; break;
		default : CurTree = MainTree0;
	}
}

//알림 아이콘에서 눌렀을 경우.
function HandleQuestSetCurrentID(string param)
{
	local string strNodeName;
	local string strChildList;
	local int RecentlyAddedQuestID;
	local int SplitCount;
	local int nQuestType;
	local array<string>	arrSplit;
	
	if (!ParseInt(param, "QuestID", RecentlyAddedQuestID))
		return;

	if (RecentlyAddedQuestID>0)
	{	
		nQuestType = Class'UIDATA_QUEST'.static.GetQuestIscategory(RecentlyAddedQuestID, 1);
		getCurTree ( nQuestType ) ;
		/*
		switch(	nQuestType )
		{
			case 0 : CurTree = MainTree0; break;
			case 1 : CurTree = MainTree1; break;
			case 2 : CurTree = MainTree2; break;
			case 3 : CurTree = MainTree3; break;
			case 4 : CurTree = MainTree4; break;
			default : CurTree = MainTree0;
		}*/

		QuestTreeTab.SetTopOrder(nQuestType, false);//on show 에서 처리 하기 때문에 보여 지는 부분을 뒤로 옮겨야 함.
		// 1. QuestNode Expand
		strNodeName = "root." $ RecentlyAddedQuestID;
		// debug("strNodeName::" @ strNodeName);
		CurTree.SetExpandedNode(strNodeName, true);

		if(!Me.isShowWindow())	//이펙트 버튼을 누르면 창이 열리도록 한다.  (물론 창이 안떠있을 경우)
		{
			Me.ShowWindow();			
			PlayConsoleSound(IFST_WINDOW_OPEN);	// 사운드도 추가
		} 
			
		// 2. JournalNode Expand
		strChildList = CurTree.GetChildNode(strNodeName);		
		// debug("노드 수 : " @ Len(strChildList));

		// Child중에서 가장 마지막 Child가 Expand할 저널
		if (Len(strChildList)>0)
		{
			SplitCount = Split(strChildList, "|", arrSplit);
			CurTree.SetExpandedNode(arrSplit[SplitCount-1], true);
		}

		// 2009 9.21 추가 , 퀘스트 알람 버튼을 클릭하면 자동으로 퀘스트 내용 나오도록 수정
		if (Left(strNodeName, 4) == "root")
		{				
			scTreeDrawer.showQuestDrawer( arrSplit[SplitCount-1] );
			//setMiniMapDrawerQuest(); //미니맵의 퀘스트에도 체크
		}
		
		//Target정보 갱신
		UpdateTargetInfo();
	}
}

//미니멥 추적 도구에서 퀘스트 클릭 한 경우.
function HandleQuestSetCurrentIDfromMiniMap(int QuestID, int Level, int nQuestType)
{
	local string strNodeName;
	local string strChildList;
	local int RecentlyAddedQuestID;
	local int SplitCount;
	local array<string>	arrSplit;
	//local  TreeHandle tempCurTree; //왜 백업 했었을까?

	//tempCurTree = CurTree; //백업

	RecentlyAddedQuestID = QuestID;

	//Debug ("CurTree" @ CurTree);

	getCurTree( nQuestType );
	/*
	switch (nQuestType)
	{
		case 0:
			CurTree = MainTree0;
			break;
		case 1:
			CurTree = MainTree1;
			break;
		case 2:
			CurTree = MainTree2;
			break;
		case 3:
			CurTree = MainTree3;
			break;
		case 4:
			CurTree = MainTree4;
			break;
	}*/
	
	QuestTreeTab.SetTopOrder(nQuestType, false);
	//Debug ("RecentlyAddedQuestID" @ RecentlyAddedQuestID @ "nQuestType" @ nQuestType);
	if (RecentlyAddedQuestID>0)
	{
		// 1. QuestNode Expand
		strNodeName = "root." $ RecentlyAddedQuestID;
		//Debug("RecentlyAddedQuestID" @ RecentlyAddedQuestID);
		CurTree.SetExpandedNode(strNodeName, true);

		//Debug ("RecentlyAddedQuestID>0" @ strNodeName);
			
		
		// 2. JournalNode Expand
		strChildList = CurTree.GetChildNode(strNodeName);
		
		// Child중에서 가장 마지막 Child가 Expand할 저널
		if ( Len( strChildList ) >0 )
		{
			SplitCount = Split( strChildList, "|", arrSplit );
			CurTree.SetExpandedNode( arrSplit[SplitCount-1], true );
			//Debug ("Len( strChildList ) >0 " @ arrSplit[SplitCount-1]);
		}
		
		//Target정보 갱신
		//UpdateTargetInfo();	//20110419 LDW GD1.0개선 사항 위치표시 박스 chkNPC....의 체크와 관련 없이 처리 되도록 개선 .  -> 롤백
		UpdateTargetNoneCheckPosBox( true );//20110516 LDW GD1.0

		if (Left(strNodeName, 4) == "root")
		{
		//	Debug(strNodeName @  arrSplit[SplitCount-1]);
			scTreeDrawer.showQuestDrawer( arrSplit[SplitCount-1] );
		}
	}
	//CurTree = tempCurTree; //restore 핸들		
//	Debug("GetExpandedNode ="@GetExpandedNode());
}

/**
 * 미니멥 추적 도구에 추가.
 */
function CheckQuestTrackList() // 퀘스트를 체크 시킴
{
	local int i;	
	local int QuestID;
	
	QuestID = getCurQuestID();
	for (i= 0; i <m_TrackID; i++)
	{	
		if (m_QuestTrackData[i].LVDataList[0].nReserved1 == QuestID ) 
		{			
			//ListTrackItem1.SetSelectedIndex(i, true);
			return;
		}
	}
}

function InsertQuestTrackList() //퀘스트를 인서트만 함
{
	local int i;	
	local int QuestID;
	
	QuestID = getCurQuestID();	
	//ListTrackItem1.DeleteAllItem();	
	for (i= 0; i <m_TrackID; i++)
	{
		//ListTrackItem1.InsertRecord( m_QuestTrackData[i] );
		if (m_QuestTrackData[i].LVDataList[0].nReserved1 == QuestID ) 
		{			
			//ListTrackItem1.SetSelectedIndex(i, true);
		}
	}
}

function int getCurQuestID()
{
	local int       QuestID;
	local string	strNodeName;
	local int       SplitCount;
	local array<string>	arrSplit;
	
	strNodeName = GetExpandedNode();

//	debug("strNodeName" @ strNodeName);

	SplitCount = Split(strNodeName, ".", arrSplit);
	if (SplitCount>1)
	{
		QuestID = int(arrSplit[1]);
	} else 		
		QuestID =  0 ;

	return QuestID ; 
}

//function setMiniMapDrawerQuest() //  저널의 선택 된 퀘스트와 지도의 위치표시를 동기화 하는 함수 
//{
//	local int       QuestID;
//	local int       i;
//	//local LVDataRecord Record;

//	QuestID = getCurQuestID();	
//	for (i= 0; i <m_TrackID; i++)
//	{	
//		//ListTrackItem1.GetRec(i, Record);
//		if (m_QuestTrackData[i].LVDataList[0].nReserved1 == QuestID ) // Record.LVDataList[0].nReserved1 )
//		{
//			//Debug("QUDSTID" @ m_QuestTrackData[i].LVDataList[0].nReserved1@Record.LVDataList[0].nReserved1);
//			//ListTrackItem1.SetSelectedIndex(i, true);
//			return;
//		}
//	}
//}


//퀘스트 중단
function HandleQuestCancel()
{
	local array<string>	arrSplit;
	local int		SplitCount;
	
	local string	strNodeName;
	
	local string	strDeleteQuestName;	
	local string	strDeleteQuestMessage;	

	m_DeleteQuestID = 0;
	m_DeleteNodeName = "";
	
	//Expanded된 노드를 구한다.
	strNodeName = GetExpandedNode();
	SplitCount = Split(strNodeName, "|", arrSplit);
	if (SplitCount>0)
	{
		strNodeName = arrSplit[0];
		
		arrSplit.Remove(0,arrSplit.Length);
		SplitCount = Split(strNodeName, ".", arrSplit);
		if (SplitCount>1)
		{
			m_DeleteQuestID = int(arrSplit[1]);
			m_DeleteNodeName = strNodeName;
		}
	}
	if (Len(m_DeleteNodeName)<1)
	{
		//Set Delete Quest Message
		strDeleteQuestMessage = GetSystemMessage(1201);
		
		DialogShow(DialogModalType_Modalless,DialogType_Notice, strDeleteQuestMessage, string(Self));
		DialogSetID(1);
	}
	else
	{
		/*
		strChildList = CurTree.GetChildNode(strNodeName);
		// Child중에서 가장 마지막 Child가 Expand할 저널
		if (Len(strChildList)>0)
		{
			SplitCount = Split(strChildList, "|", arrSplit);
			//strNodeName = arrSplit [SplitCount-1];
			//Debug ( "SetExpandedNode1" @ SplitCount @ arrSplit[ arrSplit.Length - 1]) ;
		}
		if (SplitCount > 0)
		{			
			SplitCount = Split( arrSplit[ arrSplit.Length - 1], ".", arrSplit2);			
			//Debug( "SetExpandedNode2" @ arrSplit[ arrSplit.Length - 1] @ SplitCount @ arrSplit2 [ 2 ] @ arrSplit2[ SplitCount -1 ] );
		}
		//Get Delete Quest Name		
		if( SplitCount == 2 )
		{
			Level = 1;			
		}
		else if( SplitCount == 4 )
		{
			Level = int( arrSplit2[2] );
		}

		*/
		//Debug ( "arrSplit[0]" @ SplitCount @"/"@ strNodeName @ "/"@ arrSplit[ 2 ] @ "/"@ m_DeleteQuestID @ "/"@ Level );
		strDeleteQuestName = class'UIDATA_QUEST'.static.GetQuestName(m_DeleteQuestID, util.getQuestLevelForID( m_DeleteQuestID ));
		
		//Set Delete Quest Message
		strDeleteQuestMessage = MakeFullSystemMsg( GetSystemMessage(182), strDeleteQuestName, "");
		
//		Debug( "strDeleteQuestMessage>>>>>>>>>>>" $ strDeleteQuestMessage );


		DialogShow(DialogModalType_Modalless,DialogType_Warning, strDeleteQuestMessage, string(Self) );
		DialogSetID(0);
	}
}





/*
//일단 GMQuestWnd용으로 나뚬.
//퀘스트 아이템 갯수 갱신(ClassID=0이면 전체 아이템을 갱신)
function UpdateItemCount( int ClassID, optional INT64 a_ItemCount )
{

	local int i;
	local int nPos;
	local INT64 ItemCount;
	local string strTmp;
	
	for (i=0; i<m_arrItemID.Length; i++)
	{	
		if (ClassID==0 || ClassID==m_arrItemID[i])
		{
			ItemCount = a_ItemCount;
			if( a_ItemCount == -1 )
			{
				ItemCount = 0;
			}
			else if( a_ItemCount == 0 )
			{
				ItemCount = GetInventoryItemCount(GetItemID(m_arrItemID[i]));
			}
			nPos = InStr(m_arrItemString[i], "%s");
			if (nPos>-1)
			{
				strTmp = Left(m_arrItemString[i], nPos) $ string(ItemCount) $ Mid(m_arrItemString[i], nPos+2);
				CurTree.SetNodeItemText(m_arrItemNodeName[i], m_arrItemID.Length-i, strTmp);
					
				if(ItemCount < 0)	ItemCount = ItemCount * -1;	// 음수일 경우 - ~이상이므로 양수로 바꿔준다.				
				m_scriptAlarm.UpdateAlarmItem(m_arrItemID[i], ItemCount);	//아이템 업데이트 해주기
			}
		}
	}	
}*/


//미니멥 추적 도구에서 퀘스트 클릭 한 경우.
function string LastNodeName(int QuestID, int Level, int nQuestType)
{
	local string strNodeName;
	local string strChildList;
	local int RecentlyAddedQuestID;
	local int SplitCount;
	local array<string>	arrSplit;
	local  TreeHandle tempCurTree;
	tempCurTree = CurTree; //백업

	RecentlyAddedQuestID = QuestID;

	getCurTree( nQuestType );
	/*switch (nQuestType)
	{
		case 0:
			CurTree = MainTree0;
			break;
		case 1:
			CurTree = MainTree1;
			break;
		case 2:
			CurTree = MainTree2;
			break;
		case 3:
			CurTree = MainTree3;
			break;
		case 4:
			CurTree = MainTree4;
			break;
	}*/
	
	QuestTreeTab.SetTopOrder(nQuestType, false);

	if (RecentlyAddedQuestID>0)
	{
		// 1. QuestNode Expand
		strNodeName = "root." $ RecentlyAddedQuestID;
		//CurTree.SetExpandedNode(strNodeName, true);
			
		
		// 2. JournalNode Expand
		strChildList = CurTree.GetChildNode(strNodeName);
		
		// Child중에서 가장 마지막 Child가 Expand할 저널
		if (Len(strChildList)>0)
		{
			SplitCount = Split(strChildList, "|", arrSplit);
			CurTree.SetExpandedNode( arrSplit[SplitCount-1], true );
			//Debug( "SetExpandedNode" @ arrSplit[SplitCount-1] );
		}
	}
	CurTree = tempCurTree; //restore 핸들

	return arrSplit[SplitCount-1];
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( m_WindowName ).HideWindow();
}


defaultproperties
{
    ROOTNAME="root"
    m_WindowName="QuestTreeWnd"
}
