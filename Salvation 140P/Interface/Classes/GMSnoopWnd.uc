class GMSnoopWnd extends UICommonAPI;

const MAX_GMSnoop = 4;

var int m_SnoopIDList[ MAX_GMSnoop ];
var WindowHandle m_hSnoopWndList[ MAX_GMSnoop ];
var TextListBoxHandle m_hSnoopChatWndList[ MAX_GMSnoop ];
var ButtonHandle m_hCancelButtonList[ MAX_GMSnoop ];
var CheckBoxHandle m_hCheckBox[ 28 ];

function OnRegisterEvent()
{
	RegisterEvent( EV_GMSnoop );
}

function OnLoad()
{
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	if(CREATE_ON_DEMAND==0)
		InitHandle();
	else
		InitHandleCOD();

	ClearAllSnoop();
}

function InitHandle()
{
	local int i;
	local int j;

	for( i = 0; i < MAX_GMSnoop; ++i )
	{
		m_hSnoopWndList[ i ] = GetHandle( "SnoopWnd" $ i + 1 );
		m_hSnoopChatWndList[ i ] = TextListBoxHandle( GetHandle( "SnoopWnd" $ i + 1 $ ".Chat" ) );
		m_hCancelButtonList[ i ] = ButtonHandle( GetHandle( "GMSnoopWnd.SnoopWnd" $ i + 1 $ ".CancelButton" ) ); //branch (TTP #36694)

		for( j = 0; j < 7; ++j )
		{
			m_hCheckBox[ i*7+j ] = CheckBoxHandle( GetHandle( "SnoopWnd" $ i + 1 $ ".CheckBox" $ j ) );
		}
	}	
}

function InitHandleCOD()
{
	local int i;
	local int j;

	for( i = 0; i < MAX_GMSnoop; ++i )
	{
		m_hSnoopWndList[ i ] = GetWindowHandle( "SnoopWnd" $ i + 1 );
		m_hSnoopChatWndList[ i ] = GetTextListBoxHandle( "SnoopWnd" $ i + 1 $ ".Chat" );
		m_hCancelButtonList[ i ] = GetButtonHandle( "GMSnoopWnd.SnoopWnd" $ i + 1 $ ".CancelButton" ); //branch (TTP #36694)

		for( j = 0; j < 7; ++j )
		{
			m_hCheckBox[ i*7+j ] = GetCheckBoxHandle( "SnoopWnd" $ i + 1 $ ".CheckBox" $ j );
		}
	}	
}

function OnShow()
{
	local int i;

	for( i = 0; i < MAX_GMSnoop; ++i )
	{
		m_hSnoopWndList[ i ].HideWindow();
	}
}

function OnHide()
{
}

function OnClickButtonWithHandle( ButtonHandle a_ButtonHandle )
{
	local int i;

	for( i = 0; i < MAX_GMSnoop; ++i )
	{
		if( a_ButtonHandle == m_hCancelButtonList[ i ] )
		{
			class'GMAPI'.static.RequestSnoopEnd( m_SnoopIDList[ i ] );
			ClearSnoop( i );
		}
	}
}

function OnEvent( int a_EventID, String a_Param )
{
	switch( a_EventID )
	{
	case EV_GMSnoop:
		HandleGMSnoop( a_Param );
		break;
	}
}

function HandleGMSnoop( String a_Param )
{
	local int SnoopID;
	local String SnoopName;
	local int CreatureID;
	local int Type;
	local int SnoopIndex;
	local String CharacterName;
	local String ChatMessage;
	local WindowHandle hSnoopWnd;
	local TextListBoxHandle hSnoopChatWnd;

	ParseInt( a_Param, "SnoopID", SnoopID );
	ParseString( a_Param, "SnoopName", SnoopName );
	if( !GetSnoopWnd( SnoopID, hSnoopWnd, hSnoopChatWnd, SnoopIndex, SnoopName ) )
	{
		DialogShow(DialogModalType_Modalless, DialogType_OK, GetSystemMessage( 802 ), string(Self) );
		return;
	}

	ParseString( a_Param, "CharacterName", CharacterName );
	ParseInt( a_Param, "CreatureID", CreatureID );
	ParseInt( a_Param, "Type", Type );
	ParseString( a_Param, "ChatMessage", ChatMessage );

	if( !m_hOwnerWnd.IsShowWindow() )
		m_hOwnerWnd.ShowWindow();
	hSnoopWnd.ShowWindow();

	if( !IsFiltered( EChatType( Type ), SnoopIndex ) )
		hSnoopChatWnd.AddString( CharacterName $ ": " $ ChatMessage, GetChatColorByType( Type ) );
}

function ClearAllSnoop()
{
	local int i;

	for( i = 0; i < MAX_GMSnoop; ++i )
	{
		ClearSnoop( i );		
	}
}

function ClearSnoop( int a_SnoopIndex )
{
	local int i;
	local bool AllHidden;

	if( 0 > a_SnoopIndex )
		return;

	if( MAX_GMSnoop <= a_SnoopIndex )
		return;

	m_hSnoopChatWndList[ a_SnoopIndex ].Clear(); //branch
	m_SnoopIDList[ a_SnoopIndex ] = -1;
	m_hSnoopWndList[ a_SnoopIndex ].HideWindow();

	AllHidden = true;

	for( i = 0; i < MAX_GMSnoop; ++i )
	{
		if( -1 != m_SnoopIDList[ i ] )
		{
			AllHidden = false;
			break;
		}
	}

	if( AllHidden )
		m_hOwnerWnd.HideWindow();
}

function bool GetSnoopWnd( int a_SnoopID, out WindowHandle a_hSnoopWnd, out TextListBoxHandle a_hSnoopChatWnd, out int a_SnoopIndex, String a_CharacterName )
{
	local int SnoopIndex;

	SnoopIndex = GetSnoopIndexByID( a_SnoopID );
	if( -1 != SnoopIndex )
	{
		a_hSnoopWnd = m_hSnoopWndList[ SnoopIndex ];
		a_hSnoopChatWnd = m_hSnoopChatWndList[ SnoopIndex ];
		a_SnoopIndex = SnoopIndex;
		return true;
	}

	SnoopIndex = GetSnoopIndexByID( -1 );
	if( -1 != SnoopIndex )
	{
		m_SnoopIDList[ SnoopIndex ] = a_SnoopID;
		a_hSnoopWnd = m_hSnoopWndList[ SnoopIndex ];
		a_hSnoopChatWnd = m_hSnoopChatWndList[ SnoopIndex ];
		a_SnoopIndex = SnoopIndex;
		a_hSnoopWnd.SetWindowTitle( GetSystemString( 693 ) $ " - " $ a_CharacterName );
		return true;
	}

	return false;
}

function int GetSnoopIndexByID( int a_SnoopID )
{
	local int i;

	for( i = 0; i < MAX_GMSnoop; ++i )
	{
		if( a_SnoopID == m_SnoopIDList[ i ] )
			return i;
	}

	return -1;
}

function bool IsFiltered( EChatType a_Type, int a_SnoopIndex )
{
	switch( a_Type )
	{
	case CHAT_MARKET:
		if( m_hCheckBox[a_SnoopIndex*7].IsChecked() )
			return false;
		break;
	case CHAT_CLAN:
		if( m_hCheckBox[a_SnoopIndex*7+1].IsChecked() )
			return false;
		break;
	case CHAT_PARTY:
		if( m_hCheckBox[a_SnoopIndex*7+2].IsChecked() )
			return false;
		break;
	case CHAT_SHOUT:
		if( m_hCheckBox[a_SnoopIndex*7+3].IsChecked() )
			return false;
		break;	
	case CHAT_TELL:
		if( m_hCheckBox[a_SnoopIndex*7+4].IsChecked() )
			return false;
		break;
	case CHAT_NORMAL:
		if( m_hCheckBox[a_SnoopIndex*7+5].IsChecked() )
			return false;
		break;
	case CHAT_ALLIANCE:
		if( m_hCheckBox[a_SnoopIndex*7+6].IsChecked() )
			return false;
		break;	
	}

	return true;
}
defaultproperties
{
}
