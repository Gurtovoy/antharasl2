//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : MultiTimer  ( 과거 AI-Timer , 여러 종류 타이머 ) - SCALEFORM UI
//      AITimerWnd.uc 을 대신하여 사용.
//
//------------------------------------------------------------------------------------------------------------------------
class MultiTimer extends L2UIGFxScript;

/*
const FLASH_XPOS = 0;
const FLASH_YPOS = 100;

var array<GFxValue> args;
var GFxValue invokeResult;
*/


function OnRegisterEvent()
{	
	RegisterGFxEvent( EV_AITimer );	
	RegisterGFxEvent( EV_KserthFieldEventStep );	
	RegisterGFxEvent( EV_KserthFieldEventPoint );	
	RegisterGFxEvent( EV_Restart );	
}

function OnLoad()
{
	registerState( "MultiTimer", "GamingState" );

	SetContainerHUD( WINDOWTYPE_NONE, 0 ) ;
	AddState("GAMINGSTATE");
	SetDefaultShow( true );
	setHavingFocus( false );
	//SetAlwaysFullAlpha( true );
	//SetMsgPassThrough( true );
	//IgnoreUIEvent(true);
}

/*
function OnShow()
{

}

function OnFlashLoaded()
{	
	/*
	local GFxValue l2SysStringTranslator;
	local GFxValue obj;

	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_Default);

	AllocGFxValue(l2SysStringTranslator);
	AllocGFxValue(obj);

	GetVariable(obj,"_root.l2SysStringTranslator");
	
	GetFunction(l2SysStringTranslator, EExternalFunctionType.EFunc_SysStringTranslator);
	obj.SetMemberValue("getTranslatedString", l2SysStringTranslator);

	DeallocGFxValue(l2SysStringTranslator);
	DeallocGFxValue(obj);*/

	SetAnchor( "", EAnchorPointType.ANCHORPOINT_TopCenter, EAnchorPointType.ANCHORPOINT_TopCenter, FLASH_XPOS, FLASH_YPOS );
}

function OnHide()
{
	
}

function OnCallUCLogic( int logicID, string param )
{
}

function OnEvent(int Event_ID, string param)
{
	local string Param1, Param2, Param3, Param4, Param5, Param6;
	local int EventID;

	//Debug("timer" @ param);
	if( Event_ID == EV_AITimer ) //3550
	{		
		ParseString(Param, "Param1", Param1);	//
		ParseString(Param, "Param2", Param2); //카운트 시작하는 분?
		ParseString(Param, "Param3", Param3); //카운트 시작하는 초
		ParseString(Param, "Param4", Param4); //보여주는 스트링
		ParseString(Param, "Param5", Param5); //카운트 종료되는 분?
		ParseString(Param, "Param6", Param6); //카운트 종료되는 초
		Parseint(Param, "EventID", EventID);   //이벤트 아이디 - 이 이벤트아이디로 시작/정지/일시중지/일시정지 후 다시 시작인지 판단
		
		
		//Debug( "EventID>>>>>>>" $ EventID );
		//Debug( "Param1>>>>>>>" $ Param1 );
		//Debug( "Param2>>>>>>>" $ Param2 );
		//Debug( "Param3>>>>>>>" $ Param3 );
		//Debug( "Param4>>>>>>>" $ Param4 );
		//Debug( "Param5>>>>>>>" $ Param5 );
		//Debug( "Param6>>>>>>>" $ Param6 );
		
		switch( EventID )
		{
			case 1:				
				hideTimer();				
				break;
			case 3:				
				setAnnihilationTimer( EventID, Param1, Param2 );
				break;
			//범용 타이머
			case 4:				
				setWideUseMultiTimer( EventID, Param1, Param2, Param3, Param4 );
				break;	
			case 2 : //이스티나 보스전
			case 5 : //실렌의 제단				
				//스크린 타이머 파라메타 설명 
				//EventID 2, 5 에 따라 그래픽이 다름
				//Param1 = 시간 : -1일 경우 시간 표시 없음
				//Param2 = 현재값 : 
				//Param3 = 최대값 : 최대값이 NULL일 경우 현재값이 %값이 됨.
				//Param4 = 타이틀 : 표시되고 있는 바의 제목 NULL일 경우 "발리스타 마력 충전"이 기본 값.
				//Param5 = Unit   :
				//Param6 = 사용 안함
				setScreenTimer( EventID, Param1, Param2, Param3, Param4, Param5 ); //, Param6 ); // 둘다 가능
				break;
			case 6 : //드라코의 알까기 솔로
			case 7 : //드라코의 알까기 파티			
				//스크린 타이머 파라메타 설명 				
				//Param1 = 시간 : 남은 시간
				//Param2 = 부화가능
				//Param3 = 부화최적
				//Param5 = 업 온도
				//Param6 = 상태
				setThermometer( EventID, Param1, Param2, Param3, Param4, Param5, Param6 ); 
				break;
			case 8 :
				//  혈맹 조합 게이지
				setUnionCollectTimer( EventID, Param1, Param2, Param3, Param4, Param5 );
				break;
		}
	}
}



function setThermometer( int ID, string Time, string can, string fit, string title, string toRaise, string result )
{		
	ShowWindow();
	// 플래시 타입 데이타 인스턴스 생성
	AllocGFxValues(args, 2);
	AllocGFxValue(invokeResult);

	// 발동 스킬 생성 : 이벤트 번호 2번
	args[0].SetInt(ID);
	CreateObject(args[1]);

	args[1].SetMemberString( "Time", Time );
	args[1].SetMemberstring( "can", can );
	args[1].SetMemberstring( "fit", fit );
	args[1].SetMemberstring( "title", title );
	args[1].SetMemberstring( "toRaise", toRaise );
	args[1].SetMemberstring( "result", result );

	//Debug(Time @ can @ fit @ title @ toRaise @ result);

	Invoke( "_root.onEvent", args, invokeResult );

	DeallocGFxValue( invokeResult );
	DeallocGFxValues( args );
}


//타이머 삭제 Event 1
function hideTimer()
{
	// 플래시 타입 데이타 인스턴스 생성
	AllocGFxValues(args, 1);
	AllocGFxValue(invokeResult);

	// 발동 스킬 생성 : 이벤트 번호 1번
	args[0].SetInt(1);	

	Invoke( "_root.onEvent", args, invokeResult );

	DeallocGFxValue( invokeResult );
	DeallocGFxValues( args );	

	//HideWindow();
}

//  혈맹 조합 게이지
function setUnionCollectTimer( int ID, string Time, string Min, string Max, string Title, string Unit )
{	
	local int                    Per;
	local string                UnitString;
	local string                PerString;
	local int                    TimeVisible;
	
	ShowWindow();
	// 플래시 타입 데이타 인스턴스 생성
	AllocGFxValues(args, 2);
	AllocGFxValue(invokeResult);

	// 발동 스킬 생성 : 이벤트 번호 2번
	args[0].SetInt(ID);
	CreateObject(args[1]);	

	if(Title == "") Title = "";
	
	if(Unit == "") 
		UnitString = GetSystemString(2042);  //기본은 %임
	else if (Unit == "-1" )
		UnitString = "";
	else 
		UnitString = GetSystemString( int(Unit) );
	
	if ( Max == "0") 
	{
		Per = int(Min);
		PerString =  Per $ UnitString ;
	}
	else
	{
		Per = ( float(Min) / float(Max) * 100 );
		//PerString =  Min $ UnitString $ "/" $ Max $ UnitString;
		PerString =  Per $ UnitString;
	}	

	if (Time == "-1" )
		TimeVisible = 0; //안보임
	else 
	{
		TimeVisible = 1; //  보임
	}

	args[1].SetMemberString( "Title", Title );
	args[1].SetMemberString( "Time",  TimeNumberToString( int(Time) ) ); //시간
	args[1].SetMemberInt( "Per", Per );
	args[1].SetMemberString( "PerString", PerString  );	
	args[1].SetMemberInt( "TimeVisible", TimeVisible );	

	Invoke( "_root.onEvent", args, invokeResult );

	DeallocGFxValue( invokeResult );
	DeallocGFxValues( args );
}

function setScreenTimer( int ID, string Time, string Min, string Max, string Title, string Unit ) //, string TimeInVisible )
{
	//	
	local int                   Per         ;            
	local string                UnitString  ;
	local string                PerString   ;
	local int                   TimeVisible ;
	
	ShowWindow();
	// 플래시 타입 데이타 인스턴스 생성
	AllocGFxValues(args, 2);
	AllocGFxValue(invokeResult);

	// 발동 스킬 생성 : 이벤트 번호 2번
	args[0].SetInt(ID);	
	CreateObject(args[1]);	

	if(Title == "") // 0921 > "" ai는 int 형이며 서버에서 systemstring로 변환 합니다. ""값은 오지 않습니다.
		Title = GetSystemString(2408); //LDW 20110914 기본 스트링 > 발리스타 마력충전			
	
	if(Unit == "") 
		UnitString = GetSystemString(2042);  //기본은 %임
	else if (Unit == "-1" )
		UnitString = "";
	else 
		UnitString = GetSystemString( int(Unit) );
	

	if ( Max == "0") 
	{
		Per = int(Min);
		PerString =  Per $ UnitString ;
	}
	else
	{
		Per = ( float(Min) / float(Max) * 100 );
		//Debug ("per="$ ( float(Min) / float(Max) ) );
		PerString =  Min $ UnitString $ "/" $ Max $ UnitString;
	}	

	if (Time == "-1" )
		TimeVisible = 0; //안보임
	else 
		TimeVisible = 1; //  보임

//	Debug (Title @ Time @ Per @ PerString @ TimeVisible);

	args[1].SetMemberString( "Title", Title );
	args[1].SetMemberString( "Time", TimeNumberToString( int(Time) ) ); //시간
	args[1].SetMemberInt( "Per", Per );
	args[1].SetMemberString( "PerString", PerString  );	
	args[1].SetMemberInt( "TimeVisible", TimeVisible );	

	Invoke( "_root.onEvent", args, invokeResult );

	DeallocGFxValue( invokeResult );
	DeallocGFxValues( args );
}

//진멸의 씨앗 산실전 Timer  Event 3
function setAnnihilationTimer( int ID, string Time, string Count )
{
	//setai ai_aiui_test
	//debug_ai 370
	//debug_ai -2
	// 플래시 타입 데이타 인스턴스 생성
	ShowWindow();

	AllocGFxValues(args, 2);
	AllocGFxValue(invokeResult);

	// 발동 스킬 생성 : 이벤트 번호 3번
	args[0].SetInt(ID);	
	CreateObject(args[1]);

	//systemString 추가 해야함.
	args[1].SetMemberString( "Title", GetSystemString(2409) );
	args[1].SetMemberString( "Time",  TimeNumberToString( int(Time) ) );
	//systemString 추가 해야함.
	args[1].SetMemberString( "Count", Count $ GetSystemString(932) );

	Invoke( "_root.onEvent", args, invokeResult );

	DeallocGFxValue( invokeResult );
	DeallocGFxValues( args );
}

//범용 타이머  Event 4
function setWideUseMultiTimer( int ID, string countDowUp, string startTime,  string endTime, string Title )
{
	ShowWindow();
	//setai ai_aiui_test
	//debug_ai 370
	//debug_ai -2
	// 플래시 타입 데이타 인스턴스 생성
	AllocGFxValues(args, 2);
	AllocGFxValue(invokeResult);

	// 발동 스킬 생성 : 이벤트 번호 4번
	args[0].SetInt(ID);	
	CreateObject(args[1]);

	//args[1].SetMemberInt( "countDowUp", Param1);//카운트 다운/업 구분자이나 Flash에서 필요 없음.
	args[1].SetMemberString( "Title", Title );
	args[1].SetMemberInt( "startTime", int(startTime) );
	args[1].SetMemberInt( "endTime", int(endTime) );
	args[1].SetMemberString( "Time", TimeNumberToString( int(startTime) ) );

	Invoke( "_root.onEvent", args, invokeResult );

	DeallocGFxValue( invokeResult );
	DeallocGFxValues( args );	
}
 
//실렌의 제단 Timer Event 5
function setSilenTimer( int ID, string Time, string Per, string Title )
{
	// 플래시 타입 데이타 인스턴스 생성
	AllocGFxValues(args, 2);
	AllocGFxValue(invokeResult);

	// 발동 스킬 생성 : 이벤트 번호 5번
	args[0].SetInt(ID);	
	CreateObject(args[1]);

	//systemString 추가 해야함.
	args[1].SetMemberString( "Title", Title );
	args[1].SetMemberString( "Time", TimeNumberToString( int(Time) ) );
	//systemString 추가 해야함.
	args[1].SetMemberInt( "Per", int(Per) );
	args[1].SetMemberString( "PerString", Per $ GetSystemString(2042) );

	Invoke( "_root.onEvent", args, invokeResult );

	DeallocGFxValue( invokeResult );
	DeallocGFxValues( args );	
}



//시간을 XX:XX 로 변환하여 보내줌.
function String TimeNumberToString( int time )
{
	local int Min;
	local int Sec;
	
	local string strTime;
	local string SecString;
	local string MinString;

	Min = time / 60;
	Sec = time % 60;

	SecString = string( Sec );	
	MinString = string( Min );

	if( Min < 10 )
	{
		MinString = "0" $ string( Min );
	}

	if(Sec < 10)
	{
		SecString = "0" $ string( Sec );
	}

	if( time >= 60 )
	{
		strTime = MinString $ ":" $ SecString;
	}
	else
	{
		strTime = "00:" $ SecString;
	}

	return strTime;
}
*/

/* 이모션 레이드 로 통합
//이스티나 보스전 Timer Event 2
function setIstinaBossTimer( int ID, string Time, string Per )
{
	//setai ai_aiui_test
	//debug_ai 70
	//debug_ai -1

	// 플래시 타입 데이타 인스턴스 생성
	AllocGFxValues(args, 2);
	AllocGFxValue(invokeResult);

	// 발동 스킬 생성 : 이벤트 번호 2번
	args[0].SetInt(ID);	
	CreateObject(args[1]);

	//systemString 추가 해야함.
	args[1].SetMemberString( "Title", GetSystemString(2408) );
	args[1].SetMemberString( "Time", TimeNumberToString( int(Time) ) );
	//systemString 추가 해야함.
	args[1].SetMemberInt( "Per", int(Per) );
	args[1].SetMemberString( "PerString", Per $ GetSystemString(2042) );

	Invoke( "_root.onEvent", args, invokeResult );

	DeallocGFxValue( invokeResult );
	DeallocGFxValues( args );	
}
*/
defaultproperties
{
}
