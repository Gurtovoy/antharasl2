class ConsoleWnd extends UICommonAPI;

const DLG_ID_RESTART=0;
const DLG_ID_QUIT=1;
CONST DIG_ID_ASK_COUPLEACTION = 1112;

var WindowHandle m_hSystemMenuWnd;
var DialogBox	dScript;

/** OnRegisterEvent */
function OnRegisterEvent()
{
	//RegisterEvent( EV_OpenDialogQuit );
	//RegisterEvent( EV_OpenDialogRestart );
	RegisterEvent( EV_DialogOK );
	RegisterEvent( EV_DialogCancel );


	RegisterEvent ( EV_ShowAskCoupleActionDialog );
	RegisterEvent ( EV_CommandAddAllianceCrestFile );

	// 동맹문장등록 을 실행 하면 해당 이벤트 발생 
	

	// couple action - lancelot 2009. 10. 14.
	// const EV_ShowAskCoupleActionDialog			= 4900;
	// const EV_CoupleActionFailedTargetIsNone		= 4910;
	// const EV_CoupleActionFailedIlligalTarget		= 4920;
}

/** On Load */
function OnLoad()
{
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	//if(CREATE_ON_DEMAND==0)
	//	m_hSystemMenuWnd=GetHandle("SystemMenuWnd");
	//else
	//	m_hSystemMenuWnd=GetWindowHandle("SystemMenuWnd");

	dScript = DialogBox(GetScript("DialogBox"));
}

/** On Event */
function OnEvent(int Event_ID, String param)
{
	switch(Event_ID)
	{
		//case EV_OpenDialogRestart :
		//	dScript.HideDialog();
		//	dScript.SetID( DLG_ID_RESTART );
		//	dScript.ShowDialog(DialogModalType_Modal, DialogType_Warning, GetSystemMessage(126), string(Self) );			
		//	//DialogHide();	// 이미 창이 떠있다면 지워준다.
		//	//DialogShow(DialogModalType_Modal, DialogType_Warning, GetSystemMessage(126), string(Self));
		//	//DialogSetID( DLG_ID_RESTART );
		//	break;
		
		//case EV_OpenDialogQuit :
		//	dScript.HideDialog();
		//	dScript.SetID(DLG_ID_QUIT);
		//	dScript.ShowDialog(DialogModalType_Modal,DialogType_Warning, GetSystemMessage(125), string(Self));			
		//	//DialogHide();	// 이미 창이 떠있다면 지워준다.
		//	//DialogShow(DialogModalType_Modal,DialogType_Warning, GetSystemMessage(125), string(Self));
		//	//DialogSetID(DLG_ID_QUIT);
		//	break;
		
		case EV_DialogOK :
			HandleDlgOk();
			break;
		
		// 2009.10.17 , 커플 액션 추가 
		case EV_ShowAskCoupleActionDialog :
			// debug("====> 발동 : 커플 액션 " @ param);
			HandleCoupleActionAskStart(param);
			break;

		case EV_CommandAddAllianceCrestFile :
			HandleUploadAllianceCrestFile();
			break;


		case EV_DialogCancel :
			HandleDialogCancel();
			break;
	}
}

/** 다이얼로그 OK  */
function HandleDlgOk()
{
	//local InventoryWnd Script;
	//Script = InventoryWnd(GetScript("InventoryWnd"));
	if (!DialogIsMine())
		return;

	switch(DialogGetID())
	{

		//case DLG_ID_RESTART :
		//	//리스타트시 지워줘야할 윈도우들. 
		//	m_hSystemMenuWnd.HideWindow();
		//	Script.SaveInventoryOrder();
		//	ExecRestart();
		//	break;

		//case DLG_ID_QUIT :
		//	Script.SaveInventoryOrder();
		//	ExecQuit();
		//	break;
		
			
		case DIG_ID_ASK_COUPLEACTION:
			// 커플 액션을 수락 했다면!
			// debug("=======================커플액션========================================");
			// debug("==> DialogGetReservedInt() " @ DialogGetReservedInt());
			// debug("==> DialogGetReservedInt3() " @ DialogGetReservedInt3());		
			// debug("==> Answer " @ 1);		

			// 확인, 취소 로 복구 
			dScript.SetButtonName( 1337, 1342 );
			AnswerCoupleAction(DialogGetReservedInt(), 1, DialogGetReservedInt3());
			break;
	}
}

/** 커플 액션을 수락 여부를 물어 본다 */
function HandleCoupleActionAskStart( string param )
{
	local bool bOption;
	
	local int pActionID;
	local int pRequestUserID;

	local string userName;
	local string actionStr;

	bOption = GetOptionBool( "Communication", "IsCoupleAction" );
	
	//ParseInt( param, "SocialAnimID", pSocialAnimID );
	//ParseInt( param, "requestUserID", pRequestUserID );

	ParseInt( param, "ActionID", pActionID );
	ParseInt( param, "requestUserID", pRequestUserID );

	// Debug("=====> " @ bOption);

	if (bOption == true)
	{
		// 현재 커플 액션 설정이 거부된 상태입니다. 
		// RequestDuelAnswerStart( type, int(bOption), 0 );
		// AddSystemMessage(3122);
		// debug("=====> 현재 커플액션 옵션이 거부 상태 ");

		// 커플 액션이 거부 상태이므로 자동으로 거부 된다.
		//AnswerCoupleAction(DialogGetReservedInt(), -1, DialogGetReservedInt3());
		AnswerCoupleAction(pActionID, -1, pRequestUserID);
	}
	else	
	{
		// 다이얼로그 창이 열려 있으면 커플 액션 작동 안함.
		if ( IsShowWindow("DialogBox"))
		{
			//AnswerCoupleAction(DialogGetReservedInt(), 0, DialogGetReservedInt3());
			AnswerCoupleAction(pActionID, 0, pRequestUserID);
			return;
		}

		// 유저 이름을 얻는다
		userName = class'UIDATA_USER'.static.GetUserName(pRequestUserID);

		DialogSetID( DIG_ID_ASK_COUPLEACTION );
		DialogSetCancelD(DIG_ID_ASK_COUPLEACTION);

		DialogSetReservedInt( pActionID );
		DialogSetReservedInt3( pRequestUserID );

		DialogSetParamInt64( 10*1000 );			
		
		// 다이얼 로그 박스에서 예, 아니오 가 나오도록 한다.
		dScript.SetButtonName( 184, 185 );
		class'ActionAPI'.static.GetActionNameBySocialIndex(pActionID, actionStr);

		// $c1 님의 %s1 요청을 수락하시겠습니까?  -모달->모달리스로 바꿈-
		DialogShow(DialogModalType_Modalless, DialogType_Progress, MakeFullSystemMsg( GetSystemMessage(3118), userName, actionStr), string(Self) );
	}
}

/** 커플 액션을 거부 했다면!  */
function HandleDialogCancel()
{
	local bool bOption;

	// 확인, 취소 로 복구 
	dScript.SetButtonName( 1337, 1342 );

	if(DialogIsMine())
	{
		if(DialogCheckCancelByID(DIG_ID_ASK_COUPLEACTION))
		{
			bOption = GetOptionBool( "Communication", "IsCoupleAction" );

			 debug("=====================커플액션========================================");
			 debug("==> DialogGetReservedInt() " @ DialogGetReservedInt());
			 debug("==> DialogGetReservedInt3() " @ DialogGetReservedInt3());
			 debug("==> Answer " @ 0);
			
			AnswerCoupleAction(DialogGetReservedInt(), 0, DialogGetReservedInt3());
		}
	}
}


/** 동맹문장등록 , 파일 선택 창이 뜨고 선택하여 업로드 하는 부분  */
function HandleUploadAllianceCrestFile()
{
	local Array<string> fileextarr;

	if (class'UIAPI_WINDOW'.static.IsShowWindow("FileRegisterWnd") == false)
	{

		// 동맹문장은 8 * 12 크기의 256 칼러 Bmp 파일만 등록할 수 있습니다.
		AddSystemMessage(3143);

		// 파일 업로드 
		fileextarr.Length = 1;
		fileextarr[0] = "bmp";
		ClearFileRegisterWndFileExt();

		// 2233 : 비트맵 이미지
		AddFileRegisterWndFileExt(GetSystemString(2233), fileextarr);

		// 동맹 문장등록 파일 선택 윈도우 열기
		FileRegisterWndShow(FH_ALLIANCE_CREST_UPLOAD);
	}
}
defaultproperties
{
}
