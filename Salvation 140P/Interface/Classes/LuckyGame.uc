class LuckyGame extends GFxUIScript;

function OnRegisterEvent()
{
	RegisterGFxEvent( EV_LuckyGameStart );    //9910
	RegisterGFxEvent( EV_LuckyGameResult );	//9920

	RegisterEvent( EV_DialogOK);          //1710
	RegisterEvent( EV_DialogCancel);      //1720

	RegisterGFxEvent( EV_VipLuckyGameInfo );      //10080
	RegisterGFxEvent( EV_VipLuckyGameItemList );  //10081
	RegisterGFxEvent( EV_VipLuckyGameResult );    //10082

	// 9050
	registerGfxEvent( EV_BR_SETGAMEPOINT );		
}

const DIALOG_LUCKYGAME = 200001;		// 아데나 요청
const DIALOG_RESULTFAIL = 200002;		// 결과 실패

function OnLoad()
{	
	registerState( "LuckyGame", "GamingState" );	
	// 어느 콘테이너에 넣을 건지 선언
	SetContainer( "ContainerWindow" );
	SetAnchor("", EAnchorPointType.ANCHORPOINT_CenterCenter, EAnchorPointType.ANCHORPOINT_CenterCenter, 0 , 0);	
	//setDefaultShow(true);

	SetHavingFocus( false );
} 

function onFlashLoaded()
{
	//러키 게임 관련 핸들러
	//RegisterDelegateHandler(EDelegateHandlerType.EDHandler_LuckyGameWnd);
}

function onShow()
{
	// 지정한 윈도우를 제외한 닫기 기능 
	local L2Util util;
	util = L2Util(GetScript("L2Util"));	
	util.ItemRelationWindowHide( "LuckyGame" );	
}

function onEvent( int a_EventID, String a_Param )
{

	switch ( a_EventID )
	{	
		case EV_DialogOK:
			HandleDialogOK();
		break;

		case EV_DialogCancel:
			//HandleDialogCancel();
		break;	
	}
}

function closeDialogNumpad()
{
	local DialogBox dScript;	
	
	dScript = DialogBox(GetScript("DialogBox"));
	if( dScript.GetTarget() == string(Self) ) 
	{   
		dScript.HideDialog();
	}
}

function onCallUCFunction( string functionName, string param )
{	
	//Debug("onCallUCFunction"@ functionName @ param );
	switch (functionName)
	{
		case "closeDialogNumpad":
			closeDialogNumpad();
		break;
		case "openDialogNumpad":
			openDialogNumpad(int64 (param) );
		break;	
		case "showDialogMessage":
			class'UICommonAPI'.static.DialogSetID( DIALOG_RESULTFAIL );
			class'UICommonAPI'.static.DialogShow( DialogModalType_Modalless,DialogType_OK, param, string(Self) );
		break;
	}
}

function openDialogNumpad(int64 adena)
{
	// Ask price
	class'UICommonAPI'.static.DialogSetID( DIALOG_LUCKYGAME );
	//DialogSetReservedItemID( info.ID );				// ServerID
	//DialogSetReservedInt3( int(bAllItem) );		// 전체이동이면 개수 묻는 단계를 생략한다
	class'UICommonAPI'.static.DialogSetEditType("number");
	class'UICommonAPI'.static.DialogSetParamInt64( adena );
	class'UICommonAPI'.static.DialogSetDefaultOK();
	class'UICommonAPI'.static.DialogShow(DialogModalType_Modalless, DialogType_NumberPad, getSystemString( 5174 ), string(Self) );	
}

/** Desc : 다이얼로그 윈도우를 열고 OK 버튼 누른 경우 */
function HandleDialogOK()
{	
	//local ItemInfo scInfo;
	local INT64 inputNum;
	local int id;
	local String strParam;

	if(!class'UICommonAPI'.static.DialogIsOwnedBy( string(Self) ))	return;	

	id = class'UICommonAPI'.static.DialogGetID();

	switch ( id ) {
	case  DIALOG_LUCKYGAME :
		inputNum = INT64( class'UICommonAPI'.static.DialogGetString() );
	
		ParamAdd( strParam, "Type", "DIALOG_LUCKYGAME");
		ParamAdd( strParam, "inputNum", string ( inputNum ) );
		CallGFxFunction ( "LuckyGame", "HandleDialogOK", strParam );
		//CallGFxFunction ( "LuckyGame", "HandleDialogOK", "type=DIALOG_LUCKYGAME" @ "inputNum="$String(inputNum));
	break;
	
	case DIALOG_RESULTFAIL :
		ParamAdd( strParam, "Type", "DIALOG_RESULTFAIL");
		CallGFxFunction ( "LuckyGame", "HandleDialogOK", strParam );
		//CallGFxFunction ( "LuckyGame", "HandleDialogOK", "type=DIALOG_RESULTFAIL");
		break;
	}
} 
defaultproperties
{
}
