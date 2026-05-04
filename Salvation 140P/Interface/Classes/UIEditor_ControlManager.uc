class UIEditor_ControlManager extends UICommonAPI;

const XML_PATH = "..\\Interface\\Default";

var WindowHandle	Me;

var TextBoxHandle	 txtNewControl;
var ListBoxHandle	 lstControls;
var ItemWindowHandle ControlItem;

var TextBoxHandle	txtControlAlign;
var CheckBoxHandle	chkShowWindowBox;
var CheckBoxHandle	chkVirtualBack;
var CheckBoxHandle	chkExampleAni;
var ButtonHandle	btnLeft;
var ButtonHandle	btnCenter;
var ButtonHandle	btnRight;
var ButtonHandle	btnWidth;
var ButtonHandle	btnHeight;
//var ButtonHandle	btnTop;
var ButtonHandle	btnUp;
var ButtonHandle	btnDown;
//var ButtonHandle	btnBottom;

var ListCtrlHandle	lstCurrentControl;

var WindowHandle	m_CurTopWnd;

function OnRegisterEvent()
{
	RegisterEvent( EV_TrackerAttach );
	RegisterEvent( EV_TrackerDetach );
	RegisterEvent( EV_EditorSetProperty );
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
		Me = GetHandle( "UIEditor_ControlManager" );
		
		ControlItem = ItemWindowHandle( GetHandle( "UIEditor_ControlManager.NewControlItem" ) );
		lstControls = ListBoxHandle( GetHandle( "UIEditor_ControlManager.lstControls" ) );
		
		txtControlAlign = TextBoxHandle( GetHandle( "UIEditor_ControlManager.txtControlAlign" ) );
		chkShowWindowBox = CheckBoxHandle( GetHandle( "UIEditor_ControlManager.chkShowWindowBox" ) );
		chkVirtualBack = CheckBoxHandle( GetHandle( "UIEditor_ControlManager.chkVirtualBack" ) );
		chkExampleAni = CheckBoxHandle( GetHandle( "UIEditor_ControlManager.chkExampleAni" ) );
		btnLeft = ButtonHandle( GetHandle( "UIEditor_ControlManager.btnLeft" ) );
		btnCenter = ButtonHandle( GetHandle( "UIEditor_ControlManager.btnCenter" ) );
		btnRight = ButtonHandle( GetHandle( "UIEditor_ControlManager.btnRight" ) );
		btnWidth = ButtonHandle( GetHandle( "UIEditor_ControlManager.btnWidth" ) );
		btnHeight = ButtonHandle( GetHandle( "UIEditor_ControlManager.btnHeight" ) );
	//	btnTop = ButtonHandle ( GetHandle( "UIEditor_ControlManager.btnTop" ) );
		btnUp = ButtonHandle ( GetHandle( "UIEditor_ControlManager.btnUp" ) );
		btnDown = ButtonHandle ( GetHandle( "UIEditor_ControlManager.btnDown" ) );
	//	btnBottom = ButtonHandle ( GetHandle( "UIEditor_ControlManager.btnBottom" ) );
		
		lstCurrentControl = ListCtrlHandle( GetHandle( "UIEditor_ControlManager.lstCurrentControl" ) );
	}
	else
	{
		Me = GetWindowHandle( "UIEditor_ControlManager" );
		
		ControlItem = GetItemWindowHandle( "UIEditor_ControlManager.NewControlItem" );
		lstControls = GetListBoxHandle( "UIEditor_ControlManager.lstControls" );
		
		txtControlAlign = GetTextBoxHandle( "UIEditor_ControlManager.txtControlAlign" );
		chkShowWindowBox = GetCheckBoxHandle( "UIEditor_ControlManager.chkShowWindowBox" );
		chkVirtualBack = GetCheckBoxHandle( "UIEditor_ControlManager.chkVirtualBack" );
		chkExampleAni = GetCheckBoxHandle( "UIEditor_ControlManager.chkExampleAni" );
		btnLeft = GetButtonHandle( "UIEditor_ControlManager.btnLeft" );
		btnCenter = GetButtonHandle( "UIEditor_ControlManager.btnCenter" );
		btnRight = GetButtonHandle( "UIEditor_ControlManager.btnRight" );
		btnWidth = GetButtonHandle( "UIEditor_ControlManager.btnWidth" );
		btnHeight = GetButtonHandle( "UIEditor_ControlManager.btnHeight" );

		btnUp = GetButtonHandle( "UIEditor_ControlManager.btnUp" );
		btnDown = GetButtonHandle( "UIEditor_ControlManager.btnDown" );
		
		lstCurrentControl = GetListCtrlHandle( "UIEditor_ControlManager.lstCurrentControl" );
	}
}

function InitControlItem()
{
	local ItemInfo	infItem;
	
	//Set Title
	Me.SetWindowTitle("UIEditor - ControlManager");
	
	//New Control Item
	infItem.Name = "NewControl";
	infItem.IconName = "L2UI_CH3.MenuIcon.menuButton4";
	ControlItem.AddItem(infItem);
	
	//Control Align Title
	txtControlAlign.SetText("Control Align");
	
	//Init Control List
	InitNewControlList();
}

function InitNewControlList()
{
	local int i;
	local string strName;
	
	lstControls.Clear();
	
	for( i=1; i<100; i++ )
	{
		strName = GetXMLControlString(EXMLControlType(i));
		if( Len(strName)>0 )
			lstControls.AddString(strName);
		else
			break;
	}
}

function OnEvent(int Event_ID, string param)
{
	if( Event_ID == EV_TrackerAttach )
	{
		HandleTrackerAttach();
	}
	else if( Event_ID == EV_TrackerDetach )
	{
		HandleTrackerDetach();
	}
	else if( Event_ID == EV_EditorSetProperty )
	{
		HandleEditorSetProperty( param );
	}
}

function OnClickButton( string Name )
{
	switch( Name )
	{
	case "btnLeft":
	case "btnCenter":
	case "btnRight":
	case "btnWidth":
	case "btnHeight":
		OnAlignClick( Name );
		break;
//	case "btnTop":
	case "btnUp":
	case "btnDown":
//	case "btnBottom":
		OnOrderClick( Name );
		break;
	}
}

function OnClickCheckBox( string Name )
{
	switch( Name )
	{
	case "chkShowWindowBox":
		ShowEnableTrackerBox( chkShowWindowBox.IsChecked() );
		break;
	case "chkVirtualBack":
		ShowVirtualWindowBackground( chkVirtualBack.IsChecked() );
		break;
	case "chkExampleAni":
		ShowExampleAnimation( chkExampleAni.IsChecked() );
		break;
	}
}

function EXMLControlType GetCurrentControlType()
{
	return GetXMLControlIndex(GetCurrentControlTypeString());
}

function string GetCurrentControlTypeString()
{
	return lstControls.GetSelectedString();
}

function OnAlignClick( string Name )
{
	switch( Name )
	{
	case "btnLeft":
		ExecuteAlign( TAT_Left );
		break;
	case "btnCenter":
		ExecuteAlign( TAT_Center );
		break;
	case "btnRight":
		ExecuteAlign( TAT_Right );
		break;
	case "btnWidth":
		ExecuteAlign( TAT_Width );
		break;
	case "btnHeight":
		ExecuteAlign( TAT_Height );
		break;
	}	
}

function OnClickListCtrlRecord( String strID )
{
	local int Idx;
	local LVDataRecord record;
	
	if( strID != "lstCurrentControl" )
		return;
		
	Idx = lstCurrentControl.GetSelectedIndex();
	if( Idx < 0 )
		return;
		
	lstCurrentControl.GetRec( Idx, record );
	SelectControl( record.szReserved );
}

//Control Visible
function OnDBClickListCtrlRecord( String strID )
{
	local int Idx;
	local LVDataRecord record;
	local WindowHandle hWnd;
	
	if( strID != "lstCurrentControl" )
		return;
		
	Idx = lstCurrentControl.GetSelectedIndex();
	if( Idx < 0 )
		return;
		
	lstCurrentControl.GetRec( Idx, record );
	if( record.nReserved1 < 1 )
		return;
		
	hWnd = FindWindowHandle( record.szReserved );
	if( record.LVDataList[0].szTexture != "" )
	{
		record.LVDataList[0].nTextureWidth = 0;
		record.LVDataList[0].nTextureHeight = 0;
		record.LVDataList[0].szTexture = "";
		hWnd.EnterState();
		
	}
	else
	{
		record.LVDataList[0].nTextureWidth = 12;
		record.LVDataList[0].nTextureHeight = 12;
		record.LVDataList[0].szTexture = "L2UI_CH3.RadioCtrl.RadioButton1";
		hWnd.ExitState();
	}
	
	lstCurrentControl.ModifyRecord( Idx, record );
}

function UpdateControlList()
{
	m_CurTopWnd = None;
}

function RefreshControlList()
{
	UpdateControlList();
	HandleTrackerAttach();
}

function HandleTrackerAttach()
{
	local WindowHandle TrackerWnd;
	local WindowHandle TopWnd;
	
	TrackerWnd = GetTrackerAttachedWindow();
	if( TrackerWnd==None )
		return;
	
	TopWnd = TrackerWnd.GetTopFrameWnd();
	if( TopWnd == None )
		return;
		
	if( m_CurTopWnd != TopWnd )
	{
		m_CurTopWnd = TopWnd;
		lstCurrentControl.DeleteAllItem();		
		AddChildWIndowToList( TopWnd, "", 0 );
	}
	SelectControlList( GetFullName( TrackerWnd ) );
}

function HandleTrackerDetach()
{
	m_CurTopWnd = None;
	lstCurrentControl.DeleteAllItem();
}

function HandleEditorSetProperty( string Param )
{
	local string PropertyName;
	local int Count;
	local array<string> NameList;
	
	ParseString( Param, "PropertyName", PropertyName );
	
	if( Len(PropertyName) < 1 )
		return;
		
	Count = Split( PropertyName, ".", NameList );
	if( Count < 2 )
		return;
		
	if( NameList[Count-1] == "name" && NameList[Count-2] == "DefaultProperty" )
	{
		UpdateControlList();
		HandleTrackerAttach();
	}
}

function AddChildWIndowToList( WindowHandle hWnd, string ParentName, int Depth )
{
	local int Idx;
	local EXMLControlType Type;
	local string Name;
	local string FullName;
	local Array<WindowHandle> ChildList;
	local LVDataRecord record;
	local int ChildDepth;
	local string ChildHead;
	
	if( hWnd == None )
		return;
	
	Type = hWnd.GetControlType();
	if( Type == XCT_None )
		return;
		
	if( !hWnd.IsShowWindow() )
		return;
		
	//Make Name
	Name = hWnd.GetWindowName();
	if( Len(Name) < 1 )
		return;
	FullName = Name;
	if( Len(ParentName ) > 0 )
		FullName = ParentName $ "." $ Name;
	
	if( Depth > 0 )
	{
		for( idx=0; idx<Depth; idx++ )
		{
			if( idx == Depth - 1 )
				ChildHead = ChildHead $ "¦¦";
			else
				ChildHead = ChildHead $ " ";
		}
	}
		
	record.LVDataList.length = 4;
	record.szReserved = FullName;
	record.nReserved1 = Depth;
	record.LVDataList[1].szData = ChildHead $ Name;
	record.LVDataList[2].szData = GetXMLControlString( Type );
	record.LVDataList[3].szData = ReverseParentName( ParentName );
	lstCurrentControl.InsertRecord( record );
		
	if( !hWnd.IsControlContainer() )
		return;
		
	//Process Child Control
	hWnd.GetChildWindowList( ChildList );
	ChildDepth = Depth + 1;
	for( idx=0; idx<ChildList.Length; idx++ )
		AddChildWIndowToList( ChildList[idx], FullName, ChildDepth );
}

function SelectControl( string ControlName )
{
	local WindowHandle hWnd;
	
	if( Len(ControlName) < 1 )
		return;
	
	hWnd = FindWindowHandle( ControlName );
	if( hWnd != None )
		hWnd.SetFocus();
}

function string ReverseParentName( string Name )
{
	local int Idx;
	local int Count;
	local string NewName;
	local array<String> NameList;
	
	if( Len(Name) < 1 )
		return "";
	
	Count = Split( Name, ".", NameList );
	for( Idx=Count-1; Idx>=0; Idx-- )
	{
		if( Len(NewName) > 0 )
			NewName = NewName $ ".";
		NewName = NewName $ NameList[Idx];
	}
	
	return NewName;
}

function WindowHandle FindWindowHandle( string a_FullName )
{
	local int Idx;
	local int Count;
	local string NewName;
	local array<String> NameList;
	local WindowHandle ParentHandle;
	local WindowHandle FindedHandle;
	
	NewName = a_FullName;
	
	Count = Split( a_FullName, ".", NameList );
	if( Count > 1 )
	{
		NewName = "";
		for( Idx=1; Idx<Count; Idx++ )
		{
			if( Len(NewName) > 0 )
				NewName = NewName $ ".";
			NewName = NewName $ NameList[Idx];
		}
		ParentHandle = m_CurTopWnd;
		
		FindedHandle = FindHandle( NewName, ParentHandle );
	}
	else
		FindedHandle = m_CurTopWnd;
	
	return FindedHandle;
}

function SelectControlList( string FullName )
{
	local int Idx;
	local LVDataRecord record;
	
	if( Len(FullName) < 1 )
		return;
		
	for( Idx=0; idx<lstCurrentControl.GetRecordCount(); idx++ )
	{
		lstCurrentControl.GetRec( Idx, record );
		if( record.szReserved == FullName )
		{
			lstCurrentControl.SetSelectedIndex( Idx, true );
			break;
		}
	}
}

function String GetFullName( WindowHandle hWnd )
{
	local EXMLControlType Type;
	local string FullName;
	local string ParentName;
	local WindowHandle hParent;
	
	if( hWnd == None )
		return FullName;
	
	FullName = hWnd.GetWindowName();
	
	hParent = hWnd.GetParentWindowHandle();
	while( hParent != None )
	{
		ParentName = hParent.GetWindowName();
		if( ParentName == "Console" || ParentName == "Worksheet" )
			return FullName;
		Type = hParent.GetControlType();
		if( ( Type != XCT_None ) && ( Len(ParentName) > 0 ) )
			FullName = ParentName $ "." $ FullName;
		hParent = hParent.GetParentWindowHandle();	
	}
	return FullName;
}

function OnOrderClick( String Name )
{
	local WindowHandle TrackerWnd;
	
	TrackerWnd = GetTrackerAttachedWindow();
	if( TrackerWnd==None )
		return;
		
	switch( Name )
	{
	case "btnUp":
		TrackerWnd.ChangeControlOrder( COW_Up );
		break;
	case "btnDown":
		TrackerWnd.ChangeControlOrder( COW_Down );
		break;
	}
	
	RefreshControlList();
}
defaultproperties
{
}
