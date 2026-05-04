class ChatWnd extends UICommonAPI;

struct ChatFilterInfo
{
	var int bSystem;
	var int bChat;
	var int bDamage;
	var int bNormal;
	var int bShout;
	var int bClan;
	var int bParty;
	var int bTrade;
	var int bWhisper;
	var int bAlly;
	var int bUseitem;
	var int bHero;
	var int bUnion;
	var int bBattle;
	var int bNoNpcMessage;
	var int bWorldChat;
};
//Global Setting
var int	m_bUseSystemMsgWnd;
var int	m_bSystemMsgWnd;
var int	m_bDamageOption;
var int	m_bUseSystemItem;
//var int	m_NoUnionCommanderMessage;
var int m_NoNpcMessage;				// NPC 대사 필터링 - 2010.9.8 winkey
var int m_bWorldChat;				// 월드채팅
var int m_bWorldChatSpeaker;		// 월드채팅 스피커 사용
var int m_bOnlyUseSystemMsgWnd;     // 시스템 메시지 창에서만 사용


var int         m_EditBoxHeight;

var int         m_UseChatSymbol;
var int         m_UseAlpha;
var int     	m_KeywordFilterSound;
var int 	    m_KeywordFilterActivate;

var int         m_ChatResizeOnOff;  //채팅 사이즈 조절 삼각형 보기 끄기

var string  	m_Keyword0;
var string		m_Keyword1;
var string 		m_Keyword2;
var string 		m_Keyword3;

var bool			m_IsSplit0;
var bool			m_IsSplit1;
var bool			m_IsSplit2;
var bool			m_IsSplit3;
var bool			m_IsSplit4;

var array<ChatFilterInfo>	m_filterInfo;
var array<string>			m_sectionName;
//~ var int					m_chatType;

struct native constructive ChatUIType
{
	var	int			ID;
	var	int			UI;		
};

var ChatUIType					m_ChatUI[8];
var ChatUIType					m_chatType;

const CHAT_WINDOW_NORMAL = 0;
const CHAT_WINDOW_TRADE  = 1;
const CHAT_WINDOW_PARTY  = 2;
const CHAT_WINDOW_CLAN   = 3;
const CHAT_WINDOW_ALLY   = 4;
const CHAT_WINDOW_COUNT  = 9;
const CHAT_WINDOW_SYSTEM = 9;		// 시스템 메시지 창
const CHAT_WINDOW_TAB_LEN = 5;	// 탭 개수
//~ const CHAT_WINDOW_

//(10.1.28 문선준 추가)
//Link 이벤트 const 값.
const DIALOGID_GoWeb = 1234510;
//Url 값 저장.
var string Url;
var string Text;

//branch
//const CHAT_UNION_MAX = 20;			// 지휘채널 OnScreenMessage 한줄에 최대로 들어갈 수 있는 글자 수
const CHAT_UNION_MAX = 35;			// 지휘채널 OnScreenMessage 한줄에 최대로 들어갈 수 있는 글자 수(글로벌용)
//end of branch

//Handle List
var ChatWindowHandle NormalChat;
var ChatWindowHandle TradeChat;
var ChatWindowHandle PartyChat;
var ChatWindowHandle ClanChat;
var ChatWindowHandle AllyChat;
var ChatWindowHandle SystemMsg;

var WindowHandle TradeChatTabButton;
var WindowHandle PartyChatTabButton;
var WindowHandle ClanChatTabButton;
var WindowHandle AllyChatTabButton;

var WindowHandle UpScrollButton;
var WindowHandle DownScrollButton;
var WindowHandle SliderScrollButton;

//~ var ChekboxHandle OutEditBox

var TabHandle ChatTabCtrl;
var EditBoxHandle ChatEditBox;

var WindowHandle	m_hChatWnd;
var WindowHandle	m_hSystemMsgWnd;

var WindowHandle	m_hChatFontsizeWnd;

var TextureHandle	m_hChatWndLanguageTexture;
var TextureHandle	m_hChatWndBodyTex;
var TextureHandle   m_hChatWndHeadTex;
var TextureHandle   m_hChatWndBottomTex;
var TextureHandle   m_hChatWndBottomTex2;
var TextureHandle   m_hChatWndBottomTex3;
var TextureHandle   m_hChatWndBottomTex4;
var TextureHandle   m_hChatWndBottomTex5;

var ButtonHandle m_ChatFontOptionBtn;

var string lastClickChatTabName;

function OnRegisterEvent()
{
	registerEvent( EV_ChatMessage );
	registerEvent( EV_IMEStatusChange );

	registerEvent( EV_ChatWndStatusChange );
	registerEvent( EV_ChatWndSetString );
	registerEvent( EV_ChatWndSetFocus );
	//msn 관련 내용들은 13.01.23 업데이트  이후 삭제 됨니다.
	//registerEvent( EV_ChatWndMsnStatus );	
	registerEvent( EV_ChatWndMacroCommand );
	
	//TextLink
	registerEvent( EV_TextLinkLButtonClick );
	registerEvent(EV_TextLinkRButtonClick);
	registerEvent(EV_GamingStateEnter);
	registerEvent(EV_GamingStateExit);
	

	//진정창, 채팅 url링크 이벤트(10.1.28 문선준 추가)
	//registerEvent( EV_UrlLinkClick ); // L2UTil 에 중복됨.
	registerEvent( EV_DialogOK );
	registerEvent( EV_DialogCancel );

	registerEvent( EV_ChatWndOnResize );

	registerEvent( EV_ResolutionChanged );

	registerEvent( EV_ChangedSubjob );

	registerEvent( EV_NeedResetUIData );

	registerEvent( EV_Restart );


	
}

function OnLoad()
{
	m_filterInfo.Length = CHAT_WINDOW_COUNT + 1;		// 실제로 쓰이는 것은 CHAT_WINDOW_COUNT 만큼이지만 CheckFilter를 좀 더 간편하게 짜기위해 CHAT_WINDOW_SYSTEM 용 더미를 한개 더 할당한다.
	m_EditBoxHeight = 16;
	m_sectionName.Length = CHAT_WINDOW_COUNT;				// chatfilter.ini에서의 항목
	m_sectionName[0] = "entire_tab";
	m_sectionName[1] = "pledge_tab";
	m_sectionName[2] = "party_tab";
	m_sectionName[3] = "market_tab";
	m_sectionName[4] = "ally_tab";
	m_sectionName[5] = "hero_tab";
	m_sectionName[6] = "union_tab";
	m_sectionName[7] = "shout_tab";
	m_sectionName[8] = "worldChat_tab";
	
	//~ m_sectionName[CHAT_WINDOW_ALLY] = "ally_tab";
	//~ m_sectionName[CHAT_WINDOW_ALLY] = "ally_tab";
	//~ m_sectionName[CHAT_WINDOW_ALLY] = "ally_tab";
	//~ m_sectionName[CHAT_WINDOW_ALLY] = "ally_tab";
	
	// xml 에서 GaimingState에 등록해 주고 여기서 추가로 OlympiadObserverState에도 등록해 준다.
	RegisterState( "ChatWnd", "OlympiadObserverState" );
	RegisterState( "ChatWnd", "TRAININGROOMSTATE" );

	InitHandleCOD();
		
	InitFilterInfo();
	//InitGlobalSetting();
	InitScrollBarPosition();
	
	//Enable TextLink
	ChatEditBox.SetEnableTextLink( true );
	m_chatType.UI = 0;
	m_chatType.ID = -1;

//	Debug ( "m_chatType.ID 바뀜 0 " @ m_chatType.ID );

	m_IsSplit0 = false;
	m_IsSplit1 = false;
	m_IsSplit2 = false;
	m_IsSplit3 = false;
	m_IsSplit4 = false;
	

	if ( getInstanceUIData().getIsArenaServer() )
	{
		ChatTabCtrl.RemoveTabControl( 4 ) ;
		ChatTabCtrl.RemoveTabControl( 3 ) ;		
	}	
}

//function OnExitState( name a_NextStateName )
//{
	//if (a_NextStateName == 'GamingState')
	//{
	//	ShowWindow("ChatWnd");
	//}
	//else if ( a_NextStateName == 'OlympiadObserverState')
	//{
	//	ShowWindow("ChatWnd");
	//}
	//else
	//{
	//HideWindow("ChatWnd");
	//}
//}

function OnDefaultPosition()
{
	ChatTabCtrl.MergeTab(CHAT_WINDOW_TRADE);
	ChatTabCtrl.MergeTab(CHAT_WINDOW_PARTY);
	ChatTabCtrl.MergeTab(CHAT_WINDOW_CLAN);
	ChatTabCtrl.MergeTab(CHAT_WINDOW_ALLY);
	ChatTabCtrl.SetTopOrder(0, true);
	
	m_hChatWnd.SetAnchor("", "BottomLeft", "BottomLeft", 0, -18 );
	HandleTabClick("ChatTabCtrl0");
}

/*
function InitGlobalSetting()
{
	local EditBoxHandle EditBox_KeyWord0;
	local EditBoxHandle EditBox_KeyWord1;
	local EditBoxHandle EditBox_KeyWord2;
	local EditBoxHandle EditBox_KeyWord3;

	EditBox_KeyWord0 = GetEditBoxHandle ("ChatFilterWnd.Editbox_KeyWord0" );
	EditBox_KeyWord1 = GetEditBoxHandle ("ChatFilterWnd.Editbox_KeyWord1" );
	EditBox_KeyWord2 = GetEditBoxHandle ("ChatFilterWnd.Editbox_KeyWord2" );
	EditBox_KeyWord3 = GetEditBoxHandle ("ChatFilterWnd.Editbox_KeyWord3" );	
	
	m_hChkChatFilterWndCheckBoxCommand.SetCheck( bool(m_NoUnionCommanderMessage) );
	// m_hChkChatFilterWndCheckBoxNpc.SetCheck( bool(m_NoNpcMessage) );	// NPC 대사 필터링 - 2010.9.8 winkey				
	m_hChkChatFilterWndKeywordSoundBox.SetCheck( bool(m_KeywordFilterSound) );
	m_hChkChatFilterWndKeywordFilterBox.SetCheck( bool(m_KeywordFilterActivate) );
	m_hChkChatFilterWndUseAlphaBox.SetCheck( bool(m_UseAlpha) );
	m_hChkChatFilterWndUseChatSymbol.SetCheck(bool(m_UseChatSymbol));
	m_hChkChatFilterWndChatResize.SetCheck(bool(m_ChatResizeOnOff));

	//사이즈조절 보기안보기
	//EnableChatWndResizing(true);

	EditBox_KeyWord0.SetString(m_Keyword0);
	EditBox_KeyWord1.SetString(m_Keyword1);
	EditBox_KeyWord2.SetString(m_Keyword2);
	EditBox_KeyWord3.SetString(m_Keyword3);
}
*/

function InitHandleCOD()
{
	NormalChat                              =GetChatWindowHandle( "ChatWnd.NormalChat" );
	TradeChat                               =GetChatWindowHandle( "ChatWnd.TradeChat" );
	PartyChat                               =GetChatWindowHandle( "ChatWnd.PartyChat" );
	ClanChat                                =GetChatWindowHandle( "ChatWnd.ClanChat" );
	AllyChat                                =GetChatWindowHandle( "ChatWnd.AllyChat" );
	SystemMsg                               =GetChatWindowHandle( "SystemMsgWnd.SystemMsgList" );
	ChatTabCtrl                             =GetTabHandle( "ChatWnd.ChatTabCtrl" );
	TradeChatTabButton                      =GetWindowHandle( "ChatWnd.TradeChat.TabButton" );
	PartyChatTabButton                      =GetWindowHandle( "ChatWnd.PartyChat.TabButton" );
	ClanChatTabButton                       =GetWindowHandle( "ChatWnd.ClanChat.TabButton" );
	AllyChatTabButton                       =GetWindowHandle( "ChatWnd.AllyChat.TabButton" );

	ChatEditBox                             =GetEditBoxHandle( "ChatWnd.ChatEditBox" );

	m_hChatFontsizeWnd  					=GetWindowHandle("ChatFontsizeWnd");        // 폰트 조절 옵션
	m_ChatFontOptionBtn                     =GetButtonHandle("ChatWnd.ChatFontOptionBtn");

	m_hChatWnd                              =GetWindowHandle("ChatWnd");
	m_hChatWnd.EnableDynamicAlpha(true);
	TradeChat.EnableDynamicAlpha(true);
	PartyChat.EnableDynamicAlpha(true);
	ClanChat.EnableDynamicAlpha(true);
	AllyChat.EnableDynamicAlpha(true);	
	SystemMsg.EnableDynamicAlpha(true);

	m_hSystemMsgWnd                         =GetWindowHandle("SystemMsgWnd");
	//m_hChatFilterWnd                        =GetWindowHandle("ChatFilterWnd");
	m_hChatWndLanguageTexture               =GetTextureHandle("ChatWnd.LanguageTexture");
	m_hChatWndBodyTex                       =GetTextureHandle("ChatWnd.ChatWndBodyTex");
	m_hChatWndHeadTex                       =GetTextureHandle("ChatWnd.ChatWndHeadTex");
	m_hChatWndBottomTex                     =GetTextureHandle("ChatWnd.ChatWndBottomTex");
	m_hChatWndBottomTex2                    =GetTextureHandle("ChatWnd.ChatWndBottomTex1");
	m_hChatWndBottomTex3                    =GetTextureHandle("ChatWnd.ChatWndBottomTex2");
	m_hChatWndBottomTex4                    =GetTextureHandle("ChatWnd.ChatWndBottomTex3");
	m_hChatWndBottomTex5                    =GetTextureHandle("ChatWnd.ChatWndBottomTex4");	
}

function InitScrollBarPosition()
{
	NormalChat.SetScrollBarPosition( 5, 10, 2 );
	TradeChat.SetScrollBarPosition( 5, 10, 2 );
	PartyChat.SetScrollBarPosition( 5, 10, 2 );
	ClanChat.SetScrollBarPosition( 5, 10, 2 );
	AllyChat.SetScrollBarPosition( 5, 10, 2 );
}

function OnCompleteEditBox( String strID )
{
	local String strInput;
	local EChatType Type;
	//local int useEnterChatting;
	
	if( strID == "ChatEditBox" )
	{
		strInput = ChatEditBox.GetString();
		if ( Len( strInput ) < 1 )
			return;
		
		ProcessChatMessage( strInput, m_chatType.ID, false );
		ChatEditBox.SetString( "" );
		
		//채팅기호		
		m_UseChatSymbol = int ( GetChatFilterBool ( "Global", "OldChatting")) ;		
		
		if( bool(m_UseChatSymbol) == true)
		{
			Type = GetChatTypeByTabIndex( m_chatType.ID );
			
			//일반탭이 아닌 경우, Prefix를 붙여준다.
			if ( m_chatType.ID  != 0 )
			{				
				if(GetChatPrefix( Type ) != "~")
				{
					ChatEditBox.AddString( GetChatPrefix( Type ) );
				}
			}
		}
		
		//엔터채팅		
		if( GetChatFilterBool ( "Global", "EnterChatting" ) )
		{
			ChatEditBox.ReleaseFocus();
		}
	}
}

function Clear()
{
	ChatEditBox.Clear();
	NormalChat.Clear();
	PartyChat.Clear();
	ClanChat.Clear();
	TradeChat.Clear();
	AllyChat.Clear();
	SystemMsg.Clear();
}

function SetChangeFont(int fontType)
{
	local string fontname;
	
	switch( fontType )	
	{
		case 0:
			fontname = "chatFontSize10";
			break;
		case 1:
			fontname = "chatFontSize11";
			break;
		case 2:
			fontname = "chatFontSize12";
			break;
		
		default:
			fontname = "chatFontSize10";
			break;
	}

	NormalChat.SetFontIDByName( fontname );
	TradeChat.SetFontIDByName( fontname );
	PartyChat.SetFontIDByName( fontname );
	ClanChat.SetFontIDByName( fontname );
	AllyChat.SetFontIDByName( fontname );
	SystemMsg.SetFontIDByName( fontname );
}

function OnShow()
{
	local int fontSize, sizeW, sizeH;
	local int tempVal;
	local string isSavedString, sizeParam, isShowSystemMsgWndParam;
	//local ChatFilterWnd script;

	local int CurrentMaxWidth, CurrentMaxHeight;

	local bool isSavedChatSize;	

	handleChangedSubjob( "" );
	
	// 한번도 로딩 안된 경우 .............................. 와 첫 로딩 이후 저장 된 값 가져 오기 부분
	GetINIString("global", "DefaultSaveOption", isSavedString, "chatfilter.ini");
	if(isSavedString == "true")	
		LoadINIFilterSetting();
	else
	{
		isSavedString = "true";
		SetINIString("global", "DefaultSaveOption", isSavedString, "chatfilter.ini");
		SetDefaultFilterValue();
		SaveChatFilterOption();
	}

	GetINIBool( "global", "SystemMsgWnd", tempVal, "chatfilter.ini" );
	m_bUseSystemMsgWnd = tempVal;
	
	paramAdd(isShowSystemMsgWndParam, "visible", String(tempVal));
	//사용하는 상태일때만
	if(GetINIBool( "global", "UseWorldChatSpeaker", tempVal, "chatfilter.ini" ))
	{	
		callGFxFunction( "worldChatBox", "IsShowSystemMsgWnd", isShowSystemMsgWndParam);
	}
	
	callGFxFunction( "UserAlertMessage", "IsShowSystemMsgWnd", isShowSystemMsgWndParam);

	if(bool(m_bUseSystemMsgWnd))
	{
		m_hSystemMsgWnd.ShowWindow();
	}
	else
	{
		m_hSystemMsgWnd.HideWindow();
	}

	// 챗 사이즈조절 버튼 표시 여부
	//값이 없으면 기본값을 표시해준다
	if(GetINIBool("global","ChatResizing", tempVal, "chatfilter.ini"))
	{
		m_ChatResizeOnOff = tempVal;
		if(bool(m_ChatResizeOnOff))
		{
			EnableChatWndResizing(false);
		}
		else
		{
			EnableChatWndResizing(true);
		}
	}
	else
	{
		EnableChatWndResizing(true);
	}

	
	/////////////////////////////////////

	HandleIMEStatusChange();	
	GetAllcurrentAssignedChatTypeID();

	//아레나에서 pick 이후 state 변경 전에 onsShow 실행
	//m_chatType.ID 가 -1로 변경 되면서 현재 선택 된 텝을 무시하게 됨.
	if ( GetGameStateName() != "ARENAPICKSTATE" && GetGameStateName() != "ARENAGAMINGSTATE" && GetGameStateName() != "ARENABATTLESTATE") 
	{
		m_chatType.UI = 0;
		m_chatType.ID = -1;
		//Debug ( "m_chatType.ID 바뀜 1 " @ m_chatType.ID );
	}

	//채팅창 불러올때 저장됐던 폰트크기를 불러온다	
	GetINIInt("global","ChatFontSizeSaved", fontSize, "chatfilter.ini");
	SetChangeFont(fontSize);
	
	if(m_UseAlpha == 0)
	{
		SetDefaultAlpha(0);
	}
	else
	{
		SetDefaultAlpha(1);
	}	

	GetCurrentResolution (CurrentMaxWidth, CurrentMaxHeight);	
	//채팅창 크기 기억과 해상도 변경 후 채팅창이 화면 밖에 있는 경우

	isSavedChatSize = GetINIInt("global","ChatSizeWidth", sizeW, "chatfilter.ini");
	isSavedChatSize = GetINIInt("global","ChatSizeHeight", sizeH, "chatfilter.ini") && isSavedChatSize;

	//Debug ( "onShow" @ isSavedChat @ sizeW @ CurrentMaxWidth );
	if ( sizeW < 348 ) sizeW = 348;
	if ( sizeH < 188 ) sizeH = 188;	
	
	if( isSavedChatSize && sizeW <= CurrentMaxWidth && sizeH <= CurrentMaxHeight -15 )
	{   		
		m_hChatWnd.SetWindowSize( sizeW , sizeH);
		ChatEditBox.SetWindowSize(sizeW - 31, m_EditBoxHeight);

		m_hChatWndBottomTex3.SetWindowSize(sizeW-326, 46);

		paramAdd(sizeParam, "w", String(sizeW));
		paramAdd(sizeParam, "h", String(sizeH));
		callGFxFunction( "UserAlertMessage", "ReceiveChatWndSize", sizeParam);
		callGFxFunction( "worldChatBox", "ReceiveChatWndSize", sizeParam);
	}
	else
	{
		m_hChatWnd.SetWindowSize( 348 , 188);
		m_hChatWnd.SetReSizeFrameOffset(348, 188);
		SetINIInt("global","ChatSizeWidth", 348, "chatfilter.ini");		
		SetINIInt("global","ChatSizeHeight", 188, "chatfilter.ini");


		paramAdd(sizeParam, "w", "348");
		paramAdd(sizeParam, "h", "188");
		callGFxFunction( "UserAlertMessage", "ReceiveChatWndSize", sizeParam);
		callGFxFunction( "worldChatBox", "ReceiveChatWndSize", sizeParam);
	}
	m_hChatWnd.SetReSizeFrameOffset(348, 188);
	

	setInit() ;
}

function setInit() 
{
	InitFilterInfo();
//	InitGlobalSetting();

	SetChatfilterBool ( "Global", "EnterChatting", GetChatfilterBool ( "Global", "EnterChatting") ) ;
}


function OnClickButton( String strID )
{
	switch( strID )
	{
	case "ChatTabCtrl0":
	case "ChatTabCtrl1":
	case "ChatTabCtrl2":
	case "ChatTabCtrl3":
	case "ChatTabCtrl4":
		//~ InitScrollBarPosition();
		HandleTabClick(strID);
		break;
	case "ChatFilterBtn":
		CallGFxFunction ( "OptionWnd", "showChattingOption" , "" ) ;
		//if (m_hChatFilterWnd.IsShowWindow())
		//{
		//	m_hChatFilterWnd.HideWindow();
		//}
		//else
		//{
		//	m_hChatFilterWnd.ShowWindow();
		//	SetChatFilterButton();
		//}
		break;
	case "ChatFontOptionBtn":
		if(m_hChatFontsizeWnd.IsShowWindow())
		{
			m_hChatFontsizeWnd.HideWindow();
		}
		else
		{
			m_hChatFontsizeWnd.ShowWindow();
		}
		break;
	default:
		break;
	};
}

function HandlePartyMatchWnd()
{
	local WindowHandle TaskWnd;
	local PartyMatchWnd script;	
	local PartyMatchRoomWnd p2_script;
	p2_script = PartyMatchRoomWnd( GetScript( "PartyMatchRoomWnd" ) );
	script = PartyMatchWnd( GetScript( "PartyMatchWnd" ) );

	
	TaskWnd=GetWindowHandle( "PartyMatchWnd" );

	if (TaskWnd.IsShowWindow())
	{
		ClosePartyMatchingWnd();
	}
	else
	{
		
		TaskWnd=GetWindowHandle("PartyMatchRoomWnd");

		if (TaskWnd.IsShowWindow())
		{
			TaskWnd.HideWindow();
			
			
			TaskWnd=GetWindowHandle("PartyMatchWnd");

			p2_script.OnSendPacketWhenHiding();
			
			
			
			TaskWnd=GetWindowHandle("ChatWnd");

			TaskWnd.SetTimer( 1992, 500 );
		}
		else
		{			
			TaskWnd=GetWindowHandle("PartyMatchWnd");
			//~ TaskWnd.ShowWindow();
			class'PartyMatchAPI'.static.RequestOpenPartyMatch();
			//~ ExecuteCommand("/partymatching");
		}
	}
	//~ ExecuteCommand("/partymatch");
}

function ClosePartyMatchingWnd()
{
	local WindowHandle TaskWnd;
	local PartyMatchWnd p_script;
	p_script = PartyMatchWnd( GetScript( "PartyMatchWnd" ) );	
	
	TaskWnd = GetWindowHandle("PartyMatchWnd");

	TaskWnd.HideWindow();
	p_script.OnSendPacketWhenHiding();
}

function OnTimer(int TimerID)
{
	if(TimerID == 1992)
	{
		ClosePartyMatchingWnd();
		m_hChatWnd.KillTimer(1992); 
	}
}

function OnTabSplit( string sTabButton )
{
	local ChatWindowHandle handle;

	local int outputWidth, outputHeight;

	InitScrollBarPosition();
	
	switch( sTabButton )
	{
		case "ChatTabCtrl0":
			handle = NormalChat;
			HandleTabClick(sTabButton);
			m_IsSplit0 = true;
			break;
		case "ChatTabCtrl1":
			handle = TradeChat;
			HandleTabClick(sTabButton);
			m_IsSplit1 = true;
			break;
		case "ChatTabCtrl2":
			handle = PartyChat;
			HandleTabClick(sTabButton);
			m_IsSplit2 = true;
			break;
		case "ChatTabCtrl3":
			handle = ClanChat;
			HandleTabClick(sTabButton);
			m_IsSplit3 = true;
			break;
		case "ChatTabCtrl4":
			handle = AllyChat;
			HandleTabClick(sTabButton);
			m_IsSplit4 = true;
			break;
		default:
			break;
	};

	if (handle != None)
	{
		handle.SetWindowSizeRel( -1.0f, -1.0f, 0, 0);	//RelativeSize해제
		handle.SetReSizeFrameOffset(343, 139);

		handle.GetWindowSize(outputWidth, outputHeight);
		m_hChatWndBottomTex3.SetWindowSize(outputWidth-326, 46);

		handle.Move(0, 4);
		handle.SetSettledWnd( true );
		handle.EnableTexture( true );

		if(m_UseAlpha == 1)
		{
			handle.SetAlpha(255, 0);
			m_hChatWndBodyTex.SetAlpha(50, 0);
			m_hChatWndHeadTex.SetAlpha(50, 0);
			m_hChatWndBottomTex.SetAlpha(50, 0);
			m_hChatWndBottomTex2.SetAlpha(50, 0);
			m_hChatWndBottomTex3.SetAlpha(50, 0);
			m_hChatWndBottomTex4.SetAlpha(50, 0);
			m_hChatWndBottomTex5.SetAlpha(50, 0);
		}
	}
}

function OnTabMerge( string sTabButton )
{
	local ChatWindowHandle handle;
	local Rect rectWnd;
	InitScrollBarPosition();
	
	switch( sTabButton )
	{
	case "ChatTabCtrl0":
		handle = NormalChat;
		m_IsSplit0 = false;
		break;
	case "ChatTabCtrl1":
		handle = TradeChat;
		m_IsSplit1 = false;
		break;
	case "ChatTabCtrl2":
		handle = PartyChat;
		m_IsSplit2 = false;
		break;
	case "ChatTabCtrl3":
		handle = ClanChat;
		m_IsSplit3 = false;
		break;
	case "ChatTabCtrl4":
		handle = AllyChat;
		m_IsSplit4 = false;
		break;
	default:
		break;
	};

	if (handle != None)
	{
		// TTP 60529 : SetWindowRectRel 혹은 MoveToRel 같은 것이 필요하다.
		//handle.Move(0, -4);
		rectWnd = NormalChat.GetRect();
		handle.MoveTo( rectWnd.nX, rectWnd.nY );

		handle.SetSettledWnd( false );
		handle.SetWindowSizeRel( 1.0f, 1.0f, -5, -49 );
		handle.EnableTexture( false );

		if(m_UseAlpha == 1)
		{
			handle.SetAlpha(255, 0);
			m_hChatWndBodyTex.SetAlpha(255, 0);
			m_hChatWndHeadTex.SetAlpha(255, 0);
			m_hChatWndBottomTex.SetAlpha(255, 0);
			m_hChatWndBottomTex2.SetAlpha(255, 0);
			m_hChatWndBottomTex3.SetAlpha(255, 0);
			m_hChatWndBottomTex4.SetAlpha(255, 0);
			m_hChatWndBottomTex5.SetAlpha(255, 0);
		}
	}
}

function HandleTabClick( string strID )
{
	local string strInput;
	local string strPrefix;
	local int strLen;	
	
	m_chatType.UI = ChatTabCtrl.GetTopIndex();
	m_chatType.ID = GetCurrentChatTypeID(m_chatType.UI);	
	//Debug ( "m_chatType.ID 바뀜 3 " @ m_chatType.ID );
	//SetChatFilterButton();
	InitScrollBarPosition();

	lastClickChatTabName = strID;

	//채팅기호
	if(GetChatFilterBool ( "Global", "OldChatting"))
	{
		//~ debug("Arrange me");
		strInput = ChatEditBox.GetString();
		strLen = Len(strInput);
		//Prefix가 있으면, 제거(일단 길이는 1로 가정한다)
		strPrefix = Left( strInput, 1 );
		if ( IsSameChatPrefix(CHAT_MARKET, strPrefix)
			|| IsSameChatPrefix(CHAT_PARTY, strPrefix)
			|| IsSameChatPrefix(CHAT_CLAN, strPrefix)
			|| IsSameChatPrefix(CHAT_ALLIANCE, strPrefix) 
			|| IsSameChatPrefix(CHAT_HERO, strPrefix) 
			|| IsSameChatPrefix(CHAT_INTER_PARTYMASTER_CHAT, strPrefix) 
			|| IsSameChatPrefix(CHAT_SHOUT, strPrefix) 
			|| IsSameChatPrefix(CHAT_WORLD, strPrefix) //월드채팅 추가
			//~ || IsSameChatPrefix(CHAT_BATTLE, strPrefix) 
			|| IsSameChatPrefix(CHAT_DOMINIONWAR, strPrefix))
		{
			strInput = Right( strInput, strLen-1 );
		}
		//일반탭이 아닌 경우, 변경된 Prefix를 붙여준다.
		//~ if ( m_chatType.ID != CHAT_WINDOW_NORMAL )
		if ( m_chatType.UI != 0 )
		{
				//~ if(GetChatPrefix( Type ) != "~")
			strPrefix = GetChatPrefix(GetChatTypeByTabIndex(m_chatType.ID));
			if (strPrefix != "~")
				strInput = strPrefix $ strInput;
		}
		else
		{
			strPrefix = "";
			strInput = strPrefix $ strInput;
		}
		ChatEditBox.SetString(strInput);
	}
}

function OnEnterState( name a_PrevStateName )
{
	if( a_PrevStateName == 'LoadingState' )			// 게임 중에 다른 스테이트(스페셜카메라 등)으로 갔다가 다시 들어오는 경우는 Clear()를 불러주면 안되기때문에
	{
		Clear();
	}
}

function OnEvent(int Event_ID, String param)
{

	//Debug("chat OnEvent" @ Event_ID @ param );
	switch( Event_ID )
	{
	case EV_ChatMessage:
		//~ debug (param);
		HandleChatMessage( param );
		break;
	case EV_IMEStatusChange:
		HandleIMEStatusChange();
		break;
	case EV_ChatWndStatusChange:
		//HandleChatWndStatusChange();
		break;
	case EV_ChatWndSetFocus:
		HandleSetFocus();
		break;
	case EV_ChatWndSetString:
		HandleSetString( param );
		break;
	/*case EV_ChatWndMsnStatus:
		HandleMsnStatus(param);
		break;*/
	case EV_ChatWndMacroCommand:
		HandleChatWndMacroCommand( param );
		break;
	case EV_TextLinkLButtonClick:
		HandleTextLinkLButtonClick( param );
		break;
	case EV_TextLinkRButtonClick:
		HandleTextLinkRButtonClick(param);
		break;
	case EV_DominionWarChannelSet:
		HandleDominionWarChannelSet( param );
		break;
	case EV_GamingStateEnter:
		// 마지막 선택되었던 채팅탭을 복원
		if(lastClickChatTabName != "")	
		{
			ChatTabCtrl.SetTopOrder(int(Right(lastClickChatTabName, 1)), true);			
			HandleTabClick(lastClickChatTabName);
		}
		break;

	case EV_Restart:
		break;
	case EV_NeedResetUIData:
		//SetChatFilterButton();
		lastClickChatTabName = "";
		ChatTabCtrl.SetTopOrder(0, true);
		HandleTabClick("ChatTabCtrl0");
			
		break;
	case EV_GamingStateExit:
		ChatEditBox.ClearHistory();
		break;
	//진정창, 채팅 url링크 이벤트 리스너(10.1.28 문선준 추가)
	//case EV_UrlLinkClick:
		//linkWebPage( param );
		//break;
	case EV_DialogOK:
		HandleDialogOK();
		break;
	case EV_DialogCancel:
		break;
	case EV_ChatWndOnResize:
		UpdateSize(param);
		break;
	case EV_ResolutionChanged:	
		UpdateResolution();
		break;	
	case EV_ChangedSubjob : handleChangedSubjob( param ); break;

	default:
		break;
	}
}

// 프롤로그 전직 
function handleChangedSubjob ( String param ) 
{	
	local bool isPrologueGrowType ; 
	local int currentClassID;
	
	if ( param != "" )  ParseInt(param, "CurrentSubjobClassID", currentClassID) ;	

	isPrologueGrowType = getInstanceL2Util().getIsPrologueGrowType( currentClassID ) 	;

	ChatTabCtrl.SetDisable( CHAT_WINDOW_TRADE , isPrologueGrowType) ;
	ChatTabCtrl.SetDisable( CHAT_WINDOW_PARTY, isPrologueGrowType) ;
	ChatTabCtrl.SetDisable( CHAT_WINDOW_CLAN , isPrologueGrowType) ;
	ChatTabCtrl.SetDisable( CHAT_WINDOW_ALLY , isPrologueGrowType) ;

	if(isPrologueGrowType) // 발터스기사단이 아닌 게임내에서 클래스 변경시에는 채팅탭을 변경하지 않도록한다.
		ChatTabCtrl.SetTopOrder(0, true);			
}

//채팅 창 높이도 창 밖으로 나올 경우 최소화 시킴
function UpdateResolution()
{
	local int CurrentMaxWidth, CurrentMaxHeight, CurrentChatWidth, CurrentChatHeight, CurrentEditBoxWidth, CurrentEditBoxHeight;
	local bool isFixedW, isFixedH;

	GetCurrentResolution (CurrentMaxWidth, CurrentMaxHeight);
	
	m_hChatWnd.GetWindowSize(CurrentChatWidth, CurrentChatHeight);	

	isFixedW = CurrentChatWidth > CurrentMaxWidth;
	isFixedH = CurrentChatHeight > CurrentMaxHeight -15;

	if( isFixedW || isFixedH )
	{
		
		m_hChatWnd.SetWindowSize( 348 , 188);
		m_hChatWnd.SetReSizeFrameOffset(348, 188);		
		ChatEditBox.GetWindowSize(CurrentEditBoxWidth, CurrentEditBoxHeight);	
		ChatEditBox.SetWindowSize(348 - 31, CurrentEditBoxHeight);

		SetINIInt("global","ChatSizeWidth", 348, "chatfilter.ini");
		SetINIInt("global","ChatSizeHeight", 188, "chatfilter.ini");

		OnDefaultPosition();
	}
}

function UpdateSize(string param)
{	
	local int w, h;
	local int resizeWidth, resizeHeight;
	local string wName, sizeParam;

	//Debug ( "UpdateSize" @ param);

	parseInt(param, "Width", resizeWidth);
	parseInt(param, "Height", resizeHeight);
	parseString(param, "WindowName", wName);
	ChatEditBox.GetWindowSize(w, h);	
	ChatEditBox.SetWindowSize(resizeWidth - 31, h);

	m_hChatWndBottomTex3.SetWindowSize( resizeWidth - 326 , 46);
	
	ParamAdd(sizeParam, "w", String(resizeWidth));
	ParamAdd(sizeParam, "h", String(resizeHeight));
	callGFxFunction( "UserAlertMessage", "ReceiveChatWndSize", sizeParam);
	callGFxFunction( "worldChatBox", "ReceiveChatWndSize", sizeParam);

	if(wName == "ChatWnd")
	{
		SetINIInt("global","ChatSizeWidth", resizeWidth, "chatfilter.ini");		
		SetINIInt("global","ChatSizeHeight", resizeHeight, "chatfilter.ini");	
	}
}

//홈페이지 링크(10.1.28 문선준 추가)
function HandleDialogOK()
{
	if( !DialogIsMine() )
		return;

	switch( DialogGetID() )
	{
	case DIALOGID_GoWeb:
		OpenGivenURL( Url );
		break;
	}
}

//function linkWebPage( string param )
//{	
//	if ( !ParseString(param, "Url", Url) )
//	return;

//	if ( !ParseString(param, "Text", Text) )
//	{
//		Text = "";
//	}

//	DialogHide();
//	DialogSetID( DIALOGID_GoWeb );
//	if( Text != "" )
//	{
//		DialogShow( DialogModalType_Modalless, DialogType_OKCancel, MakeFullSystemMsg( GetSystemMessage( 3211 ) , Text, "" ), string(Self) );
//	}
//	else
//	{
//		if( Url == GetSystemString( 2265 ) )
//		{
//			DialogShow( DialogModalType_Modalless, DialogType_OKCancel, MakeFullSystemMsg( GetSystemMessage( 3211 ) , GetSystemString( 2259 ), "" ), string(Self) );
//		}
//		else if( Url == GetSystemString( 2266 ) )
//		{
//			DialogShow( DialogModalType_Modalless, DialogType_OKCancel, MakeFullSystemMsg( GetSystemMessage( 3211 ) , GetSystemString( 2261 ), "" ), string(Self) );
//		}
//		else if( Url == GetSystemString( 2267 ) )
//		{
//			DialogShow( DialogModalType_Modalless, DialogType_OKCancel, MakeFullSystemMsg( GetSystemMessage( 3211 ) , GetSystemString( 2263 ), "" ), string(Self) );
//		}
//		else if( Url == GetSystemString( 2762 ) )//파워북 링크 
//		{
//			DialogShow( DialogModalType_Modalless, DialogType_OKCancel, MakeFullSystemMsg( GetSystemMessage( 3211 ) , GetSystemString( 2760 ), "" ), string(Self) );
//		}		
//		else if( Url == GetSystemString( 2775 ) ) //멘토링(가이드) 링크 
//		{
//			// 2773: 멘토링 가이드
//			DialogShow( DialogModalType_Modalless, DialogType_OKCancel, MakeFullSystemMsg( GetSystemMessage( 3211 ) , GetSystemString( 2773 ), "" ), string(Self) );
//		}		
//		else 
//		{
//			if (Url != "")
//			{
//				// 901 : 정보
//				//DialogShow( DialogModalType_Modalless, DialogType_OKCancel, MakeFullSystemMsg( GetSystemMessage( 3211 ) , GetSystemString( 901 ), "" ), string(Self) );
//				DialogShow( DialogModalType_Modalless, DialogType_OKCancel, MakeFullSystemMsg( GetSystemMessage( 3211 ) , GetSystemString( 901 ), "" ), string(Self) );
//			}   
//		}
//	}
//}

//매크로커맨드의 실행, UC의 ChatType에 맞게 실행되어야한다.
function HandleChatWndMacroCommand( string param )
{
	local string Command;
	
	if (!ParseString(param, "Command", Command))
		return;
		
	ProcessChatMessage( Command, m_chatType.ID, false );
}

function HandleChatmessage( String param )
{
	local int				nTmp;
	local EChatType		    type;
	local ESystemMsgType	systemType;
	local string			text;
	local string			origText;
	local string			userIDString;
	local string			worldChatMsg;
	local Color			    color;
	local  int 			    foundID;
	local SystemMsgData	    SysMsgData;
	local int               SysMsgIndex;
	local int               relationType;
	local int               targetLevel;

	local int SayType;
//	local int tempVal;
	//~ debug(param);
	ParseInt(param, "Type", nTmp);
	type = EChatType(nTmp);
	SayType=nTmp;

	ParseString(param, "Msg", origText);

	//Debug("----->" @ param );
	 
	// 시스템 메시지일때는 스크립트의 색상을 사용 - lancelot 2008. 8. 18.	
	if(type==CHAT_SYSTEM)
	{
		ParseInt(param, "SysMsgIndex", SysMsgIndex);
		if(SysMsgIndex==-1)
		{
			Color=GetChatColorByType(SayType);		// 시스템 메시지는 5
		}
		// 표시 하지 말아야 할 시스템 메시지 
		// ex 1. 아가시온 서브 스킬 장착 시 소환 안됨 메시지
		else if ( SysMsgIndex == 4700 ) 
		{
			return;
		}
		else
		{
			GetSystemMsgInfo(SysMsgIndex, SysMsgData);
			color=SysMsgData.FontColor;
		}
		
	
		ParseInt(param, "SysType", nTmp);	
		systemType = ESystemMsgType(nTmp);
		
		// 클라이언트 디버깅 메세지 - lancelot 2010. 8. 2.
		if( systemType==SYSTEM_CLIENT_DEBUG_MSG )
		{
			color.R=62;
			color.G=239;
			color.B=10;
		}
	}
	else
	{
		Color=GetChatColorByType(SayType);
		
		systemType = SYSTEM_NONE;
	}
	
	text = origText;

	//귓속말이 올 때 UserAlertMessage UI로 메시지를 보낸다.
	if(type == 2)
	{
		ParseString(text, "Title", userIDString);
		ParseInt(param, "Relation", relationType);
		ParseInt(param, "Level", targetLevel);
		
		if(Right( Left(userIDString, 2), 1 ) != "-")
		{
			//callGFxFunction( "UserAlertMessage", "UserRelationType", string(relationType));
			callGFxFunction( "UserAlertMessage", "WhisperMessage", "Title="$userIDString$" RelationType="$string(relationType)$" Level="$string(targetLevel));
		}
	}

	/*
	 *월드 채팅 글씨를 따로 보여줌
	 */	
	if(type == CHAT_WORLD)
	{
		//사용하는 상태일때만
		

		//if(GetINIBool( "global", "UseWorldChatSpeaker", tempVal, "chatfilter.ini" ))
		//{

		if(m_bWorldChatSpeaker == 1)
		{
			ParseString(param, "FilteredMsg", worldChatMsg);				
			callGFxFunction( "worldChatBox", "WorldChatMessage", "Msg="$worldChatMsg);
		}

		//}


		//if(GetINIBool( "global", "UseWorldChatSpeaker", tempVal, "chatfilter.ini" ))
		//{
		//	if(tempVal == 1)
		//	{
		//		ParseString(param, "FilteredMsg", worldChatMsg);				
		//		callGFxFunction( "worldChatBox", "WorldChatMessage", "Msg="$worldChatMsg);
		//	}
		//}
	}


	if (m_KeywordFilterActivate == 1)
		foundID = 	ChatNotificationFilter(text, origText, m_Keyword0, m_Keyword1, m_Keyword2, m_Keyword3);	
	//~ debug ("현재 채팅 타입" @ m_chatType.ID @ m_chatType.UI @ type);
	if( CheckFilter( type, 0, systemType ))
	{
		//~ switch (m_chatType.UI) 
		NormalChat.AddStringToChatWindow( text, color );
		//~ debug("Add String Goes Here" @ Type @ systemType);
		if (foundID > 0 && m_KeywordFilterSound == 1 && ChatTabCtrl.GetTopIndex()== 0)
			PlaySound("ItemSound3.Sys_Chat_Keyword");
	}

	if( CheckFilter( type, m_ChatUI[1].ID, systemType ) )
	{	
		TradeChat.AddStringToChatWindow( text, color );
		//~ debug("Add String Goes Here" @ Type @ systemType);
		if (foundID > 0 && m_KeywordFilterSound == 1 && ChatTabCtrl.GetTopIndex()== 1)
			PlaySound("ItemSound3.Sys_Chat_Keyword");
	}

	if( CheckFilter( type, m_ChatUI[2].ID, systemType ))
	{
		PartyChat.AddStringToChatWindow( text, color );
		//~ debug("Add String Goes Here" @ Type @ systemType);
		//~ debug(text @ color.r @ color.g @color.b);
		if (foundID > 0 && m_KeywordFilterSound == 1 && ChatTabCtrl.GetTopIndex()== 2)
			PlaySound("ItemSound3.Sys_Chat_Keyword");
	}
	
	if( CheckFilter( type, m_ChatUI[3].ID, systemType ) )
	{
		ClanChat.AddStringToChatWindow( text, color );
		//~ debug("Add String Goes Here" @ Type @ systemType);
		if (foundID > 0 && m_KeywordFilterSound == 1 && ChatTabCtrl.GetTopIndex()== 3)
			PlaySound("ItemSound3.Sys_Chat_Keyword");
	}
	
	if( CheckFilter( type, m_ChatUI[4].ID, systemType) )
	{	
		AllyChat.AddStringToChatWindow( text, color );
		//~ debug("Add String Goes Here" @ Type @ systemType);
		if (foundID > 0 && m_KeywordFilterSound == 1 && ChatTabCtrl.GetTopIndex()== 4)
			PlaySound("ItemSound3.Sys_Chat_Keyword");
	}
	
	if( CheckFilter( type, 9, systemType ) )
	{
		SystemMsg.AddStringToChatWindow( text, color );
		//~ debug("Add String Goes Here" @ Type @ systemType);
		if (foundID > 0 && m_KeywordFilterSound == 1 )
			PlaySound("ItemSound3.Sys_Chat_Keyword");
	}

	//Union Commander Message 연합사령관 메시지
	if ( type == CHAT_COMMANDER_CHAT ) //&& m_NoUnionCommanderMessage != 0 )
	{
		if (foundID > 0 && m_KeywordFilterSound == 1 )
			PlaySound("ItemSound3.Sys_Chat_Keyword");

		ParseString(param, "FilteredMsg", origText);
		ShowUnionCommanderMessgage( origText );
	}
	if ( type == CHAT_SCREEN_ANNOUNCE )
	{	
		if (foundID > 0 && m_KeywordFilterSound == 1 )
			PlaySound("ItemSound3.Sys_Chat_Keyword");

		color.R=0;
		color.G=255;
		color.B=255;
		
		NormalChat.AddStringToChatWindow( text, color );
		TradeChat.AddStringToChatWindow( text, color );
		PartyChat.AddStringToChatWindow( text, color );
		ClanChat.AddStringToChatWindow( text, color );
		AllyChat.AddStringToChatWindow( text, color );
		//20120314 오른쪽하단 스크린메시지 삭제.
		//ShowAnnounceMessgage( text );
	}

	// 아레나 채팅 윈도우
	if ( chkArenaChatting ( type ) ) showGfxChattingMessage (param );
}


function showGfxChattingMessage ( string param )  
{
	local string FilteredMsg, color ;
	//local int color
	
	ParseString(param, "FilteredMsg", FilteredMsg);
	ParseString(param, "color", color);
	param = "";	
	ParamAdd(param, "Msg", FilteredMsg);
	ParamAdd(param, "type", String ( getInstanceL2Util().EGfxScreenMsgType.MSGType_Chatting ));
	ParamAdd(param, "textColor", color ) ;
	CallGFxFunction ( "GfxScreenMessage" , "showMessage", param );
}
	//CHAT_NORMAL,
	//CHAT_SHOUT,		// '!'
	//CHAT_TELL,		// '\'
	//CHAT_PARTY,		// '#'
	//CHAT_CLAN,		// '@'
	//CHAT_SYSTEM,		// ''
	//CHAT_USER_PET,	// '&'
	//CHAT_GM_PET,		// '*'
	//CHAT_MARKET,		// '+'
	//CHAT_ALLIANCE,	// '%'	
	//CHAT_ANNOUNCE,	// ''
	//CHAT_CUSTOM,		// ''
	//CHAT_L2_FRIEND,	// ''
	//CHAT_MSN_CHAT,	// ''
	//CHAT_PARTY_ROOM_CHAT,	// ''		14
	//CHAT_COMMANDER_CHAT,				// 15
	//CHAT_INTER_PARTYMASTER_CHAT,
	//CHAT_HERO,
	//CHAT_CRITICAL_ANNOUNCE,
	//CHAT_SCREEN_ANNOUNCE,
	//CHAT_DOMINIONWAR,					// 20
	//CHAT_MPCC_ROOM,
	//CHAT_NPC_NORMAL,		// NPC 대사 필터링 - 2010.9.8 winkey
	//CHAT_NPC_SHOUT,
	//CHAT_FRIEND_ANNOUNCE,
	//CHAT_WORLD,
function bool chkArenaChatting ( EChatType type ) 
{
	return  ( getInstanceUIData().getIsArenaServer() && 
			( 	type == CHAT_NORMAL ||
				type == CHAT_SHOUT ||  
				type == CHAT_TELL ||  
				type == CHAT_PARTY || 
				type == CHAT_CLAN ||  
				type == CHAT_ALLIANCE ||  
				type == CHAT_COMMANDER_CHAT || 
				type == CHAT_HERO ||  
				type == CHAT_WORLD ||
				type == CHAT_MARKET));
}


function string InsertSHARPText( string Msg )
{
	local string MsgTemp;
	local string MsgTemp2;
	local int    maxlength;	
	local int    i;
	local int    maxSharpNum;

	maxlength = Len(Msg);
	maxSharpNum = 0;	

	while (maxlength > CHAT_UNION_MAX  * (maxSharpNum + 1))
	{		
		maxSharpNum ++ 	;
	}	

	for (i = 0 ; i < maxSharpNum ; i++ )
	{		
		maxlength = Len(Msg);
		MsgTemp  = Left (Msg, CHAT_UNION_MAX * (i+1) + i);//# 글자가 하나씩 늘어나므로 i를 더해 줌, 
		MsgTemp2 = Right(Msg, maxlength -( CHAT_UNION_MAX * (i+1) + i )); //# 글자가 하나씩 늘어나므로... 상동
		Msg = MsgTemp $"#"$ MsgTemp2 ;
		//Debug ( "InsertSHARPText"$i @ maxlength @ CHAT_UNION_MAX * i @  "MsgTemp2:"$MsgTemp2);		
	}
	
	
	return Msg;
}


function ShowUnionCommanderMessgage(string Msg)
{
	local string strParam;
	//local string MsgTemp;
	//local string MsgTemp2;
	//local int maxlength;

	//local int i ;
	
	Msg = InsertSHARPText(Msg);
	//Debug("ShowUnionCommanderMessgage"@Msg);
	/*maxlength = Len(Msg);
	
	
	for ( i = 1 ; i < InsertSHARPTextMaxNum ; i++)
	{
		if (maxlength > CHAT_UNION_MAX * i )
		{		
			MsgTemp = Left(Msg, CHAT_UNION_MAX);
			MsgTemp2 = Right(Msg, maxlength - CHAT_UNION_MAX);
			Msg = MsgTemp $"#"$ MsgTemp2 ;		
		}
	}
*/

	//~ debug (Msg);

	if (Len(Msg)>0)
	{
		
		ParamAdd(strParam, "MsgType", String(1));
		ParamAdd(strParam, "WindowType", String(8));
		ParamAdd(strParam, "FontType", String(0));
		ParamAdd(strParam, "BackgroundType",String(0));
		ParamAdd(strParam, "LifeTime", String(5000));
		ParamAdd(strParam, "AnimationType", String(1));
		ParamAdd(strParam, "Msg", Msg);
		ParamAdd(strParam, "MsgColorR", String(255));
		ParamAdd(strParam, "MsgColorG", String(150));
		ParamAdd(strParam, "MsgColorB", String(149));
		ExecuteEvent(EV_ShowScreenMessage, strParam);
	}
}

function ShowAnnounceMessgage(string Msg)
{
	local string strParam;
	//local string MsgTemp;
	//local string MsgTemp2;
	//local int maxlength;
	
		Msg = InsertSHARPText(Msg);
	//Debug("ShowAnnounceMessgage"@Msg);
	/*
	maxlength = Len(Msg);
	
	
	if (maxlength > CHAT_UNION_MAX)
	{
		
		MsgTemp = Left(Msg, CHAT_UNION_MAX);
		MsgTemp2 = Right(Msg, maxlength - CHAT_UNION_MAX);
		Msg = MsgTemp $"#"$ MsgTemp2 ;
		
		
	}
*/

	//~ debug (Msg);

	if (Len(Msg)>0)
	{
		
		ParamAdd(strParam, "MsgType", String(1));
		ParamAdd(strParam, "WindowType", String(8));
		ParamAdd(strParam, "FontType", String(1));
		ParamAdd(strParam, "BackgroundType",String(0));
		ParamAdd(strParam, "LifeTime", String(5000));
		ParamAdd(strParam, "AnimationType", String(1));
		ParamAdd(strParam, "Msg", Msg);
		ParamAdd(strParam, "MsgColorR", String(255));
		ParamAdd(strParam, "MsgColorG", String(150));
		ParamAdd(strParam, "MsgColorB", String(149));
		ExecuteEvent(EV_ShowScreenMessage, strParam);
	}
}


function HandleIMEStatusChange()
{
	local string texture;
	local EIMEType imeType;
	imeType = GetCurrentIMELang();
	switch( imeType )
	{
	case IME_KOR:
		texture = "L2UI_CH3.ChatWnd.Chatting_IMEkr";
		break;
	case IME_ENG:
		texture = "L2UI_CH3.ChatWnd.Chatting_IMEen";
		break;
	case IME_JPN:
		texture = "L2UI_CH3.ChatWnd.Chatting_IMEjp";
		break;
	case IME_CHN:
		texture = "L2UI_CH3.ChatWnd.Chatting_IMEjp";
		break;
	case IME_TAIWAN_CHANGJIE:
		texture = "L2UI.ChatWnd.IME_tw2";
		break;
	case IME_TAIWAN_DAYI:
		texture = "L2UI.ChatWnd.IME_tw3";
		break;
	case IME_TAIWAN_NEWPHONETIC:
		texture = "L2UI.ChatWnd.IME_tw1";
		break;
	case IME_CHN_MS:
		texture = "L2UI.ChatWnd.IME_cn1";
		break;
	case IME_CHN_JB:
		texture = "L2UI.ChatWnd.IME_cn2";
		break;
	case IME_CHN_ABC:
		texture = "L2UI.ChatWnd.IME_cn3";
		break;
	case IME_CHN_WUBI:
		texture = "L2UI.ChatWnd.IME_cn4";
		break;
	case IME_CHN_WUBI2:
		texture = "L2UI.ChatWnd.IME_cn4";
		break;
	case IME_THAI:
		texture = "L2UI.ChatWnd.IME_th";
		break;
	//branch
	case IME_RUSSIA:
		texture = "BranchSys.symbol.IME_ru";
		break;
	//end of branch
	default:
		texture = "L2UI_CH3.ChatWnd.Chatting_IMEen";
		break;
	};

	m_hChatWndLanguageTexture.SetTexture(texture);
}

function bool CheckFilter( EChatType type, int windowType, ESystemMsgType systemType )		// systemType은 CHAT_SYSTEM일 경우만 넘겨주면된다
{
	//	local int tempVal;
	local int tempVal;

	// Debug("---CheckFilter windowType: " @ windowType);
	
	if (( type == CHAT_NPC_NORMAL || type == CHAT_NPC_SHOUT ))
	{
		// Debug(" type!!! " @ string(type) ); 
		// Debug(" windowType!!! " @ windowType );
		// Debug(" 대화야!!! " @ m_filterInfo[windowType].bNoNpcMessage );
	}

	if( !( windowType >= 0 && windowType < CHAT_WINDOW_COUNT ) && windowType != CHAT_WINDOW_SYSTEM )
	{
		return false;
	}

	if( type == CHAT_MARKET && m_filterInfo[windowtype].bTrade != 0)
	{
		return true;
	}
	else if( type == CHAT_NORMAL && m_filterInfo[windowType].bNormal != 0 )
	{
		return true;
	}
	else if( type == CHAT_CLAN && m_filterInfo[windowType].bClan != 0 )
	{
		return true;
	}
	else if( type == CHAT_PARTY && m_filterInfo[windowType].bParty != 0 )
	{
		return true;
	}
	else if( type == CHAT_SHOUT && m_filterInfo[windowType].bShout != 0 )
	{
		return true;
	}
	else if( type == CHAT_TELL && m_filterInfo[windowType].bWhisper != 0 )
	{
		return true;
	}
	else if( type == CHAT_ALLIANCE && m_filterInfo[windowType].bAlly != 0 )
	{
		return true;
	}
	else if( type == CHAT_HERO && m_filterInfo[windowType].bHero != 0 )
	{
		return true;	
	}
	else if( type == CHAT_DOMINIONWAR  && m_filterInfo[windowType].bBattle != 0 )
	{
		return true;
	}
	else if( type == CHAT_ANNOUNCE || type == CHAT_CRITICAL_ANNOUNCE || type == CHAT_GM_PET )
	{
		return true;
	}
	else if( ( type == CHAT_INTER_PARTYMASTER_CHAT || type == CHAT_COMMANDER_CHAT ) && m_filterInfo[windowType].bUnion != 0 )
	{	
		return true;
	}
	else if( type == CHAT_SYSTEM )
	{
		if( systemType == SYSTEM_SERVER || systemType == SYSTEM_PETITION )
			return true;
		else if( windowType == CHAT_WINDOW_SYSTEM )			// 시스템 메시지 창이면 옵션을 보고
		{
			//GetINIBool( "global", "UseSystemMsg", tempVal, "chatfilter.ini" );
			tempVal = m_bSystemMsgWnd;
			if( bool(tempVal) )
			{
				if( systemType == SYSTEM_BATTLE || systemType == SYSTEM_NONE || systemType == SYSTEM_DAMAGETEXT )
					return true;
			}	
			//GetINIBool( "global", "SystemMsgWndDamage", tempVal, "chatfilter.ini" );
			tempVal = m_bDamageOption;
			if( bool(tempVal) )
			{
				if( systemType == SYSTEM_DAMAGE || systemType == SYSTEM_DAMAGETEXT )
				{
					return true;
				}
			}
			//GetINIBool( "global", "SystemMsgWndExpendableItem", tempVal, "chatfilter.ini" );
			tempVal = m_bUseSystemItem;
			if( bool(tempVal) )
			{
				if( systemType == SYSTEM_USEITEMS )
				{
					return true;
				}
			}
			return false;
		}
		else if( m_filterInfo[windowType].bSystem != 0 )
		{
			//GetINIBool( "global", "OnlyUseSystemMsgWnd", tempVal, "chatfilter.ini" );
			tempVal = m_bOnlyUseSystemMsgWnd;
			if ( !bool( tempVal ) )
				if( systemType == SYSTEM_BATTLE || systemType == SYSTEM_NONE || systemType == SYSTEM_DAMAGETEXT)
					return true;
		}
		//시스템 메시지 하위 체크박스( 데미지텍스트, 소모성아이템 개별 작동 필터링 추가 )
		if( m_filterInfo[windowType].bDamage != 0 )
		{
			//GetINIBool( "global", "OnlyUseSystemMsgWnd", tempVal, "chatfilter.ini" );
			tempVal = m_bOnlyUseSystemMsgWnd;
			if ( !bool( tempVal ) )
				if( systemType == SYSTEM_DAMAGE || systemType == SYSTEM_DAMAGETEXT )
					return true;
		}
		if( m_filterInfo[windowType].bUseItem != 0 )
		{
			//GetINIBool( "global", "OnlyUseSystemMsgWnd", tempVal, "chatfilter.ini" );
			tempVal = m_bOnlyUseSystemMsgWnd;
			if ( !bool( tempVal ) )
				if( systemType == SYSTEM_USEITEMS )
					return true;			
		}
		/////////////////////////////////////////////////////////////////////////////////////
		return false;
	}
	else if( ( type == CHAT_NPC_NORMAL || type == CHAT_NPC_SHOUT ) && m_filterInfo[windowType].bNoNpcMessage != 0)// m_NoNpcMessage == 0 )	// NPC 대사 필터링 - 2010.9.8 winkey
	{
		// Debug("npc 대화야!!! " @ m_filterInfo[windowType].bNoNpcMessage );
		return true;
	}
	else if( type == CHAT_FRIEND_ANNOUNCE)
	{	
		return true;
	}
	//월드 채팅 필터링
	else if( type == CHAT_WORLD && m_filterInfo[windowType].bWorldChat != 0 && windowType != 9)
	{	
		return true;
	}
	return false;
}

// init with chatfilter.ini
function InitFilterInfo()
{
	local int i;
	local int tempVal;
	local string tempstring;
	
	SetDefaultFilterValue();
	for( i=0; i < CHAT_WINDOW_COUNT ; ++i )
	{
		if( GetINIBool( m_sectionName[i], "system", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bSystem = tempVal;

		if( GetINIBool( m_sectionName[i], "chat", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bChat = tempVal;
		
		if( GetINIBool( m_sectionName[i], "normal", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bNormal = tempVal;
		
		if( GetINIBool( m_sectionName[i], "shout", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bShout = tempVal;
		
		if( GetINIBool( m_sectionName[i], "pledge", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bClan = tempVal;
		
		if( GetINIBool( m_sectionName[i], "party", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bParty = tempVal;
		
		if( GetINIBool( m_sectionName[i], "market", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bTrade = tempVal;
		
		if( GetINIBool( m_sectionName[i], "tell", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bWhisper = tempVal;
		
		if( GetINIBool( m_sectionName[i], "damage", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bDamage = tempVal;
		
		if( GetINIBool( m_sectionName[i], "ally", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bAlly = tempVal;
		
		if( GetINIBool( m_sectionName[i], "useitems", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bUseItem = tempVal;
		
		if( GetINIBool( m_sectionName[i], "hero", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bHero = tempVal;
			
		if( GetINIBool( m_sectionName[i], "union", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bUnion = tempVal;
		
		if( GetINIBool( m_sectionName[i], "battle", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bBattle = tempVal;

		if( GetINIBool( m_sectionName[i], "nonpcmessage", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bNoNpcMessage = tempVal;

		//월드채팅 추가
		if( GetINIBool( m_sectionName[i], "worldChat", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bWorldChat = tempVal;
		

	}
	
	// 기존의 잘못된 INI를 가진 유저들을 위해 기본 값을 항상 리셋한다. 
	SetDefaultFilterOn();

	m_UseChatSymbol = int ( GetChatFilterBool ( "Global", "OldChatting") );	
	//m_UseChatSymbol = int(GetOptionBool( "CommunIcation", "OldChatting" ));
	
	//월드 채팅 스피커
	if( GetINIBool( "global", "UseWorldChatSpeaker", tempVal, "chatfilter.ini" ) )
		m_bWorldChatSpeaker = tempVal;

	//Global Setting
	//if( GetINIBool( "global", "command", tempVal, "chatfilter.ini" ) )
	//	m_NoUnionCommanderMessage = tempVal;

	//if( GetINIBool( "global", "npc", tempVal, "chatfilter.ini" ) )	// NPC 대사 필터링 - 2010.9.8 winkey
	//	m_NoNpcMessage = tempVal;
	
	if ( GetINIBool("global", "UseAlpha", tempVal, "chatfilter.ini") )
		m_UseAlpha = tempVal;	
	
	if( GetINIBool( "global", "keywordsound", tempVal, "chatfilter.ini" ) )
		m_KeywordFilterSound = tempVal;
	
	if( GetINIBool( "global", "keywordactivate", tempVal, "chatfilter.ini" ) )
		m_KeywordFilterActivate = tempVal;
	
	if ( GetINIString("global", "Keyword0", tempstring, "chatfilter.ini") )
		m_Keyword0 = tempstring;
	
	if ( GetINIString("global", "Keyword1", tempstring, "chatfilter.ini") )
		m_Keyword1 = tempstring;
	
	if ( GetINIString("global", "Keyword2", tempstring, "chatfilter.ini") )
		m_Keyword2 = tempstring;
	
	if ( GetINIString("global", "Keyword3", tempstring, "chatfilter.ini") )
		m_Keyword3 = tempstring;
	
	if( GetINIBool( "global", "SystemMsgWnd", tempVal, "chatfilter.ini" ))
		m_bUseSystemMsgWnd = tempVal;
	
	if(GetINIBool( "global", "UseSystemMsg", tempVal, "chatfilter.ini" ))
		m_bSystemMsgWnd = tempVal;
	
	if(GetINIBool( "global", "SystemMsgWndDamage", tempVal, "chatfilter.ini" ))
		m_bDamageOption = tempVal;

	if(GetINIBool( "global", "SystemMsgWndExpendableItem", tempVal, "chatfilter.ini" ))
		m_bUseSystemItem = tempVal;
	
	if(GetINIBool( "global", "OnlyUseSystemMsgWnd", tempVal, "chatfilter.ini" ))
		m_bOnlyUseSystemMsgWnd = tempVal;	
}


function SetDefaultFilterOn()
{
	m_filterInfo[ CHAT_WINDOW_TRADE ].bTrade = 1;
	m_filterInfo[ CHAT_WINDOW_PARTY ].bParty = 1;
	m_filterInfo[ CHAT_WINDOW_CLAN ].bClan = 1;
	m_filterInfo[ CHAT_WINDOW_ALLY ].bAlly = 1;
}

//콤보박스별 초기화 < 추가 됨>
function SetCurrentDefaultFilterValue(int type)
{
	switch(type)
	{
		case 0:
			m_filterInfo[ 0 ].bSystem = 1;
			m_filterInfo[ 0 ].bChat = 1;
			m_filterInfo[ 0 ].bNormal = 1;
			m_filterInfo[ 0 ].bShout = 1;
			m_filterInfo[ 0 ].bClan = 1;
			m_filterInfo[ 0 ].bParty = 1;
			m_filterInfo[ 0 ].bTrade = 0;
			m_filterInfo[ 0 ].bWhisper = 1;
			m_filterInfo[ 0 ].bDamage = 1;
			m_filterInfo[ 0 ].bAlly = 0;
			m_filterInfo[ 0 ].bUseItem = 0;
			m_filterInfo[ 0 ].bHero = 0;
			m_filterInfo[ 0 ].bUnion = 1;
			m_filterInfo[ 0 ].bBattle = 1;
			m_filterInfo[ 0 ].bNoNpcMessage = 0;
			//월드 채팅 추가
			m_filterInfo[ 0 ].bWorldChat = 1;
		break;
		case 1:
			m_filterInfo[ 1 ].bSystem = 1;
			m_filterInfo[ 1 ].bChat = 1;
			m_filterInfo[ 1 ].bNormal = 0;
			m_filterInfo[ 1 ].bShout = 1;
			m_filterInfo[ 1 ].bClan = 0;
			m_filterInfo[ 1 ].bParty = 0;
			m_filterInfo[ 1 ].bTrade = 1;
			m_filterInfo[ 1 ].bWhisper = 1;
			m_filterInfo[ 1 ].bDamage = 1;
			m_filterInfo[ 1 ].bAlly = 0;
			m_filterInfo[ 1 ].bUseItem = 0;
			m_filterInfo[ 1 ].bHero = 0;
			m_filterInfo[ 1 ].bUnion = 1;
			m_filterInfo[ 1 ].bBattle = 0;
			m_filterInfo[ 1 ].bNoNpcMessage = 0;
			m_filterInfo[ 1 ].bWorldChat = 0;
		break;
		case 2:
			m_filterInfo[ 2 ].bSystem = 1;
			m_filterInfo[ 2 ].bChat = 1;
			m_filterInfo[ 2 ].bNormal = 0;
			m_filterInfo[ 2 ].bShout = 1;
			m_filterInfo[ 2 ].bClan = 0;
			m_filterInfo[ 2 ].bParty = 1;
			m_filterInfo[ 2 ].bTrade = 0;
			m_filterInfo[ 2 ].bWhisper = 1;
			m_filterInfo[ 2 ].bDamage = 1;
			m_filterInfo[ 2 ].bAlly = 0;
			m_filterInfo[ 2 ].bUseItem = 0;
			m_filterInfo[ 2 ].bHero = 0;
			m_filterInfo[ 2 ].bUnion = 1;
			m_filterInfo[ 2 ].bBattle = 0;
			m_filterInfo[ 2 ].bNoNpcMessage = 0;
			m_filterInfo[ 2 ].bWorldChat = 0;
		break;
		case 3:
			m_filterInfo[ 3 ].bSystem = 1;
			m_filterInfo[ 3 ].bChat = 1;
			m_filterInfo[ 3 ].bNormal = 0;
			m_filterInfo[ 3 ].bShout = 1;
			m_filterInfo[ 3 ].bClan = 1;
			m_filterInfo[ 3 ].bParty = 0;
			m_filterInfo[ 3 ].bTrade = 0;
			m_filterInfo[ 3 ].bWhisper = 1;
			m_filterInfo[ 3 ].bDamage = 1;
			m_filterInfo[ 3 ].bAlly = 0;
			m_filterInfo[ 3 ].bUseItem = 0;
			m_filterInfo[ 3 ].bHero = 0;
			m_filterInfo[ 3 ].bUnion = 1;
			m_filterInfo[ 3 ].bBattle = 0;
			m_filterInfo[ 3 ].bNoNpcMessage = 0;
			m_filterInfo[ 3 ].bWorldChat = 0;
		break;
		case 4:
			m_filterInfo[ 4 ].bSystem = 1;
			m_filterInfo[ 4 ].bChat = 1;
			m_filterInfo[ 4 ].bNormal = 0;
			m_filterInfo[ 4 ].bShout = 1;
			m_filterInfo[ 4 ].bClan = 0;
			m_filterInfo[ 4 ].bParty = 0;
			m_filterInfo[ 4 ].bTrade = 0;
			m_filterInfo[ 4 ].bWhisper = 1;
			m_filterInfo[ 4 ].bDamage = 1;
			m_filterInfo[ 4 ].bAlly = 1;
			m_filterInfo[ 4 ].bUseItem = 0;
			m_filterInfo[ 4 ].bHero = 0;
			m_filterInfo[ 4 ].bUnion = 1;
			m_filterInfo[ 4 ].bBattle = 0;
			m_filterInfo[ 4 ].bNoNpcMessage = 0;
			m_filterInfo[ 4 ].bWorldChat = 0;
		break;
		case 5:
			m_filterInfo[ 5 ].bSystem = 1;
			m_filterInfo[ 5 ].bChat = 1;
			m_filterInfo[ 5 ].bNormal = 0;
			m_filterInfo[ 5 ].bShout = 1;
			m_filterInfo[ 5 ].bClan = 0;
			m_filterInfo[ 5 ].bParty = 0;
			m_filterInfo[ 5 ].bTrade = 0;
			m_filterInfo[ 5 ].bWhisper = 1;
			m_filterInfo[ 5 ].bDamage = 1;
			m_filterInfo[ 5 ].bAlly = 0;
			m_filterInfo[ 5 ].bUseItem = 0;
			m_filterInfo[ 5 ].bHero = 1;
			m_filterInfo[ 5 ].bUnion = 1;
			m_filterInfo[ 5 ].bBattle = 0;
			m_filterInfo[ 5 ].bNoNpcMessage = 0;
			m_filterInfo[ 5 ].bWorldChat = 0;
		break;
		case 6:
			m_filterInfo[ 6 ].bSystem = 1;
			m_filterInfo[ 6 ].bChat = 1;
			m_filterInfo[ 6 ].bNormal = 0;
			m_filterInfo[ 6 ].bShout = 1;
			m_filterInfo[ 6 ].bClan = 0;
			m_filterInfo[ 6 ].bParty = 0;
			m_filterInfo[ 6 ].bTrade = 0;
			m_filterInfo[ 6 ].bWhisper = 1;
			m_filterInfo[ 6 ].bDamage = 1;
			m_filterInfo[ 6 ].bAlly = 0;
			m_filterInfo[ 6 ].bUseItem = 0;
			m_filterInfo[ 6 ].bHero = 0;
			m_filterInfo[ 6 ].bUnion = 1;
			m_filterInfo[ 6 ].bBattle = 0;
			m_filterInfo[ 6 ].bNoNpcMessage = 0;
			m_filterInfo[ 6 ].bWorldChat = 0;
		break;
		case 7:
			m_filterInfo[ 7 ].bSystem = 1;
			m_filterInfo[ 7 ].bChat = 1;
			m_filterInfo[ 7 ].bNormal = 0;
			m_filterInfo[ 7 ].bShout = 1;
			m_filterInfo[ 7 ].bClan = 0;
			m_filterInfo[ 7 ].bParty = 0;
			m_filterInfo[ 7 ].bTrade = 0;
			m_filterInfo[ 7 ].bWhisper = 1;
			m_filterInfo[ 7 ].bDamage = 1;
			m_filterInfo[ 7 ].bAlly = 0;
			m_filterInfo[ 7 ].bUseItem = 0;
			m_filterInfo[ 7 ].bHero = 0;
			m_filterInfo[ 7 ].bUnion = 1;
			m_filterInfo[ 7 ].bBattle = 0;
			m_filterInfo[ 7 ].bNoNpcMessage = 0;
			m_filterInfo[ 7 ].bWorldChat = 0;
		break;
		case 8:
			m_filterInfo[ 8 ].bSystem = 1;
			m_filterInfo[ 8 ].bChat = 0;
			m_filterInfo[ 8 ].bNormal = 0;
			m_filterInfo[ 8 ].bShout = 1;
			m_filterInfo[ 8 ].bClan = 0;
			m_filterInfo[ 8 ].bParty = 0;
			m_filterInfo[ 8 ].bTrade = 0;
			m_filterInfo[ 8 ].bWhisper = 1;
			m_filterInfo[ 8 ].bDamage = 1;
			m_filterInfo[ 8 ].bAlly = 0;
			m_filterInfo[ 8 ].bUseItem = 0;
			m_filterInfo[ 8 ].bHero = 0;
			m_filterInfo[ 8 ].bUnion = 1;
			m_filterInfo[ 8 ].bBattle = 0;
			m_filterInfo[ 8 ].bNoNpcMessage = 0;
			m_filterInfo[ 8 ].bWorldChat = 1;
		break;
	}
}

function SetDefaultFilterValue()
{
	m_filterInfo[ 0 ].bSystem = 1;
	m_filterInfo[ 0 ].bChat = 1;
	m_filterInfo[ 0 ].bNormal = 1;
	m_filterInfo[ 0 ].bShout = 1;
	m_filterInfo[ 0 ].bClan = 1;
	m_filterInfo[ 0 ].bParty = 1;
	m_filterInfo[ 0 ].bTrade = 0;
	m_filterInfo[ 0 ].bWhisper = 1;
	m_filterInfo[ 0 ].bDamage = 1;
	m_filterInfo[ 0 ].bAlly = 0;
	m_filterInfo[ 0 ].bUseItem = 0;
	m_filterInfo[ 0 ].bHero = 0;
	m_filterInfo[ 0 ].bUnion = 1;
	m_filterInfo[ 0 ].bBattle = 1;
	m_filterInfo[ 0 ].bNoNpcMessage = 0;
	m_filterInfo[ 0 ].bWorldChat = 1;
	
	m_filterInfo[ 1 ].bSystem = 1;
	m_filterInfo[ 1 ].bChat = 1;
	m_filterInfo[ 1 ].bNormal = 0;
	m_filterInfo[ 1 ].bShout = 1;
	m_filterInfo[ 1 ].bClan = 0;
	m_filterInfo[ 1 ].bParty = 0;
	m_filterInfo[ 1 ].bTrade = 1;
	m_filterInfo[ 1 ].bWhisper = 1;
	m_filterInfo[ 1 ].bDamage = 1;
	m_filterInfo[ 1 ].bAlly = 0;
	m_filterInfo[ 1 ].bUseItem = 0;
	m_filterInfo[ 1 ].bHero = 0;
	m_filterInfo[ 1 ].bUnion = 1;
	m_filterInfo[ 1 ].bBattle = 0;
	m_filterInfo[ 1 ].bNoNpcMessage = 0;
	m_filterInfo[ 1 ].bWorldChat = 0;
	
	m_filterInfo[ 2 ].bSystem = 1;
	m_filterInfo[ 2 ].bChat = 1;
	m_filterInfo[ 2 ].bNormal = 0;
	m_filterInfo[ 2 ].bShout = 1;
	m_filterInfo[ 2 ].bClan = 0;
	m_filterInfo[ 2 ].bParty = 1;
	m_filterInfo[ 2 ].bTrade = 0;
	m_filterInfo[ 2 ].bWhisper = 1;
	m_filterInfo[ 2 ].bDamage = 1;
	m_filterInfo[ 2 ].bAlly = 0;
	m_filterInfo[ 2 ].bUseItem = 0;
	m_filterInfo[ 2 ].bHero = 0;
	m_filterInfo[ 2 ].bUnion = 1;
	m_filterInfo[ 2 ].bBattle = 0;
	m_filterInfo[ 2 ].bNoNpcMessage = 0;
	m_filterInfo[ 2 ].bWorldChat = 0;
	
	m_filterInfo[ 3 ].bSystem = 1;
	m_filterInfo[ 3 ].bChat = 1;
	m_filterInfo[ 3 ].bNormal = 0;
	m_filterInfo[ 3 ].bShout = 1;
	m_filterInfo[ 3 ].bClan = 1;
	m_filterInfo[ 3 ].bParty = 0;
	m_filterInfo[ 3 ].bTrade = 0;
	m_filterInfo[ 3 ].bWhisper = 1;
	m_filterInfo[ 3 ].bDamage = 1;
	m_filterInfo[ 3 ].bAlly = 0;
	m_filterInfo[ 3 ].bUseItem = 0;
	m_filterInfo[ 3 ].bHero = 0;
	m_filterInfo[ 3 ].bUnion = 1;
	m_filterInfo[ 3 ].bBattle = 0;
	m_filterInfo[ 3 ].bNoNpcMessage = 0;
	m_filterInfo[ 3 ].bWorldChat = 0;
	
	m_filterInfo[ 4 ].bSystem = 1;
	m_filterInfo[ 4 ].bChat = 1;
	m_filterInfo[ 4 ].bNormal = 0;
	m_filterInfo[ 4 ].bShout = 1;
	m_filterInfo[ 4 ].bClan = 0;
	m_filterInfo[ 4 ].bParty = 0;
	m_filterInfo[ 4 ].bTrade = 0;
	m_filterInfo[ 4 ].bWhisper = 1;
	m_filterInfo[ 4 ].bDamage = 1;
	m_filterInfo[ 4 ].bAlly = 1;
	m_filterInfo[ 4 ].bUseItem = 0;
	m_filterInfo[ 4 ].bHero = 0;
	m_filterInfo[ 4 ].bUnion = 1;
	m_filterInfo[ 4 ].bBattle = 0;
	m_filterInfo[ 4 ].bNoNpcMessage = 0;
	m_filterInfo[ 4 ].bWorldChat = 0;
	
	m_filterInfo[ 5 ].bSystem = 1;
	m_filterInfo[ 5 ].bChat = 0;
	m_filterInfo[ 5 ].bNormal = 0;
	m_filterInfo[ 5 ].bShout = 1;
	m_filterInfo[ 5 ].bClan = 0;
	m_filterInfo[ 5 ].bParty = 0;
	m_filterInfo[ 5 ].bTrade = 0;
	m_filterInfo[ 5 ].bWhisper = 1;
	m_filterInfo[ 5 ].bDamage = 1;
	m_filterInfo[ 5 ].bAlly = 0;
	m_filterInfo[ 5 ].bUseItem = 0;
	m_filterInfo[ 5 ].bHero = 1;
	m_filterInfo[ 5 ].bUnion = 1;
	m_filterInfo[ 5 ].bBattle = 0;
	m_filterInfo[ 5 ].bNoNpcMessage = 0;
	m_filterInfo[ 5 ].bWorldChat = 0;
	
	m_filterInfo[ 6 ].bSystem = 1;
	m_filterInfo[ 6 ].bChat = 0;
	m_filterInfo[ 6 ].bNormal = 0;
	m_filterInfo[ 6 ].bShout = 1;
	m_filterInfo[ 6 ].bClan = 0;
	m_filterInfo[ 6 ].bParty = 0;
	m_filterInfo[ 6 ].bTrade = 0;
	m_filterInfo[ 6 ].bWhisper = 1;
	m_filterInfo[ 6 ].bDamage = 1;
	m_filterInfo[ 6 ].bAlly = 0;
	m_filterInfo[ 6 ].bUseItem = 0;
	m_filterInfo[ 6 ].bHero = 0;
	m_filterInfo[ 6 ].bUnion = 1;
	m_filterInfo[ 6 ].bBattle = 0;
	m_filterInfo[ 6 ].bNoNpcMessage = 0;
	m_filterInfo[ 6 ].bWorldChat = 0;
	
	m_filterInfo[ 7 ].bSystem = 1;
	m_filterInfo[ 7 ].bChat = 0;
	m_filterInfo[ 7 ].bNormal = 0;
	m_filterInfo[ 7 ].bShout = 1;
	m_filterInfo[ 7 ].bClan = 0;
	m_filterInfo[ 7 ].bParty = 0;
	m_filterInfo[ 7 ].bTrade = 0;
	m_filterInfo[ 7 ].bWhisper = 1;
	m_filterInfo[ 7 ].bDamage = 1;
	m_filterInfo[ 7 ].bAlly = 0;
	m_filterInfo[ 7 ].bUseItem = 0;
	m_filterInfo[ 7 ].bHero = 0;
	m_filterInfo[ 7 ].bUnion = 1;
	m_filterInfo[ 7 ].bBattle = 0;
	m_filterInfo[ 7 ].bNoNpcMessage = 0;
	m_filterInfo[ 7 ].bWorldChat = 0;
	
	m_filterInfo[ 8 ].bSystem = 1;
	m_filterInfo[ 8 ].bChat = 0;
	m_filterInfo[ 8 ].bNormal = 0;
	m_filterInfo[ 8 ].bShout = 1;
	m_filterInfo[ 8 ].bClan = 0;
	m_filterInfo[ 8 ].bParty = 0;
	m_filterInfo[ 8 ].bTrade = 0;
	m_filterInfo[ 8 ].bWhisper = 1;
	m_filterInfo[ 8 ].bDamage = 1;
	m_filterInfo[ 8 ].bAlly = 0;
	m_filterInfo[ 8 ].bUseItem = 0;
	m_filterInfo[ 8 ].bHero = 0;
	m_filterInfo[ 8 ].bUnion = 1;
	m_filterInfo[ 8 ].bBattle = 0;
	m_filterInfo[ 8 ].bNoNpcMessage = 0;
	m_filterInfo[ 8 ].bWorldChat = 1;
	
	
	//실제 사용되지는 않는 더미 값들
	m_filterInfo[ CHAT_WINDOW_SYSTEM ].bSystem = 1;
	m_filterInfo[ CHAT_WINDOW_SYSTEM ].bChat = 1;
	m_filterInfo[ CHAT_WINDOW_SYSTEM ].bNormal = 0;
	m_filterInfo[ CHAT_WINDOW_SYSTEM ].bShout = 0;
	m_filterInfo[ CHAT_WINDOW_SYSTEM ].bClan = 0;
	m_filterInfo[ CHAT_WINDOW_SYSTEM ].bParty = 0;
	m_filterInfo[ CHAT_WINDOW_SYSTEM ].bTrade = 0;
	m_filterInfo[ CHAT_WINDOW_SYSTEM ].bWhisper = 0;
	m_filterInfo[ CHAT_WINDOW_SYSTEM ].bDamage = 0;
	m_filterInfo[ CHAT_WINDOW_SYSTEM ].bAlly = 0;
	m_filterInfo[ CHAT_WINDOW_SYSTEM ].bUseItem = 0;
	m_filterInfo[ CHAT_WINDOW_SYSTEM ].bHero = 0;
	m_filterInfo[ CHAT_WINDOW_SYSTEM ].bUnion = 0;
	m_filterInfo[ CHAT_WINDOW_SYSTEM ].bNoNpcMessage = 0;
	m_filterInfo[ CHAT_WINDOW_SYSTEM ].bWorldChat = 1;
	
	//Global Setting
	m_bWorldChatSpeaker = 1;
	m_bUseSystemMsgWnd = 1;
	m_bSystemMsgWnd = 1;
	m_bDamageOption = 1;
	m_bUseSystemItem = 0;
	//m_NoUnionCommanderMessage = 1;
	m_NoNpcMessage = 0;				// NPC 대사 필터링 - 2010.9.8 winkey
	m_KeywordFilterSound = 0;
	m_KeywordFilterActivate = 0;
	m_UseChatSymbol = 1;
	m_UseAlpha = 0;
	m_ChatResizeOnOff = 0;
	m_Keyword0 = "";
	m_Keyword1 = "";
	m_Keyword2 = "";
	m_Keyword3 = "";	
	m_bOnlyUseSystemMsgWnd = 1;	
}


function HandleSetString( String a_Param )
{
	local int IsAppend;
	local string tmpString;

	IsAppend = 0;
	ParseInt( a_Param, "IsAppend", IsAppend );
	
	if( ParseString( a_Param, "String", tmpString ) )
	{
		if( IsAppend > 0 )
			ChatEditBox.AddString(tmpString);
		else
			ChatEditBox.SetString(tmpString);
	}
}

function HandleSetFocus()
{
	if( !ChatEditBox.IsFocused() )
		ChatEditBox.SetFocus();
}

function Print( int index )
{
	//debug( "Self=" $ Self $ " m_chatType=" $ m_chatType );
/* 	debug( "Print type(" $ index $ "), system :"	$ m_filterInfo[ index ].bSystem $ ", chat:" $ m_filterInfo[ index ].bChat $ ",Normal:" $ m_filterInfo[ index ].bNormal $
 * 		", shout:" $ m_filterInfo[ index ].bShout $ ",pledge:" $ m_filterInfo[ index ].bClan $ ", party:" $ m_filterInfo[ index ].bParty $ 
 * 		", trade:" $ m_filterInfo[ index ].bTrade $ ", whisper:" $ m_filterInfo[ index ].bWhisper $ ", damage:" $ m_filterInfo[ index ].bDamage $
 * 		", ally:" $ m_filterInfo[ index ].bAlly $ ",useitem:" $ m_filterInfo[ index ].bUseItem $ ", hero:" $ m_filterInfo[ index ].bHero );
 */
}

/*
// 채팅 필터 창의 체크박스 들을 m_filterInfo에따라 세팅해 주고 옵션불에서 시스템 메시지 전용창의 위치를 파악한다.
function SetChatFilterButton()
{	
	local ChatFilterWnd script;
	local int chatType;
	
	script = ChatFilterWnd( GetScript("ChatFilterWnd") );
	
	// 시스템 메시지 윈도우 사용
	//GetINIBool( "global", "SystemMsgWnd", tempVal, "chatfilter.ini" );
	//m_bUseSystemMsgWnd = tempVal;
	//m_hChatFilterWndUseSystemMsgBox.SetCheck( bool(m_bUseSystemMsgWnd) );

	// 일반 시스템 메시지 사용
	//GetINIBool( "global", "UseSystemMsg", tempVal, "chatfilter.ini" );
	//m_bSystemMsgWnd = tempVal;
	//m_hChatFilterWndSystemMsgBox.SetCheck( bool(m_bSystemMsgWnd) );
	
	// 데미지 - DamageBox
	//GetINIBool( "global", "SystemMsgWndDamage", tempVal, "chatfilter.ini" );
	//m_bDamageOption = tempVal;
	//m_hChatFilterWndDamageBox.SetCheck( bool(m_bDamageOption) );

	// 소모성아이템사용 - ItemBox
	//GetINIBool( "global", "SystemMsgWndExpendableItem", tempVal, "chatfilter.ini" );
	//m_bUseSystemItem = tempVal;
	//m_hChatFilterWndItemBox.SetCheck( bool(m_bUseSystemItem) );
	
	

	if( m_chatType.UI >= 0 && m_chatType.UI <= CHAT_WINDOW_COUNT )
	{
		if (m_chatType.UI  == 0)
			m_chatType.ID = 0;
		
		script.SetComboxIDSelect( m_chatType.UI -1, m_chatType.ID );
		
		/*
		switch (m_chatType.ID)
		{
			//전체 
			case 0:
				//~ debug("1");
				m_hChatFilterWndCurrentText.SetText(MakeFullSystemMsg( GetSystemMessage(1995), GetSystemString(144) , "" ));				
				break;
			//매매
			case 1:
				m_hChatFilterWndCurrentText.SetText(MakeFullSystemMsg( GetSystemMessage(1995), GetSystemString(355) , "" ));
				break;
			//파티
			case 2:
				m_hChatFilterWndCurrentText.SetText(MakeFullSystemMsg( GetSystemMessage(1995), GetSystemString(188) , "" ));
				break;
			//혈맹
			case 3:
				m_hChatFilterWndCurrentText.SetText(MakeFullSystemMsg( GetSystemMessage(1995), GetSystemString(128) , "" ));
				break;
			//동맹
			case 4:
				m_hChatFilterWndCurrentText.SetText(MakeFullSystemMsg( GetSystemMessage(1995), GetSystemString(559) , "" ));
				break;
			case 5:
				m_hChatFilterWndCurrentText.SetText(MakeFullSystemMsg( GetSystemMessage(1995), GetSystemString(1961) , "" ));
				break;
			case 6:
				m_hChatFilterWndCurrentText.SetText(MakeFullSystemMsg( GetSystemMessage(1995), GetSystemString(1962) , "" ));
				break;
			case 7:
				m_hChatFilterWndCurrentText.SetText(MakeFullSystemMsg( GetSystemMessage(1995), GetSystemString(1963) , "" ));
				break;
			case 8:
				m_hChatFilterWndCurrentText.SetText(MakeFullSystemMsg( GetSystemMessage(1995), GetSystemString(1964) , "" ));
				break;
		}
		*/

		//콤보박스 채널에 저장
		chatType = m_chatType.ID;

		//한번 다 체크 풀어줌
		m_hChkChatFilterWndCheckBoxSystem.SetCheck(false);		
		m_hChkChatFilterWndCheckBoxNormal.SetCheck(false);
		m_hChkChatFilterWndCheckBoxShout.SetCheck(false);
		m_hChkChatFilterWndCheckBoxPledge.SetCheck(false);
		m_hChkChatFilterWndCheckBoxParty.SetCheck(false);
		m_hChkChatFilterWndCheckBoxTrade.SetCheck(false);
		m_hChkChatFilterWndCheckBoxWhisper.SetCheck(false);
		m_hChkChatFilterWndCheckBoxDamage.SetCheck(false);
		m_hChkChatFilterWndCheckBoxAlly.SetCheck(false);
		m_hChkChatFilterWndCheckBoxItem.SetCheck(false);
		m_hChkChatFilterWndCheckBoxHero.SetCheck(false);
		m_hChkChatFilterWndCheckBoxUnion.SetCheck(false);
		m_hChkChatFilterWndCheckBoxNoNpcMessage.SetCheck(false);
		//월드 채팅 추가
		m_hChkChatFilterWndCheckBoxWorldChat.SetCheck(false);
		//m_hChkChatFilterWndCheckBoxWorldChatSpeaker.SetCheck(false);

		/////////////////////////////////////////////////////////
		
		m_hChkChatFilterWndCheckBoxSystem.SetCheck( bool(m_filterInfo[chatType].bSystem ) );		
		m_hChkChatFilterWndCheckBoxNormal.SetCheck( bool(m_filterInfo[chatType].bNormal ) );
		m_hChkChatFilterWndCheckBoxShout.SetCheck(  bool(m_filterInfo[chatType].bShout ) );
		m_hChkChatFilterWndCheckBoxPledge.SetCheck( bool(m_filterInfo[chatType].bClan ) );
		m_hChkChatFilterWndCheckBoxParty.SetCheck( bool(m_filterInfo[chatType].bParty ) );
		m_hChkChatFilterWndCheckBoxTrade.SetCheck( bool(m_filterInfo[chatType].bTrade ) );
		m_hChkChatFilterWndCheckBoxWhisper.SetCheck( bool(m_filterInfo[chatType].bWhisper ) );
		m_hChkChatFilterWndCheckBoxDamage.SetCheck( bool(m_filterInfo[chatType].bDamage ) );
		m_hChkChatFilterWndCheckBoxAlly.SetCheck( bool(m_filterInfo[chatType].bAlly ) );
		m_hChkChatFilterWndCheckBoxItem.SetCheck( bool(m_filterInfo[chatType].bUseItem ) );
		m_hChkChatFilterWndCheckBoxHero.SetCheck( bool(m_filterInfo[chatType].bHero ) );
		m_hChkChatFilterWndCheckBoxUnion.SetCheck( bool(m_filterInfo[chatType].bUnion ) );		
		m_hChkChatFilterWndCheckBoxNoNpcMessage.SetCheck( bool(m_filterInfo[chatType].bNoNpcMessage ) );
		//월드 채팅 추가
		m_hChkChatFilterWndCheckBoxWorldChat.SetCheck( bool(m_filterInfo[chatType].bWorldChat ) );
		//월드 채팅 스피커
		//m_hChkChatFilterWndCheckBoxWorldChatSpeaker.SetCheck( bool(m_bWorldChatSpeaker) );

		m_hChkChatFilterWndUseAlphaBox.SetCheck( bool(m_UseAlpha) );
		m_hChkChatFilterWndUseChatSymbol.SetCheck( bool(m_UseChatSymbol) );
		m_hChkChatFilterWndChatResize.SetCheck( bool(m_ChatResizeOnOff) );

		m_hChkChatFilterWndCheckBoxNormal.SetDisable( false );
		m_hChkChatFilterWndCheckBoxShout.SetDisable( false );
		m_hChkChatFilterWndCheckBoxPledge.SetDisable( false );
		m_hChkChatFilterWndCheckBoxParty.SetDisable( false );
		m_hChkChatFilterWndCheckBoxTrade.SetDisable( false );
		m_hChkChatFilterWndCheckBoxWhisper.SetDisable( false );
		m_hChkChatFilterWndCheckBoxAlly.SetDisable( false );
		m_hChkChatFilterWndCheckBoxHero.SetDisable( false );
		m_hChkChatFilterWndCheckBoxUnion.SetDisable( false );
		m_hChkChatFilterWndCheckBoxNoNpcMessage.SetDisable( false );
		m_hChkChatFilterWndCheckBoxNoNpcMessage.SetDisable( false );
		//월드 채팅 추가
		m_hChkChatFilterWndCheckBoxWorldChat.SetDisable( false );
		//m_hChkChatFilterWndCheckBoxWorldChatSpeaker.SetDisable( false );
		
		
		// 활성화 될수 없는 체크박스(기본적으로 체크여부를 유저가 결정할 수 없는 것 들)
		switch( m_chatType.ID )
		{
			case 1:
				m_hChkChatFilterWndCheckBoxTrade.SetDisable( true );
				m_hChkChatFilterWndCheckBoxTrade.SetCheck( true );
				break;
			case 2:
				m_hChkChatFilterWndCheckBoxParty.SetDisable( true );
				m_hChkChatFilterWndCheckBoxParty.SetCheck( true );
				break;
			case 3:
				m_hChkChatFilterWndCheckBoxPledge.SetDisable( true );
				m_hChkChatFilterWndCheckBoxPledge.SetCheck( true );
				break;
			case 4:
				m_hChkChatFilterWndCheckBoxAlly.SetDisable( true );
				m_hChkChatFilterWndCheckBoxAlly.SetCheck( true );
				break;
			case 5:
				m_hChkChatFilterWndCheckBoxHero.SetDisable( true );
				m_hChkChatFilterWndCheckBoxHero.SetCheck( true );
				break;
			case 6:
				m_hChkChatFilterWndCheckBoxUnion.SetDisable( true );
				m_hChkChatFilterWndCheckBoxUnion.SetCheck( true );
				break;
			case 7:
				m_hChkChatFilterWndCheckBoxShout.SetDisable( true );
				m_hChkChatFilterWndCheckBoxShout.SetCheck( true );
				break;
			case 8:
				m_hChkChatFilterWndCheckBoxWorldChat.SetDisable( true );
				m_hChkChatFilterWndCheckBoxWorldChat.SetCheck( true );
			
				break;			
			
			default:
				break;
		}
	}
}

function HandleChatWndStatusChange()
{
	//~ local UserInfo userInfo;

	//~ GetPlayerInfo( userInfo );

	//~ if( userInfo.nClanID > 0 )
		//~ ChatTabCtrl.SetDisable(CHAT_WINDOW_CLAN, false);
	//~ else
		//~ ChatTabCtrl.SetDisable(CHAT_WINDOW_CLAN, true);

	//~ if( userInfo.nAllianceID > 0 )
		//~ ChatTabCtrl.SetDisable(CHAT_WINDOW_ALLY, false);
	//~ else
		//~ ChatTabCtrl.SetDisable(CHAT_WINDOW_ALLY, true);
}

function HandleMsnStatus( string param )
{
	local string status;
	local ButtonHandle handle;

	if(CREATE_ON_DEMAND==0)
		handle = ButtonHandle(GetHandle("Chatwnd.MessengerBtn"));
	else
		handle = GetButtonHandle("Chatwnd.MessengerBtn");

	ParseString( param, "status", status );
	if( status == "online" )
		handle.SetTexture("L2UI_CH3.Msn.chatting_msn1", "L2UI_CH3.Msn.chatting_msn1_down", "L2UI_CH3.Msn.chatting_msn1_over");
	else if( status == "berightback" || status == "idle" || status == "away" || status == "lunch" )
		handle.SetTexture("L2UI_CH3.Msn.chatting_msn2", "L2UI_CH3.Msn.chatting_msn2_down", "L2UI_CH3.Msn.chatting_msn2_over");
	else if( status == "busy" || status == "onthephone" )
		handle.SetTexture("L2UI_CH3.Msn.chatting_msn3", "L2UI_CH3.Msn.chatting_msn3_down", "L2UI_CH3.Msn.chatting_msn3_over");
	else if( status == "offline" || status == "invisible" )
		handle.SetTexture("L2UI_CH3.Msn.chatting_msn4", "L2UI_CH3.Msn.chatting_msn4_down", "L2UI_CH3.Msn.chatting_msn4_over");
	else if( status == "none" )
		handle.SetTexture("L2UI_CH3.Msn.chatting_msn5", "L2UI_CH3.Msn.chatting_msn5_down", "L2UI_CH3.Msn.chatting_msn5_over");
}
*/

function EChatType GetChatTypeByTabIndex(int Index)
{
	local EChatType Type;
	//~ Type = CHAT_NORMAL;
	
	switch( m_chatType.ID )
	{
	//~ case CHAT_WINDOW_NORMAL:
		//~ Type = CHAT_NORMAL;
		//~ break;
	//~ case CHAT_WINDOW_TRADE:
		//~ Type = CHAT_MARKET;
		//~ break;
	//~ case CHAT_WINDOW_PARTY:
		//~ Type = CHAT_PARTY;
		//~ break;
	//~ case CHAT_WINDOW_CLAN:
		//~ Type = CHAT_CLAN;
		//~ break;
	//~ case CHAT_WINDOW_ALLY:
		//~ Type = CHAT_ALLIANCE;
		//~ break;
	//~ case CHAT_WINDOW_ALLY:
		//~ Type = CHAT_ALLIANCE;
		//~ break;
	//~ case CHAT_WINDOW_ALLY:
		//~ Type = CHAT_ALLIANCE;
		//~ break;
	//~ case CHAT_WINDOW_ALLY:
		//~ Type = CHAT_ALLIANCE;
		//~ break;
	//~ case CHAT_WINDOW_ALLY:
		//~ Type = CHAT_ALLIANCE;
		//~ break;
	case 0:
		Type = CHAT_NORMAL;
		break;
	case 1:
		Type = CHAT_MARKET;
		break;
	case 2:
		Type = CHAT_PARTY;
		break;
	case 3:
		Type = CHAT_CLAN;
		break;
	case 4:
		Type = CHAT_ALLIANCE;
		break;
	case 5:
		Type = CHAT_HERO;
		break;
	case 6:
		Type =CHAT_INTER_PARTYMASTER_CHAT;
		break;
	case 7:
		Type = CHAT_SHOUT;
		break;
	case 8:
		Type = CHAT_WORLD;
		
	default:
		break;
	}
	return Type;
}

//TextLink
function HandleTextLinkRButtonClick(string Param)
{
	local string chatMsg,userName;
	local int posX,posY,userID;
	local UserInfo userInfo;

	Debug("우클릭Param" @Param);

	ParseInt(Param,"PosX",posX);
	ParseInt(Param,"PosY",posY);
	ParseInt(Param,"ID",userID);

	ParseString(Param,"ChatMsg",chatMsg);
	ParseString(Param,"Title",userName);

	GetPlayerInfo(userInfo);

	// 본인이 아닌 경우만 작동 (타인)
	if(userInfo.Name != userName)
	{
		if(userName != "")	getInstanceContextMenu().execContextEvent(userName,userID,posX,posY,getInstanceContextMenu().SPECIALTYPE_CHAT_ADDBLOCK,chatMsg);
	}
}

//TextLink
function HandleTextLinkLButtonClick( string Param )
{
	local ETextLinkType eType;
	local int Type;
	local int ID;
	local string Title;
	local string LinkName;
	
	ParseInt( Param, "Type", Type );
	ParseInt( Param, "ID", ID );
	ParseString( Param, "Title", Title );
	ParseString( Param, "LinkName", LinkName );
	eType = ETextLinkType( Type );

	
	if( eType == TLT_User )
	{
		if( Left( Title, 2 ) == "->" )
			Title = Mid( Title, 2 );
		SetChatMessage( "\"" $ Title $ " " );
	}
}

function HandleDominionWarChannelSet( string param )
{
	local int DominionWarChannelSet;
	
	ParseInt(param, "DominionWarChannelSet", DominionWarChannelSet);
	
	if (DominionWarChannelSet == 1)
	{
		AddSystemMessage(2445);

	}
	else
	{
		AddSystemMessage(2446);
	}
}

function ChangeTabChannel(int ChannelIndex)
{
	switch (ChannelIndex)
	{
		case 1:
			ChatTabCtrl.SetButtonName( m_chatType.UI, GetSystemString(355));
			//~ SetINIInt("global", "TabIndex1", ChannelIndex, "chatfilter.ini");
			//~ m_ChatUI[8].ID = 1;
			//~ m_ChatUI[].UI = m_chatType.UI;
			//~ AssignCurrentChatTypeID(ChannelIndex, m_chatType.UI);
		break;
		case 2:
			ChatTabCtrl.SetButtonName( m_chatType.UI, GetSystemString(188));
			//~ SetINIInt("global", "TabIndex2", 2, "chatfilter.ini");
		break;
		case 3:
			ChatTabCtrl.SetButtonName( m_chatType.UI, GetSystemString(128));
			//~ SetINIInt("global", "TabIndex3", 3, "chatfilter.ini");
		break;
		case 4:
			ChatTabCtrl.SetButtonName( m_chatType.UI, GetSystemString(559));
			//~ SetINIInt("global", "TabIndex4", 4, "chatfilter.ini");
		break;
		case 5:
			ChatTabCtrl.SetButtonName( m_chatType.UI, GetSystemString(1961));
			//~ SetINIInt("global", "TabIndex5", 5, "chatfilter.ini");
		break;
		case 6:
			ChatTabCtrl.SetButtonName( m_chatType.UI, GetSystemString(1962));
			//~ SetINIInt("global", "TabIndex6", 6, "chatfilter.ini");
		break;
		case 7:
			ChatTabCtrl.SetButtonName( m_chatType.UI, GetSystemString(1963));
			//~ SetINIInt("global", "TabIndex7", 7, "chatfilter.ini");
		break;
		case 8:
			//월드 채팅 추가
			ChatTabCtrl.SetButtonName( m_chatType.UI, GetSystemString(3234));
			//~ SetINIInt("global", "TabIndex8", 8, "chatfilter.ini");
		break;
	}
	//~ SetINIInt("global", "TabIndex1", ChannelIndex, "chatfilter.ini");
	AssignCurrentChatTypeID(ChannelIndex, m_chatType.UI);
	SetCurrentAssignedChatType2Ini(ChannelIndex, m_chatType.UI);
}

function SetDefaultAlpha(int type)
{
	local int alpha;
	
	if(type == 0)
	{
		alpha = 255;
	}
	else
	{
		alpha = 50;
	}
	m_hChatWndBodyTex.SetAlpha(alpha, 0);
	m_hChatWndHeadTex.SetAlpha(alpha, 0);
	m_hChatWndBottomTex.SetAlpha(alpha, 0);
	m_hChatWndBottomTex2.SetAlpha(alpha, 0);
	m_hChatWndBottomTex3.SetAlpha(alpha, 0);
	m_hChatWndBottomTex4.SetAlpha(alpha, 0);
	m_hChatWndBottomTex5.SetAlpha(alpha, 0);

	if( m_IsSplit1 )
		TradeChat.SetAlpha(alpha, 0);
	else
		TradeChat.SetAlpha(255, 0);

	if( m_IsSplit2 )
		PartyChat.SetAlpha(alpha, 0);
	else
		PartyChat.SetAlpha(255, 0);

	if( m_IsSplit3 )
		ClanChat.SetAlpha(alpha, 0);
	else
		ClanChat.SetAlpha(255, 0);

	if( m_IsSplit4 )
		AllyChat.SetAlpha(alpha, 0);
	else
		AllyChat.SetAlpha(255, 0);
}

function onMouseOver( WindowHandle w )
{
	local WindowHandle parent;
	local WindowHandle target;
	local bool ChangeMain;
	ChangeMain = true;

	if(m_UseAlpha == 1)
	{
		parent = w.GetParentWindowHandle();

		if( m_IsSplit1 )
		{
			if(w == TradeChat)
			{
				target = w;
				ChangeMain = false;
			}
			else if(parent == TradeChat)
			{
				target = parent;
				ChangeMain = false;
			}
			else if(w == TradeChatTabButton)
			{
				target = TradeChat;
				ChangeMain = false;
			}
		}

		if( m_IsSplit2 )
		{
			if(w == PartyChat)
			{
				target = w;
				ChangeMain = false;
			}
			else if(parent == PartyChat)
			{
				target = parent;
				ChangeMain = false;
			}
			else if(w == PartyChatTabButton)
			{
				target = PartyChat;
				ChangeMain = false;
			}
		}
		else

		if( m_IsSplit3 )
		{
			if(w == ClanChat)
			{
				target = w;
				ChangeMain = false;
			}
			else if(parent == ClanChat)
			{
				target = parent;
				ChangeMain = false;
			}
			else if(w == ClanChatTabButton)
			{
				target = ClanChat;
				ChangeMain = false;
			}
		}

		if( m_IsSplit4 )
		{
			if(w == AllyChat)
			{
				target = w;
				ChangeMain = false;
			}
			else if(parent == AllyChat)
			{
				target = parent;
				ChangeMain = false;
			}
			else if(w == AllyChatTabButton)
			{
				target = AllyChat;
				ChangeMain = false;
			}
		}

		if(ChangeMain)
		{
			m_hChatWndBodyTex.SetAlpha(255, 0.5);
			m_hChatWndHeadTex.SetAlpha(255, 0.5);
			m_hChatWndBottomTex.SetAlpha(255, 0.5);
			m_hChatWndBottomTex2.SetAlpha(255, 0.5);
			m_hChatWndBottomTex3.SetAlpha(255, 0.5);
			m_hChatWndBottomTex4.SetAlpha(255, 0.5);
			m_hChatWndBottomTex5.SetAlpha(255, 0.5);
		}
		else
		{
			target.SetAlpha(255, 0.5);
		}
	}
}

function onMouseOut( WindowHandle w )
{
	local WindowHandle parent;
	local WindowHandle target;
	local bool ChangeMain;
	ChangeMain = true;

	if(m_UseAlpha == 1)
	{
		parent = w.GetParentWindowHandle();

		if( m_IsSplit1 )
		{
			if(w == TradeChat)
			{
				target = w;
				ChangeMain = false;
			}
			else if(parent == TradeChat)
			{
				target = parent;
				ChangeMain = false;
			}
			else if(w == TradeChatTabButton)
			{
				target = TradeChat;
				ChangeMain = false;
			}
		}

		if( m_IsSplit2 )
		{
			if(w == PartyChat)
			{
				target = w;
				ChangeMain = false;
			}
			else if(parent == PartyChat)
			{
				target = parent;
				ChangeMain = false;
			}
			else if(w == PartyChatTabButton)
			{
				target = PartyChat;
				ChangeMain = false;
			}
		}

		if( m_IsSplit3 )
		{
			if(w == ClanChat)
			{
				target = w;
				ChangeMain = false;
			}
			else if(parent == ClanChat)
			{
				target = parent;
				ChangeMain = false;
			}
			else if(w == ClanChatTabButton)
			{
				target = ClanChat;
				ChangeMain = false;
			}
		}

		if( m_IsSplit4 )
		{
			if(w == AllyChat)
			{
				target = w;
				ChangeMain = false;
			}
			else if(parent == AllyChat)
			{
				target = parent;
				ChangeMain = false;
			}
			else if(w == AllyChatTabButton)
			{
				target = AllyChat;
				ChangeMain = false;
			}
		}

		if(ChangeMain)
		{
			m_hChatWndBodyTex.SetAlpha(50, 0.5);
			m_hChatWndHeadTex.SetAlpha(50, 0.5);
			m_hChatWndBottomTex.SetAlpha(50, 0.5);
			m_hChatWndBottomTex2.SetAlpha(50, 0.5);
			m_hChatWndBottomTex3.SetAlpha(50, 0.5);
			m_hChatWndBottomTex4.SetAlpha(50, 0.5);
			m_hChatWndBottomTex5.SetAlpha(50, 0.5);
		}
		else
		{
			target.SetAlpha(50, 0.5);
		}
	}
}

function SetCurrentAssignedChatType2Ini(int ChannelIndex, int ChatType)
{
	SetINIInt("global", "TabIndex" $ string(ChatType) , ChannelIndex, "chatfilter.ini");
}


function GetAllcurrentAssignedChatTypeID()
{
	local int i;
	local int index;
	SetINIInt("global", "TabIndex0", 0, "chatfilter.ini");
	//Reset Procedure
	for (i=0;i<5;i++)
	{
		m_ChatUI[i].ID = i;
		m_ChatUI[i].UI = i;
	}
	//
	for (i=1;i<5;i++)
	{
		GetINIInt( "global", "TabIndex" $ string(i), index, "chatfilter.ini" );
		if (index > 0 && i > 0)
		{
			m_ChatUI[i].UI = i;
			m_ChatUI[i].ID = index;
			
			m_chatType.UI = i;
			ChangeTabChannel(index);
		}
		else
		{
			//~ INI에 0으로 들어 있으면 기본값으로 세팅;						
			AssignCurrentChatTypeID (i, i);
			switch (i)
			{
				case 1:
					m_ChatUI[1].ID = 1;
					ChatTabCtrl.SetButtonName( 1, GetSystemString(355));
					SetINIInt("global", "TabIndex1", 1, "chatfilter.ini");
					m_chatType.UI = i;
					ChangeTabChannel(1);
				break;
				case 2:
					m_ChatUI[2].ID = 2;
					ChatTabCtrl.SetButtonName( 2, GetSystemString(188));
					SetINIInt("global", "TabIndex2", 2, "chatfilter.ini");
					m_chatType.UI = i;
					ChangeTabChannel(2);
				break;
				case 3:
					m_ChatUI[3].ID = 3;
					ChatTabCtrl.SetButtonName( 3, GetSystemString(128));
					SetINIInt("global", "TabIndex3", 3, "chatfilter.ini");
					m_chatType.UI = i;
					ChangeTabChannel(3);
				break;
				case 4:
					m_ChatUI[4].ID = 4;
					ChatTabCtrl.SetButtonName( 4, GetSystemString(559));
					SetINIInt("global", "TabIndex4", 4, "chatfilter.ini");
					m_chatType.UI = i;
					ChangeTabChannel(4);
				break;				
			}
		}
	}
}

function AssignCurrentChatTypeID (int ChatTypeID, int ChatTypeUI)
{
	local int i;
	for (i=1;i<8;i++)
	{
		if (m_ChatUI[i].UI == ChatTypeUI)
		{
			m_ChatUI[i].ID = ChatTypeID;
			break;
		}
	}
}


function int GetCurrentChatTypeID (int ChatTypeUI)
{
	local int i;
	for (i=1;i<8;i++)
	{
		if (m_ChatUI[i].UI == ChatTypeUI)
		{
			//~ native final function bool GetINIInt( string section, string key, out int value, string file );
			return m_ChatUI[i].ID;
			break;
		}
	}
}

function setChatEditBox (string txt)
{
	ChatEditBox.SetString(txt);
	ChatEditBox.SetFocus();

}

function SaveChatFilterOption()
{
	local int i;

	for(i = 0; i < m_sectionName.Length; i++)
	{
		SetINIBool(m_sectionName[i],"system", bool(m_filterInfo[i].bSystem), "chatfilter.ini");
		SetINIBool(m_sectionName[i],"damage", bool(m_filterInfo[i].bDamage), "chatfilter.ini");
		SetINIBool(m_sectionName[i],"useitems", bool(m_filterInfo[i].bUseItem), "chatfilter.ini");
		SetINIBool(m_sectionName[i],"chat", bool(m_filterInfo[i].bChat), "chatfilter.ini");
		SetINIBool(m_sectionName[i],"normal", bool(m_filterInfo[i].bNormal), "chatfilter.ini");
		SetINIBool(m_sectionName[i],"party", bool(m_filterInfo[i].bParty), "chatfilter.ini");
		SetINIBool(m_sectionName[i],"shout", bool(m_filterInfo[i].bShout), "chatfilter.ini");
		SetINIBool(m_sectionName[i],"market", bool(m_filterInfo[i].bTrade), "chatfilter.ini");
		SetINIBool(m_sectionName[i],"pledge", bool(m_filterInfo[i].bClan), "chatfilter.ini");
		SetINIBool(m_sectionName[i],"tell", bool(m_filterInfo[i].bWhisper), "chatfilter.ini");
		SetINIBool(m_sectionName[i],"ally", bool(m_filterInfo[i].bAlly), "chatfilter.ini");	
		SetINIBool(m_sectionName[i],"hero", bool(m_filterInfo[i].bHero), "chatfilter.ini");
		SetINIBool(m_sectionName[i],"union", bool(m_filterInfo[i].bUnion), "chatfilter.ini");
		//SetINIBool(script.m_sectionName[i],"battle", bool(script.m_filterInfo[i].bBattle), "chatfilter.ini");
		SetINIBool(m_sectionName[i],"nonpcmessage", bool(m_filterInfo[i].bNoNpcMessage), "chatfilter.ini");
		//월드 채팅 추가
		SetINIBool(m_sectionName[i],"worldChat", bool(m_filterInfo[i].bWorldChat), "chatfilter.ini");
	}	

	SetINIBool ( "global", "OldChatting", bool(m_UseChatSymbol), "chatfilter.ini")  ;//int(GetOptionBool( "CommunIcation", "OldChatting" ));
	
	//SetINIBool( "global", "command", bool(m_NoUnionCommanderMessage), "chatfilter.ini" );
	
	SetINIBool( "global", "keywordsound", bool(m_KeywordFilterSound), "chatfilter.ini" );
	
	SetINIBool( "global", "keywordactivate", bool(m_KeywordFilterActivate), "chatfilter.ini" );	 
	
	SetINIBool( "global", "UseAlpha", bool(m_UseAlpha), "chatfilter.ini" );
	
	SetINIBool( "global", "ChatResizing", bool(m_ChatResizeOnOff), "chatfilter.ini" );	
	
	SetINIBool( "global", "SystemMsgWnd", bool(m_bUseSystemMsgWnd), "chatfilter.ini" );

	SetINIBool( "global", "OnlyUseSystemMsgWnd", bool(m_bOnlyUseSystemMsgWnd), "chatfilter.ini" );
	
	SetINIBool( "global", "UseSystemMsg", bool(m_bSystemMsgWnd), "chatfilter.ini" );
	
	// 데미지 - DamageBox
	SetINIBool( "global", "SystemMsgWndDamage", bool(m_bDamageOption), "chatfilter.ini" );
	
	// 소모성아이템사용 - ItemBox
	SetINIBool( "global", "SystemMsgWndExpendableItem", bool(m_bUseSystemItem), "chatfilter.ini" );


	// 월드 채팅 스피커
	SetINIBool( "global", "UseWorldChatSpeaker", bool(m_bWorldChatSpeaker), "chatfilter.ini" );

	SetINIString("global", "Keyword0", m_Keyword0, "chatfilter.ini");
	SetINIString("global", "Keyword1", m_Keyword1, "chatfilter.ini");
	SetINIString("global", "Keyword2", m_Keyword2, "chatfilter.ini");
	SetINIString("global", "Keyword3", m_Keyword3, "chatfilter.ini");


	if(bool(m_ChatResizeOnOff))
	{
		EnableChatWndResizing(false);
	}
	else
	{
		EnableChatWndResizing(true);
	}
}

// ini에서 기본값을 그냥 읽어옴
function LoadINIFilterSetting()
{		
	local int tempVal, i, resultNum;
	//local string str;
	
	for(i = 0; i < m_sectionName.Length; i++)
	{
		//getini 로 값을 가져와야됨
		GetINIBool( m_sectionName[i], "system", tempVal, "chatfilter.ini" );
		m_filterInfo[i].bSystem = tempVal;

		GetINIBool( m_sectionName[i], "useitems", tempVal, "chatfilter.ini" );
		m_filterInfo[i].bUseitem = tempVal;

		GetINIBool( m_sectionName[i], "damage", tempVal, "chatfilter.ini" );
		m_filterInfo[i].bDamage = tempVal;

		GetINIBool( m_sectionName[i], "chat", tempVal, "chatfilter.ini" );
		m_filterInfo[i].bChat = tempVal;

		GetINIBool( m_sectionName[i], "normal", tempVal, "chatfilter.ini" );
		m_filterInfo[i].bNormal = tempVal;

		GetINIBool( m_sectionName[i], "party", tempVal, "chatfilter.ini" );
		m_filterInfo[i].bParty = tempVal;

		GetINIBool( m_sectionName[i], "shout", tempVal, "chatfilter.ini" );
		m_filterInfo[i].bShout = tempVal;

		GetINIBool( m_sectionName[i], "market", tempVal, "chatfilter.ini" );
		m_filterInfo[i].bTrade = tempVal;

		GetINIBool( m_sectionName[i], "pledge", tempVal, "chatfilter.ini" );
		m_filterInfo[i].bClan = tempVal;

		GetINIBool( m_sectionName[i], "tell", tempVal, "chatfilter.ini" );
		m_filterInfo[i].bWhisper = tempVal;

		GetINIBool( m_sectionName[i], "ally", tempVal, "chatfilter.ini" );
		m_filterInfo[i].bAlly = tempVal;

		GetINIBool( m_sectionName[i], "hero", tempVal, "chatfilter.ini" );
		m_filterInfo[i].bHero = tempVal;

		GetINIBool( m_sectionName[i], "union", tempVal, "chatfilter.ini" );
		m_filterInfo[i].bUnion = tempVal;

		GetINIBool( m_sectionName[i], "nonpcmessage", tempVal, "chatfilter.ini" );
		m_filterInfo[i].bNoNpcMessage = tempVal;

		GetINIBool( m_sectionName[i], "worldChat", tempVal, "chatfilter.ini" );
		m_filterInfo[i].bWorldChat = tempVal;
	}	
	
	m_UseChatSymbol = int ( GetChatFilterBool ( "Global", "OldChatting") ) ;//int(GetOptionBool( "CommunIcation", "OldChatting" ));
	
	//GetINIBool( "global", "command", resultNum, "chatfilter.ini" );
	//m_NoUnionCommanderMessage = resultNum;
	
	GetINIBool( "global", "keywordsound", resultNum, "chatfilter.ini" );
	m_KeywordFilterSound = resultNum;
	
	GetINIBool( "global", "keywordactivate", resultNum, "chatfilter.ini" );
	m_KeywordFilterActivate = resultNum;
	
	GetINIBool( "global", "UseAlpha", resultNum, "chatfilter.ini" );
	m_UseAlpha = resultNum;
	
	GetINIBool( "global", "ChatResizing", resultNum, "chatfilter.ini" );	
	m_ChatResizeOnOff = resultNum;
	
	GetINIBool( "global", "SystemMsgWnd", resultNum, "chatfilter.ini" );
	m_bUseSystemMsgWnd = resultNum;
	
	GetINIBool( "global", "OnlyUseSystemMsgWnd", resultNum, "chatfilter.ini" );
	m_bOnlyUseSystemMsgWnd = resultNum;

	GetINIBool( "global", "UseSystemMsg", resultNum, "chatfilter.ini" );
	m_bSystemMsgWnd = resultNum;
	
	// 데미지 - DamageBox
	GetINIBool( "global", "SystemMsgWndDamage", resultNum, "chatfilter.ini" );
	m_bDamageOption = resultNum;
	
	// 소모성아이템사용 - ItemBox
	GetINIBool( "global", "SystemMsgWndExpendableItem", resultNum, "chatfilter.ini" );
	m_bUseSystemItem = resultNum;

	// 월드 채팅 스피커
	GetINIBool( "global", "UseWorldChatSpeaker", resultNum, "chatfilter.ini" );
	m_bWorldChatSpeaker = resultNum;

	GetINIString("global", "Keyword0", m_Keyword0, "chatfilter.ini");
	GetINIString("global", "Keyword1", m_Keyword1, "chatfilter.ini");
	GetINIString("global", "Keyword2", m_Keyword2, "chatfilter.ini");
	GetINIString("global", "Keyword3", m_Keyword3, "chatfilter.ini");
}
	

//~ SetINIString("global", "Keyword0", script.m_Keyword0, "chatfilter.ini");
//~ SetINIString("global", "Keyword1", script.m_Keyword1, "chatfilter.ini");
//~ SetINIString("global", "Keyword2", script.m_Keyword2, "chatfilter.ini");
//~ SystemString(355)
//~ m_ChannelAssignComboBox.AddStringWithReserved(Get, 1);
//~ m_ChannelAssignComboBox.AddStringWithReserved(GetSystemString(188), 2);
//~ m_ChannelAssignComboBox.AddStringWithReserved(GetSystemString(128), 3);
//~ m_ChannelAssignComboBox.AddStringWithReserved(GetSystemString(559), 4);
//~ m_ChannelAssignComboBox.AddStringWithReserved(GetSystemString(1961), 5);
//~ m_ChannelAssignComboBox.AddStringWithReserved(GetSystemString(1962), 6);
//~ m_ChannelAssignComboBox.AddStringWithReserved(GetSystemString(1963), 7);
//~ m_ChannelAssignComboBox.AddStringWithReserved(GetSystemString(1964), 8);
defaultproperties
{
}
