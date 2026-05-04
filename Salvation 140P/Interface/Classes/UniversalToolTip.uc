class UniversalTooltip extends UICommonAPI;

var array<string> G_CompName_List;
var array<int> G_ToolTipTitle_Str;
var array<int> G_ToolTip_Text;
var int maxLength;
var WindowHandle UniversalTooltip;
var TextBoxHandle ToolTipText;
var TextBoxHandle TitleText;
var bool g_Enable;
var int g_Position;

function OnLoad()
{
	//~ UniversalTooltip = GetHandle( "UniversalTooltip" );
	//~ ToolTipText = TextBoxHandle(GetHandle( "TextCurrent" ));
	//~ TitleText = TextBoxHandle(GetHandle( "TextTitle" ));
	
	RegisterEvent( EV_MouseOver );
	RegisterEvent( EV_MouseOut );
	RegisterEvent(EV_ResolutionChanged);
	
	//~ FillToolTipList();
	//~ maxLength = G_CompName_List.length;
	//~ UniversalTooltip.HideWindow();
	//~ g_Enable =  GetOptionBool( "Game", "UniversalToolTipBox" );
	//~ g_Position = GetOptionInt( "Game", "ToolTipPositionBox" );
	//~ SetPosition();
}
/*
//~ function OnShow()
//~ {
	//~ g_Enable =  GetOptionBool( "Game", "UniversalToolTipBox" );
	//~ g_Position = GetOptionInt( "Game", "ToolTipPositionBox" );
	//~ SetPosition();
//~ }


function OnEvent( int a_EventID, String a_Param )
{
	//~ local string ParentWndName;
	//~ local string CurrentWndName;
	//~ local string FullWndName;
	//~ 7월 6일 미리 보기 행사 관련 임시로 유니버설 툴팁 기능 중단 합니다.
	//~ switch( a_EventID )
	//~ {
	//~ case EV_MouseOver:
		//~ ParseString(a_Param, "TopWndName", ParentWndName);
		//~ ParseString(a_Param, "Name", CurrentWndName);
		//~ FullWndName = ParentWndName$"."$CurrentWndName;
		//~ ShowToolTip(FullWndName);
		//~ break;
	
	//~ case EV_MouseOut:
		//~ UniversalTooltip.HideWindow();
		//~ ToolTipText.SetText("");
		//~ TitleText.SetText("");
		//~ break;
	
	//~ case EV_ResolutionChanged:
		//~ SetPosition();
		//~ break;
	
	//~ }
}

function ShowToolTip(string WndName)
{
	local int i;
	
	if (g_Enable == false)
	{
		for (i=1;i<maxLength;++i)
		{
			if (G_CompName_List[i] == WndName)
			{
				//~ debug ("결과텍스트" @ GetSystemString(G_ToolTipTitle_Str[i]));
				//~ debug ("결과텍스트1" @ GetSystemMessage(G_ToolTip_Text[i]));
				//~ MakeTooltipSimpleText(GetSystemMessage(G_ToolTip_Text[i]));
				UniversalTooltip.ShowWindow();
				TitleText.SetText(GetSystemString(G_ToolTipTitle_Str[i]));
				ToolTipText.SetText(GetSystemMessage(G_ToolTip_Text[i]));
				
			}
		}
	}
	else
	{
		UniversalTooltip.HideWindow();
	}
	
}

function SetPosition()
{
	local int g_CurrentMaxWidth;
	local int g_CurrentMaxHeight;
	GetCurrentResolution(g_CurrentMaxWidth, g_CurrentMaxHeight);
	UniversalTooltip.MoveTo( 1, 1);
	switch(g_Position)
	{
		case 0:
			UniversalTooltip.MoveTo( 210, 50);
			break;
		case 1:
			UniversalTooltip.Move(g_CurrentMaxWidth - 500, 50);
			break;
		case 2:
			UniversalTooltip.Move(350, g_CurrentMaxHeight-250);
			break;
		case 3:
			UniversalTooltip.Move(g_CurrentMaxWidth - 500, g_CurrentMaxHeight-250);
			break;
	}
}

function FillToolTipList()	
{	
	G_CompName_List[1] = "SystemMenuWnd.btnBBS";
	G_ToolTipTitle_Str[1] = 1732;
	G_ToolTip_Text[1] = 2582;
	G_CompName_List[2] = "SystemMenuWnd.btnMacro";
	G_ToolTipTitle_Str[2] = 1733;
	G_ToolTip_Text[2] = 2583;
	G_CompName_List[3] = "SystemMenuWnd.btnHelpHtml";
	G_ToolTipTitle_Str[3] = 1734;
	G_ToolTip_Text[3] = 2584;
	G_CompName_List[4] = "SystemMenuWnd.btnPetition";
	G_ToolTipTitle_Str[4] = 1735;
	G_ToolTip_Text[4] = 2585;
	G_CompName_List[5] = "SystemMenuWnd.btnOption";
	G_ToolTipTitle_Str[5] = 1736;
	G_ToolTip_Text[5] = 2586;
	G_CompName_List[6] = "SystemMenuWnd.btnRestart";
	G_ToolTipTitle_Str[6] = 1737;
	G_ToolTip_Text[6] = 2587;
	G_CompName_List[7] = "SystemMenuWnd.btnQuit";
	G_ToolTipTitle_Str[7] = 1738;
	G_ToolTip_Text[7] = 2588;
	G_CompName_List[8] = "MenuWnd.BtnSkill";
	G_ToolTipTitle_Str[8] = 1739;
	G_ToolTip_Text[8] = 2589;
	G_CompName_List[9] = "MenuWnd.BtnClan";
	G_ToolTipTitle_Str[9] = 1740;
	G_ToolTip_Text[9] = 2590;
	G_CompName_List[10] = "MenuWnd.BtnAction";
	G_ToolTipTitle_Str[10] = 1741;
	G_ToolTip_Text[10] = 2591;
	G_CompName_List[11] = "MenuWnd.BtnQuest";
	G_ToolTipTitle_Str[11] = 1742;
	G_ToolTip_Text[11] = 2592;
	G_CompName_List[12] = "MenuWnd.BtnCharInfo";
	G_ToolTipTitle_Str[12] = 1743;
	G_ToolTip_Text[12] = 2593;
	G_CompName_List[13] = "MenuWnd.BtnInventory";
	G_ToolTipTitle_Str[13] = 1744;
	G_ToolTip_Text[13] = 2594;
	G_CompName_List[14] = "MenuWnd.BtnMap";
	G_ToolTipTitle_Str[14] = 1745;
	G_ToolTip_Text[14] = 2595;
	G_CompName_List[15] = "MenuWnd.SystemMenu";
	G_ToolTipTitle_Str[15] = 1746;
	G_ToolTip_Text[15] = 2596;

}
*/
defaultproperties
{
}
