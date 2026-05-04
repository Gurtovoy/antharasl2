//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : SceneClipView  ( 비디오, 무비클립 재생기 ) - SCALEFORM UI
//                스케일폼 4.x 버전으로 컨버팅, sceneClipViewFullScreen와 통합
//
//                이전 버전에서 쓰던 sceneClipViewFullScreen 은 삭제됨
//------------------------------------------------------------------------------------------------------------------------
class SceneClipView extends L2UIGFxScript;

var int  MovieID, currentScreenWidth, currentScreenHeight, audioVolume;
var bool bIsBuilderPC;

// 자막 폰트 사이즈
const CAPTION_FONTSIZE = 10;
// 자막 기본 Y값에서 ADD (각국 언어별 문제 대처용)
const CAPTION_ADDPOSY  = -5; 

function OnRegisterEvent()
{
	//----------------
	// Flash Event
	//----------------
	registerGFXEvent( EV_ShowSceneClipView );
	registerGFXEvent( EV_ShowFullSceneClipView );
	registerGFXEvent( EV_DeleteSceneClipView );	
	registerGFXEvent( EV_DeleteFullSceneClipView );
	registerGFXEvent( EV_OptionHasApplied);
	RegisterGFxEventForLoaded( EV_ResolutionChanged );

	//----------------
	// UC Event
	//----------------
	// 옵션 갱신 될때
	registerEvent( EV_OptionHasApplied );	
	//registerEvent( EV_DeleteFullSceneClipView );
	// UC 에서 처리 스크립트
	// UsmMovieData-k 스크립트를 읽어서 EV_ShowSceneClipView, EV_ShowFullSceneClipView 이벤트 발생 시킴
	registerEvent( EV_ShowUsm );
}

function OnLoad()
{
	// RegisterDelegateHandler(EDHandler_NotifyUSMEnd);
	registerState( "SceneClipView", "GamingState" );
	SetHavingFocus(false);	
}

function setSceneClipMode(bool bFullScreen)
{
	if (bFullScreen)
	{	
		SetAlwaysOnTop(true);
		//MakeRenderToTexture(true);
		//SetMsgPassThrough(true);
		//// SetAlwaysFullAlpha(true);
		SetRenderOnTop(true);	
		//SetHavingFocus(false);			
	}
	else
	{	
		SetAlwaysOnTop(false);
		//// MakeRenderToTexture(false);	
		//SetMsgPassThrough(false);
		//// SetAlwaysFullAlpha(true);
		SetRenderOnTop(false);	
		//SetHavingFocus(true);		
	}
}

function OnFlashLoaded()
{
	SetAnchor("", EAnchorPointType.ANCHORPOINT_TopLeft, EAnchorPointType.ANCHORPOINT_TopLeft, 0, 0);
	// RegisterDelegateHandler(EDHandler_NotifyUSMEnd);	
}

function OnShow()
{	
	Debug("onSHow Flash USM");
}

function OnHide()
{
}

function OnEnterState( name a_PreStateName )
{
}

function OnExitState( name a_NextStateName )
{
}

function OnDefaultPosition ()
{
}

/**
 *   OnCallUCLogic (플래시 -> UC 콜)
 *   byGFXCall
 **/

function OnCallUCFunction( string logicID, string statusStr )
{
	local int    movieID;

	movieID = int(logicID);

	// Debug("실행     :" @ movieID);
	// Debug("statusStr:" @ statusStr);

	if (statusStr == "start")
	{
		setSceneClipMode(false);
		Debug("영상 시작 - MovieID:" @ string(movieID));		
		//FlashMoviePlayStart(movieID);
	}
	else if (statusStr == "finish")
	{		
		Debug("영상 끝 - MovieID:" @ string(movieID));	
		FlashMoviePlayEnd(movieID);
		HideWindow();
	}

	else if (statusStr == "fullScreenStart")
	{
		setSceneClipMode(true);
		Debug("풀 스크린 영상 시작 - fullScreenStart MovieID:" @ string(movieID));
		FullScreenMovieStart();
	}
	else if (statusStr == "fullScreenFinish")
	{		
		Debug("풀 스크린 영상 끝");
		FullScreenMovieEnd();
		onMovieEnd();		
		HideWindow();
	}

	// 별도 실행 기능, 이제 사용 안함.
	if (logicID == "IsBuilderPC")
	{		
		bIsBuilderPC = IsBuilderPC();
		Debug("Refresh IsBuilderPC" @ bIsBuilderPC);
	}
	// 사운드 값 갱신
	else if (logicID == "soundUpdate")
	{	
		audioVolume = getAudioVolume();
	}
}

/**
 *  이벤트 번호 
 *  1 : 비디오 재생
 *  2 : 비디오 삭제
 *  
 *  5620
 *  posX=0 posY=0 FileName=gd10_prologue.usm Width=400 Height=300 SkinType=0 SkipButtonType=1 TargetAnchorPointType=TopLeft clipAnchorPointType=TopLeft
 *  posX=0 posY=0 FileName=gd10_prologue.usm Width=400 Height=300 SkinType=0 SkipButtonType=1 TargetAnchorPointType=CenterCenter clipAnchorPointType=CenterCenter
 **/
function OnEvent(int Event_ID, string param)
{
	local int movieID;

	// 이벤트 번호 5622
	if (Event_ID == EV_ShowUsm)
	{
		ParseInt(param   , "MovieID"        , movieID);

		// bIsBuilderPC = IsBuilderPC();

		// Debug("bIsBuilderPC--EV_ShowUsm" @ bIsBuilderPC);
		
		// FlashMoviePlayStart 함수를 실행 하면 --> Ev_ShowSceneClipView 이벤트로 usmMovieData.txt 의 스크립트 정보를 기초로
		// 해당 데이타를 받을 수 있다.
		if (movieID >= 0)
		{
			ShowWindow();
			Debug("Call FlashMoviePlayStart -> " @ movieID);
			FlashMoviePlayStart(movieID); 
		}
		else 
		{
			Debug("Error: Wrong MovieID ");
		}

		audioVolume = getAudioVolume();
	}
	//else if (Event_ID == EV_DeleteFullSceneClipView)
	//{
	//	FullScreenMovieEnd();
	//	onMovieEnd();
	//}
}

function onMovieEnd()
{	
	//듀얼 과금제 과련 무비 완료를 GFX 확인 
	local GfxDialog GfxDialogScript;
	gfxDialogScript = GfxDialog( GetScript("GfxDialog") );
	gfxDialogScript.onMovieEnd();
}

/**
 *  배경 사운드 볼륨 얻기
 **/
function int getAudioVolume ()
{
	//local int   iMusicVolume;
	local float fMusicVolume;
	local float fSoundVolume;
	
	local float fEffectVolume;
	local float fAmbientVolume;
	local float fSystemVoiceVolume;
	local float fNpcVoiceVolume;

	local float fMaxVolume;
	
	if (GetOptionBool( "Audio", "AudioMuteOn" )) return 0 ;	

	fMusicVolume       = GetOptionFloat( "Audio", "MusicVolume" );
	fEffectVolume      = GetOptionFloat( "Audio", "EffectVolume" );
	fAmbientVolume     = GetOptionFloat( "Audio", "AmbientVolume" );
	fSystemVoiceVolume = GetOptionFloat( "Audio", "SystemVoiceVolume" );
	fNpcVoiceVolume    = GetOptionFloat( "Audio", "NpcVoiceVolume" );
	fSoundVolume       = GetOptionFloat( "Audio", "SoundVolume" );

	fMaxVolume = fMax(fMusicVolume, fEffectVolume);
	fMaxVolume = fMax(fMaxVolume, fAmbientVolume);
	fMaxVolume = fMax(fMaxVolume, fSystemVoiceVolume);	
	fMaxVolume = fMax(fMaxVolume, fNpcVoiceVolume);	

	return fMaxVolume * fSoundVolume * 100;
}


///**
// *   배치 위치 세팅 
// **/
//function EAnchorPointType getAnchorPointByString(string tAnchorPointType)
//{	
//	local EAnchorPointType returnAnchorPointType;
//	// Debug("caps(tAnchorPointType)" @ caps(tAnchorPointType));

//	switch (caps(tAnchorPointType))
//	{
//		case "NONE"         : returnAnchorPointType = EAnchorPointType.ANCHORPOINT_None; break;
//		case "TOPLEFT"      : returnAnchorPointType = EAnchorPointType.ANCHORPOINT_TopLeft; break;
//		case "TOPCENTER"    : returnAnchorPointType = EAnchorPointType.ANCHORPOINT_TopCenter; break;
//		case "TOPRIGHT"     : returnAnchorPointType = EAnchorPointType.ANCHORPOINT_TopRight; break;
//		case "CENTERLEFT"   : returnAnchorPointType = EAnchorPointType.ANCHORPOINT_CenterLeft; break;
//		case "CENTERCENTER" : returnAnchorPointType = EAnchorPointType.ANCHORPOINT_CenterCenter; break;
//		case "CENTERRIGHT"  : returnAnchorPointType = EAnchorPointType.ANCHORPOINT_CenterRight; break;
//		case "BOTTOMLEFT"   : returnAnchorPointType = EAnchorPointType.ANCHORPOINT_BottomLeft; break;
//		case "BOTTOMCENTER" : returnAnchorPointType = EAnchorPointType.ANCHORPOINT_BottomCenter; break;
//		case "BOTTOMRIGHT"  : returnAnchorPointType = EAnchorPointType.ANCHORPOINT_BottomRight; break;
//		default             : returnAnchorPointType = EAnchorPointType.ANCHORPOINT_None; 
//	}
//	// Debug("returnAnchorPointType->" @ returnAnchorPointType);
//	return returnAnchorPointType;
//}
defaultproperties
{
}
