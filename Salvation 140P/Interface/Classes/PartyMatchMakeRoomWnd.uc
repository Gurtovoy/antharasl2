class PartyMatchMakeRoomWnd extends UICommonAPI;

enum InviteStateType
{
	// 새로운 방을 만듬
	MAKEROOM,
	// 파티매칭 대가지 목록 PartyMatchOutWaitListWnd 에서 파타방초대 클릭 시
	INVITE_MAKEROOM, 
	// 방 세팅 변경
	SETTINGCHANGE
};

var InviteStateType InviteState;
var int RoomNumber;
var string InvitedName;
var EditBoxHandle		MinLevelEditBox;
var EditBoxHandle		MaxLevelEditBox;

function OnLoad()
{
	MinLevelEditBox = GetEditBoxHandle("PartyMatchMakeRoomWnd.MinLevelEditBox");
	MaxLevelEditBox = GetEditBoxHandle("PartyMatchMakeRoomWnd.MaxLevelEditBox");
}

function OnShow()
{
	switch ( InviteState ) 
	{
		// 새로운 파티방을 생성합니다.
		case MAKEROOM :			
			class'UIAPI_TEXTBOX'.static.SetText( "PartyMatchMakeRoomWnd.TitletoDo",  GetSystemString(1457));
		break;
		// 새로운 파티방을 생성하고 상대방을 초청합니다.
		case INVITE_MAKEROOM :			
			class'UIAPI_TEXTBOX'.static.SetText( "PartyMatchMakeRoomWnd.TitletoDo",  GetSystemString(1458));
		break;
		// 방 설정을 변경 합니다.
		case SETTINGCHANGE :		
			class'UIAPI_TEXTBOX'.static.SetText( "PartyMatchMakeRoomWnd.TitletoDo",  GetSystemString(1460));
		break;
	}	
}

function OnClickButton( string a_strButtonName )
{
	switch( a_strButtonName )
	{
	case "OKButton":
		OnOKButtonClick();
		break;
	case "CancelButton":
		OnCancelButtonClick();
		break;
	}
}

function OnOKButtonClick()
{
	local int MaxPartyMemberCount;
	local int MinLevel;
	local int MaxLevel;
	local String RoomTitle;		
	
	// 표기 : 클래식은 최대 레벨, 라이브는 최대 레벨 이상은 199로 표기 함.
	if ( getInstanceUIData().getIsClassicServer() ) 
	{
		MaxLevel = getInstanceUIData().MAXLV;
	} else 
	{
		MaxLevel = getInstanceUIData().MAXLV2DISPLAY;
	}
	
	MinLevel = Clamp( int( class'UIAPI_EDITBOX'.static.GetString( "PartyMatchMakeRoomWnd.MinLevelEditBox" ) ), 1, MaxLevel );
	MaxLevel = Clamp( int( class'UIAPI_EDITBOX'.static.GetString( "PartyMatchMakeRoomWnd.MaxLevelEditBox" ) ), 1, MaxLevel );
	class'UIAPI_EDITBOX'.static.SetString( "PartyMatchMakeRoomWnd.MinLevelEditBox", String( MinLevel) );
	class'UIAPI_EDITBOX'.static.SetString( "PartyMatchMakeRoomWnd.MaxLevelEditBox", String( MaxLevel) );

	// 개설 : 최대 레벨 이상인 경우 최대 레벨로 방을 개설
	MaxLevel = getInstanceUIData().MAXLV;	

	RoomTitle = class'UIAPI_EDITBOX'.static.GetString( "PartyMatchMakeRoomWnd.TitleEditBox" );

	MaxPartyMemberCount = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "PartyMatchMakeRoomWnd.MaxPartyMemberCountComboBox" ) + 2;

	MinLevel = Clamp( int( class'UIAPI_EDITBOX'.static.GetString( "PartyMatchMakeRoomWnd.MinLevelEditBox" ) ), 1, MaxLevel );
	MaxLevel = Clamp( int( class'UIAPI_EDITBOX'.static.GetString( "PartyMatchMakeRoomWnd.MaxLevelEditBox" ) ), 1, MaxLevel );

	class'PartyMatchAPI'.static.RequestManagePartyRoom( RoomNumber, MaxPartyMemberCount, MinLevel, MaxLevel, RoomTitle );

	class'UIAPI_WINDOW'.static.HideWindow( "PartyMatchMakeRoomWnd" );
	if (InviteState == INVITE_MAKEROOM)
	{
		Debug ( "방 만든 뒤 초대하기 INVITE_MAKEROOM" ) ;
		class'PartyMatchAPI'.static.RequestAskJoinPartyRoom( InvitedName );
		InviteState = MAKEROOM;
	} 
}



function OnCancelButtonClick()
{
	class'UIAPI_WINDOW'.static.HideWindow( "PartyMatchMakeRoomWnd" );
	if (InviteState == INVITE_MAKEROOM)
	{
		InviteState = MAKEROOM;
	} 

}

function SetRoomNumber( int a_RoomNumber )
{
	//debug( "PartyMatchMakeRoomWnd.SetRoomNumber " $ a_RoomNumber );
	RoomNumber = a_RoomNumber;
}	

function SetTitle( String a_Title )
{
	//debug( "PartyMatchMakeRoomWnd.SetTitle " $ a_Title );
	class'UIAPI_EDITBOX'.static.SetString( "PartyMatchMakeRoomWnd.TitleEditBox", a_Title );
}

function SetMinLevel( int a_MinLevel )
{
	//debug( "PartyMatchMakeRoomWnd.SetMinLevel " $ a_MinLevel );
	MinLevelEditBox.SetString( string( a_MinLevel ) );
	//class'UIAPI_EDITBOX'.static.SetString( "PartyMatchMakeRoomWnd.MinLevelEditBox", string( a_MinLevel ) );
}

function SetMaxLevel( int a_MaxLevel )
{
	//debug( "PartyMatchMakeRoomWnd.SetMaxLevel " $ a_MaxLevel );	
	MaxLevelEditBox.SetString( string( a_MaxLevel ) );
	//class'UIAPI_EDITBOX'.static.SetString( "PartyMatchMakeRoomWnd.MaxLevelEditBox", string( a_MaxLevel ) );
}

function SetMaxPartyMemberCount( int a_MaxPartyMemberCount )
{
	//debug( "PartyMatchMakeRoomWnd.SetMaxPartyMemberCount " $ a_MaxPartyMemberCount );
	class'UIAPI_COMBOBOX'.static.SetSelectedNum( "PartyMatchMakeRoomWnd.MaxPartyMemberCountComboBox", a_MaxPartyMemberCount - 2 );
}

defaultproperties
{
}
