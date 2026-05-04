class ContainerHUD extends GFxUIScript;

var string registedState;

function OnLoad()
{	
	SetClosingOnESC();	
	//registedState = "GAMINGSTATE";

	//registerState( "ContainerHUD", registedState );

	SetDefaultShow(true);
	setHUD();
	//SetHavingFocus( true );
	setAlwaysOnBack(true);

//	SetGFxPassThrough(true);
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
}


function onCallUCFunction( string functionName, string param )
{
	switch(functionName)
	{
		//setFocus로 해도 view 가 container라서 포커스 잡을 ....
		case "focusContainer":
			SetFocus();
		break;
	}
}
function OnFlashLoaded()
{		
	local GFxValue l2SysStringTranslator;
	local GFxValue obj;

	//로그인 추가 이용약관 관련
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_LoginPIAgreementWnd);

	//SetHasTexfield 관련 델리게이트
	RegisterDelegateHandler(EDHandler_Container);

	//채팅관련
	RegisterDelegateHandler(EDHandler_ChatWnd);
	
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_Container);

	//숏컷 관련
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_ShortcutAPI);

	//옵션 관련 델리게이트
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_Option);

	//입력 관련 델리게이트
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_InputAPI);

	//어빌리티 관련 델리게이트
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_AbilityWnd);

	//레이더 관련 델리게이트
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_RadarMap);

	//에디셔널 스킬 . 스킬 사용 관련
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_UseSkill);

	//혈맹 가입 시스템
	//RegisterDelegateHandler(EDelegateHandlerType.EDHandler_PledgeRecruit);

	// 혈맹 이미지 받을 수 있도록 세팅
	//SetImageLoader(EFlashImageLoaderType.EImgLoader_Pledge);

	//낚시 관련 델리게이트
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_FishWnd);
	
	//아레나 관련 델리게이트
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_Arena);

	AllocGFxValue(l2SysStringTranslator);
	AllocGFxValue(obj);

	//GetVariable(obj,"_root.l2SysStringTranslator");
	
	GetFunction(l2SysStringTranslator, EExternalFunctionType.EFunc_SysStringTranslator);
	obj.SetMemberValue("getTranslatedString", l2SysStringTranslator);

	DeallocGFxValue(l2SysStringTranslator);
	DeallocGFxValue(obj);
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

function OnEvent(int a_EventID, string a_Param) 
{	
	switch (a_EventID)
	{
		case EV_NotifyBeforeStateChanged://3411 EV_StateChanged:
			handleNotifyBeforeStateChanged ( a_Param ) ;
		break;
		/*
			args[1].SetMemberString( "state" , a_Param );		
			invoke("onChangeState", args, invokeResult);
			
			if ( a_Param == registedState )
			{
				Invoke("onEnterState", args, invokeResult);
			}
			else 
			{
				Invoke("onExitState", args, invokeResult);			
			}
		break;
		case EV_ResolutionChanged:
			//Debug( "EV_ResolutionChanged" @  a_Param );
			ParseInt(a_Param, "NewWidth", _width);
			ParseInt(a_Param, "NewHeight", _height);
				
			args[1].SetMemberInt( "NewWidth" , _width );		
			args[1].SetMemberInt( "NewHeight" , _height );		
			invoke( "onResolutionChanged", args, invokeResult);
		case EV_ReceiveWindowsInfo :
			invoke( "onReceiveWindowsInfo", args, invokeResult);
		break;
	*/
	}	
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
 **/
function OnReceivedCloseUI()
{
	invokeToFlash("onPressESC");
}

function OnDefaultPosition()
{	
	invokeToFlash("onDefaultPosition");
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
