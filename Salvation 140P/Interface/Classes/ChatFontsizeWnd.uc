class ChatFontsizeWnd extends UICommonAPI;

var WindowHandle Me;

var ButtonHandle m_hFontSize_0;
var ButtonHandle m_hFontSize_1;
var ButtonHandle m_hFontSize_2;

var CheckBoxHandle btnAttributeSelect0;
var CheckBoxHandle btnAttributeSelect1;
var CheckBoxHandle btnAttributeSelect2;

var TextBoxHandle fontSizeText0;
var TextBoxHandle fontSizeText1;
var TextBoxHandle fontSizeText2;

var TextBoxHandle sampleText0;
var TextBoxHandle sampleText1;
var TextBoxHandle sampleText2;

var int m_SelectFontIndex;

function OnRegisterEvent()
{
}

function OnLoad()
{
	SetClosingOnESC();
	
	Me = GetWindowHandle("ChatFontsizeWnd");
	m_hFontSize_0 = GetButtonHandle("ChatFontsizeWnd.btnListSelect0");
	m_hFontSize_1 = GetButtonHandle("ChatFontsizeWnd.btnListSelect1");
	m_hFontSize_2 = GetButtonHandle("ChatFontsizeWnd.btnListSelect2");

	btnAttributeSelect0 = GetCheckBoxHandle( "ChatFontsizeWnd.btnAttributeSelect0" );
	btnAttributeSelect1 = GetCheckBoxHandle( "ChatFontsizeWnd.btnAttributeSelect1" );
	btnAttributeSelect2 = GetCheckBoxHandle( "ChatFontsizeWnd.btnAttributeSelect2" );
	
	fontSizeText0		=GetTextboxHandle("ChatFontsizeWnd.ChatFontSizeExemple0");
	fontSizeText1		=GetTextboxHandle("ChatFontsizeWnd.ChatFontSizeExemple1");
	fontSizeText2		=GetTextboxHandle("ChatFontsizeWnd.ChatFontSizeExemple2");

	sampleText0		=GetTextboxHandle("ChatFontsizeWnd.ChatFontSizeExemple_0");
	sampleText1		=GetTextboxHandle("ChatFontsizeWnd.ChatFontSizeExemple_1");
	sampleText2		=GetTextboxHandle("ChatFontsizeWnd.ChatFontSizeExemple_2");


	fontSizeText0.SetText(" " $ GetSystemString(2636));
	fontSizeText1.SetText(" " $ GetSystemString(3163));
	fontSizeText2.SetText(" " $ GetSystemString(2637));

	sampleText0.SetFontIDByName( "chatFontSize10" );
	sampleText1.SetFontIDByName( "chatFontSize11" );
	sampleText2.SetFontIDByName( "chatFontSize12" );
}
  
function OnShow()
{
	local int vars;

	GetINIInt("global","ChatFontSizeSaved", vars, "chatfilter.ini");
	m_SelectFontIndex = vars;	
	setRadioButton(vars);
}

function OnEvent(int Event_ID, String param)
{
	switch( Event_ID )
	{
	}
}

function LoadDefaultVaule()
{

}

function RequestChangeFont(int fontType)
{
	local ChatWnd	script;
	script = ChatWnd( GetScript("ChatWnd") );	
	script.SetChangeFont(fontType);
}

function CloseFontSizeWnd()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( "ChatFontsizeWnd" ).HideWindow();
}

function OnClickButton(string strID)
{
	if( strID == "CloseButton" )
	{
		CloseFontSizeWnd();
	}
	else if(strID == "ChatFilterOK")
	{
		SetINIInt("global","ChatFontSizeSaved", m_SelectFontIndex, "chatfilter.ini");
		RequestChangeFont(m_SelectFontIndex);
		CloseFontSizeWnd();
	}
	else if(strID == "ChatFilterCancel")
	{
		CloseFontSizeWnd();
	}
	else if(strID == "btnListSelect0")
	{
		setRadioButton(0);
	}
	else if(strID == "btnListSelect1")
	{
		setRadioButton(1);
	}
	else if(strID == "btnListSelect2")
	{
		setRadioButton(2);
	}
}

function setRadioButton (int selectNum)
{
	btnAttributeSelect0.SetCheck(false);
	btnAttributeSelect1.SetCheck(false);
	btnAttributeSelect2.SetCheck(false);
	m_SelectFontIndex = selectNum;
	if (selectNum == 1)
	{
		btnAttributeSelect1.SetCheck(true);
	}
	else if (selectNum == 2)
	{
		btnAttributeSelect2.SetCheck(true);
	}
	else
	{
		btnAttributeSelect0.SetCheck(true);		
	}	
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( "ChatFontsizeWnd" ).HideWindow();
}
defaultproperties
{
}
