////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Program ID : 인맥 관리 시스템 , 멘티 멘토 시스템 
//  Memo       : 멘티멘토 자료: http://lineage2:8080/wiki/moin.cgi/_b8_e0_c5_e4_b8_e0_c6_bc#line28
//
//  개발자 참고: 클라 정동형, 서버 : 윤가영
//  빌드 명령  :  //make_mentee_list 를 치면 200명 멘티 대기자 리스트를 200개 임의로 생성. 서버가 켜 있는 동안 한번만 입력 할 것.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class PersonalConnectionsWnd extends UICommonAPI;

const FRIENDLIST_LIMIT = 128;
const BLOCKLIST_LIMIT = 512; //128; 확장함

const MENTEE_LIST_LIMIT = 3;
const MENTOR_LIST_LIMIT = 1;

const DIALOG_PersonalConnectionFriendListRemove = 90007;
const DIALOG_PersonalConnectionBlockListRemove  = 90008;
const DIALOG_PersonalConnectionMenteeListRemove = 90020;


const DIALOG_PersonalConnectionConfirmMentee    = 90021;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  XML UI 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
var WindowHandle  Me;
var PersonalConnectionsDrawerWnd  m_PersonalConnectionsDrawerWnd;

var TabHandle     ConnectionsListSelectTab;
var TextureHandle ConnectionsListSelectTabBgLine;

var TextureHandle TexTabBg;

var TextBoxHandle ListTitle;
var TextBoxHandle ListCount;

var ButtonHandle ListPlusBtn;
var ButtonHandle ListMinusBtn;
var ButtonHandle ListBlockBtn;

var TextureHandle ListDeco;

var ListCtrlHandle FriendList;
var ListCtrlHandle BlockList;
var ListCtrlHandle MentoringList;

var TextureHandle GroupBox1;
var TextureHandle GroupBox2;

var ButtonHandle InvitePartyBtn;
var ButtonHandle SendPostBtn;
var ButtonHandle InviteClanBtn;
var ButtonHandle WhisperBtn;
var ButtonHandle DetailInfoBtn;
var ButtonHandle OneOnOneTalkBtn;

// 이전에 선택했던 친구 리스트 인덱스 
var int selectedFriendListIndex;
var int selectedBlockListIndex;

// 클랜 가입을 시켜줄 권한 여부 (1 있다, 0 없다)
var int          nClanJoin;
var L2Util       util;

//  내가 Mentor일경우 1, Mentee일경우 2, 처음 신청해서 리스트에 한명도 없는데 거부했을경우에는 0
var int mentorMenTeeRole;

var TextBoxHandle GuideTitle;
var TextBoxHandle Guide;

var TextureHandle GroupBox_MentoringList1;
var TextureHandle GroupBox_MentoringList2;
var TextureHandle GroupBox_FriendBlockList;

var UserInfo      MyUserInfo;

//계약 해지 남은 시간
var TextBoxHandle   NameEnterLimit;
var TextBoxHandle   NameEnterLimitTime;

var string mentorName;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Struct 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// 인맥 관리 유저 정보
struct relationMemberInfo
{
	var string  name;      // 이름
	var int		userID;    // 유저ID 
	var int		classID;   // 클래스 ID (역활)
	var int		level;     // 레벨
	var bool	bOnline;   // 접속 여부
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 관련 변수
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// 인맥 관리 리스트
var array<relationMemberInfo> friendListArray; //   친구 맴버 리스트 배열
var array<relationMemberInfo> clanListArray;   //   혈맹 유저 리스트 배열
var array<relationMemberInfo> blockListArray;  // 차단된 유저 리스트 배열



// 인스턴스 존 이력은 별도로 데이터로 관리 하지 않고
// 트리를 그때 그때 생성 삭제 한다.
// 실시간으로 각 유저의 접속 정보가 반영 되지 않기 때문이다. 


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 초기화 관련 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function OnRegisterEvent()
{
	//RegisterEvent(  );
	RegisterEvent( EV_Restart );

	// 현재 내 클랜 정보 받기
	registerEvent( EV_ClanMyAuth );

	// 차단 목록 
	registerEvent( EV_BlockInfoListEmpty );
	registerEvent( EV_BlockAdded );
	registerEvent( EV_BlockRemoved );				
	registerEvent( EV_BlockInfoUpdate );
	registerEvent( EV_BlockDetailInfoUpdate );

	// 친구 목록
	registerEvent( EV_FriendInfoListEmpty );
	registerEvent( EV_FriendAdded );
	registerEvent( EV_FriendRemoved );
	registerEvent( EV_FriendInfoUpdate );

	registerEvent( EV_FriendDetailInfoUpdate );
	registerEvent( EV_ShowPersonalConnectionWnd );
	registerEvent( EV_NotifyImportedCrestImage );

	////////////////////////////////////////
	// 멘티 멘토 시스템
	////////////////////////////////////////
	// 멘티 신청 다이얼로그 띄우는 이벤트
	registerEvent(EV_ConFirmMentee);
	// 멘티/멘토 리스틀을 받기 시작 
	registerEvent(EV_MentorMenteeListStart);
	// 각 맴버별 , 하나씩 이벤트 받기 (사람 수)
	registerEvent(EV_MentorMenteeListInfo);

	// 기타..
	registerEvent(EV_DialogOK);
	registerEvent(EV_DialogCancel);

	RegisterEvent(EV_NeedResetUIData);


}

function OnLoad()
{	 
	SetClosingOnESC();

	util = L2Util(GetScript("L2Util"));

	// 초기화 
	Initialize();
	Load();

	ConnectionsListSelectTab.SetDisable(2, true);

	selectedFriendListIndex = -1;
	selectedBlockListIndex = -1;
	GetPlayerInfo(MyUserInfo);

}

function OnShow()
{
	// class'UIDATA_CLAN'.static.RequestClanInfo();
	// class'UIDATA_CLAN'.static.RequestClanInfo();

	mentorName = "";
	
	class'PersonalConnectionAPI'.static.RequestFriendInfoList();  // 친구 리스트 갱신 
	class'PersonalConnectionAPI'.static.RequestBlockInfoList();   // 차단 리스트 갱신

	// 아레나에서는 사용 하지 않음.
	if ( ! getInstanceUIData().getIsArenaServer() ) 
		class'PersonalConnectionAPI'.static.RequestMentorList();      // 멘티멘토 리스트 갱신

	GetPlayerInfo(MyUserInfo);

	listTextUpdate();
	checkClanButtonState();

	// 멘토링 텝인 경우 멘토링 가이드를 보여줌. 
	if ( ConnectionsListSelectTab.GetTopIndex() == 2 ) 		
	{
		GuideTitle.ShowWindow();
		Guide.ShowWindow();
	}
	else 
	{			
		GuideTitle.HideWindow();
		Guide.HideWindow();
	}
}

function checkClassicForm() 
{
	if ( getInstanceUIData().getisClassicServer()  )
	{
		//ConnectionsListSelectTab.RemoveTabControl( 2 ) ; 이걸 몰랐나 봄....
		ConnectionsListSelectTab.SetTopOrder(0, false);
		ConnectionsListSelectTab.SetButtonDisableTexture(2, "L2UI_ct1.Misc_DF_Blank");
		ConnectionsListSelectTab.SetDisable(2, true);
		ConnectionsListSelectTab.SetButtonName(2, "");
		ConnectionsListSelectTabBgLine.SetWindowSize( 137 , 24);
		//ConnectionsListSelectTabBgLine.SetAnchor( "PersonalConnectionsWnd", "TopLeft", "TopRight", 340 , 5);	
		
	}
	else if ( getInstanceUIData().getIsArenaServer() ) 
	{
		ConnectionsListSelectTab.RemoveTabControl( 2 ) ;
		ConnectionsListSelectTabBgLine.SetWindowSize( 137 , 24);
		OneOnOneTalkBtn.SetAnchor( "PersonalConnectionsWnd.InviteClanBtn", "TopLeft", "TopLeft", 0, 0 ) ;
		InviteClanBtn.HideWindow();
	}
	else 
	{			
		ConnectionsListSelectTab.SetButtonName(2, getSystemString (2767));
		ConnectionsListSelectTab.SetDisable(2, false);
		ConnectionsListSelectTabBgLine.SetWindowSize( 74 , 24);
		//ConnectionsListSelectTabBgLine.SetAnchor( "PersonalConnectionsWnd", "TopLeft", "TopRight", 340 , 5);	
	}
}

function Initialize()
{
	Me = GetWindowHandle( "PersonalConnectionsWnd" );

	// 서랍 보조창
	m_PersonalConnectionsDrawerWnd = PersonalConnectionsDrawerWnd(GetScript( "PersonalConnectionsDrawerWnd" ));

	ConnectionsListSelectTab       = GetTabHandle( "PersonalConnectionsWnd.ConnectionsListSelectTab" );
	ConnectionsListSelectTabBgLine = GetTextureHandle( "PersonalConnectionsWnd.ConnectionsListSelectTabBgLine" );

	TexTabBg        = GetTextureHandle( "PersonalConnectionsWnd.TexTabBg" );
	ListDeco        = GetTextureHandle( "PersonalConnectionsWnd.ListDeco" );

	ListTitle       = GetTextBoxHandle( "PersonalConnectionsWnd.ListTitle" );
	ListCount       = GetTextBoxHandle( "PersonalConnectionsWnd.ListCount" );

	ListPlusBtn     = GetButtonHandle( "PersonalConnectionsWnd.ListPlusBtn" );
	ListMinusBtn    = GetButtonHandle( "PersonalConnectionsWnd.ListMinusBtn" );
	ListBlockBtn    = GetButtonHandle( "PersonalConnectionsWnd.ListBlockBtn" );

	FriendList      = GetListCtrlHandle( "PersonalConnectionsWnd.FriendList" );
	BlockList       = GetListCtrlHandle( "PersonalConnectionsWnd.BlockList" );
	MentoringList   = GetListCtrlHandle( "PersonalConnectionsWnd.MentoringList" );

	GroupBox1       = GetTextureHandle( "PersonalConnectionsWnd.GroupBox1" );
	GroupBox2       = GetTextureHandle( "PersonalConnectionsWnd.GroupBox2" );

	InvitePartyBtn  = GetButtonHandle( "PersonalConnectionsWnd.InvitePartyBtn" );
	SendPostBtn     = GetButtonHandle( "PersonalConnectionsWnd.SendPostBtn" );
	InviteClanBtn   = GetButtonHandle( "PersonalConnectionsWnd.InviteClanBtn" );
	WhisperBtn      = GetButtonHandle( "PersonalConnectionsWnd.WhisperBtn" );
	DetailInfoBtn   = GetButtonHandle( "PersonalConnectionsWnd.DetailInfoBtn" );
	OneOnOneTalkBtn = GetButtonHandle( "PersonalConnectionsWnd.OneOnOneTalkBtn" );
	
	GuideTitle = GetTextBoxHandle( "PersonalConnectionsWnd.GuideTitle" );
	Guide      = GetTextBoxHandle( "PersonalConnectionsWnd.Guide" );

	NameEnterLimit     = GetTextBoxHandle( "PersonalConnectionsDrawerWnd.AddWnd.NameEnterLimit" );
	NameEnterLimitTime = GetTextBoxHandle( "PersonalConnectionsDrawerWnd.AddWnd.NameEnterLimitTime" );
	

	GroupBox_MentoringList1       = GetTextureHandle( "PersonalConnectionsWnd.GroupBox_MentoringList1" );
	GroupBox_MentoringList2       = GetTextureHandle( "PersonalConnectionsWnd.GroupBox_MentoringList2" );

	GroupBox_FriendBlockList      = GetTextureHandle( "PersonalConnectionsWnd.GroupBox_FriendBlockList" );


	GuideTitle.HideWindow();
	Guide.HideWindow();

	// 각 탭 상태에 따라 텍스쳐 변경 
	setTextureVisible(0);

	// 2384 차단 목록
	// 2385 친구 목록
	
	GuideTitle.SetText(GetSystemString(2773));
	Guide.SetText(GetSystemString(2770));
	
	// 2010.10 CT3에서 사용 안함. 하지만 추후 MSN과 붙은 친구 대화 부분을 삭제 하고 추후 지원 예정
	// OneOnOneTalkBtn.HideWindow();

	listTextUpdate();	
}

function Load()
{
	// .. empty
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 이벤트 -> 해당 이벤트 처리 핸들러
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function OnEvent( int Event_ID, string param )
{
	//Debug("인맥 관리 " @ Event_ID);
	//Debug("param: " @ param);
	switch( Event_ID )
	{
		case EV_Restart :
			 restartHandler();
			 break;

		case EV_ClanMyAuth:

			 Debug("EV_ClanMyAuth : " @ param);
			 HandleClanMyAuth( param );
			 break;

		// 친구 목록 
		case EV_FriendInfoListEmpty :
			 friendInfoListEmptyHandle();			 
			 break;

		case EV_ShowPersonalConnectionWnd :
			 Me.ShowWindow();
			 break;

		case EV_FriendAdded :
			 friendAddedHandle(param);
			 listTextUpdate();
			 break;

		case EV_FriendRemoved :
			 friendRemovedHandle(param);
			 listTextUpdate();
			 break;

		case EV_FriendInfoUpdate :
			 friendInfoUpdateHandle(param);
			 listTextUpdate();
			 break;

		case EV_FriendDetailInfoUpdate :
			 userDetailInfoUpdateHandle(param);
			 listTextUpdate();
			 break;

		// 차단 목록
		case EV_BlockInfoListEmpty :
			 BlockList.DeleteAllItem();
			 break;

		case EV_BlockAdded :
			 blockAddedHandler(param);
			 listTextUpdate();
			 break;

		case EV_BlockInfoUpdate :
			 blockInfoUpdateHandler(param);
			 listTextUpdate();
			 break;

		case EV_BlockDetailInfoUpdate :
			 blockDetailInfoUpdateHandler(param);
			 listTextUpdate();
			 break;

		case EV_BlockRemoved :
			 blockRemovedHandler(param);
			 listTextUpdate();
			 break;
		
		// 인존 목록
		case EV_InzonePartyHistoryUpdate :
			 break;

 		case EV_NotifyImportedCrestImage:
			 // notifyImportedCrestImageHandler(param);
			 break;

		case EV_DialogOK:
		 	 HandleDialogOK();
			 break;

		 case EV_DialogCancel:
			 HandleDialogCancel();
			 break;

		// 멘티 멘토 리스트 받기 시작 
		case EV_MentorMenteeListStart :			 
			 mentorMenteeListStartHandler(param);
			 break;

		// 멘토/멘티 유저 추가
		case EV_MentorMenteeListInfo  :
			 menTorMenTeeAddedHandle(param);
			 listTextUpdate();
			 break;

		// 맨티 들에게 멘토가 신청을 했을때 
		case EV_ConFirmMentee : 
			 conFirmMenteeDialogHandler(param);
			 break;

		case EV_NeedResetUIData :
			checkClassicForm();
			 break;
	}
}

/** 탭 상태에 따른 텍스쳐 변경 */
function setTextureVisible(int tabIndex)
{
	switch (tabIndex)
	{
		// 친구, 차단탭
		case 0:
		case 1:
				GroupBox_MentoringList1.DisableWindow();
				GroupBox_MentoringList2.DisableWindow();
				GroupBox_FriendBlockList.ShowWindow();
				NameEnterLimit.HideWindow();
				NameEnterLimitTime.HideWindow();
				
				break;

		// 멘토탭
		case 2:
				GroupBox_MentoringList1.ShowWindow();
				GroupBox_MentoringList2.ShowWindow();
				GroupBox_FriendBlockList.DisableWindow();
				NameEnterLimit.ShowWindow();
				NameEnterLimitTime.ShowWindow();
				break;
	}
}

/**
 *  멘티, 멘토 정보 받기 시작 핸들 
 **/ 
function mentorMenteeListStartHandler (string param)
{

	GetPlayerInfo(MyUserInfo);

	// 리스트 삭제	
	MentoringList.DeleteAllItem();

	// 멘토/ 멘티 상태 받기 
	ParseInt(param, "Role", mentorMenTeeRole);
	
	// Debug("mentorMenTeeRole" @ mentorMenTeeRole);
	// Debug("param" @ param);

	switch (mentorMenTeeRole)
	{
				 // 멘토, 멘티가 아닌 경우mentorMenTeeRole 값이 0, 하지만 
		case 0 : // 각성 했고, 85랩 보다 같거나 크다면 멘토가 될 수 있다(멘토 탭 활성화)
				 if (MyUserInfo.nLevel >= 85 && GetClassTransferDegree( MyUserInfo.nSubClass ) > 3) ConnectionsListSelectTab.SetDisable(2, false); 
				 // 멘토링 탭 비활성화
				 else 
				 {
				    ConnectionsListSelectTab.SetDisable(2, true); 
				    // 비활성화 되면 , 친구탭으로 이동 
				    ConnectionsListSelectTab.SetTopOrder(0,false);
				 }
				 break;

		case 1 : // 멘토인 경우 
				 // 멘토링 탭 비활성화
				 ConnectionsListSelectTab.SetDisable(2, false); 
				 break;

		case 2 : // 멘티인 경우 
			     // 멘토링 탭 비활성화
				 ConnectionsListSelectTab.SetDisable(2, false);
				 break;

		default: // 0, 1, 2 가 아닌 값이 올수 없다. 아래 메세지가 출력 되면 에러 상태임
				 Debug("Error : mentorMenTeeRole :" @ mentorMenTeeRole);
	}	

	listTextUpdate();

}

// 멘토, 멘티 추가 
function menTorMenTeeAddedHandle (string param)
{
	local LVDataRecord record;
	
	setListRecord(record, param);

	// 친구 리스트에 추가 
	MentoringList.InsertRecord(record);
}


/**
 * 멘토-> 멘티에게 
 * 멘티 수락을 요청했을때 나오는 다이얼로그 
 **/
function conFirmMenteeDialogHandler (string param)
{
	askDialog(DIALOG_PersonalConnectionConfirmMentee, param);
}

/** 리스타트 초기화 */
function restartHandler()
{	
	// 보조창이 열려 있다면.. 닫는다.
	subWindowClose();
	buttonsEnabled(true);
	//ConnectionsListSelectTab.setT
	ConnectionsListSelectTab.SetTopOrder(0,false);
	OnShow();
}

/** 중간에 동맹 혈맹 이미지가 업데이트 되었다고 알림 이벤트가 들어 오면 갱신 (친구쪽에만 나오기 때문) */
function notifyImportedCrestImageHandler(string param)
{
	OnClickListCtrlRecord("FriendList");
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 친구 - 이벤트에 따른 처리 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// 친구 관련 리스트 컨트롤용, 레코드 세팅
// 친구, 멘티 리스트 세팅
function setListRecord (out LVDataRecord record, string param)
{
	// parse var
	local string name, memo;
	local int classID, level, status;
	local Color TextColor;

	record.LVDataList.Length = 4;
	
	// parse
	ParseString(param, "Name", name);
	ParseString(param, "memo", memo);

	ParseInt(param, "ClassID" , classID);
	ParseInt(param, "Level"   , level);
	ParseInt(param, "Status"  , status);
	
	// set 
	TextColor = util.White;
	
	//branch GD35_0828 2014-1-13 luciper3 - 배우자 온라인은 핫핑크, 배우자 오프라인은 연핑크로 한다.
	if( status == 1 )
		TextColor = util.BrightWhite;
	else if( status == 2 )
		TextColor = util.PowderPink;
	else if( status == 3 )
		TextColor = util.HotPink;
	//end of branch

	// 온라인 일때 색 바꿈
	record.LVDataList[0].buseTextColor = True;
	record.LVDataList[0].TextColor     = TextColor;
	record.LVDataList[1].buseTextColor = True;
	record.LVDataList[1].TextColor     = TextColor;

// 	if( status > 0 )
// 	{ 
// 		// 오프라인 일때 색 바꿈
// 		record.LVDataList[0].buseTextColor = True;
// 		record.LVDataList[0].TextColor     = util.BrightWhite;
// 		record.LVDataList[1].buseTextColor = True;
// 		record.LVDataList[1].TextColor     = util.BrightWhite;
// 
// 
// 	}
// 	else
// 	{
// 		// 오프라인 일때 색 바꿈
// 		record.LVDataList[0].buseTextColor = True;
// 		record.LVDataList[0].TextColor     = util.White;
// 		record.LVDataList[1].buseTextColor = True;
// 		record.LVDataList[1].TextColor     = util.White;
// 	}
		
	// 메모에 대한 툴팁 출력용 
	record.szReserved = memo;
	
	//record.LVDataList[0].buseTextColor = True;
	record.LVDataList[0].szData = name;
	// record.LVDataList[0].TextColor = util.Gold;
	// record.LVDataList[1].buseTextColor = True;
	// record.LVDataList[1].TextColor = util.White;
	record.LVDataList[1].szData = string(level);
	record.LVDataList[2].szData = string(classID);		         // 쓸모 없는 데이터지만 소팅을 위해서 넣는다
	record.LVDataList[2].szTexture = GetClassRoleIconName(classID);
	Record.LVDataList[2].HiddenStringForSorting = String (GetClassRoleType( classID ));
	
	record.LVDataList[2].nTextureWidth = 11;
	record.LVDataList[2].nTextureHeight = 11;
	
	record.LVDataList[3].nTextureWidth = 31;
	record.LVDataList[3].nTextureHeight = 11;
	record.nReserved1 = 0;	// for additional information
		
	// 친구의 접속 상태 on, off 
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
	// FriendList.SetTooltipCustomType(getMemoToolTip(classID, memo));	
}

// 친구 초기화 핸들
function friendInfoListEmptyHandle ()
{
	// 친구 리스트 삭제
	FriendList.DeleteAllItem();	
	//Debug("친구 리스트 삭제!");
}

// 친구 추가 핸들
function friendAddedHandle (string param)
{
	local LVDataRecord record;
	
	setListRecord(record, param);

	// 친구 리스트에 추가 
	FriendList.InsertRecord(record);
}

// 친구 삭제 핸들
function friendRemovedHandle (string param)
{
	local string name;
	local int i;

	// parse
	ParseString(param, "Name", name);

	i = util.ctrlListSearchByName(FriendList, name);

	if (i != -1)
	{
		FriendList.DeleteRecord(i);
	}

	// 차단 목록이 하나도 없다면.. 창 닫는다.
	if (FriendList.GetRecordCount() <= 0) subWindowClose();
	else 
	{  
		// 최하단의 항목을 삭제 한 경우 바로 위로 포커스를 가지도록 한다.
		if (FriendList.GetSelectedIndex() == FriendList.GetRecordCount()) 
		{			
			FriendList.SetSelectedIndex(FriendList.GetSelectedIndex() - 1, false);
		}

		OnClickListCtrlRecord("FriendList");
	}
}

// 친구 정보 업데이트
function friendInfoUpdateHandle (string param)
{		
	local LVDataRecord record;
	local LVDataRecord tempRecord;
	local string name;
	local int i;

	FriendList.ClearTooltip();

	// parse
	ParseString(param, "Name", name);

	setListRecord(record, param);

	for (i = 0; i < FriendList.GetRecordCount(); i++)
	{
		FriendList.GetRec(i, tempRecord);
		if (tempRecord.LVDataList[0].szData == name)
		{
			// 친구 삭제			
			FriendList.ModifyRecord(i, record);
			// Debug("친구 리스트 수정 !: " @ name);			
			break;
		}
	}
}

// 친구 유저 상세 정보 업데이트
function userDetailInfoUpdateHandle (string param)
{
	// parse var
	local string name, memo;
	local int classID, level, status;
	local int pledgeID, allianceID;

	local int birthMonth, birthDay;
	local int logoutDiffSeconds;

	// Debug("---------" @ param);
	// parse
	ParseString(param, "Name", name);
	ParseString(param, "memo", memo);

	ParseInt(param, "ClassID" , classID);
	ParseInt(param, "Level"   , level);
	ParseInt(param, "Status"  , status);

	ParseInt(param, "pledgeID"        , pledgeID);
	ParseInt(param, "allianceID"      , allianceID);

	ParseInt(param, "birthMonth"      , birthMonth);
	ParseInt(param, "birthDay"        , birthDay);

	ParseInt(param, "logoutDiffSeconds", logoutDiffSeconds);
	
	// 보조창 해당 유저 상세 정보 갱신 
	m_PersonalConnectionsDrawerWnd.setDetailInfo(name, level, classID, pledgeID, allianceID, birthMonth, birthDay, logoutDiffSeconds, memo);
	
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 차단 목록 - 이벤트에 따른 처리 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function setBlockRecord (out LVDataRecord record, string param)
{
	// parse var
	local string name, memo;
	
	record.LVDataList.Length = 1;	

	// parse
	ParseString(param, "Name", name);
	ParseString(param, "memo", memo);

	// set 
	record.LVDataList[0].buseTextColor = True;
	record.LVDataList[0].szData = name;
	record.LVDataList[0].TextColor = util.Gold;
	record.nReserved1 = 0;	// for additional information		
}

function blockInfoListEmptyHandler()
{
	BlockList.DeleteAllItem();
}

function blockAddedHandler(string param)
{
	local LVDataRecord record;

	setBlockRecord(record, param);

	// 레코드 한줄씩 추가
	BlockList.InsertRecord(record);	

	// Debug("차단 리스트 추가 !: " @ name);	
}

function blockRemovedHandler(string param)
{
	local string name;
	local int i;

	// parse
	ParseString(param, "Name", name);

	i = util.ctrlListSearchByName(BlockList, name);

	if (i != -1)
	{
		BlockList.DeleteRecord(i);
	}
	
	// 차단 목록이 하나도 없다면.. 창 닫는다.
	if (BlockList.GetRecordCount() <= 0) subWindowClose();
	else 
	{  
		// 최하단의 항목을 삭제 한 경우 바로 위로 포커스를 가지도록 한다.
		if (BlockList.GetSelectedIndex() == BlockList.GetRecordCount()) 
		{			
			BlockList.SetSelectedIndex(BlockList.GetSelectedIndex() - 1, false);
		}

		OnClickListCtrlRecord("BlockList");
	}
	
}

function blockInfoUpdateHandler(string param)
{
	local LVDataRecord record;
	local LVDataRecord tempRecord;
	local string name;
	local int i;

	// BlockList.ClearTooltip();
	// BlockList.SetTooltipCustomType()

	// parse
	ParseString(param, "Name", name);

	setBlockRecord(record, param);

	for (i = 0; i < BlockList.GetRecordCount(); i++)
	{
		BlockList.GetRec(i, tempRecord);
		if (tempRecord.LVDataList[0].szData == name)
		{			
			BlockList.ModifyRecord(i, record);
			// Debug("차단 리스트 수정 !: " @ name);			
			break;
		}
	}
}

function blockDetailInfoUpdateHandler(string param)
{
	// parse var
	local string name, memo;

	// parse
	ParseString(param, "Name", name);
	ParseString(param, "memo", memo);

	// 보조창 해당 유저 상세 정보 갱신 
	m_PersonalConnectionsDrawerWnd.setDetailInfo(name, 0, 0, 0, 0, 0, 0, 0, memo);
	// Debug("blockDetailInfoUpdateHandler 보기 이벤트 " @ param);
}

/**
 *  다이얼로그 창을 실행 
 **/ 
function askDialog(int DialogID, optional string mParam)
{	
	local int classID, level;
	local LVDataRecord record;
	
	// 다른 다이얼로그 창이 열려 있으면 무조건 취소
	if ( IsShowWindow("DialogBox"))
	{
		class'PersonalConnectionAPI'.static.ConfirmMenteeAdd(mentorName, 0);
		return;
	}

	DialogSetID( DialogID );

	// 맨트가 다를까 했는데 결국 같았다. ;;
	if (DIALOG_PersonalConnectionFriendListRemove == DialogID)
	{
		DialogShow(DialogModalType_Modalless, DialogType_OKCancel, MakeFullSystemMsg( GetSystemMessage(3307), getUserNameByList()), string(Self) );
	}
	else if (DIALOG_PersonalConnectionBlockListRemove == DialogID)
	{
		DialogShow(DialogModalType_Modalless, DialogType_OKCancel, MakeFullSystemMsg( GetSystemMessage(3708), getUserNameByList()), string(Self) );
	}
	else if (DIALOG_PersonalConnectionMenteeListRemove == DialogID)
	{
		MentoringList.GetSelectedRec(record);
		DialogShow(DialogModalType_Modalless, DialogType_OKCancel, MakeFullSystemMsg( GetSystemMessage(3711), 
																				      getUserNameByList()), string(Self) );
 
		//																			  GetClassType(int(record.LVDataList[2].szData)), 
		//																			  record.LVDataList[1].szData),
	}
	else if (DIALOG_PersonalConnectionConfirmMentee == DialogID)
	{
		ParseString(mParam, "MentorName", mentorName);
		ParseInt(mParam, "ClassID", classID);
		ParseInt(mParam, "Level"  , level);
		
		DialogSetCancelD(DIALOG_PersonalConnectionConfirmMentee);
		//10초간 열림.
		DialogSetParamInt64( 10*1000 );	// 10 seconds
		DialogSetDefaultCancle();

		//	$c1 님을 멘토로 삼아, 보살핌을 받으시겠습니까? (클래스: $s2 / 레벨: $s3)
		DialogShow(DialogModalType_Modalless, DialogType_Progress, MakeFullSystemMsg( GetSystemMessage(3690), 
																					  mentorName,
																					  GetClassType(classID),
																					  string(level)), 
																					  string(Self) );
	}
}

/** 다이얼로그 ok 되었을때 처리 */
function HandleDialogOK ()
{
	local int dialogID, mCode;
	local string userName;
	
	if(DialogIsMine())
	{		
		dialogID = DialogGetID();
		
		// 전쟁을 선포 확인! 전쟁을 시작한다
		if( DIALOG_PersonalConnectionFriendListRemove == dialogID )
		{
			// Debug("친구목록 삭제할 userName: " @ userName);
			userName = getUserNameByList();
			if (userName != "") class'PersonalConnectionAPI'.static.RequestRemoveFriend(userName);
		}
		else if( DIALOG_PersonalConnectionBlockListRemove == dialogID ) 
		{
			userName = getUserNameByList();
			// Debug("차단목록 삭제할 userName: " @ userName);
			if (userName != "") class'PersonalConnectionAPI'.static.RequestRemoveBlock(userName);
		}	
		else if( DIALOG_PersonalConnectionMenteeListRemove == dialogID ) 
		{
			// 멘티 멘토 삭제 완료
			userName = getUserNameByList();
			if (userName != "" && mentorMenTeeRole != 0) 
			{
				// Debug("del -> mentorName" @ mentorName);

				if (mentorMenTeeRole == 1) mCode = 1;
				else mCode = 0;
					
				class'PersonalConnectionAPI'.static.RequestMentorCancel(mCode, userName); 
				
			}
		}
		else if (DIALOG_PersonalConnectionConfirmMentee == dialogID ) 
		{
			// 멘토 등록을 멘티가 OK 했을때..
			// Debug("call --> class'PersonalConnectionAPI'.static.ConfirmMenteeAdd: "  @ mentorName @ " , 1");

			class'PersonalConnectionAPI'.static.ConfirmMenteeAdd(mentorName, 1); 
		}
	}
}

/**
 *  HandleDialogCancel
 **/
function HandleDialogCancel()
{
	local int dialogID;

	if(DialogIsMine())
	{		
		dialogID = DialogGetID();

		if( DialogCheckCancelByID(DIALOG_PersonalConnectionConfirmMentee))
		{
			// 멘토 등록을 멘티가 거절 cancel 했을때..
			// Debug("call --> class'PersonalConnectionAPI'.static.ConfirmMenteeAdd: "  @ mentorName @ " , 0");
			class'PersonalConnectionAPI'.static.ConfirmMenteeAdd(mentorName, 0);
			
		}
	}
}

/**
 * 리스트 더블클릭 
 **/
function OnDBClickListCtrlRecord( string ListCtrlID)
{
	local int tabIndex;

	tabIndex = ConnectionsListSelectTab.GetTopIndex();
	// 친구 탭이라면.. 1:1 대화
	// 차단 탭이라면.. 상세 정보 보기
	// 멘토 탭
	if (tabIndex == 0) OnOneOnOneTalkBtnClick();      // 1:1 채팅
	else if (tabIndex == 1) onDetailInfoBtnClick();   // 상세 정보 보기
	else if (tabIndex == 2) OnOneOnOneTalkBtnClick(); // 1:1 채팅
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 버튼 클릭 - 각종 버튼 클릭 핸들러
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function OnClickButton( string Name )
{
	// Debug("Name" @ Name);
	switch( Name )
	{
		case "ListPlusBtn":
			 OnListPlusBtnClick();
			 break;

		case "ListMinusBtn":
			 OnListMinusBtnClick();
			 break;

		case "ListBlockBtn":
			 OnListBlockBtnClick();
			 break;

		case "InvitePartyBtn":
		 	 OnInvitePartyBtnClick();
			 break;

		case "SendPostBtn":
			 OnSendPostBtnClick();
			 break;

		case "InviteClanBtn":
			 OnInviteClanBtnClick();
			 break;

		case "WhisperBtn":
			 OnWhisperBtnClick();
			 break;

		case "DetailInfoBtn":
			 onDetailInfoBtnClick();
			 break;

		case "OneOnOneTalkBtn":
			 OnOneOnOneTalkBtnClick();
			 break;

		case "ConnectionsListSelectTab0" :
			 subWindowClose();
			 buttonsEnabled(true);
			 listTextUpdate();			 
			 checkClanButtonState();

			 // 멘토 가이드 텍스트 
			 GuideTitle.HideWindow();
			 Guide.HideWindow();
			 ListPlusBtn.ShowWindow();

			 setTextureVisible(0);
			 break;

		case "ConnectionsListSelectTab1" :
			 subWindowClose();
			 buttonsEnabled(false);
			 listTextUpdate();
			 DetailInfoBtn.EnableWindow();

			 // 멘토 가이드 텍스트 
			 GuideTitle.HideWindow();
			 Guide.HideWindow();

			 ListPlusBtn.ShowWindow();

			 setTextureVisible(1);

			 // checkClanButtonState();
			 break;
		case "ConnectionsListSelectTab2" :
			 subWindowClose();
			 buttonsEnabled(true);
			 listTextUpdate();
			 checkClanButtonState();

			 // 멘토 가이드 텍스트 
			 GuideTitle.ShowWindow();
			 Guide.ShowWindow();
			 
			 //멘토 인 경우
			 if (mentorMenTeeRole == 0 || mentorMenTeeRole == 1) ListPlusBtn.ShowWindow();
			 else ListPlusBtn.HideWindow();

			 // 버튼 비활성화
			 // 상세정보, 일대일 대화, 혈맹초대는 사용 못함
			 OneOnOneTalkBtn.EnableWindow();
			 DetailInfoBtn.DisableWindow();			 
			 //InviteClanBtn.DisableWindow();

			 setTextureVisible(2);
			 
			 break;
	}
}

/** 차단 , 친구 목록 텍스트 업데이트  */
function listTextUpdate ()
{
	local int tabIndex, mCount;

	tabIndex = ConnectionsListSelectTab.GetTopIndex();

	if (tabIndex == 0)
	{
		ListTitle.SetText(GetSystemString(2385));
		ListCount.SetText("(" $ FriendList.GetRecordCount() $ "/" $ FRIENDLIST_LIMIT $ ")");
	
	}
	else if (tabIndex == 1)
	{
		ListTitle.SetText(GetSystemString(2384));
		ListCount.SetText("(" $ BlockList.GetRecordCount() $ "/" $ BLOCKLIST_LIMIT $ ")");
	}
	else if (tabIndex == 2)
	{
		//  1 맨토인 경우 , 0 멘토, 멘티가 아닌 경우 
		//  2 맨티인 경우
		if (mentorMenTeeRole == 1 || mentorMenTeeRole == 0) 
		{  
			mCount = MENTEE_LIST_LIMIT;
			// 나의 멘티
			ListTitle.SetText(GetSystemString(2774));
			// Debug("GetSystemString(2774)" @ GetSystemString(2774) );
		}
		else if (mentorMenTeeRole == 2) 
		{
			mCount = MENTOR_LIST_LIMIT;
			// 나의 멘토 
			ListTitle.SetText(GetSystemString(2768));			
			// Debug("GetSystemString(2768)" @ GetSystemString(2768) );
		}
		else
		{

		}
		
		ListCount.SetText("(" $ MentoringList.GetRecordCount() $ "/" $ mCount $ ")");
	}
}

/**
 *  해당 리스트의 리스트 컨트롤의 상태에 따라서 버튼들의 상태를 제어한다.
 **/
function checkEnabledButton(ListCtrlHandle list)
{	
	if (list.GetRecordCount() > 0)
	{
		buttonsEnabled(true);
	}
	else
	{
		buttonsEnabled(false);
	}
}

/**
 *  [이름 입력] 보조 창 열기 
 **/
function OnListPlusBtnClick()
{	
	// 이름을 입력 할 수 있는 보조 서랍창을 연다.
	sideWindowOpen("AddWnd");
}

/**
 *  [선택된 유저삭제]
 *  친구, 차단 공용 
 **/
function OnListMinusBtnClick()
{
	local int tabIndex;
	local string tempStr;

	tempStr = getUserNameByList();

	if (tempStr != "")
	{
		tabIndex = ConnectionsListSelectTab.GetTopIndex();

		if (tabIndex == 0)
		{
			askDialog(DIALOG_PersonalConnectionFriendListRemove);
		}
		else if (tabIndex == 1)
		{
			askDialog(DIALOG_PersonalConnectionBlockListRemove);
		}
		else if (tabIndex == 2)
		{
			askDialog(DIALOG_PersonalConnectionMenteeListRemove);
		}
	}
}

/**
 *  [선택된 유저 차단]
 **/
function OnListBlockBtnClick()
{

}

/**
 * [선택된 유저에게 파티 초대 하기]
 **/
function OnInvitePartyBtnClick()
{
	local string tempStr;

	tempStr = getUserNameByList();

	if (tempStr != "")
	{
		
		if (  getInstanceUIData().getIsArenaServer() ) 
		//	// 그룹 초대
			class'ArenaAPI'.static.RequestMatchGroupAsk( tempStr ) ;
		else 
			// 파티 초대 
			RequestInviteParty(tempStr);
	}
}

/**
 * [선택된 유저에게 우편 발송]
 **/
function OnSendPostBtnClick()
{
	local PostBoxWnd postBoxWndScript;
	local PostWriteWnd postWriteWndScript;
	local string tempStr;

	tempStr = getUserNameByList();

	if (tempStr != "")
	{
		// 우편 창을 열고 해당 이름을 넣고 우편을 쓰도록 한다.
		postBoxWndScript = PostBoxWnd(GetScript("PostBoxWnd"));	
		postWriteWndScript = PostWriteWnd(GetScript("PostWriteWnd"));	

		postBoxWndScript.OnClickButton("PostSendBtn");
		postWriteWndScript.toWrite(tempStr);	
	}	
}

/**
 * [선택된 유저에게 혈맹 초대 하기]
 * 자신이 혈맹에 소속되어 있나 등 조건에 따라 사용 가능 여부 결정
 **/
function OnInviteClanBtnClick()
{
	local UserInfo	info;
	local string tempStr;

	local LVDataRecord record;

//	local InviteClanPopWnd InviteClanPopWndScript;

	local InviteClanPopWndClassic InviteClanPopWndClassicScript;

	local int tabIndex;	

	tabIndex = ConnectionsListSelectTab.GetTopIndex();
	
	tempStr = getUserNameByList();

	// Debug("tempStr " @ tempStr);

	if (tempStr != "")
	{	
		
		if (GetPlayerInfo(info))
		{
			// Debug("nClanID " @ info.nClanID);
			if (tabIndex == 0) FriendList.GetSelectedRec(record);
			else if (tabIndex == 2) MentoringList.GetSelectedRec(record);

			// FriendList.GetSelectedRec(record);			
			// "1"이면 온라인 "0" 이면 오프라인
			if (record.LVDataList[3].szData != "1")
			{
				// 현재 오프라인이라고 알리고 아무것도 안함
				AddSystemMessageString(GetSystemMessage(3473));
			}
			else 
			{
				// CLAN_ACADEMY
				//class'UIDATA_USER'.static.GetClanType(info.nClanID, clanType);
				// 클랜이 있다면.. 그리고 온라인 이라면..
				if (info.nClanID > 0)
				{	
					// Debug("clanType " @ clanType);				
					// 친구전용 기능인듯.. 그래서 멘토에서 사용이 안되더군요.
					// serverID = class'PersonalConnectionAPI'.static.GetFriendServerID(tempStr);
					
					// 온 오프는 예외 처리 하지 않았음
					// record.LVDataList[3].szData = "1";	
					// Debug("serverID " @ serverID);
					//RequestClanAskJoin(serverID, clanType);

					// 이름 으로 클린을 가입 하도록 하는 함수, 클라: 정동현 추가 해줌
					//-->
					//RequestClanAskJoinByName(tempStr, clanType);
					//RequestClanAskJoinByName(tempStr, CLAN_ACADEMY);
					
					if ( getInstanceUIData().getIsClassicServer() ) 
					{
						InviteClanPopWndClassicScript = InviteClanPopWndClassic( GetScript("InviteClanPopWndClassic" ) );
						InviteClanPopWndClassicScript.showByPersonalConnectionsWndUsingUserName(tempStr);          
					}
					else 
					{
						//InviteClanPopWndScript = InviteClanPopWnd( GetScript("InviteClanPopWnd" ) );
						//InviteClanPopWndScript.showByPersonalConnectionsWndUsingUserName(tempStr);
						RequestClanAskJoinByName(tempStr, 0);
					}


				}
			}
		}		
	}
	// 클랜 초대	
	// RequestClanAskJoin(record.LVDataList[0].szData);
}

/**
 *  혈맹 초대 
 **/ 
function AskJoin()
{
	local UserInfo user;
	//local Rect rect;
	//local InviteClanPopWnd script;

	if( GetTargetInfo( user ) )
	{
		//debug("AskJoin id " $ user.nID $ " name " $ user.Name );
		if( user.nID > 0 )
		{
			//script = InviteClanPopWnd( GetScript("InviteClanPopWnd" ) );
			//rect = class'UIAPI_WINDOW'.static.GetRect("MainWnd");
			//class'UIAPI_WINDOW'.static.MoveTo("InviteClanPopWnd", rect.nX + rect.nWidth, rect.nY + rect.nHeight);			
			if ( getInstanceUIData().getIsClassicServer() ) 			
				class'UIAPI_WINDOW'.static.Showwindow("InviteClanPopWndClassic");
			else 
				class'UIAPI_WINDOW'.static.Showwindow("InviteClanPopWnd");
		}
	}
}

/** 클랜 정보 */
function HandleClanMyAuth( String a_Param )
{
	// 클랜 가입권이 있나?
	local int nClanMaster;

	ParseInt( a_Param, "Join", nClanJoin );
	ParseInt( a_Param, "ClanMaster", nClanMaster );

	if (nClanMaster == 1 || nClanJoin == 1)
	{
		nClanJoin = 1;
	}
	else 
	{
		nClanJoin = 0;
	}
	// Debug("이벤트 날라옴: " @ a_Param);
	// 혈맹에서 초대 권한이 있다면...
	checkClanButtonState();

	/*
	ParseInt( a_Param, "NickName", m_bNickName );
	ParseInt( a_Param, "ClanCrest", m_bCrest );
	ParseInt( a_Param, "War", m_bWar );
	ParseInt( a_Param, "Grade", m_bGrade );
	ParseInt( a_Param, "ManageMaster", m_bManageMaster );
	ParseInt( a_Param, "OustMember", m_bOustMember );
	*/
}

/**
 * [귓속말 보내기]
 **/
function OnWhisperBtnClick()
{
	local ChatWnd chatWndScript;
	local string tempStr;

	tempStr = getUserNameByList();

	if (tempStr != "")
	{
		chatWndScript = ChatWnd(GetScript("ChatWnd"));
		chatWndScript.setChatEditBox("\"" $ tempStr $ " ");
	//	callGFxFunction("ChatMessage","sendWhisper", tempStr);
	}
}

/**
 *  [상세 유저 정보] 보조 창 열기 
 **/
function onDetailInfoBtnClick()
{
	if (getUserNameByList() != "")
	{
		if (m_PersonalConnectionsDrawerWnd.IsShowWindow("PersonalConnectionsDrawerWnd"))
		{		
			if (!m_PersonalConnectionsDrawerWnd.DetailInfoWnd.IsShowWindow())
			{
				sideWindowOpen("DetailInfoWnd");								
			}
			else 
			{ 
				subWindowClose();
			}
		}
		else 
		{
			sideWindowOpen("DetailInfoWnd");
		}
		RequestDetailInfo();
	}
}

/**
 *  [1:1 채팅] 클라이언트에서 제작된 UI 호출
 **/ 
function OnOneOnOneTalkBtnClick()
{
	local LVDataRecord record;
	
	local int tabIndex;	
	local string userName;

	userName = getUserNameByList();

	tabIndex = ConnectionsListSelectTab.GetTopIndex();
	
	if (userName != "") 
	{  
		// 친구, 멘토링 탭의 경우 
		if (tabIndex == 0) FriendList.GetSelectedRec(record);
		else if (tabIndex == 2) MentoringList.GetSelectedRec(record);
		
		// 온라인 상태 인 경우만 가능
		if (record.LVDataList[3].szData == "1")
		{
			// 1:1 대화 채팅 기능 호출 
			Debug("-> RequestFriendChat -:" @ userName);
			class'PersonalConnectionAPI'.static.RequestFriendChat(userName);
		}
		else
		{
			// 현재 접속해 있지 않다.
			AddSystemMessageString(MakeFullSystemMsg(GetSystemMessage(3), userName));
		}
	}
}

/**
 *  리스트 클릭 (상세정보 요청)
 **/
function OnClickListCtrlRecord( string ListCtrlID)
{

	if (m_PersonalConnectionsDrawerWnd.IsShowWindow("PersonalConnectionsDrawerWnd"))
	{		
		//멘티/멘토 리스트가 아니라면..
		if (ConnectionsListSelectTab.GetTopIndex() != 2)
		{
			if (!m_PersonalConnectionsDrawerWnd.DetailInfoWnd.IsShowWindow())
			{
				sideWindowOpen("DetailInfoWnd");			
			}
			RequestDetailInfo();
		}
	}

}

/** 친구, 차단 유저의 상세 정보를 요청한다. */
function RequestDetailInfo()
{	
	local string tempStr;
	local int tabIndex;

	tempStr = getUserNameByList();
	tabIndex = ConnectionsListSelectTab.GetTopIndex();

	if (tempStr != "")
	{
		// 친구 목록
		if (tabIndex == 0)
		{
			class'PersonalConnectionAPI'.static.RequestFriendDetailInfo(tempStr);
		}
		// 차단 목록
		else 
		{
			class'PersonalConnectionAPI'.static.RequestBlockDetailInfo(tempStr);
		}		
	}
}

/* 현재 선택되어진 리스트에서 이름 스트링을 리턴한다. */
function string getUserNameByList()
{	
	local LVDataRecord record;
	
	local int tabIndex;
	// local int selectedIndex;
	local string returnStr;
	
	returnStr = "";

	tabIndex = ConnectionsListSelectTab.GetTopIndex();
		
	// - 현재 탭의 상태- 
	// [목록]

	if (tabIndex == 0)
	{	
		if (FriendList.GetSelectedIndex() != -1)
		{
			FriendList.GetSelectedRec(record);
			returnStr = record.LVDataList[0].szData;
		}
	}
	// [차단]
	else if (tabIndex == 1)
	{
		if (BlockList.GetSelectedIndex() != -1)
		{
			BlockList.GetSelectedRec(record);
			returnStr = record.LVDataList[0].szData;
		}
	}	
	// [멘티, 멘토]
	else if (tabIndex == 2)
	{
		if (MentoringList.GetSelectedIndex() != -1)
		{
			MentoringList.GetSelectedRec(record);
			returnStr = record.LVDataList[0].szData;
		}
	}

	if (returnStr == "")
	{
		// 시스템 메세지 출력
		// 목록을 선택해!
		AddSystemMessage(3314);	
	}

	return returnStr;	
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 유틸 함수 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function OnCallUCFunction( string funcName, string param )
{
	// Debug("p funcName:" @ funcName);
	// Debug("param:" @ param);

	if(funcName == "checkInviteClanByGfxCallFunction")
	{
		if (param == "1")
		{
			nClanJoin = 1;
		}
		else
		{
			nClanJoin = 0;
		}

		checkClanButtonState();
	}
}


/**
 *  혈맹 소속인지 체크해서 활성 비활성 여부 지정
 **/
function checkClanButtonState() 
{
	local UserInfo userinfo;
	
	if( GetPlayerInfo( userinfo ) )
	{
		//혈맹 미가입자
		if(userinfo.nClanID == 0)
		{
			InviteClanBtn.DisableWindow();
		}
		//혈맹 가입자
		else
		{			
			// 첫번째 친구,멘토멘티 팁에서만 보이도록 하고
			switch ( ConnectionsListSelectTab.GetTopIndex() )
			{
				case 0 :
				case 2 : 
						// 혈맹에 가입된 혈원중 혈맹 초대가 가능한 애들만 버튼 활성화
						if( nClanJoin == 0) InviteClanBtn.DisableWindow();
						else InviteClanBtn.EnableWindow();
						break;
					// Debug("nClanJoin " @ nClanJoin);
			}
			/*
			// 현재 멘토 멘티 탭에서는 혈맹초대 기능을 지원하지 않아서 주석처리.
			// 멘토/멘티 탭 
			else if (ConnectionsListSelectTab.GetTopIndex() == 2)
			{
				// 혈맹에 가입된 혈원중 혈맹 초대가 가능한 애들만 버튼 활성화
				if( nClanJoin == 0) InviteClanBtn.DisableWindow();
				else InviteClanBtn.EnableWindow();
			}
			*/
		}
	}
}

function getmyClanInfo() 
{
	
}

/**
 *  현재 버튼 활성화 비활성화 
 **/
function buttonsEnabled (bool bFlag)
{

	if (bFlag)
	{
		InvitePartyBtn.EnableWindow();
		SendPostBtn.EnableWindow();
		InviteClanBtn.EnableWindow();

		WhisperBtn.EnableWindow();
		DetailInfoBtn.EnableWindow();
		OneOnOneTalkBtn.EnableWindow();
	}
	else
	{
		InvitePartyBtn.DisableWindow();
		SendPostBtn.DisableWindow();
		InviteClanBtn.DisableWindow();
		WhisperBtn.DisableWindow();
		DetailInfoBtn.DisableWindow();
		OneOnOneTalkBtn.DisableWindow();
	}
}

/**
 * 지정한 배열을 모두 삭제 한다.
 * 
 */
function removeAllArrayItems(out array<relationMemberInfo> pArray)
{
	if (pArray.Length > 0)
	{
		pArray.Remove(0, pArray.Length);
	}
}

/**
 * 지정한 배열을 모두 삭제 한다.
 * 
 */
function removeArrayItem(out array<relationMemberInfo> pArray, int deleteItemIndex)
{
	if (pArray.Length > deleteItemIndex)
	{
		pArray.Remove(deleteItemIndex, 1);
	}
}

/**
 *  보조창을 연다.(열려 있다면 닫히게 한다)
 *  
 *  AddWnd        
 *  NameEnterWnd  
 *  ClanListWnd
 *  InzoneTreeWnd
 *  DetailInfoWnd
 *  MenteeSearchWnd (추가됨)
 **/ 
function sideWindowOpen (string sideWindowName)
{
	local WindowHandle sideWindowHandler;

	sideWindowHandler = GetWindowHandle("PersonalConnectionsDrawerWnd." $ sideWindowName);

	
	// MenteeSearchWnd
	if (m_PersonalConnectionsDrawerWnd.IsShowWindow("PersonalConnectionsDrawerWnd"))
	{	
		if (sideWindowHandler.IsShowWindow())
		{
			m_PersonalConnectionsDrawerWnd.HideWindow("PersonalConnectionsDrawerWnd");
			// Debug("PersonalConnectionsDrawerWnd hide!");
		}
		else
		{
			m_PersonalConnectionsDrawerWnd.showSelectWindow(sideWindowName);
			// Debug("PersonalConnectionsDrawerWnd 열어라!!");
		}
	}
	else
	{
		m_PersonalConnectionsDrawerWnd.ShowWindow("PersonalConnectionsDrawerWnd");
		m_PersonalConnectionsDrawerWnd.showSelectWindow(sideWindowName);
		// Debug("PersonalConnectionsDrawerWnd 다 열어라!!");
	}
}

/**
 *  보조 창 닫기
 **/
function subWindowClose()
{		
	if (m_PersonalConnectionsDrawerWnd.IsShowWindow("PersonalConnectionsDrawerWnd"))
	{   
		m_PersonalConnectionsDrawerWnd.HideWindow("PersonalConnectionsDrawerWnd");
	}
}


/**
 *  툴팁 , 메모 , 사용안함 
 */
function CustomTooltip getMemoToolTip (int job, string memo)
{
	local CustomTooltip m_Tooltip;

	m_Tooltip.DrawList.Length = 2;
	m_Tooltip.MinimumWidth = 160;

	m_Tooltip.DrawList[0].eType = DIT_TEXT;

	m_Tooltip.DrawList[0].t_strText = GetSystemString(391) $ " : " $ GetClassType(job);

	m_Tooltip.DrawList[1].eType = DIT_TEXT;
	m_Tooltip.DrawList[1].t_color.R = 175;
	m_Tooltip.DrawList[1].t_color.G = 152;
	m_Tooltip.DrawList[1].t_color.B = 120;
	m_Tooltip.DrawList[1].t_color.A = 255;

	m_Tooltip.DrawList[1].t_strText = memo;

	return m_Tooltip;

}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( "PersonalConnectionsWnd" ).HideWindow();
}
defaultproperties
{
}
