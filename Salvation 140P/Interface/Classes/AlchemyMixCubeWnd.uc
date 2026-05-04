class AlchemyMixCubeWnd extends L2UIGFxScript;


CONST DIALOG_ALCHEMYMIXCUBEWND = 10000;

function OnRegisterEvent()
{
	registerGfxEvent(EV_AlchemySkillList);
	registerGfxEvent(EV_AlchemyMixCubeInfo);
	registerGfxEvent(EV_AlchemyPushItemOnMixCube);
	registerGfxEvent(EV_AlchemyAdditionPushItemOnMixCube);
	registerGfxEvent(EV_AlchemyTryMixCube);

	
	RegisterEvent(EV_DialogOK);          //1710
	RegisterEvent(EV_DialogCancel);      //1720
}


function onEvent( int a_EventID, String a_Param )
{

	switch ( a_EventID )
	{	
		case EV_DialogOK:
			HandleDialogOK();
		break;

		case EV_DialogCancel:
			HandleDialogCancel();
		break;	
	}
}


function onCallUCFunction( string functionName, string param )
{		
	local DialogBox dScript;

	//Debug("onCallUCFunction"@ functionName );
	switch (functionName)
	{
		case "openDialogNumpad" :
			openDialogNumpad(int64 (param) );
		break;
		case "cloasDialogNumPad":
				
			dScript = DialogBox(GetScript("DialogBox"));
			if( dScript.GetTarget() == string(Self) ) 
			{   
				dScript.HideDialog();
			}
			
		break;
	}
}

function openDialogNumpad(int64 adena)
{
	// Ask price
	class'UICommonAPI'.static.DialogSetID( DIALOG_ALCHEMYMIXCUBEWND );
	//DialogSetReservedItemID( info.ID );				// ServerID
	//DialogSetReservedInt3( int(bAllItem) );		// 전체이동이면 개수 묻는 단계를 생략한다
	class'UICommonAPI'.static.DialogSetEditType("number");
	class'UICommonAPI'.static.DialogSetParamInt64( adena );
	class'UICommonAPI'.static.DialogSetDefaultOK();
	class'UICommonAPI'.static.DialogShow(DialogModalType_Modalless, DialogType_NumberPad, getSystemMessage( 4262 ), string(Self) );	
}


/** Desc : 다이얼로그 윈도우를 열고 Cancel 버튼 누른 경우 */
function HandleDialogCancel() //
{

}

/** Desc : 다이얼로그 윈도우를 열고 OK 버튼 누른 경우 */
function HandleDialogOK()
{	
	//local ItemInfo scInfo;
	local INT64 inputNum;
	local int id;

	if(!class'UICommonAPI'.static.DialogIsOwnedBy( string(Self) ))	return;	

	id = class'UICommonAPI'.static.DialogGetID();
	
	if ( id == DIALOG_ALCHEMYMIXCUBEWND )
	{
		inputNum = INT64( class'UICommonAPI'.static.DialogGetString() );
		CallGFxFunction ( "AlchemyMixCubeWnd", "HandleDialogOK", String(inputNum));
	}	
} 

function OnLoad()
{
	
	registerState( "AlchemyMixCubeWnd", "GamingState" );
	SetContainerWindow( WINDOWTYPE_DECO_NORMAL, 3302);
	AddState("GAMINGSTATE");

	//SetAnchor("", EAnchorPointType.ANCHORPOINT_CenterCenter, EAnchorPointType.ANCHORPOINT_CenterCenter, 0 , 0);

	//함수 실행 시 onStateOut, onStateIn 함수를 invoke 로 받음 
	//SetStateChangeNotification();

	//선언하면 처음 부터 보여지고 시작 함
	//SetDefaultShow(true);

	//SetAnchor("", EAnchorPointType.ANCHORPOINT_BottomRight, EAnchorPointType.ANCHORPOINT_TopLeft, 0 , 0);		

	
	
}

function onShow ()
{
	// 지정한 윈도우를 제외한 닫기 기능 
	local L2Util util;
	util = L2Util(GetScript("L2Util"));
	util.ItemRelationWindowHide("AlchemyMixCubeWnd", "InventoryWnd");	
}
defaultproperties
{
}
