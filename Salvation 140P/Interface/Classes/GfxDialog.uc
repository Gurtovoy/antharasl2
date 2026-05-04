//------------------------------------------------------------------------------------------------------------------------
//
// 제목        : gfxDialog  ( 스케일 폼용 다이얼로그 (커스텀 등) ) - SCALEFORM UI - 
//
// linkage 다이얼로그 목록 :
// 4차 전직 - 각성 게시 다이얼로그 : AwakeNoticeDialog   
//------------------------------------------------------------------------------------------------------------------------
class GfxDialog extends L2UIGFxScript;

var UserInfo currentUserInfo;
var QuestTreeWnd QuestTreeWndScript;

var bool isDualMoviePlay;

//로드 완료 시 invoke로 파라메타를 받을 수 없어 getUCproperity 로 받게 처리 함.
var int _classID;
var string _linkageName;
var string _userName;


function OnRegisterEvent()
{	
	RegisterEvent( EV_Restart );
	//htmlDialog 를 처리 
	RegisterEvent( EV_LoginFailFlash );	
	//RegisterEvent( EV_StateChanged );	

}

function OnLoad()
{	
	registerState( getCurrentWindowName(String(self)), "GamingState" );	

	QuestTreeWndScript = QuestTreeWnd(GetScript("QuestTreeWnd"));

	SetAlwaysOnTop(true);
	
	SetClosingOnESC( );	

	//SetDefaultShow ( true ) ;
	
	//setHavingFocus( false );
}



function OnFlashLoaded()
{		
	SetAnchor("", EAnchorPointType.ANCHORPOINT_CenterCenter, EAnchorPointType.ANCHORPOINT_CenterCenter, 0, 0);
	//loadComplete = true;

	/*
	if ( tryAgain ) 
	{
		tryAgain = false;
		showGfxDialog( tmplinkageName ,tmptype ,tmpparam );
		tmplinkageName = ""; 
		tmptype = "" ;
		tmpparam = "";
	}*/
	//Debug( "OnFlashLoaded" );
	//한번 로드를 해야 한다.. 이벤트를 받기 위해	
}

function OnShow()
{	
	//if ( !loadComplete ) { HideWindow (); }
	//else 
	PlayConsoleSound(IFST_WINDOW_OPEN);
}

function OnHide()
{
	//if ( !loadComplete ) loadComplete = true;
	//else 
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	//handleHideEvent();
}

function OnCallUCLogic( int logicID, string param )
{
	local string dialogName;
	
	//Debug("OnCallUCLogic" @ logicID @ param);
	// 메인 다이얼로그 이름 "name=AwakeNoticeDialog"  를 기본 파라매터로 한다.
	// 메인 다이얼로그 이름 "name=Login"  를 기본 파라매터로 한다.
	ParseString(param, "Name",  dialogName);

	// 각성 다이얼로그를 ok 했다면..
	switch (dialogName)
	{
		case "AwakeNoticeDialog" :  AwakeNoticeDialogHandler(logicID, param);	break;		
		case "DualPayDialogStep1":  DualPayDialogStep1(logicID, param);     	break;
		case "DualPayDialogStep2":  DualPayDialogStep2(logicID, param);     	break;	
	}		

	// 이제 이런식으로 하면 안됨 -_-+
	//홈페이지 링크
	if( logicID == 3 )
	{
		OpenL2Home();
	}
}

/**
 * 듀얼 과금제 풀 스크린 무비 뷰
 **/
function DualPayDialogStep1( int logicID, string param )
{	
	isDualMoviePlay = true;	
	//Debug("풀 스크린 무비 뷰" @ isDualMoviePlay );
	RequestShowVisionmovie();
	//showGfxDialog( "dialogLinkageName", "DualPayDialogStep2" , param);
}

function onMovieEnd()
{	
	//Debug("onMovieEnd" @ isDualMoviePlay );
	if (  isDualMoviePlay )
	{
		isDualMoviePlay = false;
		showGfxDialog( "dialogLinkageName", "DualPayDialogStep2" , "");
	}
}

/**
 * 듀얼 홈페이지 가기 혹은 닫기 
 **/
function DualPayDialogStep2( int logicID, string param )
{
	local InventoryWnd Script;

	if ( logicID == 1 ) 
	{
		OpenGivenURL( GetSystemString( 3120 ) );
		//OpenL2Home();
	}
	
	Script = InventoryWnd(GetScript("InventoryWnd"));
	Script.SaveInventoryOrder();
	ExecQuit();
}

/**
 * 각성하는 곳으로 이동 시켜주는 다이얼로그 
 **/
function AwakeNoticeDialogHandler ( int logicID, string param )
{
	local string  strParam;
	local int     classID;

	GetPlayerInfo(currentUserInfo);
	// 각성 관련 퀘스트 ID , 10338 담당자 : 레벨팀 이보은 요청
	// 가 존재 한다면.. 아무것도 안한다.
	// Class=139 부터..8개.4차 전직 , 각성 상태라면..
	if (QuestTreeWndScript.isQuestIDSearch(10338) || (currentUserInfo.nClassID <= 147 && currentUserInfo.nClassID >= 139) )
	{
		// empty
		// Debug("각성 알람 반복 취소! " @ param);	
	}
	else
	{
		 if ( logicID == 1 )
		{
			//Debug("RequestCallToChangeClass 호출! 텔 타자! " @ param);			
			RequestCallToChangeClass( );

		}
		else if (logicID == 2)
		{
			ParseInt(param, "Class", classID);
			ParamAdd(strParam, "Class", String(classID) );
			ParamAdd(strParam, "Immediate", String(0) );
			ParamAdd(strParam, "UserType", String(1));

			ExecuteEvent( EV_CallToChangeClass, strParam ); 
			//Debug("각성 알람 반복" @ param);	
		}
	}
}

// const EV_CallToChangeClass = 5470;
/** OnEvent */
function OnEvent(int Event_ID, string param)
{		
	//Debug("onEvent"@ Event_ID @ param);
	if( Event_ID == EV_LoginFailFlash )
	{		
		//ParseString( param, "ErrorMsg", ErrorMsg );
		//SendErrorMsg(ErrorMsg);
		showGfxDialog( "linkage", "LogInDialog", param );
	}
	else if (Event_ID == EV_Restart)
	{
		HideWindow();
	}	
	/*
	else if (Event_ID == EV_StateChanged )
	{
		if ( param == "LOGINSTATE" ) 
		{
			//if ( !loadComplete )  ShowWindow();
			Debug( "EV_StateChanged" @  param );
			
			//showGfxDialog( "loadOnly", "bb", "cc" );
		}
		
		//showGfxDialog( "aa", "bb", "cc" );
	}
*/
}

/*
function handleHideEvent ()
{
	local int eventID;
	local   array<GFxValue> args;
	local   GFxValue invokeResult;	

	eventID = 0;
	AllocGFxValues(args, 2);
	AllocGFxValue(invokeResult);
	CreateObject(args[1]);

	args[0].SetInt( eventID );
	Invoke("onEvent", args, invokeResult);
		
	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);
}
*/

/** showGfxDialog */
function showGfxDialog(string linkageName, string type, string param  )
{
	local int classID;
	//LogIn 다이얼로그 에러 메시지.
	local string ErrorMsg;

	local int eventID;

	local   array<GFxValue> args;
	local   GFxValue invokeResult;	

	_linkageName = type;
	
	//Debug ( "showGfxDialog" @ linkageName @ type );
	
	if (type != "AwakeNoticeDialog" && type != "LogInDialog" ) 
	{	
		//ShowWindow 전에 SetModal 이 되야 함.
		SetModal( true );
	}
	else 
	{		
		SetModal( false );
	}

	if( type == "LogInDialog" )
	{		
		//모달 셋팅.
		//SetModal( true );

		//eventID = 2;		
		ParseString(param, "ErrorMsg", ErrorMsg);
		//Debug("LogInDialog" @  ErrorMsg );
		//args[1].SetMemberString( linkageName, type );
		//args[1].SetMemberString( "ErrorMsg", ErrorMsg );		
		class'UICommonAPI'.static.DialogSetID( 0 );

		//해외 러시에에서 제일 긴 문장은 스크롤이 발생 됨.
		class'UICommonAPI'.static.DialogShow(DialogModalType_Modal,DialogType_OK, ErrorMsg, string(Self), 450, 244, true, "");
		return;
	}	
	else
	{
		// LogInDialog 가 아닌 경우 GfxDialog 호출
		AllocGFxValues(args, 2);
		AllocGFxValue(invokeResult);
		CreateObject(args[1]);

		if ( type == "DualPayDialogStep1")
		{			
			GetPlayerInfo(currentUserInfo);

			ParseInt(param, "Class", classID);

			_classID = classID;
			_userName = currentUserInfo.name;

			eventID = 1 ;				
			
			args[1].SetMemberString("userName", currentUserInfo.name);
			args[1].SetMemberString(linkageName, type);
			args[1].SetMemberInt("classID", classID);

			ShowWindow();
		}
		else if ( type == "DualPayDialogStep2")
		{	
			
			GetPlayerInfo(currentUserInfo);
			
			//SetModal(true);

			eventID = 1 ;
			
	//		args[1].SetMemberString("userName", currentUserInfo.name);
			args[1].SetMemberString(linkageName, type);
	//		args[1].SetMemberInt("class", classID);

			ShowWindow();
		}
		else if (type == "AwakeNoticeDialog")
		{	
			
			//SetModal( false );
			if (!  GetPlayerInfo(currentUserInfo) ) 
			{
				DeallocGFxValue(invokeResult);
				DeallocGFxValues(args);

				return ;
			}
			
			if (QuestTreeWndScript.isQuestIDSearch(10338) || (currentUserInfo.nClassID <= 147 && currentUserInfo.nClassID >= 139) )
			{
				
				HideWindow();
				DeallocGFxValue(invokeResult);
				DeallocGFxValues(args);

				return;
			}
			else
			{			
				ParseInt(param, "Class", classID);

				_classID = classID;
				
				eventID = 1;
				
				args[1].SetMemberString( linkageName , type);
				args[1].SetMemberInt("classID", classID);	

				//Debug( "showGfxDialog" @ type @linkageName @ classID );

				ShowWindow();
			}
		}

		// LogInDialog 는 XML 다이얼로
		args[0].SetInt( eventID );
		Invoke("onEvent", args, invokeResult);
			
		DeallocGFxValue(invokeResult);
		DeallocGFxValues(args);
	}
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	local array<GFxValue> args;

	local GFxValue invokeResult;

	AllocGFxValues(args, 1);
	AllocGFxValue(invokeResult);
	
	Invoke("onReceivedCloseUI", args, invokeResult);

	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);	
}
defaultproperties
{
}
