class ClanDrawerWndClassic extends UIData;

const DIALOG_AskLossClanWar = 90009;
const DIALOG_AskClanWarCancel = 487;

const c_maxranklimit = 100;
const changelineval1 = 23;

const DISABLE_ALPHA=100;		//디스에이블 해줄때의 알파. 아카데미 디스에이블
const ACADEMY_INDEX=7;		//아카데미의 아이콘 인덱스

var	string	m_state;
var int		m_clanType;
var int		m_clanWarListPage;			// 선포
var int		m_currentEditGradeID;
var string	m_currentName;
var string 	m_myName;
var int	m_currentMaster;
//var bool	m_currentmemberselectoffset;
//var int	m_clanType;
var string 	currentMasterName;

var string  currentLossWarClanName; // 전쟁 패배 선언 용
var string  m_WindowName;
var string  m_ClanPledgeBonusDrawerWndName;

//classic// var ListCtrlHandle	m_hClanDrawerWndClan1_AssignApprenticeList;
var ListCtrlHandle  m_hClanDrawerWndClan8_DeclaredListCtrl;
var ListCtrlHandle  m_hClanDrawerWndClan8_GotDeclaredListCtrl;
var ListCtrlHandle	m_hClanDrawerWndClan5_AuthListCtrl;
//classic// var ListCtrlHandle  m_hClanDrawerWndClan5_AuthListCtrl2;


const NUMOFOPTIONS_SYSTEM = 10;
const NUMOFOPTIONS_AGIT = 5;
const NUMOFOPTIONS_CASTLE = 8;

//classic// var int ClanClickedID;	// 현재 클랜 스킬 트리 부분이 클릭되어 있는지 확인

//Handle
//classic// var WindowHandle Clan3_OrgIcon[CLAN_KNIGHTHOOD_COUNT];
//var ButtonHandle Clan3_OrgButton[CLAN_KNIGHTHOOD_COUNT];
//classic// var TextureHandle Clan3_OrgHighLight[CLAN_KNIGHTHOOD_COUNT];

// var TabHandle	m_hClanDrawerWndClanWarTabCtrl;


var FileRegisterWnd fileRegisterWndHandle;

var ClanWndClassic clanWndClassicScript;
	

function OnRegisterEvent()
{
	registerEvent( EV_ClanAuthGradeList );
	registerEvent( EV_ClanCrestChange );
	registerEvent( EV_ClanAuth );
	registerEvent( EV_ClanAuthMember );
	registerEvent( EV_ClanMemberInfo );
	registerEvent( EV_ClanWarList );
	registerEvent( EV_ClanSkillList );
	registerEvent( EV_ClanSkillListRenew);
	//registerEvent( EV_ClanSkillListAdd );
	registerEvent( EV_GamingStateExit );
	registerEvent( EV_ClanClearWarList );

	registerEvent(EV_DialogOK);
	registerEvent(EV_DialogCancel);
	//~ registerEvent( EV_ClanInfo );
	//~ registerEvent( EV_
}

function OnLoad()
{
	SetClosingOnESC();
	
	InitHandle();
	InitializeGradeComboBox();
	HideAll();
	
	m_clanWarListPage = -1;
	
//classic// 	ClanClickedID = -1;

	//classic// m_hClanDrawerWndClan1_AssignApprenticeList=GetListCtrlHandle(m_WindowName$".Clan1_AssignApprenticeList");
	m_hClanDrawerWndClan8_DeclaredListCtrl=   GetListCtrlHandle(m_WindowName$".Clan8_DeclaredListCtrl");
	m_hClanDrawerWndClan8_GotDeclaredListCtrl=GetListCtrlHandle(m_WindowName$".Clan8_DeclaredListCtrl");
	m_hClanDrawerWndClan5_AuthListCtrl=GetListCtrlHandle(m_WindowName$".Clan5_AuthListCtrl");
//classic// 	m_hClanDrawerWndClan5_AuthListCtrl2=GetListCtrlHandle(m_WindowName$".Clan5_AuthListCtrl2");

	// m_hClanDrawerWndClanWarTabCtrl=GetTabHandle(m_WindowName$".ClanWarTabCtrl");

	fileRegisterWndHandle = FileRegisterWnd(GetScript("FileRegisterWnd"));

	//classic// 삭제해야 할 체크 항목 들 event로 
	class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan2_Check108" );
	class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan2_Check109" );
	class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan2_Check110" );
	class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan2_Check302" );
	class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan6_Check108" );
	class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan6_Check109" );
	class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan6_Check110" );
	class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan6_Check302" );

}


function InitHandle()
{
	/*
	local int i;


	for( i=0 ; i < CLAN_KNIGHTHOOD_COUNT ; ++i )
	{		
		Clan3_OrgIcon[i] = GetWindowHandle(m_WindowName$".Clan3_OrgIcon" $ (i + 1));
		Clan3_OrgHighLight[i] = GetTextureHandle( m_WindowName$".Clan3_OrgIconWnd" $ (i + 1) $ ".texIconHighlight");	

		if(i == ACADEMY_INDEX)	//아카데미 일 경우
		{
			Clan3_OrgIcon[i].DisableWindow();
			Clan3_OrgIcon[i].SetAlpha(DISABLE_ALPHA);			
		}
		Clan3_OrgHighLight[i].HideWindow();
	}*/

	clanWndClassicScript = ClanWndClassic ( GetScript ("ClanWndClassic"));
}

function OnShow()
{
	// 해외 예외 처리
	if(GetWindowHandle(m_ClanPledgeBonusDrawerWndName).IsShowWindow()) GetWindowHandle(m_ClanPledgeBonusDrawerWndName).HideWindow();
	
	// 권한에 따라 버튼 Enable/Diable
	class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName$".Clan1_ChangeMemberNameBtn");			// nickname
	class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName$".Clan1_ChangeMemberGradeBtn");
	//classic// class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName$".Clan1_AssignApprenticeBtn");
	//classic// class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName$".Clan1_DeleteApprenticeBtn");
	class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_ChangeBanishBtn");
	
	if( clanWndClassicScript.m_bClanMaster == 0 )
	{
		if(clanWndClassicScript.m_bNickName == 0)
		{
			class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_ChangeMemberNameBtn");	
		}				// nickname
		if( clanWndClassicScript.m_bGrade==0)
		{
			class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_ChangeMemberGradeBtn");
		}
		//classic// 
		/*
		if(clanWndClassicScript.m_bManageMaster == 0)
		{
			//classic//class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_AssignApprenticeBtn");
			//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_DeleteApprenticeBtn");
		}
		*/
		if(clanWndClassicScript.m_bOustMember == 0)
		{
			class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_ChangeBanishBtn");
		}
	}
	//전쟁목록이 없는경우 전쟁철회버튼 비활성
	switchingWarCancelButton();
}

function Clear()
{
	m_state = "";
	m_clanType = -1;
	m_clanWarListPage = -1;
	m_currentEditGradeID = -1;
	m_currentName = "";
}

function SetStateAndShow( string state )
{	
	local int i;
	local string string1;
	local string string2;
	local string string3;
	local string string4;
	//debug( "SetState " $ state );
	m_state = state;
	if( !class'UIAPI_WINDOW'.static.IsShowWindow(m_WindowName) )
	{
		class'UIAPI_WINDOW'.static.ShowWindow(m_WindowName);
	}
	HideAll();
	if( m_state == "ClanMemberInfoState" )
	{
		//RecallCurrentMemberInfo();
		class'UIAPI_WINDOW'.static.ShowWindow(m_WindowName$".ClanMemberInfoWnd");
		class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_ChangeMemberNameWnd");
		class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_ChangeMemberGradeNameWnd");
		//classic// class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_AssignApprenticeWnd");
		class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_ChangeMemberKnightHoodWnd");
	}
	else if( m_state == "ClanMemberAuthState" )			// 혈원의 권한 보기. 보기만 되므로 모든 체크 박스는 Diable
	{
		class'UIAPI_WINDOW'.static.ShowWindow(m_WindowName$".ClanMemberAuthWnd");
		for( i=0 ; i <= NUMOFOPTIONS_SYSTEM ; ++i )	// 비행정 관련 수정- CT2_Final
		{
			if(i < 10) class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan2_Check10" $ i, true );
			else	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan2_Check1" $ i, true );
		}

		for( i=0; i <= NUMOFOPTIONS_AGIT ; ++i )
			class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan2_Check20" $ i, true );

		for( i=0; i <= NUMOFOPTIONS_CASTLE ; ++i )
			class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan2_Check30" $ i, true );

		//class'UIAPI_WINDOW'.static.ShowWindow(m_WindowName$".ClanMemberAuthWnd");

	}
	else if( m_state == "ClanInfoState" )		// 혈맹 정보
	{
		InitializeClanInfoWnd();
		class'UIAPI_ITEMWINDOW'.static.Clear( m_WindowName$".ClanSkillWnd" );	//리퀘스트 하기 전에 일단 아이템윈도우 정리
		class'UIDATA_CLAN'.static.RequestClanSkillList();
		class'UIAPI_WINDOW'.static.ShowWindow(m_WindowName$".ClanInfoWnd");
		//InitializeClanInfoWnd();
	}
	else if( m_state == "ClanAuthManageWndState" )	// 권한 목록
	{
		class'UIAPI_WINDOW'.static.ShowWindow(m_WindowName$".ClanAuthManageWnd");
	}
	else if( m_state == "ClanEmblemManageWndState" )	//문장 관리
	{
		class'UIAPI_WINDOW'.static.ShowWindow(m_WindowName$".ClanEmblemManageWnd");
		
		string1 = Left(GetSystemMessage(211), changelineval1);
		string2 = Right(GetSystemMessage(211), Len(GetSystemMessage(211))-changelineval1);
		string3 = Left(GetSystemMessage(1478), changelineval1);
		string4 = Right(GetSystemMessage(1478), Len(GetSystemMessage(1478))-changelineval1);
		class'UIAPI_TEXTBOX'.static.SetText(m_WindowName$".Clan7_ManageEmb1Text1", string1);
		class'UIAPI_TEXTBOX'.static.SetText(m_WindowName$".Clan7_ManageEmb1Text2", string2);
		class'UIAPI_TEXTBOX'.static.SetText(m_WindowName$".Clan7_ManageEmb2Text1", string3);
		class'UIAPI_TEXTBOX'.static.SetText(m_WindowName$".Clan7_ManageEmb2Text2", string4);

		
		//class'UIAPI_TEXTURECTRL'.static.SetTextureWithClanCrest( m_WindowName$".ClanCrestTextureCtrl", clanWndClassicScript.m_clanID );
	}
	else if( m_state == "ClanWarManagementWndState" )	// 전쟁 정보
	{
		// m_hClanDrawerWndClanWarTabCtrl.SetTopOrder(0, true);
		class'UIAPI_WINDOW'.static.ShowWindow(m_WindowName$".ClanWarManagementWnd");
	}
	else if( m_state == "ClanAuthEditWndState" )	// 권한 편집
	{
		class'UIAPI_WINDOW'.static.ShowWindow(m_WindowName$".ClanAuthEditWnd");
	}
	else if( m_state == "ClanHeroWndState" )		//영웅 전용 메뉴 보기
	{
		class'UIAPI_WINDOW'.static.ShowWindow(m_WindowName$".ClanHeroWnd");
	}
}

function HideAll()
{
	class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".ClanMemberInfoWnd");
	class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".ClanMemberAuthWnd");
	class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".ClanInfoWnd");
	class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".ClanPenaltyWnd");
	class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".ClanWarManagementWnd");
	class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".ClanAuthManageWnd");
	class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".ClanAuthEditWnd");
	class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".ClanEmblemManageWnd");
	class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".ClanHeroWnd");
	
}

function OnClickButton( string strID )
{
	//local LVDataRecord record;
	//local int temp1;
	//local int nClanIdx;
	//local int i;
	//local int warListIndex;
	
	local Array<string> fileextarr;
	

	//debug("ClanDrawerWnd::OnClickButton " $ strID );
	if( strID == "Clan1_AskJoinPartyBtn" )				// 혈원 정보. 파티 초대
	{
		RequestInviteParty( class'UIAPI_TEXTBOX'.static.GetText(m_WindowName$".Clan1_CurrentSelectedMemberName" ) );
	}
	else if( strID == "Clan1_ChangeMemberNameBtn" )		// 혈원 정보. 호칭 변경
	{
		class'UIAPI_WINDOW'.static.ShowWindow(m_WindowName$".Clan1_ChangeMemberNameWnd");
		class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_ChangeMemberGradeNameWnd");
		//classic// class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_AssignApprenticeWnd");
		class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_ChangeMemberKnightHoodWnd");
		class'UIAPI_EDITBOX'.static.SetString(m_WindowName$".Clan1_ChangeNameTextEditbox","");
		
	}
	else if( strID == "Clan1_ChangeMemberGradeBtn" )	// 혈원 정보. 등급 변경
	{
		class'UIAPI_WINDOW'.static.ShowWindow(m_WindowName$".Clan1_ChangeMemberGradeNameWnd");
		class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_ChangeMemberNameWnd");
		class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_ChangeMemberKnightHoodWnd");
		// classic // class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_AssignApprenticeWnd");
	}
	else if ( strID == "Clan1_ChangeBanishBtn")			// 혈원 정보. 혈원 제명
	{
		HideClanWindow();
		class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_ChangeMemberNameWnd");
		class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_ChangeMemberGradeNameWnd");
		//classic// class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_AssignApprenticeWnd");
		RequestClanExpelMember( m_clanType, class'UIAPI_TEXTBOX'.static.GetText(m_WindowName$".Clan1_CurrentSelectedMemberName" ));
	}
	/* classic 
	else if( strID == "Clan1_AssignApprenticeBtn" )		// 혈원 정보. 제자 할당.
	{
		//classic// class'UIAPI_WINDOW'.static.ShowWindow(m_WindowName$".Clan1_AssignApprenticeWnd");
		class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_ChangeMemberNameWnd");
		class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_ChangeMemberKnightHoodWnd");
		class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_ChangeMemberGradeNameWnd");
		InitializeAcademyList();
	}
	*/
	// 신규추가 중간 업데이트 
	//classic//
	/*
	else if( strID == "Clan1_ChangeMemberKHOpen" )		// 혈원 소속 변경
	{
		class'UIAPI_WINDOW'.static.ShowWindow(m_WindowName$".Clan1_ChangeMemberKnightHoodWnd");
		//classic// class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_AssignApprenticeWnd");
		class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_ChangeMemberNameWnd");
		class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_ChangeMemberGradeNameWnd");
		KnighthoodCombobox();
	}
*/

	//classic// 
	/*
	else if( strID == "Clan1_DeleteApprenticeBtn" )		// 혈원 정보. 제자 없애기
	{
		RequestClanDeletePupil( class'UIAPI_TEXTBOX'.static.GetText(m_WindowName$".Clan1_CurrentSelectedMemberName" ), class'UIAPI_TEXTBOX'.static.GetText(m_WindowName$".Clan1_CurrentSelectedApprentice" ));
		RecallCurrentMemberInfo();
		//ResetdeleteApprenticeonMainWnd(class'UIAPI_TEXTBOX'.static.GetText(m_WindowName$".Clan1_CurrentSelectedMemberName" ), class'UIAPI_TEXTBOX'.static.GetText(m_WindowName$".Clan1_CurrentSelectedApprentice" ));
	}*/
	else if( strID == "Clan1_OKBtn" )
	{
		HideClanWindow();
	}
	else if( strID == "Clan1_ChangeNameAssignBtn" )		// [호칭 변경] 버튼을 눌렀을 때 호칭 입력창과 함께 나오는 [적용] 버튼
	{
		//debug("Clan1_ChangeNameAssignBtn");
		RequestClanChangeNickName( class'UIAPI_TEXTBOX'.static.GetText(m_WindowName$".Clan1_CurrentSelectedMemberName" ), 
		class'UIAPI_EDITBOX'.static.GetString(m_WindowName$".Clan1_ChangeNameTextEditbox") ) ;
		class'UIAPI_EDITBOX'.static.SetString(m_WindowName$".Clan1_ChangeNameTextEditbox","");
		class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_ChangeMemberNameWnd");	
		//유저 정보 리셋 함수 
		RecallCurrentMemberInfo();
	}
	else if( strID == "Clan1_ChangeNameDeleteBtn" )		// [호칭 삭제] 버튼을 눌렀을 때
	{
		//debug("Clan1_ChangeNameDeleteBtn");
		RequestClanChangeNickName( class'UIAPI_TEXTBOX'.static.GetText(m_WindowName$".Clan1_CurrentSelectedMemberName" ), 
			"" );
		class'UIAPI_EDITBOX'.static.SetString(m_WindowName$".Clan1_ChangeNameTextEditbox", "");
		class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_ChangeMemberNameWnd");	
		//유저 정보 리셋 함수 
		RecallCurrentMemberInfo();
	}
	
	else if( strId == "Clan1_ChangeMemberGradeAssignBtn" ) // [등급 변경] 버튼을 눌렀을 때 나오는 [적용] 버튼
	{
		//debug("Clan1_ChangeMemberGradeAssignBtn");
		//if (class'UIAPI_COMBOBOX'.static.GetSelectedNum(m_WindowName$".Clan1_MemberGradeList") <= 5) 
		if (class'UIAPI_COMBOBOX'.static.GetSelectedNum(m_WindowName$".Clan1_MemberGradeList") < 5) 
		{
			RequestClanChangeGrade( class'UIAPI_TEXTBOX'.static.GetText(m_WindowName$".Clan1_CurrentSelectedMemberName" ), 
			class'UIAPI_COMBOBOX'.static.GetSelectedNum(m_WindowName$".Clan1_MemberGradeList") + 1);	// grade 는 1부터 9까지
		} 
		else 
		{
			//debug("현재 등급을 찾아서 세팅하도록");
			//debug("현재 설정된 클랜 고유번호:" @ m_clanType);
			RequestClanChangeGrade( class'UIAPI_TEXTBOX'.static.GetText(m_WindowName$".Clan1_CurrentSelectedMemberName" ), 
			getCurrentGradebyClanType());		// 원래 소속등급을 찾아서 세팅 한다.
		}
		class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_ChangeMemberGradeNameWnd");	
		//유저 정보 리셋 함수 
		RecallCurrentMemberInfo();
	}
	/* //classic//
	 *
	else if( strID == "Clan1_ApprenticeAssignBtn" )		// [제자선임] 버튼 눌렀을 때 나오는 [적용] 버튼
	{
		//debug("Clan1_ApprenticeAssignBtn");
		i = class'UIAPI_LISTCTRL'.static.GetSelectedIndex(m_WindowName$".Clan1_AssignApprenticeList");
		if( i >= 0 && m_currentName != "" )
		{
			m_hClanDrawerWndClan1_AssignApprenticeList.GetRec(i, record);
			RequestClanAssignPupil( m_currentName, record.LVDataList[0].szData );
		}
		//classic// class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_AssignApprenticeWnd");	
		//유저 정보 리셋 함수 
		//RecallCurrentMemberInfo();
		//ResetAssignApprenticeonMainWnd(m_currentName, record.LVDataList[0].szData);
	}*/
	
	else if( strID == "Clan1_ChangeMemberKnightHoodBtn" )		//혈원소속변경 변경 버튼
	{
		proc_swapmember();
		class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_ChangeMemberKnightHoodWnd");	
	}
	
	
	else if( strID == "Clan1_Cancel1" )		//호칭변경창 [취소] 버튼
	{
		class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_ChangeMemberNameWnd");	
	}
	else if( strID == "Clan1_Cancel2" )		//혈원등급창 [취소] 버튼
	{
		class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_ChangeMemberGradeNameWnd");	
	}
 	/*//classic// 

	else if( strID == "Clan1_Cancel3" )		//후견인 [취소] 버튼
	{
		//classic// class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_AssignApprenticeWnd");	
	}
*/
	else if( strID == "Clan1_Cancel4" )		//혈원소속변경 [취소] 버튼
	{
		class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_ChangeMemberKnightHoodWnd");	
	}
	
	else if( strID == "Clan7_RegEmbBtn" )		// 혈맹 문장 등록
	{
		//RequestClanRegisterCrest();

		// FileRegisterWnd

		
		// m_editHandle.IsShowWindow() 

		if (class'UIAPI_WINDOW'.static.IsShowWindow("FileRegisterWnd") == false)
		{
			fileextarr.Length = 1;
			fileextarr[0] = "bmp";			
			ClearFileRegisterWndFileExt();
			AddFileRegisterWndFileExt(GetSystemString(2811), fileextarr);
			FileRegisterWndShow(FH_PLEDGE_CREST_UPLOAD);
		}
	}
	else if( strID == "Clan7_RmEmbBtn" )		// 혈맹 문장 삭제
	{
		RequestClanUnregisterCrest();
	}
	else if( strID == "Clan7_RegEmb2Btn" )		// 휘장 등록
	{
		
		if (class'UIAPI_WINDOW'.static.IsShowWindow("FileRegisterWnd") == false)
		{
			fileextarr.Length = 2;
			fileextarr[0] = "tga";
			fileextarr[1] = "bmp";
			ClearFileRegisterWndFileExt();
			AddFileRegisterWndFileExt(GetSystemString( 2233 ), fileextarr);
			FileRegisterWndShow(FH_PLEDGE_EMBLEM_UPLOAD);
			//RequestClanRegisterEmblem();
		}
	}
	else if( strID == "Clan7_RmEmb2Btn" )		// 휘장 삭제
	{
		RequestClanUnregisterEmblem();
	}

	else if( strID == "Clan8_CancelWar1Btn" )		// 전쟁정보 전쟁철회
	{
		//다이얼로그 띄운다.
		class'UICommonAPI'.static.DialogSetID( DIALOG_AskClanWarCancel );
		class'UICommonAPI'.static.DialogSetDefaultCancle(); // 엔터를 치거나 타임아웃발생시 cancle로 판단
		DialogShow(DialogModalType_Modalless, DialogType_OKCancel, MakeFullSystemMsg( GetSystemMessage(3883), ""), string(Self) );
	}
	else if( strID == "Clan8_DeclareWar1Btn" )		// 여기서부터 피선포 창일때
	{
		HandleDeclareWar();
	}
	else if( strID == "Clan8_CancelWar2Btn" )
	{
		HandleCancelWar2();
	}
	else if( strID == "Clan8_ViewMoreBtn" )			// 피선포 창 END
	{
		RequestClanWarList( ++m_clanWarListPage, 1 );
	}
	else if( strID == "Clan8_LoseBtn" )			// 패배 선언 창
	{
		HandleDeclareLoseWar();
	}
	
	else if( strID == "Clan2_OKBtn" )
	{
		HideClanWindow();
	}
	else if( strID == "Clan3_OKBtn" )
	{
		HideClanWindow();
	}
	else if( strID == "Clan4_OKBtn" )
	{
		HideClanWindow();
	}
	else if( strID == "Clan5_OKBtn" )		// 등급 리스트
	{
		HideClanWindow();
	}
	else if( strID == "Clan7_OKBtn" )
	{
		HideClanWindow();
	}
	else if( strID == "ClanWar_OKBtn" )
	{
		HideClanWindow();
	}
	else if( strID == "Clan5_ManageBtn")
	{
		EditAuthGrade();
	}
	//classic//
	/*
	else if( strID == "Clan5_ManageBtn2")
	{
		EditAuthGrade2();
	}
	*/
	else if( strID == "Clan6_ApplyBtn" )		// 권한 편집 적용
	{
		ApplyEditGrade();
		SetStateAndShow("ClanAuthManageWndState");
	}
	else if( strID == "Clan6_CancelBtn" )
	{
		SetStateAndShow("ClanAuthManageWndState");
	}
	else if( strID == "ClanWarTabCtrl0" )
	{
		RequestClanWarList( 0, 0 );
	}
	else if( strID == "ClanWarTabCtrl1" )
	{
		RequestClanWarList( m_clanWarListPage, 1 );
	}
	else if( strID == "Clan1_ChangeNameAssignNobBtn" )
	{
		//ExecuteCommandFromAction("selfnickname");
		//ExecuteCommand("/selfnickname " $ class'UIAPI_EDITBOX'.static.GetString(m_WindowName$".Clan1_ChangeNobNameTextEditbox"));
		//debug("nicknamechanged?");
		//debug("Clan1_ChangeNameAssignBtn");
		//debug(clanWndClassicScript.m_myName);
		RequestClanChangeNickName( clanWndClassicScript.m_myName, 
		class'UIAPI_EDITBOX'.static.GetString(m_WindowName$".Clan1_ChangeNobNameTextEditbox") ) ;
		class'UIAPI_EDITBOX'.static.SetString(m_WindowName$".Clan1_ChangeNobNameTextEditbox","");
		
	}	
	else if( strID == "Clan1_NobCancel1" )
	{
		HideClanWindow();
	}	
	else if( strID == "Clan1_ChangeNameDeleteNobBtn" )
	{
		RequestClanChangeNickName( clanWndClassicScript.m_myName, "" );
	}
	/*
	 //classic//
	else if( Left( strID , 12 ) == "Clan3_OrgIco")
	{
		temp1 = Int( Right (strID , 1));
		if(temp1 == 8) 
		{
			return;	// 아카데미는 무시한다. 
		}
		if(temp1 > 0  && temp1 < CLAN_KNIGHTHOOD_COUNT + 2)
		{
			if( (ClanClickedID < 0) || (temp1 != ClanClickedID)  )	// 클릭된게 없거나, 방금 누른거랑 아까 누른게 다를 때
			{
				Clan3_OrgHighLight[temp1-1].ShowWindow();
				if(ClanClickedID != -1)	Clan3_OrgHighLight[ClanClickedID-1].HideWindow();	// 다른것을 눌렀을경우 아까 누른 하이라이트 해제
				nClanIdx = GetClanTypeFromIndex( temp1 - 1);
				class'UIAPI_ITEMWINDOW'.static.Clear( m_WindowName$".ClanSkillWnd" );	//리퀘스트 하기 전에 일단 아이템윈도우 정리
				class'UIDATA_CLAN'.static.RequestClanSkillList();			//전체 혈맹 스킬 요청
				class'UIDATA_CLAN'.static.RequestSubClanSkillList(nClanIdx);	// 하위부대 스킬 요청
				ClanClickedID = temp1;
			}		
			else if(temp1 == ClanClickedID)	// 방금 누른것을 또 눌렀을때 체크 해제
			{
				Clan3_OrgHighLight[temp1-1].HideWindow();
				class'UIAPI_ITEMWINDOW'.static.Clear( m_WindowName$".ClanSkillWnd" );	//리퀘스트 하기 전에 일단 아이템윈도우 정리
				class'UIDATA_CLAN'.static.RequestClanSkillList();
				ClanClickedID = -1;
			}
		}
	}*/
	else if (strID == "Clan8_RefreshBtn")
	{	
		RequestClanWarList( 0, 0 );
	}
}

//function ResetAssignApprenticeonMainWnd(string C_NAME, string C_APP)
//{
//	local MainWnd script;
//	script = MainWnd( GetScript("MainWnd") );
//	clanWndClassicScript.assignClanMasterAssign(C_NAME, clanWndClassicScript.m_memberList[ clanWndClassicScript.GetIndexFromType( m_clanType ) ]);
//	debug("changed:" $ C_NAME);
//	clanWndClassicScript.assignClanMasterAssign(C_APP, clanWndClassicScript.m_memberList[ clanWndClassicScript.GetIndexFromType( CLAN_ACADEMY ) ]);
//	debug("changed:" $ C_APP);
//	clanWndClassicScript.ClearList();
//	clanWndClassicScript.AddToList( clanWndClassicScript.m_memberList[ clanWndClassicScript.GetIndexFromType( m_clanType ) ] );
//	clanWndClassicScript.m_currentShowIndex = clanWndClassicScript.GetIndexFromType( m_clanType );
//}


//function ResetdeleteApprenticeonMainWnd(string C_NAME, string C_APP)
//{
//	local MainWnd script;
//	script = MainWnd( GetScript("MainWnd") );
//	clanWndClassicScript.deleteClanMasterAssign(C_NAME, clanWndClassicScript.m_memberList[ clanWndClassicScript.GetIndexFromType( m_clanType ) ]);
//	debug("changed:" $ C_NAME);
//	clanWndClassicScript.deleteClanMasterAssign(C_APP, clanWndClassicScript.m_memberList[ clanWndClassicScript.GetIndexFromType( CLAN_ACADEMY ) ]);
//	debug("changed:" $ C_APP);
//	clanWndClassicScript.ClearList();
//	clanWndClassicScript.AddToList( clanWndClassicScript.m_memberList[ clanWndClassicScript.GetIndexFromType( m_clanType ) ] );
//	clanWndClassicScript.m_currentShowIndex = clanWndClassicScript.GetIndexFromType( m_clanType );
//}


//레코드를 더블클릭하면....
function OnDBClickListCtrlRecord( string ListCtrlID)
{
	//local int i;
	//local LVDataRecord	record;	
	
	if (ListCtrlID == "Clan5_AuthListCtrl")
	{
		EditAuthGrade();
	}
	//classic// 
	/*
	if (ListCtrlID == "Clan5_AuthListCtrl2")
	{
		EditAuthGrade2();
	}*/
	
	/*
	if (ListCtrlID == "Clan1_AssignApprenticeList")
	{
		//debug("Clan1_ApprenticeAssignBtn");
		i = class'UIAPI_LISTCTRL'.static.GetSelectedIndex(m_WindowName$".Clan1_AssignApprenticeList");
		if( i >= 0 && m_currentName != "" )
		{
			m_hClanDrawerWndClan1_AssignApprenticeList.GetRec(i, record);
			RequestClanAssignPupil( m_currentName, record.LVDataList[0].szData );
		}
		//classic// class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".Clan1_AssignApprenticeWnd");	
		//유저 정보 리셋 함수 
		//RecallCurrentMemberInfo();
		//ResetAssignApprenticeonMainWnd(m_currentName, record.LVDataList[0].szData);
	}
*/
	
}

// 현재 유저 정보창의 데이터를 리셋
function RecallCurrentMemberInfo()
{	
	RequestClanMemberInfo(clanWndClassicScript.G_CurrentRecord,clanWndClassicScript.G_CurrentSzData);
	SetStateAndShow("ClanMemberInfoState");
}

// selectall_checkbox_coded by Choonsik 
function OnClickCheckBox(string CheckBoxID)
{
	local string CheckboxNum;
	local string CheckboxName;
	local bool CheckedStat;
	local int i;
	
	CheckboxName = Left(CheckBoxID,12);

	if (CheckboxName == "Clan6_Check1")
	{
		CheckboxNum = Right(CheckBoxID,2);
		if (CheckboxNum == "00")
		{
			CheckedStat = class'UIAPI_CHECKBOX'.static.IsChecked(m_WindowName$".Clan6_Check100");
			
			switch (CheckedStat)
			{
				case true:
				//!전체 체크박스를 체크하는 함수
				for( i=0 ; i <= NUMOFOPTIONS_SYSTEM ; ++i )
					{
						if(i < 10)	class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan6_Check10" $ i, true );
						else		class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan6_Check1" $ i, true );						
					}
				break;
				case false:
				for( i=0 ; i <= NUMOFOPTIONS_SYSTEM ; ++i )
					{
						if( i< 10)	class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan6_Check10" $ i, false );
						else		class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan6_Check1" $ i, false );
					}
				break;
			}
		} 
		else
		{
			if (count_all_check("1",NUMOFOPTIONS_SYSTEM) == true) 
			{
				class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan6_Check100", true);
			}
			else
			{
				class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan6_Check100", false);
			}
		}
	}
	if (CheckboxName == "Clan6_Check2")
	{
		CheckboxNum = Right(CheckBoxID,2);
		if (CheckboxNum == "00")
		{
			CheckedStat = class'UIAPI_CHECKBOX'.static.IsChecked(m_WindowName$".Clan6_Check200");
			
			switch (CheckedStat)
			{
				case true:
				//!전체 체크박스를 체크하는 함수
				for( i=0 ; i <= NUMOFOPTIONS_AGIT ; ++i )
					{
						class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan6_Check20" $ i, true );
					}
				break;
				case false:
				for( i=0 ; i <= NUMOFOPTIONS_AGIT ; ++i )
					{
						class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan6_Check20" $ i, false );
					}
				break;
			}
		} 
		else
		{
			if (count_all_check("2",NUMOFOPTIONS_AGIT) == true) 
			{
				class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan6_Check200", true);
			}
			else
			{
				class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan6_Check200", false);
			}
		}
	}
	if (CheckboxName == "Clan6_Check3")
	{
		CheckboxNum = Right(CheckBoxID,2);
		if (CheckboxNum == "00")
		{
			CheckedStat = class'UIAPI_CHECKBOX'.static.IsChecked(m_WindowName$".Clan6_Check300");
			
			switch (CheckedStat)
			{
								case true:
				//!전체 체크박스를 체크하는 함수
				for( i=0 ; i <= NUMOFOPTIONS_CASTLE ; ++i )
					{

						class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan6_Check30" $ i, true );
					}
				break;
				case false:
				for( i=0 ; i <= NUMOFOPTIONS_CASTLE ; ++i )
					{
						class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan6_Check30" $ i, false );
					}
				break;
			}
		} 
		else
		{
			if (count_all_check("3",NUMOFOPTIONS_CASTLE) == true) 
			{
				class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan6_Check300", true);
			}
			else
			{
				class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan6_Check300", false);
			}
		}
	}
}

// check all the checkboxes are turned off coded by oxyzen
function bool count_all_check(string numString, int TotalNum)
{
	local bool checkall;
	local bool currentcheck;
	local int i;
	checkall = false;
	for (i=1; i<=TotalNum; ++i)
	{
		if( i < 10)		{currentcheck = class'UIAPI_CHECKBOX'.static.IsChecked(m_WindowName$".Clan6_Check" $ numString $ "0" $ i);}	//10개로 늘어나면서 바꾸었다.
		else			{currentcheck = class'UIAPI_CHECKBOX'.static.IsChecked(m_WindowName$".Clan6_Check" $ numString  $ i);}
		if (currentcheck == true)
		{
			checkall = true;
		}
	}
		
	return checkall;
}

//check all the checkboxes are turned off coded by oxyzen
function bool count_all_check2(string numString, int TotalNum)
{
	local bool checkall;
	local bool currentcheck;
	local int i;
	checkall = false;
	for (i=1; i<=TotalNum; ++i)
	{
		if(i < 10)	{currentcheck = class'UIAPI_CHECKBOX'.static.IsChecked(m_WindowName$".Clan2_Check" $ numString $"0" $ i);}		//10개로 늘어나면서 바꾸었다.
		else		{currentcheck = class'UIAPI_CHECKBOX'.static.IsChecked(m_WindowName$".Clan2_Check" $ numString  $ i);}
		if (currentcheck == true)
		{
			checkall = true;
		}
	}
	return checkall;
}

function OnEvent( int a_EventID, String a_Param )
{
	if (getInstanceL2Util().isClanV2()) return;

	switch( a_EventID )
	{
	case EV_ClanAuthGradeList:
		HandleClanAuthGradeList( a_Param );
		break;
	case EV_ClanWarList:
		HandleClanWarList( a_Param );
		break;
	case EV_ClanCrestChange:
		HandleCrestChange( a_Param );
	case EV_ClanMemberInfo:
		HandleClanMemberInfo( a_Param );
		break;
	//branch120516
	// TTP #55298 - gorillazin 12.07.04.
	case EV_ClanSkillList:
		HandleSkillList( a_Param );
		break;
	case EV_ClanSkillListRenew:
		HandleSkillList( a_Param );
		break;
	//end of branch
	//case EV_ClanSkillListAdd:
	//	HandleSkillListAdd( a_Param );
	//	break;
	case EV_ClanAuth:	// 등급에 대한 권한 정보
		HandleClanAuth( a_Param );
		break;
	case EV_ClanAuthMember:	// 혈원애 대한 권한 정보
		HandleClanAuthMember( a_Param );
		break;
	case EV_GamingStateExit:
		class'UIAPI_WINDOW'.static.HideWindow(m_WindowName);
		break;
	case EV_ClanClearWarList:
		HandleClearWarList( a_Param );
		break;

	case EV_DialogOK:
		 HandleDialogOK();
		 break;

	case EV_DialogCancel: 
		 break;
	default:
		break;
	}
}

/** 다이얼로그 ok 되었을때 처리 */
function HandleDialogOK ()
{
	local int dialogID;

	if( !DialogIsMine() )
	{
		return;
	}
	
	dialogID = DialogGetID();
	
	//  패배 선언을 할꺼다. 라고 ok를 한경우
	if( dialogID == DIALOG_AskLossClanWar)
	{
		
		RequestClanWarList(0, 0);			// 0 page
		SetStateAndShow("ClanWarManagementWndState");

		//RequestClanWithdrawWarWithClanName( currentLossWarClanName );
		RequestSurrenderPledgeWar(currentLossWarClanName);
	}
	//  전쟁철회 ok라고 한 경우
	else if(dialogID == DIALOG_AskClanWarCancel)
	{	
		HandleCancelWar1();
	}
	//전쟁철회버튼 비활성여부
	switchingWarCancelButton();
}


//	이벤트 핸들러
//	개별적인 이벤트를 처리하는 함수들은 Handle....() 형식의 이름을 가짐
function HandleClanAuthGradeList( String a_Param )
{
	local int count;
	local int id;
	local int members;
	local int i;
	local LVDataRecord	record;
	local LVData		data;
	
	record.LVDataList.Length = 2;
	class'UIAPI_LISTCTRL'.static.DeleteAllItem(m_WindowName$".Clan5_AuthListCtrl");
	//classic// class'UIAPI_LISTCTRL'.static.DeleteAllItem(m_WindowName$".Clan5_AuthListCtrl2");

	ParseInt( a_Param, "Count", count );
	for(i=0; i<5; ++i)
	{
		ParseInt( a_Param, "GradeID" $ i, id );
		ParseInt( a_Param, "GradeMemberCount" $ i, members );
		data.szData = GetStringByGradeID( id );
		record.LVDataList[0] = data;
		data.szData = string(members);
		record.LVDataList[1] = data;
		record.nReserved1 = id;
		class'UIAPI_LISTCTRL'.static.InsertRecord(m_WindowName$".Clan5_AuthListCtrl", record );
	}
	//classic//
	/*
	for(i=5; i<9; ++i)
	{
		ParseInt( a_Param, "GradeID" $ i, id );
		ParseInt( a_Param, "GradeMemberCount" $ i, members );
		data.szData = GetStringByGradeID( id );
		record.LVDataList[0] = data;
		data.szData = string(members);
		record.LVDataList[1] = data;
		record.nReserved1 = id;
		//classic// class'UIAPI_LISTCTRL'.static.InsertRecord(m_WindowName$".Clan5_AuthListCtrl2", record );
	}
*/
	class'UIAPI_LISTCTRL'.static.SetSelectedIndex( m_WindowName$".Clan5_AuthListCtrl", 0 ,true);
	//classic// class'UIAPI_LISTCTRL'.static.SetSelectedIndex( m_WindowName$".Clan5_AuthListCtrl2", 0 ,true);
}


// 460
// page=0 clanName="고양이" State=2 WarSituation=2 ProgressTimeInSec=44433
// 전쟁 점수로 바뀜 
function HandleClanWarList( String a_Param )
{	
	local LVDataRecord	record;
	local int page;
	
	// 클랜 이름 
	local string sClanName;

	//  0, 1, 2, 3 ,4, 5  (선포, 피선포, 전쟁중, 승리, 패배, 무승부)
	local int state;

	// 0, 1, 2, 3, 4  (매우열세, 열세, 대등, 우세. 매우우세) , 5(아무것도 아님)
	//local int warSituation;

	// 진행 시간 (초) 
	local int progressTimeInSec;

	local Color colorValue;
	
	// 전체 남은 시간 계산용
	local int totalWarSec;

	// 점수
	local int point;
	local int pointDiff;	
	local int leftKillCountOfEnemyToWar;
		
	ParseInt( a_Param, "Page", page );
	ParseString( a_Param, "ClanName", sClanName );
	
	ParseInt( a_Param, "State", state );
	ParseInt( a_Param, "ProgressTimeInSec", progressTimeInSec );

	ParseInt( a_Param, "Point", point);  //  혈맹전 점수
	ParseInt( a_Param, "PointDiff", pointDiff);  //  혈맹전 점수

	ParseInt( a_Param, "LeftKillCountOfEnemyToWar", leftKillCountOfEnemyToWar); // 피선포 시 전쟁까지 남은 선포 혈맹원 킬 횟수

	totalWarSec = (60 * 60 * 24) * 7;


	//ParseInt( a_Param, "WarSituation", warSituation );
	// 전쟁 상태에 따른 칼라값 변경
	/* 색깔 220, 220, 220 으로 통일
	if (state == 0) 	
	{
		// 전쟁선포시 3일로 부터 
		totalWarSec = (3 * (60 * 60 * 24));

		// 노랑
		colorValue.R = 255;
		colorValue.G = 180;
		colorValue.B = 0;
	}
	else if (state == 1) 	
	{
		totalWarSec = (3 * (60 * 60 * 24));
		// 하늘
		colorValue.R = 128;
		colorValue.G = 255;
		colorValue.B = 255;
	}
	else if (state == 2) 	
	{
		// 전쟁시작 21일..
		totalWarSec = (21 * (60 * 60 * 24));

		// 빨강
		colorValue.R = 220;
		colorValue.G = 70;
		colorValue.B = 50;
	}
	else if (state == 3) 	
	{
		// 주황
		colorValue.R = 220;
		colorValue.G = 120;
		colorValue.B = 0;

		// 전쟁상황이 아무것도 안나오게..
		//warSituation = 5;
	}
	else if (state == 4) 	
	{
		// 파랑
		colorValue.R = 110;
		colorValue.G = 140;
		colorValue.B = 170;

		// 전쟁상황이 아무것도 안나오게..
		//warSituation = 5;
	}
	else if (state == 5) 	
	{
		// 회색 (밝은)
		colorValue.R = 220;
		colorValue.G = 220;
		colorValue.B = 220;

		// 전쟁상황이 아무것도 안나오게..
		//warSituation = 5;
	}*/



	//  색깔 통일(220, 220, 220)
	colorValue.R = 220;
	colorValue.G = 220;
	colorValue.B = 220;

	//  혈맹 이름
	//  record.LVDataList 기존 6개 -> 7개로 한개 추가
	record.LVDataList.Length = 7;
	record.LVDataList[0].buseTextColor = True;
	record.LVDataList[0].szData = sClanName;
	record.LVDataList[0].TextColor = colorValue;

	// 선포 피선포 등등..
	record.LVDataList[1].buseTextColor = True;
	record.LVDataList[1].szData = getWarStateString( state );
	record.LVDataList[1].TextColor = colorValue;
	record.LVDataList[1].nReserved1 = state;

	// 최근 포인트 현황으로 전황 표시
	record.LVDataList[2].nReserved1 = getWarType( point );
	record.LVDataList[2].szData = "";	
	record.LVDataList[2].szTexture = getWarSituationTexture( point );
	record.LVDataList[2].nTextureWidth = 11;
	record.LVDataList[2].nTextureHeight = 11;
 	
	//  점수표시
	record.LVDataList[3].buseTextColor = True;
	record.LVDataList[3].szData = String(point);
	record.LVDataList[3].TextColor = colorValue;	
	record.LVDataList[3].nReserved1 = point;	
	
	//  최근 점수 변동
	record.LVDataList[4].nReserved1 = pointDiff;
	

	//  피 선포시 전쟁까지 남은 선포 킬 횟수
	record.LVDataList[5].nReserved1 = leftKillCountOfEnemyToWar;
	//  남은 시간
	record.LVDataList[6].nReserved1 = totalWarSec - progressTimeInSec;
	
	/*
	 *record.LVDataList[2].nReserved1 = warSituation;
	record.LVDataList[2].szData = "";	
	record.LVDataList[2].szTexture = getWarSituationTexture( warSituation );
	record.LVDataList[2].nTextureWidth = 11;
	record.LVDataList[2].nTextureHeight = 11;
 	
	record.LVDataList[3].buseTextColor = True;
	
	
	if(point <= 0)
	{
		record.LVDataList[3].szData = "-";
	}
	else
	{
		
	}*/
	
	

	m_clanWarListPage = page;

	// 남은 시간 중앙 정렬 테스트..
	m_hClanDrawerWndClan8_DeclaredListCtrl.SetHeaderAlignment(0, TA_CENTER);
	m_hClanDrawerWndClan8_DeclaredListCtrl.SetHeaderAlignment(1, TA_CENTER);
	m_hClanDrawerWndClan8_DeclaredListCtrl.SetHeaderAlignment(2, TA_CENTER);
	m_hClanDrawerWndClan8_DeclaredListCtrl.SetHeaderAlignment(3, TA_CENTER);
		
	class'UIAPI_LISTCTRL'.static.InsertRecord(m_WindowName$".Clan8_DeclaredListCtrl", record);
	
	//전쟁철회버튼 비활성 여부
	switchingWarCancelButton();
	
	/*
	if( type == 0 || type == 2 )
	{
		// m_hClanDrawerWndClanWarTabCtrl.SetTopOrder(0, true);
		class'UIAPI_LISTCTRL'.static.InsertRecord(m_WindowName$".Clan8_DeclaredListCtrl", record);
	}
	else
	{
		// m_hClanDrawerWndClanWarTabCtrl.SetTopOrder(1, true);
		
		class'UIAPI_LISTCTRL'.static.InsertRecord(m_WindowName$".Clan8_GotDeclaredListCtrl", record);
	}
	
	// 승,패인 상태 [남은 시간 처리] (하루 동일 보일때)
	if (progressTimeInSec <= 0)
	{
		record.LVDataList[3].szData = "-";
	}
	else 
	{
		record.LVDataList[3].szData = getSecToDateStr(totalWarSec - progressTimeInSec, false);	
	}
	
	
	
	*/
	// debug("getWarSituationTexture( warSituation )" @ getWarSituationTexture( warSituation ));
	// 1109 일 
	// Debug("선포 : " @ a_Param);
}

//전쟁철회 활성화비활성화
function switchingWarCancelButton()
{
	local int len;
	len = m_hClanDrawerWndClan8_DeclaredListCtrl.GetRecordCount();
	
	if(len > 0)	
		class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName $ ".Clan8_CancelWar1Btn");
	
	else 
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName $ ".Clan8_CancelWar1Btn");
}

/**
 *  0, 1, 2 (선포, 피선포, 전쟁중, 승리, 패배),4,5 (승리 , 패배)
 **/
function string getWarStateString( int state )
{
	if( state == 0 )
		return GetSystemString( 2349 );	// 선포
	else if( state == 1 ) 
		return GetSystemString( 2350 ); // 피선포
	else if( state == 2 ) 
		return GetSystemString( 340 );  // 전쟁중
	else if( state == 3 ) 
		return GetSystemString( 828 );  // 승리
	else if( state == 4 ) 
		return GetSystemString( 2356 ); // 패배
	else if( state == 5 ) 
		return GetSystemString( 846 ); // 무승부


	/*
	 *
	 ct3 에서 삭제 됨. (UI기획: 조희영, 담당컨텐츠 기획:황석윤)
	else if( state == 2 )
		return GetSystemString( 1367 ); //쌍방선포
	*/
	return "Error";
}

/**
 * 전쟁 상태에 따른 스트링 리턴 
 * 0, 1, 2 , 3, 4  (매우열세, 열세, 대응, 우세, 매우강세)
 **/
function string getWarSituationString(int pointDiff)
{
	local string returnStr;
	
	returnStr = "(";

	switch (getWarType(pointDiff))
	{
		case 0 : returnStr = returnStr $ GetSystemString(2355); break;
		case 1 : returnStr = returnStr $ GetSystemString(2354); break;
		case 2 : returnStr = returnStr $ GetSystemString(2353); break;
		case 3 : returnStr = returnStr $ GetSystemString(2352); break;
		case 4 : returnStr = returnStr $ GetSystemString(2351); break;

	}

	returnStr = returnStr $ ")";

	return returnStr;
}

/**
 * 타입으로 화살표 아이콘 표시
 **/
function string getWarSituationTexture(int pointDiff)
{
	local string returnStr;

	switch (getWarType(pointDiff))
	{
		case 0 : returnStr = "L2ui_ct1.clan_DF_warlist_arrow5"; break;
		case 1 : returnStr = "L2ui_ct1.clan_DF_warlist_arrow4"; break;
		case 2 : returnStr = "L2ui_ct1.clan_DF_warlist_arrow3"; break;
		case 3 : returnStr = "L2ui_ct1.clan_DF_warlist_arrow2"; break;
		case 4 : returnStr = "L2ui_ct1.clan_DF_warlist_arrow1"; break;
	}

	return returnStr;
}


//  값으로 타입 리턴
function int getWarType(int value)
{
	local int num;

	if(value <= -50) { num = 0; }
	else if(value > -50 && value <= -20) { num = 1; }
	else if(value > -20 && value <= 19) { num = 2; }
	else if(value > 19 && value <= 49) { num = 3; }
	else if(value >= 50) { num = 4; }

	return num;
}

	

/**
 * 초를 넣어서 1일/11:33 같은 스트링 타입으로 반환
 **/
function string getSecToDateStr(int sec, bool onlyDayFlag)
{
	// 86400
	// 1109
	local string returnStr;
	local int remainSec;
	local int m_timeDay;
	local int m_timeHour;
	local int m_timeMin;

	// (일 day)
	m_timeDay = sec / 86400;
	remainSec = sec % 86400;
	
	m_timeHour = (remainSec / 60 / 60);		// 시
	m_timeMin = (remainSec / 60) % 60;		// 분
	// m_timeSec = remainSec % 60;	// 초

	// debug(" m_timeHour : " $ m_timeHour $ "m_timeMin : "  $ m_timeMin$ "m_timeSec : "  $ m_timeSec);	
	returnStr = "";
	if (m_timeDay > 0)
	{
		returnStr = String(m_timeDay) $ GetSystemString(1109); // $ "/";
	}

	if (onlyDayFlag == false)
	{
		// 일 day 이 없다면 / 을 해주지 않는다. 
		if (returnStr != "") returnStr = returnStr $ "/";

		// 시를 그려준다.
		if(m_timeHour > 0)
		{
			if (m_timeHour < 10 ) returnStr = returnStr $ "0" $ string( m_timeHour );
			else returnStr = returnStr $ string( m_timeHour );
		}
		else
		{
			returnStr = returnStr $ "/00";
		}

		// 분
		if(m_timeMin > 0)
		{
			if (m_timeMin < 10 ) returnStr =  returnStr $ ":0" $ string( m_timeMin );
			else returnStr = returnStr $ ":" $ string( m_timeMin );
		}
		else
		{
			returnStr = returnStr $ ":00";
		}
	}

	return returnStr;

}

function HandleClanMemberInfo( String a_Param )
{
	local string nickName;
	local int gradeID;
	local string organization;
	local string masterName;		// empty if not exists
	
	local string organizationtext;	

	ParseInt( a_Param, "ClanType", m_clanType );
	ParseString( a_Param, "Name", m_currentName );
	ParseString( a_Param, "NickName", nickName );
	ParseInt( a_Param, "GradeID", gradeID );
	ParseString( a_Param, "OrderName", organization );
	ParseString( a_Param, "MasterName", MasterName );

	currentMasterName = masterName;
	//debug("d:"$currentMasterName);
	if (masterName == "")
	{
		masterName = GetSystemString(27);
	}
	//oxyzen
	organizationtext = getClanOrderString( m_clanType )@"-"@organization;
	
	class'UIAPI_TEXTBOX'.static.SetText(m_WindowName$".Clan1_CurrentSelectedMemberName", m_currentName );
	class'UIAPI_TEXTBOX'.static.SetText(m_WindowName$".Clan1_CurrentSelectedMemberSName", nickName);
	class'UIAPI_TEXTBOX'.static.SetText(m_WindowName$".Clan1_CurrentSelectedMemberGrade", GetStringByGradeID(gradeID));
	class'UIAPI_TEXTBOX'.static.SetText(m_WindowName$".Clan1_CurrentSelectedMemberOrderName", organizationtext);
	//classic// class'UIAPI_TEXTBOX'.static.SetText(m_WindowName$".Clan1_CurrentSelectedApprentice", masterName);
		
	if (clanWndClassicScript.m_CurrentclanMasterReal == m_currentName)
	{
		if (clanWndClassicScript.m_currentShowIndex == 0)
		{
			class'UIAPI_TEXTBOX'.static.SetText(m_WindowName$".Clan1_CurrentSelectedMemberGrade",GetSystemString(342));
		} 
	}
	

	/*
	// pledgeType에 따라 "후견인", "제자"로 텍스트를 바꿔 줘야함
	if ( m_clanType == CLAN_ACADEMY )
	{
		//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_AssignApprenticeBtn");
		//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_DeleteApprenticeBtn");
		class'UIAPI_TEXTBOX'.static.SetText(m_WindowName$".Clan1_CurrentSelectedApprenticeTitle", GetSystemString( 1332 ) );
	}
	else
	{
		//classic// class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName$".Clan1_AssignApprenticeBtn");
		//classic// class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName$".Clan1_DeleteApprenticeBtn");
			
					if (currentMasterName != "")
			{
				//Debug("PressDel");
				//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_AssignApprenticeBtn");
				//classic// class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName$".Clan1_DeleteApprenticeBtn");
			}
			else
			{
				//Debug("PressName");
				//classic// class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName$".Clan1_AssignApprenticeBtn");
				//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_DeleteApprenticeBtn");
			}

		class'UIAPI_TEXTBOX'.static.SetText(m_WindowName$".Clan1_CurrentSelectedApprenticeTitle", GetSystemString( 1431 ) );

	}
	*/
	
	clanWndClassicScript.resetBtnShowHide();
	CheckandCompareMyNameandDisableThings();
}

//권환 봐서 창 디스에이블 시키기 oxyzen
function CheckandCompareMyNameandDisableThings()
{
	
	local UserInfo userinfo;
	//userinfo = GetUser();
	GetPlayerInfo( userinfo );
	m_myName = userinfo.Name;
	
	//debug("informme:" $ clanWndClassicScript.m_bOustMember);
	//혈맹주일경우 등급설정버튼 비활성화/혈원제명버튼 활성화
	if (clanWndClassicScript.m_bClanMaster > 0)
	{
		class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName$".Clan1_ChangeBanishBtn");
		//classic //class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName$".Clan1_ChangeMemberKHOpen");
			
		//classic// 
		/*
		if (currentMasterName != "")
		{
			//Debug("PressDel");
			//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_AssignApprenticeBtn");
			//classic// class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName$".Clan1_DeleteApprenticeBtn");
			if (clanWndClassicScript.G_CurrentAlias == true)
			{
				//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_DeleteApprenticeBtn");
			}
		}
		else
		{
			//Debug("PressName");
			//classic// class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName$".Clan1_AssignApprenticeBtn");
			//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_DeleteApprenticeBtn");
		}
*/
	} 
	// 여기서부터는 혈맹주가 아닐경우
	else 
	{
		// 우선 등급설정부터 하고...
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_ChangeMemberGradeBtn");
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_ChangeBanishBtn");
		//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_ChangeMemberKHOpen");
		Proc_AuthValidation();
		// 자기보다 기사단 번호가 상위(실제숫자는 거꾸로...) 
		if (clanWndClassicScript.GetClanTypeFromIndex(clanWndClassicScript.m_currentShowIndex) <clanWndClassicScript.m_myClanType)
		{
			//Debug("EditAuth"@ clanWndClassicScript.GetClanTypeFromIndex( clanWndClassicScript.m_currentShowIndex) @ clanWndClassicScript.m_myClanType);
			class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_ChangeBanishBtn");
			class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_ChangeMemberGradeBtn");
			//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_AssignApprenticeBtn");
			//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_DeleteApprenticeBtn");
			if (m_clanType == CLAN_ACADEMY)
			{
			}
			else
			{
				class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_ChangeMemberNameBtn");
			}
		} 
		if (clanWndClassicScript.m_myClanType > 1)
		{
			if (clanWndClassicScript.GetClanTypeFromIndex(clanWndClassicScript.m_currentShowIndex) != 0)
			{
				if (clanWndClassicScript.m_myClanType -clanWndClassicScript.GetClanTypeFromIndex(clanWndClassicScript.m_currentShowIndex) == 1)
				{
					Proc_AuthValidation();
				}                                       
				if (clanWndClassicScript.m_myClanType -clanWndClassicScript.GetClanTypeFromIndex(clanWndClassicScript.m_currentShowIndex) == 1000)
				{
					Proc_AuthValidation();
				}
				if (clanWndClassicScript.m_myClanType -clanWndClassicScript.GetClanTypeFromIndex(clanWndClassicScript.m_currentShowIndex) == 100)
				{
					Proc_AuthValidation();
				}
				if (clanWndClassicScript.m_myClanType -clanWndClassicScript.GetClanTypeFromIndex(clanWndClassicScript.m_currentShowIndex) == 999)
				{
					Proc_AuthValidation();
				} 
				if (clanWndClassicScript.m_myClanType -clanWndClassicScript.GetClanTypeFromIndex(clanWndClassicScript.m_currentShowIndex) == 1001)
				{
					Proc_AuthValidation();
				} 
			}
		}
		if (clanWndClassicScript.G_CurrentAlias == true)
		{
			//Debug("EditAuth"@clanWndClassicScript.GetClanTypeFromIndex( clanWndClassicScript.m_currentShowIndex) @ clanWndClassicScript.m_myClanType);
			class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_ChangeBanishBtn");
			class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_ChangeMemberNameBtn");
			class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_ChangeMemberGradeBtn");
			//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_AssignApprenticeBtn");
			//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_DeleteApprenticeBtn");
			//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_ChangeMemberKHOpen");
		} 
		// 각 혈맹주의 권한은 편집 할 수 없음. - 다른 무엇보다 우선함.
		if (clanWndClassicScript.m_CurrentclanMasterReal == m_currentName)
		{
			class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_ChangeMemberGradeBtn");
			class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_ChangeBanishBtn");
			//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_AssignApprenticeBtn");
			//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_DeleteApprenticeBtn");
			class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_ChangeMemberNameBtn");
			//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_ChangeMemberKHOpen");
			
		}
	}
	// 자기 정보는 자기가 수정 할 수 없음.	
	if (m_currentName == m_myName)
	{
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_ChangeMemberGradeBtn");
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_ChangeBanishBtn");
		//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_ChangeMemberKHOpen");
	}
	//아카데미혈맹원에게는 그 누구도 권한을 지정할 수 없음. 
	if (m_clanType == CLAN_ACADEMY)
	{
		//debug("Academy");
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_ChangeMemberGradeBtn");
		//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_AssignApprenticeBtn");
		//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_DeleteApprenticeBtn");
	}
}
//실제 프로세스 부분
function Proc_AuthValidation()
{	
	if(clanWndClassicScript.m_bNickName == 0)
	{
		
		if (clanWndClassicScript.G_IamHero == true || clanWndClassicScript.G_IamNobless > 0) 
		{
			class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName$".Clan1_ChangeMemberNameBtn");	
		}
		else 
		{
			class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_ChangeMemberNameBtn");	
		}
	}
	else
	{
		class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName$".Clan1_ChangeMemberNameBtn");	
	}
	if(clanWndClassicScript.m_bGrade==0)
	{
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_ChangeMemberGradeBtn");
	}
	else
	{
		class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName$".Clan1_ChangeMemberGradeBtn");

	}
	//classic// 
	/*
	if(clanWndClassicScript.m_bManageMaster == 0)
	{
		//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_AssignApprenticeBtn");
		//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_DeleteApprenticeBtn");
	}
	else
	{
		if (currentMasterName != "")
		{
			//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_AssignApprenticeBtn");
			//classic// class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName$".Clan1_DeleteApprenticeBtn");
		}
		else
		{
			//classic// class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName$".Clan1_AssignApprenticeBtn");
			//classic// class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_DeleteApprenticeBtn");
		}
	}
*/
	if(clanWndClassicScript.m_bOustMember == 0)
	{
		class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_ChangeBanishBtn");
	}
	else
	{
		class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName$".Clan1_ChangeBanishBtn");			
	}
}

function HandleCrestChange( String param )
{	
	if( m_state == "ClanEmblemManageWndState" )
	{
	
		class'UIAPI_TEXTURECTRL'.static.SetTextureWithClanCrest( m_WindowName$".ClanCrestTextureCtrl", clanWndClassicScript.m_clanID );
	}
}

function HandleSkillList( String a_Param )
{
	local int count;
	local int i;
	local int level;
	local ItemID cID;
	
	ParseInt( a_Param, "Count", count );
	//debug("Count : " $ Count);
	for(i=0; i<count ; ++i)
	{
		ParseItemIDWithIndex( a_Param, cID, i );
		ParseInt( a_Param, "SkillLevel_" $ i, level );
		//findItemID = class'UIAPI_ITEMWINDOW'.static.FindItem(m_WindowName$".ClanSkillWnd", cID);
		//AgitText = class'UIAPI_TEXTBOX'.static.GetText("ClanWndClassic.ClanAgitText");
		//debug("AgitText : " $ AgitText);
		//debug("findItemID : " $ findItemID);
		//if(findItemID < 0 && InStr(GetSystemString( 27 ) ,AgitText ) < 0 )	//본거지 있을 경우에만 보여준다. 
		//{
			AddSkill( cID, level );
		//}

		//debug("cID : " $ cID.classID $ " level : " $ level );
	}
}

//function HandleSkillListAdd( String a_Param )
//{
//	local int level;
//	local int i;
//	local int count;
//	local ItemInfo info;
//	local ItemID cID;
//
//	ParseItemID( a_Param, cID );
//	ParseInt( a_Param, "SkillLevel", level );
//
//	count = class'UIAPI_ITEMWINDOW'.static.GetItemNum(m_WindowName$".ClanSkillWnd");
//	for( i=0 ; i < count ; ++i )
//	{
//		class'UIAPI_ITEMWINDOW'.static.GetItem(m_WindowName$".ClanSkillWnd", i, info);
//		if( IsSameClassID( info.ID, cID ) )	/// match found
//			break;
//	}
//	
//	if( i < count )	// match found
//	{
//		ReplaceSkill( i, cID, level );
//	}
//	else
//	{
//		AddSkill( cID, level );
//	}
//}

/**
 *  전쟁 패배 선언  	// 선포 창일때
 **/
function HandleDeclareLoseWar()
{
	local LVDataRecord record;
	local int index;
	index = class'UIAPI_LISTCTRL'.static.GetSelectedIndex(m_WindowName$".Clan8_DeclaredListCtrl");

	if( index >= 0 )
	{
		m_hClanDrawerWndClan8_DeclaredListCtrl.GetRec(index, record);
		//debug ("record.LVDataList[0].szData " @record.LVDataList[0].szData );
		// debug("패배 선언 :" @ record.LVDataList[0].szData);

		currentLossWarClanName = record.LVDataList[0].szData;
		DialogSetID( DIALOG_AskLossClanWar );
		
		// 누구누구 혈맹이랑 혈맹 전쟁 패배를 신청 합니까? 뭐 이런 맨트..
		DialogShow(DialogModalType_Modalless, DialogType_OKCancel, MakeFullSystemMsg( GetSystemMessage(3409), record.LVDataList[0].szData), string(Self) );			
		
	}
}

/** 
 *  이미 전쟁을 선포 하였나를 체크 
 *  피 선포 (한쪽에서 전쟁을 선포한 경우)
 *  
 **/
function bool searchClanWarDeclare(string clanName)
{
	local LVDataRecord record;
	local int i, maxRec;
	local bool bCheck;
	//index = class'UIAPI_LISTCTRL'.static.GetSelectedIndex(m_WindowName$".Clan8_DeclaredListCtrl");

	bCheck = false;
	maxRec = m_hClanDrawerWndClan8_DeclaredListCtrl.GetRecordCount();

	for (i = 0; i < maxRec; i++)
	{
		m_hClanDrawerWndClan8_DeclaredListCtrl.GetRec(i, record);
		// debug ("record.LVDataList[0].szData " @record.LVDataList[0].szData );
		// debug("선언 :" @ record.LVDataList[0].szData);
		// debug("선언 :" @ record.LVDataList[1].szData);
		// debug("선언 :" @ record.LVDataList[1].nReserved1);
		
		if (record.LVDataList[0].szData == clanName)
		{
			if (record.LVDataList[1].nReserved1 == 1)
			{
				bCheck = true;
				break;
			}
		}		
		
	}

	return bCheck;
}


function HandleCancelWar1()			// 선포 창일때
{
	local LVDataRecord record;
	local int index;
	index = class'UIAPI_LISTCTRL'.static.GetSelectedIndex(m_WindowName$".Clan8_DeclaredListCtrl");

	if( index >= 0 )
	{
		m_hClanDrawerWndClan8_DeclaredListCtrl.GetRec(index, record);
		// debug ("record.LVDataList[0].szData " @record.LVDataList[0].szData );
		RequestClanWithdrawWarWithClanName( record.LVDataList[0].szData );
		//debug("HandleCancelWar1 " $ record.LVDataList[0].szData );
		RequestClanWarList(0, 0);			// 0 page
		SetStateAndShow("ClanWarManagementWndState");
	}
}

function HandleDeclareWar()	
{
	local LVDataRecord record;
	local int index;
	index = m_hClanDrawerWndClan8_GotDeclaredListCtrl.GetSelectedIndex();

	if( index >= 0 )
	{
		m_hClanDrawerWndClan8_GotDeclaredListCtrl.GetRec(index, record);
		RequestClanDeclareWarWithClanName( record.LVDataList[0].szData );
		RequestClanWarList( m_clanWarListPage, 1 );
		
	}
}

function HandleCancelWar2()		// 피선포 창일 때
{
	local LVDataRecord record;
	local int index;
	index = m_hClanDrawerWndClan8_GotDeclaredListCtrl.GetSelectedIndex();

	if( index >= 0 )
	{
		m_hClanDrawerWndClan8_GotDeclaredListCtrl.GetRec(index, record);
		RequestClanWithdrawWarWithClanName( record.LVDataList[0].szData );
		RequestClanWarList( m_clanWarListPage, 1 );
		//m_hClanDrawerWndClanWarTabCtrl.SetTopOrder(1, true);
		class'UIAPI_WINDOW'.static.ShowWindow(m_WindowName$".ClanWarManagementWnd");
		
	}
}

function HandleClanAuth( String a_Param )		// 권한 등급 처리
{
	local int gradeID;
	local int command;
	local array<int> powers;
	local int i;
	local int index;

	ParseInt( a_Param, "GradeID", gradeID );
	ParseInt( a_Param, "Command", command );

	powers.Length = 32;
	for( i = 0; i < 32 ; ++i )
	{
		ParseInt( a_Param, "PowerValue" $ i, powers[ i ] );
	}

	class'UIAPI_TEXTBOX'.static.SetText(m_WindowName$".Clan6_CurrentSelectedRankName", GetStringByGradeID( gradeID ) $ GetSystemString(1376) );

	index = 1;
	for( i=1 ; i <= NUMOFOPTIONS_SYSTEM ; ++i )	// 비행정 관련 수정
	{			
		if(i < 10) class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan6_Check10" $ i, bool( powers[index++] ) );
		else class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan6_Check1" $ i, bool( powers[index++] ) );
	}

	for( i=1; i <= NUMOFOPTIONS_AGIT ; ++i )
	{
		class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan6_Check20" $ i, bool( powers[index++] ) );
	}

	for( i=1; i <= NUMOFOPTIONS_CASTLE ; ++i )
	{
		class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan6_Check30" $ i, bool( powers[index++] ) );
	}
	
	if (count_all_check("1", NUMOFOPTIONS_SYSTEM) == true)
	{
		class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan6_Check100", true);
	} else {
		class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan6_Check100", false);
	}
	if (count_all_check("2", NUMOFOPTIONS_AGIT) == true)
	{
		class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan6_Check200", true);
	} else {
		class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan6_Check200", false);
	}
	if (count_all_check("3", NUMOFOPTIONS_CASTLE) == true)
	{
		class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan6_Check300", true);
	} else {
		class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan6_Check300", false);
	}

	if ( gradeID == CLAN_AUTH_GRADE9)
	{
		//debug("I have done1");
		disableAcademyAuth();
	} 
	else
	{
		resetAcademyAuth();
	}
	
}

function HandleClanAuthMember( String a_Param )	// 혈원 권한
{	
	
	local int gradeID;
	local string sName;
	local array<int> powers;
	local int i;
	local int index;


	ParseInt( a_Param, "Grade", gradeID );
	ParseString( a_Param, "Name", sName );

	powers.Length = 32;
	for( i = 0; i < 32 ; ++i )
	{
		ParseInt( a_Param, "PowerValue" $ i, powers[ i ] );
	}

	class'UIAPI_TEXTBOX'.static.SetText(m_WindowName$".Clan2_CurrentSelectedMemberName", sName @ "-" @ GetStringByGradeID( gradeID ));
	
	index = 1;
	for( i=1 ; i <= NUMOFOPTIONS_SYSTEM ; ++i )	// 비행정 관련 수정 - CT2_Final
	{
		if(i < 10) class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan2_Check10" $ i, bool( powers[index++] ) );
		else class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan2_Check1" $ i, bool( powers[index++] ) );
	}

	for( i=1; i <= NUMOFOPTIONS_AGIT ; ++i )
	{
		class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan2_Check20" $ i, bool( powers[index++] ) );
	}

	for( i=1; i <= NUMOFOPTIONS_CASTLE ; ++i )
	{
		class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan2_Check30" $ i, bool( powers[index++] ) );
	}
	
	if (count_all_check2("1", NUMOFOPTIONS_SYSTEM) == true)	// 비행정 관련 수정 - CT2_Final
	{
		class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan2_Check100", true);
	} else {
		class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan2_Check100", false);
	}
	if (count_all_check2("2", NUMOFOPTIONS_AGIT) == true)
	{
		class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan2_Check200", true);
	} else {
		class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan2_Check200", false);
	}
	if (count_all_check2("3", NUMOFOPTIONS_CASTLE) == true)
	{
		class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan2_Check300", true);
	} else {
		class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan2_Check300", false);
	}

	//서버에서 온데이터가 자신의 정보일 경우 자신의 혈맹 본창을 리프레시
	if (clanWndClassicScript.m_myName == sName)
	{
		//가입권유
		if (class'UIAPI_CHECKBOX'.static.IsChecked(m_WindowName$".Clan2_Check101") == true)
		{
			clanWndClassicScript.m_bJoin = 1;
		}
		else
		{
			clanWndClassicScript.m_bJoin = 0;
		}
		if (class'UIAPI_CHECKBOX'.static.IsChecked(m_WindowName$".Clan2_Check107") == true)
		{
			clanWndClassicScript.m_bCrest = 1;
		}	
		else
		{
			clanWndClassicScript.m_bCrest = 0;
		}
		if (class'UIAPI_CHECKBOX'.static.IsChecked(m_WindowName$".Clan2_Check105") == true)
		{
			clanWndClassicScript.m_bWar = 1;
		}	
		else
		{
			clanWndClassicScript.m_bWar = 0;
		}
	clanWndClassicScript.resetBtnShowHide();
	//clanWndClassicScript.m_bCrest = 1;
	//clanWndClassicScript.m_bWar = 1;
	//clanWndClassicScript.m_bGrade = 1;
	//clanWndClassicScript.m_bManageMaster = 1;
	//clanWndClassicScript.m_bOustMember =1;
	}
		// 혈맹주 예외 처리 혈맹주만 모두 트루를 집어 넣어 줌.
	if (clanWndClassicScript.m_CurrentclanMasterReal == sName)
	{
		//문춘식
		//debug("iamRunning:" @  clanWndClassicScript.m_CurrentclanMasterName @ sName);
		class'UIAPI_TEXTBOX'.static.SetText(m_WindowName$".Clan2_CurrentSelectedMemberName", sName @ "-" @ GetSystemString(342));
		for( i=0 ; i <= NUMOFOPTIONS_SYSTEM ; ++i )	// 비행정 관련 수정 - CT2_Final
		{
			if( i < 10)	class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan2_Check10" $ i, true );
			else 	class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan2_Check1" $ i, true );
		}
	
		for( i=0; i <= NUMOFOPTIONS_AGIT ; ++i )
		{
			class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan2_Check20" $ i, true );
		}
	
		for( i=0; i <= NUMOFOPTIONS_CASTLE ; ++i )
		{
			class'UIAPI_CHECKBOX'.static.SetCheck(m_WindowName$".Clan2_Check30" $ i, true );
		}
	}
	
}

function HandleClearWarList( String a_Param )
{
	// local int condition;

	class'UIAPI_LISTCTRL'.static.DeleteAllItem(m_WindowName$".Clan8_DeclaredListCtrl");
	switchingWarCancelButton();
	/*
	if( ParseInt( a_Param, "Condition", condition ) )
	{
		if( condition == 0 )
			
		else
			class'UIAPI_LISTCTRL'.static.DeleteAllItem(m_WindowName$".Clan8_GotDeclaredListCtrl");
	}
	*/
}

//
//	이벤트 핸들러 - END
//


// 등급을 넣으면 그에 맞는 시스템 스트링을 돌려준다
function string GetStringByGradeID( int gradeID )
{
	local int stringIndex;
	stringIndex = -1;
	
	//~ debug("gradeID" @ gradeID);
	
	if( gradeID == CLAN_AUTH_GRADE1 )
		stringIndex = 1406;
	else if( gradeID == CLAN_AUTH_GRADE2 )
		stringIndex = 1407;
	else if( gradeID == CLAN_AUTH_GRADE3 )
		stringIndex = 1408;
	else if( gradeID == CLAN_AUTH_GRADE4 )
		stringIndex = 1409;
	else if( gradeID == CLAN_AUTH_GRADE5 )
		stringIndex = 1410;
	else if( gradeID == CLAN_AUTH_GRADE6 )
		stringIndex = 1411;
	else if( gradeID == CLAN_AUTH_GRADE7 )
		stringIndex = 1412;
	else if( gradeID == CLAN_AUTH_GRADE8 )
		stringIndex = 1413;
	else if( gradeID == CLAN_AUTH_GRADE9 )
		stringIndex = 1414;

	if( stringIndex != -1 )
		return GetSystemString( stringIndex );
	else 
		return "";

}

// 제자 선임을 위해서 아카데미 혈맹원만을 가져와 리스트 컨트롤에 추가한다
/*//classic//
function InitializeAcademyList()
{
	
	local int i;
	local LVDataRecord record;
	record.LVDataList.Length = 3;
	
	//InitializeClan1_AssignApprenticeList();
	for( i=0 ; i < clanWndClassicScript.m_memberList[ clanWndClassicScript.GetIndexFromType( CLAN_ACADEMY ) ].m_array.Length ; ++i )
	{
		//후견인이 있는 아카데미원은 삽입하지 않는다.
		if (  clanWndClassicScript.m_memberList[ clanWndClassicScript.GetIndexFromType( CLAN_ACADEMY ) ].m_array[i].bHaveMaster == 0 )	
		{
			record.LVDataList[0].szData = clanWndClassicScript.m_memberList[ clanWndClassicScript.GetIndexFromType( CLAN_ACADEMY ) ].m_array[i].sName;
			record.LVDataList[1].szData = string(clanWndClassicScript.m_memberList[ clanWndClassicScript.GetIndexFromType( CLAN_ACADEMY ) ].m_array[i].level);
			record.nReserved1 = clanWndClassicScript.m_memberList[ clanWndClassicScript.GetIndexFromType( CLAN_ACADEMY ) ].m_array[i].clanType;		// for additional information
			record.LVDataList[2].szData = string( clanWndClassicScript.m_memberList[ clanWndClassicScript.GetIndexFromType( CLAN_ACADEMY ) ].m_array[i].classID );
			record.LVDataList[2].szTexture = GetClassRoleIconName(clanWndClassicScript.m_memberList[ clanWndClassicScript.GetIndexFromType( CLAN_ACADEMY ) ].m_array[i].classID);
			record.LVDataList[2].nTextureWidth = 11;
			record.LVDataList[2].nTextureHeight = 11;
			class'UIAPI_LISTCTRL'.static.InsertRecord( m_WindowName$".Clan1_AssignApprenticeList", record );
		}
	}
}
*/

/*
function InitializeClan1_AssignApprenticeList()
{
	class'UIAPI_LISTCTRL'.static.DeleteAllItem( m_WindowName$".Clan1_AssignApprenticeList" );
}
*/

// 혈맹 정보창 초기화
function InitializeClanInfoWnd()
{
	local Color Blue;
	local Color Red;
	local Color DarkYellow;
	
	local SkillTrainClanTreeWnd script2;
	local int i;
	local string ClanNameVal;
	local string ClanRankStr;
	local string tooltip;
	local int	clanType;
	
	Blue.R = 126;
	Blue.G = 158;
	Blue.B = 245;
	Red.R = 200;
	Red.G = 50;
	Red.B = 80;
	DarkYellow.R =175;
	DarkYellow.G =152;
	DarkYellow.B =120;
	
	
	script2 = SkillTrainClanTreeWnd( GetScript("SkillTrainClanTreeWnd") );
	ClanNameVal = clanWndClassicScript.m_clanNameValue @ GetSystemString(1442);
	
	// 하이라이트 된 것이 있다면 지워준다. 
	//classic// 
	/*
	if(ClanClickedID>0 && Clan3_OrgHighLight[ClanClickedID-1].isShowWindow()) Clan3_OrgHighLight[ClanClickedID-1].HideWindow();
*/
//classic// 	ClanClickedID = -1;	// 클릭된 것이 없도록 한다. 

	
	// reset all 
	//classic// 
	//reset_clan_org();
	
	if (clanWndClassicScript.m_clanRank == 0)
	{
		ClanRankStr = GetSystemString(1374);
	}
	else if (clanWndClassicScript.m_clanRank <= c_maxranklimit)
	{
		ClanRankStr = clanWndClassicScript.m_clanRank @ GetSystemString(1375);
	}
	else 
	{
		ClanRankStr = GetSystemString(1374);
	}
	class'UIAPI_TEXTBOX'.static.SetText(m_WindowName$".Clan3_ClanName", clanWndClassicScript.m_clanName );
	class'UIAPI_TEXTBOX'.static.SetText(m_WindowName$".Clan3_ClanPoint", ClanNameVal );
	
	if (clanWndClassicScript.m_clanNameValue == 0)
	{
		class'UIAPI_TEXTBOX'.static.SetTextColor(m_WindowName$".Clan3_ClanPoint", DarkYellow );
	}
	else if (clanWndClassicScript.m_clanNameValue < 0)
	{
		class'UIAPI_TEXTBOX'.static.SetTextColor(m_WindowName$".Clan3_ClanPoint", Red );
	}
	else if (clanWndClassicScript.m_clanNameValue > 0)
	{
		class'UIAPI_TEXTBOX'.static.SetTextColor(m_WindowName$".Clan3_ClanPoint", Blue );
	}
	
	class'UIAPI_TEXTBOX'.static.SetText(m_WindowName$".Clan3_ClanRanking", ClanRankStr );

	for( i=0 ; i < CLAN_KNIGHTHOOD_COUNT ; ++i )
	{
		if( clanWndClassicScript.m_memberList[i].m_sName != "" )
		{
			clanType = clanWndClassicScript.GetClanTypeFromIndex(i);
			if( clanType == CLAN_MAIN )
			{
				tooltip = clanWndClassicScript.m_memberList[i].m_sName $ "\\n" $ GetSystemString(342) $ " : " $ clanWndClassicScript.m_memberList[i].m_sMasterName;
			}
			if( clanType == CLAN_ACADEMY )
			{
				tooltip = clanWndClassicScript.m_memberList[i].m_sName;
			}
			if( clanType == CLAN_KNIGHT1 || clanType == CLAN_KNIGHT2 )		// 근위대
			{
				tooltip = clanWndClassicScript.m_memberList[i].m_sName $ "\\n" $ GetSystemString(1438) $ " : " $ clanWndClassicScript.m_memberList[i].m_sMasterName;
			}
			if( clanType == CLAN_KNIGHT3 || clanType == CLAN_KNIGHT4 || clanType == CLAN_KNIGHT5 || clanType == CLAN_KNIGHT6 )
			{
				tooltip = clanWndClassicScript.m_memberList[i].m_sName $ "\\n" $ GetSystemString(1433) $ " : " $ clanWndClassicScript.m_memberList[i].m_sMasterName;
			}
			if (tooltip != "")
			{
				//classic// Clan3_OrgIcon[i].ShowWindow();
				//classic// Clan3_OrgIcon[i].EnableWindow();
				//classic// Clan3_OrgIcon[i].SetTooltipCustomType(SetTooltip(tooltip));
				//classic// script2.Clan_OrgIcon[i].ShowWindow();
				//script2.Clan_OrgIcon[i].EnableWindow();
				//classic// script2.Clan_OrgIcon[i].SetTooltipCustomType(SetTooltip(tooltip));
			}
		}
	}
}


function InitializeGradeComboBox()
{
	local int i;
	class'UIAPI_COMBOBOX'.static.Clear(m_WindowName$".Clan1_MemberGradeList");

	for( i = CLAN_AUTH_GRADE1 ; i < CLAN_AUTH_GRADE6; ++i )
	{
		class'UIAPI_COMBOBOX'.static.AddString(m_WindowName$".Clan1_MemberGradeList", GetStringByGradeID( i ) );
	}
	
	class'UIAPI_COMBOBOX'.static.AddString(m_WindowName$".Clan1_MemberGradeList", GetSystemString(1451) );
}

function KnighthoodCombobox()
{	
	local int i;
	

	class'UIAPI_COMBOBOX'.static.Clear(m_WindowName$".Clan1_targetknighthoodcombobox");
	class'UIAPI_COMBOBOX'.static.Clear(m_WindowName$".Clan1_targetknighthoodmember");
		
	class'UIAPI_COMBOBOX'.static.AddStringWithReserved(m_WindowName$".Clan1_targetknighthoodcombobox", GetSystemString(1465), 0);
	class'UIAPI_COMBOBOX'.static.AddStringWithReserved(m_WindowName$".Clan1_targetknighthoodmember", GetSystemString(1466), 0);

	class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_targetknighthoodmember");
	class'UIAPI_WINDOW'.static.DisableWindow(m_WindowName$".Clan1_ChangeMemberKnightHoodBtn");

	class'UIAPI_TEXTBOX'.static.SetText( m_WindowName$".Clan1_ChangeMemberKnightHoodTXT1", MakeFullSystemMsg(GetSystemMessage(1906), m_currentName, ""));
	
	for( i=0 ; i < clanWndClassicScript.CLAN_KNIGHTHOOD_COUNT ; ++i )
	{
		if( clanWndClassicScript.m_memberList[i].m_sName != "" )
		{
			if (clanWndClassicScript.GetClanTypeFromIndex(i) != CLAN_ACADEMY)
			{
				class'UIAPI_COMBOBOX'.static.AddStringWithReserved(m_WindowName$".Clan1_targetknighthoodcombobox", clanWndClassicScript.m_memberList[i].m_sName, i);
			}
		}
	}
	
	class'UIAPI_COMBOBOX'.static.SetSelectedNum(m_WindowName$".Clan1_targetknighthoodcombobox",0);
	
}


function swapTargetSelect(int clanNo)
{	
	local int i;
	

	class'UIAPI_COMBOBOX'.static.Clear(m_WindowName$".Clan1_targetknighthoodmember");
	class'UIAPI_COMBOBOX'.static.AddStringWithReserved(m_WindowName$".Clan1_targetknighthoodmember", GetSystemString(1466), 0);
	class'UIAPI_TEXTBOX'.static.SetText( m_WindowName$".Clan1_ChangeMemberKnightHoodTXT1", MakeFullSystemMsg(GetSystemMessage(1907), m_currentName, ""));
	
	for( i=0 ; i <= clanWndClassicScript.m_memberList[ clanNo ].m_array.Length ; ++i )
	{
		if ( clanWndClassicScript.m_memberList[ clanNo ].m_array[i].sName != clanWndClassicScript.m_CurrentclanMasterReal)
		class'UIAPI_COMBOBOX'.static.AddStringWithReserved(m_WindowName$".Clan1_targetknighthoodmember", clanWndClassicScript.m_memberList[ clanNo ].m_array[i].sName, clanWndClassicScript.m_memberList[ clanNo ].m_array[i].clanType);
	}
	class'UIAPI_COMBOBOX'.static.SetSelectedNum(m_WindowName$".Clan1_targetknighthoodmember",0);
	
}

function proc_swapmember()
{
	
	local int currentindexnew1;
	local int currentindexnew2;
	local string currentstring1; 
	local string currentstring2; 
	local int type;
	local int clantype1;
	//local int clantype2;
	
	
	
	currentindexnew1 = class'UIAPI_COMBOBOX'.static.GetSelectedNum(m_WindowName$".Clan1_targetknighthoodcombobox");
	currentstring1 = class'UIAPI_COMBOBOX'.static.GetString(m_WindowName$".Clan1_targetknighthoodcombobox", currentindexnew1);
	clantype1 = clanWndClassicScript.GetClanTypeFromIndex(class'UIAPI_COMBOBOX'.static.GetReserved(m_WindowName$".Clan1_targetknighthoodcombobox", currentindexnew1));
	
	currentindexnew2 = class'UIAPI_COMBOBOX'.static.GetSelectedNum(m_WindowName$".Clan1_targetknighthoodmember");
	currentstring2 = class'UIAPI_COMBOBOX'.static.GetString(m_WindowName$".Clan1_targetknighthoodmember", currentindexnew2);

		
	//debug(currentstring1 @ currentstring2);
	
	if (currentindexnew2 == 0)
	{
		type = 0;
	}
	else 
	{
		type = 1;
	}
	
	if (type == 1)
	{
		//debug("멤버교체");
		RequestClanReorganizeMember( 1, m_currentName, clantype1, currentstring2);
	}
	else if (type == 0)
	{
		//debug("멤버이동이얌");
		RequestClanReorganizeMember( 0, m_currentName, clantype1, "");
	}
	
	//class'UIAPI_TEXTBOX'.static.SetText(m_WindowName$".Clan1_CurrentSelectedMemberOrderName", getClanOrderString( clantype1 ) @ "-" @ currentstring1);
}


function OnComboBoxItemSelected(string strID, int index)
{
	local int selectval;
	if (strID == "Clan1_targetknighthoodcombobox")
	{
		class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName$".Clan1_targetknighthoodmember");
		class'UIAPI_WINDOW'.static.EnableWindow(m_WindowName$".Clan1_ChangeMemberKnightHoodBtn");
		selectval = class'UIAPI_COMBOBOX'.static.GetReserved(m_WindowName$".Clan1_targetknighthoodcombobox", index);
		swapTargetSelect(selectval);
	}
}

function HideClanWindow()
{	
	//debug ("HideWindow is in Run");
	class'UIAPI_WINDOW'.static.HideWindow(m_WindowName);
	clanWndClassicScript.ResetOpeningVariables();
	switchingWarCancelButton();
}

function ApplyEditGrade()	// 혈맹 권한 편집
{
	local array<int> powers;
	local int i;
	local int index;
	powers.Length = 32;
	powers[0]=0;			// first power bit is dummy
	index = 1;
	for( i=1 ; i <= NUMOFOPTIONS_SYSTEM ; ++i )	// 비행정 권한 관련 수정 - CT2_Final
	{
		if( i < 10)
		{
			if( class'UIAPI_CHECKBOX'.static.IsChecked(m_WindowName$".Clan6_Check10" $ i ) )	powers[index] = 1;
		}
		else
		{
			if( class'UIAPI_CHECKBOX'.static.IsChecked(m_WindowName$".Clan6_Check1" $ i ) )	powers[index] = 1;
		}
		++index;
	}

	for( i=1; i <= NUMOFOPTIONS_AGIT ; ++i )
	{
		if( class'UIAPI_CHECKBOX'.static.IsChecked(m_WindowName$".Clan6_Check20" $ i ) )
		{
			//debug ("아지트권한" @ m_WindowName$".Clan6_Check20" $ i  );
			powers[index] = 1;
		}
		++index;
	}

	for( i=1; i <= NUMOFOPTIONS_CASTLE ; ++i )
	{
		if( class'UIAPI_CHECKBOX'.static.IsChecked(m_WindowName$".Clan6_Check30" $ i ) )
		{
			//debug ("성/요새권한" @ m_WindowName$".Clan6_Check30" $ i  );
			powers[index] = 1;
		}
		++index;
	}

		
	RequestEditClanAuth( m_currentEditGradeID, powers );
}

function EditAuthGrade()
{
	local int index;
	local LVDataRecord record;
	index = m_hClanDrawerWndClan5_AuthListCtrl.GetSelectedIndex();
	if( index >= 0 )
	{
		m_hClanDrawerWndClan5_AuthListCtrl.GetRec(index, record);
		RequestClanAuth( int(record.nReserved1) );
		//debug("RequestClanAuth " $ ( record.nReserved1 ) );
		m_currentEditGradeID = int(record.nReserved1);
		SetStateAndShow("ClanAuthEditWndState");
	
	}
	else
	{
		SetStateAndShow("ClanAuthManageWndState");
	}
}

//classic//
/*
function EditAuthGrade2()
{
	local int index;
	local LVDataRecord record;
	index = m_hClanDrawerWndClan5_AuthListCtrl2.GetSelectedIndex();
	if( index >= 0 )
	{
		m_hClanDrawerWndClan5_AuthListCtrl2.GetRec( index, record);
		RequestClanAuth( int(record.nReserved1) );
		//debug("RequestClanAuth " $ ( record.nReserved1 ) );
		m_currentEditGradeID = int(record.nReserved1);
		SetStateAndShow("ClanAuthEditWndState");
	
	}
	else
	{
		SetStateAndShow("ClanAuthManageWndState");
	}
}
*/

function AddSkill( ItemID cID, int level )
{
	local ItemInfo info;

	info.ID = cID;
	info.Level = level;
	info.Name = class'UIDATA_SKILL'.static.GetName( info.ID, info.Level, info.SubLevel );
	info.IconName = class'UIDATA_SKILL'.static.GetIconName( info.ID, info.Level, info.SubLevel );
	info.Description = class'UIDATA_SKILL'.static.GetDescription( info.ID, info.Level, info.SubLevel  );
	info.AdditionalName = class'UIDATA_SKILL'.static.GetEnchantName( info.ID, info.Level, info.SubLevel );

	class'UIAPI_ITEMWINDOW'.static.AddItem( m_WindowName$".ClanSkillWnd", info );
}

function ReplaceSkill( int index, ItemID cID, int level )
{
	local ItemInfo info;

	info.ID = cID;
	info.Level = level;
	info.Name = class'UIDATA_SKILL'.static.GetName( info.ID, info.Level, info.SubLevel );
	info.IconName = class'UIDATA_SKILL'.static.GetIconName( info.ID, info.Level, info.SubLevel );
	info.Description = class'UIDATA_SKILL'.static.GetDescription( info.ID, info.Level, info.SubLevel  );
	info.AdditionalName = class'UIDATA_SKILL'.static.GetEnchantName( info.ID, info.Level, info.SubLevel );

	class'UIAPI_ITEMWINDOW'.static.SetItem( m_WindowName$".ClanSkillWnd", index, info );
}

// oxyzen added 혈맹기사단 이름 가져오기
function string getClanOrderString(int gradeID)
{
	local int stringIndex;
	stringIndex = -1;
	if( gradeID == CLAN_MAIN )
		stringIndex = 1399;
	else if( gradeID == CLAN_KNIGHT1 )
		stringIndex = 1400;
	else if( gradeID == CLAN_KNIGHT2 )
		stringIndex = 1401;
	else if( gradeID == CLAN_KNIGHT3 )
		stringIndex = 1402;
	else if( gradeID == CLAN_KNIGHT4 )
		stringIndex = 1403;
	else if( gradeID == CLAN_KNIGHT5 )
		stringIndex = 1404;
	else if( gradeID == CLAN_KNIGHT6 )
		stringIndex = 1405;
	else if( gradeID == CLAN_ACADEMY )
		stringIndex = 1419;

	if( stringIndex != -1 )
		return GetSystemString( stringIndex );
	else 
		return "";

}


// function reset 혈맹 정보 by oxyzen
//classic// 
/*
function reset_clan_org()
{
	local int i;
	for ( i=0; i < CLAN_KNIGHTHOOD_COUNT; ++i)
	{
		Clan3_OrgIcon[i].HideWindow();
		Clan3_OrgIcon[i].DisableWindow();
		Clan3_OrgIcon[i].SetTooltipCustomType(SetTooltip(""));
	}
}
*/


// 아카데미혈맹원등급의 권한 편집시 디스에이블
function disableAcademyAuth()
{
	//debug("I have done2");
	//혈맹권한: 혈맹가입, 호칭관리, 문장관리, 혈맹전쟁, 혈원제명, 성장괸리, 등급관리, 마스터관리		
	
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check100", true );
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check101", true );
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check102", true );
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check106", true );
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check104", true );
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check105", true );
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check107", true );
	//classic// class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check108", true );
	//classic// class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check109", true );
	//classic// class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check110", true );

	//아지트권한: 추방권한, 기능설정, 입찰매각
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check200", true );
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check203", true );
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check204", true );
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check205", true );

	//성권한: 추방권한, 장원관리, 세금관리, 공수성등록, 용병관리, 기능설정
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check300", true );
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check303", true );
	//classic// class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check302", true );
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check305", true );
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check306", true );
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check307", true );
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check308", true );
}

// 아캄데미 혈맹원의 등급이 아닐 경우 다시 이네이블 혹은 리셋;
function resetAcademyAuth()
{
	//혈맹권한: 혈맹가입, 호칭관리, 문장관리, 혈맹전쟁, 혈원제명, 성장괸리, 등급관리, 마스터관리
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check100", false );
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check101", false );
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check102", false );
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check106", false );
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check104", false );
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check105", false );
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check107", false );
	//classic// class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check108", false );
	//classic// class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check109", false );
	//classic// class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check110", false );
	//아지트권한: 추방권한, 기능설정, 입찰매각
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check200", false );
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check203", false );
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check204", false );
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check205", false );

	//성권한: 추방권한, 장원관리, 세금관리, 공수성등록, 용병관리, 기능설?
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check300", false );
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check303", false );
	//classic// class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check302", false );
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check305", false );
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check306", false );
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check307", false );
	class'UIAPI_CHECKBOX'.static.SetDisable(m_WindowName$".Clan6_Check308", false );
}

function int getCurrentGradebyClanType()
{
	local int GradeNum;
	switch(m_clanType)
	{
		case CLAN_MAIN:
		GradeNum = 6;
		break;
		case CLAN_KNIGHT1:
		GradeNum = 7;
		break;
		case CLAN_KNIGHT2:
		GradeNum = 7;
		break;
		case CLAN_KNIGHT3:
		GradeNum = 8;
		break;
		case CLAN_KNIGHT4:
		GradeNum = 8;
		break;
		case CLAN_KNIGHT5:
		GradeNum = 8;
		break;
		case CLAN_KNIGHT6:
		GradeNum = 8;
		break;
		case CLAN_ACADEMY:
		GradeNum = 9;
		break;
	}
	return GradeNum;
}

function CustomTooltip SetTooltip(string Text)
{
	local CustomTooltip Tooltip;
	local DrawItemInfo info;
	
	Tooltip.MinimumWidth = 144;
	Tooltip.DrawList.Length = 1;
	
	info.eType = DIT_TEXT;
	info.t_color.R = 178;
	info.t_color.G = 190;
	info.t_color.B = 207;
	info.t_color.A = 255;
	info.t_strText = Text;
	Tooltip.DrawList[0] = info;

	return Tooltip;
}

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
    m_WindowName="ClanDrawerWndClassic"
    m_ClanPledgeBonusDrawerWndName="ClanPledgeBonusDrawerWndClassic"
}
