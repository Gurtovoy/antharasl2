/******************************************************************************
//                                             축소된 파티창 UI 관련 스크립트                                                                    //
******************************************************************************/
class PartyWndCompact extends UICommonAPI;
	
struct VnameData
{
	var int ID;
	var int UseVName;
	var int DominionIDForVName;
	var string VName;
	var string SummonVName;
};


// 상수 설정.
const NSTATUSICON_MAXCOL = 12;		//status icon의 최대 가로.
const NPARTYSTATUS_HEIGHT = 26;		//status 상태창의 세로길이.	// 확장창은 46
const NPARTYPETSTATUS_HEIGHT = 18;		//status 상태창의 세로길이.	// 확장창은 32
const FIRSTWND_ADD_HEIGHT = 4;		//첫번째창을 추가적으로 늘려줄 높이

const MAX_ArrayNum = 10; // MAX_ArrayNum = MAX_PartyMemberCount + 1 -> 임시 저장을 추가한 수

var bool	m_bCompact;
var bool	m_bBuff;
var bool	m_partyleader;
var int 	m_arrID[MAX_ArrayNum];	// 인덱스에 해당하는 파티원의 서버 ID.
var int 	m_arrPetID[MAX_ArrayNum];	// 인덱스에 해당하는 파티원의 펫의서버 ID.
var int		m_arrSummonID[MAX_ArrayNum];	// 인덱스에 해당하는 파티원의 수환 주인 ID -> CT3 추가
var int	    m_arrPetIDOpen[MAX_ArrayNum];	// 인덱스에 해당하는 파티원의 펫의 창이 열려있는지 확인. 1이면 오픈, 2이면 닫힘. -1이면 없음
var int	    m_CurCount;
var int 	m_CurBf;
var int     m_MasterID;

var VnameData m_Vname[MAX_ArrayNum];

//Handle	선언
var WindowHandle	m_wndTop;			// 현재 윈도우
var WindowHandle	m_PartyOption;		// 옵션 윈도우
var WindowHandle	m_PartyStatus[MAX_ArrayNum];	// 캐릭터별 윈도우 (캐릭터 수만큼 생성해준다)
//var NameCtrlHandle		m_PlayerName[MAX_ArrayNum];
var TextureHandle	m_ClassIcon[MAX_ArrayNum];		//클래스 아이콘 텍스쳐.
var StatusIconHandle	m_StatusIconBuff[MAX_ArrayNum];	//버프아이콘 핸들
var StatusIconHandle	m_StatusIconDeBuff[MAX_ArrayNum];	//디버프아이콘 핸들
var BarHandle		m_BarCP[MAX_ArrayNum];
var BarHandle		m_BarHP[MAX_ArrayNum];
var BarHandle		m_BarMP[MAX_ArrayNum];
var ButtonHandle	btnBuff;

var ButtonHandle			m_petButton[MAX_ArrayNum];
var ButtonHandle			m_petButtonTrash[MAX_ArrayNum];

var WindowHandle		m_PetPartyStatus[MAX_ArrayNum];
//var NameCtrlHandle		m_PetName[MAX_ArrayNum];
var StatusIconHandle		m_PetStatusIconBuff[MAX_ArrayNum];
var StatusIconHandle		m_PetStatusIconDeBuff[MAX_ArrayNum];
var TextureHandle		m_PetClassIcon[MAX_ArrayNum];
var BarHandle			m_PetBarHP[MAX_ArrayNum];
var BarHandle			m_PetBarMP[MAX_ArrayNum];

// ct3 다중 소환 - 추가 
var TextureHandle m_ClassIconSummon[MAX_ArrayNum];
var TextureHandle m_ClassIconSummonNum[MAX_ArrayNum];

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
	
	RegisterEvent( EV_PetStatusSpelledList );		// 펫 버프가 날라오는 이벤트
	//RegisterEvent( EV_SummonedStatusSpelledList );	// 소환수  버프가 날라오는 이벤트
	
	RegisterEvent( EV_Restart );	
	//RegisterEvent( EV_TargetUpdate );	// 타겟 업데이트 이벤트

	RegisterEvent( EV_PartySpelledListDelete ); //1182
	RegisterEvent( EV_PartySpelledListInsert ); //1183
	RegisterEvent( EV_PetStatusSpelledListDelete ); //1052	
	RegisterEvent( EV_PetStatusSpelledListInsert ); //1053

	RegisterEvent( EV_NeedResetUIData ); //8000
	
}

// 윈도우가 생성될때 불리는 함수.
function OnLoad()
{
	local int idx;

	InitHandleCOD();

	m_bCompact = false;
	m_bBuff = false;	
	m_CurBf = 0;
	m_MasterID = 0;
	
	//Reset Anchor	// 버프와 디버프는 PartyWndCompact의 anchor point를 참조한다.
	for (idx=0; idx<MAX_ArrayNum; idx++)
	{
		m_StatusIconBuff[idx].SetAnchor("PartyWndCompact.PartyStatusWnd" $ idx, "TopRight", "TopLeft", 1, 3);
		m_StatusIconDeBuff[idx].SetAnchor("PartyWndCompact.PartyStatusWnd" $ idx, "TopRight", "TopLeft", 1, 3);
		m_PetStatusIconBuff[idx].SetAnchor("PartyWndCompact.PartyStatusSummonWnd" $ idx, "TopRight", "TopLeft", 1, 3);
		m_PetStatusIconDeBuff[idx].SetAnchor("PartyWndCompact.PartyStatusSummonWnd" $ idx, "TopRight", "TopLeft", 1, 3);
	}
	
	//Set ClassIcon0 Position
	m_ClassIcon[0].Move(0, 7);
	
	
	m_PartyOption.HideWindow();
	
	//Init VirtualDrag
	for (idx=0; idx<MAX_ArrayNum; idx++)
	{
		//m_PartyStatus[idx].SetVirtualDrag( true );
		m_PartyStatus[idx].SetDragOverTexture( "L2UI_CT1.ListCtrl.ListCtrl_DF_HighLight" );
	}
	ResetVName();
}


function OnHide()
{
	ResetVName();
}


function checkClassicForm() 
{
	local int idx;	

	for (idx=0; idx<MAX_ArrayNum; idx++)
	{	
		if ( getInstanceUIData().getisClassicServer()  ) 
		{			
			m_ClassIconSummonNum[idx].HideWindow();
		}
		else 
		{		
			m_ClassIconSummonNum[idx].ShowWindow();
		}
	}
}

// 특화 서버일 경우 서머너 개수가 보이지 않도록
function setHideClassIconSummonNum( int idx ) 
{
	if (  getInstanceUIData().getisClassicServer()  ) 	
		m_ClassIconSummonNum[idx].HideWindow();
	else 	
		m_ClassIconSummonNum[idx].ShowWindow();
}

function InitHandleCOD()
{
	local int idx;
	local Rect rectWnd;
	
	//Init Handle
	m_wndTop = GetWindowHandle( "PartyWndCompact" );
	m_PartyOption = GetWindowHandle("PartyWndOption");		// 옵션창의 핸들 초기화.
	for (idx=0; idx<MAX_ArrayNum; idx++)		// 최대파티원 수 만큼 각 데이터를 초기화해줌. ->  임시 데이터 용 한명을 더해 줍니다.
	{
		m_PartyStatus[idx] = GetWindowHandle( "PartyWndCompact.PartyStatusWnd" $ idx );
		m_ClassIcon[idx] = GetTextureHandle( "PartyWndCompact.PartyStatusWnd" $ idx $ ".ClassIcon" );
		m_StatusIconBuff[idx] = GetStatusIconHandle( "PartyWndCompact.PartyStatusWnd" $ idx $ ".StatusIconBuff" );
		m_StatusIconDeBuff[idx] = GetStatusIconHandle( "PartyWndCompact.PartyStatusWnd" $ idx $ ".StatusIconDebuff" );
		m_BarCP[idx] = GetBarHandle( "PartyWndCompact.PartyStatusWnd" $ idx $ ".barCP" );
		m_BarHP[idx] = GetBarHandle( "PartyWndCompact.PartyStatusWnd" $ idx $ ".barHP" );
		m_BarMP[idx] = GetBarHandle( "PartyWndCompact.PartyStatusWnd" $ idx $ ".barMP" );
		
		m_petButton[idx] = GetButtonHandle( "PartyWndCompact.btnSummon" $ idx);	
		m_petButton[idx].HideWindow();
		
		m_PetPartyStatus[idx] = GetWindowHandle( "PartyWndCompact.PartyStatusSummonWnd" $ idx );

		m_PetClassIcon[idx] = GetTextureHandle( "PartyWndCompact.PartyStatusSummonWnd" $ idx $ ".ClassIcon" );
		m_PetStatusIconBuff[idx] = GetStatusIconHandle( "PartyWndCompact.PartyStatusSummonWnd" $ idx $ ".StatusIconBuff" );
		m_PetStatusIconDeBuff[idx] = GetStatusIconHandle( "PartyWndCompact.PartyStatusSummonWnd" $ idx $ ".StatusIconDebuff" );
		m_PetBarHP[idx] = GetBarHandle( "PartyWndCompact.PartyStatusSummonWnd" $ idx $ ".barHP" );
		m_PetBarMP[idx] = GetBarHandle( "PartyWndCompact.PartyStatusSummonWnd" $ idx $ ".barMP" );		
				
		m_arrPetIDOpen[idx] = -1;
		m_arrSummonID[idx] = -1;
		m_arrID[idx] = 0;

		// ct 에 변경된 팻 클래스 아이콘
		m_PetClassIcon[idx] = GetTextureHandle( "PartyWndCompact.PartyStatusSummonWnd" $ idx $ ".ClassIconPet" );

		// ct3 에 추가된 팻, 소환수 텍스쳐 (소환수 아이콘, 소환수 수, 팻 아이콘)
		m_ClassIconSummon[idx]    =  GetTextureHandle( "PartyWndCompact.PartyStatusSummonWnd" $ idx $ ".ClassIconSummon" );
		m_ClassIconSummonNum[idx] =  GetTextureHandle( "PartyWndCompact.PartyStatusSummonWnd" $ idx $ ".ClassIconSummonNum" );

		
		if(idx == 0) //첫번째 창은 레이아웃이 다르다. 
		{
			rectWnd = m_PartyStatus[idx].GetRect();
			m_PartyStatus[idx].SetWindowSize(rectWnd.nWidth, rectWnd.nHeight + FIRSTWND_ADD_HEIGHT);
			
			m_petButton[idx].SetAnchor("PartyWndCompact.PartyStatusWnd" $ idx, "TopLeft", "TopRight", 0, 15);			
		}
		else
			m_petButton[idx].SetAnchor("PartyWndCompact.PartyStatusWnd" $ idx, "TopLeft", "TopRight", 0, 2);
	}
	btnBuff = GetButtonHandle( "PartyWndCompact.btnBuff" );
}

function OnShow()
{
	local int i;
	local int tmpInt;
	
	GetINIInt ( "PartyWndCompact", "a", m_CurBf, "WindowsInfo.ini");
	SetBuffButtonTooltip();
	UpdateBuff();
	//SwapBigandSmall
	GetIniInt( "PartyWnd", "p", tmpInt, "WindowsInfo.ini");

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

	Debug ( "onShow partyWndCompact");
	ResizeOnlyWnd();
	//ResizeWnd();
	//SetBuffButtonTooltip();
}

function OnEnterState( name a_PreStateName )
{
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
	else if (Event_ID == EV_PartySpelledList || Event_ID == EV_PetStatusSpelledList )//|| Event_ID == EV_SummonedStatusSpelledList)	// 버프 혹은 디버프 처리.
	{
		HandlePartySpelledList(param);
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
		HandleRestart();
	}
	else if (Event_ID == EV_PartyRenameMember)
	{
		HandlePartyRenameMember(param);
	}

	else if ( Event_ID == EV_PartySpelledListDelete	||  Event_ID == EV_PetStatusSpelledListDelete)
	{	
		HandlePartySpelledListDelete(param);
//		Debug("onEvent" @ Event_ID @ param);
	}
	else if  ( Event_ID == EV_PartySpelledListInsert ||  Event_ID == EV_PetStatusSpelledListInsert )
	{
		HandlePartySpelledListInsert(param);		
//		Debug( "onEvent" @  Event_ID @ param );
	}
	else if ( Event_ID == EV_NeedResetUIData ) 
	{
		checkClassicForm();
	}
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
	}	
}


//리스타트를 하면 올클리어
function HandleRestart()
{
	Clear();
}


//초기화
function Clear()
{
	local int idx;
	for (idx=0; idx<MAX_ArrayNum ; idx++)
	{
		ClearStatus(idx);		// 모든 상태를 초기화해준다. 
		ClearPetStatus(idx);
		ClearSummonStatus(idx);

		m_arrSummonID[idx] = -1;
	}
	m_CurCount = 0;
	ResizeWnd();
}

//상태창의 초기화
function ClearStatus(int idx)
{
	m_StatusIconBuff[idx].Clear();
	m_StatusIconDeBuff[idx].Clear();
	//m_PlayerName[idx].SetName("", NCT_Normal,TA_Center);
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
	//m_PetName[idx].SetName("", NCT_Normal,TA_Center);
	// m_PetClassIcon[idx].SetTexture("");
	UpdateHPBar(idx + 100, 0, 0);
	UpdateMPBar(idx + 100, 0, 0);
	
	m_petButton[idx].HideWindow();
	
	m_arrPetID[idx] = -1;
	m_arrPetIDOpen[idx] = -1;
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
	local int		MaxValue;
	local int		CurValue;
	
	local int		Row;
	local int		Col;
	local int		MaxRow;
	local int		MaxCol;
	
	local StatusIconInfo info;
	
	//Custom Tooltip
	local CustomTooltip TooltipInfo;
	local CustomTooltip TooltipInfo2;
	local string summonToolTipStr1, summonToolTipStr2;
	local string summonTextureName;
	
	//ServerID
	m_arrID[DesIndex] = m_arrID[SrcIndex];
	
	//Name
	//m_PlayerName[DesIndex].SetName(m_PlayerName[SrcIndex].GetName(), NCT_Normal,TA_Center);
	
	//Window Tooltip
	m_PartyStatus[SrcIndex].GetTooltipCustomType(TooltipInfo);
	m_PartyStatus[DesIndex].SetTooltipCustomType(TooltipInfo);
	
	//Class Texture
	m_ClassIcon[DesIndex].SetTexture(m_ClassIcon[SrcIndex].GetTextureName());
	//Class Tooltip
	m_ClassIcon[SrcIndex].GetTooltipCustomType(TooltipInfo2);
	m_ClassIcon[DesIndex].SetTooltipCustomType(TooltipInfo2);

	//CP,HP,MP
	m_BarCP[SrcIndex].GetValue(MaxValue, CurValue);
	m_BarCP[DesIndex].SetValue(MaxValue, CurValue);
	m_BarHP[SrcIndex].GetValue(MaxValue, CurValue);
	m_BarHP[DesIndex].SetValue(MaxValue, CurValue);
	m_BarMP[SrcIndex].GetValue(MaxValue, CurValue);
	m_BarMP[DesIndex].SetValue(MaxValue, CurValue);
	
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
			m_StatusIconDeBuff[DesIndex].AddCol(Row, info);
		}
	}
	
	// -------------------------------------------펫도 옮겨준다. 
	//ServerID
	m_arrPetID[DesIndex] = m_arrPetID[SrcIndex];
	m_arrSummonID[DesIndex] = m_arrSummonID[SrcIndex];
	
	m_arrPetID[DesIndex] = m_arrPetID[SrcIndex];	
	m_arrPetIDOpen[DesIndex] = m_arrPetIDOpen[SrcIndex];;	
	
	// 소환수 교체
	summonTextureName = m_ClassIconSummon[DesIndex].GetTextureName();
	m_ClassIconSummon[DesIndex].SetTexture(m_ClassIconSummon[SrcIndex].GetTextureName());
	m_ClassIconSummon[SrcIndex].SetTexture(summonTextureName);

	// 툴팁
	summonToolTipStr1 = m_ClassIconSummon[SrcIndex].GetTooltipText();	
	summonToolTipStr2 = m_ClassIconSummon[DesIndex].GetTooltipText();	
		
	m_ClassIconSummon[SrcIndex].SetTooltipText(summonToolTipStr2);
	m_ClassIconSummon[DesIndex].SetTooltipText(summonToolTipStr1);
	
	//Name
	//m_PetName[DesIndex].SetName(m_PetName[SrcIndex].GetName(), NCT_Normal,TA_Center);

	
	//Class Texture
	m_PetClassIcon[DesIndex].SetTexture(m_PetClassIcon[SrcIndex].GetTextureName());
	//Class Tooltip
	m_PetClassIcon[SrcIndex].GetTooltipCustomType(TooltipInfo);
	m_PetClassIcon[DesIndex].SetTooltipCustomType(TooltipInfo);
	
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
			m_PetStatusIconDeBuff[DesIndex].AddCol(Row, info);
		}
	}
}


//윈도우의 사이즈 조정
function ResizeOnlyWnd()
{
	local int idx;
	local Rect rectWnd;
	local bool bOption;
	local int i;
	local int OpenPetCount;
	local  PartyMemberInfo partyMemberInfo;

	local int tmpInt;

	// SetOptionBool과 페어. 이 변수는 PartyWndOption 에서 변경됨
	GetINIInt( "PartyWnd", "e", tmpInt, "Windowsinfo.ini"  ) ;
	bOption = bool ( tmpInt ) ;//GetOptionBool( "Game", "SmallPartyWnd" );
	
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
						m_PartyStatus[idx].SetAnchor("PartyWndCompact.PartyStatusSummonWnd" $ idx-1, "BottomLeft", "TopLeft", 0, -4);	// 펫 윈도우 밑으로 앵커
					}
					else// 앞 파티원의 소환수가 닫혀있거나 소환수가 없으면
					{
						m_PartyStatus[idx].SetAnchor("PartyWndCompact.PartyStatusWnd" $ idx-1, "BottomLeft", "TopLeft", 0, -4);	// 파티원 밑으로 앵커
					}
				}
				if(m_arrID[idx]!= 0 )
				{
					if (m_arrPetIDOpen[idx] > -1)  m_petButton[idx].showWindow();
					else	m_petButton[idx].HideWindow();
					m_PartyStatus[idx].SetVirtualDrag( true );
					m_PartyStatus[idx].ShowWindow();
				}
				if(m_arrPetIDOpen[idx] == 1) m_PetPartyStatus[idx].ShowWindow();

				
				// 소환수 정보
				GetPartyMemberInfo(m_arrID[idx], partyMemberInfo);

				// Debug("RESIZE ---> partyMemberInfo.curSummonNum : "  @ partyMemberInfo.curSummonNum);
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
					m_petButton[idx].ShowWindow();
					// Debug("m_arrPetIDOpen[i] " @ m_arrPetIDOpen[idx]);
					//  Debug("-보조창을 연다 " @ idx @ "  - > "  @ partyMemberInfo.curSummonNum);
				}
				else
				{
					// 팻, 소환수 하나도 없다면.. 보조창 닫기 					
					m_petButton[idx].HideWindow();
					m_PetPartyStatus[idx].HideWindow();					
					m_arrPetIDOpen[idx] = -1;

				}
				// 소환수가 한마리 라도 있다면..
				if (partyMemberInfo.curSummonNum > 0)
				{
					m_ClassIconSummon[idx].ShowWindow();
					//m_ClassIconSummonNum[idx].ShowWindow();
					setHideClassIconSummonNum(idx);
					m_ClassIconSummonNum[idx].SetTexture("L2UI_ch3.PARTYWND.party_summmon_num" $ String(partyMemberInfo.curSummonNum));
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
				m_petButton[idx].HideWindow();
				m_PartyStatus[idx].SetVirtualDrag( false );
				m_PartyStatus[idx].HideWindow();
				m_PetPartyStatus[idx].HideWindow();
			}
		}

		OpenPetCount=0;
		for(i=0; i<MAX_ArrayNum ; i++)
		{
			if(m_arrPetIDOpen[i] == 1) OpenPetCount++;
			else 	// 열려있는 상태가 아닌데..
			{
				 if(m_PetPartyStatus[i].IsShowWindow()) m_PetPartyStatus[i].HideWindow();
			}
		}		
		
		//윈도우 사이즈 변경
		rectWnd = m_wndTop.GetRect();
		
		m_wndTop.SetWindowSize(rectWnd.nWidth, NPARTYSTATUS_HEIGHT*m_CurCount  + OpenPetCount * NPARTYPETSTATUS_HEIGHT + FIRSTWND_ADD_HEIGHT);
		// 펫창이 열려진 만큼 윈도우 사이즈에서 더해준다. 
		m_wndTop.SetResizeFrameSize(10, NPARTYSTATUS_HEIGHT*m_CurCount  + OpenPetCount * NPARTYPETSTATUS_HEIGHT + FIRSTWND_ADD_HEIGHT);		
	}
	else	// 파티원이 존재하지 않으면 이 윈도우는 보이지 않는다.
	{
		m_wndTop.HideWindow();
		m_PetPartyStatus[idx].HideWindow();
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
	GetINIInt( "PartyWnd", "e", tmpInt, "Windowsinfo.ini"  ) ;
	bOption = bool ( tmpInt ) ;//GetOptionBool( "Game", "SmallPartyWnd" );
	
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
						m_PartyStatus[idx].SetAnchor("PartyWndCompact.PartyStatusSummonWnd" $ idx-1, "BottomLeft", "TopLeft", 0, -4);	// 펫 윈도우 밑으로 앵커
					}
					else// 앞 파티원의 소환수가 닫혀있거나 소환수가 없으면
					{
						m_PartyStatus[idx].SetAnchor("PartyWndCompact.PartyStatusWnd" $ idx-1, "BottomLeft", "TopLeft", 0, -4);	// 파티원 밑으로 앵커
					}
				}
				if(m_arrID[idx]!= 0 )
				{
					if (m_arrPetIDOpen[idx] > -1)  m_petButton[idx].showWindow();
					else	m_petButton[idx].HideWindow();
					m_PartyStatus[idx].SetVirtualDrag( true );
					m_PartyStatus[idx].ShowWindow();
				}
				if(m_arrPetIDOpen[idx] == 1) m_PetPartyStatus[idx].ShowWindow();

				
				// 소환수 정보
				GetPartyMemberInfo(m_arrID[idx], partyMemberInfo);

				// Debug("RESIZE ---> partyMemberInfo.curSummonNum : "  @ partyMemberInfo.curSummonNum);
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
					m_petButton[idx].ShowWindow();
					// Debug("m_arrPetIDOpen[i] " @ m_arrPetIDOpen[idx]);
					//  Debug("-보조창을 연다 " @ idx @ "  - > "  @ partyMemberInfo.curSummonNum);
				}
				else
				{
					// 팻, 소환수 하나도 없다면.. 보조창 닫기 					
					m_petButton[idx].HideWindow();
					m_PetPartyStatus[idx].HideWindow();					
					m_arrPetIDOpen[idx] = -1;

				}
				// 소환수가 한마리 라도 있다면..
				if (partyMemberInfo.curSummonNum > 0)
				{
					m_ClassIconSummon[idx].ShowWindow();
					//m_ClassIconSummonNum[idx].ShowWindow();
					setHideClassIconSummonNum(idx);
					m_ClassIconSummonNum[idx].SetTexture("L2UI_ch3.PARTYWND.party_summmon_num" $ String(partyMemberInfo.curSummonNum));
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
				m_petButton[idx].HideWindow();
				m_PartyStatus[idx].SetVirtualDrag( false );
				m_PartyStatus[idx].HideWindow();
				m_PetPartyStatus[idx].HideWindow();
			}
		}

		OpenPetCount=0;
		for(i=0; i<MAX_ArrayNum ; i++)
		{
			if(m_arrPetIDOpen[i] == 1) OpenPetCount++;
			else 	// 열려있는 상태가 아닌데..
			{
				 if(m_PetPartyStatus[i].IsShowWindow()) m_PetPartyStatus[i].HideWindow();
			}
		}		
		
		//윈도우 사이즈 변경
		rectWnd = m_wndTop.GetRect();
		
		m_wndTop.SetWindowSize(rectWnd.nWidth, NPARTYSTATUS_HEIGHT*m_CurCount  + OpenPetCount * NPARTYPETSTATUS_HEIGHT + FIRSTWND_ADD_HEIGHT);
		// 펫창이 열려진 만큼 윈도우 사이즈에서 더해준다. 
		m_wndTop.SetResizeFrameSize(10, NPARTYSTATUS_HEIGHT*m_CurCount  + OpenPetCount * NPARTYPETSTATUS_HEIGHT + FIRSTWND_ADD_HEIGHT);
		if (bOption)	// 옵션창에 체크가 되어있으면 현재 (Compact) 윈도우를 활성화
			m_wndTop.ShowWindow();
		else
			m_wndTop.HideWindow();
	}
	else	// 파티원이 존재하지 않으면 이 윈도우는 보이지 않는다.
	{
		m_wndTop.HideWindow();
		m_PetPartyStatus[idx].HideWindow();
	}
}

//ID로 몇번째 표시되는 파티원인지 구한다
function int FindPartyID(int ID)
{
	local int idx;
	for (idx=0; idx<MAX_ArrayNum ; idx++)
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
	// local int SummonID;
	
	local int UseVName;
	local int DominionIDForVName;
	local int SummonCount;
	local string VName;
	local string SummonVName;


	// 파티 맴버 정보
	local PartyMemberInfo    partyMemberInfo;
	// 파티 맴버 팻 정보
	local PartyMemberPetInfo partyMemberPetInfo;

	local int index, i;

	local int summonType, summonMAXHP, summonMAXMP, summonHP, summonMP;
	local int summonClassID;
	
	//debug("파티원 추가" @ param);

	ParseInt(param, "ID", ID);	// ID를 파싱한다.
	// ParseInt(param, "SummonID", SummonID);
	ParseInt(Param, "UseVName",UseVName);
	ParseInt(Param, "DominionIDForVName", DominionIDForVName);
	ParseString(Param, "VName", VName);
	ParseString(Param, "SummonVName", SummonVName);	
	
	GetPartyMemberInfo(ID, partyMemberInfo);

	// 소환수 수를 얻는다.
	// ParseInt(Param, "SummonCount", summonCount);
	GetPartyMemberPetInfo(ID, partyMemberPetInfo);

	
	if (ID>0)
	{
		m_Vname[m_CurCount].ID = ID;
		m_Vname[m_CurCount].UseVName = UseVName;
		m_Vname[m_CurCount].DominionIDForVName = DominionIDForVName;
		m_Vname[m_CurCount].VName = VName;
		//		m_Vname[m_CurCount].SummonVName = SummonVName;
		ExecuteEvent( EV_TargetUpdate);
	
		m_CurCount++;	
		
		m_arrID[m_CurCount-1] = ID;
		UpdateStatus(m_CurCount-1, param);
		
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
					 m_ClassIconSummon[m_CurCount - 1].SetTooltipText(GetSystemString(505)); //getSummonSortString(class'UIDATA_NPC'.static.GetSummonSort(summonClassID)));
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
				// 팻이라면..
				if (summonType == 2)
				{
					ParseInt(param, "SummonMaxHP" $ i, SummonMaxHP);
					ParseInt(param, "SummonMaxMP" $ i, SummonMaxMP);
					ParseInt(param, "SummonHP"    $ i, SummonHP);
					ParseInt(param, "SummonMP"    $ i, SummonMP);
					ParseString(param, "SummonVName" $ i, SummonVName);

					// Debug("팻 업데이트 -> 추가 -> "@ SummonMaxHP);
					UpdateHPBar(index + 100, SummonHP, SummonMaxHP);
					UpdateMPBar(index + 100, SummonMP, SummonMaxMP);

					m_Vname[m_CurCount].SummonVName = SummonVName;
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
	
	ParseInt(param, "ID", ID);
	if (ID>0)
	{
		idx = FindPartyID(ID);
		if (idx>-1)
		{	
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
function UpdateStatus(int idx, string param)
{
	local string	Name;
	local int		ID;
	local int		CP;
	local int		MaxCP;
	local int		HP;
	local int		MaxHP;
	local int		MP;
	local int		MaxMP;
	local int		ClassID;
	local int		Vitality;
	local int		MasterID;
	local userinfo 	TargetUser;
	
	//Custom Tooltip
	local CustomTooltip TooltipInfo;
	local CustomTooltip TooltipInfo2;
	
	local int UseVName;
	local int DominionIDForVName;
	local string VName;
	local string SummonVName;
		
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
	ParseInt(param, "Vitality", Vitality);

		
	UseVName = m_Vname[idx].UseVName;
	DominionIDForVName = m_Vname[idx].DominionIDForVName;
	VName = m_Vname[idx].VName;
	SummonVName = m_Vname[idx].SummonVName;
	
	//업데이트일경우에는 파티장 정보가 안날라온다.
	if (ParseInt(param, "MasterID", MasterID))
		m_MasterID = MasterID;
	
	//Window Tooltip
	TooltipInfo.DrawList.length = 1;
	TooltipInfo.DrawList[0].eType = DIT_TEXT;
	TooltipInfo.DrawList[0].t_bDrawOneLine = true;
	if (m_MasterID >0 && m_MasterID==ID)
	{	
		if (TargetUser.WantHideName && TargetUser.RealName != "")
		{
			TooltipInfo.DrawList[0].t_strText =  TargetUser.Name $ "(" $ GetSystemString(408) $ ")";
		}
		else
		{
			TooltipInfo.DrawList[0].t_strText =  Name $ "(" $ GetSystemString(408) $ ")";
		}
	}
	else
	{
		if (UseVName == 1)
		{
			TooltipInfo.DrawList[0].t_strText = VName;
		}
		else
		{
			TooltipInfo.DrawList[0].t_strText = Name;
		}
	}
	m_PartyStatus[idx].SetTooltipCustomType(TooltipInfo);
	
	//직업 아이콘
	m_ClassIcon[idx].SetTexture(GetClassRoleIconName(ClassID));
	
	//Custom Tooltip
	TooltipInfo2.DrawList.length = 2;
	TooltipInfo2.DrawList[0].eType = DIT_TEXT;
	TooltipInfo2.DrawList[0].t_bDrawOneLine = true;
	if (m_MasterID >0 && m_MasterID==ID)
	{	
		if (TargetUser.WantHideName && TargetUser.RealName != "")
			TooltipInfo2.DrawList[0].t_strText =  TargetUser.Name $ "(" $ GetSystemString(408) $ ")";
		else
			TooltipInfo2.DrawList[0].t_strText =  Name $ "(" $ GetSystemString(408) $ ")";
	}
	else
	{
		if (TargetUser.WantHideName && TargetUser.RealName != "")
			TooltipInfo2.DrawList[0].t_strText = TargetUser.Name;
		else
			TooltipInfo2.DrawList[0].t_strText = Name;
	}
	
	TooltipInfo2.DrawList[1].eType = DIT_TEXT;
	TooltipInfo2.DrawList[1].nOffSetY = 2;
	TooltipInfo2.DrawList[1].t_bDrawOneLine = true;
	TooltipInfo2.DrawList[1].bLineBreak = true;
	
	TooltipInfo2.DrawList[1].t_strText = GetClassRoleName(ClassID) $ " - " $ GetClassType(ClassID);
	TooltipInfo2.DrawList[1].t_color.R = 128;
	TooltipInfo2.DrawList[1].t_color.G = 128;
	TooltipInfo2.DrawList[1].t_color.B = 128;
	TooltipInfo2.DrawList[1].t_color.A = 255;
	m_ClassIcon[idx].SetTooltipCustomType(TooltipInfo2);
	
	//각종 게이지
	UpdateCPBar(idx, CP, MaxCP);
	UpdateHPBar(idx, HP, MaxHP);
	UpdateMPBar(idx, MP, MaxMP);
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
				debug("HandlePartyPetAdd ERROR - Can't find master ID");
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
		 m_ClassIconSummon[idx].SetTooltipText(GetSystemString(505)); //getSummonSortString(class'UIDATA_NPC'.static.GetSummonSort(m_SummonInfo.nClassID)));
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
		for(i=0; i< MAX_ArrayNum; i++)
		{
			if(m_arrID[i] == MasterID)
			{
				MasterIndex = i;
				break;
			}
		}
		
		if(MasterIndex == -1)
		{
			debug("PartySummonProcess -> ERROR - Can't find master ID");
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
			setHideClassIconSummonNum(idx);
			//m_ClassIconSummonNum[idx].ShowWindow();
			m_ClassIconSummonNum[idx].SetTexture("L2UI_ch3.PARTYWND.party_summmon_num" $ String(partyMemberInfo.curSummonNum));
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
	
	local bool isPC;	//pc인지 펫인지 체크하는 함수
	
	local StatusIconInfo info;
	
	DeBuffCurRow = -1;
	BuffCurRow = -1;
	
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
			isPC = false;
		}
		else
		{
			return;	// 펫 아이디마저 없다면 걍 무시무시
		}
	}
	
	//info 초기화
	info.Size = 10;
	info.bShow = true;
		
	ParseInt(param, "Max", Max);
	
	for (i=0; i<Max; i++)
	{
		ParseItemIDWithIndex(param, info.ID, i);
		ParseInt(param, "Level_" $ i, info.Level);
		ParseInt(param, "SubLevel_" $ i, info.SubLevel);
		//ttp 60079

		// 토핑 버프인 경우 add 하지 않음.
		if ( class'UIDATA_SKILL'.static.IsToppingSkill( info.ID, info.Level, info.SubLevel) ) 
		{			
			continue ;
		}

		ParseInt(param, "SpellerID_" $ i, info.SpellerID);
		
		if (IsValidItemID(info.ID))
		{
			info.IconName = class'UIDATA_SKILL'.static.GetIconName(info.ID, info.Level, info.SubLevel);
			
			if (GetDebuffType( info.ID, info.Level, info.SubLevel) != 0 )
			{
				if (DeBuffCnt%NSTATUSICON_MAXCOL == 0)
				{
					DeBuffCurRow++;
					if(isPC)	m_StatusIconDeBuff[idx].AddRow();
					else		m_PetStatusIconDeBuff[idx].AddRow();
				}
				if(isPC)	m_StatusIconDeBuff[idx].AddCol(DeBuffCurRow, info);	
				else 		m_PetStatusIconDeBuff[idx].AddCol(DeBuffCurRow, info);		
				DeBuffCnt++;
			}
			else
			{
				if (BuffCnt%NSTATUSICON_MAXCOL == 0)
				{
					BuffCurRow++;
					if(isPC)	m_StatusIconBuff[idx].AddRow();
					else		m_PetStatusIconBuff[idx].AddRow();
				}
				if(isPC)	m_StatusIconBuff[idx].AddCol(BuffCurRow, info);	
				else		m_PetStatusIconBuff[idx].AddCol(BuffCurRow, info);	
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
		ParseItemIDWithIndex(param, info.ID, i);
		ParseInt(param, "Level_" $ i, info.Level);
		ParseInt(param, "SubLevel_" $ i, info.SubLevel );

		ParseInt(param, "SpellerID_" $ i, info.SpellerID);
		
		if (IsValidItemID(info.ID))
		{	
			//디버프이면 
			if (GetDebuffType( info.ID, info.Level, info.SubLevel) != 0 )
			{
				if ( isPC ) deleteBuff( m_StatusIconDeBuff[idx], info.Level, info.ID.ClassID, info.SpellerID);
				else 		deleteBuff( m_PetStatusIconDeBuff[idx], info.Level, info.ID.ClassID, info.SpellerID );							
			}			
			//일반 버프 
			else
			{				
				if ( isPC ) deleteBuff( m_StatusIconBuff[idx], info.Level, info.ID.ClassID, info.SpellerID);
				else        deleteBuff( m_PetStatusIconBuff[idx], info.Level, info.ID.ClassID, info.SpellerID);
			}
		}
	}
	UpdateBuff();
}


//받은 정보의 버프를 찾아 삭제 하는 함수
//ttp 60079 로 spellerID 추가
function deleteBuff( StatusIconHandle tmpStatusIcon , int level, int classID, int spellerID )
{
	local int row;	
	local int col;
	local StatusIconInfo info;	

	for ( row = 0 ; row < tmpStatusIcon.GetRowCount(); row++ )
	{
		for ( col = 0 ; col < tmpStatusIcon.GetColCount(row) ; col++)
		{
			tmpStatusIcon.GetItem(row, col, info );		
			if ( info.ID.classID == classID && info.level ==  level && info.SpellerID == spellerID)
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
	info.Size = 10;	
	info.bShow = true;	

	//Debug( "HandlePartySpelledListInsert" @ String(isPC) @ idx);
	//Max=1 ID=1209091781 ClassID_0=77 Level_0=2 Sec_0=1200
	ParseInt(param, "Max", Max);
	for (i=0; i<Max; i++)
	{
		ParseItemIDWithIndex(param, info.ID, i);
		ParseInt(param, "Level_" $ i, info.Level);
		ParseInt(param, "SubLevel_" $ i, info.SubLevel);
		ParseInt(param, "Sec_" $ i, info.RemainTime);

		// 토핑 버프인 경우 add 하지 않음.
		if ( class'UIDATA_SKILL'.static.IsToppingSkill( info.ID, info.Level, info.SubLevel) ) 
		{			
			continue ;
		}

		//ttp 60079
		ParseInt(param, "SpellerID_" $ i, info.SpellerID);

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
			//일반 버프 
			else
			{				
				if ( isPC ) tmpStatusIcon = m_StatusIconBuff[idx];
				else        tmpStatusIcon = m_PetStatusIconBuff[idx];
			}
		
			//삭제 부분
			deleteBuff ( tmpStatusIcon, info.Level, info.ID.ClassID, info.SpellerID );
			
			//Debug("buffRow" @ tmpStatusIcon.GetRowCount() - 1 @ tmpStatusIcon.GetColCount( tmpStatusIcon.GetRowCount() -1 ));
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
	
	
	if (m_CurBf > 2)
	{
		m_CurBf = 0;
	}
	
	SetINIInt ( "PartyWndCompact", "a", m_CurBf, "WindowsInfo.ini");

	SetBuffButtonTooltip();
	
	switch (m_CurBf)
	{
		case 1:
		UpdateBuff();
		break;
		case 2:
		UpdateBuff();
		break;
		case 0:
		m_CurBf = 0;
		UpdateBuff();
	}
}

// 버튼클릭 이벤트
function OnClickButton( string strID )
{
	local int idx;
	local PartyWnd script;
	script = PartyWnd( GetScript("PartyWnd") );
	switch( strID )
	{
	case "btnBuff":		//버프버튼 클릭시 
		OnBuffButton();
		//script.OnBuffButton();
		break;
	case "btnOption":	// 옵션 버튼 클릭시
		OnOpenPartyWndOption();
		break;
	case "btnSummon":	// 소환수 버튼 클릭시
		//debug("ERROR - you can't enter here");	// 여기로 들어오면 에러 -_-;
		break;
	}
	
	//debug("btnSummon strID-->@@" @ strID);
	//debug("-------------@@@@@@" @ inStr( strID , "btnSummon"));
	if(  inStr( strID , "btnSummon") > -1)
	{
		//debug("btnSummon strID-->@@" @ strID);
		//Debug("idx:" @ idx);
		
		idx = int( Right(strID , 1));
		if(m_PetPartyStatus[idx].isShowwindow())
		{
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
	// 열려있는 소환수 창 정보를 옵션 윈도우로 전달한다. 
	for(i=0; i<MAX_ArrayNum; i++)
	{	
		script.m_arrPetIDOpen[i] = m_arrPetIDOpen[i];
	}
	
	script.ShowPartyWndOption();
	m_PartyOption.SetAnchor("PartyWndCompact.PartyStatusWnd0", "TopRight", "TopLeft", 5, 5);
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
	if (m_CurBf > 2)
	{
		m_CurBf = 0;
	}

	SetINIInt ( "PartyWndCompact", "a", m_CurBf, "WindowsInfo.ini");	
	
	// 툴팁표시
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
			
		}
	}
	else if (m_CurBf == 2)
	{
		for (idx=0; idx<MAX_ArrayNum ; idx++)
		{
			m_StatusIconBuff[idx].HideWindow();	
			m_PetStatusIconBuff[idx].HideWindow();
			m_StatusIconDeBuff[idx].ShowWindow();	
			m_PetStatusIconDeBuff[idx].ShowWindow();
			
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
		}
	}
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
	
	rectWnd = m_wndTop.GetRect();
	if (X > rectWnd.nX + 30)
	{
		if (GetPlayerInfo(userinfo))
		{
			//idx = (Y-rectWnd.nY) / NPARTYSTATUS_HEIGHT;
			idx = GetIdx(Y-rectWnd.nY);
			//debug("OnLButtonDown : " $ idx);
			//RequestTargetUser(m_arrID[idx]);	// 어라? 왜 파티창이랑 콤팩트창이 기능이 다른고?

			rectWnd = m_PetPartyStatus[idx].GetRect();
			rectPetClassIcon = m_PetClassIcon[idx].GetRect();

			if (IsPKMode())
			{
				if(idx <100)
					RequestAttack(m_arrID[idx], userinfo.Loc);
				else
				{
					if (X > rectPetClassIcon.nX && X < rectWnd.nX + rectWnd.nWidth -10)	RequestAttack(m_arrPetID[idx-100], userinfo.Loc);
				}
			}
			else
			{
				if(idx < 100)
					RequestAction(m_arrID[idx], userinfo.Loc);
				else
					if (X > rectPetClassIcon.nX && X < rectWnd.nX + rectWnd.nWidth -10) RequestAction(m_arrPetID[idx-100], userinfo.Loc);
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
	if (X > rectWnd.nX + 30)
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
	
	for(i=0 ; i<MAX_ArrayNum; i++)
	{
		tempY = tempY - NPARTYSTATUS_HEIGHT;
		if(i == 0) tempY = tempY - FIRSTWND_ADD_HEIGHT;	// 첫번째 창은 크기가 더 크기때문에 조금 더 빼준다. 
		
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
		case 2:	idx = 1498;
		break;
	}	
	btnBuff.SetTooltipCustomType(MakeTooltipSimpleText(GetSystemString(idx)));
}


function OnDropWnd( WindowHandle hTarget, WindowHandle hDropWnd, int x, int y )
{
	local string sTargetName, sDropName,sTargetParent;
	local int dropIdx, targetIdx,i;
	
	local  PartyWnd script1;			// 확장된 파티창의 클래스
	//local PartyWndCompact script2;	// 축소된 파티창의 클래스
	
	script1 = PartyWnd( GetScript("PartyWnd") );
	//script2 = PartyWndCompact( GetScript("PartyWndCompact") );
	
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
			script1.CopyStatus ( MAX_PartyMemberCount , dropIdx );		//타겟을 옮겨놓고
			
			for (i=dropIdx-1; i>targetIdx-1; i--)	// 아래로 밀어준다. 
			{
				CopyStatus(i+1, i);
				script1.CopyStatus(i+1, i);
			}
			CopyStatus ( targetIdx , MAX_PartyMemberCount  );
			script1.CopyStatus ( targetIdx , MAX_PartyMemberCount  );
		}
		else if(dropIdx < targetIdx)
		{
			CopyStatus ( MAX_PartyMemberCount , dropIdx );		//타겟을 옮겨놓고
			script1.CopyStatus ( MAX_PartyMemberCount , dropIdx );		//타겟을 옮겨놓고
			
			for (i=dropIdx+1; i<targetIdx+1; i++)	// 위로 땡겨준다.
			{
				CopyStatus(i-1, i);
				script1.CopyStatus(i-1, i);
			}
			CopyStatus ( targetIdx , MAX_PartyMemberCount  );
			script1.CopyStatus ( targetIdx , MAX_PartyMemberCount  );
		}
		ClearStatus(MAX_PartyMemberCount);
		ClearPetStatus(MAX_PartyMemberCount);
		
		//Update Client Data
		class'UIDATA_PARTY'.static.MovePartyMember( dropIdx, targetIdx );
		
		//CopyStatus ( 8 , targetIdx );		//타겟을 옮겨놓고
		//CopyStatus ( targetIdx , dropIdx  );
		//CopyStatus ( dropIdx ,  8  );
		//ClearStatus(8);
		//ClearPetStatus(8);
		
		//script1.CopyStatus ( 8 , targetIdx );		//타겟을 옮겨놓고
		//script1.CopyStatus ( targetIdx , dropIdx  );
		//script1.CopyStatus ( dropIdx ,  8  );
		//script1.ClearPetStatus(8);
		//script1.ClearStatus(8);
		
		ResizeWnd();
	}
	
	
	//hTarget.
	
	//m_PartyStatus[idx].SetAnchor("PartyWnd.PartyStatusSummonWnd" $ idx-1, "BottomLeft", "TopLeft", 0, 0);	// 펫 윈도우 밑으로 앵커
	
	//앵커를 조정해준다. 
		
	//Debug( "DropTargetWindow: " $ hTarget.GetWindowName() );
	//Debug( "DropWindow: " $ hDropWnd.GetWindowName() );
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

/** 
 * 소환수 타입 받기   
 * -> 기획 변경으로 더 이상 사용하지 않음
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
defaultproperties
{
}
