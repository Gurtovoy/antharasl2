//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : PlayerSkillGauge  - SCALEFORM UI
//      Player 스킬 게이지
//
//------------------------------------------------------------------------------------------------------------------------
class PlayerSkillGauge extends L2UIGFxScript;


const FLASH_XPOS = 0;
const FLASH_YPOS = -220;

/*
var array<GFxValue> args;
var GFxValue invokeResult;
*/

function OnRegisterEvent()
{
	//타겟의 스킬 시전 정보 보내주는 Event Test용.
	RegisterGFxEvent( EV_OwnSkillHasLaunched );
	RegisterGFxEvent( EV_OwnSkillHasCanceled );
}

function OnLoad()
{
	local int addShortcutExpandLocY;

	SetContainerHUD(WINDOWTYPE_NONE, 0);

	AddState( "GAMINGSTATE" ) ;
	AddState( "ARENAPICKSTATE" ) ;
	AddState( "ARENAGAMINGSTATE" ) ;
	AddState( "ARENABATTLESTATE" ) ;
	
	// 한국, 나중에 옵션으로 하는게 좋을듯.. 언어로 세팅하면 한글, 해외 버전에서 확인하기가 불편함.
	//if(GetLanguage() != ELanguageType.LANG_Korean) addShortcutExpandLocY = -40;

	addShortcutExpandLocY = -60;

	SetAnchor("",EAnchorPointType.ANCHORPOINT_BottomCenter,EAnchorPointType.ANCHORPOINT_BottomCenter,FLASH_XPOS,FLASH_YPOS + addShortcutExpandLocY);

	setDefaultShow(true);
	setHavingFocus( false );
	
	/*
	SetAlwaysFullAlpha( true );
	SetMsgPassThrough( true );
	IgnoreUIEvent(true);	
	SetAnchor( "", EAnchorPointType.ANCHORPOINT_BottomCenter, EAnchorPointType.ANCHORPOINT_BottomCenter, FLASH_XPOS , FLASH_YPOS );
	*/
}

/*
function OnEvent(int Event_ID, string
param)
{
	//Debug( "OnEvent" @ Event_ID );
	CallGFxFunction(getCurrentWindowName (String(self)), string(Event_ID), param);

	if( Event_ID == EV_OwnSkillHasLaunched )
	{	
		if( IsShowWindow() == false )
		{
			ShowWindow();
		}
		//ShowFlash("PlayerSkillGauge");
		//Debug( "param ::" $ param );
		HandleOwnSkillHasLaunched(param);

	}
	else if( Event_ID == EV_OwnSkillHasCanceled )
	{
		//이벤트가 2번 날라와 알파가 2번 됨;;
		//Debug("EV_OwnSkillHasCanceled");
		HandleOwnSkillHasCanceled();
	}

}
*/

/*
//타겟 스킬 시전 EV 받음
function HandleOwnSkillHasLaunched(string param)
{	
	
	local int bUseSlot1;
	local float fTotalTimeSlot1;
	local float fElapsedTimeSlot1;
	local string SkillNameSlot1;

	local int bUseSlot2;
	local float fTotalTimeSlot2;
	local float fElapsedTimeSlot2;
	local string SkillNameSlot2;	

//	Debug("HandleOwnSkillHasLaunched"@param);

	ParseInt(param, "bUseSlot1", bUseSlot1);
	ParseFloat(param, "fTotalTimeSlot1", fTotalTimeSlot1);
	ParseFloat(param, "fElapsedTimeSlot1", fElapsedTimeSlot1);
	ParseString(param, "SkillNameSlot1", SkillNameSlot1);	
	
	ParseInt(param, "bUseSlot2", bUseSlot2);
	ParseFloat(param, "fTotalTimeSlot2", fTotalTimeSlot2);
	ParseFloat(param, "fElapsedTimeSlot2", fElapsedTimeSlot2);
	ParseString(param, "SkillNameSlot2", SkillNameSlot2);	

	// 플래시 타입 데이타 인스턴스 생성
	AllocGFxValues(args, 2);		
	AllocGFxValue(invokeResult);

	// 이벤트 번호 0번
	args[0].SetInt(0);	
	CreateObject(args[1]);

	//
	args[1].SetMemberInt( "bUseSlot0", bUseSlot1 );
	args[1].SetMemberInt( "totalTime0", fTotalTimeSlot1 );
	args[1].SetMemberInt( "elapsedTime0", fElapsedTimeSlot1 );
	args[1].SetMemberString( "skillName0", SkillNameSlot1 );

	args[1].SetMemberInt( "bUseSlot1", bUseSlot2 );
	args[1].SetMemberInt( "totalTime1", fTotalTimeSlot2 );
	args[1].SetMemberInt( "elapsedTime1", fElapsedTimeSlot2 );
	args[1].SetMemberString( "skillName1", SkillNameSlot2 );
	Invoke( "_root.onEvent", args, invokeResult );

	DeallocGFxValue( invokeResult );
	DeallocGFxValues( args );
}

//자신의 스킬 시전 취소.
function HandleOwnSkillHasCanceled()
{
	// 플래시 타입 데이타 인스턴스 생성
	AllocGFxValues(args, 1);		
	AllocGFxValue(invokeResult);

	// 이벤트 번호 1번
	args[0].SetInt(1);

	Invoke( "_root.onEvent", args, invokeResult );

	DeallocGFxValue( invokeResult );
	DeallocGFxValues( args );
}
*/
defaultproperties
{
}
