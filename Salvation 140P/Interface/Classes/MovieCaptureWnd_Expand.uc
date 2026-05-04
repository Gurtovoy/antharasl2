class MovieCaptureWnd_Expand extends UICommonAPI;//ldw 2010.10.

var WindowHandle Me;
var ButtonHandle cBtn;
var WindowHandle m_Wnd;
//var ButtonHandle CloseButton;
var TextBoxHandle timer;
var int secInt; 

const TIMER_ID_COUNTUP=7069;// 타이머 아이디 인데 수정 해 줘야 하는 지 모르겠음. 일단 없는거 씀.
const TIMER_DELAY=1000;//1초

function OnLoad()
{
	if(CREATE_ON_DEMAND==0)//과거에 불려 졌었는가?
	{
		//OnRegisterEvent();
	} else {
		timer	= 	TextBoxHandle(GetHandle("MovieCapturewnd_Expand.timer"));//시간
	}
	Initialize();
}
function Initialize()
{	
	Me = GetWindowHandle( "MovieCaptureWnd_Expand" );
	m_Wnd = GetWindowHandle( "MovieCaptureWnd" );
	cBtn = GetButtonHandle( "MovieCapturewnd_Expand.cBtn" );
	timer = GetTextBoxHandle("MovieCapturewnd_Expand.timer");	
}
function OnTimer(int TimerID) {
	if(TimerID == TIMER_ID_COUNTUP){
		secInt++;		
	}
	setTimeTxt();
}
function OnClickButton( string Name )
{	
	switch( Name )
	{
	case "cBtn":
		MovieCaptureToggle();
		//Debug("멈추기");
		break;
	/*case "CloseButton":
		MovieCaptureToggle();*/
	}
}
function string itoStr(int tmpNum){
	local string tmpStr;
	if(tmpNum<10){
		tmpStr = ("0"$string(tmpNum));
	} else 
	{		
		tmpStr = string(tmpNum);
	}	
	return tmpStr;
}
function setTimeTxt(){
	timer.SetText( itoStr(((secInt/60)/60)%60)$" : "$itoStr((secInt/60)%60)$" : "$itoStr(secInt%60));	
	///////////////////////////  디버그 용 나중에 수치 찍어 볼 대 /////////////////////////////////
	/*local int tmpHouInt;
	local int tmpMinInt;
	local int tmpSecInt;	
	
	tmpSecInt = secInt%60;
	tmpMinInt = (secInt/60)%60;
	tmpHouInt = ((secInt/60)/60)%60;

	Debug(tmpHouInt$"시 "$tmpMinInt$"분 "$tmpSecInt$"초");*/
	////////////////////////////////////////////////////////////////////////
}
function OnRegisterEvent()
{
	RegisterEvent(EV_MovieCaptureStarted);//캡쳐가 시작 되었음
	RegisterEvent(EV_MovieCaptureEnded);//캡쳐가 끝남 되었음
	RegisterEvent(EV_MovieCaptureFailDiskSpace);//용량 부족으로 캡쳐 시작 실패 혹은 캡쳐 도중 중단
}

function OnEvent(int a_EventID, String a_Param )
{
	switch( a_EventID )
	{
		case EV_MovieCaptureStarted:
			secInt = 0;
			setTimeTxt();
			Me.SetTimer(TIMER_ID_COUNTUP,TIMER_DELAY);
			//Debug("캡쳐 시작 이벤트_expand");
			break;
		case EV_MovieCaptureEnded:
			Me.KillTimer(TIMER_ID_COUNTUP);
			//Debug("캡쳐 완료 이벤트_expand");
			break;
		case EV_MovieCaptureFailDiskSpace:
			Me.KillTimer(TIMER_ID_COUNTUP);
			//Debug("용량 없음 이벤트_expand");
			break;		
	}
}

/*function onShow(){
	class'UIAPI_WINDOW'.static.SetAnchor( "MovieCaptureWnd", "MovieCaptureWnd_Expand", "TopLeft", "TopLeft", 0, 0 );
}*/
defaultproperties
{
}
