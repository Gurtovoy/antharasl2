//------------------------------------------------------------------------------------------------------------------------
//
// 제목        : AlterSkillJump   - SCALEFORM UI - 
//
//------------------------------------------------------------------------------------------------------------------------
class AlterSkillJump extends L2UIGFxScript;

function OnRegisterEvent()
{
	registerGfxEvent(EV_NotifyFlyMoveStart);
}

function OnLoad()
{
	SetAnchor("", EAnchorPointType.ANCHORPOINT_CenterCenter, EAnchorPointType.ANCHORPOINT_CenterCenter, 116, -3);

	AddState("GAMINGSTATE");	
	AddState( "ARENABATTLESTATE" );
	AddState( "ARENAGAMINGSTATE" );	
	SetContainerHUD(WINDOWTYPE_NONE, 0);	
	
	SetAlwaysFullAlpha( true );
	SetHavingFocus( false );
}

function onCallUCFunction( string functionName, string param )
{
	//Debug("flyMove 점프 하라고 명령! " @ functionName );

	switch (functionName)
	{
		// 점프 하라고 명령!
		case "flyMove" :
			RequestFlyMoveStart();			
		break;
	}
}

/**
 * 숫자를 넣으서 true, false 를 리턴 하게 한다.
 **/
function bool bflag(int nflag)
{
	if (nflag > 0) return true;
	else return false;
}
defaultproperties
{
}
