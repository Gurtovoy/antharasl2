//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : Menu 스케일폼 버전 - SCALEFORM UI
//                메인 메뉴
//
//------------------------------------------------------------------------------------------------------------------------
class ArenaRevivalWnd extends L2UIGFxScript;

function OnRegisterEvent()
{	
	RegisterGFxEvent( EV_Die );
	RegisterGFxEvent( EV_ChatMessage );
	RegisterGFxEvent( EV_Restart );
	//RegisterEvent ( EV_UpdateMyHP ) ;
	//RegisterEvent( EV_Die );
	RegisterEvent( EV_Restart );
	RegisterEvent( EV_RestartMenuShow );
	RegisterEvent( EV_RestartMenuHide );

	RegisterGFxEvent( EV_StateChanged );
}

function OnLoad()
{		
	AddState( "ARENAGAMINGSTATE" );
	AddState( "ARENABATTLESTATE" );
	AddState( "ARENAPICKSTATE" );
	
	SetContainerWindow(WINDOWTYPE_NONE, 0);
	SetHavingFocus( false );
}

function OnFlashLoaded()
{		
	SetRenderOnTop(true);
	SetAlwaysFullAlpha(true);
	SetAnchor("", EAnchorPointType.ANCHORPOINT_CenterCenter, EAnchorPointType.ANCHORPOINT_CenterCenter, 0 , -50);	
}


function onEvent ( int id, string param) 
{
	//Debug ( "onEvent" @ id @ param ) ;
	switch ( id ) 
	{
	//	case EV_UpdateMyHP : HandleUpdateHP( param ) ;break;
		case EV_RestartMenuShow : ShowWindow() ;break;
		case EV_RestartMenuHide : 
		case EV_Restart :hideWindow() ;break;
	}
}
defaultproperties
{
}
