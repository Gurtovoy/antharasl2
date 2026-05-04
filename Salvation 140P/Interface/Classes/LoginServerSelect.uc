//------------------------------------------------------------------------------------------------------------------------
//
// 제목  : LoginServerSelect  - SCALEFORM UI
//
//------------------------------------------------------------------------------------------------------------------------
class LoginServerSelect extends GFxUIScript;

//const FLASH_WIDTH  = 800;
//const FLASH_HEIGHT = 600;

//플래쉬 옵셋 좌표
const FLASH_XPOS = 0;
const FLASH_YPOS = 0;

var array<int> arrID;
var array<int> arrAgeLimit;
//var array<string> arrTest;

var int currentScreenWidth, currentScreenHeight;

function OnRegisterEvent()
{	
	RegisterEvent(EV_ServerListStart);	
	RegisterEvent(EV_ServerList);	
	RegisterEvent(EV_ServerListEnd);	
	RegisterEvent( EV_ResolutionChanged );
}

function OnLoad()
{		
	//registerState 를 할 경우 setfocus 됨.
	registerState( "loginServerSelect", "SERVERLISTSTATE" );

	SetContainer( "ContainerHUD" );
	
	setHUD();

	SetAlwaysOnTop(true);
	//SetFixedPositionRate( 0.5f, 0.46f );	
	SetAnchor("", EAnchorPointType.ANCHORPOINT_BottomRight, EAnchorPointType.ANCHORPOINT_TopLeft, 0, 0 );	
	//Debug("rang" @ getLanguageNum());
}

//function OnFocus(bool bFlag, bool bTransparency){}


function int getLanguageNum()
{
	local ELanguageType Language;	
	//local int languageNum;
	Language = GetLanguage();
	return  int(Language) ;
/*
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
		//branch 110824
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
		default:
			languageNum = 0;
			break;
	}	
	
	return languageNum;	*/
	 //<< 이렇게 팅겨 줘도 됨.
}
function OnShow()
{
	//checkWarnimgMode();
	//ExecuteCommand("///uidebug");	
}

function OnFlashLoaded()
{	
	/*
	local GFxValue l2SysStringTranslator;
	local GFxValue obj;
*/

	checkWarnimgMode();
/*	
	AllocGFxValue(l2SysStringTranslator);
	AllocGFxValue(obj);

	GetVariable(obj,"_root.l2SysStringTranslator");
	
	GetFunction(l2SysStringTranslator, EExternalFunctionType.EFunc_SysStringTranslator);
	obj.SetMemberValue("getTranslatedString", l2SysStringTranslator);

	DeallocGFxValue(l2SysStringTranslator);
	DeallocGFxValue(obj);
*/
}

function checkWarnimgMode() //각 조건 별 메시지 출력
{
	local string msg;

	//타이틀 색생 및 크기 15 #FFDF5F
	//13 #DCDCDC

	
	if ( getLanguageNum() == 0 ) //한국어일 경우 2.0  
	{		
		msg = GetSystemMessage(5070); //서버 통합 메시지 
	}
	
		
	//dispatchEventToFlash_String(10, msg);
	//msg 가 "" 일 경우 노멀 모드 
	
	callGfxFunction("LoginServerSelect", "showWarningMode", msg );
}

function OnHide()
{
	//RestartFlash();
}

/*
 * GGx4.x
 */
function OnCallUCFunction( string funcName, string param )
{	
	local int severNum;
	local string strParam;

	//debug("OnCallUCFunction" @ funcName @  param);
	switch( funcName )
	{
		//서버 선택.
		case "selectServer" :
			ParseInt( param, "serverNum", severNum );
			FindAge( severNum );
			RequestLoginServer(severNum);
			break;
		//서버 선택 cancel
		case "selectServerCancle" :
			GotoLogin();
			break;
		//추천 서버로 정렬
		case "sortServerList":
			RequestSortedServerInfo();
			break;
		case "showHelp":				
			ParamAdd(strParam, "FilePath", "..\\L2text\\server_help.htm");
			ExecuteEvent(EV_ShowHelp, strParam);
			break;
	}
}

/*
function OnCallUCLogic( int logicID, string param )
{	
	local int severNum;
	local string strParam;

	switch( logicID )
	{
		//서버 선택.
		case 0 :
			ParseInt( param, "severNum", severNum );
			FindAge( severNum );
			RequestLoginServer(severNum);
			break;
		//서버 선택 cancel
		case 1 :
			GotoLogin();
			break;
		//추천 서버로 정렬
		case 2:			
			RequestSortedServerInfo();
			break;
		case 3:				
			ParamAdd(strParam, "FilePath", "..\\L2text\\server_help.htm");
			ExecuteEvent(EV_ShowHelp, strParam);
			break;
	}
}
*/

//등급표시를 위한 작업. 서버 선택이 Flash로 바뀌면서 추가 됨.
function FindAge( int serverID )
{
	local int i;
	local int intAge;
	local string strParam;

	for( i = 0 ; i < arrID.Length ; i++ )
	{
		if( serverID == arrID[i] )
		{
			//debug( "!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@!@" $ string( arrAgeLimit[i] ) $ arrTest[i] );
			if( arrAgeLimit[i] == 15 ) intAge = 0;
			else if( arrAgeLimit[i] == 18 ) intAge = 1;
			else intAge = 1;
			
			ParamAdd(strParam, "ServerAgeLimit", string( intAge ));
			ParamAdd(strParam, "GlobalVersion", string( getLanguageNum() ));			
			ExecuteEvent( EV_ServerAgeLimitChange, strParam );
			break;
		}
	}
}


function OnEvent(int Event_ID, string a_param)
{			
	//Debug (" server Select" @ Event_ID @ a_param);

	switch(Event_ID)
	{	
		// 서버리스트 받기 시작
		case EV_ServerListStart :	
			if( IsShowWindow() == false ) 
				ShowWindow();
			//SendScreenSize();
			sendServerListStart();
			//IsChinaClient();
			break;

		// 서버리스트 받기
		case EV_ServerList :
			handleServerList(a_param);
			break;

		// 서버리스트 받기 완료
		case EV_ServerListEnd :		
			sendServerListEnd();
			break;
		// 현재 해상도를 얻는다.
		/*case EV_ResolutionChanged :		
			SendScreenSize();
			break;	*/
	}
}


function handleServerList(string a_param)
{
	//local GFXValue argArray;


	local int ID;
	/*
	local string Name;
	local string State;
	local int CharCnt;
*/
	local int AgeLimit;
	/*
	local int IsRelaxServer;
	local int IsTestServer;
	local int IsBoradServer;
	local int IsCreateRestrictServer;
	local int IsEventServer;
	local int IsFreeServer;
	local int IsNewServer;
	local int IsForbiddenServer;
*/


	// 공성전 서버 2012.11.08
	local int IsWorldRaidServer;
/*
	local int StateColorR;
	local int StateColorG;
	local int StateColorB;
*/


	// 공성전 서버라면 리스트 정보를 보내주지 않음 
	ParseInt(a_Param, "IsWorldRaidServer", IsWorldRaidServer);//bool
	if ( IsWorldRaidServer == 1 ) return;

	/*
	AllocGFxValue(argArray);
	createObject(argArray);	
*/

	ParseInt(a_Param, "ID", ID);
	//서버에서는 0, 1로 값을 구분하므로 나중에 ID맞춰 값을 바꿔 줘야 함.
	arrID.Length = arrID.Length + 1;
	arrID[arrID.Length - 1] = ID;

/*
	ParseString(a_Param, "Name",Name );	
	
	ParseString(a_Param, "State", State);

	ParseInt(a_Param, "CharCnt",CharCnt );
*/
	ParseInt(a_Param, "AgeLimit",AgeLimit );
	//서버에서는 0, 1로 값을 구분하므로 나중에 ID맞춰 값을 바꿔 줘야 함.
	arrAgeLimit.Length = arrAgeLimit.Length + 1;
	arrAgeLimit[arrAgeLimit.Length - 1] = AgeLimit;

	/*

	ParseInt(a_Param, "IsRelaxServer", IsRelaxServer); //bool
	ParseInt(a_Param, "IsTestServer", IsTestServer);//bool
	ParseInt(a_Param, "IsBoradServer", IsBoradServer);//bool
	ParseInt(a_Param, "IsCreateRestrictServer", IsCreateRestrictServer);//bool
	ParseInt(a_Param, "IsEventServer", IsEventServer);//bool
	ParseInt(a_Param, "IsFreeServer", IsFreeServer);//bool
	ParseInt(a_Param, "IsNewServer", IsNewServer);//bool
	ParseInt(a_Param, "IsForbiddenServer", IsForbiddenServer);//bool

	ParseInt(a_Param, "StateColorR", StateColorR);
	ParseInt(a_Param, "StateColorG", StateColorG);
	ParseInt(a_Param, "StateColorB", StateColorB);
*/

	/*
	argArray.SetMemberInt("ID",ID);	 
	argArray.SetMemberString("Name",Name);	 
	argArray.SetMemberString("State",State);
	argArray.SetMemberInt("CharCnt",CharCnt);
	argArray.SetMemberInt("AgeLimit",AgeLimit);
	argArray.SetMemberInt("IsRelaxServer",IsRelaxServer);
	argArray.SetMemberInt("IsTestServer",IsTestServer);
	argArray.SetMemberInt("IsBoradServer",IsBoradServer);
	argArray.SetMemberInt("IsCreateRestrictServer",IsCreateRestrictServer);
	argArray.SetMemberInt("IsEventServer",IsEventServer);
	argArray.SetMemberInt("IsFreeServer",IsFreeServer);
	argArray.SetMemberInt("IsNewServer",IsNewServer);
	argArray.SetMemberInt("IsForbiddenServer",IsForbiddenServer);
	argArray.SetMemberInt("IsWorldRaidServer",IsWorldRaidServer);
	
	//argArray.SetMemberString("AgeLimitTexName",AgeLimitTexName);
	//argArray.SetMemberString("RelaxServerTexname",RelaxServerTexname);
	//argArray.SetMemberString("CreateRestrictServerTexName",CreateRestrictServerTexName);
	//argArray.SetMemberString("EventServerTexName",EventServerTexName);
	//argArray.SetMemberString("FreeServerTexName",FreeServerTexName);

	argArray.SetMemberInt("StateColorR",StateColorR);
	argArray.SetMemberInt("StateColorG",StateColorG);
	argArray.SetMemberInt("StateColorB",StateColorB);

	//Debug( "handleServerList" @ ID @Name@State@CharCnt@AgeLimit@IsRelaxServer@IsTestServer@IsBoradServer@ IsCreateRestrictServer@IsEventServer@IsFreeServer@AgeLimitTexName@RelaxServerTexname@RelaxServerTexname@CreateRestrictServerTexName@EventServerTexName@FreeServerTexName);
	
	
	dispatchEventToFlash(1, argArray);
	DeallocGFxValue(argArray);
*/
	
		/*
	* gfx4.0 버젼

	param = makeVar2Str( "ID", String( ID ) );
	param = param @ makeVar2Str( "Name", Name );	
	param = param @ makeVar2Str( "State", State );	
	param = param @ makeVar2Str( "CharCnt", String( CharCnt ) );	
	param = param @ makeVar2Str( "AgeLimit", String( AgeLimit ) );	
	param = param @ makeVar2Str( "IsRelaxServer", String( IsRelaxServer ) );	
	param = param @ makeVar2Str( "IsTestServer", String( IsTestServer ) );	
	param = param @ makeVar2Str( "IsBoradServer", String( IsBoradServer ) );	
	param = param @ makeVar2Str( "IsCreateRestrictServer", String( IsCreateRestrictServer ) );	
	param = param @ makeVar2Str( "IsEventServer", String( IsEventServer ) );	
	param = param @ makeVar2Str( "IsFreeServer", String( IsFreeServer ) );	
	param = param @ makeVar2Str( "IsNewServer", String( IsNewServer ) );
	param = param @ makeVar2Str( "IsForbiddenServer", String( IsForbiddenServer ) );
	param = param @ makeVar2Str( "IsWorldRaidServer", String( IsWorldRaidServer ) );	
	param = param @ makeVar2Str( "StateColorR", String( StateColorR ) );
	param = param @ makeVar2Str( "StateColorG", String( StateColorG ) );
	param = param @ makeVar2Str( "StateColorB", String( StateColorB ) );
	*/

	callGFxFunction("LoginServerSelect","sendServerList", a_param);

}

/*
function dispatchEventToFlash_String(int Event_ID, string argString){
	local array<GFxValue> args;
	local GFxValue invokeResult;

	AllocGFxValues(args, 2);
	AllocGFxValue(invokeResult);
	args[0].SetInt(Event_ID);
	CreateObject(args[1]);

	args[1].SetMemberString("string", argString );

	Invoke("_root.onEvent", args, invokeResult);
	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);
}

function dispatchEventToFlash(int Event_ID, GFxValue argArray)
{
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
*/

/**
 * 서버 리스트 받기 시작.
 * 중국 처리도 해줌.
 */
function sendServerListStart()
{
	local String param;
	/*
	local array<GFxValue> args;
	local GFxValue invokeResult;

	AllocGFxValues(args, 2);
	AllocGFxValue(invokeResult);

	// 이벤트 번호 0번
	args[0].SetInt(0);
	CreateObject(args[1]);

	args[1].SetMemberBool( "IsChinaClient", IsChinaClient() );
	//args[1].SetMemberBool( "IsChinaClient", true );
	args[1].SetMemberString( "PkString", GetChinaPkString() );
	//args[1].SetMemberString( "PkString", "테스트용으로 넣었음.." );
	Invoke("_root.onEvent", args, invokeResult);

	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);
*/
	/*
	* gfx4.0 버젼
	*/	
	param = makeVar2Str( "IsChinaClient", String( IsChinaClient()) );
	param = param @ makeVar2Str( "PkString", GetChinaPkString() );	
	callGFxFunction("LoginServerSelect","sendServerListStart", param);
}

/*
 * gfx4.0 버젼
 */
function string makeVar2Str(string varName, string vars)
{
	return varName $ "=" $ vars;
}

/**
 * 서버 리스트 받기 완료.
 */
function sendServerListEnd()
{
	/*
	local array<GFxValue> args;
	local GFxValue invokeResult;

	AllocGFxValues(args, 1);
	AllocGFxValue(invokeResult);

	// 이벤트 번호 2번
	args[0].SetInt(2);
	//CreateObject(args[1]);

	Invoke("_root.onEvent", args, invokeResult);

	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);
*/

	/*
	* gfx4.0 버젼
	*/
	callGFxFunction("LoginServerSelect","sendServerListEnd", "");
}

/*
function SendScreenSize()
{
	local array<GFxValue> args;
	local GFxValue invokeResult;

	GetCurrentResolution (currentScreenWidth, currentScreenHeight);

	//Debug( "currentScreenWidth>>>" $ string(currentScreenWidth) );
	//Debug( "currentScreenHeight>>>" $ string(currentScreenHeight) );

	// 플래시 타입 데이타 인스턴스 생성
	AllocGFxValues(args, 2);		
	AllocGFxValue(invokeResult);

	// 각성 알람 : 이벤트 번호 100번
	args[0].SetInt( 100 );
	CreateObject(args[1]);

	args[1].SetMemberInt( "screenW", currentScreenWidth );
	Invoke( "_root.onEvent", args, invokeResult );

	DeallocGFxValue( invokeResult );
	DeallocGFxValues( args );
}*/
defaultproperties
{
}
