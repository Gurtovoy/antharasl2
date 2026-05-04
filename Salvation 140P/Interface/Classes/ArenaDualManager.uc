//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : Menu 스케일폼 버전 - SCALEFORM UI
//                전광판
//
//------------------------------------------------------------------------------------------------------------------------
class ArenaDualManager extends L2UIGFxScript;

function OnRegisterEvent()
{	
	//RegisterEvent( EV_StateChanged );

	RegisterGFxEvent( EV_DuelReady);
	RegisterGFxEvent( EV_DuelStart);
	RegisterGFxEvent( EV_DuelEnd);
	RegisterGFxEvent( EV_DuelUpdateUserInfo);
	RegisterGFxEvent( EV_DuelEnemyRelation);
	RegisterGFxEvent( EV_ArenaKillInfo);

	// 적 목록 초기화를 위해 사용할 event, 정확하게 오는게 뭔지 몰라서 두개다 넣음.
	RegisterGFxEvent( EV_BattleResultArena );
	RegisterGFxEvent( EV_StartBattleReadyArena );
	RegisterGFxEvent( EV_TargetUpdate );
}

//function OnEvent(int Event_ID, string param)
//{
//	if(Event_ID == EV_StateChanged)
//	{
		
//		Debug("엔터 스테이트" @ GetGameStateName());

//		//if (param == "ARENABATTLESTATE")
//		//{
//		//	ShowWindow();

//		//	Debug("ARENAGAMINGSTATE-> ");
//		//	CallGFxFunction("ArenaDualManager","removeAllMember","");
//		//}

//		Debug("-------------State : " @ param);
//		Debug("스테이트 -_- ARENABATTLESTATE -> ArenaDualManager" @ GetWindowHandle("ArenaDualManager").IsShowWindow());

//		// 배틀이나 게이밍 스테이트에다 넣으니.. 맴버 업데이트 이벤트가 더 먼저와서..문제가 생겨서 
//		// ARENAPICKSTATE으로 변경, 그냥 이벤트를 받는게 깔끔 할듯.
//		if (param == "ARENAPICKSTATE")
//		{
//			Debug("스테이트 -_- ARENAPICKSTATE-> ArenaDualManager");
//			if (GetWindowHandle("ArenaDualManager").IsShowWindow())
//			{
//				CallGFxFunction("ArenaDualManager","removeAllMember","");
//			}
//		}
//	}

//}



function OnLoad()
{	
	//AddState( "ARENAGAMINGSTATE" );
	AddState( "ARENABATTLESTATE" );
	AddState("ARENAOBSERVERSTATE");
	//AddState( "ARENAGAMINGSTATE" );
	SetDefaultShow( true ) ;
	SetContainerHUD(WINDOWTYPE_NONE, 0);    
	SetHavingFocus( false );
}

function OnFlashLoaded()
{		
	IgnoreUIEvent(true);
	SetAnchor("", EAnchorPointType.ANCHORPOINT_CenterRight, EAnchorPointType.ANCHORPOINT_TopRight, -26 , -160);	
}

/*
function onEvent ( int id, string param) 
{
	switch ( id ) 
	{
		case EV_Die : Debug ( "onEvent" @  id ) ;break;
	}
}*/
defaultproperties
{
}
