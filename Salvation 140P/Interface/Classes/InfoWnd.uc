class InfoWnd extends UICommonAPI;

var int m_TotalPoint;
var int m_AddPoint;
var int m_PeriodType;
var int m_RemainTime;
var int m_PointType;

// 2015-06-25 
// http://wallis-devsub/redmine/issues/1792
// 경고 메세지 삭제 작업 진행 
//var int m_DailyPoint;		//CT26P4_0323

var string m_ToppingWndName;
var string m_VPWndName;
var string m_PCCafeWndwName;
var string m_MysteriousMansionWaitingWndName;
var string m_WindowName;


var TextureHandle windowBackground;

//Handle
var WindowHandle Me;

/***************
 * **NP 토핑
 * *************/
var WindowHandle ToppingWnd;
var array<StatusIconHandle> toppingStatusIcons;
var array<TextureHandle> toppingDisableTextures;
var array<ToppingSkillExtraInfo> toppingDefaultInfos ;

/***************
 * **클래식 활력
 * *************/
var WindowHandle VPWnd;
var TextureHandle VpIcon;
var StatusBarHandle VpDetailBar;
var int nVitalityBonus, nVitalityExtraBonus, nVitalityItemMaxRestoreCount;
var bool isAfterStatusNormaEvent;
var bool isVPApply;//활력이 적용 되고 있는가? 

/****************
 * **PC 방 포인트
 * **************/
var WindowHandle PCCafeEventWnd;
var WindowHandle HelpButton;

/***************
 * **혼돈의 제전
 * *************/
var WindowHandle MysteriousMansionWaitingWnd;
var WindowHandle MHelpButton;
var ButtonHandle MCancelButton;


var array<WindowHandle> allWindow;

const TOPPING_MAX = 6;
const TOPPING_ICON_WH = 22;
//////

// 윈도우 정보
const WINDOW_H_MIN = 2;
const WINDOW_H_GAP = 2;
 
//branch : gorillazin 10. 04. 14. - pc cafe event
var bool m_bIsPCCafeEvent;
//end of branch

//branch GD35_0828 2013-12-06 luciper3 - 옵션 설정값을 임시로 저장하고 있는다.
var bool bIsOptionValue;
//end of branch

//branch EP1.0 2014-3-6 luciper3 - 상태변경 전 Show상태를 저장한다.
var bool bIsShowBackup;
//end of branch

const WINDOWS_MAX = 4;

var bool isEnterState;

var bool isShowInfoWnd;

function OnRegisterEvent()
{
	//branch EP1.0 2014-3-6 luciper3 - 게임상태가 변경되면 Show 처리하기위해 추가
	RegisterEvent( EV_GamingStateEnter );
	RegisterEvent( EV_GamingStatePreExit );
	//end of branch

	/*
	 * 토핑 버프 관련 이벤트 
	 * 클래식 VP 시스템 메시지를 위한 이벤트 
	 * */
	RegisterEvent( EV_AbnormalStatusNormalItem );

	/*
	 * 클래식 VP 창을 위한 버프 
	 * */	
	RegisterEvent( EV_UpdateUserInfo );
	RegisterEvent( EV_VitalityEffectInfo );	

	/*
	 * PC cafe 포인트
	 * */
	RegisterEvent( EV_PCCafePointInfo );
	RegisterEvent( EV_ToggleShowPCCafeEventWnd);	

	/*
	 * 혼돈의 제전 을 위한 에벤트 
	 * */
	RegisterEvent( EV_CuriousHouseWaitState );
	RegisterEvent( EV_CuriousHouseEnter ) ;
	RegisterEvent( EV_Restart );
	RegisterEvent( EV_NeedResetUIData);
}
	

function OnLoad()
{			
	local int i;

	/***************
	 * 클래식 활력
	 * */
	VPWnd = GetWindowHandle( m_VPWndName );
	VpDetailBar = GetStatusBarHandle ( m_VPWndName$".VpDetailBar");
	VpIcon = GetTextureHandle ( m_VPWndName$".VPIcon");
	//VpIcon = GetTextureHandle ( "");
    //VpDetailBar = GetStatusBarHandle ( ""); 

	/***************
	 * PC방 포인트 
	 * */
	PCCafeEventWnd = GetWindowHandle( m_PCCafeWndwName );
	HelpButton = GetWindowHandle( m_PCCafeWndwName$".HelpButton");
	
	/***************
	 * 토핑
	 * */
	ToppingWnd = GetWindowHandle( m_ToppingWndName );
	

	toppingStatusIcons.Length = TOPPING_MAX;
	for ( i = 0 ; i < TOPPING_MAX ; i ++ ) 
	{				
		toppingStatusIcons[i] = GetStatusIconHandle ( m_ToppingWndName $ ".StatusIcon" $ (i + 1));
		toppingStatusIcons[i].Clear();
		//toppingStatusIcons[i].AddRow();	

		toppingDisableTextures[i] = GetTextureHandle ( m_ToppingWndName $ ".toppingDisable" $ (i + 1));
	}

	/***************
	 * 혼돈의 제전 
	 * */
	MysteriousMansionWaitingWnd = GetWindowHandle ( m_MysteriousMansionWaitingWndName );
	MHelpButton = GetWindowHandle ( m_MysteriousMansionWaitingWndName $ ".MHelpButton");
	MHelpButton.SetTooltipCustomType(getCustomTooltip(GetSystemString(2812)));
	MCancelButton = GetButtonHandle ( m_MysteriousMansionWaitingWndName $ ".MCancelButton" );

	/***************
	 * 기타 
	 * */
	Me = GetWindowHandle( m_WindowName);	
	windowBackground = GetTextureHandle( m_WindowName$".CTextureCtrl939" ) ;	

	setWindowOrder();	

	//branch : gorillazin 10. 04. 14. - pc cafe event
	m_bIsPCCafeEvent = false;	
	//end of branch		
}

// 윈도우 배열 순서
function setWindowOrder()
{	
	local int i ;
	allWindow.Length = WINDOWS_MAX;
	// 토핑
	allWindow[i++] = ToppingWnd;
	// 활력
	allWindow[i++] = VPWnd;
	// 피씨방
	allWindow[i++] = PCCafeEventWnd;
	// 혼돈의 제전 취소
	allWindow[i++] = MysteriousMansionWaitingWnd;
}

function OnEvent( int a_EventID, String a_Param )
{
	//Debug( "OnEvent" @ a_EventID );
	switch( a_EventID )
	{
	//branch EP1.0 2014-3-6 luciper3 - OnEnter, OnExit 호출로 처리할려면 수정이 많이 필요할것같아서.. 게임상태전용 이벤트로 처리함
	case EV_GamingStateEnter:
//		Debug ( "EV_GamingStateEnter" );
		handleOnGamingStateEnter();
		break;
	case EV_GamingStatePreExit:
//		Debug ( "EV_GamingStatePreExit" );
		//클래식 서버가 아닐 경우에만 상태를 저장 한다.
		if ( !getInstanceUIData().getIsClassicServer() ) bIsShowBackup = PCCafeEventWnd.IsShowWindow() ;
		break;
		//end of branch		

	/******************************************
	 * 토핑 버프, 클래식 활력을 위한 이벤트 
	 */
	case EV_AbnormalStatusNormalItem :	
		if(GetLanguage() == ELanguageType.LANG_Korean)
		{
			handleBuffEvent ( a_Param);

			// 버프 이벤트, 활력 % 버프는 이 이벤트 이후 정상적으로 받을 수 있음.
			if ( getInstanceUIData().getIsClassicServer() ) 
			{
				if ( !isAfterStatusNormaEvent ) 
				{
					isAfterStatusNormaEvent = true;
					showVPSystemMsg();
				}
			}		
		}

		break;

	/******************************************
	 * 클래식 활력을 위한 이벤트 
	 */
	case EV_UpdateUserInfo:
		handleVPPoint();
		break;
	case EV_VitalityEffectInfo:		
		if(GetLanguage() == ELanguageType.LANG_Korean)
		{
			if ( getInstanceUIData().getIsClassicServer() ) HandleVitalityEffectInfo(a_Param);
		}
		break;

	/*********************************************
	 * PC 카페를 위한 이벤트 
	 */
	case EV_PCCafePointInfo:
		HandlePCCafePointInfo( a_Param );
		break;
	case EV_ToggleShowPCCafeEventWnd:
		HandleToggleShowPCCafeEventWnd();
		break;

	/*********************************************
	 * 혼돈의 제전을 위한 이벤트 들 
	 */
	case EV_Restart :
		setWindowShowHide ( MysteriousMansionWaitingWnd, false );		
		break;
	case EV_CuriousHouseEnter :     //9320
		setWindowShowHide ( MysteriousMansionWaitingWnd, false );		
		break;	
	case EV_CuriousHouseWaitState:  //9310
		CuriousHouseHandle( a_Param );
		break;
	case EV_NeedResetUIData :    
		MHelpButton.SetTooltipCustomType(getCustomTooltip(GetSystemString(2812)));
		break;
	}
}


function OnClickButton( String a_ButtonID )
{
	switch( a_ButtonID )
	{
	// PC 방 포인트 버튼 핸들
	/*
	case "HelpButton":
		OnClickHelpButton();
		break;
	*/
	case "CloseButton":	HandleToggleShowPCCafeEventWnd();    
		break;
	case "PCCafeBtn":	HandleToggleShowPCCafeCommuniWnd();    
		break;
	// 혼돈의 제전 버튼 핸들	
	case "MCancelButton":	RequestCancelCuriousHouse();
		break;
	}
}

/*********************************************************************************************************
 *
 * 토핑 버프 처리
 * 
 ********************************************************************************************************/

// 기본 토핑 값을 받음.
function getToppingDefault ()
{
	local int i ;
	local ToppingSkillExtraInfo tmpSkillExtraInfo;
//	Debug ( "getToppingDefault");
	toppingDefaultInfos.Remove(0, toppingDefaultInfos.Length );
	toppingDefaultInfos.Length = TOPPING_MAX;
	
	class'UIDATA_SKILL'.static.GetFirstDefaultToppingSkillExtraInfo( toppingDefaultInfos[0] ) ;		
	
	while ( class'UIDATA_SKILL'.static.GetNextDefaultToppingSkillExtraInfo( tmpSkillExtraInfo ) ) 
	{
		i ++ ;
		toppingDefaultInfos[ i ] = tmpSkillExtraInfo;
	}
}

// 토핑 아이콘을 스태터스 아이콘에 넣음
function setToppingBuffIcon ( int slotIndex, StatusIconInfo toppingInfo, bool bActive  )
{	
	local StatusIconInfo  tmpInfo;
	
//	Debug ( "setToppingBuffIcon" @ slotIndex );
	toppingStatusIcons[ slotIndex -1 ].GetItem( 0, 0, tmpInfo );

	if ( bActive )  toppingDisableTextures[ slotIndex -1 ].hideWindow();
	else toppingDisableTextures[ slotIndex -1 ].showWindow();

	if ( tmpInfo == toppingInfo ) return;

//	Debug ( "setToppingBuffIcon add " @ slotIndex );

	toppingStatusIcons[ slotIndex -1 ].Clear();
	toppingStatusIcons[ slotIndex -1 ].AddRow();
	toppingStatusIcons[ slotIndex -1 ].AddCol(0, toppingInfo);
}

// 버프 이벤트를 처리
function handleBuffEvent( string param ) 
{
	local int i;
	local int Max;
	local StatusIconInfo info ;	
	local ToppingSkillExtraInfo toppingSkillInfo;
	local array<int> bActivedSlot ;

	bActivedSlot.Length = TOPPING_MAX;

	//info 초기화
	info.Size = TOPPING_ICON_WH;
	info.BackTex = "l2ui_ct1.Ntopping_Lock";
	info.bShow = true;
	info.bEtcItem = false;
	info.bShortItem = false;	

	ParseInt(param, "ServerID", info.ServerID);
	ParseInt(param, "Max", Max);
	 
	//GetFirstToppingSkillExtraInfo( toppingSkillInfo) ;

	for (i = 0 ; i < Max ; i++ )
	{
		ParseItemIDWithIndex(param, info.ID, i);
		ParseInt(param, "SkillLevel_" $ i, info.Level);
		ParseInt(param, "SkillSubLevel_" $ i, info.SubLevel);
		ParseInt(param, "RemainTime_" $ i, info.RemainTime);
		ParseString(param, "Name_" $ i, info.Name);
		ParseString(param, "IconName_" $ i, info.IconName);
		ParseString(param, "Description_" $ i, info.Description);		

		// 활성화 된 토핑 아이템은 추가
		if ( class'UIDATA_SKILL'.static.IsToppingSkill( info.ID, info.Level, info.SubLevel) ) 
		{			
			class'UIDATA_SKILL'.static.GetToppingSkillExtraInfo ( info.ID, info.Level, info.SubLevel, toppingSkillInfo );
			bActivedSlot[ toppingSkillInfo.slotIndex -1 ] = 1;
			//Debug ( "setActiveToppingBuff index :" @ toppingSkillInfo.ID @ bActivedSlot[ toppingSkillInfo.slotIndex -1 ] @ toppingSkillInfo.Level @ info.SubLevel @ toppingSkillInfo.slotIndex -1);
			setToppingBuffIcon ( toppingSkillInfo.slotIndex, info, true ) ;
			//Debug ( "GetToppingSkillExtraInfo" @  toppingSkillInfo.ID @ toppingSkillInfo.Level @ toppingSkillInfo.subLevel @ toppingSkillInfo.slotIndex @ toppingSkillInfo.bIsDefault ) ;
		}
	}

	setDefaultToppingBuff ( bActivedSlot ) ;
}

// 비활성 기본 버프를 세팅
function setDefaultToppingBuff ( array<int> bActivedSlot ) 
{
	local int i;
	local StatusIconInfo info ;
	local bool isActived ;	
	
		//info 초기화
	info.Size = TOPPING_ICON_WH;
	info.BackTex = "l2ui_ct1.Ntopping_Lock";
	info.bShow = true;
	info.bEtcItem = false;
	info.bShortItem = false;
	
	for ( i = 0 ; i < TOPPING_MAX ; i++ )
	{
		isActived = bActivedSlot[i] == 1 ;

		//Debug ( "setDefaultToppingBuff index :"  @ i @ isActived @ bActivedSlot[i]) ;
		// 해당 슬롯의 버프 정보가 있으면 그 정보를 가지고 아니면 default 정보를 가지고 처리 함.
		// 없는 경우 default 에서 값을 가져 옴.
		if ( !isActived )
		{			
			//Debug ( "setDefaultToppingBuff index :"  @ i);
			info.ID = GetItemID (toppingDefaultInfos[i].ID );
			info.Level = toppingDefaultInfos[i].Level;
			info.SubLevel = toppingDefaultInfos[i].SubLevel;
			info.RemainTime = -1;
			info.Name = class'UIDATA_SKILL'.static.GetName( info.ID, info.Level, info.SubLevel );
			info.Description = class'UIDATA_SKILL'.static.GetDescription( info.ID, info.Level, info.SubLevel  );
			info.IconName = class'UIDATA_SKILL'.static.GetIconName( info.ID, info.Level, info.SubLevel );
			setToppingBuffIcon ( i + 1, info, false ) ; 			
		}
	}
}


/**************************************************************************
 * 
 * 클래식 활력 
 * 
 * ******************************************************************************/

function handleVPPoint ()
{
	local UserInfo userinfo;
	local int Vitality;	

	if( GetPlayerInfo( userinfo ) )
	{	
		Vitality = userinfo.nVitality;		

		VpDetailBar.SetPoint(Vitality, GetMaxVitality());
		
		// 활력이 거의 소전 됐을 때에도 활력이 남아 있는걸 보여주기 위한 보정 치
		if(Vitality < 2205 && Vitality > 0){
			VpDetailBar.SetPoint(2205, GetMaxVitality());
		} else {
			VpDetailBar.SetPoint(Vitality, GetMaxVitality());
		}
	}
}

// 클래식에서는 활력 아이템을 사용하지 않음.
function HandleVitalityEffectInfo(string param)
{	
	local CustomTooltip T;
	local int nVitality, nVitalityItemRestoreCount;		
	local string sBonusString;
	local string sExtraBonusString;
	local string sSysMsgParamString;
	local string tmpStr;

	local L2Util util;

	ParseInt(param, "vitalityPoint", nVitality);
	ParseInt(param, "vitalityBonus", nVitalityBonus);
	ParseInt(param, "restoreCount", nVitalityItemRestoreCount);
	ParseInt(param, "maxRestoreCount", nVitalityItemMaxRestoreCount);

	// 활력 추가 보너스 표시 2015.05
	ParseInt(param, "vitalityExtraBonus", nVitalityExtraBonus);
	
	//Debug ( "" @ nVitalityExtraBonus  @ isVPApplyChecked);
	sBonusString = nVitalityBonus $ "%";
	if ( nVitalityExtraBonus > 0 ) 
	{
		sExtraBonusString = "(+" $ nVitalityExtraBonus $ "%)";
	}	
	
	util = L2Util(GetScript("L2Util"));
	util.setCustomTooltip(T);

	// 활력 보너스:
	util.ToopTipInsertText( GetSystemString(2494), true, false );
	
	// 활력이 0 인 경우 미적용 표시
	if (nVitality <= 0)
	{		
		util.ToopTipInsertText(GetSystemString(2496), true, false, util.ETooltipTextType.COLOR_GRAY);			
		util.ToopTipInsertText(", ", true, false);
		VpIcon.SetTexture( "L2UI_CT1.Icon.InfoWnd_VPIcon_dis");
	}
	// 활력 0 이상인 경우 
	else
	{
		util.ToopTipInsertText(sBonusString, true, false);			
		util.ToopTipInsertText(sExtraBonusString, true, false, util.ETooltipTextType.COLOR_YELLOW03);		
		util.ToopTipInsertText(" " $ GetSystemString(2495) $ ". " , true, false);
		VpIcon.SetTexture("L2UI_CT1.Icon.InfoWNd_VPIcon");
	}		

	// 사용 할 수 있는 아이템 개수 
	sSysMsgParamString = "";
	tmpStr = "";		
	ParamAdd(sSysMsgParamString, "Type", string(int(ESystemMsgParamType.SMPT_NUMBER)));
	ParamAdd(sSysMsgParamString, "param1", string(nVitalityItemRestoreCount));
	AddSystemMessageParam(sSysMsgParamString);
	tmpStr = EndSystemMessageParam(6073, true);

	util.ToopTipInsertText(tmpStr, true, false);

	VpDetailBar.SetTooltipCustomType(util.getCustomTooltip());	

	// 활력 적용, 미적용이 변경 되는 경우에 시스템 메시지 출력 	
	if ( (isVPApply && nVitality == 0 ) || ( !isVPApply && nVitality  > 0 ) ) showVPSystemMsg();	
}

// 맨 처음 게임에 들어갔을 때 활력 관련 메시지를 출력 함.
// 활력 적용, 미적용이 변경 되는 경우에 시스템 메시지 출력 
function showVPSystemMsg( ) 
{
	local string sBonusString;
	local string sExtraBonusString;

	local string sSysMsgParamString ;
	local UserInfo userinfo; 
	local int nVitality ; 
	local string sMessage;

	if( !GetPlayerInfo( userinfo ) ) return;		
	
	nVitality = userinfo.nVitality ;

	sBonusString = nVitalityBonus $ "%";
	if ( nVitalityExtraBonus > 0 ) 
	{
		sExtraBonusString = "(+" $ nVitalityExtraBonus $ "%)";
	}	
	
	// 추가 보너스 정상 표시를 위해
	// 버프를 다 받고 나면, 활력 관련 메시지를 출력 할 수 있도록 함.
	if ( isAfterStatusNormaEvent )
	{
		isVPApply = nVitality > 0;
		
		// 활력 포인트가 0보다 큰 경우 적용 상태
		if ( isVPApply )
		{		
			//AddSystemMessage(3525);
			ParamAdd(sSysMsgParamString, "Type", string(int(ESystemMsgParamType.SMPT_STRING)));
			ParamAdd(sSysMsgParamString, "param1", sBonusString$sExtraBonusString );
			AddSystemMessageParam(sSysMsgParamString);
			sSysMsgParamString="";
			ParamAdd(sSysMsgParamString, "Type", string(int(ESystemMsgParamType.SMPT_NUMBER)));
			ParamAdd(sSysMsgParamString, "param1", string(nVitalityItemMaxRestoreCount));
			AddSystemMessageParam(sSysMsgParamString);
			sMessage = EndSystemMessageParam(6067, true);
			AddSystemMessageString(sMessage);
			isVPApply = true;
		}
		// 미적용 상태
		else 
		{
			//AddSystemMessage(3526);
			ParamAdd(sSysMsgParamString, "Type", string(int(ESystemMsgParamType.SMPT_NUMBER)));
			ParamAdd(sSysMsgParamString, "param1", string(nVitalityItemMaxRestoreCount));
			AddSystemMessageParam(sSysMsgParamString);
			sMessage = EndSystemMessageParam(6068, true);
			AddSystemMessageString(sMessage);
			isVPApply = false;
		}
	}
}

/**************************************************************************
 * 
 * PC방 포인트 처리
 * 
 * ******************************************************************************/

function HandleToggleShowPCCafeCommuniWnd()
{
	if ( getInstanceL2Util().getIsPrologueGrowType() ) AddSystemMessage( 4533 ) ;
	else class'PCCafeAPI'.static.RequestOpenWndWithoutNPC();	
}

/*
function OnClickHelpButton()
{
	// TODO: When TTMayrin implements HTML Control, load proper HTML... - NeverDie
}
*/

function HandlePCCafePointInfo( String a_Param )
{
	local int Show;
	local bool bOption;

	ParseInt( a_Param, "TotalPoint", m_TotalPoint );
	ParseInt( a_Param, "AddPoint", m_AddPoint );
	ParseInt( a_Param, "PeriodType", m_PeriodType );
	ParseInt( a_Param, "RemainTime", m_RemainTime );
	ParseInt( a_Param, "PointType", m_PointType );
	ParseInt( a_Param, "Show", Show );
	// 2015-06-25 
	// http://wallis-devsub/redmine/issues/1792
	// 경고 메세지 삭제 작업 진행 
	// ParseInt( a_Param, "DailyPoint", m_DailyPoint);		//CT26P4_0323
	
	//branch : gorillazin 10. 04. 14. - pc cafe event
	// EV_PCCafePointInfo 이벤트가 발생하면 PC Cafe 이벤트를 진행하고 있다는 뜻이므로 창을 띄워줘야 한다.
	// 이 function의 Show 변수와 같은 의미로 쓰일 수도 있음.
 	if( Show > 0 && !m_bIsPCCafeEvent )
 	{		
		// PC 게임 스테이트에 들어왔을 때 카페를 을 보여 줄 것인가?
		bOption = GetOptionBool( "ScreenInfo", "IsPcRoomBox" );
 		if ( !getInstanceUIData().getIsClassicServer() && !bOption) setWindowShowHide ( PCCafeEventWnd, true ) ;
 		m_bIsPCCafeEvent = true;
 	}
	//end of branch	
	RefreshPcCafeInfo(Show);
}

function bool IsPCCafeEventOpened()
{
	if( 0 < m_PeriodType )
		return true;

	return false;
}

function RefreshPcCafeInfo(int nShow)
{
	local Color TextColor;
	local String AddPointText;
	local String FullPointText;		//CT26P4_0323

	if( nShow == 0 )
	{
		//PCCafeEventWnd.HideWindow();
		setWindowShowHide ( PCCafeEventWnd) ;		
	}
	
	//HelpButton.SetTooltipCustomType(SetTooltip(GetHelpButtonTooltipText()));

	HelpButton.SetTooltipCustomType(getCustomTooltip(GetSystemString(2256)));

	FullPointText = MakeCostString( String( m_TotalPoint ) );

	//CT26P4_0323
	/*
	if (m_DailyPoint > 0) {
		nDailyMin = m_DailyPoint / 20;
		nDailyHour = nDailyMin / 60;
		nDailyMin = nDailyMin - nDailyHour * 60;
		FullPointText = FullPointText $ " [" $ GetFormattedTimeStrMMHH(nDailyHour, nDailyMin) $ "]";
	}*/
	
	class'UIAPI_TEXTBOX'.static.SetText( m_PCCafeWndwName$".PointTextBox", FullPointText );
	class'UIAPI_WINDOW'.static.SetAlpha( m_PCCafeWndwName$".PointAddTextBox", 0 );
	if( 0 != m_AddPoint && nShow != 0 )
	{
		if( 0 < m_AddPoint )
			AddPointText = "+" $ MakeCostString( String( m_AddPoint ) );
		else
			AddPointText = MakeCostString( String( m_AddPoint ) );

		class'UIAPI_TEXTBOX'.static.SetText( m_PCCafeWndwName$".PointAddTextBox", AddPointText );

		switch( m_PointType )
		{
		case 0:	// Normal
			TextColor.R = 255;
			TextColor.G = 255;
			TextColor.B = 0;
			break;
		case 1:	// Bonus
			//TextColor.R = 255;
			//TextColor.G = 0;
			//TextColor.B = 0;
			TextColor.R = 0;
			TextColor.G = 255;
			TextColor.B = 255;
			break;
		case 2:	// Decrease
			//TextColor.R = 0;
			//TextColor.G = 255;
			//TextColor.B = 255;
			TextColor.R = 255;
			TextColor.G = 0;
			TextColor.B = 0;
			break;
		}

		class'UIAPI_TEXTBOX'.static.SetTextColor( m_PCCafeWndwName$".PointAddTextBox", TextColor );
		class'UIAPI_WINDOW'.static.SetAnchor( m_PCCafeWndwName$".PointAddTextBox", m_PCCafeWndwName, "TopRight", "TopRight", -5, 41 );
		class'UIAPI_WINDOW'.static.ClearAnchor( m_PCCafeWndwName$".PointAddTextBox" );
		class'UIAPI_WINDOW'.static.Move( m_PCCafeWndwName$".PointAddTextBox", 0, -18, 1.f );
		class'UIAPI_WINDOW'.static.SetAlpha( m_PCCafeWndwName$".PointAddTextBox", 255 );
		class'UIAPI_WINDOW'.static.SetAlpha( m_PCCafeWndwName$".PointAddTextBox", 0, 0.8f );
		m_AddPoint = 0;
	}
}

/** 현재 사용안함 정책이 바뀌었음 */
function String GetHelpButtonTooltipText()
{
	local String TooltipSystemMsg;

	if( 1 == m_PeriodType )
		TooltipSystemMsg = GetSystemMessage( 1705 );
	else if( 2 == m_PeriodType )
		TooltipSystemMsg = GetSystemMessage( 1706 );
	else
		return "";

	return MakeFullSystemMsg( TooltipSystemMsg, string( m_RemainTime ), "" );
}


// 빌더 명령어에 의해 창을 감추고 보여주는 함수
function HandleToggleShowPCCafeEventWnd(optional bool bIsForceSet, optional bool bIsHide)
{	
	//local bool bIsHideOption;
	// 해당 옵션은 게임 스테이트에 들어왔을 때 체크 합니다.
	//bIsHideOption = GetOptionBool( "ScreenInfo", "IsPcRoomBox" );
	
	//log("===== Toggle Show Func ===== IsPCCafeEvent() : "$m_bIsPCCafeEvent$" === Force : "$bIsForceSet$" === bIsHide : "$bIsHide);

	//branch GD35_0828 2013-12-9 luciper3 - 옵션에서 호출하면 따로처리한다.
	if( bIsForceSet )
	{
		SetOptionValue(bIsHide);
		setWindowShowHide ( PCCafeEventWnd, !bIsHide && IsPCCafeEvent() && !getInstanceUIData().getIsClassicServer() ) ;
		/*
		if( !bIsHide && IsPCCafeEvent() && !getInstanceUIData().getIsClassicServer())
			
			//PCCafeEventWnd.ShowWindow();
		else
//			PCCafeEventWnd.HideWindow();
			setWindowShowHide ( PCCafeEventWnd ) ;
*/
		
		//setWindowSize();
		return;
	}
	//end of branch

	if( PCCafeEventWnd.isShowWindow() )
	{
		setWindowShowHide ( PCCafeEventWnd ) ;		
	}
	else if( IsPCCafeEvent() )
	{
		if ( !getInstanceUIData().getIsClassicServer()) 
		{
//			Debug ( "HandleToggleShowPCCafeEventWnd");
			setWindowShowHide ( PCCafeEventWnd, true ) ;
			//PCCafeEventWnd.ShowWindow();
		}
	}	
}

//branch : gorillazin 10. 04. 14. - pc cafe event
function bool IsPCCafeEvent()
{
	//brancg GD35_0828 2013-12-06 luciper3 - 보여줘야하는데 옵션에서 감추기설정이면 안보여준다.
	if( m_bIsPCCafeEvent && bIsOptionValue )
		return false;
	//end of branch

	return m_bIsPCCafeEvent;
}
//end of branch

/*********************************************************************************************************
 *
 * 혼돈의 제전 처리
 * 
 ********************************************************************************************************/

function CuriousHouseHandle (string a_Param)
{	
	local int HouseState;
	ParseInt(a_Param, "State", HouseState);
	switch (HouseState){
	case 0 : //입장 불가능 마감시간이 지난 뒤  입장 불가능이 될 경우 		
	case 1 : //입장 가능		
		setWindowShowHide ( MysteriousMansionWaitingWnd, false );
		break;
	case 2 : //대기 상태
		AddSystemMessage(3732);//초대 관련 메시지
		MCancelButton.EnableWindow(  );		
		setWindowShowHide ( MysteriousMansionWaitingWnd, true );
		Me.SetFocus();
		break;
	case 3 : //취소 불가능의 상태
		MCancelButton.disableWindow();
		break;		
	}
}

/*******************************************************
 * 윈도우 이벤트 
 ********************************************************/

// 게임 스테이트 들어왔을 때 처리 
function handleOnGamingStateEnter()
{
	// 1 이면 토핑을 사용 한다.
	local int useToppingType;
	local bool bOption;

	// PC 게임 스테이트에 들어왔을 때 카페를 을 보여 줄 것인가?
	bOption = GetOptionBool( "ScreenInfo", "IsPcRoomBox" );
	
	if ( bOption ) {
		//PCCafeEventWnd.HideWindow();
		setWindowShowHide ( PCCafeEventWnd ) ;
	} else 
	{
//		Debug( "handleOnGamingStateEnter" @ PCCafeEventWnd @ bIsShowBackup && !getInstanceUIData().getIsClassicServer() );
		setWindowShowHide ( PCCafeEventWnd, bIsShowBackup && !getInstanceUIData().getIsClassicServer() ) ;
	}	
	
	// 토핑을 보여 줄 것인가?
	if ( !GetINIBool("L2UI", "UseTopping", useToppingType, "L2.ini" ) ) useToppingType = 0;

//	Debug ( "handleOnGamingStateEnter" @ useToppingType @ GetINIBool("L2UI", "UseTopping", useToppingType, "L2.ini" ));
	if ( useToppingType == 1 ) 
	{
		getToppingDefault();
	}
	setWindowShowHide(ToppingWnd, useToppingType == 1);

	// 혼돈의 제전 웨이팅 창 끄기	
	setWindowShowHide( MysteriousMansionWaitingWnd );
}

function OnEnterState( name a_PreStateName )
{	
	local int nShow;

	/*
	 * 활력
	 * */	
	isAfterStatusNormaEvent = false;
	//branch EP3.0 2016-3-16 luciper3 - 해외에서는 사용하지않음
	setWindowShowHide(VPWnd,false);
	//setWindowShowHide( VPWnd, getInstanceUIData().getIsClassicServer()  ) ;
	//end of branch

	/* 
	 * Pc 방 포인트 
	 * */
	if( IsPCCafeEvent() )
		nShow = 1;
	else 
		nShow = 0;

	//branch : gorillazin 10. 04. 14. - pc cafe event
	RefreshPcCafeInfo(nShow);
	//end of branch	
	
	isEnterState = true;
	//Refresh(1);
	Me.ShowWindow();
}

function OnExitState( name a_NextStateName )
{
	//Debug ( "OnExitState" @ a_NextStateName);
	RefreshPcCafeInfo(0);
	// 혼돈의 제전 웨이팅 창 끄기
	//setWindowShowHide( MysteriousMansionWaitingWnd );
	isEnterState = false;
	Me.HideWindow();
	
}

function OnShow()
{
	if ( !isShowInfoWnd ) Me.HideWindow();
	//	Debug( "onShow");
	//onShow 때 setWindowShowHide 함수를 쓰지 말 것. 아직 설정값을 다 받지 못한 상태라 잘 못하면 다시 닫힘.
	// OnEnterState 때 쓸 것 
}

function OnHide()
{	
	PlayConsoleSound(IFST_WINDOW_CLOSE);	
}

function CustomTooltip getCustomTooltip(string Text)
{
	local CustomTooltip Tooltip;
	local DrawItemInfo info;
	
	Tooltip.MinimumWidth = 144;
	
	Tooltip.DrawList.Length = 1;
	info.eType = DIT_TEXT;
	info.t_bDrawOneLine = true;
	info.t_color.R = 178;
	info.t_color.G = 190;
	info.t_color.B = 207;
	info.t_color.A = 255;
	info.t_strText = Text;
	Tooltip.DrawList[0] = info;

	return Tooltip;
}


/*
 * 1. 윈도우를 show, hide 
 * 2. 그 아래 윈도우들의 위치를 정렬.
 * 3. 그 사이즈 만큼 전체 윈도우 사이즈를 조절 함.
 * 위치 보정 나중에 여러 윈도우들 껐다 켰다 확장용 
 */
function setWindowShowHide ( WindowHandle tmpWnd, optional bool isShow )
{
	local int nWndWidth, nWndHeight, i;	
	local int nWndHMax;
	local Rect rectWnd;	
	
	if ( isShow == tmpWnd.IsShowWindow() ) return;	

	///if (tmpWnd == PCCafeEventWnd  ) Debug ( "setWindowShowHide" @ isShow );
	if ( isShow ) tmpWnd.ShowWindow();	
	else tmpWnd.hideWindow ();	
	
	rectWnd = Me.GetRect();

	isShowInfoWnd = false ;

	// 열려 있는 창을 찾아서 위치와 크기를 조절 한다.
	for ( i = 0 ; i < allWindow.Length ; i++ )
	{		
		if ( allWindow[i].IsShowWindow() )
		{
			//Debug( "보여지고 있다" @ allWindow[i].GetWindowName());
			allWindow[i].GetWindowSize(nWndWidth, nWndHeight);
			allWindow[i].MoveTo( rectWnd.nX, rectWnd.nY + nWndHMax);
			nWndHMax = nWndHMax + nWndHeight;
			isShowInfoWnd = true;
		}
	}	
	
	Me.SetWindowSize ( rectWnd.nWidth, nWndHMax + WINDOW_H_MIN );
	windowBackground.SetWindowSize ( rectWnd.nWidth, nWndHMax + WINDOW_H_MIN);
	
//	Debug ( "setWindowShowHide" @ isEnterState  );
	if ( isShowInfoWnd  && isEnterState)
	{
		//Debug ( "보여주자" );
		Me.ShowWindow();
	}
	else 
	{
		//Debug ( "숨기자 " );
		Me.HideWindow();		
	}

//	Debug( "setWindowShowHide" @ tmpWnd.GetWindowName() @ isShowInfoWnd  @ Me.IsShowWindow() ) ;
}

// branch GD35_0828 2013-12-9 luciper3 - 옵션 설정값을 임시로 저장한다.
// 사용 되지 않는 듯 함.
function SetOptionValue(bool bValue)
{
	bIsOptionValue = bValue;
}
//end of branch

defaultproperties
{
    m_ToppingWndName="InfoWnd.ToppingWnd"
    m_VPWndName="InfoWnd.VPWnd"
    m_PCCafeWndwName="InfoWnd.PCCafeEventWnd"
    m_MysteriousMansionWaitingWndName="InfoWnd.MysteriousMansionWaitingWnd"
    m_WindowName="InfoWnd"
}
