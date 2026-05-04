class RadarMapWnd extends L2UIGFxScript;

function OnRegisterEvent()
{	
	RegisterGFxEvent( EV_Restart );
	RegisterGFxEvent( EV_SetRadarZoneCode);
	RegisterGFxEvent( EV_BeginShowZoneTitleWnd );		//존네임이 바뀔 때, 레이더를 가려줄지 말지를 결정해야한다. 
	RegisterGFxEvent( EV_ShowMinimap );	
	//RegisterGFxEvent( EV_NotifyObject);	
	
	RegisterGFxEvent( EV_GamingStateEnter );
	RegisterGFxEvent( EV_GamingStateExit );
	
	//RegisterGFxEvent( EV_TargetUpdate );				//타겟 업데이트 될 경우 타겟을 표시해준다.
	//6130
	RegisterGFxEvent( EV_UpdateTargetSelectedRadarMap );				//타겟 업데이트 될 경우 타겟을 표시해준다.
	RegisterGFxEvent( EV_TargetHideWindow );			//타겟이 하이드 될경우 타겟 삭제
	
	//RegisterGFxEvent( EV_FinishRotate);	//회전 종료시 들어오는 이벤트
	
	//RegisterGFxEvent( EV_AirShipState );	// 비행정 스테이트가 들어왔을 경우
	//RegisterGFxEvent( EV_AirShipUpdate );	// 비행정 정보 업데이트 이벤트
	//RegisterGFxEvent( EV_AirShipAltitude);	// 비행정 고도가 변경되었을 경우

	//RegisterGFxEvent( EV_NotifyTutorialQuest ); //ldw 튜토리얼 퀘스트 시작 이벤트
	//RegisterGFxEvent( EV_ClearTutorialQuest ); //ldw 튜토리얼 종료 이벤트


	RegisterGFxEvent( EV_PartyAddParty);       //파티 들어옴
	RegisterGFxEvent( EV_PartyDeleteParty);    //파티 삭제
	RegisterGFxEvent( EV_PartyDeleteAllParty); //모든 파티 삭제
	RegisterGFxEvent( EV_PartyDeleteAllParty); //모든 파티 삭제
	RegisterGFxEvent( EV_PartyUpdateParty);    //파티 정보 변경
	

	RegisterGFxEvent( EV_UpdateQuestMarkRadarMap ); //퀘스트 마크 받음 

	//RegisterGFxEvent( EV_NotifyPartyMemberPosition);


	//핸디의 블록체커
	//RegisterGFxEvent( EV_BlockStateTeam );
	//RegisterGFxEvent( EV_BlockStatePlayer );
	//클레프트 상황판
	//RegisterGFxEvent( EV_CleftStateTeam );
	//RegisterGFxEvent( EV_CleftStatePlayer );
	//지하 콜로세움 상황판
	//RegisterGFxEvent( EV_CrataeCubeRecordBegin );
	//RegisterGFxEvent( EV_CrataeCubeRecordMyItem );
	//RegisterGFxEvent( EV_CrataeCubeRecordRetire );
	//PVP 용 이벤트
	//RegisterGFxEvent( EV_PVPMatchRecord );

	//RegisterGFxEvent( EV_CuriousHouseWaitState);
	// 의문의 저택 state 0:기간 아님, 1:입장신청, 2:임장대기

	//유저가 단일 메시 볼륨에 들어갈 때 발생
	//RegisterGFxEvent( EV_EnterSingleMeshZone ); //9540

	//유저가 단일 메시 볼륨에서 나올 때 발생
	//RegisterGFxEvent( EV_ExitSingleMeshZone ); //9541		

	//미니맵 존 바뀔 때
	RegisterGFxEvent( EV_MinimapChangeZone ); //1840		

	//게임 시간 갱신
	//RegisterGFxEvent( EV_MinimapUpdateGameTime ); //1890

	//퀘스트를 다시 받을 때
	//RegisterGFxEvent( EV_QuestListStart ); //700;

	RegisterGFxEvent( EV_Restart ); //퀘스트 마크 받음 

	// 레이더 맵 핑 이벤트
	RegisterGFxEvent( EV_ArenaCustomNotification ); 

	// 레이더 맵 아레나 적 검색.
	RegisterGFxEvent( EV_ArenaShowEnemyParty ); 
	

}

/*
 *튜토리얼 퀘스트 미니맵에 해당 위치 표시
function onTutorialQuest8888Handle(){//ldw
	local vector vTutorialPos;//ldw
	local MinimapWnd MinimapWndScript;//ldw
	local MinimapWnd_Expand MinimapWnd_ExpandScript;//ldw

	//Debug("TutorialQuest8888 is pushed");			
			vTutorialPos.x=TUTORIALQUEST[3];
			vTutorialPos.y=TUTORIALQUEST[4];
			vTutorialPos.z=TUTORIALQUEST[5];
			if(IsShowWindow("MinimapWnd_Expand"))
			{				
				//Debug("expand");
				ShowWindowWithFocus("MinimapWnd_Expand");
				MinimapWnd_ExpandScript = MinimapWnd_Expand( GetScript("MinimapWnd_Expand") );
				MinimapWnd_ExpandScript.SetLocContinent(vTutorialPos);
				class'UIAPI_MINIMAPCTRL'.static.AdjustMapView("MinimapWnd_Expand.Minimap",vTutorialPos,true);
			}else if (IsShowWindow("MinimapWnd"))
			{  				
				MinimapWndScript = MinimapWnd( GetScript("MinimapWnd") );
				MinimapWndScript.SetLocContinent(vTutorialPos);				
				class'UIAPI_MINIMAPCTRL'.static.AdjustMapView("MinimapWnd.Minimap",vTutorialPos,true);				
				MinimapWnd.setFocus();				
				

			} else {				
				ShowWindowWithFocus("MinimapWnd");
				MinimapWndScript = MinimapWnd( GetScript("MinimapWnd") );
				MinimapWndScript.SetLocContinent(vTutorialPos);
				class'UIAPI_MINIMAPCTRL'.static.AdjustMapView("MinimapWnd.Minimap",vTutorialPos,true); //ldw 튜토리얼
			}
}
*/

function OnLoad()
{
	registerState( "RadarMapWnd", "GamingState" );

	SetContainerHUD( WINDOWTYPE_NONE, 0);
	AddState("GAMINGSTATE");
	AddState("ARENABATTLESTATE");
	AddState( "ARENAGAMINGSTATE" );
	AddState("ARENAOBSERVERSTATE");

	//함수 실행 시 onStateOut, onStateIn 함수를 invoke 로 받음 
	//SetStateChangeNotification();

	//선언하면 처음 부터 보여지고 시작 함
	SetDefaultShow(true);

	//SetAnchor("", EAnchorPointType.ANCHORPOINT_BottomRight, EAnchorPointType.ANCHORPOINT_TopLeft, 0 , 0);		
}

function onCallUCFunction ( string functionName, string param )
{
	switch ( functionName )
	{
		case "TeleportBookmarkBtn":
			
			if( class'UIAPI_WINDOW'.static.IsShowWindow("TeleportBookMarkWnd") )
			{
				class'UIAPI_WINDOW'.static.HideWindow( "TeleportBookMarkWnd" );
			}
			else
			{
				DoAction(class'UICommonAPI'.static.GetItemID(64));
			}
		break;
		case "onClickArrowIcon":
			onClickArrowIcon();
			break;
	}
}

function onClickArrowIcon() 
{
	local MinimapWnd Script;
	// local MinimapWnd_Expand Script2;
	local string minimapWndName;
	
	Script = MinimapWnd(GetScript("MinimapWnd" ));
	//Script2 = MinimapWnd_Expand(GetScript( "MinimapWnd_Expand" ));

	//if ( Script.IsExpandState() )
	//{
	//	minimapWndName = "MinimapWnd_Expand";		
	//	if ( !class'UIAPI_WINDOW'.static.IsShowWindow( minimapWndName) ) 
	//	{
	//		class'UIAPI_WINDOW'.static.ShowWindow( minimapWndName );		
	//	}		
	//	//Script2.OnClickTargetButton();
	//}
	//else 
	//{
	//	minimapWndName = "MinimapWnd";
	//	if ( !class'UIAPI_WINDOW'.static.IsShowWindow( minimapWndName) ) 
	//	{
	//		class'UIAPI_WINDOW'.static.ShowWindow( minimapWndName );		
	//	}		
	//	Script.OnClickTargetButton();
	//}
	minimapWndName = "MinimapWnd";
	if ( !class'UIAPI_WINDOW'.static.IsShowWindow( minimapWndName) ) 
	{
		class'UIAPI_WINDOW'.static.ShowWindow( minimapWndName );		
	}		
	Script.OnClickTargetButton();

	
	/*
	else 
	{
		class'UIAPI_WINDOW'.static.HideWindow( "MinimapWnd" );		
	}*/
	
}
defaultproperties
{
}
