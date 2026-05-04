class PremiumItemAlarmWnd extends UICommonAPI;

var WindowHandle Me;
var TextureHandle CTextureCtrl1038;
var TextBoxHandle CTextBox1039;
var ButtonHandle btnOK;

function OnLoad()
{
	Initialize();
	Load();
}

function Initialize()
{
	if(CREATE_ON_DEMAND==0)
	{
		Me = GetHandle( "PremiumItemAlarmWnd" );
		CTextureCtrl1038 = TextureHandle ( GetHandle( "CFrameWnd461.CTextureCtrl1038" ) );
		CTextBox1039 = TextBoxHandle ( GetHandle( "CFrameWnd461.CTextBox1039" ) );
		btnOK = ButtonHandle ( GetHandle( "CFrameWnd461.CButton1414" ) );
	}
	else
	{
		Me = GetWindowHandle( "PremiumItemAlarmWnd" );
		CTextureCtrl1038 = GetTextureHandle ( "CFrameWnd461.CTextureCtrl1038" );
		CTextBox1039 = GetTextBoxHandle ( "CFrameWnd461.CTextBox1039" );
		btnOK = GetButtonHandle ( "CFrameWnd461.CButton1414" );
	}
}

function Load()
{

}
function OnEvent(int Event_ID, String param)
{

}
function OnClickButton( string Name )
{
	switch( Name )
	{
	case "btnOK":
		Me.hideWindow();
		break;
	}
}

//상태가 변할 경우 무조건 닫아준다.
function OnExitState( name a_NextStateName )
{
	Me.HideWindow();
}
defaultproperties
{
}
