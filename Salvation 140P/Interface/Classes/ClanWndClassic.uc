class ClanWndClassic extends UIData;

const DIALOG_StartPledgeWar = 90006;
const DIALOG_AskPledgeWar = 90010;
const TIMER_ID=20001;
const TIMER_DELAY=200;

var WindowHandle Me;
var ClanDrawerWndClassic ClanDrawerWndClassicScript;

var int m_clanID;
var string m_clanName;
var int m_clanRank;
var int m_clanLevel;
var int m_clanNameValue;
var int m_bMoreInfo;
var int m_currentShowIndex;
var int G_CurrentRecord;
var string G_CurrentSzData;
var bool G_CurrentAlias;
var int G_IamNobless;
var bool G_IamHero;
var int G_ClanMember;
var String m_WindowName;
var String m_DrawerWindowName;
var String m_ClanPledgeBonusDrawerWndName;

//var int m_unionType;

// 자신의 혈맹 정보
var int 	m_myClanType;
var string 	m_myName;
var string 	m_myClanName;
var int 	m_indexNum;
//var int 	m_indexNumKH;

//Global bool variables to manage the status of the drawer wnd opened and closed;
var bool m_currentactivestatus1; //혈원정보창
var bool m_currentactivestatus2; //혈원권한창
var bool m_currentactivestatus3; //혈맹정보
var bool m_currentactivestatus4; //패널티
var bool m_currentactivestatus5; //전쟁정보
var bool m_currentactivestatus6; //권한편집
var bool m_currentactivestatus7; //문장관리
var bool m_currentactivestatus8; //영웅메뉴

// 혈맹 권한(자신)
var int		m_bClanMaster;
var int		m_bJoin;
var int		m_bNickName;
var int		m_bCrest;
var int		m_bWar;
var int		m_bGrade;
var int		m_bManageMaster;
var int		m_bOustMember;

//var 	TextBoxHandle	txtDominionWarTitle;
//var 	TextBoxHandle	txtDominionWarStatus;
//var 	TextBoxHandle	TxtDominionWar_Title;
//var 	TextBoxHandle	TxtDominion;
//var 	TextBoxHandle	TxtDominionWarStatusTitle;
var 	TextBoxHandle	TxtClanWar_Title;

var ListCtrlHandle	m_hClanMemberList;


//현재 선택된 그룹의 기사단장 이름
var string m_CurrentclanMasterName;
// 현재 선택된 그룹의 혈맹주 이름
var string m_CurrentclanMasterReal;
//현재 선택된 기사단의 종류?
var int m_CurrentNHType;

//var array<int>		m_knighthoodList;				// 현재 창설된 기사단의 인덱스들( 존재하지 않는 기사단은 보여주면 안됨 )
var array<ClanInfo> m_memberList;

// 전쟁 선포할 혈맹 이름 
var string withWarPledgeNameStr;
var int     pledgeDelayTimerCount;
//내 혈맹 정보 세팅 oxyzen coded

// 해외 온오프라인 버튼 기억
var bool bShowOnlyOnlineUser;

function getmyClanInfo() 
{
	local UserInfo userinfo;
	//userinfo = GetUser();
	if( GetPlayerInfo( userinfo ) )
	{
		m_myName = userinfo.Name;
		m_myClanType = findmyClanData(m_myName);
		G_IamNobless = userinfo.nNobless;
		G_IamHero = userinfo.bHero;
		G_ClanMember = userinfo.nClanID;
	}
	//Debug("------------------------------------------------------------------");
	//Debug("MyNameGet =" @  m_myName);
	//Debug("MyClanTypeGet =" @  m_myClanType);
	//Debug("MyClanMember =" @  G_ClanMember);
	//Debug("IamHero =" @  G_IamHero);
	//Debug("G_IamNobless =" @  G_IamNobless);
	//Debug("MyClanNameGet = " @ m_myClanName);
	//Debug("------------------------------------------------------------------");

}

//내 기사단 정보를 찾아오는 함수.
function int findmyClanData(string C_Name)
{
	local int i;
	local int j;
	local int clannum;
	for( i=0 ; i < m_memberList.Length ; ++i )
	{
		for ( j = 0 ; j < m_memberList[i].m_array.Length ; ++j )
		{
			if(m_memberList[i].m_array[j].sName == C_Name)
			{
				clannum = m_memberList[i].m_array[j].clanType;
				//m_myClanName = m_memberList[i].sName;
			}
		}
	}
	return clannum;
}

function OnLoad()
{
	SetClosingOnESC();

	InitHandleCOD();		
	
	Load();	// GMClanWnd에서 사용

	m_memberList.Length = CLAN_KNIGHTHOOD_COUNT;

	//m_unionType = 0;

	m_currentShowIndex = 0;
	m_bMoreInfo = 0;
	G_CurrentAlias = false;

	Clear();
	
	//set entire windows has closed.
	m_currentactivestatus1 = false;
	m_currentactivestatus2 = false;
	m_currentactivestatus3 = false;
	m_currentactivestatus4 = false;
	m_currentactivestatus5 = false;
	m_currentactivestatus6 = false;
	m_currentactivestatus7 = false;

	//class'UIDATA_CLAN'.static.RequestClanInfo();

	m_hClanMemberList=GetListCtrlHandle(m_WindowName $ ".ClanMemberList");
	
	ClanDrawerWndClassicScript = ClanDrawerWndClassic( GetScript( m_DrawerWindowName ));

	bShowOnlyOnlineUser = false;
}


function InitHandleCOD()
{
	Me = GetWindowHandle( m_WindowName );

	//TxtDominionWar_Title = GetTextBoxHandle (  m_DrawerWindowName$".ClanWarManagementWnd.TxtDominionWar_Title"  );
	//TxtDominion = GetTextBoxHandle (  m_DrawerWindowName$".ClanWarManagementWnd.TxtDominion"  );
	//TxtDominionWarStatusTitle = GetTextBoxHandle (  m_DrawerWindowName$".ClanWarManagementWnd.TxtDominionWarStatusTitle"  );
	TxtClanWar_Title = GetTextBoxHandle (  m_DrawerWindowName$".ClanWarManagementWnd.TxtClanWar_Title"  );
	
	//txtDominionWarTitle = GetTextBoxHandle (  m_DrawerWindowName$".ClanWarManagementWnd.txtDominionWarTitle"  );
	//txtDominionWarStatus = GetTextBoxHandle (  m_DrawerWindowName$".ClanWarManagementWnd.txtDominionWarStatus"  );
}


function Load()
{
	pledgeDelayTimerCount = 0;	
}

function OnRegisterEvent()
{
	registerEvent( EV_ClanInfo );
	registerEvent( EV_ClanInfoUpdate );
	registerEvent( EV_ClanDeleteAllMember );
	registerEvent( EV_ClanAddMember );
	registerEvent( EV_ClanMemberInfoUpdate );
	registerEvent( EV_ClanAddMemberMultiple );
	registerEvent( EV_ClanDeleteMember );
	registerEvent( EV_GamingStateEnter );
	registerEvent( EV_GamingStateExit );
	registerEvent( EV_ClanMyAuth );
	registerEvent( EV_ClanSubClanUpdated );
	registerEvent( EV_ResultJoinDominionWar );
	registerEvent( EV_RequestStartPledgeWar );

	registerEvent(EV_SendIsActiveUnionInfoBtn);  //  혈맹 조합 가입 여부

	registerEvent(EV_PledgeBonusMarkReset);  // 혈맹 보상 초기화 10142

	registerEvent(EV_DialogOK);
	registerEvent(EV_DialogCancel);	
}

// 문춘식
function int GetClanTypeFromIndex( int index )
{
	local int type;
	if( index == 0 )
	{
		type = CLAN_MAIN;
	}
	if( index == 1 )
	{
		type = CLAN_KNIGHT1;
	}
	if( index == 2 )
	{
		type = CLAN_KNIGHT2;
	}
	if( index == 3 )
	{
		type = CLAN_KNIGHT3;
	}
	if( index == 4 )
	{
		type = CLAN_KNIGHT4;
	}
	if( index == 5 )
	{
		type = CLAN_KNIGHT5;
	}
	if( index == 6 )
	{
		type = CLAN_KNIGHT6;
	}
	if( index == 7 )
	{
		type = CLAN_ACADEMY;
	}
	return type;
}

function string GetClanTypeNameFromIndex(int index)
{
	local string type;
	if( index == CLAN_MAIN )
	{
		type = GetSystemString(1399);
	}
	if( index == CLAN_KNIGHT1 )
	{
		type = GetSystemString(1400);
	}
	if( index == CLAN_KNIGHT2 )
	{
		type = GetSystemString(1401);
	}
	if( index == CLAN_KNIGHT3 )
	{
		type = GetSystemString(1402);
	}
	if( index == CLAN_KNIGHT4 )
	{
		type = GetSystemString(1403);
	}
	if( index == CLAN_KNIGHT5 )
	{
		type = GetSystemString(1404);
	}
	if( index == CLAN_KNIGHT6 )
	{
		type = GetSystemString(1405);
	}
	if( index == CLAN_ACADEMY )
	{
		type = GetSystemString(1452);
	}
	return type;
}

function OnShow()
{
	local int i;

	// 해외, 혈맹 보상 관련 유저 카운팅 위치 보정 용.
	local Rect comboboxMainClanWndRect;

	// 해외 혈맹 보상 관련
	comboboxMainClanWndRect = GetComboBoxHandle(m_WindowName $ ".ComboboxMainClanWnd").GetRect();

	// 해외, 혈맹 보상 개선, 한국만 사용 하지 않는다.(2015-08-28)
	if(IsUsePledgeBonus()) 
	{
		GetTextBoxHandle(m_WindowName $ ".ClanCurrentNum").MoveTo(comboboxMainClanWndRect.nX + 184, comboboxMainClanWndRect.nY + 3);

		GetTextureHandle(m_WindowName $ ".PledgeflagIcon_Texture").ShowWindow();
		GetButtonHandle(m_WindowName $ ".PledgeBonusWnd_Btn").ShowWindow();

		// 온오프라인 보기 버튼
		if (bShowOnlyOnlineUser)
		{			
			GetButtonHandle(m_WindowName $ ".PledgePCOnline_Btn").ShowWindow();
			GetButtonHandle(m_WindowName $ ".PledgePCOffline_Btn").HideWindow();
		}
		else
		{
			GetButtonHandle(m_WindowName $ ".PledgePCOnline_Btn").HideWindow();
			GetButtonHandle(m_WindowName $ ".PledgePCOffline_Btn").ShowWindow();
		}

		m_hClanMemberList.SetColumnString(3, 5850); // 혈맹활동으로 리스트 헤더 변경

		// Debug("혈맹보상 UI Api Call -------> PledgeBonusOpen()");
		// Debug("혈맹보상 UI Api Call -------> PledgeBonusRewardList()");

		// 혈맹 보상 목록을 받았나?, 리스타트 하기전에는 한번만 받게 한다.
		if(getInstanceUIData().getIsClassicServer())
		{
			if(!ClanPledgeBonusDrawerWndClassic(GetScript("ClanPledgeBonusDrawerWndClassic")).getHasPledgeBonusList())
			{
				PledgeBonusRewardList();
			}
		}
		else
		{
			if(!ClanPledgeBonusDrawerWnd(GetScript("ClanPledgeBonusDrawerWnd")).getHasPledgeBonusList())
			{
				PledgeBonusRewardList();
			}
		}
		PledgeBonusOpen();	
	}
	else 
	{
		GetTextBoxHandle(m_WindowName $ ".ClanCurrentNum").MoveTo(comboboxMainClanWndRect.nX + 202, comboboxMainClanWndRect.nY + 3);

		m_hClanMemberList.SetColumnString(3, 346); // 접속상태
		GetButtonHandle(m_WindowName $ ".PledgePCOnline_Btn").HideWindow();
		GetButtonHandle(m_WindowName $ ".PledgePCOffline_Btn").HideWindow();

		GetTextureHandle(m_WindowName $ ".PledgeflagIcon_Texture").HideWindow();
		GetButtonHandle(m_WindowName $ ".PledgeBonusWnd_Btn").HideWindow();
	}

	getmyClanInfo();
	RefreshCombobox();
	resetBtnShowHide();
	NoblessMenuValidate();	
	//class'UIAPI_WINDOW'.static.HideWindow(m_WindowName $ ".MemberInfoBtnWnd");

	
	//class'UIAPI_COMBOBOX'.static.SetSelectedNum(m_WindowName $ ".ClanMemberList", m_indexNumKH);
	//debug("ShowmyIndexNum:" @ m_indexNumKH);
	//debug("Showm_myClanType:" @ m_myClanType);
	//class'UIAPI_COMBOBOX'.static.GetReserved(m_WindowName $ ".ComboboxMainClanWnd", class'UIAPI_COMBOBOX'.static.GetSelectedNum(m_WindowName $ ".ComboboxMainClanWnd")
	
	for (i=10; i>=0; --i)
	{
		//ComboboxData = class'UIAPI_COMBOBOX'.static.GetReserved(m_WindowName $ ".ComboboxMainClanWnd", i)
		if (class'UIAPI_COMBOBOX'.static.GetReserved(m_WindowName $ ".ComboboxMainClanWnd", i) == m_myClanType)
		{
			//debug("What:"@ class'UIAPI_COMBOBOX'.static.GetReserved(m_WindowName $ ".ComboboxMainClanWnd", i));
			//Debug("ComboboxLoc:"@i);
			//Debug("m_myClanType:"@m_myClanType);
			class'UIAPI_COMBOBOX'.static.SetSelectedNum(m_WindowName $ ".ComboboxMainClanWnd", i);
		} 
	}
	//if (class'UIAPI_COMBOBOX'.static.GetReserved(m_WindowName $ ".ComboboxMainClanWnd", i) == -1)
	//{
			//Debug("ComboboxLoc:"@i);
			//class'UIAPI_COMBOBOX'.static.SetSelectedNum(m_WindowName $ ".ComboboxMainClanWnd", i);
	//} 
	ShowList(m_myClanType);
	class'UIAPI_LISTCTRL'.static.SetSelectedIndex( m_WindowName $ ".ClanMemberList", m_indexNum ,true);
	//TTP 15881 아카데미 정보원 수정
	if (m_myClanType == -1)
	{
	class'UIAPI_LISTCTRL'.static.SetSelectedIndex( m_WindowName $ ".ClanMemberList", m_indexNum -1,true);
	}

}

function NoblessMenuValidate()
{
	//debug("NoblessMenuValidate");
	if (G_ClanMember == 0)
	{
		if (G_IamHero == true || G_IamNobless > 0)
		{
			class'UIAPI_WINDOW'.static.ShowWindow(m_WindowName $ ".HeroBtn");
			class'UIAPI_WINDOW'.static.HideWindow(m_WindowName $ ".ClanMemInfoBtn");
		}
		else
		{
			class'UIAPI_WINDOW'.static.HideWindow(m_WindowName $ ".HeroBtn");
			class'UIAPI_WINDOW'.static.ShowWindow(m_WindowName $ ".ClanMemInfoBtn");
		}
	}
	else
	{
		class'UIAPI_WINDOW'.static.HideWindow(m_WindowName $ ".HeroBtn");
		class'UIAPI_WINDOW'.static.ShowWindow(m_WindowName $ ".ClanMemInfoBtn");
	}
}

function OnHide()
{
	// 2006/04/03 - Removed by NeverDie
	//	Drawer child window now automatically hides upon hiding Drawer parent window
	//class'UIAPI_WINDOW'.static.HideWindow("ClanDrawerWnd");
}

//function onKeyUp(EInputKey nKey)
//{
	//if (nKey == IK_N )
	//{
	//debug("keyinput");
	//getmyClanInfo();
	//NoblessMenuValidate();
	//}
	//if (nKey == IK_alt + IK_N )
	//{
	//debug("keyinput");
	//getmyClanInfo();
	//NoblessMenuValidate();
	//}
//}

function OnEnterState( name a_PreStateName )
{
	if (getInstanceL2Util().isClanV2()) return;

	getmyClanInfo();
	NoblessMenuValidate();
	//if( a_PreStateName == 'GamingState' )
	//{
	//	getmyClanInfo();
	//	NoblessMenuValidate();
	//}
	Clear();
	class'UIDATA_CLAN'.static.RequestClanInfo();
}

function OnClickButton( string strID )
{	
	local LVDataRecord record;
	local string strParam;

	record.LVDataList.Length = 10;

	// 혈원 정보
	if( strID == "ClanMemInfoBtn" )
	{
		if( m_currentactivestatus1 == false)
		{
			ResetOpeningVariables();
			m_currentactivestatus1 = true;
			// 아무것도 없는 레코드가 리턴될 수도 있다. 체크할 것.
			if( GetSelectedListCtrlItem( record ) )
			{
				//debug("Asking ClanMemberInfo " $ record.LVDataList[0].szData $ " " $ record.LVDataList[0].nReserved1 );
				RequestClanMemberInfo( int(record.nReserved1), record.LVDataList[0].szData );
				G_CurrentRecord = int(record.nReserved1);
				G_CurrentSzData = record.LVDataList[0].szData;
				if (record.LVDataList[3].szData == "0")
				{
					G_CurrentAlias = true;
				} 
				else
				{
					G_CurrentAlias = false;
				}
				ClanDrawerWndClassicScript.SetStateAndShow("ClanMemberInfoState");
				//script.SetStateAndShow("ClanMemberInfoState");
			}
		} else {
		// 서랍창의 글로벌 변수를 리셋
		m_currentactivestatus1 = false;
		ClanDrawerWndClassicScript.HideClanWindow();
		}
	}

	//혈원권한
	else if( strID == "ClanMemAuthBtn" )
	{
		if(m_currentactivestatus2 == false)
		{
			ResetOpeningVariables();
			m_currentactivestatus2 = true;
			if( GetSelectedListCtrlItem( record ) )
			{
				RequestClanMemberAuth( int(record.nReserved1), record.LVDataList[0].szData );
				ClanDrawerWndClassicScript.SetStateAndShow("ClanMemberAuthState");
			}
		} else {
		// 서랍창의 글로벌 변수를 리셋
		m_currentactivestatus2 = false;
		ClanDrawerWndClassicScript.HideClanWindow();
		}
	}
	//게시판
	else if( strID == "ClanBoardBtn" )
	{
		// request open BBS
		ParamAdd(strParam, "Index", "3");
		ExecuteEvent(EV_ShowBBS, strParam);
	}
	//혈맹정보
	else if( strID == "ClanInfoBtn" )
	{
		if(m_currentactivestatus3 == false)
		{
			ResetOpeningVariables();
			m_currentactivestatus3 = true;
			ClanDrawerWndClassicScript.SetStateAndShow("ClanInfoState");
		} else {
		m_currentactivestatus3 = false;
		ClanDrawerWndClassicScript.HideClanWindow();
		}
		
	}
	//패널티
	else if( strID == "ClanPenaltyBtn" )
	{
		//ClanDrawerWndClassicScript.SetStateAndShow("ClanPenaltyWndState");
		ExecuteCommandFromAction("pledgepenalty");
	}
	//혈맹탈퇴
	else if( strID == "ClanQuitBtn" )
	{
		// Ask to quit Clan
		RequestClanLeave(m_clanName, m_myClanType);
	}
	//전쟁정보
	else if( strID == "ClanWarInfoBtn" )
	{
		if(m_currentactivestatus5 == false)
		{
			ResetOpeningVariables();
			m_currentactivestatus5 = true;
			ClanDrawerWndClassicScript.m_clanWarListPage = -1;
			RequestClanWarList(0, 0);			// 0 page
			ClanDrawerWndClassicScript.SetStateAndShow("ClanWarManagementWndState");
		} else {
		m_currentactivestatus5 = false;
		ClanDrawerWndClassicScript.HideClanWindow();
		}
	}
	//전쟁선포
	else if( strID == "ClanWarDeclareBtn" )
	{
		RequestClanDeclareWar();
	}
	//전쟁철회 -> 혈맹조합 -> 혈맹가입게시판
	else if( strID == "ClanUnionBtn" )
	{
		if ( class'UIAPI_WINDOW'.static.IsShowWindow ("ClanSearch") )
		{
			class'UIAPI_WINDOW'.static.HideWindow("ClanSearch");
		}
		else
		{
			class'UIAPI_WINDOW'.static.ShowWindow("ClanSearch");
		}
		//class'UIDATA_CLAN'.static.RequestOpenUnionWnd();
		//class'UIDATA_CLAN'.static.RequestUnionInfo();
		//RequestClanWithdrawWar();
		
	}
	//가입권유
	else if( strID == "ClanAskJoinBtn" )
	{
		AskJoin();
	}
	//권한편집
	else if( strID == "ClanAuthEditBtn" )
	{
		if(m_currentactivestatus6 == false)
		{
			ResetOpeningVariables();
			m_currentactivestatus6 = true;
			RequestClanGradeList();
			ClanDrawerWndClassicScript.SetStateAndShow("ClanAuthManageWndState");
		} else {
		m_currentactivestatus6 = false;
		ClanDrawerWndClassicScript.HideClanWindow();
		}
	}
	//문장관리
	else if( strID == "ClanTitleManageBtn" )
	{
		if(m_currentactivestatus7 == false)
		{
			ResetOpeningVariables();
			m_currentactivestatus7 = true;
			ClanDrawerWndClassicScript.SetStateAndShow("ClanEmblemManageWndState");
		} else {
		m_currentactivestatus7 = false;
		ClanDrawerWndClassicScript.HideClanWindow();
		}
	} 
	else if( strID == "HeroBtn" )
	{
		if(m_currentactivestatus8 == false)
		{
			m_currentactivestatus8 = true;
			ClanDrawerWndClassicScript.SetStateAndShow("ClanHeroWndState");
		} else {
			m_currentactivestatus8 = false;
			ClanDrawerWndClassicScript.HideClanWindow();
		}
	}

	// 2015-08-24 신규 해외 추가 혈맹 보상 UI 개선 관련.
	else if( strID == "PledgeBonusWnd_Btn" )
	{
		// toggleWindow("ClanPledgeBonusDrawerWnd");	
		if (IsShowWindow(m_ClanPledgeBonusDrawerWndName)) GetWindowHandle(m_ClanPledgeBonusDrawerWndName).HideWindow();
		else PledgeBonusOpen();	
	}
	else if( strID == "PledgePCOnline_Btn" || strID == "PledgePCOffline_Btn")
	{
		if(isOnlyOnline())
		{
			GetButtonHandle(m_WindowName $ ".PledgePCOnline_Btn").HideWindow();
			GetButtonHandle(m_WindowName $ ".PledgePCOffline_Btn").ShowWindow();
			bShowOnlyOnlineUser = false;
		}
		else 
		{
			GetButtonHandle(m_WindowName $ ".PledgePCOnline_Btn").ShowWindow();
			GetButtonHandle(m_WindowName $ ".PledgePCOffline_Btn").HideWindow();
			bShowOnlyOnlineUser = true;
		}

		//ShowList(m_myClanType);
		ShowList(class'UIAPI_COMBOBOX'.static.GetReserved(m_WindowName $ ".ComboboxMainClanWnd", class'UIAPI_COMBOBOX'.static.GetSelectedNum(m_WindowName $ ".ComboboxMainClanWnd")));

	}
}

// 인라인 유저만 보여주는가?
function bool isOnlyOnline()
{
	return GetButtonHandle(m_WindowName $ ".PledgePCOnline_Btn").IsShowWindow();
}


function isWorldRaidServer()
{
	if(IsPlayerOnWorldRaidServer() == true)
	{
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanMemInfoBtn");
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanMemAuthBtn");
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanBoardBtn");
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanInfoBtn");
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanPenaltyBtn");
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanQuitBtn");
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanWarInfoBtn");
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanWarDeclareBtn");
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanUnionBtn");
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanAskJoinBtn");
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanAuthEditBtn");
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanTitleManageBtn");
	}
}

function OnEvent( int a_EventID, String a_Param )
{
	// debug("------");
	// debug("a_EventID" @ a_EventID);
	// debug("a_Param" @ a_Param);
	
	//local int unionType;
	//ParseInt( a_Param, "unionType", unionType );
	if (getInstanceL2Util().isClanV2()) return;
		
	switch( a_EventID )
	{	
	//case EV_SendIsActiveUnionInfoBtn:  //  조합가입 여부
	//		m_unionType = unionType;
		//unionButtonShowHide(unionType);
	//	break;

	case EV_ClanDeleteAllMember:	// Enter world 할때 지워 버려야함
		Clear();
		break;
	case EV_GamingStateExit:		// Clear
		Clear();
		break;
	case EV_ClanInfo:
		HandleClanInfo( a_Param );
		break;
	case EV_ClanAddMemberMultiple:
		HandleAddClanMemberMultiple( a_Param );
		break;
	case EV_ClanMemberInfoUpdate:
		HandleMemberInfoUpdate( a_Param );
		break;
	case EV_ClanAddMember:
		HandleAddClanMember( a_Param );
		break;
	case EV_ClanDeleteMember:
		HandleDeleteMember( a_Param );
		break;
	case EV_ClanInfoUpdate:
		HandleClanInfoUpdate( a_Param );
		break;
	case EV_ClanSubClanUpdated:
		HandleSubClanUpdated( a_Param );
		break;
	case EV_ClanMyAuth:
		HandleClanMyAuth( a_Param );
		break;
	/*case EV_ResultJoinDominionWar:
		HandleEV_ResultJoinDominionWar();
		break;*/
	case EV_RequestStartPledgeWar:
		HandleEV_RequestStartPledgeWar(a_Param);
		break;

	case EV_PledgeBonusMarkReset:
		// 클래식 인 경우만..
		if(getInstanceUIData().getIsClassicServer())
		{
			Debug("초기화 됨. EV_PledgeBonusMarkReset");
			ClearList();
			deleteAllBActive();
			ShowList(class'UIAPI_COMBOBOX'.static.GetReserved(m_WindowName $ ".ComboboxMainClanWnd", class'UIAPI_COMBOBOX'.static.GetSelectedNum(m_WindowName $ ".ComboboxMainClanWnd")));
		}
		break;

	case EV_DialogOK:
		HandleDialogOK();
		break;
	default:
		break;
	}
}

// 혈맹 보상 출석에서 출석 표기 삭제
function deleteAllBActive()
{
	local int n, i;

	for(i = 0; i < m_memberList.Length; i++)
	{
		for(n = 0; n < m_memberList[i].m_array.Length; n++)
		{
			m_memberList[i].m_array[n].bActive = 0;
		}
	}
}

function OnComboBoxItemSelected( string sName, int index )
{
	ClearList();
	//debug("information:" @ class'UIAPI_COMBOBOX'.static.GetReserved(m_WindowName $ ".ComboboxMainClanWnd", class'UIAPI_COMBOBOX'.static.GetSelectedNum(m_WindowName $ ".ComboboxMainClanWnd")) @ class'UIAPI_COMBOBOX'.static.GetSelectedNum(m_WindowName $ ".ComboboxMainClanWnd"));
	ShowList(class'UIAPI_COMBOBOX'.static.GetReserved(m_WindowName $ ".ComboboxMainClanWnd", class'UIAPI_COMBOBOX'.static.GetSelectedNum(m_WindowName $ ".ComboboxMainClanWnd")));
	//if( index == m_indexNumKH)
	//{
	//	class'UIAPI_LISTCTRL'.static.SetSelectedIndex( m_WindowName $ ".ClanMemberList", m_indexNum ,true);
	//}	
}


//{
//	debug("OnComboBoxItemSelected" $ index);
//	
//	ClearList();
//
//	if( index == 0 )
//		ShowList(CLAN_MAIN);
//	else if(index == 1)
//		//ShowList(CLAN_ACADEMY);
//		ShowList(CLAN_KNIGHT1);
//	else if(index == 2)
//		ShowList(CLAN_KNIGHT2);
//	else if(index == 3)
//		ShowList(CLAN_KNIGHT3);
//	else if(index == 4)
//		ShowList(CLAN_KNIGHT4);
//	else if(index == 5)
//		ShowList(CLAN_KNIGHT5);
//	else if(index == 6)
//		ShowList(CLAN_KNIGHT6);
//	else if(index == 7)
//		ShowList(CLAN_ACADEMY);
//}


function OnClickListCtrlRecord( string ListCtrlID)
{	
	local LVDataRecord record;

	record.LVDataList.Length = 10;

	//클릭시 혈원 정보창이 열려 있으면 클릭된 내용으로 데이터 갱신 
	if (ListCtrlID == "ClanMemberList")
	{
		if ( m_currentactivestatus1 == true)
		{
			ResetOpeningVariables();
			m_currentactivestatus1 = true;
			if( GetSelectedListCtrlItem( record ) )
			{
				RequestClanMemberInfo( int(record.nReserved1), record.LVDataList[0].szData );
				G_CurrentRecord = int(record.nReserved1);
				G_CurrentSzData = record.LVDataList[0].szData;
				if (record.LVDataList[3].szData == "0")
				{
					G_CurrentAlias = true;
				} 
				else
				{
					G_CurrentAlias = false;
				}
				ClanDrawerWndClassicScript.SetStateAndShow("ClanMemberInfoState");
			}
		} 
		//클릭시 혈원 권한창이 열려 있으면 클릭된 내용으로 데이터 갱신 
		if ( m_currentactivestatus2 == true)
		{
			ResetOpeningVariables();
			m_currentactivestatus2 = true;
			if( GetSelectedListCtrlItem( record ) )
			{
				RequestClanMemberAuth( int(record.nReserved1), record.LVDataList[0].szData );
				ClanDrawerWndClassicScript.SetStateAndShow("ClanMemberAuthState");
			}
		} 
	}
}

function OnDBClickListCtrlRecord( string ListCtrlID){
	
	local LVDataRecord record;

	record.LVDataList.Length = 10;
	
	// 리스트를 더블 클릭 하면 혈맹 정보창으로 무조건 포커스를 전환한다. 
	if (ListCtrlID == "ClanMemberList")
	{
		if( m_currentactivestatus1 == false)
		{
			ResetOpeningVariables();
			m_currentactivestatus1 = true;
			if( GetSelectedListCtrlItem( record ) )
			{
				RequestClanMemberInfo( int(record.nReserved1), record.LVDataList[0].szData );
				G_CurrentRecord = int(record.nReserved1);
				G_CurrentSzData = record.LVDataList[0].szData;
				
				if (record.LVDataList[3].szData == "0")
				{
					G_CurrentAlias = true;
				} 
				else
				{
					G_CurrentAlias = false;
				}
				
				ClanDrawerWndClassicScript.SetStateAndShow("ClanMemberInfoState");
			}
		} 
		else 
		{
			ResetOpeningVariables();
			m_currentactivestatus1 = true;
			if( GetSelectedListCtrlItem( record ) )
			{
				RequestClanMemberInfo( int(record.nReserved1), record.LVDataList[0].szData );
				G_CurrentRecord = int(record.nReserved1);
				G_CurrentSzData = record.LVDataList[0].szData;

				
				ClanDrawerWndClassicScript.SetStateAndShow("ClanMemberInfoState");
			}
		}
	}
}
/*
//  혈맹조합 버튼 숨김 여부
function unionButtonShowHide(int unionType)
{	
	if(unionType == 0)
	{
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanUnionBtn");
	}
	else
	{
		class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanUnionBtn");
	}

	if(IsPlayerOnWorldRaidServer() == true)
	{
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanUnionBtn");
	}
}
*/

//coded by oxyzen reset btn on authority.
function resetBtnShowHide()
{	
	//debug("resetbtn running");
	NoblessMenuValidate();

	IsNoblessToChangeMemberNameBtnEnabled();
	//unionButtonShowHide(m_unionType);
	
	//혈맹 가입게시판 버튼으로 변경 되고 항상 표시 되도록 수정됨 13-04-10 정우균
	class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanUnionBtn");	
	
	//혈맹 미가입자
	if(m_clanID == 0)
	{
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanMemInfoBtn");
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanMemAuthBtn");
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanBoardBtn");
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanInfoBtn");
		//class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanPenaltyBtn");
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanQuitBtn");
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanWarInfoBtn");
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanWarDeclareBtn");
		//class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanUnionBtn");
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanAskJoinBtn");
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanAuthEditBtn");
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanTitleManageBtn");
	}                                                                    
	else 
	{
		// 혈맹레벨 5 이상
		if (m_clanLevel>5)
		{
			class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanMemInfoBtn");
			class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanMemAuthBtn");
			class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanBoardBtn");
			class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanInfoBtn");
			class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanPenaltyBtn");
			class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanQuitBtn");
			class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanWarInfoBtn");
			class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanWarDeclareBtn");
//			class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanUnionBtn");
			class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanAskJoinBtn");
			class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanAuthEditBtn");
			class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanTitleManageBtn");
			class'UIAPI_WINDOW'.static.EnableWindow( m_DrawerWindowName$".Clan1_ChangeMemberNameBtn");
			class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_ChangeBanishBtn");
			class'UIAPI_WINDOW'.static.EnableWindow( m_DrawerWindowName$".Clan1_ChangeMemberGradeBtn");
			//classic// class'UIAPI_WINDOW'.static.EnableWindow( m_DrawerWindowName$".Clan1_AssignApprenticeBtn");
			//classic// class'UIAPI_WINDOW'.static.EnableWindow( m_DrawerWindowName$".Clan1_DeleteApprenticeBtn");
		}
		else
		{
			switch(m_clanLevel) 
			{
				//혈맹레벨 0 
				case 0:
					//혈원정보
					//혈원권한
					//혈맹정보
					//페널티
					//가입권유
					//권한편집
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanMemInfoBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanMemAuthBtn");
					class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanBoardBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanInfoBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanPenaltyBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanQuitBtn");
					class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanWarInfoBtn");
					class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanWarDeclareBtn");
					//class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanUnionBtn");

					//class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanUnionBtn");
					
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanAskJoinBtn");
					class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanAuthEditBtn");
					class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanTitleManageBtn");
					//class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_AskJoinPartyBtn");

					//class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_ChangeMemberNameBtn");
					class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_ChangeBanishBtn");
					class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_ChangeMemberGradeBtn");
					//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_AssignApprenticeBtn");
						//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_DeleteApprenticeBtn");
				break;
				
				case 1:
					//혈원정보
					//혈원권한
					//혈맹정보
					//페널티
					//가입권유
					//권한편집
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanMemInfoBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanMemAuthBtn");
					class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanBoardBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanInfoBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanPenaltyBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanQuitBtn");
					class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanWarInfoBtn");
					class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanWarDeclareBtn");
					//class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanUnionBtn");
					
					//class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanUnionBtn");

					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanAskJoinBtn");
					class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanAuthEditBtn");
					class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanTitleManageBtn");
					//class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_AskJoinPartyBtn");
					
					
					//class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_ChangeMemberNameBtn");
					class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_ChangeBanishBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_DrawerWindowName$".Clan1_ChangeMemberGradeBtn");
					//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_AssignApprenticeBtn");
						//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_DeleteApprenticeBtn");
				break;
				
				case 2:
					//혈원정보
					//혈원권한
					//혈맹정보
					//페널티
					//가입권유
					//권한편집
					//혈맹게시판
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanMemInfoBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanMemAuthBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanBoardBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanInfoBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanPenaltyBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanQuitBtn");
					class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanWarInfoBtn");
					class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanWarDeclareBtn");
					//class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanUnionBtn");
					
					//class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanUnionBtn");

					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanAskJoinBtn");
					class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanAuthEditBtn");
					class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanTitleManageBtn");					
					//class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_AskJoinPartyBtn");
					
					
					//class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_ChangeMemberNameBtn");
					class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_ChangeBanishBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_DrawerWindowName$".Clan1_ChangeMemberGradeBtn");
					//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_AssignApprenticeBtn");
					//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_DeleteApprenticeBtn");
				break;
				
				case 3:
					//혈원정보(호칭변경)
					//혈원권한
					//혈맹정보
					//페널티
					//가입권유
					//권한편집
					//혈맹게시판
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanMemInfoBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanMemAuthBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanBoardBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanInfoBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanPenaltyBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanQuitBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanWarInfoBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanWarDeclareBtn");
					//class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanUnionBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanAskJoinBtn");
					class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanAuthEditBtn");
					class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanTitleManageBtn");					
					//class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_AskJoinPartyBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_DrawerWindowName$".Clan1_ChangeMemberNameBtn");
					class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_ChangeBanishBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_DrawerWindowName$".Clan1_ChangeMemberGradeBtn");
					//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_AssignApprenticeBtn");
					//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_DeleteApprenticeBtn");
				break;
				
				case 4:
					//혈원정보
					//혈원권한
					//혈맹정보
					//페널티
					//가입권유
					//권한편집
					//혈맹게시판
					//전쟁정보
					//전쟁선포
					//전쟁철회
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanMemInfoBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanMemAuthBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanBoardBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanInfoBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanPenaltyBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanQuitBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanWarInfoBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanWarDeclareBtn");
					//class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanUnionBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanAskJoinBtn");
					class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanAuthEditBtn");
					class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanTitleManageBtn");
					//class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_AskJoinPartyBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_DrawerWindowName$".Clan1_ChangeMemberNameBtn");
					class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_ChangeBanishBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_DrawerWindowName$".Clan1_ChangeMemberGradeBtn");
					//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_AssignApprenticeBtn");
					//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_DeleteApprenticeBtn");
				break;
				
				case 5:
					//혈원정보(수제자 선임, 수제자 제명);
					//혈원권한
					//혈맹정보
					//페널티
					//가입권유
					//권한편집
					//혈맹게시판
					//전쟁정보
					//전쟁선포
					//전쟁철회
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanMemInfoBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanMemAuthBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanBoardBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanInfoBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanPenaltyBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanQuitBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanWarInfoBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanWarDeclareBtn");
					//class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanUnionBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanAskJoinBtn");
					class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanAuthEditBtn");
					class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanTitleManageBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_DrawerWindowName$".Clan1_ChangeMemberNameBtn");
					class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_ChangeBanishBtn");
					class'UIAPI_WINDOW'.static.EnableWindow(m_DrawerWindowName$".Clan1_ChangeMemberGradeBtn");
					//classic// class'UIAPI_WINDOW'.static.EnableWindow(m_DrawerWindowName$".Clan1_AssignApprenticeBtn");
					//classic// class'UIAPI_WINDOW'.static.EnableWindow(m_DrawerWindowName$".Clan1_DeleteApprenticeBtn");
				break;
				
			}
	
		}
		
		if(m_bClanMaster>0)
		{
			class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanQuitBtn");		// 혈맹주는 탈퇴가 안됨
			if (m_clanLevel > 2)
			{
				class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanTitleManageBtn");
			}
			class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanAuthEditBtn"); //혈맹주만 편집 가능함.
			
		}
		else
		{
			class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_ChangeMemberNameBtn");
			class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_ChangeBanishBtn");
			class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_ChangeMemberGradeBtn");
			//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_AssignApprenticeBtn");
			//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_DeleteApprenticeBtn");
			
			if( m_bJoin == 0)
				class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanAskJoinBtn");
			if(m_bCrest == 0 )
			{
				class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanTitleManageBtn");
			} 
			else
			{
				if (m_clanLevel > 2)
				{
					class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".ClanTitleManageBtn");
				}
			}
			if(m_bWar == 0 )
			{
				class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanWarDeclareBtn");
				//class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanUnionBtn");
			}
			//if(m_bGrade == 0)
				//class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".ClanAuthEditBtn");
		}
		//script.OnShow();
		ClanDrawerWndClassicScript.CheckandCompareMyNameandDisableThings();
		//script.m_myName
	}
	isWorldRaidServer();

	NoblessMenuValidate();
}

function IsNoblessToChangeMemberNameBtnEnabled()
{
	if (G_IamHero == true || G_IamNobless > 0)
	{
		class'UIAPI_WINDOW'.static.EnableWindow(m_DrawerWindowName$".Clan1_ChangeMemberNameBtn");
	}
	else
	{
		class'UIAPI_WINDOW'.static.DisableWindow(m_DrawerWindowName$".Clan1_ChangeMemberNameBtn");
	}
}

function Clear()		// clear this Script
{	
	local int i;

	ClearList();

	ClanDrawerWndClassicScript = ClanDrawerWndClassic( GetScript( m_DrawerWindowName ));

	ClanDrawerWndClassicScript.Clear();
	
	class'UIAPI_WINDOW'.static.HideWindow( m_DrawerWindowName );	
	class'UIAPI_WINDOW'.static.HideWindow("InviteClanPopWndClassic");

	class'UIAPI_TEXTBOX'.static.SetText( m_WindowName $ ".ClanNameText", "" );
	class'UIAPI_TEXTBOX'.static.SetText( m_WindowName $ ".ClanMasterNameText", "");
	class'UIAPI_TEXTBOX'.static.SetText( m_WindowName $ ".ClanAgitText", GetSystemString( 27 ) );	// 없음
	class'UIAPI_TEXTBOX'.static.SetText( m_WindowName $ ".ClanStatusText", "");
	class'UIAPI_TEXTBOX'.static.SetInt( m_WindowName $ ".ClanLevelText", 0);

	class'UIAPI_COMBOBOX'.static.Clear(m_WindowName $ ".ComboboxMainClanWnd");
	m_clanID = 0;
	m_clanName = "";
	m_clanRank = 0;
	m_clanLevel = 0;
	m_clanNameValue = 0;
	m_bMoreInfo = 0;
	m_currentShowIndex = 0;

	m_bClanMaster = 0;
	m_bJoin = 0;
	m_bNickName = 0;
	m_bCrest = 0;
	m_bWar = 0;
	m_bGrade = 0;
	m_bManageMaster = 0;
	m_bOustMember = 0;

	for( i=0; i < CLAN_KNIGHTHOOD_COUNT ; ++i )
	{
		m_memberList[ i ].m_array.Remove(0, m_memberList[ i ].m_array.Length);
		m_memberList[ i ].m_sName = "";
		m_memberList[ i ].m_sMasterName = "";
	}
}


/*function HandleEV_ResultJoinDominionWar()
{
	class'UIDATA_CLAN'.static.RequestClanInfo();
}*/

/** 혈맹 전 선포 하기 */
function HandleEV_RequestStartPledgeWar(string param)
{	
	parseString( param, "PledgeName", withWarPledgeNameStr );

	//----
	// 현재 전쟁 피선포를 한 곳이 있는지 미리 받아 오기 위해서..
	ResetOpeningVariables();
	// m_currentactivestatus5 = true;
	ClanDrawerWndClassicScript.m_clanWarListPage = -1;
	RequestClanWarList(0, 0);	
	m_currentactivestatus5 = false;
	ClanDrawerWndClassicScript.HideClanWindow();
	//----

	pledgeDelayTimerCount = 0;
	Me.KillTimer( TIMER_ID );
	Me.SetTimer(TIMER_ID, TIMER_DELAY);


	
}
function OnTimer(int TimerID)
{
	if (pledgeDelayTimerCount > 0)
	{
		if(TimerID == TIMER_ID)
		{
			Me.KillTimer( TIMER_ID );
			
			DialogSetID( DIALOG_AskPledgeWar );
			// DialogSetDefaultOK();
			if (ClanDrawerWndClassicScript.searchClanWarDeclare(withWarPledgeNameStr))
			{
				// 다른 한쪽이 이미 전쟁 선포 한 상태인 경우, 3일 후가 아니라 바로 전쟁 선포 한다는 메세지.. 
				DialogShow(DialogModalType_Modalless, DialogType_OKCancel, MakeFullSystemMsg( GetSystemMessage(3524), withWarPledgeNameStr), string(Self) );
			}
			else 
			{
				// xxx 혈맹과의 혈맹전쟁을 시작합니다. 3일 후에 혈맹전쟁이 시작됩니다. 전쟁을 선포하시겠습니까?
				DialogShow(DialogModalType_Modalless, DialogType_OKCancel, MakeFullSystemMsg( GetSystemMessage(3306), withWarPledgeNameStr), string(Self) );
			}
		}
	}
	// Debug("pledgeDelayTimerCount " @ pledgeDelayTimerCount);
	pledgeDelayTimerCount++;
}



/** 다이얼로그 ok */
function HandleDialogOK ()
{
	
	local int dialogID;
	
		
	if (DialogIsMine())
	{
		dialogID = DialogGetID();

		// 전쟁을 선포 확인! 전쟁을 시작한다
		if( dialogID == DIALOG_AskPledgeWar )
		{
						
			if (withWarPledgeNameStr != "") 
			{
				// Debug("실행하기!!! " @ withWarPledgeNameStr);				

				RequestPledgeWar(withWarPledgeNameStr);
			}

			withWarPledgeNameStr = "";
		}
	}
}

function HandleClanInfo( String a_Param )
{
	local string clanMasterName;
	local string clanName;
	local int crestID;
	local int skillLevel;
	local int castleID;
	local int agitType;
	local int agitID;
	local int fotressID;
	local int status;
	local int bGuilty;
	local int allianceID;
	local string allianceName;
	local int allianceCrestID;
	local int bInWar;
	local int clanType;
	local int clanRank;
	local int clanNameValue;
	local int clanID;
	//local int JoinDominionWarID;

	//parseInt( a_Param, "JoinDominionWarID", JoinDominionWarID );
	
	//debug ("a_Param" @ a_Param);
	/*
	if (JoinDominionWarID == 0)
	{
		// 영지전 미참전 상태
		//~ Debug ("ClanInfoInsertion");
		//~ TxtDominion.SetText(GetSystemString(1989));	//영지전 
		//~ txtDominionWarStatus.SetText(GetSystemMessage(2917));	//영지전 미참전 상태

		//TxtDominion.SetText("없음");	//영지전 
		//txtDominionWarStatus.SetText("영지전 미참전 상태");	//영지전 미참전 상태
		//txtDominion.SetText(GetSystemString(1989));	//영지전 
		//txtDominionWarStatus.SetText(GetSystemMessage(2917));	//영지전 미참전 상태

	}
	else 
	{
		// 영지전 참전 상태
		//~ Debug ("ClanInfoInsertion2");
		//~ TxtDominion.SetText(GetSystemString(1989));	//영지전 
		//~ txtDominionWarStatus.SetText(MakeFullSystemMsg(GetSystemMessage(2917), GetCastleName(JoinDominionWarID),"")); // 어디어디 영지전 참전 상태
		// TxtDominion.SetText(GetCastleName(JoinDominionWarID));	//영지전 
		//txtDominionWarStatus.SetText("영지전 참전 상태");	//영지전 미참전 상태
		//TxtDominion.SetText(GetSystemString(1989));	//영지전 
		//~ txtDominionWarStatus.SetText(MakeFullSystemMsg(GetSystemMessage(2917), GetCastleName(JoinDominionWarID),"")); // 어디어디 영지전 참전 상태

		//TxtDominion.SetText(GetCastleName(JoinDominionWarID));	//영지전 
		//txtDominionWarStatus.SetText(GetSystemMessage(2916));
		//txtDominionWarStatus.SetText(MakeFullSystemMsg(GetSystemMessage(2916), GetCastleName(JoinDominionWarID),"")); // 어디어디 영지전 참전 상태
	}
*/
	
	
	
	
	
	
	
	ParseInt( a_Param, "ClanID", clanID );
	ParseInt( a_Param, "ClanType", clanType );
	m_CurrentNHType = clanType;
	ParseString( a_Param, "ClanName", clanName );
	ParseString( a_Param, "ClanMasterName", clanMasterName );
	m_CurrentclanMasterName = clanMasterName;
	if( clanType == CLAN_MAIN )
		m_CurrentclanMasterReal = clanMasterName;
	ParseInt( a_Param, "CrestID", crestID );
	ParseInt( a_Param, "SkillLevel", skillLevel );
	ParseInt( a_Param, "CastleID", castleID );
	ParseInt( a_Param, "AgitType", agitType );
	ParseInt( a_Param, "AgitID", agitID );
	ParseInt( a_Param, "FortressID", fotressID );
	ParseInt( a_Param, "ClanRank", clanRank );
	ParseInt( a_Param, "ClanNameValue", clanNameValue );
	ParseInt( a_Param, "Status", status );
	ParseInt( a_Param, "Guilty", bGuilty );
	ParseInt( a_Param, "AllianceID", allianceID );
	ParseString( a_Param, "AllianceName", allianceName );
	ParseInt( a_Param, "AllianceCrestID", allianceCrestID );
	ParseInt( a_Param, "InWar", bInWar );

	//debug("fotressID : " $ Right(a_Param, 175));

	if( clanType == CLAN_MAIN )
	{
		m_clanName = clanName;
		m_clanRank = clanRank;
		m_clanNameValue = clanNameValue;
		m_clanLevel = skillLevel;
		m_clanID = clanID;
	}

	m_memberList[ GetIndexFromType( clanType ) ].m_sName = clanName;
	m_memberList[ GetIndexFromType( clanType ) ].m_sMasterName = clanMasterName;

	//debug( "ClanWnd::HandleClanInfo name " $ clanName $ ", master " $ clanMasterName $ " type " $ clanType );
	//debug("fotressID : " $ fotressID);
	if( clanType == CLAN_MAIN )
	{
		class'UIAPI_TEXTBOX'.static.SetText( m_WindowName $ ".ClanNameText", clanName );
		class'UIAPI_TEXTBOX'.static.SetText( m_WindowName $ ".ClanMasterNameText", m_CurrentclanMasterReal );
		if( agitID > 0 )
		{
			if( agitType == 0 )
				class'UIAPI_TEXTBOX'.static.SetText( m_WindowName $ ".ClanAgitText", GetCastleName( agitID ) );	// 아지트
			else if( agitType == 1 )
				class'UIAPI_TEXTBOX'.static.SetText( m_WindowName $ ".ClanAgitText", GetInZoneNameWithZoneID( agitID ) );	// 인존 아지트
		}
		else if( castleID > 0 )
			class'UIAPI_TEXTBOX'.static.SetText( m_WindowName $ ".ClanAgitText", GetCastleName( castleID ) );	// 성
		else if( fotressID > 0)
		{
			//debug("fotressName : " $ GetCastleName( fotressID ));
			class'UIAPI_TEXTBOX'.static.SetText( m_WindowName $ ".ClanAgitText", GetCastleName( fotressID ) );	// 요새
		}
		else
			class'UIAPI_TEXTBOX'.static.SetText( m_WindowName $ ".ClanAgitText", GetSystemString( 27 ) );	// 없음

		if( status == 3 )
			class'UIAPI_TEXTBOX'.static.SetText( m_WindowName $ ".ClanStatusText", GetSystemString(341));
		else if( bInWar == 0 )
			class'UIAPI_TEXTBOX'.static.SetText( m_WindowName $ ".ClanStatusText", GetSystemString(894));
		else
			class'UIAPI_TEXTBOX'.static.SetText( m_WindowName $ ".ClanStatusText", GetSystemString(340));

		class'UIAPI_TEXTBOX'.static.SetInt( m_WindowName $ ".ClanLevelText", skillLevel );
	}
	
	//~ if (JoinDominionWarID != 0)
	//~ {
		//~ txtDominionWarTitle.SetText("영지전");
		//~ txtDominionWarStatus.SetText("영지전 미참전 상태");
	//~ }
	//~ else 
	//~ {
		//~ txtDominionWarTitle.SetText("영지전");
		//~ txtDominionWarStatus.SetText( GetCastleName(JoinDominionWarID)$"영지 참전 상태");
	//~ }
	
	RefreshComboBox();
	getmyClanInfo();
	
}

function HandleClanInfoUpdate( String a_Param )
{
	local int PledgeCrestID;
	local int CastleID;
	local int AgitType;
	local int AgitID;
	local int fotressID;
	local int Status;
	local int bGuilty;
	local int AllianceId;
	local string sAllianceName;
	local int AllianceCrestId;
	local int InWar;
	local int LargePledgeCrestID;	

	/*
	local int JoinDominionWarID;
	parseInt( a_Param, "JoinDominionWarID", JoinDominionWarID );
	
	if (JoinDominionWarID == 0)
	{
		//~ Debug ("ClanInfoInsertion");
		//~ TxtDominion.SetText(GetSystemString(1989));	//영지전 
		//~ txtDominionWarStatus.SetText(GetSystemMessage(2917));	//영지전 미참전 상태
		// TxtDominion.SetText("없음");	//영지전 
		// txtDominionWarStatus.SetText("영지전 미참전 상태");	//영지전 미참전 상태

		//TxtDominion.SetText(GetSystemString(1989));	//영지전 
		//txtDominionWarStatus.SetText(GetSystemMessage(2917));	//영지전 미참전 상태

	}
	else 
	{
		//~ Debug ("ClanInfoInsertion2");
		//TxtDominion.SetText(GetCastleName(JoinDominionWarID));	//영지전 
		//txtDominionWarStatus.SetText(GetSystemMessage(2916));
		//txtDominionWarStatus.SetText(MakeFullSystemMsg(GetSystemMessage(2916), GetCastleName(JoinDominionWarID),"")); // 어디어디 영지전 참전 상태
		// TxtDominion.SetText(GetCastleName(JoinDominionWarID));	//영지전 
		// txtDominionWarStatus.SetText("영지전 참전 상태");	//영지전 미참전 상태
	}
*/
	
	ParseInt( a_Param, "ClanID", m_clanID );
	ParseInt( a_Param, "CrestID", PledgeCrestID );
	ParseInt( a_Param, "SkillLevel", m_clanLevel );
	ParseInt( a_Param, "CastleID", CastleID );
	ParseInt( a_Param, "AgitType", AgitType );
	ParseInt( a_Param, "AgitID", AgitID );
	ParseInt( a_Param, "FortressID", fotressID );
	ParseInt( a_Param, "ClanRank", m_clanRank );
	ParseInt( a_Param, "ClanNameValue", m_clanNameValue );
	ParseInt( a_Param, "Status", Status );
	ParseInt( a_Param, "Guilty", bGuilty );
	ParseInt( a_Param, "AllianceID", AllianceId );
	ParseString( a_Param, "AllianceName", sAllianceName );
	ParseInt( a_Param, "AllianceCrestID", AllianceCrestId );
	ParseInt( a_Param, "InWar", InWar );
	ParseInt( a_Param, "LargeCrestID", LargePledgeCrestID );

	if( class'UIAPI_WINDOW'.static.IsShowWindow(m_DrawerWindowName$".ClanInfoWnd") )			// 혈맹 정보 창이 보여지고 있다면 업데이트 해준다.
	{		
		ClanDrawerWndClassicScript.InitializeClanInfoWnd();
	}

	//debug( "ClanWnd::HandleClanInfoUpdate" );
	if( AgitID > 0 )
	{
		if( AgitType == 0 )
			class'UIAPI_TEXTBOX'.static.SetText( m_WindowName $ ".ClanAgitText", GetCastleName( AgitID ) );	// 아지트
		else if( AgitType == 1 )
			class'UIAPI_TEXTBOX'.static.SetText( m_WindowName $ ".ClanAgitText", GetInZoneNameWithZoneID( AgitID ) );	// 인존 아지트
	}
	else if( CastleID > 0 )
		class'UIAPI_TEXTBOX'.static.SetText( m_WindowName $ ".ClanAgitText", GetCastleName( CastleID ) );	// 성
	else if( fotressID > 0)
		{
			//debug("fotressName : " $ GetCastleName( fotressID ));
			class'UIAPI_TEXTBOX'.static.SetText( m_WindowName $ ".ClanAgitText", GetCastleName( fotressID ) );	// 요새
		}
	else
		class'UIAPI_TEXTBOX'.static.SetText( m_WindowName $ ".ClanAgitText", GetSystemString( 27 ) );	// 없음

	if( Status == 3 )
		class'UIAPI_TEXTBOX'.static.SetText( m_WindowName $ ".ClanStatusText", GetSystemString(341));
	else if( InWar == 0 )
		class'UIAPI_TEXTBOX'.static.SetText( m_WindowName $ ".ClanStatusText", GetSystemString(894));
	else
		class'UIAPI_TEXTBOX'.static.SetText( m_WindowName $ ".ClanStatusText", GetSystemString(340));

	class'UIAPI_TEXTBOX'.static.SetInt( m_WindowName $ ".ClanLevelText", m_clanLevel );
	

	resetBtnShowHide();
	
	getmyClanInfo();
}

function HandleAddClanMemberMultiple( String a_Param )
{
	local ClanMemberInfo info;
	local int count;
	local int index;

	ParseInt( a_Param, "ClanType", info.clanType );
	index = GetIndexFromType( info.clanType );
	ParseString( a_Param, "Name", info.sName );
	ParseInt( a_Param, "Level", info.level );
	ParseInt( a_Param, "Class", info.classID );
	ParseInt( a_Param, "Gender", info.gender );
	ParseInt( a_Param, "Race", info.race );
	ParseInt( a_Param, "ID", info.id );
	ParseInt( a_Param, "HaveMaster", info.bHaveMaster );

	// 해외만 버전 추가 
	if(IsUsePledgeBonus()) ParseInt( a_Param, "MemberActive", info.bActive  );

	Debug("HandleAddClanMemberMultiple:::::::::::" @ a_Param);

	//debug("HandleAddClanMemberMultiple type " $ info.clanType $ " name " $ info.sName $ ", class " $ info.classID $ ", gender " $ info.gender $ ", race " $ info.race $ ", ID " $ info.id $ ", haveMaster " $ info.bHaveMaster $ " index " $ index);

	count = m_memberList[ index ].m_array.Length;
	
	m_memberList[ index ].m_array.Length = count + 1;

	m_memberList[ index ].m_array[ count ] = info;

	if( index == m_currentShowIndex )
		ShowList( info.clanType );									// renew list
}


// ListCtrl related operations
function ClearList()
{
	class'UIAPI_LISTCTRL'.static.DeleteAllItem( m_WindowName $ ".ClanMemberList" );
}

function ShowList( int clanType )
{
	local int index;

	index = GetIndexFromType( clanType );

	m_currentShowIndex = index;
	ClearList();
	AddToList( index );
}

function int getClanKnighthoodMasterInfo(string NameVal)
{
	local int i;
	local int ReturnVal;
	
	for (i = 0; i <m_memberList[0].m_array.Length; ++i )
	{
		if (m_memberList[0].m_array[i].sName == NameVal)
		{
			ReturnVal = i;
		}
	}
	return ReturnVal;
}

function AddToList( int idx )
{
	local Color White;
	local Color Yellow;
	local Color Blue;
	local Color BrightWhite;
	local Color Gold;
	local int i;
	local int OnLineNum;
	local LVDataRecord record;
	
	BrightWhite.R = 255;
	BrightWhite.G = 255;
	BrightWhite.B = 255;
	White.R = 170;
	White.G = 170;
	White.B = 170;
	Yellow.R = 235;
	Yellow.G = 205;
	Yellow.B = 0;
	Blue.R = 102;
	Blue.G = 150;
	Blue.B = 253;
	Gold.R = 176;
	Gold.G = 153;
	Gold.B  = 121;
	
	OnLineNum = 0;
	
	record.LVDataList.Length = 4;
	
	if (GetClanTypeFromIndex(m_currentShowIndex) <= CLAN_MAIN)
	{
	}
	else
	{
		if (m_memberList[m_currentShowIndex].m_sMasterName == "")
		{
			i = getClanKnighthoodMasterInfo(m_memberList[m_currentShowIndex].m_sMasterName);
			//debug ("ClanKnighthood MasterInfo" @ i);
			record.LVDataList[0].buseTextColor = True;
			record.LVDataList[0].szData = GetSystemString(1445);
			//record.LVDataList[0].szData = m_memberList[GetClanTypeFromIndex(m_currentShowIndex)].m_sMasterName;
			//debug ("Current Index" @ GetClanTypeFromIndex(m_currentShowIndex));
			//debug ("ClanKnighthood MasterInfoName" @ m_memberList[0].m_sMasterName);
			record.LVDataList[0].TextColor = Gold;
			record.LVDataList[1].szData = "";
			record.LVDataList[2].szData = "";
			
			class'UIAPI_LISTCTRL'.static.InsertRecord( m_WindowName $ ".ClanMemberList", record );
		}
		else
		{
			// 해외만 적용, 온라인 유저만 보여주는 거라면, continue
			if(IsUsePledgeBonus())
			{
				// 국내 것 그대로 둠.
				i = getClanKnighthoodMasterInfo(m_memberList[m_currentShowIndex].m_sMasterName);

				if (isOnlyOnline())
				{
					if (m_memberList[0].m_array[i].id <= 0) return;
				}

				//debug ("ClanKnighthood MasterInfo" @ i);
				record.LVDataList[0].buseTextColor = True;
				record.LVDataList[0].szData = m_memberList[m_currentShowIndex].m_sMasterName;
				//record.LVDataList[0].szData = m_memberList[GetClanTypeFromIndex(m_currentShowIndex)].m_sMasterName;
				//debug ("Current Index" @ GetClanTypeFromIndex(m_currentShowIndex));
				//debug ("ClanKnighthood MasterInfoName" @ m_memberList[0].m_sMasterName);

				if( m_memberList[0].m_array[i].bHaveMaster == 0)
				{
					record.LVDataList[0].TextColor = White;
				}
				else
				{
					record.LVDataList[0].TextColor = Yellow;
				}

				//record.LVDataList[0].TextColor = Gold;
				record.LVDataList[1].buseTextColor = True;
				//record.LVDataList[1].TextColor = White;

				// 해외
				// 자기 자신은 노랑
				if( m_memberList[0].m_array[i].sName == m_myName )
				{
					record.LVDataList[0].TextColor = Yellow;
					record.LVDataList[1].TextColor = Yellow;
				}
				else
				{
					// 기존에는 자기 자신을 밝게 표기 했으나. 스팀 혈맹 개선에서 부터는 로그인 된 유저는 밝게 아니면 일반으로 표기
					if( m_memberList[0].m_array[i].id > 0 )
					{
						record.LVDataList[0].TextColor = BrightWhite;
						record.LVDataList[1].TextColor = BrightWhite;
					}
					else
					{   
						record.LVDataList[0].TextColor = White;
						record.LVDataList[1].TextColor = White;
					}
				}

				record.LVDataList[1].szData = string(m_memberList[0].m_array[i].level);
				record.LVDataList[2].szData = string(m_memberList[0].m_array[i].classID);		// 쓸모 없는 데이터지만 소팅을 위해서 넣는다
				record.LVDataList[2].szTexture = GetClassRoleIconName(m_memberList[0].m_array[i].classID);
				record.LVDataList[2].HiddenStringForSorting = String (GetClassRoleType( m_memberList[0].m_array[i].classID)); 		
				
				record.LVDataList[2].nTextureWidth = 11;
				record.LVDataList[2].nTextureHeight = 11;
				
				record.LVDataList[3].nTextureWidth = 31;
				record.LVDataList[3].nTextureHeight = 11;
				record.nReserved1 = 0;	// for additional information
				
				//if( m_memberList[0].m_array[i].id > 0 )
				//{
				//	record.LVDataList[3].szData = "0";				// 쓸모 없는 데이터지만 소팅을 위해서 넣는다
				//	record.LVDataList[3].szTexture = "L2UI_CH3.BloodHoodWnd.BloodHood_Logon";
				//	OnLineNum = OnLineNum++;
				//}
				//else 
				//{
				//	record.LVDataList[3].szData = "0";
				//	record.LVDataList[3].szTexture = "L2UI_CH3.BloodHoodWnd.BloodHood_Logoff";
				//}

				// 온라인 유저 체크
				if( m_memberList[0].m_array[i].id > 0 ) OnLineNum = OnLineNum++;
					
				// 혈맹 활동 
				// 완료
				if(m_memberList[0].m_array[i].bActive == 1)
				{
					record.LVDataList[3].nTextureWidth = 16;
					record.LVDataList[3].nTextureHeight = 16;

					record.LVDataList[3].szData = "1";
					record.LVDataList[3].szTexture = "L2UI_CT1.PledgeBonusWnd.PledgeflagIcon";  // 깃발 표시
				}
				// 새로 들어온 맴버 
				else if(m_memberList[0].m_array[i].bActive == 2)
				{
					record.LVDataList[3].nTextureWidth = 26;
					record.LVDataList[3].nTextureHeight = 9;

					record.LVDataList[3].szData = "2";
					record.LVDataList[3].szTexture = "L2UI_CT1.pledgeBonusWnd.New";  // new 표시
				} 
				// 표시 안함.
				else
				{
					record.LVDataList[3].szData = "";
					record.LVDataList[3].szTexture = "";
				}

				class'UIAPI_LISTCTRL'.static.InsertRecord( m_WindowName $ ".ClanMemberList", record );
			}
			else
			{
				// 국내 것 그대로 둠.
				i = getClanKnighthoodMasterInfo(m_memberList[m_currentShowIndex].m_sMasterName);
				//debug ("ClanKnighthood MasterInfo" @ i);
				record.LVDataList[0].buseTextColor = True;
				record.LVDataList[0].szData = m_memberList[m_currentShowIndex].m_sMasterName;
				//record.LVDataList[0].szData = m_memberList[GetClanTypeFromIndex(m_currentShowIndex)].m_sMasterName;
				//debug ("Current Index" @ GetClanTypeFromIndex(m_currentShowIndex));
				//debug ("ClanKnighthood MasterInfoName" @ m_memberList[0].m_sMasterName);
				record.LVDataList[0].TextColor = Gold;
				record.LVDataList[1].buseTextColor = True;
				record.LVDataList[1].TextColor = White;

				record.LVDataList[1].szData = string(m_memberList[0].m_array[i].level);
				record.LVDataList[2].szData = string(m_memberList[0].m_array[i].classID);		// 쓸모 없는 데이터지만 소팅을 위해서 넣는다
				record.LVDataList[2].szTexture = GetClassRoleIconName(m_memberList[0].m_array[i].classID);
				record.LVDataList[2].HiddenStringForSorting = String (GetClassRoleType( m_memberList[0].m_array[i].classID)); 		
				
				record.LVDataList[2].nTextureWidth = 11;
				record.LVDataList[2].nTextureHeight = 11;
				
				record.LVDataList[3].nTextureWidth = 31;
				record.LVDataList[3].nTextureHeight = 11;
				record.nReserved1 = 0;	// for additional information
				
				if( m_memberList[0].m_array[i].id > 0 )
				{
					record.LVDataList[3].szData = "0";				// 쓸모 없는 데이터지만 소팅을 위해서 넣는다
					record.LVDataList[3].szTexture = "L2UI_CH3.BloodHoodWnd.BloodHood_Logon";
					OnLineNum = OnLineNum++;
				}
				else 
				{
					record.LVDataList[3].szData = "0";
					record.LVDataList[3].szTexture = "L2UI_CH3.BloodHoodWnd.BloodHood_Logoff";
				}
				class'UIAPI_LISTCTRL'.static.InsertRecord( m_WindowName $ ".ClanMemberList", record );
			}
		}
		i = 0;
	}
	
	for( i=0 ; i < m_memberList[idx].m_array.Length ; ++i )
	{
		// 해외만 적용, 온라인 유저만 보여주는 거라면, continue
		if(IsUsePledgeBonus())
		{
			if (isOnlyOnline())
			{
				if (m_memberList[idx].m_array[i].id <= 0) continue;
			}
		}

		record.LVDataList[0].buseTextColor = True;
		
		record.LVDataList[0].szData = m_memberList[idx].m_array[i].sName;
		if( m_memberList[idx].m_array[i].bHaveMaster == 0)
		{
			record.LVDataList[0].TextColor = White;
		}
		else
		{
			record.LVDataList[0].TextColor = Yellow;
		}
		if( m_memberList[idx].m_array[i].sName == m_myName)
		{
			record.LVDataList[0].TextColor = BrightWhite;
			record.LVDataList[1].TextColor = BrightWhite;
			if (GetClanTypeFromIndex(m_currentShowIndex) == CLAN_MAIN)
			{
				m_indexNum = i;
			}
			else
			{
				m_indexNum = i+1;
			}
		}
		record.LVDataList[1].buseTextColor = True;

		// 한국어는 이전 것과 그대로.. 해외는 변경 버전 적용
		if (IsUsePledgeBonus())
		{
			// 해외
			// 자기 자신은 노랑
			if( m_memberList[idx].m_array[i].sName == m_myName )
			{
				record.LVDataList[0].TextColor = Yellow;
				record.LVDataList[1].TextColor = Yellow;
			}
			else
			{
				// 기존에는 자기 자신을 밝게 표기 했으나. 스팀 혈맹 개선에서 부터는 로그인 된 유저는 밝게 아니면 일반으로 표기
				if( m_memberList[idx].m_array[i].id > 0 )
				{
					record.LVDataList[0].TextColor = BrightWhite;
					record.LVDataList[1].TextColor = BrightWhite;
				}
				else
				{   
					record.LVDataList[0].TextColor = White;
					record.LVDataList[1].TextColor = White;
				}
			}
		}
		else
		{
			// 국내 그대로..
			if( m_memberList[idx].m_array[i].sName == m_myName)
			{
				record.LVDataList[1].TextColor = BrightWhite;
			}
			else
			{
				record.LVDataList[1].TextColor = White;
			}
		}		

		record.LVDataList[1].szData = string(m_memberList[idx].m_array[i].level);
		record.LVDataList[2].szData = string( m_memberList[idx].m_array[i].classID );		// 쓸모 없는 데이터지만 소팅을 위해서 넣는다
		record.LVDataList[2].szTexture = GetClassRoleIconName(m_memberList[idx].m_array[i].classID);
		record.LVDataList[2].HiddenStringForSorting = String (GetClassRoleType( m_memberList[idx].m_array[i].classID)); 		
		record.LVDataList[2].nTextureWidth = 11;
		record.LVDataList[2].nTextureHeight = 11;
		record.LVDataList[3].nTextureWidth = 31;
		record.LVDataList[3].nTextureHeight = 11;
		record.nReserved1 = m_memberList[idx].m_array[i].clanType;		// for additional information

		// 리스트 4번째 헤더를 해외는 혈맹 활동으로 변경 
		if(IsUsePledgeBonus())
		{
			// 온라인 유저 체크
			if( m_memberList[idx].m_array[i].id > 0 ) OnLineNum = OnLineNum++;

			//// 혈맹 활동 
			//if(m_memberList[idx].m_array[i].bActive > 0)
			//{
			//	record.LVDataList[3].szData = "1";
			//	record.LVDataList[3].szTexture = "L2UI_CT1.PledgeBonusWnd.PledgeflagIcon";  // 깃발
			//}
			//else
			//{
			//	record.LVDataList[3].szData = "";
			//	record.LVDataList[3].szTexture = "";
			//}

			// 혈맹 활동 
			// 완료
			if(m_memberList[idx].m_array[i].bActive == 1)
			{
				record.LVDataList[3].nTextureWidth  = 16;
				record.LVDataList[3].nTextureHeight = 16;

				record.LVDataList[3].szData = "1";
				record.LVDataList[3].szTexture = "L2UI_CT1.PledgeBonusWnd.PledgeflagIcon";  // 깃발 표시
			}
			// 새로 들어온 맴버 
			else if(m_memberList[idx].m_array[i].bActive == 2)
			{
				record.LVDataList[3].nTextureWidth = 26;
				record.LVDataList[3].nTextureHeight = 9;

				record.LVDataList[3].szData = "2";
				record.LVDataList[3].szTexture = "L2UI_CT1.pledgeBonusWnd.New";  // new 표시
			} 
			// 표시 안함.
			else
			{
				record.LVDataList[3].szData = "";
				record.LVDataList[3].szTexture = "";
			}
		}		
		else
		{
			if( m_memberList[idx].m_array[i].id > 0 )
			{
				record.LVDataList[3].szData = "1";				// 쓸모 없는 데이터지만 소팅을 위해서 넣는다
				record.LVDataList[3].szTexture = "L2UI_CH3.BloodHoodWnd.BloodHood_Logon";
				OnLineNum = OnLineNum++;
			}
			else 
			{
				record.LVDataList[3].szData = "2";
				record.LVDataList[3].szTexture = "L2UI_CH3.BloodHoodWnd.BloodHood_Logoff";
			}
		}

		class'UIAPI_LISTCTRL'.static.InsertRecord( m_WindowName $ ".ClanMemberList", record );
	}
	

	if (GetClanTypeFromIndex(m_currentShowIndex) <= CLAN_MAIN)
	{
		class'UIAPI_TEXTBOX'.static.SetText(m_WindowName $ ".ClanCurrentNum", "("$OnLineNum$"/"$m_memberList[idx].m_array.Length$")"); 
	}
	else
	{
		class'UIAPI_TEXTBOX'.static.SetText(m_WindowName $ ".ClanCurrentNum", "("$OnLineNum$"/"$m_memberList[idx].m_array.Length+1$")"); 
	}
}

function bool GetSelectedListCtrlItem(out LVDataRecord record)
{
	local int index;
	index = m_hClanMemberList.GetSelectedIndex();
	if( index >= 0 )
	{
		m_hClanMemberList.GetRec(index, record);
		return true;
	}
	return false;
}

function HandleMemberInfoUpdate( String a_Param )
{
	local ClanMemberInfo info;

	local int i;
	local int j;
	local int count;	
	local bool bHaveMasterChanged;
	local bool bMemberChanged;
	local int process_length;
	local int process_clanindex;
	
	bHaveMasterChanged= false;
	bMemberChanged = false;


	ParseString( a_Param, "Name", info.sName );
	ParseInt( a_Param, "Level", info.level );
	ParseInt( a_Param, "Class", info.classID );
	ParseInt( a_Param, "Gender", info.gender );
	ParseInt( a_Param, "Race", info.race );
	ParseInt( a_Param, "ID", info.ID );
	ParseInt( a_Param, "ClanType", info.clanType );
	ParseInt( a_Param, "HaveMaster", info.bHaveMaster );

		// 해외만 버전 추가 
	if(IsUsePledgeBonus()) ParseInt( a_Param, "MemberActive", info.bActive  );
	
	//debug("ClanWnd::HandleMemberInfoUpdate name " $ info.sName $ " level " $ info.level $ " classID " $ info.classID $ " gender " $ info.gender $ " race " $ info.race $ " ID " $ info.id $ " type " $ info.clanType $ " bHaveMaster " $ info.bHaveMaster );

	for( i=0 ; i < CLAN_KNIGHTHOOD_COUNT ; ++i )
	{
		count = m_memberList[ i ].m_array.Length;
		for(j=0; j < count ; ++j)
		{
			if( m_memberList[ i ].m_array[ j ].sName == info.sName )		// match found
			{
				//debug("HandleMemberInfoUpdate match found(i,j) :" $ i $ ", " $ j );
				if( m_memberList[ i ].m_array[ j ].bHaveMaster != info.bHaveMaster )
				{
					bHaveMasterChanged = true;
					m_memberList[ i ].m_array[ j ] = info;
					//debug("멤버정보 변경 이벤트 날아왔음222");
				}
				
				if(m_memberList[ i ].m_array[ j ].clanType != info.clanType)	
				{
					//m_memberList[ i ].m_array[ j ].sName = "";
					//m_memberList[ i ].m_array[ j ].clanType = 0;
					//m_memberList[ i ].m_array[ j ].level = 0;
					//m_memberList[ i ].m_array[ j ].classID = 0;
					//m_memberList[ i ].m_array[ j ].gender = 0;
					//m_memberList[ i ].m_array[ j ].race = 0;
					//m_memberList[ i ].m_array[ j ].ID = 0;
					//m_memberList[ i ].m_array[ j ].bHaveMaster = 0;
					bMemberChanged = true;
					//debug("멤버이동 처리");
					
					m_memberList[ i ].m_array.Remove(j, 1);
	
					
					
					process_clanindex = GetIndexFromType( info.clanType );
					process_length = m_memberList[ process_clanindex ].m_array.Length;
					m_memberList[ process_clanindex ].m_array.Insert(process_length, 1);
					//m_memberList[ process_clanindex ].m_array.Length = process_length+ 1;
					//process_length = m_memberList[ process_clanindex ].m_array.Length;
					
					m_memberList[ process_clanindex ].m_array[ process_length ].sName = info.sName;
					m_memberList[ process_clanindex ].m_array[ process_length ].clanType = info.clanType;
					m_memberList[ process_clanindex ].m_array[ process_length ].level = info.level;
					m_memberList[ process_clanindex ].m_array[ process_length ].classID = info.classID;
					m_memberList[ process_clanindex ].m_array[ process_length ].gender = info.gender;
					m_memberList[ process_clanindex ].m_array[ process_length ].race = info.race;
					m_memberList[ process_clanindex ].m_array[ process_length ].ID = info.ID;
					m_memberList[ process_clanindex ].m_array[ process_length ].bHaveMaster = info.bHaveMaster;
					
					class'UIAPI_TEXTBOX'.static.SetText(m_DrawerWindowName$".Clan1_CurrentSelectedMemberGrade", "");
										
					ShowList(info.clanType);
					
					//script.SetStateAndShow("ClanMemberInfoState");
				}
				else 
				{
					m_memberList[ i ].m_array[ j ] = info;
					ShowList(info.clanType);
				}
				break;
			}
		}
		if( j < count )
			break;			// match found. early break;
	}

	
	// 마침 그 사람의 정보를 보고 있었다면 UI를 업데이트 해 줘야한다	

	if( bHaveMasterChanged && class'UIAPI_WINDOW'.static.IsShowWindow(m_DrawerWindowName$".ClanMemberInfoWnd") )
	{		
		if( ClanDrawerWndClassicScript.m_currentName == info.sName )
		{
			//debug("HandleMemberInfoUpdate : RequestClanMemberInfo( " $ info.sName $ " )");
			RequestClanMemberInfo( info.clanType, info.sName );
		}
		if( GetIndexFromType( info.clanType ) == m_currentShowIndex )
		{
			ShowList( info.clanType );									// renew list
		}
		ShowList(m_currentShowIndex);
	}
	
	if( bMemberChanged && class'UIAPI_WINDOW'.static.IsShowWindow(m_DrawerWindowName$".ClanMemberInfoWnd") )
	{
		ClearList();
		ShowList( info.clanType );
		RefreshCombobox1(info.clanType );

		if( ClanDrawerWndClassicScript.m_currentName == info.sName )
		{
			RequestClanMemberInfo( info.clanType, info.sName );
		}			
	}
	
	//ShowList(m_currentShowIndex);
	
}

function RefreshCombobox1( int ClanT )
{
	local int i;

	for (i=0; i<10; ++i)
	{
		if (class'UIAPI_COMBOBOX'.static.GetReserved(m_WindowName $ ".ComboboxMainClanWnd", i) == ClanT)
		{
			class'UIAPI_COMBOBOX'.static.SetSelectedNum(m_WindowName $ ".ComboboxMainClanWnd", i);
			//debug("CurrentSelected:" @ i);
		}
	}
	
}

function HandleAddClanMember( String a_Param )
{
	local int count;
	local ClanMemberInfo info;
	
	ParseString( a_Param, "Name", info.sName );
	ParseInt( a_Param, "Level", info.level );
	ParseInt( a_Param, "Class", info.classID );
	ParseInt( a_Param, "Gender", info.gender );
	ParseInt( a_Param, "Race", info.race );
	ParseInt( a_Param, "ID", info.id );
	ParseInt( a_Param, "ClanType", info.clanType );

	// 해외만 버전 추가 
	if(IsUsePledgeBonus()) ParseInt( a_Param, "MemberActive", info.bActive  );

	info.bHaveMaster = 0;

	count = m_memberList[ GetIndexFromType( info.clanType ) ].m_array.Length;
	m_memberList[ GetIndexFromType( info.clanType ) ].m_array.Length = count + 1;
	m_memberList[ GetIndexFromType( info.clanType ) ].m_array[ count ] = info;
	//debug("ClanWnd::HandleAddClanMember Name: " $ info.sName $ " lv: "$ info.level $ "classID: " $ info.classID $ " id: " $ info.id $ "clanType: " $ info.clanType );

	if( GetIndexFromType( info.clanType ) == m_currentShowIndex )
		ShowList( info.clanType );									// renew list
}

function int GetIndexFromType( int type )
{
	local int i;
	i = -1;
	if(type == CLAN_MAIN)
	{
		i = 0;
	}
	else if(type == CLAN_KNIGHT1 )
	{
		i = 1;
	}
	else if(type == CLAN_KNIGHT2 )
	{
		i = 2;
	}
	else if(type == CLAN_KNIGHT3 )
	{
		i = 3;
	}
	else if(type == CLAN_KNIGHT4 )
	{
		i = 4;
	}
	else if(type == CLAN_KNIGHT5 )
	{
		i = 5;
	}
	else if(type == CLAN_KNIGHT6 )
	{
		i = 6;
	}
	else if(type == CLAN_ACADEMY )
	{
		i = 7;
	}
	return i;
}

function HandleDeleteMember( String a_Param )
{
	local int i;
	local int j;
	local int k;
	local int count;
	local string sName;

	ParseString( a_Param, "Name", sName );

	//debug("HandleDeleteMember name " $ sName );
	for( i=0 ; i < CLAN_KNIGHTHOOD_COUNT ; ++i )
	{
		count = m_memberList[ i ].m_array.Length;
		for(j=0; j < count ; ++j)
		{
			if( m_memberList[ i ].m_array[ j ].sName == sName )		// match found
			{
				//debug("HandleDeleteMember match found(i,j) :" $ i $ ", " $ j $ " count: " $ count );
				for( k=j ; k<count-1 ; ++k )
				{
					m_memberList[ i ].m_array[ k ] = m_memberList[ i ].m_array[ k + 1 ];
					//debug("HandleDeleteMember delete array");
				}
				m_memberList[ i ].m_array.Length = count - 1;		//shrink 
				//debug("HandleDeleteMember shrink Arrary to " $ m_memberList[ i ].m_array.Length );
				break;
			}
		}
		if( j < count )
			break;			// match found. early break;
	}

	if( i == m_currentShowIndex )
		ShowList( i );									// renew list
}

function RefreshCombobox()
{
	local int i;
	local int index;
	local int newIndex;
	local int addedCount;
	//local int addedCount2;
	index = class'UIAPI_COMBOBOX'.static.GetSelectedNum(m_WindowName $ ".ComboboxMainClanWnd");
	class'UIAPI_COMBOBOX'.static.Clear(m_WindowName $ ".ComboboxMainClanWnd");
	addedCount = -1;
	//addedCount2 = 0;
	//debug("myClanType:" @ m_myClanType);
	for( i=0 ; i < CLAN_KNIGHTHOOD_COUNT ; ++i )
	{
		if( m_memberList[i].m_sName != "" )
		{
			// 문춘식 여기 수정했음. -_-;
			//class'UIAPI_COMBOBOX'.static.AddString(m_WindowName $ ".ComboboxMainClanWnd", m_memberList[i].m_sName);
			//debug("CurrentI : " @ i );
			class'UIAPI_COMBOBOX'.static.AddStringWithReserved(m_WindowName $ ".ComboboxMainClanWnd", GetClanTypeNameFromIndex(GetClanTypeFromIndex(i))@"-"@m_memberList[i].m_sName, GetClanTypeFromIndex(i));
			++addedCount;
			//++addedCount2;
			
			if( i == m_currentShowIndex )
			{
				newIndex = addedCount;
			}
			//if( i == m_myClanType)
			//{
			//	m_indexNumKH = addedCount2;
			//	debug("ShowmyIndexNumChange:" @ m_indexNumKH);
			//}
			
			
			
		}
	}

	//debug("RefreshCombobox m_currentShowIndex " $ m_currentShowIndex $ " newIndex " $ newIndex $ " addedCount " $ addedCount );

	//class'UIAPI_COMBOBOX'.static.SetSelectedNum(m_WindowName $ ".ComboboxMainClanWnd", m_indexNumKH );
	
	for (i=0; i<10; ++i)
	{
		if (class'UIAPI_COMBOBOX'.static.GetReserved(m_WindowName $ ".ComboboxMainClanWnd", i) == m_myClanType)
		{
			class'UIAPI_COMBOBOX'.static.SetSelectedNum(m_WindowName $ ".ComboboxMainClanWnd", i);
			//debug("CurrentSelected:" @ i);
		}
	}
}

function HandleSubClanUpdated( String a_Param )
{
	local int id;
	local int type;
	local string sName;
	local string sMasterName;

	ParseInt( a_Param, "ClanID", id );
	ParseInt( a_Param, "ClanType", type );
	ParseString( a_Param, "ClanName", sName );
	ParseString( a_Param, "MasterName", sMasterName );

	//debug("HandleSubClanCreated type " $ type $ " name " $ sName $ " masterName " $ sMasterName );
	m_memberList[ GetIndexFromType( type ) ].m_sName = sName;
	m_memberList[ GetIndexFromType( type ) ].m_sMasterName = sMasterName;
	RefreshComboBox();
	
	if( class'UIAPI_WINDOW'.static.IsShowWindow(m_DrawerWindowName$".ClanInfoWnd") )			// 혈맹 정보 창이 보여지고 있다면 업데이트 해준다.
	{		
		ClanDrawerWndClassicScript.InitializeClanInfoWnd();
	}
}

function AskJoin()
{
	local UserInfo user;
	//local Rect rect;
	//local InviteClanPopWnd script;
	local InviteClanPopWndClassic InviteClanPopWndScript;	

	if( GetTargetInfo( user ) )
	{
		//debug("AskJoin id " $ user.nID $ " name " $ user.Name );
		if( user.nID > 0 )
		{
			//script = InviteClanPopWnd( GetScript("InviteClanPopWnd" ) );
			//rect = class'UIAPI_WINDOW'.static.GetRect("MainWnd");
			//class'UIAPI_WINDOW'.static.MoveTo("InviteClanPopWnd", rect.nX + rect.nWidth, rect.nY + rect.nHeight);
			InviteClanPopWndScript = InviteClanPopWndClassic( GetScript("InviteClanPopWndClassic" ) );
			InviteClanPopWndScript.showByClanWnd();
			//class'UIAPI_WINDOW'.static.Showwindow("InviteClanPopWnd");
		}
	}
}

function HandleClanMyAuth( String a_Param )
{
	ParseInt( a_Param, "ClanMaster", m_bClanMaster );
	ParseInt( a_Param, "Join", m_bJoin );
	ParseInt( a_Param, "NickName", m_bNickName );
	ParseInt( a_Param, "ClanCrest", m_bCrest );
	ParseInt( a_Param, "War", m_bWar );
	ParseInt( a_Param, "Grade", m_bGrade );
	ParseInt( a_Param, "ManageMaster", m_bManageMaster );
	ParseInt( a_Param, "OustMember", m_bOustMember );

	resetBtnShowHide();
	//debug("HandleClanMyAuth bMaster:"$m_bClanMaster$" bJoin: "$m_bJoin$" bNickName: "$m_bNickName$" bCrest: "$m_bCrest$" bWar: "$m_bWar$" bGrade: "$m_bGrade$" bManageMaster: "$m_bManageMaster$" bOustMember: " $m_bOustMember);
}
// 문춘식 추가 
function ResetOpeningVariables()
{
	m_currentactivestatus1 = false;
	m_currentactivestatus2 = false;
	m_currentactivestatus3 = false;
	m_currentactivestatus4 = false;
	m_currentactivestatus5 = false;
	m_currentactivestatus6 = false;
	m_currentactivestatus7 = false;
	m_currentactivestatus8 = false;
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
    m_WindowName="ClanWndClassic"
    m_DrawerWindowName="ClanDrawerWndClassic"
    m_ClanPledgeBonusDrawerWndName="ClanPledgeBonusDrawerWndClassic"
}
