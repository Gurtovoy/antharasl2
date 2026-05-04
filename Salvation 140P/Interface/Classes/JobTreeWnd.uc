//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : 전직계보도 - SCALEFORM UI
//
//------------------------------------------------------------------------------------------------------------------------
class JobTreeWnd extends L2UIGFxScript;

var int InitClassID;
var int CurrentSubjobClassID;
var int targetCurrentSubjobClassID;

function OnRegisterEvent()
{	
	// 5310
	//registerGfxEvent( EV_NotifySubjob );	
	//registerGfxEvent(EV_CreatedSubjob);
	//registerGfxEvent(EV_ChangedSubjob);
	registerEvent( EV_TargetUpdate );
}

function onEvent ( int a_EventID, String a_Param ) 
{
	switch ( a_EventID ) 
	{
	case EV_TargetUpdate :
		onTargetUpdate();
	}
}

function OnLoad()
{		
	AddState( "GAMINGSTATE" );
	SetContainerWindow(WINDOWTYPE_DECO_NORMAL, 2704);
}

function getInitClassID ( int currentClassID )
{
	local array<int> EnableClassIndexList;	
	class'UIDataManager'.static.GetEnableClassIndexList(currentClassID, EnableClassIndexList);
	InitClassID = EnableClassIndexList[0];
}

function getTargetCurrentSubjobClassID () 
{
	local UserInfo	info;
	
	if ( ! GetTargetInfo(info) ) return;		
	
	if(class'UIDATA_TARGET'.static.GetTargetID() >0 ) 
	{	
		//NPC일경우에는 tree를 disable 시킴. 
		if (info.bNpc )
			targetCurrentSubjobClassID = -1;			
		else 
			targetCurrentSubjobClassID = info.nSubClass;		
		
	}
}


function onTargetUpdate ( )
{	
	local string currentWndName;
	
	getTargetCurrentSubjobClassID();
	currentWndName = getCurrentWindowName(string (self));	
	if ( !IsShowWindow(currentWndName) ) return;	
	CallGFxFunction ( currentWndName, "changeTargetClassID", "" );
	
}

function getCurrentSubjobClassID () 
{
	local UserInfo userinfo ;
	if (! getPlayerInfo( userinfo ) ) return;

	CurrentSubjobClassID = userinfo.nSubClass;
}

function onCallUcFunction ( String funcName, String param ) 
{
	switch ( funcName )
	{
	case "getInitClassID":
		getInitClassID( int( param )) ;
	break;

	case "getCurrentSubjobClassID":
		getCurrentSubjobClassID();
	break;
	case "getTargetCurrentSubjobClassID":
		getTargetCurrentSubjobClassID();
	break;
	case "ucExecuteCommand" :
		ucExecuteCommand ( param ) ;
	break;
	}


}


function ucExecuteCommand(string param)
{
	Debug ( "ucExecuteCommand" @ param );
	if ( param == "" ) return;
	ExecuteCommand(param);
}

defaultproperties
{
}
