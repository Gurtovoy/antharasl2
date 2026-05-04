class ItemLockWnd extends UICommonAPI;

///////////////////////////////////////////////////////////////////////////////////////////
//	ItemLockWnd 1.0																//
///////////////////////////////////////////////////////////////////////////////////////////

// 기능
// 1. 봉인과, 해제 창을 변경
// 2. 상태에 따른 변경
//  봉인 <-> 취소 -> 계속
//  해제 <-> 취소 -> 계속

const       C_ANIMLOOPCOUNT = 1;

enum WindowType 
{
	LOCK,
	UNLOCK,
	ERROR
};

enum StateStep 
{
	START,
	READY,
	POPUP,
	PROGRESS,
	END
} ;

// 자신
var WindowHandle        Me ;
// 상부 설명
var TextBoxHandle       Instruction_Txt ;
// 아이템 이름
var TextBoxHandle       ItemName_Txt ;
// 봉인 주문서 텍스트
var TextBoxHandle       ItemLockPaperTitle_txt ;
// 해제 주문서 텍스트
var TextBoxHandle       ItemUnLockPaperTitle_txt ;
// 주문서 수량
var TextBoxHandle       ItemLockPaperinput_txt ;
// 봉인, 해제 아이템 
var ItemWindowHandle    ItemLock_ItemWindow ;
// 봉인, 해제 프로그래스 바
var ProgressCtrlHandle	itemLock_Progress ;
var ProgressCtrlHandle	itemUnLock_Progress ;
var ProgressCtrlHandle  currentProgress;

// 버튼
var ButtonHandle        ItemLockBtn ;
// 경고
var WindowHandle        ItemLockAlert_Wnd ;
var WindowHandle        DisableWnd ;
// 서브 창
var WindowHandle        SubWnd ;
var ItemLockSubWnd      ItemLockSubWndScript;

// 아이템 드랍 유도 이팩트 
var TextureHandle       DropHighlight_ItemLock_AniPanel;


// 상태 
var WindowType          currentWindowType ;

var StateStep           currentState ;
// 현재 스크롤 ID 
var int                 currentScrollItemClassID ;
// 현재 스크롤 수량
var int64               currentScrollNum;

var InventoryWnd inventoryWndScript ;
	

// 변수 초기화
function Initialize()
{	
	currentState = stateStep.START;
}


function OnLoad()
{
	SetClosingOnESC();
	
	Me = GetWindowHandle( "ItemLockWnd" );

	Instruction_Txt             = GetTextBoxHandle (  "ItemLockWnd.Instruction_Txt"  );
// 아이템 이름
	ItemName_Txt                = GetTextBoxHandle (  "ItemLockWnd.ItemName_Txt"  );
// 봉인 주문서 텍스트
	ItemLockPaperTitle_txt	    = GetTextBoxHandle (  "ItemLockWnd.ItemLockPaperTitle_txt"  );
// 해제 주문서 텍스트
	ItemUnLockPaperTitle_txt	= GetTextBoxHandle (  "ItemLockWnd.ItemUnLockPaperTitle_txt"  );
// 봉인, 해제 아이템 
	ItemLock_ItemWindow	        = GetItemWindowHandle (  "ItemLockWnd.ItemLock_ItemWindow"  );
// 봉인, 해제 프로그래스 바
	itemLock_Progress	        = GetProgressCtrlHandle("ItemLockWnd.itemLock_Progress");
	itemUnLock_Progress	        = GetProgressCtrlHandle("ItemLockWnd.itemUnLock_Progress");
// 버튼
	ItemLockBtn	                = GetButtonHandle (  "ItemLockWnd.ItemLockBtn"  );

	DisableWnd                  = GetWindowHandle( "ItemLockWnd.DisableWnd" );
	ItemLockAlert_Wnd           = GetWindowHandle( "ItemLockWnd.ItemLockAlert_Wnd" );

	ItemLockPaperinput_txt      = GetTextBoxHandle ( "ItemLockWnd.ItemLockPaperinput_txt"  );

	SubWnd                      = GetWindowHandle( "ItemLockSubWnd");

	ItemLockSubWndScript        = ItemLockSubWnd( GetScript ( "ItemLockSubWnd" ) );

	DropHighlight_ItemLock_AniPanel = GetTextureHandle ( "ItemLockWnd.DropHighlight_ItemLock_AniPanel");

	//itemLock_Progress.SetProgressTime(1500);	        
	//itemUnLock_Progress.SetProgressTime(1500);

	inventoryWndScript =InventoryWnd ( GetScript ("InventoryWnd") );

	if ( getInstanceUIData().getIsClassicServer() ) GetButtonHandle (  "ItemLockWnd.BtnWindowHelp"  ).HideWindow();	
}

function OnRegisterEvent()
{
	RegisterEvent ( EV_LockedItemShow  ) ;
	RegisterEvent ( EV_LockedResult  ) ;
}

function onShow()
{ 
	// 지정한 윈도우를 제외한 닫기 기능 	
	getInstanceL2Util().ItemRelationWindowHide(getCurrentWindowName(String(self)));
	Initialize();
	
	setWindowByType();
	handleState () ;

	SubWnd.ShowWindow();
}

function OnHide()
{		
	
//	Debug("onHide");
	// 해제 취소
	switch ( currentWindowType) 
	{
		case LOCK :
			RequestLockedItemCancel();
		break;
		case UNLOCK:
			RequestUnlockedItemCancel();
		break;
	}
}

function OnClickButton( string Name )
{
	//Debug( "OnClickButton"  @ Name);
	switch( Name )
	{
		case "ItemLockBtn":
			// 초기화
			switch ( currentState ) 
			{
				// 팝업을 보여 준다.
				case stateStep.READY :	
					if ( currentWindowType == LOCK ) 
						currentState = stateStep.POPUP;
					else 
						currentState = stateStep.PROGRESS;
				break;				
				case stateStep.PROGRESS :
					currentState = stateStep.READY;	
				break;
				case stateStep.END :
					scrollItemReuse () ;					
					//currentState = stateStep.START;
				break;			
			}	
		break;
		case "AlertWnd_Confirm_Btn" :
			currentState = stateStep.PROGRESS ;			
			break ;
		case "AlertWnd_Close_Btn" : 
			currentState = stateStep.READY;						
			break;
		case "BtnWindowHelp": 
			ExecuteEvent(EV_ShowHelp, "131");
			return;
			break;
	}

	handleState () ;	
}

function scrollItemReuse () 
{
	local iteminfo outinfo ;
	local itemID id;
	
	id.classID = currentScrollItemClassID;
	inventoryWndScript.getInventoryItemInfo( id, outinfo, true ) ;
	RequestUseItem(outinfo.ID);
}

function OnDropItem( String a_WindowID, ItemInfo a_ItemInfo, int X, int Y)
{	
	if ( a_ItemInfo.DragSrcName != "ItemLockSubWnd_Item1" ) return;		

	setItemInfo ( a_ItemInfo ) ;
	//if ( X > rectWnd.nX + 9 && X < rectWnd.nWidth + 9 && Y > rectWnd.nY + 39 && Y < rectWnd.nHeight + 39 )//반절 이전		
}


function OnEvent(int Event_ID, string param)
{
	//Debug("OnEvent" @ Event_ID @ param);
	switch ( Event_ID ) 
	{
		case EV_LockedItemShow :			
			setShow( param ) ;
		break;
		case EV_LockedResult :
			handleResult (param )  ;			
			handleState();
		break;
	}
}

function OnProgressTimeUp ( string strID ) 
{
	switch ( strID ) 
	{
		case "itemLock_Progress":
			RequestLockedItem ( getCurrentItemServerID () ) ;
			//Debug ( "RequestLockedItem" @ getCurrentItemServerID () ) ;
			ItemLockBtn.DisableWindow();
		break;
		case "itemUnLock_Progress":
			RequestUnLockedItem ( getCurrentItemServerID () ) ;
			//Debug ( "itemUnLock_Progress" @ getCurrentItemServerID () ) ;
			ItemLockBtn.DisableWindow();
		break;
		
	}
}

/************************************************************ 정보 ********************************************************************/

// 스크롤 수량
function setScrollNum ( int classID ) 
{	
	currentScrollNum = inventoryWndScript.getItemCountByClassID( classID ) ;

	if ( currentScrollNum == 0 ) 
		 ItemLockPaperinput_txt.SetTextColor( getInstanceL2Util().DRed ) ;
	else ItemLockPaperinput_txt.SetTextColor( getInstanceL2Util().White ) ;

	ItemLockPaperinput_txt.SetText( String(currentScrollNum) ) ;
}

// 아이템 정보
function setItemInfo ( itemInfo a_ItemInfo ) 
{
	if ( currentState != stateStep.START && currentState != stateStep.READY) return;

	ItemLock_ItemWindow.SetItem( 0, a_ItemInfo );
	ItemLock_ItemWindow.AddItem( a_ItemInfo );	

	// 아이템 이름 명시 

	ItemName_Txt.SetText ( GetItemNameAll (a_ItemInfo) ) ;	

	DropHighlight_ItemLock_AniPanel.HideWindow();

	currentState = READY;	
	handleState () ;
}

function setShow( string param ) 
{	
	local string LockType;

	parseString ( param, "LockType", LockType ) ;

	switch ( LockType ) 
	{
		case "Error" :
			currentWindowType = ERROR;
			Me.HideWindow();						
			break;
		case "UnLock" :
			currentWindowType = UNLOCK;
			if ( Me.IsShowWindow() ) onShow();
			Me.ShowWindow();
			break;
		case "Lock" :
			currentWindowType = LOCK;
			if ( Me.IsShowWindow() ) onShow();
			Me.ShowWindow();
			break;
	}

	parseInt ( param, "ScrollItemClassID", currentScrollItemClassID );
	setScrollNum ( currentScrollItemClassID ) ;
}

// 기본적으로 사용하는 공통된 아이템 이름을 리턴한다.
function string GetItemNameAll(ItemInfo info)
{
	local string ensoulOptionAllName, fullName, addStr;

	ensoulOptionAllName = GetEnsoulOptionNameAll(info);

	// 인챈트, 옵션, AdditionalName
	if(info.Enchanted > 0) fullName = "+"$ String(info.Enchanted);	

	if (Len(fullName) > 0)
	{
		fullName = fullName $ " " $ info.name;
	}
	else fullName = info.name;

	if (len(info.AdditionalName) > 0) addStr = addStr $ " " $ info.AdditionalName;
	if (len(ensoulOptionAllName) > 0) addStr = addStr $ " " $ ensoulOptionAllName;

	
	fullName = fullName $ addStr;
	
	return fullName;
}

/*********************************************** 아이템 삭제 **************************************************************/
function  handleClearItem( )
{			
	ItemLock_ItemWindow.Clear();
	// 아이템 이름 명시 	
	ItemName_Txt.SetText ( "" ) ;	
	DropHighlight_ItemLock_AniPanel.ShowWindow();
}

/*******************************************************************************************************************
* 윈도우 외형 처리
*******************************************************************************************************************/
/***************************************************** 윈도우 타입 ************************************************/
function setWindowByType ( ) 
{
	if( currentWindowType == LOCK ) 
	{		
		itemUnLock_Progress.HideWindow();
		Me.SetWindowTitle( GetSystemString ( 3770 ));
		ItemLockPaperTitle_txt.SetText ( GetSystemString ( 3772 ));	
		ItemLockPaperTitle_txt.SetTextColor( getColor(255, 153, 0, 255)) ;
		currentProgress = itemLock_Progress ;
	}	
	else 
	{
		itemLock_Progress.HideWindow();		
		Me.SetWindowTitle( GetSystemString ( 3771 ));
		ItemLockPaperTitle_txt.SetText ( GetSystemString ( 3773 ));
		ItemUnLockPaperTitle_txt.ShowWindow();
		ItemLockPaperTitle_txt.SetTextColor( getColor(136, 255, 255, 255) ) ;
		currentProgress = itemUnLock_Progress;
	}

	currentProgress.ShowWindow();
}

/***************************************************** 스테이트  ************************************************/
// 스테이트에 따른 윈도우 상태 처리

function handleState () 
{
	setWindowByState();
	setButtonByState () ;
	setWindowInstruction() ;
}

function setWindowByState () 
{
	switch ( currentState ) 
	{
		case START :
			hideAlert();			
			handleClearItem();
			ItemLockSubWndScript.syncInventory();
			ItemLockSubWndScript.setLock( false ) ;
		case READY:
			currentProgress.Reset();
			//currentProgress.SetPos(0);
			hideAlert() ;
			ItemLockSubWndScript.setLock( false ) ;
		break;		
		case POPUP :
			showAlert();
		break;
		case PROGRESS : 
			ItemLockSubWndScript.setLock( true ) ;
			Playsound("ItemSound3.enchant_process");
			currentProgress.SetProgressTime(1500);
			currentProgress.Reset();			
			currentProgress.Start();
			hideAlert() ;
		break;
		case END:   			
			ItemLockSubWndScript.syncInventory();
			ItemLockSubWndScript.setLock( true ) ;
		break;
	}
}

// 버튼 처리 
function setButtonByState () 
{
	local int buttonString;
	if( currentWindowType == LOCK ) 
	{
		switch ( currentState ) 
		{
			case START :
				buttonString = 3774;
				ItemLockBtn.DisableWindow();				
			break;	
			case READY : 
				buttonString = 3774;
				ItemLockBtn.EnableWindow();
			break;
			case PROGRESS :
				buttonString = 141;		
			break;
			case END:
				buttonString = 1731;	
				//Debug ( "handleState" @  currentScrollNum  ) ;
				if ( currentScrollNum > 0 ) ItemLockBtn.EnableWindow();
			break;
		default: return;
		}
	}
	else	
	{
		switch ( currentState ) 
		{
			case START :
				buttonString = 3808;
				ItemLockBtn.DisableWindow();				
			break;	
			case READY : 
				buttonString = 3808;
				ItemLockBtn.EnableWindow();
				break;
			case PROGRESS :
				buttonString = 141;		
			break;
			case END:
				buttonString = 1731;	
				//Debug ( "handleState" @  currentScrollNum  ) ;
				if ( currentScrollNum > 0 )  ItemLockBtn.EnableWindow();
			break;
			default: return;
		}
	}

	ItemLockBtn.SetButtonName( buttonString );
}


// 상단 안내 문구 수정
function setWindowInstruction( ) 
{
	local int systemMessage;
	if( currentWindowType == LOCK ) 
	{
		switch ( currentState ) 
		{
			case START :
				systemMessage = 5129;				
			break;
			case READY :
				systemMessage = 5130;
			break;
			case END:
				systemMessage = 5121;
			break;
			default: return;
		}
	}
	else
	{
		switch ( currentState ) 
		{
			case START :				
				systemMessage = 5132;
			break;						
			case READY : 
				systemMessage = 5133;
				break;
			case END:   
				systemMessage = 5122;				
			break;
			default: return;
		}
	}

	Instruction_Txt.SetText(GetSystemMessage( systemMessage ));
}


/*********************************************** 아이템 해제 시 인증이 필요 하다는 경고 문구 **************************************************************/
function showAlert( )
{
	DisableWnd.ShowWindow();
	ItemLockAlert_Wnd.ShowWindow();
}

function hideAlert () 
{
	DisableWnd.HideWindow();
	ItemLockAlert_Wnd.HideWindow();
}

/*********************************************** 정보 받기 **************************************************************/
function int getCurrentItemServerID () 
{
	local itemInfo info ; 

	ItemLock_ItemWindow.GetItem( 0, info );

	if ( IsValidItemID( info.ID)  ) return info.ID.serverID  ;
	return - 1;
}

/*********************************************** 인챈 종료 **************************************************************/
function handleResult ( string param ) 
{
	local int result ;	
	local itemInfo info;

	parseInt ( param, "Result", result ) ;
	if ( result == 0 ) 
	{
		Me.HideWindow();
		//if ( currentWindowType == LOCK ) RequestLockedItemCancel();
		//else RequestUnlockedItemCancel();
		//currentState = START;
	}
	else 
	{			
		ItemLock_ItemWindow.GetItem( 0, info );
		info.bSecurityLock = currentWindowType == LOCK;
		
		ItemLock_ItemWindow.SetItem( 0, info );
		ItemLock_ItemWindow.AddItem( info );



		switch ( currentWindowType ) 
		{
		case LOCK : 		
			AddSystemMessage( 5121 );
			//getInstanceL2Util().showGfxScreenMessage( ItemName_Txt.GetText() @  GetSystemMessage(5121)) ;
			break;
		case UNLOCK : 
			AddSystemMessage( 5122 );
			//getInstanceL2Util().showGfxScreenMessage( ItemName_Txt.GetText() @  GetSystemMessage(5122) ) ;
			break;
		}
		 
		setScrollNum ( currentScrollItemClassID ) ;
		Playsound("ItemSound3.enchant_success");	
		currentState = END;
	}
}


/******************************************************** API ****************************************/
// 봉인 요청
function RequestLockedItem  ( int targetItemID )
{
	class'EnchantAPI'.static.RequestLockedItem ( targetItemID ) ;
}

// 해제
function RequestUnlockedItem ( int targetItemID )
{
	class'EnchantAPI'.static.RequestUnlockedItem( targetItemID );
}

// 해제 취소
function RequestUnlockedItemCancel ( )
{
	class'EnchantAPI'.static.RequestUnlockedItemCancel( );
}

// 봉인 취소
function RequestLockedItemCancel  ()
{
	class'EnchantAPI'.static.RequestLockedItemCancel();
}

 

/*********************************************** 열고 닫기 **************************************************************/
function toggleShowWindow()
{	
	if ( Me.IsShowWindow() ) 
		Me.HideWindow();	
	else 
		Me.ShowWindow();
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( "ItemLockWnd" ).HideWindow();
}
defaultproperties
{
}
