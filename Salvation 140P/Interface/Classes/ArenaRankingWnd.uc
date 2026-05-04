//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : 아레나 랭킹 - SCALEFORM UI
//
//------------------------------------------------------------------------------------------------------------------------
class ArenaRankingWnd extends L2UIGFxScript;

function OnRegisterEvent()
{	
	// 10080
	//registerGfxEvent( EV_FactionInfo );		
	registerGfxEvent( EV_ArenaRankAll );	
	registerGfxEvent( EV_ArenaMyRank );	
	//registerGfxEvent( EV_RESTART );	
}

function OnLoad()
{		
	AddState("ARENAGAMINGSTATE");
	AddState("ARENABATTLESTATE");
	SetContainerWindow(WINDOWTYPE_DECO_NORMAL, 4528 );
}
defaultproperties
{
}
