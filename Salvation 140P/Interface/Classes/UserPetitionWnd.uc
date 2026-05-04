class UserPetitionWnd extends UICommonAPI;

const MAX_PetitionCategory = 32;

var int PetitionCategoryCount;
var int PetitionCategoryTitle[ MAX_PetitionCategory ];
var String PetitionCategoryLink[ MAX_PetitionCategory ];

var HtmlHandle	m_hUserPetitionWndHelpHtmlCtrl;

function OnRegisterEvent()
{
	RegisterEvent( EV_ShowUserPetitionWnd );
	RegisterEvent( EV_LoadPetitionHtml );
}

function OnLoad()
{
	local int i;

	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	m_hUserPetitionWndHelpHtmlCtrl=GetHtmlHandle("UserPetitionWnd.HelpHtmlCtrl");

	for( i = 0; i < PetitionCategoryCount; ++i )
	{
		class'UIAPI_COMBOBOX'.static.SYS_AddString( "UserPetitionWnd.PetitionTypeComboBox", PetitionCategoryTitle[ i ] );
	}
}

function OnEvent( int a_EventID, String a_Param )
{
	switch( a_EventID )
	{
	case EV_ShowUserPetitionWnd:
		HandleShowUserPetitionWnd( a_Param );
		break;
	case EV_LoadPetitionHtml:
		HandleLoadPetitionHtml( a_Param );
		break;
	}
}

function HandleShowUserPetitionWnd( String a_Param )
{
	local String Message;

	m_hOwnerWnd.ShowWindow();
	m_hOwnerWnd.SetFocus();

	if( ParseString( a_Param, "Message", Message ) )
		class'UIAPI_MULTIEDITBOX'.static.SetString( "UserPetitionWnd.PetitionMultiEdit", Message );
}

function HandleLoadPetitionHtml( String a_Param )
{
	local string HtmlString;
	
	ParseString( a_Param, "HtmlString", HtmlString );
	if( Len( HtmlString ) > 0 )
		m_hUserPetitionWndHelpHtmlCtrl.LoadHtmlFromString(HtmlString );
}

function OnComboBoxItemSelected( String a_ControlID, INT a_SelectedIndex )
{
	if( a_ControlID == "PetitionTypeComboBox" )
	{
		if( a_SelectedIndex >= 1 )
		{
			m_hUserPetitionWndHelpHtmlCtrl.LoadHtml("..\\L2text\\" $ PetitionCategoryLink[ a_SelectedIndex -1 ] );
		}
		else
		{
			m_hUserPetitionWndHelpHtmlCtrl.Clear();
		}
	}
}

function OnClickButton( String a_ControlID )
{
	switch( a_ControlID )
	{
	case "OKButton":
		OnClickOKButton();
		break;
	case "CancelButton":
		OnClickCancelButton();
		break;
	}
}

function OnClickOKButton()
{
	local String PetitionMessage;
	local int PetitionMessageLen;
	local int PetitionType;
	local String Param;
	local PetitionWnd PetitionWndScript;

	PetitionType = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "UserPetitionWnd.PetitionTypeComboBox" );
	PetitionMessage = class'UIAPI_MULTIEDITBOX'.static.GetString( "UserPetitionWnd.PetitionMultiEdit" );
	PetitionMessageLen = Len( PetitionMessage );

	if( 0 == PetitionType )
		DialogShow(DialogModalType_Modalless, DialogType_OK, GetSystemMessage( 804 ), string(Self) );
	else if( 5 > PetitionMessageLen )
		DialogShow(DialogModalType_Modalless, DialogType_OK, GetSystemMessage( 386 ), string(Self) );
	else if( 800 <= PetitionMessageLen )
		DialogShow(DialogModalType_Modalless, DialogType_OK, GetSystemMessage( 971 ), string(Self) );
	else
	{
		class'PetitionAPI'.static.RequestPetition( PetitionMessage, PetitionType );
		Clear();
		HideWindow( "UserPetitionWnd" );

		PetitionWndScript = PetitionWnd( GetScript( "PetitionWnd" ) );
		if( None != PetitionWndScript )
		{
			PetitionWndScript.Clear();
			ParamAdd( Param, "Message", GetSystemString( 708 ) $ " : " $ PetitionMessage );
			ParamAdd( Param, "ColorR", "220" );
			ParamAdd( Param, "ColorG", "220" );
			ParamAdd( Param, "ColorB", "220" );
			ParamAdd( Param, "ColorA", "255" );
			PetitionWndScript.HandlePetitionChatMessage( Param );
		}
	}
}

function OnClickCancelButton()
{
	class'PetitionAPI'.static.RequestPetitionCancel();
	Clear();
	HideWindow( "UserPetitionWnd" );
}

function Clear()
{
	class'UIAPI_COMBOBOX'.static.SetSelectedNum( "UserPetitionWnd.PetitionTypeComboBox", 0 );
	class'UIAPI_MULTIEDITBOX'.static.SetString( "UserPetitionWnd.PetitionMultiEdit", "" );
	m_hUserPetitionWndHelpHtmlCtrl.Clear();
}

defaultproperties
{
    PetitionCategoryCount=9
    PetitionCategoryTitle(0)=696
    PetitionCategoryTitle(1)=697
    PetitionCategoryTitle(2)=698
    PetitionCategoryTitle(3)=699
    PetitionCategoryTitle(4)=700
    PetitionCategoryTitle(5)=701
    PetitionCategoryTitle(6)=702
    PetitionCategoryTitle(7)=703
    PetitionCategoryTitle(8)=704
    PetitionCategoryLink(0)="pet_help_move.htm"
    PetitionCategoryLink(1)="pet_help_recover.htm"
    PetitionCategoryLink(2)="pet_help_bug.htm"
    PetitionCategoryLink(3)="pet_help_quest.htm"
    PetitionCategoryLink(4)="pet_help_report.htm"
    PetitionCategoryLink(5)="pet_help_suggest.htm"
    PetitionCategoryLink(6)="pet_help_game.htm"
    PetitionCategoryLink(7)="pet_help_oprn.htm"
    PetitionCategoryLink(8)="pet_help_etc.htm"
}
