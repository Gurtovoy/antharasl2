//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : Menu 스케일폼 버전 - SCALEFORM UI
//                메인 메뉴
//
//------------------------------------------------------------------------------------------------------------------------
class ArenaPickWnd extends L2UIGFxScript;

function OnRegisterEvent()
{	
	RegisterEvent( EV_StateChanged );
	
	RegisterGFxEvent( EV_StartChooseClassArena );
	RegisterGFxEvent( EV_ChangeClassArena  );
	RegisterGFxEvent( EV_ConfirmClassArena  );

	RegisterGFxEvent( EV_StartBattleReadyArena  );
}

function OnLoad()
{		
	AddState( "ARENAPICKSTATE" );
	SetContainerHUD(WINDOWTYPE_NOBG, 0);

	setDefaultShow(true);
	SetHavingFocus( false );
}

function OnEvent(int Event_ID, string param)
{
	if(Event_ID == EV_StateChanged)
	{
		if (param == "ARENAPICKSTATE")
		{
			ShowWindow();
			//Debug( "ARENAPICKSTATE" @  param );
		}
		else //if (param == "ARENABATTLESTATE")
		{
			HideWindow();
		}
	}
}

function OnFlashLoaded()
{		
	SetAnchor("", EAnchorPointType.ANCHORPOINT_CenterCenter, EAnchorPointType.ANCHORPOINT_CenterCenter, 0 , 0);	
}
defaultproperties
{
}
