class L2UIGFxScriptNoneContainer extends GFxUIScript;

function AddState(string str)
{		
	registerState( getCurrentWindowName (string(Self)), str );
	//함수 실행 시 onStateOut, onStateIn 함수를 invoke 로 받음 
	SetStateChangeNotification();
}

function OnEvent(int a_EventID, string a_Param) 
{	
	switch (a_EventID)
	{
		case EV_NotifyBeforeStateChanged://3411 EV_StateChanged:
			handleNotifyBeforeStateChanged ( a_Param ) ;		
		break;	
	}
}

function OnFocus(bool bFlag, bool bTransparency)
{	
	local array<GFxValue> args;
	local GFxValue invokeResult;

	Debug ( "onFocus !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" @ bFlag);
	AllocGFxValues(args,2) ;	
	args[0].setbool(bflag) ;
	args[1].setbool(bTransparency);
	AllocGFxValue(invokeResult);	
		
	Invoke("onFocusContainer", args, invokeResult);		
	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);	
}

function onHide () 
{
	invokeToFlash ("onHide");
}

function onShow () 
{
	Debug ( getCurrentWindowName( string( self) )  @ "onShow" ) ;
	invokeToFlash ("onShow");
}

function handleNotifyBeforeStateChanged( string param ) 
{
	local array<GFxValue> args;
	local GFxValue invokeResult;

	AllocGFxValues(args, 2);
	AllocGFxValue(invokeResult);

	args[0].SetInt( EV_NotifyBeforeStateChanged );
	CreateObject(args[1]);

//	Debug("argString"@argString);
	args[1].SetMemberString( "state" , param  );

	Invoke("onEvent", args, invokeResult);
	
	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 **
 ***/
function OnReceivedCloseUI()
{
	invokeToFlash ("onPressESC");
}

function OnDefaultPosition()
{
	invokeToFlash( "onDefaultPosition" );
}


function invokeToFlash ( string invokeID ) 
{
	local array<GFxValue> args;
	local GFxValue invokeResult;
	
	//if ( param != NU ) 
	AllocGFxValues(args, 1);
	//args[0].setMemberString ( "param", param) ;
	
	Invoke( invokeID, args, invokeResult);

	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);		
}

////////////////////////////////////////////////////////////////////////////////static 

static function UIData getInstanceUIData()
{	
	return UIData(GetScript("UIData"));
}

/** 
 * 
 * 윈도우 이름을 받는다.
 * 
 * getCurrentWindowName (string(Self)) 
 * 
 **/
static function string getCurrentWindowName (string targetString)
{
	local array<string>	ArrayStr;

	Split(targetString, ".", ArrayStr);

	return ArrayStr[1];
}

static function int Split( string strInput, string delim, out array<string> arrToken )
{
	local int arrSize;
	
	while ( InStr(strInput, delim)>0 )
	{
		arrToken.Insert(arrToken.Length, 1);
		arrToken[arrToken.Length-1] = Left(strInput, InStr(strInput, delim));
		strInput = Mid(strInput, InStr(strInput, delim)+1);
		arrSize = arrSize + 1;
	}
	arrToken.Insert(arrToken.Length, 1);
	arrToken[arrToken.Length-1] = strInput;
	arrSize = arrSize + 1;
	
	return arrSize;
}
defaultproperties
{
}
