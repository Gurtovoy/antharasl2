class UIEditor_Worksheet extends UICommonAPI;

//"Del" Key
function OnKeyUp( WindowHandle a_WindowHandle, EInputKey nKey )
{
	if( nKey == IK_Delete )
	{
		DeleteWindow();
	}
	else if( nKey == IK_Escape )
	{
		ClearAllTracker();
	}
}

//ReleaseTracker
function ClearAllTracker()
{
	ClearTracker();
}

//Delete Control
function DeleteWindow()
{
	DeleteAttachedWindow();
}

function OnDropWnd( WindowHandle hTarget, WindowHandle hDropWnd, int x, int y )
{
	local UIEditor_ControlManager Script;

	local WindowHandle ContainerHandle;
	local WindowHandle ParentHandle;
	
	if( hTarget == None || hDropWnd == None )
		return;
		
	ContainerHandle = hTarget;
		
	//Find Container
	if( !ContainerHandle.IsControlContainer() )
	{
		ParentHandle = ContainerHandle.GetParentWindowHandle();
		while( ParentHandle != None )
		{
			if( ParentHandle.IsControlContainer() )
				break;
			ParentHandle = ParentHandle.GetParentWindowHandle();
		}
		ContainerHandle = ParentHandle;
	}
	if( ContainerHandle==None )
	{
		DialogShow(DialogModalType_Modalless, DialogType_OK, "Can't Move Control to " $ hTarget.GetWindowName() $ ".", string(Self) );
		return;
	}
	
	//Change Parent
	if( hDropWnd.ChangeParentWindow( ContainerHandle ) )
	{
		//Refresh Control List
		Script = UIEditor_ControlManager( GetScript( "UIEditor_ControlManager" ) );
		if( Script!=None )
			Script.RefreshControlList();	
	}	
}

function OnDropItemWithHandle( WindowHandle hTarget, ItemInfo info, int x, int y )
{
	local UIEditor_ControlManager Script;
	
	local String strTarget;
	local WindowHandle TargetWndHandle;
	local WindowHandle ParentHandle;
	local WindowHandle NewWnd;
	
	local EXMLControlType Type;
	
	//Check Target Window
	TargetWndHandle = hTarget;
	if( TargetWndHandle==None )
		return;
		
	strTarget = TargetWndHandle.GetWindowName();
		
	//Find Container
	if( !TargetWndHandle.IsControlContainer() )
	{
		ParentHandle = TargetWndHandle.GetParentWindowHandle();
		while( ParentHandle != None )
		{
			if( ParentHandle.IsControlContainer() )
				break;
			ParentHandle = ParentHandle.GetParentWindowHandle();
		}
		TargetWndHandle = ParentHandle;
	}
	if( TargetWndHandle==None )
	{
		DialogShow(DialogModalType_Modalless, DialogType_OK, "Can't Drop Control to " $ strTarget $ ".", string(Self) );
		return;
	}
	
	//Get Child Type	
	Script = UIEditor_ControlManager( GetScript( "UIEditor_ControlManager" ) );
	if( Script==None )
		return;
	Type = Script.GetCurrentControlType();
	
	if( strTarget == "Worksheet" )
	{
		if( Type != XCT_FrameWnd && Type != XCT_ScrollWnd )
		{
			DialogShow(DialogModalType_Modalless, DialogType_OK, "Please Drop Container Control First! (Window, ScrollArea..)", string(Self));
			return;
		}
	}
	
	//Update ControlList
	Script.UpdateControlList();
	
	//Create New Control
	NewWnd = TargetWndHandle.AddChildWnd( Type );
	
	if( NewWnd!=None )
		SetDefaultValue( NewWnd, Type, strTarget, x, y );
}

//각종 컨트롤의 디폴트 값을 셋팅해준다.
function SetDefaultValue( WindowHandle NewWnd, EXMLControlType Type, string strTarget, int X, int Y )
{
	local int DefaultWidth;
	local int DefaultHeight;
	
	local ButtonHandle	hButton;
	local TextBoxHandle hTextBox;
	local TextureHandle hTexture;
	local BarHandle		hBar;
	
	DefaultWidth = 50;
	DefaultHeight = 50;
	
	NewWnd.SetEditable( true );
	
	switch( Type )
	{
	case XCT_FrameWnd:
		//Is Worksheet?
		if( strTarget == "Worksheet" )
		{
			DefaultWidth = 256;
			DefaultHeight = 256;
			NewWnd.SetBackTexture( "Default.BlackTexture" );
			NewWnd.SetXMLDocumentInfo( "Created By L2UIEditor Ver1.0", 
										"http://www.lineage2.co.kr/ui", 
										"http://www.w3.org/2001/XMLSchema-instance", 
										"http://www.lineage2.co.kr/ui ..\\..\\Schema.xsd" );
		}
		else
		{
			DefaultWidth = 50;
			DefaultHeight = 50;
		}
	break;
	case XCT_Button:
		DefaultWidth = 76;
		DefaultHeight = 23;
		hButton = ButtonHandle( NewWnd );
		hButton.SetTexture( "L2UI_CH3.Button.Btn1_Normal", "L2UI_CH3.Button.Btn1_NormalOn", "L2UI_CH3.Button.Btn1_Normal_Over" );
	break;
	case XCT_TextBox:
		DefaultWidth = 100;
		DefaultHeight = 12;
		hTextBox = TextBoxHandle( NewWnd );
		hTextBox.SetText( hTextBox.GetWindowName() );
	break;
	case XCT_EditBox:
		DefaultWidth = 50;
		DefaultHeight = 17;
	break;
	case XCT_TextureCtrl:
		hTexture = TextureHandle( NewWnd );
		hTexture.SetTexture( "Default.WhiteTexture" );
	break;
	case XCT_ChatListBox:
	break;
	case XCT_TabControl:
	break;
	case XCT_ItemWnd:
	break;
	case XCT_CheckBox:
		DefaultWidth = 80;
		DefaultHeight = 12;
	break;
	case XCT_ComboBox:
		DefaultWidth = 50;
		DefaultHeight = 19;
	break;
	case XCT_ProgressCtrl:
	break;
	case XCT_MultiEdit:
		DefaultWidth = 50;
		DefaultHeight = 50;
	break;
	case XCT_ListCtrl:
	break;
	case XCT_ListBox:
	break;
	case XCT_StatusBarCtrl:
		DefaultWidth = 50;
		DefaultHeight = 12;
	break;
	case XCT_NameCtrl:
		DefaultWidth = 50;
		DefaultHeight = 12;
	break;
	case XCT_MinimapWnd:
	break;
	case XCT_ShortcutItemWnd:
	break;
	case XCT_XMLTreeCtrl:
	break;
	case XCT_SliderCtrl:
	break;
	case XCT_EffectButton:
	break;
	case XCT_TextListBox:
	break;
	case XCT_RadarWnd:
	break;
	case XCT_HtmlViewer:
	break;
	case XCT_RadioButton:
		DefaultWidth = 80;
		DefaultHeight = 12;
	break;
	case XCT_InvenWeightWnd:
	break;
	case XCT_StatusIconCtrl:
	break;
	case XCT_BarCtrl:
		DefaultWidth = 50;
		DefaultHeight = 6;
		hBar = BarHandle ( NewWnd );
		hBar.SetValue( 100, 25 );
	break;
	case XCT_ScrollWnd:
	break;
	case XCT_FishViewportWnd:
	break;
	case XCT_VIPShopItemInfoWnd:
	break;
	case XCT_VIPShopNeededItemWnd:
	break;
	case XCT_DrawPanel:
	break;
	}
	
	NewWnd.SetWindowSize( DefaultWidth, DefaultHeight );
	NewWnd.SetFocus();
}
defaultproperties
{
}
