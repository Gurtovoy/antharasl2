/******************************************************************************
//                                                개인/파티간의 결투 관련 UI 스크립트                                                       //
******************************************************************************/

class DuelManager extends UICommonAPI;

CONST DIALOG_ASK_START = 1111;

CONST MAX_PARTY_NUM = 9;

const NDUELSTATUS_HEIGHT = 46;	//듀얼 상태창의 세로길이.

var int					m_memberInfo[MAX_PARTY_NUM];		// 각 파티 창에 표시되고 있는 플레이어의 서버 ID를 가지고 있다. 0이면 사용하지 않는 파티 창.

// 윈도우 핸들
var WindowHandle		m_TopWnd;
var WindowHandle		m_StatusWnd[MAX_PARTY_NUM];
var NameCtrlHandle		m_PlayerName[MAX_PARTY_NUM];
var TextureHandle		m_ClassIcon[MAX_PARTY_NUM];
var BarHandle			m_BarCP[MAX_PARTY_NUM];
var BarHandle			m_BarHP[MAX_PARTY_NUM];
var BarHandle			m_BarMP[MAX_PARTY_NUM];

var bool				m_bDuelState;


function OnRegisterEvent()
{
	// 이벤트 (서버 혹은 클라이언트에서 오는) 핸들 등록.
	registerEvent(EV_DuelAskStart);
	registerEvent(EV_DuelReady);
	registerEvent(EV_DuelStart);
	registerEvent(EV_DuelEnd);
	registerEvent(EV_DuelUpdateUserInfo);
	registerEvent(EV_DuelEnemyRelation);
	registerEvent(EV_DialogOK);
	registerEvent(EV_DialogCancel);
	registerEvent(EV_OlympiadUserInfo);
	RegisterEvent( EV_OlympiadMatchEnd );
}


// 윈도우 생성시 로드되는 함수
function OnLoad()
{
	local int idx;

	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	if(CREATE_ON_DEMAND==0)
	{
		//Init Handle 각종 이벤트 핸들 초기화.
		m_TopWnd = GetHandle("DuelManager");
		
		for (idx=0; idx<MAX_PARTY_NUM; idx++)
		{
			m_StatusWnd[idx] = GetHandle("DuelManager.PartyStatusWnd" $ idx);
			m_PlayerName[idx] = NameCtrlHandle( GetHandle( "DuelManager.PartyStatusWnd" $ idx $ ".PlayerName" ) ); 
			m_ClassIcon[idx] = TextureHandle( GetHandle( "DuelManager.PartyStatusWnd" $ idx $ ".ClassIcon" ) );
			m_BarCP[idx] = BarHandle( GetHandle( "DuelManager.PartyStatusWnd" $ idx $ ".barCP" ) );
			m_BarHP[idx] = BarHandle( GetHandle( "DuelManager.PartyStatusWnd" $ idx $ ".barHP" ) );
			m_BarMP[idx] = BarHandle( GetHandle( "DuelManager.PartyStatusWnd" $ idx $ ".barMP" ) );
		}
	}
	else
	{
		//Init Handle 각종 이벤트 핸들 초기화.
		m_TopWnd = GetWindowHandle("DuelManager");
		
		for (idx=0; idx<MAX_PARTY_NUM; idx++)
		{
			m_StatusWnd[idx] = GetWindowHandle("DuelManager.PartyStatusWnd" $ idx);
			m_PlayerName[idx] = GetNameCtrlHandle( "DuelManager.PartyStatusWnd" $ idx $ ".PlayerName" ); 
			m_ClassIcon[idx] = GetTextureHandle( "DuelManager.PartyStatusWnd" $ idx $ ".ClassIcon" );
			m_BarCP[idx] = GetBarHandle( "DuelManager.PartyStatusWnd" $ idx $ ".barCP" );
			m_BarHP[idx] = GetBarHandle( "DuelManager.PartyStatusWnd" $ idx $ ".barHP" );
			m_BarMP[idx] = GetBarHandle( "DuelManager.PartyStatusWnd" $ idx $ ".barMP" );
		}
	}

	Clear();
	m_bDuelState = false;
}

//이벤트 처리 핸들
function OnEvent(int EventID, string param)
{
	local Color white;
	white.R = 255;
	white.G = 255;
	white.B = 255;

	//debug( "DuelManager event " $ EventID $ ", param " $ param );
	switch( EventID )
	{
	case EV_DuelAskStart:
		//debug("DuelAskStart");
		HandleDuelAskStart(param);
		break;
	case EV_DuelReady:
		//debug("DuelReady");
		m_bDuelState = true;
		break;
	case EV_DuelStart:
		//debug("DuelStart");
		break;
	case EV_DuelEnd:
		//debug("DuelEnd");
		m_bDuelState = false;
		Clear();
		m_TopWnd.HideWindow();
		break;
	case EV_DuelUpdateUserInfo:
		HandleUpdateUserInfo( param );
		break;
	case EV_DuelEnemyRelation:
		break;
	case EV_DialogOK:
		HandleDialogOK();
		break;
	case EV_DialogCancel:
		//debug("rejected");
		HandleDialogCancel();
		break;
	case EV_OlympiadUserInfo:
		HandleOlympiadUserInfo( param );
		break;
	case EV_OlympiadMatchEnd:
		HandleOlympiadEnd();
		break;
	default:
		break;
	};
}

//듀얼을 요청 
function HandleDuelAskStart( string param )
{
	local string	sName;
	local int		type, messageNum;
	local bool      bOption;

	bOption = GetOptionBool( "Communication", "IsRejectingDuel" );
	
	ParseString( param, "userName", sName );
	ParseInt( param, "type", type );

	if (bOption == true)
	{
		// 옵션에서 거부 상태를 체크 해놓으면 -1을 보낸다
		RequestDuelAnswerStart( type, int(bOption), -1 );		
	}
	else	
	{
		if ( IsShowWindow("DialogBox"))
		{
			RequestDuelAnswerStart( type, int(bOption), 0);
			return;
		}

		// 다이얼로그에 메세지를 설정하고, 보여준다.
		if( type == 0 )			// 개인 결투
			messageNum = 1938;
		else if( type == 1 )		// 파티 결투
			messageNum = 1939;
	
		DialogSetReservedInt( type );
		DialogSetParamInt64( 10*1000 );	
		DialogSetID(DIALOG_ASK_START);
		DialogSetCancelD(DIALOG_ASK_START);
		DialogShow(DialogModalType_Modalless, DialogType_Progress, MakeFullSystemMsg( GetSystemMessage(messageNum), sName ), string(Self) );
	}
}

function HandleOlympiadUserInfo(string Param)
{
	local int i;
	local int playNum;

	local int IsPlayer;
	local int PlayerID;
	local int m_ClassID;
	local string m_Name;
	local int m_MaxHP;
	local int m_CurHP;
	local int m_MaxCP;
	local int m_CurCP;
	
	local string FakeEventParam;
	
	ParseInt(param, "TotalCount", playNum); //플레이어 숫자
	
	//~ 플레이어의 인원이 0 이상이면 올림피아드 다대다로 간주하고 UI 시작 
	
	if (playNum > 0 )
	{
		for(i = 0; i < playNum; i++)

		{
			ParseInt(param, "PlayerNum_" $ string (i) , IsPlayer);  //현재 플레이어의 팀정보 1팀 2팀
			ParseInt(param, "ID_" $ string (i), PlayerID);
			ParseString(param, "Name_" $ string (i), m_Name);
			ParseInt(param, "ClassID_" $ string (i), m_ClassID);
			ParseInt(param, "MaxHP_" $ string (i), m_MaxHP);
			ParseInt(param, "CurHP_" $ string (i), m_CurHP);
			ParseInt(param, "MaxCP_" $ string (i), m_MaxCP);
			ParseInt(param, "CurCP_" $ string (i), m_CurCP);
		
			if (IsPlayer == 0)
			{
				FakeEventParam = "";
				ParamAdd (FakeEventParam, "userName", "m_Name");
				ParamAdd (FakeEventParam, "ID", string(PlayerID) );
				ParamAdd (FakeEventParam, "class", string(m_ClassID) );
				ParamAdd (FakeEventParam, "level", string(75) );
				ParamAdd (FakeEventParam, "currentHP", string( m_CurHP) );
				ParamAdd (FakeEventParam, "maxHP", string(m_MaxHP) );
				ParamAdd (FakeEventParam, "currentMP", string(0) );
				ParamAdd (FakeEventParam, "maxMP", string(0) );
				ParamAdd (FakeEventParam, "currentCP", string(m_CurCP) );
				ParamAdd (FakeEventParam, "maxCP", string(m_MaxCP) );
				
				ExecuteEvent(EV_DuelUpdateUserInfo, FakeEventParam);
			}
			
			
			
		}
	}
	
}

function HandleOlympiadEnd()
{
	ExecuteEvent(EV_DuelEnd);
}

function HandleDialogOK()
{
	local int dialogID;
	local bool bOption;
	if(DialogIsMine())
	{
		dialogID = DialogGetID();
		if( dialogID == DIALOG_ASK_START )
		{
			bOption = GetOptionBool( "Communication", "IsRejectingDuel" );
			RequestDuelAnswerStart( DialogGetReservedInt(), int(bOption), 1 );
		}
	}
}

function HandleDialogCancel()
{
	local bool bOption;

	if(DialogIsMine())
	{
		if( DialogCheckCancelByID(DIALOG_ASK_START))
		{
			// Debug("--RequestDuelAnswerStart");
			bOption = GetOptionBool( "Communication", "IsRejectingDuel" );
			RequestDuelAnswerStart( DialogGetReservedInt(), int(bOption), 0 );
		}
	}
}



function HandleUpdateUserInfo( string param )
{
	local string sName;
	local int ID, classID, level, currentHP, maxHP, currentMP, maxMP, currentCP, maxCP;
	local int i;
	local bool bFound;

	if( !m_bDuelState )
		return;

	ParseString( param, "userName", sName );
	ParseInt( param, "ID", ID );
	ParseInt( param, "class", classID );
	ParseInt( param, "level", level );
	ParseInt( param, "currentHP", currentHP );
	ParseInt( param, "maxHP", maxHP );
	ParseInt( param, "currentMP", currentMP );
	ParseInt( param, "maxMP", maxMP );
	ParseInt( param, "currentCP", currentCP );
	ParseInt( param, "maxCP", maxCP );

	// 유저의 ID 로 파티창을 검색한다.
	bFound = false;
	for( i=0; i < MAX_PARTY_NUM ; ++i )
	{
		if( m_memberInfo[i] != 0  )
		{
			if( ID == m_memberInfo[i] )
			{
				bFound = true;
				break;
			}
		}
		else 
		{
			break;
		}
	}

	// i 는 정보가 업데이트 될 인덱스를 가리킨다.( i는 MAX_PARTY_NUM 보다 작아야한다. 아니면 에러;;; )
	if( !bFound )			// 새로운 멤버이다
	{
		//debug( "match not found(i:" $ i );
		m_memberInfo[i] = ID;
		m_StatusWnd[i].ShowWindow();
		Resize(i+1);
	}

	m_TopWnd.ShowWindow();

	//Name
	m_PlayerName[i].SetName(sName, NCT_Normal,TA_Center);

	//직업 아이콘
	m_ClassIcon[i].SetTexture(GetClassRoleIconName(classID));
	m_ClassIcon[i].SetTooltipCustomType(MakeTooltipSimpleText(GetClassRoleName(classID) $ " - " $ GetClassType(classID)));

	m_BarCP[i].SetValue( maxCP, currentCP );
	m_BarHP[i].SetValue( maxHP, currentHP );
	m_BarMP[i].SetValue( maxMP, currentMP );
}

//초기화
function Clear()
{
	local int i;

	for( i=0 ; i < MAX_PARTY_NUM ; ++i )
	{
		m_StatusWnd[i].HideWindow();
		m_memberInfo[i] = 0;
	}
}

// 현재 보이고 있는 창의 개수에 맞도록 frame 등의 사이즈를 조정한다( count는 창의 카운트 )
function Resize( int count )
{
	local Rect entireRect, statusWndRect;
	entireRect = m_TopWnd.GetRect();
	statusWndRect = m_StatusWnd[0].GetRect();

	m_TopWnd.SetWindowSize( entireRect.nWidth, statusWndRect.nHeight*count );
	m_TopWnd.SetResizeFrameSize( 10, statusWndRect.nHeight*count );
}

//마우스 왼쪽버튼으로 타겟팅
function OnLButtonDown( WindowHandle a_WindowHandle, int X, int Y )
{
	local Rect rectWnd;
	local int idx;
	
	rectWnd = m_TopWnd.GetRect();
	
	if (X > rectWnd.nX + 13 )
	{
		//debug ("abcde" $ X $ rectWnd.nX $idx);
		idx = (Y-rectWnd.nY) / NDUELSTATUS_HEIGHT;
		RequestTargetUser(m_memberInfo[idx]);
	}
}
defaultproperties
{
}
