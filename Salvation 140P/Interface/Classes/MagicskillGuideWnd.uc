class MagicskillGuideWnd extends UICommonAPI;

var WindowHandle Me;
var String g_WindowName;
var ButtonHandle btn_01;
var ButtonHandle btn_02;
var ButtonHandle btn_03;
var ButtonHandle btn_04;

var TextBoxHandle BtnText_01;
var TextBoxHandle BtnText_02;
var TextBoxHandle BtnText_03;
var TextBoxHandle BtnText_04;

const BTN_MAX_LENGTH = 150;

var HtmlHandle HtmlViewer_02;

function Initialize()
{
	Me = GetWindowHandle( g_WindowName );
	
	HtmlViewer_02 = GetHtmlHandle(g_WindowName$".HtmlViewer_02");
	btn_01 = GetButtonHandle (g_WindowName$".btn_01");
	btn_02 = GetButtonHandle (g_WindowName$".btn_02");
	btn_03 = GetButtonHandle (g_WindowName$".btn_03");
	btn_04 = GetButtonHandle (g_WindowName$".btn_04");
	
	BtnText_01 = GetTextBoxHandle (g_WindowName$".BtnText_01");
	BtnText_02 = GetTextBoxHandle (g_WindowName$".BtnText_02");
	BtnText_03 = GetTextBoxHandle (g_WindowName$".BtnText_03");
	BtnText_04 = GetTextBoxHandle (g_WindowName$".BtnText_04");	
}

function OnLoad()
{
	Initialize();
	SetClosingOnESC();
}

function setBtnText ( TextBoxHandle BtnText, ButtonHandle btn, string str ) 
{
	local int textSizeWidth;
	local int textSizeHeight;
	local string sysString;

	sysString = str;

	GetTextSize(str, "GameDefault", textSizeWidth, textSizeHeight) ;
	
	if ( textSizeWidth > BTN_MAX_LENGTH )
	{		
		btn.SetTooltipCustomType(MakeTooltipSimpleText( sysString ));
		sysString = makeShortStringByPixel ( str, BTN_MAX_LENGTH, ".." );
	}
	
	BtnText.SetText( sysString );
	GetTextSize(sysString, "GameDefault", textSizeWidth, textSizeHeight);
	btn.SetWindowSize ( textSizeWidth + 2 , 14 );
}

function OnShow()
{
	PlayConsoleSound(IFST_WINDOW_OPEN);

	HtmlViewer_02.LoadHtml("..\\L2text\\skill_enchant_guide.htm");

	setBtnText ( BtnText_01, btn_01, GetSystemString(2070));
	setBtnText ( BtnText_02, btn_02, GetSystemString(2069));
	setBtnText ( BtnText_03, btn_03, GetSystemString(2038)@GetSystemString(2068));
	setBtnText ( BtnText_04, btn_04, GetSystemString(2098) );
}

function OnClickButton( string Name )
{
	switch( Name)
	{
	case "btn_01":
		Onbtn_01Click();
		break;
	case "btn_02":
		Onbtn_02Click();
		break;
	case "btn_03":
		Onbtn_03Click();
		break;
	case "btn_04":
		Onbtn_04Click();
		break;
	}
}

function Onbtn_01Click()
{
	HtmlViewer_02.Clear();
	HtmlViewer_02.LoadHtml("..\\L2text\\skill_enchant_guide_1.htm");
}

function Onbtn_02Click()
{
	HtmlViewer_02.Clear();
	HtmlViewer_02.LoadHtml("..\\L2text\\skill_enchant_guide_2.htm");
}

function Onbtn_03Click()
{
	HtmlViewer_02.Clear();
	HtmlViewer_02.LoadHtml("..\\L2text\\skill_enchant_guide_3.htm");
}


function Onbtn_04Click()
{
	HtmlViewer_02.Clear();
	HtmlViewer_02.LoadHtml("..\\L2text\\skill_enchant_guide_4.htm");
}

function OnHide()
{

}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( g_WindowName ).HideWindow();
}

defaultproperties
{
    g_WindowName="MagicskillGuideWnd"
}
