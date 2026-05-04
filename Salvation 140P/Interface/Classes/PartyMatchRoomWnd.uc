class PartyMatchRoomWnd extends PartyMatchWndCommon;

var int RoomNumber;
var int CurPartyMemberCount;
var int MaxPartyMemberCount;
var int MinLevel;
var int MaxLevel;
var int LootingMethodID;

/* TT 77355 -1 인 경우 추가
 * EV_PartyMatchRoomMemberUpdate 으로 MyMembershipType 정보를 받기 전에 
 * EV_PartyMatchRoomStart 이벤트의 updateData 로 맞지 않는 레벨 정보가 표기 되는 걸 방지
 */
var int MyMembershipType;	//-1 Before PartyMatchRoomMemberUpdate, 0:Want to be party member, 1:Room Master, 2:Party member 

var string RoomTitle;

var bool m_bPartyMatchRoomStart;
var bool m_bRequestExitPartyRoom;

var string m_WindowName;
var ListCtrlHandle m_hPartyMatchRoomWndPartyMemberListCtrl;
 

function OnRegisterEvent()
{
	RegisterEvent( EV_Restart );
	RegisterEvent( EV_PartyMatchRoomStart );
	RegisterEvent( EV_PartyMatchRoomClose );
	RegisterEvent( EV_PartyMatchRoomMember );
	RegisterEvent( EV_PartyMatchRoomMemberUpdate );
	RegisterEvent( EV_PartyMatchChatMessage );
	RegisterEvent( EV_PartyMatchCommand );
}

function OnLoad()
{
	m_bPartyMatchRoomStart = false;
	m_bRequestExitPartyRoom = false;
	
	m_hPartyMatchRoomWndPartyMemberListCtrl=GetListCtrlHandle(m_WindowName$".PartyMemberListCtrl");

	MyMembershipType = -1;
}


//X버튼을 눌렀을때
function OnSendPacketWhenHiding()
{
	local PartyMatchWnd Script;
	
	Script = PartyMatchWnd( GetScript( "PartyMatchWnd" ) );
	if( Script != None )
	{
		Script.CompletelyQuitPartyMatching = 1;
		Script.SetWaitListWnd(false);
		Script.ShowHideWaitListWnd();
	}
	
	ExitPartyRoom();
}

function OnEnterState( name a_PreStateName )
{
	if (m_bPartyMatchRoomStart)
	{
		class'UIAPI_WINDOW'.static.ShowWindow( "PartyMatchRoomWnd" );
		class'UIAPI_WINDOW'.static.SetFocus( "PartyMatchRoomWnd" );
	}
}

function OnEvent( int a_EventID, String param )
{
	//Debug( "OnEvent" @ a_EventID @ param );
	switch( a_EventID )
	{
	case EV_PartyMatchCommand:
	if (class'UIAPI_WINDOW'.static.IsMinimizedWindow("PartyMatchRoomWnd"))
		{
		    class'UIAPI_WINDOW'.static.ShowWindow("PartyMatchRoomWnd");
		}
		class'UIAPI_WINDOW'.static.SetFocus("PartyMatchRoomWnd");
		break;	
	case EV_PartyMatchRoomStart:
		HandlePartyMatchRoomStart( param ); //파티 멤버가 시작 되는 경우 		
		break;
	case EV_PartyMatchRoomClose:
		HandlePartyMatchRoomClose();
		break;
	case EV_PartyMatchRoomMember: //파티 멤버가 들어 오는 경우 		
		HandlePartyMatchRoomMember( param );
		break;
	case EV_PartyMatchRoomMemberUpdate:
		HandlePartyMatchRoomMemberUpdate( param ); //파티 멤버가 업데이트 되는 경우 
		break;
	case EV_PartyMatchChatMessage: //채팅 메시지가 들어 오는 경우 		
		HandlePartyMatchChatMessage( param );
		break;
	case EV_Restart:
		HandleRestart();
		break;
	}
}

function HandleRestart()
{
	m_bPartyMatchRoomStart = false;
}

function ExitPartyRoom()
{
	m_bRequestExitPartyRoom = true;
	
	switch( MyMembershipType )
	{
	case 0:
	case 2:
		class'PartyMatchAPI'.static.RequestWithdrawPartyRoom( RoomNumber );
		break;
	case 1:		
		class'PartyMatchAPI'.static.RequestDismissPartyRoom( RoomNumber );
		break;
	}

	MyMembershipType = -1;
}

function onShow()
{
	callGfxFunction ( "ExpBar", "PartyMatchWndGFxEvent", "state=onShow windowName=PartyMatchRoomWnd");	
}

function OnMinimize()
{
	callGfxFunction ( "ExpBar", "PartyMatchWndGFxEvent", "state=onMinimize");	
}


function HandlePartyMatchRoomStart( String param )
{
		
	local Rect 	rectWnd;
	local PartyMatchWnd script;
	script = PartyMatchWnd( GetScript( "PartyMatchWnd" ) );
	script.SetIsInParty(true);
	
	ParseInt(param, "RoomNum", RoomNumber);
	ParseInt(param, "MaxMember", MaxPartyMemberCount);
	ParseInt(param, "MinLevel", MinLevel);
	ParseInt(param, "MaxLevel", MaxLevel);
	ParseInt(param, "LootingMethodID", LootingMethodID);	
	ParseString(param, "RoomName", RoomTitle);
	
	 //debug("시작!!" @ MaxLevel);
	UpdateData( );
	lootingMethodUpdate();
	m_bPartyMatchRoomStart = true;
	
	//채팅창 초기화
	class'UIAPI_TEXTLISTBOX'.static.Clear( "PartyMatchRoomWnd.PartyRoomChatWindow" );
	
	//Minimize된 상태라면, 아이콘만 깜박이게 한다.
	if (class'UIAPI_WINDOW'.static.IsMinimizedWindow( "PartyMatchRoomWnd" ))
	{
		//class'UIAPI_WINDOW'.static.NotifyAlarm( "PartyMatchRoomWnd" );	
		callGfxFunction ( "ExpBar", "PartyMatchWndGFxEvent", "state=highlightOn");
	}
	else
	{
		//윈도우의 위치를 PartyMatchWnd에 맞춤
		rectWnd = class'UIAPI_WINDOW'.static.GetRect("PartyMatchWnd");
		class'UIAPI_WINDOW'.static.MoveTo("PartyMatchRoomWnd", rectWnd.nX, rectWnd.nY);
		
		//대기자리스트 업데이트
		UpdateWaitListWnd();
		
		class'UIAPI_WINDOW'.static.ShowWindow( "PartyMatchRoomWnd" );
		class'UIAPI_WINDOW'.static.SetFocus( "PartyMatchRoomWnd" );
	}
}

//대기자리스트 업데이트
function UpdateWaitListWnd()
{	
	local string strName;	
	local int roleIndex;

	local PartyMatchWnd Script;
	
	Script = PartyMatchWnd( GetScript( "PartyMatchWnd" ) );
	if( Script != None )
	{
		if (Script.IsShowWaitListWnd())
		{
			//class'PartyMatchAPI'.static.RequestPartyMatchWaitList(1, MinLevel, MaxLevel, JobFilterComboBox.GetSelectedNum() );
			strName = class'UIAPI_EDITBOX'.static.GetString( "PartyMatchWaitListWnd.Name");
			roleIndex = GetComboBoxHandle( "PartyMatchWaitListWnd.Job" ).GetSelectedNum();	
			RequestPartyMatchWaitList( 1, MinLevel, MaxLevel, roleIndex, strName );
		}
	}
}

function OnHide()
{
	callGfxFunction ( "ExpBar", "PartyMatchWndGFxEvent", "state=onHide");
	class'UIAPI_WINDOW'.static.HideWindow( "PartyMatchMakeRoomWnd" );	
}

function HandlePartyMatchRoomClose()
{
	local PartyMatchWnd Script;
	local PartyMatchMakeRoomWnd Script2;
	local PartyWnd Script3;

	
	script = PartyMatchWnd( GetScript( "PartyMatchWnd" ) );
	script.SetIsInParty(false);

	Script3 = PartyWnd(GetScript("PartyWnd"));
	Script3.m_AmIRoomMaster = false;
	
	
	m_bPartyMatchRoomStart = false;
	
	class'UIAPI_WINDOW'.static.HideWindow( "PartyMatchRoomWnd" );
	
	//버튼을 눌러서 Request를 했을 때만, PartyMatchWnd의 갱신을 해준다.
	//왜냐하면, 파티매칭중에 리스타트를 해서 EV_PartyMatchRoomClose가 날라왔을 때, 서버접속종료가 되기 때문이다.
	if (m_bRequestExitPartyRoom)
	{
		Script = PartyMatchWnd( GetScript( "PartyMatchWnd" ) );
		if( Script != None )
			Script.OnRefreshBtnClick();	
		
		Script2 = PartyMatchMakeRoomWnd( GetScript( "PartyMatchMakeRoomWnd" ) );
		if( Script2 != None )
			Script2.OnCancelButtonClick();
	}
	m_bRequestExitPartyRoom = false;
}

function UpdateMyMembershipType()
{
	local PartyWnd Script;
	local PartyMatchWaitListWnd Script2;
	Script = PartyWnd(GetScript("PartyWnd"));
	Script2 = PartyMatchWaitListWnd ( GetScript( "PartyMatchWaitListWnd"));
	switch( MyMembershipType )
	{
	case 0:
				
	case 2:		
		class'UIAPI_BUTTON'.static.DisableWindow( "PartyMatchRoomWnd.RoomSettingButton" );
		class'UIAPI_BUTTON'.static.DisableWindow( "PartyMatchRoomWnd.BanButton" );
		class'UIAPI_BUTTON'.static.DisableWindow( "PartyMatchRoomWnd.InviteButton" );
		class'UIAPI_BUTTON'.static.EnableWindow( "PartyMatchRoomWnd.ExitButton" );
		break;
	case 1:
		Script.m_AmIRoomMaster = true;
		class'UIAPI_BUTTON'.static.EnableWindow( "PartyMatchRoomWnd.RoomSettingButton" );
		class'UIAPI_BUTTON'.static.EnableWindow( "PartyMatchRoomWnd.BanButton" );
		class'UIAPI_BUTTON'.static.EnableWindow( "PartyMatchRoomWnd.InviteButton" );
		class'UIAPI_BUTTON'.static.EnableWindow( "PartyMatchRoomWnd.ExitButton" );
		break;
	}

	
	Script2.updateMyMemberShipType( MyMembershipType );
}

function HandlePartyMatchRoomMember( String param )
{
	local int i;
	local int ClassID;
	local int Level;
	local int MemberID;
	local String MemberName;	
	local int MembershipType;
	local PartyMatchWaitListWnd Script;
	
	local int       RestrictZoneCnt;
	local string    RestrictZoneID;
	local int       temp;
	local int       j;

	Script = PartyMatchWaitListWnd( GetScript( "PartyMatchWaitListWnd" ) );
	
	ParseInt(param, "MyMembershipType", MyMembershipType);
	UpdateMyMembershipType();

	class'UIAPI_LISTCTRL'.static.DeleteAllItem( "PartyMatchRoomWnd.PartyMemberListCtrl" );

	ParseInt(param, "MemberCount", CurPartyMemberCount);
	for( i = 0; i < CurPartyMemberCount; ++i )
	{
		ParseInt(param, "MemberID_" $ i, MemberID);
		ParseString(param, "MemberName_" $ i, MemberName);
		ParseInt(param, "ClassID_" $ i, ClassID);
		ParseInt(param, "Level_" $ i, Level);		
		ParseInt(param, "MembershipType_" $ i, MembershipType);
		
		//선준 수정(2010.03.05 ~ 08) 완료
		ParseInt(param, "RestrictZoneCnt_" $ i, RestrictZoneCnt);
		
		if( RestrictZoneCnt == 0 )
		{
			RestrictZoneID = "";
		}

		for(j = 0; j < RestrictZoneCnt ; j++)
		{
			ParseInt(param, "RestrictZoneID_" $ i $ "_" $ j, temp);
			if( j != 0 )
			{
				RestrictZoneID = RestrictZoneID $ "," $ GetInZoneNameWithZoneID( temp );
			}
			else
			{
				RestrictZoneID = GetInZoneNameWithZoneID( temp );
			}
		}


		//debug( "RestrictZoneCnt --> " @  RestrictZoneCnt );
		//debug( "RestrictZoneID PartyMatchRoom --> " @  RestrictZoneID );

		AddMember( MemberID, MemberName, ClassID, Level, MembershipType, RestrictZoneID );
	}
	
	UpdateData( );
	
	//Minimize된 상태라면, 아이콘을 깜박이게 한다.
	if (class'UIAPI_WINDOW'.static.IsMinimizedWindow( "PartyMatchRoomWnd" ))
	{
		//class'UIAPI_WINDOW'.static.NotifyAlarm( "PartyMatchRoomWnd" );	
		callGfxFunction ( "ExpBar", "PartyMatchWndGFxEvent", "state=highlightOn");

	}
	
	if (class'UIAPI_WINDOW'.static.IsShowWindow( "PartyMatchRoomWnd.PartyMatchWaitListWnd" ) == true)
	{
		Script.OnRefreshButtonClick();
	}
	
}

//선준 수정(2010.03.05 ~ 08) 완료
function AddMember( int a_MemberID, string a_MemberName, int a_ClassID, int a_Level, int a_MembershipType, string a_RestrictZoneID )
{
	local LVDataRecord Record;

	Record.LVDataList.length = 5;
	Record.LVDataList[0].nReserved1 = a_MemberID;
	Record.LVDataList[0].szData = a_MemberName;
	Record.LVDataList[1].szData = String( a_ClassID );
	Record.LVDataList[1].szTexture = GetClassRoleIconName( a_ClassID );
	Record.LVDataList[1].nTextureWidth = 11;
	Record.LVDataList[1].nTextureHeight = 11;
	Record.LVDataList[2].szData = GetAmbiguousLevelString( a_Level, true );

	switch( a_MembershipType )
	{
	case 0:
		Record.LVDataList[3].szData = GetSystemString( 1061 );
		break;
	case 1:
		Record.LVDataList[3].szData = GetSystemString( 1062 );
		break;
	case 2:
		Record.LVDataList[3].szData = GetSystemString( 1063 );
		break;
	}
	
	Record.LVDataList[4].szData = a_RestrictZoneID;

	class'UIAPI_LISTCTRL'.static.InsertRecord( "PartyMatchRoomWnd.PartyMemberListCtrl", Record );
}

function RemoveMember( int a_MemberID )
{
	local int RecordCount;
	local int i;
	local LVDataRecord Record;

	RecordCount = m_hPartyMatchRoomWndPartyMemberListCtrl.GetRecordCount();
	for( i = 0; i < RecordCount; ++i )
	{
		m_hPartyMatchRoomWndPartyMemberListCtrl.GetRec(i, record );
		if( Record.LVDataList[0].nReserved1 == a_MemberID )
		{
			m_hPartyMatchRoomWndPartyMemberListCtrl.DeleteRecord( i );
			break;
		}
	}
}

function HandlePartyMatchRoomMemberUpdate( String param )
{
	local int UpdateType;	// 0:Add, 1:Modify, 2:Remove
	local int MemberID;
	local String MemberName;
	local int ClassID;
	local int Level;	
	local int MembershipType;
	local UserInfo PlayerInfo;
	local PartyMatchWaitListWnd Script;

	local int       RestrictZoneCnt;
	local string    RestrictZoneID;
	local int       temp;
	local int       i;


	Script = PartyMatchWaitListWnd( GetScript( "PartyMatchWaitListWnd" ) );
	
	ParseInt(param, "UpdateType", UpdateType);
	ParseInt(param, "MemberID", MemberID);
	switch( UpdateType )
	{
	case 0:
		ParseString(param, "MemberName", MemberName);
		ParseInt(param, "ClassID", ClassID);
		ParseInt(param, "Level", Level);		
		ParseInt(param, "MembershipType", MembershipType);
		
		//선준 수정(2010.03.05 ~ 08) 완료
		ParseInt(param, "RestrictZoneCnt", RestrictZoneCnt);

		
		if( RestrictZoneCnt == 0 )
		{
			RestrictZoneID = "";
		}

		for(i = 0; i < RestrictZoneCnt ; i++)
		{
			ParseInt(param, "RestrictZoneID_" $ i, temp);
			if( i != 0 )
			{
				RestrictZoneID = RestrictZoneID $ "," $ GetInZoneNameWithZoneID( temp );
			}
			else
			{
				RestrictZoneID = GetInZoneNameWithZoneID( temp );
			}
		}

		//debug( "RestrictZoneCnt --> " @  RestrictZoneCnt );
		//debug( "RestrictZoneID PartyMatchRoom --> " @  RestrictZoneID );

		AddMember( MemberID, MemberName, ClassID, Level, MembershipType, RestrictZoneID );
		
		CurPartyMemberCount = CurPartyMemberCount + 1;
		break;
	case 1:
		ParseString(param, "MemberName", MemberName);
		ParseInt(param, "ClassID", ClassID);
		ParseInt(param, "Level", Level);		
		ParseInt(param, "MembershipType", MembershipType);
		
		//선준 수정(2010.03.05 ~ 08) 완료
		ParseInt(param, "RestrictZoneCnt", RestrictZoneCnt);
		
		if( RestrictZoneCnt == 0 )
		{
			RestrictZoneID = "";
		}

		for(i = 0; i < RestrictZoneCnt ; i++)
		{
			ParseInt(param, "RestrictZoneID_" $ i, temp);
			if( i != 0 )
			{
				RestrictZoneID = RestrictZoneID $ "," $ GetInZoneNameWithZoneID( temp );
			}
			else
			{
				RestrictZoneID = GetInZoneNameWithZoneID( temp );
			}
		}

		//debug( "RestrictZoneCnt --> " @  RestrictZoneCnt );
		//debug( "RestrictZoneID PartyMatchRoom --> " @  RestrictZoneID );

		RemoveMember( MemberID );
		CurPartyMemberCount = CurPartyMemberCount - 1;
		AddMember( MemberID, MemberName, ClassID, Level, MembershipType, RestrictZoneID );
		CurPartyMemberCount = CurPartyMemberCount + 1;
		break;
	case 2:
		RemoveMember( MemberID );
		CurPartyMemberCount = CurPartyMemberCount  - 1;
		break;
	}

	if( GetPlayerInfo( PlayerInfo ) )
	{
		if( PlayerInfo.nID == MemberID )
		{
			MyMembershipType = MembershipType;
			UpdateMyMembershipType();
		}
	}
	
	//Minimize된 상태라면, 아이콘을 깜박이게 한다.
	if (class'UIAPI_WINDOW'.static.IsMinimizedWindow( "PartyMatchRoomWnd" ))
	{
		//class'UIAPI_WINDOW'.static.NotifyAlarm( "PartyMatchRoomWnd" );
		callGfxFunction ( "ExpBar", "PartyMatchWndGFxEvent", "state=highlightOn");
	}

	// debug("갱신 : " @ UpdateType);

	UpdateData( );
	
	if (class'UIAPI_WINDOW'.static.IsShowWindow( "PartyMatchRoomWnd.PartyMatchWaitListWnd" ) == true)
	{
		Script.OnRefreshButtonClick();
	}
	
}

function HandlePartyMatchChatMessage( String param )
{
	//~ local int Tmp;
	local Color ChatColor;
	local String ChatMessage;
	
	local int tmpType;

	ParseString(param, "Msg", ChatMessage);

	ParseInt( param, "SayType", tmpType);
	ChatColor=GetChatColorByType(tmpType);

	class'UIAPI_TEXTLISTBOX'.static.AddString( "PartyMatchRoomWnd.PartyRoomChatWindow", ChatMessage, ChatColor );	
	
	//Minimize된 상태라면, 아이콘을 깜박이게 한다.
	if (class'UIAPI_WINDOW'.static.IsMinimizedWindow( "PartyMatchRoomWnd" ))
	{		
		//class'UIAPI_WINDOW'.static.NotifyAlarm( "PartyMatchRoomWnd" );		
		PlaySound("ItemSound3.Sys_party_matching"); //ldw 20120709 추가 사운드
		callGfxFunction ( "ExpBar", "PartyMatchWndGFxEvent", "state=highlightOn");
	}
}

/** updateData 갱신 , bLootingMethodUpdate 파티 루틴을 업데이트 할 것인가? */
function UpdateData( )
{	
	local int minNum;
	local int maxNum;

	local PartyMatchMakeRoomWnd partyMatchMakeRoomWndHandle;
	
	partyMatchMakeRoomWndHandle = PartyMatchMakeRoomWnd ( GetScript ( "PartyMatchMakeRoomWnd"));	

	
	class'UIAPI_TEXTBOX'.static.SetText( "PartyMatchRoomWnd.RoomNumber", string( RoomNumber ) );
	class'UIAPI_TEXTBOX'.static.SetText( "PartyMatchRoomWnd.RoomTitle", RoomTitle );		
	class'UIAPI_TEXTBOX'.static.SetText( "PartyMatchRoomWnd.PartyMemberCount", string( CurPartyMemberCount ) $ "/" $ MaxPartyMemberCount );
	
	if ( getInstanceUIData().getIsClassicServer() ) 
	{
		class'UIAPI_TEXTBOX'.static.SetText( "PartyMatchRoomWnd.LevelLimit", string( MinLevel ) $ "-" $string ( MaxLevel) );
	}
	else 
	{
		switch ( MyMembershipType )
		{
			case 0:
			case 2:
				//타인
				// 맥스 레벨 이상인 경우 getInstanceUIData().MAXLV2DISPLAY 로 보여 짐
				if ( MinLevel >= getInstanceUIData().MAXLV ) MinLevel = getInstanceUIData().MAXLV2DISPLAY;
				if ( MaxLevel >= getInstanceUIData().MAXLV ) MaxLevel = getInstanceUIData().MAXLV2DISPLAY;
				// getInstanceUIData().MAXLV2DISPLAY 이상인 경우 getInstanceUIData().MAXLV2DISPLAY 로 보여짐
				//if ( MinLevel > getInstanceUIData().MAXLV2DISPLAY ) MinLevel = getInstanceUIData().MAXLV2DISPLAY;
				//if ( MaxLevel > getInstanceUIData().MAXLV2DISPLAY ) MaxLevel = getInstanceUIData().MAXLV2DISPLAY;
				class'UIAPI_TEXTBOX'.static.SetText( "PartyMatchRoomWnd.LevelLimit", string( MinLevel ) $ "-" $string ( MaxLevel) );
				partyMatchMakeRoomWndHandle.SetMaxLevel ( MaxLevel ) ;
				partyMatchMakeRoomWndHandle.SetMinLevel ( MinLevel ) ;
				break;
			case 1:
				//방장	
				// 방설정이 긑나기 전에는 레벨을 업데이트 하지 말 것.
				if ( class'UIAPI_WINDOW'.static.IsShowWindow("PartyMatchMakeRoomWnd") ) return;

				minNum = int ( class'UIAPI_EDITBOX'.static.GetString( "PartyMatchMakeRoomWnd.MinLevelEditBox" ) );
				maxNum = int ( class'UIAPI_EDITBOX'.static.GetString( "PartyMatchMakeRoomWnd.MaxLevelEditBox" ) );	
				if ( minNum == 0 ) minNum = 1;
				if ( maxNum == 0 ) maxNum = 1;
				if ( minNum > maxNum ) maxNum = minNum;
				class'UIAPI_TEXTBOX'.static.SetText( "PartyMatchRoomWnd.LevelLimit", minNum $ "-" $ maxNum );
				break;
		}
	}	
}

function lootingMethodUpdate ( ) 
{
	local L2Util util ;
	util = L2Util(GetScript("L2Util"));	
	class'UIAPI_TEXTBOX'.static.SetText( "PartyMatchRoomWnd.LootingMethod", util.getLootingString( LootingMethodID ) );
}

function OnClickButton( string a_strButtonName )
{
	switch( a_strButtonName )
	{
	case "WaitListButton":
		OnWaitListButtonClick();
		break;
	case "RoomSettingButton":
		OnRoomSettingButtonClick();
		break;
	case "BanButton":
		OnBanButtonClick();
		break;
	case "InviteButton":
		OnInviteButtonClick();
		break;
	case "ExitButton":
		OnExitButtonClick();
		break;
	}
}

function OnWaitListButtonClick()
{
	local PartyMatchWnd Script;
	
	Script = PartyMatchWnd( GetScript( "PartyMatchWnd" ) );
	if( Script != None )
	{
		Script.ToggleWaitListWnd();
		UpdateWaitListWnd();
	}
}

function OnRoomSettingButtonClick()
{
	local PartyMatchMakeRoomWnd Script;
//	local UserInfo userinfo;
	local int minNum;
	local int maxNum;

	Script = PartyMatchMakeRoomWnd( GetScript( "PartyMatchMakeRoomWnd" ) );
	if( Script != None )
	{
		Script.InviteState = Script.InviteStateType.SETTINGCHANGE;
		Script.SetRoomNumber( RoomNumber );
		Script.SetTitle( RoomTitle );
		Script.SetMaxPartyMemberCount( MaxPartyMemberCount );
		//Script.SetMinLevel( MinLevel );
		//Script.SetMaxLevel( MaxLevel );

//		Debug("OnRoomSettingButtonClick" @ MaxLevel);
		if ( getInstanceUIData().getIsClassicServer() ) 
		{		
			Script.SetMinLevel( MinLevel );
			Script.SetMaxLevel( MaxLevel );
		}
		else 
		{			
			minNum = int ( class'UIAPI_EDITBOX'.static.GetString( "PartyMatchMakeRoomWnd.MinLevelEditBox" ) );
			maxNum = int ( class'UIAPI_EDITBOX'.static.GetString( "PartyMatchMakeRoomWnd.MaxLevelEditBox" ) );	
			if ( minNum == 0 ) minNum = 1;
			if ( maxNum == 0 ) maxNum = 1;
			if ( minNum > maxNum ) maxNum = minNum;
			Script.SetMinLevel( minNum );
			Script.SetMaxLevel( maxNum );
			//class'UIAPI_EDITBOX'.static.GetString( "PartyMatchMakeRoomWnd.MaxLevelEditBox" );
			//GetPlayerInfo( userinfo) ;
			//Debug ( "OnRoomSettingButtonClick" @   class'UIAPI_EDITBOX'.static.GetString( "PartyMatchMakeRoomWnd.MaxLevelEditBox" ) );
			//Script.SetMaxLevel(  Script.inputedMaxLevel );
		}

	}

	class'UIAPI_WINDOW'.static.ShowWindow( "PartyMatchMakeRoomWnd" );
	class'UIAPI_WINDOW'.static.SetFocus( "PartyMatchMakeRoomWnd" );
}

function OnBanButtonClick()
{
	local LVDataRecord Record;

	m_hPartyMatchRoomWndPartyMemberListCtrl.GetSelectedRec( record );
	class'PartyMatchAPI'.static.RequestBanFromPartyRoom( Record.LVDataList[0].nReserved1 );
}

function OnInviteButtonClick()
{
	local LVDataRecord Record;

	m_hPartyMatchRoomWndPartyMemberListCtrl.GetSelectedRec( record );
	RequestInviteParty( Record.LVDataList[0].szData );
}

function OnExitButtonClick()
{
	ExitPartyRoom();
	class'UIAPI_WINDOW'.static.HideWindow( "PartyMatchRoomWnd" );
}

function OnCompleteEditBox( String strID )
{
	local String ChatMsg;

	if( strID == "PartyRoomChatEditBox" )
	{
		ChatMsg = class'UIAPI_EDITBOX'.static.GetString( "PartyMatchRoomWnd.PartyRoomChatEditBox" );
		ProcessPartyMatchChatMessage(CHAT_PARTY_ROOM_CHAT, ChatMsg );
		class'UIAPI_EDITBOX'.static.SetString( "PartyMatchRoomWnd.PartyRoomChatEditBox", "" );
	}
}

function OnChatMarkedEditBox( string strID )
{
	Local Color ChatColor;
	If ( strID == "PartyRoomChatEditBox")
	{
		 ChatColor.R = 176;
		 ChatColor.G= 155;
		 ChatColor.B = 121;
		 ChatColor.A = 255;
		 Class'UIAPI_TEXTLISTBOX'.static.AddString("PartyMatchRoomWnd.PartyRoomChatWindow", GetSystemMessage(966), ChatColor);
	}
}

defaultproperties
{
    m_WindowName="PartyMatchRoomWnd"
}
