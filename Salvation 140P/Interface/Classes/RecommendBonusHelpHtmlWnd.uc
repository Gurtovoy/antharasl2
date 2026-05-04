class RecommendBonusHelpHtmlWnd extends UICommonAPI;

var WindowHandle Me;
var TextureHandle texBack;
var HtmlHandle htmlViewerRecommendBonusHelp;

function OnRegisterEvent()
{
	RegisterEvent(EV_ShowNewVoteSystemHelp);
}

function OnLoad()
{
	OnRegisterEvent();
	Initialize();
}

function Initialize()
{
	Me = GetWindowHandle( "RecommendBonusHelpHtmlWnd" );
	texBack = GetTextureHandle( "RecommendBonusHelpHtmlWnd.texBack" );
	htmlViewerRecommendBonusHelp = GetHtmlHandle( "RecommendBonusHelpHtmlWnd.htmlViewerRecommendBonusHelp" );
}

function OnEvent(int Event_ID, string param)
{
	switch(Event_ID)
	{

		case EV_ShowNewVoteSystemHelp: OnShow (); break;
	}
}

function OnShow ()
{
	ShowHelp("..\\L2text\\event_2010_bless001.htm");
}

function ShowHelp(string strPath)
{
	if (Len(strPath)>0)
	{		
		htmlViewerRecommendBonusHelp.LoadHtml(strPath);

		Me.ShowWindow();
		Me.SetFocus();
	}			
}

defaultproperties
{
}
