class NewPetitionWnd extends UICommonAPI;

var WindowHandle Me;
var TextBoxHandle m_hTitleEditBox;
var MultiEditBoxHandle m_hContentsEditBox;
var int m_categoryId;

function OnRegisterEvent()
{
}

function OnLoad()
{
	OnRegisterEvent();

	Me = GetWindowHandle("NewPetitionWnd");
	m_hTitleEditBox = GetTextBoxHandle("NewPetitionWnd.PetitionGuideText");
	m_hContentsEditBox = GetMultiEditBoxHandle("NewPetitionWnd.PetitionMultiEdit");
	//m_hTitleEditBox.SetString(GetSystemString(2021));	

	Me.ShowWindow();
	Me.SetFocus();
}

function OnShow()
{
	Me.ShowWindow();
	Me.SetFocus();
}

function OnHide()
{
	Clear();
}

function OnEvent(int a_EventID, string a_Param)
{
}

function OnClickButton( String a_ControlID )
{
	switch( a_ControlID )
	{
	// 버튼 이름은 FeedBackButton이지만 사실은 [진정접수] 버튼
	case "FeedBackButton":
		OnClickOKButton();
		break;
	case "CancelButton":
		OnClickCancelButton();
		break;
	default:
		break;
	}
}

function Clear()
{
	//m_hTitleEditBox.SetString(GetSystemString(2021));
	m_hContentsEditBox.SetString("");
}

function OnClickOKButton()
{
	//local int TitleMessageLen;
	local int ContentsMessageLen;
	//local String TitleMessage;
	local String ContentsMessage;
	//local String AllMessage;
	local String Param;
	local PetitionWnd PetitionWndScript;

	//TitleMessageLen = 0;
	ContentsMessageLen = 0;

	//TitleMessage = m_hTitleEditBox.GetString();
	ContentsMessage = m_hContentsEditBox.GetString();

	//TitleMessageLen = Len(TitleMessage);
	ContentsMessageLen = Len(ContentsMessage);

	if(15 > ContentsMessageLen)
		DialogShow(DialogModalType_Modalless, DialogType_OK, GetSystemMessage( 2991 ), string(Self) );
	else if(800 <= ContentsMessageLen)
		DialogShow(DialogModalType_Modalless, DialogType_OK, GetSystemMessage( 971 ), string(Self) );
	else
	{
		// 제목과 내용을 분리하려는 작업 (일단 보류)
		//TitleMessage = "_T_" $ TitleMessage;
		//ContentsMessage = "_C_" $ ContentsMessage;
		

		class'PetitionAPI'.static.RequestPetition(ContentsMessage, m_categoryId);
		Clear();
		HideWindow("NewPetitionWnd");

		// PetitionWnd는 기존과 동일하므로 따로 NewPetitionChatWnd를 사용하지는 않는다. (개선된 진정에서는 새로운 단계가 추가된 것이라고 보면 됨)
		PetitionWndScript = PetitionWnd(GetScript("PetitionWnd"));
		if(None != PetitionWndScript)
		{
			PetitionWndScript.Clear();
			ParamAdd(Param, "Message", GetSystemString( 708 ) $ " : " $ ContentsMessage);
			ParamAdd(Param, "ColorR", "220");
			ParamAdd(Param, "ColorG", "220");
			ParamAdd(Param, "ColorB", "220");
			ParamAdd(Param, "ColorA", "255");
			PetitionWndScript.HandlePetitionChatMessage(Param);
		}
	}
}

function OnClickCancelButton()
{
	Clear();
	Me.HideWindow();
}

function SetCategoryId(int categoryId)
{
	m_categoryId = categoryId;
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnKeyDown( WindowHandle a_WindowHandle, EInputKey Key )
{
	if( Key == IK_Escape )
	{
		OnClickCancelButton();
	}
}
defaultproperties
{
}
