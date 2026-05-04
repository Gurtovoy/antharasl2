class BR_EventHalloweenTodayWnd extends UICommonAPI;

var WindowHandle Me;
var TextBoxHandle ServerTextBox;
var TextBoxHandle MyTextBox;
var TextBoxHandle MsgTextBox;
var TextBoxHandle TitleTextBox;

function OnRegisterEvent()
{
	RegisterEvent( EV_BR_EventRankerNowList );	
	RegisterEvent( EV_BR_EventRankerLastList );	
}

function OnLoad()
{
	Initialize();
}

function OnShow()
{
	Me.SetTimer( 200901, 7000 );
	
	TitleTextBox.SetText( GetSystemMessage(2031) );	// [잠시 기다려 주세요] - 패킷이 늦게 오는 경우가 있어서
	ServerTextBox.SetText( "" );	
	MyTextBox.SetText( "" );
	MsgTextBox.SetText( "" );
}

function OnHide()
{
	Me.KillTimer( 200901 );
}

function OnTimer( int TimerID )
{	
	if(TimerID == 200901)
	{
		if( IsShowWindow("BR_EventHalloweenTodayWnd") ) Me.HideWindow(); // 7초 후 자동으로 닫힘
	}
}

function Initialize()
{
	if (CREATE_ON_DEMAND==0) {
		Me = GetHandle( "BR_EventHalloweenTodayWnd" );
		ServerTextBox = TextBoxHandle ( GetHandle( "BR_EventHalloweenTodayWnd.ServerTextBox" ) );		
		MyTextBox = TextBoxHandle ( GetHandle( "BR_EventHalloweenTodayWnd.MyTextBox" ) );		
		MsgTextBox = TextBoxHandle ( GetHandle( "BR_EventHalloweenTodayWnd.MsgTextBox" ) );		
		TitleTextBox = TextBoxHandle ( GetHandle( "BR_EventHalloweenTodayWnd.TitleTextBox" ) );		
	}
	else
	{
		Me = GetWindowHandle( "BR_EventHalloweenTodayWnd" );
		ServerTextBox = GetTextBoxHandle( "BR_EventHalloweenTodayWnd.ServerTextBox" );
		MyTextBox = GetTextBoxHandle( "BR_EventHalloweenTodayWnd.MyTextBox" );
		MsgTextBox = GetTextBoxHandle( "BR_EventHalloweenTodayWnd.MsgTextBox" );
		TitleTextBox = GetTextBoxHandle( "BR_EventHalloweenTodayWnd.TitleTextBox" );
	}
}

function OnEvent(int Event_ID, String a_param)
{
	local int count, bestScore, myScore;
	
	if (Event_ID == EV_BR_EventRankerNowList) // 오늘 기록
	{
		ParseInt(a_param, "Count", count);
		ParseInt(a_param, "BestScore", bestScore);
		ParseInt(a_param, "Myscore", myscore);
		Debug("EV_BR_EventRankerNowList Count: "$count);
		Debug("EV_BR_EventRankerNowList BestScore: "$bestScore);
		Debug("EV_BR_EventRankerNowList Myscore: "$myscore);
		SetTodayTextbox(count, bestScore, myScore);
	}
	else if (Event_ID == EV_BR_EventRankerLastList) // 전날 기록
	{
		ParseInt(a_param, "Count", count); 
		ParseInt(a_param, "BestScore", bestScore);
		ParseInt(a_param, "Myscore", myscore);
		Debug("EV_BR_EventRankerLastList Count: "$count);
		Debug("EV_BR_EventRankerLastList BestScore: "$bestScore);
		Debug("EV_BR_EventRankerLastList Myscore: "$myscore);
		SetLastTextbox(count, bestScore, myScore);
	}
}

function SetTodayTextbox(int count, int bestScore, int myScore)
{
	TitleTextBox.SetText( GetSystemString(5040) );
	
	if (bestScore>=5 ) // 서버 최고 기록 : 5승 이상
		ServerTextBox.SetText( MakeFullSystemMsg( GetSystemMessage(6023), string(bestScore), string(count) ) );
	else // 서버 최고 기록 : 4승 이하
		ServerTextBox.SetText( GetSystemMessage(6025) );
		
	if( myScore>=5 ) // 나의 최고 기록 : 5승 이상
		MyTextBox.SetText( MakeFullSystemMsg( GetSystemMessage(6024), string(myscore), "" ));
	else // 나의 최고 기록 : 4승 이하
		MyTextBox.SetText( GetSystemMessage(6026) );
		
	if( bestScore==myScore && myScore>=0 ) // 내가 1등 일때 & 나의 기록 5승 이상
		MsgTextBox.SetText( GetSystemString(5041) ); // [현재 1위입니다!]
	else
		MsgTextBox.SetText( "" );
}

function SetLastTextbox(int count, int bestScore, int myScore)
{
	TitleTextBox.SetText( GetSystemString(5039) );	
	
	if (bestScore>=10 ) // 서버 최고 기록 : 10승 이상
		ServerTextBox.SetText( MakeFullSystemMsg( GetSystemMessage(6023), string(bestScore), string(count) ) );
	else // 서버 최고 기록 : 9승 이하 or 기록이 없는 경우
		ServerTextBox.SetText( GetSystemMessage(6028) );
		
	if( myScore>=5 ) // 나의 최고 기록 : 5승 이상
		MyTextBox.SetText( MakeFullSystemMsg( GetSystemMessage(6024), string(myscore), "" ));
	else // 나의 최고 기록 : 4승 이하
		MyTextBox.SetText( GetSystemMessage(6026) );
		
	if( bestScore==myScore && bestScore>=10 ) // 내가 1등 일때 & 서버 최고 기록 10승 이상
		MsgTextBox.SetText( GetSystemString(5042) ); // [1위를 축하합니다!]
	else
		MsgTextBox.SetText( "" );
}
defaultproperties
{
}
