class ContainerWindow extends L2UIGFxScript;

//var string registedState;

function OnLoad()
{
	SetClosingOnESC();
	//SetAnchor( "", EAnchorPointType.ANCHORPOINT_BottomRight, EAnchorPointType.ANCHORPOINT_TopLeft, 0, 0 );	
	//registedState = "GAMINGSTATE";

	registerState( "ContainerWindow", "GAMINGSTATE" );
	registerState( "ContainerWindow", "TRAININGROOMSTATE" );
	//SetDefaultShow(true);	
	//SetHavingFocus(false);
}

function OnRegisterEvent()
{
	//RegisterEvent( EV_StateChanged );	
	RegisterEvent( EV_NotifyBeforeStateChanged );	

	RegisterGfxEvent( EV_ResolutionChanged );		
	RegisterGfxEvent( EV_ReceiveWindowsInfo );
	RegisterGfxEvent( EV_DialogOK );
	RegisterGfxEvent( EV_DialogCancel );

	//L2UIData에 아데나, 인벤카운트 저장
	RegisterGFxEvent( EV_AdenaInvenCount );	

	//아데나 정보 저장 ( 불필요한 로드방지 컨테이너에서 아데나 정보를 들고 있음 ) 
	RegisterGfxEvent( EV_AdenaInvenCount );
	//RegisterEvent( EV_ReceiveChatFilter );
	//RegisterEvent( EV_ReceiveOption );	
}

function OnFlashLoaded()
{		
	local GFxValue l2SysStringTranslator;
	local GFxValue obj;

	//연금술 관련 델리게이트
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_AlchemyAPI);

	//10주년이벤트 델리게이트
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_Event10thAnniversary);

	//어빌리티 관련 델리게이트
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_AbilityWnd);
	//훈련소
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_TrainingRoomWnd);

	//러키 게임 관련 핸들러
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_LuckyGameWnd);


	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_EventCardWnd);

	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_Container);

	//숏컷 관련
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_ShortcutAPI);

	//옵션 관련 델리게이트
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_Option);

    // VIP 시스템 델리게이트
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_VipSystem);

	//입력 관련 델리게이트
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_InputAPI);

	//혈맹 가입 시스템
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_PledgeRecruit);
	
	//크리스마스 이벤트 관련 
	////RegisterDelegateHandler(EDelegateHandlerType.EDHandler_EventChristmasWnd);

	//아데나 분배 창
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_AdenaDistributionWnd);

	//올림피아드 결과 창 핸들
	RegisterDelegateHandler( EDHandler_OlympiadArenaList );

	//기본 적인 델리게이트? 옵션에서 사용 중이었음
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_Default);

	// 팩션 윈도우 델리게이트 추가	
	RegisterDelegateHandler ( EDelegateHandlerType.EDHandler_FactionWnd );

	//아레나 관련 델리게이트
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_Arena);

	//레이더 관련 델리게이트 ( faction 의 startNPC 위치 받기 위함. 
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_RadarMap);

	// 각정 데이타 를 받기 위함
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_GameData);

	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_PledgeWnd);

	// 미니맵 데이타를 받음
	//RegisterDelegateHandler(EDelegateHandlerType.EDHandler_Minimap);

	



	// 혈맹 이미지 받을 수 있도록 세팅
	//SetImageLoader(EFlashImageLoaderType.EImgLoader_Pledge);

	//채팅관련
	//RegisterDelegateHandler(EDHandler_ChatWnd);

	AllocGFxValue(l2SysStringTranslator);
	AllocGFxValue(obj);

	//GetVariable(obj,"_root.l2SysStringTranslator");
	
	//시스템 스트링 관련 
	GetFunction(l2SysStringTranslator, EExternalFunctionType.EFunc_SysStringTranslator);
	obj.SetMemberValue("getTranslatedString", l2SysStringTranslator);

	DeallocGFxValue(l2SysStringTranslator);
	DeallocGFxValue(obj);
}

function onCallUCFunction ( string functionName, string param ) 
{
	switch ( functionName ) 
	{
		/*
		 *서브창 제어를 위한 코드 
		case "setSubWindowPosition" :
			setSubWindowPosition ( param ) ;
		break;
		case "setFocusInSubWindow" :
			setFocusInSubWindow( param ) ;
		break;
		case "setFocusOutSubWindow" :
			setFocusOutSubWindow( param ) ;
		break;
		case "bringToFront":
			//BringToFront (getCurrentWindowName(string(Self))) ;
			Debug( "bringToFront" @ getCurrentWindowName(string(Self)) )  ;				
			class'UIAPI_WINDOW'.static.BringToFront (getCurrentWindowName(string(Self)));	
		*/
	}
}

/****************************************************************************************************************
 * 서브창 제어를 위한 코드 
 * **************************************************************************************************************
function setFocusInSubWindow ( string param )
{
	//local WindowHandle subWindow;
	//local string windowName;	
	//parseString ( param, "windowName", windowName );
	//subWindow = GetWindowHandle ( param );
	//subWindow.SetFocus();
	Debug(  "setFocusInSubWindow" @ param ) ;
	//class'UIAPI_WINDOW'.static.SetAlwaysOnTop( param, true );
	class'UIAPI_WINDOW'.static.BringToFront (param);
}

function setFocusOutSubWindow ( string param )
{
	//local WindowHandle subWindow;
	//local string windowName;	
	//parseString ( param, "windowName", windowName );
	//subWindow = GetWindowHandle ( param );
	//subWindow.SetFocus();
	Debug(  "setFocusOutSubWindow" @ param ) ;
	//class'UIAPI_WINDOW'.static.SetAlwaysOnTop( param, false );
}


function setSubWindowPosition ( string param )
{	
	local WindowHandle subWindow;
	local string windowName;
	local int offsetX, offsetY, x, y, width, height, targetX, targetY ;

	parseString ( param, "windowName", windowName );
	subWindow = GetWindowHandle ( windowName );

	if ( !subWindow.IsShowWindow() ) return;
	
	parseInt ( param , "offsetX", offsetX) ;
	parseInt ( param , "offsetY", offsetY) ;
	parseInt ( param , "width", width) ;
	parseInt ( param , "height", height) ;
	parseInt ( param , "x", x) ;
	parseInt ( param , "y", y) ;

	targetX = x + width + offsetX ;
	targetY = y + offsetY ;	
	subWindow.SetAnchor( "" , "TopLeft", "TopLeft", targetX, targetY );	
}*/

function OnEvent(int a_EventID, string a_Param) 
{	
	switch (a_EventID)
	{
	case EV_NotifyBeforeStateChanged://3411 EV_StateChanged:
		handleNotifyBeforeStateChanged ( a_Param ) ;
		//handleNotifyBeforeStateChanged( a_Param ) ;
		//invoke("onChangeState", args, invokeResult);

		/*
		if ( a_Param == registedState )
		{
			Invoke("onEnterState", args, invokeResult);			
		}
		else 
		{
			Invoke("onExitState", args, invokeResult);			
		}
*/
	break;
	/*
	case EV_ResolutionChanged:
		//Debug( "EV_ResolutionChanged" @  a_Param );
		ParseInt(a_Param, "NewWidth", _width);
		ParseInt(a_Param, "NewHeight", _height);
			
		args[1].SetMemberInt( "NewWidth" , _width );		
		args[1].SetMemberInt( "NewHeight" , _height );		
		invoke( "onResolutionChanged", args, invokeResult);
	break;
	case EV_ReceiveWindowsInfo:
		//Debug ( "---------EV_ReceiveWindowsInfo");
		invoke( "onReceiveWindowsInfo", args, invokeResult);
	break;
	case EV_ReceiveChatFilter:
//		Debug ( "---------EV_ReceiveChatFilter");
		invoke( "onReceiveChatFilter", args, invokeResult);
	break;
	case EV_ReceiveOption:
//		Debug ( "---------EV_ReceiveOption");
		invoke( "onReceiveOption", args, invokeResult);
	break;
*/
	}
}

function OnFocus(bool bFlag, bool bTransparency)
{	
	local array<GFxValue> args;
	local GFxValue invokeResult;

	AllocGFxValues(args,2) ;	
	args[0].setbool(bflag) ;
	args[1].setbool(bTransparency);
	AllocGFxValue(invokeResult);	
		
	Invoke("onFocusContainer", args, invokeResult);		
	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);	
}

function onHide () 
{
	invokeToFlash ("onHide");
}

function handleNotifyBeforeStateChanged( string param ) 
{
	local array<GFxValue> args;
	local GFxValue invokeResult;

	AllocGFxValues(args, 2);
	AllocGFxValue(invokeResult);

	args[0].SetInt( EV_NotifyBeforeStateChanged );
	CreateObject(args[1]);

//	Debug("argString"@argString);
	args[1].SetMemberString( "state" , param  );

	Invoke("onEvent", args, invokeResult);
	
	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 **
 ***/
function OnReceivedCloseUI()
{
	invokeToFlash ("onPressESC");
}

function OnDefaultPosition()
{
	invokeToFlash( "onDefaultPosition" );
}


function invokeToFlash ( string invokeID ) 
{
	local array<GFxValue> args;
	local GFxValue invokeResult;
	
	//if ( param != NU ) 
	AllocGFxValues(args, 1);
	//args[0].setMemberString ( "param", param) ;
	
	Invoke( invokeID, args, invokeResult);

	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);		
}
defaultproperties
{
}
