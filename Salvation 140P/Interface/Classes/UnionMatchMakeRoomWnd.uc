class UnionMatchMakeRoomWnd extends PartyMatchWndCommon;

var WindowHandle Me;
var TextBoxHandle TitletoDo;
var EditBoxHandle TitleEditBox;
var ComboBoxHandle MaxMemberCountComboBox;
var EditBoxHandle MinLevelEditBox;
var EditBoxHandle MaxLevelEditBox;

var int MAKE_TYPE;
var int ROOM_NUM;
var int ROOM_ROUTING;
var int MAX_LEVEL;

const MIN_MEMBER = 20;
const MAX_MEMBER = 50;

function OnRegisterEvent()
{
	//RegisterEvent(  );
}

function OnLoad()
{
	Initialize();
	Load();
}

function Initialize()
{
	Me = GetWindowHandle( "UnionMatchMakeRoomWnd" );
	TitletoDo = GetTextBoxHandle( "UnionMatchMakeRoomWnd.TitletoDo" );
	TitleEditBox = GetEditBoxHandle( "UnionMatchMakeRoomWnd.TitleEditBox" );
	MaxMemberCountComboBox = GetComboBoxHandle( "UnionMatchMakeRoomWnd.MaxMemberCountComboBox" );
	MinLevelEditBox = GetEditBoxHandle( "UnionMatchMakeRoomWnd.MinLevelEditBox" );
	MaxLevelEditBox = GetEditBoxHandle( "UnionMatchMakeRoomWnd.MaxLevelEditBox" );
}

function Load()
{
	Clear();
	MAX_LEVEL=GetMaxLevel();
}

function OnShow()
{
	if( MAKE_TYPE == UNION_MAKEROOM_NEW )
		TitletoDo.SetText( GetSystemString(1985) );	//새로운 연합방을 생성합니다.
	else if( MAKE_TYPE == UNION_MAKEROOM_EDIT )
		TitletoDo.SetText( GetSystemString(1460) );	//방 설정을 변경 합니다.
}

function OnClickButton( string Name )
{
	switch( Name )
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
	local int MaxMemberCount;
	local int MinLevel;
	local int MaxLevel;
	local String RoomTitle;

	MaxMemberCount = MaxMemberCountComboBox.GetSelectedNum() * 2 + MIN_MEMBER;
	MaxMemberCount = clamp( MaxMemberCount, MIN_MEMBER, MAX_MEMBER );
	
	MinLevel = Clamp( int( MinLevelEditBox.GetString() ), 1, MAX_LEVEL );
	MaxLevel = Clamp( int( MaxLevelEditBox.GetString() ), 1, MAX_LEVEL );
	RoomTitle = TitleEditBox.GetString();

	class'PartyMatchAPI'.static.RequestManageMpccRoom( ROOM_NUM, MaxMemberCount, MinLevel, MaxLevel, ROOM_ROUTING, RoomTitle );
		
	Clear();
	Me.HideWindow();
}

function OnCancelButtonClick()
{
	Clear();
	Me.HideWindow();
}

function SetRoomNum( int a_RoomNum )
{
	ROOM_NUM = a_RoomNum;
}	

function SetTitle( String a_Title )
{
	TitleEditBox.SetString( a_Title );
}

function SetMinLevel( int a_MinLevel )
{
	MinLevelEditBox.SetString( string( a_MinLevel ) );
}

function SetMaxLevel( int a_MaxLevel )
{
	MaxLevelEditBox.SetString( string( a_MaxLevel ) );
}

function SetMaxMemberCount( int a_MaxMemberCount )
{
	local int idx;
	
	a_MaxMemberCount = clamp( a_MaxMemberCount, MIN_MEMBER, MAX_MEMBER );
	idx	= ( a_MaxMemberCount - 20 ) / 2;
	MaxMemberCountComboBox.SetSelectedNum( idx );
}

function SetRoomRouting( int a_RoomRouting )
{
	ROOM_ROUTING = a_RoomRouting;
}

function SetMakeType( int a_Type )
{
	MAKE_TYPE = a_Type;
}

function Clear()
{
	MAKE_TYPE = 0;
	ROOM_NUM = 0;
	ROOM_ROUTING = 0;
}
defaultproperties
{
}
