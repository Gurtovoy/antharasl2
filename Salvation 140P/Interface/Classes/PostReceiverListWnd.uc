class PostReceiverListWnd extends UICommonAPI;


var string m_WindowName;
var WindowHandle Me;
var TextBoxHandle Description;
var TextureHandle DescriptionGroupBox;
var TextBoxHandle ListCount;
var TabHandle TabCtrl;
var TextureHandle ListGroupBox;
var TextureHandle TabLineTop;
var TextureHandle tabBg;
var WindowHandle PostReceiverListWnd_Friends;
var ListCtrlHandle FriendsList;
var TextureHandle FriendsListDeco;
var WindowHandle PostReceiverListWnd_Clan;
var ListCtrlHandle ClanList;
var TextureHandle ClanListDeco;
var WindowHandle PostReceiverListWnd_Add;
var ListCtrlHandle AddList;
var ButtonHandle Btn_Add;
var ButtonHandle Btn_Del;
var TextureHandle AddListGroupBoxLine;
var TextureHandle AddListDeco;
var ButtonHandle CloseButton;

var WindowHandle    PostReceiverListAddWnd;

var int m_selectedTab;

var string countFriend;
var string countPledge;
var string countPostFriend;
var string selectFriend;

var int NumPostFriend;

var bool bPostFriendSelect;


//다이얼 로그창 이벤트 넘버
const DIALOGID_DelFriend = 1;
const DIALOGID_ErrorFriend = 2;

//각 텝의 최대치
const MAX_FRIEND = 128;
const MAX_PLEDGE = 220;
const MAX_POSTFRIEND = 100;

//텝의 넘버
const FRIEND_TAB = 0;
const PLEDGE_TAB = 1;
const POSTFRIEND_TAB = 2;


function OnRegisterEvent()
{
	RegisterEvent( EV_ReceiveFriendList );
	RegisterEvent( EV_ReceivePledgeMemberList );
	RegisterEvent( EV_ReceivePostFriendList );
	RegisterEvent( EV_ConfirmAddingPostFriend );

	RegisterEvent( EV_DialogOK );
	RegisterEvent( EV_DialogCancel );

	RegisterEvent( EV_ListCtrlLoseSelected );
	RegisterEvent( EV_Restart );
}

function OnLoad()
{
	SetClosingOnESC();

	Initialize();
	Load();
	m_selectedTab = FRIEND_TAB;
	selectedInit();

}

function selectedInit()
{
	selectFriend = "";
	bPostFriendSelect = false;
}

function Initialize()
{
	Me = GetWindowHandle( "PostReceiverListWnd" );
	Description = GetTextBoxHandle( "PostReceiverListWnd.Description" );
	DescriptionGroupBox = GetTextureHandle( "PostReceiverListWnd.DescriptionGroupBox" );
	ListCount = GetTextBoxHandle( "PostReceiverListWnd.ListCount" );
	TabCtrl = GetTabHandle( "PostReceiverListWnd.TabCtrl" );
	ListGroupBox = GetTextureHandle( "PostReceiverListWnd.ListGroupBox" );
	TabLineTop = GetTextureHandle( "PostReceiverListWnd.TabLineTop" );
	tabBg = GetTextureHandle( "PostReceiverListWnd.tabBg" );
	PostReceiverListWnd_Friends = GetWindowHandle( "PostReceiverListWnd.PostReceiverListWnd_Friends" );
	FriendsList = GetListCtrlHandle( "PostReceiverListWnd.PostReceiverListWnd_Friends.FriendsList" );
	FriendsListDeco = GetTextureHandle( "PostReceiverListWnd.PostReceiverListWnd_Friends.FriendsListDeco" );
	PostReceiverListWnd_Clan = GetWindowHandle( "PostReceiverListWnd.PostReceiverListWnd_Clan" );
	ClanList = GetListCtrlHandle( "PostReceiverListWnd.PostReceiverListWnd_Clan.ClanList" );
	ClanListDeco = GetTextureHandle( "PostReceiverListWnd.PostReceiverListWnd_Clan.ClanListDeco" );
	PostReceiverListWnd_Add = GetWindowHandle( "PostReceiverListWnd.PostReceiverListWnd_Add" );
	AddList = GetListCtrlHandle( "PostReceiverListWnd.PostReceiverListWnd_Add.AddList" );
	Btn_Add = GetButtonHandle( "PostReceiverListWnd.PostReceiverListWnd_Add.Btn_Add" );
	Btn_Del = GetButtonHandle( "PostReceiverListWnd.PostReceiverListWnd_Add.Btn_Del" );
	AddListGroupBoxLine = GetTextureHandle( "PostReceiverListWnd.PostReceiverListWnd_Add.AddListGroupBoxLine" );
	AddListDeco = GetTextureHandle( "PostReceiverListWnd.PostReceiverListWnd_Add.AddListDeco" );
	CloseButton = GetButtonHandle( "PostReceiverListWnd.CloseButton" );

	PostReceiverListAddWnd = GetWindowHandle( "PostReceiverListAddWnd" );
}

function Load(){
	
}

function OnShow()
{	
	SetCount( m_selectedTab );
	Btn_Del.DisableWindow();
}

function OnClickButton( string Name )
{
	switch( Name )
	{
	case "Btn_Add":
		OnBtn_AddClick();
		break;
	case "Btn_Del":
		OnBtn_DelClick();
		break;
	case "CloseButton":
		OnCloseButtonClick();
		break;

	case "TabCtrl0":
		setFriendCount();
		break;
	case "TabCtrl1":
		setPledgeCount();
		break;
	case "TabCtrl2":
		setPostFrienddCount();
		break;
	}
}

//친구 텝의 카운트 및 변수 지정 
function setFriendCount()
{
	m_selectedTab = FRIEND_TAB;	
	SetCount(m_selectedTab);
}
//혈맹 텝의 카운트 및 변수 지정
function setPledgeCount()
{
	m_selectedTab = PLEDGE_TAB;
	SetCount(m_selectedTab);
}
//받는이추가 텝의 카운트 및 변수 지정
function setPostFrienddCount()
{
	m_selectedTab = POSTFRIEND_TAB;
	SetCount(m_selectedTab);
}

//각 텝의 인원수 표시
function SetCount( int count )
{
	switch( count )
	{
		case FRIEND_TAB:
			ListCount.SetText( countFriend );
			break;
		case PLEDGE_TAB:
			ListCount.SetText( countPledge );
			break;
		case POSTFRIEND_TAB:
			ListCount.SetText( countPostFriend );
			break;
	}
}
//받는이 추가 텝의 새이름 추가
function OnBtn_AddClick()
{
	DisableTab();

	class'UIAPI_EDITBOX'.static.SetString( "PostReceiverListAddWnd.Name", "" );
	PostReceiverListAddWnd.ShowWindow();
	PostReceiverListAddWnd.SetFocus();
}

function DisableTab()
{
	local ButtonHandle sendBtn;
	sendBtn = GetButtonHandle( "PostWriteWnd.SendBtn" );

	sendBtn.DisableWindow();
	AddList.DisableWindow();
	TabCtrl.DisableWindow();	
	Btn_Add.DisableWindow();
	Btn_del.DisableWindow();
	CloseButton.DisableWindow();

}

function EnableTab()
{
	local ButtonHandle sendBtn;
	sendBtn = GetButtonHandle( "PostWriteWnd.SendBtn" );

	sendBtn.EnableWindow();
	TabCtrl.EnableWindow();
	AddList.EnableWindow();
	Btn_Add.EnableWindow();

	if(	bPostFriendSelect )
	{
		Btn_del.EnableWindow();
	}
	CloseButton.EnableWindow();
}

//받는이 추가 텝의 선택 이름 삭제
function OnBtn_DelClick()
{
	if( selectFriend != "" )
	{
		DisableTab();

		DialogSetID( DIALOGID_DelFriend );
		DialogShow( DialogModalType_Modalless, DialogType_OKCancel, MakeFullSystemMsg( GetSystemMessage( 3218 ), selectFriend, "" ), string(Self) );		
	}
}
//선택 이름 삭제 시 확인 버튼 클릭 이벤트 
function HandleDialogOK()
{
	if( DialogIsMine() )
	{
		switch( DialogGetID() )
		{
		case DIALOGID_DelFriend:
			//받는이 추가 리스트의 선택 이름 삭제				
			EnableTab();
			Btn_Del.DisableWindow();		
			DeletePostFriend();		
			break;

		case DIALOGID_ErrorFriend:
			EnableTab();
			break;

		default:
			EnableTab();
			break;
		}
	}
	else
	{
		//예외 처리 다른 dialog 창이 떳을 경우.
		EnableTab();
	}
}
//선택 이름 삭제 시 취소 버튼 클릭 이벤트 
function HandleDialogCancel()
{
	if( DialogIsMine() )
	{
		switch( DialogGetID() )
		{
		//"이름 삭제가 취소 되었습니다." 시스템 메시지 보여줌.
		case DIALOGID_DelFriend:
			EnableTab();
			AddSystemMessage(3220);
			break;

		default:
			EnableTab();
			break;
		}
	}
	else
	{
		//예외 처리 다른 dialog 창이 떳을 경우.
		EnableTab();
	}
}

//받는이 추가 리스트의 선택 이름 삭제
function DeletePostFriend()
{
	local int i;
	
	NumPostFriend = NumPostFriend - 1;	
	countPostFriend = "(" $ string(NumPostFriend) $ "/" $ MAX_POSTFRIEND $ ") ";
	SetCount( POSTFRIEND_TAB );

	i = AddList.GetSelectedIndex();

	AddList.DeleteRecord( i );
	
	class'PostWndAPI'.static.RequestDeletingPostFriend( selectFriend );

	class'PostWndAPI'.static.RequestPostFriendList();

	selectedInit();
}
//닫기 버튼 클릭 시.
function OnCloseButtonClick()
{
	local PostWriteWnd Script;
	
	Script = PostWriteWnd( GetScript( "PostWriteWnd" ) );
	
	Script.SetBoolPostReceiverList( false );
	HandleRestart();
	Me.HideWindow();	
}

function OnEvent( int Event_ID, String Param )
{
	switch(Event_ID)
	{
	case EV_ReceiveFriendList:
		FriendsList.DeleteAllItem();
		HandleReceiveFriendList(Param);
		break;

	case EV_ReceivePledgeMemberList:
		ClanList.DeleteAllItem();
		HandleReceivePledgeMemberList(Param);
		break;

	case EV_ReceivePostFriendList:
		AddList.DeleteAllItem();
		HandleReceivePostFriendList(Param);
		break;

	case EV_ConfirmAddingPostFriend:
		HandleConfirmAddingPostFriend(Param);
		break;
	
	case EV_DialogOK:
		HandleDialogOK();
		break;

	case EV_DialogCancel:
		HandleDialogCancel();
		break;
	//리스트컨트롤 선택 해지
	case EV_ListCtrlLoseSelected:
		HandleListCtrlLose(Param);
		break;
	//다시시작 했을 때
	case EV_Restart:
		HandleRestart();
		break;
	}
}
function HandleRestart()
{
	selectFriend = "";
	bPostFriendSelect = false;
}

//친구 리스트 이멘트 받았을때 처리
function HandleReceiveFriendList( string param )
{
	local int Num;
	local int i;
	local string strName;
	local int FriendClass;
	local int FriendLevel;
	local LVDataRecord Record;
	local EditBoxHandle e_handle; //윈도우 핸들 선언
	local array<String> addName;

	e_handle = GetEditBoxHandle( "PostWriteWnd.ReceiverID" ); //핸들을 가져온다

	ParseInt( Param, "Num", Num );

	countFriend = "(" $ string(Num) $ "/" $ MAX_FRIEND $ ") ";

	for( i = 0 ; i < Num ; i++ )
	{
		ParseString( Param, "Name"$i, strName );
		ParseInt( Param, "FriendClass"$i, FriendClass );
		ParseInt( Param, "FriendLevel"$i, FriendLevel );
		
		//debug("친구 Name--->> " $ strName );
		//debug("친구 FriendClass--->> " $ string(FriendClass) );
		//debug("친구 FriendLevel--->> " $ string(FriendLevel) );
		//debug(string(i)@"--------------------------------->>>>"@addName[i]);	
		//class'UIAPI_EDITBOX'.static.AddNameToAdditionalFriendSearchList( "PostWriteWnd.ReceiverID", strName );		

		addName[i] = strName;

		Record.LVDataList.length = 3;
		Record.LVDataList[0].szData = strName;
		Record.LVDataList[1].szTexture = GetClassRoleIconName( FriendClass );
		Record.LVDataList[1].nTextureWidth = 11;
		Record.LVDataList[1].nTextureHeight = 11;
		Record.LVDataList[1].szData = String( FriendClass );
		Record.LVDataList[1].HiddenStringForSorting = String (GetClassRoleType( FriendClass ));
		Record.LVDataList[2].szData = string( FriendLevel );
		//Record.nReserved1 = FriendLevel;

		class'UIAPI_LISTCTRL'.static.InsertRecord( "PostReceiverListWnd.FriendsList", Record );
	}

	e_handle.FillAdditionalSearchList( addName, SLT_FRIEND_LIST );
	SetCount(m_selectedTab);
}

//혈맹 리스트 이멘트 받았을때 처리
function HandleReceivePledgeMemberList( string param )
{
	local int Num;
	local int i;
	local string strName;
	local int ClanClass;
	local int ClanLevel;
	local LVDataRecord Record;
	local EditBoxHandle e_handle; //윈도우 핸들 선언
	local array<String> addName;

	e_handle = GetEditBoxHandle( "PostWriteWnd.ReceiverID" ); //핸들을 가져온다
	ParseInt( Param, "Num", Num );
	
	//debug("-------->>>>>"$Num);

	countPledge = "(" $ string(Num) $ "/" $ MAX_PLEDGE $ ") ";
	
	for( i = 0 ; i < Num ; i++ )
	{
		ParseString( Param, "Name"$i, strName );
		ParseInt( Param, "FriendClass"$i, ClanClass );
		ParseInt( Param, "FriendLevel"$i, ClanLevel );
		
		//debug("친구 Name--->> " $ strName );
		//debug("친구 ClanClass--->> " $ string(ClanClass) );
		//debug("친구 ClanLevel--->> " $ string(ClanLevel) );
		
		addName[i] = strName;

		Record.LVDataList.length = 3;
		Record.LVDataList[0].szData = strName;
		Record.LVDataList[1].szTexture = GetClassRoleIconName( ClanClass );
		Record.LVDataList[1].nTextureWidth = 11;
		Record.LVDataList[1].nTextureHeight = 11;
		Record.LVDataList[1].szData = String( ClanClass );
		Record.LVDataList[1].HiddenStringForSorting = String (GetClassRoleType( ClanClass ));
		Record.LVDataList[2].szData = string( ClanLevel );

		class'UIAPI_LISTCTRL'.static.InsertRecord( "PostReceiverListWnd.ClanList", Record );
	}

	e_handle.FillAdditionalSearchList( addName, SLT_PLEDGEMEMBER_LIST );
	SetCount(m_selectedTab);
}

//받는이 추가 리스트 이멘트 받았을때 처리
function HandleReceivePostFriendList( string param )
{
	local int Num;
	local int i;
	local string strName;
	local LVDataRecord Record;
	local EditBoxHandle e_handle; //윈도우 핸들 선언
	local array<String> addName;

	e_handle = GetEditBoxHandle( "PostWriteWnd.ReceiverID" ); //핸들을 가져온다
	ParseInt( Param, "Num", Num );
	NumPostFriend = Num;

	//debug("Post 친구 숫자--->> " $ string(Num) );	

	countPostFriend = "(" $ string(NumPostFriend) $ "/" $ MAX_POSTFRIEND $ ") ";

	for( i = 0 ; i < Num ; i++ )
	{
		ParseString( Param, "Name"$i, strName );
		
		addName[i] = strName;

		Record.LVDataList.length = 1;
		Record.LVDataList[0].szData = strName;

		class'UIAPI_LISTCTRL'.static.InsertRecord( "PostReceiverListWnd.AddList", Record );
	}

	e_handle.FillAdditionalSearchList( addName, SLT_ADDITIONALFRIEND_LIST );
	SetCount(m_selectedTab);
}

//받는 이 추가의 새 이름 추가시 성공 실패의 이벤트 처리.
function HandleConfirmAddingPostFriend( string param )
{
	local string strName;
	local int Result;

	ParseString( Param, "Name", strName );
	ParseInt( Param, "Result", Result );
	
	if( Result == 1 )
	{
		//debug( "받는이 추가 성공" );
		class'PostWndAPI'.static.RequestPostFriendList();
		EnableTab();
	}
	else if( Result == -1 )
	{
		//debug( "연속해서 입력한 경우 --> 아마 없을 듯" );
		//이전 이름을 등록 하는 중입니다. 잠시 후에 다시 시도해주세요.
		DialogSetID( DIALOGID_ErrorFriend );
		DialogShow( DialogModalType_Modalless,DialogType_Notice, GetSystemMessage(3223), string(Self) );
	}
	else if( Result == -2 || Result == 0 )
	{
		//debug( "존재하지 않는 이름!!" $  strName );
		//??은 존재하지 않는 이름입니다. 다시 확인하시고 입력해 주세요.
		DialogSetID( DIALOGID_ErrorFriend );
		DialogShow( DialogModalType_Modalless, DialogType_Notice, MakeFullSystemMsg( GetSystemMessage( 3215 ), strName, "" ), string(Self) );
	}
	else if( Result == -3 )
	{
		//debug( "100이 넘었을 경우." );
		//이름 추가 한도(100명)를  초과하여 더는 등록할 수  없습니다.
		DialogSetID( DIALOGID_ErrorFriend );
		DialogShow( DialogModalType_Modalless,DialogType_Notice, GetSystemMessage(3222), string(Self) );
	}
	else if( Result == -4 )
	{
		//debug( "중복된 이름인 경우." );
		//이미 받는 이 추가 목록에 존재하는 이름입니다.
		DialogSetID( DIALOGID_ErrorFriend );
		DialogShow( DialogModalType_Modalless,DialogType_Notice, GetSystemMessage(3216), string(Self) );
	}
	else
	{
		//debug( "이유 모름..? 실패!!!>>>Result=="$string(Result) );
		//현재 이름을 등록 할 수 없는 상황입니다.
		DialogSetID( DIALOGID_ErrorFriend );
		DialogShow(DialogModalType_Modalless,DialogType_Notice, GetSystemMessage(3217), string(Self));
	}	
}

//받는 이 추가에서 선택 해지됬을 경우.
function HandleListCtrlLose( string param )
{
	local string ListCtrlName;
	
	ParseString( Param, "ListCtrlName", ListCtrlName );

	if( ListCtrlName == AddList.GetWindowName() )
	{
		bPostFriendSelect = false;
		Btn_Del.DisableWindow();
	}
}

//레코드를 더블클릭하면....
function OnDBClickListCtrlRecord( string ListCtrlID )
{
	local LVDataRecord	record;	
	
	switch(ListCtrlID)
	{
		case "FriendsList" :
			FriendsList.GetSelectedRec( record );
			class'UIAPI_EDITBOX'.static.SetString( "PostWriteWnd.ReceiverID", record.LVDataList[0].szData );
			break;

		case "ClanList":
			ClanList.GetSelectedRec( record );
			class'UIAPI_EDITBOX'.static.SetString( "PostWriteWnd.ReceiverID", record.LVDataList[0].szData );
			break;

		case "AddList":
			AddList.GetSelectedRec( record );
			class'UIAPI_EDITBOX'.static.SetString( "PostWriteWnd.ReceiverID", record.LVDataList[0].szData );
			break;
	}
}

//레코드를 클릭하면....
function OnClickListCtrlRecord( string ListCtrlID )
{
	local LVDataRecord record;	

	switch(ListCtrlID)
	{
		case "AddList":
			bPostFriendSelect = true;
			Btn_Del.EnableWindow();
			AddList.GetSelectedRec( record );
			selectFriend = record.LVDataList[0].szData;			
			break;
	}
}


/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( m_WindowName ).HideWindow();
}

defaultproperties
{
    m_WindowName="PostReceiverListWnd"
}
