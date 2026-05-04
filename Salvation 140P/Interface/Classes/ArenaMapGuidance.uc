//------------------------------------------------------------------------------------------------------------------------
//
// Á¦¸ñ         : Menu ½ºÄÉÀÏÆû ¹öÀü - SCALEFORM UI
//                Àü±¤ÆÇ
//
//------------------------------------------------------------------------------------------------------------------------
class ArenaMapGuidance extends L2UIGFxScript;

function OnRegisterEvent()
{	
	RegisterGFxEvent( EV_ArenaDashboard);
	RegisterGFxEvent( EV_ScenePlayStart);
	RegisterGFxEvent( EV_ScenePlay);	
	RegisterEvent( EV_StateChanged );	
}

function OnLoad()
{	
	AddState( "ARENAGAMINGSTATE" );
	AddState( "ARENABATTLESTATE" );
	AddState( "SPECIALCAMERASTATE" );
	SetContainerWindow(WINDOWTYPE_NONE, 0);    
	//setDefaultShow(true);
	setHUD();
	SetHavingFocus( false );
}

function OnFlashLoaded()
{		
	IgnoreUIEvent(true);

	//SetAnchor("", EAnchorPointType.ANCHORPOINT_TopCenter, EAnchorPointType.ANCHORPOINT_TopCenter, 0 , 0);	
}

function OnEvent ( int eventID , String param ) 
{
	switch ( eventID ) 
	{
		case EV_StateChanged :
			//Debug (  param  @  "´ÝÈ÷³ª?? ") ;
			if ( param == "ARENAGAMINGSTATE") HideWindow();
		break;
	}
}

//function OnCallUCFunction ( string funcName, string param ) 
//{
//	switch ( funcName ) 
//	{
//	case "ucExecuteCommand" :
//		ExecuteCommand( param ) ;
//		break;
//	}
//}
defaultproperties
{
}
