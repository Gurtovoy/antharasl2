//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : 몬스터 도감 - SCALEFORM UI
//
//------------------------------------------------------------------------------------------------------------------------
class MonsterBookWnd extends L2UIGFxScript;

function OnRegisterEvent()
{	
	// 10080
	//registerGfxEvent( EV_FactionInfo );		
	registerGfxEvent( EV_MonsterBookStart);	
	registerGfxEvent( EV_MonsterBookInfo );	
	registerGfxEvent( EV_MonsterBookEnd  );	
	//registerGfxEvent( EV_MonsterBookRewardIcon );	
	registerGfxEvent( EV_MonsterBookOpenResult );	
	registerGfxEvent( EV_MonsterBookCloseForce );	
	//registerGfxEvent( EV_FactionInfoRewardIcon );	
	RegisterGFxEventForLoaded( EV_Restart );	
	RegisterGFxEventForLoaded( EV_FactionInfo );	
	 
}

function OnLoad()
{		
	AddState( "GAMINGSTATE" );
	SetContainerWindow(WINDOWTYPE_DECO_NORMAL, 3511);
}
defaultproperties
{
}
