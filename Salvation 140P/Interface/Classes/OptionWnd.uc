class OptionWnd extends L2UIGFxScript;
// 뉴 옵션 


//option
const PARTY_MODIFY_REQUEST = 9;
//const OPTION_CHANGE = 1 ;

//key Dialog
const DIALOGID_proc1= 10;
const DIALOGID_proc2= 11;
const DIALOGID_proc3= 12;
const DIALOGID_proc4= 13;

const ID_CALL_DIALOG = 10 ;
const ID_EXEC_FUNCTION = 11 ;
const ID_OPENWINDOW = 12;

//shaderBuild에서 쓸 변수 들
var bool m_bL2Shader ;
var bool m_bDOF ;
var bool m_bShaderWater ;
//var bool m_bDepthBufferShadow ;
var int m_AntiAliasing;
var int m_PostProc;

var bool m_bAutoPartyMatching;//오토파티매칭 관련 변수 

var int g_CurrentMaxWidth;
var int g_CurrentMaxHeight;
var int nPixelShaderVersion;
var int nVertexShaderVersion;

var bool    isGAMINGSTATE;

var DialogBox	dScript;

var bool bPartyMember;
var bool bPartyMaster;

var	FlightShipCtrlWnd			scriptShip;
var	FlightTransformCtrlWnd		scriptTrans;

var array<string> m_datasheetKeyReplace;
var array<string> m_datasheetKeyReplaced;

var bool isOpenShortCut;

var WindowHandle	m_hPartyMatchWnd;
var WindowHandle	m_hUnionMatchWnd;

// 아레나에서 강제로 enterchatting 모드로 전환한다. 그 때 임시로 이전 모드를 저장 함.
var bool preEnterChattingOption ;

function OnRegisterEvent()
{
	
	// 파티를 찾고 있다라는 상태를 보여줌
	RegisterEvent( EV_WaitWaitingSubstitute );
	// 파티를 찾고 있다라는 상태를 해제함
	RegisterEvent( EV_CancelWaitingSubstitute );
	
	RegisterEvent( EV_DialogOK );
	RegisterEvent( EV_DialogCancel );

	//RegisterGFxEvent( EV_ResolutionChanged );//콤보박스 닫기위해 추가

	RegisterEvent( EV_StateChanged );
	//RegisterGFxEvent( EV_StateChanged );
	RegisterEvent( EV_AskPartyLootingModify );
	RegisterEvent( EV_PartyLootingHasModified );
	
	RegisterGFxEvent( EV_OptionWndShow );
	RegisterGFxEvent( EV_AirStateOn );
	RegisterGFxEvent( EV_AirStateOff );

	RegisterGFxEvent( EV_MinFrameRateChanged );

	RegisterEvent( EV_PartyMemberChanged );

	RegisterEvent( EV_PartyHasDismissed );//파티가 해체되었음
	RegisterEvent( EV_OustPartyMember ); //파티에서 추방당했음
	RegisterEvent( EV_BecamePartyMember ); //파티의 멤버가 됨
	RegisterEvent( EV_BecamePartyMaster ); //파티장이됨
	RegisterEvent( EV_HandOverPartyMaster ); //파티장을 양도함
	RegisterEvent( EV_RecvPartyMaster ); //파티장을 양도받음
// 	RegisterEvent( EV_PartyMatchRoomStart ); //파티방장이됨

 	RegisterEvent( EV_PartyMatchRoomClose ); //파티방닫음
	RegisterEvent( EV_Restart );

	RegisterEvent( EV_WithdrawParty ); //파티에서 탈퇴함

	//RegisterGFxEvent( EV_ShowAllStateInfoChanged ); //액셔에서 상태 정보 보기 끄기를 껐다 킬 경우 > 역사 속으로 사라짐 
	RegisterGFxEvent( EV_SetShowAllStateInfo ); //액셔에서 상태 정보 보기 끄기를 껐다 킬 경우
	
	RegisterGFxEvent(EV_SetFullScreenCheck);

	//////////// 숏컷 관련 이벤트 들
	RegisterGFxEvent(EV_ShortcutInit);
	RegisterGFxEvent(EV_ShortcutDataReceived);

	//RegisterGFxEvent(EV_ReceiveWindowsInfo);

	RegisterGFxEvent(EV_ReceiveChatFilter);

	RegisterGFxEvent( EV_CuriousHouseEnter ); //9320
	RegisterGFxEvent( EV_CuriousHouseLeave ); //9330

	RegisterEvent ( EV_ShortcutDataReceived );

	//SetAnchor( "", EAnchorPointType.ANCHORPOINT_BottomRight, EAnchorPointType.ANCHORPOINT_TopLeft, FLASH_XPOS, FLASH_YPOS );
	

}
//=================================================================================
// Function : LoadAudioOption()
//
// Description :
//	* Reads option.ini file, and apply audio options.
//	* There is no need to apply options here for the options that share key between
//	  script and native code. (e.g. Video.Gamma)
//	* On the other hand, options that do not share key between script and native code
//	  MUST be applied here. (e.g. Video.L2Shader)
//	* This function MUST be called when loading the game. Otherwise, some of the
//	  options in option.ini will not be applied to the game.
//
// Revision History
//	* 2007/11/16 NeverDie: Created
//---------------------------------------------------------------------------------
function LoadAudioOption()
{
	local bool bMute;		// Audio mute

	// If device does not support audio, it's ok to simply ignore audio options
	if( CanUseAudio() )
	{
		// We only need to apply "Mute" option, because keys for volumes are shared between script and native code.
		bMute = GetOptionBool( "Audio", "AudioMuteOn" );

		SetOptionBool( "Audio", "AudioMuteOn", bMute );
	}
}

//=================================================================================
// Function : LoadVideoOption()
//
// Description :
//	* Reads option.ini file, and apply video options.
//	* There is no need to apply options here for the options that share key between
//	  script and native code. (e.g. Video.Gamma)
//	* On the other hand, options that do not share key between script and native code
//	  MUST be applied here. (e.g. Video.L2Shader)
//	* This function MUST be called when loading the game. Otherwise, some of the
//	  options in option.ini will not be applied to the game.
//
// Revision History
//	* 2007/11/16 NeverDie: Created
//---------------------------------------------------------------------------------
function LoadVideoOption()
{
	local bool bKeepMinFrameRate;		// Min frame rate
//	local bool bL2Shader;				// Shader 3.0
//	local bool bShaderDOF;				// Shader 3.0 Depth of field
//	local bool bShaderWater;			// Shader 3.0 Water
//	local bool bShaderShadow;			// Shader 3.0 Self shadow
	
	// Shader option should be set only when "KeepMinFrameRate" option is off
	m_AntiAliasing          = GetOptionInt("Video", "AntiAliasing" );
    m_PostProc              = GetOptionInt("Video", "PostProc" );
	
	m_bL2Shader             = GetOptionBool( "Video", "L2Shader" );
	m_bDOF                  = GetOptionBool( "Video", "S30DOFBOX" );
	m_bShaderWater          = GetOptionBool( "Video", "S30WaterEffectBox" );
//	m_bDepthBufferShadow    = GetOptionBool( "Video", "S30ShadowBox" );

	bKeepMinFrameRate = GetOptionBool( "Video", "IsKeepMinFrameRate" );
	if( !bKeepMinFrameRate )
	{
		// If current driver doesn't support Shader 3.0, there is no need to set Shader 3.0 options
		if( nPixelShaderVersion >= 30 && nVertexShaderVersion >= 30 )
		{
			// Apply Shader 3.0 config			
			SetL2Shader(m_bL2Shader);

			// DOF, WaterEffect, Shadow depend on L2Shader option. Set them only when bL2Shader is on.
			if( m_bL2Shader )
			{
				// Apply Shader 3.0 Depth of Field				
				SetDOF(m_bDOF);
					
				// Apply Shader 3.0 Water				
				SetShaderWaterEffect(m_bShaderWater);
				
				// Apply Shader 3.0 Self shadow				
				// SetDepthBufferShadow(m_bDepthBufferShadow);
			}
		}
	}
}

//=================================================================================
// Function : LoadGameOption()
//
// Description :
//	* Reads option.ini file, and apply game options.
//	* There is no need to apply options here for the options that share key between
//	  script and native code. (e.g. Video.Gamma)
//	* On the other hand, options that do not share key between script and native code
//	  MUST be applied here. (e.g. Video.L2Shader)
//	* This function MUST be called when loading the game. Otherwise, some of the
//	  options in option.ini will not be applied to the game.
//
// Revision History
//	* 2007/11/16 NeverDie: Created
//---------------------------------------------------------------------------------
function LoadGameOption()
{
	// Currently there is no options to load for the game tab.

	local bool bChecked;
	local int iChecked;
	bChecked=false;
	bChecked = GetOptionBool( "Control", "RightClickBox");
	SetFixedDefaultCamera(bChecked);

	/*
	 * 첫 설치시 default 값 처리 
	 */
	// 존 타이틀,
	if ( !GetINIBool ( "ScreenInfo", "ShowZoneTitle", iChecked, "Option.ini") )  
		SetOptionBool ( "ScreenInfo", "ShowZoneTitle", true ) ;
	// 로딩 중 유용한 정보 보기
	if ( !GetINIBool ( "ScreenInfo", "ShowGameTipMsg", iChecked, "Option.ini") )  
		SetOptionBool ( "ScreenInfo", "ShowGameTipMsg", true ) ;
}

function OnLoad()
{
	//SetClosingOnESC();
	SetContainerWindow( WINDOWTYPE_DECO_NORMAL, 205);
	AddState( "GAMINGSTATE" );
	AddState( "LOGINSTATE" );

	AddState( "PAWNVIEWERSTATE" );

	AddState( "ARENAGAMINGSTATE" );
	AddState( "ARENABATTLESTATE" );

	SetOptionBool( "ScreenInfo", "HideDropItem", false );

	GetShaderVersion( nPixelShaderVersion, nVertexShaderVersion );


	LoadVideoOption();
	LoadAudioOption();
	LoadGameOption();

	DataSheetAssignKeyReplacement();

	scriptShip = FlightShipCtrlWnd ( GetScript("FlightShipCtrlWnd") );
	scriptTrans = FlightTransformCtrlWnd ( GetScript("FlightTransformCtrlWnd") ); 	

	m_hPartyMatchWnd = GetWindowHandle("PartyMatchWnd");
	m_hUnionMatchWnd = GetWindowHandle("UnionMatchWnd");
//	Debug("** option onLoad");
}




/* Referenced by: OnLoad()
 * Description: 
 * 	Datasheet contains key name data to replace system key name to user readable names.
 */
function DataSheetAssignKeyReplacement()
{
	m_datasheetKeyReplace[1]="LEFTMOUSE";
	m_datasheetKeyReplace[2]="RIGHTMOUSE";
	m_datasheetKeyReplace[3]="BACKSPACE";
	m_datasheetKeyReplace[4]="ENTER";
	m_datasheetKeyReplace[5]="SHIFT";
	m_datasheetKeyReplace[6]="CTRL";
	m_datasheetKeyReplace[7]="ALT";
	m_datasheetKeyReplace[8]="PAUSE";
	m_datasheetKeyReplace[9]="CAPSLOCK";
	m_datasheetKeyReplace[10]="ESCAPE";
	m_datasheetKeyReplace[11]="SPACE";
	m_datasheetKeyReplace[12]="PAGEUP";
	m_datasheetKeyReplace[13]="PAGEDOWN";
	m_datasheetKeyReplace[14]="END";
	m_datasheetKeyReplace[15]="HOME";
	m_datasheetKeyReplace[16]="LEFT";
	m_datasheetKeyReplace[17]="UP";
	m_datasheetKeyReplace[18]="RIGHT";
	m_datasheetKeyReplace[19]="DOWN";
	m_datasheetKeyReplace[20]="SELECT";
	m_datasheetKeyReplace[21]="PRINT";
	m_datasheetKeyReplace[22]="PRINTSCRN";
	m_datasheetKeyReplace[23]="INSERT";
	m_datasheetKeyReplace[24]="DELETE";
	m_datasheetKeyReplace[25]="HELP";
	m_datasheetKeyReplace[26]="NUMPAD0";
	m_datasheetKeyReplace[27]="NUMPAD1";
	m_datasheetKeyReplace[28]="NUMPAD2";
	m_datasheetKeyReplace[29]="NUMPAD3";
	m_datasheetKeyReplace[30]="NUMPAD4";
	m_datasheetKeyReplace[31]="NUMPAD5";
	m_datasheetKeyReplace[32]="NUMPAD6";
	m_datasheetKeyReplace[33]="NUMPAD7";
	m_datasheetKeyReplace[34]="NUMPAD8";
	m_datasheetKeyReplace[35]="NUMPAD9";
	m_datasheetKeyReplace[36]="GREYSTAR";
	m_datasheetKeyReplace[37]="GREYPLUS";
	m_datasheetKeyReplace[38]="SEPARATOR";
	m_datasheetKeyReplace[39]="GREYMINUS";
	m_datasheetKeyReplace[40]="NUMPADPERIOD";
	m_datasheetKeyReplace[41]="GREYSLASH";
	m_datasheetKeyReplace[42]="NUMLOCK";
	m_datasheetKeyReplace[43]="SCROLLLOCK";
	m_datasheetKeyReplace[44]="UNICODE";
	m_datasheetKeyReplace[45]="SEMICOLON";
	m_datasheetKeyReplace[46]="EQUALS";
	m_datasheetKeyReplace[47]="COMMA";
	m_datasheetKeyReplace[48]="MINUS";
	m_datasheetKeyReplace[49]="SLASH";
	m_datasheetKeyReplace[50]="TILDE";
	m_datasheetKeyReplace[51]="LEFTBRACKET";
	m_datasheetKeyReplace[52]="BACKSLASH";
	m_datasheetKeyReplace[53]="RIGHTBRACKET";
	m_datasheetKeyReplace[54]="SINGLEQUOTE";
	m_datasheetKeyReplace[55]="PERIOD";
	m_datasheetKeyReplace[56]="MIDDLEMOUSE";
	m_datasheetKeyReplace[57]="MOUSEWHEELDOWN";
	m_datasheetKeyReplace[58]="MOUSEWHEELUP";
	m_datasheetKeyReplace[59]="UNKNOWN16";
	m_datasheetKeyReplace[60]="UNKNOWN17";
	m_datasheetKeyReplace[61]="BACKSLASH";
	m_datasheetKeyReplace[62]="UNKNOWN19";
	m_datasheetKeyReplace[63]="UNKNOWN5C";
	m_datasheetKeyReplace[64]="UNKNOWN5D";
	m_datasheetKeyReplace[65]="UNKNOWN0C";
	m_datasheetKeyReplaced[1]=GetSystemString(1670);
	m_datasheetKeyReplaced[2]=GetSystemString(1671);
	m_datasheetKeyReplaced[3]=GetSystemString(1517);
	m_datasheetKeyReplaced[4]="Enter";
	m_datasheetKeyReplaced[5]="Shift";
	m_datasheetKeyReplaced[6]="Ctrl";
	m_datasheetKeyReplaced[7]="Alt";
	m_datasheetKeyReplaced[8]="Pause";
	m_datasheetKeyReplaced[9]="CapsLock";
	m_datasheetKeyReplaced[10]="ESC";
	m_datasheetKeyReplaced[11]=GetSystemString(1672);
	m_datasheetKeyReplaced[12]="PageUp";
	m_datasheetKeyReplaced[13]="PageDown";
	m_datasheetKeyReplaced[14]="End";
	m_datasheetKeyReplaced[15]="Home";
	m_datasheetKeyReplaced[16]="Left";
	m_datasheetKeyReplaced[17]="Up";
	m_datasheetKeyReplaced[18]="Right";
	m_datasheetKeyReplaced[19]="Down";
	m_datasheetKeyReplaced[20]="Select";
	m_datasheetKeyReplaced[21]="Print";
	m_datasheetKeyReplaced[22]="PrintScrn";
	m_datasheetKeyReplaced[23]="Insert";
	m_datasheetKeyReplaced[24]="Delete";
	m_datasheetKeyReplaced[25]="Help";
	m_datasheetKeyReplaced[26]=GetSystemString(1657);
	m_datasheetKeyReplaced[27]=GetSystemString(1658);
	m_datasheetKeyReplaced[28]=GetSystemString(1659);
	m_datasheetKeyReplaced[29]=GetSystemString(1660);
	m_datasheetKeyReplaced[30]=GetSystemString(1661);
	m_datasheetKeyReplaced[31]=GetSystemString(1662);
	m_datasheetKeyReplaced[32]=GetSystemString(1663);
	m_datasheetKeyReplaced[33]=GetSystemString(1664);
	m_datasheetKeyReplaced[34]=GetSystemString(1665);
	m_datasheetKeyReplaced[35]=GetSystemString(1666);
	m_datasheetKeyReplaced[36]="*";
	m_datasheetKeyReplaced[37]="+";
	m_datasheetKeyReplaced[38]="Separator";
	m_datasheetKeyReplaced[39]="-";
	m_datasheetKeyReplaced[40]=".";
	m_datasheetKeyReplaced[41]="/";
	m_datasheetKeyReplaced[42]="NumLock";
	m_datasheetKeyReplaced[43]="ScrollLock";
	m_datasheetKeyReplaced[44]="Unicode";
	m_datasheetKeyReplaced[45]=";";
	m_datasheetKeyReplaced[46]="=";
	m_datasheetKeyReplaced[47]=",";
	m_datasheetKeyReplaced[48]="-";
	m_datasheetKeyReplaced[49]="/";
	m_datasheetKeyReplaced[50]="`";
	m_datasheetKeyReplaced[51]="[";
	m_datasheetKeyReplaced[52]="";
	m_datasheetKeyReplaced[53]="]";
	m_datasheetKeyReplaced[54]="'";
	m_datasheetKeyReplaced[55]=".";
	m_datasheetKeyReplaced[56]=GetSystemString(1669);
	m_datasheetKeyReplaced[57]=GetSystemString(1667);
	m_datasheetKeyReplaced[58]=GetSystemString(1668);
	m_datasheetKeyReplaced[59]="-";
	m_datasheetKeyReplaced[60]="=";
	m_datasheetKeyReplaced[61]=GetSystemString(1676);
	m_datasheetKeyReplaced[62]=GetSystemString(1673);
	m_datasheetKeyReplaced[63]=GetSystemString(1674);
	m_datasheetKeyReplaced[64]=GetSystemString(1675);
	m_datasheetKeyReplaced[65]=GetSystemString(1677);

}

/* Referenced by: HandleUpdateGeneralKeyListControl()
 * Description: Returns user readable key name with system key names.
 */
function String GetUserReadableKeyName(String input)
{
	local int i;
	local String output;
	for (i= 0 ; i < m_datasheetKeyReplace.Length ; ++i)
	{
		if (m_datasheetKeyReplace[i] == input)
			output = m_datasheetKeyReplaced[i];
	}
	if (output == "")
		output = input;
	return output;
}


function PartyLootingChanged(int selectedNum )
{		
	if(bPartyMaster || (IsRoomMaster() && !bPartyMember)) //파티방장인데 파티장을 양도하는 경우가 있어서
	{

		//현재 루팅과 같은걸 또선택하면 무시.
		//저장된 설정이 현재 설정이랑 일치하는 이유는 파티를 초대할때 저장된 설정을 사용하고, 
		//루팅이 변경되도 설정을 저장하기 때문이다.
		if(GetOptionInt( "Communication", "PartyLooting") == selectedNum) return ;
		setEnableLootingBox( false );
		RequestPartyLootingModify( selectedNum ); // 루팅변경을 신청한다.
	}
}

function chkRequestRegistWaitingSubstitute(bool checked) 
{	
	if ( checked == GetOptionBool( "Communication", "StartupAutoPartyMatching" ))
		return;

	if (m_bAutoPartyMatching) 
		return;//켜져 있으면 또 켜지 말것 

	if (checked ) 
	{
		RequestRegistWaitingSubstitute(1); //커긴 하지만 
	}
	//else 
	//	RequestRegistWaitingSubstitute(0); 끄지는 않는다.

}

// 엔터채팅으로 변경해준다. 
/* Referenced by: OnClickCheckBox()
 * Description:
 * 	* Reads OptionBool "EnterChatting" and gets the chatting mode setting data.
 * 	* Clear current state key settings first.
 *	* Activate apparant key setting groups.
 *	* Check or CheckBox "Chk_EnterChatting".
 */
Function HandleSwitchEnterchatting()
{
	
	//local	MainMenu	scriptMain;
	local   bool         enableEnterChatting ;
	local   FlightTransformCtrlWnd  scriptFlgithForm;
	local   FlightShipCtrlWnd       scriptFlightShip;

	//현재 비행 변신 상태라면 리턴 한다.
	scriptFlgithForm = FlightTransformCtrlWnd( GetScript ( "FlightTransformCtrlWnd" ));
	if ( scriptFlgithForm.isNowActiveFlightTransShortcut ) return;

	//현재 비행 탑승 상태라면 리턴한다.
	scriptFlightShip = FlightShipCtrlWnd( GetScript ( "FlightShipCtrlWnd" ));
	if ( scriptFlightShip.isNowActiveFlightShipShortcut ) return;
	
	//scriptMain = MainMenu ( GetScript("MainMenu") );	
	//bEnterChat = GetOptionBool("CommunIcation", "EnterChatting");
	//~ ResetActivateKeyGroup();

	// defaultstate로 자동 로딩 됐었으나, 아레나에 의해 수종으로 로딩 함.
	//class'ShortcutAPI'.static.ActivateGroup("GamingStateShortcut");	
	class'ShortcutAPI'.static.ActivateGroup("GamingStateDefaultShortcut");	
	class'ShortcutAPI'.static.ActivateGroup("CameraControl");
	class'ShortcutAPI'.static.ActivateGroup("GamingStateGMShortcut");

	// 아레나 서버에서는 enterchatting로 동작 합니다. 
	if ( getInstanceUIData().getIsArenaServer()) 
	{
		class'ShortcutAPI'.static.ActivateGroup("TempStateShortcut");
		preEnterChattingOption = GetChatFilterBool ( "Global", "EnterChatting") ;
		SetChatFilterBool ( "Global", "EnterChatting", true) ;
		enableEnterChatting = true;
		CallGFxFunction( getCurrentWindowName(String(self)), "onSwitchDisableEnterChatting", String ( true ) );		
		// 옵션 창에서, disable, 및 체크 표시 필요
	}
	else if (GetChatFilterBool ( "Global", "EnterChatting"))
	{	
		class'ShortcutAPI'.static.ActivateGroup("TempStateShortcut");
		SetChatFilterBool ( "Global", "EnterChatting", true) ;
		enableEnterChatting = true;
	}
	else
	{		
		class'ShortcutAPI'.static.DeactivateGroup("TempStateShortcut");
		SetChatFilterBool ( "Global", "EnterChatting", false) ;
		enableEnterChatting = false;		
	}
	
	handleArenaShortCut();
	// 아래 의 경우 지금 해도 소용 없다, 서버에 저장 된 단축키 리스트를 요청 한 상태다.
	//if ( GetGameStateName() =="ARENAGAMINGSTATE" )//|| GetGameStateName() =="ARENABATTLESTATE" || GetGameStateName() =="ARENAPICKSTATE" ) 
	//{	
	//	//class'ShortcutAPI'.static.DeactivateGroup("ArenaPickEnterChattingShortcut");
	//	//class'ShortcutAPI'.static.ActivateGroup("ArenaGamingShortcut");
	//	class'ShortcutAPI'.static.ActivateGroup("ArenaGamingEnterChattingShortcut");
	//}	
	//else if (GetGameStateName() =="ARENAPICKSTATE") 
	//{		
	//	class'ShortcutAPI'.static.ActivateGroup("ArenaPickEnterChattingShortcut");
	//	class'ShortcutAPI'.static.DeactivateGroup("TempStateShortcut");
	//	class'ShortcutAPI'.static.DeactivateGroup("ArenaGamingShortcut");
	//	class'ShortcutAPI'.static.DeactivateGroup("ArenaGamingEnterChattingShortcut");
	//}
	
	CallGFxFunction( getCurrentWindowName(String(self)), "onSwitchEnterChatting", String ( enableEnterChatting ) );
	//dispatchEventToFlash_Int(200, enableNum);
}

function saveArenaShortcutList () 
{
	local   ShortcutCommandItem     shortcutItem;

	//	/************************************************************************* 
	//	 * 단축키 변경 
	//	 **************************************************************************/
		shortcutItem.sCommand = "getNextTarget";
		shortcutItem.key = "TAB";
		shortcutItem.subkey1 = "";
		shortcutItem.subkey2 =  "";
		shortcutItem.sState = "";
		shortcutItem.sAction =  "Press";
		//class'ShortcutAPI'.static.AssignCommand("ArenaGamingShortcut", shortcutItem);
		class'ShortcutAPI'.static.AssignCommand("ArenaGamingEnterChattingShortcut", shortcutItem);

		shortcutItem.sCommand = "getPrevTarget";
		shortcutItem.key = "TAB";
		shortcutItem.subkey1 = "Shift";
		shortcutItem.subkey2 =  "";
		shortcutItem.sState = "";
		shortcutItem.sAction =  "Press";
		//class'ShortcutAPI'.static.AssignCommand("ArenaGamingShortcut", shortcutItem);
		class'ShortcutAPI'.static.AssignCommand("ArenaGamingEnterChattingShortcut", shortcutItem);

		//shortcutItem.sCommand = "useRunSkill";
		//shortcutItem.key = "F";
		//shortcutItem.subkey1 = "Ctrl";
		//shortcutItem.subkey2 =  "";
		//shortcutItem.sState = "";
		//shortcutItem.sAction =  "Press";
		//class'ShortcutAPI'.static.AssignCommand("ArenaGamingShortcut", shortcutItem);

		shortcutItem.sCommand = "useRunSkill";
		shortcutItem.key = "F";
		shortcutItem.subkey1 = "";
		shortcutItem.subkey2 =  "";
		shortcutItem.sState = "";
		shortcutItem.sAction =  "Press";
		class'ShortcutAPI'.static.AssignCommand("ArenaGamingEnterChattingShortcut", shortcutItem);

		//shortcutItem.sCommand = "useBaseRecallSkill";
		//shortcutItem.key = "B";
		//shortcutItem.subkey1 = "Ctrl";qqqq
		//shortcutItem.subkey2 =  "";
		//shortcutItem.sState = "";
		//shortcutItem.sAction =  "Press";
		//class'ShortcutAPI'.static.AssignCommand("ArenaGamingShortcut", shortcutItem);

		shortcutItem.sCommand = "useBaseRecallSkill";
		shortcutItem.key = "B";
		shortcutItem.subkey1 = "";
		shortcutItem.subkey2 =  "";
		shortcutItem.sState = "";
		shortcutItem.sAction =  "Press";
		class'ShortcutAPI'.static.AssignCommand("ArenaGamingEnterChattingShortcut", shortcutItem);

		shortcutItem.sCommand = "ArenaSelectTarget";
		shortcutItem.key = "SPACE";
		shortcutItem.subkey1 = "";
		shortcutItem.subkey2 =  "";
		shortcutItem.sState = "";
		shortcutItem.sAction =  "Press";
		class'ShortcutAPI'.static.AssignCommand("ArenaGamingEnterChattingShortcut", shortcutItem);

		class'ShortcutAPI'.static.Save();
}

function ToggleOpenMeWnd( bool isShortCut)
{	
	isOpenShortCut = isShortCut;

	if( IsShowWindow() )
	{
		HideWindow();
	}
	else
	{		
		ShowWindow();
	}
	
}

/* 
 * 다이얼로그 켄슬 이후 
 */
function ShortCutReset ( ) 
{	
	//local MainMenu sc;

	//Debug ( " !~  ShortCutReset dialogCanceled");
	//class'ShortcutAPI'.static.RestoreDefault();
	//class'ShortcutAPI'.static.Save();

	//dispatchEventToFlash_Int(50, 0); //숏컷 초기화 
	
	ActiveFlightShort();	//비행상태의 숏컷그룹을 액티브해줌

	HandleSwitchEnterchatting();

	handleArenaShortCut();
	//메인메뉴 단축키 수정
	//sc = MainMenu( GetScript( "MainMenu" ) );
	//sc.updateTooltip();	
}

function onCallUCFunction (String funcName, String param ) 
{
	//Debug ( "onCallUCFunction" @ funcName @ param);
	switch (funcName) 
	{
		case "ShortCutReset" :
			ShortCutReset();
		break;
		case "HandleSwitchEnterchatting" :	//엔터 채팅 변경			
			HandleSwitchEnterchatting();
		break;
		case "PartyLootingChanged":
			PartyLootingChanged	( int (param) ) ;
		break;
			//추가 부분
		//다른 uc에서 참조 함.
		/*
		case "L2Shader" :				
			m_bL2Shader = GetOptionBool("Video",funcName);
			//Debug("uc L2Shader" @ m_bL2Shader);				
			break;
		//다른 uc에서 참조 함.
		case "S30DOFBOX": 				
			m_bDOF = GetOptionBool("Video",funcName) ; 
			//Debug("uc S30DOFBOX" @ m_bDOF);			
			break;
		//다른 uc에서 참조 함.
		case "S30WaterEffectBox": 				
			m_bShaderWater = GetOptionBool("Video",funcName) ;
			//Debug("uc S30WaterEffectBox" @ m_bShaderWater);			
			break;
		//case "S30ShadowBox":				
		//	m_bDepthBufferShadow = GetOptionBool("Video",funcName) ;
		//	//Debug("uc S30ShadowBox" @ m_bDepthBufferShadow);			
		//	break;
		*/
		//오토파티 열고 닫기
		case "RequestRegistWaitingSubstitute":
			chkRequestRegistWaitingSubstitute ( bool( param ) ) ;
			break;
		//피씨방 포인트 창 끄고 키기
		case "SetPcRoomBoxData" : 
			SetPcRoomBoxData ( bool (param ) );
			break;
		//상태 창 보여지기 
		case "StateBoxShow" : 
			StateBoxShow( bool (param ) );
			break;
		case "handleShaderOptionChange":
			handleShaderOptionChange();
			break;
		case "setChattingOption":
			setChattingOption();
			break;
	}
	
}

/*
 * 정확한 기능을 알 수 없지만 
 * shortcut 에서 사용 중이므로, 남겨 둠
 */
function SetDefaultPositionByClick()
{
	GetCurrentResolution(g_CurrentMaxWidth, g_CurrentMaxHeight);
	SetDefaultPosition();
}

function InitControlOption ()
{
	CallGFxFunction ( getCurrentWindowName( String ( self ) ), "InitControlOption", "");
//	dispatchEventToFlash_Int( 100 , 0 );
}

function InitScreenInfoOption()
{
	CallGFxFunction ( getCurrentWindowName( String ( self ) ), "InitScreenInfoOption", "");
	//dispatchEventToFlash_Int( 101 , 0 );
} 

function StateBoxShow( bool bChecked )
{
	local TargetStatusWnd util;
	util = TargetStatusWnd(GetScript("TargetStatusWnd"));
	util.StateBoxShow( bChecked );
}

Function SetPcRoomBoxData(bool bOption)
{
	//branch GD35_0828 2013-12-06 luciper3 - 해당 클래스에서 처리하도록한다.
	local InfoWnd script;
	//local bool bIsHide;
	script = InfoWnd( GetScript( "InfoWnd" ) );

	//log("===== Option Call ===== bOption : "$bOption);

	if( script != none && isGAMINGSTATE )
	{
		//bIsHide = bOption || !isGAMINGSTATE;
		script.HandleToggleShowPCCafeEventWnd(true, bOption);
	}
	//end of branch

// 	local windowhandle win;	
// 	
// 	win = GetWindowHandle ("InfoWnd" ) ;
// 	if ( bOption || !isGAMINGSTATE ) 
// 	{
// 		win.HideWindow();
// 	}
// 	else 
// 	{
// 		win.ShowWindow();
// 	}
}


// 비행 상태 활성화 
function ActiveFlightShort()
{
	//local	MainMenu	                scriptMain;	
	
	//scriptMain = MainMenu ( GetScript("MainMenu") );

	if( scriptShip.Me.IsShowWindow())	// 비행정 조종 상태일때	// 비행정 숏컷 그룹을 액티브 해준다. 
	{
		//scriptShip.preEnterChattingOption = GetOptionBool("Game", "EnterChatting");		//기존 엔터채팅 옵션을 저장해둔다. 				
		SetChatFilterBool ( "Global", "EnterChatting", true);
		//SetOptionBool( "CommunIcation", "EnterChatting", true );	//강제 엔터 채팅
		//dispatchEventToFlash_Int(200, 1); //엔터 채팅 체크 		
		CallGFxFunction( getCurrentWindowName(String(self)), "onSwitchEnterChatting", String ( true ) );
		//dispatchEventToFlash_Int(200, 2); //디스에이블 
		CallGFxFunction( getCurrentWindowName(String(self)), "onSwitchDisableEnterChatting", String ( true ) );			
		class'ShortcutAPI'.static.ActivateGroup("FlightStateShortcut");		//숏컷 그룹 지정	
		//scriptMain.changeEnterChat( "FlightStateShortcut" );
		scriptShip.updateLockButton();	// 잠금 상태를 업데이트 한다. 			
			
		//scriptShip.ChatEditBox.ReleaseFocus();
	}
	else if( scriptTrans.Me.IsShowWindow())
	{
		//scriptTrans.preEnterChattingOption = GetOptionBool("Game", "EnterChatting");		//기존 엔터채팅 옵션을 저장해둔다. 		
		SetChatFilterBool ( "Global", "EnterChatting", true);		
		//SetOptionBool( "CommunIcation", "EnterChatting", true );	//강제 엔터 채팅
		//dispatchEventToFlash_Int(200, 1); //엔터 채팅 체크 
		CallGFxFunction( getCurrentWindowName(String(self)), "onSwitchEnterChatting", String ( true ) );
		//dispatchEventToFlash_Int(200, 2); //엔터 채팅 디스에이블
		CallGFxFunction( getCurrentWindowName(String(self)), "onSwitchDisableEnterChatting", String ( true ) );
		
		
		scriptTrans.updateLockButton();	// 잠금 상태를 업데이트 한다. 
		class'ShortcutAPI'.static.ActivateGroup("FlightTransformShortcut");	//숏컷 그룹 지정
//		scriptMain.changeEnterChat( "FlightTransformShortcut" );
	}
}

/*
 * 기존 쉐이더 빌드 스테이트를 두고
 * 그 스트이트 때 옵션 값을 일괄 변경 했었음
 * 그렇게 하기 위해 shader 등과 관련 된 옵션 들은 한 곳에 모아서 처리 함.
 */
function handleShaderOptionChange()
{		
	//local RadarMapWnd sc;
	//sc = RadarMapWnd( GetScript( "RadarMapWnd" ) );
	
	//sc.setButtonInfo();

	//추가 부분
	m_AntiAliasing          = GetOptionInt("Video", "AntiAliasing" );
    m_PostProc              = GetOptionInt("Video", "PostProc" );

	m_bL2Shader             = GetOptionBool ("Video", "L2Shader" );
	m_bDOF                  = GetOptionBool ("Video", "S30DOFBOX" );
	m_bShaderWater          = GetOptionBool ("Video", "S30WaterEffectBox" );
	//m_bDepthBufferShadow    = GetOptionBool ("Video", "S30ShadowBox" );

//	Debug("-handleOPTION_CHANGE" @m_bL2Shader@ m_bDOF @ m_bShaderWater @ m_bDepthBufferShadow);

	//쉐이더 빌더 스테이트 없이 옵션 적용
	SetHDR (m_PostProc );		
	SetAntialiasing( m_AntiAliasing );
	SetShaderWaterEffect( m_bShaderWater );		
	SetDOF( m_bDOF );
	SetL2Shader( m_bL2Shader );
	//SetUIState( "ShaderBuildState" );
}

function OnEvent(int a_EventID, string a_Param)
{
	switch( a_EventID )
	{
		case EV_DialogOK:
		HandleDialogResult(true);
		break;
		case EV_DialogCancel:
		HandleDialogResult(false);
		break;
		case EV_StateChanged :
			UIActivationUponStateChanges( a_Param );// 로그인시 숏컷 할당이 가능하도록 활성화해준다. 		
			
		break;
		/////파티루팅관련 이벤트//////////////////jdh84
		case EV_AskPartyLootingModify: //파티루팅변경 신청 들어옴
			OnAskPartyLootingModify(a_Param);
			break;
		
		case EV_PartyLootingHasModified: //파티루팅변경 결과 알려옴
			OnPartyLootingHasModified(a_Param);
			break;

		case EV_WithdrawParty: //탈퇴하거나
		case EV_OustPartyMember: //추방당하거나
		case EV_PartyHasDismissed: //파티가 해산될때
			bPartyMember = false;
			bPartyMaster = false;
			OnPartyHasDismissed();
//			Debug( "파티가 탈퇴, 추방, 해산 등으로 사라짐 " );
			break;
		case EV_BecamePartyMember://파티의 멤버가됨
			bPartyMember = true;
			bPartyMaster = false;
			OnBecamePartyMember(a_Param);
//			Debug ( "파티 멤버가 됐음");
			break;
		case EV_BecamePartymaster://파티장이됨		
			bPartyMember = false;
			bPartyMaster = true;
			OnBecamePartyMaster(a_Param);
//			Debug ( "파티 장!이 됐음");
			break;
		case EV_HandOverPartyMaster: //파티장을 양도함
			bPartyMember = true;
			bPartyMaster = false;
			OnHandOverPartyMaster();
			
			//정우균 추가 - 2013-03-29 < 연합매칭, 파티매칭이벤트가 해당 창으로 가지 않아서 이곳에서 닫음 >
			//파티매칭윈도우, 연합매칭윈도우 창 닫음			
			if(m_hPartyMatchWnd.IsShowWindow()==true)
			{
				m_hPartyMatchWnd.HideWindow();
			}
			if(m_hUnionMatchWnd.IsShowWindow()==true)
			{
				m_hUnionMatchWnd.HideWindow();
			}
			//Debug ( "파티장을 양도! 함");
			break;;
		case EV_RecvPartyMaster: //파티장을 양도받음
			bPartyMember = false;
			bPartyMaster = true;
			OnRecvPartyMaster();
			//Debug ( "파티장을 양도! 받음!");
			break;;
		case EV_Restart: //리스타트
			bPartyMember = false;
			bPartyMaster = false;
			OnRestart();
			break;
	// 	case EV_PartyMatchRoomStart:
	// 		bPartyRoomMaster = true;
	// 		break;
 		case EV_PartyMatchRoomClose:
			OnPartyMatchRoomClose();	 		
 			break;

 		case EV_WaitWaitingSubstitute :
			m_bAutoPartyMatching = true;
			break;
 		case EV_CancelWaitingSubstitute : 
			m_bAutoPartyMatching = false;
			break;
		case EV_ShortcutDataReceived :			
			handleArenaShortCut();
			break;
	}
}

/*
 * 1. stateChange 시 
 * 2. HandleSwitchEnterchatting 에서 단측키 Active 하고
 * 3. requestList 서버에 단축키 리스트를 요청
 * 4. 단축키 리스트가 들어오면 아레나용 인 경우 saveArenaShortcutList 로 단축키 저장
 * 5. active 해준다.
 * 
 * 6. 서버에 저장을 한번도 안한 경우 EV_ShortcutDataReceived 가 들어오지 않는다. 그 전에 무조건 해 줘야 함.
 * 7. ShortCutReset 시에도 .진행 한다.
 */
function handleArenaShortCut () 
{
	local string stateName;
	stateName = GetGameStateName() ;
	
	if ( stateName =="ARENAGAMINGSTATE" || stateName =="ARENABATTLESTATE" || stateName =="ARENAPICKSTATE" || stateName == "ARENAOBSERVERSTATE" ) 
	{
		saveArenaShortcutList () ;
		class'ShortcutAPI'.static.ActivateGroup("ArenaGamingShortcut");
		class'ShortcutAPI'.static.ActivateGroup("ArenaGamingEnterChattingShortcut");		
	}
}


///////////////지금부터 파티루팅변경 관련 코드가 들어갑니다//////////////////////////////////////////////////////////////////////////////////////////
//
//		파티루팅을 옵션창에서 변경하는 관계로 여기에다 넣었음
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// 다이얼로그 결과
function HandleDialogResult(bool bOk)
{	
	//local MainMenu sc;	
	local DialogBox dialogBoxScript;

	dialogBoxScript = DialogBox( GetScript( "DialogBox" ) );

	// Debug("HandleDialogResult-" @ string(Self));

//	if(class'UICommonAPI'.static.DialogIsOwnedBy( string(Self) ) || class'UICommonAPI'.static.DialogIsBeforeOwnedBy( string(Self) ))
	if(class'UICommonAPI'.static.DialogIsOwnedBy( string(Self) ))
	{
		//Debug("dialogBoxScript.isProgressBarWorking()" @ dialogBoxScript.isProgressBarWorking());
		//Debug("dialogBoxScript.getTryCancelDialogID()" @ dialogBoxScript.getTryCancelDialogID());
		//Debug("dialogBoxScript.DialogGetID()" @ dialogBoxScript.DialogGetID());
		
		//Debug (  "HandleDialogResult" @ dialogBoxScript.checkCancelDialogID(PARTY_MODIFY_REQUEST)  @ dialogBoxScript.DialogGetID() );

		if(dialogBoxScript.DialogGetID() == PARTY_MODIFY_REQUEST) SetRequestPartyLootingModifyAgreement(bOk);
		
		//// 캔슬일때 
		//if (bOk == false)
		//{
		//	if(dialogBoxScript.checkCancelDialogID(PARTY_MODIFY_REQUEST))
		//	{
				
		//		SetRequestPartyLootingModifyAgreement(bOk);
		//	}
		//}
		//else
		//{
		//	// ok일떄
		//	if(dialogBoxScript.DialogGetID() == PARTY_MODIFY_REQUEST)
		//	{
		//		SetRequestPartyLootingModifyAgreement(bOk);
		//	}	
		//}
	}
}

function setEnableLootingBox( bool bEnable) 
{
	/*
	local int enableNum;
	if ( bEnable ) enableNum = 1 ;
	else enableNum = 0;
*/

	CallGFxFunction ( getCurrentWindowName( String ( self ) ), "setEnableLootingBox", String ( bEnable) );
	//dispatchEventToFlash_Int(80, enableNum);
}

function setLootingBoxSelection ( int SelectNum) 
{
	CallGFxFunction ( getCurrentWindowName( String ( self ) ), "setLootingBoxSelection", string ( SelectNum ));
	//dispatchEventToFlash_Int(81, SelectNum);
}

function saveLootingBoxSelection () 
{
	CallGFxFunction ( getCurrentWindowName( String ( self ) ), "saveLootingBoxSelection", "");
	//dispatchEventToFlash_Int(82, 0);
}

function SetRequestPartyLootingModifyAgreement(bool bOK) //파티루팅변경 동의창 
{
	if ( bOK ) RequestPartyLootingModifyAgreement(1); // 수락 
	else 
	{
		//버튼 네임을 확인, 취소 로 복구 왜 취소에만 들어가 있는 지 모르겠음.
		dScript.SetButtonName( 1337, 1342 );		
		RequestPartyLootingModifyAgreement(0); //거절함 혹은 타임아웃
	}
}

function OnPartyMatchRoomClose()
{	
	if (!bPartyMember && !bPartyMaster)
		setLootingBoxSelection( GetOptionInt( "Communication", "PartyLooting") );
}

function OnPartyHasDismissed()
{
	setLootingBoxSelection( GetOptionInt( "Communication", "PartyLooting") );
	setEnableLootingBox(true);
	
	//파티가 해제,탈퇴,추방되면 자신이 설정한 루팅방식으로 돌아간다. 
	//파티장도 마찬가지(루팅변경시 파티장은 저장된다)
}


function OnBecamePartyMember(string a_Param) //파티원이 됨
{
	local int Lootingtype;
	ParseInt(a_Param, "Lootingtype", Lootingtype);
	setLootingBoxSelection(Lootingtype); //루팅타입을 파티장따라간다. 저장은 하지 않는다
	setEnableLootingBox(false);
}

function OnBecamePartyMaster(string a_Param) //파티장이됨
{
	local int Lootingtype;
	ParseInt(a_Param, "Lootingtype", Lootingtype);
	setLootingBoxSelection(Lootingtype);
	setEnableLootingBox(true);
}

function OnHandOverPartyMaster() //파티장을 양도함
{
	setEnableLootingBox(false);
}

function OnRecvPartyMaster()  //파티장을 양도받음
{

	saveLootingBoxSelection();//방장이 되면 현재방식을 저장한다. 운명적으로
	setEnableLootingBox(true);
}

function OnRestart()
{
	//dispatchEventToFlash_Int(1 );
	//루팅을 초기화 함.
	setLootingBoxSelection(GetOptionInt( "Communication", "PartyLooting"));
	setEnableLootingBox(true);
	// 특정 조건에서 preEnterChattingOption 를 setChattingBool 처리 해야 함.
//	Debug ( "OnRestart" @  String ( preEnterChattingOption) );
	if ( getInstanceUIData().getIsArenaServer() ) 
	{
//		Debug ( "아레나 서버인가??" @ getInstanceUIData().getIsArenaServer() );
		 SetChatFilterBool ( "Global", "EnterChatting" , preEnterChattingOption) ;		
	}
	
}

function bool IsRoomMaster()
{
	local PartyWnd Script;
	Script = PartyWnd(GetScript("PartyWnd"));
	return Script.m_AmIRoomMaster;
}
function OnPartyLootingHasModified(String a_Param) //파티루팅이 변경되었을때
{
	local int IsSuccess;
	local int LootingScheme;
	local string Schemestr;
	local string	strParam;
	local PartyWnd script;
	//////////for ScreenMsg///////////
	local SystemMsgData SystemMsgCurrent;
	///////////////////////////////////////

	//루팅 콤보박스 변경을 위해
	/////////////////////////

	local TextBoxHandle t_handle;


	local L2Util util ;
	util = L2Util(GetScript("L2Util"));	

	script = PartyWnd(GetScript("PartyWnd"));

	ParseInt(a_Param, "IsSuccess", IsSuccess);
	ParseInt(a_Param, "LootingScheme", LootingScheme);


	//Debug ( "OnPartyLootingHasModified" @ IsSuccess) ;
	//이곳에 스크린메시지 코드 추가. 옵션창 파티루팅방식 콤보박스도 다루어야함

	if(IsSuccess != 0) //성공이기만 하면 partyMatchRoom 의 루팅방식은 무조건 바꿔야한다. //파티창의 방장툴팁도변경
	{		
		script.SetMasterTooltip(LootingScheme);
		Schemestr = util.getLootingString(LootingScheme);
		t_handle = GetTextBoxHandle("PartyMatchRoomWnd.LootingMethod");
		t_handle.SetText(Schemestr);
	}
	
		
	if(bPartyMaster || IsRoomMaster()) //자신이 파티장 혹은 파티방장이라면
	{
		AddSystemMessage(3136);
		if(IsSuccess != 0) //변경 성공 
		{
			SetOptionInt( "Communication", "PartyLooting", LootingScheme ); //방장만 이 방법으로 루팅설정을 저장한다.(자기가 권유한 거니까)
			//do not change. Preserve combobox's current Item.
		}
		else //변경실패 콤보박스 원래로 복귀
		{
			setLootingBoxSelection(GetOptionInt( "Communication", "PartyLooting"));
		}
		setEnableLootingBox(true); //루팅박스 활성화
	}
		

	if(IsSuccess == 0) //fail
	{
		//debug("실패했음");
	}
	else if(IsSuccess == 1)//success 파티원일 경우, 콤보박스만 바꿔주고 저장은 하지않는다
	{
		Schemestr = util.getLootingString(LootingScheme);
		GetSystemMsgInfo( 3138, SystemMsgCurrent);
		
		ParamAdd(strParam, "MsgType", String(1));
		ParamAdd(strParam, "WindowType", String(SystemMsgCurrent.WindowType));
		ParamAdd(strParam, "FontType", String(SystemMsgCurrent.FontType));
		ParamAdd(strParam, "BackgroundType", String(SystemMsgCurrent.BackgroundType));
		ParamAdd(strParam, "LifeTime", String(SystemMsgCurrent.LifeTime * 1000) );
		ParamAdd(strParam, "AnimationType", String(SystemMsgCurrent.AnimationType));
		ParamAdd(strParam, "Msg", MakeFullSystemMsg(SystemMsgCurrent.OnScrMsg,Schemestr));
		ParamAdd(strParam, "MsgColorR", String(SystemMsgCurrent.FontColor.R));
		ParamAdd(strParam, "MsgColorG", String(SystemMsgCurrent.FontColor.G));
		ParamAdd(strParam, "MsgColorB", String(SystemMsgCurrent.FontColor.B));
		ExecuteEvent(EV_ShowScreenMessage, strParam);
		
		PlaySound(SystemMsgCurrent.Sound);
		setLootingBoxSelection(LootingScheme); //저장은 하지 않는다.
		
	}
	else if(IsSuccess == 2)//success 그냥 방안에 있는 사람일 경우. 콤보박스만 바꿔주고 저장은 하지않는다
	{
		Schemestr = util.getLootingString(LootingScheme);
		GetSystemMsgInfo( 3138, SystemMsgCurrent);

		ParamAdd(strParam, "MsgType", String(1));
		ParamAdd(strParam, "WindowType", String(SystemMsgCurrent.WindowType));
		ParamAdd(strParam, "FontType", String(SystemMsgCurrent.FontType));
		ParamAdd(strParam, "BackgroundType", String(SystemMsgCurrent.BackgroundType));
		ParamAdd(strParam, "LifeTime", String(SystemMsgCurrent.LifeTime * 1000) );
		ParamAdd(strParam, "AnimationType", String(SystemMsgCurrent.AnimationType));
		ParamAdd(strParam, "Msg", MakeFullSystemMsg(SystemMsgCurrent.OnScrMsg,Schemestr));
		ParamAdd(strParam, "MsgColorR", String(SystemMsgCurrent.FontColor.R));
		ParamAdd(strParam, "MsgColorG", String(SystemMsgCurrent.FontColor.G));
		ParamAdd(strParam, "MsgColorB", String(SystemMsgCurrent.FontColor.B));
		ExecuteEvent(EV_ShowScreenMessage, strParam);
		
		PlaySound(SystemMsgCurrent.Sound);
		setLootingBoxSelection(LootingScheme); //저장은 하지 않는다.
	}
	
}

/*
 * 파티 루팅 변경
 */
function OnAskPartyLootingModify(String a_Param)
{
	//Using for Party Looting Scheme Modification//
	local string LeaderName;
	local int LootingScheme;
	/////////////////////////////////////////////////
	local string Schemestr;

	local L2Util util ;
	util = L2Util(GetScript("L2Util"));	


	// 파티 아이템 습득 설정, 다이얼로그 창이 열려 있으면 무조건 취소로 세팅 
	
	if ( class'UIAPI_WINDOW'.static.IsShowWindow("DialogBox"))
	{		
		SetRequestPartyLootingModifyAgreement(false);
		return;
	}


	// 다이얼 로그 박스에서 예, 아니오 가 나오도록 한다.
	dScript.SetButtonName( 184, 185 );
	
	class'UICommonAPI'.static.DialogSetID( PARTY_MODIFY_REQUEST );	
	class'UICommonAPI'.static.DialogSetParamInt64( 10*1000 );			// 5 seconds
	class'UICommonAPI'.static.DialogSetDefaultCancle(); // 엔터를 치거나 타임아웃발생시 cancle로 판단
	ParseString(a_Param, "LeaderName", LeaderName);
	ParseInt(a_Param, "LootingScheme", LootingScheme);	
	Schemestr = util.getLootingString(LootingScheme);

	//Modal 에서 Modalless 로 바꿈 TTP 60257
	class'UICommonAPI'.static.DialogShow(DialogModalType_Modalless, DialogType_Progress, MakeFullSystemMsg(GetSystemMessage(3134),Schemestr), string(Self));
}

/*  Referenced by: OnEvent() > EV_StateChanged
 *  Description:
 *	스테이트 별로 단축키 버튼을 활성화할지 비활성화 할지 결정한다.
 */
function UIActivationUponStateChanges(string a_Param)
{
//	Debug ( "UIActivationUponStateChanges" @ a_Param ) ;
	if ( a_Param == "GAMINGSTATE" ||  a_Param == "ARENAGAMINGSTATE" ||  a_Param == "ARENABATTLESTATE" || a_Param == "ARENAPICKSTATE" )
	{
		//서버로 부터 단축키 목록을 리퀘스트 
		HandleSwitchEnterchatting();
		//Debug ( "requestLit");
		class'ShortcutAPI'.static.RequestList();
		//ShortcutBtn.HideWindow();
		isGAMINGSTATE = true;
	}
	else 
	{
		isGAMINGSTATE = false;
		//ShortcutBtn.ShowWindow();
	}
	SetAlwaysOnTop(!isGAMINGSTATE);
	//call_isGAMINGSTATE ();
	InitControlOption();
}

//function setChatOption() 
//{
//	local ChatWnd	script;
//	local int i, tempVar;
//	local bool bChecked;
	
//	script = ChatWnd( GetScript("ChatWnd") );
//	//콤보박스 인덱스에 저장
//	//chatType = script.m_chatType.ID; // 원래는 ID
	
//	//script.m_filterInfo[chatType].bSystem = int( class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.CheckBoxSystem" ) );
//	//script.m_filterInfo[chatType].bUseitem = int( class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.CheckBoxItem" ) );
//	//script.m_filterInfo[chatType].bDamage = int( class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.CheckBoxDamage" ) );
//	//script.m_filterInfo[chatType].bChat = int( class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.CheckBoxChat" ) );
//	//script.m_filterInfo[chatType].bNormal = int( class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.CheckBoxNormal" ) );
//	//script.m_filterInfo[chatType].bParty = int( class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.CheckBoxParty" ) );
//	//script.m_filterInfo[chatType].bShout = int( class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.CheckBoxShout" ) );
//	//script.m_filterInfo[chatType].bTrade = int( class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.CheckBoxTrade" ) );
//	//script.m_filterInfo[chatType].bClan = int( class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.CheckBoxPledge" ) );
//	//script.m_filterInfo[chatType].bWhisper = int( class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.CheckBoxWhisper" ) );
//	//script.m_filterInfo[chatType].bAlly = int( class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.CheckBoxAlly" ) );
//	//script.m_filterInfo[chatType].bHero = int( class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.CheckBoxHero" ) );
//	//script.m_filterInfo[chatType].bUnion = int( class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.CheckBoxUnion" ) );
//	////script.m_filterInfo[chatType].bBattle = int( class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.CheckBoxBattle" ) );
//	//script.m_filterInfo[chatType].bNoNpcMessage = int( class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.CheckBoxNPC" ) );
//	////월드 채팅 추가
//	//script.m_filterInfo[chatType].bWorldChat = int( class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.CheckBoxWorldChat" ) );
	
//	// script.m_NoNpcMessage = int( class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.CheckBoxNPC" ) );	// NPC 대사 필터링 - 2010.9.8 winkey

//	//script.m_NoUnionCommanderMessage = int( class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.CheckBoxCommand" ) );
//	//script.m_KeywordFilterSound = int( class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.KeywordSoundBox" ) );
//	//script.m_KeywordFilterActivate = int( class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.KeywordFilterBox" ) );
//	//script.m_UseAlpha = int( class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.UseChatAlpha" ) );
//	//script.m_ChatResizeOnOff = int( class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.ChattingFilterGroup.ChatWndLock" ) );	
	
//	//script.m_bWorldChatSpeaker = int( class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.ChattingFilterGroup.CheckBoxUseWorldChatSpeaker" ) );

//	//월드 채팅 스피커
//	//bChecked = CheckBoxUseWorldChatSpeaker.IsChecked();
//	//SetINIBool("global","UseWorldChatSpeaker", bChecked, "chatfilter.ini");
	

//	//채팅기호 표시
//	bChecked = UseChatSymbolBox.IsChecked();	
//	//SetOptionBool( "Communication", "OldChatting", bChecked );
//	SetChatFilterBool ( "Global", "OldChatting", bChecked);

//	//채팅창 투명화 <신규 기능>	
//	bChecked = UseChatAlphaBox.IsChecked();
//	SetINIBool("global","ChatWndTransparent", bChecked, "chatfilter.ini");

//	//채팅창 사이즈 조절 <신규 기능>	
//	bChecked = ChatResizeBox.IsChecked();
//	SetINIBool("global","ChatResizing", bChecked, "chatfilter.ini");

//	// 시스템메시지전용창 사용여부 - SystemMsgBox	
//	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.ChattingFilterGroup.UseSystemMsgBox" );
//	SetINIBool("global","SystemMsgWnd", bChecked, "chatfilter.ini");

//	// 시스템메시지전용창 시스템메시지
//	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.ChattingFilterGroup.OnlySystemMsgChannelBox" );
//	SetINIBool("global","UseSystemMsg", bChecked, "chatfilter.ini");
	
//	// 시스템메시지전용창 데미지
//	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.ChattingFilterGroup.OnlySystemMsgDamageBox" );
//	SetINIBool("global","SystemMsgWndDamage", bChecked, "chatfilter.ini");
	
//	// 시스템메시지전용창 소모성아이템사용
//	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.ChattingFilterGroup.OnlySystemMsgItemBox" );
//	SetINIBool("global","SystemMsgWndExpendableItem", bChecked, "chatfilter.ini");
	
//	GetINIBool("global", "SystemMsgWnd", tempVar, "chatfilter.ini");
//	if(bool(tempVar))
//	{
//		 class'UIAPI_WINDOW'.static.ShowWindow("SystemMsgWnd");
//	} 
//	else 
//	{
//		class'UIAPI_WINDOW'.static.HideWindow("SystemMsgWnd");
//	}
	
//	for(i = 0; i < script.m_sectionName.Length; i++)
//	{
//		GetINIBool(script.m_sectionName[i],"system", script.m_filterInfo[i].bSystem, "chatfilter.ini");
//		GetINIBool(script.m_sectionName[i],"damage", script.m_filterInfo[i].bDamage, "chatfilter.ini");
//		GetINIBool(script.m_sectionName[i],"useitems", script.m_filterInfo[i].bUseItem, "chatfilter.ini");
//		GetINIBool(script.m_sectionName[i],"chat", script.m_filterInfo[i].bChat, "chatfilter.ini");
//		GetINIBool(script.m_sectionName[i],"normal", script.m_filterInfo[i].bNormal, "chatfilter.ini");
//		GetINIBool(script.m_sectionName[i],"party", script.m_filterInfo[i].bParty, "chatfilter.ini");
//		GetINIBool(script.m_sectionName[i],"shout", script.m_filterInfo[i].bShout, "chatfilter.ini");
//		GetINIBool(script.m_sectionName[i],"market", script.m_filterInfo[i].bTrade, "chatfilter.ini");
//		GetINIBool(script.m_sectionName[i],"pledge", script.m_filterInfo[i].bClan, "chatfilter.ini");
//		GetINIBool(script.m_sectionName[i],"tell", script.m_filterInfo[i].bWhisper, "chatfilter.ini");
//		GetINIBool(script.m_sectionName[i],"ally", script.m_filterInfo[i].bAlly, "chatfilter.ini");	
//		GetINIBool(script.m_sectionName[i],"hero", script.m_filterInfo[i].bHero, "chatfilter.ini");
//		GetINIBool(script.m_sectionName[i],"union", script.m_filterInfo[i].bUnion, "chatfilter.ini");
//		//SetINIBool(script.m_sectionName[i],"battle", bool(script.m_filterInfo[i].bBattle), "chatfilter.ini");
//		GetINIBool(script.m_sectionName[i],"nonpcmessage", script.m_filterInfo[i].bNoNpcMessage, "chatfilter.ini");
//		//월드 채팅 추가
//		GetINIBool(script.m_sectionName[i],"worldChat", script.m_filterInfo[i].bWorldChat, "chatfilter.ini");
//	}
//	//월드 채팅 스피커
//	GetINIBool("global", "UseWorldChatSpeaker", script.m_bWorldChatSpeaker, "chatfilter.ini");
//	//script.GetAllcurrentAssignedChatTypeID();
	
//	//Global Setting
//	// SetINIBool("global","npc", bool(script.m_NoNpcMessage), "chatfilter.ini");						// NPC 대사 필터링 - 2010.9.8 winkey
//	GetINIBool("global","command", script.m_NoUnionCommanderMessage, "chatfilter.ini");
//	GetINIBool("global","keywordsound", script.m_KeywordFilterSound, "chatfilter.ini");
//	GetINIBool("global","keywordactivate", script.m_KeywordFilterActivate, "chatfilter.ini");
//	//투명기능 사용여부
//	GetINIBool("global","UseAlpha", script.m_UseAlpha, "chatfilter.ini");
	
//	//사이즈 조절 사용여부
//	GetINIBool("global","ChatResizing", script.m_ChatResizeOnOff, "chatfilter.ini");

//	if(bool(script.m_ChatResizeOnOff))	
//		EnableChatWndResizing(false);	
//	else	
//		EnableChatWndResizing(true);

//	GetINIString("global", "Keyword0", script.m_Keyword0, "chatfilter.ini");
//	GetINIString("global", "Keyword1", script.m_Keyword1, "chatfilter.ini");
//	GetINIString("global", "Keyword2", script.m_Keyword2, "chatfilter.ini");
//	GetINIString("global", "Keyword3", script.m_Keyword3, "chatfilter.ini");	




	
//	script.m_KeywordFilterSound = int( class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.KeywordSoundBox" ) );
//	script.m_KeywordFilterActivate = int( class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.KeywordFilterBox" ) );
//}

// 저장된 채팅 옵션 적용
function setChattingOption()
{	
	local ChatWnd	script;
	local SystemMsgWnd SysMsgScript;
	local int tempVal, i, resultNum;	

	script = ChatWnd( GetScript("ChatWnd") );
	SysMsgScript = SystemMsgWnd( GetScript("ChatWnd.SystemMsgWnd") );
	
	for(i = 0; i < script.m_sectionName.Length; i++)
	{
		//getini 로 값을 가져와야됨
		GetINIBool( script.m_sectionName[i], "system", tempVal, "chatfilter.ini" );
		script.m_filterInfo[i].bSystem = tempVal;

		GetINIBool( script.m_sectionName[i], "useitems", tempVal, "chatfilter.ini" );
		script.m_filterInfo[i].bUseitem = tempVal;

		GetINIBool( script.m_sectionName[i], "damage", tempVal, "chatfilter.ini" );
		script.m_filterInfo[i].bDamage = tempVal;

		GetINIBool( script.m_sectionName[i], "chat", tempVal, "chatfilter.ini" );
		script.m_filterInfo[i].bChat = tempVal;

		GetINIBool( script.m_sectionName[i], "normal", tempVal, "chatfilter.ini" );
		script.m_filterInfo[i].bNormal = tempVal;

		GetINIBool( script.m_sectionName[i], "party", tempVal, "chatfilter.ini" );
		script.m_filterInfo[i].bParty = tempVal;

		GetINIBool( script.m_sectionName[i], "shout", tempVal, "chatfilter.ini" );
		script.m_filterInfo[i].bShout = tempVal;

		GetINIBool( script.m_sectionName[i], "market", tempVal, "chatfilter.ini" );
		script.m_filterInfo[i].bTrade = tempVal;

		GetINIBool( script.m_sectionName[i], "pledge", tempVal, "chatfilter.ini" );
		script.m_filterInfo[i].bClan = tempVal;

		GetINIBool( script.m_sectionName[i], "tell", tempVal, "chatfilter.ini" );
		script.m_filterInfo[i].bWhisper = tempVal;

		GetINIBool( script.m_sectionName[i], "ally", tempVal, "chatfilter.ini" );
		script.m_filterInfo[i].bAlly = tempVal;

		GetINIBool( script.m_sectionName[i], "hero", tempVal, "chatfilter.ini" );
		script.m_filterInfo[i].bHero = tempVal;

		GetINIBool( script.m_sectionName[i], "union", tempVal, "chatfilter.ini" );
		script.m_filterInfo[i].bUnion = tempVal;

		GetINIBool( script.m_sectionName[i], "nonpcmessage", tempVal, "chatfilter.ini" );
		script.m_filterInfo[i].bNoNpcMessage = tempVal;

		GetINIBool( script.m_sectionName[i], "worldChat", tempVal, "chatfilter.ini" );
		script.m_filterInfo[i].bWorldChat = tempVal;
	}	
	
	script.m_UseChatSymbol = int ( GetChatFilterBool ( "Global", "OldChatting") ) ;//int(GetOptionBool( "CommunIcation", "OldChatting" ));
	
	//GetINIBool( "global", "command", resultNum, "chatfilter.ini" );
	//script.m_NoUnionCommanderMessage = resultNum;
	
	GetINIBool( "global", "keywordsound", resultNum, "chatfilter.ini" );
	script.m_KeywordFilterSound = resultNum;
	
	GetINIBool( "global", "keywordactivate", resultNum, "chatfilter.ini" );
	script.m_KeywordFilterActivate = resultNum;
	
	GetINIBool( "global", "UseAlpha", resultNum, "chatfilter.ini" );
	script.m_UseAlpha = resultNum;
	
	GetINIBool( "global", "ChatResizing", resultNum, "chatfilter.ini" );	
	script.m_ChatResizeOnOff = resultNum;
	
	
	GetINIBool( "global", "SystemMsgWnd", resultNum, "chatfilter.ini" );
	script.m_bUseSystemMsgWnd = resultNum;
	
	GetINIBool( "global", "UseSystemMsg", resultNum, "chatfilter.ini" );
	script.m_bSystemMsgWnd = resultNum;
	
	// 데미지 - DamageBox
	GetINIBool( "global", "SystemMsgWndDamage", resultNum, "chatfilter.ini" );
	script.m_bDamageOption = resultNum;
	
	// 소모성아이템사용 - ItemBox
	GetINIBool( "global", "SystemMsgWndExpendableItem", resultNum, "chatfilter.ini" );
	script.m_bUseSystemItem = resultNum;

	// 월드 채팅 스피커
	GetINIBool( "global", "UseWorldChatSpeaker", resultNum, "chatfilter.ini" );
	script.m_bWorldChatSpeaker = resultNum;

	// 시스템 메세지 전용 창 표시
	GetINIBool( "global", "OnlyUseSystemMsgWnd", resultNum, "chatfilter.ini" );
	script.m_bOnlyUseSystemMsgWnd = resultNum;
	
	GetINIString("global", "Keyword0", script.m_Keyword0, "chatfilter.ini");
	GetINIString("global", "Keyword1", script.m_Keyword1, "chatfilter.ini");
	GetINIString("global", "Keyword2", script.m_Keyword2, "chatfilter.ini");
	GetINIString("global", "Keyword3", script.m_Keyword3, "chatfilter.ini");	 

	if(Bool( script.m_bUseSystemMsgWnd ))
		class'UIAPI_WINDOW'.static.ShowWindow("SystemMsgWnd");
	else 
		class'UIAPI_WINDOW'.static.HideWindow("SystemMsgWnd");

	
	if(bool(script.m_ChatResizeOnOff))	
		EnableChatWndResizing(false);	
	else	
		EnableChatWndResizing(true);

	script.SetDefaultAlpha(script.m_UseAlpha);
	SysMsgScript.SetDefaultAlpha(script.m_UseAlpha);

	script.GetAllcurrentAssignedChatTypeID();
	//for ( i = 1 ; i < 5 ; i ++ ) 
	//{
	//	GetINIInt( "global", "TabIndex" $ string(i), index, "chatfilter.ini" );
	//	ResetTabChannel ( i , index ) ; 
	//}


}

//function ResetTabChannel(int tabIndex, int ChannelIndex)
//{
//	local ChatWnd script;
//	script = ChatWnd( GetScript("ChatWnd") );

	
//	switch (ChannelIndex)
//	{
//		case 1:
//			script.ChatTabCtrl.SetButtonName( tabIndex, GetSystemString(355));
//			//~ SetINIInt("global", "TabIndex1", ChannelIndex, "chatfilter.ini");
//			//~ m_ChatUI[8].ID = 1;
//			//~ m_ChatUI[].UI = tabIndex;
//			//~ AssignCurrentChatTypeID(ChannelIndex, tabIndex);
//		break;
//		case 2:
//			script.ChatTabCtrl.SetButtonName( tabIndex, GetSystemString(188));
//			//~ SetINIInt("global", "TabIndex2", 2, "chatfilter.ini");
//		break;
//		case 3:
//			script.ChatTabCtrl.SetButtonName( tabIndex, GetSystemString(128));
//			//~ SetINIInt("global", "TabIndex3", 3, "chatfilter.ini");
//		break;
//		case 4:
//			script.ChatTabCtrl.SetButtonName( tabIndex, GetSystemString(559));
//			//~ SetINIInt("global", "TabIndex4", 4, "chatfilter.ini");
//		break;
//		case 5:
//			script.ChatTabCtrl.SetButtonName( tabIndex, GetSystemString(1961));
//			//~ SetINIInt("global", "TabIndex5", 5, "chatfilter.ini");
//		break;
//		case 6:
//			script.ChatTabCtrl.SetButtonName( tabIndex, GetSystemString(1962));
//			//~ SetINIInt("global", "TabIndex6", 6, "chatfilter.ini");
//		break;
//		case 7:
//			script.ChatTabCtrl.SetButtonName( tabIndex, GetSystemString(1963));
//			//~ SetINIInt("global", "TabIndex7", 7, "chatfilter.ini");
//		break;
//		case 8:
//			script.ChatTabCtrl.SetButtonName( tabIndex, GetSystemString(1964));
//			//~ SetINIInt("global", "TabIndex8", 8, "chatfilter.ini");
//		break;
//	}
//}
defaultproperties
{
}
