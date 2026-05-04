class UnionMatchWnd extends PartyMatchWndCommon;

var WindowHandle Me;

var ListCtrlHandle lstMember;
var TextBoxHandle lblNum;
var TextBoxHandle txtNum;
var TextBoxHandle lblTitle;
var TextBoxHandle txtTitle;
var TextBoxHandle lblMethod;
var TextBoxHandle txtMethod;
var TextBoxHandle lblMemberCount;
var TextBoxHandle txtMemberCount;
var TextBoxHandle lblLevelLimit;
var TextBoxHandle txtLevelLimit;
var TextListBoxHandle tlstChat;
var EditBoxHandle edChat;
var ButtonHandle btnRoomInfo;
var ButtonHandle btnUnionInfo;
var ButtonHandle btnBan;
var ButtonHandle btnInviteParty;
var ButtonHandle btnInviteUnion;
var ButtonHandle btnExit;
var TextureHandle txListTitleBg;
var TextureHandle txTitleBg;
var TextureHandle txListBg;
var TextureHandle txChatBg;
var TextBoxHandle lblListTitle;

//Ohter Window
var WindowHandle UnionMatchDrawerWnd;
var WindowHandle UnionMatchMakeRoomWnd;
var WindowHandle PartyMatchWnd;
var WindowHandle m_UnionWnd;

//Global Constant
const ROOMMASTER = 1;	//연합 지휘자
const UNIONLEADER = 3;	//연합 지휘자
const UNIONPARTY = 4;	//연합 파티장
const WAITPARTY = 5;	//일반 파티장(연합 미가입중)
const WAITNORMAL = 6;	//일반 대기자(연합 미가입중)

//Global Variable
var string ROOM_NAME;
var int ROOM_TYPE;
var int ROOM_NUM;
var int ROOM_MINLEVEL;
var int ROOM_MAXLEVEL;
var int ROOM_ROUTING;

var int MYID;
var int MYTYPE;
var int CURMEMBER_COUNT;
var int MAXMEMBER_COUNT;

var bool I_REQUEST_EXIT;

var int m_MasterID; // 정우균 추가 2013.01.24

function OnRegisterEvent()
{
	RegisterEvent( EV_DialogOK );
	RegisterEvent( EV_MpccRoomInfo );
	RegisterEvent( EV_DismissMpccRoom );
	RegisterEvent( EV_ManageMpccRoomMember );
	RegisterEvent( EV_MpccRoomMemberStart );
	RegisterEvent( EV_MpccRoomMemberInfo );
	RegisterEvent( EV_MpccRoomChatMessage );
	RegisterEvent( EV_PartyDeleteAllParty );
	RegisterEvent( EV_PartyAddParty );          // 정우균 추가 2013.03.29
	RegisterEvent( EV_PartyDeleteParty );       // 정우균 추가 2013.03.29
}

function OnLoad()
{
	Initialize();
	Load();
}

function Initialize()
{
	Me = GetWindowHandle( "UnionMatchWnd" );
	lstMember = GetListCtrlHandle( "UnionMatchWnd.lstMember" );
	lblNum = GetTextBoxHandle( "UnionMatchWnd.lblNum" );
	txtNum = GetTextBoxHandle( "UnionMatchWnd.txtNum" );
	lblTitle = GetTextBoxHandle( "UnionMatchWnd.lblTitle" );
	txtTitle = GetTextBoxHandle( "UnionMatchWnd.txtTitle" );	
	lblMethod = GetTextBoxHandle( "UnionMatchWnd.lblMethod" );
	txtMethod = GetTextBoxHandle( "UnionMatchWnd.txtMethod" );
	lblMemberCount = GetTextBoxHandle( "UnionMatchWnd.lblMemberCount" );
	txtMemberCount = GetTextBoxHandle( "UnionMatchWnd.txtMemberCount" );
	lblLevelLimit = GetTextBoxHandle( "UnionMatchWnd.lblLevelLimit" );
	txtLevelLimit = GetTextBoxHandle( "UnionMatchWnd.txtLevelLimit" );
	tlstChat = GetTextListBoxHandle( "UnionMatchWnd.tlstChat" );
	edChat = GetEditBoxHandle( "UnionMatchWnd.edChat" );
	btnRoomInfo = GetButtonHandle( "UnionMatchWnd.btnRoomInfo" );
	btnUnionInfo = GetButtonHandle( "UnionMatchWnd.btnUnionInfo" );
	btnBan = GetButtonHandle( "UnionMatchWnd.btnBan" );
	btnInviteParty = GetButtonHandle( "UnionMatchWnd.btnInviteParty" );
	btnInviteUnion = GetButtonHandle( "UnionMatchWnd.btnInviteUnion" );
	btnExit = GetButtonHandle( "UnionMatchWnd.btnExit" );
	txListTitleBg = GetTextureHandle( "UnionMatchWnd.txListTitleBg" );
	txTitleBg = GetTextureHandle( "UnionMatchWnd.txTitleBg" );
	txListBg = GetTextureHandle( "UnionMatchWnd.txListBg" );
	txChatBg = GetTextureHandle( "UnionMatchWnd.txChatBg" );
	lblListTitle = GetTextBoxHandle( "UnionMatchWnd.lblListTitle" );
	
	//Other Window
	m_UnionWnd = GetWindowHandle( "UnionWnd" );
	UnionMatchDrawerWnd = GetWindowHandle( "UnionMatchDrawerWnd" );
	UnionMatchMakeRoomWnd = GetWindowHandle( "UnionMatchMakeRoomWnd" );
	PartyMatchWnd = GetWindowHandle( "PartyMatchWnd" );
}

function Load()
{
	CURMEMBER_COUNT = 0;
	I_REQUEST_EXIT = false;
}

function OnEvent(int EventID, String param)
{
//	Debug("OnEvent" @ EventID @ param );
	switch( EventID )
	{
	case EV_MpccRoomInfo:
		HandleMpccRoomInfo(param);
		break;
	case EV_DismissMpccRoom:
		HandleDismissMpccRoom(param);
		break;
	case EV_ManageMpccRoomMember:
		HandleManageMpccRoomMember(param);
		break;
	case EV_MpccRoomMemberStart:
		HandleMpccRoomMemberStart(param);
		break;
	case EV_MpccRoomMemberInfo:
		HandleMpccRoomMemberInfo(param);
		break;
	case EV_MpccRoomChatMessage:
		HandleMpccRoomChatMessage(param);
		break;
	
	//파티원 제외
	case EV_PartyDeleteParty:
		class'PartyMatchAPI'.static.RequestDismissMpccRoom();	//연합매칭 해산!
		Me.HideWindow();
		break;

	case EV_PartyDeleteAllParty:
		//class'CommandChannelAPI'.static.RequestCommandChannelInfo();
		class'PartyMatchAPI'.static.RequestDismissMpccRoom();	//연합매칭 해산!
		Me.HideWindow();
		break;
	case EV_DialogOK:
		if( DialogIsMine() )
		{
			//연합지휘자가 연합매칭방을 나갈때.
			if( DialogGetID() == 1 )
			{
				class'PartyMatchAPI'.static.RequestDismissMpccRoom();	//연합매칭 해산!
				Me.HideWindow();
			}
		}
		break;		
	}	
}

function OnClickButton( string Name )
{
	switch( Name )
	{
	case "btnRoomInfo":
		OnbtnRoomInfoClick();
		break;
	case "btnUnionInfo":
		OnbtnUnionInfoClick();
		break;
	case "btnBan":
		OnbtnBanClick();
		break;
	case "btnInviteParty":
		OnbtnInvitePartyClick();
		break;
	case "btnInviteUnion":
		OnbtnInviteUnionClick();
		break;
	case "btnExit":
		OnbtnExitClick();
		break;
	}
}

//UnionMatchDrawerWnd가 보여지고 있으면, 갱신
function OnShow()
{
	if( UnionMatchDrawerWnd.IsShowWindow() )
		class'PartyMatchAPI'.static.RequestMpccPartymasterList();
	if( m_UnionWnd.IsShowWindow())
		class'PartyMatchAPI'.static.RequestMpccPartymasterList();
}

//채팅메세지 전송
function OnCompleteEditBox( String strID )
{
	local String ChatMsg;

	if( strID == "edChat" )
	{
		ChatMsg = edChat.GetString();
		ProcessPartyMatchChatMessage(CHAT_MPCC_ROOM, ChatMsg );
		edChat.SetString( "" );
	}
}

//[방설정] 버튼
function OnbtnRoomInfoClick()
{
	local UnionMatchMakeRoomWnd Script;

	Script = UnionMatchMakeRoomWnd( GetScript( "UnionMatchMakeRoomWnd" ) );
	if( Script != None )
	{
		Script.SetMakeType( UNION_MAKEROOM_EDIT );
		Script.SetRoomNum( ROOM_NUM );
		Script.SetTitle( ROOM_NAME );
		Script.SetMaxMemberCount( MAXMEMBER_COUNT );
		Script.SetMinLevel( ROOM_MINLEVEL );
		Script.SetMaxLevel( ROOM_MAXLEVEL );
		Script.SetRoomRouting( ROOM_ROUTING );
	}

	UnionMatchMakeRoomWnd.ShowWindow();
	UnionMatchMakeRoomWnd.SetFocus();
}

//[연합정보] 버튼
function OnbtnUnionInfoClick()
{
	if( !UnionMatchDrawerWnd.IsShowWindow() )
	{
		UnionMatchDrawerWnd.ShowWindow();
		class'PartyMatchAPI'.static.RequestMpccPartymasterList();
	}
	else
	{
		UnionMatchDrawerWnd.HideWindow();
	}
}

//[강제추방] 버튼
function OnbtnBanClick()
{
	local int idx;
	local LVDataRecord Record;
	
	idx = lstMember.GetSelectedIndex();
	if( idx < 0 )
		return;
	
	lstMember.GetRec( idx, Record );
	class'PartyMatchAPI'.static.RequestOustFromMpccRoom( Record.LVDataList[0].nReserved1 );
}

//[파티초대] 버튼
function OnbtnInvitePartyClick()
{
	local int idx;
	local LVDataRecord Record;
	
	idx = lstMember.GetSelectedIndex();
	if( idx < 0 )
		return;
	
	lstMember.GetRec( idx, Record );
	if( Record.LVDataList[3].nReserved1 == WAITNORMAL )
		RequestInviteParty( Record.LVDataList[0].szData );
}

//[연합초대] 버튼
function OnbtnInviteUnionClick()
{
	local int idx;
	local LVDataRecord Record;
	
	idx = lstMember.GetSelectedIndex();
	if( idx < 0 )
		return;
	
	lstMember.GetRec( idx, Record );
	if( Record.LVDataList[3].nReserved1 == WAITPARTY )
		RequestInviteMpcc( Record.LVDataList[0].szData );
}

//[방나가기] 버튼
function OnbtnExitClick()
{
	switch( MYTYPE )
	{
	//연합지휘자 -> 창을 닫으면 연합매칭방이 해산됨을 경고한다.
	case ROOMMASTER:
	case UNIONLEADER:
		DialogShow(DialogModalType_Modalless, DialogType_OKCancel, GetSystemMessage( 2993 ), string(Self) );
		DialogSetID( 1 );
		break;
	//연합파티장 -> 그냥 창이 닫힌다.
	case UNIONPARTY:
		Me.HideWindow();
		break;
	//일반파티장,대기자 -> 나가기 패킷을 보낸다.
	case WAITPARTY:
	case WAITNORMAL:
		class'PartyMatchAPI'.static.RequestWithdrawMpccRoom();
		I_REQUEST_EXIT = true;
		break;
	}
}

//연합매칭 방 정보
function HandleMpccRoomInfo(string param)
/*
RoomNum        : INT 방번호
MaxMemberLimit : INT 최대인원수
MinLevelLimit  : INT 레벨하한
MaxLevelLimit  : INT 레벨상한
PartyRouting   : INT 파티루팅타입  0: 주운사람 1:랜덤 2:스포일 포함 랜덤 3:순서대로 4:스포일 포함 순서대로 5:파티장
Title          : string 방이름 
*/
{	
	local Rect rectWnd;

	local L2Util util ;
	util = L2Util(GetScript("L2Util"));	

	
	ParseInt( param, "RoomNum", ROOM_NUM );
	ParseInt( param, "MaxMemberLimit", MAXMEMBER_COUNT );
	ParseInt( param, "MinLevelLimit", ROOM_MINLEVEL );
	ParseInt( param, "MaxLevelLimit", ROOM_MAXLEVEL );
	ParseInt( param, "PartyRouting", ROOM_ROUTING );	
	ParseString( param, "Title", ROOM_NAME );
	
	//파티매칭창이 있으면 Hide하고, 그 위치로 연합매칭창을 보여준다.
	if (PartyMatchWnd.IsShowWindow())
		PartyMatchWnd.HideWindow();
	rectWnd = PartyMatchWnd.GetRect();
	Me.MoveTo(rectWnd.nX, rectWnd.nY);
	Me.ShowWindow();
	Me.SetFocus();
	
	txtNum.SetText( String( ROOM_NUM ) );
	txtTitle.SetText( ROOM_NAME );	
	txtMethod.SetText( util.getLootingString( ROOM_ROUTING ) );
	txtLevelLimit.SetText( string( ROOM_MINLEVEL ) $ "-" $ ROOM_MAXLEVEL );
	tlstChat.Clear();
}

//방채팅 메세지 처리
function HandleMpccRoomChatMessage( string param )
{
	local Color ChatColor;
	local String ChatMessage;
	local int tmpType;
	
	ParseInt( param, "SayType", tmpType );
	ParseString( param, "Msg", ChatMessage );
	ChatColor=GetChatColorByType(tmpType);
	
	tlstChat.AddString( ChatMessage, ChatColor );
	
	if( Me.IsMinimizedWindow() )
	{
		PlaySound("ItemSound3.Sys_party_matching"); //ldw 20120709 추가 사운드
	}
	NotifyMe();
}

//연합매칭방 나가라
function HandleDismissMpccRoom( string param )
{
	local Rect rectWnd;
	
	if( Me.IsShowWindow() )
	{
		Me.HideWindow();
		rectWnd= Me.GetRect();
		PartyMatchWnd.MoveTo( rectWnd.nX, rectWnd.nY );
	}
	
	//일반파티장,대기자 -> 내가 나간다고 버튼을 눌렀을 때, 파티매칭창을 보여준다.
	if( I_REQUEST_EXIT == false )
		return;
		
	switch( MYTYPE )
	{
	case WAITPARTY:
	case WAITNORMAL:
		PartyMatchWnd.ShowWindow();
		PartyMatchWnd.SetFocus();
		break;
	}
	
	I_REQUEST_EXIT = false;
}

//연합매칭방 리스트 받기 시작~
function HandleMpccRoomMemberStart( string param )
/* 
MyPartyRoomStatus	: INT (3:연합매칭 연합채널장, 4:연합매칭 연합채널파티장, 5:연합매칭 일반파티장, 6:연합매칭 개인)
MemberCount			: INT 멤버수
*/
{
	local Rect rectWnd;
	local UserInfo MyInfo;
	
	//Clear
	MYID = 0;
	MYTYPE = 0;
	if( GetPlayerInfo( MyInfo ) )
		MYID = MyInfo.nID;
	CURMEMBER_COUNT = 0;
	lstMember.DeleteAllItem();
	
	ParseInt( param,"MyPartyRoomStatus", ROOM_TYPE) ;
	UpdateInfoButton();
	UpdateRelationButton();

	//연합매칭창 갱신	
	if( !Me.IsShowWindow() )
	{
		rectWnd= PartyMatchWnd.GetRect();
		Me.MoveTo( rectWnd.nX, rectWnd.nY );
		Me.ShowWindow();
		Me.SetFocus();
	}
	else
		NotifyMe();
}

//연합매칭방 인원 리스트
function HandleMpccRoomMemberInfo( string param )
/* 
ID              : INT 캐릭터ID
Name            : string 이름
Level           : INT 레벨
ClassID         : INT 클래스ID
partyRoomStatus : INT (3:연합매칭 연합채널장, 4:연합매칭 연합채널파티장, 5:연합매칭 일반파티장, 6:연합매칭 개인)
 */
{
	local int ID;
	local string Name;
	local int Level;
	local int ClassID;	
	local int partyRoomStatus;
	
	ParseInt( param, "ID", ID );
	ParseString( param,"Name", Name );
	ParseInt( param,"Level", Level );
	ParseInt( param, "ClassID", ClassID );	
	ParseInt( param, "partyRoomStatus", partyRoomStatus );
		
	AddMember( ID, Name, ClassID, Level, partyRoomStatus );
}

//연합매칭방 인원 정보 수정
function HandleManageMpccRoomMember( string param )
/* 
Type            : INT 상태   0: add, 1: modify, 2, delete
ID              : INT 유저 ID
Name            : string 유저 이름
Level           : INT Level
ClassID         : INT 클래스ID
partyRoomStatus : INT 파티방 상태 (3:연합매칭 연합채널장, 4:연합매칭 연합채널파티장, 5:연합매칭 일반파티장, 6:연합매칭 개인)
*/
{
	local int Type;
	local int ID;
	local string Name;
	local int Level;
	local int ClassID;	
	local int partyRoomStatus;
	
	ParseInt( param, "Type", Type );
	ParseInt( param,"ID", ID );
	
	switch(Type)
	{
	//Add
	case 0:
		ParseString( param,"Name", Name );
		ParseInt( param,"Level", Level );
		ParseInt( param, "ClassID", ClassID );		
		ParseInt( param, "partyRoomStatus", partyRoomStatus );
		AddMember( ID, Name, ClassID, Level, partyRoomStatus );
		break;
	//Modify
	case 1:
		ParseString(param,"Name",  Name);
		ParseInt( param,"Level", Level);
		ParseInt( param, "ClassID", ClassID );		
		ParseInt( param, "partyRoomStatus", partyRoomStatus);
		ModifyMember( ID, Name, ClassID, Level, partyRoomStatus );
		break;
	//Delete
	case 2:
		RemoveMember( ID );
		break;
	}
	
	NotifyMe();
}

//현재 인원수 갱신
function UpdateMemberCount()
{
	txtMemberCount.SetText( string( CURMEMBER_COUNT ) $ "/" $ MAXMEMBER_COUNT );
}

//화면 버튼 갱신
function UpdateInfoButton()
{
	switch( ROOM_TYPE )
	{
	case ROOMMASTER:
	case UNIONLEADER:
		btnRoomInfo.EnableWindow();
		break;
	case UNIONPARTY:
	case WAITNORMAL:
	case WAITPARTY:
		btnRoomInfo.DisableWindow();
		break;
	}
}
function UpdateRelationButton()
{
	local int idx;
	local LVDataRecord Record;
	//local string Name;
	
	btnBan.DisableWindow();
	btnInviteParty.DisableWindow();
	btnInviteUnion.DisableWindow();	
	
	if( ROOM_TYPE == WAITNORMAL )
		return;
	
	
	idx = lstMember.GetSelectedIndex();

	//Debug ( "UpdateRelationButton"  @ idx @  lstMember.GetRecordCount()  );

	if( idx < 0 )
		return;
	
	//마지막 줄이 삭제 될 경우 에러가 발생 됨 hardcom0
	if ( idx == lstMember.GetRecordCount() ) 
		return;
	
	lstMember.GetRec( idx, Record );	
	
	if( Record.LVDataList[3].nReserved1 == WAITPARTY )
	{
		if( IsMaster() )
		{
			btnBan.EnableWindow();
			btnInviteUnion.EnableWindow();
		}
	}
	else if( Record.LVDataList[3].nReserved1 == WAITNORMAL )
	{
		if( IsMaster() )
		{
			btnBan.EnableWindow();
		}
		btnInviteParty.EnableWindow();
	}
}

//연합지휘자인가?
function bool IsMaster()
{
	if( ROOM_TYPE == UNIONLEADER || ROOM_TYPE == ROOMMASTER )
		return true;
	return false;
}

//깜박거리기
function NotifyMe()
{
	if( Me.IsMinimizedWindow() )
		Me.NotifyAlarm();	
}

//리스트에 인원 추가
function AddMember( int a_ID, string a_Name, int a_ClassID, int a_Level, int a_partyRoomStatus )
{
	local int idx;
	local LVDataRecord Record;
	
	//Already exist
	idx = FindMember( a_ID );
	if( idx > -1 )
		return;

	Record = MakeRecord( a_ID, a_Name, a_ClassID, a_Level, a_partyRoomStatus );
	lstMember.InsertRecord(Record );
	
	CURMEMBER_COUNT++;
	UpdateMemberCount();
	
	if( a_ID == MYID )
		MYTYPE = a_partyRoomStatus;
}

//리스트에서 인원 제거
function RemoveMember( int a_ID )
{
	local int idx;
	
	idx = FindMember( a_ID );
	if( idx < 0 )
		return;
		
	lstMember.DeleteRecord( idx );
	
	CURMEMBER_COUNT--;
	UpdateMemberCount();
	UpdateRelationButton();
}

//리스트에서 인원정보 수정
function ModifyMember( int a_ID, string a_Name, int a_ClassID, int a_Level, int a_partyRoomStatus )
{
	local int idx;
	local LVDataRecord Record;
	
	idx = FindMember( a_ID );
	if( idx < 0 )
		return;
		
	Record = MakeRecord( a_ID, a_Name, a_ClassID, a_Level, a_partyRoomStatus );
	lstMember.ModifyRecord( idx, Record );
	
	if( a_ID == MYID )
		MYTYPE = a_partyRoomStatus;
	
	UpdateRelationButton();
}

//리스트에서 멤버ID로 리스트의 Index를 찾음
function int FindMember( int a_ID )
{
	local int i;
	local int RecordCount;
	local LVDataRecord Record;

	RecordCount = lstMember.GetRecordCount();
	for( i=0; i<RecordCount; i++ )
	{
		lstMember.GetRec( i, Record );
		if( Record.LVDataList[0].nReserved1 == a_ID )
			return i;
	}
	return -1;
}

//여러 정보로 리스트의 레코드를 만듬.
function LVDataRecord MakeRecord( int a_ID, string a_Name, int a_ClassID, int a_Level, int a_partyRoomStatus )
{
	local LVDataRecord Record;
	
	Record.LVDataList.length = 5;
	Record.LVDataList[0].szData = a_Name;
	Record.LVDataList[0].nReserved1 = a_ID;
	Record.LVDataList[1].szData = String( a_ClassID );
	Record.LVDataList[1].szTexture = GetClassRoleIconName( a_ClassID );
	Record.LVDataList[1].nTextureWidth = 11;
	Record.LVDataList[1].nTextureHeight = 11;
	Record.LVDataList[2].szData = GetAmbiguousLevelString( a_Level, true );	
	switch( a_partyRoomStatus )
	{
		case ROOMMASTER:
		case UNIONLEADER:
			//연합지휘자
			Record.LVDataList[3].szData = GetSystemString( 2217 );
			break;
		case UNIONPARTY:
			//연합파티장
			Record.LVDataList[3].szData = GetSystemString( 2218 );
			break;
		case WAITPARTY:
			//일반파티장
			Record.LVDataList[3].szData = GetSystemString( 2219 );
			break;
		case WAITNORMAL:
			//일반대기자
			Record.LVDataList[3].szData = GetSystemString( 2220 );
			break;
	}	
	Record.LVDataList[3].nReserved1 = a_partyRoomStatus;
	
	return Record;
}

//연합 멤버를 클릭했을 때, 버튼 갱신
function OnClickListCtrlRecord( string ID )
{
	if( ID == "lstMember" )
		UpdateRelationButton();
}
defaultproperties
{
}
