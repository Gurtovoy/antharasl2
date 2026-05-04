class PetitionWnd extends UICommonAPI;
var ChatWindowHandle petitionchat;

function OnRegisterEvent()
{
	RegisterEvent( EV_ShowPetitionWnd );
	RegisterEvent( EV_PetitionChatMessage );
	RegisterEvent( EV_EnablePetitionFeedback );
}

function OnLoad()
{
	local ListBoxHandle temp;

	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	SetFeedBackEnable( false );
	petitionchat = GetChatWindowHandle( "PetitionWnd.PetitionChatWindow" );
	petitionchat.SetScrollBarPosition(368,0,0);
	temp = GetListBoxHandle( "PetitionWnd.PetitionChatWindow" );
	temp.SetDrawOffset(3,3);
	temp.SetMaxRow(200);
	
}

function OnHide()
{
	SetFeedBackEnable( false );
}

function SetFeedBackEnable( bool a_IsEnabled )
{
	if( a_IsEnabled )
		class'UIAPI_BUTTON'.static.EnableWindow( "PetitionWnd.FeedBackButton" );
	else
		class'UIAPI_BUTTON'.static.DisableWindow( "PetitionWnd.FeedBackButton" );
}

function OnEvent( int a_EventID, String a_Param )
{
	switch( a_EventID )
	{
	case EV_ShowPetitionWnd:
		HandleShowPetitionWnd();
		break;
	case EV_PetitionChatMessage:
		HandlePetitionChatMessage( a_Param );
		break;
	case EV_EnablePetitionFeedback:
		HandleEnablePetitionFeedback( a_Param );
		break;
	}
}

function OnCompleteEditBox( String strID )
{
	local String Message;

	switch( strID )
	{
	case "PetitionChatEditBox":
		Message = class'UIAPI_EDITBOX'.static.GetString( "PetitionWnd.PetitionChatEditBox" );
		ProcessPetitionChatMessage( Message );
		break;
	}
	
	class'UIAPI_EDITBOX'.static.Clear( "PetitionWnd.PetitionChatEditBox" );
}

function HandleShowPetitionWnd()
{
	if( m_hOwnerWnd.IsMinimizedWindow() )
		m_hOwnerWnd.NotifyAlarm();
	else
	{
		ShowWindow( "PetitionWnd" );
		m_hOwnerWnd.SetFocus();
	}
}

function HandlePetitionChatMessage( String a_Param )
{
	local String ChatMessage;
	local Color ChatColor;
	local int tmpType;
	
	if( ParseString( a_Param, "Message", ChatMessage ) && ParseInt( a_Param, "SayType", tmpType) )
	{
		debug(ChatMessage);
		ChatColor=GetChatColorByType(tmpType);
		//class'UIAPI_TEXTLISTBOX'.static.AddString( "PetitionWnd.PetitionChatWindow", ChatMessage, ChatColor );
		debug(string(petitionchat));
		petitionchat.AddString(ChatMessage, ChatColor);
	}
}

function HandleEnablePetitionFeedback( String a_Param )
{
	local int Enable;

	if( ParseInt( a_Param, "Enable", Enable ) )
	{
		if( 1 == Enable )
			SetFeedBackEnable( true );
		else
			SetFeedBackEnable( false );
	}
}

function OnClickButton( String a_ControlID )
{
	switch( a_ControlID )
	{
	case "FeedBackButton":
		OnClickFeedBackButton();
		break;
	case "CancelButton":
		OnClickCancelButton();
		break;
	}
}

function OnClickFeedBackButton()
{
	local PetitionMethod useNewPetition;
	useNewPetition = GetPetitionMethod();

	if( useNewPetition == PetitionMethod_New )
		class'UIAPI_WINDOW'.static.ShowWindow("NewPetitionFeedBackWnd");
	else
		class'UIAPI_WINDOW'.static.ShowWindow("PetitionFeedBackWnd");
}

function OnClickCancelButton()
{
	SetFeedBackEnable( false );
	class'PetitionAPI'.static.RequestPetitionCancel();
}

function Clear()
{
	local ListBoxHandle temp;
	temp = GetListBoxHandle( "PetitionWnd.PetitionChatWindow" );
	temp.Clear();
	//class'UIAPI_TEXTLISTBOX'.static.Clear( "PetitionWnd.PetitionChatWindow" );
}

defaultproperties
{
}
