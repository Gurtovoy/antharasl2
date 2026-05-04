/***
 * 
 *   몬스터 투기장 결과창 
 *   
 **/
class MonsterArenaResultWnd extends UICommonAPI;

var WindowHandle  Me;

var TextBoxHandle txtPlayMode;
var TextBoxHandle txtStage;
var TextBoxHandle txtStageScore;
var TextBoxHandle txtTotalScore;

var ButtonHandle BtnClose;

const TIMER_ID=1490;
const TIMER_DELAY=10000;

function OnRegisterEvent()
{
	RegisterEvent( EV_AI_CONTENT_MONSTER_ARENA_SCORE );
}

function OnLoad()
{
	SetClosingOnESC();
	Initialize();
}

function Initialize()
{
	Me = GetWindowHandle( "MonsterArenaResultWnd" );	

	txtPlayMode	    = GetTextBoxHandle( "MonsterArenaResultWnd.PlayReportWnd.txtPlayMode" );
	txtStage	    = GetTextBoxHandle( "MonsterArenaResultWnd.PlayReportWnd.txtStage" );
	txtStageScore	= GetTextBoxHandle( "MonsterArenaResultWnd.PlayReportWnd.txtStageScore" );
	txtTotalScore	= GetTextBoxHandle( "MonsterArenaResultWnd.PlayReportWnd.txtTotalScore" );

	BtnClose  = GetButtonHandle( "MonsterArenaResultWnd.BtnClose" );	
}

function onShow()
{
	Me.SetTimer(TIMER_ID,TIMER_DELAY);	//해당 시간이 지나면 페이드 아웃 시켜준다. 
}

//-----------------------------------------------------------------------------------------------------------
// OnTimer
//-----------------------------------------------------------------------------------------------------------
function OnTimer(int TimerID)
{
	if(TimerID == TIMER_ID)
	{
		Me.HideWindow();
		Me.KillTimer( TIMER_ID );
	}	
}



//-----------------------------------------------------------------------------------------------------------
// OnClickButton
//-----------------------------------------------------------------------------------------------------------
function OnClickButton( string Name )
{
	switch( Name )
	{		
		case "BtnClose":
			 Me.HideWindow();
			 break;
	}
}


//-----------------------------------------------------------------------------------------------------------
// Evnet
//-----------------------------------------------------------------------------------------------------------
function OnEvent( int a_EventID, String a_Param )
{	
	switch ( a_EventID ) 
	{
		case EV_AI_CONTENT_MONSTER_ARENA_SCORE  :
			insertParam ( a_Param ) ;		
		break;
	}
}

function insertParam( string a_Param ) 
{
	local int InstantZoneID, StageNum, CurStageScore, TotalStageScore;

	ParseInt ( a_Param, "InstantZoneID", InstantZoneID  );
	ParseInt ( a_Param, "StageNum", StageNum  );
	ParseInt ( a_Param, "CurStageScore", CurStageScore );
	ParseInt ( a_Param, "TotalStageScore", TotalStageScore );

	txtPlayMode.SetText(GetInZoneNameWithZoneID(InstantZoneID));

	txtStage.SetText( (GetSystemString ( 3483 ) @ StageNum) );   
	txtStageScore.SetText(MakeCostString (string(CurStageScore)));	
	txtTotalScore.SetText(MakeCostString (string(TotalStageScore)));
	
	Me.ShowWindow();
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( getCurrentWindowName(string(Self))).HideWindow();
}
defaultproperties
{
}
