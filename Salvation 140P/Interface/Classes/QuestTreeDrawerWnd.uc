class QuestTreeDrawerWnd extends UICommonAPI;

var WindowHandle Me;
var TextureHandle GroupBox_Title;
var TextureHandle GroupBox_DescriptionTree;
var TextureHandle GroupBox_DescriptionTreeLarge;
var TextureHandle GroupBox_ItemTree;
var TextureHandle GroupBox_RewardItemTree;
var TextBoxHandle txtQuestTitle;
var TextBoxHandle txtRecommandedLevel;
var TextBoxHandle txtRecommandedLevelText;
var TextBoxHandle txtQuestType;
var TreeHandle QuestDescriptionTree;
var TreeHandle QuestDescriptionLargeTree;
var TextBoxHandle txtQuestItemTitle;
var TextBoxHandle txtQuestRewardItemTreeTitle;
var TreeHandle QuestItemTree;
var TreeHandle QuestRewardItemTree;
var ButtonHandle btnGiveUpCurrentQuest;
var ButtonHandle btnAddAlarm;
var ButtonHandle btnClose;
var ButtonHandle btnDeleteAlarm;

//Utill 변수
var L2Util util;

//선택된 퀘스트 QuestID
var int SelectQuestID;
//선택된 퀘스트 레벨
var int SelectLevel;
//선택된 퀘스트 완료
var int SelectCompleted;
//
var array<int> SelectarrItemID;

var array<int> SelectarrItemNumList;

var array<int> SelectarrGoalType;

var QuestAlarmWnd m_scriptAlarm;

var QuestTreeWnd scQuestTree;
	
function OnRegisterEvent()
{
}

function OnLoad()
{
	Initialize();
	Load();
	
	util = L2Util(GetScript("L2Util"));	

	m_scriptAlarm = QuestAlarmWnd( GetScript( "QuestAlarmWnd" ));
	scQuestTree = QuestTreeWnd( GetScript( "QuestTreeWnd" ) );

	btnAddAlarm.DisableWindow();
	btnDeleteAlarm.DisableWindow();
}

function Initialize()
{
	Me = GetWindowHandle( "QuestTreeDrawerWnd" );
	GroupBox_Title = GetTextureHandle( "QuestTreeDrawerWnd.GroupBox_Title" );
	GroupBox_DescriptionTree = GetTextureHandle( "QuestTreeDrawerWnd.GroupBox_DescriptionTree" );
	GroupBox_DescriptionTreeLarge = GetTextureHandle( "QuestTreeDrawerWnd.GroupBox_DescriptionTreeLarge" );
	GroupBox_ItemTree = GetTextureHandle( "QuestTreeDrawerWnd.GroupBox_ItemTree" );
	GroupBox_RewardItemTree = GetTextureHandle( "QuestTreeDrawerWnd.GroupBox_RewardItemTree" );
	txtQuestTitle = GetTextBoxHandle( "QuestTreeDrawerWnd.txtQuestTitle" );
	txtRecommandedLevel = GetTextBoxHandle( "QuestTreeDrawerWnd.txtRecommandedLevel" );
	txtRecommandedLevelText = GetTextBoxHandle( "QuestTreeDrawerWnd.txtRecommandedLevelText" );
	txtQuestType = GetTextBoxHandle( "QuestTreeDrawerWnd.txtQuestType" );
	QuestDescriptionTree = GetTreeHandle( "QuestTreeDrawerWnd.QuestDescriptionTree" );
	QuestDescriptionLargeTree = GetTreeHandle( "QuestTreeDrawerWnd.QuestDescriptionLargeTree" );
	txtQuestItemTitle = GetTextBoxHandle( "QuestTreeDrawerWnd.txtQuestItemTitle" );
	txtQuestRewardItemTreeTitle = GetTextBoxHandle( "QuestTreeDrawerWnd.txtQuestRewardItemTreeTitle" );
	QuestItemTree = GetTreeHandle( "QuestTreeDrawerWnd.QuestItemTree" );
	QuestRewardItemTree = GetTreeHandle( "QuestTreeDrawerWnd.QuestRewardItemTree" );
	btnGiveUpCurrentQuest = GetButtonHandle( "QuestTreeDrawerWnd.btnGiveUpCurrentQuest" );
	btnAddAlarm = GetButtonHandle( "QuestTreeDrawerWnd.btnAddAlarm" );
	btnClose = GetButtonHandle( "QuestTreeDrawerWnd.btnClose" );
	btnDeleteAlarm = GetButtonHandle( "QuestTreeDrawerWnd.btnDeleteAlarm" );
}

function Load()
{
}

function OnEvent( int EventID, String param )
{
}

function OnClickButton( string Name )
{
	switch( Name )
	{
		case "btnGiveUpCurrentQuest":
			OnbtnGiveUpCurrentQuestClick();
			break;
		case "btnAddAlarm":
			OnbtnAddAlarmClick();
			break;
		case "btnClose":
			OnbtnCloseClick();
			break;
		case "btnDeleteAlarm":
			OnbtnDeleteAlarmClick();
			break;
	}
}

function OnbtnGiveUpCurrentQuestClick()
{
	local QuestTreeWnd Script;
	Script = QuestTreeWnd(GetScript("QuestTreeWnd"));
	
	Script.HandleQuestCancel();
	//class'QuestAPI'.static.RequestDestroyQuest( SelectQuestID );
}

function OnbtnAddAlarmClick()
{
	local int i, count;
	local string alarmTitleStr;

	// 퀘스트 아이디로 등록할 퀘스트 아이템을 등록한다.		
	//Debug("SelectarrItemID.Length" @ SelectarrItemID.Length);

	if (SelectarrItemID.Length > 0)
	{
		Debug("Call --> RequestAddExpandQuestAlarm : " $ string(SelectQuestID) );
		RequestAddExpandQuestAlarm( SelectQuestID );
	}

	for ( i = 0 ; i < SelectarrItemID.Length ; i++ )
	{	
		alarmTitleStr = "";

		// npcString을 통해, 특히 누구 만나기 등을 구현 하는 형태
		if(SelectarrGoalType[i] == 1) 
		{
			alarmTitleStr = GetNpcString(SelectarrItemID[i]);
			count = SelectarrItemNumList[i];
			// Debug("대화형? alarmTitleStr" @ alarmTitleStr);
		}
		// 처치형
		else if( SelectarrItemID[i] >= 1000000 )
		{
			alarmTitleStr = class'UIDATA_NPC'.static.GetNPCName( SelectarrItemID[i] - 1000000) $ " " $ GetSystemString(2240) ;				
			count = SelectarrItemNumList[i];
			// Debug("처치형 alarmTitleStr" @ alarmTitleStr);
		}
		// 보통 수집..
		else
		{
			alarmTitleStr = class'UIDATA_ITEM'.static.GetItemName( GetItemID( SelectarrItemID[i] ));
			count = int(GetInventoryItemCount( GetItemID( SelectarrItemID[i])));
			// Debug("수집 일반형 alarmTitleStr" @ alarmTitleStr);
			//m_scriptAlarm.AddQuestAlarm( SelectQuestID, SelectLevel, SelectarrItemID[i], SelectarrItemNumList[i] );
			//선택한 Quest의 마지막 것으로 요청한다.
		}

		m_scriptAlarm.AddQuestAlarmNew( 
			SelectQuestID,
			class'UIDATA_QUEST'.static.GetQuestName( SelectQuestID, SelectLevel ),
			SelectarrItemID[i],
			alarmTitleStr,
			count,
			SelectarrItemNumList[i],
			SelectLevel);

			//Debug("Call --> m_scriptAlarm.AddQuestAlarmNew : " $ string(SelectQuestID) );
			//Debug("SelectQuestID: " $ string(SelectQuestID) );
			//Debug("getItemNAme: " $ class'UIDATA_ITEM'.static.GetItemName( GetItemID( SelectarrItemID[i] )));
			//Debug("GetInventoryItemCount( GetItemID( SelectarrItemID[i] ) ): " $ string(GetInventoryItemCount( GetItemID( SelectarrItemID[i] ) )) );
			//Debug("SelectarrItemNumList[i]: " $ string(SelectarrItemNumList[i]) );
			//Debug("SelectLevel: " $ SelectLevel );
	}

	scQuestTree.ButtonEnableCheck();
}

function OnbtnCloseClick()
{
	Me.HideWindow();
}

function OnbtnDeleteAlarmClick()
{
	scQuestTree.HandleDeleteAlarm();
}

function showQuestDrawer( string str )
{
	local int i;
	local int SplitCount;
	local array<string>	arrSplit;

	//퀘스트 아이디
	local int QuestID;
	//퀘스트 레벨
	local int Level;
	//퀘스트 완료
	local int Completed;
	//퀘스트 타입
	local int QuestType;
	//퀘스트 세부 타입 일일 퀘 구분 용도
	local int Type;

	//추천 레벨 최저, 최고
	local int MinLevel, MaxLevle;

	//퀘스트 설명
	local string QuestDescription;

	//퀘스트 아이템 param
	local string QuestParam;
	//퀘스트 아이템 개수
	local int Max;

	//퀘스트 필요 아이템 ID
	local array<int>		arrItemIDList;
	//퀘스트 필요 아이템 개수
	local array<int>		arrItemNumList;
	//?? 먼지 머름..;;
	local bool			bShowCompletionItem;

	//보상 아이템 ID
	local Array<int> rewardIDList;	
	//보상 아이템 개수
	local Array<INT64> rewardNumList;
	
	//퀘스트 소 제목
	local string JournalName;	

	//설명 
	local bool bQuest;

	//스트링 타입인지 체크
	local array<int> arrGoalType;

	bQuest = false;


	if( !Me.IsShowWindow() )
		Me.ShowWindow();

	btnGiveUpCurrentQuest.EnableWindow();

	SplitCount = Split( str, ".", arrSplit );
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

	MinLevel = class'UIDATA_QUEST'.static.GetMinLevel( QuestID, Level );
	MaxLevle = class'UIDATA_QUEST'.static.GetMaxLevel( QuestID, Level );

	QuestDescription = class'UIDATA_QUEST'.static.GetQuestDescription( QuestID, Level );

	//퀘스트 소제목
	JournalName = class'UIDATA_QUEST'.static.GetQuestJournalName( QuestID, Level );
	//branch 110720_0804
	JournalName = class'UIDATA_QUEST'.static.GetQuestJournalNameLine( JournalName );
	//end of branch
	txtQuestTitle.SetText( JournalName );

	//추천레벨
	txtRecommandedLevel.SetTextColor( util.White );
	txtRecommandedLevel.SetText( GetSystemString(922) @ ":");

	//레벨 표시( 1~23, 11이상, 제한 없음 )
	txtRecommandedLevelText.SetTextColor( util.Token1 );
	if ( MaxLevle > 0 && MinLevel > 0)
		txtRecommandedLevelText.SetText( MinLevel $ "~" $ MaxLevle );
	else if ( MinLevel > 0 )
		txtRecommandedLevelText.SetText( MinLevel $ " " $ GetSystemString(859) );
	else
		txtRecommandedLevelText.SetText( GetSystemString(866) );

	//퀘스트 타입( 전직 퀘스트, 일회성 퀘스트 등 )
	QuestType = Class'UIDATA_QUEST'.static.GetQuestIscategory( QuestID, Level );

	//퀘스트 타입 (솔로, 파티, 일일, 반복 구분)
	
	txtQuestType.SetTextColor( util.White );
	switch (QuestType)
	{
		case 0:
			txtQuestType.SetText(GetSystemString(862));
			break;
		case 1:
			Type = class'UIDATA_QUEST'.static.GetQuestType(QuestID, Level);
			if ( Type == 4 || Type == 5 )
				txtQuestType.SetText(GetSystemString( 2788 )); //일일 퀘스트 
			else 
				txtQuestType.SetText(GetSystemString(861));				
			break;
		case 2:
			txtQuestType.SetText(GetSystemString(1998));
			break;
		case 3:
			txtQuestType.SetText(GetSystemString(1999));
			break;
		case 4:
			txtQuestType.SetText(GetSystemString(2000));
			break;
	}


	QuestParam = class'UIDATA_QUEST'.static.GetQuestItem( QuestID, Level );

	ParseInt( QuestParam, "Max", Max );	
	arrItemIDList.Length = Max;	
	arrItemNumList.Length = Max;
	arrGoalType.Length = Max;

	for ( i = 0; i < Max; i++ )
	{
		//퀘스트 필요 아이템 ID
		ParseInt( QuestParam, "GoalID_" $ i, arrItemIDList[i] );
		//퀘스트 필요 아이템 개수
		ParseInt( QuestParam, "GoalNum_" $ i, arrItemNumList[i] );
		//퀘스트 스트링 타입 여부
		ParseInt( QuestParam, "GoalType_" $ i, arrGoalType[i]) ;

		if( arrItemIDList[i] < 1000000 && arrGoalType[i] != 1)
		{
			bQuest = true;// true; //아이템 형
		}
	}

	rewardIDList.Remove(0, rewardIDList.Length);
	rewardNumList.Remove(0, rewardNumList.Length);

	class'UIDATA_QUEST'.static.GetQuestReward( QuestID, Level, rewardIDList, rewardNumList);

	//스킬 설명	
	util.TreeClear( "QuestTreeDrawerWnd.QuestDescriptionTree" );
	util.TreeClear( "QuestTreeDrawerWnd.QuestDescriptionLargeTree" );
	//Root 노드 생성.
	util.TreeInsertRootNode( "QuestTreeDrawerWnd.QuestDescriptionTree", "root", "" );
	util.TreeInsertRootNode( "QuestTreeDrawerWnd.QuestDescriptionLargeTree", "root", "" );
	
	if( Max != 0 )
	{
		//모르겠음 이전 코딩이 이렇게 되어 있음.
			// 2009.11 퀘스트 파트에서 요청 
			// 100만 넘은 건 퀘스트 아이템에 등록 하지 않는다.
			// (예: 맹수 처치 퀘스트에서 몬스터를 몇마리 잡아라! 라고 한다면 , Item_id 는 100만 10 이라구 한다면 특정 몬스터를 10마리 잡아라
			// 이런식으러 퀘스트 파트에서 처리가 되어 있다. 그래서 들어 가는 코드이다.)
			// [ 가능하면 별도 속성으로 이런 것은 처리 했으면 좋을 것이다. ]
		//확실 하지 않음.
		/*
		 * 수정 함..;;;
		 */

		if( !bQuest )
		{
			setQuestItemShow( false ); //학살형
			//Insert Node Item - 아이템 이름
			util.TreeInsertTextNodeItem( "QuestTreeDrawerWnd.QuestDescriptionLargeTree", "root", QuestDescription );
		}
		else
		{
			setQuestItemShow( true );
			//Insert Node Item - 아이템 이름
			util.TreeInsertTextNodeItem( "QuestTreeDrawerWnd.QuestDescriptionTree", "root", QuestDescription );
		}
	}
	else
	{
		setQuestItemShow( false );
		//Insert Node Item - 아이템 이름
		util.TreeInsertTextNodeItem( "QuestTreeDrawerWnd.QuestDescriptionLargeTree", "root", QuestDescription );
	}


	if( Max > 0 )
	{
		if( bQuest )
		{
			bShowCompletionItem = class'UIDATA_QUEST'.static.IsShowableItemNumQuest( QuestID, Level );
			setQuestItem( Completed, Max, arrItemIDList, arrItemNumList, bShowCompletionItem, arrGoalType);
		}
	}

	if ( rewardIDList.length > 0 )
	{
		setRewardItem( rewardIDList, rewardNumList );
	}


	selectQuestLastCall( QuestID );
	/*
	//선택한 퀘스트 [퀘스트 알람용 인가??]
	SelectQuestID = QuestID;
	SelectLevel = Level;
	SelectCompleted = Completed;

	SelectarrItemID = arrItemIDList;
	SelectarrItemNumList = arrItemNumList;
	*/


}

/**
 * 퀘스트 아이템 Tree에 추가.
 */
function setQuestItem( int Completed, int count, array<int> IDList, array<int> ItemNum, bool bShowCompletionItem, array<int> arrGoalType )
{
	local int i;
	local string TREENAME;
	local string setTreeName;
	local string strRetName;

	local bool bDrawBgTreeQuestItem;
	local string iconName;
	local string itemName;

	TREENAME = "QuestTreeDrawerWnd.QuestItemTree";
	TreeClear( TREENAME );

	bDrawBgTreeQuestItem = false;
	//Roots 노드 생성.
	util.TreeInsertRootNode( TREENAME, "List", "", 0, 2 );
	setTreeName = "List";

	for( i = 0 ; i < count ; i++ )
	{
		if ( arrGoalType[i] == 0 )
		{			
			if( IDList[i] < 1000000 )
			{
				strRetName = util.TreeInsertItemNode( TREENAME, string(i), setTreeName, false, -4, -2 );
				iconName = class'UIDATA_ITEM'.static.GetItemTextureName( GetItemID( IDList[i] ) );
				itemName = class'UIDATA_ITEM'.static.GetItemName( GetItemID( IDList[i] ) );

				if( !bDrawBgTreeQuestItem )
				{
					//Insert Node Item - 아이템 배경?
					util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_CH3.etc.textbackline", 244, 38, , , , ,14 );
				}
				else
				{
					util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_CT1.EmptyBtn", 244, 38 );
				}
				bDrawBgTreeQuestItem = !bDrawBgTreeQuestItem;

				//Insert Node Item - 아이템슬롯 배경
				util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_ct1.ItemWindow.ItemWindow_df_slotbox_2x2", 36, 36, -238, 2 );
				//Insert Node Item - 아이템 아이콘
				util.TreeInsertTextureNodeItem( TREENAME, strRetName, IconName, 32, 32, -34, 3 );
				//Insert Node Item - 아이템 이름
				//[퀘스트 아이템 툴팁 추가] 퀘스트 아이템에 툴팁을 표시하기 위한 item class id를 저장.
				util.TreeInsertTextNodeItem( TREENAME, strRetName, itemName, 5, 6, util.ETreeItemTextType.COLOR_DEFAULT, true, , IDList[i] );

				//아이템 개수 표시
				if( ItemNum[i] > 0 )
				{
					if( Completed > 0 && bShowCompletionItem )
						util.TreeInsertTextNodeItem( TREENAME, strRetName, "(" $ GetSystemString(898) $ "/" $ ItemNum[i] $ ")", 48, -18, util.ETreeItemTextType.COLOR_GOLD, ,true );
					else
						util.TreeInsertTextNodeItem( TREENAME, strRetName, "(" $ ItemNum[i] $ ")", 48, -18, util.ETreeItemTextType.COLOR_GOLD, ,true );
				}
				else if( ItemNum[i] == 0 )
				{
					if( Completed > 0 && bShowCompletionItem )
						util.TreeInsertTextNodeItem( TREENAME, strRetName, "(" $ GetSystemString(898) $ "/" $ GetSystemString(858) $ ")", 48, -18, util.ETreeItemTextType.COLOR_GOLD, ,true );
					else
						util.TreeInsertTextNodeItem( TREENAME, strRetName, "(" $ GetSystemString(858) $ ")", 48, -18, util.ETreeItemTextType.COLOR_GOLD, ,true );				
				}
				else
				{
					if( Completed > 0 && bShowCompletionItem )
						util.TreeInsertTextNodeItem( TREENAME, strRetName, "(" $ GetSystemString(898) $ "/" $ string(-ItemNum[i]) $ GetSystemString(859) $ ")", 48, -18, util.ETreeItemTextType.COLOR_GOLD, ,true );
					else
						util.TreeInsertTextNodeItem( TREENAME, strRetName, "(" $ string(-ItemNum[i]) $ GetSystemString(859) $ ")", 48, -18, util.ETreeItemTextType.COLOR_GOLD, ,true );
				}
			}
		}
	}
}

/**
 * 보상 아이템 Tree에 추가.
 */
function setRewardItem( array<int> rewardIDList, array<INT64> rewardNumList )
{
	local int i;
	local string TREENAME;
	local string setTreeName;
	local string strRetName;
	
	local bool bDrawBgTreeReward;
	local string iconName;
	local string itemName;

	TREENAME = "QuestTreeDrawerWnd.QuestRewardItemTree";
	TreeClear( TREENAME );

	bDrawBgTreeReward = false;

	//Roots 노드 생성.
	util.TreeInsertRootNode( TREENAME, "List", "", 0, 2 );
	setTreeName = "List";

	for( i = 0 ; i < rewardIDList.Length ; i++ )
	{
		strRetName = util.TreeInsertItemNode( TREENAME, string(i), setTreeName, false, -4, -2 );

		if( !bDrawBgTreeReward )
		{
			//Insert Node Item - 아이템 배경?
			util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_CH3.etc.textbackline", 244, 38, , , , ,14 );
		}
		else
		{
			util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_CT1.EmptyBtn", 244, 38 );
		}
		bDrawBgTreeReward = !bDrawBgTreeReward;

		//Insert Node Item - 아이템슬롯 배경
		util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_ct1.ItemWindow.ItemWindow_df_slotbox_2x2", 36, 36, -238, 2 );
		
		//아이템 아이콘 결정
		switch (rewardIDList[i])
		{
			case 57:
				//아데나 일 경우
				iconName = class'UIDATA_ITEM'.static.GetItemTextureName(GetItemID(57));		
				itemName = GetSystemString(469);

				//Insert Node Item - 아이템 아이콘
				util.TreeInsertTextureNodeItem( TREENAME, strRetName, IconName, 32, 32, -34, 3 );
				//Insert Node Item - 아이템 이름
				//[퀘스트 아이템 툴팁 추가] 퀘스트 아이템에 툴팁을 표시하기 위한 item class id를 저장.
				util.TreeInsertTextNodeItem( TREENAME, strRetName, itemName, 5, 6, util.ETreeItemTextType.COLOR_DEFAULT, true );
					
				//아데나 양
				//미정
				if ( rewardNumList[i] == 0 )
					util.TreeInsertTextNodeItem( TREENAME, strRetName, GetSystemString(584), 48, -18, util.ETreeItemTextType.COLOR_GOLD, ,true );
				else 
					util.TreeInsertTextNodeItem( TREENAME, strRetName, MakeFullSystemMsg(GetSystemMessage(2932), MakeCostString(string(rewardNumList[i])),""), 48, -18, util.ETreeItemTextType.COLOR_GOLD, , true );
				break;
				
			default:
				iconName = class'UIDATA_ITEM'.static.GetItemTextureName(GetItemID(rewardIDList[i]));
				itemName = class'UIDATA_ITEM'.static.GetItemName(GetItemID(rewardIDList[i]));

				//Insert Node Item - 아이템 아이콘
				util.TreeInsertTextureNodeItem( TREENAME, strRetName, IconName, 32, 32, -34, 3 );
				//Insert Node Item - 아이템 이름
				//[퀘스트 아이템 툴팁 추가] 퀘스트 아이템에 툴팁을 표시하기 위한 item class id를 저장.
				util.TreeInsertTextNodeItem( TREENAME, strRetName, itemName, 5, 6, util.ETreeItemTextType.COLOR_DEFAULT, true, , rewardIDList[i] );

				//아이템 개수
				//미정
				if (rewardNumList[i] == 0)
					util.TreeInsertTextNodeItem( TREENAME, strRetName, GetSystemString(584), 48, -18, util.ETreeItemTextType.COLOR_GOLD, ,true );
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
						rewardIDList[i] == 15633 || 						
						rewardIDList[i] == 47130      // 우호도
						)
					{
						util.TreeInsertTextNodeItem( TREENAME, strRetName, MakeCostString(string(rewardNumList[i])), 48, -18, util.ETreeItemTextType.COLOR_GOLD, ,true );
					}
					else
					{
						util.TreeInsertTextNodeItem( TREENAME, strRetName, MakeFullSystemMsg(GetSystemMessage(1983), MakeCostString(string(rewardNumList[i])),""), 48, -18, util.ETreeItemTextType.COLOR_GOLD, ,true );      
					}
				}
				break;
		}
	}
}

/**
 * 퀘스트 아이템이 있는 경우 없는 경우 창 정보 바꿈.
 */
function setQuestItemShow( bool b )
{
	if( b )
	{
		QuestDescriptionLargeTree.HideWindow();
		QuestDescriptionTree.ShowWindow();
		txtQuestItemTitle.ShowWindow();
		GroupBox_DescriptionTree.ShowWindow();
		GroupBox_ItemTree.ShowWindow();
		QuestItemTree.ShowWindow();
	}
	else
	{
		QuestDescriptionTree.HideWindow();
		QuestDescriptionLargeTree.ShowWindow();
		txtQuestItemTitle.HideWindow();
		QuestItemTree.HideWindow();
		GroupBox_DescriptionTree.HideWindow();
		GroupBox_ItemTree.HideWindow();
	}

}

// 트리 비우기
function TreeClear( string str )
{
	class'UIAPI_TREECTRL'.static.Clear( str );	
}


/**
 * 선택한 퀘스트에 마지막 레벨을 알림 창에 보여줌.
 */
function selectQuestLastCall( int selectQuest )
{
	local int Level;

	local int i;

	//퀘스트 아이템 param
	local string QuestParam;
	//퀘스트 아이템 개수
	local int Max;

	//퀘스트 필요 아이템 ID
	local array<int>		arrItemIDList;
	//퀘스트 필요 아이템 개수
	local array<int>		arrItemNumList;
	//퀘스트 골네임이 스트링 타입인지?
	local array<int>        arrGoalType;

	Level = 0;

	//전체 퀘스트
	Level = util.getQuestLevelForID (selectQuest);

	QuestParam = class'UIDATA_QUEST'.static.GetQuestItem( selectQuest, Level );

	ParseInt( QuestParam, "Max", Max );	
	arrItemIDList.Length = Max;	
	arrItemNumList.Length = Max;
	arrGoalType.Length = Max;

	for ( i = 0; i < Max; i++ )
	{
		//퀘스트 필요 아이템 ID
		ParseInt( QuestParam, "GoalID_" $ i, arrItemIDList[i] );
		//퀘스트 필요 아이템 개수
		ParseInt( QuestParam, "GoalNum_" $ i, arrItemNumList[i] );
		//퀘스트 스트링 타입 여부
		ParseInt( QuestParam, "GoalType_" $ i, arrGoalType[i]);
	}

	SelectQuestID = selectQuest;
	SelectLevel = Level;

	SelectarrItemID = arrItemIDList;
	SelectarrItemNumList = arrItemNumList;
	SelectarrGoalType = arrGoalType;
}


function onHide()
{
	AllClear();
}

function AllClear()
{
	util.TreeClear( "QuestTreeDrawerWnd.QuestItemTree" );
	util.TreeClear( "QuestTreeDrawerWnd.QuestRewardItemTree" );
	util.TreeClear( "QuestTreeDrawerWnd.QuestDescriptionTree" );
	util.TreeClear( "QuestTreeDrawerWnd.QuestDescriptionLargeTree" );

	txtQuestTitle.SetText("");
	//추천레벨
	txtRecommandedLevel.SetText("");
	txtRecommandedLevelText.SetText("");
	txtQuestType.SetText("");

	btnGiveUpCurrentQuest.DisableWindow();
}

/*
//function array<string> getSystemStringArray(int type)
function array<int> getQuestItemID()
{
	//SelectarrItemNumList = arrItemNumList;
	return SelectarrItemID;
	//return item1Array;
}

function array<int> getQuestItemNum()
{
	//SelectarrItemNumList = arrItemNumList;
	return SelectarrItemNumList;	
}
*/
defaultproperties
{
}
