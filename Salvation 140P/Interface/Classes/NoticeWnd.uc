//------------------------------------------------------------------------------------------------------------------------
//
// 제목 : NoticeWnd  ( 튜토리얼, 퀘스트, 메일, 경매알림, 프리미엄 아이템, 생일 알림[없음]  ) - SCALEFORM UI
//        새로운 추가 --> 스킬 습득, 캠패인, 존퀘스트, 4차 각성
//        TutorialBtnWnd.uc + QuestBtnWnd.uc + MailBtnWnd.uc + AuctionBtnWnd.uc[툴팁 문제로 아직 작업전]
//   
//        2013(10월) GD3.5에서 스케일폼4로 변경
//
//    ****  2015-11-26 , 해외 버전 , 오늘의 할일은 빠져 있으니 머징 할때 주의!!!!!!  *****
//------------------------------------------------------------------------------------------------------------------------
class NoticeWnd extends L2UIGFxScript;

const FLASH_XPOS = -7;
const FLASH_YPOS = -250;

// 삭제 
const NOTICEBUTTON_DELETE    = "900";
// 삭제 
const NOTICEBUTTON_DELETEALL = "1000";
// 위로 쌓이는 식의 레이아웃
const LAYOUT_MULTILINE       = "10001";
// 왼쪽으로 늘이는 레이아웃
const LAYOUT_ONELINE         = "10002";

var int RecentlyAddedQuestID;
var int HtmlString;
var int zonetype;	

var array<GFxValue> args;
var GFxValue invokeResult;


var WindowHandle Me;

var WindowHandle AlarmWnd;

var MagicSkillWnd MagicSkillWndScript;
var QuestTreeWnd QuestTreeWndScript;

var UserInfo currentUserInfo;

var TabHandle m_TabCtrl;

var bool bCam;
var bool bZone;
var bool bEvent;

var bool bUseSingleMesh;  // 최적화 제복 상태 저장
// 각성 클래스 id 저장
var int  awakeClassID, awakeImmediate;

//해상도용
var int currentScreenWidth, currentScreenHeight;

//branch121212
var int PathToAwakeningAlarmType; 
var int PathToAwakeningAlarmValue;

var int nUsePledgeV2Live;

// 순서 바꾸면 안됨, 밑으로 추가 하세요
enum ENoticeType
{
	TYPE_MAIL,
	TYPE_QUEST,
	TYPE_PREM,
	TYPE_TUTORIAL,
	TYPE_SKILL,
	TYPE_CAMPAIGN,
	TYPE_ZONE,
	TYPE_AWAKENED,
	TYPE_CURIOUSEHOUSE,
	TYPE_EVENTCAMPAIGN,        // 이벤트 캠페인 (아마도 해외 좀비 이벤트) 9
	TYPE_PLEDGEALARM,          // 혈맹알람
	TYPE_WEBPETITIONALARM,     // Web진정 알람  , 별도 알림 아이콘을 하지 않고 바로 창을 열어 준다(왜 인진 모르겠고 그렇게 작업했다)
	TYPE_SINGLEMESHZONE,       // 최적화 제복, 12
	TYPE_PVPBLOCKCHECKER,      // 블록체커	
	TYPE_PVPCRATAECUBE,        // 콜로세움 상황판 
	TYPE_PVPMATCHRECORD,       // PVP 상황판 
	TYPE_PVPCLEFT,             // 크레프트 상황판 16 
	TYPE_PATHTOAWAKENINGALARM, // PathToAwakeningAlarm 17
	TYPE_TODOLIST,             // 오늘의 할일 18
	TYPE_LINEAGE2HOME,         // 리니지2홈 (인게임웹) 19
	TYPE_KILLER,               // 중국 원수알림 20
	TYPE_PCROOM,               // 중국 pc방 알림 21
	TYPE_ATTENDANCESTAMP,      // 출석부 22 (현재는 중국만), 출석부는 중국과 국내 버전이 다름(알림은 같이써도 뭐..상관 없음)
	TYPE_CHINATUTORIAL,        // 중국만 사용하는 튜터리얼, 3번 튜터리얼은 다중타입, 중국은 하나만 나오는 튜터리얼, 23
	TYPE_ABILITYPOINT,         // 어빌리티 포인트, 24
	TYPE_MONSTERBOOK,          // 몬스터 도감, 25
	TYPE_FACTION,              // 세력(펙션) 26
	TYPE_AUCTION_FAIL,         // 경매 유찰 27
	TYPE_EVENT_INFO,           // 이벤트 정보 28
	TYPE_NSHOPHOME             // N샵 29
};


// 프롤로그 상태 체크 
var bool isPrologueGrowTypeState ;
var bool isGetPremium;

function OnRegisterEvent()
{
	RegisterEvent( EV_ResolutionChanged );
	RegisterEvent( EV_Restart );

	//--------------------------------------------------------- 
	// 유동형 알림 아이콘 이벤트
	//--------------------------------------------------------- 
	//메일 알림 이벤트
	RegisterEvent( EV_ArriveNewMail );
	RegisterEvent( EV_Notice_Post_Arrived );
	RegisterEvent( EV_SetRadarZoneCode );

	//퀘스트 관련 알림 이벤트 1520
	RegisterEvent( EV_ArriveShowQuest );

	//프리미엄 아이템 3460
	RegisterEvent( EV_PremiumItemAlarm );

	//한국 상품인벤토리.
	RegisterEvent( EV_GoodsInventoryNoti );

	//튜토리얼 1510, QuestionID=1, 삭제 됨.
	//RegisterEvent( EV_ArriveNewTutorialQuestion );

	// 2015개선, 튜토리얼 1511 ID=1 Type=0 Name="어쩌구다"
	RegisterEvent( EV_ArriveTutorial );

	//스킬 습득 2059
	RegisterEvent( EV_SkillLearningNewArrival );

	// 4차 전직 (각성) 알람  
	RegisterEvent( EV_CallToChangeClass );

	//혈맹 가입 알람  9630
	RegisterEvent( EV_PledgeWaitingListAlarm );	

	//--------------------------------------------------------- 
	// 고정 알림 아이콘 이벤트
	//--------------------------------------------------------- 
	//캠패인 5210
	RegisterEvent( EV_CampaignArrived );

	//캠패인 완료 5220
	RegisterEvent( EV_CampaignFinish );	

	//존 퀘스트
	RegisterEvent( EV_ZoneQuestArrived );

	// 혼돈의 제전
	// 의문의 저택 state 0:기간 아님, 1:입장신청, 2:임장대기
	RegisterEvent( EV_CuriousHouseWaitState);	

	//이벤트 캠패인(해외) 좀비 이벤트 같은..
	RegisterEvent( EV_BR_Event_CampaignArrived ); //branch120516

	//유저가 단일 메시 볼륨에 들어갈 때 발생
	RegisterEvent( EV_EnterSingleMeshZone ); //9540

	//유저가 단일 메시 볼륨에서 나올 때 발생
	RegisterEvent( EV_ExitSingleMeshZone ); //9541	

	//--------------------------------------------------------- 
	// 바로 UI 창을 열어 주는 이벤트
	//--------------------------------------------------------- 
	//진정 알람 9452
	RegisterEvent( EV_WebPetitionReplyAlarm );	
	
	//branch121212 PathToAwakening 10100
	RegisterEvent( EV_PathToAwakeningAlarm );	

	// 핸디의 블록체커, toolTip : 2445
	RegisterEvent( EV_BlockStateTeam );	
	RegisterEvent( EV_BlockStatePlayer );	

	// 클레프트 상황판, toolTip : 2443
	RegisterEvent( EV_CleftStateTeam );	
	RegisterEvent( EV_CleftStatePlayer );	

	// 지하 콜로세움 상황판toolTip : 2444
	RegisterEvent( EV_CrataeCubeRecordMyItem );	
	RegisterEvent( EV_CrataeCubeRecordBegin );	
	RegisterEvent( EV_CrataeCubeRecordRetire );	

	//PVP 상황판 toolTip : 2442
	RegisterEvent( EV_PVPMatchRecord );

	// 퀘스트 
	RegisterEvent( EV_QuestListEnd );

	// 스테이트 
	RegisterEvent( EV_StateChanged );

	// 오늘의 할일,  일일보상 160831 해외에서 클래식 추가
	RegisterEvent( EV_OneDayRewardCount );

	// 클랜 가입 시스템 버튼 삭제를 위해서
	RegisterEvent( EV_ClanInfo );

	// 리뉴얼 된 클랜 정보, 스케일 폼 이벤트
	RegisterGFxEvent( EV_GFX_ClanInfo ); //                 = 10450;
	
	// 어빌리티 포인트 알람을 보여줌.
	RegisterEvent( EV_UpdateUserInfo );

	// 경매 유찰(실패) 알림 
	RegisterEvent( EV_ITEM_AUCTION_UPDATED_BIDDING_INFO );

	// 세력 
	RegisterEvent( EV_FactionLevelUpNotify );
	
	// 몬스터 도감
	RegisterEvent( EV_MonsterBookRewardIcon );

	// 차원 서버로 이동 할때
	RegisterEvent ( EV_GotoWorldRaidServer );
	
	// 오늘의 할일,  일일보상 10127
	RegisterEvent( EV_OneDayRewardCount );

	// 케릭터 직업 정보가 바뀔 때
	registerEvent( EV_ChangedSubjob );
}

function OnLoad()
{	
	registerState( "NoticeWnd", "GamingState" );
	SetContainerHUD(WINDOWTYPE_NONE, 0);
	//SetContainer(WINDOWTYPE_NONE, 0);
	AddState("GAMINGSTATE");
		
	// SetAlwaysFullAlpha( true );
	SetHavingFocus( false );
	SetDefaultShow(true);
	SetHUD();

	Me                  = GetWindowHandle( "NoticeWnd" );

	AlarmWnd            = GetWindowHandle( "PremiumItemAlarmWnd" );
	MagicSkillWndScript = MagicSkillWnd(GetScript("MagicSkillWnd"));
	QuestTreeWndScript  = QuestTreeWnd(GetScript("QuestTreeWnd"));
	PathToAwakeningAlarmType = 0; //branch121212
	PathToAwakeningAlarmValue = 0; //branch121212
}

//Flash에 마우스 오버시 이벤트 발생.
//event OnMouseOver( WindowHandle w )
//{	
//	dispatchEventToFlash_Int(200,0);
//}
//Flash에 마우스 아웃시 이벤트 발생.
//event OnMouseOut( WindowHandle w )
//{
//	//강제로 마우스 위치를 0,0으로.
//	dispatchEventToFlash_Int(201,0);
//}

function OnShow()
{	
	checkMultiLayOut();
}

function OnFlashLoaded()
{
	checkMultiLayOut();
}


function onCallUCFunction( string functionName, string param )
{
	clickNoticeButton(functionName, param);
}

// onCallUCLogic 기존 대체 
function clickNoticeButton( string logicIDStr, string param )
{
	local string	        strParam;
	local int               logicID;

	//캠페인 버튼 눌렸을 경우 스크립트 호출 위한 것.
	local CampaignAlarmWnd campaign;
	//존 퀘스트 버튼 눌렸을 경우 스크립트 호출 위한 것.
	local ZoneQuestAlarmWnd zone;
	// 각성창을 열기 위해 (동영상 재생 및 각성해주는 윈도우)
	local GfxDialog GfxDialogScript;
	local BR_CampaignAlarmWnd br_eventcampaign; //branch120516

	local int    tutorialID;
	local int    tutorialType;
	
	//local String tutorialName;
	
	logicID  = int(logicIDStr);
	campaign = CampaignAlarmWnd( GetScript("CampaignAlarmWnd") );
	zone     = ZoneQuestAlarmWnd( GetScript("ZoneQuestAlarmWnd") );
	
	br_eventcampaign = BR_CampaignAlarmWnd( GetScript("BR_CampaignAlarmWnd") );//branch120516

	// Debug("logicID" @ logicID);
	// Debug("zonetype" @ zonetype);

	if( logicID == ENoticeType.TYPE_MAIL )
	{
		if( zonetype == 12 )
		{
			// ParamAdd(strParam, "Name", "Post");
			// ExecuteEvent(EV_ShowWindow, strParam);
			PlayConsoleSound(IFST_WINDOW_OPEN);
			RequestRequestReceivedPostList();
		}
		else
		{
			AddSystemMessage(3066);
		}
	}
	else if( logicID == ENoticeType.TYPE_QUEST )
	{
		ParamAdd(strParam, "QuestID", String(RecentlyAddedQuestID) );
		ExecuteEvent( EV_QuestSetCurrentID, strParam );
	}
	else if( logicID == ENoticeType.TYPE_PREM )
	{
		if( IsUseGoodsInvnentory() == false )
		{
			if(!AlarmWnd.isShowWindow()) AlarmWnd.showWindow();
		}
		else
		{
			HandleShowProductInventory();
		}
	}
	else if( logicID == ENoticeType.TYPE_TUTORIAL )
	{			
		//RequestTutorialQuestionMarkPressed( HtmlString );	

		ParseInt(param   , "ID"  , tutorialID);
		ParseInt(param   , "Type", tutorialType);

		//Debug("param: " @ param);
		//Debug("--> Call API : RequestTutorialMarkPressed");
		//Debug("tutorialID: " @ tutorialID);
		//Debug("tutorialType: " @ tutorialType);

		// 2015.05.13 새로 추가된 튜터리얼 오픈 함수
		RequestTutorialMarkPressed(tutorialType, tutorialID);
	}
	else if( logicID == ENoticeType.TYPE_SKILL )
	{
		// MagicSkillWnd.ShowWindow();
		// m_TabCtrl.SetTopOrder( 2, false );
		MagicSkillWndScript.externalCallLearnSkill();

		//MagicSkillWnd.onClickButton("TabCtrl2");
		
	}
	else if( logicID == ENoticeType.TYPE_CAMPAIGN )
	{
		bCam = false;
		campaign.RaderButtonClick();
	}
	else if( logicID == ENoticeType.TYPE_ZONE )
	{	
		bZone = false;
		zone.RaderButtonClick();
	}
	else if( logicID == ENoticeType.TYPE_AWAKENED )
	{	
		//Debug("각성 알림!");
		// 각성 알람 다이얼로그 열기 		
		ParamAdd(strParam, "Class", String(awakeClassID) );

		gfxDialogScript = GfxDialog( GetScript("GfxDialog") );
		gfxDialogScript.showGfxDialog("dialogLinkageName", "AwakeNoticeDialog", strParam);
	}
	else if ( logicID == ENoticeType.TYPE_CURIOUSEHOUSE )
	{
		RequestCuriousHouseHtml();
		///parseInt( param , "state",  HouseState )
		//창을 염
	}
	//branch120516
	else if ( logicID == ENoticeType.TYPE_EVENTCAMPAIGN )
	{
		bEvent = false;
		br_eventcampaign.RaderButtonClick();
	}

	else if ( logicID == ENoticeType.TYPE_PLEDGEALARM )
	{
		if ( !class'UIAPI_WINDOW'.static.IsShowWindow("ClanSearch") ) //gfx 형 윈도우 때문에 이와 같은 형태로 수정
			class'UIAPI_WINDOW'.static.ShowWindow("ClanSearch");
	}

	//end of branch
	else if ( logicID == ENoticeType.TYPE_WEBPETITIONALARM )
	{
		ExecuteEvent( EV_ShowWebPetitionListPage );
		ResponsePetitionAlarm();
	}

	else if ( logicID == ENoticeType.TYPE_SINGLEMESHZONE )
	{
		// 작업 되면 on, off 하도록
		// SwitchSingleMeshMode
		bUseSingleMesh = !bUseSingleMesh;
		
		SwitchSingleMeshMode(bUseSingleMesh);
		if(bUseSingleMesh)
		{
			createNoticeButton(	ENoticeType.TYPE_SINGLEMESHZONE, 3031); // 최적화 제복 끄기
		}
		else 
		{
			createNoticeButton(	ENoticeType.TYPE_SINGLEMESHZONE, 3030); // 최적화 제복 켜기
		}
	}
	// 블록체커	
	else if ( logicID == ENoticeType.TYPE_PVPBLOCKCHECKER )
	{
		pvpButton(ENoticeType.TYPE_PVPBLOCKCHECKER);
	}
	// 콜로세움 상황판 
	else if ( logicID == ENoticeType.TYPE_PVPCRATAECUBE )
	{
		pvpButton(ENoticeType.TYPE_PVPCRATAECUBE);
	}
	// PVP 상황판 
	else if ( logicID == ENoticeType.TYPE_PVPMATCHRECORD )
	{
		pvpButton(ENoticeType.TYPE_PVPMATCHRECORD);
	}
	//branch121212
	else if ( logicID == ENoticeType.TYPE_PATHTOAWAKENINGALARM )
	{
		ParamAdd(strParam, "Type", String(PathToAwakeningAlarmType) );
		ParamAdd(strParam, "Value", String(PathToAwakeningAlarmValue) );
		ExecuteEvent( EV_ShowWebPathMainPage, strParam );
	}
	//end of branch	
	// 리니지2홈 (인 게임 웹) 열기
	else if ( logicID == ENoticeType.TYPE_LINEAGE2HOME )
	{
		// 3471
		//showHideLineage2Home();
		showHideL2InGameWeb("main", "");
		//Debug("TYPE_LINEAGE2HOME 알림 버튼 클릭!!!");
	}
	else if ( logicID == ENoticeType.TYPE_ABILITYPOINT ) 
	{
		showHideAbilityWnd () ;
	}
	else if ( logicID == ENoticeType.TYPE_MONSTERBOOK ) 
	{
		//Debug("몬스터 도감 알림 클릭!");
		showhideMonsterBookWnd();
	}
	else if ( logicID == ENoticeType.TYPE_FACTION ) 
	{
		//Debug("팩션 알림 클릭!!");
		showHideWindow( "FactionWnd" ) ;
	}
	else if ( logicID == ENoticeType.TYPE_AUCTION_FAIL ) 
	{
		//Debug("경매 알림 클릭!!!");	
		handleAuctionFail();
	}
	// 오늘의 할일
	else if ( logicID == ENoticeType.TYPE_TODOLIST )
	{
		if ( getInstanceUIData().getIsLiveServer () ) 
		{
			if ( class'UIAPI_WINDOW'.static.isShowWindow ( "ToDoListClanWnd" )  ) 				
				class'UIAPI_WINDOW'.static.HideWindow("ToDoListClanWnd");	
			else 
				class'UIAPI_WINDOW'.static.ShowWindow("ToDoListClanWnd");	
		}
		else if ( getInstanceUIData().getIsClassicServer()  )
		{
			ExecuteEvent(EV_TodoListShow, "forceOpen=1");
		}
		
	}

	// 이벤트 정보 UI
	else if ( logicID == ENoticeType.TYPE_EVENT_INFO )
	{
		showHideWindow( "EventInfoWnd" );
	}

	// n샵
	else if ( logicID == ENoticeType.TYPE_NSHOPHOME )
	{
		showHideL2InGameWeb("nshop", "");
		// 3471
		//showHideHomePage("https://mink.ncsoft.com/");
		//Debug("TYPE_LINEAGE2HOME 알림 버튼 클릭!!!");
	}
}

function handleAuctionFail( ) 
{
	local string strParam ;
	local HelpHtmlWnd script;
	script = HelpHtmlWnd ( GetScript ( "HelpHtmlWnd"));
	ParamAdd(strParam, "FilePath", "..\\L2text\\item_auction_rule_info002.htm");
	script.HandleShowHelp( strParam ) ;	
}

function showhideMonsterBookWnd ( ) 
{
	if ( class'UIAPI_WINDOW'.static.IsShowWindow ("MonsterBookWnd") )		
		class'UIAPI_WINDOW'.static.HideWindow("MonsterBookWnd");		
	else 
	{
		CallGFxFunction( "MonsterBookWnd", "clearSearchCondition", "" ) ;
		CallGFxFunction( "MonsterBookWnd", "ChangefactionCategroy", "0" ) ;
	}
}

function showHideWindow ( string windowName )
{
	if ( class'UIAPI_WINDOW'.static.IsShowWindow (windowName) )
	{
		class'UIAPI_WINDOW'.static.HideWindow(windowName);
	}
	else
	{
		class'UIAPI_WINDOW'.static.ShowWindow(windowName);
		class'UIAPI_WINDOW'.static.SetFocus(windowName);
	}
}

function showHideAbilityWnd () 
{
	showHideWindow( "AbilityWnd");	
}

//showHideLineage2Home


// 인 게임 웹페이지 UI 호출 

// category , "main", "nshop" 두개 현재 사용 중..
function showHideL2InGameWeb (string category, string Message)
{	
	local string strParam ;	
	
	//if ( class'UIAPI_WINDOW'.static.IsShowWindow ( "IngameWebWnd") ) 
	//{
	//	class'UIAPI_WINDOW'.static.HideWindow( "IngameWebWnd") ;		
	//}
	//else 
	//{	
	//}

	ParamAdd(strParam, "Category", category);		
	ParamAdd(strParam, "Message", "");
	ExecuteEvent( EV_InGameWebWnd_Info, strParam  );
}

function OnEvent(int Event_ID, string param)
{
	local int iEffectNumber, level, statusInt;
	local string strParam;

	local string strTargetName;
	local vector vTargetPos;
	local bool bOnlyMinimap;
	//local int nUsePledgeV2Live;//, nUsePledgeV2Classic;

	local GfxDialog GfxDialogScript;

	// 0||1 무료||유료
	local int UserType;

	local int clanID;

	//	if(class'UIAPI_WINDOW'.static.IsShowWindow("NoticeWnd") == false) return;
	
	//언제 오는 이벤트인지 알 수 없음.
	if ( Event_ID == EV_ArriveNewMail )
	{
//		Debug("EV_ArriveNewMail?? 언제오는겨??");
	}
	//새로운 메일이 왔을 때.
	else if ( Event_ID == EV_Notice_Post_Arrived ) //4700
	{			
		//이팩트 넘버
		ParseInt(param, "IdxMail", iEffectNumber);
		createNoticeButton(ENoticeType.TYPE_MAIL, 2074);
	}
	//현재 메일을 볼 수 있는 지역인지 확인.
	else if ( Event_ID == EV_SetRadarZoneCode )
	{
		//메일을 열수 있는 안전지역 상황
		ParseInt( param, "ZoneCode", zonetype );
	}

	//혈맹 아이콘
	else if( Event_ID == EV_PledgeWaitingListAlarm)
	{
		createNoticeButton(ENoticeType.TYPE_PLEDGEALARM, 3068);
	}

	//새로운 퀘스트가 왔을 경우.
	else if( Event_ID == EV_ArriveShowQuest ) //1520
	{
		// SetShowWindow();
		ParseInt(param, "QuestID", RecentlyAddedQuestID);
		ParseInt(param, "QuestLevel", level);

		//Debug("RecentlyAddedQuestID" @ RecentlyAddedQuestID);
		//Debug("level" @ level);
		
		ArriveShowQuest();

		GetPlayerInfo(currentUserInfo);

		// debug("RecentlyAddedQuestID" @ RecentlyAddedQuestID);
		// 각성 관련 퀘스트 ID , 10338 담당자 : 레벨팀 이보은 요청
		// 가 존재 한다면.. 아무것도 안한다.
		// Class=139 부터..8개.4차 전직 , 각성 상태라면..
		//if (QuestTreeWndScript.isQuestIDSearch(10338) || (currentUserInfo.nClassID <= 147 && currentUserInfo.nClassID >= 139) )

		// GD3.5 -> 각성 세분화 이후 방치되었던거 같아서 각성 세분화에 따라 수정
		if (RecentlyAddedQuestID == 10338 || (currentUserInfo.nClassID <= 181 && currentUserInfo.nClassID >= 148 ) || currentUserInfo.nClassID == 188 || currentUserInfo.nClassID == 189 )
		{
			// 별 각성 알람 삭제
			ChangeToAwakenedArrived(false);
		}
		
		

		// 3d 방향 화살표를 출력 하게 한다.
		if ( RecentlyAddedQuestID > 0 && Level > 0 )
		{
			//Target이름 취득
			strTargetName = class'UIDATA_QUEST'.static.GetTargetName(RecentlyAddedQuestID, Level);
			vTargetPos = class'UIDATA_QUEST'.static.GetTargetLoc(RecentlyAddedQuestID, Level);		

			//추가 함
			ParamAdd(strParam, "X", string ( vTargetPos.x ));
			ParamAdd(strParam, "Y", string ( vTargetPos.y ));
			ParamAdd(strParam, "Z", string ( vTargetPos.z ));
			ParamAdd(strParam, "targetName", strTargetName);

			ParamAdd(strParam, "QuestID",  string (RecentlyAddedQuestID));
			ParamAdd(strParam, "QuestLevel",  string (Level));

			ParamAdd(strParam, "questName", class'UIDATA_QUEST'.static.GetQuestName( RecentlyAddedQuestID, Level ));
			CallGFxFunction("RadarMapWnd", "showQuestTargetInfo" , strParam ) ;
			//추가 함
			
			bOnlyMinimap = class'UIDATA_QUEST'.static.IsMinimapOnly(RecentlyAddedQuestID, Level);
			QuestTreeWndScript.curQuestExpand(RecentlyAddedQuestID);
			if (bOnlyMinimap)
			{

				//Debug("Notice1" @ RecentlyAddedQuestID);
				class'QuestAPI'.static.SetQuestTargetInfo( true, false, false, strTargetName, vTargetPos, RecentlyAddedQuestID, level);
			}
			else
			{
				//Debug("Notice2" @ RecentlyAddedQuestID);
				//받으면 바로 확장 될 수 있도록 퀘스트 트리 확장 기능 까지 추가 해야 함.				
				class'QuestAPI'.static.SetQuestTargetInfo( true, true, true, strTargetName, vTargetPos, RecentlyAddedQuestID, level);
			}
		}
		
		/// Debug("quest param" @ param);

	}
	//프리미어 아이템이 왔을 경우.
	else if( Event_ID == EV_PremiumItemAlarm  || Event_ID ==  EV_GoodsInventoryNoti )
	{
		// SetShowWindow();
		PremiumItemAlarm();
	}
	//튜토리얼
	//else if( Event_ID == EV_ArriveNewTutorialQuestion )
	
	else if( Event_ID == EV_ArriveTutorial )
	{
		// SetShowWindow();
		//Debug("EV_ArriveNewTutorialQuestion" @ HtmlString);
		//ParseInt(param, "QuestionID", HtmlString);		
		ArriveNewTutorialQuestion(param);
	}
	//스킬 습득
	else if( Event_ID == EV_SkillLearningNewArrival )
	{
		// SetShowWindow();
		SkillLearningNewArrival();
	}
	//캠페인 알림 아이콘.
	else if( Event_ID == EV_CampaignArrived)
	{
		//SetShowWindow();
		bCam = true;

		CampaignArrived();
	}

	//캠페인 알림 끝
	else if ( Event_ID == EV_CampaignFinish )
	{ 
		ClearCampaignBtn();
	}

	//존 퀘스트 알림 아이콘.
	else if( Event_ID == EV_ZoneQuestArrived)
	{
		// SetShowWindow();
		bZone = true;

		ZoneQuestArrived();
	}
	//이벤트켐페인branch120516
	else if( Event_ID == EV_BR_Event_CampaignArrived)
	{
		// SetShowWindow();
		bEvent = true;
		
		EventCampaignArrived();
	}
	//end of branch
	else if( Event_ID == EV_CallToChangeClass)
	{
		// 5470
		// SetShowWindow();
		
		ParseInt(param, "Class", awakeClassID);
		ParseInt(param, "Immediate", awakeImmediate);
		ParseInt(param, "UserType", UserType);

//		Debug("awakeClassID" @ awakeClassID);
		//무료 과금제를 사용 할 경우 알람창을 보여 줌.
		if ( UserType == 0 )// GetUIUserPremiumLevel() <= 0)
		{
			strParam = "";
			ParamAdd(strParam, "Class", String(awakeClassID) );

			gfxDialogScript = GfxDialog( GetScript("GfxDialog") );
			gfxDialogScript.showGfxDialog("dialogLinkageName", "DualPayDialogStep1", strParam);
		}
		// 만약.. classid 가 0보다 같거나 작다면.. 해당 별 각성 알람을삭제한다
		else if (awakeClassID <= 0)
		{
		}
		else 
		{
			// 별(각성) 알람 아이콘 클릭 한 경우
			if (awakeImmediate == 1)
			{
				strParam = "";
				ParamAdd(strParam, "Class", String(awakeClassID) );
				ParamAdd(strParam, "Immediate", String(awakeImmediate) );

				gfxDialogScript = GfxDialog( GetScript("GfxDialog") );
				gfxDialogScript.showGfxDialog("dialogLinkageName", "AwakeNoticeDialog", strParam);
			}
			// 로그인시 바로 각성 다이얼로그를 보여 주고 싶을때..
			else
			{	
				ChangeToAwakenedArrived(true);
			}
		}
	}

	//리스타스 시 버튼 제거.
	else if( Event_ID == EV_Restart )
	{	
		isGetPremium = false;
		isPrologueGrowTypeState = false;
		removeALLNoticeButton();
	}
	else if( Event_ID == EV_ResolutionChanged )
	{
		// SendScreenSize();
		checkMultiLayOut();
	}
	else if ( Event_ID == EV_CuriousHouseWaitState ) //9310
	{
		CuriousHouseHandle( param );
	}
	//9452 Web진정 알람.
	else if( Event_ID == EV_WebPetitionReplyAlarm ) 
	{
		WebPetitionReplyAlarm();
	}
	else if( Event_ID == EV_EnterSingleMeshZone ) 
	{
		bUseSingleMesh = true;

		if(bUseSingleMesh)
		{
			createNoticeButton(	ENoticeType.TYPE_SINGLEMESHZONE, 3031); // 최적화 제복 끄기
		}
		else 
		{
			createNoticeButton(	ENoticeType.TYPE_SINGLEMESHZONE, 3030); // 최적화 제복 켜기
		}
	}

	else if( Event_ID == EV_ExitSingleMeshZone ) 
	{
		bUseSingleMesh = false;
		// SwitchSingleMeshMode(false);
		// 최적화 제복 아이콘 삭제		
		removeNoticeButton(ENoticeType.TYPE_SINGLEMESHZONE);			
	}

	// 핸디의 블록체커, toolTip : 2445
	else if( Event_ID == EV_BlockStateTeam || Event_ID == EV_BlockStatePlayer) 
	{
		createNoticeButton(	ENoticeType.TYPE_PVPBLOCKCHECKER, 2445); 
	}
	// 지하 콜로세움 상황판toolTip : 2444
	else if( Event_ID == EV_CrataeCubeRecordMyItem ) 
	{
		createNoticeButton(	ENoticeType.TYPE_PVPCRATAECUBE, 2444);
	}
	else if( Event_ID == EV_CrataeCubeRecordBegin ) 
	{
		ParseInt( param, "Status", statusInt);

		if( statusInt == 0 ) 
		{			
			createNoticeButton(	ENoticeType.TYPE_PVPCRATAECUBE, 2444); 
		}
		else if( statusInt == 2 )
		{
			removeNoticeButton(	ENoticeType.TYPE_PVPCRATAECUBE); 
		}
	}
	else if( Event_ID == EV_CrataeCubeRecordRetire ) 
	{
		removeNoticeButton(	ENoticeType.TYPE_PVPCRATAECUBE); 
	}

	//PVP 상황판 toolTip : 2442
	else if( Event_ID == EV_PVPMatchRecord ) 
	{
		ParseInt( param, "CurrentState", statusInt );	
		if( statusInt == 0 ) 
		{
			createNoticeButton(	ENoticeType.TYPE_PVPMATCHRECORD, 2442); 
		}
		else if( statusInt == 2 )
		{
			removeNoticeButton(	ENoticeType.TYPE_PVPMATCHRECORD); 
		}
	}

	// 클레프트 상황판, toolTip : 2443 
	else if( Event_ID == EV_CleftStateTeam || Event_ID == EV_CleftStatePlayer) 
	{
		createNoticeButton(	ENoticeType.TYPE_PVPCLEFT, 2443); 
	}

	// 퀘스트가 새로 올때 현재 퀘스트 알람 아이콘 존재 여부를 체크 한다.
	else if( Event_ID == EV_QuestListEnd )
	{
		QuestTreeWndScript.findNowQuestExist(RecentlyAddedQuestID);
	}

	//branch121212
	else if( Event_ID == EV_PathToAwakeningAlarm )
	{
		ParseInt(param, "Type", PathToAwakeningAlarmType); // 0 None 1 Level
		ParseInt(param, "Value", PathToAwakeningAlarmValue); // type 0일때는 사용안함
		
		createNoticeButton(	ENoticeType.TYPE_PATHTOAWAKENINGALARM, 5178); 
		// PathToAwakeningAlarm();
	}

	else if (Event_ID == EV_ClanInfo)
	{
		ParseInt( param, "ClanID", clanID );

		// 혈맹 정보가 있다면 삭제 시도
		if (clanID > 0) removeNoticeButton(ENoticeType.TYPE_PLEDGEALARM);
	}

	else if ( Event_ID == EV_UpdateUserInfo ) 
	{
		// 어빌리티 포인트를 사용 할 수 있습니다.
		chkAbilityPoint();

		// 혈맹 정보가 있다면 가입 시스템 알림 삭제
		ParseInt( param, "ClanID", clanID );
		if (clanID > 0) removeNoticeButton(ENoticeType.TYPE_PLEDGEALARM);
	}

	else if ( Event_ID == EV_ITEM_AUCTION_UPDATED_BIDDING_INFO ) 
	{
		// 유찰금 찾기
		createNoticeButton(	ENoticeType.TYPE_AUCTION_FAIL, 3500); 
	}
	else if ( Event_ID == EV_FactionLevelUpNotify ) 
	{
		// 세력 레벨 업
		createNoticeButton(	ENoticeType.TYPE_FACTION, 3443); 
	}

	else if ( Event_ID == EV_MonsterBookRewardIcon ) 
	{
		// 몬스터 도감 보상 조건 완료
		createNoticeButton(	ENoticeType.TYPE_MONSTERBOOK, 3511); 
	}	
	//오늘의 할 일
	else if( Event_ID == EV_OneDayRewardCount )
	{	
		createNoticeButtonWithParam(ENoticeType.TYPE_TODOLIST, 3506, param); 
	}
	// 차원 서버로 이동 할떄 오늘의 할일 삭제(클랜)
	else if( Event_ID == EV_GotoWorldRaidServer )
	{		
		// GetINIBool ( "Localize", "UsePledgeV2Live", nUsePledgeV2Live, "L2.ini" );

		// 혈맹 리뉴얼 UI 사용, 차원 서버는 라이브만..
		//if (nUsePledgeV2Live > 0) removeNoticeButton(ENoticeType.TYPE_TODOLIST); 
		// 혈맹 리뉴얼 UI 사용, 차원 서버는 라이브만..
		if(getInstanceL2Util().isClanV2())
			removeNoticeButton(ENoticeType.TYPE_TODOLIST);
	}

	else if( Event_ID == EV_ChangedSubjob )
	{
		handleChangedSubjob( param );
	}

	// 인게임웹 버튼, 2015-11-26 추가	
	if(Event_ID == EV_StateChanged)
	{	
		// 스테이트가 변하고 게이밍스테이트로 들어 갈때마다 팡~! 터지면서 갱신은 될텐데 원하지 않으면 리스타트 할때 끄고 하는 식으로
		// 플래그 변수로 안하게 할 수도 있는데 일단 굳이 할 필요가 있나 해서 넣지 않음.
		if (param == "GAMINGSTATE")
		{
			isPrologueGrowTypeState = getInstanceL2Util().getIsPrologueGrowType ( ) ;
			//Debug ( "EV_StateChanged" @ isPrologueGrowTypeState ) ;
			// 리니지2홈 생성
			if ( bUseL2Button()) 
			{
				// Debug("NoticeButton TYPE_LINEAGE2HOME");
				createNoticeButton(	ENoticeType.TYPE_LINEAGE2HOME, 3471);  // l2홈				
				createNoticeButton(	ENoticeType.TYPE_NSHOPHOME, 3634);     // n샵
			}
		}		
	}
}

function chkAbilityPoint () 
{
	local userinfo userInfo;
	
	GetPlayerInfo ( userInfo ) ;
	//Debug (  "chkAbilityPoint" @ getInstanceUIData().isLevelUP() @ userInfo.nRemainAbilityPoint );

	if (  getInstanceUIData().isLevelUP()  && userInfo.nRemainAbilityPoint > 0)
	{
		//Debug("레벨업, 어빌리티 알림, TYPE_ABILITYPOINT!!!");
		createNoticeButton(	ENoticeType.TYPE_ABILITYPOINT, 3151); 		
	}
}

// 한국, 클래식서버만 나오게
function bool bUseL2Button()
{	
	local ELanguageType Language;	 //branch121212
	local bool flag;

	Language = GetLanguage();
	if( Language == LANG_Korean && !getInstanceUIData().getIsArenaServer() ) flag = true;

	return flag;
}

function toggleWindow(string windowName)
{
	if (!GetWindowHandle(windowName).IsShowWindow())
		GetWindowHandle(windowName).ShowWindow();
	else 
		GetWindowHandle(windowName).HideWindow();
}

/**
 *  PVP 버튼을 클릭 했을때 
 **/ 
function pvpButton(int SelectPVP)
{
	// 블록체커		
	if( SelectPVP == ENoticeType.TYPE_PVPBLOCKCHECKER)
	{
		toggleWindow("BlockCurWnd");		
	}
	// 콜로세움 상황판 
	else if( SelectPVP == ENoticeType.TYPE_PVPCRATAECUBE )
	{		
		if (!GetWindowHandle("KillPointRankWnd").IsShowWindow())
		{
			RequestStartShowCrataeCubeRank();
		}
		toggleWindow("KillPointRankWnd");
	}
	// PVP 상황판 
	else if( SelectPVP == ENoticeType.TYPE_PVPMATCHRECORD )
	{
		toggleWindow("PVPDetailedWnd");
	}
	// 크레프트
	else if( SelectPVP == ENoticeType.TYPE_PVPCLEFT )
	{
		toggleWindow("CleftCurWnd");
	}
}

function CuriousHouseHandle ( string param)
{
	local int HouseState;

	ParseInt(param, "State", HouseState);

	//대기 취소 불가능 상태일 경우 알림 아이콘 취소
	switch ( HouseState ) 
	{
		case 1 :
			createNoticeButton(ENoticeType.TYPE_CURIOUSEHOUSE, 2804);
			//알림 아이콘을 보여 줌
			break;
		case 0 :	
		case 2 :  
		case 3 :
			//eventID = 900;
			// args[1].SetMemberInt( "Num", ENoticeType.TYPE_CURIOUSEHOUSE );//알림의 번호
			// createNoticeButton(ENoticeType.TYPE_PLEDGEALARM);
			removeNoticeButton(ENoticeType.TYPE_CURIOUSEHOUSE);
			//알림 아이콘을 숨킴
			break;		
	}
}

function PledgeAlarm()
{	
	createNoticeButton(ENoticeType.TYPE_PLEDGEALARM, 3068);	
}

//Web진정 시 알람.9452
function WebPetitionReplyAlarm()
{	
	createNoticeButton(ENoticeType.TYPE_WEBPETITIONALARM, 3109);
}

/**
 * 새로운 메일이 왔을 때.
 * 플래시로 보내는 이벤트 넘버 "0"
 * ENoticeType.TYPE_MAIL
 */
function Notice_Post_Arrived()
{
	createNoticeButton(ENoticeType.TYPE_MAIL, 2074);
}

/**
 * 새로운 퀘스트가 왔을 때.
 * 플래시로 보내는 이벤트 넘버 "1"
 * ENoticeType.TYPE_QUEST
 */
function ArriveShowQuest()
{
	createNoticeButton(ENoticeType.TYPE_QUEST, 118);
}

/**
 * 프리미어 아이템이 왔을 경우 상품인벤토리.?
 * 플래시로 보내는 이벤트 넘버 "2"
 * ENoticeType.TYPE_PREM
 */
function PremiumItemAlarm()
{	
	if( IsUseGoodsInvnentory() == false )
	{
		createNoticeButton(ENoticeType.TYPE_PREM, 1738); // 비타민 아이템
		AddSystemMessage(2313); // 비타민 아이템이 도착하였습니다.
	}
	else
	{
		createNoticeButton(ENoticeType.TYPE_PREM, 2680); // 상품이 도착했습니다. 아이콘을 클릭하시면 상품 인벤토리에서 바로 상품을 확인하실 수 있습니다.
	}	
}

/**
 * 스킬 습득
 * 플래시로 보내는 이벤트 넘버 "4"
 * ENoticeType.TYPE_SKILL
 */
function SkillLearningNewArrival()
{
	createNoticeButton(ENoticeType.TYPE_SKILL, 2369);
}

/**
 * 캠페인 습득
 * 플래시로 보내는 이벤트 넘버 "5"
 * ENoticeType.TYPE_CAMPAIGN
 */
function CampaignArrived()
{
	createNoticeButton(ENoticeType.TYPE_CAMPAIGN, 2440);
}


/**
 * 존 퀘스트 습득
 * 플래시로 보내는 이벤트 넘버 "6"
 * ENoticeType.TYPE_ZONE
 */
function ZoneQuestArrived()
{
	createNoticeButton(ENoticeType.TYPE_ZONE, 2441);
}

//branch120516
/**
 * 이벤트 캠페인 습득
 * 플래시로 보내는 이벤트 넘버 "7"
 * ENoticeType.TYPE_EVENTCAMPAIGN
 */
function EventCampaignArrived()
{
	createNoticeButton(ENoticeType.TYPE_EVENTCAMPAIGN, 5143);
}
//end of branch


// 이벤트 정보 버튼 보이기
function EventInfoArrived()
{	
	createNoticeButton(ENoticeType.TYPE_EVENT_INFO, 3004);	
}

// 이벤트 정보 버튼 삭제
function hideNoticeButton_EventInfo()
{	
	removeNoticeButton(ENoticeType.TYPE_EVENT_INFO);	
}


//캠페인 버튼 삭제.
function ClearCampaignBtn()
{
	//Debug("bCam>>>>>>>>>" $ string(bCam));
	if( bCam == true )
	{
		removeNoticeButton(int(ENoticeType.TYPE_CAMPAIGN));

		bCam = false;
	}
}

//존 퀘스트 버튼 삭제.
function ClearZoneQuestBtn()
{
	if( bZone == true )
	{
		removeNoticeButton(int(ENoticeType.TYPE_ZONE));

		bZone = false;
	}
}

//branch121212
/**
 * 이벤트 캠페인 습득
 * 플래시로 보내는 이벤트 넘버 "10"
 * ENoticeType.TYPE_PATHTOAWAKENINGALARM
 */
function PathToAwakeningAlarm()
{
	// 플래시 타입 데이타 인스턴스 생성
	AllocGFxValues(args, 2);		
	AllocGFxValue(invokeResult);

	// 알림 생성 : 이벤트 번호 10번
	args[0].SetInt( ENoticeType.TYPE_PATHTOAWAKENINGALARM );
	CreateObject(args[1]);
	
	args[1].SetMemberInt( "toolTipNum", 5178 ); //시스템 스트링 5152  PathToAwakening
	
	Invoke( "_root.onEvent", args, invokeResult );

	DeallocGFxValue( invokeResult );
	DeallocGFxValues( args );
}
//end of branch


//이벤트 캠페인 버튼 삭제.
//branch120516
function ClearBRCampaignBtn()
{
	if( bEvent == true )
	{
		removeNoticeButton(int(ENoticeType.TYPE_EVENTCAMPAIGN));

		bEvent = false;
	}
}
//end of branch

/**
 * 
 * 각성 알람 
 * 
 */
function ChangeToAwakenedArrived(bool bOnOff )
{
	// SetShowWindow();

	if (bOnOff)
	{
		//CallGFxFunction("noticeWnd", String(ENoticeType.TYPE_AWAKENED), "toolTipNum=" $ string(2491));
		createNoticeButton(ENoticeType.TYPE_AWAKENED, 2491);
	}
	else
	{
		removeNoticeButton(int(ENoticeType.TYPE_AWAKENED));
	}
}

//상품 인벤토리 열기
function HandleShowProductInventory()
{
	local WindowHandle win;	
	win = GetWindowHandle( "ProductInventoryWnd" );

	if( ! win.IsShowWindow() )
	{
		win.ShowWindow();
		win.SetFocus();
	}
}

function SetShowWindow()
{
	//branch GD35_0828 2014-2-7 luciper3 - 게임상태일때만 보여준다. 훈련소 상태 때문에 수정함.
	local bool bStateCheck;

	bStateCheck = GetGameStateName() == "GAMINGSTATE";
	//end of branch

	if( IsShowWindow() == false && bStateCheck )
	{
		ShowWindow();
	}	
}

function OnEnterState( name a_PreStateName )
{	
	SetShowWindow();
}

// 숏컷 위치에 따라서, 알림 위치 변경
function checkMultiLayOut()
{
	local int tmpInt ;
	GetINIInt ( "ShortcutWnd", "v", tmpInt, "WindowsInfo.ini");
	if ( bool ( tmpInt ) )//GetOptionBool( "Game", "IsShortcutWndVertical" ))
	{
		setMultiLayOut(false);
	}	
	else
	{			
		setMultiLayOut(true);
	}
}

function setMultiLayOut(bool flag)
{
	if (flag)
	{
		// 숏컷 가로, 여러줄 알림
		SetAnchor("", EAnchorPointType.ANCHORPOINT_BottomRight, EAnchorPointType.ANCHORPOINT_TopLeft, -47, -150 );	
		CallGFxFunction("noticeWnd", LAYOUT_MULTILINE, "");			
	}	
	else
	{			
		// 숏컷 세로, 한줄 알림
		SetAnchor("", EAnchorPointType.ANCHORPOINT_BottomRight, EAnchorPointType.ANCHORPOINT_TopLeft, -205, -64 );					
		CallGFxFunction("noticeWnd", LAYOUT_ONELINE, "");
	}
}

/**
 * 튜토리얼 , 개선판 (특수 타입) 카운팅 되는..
 * 플래시로 보내는 이벤트 넘버 "3"
 * ENoticeType.TYPE_TUTORIAL
 */

function ArriveNewTutorialQuestion(string param)
{
	local int toolTipNum;

	ParseInt(param, "toolTipNum", toolTipNum);

	// param 에 toolTipNum 이 없으면.. 넣어줌.
	if (toolTipNum <= 0) 
	{
		// 튜토리얼 툴팁 표시
		toolTipNum = 448;
	}

	createNoticeButtonWithParam(ENoticeType.TYPE_TUTORIAL, toolTipNum, param); 
}

// 알림 버튼 생성, 삭제, 전체 삭제
function createNoticeButton(int nType, int nTooltipString )
{
	local string paramStr;	
	
	if ( checkIisPrologueGrowType( nType ) ) return;

	// 혈맹 리뉴얼 버전은 오늘의 할일(클랜버전)을 차원서버에서 알림을 생성하지 않음.
	//GetINIBool ( "Localize", "UsePledgeV2Live", nUsePledgeV2Live, "L2.ini" );
	
	//if (nUsePledgeV2Live > 0 && IsPlayerOnWorldRaidServer() && nType == ENoticeType.TYPE_TODOLIST) return;
	if (getInstanceL2Util().isClanV2() && IsPlayerOnWorldRaidServer() && nType == ENoticeType.TYPE_TODOLIST) return;

	ParamAdd(paramStr, "toolTipNum", string(nTooltipString));
	CallGFxFunction("noticeWnd", String(nType), paramStr);
}

// 알림 버튼 생성, 삭제, 전체 삭제
function createNoticeButtonWithParam(int nType, int nTooltipString, string paramStr)
{
	if ( checkIisPrologueGrowType( nType ) ) return;

	// 혈맹 리뉴얼 버전은 오늘의 할일(클랜버전)을 차원서버에서 알림을 생성하지 않음.
	//GetINIBool ( "Localize", "UsePledgeV2Live", nUsePledgeV2Live, "L2.ini" );
	
	//if (nUsePledgeV2Live > 0 && IsPlayerOnWorldRaidServer() && nType == ENoticeType.TYPE_TODOLIST) return;
	if (getInstanceL2Util().isClanV2() && IsPlayerOnWorldRaidServer() && nType == ENoticeType.TYPE_TODOLIST) return;

	ParamAdd(paramStr, "toolTipNum", string(nTooltipString));
	//Debug( "createNoticeButtonWithParam" @ nTooltipString @ paramStr) ;
	CallGFxFunction("noticeWnd", String(nType), paramStr);
}

function removeNoticeButton(int nType)
{
	local string paramStr;

	if(IsShowWindow()) 
	{
		ParamAdd(paramStr, "type", string(nType));
		CallGFxFunction("noticeWnd", NOTICEBUTTON_DELETE, paramStr);
	}
}

function removeALLNoticeButton()
{
	//SetShowWindow();
	if(IsShowWindow()) CallGFxFunction("noticeWnd", NOTICEBUTTON_DELETEALL, "");
}

// 퀘스트 	
function hideNoticeButton_QUEST()
{
	removeNoticeButton(ENoticeType.TYPE_QUEST);
}

// 블록체커	
function hideNoticeButton_PVPBLOCKCHECKER()
{
	removeNoticeButton(ENoticeType.TYPE_PVPBLOCKCHECKER);
}

// 콜로세움 상황판 
function hideNoticeButton_PVPCRATAECUBE()
{
	removeNoticeButton(ENoticeType.TYPE_PVPCRATAECUBE);
}

// PVP 상황판 
function hideNoticeButton_PVPMATCHRECORD()
{
	removeNoticeButton(ENoticeType.TYPE_PVPMATCHRECORD);
}

// 크레프트 상황판 
function hideNoticeButton_PVPCLEFT()
{
	removeNoticeButton(ENoticeType.TYPE_PVPCLEFT);
}

// 캠패인
function hideNoticeButton_CAMPAIGN()
{
	removeNoticeButton(ENoticeType.TYPE_CAMPAIGN);
}


// 존 퀘스트
function hideNoticeButton_ZONE()
{
	removeNoticeButton(ENoticeType.TYPE_ZONE);
}


/* ////////////////////////////////////////////////////////////////////////////////////////////////////
 * 프롤로그 전직  
 */////////////////////////////////////////////////////////////////////////////////////////////////////
// 1. 혈맹 초대, 2. 엔샾, 3. 이벤트, 4. BM 상품 인벤토리 ( 상품 있을 시 ) 			
function handleChangedSubjob( string param ) 
{
	local bool tmpIsPrologueGrowTypeState ;
	local EventInfoWnd script;
	local UserInfo info ;
		
	tmpIsPrologueGrowTypeState = getisPrologueGrowTypeState( param ) ;
	if ( tmpIsPrologueGrowTypeState != isPrologueGrowTypeState )
	{
		isPrologueGrowTypeState = tmpIsPrologueGrowTypeState;
		if ( !isPrologueGrowTypeState ) 
		{	
			// 이벤트			
			script = EventInfoWnd ( GetScript ("EventInfoWnd"));
			if ( script.hasNoticeIcon ) EventInfoArrived();

			// 혈맹 초대
			if ( GetPlayerInfo ( info ) )			
				if ( info.nClanID <= 0 ) createNoticeButton(ENoticeType.TYPE_PLEDGEALARM, 3068) ;

			// 엔샾
			if(bUseL2Button())
				createNoticeButton(ENoticeType.TYPE_NSHOPHOME, 3634) ;

			// 프리미엄 알람
			if ( isGetPremium )  PremiumItemAlarm ();
		}		
	}
}

function bool getisPrologueGrowTypeState ( string param ) 
{
	local int currentClassID ;

	if ( param != "" )  ParseInt(param, "CurrentSubjobClassID", currentClassID) ;
	return getInstanceL2Util().getIsPrologueGrowType( currentClassID );
}

function bool checkIisPrologueGrowType ( int nType ) 
{	
//	Debug ( "checkIisPrologueGrowType" @ isPrologueGrowTypeState ) ;
	if ( IsPrologueGrowTypeState ) //getInstanceL2Util().getIsPrologueGrowType( ) ) 
		switch ( nType ) 
		{				
			case ENoticeType.TYPE_PREM :            // 프리미엄 상품
				isGetPremium = true ;	
			case ENoticeType.TYPE_TUTORIAL :
			case ENoticeType.TYPE_PLEDGEALARM :     // 혈맹알람
			case ENoticeType.TYPE_EVENT_INFO :      // 이벤트 정보 28
			case ENoticeType.TYPE_NSHOPHOME :       // N샵 29			
			return true ;
		}

	return false;
}



///**
// *  OnFocus
// *  포커스를 잃으면 우 클릭 메뉴 삭제 하도록 되어 있음
// **/
//function OnFocus(bool bFlag, bool bTransparency)
//{
//	Debug("포커스uc" @ bFlag);
//	Debug("포커스bTransparency" @ bTransparency);
//}

/*
function OnShow()
{
	if(IsActivedZoneQuestExist())
	{
		ZoneQuestBtn.ShowWindow();
	}
	else
	{
		ZoneQuestBtn.HideWindow();
	}
	
	if(IsActivedCampaignExist())
	{
		CampaignBtn.ShowWindow();
	}	
	else
	{
		CampaignBtn.HideWindow();
	}
	
	//branch120516
	if(IsActivedBRCampaignExist())
	{
		BR_CampaignBtn.ShowWindow();
	}
	else
	{
		BR_CampaignBtn.HideWindow();
	}
	//end of branch
}
*/
defaultproperties
{
}
