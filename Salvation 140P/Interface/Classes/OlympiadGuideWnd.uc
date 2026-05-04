class OlympiadGuideWnd extends UICommonAPI;

var WindowHandle Me;
var ButtonHandle CloseButton;
var TextBoxHandle TitleTextBox;
var TextBoxHandle TextWASD;
var TextBoxHandle TextPageUpDown;
var TextBoxHandle TextRecord;
var TextBoxHandle TextMove;
var TextBoxHandle TextViewPoint;
var TextBoxHandle TextViewMove;
var TextureHandle GroupBg;
var TextureHandle GuideImg;

var bool open;

const TIMER_ID=151;
const TIMER_DELAY=5000;

function OnRegisterEvent()
{
	RegisterEvent( EV_EnterOlympiadObserverMode );
}

//선준 수정(10.04.01) 완료
function OnEvent( int Event_ID, String Param )
{
	switch(Event_ID)
	{
	case EV_EnterOlympiadObserverMode:		
		open = true;
		m_hOwnerWnd.SetTimer( TIMER_ID, TIMER_DELAY );
		break;
	}
	
}
function OnLoad()
{
	Initialize();
	Load();
}

function Initialize()
{
	Me = GetWindowHandle( "OlympiadGuideWnd" );
	CloseButton = GetButtonHandle( "OlympiadGuideWnd.CloseButton" );
	TitleTextBox = GetTextBoxHandle( "OlympiadGuideWnd.TitleTextBox" );
	TextWASD = GetTextBoxHandle( "OlympiadGuideWnd.TextWASD" );
	TextPageUpDown = GetTextBoxHandle( "OlympiadGuideWnd.TextPageUpDown" );
	TextRecord = GetTextBoxHandle( "OlympiadGuideWnd.TextRecord" );
	TextMove = GetTextBoxHandle( "OlympiadGuideWnd.TextMove" );
	TextViewPoint = GetTextBoxHandle( "OlympiadGuideWnd.TextViewPoint" );
	TextViewMove = GetTextBoxHandle( "OlympiadGuideWnd.TextViewMove" );
	GroupBg = GetTextureHandle( "OlympiadGuideWnd.GroupBg" );
	GuideImg = GetTextureHandle( "OlympiadGuideWnd.GuideImg" );	
}

function Load()
{	
}

function onShow()
{
	Me.SetFocus();
}

function OnClickButton( string Name )
{
	switch( Name )
	{
	case "CloseButton":
		OpenCloseGuide();
		break;
	}
}


function OnTimer(int TimerID)
{
	switch( TimerID )
	{
	case TIMER_ID:
		m_hOwnerWnd.KillTimer( TIMER_ID );
		m_hOwnerWnd.SetAlpha( 0, 1000 );
		open = false;
		break;
	}
}


function OpenCloseGuide()
{
	if(open)
	{
		Me.KillTimer( TIMER_ID );
		Me.HideWindow();
	}
	else
	{
		Me.SetAlpha( 255 );
		Me.ShowWindow();
	}
	open = !open;
}


function MysteriousMansionShow() //의문의 저택 에서 가이드 윈도우를 염
{	
	open = false;	
	Me.KillTimer( TIMER_ID );
	Me.SetAlpha( 255 );
	Me.ShowWindow();		
	
}

function MysteriousMansionHide() //의문의 저택 에서 가이드 윈도우를 닫음
{	
	open = true;	
	Me.KillTimer( TIMER_ID );	
	Me.HideWindow();
	
}
defaultproperties
{
}
