class MysteriousMansionResultWnd extends L2UIGFxScript;

var string userFakeName;

function OnRegisterEvent()
{
	//gfx 이벤트로 풀려면 클라이언트 수정 필요 
	
	registerGFxEvent(EV_CuriousHouseResultIsVictory);
	registerGFxEvent(EV_CuriousHouseResultListStart);
	registerGFxEvent(EV_CuriousHouseResultList);
	registerGFxEvent(EV_CuriousHouseResultListEnd);
	registerGFxEvent(EV_CuriousHouseMemberList);
/*
 *  registerEvent(EV_CuriousHouseResultIsVictory);
	registerEvent(EV_CuriousHouseResultListStart);
	registerEvent(EV_CuriousHouseResultList);
	registerEvent(EV_CuriousHouseResultListEnd);
	registerEvent(EV_CuriousHouseMemberList);
*/
}

function OnLoad()
{
	registerState( getCurrentWindowName(String(self)), "GamingState" );

	SetContainerWindow( WINDOWTYPE_DECO_NORMAL, 2806);
	AddState("GAMINGSTATE");	
}

/*
function OnEvent(int Event_ID, string a_param)
{

	Debug ("OnEvent" @  Event_ID ) ;
	switch (Event_ID)
	{
	case EV_CuriousHouseMemberList : //9341		
		//handleMemberList(a_param);
		//break;
	case EV_CuriousHouseResultIsVictory :   //9370		
		//handleResultIsVictory(a_param); 
		//break;
	case EV_CuriousHouseResultListStart: //9380
//		handleResultStart(a_param);
		//break;
	case EV_CuriousHouseResultList :    //9381		
		//handleResultList(a_param);
		//break;
	case EV_CuriousHouseResultListEnd  :    //9382
		
		//handleResultEnd(a_param);
		CallGFxFunction( getcurrentWindowName(string(self)), string( Event_ID ) , a_param);
		break;
	}
}

function handleMemberList(string a_param)
{
	local UserInfo  userinfo;
	local int       ServerID;	

	ParseInt( a_param , "ServerID", ServerID);	
	if ( GetPlayerInfo ( userinfo ))
	{
		if ( userinfo.nID == ServerID )
		{
			ParseString(a_param, "UserName", userFakeName);
		}
	}
}

function handleResultIsVictory (string a_param)
{
	//이 부분 받을 때, 자신의 이름도 같이 전송 
	local int isVictory;
	local GFXValue argArray;

	setShowWindow(); //쇼를 해줘야 정상 작동 함

//	Debug("handleResultIsVictory" @ a_param);

	AllocGFxValue(argArray);
	createObject(argArray);	
	ParseInt(a_param, "isVictory", isVictory);
	dispatchEventToFlash_Int(1, isVictory);
	DeallocGFxValue(argArray);
}

function handleResultStart (string a_param)
{	
	local UserInfo userinfo;

	local GFXValue argArray;
	AllocGFxValue(argArray);
	createObject(argArray);	

	if(GetPlayerInfo(userinfo))
		dispatchEventToFlash_String(2, userinfo.Name );	

	DeallocGFxValue(argArray);
}

function handleResultList (string a_param)
{
	local string UserName;
	local int    ClassID;	
	local int    LifeTimeInSec;
	local int    KillCnt;

	local UserInfo userinfo;

	local GFXValue argArray;
	AllocGFxValue(argArray);
	createObject(argArray);	

	ParseString(a_param, "UserName",    UserName);

	if (userFakeName == UserName) // 자기 이름과 userFakeName이 같으면 
	{
		if(GetPlayerInfo(userinfo))
			UserName = userinfo.Name; //username로 자기 이름을 올림
	}

	ParseInt(a_param, "ClassID",        ClassID);
	Parseint(a_param, "LifeTimeInSec",  LifeTimeInSec);
	ParseInt(a_param, "KillCnt",        KillCnt);

	argArray.SetMemberString("UserName",        UserName);
	argArray.SetMemberString("ClassName",       GetClassType(ClassID));
	argArray.SetMemberString("LifeTimeInSec",   LifeTimeInSec @ GetSystemString(2001));
	argArray.SetMemberInt("KillCnt",            KillCnt);

	dispatchEventToFlash(3, argArray);
	DeallocGFxValue(argArray);
}

function handleResultEnd (string a_param)
{
	local GFXValue argArray;
	AllocGFxValue(argArray);
	createObject(argArray);	

	dispatchEventToFlash_int(4, 0);
	DeallocGFxValue(argArray);
}


function setShowWindow()
{	
	if( IsShowWindow() == false )
	{
		ShowWindow();				
	}
}

function setHideWindow()
{	
	if( IsShowWindow() == true )
	{
		HideWindow();				
	}
}


/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	local array<GFxValue> args;

	local GFxValue invokeResult;

	AllocGFxValues(args, 1);		
	
	Invoke("_root.onReceivedCloseUI", args, invokeResult);

	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);	
}


function dispatchEventToFlash(int Event_ID, GFxValue argArray){

	local array<GFxValue> args;
	local GFxValue invokeResult;

	AllocGFxValues(args, 2);
	AllocGFxValue(invokeResult);
	args[0].SetInt(Event_ID);
	CreateObject(args[1]);

	args[1].SetMemberValue("param", argArray );

	Invoke("_root.onEvent", args, invokeResult);
	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);	
}

function dispatchEventToFlash_String(int Event_ID, string argString){
	local array<GFxValue> args;
	local GFxValue invokeResult;

	AllocGFxValues(args, 2);
	AllocGFxValue(invokeResult);
	args[0].SetInt(Event_ID);
	CreateObject(args[1]);

//	Debug("argString"@argString);
	args[1].SetMemberString("string", argString );

	Invoke("_root.onEvent", args, invokeResult);
	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);
}

function dispatchEventToFlash_Int(int Event_ID, int argInt){
	local array<GFxValue> args;
	local GFxValue invokeResult;

	AllocGFxValues(args, 2);
	AllocGFxValue(invokeResult);
	args[0].SetInt(Event_ID);
	CreateObject(args[1]);

//	Debug("argString"@argString);
	args[1].SetMemberInt("int", argInt );

	Invoke("_root.onEvent", args, invokeResult);
	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);
}

*/
defaultproperties
{
}
