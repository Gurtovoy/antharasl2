/**
 *   ContextMenu 우클릭 메뉴
 *   
 *   특이한 구성으로, 오른쪽 클릭을 하면 타겟을 잡도록 하는 기능 때문에
 *   타겟UI와 연동해서 작업이 되었음
 **/

class ContextMenu extends L2UIGFxScript;

const SPECIALTYPE_CHAT_ADDBLOCK = 1;

// 업적
const ACHIEVEMENT          = 1;		
// 개인상점 - 판매
const PRIVATESHOP_SELL     = 2;
// 개인상점 - 일괄판매
const PRIVATESHOP_ALLSELL  = 3;		
// 개인상점 - 구매
const PRIVATESHOP_BUY      = 4;
// 상점 닫기
const PRIVATESHOP_CLOSE    = 5;		
// 변신 해제 
const TRANSFORM_CANCEL     = 6;
// 인스턴스 존 이력
const INSTANCEZONE_HISTORY = 7;
// 어시스트
const ASSIST               = 8;		
// 귓속말
const WHISPER              = 9;		
// 혈맹 초대
const INVITE_CLAN          = 10;		
// 친구 초대 요청
const INVITE_FRIEND        = 11;
// 파티 초대 
const INVITE_PARTY         = 12;
		
// 징표
const TARGET_TOKEN1 = 13;
const TARGET_TOKEN2 = 14;
const TARGET_TOKEN3 = 15;
const TARGET_TOKEN4 = 16;

// 펫 탑승
const PET_ACTION_RIDE            = 17;
// 펫 이동모드 전환
const PET_ACTION_CHANGE_MOVEMODE = 18;
// 펫 돌리기
const PET_ACTION_RETURN          = 19;
// 수동 성향
const SUMMON_DISPOSITION_PASSIVE = 20;
// 방어 성향
const SUMMON_DISPOSITION_DEFENSE = 21;
// 소환 해제
const SUMMON_RETURN              = 25;

// 내리기 (탈것)
const GETOFF                     = 22;
// 교환
const TRADE                      = 23;
// 타이틀
const TITLE                      = 24;
// 라인
const LINE                       = 10000;		

// 파티 (해체, 탈퇴, 추방, 파티장 위임)
const PARTY_BREAK_UP             = 26;
const PARTY_LEAVE                = 27;
const PARTY_BANISH               = 28;
const PARTY_LEADER_CHANGE        = 29;

// 일반 공방 
const MANUFACTURE_COMMON         = 30;

// 드워프 공방
const MANUFACTURE_DWARF          = 31;		

// 탑승형 변신 해제
const TRANSFORM_RIDE_CANCEL      = 32;

// 채팅창 광고 차단 ( 해외 )
const BLOCKLIST_AD               = 33;

// 채팅창 비매너유저 차단 ( 해외 )
const BLOCKLIST_BADMANNER        = 34;

// 우클릭 메뉴 이벤트 정보
struct ContextMenuInfo
{
	var string Name;
	var int ID;
	var int X;
	var int Y;	
};

// UI
var InviteClanPopWnd InviteClanPopWndScript;
var InviteClanPopWndClassic InviteClanPopWndClassicScript;
var TargetStatusWnd  TargetStatusWndScript;
var PrivateShopWnd   PrivateShopWndScript;
var SummonedWnd      SummonedWndScript;

// struct
var ContextMenuInfo m_contextMenuInfo;

/**
 *  OnRegisterEvent
 **/
function OnRegisterEvent()
{	
	RegisterGFxEvent(EV_ContextMenu);

	RegisterEvent(EV_Restart);
}

/**
 *  OnEvent
 **/
function OnEvent(int Event_ID, string param)
{
//	Debug(" param : " @ param);

	
	if (Event_ID == EV_Restart )
	{
		//Debug("EV_Restart");
		clearInfo();
	}
}

/**
 *  OnLoad
 **/
function OnLoad()
{	
	registerState("ContextMenu", "GamingState" );
	SetHavingFocus(false);	
	SetAnchor("", EAnchorPointType.ANCHORPOINT_TopLeft, EAnchorPointType.ANCHORPOINT_TopLeft, 0, 0 );	
	setDefaultShow(true);

	// UC Script
	PrivateShopWndScript   = PrivateShopWnd(GetScript("PrivateShopWnd"));
	InviteClanPopWndScript = InviteClanPopWnd(GetScript("InviteClanPopWnd"));
	InviteClanPopWndClassicScript = InviteClanPopWndClassic(GetScript("InviteClanPopWndClassic"));
	SummonedWndScript      = SummonedWnd(GetScript("SummonedWnd"));
	TargetStatusWndScript  = TargetStatusWnd(GetScript("TargetStatusWnd"));
}

/**
 *  OnFlashLoaded
 **/
function OnFlashLoaded()
{
	SetRenderOnTop(true);
}

/**
 *  OnHide
 **/
function OnHide()
{
	clearInfo();
	SetHavingFocus(false);
}

/**
 *  우 클릭 메뉴 이벤트 직접 발생 Event
 **/
function execContextEvent(string creatureName,int creatureID,int locX,int locY,optional int specialType,optional string etcParam)
{
	local string strParam;

	paramAdd(strParam, "ID", String(creatureID));
	paramAdd(strParam, "Name", creatureName);
	paramAdd(strParam, "X", String(locX));
	paramAdd(strParam, "Y", String(locY));
	paramAdd(strParam,"SpecialType",String(specialType));
	paramAdd(strParam,"EtcParam",etcParam);

	ExecuteEvent(EV_ContextMenu, strParam);

	//Debug("EV_ContextMenu : " @ strParam);
}

/**
 *  SWF -> UC 실행
 **/
function onCallUCFunction( string functionName, string param )
{
	switch ( functionName )
	{
		case "processCommand" :
			//nCanUseAP = int(param);
			processCommand(param);
			break;

		case "contextMenuEventInfo" :
			saveInfo(param);			
			break;

		//case "closeContextMenu" :
		//	if (GetWindowHandle("TargetStatusWnd").IsShowWindow()) 
		//	{
		//		// Debug("타겟한테 포커스 주기 ");
		//		GetWindowHandle("TargetStatusWnd").SetFocus();
		//	}

		//	break;

	}
}

/**
 *  컨텍스트 이벤트 상태 저장
 **/
function saveInfo(string param)
{
	// Debug("상태 저장" @ param);
	ParseString (param, "Name", m_contextMenuInfo.Name );
	ParseInt (param, "ID", m_contextMenuInfo.ID );	
	ParseInt (param, "X", m_contextMenuInfo.X );
	ParseInt (param, "Y", m_contextMenuInfo.Y );
	

	// Debug("상태 m_contextMenuInfo.Name" @ m_contextMenuInfo.Name);
}

/**
 *  컨텍스트 이벤트 상태 초기화
 **/
function clearInfo()
{
	// Debug("상태 클리어");
	m_contextMenuInfo.Name = "";
	m_contextMenuInfo.ID = 0;
	m_contextMenuInfo.X = 0;
	m_contextMenuInfo.Y = 0;	
}

/**
 * 현재 눌러진 컨텍스트 메뉴 이벤트의 정보를 리턴
 **/ 
function ContextMenuInfo getContextEventInfo()
{
	return m_contextMenuInfo;
}

/**
 *  눌러진 컨텍스트 메뉴가 있으면 메뉴를 생성한다.
 **/
function makeContextMenu()
{
	if (m_contextMenuInfo.ID > 0)
	{
		// Debug("m_contextMenuInfo.Name" @ m_contextMenuInfo.Name);

		execContextEvent(m_contextMenuInfo.Name, m_contextMenuInfo.ID, m_contextMenuInfo.X, m_contextMenuInfo.Y);
	}
}

/**
 *  컨텍스트 명령 실행 
 **/
function processCommand(string param)
{
	local int menuItemType, targetID;
	local string userName;
	local UserInfo targetUserInfo;
	local ItemInfo skillInfo;
	local string chatMsg;
//	Debug("UC 실행 버튼" @ param);

	// 잘못된 targetID 라면.. 정지.
	// if (targetID <= 0) return;

	ParseInt (param, "menuItemType", menuItemType );
	ParseInt (param, "ID", targetID );	
	ParseString (param, "Name", userName );
	ParseString(param,"ChatMsg",chatMsg);

	switch (menuItemType)
	{

		case ACHIEVEMENT :   // 업적, 명예 (아직 포함되지 않음)
			 break;

		case PRIVATESHOP_SELL :   
			 ExecuteCommandFromAction("vendor");
			 break;

		case PRIVATESHOP_ALLSELL :   
			 ExecuteCommandFromAction("packagevendor");
			 break;

		case PRIVATESHOP_BUY :   
			 ExecuteCommandFromAction("buy");			 
			 break;

		case PRIVATESHOP_CLOSE : 			 
			 //PrivateShopWndScript.OnClickButton("StopButton");
			 PrivateShopWndScript.contextMenuQuit();
			 break;

		case TRANSFORM_RIDE_CANCEL : // (탑승형) 변신해제
			 // 스킬 아이디 (변신 해제)
			 skillInfo.ID.ClassID = 9210;
			 skillInfo.ID.ServerID = 0;
			 UseSkill(skillInfo.ID, int(EShortCutItemType.SCIT_SKILL));
			 break;

		case TRANSFORM_CANCEL :   
			 // 스킬 아이디 (변신 해제)
			 skillInfo.ID.ClassID = 619;
			 skillInfo.ID.ServerID = 0;
			 
			 UseSkill(skillInfo.ID, int(EShortCutItemType.SCIT_SKILL));
			 break;

		case INSTANCEZONE_HISTORY :   
			 RequestInzoneWaitingTime();
			 break;

		case ASSIST :			 
			 GetUserInfo(targetID, targetUserInfo);

//			 Debug("targetUserInfox" @ targetUserInfo.Loc.x);
			 //Debug("targetUserInfoy" @ targetUserInfo.Loc.y);

			 RequestAssist(targetID, targetUserInfo.loc);  

			 break;

		case WHISPER :
			 whisperToUser(userName);
			 break;

		case INVITE_CLAN :
			// 클래식
			 if ( getInstanceUIData().getisClassicServer() )
			 {
				//GetINIBool ( "Localize", "UsePledgeV2Classic", nUsePledgeV2Classic, "L2.ini" );

				// 혈맹 리뉴얼 UI 사용
				if (getInstanceL2Util().isClanV2())
					RequestClanAskJoinByName(userName, 0);
				else
					InviteClanPopWndClassicScript.showByPersonalConnectionsWndUsingUserName(userName);
			 }
			 else
			 {
				// 라이브
				//GetINIBool ( "Localize", "UsePledgeV2Live", nUsePledgeV2Live, "L2.ini" );

				// 혈맹 리뉴얼 UI 사용
				if (getInstanceL2Util().isClanV2())
					RequestClanAskJoinByName(userName, 0);
				else
					InviteClanPopWndScript.showByPersonalConnectionsWndUsingUserName(userName);
			 }

			 break;

		case INVITE_FRIEND : 
			 class'PersonalConnectionAPI'.static.RequestAddFriend(userName);						
			 break;

		case INVITE_PARTY :  
//			 Debug("userName" @ userName);
			 RequestInviteParty(userName);
			 break;

		case TARGET_TOKEN1 :   
			 ExecuteCommandFromAction("tacticalsign1");
			 break;

		case TARGET_TOKEN2 :   
			 ExecuteCommandFromAction("tacticalsign2");
			 break;

		case TARGET_TOKEN3 :   
			 ExecuteCommandFromAction("tacticalsign3");
			 break;

		case TARGET_TOKEN4 :   
			 ExecuteCommandFromAction("tacticalsign4");
			 break;

		case PET_ACTION_RIDE :  
			 ExecuteCommandFromAction("mountdismount");
			 break;

		case PET_ACTION_CHANGE_MOVEMODE :  
			 ExecuteCommandFromAction("pethold"); 
			 break;

		case PET_ACTION_RETURN :  
			 ExecuteCommandFromAction("petrevert"); 			 
//			 Debug("petrevert");
			 break;

		case SUMMON_DISPOSITION_PASSIVE :   
			 //SummonedWndScript.OnClickItem("SummonedActionWnd2", 0);
			 DoAction( class'UICommonAPI'.static.GetItemID(1104) ); // 수동
			 break;

		case SUMMON_DISPOSITION_DEFENSE : 
			 // SummonedWndScript.OnClickItem("SummonedActionWnd2", 1);
			 DoAction( class'UICommonAPI'.static.GetItemID(1103) ); // 방어
			 break;

		case SUMMON_RETURN :   
//			 Debug("unsummon");
			 ExecuteCommandFromAction("unsummon"); 
			 break;

		case TRADE :   
			 ExecuteCommandFromAction("trade"); 
			 break;

		case GETOFF :   
			 ExecuteCommandFromAction("mountdismount"); 
			 break;

		case PARTY_BREAK_UP :   
			 // 현재 구현이 안되어 있음, 중국 쪽은 되어 있음;
			 // ExecuteCommandFromAction("partybreakup");
			 break;

		case PARTY_LEAVE :   
			 ExecuteCommandFromAction("partyleave"); 
			 break;

		case PARTY_BANISH :   
			 ExecuteCommandFromAction("partydismiss"); 
			 break;

		case PARTY_LEADER_CHANGE :
			 ExecuteCommandFromAction("leaderchange"); 
			 break;

		case MANUFACTURE_COMMON :   
			 ExecuteCommandFromAction("manufacture2"); 
			 break;

		case MANUFACTURE_DWARF :   			 
			 ExecuteCommandFromAction("manufacture"); 
			 break;

			 // 해외 전용, 채팅창 차단 기능
		case BLOCKLIST_AD:
			RequestBlockListForAD(userName,chatMsg);
			Debug("-> RequestBlockListForAD" @ userName);
			Debug("-> chatMsg" @ chatMsg);
			break;

		case BLOCKLIST_BADMANNER:
			Debug("-> RequestAddBlock" @ userName);
			//class'PersonalConnectionAPI'.static.RequestUpdateBlockMemo(userName, GetSystemString(5853));
			class'PersonalConnectionAPI'.static.RequestAddBlock(userName);
			break;
	}
}

//귓속말하기
function whisperToUser(string userName)
{
	local ChatWnd chatWndScript;
	if (userName != "")
	{
		//callGFxFunction("ChatMessage", "sendWhisper", userName);
		//클라쪽 귓속말 확인
		chatWndScript = ChatWnd(GetScript("ChatWnd"));
		chatWndScript.setChatEditBox("\"" $ userName $ " ");
	}
}

/**
 *  우 클릭 메뉴가 열려 있나?
 **/
function bool isShowContextMenu()
{
	local bool bShow;
	local array<GFxValue> args;
	local GFxValue invokeResult;

	AllocGFxValues(args, 1);
	args[0].setbool(false);

	AllocGFxValue(invokeResult);
		
	Invoke("_root.isShowContextMenu", args, invokeResult);
	bShow = invokeResult.GetBool();

	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);

	return bShow;
}

/**
 *  OnFocus
 *  포커스를 잃으면 우 클릭 메뉴 삭제 하도록 되어 있음
 **/
function OnFocus(bool bFlag, bool bTransparency)
{
	local array<GFxValue> args;
	local GFxValue invokeResult;
	// local UserInfo userInfo;

	//if (GetTargetInfo(userInfo))
	//{
	//	Debug("타겟이 있는 상태");
	//}
	//else
	//{
	//	Debug("타겟이 없는 상태");
	//}

	AllocGFxValues(args, 2);	
	args[0].setbool(bflag);
	args[1].setbool(bTransparency);
	AllocGFxValue(invokeResult);

	Invoke("_root.onFocus", args, invokeResult);

	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);


	if (!bFlag) SetHavingFocus(false);
}
defaultproperties
{
}
