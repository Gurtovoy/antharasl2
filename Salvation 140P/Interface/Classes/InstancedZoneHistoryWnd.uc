//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : InstancedZoneHistoryWnd  - SCALEFORM UI
//
//------------------------------------------------------------------------------------------------------------------------
class InstancedZoneHistoryWnd extends L2UIGFxScript;

function OnRegisterEvent()
{
	registerEvent(EV_InzoneWaitingInfo);	
	//Debug("ArchiveHotLinkWnd  OnRegisterEvent =============> ");	
}

function OnLoad()
{		
    SetContainerWindow(WINDOWTYPE_DECO_NORMAL, 2668);
	AddState("GAMINGSTATE");
}

function onCallUCFunction( string logicID, string param )
{
	switch (logicID)
	{
		case "RequestInzoneWaitingTime" :
			 //Debug("OnCallUCLogic"@logicID);
			 RequestInzoneWaitingTime();
			 break;
	}
}

function onEvent ( int a_EventID, string  a_Param ) 
{
	local int nShowWindow;

	switch ( a_EventID ) 
	{
		case  EV_InzoneWaitingInfo :
			  parseInt (a_Param, "ShowWindow" , nShowWindow );
			  if(nShowWindow > 0)
			  {
 				 a_Param = handleInzoneWaitingInfo( a_Param ) ;
				 CallGFxFunction( getCurrentWindowName( string(  self ) ), "WaitingInfo",  a_Param ) ;
			  }
			  break;
	}		
}

function string handleInzoneWaitingInfo(string param)
{
	local int currentInzoneID;
	local int sizeOfBlockedInzone ;
	local int blockedInzoneID ;
	local int blockedInzoneLeftSeconds ;
	local string currentInzoneName;
	local string blockedInzoneName;
	local string LeftTime;

	local int i;

	local string strParam ;

	
	parseInt (param, "currentInzoneID" , currentInzoneID );
	currentInzoneName = GetInZoneNameWithZoneID(currentInzoneID);
	if (currentInzoneName == "Invalid inzone ID") currentInzoneName =  "";

	ParamAdd( strParam, "currentInzoneName", currentInzoneName ) ;
	
	parseInt (param, "sizeOfBlockedInzone" , sizeOfBlockedInzone );	
	ParamAdd( strParam, "sizeOfBlockedInzone", String ( sizeOfBlockedInzone ) ) ;
	
	//Debug("sizeOfBlockedInzone=== " @ sizeOfBlockedInzone);

	for (i = 0 ; i <  sizeOfBlockedInzone ; i++ ) 
	{
		parseInt (param, "blockedInzoneID_"$i, blockedInzoneID );		
		parseInt (param, "blockedInzoneLeftSeconds_"$i , blockedInzoneLeftSeconds );		
		blockedInzoneName = GetInZoneNameWithZoneID(blockedInzoneID);
		LeftTime = setTimeString ( blockedInzoneLeftSeconds );

		ParamAdd( strParam, "blockedInzoneName_"$i, blockedInzoneName );
		ParamAdd( strParam, "blockedInzoneTimeString_"$i, LeftTime );
		ParamAdd( strParam, "blockedInzoneTime_"$i, String( blockedInzoneLeftSeconds ) );
	}	

	return strParam;
}

function string setTimeString(int tmpTime)
{
	//규칙 1시간 이상은 시간만
	//1시간 이하는 분만
	//1분 이하는 1분 이하
	local string timeStr;
	local int timeHour;
	local int timeMin;
	//local int stringNum
	//Debug("타임을 세팅합니다.");
	//Debug("tmpTime=== " @ tmpTime);
	if ( tmpTime < 60 ) //분 미만으로
	{ 			
		timeStr = MakeFullSystemMsg( GetSystemMessage(3390), string(1)); //1 분
		timeStr = MakeFullSystemMsg( GetSystemMessage(3408), timeStr);   //미만
	} 
	else if ( tmpTime < 3600 ) {//몇 분으로	
		tmpTime = tmpTime/60;
		timeStr = MakeFullSystemMsg( GetSystemMessage(3390), string(tmpTime));			
	} 
	else {//시간
		//tmpTime = tmpTime/3600;
		//timeStr = MakeFullSystemMsg( GetSystemMessage(3406), string(tmpTime));	
		//timeHour = 	tmpTime/3600;	
			

		timeHour = tmpTime/3600;
		timeMin	= (tmpTime - timeHour*3600)/60;
		//Debug("timeHour=== " @ timeHour);
		//Debug("timeMin=== " @ timeMin);
		if(timeMin > 0){
			timeStr = MakeFullSystemMsg( GetSystemMessage(3406), string(timeHour)) @ MakeFullSystemMsg( GetSystemMessage(3390), string(timeMin));
		}else {
			timeStr = MakeFullSystemMsg( GetSystemMessage(3406), string(timeHour));
		}
		
	}
	//Debug("timeStr=== " @ timeStr);
	return timeStr;
}

		

/*
function OnShow()
{
	dispatchEventToFlash_String(0,"");
	PlayConsoleSound(IFST_MAPWND_OPEN);
}

function OnHide()
{
	PlayConsoleSound(IFST_MAPWND_CLOSE);
	//dispatchEventToFlash_String(11 ,"" ) ;
}

function dispatchEventToFlash_String(int Event_ID, string argString)
{
	local array<GFxValue> args;
	local GFxValue invokeResult;

	AllocGFxValues(args, 2);
	AllocGFxValue(invokeResult);
	args[0].SetInt(Event_ID);
	CreateObject(args[1]);

	args[1].SetMemberString("string", argString );

	Invoke("_root.onEvent", args, invokeResult);
	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);
}

function dispatchEventToFlash(int Event_ID, GFxValue argArray){

	local array<GFxValue> args;
	local GFxValue invokeResult;

	AllocGFxValues(args, 2);
	AllocGFxValue(invokeResult);
	args[0].SetInt(Event_ID);
	CreateObject(args[1]);

	args[1].SetMemberValue("param", argArray );

	Invoke("_root.onEvent", args, invokeResult);
	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);	
}


function OnFlashLoaded()
{	
	local array<GFxValue> args;
	local GFxValue invokeResult;

	local float xLoc;
	local float yLoc;	

	//창의 기본 위치 지정 및 세이브 된 창위치로 이동.
	if( IsSavedInfo() )
	{
		SetGFxFromSavedInfo();
	}
	else
	{		
		// 플래시 타입 데이타 인스턴스 생성		
		AllocGFxValues(args, 2);		
		AllocGFxValue(invokeResult);

		GetAnchorPointFromWindow( xLoc, yLoc, EAnchorPointType.ANCHORPOINT_CenterCenter );

		args[0].SetInt( int(xLoc) + FLASH_XPOS );
		args[1].SetInt( int(yLoc) + FLASH_YPOS );

		Invoke( "_root.onMove", args, invokeResult );

		DeallocGFxValue( invokeResult );
		DeallocGFxValues( args );
	}
}

function OnFocus(bool bFlag, bool bTransparency)
{
	local array<GFxValue> args;
	local GFxValue invokeResult;

	AllocGFxValues(args,2);	
	args[0].setbool(bflag);
	args[1].setbool(bTransparency);
	AllocGFxValue(invokeResult);
		
	Invoke("_root.onFocus", args, invokeResult);

	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);	
}

function OnDefaultPosition()
{	
//	Debug("ArchiveHotLinkWnd.uc.onDefaultPosition()");
}

/*

function OnEvent(int Event_ID, string param)
{	
	//여기 이벤트가 와야하는데 안오고있음...
	if( Event_ID == EV_InzoneWaitingInfo)   //5860
	{
		if( IsShowWindow() == false )
		{
			ShowWindow();
		}

		//Debug("EV_InzoneWaitingInfo");
		handleInzoneWaitingInfo(param);		
	}
}

function handleInzoneWaitingInfo(string param)
{
	local int currentInzoneID;
	local int sizeOfBlockedInzone ;
	local int blockedInzoneID ;
	local int blockedInzoneLeftSeconds ;
	local string currentInzoneName;
	local string blockedInzoneName;
	local string LeftTime;

	local int i;

	local GFXValue argArray;
	local GFXValue blockedInzone;
	local GFxValue ArrayElem;

	AllocGFxValue(argArray);
	AllocGFxValue(blockedInzone);
	AllocGFxValue(ArrayElem);

	createObject(argArray);	
	CreateArray(blockedInzone);

	parseInt (param, "currentInzoneID" , currentInzoneID );
	//if ( currentInzoneID != null)
	//Debug("currentInzoneID " @ currentInzoneID);
	//Debug("param " @ param);

	currentInzoneName = GetInZoneNameWithZoneID(currentInzoneID);
	if (currentInzoneName == "Invalid inzone ID") 	
		currentInzoneName =  "";
	argArray.SetMemberString("currentInzoneName",currentInzoneName);

	parseInt (param, "sizeOfBlockedInzone" , sizeOfBlockedInzone );
	
	//Debug("sizeOfBlockedInzone=== " @ sizeOfBlockedInzone);

	for (i = 0 ; i <  sizeOfBlockedInzone ; i++ ) 
	{
		CreateObject(ArrayElem);

		parseInt (param, "blockedInzoneID_"$i, blockedInzoneID );		
		parseInt (param, "blockedInzoneLeftSeconds_"$i , blockedInzoneLeftSeconds );		
		blockedInzoneName = GetInZoneNameWithZoneID(blockedInzoneID);
		LeftTime = setTimeString ( blockedInzoneLeftSeconds ) ;
		ArrayElem.SetMemberString("name", blockedInzoneName);
		ArrayElem.SetMemberString("timeString", LeftTime);
		ArrayElem.SetMemberInt("time", blockedInzoneLeftSeconds);

		blockedInzone.SetElement(i, ArrayElem);
	}	
	argArray.SetMemberValue("blockedInzone", blockedInzone);
	
	dispatchEventToFlash(5, argArray);	//변수 세팅후 플래시로 보낸다...
	DeallocGFxValue(ArrayElem);
	DeallocGFxValue(blockedInzone);
	DeallocGFxValue(argArray);
}



*/

/**
 * 숫자를 넣으서 true, false 를 리턴 하게 한다.
 **/
function bool bflag(int nflag)
{
	if (nflag > 0) return true;
	else return false;
}
*/
defaultproperties
{
}
