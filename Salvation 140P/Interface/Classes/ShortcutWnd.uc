class ShortcutWnd extends UICommonAPI;

const MAX_Page = 20; //branch EP3.0 2016.7.27 luciper3 - 일본 요청으로 페이지 10 -> 20 으로 변경
const MAX_ShortcutPerPage = 12;
const MAX_ShortcutPerPage2 = 24;
const MAX_ShortcutPerPage3 = 36;
const MAX_ShortcutPerPage4 = 48;
enum EJoyShortcut
{
	JOYSHORTCUT_Left,
	JOYSHORTCUT_Center,
	JOYSHORTCUT_Right,
};
var WindowHandle Me;
var int CurrentShortcutPage;
var int CurrentShortcutPage2;
var int CurrentShortcutPage3;
var bool m_IsLocked;
var bool m_IsVertical;
var bool m_IsJoypad;
var bool m_IsJoypadExpand;
var bool m_IsJoypadOn;
//var bool m_IsExpand1;
//var bool m_IsExpand2;
//수정(10.02.25)
var int CurrentShortcutPage4;
var int CurrentShortcutPage5;
//var bool m_IsExpand3;

var int m_Expand;

var bool m_IsShortcutExpand;
var String m_ShortcutWndName;

var AutoShotItemWnd AutoShotItemWndScript;

function OnRegisterEvent()
{
	RegisterEvent( EV_ShortcutUpdate );
	RegisterEvent( EV_ShortcutPageUpdate );
	RegisterEvent( EV_ShortcutJoypad );
	RegisterEvent( EV_ShortcutClear );
	RegisterEvent( EV_JoypadLButtonDown );
	RegisterEvent( EV_JoypadLButtonUp );
	RegisterEvent( EV_JoypadRButtonDown );
	RegisterEvent( EV_JoypadRButtonUp );
	RegisterEvent( EV_ShortcutCommandSlot );

	RegisterEvent( EV_ShortcutkeyassignChanged );
	
	RegisterEvent( EV_SetEnterChatting );
	RegisterEvent( EV_UnSetEnterChatting );
	RegisterEvent(EV_Restart);
}

function onShow ( ) 
{
	LoadINIValues();	

	if ( m_IsLocked ) Lock(); else UnLock();

	class'UIAPI_WINDOW'.static.HideWindow("ShortcutWnd.ShortcutWndVertical_1");	
	class'UIAPI_WINDOW'.static.HideWindow("ShortcutWnd.ShortcutWndHorizontal_1");
	class'UIAPI_WINDOW'.static.HideWindow("ShortcutWnd.ShortcutWndVertical_2");
	class'UIAPI_WINDOW'.static.HideWindow("ShortcutWnd.ShortcutWndHorizontal_2");	
	class'UIAPI_WINDOW'.static.HideWindow("ShortcutWnd.ShortcutWndVertical_3");
	class'UIAPI_WINDOW'.static.HideWindow("ShortcutWnd.ShortcutWndHorizontal_3");

	class'UIAPI_WINDOW'.static.HideWindow("ShortcutWnd.ShortcutWndVertical_4");
	class'UIAPI_WINDOW'.static.HideWindow("ShortcutWnd.ShortcutWndHorizontal_4");


	ExpandByNum( m_Expand );
	SetVertical( m_IsVertical );
}

function LoadINIValues() 
{
	local Int tmpInt;
	GetINIInt ( "ShortcutWnd", "e",  m_Expand, "WindowsInfo.ini");	
	GetInIBool ( "ShortcutWnd", "l", tmpInt, "windowsInfo.ini");
	m_IsLocked = GetOptionBool( "Game", "IsLockShortcutWnd" );
	if ( bool( tmpInt ) )
	{
		OnMaxBtn();
	}
	else 
	{
		OnMinBtn();
	}

	
/*
	GetINIInt ( "ShortcutWnd", "l",  tmpInt, "WindowsInfo.ini");
	m_IsLocked = bool ( tmpInt );
*/
	
	GetINIInt ( "ShortcutWnd", "v",  tmpInt, "WindowsInfo.ini");
	m_IsVertical = bool ( tmpInt );
}

function OnLoad()
{
	local bool bMinTooltip;
	local Tooltip Script;
	local int minTooltip;
	
	if ( getInstanceUIData().getIsArenaServer() ) return;

	Me = GetWindowHandle( "ShortcutWnd" );

	// 자동 정탄
	AutoShotItemWndScript = AutoShotItemWnd(GetScript("AutoShotItemWnd"));	
	
	//Load Ini	
	LoadINIValues();

	/*
	m_IsLocked = GetOptionBool( "Game", "IsLockShortcutWnd" );
	m_IsExpand1 = GetOptionBool( "Game", "Is1ExpandShortcutWnd" );
	m_IsExpand2 = GetOptionBool( "Game", "Is2ExpandShortcutWnd" );
	m_IsExpand3 = GetOptionBool( "Game", "Is3ExpandShortcutWnd" );
	m_IsVertical = GetOptionBool( "Game", "IsShortcutWndVertical" );*/
	//수정(10.02.25)
	
	InitShortPageNum();

	// 숏컷 툴팁 켜기/끄기 기본값을 켜기로(TTP#41925) 2010.8.23 - winkey
	// Option.ini의 설정을 이용한다(TTP#46732) 2011.4.21 - winkey

	//bMinTooltip = GetOptionBool( "Game", "IsShortcutWndMinTooltip" );
	GetInIBool ( "ShortcutWnd", "l", minTooltip, "windowsInfo.ini");
	bMinTooltip = bool ( minTooltip );	
	Script = Tooltip( GetScript( "Tooltip" ) );
	Script.setBoolSelect( !bMinTooltip );
	
	if( bMinTooltip )
	{
		HideWindow( "ShortcutWnd.ShortcutWndHorizontal.TooltipMaxBtn" );
		ShowWindow( "ShortcutWnd.ShortcutWndHorizontal.TooltipMinBtn" );
		HideWindow( "ShortcutWnd.ShortcutWndVertical.TooltipMaxBtn" );
		ShowWindow( "ShortcutWnd.ShortcutWndVertical.TooltipMinBtn" );
	}
	else
	{
		ShowWindow( "ShortcutWnd.ShortcutWndHorizontal.TooltipMaxBtn" );
		HideWindow( "ShortcutWnd.ShortcutWndHorizontal.TooltipMinBtn" );
		ShowWindow( "ShortcutWnd.ShortcutWndVertical.TooltipMaxBtn" );
		HideWindow( "ShortcutWnd.ShortcutWndVertical.TooltipMinBtn" );
	}
}

//~ function OnDefaultPosition()
//~ {
	//~ m_IsExpand1 = false;
	//~ m_IsExpand2 = false;
	//~ SetVertical(true);
	
	//~ InitShortPageNum();
	//~ ArrangeWnd();
	//~ ExpandWnd();
//~ }

function OnDefaultPosition()
{
	if ( getInstanceUIData().getIsArenaServer() ) return;

	if (GetOptionInt( "Game", "LayoutDF" ) == 1)
	{
		/*
		m_IsExpand1 = true;
		m_IsExpand2 = true;
		//수정(10.02.25)
		m_IsExpand3 = true;
		*/
		m_Expand = 4;
	}
	else
	{
	//~ class'UIAPI_WINDOW'.static.ClearAnchor( "ShortcutWnd.ShortcutWndVertical" );
	//~ class'UIAPI_WINDOW'.static.SetAnchor( "ShortcutWnd.ShortcutWndHorizontal", "ShortcutWnd.ShortcutWndVertical", "BottomRight", "BottomRight", 0, 0 );
	}
	ArrangeWnd();
	expandWnd();
	if (GetOptionInt( "Game", "LayoutDF" ) == 1)
	{
		SetVertical(false);
	}
}

function OnEnterState( name a_PreStateName )
{
	if ( getInstanceUIData().getIsArenaServer() ) return;

	ArrangeWnd();
	ExpandWnd();
	
	if( a_PreStateName == 'LoadingState' )
	InitShortPageNum();
}

function OnEvent( int a_EventID, String a_Param )
{	
	//local array<String> IDNum;
	//local ShortcutCommandItem commandItem;
	//local int shortcutID;
	//local String Command;
	
	// 아레나에서는 처리 하지 않음
	if ( getInstanceUIData().getIsArenaServer() ) return;

	//Debug("a_EventID" @ a_EventID);
	//Debug("a_Param" @ a_Param);

	switch( a_EventID )
	{
	case EV_ShortcutCommandSlot:
		ExecuteShortcutCommandBySlot(a_Param);
		break;

	case EV_ShortcutPageUpdate:					//첫번째숏컷창의 페이지가 새로 설정되었을 때 날라오는 이벤트
		HandleShortcutPageUpdate( a_Param );
		
		break;
	case EV_ShortcutJoypad:
		HandleShortcutJoypad( a_Param );
		break;
	case EV_JoypadLButtonDown:
		HandleJoypadLButtonDown( a_Param );
		break;
	case EV_JoypadLButtonUp:
		HandleJoypadLButtonUp( a_Param );
		break;
	case EV_JoypadRButtonDown:
		HandleJoypadRButtonDown( a_Param );
		break;
	case EV_JoypadRButtonUp:
		HandleJoypadRButtonUp( a_Param );
		break;
	case EV_ShortcutUpdate:
		HandleShortcutUpdate( a_Param );
		break;
	case EV_ShortcutClear:
		HandleShortcutClear();
		//InitShortPageNum();
		ArrangeWnd();
		ExpandWnd();
		break;

	case EV_ShortcutkeyassignChanged:		
	case EV_SetEnterChatting:
	case EV_UnSetEnterChatting:
		ClearAllShortcutItemTooltip();
		break;	

	case EV_Restart:
		InitShortPageNum();
		break;
	}
}
function ClearAllShortcutItemTooltip()
{
	Me.ClearAllChildShortcutItemTooltip();
}

function InitShortPageNum()
{
	CurrentShortcutPage = 0;
	CurrentShortcutPage2 = 1;
	CurrentShortcutPage3 = 2;
	//수정(10.02.25)
	CurrentShortcutPage4 = 3;
	CurrentShortcutPage5 = 4;
}

function HandleShortcutPageUpdate(string param)
{
	local int i;
	local int nShortcutID;
	local int ShortcutPage;
	
	if( ParseInt(param, "ShortcutPage", ShortcutPage) )
	{
		if( 0 > ShortcutPage || MAX_Page <= ShortcutPage )
			return;
			
		CurrentShortcutPage = ShortcutPage;
		class'UIAPI_TEXTBOX'.static.SetText( "ShortcutWnd." $ m_ShortcutWndName $ ".PageNumTextBox", string( CurrentShortcutPage + 1 ) );
		nShortcutID = CurrentShortcutPage * MAX_ShortcutPerPage;
		for( i = 0; i < MAX_ShortcutPerPage; ++i )
		{
			class'UIAPI_SHORTCUTITEMWINDOW'.static.UpdateShortcut( "ShortcutWnd." $ m_ShortcutWndName $ ".Shortcut" $ ( i + 1 ), nShortcutID );
			nShortcutID++;
		}
	}
}

function HandleShortcutUpdate(string param)
{
	local int nShortcutID;
	local int nShortcutNum;
	
	ParseInt(param, "ShortcutID", nShortcutID);
	nShortcutNum = ( nShortcutID % MAX_ShortcutPerPage ) + 1;
	
	if( IsShortcutIDInCurPage( CurrentShortcutPage, nShortcutID ) )
	{
		class'UIAPI_SHORTCUTITEMWINDOW'.static.UpdateShortcut( "ShortcutWnd." $ m_ShortcutWndName $ ".Shortcut" $ nShortcutNum, nShortcutID );
	}
	if( IsShortcutIDInCurPage( CurrentShortcutPage2, nShortcutID ) )
	{
		class'UIAPI_SHORTCUTITEMWINDOW'.static.UpdateShortcut( "ShortcutWnd." $ m_ShortcutWndName $ "_1.Shortcut" $ nShortcutNum, nShortcutID );
	}
	if( IsShortcutIDInCurPage( CurrentShortcutPage3, nShortcutID ) )
	{
		class'UIAPI_SHORTCUTITEMWINDOW'.static.UpdateShortcut( "ShortcutWnd." $ m_ShortcutWndName $ "_2.Shortcut" $ nShortcutNum, nShortcutID );
	}
	if( IsShortcutIDInCurPage( CurrentShortcutPage4, nShortcutID ) )
	{
		class'UIAPI_SHORTCUTITEMWINDOW'.static.UpdateShortcut( "ShortcutWnd." $ m_ShortcutWndName $ "_3.Shortcut" $ nShortcutNum, nShortcutID );
	}
	if(IsShortcutIDInCurPage(CurrentShortcutPage5,nShortcutID))
	{
		class'UIAPI_SHORTCUTITEMWINDOW'.static.UpdateShortcut( "ShortcutWnd." $ m_ShortcutWndName $ "_4.Shortcut" $ nShortcutNum, nShortcutID);
	}
}

function HandleShortcutClear()
{
	local int i;
	
	for( i=0 ; i < MAX_ShortcutPerPage ; ++i )
	{
		class'UIAPI_SHORTCUTITEMWINDOW'.static.Clear( "ShortcutWnd.ShortcutWndVertical.Shortcut" $ (i+1) );
		class'UIAPI_SHORTCUTITEMWINDOW'.static.Clear( "ShortcutWnd.ShortcutWndVertical_1.Shortcut" $ (i+1) );
		class'UIAPI_SHORTCUTITEMWINDOW'.static.Clear( "ShortcutWnd.ShortcutWndVertical_2.Shortcut" $ (i+1) );
		class'UIAPI_SHORTCUTITEMWINDOW'.static.Clear( "ShortcutWnd.ShortcutWndVertical_3.Shortcut" $ (i+1) );
		class'UIAPI_SHORTCUTITEMWINDOW'.static.Clear( "ShortcutWnd.ShortcutWndHorizontal.Shortcut" $ (i+1) );
		class'UIAPI_SHORTCUTITEMWINDOW'.static.Clear( "ShortcutWnd.ShortcutWndHorizontal_1.Shortcut" $ (i+1) );
		class'UIAPI_SHORTCUTITEMWINDOW'.static.Clear( "ShortcutWnd.ShortcutWndHorizontal_2.Shortcut" $ (i+1) );
		class'UIAPI_SHORTCUTITEMWINDOW'.static.Clear( "ShortcutWnd.ShortcutWndHorizontal_3.Shortcut" $ (i+1) );

		class'UIAPI_SHORTCUTITEMWINDOW'.static.Clear( "ShortcutWnd.ShortcutWndJoypadExpand.Shortcut" $ (i+1) );
	}
	for( i=0; i< 4 ; ++i )
	{
		class'UIAPI_SHORTCUTITEMWINDOW'.static.Clear( "ShortcutWnd.ShortcutWndJoypad.Shortcut" $ (i+1) );
	}
}

function HandleShortcutJoypad( String a_Param )
{
	local int OnOff;

	if( ParseInt( a_Param, "OnOff", OnOff ) )
	{
		if( 1 == OnOff )
		{
			m_IsJoypadOn = true;
			if( Len(m_ShortcutWndName) > 0 )
				ShowWindow( "ShortcutWnd." $ m_ShortcutWndName $ ".JoypadBtn" );
		}
		else if( 0 == OnOff )
		{
			m_IsJoypadOn = false;
			if( Len(m_ShortcutWndName) > 0 )
				HideWindow( "ShortcutWnd." $ m_ShortcutWndName $ ".JoypadBtn" );
		}
	}
}

function HandleJoypadLButtonUp( String a_Param )
{
	SetJoypadShortcut( JOYSHORTCUT_Center );
}

function HandleJoypadLButtonDown( String a_Param )
{
	SetJoypadShortcut( JOYSHORTCUT_Left );
}

function HandleJoypadRButtonUp( String a_Param )
{
	SetJoypadShortcut( JOYSHORTCUT_Center );
}

function HandleJoypadRButtonDown( String a_Param )
{
	SetJoypadShortcut( JOYSHORTCUT_Right );
}

function SetJoypadShortcut( EJoyShortcut a_JoyShortcut )
{
	local int i;
	local int nShortcutID;

	switch( a_JoyShortcut )
	{
	case JOYSHORTCUT_Left:
		class'UIAPI_TEXTURECTRL'.static.SetTexture( "ShortcutWnd.ShortcutWndJoypadExpand.JoypadButtonBackTex", "L2UI_CH3.ShortcutWnd.joypad2_back_over1" );
		class'UIAPI_TEXTURECTRL'.static.SetAnchor( "ShortcutWnd.ShortcutWndJoypadExpand.JoypadButtonBackTex", "ShortcutWnd.ShortcutWndJoypadExpand", "TopLeft", "TopLeft", 28, 0 );
		class'UIAPI_TEXTURECTRL'.static.SetTexture( "ShortcutWnd.ShortcutWndJoypad.JoypadLButtonTex", "L2UI_ch3.Joypad.joypad_L_HOLD" );
		class'UIAPI_TEXTURECTRL'.static.SetTexture( "ShortcutWnd.ShortcutWndJoypad.JoypadRButtonTex", "L2UI_ch3.Joypad.joypad_R" );
		nShortcutID = CurrentShortcutPage * MAX_ShortcutPerPage + 4;
		for( i = 0; i < 4; ++i )
		{
			class'UIAPI_SHORTCUTITEMWINDOW'.static.UpdateShortcut( "ShortcutWnd.ShortcutWndJoypad.Shortcut" $ ( i + 1 ), nShortcutID );
			nShortcutID++;
		}
		break;
	case JOYSHORTCUT_Center:
		class'UIAPI_TEXTURECTRL'.static.SetTexture( "ShortcutWnd.ShortcutWndJoypadExpand.JoypadButtonBackTex", "L2UI_CH3.ShortcutWnd.joypad2_back_over2" );
		class'UIAPI_TEXTURECTRL'.static.SetAnchor( "ShortcutWnd.ShortcutWndJoypadExpand.JoypadButtonBackTex", "ShortcutWnd.ShortcutWndJoypadExpand", "TopLeft", "TopLeft", 158, 0 );
		class'UIAPI_TEXTURECTRL'.static.SetTexture( "ShortcutWnd.ShortcutWndJoypad.JoypadLButtonTex", "L2UI_ch3.Joypad.joypad_L" );
		class'UIAPI_TEXTURECTRL'.static.SetTexture( "ShortcutWnd.ShortcutWndJoypad.JoypadRButtonTex", "L2UI_ch3.Joypad.joypad_R" );
		nShortcutID = CurrentShortcutPage * MAX_ShortcutPerPage;
		for( i = 0; i < 4; ++i )
		{
			class'UIAPI_SHORTCUTITEMWINDOW'.static.UpdateShortcut( "ShortcutWnd.ShortcutWndJoypad.Shortcut" $ ( i + 1 ), nShortcutID );
			nShortcutID++;
		}
		break;
	case JOYSHORTCUT_Right:
		class'UIAPI_TEXTURECTRL'.static.SetTexture( "ShortcutWnd.ShortcutWndJoypadExpand.JoypadButtonBackTex", "L2UI_CH3.ShortcutWnd.joypad2_back_over3" );
		class'UIAPI_TEXTURECTRL'.static.SetAnchor( "ShortcutWnd.ShortcutWndJoypadExpand.JoypadButtonBackTex", "ShortcutWnd.ShortcutWndJoypadExpand", "TopLeft", "TopLeft", 288, 0 );
		class'UIAPI_TEXTURECTRL'.static.SetTexture( "ShortcutWnd.ShortcutWndJoypad.JoypadLButtonTex", "L2UI_ch3.Joypad.joypad_L" );
		class'UIAPI_TEXTURECTRL'.static.SetTexture( "ShortcutWnd.ShortcutWndJoypad.JoypadRButtonTex", "L2UI_ch3.Joypad.joypad_R_HOLD" );
		nShortcutID = CurrentShortcutPage * MAX_ShortcutPerPage + 8;
		for( i = 0; i < 4; ++i )
		{
			class'UIAPI_SHORTCUTITEMWINDOW'.static.UpdateShortcut( "ShortcutWnd.ShortcutWndJoypad.Shortcut" $ ( i + 1 ), nShortcutID );
			nShortcutID++;
		}
		break;
	}
}

function OnClickButton( string a_strID )
{
	switch( a_strID )
	{
	case "PrevBtn":
		OnPrevBtn();
		break;
	case "NextBtn":
		OnNextBtn();
		break;
	case "PrevBtn2":
		OnPrevBtn2();
		break;
	case "NextBtn2":
		OnNextBtn2();
		break;
	case "PrevBtn3":
		OnPrevBtn3();
		break;
	case "NextBtn3":
		OnNextBtn3();
		break;
	case "LockBtn":
		OnClickLockBtn();
		break;
	case "UnlockBtn":
		OnClickUnlockBtn();
		break;
	case "RotateBtn":
		OnRotateBtn();
		// 자동 정탄 위치 보정
		AutoShotPositionAutoMove();
		break;
	case "JoypadBtn":
		OnJoypadBtn();
		break;
	case "ExpandBtn":
		OnExpandBtn();
		break;
	case "ExpandButton":
		OnClickExpandShortcutButton();
		// 자동 정탄 위치 보정
		//AutoShotItemWndScript.windowPositionAutoMove();
		//AutoShotItemWndScript.checkSlotShowState();
		break;
	case "ReduceButton":
		OnClickExpandShortcutButton();
		// 자동 정탄 위치 보정
		//AutoShotItemWndScript.windowPositionAutoMove();
		//AutoShotItemWndScript.checkSlotShowState();
		break;
	//수정(10.02.25)
	case "PrevBtn4":
		OnPrevBtn4();
		break;
	case "NextBtn4":
		OnNextBtn4();
		break;

	case "PrevBtn5":
		OnPrevBtn5();
		break;
	case "NextBtn5":
		OnNextBtn5();
		break;

	//수정(10.05.07)
	case "TooltipMinBtn":
		OnMinBtn();
		break;
	case "TooltipMaxBtn":
		OnMaxBtn();
		break;
	}
}

function OnMinBtn()
{
	local Tooltip Script;
	
	HandleShortcutClear();
	ArrangeWnd();
	ExpandWnd();

	Script = Tooltip( GetScript( "Tooltip" ) );
	Script.setBoolSelect( true );

	// 2010.8.23 - winkey
	ShowWindow( "ShortcutWnd.ShortcutWndHorizontal.TooltipMaxBtn" );
	HideWindow( "ShortcutWnd.ShortcutWndHorizontal.TooltipMinBtn" );
	ShowWindow( "ShortcutWnd.ShortcutWndVertical.TooltipMaxBtn" );
	HideWindow( "ShortcutWnd.ShortcutWndVertical.TooltipMinBtn" );
	
	SetInIBool ( "ShortcutWnd", "l", false, "windowsInfo.ini");
	//SetOptionBool( "Game", "IsShortcutWndMinTooltip", false );
}

function OnMaxBtn()
{
	local Tooltip Script;
	
	HandleShortcutClear();
	ArrangeWnd();
	ExpandWnd();

	Script = Tooltip( GetScript( "Tooltip" ) );
	Script.setBoolSelect( false );

	// 2010.8.23 - winkey
	ShowWindow( "ShortcutWnd.ShortcutWndHorizontal.TooltipMinBtn" );
	HideWindow( "ShortcutWnd.ShortcutWndHorizontal.TooltipMaxBtn" );
	ShowWindow( "ShortcutWnd.ShortcutWndVertical.TooltipMinBtn" );
	HideWindow( "ShortcutWnd.ShortcutWndVertical.TooltipMaxBtn" );
	
	SetInIBool ( "ShortcutWnd", "l", true, "windowsInfo.ini");
	//SetOptionBool( "Game", "IsShortcutWndMinTooltip", true );
}

function OnPrevBtn()
{
	local int nNewPage;

	nNewPage = CurrentShortcutPage - 1;
	if( 0 > nNewPage )
		nNewPage = MAX_Page - 1;

	SetCurPage( nNewPage );
}

function OnPrevBtn2()
{
	local int nNewPage;

	nNewPage = CurrentShortcutPage2 - 1;
	if( 0 > nNewPage )
		nNewPage = MAX_Page - 1;

	SetCurPage2( nNewPage );
}

function OnPrevBtn3()
{
	local int nNewPage;

	nNewPage = CurrentShortcutPage3 - 1;
	if( 0 > nNewPage )
		nNewPage = MAX_Page - 1;

	SetCurPage3( nNewPage );
}

function OnNextBtn()
{
	local int nNewPage;

	nNewPage = CurrentShortcutPage + 1;
	if( MAX_Page <= nNewPage )
		nNewPage = 0;

	SetCurPage( nNewPage );
}

function OnNextBtn2()
{
	local int nNewPage;

	nNewPage = CurrentShortcutPage2 + 1;
	if( MAX_Page <= nNewPage )
		nNewPage = 0;

	SetCurPage2( nNewPage );
}

function OnNextBtn3()
{
	local int nNewPage;

	nNewPage = CurrentShortcutPage3 + 1;
	if( MAX_Page <= nNewPage )
		nNewPage = 0;

	SetCurPage3( nNewPage );
}


function OnPrevBtn4()
{
	local int nNewPage;

	nNewPage = CurrentShortcutPage4 - 1;
	if( 0 > nNewPage )
		nNewPage = MAX_Page - 1;

	SetCurPage4( nNewPage );
}

function OnNextBtn4()
{
	local int nNewPage;

	nNewPage = CurrentShortcutPage4 + 1;
	if( MAX_Page <= nNewPage )
		nNewPage = 0;

	SetCurPage4( nNewPage );
}


function OnPrevBtn5()
{
	local int nNewPage;

	nNewPage = CurrentShortcutPage5 - 1;
	if( 0 > nNewPage )
		nNewPage = MAX_Page - 1;

	SetCurPage5( nNewPage );
}

function OnNextBtn5()
{
	local int nNewPage;

	nNewPage = CurrentShortcutPage5 + 1;
	if( MAX_Page <= nNewPage )
		nNewPage = 0;

	SetCurPage5( nNewPage );
}

function OnClickLockBtn()
{
	UnLock();
}

function OnClickUnlockBtn()
{
	Lock();
}

function OnRotateBtn()
{
	SetVertical( !m_IsVertical );
	
	if( m_IsVertical )
	{
		class'UIAPI_WINDOW'.static.SetAnchor( "ShortcutWnd.ShortcutWndVertical", "ShortcutWnd.ShortcutWndHorizontal", "BottomRight", "BottomRight", 0, 0 );
		class'UIAPI_WINDOW'.static.ClearAnchor( "ShortcutWnd.ShortcutWndVertical" );
		class'UIAPI_WINDOW'.static.SetAnchor( "ShortcutWnd.ShortcutWndHorizontal", "ShortcutWnd.ShortcutWndVertical", "BottomRight", "BottomRight", 0, 0 );
	}
	else 
	{
		class'UIAPI_WINDOW'.static.SetAnchor( "ShortcutWnd.ShortcutWndHorizontal", "ShortcutWnd.ShortcutWndVertical", "BottomRight", "BottomRight", 0, 0 );                                
		class'UIAPI_WINDOW'.static.ClearAnchor( "ShortcutWnd.ShortcutWndHorizontal" );                                                                                                     
		class'UIAPI_WINDOW'.static.SetAnchor( "ShortcutWnd.ShortcutWndVertical", "ShortcutWnd.ShortcutWndHorizontal", "BottomRight", "BottomRight", 0, 0 );                                
	}

	// 알림 가로 세로 체크
	NoticeWnd(GetScript("NoticeWnd")).checkMultiLayOut();	

	/*
	//수정(10.02.25)
	if(m_IsExpand3 == true)
	{
		Expand1();
		Expand2();
		Expand3();
	}
	if(m_IsExpand2 == true)
	{
		Expand1();
		Expand2();
	}
	if(m_IsExpand1 == true)
	{
		Expand1();
	}*/
	
	ExpandByNum( m_Expand ) ;

	class'UIAPI_WINDOW'.static.SetFocus( "ShortcutWnd." $ m_ShortcutWndName );
}

function OnJoypadBtn()
{
	SetJoypad( !m_IsJoypad );
	class'UIAPI_WINDOW'.static.SetFocus( "ShortcutWnd." $ m_ShortcutWndName );
}

function OnExpandBtn()
{
	SetJoypadExpand( !m_IsJoypadExpand );
	class'UIAPI_WINDOW'.static.SetFocus( "ShortcutWnd." $ m_ShortcutWndName );
}

function SetCurPage( int a_nCurPage )
{
	if( 0 > a_nCurPage || MAX_Page <= a_nCurPage )
		return;
		
	//Set Current ShortcutKey(F1,F2,F3...) ShortcutWnd Num
	//단축키는 첫번째숏컷창만 참조하므로..
	class'ShortcutAPI'.static.SetShortcutPage( a_nCurPage );
	
	//->EV_ShortcutPageUpdate 가 날라온다.
}

function SetCurPage2( int a_nCurPage )
{
	local int i;
	local int nShortcutID;
	
	if( 0 > a_nCurPage || MAX_Page <= a_nCurPage )
		return;
		
	CurrentShortcutPage2 = a_nCurPage;
	class'UIAPI_TEXTBOX'.static.SetText( "ShortcutWnd." $ m_ShortcutWndName $ "." $ m_ShortcutWndName $ "_1" $ ".PageNumTextBox", string( CurrentShortcutPage2 + 1 ) );
	nShortcutID = CurrentShortcutPage2 * MAX_ShortcutPerPage;
	for( i = 0; i < MAX_ShortcutPerPage; ++i )
	{
		class'UIAPI_SHORTCUTITEMWINDOW'.static.UpdateShortcut( "ShortcutWnd." $ m_ShortcutWndName $ "." $ m_ShortcutWndName $ "_1" $".Shortcut" $ ( i + 1 ), nShortcutID );
		nShortcutID++;
	}
}

function SetCurPage3( int a_nCurPage )
{
	local int i;
	local int nShortcutID;
	
	if( 0 > a_nCurPage || MAX_Page <= a_nCurPage )
		return;
		
	CurrentShortcutPage3 = a_nCurPage;
	class'UIAPI_TEXTBOX'.static.SetText( "ShortcutWnd." $ m_ShortcutWndName $ "." $ m_ShortcutWndName $ "_1." $ m_ShortcutWndName $"_2" $ ".PageNumTextBox", string( CurrentShortcutPage3 + 1 ) );	
	nShortcutID = CurrentShortcutPage3 * MAX_ShortcutPerPage;
	for( i = 0; i < MAX_ShortcutPerPage; ++i )
	{
		class'UIAPI_SHORTCUTITEMWINDOW'.static.UpdateShortcut( "ShortcutWnd." $ m_ShortcutWndName $ "." $ m_ShortcutWndName $ "_1." $ m_ShortcutWndName $"_2" $ ".Shortcut" $ ( i + 1 ), nShortcutID );
		nShortcutID++;
	}
}

//수정(10.02.25)
function SetCurPage4( int a_nCurPage )
{
	local int i;
	local int nShortcutID;
	
	if( 0 > a_nCurPage || MAX_Page <= a_nCurPage )
		return;
		
	CurrentShortcutPage4 = a_nCurPage;
	class'UIAPI_TEXTBOX'.static.SetText( "ShortcutWnd." $ m_ShortcutWndName $ "." $ m_ShortcutWndName $ "_1." $ m_ShortcutWndName $"_3" $ ".PageNumTextBox", string( CurrentShortcutPage4 + 1 ) );	
	nShortcutID = CurrentShortcutPage4 * MAX_ShortcutPerPage;
	for( i = 0; i < MAX_ShortcutPerPage; ++i )
	{
		//debug( "ShortcutWnd." $ m_ShortcutWndName $ "." $ m_ShortcutWndName $ "_1." $ m_ShortcutWndName $"_3" $ ".Shortcut" $ ( i + 1 ) @ nShortcutID );

		class'UIAPI_SHORTCUTITEMWINDOW'.static.UpdateShortcut( "ShortcutWnd." $ m_ShortcutWndName $ "." $ m_ShortcutWndName $ "_1." $ m_ShortcutWndName $"_3" $ ".Shortcut" $ ( i + 1 ), nShortcutID );
		nShortcutID++;
	}
}

// 2016.07.20
// 해외 5줄 숏컷 추가 
function SetCurPage5( int a_nCurPage )
{
	local int i;
	local int nShortcutID;
	
	if( 0 > a_nCurPage || MAX_Page <= a_nCurPage )
		return;
		
	CurrentShortcutPage5 = a_nCurPage;
	class'UIAPI_TEXTBOX'.static.SetText( "ShortcutWnd." $ m_ShortcutWndName $ "." $ m_ShortcutWndName $ "_1." $ m_ShortcutWndName $"_4" $ ".PageNumTextBox", string( CurrentShortcutPage5 + 1 ) );	
	nShortcutID = CurrentShortcutPage5 * MAX_ShortcutPerPage;
	for( i = 0; i < MAX_ShortcutPerPage; ++i )
	{
		//debug( "ShortcutWnd." $ m_ShortcutWndName $ "." $ m_ShortcutWndName $ "_1." $ m_ShortcutWndName $"_3" $ ".Shortcut" $ ( i + 1 ) @ nShortcutID );

		class'UIAPI_SHORTCUTITEMWINDOW'.static.UpdateShortcut( "ShortcutWnd." $ m_ShortcutWndName $ "." $ m_ShortcutWndName $ "_1." $ m_ShortcutWndName $"_4" $ ".Shortcut" $ ( i + 1 ), nShortcutID );
		nShortcutID++;
	}
}

function bool IsShortcutIDInCurPage( int PageNum, int a_nShortcutID )
{
	if( PageNum * MAX_ShortcutPerPage > a_nShortcutID )
		return false;
	if( ( PageNum + 1 ) * MAX_ShortcutPerPage <= a_nShortcutID )
		return false;
	return true;
}

function Lock()
{
	m_IsLocked = true;
	SetOptionBool( "Game", "IsLockShortcutWnd", true );
	//SetINIInt ( "ShortcutWnd", "l",  1, "WindowsInfo.ini");

	//if( IsShowWindow( "ShortcutWnd" ) )
	//{
		ShowWindow( "ShortcutWnd." $ m_ShortcutWndName $ ".LockBtn" );
		HideWindow( "ShortcutWnd." $ m_ShortcutWndName $ ".UnlockBtn" );
	//}
}

function UnLock()
{
	m_IsLocked = false;
	//SetINIInt ( "ShortcutWnd", "l",  0, "WindowsInfo.ini");
	SetOptionBool( "Game", "IsLockShortcutWnd", false );

	//if( IsShowWindow( "ShortcutWnd" ) )
	//{
		ShowWindow( "ShortcutWnd." $ m_ShortcutWndName $ ".UnlockBtn" );
		HideWindow( "ShortcutWnd." $ m_ShortcutWndName $ ".LockBtn" );
	//}
}

function SetVertical( bool a_IsVertical )
{
	m_IsVertical = a_IsVertical;
	SetINIInt ( "ShortcutWnd", "v",  int ( m_IsVertical ) , "WindowsInfo.ini");
	//SetOptionBool( "Game", "IsShortcutWndVertical", m_IsVertical );

	ArrangeWnd();
	ExpandWnd();
}

function SetJoypad( bool a_IsJoypad )
{
	m_IsJoypad = a_IsJoypad;

	ArrangeWnd();
}

function SetJoypadExpand( bool a_IsJoypadExpand )
{
	m_IsJoypadExpand = a_IsJoypadExpand;

	if( m_IsJoypadExpand )
	{
		class'UIAPI_WINDOW'.static.SetAnchor( "ShortcutWnd.ShortcutWndJoypadExpand", "ShortcutWnd.ShortcutWndJoypad", "TopLeft", "TopLeft", 0, 0 );
		class'UIAPI_WINDOW'.static.ClearAnchor( "ShortcutWnd.ShortcutWndJoypadExpand" );
	}
	else
	{
		class'UIAPI_WINDOW'.static.SetAnchor( "ShortcutWnd.ShortcutWndJoypad", "ShortcutWnd.ShortcutWndJoypadExpand", "TopLeft", "TopLeft", 0, 0 );
		class'UIAPI_WINDOW'.static.ClearAnchor( "ShortcutWnd.ShortcutWndJoypad" );
	}

	ArrangeWnd();
}

function ArrangeWnd()
{
	local Rect WindowRect;
	//local int tmpInt;

	if( m_IsJoypad )
	{
		HideWindow( "ShortcutWnd.ShortcutWndVertical" );
		HideWindow( "ShortcutWnd.ShortcutWndHorizontal" );
		if( m_IsJoypadExpand )
		{
			HideWindow( "ShortcutWnd.ShortcutWndJoypad" );
			ShowWindow( "ShortcutWnd.ShortcutWndJoypadExpand" );

			m_ShortcutWndName = "ShortcutWndJoypadExpand";
		}
		else
		{
			HideWindow( "ShortcutWnd.ShortcutWndJoypadExpand" );
			ShowWindow( "ShortcutWnd.ShortcutWndJoypad" );

			m_ShortcutWndName = "ShortcutWndJoypad";
		}
	}
	else
	{
		HideWindow( "ShortcutWnd.ShortcutWndJoypadExpand" );
		HideWindow( "ShortcutWnd.ShortcutWndJoypad" );
		if( m_IsVertical )
		{
			m_ShortcutWndName = "ShortcutWndVertical";
			WindowRect = class'UIAPI_WINDOW'.static.GetRect( "ShortcutWnd.ShortcutWndVertical" );
			if( WindowRect.nY < 0 )
				class'UIAPI_WINDOW'.static.MoveTo( "ShortcutWnd.ShortcutWndVertical", WindowRect.nX, 0 );
			HideWindow( "ShortcutWnd.ShortcutWndHorizontal" );
			ShowWindow( "ShortcutWnd.ShortcutWndVertical" );
		}
		else
		{
			m_ShortcutWndName = "ShortcutWndHorizontal";
			WindowRect = class'UIAPI_WINDOW'.static.GetRect( "ShortcutWnd.ShortcutWndHorizontal" );
			if( WindowRect.nX < 0 )
				class'UIAPI_WINDOW'.static.MoveTo( "ShortcutWnd.ShortcutWndHorizontal", 0, WindowRect.nY );
			HideWindow( "ShortcutWnd.ShortcutWndVertical" );
			ShowWindow( "ShortcutWnd.ShortcutWndHorizontal" );
		}

		if( m_IsJoypadOn )
			ShowWindow( "ShortcutWnd." $ m_ShortcutWndName $ ".JoypadBtn" );
		else
			HideWindow( "ShortcutWnd." $ m_ShortcutWndName $ ".JoypadBtn" );
	}
	
	/*GetINIInt ( "ShortcutWnd", "l",  tmpInt, "WindowsInfo.ini");
	m_IsLocked = bool ( tmpInt ) ;*/
	//m_IsLocked = GetOptionBool( "Game", "IsLockShortcutWnd" );	
	if( m_IsLocked )
		Lock();
	else
		UnLock();

	SetCurPage( CurrentShortcutPage );
	SetCurPage2( CurrentShortcutPage2 );
	SetCurPage3( CurrentShortcutPage3 );
	SetCurPage4( CurrentShortcutPage4 );
	SetCurPage5( CurrentShortcutPage5 );
	
	/*
	if(m_IsExpand1 == true)
	{
		m_IsShortcutExpand = true;
		HandleExpandButton();
	}
	else if(m_IsExpand2 == true)
	{
		m_IsShortcutExpand = true;
		HandleExpandButton();
	}
	else if(m_IsExpand3 == true)
	{
		m_IsShortcutExpand = false;
		HandleExpandButton();
	}
	else
	{
		m_IsShortcutExpand = true;
		HandleExpandButton();
	}
*/
	
	m_IsShortcutExpand = ( m_Expand != 4 ) ;
	HandleExpandButton();
}

function ExpandWnd()
{
	//수정(10.02.25)
	//if( m_IsExpand1 == true || m_IsExpand2 == true || m_IsExpand3 == true )
	if ( m_Expand > 0 ) 
	{
		//debug( m_IsExpand1 @ "&&&&&" @ m_IsExpand2 @ "&&&&&" @ m_IsExpand3 );
		m_IsShortcutExpand = false;
		/*
		if(m_IsExpand3 == true)
		{			
			Expand3();
		}
		if(m_IsExpand2 == true)
		{			
			Expand2();
		}
		if(m_IsExpand1 == true)
		{		
			Expand1();
		}*/
		ExpandByNum( m_Expand ) ;
	}
	else
	{
		m_IsShortcutExpand = true;
		Reduce();
	}
}

function ExpandByNum ( int expandNum )
{
	m_IsShortcutExpand = true;
	m_Expand = expandNum;
	switch ( expandNum ) 
	{
		case 4:		
			class'UIAPI_WINDOW'.static.ShowWindow("ShortcutWnd.ShortcutWndVertical_4");
			class'UIAPI_WINDOW'.static.ShowWindow("ShortcutWnd.ShortcutWndHorizontal_4");

		case 3:		
			class'UIAPI_WINDOW'.static.ShowWindow("ShortcutWnd.ShortcutWndVertical_3");
			class'UIAPI_WINDOW'.static.ShowWindow("ShortcutWnd.ShortcutWndHorizontal_3");

		case 2:		
			class'UIAPI_WINDOW'.static.ShowWindow("ShortcutWnd.ShortcutWndVertical_2");
			class'UIAPI_WINDOW'.static.ShowWindow("ShortcutWnd.ShortcutWndHorizontal_2");

		case 1:		
			class'UIAPI_WINDOW'.static.ShowWindow("ShortcutWnd.ShortcutWndVertical_1");
			class'UIAPI_WINDOW'.static.ShowWindow("ShortcutWnd.ShortcutWndHorizontal_1");
			break;
	}

	SetINIInt ( "ShortcutWnd", "e", m_Expand, "WindowsInfo.ini") ;
	HandleExpandButton();

	AutoShotItemWndScript.windowPositionAutoMove();
	AutoShotItemWndScript.checkSlotShowState();
}

/*
function Expand1()
{
	m_IsShortcutExpand = true;
	m_IsExpand1 = true;
	SetOptionBool( "Game", "Is1ExpandShortcutWnd", m_IsExpand1 );
	
	class'UIAPI_WINDOW'.static.ShowWindow("ShortcutWnd.ShortcutWndVertical_1");
	class'UIAPI_WINDOW'.static.ShowWindow("ShortcutWnd.ShortcutWndHorizontal_1");
	
	HandleExpandButton();
}

function Expand2()
{
	m_IsShortcutExpand = true;	
	m_IsExpand2 = true;
	SetOptionBool( "Game", "Is2ExpandShortcutWnd", m_IsExpand2 );
	
	class'UIAPI_WINDOW'.static.ShowWindow("ShortcutWnd.ShortcutWndVertical_2");
	class'UIAPI_WINDOW'.static.ShowWindow("ShortcutWnd.ShortcutWndHorizontal_2");
	
	HandleExpandButton();
}

//수정(10.02.25)
function Expand3()
{
	m_IsShortcutExpand = true;	
	m_IsExpand3 = true;
	SetOptionBool( "Game", "Is3ExpandShortcutWnd", m_IsExpand3 );
	
	class'UIAPI_WINDOW'.static.ShowWindow("ShortcutWnd.ShortcutWndVertical_3");
	class'UIAPI_WINDOW'.static.ShowWindow("ShortcutWnd.ShortcutWndHorizontal_3");
	
	HandleExpandButton();
}
*/

function Reduce()
{
	m_IsShortcutExpand = true;
	
	//m_IsExpand1 = false;
	//m_IsExpand2 = false;
	
	//SetOptionBool( "Game", "Is1ExpandShortcutWnd", m_IsExpand1 );
	//SetOptionBool( "Game", "Is2ExpandShortcutWnd", m_IsExpand2 );

	class'UIAPI_WINDOW'.static.HideWindow("ShortcutWnd.ShortcutWndVertical_1");
	class'UIAPI_WINDOW'.static.HideWindow("ShortcutWnd.ShortcutWndVertical_2");
	class'UIAPI_WINDOW'.static.HideWindow("ShortcutWnd.ShortcutWndHorizontal_1");
	class'UIAPI_WINDOW'.static.HideWindow("ShortcutWnd.ShortcutWndHorizontal_2");
	
	//수정(10.02.25)
	//m_IsExpand3 = false;
	//SetOptionBool( "Game", "Is3ExpandShortcutWnd", m_IsExpand3 );
	class'UIAPI_WINDOW'.static.HideWindow("ShortcutWnd.ShortcutWndVertical_3");
	class'UIAPI_WINDOW'.static.HideWindow("ShortcutWnd.ShortcutWndHorizontal_3");

	class'UIAPI_WINDOW'.static.HideWindow("ShortcutWnd.ShortcutWndVertical_4");
	class'UIAPI_WINDOW'.static.HideWindow("ShortcutWnd.ShortcutWndHorizontal_4");

	m_Expand = 0;
	SetINIInt ( "ShortcutWnd", "e", m_Expand, "WindowsInfo.ini") ;

	HandleExpandButton();

	AutoShotItemWndScript.windowPositionAutoMove();
	AutoShotItemWndScript.checkSlotShowState();
}

function OnClickExpandShortcutButton()
{
	//수정(10.02.25)
	//debug( "m_IsExpand3------->" @  m_IsExpand3 );
	//debug( "m_IsExpand2------->" @  m_IsExpand2 );
	//debug( "m_IsExpand1------->" @  m_IsExpand1 );

	//Debug("m_Expand:::: "@ m_Expand);

	if ( m_Expand == 4 ) 
	{
		Reduce();
	}
	else 
	{
		ExpandByNum ( m_Expand + 1) ;
	}
	AutoShotPositionAutoMove();
	/*
	if (m_IsExpand3)
	{
		//debug( "Reduce" );
		Reduce();
	}
	else if (m_IsExpand2)
	{
		//debug( "Expand3" );
		Expand3();
	}
	else if (m_IsExpand1)
	{
		//debug( "Expand2" );
		Expand2();
	}
	else 
	{
		//debug( "Expand1" );
		Expand1();
	}	
	*/
}

function ExecuteShortcutCommandBySlot(string param)
{
	local int slot;
	ParseInt(param, "Slot", slot);
	//debug ("현재 슬롯넘버" @ slot);
	//Log("CurrentShortcutPage 1 " $ CurrentShortcutPage $ ", 2 " $ CurrentShortcutPage2 $ ", 3 " $ CurrentShortcutPage3);
	
	if(Me.isShowwindow())		// 창이 보여질 때만 수행하도록 처리.
	{	
		if( slot >=0 && slot < MAX_ShortcutPerPage )			// bottom
		{
			class'ShortcutAPI'.static.ExecuteShortcutBySlot(CurrentShortcutPage*MAX_ShortcutPerPage + slot);
		}
		else if( slot >= MAX_ShortcutPerPage && slot < MAX_ShortcutPerPage*2 )		// middle
		{
			//debug ("슬롯페이지2");
			class'ShortcutAPI'.static.ExecuteShortcutBySlot(CurrentShortcutPage2*MAX_ShortcutPerPage + slot - MAX_ShortcutPerPage);
		}
		else if( slot >= MAX_ShortcutPerPage*2 && slot < MAX_ShortcutPerPage*3 )		// last
		{
			//debug ("슬롯페이지3");
			class'ShortcutAPI'.static.ExecuteShortcutBySlot(CurrentShortcutPage3*MAX_ShortcutPerPage + slot - MAX_ShortcutPerPage2);
		}
		else if( slot >= MAX_ShortcutPerPage*3 && slot < MAX_ShortcutPerPage*4 )		// last
		{
			//debug ("슬롯페이지4");
			class'ShortcutAPI'.static.ExecuteShortcutBySlot(CurrentShortcutPage4*MAX_ShortcutPerPage + slot - MAX_ShortcutPerPage3);
		}

	}
}

function HandleExpandButton()
{
	if( m_IsShortcutExpand )
	{
		ShowWindow( "ShortcutWnd." $ m_ShortcutWndName $ ".ExpandButton" );
		HideWindow( "ShortcutWnd." $ m_ShortcutWndName $ ".ReduceButton" );
	}
	else
	{
		HideWindow( "ShortcutWnd." $ m_ShortcutWndName $ ".ExpandButton" );
		ShowWindow( "ShortcutWnd." $ m_ShortcutWndName $ ".ReduceButton" );
	}
}

function bool IsVertical()
{
	return m_IsVertical;
}

// 숏컷 확장슬롯 상태 0~4
function int getExpandNum()
{
	//Debug("m_Expand" @ m_Expand);
	return m_Expand;
}

// 자동 정탄 위치 보정 TT#72738
function AutoShotPositionAutoMove()
{	
	AutoShotItemWndScript.windowPositionAutoMove();
	AutoShotItemWndScript.checkSlotShowState();
}

defaultproperties
{
    m_IsVertical=True
}
