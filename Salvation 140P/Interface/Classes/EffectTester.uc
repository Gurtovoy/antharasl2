class EffectTester extends L2UIGFxScriptNoneContainer;

function OnRegisterEvent()
{	
	RegisterEvent(EV_Test_9);
	//RegisterGFxEvent(EV_Test_9);
	//RegisterGFxEvent(EV_Test_1);
	//RegisterEvent(EV_Test_1);
}

function OnLoad()
{	
	SetClosingOnESC();	
	//SetContainerWindow( WINDOWTYPE_DECO_NORMAL, 0);
	AddState("GAMINGSTATE");
	
	//선언하면 처음 부터 보여지고 시작 함
	//SetDefaultShow(true);
	//SetRenderOnTop(true);
	//SetAlwaysOnTop(true);
	//SetHavingFocus( false );
}

//function onFocus ( bool bFlag, bool bTransparency ) 
//{
//	if ( bFlag ) 
//	{
//		class'UIAPI_WINDOW'.static.BringToFront("EffectWnd") ;
//	}	
//}

function onEvent ( int id , string param  ) 
{
	ShowWindow( "EffectTester");	
	//CallUcFunction ( "EffectTester", "show", "");
}

function OnFlashLoaded () 
{	
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_Container);

	//옵션 관련 델리게이트
	//RegisterDelegateHandler(EDelegateHandlerType.EDHandler_Option);

	////기본 적인 델리게이트? 옵션에서 사용 중이었음
	//RegisterDelegateHandler(EDelegateHandlerType.EDHandler_Default);

}


////테스트용 함수
//function onCallUCFunction( string functionName, string param )
//{	
//	Debug("sampe's onCallUCFunction" @ functionName @ param);
//	switch ( functionName ) 
//	{
//		case "sunnomMonster" :
//			ouputCheck( param );
//		break;
//	}
//}
defaultproperties
{
}
