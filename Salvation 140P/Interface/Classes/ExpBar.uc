class ExpBar extends L2UIGFxScript;

function OnRegisterEvent()
{	
	RegisterGFxEvent( EV_UpdateUserInfo );
	
	RegisterGFxEvent( EV_Restart );

	RegisterGFxEvent( EV_UnReadMailCount );
	RegisterGFxEvent( EV_PledgeCount );
	RegisterGFxEvent( EV_AdenaInvenCount );
	RegisterGFxEvent( EV_SetMaxCount );
	RegisterGFxEvent( EV_ClanInfo );
	RegisterGFxEvent( EV_GFx_ClanInfo );
	RegisterGFxEvent( EV_ClanDeleteAllMember );
	RegisterGFxEvent( EV_GFx_ClanDeleteAllMember );
	RegisterGFxEvent( EV_NeedResetUIData );

	//RegisterGFxEvent( EV_SPInfo );

	RegisterGFxEvent( EV_AbilityListStart );
}

function OnLoad()
{		
	AddState("GAMINGSTATE");
	AddState("ARENAGAMINGSTATE");
	AddState("ARENABATTLESTATE");
	AddState("ARENAPICKSTATE");
	SetContainerHUD(WINDOWTYPE_NONE, 0);
	SetDefaultShow(true);
	SetHavingFocus( false );
	setHUD();
	//SetAnchor("", EAnchorPointType.ANCHORPOINT_BottomRight, EAnchorPointType.ANCHORPOINT_TopLeft, 0, 0 );
}
defaultproperties
{
}
