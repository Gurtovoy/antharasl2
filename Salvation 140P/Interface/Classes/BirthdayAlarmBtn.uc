
class BirthdayAlarmBtn extends UICommonAPI;

var WindowHandle Me;
var WindowHandle BirthdayAlarmWnd;
var ButtonHandle btnItemPop;

function OnRegisterEvent()
{
	RegisterEvent( EV_BirthdayItemAlarm);
}

function OnLoad()
{
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	if(CREATE_ON_DEMAND==0)
		Initialize();
	else
		InitializeCOD();
}

function Initialize()
{
	
		Me = GetHandle( "BirthdayAlarmBtn" );
		BirthdayAlarmWnd = GetHandle( "BirthdayAlarmWnd" );
		btnItemPop = ButtonHandle ( GetHandle( "BirthdayAlarmBtn.btnItemPop" ) );
	
	
	//btnItemPop.SetTooltipCustomType(MakeTooltipSimpleText(GetSystemMessage(2313)));	// 툴팁. 프리미엄 아이템이 도착하였습니다.
}

function InitializeCOD()
{
		Me = GetWindowHandle( "BirthdayAlarmBtn" );
		BirthdayAlarmWnd = GetWindowHandle( "BirthdayAlarmWnd" );
		btnItemPop = GetButtonHandle ("BirthdayAlarmBtn.btnItemPop" );
	
}

// 버튼을 클릭하면 알림창 팝업
function OnClickButton( string Name )
{
	switch( Name )
	{
		case "btnItemPop":
			if(!BirthdayAlarmWnd.isShowWindow()) 
			BirthdayAlarmWnd.showWindow();
			Me.hideWindow();
			Me.SetWindowSize( 0 , 32);	//윈도우의 크기를 재조정해준다. 
			break;
	}
}

// 이벤트를 받아 데이터를 파싱한다. 
function OnEvent(int Event_ID, string a_param)
{
	switch(Event_ID)
	{
		case EV_BirthdayItemAlarm:
			Me.SetWindowSize( 32 , 32);	//윈도우의 크기를 재조정해준다. 
			ShowWindowWithFocus("BirthdayAlarmBtn");
			btnItemPop.ShowWindow();
			class'UIAPI_EFFECTBUTTON'.static.BeginEffect("BirthdayAlarmBtn.btnItemPop", 0);
			//AddSystemMessage(2313);	
		break;
	}
}

//상태가 변할 경우 무조건 닫아준다.
function OnExitState( name a_NextStateName )
{
	Me.SetWindowSize( 0 , 32);	//윈도우의 크기를 재조정해준다. 
	Me.HideWindow();	
}
defaultproperties
{
}
