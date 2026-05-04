/**
 *   출석부 시스템 (해외쪽 부터 개발되고, 국내에도 사용 예정)
 *   
 *   관련 빌드 명령어 
 *   //attendance info
 *   //attendance check 1 (날짜)
 *   //attendance reset [type1:normal, 2:newbie, 3:dormant]
 *   //attendance reset 1   (타겟 찍고)
 *   //attendance reset_time   (타겟 찍고)
 *   //pccafe on     //pc방 모드
 *   
 **/ 

class AttendCheckWnd extends UICommonAPI;

var WindowHandle  Me;
var WindowHandle  AttendCheck_SlotGroup;
var WindowHandle  AttendCheck_VIPGroup;

var AnimTextureHandle TodayTwinkle_VIP_AnimTex;
var AnimTextureHandle TodayStampYellow_VIP_AnimText;
var AnimTextureHandle TodayStampRed_VIP_AnimText;

var AnimTextureHandle TodayTwinkle_AnimTex;
var AnimTextureHandle TodayStampYellow_AnimText;
var AnimTextureHandle TodayStampRed_AnimText;

var WindowHandle week1Slot_Window;
var WindowHandle week2Slot_Window;
var WindowHandle week3Slot_Window; 
var WindowHandle week4Slot_Window;

var TextBoxHandle Message_TextBox;
var TextBoxHandle Checklist_TextBox;

var int  baseWindowSizeW, baseWindowSizeH, slotWindowSizeW, slotWindowSizeH, vipSlotWindowSizeW, vipSlotWindowSizeH;

var Rect TodayStampYellow_VIP_Rect, TodayStampRed_VIP_Rect, TodayTwinkle_VIP_Rect;
var Rect TodayStampYellow_Rect, TodayStampRed_Rect, TodayTwinkle_Rect;

// var bool bItemWindowOneClick; // 한번 아이템 윈도우를 클릭 했는지 기억

var int todayNormalDay, todayVIpDay;

const DialogCloseID = 1002112;
// 숫자 텍스쳐 뒤에 0~9 까지 조합하여 숫자를 만듬.
const texNumber = "L2UI_CT1.AttendCheckWnd.Attend_DateNum_";


const RED       = true;
const YELLOW    = false;

const VIP_TYPE        = true;
const NORMAL_TYPE     = false;

const TWINKLE_ANI   = true;
const STAMP_ANI     = false;

// 모션이 시작될때 표시
var int  aniState_NormalRedStamp_nDay, aniState_NormalYellowStamp_nDay, aniState_VipRedStamp_nDay, aniState_VipYellowStamp_nDay;

//------------------------------------------------------------------------------------------------------------------------------------
//  OnRegisterEvent
//------------------------------------------------------------------------------------------------------------------------------------
function OnRegisterEvent()
{
	RegisterEvent( EV_Test_6 );

	RegisterEvent( EV_SystemMessage );

	RegisterEvent(EV_VipAttendanceItemList);  //10050
	RegisterEvent(EV_VipAttendanceCheck);     //10052
}

//------------------------------------------------------------------------------------------------------------------------------------
//  OnLoad
//------------------------------------------------------------------------------------------------------------------------------------
function OnLoad()
{
	SetClosingOnESC();
	Initialize();
	Load();
}

function OnShow()
{
		// 지정한 윈도우를 제외한 닫기 기능 
	getInstanceL2Util().ItemRelationWindowHide(getCurrentWindowName(String(self)));
}

//------------------------------------------------------------------------------------------------------------------------------------
//  Init
//------------------------------------------------------------------------------------------------------------------------------------
function Initialize()
{
	//--------------------------------------
	// 윈도우 핸들.
	//--------------------------------------

	// 윈도우 핸들
	Me = GetWindowHandle( "AttendCheckWnd" );

	//  VIP 그룹 윈도우
	AttendCheck_VIPGroup = GetWindowHandle( "AttendCheckWnd.AttendCheck_VIPGroup" );

	//  일반 슬롯 윈도우
	AttendCheck_SlotGroup  = GetWindowHandle( "AttendCheckWnd.AttendCheck_SlotGroup" );
	week1Slot_Window       = GetWindowHandle( "AttendCheckWnd.AttendCheck_SlotGroup.week1Slot_Window" );
	week2Slot_Window       = GetWindowHandle( "AttendCheckWnd.AttendCheck_SlotGroup.week2Slot_Window" );
	week3Slot_Window       = GetWindowHandle( "AttendCheckWnd.AttendCheck_SlotGroup.week3Slot_Window" );
	week4Slot_Window       = GetWindowHandle( "AttendCheckWnd.AttendCheck_SlotGroup.week4Slot_Window" );

	// 일반 텍스트 박스 
	Message_TextBox   = GetTextBoxHandle( "AttendCheckWnd.Message_TextBox" );
	Checklist_TextBox = GetTextBoxHandle( "AttendCheckWnd.Checklist_TextBox" );

	// VIP,  오늘 빤짝이, 빨간, 노란 도장 애니
	TodayTwinkle_VIP_AnimTex      = GetAnimTextureHandle( "AttendCheckWnd.AttendCheck_VIPGroup.TodayTwinkle_AnimTex" );	
	TodayStampRed_VIP_AnimText    = GetAnimTextureHandle( "AttendCheckWnd.AttendCheck_VIPGroup.TodayStampRed_AnimText" );
	TodayStampYellow_VIP_AnimText = GetAnimTextureHandle( "AttendCheckWnd.AttendCheck_VIPGroup.TodayStampYellow_AnimText" );

	// 일반, 오늘 빤짝이, 빨간, 노란 도장 애니
	TodayTwinkle_AnimTex      = GetAnimTextureHandle( "AttendCheckWnd.AttendCheck_SlotGroup.TodayTwinkle_AnimTex" );
	TodayStampRed_AnimText    = GetAnimTextureHandle( "AttendCheckWnd.AttendCheck_SlotGroup.TodayStampRed_AnimText" );
	TodayStampYellow_AnimText = GetAnimTextureHandle( "AttendCheckWnd.AttendCheck_SlotGroup.TodayStampYellow_AnimText" );

	// VIP 도장이 찍힌 후 가려지는 이미지 , AttendCheckWnd.AttendCheck_VIPGroup.StampBG1 ~ 4_Texture
	// VIP 노란 도장 이미지 AttendCheckWnd.AttendCheck_VIPGroup.StampYellow1 ~ 4_Texture
	// VIP 빨간 도장 이미지 AttendCheckWnd.AttendCheck_VIPGroup.StampRed1 ~ 4_Texture
	// VIP 아이템 윈도우 AttendCheckWnd.AttendCheck_VIPGroup.AttendVIP1~4_ItemWindow

	// 동적으로 변동되는 텍스트 박스
	Message_TextBox.SetText("");

	//당일 출석 보상을 받아야만 다음날 출석 보상을 받을 수 있습니다.
	//\n- PC방에서의 접속은 추가 보상을 획득합니다.\n- 한 번 습득한 보상은 이전 상태로 되돌릴 수 없으니 주의해 주세요.
	Checklist_TextBox.SetText(GetSystemMessage(6189));
}

// load 세팅
function Load()
{
	elementInit();

	// 초기 윈도우 사이즈 값 얻기
	Me.GetWindowSize(baseWindowSizeW, baseWindowSizeH);
	AttendCheck_VIPGroup.GetWindowSize(vipSlotWindowSizeW, vipSlotWindowSizeH);
	AttendCheck_SlotGroup.GetWindowSize(slotWindowSizeW, slotWindowSizeH);	

	// VIP 도장 애니메이션 위치 정보
	TodayStampYellow_VIP_Rect = TodayStampYellow_VIP_AnimText.GetRect();
	TodayStampRed_VIP_Rect    = TodayStampRed_VIP_AnimText.GetRect();
	TodayTwinkle_VIP_Rect     = TodayTwinkle_VIP_AnimTex.GetRect();

	// 일반 도장 애니메이션 위치 정보
	TodayStampYellow_Rect     = TodayStampYellow_AnimText.GetRect();
	TodayStampRed_Rect        = TodayStampRed_AnimText.GetRect();
	TodayTwinkle_Rect         = TodayTwinkle_AnimTex.GetRect();

	//setAttendWndSize(true, 21);
}

function elementInit()
{
	local int i;

	for(i = 1; i <= 28; i++)
	{
		// 일반 도장 이미지
		setStampTexture(NORMAL_TYPE, RED   , i, false);
		setStampTexture(NORMAL_TYPE, YELLOW, i, false);

		// vip 도장 이미지
		setStampTexture(VIP_TYPE, RED,    i, false);
		setStampTexture(VIP_TYPE, YELLOW, i, false);

		// 도장 배경 이미지
		setStampBgTexture(VIP_TYPE   , i, false);
		setStampBgTexture(NORMAL_TYPE, i, false);

		// 도장 하이라이트 이미지
		setSlotHighlightTexture(VIP_TYPE   , i, false);
		setSlotHighlightTexture(NORMAL_TYPE, i, false);

		// 날짜 텍스쳐(숫자)
		setDayNumberTexture(VIP_TYPE   , i);
		setDayNumberTexture(NORMAL_TYPE, i);

		// 아이템 윈도우
		setItemWindow(VIP_TYPE   , i, 0, 0);
		setItemWindow(NORMAL_TYPE, i, 0, 0);

		// 출석 아이템 카운트 텍스트
		setTextBoxAttendItemCount(VIP_TYPE   , i, 0);
		setTextBoxAttendItemCount(NORMAL_TYPE, i, 0);

		// 화살표 텍스쳐 숨기기 
		if (getDay(i) > 1) GetTextureHandle(getSlotWnd(getWeek(i)) $ ".slot_arrow" $ (getDay(i) - 1)).ShowWindow();
	}

	// VIP 출석 아이템 카운트 텍스트
	setTextBoxAttendItemCount(VIP_TYPE,  7, 0);
	setTextBoxAttendItemCount(VIP_TYPE, 14, 0);
	setTextBoxAttendItemCount(VIP_TYPE, 21, 0);
	setTextBoxAttendItemCount(VIP_TYPE, 28, 0);
	
	// 리본 세팅
	setVipPribbonTexture( 7, 0);
	setVipPribbonTexture(14, 0);
	setVipPribbonTexture(21, 0);
	setVipPribbonTexture(28, 0);

	hideAllAniTexture();

	// 모션 상태 기억 초기화
	aniState_NormalRedStamp_nDay     = 0;
	aniState_NormalYellowStamp_nDay  = 0;

	aniState_VipRedStamp_nDay        = 0;
	aniState_VipYellowStamp_nDay     = 0;

	// 아이템 윈도우를 한번만 클릭 하도록 하기 위해서..
	//bItemWindowOneClick = false;
}

/**
 * 모든 모션 애니 스톱
 **/
function hideAllAniTexture()
{
	// 도장 모션
	TodayStampYellow_VIP_AnimText.Pause();
	TodayStampYellow_VIP_AnimText.Stop();
	TodayStampYellow_VIP_AnimText.HideWindow();
	
	TodayStampYellow_AnimText.Pause();
	TodayStampYellow_AnimText.Stop();
	TodayStampYellow_AnimText.HideWindow();
	
	TodayStampRed_VIP_AnimText.Pause();
	TodayStampRed_VIP_AnimText.Stop();
	TodayStampRed_VIP_AnimText.HideWindow();
	
	TodayStampRed_AnimText.Pause();
	TodayStampRed_AnimText.Stop();
	TodayStampRed_AnimText.HideWindow();

	// 투데이 포커싱 모션	
	TodayTwinkle_VIP_AnimTex.Pause();
	TodayTwinkle_VIP_AnimTex.Stop();
	TodayTwinkle_VIP_AnimTex.HideWindow();

	TodayTwinkle_AnimTex.Pause();
	TodayTwinkle_AnimTex.Stop();
	TodayTwinkle_AnimTex.HideWindow();
}


// 아이템 카운트
function setTextBoxAttendItemCount(bool isVip, int nDay, int itemCount)
{
	local String pStr;

	if (itemCount > 99) pStr = "99+";
	else pStr = "x" $ String(itemCount);

	if (isVip)
	{
		// 7, 14, 21, 28 날짜..
		if((nDay % 7) == 0)
		{
			if (itemCount == 0)
			{
				GetTextBoxHandle(getVipWnd() $ ".vip_" $ String(nDay) $ "dayCount_TextBox").HideWindow();
			}
			else
			{
				GetTextBoxHandle(getVipWnd() $ ".vip_" $ String(nDay) $ "dayCount_TextBox").SetText(pStr);
				GetTextBoxHandle(getVipWnd() $ ".vip_" $ String(nDay) $ "dayCount_TextBox").ShowWindow();
			}
		}
	}
	else 
	{
		if (itemCount == 0)
		{
			GetTextBoxHandle(getSlotWnd(getWeek(nDay)) $ ".AttendDayCount" $ getDay(nDay) $ "_TextBox").HideWindow();
		}
		else
		{
			GetTextBoxHandle(getSlotWnd(getWeek(nDay)) $ ".AttendDayCount" $ getDay(nDay) $ "_TextBox").SetText(pStr);
			GetTextBoxHandle(getSlotWnd(getWeek(nDay)) $ ".AttendDayCount" $ getDay(nDay) $ "_TextBox").ShowWindow();
		}
	}	
}

// 아이템을 삽입
function setItemWindow(bool isVip, int nDay, int nItemID, int amount)
{
	local ItemID pItemID;
	local ItemInfo ResourceInfo;

	local string path;

	if (isVip)
	{
		path = getVipWnd() $ ".AttendVIP" $ getWeek(nDay) $ "_ItemWindow";
	}
	else
	{
		path = getSlotWnd(getWeek(nDay))  $ ".AttendMonth" $ getDay(nDay) $ "_ItemWindow";
	}
	
	GetItemWindowHandle(path).Clear();	

	if  (nItemID > 0)
	{
		pItemID.ClassID = nItemID;
		class'UIDATA_ITEM'.static.GetItemInfo(pItemID, ResourceInfo);	

		// 수량성 아이템이면 수량 추가
		if(IsStackableItem(ResourceInfo.ConsumeType) && amount > 0)
		{
			ResourceInfo.ItemNum = amount;
		}

		GetItemWindowHandle(path).AddItem(ResourceInfo);		
	}
}

function ItemWindowHandle getItemWindow(bool isVip, int nDay)
{
	local string path;

	if (isVip)
	{
		path = getVipWnd() $ ".AttendVIP" $ getWeek(nDay) $ "_ItemWindow";
	}
	else
	{
		path = getSlotWnd(getWeek(nDay))  $ ".AttendMonth" $ getDay(nDay) $ "_ItemWindow";
	}
	
	return GetItemWindowHandle(path);
}

// 일수에 따라서 창 사이즈 조절 기능
function setAttendWndSize(bool isVip, int nDay)
{
	local int i, slotCount, decSlotHeight, nWidth, nHeight, baseWndW, baseWndH;

	slotCount = getWeek(nDay);
	
	decSlotHeight = (4 - slotCount) * (83 + 3);
	if (isVip)
	{
		//  vip 윈도우 기본 사이즈 76, 359
		baseWndW = baseWindowSizeW;		
		AttendCheck_VIPGroup.ShowWindow();
	}
	else
	{
		baseWndW = baseWindowSizeW - vipSlotWindowSizeW;
		AttendCheck_VIPGroup.HideWindow();
	}

	AttendCheck_VIPGroup.SetWindowSize(vipSlotWindowSizeW, vipSlotWindowSizeH - decSlotHeight - 2);//15);

	// 슬롯 그룹 윈도우 (슬롯들4개가 들어 있는 그룹 윈도우), 83 * 4 = 332
	nWidth = slotWindowSizeW;
	nHeight = slotWindowSizeH - decSlotHeight;

	// 슬롯 그룹 윈도우 , 리사이징
	AttendCheck_SlotGroup.SetWindowSize(nWidth, nHeight);
	
	for (i = 1; i <= 4; i++)
	{
		if ((slotCount + 1) > i) GetWindowHandle(getSlotWnd(i)).ShowWindow();
		else GetWindowHandle(getSlotWnd(i)).HideWindow();
	}
	
	// 전체 윈도우 세로 폭, 슬롯 숫자에 따라서 결정
	baseWndH = baseWindowSizeH - decSlotHeight;

	// 전체 윈도우 사이즈 조절
	Me.SetWindowSize(baseWndW, baseWndH);
}

//------------------------------------------------------------------------------------------------------------------------------------
//  OnEvent Process
//------------------------------------------------------------------------------------------------------------------------------------
function OnEvent( int Event_ID, String a_Param )
{
	local int nX, nY, nDay, SystemMsgIndex;

	//16
	if( Event_ID == EV_Test_6 )
	{
		ParseInt(a_Param, "x", nX);
		ParseInt(a_Param, "y", nY);
		ParseInt(a_Param, "day", nDay);

		playMotionTodayTwinkle(VIP_TYPE   , nDay, true);
		playMotionTodayTwinkle(NORMAL_TYPE, nDay, true);

		playMotionStamp(NORMAL_TYPE, RED, nX, true);
		playMotionStamp(NORMAL_TYPE, YELLOW, nX, true);
	}
	else if (Event_ID == EV_SystemMessage)
	{
		// 시스템 메세지가 왔을 겨우
		ParseInt ( a_Param, "Index", SystemMsgIndex );

		// "인벤토리 슬롯이 다 찼습니다." 가 찍힌 경우 
		if (SystemMsgIndex == 129)
		{
			Message_TextBox.SetText(GetSystemMessage(129));
		}
		// "인벤토리의 무게/수량 제한을 초과하여 출석 보상 아이템을 받을 수 없습니다." 
		else if (SystemMsgIndex == 6178)
		{
			Message_TextBox.SetText(GetSystemMessage(6178));
		}
	}
	else if (Event_ID == EV_VipAttendanceItemList)
	{
		//Debug("--------------------------------------------------");
		//Debug("EV_VipAttendanceItemList:" @ a_Param);

		if (Me.IsShowWindow()) 
			Me.HideWindow();
		else
			processEvent_VipAttendanceItemList(a_param);
	}
	else if (Event_ID == EV_VipAttendanceCheck)
	{
		//Debug("--------------------------------------------------");
		//Debug("EV_VipAttendanceCheck:" @ a_Param);

		processEvent_VipAttendanceCheck(a_param);
	}
}

/**
 *  이벤트를 데이타를 파싱하고 처리
 **/ 

function processEvent_VipAttendanceItemList(string param)
{
	local int i;
	local int itemTotalCount;         // itemTotalCount로 전체 출석부 날짜로 파악 하면 됨.
	local int vipItemTotalCount;      // 1~4   // 7,14,21,28일 
	local int normalItemGetEnable;    // 일반 보상 받기 가능
	local int vipItemGetEnable;       // VIP 보상 받기 가능

	local int NormalDay;              // 값이 15이면 15일차 출석 (0부터 시작: 첫번째날은 0이 들어온다)) +1을 해서 사용하면 됨.
	local int Today;                  // 오늘이 언제인가?

	// 보상 아이템, 수량,  하루에 대한 데이타
	local int itemID, amount, multiple, highLight;
	local int vipItemID, vipAmount, vipMultiple, vipHighLight, vipLevel, minimumLevel;

	local int vipDay, pcCafeDay;

	local bool bTodayGetEnable; // 보상을 받기 가능한 날인가?

	local UserInfo playerInfo;

	// 클릭을 찍을날이 언제인지 기억
	todayVIpDay    = -1;
	todayNormalDay = -1;
	
	// (Today 는 1 부터 ~28 까지 날라온다)
	ParseInt(param, "Today"                 , Today);   
	ParseInt(param, "NormalDay"             , NormalDay);
	ParseInt(param, "ItemCount"             , itemTotalCount);
	ParseInt(param, "VipItemCount"          , vipItemTotalCount);

	ParseInt(param, "NormalAttendanceEnable", normalItemGetEnable);  // 1:보상 받기 가능, 0:보상 받음
	ParseInt(param, "VipAttendanceEnable"   , vipItemGetEnable);     // 1:보상 받기 가능, 0:보상받음, -1:보상 받을 수 없음.

	// 85랩 미만 유저
	ParseInt(param, "MinimumLevel"          , minimumLevel); 

	// VIP 가능한가?, VIP 아이템이 한개라도 있으면 VIP보여주는 모드
	if (vipItemTotalCount > 0)  
		setAttendWndSize(VIP_TYPE, itemTotalCount);
	else
		setAttendWndSize(NORMAL_TYPE, itemTotalCount);
		
		
	// 아이템 정보 적용
	for (i = 1; i <= itemTotalCount; i++)
	{
		// 일반 날때
		ParseInt(param, "ItemID_"      $ i, itemID);
		ParseInt(param, "Amount_"      $ i, amount);
		ParseInt(param, "Multiple_"    $ i, multiple);
		ParseInt(param, "HighLight_"   $ i, highLight);

		ParseInt(param, "PcCafeDay_"   $ i, pcCafeDay);

		if (NormalDay < i || normalItemGetEnable > 0)
		{
			setItemWindow            (NORMAL_TYPE, i, itemID, amount);
			setTextBoxAttendItemCount(NORMAL_TYPE, i, amount);
			setSlotHighlightTexture  (NORMAL_TYPE, i, numToBool(highLight)) ;
		}
		if (NormalDay >= i)
		{
			// 이미 찍은 도장 이미지, 일반, pc방
			setStampTexture   (NORMAL_TYPE, RED, i, true);
			setStampTexture   (NORMAL_TYPE, YELLOW, i, numToBool(pcCafeDay));						

			// 도장을 찍으면 아이템은 무조건 일단 가려 놓고..
			setStampBgTexture (NORMAL_TYPE, i, true);
			setItemWindow     (NORMAL_TYPE, i, 0, 0);
	
			// 화살표 텍스쳐 숨기기 
			if (getDay(i) > 1) GetTextureHandle(getSlotWnd(getWeek(i)) $ ".slot_arrow" $ (getDay(i) - 1)).HideWindow();
		}
	}

	for (i = 1; i <= vipItemTotalCount; i++)
	{
		// VIP 그룹
		ParseInt(param, "VipItemID_"      $ i, vipItemID);
		ParseInt(param, "VipAmount_"      $ i, vipAmount);
		ParseInt(param, "VipMultiple_"    $ i, vipMultiple);
		ParseInt(param, "VipHighLight_"   $ i, vipHighLight);
		ParseInt(param, "VipLevel_"       $ i, vipLevel);
		ParseInt(param, "VipDay_"         $ i, VipDay);

		if (VipDay <= 0)
		{
			setItemWindow            (VIP_TYPE, i * 7, vipItemID, amount);
			setTextBoxAttendItemCount(VIP_TYPE, i * 7, vipAmount);
			setSlotHighlightTexture  (VIP_TYPE, i * 7, numToBool(vipHighLight)) ;

			// vip 리본 초기화 (7,14,21,28일이 되면 초기화)
			setVipPribbonTexture     (i * 7, vipLevel);
		}
		else
		{
			// 이미 찍은 도장 이미지
			// VIP 보상을 받았나?
			setStampBgTexture (VIP_TYPE, i * 7, numToBool(VipDay));
			setStampTexture   (VIP_TYPE, RED, i * 7, true);
			setItemWindow     (VIP_TYPE, i * 7, 0, 0);
		}
	}


	// 받기 가능한 날 포커스

	// 일반, PC방 빤짝 거림 
	if (normalItemGetEnable > 0)
	{
		// 받기 가능한 날 포커스 모션(깜빡 거리는 것 받으라고..)
		if (NormalDay == (Today - 1) || NormalDay == Today)	
		{
			playMotionTodayTwinkle(NORMAL_TYPE, Today, true);
			todayNormalDay = Today;
			bTodayGetEnable = true;

			// 도장 찍기 가능한 날이니 아이템을 가리는 bg를 숨긴다.
			setStampBgTexture(NORMAL_TYPE, Today, false);
		}
	}

	// VIP 반짝 거림
	if (NormalDay == (Today - 1) && vipItemGetEnable > 0)	
	{
		playMotionTodayTwinkle(VIP_TYPE, Today, true);
		todayVIpDay = Today;
		bTodayGetEnable = true;
	}

	GetPlayerInfo(playerInfo);

	// minimumLevel 는 해외쪽에서 몇레벨 부터 출석보상을 받게 지정하도록 하기 위한 부분
	if (minimumLevel > 0 && minimumLevel > playerInfo.nLevel)
	{
		Message_TextBox.SetText(MakeFullSystemMsg(GetSystemMessage(6188), string(minimumLevel)));
	}
	else if (bTodayGetEnable)
	{
		// pc방만 받을께 있다면..
		if (NormalDay == Today)
		{
			// $s일차 출석 보상을 받을 수 있습니다. 보상 아이콘을 클릭해 주세요
			Message_TextBox.SetText(MakeFullSystemMsg(GetSystemMessage(6174), string(NormalDay)));
		}
		else
		{
			// $s일차 출석 보상을 받을 수 있습니다. 보상 아이콘을 클릭해 주세요
			Message_TextBox.SetText(MakeFullSystemMsg(GetSystemMessage(6174), string(NormalDay + 1)));
		}
	}
	else
	{
		// $s1일차 출석 보상을 성공적으로 받았습니다
		Message_TextBox.SetText(MakeFullSystemMsg(GetSystemMessage(6176), string(Today)));
	}

	if(!Me.IsShowWindow())
	{
		Me.ShowWindow();
		Me.SetFocus();
	}
}

/**
 *   도장을 찍는 실질적 부분. 서버에서 도장을 찍을 곳을 확인해서 보내는 것.
 *   
 *   상태 값
 *   
 *   1.normal
 *   2.pcCafe
 *   3.normal & pccafe
 *   4.vip
 *   5.normal & vip
 *   6.pcCafe & vip
 *   7.normal & pcCafe & vip
 *   
 **/
function processEvent_VipAttendanceCheck(string param)
{
	//local string 
	local int CheckDay, CheckType;
	local bool isVip, isVipRed, isNormal, isNormalRed;

	ParseInt(param, "CheckDay", CheckDay);
	ParseInt(param, "CheckType", CheckType);  

	if (CheckDay > 0)
	{
		switch(CheckType)
		{
			case 1: isNormal    = true; // 일반출석
				    isNormalRed = true; // 빨간 도장
				    break;

			case 2: isNormal    = true;  // 일반출석
				    isNormalRed = false; // 노란 도장(PC방)
				    break;

			case 4: isVip       = true;    // VIP출석 
				    isVipRed    = true;    // VIP빨간도장(VIP는 빨간 도장 하나만 찍는다)
				    break;

			case 5: isNormal    = true;  // 일반 출석
				    isNormalRed = true;  // 일반 빨간도장

					isVip       = true;  // VIP 출석
					isVipRed    = true;  // vip 빨간도장
				    break;

		    case 6: isVip       = true;  // VIP출석
					isVipRed    = true;  // VIP빨간도장

					isNormal    = true;  // 일반출석   
					isNormalRed = false; // 빨간도장

		    		// 해당 경우는 발생 안함 : pc방 & Vip(만들어 놓긴 하는데..)
				    break;
		}

		// $s1일차 출석 보상을 성공적으로 받았습니다
		Message_TextBox.SetText(MakeFullSystemMsg(GetSystemMessage(6176), string(CheckDay)));

		// 레드, 노란 도장, 일반 출석에 찍기 모션 (예외 상황)
		if (CheckType == 3 || CheckType == 7)
		{
			playMotionStamp(NORMAL_TYPE, RED   , CheckDay, true);
			playMotionStamp(NORMAL_TYPE, YELLOW, CheckDay, true);

			PlaySound("InterfaceSound.stamp_double");

			if (CheckType == 7)
			{
				playMotionStamp(VIP_TYPE, RED, CheckDay, true);
			}
		}
		// 단일 도장, 각 상태에 따라 도장 애니 작동
		else
		{
			if (isNormal) playMotionStamp(NORMAL_TYPE, isNormalRed, CheckDay, true);
			if (isVip) playMotionStamp(VIP_TYPE, isVipRed, CheckDay, true);

			if (isVipRed || isNormalRed) PlaySound("InterfaceSound.stamp_red");
			else PlaySound("InterfaceSound.stamp_yellow");
		}

		// 오늘 활성화 모션 숨기기
		TodayTwinkle_AnimTex.Pause();
		TodayTwinkle_AnimTex.Stop();
		TodayTwinkle_AnimTex.HideWindow();

		TodayTwinkle_VIP_AnimTex.Pause();
		TodayTwinkle_VIP_AnimTex.Stop();
		TodayTwinkle_VIP_AnimTex.HideWindow();
	}
}

function onHide()
{
	elementInit();
}

//function OnClickItem( String strID, int index )
//{
//	Debug("strID:" $ strID);
//	Debug("index:" $ index);

//}

// 아이템 윈도우를 마우스 down (선택) 했을때  
function OnSelectItemWithHandle( ItemWindowHandle a_hItemWindow, int a_Index )
{
	// Debug("a_hItemWindow" @ a_hItemWindow.GetWindowName());
	// Debug("index:" $ a_Index);	
	
	// 클릭 유도 모션이 둘중 하나라도 있으면.. 클릭 가능하도록..)
	//if (TodayTwinkle_AnimTex.IsShowWindow() || TodayTwinkle_VIP_AnimTex.IsShowWindow())
	//if (bItemWindowOneClick == false)
	//{

	// 서버 쪽에서 빤짝 거리는 동안만 막 클릭이 가능하도록 해달라고 해서.. 추가
	if (TodayTwinkle_AnimTex.IsShowWindow() || TodayTwinkle_VIP_AnimTex.IsShowWindow())
	{
		if (getItemWindow(VIP_TYPE, todayVIpDay) == a_hItemWindow || getItemWindow(NORMAL_TYPE, todayNormalDay) == a_hItemWindow)
		{
			//bItemWindowOneClick = true;
			RequestAttendanceCheck();
		}
	}
	//}
}

//------------------------------------------------------------------------------------------------------------------------------------
//  OnClickButton Event
//------------------------------------------------------------------------------------------------------------------------------------
function OnClickButton( string Name )
{
	switch( Name )
	{
		case "HelpBtn":
			 OnHelpBtnClick();
			 break;

	    case "CancelBtn":
			 OnCancelBtnClick();
			 break;
	}
}

// OnCancelBtnClick Handler
function OnCancelBtnClick()
{
	Me.HideWindow();
}

// 도움말 열기 
function OnHelpBtnClick()
{
	local string strParam;

	// 클래식과 라이브에 다른 도움말 사용
	if(getInstanceUIData().getIsClassicServer())
	{
		ParamAdd(strParam,"FilePath","..\\L2text\\g_attendance_help001.htm");
		ExecuteEvent(EV_ShowHelp,strParam);
	}
	else
	{
		ExecuteEvent(EV_ShowHelp,"155");
	}
}

//------------------------------------------------------------------------------------------------------------------------------------
//  OnTextureAnimEnd 
//------------------------------------------------------------------------------------------------------------------------------------

//// 텍스쳐 애니메이션이 끝났을때..
//function OnTextureAnimEnd( AnimTextureHandle a_AnimTextureHandle )
//{
//	switch (a_AnimTextureHandle.GetWindowName())
//	{
//		case "TodayStampRed_AnimText"        :  if(aniState_NormalRedStamp_nDay > 0)
//												{
//													setStampTexture(NORMAL_TYPE, RED, aniState_NormalRedStamp_nDay, true); 													
//													aniState_NormalRedStamp_nDay = 0;		
//												}
//												if(aniState_VipRedStamp_nDay > 0)
//												{
//													setStampTexture(VIP_TYPE, RED, aniState_VipRedStamp_nDay, true); 													
//													aniState_VipRedStamp_nDay = 0;													
//												}
//												a_AnimTextureHandle.HideWindow();
//												break;												

//		case "TodayStampYellow_AnimText"     :  if(aniState_NormalYellowStamp_nDay > 0)
//												{
//													setStampTexture(NORMAL_TYPE, YELLOW, aniState_NormalYellowStamp_nDay, true); 													
//													aniState_NormalYellowStamp_nDay = 0;
//												}
//												if(aniState_VipYellowStamp_nDay > 0)
//												{
//													setStampTexture(VIP_TYPE, YELLOW, aniState_VipYellowStamp_nDay, true); 													
//													aniState_VipYellowStamp_nDay = 0;
//												}	
//												a_AnimTextureHandle.HideWindow();
//												break;
//	}
//}

//------------------------------------------------------------------------------------------------------------------------------------
//  Inner Util
//------------------------------------------------------------------------------------------------------------------------------------

//  슬롯에 날짜 텍스쳐를 수정
function setDayNumberTexture(bool isVip, int nDay)
{
	local string tex1Path, tex10Path;
	local string ten, one;

	strDaySplit(nDay, ten, one);

	// 7, 14, 21, 28 날짜..
	if(isVip && ((nDay % 7) == 0))
	{
		tex1Path  = getVipWnd() $ ".DateNum" $ nDay $ "_VIP_1_Texture";
		tex10Path = getVipWnd() $ ".DateNum" $ nDay $ "_VIP_10_Texture";

		GetTextureHandle(tex1Path).SetTexture(texNumber  $ one);
		GetTextureHandle(tex10Path).SetTexture(texNumber $ ten);
	}
	else
	{		
		tex1Path  = getSlotWnd(getWeek(nDay)) $ ".DateNum" $ getDay(nDay) $ "_Month_1_Texture";
		tex10Path = getSlotWnd(getWeek(nDay)) $ ".DateNum" $ getDay(nDay) $ "_Month_10_Texture";

		GetTextureHandle(tex1Path).SetTexture(texNumber $ one);
		GetTextureHandle(tex10Path).SetTexture(texNumber $ ten);
	}
}

//  vip 슬롯에 리본레벨 교체
function setVipPribbonTexture(int nDay, int nLevel)
{
	local string texPath;
	
	// 7, 14, 21, 28 날짜..
	if((nDay % 7) == 0)
	{
		texPath = getVipWnd() $ ".Attend_VIPribbon" $ getWeek(nDay);
		
		if (nLevel > 0)
		{
			// 리본 텍스쳐 교체
			GetTextureHandle(texPath).ShowWindow();
			GetTextureHandle(texPath).SetTexture("L2UI_ct1.AttendCheckWnd.Attend_VIPribbon" $ nLevel);
		}
		else
		{
			GetTextureHandle(texPath).HideWindow();
		}
	}
}

// 도장 이미지, vip 인지 일반인지, red 또는 yellow, 해당 날짜
function setStampTexture(bool isVip, bool isRed, int nDay, bool nShow)
{
	local string texRedPath, texYellowPath, texStampBgPath;
	
	// VIP일때는 ,nDay가 7, 14, 21, 28 만 나오도록 한다.
	if(isVip && ((nDay % 7) == 0))
	{
		texRedPath     = getVipWnd() $ ".StampRed"    $ getWeek(nDay) $ "_Texture";
		texYellowPath  = getVipWnd() $ ".StampYellow" $ getWeek(nDay) $ "_Texture";
		texStampBgPath = getVipWnd() $ ".StampBG"     $ getWeek(nDay) $ "_Texture";

		// VIP의 빨간도장, 노란도장
		if (nShow)
		{
			if(isRed) GetTextureHandle(texRedPath).ShowWindow();
			else GetTextureHandle(texYellowPath).ShowWindow();
		}
		else
		{
			if(isRed) GetTextureHandle(texRedPath).HideWindow();
			else GetTextureHandle(texYellowPath).HideWindow();
		}
	}
	else
	{		
		// 일반의 빨간도장, 노란도장
		texRedPath     = getSlotWnd(getWeek(nDay)) $ ".StampRed"    $ getDay(nDay) $ "_Texture";
		texYellowPath  = getSlotWnd(getWeek(nDay)) $ ".StampYellow" $ getDay(nDay) $ "_Texture";
		texStampBgPath = getSlotWnd(getWeek(nDay)) $ ".StampBG"     $ getDay(nDay) $ "_Texture";

		if (nShow)
		{
			if(isRed) GetTextureHandle(texRedPath).ShowWindow();
			else GetTextureHandle(texYellowPath).ShowWindow();
		}
		else
		{
			if(isRed) GetTextureHandle(texRedPath).HideWindow();
			else GetTextureHandle(texYellowPath).HideWindow();
		}

		// 도장이 둘다 안보이게 되었으면 패널을 보여준다.
		if (!GetTextureHandle(texRedPath).IsShowWindow() && !GetTextureHandle(texYellowPath).IsShowWindow())
		{
			GetTextureHandle(texStampBgPath).ShowWindow();
		}
	}
}

// 아이템을 가리는 도장 아래 배경 텍스쳐
function setStampBgTexture(bool isVip, int nDay, bool nShow)
{
	local string texStampBgPath;
	
	// VIP일때는 ,nDay가 7, 14, 21, 28 만 나오도록 한다.
	if(isVip && ((nDay % 7) == 0))
	{		                                 
		texStampBgPath = getVipWnd() $ ".StampBG" $ getWeek(nDay) $ "_Texture";

		if (nShow) GetTextureHandle(texStampBgPath).ShowWindow();
		else { GetTextureHandle(texStampBgPath).HideWindow();}
	}
	else
	{		
		texStampBgPath = getSlotWnd(getWeek(nDay)) $ ".StampBG" $ getDay(nDay) $ "_Texture";

		if (nShow) GetTextureHandle(texStampBgPath).ShowWindow();
		else GetTextureHandle(texStampBgPath).HideWindow();
	}
}

// 아이템 주변에 빛 줄기? 텍스쳐
function setSlotHighlightTexture(bool isVip, int nDay, bool nShow)
{
	local string texPath;
	
	// VIP일때는 ,nDay가 7, 14, 21, 28 만 나오도록 한다.
	if(isVip && ((nDay % 7) == 0))
	{		                      
		texPath = getVipWnd() $ ".SlotHighlight" $ getWeek(nDay) $ "_VIP_Texture";

		if (nShow) GetTextureHandle(texPath).ShowWindow();
		else { GetTextureHandle(texPath).HideWindow();}
	}
	else
	{		
		texPath = getSlotWnd(getWeek(nDay)) $ ".SlotHighlight" $ getDay(nDay) $ "_Texture";

		if (nShow) GetTextureHandle(texPath).ShowWindow();
		else GetTextureHandle(texPath).HideWindow();
	}
}

// 도장 찍는 모션 재생, 스톱
//  백판(빛나는) x=11 y=93  x간격 59 , y간격 87
//  7, 88 을 기준값
//  백판      4, 5
//  노랑도장 -8, 9
//  빨간도장 -16 - 22
// isBgTwinkle 이 true 오늘이라고 강조하는 모션이 재생되고, false이면 도장 애니메이션이 나온다.
function playMotionStamp(bool isVip, bool isRed, int nDay, bool bPlay) //, int nX, int nY)
{
	local int nX, nY;

	setStampTexture(isVip, isRed, nDay, bPlay);

	if(isVip && ((nDay % 7) == 0))
	{	
		if (isRed)
		{
			if (bPlay)
			{
				aniState_VipRedStamp_nDay = nDay;
				
				nX = 3;
				nY = 3;
				TodayStampRed_VIP_AnimText.ShowWindow();				
				TodayStampRed_VIP_AnimText.SetAnchor("AttendCheckWnd.AttendCheck_VIPGroup", "TopLeft", "TopLeft", 
													  nX - 16, nY - 22 + ((getWeek(nDay) - 1) * 87));

				TodayStampRed_VIP_AnimText.SetLoopCount(1);
				TodayStampRed_VIP_AnimText.Stop();				
				TodayStampRed_VIP_AnimText.Play();
			}
			else
			{
				TodayStampRed_VIP_AnimText.HideWindow();
				TodayStampRed_VIP_AnimText.Stop();
			}
		}
		else
		{
			if (bPlay)
			{
				aniState_VipYellowStamp_nDay = nDay;
				nX = 3;
				nY = 3;

				TodayStampYellow_VIP_AnimText.ShowWindow();
				TodayStampYellow_VIP_AnimText.SetAnchor("AttendCheckWnd.AttendCheck_VIPGroup", "TopLeft", "TopLeft", 
														nX - 8, nY + 9 + ((getWeek(nDay) - 1) * 87));

				TodayStampYellow_VIP_AnimText.SetLoopCount(1);
				TodayStampYellow_VIP_AnimText.Stop();				
				TodayStampYellow_VIP_AnimText.Play();
			}
			else
			{
				TodayStampYellow_VIP_AnimText.HideWindow();
				TodayStampYellow_VIP_AnimText.Stop();
			}
		}
	}
	else
	{		
		if (isRed)
		{

			if (bPlay)
			{
				aniState_NormalRedStamp_nDay = nDay;

				nX = 7;
				nY = 87;
				TodayStampRed_AnimText.ShowWindow();
				TodayStampRed_AnimText.SetAnchor("AttendCheckWnd", "TopLeft", "TopLeft", 
												  nX - 16 + (getDay(nDay) - 1) * 59, nY - 22 + ((getWeek(nDay) - 1) * 87));

				TodayStampRed_AnimText.SetLoopCount(1);				
				TodayStampRed_AnimText.Stop();
				TodayStampRed_AnimText.Play();
			}
			else
			{
				TodayStampRed_AnimText.HideWindow();
				TodayStampRed_AnimText.Stop();
			}
		}
		else
		{
			if (bPlay)
			{
				aniState_NormalYellowStamp_nDay = nDay;

				nX = 6;
				nY = 86;
				TodayStampYellow_AnimText.ShowWindow();
				TodayStampYellow_AnimText.SetAnchor("AttendCheckWnd", "TopLeft", "TopLeft", 
													 nX - 8 + (getDay(nDay) - 1) * 59, nY + 9 + ((getWeek(nDay) - 1) * 87));

				TodayStampYellow_AnimText.SetLoopCount(1);
				TodayStampYellow_AnimText.Stop();				
				TodayStampYellow_AnimText.Play();
			}
			else
			{
				TodayStampYellow_AnimText.HideWindow();
				TodayStampYellow_AnimText.Stop();				
			}
		}
	}
}

// 투데이 빤짝이 모션 
function playMotionTodayTwinkle(bool isVip, int nDay, bool bPlay) 
{
	local int nX, nY;

	if(isVip && ((nDay % 7) == 0))
	{	
		if (bPlay)
		{
			TodayTwinkle_VIP_AnimTex.ShowWindow();
			TodayTwinkle_VIP_AnimTex.SetAnchor("AttendCheckWnd.AttendCheck_VIPGroup", "TopLeft", "TopLeft", 
												nX + 7, nY + 7 + ((getWeek(nDay) - 1) * 87));
		
			TodayTwinkle_VIP_AnimTex.Stop();
			TodayTwinkle_VIP_AnimTex.SetLoopCount(99999);
			TodayTwinkle_VIP_AnimTex.Play();
		}
		else
		{
			TodayTwinkle_VIP_AnimTex.HideWindow();
			TodayTwinkle_VIP_AnimTex.Stop();
		}
	}
	else
	{		
		if (bPlay)
		{
			nX = 7;
			nY = 87;

			TodayTwinkle_AnimTex.ShowWindow();
			TodayTwinkle_AnimTex.SetAnchor("AttendCheckWnd", "TopLeft", "TopLeft", 
											nX + 4 + (getDay(nDay) - 1) * 59, nY + 5 + ((getWeek(nDay) - 1) * 87));
			TodayTwinkle_AnimTex.Stop();
			TodayTwinkle_AnimTex.SetLoopCount(99999);
			TodayTwinkle_AnimTex.Play();
		}
		else
		{
			TodayTwinkle_AnimTex.HideWindow();
			TodayTwinkle_AnimTex.Stop();
		}
	}
}

// 윈도우 일반 슬롯 핸들 스트링
function string getSlotWnd(int slotNum)
{
	return "AttendCheckWnd.AttendCheck_SlotGroup.week" $ slotNum $ "Slot_Window";
}

// 윈도우 vip슬롯 핸들 스트링
function string getVipWnd()
{
	return "AttendCheckWnd.AttendCheck_VIPGroup";
}

// 날짜 숫자를 넣으면 각 단위로 "0" , "1"
function strDaySplit(int nDay, out string ten, out string one)
{
	if (nDay > 9) 
	{
		// 10 자리
		ten = Mid(string(nDay),0,1);
		one = Mid(string(nDay),1,1);
	}
	else 
	{
		// 1자리
		ten = "0";
		one = string(nDay);
	}	
}

// 1~28날짜를 넣으면 (1~4) 리턴
function int getWeek(int nDay)
{
	local int nValue;

	if ((nDay % 7) <= 0) nValue = nDay / 7;
	else nValue = (nDay / 7) + 1;

	return nValue;
}

// 1~28날짜를 넣으면 한주에서 몇일째인지를 리턴 (1~7)
function int getDay(int nDay)
{
	local int nValue;

	nValue = (nDay % 7);

	if (nValue <= 0) nValue = 7;
	return nValue;
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( getCurrentWindowName(string(Self))).HideWindow();
}
defaultproperties
{
}
