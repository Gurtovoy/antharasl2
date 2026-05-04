//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : Menu 스케일폼 버전 - SCALEFORM UI
//                메인 메뉴
//
//------------------------------------------------------------------------------------------------------------------------
class ArenaMatchWnd extends L2UIGFxScript;

function OnRegisterEvent()
{	
	RegisterEvent( EV_StateChanged );
	
	RegisterGFxEvent( EV_RequestMatchArena );
	RegisterGFxEvent( EV_CompleteMatchArena );
	RegisterGFxEvent( EV_ConfirmMatchArena );
	RegisterGFxEvent( EV_CancelMatchArena );

	// 파티 상태에 다라 다르게 표시 하도록	
	RegisterGFxEvent( EV_BecamePartyMaster );   //파티장이됨
	RegisterGFxEvent( EV_RecvPartyMaster );     //파티장을 이양받음	

	RegisterGFxEvent( EV_HandOverPartyMaster ); //4918 파티장을 양도함 
	
	RegisterGFxEvent( EV_PartyAddParty );       //파티 혹은 들어옴	

	RegisterGFxEvent( EV_PartyDeleteAllParty ); //모든 파티원 삭제
}

function OnLoad()
{		
	AddState( "ARENAGAMINGSTATE" );
	SetContainerHUD(WINDOWTYPE_NONE, 0);

	setHUD();
	setDefaultShow(true);		
	SetHavingFocus( false );
}

function OnEvent(int Event_ID, string param)
{
	if(Event_ID == EV_StateChanged)
	{
		//Debug( "ArenaMatchWnd- EV_StateChanged ->" @  param );
		if (param == "ARENAGAMINGSTATE")
		{
			ShowWindow();			
			GetWindowHandle("ChatWnd").ShowWindow();
			GetWindowHandle("ShortcutWnd").ShowWindow();			
			//ExecuteCommand("//set_member_arena 2");
		}
		else if( param == "ARENAPICKSTATE" )
		{
			HideWindow();
		}
		else if( param == "ARENABATTLESTATE" )
		{
			GetWindowHandle("ChatWnd").ShowWindow();
			GetWindowHandle("ShortcutWnd").ShowWindow();			
			HideWindow();
		}

	}
}

function OnFlashLoaded()
{		
	SetAnchor("", EAnchorPointType.ANCHORPOINT_BottomCenter, EAnchorPointType.ANCHORPOINT_TopCenter, 0 , -248);	
}
defaultproperties
{
}
