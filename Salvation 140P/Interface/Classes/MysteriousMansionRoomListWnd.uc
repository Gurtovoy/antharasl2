//------------------------------------------------------------------------------------------------------------------------
//
// 제목       : mysteriousMansionRoomListWnd   - SCALEFORM UI - 
//             : 이거는왜파일이소문자야?? to.동원
//
//------------------------------------------------------------------------------------------------------------------------
class mysteriousMansionRoomListWnd extends L2UIGFxScript;


function OnRegisterEvent()
{
        registerGfxEvent(EV_CuriousHouseObserveListStart);
        registerGfxEvent(EV_CuriousHouseObserveList);
        registerGfxEvent(EV_CuriousHouseObserveListEnd);
        //const EV_CuriousHouseObserveListStart      = 9390;
        //const EV_CuriousHouseObserveList           = 9391;
        //const EV_CuriousHouseObserveListEnd        = 9392;
}

function OnLoad()
{        
        //SetAnchor("", EAnchorPointType.ANCHORPOINT_CenterCenter, EAnchorPointType.ANCHORPOINT_CenterCenter, 0, 0);
		registerState( getCurrentWindowName(String(self)), "GAMINGSTATE" );
		registerState( getCurrentWindowName(String(self)), "CuriousHouseObserverState" );
        SetContainerWindow(WINDOWTYPE_DECO_NORMAL, 2809);
        AddState("GAMINGSTATE");
		AddState("CuriousHouseObserverState");
}

function onCallUCFunction( string functionName, string param )
{
        switch (functionName)
        {
               //방리스트
               case "RequestObservingCuriousHouse" :
                    RequestObservingCuriousHouse( int( param ) );
					//Debug("roomlist->refresh");
               break;
               case "refresh":
					RequestObservingListCuriousHouse();  					
				break;
        }
}

/*
//플래쉬옵셋좌표
const FLASH_XPOS = 0;
const FLASH_YPOS = 0;

//var int num ; 
function OnRegisterEvent()
{       
        registerEvent(EV_CuriousHouseObserveListStart);
        registerEvent(EV_CuriousHouseObserveList);
        registerEvent(EV_CuriousHouseObserveListEnd);
}

function OnLoad()
{
        SetClosingOnESC();     
        registerState( "mysteriousMansionRoomListWnd", "CuriousHouseObserverState" );
        registerState( "mysteriousMansionRoomListWnd", "GamingState" );
}

function OnShow()
{
        PlayConsoleSound(IFST_WINDOW_OPEN);
}

function OnHide()
{
        PlayConsoleSound(IFST_WINDOW_CLOSE);
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


function OnCallUCLogic( int logicID, string param )
{
        //Debug("RequestObservingCuriousHouse" @ param);
        switch (logicID)
        {              
        case 0 :
               RequestObservingListCuriousHouse();
               
               break;
        case 1 : 
               handleLogicID_1(param);
               
               break;
        }
}

function handleLogicID_1(string  param )
{
        local int ID;
        parseInt(param, "ID", ID);
        RequestObservingCuriousHouse( ID );
}


function OnFlashLoaded()
{
        local array<GFxValue> args;
        local GFxValue invokeResult;

        local float xLoc;
        local float yLoc;      

        if( IsSavedInfo() )
        {
               SetGFxFromSavedInfo();
        }
        else
        {       
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

function OnEvent(int Event_ID, string a_param)
{              
//      Debug ("Event_ID" @ Event_ID);
        switch ( Event_ID )
        {
               
        case EV_CuriousHouseObserveListStart :  //9390
               handleCuriousHouseObserveListStart( a_param );
        break;
        case EV_CuriousHouseObserveList :  //9391
               handleCuriousHouseObserveList( a_param );
        break;
        case EV_CuriousHouseObserveListEnd : //9392
               handleCuriousHouseObserveListEnd ( a_param );
        break;  

        }
}

function handleCuriousHouseObserveListStart(string a_param ) 
{
        setShowWindow();
        //num = 0;
        dispatchEventToFlash_Int(0, 0);
        
}

function handleCuriousHouseObserveList(string a_param ) 
{
        local int       ID;
        local string    HouseName;
        local int       State;
        local int       Count;
        local int       StateString;

        local GFXValue argArray;

//      Debug("handleCuriousHouseObserveList" @ a_param) ;
        

        ParseInt(a_param, "Count",  Count);
        if ( Count != 0 ) //참여인원이0이아니면
        {
               AllocGFxValue(argArray);
               createObject(argArray);       

               ParseInt(a_param, "ID",    ID);
               //ParseString(a_param, "HouseName",HouseName);
               HouseName = GetSystemString(2806) $ ( ID + 1 ) ;
               Parseint(a_param, "State",  State);
               
               Debug("HouseName" @ HouseName);

               if (State == 0 ) 
               {
                       StateString = 1718;
               }
               else 
               {
                       StateString = 1719;
               }
               
               argArray.SetMemberInt("ID", ID);      
               argArray.SetMemberString("HouseName",    HouseName);
               argArray.SetMemberString("StateString", GetSystemString( StateString));
               argArray.SetMemberInt("Count",          Count);

               dispatchEventToFlash(1, argArray);
               DeallocGFxValue(argArray);
        }

        //num++;
}

function handleCuriousHouseObserveListEnd(string a_param ) 
{
        dispatchEventToFlash_Int(2, 0);
}
*/
/**
* 윈도우ESC 키로닫기처리
* "Esc" Key
***/
/*
function OnReceivedCloseUI()
{
        local array<GFxValue> args;

        local GFxValue invokeResult;

        AllocGFxValues(args, 1);              
        
        Invoke("_root.onReceivedCloseUI", args, invokeResult);

        DeallocGFxValue(invokeResult);
        DeallocGFxValues(args);       
}

function setShowWindow()
{       
        if( IsShowWindow() == false )
        {
               ShowWindow();                         
        }
}

function setHideWindow()
{       
        if( IsShowWindow() == true )
        {
               HideWindow();                         
        }
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

function dispatchEventToFlash_String(int Event_ID, string argString){
        local array<GFxValue> args;
        local GFxValue invokeResult;

        AllocGFxValues(args, 2);
        AllocGFxValue(invokeResult);
        args[0].SetInt(Event_ID);
        CreateObject(args[1]);

//      Debug("argString"@argString);
        args[1].SetMemberString("string", argString );

        Invoke("_root.onEvent", args, invokeResult);
        DeallocGFxValue(invokeResult);
        DeallocGFxValues(args);
}

function dispatchEventToFlash_Int(int Event_ID, int argInt){
        local array<GFxValue> args;
        local GFxValue invokeResult;

        AllocGFxValues(args, 2);
        AllocGFxValue(invokeResult);
        args[0].SetInt(Event_ID);
        CreateObject(args[1]);

//      Debug("argString"@argString);
        args[1].SetMemberInt("int", argInt );

        Invoke("_root.onEvent", args, invokeResult);
        DeallocGFxValue(invokeResult);
        DeallocGFxValues(args);
}
*/
defaultproperties
{
}
