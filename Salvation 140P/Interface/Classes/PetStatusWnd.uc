class PetStatusWnd extends UICommonAPI;

const NSTATUSICON_MAXCOL = 12;

var bool m_bBuff;
var bool m_bShow;
var int m_PetID;
var int  m_CurBf;
var bool  m_bPetload;
var WindowHandle Me;
var BarHandle barFATIGUE;
var BarHandle barMP;
var BarHandle barHP;
var NameCtrlHandle PetName;
var ButtonHandle btnBuff;
var WindowHandle BackTex;
//~ var StatusIconHandle StatusIcon;
var StatusIconHandle m_StatusIconBuff;
var StatusIconHandle m_StatusIconDeBuff;
var StatusIconHandle m_StatusIconSongDance;
var StatusIconHandle m_StatusIconTriggerSkill;
var StatusIconHandle	BufIcon;
var StatusIconHandle	DebufIcon;
var StatusIconHandle	SongDanceIcon;
var StatusIconHandle	TriggerSkillIcon;


function OnRegisterEvent()
{
	RegisterEvent( EV_Restart );

	RegisterEvent( EV_UpdatePetInfo );
	RegisterEvent( EV_ShowBuffIcon );

	// RegisterEvent( EV_StateChanged );
	 
	RegisterEvent( EV_PetStatusShow );
	RegisterEvent( EV_PetStatusSpelledList );
	 
	RegisterEvent( EV_PetStatusClose );
	RegisterEvent( EV_UpdateHP ); //hp 변경이 있을 경우 
	RegisterEvent( EV_UpdateMP ); //mp 변경이 있을 경우 

	RegisterEvent( EV_PetStatusSpelledListDelete ); //1052
	RegisterEvent( EV_PetStatusSpelledListInsert ); //1053	
}

function OnLoad()
{
	m_bPetload = false;
	
	if(CREATE_ON_DEMAND==0)
	  Initialize();
	 else
	  InitializeCOD();
	 
	Load();
}

function Initialize()
{
	BufIcon = GetStatusIconHandle( "PetStatusWnd.StatusIconBuff" );
	DebufIcon = GetStatusIconHandle( "PetStatusWnd.StatusIconDeBuff" );
	SongDanceIcon = GetStatusIconHandle( "PetStatusWnd.StatusIconSongDance" );
	TriggerSkillIcon = GetStatusIconHandle( "PetStatusWnd.StatusIconTriggerSkill" );

	Me = GetHandle( "PetStatusWnd" );
	barFATIGUE = BarHandle ( GetHandle( "PetStatusWnd.barFATIGUE" ) );
	barMP = BarHandle ( GetHandle( "PetStatusWnd.barMP" ) );
	barHP = BarHandle ( GetHandle( "PetStatusWnd.barHP" ) );
	PetName = NameCtrlHandle ( GetHandle( "PetStatusWnd.PetName" ) );
	btnBuff = ButtonHandle ( GetHandle( "PetStatusWnd.btnBuff" ) );
	BackTex = GetHandle( "PetStatusWnd.BackTex" );
	m_StatusIconBuff = StatusIconHandle ( GetHandle( "PetStatusWnd.StatusIconBuff" ) );
	m_StatusIconDeBuff = StatusIconHandle ( GetHandle( "PetStatusWnd.StatusIconDeBuff" ) );
	m_StatusIconSongDance = StatusIconHandle ( GetHandle( "PetStatusWnd.StatusIconSongDance" ) );
	m_StatusIconTriggerSkill = StatusIconHandle ( GetHandle(  "PetStatusWnd.StatusIconTriggerSkill" ));
	m_CurBf = 1;
	//SetBuffButtonTooltip();
}

function InitializeCOD()
{
	BufIcon = GetStatusIconHandle( "PetStatusWnd.StatusIconBuff" );
	DebufIcon = GetStatusIconHandle( "PetStatusWnd.StatusIconDeBuff" );
	SongDanceIcon = GetStatusIconHandle( "PetStatusWnd.StatusIconSongDance" );
	TriggerSkillIcon = GetStatusIconHandle( "PetStatusWnd.StatusIconTriggerSkill" );

	Me = GetWindowHandle( "PetStatusWnd" );
	barFATIGUE = GetBarHandle( "PetStatusWnd.barFATIGUE" );
	barMP = GetBarHandle( "PetStatusWnd.barMP" );
	barHP = GetBarHandle( "PetStatusWnd.barHP" );
	PetName = GetNameCtrlHandle( "PetStatusWnd.PetName" );
	btnBuff = GetButtonHandle( "PetStatusWnd.btnBuff" );
	BackTex = GetWindowHandle( "PetStatusWnd.BackTex" );
	m_StatusIconBuff = GetStatusIconHandle( "PetStatusWnd.StatusIconBuff" );
	m_StatusIconDeBuff = GetStatusIconHandle( "PetStatusWnd.StatusIconDeBuff" );
	m_StatusIconSongDance = GetStatusIconHandle( "PetStatusWnd.StatusIconSongDance" );
	m_StatusIconTriggerSkill = GetStatusIconHandle( "PetStatusWnd.StatusIconTriggerSkill" );
	m_CurBf = 1;
	//SetBuffButtonTooltip();
}

function Load()
{
	m_CurBf = 1;
	SetBuffButtonTooltip();

	m_bShow = false;
	m_bBuff = false;
}

function OnShow()
{
	// local int IsPetOrSummoned;
	local PetInfo petInfo;

	//PetID = class'UIDATA_PET'.static.GetPetID();
	GetPetInfo(petInfo);
	
	//IsPetOrSummoned = class'UIDATA_PET'.static.GetIsPetOrSummoned();

	//if (petInfo.nID < 0 || IsPetOrSummoned!=2)
	if (petInfo.nServerID < 0)
	{
		Me.HideWindow();
	}
	else
	{
		m_bShow = true;
	}
}

function OnHide()
{
	m_bShow = false;
}

function OnEnterState( name a_PreStateName )
{
	if (m_bPetload)
		Me.ShowWindow();

	m_bBuff = false;

	GetINIInt ( "PetStatusWnd", "a", m_CurBf, "WindowsInfo.ini") ;

	SetBuffButtonTooltip();
	UpdateBuff();
}

function OnEvent(int Event_ID, string param)
{
	if (Event_ID == EV_UpdatePetInfo)
	{
		HandlePetInfoUpdate();
	}
	
	else if (Event_ID == EV_UpdateHP)
	{
		UpdatePetHP(param);
	}

	else if (Event_ID == EV_UpdateMP)
	{
		UpdatePetMP(param);
	}

	// 우균이가 고친건데.. 이렇게 하면 안된다. 리스타트시에 초기화만 하면 되는걸..이상한 짓을 해서
	// 63938 같은 TTP 발생..-_-..

	//스테이트 바뀔 때
	//ttp 63598 관련 //kick 으로 튕겼을때 EV_PetStatusClose 이벤트가 오지 않음으로
	//강제로 m_bPetload 를 false 로 바꿔줌
	//그래야 기존 펫 상태창이 나오지 않음
	//else if(Event_ID == EV_StateChanged)
	//{
	//	Debug("씬 " @ param);
	//	if( param != "ReplayState")
	//	{
	//		m_bPetload = false;
	//	}
	//}

	else if (Event_ID == EV_PetStatusClose)
	{
		HandlePetStatusClose();
		m_bPetload = false;
	}
	else if (Event_ID == EV_PetStatusShow)
	{
		if(GetGameStateName()!="GAMINGSTATE")
			return;
	
		HandlePetStatusShow();
		m_bPetload = true;
	}
	else if (Event_ID == EV_ShowBuffIcon)
	{
		HandleShowBuffIcon(param);
	}
	else if (Event_ID == EV_PetStatusSpelledList) //1050
	{
		HandlePetStatusSpelledList(param);
		//Debug( "Event : " $ Event_ID @ param);
	}
	else if (Event_ID == EV_PetStatusSpelledListDelete) //1053
	{
		HandlePetStatusSpelledListDelete(param);
		//Debug( "Event : " $ Event_ID @ param);
	}
	else if (Event_ID == EV_PetStatusSpelledListInsert) //1052
	{
		HandlePetStatusSpelledListInsert(param);
		//Debug( "Event : " $ Event_ID @ param);
	}
	// 63598 ttp
	else if (Event_ID == EV_Restart)
	{
		m_bPetload = false;
	}
}

//초기화
function Clear()
{
 //~ StatusIcon.Clear();
 
	m_StatusIconBuff.Clear();
	m_StatusIconDeBuff.Clear();
	m_StatusIconSongDance.Clear();
	m_StatusIconTriggerSkill.Clear();

	PetName.SetName("", NCT_Normal,TA_Left);
	barHP.SetValue(0, 0);
	barMP.SetValue(0, 0);
	barFatigue.SetValue(0, 0);

	Me.HideWindow();
}

//종료처리
function HandlePetStatusClose()
{
	Me.HideWindow();
	PlayConsoleSound(IFST_WINDOW_CLOSE);

	Debug("펫 ui 꺼짐");
}

//mp 업데이트
function UpdatePetMP(string param)
{
	local int       serverID;
	local int		CurrentMP;
	local int		MP;
	local int		MaxMP;
	local PetInfo	info;

	ParseInt( param, "ServerID", serverID );
	ParseInt( param, "CurrentMP", CurrentMP );
	
	if (GetPetInfo(info))
	{
		if (serverID == info.nServerID)
		{
			MP = CurrentMP;
			MaxMP = info.nMaxMP;			
			barMP.SetValue(MaxMP, MP);
		}
	}
}

//hp 업데이트
function UpdatePetHP(string param)
{
	local int       serverID;
	local int		CurrentHP;
	local int		HP;
	local int		MaxHP;
	local PetInfo	info;

	ParseInt( param, "ServerID", serverID );
	ParseInt( param, "CurrentHP", CurrentHP );
	
	if (GetPetInfo(info))
	{
		if (serverID == info.nServerID)
		{
			HP = CurrentHP;
			MaxHP = info.nMaxHP;			
			barHP.SetValue(MaxHP, HP);			
		}
	}
}

//펫Info패킷 처리
function HandlePetInfoUpdate()
{
	local string Name;
	local int  HP;
	local int  MaxHP;
	local int  MP;
	local int  MaxMP;
	local int  Fatigue;
	local int  MaxFatigue;
	local PetInfo info;

	m_PetID = 0;
	if (GetPetInfo(info))
	{
		m_PetID = info.nServerID;
		Name = info.Name;
		HP = info.nCurHP;
		MP = info.nCurMP;
		Fatigue = info.nFatigue;
		MaxHP = info.nMaxHP;
		MaxMP = info.nMaxMP;
		MaxFatigue = info.nMaxFatigue;
	}

	PetName.SetName(Name, NCT_Normal,TA_Left);
	barHP.SetValue(MaxHP, HP);
	barMP.SetValue(MaxMP, MP);
	barFatigue.SetValue(MaxFatigue, Fatigue); 
}

//펫창을 표시
function HandlePetStatusShow()
{
	Clear();
	Me.ShowWindow();
	Me.SetFocus();

	Debug("팻 ui보임 " );
}

//펫의 버프리스트정보
function HandlePetStatusSpelledList(string param)
{
	local int i;
	local int ID;
	local int Max;

	local int BuffCnt;
	local int BuffCurRow;

	local int DeBuffCnt;
	local int DeBuffCurRow;

	local int SongDanceCnt;
	local int SongDanceCurRow;

	
	local int TriggerSkillCnt;
	local int TriggerSkillCurRow;
	
	local StatusIconInfo info;	

	DeBuffCurRow = -1;
	BuffCurRow = -1;
	SongDanceCurRow = -1;
	TriggerSkillCurRow = -1;

	ParseInt(param, "ID", ID);	
	if (ID<1 || m_PetID != ID) // 내 펫의 버프정보인지 확인하고, 아니면 반사 
	{
		return;
	}

	m_StatusIconBuff.Clear();
	m_StatusIconDeBuff.Clear();
	m_StatusIconSongDance.Clear();
	m_StatusIconTriggerSkill.Clear();

	//info 초기화
	info.Size = 16;
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

		//ttp 60079
		ParseInt(param, "SpellerID_" $ i, info.SpellerID);
		
		if (IsValidItemID(info.ID))
		{			
			info.IconName = class'UIDATA_SKILL'.static.GetIconName(info.ID, info.Level, info.SubLevel);
			info.bHideRemainTime = true;

			if (GetDebuffType( info.ID, info.Level, info.SubLevel) != 0 )
			{
				if (DeBuffCnt%NSTATUSICON_MAXCOL == 0)
				{
					DeBuffCurRow++;				 
					m_StatusIconDeBuff.AddRow();				 
				}
				m_StatusIconDeBuff.AddCol(DeBuffCurRow, info);
				DeBuffCnt++;
			}
			else if (IsSongDance( info.ID, info.Level, info.SubLevel) == true )
			{
				if (SongDanceCnt%NSTATUSICON_MAXCOL == 0)
				{					
					SongDanceCurRow++;					
					m_StatusIconSongDance.AddRow();					
				}	
				m_StatusIconSongDance.AddCol(SongDanceCurRow, info);
				SongDanceCnt++;
			}

			else if (IsTriggerSkill( info.ID, info.Level, info.SubLevel ) == true )
			{
				if ( TriggerSkillCnt % NSTATUSICON_MAXCOL == 0 ) 
				{
					TriggerSkillCurRow++;					
					m_StatusIconTriggerSkill.AddRow();
				}
				m_StatusIconTriggerSkill.AddCol(TriggerSkillCurRow, info);
				TriggerSkillCnt++;
				
			}
			else
			{				
//				Debug( "BuffCnt" @ BuffCnt @ BuffCnt%NSTATUSICON_MAXCOL );
				if (BuffCnt%NSTATUSICON_MAXCOL == 0)
				{					
					
					BuffCurRow++;
					m_StatusIconBuff.AddRow();
//					Debug("addRow");
				}			
				m_StatusIconBuff.AddCol(BuffCurRow, info);
//				Debug("addCol");
				BuffCnt++;
			}
		}
	}	
	UpdateBuff();
}


//버프리스트삭제
function HandlePetStatusSpelledListDelete(string param)
{
	local int i;	
	local int ID;
	local int Max;	
	local StatusIconInfo info;		

	ParseInt(param, "ID", ID);	

	if (ID<1 || m_PetID != ID) // 내 펫의 버프정보인지 확인하고, 아니면 반사 
	{
		return;
	}
		
	ParseInt(param, "Max", Max);

	for (i=0; i<Max; i++)
	{
		//버프 종류를 알기 위한 ID, Level
		ParseItemIDWithIndex(param, info.ID, i);
		ParseInt(param, "Level_" $ i, info.Level );
		ParseInt(param, "SubLevel_" $ i, info.SubLevel );

		ParseInt(param, "SpellerID_" $ i, info.SpellerID );
		//ParseInt(param, "classID_" $ i, classID);//삭제해야 될 클래스 ID
		
		if (IsValidItemID(info.ID))
		{	
			//디버프이면 
			if (GetDebuffType( info.ID, info.Level, info.SubLevel) != 0 )
			{	
				deleteBuff( m_StatusIconDeBuff, info.Level, info.ID.ClassID, info.SpellerID);
			}
			//송댄스
			else if (IsSongDance( info.ID, info.Level, info.SubLevel) == true )
			{	
				deleteBuff( m_StatusIconSongDance, info.Level, info.ID.ClassID, info.SpellerID);
			}
			//IsTriggerSkill
			else if (IsTriggerSkill( info.ID, info.Level, info.SubLevel) == true )
			{								
				 deleteBuff( m_StatusIconTriggerSkill, info.Level, info.ID.ClassID, info.SpellerID);
			}
			//일반 버프 
			else
			{	
				deleteBuff( m_StatusIconBuff, info.Level, info.ID.ClassID, info.SpellerID);
			}
		}
	}	

	UpdateBuff();
}


//받은 정보의 버프를 찾아 삭제 하는 함수
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
function HandlePetStatusSpelledListInsert(string param)
{
	local int i;		
	local int ID;
	local int Max;

	local StatusIconInfo info;
	local StatusIconHandle tmpStatusIcon;

	ParseInt(param, "ID", ID);

	
	if (ID<1 || m_PetID != ID) // 내 펫의 버프정보인지 확인하고, 아니면 반사 
	{
		return;
	}
		
	info.Size = 16;
	info.bShow = true;
	
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

		info.bHideRemainTime = true;

		if (IsValidItemID(info.ID))
		{				
			info.IconName = class'UIDATA_SKILL'.static.GetIconName(info.ID, info.Level, info.SubLevel);
			info.bHideRemainTime = true;
			//디버프이면 
			if (GetDebuffType( info.ID, info.Level, info.SubLevel) != 0 )
			{				
				tmpStatusIcon = m_StatusIconDeBuff;								
			}
			//송댄스
			else if (IsSongDance( info.ID, info.Level, info.SubLevel) == true )
			{					
				tmpStatusIcon = m_StatusIconSongDance;
			}
			//IsTriggerSkill
			else if (IsTriggerSkill( info.ID, info.Level, info.SubLevel) == true )
			{				
				 tmpStatusIcon = m_StatusIconTriggerSkill;
			}
			//일반 버프 
			else
			{	
				tmpStatusIcon = m_StatusIconBuff;
			}
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
	if (nShow==1)
	{
		//~ UpdateBuff(true);
		UpdateBuff();
	}
	else
	{
		//~ UpdateBuff(false);
		UpdateBuff();
	}
}


// 버프디버프 표시,  송댄스 , 끄기 3가지모드를 전환한다.
function UpdateBuff()
{
	//~ local int idx;
	if (m_CurBf == 1)
	{
		// 버프 , 디버프 보여 준다.
		m_StatusIconBuff.ShowWindow(); 
		m_StatusIconDeBuff.ShowWindow(); 
		m_StatusIconSongDance.HideWindow(); 
		m_StatusIconTriggerSkill.HideWindow();
	}
	 /*  
	 // 버프/디버프 통합 
	 else if (m_CurBf == 2)
	 {
	  //~ for (idx=0; idx<NPARTYSTATUS_MAXCOUNT; idx++)
	  //~ {
	   m_StatusIconBuff.HideWindow(); 
	   m_StatusIconDeBuff.ShowWindow(); 
	   m_StatusIconSongDance.HideWindow(); 
	  //~ }
	 }
	 */
	else if (m_CurBf == 2)
	{
		//~ for (idx=0; idx<NPARTYSTATUS_MAXCOUNT; idx++)
		//~ {
		m_StatusIconBuff.HideWindow(); 
		m_StatusIconDeBuff.HideWindow(); 
		m_StatusIconSongDance.ShowWindow(); 
		m_StatusIconTriggerSkill.HideWindow();
  //~ }
	}
	else if ( m_CurBf == 3 )
	{
		m_StatusIconBuff.HideWindow(); 
		m_StatusIconDeBuff.HideWindow(); 
		m_StatusIconSongDance.HideWindow(); 
		m_StatusIconTriggerSkill.ShowWindow();
	}
	else
	{	
		m_StatusIconBuff.HideWindow();
		m_StatusIconDeBuff.HideWindow(); 
		m_StatusIconSongDance.HideWindow(); 
		m_StatusIconTriggerSkill.HideWindow();  
	}
 //m_bBuff = bShow;
}


function OnLButtonDown( WindowHandle a_WindowHandle, int X, int Y )
{
	local Rect rectWnd;
	local UserInfo userinfo;

//	Debug ("OnLButtonDown");
	rectWnd = Me.GetRect();	
	if (X > rectWnd.nX + 13 && X < rectWnd.nX + rectWnd.nWidth -10)
	{
		if (GetPlayerInfo(userinfo))
		{
			RequestAction(m_PetID, userinfo.Loc);
		}
	}
}

function OnClickButton( string strID )
{
	switch( strID )
	{
		case "btnBuff":
			OnBuffButton();
			break;
	}
}


function OnBuffButton()
{
	m_CurBf = m_CurBf + 1;

	// 2009.10.01 이전: 기존에 버프, 디버프, 이상상태 끄기, 송/댄스 4가지 였다. 
	// (버프/디버프) 이상상태 보기, 송/댄스 보기, 이상상태 끄기
	// 4가지 모드가 전환된다.
	// 2011.5.27 특수 이상상태 추가
	if (m_CurBf > 3)
	{
		m_CurBf = 0;
	}
	SetINIInt ( "PetStatusWnd", "a", m_CurBf, "WindowsInfo.ini") ;

	SetBuffButtonTooltip();
	UpdateBuff();
}

// 버프 툴팁을 설정한다.
function SetBuffButtonTooltip()
{
	local int idx;

	 //stringID=1496 string=[버프보기] 
	 //stringID=1497 string=[디버프보기] 
	 //stringID=1498 string=[이상상태 끄기] 
	 //stringID=1741 string=[송/댄스 보기] 
	 switch (m_CurBf)
	 {
		case 0: idx = 2221; // 1496;  // 버프보기로 변경 -> 이상상태 보기 2221 
			break;
		//case 1: idx = 1497; break; // 삭제 된다. 
		case 1: idx = 1741;
			break;
		case 2: idx = 2307;
			break;
		// 차후에 바꿔야할 것.
		case 3: idx = 1498;
			break;
	}
	btnBuff.SetTooltipCustomType(MakeTooltipSimpleText(GetSystemString(idx)));
}



//~ function OnBuffButton()
//~ {
 //~ UpdateBuff(!m_bBuff);
//~ }

//~ function UpdateBuff(bool bShow)
//~ {
 //~ if (bShow)
 //~ {
  //~ //StatusIcon.ShowWindow();
  //~ m_StatusIconBuff.ShowWindow();
  //~ m_StatusIconDeBuff.ShowWindow();
  //~ m_StatusIconSongDance.ShowWindow();
 //~ }
 //~ else
 //~ {
  //~ //StatusIcon.HideWindow();
  //~ m_StatusIconBuff.ShowWindow();
  //~ m_StatusIconDeBuff.ShowWindow();
  //~ m_StatusIconSongDance.ShowWindow();
 //~ }
 //~ m_bBuff = bShow;
//~ }


function OnClickItem( string strID, int index )
{	
	local int row;
	local int col;
	local StatusIconInfo info;
	local SkillInfo skillInfo;		// 스킬 정보. 버프스킬인지 확인해야 하니까
	local StatusIconHandle  StatusIcon;

//	Debug("item Click");
	col = index / 10;
	row = index - (col * 10);

	if(InStr( strID ,"StatusIconBuff" ) > -1)
	{
		StatusIcon = BufIcon;
	}
	if(InStr( strID ,"StatusIconDeBuff" ) > -1)
	{
		StatusIcon = DebufIcon;
	}
	if(InStr( strID ,"StatusIconSongDance" ) > -1)
	{
		StatusIcon = SongDanceIcon;
	}
	if (InStr( strID ,"StatusIconTriggerSkill" ) > -1)
	{
		StatusIcon = TriggerSkillIcon;
	}


	StatusIcon.GetItem(row, col, info);
	
	// ID를 가지고 스킬의 정보를 얻어온다. 없으면 패배
	if( !GetSkillInfo( info.ID.ClassID, info.Level , info.SubLevel, skillInfo ) )
	{
		//debug("ERROR - no skill info!!");
		return;
	}	
	
	if ( InStr( strID ,"StatusIconBuff" ) > -1 ||  InStr( strID ,"StatusIconDeBuff" ) > -1 ||  InStr( strID ,"StatusIconSongDance" ) > -1 || InStr( strID ,"StatusIconTriggerSkill" ) > -1) 
	{
		if (skillInfo.Debuff == 0 && skillInfo.OperateType == 1)
		{	
			//Summon에서는 Update 이벤트시 info.ServerID에 ServerID를 저장해 두는데 Pet에서는 그런 처리가 없다.
			RequestDispel(m_PetID, info.ID, info.Level, info.SubLevel);	
		}					//버프 취소 요청
		else												
		{	
			AddSystemMessage(2318);	
		}	//강화 스킬인 경우에만 버프 취소가 가능합니다. 
	}

}

// 마우스 오른쪽 버튼 클릭
function OnRButtonDown( WindowHandle a_WindowHandle, int X, int Y )
{
	local Rect      rectWnd;
	local int		TargetID;	
	local string    userName;
	local UserInfo  targetUserInfo;

	rectWnd = Me.GetRect();
	
	//타겟ID 얻어오기
	TargetID = m_PetID;

	if (TargetID > 0)
	{		
		if (X > rectWnd.nX && X < rectWnd.nX + rectWnd.nWidth) 
		{
			if (Y > rectWnd.nY && Y < rectWnd.nY + rectWnd.nHeight) 
			{
				// 컨텍스트 메뉴 구성을 위한 정보 save
				userName = class'UIDATA_USER'.static.GetUserName(TargetID);

				if (userName != "")	
				{
					if (GetTargetInfo(targetUserInfo))
					{
						// Debug("타겟이 있는 상태");
					}

					// 이미 타겟이 잡히지 않았다면..
					if (targetUserInfo.nID != TargetID) setTargetByServerID(TargetID);
								
					getInstanceContextMenu().execContextEvent(userName, TargetID, X, Y);				
				}

				//Debug("myInfo.Name : " @ myInfo.Name);
				//Debug("userName    : " @ userName);
				//Debug("X : " @ X);
				//Debug("Y : " @ Y);
				//Debug("rectWnd.nX  : " @ rectWnd.nX );
				//Debug("rectWnd.nY  : " @ rectWnd.nY );
			}
		}
	}
}
defaultproperties
{
}
