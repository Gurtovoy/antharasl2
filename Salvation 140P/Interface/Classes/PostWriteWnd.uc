class PostWriteWnd extends UICommonAPI;

var string m_WindowName;

var WindowHandle Me;
//var UIScript myScript;
var WindowHandle PostBoxWnd;
var WindowHandle PostDetailWnd_General;
var WindowHandle PostDetailWnd_SafetyTrade;

var TextureHandle PostTitleDivider;
var TextureHandle PostContentsBg;
var TextureHandle groupbox1;
var TextureHandle AccompanyItemSlotBg01;
var TextureHandle AccompanyItemSlotBg02;
var TextureHandle AccompanyItemSlotBg03;
var TextureHandle AdenaIcon;
var TextureHandle WeightBg;
var TextureHandle WeightDivider;
var TextureHandle InventoryItemSlot01;
var TextureHandle InventoryItemSlot02;
var TextureHandle InventoryDivider;
var TextureHandle ChargeAdenaIcon;
var TextureHandle Chargeadenabg;
var TextureHandle groupbox2;
var TextureHandle SafetyTradeAdenaIcon;
var TextureHandle groupbox3;
var TextureHandle SafetyTradeAdenaTextBoxBg;
var TextureHandle SafetyReceiveAdenaIcon;

var TextboxHandle Title_ReceiverID;
var TextboxHandle Title_PostType;
var TextboxHandle Title_PostTitle;
var TextboxHandle PostTitleByte;
var TextboxHandle Title_PostContents;
var TextboxHandle PostContentsByte;
var TextboxHandle Title_AccompanyItem;
var TextboxHandle Title_Weight;
var TextboxHandle WeightText;
var TextboxHandle Title_Inventory;
var TextboxHandle InventoryItemNumber;
var TextboxHandle InventoryPageNumber;
var TextboxHandle Title_Charge;
var TextboxHandle ChargeAdenaText;
var TextboxHandle Title_SafetyTradeAdena;


var EditBoxHandle ReceiverID;
var EditBoxHandle PostTitle;
//var TextboxHandle AdenaTextBox;
var TextboxHandle SafetyTradeAdenaTextBox;

var ButtonHandle SafetyReceiveAdena;


//XML에 MultiEdit이 있으나 핸들러선언을 찾아봐도 없넹...
var MultiEditBoxHandle Contents;

var ComboBoxHandle PostTypeComboBox;


var ButtonHandle SendBtn;


var ItemWindowHandle AccompanyItem;
var ItemWindowHandle InventoryItem;
var ButtonHandle PrevButton;
var ButtonHandle NextButton;


var InventoryWnd script;


//선준 수정(2010.03.08)
var WindowHandle    PostReceiverListWnd;
var bool            bOpenPostReceiverList;

var string          strSendID;

var array<RequestItem> itemIDList;
//var array<INT64> itemAmountList;

var ItemInfo adenaInfo;		// 아데나 정보 가지고 있기..
var INT64 SafetyTradeAdena;	// 안전거래시 받을 금액
var INT64 FeeAdena;			// 배송료
var	int		TotalWeight;	// 총무게
var int	 curTradeType;
var int  ZoneType;
//var int IsPeaceZone;

var Color disableColor;
var Color enableColor;

const FEEMUITIPLIER = 2;	//무게당 배송료 비율
//const FEE_PER_SLOT = 1000;//LDW 2011.09.02 수정
var int FEE_PER_SLOT ;

const TRADE_NORMAL	= 0;	// 일반 거래
const TRADE_SAFE = 1;		// 안전 거래

const MAX_APPEND_ITEM_NUM = 8; //최대 첨부수

const DIALOG_STACKABLE_ITEM_ACCOMPANY_TO_INVEN = 1111;		//ACCOMPANY 에서 INVEN으로 옮길때 스태커블한거 개수 물어보기
const DIALOG_STACKABLE_ITEM_INVEN_TO_ACCOMPANY = 2222;		//INVEN 에서 ACCOMPANY으로 옮길때 스태커블한거 개수 물어보기
const DIALOG_RECEIVE_ADENA = 3333;							//받을 금액 설정
const DIALOG_NOTIFY_SEND_POST = 4444;						//우편을 전송할 것인지 물어보는 다이얼로그
const DIALOG_ONLY_NOTICE = 5555;							//아무동작도 안하는 알려주는 전용
//보낼 금액 설정
const MAX_CHAR_LENGTH = 24;
const MAX_TITLE_LENGTH = 60;
const MAX_CONTENTS_LENGTH = 1000;

//const BASE_FEE_ADENA = 100;								//우편 기본요금 //LDW 2011.09.02 수정
var int BASE_FEE_ADENA;		            					//우편 기본요금 //LDW 2011.09.02 수정
const ADENA_OVER_FLOW = "1000000000000";	

const MAX_PAGE_ITEM_NUM = 24;

function OnRegisterEvent()
{
	registerEvent( EV_ReceiveFriendList );
	registerEvent( EV_ConfirmAddingPostFriend );
	registerEvent( EV_ReceivePostFriendList );
	registerEvent( EV_ReceivePledgeMemberList );
	registerEvent( EV_PostWriteOpen );
	registerEvent( EV_PostWriteAddItem );
	registerEvent( EV_PostWriteEnd );
	registerEvent( EV_DialogOK );
	registerEvent( EV_ReplyWritePost );
	registerEvent( EV_SetRadarZoneCode );
	registerEvent( EV_GamingStateExit );

	registerEvent( EV_MailCommisionValue );
}

function OnLoad()
{
	SetClosingOnESC();

	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	if(CREATE_ON_DEMAND==0)
		Initialize();
	else
		InitializeCOD();

	Me.HideWindow();

	enableColor.R = 220;
	enableColor.G = 220;
	enableColor.B = 220;
	disableColor.R = 130;
	disableColor.G = 130;
	disableColor.B = 130;
	ClearAll();

	bOpenPostReceiverList = false;
//	ResetUI();
	
}

function OnShow()
{
	if( PostBoxWnd.IsShowwindow())
		PostBoxWnd.HideWindow();
	if (PostDetailWnd_General.IsShowWindow())
		PostDetailWnd_General.HideWindow();
	if (PostDetailWnd_SafetyTrade.IsShowWindow())
		PostDetailWnd_SafetyTrade.HideWindow();
	if ( ZoneType != 12 )
		SendBtn.EnableWindow();

	// 보낼 이름이 없으면 , 보낼 이름 쪽에 포커스 
	// 이름이 있다면 내용쪽에 포커스를 둔다.
	if (ReceiverID.GetString() == "")
	{
		ReceiverID.Setfocus();
	}
	else
	{
		Contents.SetFocus();
	}
}

/**
 *  지정한 이름으로 외부에서 해당 창을 열기 위한 함수(인맥 관리 쪽에서 사용)
 **/
function toWrite(string name)
{	
	ReceiverID.SetString(name);
}

function Initialize()
{
	Me = GetHandle("PostWriteWnd");
	PostBoxWnd = GetHandle("PostBoxWnd");
	PostDetailWnd_General = GetHandle("PostDetailWnd_General");
	PostDetailWnd_SafetyTrade = GetHandle("PostDetailWnd_SafetyTrade");

	Title_ReceiverID=TextboxHandle(GetHandle("PostWriteWnd.Title_ReceiverID"));
	Title_PostType=TextboxHandle(GetHandle("PostWriteWnd.Title_PostType"));
	Title_PostTitle=TextboxHandle(GetHandle("PostWriteWnd.Title_PostTitle"));
	PostTitleByte=TextboxHandle(GetHandle("PostWriteWnd.PostTitleByte"));
	Title_PostContents=TextboxHandle(GetHandle("PostWriteWnd.Title_PostContents"));
	PostContentsByte=TextboxHandle(GetHandle("PostWriteWnd.PostContentsByte"));
	Title_AccompanyItem=TextboxHandle(GetHandle("PostWriteWnd.Title_AccompanyItem"));
	Title_Weight=TextboxHandle(GetHandle("PostWriteWnd.Title_Weight"));
	WeightText=TextboxHandle(GetHandle("PostWriteWnd.WeightText"));
	Title_Inventory=TextboxHandle(GetHandle("PostWriteWnd.Title_Inventory"));
	InventoryItemNumber=TextboxHandle(GetHandle("PostWriteWnd.InventoryItemNumber"));
	InventoryPageNumber=TextboxHandle(GetHandle("PostWriteWnd.InventoryPageNumber"));
	Title_Charge=TextboxHandle(GetHandle("PostWriteWnd.Title_Charge"));
	ChargeAdenaText=TextboxHandle(GetHandle("PostWriteWnd.ChargeAdenaText"));
	Title_SafetyTradeAdena=TextboxHandle(GetHandle("PostWriteWnd.Title_SafetyTradeAdena"));
	
	
	
	PostTitleDivider=TextureHandle(GetHandle("PostWriteWnd.PostTitleDivider"));
	PostContentsBg=TextureHandle(GetHandle("PostWriteWnd.PostContentsBg"));
	groupbox1=TextureHandle(GetHandle("PostWriteWnd.groupbox1"));
	AccompanyItemSlotBg01=TextureHandle(GetHandle("PostWriteWnd.AccompanyItemSlotBg01"));
	AccompanyItemSlotBg02=TextureHandle(GetHandle("PostWriteWnd.AccompanyItemSlotBg02"));
	AccompanyItemSlotBg03=TextureHandle(GetHandle("PostWriteWnd.AccompanyItemSlotBg03"));
	AdenaIcon=TextureHandle(GetHandle("PostWriteWnd.AdenaIcon"));
	WeightBg=TextureHandle(GetHandle("PostWriteWnd.WeightBg"));
	WeightDivider=TextureHandle(GetHandle("PostWriteWnd.WeightDivider"));
	InventoryItemSlot01=TextureHandle(GetHandle("PostWriteWnd.InventoryItemSlot01"));
	InventoryItemSlot02=TextureHandle(GetHandle("PostWriteWnd.InventoryItemSlot02"));
	InventoryDivider=TextureHandle(GetHandle("PostWriteWnd.InventoryDivider"));
	ChargeAdenaIcon=TextureHandle(GetHandle("PostWriteWnd.ChargeAdenaIcon"));
	Chargeadenabg=TextureHandle(GetHandle("PostWriteWnd.Chargeadenabg"));
	groupbox2=TextureHandle(GetHandle("PostWriteWnd.groupbox2"));
	SafetyTradeAdenaIcon=TextureHandle(GetHandle("PostWriteWnd.SafetyTradeAdenaIcon"));
	groupbox3=TextureHandle(GetHandle("PostWriteWnd.groupbox3"));

	SafetyTradeAdenaTextBoxBg=TextureHandle(GetHandle("PostWriteWnd.SafetyTradeAdenaTextBoxBg"));
	SafetyReceiveAdenaIcon=TextureHandle(GetHandle("PostWriteWnd.SafetyReceiveAdenaIcon"));
	
	ReceiverID=EditBoxHandle(GetHandle("PostWriteWnd.ReceiverID"));
	PostTitle=EditBoxHandle(GetHandle("PostWriteWnd.PostTitle"));
	//	AdenaTextBox=TextBoxHandle(GetHandle("PostWriteWnd.AdenaTextBox"));
	SafetyTradeAdenaTextBox=TextBoxHandle(GetHandle("PostWriteWnd.SafetyTradeAdenaTextBox"));
	Contents = MultiEditBoxHandle(GetHandle("PostWriteWnd.PostContents"));	

	PostTypeComboBox=ComboBoxHandle(GetHandle("PostWriteWnd.PostTypeComboBox"));

	AccompanyItem=ItemWindowHandle(GetHandle("PostWriteWnd.AccompanyItem"));
	InventoryItem=ItemWindowHandle(GetHandle("PostWriteWnd.InventoryItem"));
	PrevButton=ButtonHandle (GetHandle("PostWriteWnd.PrevButton"));
	NextButton=ButtonHandle (GetHandle("PostWriteWnd.NextButton"));
	

	SendBtn=ButtonHandle (GetHandle("PostWriteWnd.SendBtn"));
	SafetyReceiveAdena =ButtonHandle (GetHandle("PostWriteWnd.SafetyReceiveAdena"));
	
	script = InventoryWnd( GetScript("InventoryWnd") );

	//선준 수정(2010.03.08)
	PostReceiverListWnd = GetWindowHandle( "PostReceiverListWnd" );
}

function InitializeCOD()
{

	Me = GetWindowHandle("PostWriteWnd");
	PostBoxWnd = GetWindowHandle("PostBoxWnd");
	PostDetailWnd_General = GetWindowHandle("PostDetailWnd_General");
	PostDetailWnd_SafetyTrade = GetWindowHandle("PostDetailWnd_SafetyTrade");

	Title_ReceiverID=GetTextBoxHandle("PostWriteWnd.Title_ReceiverID");
	Title_PostType=GetTextBoxHandle("PostWriteWnd.Title_PostType");
	Title_PostTitle=GetTextBoxHandle("PostWriteWnd.Title_PostTitle");
	PostTitleByte=GetTextBoxHandle("PostWriteWnd.PostTitleByte");
	Title_PostContents=GetTextBoxHandle("PostWriteWnd.Title_PostContents");
	PostContentsByte=GetTextBoxHandle("PostWriteWnd.PostContentsByte");
	Title_AccompanyItem=GetTextBoxHandle("PostWriteWnd.Title_AccompanyItem");
	Title_Weight=GetTextBoxHandle("PostWriteWnd.Title_Weight");
	WeightText=GetTextBoxHandle("PostWriteWnd.WeightText");
	Title_Inventory=GetTextBoxHandle("PostWriteWnd.Title_Inventory");
	InventoryItemNumber=GetTextBoxHandle("PostWriteWnd.InventoryItemNumber");
	InventoryPageNumber=GetTextBoxHandle("PostWriteWnd.InventoryPageNumber");
	Title_Charge=GetTextBoxHandle("PostWriteWnd.Title_Charge");
	ChargeAdenaText=GetTextBoxHandle("PostWriteWnd.ChargeAdenaText");
	Title_SafetyTradeAdena=GetTextBoxHandle("PostWriteWnd.Title_SafetyTradeAdena");
	
	
	
	PostTitleDivider=GetTextureHandle("PostWriteWnd.PostTitleDivider");
	PostContentsBg=GetTextureHandle("PostWriteWnd.PostContentsBg");
	groupbox1=GetTextureHandle("PostWriteWnd.groupbox1");
	AccompanyItemSlotBg01=GetTextureHandle("PostWriteWnd.AccompanyItemSlotBg01");
	AccompanyItemSlotBg02=GetTextureHandle("PostWriteWnd.AccompanyItemSlotBg02");
	AccompanyItemSlotBg03=GetTextureHandle("PostWriteWnd.AccompanyItemSlotBg03");
	AdenaIcon=GetTextureHandle("PostWriteWnd.AdenaIcon");
	WeightBg=GetTextureHandle("PostWriteWnd.WeightBg");
	WeightDivider=GetTextureHandle("PostWriteWnd.WeightDivider");
	InventoryItemSlot01=GetTextureHandle("PostWriteWnd.InventoryItemSlot01");
	InventoryItemSlot02=GetTextureHandle("PostWriteWnd.InventoryItemSlot02");
	InventoryDivider=GetTextureHandle("PostWriteWnd.InventoryDivider");
	ChargeAdenaIcon=GetTextureHandle("PostWriteWnd.ChargeAdenaIcon");
	Chargeadenabg=GetTextureHandle("PostWriteWnd.Chargeadenabg");
	groupbox2=GetTextureHandle("PostWriteWnd.groupbox2");
	SafetyTradeAdenaIcon=GetTextureHandle("PostWriteWnd.SafetyTradeAdenaIcon");
	groupbox3=GetTextureHandle("PostWriteWnd.groupbox3");

	SafetyTradeAdenaTextBoxBg=GetTextureHandle("PostWriteWnd.SafetyTradeAdenaTextBoxBg");
	SafetyReceiveAdenaIcon=GetTextureHandle("PostWriteWnd.SafetyReceiveAdenaIcon");
	
	ReceiverID=GetEditBoxHandle("PostWriteWnd.ReceiverID");
	PostTitle=GetEditBoxHandle("PostWriteWnd.PostTitle");
	//AdenaTextBox=GetTextBoxHandle("PostWriteWnd.AdenaTextBox");
	SafetyTradeAdenaTextBox=GetTextBoxHandle("PostWriteWnd.SafetyTradeAdenaTextBox");
	Contents = GetMultiEditBoxHandle("PostWriteWnd.PostContents");	
	
	PostTypeComboBox=GetComboBoxHandle("PostWriteWnd.PostTypeComboBox");

	AccompanyItem=GetItemWindowHandle("PostWriteWnd.AccompanyItem");
	InventoryItem=GetItemWindowHandle("PostWriteWnd.InventoryItem");
	PrevButton=GetButtonHandle("PostWriteWnd.PrevButton");
	NextButton=GetButtonHandle("PostWriteWnd.NextButton");

	SendBtn=GetButtonHandle("PostWriteWnd.SendBtn");
	SafetyReceiveAdena = GetButtonHandle("PostWriteWnd.SafetyReceiveAdena");

	script = InventoryWnd( GetScript("InventoryWnd") );
//	myScript = GetScript("PostWriteWnd");

	//선준 수정(2010.03.08)
	PostReceiverListWnd = GetWindowHandle( "PostReceiverListWnd" );
}

function PostListUpdate()
{
	class'PostWndAPI'.static.RequestFriendList();
	class'PostWndAPI'.static.RequestPledgeMemberList();
	class'PostWndAPI'.static.RequestPostFriendList();
}

function OnClickButton( String a_ButtonID )
{
	switch(a_ButtonID)
	{
	case "SendBtn":
		HandleSendBtn();
		break;
	case "SafetyReceiveAdena":
		HandleSafetyReceiveAdena();
		break;
	case "PrevButton":
		InventoryItem.PushSideTypePrevBtn();
		SetInventoryPageNumber();
		break;
	case "NextButton":
		InventoryItem.PushSideTypeNextBtn();
		SetInventoryPageNumber();
		break;

	//선준 수정(2010.03.08)
	case "ReceiverListBtn":		
		OnReceiverListButton();
		break;
	}
}

function SetBoolPostReceiverList( bool b )
{
	//debug("SetBoolPostReceiverList" $ string(b) );
	bOpenPostReceiverList = b;
}

function OnReceiverListButton()
{	
	local PostReceiverListWnd Script;
	
	Script = PostReceiverListWnd( GetScript( "PostReceiverListWnd" ) );	

	bOpenPostReceiverList = !bOpenPostReceiverList;	
	
	if (bOpenPostReceiverList)
	{	
		PostReceiverListWnd.ShowWindow();
		PostListUpdate();
	}
	else 
	{	
		Script.selectedInit();
		PostReceiverListWnd.HideWindow();		
	}		
}

function OnEvent( int Event_ID, String Param )
{
//	local int zonetype;
	switch(Event_ID)
	{
	case EV_PostWriteOpen:
		HandlePostWriteOpen();
		break;

	case EV_PostWriteAddItem:
		HandleSentEnableAddItem(Param);
		break;
	
	case EV_PostWriteEnd:
		HandlePostWriteEnd();
		break;
	case EV_DialogOK:
		HandleDialogOK();
		break;

	case EV_ReplyWritePost:
		HandleReplyWritePost(Param);
		break;
	case EV_SetRadarZoneCode:
//		ParseInt( Param, "ZoneCode", zonetype );		
		ParseInt( Param, "ZoneCode", ZoneType );
		if (ZoneType == 12 )
			SendBtn.EnableWindow();
		else if ( AccompanyItem.GetItemNum() > 0 )
			SendBtn.DisableWindow();
			
//		if (zonetype == 12)
//			SendBtn.EnableWindow();
//		else
//		{
//			if (Me.IsShowWindow())
//				AddSystemMessage(3066);

//			SendBtn.DisableWindow();
//		}

		break;
	case EV_GamingStateExit:
		ReceiverID.ClearHistory();
		break;
	//	case EV_CleftListStart :
//			HandleCleftListStart();
	//		break;
	case EV_MailCommisionValue:     //LDW 우편 커미션 받기
		handleSetCommisionValue(Param);
		
		break;
	case EV_ReceiveFriendList:
	case EV_ConfirmAddingPostFriend:
	case EV_ReceivePostFriendList:
	case EV_ReceivePledgeMemberList:
		break;
	}
}

//////////////////////////////////////////////////////////////////////////////////

function handleSetCommisionValue( string Param )
{
	Parseint(Param, "Commision" ,BASE_FEE_ADENA);
	Parseint(Param, "PerSlot" ,FEE_PER_SLOT); 	
}

function UseInvenToAccompany(ItemInfo infItem)
{
	local int AccompanyItemID, invenItemID;
	local ItemInfo AccompanyInfo;
	invenItemID = InventoryItem.FindItem( infItem.id );	// ServerID
	AccompanyItemID = AccompanyItem.FindItem(infItem.id);

	if ( AccompanyItem.GetItemNum() < MAX_APPEND_ITEM_NUM)
	{		
		
		if (IsStackableItem( infItem.ConsumeType) && infItem.ItemNum != 1)
		{
			if ( class'InputAPI'.static.IsAltPressed() )
			{
				
				// 만약 ACCOMPANY에 아이템이 있다면 겹쳐줘야 한다.
				if (AccompanyItemID >= 0)
				{
					AccompanyItem.GetItem(AccompanyItemID, AccompanyInfo);
					// Accompany의 현재아이템 개수에 Inven에서 넘어오는 개수를 더해준다.
					AccompanyInfo.ItemNum += infItem.AllItemCount;
					AccompanyItem.SetItem(AccompanyItemID, AccompanyInfo);
				}
				else // 만약 Accompany에 아이템이 없다면 겹쳐주지 않아도 된다.
				{
					// Accompany에 없으므로 걍 더해준다.
					AccompanyItem.AddItem(infItem);
				}				
			
				InventoryItem.DeleteItem(InvenItemID);

				// 무게와 배송료를 계산한다.
				TotalWeight += infItem.Weight * int(infItem.ItemNum);
				SetWeight();				
			}
			else
			{
				DialogSetID(DIALOG_STACKABLE_ITEM_INVEN_TO_ACCOMPANY);
				DialogSetReservedItemInfo(infItem);
				DialogSetParamInt64(infItem.ItemNum);
				DialogShow(DialogModalType_Modalless, DialogType_NumberPad, MakeFullSystemMsg( GetSystemMessage(72), infItem.Name, "" ), string(Self) );
			}
		}
		else
		{
			TotalWeight += infItem.Weight;

			InventoryItem.DeleteItem(invenItemID);


			if (IsStackableItem(infItem.ConsumeType))
			{
				if (AccompanyItemID >= 0)
				{
					AccompanyItem.GetItem(AccompanyItemID, AccompanyInfo);
					AccompanyInfo.ItemNum += 1;
					AccompanyItem.SetItem(AccompanyItemID, AccompanyInfo);
				}
				else
				{
					AccompanyItem.AddItem(infItem);
				}
			}
			else
			{
				AccompanyItem.AddItem(infItem);
			}
			FeeAdena = CalculateFeeAdena();			
			SetWeight();
			SetFeeAdena();
		}
	}
	else if (AccompanyItem.GetItemNum() == MAX_APPEND_ITEM_NUM && IsStackableItem( infItem.ConsumeType) && AccompanyItemID >= 0 )	//8개 일경우는 스태커블한거만 이동이 가능
	{		
		if ((infItem.ItemNum != 1 && infItem.AllItemCount > 0) || infItem.ItemNum == 1 )
		{
			AccompanyItem.GetItem(AccompanyItemID, AccompanyInfo);
			// Accompany의 현재아이템 개수에 Inven에서 넘어오는 개수를 더해준다.
			AccompanyInfo.ItemNum += infItem.ItemNum;
			AccompanyItem.SetItem(AccompanyItemID, AccompanyInfo);

			InventoryItem.DeleteItem(InvenItemID);

			// 무게와 배송료를 계산한다.
			TotalWeight += infItem.Weight * int(infItem.ItemNum);
			FeeAdena = CalculateFeeAdena();
			SetWeight();
			SetFeeAdena();
			Debug("몰땅");
		}
		else
		{
			Debug("하ㅏ나");
			DialogSetID(DIALOG_STACKABLE_ITEM_INVEN_TO_ACCOMPANY);
			DialogSetReservedItemInfo(infItem);
			DialogSetParamInt64(infItem.ItemNum);
			DialogShow(DialogModalType_Modalless, DialogType_NumberPad, MakeFullSystemMsg( GetSystemMessage(72), infItem.Name, "" ), string(Self) );
		}
	}
	else
	{
		DialogHide();	// 이미 창이 떠있다면 지워준다.
		DialogShow(DialogModalType_Modalless,DialogType_Notice, GetSystemMessage(3016), string(Self));
		DialogSetID(DIALOG_ONLY_NOTICE);

	}

	// "수량성 아이템에 대해서 alt 누르고 이동시 우편료 계산이 안된다." 라는 문제
	// All , 모든 형태의 이동에 대해서 계산을 해줘야함 , alt , 그냥 drag&drop  , 2009. 9.17 추가 
	FeeAdena = CalculateFeeAdena();
	SetWeight();
	SetFeeAdena();
}
function UseAccompanyToInven(ItemInfo infItem)
{
	
	local int AccompanyItemID, InvenItemID;;
	local ItemInfo invenInfo;
	AccompanyItemID = AccompanyItem.FindItem( infItem.id);
	if (IsStackableItem( infItem.ConsumeType) && infItem.ItemNum != 1)
	{
		// 이거..문제가 있는듯.. 체크 해야함 2011-07-11 
		if (infItem.AllItemCount > 0 || class'InputAPI'.static.IsAltPressed())
		{
			invenItemID = InventoryItem.FindItem(infItem.id);
			// 만약 INVEN에 아이템이있다면 겹쳐줘야한다.
			if (invenItemID >= 0)
			{
				InventoryItem.GetItem(invenItemID, invenInfo);
				// 인벤의 현재 아이템 개수에 Accompany에서 넘어오는 개수를 더해준다.
				//invenInfo.ItemNum += infItem.AllItemCount;	
				invenInfo.ItemNum += infItem.itemNum;
				InventoryItem.SetItem(invenItemID, invenInfo);
			}
			else //만약 INVEN에 아이템이 없다면 겹쳐주지 않아도 된다. 
			{
				// Inven에 없으므로 걍 더해준다.
				InventoryItem.AddItem(infItem);
			}
		
			AccompanyItem.DeleteItem(AccompanyItemID);
		
			// 무게와 배송료를 계산한다.
			TotalWeight -= infItem.Weight * int(infItem.AllItemCount);
			FeeAdena = CalculateFeeAdena();
			SetWeight();
			SetFeeAdena();
		}
		else
		{
			DialogSetID(DIALOG_STACKABLE_ITEM_ACCOMPANY_TO_INVEN);
			DialogSetReservedItemInfo(infItem);
			DialogSetParamInt64(infItem.ItemNum);
			DialogShow(DialogModalType_Modalless, DialogType_NumberPad, MakeFullSystemMsg( GetSystemMessage(72), infItem.Name, "" ), string(Self) );
		}
		
	}
	else
	{
		TotalWeight -= infItem.Weight;

		AccompanyItem.DeleteItem(AccompanyItemID);
		if (IsStackableItem( infItem.ConsumeType))
		{
			InvenItemID = InventoryItem.FindItem( infItem.id);
			if (InvenItemID >= 0)
			{
				InventoryItem.GetItem(InvenItemID, invenInfo);
				invenInfo.ItemNum += 1;
				inventoryItem.SetItem(invenItemID, invenInfo);
			}
			else
			{
				InventoryItem.AddItem(infItem);
			}
		}
		else
		{
			InventoryItem.AddItem(infItem);
		}
		FeeAdena = CalculateFeeAdena();
		SetWeight();
		SetFeeAdena();
	}
	if ( AccompanyItem.GetItemNum() == 0 && ZoneType != 12 )
		SendBtn.EnableWindow();
}
function OnDropItem( String strID, ItemInfo infItem, int x, int y )
{
	
	if (strID == "AccompanyItem" && infItem.DragSrcName == "InventoryItem")
	{
		if ( ZoneType == 12 )
			UseInvenToAccompany(infItem);
	}	
	else if (strID == "InventoryItem" && infItem.DragSrcName == "AccompanyItem")
	{
		UseAccompanyToInven(infItem);	
	}
}

function OnDBClickItemWithHandle( ItemWindowHandle a_hItemWindow, int index )
{
	local ItemInfo info;
	if (a_hItemWindow.GetItem(index, info))
	{
		if (a_hItemWindow.GetWindowName() == "AccompanyItem")
		{
			UseAccompanyToInven(info);
		}
		else if (a_hItemWindow.GetWindowName() == "InventoryItem")
		{
			if ( ZoneType == 12 )
				UseInvenToAccompany(info);
		}
	}	
}
function OnRClickItemWithHandle( ItemWindowHandle a_hItemWindow, int index )
{
	local ItemInfo info;
	if (a_hItemWindow.GetItem(index, info))
	{
		if (a_hItemWindow.GetWindowName() == "AccompanyItem")
		{
			UseAccompanyToInven(info);
		}
		else if (a_hItemWindow.GetWindowName() == "InventoryItem")
		{
			if ( ZoneType == 12 )
				UseInvenToAccompany(info);
		}
	}
}

function OnComboBoxItemSelected( String strID, int index )
{
	switch(strID)
	{
	case "PostTypeComboBox":
		if (index ==  TRADE_NORMAL )
		{			
			DisableSafetyAdena();
		}
		else if (index == TRADE_SAFE)
		{
			EnableSafetyAdena();	
		}

		break;
	}
}

function setCombobox(int selectedNum)
{
	PostTypeComboBox.SetSelectedNum(selectedNum);
}

function DisableSafetyAdena()
{
	Title_SafetyTradeAdena.DisableWindow();
	SafetyReceiveAdena.DisableWindow();
	SafetyTradeAdenaTextBox.DisableWindow();
	SafetyTradeAdenaTextBoxBg.DisableWindow();
	SafetyReceiveAdenaIcon.DisableWindow();
		

	Title_SafetyTradeAdena.SetTextColor(disableColor);
	SafetyTradeAdenaTextBox.SetTextColor(disableColor);
	SafetyReceiveAdenaIcon.SetTexture("L2UI_ct1.Icon.Icon_DF_Common_Adena_disable");

	SafetyTradeAdenaTextBox.SetText("0");
	SafetyTradeAdena = 0;

	// 우편 보내기 - 일반우편
	Me.SetWindowTitle(GetSystemString(2031) $ " - " $ GetSystemString(2071));

	// 일반 우편 보내기
	SendBtn.SetNameText(MakeFullSystemMsg( GetSystemMessage(4412), GetSystemString(2071)));

	Title_SafetyTradeAdena.SetTextColor(getInstanceL2Util().White);

}
function EnableSafetyAdena()
{
	Title_SafetyTradeAdena.EnableWindow();
	SafetyReceiveAdena.EnableWindow();
	SafetyTradeAdenaTextBox.EnableWindow();
	SafetyTradeAdenaTextBoxBg.EnableWindow();
	SafetyReceiveAdenaIcon.EnableWindow();
	Title_SafetyTradeAdena.SetTextColor(enableColor);
	SafetyTradeAdenaTextBox.SetTextColor(enableColor);
	SafetyReceiveAdenaIcon.SetTexture("L2UI_ct1.Icon.Icon_DF_Common_Adena");

	// 우편 보내기 - 대금청구
	Me.SetWindowTitle(GetSystemString(2031) $ " - " $ GetSystemString(2072));

	// 대금청구 우편 보내기
	SendBtn.SetNameText(MakeFullSystemMsg( GetSystemMessage(4412), GetSystemString(2072)));

	
	Title_SafetyTradeAdena.SetTextColor(getInstanceL2Util().Yellow);

}
function SetWeight()
{
	WeightText.SetText(string(TotalWeight));
}
function SetFeeAdena()
{
	ChargeAdenaText.SetText(MakeCostString(string(FeeAdena)));
}

function HandleDialogOK()
{
	local ItemInfo scInfo;
	local INT64 inputNum;
	local INT64 adena;
	local int invenItemID, AccompanyItemID;
	local ItemInfo invenInfo, AccompanyInfo;
	local bool allItemMove; // 모든 아이템을 옮기는 것인가? 스태커블한 경우 모든 아이템을 a에서 b로 옮기는 것이라면 a에서 없애주어야한다.
	local int id;
	local String adenaStr;
	local Color textColor;
	
	local CustomTooltip cTooltip;

 
	if (DialogIsMine() )
	{
		id = DialogGetID();


		if (id == DIALOG_NOTIFY_SEND_POST)
		{
			SendPostMsg();
		}
		else if (id == DIALOG_RECEIVE_ADENA) // 받을돈
		{
			adena = INT64(DialogGetString());
			if (adena > INT64(ADENA_OVER_FLOW) || adena < 0)
			{
				DialogHide();	// 이미 창이 떠있다면 지워준다.
				DialogShow(DialogModalType_Modalless,DialogType_Notice, GetSystemMessage(1369), string(Self));		
			}
			else
			{
				SafetyTradeAdenaTextBox.SetText(MakeCostString(DialogGetString()));

				textColor = GetNumericColor(MakeCostString( SafetyTradeAdenaTextBox.GetText()));
				SafetyTradeAdenaTextBox.SetTextColor(textColor);

				adenaStr = SafetyTradeAdenaTextBox.GetText();
				
				addToolTipDrawList(cTooltip, addDrawItemText(ConvertNumToTextNoAdena(String(adena)) $ " " $ GetSystemString(469), getInstanceL2Util().White , "", false));

				SafetyTradeAdenaTextBox.SetTooltipCustomType(cTooltip);

				SafetyTradeAdena = adena;
			}
		}
		else if (id == DIALOG_STACKABLE_ITEM_ACCOMPANY_TO_INVEN || id == DIALOG_STACKABLE_ITEM_INVEN_TO_ACCOMPANY)
		{

			DialogGetReservedItemInfo( scInfo );
			inputNum =  INT64(DialogGetString() );
			// 요청한 개수는 0보다 커야한다.
			if (inputNum > 0 )
			{
				// 요청한 개수가 가지고 있는 수보다 크다면
				if (inputNum >= scInfo.ItemNum )
				{
					inputNum = scInfo.ItemNum; // 현재가지고 있는 수로 수정해준다. Maximum임..
					allItemMove = true; // Maixmum상태를 저장한다.
				}

				// ACCOMPANY 에서 INVEN으로
				if ( id == DIALOG_STACKABLE_ITEM_ACCOMPANY_TO_INVEN)
				{			
					invenItemID = InventoryItem.FindItem(scInfo.id);
					AccompanyItemID = AccompanyItem.FindItem(scInfo.id);
					// 만약 INVEN에 아이템이있다면 겹쳐줘야한다.
					if (invenItemID >= 0)
					{
						InventoryItem.GetItem(invenItemID, invenInfo);
						// 인벤의 현재 아이템 개수에 Accompany에서 넘어오는 개수를 더해준다.
						invenInfo.ItemNum += inputNum;	
						InventoryItem.SetItem(invenItemID, invenInfo);
					}
					else //만약 INVEN에 아이템이 없다면 겹쳐주지 않아도 된다. 
					{
						// Inven에 없으므로 걍 더해준다.
						AccompanyItem.GetItem(accompanyItemID, AccompanyInfo);
						AccompanyInfo.ItemNum = inputNum;
						InventoryItem.AddItem(AccompanyInfo);
					}
					
					
					if (allItemMove) // 완전 옮기는 것이므로 없애준다.
					{
						AccompanyItem.DeleteItem(AccompanyItemID);
					}
					else	// 일부만 옮겨주므로 개수를 수정한다.
					{
						scInfo.ItemNum -= inputNum;
						AccompanyItem.SetItem(AccompanyItemID, scInfo);
					}

					// 무게와 배송료를 계산한다.
					TotalWeight -= scInfo.Weight * int(inputNum);
					FeeAdena = CalculateFeeAdena();
					SetWeight();
					SetFeeAdena();
				}
				// INVEN 에서 ACCOMPANY로
				else if (id == DIALOG_STACKABLE_ITEM_INVEN_TO_ACCOMPANY )
				{
					AccompanyItemID = AccompanyItem.FindItem(scInfo.id);
					InvenItemID = InventoryItem.FindItem(scInfo.id);

					// 만약 ACCOMPANY에 아이템이 있다면 겹쳐줘야 한다.
					if (AccompanyItemID >= 0)
					{
						AccompanyItem.GetItem(AccompanyItemID, AccompanyInfo);
						// Accompany의 현재아이템 개수에 Inven에서 넘어오는 개수를 더해준다.
						AccompanyInfo.ItemNum += inputNum;
						AccompanyItem.SetItem(AccompanyItemID, AccompanyInfo);
					}
					else // 만약 Accompany에 아이템이 없다면 겹쳐주지 않아도 된다.
					{
						// Accompany에 없으므로 걍 더해준다.
						InventoryItem.GetItem(InvenItemID, InvenInfo);
						InvenInfo.ItemNum = inputNum;
						AccompanyItem.AddItem(InvenInfo);
					}
					
					if (allItemMove) // 완전 옮기는 것이므로 업애준다.
					{
						InventoryItem.DeleteItem(InvenItemID);
					}
					else	// 일부만 옮겨주므로 개수를 수정한다.
					{
						scInfo.ItemNum -= inputNum;
						InventoryItem.SetItem(InvenItemID, scInfo);
					}

					// 무게와 배송료를 계산한다.
					TotalWeight += scInfo.Weight * int(inputNum);
					FeeAdena = CalculateFeeAdena();
					SetWeight();
					SetFeeAdena();
				}
			}
		}
	}
}
function HandlePostWriteOpen()
{

	if (PostBoxWnd.IsShowwindow())
	{
		PostBoxWnd.HideWindow();
	}
}

function HandleSentEnableAddItem( string param)
{
	local ItemInfo info;

	ParamToItemInfo( param, info );
	
	InventoryItem.AddItem(info);
	if (info.id.classid == 57)	
	{
		adenaInfo = info;
		InventoryItem.SwapItems(0, InventoryItem.GetItemNum() - 1);
	}
}

function HandlePostWriteEnd()
{
	SetInventoryPageNumber();
}
function HandleReplyWritePost(string param)
{
	local int isuccess;
	ParseInt(param, "Success", isuccess);

	if (isuccess == 1)
	{
		ReceiverID.AddItemToAutoCompleteHistory( strSendID );
		Me.hidewindow();
		ClearAll();
	}

}
function HandleSendBtn()
{
	if (PostTypeComboBox.GetSelectedNum() == 1 && AccompanyItem.GetItemNum() <= 0) //안전거래인데 첨부한 아이템이 없다면
	{
		DialogHide();	// 이미 창이 떠있다면 지워준다.
		DialogShow(DialogModalType_Modalless,DialogType_Notice, GetSystemMessage(2966), string(Self));		
		DialogSetID(DIALOG_ONLY_NOTICE);

	}
	else if (PostTitle.GetString() == "" )
	{
		DialogHide();	// 이미 창이 떠있다면 지워준다.
		DialogShow(DialogModalType_Modalless,DialogType_Notice, GetSystemMessage(328), string(Self));	
		DialogSetID(DIALOG_ONLY_NOTICE);
	}
	else if(PostTypeComboBox.GetSelectedNum() == 1 && SafetyTradeAdena == 0 )
	{
		DialogHide();	// 이미 창이 떠있다면 지워준다.
		DialogShow(DialogModalType_Modalless,DialogType_Notice, GetSystemMessage(3020), string(Self));		
		DialogSetID(DIALOG_ONLY_NOTICE);
	}
	else if (Len(ReceiverID.GetString()) > MAX_CHAR_LENGTH)
	{
		DialogHide();	// 이미 창이 떠있다면 지워준다.
		DialogShow(DialogModalType_Modalless,DialogType_Notice, GetSystemMessage(3074), string(Self));		
		DialogSetID(DIALOG_ONLY_NOTICE);
	}
	else if (Len(PostTitle.GetString()) > MAX_TITLE_LENGTH)
	{
		DialogHide();	// 이미 창이 떠있다면 지워준다.
		DialogShow(DialogModalType_Modalless,DialogType_Notice, GetSystemMessage(3075), string(Self));		
		DialogSetID(DIALOG_ONLY_NOTICE);
	}
	else if (Len(Contents.GetString()) > MAX_CONTENTS_LENGTH)
	{
		DialogHide();	// 이미 창이 떠있다면 지워준다.
		DialogShow(DialogModalType_Modalless,DialogType_Notice, GetSystemMessage(3076), string(Self));		
		DialogSetID(DIALOG_ONLY_NOTICE);
	}
	else
	{
		DialogHide();
		if (PostTypeComboBox.GetSelectedNum() == 0 )	//일반우편이면
		{
			DialogShow(DialogModalType_Modal,DialogType_OKCancel, GetSystemMessage(2967), string(Self));
		}
		else											//대금청구이면
		{
			DialogShow(DialogModalType_Modal,DialogType_OKCancel, GetSystemMessage(3078), string(Self));
		}		
		DialogSetID(DIALOG_NOTIFY_SEND_POST);
//		DialogSetHostWndScript(myScript);
	}
}

function HandleSafetyReceiveAdena()
{
	DialogSetID(DIALOG_RECEIVE_ADENA);
	DialogSetParamInt64(0);
	DialogShow(DialogModalType_Modal, DialogType_NumberPad, GetSystemMessage(2987), string(Self));
	
}


function SendPostMsg()
{
	local int i;
	local ItemInfo iteminfo;
	local RequestItem item;
	local string ReceiverName;
	itemIDList.Remove(0, itemIDList.Length);
//	itemAmountList.Remove(0, itemAmountList.Length);

	for (i = 0; i < AccompanyItem.GetItemNum(); i++)
	{		
		AccompanyItem.GetItem(i, iteminfo);
		item.id = iteminfo.id.serverid;
		item.amount = iteminfo.ItemNum;
		itemIDList.Insert(itemIDList.Length,1); itemIDList[itemIDList.Length - 1] = item;
	}
	if (PostTypeComboBox.GetSelectedNum() == 0)
		SafetyTradeAdena = 0;
	strSendID = ReceiverID.GetString();

	//branch EP1.0 2014-6-18 luciper3 - 우편 보낼때 수신자가 없으면 보내지 않는다.
	ReceiverName = ReceiverID.GetString();
	if( Len( ReceiverName ) > 0  )
		RequestSendPost(ReceiverID.GetString(), PostTypeComboBox.GetSelectedNum(), PostTitle.GetString(), Contents.GetString(), itemIDList, SafetyTradeAdena);
	else
		AddSystemMessage(3002);  //  수신자가 존재하지 않거나 삭제된 캐릭터일 경우에는 우편발송이 불가능합니다.
	//end of branch


}

function ClearAll()
{
	PostTypeComboBox.clear();
	PostTypeComboBox.AddStringWithReserved(GetSystemString(2071),0);
	PostTypeComboBox.AddStringWithReserved(GetSystemString(2072),1);
	PostTypeComboBox.SetSelectedNum(0);

	FeeAdena = 0;
	TotalWeight = 0;
	SafetyTradeAdena = 0;

	ReceiverID.SetString("");
	ReceiverID.SetMaxLength(MAX_CHAR_LENGTH);
	PostTypeComboBox.SetSelectedNum(0);
	PostTitle.SetString("");
	PostTitle.SetMaxLength(MAX_TITLE_LENGTH);
	Contents.SetString("");
	itemIDList.Remove(0, itemIDList.Length);
	SafetyTradeAdena = 0;
	//AdenaTextBox.SetText("0");
	SafetyTradeAdenaTextBox.SetText("0");
	WeightText.SetText("0");
	ChargeAdenaText.SetText("0");
	AccompanyItem.clear();
	InventoryItem.clear();

	FeeAdena = CalculateFeeAdena();
	SetWeight();
	SetFeeAdena();

	DisableSafetyAdena();

}

function SetPostWriteWnd(string senderName, string title, string context)
{
	ClearAll();
	ReceiverID.SetString(senderName);
	PostTitle.SetString(title);
	Contents.SetString(context);
	Me.ShowWindow();
	Me.Setfocus();
}
function int CalculateFeeAdena()
{
	local int Fee;
//	Fee = BASE_FEE_ADENA + allweight * FEEMUITIPLIER;
	FEE = BASE_FEE_ADENA + FEE_PER_SLOT * AccompanyItem.GetItemNum();
	return Fee;
}
function SetInventoryPageNumber()
{
	if (InventoryItem.GetSideTypePageNum() == 0 )
	{
		InventoryPageNumber.SetText("0/0");
	}
	else
	{
		InventoryPageNumber.SetText(string(InventoryItem.GetSideTypeCurPage() + 1)$"/"$string(InventoryItem.GetSideTypePageNum()));
	}
}

function OnKeyUp( WindowHandle a_WindowHandle, EInputKey nKey )
{
	if(nKey == EInputKey.IK_Tab)
	{
		if (ReceiverID.IsFocused())
		{
			PostTitle.Setfocus();
		}
		else if (PostTitle.IsFocused())
		{
			Contents.Setfocus();
		}
	}		
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( m_WindowName ).HideWindow();
}

defaultproperties
{
    m_WindowName="PostWriteWnd"
}
