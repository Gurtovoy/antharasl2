class PersonalConnectionsDrawerWnd extends UICommonAPI;

const MAX_MEMO_LENGTH = 50;

var WindowHandle Me;
var WindowHandle AddWnd;

var TextBoxHandle AddWndTitle;
var TabHandle AddWndTab;
var TextureHandle AddListTabBgLine;
var TextureHandle AddListTabBg;

var WindowHandle NameEnterWnd;
var TextBoxHandle NameEnter_Description;
var TextBoxHandle NameEnterTitle;
var EditBoxHandle NameEnterEditbox;
var TextureHandle DecoGroupBox;

var WindowHandle ClanListWnd;
var TextBoxHandle ClanList_Description;
var TextureHandle ClanListDeco;
var ListCtrlHandle ClanList;
var TextureHandle ClanListGroupBox;

var WindowHandle InzoneTreeWnd;
var TextBoxHandle InzoneTree_Description;
var TreeHandle InzoneTree;
var TextureHandle InzoneClanListGroupBox;
var ButtonHandle AddListBtn;
var ButtonHandle CloseBtn;
var TextureHandle DescriptionGroupBox;

var WindowHandle DetailInfoWnd;
var WindowHandle MenteeSearchWnd;

var MultiEditBoxHandle MemoContents;
var ButtonHandle  MemoEnterBtn;
var TextureHandle texPledgeCrest;	
var TextureHandle texPledgeAllianceCrest;

// 멘티 검색 윈도우 맴버
var ButtonHandle   AddMenteeBtn, WhisperMenteeBtn, CloseMenteeBtn, RefreshMenteeBtn, BackwardBtn, ForwardBtn;
var TextBoxHandle  MenteeCount;
var ComboBoxHandle LevelComboBox;
var ListCtrlHandle MenteeList;

var PersonalConnectionsWnd PersonalConnectionsWndScript;

// 현재 멘티 페이지 카운트
var int menTeeListCurrentPageCount;
var int menTeeListTotalPage;


var L2Util       util;

var string       beforeSelectedTreePath;
var string       inzoneSelectedParam;
var string       selectTreeNodeStr;


// 멘티 계약 해지 남은 시간

var TextBoxHandle   NameEnterLimit;
var TextBoxHandle   NameEnterLimitTime;


function OnRegisterEvent()
{
	RegisterEvent( EV_Restart );

	// 혈맹 목록
	registerEvent( EV_ClanDeleteAllMember );
	registerEvent( EV_ClanAddMember );
	registerEvent( EV_ClanMemberInfoUpdate );
	registerEvent( EV_ClanDeleteMember );

	registerEvent( EV_ClanInfo );
	registerEvent( EV_ClanInfoUpdate );
	registerEvent( EV_ClanAddMemberMultiple );

	// 우편에서 쓰던 혈맹 목록 리스트
	registerEvent( EV_ReceivePledgeMemberList );


	// 인존 파티 히스토리
	registerEvent( EV_InzonePartyHistoryUpdate );

	// 멘티 대기자 리스트 받기 
	registerEvent(EV_MenteeWaitingListStart);	
	registerEvent(EV_MenteeWaitingList);	
	registerEvent(EV_MenteeWaitingListEnd);

	// 멘티 계약 해지 남은 시간
	registerEvent(EV_MentorMenteeListStart);
}

function OnLoad()
{	
	SetClosingOnESC();
	// Debug("인맥 관리 보조창 onLoad");
	Initialize();
	Load();

	util = L2Util(GetScript("L2Util"));

	// 레벨 범위 추가
	// 1~40, 41 ~ 60, 
	LevelComboBox.AddString(GetSystemString(2780));
	LevelComboBox.AddString(GetSystemString(2781));
	LevelComboBox.AddString(GetSystemString(2782));
	LevelComboBox.AddString(GetSystemString(2783));

	menTeeListTotalPage        = 1;
	menTeeListCurrentPageCount = 1;	
}

function mentorMenteeListStartHandle(string param)
{	

	local int DisableTimeInSec;
	//local int Role;
	//local string NameEnterLimitTimeStr;
	//parseInt(param, "Role", Role);	
	parseInt(param, "DisableTimeInSec", DisableTimeInSec);	
	if (DisableTimeInSec == 0 ) 
	{
		NameEnterLimit.SetText( "" );
		NameEnterLimitTime.SetText( "" );
	}else {
		//NameEnterLimitTimeStr = GetSystemMessage(3902) $ "\\n" $ makeNameEnterLimitTime(DisableTimeInSec) ;
		NameEnterLimit.SetText( GetSystemMessage(3902) );
		//NameEnterLimit.SetText( "머라머라!!!!" );
		NameEnterLimitTime.SetText( makeNameEnterLimitTime(DisableTimeInSec) );
	}
	//Debug("mentorMenteeListStartHandle" @ NameEnterLimitTimeStr);
	
}


function string makeNameEnterLimitTime (int DisableTimeInSec)
{
	local string    tmpStr;	
	local int CurDay;
	local int Totday;
	local int Curhou;
	local int Tothou;
	local int Curmin;
	local int Totmin;	
	local int Totsec;

	Totsec = DisableTimeInSec;
	
	if ( Totsec < 60 ) 
	{
		tmpStr = MakeFullSystemMsg( GetSystemMessage(3390),"1") ; //1분
		tmpStr = MakeFullSystemMsg( GetSystemMessage(3408), tmpStr);
	}
	else 
	{	
		Totmin = Totsec / 60;
		Curmin = Totmin % 60;
		Tothou = Totmin / 60;
		Curhou = Tothou % 24 ;		
		Totday = Tothou / 24 ;
		CurDay = Totday % 24 ;

		//Debug ("test" @ Tothou @ Curhou    );

		if ( Tothou >= 24 ) tmpStr = MakeFullSystemMsg( GetSystemMessage(3418), String(CurDay)) ; //일
		if ( Tothou > 0  && Curhou != 0 )  tmpStr = tmpStr @ MakeFullSystemMsg( GetSystemMessage(3406), String(Curhou) ) ; //시간
		if ( Curmin != 0 ) tmpStr = tmpStr @ MakeFullSystemMsg( GetSystemMessage(3390), String(Curmin)) ; //분
	}

	tmpStr = GetSystemString(1108) @ tmpStr; //남은 시간
	
	return tmpStr;
}







function OnShow()
{
	if(getInstanceL2Util().isClanV2())
	{		
		class'PostWndAPI'.static.RequestPledgeMemberList();
		GetButtonHandle( "PersonalConnectionsDrawerWnd.AddWnd.ClanListWnd.ClanListReset_Btn" ).ShowWindow();
	}
	else
	{
		// 기존, 혈맹 리스트 정보
		class'UIDATA_CLAN'.static.RequestClanInfo();	
		GetButtonHandle( "PersonalConnectionsDrawerWnd.AddWnd.ClanListWnd.ClanListReset_Btn" ).HideWindow();
	}

	// 인존 정보 요청	
	// 아레나에서는 사용 안함.
	if ( ! getInstanceUIData().getIsArenaServer() ) 
		class'PersonalConnectionAPI'.static.RequestInzonePartyInfoHistory();

	texPledgeCrest.HideWindow();
	texPledgeAllianceCrest.HideWindow();
}

function Initialize()
{
	Me = GetWindowHandle( "PersonalConnectionsDrawerWnd" );

	NameEnterLimit = GetTextBoxHandle( "PersonalConnectionsDrawerWnd.AddWnd.NameEnterLimit" );
	NameEnterLimitTime = GetTextBoxHandle( "PersonalConnectionsDrawerWnd.AddWnd.NameEnterLimitTime" );

	AddWnd = GetWindowHandle( "PersonalConnectionsDrawerWnd.AddWnd" );
	AddWndTitle = GetTextBoxHandle( "PersonalConnectionsDrawerWnd.AddWnd.AddWndTitle" );
	AddWndTab = GetTabHandle( "PersonalConnectionsDrawerWnd.AddWnd.AddWndTab" );

	AddListTabBgLine = GetTextureHandle( "PersonalConnectionsDrawerWnd.AddWnd.AddListTabBgLine" );
	AddListTabBg = GetTextureHandle( "PersonalConnectionsDrawerWnd.AddWnd.AddListTabBg" );

	NameEnterWnd = GetWindowHandle( "PersonalConnectionsDrawerWnd.AddWnd.NameEnterWnd" );
	NameEnter_Description = GetTextBoxHandle( "PersonalConnectionsDrawerWnd.AddWnd.NameEnterWnd.NameEnter_Description" );
	NameEnterTitle = GetTextBoxHandle( "PersonalConnectionsDrawerWnd.AddWnd.NameEnterWnd.NameEnterTitle" );
	NameEnterEditbox = GetEditBoxHandle( "PersonalConnectionsDrawerWnd.AddWnd.NameEnterWnd.NameEnterEditbox" );
	DecoGroupBox = GetTextureHandle( "PersonalConnectionsDrawerWnd.AddWnd.NameEnterWnd.DecoGroupBox" );

	ClanListWnd = GetWindowHandle( "PersonalConnectionsDrawerWnd.AddWnd.ClanListWnd" );
	ClanList_Description = GetTextBoxHandle( "PersonalConnectionsDrawerWnd.AddWnd.ClanListWnd.ClanList_Description" );
	ClanListDeco = GetTextureHandle( "PersonalConnectionsDrawerWnd.AddWnd.ClanListWnd.ClanListDeco" );
	ClanList = GetListCtrlHandle( "PersonalConnectionsDrawerWnd.AddWnd.ClanListWnd.ClanList" );
	ClanListGroupBox = GetTextureHandle( "PersonalConnectionsDrawerWnd.AddWnd.ClanListWnd.ClanListGroupBox" );

	InzoneClanListGroupBox = GetTextureHandle( "PersonalConnectionsDrawerWnd.AddWnd.InzoneTreeWnd.ClanListGroupBox" );
	InzoneTreeWnd = GetWindowHandle( "PersonalConnectionsDrawerWnd.AddWnd.InzoneTreeWnd" );
	InzoneTree_Description = GetTextBoxHandle( "PersonalConnectionsDrawerWnd.AddWnd.InzoneTreeWnd.InzoneTree_Description" );
	InzoneTree = GetTreeHandle( "PersonalConnectionsDrawerWnd.AddWnd.InzoneTreeWnd.InzoneTree" );
	
	AddListBtn = GetButtonHandle( "PersonalConnectionsDrawerWnd.AddWnd.AddListBtn" );
	CloseBtn = GetButtonHandle( "PersonalConnectionsDrawerWnd.AddWnd.CloseBtn" );
	DescriptionGroupBox = GetTextureHandle( "PersonalConnectionsDrawerWnd.AddWnd.DescriptionGroupBox" );

	DetailInfoWnd = GetWindowHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd" );

	// 멘토 대기자 검색 기능 추가 
	MenteeSearchWnd = GetWindowHandle( "PersonalConnectionsDrawerWnd.MenteeSearchWnd" );

	MemoContents = GetMultiEditBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.MemoContents" );
	MemoEnterBtn = GetButtonHandle("PersonalConnectionsDrawerWnd.DetailInfoWnd.MemoEnterBtn");
	texPledgeCrest = GetTextureHandle ("PersonalConnectionsDrawerWnd.DetailInfoWnd.texPledgeCrest");
	texPledgeAllianceCrest = GetTextureHandle ("PersonalConnectionsDrawerWnd.DetailInfoWnd.texPledgeAllianceCrest");

	
	AddMenteeBtn     = GetButtonHandle( "PersonalConnectionsDrawerWnd.MenteeSearchWnd.AddMenteeBtn" );
	WhisperMenteeBtn = GetButtonHandle( "PersonalConnectionsDrawerWnd.MenteeSearchWnd.WhisperMenteeBtn" );
	CloseMenteeBtn   = GetButtonHandle( "PersonalConnectionsDrawerWnd.MenteeSearchWnd.CloseMenteeBtn" );	
	RefreshMenteeBtn = GetButtonHandle( "PersonalConnectionsDrawerWnd.MenteeSearchWnd.RefreshMenteeBtn" );

	BackwardBtn      = GetButtonHandle( "PersonalConnectionsDrawerWnd.MenteeSearchWnd.BackwardBtn" );
	ForwardBtn       = GetButtonHandle( "PersonalConnectionsDrawerWnd.MenteeSearchWnd.ForwardBtn" );

	MenteeCount      = GetTextBoxHandle( "PersonalConnectionsDrawerWnd.MenteeSearchWnd.MenteeCount" );

	LevelComboBox    = GetComboBoxHandle( "PersonalConnectionsDrawerWnd.MenteeSearchWnd.LevelComboBox" );
	MenteeList       = GetListCtrlHandle( "PersonalConnectionsDrawerWnd.MenteeSearchWnd.MenteeList" );

	// 부모 윈도우 script
	PersonalConnectionsWndScript = PersonalConnectionsWnd(GetScript("PersonalConnectionsWnd"));
	
	
	// 50자 제한 
	MemoContents.SetMaxSizeOfText(50);

	GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.BlockInfoText").HideWindow();
	

	beforeSelectedTreePath = "";	

	if ( getInstanceUIData().getIsArenaServer() ) 
	{
		AddWndTab.RemoveTabControl( 2 ) ;
		AddWndTab.RemoveTabControl( 1 ) ;
		AddListTabBgLine.SetWindowSize( 182 , 24);		
	}
}

function Load()
{

}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 버튼 클릭 이벤트 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function OnClickButton( string Name )
{
	local LVDataRecord record;
	local string tempStr;

	switch( Name )
	{
		// 혈맹 v2 에서 사용.
		case "ClanListReset_Btn":
			 class'PostWndAPI'.static.RequestPledgeMemberList();
			 break;

		case "AddListBtn":
			 OnAddListBtnClick();
			 break;

	    case "CloseMenteeBtn" :
		case "CloseBtn":
			 OnCloseBtnClick();
		  	 break;
			 
		case "MemoEnterBtn" :
			 memoEnterBtnHandler();
			 break;

        case "AddWndTab0" :
		case "AddWndTab1" :
	    case "AddWndTab2" :
			 // 인존 정보 요청
			 // class'PersonalConnectionAPI'.static.RequestInzonePartyInfoHistory();
			 // 멘토링 상태 
			 if (PersonalConnectionsWndScript.ConnectionsListSelectTab.GetTopIndex() == 2)
			 {

				 // 멘토링탭에서 , 멘티 검색을 클릭한 경우 
				 if (AddWndTab.GetTopIndex() == 2)
				 {
					InzoneTreeWnd.HideWindow();				
					MenteeSearchWnd.ShowWindow();

					AddListBtn.HideWindow();
					CloseBtn.HideWindow();

					// 멘티 리스트요청					
					callMenTeeList(LevelComboBox.GetSelectedNum(), 1);
				 }
				 else
				 {
					MenteeSearchWnd.HideWindow();
					AddListBtn.ShowWindow();
					CloseBtn.ShowWindow();
				 }
			 }
			 else
			 {
				AddListBtn.ShowWindow();
				CloseBtn.ShowWindow();
			 }

			 break;

		case "RefreshMenteeBtn" : callMenTeeList(LevelComboBox.GetSelectedNum(), 1); break;
		case "BackwardBtn"      : callMenTeeList(LevelComboBox.GetSelectedNum(), menTeeListCurrentPageCount - 1); break;
		case "ForwardBtn"       : callMenTeeList(LevelComboBox.GetSelectedNum(), menTeeListCurrentPageCount + 1); break;
		case "WhisperMenteeBtn" : OnDBClickListCtrlRecord("MenteeList"); break;
		case "AddMenteeBtn"     : // 멘토 대기자 중에 멘토 초대 			 
								  MenteeList.GetSelectedRec(record);
								  if (record.LVDataList.length > 0)	tempStr = record.LVDataList[0].szData;								  
								  if (tempStr != "")
								  {
									// debug("RequestMenteeAdd" @ tempStr); 
									class'PersonalConnectionAPI'.static.RequestMenteeAdd(tempStr); 
								  }
								  else AddSystemMessage(3314); // 목록을 선택하라는 메세지 출력 

								  break;
	}


	// 인존 트리 
	if (Left(Name, 4) == "root")
	{	
		// "root.list1.member1" 이면 13자가 넘으니까  [심연의 미궁] - 변신맨
		// 두번째 단계의 노드를 클릭 한 것에 대해서만 조건 체크 
		if (13  < len(Name))
		{
			if (beforeSelectedTreePath != name)
			{
				if (beforeSelectedTreePath == "")
				{
				
				}
				else
				{
					InzoneTree.SetExpandedNode( beforeSelectedTreePath, false );
					selectTreeNodeStr = "";
				}
			}
			else 
			{
				InzoneTree.SetExpandedNode( beforeSelectedTreePath, true);		

				// Debug("inzoneSelectedParam" @ inzoneSelectedParam);
								
				// debug("selectTreeNodeStr" @ selectTreeNodeStr);

			}
			ParseString(inzoneSelectedParam, Name, selectTreeNodeStr);
			beforeSelectedTreePath = Name;
		}		
		else		
		{
			InzoneTree.SetExpandedNode( beforeSelectedTreePath, false );
			beforeSelectedTreePath = "";
			selectTreeNodeStr = "";
		}
	}

	// Debug("string : " @ name);
}

function treeSelectHandler ()
{

//	InzoneTree.SetExpandedNode( beforeTreeName, false );	

}
/**
 *  메모 입력 
 **/
function memoEnterBtnHandler ()
{
	local string userName;
	local int parentTabIndex;

	userName = GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.TargetNameText" ).GetText();
	// Debug(" 문자 수 " @ MemoContents.GetTotalSizeOfText());

	// Debug("메모 입력 유저 :" @ userName);
	// Debug("MemoContents.GetString() :" @ MemoContents.GetString());

	if (MemoContents.GetString() != "")
	{
		// 글자수 제한 
		if (MemoContents.GetTotalSizeOfText() <= 50)
		{
			parentTabIndex = PersonalConnectionsWndScript.ConnectionsListSelectTab.GetTopIndex();

			if (parentTabIndex == 0)
			{
				class'PersonalConnectionAPI'.static.RequestUpdateFriendMemo(userName, MemoContents.GetString());
				// Debug("RequestUpdateFriendMemo");
				
			}
			else 
			{   
				class'PersonalConnectionAPI'.static.RequestUpdateBlockMemo(userName, MemoContents.GetString());
				// Debug("RequestUpdateBlockMemo");
			}

			// 메모 입력이 완료되었습니다. 메세지 출력 
			AddSystemMessage(3332);
		}
	}
}

/**
 * 콤보 박스 선택 
 * 
 * 멘티 검색 Lv 범위 지정 
 **/
function OnComboBoxItemSelected(string StrID, int IndexID)
{
	switch(strID)
	{		
		case "LevelComboBox" : callMenTeeList(IndexID, 1); break;
	}
}

/***
 * 멘티 리스트를 요청한다
 **/
function callMenTeeList (int comboLevelIndex, int nChangePage)
{
	// Debug("comboLevelIndex->" @ comboLevelIndex);
	// Debug("menTeeListCurrentPageCount->" @ menTeeListCurrentPageCount);

	if (nChangePage > menTeeListTotalPage) nChangePage = menTeeListTotalPage;
	if (nChangePage < 1) nChangePage = menTeeListTotalPage;

	// Debug("nChangePage->" @ nChangePage);

	switch(comboLevelIndex)
	{
		case 0 : RequestMenteeWaitingList(nChangePage,  1, 85); break;
		case 1 : RequestMenteeWaitingList(nChangePage,  1, 40); break;
		case 2 : RequestMenteeWaitingList(nChangePage, 41, 70); break;
		case 3 : RequestMenteeWaitingList(nChangePage, 71, 85); break;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 리스트 클릭 이벤트
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 *  리스트 요소를 클릭 했다면..
 **/ 
function OnClickListCtrlRecord( string ListCtrlID)
{
	// local LVDataRecord record;
	 	
	if (ListCtrlID == "ClanList")
	{
		// empty
	}
}
	
/**
 * 리스트 더블클릭 
 **/

function OnDBClickListCtrlRecord( string ListCtrlID)
{	
	local int tabIndex;
	local string tempStr;

	local ChatWnd chatWndScript;
	local LVDataRecord record;

	// Debug("더블 클릭 -> " @ ListCtrlID);

	tabIndex = AddWndTab.GetTopIndex();
	
	if (ListCtrlID == "MenteeList")
	{
		MenteeList.GetSelectedRec(record);
		tempStr = record.LVDataList[0].szData;

		if (tempStr != "")
		{
			chatWndScript = ChatWnd(GetScript("ChatWnd"));
			chatWndScript.setChatEditBox("\"" $ tempStr $ " ");
			//callGFxFunction("ChatMessage","sendWhisper", tempStr);
		}
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 이벤트 -> 해당 이벤트 처리 핸들러
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function OnEvent( int Event_ID, string param )
{
	// Debug("인맥 관리 보조창 " @ Event_ID);
	// Debug("param: " @ param);

	switch( Event_ID )
	{
		case EV_Restart :
			 restartHandler();
			 break;

		case EV_ReceivePledgeMemberList :
			 HandleReceivePledgeMemberList(param);
			 break;

	    case EV_ClanInfo :
		case EV_ClanDeleteAllMember :
			 if(!getInstanceL2Util().isClanV2()) clanMemberInfoListEmptyHandle();
			 break;

		case EV_ClanAddMember :
  	    case EV_ClanAddMemberMultiple :			 
			 if(!getInstanceL2Util().isClanV2()) clanMemberAddedHandle(param);

			 break;

		case EV_ClanMemberInfoUpdate :
			 if(!getInstanceL2Util().isClanV2()) clanMemberInfoUpdateHandle(param);
			 break;

		case EV_ClanDeleteMember :
			 if(!getInstanceL2Util().isClanV2()) clanMemberRemovedHandle(param);
			 break;

		case EV_InzonePartyHistoryUpdate:
			 InzonePartyHistoryUpdateHandler(param);
			 break;

		 // 멘티 대기자 리스트 받기 
	    case EV_MenteeWaitingListStart :
			 menteeWaitingListStartHandle(param);
			 break;

	    case EV_MenteeWaitingList :
			 menteeWaitingListHandle(param);
			 break;

	    case EV_MenteeWaitingListEnd :
			 menteeWaitingListEndHandle(param);
			 break;

		 case EV_MentorMenteeListStart :
			
			mentorMenteeListStartHandle(param);
			break;
	}
}

/**
 * 멘티 대기자 리스트 받기 - start
 **/
function menteeWaitingListStartHandle(string param)
{
	local int currentPageCount;
	local int totalPage;

	ParseInt(param, "CurPage"  , currentPageCount);
	ParseInt(param, "TotalPage", totalPage);

	if (currentPageCount <= 0 || totalPage <= 0)
	{
		// empty
	}
	else
	{
		menTeeListCurrentPageCount = currentPageCount;		
		menTeeListTotalPage        = totalPage;

		// 정상적, 작동 이라고면.. 리스트를 지우고, 초기화
		MenteeList.DeleteAllItem();
		
		// 페이지 출력
		MenteeCount.SetText(menTeeListCurrentPageCount $ "/" $ menTeeListTotalPage);

		if (menTeeListTotalPage <= menTeeListCurrentPageCount) ForwardBtn.DisableWindow();
		else ForwardBtn.EnableWindow();

		if (menTeeListCurrentPageCount <= 1) BackwardBtn.DisableWindow();
		else BackwardBtn.EnableWindow();
	}
}

/**
 * 멘티 대기자 리스트 받기 - get Info
 **/
function menteeWaitingListHandle(string param)
{
	//MenteeList.add
	local LVDataRecord record;

	setMenteeMemberRecord(record, param);

	// 레코드 한줄씩 추가
	MenteeList.InsertRecord(record);
}

/**
 * 멘티 대기자 리스트 받기 - End
 **/
function menteeWaitingListEndHandle(string param)
{

}

/***
 * 멘티리스트 레코드 생성 
 **/
function setMenteeMemberRecord (out LVDataRecord record, string param)
{
	// parse var
	local string name, levelString;
	local int classID, level, status;
	
	record.LVDataList.Length = 4;

	// parse
	ParseString(param, "Name", name);
	//ParseString(param, "memo", memo);

	ParseInt(param, "Class" , classID);
	ParseInt(param, "Level"   , level);
	// 특이하게 ID가 0이 아니면 접속 상태로 파악한다. 	
	// ParseInt(param, "ID"  , status);

	// debug("status" @ status);
	if (status < 1)
	{
		ParseInt(param, "Status"  , status);
	}
	// debug("status:" @ status);

	// 정확한 레벨로 보여 주지 않고, 범위로 보여준다. 
	if (level >= 1  && level <= 40)
	{
		// 1~40
		levelString = GetSystemString(2789);
	}
	else if (level >= 41  && level <= 70)
	{
		// 41~70
		levelString = GetSystemString(2790);
	}
	else if (level >= 71  && level <= 85)
	{
		// 71~85
		levelString = GetSystemString(2791);
	}  

	// 멘티 대기자 리스트는 무조건 온라인인 사람만 넘어 온다.
	// 무조건 온라인 상태인 텍스트 칼라 
	record.LVDataList[0].buseTextColor = True;
	record.LVDataList[0].TextColor = util.BrightWhite;
	record.LVDataList[1].buseTextColor = True;
	record.LVDataList[1].TextColor = util.BrightWhite;

	record.LVDataList[0].szData = name;	

	record.LVDataList[1].szData = levelString;
	Record.LVDataList[1].textAlignment=TA_CENTER;

	record.LVDataList[2].szData = string(classID);		
	record.LVDataList[2].szTexture = GetClassRoleIconName(classID);
	record.LVDataList[2].HiddenStringForSorting = String(GetClassRoleType(classID));
	
	record.LVDataList[2].nTextureWidth = 11;
	record.LVDataList[2].nTextureHeight = 11;
	
	record.nReserved1 = 0;	// for additional information
}


/** 리스타트 초기화 */
function restartHandler()
{	
	OnShow();
	clanMemberInfoListEmptyHandle();
}


/**
 *  친구 목록 추가 
 **/
function OnAddListBtnClick()
{
	local int tabIndex;
	local string tempStr;

	tabIndex = AddWndTab.GetTopIndex();

	// - 현재 탭의 상태- 
	// [이름 추가]
	if (tabIndex == 0)
	{
		if (NameEnterEditbox.GetString() != "")
		{
			switch (PersonalConnectionsWndScript.ConnectionsListSelectTab.GetTopIndex())
			{
				case 0 :// Debug("친구 목록 추가: " @ NameEnterEditbox.GetString());
						class'PersonalConnectionAPI'.static.RequestAddFriend(NameEnterEditbox.GetString());						
						break;

				case 1 :// Debug("차단 목록 추가: " @ NameEnterEditbox.GetString());
						class'PersonalConnectionAPI'.static.RequestAddBlock(NameEnterEditbox.GetString());			
						break;

				case 2 :// Debug("멘토링 목록 추가: " @ NameEnterEditbox.GetString());
						class'PersonalConnectionAPI'.static.RequestMenteeAdd(NameEnterEditbox.GetString()); 
						break;
			}
			NameEnterEditbox.SetString("");
		}
		else
		{
			AddSystemMessage(3718);
			// Debug("이름 넣는데 공백이 있다. ");
		}
	}
	// [혈맹 목록]
	else if (tabIndex == 1)
	{
		tempStr = getUserNameByList();
		if (tempStr != "")
		{
			switch (PersonalConnectionsWndScript.ConnectionsListSelectTab.GetTopIndex())
			{
				case 0 :// Debug("친구 목록 추가: " @ NameEnterEditbox.GetString());
						class'PersonalConnectionAPI'.static.RequestAddFriend(tempStr);
						break;

				case 1 :// Debug("차단 목록 추가: " @ NameEnterEditbox.GetString());
						class'PersonalConnectionAPI'.static.RequestAddBlock(tempStr);
						break;

				case 2 :// Debug("멘토링 목록 추가: " @ NameEnterEditbox.GetString());
						class'PersonalConnectionAPI'.static.RequestMenteeAdd(tempStr); 

						break;
			}
		}
		else
		{
			// 목록을 선택하라는 메세지 출력 
			AddSystemMessage(3314);	
		}
	}
	// [인존 이력]
	else if (tabIndex == 2)
	{		
		// debug("--selectTreeNodeStr" @ selectTreeNodeStr);
		if (selectTreeNodeStr != "")
		{
			switch (PersonalConnectionsWndScript.ConnectionsListSelectTab.GetTopIndex())
			{
				case 0 :// Debug("친구 목록 추가: " @ NameEnterEditbox.GetString());
						class'PersonalConnectionAPI'.static.RequestAddFriend(selectTreeNodeStr);
						break;

				case 1 :// Debug("차단 목록 추가: " @ NameEnterEditbox.GetString());
						class'PersonalConnectionAPI'.static.RequestAddBlock(selectTreeNodeStr);
						break;

				case 2 :// Debug("멘토링 목록 추가: " @ NameEnterEditbox.GetString());
						class'PersonalConnectionAPI'.static.RequestMenteeAdd(selectTreeNodeStr); 
						break;
			}
		}
		else
		{
			// 목록을 선택하라는 메세지 출력 
			AddSystemMessage(3314);	
		}
		// Debug("인존 목록 추가: ");
	}
}

/***
 *  닫기 버튼 클릭 
 **/
function OnCloseBtnClick()
{
	Me.HideWindow();
}

//혈맹 리스트 받았을때 처리
function HandleReceivePledgeMemberList( string param )
{
	local int Num;
	local int i;
	local string strName;
	local int ClanClass;
	local int ClanLevel;
	local int logon;
	local LVDataRecord Record;
	local array<String> addName;

	if(!getInstanceL2Util().isClanV2()) return;
	ParseInt( Param, "Num", Num );
	
	ClanList.DeleteAllItem();

	for( i = 0 ; i < Num ; i++ )
	{
		ParseString( Param, "Name"$i, strName );
		ParseInt( Param, "FriendClass"$i, ClanClass );
		ParseInt( Param, "FriendLevel"$i, ClanLevel );
		ParseInt( Param, "FriendLogon"$i, logon );
		
		//debug("친구 Name--->> " $ strName );
		//debug("친구 ClanClass--->> " $ string(ClanClass) );
		//debug("친구 ClanLevel--->> " $ string(ClanLevel) );
		
		addName[i] = strName;

		Record.LVDataList.length = 4;

		if( logon > 0 )
		{
			// 오프라인 일때 색 바꿈
			record.LVDataList[0].buseTextColor = True;
			record.LVDataList[0].TextColor = util.BrightWhite;
			record.LVDataList[1].buseTextColor = True;
			record.LVDataList[1].TextColor = util.BrightWhite;
		}
		else
		{
			// 오프라인 일때 색 바꿈
			record.LVDataList[0].buseTextColor = True;
			record.LVDataList[0].TextColor = util.White;
			record.LVDataList[1].buseTextColor = True;
			record.LVDataList[1].TextColor = util.White;
		}

		Record.LVDataList[0].szData = strName;
		Record.LVDataList[1].szData = string( ClanLevel );
		Record.LVDataList[2].szTexture = GetClassRoleIconName( ClanClass );
		Record.LVDataList[2].nTextureWidth = 11;
		Record.LVDataList[2].nTextureHeight = 11;
		Record.LVDataList[2].szData = String( ClanClass );
		Record.LVDataList[2].HiddenStringForSorting = String (GetClassRoleType( ClanClass ));

		Record.LVDataList[3].nTextureWidth = 31;
		Record.LVDataList[3].nTextureHeight = 11;
		
		// 혈맹 맴버 접속 상태 on, off 
		if( logon > 0 )
		{
			record.LVDataList[3].szData = "1";			// 쓸모 없는 데이터지만 소팅을 위해서 넣는다
			record.LVDataList[3].szTexture = "L2UI_CH3.BloodHoodWnd.BloodHood_Logon";
		}
		else 
		{
			record.LVDataList[3].szData = "0";
			record.LVDataList[3].szTexture = "L2UI_CH3.BloodHoodWnd.BloodHood_Logoff";		
		}	

		ClanList.InsertRecord(Record);
	}

}


// 혈맹 맴버 관련 리스트 컨트롤용, 레코드 세팉
function setClanMemberRecord (out LVDataRecord record, string param)
{
	// parse var
	local string name;
	local int classID, level, status;

	record.LVDataList.Length = 4;

	// parse
	ParseString(param, "Name", name);
	//ParseString(param, "memo", memo);

	ParseInt(param, "Class" , classID);
	ParseInt(param, "Level"   , level);
	// 특이하게 ID가 0이 아니면 접속 상태로 파악한다. 	
	ParseInt(param, "ID"  , status);

	// debug("status" @ status);
	if (status < 1)
	{
		ParseInt(param, "Status"  , status);
	}
	// debug("status:" @ status);

	// set 
	if( status > 0 )
	{
		// 오프라인 일때 색 바꿈
		record.LVDataList[0].buseTextColor = True;
		record.LVDataList[0].TextColor = util.BrightWhite;
		record.LVDataList[1].buseTextColor = True;
		record.LVDataList[1].TextColor = util.BrightWhite;
	}
	else
	{
		// 오프라인 일때 색 바꿈
		record.LVDataList[0].buseTextColor = True;
		record.LVDataList[0].TextColor = util.White;
		record.LVDataList[1].buseTextColor = True;
		record.LVDataList[1].TextColor = util.White;
	}

	record.LVDataList[0].szData = name;	
	record.LVDataList[1].szData = string(level);

	record.LVDataList[2].szData = string(classID);		// 쓸모 없는 데이터지만 소팅을 위해서 넣는다
	record.LVDataList[2].szTexture = GetClassRoleIconName(classID);
	record.LVDataList[2].HiddenStringForSorting = String(GetClassRoleType(classID));
	
	record.LVDataList[2].nTextureWidth = 11;
	record.LVDataList[2].nTextureHeight = 11;
	
	record.LVDataList[3].nTextureWidth = 31;
	record.LVDataList[3].nTextureHeight = 11;
	record.nReserved1 = 0;	// for additional information
		
	// 혈맹 맴버 접속 상태 on, off 
	if( status > 0 )
	{
		record.LVDataList[3].szData = "1";			// 쓸모 없는 데이터지만 소팅을 위해서 넣는다
		record.LVDataList[3].szTexture = "L2UI_CH3.BloodHoodWnd.BloodHood_Logon";
	}
	else 
	{
		record.LVDataList[3].szData = "0";
		record.LVDataList[3].szTexture = "L2UI_CH3.BloodHoodWnd.BloodHood_Logoff";		
	}	
}

// 혈맹 맴버 추가 핸들
function clanMemberAddedV2Handle (string param)
{
	local LVDataRecord record;

	setClanMemberRecord(record, param);

	// 레코드 한줄씩 추가
	ClanList.InsertRecord(record);
	// Debug("혈맹 맴버 리스트 추가 !: ");
}

// 혈맹 맴버 추가 핸들
function clanMemberInfoListEmptyHandle ()
{
	// 혈맹 맴버 리스트 삭제
	ClanList.DeleteAllItem();
	//Debug("혈맹 맴버 리스트 삭제!");
}

// 혈맹 맴버 추가 핸들
function clanMemberAddedHandle (string param)
{
	local LVDataRecord record;

	setClanMemberRecord(record, param);

	// 레코드 한줄씩 추가
	ClanList.InsertRecord(record);
	// Debug("혈맹 맴버 리스트 추가 !: ");
}

// 혈맹 맴버 삭제 핸들
function clanMemberRemovedHandle (string param)
{
	local string name;
	local int i;

	// parse
	ParseString(param, "Name", name);

	i = util.ctrlListSearchByName(ClanList, name);

	if (i != -1)
	{
		ClanList.DeleteRecord(i);
	}
}

// 혈맹 맴버 정보 업데이트
function clanMemberInfoUpdateHandle (string param)
{		
	local LVDataRecord record;
	local LVDataRecord tempRecord;
	local string name;
	local int i;

	// parse
	ParseString(param, "Name", name);

	setClanMemberRecord(record, param);

	for (i = 0; i < ClanList.GetRecordCount(); i++)
	{
		ClanList.GetRec(i, tempRecord);

		if (tempRecord.LVDataList[0].szData == name)
		{
			// 혈맹 맴버 삭제
			ClanList.ModifyRecord(i, record);
			// Debug("혈맹 맴버 리스트 수정 !: " @ name);			
			break;
		}
	}
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  인존 맴버 - 이벤트에 따른 처리 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 0번 부터 ...  번호로 구성
//
// 파티에서 인존 히스토리 핸들 
function InzonePartyHistoryUpdateHandler(string param)
{
	local string strRetName;
	local string treeName, rootName;

	local int NumberOfInzoneParty, NumberOfPartyMember,  InzoneTypeID, InzoneUseTimeYear, InzoneUseTimeMonth, InzoneUseTimeDay;
	local int InzoneClassID, InzoneStatus;

	local int inzoneCount, partyMemberCount;

	local string inzoneName, inzoneMemberName, listName, inzoneDate;

	// Debug("--- 인존 ---" @ param);

	treeName = "PersonalConnectionsDrawerWnd.AddWnd.InzoneTreeWnd.InzoneTree";
	rootName = "root";
	

	if (selectTreeNodeStr != "") InzoneTree.SetExpandedNode( selectTreeNodeStr, false );
	if (beforeSelectedTreePath != "") InzoneTree.SetExpandedNode( beforeSelectedTreePath, false );

	InzoneTree.Clear();
	listName = "";
	inzoneName = "";
	inzoneDate = "";
	inzoneMemberName = "";	
	inzoneSelectedParam = "";	
	// beforeSelectedTreePath = "";
	// selectTreeNodeStr = "";

	// parse
	ParseInt(param, "NumberOfInzoneParty", NumberOfInzoneParty);
	
	// root 만듬
	util.TreeInsertRootNode( treeName,  rootName, "", 0, 4 );

	// 인존 정보, 맴버 리스트 정보 얻기
	for (inzoneCount = 0; inzoneCount < NumberOfInzoneParty; inzoneCount++)
	{
		ParseInt(param, "NumberOfPartyMember" $ inzoneCount, NumberOfPartyMember);

		ParseInt(param, "InzoneUseTimeYear"   $ inzoneCount, InzoneUseTimeYear);
		ParseInt(param, "InzoneUseTimeMonth"  $ inzoneCount, InzoneUseTimeMonth);
		ParseInt(param, "InzoneUseTimeDay"    $ inzoneCount, InzoneUseTimeDay);

		ParseInt(param, "InzoneTypeID"        $ inzoneCount, InzoneTypeID);
		
		// Debug("::" @ NumberOfInzoneParty);
		// Debug("::" @ NumberOfPartyMember);
		// Debug("::" @ InzoneUseTime);
		// Debug("::" @ InzoneTypeID);
		// Debug("inzoneCount:" @ inzoneCount);
		
		// 1명 이상 이라면 + 노드 생성
		if (NumberOfInzoneParty > 0)
		{
			listName = "list" $ string(inzoneCount);
			// debug("1.listName : " @ listName);
			inzoneName = GetInZoneNameWithZoneID(InzoneTypeID);
			inzoneDate ="(" $ MakeFullSystemMsg( GetSystemMessage(2203), string(InzoneUseTimeMonth), string(InzoneUseTimeDay)) $ ")";
			// 2201
			//inzoneName = inzoneName + 
			util.TreeInsertExpandBtnNode( treeName, listName, rootName );

			listName = rootName $ "." $ listName;
			// debug("2.listName : " @ listName);
			// 심연의 미궁 같은..  글씨 
			util.TreeInsertTextNodeItem( treeName, listName, inzoneName, 5, 0, util.ETreeItemTextType.COLOR_DEFAULT, true );
			util.TreeInsertTextNodeItem( treeName, listName, inzoneDate, 5, 0, util.ETreeItemTextType.COLOR_GOLD, true );

			// Debug(":inzoneName:" @ inzoneName);

		}

		// Debug("NumberOfPartyMember: " @ NumberOfPartyMember);

		// 각 인존을 함께한 맴버 리스트
		for(partyMemberCount = 0; partyMemberCount < NumberOfPartyMember; partyMemberCount++)
		{
			ParseString(param, "Inzone" $ inzoneCount $ "_Name"    $ partyMemberCount, inzoneMemberName);
			ParseInt   (param, "Inzone" $ inzoneCount $ "_ClassID" $ partyMemberCount, InzoneClassID);
			ParseInt   (param, "Inzone" $ inzoneCount $ "_Status"  $ partyMemberCount, InzoneStatus);

			// Debug("inzoneMemberName:" @ inzoneMemberName);
			// Debug("InzoneClassID:" @ InzoneClassID);
			// Debug("InzoneStatus:" @ InzoneStatus);

			util.setCustomTooltip(getJobToolTip(InzoneClassID));
			//util.ToopTipMinWidth( 200 );

			// 노드 생성 
			strRetName = util.TreeInsertItemTooltipNode( treeName, "member" $ partyMemberCount, listName, -7, 0, 20, 0, 32, 20, util.getCustomTooltip());
			
			inzoneSelectedParam = inzoneSelectedParam $ " " $ strRetName $ "=" $ inzoneMemberName;
			// 맴버, 배경, 텍스쳐 , (진한거 , 홀짝)
			if ((partyMemberCount % 2) == 0) util.TreeInsertTextureNodeItem( treeName, strRetName, "L2UI_CH3.etc.textbackline", 257, 18, 16, 0, , ,14 );
			else util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_CT1.EmptyBtn", 257, 18, 16, 0, , , 14);

			// 직업 (클래스)
			util.TreeInsertTextureNodeItem( treeName, strRetName, GetClassRoleIconName(InzoneClassID), 11, 11, -108, 3 );

			if (InzoneStatus > 0)
			{
				// 접속 상태 on
				util.TreeInsertTextureNodeItem( treeName, strRetName, "L2UI_CH3.BloodHoodWnd.BloodHood_Logon", 31, 11, 25, 3 );
			}
			else 
			{
				// 접속 상태 off 
				util.TreeInsertTextureNodeItem( treeName, strRetName, "L2UI_CH3.BloodHoodWnd.BloodHood_Logoff", 31, 11, 25, 3 );
			}

			// 캐릭터 이름 
			util.TreeInsertTextNodeItem( treeName, strRetName, inzoneMemberName, -211, 2);
		}
	}

}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  인맥 관련 공용 함수 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/* 현재 선택되어진 리스트에서 이름 스트링을 리턴한다. */
function string getUserNameByList()
{	
	local LVDataRecord record;
	
	local int tabIndex;
	local int selectedIndex;
	local string returnStr;
	
	returnStr = "";

	tabIndex = AddWndTab.GetTopIndex();	

	// - 현재 탭의 상태- 
	// [혈맹 목록]
	if (tabIndex == 1)
	{	
		// 목록이 하나라도 선택되었다면..
		selectedIndex = ClanList.GetSelectedIndex();
		if (selectedIndex != -1)
		{
			//record = util.getListSelectedRecord(ClanList, selectedIndex);

			ClanList.GetSelectedRec(record);
			returnStr = record.LVDataList[0].szData;
		}
	}
	// [인존 이력]
	else if (tabIndex == 2)
	{	
		// Debug("인존..");
	}
    else 
    {
		// 시스템 메세지 출력
		// 목록을 선택해!
		AddSystemMessage(3314);	
    }

	return returnStr;	
}

/**
 *  하나의 윈도우를 열어 준다.
 **/
function showSelectWindow(string windowName)
{
	// 모두 숨기고..
	AddWnd.HideWindow();
	NameEnterWnd.HideWindow();
	ClanListWnd.HideWindow();
	InzoneTreeWnd.HideWindow();
	DetailInfoWnd.HideWindow();
	MenteeSearchWnd.HideWindow();

	AddListBtn.ShowWindow();
	CloseBtn.ShowWindow();

	// Debug("창 열기 ----> " @ windowName);
	switch (windowName)
	{
		case "AddWnd"          : AddWnd.ShowWindow();
							     AddWndTab.SetTopOrder(0,false);
							     NameEnterEditbox.SetFocus();
							     break;

		case "NameEnterWnd"    : NameEnterWnd.ShowWindow();  
							     break;

		case "ClanListWnd"     : ClanListWnd.ShowWindow();  
							     AddWndTab.SetTopOrder(1,false);
							     break;

		case "InzoneTreeWnd"   : InzoneTreeWnd.ShowWindow();  
							     AddWndTab.SetTopOrder(2,false);
							     break;

		case "DetailInfoWnd"   : DetailInfoWnd.ShowWindow();  
							     break;

		case "MenteeSearchWnd" : MenteeSearchWnd.ShowWindow();
								 AddWndTab.SetTopOrder(2,false);
							     break;
	}

	// 탭 이름 변경
	switch(PersonalConnectionsWndScript.ConnectionsListSelectTab.GetTopIndex())
	{
		// 친구
		case 0 : AddWndTab.SetButtonName(2, GetSystemString(2392)); break; // 인존 이력 
		// 차단
		case 1 : AddWndTab.SetButtonName(2, GetSystemString(2392)); break;
		// 멘토링
		case 2 : AddWndTab.SetButtonName(2, GetSystemString(2784)); break; // 멘티 검색 
	}
}


/**
 *  상세 정보 세팅 
 **/
function setDetailInfo (string name, int level, int classID, int pledgeCrestId, int allianceCrestId, 
						int birthMonth, int birthDay, int logoutDiffSeconds, string memo)
{	
	// 혈맹 , 동맹 텍스쳐
	local texture texPledge, texAlliance;

	local string pledgeName, allianceName;

	// 클래스 타입 
	local string classTypeStr;
	
	local bool bPledge, bAlliance;
	local Rect rectWnd;

	rectWnd = DetailInfoWnd.GetRect();	
	
	// 이름 
	GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.TargetNameText" ).SetText(name);

	// 블럭 유저 정보 보기인 경우 
	if ((level + classID + pledgeCrestId + allianceCrestId + birthMonth + birthDay + logoutDiffSeconds) == 0)
	{		
		GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.BlockInfoText").ShowWindow();

		// Set textbox 
		// GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.TargetNameText" ).SetText("");
		GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.TargetStatusText" ).SetText(GetSystemString(2394));
		GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.Level" ).SetText("");

		GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.job" ).SetText("");
		GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.Clan" ).SetText("");
		GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.Union" ).SetText("");

		GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.BirthDay" ).SetText("");
		
		GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.FinalConnect" ).SetText("");

		GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.LevelTitle" ).HideWindow();
		GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.JobTitle" ).HideWindow();
		GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.ClanTitle" ).HideWindow();
		GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.UnionTitle" ).HideWindow();
		GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.BirthDayTitle" ).HideWindow();
		GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.FinalConnectTitle" ).HideWindow();

	}
	else 
	{
		GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.BlockInfoText").HideWindow();

		// Debug("pledgeCrestId : " @ pledgeCrestId);
		// Debug("allianceCrestId : " @ allianceCrestId);
		// 혈맹, 동맹 이름 
		pledgeName = class'UIDATA_CLAN'.static.GetName(pledgeCrestId);
		allianceName = class'UIDATA_CLAN'.static.GetAllianceName(pledgeCrestId);
		
		// Debug("pledgeName :" @ pledgeName);
		// Debug("allianceName :" @ allianceName);
		
		// 텍스쳐
		texPledge   = GetPledgeCrestTexFromPledgeCrestID(pledgeCrestId);
		texAlliance = GetAllianceCrestTexFromAllianceCrestID(allianceCrestId);	

		// 클래스 타입 
		classTypeStr = GetClassType(classID);

		// 혈맹 동맹, 이미지 얻어오기 
		bPledge   = class'UIDATA_CLAN'.static.GetCrestTexture(pledgeCrestId, texPledge);
		bAlliance = class'UIDATA_CLAN'.static.GetAllianceCrestTexture(pledgeCrestId, texAlliance);

		texPledgeCrest.SetTextureWithObject(texPledge);
		texPledgeAllianceCrest.SetTextureWithObject(texAlliance);

		texPledgeCrest.HideWindow();
		texPledgeAllianceCrest.HideWindow();

		GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.Clan" ).ClearAnchor();
		GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.Union" ).ClearAnchor();
		// 혈맹, 동맹 텍스쳐 
		if (bPledge)
		{
			texPledgeCrest.ShowWindow();
			GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.Clan" ).MoveTo(rectWnd.nX + 118 , rectWnd.nY + 156 + 4);			
		}
		else
		{
			texPledgeCrest.HideWindow();
			GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.Clan" ).MoveTo(rectWnd.nX + 98 , rectWnd.nY + 156 + 4);
		}

		if (bAlliance) 
		{
			texPledgeAllianceCrest.ShowWindow();
			GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.Union" ).MoveTo(rectWnd.nX + 110 , rectWnd.nY + 178 + 4);			
		}
		else 
		{
			texPledgeAllianceCrest.HideWindow();
			GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.Union" ).MoveTo(rectWnd.nX + 98 , rectWnd.nY + 178 + 4);			
		}
		
		// Set textbox 		
		GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.Level" ).SetText(string(level));

		GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.job" ).SetText(classTypeStr);
		GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.Clan" ).SetText(pledgeName);
		GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.Union" ).SetText(allianceName);

		GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.BirthDay" ).SetText(MakeFullSystemMsg(GetSystemMessage(2203), 
																						  string(birthMonth), string(birthDay)));

		GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.LevelTitle" ).ShowWindow();
		GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.JobTitle" ).ShowWindow();
		GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.ClanTitle" ).ShowWindow();
		GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.UnionTitle" ).ShowWindow();
		GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.BirthDayTitle" ).ShowWindow();
		GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.FinalConnectTitle" ).ShowWindow();
		
		// Debug("logoutDiffSeconds :" @ logoutDiffSeconds);
		if (logoutDiffSeconds <= -1)
		{
			GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.TargetStatusText" ).SetText(GetSystemString(347));
			GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.FinalConnect" ).SetText(GetSystemString(2401));
			
		}
		else 	
		{
			// 현재 접속중
			// 해당 유저가 접속중인 경우..
			GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.TargetStatusText" ).SetText(GetSystemString(348));
			GetTextBoxHandle( "PersonalConnectionsDrawerWnd.DetailInfoWnd.FinalConnect" ).SetText(getConnectInfoTimeMessage(logoutDiffSeconds / 60));
		}
	}

	/*
		native static function string GetName(int ID);
		native static function string GetAllianceName(int ID);
		native static function bool GetCrestTexture(int ID, out texture texCrest);
		native static function bool GetEmblemTexture(int ID, out texture emblemTexture);
		native static function bool GetAllianceCrestTexture(int ID, out texture texCrest);
		native static function bool	GetNameValue( int ID, out int namevalue );
		native static function RequestClanInfo();		// 전체 혈맹 정보를 초기화 하고 새로 클라이언트에서 정보를 보내 준다.
		native static function RequestClanSkillList();
		native static function RequestSubClanSkillList(int subClanIndex);
		native static function int GetSkillLevel(int skillID);
		native static function int GetSubClanSkillLevel(int skillID, int subClanIndex);
	 */
	
	// Debug("서버에서온 memo MemoContents.SetString(memo) -> " @ memo);
	
	// 메모
	MemoContents.SetString(memo);		

}

/**  접속 정보 스트링 리턴 , 분을 입력 -> 현재 접속중.. ~시간,  분전 시간 전 일 전 개월 전 년 이상.. 이런식으로 표현 */
function string getConnectInfoTimeMessage(int minute)
{
	local string returnStr;

	local int value;
	returnStr = "";

	// 3294	$s1분 전
	if (minute < 60)
	{
		returnStr = MakeFullSystemMsg(GetSystemMessage(3294), string(minute));
	}
	// 3295	$s1시간 전
	else if (minute < (60 * 24))
	{
		value = minute / 60;
		returnStr = MakeFullSystemMsg(GetSystemMessage(3295),string(value));
	}

	// 3296	$s1일 전
	else if (minute < (60 * 24 * 30) )
	{
		value = minute / 60 / 24;
		returnStr = MakeFullSystemMsg(GetSystemMessage(3296), string(value));
	}
	// 3297	$s1개월 전
	else if (minute < (60 * 24 * 365) )
	{
		value = minute / 60 / 24 / 30;
		returnStr = MakeFullSystemMsg(GetSystemMessage(3297), string(value));
	}
	// 3298	$s1년 이상
	else if (minute > (60 * 24 * 365) )
	{
		value = minute / 60 / 24 / 30;
		returnStr = MakeFullSystemMsg(GetSystemMessage(3297), string(value));
	}

	return returnStr;
}


/**
 *  툴팁 ,직업 정보
 */
function CustomTooltip getJobToolTip (int job)
{
	local CustomTooltip m_Tooltip;

	m_Tooltip.DrawList.Length = 1;	
	m_Tooltip.DrawList[0].eType = DIT_TEXT;
	m_Tooltip.DrawList[0].t_strText = GetSystemString(391) $ " : " $ GetClassType(job);

	return m_Tooltip;
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( "PersonalConnectionsDrawerWnd" ).HideWindow();
}

/*

//root
util.TreeInsertRootNode( TREENAME, ROOTNAME, "", 0, 4 );

 // + 
 util.TreeInsertExpandBtnNode( TREENAME, "LIST1", ROOTNAME );

// 심연의 미궁 글씨 
util.TreeInsertTextNodeItem( TREENAME, ROOTNAME$"."$"LIST1", GetSystemString(2370), 5, 0, util.ETreeItemTextType.COLOR_DEFAULT, true );



  for()
   je
   박스  각 유저 리스트
   //strRetName = util.TreeInsertItemTooltipSimpleNode( TREENAME, ""$ iID $","$ iLevel, ROOTNAME$"."$"LIST1", -7, 0, 38, 0, 32, 38, util.getCustomTooltip() );
	 
	 // 진한거 , 홀짝
	 util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_CH3.etc.textbackline", 257, 38, , , , ,14 );
	 util.TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_CT1.EmptyBtn", 257, 38 );

	//Insert Node Item - 아이템 이름
	util.TreeInsertTextNodeItem( TREENAME, strRetName, strName, 5, 5, util.ETreeItemTextType.COLOR_DEFAULT, true );
		//Insert Node Item - 아이템 아이콘
		util.TreeInsertTextureNodeItem( TREENAME, strRetName, strIconName, 32, 32, -34, OFFSET_Y_ICON_TEXTURE - 1 );

			//Insert Node Item - 아이템 아이콘
		util.TreeInsertTextureNodeItem( TREENAME, strRetName, strIconName, 32, 32, -34, OFFSET_Y_ICON_TEXTURE - 1 );

	util.TreeInsertExpandBtnNode( TREENAME, "LIST1", ROOTNAME );


*/
defaultproperties
{
}
