// 도움말에서 빠짐. 별도로 PlayerAgeWnd 
// 15세 사용가도 없어진 상황 (non pk 서버가 없어짐)
class AgeWnd extends UICommonAPI;

var WindowHandle Me;
var TextureHandle AgeTex;
var WindowHandle HelpHtmlWnd;

// var WindowHandle m_hHelpHtmlWndAgeHelpWnd;
// var TextureHandle m_hHelpHtmlWndAgeHelpWndAgeTex;

const TIMER_ID=148;
const TIMER_DELAY=5000;

const TIMER_ID2=149;
const TIMER_DELAY2=600000;

var string Texture15;
var string Texture18;
var string TextureFree;
var string HelpTexture15;
var string HelpTexture18;
var string HelpTextureFree;

var bool bBlock;

function OnRegisterEvent()
{
	RegisterEvent( EV_ServerAgeLimitChange );
}

function OnLoad()
{
	Initialize();
	Load();
	//Me.ShowWindow();
}

function Initialize()
{
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	if(CREATE_ON_DEMAND==0)
	{
		Me = GetHandle( "AgeWnd" );
		AgeTex = TextureHandle ( GetHandle( "AgeWnd.AgeTex" ) );
		// HelpHtmlWnd = GetHandle( "HelpHtmlWnd" );

		// m_hHelpHtmlWndAgeHelpWnd=GetHandle("HelpHtmlWnd.AgeHelpWnd");
		// m_hHelpHtmlWndAgeHelpWndAgeTex=TextureHandle(GetHandle("HelpHtmlWnd.AgeHelpWnd.AgeTex"));
	}
	else
	{
		Me = GetWindowHandle( "AgeWnd" );
		AgeTex = GetTextureHandle( "AgeWnd.AgeTex" );
		// HelpHtmlWnd = GetWindowHandle( "HelpHtmlWnd" );

		// m_hHelpHtmlWndAgeHelpWnd=GetWindowHandle("HelpHtmlWnd.AgeHelpWnd");
		// m_hHelpHtmlWndAgeHelpWndAgeTex=GetTextureHandle("HelpHtmlWnd.AgeHelpWnd.AgeTex");
	}

	
	bBlock = false;
}

function Load()
{	
	Texture15 = "L2Font.Skins.kr_rated_15";
	Texture18 = "L2Font.Skins.kr_rated_18";
	TextureFree = "";
	HelpTexture15 ="L2Font.Skins.Help_Age_15";
	HelpTexture18 ="L2Font.Skins.Help_Age_18";
	HelpTextureFree="";
}

//처음 시작할때
function OnEnterState( name a_PrevStateName )
{
	if( a_PrevStateName == 'LoadingState' )		
	{
		if(!bBlock)	startAge();
	}
}


function startAge()
{
	// 여기서 페이드 인 텍스쳐
	//AgeTex.SetAlpha( 0 );
	Me.ShowWindow();
	AgeTex.ShowWindow();
	//AgeTex.SetAlpha( 255, 2.0f );
	Me.SetTimer(TIMER_ID,TIMER_DELAY);	//해당 시간이 지나면 페이드 아웃 시켜준다. 
	
	bBlock = true;	//자주 볼수 없게 막는다. 
	Me.SetTimer(TIMER_ID2,TIMER_DELAY2);
}

function OnTimer(int TimerID)
{
	if(TimerID == TIMER_ID)
	{
		Me.HideWindow();
		Me.KillTimer( TIMER_ID );
	}
	else if(TimerID == TIMER_ID2)	//타이머가 다되면 블락을 꺼준다. 
	{
		bBlock = false;
		Me.KillTimer( TIMER_ID2 );
	}
}

function OnEvent( int a_EventID, String a_Param )
{
	local int ServerAgeLimitInt;
	// local int nWndWidth, nWndHeight;	// 윈도우 사이즈 받기 변수
	local EServerAgeLimit ServerAgeLimit;
	local int GlobalVersion;
			
	if( a_EventID == EV_ServerAgeLimitChange )
	{
		ParseInt( a_Param, "ServerAgeLimit", ServerAgeLimitInt );
		ParseInt( a_Param, "GlobalVersion", GlobalVersion );
		
		//branch 110824
		if( GlobalVersion > 0 ) 
		{
			bBlock = true; //해외에서는 사용안함
			return;
		}
	
		ServerAgeLimit = EServerAgeLimit( ServerAgeLimitInt );
		switch( ServerAgeLimit )	//각각의 텍스쳐를 설정해준다. 
		{
		case SERVER_AGE_LIMIT_15:	
			//debug( "Texture15=" $ HelpTexture15 );
			AgeTex.SetTexture(Texture15);
			// m_hHelpHtmlWndAgeHelpWndAgeTex.SetTexture(HelpTexture15);
			//HelpHtmlWnd.GetWindowSize(nWndWidth, nWndHeight);	// width는 버린다 -_-;; Height만 사용
			//HelpHtmlWnd.SetWindowSize(nWndWidth, 501);	// 높이를 82 늘려준다. (등급표시 텍스트의 높이)
			//class'UIAPI_TEXTURECTRL'.static.SetTexture( "HelpHtmlWnd.AgeHelpWnd", LoadingTexture15 );
			break;
		case SERVER_AGE_LIMIT_18:
			//debug( "Texture18=" $ HelpTexture18 );
			AgeTex.SetTexture(Texture18);
			// HelpHtmlWnd.GetWindowSize(nWndWidth, nWndHeight);	// width는 버린다 -_-;; Height만 사용
			// HelpHtmlWnd.SetWindowSize(nWndWidth, 501);	// 높이를 82 늘려준다. (등급표시 텍스트의 높이)
			// m_hHelpHtmlWndAgeHelpWndAgeTex.SetTexture(HelpTexture18);
			break;
		case SERVER_AGE_LIMIT_Free:
			//debug( "TextureFree=" $ TextureFree );
		default:
			AgeTex.SetTexture(TextureFree);
			AgeTex.HideWindow();
			// m_hHelpHtmlWndAgeHelpWnd.HideWindow();
			break;
		}
	}
}
defaultproperties
{
}
