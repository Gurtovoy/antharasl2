class BR_EventHalloweenWnd extends UICommonAPI;

var WindowHandle Me;
var WindowHandle Today;

var int WindowState;
// 0 : BR_EventHalloweenTodayWnd Hide 상태
// 1 : BR_EventHalloweenTodayWnd 에 오늘 기록 보여주고 있는 상태
// 2 : BR_EventHalloweenTodayWnd 에 전날 기록 보여주고 있는 상태

function OnRegisterEvent()
{
	RegisterEvent( EV_BR_EventHalloweenShow );
}

function OnLoad()
{
	Initialize();
}

function Initialize()
{
	if (CREATE_ON_DEMAND==0) {
		Me = GetHandle( "BR_EventHalloweenWnd" );
		Today = GetHandle( "BR_EventHalloweenTodayWnd" );
	}
	else {
		Me = GetWindowHandle( "BR_EventHalloweenWnd" );
		Today = GetWindowHandle( "BR_EventHalloweenTodayWnd" );
		
	}
	WindowState = 0;
}

function OnEvent( int Event_ID, string param )
{
	local int Show;
	
	switch( Event_ID )
	{		
	case EV_BR_EventHalloweenShow : 
		ParseInt(param, "Show", Show ); 
		if(Show==0)
		{
			if(Me.isShowWindow()){Me.HideWindow();}		
		}
		else
		{		
			if(!Me.isShowWindow()){Me.ShowWindow();}
			AddSystemMessage(6027); // [할로윈 이벤트 기간입니다]
		}	
	}
}

function OnClickButton( string Name )
{
	switch( Name )
	{
	case "EventHalloweenBtn1": // 전날 기록
		OnEventHalloBtnRankClick(2, 1);
		break;
	case "EventHalloweenBtn2": // 오늘 기록
		OnEventHalloBtnRankClick(1, 2);
		break;
	case "EventHalloweenBtn3":
		OnEventHalloBtnHelpClick();
		break;
	}
}

function OnEventHalloBtnRankClick(int me, int other)
{
	if(IsShowWindow("BR_EventHalloweenTodayWnd")) {
		if(WindowState == me) { // 같은 내용이면 창을 닫음
			HideWindow("BR_EventHalloweenTodayWnd");
			WindowState = 0; 
		}		
		else if(WindowState == other) { // 다른 내용이 이미 보여지고 있으면
			Today.KillTimer( 200901 );
			RequestBR_EventRankerList(20091031, me-1, 1); // 창은 그대로 두고, 텍스트 내용만 교체 (이벤트ID, 오늘:0/전날:1, 랭킹)
			WindowState = me; 
			Today.SetTimer( 200901, 7000 ); // 내용이 바뀌므로 새로운 7초 타이머를 시작함
		}
	}
	else {		
		RequestBR_EventRankerList(20091031, me-1, 1);
		ShowWindowWithFocus("BR_EventHalloweenTodayWnd");			
		WindowState = me; 
	}

}

function OnEventHalloBtnHelpClick()
{	
	local string strParam;	

	if(IsShowWindow("BR_EventHtmlWndA"))
	{
		HideWindow("BR_EventHtmlWndA");		
	}
	else
	{
		ShowWindowWithFocus("BR_EventHtmlWndA");		
		ParamAdd(strParam, "FilePath", "..\\L2text\\br_eventhalloween000.htm");
		ParamAdd(strParam, "Title", GetSystemString(5036));
		ExecuteEvent(EV_BR_EventCommonHtml1, strParam);
	}
}
defaultproperties
{
}
