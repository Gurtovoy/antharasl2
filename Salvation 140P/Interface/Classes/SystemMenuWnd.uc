class SystemMenuWnd extends UICommonAPI;

var string m_WindowName;
var WindowHandle m_hOptionWnd;
var WindowHandle m_hUserPetitionWnd;
var WindowHandle m_hNewUserPetitionWnd;
var WindowHandle m_hMovieCaptureWnd;//ldw 동영상 캡쳐윈도우 
var WindowHandle m_hArchiveViewWnd;//ldw 박물관 윈도우
var WindowHandle m_hMovieCaptureWnd_Expand;
var WindowHandle PostBoxWnd;
var WindowHandle W24HzWnd;//ldw 24Hz 윈도우
var TextBoxHandle m_hTbBBS;
var TextBoxHandle m_hTbMacro;

var int IsPeaceZone;		//현재 지역 PeaceZone인가

const DIALOGID_Gohome = 0;

function OnRegisterEvent()
{
	RegisterEvent( EV_LanguageChanged );
	RegisterEvent( EV_SetRadarZoneCode );
	RegisterEvent( EV_DialogOK );
	RegisterEvent( EV_DialogCancel );
}

function OnLoad()
{
	SetClosingOnESC();

	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	if(CREATE_ON_DEMAND==0)
	{
		
		m_hArchiveViewWnd=GetHandle("ArchiveViewWnd");//ldw 박물관 윈도우
		m_hMovieCaptureWnd=GetHandle("MovieCaptureWnd");//ldw 동영상 캡쳐
		m_hMovieCaptureWnd_Expand = GetHandle("MovieCaptureWnd_Expand");//ldw 동영상 캡쳐
		m_hOptionWnd=GetHandle("OptionWnd");
		m_hUserPetitionWnd=GetHandle("UserPetitionWnd");
		m_hNewUserPetitionWnd=GetHandle("NewUserPetitionWnd");
		m_hTbBBS=TextBoxHandle(GetHandle("SystemMenuWnd.txtBBS"));
		m_hTbMacro=TextBoxHandle(GetHandle("SystemMenuWnd.txtMacro"));
		PostBoxWnd=GetHandle("PostBoxWnd");
		W24HzWnd= GetHandle("W24HzWnd");		
	}
	else
	{
		m_hArchiveViewWnd=GetWindowHandle("ArchiveViewWnd");//ldw 박물관 윈도우
		m_hMovieCaptureWnd=GetWindowHandle("MovieCaptureWnd");//ldw 동영상 캡쳐
		m_hMovieCaptureWnd_Expand = GetWindowHandle("MovieCaptureWnd_Expand");//ldw 동영상 캡쳐
		m_hOptionWnd=GetWindowHandle("OptionWnd");
		m_hUserPetitionWnd=GetWindowHandle("UserPetitionWnd");
		m_hNewUserPetitionWnd=GetWindowHandle("NewUserPetitionWnd");
		m_hTbBBS=GetTextBoxHandle("SystemMenuWnd.txtBBS");
		m_hTbMacro=GetTextBoxHandle("SystemMenuWnd.txtMacro");
		PostBoxWnd=GetWindowHandle("PostBoxWnd");
		W24HzWnd= GetWindowHandle("W24HzWnd");	
	}

	SetMenuString();
}

function OnClickButton( string strID )
{
	switch( strID )
	{


	case "btnArchive":
		HandlebtnArchive();
		break;
	case "btnPersonalConnections":	
		HandlePersonalConnectionsWnd();
		break;
	case "btnPost":
		HandleShowPostBoxWnd();
		break;
	case "btnBBS":
		HandleShowBoardWnd();
		break;
	case "btnMacro":
		HandleShowMacroListWnd();
		break;
	case "btnMovieCapture"://ldw 동영상 캡쳐
		//Debug("MovieCapture button Clicked");
		HandleShowMovieCaptureWnd();
		break;
	case "btnHelpHtml":
		HandleShowHelpHtmlWnd();
		break;
	case "btn24hz"://ldw 24Hz 열기 함수
		W24HzShowWnd();
		break;
	case "btnPetition":
		HandleShowPetitionBegin();
		break;
	case "btnOption":
		HandleShowOptionWnd();
		break;
	//홈페이지 링크(10.1.18 문선준 추가)
	case "btnHomepage":
		linkHomePage();
		break;
	//
	case "btnRestart":
		ExecuteEvent(EV_OpenDialogRestart);
		break;
	case "btnQuit":
		ExecuteEvent(EV_OpenDialogQuit);
		break;
	}
}

function HandlebtnArchive(){
	/*if (m_hArchiveViewWnd.IsShowWindow())
	{
		PlayConsoleSound(IFST_WINDOW_CLOSE);
		m_hArchiveViewWnd.HideWindow();
	}
	else
	{
		PlayConsoleSound(IFST_WINDOW_OPEN);
		ExecuteEvent(EV_StatisticWndshow);
		//m_hArchiveViewWnd.ShowWindow();
		//m_hArchiveViewWnd.SetFocus();
	}*/
	Debug("HandlebtnArchive button clicked");
	ExecuteEvent(EV_StatisticWndshow);
}

function OnEvent(int Event_ID, String param)
{
	local int zonetype;
	if( Event_ID == EV_LanguageChanged )
	{
		SetMenuString();
	}
	else if ( Event_ID == EV_SetRadarZoneCode )
	{
		ParseInt( param, "ZoneCode", zonetype );		
		if (zonetype == 12)
		{
			IsPeaceZone = 1;
		}
		else
		{
			IsPeaceZone = 0;
		}
	}
	else if( Event_ID == EV_DialogOK )
	{
		HandleDialogOK();
	}
	else if( Event_ID == EV_DialogCancel )
	{
		
	}
}

// 익맥관리 시스템 열기 
function HandlePersonalConnectionsWnd ()
{
	if( GetWindowHandle("PersonalConnectionsWnd").isShowWindow())
	{
		GetWindowHandle("PersonalConnectionsWnd").HideWindow();
	}
	else
	{
		GetWindowHandle("PersonalConnectionsWnd").ShowWindow();
		GetWindowHandle("PersonalConnectionsWnd").SetFocus();
	}
	
}

//홈페이지 링크(10.1.18 문선준 추가)

function linkHomePage()
{
	DialogSetID( DIALOGID_Gohome);
	DialogShow( DialogModalType_Modalless, DialogType_OKCancel, GetSystemMessage( 3208 ), string(Self));
}

function HandleDialogOK()
{
	if( !DialogIsMine())
		return;

	switch( DialogGetID())
	{
	case DIALOGID_Gohome:
		OpenL2Home();
		break;
	}
}

function W24HzShowWnd()//ldw 24hz 열기 함수 
{	
	if( W24HzWnd.isShowWindow())//보여지면 닫기
	{
		PlayConsoleSound(IFST_WINDOW_CLOSE);
		W24HzWnd.HideWindow();
	}
	else //아니면 열기
	{
		PlayConsoleSound(IFST_WINDOW_OPEN);
		W24HzWnd.ShowWindow();
		W24HzWnd.SetFocus();
	}
}


function HandleShowPostBoxWnd()
{
	if( PostBoxWnd.isShowWindow())
	{
		PostBoxWnd.HideWindow();
	}
	else
	{
		RequestRequestReceivedPostList();
		if (IsPeaceZone == 0)
			AddSystemMessage(3066);
	}
}


function HandleShowBoardWnd()
{
	local string strParam;
	ParamAdd(strParam, "Init", "1");
	ExecuteEvent(EV_ShowBBS, strParam);
}

function HandleShowHelpHtmlWnd()
{
	local  AgeWnd script1;	// 등급표시 스크립트 가져오기
	
	local string strParam;
	ParamAdd(strParam, "FilePath", "..\\L2text\\help.htm");
	ExecuteEvent(EV_ShowHelp, strParam);
	
	script1 = AgeWnd( GetScript("AgeWnd") );
	
	if(script1.bBlock == false)	script1.startAge();	//등급표시를 켜준다. 
}

function HandleShowMacroListWnd()
{
	ExecuteEvent(EV_MacroShowListWnd);
}


function HandleShowMovieCaptureWnd()//ldw 동영상 캡쳐 윈도우 띄우기
{
	local bool tmpBool;
	/*local  MovieCaptureWnd  script;	
	script = MovieCaptureWnd( GetScript( "MovieCaptureWnd" ) );	
	tmpBool = script.IsCapturingFlag;		
	Debug("IsCapturingFlag = "$script.IsCapturingFlag);*/
	tmpBool =IsNowMovieCapturing();

	if(tmpBool){//ldw 켑쳐링 되고 있다면
		m_hMovieCaptureWnd.HideWindow();//혹시 모르니 재차 닫자.
		if (m_hMovieCaptureWnd_Expand.IsShowWindow()){//확장 창이 보여 진다면
			PlayConsoleSound(IFST_WINDOW_CLOSE);
			m_hMovieCaptureWnd_Expand.HideWindow();
		} else {			
			PlayConsoleSound(IFST_WINDOW_OPEN);
			m_hMovieCaptureWnd_Expand.ShowWindow();
			m_hMovieCaptureWnd_Expand.SetFocus();
		}
	} else {//아니라면 일반 창 열고 닫기
		if (m_hMovieCaptureWnd.IsShowWindow())
		{
			PlayConsoleSound(IFST_WINDOW_CLOSE);
			m_hMovieCaptureWnd.HideWindow();
		} else{	
			PlayConsoleSound(IFST_WINDOW_OPEN);
			m_hMovieCaptureWnd.ShowWindow();
			m_hMovieCaptureWnd.SetFocus();
		}
	}	
}


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


function HandleShowOptionWnd()
{
	if (m_hOptionWnd.IsShowWindow())
	{
		PlayConsoleSound(IFST_WINDOW_CLOSE);
		m_hOptionWnd.HideWindow();
	}
	else
	{
		PlayConsoleSound(IFST_WINDOW_OPEN);
		m_hOptionWnd.ShowWindow();
		m_hOptionWnd.SetFocus();
	}
}

function SetMenuString()
{
	//단축키 붙여주기
	m_hTbBBS.SetText(GetSystemString(387) $ "(Alt+B)");
	m_hTbMacro.SetText(GetSystemString(711) $ "(Alt+R)");
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( m_WindowName ).HideWindow();
}

defaultproperties
{
    m_WindowName="SystemMenuWnd"
}
