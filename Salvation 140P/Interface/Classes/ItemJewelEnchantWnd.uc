class ItemJewelEnchantWnd extends UICommonAPI;

///////////////////////////////////////////////////////////////////////////////////////////
//	ItemJewelEnchantWnd 1.0																//
///////////////////////////////////////////////////////////////////////////////////////////
// 	Designed by Oxyzen
// 	UIAPI by ttMarine 
//	UC coded by Oxyzen

const C_ANIMLOOPCOUNT = 1;
const TIMER_ID = 1002012;
const TIMER_DELAY = 1000;

var bool    bEnchantbool;       //인챈 중
var bool    bEnchantedbool;     //인챈 완료

//var bool    bIsShopping;
var bool    isBreakable;

var WindowHandle Me;
var TextureHandle BackPattern;
var TextBoxHandle InstructionTxt;
var ItemWindowHandle EnchantJewel1;
var ItemWindowHandle EnchantJewel2;

var ItemWindowHandle EnchantedItemSlot;
var ButtonHandle EnchantBtn;
var ButtonHandle ExitBtn;
var ButtonHandle InitBtn;

var TextureHandle Groupbox2;
var TextureHandle Groupbox1;
var TextureHandle EnchantJewel1BackTex;
var TextureHandle EnchantJewel2BackTex;

var TextureHandle EnchantedJewelBackTex;
var TextureHandle DropHighlight_EnchantJewel2;
var TextureHandle DropHighlight_EnchantJewel1;

var AnimTextureHandle EnchantProgressAnim;

var ProgressCtrlHandle	m_hItemEnchantWndEnchantProgress;

var ItemWindowHandle InventoryItem;

// 슬롯1,2, 계속 버튼시 이전 아이템을 기억.
var ItemInfo continueSlot1ItemInfo, continueSlot2ItemInfo;

var TextBoxHandle WarningTxt;

// 변수 목록
var ItemInfo        Jewel1ItemInfo; //요청한 보석1
var ItemInfo        Jewel2ItemInfo; //요청한 보석2

var bool            bRequestPushOne;        // 보석1 푸시 리퀘스트
var bool            bRequestPushTwo;        // 보석2 푸시 리퀘스트
var bool            bRequestRemoveOne;      // 보석1 리무브 리퀘스트
var bool            bRequestRemoveTwo;      // 보석2 리무브 리퀘스트

var ItemJewelEnchantSubWnd ItemJewelEnchantSubWndScript;
var ItemWindowHandle ItemJewelEnchantSubWnd_ItemWnd;
///다이얼로그 추가	
const DLG_ID_CRASH_ALERT=1;

function OnLoad()
{
	SetClosingOnESC();
	
	Me = GetWindowHandle( "ItemJewelEnchantWnd" );

	ItemJewelEnchantSubWndScript = ItemJewelEnchantSubWnd(GetScript("ItemJewelEnchantSubWnd"));

	EnchantProgressAnim = GetAnimTextureHandle (  "ItemJewelEnchantWnd.EnchantProgressAnim"  );
	BackPattern = GetTextureHandle (  "ItemJewelEnchantWnd.BackPattern"  );
	InstructionTxt = GetTextBoxHandle (  "ItemJewelEnchantWnd.InstructionTxt"  );
	EnchantJewel1 = GetItemWindowHandle (  "ItemJewelEnchantWnd.EnchantJewel1"  );
	EnchantJewel2 = GetItemWindowHandle (  "ItemJewelEnchantWnd.EnchantJewel2"  );

	EnchantedItemSlot = GetItemWindowHandle (  "ItemJewelEnchantWnd.EnchantedItemSlot"  );
	EnchantBtn = GetButtonHandle (  "ItemJewelEnchantWnd.EnchantBtn"  );
	ExitBtn = GetButtonHandle (  "ItemJewelEnchantWnd.ExitBtn"  );
	InitBtn = GetButtonHandle (  "ItemJewelEnchantWnd.InitBtn"  );
	
	Groupbox2 = GetTextureHandle (  "ItemJewelEnchantWnd.Groupbox2"  );
	Groupbox1 = GetTextureHandle (  "ItemJewelEnchantWnd.Groupbox1"  );
	EnchantJewel1BackTex = GetTextureHandle (  "ItemJewelEnchantWnd.EnchantJewel1BackTex"  );
	EnchantJewel2BackTex = GetTextureHandle (  "ItemJewelEnchantWnd.EnchantJewel2BackTex"  );

	EnchantedJewelBackTex = GetTextureHandle (  "ItemJewelEnchantWnd.EnchantedJewelBackTex"  );
	DropHighlight_EnchantJewel2 = GetTextureHandle (  "ItemJewelEnchantWnd.DropHighlight_EnchantJewel2"  );
	DropHighlight_EnchantJewel1 = GetTextureHandle (  "ItemJewelEnchantWnd.DropHighlight_EnchantJewel1"  );
	
	m_hItemEnchantWndEnchantProgress=GetProgressCtrlHandle("ItemJewelEnchantWnd.EnchantProgress");

	InventoryItem	= GetItemWindowHandle( "InventoryWnd.InventoryItem");

	WarningTxt = GetTextBoxHandle (  "ItemJewelEnchantWnd.WarningTxt"  );

	ItemJewelEnchantSubWnd_ItemWnd = GetItemWindowHandle( "ItemJewelEnchantSubWnd.ItemJewelEnchantSubWnd_ItemWnd" );
	
	Initialize();	

	//쇼핑 중일 경우 
//	bIsShopping = false;
}

function onShow()
{ 
	// 지정한 윈도우를 제외한 닫기 기능 
	//getInstanceL2Util().ItemRelationWindowHide(getCurrentWindowName(String(self)), "InventoryWnd");
	getInstanceL2Util().ItemRelationWindowHide(getCurrentWindowName(String(self)));
	//WarningTxt.HideWindow();
	HandleHighlight();
	HandleInstructionTxt();
	checkEnchantBtn();
		
	ExitBtn.SetNameText( GetSystemString(646) );
	EnchantBtn.SetNameText( GetSystemString(428) );	

	GetWindowHandle("ItemJewelEnchantSubWnd").ShowWindow();

	InitBtn.DisableWindow();
	Initialize();
}

function Initialize()
{
	bEnchantbool = false;
	bEnchantedbool = false;
	bRequestPushOne = false;
	bRequestPushTwo = false;
	bRequestRemoveOne = false;
	bRequestRemoveTwo = false;
}

function OnRegisterEvent()
{
	RegisterEvent(EV_NewEnchantPushOneOK);		// 9760;	
	RegisterEvent(EV_NewEnchantPushOneFail);	//9761;
	RegisterEvent(EV_NewEnchantPushTwoOK);		//9762;
	RegisterEvent(EV_NewEnchantPushTwoFail);	//9763;
	RegisterEvent(EV_NewEnchantRemoveOneOK);	//9764;
	RegisterEvent(EV_NewEnchantRemoveOneFail);	//9765;
	RegisterEvent(EV_NewEnchantRemoveTwoOK);	//9766;
	RegisterEvent(EV_NewEnchantRemoveTwoFail);	//9767;
	RegisterEvent(EV_NewEnchantTrySuccess);	    //9768;
	RegisterEvent(EV_NewEnchantTryFail);		//9769;

	RegisterEvent(EV_NewEnchantRetryPutItemsOK);
	RegisterEvent(EV_NewEnchantRetryPutItemsFail);


	RegisterEvent( EV_DialogOK);
	RegisterEvent( EV_DialogCancel);	
}


function handleShowDialog()
{
	class'UICommonAPI'.static.DialogSetID( DLG_ID_CRASH_ALERT );	
	class'UICommonAPI'.static.DialogShow(DialogModalType_Modalless, DialogType_OKCancel, GetSystemMessage( 4149 ), string(Self) );	
}

function OnClickButton( string Name )
{
	local ItemID ItemID1, ItemID2;

	//Debug( "OnClickButton"  @ Name);
	switch( Name )
	{
		case "InitBtn" :			
			EnchantBtn.EnableWindow();
			Me.KillTimer(TIMER_ID);

			// 결과 상태라면, 초기값으로 돌려줌.
			if ( bEnchantedbool )
			{
				//맨 처음 스텝으로 감							
				ClearAllItems();
				HandleGoToFirstStep();
				HandleHighlight();
				class'NewEnchantAPI'.static.RequestClose();
			}
			else
			{
				// 첫번째 슬롯에 아이템을 빼주면 초기화 된다.
				OnDBClickItem("EnchantJewel1", 0);
			}
			break;

		case "EnchantBtn":
			//인챈 완료시 인첸 버튼을 클릭 했을 때 (계속 버튼)
			if ( bEnchantedbool )
			{
				//맨 처음 스텝으로 감							
				ClearAllItems();
				HandleGoToFirstStep();
				HandleHighlight();

				// ItemJewelEnchantSubWndScript.refresh();
				// 계속을 누르면 1,2 슬롯에 이전에 꼽았던 아이템을 넣어준다. 서버에 전송은 dropProcess에서 하지 않는다.
				ItemID1 = dropProcess(continueSlot1ItemInfo, 1, true);
				ItemID2 = dropProcess(continueSlot2ItemInfo, 2, true);

				//Debug("---> RequestEnchantRetryPutItems ----------");
				//Debug("ItemID1.ServerID" @ ItemID1.ServerID);
				//Debug("ItemID2.ServerID" @ ItemID2.ServerID);

				// 1,2 슬롯 모두 들어 있는 경우만 서버에 "계속" 작동을 할지 요청
				if (ItemID1.ServerId > 0 && ItemID2.ServerID > 0)
				{					
					class'NewEnchantAPI'.static.RequestEnchantRetryPutItems(ItemID1.ServerID, ItemID2.ServerID);				
				}
				else 
					HandleNewEnchantRetryPutItems(false, "");

				// 보조창 업데이트, 슬롯1에 장착이 안되어 있다면 보조창 갱신
				//if(!hasItemInSlot(1)) ItemJewelEnchantSubWndScript.refresh();
			}
			else 
			{
				bEnchantbool = true;
				EnchantBtn.DisableWindow();
				//여기서 다이얼로그 띄우고 
				//모든 창 disable
				//취소 시 HandleGoToFirstStep();, 
				//OK 시 OnEnchantBtnClick(); 
				//OnEnchantBtnClick();
				//취소 시 
				//bEnchantbool = false;
				//모두 활성화
				//etc
				//창 닫을 때는 다이얼로그 창도 닫기
				if ( isBreakable )
				{

					handleShowDialog();
					ExitBtn.DisableWindow();
					//CloverItemSlot.DisableWindow();
					//EnchantJewel1.DisableWindow();
					//EnchantJewel2.DisableWindow();				
				}
				
				else OnEnchantBtnClick();
			}
			break;
		case "ExitBtn":
			if ( bEnchantbool ) //인챈 중이면 애니메이션 중지 하고 원래 아이콘 상태로 으로
			{
				EnchantBtn.EnableWindow();
				Me.KillTimer(TIMER_ID);

				// 초기화 버튼 활성화
				InitBtn.EnableWindow();

				HandleGoToFirstStep();

				if( class'UICommonAPI'.static.DialogIsOwnedBy( string(Self) ))
					DialogHide();
				//ResetUI();
			}
			else //if (!bEnchantedbool) //인챈 완료가 아니면 취소 신청
			{			
				Me.HideWindow(); //인챈 끝났으면 닫기			
			}
			break;
	}
	
}

function  handleAddJewel1( string Param )
{
	//local int ResultID;		
		
	//ParseInt(Param, "Result", ResultID);	
	
	//Debug("handleAddJewel1");
	if( !Me.IsShowWindow() ) HandleEnchantShow();
	//	EnchantJewel1.SetItem( 0, Jewel1ItemInfo );
	EnchantJewel1.Clear();
	EnchantJewel1.AddItem( Jewel1ItemInfo );
	EnchantJewel1BackTex.HideWindow();	
	
	bRequestPushOne = false;

	HandleHighlight();	

	checkEnchantBtn();

	HandleInstructionTxt();

	// 계속 버튼시, 첫번째 슬롯에 넣을 아이템 정보 저장
	continueSlot1ItemInfo  = Jewel1ItemInfo;

	// Debug("계속 용" @Jewel1ItemInfo.name);

	// 보조창 업데이트
	ItemJewelEnchantSubWndScript.refresh();
}

function handleAddJewel2 (string param ) 
{		
	//Debug("handleAddJewel2");
	//EnchantJewel2.SetItem( 0, Jewel2ItemInfo );
	EnchantJewel2.Clear();
	EnchantJewel2.AddItem( Jewel2ItemInfo );
	EnchantJewel2BackTex.HideWindow();

	continueSlot2ItemInfo  = Jewel2ItemInfo;

	bRequestPushTwo = false;

	HandleHighlight();

	checkEnchantBtn();

	HandleInstructionTxt();

	// 보조창 업데이트
	ItemJewelEnchantSubWndScript.refresh();
}

function handleRemoveJewel1 (string param) 
{
	EnchantJewel1.Clear();
	bRequestRemoveOne = false;
	EnchantJewel1BackTex.ShowWindow();
	HandleHighlight();
	HandleInstructionTxt();
	//WarningTxt.HideWindow();
	checkEnchantBtn();

	InitBtn.DisableWindow();

	ItemJewelEnchantSubWndScript.refresh();
}

function handleRemoveJewel2 (string param ) 
{
	EnchantJewel2.Clear();
	bRequestRemoveTwo = false;
	EnchantJewel2BackTex.ShowWindow();
	HandleHighlight();
	HandleInstructionTxt();
	WarningTxt.HideWindow();
	//checkEnchantBtn();

	ItemJewelEnchantSubWndScript.refresh();
}

function OnEvent(int Event_ID, string param)
{
	//Debug("OnEvent" @ Event_ID @ param);
	switch ( Event_ID ) 
	{
		case EV_NewEnchantPushOneOK:			
			handleAddJewel1( param );
			break;
		case EV_NewEnchantPushOneFail:
			bRequestPushOne = false;
			break;
		case EV_NewEnchantPushTwoOK:
			handleAddJewel2( param );
			break;
		case EV_NewEnchantPushTwoFail:		
			bRequestPushTwo = false;	
			break;
		case EV_NewEnchantRemoveOneOK:
			handleRemoveJewel1( param ) ;
			break;
		case EV_NewEnchantRemoveOneFail:				
			bRequestRemoveOne = false;	
			checkEnchantBtn();
			break;
		case EV_NewEnchantRemoveTwoOK:
			handleRemoveJewel2( param ) ;
			break;
		case EV_NewEnchantRemoveTwoFail:
			bRequestRemoveTwo = false;
			checkEnchantBtn();
			break;
		case EV_NewEnchantTrySuccess:
			handleEnchantSuccess( param );			
			break;
		case EV_NewEnchantTryFail:			
			handleEnchantFail( param ) ;			
			break;

		case EV_NewEnchantRetryPutItemsOK:
			HandleNewEnchantRetryPutItems(true, param );
			break;

		case EV_NewEnchantRetryPutItemsFail:
			HandleNewEnchantRetryPutItems(false, param );
			break;

		case EV_DialogOK:
			break;
		case EV_DialogCancel:
			break;
	}
}

// 
function HandleNewEnchantRetryPutItems(bool bSuccess, string param)
{
	local ItemInfo emptyItemInfo;

	//Debug("------------ HandleNewEnchantRetryPutItems --------------");

	//Debug("bSuccess" @ bSuccess);
	//Debug("param:" @ param);

	if (bSuccess)
	{
		handleAddJewel1("");
		handleAddJewel2("");
	}
	else
	{
		Jewel1ItemInfo = emptyItemInfo;
		Jewel2ItemInfo = emptyItemInfo;
		// bRequestPushOne = false;
		// bRequestPushTwo = false;

		handleRemoveJewel1("");
		handleRemoveJewel2("");
	}

	if(!hasItemInSlot(1)) ItemJewelEnchantSubWndScript.refresh();
}

function HandleDialogResult(bool bOk)
{
	local int DlgID;
	///local int Reserved;

	if(!class'UICommonAPI'.static.DialogIsOwnedBy( string(Self) ))
		return;

	Me.setFocus();
	DlgID = class'UICommonAPI'.static.DialogGetID();
	//Reserved = class'UICommonAPI'.static.DialogGetReservedInt();

	switch(DlgID)
	{
		case DLG_ID_CRASH_ALERT :
			HandleDlGCrashAlert(bOk);
			break;		
	}
}

function HandleDlGCrashAlert( bool bOk )
{
	ExitBtn.EnableWindow();

	if ( bOK )
	{
		OnEnchantBtnClick();
	}
	else 
	{
		bEnchantbool = false;
		EnchantBtn.EnableWindow();
	}
}


function HandleInstructionTxt()
{
	local int systemMessage;

	local itemInfo tmpItem1;
	local itemInfo tmpItem2;	
	
	EnchantJewel1.GetItem( 0, tmpItem1 ) ;
	EnchantJewel2.GetItem( 0, tmpItem2 ) ;

	//아이템이 비었을 때
	//2339 : 인챈트 할 아이템을 올려놓으십시오.

	//아이템이 찼을 때
	//2341 : 아래의 시작 버튼을 누르면 인챈트가 시작 됩니다. 	

	//스크롤 아이템이 없을 때
	if ( tmpItem1.ID.serverID < 1 ||  tmpItem2.ID.serverID < 1  ) 
	{
		//인챈트 할 아이템을 올려놓으십시오.
		systemMessage = 4232;
	}
	/*
	else if (  tmpItem2.ID.serverID < 1 )
	{
		//인챈트 할 아이템을 올려놓으십시오.
		systemMessage = 2339;
	}	*/
	else 
	{
		//아래의 시작 버튼을 누르면 인챈트가 시작 됩니다.
		systemMessage = 4233;
	}		

	InstructionTxt.SetText(GetSystemMessage( systemMessage ));
}	

function HandleHighlight()
{
	local itemInfo tmpItem1;
	local itemInfo tmpItem2;
	
	//refineslot1 깜빡임 
	//refineslot2 안깜빡.
	DropHighlight_EnchantJewel1.SetTexture("L2UI_ch3.RefineryWnd.refineslot2");		
	DropHighlight_EnchantJewel2.SetTexture("L2UI_ch3.RefineryWnd.refineslot2");
	
	EnchantJewel1.GetItem( 0, tmpItem1 ) ;
	EnchantJewel2.GetItem( 0, tmpItem2 ) ;
	//Debug( "HandleHighlight" @ tmpItem1.ID.serverID @  tmpItem1.ID.serverID );
	//1번에서 서버 아이디가 아무것도 없으면, 
	if ( tmpItem1.ID.serverID < 1 && tmpItem2.ID.serverID < 1 ) 
	{ 
		//깜빡여라.		
		DropHighlight_EnchantJewel1.SetTexture("L2UI_ch3.RefineryWnd.refineslot1");
	}
	// 1번에 슬롯을 넣으면 두번째 슬롯만 깜빡이게
	else if (tmpItem1.ID.serverID > 1)
	{
		//깜빡여라.		
		DropHighlight_EnchantJewel2.SetTexture("L2UI_ch3.RefineryWnd.refineslot1");
	}		
}

//애니 중지
function HandleGoToFirstStep()
{	
	//local ItemInfo EmptyInfo;
	ProcCancel();

	EnchantProgressAnim.SetTexture("l2ui_ct1.ItemEnchant_DF_Effect_Loading_01");
	EnchantProgressAnim.HideWindow();
	BackPattern.HideWindow();
	InstructionTxt.SetText( "" );

	m_hItemEnchantWndEnchantProgress.SetProgressTime(1500);
	m_hItemEnchantWndEnchantProgress.SetPos(0);		
	m_hItemEnchantWndEnchantProgress.Reset();
	
	bEnchantbool = false;
	bEnchantedbool = false;	

	EnchantJewel1.DisableTick();
	EnchantJewel2.DisableTick();
	EnchantedItemSlot.DisableTick();

	EnchantedItemSlot.Clear();

	EnchantJewel1BackTex.ShowWindow();
	EnchantJewel2BackTex.ShowWindow();	
	
	ResetUI();
	HandleHighlight();
	HandleInstructionTxt();
	checkEnchantBtn();
	ExitBtn.SetNameText( GetSystemString(646) );
	EnchantBtn.SetNameText( GetSystemString(428) );
}

function OnEnchantBtnClick()
{
	local Rect Item1Rect;
	local Rect Item2Rect;	
	local Rect ResultRect;	
	
	EnchantProgressAnim.SetLoopCount( C_ANIMLOOPCOUNT );
	EnchantProgressAnim.Stop();
	EnchantProgressAnim.Play();
	Playsound("ItemSound3.enchant_process");
	EnchantProgressAnim.ShowWindow();

	m_hItemEnchantWndEnchantProgress.Start();
		
	Item1Rect = EnchantJewel1.GetRect();
	Item2Rect = EnchantJewel2.GetRect();
	
	ResultRect = EnchantedItemSlot.GetRect();

	EnchantJewel1.EnableTick();
	EnchantJewel2.EnableTick();

	EnchantJewel1.Move( ResultRect.nX - Item1Rect.nX, ResultRect.nY - Item1Rect.nY, 1.5f );
	EnchantJewel2.Move( ResultRect.nX - Item2Rect.nX, ResultRect.nY - Item2Rect.nY, 1.5f );

	EnchantJewel1BackTex.HideWindow();
	EnchantJewel2BackTex.HideWindow();	
	EnchantedJewelBackTex.HideWindow();

	ExitBtn.SetNameText( GetSystemString(141) );
	EnchantBtn.SetNameText( GetSystemString(428) );

	// 초기화 버튼 비활성화
	InitBtn.DisableWindow();
}

function ProcCancel()
{
	bEnchantbool = false;
	m_hItemEnchantWndEnchantProgress.Stop();
	EnchantProgressAnim.Stop();
}

function OnTextureAnimEnd( AnimTextureHandle a_WindowHandle )
{
	//~ local ItemID SupportID;
	EnchantProgressAnim.HideWindow();
	EnchantProgressAnim.Stop();
	EnchantProgressAnim.HideWindow();
	switch ( a_WindowHandle )
	{
		case EnchantProgressAnim:
			//~ EnchantProgressAnim.Stop();
			//~ EnchantProgressAnim.HideWindow();
			if ( bEnchantbool )
			{				
				bEnchantbool = false;
				//Debug("RequestEnchantItem" @ SelectItemInfo.ID.ClassID @ SelectHelperItemInfo.ID.ClassID);
				class'NewEnchantAPI'.static.RequestTryEnchant( );
			}				
		break;
	}
	EnchantProgressAnim.HideWindow();
}


//~ function OnExitBtnClick()
//~ {
	//~ OnCancelClick();
//~ }

function HandleEnchantShow( )
{
	//테숫후
	ResetUI();
	ClearAllItems();
	Me.ShowWindow();	
	Me.SetFocus();
}

//리퀘스트에 대한 답변을 모두 받았는지 체크 함.( 예외 사항을 줄이기 위함 ) 
function bool bRequesteEnd()
{
	return ( !bRequestPushOne && !bRequestPushTwo && !bRequestRemoveOne && !bRequestRemoveTwo );
}

//보석 두개가 모두 박혀 있는지 체크 함. 
function bool bJewelAllReady()
{
	local itemInfo tmpItem;
	local itemInfo tmpItem2;

	EnchantJewel2.GetItem( 0, tmpItem )  ;	
	if ( tmpItem.ID.serverID < 1) return false;
	
	EnchantJewel1.GetItem( 0, tmpItem2 ) ;	
	if ( tmpItem2.ID.serverID < 1) return false;
	
	//Debug( tmpItem.ID.serverID $ tmpItem.ID.serverID  );
	return true;

}

function checkEnchantBtn()
{
	//EnchantBtn의 조건 
	//시도 완료 성공 시 > result에서 처리 
	//모든 request의 답변이 왔을 때
	//슬롯 두 개가 찼을 때	
	//bEnchantbool, bEnchantedbool 이 false 때
	//EnchantBtn
	local bool isEnableEnchantBtn , bNoFailResult;	

	isEnableEnchantBtn = bRequesteEnd() && bJewelAllReady() && ( !bEnchantbool && !bEnchantedbool ) ;

	if (isEnableEnchantBtn ) 
	{
		EnchantBtn.EnableWindow();
		//합성에 대한 경고 메시지

		// 합성이 무조건 성공으로 보이게 하는 경우라면..
		bNoFailResult = class'NewEnchantAPI'.static.IsNoFailResultEffectType(getSlotItemWindowByIndex(1), getSlotItemWindowByIndex(2));
		
		if(bNoFailResult == true)
		{
			// 합성 실패 시 일부 또는 모든 재료가 사라질 수 있습니다. 진행하시겠습니까?
			WarningTxt.SetText(GetSystemMessage( 4424 ) );	
		}
		else
		{
			//합성 실패 시 일부 또는 모든 재료가 사라질 수 있습니다. 진행하시겠습니까?
			WarningTxt.SetText(GetSystemMessage( 4234 ) );	
		}

		WarningTxt.ShowWindow();
	}
	else 
	{
		// 슬롯에 아무것도 없다면..
		if(hasItemInSlot(1) == false && hasItemInSlot(2) == false)
		{
			// 수량성 아이템 등록시 한개씩 등록됩니다. 
			WarningTxt.ShowWindow();
			WarningTxt.SetText(GetSystemString( 3501 ) );
		}
		else
		{
			WarningTxt.HideWindow();
			EnchantBtn.DisableWindow();
		}
	}
	
	// 슬롯에 아이템이 하나라도 있다면..
	if(hasItemInSlot(1) || hasItemInSlot(2))
	{
		InitBtn.EnableWindow();
	}
	else
	{
		InitBtn.DisableWindow();
	}

	//hasItemInSlot

	//InitBtn
}

// 슬롯에 아이템이 들어 있나 체크
function bool hasItemInSlot(int slotIndex)
{
	local itemInfo info;
	local bool bFlag;

	if (slotIndex == 1)
		EnchantJewel1.GetItem(0 , info );
	else 
		EnchantJewel2.GetItem(0 , info );

	if (info.Id.ClassID > 0)
	{
		bFlag = true;
	}

	return bFlag;
}

function ClearAllItems()
{
	EnchantJewel1.Clear();
	EnchantJewel2.Clear();	
	EnchantedItemSlot.Clear();
}

function ResetUI()
{
	//EnchantProgressAnim.HideWindow();
	EnchantProgressAnim.SetTexture("l2ui_ct1.ItemEnchant_DF_Effect_Loading_01");
	EnchantProgressAnim.HideWindow();
	BackPattern.HideWindow();
	InstructionTxt.SetText( "" );

	EnchantedItemSlot.SetAnchor( "ItemJewelEnchantWnd", "TopLeft", "TopLeft", 116, 90 );
	EnchantedItemSlot.SetWindowSize(34,34);
	EnchantedItemSlot.ClearAnchor();
	EnchantedItemSlot.ShowWindow();

	EnchantBtn.DisableWindow();
	
	//EnchantJewel2.SetAlpha(255,0);

	EnchantJewel1.SetAnchor( "ItemJewelEnchantWnd", "TopLeft", "TopLeft", 78, 90 );
	EnchantJewel1.SetWindowSize(34,34);
	EnchantJewel1.ClearAnchor();
	EnchantJewel1.ShowWindow();

	EnchantJewel2.SetAnchor( "ItemJewelEnchantWnd", "TopLeft", "TopLeft", 157, 90 );
	EnchantJewel2.SetWindowSize(34,34);
	EnchantJewel2.ClearAnchor();
	EnchantJewel2.ShowWindow();

	EnchantJewel1BackTex.SetAnchor( "ItemJewelEnchantWnd", "TopLeft", "TopLeft", 77, 90 );
	EnchantJewel1BackTex.ClearAnchor();
	EnchantJewel1BackTex.ShowWindow();
	
	EnchantJewel2BackTex.SetAnchor( "ItemJewelEnchantWnd", "TopLeft", "TopLeft", 156, 90 );
	EnchantJewel2BackTex.ClearAnchor();
	EnchantJewel2BackTex.ShowWindow();

	EnchantedJewelBackTex.HideWindow();
	
	m_hItemEnchantWndEnchantProgress.SetProgressTime(1500);
	m_hItemEnchantWndEnchantProgress.SetPos(0);		
	m_hItemEnchantWndEnchantProgress.Reset();
}     

function OnHide()
{
	class'NewEnchantAPI'.static.RequestClose();
	ResetUI();
	ClearAllItems();
	Initialize();	

	GetWindowHandle("ItemJewelEnchantSubWnd").HideWindow();
	EnchantBtn.EnableWindow();
	Me.KillTimer(TIMER_ID);
	// Debug("onHide");
}

//쥬얼 타입을 비트 타입으로 체크 
function bool IsEnchantableItem(int64  SlotBitType)
{
	return ( SlotBitType == 1073741824 )	;
}

//순차 적으로 넣을 경우 => 인벤토리에서 바로 넣는 경우 
function handleDropedItem( ItemInfo a_ItemInfo )
{	 
	local itemInfo tmpJewelItemInfo1;
	local itemInfo tmpJewelItemInfo2;

	EnchantJewel1.GetItem(0 , tmpJewelItemInfo1 );
	EnchantJewel2.GetItem(0 , tmpJewelItemInfo2 );
	
	//창이 닫힌 상태에서는 bEnchantbool || bEnchantedbool 체크를 하지 않는다.
	if ( ( bEnchantbool || bEnchantedbool ) && Me.IsShowWindow() ) return;

	//같은 아이템일 경우 시도 하지 않는다.  < 서버에서도 처리
	
	if ( IsSameItemID( tmpJewelItemInfo1.ID , a_ItemInfo.ID ) || IsSameItemID( tmpJewelItemInfo2.ID , a_ItemInfo.ID ) ) 
	{	
		return;
	}

	if ( tmpJewelItemInfo1.ID.serverID == 0 ) 
	{	
		class'NewEnchantAPI'.static.RequestPushOne ( a_ItemInfo.ID ) ;
		bRequestPushOne = true;
		Jewel1ItemInfo = a_ItemInfo;
	}
	else 
	{
		class'NewEnchantAPI'.static.RequestPushTwo ( a_ItemInfo.ID ) ;
		bRequestPushTwo = true;
		Jewel2ItemInfo = a_ItemInfo;
	}
}




function OnDropItem( String a_WindowID, ItemInfo a_ItemInfo, int X, int Y)
{	
	local Rect rectWnd;		

	if (a_ItemInfo.ItemSubType == EShortCutItemType.SCIT_MACRO) return;
	if (a_ItemInfo.DragSrcName != "ItemJewelEnchantSubWnd_ItemWnd") return;
	
	rectWnd = Me.GetRect();	
	
//	Debug( "OnDropItem" @ bEnchantbool @ bEnchantedbool);
	if ( bEnchantbool || bEnchantedbool ) return;

	////같은 아이템일 경우 시도 하지 않는다.  < 서버에서도 처리	
	//if ( IsSameItemID( tmpJewelItemInfo1.ID , a_ItemInfo.ID ) || IsSameItemID( tmpJewelItemInfo2.ID , a_ItemInfo.ID ) ) 
	//{	
	//	return;
	//}

	//if ( X > rectWnd.nX + 9 && X < rectWnd.nX + 9 + 246/2 && Y > rectWnd.nY + 39 && Y < rectWnd.nY + 39 + 137)//반절 이전
	if ( X > rectWnd.nX + 9 && X < rectWnd.nX + 9 + rectWnd.nWidth && Y > rectWnd.nY + 39 && Y < rectWnd.nY + 39 + 137)//반절 이전
	{	
		//Debug( " drop case 1" ) ;
		//숏컷에서 아이템이 드랍됐을 경우 아이템 ItemSubType은 다른 용도로 쓰이므로, 인벤의 데이타를 다시 받아야 함.
		//InventoryItem.GetItem(InventoryItem.FindItem( a_ItemInfo.ID ), a_ItemInfo);		
		//class'NewEnchantAPI'.static.RequestPushOne ( a_ItemInfo.ID ) ;
		//bRequestPushOne = true;
		//Jewel1ItemInfo = a_ItemInfo;

		if(hasItemInSlot(1))
			dropProcess(a_ItemInfo, 2);
		else
			dropProcess(a_ItemInfo, 1);
		
	}
	//else if ( X > rectWnd.nX + 9 + 246/2 && X < rectWnd.nX + 9 + 246 && Y > rectWnd.nY + 39 && Y < rectWnd.nY + 39 + 137 )//반절 이상
	//{
	//	//Debug( " drop case 2" ) ;
	//	//InventoryItem.GetItem(InventoryItem.FindItem( a_ItemInfo.ID ), a_ItemInfo);	
	//	//class'NewEnchantAPI'.static.RequestPushTwo ( a_ItemInfo.ID ) ;
	//	//bRequestPushTwo = true;
	//	//Jewel2ItemInfo = a_ItemInfo;

	//	dropProcess(a_ItemInfo, 2);
	//}
}

// slotIndex (1,2) 0은 자동으로 넣기
function ItemID dropProcess(itemInfo a_ItemInfo, int slotIndex, optional bool bNoRequestServer)
{
	local itemInfo tmpJewelItemInfo1;
	local itemInfo tmpJewelItemInfo2;
	local ItemID emptyItemID;

	local int hasItemCount, i, selectIndex;

	local array<ItemInfo> ItemInfoArray;
	local ItemInfo ServerIDItemInfo;

	if (a_ItemInfo.ItemSubType == EShortCutItemType.SCIT_MACRO) return emptyItemID;
	if ( bEnchantbool || bEnchantedbool ) return emptyItemID;

	EnchantJewel1.GetItem(0 , tmpJewelItemInfo1 );
	EnchantJewel2.GetItem(0 , tmpJewelItemInfo2 );

	if (slotIndex == 0)
	{   
		if (tmpJewelItemInfo1.Id.ClassID <= 0)
		{
			slotIndex = 1;
		}
		else if (tmpJewelItemInfo2.Id.ClassID <= 0)
		{
			slotIndex = 2;
		}
	}

	//InventoryItem.GetItem(InventoryItem.FindItem( a_ItemInfo.Id ), a_ItemInfo);
	
	//// 수량성 아이템이면 classID 로만 찾으면 되고..
	if(IsStackableItem(a_ItemInfo.ConsumeType))
	{
		InventoryItem.GetItem(InventoryItem.FindItemByClassID( a_ItemInfo.Id ), a_ItemInfo);		
	}
	else
	{
		if (slotIndex == 1)
		{
			// InventoryItem.GetItem(InventoryItem.FindItemByClassID( a_ItemInfo.ID ), a_ItemInfo);
			//hasItemCount = getInstanceL2Util().FindItemByClassID(a_ItemInfo.Id.ClassID, ItemInfoArray, getInstanceL2Util().EItemLockedCheckType.UNLOCK);
			hasItemCount = 0;
			if(getInstanceL2Util().FindItemByServerID(a_ItemInfo.Id.ServerID,ServerIDItemInfo,getInstanceL2Util().EItemLockedCheckType.UNLOCK))
				hasItemCount = 1;
	
			//class'UIDATA_INVENTORY'.static.FindItemByClassID(a_ItemInfo.Id.ClassID, ItemInfoArray);							
			// 1개 이상이 존재 한다면 그대로 슬롯에 넣어 준다.
			
			//if(ItemInfoArray.Length > 0) a_ItemInfo = ItemInfoArray[0];

			a_ItemInfo = ServerIDItemInfo;
			if (hasItemCount <= 0) return emptyItemID;

			//Debug("슬롯1" @ a_ItemInfo.Id.ServerID);

		}
		else if (slotIndex == 2)
		{
			hasItemCount = getInstanceL2Util().FindItemByClassID(a_ItemInfo.Id.ClassID, ItemInfoArray, getInstanceL2Util().EItemLockedCheckType.UNLOCK);	
			//class'UIDATA_INVENTORY'.static.FindItemByClassID(a_ItemInfo.Id.ClassID, ItemInfoArray);				

			//Debug("두번째ItemInfoArray.Length: " @ ItemInfoArray.Length);
				
			selectIndex = -1;
			for(i = 0; i < ItemInfoArray.Length; i++)
			{
				//Debug("Jewel1ItemInfo.Id.ServerID" @Jewel1ItemInfo.Id.ServerID);
				//Debug("ServerID" @ ItemInfoArray[i].Id.ServerID);

				if(ItemInfoArray[i].Id.ServerID != Jewel1ItemInfo.Id.ServerID) 
				{   
					selectIndex = i;
					//Debug("정지 " @ selectIndex);
					break;
				}
			}

			if (selectIndex == -1) return emptyItemID;
			
			a_ItemInfo = ItemInfoArray[selectIndex];
		}
	}

	
	
	if(slotIndex == 1)
	{
		if (bNoRequestServer == false) class'NewEnchantAPI'.static.RequestPushOne ( a_ItemInfo.ID );
		//Debug ("slot1 bSecurityLock :" @ a_ItemInfo.bSecurityLock);
		bRequestPushOne = true;
		a_ItemInfo.ItemNum = 1;  // 무조건 1개가 있어야함
		Jewel1ItemInfo = a_ItemInfo;
	}
	else if(slotIndex == 2)
	{
		if (bNoRequestServer == false) class'NewEnchantAPI'.static.RequestPushTwo ( a_ItemInfo.ID );
		//Debug ("slot2 bSecurityLock :" @ a_ItemInfo.bSecurityLock);
		bRequestPushTwo = true;
		a_ItemInfo.ItemNum = 1; // 무조건 1개가 있어야함
		Jewel2ItemInfo = a_ItemInfo;
	}
	
	return a_ItemInfo.Id;
}

function OnRClickItem( String strID, int index )
{
	OnDBClickItem(strID, index);
}

function OnDBClickItem( string ControlName, int index )
{
	local itemInfo tmpJewelItemInfo1;
	local itemInfo tmpJewelItemInfo2;

	if ( bEnchantbool ) return;
//	Debug( ControlName @ String ( index ));	

	switch(ControlName)
	{
		// 1번 슬롯을 비우면 2번 슬롯도 비우게 해야 한다.
		case "EnchantJewel1" : 
			 if(hasItemInSlot(1))
			 {
				 EnchantJewel1.GetItem(0 , tmpJewelItemInfo1 );
				 bRequestRemoveOne = true;
				 //요청 한 사이에 인첸트 시도를 하지 않도록 disable 시킴
				 EnchantBtn.DisableWindow();
				 class'NewEnchantAPI'.static.RequestRemoveOne ( tmpJewelItemInfo1.ID );		
			 }
			 // break를 하지 않고 다음으로 넘어 가게.. 단 슬롯이 있는지 체크는 하도록 한다.

		case "EnchantJewel2":
			 if(hasItemInSlot(2))
			 {
				 EnchantJewel2.GetItem(0 , tmpJewelItemInfo2 );
				 bRequestRemoveTwo = true;
				 //요청 한 사이에 인첸트 시도를 하지 않도록 disable 시킴
				 EnchantBtn.DisableWindow();
				 class'NewEnchantAPI'.static.RequestRemoveTwo ( tmpJewelItemInfo2.ID );		
			 }
			 
			 break;
	}

	//if ( ControlName == "EnchantJewel1")
	//{
	//	EnchantJewel1.GetItem(0 , tmpJewelItemInfo1 );
	//	bRequestRemoveOne = true;
	//	//요청 한 사이에 인첸트 시도를 하지 않도록 disable 시킴
	//	EnchantBtn.DisableWindow();
	//	class'NewEnchantAPI'.static.RequestRemoveOne ( tmpJewelItemInfo1.ID );		
	//}	
	//else if( ControlName == "EnchantJewel2")
	//{
	//	EnchantJewel2.GetItem(0 , tmpJewelItemInfo2 );
	//	bRequestRemoveTwo = true;
	//	//요청 한 사이에 인첸트 시도를 하지 않도록 disable 시킴
	//	EnchantBtn.DisableWindow();
	//	class'NewEnchantAPI'.static.RequestRemoveTwo ( tmpJewelItemInfo2.ID );		
	//}	
}

function OnDropItemSource( String strTarget, ItemInfo info )
{
	local itemInfo tmpJewelItemInfo1;
	local itemInfo tmpJewelItemInfo2;

	if ( bEnchantbool || bEnchantedbool) return;//인챈 중이거나 인챈 완료 시 

	//Debug( "OnDropItemSource" @ strTarget  @ info.DragSrcName );

	if ( strTarget == "Console")
	{		
		switch ( info.DragSrcName  )
		{
			case "EnchantJewel1" :		
				EnchantJewel1.GetItem(0 , tmpJewelItemInfo1 );
				bRequestRemoveOne = true;
				EnchantBtn.DisableWindow();
				class'NewEnchantAPI'.static.RequestRemoveOne ( tmpJewelItemInfo1.ID );		
				//removeSupportItm();
				break;	
				
			case "EnchantJewel2" :
				EnchantJewel2.GetItem(0 , tmpJewelItemInfo2 );
				bRequestRemoveTwo = true;
				EnchantBtn.DisableWindow();
				class'NewEnchantAPI'.static.RequestRemoveTwo ( tmpJewelItemInfo2.ID );		
				//removeSupportItm();
				break;	
		}		
	}
}

function handleEnchantEnd( itemInfo resultItem ) 
{
	//Debug("handleEnchantEnd");
	bEnchantedbool = true; 

	WarningTxt.HideWindow();
	
	EnchantProgressAnim.HideWindow();	
	
	//EnchantJewel2BackTex.HideWindow();
	EnchantedJewelBackTex.HideWindow();

	EnchantedItemSlot.EnableTick();	
	
	EnchantProgressAnim.HideWindow();	
	EnchantProgressAnim.SetLoopCount( C_ANIMLOOPCOUNT );
	EnchantProgressAnim.Stop();
	EnchantProgressAnim.Play();	
	EnchantProgressAnim.ShowWindow();	

	BackPattern.SetAlpha(0, 0);
	BackPattern.ShowWindow();
	BackPattern.SetAlpha(255, 2);
	
	EnchantedItemSlot.SetAlpha(0);
	EnchantedItemSlot.SetItem( 0, ResultItem );
	EnchantedItemSlot.AddItem( ResultItem );
	EnchantedItemSlot.ShowWindow();
	EnchantedItemSlot.SetAlpha(255,2);	
	
	EnchantJewel1.Clear();
	EnchantJewel2.Clear();

	EnchantJewel2.HideWindow();	
	EnchantJewel1.HideWindow();

	// 계속 버튼으로 변경
	// 지정한 시간 만큼 약간 딜레이를 주고, 바로 하면 슬롯이 정상적으로 삽입 되지 않음.
	Me.SetTimer(TIMER_ID, TIMER_DELAY);
	//EnchantBtn.EnableWindow();
	EnchantBtn.SetNameText( GetSystemString(3135) );

	// 초기화 버튼 활성화
	InitBtn.EnableWindow();
}


function handleEnchantFail( string param ) 
{	
	local ItemInfo ResultItem;	

	local bool bNoFailResult, bUseGetItemNum;
	// GetResultItemForEnchant 용 변수
	local int ResultItemClassID, ResultItemNum, FailResultItemClassID, FailResultItemNum;

	// 결과 값이 무조건 성공 효과로 보이게 할지, 아니면 성공, 실패 모드로 할지를 얻어 낸다.
	bNoFailResult = class'NewEnchantAPI'.static.IsNoFailResultEffectType(getSlotItemWindowByIndex(1), getSlotItemWindowByIndex(2));

	// 얻은 아이템 
	parseInt( param, "ItemClassID", ResultItem.ID.classID ) ;

	Debug("무조건 성공으로 할것인가? bNoFailResult:" @ bNoFailResult);
	Debug( "handleEnchantFail param:" @ param );

	if ( ResultItem.ID.classID  == 0 ) 
	{
		Me.HideWindow();
		//HandleGoToFirstStep();
		return ;
	}
	
	//실패 하여 얻었습니다.
	bUseGetItemNum = class'NewEnchantAPI'.static.GetResultItemForEnchant(getSlotItemWindowByIndex(1), getSlotItemWindowByIndex(2), 
							ResultItemClassID, ResultItemNum, FailResultItemClassID, FailResultItemNum);

	class'UIDATA_ITEM'.static.GetItemInfo( ResultItem.ID, ResultItem );		

	// 무조건 성공으로 보여지게 할 것인지..
	if (bNoFailResult)
	{
		//handleEnchantSuccess(param);
		EnchantProgressAnim.SetTexture("l2ui_ct1.ItemEnchant_DF_Effect_Success_00");
		Playsound("ItemSound3.enchant_success");	
		InstructionTxt.SetText( MakeFullSystemMsg(GetSystemMessage( 4417 ), ResultItem.name, String(FailResultItemNum)) );	

	}
	// 실패 
	else
	{
		EnchantProgressAnim.SetTexture("l2ui_ct1.ItemEnchant_DF_Effect_Failed_01");
		Playsound("ItemSound3.enchant_fail");
		InstructionTxt.SetText( MakeFullSystemMsg(GetSystemMessage( 4414 ), ResultItem.name, String(FailResultItemNum)) );	
	}

	// 실패시 수량을 스크립트 값으로 넣는다(서버에서 안주는 정보임)
	ResultItem.ItemNum = FailResultItemNum;

	Debug("----------------  handleEnchantFail ---------------------------------------------");
	if(ResultItem.ID.classID != FailResultItemClassID)
	{
		Debug("********* 주의 : 서버 값과 스크립트 실패 값이 다릅니다 확인 해주세요");
	}

	Debug("bUseGetItemNum " @ bUseGetItemNum);
	Debug("ResultItemClassID" @ ResultItemClassID);
	Debug("ResultItemNum" @ ResultItemNum);
	Debug("FailResultItemClassID" @ FailResultItemClassID);
	Debug("FailResultItemNum" @ FailResultItemNum);
	
	//InstructionTxt.SetText( MakeFullSystemMsg(GetSystemMessage( 4236 ), ResultItem.name ) );	

	handleEnchantEnd( ResultItem ) ;
}

function handleEnchantSuccess( string param ) 
{	
	local ItemInfo ResultItem;		
	local bool bUseGetItemNum;
	// GetResultItemForEnchant 용 변수
	local int ResultItemClassID, ResultItemNum, FailResultItemClassID, FailResultItemNum;

	// 결과 값이 무조건 성공 효과로 보이게 할지, 아니면 성공, 실패 모드로 할지를 얻어 낸다.
	//bNoFailResult = class'NewEnchantAPI'.static.IsNoFailResultEffectType(getSlotItemWindowByIndex(1), getSlotItemWindowByIndex(2));

	parseInt( param, "ItemClassID", ResultItem.ID.classID ) ;
	//Debug( "handleEnchantSuccess" @ param );

	if ( ResultItem.ID.classID  == 0 ) 
	{
		Me.HideWindow();
		//HandleGoToFirstStep();
		return ;
	}
	
	Debug(" handleEnchantSuccess param: " @ param);
	class'UIDATA_ITEM'.static.GetItemInfo( ResultItem.ID, ResultItem );			
	EnchantProgressAnim.SetTexture("l2ui_ct1.ItemEnchant_DF_Effect_Success_00");
	Playsound("ItemSound3.enchant_success");	
	
	//강화가 성공 하여 name이 되었습니다.

	bUseGetItemNum = class'NewEnchantAPI'.static.GetResultItemForEnchant(getSlotItemWindowByIndex(1), getSlotItemWindowByIndex(2), 
							ResultItemClassID, ResultItemNum, FailResultItemClassID, FailResultItemNum);

	ResultItem.ItemNum = ResultItemNum;

	InstructionTxt.SetText( MakeFullSystemMsg(GetSystemMessage( 4413 ), ResultItem.name, string(ResultItemNum)) );	
	Debug("-------------  handleEnchantSuccess  ------------------------------------------------");
	Debug("bUseGetItemNum " @ bUseGetItemNum);
	Debug("ResultItemClassID" @ ResultItemClassID);
	Debug("ResultItemNum" @ ResultItemNum);
	Debug("FailResultItemClassID" @ FailResultItemClassID);
	Debug("FailResultItemNum" @ FailResultItemNum);

	handleEnchantEnd( ResultItem ) ;
}

//토글 벗
function toggleShowWindow()
{
	// Debug("param" @ param);
	local ItemEnchantWnd script;
	script = ItemEnchantWnd ( GetScript ( "ItemEnchantWnd" )) ;
	if ( Me.IsShowWindow() ) 
	{
		Me.HideWindow();		
	/*
	else
	{
		//class'EnchantAPI'.static.RequestExCancelEnchantItem();
	}*/
	}
	else if (! script.bIsShopping )
	{
//		Debug( "toggleShowWindow" @ script.bIsShopping );
		HandleEnchantShow();
	}
}

// 합성 슬롯 1, 2 에서 아이템 클래스 ID 정보를 리턴한다.
function int getSlotItemWindowByIndex(int slotIndex)
{
	local ItemInfo info;

	if (slotIndex == 1)
		EnchantJewel1.GetItem(0, info);
	else 
		EnchantJewel2.GetItem(0, info);

	return info.Id.ClassID;
}

function bool isWorkingEnchant()
{
	//인챈 중이거나 인챈 완료 시 
	if ( bEnchantbool || bEnchantedbool) return true;
	return false;
}

function OnTimer(int TimerID)
{
	if(TimerID == TIMER_ID)
	{
		EnchantBtn.EnableWindow();
		Me.KillTimer( TIMER_ID );
	}
}

/*
function SetIsShopping(bool isShopping)
{
	
	bIsShopping = isShopping;

	// debug("=============isShopping : " $ bIsShopping);
}*/

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	OnClickButton( "ExitBtn" );
}
defaultproperties
{
}
