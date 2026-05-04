//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : Menu 스케일폼 버전 - SCALEFORM UI
//                메인 메뉴
//
//------------------------------------------------------------------------------------------------------------------------
class ArenaSkillUpgrade extends L2UIGFxScript;

function OnRegisterEvent()
{		
	RegisterGFxEvent( EV_SkillListStart);
	RegisterGFxEvent( EV_SkillList);
	RegisterGFxEvent( EV_SkillListEnd );

	RegisterGFxEvent( EV_SkillEnchantInfoWndShow );
	RegisterGFxEvent( EV_SkillEnchantInfoWndAddSkill );	
	//RegisterGFxEvent( EV_SkillEnchantInfoWndAddExtendInfo );
	RegisterGFxEvent( EV_SkillEnchantResult );

//	RegisterEvent( EV_SkillListStart);
//	RegisterEvent( EV_SkillList);
//	RegisterEvent( EV_SkillListEnd );
//	RegisterEvent( EV_SkillEnchantInfoWndAddSkill );
//	RegisterEvent( EV_SkillEnchantResult );

	RegisterEvent( EV_Restart );	
}

function onEvent ( int id, string param) 
{
	switch ( id ) 
	{	
		case EV_Restart :hideWindow() ;break;
	}
}

function OnLoad()
{		
	//AddState( "GAMINGSTATE" );
	AddState( "ARENABATTLESTATE" );
	AddState( "ARENAGAMINGSTATE" );
	//setDefaultShow(true);
	//
	
	SetContainerHUD(WINDOWTYPE_NONE, 0);

	
	SetHavingFocus( false );
}

/*
function onEvent ( int id, string param ) 
{
	Debug ("magicskill" @ id ) ;
}*/

function OnFlashLoaded()
{	
	
	// 스킬 창 위
	SetAnchor("", EAnchorPointType.ANCHORPOINT_BottomCenter, EAnchorPointType.ANCHORPOINT_BottomCenter, 23 , - 130 );

	//SetAnchor("", EAnchorPointType.ANCHORPOINT_CenterLeft, EAnchorPointType.ANCHORPOINT_CenterLeft, 80 , 0);
	// 메뉴 위
	//SetAnchor("", EAnchorPointType.ANCHORPOINT_BottomRight, EAnchorPointType.ANCHORPOINT_BottomRight, 0, - 110 );
}
defaultproperties
{
}
