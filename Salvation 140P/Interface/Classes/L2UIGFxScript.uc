class L2UIGFxScript extends GFxUIScript;

/*
 * 윈도우타입 디파인
 */ 
const WINDOWTYPE_NONE = "none";
const WINDOWTYPE_DECO_NORMAL = "SkinnedWindow";
const WINDOWTYPE_SUB_WINDOW_TL = "SubWindow_TL";
const WINDOWTYPE_SIMPLE_DRAG = "SimpleDragWindow";
const WINDOWTYPE_NOBG = "SimpleNoBg";
const WINDOWTYPE_NOBG_NODRAG = "SimpleNoBgNoDrag";


var string _windowType;
var string _windowState;
var int _windowTitleID;
var int _stateCount;
var bool _isNotUseESC;
//var bool _CanFocusContainer;
var string containerName;

var WindowHandle m_Container;

function SetContainerHUD(string wndType, int wndTitleID)
{
	containerName = "ContainerHUD";	
	SetMyContainer ( wndType, wndTitleID );
	_isNotUseESC = true;
	//_CanFocusContainer = false;
}

function SetContainerWindow(string wndType, int wndTitleID)
{
	containerName = "ContainerWindow" ;	
	SetMyContainer ( wndType, wndTitleID );
	_isNotUseESC = false;
	//_CanFocusContainer = true;
//	SetHavingFocus( false );
}
function SetMyContainer( string wndType, int wndTitleID )
{
	m_Container = GetWindowHandle ( containerName );
	SetContainer( containerName );
	_windowType = wndType;
	_windowTitleID = wndTitleID;
	_stateCount = 0 ;	
}



/* 윈도우 컨테이너의 문제점
 * 실제 창을 포커스 해도 컨테이너 뎁스는 변경 되지 않는다.
 * 뎁스를 조절 하려면 컨테이너를 focus 해야함
 * 그렇다고 컨테이너만 focus 하게 되면 각 창의 뎁스 변경은 인식 되지 않는다.
 * 즉 순차 적으로 윈도우, 컨테이너를 포커스 해야 한다.
 * 그렇게 할 경우 focus를 잃어 버리는 경우가 생겨 버린다.
 */
function OnFocus(bool bFlag, bool bTransparency)
{
	//CallGFxFunction ( containerName, "onFocus", string ( bFlag ) ) ;

/*
    local array<GFxValue> args;
	local GFxValue invokeResult;

	AllocGFxValues(args,2) ;	
	args[0].setbool(bflag) ;
	args[1].setbool(bTransparency);
	AllocGFxValue(invokeResult);	
		
	Invoke("onFocusContainer", args, invokeResult);
	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);	
*/

	//Debug ( "OnFocus1" @  bFlag @ containerName @ getCurrentWindowName(string (self)) ) ;

	

 // 2014.10.17 포커스를 컨테이너로 하도록 수정
 
	//컨테이너의 창을 포커싱 할 때는 컨테이너 자체로 포커스를 옮김.
	//Debug ( "OnFocus1" @  bFlag @ _CanFocusContainer @containerName @ getCurrentWindowName(string (self)) ) ;
	if ( bFlag ) 
	{
		// 컨테이너가 있다면, 포커싱을 컨테이너로 할 것 
		if ( containerName != "" ) class'UIAPI_WINDOW'.static.SetFocus(containerName);
		//Debug ( "OnFocus2" @  bFlag @ containerName @ getCurrentWindowName(string (self)) ) ;
	}

}


function AddState(string str)
{		
	registerState( getCurrentWindowName (string(Self)), str );
	//Debug ( "AddState" @  getCurrentWindowName (string(Self)) );
	ParamAdd(_windowState, "State"$_stateCount, str);
	_stateCount++;
}

function NotUseESC()
{
	_isNotUseESC = false;
}

////////////////////////////////////////////////////////////////////////////////static 

static function L2Util getInstanceL2Util()
{
	local L2Util script;
	script = L2Util(GetScript("L2Util"));

	return script;
}

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
