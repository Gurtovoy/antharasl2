class BR_EventFastivalInkWnd extends UICommonAPI;

var int MaxEnergy;
var int CurrentEnergy;

var WindowHandle Me;
var TextureHandle EventInkTex;
var TextureHandle EventInkTexBG;
var ButtonHandle HelpButton;
var StatusBarHandle GoalGage1;
var StatusBarHandle GoalGage2;
var StatusBarHandle GoalGageMax;
var bool m_showInk;

function OnRegisterEvent()
{
	RegisterEvent( EV_BR_EventFastivalInkMax );
	RegisterEvent( EV_BR_EventFastivalInkEnergy );
	
	RegisterEvent( EV_StateChanged );
}

function OnLoad()
{
	Initialize();
	Load();
}

function Initialize()
{
	if (CREATE_ON_DEMAND==0) {
		Me = GetHandle( "BR_EventFastivalInkWnd" );
		EventInkTex = TextureHandle ( GetHandle( "BR_EventFastivalInkWnd.EventInkTex" ) );
		EventInkTexBG = TextureHandle ( GetHandle( "BR_EventFastivalInkWnd.EventInkTexBG" ) );
		HelpButton = ButtonHandle ( GetHandle( "BR_EventFastivalInkWnd.HelpButton" ) );
		GoalGage1 = GetStatusBarHandle( "BR_EventFastivalInkWnd.GoalGage1" );
		GoalGage2 = GetStatusBarHandle( "BR_EventFastivalInkWnd.GoalGage2" );
		GoalGageMax = GetStatusBarHandle( "BR_EventFastivalInkWnd.GoalGageMax" );
		
	}
	else {
		Me = GetWindowHandle( "BR_EventFastivalInkWnd" );
		EventInkTex = GetTextureHandle( "BR_EventFastivalInkWnd.EventInkTex" );
		EventInkTexBG = GetTextureHandle( "BR_EventFastivalInkWnd.EventInkTexBG" );
		HelpButton = GetButtonHandle( "BR_EventFastivalInkWnd.HelpButton" );
		GoalGage1 = GetStatusBarHandle( "BR_EventFastivalInkWnd.GoalGage1" );
		GoalGage2 = GetStatusBarHandle( "BR_EventFastivalInkWnd.GoalGage2" );
		GoalGageMax = GetStatusBarHandle( "BR_EventFastivalInkWnd.GoalGageMax" );
	}
	MaxEnergy=10000;
	CurrentEnergy=0;
	GoalGageMax.SetPointExpPercentRate( 1 );
	GoalGageMax.HideWindow();
	
	Me.HideWindow();
	EventInkTexBG.HideWindow();
	
	m_showInk = false;
	//¿Ï·á 
	
	
}

function Load()
{
	HelpButton.SetTooltipCustomType(SetTooltip(GetSystemString(5148)));
}

function OnEvent( int a_EventID, String a_Param )
{
	local int iEnergy;

	switch( a_EventID )
	{
	case EV_BR_EventFastivalInkMax:		
		ParseInt(a_param, "Energy", iEnergy);
        EventInkWndShow(iEnergy);		
		break;
	case EV_BR_EventFastivalInkEnergy:		
		ParseInt(a_param, "Energy", iEnergy);
        FireEventGauge(iEnergy);					
		break;	
	}
	
	if( a_EventID == EV_StateChanged )
	{
		if (a_Param == "GAMINGSTATE")
		{
			if( m_showInk == true )
			{
				if(!Me.isShowWindow())
				{
					Me.ShowWindow();
				}
			}
		}
		
	}
}

function EventInkWndShow(int iMaxEnergy)
{
	if(!Me.isShowWindow())
	{
		Me.ShowWindow();
	}
	MaxEnergy = iMaxEnergy;	
	GoalGage1.SetPointExpPercentRate( 0 );
	GoalGage2.SetPointExpPercentRate( 0 );
	
	m_showInk = true;	
}

function FireEventGauge(int iEnergy)
{	
	local float convertpercent;
	
	CurrentEnergy = iEnergy;
	
	convertpercent = float(CurrentEnergy) / float(MaxEnergy);
	
	if( convertpercent >= 1.0 )
	{
		GoalGage1.SetPointExpPercentRate( 1 );
		EventInkTex.SetTexture("BranchSys3.icon1.g_ev_invite_ink_03");
		GoalGage1.HideWindow();
		GoalGage2.HideWindow();
		GoalGageMax.ShowWindow();
		EventInkTexBG.ShowWindow();
	}
	else
	{
		if( convertpercent >= 0.1429 )
		{	
			EventInkTex.SetTexture("BranchSys3.icon1.g_ev_invite_ink_02");			
			GoalGage2.ShowWindow();
			GoalGage1.HideWindow();
			GoalGage2.SetPointExpPercentRate( convertpercent );
		}
		else
		{
			EventInkTex.SetTexture("BranchSys3.icon1.g_ev_invite_ink_01");
			GoalGage1.ShowWindow();
			GoalGage2.HideWindow();
			GoalGage1.SetPointExpPercentRate( convertpercent );
		}		
		GoalGageMax.HideWindow();
		EventInkTexBG.HideWindow();
	}		        
}

function CustomTooltip SetTooltip(string Text)
{
	local CustomTooltip Tooltip;
	local DrawItemInfo info;
	
	Tooltip.MinimumWidth = 144;
	
	Tooltip.DrawList.Length = 1;
	info.eType = DIT_TEXT;
	info.t_bDrawOneLine = true;
	info.t_color.R = 178;
	info.t_color.G = 190;
	info.t_color.B = 207;
	info.t_color.A = 255;
	info.t_strText = Text;
	Tooltip.DrawList[0] = info;

	return Tooltip;
}

function OnClickButton( string Name )
{
	switch( Name )
	{
	case "HelpButton":
		OnHelpButtonClick();
		break;
	}
}

function OnEventFireBtn1Click()
{
}

function OnHelpButtonClick()
{
	
}
defaultproperties
{
}
