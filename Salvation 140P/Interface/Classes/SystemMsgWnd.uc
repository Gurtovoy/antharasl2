class SystemMsgWnd	extends UICommonAPI;


var WindowHandle Me;
var WindowHandle m_hChatWnd;
var TextureHandle	m_hdBodyTex;

function OnRegisterEvent()
{
	registerEvent( EV_GamingStateEnter );
	registerEvent( EV_ChatWndOnResize);
	registerEvent( EV_ResolutionChanged);
}

function OnLoad()
{	
	Me = GetWindowHandle("SystemMsgWnd");
	Me.EnableDynamicAlpha(true);
	m_hChatWnd = GetWindowHandle("ChatWnd");
	m_hdBodyTex = GetTextureHandle("SystemMsgWnd.BackTexture");	
}

function OnEvent( int a_EventID, String a_Param )
{
	local int tempVal ; 
	switch( a_EventID )
	{
	case EV_GamingStateEnter:
		//게임에 다시 들어왔을 때 창을 열지 말지 결정함
		GetINIBool( "global", "SystemMsgWnd", tempVal, "chatfilter.ini" );
		//if(class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.ChattingFilterGroup.UseSystemMsgBox" ))
		if ( tempVal != 0 ) 
		{
			class'UIAPI_WINDOW'.static.ShowWindow("SystemMsgWnd");
		}
		else
		{
			class'UIAPI_WINDOW'.static.HideWindow("SystemMsgWnd");
		}

	/*
		if( GetINIBool( "global", "SystemMsgWnd", tempVars, "chatfilter.ini" ))
		{
			//debug("SystemMsgWndtest Show");
			class'UIAPI_WINDOW'.static.ShowWindow("SystemMsgWnd");
		}
		else
		{
			//debug("SystemMsgWndtest Hide");
			class'UIAPI_WINDOW'.static.HideWindow("SystemMsgWnd");
		}
*/
		break;

	case EV_ChatWndOnResize:
		ReSize(a_Param);
		break;
	case EV_ResolutionChanged:
		UpdateResolution();
		break;
	default:
		break;
	}
}

function SetDefaultAlpha(int type)
{
	if(type == 0)
	{
		m_hdBodyTex.SetAlpha(255, 0);

	}
	else
	{
		m_hdBodyTex.SetAlpha(50, 0);
	}
}


function onMouseOver( WindowHandle w )
{
	local ChatWnd script;
	script = ChatWnd( GetScript("ChatWnd") );

	if(script.m_UseAlpha == 1)
	{
		m_hdBodyTex.SetAlpha(255, 0.5);
	}
}

function onMouseOut( WindowHandle w )
{
	local ChatWnd script;
	script = ChatWnd( GetScript("ChatWnd") );

	if(script.m_UseAlpha == 1)
	{
		m_hdBodyTex.SetAlpha(50, 0.5);
	}
}

function UpdateResolution()
{
	local int CurrentMaxWidth, CurrentMaxHeight, CurrentChatWidth, CurrentChatHeight;

	GetCurrentResolution (CurrentMaxWidth, CurrentMaxHeight);

	m_hChatWnd.GetWindowSize(CurrentChatWidth, CurrentChatHeight);	

	if( CurrentChatWidth > CurrentMaxWidth || CurrentChatHeight > CurrentMaxHeight - 15)
	{
		Me.GetWindowSize (CurrentChatWidth, CurrentChatHeight );
		Me.SetWindowSize( 348 , CurrentChatHeight);
	}
}

function ReSize(string param)
{
	local int w;
	local int resizeWidth;
	local int h;
	
	parseInt(param, "Width", resizeWidth);
	
	Me.GetWindowSize(w, h);	
	Me.SetWindowSize(resizeWidth, h);
}

function OnShow()
{
	local int useAlpha, tempVal, w, h, sizeW;
	local string showWndParam;

	if ( GetINIBool("global", "UseAlpha", tempVal, "chatfilter.ini") )
		useAlpha = tempVal;

	if(useAlpha == 0)
	{	
		SetDefaultAlpha(0);
	}
	else
	{
		SetDefaultAlpha(1);
	}
	
	//사이즈 기억
	Me.GetWindowSize(w, h);

	if(GetINIInt("global","ChatSizeWidth", sizeW, "chatfilter.ini"))
	{   
		Me.SetWindowSize( sizeW , h);
	}
	else
	{	
		Me.SetWindowSize( w , h);
	}
	Me.SetReSizeFrameOffset(348, h);
	ChangeAnchorEffectButton("SystemMsgWnd");	// lancelot 2006. 7. 10.

	paramAdd(showWndParam, "visible", String(1));
	/*
	 * worldChatBox 에 전용창 사용여부 보냄
	 */
	if(GetINIBool( "global", "UseWorldChatSpeaker", tempVal, "chatfilter.ini" ))
	{	
		callGFxFunction( "worldChatBox", "IsShowSystemMsgWnd", showWndParam);
	}
	callGFxFunction( "UserAlertMessage", "IsShowSystemMsgWnd", showWndParam);
}

function OnHide()
{
	local string showWndParam;
	//debug("SystemMsgWndtest OnHide");
	//채팅창 기능 개선으로 필터 윈도우의 앵커를 설정하는 기능은 없어짐
	//class'UIAPI_WINDOW'.static.SetAnchor( "ChatFilterWnd", "ChatWnd", "TopLeft", "BottomLeft", 0, -5 );
	ChangeAnchorEffectButton("ChatWnd");		// lancelot 2006. 7. 10.

	paramAdd(showWndParam, "visible", String(0));
	callGFxFunction( "worldChatBox", "IsShowSystemMsgWnd", showWndParam);
	callGFxFunction( "UserAlertMessage", "IsShowSystemMsgWnd", showWndParam);
}

function ChangeAnchorEffectButton(string strID)
{
	//debug("ChangeAnchorEffectButton");
	class'UIAPI_WINDOW'.static.SetAnchor( "TutorialBtnWnd", strID, "TopLeft", "BottomLeft", 5, -5 );
	class'UIAPI_WINDOW'.static.SetAnchor( "QuestBtnWnd", StrID, "TopLeft", "BottomLeft", 42, -5 );
	class'UIAPI_WINDOW'.static.SetAnchor( "MailBtnWnd", strID, "TopLeft", "BottomLeft", 79, -5 );
	//class'UIAPI_WINDOW'.static.SetAnchor( "PremiumItemBtnWnd", strID, "TopLeft", "BottomLeft", 5, -37 );
	class'UIAPI_WINDOW'.static.SetAnchor( "BirthdayAlarmBtn", strID, "TopLeft", "BottomLeft", 42, -37 );
	//class'UIAPI_WINDOW'.static.SetAnchor( "AuctionBtnWnd", strID, "TopLeft", "BottomLeft", 79, -37 );
	//class'UIAPI_WINDOW'.static.SetAnchor( "AuctionBtnWnd", strID, "TopLeft", "BottomLeft", 5, -37 );
	//class'UIAPI_WINDOW'.static.SetAnchor( "SystemTutorialBtnWnd", strID, "TopLeft", "BottomLeft", 5, -37 );		
}
defaultproperties
{
}
