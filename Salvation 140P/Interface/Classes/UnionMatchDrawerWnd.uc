class UnionMatchDrawerWnd extends UICommonAPI;

var WindowHandle Me;
var TextBoxHandle txtTitle1;
var TextBoxHandle txtTitle2;
var ButtonHandle btnPrev;
var ButtonHandle btnNext;
var ButtonHandle btnWhisper;
var ButtonHandle btnRefresh;
var ListCtrlHandle lstParty;
var TextureHandle txListTitleBg;
var TextureHandle txListBg;
var TextureHandle txLine;
var ButtonHandle btnClose;

function OnRegisterEvent()
{
	RegisterEvent( EV_MpccPartyMasterList );
}

function OnLoad()
{
	Initialize();
	Load();
}

function Initialize()
{
	Me = GetWindowHandle( "UnionMatchDrawerWnd" );
	txtTitle1 = GetTextBoxHandle( "UnionMatchDrawerWnd.txtTitle1" );
	txtTitle2 = GetTextBoxHandle( "UnionMatchDrawerWnd.txtTitle2" );
	btnPrev = GetButtonHandle( "UnionMatchDrawerWnd.btnPrev" );
	btnNext = GetButtonHandle( "UnionMatchDrawerWnd.btnNext" );
	btnWhisper = GetButtonHandle( "UnionMatchDrawerWnd.btnWhisper" );
	btnRefresh = GetButtonHandle( "UnionMatchDrawerWnd.btnRefresh" );
	lstParty = GetListCtrlHandle( "UnionMatchDrawerWnd.lstParty" );
	txListTitleBg = GetTextureHandle( "UnionMatchDrawerWnd.txListTitleBg" );
	txListBg = GetTextureHandle( "UnionMatchDrawerWnd.txListBg" );
	txLine = GetTextureHandle( "UnionMatchDrawerWnd.txLine" );
	btnClose = GetButtonHandle( "UnionMatchDrawerWnd.btnClose" );
}

function Load()
{
	//페이징 기능은 추후 추가
	btnPrev.DisableWindow();
	btnNext.DisableWindow();
}

function OnEvent( int a_EventID, String param )
{
	switch( a_EventID )
	{
	case EV_MpccPartyMasterList:
		HandleMpccPartyMasterList( param );
		break;
	}
}

function HandleMpccPartyMasterList( String param )
{
	local int PartyMasterCnt;
	local int idx;
	local String Name;
	local LVDataRecord Record;
	
	lstParty.DeleteAllItem();
	
	ParseInt( param, "PartyMasterCnt", PartyMasterCnt );
	
	Record.LVDataList.length = 1;
	for( idx=1; idx<=PartyMasterCnt; idx++ )
	{
		ParseString( param, "Name" $ idx, Name );	
		Record.LVDataList[0].szData = Name;
		lstParty.InsertRecord( Record );
	}
}

function OnClickButton( string Name )
{
	switch( Name )
	{
	case "btnWhisper":
		OnbtnWhisperClick();
		break;
	case "btnRefresh":
		OnbtnRefreshClick();
		break;
	case "btnClose":
		OnbtnCloseClick();
		break;
	}
}

//[귓속말]
function OnbtnWhisperClick()
{
	local int idx;
	local LVDataRecord Record;
	local string Name;
	local EditBoxHandle ChatEditBox;
	
	idx = lstParty.GetSelectedIndex();
	if( idx < 0 )
		return;
	
	lstParty.GetRec( idx, Record );
	
	Name = Record.LVDataList[0].szData;
	if( Name != "" )
	{
		SetChatMessage( "\"" $ Name $ " " );
		ChatEditBox = GetEditBoxHandle("ChatWnd.ChatEditBox" );
		if( ChatEditBox != None )
			ChatEditBox.SetFocus();
	}
}

//[목록갱신]
function OnbtnRefreshClick()
{
	class'PartyMatchAPI'.static.RequestMpccPartymasterList();
}

function OnbtnCloseClick()
{
	Me.HideWindow();
}
defaultproperties
{
}
