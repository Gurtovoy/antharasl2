class CharacterPasswordHelpHtmlWnd extends UICommonAPI;

var WindowHandle Me;
var TextureHandle texBack;
var HtmlHandle htmlViewerCharacterPasswordHelp;

function OnRegisterEvent()
{
	//RegisterEvent(  );
}

function OnLoad()
{
	Initialize();	
}

function Initialize()
{
	Me = GetWindowHandle( "CharacterPasswordHelpHtmlWnd" );
	texBack = GetTextureHandle( "CharacterPasswordHelpHtmlWnd.texBack" );
	htmlViewerCharacterPasswordHelp = GetHtmlHandle( "CharacterPasswordHelpHtmlWnd.htmlViewerCharacterPasswordHelp" );
}

function OnEvent(int Event_ID, string param)
{
}


function OnShow ()
{
	ShowHelp("..\\L2text\\help_characterpassword00.htm");	
}

function ShowHelp(string strPath)
{
	if (Len(strPath)>0)
	{		
		htmlViewerCharacterPasswordHelp.LoadHtml(strPath);

		Me.ShowWindow();
		Me.SetFocus();
	}			
}
defaultproperties
{
}
