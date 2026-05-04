//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : AlterSkill  ( 발동 스킬 ) - SCALEFORM UI
//
//------------------------------------------------------------------------------------------------------------------------
class Fishing extends L2UIGFxScript;

function OnRegisterEvent()
{	
	RegisterGFxEvent( EV_AutoFishAvailable );
	RegisterGFxEvent( EV_AutoFishStart );
	RegisterGFxEvent( EV_AutoFishEnd );
	RegisterGFxEvent( EV_Test );
}

function OnLoad()
{
	registerState( "Fishing", "GamingState" );	
	//	SetAlwaysFullAlpha( true );

	SetContainerHUD( WINDOWTYPE_NONE, 0);
	AddState("GAMINGSTATE");

	//선언하면 처음 부터 보여지고 시작 함
	//SetDefaultShow(true);

	SetHavingFocus( false );
	SetAnchor("", EAnchorPointType.ANCHORPOINT_BottomRight, EAnchorPointType.ANCHORPOINT_TopLeft, 0,0);//116, -3);
}

function OnShow()
{
	//Debug("Fishing!!!! onShow" @ IsBuilderPC());
}

function OnFlashLoaded()
{
	//RegisterDelegateHandler(EDelegateHandlerType.EDHandler_UseSkill);	
}

function OnHide()
{
}

function OnCallUCLogic( int logicID, string param )
{
	// SetNextFocus();
	// 닫을때, 포커스 넘겨주기 
	if (logicID == 1)
	{
		SetNextFocus();
		HideWindow();
	}
}

function OnEvent(int Event_ID, string param)
{
}
defaultproperties
{
}
