class UIEditor_DocumentInfo extends UICommonAPI;

var WindowHandle	Me;

var EditBoxHandle	txtCommentInput;
var String	m_xmlnsInput;
var String	m_xsiInput;
var String	m_schemaLocationInput;

var WindowHandle	m_CurTopWnd;

function OnRegisterEvent()
{
	RegisterEvent( EV_TrackerAttach );
	RegisterEvent( EV_TrackerDetach );
}

function OnLoad()
{
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	//Init Handle
	InitHandle();
	
	//Init Control Item
	InitControlItem();
}

function InitHandle()
{
	if(CREATE_ON_DEMAND==0)
	{
		Me = GetHandle( "UIEditor_DocumentInfo" );
		txtCommentInput = EditBoxHandle( GetHandle( "UIEditor_DocumentInfo.txtCommentInput" ) );
	}
	else
	{
		Me = GetWindowHandle( "UIEditor_DocumentInfo" );
		txtCommentInput = GetEditBoxHandle( "UIEditor_DocumentInfo.txtCommentInput" );
	}
}

function InitControlItem()
{
	//Set Title
	Me.SetWindowTitle("UIEditor - DocumentInfo");
}

function OnEvent(int Event_ID, string param)
{
	if( Event_ID == EV_TrackerAttach )
	{
		HandleTrackerAttach( param );
	}
	else if( Event_ID == EV_TrackerDetach )
	{
		HandleTrackerDetach();
	}
}

function OnCompleteEditBox( String strID )
{
	switch( strID )
	{
	case "txtCommentInput":
		UpdateDocumentInfo();
	break;
	}
}

function HandleTrackerAttach( string param )
{
	local WindowHandle TrackerWnd;
	local WindowHandle TopWnd;
	
	local string Comment;
	local string NameSpace;
	local string XSI;
	local string SchemaLocation;
	
	TrackerWnd = GetTrackerAttachedWindow();
	if( TrackerWnd==None )
		return;
	
	Clear();
	
	TopWnd = TrackerWnd.GetTopFrameWnd();
	if( TopWnd == None )
		return;
		
	if( TopWnd==m_CurTopWnd )
		return;
		
	m_CurTopWnd = TopWnd;
	
	TopWnd.GetXMLDocumentInfo( Comment, NameSpace, XSI, SchemaLocation );
	txtCommentInput.AddString( Comment );
	m_xmlnsInput = NameSpace;
	m_xsiInput = XSI;
	m_schemaLocationInput = SchemaLocation;
}

function UpdateDocumentInfo()
{
	m_CurTopWnd.SetXMLDocumentInfo( txtCommentInput.GetString(), m_xmlnsInput, m_xsiInput, m_schemaLocationInput );
}

function HandleTrackerDetach()
{
	Clear();
}

function Clear()
{
	m_CurTopWnd = None;
	txtCommentInput.Clear();
	m_xmlnsInput = "";
	m_xsiInput = "";
	m_schemaLocationInput = "";
}
defaultproperties
{
}
