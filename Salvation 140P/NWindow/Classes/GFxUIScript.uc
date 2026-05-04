class GFxUIScript extends UIScript
	dynamicrecompile
	native;

var Object m_pTargetWnd;

enum EFlashImageLoaderType
{
	EImgLoader_None,
	EImgLoader_Pledge,
	EImgLoader_PackageTexture
};
enum EExternalFunctionType
{
	EFunc_None,
	EFunc_SysStringTranslator,
};

enum EDelegateHandlerType
{
	EDHandler_Default,
	EDHandler_OlympiadArenaList,
	EDHandler_UseSkill,
	EDHandler_Container,
	EDHandler_DamageText,
	EDHandler_Statistic,
	EDHandler_NotifyUSMEnd,
	EDHandler_ClanUnionAction,
	EDHandler_EventKalieWnd,
	EDHandler_Option,
	EDHandler_ShortcutAPI,
	EDHandler_InputAPI,
	EDHandler_BeautyshopWnd,
	EDHandler_ChatWnd,
	EDHandler_PledgeRecruit,
	EDHandler_EventChristmasWnd,
	EDHandler_LoginPIAgreementWnd,
	EDHandler_EventCardWnd,
	EDHandler_AdenaDistributionWnd,
	EDHandler_AbilityWnd,
	EDHandler_GFxDebug,
	EDHandler_LuckyGameWnd,		//branch121212
	EDHandler_TrainingRoomWnd,	//branch121212
	EDHandler_Event10thAnniversary,
	EDHandler_RadarMap,
	EDHandler_AlchemyAPI,		// 연금술 작업 - by y2inc (2013. 10. 10)
	EDHandler_FishWnd,
	EDHandler_VipSystem,		//branch EP2.0 2015.2.25 luciper3 - VIP 정보창
	EDHandler_Arena,
	EDHandler_FactionWnd,	// Faction System(#2029) - moonhj
	EDHandler_Minimap,
	EDHandler_UpgradeSystemWnd,	// 업그레이드 시스템(#4275) - by moonhj
	EDHandler_GameData,
	EDHandler_OBS,
	EDHandler_CardUpdownGame,	// 카드 숫자 게임(#4288) szmyoung
	EDHandler_PledgeWnd,		// 혈맹UI
//	EDHandler_Honor,			#ifdef HONOR
//	EDHandler_RecipeWnd			#ifdef NEW_GFX_RECIPE_UI
	EDHandler_Tutorial			// 도움말 개선(#4620) szmyoung
};

native function RegisterEvent( int ev);
native function RegisterGFxEventForLoaded(int ev);
native function RegisterGFxEvent( int ev );
//ShowFlash 함수 쓸 필요 없다. ShowWindow를 사용하면 됨.
native function RegisterState(string WindowName, string state);
native final function bool ShowFlashFromFilePath(string filePath, optional bool bDuplicated );
native final function CreateObject(out GFxValue val);
native final function CreateArray(out GFxValue val);
native final function bool Invoke(string funcName, out array<GFxValue> args, out GFxValue result);
native final function AllocGFxValues(out array<GFxValue> args, int num);	//함수 이름을 바꾸면 안 됨 -jumper
native final function DeallocGFxValues(out array<GFxValue> args);			//함수 이름을 바꾸면 안 됨 -jumper
native final function AllocGFxValue(out GFxValue val);						//함수 이름을 바꾸면 안 됨 -jumper
native final function DeallocGFxValue(out GFxValue val);					//함수 이름을 바꾸면 안 됨 -jumper
native final function RegisterDelegateHandler(EDelegateHandlerType type);
native final function bool GetVariable(out GFxValue val, string PathToVar);
native final function GetFunction(out GFxValue val, EExternalFunctionType funcType);
//native function UIScript GetScript( string window );
native function SetMsgPassThrough(bool bPass);
native function SetAlwaysFullAlpha(bool bFull);
native function SetRenderOnTop(bool bSet);		//가장 최상위에 그리기 위해 WM_POSTPAINT메시지 받을때 그린다. 예)툴팁 Added by JoeyPark 2011/02/08
native function SetDefaultShow(bool bSet);		//게임 상태에 따라 항상 보여줘야 하는 윈도우 인지를 설정한다.
native final function ShowWindow(optional string windowName);
native final function HideWindow(optional string windowName);
native final function bool IsShowWindow(optional string windowName);
native final function SetFocus(optional string windowName);
native final function BringToFront();
native final function MakeRenderToTexture(bool bScreenSizeRenderTarget);
native final function IgnoreUIEvent(bool bIgnore);
native final function SetHavingFocus(bool bFocus);
native final function FlashMoviePlayStart(int iReserved);
native final function FlashMoviePlayEnd(int iReserved);
native final function SetAnchor( string targetWindowName, EAnchorPointType targetPointType, EAnchorPointType anchorPointType, int offsetX, int offsetY); 
native final function SetFixedPositionRate(float fVerticalPositionRate, float fHorizontalPositionRate);
native final function ApplyFixedPositionRate();

native final function SetRestartableFlash();
native final function SetContainer( string containerName );	//지정된 컨테이너가 플래쉬 로딩
native final function SetStateChangeNotification(); //상태 변경 시 무비의 onStateIn, onStateOut을 호출한다.

native final function HasTextField(bool enableIME); //GFx용 IME사용여부 셋팅
native final function SetHasGFxTextField(bool hasTextField);	// GFx창이 TextField를 가지고 있는지 Set하는 함수
//native final function SetGFxPassThrough(bool PassThrough);
native final function SetNextFocus();
native final function SetModal(bool a_Modal);
native final function SetAlwaysOnTop(bool bAlwaysOnTop);
native final function SetRotateCursor();
native final function UnsetRotateCursor();

native final function bool IsSavedInfo();
native final function bool SetGFxFromSavedInfo();

native final function GetAnchorPointFromWindow( out float X, out float Y, EAnchorPointType anchorType );

native function SetClosingOnESC();
native final function SetHUD();

native final function ForceToMoveMousePos( float X, float Y );

native final function SendCommandToServer(string command);

event OnCallUCLogic( int logicID, string param );

event OnFlashLoaded();
event OnFocus(bool bFocused, bool bTransparencyMode);

native final function SetEulaText(out GFxValue val, string name); //branch 111109
native final function int GetUserPremiumLevel(); //branch 유저 프리미엄 레벨

//branch121212
native final function SetTimer( int a_TimerID, int a_DelayMiliseconds );
native final function KillTimer( int a_TimerID );
//end of branch
defaultproperties
{
}
