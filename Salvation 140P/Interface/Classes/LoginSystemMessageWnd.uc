//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : lobbyMenuWnd  - SCALEFORM UI
//
//------------------------------------------------------------------------------------------------------------------------
class LoginSystemMessageWnd extends GFxUIScript;

//const FLASH_WIDTH  = 800;
//const FLASH_HEIGHT = 600;

//플래쉬 옵셋 좌표
const FLASH_XPOS = 0;
const FLASH_YPOS = 0;

var bool isFlashLoaded;

var array<string> stateArr ;	

function OnRegisterEvent()
{	
	RegisterEvent(EV_StateChanged);	
	RegisterEvent(EV_MessageWndString);
	RegisterEvent(EV_CharacterDeleteFail);//9740
	//RegisterEvent(EV_Lobby_ShowPremiumLevelInfo);	
}

function OnLoad()
{		
	local int i ;	
	SetAnchor( "", EAnchorPointType.ANCHORPOINT_BottomRight, EAnchorPointType.ANCHORPOINT_TopLeft, FLASH_XPOS, FLASH_YPOS );	

	
	stateArr[0] = "PIAGREEMENTSTATE";       //사용자 정보 동의
	stateArr[1] = "EULAMSGSTATE";           //이용약관
	stateArr[2] = "SERVERLISTSTATE" ;       //서버선택
	stateArr[3] = "CHARACTERSELECTSTATE" ;  //캐릭터 선택
	stateArr[4] = "CHARACTERCREATESTATE";   //캐릭터 생성	
	//stateArr[5] = "GAMINGSTATE";   //캐릭터 생성	

	for ( i = 0 ; i < stateArr.Length ; i++)
	{	
		registerState( "loginSystemMessageWnd", stateArr[i] );
	}
	SetHavingFocus( false );
	SetHUD();
	SetContainer("ContainerHUD");
	SetDefaultShow(true);
	SetAlwaysFullAlpha( true );
	SetMsgPassThrough( true );
	isFlashLoaded = false;
}


function OnShow()
{
	//ExecuteCommand("///uidebug");
//	Debug("lobbyMenuWnd!!!! onShow");
	
}

function OnFlashLoaded()
{
	/*
	//beforeFlashLoadedEvent();
	local GFxValue l2SysStringTranslator;
	local GFxValue obj;	

	AllocGFxValue(l2SysStringTranslator);
	AllocGFxValue(obj);

	GetVariable(obj,"_root.l2SysStringTranslator");
	
	GetFunction(l2SysStringTranslator, EExternalFunctionType.EFunc_SysStringTranslator);
	obj.SetMemberValue("getTranslatedString", l2SysStringTranslator);

	DeallocGFxValue(l2SysStringTranslator);
	DeallocGFxValue(obj);

	isFlashLoaded = true;
*/
}

function beforeFlashLoadedEvent()
{ // 플래시 로딩 전에 들어왓던 관련 이벤트 들을 로드
}

function OnHide()
{	
}


function handleShowMessage(string systemMessage)
{
//	Debug("handleShowMessage" @ systemMessage );
	dispatchEventToFlash_String(3, systemMessage);
}

/*function OnFocus(bool bFlag, bool bTransparency)
{
	local array<GFxValue> args;
	local GFxValue invokeResult;

	AllocGFxValues(args,2);	
	args[0].setbool(bflag);
	args[1].setbool(bTransparency);
	AllocGFxValue(invokeResult);
		
	Invoke("_root.onFocus", args, invokeResult);

	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);	
}*/


function OnEvent(int Event_ID, string a_param)
{
	local string    msg;
	
	switch(Event_ID)
	{
		case EV_StateChanged:			
			HandleStateChange( a_param );
			break;
		case EV_MessageWndString : //581			
			parseString(a_param, "Message", msg);
			handleShowMessage(msg);
			break;
		case EV_CharacterDeleteFail:
			
			handleShowDeleteFail(a_param);
			break;
		/*case EV_Lobby_ShowPremiumLevelInfo :
			handleShowKindOfAccount(a_param);
			break;*/
	}
}

function handleShowDeleteFail( string a_param ) 
{
	local int type;
	local int msgInt ;
	local string systemMessage;

	parseInt(a_param, "type", type);

//	if ( type == 0 ) return // 성공 할 경우 .

	switch ( type ) 
	{
		//성공 적으로 삭제 한 경우.
		case ECharacterDeleteFailType.ECDFT_NONE:
			return;
		break;
		case ECharacterDeleteFailType.ECDFT_UNKNOWN:
			msgInt = 306;
		break;
		case ECharacterDeleteFailType.ECDFT_PLEDGE_MEMBER:
			msgInt = 541;
		break;
		case ECharacterDeleteFailType.ECDFT_PLEDGE_MASTER:
			msgInt = 540;
		break;
		case ECharacterDeleteFailType.ECDFT_PROHIBIT_CHAR_DELETION:
			msgInt = 3091;
		break;
		case ECharacterDeleteFailType.ECDFT_COMMISSION:
			msgInt = 3529;
		break;
		case ECharacterDeleteFailType.ECDFT_MENTOR:
			msgInt = 3716;
		break;
		case ECharacterDeleteFailType.ECDFT_MAIL:
			msgInt = 4198;
		break;
	}	
	systemMessage = GetSystemMessage( msgInt );
	dispatchEventToFlash_String(3, systemMessage);
}

function HandleStateChange ( string a_param ) 
{	
	local int           stateNum ;
	local array<int> titleSystemInt[5];
	
	titleSystemInt[0] = 2686;            //사용자 사전 동의 
	titleSystemInt[1] = 2686;            //이용약관
	titleSystemInt[2] = 2693;            //서버선택
	titleSystemInt[3] = 157;             //캐릭터 선택
	titleSystemInt[4] = 158;             //캐릭터 생성

	stateNum =  chkState(a_param);
	
	if ( stateNum != -1)
	{
		dispatchEventToFlash_Int( 1,  titleSystemInt[stateNum] );
	}
	else
	{ 
		dispatchEventToFlash_Int( 2, -1);	
	}
}

function int chkState(string state)
{
	local int i;

	for ( i = 0 ; i < stateArr.Length ; i++ )
		if ( state == stateArr[i])
			return i;
	
	return -1;
}


function handleShowKindOfAccount(string a_param)
{
	local int premiumLevel ; 	
	local  array<int> kindOfAccount[20];

	kindOfAccount[0] = 5097;                  //Free Account;
	kindOfAccount[1] = 5098;                  //Premium Account;
	
	parseInt(a_param, "premiumLevel", premiumLevel);
	
	dispatchEventToFlash_Int(4, kindOfAccount[premiumLevel]);
}
/*function dispatchEventToFlash(int Event_ID, GFxValue argArray){

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
}*/

function dispatchEventToFlash_String(int Event_ID, string argString)
{
	//local array<GFxValue> args;
	//local GFxValue invokeResult;

	//AllocGFxValues(args, 2);
	//AllocGFxValue(invokeResult);
	//args[0].SetInt(Event_ID);
	//CreateObject(args[1]);

//	Debug("argString"@argString);
	//args[1].SetMemberString("string", argString );

	callGFxFunction( "LoginSystemMessageWnd", "logSystemMsgFunc", "eventID=" $ Event_ID @ "string=" $ argString);

	//Invoke("_root.onEvent", args, invokeResult);
	//DeallocGFxValue(invokeResult);
	//DeallocGFxValues(args);
}

function dispatchEventToFlash_Int(int Event_ID, int argInt){
	//local array<GFxValue> args;
	//local GFxValue invokeResult;

	//AllocGFxValues(args, 2);
	//AllocGFxValue(invokeResult);
	//args[0].SetInt(Event_ID);
	//CreateObject(args[1]);

//	Debug("argString"@argString);
	//args[1].SetMemberInt("int", argInt );

	callGFxFunction( "LoginSystemMessageWnd", "logSystemMsgFunc", "eventID=" $ Event_ID @ "num=" $ argInt);

	//Invoke("_root.onEvent", args, invokeResult);
	//DeallocGFxValue(invokeResult);
	//DeallocGFxValues(args);
}
defaultproperties
{
}
