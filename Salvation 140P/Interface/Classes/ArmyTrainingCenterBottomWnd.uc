class ArmyTrainingCenterBottomWnd extends GFxUIScript;

const DIALOG_ASK_TRAINING_OUT = 66666;

function OnRegisterEvent()
{	
	RegisterEvent( EV_DialogOK );
	RegisterEvent( EV_DialogCancel );
	RegisterEvent( EV_StateChanged );
}

function OnLoad()
{	
	registerState( "ArmyTrainingCenterBottomWnd", "TRAININGROOMSTATE" );
	// 어느 콘테이너에 넣을 건지 선언
	SetContainer( "ContainerWindow" );
	setDefaultShow(true);
	SetAnchor("", EAnchorPointType.ANCHORPOINT_BottomRight, EAnchorPointType.ANCHORPOINT_TopLeft, 0, 0 );
}

function OnEvent(int Event_ID, string param)
{
	if(Event_ID == EV_DialogOK)
	{
		HandleDialogOK();
	}
	else if(Event_ID == EV_DialogCancel)
	{
		//HandleDialogCancel();
	}
	else if(Event_ID == EV_StateChanged)
	{
		if (param == "TRAININGROOMSTATE")
		{
			ShowWindow();
		}
		else
		{
			HideWindow();
		}
	}
}
/*
function HandleDialogCancel()
{
	local int id;
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	id = script.GetID();

	if( script.GetTarget() == string(Self) )
	{
		if (id == DIALOG_ASK_TRAINING_OUT)
		{
			script.HandleCancel();
		}
	}
}
*/
function HandleDialogOK()
{
	local int id;

	local DialogBox script;
	local ArmyTrainingCenterWnd armyScript;

	script = DialogBox(GetScript("DialogBox"));
	armyScript = ArmyTrainingCenterWnd(GetScript("ArmyTrainingCenterWnd"));
	id = script.GetID();

	if( script.GetTarget() == string(Self) )
	{
		if (id == DIALOG_ASK_TRAINING_OUT)
		{	
			//훈련 퇴소 신청
			callGFxFunction( "ArmyTrainingCenterBottomWnd", "TrainingRoomOut", "");
			//callGFxFunction( "ArmyTrainingCenterWnd", "TrainingRoomOut", "");
			armyScript.ClearTimer(10012);
			armyScript.ClearTimer(10013);
		}
	}
} 

function onCallUCFunction( string functionName, string param )
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	switch ( functionName ) 
	{
		case "ShowDialogTrainingOut" :
			
			//다이얼로그 열기 
			script.SetID( DIALOG_ASK_TRAINING_OUT );
			script.ShowDialog(DialogModalType_Modal, DialogType_OKCancel, GetSystemString(5155), string(self) );

			//DialogSetID( DIALOG_ASK_TRAINING_OUT);
			// ServerID
			//DialogSetReservedItemID( info.ID );						
			//훈련소 퇴소신청을 하시겠습니까? 스트링
			//DialogShow(DialogModalType_Modalless, DialogType_NumberPad, GetSystemMessage(4142), string(Self) );
		break;
		case "GameQuit":
			ExecuteEvent(EV_OpenDialogQuit);
		break;
		case "GameRestart":
			ExecuteEvent(EV_OpenDialogRestart);
		break;
	}
}
defaultproperties
{
}
