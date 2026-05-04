/******************************************************************************
//                                             확장된 파티창 UI 관련 스크립트                                                                    //
******************************************************************************/
class PartyWndArena extends UICommonAPI;	

//상수설정.  
const NSTATUSICON_MAXCOL = 12;	    // status icon의 최대 가로.
const NPARTYSTATUS_HEIGHT = 47; //46;	    // status 상태창의 세로길이.
const NPARTYPETSTATUS_HEIGHT = 18;	// status 상태창의 세로길이.

const SMALL_BUF_ICON_SIZE = 6;	// 펫 버프 아이콘이 겹치므로 항상 작게 해준다. 

const MAX_ArrayNum = 10; // MAX_ArrayNum = MAX_PartyMemberCount + 1 -> 임시 저장을 추가한 수
const MAX_BUFF_ICONTYPE = 4;//보여주고자 하는 버프 아이콘 타입 종류

struct VnameData
{
	var int ID;
	var int UseVName;
	var int DominionIDForVName;
	var string VName;
	var string SummonVName;	
};

var bool	m_bCompact;	//컴팩트창 오픈여부.
var bool	m_bBuff;		//버프 표시상태 플래그.

var int		m_arrID[MAX_ArrayNum];	// 인덱스에 해당하는 파티원의 서버 ID.
var int		m_arrPetID[MAX_ArrayNum];	// 인덱스에 해당하는 파티원의 펫의서버 ID.
var int		m_arrSummonID[MAX_ArrayNum];	// 인덱스에 해당하는 파티원의 수환 주인 ID -> CT3 추가
var int		m_arrPetIDOpen[MAX_ArrayNum];	// 인덱스에 해당하는 파티원의 펫의 창이 열려있는지 확인. 1이면 오픈, 2이면 닫힘. -1이면 없음
var int		m_CurCount;	
var int 	m_CurBf;
var int		m_TargetID;
var int		m_LastChangeColor;

var VnameData m_Vname[MAX_ArrayNum];
var bool m_AmIRoomMaster; //자신이 파티방의 방장인지를 가지고 있다. PartyMatchRoomWnd에 의해서 파티방이 열리고 닫힐때 갱신된다
//Handle 을 등록.
var WindowHandle		m_wndTop;
var WindowHandle		m_PartyStatus[MAX_ArrayNum];
var WindowHandle		m_PartyOption;
var NameCtrlHandle		m_PlayerName[MAX_ArrayNum];
var TextureHandle		m_ClassIcon[MAX_ArrayNum];
var TextureHandle		m_LeaderIcon[MAX_ArrayNum];
var TextureHandle		m_VPIcon[MAX_ArrayNum];

var TextureHandle		m_IsDead[MAX_ArrayNum];


var StatusIconHandle	m_StatusIconBuff[MAX_ArrayNum];
var StatusIconHandle	m_StatusIconDeBuff[MAX_ArrayNum];
var StatusIconHandle	m_StatusIconSongDance[MAX_ArrayNum];
var StatusIconHandle	m_StatusIconTriggerSkill[MAX_ArrayNum];
var BarHandle			m_BarCP[MAX_ArrayNum];
var BarHandle			m_BarHP[MAX_ArrayNum];
var BarHandle			m_BarMP[MAX_ArrayNum];
var ButtonHandle		btnBuff;

var ButtonHandle		m_petButton[MAX_ArrayNum];
var ButtonHandle		m_petButtonTrash[MAX_ArrayNum];

var WindowHandle		m_PetPartyStatus[MAX_ArrayNum];
//var NameCtrlHandle		m_PetName[MAX_ArrayNum];
 
var StatusIconHandle	m_PetStatusIconBuff[MAX_ArrayNum];
var StatusIconHandle	m_PetStatusIconDeBuff[MAX_ArrayNum];
var StatusIconHandle	m_PetStatusIconSongDance[MAX_ArrayNum];
var StatusIconHandle	m_PetStatusIconTriggerSkill[MAX_ArrayNum];


var BarHandle			m_PetBarHP[MAX_ArrayNum];
var BarHandle			m_PetBarMP[MAX_ArrayNum];

var TextureHandle		m_PetClassIcon[MAX_ArrayNum];

// ct3 다중 소환 - 추가 
var TextureHandle m_ClassIconSummon[MAX_ArrayNum];
var TextureHandle m_ClassIconSummonNum[MAX_ArrayNum];
// var TextureHandle m_ClassIconPet[MAX_ArrayNum];


/**자동파티시스템 추가*/
//자동파티아이콘텍스쳐
//var TextureHandle m_AutoPartyMatchingIcon[MAX_ArrayNum];
//자동파티아이콘버튼
//var ButtonHandle m_AutoPartyMatchingBtn[MAX_ArrayNum];

//자동파티 선택된 index
//var int autoPartyIndex[MAX_ArrayNum];

var int partymasteridx;

var L2Util util;

//파티장 아이디
var int PartyLeaderID;

// 현재 이상상태 보기 (버프,송댄스 등) 버튼 상태를 저장합니다.
// 45842 TTP 
var string currentBuffButtonState;

//클래식 서버에서 vp 아이콘이 없어서 생기는 offset
const ONCLASSICFORM_OFFSET_X = 12;
const ONAREAFORM_OFFSET_X = 3;

var int iconsOffsetX ;

// 매칭 그룹 맴버
var Array<int> m_arrMatchGroupMember;	

// 그룹 인덱싱 용
var int currentIndex, matchGroupCount, partyCount ;


function OnRegisterEvent()
{
	// 이벤트 (서버 혹은 클라이언트에서 오는) 핸들 등록.
	RegisterEvent( EV_ShowBuffIcon );
	
	RegisterEvent( EV_PartyAddParty);
	RegisterEvent( EV_PartyUpdateParty );
	RegisterEvent( EV_PartyDeleteParty );
	RegisterEvent( EV_PartyDeleteAllParty );
	RegisterEvent( EV_PartySpelledList );
	RegisterEvent( EV_PartyRenameMember );
	
	// ct3 에서 소환수와 팻 분리
	
	RegisterEvent( EV_PartySummonAdd );
	RegisterEvent( EV_PartySummonUpdate );
	RegisterEvent( EV_PartySummonDelete );
	
	RegisterEvent( EV_PartyPetAdd );	
	RegisterEvent( EV_PartyPetUpdate );
	RegisterEvent( EV_PartyPetDelete );
	
	/*
	 *20130219 현재 적혀있는 기획서에 따라. 소환수 버프는 보여주지 않는다.
	 */
	RegisterEvent( EV_PetStatusSpelledList );		// 펫 버프가 날라오는 이벤트
	//RegisterEvent( EV_SummonedStatusSpelledList );	// 소환수  버프가 날라오는 이벤트
	
	RegisterEvent( EV_Restart );
	RegisterEvent( EV_TargetUpdate );	// 타겟 업데이트 이벤트	

	// 파장의 대타 신청 성공유무
	RegisterEvent( EV_RegistPartySubstitute );
	// 파장의 대타 취소 신청 성공유무
	RegisterEvent( EV_DeletePartySubstitute );


	RegisterEvent( EV_PartySpelledListDelete ); //1182
	RegisterEvent( EV_PartySpelledListInsert ); //1183
	RegisterEvent( EV_PetStatusSpelledListDelete ); //1052	
	RegisterEvent( EV_PetStatusSpelledListInsert ); //1053

	RegisterEvent( EV_NeedResetUIData);

	RegisterEvent( EV_StateChanged );
	
	//RegisterEvent( EV_TargetHideWindow );
}



function checkClassicForm() 
{
	local int idx;		

	if ( getInstanceUIData().getisClassicServer())
	{
		iconsOffsetX = ONCLASSICFORM_OFFSET_X;		
	}
	else if ( getInstanceUIData().getIsArenaServer() )
	{
		iconsOffsetX = ONAREAFORM_OFFSET_X;
	}
	else 
	{		
		iconsOffsetX = 0;
	}

	for (idx=0; idx<MAX_ArrayNum; idx++)
	{	
		
		if ( getInstanceUIData().getisClassicServer() || getInstanceUIData().getIsArenaServer()) 
		{
			m_VPIcon[idx].hideWindow();
			m_ClassIconSummonNum[idx].HideWindow();
		}
		else 
		{
			m_VPIcon[idx].showWindow();
			m_ClassIconSummonNum[idx].ShowWindow();
		}

		m_LeaderIcon[idx].SetAnchor( "PartyWndArena.PartyStatusWnd"$idx , "TopLeft", "TopLeft", 30 - iconsOffsetX, 8 );			
	}
}

// 특화 서버일 경우 서머너 개수가 보이지 않도록
function setHideClassIconSummonNum( int idx ) 
{
	if ( getInstanceUIData().getisClassicServer() )
		m_ClassIconSummonNum[idx].HideWindow();
	else 	
		m_ClassIconSummonNum[idx].ShowWindow();
}

// 윈도우 생성시 불리는 함수.
function OnLoad()
{
	local int idx;	// 루프를 돌게될 int.

	util = L2Util(GetScript("L2Util"));

	InitHandleCOD();

	// 전역변수 초기화.
	partymasteridx = -1;
	m_bCompact = false;
	m_bBuff = false;
	m_CurBf = 0;
	m_TargetID = -1;
	m_LastChangeColor = -1;
	m_AmIRoomMaster = false;
	
	//Reset Anchor	// 버프와 디버프는 PartyWndCompact의 anchor point를 참조한다.
	for (idx=0; idx<MAX_ArrayNum; idx++)
	{
		m_StatusIconBuff[idx].SetAnchor("PartyWndArena.PartyStatusWnd" $ idx, "TopRight", "TopLeft", 0, 5);
		m_StatusIconDeBuff[idx].SetAnchor("PartyWndArena.PartyStatusWnd" $ idx, "TopRight", "TopLeft", 0, 5);
		m_StatusIconSongDance[idx].SetAnchor("PartyWndArena.PartyStatusWnd" $ idx, "TopRight", "TopLeft", 0, 5);
		m_StatusIconTriggerSkill[idx].SetAnchor("PartyWndArena.PartyStatusWnd" $ idx, "TopRight", "TopLeft", 0, 5);

		
		m_PetStatusIconBuff[idx].SetAnchor("PartyWndArena.PartyStatusSummonWnd" $ idx, "TopRight", "TopLeft", 1, 1);
		m_PetStatusIconDeBuff[idx].SetAnchor("PartyWndArena.PartyStatusSummonWnd" $ idx, "TopRight", "TopLeft", 1, 1);
		m_PetStatusIconSongDance[idx].SetAnchor("PartyWndArena.PartyStatusSummonWnd" $ idx, "TopRight", "TopLeft", 1, 1);
		m_PetStatusIconTriggerSkill[idx].SetAnchor("PartyWndArena.PartyStatusSummonWnd" $ idx, "TopRight", "TopLeft", 1, 1);

	}
	m_PartyOption.HideWindow();
	
	//Init VirtualDrag
	for (idx=0; idx<MAX_ArrayNum; idx++)
	{
		//m_PartyStatus[idx].SetVirtualDrag( true );
		m_PartyStatus[idx].SetDragOverTexture( "L2UI_CT1.ListCtrl.ListCtrl_DF_HighLight" );
	}
	
	ResetVName();
	
	m_arrMatchGroupMember.Length = 0;
	//Debug("다시 로드..");
}
/*
function InitHandle()
{
	local int idx;	// 루프를 돌게될 int.

	//Init Handle
	m_wndTop = GetHandle( "PartyWndArena" );
	m_PartyOption = GetHandle("PartyWndOption");	// 옵션창의 핸들 초기화.
	for (idx=0; idx<MAX_ArrayNum; idx++)	// 최대파티원 수 만큼 각 데이터를 초기화해줌.
	{
		m_PartyStatus[idx] = GetHandle( "PartyWndArena.PartyStatusWnd" $ idx );
		m_PlayerName[idx] = NameCtrlHandle( GetHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".PlayerName" ) ); 
		m_ClassIcon[idx] = TextureHandle( GetHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".ClassIcon" ) );
		m_LeaderIcon[idx] = TextureHandle( GetHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".LeaderIcon" ) );
		
		m_StatusIconBuff[idx] = StatusIconHandle( GetHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".StatusIconBuff" ) );
		m_StatusIconDeBuff[idx] = StatusIconHandle( GetHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".StatusIconDeBuff" ) );
		m_StatusIconSongDance[idx] = StatusIconHandle( GetHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".StatusIconSongDance" ) );
		m_StatusIconTriggerSkill[idx] = StatusIconHandle( GetHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".StatusIconTriggerSkill" ) );

		m_BarCP[idx] = BarHandle( GetHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".barCP" ) );
		m_BarHP[idx] = BarHandle( GetHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".barHP" ) );
		m_BarMP[idx] = BarHandle( GetHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".barMP" ) );
		//if(idx != 0) // 첫번째 창의 버튼을 상속받은 모든 창에 버튼이 생겼지만 어쩔수 없다. 
		//{
		//	m_petButtonTrash[idx] = ButtonHandle( GetHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".btnSummon0") );	
		//	m_petButtonTrash[idx].HideWindow();
		//}
		m_petButton[idx] = ButtonHandle( GetHandle( "PartyWndArena.btnSummon" $ idx) );	// 실제로 사용될 버튼		
		m_petButton[idx].HideWindow();
		
		m_PetPartyStatus[idx] = GetHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx );
		//m_PetName[idx] = NameCtrlHandle( GetHandle( 
"PartyWndArena.PartyStatusSummonWnd" $ idx $ ".SummonName" ) ); 
		m_PetClassIcon[idx] = TextureHandle( GetHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".ClassIcon" ) );
		
		m_PetStatusIconBuff[idx] = StatusIconHandle( GetHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".StatusIconBuff" ) );
		m_PetStatusIconDeBuff[idx] = StatusIconHandle( GetHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".StatusIconDebuff" ) );
		m_PetStatusIconSongDance[idx] = StatusIconHandle( GetHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".StatusIconSongDance" ) );
		m_PetStatusIconTriggerSkill[idx] = StatusIconHandle( GetHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".StatusIconTriggerSkill" ) );

		m_PetBarHP[idx] = BarHandle( GetHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".barHP" ) );
		m_PetBarMP[idx] = BarHandle( GetHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".barMP" ) );		
				
		m_arrPetIDOpen[idx] = -1;
		m_arrID[idx] = 0;
		
		if(idx == 0) //첫번째 창은 레이아웃이 다르다. 
		{
			m_petButton[idx].SetAnchor("PartyWndArena.PartyStatusWnd" $ idx, "TopLeft", "TopRight", 0, 32);
		}
		else
			m_petButton[idx].SetAnchor("PartyWndArena.PartyStatusWnd" $ idx, "TopLeft", "TopRight", 0, 2);
		
	}
	btnBuff = ButtonHandle( GetHandle( "PartyWndArena.btnBuff" ) );
}
*/
function InitHandleCOD()
{
	local int idx;	// 루프를 돌게될 int.

	//Init Handle
	m_wndTop = GetWindowHandle( "PartyWndArena" );
	m_PartyOption = GetWindowHandle("PartyWndOption");	// 옵션창의 핸들 초기화.

	for (idx=0; idx<MAX_ArrayNum; idx++)	// 최대파티원 수 만큼 각 데이터를 초기화해줌. ->  임시 데이터 용 한명을 더해 줍니다.
	{
		m_PartyStatus[idx] = GetWindowHandle  ( "PartyWndArena.PartyStatusWnd" $ idx );
		m_PlayerName[idx]  = GetNameCtrlHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".PlayerName" ); 
		m_ClassIcon[idx]   = GetTextureHandle ( "PartyWndArena.PartyStatusWnd" $ idx $ ".ClassIcon" );
		m_LeaderIcon[idx]  = GetTextureHandle ( "PartyWndArena.PartyStatusWnd" $ idx $ ".LeaderIcon" );
		m_VPIcon[idx]      = GetTextureHandle ( "PartyWndArena.PartyStatusWnd" $ idx $ ".PartyVPIcon" );

		m_IsDead[idx]      = GetTextureHandle ( "PartyWndArena.PartyStatusWnd" $ idx $ ".IsDeadTexture" );
		
		m_StatusIconBuff[idx]          = GetStatusIconHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".StatusIconBuff" );
		m_StatusIconDeBuff[idx]        = GetStatusIconHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".StatusIconDeBuff" );
		m_StatusIconSongDance[idx]     = GetStatusIconHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".StatusIconSongDance" );
		m_StatusIconTriggerSkill[idx]  = GetStatusIconHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".StatusIconTriggerSkill" );

		m_BarCP[idx] = GetBarHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".barCP" );
		m_BarHP[idx] = GetBarHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".barHP" );
		m_BarMP[idx] = GetBarHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".barMP" );

		m_petButton[idx] = GetButtonHandle( "PartyWndArena.btnSummon" $ idx);	// 실제로 사용될 버튼		
		m_petButton[idx].HideWindow();
		
		m_PetPartyStatus[idx] = GetWindowHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx );

		
		m_PetStatusIconBuff[idx] = GetStatusIconHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".StatusIconBuff" );
		m_PetStatusIconDeBuff[idx] = GetStatusIconHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".StatusIconDebuff" );
		m_PetStatusIconSongDance[idx] = GetStatusIconHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".StatusIconSongDance" );
		m_PetStatusIconTriggerSkill[idx] = GetStatusIconHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".StatusIconTriggerSkill" );

		m_PetBarHP[idx] = GetBarHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".barHP" );
		m_PetBarMP[idx] = GetBarHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".barMP" );		
		

		// m_PetClassIcon[idx] = GetTextureHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".ClassIcon" );

		// ct 에 변경된 팻 클래스 아이콘
		m_PetClassIcon[idx] = GetTextureHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".ClassIconPet" );


		// ct3 에 추가된 팻, 소환수 텍스쳐 (소환수 아이콘, 소환수 수, 팻 아이콘)
		m_ClassIconSummon[idx]    =  GetTextureHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".ClassIconSummon" );
		
		m_ClassIconSummonNum[idx] =  GetTextureHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".ClassIconSummonNum" );
		
		m_arrPetIDOpen[idx] = -1;
		m_arrSummonID[idx] = -1;
		m_arrID[idx] = 0;

		//m_AutoPartyMatchingIcon[idx]    = GetTextureHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".AutoPartyMatchingIcon" );
		//m_AutoPartyMatchingBtn[idx]     = GetButtonHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".AutoPartyMatchingBtn" );
		
		if(idx == 0) //첫번째 창은 레이아웃이 다르다. 
		{
			m_petButton[idx].SetAnchor("PartyWndArena.PartyStatusWnd" $ idx, "TopLeft", "TopRight", 0, 32);
		}
		else
			m_petButton[idx].SetAnchor("PartyWndArena.PartyStatusWnd" $ idx, "TopLeft", "TopRight", 0, 2);
		
	}
	btnBuff = GetButtonHandle( "PartyWndArena.btnBuff" );
}

/** 
 * 소환수 타입 받기   
 **/
function string getSummonSortString(int typeN)
{
	local string returnV;
	
	returnV = "";

	switch(typeN)
	{
		// 공격형 소환수
		case 0 : returnV = GetSystemString(2311); break;
		// 방어형 소환수
		case 1 : returnV = GetSystemString(2312); break;
		// 보조형 소환수
		case 2 : returnV = GetSystemString(2313); break;
		// 공성형 소환수
		case 3 : returnV = GetSystemString(2314); break;
		// 소모형 소환수
		case 4 : returnV = GetSystemString(2315); break;
	}

	return returnV;
}
function OnShow()
{
	local int i;
	local int tmpInt;

	GetINIInt ( "PartyWndArena", "a", m_CurBf, "WindowsInfo.ini");
	SetBuffButtonTooltip();
	UpdateBuff();
	GetIniInt( "PartyWndArena", "p", tmpInt, "WindowsInfo.ini");	

	for(i=0; i <MAX_PartyMemberCount ; i++)
	{
		
		if( bool ( tmpInt ) ) 	
		{
			if(m_arrPetIDOpen[i] > 0)	m_arrPetIDOpen[i] = 2;		//펫이 있을때 모두 닫아준다. 
		}
		else 
		{
			if(m_arrPetIDOpen[i] > 0)	m_arrPetIDOpen[i] = 1;		//펫이 있을때 모두 열어준다. 			
		}	
		// 양쪽 스크립트에게 모두 전달.		
	}
	//컷 신의 경우 실제로 show가 되지 않으나, onShow를 반복 실행 하게 됨
	//showWindow를 뺀 리사이즈 를 만듬
	

	//Debug ( "onShow partyWnd");
	resizeOnly() ;
	//ResizeWnd();
	//SetBuffButtonTooltip();
}

function OnHide()
{
	ResetVName();
}

function OnEnterState( name a_PreStateName )
{
	if (isAreaState() == false) return;
	
	m_bCompact = false;
	m_bBuff = false;
	// m_CurBf = 0;
	ResizeWnd();

	SetBuffButtonTooltip();
	UpdateBuff();
	
}

// 이벤트 핸들 처리.
function OnEvent(int Event_ID, string param)
{
	//Debug( "Event_ID>>>" $ string(Event_ID) $ "&&" $ param );
	//Debug("isAreaState()" @ isAreaState());
	//Debug ( "OnEvent" @  Event_ID @ param );
	if (isAreaState() == false) return;

	if (Event_ID == EV_PartyAddParty)	//파티원을 추가하는 이벤트.
	{
		HandlePartyAddParty(param);
	}
	else if (Event_ID == EV_PartyUpdateParty)	//파티 업데이트. 각종 HP 및 상태를 처리하기 위함.
	{
		HandlePartyUpdateParty(param);
	}
	else if (Event_ID == EV_PartyDeleteParty)	//파티원 삭제.
	{
		HandlePartyDeleteParty(param);
	}
	else if (Event_ID == EV_PartyDeleteAllParty)	//모든 파티원 삭제. 파티를 떠나거나 뽀갤때.
	{
		HandlePartyDeleteAllParty();
	}
	//20130221 최종 기획 내용은, 펫 이상상태는 표시 하지 않는 것으로 파악 됨. 우선 summon 만 막아 놓음
	else if (Event_ID == EV_PartySpelledList || Event_ID == EV_PetStatusSpelledList )//|| Event_ID == EV_SummonedStatusSpelledList)	// 버프 혹은 디버프 처리.
	{
		HandlePartySpelledList(param);
		//Debug( EV_PartySpelledList @ "EV_PartySpelledList");
	}
	else if (Event_ID == EV_ShowBuffIcon)		// 버프, 디버프, 버프/디버프 보이기 모드를 전환.
	{
		HandleShowBuffIcon(param);
	}
	else if (Event_ID == EV_PartySummonAdd)	//파티원이 소환수를 소환했을 경우
	{
		HandlePartySummonAdd(param);
	}
	else if (Event_ID == EV_PartyPetAdd)	//파티원이 팻을 소환했을 경우
	{
		HandlePartyPetAdd(param);
	}
	else if (Event_ID == EV_PartySummonUpdate)	//소환수 업데이트 HP나 뭐 그런거..
	{
		// Debug("EV_PartySummonUpdate:" @ param);
		HandlePartySummonUpdate(param);
		
	}
	else if (Event_ID == EV_PartyPetUpdate)	// 팻 업데이트 HP나 뭐 그런거..
	{		
		HandlePartyPetUpdate(param);
	}
	else if (Event_ID == EV_PartySummonDelete)	// 소환 해제
	{
		// Debug("소환수 해제"@ param);
		HandlePartySummonDelete(param);
	}
	else if (Event_ID == EV_PartyPetDelete)	    // 팻 소환 해제
	{
		// Debug("팻 소환 해제" @ param);
		HandlePartyPetDelete(param);
	}

	else if (Event_ID == EV_Restart)
	{
		// Debug("우윅");
		HandleRestart();
	}
	
	else if (Event_ID == EV_TargetUpdate)
	{
		HandleCheckTarget();
	}
	else if (Event_ID == EV_PartyRenameMember)
	{
		HandlePartyRenameMember(param);
	}

	else if( Event_ID == EV_RegistPartySubstitute )
	{
		HandleRegistPartySubstitute( param );
	}
	else if( Event_ID ==  EV_DeletePartySubstitute )
	{
		HandleDeletePartySubstitute( param );
	}

	else if ( Event_ID == EV_PartySpelledListDelete	||  Event_ID == EV_PetStatusSpelledListDelete)
	{	
		HandlePartySpelledListDelete(param);		
	}
	else if  ( Event_ID == EV_PartySpelledListInsert ||  Event_ID == EV_PetStatusSpelledListInsert )
	{
		HandlePartySpelledListInsert(param);				
	}
	else if ( Event_ID == EV_NeedResetUIData ) 
	{
		checkClassicForm();
	}	
	else if ( Event_ID ==  EV_StateChanged )
	{
		if ( param == "ARENABATTLESTATE" && m_arrMatchGroupMember.Length > 0 ) 
		{
//			Debug ( "아레나 배틀 스테이트 보여야 한다 !!!" @ m_arrMatchGroupMember.Length) ;
			m_wndTop.ShowWindow();		
		}
	}
}

function onCallUCFunction ( string functionName, string param ) 
{
	
	switch ( functionName ) 
	{
		case "addGroupMember":			
			m_arrMatchGroupMember.Length = m_arrMatchGroupMember.Length + 1 ;
			m_arrMatchGroupMember[m_arrMatchGroupMember.Length-1] = int ( param );
	//		Debug ( "addGroupMember" @ m_arrMatchGroupMember.Length @ m_arrMatchGroupMember[m_arrMatchGroupMember.Length-1]) ;
		break;
		case "resetGroupMember" :
	//		Debug ( "resetGroupMember" @ m_arrMatchGroupMember.Length ) ;
			m_arrMatchGroupMember.Length = 0 ;
		break;
	}
}

function bool isMatchGroupMember ( int ID ) 
{
	local int i;
	for (i = 0 ; i < m_arrMatchGroupMember.Length ; i ++ )		
	{
		//Debug ( "isMatchGroupMember" @  m_arrMatchGroupMember[i] @ ID) ;
		if ( m_arrMatchGroupMember[i] == ID ) return true;
	}
	return false;
}

function HandlePartyRenameMember(string Param)
{
	local int idx;
	local int ID;
	local int UseVName;
	local int DominionIDForVName;
	local string VName;
	local string SummonVName;
	
	ParseInt(Param, "ID", ID);
	ParseInt(Param, "UseVName",UseVName);
	ParseInt(Param, "DominionIDForVName", DominionIDForVName);
	ParseString(Param, "VName", VName);
	ParseString(Param, "SummonVName", SummonVName);
	
	idx = GetVNameIndexByID( ID );
	if( idx > -1 )
	{
		m_Vname[idx].ID = ID;
		m_Vname[idx].UseVName = UseVName;
		m_Vname[idx].DominionIDForVName = DominionIDForVName;
		m_Vname[idx].VName = VName;
		m_Vname[idx].SummonVName = SummonVName;
		ExecuteEvent( EV_TargetUpdate);
	}	
}

// 타겟한 것이 파티원이면 색깔에 조금 변화를 준다.
function HandleCheckTarget()
{
	local int idx;
	
	idx = -1;
	
	m_TargetID = class'UIDATA_TARGET'.static.GetTargetID();
	if(m_TargetID > 0)	{	idx = FindPartyID(m_TargetID);	}
	
	// 이전에 색을 바꿔준게 있으면 다시 원상 복귀
	if( m_LastChangeColor != -1) 
	{			
		m_PartyStatus[m_LastChangeColor].SetBackTexture("L2UI_CT1.Windows.Windows_DF_Small_Vertical_SizeControl_Bg_Darker");
		m_TargetID	 = -1;
		m_LastChangeColor = -1;
	}

	if(idx != -1) 
	{
		m_LastChangeColor = idx;
		m_PartyStatus[idx].SetBackTexture("L2UI_CT1.Windows.Windows_DF_Small_Vertical_SizeControl_Bg_Over");
	}
}




//리스타트를 하면 올클리어
function HandleRestart()
{
	Clear();
}

function ClearTargetHighLight () 
{
	local int i;
	for ( i = 0 ; i < MAX_ArrayNum ; i ++ ) 	
		m_PartyStatus[i].SetBackTexture("L2UI_CT1.Windows.Windows_DF_Small_Vertical_SizeControl_Bg_Darker");
	
	m_LastChangeColor = -1;
}

//초기화
function Clear()
{	
	local int idx;
	for (idx=0; idx<MAX_ArrayNum; idx++)
	{
		ClearStatus(idx);		// 모든 상태를 초기화해준다. 
		ClearPetStatus(idx);
		ClearSummonStatus(idx);

		m_arrSummonID[idx] = -1;
	}

	currentIndex = 0 ;
	matchGroupCount = 0 ;
	partyCount = 0 ;

	m_CurCount = 0;
	m_TargetID	 = -1;
	m_LastChangeColor = -1;
	ResizeWnd();
	ClearTargetHighLight();

	//Debug("AutoPartyMatchingStatusWnd 지워!!!!!");	
	//HideWindow( "AutoPartyMatchingStatusWnd" ); 자동대타 삭제
}

//상태창의 초기화
function ClearStatus(int idx)
{
	m_StatusIconBuff[idx].Clear();
	m_StatusIconDeBuff[idx].Clear();
	m_StatusIconSongDance[idx].Clear();
	m_StatusIconTriggerSkill[idx].Clear();
	m_PlayerName[idx].SetName("", NCT_Normal,TA_Left);
	m_LeaderIcon[idx].SetTexture("");
	m_ClassIcon[idx].SetTexture("");
	UpdateCPBar(idx, 0, 0);
	UpdateHPBar(idx, 0, 0);
	UpdateMPBar(idx, 0, 0);
	m_arrID[idx] = 0;
}

// 펫 상태창의 초기화
function ClearPetStatus(int idx)
{
	m_PetStatusIconBuff[idx].Clear();
	m_PetStatusIconDeBuff[idx].Clear();
	m_PetStatusIconSongDance[idx].Clear();
	m_PetStatusIconTriggerSkill[idx].Clear();
	//m_PetName[idx].SetName("", NCT_Normal,TA_Left);
	//m_PetClassIcon[idx].SetTexture("");
	m_PetClassIcon[idx].HideWindow();
	UpdateHPBar(idx + 100, 0, 0);
	UpdateMPBar(idx + 100, 0, 0);
	
	//if(m_PetPartyStatus[idx].IsShowWindow()) m_PetPartyStatus[idx].HideWindow();	// 펫창 없애기
	// if(m_petButton[idx].IsShowWindow()) m_petButton[idx].HideWindow();
	m_arrPetID[idx] = -1;
	m_arrPetIDOpen[idx] = -1;
	m_arrSummonID[idx] = -1;
}

// 펫 상태창의 초기화
function ClearSummonStatus(int idx)
{
	m_arrSummonID[idx] = -1;

	m_ClassIconSummon[idx].HideWindow();
	m_ClassIconSummonNum[idx].HideWindow();
}

//파티창의 복사 (목적이 되는 파티창의 인덱스, 복사할 파티창의 인덱스)
function CopyStatus(int DesIndex, int SrcIndex)
{
	local string	strTmp;	
	local int		MaxValue;	// CP, HP, MP의 최대값.
	local int		CurValue;	// CP, HP, MP의 현재값.
	
	local int		Width;
	local int		Height;
	
	local int		Row;
	local int		Col;
	local int		MaxRow;
	local int		MaxCol;
	local StatusIconInfo info;
	
	//Custom Tooltip
	local CustomTooltip TooltipInfo;
	local CustomTooltip TooltipInfo2;
	
	local string vpIconTextureName, vpToolTipString;

	local Color nameColor ;	

	//ServerID
	m_arrID[DesIndex] = m_arrID[SrcIndex];	
	
	//Class Texture
	m_ClassIcon[DesIndex].SetTexture(m_ClassIcon[SrcIndex].GetTextureName());
	//Class Tooltip
	m_ClassIcon[SrcIndex].GetTooltipCustomType(TooltipInfo);
	m_ClassIcon[DesIndex].SetTooltipCustomType(TooltipInfo);
	
	//파티장 Texture
	strTmp = m_LeaderIcon[SrcIndex].GetTextureName();
	m_LeaderIcon[DesIndex].SetTexture(strTmp);
	if (Len(strTmp)>0)
	{
		//아이콘을 이름의 옆에 위치시켜준다.
		strTmp = m_PlayerName[DesIndex].GetName();
		GetTextSizeDefault(strTmp, Width, Height);
		//주석위치 확인중
		//m_LeaderIcon[DesIndex].SetAnchor("PartyWndArena.PartyStatusWnd" $ DesIndex, "TopCenter", "TopLeft", -(Width/2)-18, 8);		
		//SetTypePosition
		m_LeaderIcon[DesIndex].ShowWindow();
	}
	//루팅 방식 툴팁
	m_LeaderIcon[SrcIndex].GetTooltipCustomType(TooltipInfo2);
	m_LeaderIcon[DesIndex].SetTooltipCustomType(TooltipInfo2);
	
	//CP,HP,MP
	m_BarCP[SrcIndex].GetValue(MaxValue, CurValue);
	m_BarCP[DesIndex].SetValue(MaxValue, CurValue);	
	m_BarMP[SrcIndex].GetValue(MaxValue, CurValue);
	m_BarMP[DesIndex].SetValue(MaxValue, CurValue);

	m_BarHP[SrcIndex].GetValue(MaxValue, CurValue);
	m_BarHP[DesIndex].SetValue(MaxValue, CurValue);

	// 죽거나 살거나.
	if ( CurValue == 0 ) m_IsDead[DesIndex].ShowWindow();
	else m_IsDead[DesIndex].hideWindow();

	// 매칭 그룹인 경우 이름에 컬러 지정
	if ( isMatchGroupMember ( m_arrID[DesIndex] ) ) 
	{
		// HP 인 경우.
		nameColor.R = 238;
		nameColor.G = 170;
		nameColor.B = 255;
		nameColor.A = 255;
	}
	else nameColor = util.White;
	//Name
	m_PlayerName[DesIndex].SetNameWithColor(m_PlayerName[SrcIndex].GetName(), NCT_Normal,TA_Left, nameColor);
//	m_PlayerName[idx].SetNameWithColor(VName, NCT_Normal,TA_Left, nameColor);

	// vp 교체 
	vpIconTextureName = m_VPIcon[DesIndex].GetTextureName();
	vpToolTipString = m_VPIcon[DesIndex].GetTooltipText();

	m_VPIcon[DesIndex].SetTexture(m_VPIcon[SrcIndex].GetTextureName());
	m_VPIcon[DesIndex].SetTooltipText(m_VPIcon[SrcIndex].GetTooltipText());

	m_VPIcon[SrcIndex].SetTexture(vpIconTextureName);
	m_VPIcon[SrcIndex].SetTooltipText(vpToolTipString);

	//BuffStatus
	m_StatusIconBuff[DesIndex].Clear();
	MaxRow = m_StatusIconBuff[SrcIndex].GetRowCount();
	for (Row=0; Row<MaxRow; Row++)
	{
		m_StatusIconBuff[DesIndex].AddRow();
		MaxCol = m_StatusIconBuff[SrcIndex].GetColCount(Row);
		for (Col=0; Col<MaxCol; Col++)
		{
			m_StatusIconBuff[SrcIndex].GetItem(Row, Col, info);
			m_StatusIconBuff[DesIndex].AddCol(Row, info);
		}
	}
	
	//DeBuffStatus
	m_StatusIconDeBuff[DesIndex].Clear();
	MaxRow = m_StatusIconDeBuff[SrcIndex].GetRowCount();
	for (Row=0; Row<MaxRow; Row++)
	{
		m_StatusIconDeBuff[DesIndex].AddRow();
		MaxCol = m_StatusIconDeBuff[SrcIndex].GetColCount(Row);
		for (Col=0; Col<MaxCol; Col++)
		{			
			m_StatusIconDeBuff[SrcIndex].GetItem(Row, Col, info);
			info.bHideRemainTime = true;
			m_StatusIconDeBuff[DesIndex].AddCol(Row, info);
		}
	}
	
	//SongDanceStatus
	m_StatusIconSongDance[DesIndex].Clear();
	MaxRow = m_StatusIconSongDance[SrcIndex].GetRowCount();
	for (Row=0; Row<MaxRow; Row++)
	{
		m_StatusIconSongDance[DesIndex].AddRow();
		MaxCol = m_StatusIconSongDance[SrcIndex].GetColCount(Row);
		for (Col=0; Col<MaxCol; Col++)
		{
			m_StatusIconSongDance[SrcIndex].GetItem(Row, Col, info);
			m_StatusIconSongDance[DesIndex].AddCol(Row, info);
		}
	}

	//TriggerSkillStatus
	m_StatusIconTriggerSkill[DesIndex].Clear();
	MaxRow = m_StatusIconTriggerSkill[SrcIndex].GetRowCount();
	for (Row=0; Row<MaxRow; Row++)
	{
		m_StatusIconTriggerSkill[DesIndex].AddRow();
		MaxCol = m_StatusIconTriggerSkill[SrcIndex].GetColCount(Row);
		for (Col=0; Col<MaxCol; Col++)
		{
			m_StatusIconTriggerSkill[SrcIndex].GetItem(Row, Col, info);
			m_StatusIconTriggerSkill[DesIndex].AddCol(Row, info);
		}
	}	
	
	// -------------------------------------------펫도 옮겨준다. 
	//ServerID
	m_arrPetID[DesIndex] = m_arrPetID[SrcIndex];
	m_arrSummonID[DesIndex] = m_arrSummonID[SrcIndex];

	// 팻 & 소환수 서브 창 열려 있는가 상태
	m_arrPetIDOpen[DesIndex] = m_arrPetIDOpen[SrcIndex];;	
	
	//CP,HP,MP
	m_PetBarHP[SrcIndex].GetValue(MaxValue, CurValue);
	m_PetBarHP[DesIndex].SetValue(MaxValue, CurValue);
	m_PetBarMP[SrcIndex].GetValue(MaxValue, CurValue);
	m_PetBarMP[DesIndex].SetValue(MaxValue, CurValue);
	
	
	//BuffStatus
	m_PetStatusIconBuff[DesIndex].Clear();
	MaxRow = m_PetStatusIconBuff[SrcIndex].GetRowCount();
	for (Row=0; Row<MaxRow; Row++)
	{
		m_PetStatusIconBuff[DesIndex].AddRow();
		MaxCol = m_PetStatusIconBuff[SrcIndex].GetColCount(Row);
		for (Col=0; Col<MaxCol; Col++)
		{
			m_PetStatusIconBuff[SrcIndex].GetItem(Row, Col, info);
			m_PetStatusIconBuff[DesIndex].AddCol(Row, info);
		}
	}
	
	//DeBuffStatus
	m_PetStatusIconDeBuff[DesIndex].Clear();
	MaxRow = m_PetStatusIconDeBuff[SrcIndex].GetRowCount();
	for (Row=0; Row<MaxRow; Row++)
	{
		m_PetStatusIconDeBuff[DesIndex].AddRow();
		MaxCol = m_PetStatusIconDeBuff[SrcIndex].GetColCount(Row);
		for (Col=0; Col<MaxCol; Col++)
		{
			m_PetStatusIconDeBuff[SrcIndex].GetItem(Row, Col, info);
			info.bHideRemainTime = true;
			m_PetStatusIconDeBuff[DesIndex].AddCol(Row, info);
		}
	}

	//SongDanceStatus
	m_PetStatusIconSongDance[DesIndex].Clear();
	MaxRow = m_PetStatusIconSongDance[SrcIndex].GetRowCount();
	for (Row=0; Row<MaxRow; Row++)
	{
		m_PetStatusIconSongDance[DesIndex].AddRow();
		MaxCol = m_PetStatusIconSongDance[SrcIndex].GetColCount(Row);
		for (Col=0; Col<MaxCol; Col++)
		{
			m_PetStatusIconSongDance[SrcIndex].GetItem(Row, Col, info);
			m_PetStatusIconSongDance[DesIndex].AddCol(Row, info);
		}
	}

	//TriggerSkillStatus
	m_PetStatusIconTriggerSkill[DesIndex].Clear();
	MaxRow = m_PetStatusIconTriggerSkill[SrcIndex].GetRowCount();
	for (Row=0; Row<MaxRow; Row++)
	{
		m_PetStatusIconTriggerSkill[DesIndex].AddRow();
		MaxCol = m_PetStatusIconTriggerSkill[SrcIndex].GetColCount(Row);
		for (Col=0; Col<MaxCol; Col++)
		{
			m_PetStatusIconTriggerSkill[SrcIndex].GetItem(Row, Col, info);
			m_PetStatusIconTriggerSkill[DesIndex].AddCol(Row, info);
		}
	}

	// 타겟팅 처리
	ClearTargetHighLight();
	HandleCheckTarget();
}

function resizeOnly() 
{
	local int idx;
	local Rect rectWnd;
	local bool bOption;
	local int i;
	local int OpenPetCount;

	local  PartyMemberInfo partyMemberInfo;

	local int tmpInt;

	// SetOptionBool과 페어. 이 변수는 PartyWndOption 에서 변경됨
	GetINIInt( "PartyWndArena", "e", tmpInt, "Windowsinfo.ini"  ) ;
	bOption = bool ( tmpInt ) ;//GetOptionBool( "Game", "SmallPartyWnd" );
	
	// Debug("-- m_CurCount " @ m_CurCount);
	if (m_CurCount>0)
	{				
		for (idx=0; idx<MAX_ArrayNum; idx++)
		{
			if (idx<=m_CurCount-1)
			{
				if(idx >0 )	 //1 이상일때의 anchor를 처리해준다.
				{
					if(m_arrPetIDOpen[idx-1] == 1) // 앞 파티원의 소환수가 열려있다면
					{
						m_PartyStatus[idx].SetAnchor("PartyWndArena.PartyStatusSummonWnd" $ idx-1, "BottomLeft", "TopLeft", 0, -4);	// 펫 윈도우 밑으로 앵커
					}
					else// 앞 파티원의 소환수가 닫혀있거나 소환수가 없으면
					{
						m_PartyStatus[idx].SetAnchor("PartyWndArena.PartyStatusWnd" $ idx-1, "BottomLeft", "TopLeft", 0, -4);	// 파티원 밑으로 앵커
					}
				}
				if(m_arrID[idx]!= 0 )
				{
					if (m_arrPetIDOpen[idx] > -1)  m_petButton[idx].showWindow();
					else	m_petButton[idx].HideWindow();

					m_PartyStatus[idx].SetVirtualDrag( true );
					m_PartyStatus[idx].ShowWindow();
				}
				// if(m_arrPetIDOpen[idx] == 1) m_PetPartyStatus[idx].ShowWindow();

				
				// 파티원 정보
				GetPartyMemberInfo(m_arrID[idx], partyMemberInfo);

				//Debug("RESIZE ---> partyMemberInfo.curSummonNum : "  @ partyMemberInfo.curSummonNum);
				// Debug("RESIZE ---> partyMemberInfo.curHavePet   : "  @ partyMemberInfo.curHavePet);
			
				// 소환수가 1마리 이상 있거나, 팻이 있다면
				// 보조창 열기
				if (partyMemberInfo.curSummonNum > 0 || partyMemberInfo.curHavePet)
				{
					if (m_arrPetIDOpen[idx] == -1) 
					{
						m_arrPetIDOpen[idx] = 1;
					}
					
					// 보조창을 연다.
					m_PetPartyStatus[idx].ShowWindow();

					// Debug("m_arrPetIDOpen[i] " @ m_arrPetIDOpen[idx]);
					// Debug("-보조창을 연다 " @ idx @ "  - > "  @ partyMemberInfo.curSummonNum);

					// 소환수가 한마리 라도 있다면..
					if (partyMemberInfo.curSummonNum > 0)
					{						
						m_ClassIconSummon[idx].ShowWindow();
						setHideClassIconSummonNum( idx ) ;
						//m_ClassIconSummonNum[idx].ShowWindow();
						m_ClassIconSummonNum[idx].SetTexture("L2UI_ch3.PartyWndArena.party_summmon_num" $ String(partyMemberInfo.curSummonNum));
					}
					else
					{
						// 소환수가 없다면..
						m_ClassIconSummon[idx].HideWindow();
						m_ClassIconSummonNum[idx].HideWindow();
					}

					// 버튼을 눌러 팻&소환수 확장 창을 사용자가 닫아 놓은 상태가 아니라면..
					//if (m_arrPetIDOpen[idx] != 2)

					// 팻이 존재 한다면..
					if (partyMemberInfo.curHavePet)
					{
						m_PetBarMP[idx].ShowWindow();
						m_PetBarHP[idx].ShowWindow();
						m_PetClassIcon[idx].ShowWindow();
					}
					else
					{
						// 팻이 없다면..
						m_PetBarMP[idx].HideWindow();
						m_PetBarHP[idx].HideWindow();
						m_PetClassIcon[idx].HideWindow();
					}
				}
				else
				{
					// 팻, 소환수 하나도 없다면.. 보조창 닫기 					
					m_PetPartyStatus[idx].HideWindow();
					m_arrPetIDOpen[idx] = -1;
				}

			}
			else
			{
				//Debug("창 닫기---rerere " @idx);
				m_petButton[idx].HideWindow();
				m_PartyStatus[idx].SetVirtualDrag( false );
				m_PartyStatus[idx].HideWindow();
				m_PetPartyStatus[idx].HideWindow();
			}
		}

		// 전체 창 사이즈를 정렬한다.
		OpenPetCount=0;
		for(i=0; i<MAX_ArrayNum; i++)
		{
			// Debug("m_arrPetIDOpen[i]==::" @ m_arrPetIDOpen[i]);
			if(m_arrPetIDOpen[i] == 1)
			{   
				OpenPetCount++;
			}
			else 	// 열려있는 상태가 아닌데..
			{
				 if(m_PetPartyStatus[i].IsShowWindow()) m_PetPartyStatus[i].HideWindow();
			}
		}

		// Debug("OpenPetCount : " @ OpenPetCount);
		
		//윈도우 사이즈 변경
		rectWnd = m_wndTop.GetRect();
		m_wndTop.SetWindowSize(rectWnd.nWidth, NPARTYSTATUS_HEIGHT*m_CurCount + OpenPetCount * NPARTYPETSTATUS_HEIGHT);	
		// 펫창이 열려진 만큼 윈도우 사이즈에서 더해준다. 
		m_wndTop.SetResizeFrameSize(10, NPARTYSTATUS_HEIGHT*m_CurCount  + OpenPetCount * NPARTYPETSTATUS_HEIGHT);
		
	}
	else	// 파티원이 존재하지 않으면 이 윈도우는 보이지 않는다.
	{
		m_wndTop.HideWindow();
	}
}


//윈도우의 사이즈 조정
function ResizeWnd()
{
	local int idx;
	local Rect rectWnd;
	local bool bOption;
	local int i;
	local int OpenPetCount;

	local  PartyMemberInfo partyMemberInfo;

	local int tmpInt;

	// SetOptionBool과 페어. 이 변수는 PartyWndOption 에서 변경됨
	GetINIInt( "PartyWndArena", "e", tmpInt, "Windowsinfo.ini"  ) ;
	bOption = bool ( tmpInt ) ;//GetOptionBool( "Game", "SmallPartyWnd" );
	
	// Debug("-- m_CurCount " @ m_CurCount);
	if (m_CurCount>0)
	{				
		for (idx=0; idx<MAX_ArrayNum; idx++)
		{
			if (idx<=m_CurCount-1)
			{
				if(idx >0 )	 //1 이상일때의 anchor를 처리해준다.
				{
					if(m_arrPetIDOpen[idx-1] == 1) // 앞 파티원의 소환수가 열려있다면
					{
						m_PartyStatus[idx].SetAnchor("PartyWndArena.PartyStatusSummonWnd" $ idx-1, "BottomLeft", "TopLeft", 0, -4);	// 펫 윈도우 밑으로 앵커
					}
					else// 앞 파티원의 소환수가 닫혀있거나 소환수가 없으면
					{
						m_PartyStatus[idx].SetAnchor("PartyWndArena.PartyStatusWnd" $ idx-1, "BottomLeft", "TopLeft", 0, -4);	// 파티원 밑으로 앵커
					}
				}
				if(m_arrID[idx]!= 0 )
				{
					if (m_arrPetIDOpen[idx] > -1)  m_petButton[idx].showWindow();
					else	m_petButton[idx].HideWindow();

					m_PartyStatus[idx].SetVirtualDrag( true );
					m_PartyStatus[idx].ShowWindow();
				}
				// if(m_arrPetIDOpen[idx] == 1) m_PetPartyStatus[idx].ShowWindow();

				
				// 파티원 정보
				GetPartyMemberInfo(m_arrID[idx], partyMemberInfo);

				//Debug("RESIZE ---> partyMemberInfo.curSummonNum : "  @ partyMemberInfo.curSummonNum);
				// Debug("RESIZE ---> partyMemberInfo.curHavePet   : "  @ partyMemberInfo.curHavePet);
			
				// 소환수가 1마리 이상 있거나, 팻이 있다면
				// 보조창 열기
				if (partyMemberInfo.curSummonNum > 0 || partyMemberInfo.curHavePet)
				{
					if (m_arrPetIDOpen[idx] == -1) 
					{
						m_arrPetIDOpen[idx] = 1;
					}
					
					// 보조창을 연다.
					m_PetPartyStatus[idx].ShowWindow();

					// Debug("m_arrPetIDOpen[i] " @ m_arrPetIDOpen[idx]);
					// Debug("-보조창을 연다 " @ idx @ "  - > "  @ partyMemberInfo.curSummonNum);

					// 소환수가 한마리 라도 있다면..
					if (partyMemberInfo.curSummonNum > 0)
					{						
						m_ClassIconSummon[idx].ShowWindow();
						setHideClassIconSummonNum( idx ) ;
						//m_ClassIconSummonNum[idx].ShowWindow();
						m_ClassIconSummonNum[idx].SetTexture("L2UI_ch3.PartyWndArena.party_summmon_num" $ String(partyMemberInfo.curSummonNum));
					}
					else
					{
						// 소환수가 없다면..
						m_ClassIconSummon[idx].HideWindow();
						m_ClassIconSummonNum[idx].HideWindow();
					}

					// 버튼을 눌러 팻&소환수 확장 창을 사용자가 닫아 놓은 상태가 아니라면..
					//if (m_arrPetIDOpen[idx] != 2)

					// 팻이 존재 한다면..
					if (partyMemberInfo.curHavePet)
					{
						m_PetBarMP[idx].ShowWindow();
						m_PetBarHP[idx].ShowWindow();
						m_PetClassIcon[idx].ShowWindow();
					}
					else
					{
						// 팻이 없다면..
						m_PetBarMP[idx].HideWindow();
						m_PetBarHP[idx].HideWindow();
						m_PetClassIcon[idx].HideWindow();
					}
				}
				else
				{
					// 팻, 소환수 하나도 없다면.. 보조창 닫기 					
					m_PetPartyStatus[idx].HideWindow();
					m_arrPetIDOpen[idx] = -1;
				}

			}
			else
			{
				//Debug("창 닫기---rerere " @idx);
				m_petButton[idx].HideWindow();
				m_PartyStatus[idx].SetVirtualDrag( false );
				m_PartyStatus[idx].HideWindow();
				m_PetPartyStatus[idx].HideWindow();
			}
		}

		// 전체 창 사이즈를 정렬한다.
		OpenPetCount=0;
		for(i=0; i<MAX_ArrayNum; i++)
		{
			// Debug("m_arrPetIDOpen[i]==::" @ m_arrPetIDOpen[i]);
			if(m_arrPetIDOpen[i] == 1)
			{   
				OpenPetCount++;
			}
			else 	// 열려있는 상태가 아닌데..
			{
				 if(m_PetPartyStatus[i].IsShowWindow()) m_PetPartyStatus[i].HideWindow();
			}
		}

		// Debug("OpenPetCount : " @ OpenPetCount);
		
		//윈도우 사이즈 변경
		rectWnd = m_wndTop.GetRect();
		m_wndTop.SetWindowSize(rectWnd.nWidth, NPARTYSTATUS_HEIGHT*m_CurCount + OpenPetCount * NPARTYPETSTATUS_HEIGHT);	
		// 펫창이 열려진 만큼 윈도우 사이즈에서 더해준다. 
		m_wndTop.SetResizeFrameSize(10, NPARTYSTATUS_HEIGHT*m_CurCount  + OpenPetCount * NPARTYPETSTATUS_HEIGHT);

		m_wndTop.ShowWindow();

		//if (!bOption)	// 옵션창에 체크가 되어있지 않으면 현재 (확장된) 윈도우를 활성화
		//	m_wndTop.ShowWindow();
		//else
		//	m_wndTop.HideWindow();
	}
	else	// 파티원이 존재하지 않으면 이 윈도우는 보이지 않는다.
	{
		m_wndTop.HideWindow();
	}
}

//ID로 몇번째 표시되는 파티원인지 구한다
function int FindPartyID(int ID)
{
	local int idx;
	for (idx=0; idx<MAX_ArrayNum; idx++)
	{
		if (m_arrID[idx] == ID)
		{
			return idx;
		}
	}
	return -1;
}

//ID로 몇번째 표시되는 펫인지 구한다
function int FindPetID(int ID)
{
	local int idx;
	for (idx=0; idx<MAX_ArrayNum; idx++)
	{
		if (m_arrPetID[idx] == ID)
		{
			return idx;
		}
	}
	return -1;
}

//ID로 몇번째 표시되는 소환수 마스터인지 구한다
function int FindSummonMasterID(int ID)
{
	local int idx;
	for (idx=0; idx<MAX_ArrayNum; idx++)
	{
		if (m_arrSummonID[idx] == ID)
		{
			return idx;
		}
	}
	return -1;
}

//ADD	파티원 추가.
function HandlePartyAddParty(string param)
{
	local int ID;
	local int SummonID;
	
	local int UseVName;
	local int DominionIDForVName;
	local int SummonCount;
	local string VName;
	local string SummonVName;

	// 파티 맴버 정보
	local PartyMemberInfo    partyMemberInfo;
	// 파티 맴버 팻 정보
	local PartyMemberPetInfo partyMemberPetInfo;

	local int index, i, summonClassID;

	local int summonType, summonMAXHP, summonMAXMP, summonHP, summonMP;
		

//	debug("HandlePartyAddParty>>" $ param);

	ParseInt(param, "ID", ID);	// ID를 파싱한다.
	ParseInt(param, "SummonID", SummonID);
	ParseInt(Param, "UseVName",UseVName);
	ParseInt(Param, "DominionIDForVName", DominionIDForVName);
	// ParseString(Param, "VName", VName);
	ParseString(Param, "SummonVName", SummonVName);	
	
	GetPartyMemberInfo(ID, partyMemberInfo);

	// 소환수 수를 얻는다.
	// ParseInt(Param, "SummonCount", summonCount);
	GetPartyMemberPetInfo(ID, partyMemberPetInfo);	

	if (ID>0)
	{		
		// 파티 멤버인 경우 앞에 위치 시킨다.
		if ( isMatchGroupMember( ID ) )
		{
			currentIndex = matchGroupCount;
			matchGroupCount ++ ;
		}
		else 
		{		
			currentIndex = m_arrMatchGroupMember.Length + partyCount ;
			partyCount ++ ;
		}

		m_CurCount++;
		m_Vname[currentIndex].ID = ID;
		m_Vname[currentIndex].UseVName = UseVName;
		m_Vname[currentIndex].DominionIDForVName = DominionIDForVName;
		m_Vname[currentIndex].VName = VName;
		m_Vname[currentIndex].SummonVName = SummonVName;
		ExecuteEvent( EV_TargetUpdate);
	
//		Debug("HandlePartyAddParty" @ currentIndex @ matchGroupCount @ partyCount @ m_CurCount @ m_arrMatchGroupMember.Length @ isMatchGroupMember( ID )) ;
		
		m_arrID[currentIndex] = ID;
		UpdateStatus(currentIndex, param);

		//util.showGfxScreenMessage ( MakeFullSystemMsg(getSystemMessage(107), m_PlayerName[currentIndex].GetName() )) ;

		// Debug("====================> param 팻 정보 " @ param);
		// Debug(":::: m_CurCount ====> " @ m_CurCount);
		// Debug("partyMemberInfo.curSummonNum: " @ partyMemberInfo.curSummonNum);
		// Debug("partyMemberInfo.curHavePet  : " @ partyMemberInfo.curHavePet);
		// if(SummonID > 0)	// 소환수가 있으면 소환수도 보여줌
		// 소환수가 있다면
		
		// 소환수가 한마리 이상, 또는 팻이 존재 한다면..
		if (partyMemberInfo.curSummonNum > 0)
		{
			// 소환수 마스터 ID 를 넣고 소환수 UI 갱신
			PartySummonProcess(ID);

			for (i = 0; i < SummonCount; i++)
			{
				ParseInt(param, "SummonType" $ i, summonType);
				ParseInt(param, "SummonClassID" $ i, summonClassID);

				// 소환수와 같다면..
				if (summonType == 1)
				{
					// 공격형 소환수, 방어형 소환수 같은 툴팁을 세팅한다.
					m_ClassIconSummon[currentIndex].SetTooltipText(GetSystemString(505));//getSummonSortString(class'UIDATA_NPC'.static.GetSummonSort(summonClassID)));
					//Debug( "npc : "@ class'UIDATA_NPC'.static.GetSummonSort(summonClassID) );
					
					break;
					// 루프 캔슬 
				}				
			}
		}

		if ( partyMemberInfo.curHavePet == true)
		{			
			// 팻이 새롭게 추가 
			index = FindPartyID(ID);
			// Debug("추가 추가 팻 " @ index);
			// 바로 hp, mp 바를 갱신 하기 위해서

			ParseInt(param, "SummonCount", SummonCount);

			// summonType 가 2인 것이 팻이다. 팻을 찾아서..
			// HP, MP바를 갱신 시킨다. 
			for (i = 0; i < SummonCount; i++)
			{
				ParseInt(param, "SummonType" $ i, summonType);

				if (summonType == 2)
				{
					ParseInt(param, "SummonMaxHP" $ i, SummonMaxHP);
					ParseInt(param, "SummonMaxMP" $ i, SummonMaxMP);
					ParseInt(param, "SummonHP"    $ i, SummonHP);
					ParseInt(param, "SummonMP"    $ i, SummonMP);

					// Debug("팻 업데이트 -> 추가 -> "@ SummonMaxHP);
					UpdateHPBar(index + 100, SummonHP, SummonMaxHP);
					UpdateMPBar(index + 100, SummonMP, SummonMaxMP);
				}				
			}

			m_arrPetID[index] = partyMemberPetInfo.petID;
			// m_arrPetIDOpen[index] = 1;			
		}		

		ResizeWnd();
	}
}


//UPDATE	특정 파티원 업데이트.
function HandlePartyUpdateParty(string param)
{
	local int	ID;
	local int	idx;
	
	//Debug("파티 :" @ param);

	ParseInt(param, "ID", ID);	

	if (ID>0)
	{
		idx = FindPartyID(ID);
		UpdateStatus(idx, param);	// 해당 인덱스의 파티원 정보를 갱신
	}
}

//DELETE	특정 파티원을 삭제.
function HandlePartyDeleteParty(string param)
{
	local int	ID;
	local int	idx;
	local int	i;
	
	//Debug("특정 파티원을 삭제 :" @ param);
	
	ParseInt(param, "ID", ID);

	if (ID>0)
	{
		idx = FindPartyID(ID);	
		//util.showGfxScreenMessage ( MakeFullSystemMsg(getSystemMessage(108), m_PlayerName[idx].GetName() )) ;

		if (idx>-1)
		{	
			if ( isMatchGroupMember ( ID ) ) 				
				matchGroupCount --;
			else partyCount --;

			for (i=idx; i<m_CurCount-1; i++)	// 삭제하려는 파티원 아래의 파티원들을 땡겨준다. 
			{
				CopyStatus(i, i+1);
			}
			ClearStatus(m_CurCount-1);
			ClearPetStatus(m_CurCount-1);
			m_CurCount--;
			ResizeWnd();	// 만약 파티원이 자신밖에 없다면 알아서 파티윈도우는 사라짐.
		}
		
	}
}

//DELETE ALL	그저 모두 지울뿐..
function HandlePartyDeleteAllParty()
{
	Clear();
}

//Set Info	특정 인덱스의 파티원의 정보 갱신. 서버 아이디 정보는 확인을 위해 필요하다.

function SetMasterTooltip(int lootingtype)
{
	if(partymasteridx < MAX_ArrayNum && partymasteridx > -1)
		m_LeaderIcon[partymasteridx].SetTooltipCustomType(MakeTooltipSimpleText(GetRoutingString(lootingtype)));	
}

function UpdateStatus(int idx, string param)
{
	local string	Name;
	//local int		MasterID;
	//local int		RoutingType;
	local int		ID;
	local int		CP;
	local int		MaxCP;
	local int		HP;
	local int		MaxHP;
	local int		MP;
	local int		MaxMP;
	local int		ClassID;
	local int		Level;
	local int		Vitality;
	local userinfo 	TargetUser;
	//~ local int		SummonID;
	
	//local int		Width;
	//local int		Height;	
	
	local int UseVName;
	//local int DominionIDForVName;
	local string VName;
	//local string SummonVName;
	
	//소환수 수 
	local int SummonCount; 
	// 소환수 툴팁 
	//local string SummonTooltipStr;
	// 소환수 닉네임 
	//local string SummonNickName; 
	
	//현재파티원의 자동파티 신청상태
	local int iSubstatus;

	local Color nameColor;

	ParseInt(param, "SubStitute", iSubstatus);

	if (idx<0 || idx>=MAX_ArrayNum)
		return;
	
	ParseString(param, "Name", Name);
	ParseInt(param, "ID", ID);
	GetUserInfo(ID, TargetUser);
	
	ParseInt(param, "CurCP", CP);
	ParseInt(param, "MaxCP", MaxCP);
	ParseInt(param, "CurHP", HP);
	ParseInt(param, "MaxHP", MaxHP);
	ParseInt(param, "CurMP", MP);
	ParseInt(param, "MaxMP", MaxMP);
	ParseInt(param, "ClassID", ClassID);
	ParseInt(param, "Level", Level);
	ParseInt(param, "Vitality", Vitality);

	ParseInt(param, "SummonCount", SummonCount);

	//파티장 아이디.
	//ParseInt(param, "MasterID", PartyLeaderID);

	if ( isMatchGroupMember ( ID ) ) 
	{		
		nameColor.R = 238;
		nameColor.G = 170;
		nameColor.B = 255;
		nameColor.A = 255 ;	
	}		
	else nameColor = util.White;

	if ( HP == 0 ) m_IsDead[idx].ShowWindow();
	else m_IsDead[idx].hideWindow();
	
	//펫이 없다면 0
	/*
	for(i = 0; i < SummonCount; i++) 
	{
		ParseString (param, "SummonNickName" $i, SummonNickName);		
		ParseInt(param, "SummonID"      $ i, SummonID);		
		ParseInt(param, "SummonType"    $ i, SummonType);
		ParseInt(param, "SummonClassID" $ i, SummonClassID);		
		ParseInt(param, "SummonHP"      $ i, SummonHP);
		ParseInt(param, "SummonMaxHP"   $ i, SummonMaxHP);
		ParseInt(param, "SummonMP"      $ i, SummonMP);
		ParseInt(param, "SummonMaxMP"   $ i, SummonMaxMP);
		ParseInt(param, "SummonLevel"   $ i, SummonLevel);
		
	}
	*/

	// 소환수가 존재 한다면..
	/*
	if (SummonCount > 0)
	{
		SummonTooltipStr = SummonNickName;
	}*/

	UseVName = m_Vname[idx].UseVName;
	//DominionIDForVName = m_Vname[idx].DominionIDForVName;
	VName = m_Vname[idx].VName;
	//SummonVName = m_Vname[idx].SummonVName;
	
	if (UseVName == 1)
		m_PlayerName[idx].SetNameWithColor(VName, NCT_Normal,TA_Left, nameColor);
	else
		m_PlayerName[idx].SetNameWithColor(Name, NCT_Normal,TA_Left, nameColor);
	
	//팟장 아이콘
	//if (ParseInt(param, "MasterID", MasterID))
	//{
	//	if (MasterID>0 && MasterID==ID)
	//	{	
	//		partymasteridx = idx;
	//		ParseInt(param, "RoutingType", RoutingType);
	//		m_LeaderIcon[idx].SetTexture("L2UI_CH3.PartyWndArena.party_leadericon");
	//		m_LeaderIcon[idx].SetTooltipCustomType(MakeTooltipSimpleText(GetRoutingString(RoutingType)));
			
	//		//아이콘을 이름의 옆에 위치시켜준다.
	//		GetTextSizeDefault(Name, Width, Height);
	//		//m_LeaderIcon[idx].SetAnchor("PartyWndArena.PartyStatusWnd" $ idx, "TopCenter", "TopLeft", -(Width/2)-18, 8);
	//		//SetTypePosition( idx, 1 );
	//	}
	//	else
	//	{
	//		m_LeaderIcon[idx].SetTexture("");
	//		m_LeaderIcon[idx].SetTooltipCustomType(MakeTooltipSimpleText(""));
	//		//SetTypePosition( idx, 0 );
	//	}
	//}
	
	//직업 아이콘
	//m_ClassIcon[idx].SetTexture(GetClassRoleIconName(ClassID));	
	m_ClassIcon[idx].SetTexture(GetClassArenaRoleIconName(ClassID));
	
	m_ClassIcon[idx].SetTooltipCustomType(MakeTooltipSimpleText(GetClassRoleName(ClassID) $ " - " $ GetClassType(ClassID)));
	
	//각종 게이지
	UpdateCPBar(idx, CP, MaxCP);
	UpdateHPBar(idx, HP, MaxHP);
	UpdateMPBar(idx, MP, MaxMP);

	//파티원 추가일 때는 Vitality값 없음, 파티원 update일때는 있음.???
}

function HandlePartyPetAdd( string param )
{
	local int	MasterID;
	local int	ID;
	local int	i;

	// 소환수 1, 팻 2
	local int   type;
	local int	MasterIndex;
	
	ParseInt(param, "Type", type);	// 마스터 ID를 파싱한다.

	// Debug("팻 추가 @" @ param);
	if (type == 2)
	{
		// 마스터 ID를 파싱한다.
		ParseInt(param, "MasterID", MasterID);	

		// ID를 파싱한다.
		ParseInt(param, "ID", ID);	

		if (MasterID>0)
		{
			MasterIndex = -1;
			for(i=0; i< MAX_ArrayNum ; i++)
			{
				if(m_arrID[i] == MasterID) MasterIndex = i;
			}
			
			if(MasterIndex == -1)
			{
				//debug("HandlePartyPetAdd ERROR - Can't find master ID");
				return;
			}
						
			m_arrPetID[MasterIndex] = ID;
			m_arrPetIDOpen[MasterIndex] = 1;

			UpdatePetStatus(MasterIndex, param);
			ResizeWnd();
		}
	}
}

function HandlePartyPetUpdate( string param )
{
	local int	id;
	local int	idx;

	local int	type;
	
	//debug(" PartySummonUpdate !! ");

	// 소환수 1, 팻 2 
	ParseInt(param, "Type", type);

	ParseInt(param, "ID", id);
	// Debug("팻 업데이트"@ param);
	
	// 팻 
	if (type == 2)
	{	
		idx = FindPetID(id);

		// Debug("idx " @ idx);
		// 해당 인덱스의 펫 정보를 갱신
		UpdatePetStatus(idx, param);	
	}
}


function HandlePartyPetDelete( string param )
{
	local int	SummonID;
	local int	idx;
	//~ local int	i;
	
	ParseInt(param, "SummonID", SummonID);
	if (SummonID>0)
	{
		idx = FindPetID(SummonID);
		if (idx>-1)
		{	
			ClearPetStatus(idx);
			ResizeWnd();	// 만약 파티원이 자신밖에 없다면 알아서 파티윈도우는 사라짐.
		}
	}
}


function UpdatePetStatus(int idx, string param)
{
	local int		ID;			// 펫 ID
	local int		ClassID;	// 펫 종류
	local int		Type;		// 펫 타입 1-소환수 2-펫
	local int		MasterID;	// 주인의 ID
	// local string	NickName;  	// 펫 이름
		
	local int		HP;
	local int		MaxHP;
	local int		MP;
	local int		MaxMP;
	local int		Level;
	
	if (idx<0 || idx>=MAX_ArrayNum)
		return;
	
	ParseInt(param, "ID", ID);
	ParseInt(param, "ClassID", ClassID);
	ParseInt(param, "Type", Type);
	ParseInt(param, "MasterID", MasterID);
	ParseInt(param, "HP", HP);
	ParseInt(param, "MaxHP", MaxHP);
	ParseInt(param, "MP", MP);
	ParseInt(param, "MaxMP", MaxMP);
	ParseInt(param, "Level", Level);
	
	//툴팁
	// m_PetClassIcon[idx].SetTexture("L2UI_CT1.Icon.ICON_DF_PETICON");
	//m_PetClassIcon[idx].SetTooltipCustomType(MakeTooltipSimpleText(m_PetName[idx].GetName()));
			
	//펫 아이콘
	//m_ClassIcon[idx].SetTexture(GetClassRoleIconName(SummonClassID));
	//m_ClassIcon[idx].SetTooltipCustomType(MakeTooltipSimpleText(GetClassRoleName(ClassID) $ " - " $ GetClassType(ClassID)));
	
	// debug(" idx :MaxHP" @ idx @ "__" @MaxHP);
	//각종 게이지
	UpdateHPBar(idx + 100, HP, MaxHP);
	UpdateMPBar(idx + 100, MP, MaxMP);
}

/**
 *  파티원의 소환수 추가
 **/
function HandlePartySummonAdd( string param )
{
	local int	MasterID;
	local int	ID;
	local int	idx;

	// 소환수 1, 팻 2
	local int   type;

	local SummonInfo m_SummonInfo; 

	ParseInt(param, "Type", type);	
	ParseInt(param, "MasterID", MasterID);
	ParseInt(param, "ID", ID);

	GetSummonInfo(ID, m_SummonInfo);
	// debug("class " @  m_SummonInfo.nClassID);
	// Debug("소환수 추가 @" @ param);

	idx = FindSummonMasterID(MasterID);
	if (idx > 0)
	{
		m_ClassIconSummon[idx].SetTooltipText(GetSystemString(505));//getSummonSortString(class'UIDATA_NPC'.static.GetSummonSort(m_SummonInfo.nClassID)));
	}

	if (type == 1)
	{		
		PartySummonProcess(MasterID);
	}
}

/**
 *  파티의 소환수의 정보를 받아서 보조창에서 표현 
 **/
function PartySummonProcess( int MasterID ) 
{
	local int	i;

	local int	MasterIndex;

	local PartyMemberInfo partyMemberInfo;
	
	if (MasterID>0)
	{
		MasterIndex = -1;
		for(i=0; i< MAX_ArrayNum ; i++)
		{
			if(m_arrID[i] == MasterID)
			{
				MasterIndex = i;
				break;
			}
		}
		
		if(MasterIndex == -1)
		{
			//debug("PartySummonProcess -> ERROR - Can't find master ID");
			return;
		}
		
		GetPartyMemberInfo(MasterID, partyMemberInfo);

		if (partyMemberInfo.curSummonNum > 0)
		{
			// 팻 소환수 보조 창 열기
			// 소환수 마스터 ID 넣기
			m_arrSummonID[MasterIndex] = MasterID;
		}
		else
		{
			// 닫기
			// 소환수 마스터 ID 넣기
			m_arrSummonID[MasterIndex] = -1;			
		}
		
		// 창 갱신 
		ResizeWnd();		
	}
}

/**
 *  파티원의 소환수 업데이트
 **/
function HandlePartySummonUpdate( string param )
{
	local int	MasterID;

	// 소환수 1, 팻 2
	local int   type;

	// 맴버 아이디르 통해서 소환수 수를 얻고 그걸 갱신 해주는 코드를 넣어야 함
	// debug("수환수 업데이트 !" @param);

	ParseInt(param, "MasterID", MasterID);
	ParseInt(param, "Type", type);	

	// 소환수 
	if (type == 1)
	{	
		PartySummonProcess(MasterID);
	}
}



function HandlePartySummonDelete( string param )
{
	local int	SummonMasterID;
	local int	idx;
	local  PartyMemberInfo partyMemberInfo;

	
	ParseInt(param, "SummonMasterID", SummonMasterID);

	if (SummonMasterID>0)
	{

		// 소환수 마스터의 index 를 찾는다.
		idx = FindSummonMasterID(SummonMasterID);

		GetPartyMemberInfo(SummonMasterID, partyMemberInfo);
		// Debug("해제.. ---> partyMemberInfo.curSummonNum : "  @ partyMemberInfo.curSummonNum);

		// 소환수가 한마리 라도 있다면..
		if (partyMemberInfo.curSummonNum > 0)
		{						
			m_ClassIconSummon[idx].ShowWindow();
			setHideClassIconSummonNum( idx ) ;
			//m_ClassIconSummonNum[idx].ShowWindow();
			m_ClassIconSummonNum[idx].SetTexture("L2UI_ch3.PartyWndArena.party_summmon_num" $ String(partyMemberInfo.curSummonNum));
		}
		else
		{
			// 소환수가 없다면..
			ClearSummonStatus(idx);
		}		
		ResizeWnd();			
	}
}

/**
 *  소환수 상태 업데이트 
 **/
function UpdateSummonStatus(int idx, string param)
{
	local int		ID;			// 펫 ID
	local int		ClassID;		// 펫 종류
	local int		Type;		    // 펫 타입 1-소환수 2-펫
	local int		MasterID;	    // 주인의 ID
	// local string	NickName;  	// 펫 이름
		
	local int		HP;
	local int		MaxHP;
	local int		MP;
	local int		MaxMP;
	local int		Level;
	
	if (idx<0 || idx>=MAX_ArrayNum)
		return;
	
	ParseInt(param, "ID", ID);
	ParseInt(param, "ClassID", ClassID);
	ParseInt(param, "Type", Type);
	ParseInt(param, "MasterID", MasterID);
	ParseInt(param, "HP", HP);
	ParseInt(param, "MaxHP", MaxHP);
	ParseInt(param, "MP", MP);
	ParseInt(param, "MaxMP", MaxMP);
	ParseInt(param, "Level", Level);
	
	
	// debug(":MaxHP" @MaxHP);
	//각종 게이지

	// 각 소환수는 현재 상태 정보를 표현 하지 않음 (단지 수만 표시)
	// UpdateHPBar(idx + 100, HP, MaxHP);
	// UpdateMPBar(idx + 100, MP, MaxMP);
}


//버프리스트정보
function HandlePartySpelledList(string param)
{
	local int i;
	local int idx;
	local int ID;
	local int Max;
	
	local int BuffCnt;
	local int BuffCurRow;
	
	local int DeBuffCnt;
	local int DeBuffCurRow;
	
	//~ local int SongDanceCnt;
	//local int SongDanceCurRow;
	
	local int TriggerSkillCnt;
	local int TriggerSkillCurRow;
	
	local bool isPC;	//pc인지 펫인지 체크하는 함수
	
	local StatusIconInfo info;
	
	DeBuffCurRow = -1;
	BuffCurRow = -1;
	//SongDanceCurRow = -1;
	TriggerSkillCurRow = -1;
	isPC = false;
	
	ParseInt(param, "ID", ID);
	if (ID<1)
	{
		return;
	}
	
	idx = FindPartyID(ID);
	if(idx >=0)
	{
		//버프 초기화
		m_StatusIconBuff[idx].Clear();
		m_StatusIconDeBuff[idx].Clear();
		m_StatusIconSongDance[idx].Clear();
		m_StatusIconTriggerSkill[idx].Clear();
		isPC = true;
	}
	else	// 파티원이면 여긴 그냥 패스
	{
		idx = FindPetID(ID);	// 파티원이 아니라면, 펫인지 살펴본다. 
		if(idx >= 0)
		{
			//버프 초기화
			m_PetStatusIconBuff[idx].Clear();
			m_PetStatusIconDeBuff[idx].Clear();
			m_PetStatusIconSongDance[idx].Clear();
			m_PetStatusIconTriggerSkill[idx].Clear();
			isPC = false;
		}
		else
		{
			return;	// 펫 아이디마저 없다면 걍 무시무시
		}
	}
		
	//info 초기화
	if ( isPC ) 
	{
		info.Size = 16;
	}
	else 
	{
		info.Size = 10;
	}
	
	info.bShow = true;
	
	ParseInt(param, "Max", Max);
	for (i=0; i<Max; i++)
	{
		ParseItemIDWithIndex(param, info.ID, i);
		ParseInt(param, "Level_" $ i, info.Level);
		ParseInt(param, "SubLevel_" $ i, info.SubLevel);

		// 토핑 버프인 경우 add 하지 않음.
		if ( class'UIDATA_SKILL'.static.IsToppingSkill( info.ID, info.Level, info.SubLevel) ) 
		{			
			continue ;
		}

		ParseInt(param, "Sec_" $ i, info.RemainTime);

		ParseInt(param, "SpellerID_" $ i, info.SpellerID);

		//Debug( "HandlePartySpelledList" @ idx @ info.SpellerID @ info.Level @ info.ID.ClassID @  i);

		if (IsValidItemID(info.ID))
		{
			info.IconName = class'UIDATA_SKILL'.static.GetIconName(info.ID, info.Level, info.SubLevel);
			
			if (GetDebuffType( info.ID, info.Level, info.SubLevel) != 0 )
			{
				info.bHideRemainTime = true;
				if (DeBuffCnt%NSTATUSICON_MAXCOL == 0)
				{
					DeBuffCurRow++;
					if(isPC)	
					{			
						m_StatusIconDeBuff[idx].AddRow();
					}
					else		
					{	
						m_PetStatusIconDeBuff[idx].AddRow();
					}
				}
				if(isPC)	
				{				
					m_StatusIconDeBuff[idx].AddCol(DeBuffCurRow, info);	
				}
				else 		
				{					
					m_PetStatusIconDeBuff[idx].AddCol(DeBuffCurRow, info);	
				}
				DeBuffCnt++;
			}
			else if (IsSongDance( info.ID, info.Level, info.SubLevel) == true )
			{
				//~ debug("송댄스입니까?");
				//~ SongDanceCurRow++;
				if(isPC)	
				{					
					m_StatusIconSongDance[idx].AddRow();
				}
				else		
				{				
					m_PetStatusIconSongDance[idx].AddRow();
				}
				
				if(isPC)	
				{				
					m_StatusIconSongDance[idx].AddCol(0, info);	
				}
				else 		
				{				
					m_PetStatusIconSongDance[idx].AddCol(0, info);	
				}
				//~ SongDanceCurRow++;
			}
			else if (IsTriggerSkill( info.ID, info.Level, info.SubLevel) == true )
			{
				//~ debug("발동버프입니까?");
				if (TriggerSkillCnt % NSTATUSICON_MAXCOL == 0)
				{
					TriggerSkillCurRow++;
					if(isPC)	
					{				
						m_StatusIconTriggerSkill[idx].AddRow();
					}
					else		
					{					
						m_PetStatusIconTriggerSkill[idx].AddRow();
					}
				}
					
				if(isPC)	
				{					
					m_StatusIconTriggerSkill[idx].AddCol(TriggerSkillCurRow, info);	
				}
				else 		
				{				
					m_PetStatusIconTriggerSkill[idx].AddCol(TriggerSkillCurRow, info);	
				}
				TriggerSkillCnt++;
			}
			else
			{
				//~ debug("일반 버프입니까?");
				if (BuffCnt%NSTATUSICON_MAXCOL == 0)
				{
					BuffCurRow++;
					if(isPC)	
					{						
						m_StatusIconBuff[idx].AddRow();
					}
					else
					{					
						m_PetStatusIconBuff[idx].AddRow();
					}
				}
				if(isPC)	
				{					
					m_StatusIconBuff[idx].AddCol(BuffCurRow, info);	
				}
				else		
				{				
					m_PetStatusIconBuff[idx].AddCol(BuffCurRow, info);	
				}
				BuffCnt++;
			}
		}
	}
	UpdateBuff();
}



//버프리스트삭제
function HandlePartySpelledListDelete(string param)
{
	local int i;		
	local int idx;
	local int ID;
	local int Max;		
	local StatusIconInfo info;		

	local bool isPC;
	
	ParseInt(param, "ID", ID);	

	if (ID<1) return;	
	idx = FindPartyID(ID);	
	if ( idx < 0 ) 
	{
		isPC = false;
		idx = FindPetID(ID);
	} 
	else isPC = true;

	if ( idx < 0 ) return;	
		
	ParseInt(param, "Max", Max);	

	for (i=0; i<Max; i++)
	{
		//버프 종류를 알기 위한 ID, Level
		ParseItemIDWithIndex(param, info.ID, i );
		ParseInt(param, "Level_" $ i, info.Level );
		ParseInt(param, "SubLevel_" $ i, info.SubLevel );

		//ttp 60079
		ParseInt(param, "SpellerID_" $ i, info.SpellerID );

		//Debug( "HandlePartySpelledListDelete"  @ idx @ info.SpellerID @ info.Level @ info.ID.ClassID @  i ) ;
		
		if (IsValidItemID(info.ID))
		{	
			//디버프이면 
			if (GetDebuffType( info.ID, info.Level, info.SubLevel) != 0 )
			{
				if ( isPC ) deleteBuff ( m_StatusIconDeBuff[idx], info.Level, info.ID.ClassID, info.SpellerID ); 
				else 		deleteBuff ( m_PetStatusIconDeBuff[idx], info.Level, info.ID.ClassID, info.SpellerID ); 							
			}
			//송댄스
			else if (IsSongDance( info.ID, info.Level, info.SubLevel) == true )
			{	
				if ( isPC ) deleteBuff ( m_StatusIconSongDance[idx], info.Level, info.ID.ClassID, info.SpellerID );
				else        deleteBuff ( m_PetStatusIconSongDance[idx], info.Level, info.ID.ClassID, info.SpellerID );
			}
			//디버프
			else if (IsTriggerSkill( info.ID, info.Level, info.SubLevel) == true )
			{								
				if ( isPC ) deleteBuff ( m_StatusIconTriggerSkill[idx], info.Level, info.ID.ClassID, info.SpellerID );
				else        deleteBuff ( m_PetStatusIconTriggerSkill[idx], info.Level, info.ID.ClassID, info.SpellerID ); 
			}
			//일반 버프 
			else
			{				
				if ( isPC ) deleteBuff ( m_StatusIconBuff[idx], info.Level, info.ID.ClassID, info.SpellerID ); 
				else        deleteBuff ( m_PetStatusIconBuff[idx], info.Level, info.ID.ClassID, info.SpellerID );
			}
			
			
		}
	}
	UpdateBuff();
}

//받은 정보의 버프를 찾아 삭제 하는 함수
//ttp 60079 로 SpellerID 추가.
function deleteBuff( StatusIconHandle tmpStatusIcon , int level, int classID, int SpellerID )
{
	local int row;	
	local int col;
	local StatusIconInfo info;	

	for ( row = 0 ; row < tmpStatusIcon.GetRowCount(); row++ )
	{
		for ( col = 0 ; col < tmpStatusIcon.GetColCount(row) ; col++)
		{
			tmpStatusIcon.GetItem(row, col, info );			
			if ( info.ID.classID == classID && info.level ==  level && info.SpellerID == SpellerID )
			{
				tmpStatusIcon.DelItem( row, col );
				refreshPostion( tmpStatusIcon , row );
				return;
			}
		}
	}
}
//버프가 두 줄 이상 들어갈 경우 버프를 한 칸씩 땡겨 주는 함수
function refreshPostion ( StatusIconHandle tmpStatusIcon , int deletedRow  )
{
	local int row;
	local StatusIconInfo info;	

	for ( row = deletedRow ; row < tmpStatusIcon.GetRowCount() -1 ; row ++ )
	{
		tmpStatusIcon.GetItem (row + 1 ,   0,  info );//다음 줄에 있는 것 중 맨 앞의 것을 가져 오고 
		tmpStatusIcon.addCol( row, info);// 그 아이템을 지워진 줄에 채워 넣은 다음
		tmpStatusIcon.DelItem( row + 1, 0 ); // 지운다.
	}
}

//버프리스트추가
function HandlePartySpelledListInsert(string param)
{
	local int i;	
	local int idx;
	local int ID;
	local int Max;

	local StatusIconInfo info;
	local StatusIconHandle tmpStatusIcon;

	local bool isPC;
		
	ParseInt(param, "ID", ID);	

	if (ID<1) return;	

	idx = FindPartyID(ID);	
	if ( idx < 0 ) 
	{
		isPC = false;
		idx = FindPetID(ID);
	} 
	else isPC = true;

	if ( idx < 0 ) return;
		
	//info 초기화
	if ( isPC ) 
	{
		info.Size = 16;
	}
	else 
	{
		info.Size = 10;
	}
	
	info.bShow = true;	

//	Debug( "HandlePartySpelledListInsert" @ String(isPC) @ idx);
	//Max=1 ID=1209091781 ClassID_0=77 Level_0=2 Sec_0=1200
	ParseInt(param, "Max", Max);

	for (i=0; i<Max; i++)
	{
		ParseItemIDWithIndex(param, info.ID, i);
		ParseInt(param, "Level_" $ i, info.Level);
		ParseInt(param, "SubLevel_" $ i, info.SubLevel);
		
		// 토핑 버프인 경우 add 하지 않음.
		if ( class'UIDATA_SKILL'.static.IsToppingSkill( info.ID, info.Level, info.SubLevel) ) 
		{			
			continue ;
		}

		ParseInt(param, "Sec_" $ i, info.RemainTime);

		//ttp 60079
		ParseInt(param, "SpellerID_" $ i, info.SpellerID);
		//Debug( "HandlePartySpelledListInsert"  @ idx @ info.SpellerID @ info.Level @ info.ID.ClassID @  i ) ;

		if (IsValidItemID(info.ID))
		{
			info.IconName = class'UIDATA_SKILL'.static.GetIconName(info.ID, info.Level, info.SubLevel);
			info.bHideRemainTime = true;

			//디버프이면 
			if (GetDebuffType( info.ID, info.Level, info.SubLevel) != 0 )
			{
				if ( isPC ) tmpStatusIcon = m_StatusIconDeBuff[idx];
				else 		tmpStatusIcon = m_PetStatusIconDeBuff[idx];				
				
			}
			//송댄스
			else if (IsSongDance( info.ID, info.Level, info.SubLevel) == true )
			{	
				if ( isPC ) tmpStatusIcon = m_StatusIconSongDance[idx];	
				else        tmpStatusIcon = m_PetStatusIconSongDance[idx];
			}
			//디버프
			else if (IsTriggerSkill( info.ID, info.Level, info.SubLevel) == true )
			{								
				if ( isPC ) tmpStatusIcon = m_StatusIconTriggerSkill[idx];
				else        tmpStatusIcon = m_PetStatusIconTriggerSkill[idx];
			}
			//일반 버프 
			else 
			{				
				if ( isPC ) tmpStatusIcon = m_StatusIconBuff[idx];
				else        tmpStatusIcon = m_PetStatusIconBuff[idx];
			} 	
			
			//삭제 부분
			deleteBuff ( tmpStatusIcon, info.Level, info.ID.ClassID, info.SpellerID ); 

			//추가 부분			
			if ( tmpStatusIcon.GetRowCount() == 0 || tmpStatusIcon.GetColCount( tmpStatusIcon.GetRowCount() -1 ) % NSTATUSICON_MAXCOL == 0 )
			{				
				tmpStatusIcon.AddRow();
			}
			tmpStatusIcon.AddCol( tmpStatusIcon.GetRowCount() -1 , info);
		}
	}
	UpdateBuff();
}

//버프아이콘 표시
function HandleShowBuffIcon(string param)
{
	local int nShow;
	ParseInt(param, "Show", nShow);
	
	m_CurBf = m_CurBf + 1;
	
	
	if (m_CurBf > MAX_BUFF_ICONTYPE)
	{
		m_CurBf = 0;
	}
	
	SetINIInt ( "PartyWndArena", "a", m_CurBf, "WindowsInfo.ini");	

	SetBuffButtonTooltip();
	UpdateBuff();
	//~ switch (m_CurBf)
	//~ {
		//~ case 1:
		//~ UpdateBuff();
		//~ break;
		//~ case 2:
		//~ UpdateBuff();
		//~ break;
		//~ case 0:
		//~ m_CurBf = 0;
		//~ UpdateBuff();
	//~ }
}

// 버튼클릭 이벤트
function OnClickButton( string strID )
{
	local int idx;
	local PartyWndCompact script;
	script = PartyWndCompact( GetScript("PartyWndCompact") );
	
	switch( strID )
	{
	case "btnBuff":		//버프버튼 클릭시 
		OnBuffButton();
		//script.OnBuffButton();
		break;
	case "btnCompact":	// 옵션 버튼 클릭시
		OnOpenPartyWndOption();
		//OnCompactButton();
		break;	
	case "btnSummon":	// 소환수 버튼 클릭시
		//debug("ERROR - you can't enter here");	// 여기로 들어오면 에러 -_-;
		break;
	}

	if( inStr( strID , "btnSummon") > -1 )
	{
		idx = int( Right(strID , 1));
		// Debug("idx===> " @idx);
		if(m_PetPartyStatus[idx].isShowwindow())
		{
			// Debug(" 소환수 창을 닫아라! ");
			m_PetPartyStatus[idx].HideWindow();

			m_arrPetIDOpen[idx] = 2;
		}
		else
		{
			m_PetPartyStatus[idx].ShowWindow();
			m_arrPetIDOpen[idx] = 1;
		}
		ResizeWnd();
	}
}

// 옵션버튼 클릭시 불리는 함수
function OnOpenPartyWndOption()
{
	local int i;
	local PartyWndOption script;
	script = PartyWndOption( GetScript("PartyWndOption") );
	
	// 열려있는 소환수 창 정보를 옵션 윈도우 , 작은 윈도우로 전달한다. 
	for(i=0; i<MAX_ArrayNum; i++)
	{
		script.m_arrPetIDOpen[i] = m_arrPetIDOpen[i];
	}
	
	script.ShowPartyWndOption();
	m_PartyOption.SetAnchor("PartyWndArena.PartyStatusWnd0", "TopRight", "TopLeft", 5, 5);
	
	
}

// 사용되지 않는 함수인듯.  PartyWnd, PartyWndCompact, PartyWndOption 에서 사용하지 않음

//		function OnCompactButton()
//		{
//			local int idx;
//			local int Size;
//			
//			if (m_bCompact)
//			{
//				Size = 16;
//			}
//			else
//			{
//				Size = 10;
//			}
//			m_bCompact = !m_bCompact;
//			
//			for (idx=0; idx<MAX_ArrayNum; idx++)
//			{
//				m_StatusIconBuff[idx].SetIconSize(Size);	
//				m_StatusIconDeBuff[idx].SetIconSize(Size);	
//			}
//		}

// 버프버튼을 눌렀을 경우 실행되는 함수
function OnBuffButton()
{
	m_CurBf = m_CurBf + 1;
	
	//3가지 모드가 전환된다.
	if (m_CurBf > MAX_BUFF_ICONTYPE)
	{
		m_CurBf = 0;
	}

	SetINIInt ( "PartyWndArena", "a", m_CurBf, "WindowsInfo.ini");	
	
	SetBuffButtonTooltip();
	UpdateBuff();
}

// 버프표시, 디버프 표시,  끄기 3가지모드를 전환한다.
function UpdateBuff()
{
	local int idx;
	if (m_CurBf == 1)
	{
		for (idx=0; idx<MAX_ArrayNum; idx++)
		{
			m_StatusIconBuff[idx].ShowWindow();	
			m_PetStatusIconBuff[idx].ShowWindow();
			m_StatusIconDeBuff[idx].HideWindow();	
			m_PetStatusIconDeBuff[idx].HideWindow();
			m_StatusIconSongDance[idx].HideWindow();	
			m_PetStatusIconSongDance[idx].HideWindow();
			m_StatusIconTriggerSkill[idx].HideWindow();	
			m_PetStatusIconTriggerSkill[idx].HideWindow();
		}
	}
	else if (m_CurBf == 2)
	{
		for (idx=0; idx<MAX_ArrayNum; idx++)
		{
			m_StatusIconBuff[idx].HideWindow();	
			m_PetStatusIconBuff[idx].HideWindow();
			m_StatusIconDeBuff[idx].ShowWindow();	
			m_PetStatusIconDeBuff[idx].ShowWindow();
			m_StatusIconSongDance[idx].HideWindow();	
			m_PetStatusIconSongDance[idx].HideWindow();
			m_StatusIconTriggerSkill[idx].HideWindow();	
			m_PetStatusIconTriggerSkill[idx].HideWindow();			
		}
	}
	else if (m_CurBf == 3)
	{
		for (idx=0; idx<MAX_ArrayNum; idx++)
		{
			m_StatusIconBuff[idx].HideWindow();	
			m_PetStatusIconBuff[idx].HideWindow();
			m_StatusIconDeBuff[idx].HideWindow();	
			m_PetStatusIconDeBuff[idx].HideWindow();
			m_StatusIconSongDance[idx].ShowWindow();	
			m_PetStatusIconSongDance[idx].ShowWindow();
			m_StatusIconTriggerSkill[idx].HideWindow();	
			m_PetStatusIconTriggerSkill[idx].HideWindow();			
		}
	}
	else if (m_CurBf == 4)
	{
		for (idx=0; idx<MAX_ArrayNum; idx++)
		{
			m_StatusIconBuff[idx].HideWindow();	
			m_PetStatusIconBuff[idx].HideWindow();
			m_StatusIconDeBuff[idx].HideWindow();	
			m_PetStatusIconDeBuff[idx].HideWindow();
			m_StatusIconSongDance[idx].HideWindow();	
			m_PetStatusIconSongDance[idx].HideWindow();
			m_StatusIconTriggerSkill[idx].ShowWindow();	
			m_PetStatusIconTriggerSkill[idx].ShowWindow();			
		}
	}
	else
	{
		for (idx=0; idx<MAX_ArrayNum; idx++)
		{
			m_StatusIconBuff[idx].HideWindow();
			m_PetStatusIconBuff[idx].HideWindow();
			m_StatusIconDeBuff[idx].HideWindow();	
			m_PetStatusIconDeBuff[idx].HideWindow();
			m_StatusIconSongDance[idx].HideWindow();	
			m_PetStatusIconSongDance[idx].HideWindow();
			m_StatusIconTriggerSkill[idx].HideWindow();	
			m_PetStatusIconTriggerSkill[idx].HideWindow();			
		}
	}
	//m_bBuff = bShow;
}

//CP바 갱신
function UpdateCPBar(int idx, int Value, int MaxValue)
{
	m_BarCP[idx].SetValue(MaxValue, Value);
}

//HP바 갱신
function UpdateHPBar(int idx, int Value, int MaxValue)
{
	if(idx < 100)
		m_BarHP[idx].SetValue(MaxValue, Value);
	else
		m_PetBarHP[idx - 100].SetValue(MaxValue, Value);
}

//MP바 갱신
function UpdateMPBar(int idx, int Value, int MaxValue)
{
	if(idx < 100)
		m_BarMP[idx].SetValue(MaxValue, Value);
	else 	// 100보다 크면 펫이 보낸거라는..
		m_PetBarMP[idx - 100].SetValue(MaxValue, Value);
}

//파티원 클릭 했을시..
function OnLButtonDown( WindowHandle a_WindowHandle, int X, int Y )
{
	local Rect rectWnd, rectPetClassIcon;
	local UserInfo userinfo;
	local int idx;
	//자동 대타 버튼일 경우 예외 처리용으로 사용.
	//local Rect rectAutoPart;		

	rectWnd = m_wndTop.GetRect();	

	if (X > rectWnd.nX + 13 && X < rectWnd.nX + rectWnd.nWidth -10)
	{
		if (GetPlayerInfo(userinfo))
		{
			//idx = (Y-rectWnd.nY) / NPARTYSTATUS_HEIGHT;	//펫보여주기 개편 전의 코드
			idx = GetIdx( Y-rectWnd.nY );
			//debug("OnLButtonDown : " $ idx);			
			//rectAutoPart = m_AutoPartyMatchingBtn[idx].GetRect();	
/*
			//자동 대타 버튼일 경우 타겟 잡지 않음.
			if( X > rectAutoPart.nX && X < rectAutoPart.nX + rectAutoPart.nWidth )
			{
				if( Y > rectAutoPart.nY && Y <  ( rectAutoPart.nY + rectAutoPart.nHeight ) )
				{					
					return;
				}
			}*/

			rectWnd = m_PetPartyStatus[idx].GetRect();
			rectPetClassIcon = m_PetClassIcon[idx].GetRect();

			if (IsPKMode())
			{
				if(idx <100)
					RequestAttack(m_arrID[idx], userinfo.Loc);
				else
				{
					
										
					if (X > rectPetClassIcon.nX && X < rectWnd.nX + rectWnd.nWidth -10)
					{
						RequestAttack(m_arrPetID[idx-100], userinfo.Loc);
					}
				}
			}
			else
			{
				if(idx < 100)
					RequestAction(m_arrID[idx], userinfo.Loc);
				else
				{
					if (X > rectPetClassIcon.nX && X < rectWnd.nX + rectWnd.nWidth -10)
					{
						RequestAction(m_arrPetID[idx-100], userinfo.Loc);
					}
				}
			}
		}
	}
}

//파티원의 어시스트
function OnRButtonDown( WindowHandle a_WindowHandle, int X, int Y )
{
	local Rect rectWnd;
	local UserInfo userinfo;
	local int idx;
		
	rectWnd = m_wndTop.GetRect();
	if (X > rectWnd.nX + 13 && X < rectWnd.nX + rectWnd.nWidth -10)
	{
		if (GetPlayerInfo(userinfo))
		{
			//idx = (Y-rectWnd.nY) / NPARTYSTATUS_HEIGHT;	//펫보여주기 개편 전의 코드
			idx = GetIdx( Y-rectWnd.nY );
			//debug("OnRButtonUp : " $ idx);
			if(idx <100)
				RequestAssist(m_arrID[idx], userinfo.Loc);
			else
				RequestAssist(m_arrPetID[idx-100], userinfo.Loc);
		}
	}
}

// Y 좌표를 이용해 배열의 인덱스 값을 구한다. 펫의 경우에는 + 100을 하여 리턴해준다. 
function int GetIdx(int y)
{
	local int tempY;	// 이변수는 배열을 위에서부터 훑고 내려가면서 누적 감소시킨다. 
	local int i;
	local int idx;
	
	idx = -1;
	tempY = y;
	
	for(i=0 ; i<MAX_ArrayNum ; i++)
	{
		tempY = tempY - NPARTYSTATUS_HEIGHT;
		
		if(tempY <0)	// 0보다 작으면 해당 i가 IDX가 된다. 
		{
			idx = i;	//필요할까 싶지만, 안전장치 차원에서..
			return idx;
		}
		else if( m_arrPetIDOpen[i] == 1) // 해당 인덱스의 펫이 열려있다면
		{
			tempY = tempY - NPARTYPETSTATUS_HEIGHT;			
			if(tempY <0)	// 0보다 작으면 해당 i가 IDX가 된다. 
			{
				idx = i + 100;	//펫일 경우 100을 더하여 보내준다. 
				return idx;
			}
		}		
	}
	
	return idx;
}

// 버프 툴팁을 설정한다.
function SetBuffButtonTooltip()
{
	local int idx;
	switch (m_CurBf)
	{
		case 0:	idx = 1496;
		break;
		case 1:	idx = 1497;
		break;
		case 2:	idx = 1741;
		break;
		case 3:	idx = 2307;
		break;
		case 4: idx = 1498;
		break;
	}
	btnBuff.SetTooltipCustomType(MakeTooltipSimpleText(GetSystemString(idx)));
}

function OnDropWnd( WindowHandle hTarget, WindowHandle hDropWnd, int x, int y )
{
	local string sTargetName, sDropName ,sTargetParent;
	local int dropIdx, targetIdx, i;
	
	//local  PartyWnd script1;			// 확장된 파티창의 클래스
	local PartyWndCompact script2;	// 축소된 파티창의 클래스
	
	//script1 = PartyWnd( GetScript("PartyWndArena") );
	script2 = PartyWndCompact( GetScript("PartyWndCompact") );
	
	dropIdx = -1;
	targetIdx = -1;
	
	if( hTarget == None || hDropWnd == None )
		return;
	
	sTargetName = hTarget.GetWindowName();
	sDropName = hDropWnd.GetWindowName();
	sTargetParent = hTarget.GetParentWindowName();
	
	// PartyStatusWnd에만 드래그 엔 드롭을 할 수 있다. 
	//if(( InStr( "PartyStatusWnd", sTargetName ) == -1 ) || ( InStr( "PartyStatusWnd" ,sDropName) == -1 ))
	if( (( InStr( sTargetName , "PartyStatusWnd" ) == -1 ) && ( InStr( sTargetParent , "PartyStatusWnd" ) == -1 )   ) || ( InStr( sDropName, "PartyStatusWnd") == -1 ))
	{
		//Debug( "sTargetName: " $ sTargetName );
		//Debug( "sTargetName: " $ sDropName );
		return;
	}
	else
	{
		dropIdx = int(Right(sDropName , 1));
		
		if( InStr( sTargetName , "PartyStatusWnd" ) > -1 ) 	//타겟 네임이 있을 겨우
			targetIdx = int(Right(sTargetName , 1));
		else									//타겟 네임은 없지만 부모의 이름이 PartyStatusWnd 일때
			targetIdx = int(Right(sTargetParent , 1));
		
		if( dropIdx <0 || targetIdx <0 )
		{
			//Debug( "ERROR IDX: " $ dropIdx $ " / " $  targetIdx);
		}
		
		// 아래 혹은 위로 밀어주는 코드
		if( dropIdx > targetIdx)
		{
			CopyStatus ( MAX_PartyMemberCount , dropIdx );		//타겟을 옮겨놓고
			script2.CopyStatus ( MAX_PartyMemberCount , dropIdx );		//타겟을 옮겨놓고
			
			for (i=dropIdx-1; i>targetIdx-1; i--)	// 아래로 밀어준다. 
			{
				CopyStatus(i+1, i);
				script2.CopyStatus(i+1, i);
			}
			CopyStatus ( targetIdx , MAX_PartyMemberCount  );
			script2.CopyStatus ( targetIdx , MAX_PartyMemberCount  );
		}
		else if(dropIdx < targetIdx)
		{
			CopyStatus ( MAX_PartyMemberCount, dropIdx );		//타겟을 옮겨놓고
			script2.CopyStatus ( MAX_PartyMemberCount , dropIdx );		//타겟을 옮겨놓고
			
			for (i=dropIdx+1; i<targetIdx+1; i++)	// 위로 땡겨준다.
			{
				CopyStatus(i-1, i);
				script2.CopyStatus(i-1, i);
			}
			CopyStatus ( targetIdx , MAX_PartyMemberCount );
			script2.CopyStatus ( targetIdx , MAX_PartyMemberCount );
		}

		ClearStatus(MAX_PartyMemberCount);
		ClearPetStatus(MAX_PartyMemberCount);
		
		//Update Client Data
		class'UIDATA_PARTY'.static.MovePartyMember( dropIdx, targetIdx );
		
		ResizeWnd();
	}
}

function int GetVNameIndexByID( int ID )
{
	local int i;
	for (i=0; i<MAX_ArrayNum; i++)
	{
		if( m_Vname[i].ID == ID )
			return i;
	}
	return -1;
}

function ResetVName()
{
	local int i;
	
	for (i=0; i<MAX_ArrayNum; i++)
	{
		m_Vname[i].ID = i;
		m_Vname[i].UseVName = 0;
		m_Vname[i].DominionIDForVName = 0;
		m_Vname[i].VName = "";
		m_Vname[i].SummonVName = "";
	}
}


function HandleRegistPartySubstitute( string param )
{
	local int iOK;
	local int iUserID;

	ParseInt( param, "OK", iOK );
	ParseInt( param, "UserID", iUserID );

	//debug( "HandleRegistPartySubstitute OK>>>" $string(iOK) );
	//debug( "HandleRegistPartySubstitute UserID>>>" $string(iUserID) );
}

function HandleDeletePartySubstitute( string param )
{
	local int iOK;
	local int iUserID;

	ParseInt( param, "OK", iOK );
	ParseInt( param, "UserID", iUserID );

	//debug( "HandleDeletePartySubstitute OK>>>" $string(iOK) );
	//debug( "HandleDeletePartySubstitute UserID>>>" $string(iUserID) );
}
defaultproperties
{
}
