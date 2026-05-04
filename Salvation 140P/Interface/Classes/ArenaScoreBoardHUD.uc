//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : Menu 스케일폼 버전 - SCALEFORM UI
//                전광판
//
//------------------------------------------------------------------------------------------------------------------------
class ArenaScoreBoardHUD extends L2UIGFxScript;

function OnRegisterEvent()
{	
	RegisterGFxEvent( EV_ArenaDashboard);
	RegisterGFxEvent( EV_ArenaKillInfo);
	RegisterGFxEvent( EV_UpdateHP);	
	RegisterGFxEvent( EV_InventoryUpdateItem ); 
	RegisterEvent( EV_StateChanged);
}

function OnLoad()
{	
	AddState( "ARENABATTLESTATE" );
	AddState( "ARENAGAMINGSTATE" );	
	AddState("ARENAOBSERVERSTATE");
	SetContainerHUD(WINDOWTYPE_NONE, 0);    
	SetHavingFocus( false );
}

function OnFlashLoaded()
{		
	IgnoreUIEvent(true);
	SetAnchor("", EAnchorPointType.ANCHORPOINT_TopCenter, EAnchorPointType.ANCHORPOINT_TopCenter, 0 , 0);	
}


function onEvent ( int id, string param) 
{	
	switch ( id ) 
	{
		// 스테이트 변경 시 open 해 둬야 as 설정이 됨.
		case EV_StateChanged : 
			if( param == "ARENABATTLESTATE" || param == "ARENAOBSERVERSTATE" ) ShowWindow ( getCurrentWindowName(string(Self)) );
			else hideWindow ( getCurrentWindowName(string(Self)) );
		break;
	}
}
defaultproperties
{
}
