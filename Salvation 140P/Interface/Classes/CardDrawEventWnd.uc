class CardDrawEventWnd extends L2UIGFxScriptNoneContainer;

var String gameTryCount ;

var InventoryWnd inventoryWndScript;

function OnRegisterEvent()
{	
	RegisterGFxEvent(EV_CardUpdownGameStart);
	RegisterGFxEvent(EV_CardUpdownGamePickResult);
	RegisterGFxEvent(EV_CardUpdownGamePrepReward);
	RegisterGFxEvent(EV_CardUpdownGameRewardReply); //6000
	RegisterGFxEvent(EV_CardUpdownGameQuit ); //6000
	
	//RegisterGFxEvent(EV_Test_8); 	
	//RegisterGFxEvent(EV_Test_6); 
	//RegisterGFxEvent(EV_Test_5); 
	//RegisterGFxEvent(EV_Test_7); 
}

function onCallUCFunction ( string id, string param ) 
{		
	// 13주년 아이템 이벤트 받아 오기

	switch ( id ) 
	{
		case "getItemCount" :			 
			gameTryCount = String(inventoryWndScript.getItemCountByClassID ( int ( param ) )) ;
		break;
	}
}

function onShow()
{
	class'UIAPI_WINDOW'.static.HideWindow( "ItemUpgrade" ) ;
	super.onShow();
}


function OnLoad()
{	
	SetClosingOnESC();
	//registerState( "CardDrawEventWnd", "GamingState" );	
	AddState("GAMINGSTATE");	
	//setDefaultShow(true);
	inventoryWndScript = inventoryWnd(GetScript("inventoryWnd"));
	//SetAnchor("", EAnchorPointType.ANCHORPOINT_CenterCenter, EAnchorPointType.ANCHORPOINT_CenterCenter, 0 , 0);
}

function OnFlashLoaded()
{	
	//RegisterDelegateHandler(EDelegateHandlerType.EDHandler_Container);

	//카드 게임 델리게이트 
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_CardUpdownGame);

	//옵션 관련 델리게이트
	//RegisterDelegateHandler(EDelegateHandlerType.EDHandler_Option);

	//기본 적인 델리게이트? 옵션에서 사용 중이었음
	//RegisterDelegateHandler(EDelegateHandlerType.EDHandler_Default);

	// 각정 데이타 를 받기 위함
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_GameData);

	//SetAlwaysOnTop(true);
}



defaultproperties
{
}
