class ItemEnchantWnd extends UICommonAPI;

///////////////////////////////////////////////////////////////////////////////////////////
//	ItemEnchantWnd 2.0																//
///////////////////////////////////////////////////////////////////////////////////////////
// 	Designed by Oxyzen
// 	UIAPI by ttMarine 
//	UC coded by Oxyzen

const       C_ANIMLOOPCOUNT = 1;
var bool    bEnchantbool;       //인챈 중
var bool    bEnchantedbool;     //인챈 완료
var int     mEnchantLevel;
var int64    mEnchantItemType;
var bool    bIsShopping;
var bool    isBreakable;

var WindowHandle Me;
var TextureHandle BackPattern;
var TextBoxHandle InstructionTxt;
var ItemWindowHandle EnchantScriptSlot;
var ItemWindowHandle EnchantItemSlot;
var ItemWindowHandle CloverItemSlot;       // 보조석 슬롯 
var ItemWindowHandle EnchantedItemSlot;
var ButtonHandle EnchantBtn;
var ButtonHandle ExitBtn;
var TextureHandle Groupbox2;
var TextureHandle Groupbox1;
var TextureHandle EnchantScriptSlotBackTex;
var TextureHandle EnchantItemSlotBackTex;
var TextureHandle CloverItemSlotBackTex;
var TextureHandle EnchantedItemSlotBackTex;
var TextureHandle DropHighlight_enchantitem;
var TextureHandle DropHighlight_enchantscript;
var TextureHandle DropHighlight_CloverItem;

var AnimTextureHandle EnchantProgressAnim;

var ProgressCtrlHandle	m_hItemEnchantWndEnchantProgress;

var ItemWindowHandle InventoryItem;

var TextBoxHandle WarningTxt;

// 변수 목록
var ItemInfo 		SelectItemInfo;		// 무기 등 아이템
var ItemInfo		SelectHelperItemInfo;//보조석 
var ItemInfo        scrolltemInfo;      //스크롤 아이템 

var ItemInfo 		tempSelectItemInfo;		// 무기 등 아이템
var ItemInfo		tempSelectHelperItemInfo;//보조석 
var ItemInfo        tempscrolltemInfo;      //스크롤 아이템 

//var ItemID	 		SupportID;
var int 			ScrollCID;			// 스크롤의 종류를 저장한다. 
//var int 			mEnchantScrollID;

var bool            bRequestScroll;         // 스크롤 아이템 변경 리퀘스트 중
var bool            bRequestEnchant;        // 인첸 아이템 변경 리퀘스트 중
var bool            bRequestSupport;        // 보조석 아이템 변경 리퀘스트 중
var bool            bRequestRemoveSupport;  // 보조석 아이템 삭제 리퀘스트 중

///다이얼로그 추가	
const DLG_ID_CRASH_ALERT=1;

// 아이템 인챈트=0, 아가시온 성장=1
var int uiType;

function OnLoad()
{
	SetClosingOnESC();	
	
	Me = GetWindowHandle( "ItemEnchantWnd" );
	EnchantProgressAnim = GetAnimTextureHandle (  "ItemEnchantWnd.EnchantProgressAnim"  );
	BackPattern = GetTextureHandle (  "ItemEnchantWnd.BackPattern"  );
	InstructionTxt = GetTextBoxHandle (  "ItemEnchantWnd.InstructionTxt"  );
	EnchantScriptSlot = GetItemWindowHandle (  "ItemEnchantWnd.EnchantScriptSlot"  );
	EnchantItemSlot = GetItemWindowHandle (  "ItemEnchantWnd.EnchantItemSlot"  );
	CloverItemSlot = GetItemWindowHandle (  "ItemEnchantWnd.CloverItemSlot"  );
	EnchantedItemSlot = GetItemWindowHandle (  "ItemEnchantWnd.EnchantedItemSlot"  );
	EnchantBtn = GetButtonHandle (  "ItemEnchantWnd.EnchantBtn"  );
	ExitBtn = GetButtonHandle (  "ItemEnchantWnd.ExitBtn"  );
	Groupbox2 = GetTextureHandle (  "ItemEnchantWnd.Groupbox2"  );
	Groupbox1 = GetTextureHandle (  "ItemEnchantWnd.Groupbox1"  );
	EnchantScriptSlotBackTex = GetTextureHandle (  "ItemEnchantWnd.EnchantScriptSlotBackTex"  );
	EnchantItemSlotBackTex = GetTextureHandle (  "ItemEnchantWnd.EnchantItemSlotBackTex"  );
	CloverItemSlotBackTex = GetTextureHandle (  "ItemEnchantWnd.CloverItemSlotBackTex"  );
	EnchantedItemSlotBackTex = GetTextureHandle (  "ItemEnchantWnd.EnchantedItemSlotBackTex"  );
	DropHighlight_enchantitem = GetTextureHandle (  "ItemEnchantWnd.DropHighlight_enchantitem"  );
	DropHighlight_enchantscript = GetTextureHandle (  "ItemEnchantWnd.DropHighlight_enchantscript"  );
	DropHighlight_CloverItem = GetTextureHandle (  "ItemEnchantWnd.DropHighlight_CloverItem"  );
	
	m_hItemEnchantWndEnchantProgress=GetProgressCtrlHandle("ItemEnchantWnd.EnchantProgress");

	InventoryItem	= GetItemWindowHandle( "InventoryWnd.InventoryItem");

	WarningTxt = GetTextBoxHandle (  "ItemEnchantWnd.WarningTxt"  );
	
	Initialize();
	Load();
}

function onShow()
{ 
	// 지정한 윈도우를 제외한 닫기 기능 
	getInstanceL2Util().ItemRelationWindowHide(getCurrentWindowName(String(self)), "InventoryWnd");
	WarningTxt.HideWindow();
	
	// 레시피를 사용할 것인지를 물을 때
	// 아이템사용 시 지정된 팝업메시지를 띄울 때
	// 아이템을 바닥에 버릴 때(한개)
	// 아이템을 바닥에 버릴 때(여러개, 개수를 물어본다)
	// 아이템을 바닥에 버릴 때(MoveAll 상태일 때)
	// 아이템을 휴지통에 버릴 때(한개)
	// 아이템을 휴지통에 버릴 때(MoveAll 상태일 때)
	// 아이템을 휴지통에 버릴 때(여러개, 개수를 물어본다)
	// 아이템을 결정화 할때
	// 결정화가 불가능하다는 경고
	// 펫인벤에서 아이템이 드롭되었을 때

	// 해당 id로 열린 다이얼로그 박스가 인챈트 창을 열었을때 열려 있다면..
	// QA 요청 사항 : QA 김환수 요청
	switch(DialogGetID())
	{
		case 1111  :
		case 2222  :
		case 3333  :
		case 4444  :
		case 5555  :
		case 6666  :
		case 7777  :
		case 8888  :
		case 9998  :
		case 9999  :
		case 10000 : DialogHide(); break;
	}
}

function Initialize()
{
	bEnchantbool = false;
	bEnchantedbool = false;
	bIsShopping = false;
	
	//~ Me = GetHandle( "ItemEnchantWnd" );
	//~ EnchantProgressAnim = AnimTextureHandle ( GetHandle( "ItemEnchantWnd.EnchantProgressAnim" ) );
	//~ BackPattern = TextureHandle ( GetHandle( "ItemEnchantWnd.BackPattern" ) );
	//~ InstructionTxt = TextBoxHandle ( GetHandle( "ItemEnchantWnd.InstructionTxt" ) );
	//~ EnchantScriptSlot = ItemWindowHandle ( GetHandle( "ItemEnchantWnd.EnchantScriptSlot" ) );
	//~ EnchantItemSlot = ItemWindowHandle ( GetHandle( "ItemEnchantWnd.EnchantItemSlot" ) );
	//~ CloverItemSlot = ItemWindowHandle ( GetHandle( "ItemEnchantWnd.CloverItemSlot" ) );
	//~ EnchantedItemSlot = ItemWindowHandle ( GetHandle( "ItemEnchantWnd.EnchantedItemSlot" ) );
	//~ EnchantBtn = ButtonHandle ( GetHandle( "ItemEnchantWnd.EnchantBtn" ) );
	//~ ExitBtn = ButtonHandle ( GetHandle( "ItemEnchantWnd.ExitBtn" ) );
	//~ Groupbox2 = TextureHandle ( GetHandle( "ItemEnchantWnd.Groupbox2" ) );
	//~ Groupbox1 = TextureHandle ( GetHandle( "ItemEnchantWnd.Groupbox1" ) );
	//~ EnchantScriptSlotBackTex = TextureHandle ( GetHandle( "ItemEnchantWnd.EnchantScriptSlotBackTex" ) );
	//~ EnchantItemSlotBackTex = TextureHandle ( GetHandle( "ItemEnchantWnd.EnchantItemSlotBackTex" ) );
	//~ CloverItemSlotBackTex = TextureHandle ( GetHandle( "ItemEnchantWnd.CloverItemSlotBackTex" ) );
	//~ EnchantedItemSlotBackTex = TextureHandle ( GetHandle( "ItemEnchantWnd.EnchantedItemSlotBackTex" ) );
	//~ DropHighlight_enchantitem = TextureHandle ( GetHandle( "ItemEnchantWnd.DropHighlight_enchantitem" ) );
	//~ DropHighlight_enchantscript = TextureHandle ( GetHandle( "ItemEnchantWnd.DropHighlight_enchantscript" ) );
}

function OnRegisterEvent()
{
	RegisterEvent( EV_EnchantShow );                //2860
	RegisterEvent( EV_EnchantHide );	            //2865
	RegisterEvent( EV_EnchantResult );              //2870
	RegisterEvent( EV_EnchantPutTargetItemResult ); //2880
	RegisterEvent( EV_EnchantPutSupportItemResult );//2881
	RegisterEvent( EV_EnchantPutScrollItemResult ); //2882
	RegisterEvent( EV_EnchantRemoveSupportItemResult );//2883
	RegisterEvent( EV_DialogOK);
	RegisterEvent( EV_DialogCancel);
	 
}

function Load()
{
}


function handleShowDialog()
{
	class'UICommonAPI'.static.DialogSetID( DLG_ID_CRASH_ALERT );	
	DialogSetCancelD(DLG_ID_CRASH_ALERT);

	if(isAGScrollState())
	{
		// 파괴 주의 경고! 아가시온 성장 실패 시 아이템이 파괴 됩니다. 계속 진행하시겠습니까?
		class'UICommonAPI'.static.DialogShow(DialogModalType_Modalless, DialogType_OKCancel, GetSystemMessage( 4507 ), string(Self) );	
	}
	else
	{
		// 파괴(결정화) 주의 경고!\n\n인챈트 실패 시 아이템이 파괴 또는 결정화됩니다.
		class'UICommonAPI'.static.DialogShow(DialogModalType_Modalless, DialogType_OKCancel, GetSystemMessage( 4149 ), string(Self) );	
	}
}

function OnClickButton( string Name )
{
	//Debug( "OnClickButton"  @ Name);
	switch( Name )
	{
	case "EnchantBtn":

		checkEventWarningText();
		
		//인챈 완료시 인첸 버튼을 클릭 했을 때
		if ( bEnchantedbool )
		{
			//맨 처음 스텝으로 감
			HandleGoToFirstStep();
			//EnchantedItemSlot;
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
				//EnchantScriptSlot.DisableWindow();
				//EnchantItemSlot.DisableWindow();				
			}
			
			else OnEnchantBtnClick();
		}
		break;
	case "ExitBtn":
		if ( bEnchantbool ) //인챈 중이면 애니메이션 중지 하고 원래 아이콘 상태로 으로
		{
			HandleGoToFirstStep();

			if( class'UICommonAPI'.static.DialogIsOwnedBy( string(Self) ))
				DialogHide();
			//ResetUI();
		}
		else //if (!bEnchantedbool) //인챈 완료가 아니면 취소 신청
		{
			class'EnchantAPI'.static.RequestExCancelEnchantItem();
			//ProcCancel();
		}/*
		else 
		{
			Me.HideWindow(); //인챈 끝났으면 닫기
		}*/
		break;
	}
	
}

function OnEvent(int Event_ID, string param)
{
	// Debug("OnEvent" @ Event_ID @ param);
	if (Event_ID == EV_EnchantShow) //2860
	{
		// Debug("param" @ param);
		if(!bIsShopping)
		{
			HandleEnchantShow(param);
		}
		else
		{
			class'EnchantAPI'.static.RequestExCancelEnchantItem();
		}
	}
	else if (Event_ID == EV_EnchantResult) //2890
	{
		HandleEnchantResult(param);
	}
	else if ( Event_ID == EV_EnchantPutTargetItemResult) //2880
	{
		HandlePutTargetItemResult(param);
		//~ debug ("EnchantLevel" @ mEnchantLevel);
	}
	else if ( Event_ID ==  EV_EnchantPutSupportItemResult ) //2892
	{
		//debug ("Support Item Received" @ param);
		HandlePutSupportItemResult(param);
	}

	else if ( Event_ID == EV_EnchantRemoveSupportItemResult )//2883
	{
		removeSupportItm();	
	}

	else if ( Event_ID == EV_EnchantPutScrollItemResult )//2882
	{
		HandlePutScrollResult( param );	
	}
	else if ( Event_ID == EV_DialogOK )
	{	
		HandleDialogResult(true);		
	}
	else if ( Event_ID == EV_DialogCancel  )
	{		
		HandleDialogResult(false);
	}
}


function HandleDialogResult(bool bOk)
{
	local int DlgID;
	///local int Reserved;

	if(!class'UICommonAPI'.static.DialogIsOwnedBy( string(Self) ))
		return;

	Me.setFocus();

	if (bOk)
	{
		DlgID = class'UICommonAPI'.static.DialogGetID();
				
		//Reserved = class'UICommonAPI'.static.DialogGetReservedInt();

		switch(DlgID)
		{
			case DLG_ID_CRASH_ALERT :
				HandleDlGCrashAlert(bOk);
				break;		
		}
	}
	else
	{
		if(DialogCheckCancelByID(DLG_ID_CRASH_ALERT))
		{
			HandleDlGCrashAlert(bOk);
		}
	}
}

function HandleDlGCrashAlert( bool bOk )
{
	//CloverItemSlot.EnableWindow();
	//EnchantScriptSlot.EnableWindow();
	//EnchantItemSlot.EnableWindow();
	ExitBtn.EnableWindow();

	if ( bOK)
	{
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
		OnEnchantBtnClick();
	}
	else 
	{
		bEnchantbool = false;
		EnchantBtn.EnableWindow();
	}
}

// 아가시온 성장 스크롤 상태인가?
function bool isAGScrollState()
{
	// 아가시온 성장
	if(uiType == 1)	return true;

	return false;
}

// 아가시온 성장 스크롤 상태인가?
function bool isAGScrollType(EEtcItemType Type)
{
	if (Type == ITEME_ENCHT_AG || Type == ITEME_BLESS_ENCHT_AG || Type == ITEME_MULTI_ENCHT_AG || Type == ITEME_ANCIENT_CRYSTAL_ENCHANT_AG)
	{
		return true;
	}
	return false;
}

function setTitleByItemType( EEtcItemType Type )
{	
	// 아가시온 관련 
	// 아가시온 강화 주문서, 축복받은 아가시온 강화, 거인의 아가시온 강화 주문서
	if (Type == ITEME_ENCHT_AG || Type == ITEME_BLESS_ENCHT_AG || Type == ITEME_MULTI_ENCHT_AG || Type == ITEME_ANCIENT_CRYSTAL_ENCHANT_AG)
	{
		// 아가시온 성장
		Me.SetWindowTitle(GetSystemString(3639));
		uiType = 1;
	}
	else
	{
		// 아이템 인챈트
		Me.SetWindowTitle(GetSystemString(1220));
		uiType = 0;
	}
}

function int getFailStringNum( EEtcItemType Type )
{	
	// 클래식 버젼에서도 메시지가 출력 되도록 수정
	//debug ( "getFailString" @ Type );
	/*if ( getInstanceUIData().getIsClassicServer() ) 
	{
		return -1;
	}
	//ttp 63816 으로 거인의 강화 주문서 실패시 깨질 수 있음


	else */if ( Type == ITEME_ENCHT_WP || Type == ITEME_ENCHT_AM || Type == ITEME_MULTI_ENCHT_WP || Type == ITEME_MULTI_ENCHT_AM )
	{
		// 일반 무기 강화 주문서		
		// 실패 시 아이템이 '파괴(결정화)'됩니다.
		return 4143;
	}
	else if ( Type == ITEME_BLESS_ENCHT_WP || Type == ITEME_BLESS_ENCHT_AM )
	{		
		//축복 받은 무기 강화 주문서
		// 실패 시 +0으로 인챈트가 '초기화'됩니다.
		return 4144;
	}
	else if (Type == ITEME_ENCHT_ATTR_CRYSTAL_ENCHANT_AM || Type == ITEME_ENCHT_ATTR_CRYSTAL_ENCHANT_WP )
	{
		return -1;
	}
	else if (Type == ITEME_ENCHT_ATTR_ANCIENT_CRYSTAL_ENCHANT_AM || Type == ITEME_ENCHT_ATTR_ANCIENT_CRYSTAL_ENCHANT_WP )
	{
		// 파멸의 강화 주문서
		// 실패 시 현재 인챈트 수치가 '유지'됩니다.
		return 4145;
	}
	// 아가시온 관련 
	// 아가시온 강화 주문서, 거인의 아가시온 강화 주문서
	else if (Type == ITEME_ENCHT_AG || Type == ITEME_MULTI_ENCHT_AG)
	{
		// 실패 시 아가시온이 소멸됩니다.
		return 4506;
	}
	// 축복 받은 아가시온 강화 주문서
	else if (Type == ITEME_BLESS_ENCHT_AG)
	{
		// 실패 시 아가시온의 성장 수치가 ‘초기화’됩니다.
		return 4508;
	}
	// 파멸의 아가시온 강화 주문서
	else if (Type == ITEME_ANCIENT_CRYSTAL_ENCHANT_AG)
	{
		// 실패 시 아가시온의 성장 수치가 ‘유지’됩니다.
		return 4509;
	}

	

	return -1;
}

function checkWarningTxt()
{
	local bool isCanUseSupportMinLv;
	local bool isNot100PerSuccess;
	local EEtcItemType EEtcItemType;
	local int failStringNum ;

	WarningTxt.HideWindow();

	EEtcItemType = EEtcItemType( scrolltemInfo.ItemSubType );

	isCanUseSupportMinLv = mEnchantLevel > getEnchantedItemMini();

	isNot100PerSuccess = CheckEnableCloverSlot(ScrollCID) ;

	failStringNum = getFailStringNum(EEtcItemType);

	//Debug("failStringNum : " @ failStringNum);
	//Debug("failString    : " @ GetSystemMessage(failStringNum));
	//Debug("isCanUseSupportMinLv" @ isCanUseSupportMinLv);
	//Debug("isNot100PerSuccess" @ isNot100PerSuccess);

	// 라이브, 망토 강화 주문서
	if(scrolltemInfo.Id.ClassID == 28593 ||
		scrolltemInfo.Id.ClassID == 28594 ||
		scrolltemInfo.Id.ClassID == 28595)
	{
		WarningTxt.SetText(GetSystemMessage(4278));
		WarningTxt.ShowWindow();

		// 결정화된다는 경고 다이얼로그 나오도록 
		isBreakable = false;
	}
	// 안정된 망토 강화 주문서 - 전설
	else if(scrolltemInfo.Id.ClassID == 28766)
	{
		// 실패 시 현재 인챈트 수치가 '유지' 됩니다.
		WarningTxt.SetText(GetSystemMessage(4145));
		WarningTxt.ShowWindow();

		// 결정화된다는 경고 다이얼로그 나오도록 
		isBreakable = false;
	}
	// 클래식, 망토 강화 주문서
	else if(scrolltemInfo.Id.ClassID == 70885 ||
		scrolltemInfo.Id.ClassID == 70886 ||
		scrolltemInfo.Id.ClassID == 70887)
	{
		WarningTxt.SetText(GetSystemMessage(4278));
		WarningTxt.ShowWindow();

		// 결정화된다는 경고 다이얼로그 나오도록 
		isBreakable = false;
	}
	else
	{
		if(isCanUseSupportMinLv && isNot100PerSuccess && failStringNum != -1)  /*&& !getInstanceUIData().getIsClassicServer()) */
		{
			//Debug("출력");
			WarningTxt.SetText(GetSystemMessage(failStringNum));
			WarningTxt.ShowWindow();
		}
	}
}

function int getEnchantedItemMini()
{
	local int EnchantedItemMini ;
	
	//Debug ("getEnchantedItemMini" @ ScrollCID );
	// 1부터 깨질 위험이 있음, "실패 시 +0으로 인챈트가 '초기화' 됩니다. 

	if ( ScrollCID  == 48211 ||    // 축복받은 서클릿 강화 주문서
		 ScrollCID  == 48264 ||    // 혈맹 망토 강화 주문서
		 ScrollCID  == 48265 ||    // 거인의 혈맹 망토 강화 주문서

		 ScrollCID  == 48498 ||      // 축복받은 드래곤 셔츠 강화 주문서		 

		 // -- 1부터 깨질 위험이 있음
		 // 축복받은 서클릿 강화 주문서
		 // 망토 강화 주문서
		 // 망토 강화 주문서 - 전설
		 // 고대 망토 강화 주문서 - 전설
		ScrollCID  == 48211 || ScrollCID  == 28593 || ScrollCID  == 28594 || ScrollCID  == 28595 ||

		// 클래식, 망토 강화 주문서
		ScrollCID  == 70885 || ScrollCID  == 70886 || ScrollCID  == 70887

		) 
	{
		EnchantedItemMini = 0;		
	}
	//원 피스 아이템일 경우 4부터 보조석
	else if ( mEnchantItemType == 32768 ) 
	{
		EnchantedItemMini = 3;		
	}
	else 
	{
		EnchantedItemMini = 2;
	}
	return EnchantedItemMini;
}

// 강화시, 깨진다고 다이얼로그 경고 뜨는 것에 대한 설정
function bool getIsBreakable()
{
	local EEtcItemType EEtcItemType;
	local bool isCanUseSupportMinLv;	
	
	EEtcItemType = EEtcItemType( scrolltemInfo.ItemSubType );

	isCanUseSupportMinLv = mEnchantLevel > getEnchantedItemMini();	

	// 해외 : 레벨 1부터 파쇄 되는 팬던트 아이템 추가
	//Debug ( "getIsBreakable" @ SelectItemInfo.ID.classID );
	if ( SelectItemInfo.ID.classID == 29704 || SelectItemInfo.ID.classID == 29705 || SelectItemInfo.ID.classID == 29706 || SelectItemInfo.ID.classID == 29707 )
		return true;

	//// 신성한 별자리 아가시온 성장의 서
	//if (scrolltemInfo.ID.classID == 48323)
	//	return false;

	//// 안정된 아가시온 강화 주문서(ID: 90963) , 클래식
	//if (scrolltemInfo.ID.classID == 90963)
	//	return false;


	return isCanUseSupportMinLv && ( EEtcItemType == ITEME_ENCHT_WP || EEtcItemType == ITEME_ENCHT_AM || 
									 EEtcItemType == ITEME_MULTI_ENCHT_WP || EEtcItemType == ITEME_MULTI_ENCHT_AM ||
									 // 아가시온 강화 추가 (2016-11-25)
									 EEtcItemType == ITEME_ENCHT_AG || EEtcItemType == ITEME_MULTI_ENCHT_AG 
									 //EEtcItemType == ITEME_ENCHT_AG || EEtcItemType == ITEME_BLESS_ENCHT_AG || EEtcItemType == ITEME_MULTI_ENCHT_AG || EEtcItemType == ITEME_ANCIENT_CRYSTAL_ENCHANT_AG
									);
}

function handleCloverSlot()
{
	local bool isCanUseSupportMinLv, bEnableCloverSlot;	
	local ItemInfo invenSupportInfo;
	
	getEnchantedItemMini();
	checkWarningTxt();
	isCanUseSupportMinLv = mEnchantLevel > getEnchantedItemMini();
	
	//ttp 63816 으로 거인의 강화 주문서 실패시 깨질 수 있음
	isBreakable = getIsBreakable();
	
	//클래식 서버 BM 설정을 위한 보조석 오픈 
	// 국내 16 이상 제한 조건은 삭제 되었습니다. 20160204 ~LDW	
	// 아가시온 스크롤인 경우 보조석이 보이지 않습니다. 20170315 ~LDW
	if ( isCanUseSupportMinLv ) 
	{
		if ( getInstanceUIData().getIsClassicServer() ) 
			bEnableCloverSlot = checkEnableCloverSlotClassic( ScrollCID ) && !isAGScrollType( EEtcItemType( scrolltemInfo.ItemSubType ) ) ;
		else 
			bEnableCloverSlot = CheckEnableCloverSlot(ScrollCID) && !CheckScrollType(ScrollCID) && !isAGScrollType( EEtcItemType( scrolltemInfo.ItemSubType ) ) ; 
	}

	//Debug("bEnableCloverSlot" @bEnableCloverSlot);
	
	 // 인챈트 보조석 기능 추가 : 보조석 사용 가능 최대 인챈트 레벨을 9에서 15로 확장합니다. - gorillazin
	if ( bEnableCloverSlot )	// branch 신성한 무기 강화 결정 처럼 일정 구간에서 100%의 확률로 인챈트가 성공하는 스크롤의 경우 강화 보조석 슬롯을 disable 합니다. - gorillazin 11.09.27.
	//
	{
		EnableCloverSlot();
		
		//인벤토리에서 서폿 아이템을 찾음
		InventoryItem.GetItem(InventoryItem.FindItem( SelectHelperItemInfo.ID ), invenSupportInfo);
		
		// 2014.03.11 9까지 인것 외에도 체크 하도록 수정		
		// 인벤토리 안의 아이템 개수가 0 개 이상일 경우에만 시도 하도록 수정
		if ( invenSupportInfo.itemNum > 0 )// && mEnchantLevel > 9)  
		{
			bRequestSupport = true;
			EnchantBtn.DisableWindow();
			class'EnchantAPI'.static.RequestExTryToPutEnchantSupportItem( invenSupportInfo.ID, SelectItemInfo.ID );
		}
		else 
		{
			RequestExRemoveEnchantSupportItem();
		}
	}
	else
	{
		DisableCloverSlot();
	}	
}

function HandleInstructionTxt()
{
	local int systemMessage;
	//스크롤이 비었을 때
	//4146 : 

	//아이템이 비었을 때
	//2339 : 인챈트 할 아이템을 올려놓으십시오.

	//스크롤과 아이템이 찼을 때
	//2341 : 아래의 시작 버튼을 누르면 인챈트가 시작 됩니다. 

	//보조석 활성 화 시
	//2940 : +3에서 +9까지 인챈트 된 아이템에는 인챈트 확률 증가 아이템을 사용 할 수 있습니다.

	//아이템 타입이 mEnchantItemType == 32768 일 경우 
	//3149 : 상하의 일체형 방어구에는 +4부터 인챈트 확률 증가 아이템을 사용할 수 있습니다.

	//스크롤 아이템이 없을 때
	if ( scrolltemInfo.itemNum < 1 ) 
	{
		//강화 주문서를 등록해주세요.
		systemMessage = 4146;
	}
	else if ( SelectItemInfo.itemNum < 1 )
	{
		if(isAGScrollType(EEtcItemType(scrolltemInfo.ItemSubType)))
		{
			//성장시킬 아가시온을 등록해 주세요.
			systemMessage = 4504;
		}
		else
		{
			//인챈트 할 아이템을 올려놓으십시오.		
			systemMessage = 2339;
		}
	}
	//보조석이 활성화 되어 잇다면
	else if ( CloverITemSlot.IsShowWindow() )
	{
		 //아이템 타입이 일체형 일 경우
		if (mEnchantItemType == 32768)
		{
			//상하의 일체형 방어구에는 +4부터 인챈트 확률 증가 아이템을 사용할 수 있습니다.
			systemMessage = 3149;
		}
		else
		{
			// 1207 업데이트에는 보조석이 없기 때문에 작동 안되게 해야 해서 추가 안함 (시스템 메세지도 제작이 안되서..)
			if (isAGScrollState())
			{
				//
			}
			else
			{
				//..
			}

			//+3에서 +9까지 인챈트 된 아이템에는 인챈트 확률 증가 아이템을 사용 할 수 있습니다.
			systemMessage = 2940;
		}
	}
	else 
	{
		if(isAGScrollState())
		{
			// 아가시온의 성장을 진행하시려면 시작 버튼을 눌러주세요.
			systemMessage = 4505;
		}
		else
		{
			//아래의 시작 버튼을 누르면 인챈트가 시작 됩니다.
			systemMessage = 2341;
		}
	}		

	InstructionTxt.SetText(GetSystemMessage( systemMessage ));
}	

function HandleHighlight()
{
		DropHighlight_enchantitem.SetTexture("L2UI_ch3.RefineryWnd.refineslot2");
		DropHighlight_enchantscript.SetTexture("L2UI_ch3.RefineryWnd.refineslot2");
		DropHighlight_CloverItem.SetTexture("L2UI_ch3.RefineryWnd.refineslot2");

//		Debug( "HandleHighlight" @ scrolltemInfo.itemNum @  SelectHelperItemInfo.itemNum @  SelectItemInfo.itemNum);
		if ( scrolltemInfo.itemNum < 1 ) 
		{ 
			DropHighlight_enchantitem.SetTexture("L2UI_ch3.RefineryWnd.refineslot1");
		}
		else if ( SelectItemInfo.itemNum < 1 )
		{
			DropHighlight_enchantscript.SetTexture("L2UI_ch3.RefineryWnd.refineslot1");
		}
		else if (  SelectHelperItemInfo.itemNum < 1 )		
		{
			DropHighlight_CloverItem.SetTexture("L2UI_ch3.RefineryWnd.refineslot1");
		}
}


function HandlePutTargetItemResult(string param)
{
	local int ResultID;
	ParseInt(Param, "Result", ResultID);	

	bRequestEnchant = false;
	
	if (ResultID==0)
	{			
		//맞는 무기가 아닙니다. 
		//class'EnchantAPI'.static.RequestExCancelEnchantItem(); //이걸 실행 한 뒤 2890 이벤트 발생		
	}
	else
	{		
		SelectItemInfo = tempSelectItemInfo;
		EnchantItemSlot.SetItem( 0, SelectItemInfo );
		EnchantItemSlot.AddItem( SelectItemInfo );
//		InstructionTxt.SetText(GetSystemMessage(2341));
		//~ DropHighlight_enchantitem.HideWindow();
		//DropHighlight_enchantitem.SetTexture("L2UI_ch3.RefineryWnd.refineslot2");
		//DropHighlight_enchantscript.SetTexture("L2UI_ch3.RefineryWnd.refineslot2");
		//~ DropHighlight_CloverItem.SetTexture("L2UI_ch3.RefineryWnd.refineslot2");
		//debug("====> " @ mEnchantItemType);
		//debug("ScrollCID ==>" @ ScrollCID);

		handleCloverSlot();

		HandleHighlight();	
		HandleInstructionTxt();
		//checkEnchantBtn();
		
		EnchantScriptSlotBackTex.HideWindow();
		EnchantItemSlotBackTex.HideWindow();

		
		//~ CloverItemSlotBackTex.HideWindow();
		//~ EnchantedItemSlotBackTex.HideWindow();
	}
	checkEnchantBtn();
}


//스크롤 아이콘을 바꾼다.
function HandlePutScrollResult( string param)
{
	local int ResultID;	
	ParseInt(Param, "Result", ResultID);	

//	debug("HandlePutScrollResult" @ Param) ;

	bRequestScroll = false;		

	if (ResultID==0) 
	{
		
	}
	else 
	{	
		scrolltemInfo = tempscrolltemInfo;
		scrolltemInfo.bShowCount = true;
		EnchantScriptSlot.Clear();
		EnchantScriptSlot.SetItem( 0, scrolltemInfo );
		EnchantScriptSlot.AddItem( scrolltemInfo );	

		ScrollCID = scrolltemInfo.ID.classID;

		handleCloverSlot();	
		EnchantScriptSlotBackTex.hideWindow();	
		Playsound("ItemSound3.enchant_input");

		HandlecheckisMatchScrollSupport ( EEtcItemType( scrolltemInfo.ItemSubType ) , EEtcItemType( SelectHelperItemInfo.ItemSubType ));		
		HandleHighlight();
		HandleInstructionTxt();

		setTitleByItemType(EEtcItemType( scrolltemInfo.ItemSubType ));
	}

	
	/*
	 *주문서 교체할 경우 서폿 아이템이 맞는지 체크 함. 22일 버젼에는 서버에서 직접 처리 하는 것으로 수정 할 예정임	
	if (SelectHelperItemInfo.itemNum > 0)  
	{				
		bRequestSupport = true;
		class'EnchantAPI'.static.RequestExTryToPutEnchantSupportItem( SelectHelperItemInfo.ID, SelectItemInfo.ID );			
	}*/

	checkEnchantBtn();
	
}

function HandlePutSupportItemResult(string param)
{
	local int ResultID;

	local ItemInfo invenSupportInfo;

	ParseInt(Param, "Result", ResultID);

	bRequestSupport = false;
	

	// Debug("param : " @ param);

	if (ResultID==0)
	{		
		//맞는 강화석이 아닙니다.
		//서폿 아이템이 0보다 클 경우 +9 까지 되는 것과 +15 까지 지원 하는 것이 있음. 그걸 걸러 내기 위해
		RequestExRemoveEnchantSupportItem();
	}
	else
	{
		SelectHelperItemInfo = tempSelectHelperItemInfo;
		SelectHelperItemInfo.bShowCount = true;

		InventoryItem.GetItem(InventoryItem.FindItem( SelectHelperItemInfo.ID ), invenSupportInfo);//d
		SelectHelperItemInfo.ItemNum = invenSupportInfo.itemNum;

		CloverITemSlot.SetItem( 0, SelectHelperItemInfo );
		CloverITemSlot.AddItem( SelectHelperItemInfo );
		//~ DropHighlight_enchantitem.HideWindow();
		
		//EnchantScriptSlotBackTex.HideWindow();
		//EnchantItemSlotBackTex.HideWindow();
		CloverItemSlotBackTex.HideWindow();
		HandlecheckisMatchScrollSupport ( EEtcItemType( scrolltemInfo.ItemSubType ) , EEtcItemType( SelectHelperItemInfo.ItemSubType ));
		isBreakable = getIsBreakable();
		HandleHighlight();		
		checkWarningTxt();
		checkEventWarningText();
	}	
	checkEnchantBtn();
}

/*
 *둘다 축복 받은 이거나 둘다 일반 일 경우에만 보조석을 남겨 둠
 *Multi 타입 추가
 */
function HandlecheckisMatchScrollSupport( EEtcItemType scrollSubType , EEtcItemType supportSubType )
{
	local bool bool1;
	local bool bool2;
	
	if (SelectHelperItemInfo.itemNum < 1 )  return;

	bool1 = ( supportSubType == ITEME_BLESS_INC_PROP_ENCHT_WP || supportSubType == ITEME_BLESS_INC_PROP_ENCHT_AM );
	bool2 = ( scrollSubType == ITEME_BLESS_ENCHT_WP || scrollSubType == ITEME_BLESS_ENCHT_AM );

	if ( !bool1 && !bool2 )
	{
		bool1 = ( supportSubType == ITEME_MULTI_INC_PROB_ENCHT_WP || supportSubType == ITEME_MULTI_INC_PROB_ENCHT_AM );
		bool2 = ( scrollSubType == ITEME_MULTI_ENCHT_WP || scrollSubType == ITEME_MULTI_ENCHT_AM );		
	}

	//Debug("HandlecheckisMatchScrollSupport" @ bool1 @ bool2 );
	if  ( bool1 != bool2 )
	{
		//Debug("HandlecheckisMatchScrollSupport 보조석 제거" @ supportSubType @  scrollSubType);
		RequestExRemoveEnchantSupportItem();		
	} 
}

function removeSupportItm()
{
	local ItemInfo EmptyInfo;
	
	bRequestRemoveSupport = false;

	SelectHelperItemInfo = EmptyInfo;
	CloverItemSlot.Clear();

	HandleHighlight();
	//서폿 아이템에 의해 isBreakable 가 true 될 경우 때문에
	isBreakable = getIsBreakable();
	//ttp 64083 보조석이 삭제 됐을 때 경고 문구를 바꾸는 예외 처리가 되어 있지 않음.
	//handleCloverSlot();	
	checkWarningTxt();
	checkEventWarningText();
	HandleInstructionTxt();

	checkEnchantBtn();
}

function HandleGoToFirstStep()
{	
	//local ItemInfo EmptyInfo;
	local ItemInfo invenScrollInfo;
	local ItemInfo invenSupportInfo;

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

	EnchantScriptSlot.DisableTick();
	EnchantItemSlot.DisableTick();
	CloverItemSlot.DisableTick();
	EnchantedItemSlot.DisableTick();

	EnchantedItemSlot.Clear();

	//EnchantScriptSlotBackTex.ShowWindow();
	//EnchantItemSlotBackTex.ShowWindow();
	
	InventoryItem.GetItem(InventoryItem.FindItem( scrolltemInfo.ID ), invenScrollInfo);//d
	scrolltemInfo.ItemNum = invenScrollInfo.itemNum;//인벤에 있는 수량

	ScrollCID = scrolltemInfo.ID.classID;
	//Debug( "goto" @ scrolltemInfo.itemNum @  SelectHelperItemInfo.itemNum);

	//스크롤을 다 썼을 때( 완료 시점 ), 인챈 중 취소 시도 실행 하는데 그 때는 itemNum 값이 0일리 없다. 그래서 scrolltemInfo = EmptyInfo는 주석 처리 함.
	if ( scrolltemInfo.itemNum == 0 ) 
	{	
		//Debug(" step1");
		//scrolltemInfo = EmptyInfo;
		//SelectHelperItemInfo = EmptyInfo;
		EnchantScriptSlot.Clear();		
		DisableCloverSlot();		
		EnchantScriptSlotBackTex.ShowWindow();
	} 
	else
	{	
		//계속을 클릭 할 경우 아이템 인챈트 조건이 달라지므로, 조건 검사를 다시 함.
		handleCloverSlot();
		EnchantScriptSlot.SetItem(0, scrolltemInfo);
		 //아래 내용 들이 handleCloverSlot() 안에 있음
		InventoryItem.GetItem(InventoryItem.FindItem( SelectHelperItemInfo.ID ), invenSupportInfo);//d
		SelectHelperItemInfo.ItemNum = invenSupportInfo.itemNum;
		//Debug("gotoFirst" @ SelectHelperItemInfo.ItemNum );
		if ( SelectHelperItemInfo.ItemNum == 0 )
		{			
			class'EnchantAPI'.static.RequestExRemoveEnchantSupportItem();
			//removeSupportItm();
			//SelectHelperItemInfo = EmptyInfo;
		}
		else 
		{		
			CloverItemSlot.SetItem(0, invenSupportInfo);
		}
	}

	HandleHighlight();
	HandleInstructionTxt();
	checkEnchantBtn();
	ExitBtn.SetNameText( GetSystemString(646) );
	EnchantBtn.SetNameText( GetSystemString(428) );

	checkEventWarningText();
}

function OnEnchantBtnClick()
{
	local Rect Item1Rect;
	local Rect Item2Rect;
	local Rect Item3Rect;
	local Rect ResultRect;	
	
	EnchantProgressAnim.SetLoopCount( C_ANIMLOOPCOUNT );
	EnchantProgressAnim.Stop();
	EnchantProgressAnim.Play();
	Playsound("ItemSound3.enchant_process");
	EnchantProgressAnim.ShowWindow();	

	DropHighlight_enchantitem.SetTexture("L2UI_ch3.RefineryWnd.refineslot2");
	DropHighlight_enchantscript.SetTexture("L2UI_ch3.RefineryWnd.refineslot2");
	DropHighlight_CloverItem.SetTexture("L2UI_ch3.RefineryWnd.refineslot2");	
	
	m_hItemEnchantWndEnchantProgress.Start();
		
	Item1Rect = EnchantScriptSlot.GetRect();
	Item2Rect = EnchantItemSlot.GetRect();
	Item3Rect = CloverItemSlot.GetRect();
	ResultRect = EnchantedItemSlot.GetRect();

	EnchantScriptSlot.EnableTick();
	EnchantItemSlot.EnableTick();
	CloverItemSlot.EnableTick();

	EnchantScriptSlot.Move( ResultRect.nX - Item1Rect.nX, ResultRect.nY - Item1Rect.nY, 1.5f );
	EnchantItemSlot.Move( ResultRect.nX - Item2Rect.nX, ResultRect.nY - Item2Rect.nY, 1.5f );
	CloverItemSlot.Move( ResultRect.nX - Item3Rect.nX, ResultRect.nY - (Item3Rect.nY), 1.5f );	

	CloverItemSlotBackTex.HideWindow();
	EnchantItemSlotBackTex.HideWindow();
	EnchantedItemSlotBackTex.HideWindow();
	CloverItemSlotBackTex.HideWindow();

	ExitBtn.SetNameText( GetSystemString(141) );
	EnchantBtn.SetNameText( GetSystemString(428) );
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
			if (bEnchantbool)
			{				
				bEnchantbool = false;
				//Debug("RequestEnchantItem" @ SelectItemInfo.ID.ClassID @ SelectHelperItemInfo.ID.ClassID);
				class'EnchantAPI'.static.RequestEnchantItem(SelectItemInfo.ID, SelectHelperItemInfo.ID);
			}
			else
			{
			}
					
		break;
	}
	EnchantProgressAnim.HideWindow();
}


//~ function OnExitBtnClick()
//~ {
	//~ OnCancelClick();
//~ }

function HandleEnchantShow(string param)
{
	local ItemID cID;
	//local ItemInfo cItemInfo;

	local ItemInfo invenInfo;
	local itemInfo emptyInfo;

	//인벤에 있는 수량을 값을 가져 오기 위함.
	local int InvenItemID;;

	SelectItemInfo = emptyInfo;
	SelectHelperItemInfo = emptyInfo;

	//DropHighlight_enchantitem.SetTexture("L2UI_ch3.RefineryWnd.refineslot2");
	DropHighlight_enchantscript.SetTexture("L2UI_ch3.RefineryWnd.refineslot1");
	ParseItemID(param, cID);
	//scrolltemInfo = 
	ScrollCID = cID.ClassID;
	
	class'UIDATA_ITEM'.static.GetItemInfo(cID, scrolltemInfo);	

	bEnchantedbool = false;

	ResetUI();
	Me.ShowWindow();
	//~ EnchantBtn.ShowWindow();
	Me.SetFocus();
	ExitBtn.SetNameText( GetSystemString(646) );
	EnchantBtn.SetNameText( GetSystemString(428) );

	invenItemID = InventoryItem.FindItem( cID ); // ServerID
	InventoryItem.GetItem(invenItemID, invenInfo);//d
	scrolltemInfo.ItemNum = invenInfo.itemNum;//인벤에 있는 수량
	
	scrolltemInfo.bShowCount = true;

	//스크롤은 완료 상태 이므로
	bRequestScroll = false;
	EnchantScriptSlot.SetItem( 0, scrolltemInfo );
	EnchantScriptSlot.AddItem( scrolltemInfo );
	//~ mEnchantScrollID = cItemInfo.Id;
	Playsound("ItemSound3.enchant_input");
	//~ DropHighlight_enchantitem.ShowWindow();
	
	//if(isAGScrollType(EEtcItemType(SelectItemInfo.ItemSubType)))
	//{
	//	// 성장시킬 아가시온을 등록해 주세요.
	//	InstructionTxt.SetText(GetSystemMessage(4504));
	//}
	//else
	//{
	//	// 인챈트 할 아이템을 올려놓으십시오.
	//	InstructionTxt.SetText(GetSystemMessage(2339));
	//}
	
	HandleInstructionTxt();

	//~ BackPattern.ShowWindow();
	mEnchantLevel = 0;
	DropHighlight_CloverItem.HideWindow();

	//Debug("- 주문서 타입: scrolltemInfo.ItemSubType" @ scrolltemInfo.ItemSubType);
	// UI 타이틀 변경, "아이템 인챈트", "아가시온 인챈트", 2016-11-23 추가
	setTitleByItemType(EEtcItemType(scrolltemInfo.ItemSubType));
}

function checkEnchantBtn()
{
	//EnchantBtn의 조건 
	//시도 완료 성공 시 > result에서 처리 
	//모든 request의 답변이 왔을 때
	//슬롯 두 개가 찼을 때	
	//bEnchantbool, bEnchantedbool 이 false 때
	//EnchantBtn
	local bool isEnableEnchantBtn ;
	//debug (  "checkEnchantBtn1" @ ( !bRequestScroll && !bRequestEnchant && !bRequestSupport && !bRequestRemoveSupport ) @ ( SelectItemInfo.itemNum > 0 && scrolltemInfo.itemNum > 0 ) @  ( !bEnchantbool && !bEnchantedbool )) ;
	//debug (  "checkEnchantBtn2" @  !bRequestScroll @ !bRequestEnchant @ !bRequestSupport @ !bRequestRemoveSupport );
	//debug (  "checkEnchantBtn3" @  SelectItemInfo.itemNum @ scrolltemInfo.itemNum );


	isEnableEnchantBtn = ( !bRequestScroll && !bRequestEnchant && !bRequestSupport && !bRequestRemoveSupport ) && ( SelectItemInfo.itemNum > 0 && scrolltemInfo.itemNum > 0 ) && ( !bEnchantbool && !bEnchantedbool ) ;

	if (isEnableEnchantBtn ) 
	{
		EnchantBtn.EnableWindow();
	}
	else 
	{
		EnchantBtn.DisableWindow();
	}
}

function ResetUI()
{
	EnchantProgressAnim.HideWindow();
	EnchantProgressAnim.SetTexture("l2ui_ct1.ItemEnchant_DF_Effect_Loading_01");
	EnchantProgressAnim.HideWindow();
	BackPattern.HideWindow();
	InstructionTxt.SetText( "" );

	EnchantedItemSlot.Clear();

	EnchantedItemSlot.SetAnchor( "ItemEnchantWnd", "TopLeft", "TopLeft", 116, 90 );
	EnchantedItemSlot.SetWindowSize(34,34);
	EnchantedItemSlot.ClearAnchor();
	EnchantedItemSlot.ShowWindow();


	EnchantBtn.DisableWindow();
	
	EnchantItemSlot.SetAlpha(255,0);

	EnchantScriptSlot.Clear();

	EnchantScriptSlot.SetAnchor( "ItemEnchantWnd", "TopLeft", "TopLeft", 78, 90 );
	EnchantScriptSlot.SetWindowSize(34,34);
	EnchantScriptSlot.ClearAnchor();
	EnchantScriptSlot.ShowWindow();

	EnchantItemSlot.Clear();	

	EnchantItemSlot.SetAnchor( "ItemEnchantWnd", "TopLeft", "TopLeft", 157, 90 );
	EnchantItemSlot.SetWindowSize(34,34);
	EnchantItemSlot.ClearAnchor();
	EnchantItemSlot.ShowWindow();

	CloverItemSlot.Clear();

	EnchantScriptSlotBackTex.SetAnchor( "ItemEnchantWnd", "TopLeft", "TopLeft", 77, 90 );
	EnchantScriptSlotBackTex.ClearAnchor();
	EnchantScriptSlotBackTex.ShowWindow();
	
	EnchantItemSlotBackTex.SetAnchor( "ItemEnchantWnd", "TopLeft", "TopLeft", 156, 90 );
	EnchantItemSlotBackTex.ClearAnchor();
	EnchantItemSlotBackTex.ShowWindow();
	
	CloverItemSlot.Clear();
	
	CloverItemSlot.SetAnchor( "ItemEnchantWnd", "TopLeft", "TopLeft", 116, 100);
	CloverItemSlot.SetWindowSize(34,34);
	CloverItemSlot.ClearAnchor();

	CloverItemSlotBackTex.SetAnchor( "ItemEnchantWnd", "TopLeft", "TopLeft", 115, 100 );
	CloverItemSlotBackTex.ClearAnchor();
	//CloverItemSlotBackTex.ShowWindow();

	EnchantedItemSlotBackTex.HideWindow();
	CloverItemSlotBackTex.HideWindow();
	CloverITemSlot.HideWindow();

	bRequestScroll = false;
	bRequestEnchant = false;
	bRequestSupport = false;
	bRequestRemoveSupport = false;
	
	m_hItemEnchantWndEnchantProgress.SetProgressTime(1500);
	m_hItemEnchantWndEnchantProgress.SetPos(0);
		
	m_hItemEnchantWndEnchantProgress.Reset();
}      

function EnableCloverSlot()
{
	EnchantScriptSlot.SetAnchor( "ItemEnchantWnd", "TopLeft", "TopLeft", 78, 60 );
	EnchantScriptSlot.SetWindowSize(34,34);
	EnchantScriptSlot.ClearAnchor();
	EnchantScriptSlot.ShowWindow();
	EnchantItemSlot.SetAnchor( "ItemEnchantWnd", "TopLeft", "TopLeft", 157, 60 );
	EnchantItemSlot.SetWindowSize(34,34);
	EnchantItemSlot.ClearAnchor();
	EnchantItemSlot.ShowWindow();
	CloverItemSlot.SetAnchor( "ItemEnchantWnd", "TopLeft", "TopLeft", 116, 100);
	CloverItemSlot.ClearAnchor();
	CloverItemSlot.ShowWindow();
	CloverItemSlotBackTex.ShowWindow();
	DropHighlight_CloverItem.ShowWindow();
	//InstructionTxt.SetText(GetSystemMessage(2940));
}

/* 강화 주문서 슬롯은 안보이게 하고 (주문서 + 무기, 방어구) 두가지만 나오는 형태 */
function DisableCloverSlot()
{
	EnchantScriptSlot.SetAnchor( "ItemEnchantWnd", "TopLeft", "TopLeft", 78, 90 );
	EnchantScriptSlot.SetWindowSize(34,34);
	EnchantScriptSlot.ClearAnchor();
	EnchantScriptSlot.ShowWindow();

	EnchantItemSlot.SetAnchor( "ItemEnchantWnd", "TopLeft", "TopLeft", 157, 90 );
	EnchantItemSlot.SetWindowSize(34,34);
	EnchantItemSlot.ClearAnchor();
	EnchantItemSlot.ShowWindow();
	
	CloverItemSlot.Clear();
	CloverItemSlot.HideWindow();
	CloverItemSlotBackTex.HideWindow();
	DropHighlight_CloverItem.HideWindow();
	//InstructionTxt.SetText(GetSystemMessage(2339));

	RequestExRemoveEnchantSupportItem();
	//removeSupportItm();	
}

function RequestExRemoveEnchantSupportItem()
{
	bRequestRemoveSupport = true;
	EnchantBtn.DisableWindow();	
	class'EnchantAPI'.static.RequestExRemoveEnchantSupportItem();
}

function OnHide()
{
	bEnchantbool = false;
	if(class'UICommonAPI'.static.DialogIsOwnedBy( string(Self) )) DialogHide();
	class'EnchantAPI'.static.RequestExCancelEnchantItem();

}

function bool IsEnchantableItem(EItemParamType Type)
{
	return (Type == ITEMP_WEAPON || Type == ITEMP_ARMOR || Type == ITEMP_ACCESSARY || Type == ITEMP_SHIELD);
}

function bool isIncPropItem( EEtcItemType Type )
{
	//Debug ( "isIncPropItem" @ Type == ITEME_ENCHT_ATTR_INC_PROP_ENCHT_AM || Type == ITEME_ENCHT_ATTR_INC_PROP_ENCHT_WP  || Type == ITEME_BLESS_INC_PROP_ENCHT_WP || Type == ITEME_BLESS_INC_PROP_ENCHT_AM);
	return ( Type == ITEME_ENCHT_ATTR_INC_PROP_ENCHT_AM || Type == ITEME_ENCHT_ATTR_INC_PROP_ENCHT_WP  || Type == ITEME_BLESS_INC_PROP_ENCHT_WP || Type == ITEME_BLESS_INC_PROP_ENCHT_AM || Type == ITEME_MULTI_INC_PROB_ENCHT_WP || Type == ITEME_MULTI_INC_PROB_ENCHT_AM );	
}

function bool isEnchantScroll( EEtcItemType Type )
{	
	/*
	if  ( Type == ITEME_ENCHT_WP || Type == ITEME_ENCHT_AM || Type == ITEME_BLESS_ENCHT_WP || Type == ITEME_BLESS_ENCHT_AM || Type == ITEME_ENCHT_ATTR_CRYSTAL_ENCHANT_AM || Type == ITEME_ENCHT_ATTR_CRYSTAL_ENCHANT_WP ||  Type == ITEME_ENCHT_ATTR_ANCIENT_CRYSTAL_ENCHANT_AM || Type == ITEME_ENCHT_ATTR_ANCIENT_CRYSTAL_ENCHANT_WP)
	{
		Debug("스크롤 타입 맞아요" @ Type );
	}
	else 
	{
		Debug("스크롤 타입 아네요" @ Type );
	}*/
	//return ( Type == ITEME_ENCHT_WP || Type == ITEME_ENCHT_AM || Type == ITEME_BLESS_ENCHT_WP || Type == ITEME_BLESS_ENCHT_AM || Type == ITEME_ENCHT_ATTR_CRYSTAL_ENCHANT_AM || Type == ITEME_ENCHT_ATTR_CRYSTAL_ENCHANT_WP ||  Type == ITEME_ENCHT_ATTR_ANCIENT_CRYSTAL_ENCHANT_AM || Type == ITEME_ENCHT_ATTR_ANCIENT_CRYSTAL_ENCHANT_WP );
	return ( Type == ITEME_ENCHT_WP || Type == ITEME_ENCHT_AM || Type == ITEME_BLESS_ENCHT_WP || Type == ITEME_BLESS_ENCHT_AM || 
			 Type == ITEME_ENCHT_ATTR_CRYSTAL_ENCHANT_AM || Type == ITEME_ENCHT_ATTR_CRYSTAL_ENCHANT_WP ||  Type == ITEME_ENCHT_ATTR_ANCIENT_CRYSTAL_ENCHANT_AM || 
			 Type == ITEME_ENCHT_ATTR_ANCIENT_CRYSTAL_ENCHANT_WP || Type == ITEME_MULTI_ENCHT_WP || Type == ITEME_MULTI_ENCHT_AM ||
			 Type == ITEME_ENCHT_AG || Type == ITEME_BLESS_ENCHT_AG || Type == ITEME_MULTI_ENCHT_AG || Type == ITEME_ANCIENT_CRYSTAL_ENCHANT_AG
		   );
}

function OnDBClickItem( string ControlName, int index )
{
	if ( bEnchantbool ) return;
//	Debug( ControlName @ String ( index ));	

	if ( ControlName == "CloverItemSlot")
	{		
		RequestExRemoveEnchantSupportItem();		
		//handleCloverSlot();
		//removeSupportItm();
	}	
}

function OnDropItemSource( String strTarget, ItemInfo info )
{
	if ( bEnchantbool || bEnchantedbool) return;//인챈 중이거나 인챈 완료 시 

	//Debug( "OnDropItemSource" @ strTarget  @ info.DragSrcName );
	

	if ( strTarget == "Console")
	{		
		switch (info.DragSrcName  )
		{
			/*
		case "EnchantScriptSlot":
			Debug("OnDropItemSource EnchantScriptSlot");
		break;
		case "EnchantItemSlot":
			Debug("OnDropItemSource EnchantItemSlot");
			//class'EnchantAPI'.static.RequestExTryToPutEnchantTargetItem( -1 );
		break;*/
		case "CloverItemSlot":		
			RequestExRemoveEnchantSupportItem();			
			//removeSupportItm();

			//Debug("OnDropItemSource CloverItemSlot > 슬롯을 비워라!");			
		break;
		}		
	}
}

//function onDoubleClick

function OnDropItem( String a_WindowID, ItemInfo a_ItemInfo, int X, int Y)
{	
	local Rect rectWnd;
	
	local EItemParamType eItemParamType;
	
	//local ItemInfo invenInfo;	
	
	if ( bEnchantbool || bEnchantedbool ) return;

	rectWnd = Me.GetRect();	
	if (X > rectWnd.nX + 9 && X < rectWnd.nX + 9 + 246 && Y > rectWnd.nY + 39 && Y < rectWnd.nY + 39 + 137)//범위 지정
	{	
		//숏컷에서 아이템이 드랍됐을 경우 아이템 ItemSubType은 다른 용도로 쓰이므로, 인벤의 데이타를 다시 받아야 함.
		InventoryItem.GetItem(InventoryItem.FindItem( a_ItemInfo.ID ), a_ItemInfo);		
		eItemParamType = EItemParamType( a_ItemInfo.ItemType );
		//인첸이 가능 한 아이템일 경우 
		if (IsEnchantableItem(eItemParamType))
		{			
			//if ( SelectItemInfo.ID.ClassID == a_ItemInfo.ID.ClassID  ) return;			
			tempSelectItemInfo = a_ItemInfo;			
			mEnchantLevel = a_ItemInfo.Enchanted;
			mEnchantItemType = a_ItemInfo.SlotBitType;	// by y2jinc
			//WarningTxt.HideWindow();
			bRequestEnchant = true;
			EnchantBtn.DisableWindow();			
			class'EnchantAPI'.static.RequestExTryToPutEnchantTargetItem( a_ItemInfo.ID );

			//Debug("-->API CAll,  RequestExTryToPutEnchantTargetItem" @ a_ItemInfo.ID.ClassID);
		}		
		else  if ( EItemType( a_ItemInfo.ItemType) == ITEM_ETCITEM )
		{	
			//스크롤 일 경우 			
			if ( isEnchantScroll( EEtcItemType( a_ItemInfo.ItemSubType ) ) )
			{				
				//무기슬롯에 아이템이 있을 경우 
				if ( true ) // SelectItemInfo.itemNum > 0 ) 
				{
					//같은 거 일 경우 return
					//Debug( "OnDropItem" @ SelectItemInfo.ID.ClassID @ scrolltemInfo.ID.ClassID @ a_ItemInfo.ID.ClassID );

					if ( scrolltemInfo.ID.ClassID == a_ItemInfo.ID.ClassID)  return;

					tempscrolltemInfo = a_ItemInfo;
					//WarningTxt.HideWindow();
					bRequestScroll = true;
					EnchantBtn.DisableWindow();
					class'EnchantAPI'.static.RequestExAddEnchantScrollItem( SelectItemInfo.ID,  a_ItemInfo.ID );					
					//HandlePutScrollResult("Result=1");
					//Debug ( "OnDropItem 인첸 주문서 리퀘스트를 해야 함.");
				}
			}
			//강화석일 경우 
			else if ( isIncPropItem ( EEtcItemType( a_ItemInfo.ItemSubType ) ) )
			{	
				
				if ( !CloverItemSlot.IsShowWindow()) 
				{
					//Debug ( "!CloverItemSlot.IsShowWindow()");
					AddSystemMessage(6094);
					return;
				}
				if (  SelectHelperItemInfo.ID.ClassID == a_ItemInfo.ID.ClassID ) return;

				bRequestSupport = true;
				EnchantBtn.DisableWindow();
				tempSelectHelperItemInfo = a_ItemInfo;
				//SupportID = a_ItemInfo.ID;
				class'EnchantAPI'.static.RequestExTryToPutEnchantSupportItem( a_ItemInfo.ID, SelectItemInfo.ID );	
			}
			else 
			{
				//시스템 메시지 출력
				//조건에 맞지 않는 아이템 입니다.
				//Debug ( "!isIncPropItem ( EEtcItemType( a_ItemInfo.ItemSubType ) ) ");
				AddSystemMessage(6094);
			}
		}
		else 
		{
			//시스템 메시지 출력
			//조건에 맞지 않는 아이템 입니다.
			//Debug ( "!EItemType( a_ItemInfo.ItemType) == ITEM_ETCITEM");
			AddSystemMessage(6094);
		}
		//Debug ( "OnDropItem" @ String ( EEtcItemType(a_ItemInfo.ItemSubType)) @ string ( eItemType)  );
	}
}

/****************************************************************************************************************************************
 * 보조석 가능 조건 체크
 * **************************************************************************************************************************************/
// 클래식 
function bool checkEnableCloverSlotClassic ( int ScrollCID  ) 
{
	local EEtcItemType EEtcItemType;
	EEtcItemType = EEtcItemType( scrolltemInfo.ItemSubType );

	if ( EEtcItemType != ITEME_ENCHT_AM ) return false;
	switch ( ScrollCID ) 
	{
		// 헤어 액세서리 강화 주문서
		case 90494: 
		// 펜던트 연마제
		case 49469:
		// 발터스 기사단의 연마제 
		case 90995 :
			// 망토 강화 주문서, 망토 강화 주문서 - 전설, 고대 망토 강화 주문서 - 전설
		case 70885:
		case 70886:
		case 70887:
			// 안정된 망토 강화 주문서
		case 71124 :
		return false;
	}
	return true;
}

//branch
// 신성한 무기 강화 결정 처럼 일정 구간에서 100%의 확률로 인챈트가 성공하는 스크롤의 경우 강화 보조석 슬롯을 disable 합니다. - gorillazin 11.09.27.
function bool CheckEnableCloverSlot(int id)
{
	switch (id)
	{
	case 22018:	// 신성한 무기 강화 결정 - B그레이드
	case 22019:	// 신성한 무기 강화 결정 - A그레이드
	case 20521:	// 신성한 무기 강화 결정 - S그레이드
	case 22427:	// 신성한 무기 강화 결정 - R그레이드
	case 22020:	// 신성한 갑옷 강화 결정 - B그레이드
	case 22021:	// 신성한 갑옷 강화 결정 - A그레이드
	case 20522:	// 신성한 갑옷 강화 결정 - S그레이드
	case 22430:	// 신성한 갑옷 강화 결정 - R그레이드
	// 강화 보조석 슬롯 disable 추가 - gorillazin 13.09.17.
	case 22014:
	case 22015:
	case 22016:
	case 22017:
	case 20519:
	case 20520:
	case 22426:
	case 22429:
	case 23342:
	case 23343:
	case 23344:
	case 23345:
	case 23731:
	case 23732:
	case 23733:
	case 23734:
	case 23735:
	case 23736:
	case 23737:
	case 23738:
	case 23739:
	case 23740:
	case 23741:
	case 23742:
	case 37803:

	// 망토 강화 주문서, 망토 강화 주문서 - 전설, 고대 망토 강화 주문서 - 전설
	case 28593:
	case 28594:
	case 28595:

	// 신성한 별자리 아가시온 성장의 서
	// case 48323:

	//
		return false;
	default:
		return true;
	}
}
//end of branch

// 기타 하드 코딩 되어 있는 스크롤 타입
function bool CheckScrollType(int ID)
{
	switch (ID)
	{
		//case 6569:
		//case 6570:
		//case 6571:
		//case 6572:
		//case 6573:
		//case 6574:
		//case 6575:
		//case 6576:
		//case 6577:
		//case 6578:
		// 월드컵 이벤트에 사용되는 축복받은 강화 주문서 사용 시에도 처리 - gorillazin 10.06.14.
		//case 17255:
		//case 17256:
		//case 17257:
		//case 17258:
		//case 17259:
		//case 17260:
		//case 17261:
		//case 17262:
		//case 17263:
		//case 17264:
		// 7주년 기념 티셔츠 강화 주문서 사용 시에도 처리 - gorillazin 10.07.27.
		case 21581:
		case 21582:
		// 2010 추석 프로모션 복구용 티셔츠 - gorillazin 10.09.10.
		case 21707:
		// 2011 초롱 이벤트 관련 추가 주문서 - enyheid 11.01.06
		// 파멸의 강화주문서 D - S 그레이드
		case 22221:
		case 22222:
		case 22223:
		case 22224:
		case 22225:
		case 22226:
		case 22227:
		case 22228:
		case 22229:
		case 22230:

		// 파멸의 강화주문서 R 그레이드 - 담당 기획자 : 전투디자인팀 김창현 
		case 33478:
		case 33479:

		// 운명의 힘 이벤트 : 장비 강화 - 담당 기획자 : 전투디자인팀 김창현 
		case 33455:
		case 33456:
		case 33457:
		case 33458:
		case 33459:
		case 33460:
		case 33461:
		case 33462:
		case 33463:
		case 33464:
		
		// 거인의 주문서 : 장비 강화 
		//case 33806:
		//case 33807:
		//case 33808:
		//case 33809:
		//case 33810:
		//보조석 추가 13.10.14
		//case 33811:
		//case 33812:
		//case 33813:
		//case 33814:
		//case 33815:
		//case 33816:
		//보조석 추가 13.10.14
		//case 33817:

		//헤어 강화 주문서 : 장비 강화
		case 33818: //헤어 엑세사리 강화 주문서

		//아인하사드의 티셔츠 강화 주문서
		case 34627:
			
		//축복받은 각종 강화 주문서들
		//case 19447:
		//case 19448:
		//case 34789:
		//case 34787:

		//축복받은 무기 강화 주문서-R그레이드(이벤트)
		//case 36283:
		//축복받은 무기 강화 주문서-R그레이드(이벤트)
		//case 36284:

		//20120529 추가 됨
		//보조석 추가 13.10.14
		//case 36163: //거인의
		//case 36164: //거인의
		//case 22647:
		//case 22648:

		//파멸의 강화 주문서
		case 33838:
		case 33839:
		case 33840:
		case 33841:
		case 33842:
		case 33843:
		case 33844:
		case 33845:
		case 33846:
		case 33847:
		case 33848:
		case 33849:

		//거인의 무기, 갑옷 강화 주문서
		//보조석 추가 13.10.14
		//case 36386:
		//case 36389:
		
		//ttp 57605
		//case 36387:
		//case 36388:
		//case 36390:
		//case 36391:

		// 아인하사드의 티셔츠 강화 주문서
		case 47392 :
		// 찬란한 아인하사드의 티셔츠 강화 주문서
		case 47804 :
		// 희미한 아인하사드의 티셔츠 강화 주문서
		case 47805 :

		// 축복받은 서클릿 강화 주문서
		case 48211:

		// 망토 강화 주문서, 망토 강화 주문서 - 전설, 고대 망토 강화 주문서 - 전설
		case 28593:
		case 28594:
		case 28595:

		// 안정된 망토 강화 주문서 (해외)
		case 28766:

		// 축복받은 드래곤 셔츠 강화 주문서
		case 48498:    		

		// 혈맹 망토 강화 주문서
		case 48264:

		// 거인의 혈맹 망토 강화 주문서
		case 48265:

		// 아가시온 타입은 모두 보조석이 보이지 않도록 예외 처리 됩니다. 20170315 ~LDW
		// 2016-11-24 아가시온 아이템
		//  아가시온 강화 주문서, 축복, 거인, 파멸
		//case 48039:
		//case 48040:
		//case 48041:
		//case 48042:
		//case 48046:
		//case 48047:

		// 신성한 별자리 아가시온 성장의 서
		//case 48323:

		// 발터스 기사단의 연마제 
		case 90995 :

		// 안정된 망토 강화 주문서
		case 29163 :

			return true;
			break;
		default:
			return false;
			break;
	}
}

/***********************************************************************************************************
 * 보조석 예외 처리
 ************************************************************************************************************/
// 프레야 강화 보조석 관련 TTP 수정 내용
function checkEventWarningText()
{
	// TTP 62925 대책, 프레야 강화 보조석을 사용하여 인챈트 할때 인챈트 UI에 텍스트가 잘못 된 내용을
	// 알려줍니다.
	
	switch(SelectHelperItemInfo.ID.ClassID)
	{
		// 프레야의 무기 강화 보조석 -R그레이드
		case 40232 :
		// 프레야의 갑옷 강화 보조석 -R그레이드
		case 40233 : WarningTxt.SetText(GetSystemMessage(4278));
		break;
		// 축복받은 거인의 방어구용 강화 보조석
		case 23784 : 
		// 바람의 갑옷 강화 보조석 -R그레이드, 바람의 무기 강화 보조석 -R그레이드
		case 39465 : 
		case 39464 : 
		// 갑옷 세이브 보조석
		case 90480 :        case 90481 :        case 90482 :        case 90483 : 
			WarningTxt.SetText(GetSystemMessage(4144));		
			isBreakable = false;
		break;
		
		//branch GD35_0828 2014-2-6 luciper3 - 아래 아이템은 예외적으로 처리된다. 강화스크롤의 효과를 바꾸는 보조석이라서.. 해외한정..TTP #63645
		//branch GD35_0828 2014-6-2 luciper3 - 몇개 더 추가.. TTP #64906
		case 23783 :		case 23784 :		case 23785 :		case 23786 :		case 23787 :		case 23788 :
		case 23789 :		case 23790 :		case 23791 :		case 23792 :		case 23793 :		case 23794 :
		case 23795 :		case 23796 :		case 23797 :		case 23798 :
		//end of branch
		WarningTxt.HideWindow();
		isBreakable = false;
		break;
		//end of branch
		//branch GD1.0_0319 2014-3-26 hardcom0 - 인탠테미스 프로모션 아이템 예외 처 : 실패 메시지, isBreakable 속성 변경
		case 45416:
		case 45417:
		case 45418:
		case 45419:
		case 45420:
		case 45421:			
			//실패 시 인챈트 수치가 '3' 하락합니다.
			WarningTxt.SetText(GetSystemMessage(4298));
			isBreakable = false;
			break;
		case 45422:
		case 45423:
		case 45424:
		case 45425:
		case 45426:
		case 45427:

		// 로열 화이트 세이브 티겟 추가 2015.12.02
		case 47575 :        case 47576:         case 47577 :
		// 로열 퍼플 세이브 티켓 추가 2016.1.4
		case 47622 :        case 47623:         case 47624 :
		// 해외 로열 화이트 세이브 티겟 추가 2016.10.24
		case 28425:        case 28426:        case 28427:        case 28428:        case 28429:        case 28430:
		// 클래식 인첸트 세이브 보조석
		case 90484 :        case 90485 :        case 90486 :        case 90487 : 
		// 해외 로열 화이트 세이브 티겟 추가 2016.10.24
		case 28425 :        case 28426 :        case 28427 :        case 28428 :        case 28429 :        case 28430 :
			//실패 시 인챈트 수치가 '1' 하락합니다.
			WarningTxt.SetText(GetSystemMessage(4278));
			isBreakable = false;
			break;		

		//end of branch		
	}	
}




function HandleEnchantResult(string param)
{
	local int IntResult ;
	local ItemID ItemID ;
	local int64 Count ;
	local int CountInt ;
	local ItemInfo ResultItem ;
	local string EndTxt ;
	local int EnchantValue ;
	local int EnchantOption1;
	local int EnchantOption2;	
	local int EnchantOption3;

	local ItemInfo EmptyItem;

	local ItemInfo invenScrollInfo;
	local ItemInfo invenSupportInfo;

	//추가된 param 실제 쓰이는 건, SupportCount, ScrollCount 되겠다.
	//local int TargetServerID;
	//local int ScrollServerID;
	//local int SupportServerID;
	//local int SupportCount;
	//local int ScrollCount;

	//결과에 상관 없이 무조건 Hide.
	WarningTxt.HideWindow();
	
	EnchantProgressAnim.HideWindow();
	//결과에 상관없이 무조건 Hide
	//~ Me.HideWindow();
	//~ Clear();
	//debug (param);
	ParseInt(Param, "Result", IntResult );
	ParseItemID(param, ItemID );
	Parseint64(param, "Count", Count );
	ParseInt(param, "Count", CountInt );	
	ParseInt(param, "EnchantValue", EnchantValue );
	ParseInt(param, "EnchantOption1", EnchantOption1 );
	ParseInt(param, "EnchantOption2", EnchantOption2 );
	ParseInt(param, "EnchantOption3", EnchantOption3 );

	//ParseInt(param, "SupportCount", SupportCount );
	//ParseInt(param, "ScrollCount", ScrollCount );
	
	//debug ("HandleEnchantResult" @ IntResult ) ;
	//debug ("count:" @ string(int(Count)));
	class'UIDATA_ITEM'.static.GetItemInfo(ItemID, ResultItem );
	
	
	EnchantItemSlotBackTex.HideWindow();
	EnchantedItemSlotBackTex.HideWindow();
	CloverItemSlotBackTex.HideWindow();
	EnchantBtn.DisableWindow();

	EnchantedItemSlot.Clear();
	EnchantedItemSlot.EnableTick();
	
	switch (IntResult)
	{
		case 0://IER_SUCCESS
			bEnchantedbool = true;
			EnchantProgressAnim.HideWindow();
			EnchantProgressAnim.SetTexture("l2ui_ct1.ItemEnchant_DF_Effect_Success_00");
			EnchantProgressAnim.SetLoopCount( 1 );
			EnchantProgressAnim.Stop();
			EnchantProgressAnim.Play();
			Playsound("ItemSound3.enchant_success");
			EnchantProgressAnim.ShowWindow();
		
			BackPattern.SetAlpha(0, 0);
			BackPattern.ShowWindow();
			BackPattern.SetAlpha(255, 2);
		
			SelectItemInfo.Enchanted = EnchantValue;
			mEnchantLevel = EnchantValue;
			
			SelectItemInfo.EnchantOption1 = EnchantOption1;
			SelectItemInfo.EnchantOption2 = EnchantOption2;
			SelectItemInfo.EnchantOption3 = EnchantOption3;
		
			EnchantItemSlot.SetItem(0, SelectItemInfo);
			EnchantedItemSlot.SetItem( 0, SelectItemInfo );
			EnchantedItemSlot.AddItem( SelectItemInfo );

			// 아가시온 성장이라면..
			if(isAGScrollState())
			{
				// 축하합니다. 성장에 성공하여 ‘$s1’이 되었습니다.
				EndTxt = MakeFullSystemMsg(GetSystemMessage(4513), "+"$string(SelectItemInfo.Enchanted) @ SelectItemInfo.Name, "");
			}
			else
			{
				// 축하합니다. 아이템 강화가 성공하여 $s1%이 되었습니다.
				EndTxt = MakeFullSystemMsg(GetSystemMessage(2342), "+"$string(SelectItemInfo.Enchanted) @ SelectItemInfo.Name, "");
			}
			InstructionTxt.SetText(EndTxt);
			EnchantedItemSlot.SetAlpha(0);
			EnchantedItemSlot.ShowWindow();
			EnchantedItemSlot.SetAlpha(255,2);
			CloverItemSlot.HideWindow();
			//~ EnchantItemSlot.SetAlpha(0, 2);
			EnchantItemSlot.HideWindow();
			EnchantScriptSlot.HideWindow();
			CloverItemSlot.HideWindow();
			EnchantBtn.EnableWindow();
			//EnchantBtn.SetNameText( GetSystemString(140) );	
			EnchantBtn.SetNameText( GetSystemString(3135) );

			//인벤에서 아이템 개수를 받아 정리 함.
			InventoryItem.GetItem(InventoryItem.FindItem( scrolltemInfo.ID ), invenScrollInfo);//d
			InventoryItem.GetItem(InventoryItem.FindItem( SelectHelperItemInfo.ID ), invenSupportInfo);//d
			
			//Debug("invenScrollInfo.itemNum" @ invenScrollInfo.itemNum @ invenSupportInfo.itemNum);
			if (invenScrollInfo.itemNum < 2) 
			{
				//Debug("invenScrollInfo.itemNum" @ invenScrollInfo.itemNum );
				scrolltemInfo = EmptyItem;
			}
			if (invenSupportInfo.itemNum < 2 ) 
			{
				//Debug("invenSupportInfo.itemNum" @ invenSupportInfo.itemNum);
				SelectHelperItemInfo = EmptyItem;
			}
	
			break;
		
		case 1://IER_FAIL
			bEnchantedbool = true; 
			EnchantProgressAnim.HideWindow();
			EnchantProgressAnim.SetTexture("l2ui_ct1.ItemEnchant_DF_Effect_Failed_01");
			EnchantProgressAnim.SetLoopCount( C_ANIMLOOPCOUNT );
			EnchantProgressAnim.Stop();
			EnchantProgressAnim.Play();
			Playsound("ItemSound3.enchant_fail");
			EnchantProgressAnim.ShowWindow();
		
			BackPattern.SetAlpha(0, 0);
			BackPattern.ShowWindow();
			BackPattern.SetAlpha(255, 2);
		
			if (ResultItem.Id.ClassID > 0)
			{
				ResultItem.ItemNum = Count;
				//debug ("Count2" @ string(int(Count)));
				EnchantedItemSlot.SetAlpha(0);
				EnchantedItemSlot.SetItem( 0, ResultItem );
				EnchantedItemSlot.AddItem( ResultItem );
				EnchantedItemSlot.ShowWindow();
				EnchantedItemSlot.SetAlpha(255,2);
			}
			
			if (isAGScrollState())
			{
				// 성장에 실패 하였습니다. 아가시온이 소멸되어, 아이템이 ‘파괴’되었습니다.
				EndTxt = GetSystemMessage(4511);
			}
			else
			{
				// 아이템 강화에 실패하였습니다. $s1 $s2개를 얻었습니다.
				EndTxt = MakeFullSystemMsg(GetSystemMessage(2343), ResultItem.Name, String(CountInt));
			}

			InstructionTxt.SetText(EndTxt);
		
			CloverItemSlot.HideWindow();
			EnchantItemSlot.HideWindow();
			//~ EnchantItemSlot.SetAlpha(0, 3);
			//~ EnchantItemSlot.HideWindow();
			EnchantScriptSlot.HideWindow();
			CloverItemSlot.HideWindow();
			break;
		case 2://IER_CANCELED
			EnchantProgressAnim.HideWindow();
			//if (!bEnchantedbool)
				//2013.01.14 인첸 드랍 후 실패 X
			Me.HideWindow();
			break;
		case 3://IER_BLESSED_FAIL
			bEnchantedbool = true;
			EnchantProgressAnim.HideWindow();
			EnchantProgressAnim.SetTexture("l2ui_ct1.ItemEnchant_DF_Effect_Failed_01");
			EnchantProgressAnim.SetLoopCount( C_ANIMLOOPCOUNT );
			EnchantProgressAnim.Stop();
			EnchantProgressAnim.Play();
			Playsound("ItemSound3.enchant_fail");
			EnchantProgressAnim.ShowWindow();
		
			BackPattern.SetAlpha(0, 0);
			BackPattern.ShowWindow();
			BackPattern.SetAlpha(255, 2);
		
			//~ ResultItem.
			ResultItem.ItemNum = 1;
			EnchantedItemSlot.SetAlpha(0);
			//SelectItemInfo.Enchanted = 0;

			SelectItemInfo.Enchanted = EnchantValue;
			SelectItemInfo.EnchantOption1 = EnchantOption1;
			SelectItemInfo.EnchantOption2 = EnchantOption2;
			SelectItemInfo.EnchantOption3 = EnchantOption3;

			EnchantedItemSlot.SetItem( 0, SelectItemInfo );
			EnchantedItemSlot.AddItem( SelectItemInfo );
			EnchantedItemSlot.ShowWindow();
			EnchantedItemSlot.SetAlpha(255,2);

			if (isAGScrollState())
			{
				// 성장에 실패 하였습니다. 아가시온이 소멸되어, 아이템이 ‘파괴’되었습니다.
				EndTxt = GetSystemMessage(4511);
			}
			else
			{
				// 아이템 강화에 실패하였습니다. $s1 $s2개를 얻었습니다.
				EndTxt = MakeFullSystemMsg(GetSystemMessage(2343), SelectItemInfo.Name, "1");
			}

			InstructionTxt.SetText(EndTxt);
		
			CloverItemSlot.HideWindow();
			EnchantItemSlot.HideWindow();
			//~ EnchantItemSlot.SetAlpha(0, 3);
			//~ EnchantItemSlot.HideWindow();
			EnchantScriptSlot.HideWindow();
			CloverItemSlot.HideWindow();
			break;
			
		case 4://IER_EVENT_FAIL
			bEnchantedbool = true;
			EnchantProgressAnim.HideWindow();
			EnchantProgressAnim.SetTexture("l2ui_ct1.ItemEnchant_DF_Effect_Failed_01");
			EnchantProgressAnim.SetLoopCount( C_ANIMLOOPCOUNT );
			EnchantProgressAnim.Stop();
			EnchantProgressAnim.Play();
			Playsound("ItemSound3.enchant_fail");
			EnchantProgressAnim.ShowWindow();
		
			BackPattern.SetAlpha(0, 0);
			BackPattern.ShowWindow();
			BackPattern.SetAlpha(255, 2);
		
			//~ ResultItem.
			if (ResultItem.Id.ClassID > 0)
			{
				ResultItem.ItemNum = 0;
				EnchantedItemSlot.SetAlpha(0);
				EnchantedItemSlot.SetItem( 0, ResultItem );
				EnchantedItemSlot.AddItem( ResultItem );
				//~ EnchantedItemSlot.ShowWindow();
				EnchantedItemSlot.SetAlpha(255,2);
			}

			if(isAGScrollState())
			{
				// 성장에 실패 하였습니다. 아가시온이 소멸되어, 아이템이 ‘파괴’되었습니다.
				EndTxt = GetSystemMessage(4511);
			}
			else
			{
				// 강화에 실패했습니다. $s1%이 증발하였습니다
				EndTxt = MakeFullSystemMsg(GetSystemMessage(64), SelectItemInfo.Name,"");
			}
			InstructionTxt.SetText(EndTxt);
		
			CloverItemSlot.HideWindow();
			EnchantItemSlot.HideWindow();
			//~ EnchantItemSlot.SetAlpha(0, 3);
			//~ EnchantItemSlot.HideWindow();
			EnchantScriptSlot.HideWindow();
			break;
			
		//branch
		case 5:			// case IER_ANCIENT_BLESSED_FAIL -> ItemEnchantResult 상수가 추가되어 번호가 변경되진 않는지 확인.
			bEnchantedbool = true;
			EnchantProgressAnim.HideWindow();
			EnchantProgressAnim.SetTexture("l2ui_ct1.ItemEnchant_DF_Effect_Failed_01");
			EnchantProgressAnim.SetLoopCount( C_ANIMLOOPCOUNT );
			EnchantProgressAnim.Stop();
			EnchantProgressAnim.Play();
			Playsound("ItemSound3.enchant_fail");
			EnchantProgressAnim.ShowWindow();
		
			BackPattern.SetAlpha(0, 0);
			BackPattern.ShowWindow();
			BackPattern.SetAlpha(255, 2);
		
			//~ ResultItem.
			ResultItem.ItemNum = 1;
			EnchantedItemSlot.SetAlpha(0);
			EnchantedItemSlot.SetItem( 0, SelectItemInfo );
			EnchantedItemSlot.AddItem( SelectItemInfo );
			EnchantedItemSlot.ShowWindow();
			EnchantedItemSlot.SetAlpha(255,2);

			// 인챈트에 실패했습니다. 해당 아이템의 인챈트 수치는 그대로 유지됩니다.
			
			if(isAGScrollState())
			{
				// 실패 시 아가시온의 성장 수치가 ‘유지’됩니다.
				EndTxt = GetSystemMessage(4509);
			}
			else
			{
				// 인챈트에 실패했습니다. 해당 아이템의 인챈트 수치는 그대로 유지됩니다.
				EndTxt = GetSystemMessage(6004);
			}

			InstructionTxt.SetText(EndTxt);
		
			CloverItemSlot.HideWindow();
			EnchantItemSlot.HideWindow();
			//~ EnchantItemSlot.SetAlpha(0, 3);
			//~ EnchantItemSlot.HideWindow();
			EnchantScriptSlot.HideWindow();
			CloverItemSlot.HideWindow();
			break;
		//end of branch
			//해외 추가
		case 6:
			//Debug("-- 6번 결과 --");
			bEnchantedbool = true;
			EnchantProgressAnim.HideWindow();
			EnchantProgressAnim.SetTexture("l2ui_ct1.ItemEnchant_DF_Effect_Failed_01");
			EnchantProgressAnim.SetLoopCount(C_ANIMLOOPCOUNT);
			EnchantProgressAnim.Stop();
			EnchantProgressAnim.Play();
			Playsound("ItemSound3.enchant_fail");
			EnchantProgressAnim.ShowWindow();

			// ---
			BackPattern.SetAlpha(0,0);
			BackPattern.ShowWindow();
			BackPattern.SetAlpha(255,2);

			SelectItemInfo.Enchanted = EnchantValue;
			mEnchantLevel = EnchantValue;

			SelectItemInfo.EnchantOption1 = EnchantOption1;
			SelectItemInfo.EnchantOption2 = EnchantOption2;
			SelectItemInfo.EnchantOption3 = EnchantOption3;

			EnchantItemSlot.SetItem(0,SelectItemInfo);
			EnchantedItemSlot.SetItem(0,SelectItemInfo);
			EnchantedItemSlot.AddItem(SelectItemInfo);
			EndTxt = MakeFullSystemMsg(GetSystemMessage(2343),"+"$string(SelectItemInfo.Enchanted) @ SelectItemInfo.Name,"1");
			InstructionTxt.SetText(EndTxt);
			EnchantedItemSlot.SetAlpha(0);
			EnchantedItemSlot.ShowWindow();
			EnchantedItemSlot.SetAlpha(255,2);
			CloverItemSlot.HideWindow();
			//~ EnchantItemSlot.SetAlpha(0, 2);
			EnchantItemSlot.HideWindow();
			EnchantScriptSlot.HideWindow();
			CloverItemSlot.HideWindow();
			EnchantBtn.EnableWindow();
			//EnchantBtn.SetNameText( GetSystemString(140) );	
			EnchantBtn.SetNameText(GetSystemString(3135));

			//인벤에서 아이템 개수를 받아 정리 함.
			InventoryItem.GetItem(InventoryItem.FindItem(scrolltemInfo.ID),invenScrollInfo);//d
			InventoryItem.GetItem(InventoryItem.FindItem(SelectHelperItemInfo.ID),invenSupportInfo);//d

			//Debug("invenScrollInfo.itemNum" @ invenScrollInfo.itemNum @ invenSupportInfo.itemNum);
			if(invenScrollInfo.itemNum < 2)
			{
				//Debug("invenScrollInfo.itemNum" @ invenScrollInfo.itemNum );
				scrolltemInfo = EmptyItem;
			}
			if(invenSupportInfo.itemNum < 2)
			{
				//Debug("invenSupportInfo.itemNum" @ invenSupportInfo.itemNum);
				SelectHelperItemInfo = EmptyItem;
			}
 
			break;
	}

	ExitBtn.SetNameText( GetSystemString(646) );	
	ExitBtn.EnableWindow();
}

function SetIsShopping(bool isShopping)
{
	bIsShopping = isShopping;

	// debug("=============isShopping : " $ bIsShopping);
}

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
