class NewUserPetitionWnd extends UICommonAPI;

const MAX_PetitionCategory = 100;

var ComboBoxHandle	m_hFirstCategory;
var ComboBoxHandle	m_hSecondCategory;

var HtmlHandle		m_hDescriptionViewer;
var HtmlHandle		m_hHtmlViewer;
var HtmlHandle		m_hContentsViewer;

var WindowHandle 	Drawer;
var WindowHandle	Me;

var int				selectedCategoryId;

var String			StartHtml;
var String			EndHtml;

function OnRegisterEvent()
{
	RegisterEvent(EV_ShowNewUserPetitionWnd);
	RegisterEvent(EV_AddNewUserPetitionCategoryStepOne);
	RegisterEvent(EV_ShowNewUserPetitionDescription);
	RegisterEvent(EV_AddNewUserPetitionCategoryStepTwo);
	RegisterEvent(EV_ShowNewUserPetitionHtml);
	RegisterEvent(EV_ShowNewUserPetitionContents);	
}

function OnLoad()
{
	selectedCategoryId = 0;

	OnRegisterEvent();

	Me = GetWindowHandle("NewUserPetitionWnd");
	Drawer = GetWindowHandle("NewUserPetitionDrawerWnd");

	m_hFirstCategory = GetComboBoxHandle("NewUserPetitionWnd.PetitionTypeComboBox_1st");
	m_hSecondCategory = GetComboBoxHandle("NewUserPetitionWnd.PetitionTypeComboBox_2nd");
	m_hDescriptionViewer = GetHtmlHandle("NewUserPetitionWnd.HelpDialogHtmlCtrl");
	m_hHtmlViewer = GetHtmlHandle("NewUserPetitionWnd.HelpHtmlCtrl");
	m_hContentsViewer = GetHtmlHandle("NewUserPetitionDrawerWnd.ContentsTextBox");

	m_hSecondCategory.DisableWindow();

	StartHtml = "<HTML><HEAD><BODY>";
	EndHtml = "</BODY></HTML>";
}

function OnHide()
{
	Clear();
}

function OnEvent(int a_EventID, string a_Param)
{
	switch(a_EventID)
	{
	case EV_ShowNewUserPetitionWnd:
		HandleShowNewUserPetitionWnd();
		break;
	case EV_AddNewUserPetitionCategoryStepOne:
		HandleAddNewCategoryStepOne(a_Param);
		break;
	case EV_ShowNewUserPetitionDescription:
		HandleShowDescription(a_Param);
		break;
	case EV_AddNewUserPetitionCategoryStepTwo:
		HandleAddNewCategoryStepTwo(a_Param);
		break;
	case EV_ShowNewUserPetitionHtml:
		HandleLoadPetitionHtml(a_Param);
		break;
	case EV_ShowNewUserPetitionContents:
		HandleShowNewUserPetitionContents(a_Param);
		break;
	}
}

function HandleShowNewUserPetitionWnd()
{
	Clear();

	m_hOwnerWnd.ShowWindow();
	m_hOwnerWnd.SetFocus();

	// 클라이언트에서 읽어 온 기본 안내말 html을 필요한 윈도우에 뿌려준다. (아직 미수행)
	m_hHtmlViewer.LoadHtml("..\\L2text\\newpet_help_main.htm");	
}

function HandleAddNewCategoryStepOne(string a_Param)
{
	local int		categoryId		;
	local string	categoryName	;

	ParseInt(a_Param, "CategoryId_", categoryId);
	ParseString(a_Param, "CategoryName_", categoryName);

	m_hFirstCategory.AddStringWithReserved(categoryName, categoryId);
}

function HandleAddNewCategoryStepTwo(string a_Param)
{
	local int		categoryId		;
	local string	categoryName	;	

	ParseInt(a_Param, "CategoryId_", categoryId);
	ParseString(a_Param, "CategoryName_", categoryName);

	m_hSecondCategory.AddStringWithReserved(categoryName, categoryId);	
}

function HandleShowDescription(string a_Param)
{
	local int num;
	local string categoryDescription;

	ParseInt(a_Param, "Count", num);
	if(num > 0)
	{
		m_hSecondCategory.EnableWindow();
		DialogShow(DialogModalType_Modalless, DialogType_OK, GetSystemMessage( 2992 ), string(Self) );
		selectedCategoryId = 0;
	}

	ParseString(a_Param, "CategoryDescription", categoryDescription);
	m_hDescriptionViewer.LoadHtmlFromString(StartHtml $ categoryDescription $ EndHtml);
}

function HandleLoadPetitionHtml(String a_Param)
{
	local string HtmlString;
	
	ParseString(a_Param, "HtmlString", HtmlString);
	if( Len( HtmlString ) > 0 )
	{
		m_hHtmlViewer.clear();
		m_hHtmlViewer.LoadHtmlFromString(HtmlString);
	}
}

function HandleShowNewUserPetitionContents(String a_Param)
{
	local string ContentsString;

	m_hContentsViewer.Clear();
	ParseString(a_Param, "Contents", ContentsString);
	m_hContentsViewer.LoadHtmlFromString(StartHtml $ ContentsString $ EndHtml);

	Drawer.ShowWindow();
}

function OnComboBoxItemSelected(String a_ControlID, INT a_SelectedIndex)
{
	local int passingCategoryId;

	if(a_ControlID == "PetitionTypeComboBox_1st")
	{
		Drawer.HideWindow();
		m_hSecondCategory.DisableWindow();
		if(a_SelectedIndex >= 1)
		{
			m_hSecondCategory.Clear();
			m_hSecondCategory.AddStringWithReserved(GetSystemString(2024), MAX_PetitionCategory);
			class'UIAPI_COMBOBOX'.static.SetSelectedNum("NewUserPetitionWnd.PetitionTypeComboBox_2nd", 0);

			m_hDescriptionViewer.Clear();
			m_hHtmlViewer.clear();

			passingCategoryId = m_hFirstCategory.GetReserved(a_SelectedIndex);
			selectedCategoryId = m_hFirstCategory.GetReserved(a_SelectedIndex);

			RequestShowStepTwo(passingCategoryId);
		}
		else
		{
			selectedCategoryId = 0;

			m_hSecondCategory.Clear();
			m_hSecondCategory.AddStringWithReserved(GetSystemString(2024), MAX_PetitionCategory);
			class'UIAPI_COMBOBOX'.static.SetSelectedNum("NewUserPetitionWnd.PetitionTypeComboBox_2nd", 0);

			m_hDescriptionViewer.Clear();
			m_hHtmlViewer.clear();
			m_hHtmlViewer.LoadHtml("..\\L2text\\newpet_help_main.htm");
		}
	}
	else if(a_ControlID == "PetitionTypeComboBox_2nd")
	{
		Drawer.HideWindow();
		if(a_SelectedIndex >= 1)
		{
			m_hHtmlViewer.clear();

			passingCategoryId = m_hSecondCategory.GetReserved(a_SelectedIndex);
			selectedCategoryId = m_hSecondCategory.GetReserved(a_SelectedIndex);

			RequestShowStepThree(passingCategoryId);
		}
		else
		{
			selectedCategoryId = 0;
			m_hHtmlViewer.clear();
			m_hHtmlViewer.LoadHtml("..\\L2text\\newpet_help_main.htm");
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
	case "DrawerCloseButton":
		if(Drawer.IsShowWindow())
		{
			m_hContentsViewer.Clear();
			Drawer.HideWindow();
		}		
		break;
	default:
		break;
	}
}

function OnClickOKButton()
{
	local WindowHandle 	NewPetitionWndHandle;
	local NewPetitionWnd NewPetitionWndScript;

	if(!Drawer.IsShowWindow())
	{
		// 컨텐츠까지 읽어야 진정 신청이 가능하다.
		DialogShow(DialogModalType_Modalless,DialogType_Notice, GetSystemMessage(804), string(Self));
	}
	else
	{		
		NewPetitionWndHandle = GetWindowHandle("NewPetitionWnd");
		NewPetitionWndScript = NewPetitionWnd(GetScript("NewPetitionWnd"));

		NewPetitionWndScript.SetCategoryId(selectedCategoryId);
		NewPetitionWndHandle.ShowWindow();

		Clear();
		Me.HideWindow();		
	}
}

function OnClickCancelButton()
{
	Clear();
	HideWindow("NewUserPetitionWnd");
}

function Clear()
{
	m_hFirstCategory.Clear();
	m_hSecondCategory.Clear();

	m_hSecondCategory.DisableWindow();

	m_hFirstCategory.AddStringWithReserved(GetSystemString(2024), MAX_PetitionCategory);
	m_hSecondCategory.AddStringWithReserved(GetSystemString(2024), MAX_PetitionCategory);

	class'UIAPI_COMBOBOX'.static.SetSelectedNum("NewUserPetitionWnd.PetitionTypeComboBox_1st", 0);
	class'UIAPI_COMBOBOX'.static.SetSelectedNum("NewUserPetitionWnd.PetitionTypeComboBox_2nd", 0);
	m_hDescriptionViewer.Clear();
	m_hContentsViewer.Clear();
	m_hHtmlViewer.clear();

	Drawer.HideWindow();

	selectedCategoryId = 0;
}
defaultproperties
{
}
