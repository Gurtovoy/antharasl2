/**
 * 
 *   GFX 용 플래시로 만든 디버그 
 *   
 **/

class GfxDebug extends L2UIGFxScript;

function OnRegisterEvent()
{	
	RegisterGFxEvent( EV_GFXDEBUG_EVENT );
	RegisterGFxEvent( EV_GFXDEBUG_CALL );
	RegisterGFxEvent( EV_GFXDEBUG_RETURN );
	RegisterGFxEvent( EV_GFXDEBUG_RUNTIME_ERROR );
	//RegisterGFxEvent( EV_GFXDEBUG_INVOKE_ERROR );
	RegisterGFxEvent( EV_TEST_8 );
}

function OnLoad()
{	
	//registerState( "GfxDebug", "GamingState" );

	// gfxDebug
	SetContainerWindow(WINDOWTYPE_DECO_NORMAL, 3365);
	AddState("GAMINGSTATE");
	//setDefaultShow(true);
	//SetAnchor("", EAnchorPointType.ANCHORPOINT_CenterCenter, EAnchorPointType.ANCHORPOINT_CenterCenter, 0 , 0);
}

function onCallUCFunction( string functionName, string param )
{
	//local string strParam;
	switch ( functionName ) 
	{
		case "ucExecuteCommand" :
			 if (param != "") 
			 {
		 		ExecuteCommand(param);
		 	 }
			 break;
		
	}
}


defaultproperties
{
}
