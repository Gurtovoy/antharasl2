// AbilityWnd

class AbilityWnd extends L2UIGFxScript;

function OnRegisterEvent()
{	
	RegisterGFxEvent( EV_AbilityListStart );
	RegisterGFxEvent( EV_AbilityListItem );
	//RegisterGFxEvent( EV_AdenaInvenCount );
	RegisterGFxEvent( EV_UpdateUserInfo );
	RegisterGFxEvent( EV_AbilityWndShow );
	RegisterGFxEvent( EV_AbilityWndClose );
	RegisterGFxEvent( EV_Restart );
}

function OnLoad()
{	
	registerState( "AbilityWnd", "GamingState" );

	SetContainerWindow(WINDOWTYPE_DECO_NORMAL, 3151);
	AddState("GAMINGSTATE");
	//setDefaultShow(true);
	//SetAnchor("", EAnchorPointType.ANCHORPOINT_CenterCenter, EAnchorPointType.ANCHORPOINT_CenterCenter, 0 , 0);
}

function onCallUCFunction( string functionName, string param )
{
	local string strParam;
	//Debug("sampe's onCallUCFunction" @ functionName @ param);
	switch ( functionName ) 
	{
		case "OpenHelpHTML" :
			ParamAdd(strParam, "HtmlFile", "..\\L2text\\"$param);
			ParamAdd(strParam, "ViewerType", "2");			
			ExecuteEvent(EV_TutorialViewerWndShowHtmlFile, strParam);
		break;
		
	}
}
defaultproperties
{
}
