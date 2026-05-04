class PostDetailWnd_General extends UICommonAPI;


var WindowHandle Me;
var WindowHandle SafetyTrade;

var TextboxHandle Title_SenderID;
var TextboxHandle SenderID;
var TextboxHandle PostType;
var TextboxHandle PostTitle;
var TextListBoxHandle PostContents;  
var TextboxHandle WeightText;

var ButtonHandle SendCancelBtn;
var ButtonHandle ReceiveBtn;
var ButtonHandle ReturnBtn;
var ButtonHandle ReplyBtn;
//선준 수정(10.03.19)
var ButtonHandle AddBtn;

var ItemWindowHandle AccompanyItem;

var int trade;		//안전거래, 일반우편
var int returnd;	//반송여부
var int mailID;
var int totalWeight;//총  무게
var int returnable, sentbysystem;

//var int IsPeaceZone;

const DIALOG_RETURN_POST = 1111;
//branch110706 인게임샵
const DIALOG_NOTIFY_SEND_CANCLE_PRIMESHOP = 2222;
//end of branch

function OnRegisterEvent()
{
	registerEvent( EV_ReplyReceivedPostStart ); 
	registerEvent( EV_ReplyReceivedPostAddItem );
	registerEvent( EV_ReplyReceivedPostEnd );

	registerEvent( EV_ReplySentPostStart ); 
	registerEvent( EV_ReplySentPostAddItem );
	registerEvent( EV_ReplySentPostEnd );
	registerEvent( EV_DialogOK );

	registerEvent( EV_SetRadarZoneCode );
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

//	ResetUI();
	totalWeight = 0;
}

function OnShow()
{
	if (SafetyTrade.IsShowWindow())
		SafetyTrade.HideWindow();
}

function Initialize()
{
	Me = GetHandle("PostDetailWnd_General");
	SafetyTrade = GetHandle("PostDetailWnd_SafetyTrade");
	
	Title_SenderID=TextboxHandle(GetHandle("PostDetailWnd_General.Title_SenderID"));
	SenderID=TextboxHandle(GetHandle("PostDetailWnd_General.SenderID"));
	PostType=TextboxHandle(GetHandle("PostDetailWnd_General.PostType"));
	PostTitle=TextboxHandle(GetHandle("PostDetailWnd_General.PostTitle"));
	PostContents=TextListBoxHandle(GetHandle("PostDetailWnd_General.PostContents"));
	WeightText=TextboxHandle(GetHandle("PostDetailWnd_General.WeightText"));
	
	SendCancelBtn=ButtonHandle (GetHandle("PostDetailWnd_General.SendCancelBtn"));
	ReceiveBtn=ButtonHandle (GetHandle("PostDetailWnd_General.ReceiveBtn"));
	ReturnBtn=ButtonHandle (GetHandle("PostDetailWnd_General.ReternBtn"));
	ReplyBtn=ButtonHandle (GetHandle("PostDetailWnd_General.ReplyBtn"));
	//선준 수정(10.03.19)
	AddBtn=ButtonHandle (GetHandle("PostDetailWnd_General.AddBtn"));

	AccompanyItem = ItemWindowHandle(GetHandle("PostDetailWnd_General.AccompanyItem"));
	

}

function InitializeCOD()
{
	
	Me = GetWindowHandle("PostDetailWnd_General.PostDetailWnd_General");
	SafetyTrade = GetWindowHandle("PostDetailWnd_SafetyTrade");

	Title_SenderID=GetTextBoxHandle("PostDetailWnd_General.Title_SenderID");
	SenderID=GetTextBoxHandle("PostDetailWnd_General.SenderID");
	PostType=GetTextBoxHandle("PostDetailWnd_General.PostType");
	PostTitle=GetTextBoxHandle("PostDetailWnd_General.PostTitle");
	PostContents = GetTextListBoxHandle("PostDetailWnd_General.PostContents");
	WeightText=GetTextBoxHandle("PostDetailWnd_General.WeightText");

	SendCancelBtn=GetButtonHandle("PostDetailWnd_General.SendCancelBtn");
	ReceiveBtn=GetButtonHandle("PostDetailWnd_General.ReceiveBtn");
	ReturnBtn=GetButtonHandle("PostDetailWnd_General.ReternBtn");
	ReplyBtn=GetButtonHandle("PostDetailWnd_General.ReplyBtn");
	//선준 수정(10.03.19)
	AddBtn=GetButtonHandle("PostDetailWnd_General.AddBtn");

	AccompanyItem = GetItemWindowHandle("PostDetailWnd_General.AccompanyItem");
}


function OnEvent( int Event_ID, String Param )
{
	local int zonetype;
	switch(Event_ID)
	{
	case EV_ReplyReceivedPostStart:		
		OnEVReplyReceivedPostStart(Param);
		break;
	case EV_ReplyReceivedPostAddItem:
		OnEVReplyReceivedPostAddItem(Param);
		break;
	case EV_ReplyReceivedPostEnd:
		OnEVReplyReceivedPostEnd(Param);
		break;

	case EV_ReplySentPostStart:
		OnEVReplySentPostStart(Param);
		break;
	case EV_ReplySentPostAddItem:
		OnEVReplySentPostAddItem(Param);
		break;
	case EV_ReplySentPostEnd:
		OnEVReplySentPostEnd(Param);
		break;
	case EV_DialogOK:
		HandleDialogOK();
		break;	
	case EV_SetRadarZoneCode:
		ParseInt( Param, "ZoneCode", zonetype );
		if (zonetype == 12)
		{
			SendCancelBtn.EnableWindow();
			ReceiveBtn.EnableWindow();
			ReturnBtn.EnableWindow();
//			ReplyBtn.EnableWindow();
		}
		else
		{
			if (Me.IsShowWindow())
				AddSystemMessage(3066);

			SendCancelBtn.DisableWindow();
			ReceiveBtn.DisableWindow();
			ReturnBtn.DisableWindow();
//			if ( AccompanyItem.GetItemNum() > 0 )
//				ReplyBtn.DisableWindow();
		}

		break;
	}
}


function OnEVReplyReceivedPostStart(String Param)
{
	ClearAll();
	ParseInt(param, "trade", trade);
	ParseInt(param, "Returnd", returnd);  // 반송된 메일인가(1), 아닌가(0)	

	if (returnd == 1 || trade == 0 ) //반송된경우이거나, 일반우편일경우
	{
		Me.SetWindowTitle(GetSystemString(2075));
		ReceiveBtn.Hidewindow();
		ReturnBtn.ShowWindow();
		SendCancelBtn.HideWindow();
//		ReturnBtn.ShowWindow();			//위랑 똑같아서 제거.

		Me.ShowWindow();
		Me.Setfocus();
		
	}

	totalWeight =0;
	
}

function OnEVReplyReceivedPostAddItem(String Param)
{
	local ItemInfo info;

	if (returnd == 1 || trade == 0 ) //일반우편이면
	{
		ParamToItemInfo( param, info );
		AccompanyItem.AddItem(info);

		totalWeight += info.Weight * int(info.ItemNum);
	}
}

function string addComma (bool bComma, string text)
{	
	if (bComma) 
	{ 		
		return ", " $ text; 
	}	
	// Debug (text);
	return text;
}

function OnEVReplyReceivedPostEnd(String Param)
{
	local string SenderName, title, contents;
	local INT64 tradeMoney;
	local string fixedtitle;
	local int SendId, contentSystemMsgID, classID, enchant;
	local string NPCName;
	local int titleSystemMsgId;

	local int valueFire, valueWater, 
			  valueWind, valueEarth, 
			  valueHoly, valueUnholy;
	
	local bool isAttribute; // 속성이 한개라도 있나 

	local string attStr;

	local ItemID   cItemID;
	local ItemInfo cItemInfo;

	Title_SenderID.SetText(GetSystemString(2078));
	
	if (returnd == 1 || trade == 0)
	{
		ParseInt(param,    "MailID", mailID);  
		ParseString(param, "SenderName"         , SenderName);	        // 보낸 사람
		ParseInt(param   , "SenderId"           , SendId);	            // 보낸 사람 ID
		ParseString(param, "Title"              , title);			    // 제목
		ParseInt(param   , "TitleSystemMsgId"   , titleSystemMsgId);    // 제목ID
		ParseString(param, "Content"            , contents);		    // 내용
		ParseInt(param   , "ContentSystemMsgID" , contentSystemMsgID);  // 내용ID
		ParseInt(param   , "ClassID"            , classID);             // 아이템의 클래스ID
		ParseInt(param   , "Enchant"            , enchant);             // 아이템의 인챈트 값 
		  
		ParseINT64(param, "TradeMoney", tradeMoney);    // 청구비용
		ParseInt(param, "ReturnAble"  , returnable);    // 취소할수있나(1), 없나(0)
		ParseInt(param, "Sentbysystem", sentbysystem);  // 시스템이 보낸메일인가(1), 아닌가(0)
		
		ParseInt(param, "attrFire"  , valueFire);  // 속성 (물, 불, 바람, 땅, 신성, 암흑)
		ParseInt(param, "attrWater" , valueWater);
		ParseInt(param, "attrWind"  , valueWind);
		ParseInt(param, "attrEarth" , valueEarth);
		ParseInt(param, "attrHoly"  , valueHoly);
		ParseInt(param, "attrUnholy", valueUnholy);

		// "일반우편" -> 2071 
		if( sentbysystem == 7 ) //선물우편
		{
			PostType.SetText(GetSystemString(5080));
		}
		else
		{
			PostType.SetText(GetSystemString(2071)); //일반우편
		}
		
		////////////////////////
		// -- 제목 출력 --
		////////////////////////
		// 판매 대행(4,5) 인 경우 
		// 4: 기간이 만료되서 돌아왔을때..
		// 5: 팔렸다는 메일이 올때..
		if(sentbysystem == 4 || sentbysystem == 5)
		{
			// 등록하신 물품의 등록 기간이 만료되었습니다. -> 3492
			// 등록하신 물품이 판매되었습니다. -> 3490
			title = GetSystemMessage(titleSystemMsgId);
		}

		// debug("post:" @ Param);
		
		// 너무 제목이 길면 말줄임 ...
		fixedtitle = DivideStringWithWidth(title, 380);
		if (fixedtitle != title)
		{
			fixedtitle =  fixedtitle $ "...";
		}
		
		if(returnd == 1)
		{
			fixedtitle = "["$GetSystemString(2090)$"] "$fixedtitle;
			PostTitle.SetText(fixedtitle);
		}
		else
		{
			PostTitle.SetText(fixedtitle);
		}

		// Debug("::" @contents);
		
		isAttribute = false;

		////////////////////////
		// -- 내용 출력 --
		////////////////////////
		// 판매 대행(4,5) 인 경우 
		// 4: 기간이 만료되서 돌아왔을때..
		// 5: 팔렸다는 메일이 올때..
		if(sentbysystem == 4)
		{
			// 등록하신 물품의 등록 기간이 만료되었습니다. 
			contents = GetSystemMessage(contentSystemMsgID);
		}
		else if (sentbysystem == 5)
		{
			// 아이템 정보 얻기 
			cItemID.ClassID = classID; 
			class'UIDATA_ITEM'.static.GetItemInfo(cItemID, cItemInfo);

			if (cItemInfo.ItemType == EItemType.ITEM_WEAPON)
			{
				// Debug("무기" @ cItemInfo.ItemType);
				
				// 인챈트 수치 +
				if (enchant > 0) contents = "+" $ string(enchant) $ " " $ contents;
				
				// 1596 속성  -> "(속성: " 이후는 아래 조건에 따라서..
				contents = contents $ "( " $ GetSystemString(1596) $ ": ";
				// Debug("::" @contents);

				if (valueFire > 0)
				{
					attStr = attStr $ addComma(isAttribute, GetSystemString(1622) $ valueFire);
					//attStr = attStr $ GetSystemString(1622) $ valueFire $ " ";					
					isAttribute = true;
				}
				if (valueWater > 0)
				{					
					attStr = attStr $  addComma(isAttribute, GetSystemString(1623) $ valueWater);
					isAttribute = true;
				}
				if (valueWind > 0)
				{
					attStr = attStr $ addComma(isAttribute, GetSystemString(1624) $ valueWind);
					isAttribute = true;
				}
				if (valueEarth > 0)
				{
					attStr = attStr $ addComma(isAttribute, GetSystemString(1625) $ valueEarth);
					isAttribute = true;
				}
				if (valueHoly > 0)
				{
					attStr = attStr $ addComma(isAttribute, GetSystemString(1626) $ valueHoly);
					isAttribute = true;
				}
				if (valueUnholy > 0)
				{
					attStr = attStr $  addComma(isAttribute, GetSystemString(1627) $ valueUnholy);
					isAttribute = true;
				}

				// 속성이 없는 경우 
				if (valueFire + valueWater + valueWind + valueEarth + valueHoly + valueUnholy <= 0)
				{
					// (속성: 없음) ,GetSystemString(27) = "없음"
					attStr = attStr $ GetSystemString(27);
				}

				contents = contents $ attStr $ " )";

				// .. 가 판매되었습니다.
				contents = MakeFullSystemMsg(GetSystemMessage(contentSystemMsgID), contents);
				// Debug("::" @contents);
			}
			else if (cItemInfo.ItemType == EItemType.ITEM_ARMOR)
			{
				// Debug("방어구  " @ contents);
				// 인챈트 수치 +
				if (enchant > 0) contents = "+" $ string(enchant) $ " " $ contents;

				// 1596 속성  -> "(속성: " 이후는 아래 조건에 따라서..
				contents = contents $ "( " $ GetSystemString(1596) $ ": ";
				// Debug("::" @contents);

				// 방어구는 속성에 대한 방어 , 반대 속성 스트링을 출력이라고 했으니.. 정보를 보니 그대로 출력 해줘도 될듯..				
				if (valueFire > 0)
				{
					attStr = attStr $ addComma(isAttribute, MakeFullSystemMsg(GetSystemMessage(2215), GetSystemString(1622) $ " ") $ valueFire);
					isAttribute = true;
				}
				if (valueWater > 0)
				{
					attStr = attStr $ addComma(isAttribute, MakeFullSystemMsg(GetSystemMessage(2215), GetSystemString(1623) $ " ") $ valueWater);
					isAttribute = true;
				}
				if (valueWind > 0)
				{
					attStr = attStr $ addComma(isAttribute, MakeFullSystemMsg(GetSystemMessage(2215), GetSystemString(1624) $ " ") $ valueWind);
					isAttribute = true;
				}
				if (valueEarth > 0)
				{
					attStr = attStr $ addComma(isAttribute, MakeFullSystemMsg(GetSystemMessage(2215), GetSystemString(1625) $ " ") $ valueEarth);
					isAttribute = true;
				}
				if (valueHoly > 0)
				{
					attStr = attStr $ addComma(isAttribute, MakeFullSystemMsg(GetSystemMessage(2215), GetSystemString(1626) $ " ") $ valueHoly);
					isAttribute = true;
				}
				if (valueUnholy > 0)
				{
					attStr = attStr $ addComma(isAttribute, MakeFullSystemMsg(GetSystemMessage(2215), GetSystemString(1627) $ " ") $ valueUnholy);
					isAttribute = true;
				}

				// 속성이 없는 경우 
				if (valueFire + valueWater + valueWind + valueEarth + valueHoly + valueUnholy <= 0)
				{
					// (속성: 없음) ,GetSystemString(27) = "없음"
					attStr = attStr $ GetSystemString(27);
				}

				contents = contents $ attStr $ " )";

				// Debug(attStr);
				// .. 가 판매되었습니다.
				
				contents = MakeFullSystemMsg(GetSystemMessage(contentSystemMsgID), contents);
				// Debug("::" @contents);
			}
			else
			{
				// Debug("일반 " @ contents);
				contents = MakeFullSystemMsg(GetSystemMessage(contentSystemMsgID), contents);		
			}
		}

		// 우편 내용 
		PostContents.AddString(contents,GetChatColorByType(0));
		// 텍스트 리스트 박스, 스크롤 가장 위로 초기화 
		PostContents.SetTextListBoxScrollPosition(0);

		if (AccompanyItem.GetItemNum() != 0 )
		{
			if (!ReceiveBtn.IsShowwindow()) ReceiveBtn.Showwindow();
		}

		if (returnable == 1)
		{
			if (ReceiveBtn.IsShowwindow())
			{
				ReceiveBtn.SetAnchor("PostDetailWnd_General", "BottomCenter", "BottomRight", -1, -4);
			}

			ReturnBtn.ShowWindow();
//			ReturnBtn.EnableWindow();
		}
		else
		{
			if (ReceiveBtn.IsShowwindow())
			{
				ReceiveBtn.SetAnchor("PostDetailWnd_General", "BottomCenter", "BottomCenter", 0, -4);
			}

			ReturnBtn.HideWindow();
		}

		// Debug("sentbysystem" @ sentbysystem);

		//#ifndef CT26P2_0825
		//		if (sentbysystem == 1) //시스템이 보낸메일이면
		//		{
		//			if (returnd == 1)
		//				SenderID.SetText(GetSystemString(2073));
		//			else
		//				SenderID.SetText(GetSystemString(2211));
		//
		//			if (ReceiveBtn.IsShowwindow())
		//			{
		//				ReceiveBtn.SetAnchor("PostDetailWnd_General", "BottomCenter", "BottomCenter", 0, -4);
		//			}
		//			ReturnBtn.HideWindow();
		//		}
		//		else
		//		{
		//			SenderID.SetText(SenderName);
		//		}
		//
		//		if (sentbysystem == 1)
		//		{
		//			ReplyBtn.HideWindow();
		//		}
		//		else
		//		{
		//			ReplyBtn.EnableWindow();
		//			ReplyBtn.ShowWindow();
		//		}
		//#endif 
		//#ifdef CT26P2_0825
		
		//************************************************************
		//*  우편 발신인 예외 처리 
		//************************************************************
		
		// 1: 시스템이 보낸 메일
		if (sentbysystem == 1) 
		{
			if (returnd == 1)
				SenderID.SetText(GetSystemString(2073));
			else
				SenderID.SetText(GetSystemString(2211));			
		}
		// NPC 한테 온경우
		else if ( sentbysystem ==2 )	
		{
			NPCName=class'UIDATA_NPC'.static.GetNPCName(SendId);
			if(Len(NPCName)>0)
				SenderID.SetText( NPCName );
		}
		// 알레그리아
		else if (sentbysystem == 3)
		{
			SenderID.SetText(GetSystemString(2316)); 
		}
		// 판매대행 4번은 만료등의 반품, 5번은 판매되었을때
		else if( sentbysystem == 4 || sentbysystem == 5 ) 
		{
			SenderID.SetText( GetSystemString( class'consignmentSaleAPI'.static.GetCommissionSellerID() ) );
		}
		// 멘토링에서 사용하는 번호 
		else if( sentbysystem == 6 ) 
		{			
			SendId = class'UIDATA_NPC'.static.GetMentoringNPCId();
			if (SendId > 0)
			{
				NPCName = class'UIDATA_NPC'.static.GetNPCName(SendId);
				if(Len(NPCName)>0)
					SenderID.SetText( NPCName );
			}
			else 
			{
				Debug("Error : 'SendId' is wrong" @ SendId);
			}

		}
		// 일반 유저 인 경우 
		else
		{
			SenderID.SetText(SenderName);
		}

		// 답장등, 버튼에 대한 , 예외 처리 
		if (sentbysystem == 1 || sentbysystem == 3 || sentbysystem == 5 || sentbysystem == 6 ) // 3: BirthDay Mail , 5번 판매대행, 6번 멘토링
		{
			if (ReceiveBtn.IsShowwindow())
			{
				ReceiveBtn.SetAnchor("PostDetailWnd_General", "BottomCenter", "BottomCenter", 0, -4);
			}
			ReturnBtn.HideWindow();
			ReplyBtn.HideWindow();
		}
		else
		{
			ReplyBtn.EnableWindow();
			ReplyBtn.ShowWindow();
		}
		
		if (AccompanyItem.GetItemNum() == 0 )
		{
			if (ReceiveBtn.IsShowwindow())
			{
				ReceiveBtn.SetAnchor("PostDetailWnd_General", "BottomCenter", "BottomCenter", 0, -4);
			}
			ReturnBtn.HideWindow();
		}
		
		if(sentbysystem == 9)
		{
			AddBtn.DisableWindow();
		}
		else
		{
			AddBtn.EnableWindow();
		}

		WeightText.SetText(string(totalWeight));
	}
}

function OnEVReplySentPostStart(String Param)
{
	ClearAll();
	ParseInt(param, "trade", trade);
	ParseInt(param, "Sentbysystem", sentbysystem);
	if (trade == 0 ) //일반우편이면
	{
		Me.SetWindowTitle(GetSystemString(2076));
		ReceiveBtn.Hidewindow();
		ReturnBtn.HideWindow();
		SendCancelBtn.ShowWindow();
		ReplyBtn.HideWindow();
		//ReturnBtn.Showwindow();
		Me.ShowWindow();
		Me.Setfocus();
	}
	if( sentbysystem == 7 ) //인게임샵 선물하기면 받는이추가를 삭제함
	{
		AddBtn.HideWindow();
	}
	else
	{
		AddBtn.Showwindow();
	}
}

function OnEVReplySentPostAddItem(String Param)
{
	local ItemInfo info;
	
	if (trade == 0 ) //일반우편이면
	{
		ParamToItemInfo( param, info );
		AccompanyItem.AddItem(info);

		Debug("OnEVReplySentPostAddItem" @ Param);
	}
}

function OnEVReplySentPostEnd(String Param)
{
	local string ReceiverName, title, contents;
	local INT64 tradeMoney;
	local int notOpend;
	local string fixedtitle;

	ParseInt(param, "Sentbysystem", sentbysystem);  // 시스템이 보낸메일인가(1), 아닌가(0)
	
	if (trade == 0)
	{
		ParseInt(param, "MailID", mailID);				// 메일 아이디
		ParseString(param, "ReceiverName", ReceiverName);	// 받을 사람
		ParseString(param, "Title", title);				// 제목
		ParseString(param, "Content", contents);		// 내용
		ParseINT64(param, "TradeMoney", tradeMoney);	// 청구비용
		ParseInt(param, "NotOpend", notOpend);  // 취소할수있나(1), 없나(0)
		ParseInt(param, "Sentbysystem", sentbysystem);  // 시스템이 보낸메일인가(1), 아닌가(0)

		if( sentbysystem == 7 ) //선물우편
		{
			PostType.SetText(GetSystemString(5080));
		}
		else
		{
			PostType.SetText(GetSystemString(2071)); //일반우편
		}
		
		fixedtitle = DivideStringWithWidth(title, 380);
		if (fixedtitle != title)
		{
			fixedtitle =  fixedtitle $ "...";
		}
		PostTitle.SetText(fixedtitle);


		Title_SenderID.SetText(GetSystemString(2087));
		PostContents.AddString(contents, GetChatColorByType(0));
		PostContents.SetTextListBoxScrollPosition(0);
		SenderID.SetText(ReceiverName);
	
		if (AccompanyItem.GetItemNum() != 0)
		{
			SendCancelBtn.ShowWindow();
//			SendCancelBtn.EnableWindow();
		}
		else
		{
		//	AddSystemMessage(3030);
			SendCancelBtn.HideWindow();
		}
	}
}

function ClearAll()
{
	SenderID.SetText("");
	PostType.SetText(GetSystemString(2071));
	PostTitle.SetText("");

	PostContents.Clear();
	WeightText.SetText("0");


	ReceiveBtn.HideWindow();
	ReturnBtn.HideWindow();
	SendCancelBtn.HideWindow();
	AccompanyItem.Clear();

}

function OnClickButton( String a_ButtonID )
{

	switch( a_ButtonID )
	{
	case "ReceiveBtn":
		RequestReceivePost(mailID);
		Me.HideWindow();
		break;
	case "ReternBtn":
		if (returnd == 1 || trade == 0 && returnable == 1)
		{
			DialogHide();
			DialogShow(DialogModalType_Modalless,DialogType_OKCancel, GetSystemMessage(3063), string(Self));
			DialogSetID(DIALOG_RETURN_POST);			
		}
		
		break;
	case "SendCancelBtn":
		//branch110706 인게임샵
		if(sentbysystem == 7) // 인게임샵에서 온 편지를 취소할때
		{		
			DialogHide();
			DialogShow(DialogModalType_Modalless,DialogType_OKCancel, GetSystemMessage(6066), string(Self));
			DialogSetID(DIALOG_NOTIFY_SEND_CANCLE_PRIMESHOP);
		}		
		else
		{
			RequestCancelSentPost(mailID);
			Me.HideWindow();
		}
		//end of branch
		break;
	case "ReplyBtn":
		HandleReplyBtn();
		break;
	//선준 수정(10.03.19)
	case "AddBtn":
		HandleAddBtn();
		break;
	}
}
function HandleDialogOK()
{
	local int id;
	if (DialogIsMine() )
	{
		id = DialogGetID();

	
		if (id == DIALOG_RETURN_POST )
		{
			RequestRejectPost(mailID);
			Me.HideWindow();
		}
		//branch110706 인게임샵
		else if (id == DIALOG_NOTIFY_SEND_CANCLE_PRIMESHOP )
		{
			RequestCancelSentPost(mailID);
			Me.HideWindow();
		}
		//end of branch
	}
}
function HandleReplyBtn()
{
	local PostWriteWnd script;
	local string title;
	
	if (returnd != 1)
	{
		RequestPostItemList();
		script = PostWriteWnd(GetScript("PostWriteWnd"));

		Me.HideWindow();
		title = "[Re]"$ PostTitle.GetText();
		script.SetPostWriteWnd(SenderID.GetText(), title, "");
	}
}
//선준 수정(10.03.19)
function HandleAddBtn()
{
	class'PostWndAPI'.static.RequestAddingPostFriend( SenderID.GetText() );
}


/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	class'UIAPI_WINDOW'.static.HideWindow("PostDetailWnd_General");		
}
defaultproperties
{
}
