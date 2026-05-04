class Shortcut extends UICommonAPI;

var bool m_chatstateok;

//현재 지역 PeaceZone인가
var int IsPeaceZone;	

const CHAT_WINDOW_NORMAL = 0;
const CHAT_WINDOW_TRADE = 1;
const CHAT_WINDOW_PARTY = 2;
const CHAT_WINDOW_CLAN = 3;
const CHAT_WINDOW_ALLY = 4;
const CHAT_WINDOW_COUNT = 5;
const CHAT_WINDOW_SYSTEM = 5;		// 시스템 메시지 창

const DIALOGID_Gohome = 44420;

function OnRegisterEvent()
{
	RegisterEvent( EV_ShortcutCommand );
	RegisterEvent( EV_StateChanged );		// lpislhy
	RegisterEvent( EV_ShowWindow );

	RegisterEvent( EV_DialogOK );
	RegisterEvent( EV_DialogCancel );
	RegisterEvent( EV_SetRadarZoneCode );
}

function OnLoad()
{	
}

function OnEvent( int a_EventID, String a_Param )
{
	local int zonetype;
	
	switch( a_EventID )
	{
		case EV_ShortcutCommand:
			HandleShortcutCommand( a_Param );
			break;
		case EV_StateChanged:
			HandleStateChange( a_Param );
			break;
		case EV_ShowWindow:		
			HandleShortcutKeyEvent( a_Param );
			break;
		//메뉴 작업시 추가.
		case EV_SetRadarZoneCode:
			ParseInt( a_Param, "ZoneCode", zonetype );		
			if (zonetype == 12)
			{
				IsPeaceZone = 1;
			}
			else
			{
				IsPeaceZone = 0;
			}
			break;

		case EV_DialogOK:
			HandleDialogOK();
			break;
		default:
			break;
	}
}

Function HandleShortcutKeyEvent( string a_Param )
{
	local string WNDName;
	local OptionWnd o_script;
	local TargetStatusWnd t_script;
	local ShortcutWnd s_script;
	local WindowHandle TempWnd;

	ParseString(a_Param, "Name", WNDName);
	o_script = OptionWnd( GetScript( "OptionWnd" ) );
	t_script = TargetStatusWnd( GetScript("TargetStatusWnd") );
	s_script = ShortcutWnd( GetScript("ShortcutWnd") );
	
	//Debug ( "HandleShortcutKeyEvent" @ WNDName );
	switch (WNDName)
	{
		case "GMWnd":
		case "GMClanWnd":
		case "GMDetailStatusWnd":
		case "GMInventoryWnd":
		case "GMMagicSkillWnd":
		case "GMQuestWnd":
		case "GMWarehouseWnd":
		case "GMSnoopWnd":
		case "GMPetitionWnd":
			if( !IsBuilderPC() )
				return;
		break;
	}
	
	switch (WNDName)
	{
		case "InventoryWnd":
			ExecuteEvent(EV_InventoryToggleWindow);	
			break;
		case "MacroWnd":
			ExecuteEvent(EV_MacroShowListWnd);
			break;
		case "PartyMatchWnd":
			HandlePartyMatchingOnOff();
			break;
		case "BoardWnd":
			
			TempWnd=GetWindowHandle("BoardWnd");

			if (TempWnd.isShowWindow())
				TempWnd.HideWindow();
			else 
				ExecuteEvent(EV_ShowBBS);
			
			break;
		case "MinimapWnd":
			RequestOpenMinimap();
			break;
		
		case "HelpHtmlWnd":
			HandleShowHelpHtmlWnd();
			break;
		
		case "FN_HideDropItemSilhauette":
			if (GetOptionBool("ScreenInfo", "HideDropItem"))
			{
				SetOptionBool( "ScreenInfo", "HideDropItem", false );
			}
			else
			{
				SetOptionBool( "ScreenInfo", "HideDropItem", true );
			}
			o_script.InitScreenInfoOption();
			break;
		case "FN_SendTargetedCharacterMessage":
			if (t_script.g_NameStr == "")
			{
			}
			else 
			{
				/*
				 *roleback chatMessage > chatWnd
				 */
				//callGFxFunction("ChatMessage","sendWhisper", t_script.g_NameStr);
				SetChatMessage( "\"" $ t_script.g_NameStr $ " " );
			}
			break;
			//
		case "FN_MuteAllAudio":
			if (GetOptionBool("Audio", "AudioMuteOn"))
			{
				SetOptionBool( "Audio", "AudioMuteOn", false );
			}
			else
			{
				SetOptionBool( "Audio", "AudioMuteOn", true );
			}
			o_script.InitControlOption();
			break;
		case "FN_SHORTCUTEXPAND":
			s_script.OnClickExpandShortcutButton();
			break;
		case "FN_UILocReset":
			o_script.SetDefaultPositionByClick();
			break;
		case "SystemMenuWnd":
			break;
		//메뉴 리뉴얼로인하여 추가.
		//우편함
		case "Post":
			HandleShowPostBoxWnd();
			break;		
		//단축키 변경창
		case "ShortcutAssign":
			HandleShowShortcutAssignWnd();
			break;
		//인스턴스존
		case "InstancedZone":			 
			RequestInzoneWaitingTime();
			break;
		//동영상 녹화
		case "Rec":
			HandleShowMovieCaptureWnd();
			break;
		//리플레이 녹화
		case "Replayrec":
			DoAction( class'UICommonAPI'.static.GetItemID(55) );
			break;
		//상품인벤토리
		case "Productinven":
			HandleShowProductInventory();
			break;			
		//판매상점
		case "ShopSell":
			DoAction( class'UICommonAPI'.static.GetItemID(10) );
			break;
		//구매상점
		case "ShopBuy":
			DoAction( class'UICommonAPI'.static.GetItemID(28) );
			break;
		//일괄판매상점
		case "ShopSellAll":
			DoAction( class'UICommonAPI'.static.GetItemID(61) );
			break;
		//상점검색
		case "ShopSearch":
			DoAction( class'UICommonAPI'.static.GetItemID(57) );
			break;
		//진정
		case "Petition":
			HandleShowPetitionBegin();
			break;	
		//홈페이지
		case "Homepage":
			linkHomepage();
			break;
		//PC방 포인트
		case "PcRoom":
			HandleToggleShowPCCafeEventWnd();
			break;
		Default:
			WindowOpenOrClose(WNDName);
		break;
	}
}


/* ****************************************************
 * 윈도우 열고 닫기 
 **************************************************** */

// 서버 타입에 의한 윈도우 이름 받기
function string getWindowNameByServerType( string WNDName )
{
	// GFx용 채팅 윈도우 롤백 코드.
	if ( WNDName ==  "ChatMessage" ) WNDName = "ChatWnd";

	// 클래식 윈도우
	else if ( getInstanceUIData().getisClassicServer() )
	{
		WNDName = getClassicWindowName(WNDName);
	}
	// 아레나 윈도우
	else if ( getInstanceUIData().getIsArenaServer() )
	{
		WNDName = getArenaWindowName (WNDName);
	}	

	return WNDName;
}

// 클래식 윈도우로 따로 만들어져 있는 윈도우들 목록
function string getClassicWindowName ( string WNDName )
{
	switch ( WNDName )
	{
	case "ClanWnd":
	case "DetailStatusWnd":
		return WNDName $ "Classic";
	}
	return WNDName;
}

// 아레나 윈도우로 따로 만들어져 있는 윈도우들 목록
function string getArenaWindowName ( string WNDName )
{
	switch ( WNDName )
	{	
	// #3038 [아레나] M3 - 사용하지 않는 기능 제거 : 케릭터 정보 창
	case "DetailStatusWnd":
		return WNDName $ "Classic";
	}
	return WNDName;
}

// 사운드 받기
function getSoundTypeByWndName ( string WndName, out EInterfaceSoundType openSound, out EInterfaceSoundType closeSound ) 
{
	switch  (WNDName) //사운드 세팅
	{	
	case "MagicSkillWnd":
		openSound = IFST_MAPWND_OPEN;
		closeSound = IFST_MAPWND_CLOSE;
		break;
	case "ActionWnd":
	case "DetailStatusWnd":
	case "DetailStatusWndClassic":
		openSound =  IFST_WINDOW_OPEN;
		closeSound = IFST_WINDOW_CLOSE;
		break;	
	default :
		openSound = IFST_STATUSWND_OPEN;
		closeSound = IFST_STATUSWND_CLOSE;
		break;
	}
}

function HandleStopShowWindow( string a_Param ) 
{
	local String WNDName;
	
	parseString ( a_Param , "Name", WNDName );
	
	if ( inStr ( WNDName, "ArenaScoreBoardWnd" ) > -1 )
	{		
		CallGFxFunction( "ArenaScoreBoardWnd", "hide", "");
	}
}

function WindowOpenOrClose( string WNDName)
{
	local EInterfaceSoundType openSound, closeSound;	

	local WindowHandle WNDNameHandle;
	local int tempVars;	
	//local int nUsePledgeV2Live, nUsePledgeV2Classic;
	
	WNDNameHandle = GetWindowHandle ( getWindowNameByServerType (WndName) ) ;

	getSoundTypeByWndName(WndName, openSound, closeSound ) ;	
	
	switch ( WNDName ) 
	{
		case "ArenaRankingWnd":
		case "RadarMapWnd" :
			if ( class'UIAPI_WINDOW'.static.IsShowWindow( WNDName) ) 		
				class'UIAPI_WINDOW'.static.HideWindow( WNDName );						
			else 		
				class'UIAPI_WINDOW'.static.ShowWindow( WNDName );
			break;		
		// 아레나 스코어 보드 
		case "ArenaScoreBoardWnd":			
			CallGFxFunction( "ArenaScoreBoardWnd", "show", "");
			break;
		//case "ArenaScoreBoardWndShow":
		//	CallGFxFunction( "ArenaScoreBoardWnd", "show", "");
		//	break;
		//case "ArenaScoreBoardWndHide":
		//	CallGFxFunction( "ArenaScoreBoardWnd", "hide", "");
		//	break;
		case "OptionWnd":
			toggleShowOptionWnd();
			break;
		// 채팅창에 붙어 있는 월드맵 채트 박스 처리
		case "ChatWnd":		
			if(WNDNameHandle.IsShowWindow())
			{
				callGFxFunction( "WorldChatBox","ToggleShowWnd", "hide");
				WNDNameHandle.HideWindow();
				PlayConsoleSound(closeSound);
			}
			else
			{
				GetINIBool( "global", "UseWorldChatSpeaker", tempVars, "chatfilter.ini" );		
				if(bool(tempVars))
				{
					callGFxFunction( "WorldChatBox","ToggleShowWnd", "show");
				}

				WNDNameHandle.ShowWindow();
				WNDNameHandle.SetFocus();
				PlayConsoleSound(openSound);
			}		
			break;

		case "ClanWnd":
		case "ClanWndClassic":

			// 차원 이동 후, 혈맹 창 안나오게..
			if ( IsPlayerOnWorldRaidServer() ) 
			{
				getInstanceL2Util().showGfxScreenMessage( GetSystemMessage(4047));
				return;
			}

			// 클래식
			if ( getInstanceUIData().getisClassicServer() )
			{
				//GetINIBool ( "Localize", "UsePledgeV2Classic", nUsePledgeV2Classic, "L2.ini" );

				// 혈맹 리뉴얼 UI 사용
				if (getInstanceL2Util().isClanV2())
					toggleWindow("ClanGfxWnd", true, true);
				else
					toggleWindow("ClanWndClassic", true, true);
			}
			else
			{
				// 라이브
				//GetINIBool ( "Localize", "UsePledgeV2Live", nUsePledgeV2Live, "L2.ini" );

				// 혈맹 리뉴얼 UI 사용
				//if (nUsePledgeV2Live > 0)
				//	toggleWindow("ClanGfxWnd", true, true);
				//else
				//	toggleWindow("ClanWnd", true, true);

				if(getInstanceL2Util().isClanV2())
				{
					toggleWindow("ClanGfxWnd", true, true);
				}
				else
				{
					toggleWindow("ClanWnd", true, true);
				}
			}

			break;

		// 기본 showhide
		Default :
			if(WNDNameHandle.IsShowWindow())
			{
				WNDNameHandle.HideWindow();
				PlayConsoleSound(closeSound);
			}
			else
			{
				WNDNameHandle.ShowWindow();
				WNDNameHandle.SetFocus();
				PlayConsoleSound(openSound);
			}
			break;
	}
}

function toggleShowOptionWnd()
{
	local OptionWnd win;
	win = OptionWnd( GetScript("OptionWnd") );
	win.ToggleOpenMeWnd(false); //옵션창만 열기
}

/**
 * 단축키 창 열기
 */
function HandleShowShortcutAssignWnd()
{
	local OptionWnd win;	
	win = OptionWnd( GetScript("OptionWnd") );
	win.ToggleOpenMeWnd(true);  //숏컷 창으로 열기 
}

// 빌더 명령어에 의해 창을 감추고 보여주는 함수 PC방 포인트
function HandleToggleShowPCCafeEventWnd()
{
	//branch GD35_0828 2013-12-06 luciper3 - 해당 클래스에서 처리하도록 한다. 
	local InfoWnd script;

	script = InfoWnd( GetScript( "InfoWnd" ) );
	
	if( script != none )
		script.HandleToggleShowPCCafeEventWnd();
	//end of branch

// 	local bool bOption;
// 	local WindowHandle win;	
//
// 	win = GetWindowHandle( "PCCafeEventWnd" );
// 
// 	bOption = GetOptionBool( "ScreenInfo", "IsPcRoomBox" );
// 	
// 	if(win.isShowWindow())
// 	{
// 		win.HideWindow();
// 	}
// 	else 
// 	{
// 		if ( !bOption ) {
// 			win.ShowWindow();
// 		}
// 	}	
}

/**
 * 동영상 녹화 창 열기
 */
function HandleShowMovieCaptureWnd()
{
	local bool tmpBool;
	local WindowHandle win;	
	local WindowHandle win1;	

	win = GetWindowHandle( "MovieCaptureWnd_Expand" );
	win1 = GetWindowHandle( "MovieCaptureWnd" );

	tmpBool =IsNowMovieCapturing();

	//켑쳐 되고 있다면
	if(tmpBool)
	{
		win.HideWindow();
		//확장 창이 보여 진다면
		if ( win.IsShowWindow() )
		{
			PlayConsoleSound(IFST_WINDOW_CLOSE);
			win.HideWindow();
		}
		else 
		{			
			PlayConsoleSound(IFST_WINDOW_OPEN);
			win.ShowWindow();
			win.SetFocus();
		}
	} 
	//아니라면 일반 창 열고 닫기
	else 
	{
		if (win1.IsShowWindow())
		{
			PlayConsoleSound(IFST_WINDOW_CLOSE);
			win1.HideWindow();
		} 
		else
		{	
			PlayConsoleSound(IFST_WINDOW_OPEN);
			win1.ShowWindow();
			win1.SetFocus();

		}
	}	
}

/**
 * 진정 창 열기
 */
function HandleShowPetitionBegin()
{
	local WindowHandle win;	
	local WindowHandle win1;	
	local WindowHandle win2;	
	local PetitionMethod useNewPetition;

	win = GetWindowHandle( "NewUserPetitionWnd" );
	win1 = GetWindowHandle( "UserPetitionWnd" );
	win2 = GetWindowHandle( "WebPetitionWnd" );

	useNewPetition = GetPetitionMethod();

	if( useNewPetition == PetitionMethod_New )
	{
		if(win.IsShowWindow())
		{
			PlayConsoleSound(IFST_WINDOW_CLOSE);
			win.HideWindow();
		}
		else
		{
			PlayConsoleSound(IFST_WINDOW_OPEN);
			RequestShowPetitionAsMethod();
		}
	}
	else if( useNewPetition == PetitionMethod_Default )
	{
		if (win1.IsShowWindow())
		{
			PlayConsoleSound(IFST_WINDOW_CLOSE);
			win1.HideWindow();
		}
		else
		{
			PlayConsoleSound(IFST_WINDOW_OPEN);
			win1.ShowWindow();
			win1.SetFocus();
		}
	}
	else if( useNewPetition == PetitionMethod_Web )
	{
		if (win2.IsShowWindow())
		{
			PlayConsoleSound(IFST_WINDOW_CLOSE);
			win2.HideWindow();
		}
		else
		{
			PlayConsoleSound(IFST_WINDOW_OPEN);
			RequestShowPetitionAsMethod();
		}
	}
}

/**
 * 홈페이지 열기
 */
function linkHomePage()
{
	class'UICommonAPI'.static.DialogSetID( DIALOGID_Gohome );
	class'UICommonAPI'.static.DialogShow( DialogModalType_Modalless, DialogType_OKCancel, GetSystemMessage( 3208 ), string(Self));
}

//홈페이지 링크(10.1.18 문선준 추가)
function HandleDialogOK()
{	
	if( ! class'UICommonAPI'.static.DialogIsOwnedBy( string(Self) ) )
		return;

	switch( class'UICommonAPI'.static.DialogGetID() )
	{
	case DIALOGID_Gohome:
		OpenL2Home();
		break;
	}
}

//상품 인벤토리 열기
function HandleShowProductInventory()
{
	local WindowHandle win;	
	local WindowHandle win1;	
	local L2Util util;
	
	win = GetWindowHandle( "ProductInventoryWnd" );
	win1 = GetWindowHandle( "ShopWnd" );
	util = L2Util(GetScript("L2Util"));	

	//보여지면 닫기
	if( win.isShowWindow())
	{
		PlayConsoleSound(IFST_INVENWND_CLOSE);
		win.HideWindow();
	}
	//아니면 열기
	else 
	{	
		util.ItemRelationWindowHide( "ProductInventoryWnd" );

		if( !win1.IsShowWindow() )
		{
			PlayConsoleSound(IFST_INVENWND_OPEN);
			win.ShowWindow();
			win.SetFocus();
		}
	}
}

/**
 * 우폄함 열기
 */
function HandleShowPostBoxWnd()
{
	local WindowHandle win;
	win = GetWindowHandle( "PostBoxWnd" );
	
	if( win.IsShowWindow() )
	{
		win.HideWindow();
		PlayConsoleSound(IFST_WINDOW_CLOSE);
	}
	else
	{
		PlayConsoleSound(IFST_WINDOW_OPEN);
		RequestRequestReceivedPostList();
		if (IsPeaceZone == 0)
			AddSystemMessage(3066);	
	}
}

Function ClosePartyMatchingWnd()
{
	local WindowHandle TaskWnd;
	local PartyMatchWnd p_script;
	p_script = PartyMatchWnd( GetScript( "PartyMatchWnd" ) );
	
	if(CREATE_ON_DEMAND==0)
		TaskWnd = GetHandle("PartyMatchWnd");
	else
		TaskWnd = GetWindowHandle("PartyMatchWnd");

	TaskWnd.HideWindow();
	p_script.OnSendPacketWhenHiding();
}


Function HandleShowHelpHtmlWnd()
{
	local  AgeWnd script1;	// 등급표시 스크립트 가져오기
	
	local string strParam;
	ParamAdd(strParam, "FilePath", "..\\L2text\\help.htm");
	ExecuteEvent(EV_ShowHelp, strParam);
	
	script1 = AgeWnd( GetScript("AgeWnd") );
	
	if(script1.bBlock == false)	script1.startAge();	//등급표시를 켜준다. 
}

Function HandlePartyMatchingOnOff()
{
	local WindowHandle PartyMatchRoomWnd;
	local windowHandle PartyMatchWnd;
	local PartyMatchRoomWnd p2_script;
	local L2Util util;

	if ( getInstanceUIData().getIsArenaServer() ) 
	{
		util = L2Util(GetScript("L2Util"));	
		util.showGfxScreenMessage (  GetSystemMessage (5517) ) ;
	}

	PartyMatchWnd = GetWindowHandle("PartyMatchWnd");
	PartyMatchRoomWnd = GetWindowHandle("PartyMatchRoomWnd"); 
	
	
	//class'UIAPI_WINDOW'.static.IsMinimizedWindow( "PartyMatchRoomWnd" )
	p2_script = PartyMatchRoomWnd( GetScript( "PartyMatchRoomWnd" ) );

	if(PartyMatchWnd.IsShowWindow())
	{
		ClosePartyMatchingWnd();
	}
	else
	{
		if ( PartyMatchRoomWnd.IsShowWindow() )
		{					
			PartyMatchRoomWnd.HideWindow();	
			//p2_script.ExitPartyRoom();		
			
			p2_script.OnSendPacketWhenHiding();
			PartyMatchWnd.SetTimer( 1991, 500 );			
		}
		else
		{	
			class'PartyMatchAPI'.static.RequestOpenPartyMatch();			
		}
	}
}

function OnTimer(int TimerID)
{
	if(TimerID == 1991)
	{		
		ClosePartyMatchingWnd();	
		class'UIAPI_WINDOW'.static.KillUITimer("ShortcutTab",1991); 		
	}
}

function OnExitState( name a_NextStateName )
{
	if (a_NextStateName == 'GamingState')
	{
		//debug("what?");
		m_chatstateok = true;
	}
	else
	{
		m_chatstateok = false;
	}
}


function HandleShortcutCommand( String a_Param )
{
	local String Command;
	
	if( ParseString( a_Param, "Command", Command ) )
	{
		switch( Command )
		{
		case "CloseAllWindow":		// alt + w
			HandleCloseAllWindow();
			break;
		case "ShowChatWindow":		// alt + j
			
			HandleShowChatWindow();
			//if (m_chatstateok == true)
			//{
			//	HandleShowChatWindow();
			//}
			break;
		case "SetPrevChatType":		// alt + page up	
			HandleSetPrevChatType();
			break;
		case "SetNextChatType":		// alt + page down
			HandleSetNextChatType();
			break;
		case "shortcutreset":
			class'ShortcutAPI'.static.RestoreDefault();
			break;
		case "shortcutsave":
			class'ShortcutAPI'.static.Save();
			break;
		case "shortcutload":
			class'ShortcutAPI'.static.RequestList();
			break;
		case "test":
			HandleShortcutTest();
			break;
		case "printshortcut":
			HandlePrintShortcut();
			break;

		case "getPrevTarget" :if ( getInstanceUIData().getIsArenaServer()) ExecuteCommand("/이전타겟") ; break;
		case "getNextTarget" :if ( getInstanceUIData().getIsArenaServer()) ExecuteCommand("/다음타겟") ; break;
		case "useRunSkill" : if ( getInstanceUIData().getIsArenaServer()) setUseSkill ( 18651 )  ;break;		
		case "useBaseRecallSkill" : if ( getInstanceUIData().getIsArenaServer()) setUseSkill ( 18652 ) ; break;

		case "HideAllWindow":
			//Debug( "HandleShortcutCommand" @ a_Param ) ;
			HandleHideAllWindow();
		case "StopShowWindow":

		default:
			
			if ( InStr( Command ,"StopShowWindow") > -1 ) 
			{			
				HandleStopShowWindow( a_Param );
			}
			break;
		}
	}
}

function setUseSkill ( int skillID ) 
{
	local itemID skillItemID;
	skillItemID.ClassID = skillID;
	Debug ( "setUseSkill" @ skillItemID.ClassID ) ;
	UseSkill(skillItemID, int(EShortCutItemType.SCIT_SKILL));
}


function HandleHideAllWindow()
{

}

function HandlePrintShortcut()
{
	local Array<ShortcutCommandItem> commandlist;
	local Array<string> grouplist;
	local int i;
	class'ShortcutAPI'.static.GetGroupList(groupList);
	for( i = 0 ; i < grouplist.Length ; ++i )
	{
		//debug("Group : " $ grouplist[i] );
		commandlist.Length = 0;
		class'ShortcutAPI'.static.GetGroupCommandList(grouplist[i], commandlist);
		//for( j=0 ; j < commandlist.Length ; ++j )
			//debug("key : " $ commandlist[j].Key $ ", subkey1 : " $ commandlist[j].subkey1 $ ", subkey2 : " $ commandlist[j].subkey2 $ ", action : " $ commandlist[j].sAction $ ", command : " $ commandlist[j].sCommand $ ", id : " $ commandlist[j].id);
	}
	grouplist.Length = 0;
	class'ShortcutAPI'.static.GetActiveGroupList(grouplist);
	for(i=0 ; i<grouplist.Length ; ++i)
	{
		//debug("ActiveGroup : " $ grouplist[i]);
	}
}
//~ function HandleShortcutTest()
//~ {
	//~ local ShortcutCommandItem item;
	//~ local array<ShortcutCommandItem> items;
	//~ local int i;
	//~ item.sCommand = "ZoomIn";
	//~ item.key = "MouseWheelUp";
	//~ item.subkey1 = "";
	//~ item.subkey2 = "";
	//~ item.sState = "GamingState";
	//~ if( class'ShortcutAPI'.static.AssignShortcut(item) )
		//~ Log("ShortcutAssign Success ZoomIn");
	//~ item.sCommand = "ZoomOut";
	//~ item.key = "MouseWheelDown";
	//~ item.subkey1 = "";
	//~ item.subkey2 = "";
	//~ item.sState = "GamingState";
	//~ if( class'ShortcutAPI'.static.AssignShortcut(item) )
		//~ Log("ShortcutAssign Success ZoomOut");
	//~ item.sCommand = "TurnBack";
	//~ item.key = "MiddleMouse";
	//~ item.subkey1 = "";
	//~ item.subkey2 = "";
	//~ item.sState = "GamingState";
	//~ if( class'ShortcutAPI'.static.AssignShortcut(item) )
		//~ Log("ShortcutAssign Success TurnBack" );

	//~ item.sCommand = "ShowInventoryWindow";
	//~ item.key = "i";
	//~ item.subkey1 = "alt";
	//~ item.subkey2 = "";
	//~ item.sState = "GamingState";
	//~ if( class'ShortcutAPI'.static.AssignShortcut(item) )
		//~ Log("ShortcutAssign Success TurnBack ShowInventoryWindow" );

	//~ item.sCommand = "PKKey";
	//~ item.key = "Ctrl";
	//~ item.subkey1 = "";
	//~ item.subkey2 = "";
	//~ item.sState = "";
	//~ item.sCategory = "";
	//~ if( class'ShortcutAPI'.static.AssignSpecialKey(item) )
		//~ Log("SpecialKeyAssign Success PKKey");

	//~ class'ShortcutAPI'.static.GetCommandItems(items);
	//~ for(i=0 ; i<items.Length ; ++i)
	//~ {
		//~ Log("Shortcut " $ i $ ": key(" $ items[i].key $ "), subkey1(" $ items[i].subkey1 $ "), subkey2(" $ items[i].subkey2 $ "), command(" $ items[i].sCommand $ "), state(" $ items[i].sState $ "), category(" $ items[i].sCategory $ ")");
	//~ }
//~ }

function HandleShortcutTest()
{
}

/*
 * rollback chatmessage > chatWnd 2012.11.01
 */
function HandleShowChatWindow()		// alt + j
{
	local WindowHandle handle;
	local int tempVars;

	handle = GetWindowHandle( "ChatWnd" );
	
	if( handle.IsShowWindow() )
	{
		handle.HideWindow();
		GetINIBool( "global", "SystemMsgWnd", tempVars, "chatfilter.ini" );
		
		if(!bool(tempVars))
		{
			class'UIAPI_WINDOW'.static.HideWindow("SystemMsgWnd");
		}
			
	}
	else
	{
		handle.ShowWindow();
		GetINIBool( "global", "SystemMsgWnd", tempVars, "chatfilter.ini" );
		
		if(bool(tempVars))
		{	
			class'UIAPI_WINDOW'.static.ShowWindow("SystemMsgWnd");
		}
	}

	/* chatMessage 용

	local WindowHandle handle;

	if(CREATE_ON_DEMAND==0)
		handle = GetHandle( "ChatMessage" );
	else
		handle = GetWindowHandle( "ChatMessage" );
	
	if( handle.IsShowWindow() )
	{
		handle.HideWindow();
			
	}
	else
	{
		handle.ShowWindow();
	}
	*/
}



function HandleSetPrevChatType()		// alt + page up
{	
	/*
	 *rollback chatmessage > chatWnd
	 
	callGFxFunction("ChatMessage","setRemoteTabSelect", "true");
	*/
	
	local ChatWnd chatWndScript;			// 채팅 윈도우 클래스
	
	chatWndScript = ChatWnd( GetScript("ChatWnd") );	// 스크립트를 가져온다.
	
	//debug("chatWndScript.m_chatType" $ chatWndScript.m_chatType);
	switch (chatWndScript.m_chatType.UI)	
	{
		case CHAT_WINDOW_NORMAL:
			////chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_NORMAL);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_TRADE);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_PARTY);
			////chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_CLAN);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_ALLY);
			chatWndScript.ChatTabCtrl.SetTopOrder(4, true);
			chatWndScript.HandleTabClick("ChatTabCtrl4");
			break;
		case CHAT_WINDOW_TRADE:
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_NORMAL);
			////chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_TRADE);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_PARTY);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_CLAN);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_ALLY);
			chatWndScript.ChatTabCtrl.SetTopOrder(0, true);
			chatWndScript.HandleTabClick("ChatTabCtrl0");
			break;
		case CHAT_WINDOW_PARTY:
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_NORMAL);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_TRADE);
			////chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_PARTY);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_CLAN);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_ALLY);
			chatWndScript.ChatTabCtrl.SetTopOrder(1, true);
			chatWndScript.HandleTabClick("ChatTabCtrl1");
			break;
		case CHAT_WINDOW_CLAN:
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_NORMAL);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_TRADE);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_PARTY);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_CLAN);
			////chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_ALLY);
			chatWndScript.ChatTabCtrl.SetTopOrder(2, true);
			chatWndScript.HandleTabClick("ChatTabCtrl2");
			break;
		case CHAT_WINDOW_ALLY:
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_NORMAL);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_TRADE);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_PARTY);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_CLAN);
			////chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_ALLY);
			chatWndScript.ChatTabCtrl.SetTopOrder(3, true);
			chatWndScript.HandleTabClick("ChatTabCtrl3");
			break;		
	}
}

function HandleSetNextChatType()		// alt + page down
{
	/*
	 *rollback chatmessage > chatWnd
	 
	callGFxFunction("ChatMessage","setRemoteTabSelect", "false");
	*/

	local ChatWnd chatWndScript;			// 채팅 윈도우 클래스
	
	chatWndScript = ChatWnd( GetScript("ChatWnd") );	// 스크립트를 가져온다.
	
	//debug("chatWndScript.m_chatType" $ chatWndScript.m_chatType);
	switch (chatWndScript.m_chatType.UI)	
	{
		case CHAT_WINDOW_NORMAL:
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_NORMAL);
			////chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_TRADE);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_PARTY);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_CLAN);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_ALLY);
			chatWndScript.ChatTabCtrl.SetTopOrder(1, true);
			chatWndScript.HandleTabClick("ChatTabCtrl1");
			break;
		case CHAT_WINDOW_TRADE:
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_NORMAL);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_TRADE);
			////chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_PARTY);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_CLAN);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_ALLY);
			chatWndScript.ChatTabCtrl.SetTopOrder(2, true);
			chatWndScript.HandleTabClick("ChatTabCtrl2");
			break;
		case CHAT_WINDOW_PARTY:
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_NORMAL);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_TRADE);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_PARTY);
			////chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_CLAN);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_ALLY);
			chatWndScript.ChatTabCtrl.SetTopOrder(3, true);
			chatWndScript.HandleTabClick("ChatTabCtrl3");
			break;
		case CHAT_WINDOW_CLAN:
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_NORMAL);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_TRADE);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_PARTY);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_CLAN);
			////chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_ALLY);
			chatWndScript.ChatTabCtrl.SetTopOrder(4, true);
			chatWndScript.HandleTabClick("ChatTabCtrl4");
			break;
		case CHAT_WINDOW_ALLY:
			////chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_NORMAL);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_TRADE);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_PARTY);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_CLAN);
			//chatWndScript.ChatTabCtrl.MergeTab(CHAT_WINDOW_ALLY);
			chatWndScript.ChatTabCtrl.SetTopOrder(0, true);
			chatWndScript.HandleTabClick("ChatTabCtrl0");
			break;		
	}
}

// alt + w
function HandleCloseAllWindow()
{
	local WindowHandle handle;
	local int i;
	local array<string> WndList;
	local array<string> GFxWndList;

	local int numOfWnd;
	
	local PrivateShopWnd PrivateShopWndScript;
	local RefineryWnd RefineryWndScript;

	/*
	 *2012.12.12 개인판매 창이 alt W로 닫힐 때 오류 발생
	 */
	PrivateShopWndScript = PrivateShopWnd( GetScript("PrivateShopWnd") );
	PrivateShopWndScript.RequestQuit();	

	/*
	 *2012.12.17 드워프 공방 창이 alt W 로 닫힐 때 다시 열리지 않는 오류 수정 > 
	 */
	class'RecipeAPI'.static.RequestRecipeShopManageQuit();
	
	/*
	 *2013.2.4 인첸 창이 alt + W 로 닫힐 때 다시 열리지 않는 오류 수정 > 
	 */
	class'EnchantAPI'.static.RequestExCancelEnchantItem();

	/*
	 *2013.2.4 제련 창이 alt + W 로 닫힐 때 다시 열리지 않는 오류 수정 > 
	 */
	RefineryWndScript = RefineryWnd( GetScript("RefineryWnd") );
	RefineryWndScript.OnClickCancelButton();

	numOfWnd = 0;
	WndList[numOfWnd++] = "ActionWnd";
	WndList[numOfWnd++] = "AttributeEnchantWnd";
	WndList[numOfWnd++] = "AttributeRemoveWnd";
	WndList[numOfWnd++] = "BoardWnd";
	WndList[numOfWnd++] = "CalculatorWnd";
	//WndList[numOfWnd++] = "ChatFilterWnd";	
	WndList[numOfWnd++] = getWindowNameByServerType ("ClanWnd");
	WndList[numOfWnd++] = "ConsoleWnd";
	WndList[numOfWnd++] = "CouponEventWnd";
	WndList[numOfWnd++] = "DeliverWnd";
	WndList[numOfWnd++] = "SelectDeliverWnd";
	WndList[numOfWnd++] = getWindowNameByServerType ("DetailStatusWnd" );
	WndList[numOfWnd++] = "MailBtnWnd";
	WndList[numOfWnd++] = "HelpHtmlWnd";
	WndList[numOfWnd++] = "HelpWnd";
	WndList[numOfWnd++] = "HennaInfoWnd";
	WndList[numOfWnd++] = "HennaListWnd";
	WndList[numOfWnd++] = "HeroTowerWnd";
	WndList[numOfWnd++] = "HeroTowerWndWorld";
	WndList[numOfWnd++] = "InventoryWnd";
	WndList[numOfWnd++] = "ItemEnchantWnd";
	WndList[numOfWnd++] = "XMasSealWnd";
	WndList[numOfWnd++] = "MacroEditWnd";
	WndList[numOfWnd++] = "MacroListWnd";
	WndList[numOfWnd++] = "MagicSkillWnd";
	//WndList[numOfWnd++] = "MainWnd";
	WndList[numOfWnd++] = "ManorCropInfoChangeWnd";
	WndList[numOfWnd++] = "ManorCropInfoSettingWnd";
	WndList[numOfWnd++] = "ManorCropSellChangeWnd";
	WndList[numOfWnd++] = "ManorCropSellWnd";
	//WndList[numOfWnd++] = "ManorInfo_Crop";
	//WndList[numOfWnd++] = "ManorInfo_Default";
	//WndList[numOfWnd++] = "ManorInfo_Seed";
	WndList[numOfWnd++] = "ManorInfoWnd";
	WndList[numOfWnd++] = "ManorSeedInfoChangeWnd";
	WndList[numOfWnd++] = "ManorSeedInfoSettingWnd";
	WndList[numOfWnd++] = "ManorShopWnd";
	WndList[numOfWnd++] = "MinimapWnd";
	//WndList[numOfWnd++] = "MinimapWnd_Expand";
	//WndList[numOfWnd++] = "MoviePlayerWnd";
	WndList[numOfWnd++] = "MultiSellWnd";
	WndList[numOfWnd++] = "OptionWnd";
	WndList[numOfWnd++] = "PetitionFeedBackWnd";
	WndList[numOfWnd++] = "PetitionWnd";
	WndList[numOfWnd++] = "UserPetitionWnd";
	WndList[numOfWnd++] = "PetWnd";
	WndList[numOfWnd++] = "PrivateShopWnd";
	WndList[numOfWnd++] = "QuestListWnd";
	WndList[numOfWnd++] = "QuestTreeWnd";	
	WndList[numOfWnd++] = "RecipeBookWnd";
	WndList[numOfWnd++] = "RecipeBuyListWnd";
	WndList[numOfWnd++] = "RecipeBuyManufactureWnd";
	WndList[numOfWnd++] = "RecipeManufactureWnd";
	WndList[numOfWnd++] = "RecipeShopWnd";
	WndList[numOfWnd++] = "RecipeTreeWnd";
	WndList[numOfWnd++] = "RefineryWnd";
	WndList[numOfWnd++] = "ReplayListWnd";
	WndList[numOfWnd++] = "ReplayLogoWnd";
	//WndList[numOfWnd++] = "ScenePlayerWnd";
	WndList[numOfWnd++] = "ShopWnd";
	WndList[numOfWnd++] = "SiegeInfoWnd";
	//WndList[numOfWnd++] = "SkillEnchantInfoWnd";
	//WndList[numOfWnd++] = "SkillEnchantWnd";
	//WndList[numOfWnd++] = "SSQMainBoard";
	//WndList[numOfWnd++] = "SSQMainBoard_SSQMainEventWnd";
	//WndList[numOfWnd++] = "SSQMainBoard_SSQSealStatusWnd";
	//WndList[numOfWnd++] = "SSQMainBoard_SSQStatusWnd";
	WndList[numOfWnd++] = "SummonedWnd";
	//WndList[numOfWnd++] = "SystemMenuWnd";
	WndList[numOfWnd++] = "TownMapWnd";
	WndList[numOfWnd++] = "TradeWnd";
	WndList[numOfWnd++] = "SkillTrainClanTreeWnd";
	//WndList[numOfWnd++] = "SkillTrainInfoSubWndEnchant";
	//WndList[numOfWnd++] = "SkillTrainInfoSubWndNormal";
	WndList[numOfWnd++] = "SkillTrainInfoWnd";
	WndList[numOfWnd++] = "SkillTrainListWnd";
	WndList[numOfWnd++] = "TutorialViewerWnd";
	WndList[numOfWnd++] = "unrefineryWnd";
	WndList[numOfWnd++] = "WarehouseWnd";

	//파티 매칭
	WndList[numOfWnd++] = "PartyMatchWnd";
	//인맥
	WndList[numOfWnd++] = "PersonalConnectionsWnd";
	
	//2012.12.17 창 목록 추가 
	WndList[numOfWnd++] = "NPCDialogWnd";
	WndList[numOfWnd++] = "PostBoxWnd";						  	
	WndList[numOfWnd++] = "NewUserPetitionWnd";			
	WndList[numOfWnd++] = "ProductInventoryWnd";

	//2013.01.03 창 목록 추가 > 언급 된 닫히지 않는 창 목록 입니다.
	WndList[numOfWnd++] = "AuctionWnd";
	WndList[numOfWnd++] = "BlockCurWnd";						  	
	WndList[numOfWnd++] = "BlockEnterWnd";
	WndList[numOfWnd++] = "CleftEnterWnd";
	WndList[numOfWnd++] = "CleftCurWnd";        
	WndList[numOfWnd++] = "ColorNickNameWnd";
	WndList[numOfWnd++] = "DominionWarInfoWnd";
	WndList[numOfWnd++] = "FileRegisterWnd";
	WndList[numOfWnd++] = "KillPointRankWnd";	
	WndList[numOfWnd++] = "MagicskillGuideWnd";
	WndList[numOfWnd++] = "miniGame1Wnd";
	WndList[numOfWnd++] = "NewPetitionWnd";		
	//해외 사용 여부 확인 필요
	WndList[numOfWnd++] = "PetitionFeedBackWnd";	
	WndList[numOfWnd++] = "PostWriteWnd";
	WndList[numOfWnd++] = "PremiumItemGetWnd";
	WndList[numOfWnd++] = "PVPDetailedWnd";
	WndList[numOfWnd++] = "QuesthtmlWnd";	
	WndList[numOfWnd++] = "SeedShopWnd";      
	WndList[numOfWnd++] = "SellingAgencyWnd";
	WndList[numOfWnd++] = "TeleportBookMarkWnd";
	WndList[numOfWnd++] = "WebPetitionWnd";
	//2013.08.22 접속공지창 추가
	WndList[numOfWnd++] = "IngameNoticeWnd";
	//2013.09.09 쥬엘 인첸 창 추가
	WndList[numOfWnd++] = "ItemJewelEnchantWnd";
	//게임 이용 제한 윈도우
	WndList[numOfWnd++ ] = "PlayerAgeWnd";
		// path to awaken 
	WndList[numOfWnd++ ] = "BR_PathWnd";
	// 오늘의 할일
	WndList[numOfWnd++ ] = "ToDoListWnd";
	// 오늘의 할일 혈맹
	WndList[numOfWnd++ ] = "ToDoListClanWnd";
	//인벤토리 보기 윈도우
	WndList[numOfWnd++ ] = "InventoryViewer";
	// 집혼 
	WndList[numOfWnd++ ] = "EnsoulWnd";

	WndList[numOfWnd++ ] = "AttendCheckWnd";
	WndList[numOfWnd++ ] = "SiegeReportWnd";
	WndList[numOfWnd++ ] = "AgitDecoWnd";
	WndList[numOfWnd++ ] = "MonsterArenaResultWnd";
	WndList[numOfWnd++ ] = "MacroPresetWnd";
	WndList[numOfWnd++ ] = "IngameWebWnd";
	WndList[numOfWnd++ ] = "MonsterBookDetailedInfo";
	WndList[numOfWnd++ ] = "PrivateShopWndHistory";
	WndList[numOfWnd++ ] = "ItemLockWnd";

	//WndList[79]="ShortcutAssignWnd"; //옵션과 통합 2012.3.27
	
	for (i=0;i<WndList.Length; ++i)
	{			
		handle = GetWindowHandle( WndList[i] );
		if ( WndList[i] == "" );
		if( handle.IsShowWindow() )
			handle.HideWindow();
	}
	
	//2012.12.17 Gfx 창 목록 추가 
	numOfWnd = 0 ;
	GFxWndList[ numOfWnd ++ ] = "ClanSearch";
	GFxWndList[ numOfWnd ++ ] = "InstancedZoneHistoryWnd";
	GFxWndList[ numOfWnd ++ ] = "OptionWnd";

	GFxWndList[ numOfWnd ++ ] = "CardExchange";
	GFxWndList[ numOfWnd ++ ] = "CardExchangeB";
	GFxWndList[ numOfWnd ++ ] = "CardExchangeC";
	
	GFxWndList[ numOfWnd ++ ] = "AdenaDistributionWnd";
	GFxWndList[ numOfWnd ++ ] = "AbilityWnd";
	GFxWndList[ numOfWnd ++ ] = "AlchemyMixCubeWnd";
	GFxWndList[ numOfWnd ++ ] = "AlchemyOpener";
	GFxWndList[ numOfWnd ++ ] = "AlchemyItemConversionWnd";
	GFxWndList[ numOfWnd ++ ] = "FactionWnd";
	GFxWndList[ numOfWnd ++ ] = "VipInfoWnd";
	GFxWndList[ numOfWnd ++ ] = "IngameShopWnd";
	GFxWndList[ numOfWnd ++ ] = "LuckyGame";
	GFxWndList[ numOfWnd ++ ] = "MonsterBookWnd";
	GFxWndList[ numOfWnd ++ ] = "MiniMapGFxWnd";
	GFxWndList[ numOfWnd ++ ] = "EventInfoWnd";	
	GFxWndList[ numOfWnd ++ ] = "CardDrawEventWnd";	
	GFxWndList[ numOfWnd ++ ] = "ArenaRankingWnd";	
	GFxWndList[ numOfWnd ++ ] = "ClanRaidsWnd";	
	GFxWndList[ numOfWnd ++ ] = "ClanGfxWnd";	

	for ( i=0 ; i< GFxWndList.length ; i++ )
	{
		if ( class'UIAPI_WINDOW'.static.IsShowWindow ( GFxWndList[i] ) )
		{
			if (  GFxWndList[i]  == "AdenaDistributionWnd" )
			{
				//아데나 분배 창이 보여 지고 있을 때 alt + W로 취소 하게 되면, 
				callGFxFunction("AdenaDistributionWnd", "RequestDivideAdenaCancel", "");
			}
			class'UIAPI_WINDOW'.static.HideWindow( GFxWndList[i] );
		}
	}	
}

function HandleStateChange( String state )
{
	local	FlightShipCtrlWnd			scriptShip;
	local	FlightTransformCtrlWnd		scriptTrans;
	//local	MainMenu	                scriptMain;		

	scriptShip = FlightShipCtrlWnd ( GetScript("FlightShipCtrlWnd") );
	scriptTrans = FlightTransformCtrlWnd ( GetScript("FlightTransformCtrlWnd") ); 
	//scriptMain = MainMenu ( GetScript("MainMenu") );
	
	if( state == "GAMINGSTATE" )
	{		
		if( GetChatFilterBool ( "Global", "EnterChatting") ) // GetOptionBool( "Game", "EnterChatting" ));
		{					
			class'ShortcutAPI'.static.ActivateGroup("TempStateShortcut");
		}
		
		// 향상된 셰이더 로딩때문에 추가
		if(scriptShip.isNowActiveFlightShipShortcut) 	// 비행정 조종 모드라면		
		{
			if(  GetChatFilterBool ( "Global", "EnterChatting") )	{class'ShortcutAPI'.static.DeactivateGroup("TempStateShortcut");}
			class'ShortcutAPI'.static.ActivateGroup("FlightStateShortcut");
			//scriptMain.changeEnterChat( "FlightStateShortcut" );
		}
		else if (scriptTrans.isNowActiveFlightTransShortcut ) // 비행 변신체 모드라면
		{
			
			if(  GetChatFilterBool ( "Global", "EnterChatting") )	{class'ShortcutAPI'.static.DeactivateGroup("TempStateShortcut");}
			class'ShortcutAPI'.static.ActivateGroup("FlightTransformShortcut");
			//scriptMain.changeEnterChat( "FlightTransformShortcut" );
		}		
	}
}
defaultproperties
{
}
