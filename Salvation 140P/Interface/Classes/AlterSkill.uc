//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : AlterSkill  ( 발동 스킬 ) - SCALEFORM UI
//
//------------------------------------------------------------------------------------------------------------------------
class AlterSkill extends L2UIGFxScript;

const FLASH_WIDTH  = 800;
const FLASH_HEIGHT = 600;

var int currentScreenWidth, currentScreenHeight;

function OnRegisterEvent()
{
	// registerEvent(EV_ReceiveOlympiadGameList);
	registerEvent(EV_ActivateAlterSkill);
	registerGFxEvent(EV_ActivateAlterSkill);
	registerGFxEvent(EV_InActivateAlterSkill);
	registerGFxEvent(EV_UseActiveAlterSkill);
	registerGFxEvent(EV_Restart);
	
	

	// Debug("AlterSkill  OnRegisterEvent =============> ");	
}

function OnLoad()
{
	registerState( "AlterSkill", "GamingState" );	
	//	SetAlwaysFullAlpha( true );

	SetContainerHUD( WINDOWTYPE_NONE, 0);
	AddState("GAMINGSTATE");

	//선언하면 처음 부터 보여지고 시작 함	
	SetDefaultShow(true);

	SetHavingFocus( false );
	SetAnchor("", EAnchorPointType.ANCHORPOINT_BottomRight, EAnchorPointType.ANCHORPOINT_TopLeft, 0,0);//116, -3);
}

function OnShow()
{
	// Debug("AlterSkill!!!! onShow");
}

function OnFlashLoaded()
{
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_UseSkill);
}

function OnHide()
{
}

function OnCallUCLogic( int logicID, string param )
{
	// SetNextFocus();
	// 닫을때, 포커스 넘겨주기 
	if (logicID == 1)
	{
		SetNextFocus();
		HideWindow();
	}
}

// skillID=1 level=1 time=5 altFlag=1 ctrlFlag=1 shiftFlag=0 totalCoolTime=10 remainCoolTime=10 mainKey=a
// 5130
function OnEvent(int Event_ID, string param)
{
	// local int xLoc, yLoc;
	/*
	local int skillID;

	// 실제 실행할 스킬 아이디
	// local int originalSkillID;
	local int skillLevel;
	local int sec;

	local int totalCoolTime;
	local int remainCoolTime;

	
	local int altFlag;
	local int ctrlFlag;
	local int shiftFlag;


	local string mainKey;

	local array<GFxValue> args;

	local GFxValue invokeResult;


	// 스킬 텍스쳐 스트링을 받기 위한 itemID
	local ItemID itemID;
*/

	local string mainKey;

	// 해상도 
	// local int CurrentMaxWidth; 
	// local int CurrentMaxHeight;
	// end

	// Debug("Show AlterSkill" @ Event_ID);
	// Debug(" param : " @ param);

	if ( Event_ID == EV_ActivateAlterSkill )
	{
		ParseString(param, "mainKey"   , mainKey);

		callGfxFunction ( "AlterSkill", "setShowShortKey", string(mainKey!="") ) ;

		// 현재 해상도를 얻는다.
		// GetCurrentResolution (CurrentMaxWidth, CurrentMaxHeight);	

		/*
		ShowWindow();


		/////////// 
		// 기존 얼터 스킬이 존재 할수도 있으니 삭제 시도..

		// 플래시 타입 데이타 인스턴스 생성
		AllocGFxValues(args, 2);		
		AllocGFxValue(invokeResult);

		// 발동 스킬 삭제 : 이벤트 번호 3번
		args[0].SetInt(3);
		CreateObject(args[1]);

		Invoke("_root.onEvent", args, invokeResult);

		DeallocGFxValue(invokeResult);
		DeallocGFxValues(args);

		/////////////////

		// 스킬 정보
		ParseInt(param,"skillID"        , skillID);
		// ParseInt(param,"originalSkillID", originalSkillID);
		ParseInt(param,"level"          , skillLevel);
		ParseInt(param,"time"           , sec);

		// 단축키 
		ParseInt(param, "altFlag"   , altFlag);
		ParseInt(param, "ctrlFlag"  , shiftFlag);
		ParseInt(param, "shiftFlag" , shiftFlag);

		// 스킬 재사용 지연 시간 (초)
		ParseInt(param, "totalCoolTime"  , totalCoolTime);
		ParseInt(param, "remainCoolTime" , remainCoolTime);

		ParseString(param, "mainKey"   , mainKey);

		// 스킬 아이디 구조 생성
		itemID.ClassID = skillID;
		itemID.ServerID = 0;

		// 스킬 아이콘 얻기 (현재 사용하지 않기로 했음)
		// IconName = class'UIDATA_SKILL'.static.GetIconName( itemID, skillLevel );

		// 플래시 타입 데이타 인스턴스 생성
		AllocGFxValues(args, 2);		
		AllocGFxValue(invokeResult);

		// 발동 스킬 생성 : 이벤트 번호 1번
		args[0].SetInt(1);
		
		CreateObject(args[1]);
				
		// 아이콘 타입, 1은 발, 2는 주먹 
		// 이쪽에서 하드 코딩을 해야 함..
		args[1].SetMemberInt("iconType", 1);

		// 화면에 나오는 초
		args[1].SetMemberInt("sec", sec);

		// 스킬 재사용 지연 시간 (초)
		args[1].SetMemberInt("totalCoolTime" , totalCoolTime);
		args[1].SetMemberInt("remainCoolTime", remainCoolTime);
	
		// 스킬 아이디
		args[1].SetMemberInt("skillID"        , skillID);
		// args[1].SetMemberInt("originalSkillID", originalSkillID);

		// 단축키
		args[1].SetMemberBool("altFlag"   , bflag(altFlag));
		args[1].SetMemberBool("ctrlFlag"  , bflag(ctrlFlag));
		args[1].SetMemberBool("shiftFlag" , bflag(shiftFlag));
		args[1].SetMemberString("mainKey" , mainKey);
		
		
		// 현재 해상도를 얻는다.
		GetCurrentResolution (currentScreenWidth, currentScreenHeight);	

		// 화면 위치
		// 가로 60% , 세로 중앙
		//args[1].SetMemberInt("x"  , (FLASH_WIDTH  / 1.66));
		//args[1].SetMemberInt("y"  , (FLASH_HEIGHT / 2) );
		
		// args[1].SetMemberInt("x"  , (FLASH_WIDTH / 100) * 70);
		// args[1].SetMemberInt("y"  , (FLASH_HEIGHT / 100) * 60);

		// args[1].SetMemberInt("x"  ,(currentScreenWidth / 100) * 60);
		// args[1].SetMemberInt("y"  ,(currentScreenHeight / 100) * 50);

		Invoke("_root.onEvent", args, invokeResult);

		DeallocGFxValue(invokeResult);
		DeallocGFxValues(args);

	}
	// 삭제 모드
	else if ( Event_ID == EV_InActivateAlterSkill )
	{
		// 플래시 타입 데이타 인스턴스 생성
		AllocGFxValues(args, 2);		
		AllocGFxValue(invokeResult);

		// 발동 스킬 삭제 : 이벤트 번호 3번
		args[0].SetInt(3);
		CreateObject(args[1]);

		Invoke("_root.onEvent", args, invokeResult);

		DeallocGFxValue(invokeResult);
		DeallocGFxValues(args);
	}
	// 스킬이 성공적으로 실행 되었다면 다음 쿨 타임 (스킬 재사용 지연 시간)을 받아서 돌린다.	
	else if ( Event_ID == EV_UseActiveAlterSkill )
	{

		// 스킬 id
		// ParseInt(param,"skillID"     , skillID);
		// 스킬 쿨 타임
		ParseInt(param,"totalCoolTime" , totalCoolTime);
		// 현재 까지 남은 스킬 쿨 타임
		ParseInt(param,"remainCoolTime", remainCoolTime);

		// 플래시 타입 데이타 인스턴스 생성
		AllocGFxValues(args, 2);		
		AllocGFxValue(invokeResult);

		// 현재 발동중인 스킬이 성공적으로 사용했다면 재사용 딜레이 표현 : 이벤트 번호 4번
		// 화면상에 발동 스킬이 나와 있는 상황에서 사용..
		args[0].SetInt(4);
		CreateObject(args[1]);

		args[1].SetMemberInt("totalCoolTime"  , totalCoolTime);
		args[1].SetMemberInt("remainCoolTime"  , remainCoolTime);

		Invoke("_root.onEvent", args, invokeResult);

		DeallocGFxValue(invokeResult);
		DeallocGFxValues(args);
		// Debug("EV_UseActiveAlterSkill 이벤트가 날라 왔다! :" @ param);
*/
	}	

}

/**
 * 숫자를 넣으서 true, false 를 리턴 하게 한다.
 **/
function bool bflag(int nflag)
{
	if (nflag > 0) return true;
	else return false;
}


/**
 * 스킬 번호를 입력 하면 발동 시킬 아이콘을 리턴
 * 현재 사용 하지 않음..
 **/
function int getSkillIconType(int skill_id)
{

	local int returnV;

	returnV = 1;

	switch (skill_id)
	{
		// 발 
		case   0 :
		case   1 :
		case   2 :returnV = 1;
		break;

		// 주먹
		case   3 :
		case   4 :
		case   5 : returnV = 2;
		break;

		default :

	}	

	return returnV;
}
defaultproperties
{
}
