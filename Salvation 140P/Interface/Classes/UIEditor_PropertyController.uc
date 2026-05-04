class UIEditor_PropertyController extends UICommonAPI;

var WindowHandle Me;
var WindowHandle m_CurPropertyWnd;
var PropertyControllerHandle ctlProperty;
var WindowHandle areaScroll;

function OnRegisterEvent()
{
	RegisterEvent( EV_TrackerAttach );
	RegisterEvent( EV_TrackerDetach );
	RegisterEvent( EV_EditorUpdateProperty );
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
		Me = GetHandle( "UIEditor_PropertyController" );
		ctlProperty = PropertyControllerHandle( GetHandle( "UIEditor_PropertyController.ctlProperty" ) );
		areaScroll = GetHandle( "UIEditor_PropertyController.areaScroll" );
	}
	else
	{
		Me = GetWindowHandle( "UIEditor_PropertyController" );
		ctlProperty = GetPropertyControllerHandle( "UIEditor_PropertyController.ctlProperty" );
		areaScroll = GetWindowHandle( "UIEditor_PropertyController.areaScroll" );
	}
}

function InitControlItem()
{
	//Set Title
	Me.SetWindowTitle("UIEditor - PropertyManager");
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
	else if( Event_ID == EV_EditorUpdateProperty )
	{
		HandleEditorUpdateProperty( param );
	}
}

function OnPropertyControllerResize( PropertyControllerHandle a_PropertyHandle, int a_Height )
{
	if( areaScroll != None )
		areaScroll.SetScrollHeight( a_Height );
}

function Clear()
{
	m_CurPropertyWnd = None;
	ctlProperty.Clear();
	areaScroll.SetScrollPosition( 0 );
}

function HandleTrackerAttach( string param )
{
	local WindowHandle TrackerWnd;
	
	TrackerWnd = GetTrackerAttachedWindow();
	if( TrackerWnd==None )
		return;
	
	if( TrackerWnd!=m_CurPropertyWnd )
	{
		m_CurPropertyWnd = TrackerWnd;
		
		ctlProperty.SetProperty( TrackerWnd.GetControlType(), m_CurPropertyWnd );
		areaScroll.SetScrollHeight( ctlProperty.GetPropertyHeight() );
		areaScroll.SetScrollPosition( 0 );
	}
}

function HandleTrackerDetach()
{
	Clear();
}

function HandleEditorUpdateProperty( string param )
{
	local string ControlName;
	local int CloneID;
	local string GroupName;
	local WindowHandle hWnd;
	
	ParseString( param, "ControlName", ControlName );
	if( Len(ControlName) < 1 )
		return;
		
	ParseInt( param, "CloneID", CloneID );
	
	hWnd = FindHandle( ControlName, None, CloneID );
	if( hWnd != m_CurPropertyWnd )
		return;	
	
	ParseString( param, "GroupName", GroupName );
	ctlProperty.UpdatePropertyGroup( GroupName );
}
defaultproperties
{
}
