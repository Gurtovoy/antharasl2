/**
 * 
 *   옥션
 *  
 *  Memo :
 *  2016.04.04 리뉴얼됨: 코드는 거의 그대로, 디자인 위주로 리뉴얼, 
 *  다음 경매 보기 버튼 삭제, 유찰금 받기 추가, 최고 입찰가 가독성 강화(텍스트로 읽어주기)
 *  
 **/
class AuctionWnd extends UICommonAPI;

// Sets Timer Value
const TIMER_ID=777; 
const TIMER_DELAY=1000; 

const DIALOG_ASK_AUCTION_PRICE	= 321;	// 옥션 가격 직접 입력 다이얼로그 ID
const DIALOG_CONFIRM_PRICE		= 432;	// 옥션 가격을 확인하는 다이얼로그 ID

const ADENA_OVER_FLOW = "1000000000000";		//입찰 오버플로우

// 각종 핸들 받아오기.
var WindowHandle Me;
var TextBoxHandle txtRemainStr;
var TextBoxHandle txtTimeHour;
var TextBoxHandle txtTimeMin;
var TextBoxHandle txtTimeSec;
var TextBoxHandle txtHighBid;
var TextBoxHandle txtMyAdenaStr;
var TextBoxHandle txtMyAdena;
var TextBoxHandle txtItemInfoStr;

var ButtonHandle BtnBid1;
var ButtonHandle BtnBid2;
var ButtonHandle BtnBid3;
var ButtonHandle BtnBid4;
var ButtonHandle BtnBidInput;
var TextBoxHandle txtHighBidStr;
//var TextBoxHandle txtInfo;

var ButtonHandle BtnClose;
var ButtonHandle BtnNext;
var ItemWindowHandle AuctionItem;
//var TextBoxHandle txtItemDesc;
var TextBoxHandle txtItemName;
//var WindowHandle areaScroll;
//var WindowHandle NextAuctionWnd;

var TextBoxHandle txtHighBid_word;

// 변수들
var INT64 m_myLastBidPrice;		 // 마지막으로 자신이 입찰했던 가격을 저장해둔다. 
var INT64 m_myBidPrice;		     // 입찰을 시도하는 가격
var INT64 m_currentPrice;		 // 현재 최고 입찰가
var int m_auctionID;		     // 현재 보고 있는 아이템의 옥션 아이디
var ItemInfo 	m_auctionItem;	 // 경매에 올라있는 아이템의 정보

var int 		bShowUI;
var int 		iAuctionID;
var INT64		iCurrentPrice;
var int 		iRemainSecond;

function OnRegisterEvent()
{
	// 이벤트 등록 
	RegisterEvent( EV_ITEM_AUCTION_INFO );
	RegisterEvent( EV_AdenaInvenCount );
	RegisterEvent( EV_DialogOK );
}

function OnLoad()
{
	SetClosingOnESC();

	Initialize();
	Load();
	
}

function Initialize()
{

	Me = GetWindowHandle( "AuctionWnd" );
	txtRemainStr = GetTextBoxHandle( "AuctionWnd.txtRemainStr" );
	txtTimeHour = GetTextBoxHandle( "AuctionWnd.txtTimeHour" );
	txtTimeMin = GetTextBoxHandle( "AuctionWnd.txtTimeMin" );
	txtTimeSec = GetTextBoxHandle( "AuctionWnd.txtTimeSec" );
	txtHighBid = GetTextBoxHandle( "AuctionWnd.txtHighBid" );

	txtMyAdenaStr = GetTextBoxHandle( "AuctionWnd.txtMyAdenaStr" );
	txtMyAdena = GetTextBoxHandle( "AuctionWnd.txtMyAdena" );
	txtItemInfoStr = GetTextBoxHandle( "AuctionWnd.txtItemInfoStr" );

	BtnBid1 = GetButtonHandle( "AuctionWnd.BtnBid1" );
	BtnBid2 = GetButtonHandle( "AuctionWnd.BtnBid2" );
	BtnBid3 = GetButtonHandle( "AuctionWnd.BtnBid3" );
	BtnBid4 = GetButtonHandle( "AuctionWnd.BtnBid4" );	
	BtnBidInput = GetButtonHandle( "AuctionWnd.BtnBidInput" );
	txtHighBidStr = GetTextBoxHandle( "AuctionWnd.txtHighBidStr" );

	//txtInfo = GetTextBoxHandle( "AuctionWnd.txtInfo" );

	BtnClose = GetButtonHandle( "AuctionWnd.BtnClose" );
	AuctionItem = GetItemWindowHandle ( "AuctionWnd.AuctionItem" );
	//txtItemDesc = GetTextBoxHandle( "AuctionWnd.scrollDesc.txtItemDesc" );
	txtItemName = GetTextBoxHandle( "AuctionWnd.txtItemName" );
	//areaScroll = GetWindowHandle( "AuctionWnd.scrollDesc" );
	BtnNext = GetButtonHandle( "AuctionWnd.BtnNextAuction" );
	//NextAuctionWnd = GetWindowHandle( "NextAuctionDrawerWnd" );

	// 최고 입찰가 가독성 개선 (읽어 주기 5억 이런식)
	txtHighBid_word = GetTextBoxHandle("AuctionWnd.txtHighBid_word");
}

function Load()
{
}

// 이벤트를 받아 데이터를 파싱한다. 
function OnEvent(int Event_ID, string param)
{
	//이벤트로 받는 정보
	local ItemInfo 	info;
	
	switch(Event_ID)
	{
		//기본 경매 이벤트
		case EV_ITEM_AUCTION_INFO:
		//case 0:
			ParseInt(param, "ShowUI", bShowUI);
			ParseInt(param, "AuctionID", iAuctionID);
			ParseInt64(param, "CurrentPrice", iCurrentPrice);
			ParseInt(param, "RemainSecond", iRemainSecond);		
			ParamToItemInfo( param, info );
		
			//전역 변수를 갱신해준다. 
			m_currentPrice = iCurrentPrice;	
			m_auctionID = iAuctionID;
			m_auctionItem = info;
		
			if( bShowUI == 1)
			{
				// 아이템 정보 추가 
				InsertAuctionItem();
				
				// 창이 처음 열릴때 타이머를 켠다.
				m_hOwnerWnd.SetTimer( TIMER_ID, TIMER_DELAY );	
				Me.ShowWindow();	
				Me.SetFocus();
			}
			
			//debug("bShowUI : " $ bShowUI $ "iAuctionID : " $ iAuctionID $ " iCurrentPrice : " $ iCurrentPrice $ "iRemainSecond : " $ iRemainSecond);
				
			// 정보를 갱신해주는 함수 호출
			UpdateAuctionWnd();
			break;
			
		case EV_AdenaInvenCount :
			myUpdateAdena();
			break;

		// 가격 직접 입력 확인시		
		case EV_DialogOK:	
			HandleDialogOK();
			break;
	}
}

function OnTimer(int TimerID)
{
	// Sending packet in Timer may be very dangerous and unhealthy.
	// Be aware of its influence over performance. If you are uncertain always contact client team member.
	if(TimerID == TIMER_ID)
	{
		class'AuctionAPI'.static.RequestInfoItemAuction( m_auctionID  );	// 정보 갱신 요청
	}
}

function InsertAuctionItem()
{
	AuctionItem.clear();
	AuctionItem.AddItem( m_auctionItem );
	AuctionItem.SetTooltipType( "Inventory");
	
	//class'UIDATA_ITEM'.static.GetItemInfo( info.Id , tempInfo);
	txtItemName.setText( m_auctionItem.Name );
	//txtItemDesc.setText( info.Name $ ": 조낸짱좋은 아이템. 천억 아데나가 아깝지 안타" );
	//ComputeScrollHeight( m_auctionItem.Description );	//높이를 계산해준다. 
	//txtItemDesc.setText( m_auctionItem.Description );
}

//function ComputeScrollHeight(string tempStr)
//{
//	local int nHeight;
//	local int nWidth;
	
//	local Rect rectWnd;
	
//	rectWnd = txtItemDesc.GetRect();
	
//	GetTextSizeDefault(tempStr, nWidth, nHeight);		// 사이즈를 받아서
	
//	areaScroll.SetScrollHeight((nHeight + 1) * (nWidth / rectWnd.nWidth + 1));
//	//debug("nHeight : " $ nHeight $ " nWidth : " $ nWidth $ "nWidth / rectWnd.nWidth : " $ (nWidth / rectWnd.nWidth));
//	areaScroll.SetScrollPosition( 0 );
//}

function OnShow()
{
	BtnNext.EnableWindow();
	BtnBid1.EnableWindow();
	BtnBid2.EnableWindow();
	BtnBid3.EnableWindow();
	BtnBid4.EnableWindow();
	BtnBidInput.EnableWindow();
}

function OnHide()
{
	// 창이 닫힐 경우 타이머를 꺼줘야 한다. 
	class'UIAPI_WINDOW'.static.KillUITimer("AuctionWnd",Timer_ID);  	// 타이머 끄기
	class'UIAPI_ITEMWINDOW'.static.Clear("AuctionWnd.AuctionItem");	// 아이템 윈도우 클리어
	//NextAuctionWnd.HideWindow();
}

function OnClickButton( string Name )
{
	m_myBidPrice = -1;


	switch( Name )
	{
		case "BtnBid1":	// 2배
			m_myBidPrice = m_currentPrice * 2;
			if (m_myBidPrice > INT64(ADENA_OVER_FLOW) || m_myBidPrice< 0)	//음수 혹은 21억을 넘으면 입찰 금지
			{			
				BtnBid1.DisableWindow();
				BtnBid1.SetTooltipCustomType( MakeTooltipSimpleText( GetSystemMessage(2157)));
			}
			else
			{
				DialogSetID( DIALOG_CONFIRM_PRICE );
				DialogShow(DialogModalType_Modalless, DialogType_Warning, MakeFullSystemMsg( GetSystemMessage(2137), m_auctionItem.Name, MakeCostString(string(m_myBidPrice) )), string(Self) );
			}
			//class'AuctionAPI'.static.RequestBidItemAuction( m_auctionID ,  m_myBidPrice);	// 입찰을 시도합니다.
			break;

		case "BtnBid2":	// 50%
			//m_myBidPrice = m_currentPrice * 0.5 + m_currentPrice;
			m_myBidPrice = ((m_currentPrice * 5) / 10)  + m_currentPrice;
			
			if (m_myBidPrice > INT64(ADENA_OVER_FLOW) || m_myBidPrice< 0)	//음수 혹은 21억을 넘으면 입찰 금지
			{
				BtnBid2.DisableWindow();
				BtnBid2.SetTooltipCustomType( MakeTooltipSimpleText( GetSystemMessage(2157)));
			}
			else
			{
				DialogSetID( DIALOG_CONFIRM_PRICE );
				DialogShow(DialogModalType_Modalless, DialogType_Warning, MakeFullSystemMsg( GetSystemMessage(2137), m_auctionItem.Name, MakeCostString(string(m_myBidPrice) ) ), string(Self));
			}
			//class'AuctionAPI'.static.RequestBidItemAuction( m_auctionID ,  m_myBidPrice);	// 입찰을 시도합니다.
			break;

		case "BtnBid3":
			m_myBidPrice = (m_currentPrice / 10) + m_currentPrice;;	
			if (m_myBidPrice > INT64(ADENA_OVER_FLOW) || m_myBidPrice< 0)	//음수 혹은 21억을 넘으면 입찰 금지
			{
				BtnBid3.DisableWindow();
				BtnBid3.SetTooltipCustomType( MakeTooltipSimpleText( GetSystemMessage(2157)));
			}
			else
			{
				DialogSetID( DIALOG_CONFIRM_PRICE );
				DialogShow(DialogModalType_Modalless, DialogType_Warning, MakeFullSystemMsg( GetSystemMessage(2137), m_auctionItem.Name, MakeCostString(string(m_myBidPrice) )), string(Self) );
			}
			//class'AuctionAPI'.static.RequestBidItemAuction( m_auctionID ,  m_myBidPrice);	// 입찰을 시도합니다.
			break;
		case "BtnBid4":

			m_myBidPrice = ((m_currentPrice * 5) / 100) + m_currentPrice;;	

			Debug("m_myBidPrice" @  m_myBidPrice);
			if (m_myBidPrice > INT64(ADENA_OVER_FLOW) || m_myBidPrice< 0)	//음수 혹은 21억을 넘으면 입찰 금지
			{
				BtnBid4.DisableWindow();
				BtnBid4.SetTooltipCustomType( MakeTooltipSimpleText( GetSystemMessage(2157)));
			}
			else
			{
				DialogSetID( DIALOG_CONFIRM_PRICE );
				DialogShow(DialogModalType_Modalless, DialogType_Warning, MakeFullSystemMsg( GetSystemMessage(2137), m_auctionItem.Name, MakeCostString(string(m_myBidPrice) )), string(Self) );

				Debug("MakeCostString(string(m_myBidPrice) )" @ MakeCostString(string(m_myBidPrice) ));
			}
			//class'AuctionAPI'.static.RequestBidItemAuction( m_auctionID ,  m_myBidPrice);	// 입찰을 시도합니다.
			break;		

		case "BtnBidInput":
			OnBtnBidInputClick();
			break;

		case "BtnClose":
			if( IsShowWindow("AuctionWnd"))
				HideWindow("AuctionWnd");
			//NextAuctionWnd.HideWindow();
			break;

		// 유찰금 받기 2016-04-04 추가
		case "BtnFailBid" :
			// 유찰금 받기 
			RequestBypassToServer( "item_auction_withdraw" );
			Debug("유찰금 받기 실행!");
			break;
	}
}

function myUpdateAdena()
{
	local CustomTooltip cTooltip;

	// 내 소지금 갱신.
	//txtMyAdena.setText(MakeCostString( string(GetAdena()) ) $ " " $ GetSystemString(469));
	txtMyAdena.setText(MakeCostString( string(GetAdena()) ) );

	// 아데나 읽어 주는 툴팁 추가
	addToolTipDrawList(cTooltip, addDrawItemText(ConvertNumToTextNoAdena(String(GetAdena())) $ " " $ GetSystemString(469), getInstanceL2Util().White , "", false));
	txtMyAdena.SetTooltipCustomType(cTooltip);
}

function UpdateAuctionWnd()
{
	local int temp1;
	local int m_timeHour;
	local int m_timeMin;
	local int m_timeSec;

		
	local string tempStr;
	//local int myAdena;

	local INT64 tempPrice;
	
	
	// 현재 최고가를 갱신해준다.  
	//txtHighBid.setText( MakeCostString( string(m_currentPrice) ) $ " adena");
	txtHighBid.setText( MakeCostString( string(m_currentPrice) ) $ " " $ GetSystemString(469));
	txtHighBid.SetTextColor( GetNumericColor( string(m_currentPrice) ) );

	// 아데나 읽어 주기
	txtHighBid_word.SetTextColor( GetNumericColor( string(m_currentPrice) ) );
	txtHighBid_word.SetText(ConvertNumToTextNoAdena(string(m_currentPrice)) $ " " $ GetSystemString(469));

	//MyAdena.SetTooltipString( ConvertNumToText(string(GetAdena())) );

	myUpdateAdena();

	// 시간 갱신. 
	m_timeSec = iRemainSecond % 60;	// 초
	temp1 = iRemainSecond / 60;
	m_timeHour = temp1 / 60;			// 시
	m_timeMin = temp1 % 60;			// 분?
	
	//debug(" m_timeHour : " $ m_timeHour $ "m_timeMin : "  $ m_timeMin$ "m_timeSec : "  $ m_timeSec);
	
	// 시를 그려준다.
	if(m_timeHour > 0)
	{
		if (m_timeHour < 10 ) txtTimeHour.setText( "0" $ string( m_timeHour ));
		else txtTimeHour.setText( string( m_timeHour ));
	}
	else
	{
		txtTimeHour.setText( "00");
	}
	
	// 분을 그려준다.
	if( m_timeMin > 0)
	{
		if (m_timeMin < 10 ) txtTimeMin.setText( "0" $ string( m_timeMin ));
		else txtTimeMin.setText( string( m_timeMin ));
	}
	else
	{
		txtTimeMin.setText( "00");
	}
		
	// 초를 그려준다. 
	if(m_timeSec > 0)
	{
		if (m_timeSec < 10 ) txtTimeSec.setText( "0" $ string( m_timeSec ));
		else txtTimeSec.setText( string( m_timeSec ));
	}
	else
	{
		txtTimeSec.setText( "00");
	}
	//txtRemainTime.setText( string( m_timeHour ) $ " : " $ string( m_timeMin ) $ " : " $ string( m_timeSec ) );
	
	//버튼의 툴팁에 가격을 적어준다. 
	tempPrice = m_currentPrice * 2;
	if(tempPrice > INT64(ADENA_OVER_FLOW) || tempPrice < 0 )
	{
		BtnBid1.DisableWindow();
		BtnBid1.SetTooltipCustomType( MakeTooltipSimpleText( GetSystemMessage(2076)));
	}
	else
	{
		if(!BtnBid1.IsEnableWindow()) BtnBid1.EnableWindow();
		tempStr = MakeFullSystemMsg( GetSystemMessage(2157), MakeCostString(string(tempPrice) ) );
		//BtnBid1.SetTooltipCustomType( MakeTooltipSimpleText(tempStr));

   		BtnBid1.SetTooltipCustomType(MakeTooltipMultiText(tempStr, getInstanceL2Util().White, "",false,
									   					  "(" $ ConvertNumToText(string(tempPrice)) $ ")", GetNumericColor(string(tempPrice)), "",true));
	}
	
	//temp1 = m_currentPrice * 15 / 10;
	tempPrice = ((m_currentPrice * 5) / 10) + m_currentPrice;
	if(tempPrice > INT64(ADENA_OVER_FLOW) || tempPrice < 0 )
	{
		BtnBid2.DisableWindow();
		BtnBid2.SetTooltipCustomType( MakeTooltipSimpleText( GetSystemMessage(2076)));
	}
	else
	{
		if(!BtnBid2.IsEnableWindow()) BtnBid2.EnableWindow();
		tempStr = MakeFullSystemMsg( GetSystemMessage(2157), MakeCostString(string(tempPrice)));
		//BtnBid2.SetTooltipCustomType( MakeTooltipSimpleText(tempStr));

   		BtnBid2.SetTooltipCustomType(MakeTooltipMultiText(tempStr, getInstanceL2Util().White, "",false,
									   					  "(" $ ConvertNumToText(string(tempPrice)) $ ")", GetNumericColor(string(tempPrice)), "",true));
	}
	
	//temp1 = m_currentPrice * 11 /10;
	tempPrice = (m_currentPrice / 10) + m_currentPrice;
	if(tempPrice > INT64(ADENA_OVER_FLOW) || tempPrice < 0 )
	{
		BtnBid3.DisableWindow();
		BtnBid3.SetTooltipCustomType( MakeTooltipSimpleText( GetSystemMessage(2076)));
	}
	else
	{
		if(!BtnBid3.IsEnableWindow()) BtnBid3.EnableWindow();
		tempStr = MakeFullSystemMsg( GetSystemMessage(2157), MakeCostString(string(tempPrice) ) );
		//BtnBid3.SetTooltipCustomType( MakeTooltipSimpleText(tempStr));
   		BtnBid3.SetTooltipCustomType(MakeTooltipMultiText(tempStr, getInstanceL2Util().White, "",false,
									   					  "(" $ ConvertNumToText(string(tempPrice)) $ ")", GetNumericColor(string(tempPrice)), "",true));

	}
	
	//temp1 = m_currentPrice * 105 / 100;		//크악
	tempPrice = ((m_currentPrice * 5) / 100) + m_currentPrice;
	//debug("temp 1 : " $ m_currentPrice  * 0.05 + m_currentPrice);
	if(tempPrice > INT64(ADENA_OVER_FLOW) || tempPrice < 0 )
	{
		BtnBid4.DisableWindow();
		BtnBid4.SetTooltipCustomType( MakeTooltipSimpleText( GetSystemMessage(2076)));
	}
	else
	{
		if(!BtnBid4.IsEnableWindow()) BtnBid4.EnableWindow();
		tempStr = MakeFullSystemMsg( GetSystemMessage(2157), MakeCostString(string(tempPrice) ) );
		//BtnBid4.SetTooltipCustomType( MakeTooltipSimpleText(tempStr));

   		BtnBid4.SetTooltipCustomType(MakeTooltipMultiText(tempStr, getInstanceL2Util().White, "",false,
									   					  "(" $ ConvertNumToText(string(tempPrice)) $ ")", GetNumericColor(string(tempPrice)), "",true));

	}
	
	if(m_timeHour == 0 && m_timeMin == 0 && m_timeSec == 0)	//경매가 끝나면 타이머를 죽인다.
	{
		m_hOwnerWnd.KillTimer( TIMER_ID );
	}
	
	if(iRemainSecond == 0)
	{
		// iRemainSecond가 0이면 이번 경매는 종료된 것임. 다음 경매 정보 창을 보여준다.
		BtnBid1.DisableWindow();
		BtnBid2.DisableWindow();
		BtnBid3.DisableWindow();
		BtnBid4.DisableWindow();
		BtnBidInput.DisableWindow();
		
		//NextAuctionWnd.ShowWindow();
		BtnClose.EnableWindow();
	}
}

function OnBtnBidInputClick()
{
	DialogSetID( DIALOG_ASK_AUCTION_PRICE );
	//DialogSetReservedItemID( info.ID );				// ClassID
	DialogSetEditType("number");
	DialogSetParamInt64( -1 );
	DialogSetDefaultOK();	
	DialogShow(DialogModalType_Modalless, DialogType_NumberPad, GetSystemMessage(2138), string(Self) );
}

function HandleDialogOK()
{
	local int id;				//다이얼로그 아이디를 받아온다. 
	if( DialogIsMine() )
	{
		id = DialogGetID();
		if( id == DIALOG_ASK_AUCTION_PRICE)
		{
			// 오버플로우 체크 해야함.
			m_myBidPrice = INT64( DialogGetString() );
			DialogSetID( DIALOG_CONFIRM_PRICE );
			DialogShow(DialogModalType_Modalless, DialogType_Warning, MakeFullSystemMsg( GetSystemMessage(2137), m_auctionItem.Name, MakeCostString(string(m_myBidPrice) ) ), string(Self));
			
			//class'AuctionAPI'.static.RequestBidItemAuction( m_auctionID ,  m_myBidPrice);	// 입찰을 시도합니다.
		}
		else if( id == DIALOG_CONFIRM_PRICE)
		{
			class'AuctionAPI'.static.RequestBidItemAuction( m_auctionID ,  m_myBidPrice);	// 입찰을 시도합니다.
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
	OnClickButton("BtnClose");
}
defaultproperties
{
}
