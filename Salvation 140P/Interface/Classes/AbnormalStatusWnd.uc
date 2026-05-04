//AbnormalStatusWnd


class AbnormalStatusWnd extends UICommonAPI;

const NSTATUSICON_FRAMESIZE = 12;
const NSTATUSICON_MAXCOL = 12;

var int m_NormalStatusRow;
var int m_DebuffRow;
var int m_EtcStatusRow;
var int m_ShortStatusRow;
var int m_SongDanceStatusRow;
var int m_TriggerSkillRow;
var bool m_bOnCurState;

var WindowHandle		Me;
var StatusIconHandle	StatusIcon;

function OnRegisterEvent()
{
	RegisterEvent( EV_AbnormalStatusNormalItem );
	RegisterEvent( EV_AbnormalStatusEtcItem );
	RegisterEvent( EV_AbnormalStatusShortItem );
	
	RegisterEvent( EV_Restart );
	//RegisterEvent( EV_Die );
	RegisterEvent( EV_ShowReplayQuitDialogBox );
	RegisterEvent( EV_LanguageChanged );
	RegisterEvent( EV_StateChanged );	//branch121212
		
	
}

function OnLoad()
{
	m_DebuffRow = -1;
	m_NormalStatusRow = -1;
	m_EtcStatusRow = -1;
	m_ShortStatusRow = -1;
	m_SongDanceStatusRow = -1;
	m_TriggerSkillRow = -1;
	m_bOnCurState = false;
	
	InitHandle();
}

function InitHandle()
{
	Me = GetWindowHandle( "AbnormalStatusWnd" );
	StatusIcon = GetStatusIconHandle( "AbnormalStatusWnd.StatusIcon" );
}

function OnEnterState( name a_PreStateName )
{
	m_bOnCurState = true;
	UpdateWindowSize();
}

function OnExitState( name a_NextStateName )
{
	m_bOnCurState = false;
}

function OnEvent(int Event_ID, string param)
{
	//Debug( "debuftest OnEvent " @ Event_ID  @ param) ;
	if (Event_ID == EV_AbnormalStatusNormalItem) //950
	{
		HandleAddNormalStatus(param);
	}
	else if (Event_ID == EV_AbnormalStatusEtcItem) //960
	{
		HandleAddEtcStatus(param);
	}
	else if (Event_ID == EV_AbnormalStatusShortItem) //970
	{
		HandleAddShortStatus(param);
	}
	else if (Event_ID == EV_Restart)
	{
		HandleRestart();
	}
	//else if (Event_ID == EV_Die)
	//{		
		//HandleDie();
	//}
	else if (Event_ID == EV_ShowReplayQuitDialogBox)
	{
		HandleShowReplayQuitDialogBox();
	}
	else if (Event_ID == EV_LanguageChanged)
	{
		HandleLanguageChanged();
	}	

	//branch GD35_0828 2013-12-04 luciper3 - 상태 변경시 트레이닝품 제외시키는 코드인데, 
	// 이 ui가 게이밍상태에서만 떠야하는데 다른상태가 와도 트레이닝룸이 아니라서 ui를 갱신한다. 그래서 게이밍 상태에 재진입했을때만 갱신하도록 수정함.
	//branch121212
	if(Event_ID == EV_StateChanged)
	{	
		//if (param != "TRAININGROOMSTATE")
		if (param == "GAMINGSTATE")
		{
			UpdateWindowSize();	
		}		
	}
	//end of branch
}

//리스타트를 하면 올클리어
function HandleRestart()
{
	ClearAll();
}

//죽었으면, Normal/Short를 클리어
/*function HandleDie()
{
	//죽어서 남는 디버프 처리 함수 ClearStatus 와 거의 유사함.
	
	//ClearStatusOnDie(false, false);
	ClearStatus(false, false);	
	ClearStatus(false, true);
}*/

function HandleShowReplayQuitDialogBox()
{
	Me.HideWindow();
}

//강제로 UI가 보여질 때, 프레임이 보여지는 것을 막는다
function OnShow()
{
	local int RowCount;
	RowCount = StatusIcon.GetRowCount();
	if (RowCount<1)
	{
		Me.HideWindow();
	}
}


//죽었을 때 특정 버프만 남겨 두고 초기화 하는 함수 
/*
function ClearStatusOnDie(bool bEtcItem, bool bShortItem)
{
	local int i;
	local int j;
	local int RowCount;
	local int RowCountTmp;
	local int ColCount;
	local StatusIconInfo info;

	local bool isDeathDebuff ; 

	isDeathDebuff = false;

	RowCount = StatusIcon.GetRowCount();
	for (i=0; i<RowCount; i++)
	{
		ColCount = StatusIcon.GetColCount(i);
		for (j=0; j<ColCount; j++)
		{
			StatusIcon.GetItem(i, j, info);

			//제대로 아이템을 얻어왔다면
			if (IsValidItemID(info.ID))
			{				
				//Debug( "ClearStatusOnDie" @ info.ID.ClassID @ info.bEtcItem @ info.bShortItem ) ;
				if ( info.ID.ClassID == 19114 ) // 죽어서 보여야 하는 디버프 
				{
					isDeathDebuff = true;
				}
				else if (info.bEtcItem==bEtcItem && info.bShortItem==bShortItem)
				{
					StatusIcon.DelItem(i, j);
					j--;
					ColCount--;
					
					RowCountTmp = StatusIcon.GetRowCount();
					if (RowCountTmp != RowCount)
					{
						i--;
						RowCount--;
					}
				}
			}
		}
	}
	
	//Normal아이템을 초기화하는 경우라면, Normal아이템의 현재행을 초기화한다.
	if (bEtcItem==false && bShortItem==false)
	{
		m_NormalStatusRow = -1;
		m_SongDanceStatusRow = -1;
		if ( isDeathDebuff ) 
		{ 
			Debug( "m_DebuffRow" @ m_DebuffRow ) ;
		};
		m_DebuffRow = -1;
		m_TriggerSkillRow = -1;
	}
	//Etc아이템을 초기화하는 경우라면, Etc아이템의 현재행을 초기화한다.
	if (bEtcItem==true && bShortItem==false)
	{
		m_EtcStatusRow = -1;
		m_ShortStatusRow = -1;
	}
	//Short아이템을 초기화하는 경우라면, Short아이템의 현재행을 초기화한다.
	if (bEtcItem==false && bShortItem==true)
	{
		m_ShortStatusRow = -1;
		//~ m_EtcStatusRow = -1;
	}
}
*/



//특정한 Status들을 초기화한다.
function ClearStatus(bool bEtcItem, bool bShortItem)
{
	local int i;
	local int j;
	local int RowCount;
	local int RowCountTmp;
	local int ColCount;
	local StatusIconInfo info;	
	
	//Normal아이템을 초기화하는 경우라면, Normal아이템의 현재행을 초기화한다.
	if (bEtcItem==false && bShortItem==false)
	{
		m_NormalStatusRow = -1;
		m_SongDanceStatusRow = -1;
		m_DebuffRow = -1;
		m_TriggerSkillRow = -1;
	}
	//Etc아이템을 초기화하는 경우라면, Etc아이템의 현재행을 초기화한다.
	if (bEtcItem==true && bShortItem==false)
	{
		m_EtcStatusRow = -1;
		m_ShortStatusRow = -1;
	}
	//Short아이템을 초기화하는 경우라면, Short아이템의 현재행을 초기화한다.
	if (bEtcItem==false && bShortItem==true)
	{
		m_ShortStatusRow = -1;
		//~ m_EtcStatusRow = -1;
	}
	
	RowCount = StatusIcon.GetRowCount();
	for (i=0; i<RowCount; i++)
	{
		ColCount = StatusIcon.GetColCount(i);
		for (j=0; j<ColCount; j++)
		{
			StatusIcon.GetItem(i, j, info);
			
			

			//제대로 아이템을 얻어왔다면
			if (IsValidItemID(info.ID))
			{	
				if (info.bEtcItem==bEtcItem && info.bShortItem==bShortItem)
				{
					StatusIcon.DelItem(i, j);
					j--;
					ColCount--;
					
					RowCountTmp = StatusIcon.GetRowCount();
					if (RowCountTmp != RowCount)
					{
						i--;
						RowCount--;
					}
				}
			}
		}
	}
}

function ClearAll()
{
	ClearStatus(false, false);
	ClearStatus(true, false);
	ClearStatus(false, true);
}

function handleArenaSeal( int classID, string Name, int Level ) 
{
	local string param ; 

	if ( classID == 30799 ) 
	{
		param = "";
		ParamAdd( param, "classID", String ( classID) ) ;
		ParamAdd( param, "Name", Name ) ;
		ParamAdd( param, "Level", String ( Level )) ;
		CallGFxFunction ( "ArenaScoreBoardHUD", "seal", param ) ;
	}
}

//Normal Status 추가  950
function HandleAddNormalStatus(string param)
{
	local int i;
	local int Max;
	local int BuffCnt;
	local int DeBuffCnt;

	local StatusIconInfo info;
	
	//local int temp1;

	// 발동 버프 슬롯 분리 - gorillazin 10.05.24.
	local int TriggerBuffCount;

	local array<StatusIconInfo> arrSongDance;
	local array<StatusIconInfo> arrTriggerSkill;
	local array<StatusIconInfo> arrDebuff;
	local array<StatusIconInfo> arrBuff;

	
	//NormalStatus 초기화
	ClearStatus(false, false);

	//info 초기화
	info.Size = 24;
	info.BackTex = "L2UI.EtcWndBack.AbnormalBack";
	info.bShow = true;
	info.bEtcItem = false;
	info.bShortItem = false;

	BuffCnt = 0;
	DeBuffCnt = 0;

	// 발동 버프 슬롯 분리 - gorillazin 10.05.24.
	TriggerBuffCount = 0;

	ParseInt(param, "ServerID", info.ServerID);
	ParseInt(param, "Max", Max);

	for (i = 0 ; i < Max ; i++ )
	{
		ParseItemIDWithIndex(param, info.ID, i);
		ParseInt(param, "SkillLevel_" $ i, info.Level);
		ParseInt(param, "SkillSubLevel_" $ i, info.SubLevel);
		ParseInt(param, "RemainTime_" $ i, info.RemainTime);
		ParseString(param, "Name_" $ i, info.Name);
		ParseString(param, "IconName_" $ i, info.IconName);
		ParseString(param, "Description_" $ i, info.Description);

		ParseInt(param, "SpellerID_" $ i, info.SpellerID);
		
		// 아레나 서버 봉인 해제 단계 버프 5스택 부터 처리 하므로, 
		if (  getInstanceUIData().getIsArenaServer()  ) handleArenaSeal ( info.ID.classID, info.Name, info.Level ) ;

		if (IsValidItemID(info.ID))                                                                                  
		{
			//시너지/송/댄스 버프
			if (IsSongDance( info.ID, info.Level, info.SubLevel))
			{
				//iiidebug( info.Name $ "IsSongDance>>>>" $ string(IsSongDance( info.ID, info.Level)) );
				arrSongDance.Length = arrSongDance.Length + 1;
				arrSongDance[arrSongDance.Length - 1] = info;
			}

			//발동 버프
			else if (IsTriggerSkill(info.ID, info.Level, info.SubLevel))
			{
				arrTriggerSkill.Length = arrTriggerSkill.Length + 1;
				arrTriggerSkill[arrTriggerSkill.Length - 1] = info;
			}
			//디버프
			else if (GetDebuffType( info.ID, info.Level, info.SubLevel) != 0)
			{
				arrDebuff.Length = arrDebuff.Length + 1;
				arrDebuff[arrDebuff.Length - 1] = info;
			}
			//일반 버프 토핑 버프는 표시하지 않는다.
			else if ( !class'UIDATA_SKILL'.static.IsToppingSkill( info.ID, info.Level, info.SubLevel) )
			{
				arrBuff.Length = arrBuff.Length + 1;
				arrBuff[arrBuff.Length - 1] = info;
			}
		}
	}

	//시너지/송/댄스 버프 추가
	for( i = 0 ; i < arrSongDance.Length ; i ++ )
	{
		if (m_SongDanceStatusRow == -1)
		{
			m_SongDanceStatusRow = m_NormalStatusRow +1;
			StatusIcon.InsertRow(m_SongDanceStatusRow);

			if (m_DebuffRow > -1)
			{
				m_DebuffRow++;
			}
		}				
		StatusIcon.AddCol(m_SongDanceStatusRow, arrSongDance[i]);
	}

	//발동 버프 추가
	for( i = 0 ; i < arrTriggerSkill.Length ; i ++ )
	{
		if (m_TriggerSkillRow == -1 && m_SongDanceStatusRow == -1)
		{
			m_TriggerSkillRow = m_NormalStatusRow + 1;
			StatusIcon.InsertRow(m_TriggerSkillRow);

			if (m_DebuffRow > -1)
			{
				m_DebuffRow++;
			}
		}
		else if (m_TriggerSkillRow == -1 && m_SongDanceStatusRow > -1)
		{
			m_TriggerSkillRow = m_SongDanceStatusRow +1;
			StatusIcon.InsertRow(m_TriggerSkillRow);

			if (m_DebuffRow > -1)
			{
				m_DebuffRow++;
			}
		}

		if (TriggerBuffCount == NSTATUSICON_MAXCOL)
		{
			m_TriggerSkillRow++;
			StatusIcon.InsertRow(m_TriggerSkillRow);

			if (m_DebuffRow > -1)
			{
				m_DebuffRow++;
			}
		}

		StatusIcon.AddCol(m_TriggerSkillRow, arrTriggerSkill[i]);

		TriggerBuffCount++;
	}
	//디버프 추가.
	for( i = 0 ; i < arrDebuff.Length ; i ++ )
	{		
		if (m_DebuffRow == -1 && m_SongDanceStatusRow == -1 && m_TriggerSkillRow == -1)
		{
			m_DebuffRow = m_NormalStatusRow + 1;
			StatusIcon.InsertRow(m_DebuffRow);
		}
		else if (m_DebuffRow == -1 && m_SongDanceStatusRow > -1 && m_TriggerSkillRow == -1)
		{					
			m_DebuffRow = m_SongDanceStatusRow + 1;
			StatusIcon.InsertRow(m_DebuffRow);
		}
		else if (m_DebuffRow == -1 && m_SongDanceStatusRow == -1 && m_TriggerSkillRow > -1)
		{
			m_DebuffRow = m_TriggerSkillRow + 1;
			StatusIcon.InsertRow(m_DebuffRow);
		}
		else if (m_DebuffRow == -1 && m_SongDanceStatusRow > -1 && m_TriggerSkillRow > -1)
		{
			m_DebuffRow = m_TriggerSkillRow + 1;
			StatusIcon.InsertRow(m_DebuffRow);
		}

		if( DeBuffCnt != 0 )
		{
			if ( DeBuffCnt%NSTATUSICON_MAXCOL == 0 )
			{
				m_DebuffRow++;
				StatusIcon.InsertRow(m_DebuffRow);
			}
		}
		StatusIcon.AddCol(m_DebuffRow, arrDebuff[i]);

		DeBuffCnt++;
	}
	//버프 추가.
	for( i = 0 ; i < arrBuff.Length ; i ++ )
	{
		if (BuffCnt%NSTATUSICON_MAXCOL == 0)
		{
			m_NormalStatusRow++;
			StatusIcon.InsertRow(m_NormalStatusRow);
		}
		StatusIcon.AddCol(m_NormalStatusRow, arrBuff[i]);
		BuffCnt++;
	}
	
	
	//현재 Etc, Short아이템이 표시되고 있는 중이라면, 행이 증가/삭제 되었을 경우가 있기 때문에
	if (m_EtcStatusRow > -1)
	{
		m_EtcStatusRow = m_NormalStatusRow + 1;
		
		if (m_SongDanceStatusRow > -1)
		{			
			m_EtcStatusRow = m_SongDanceStatusRow + 1;
		}
		if (m_TriggerSkillRow > -1)
		{
			m_EtcStatusRow = m_TriggerSkillRow + 1;
		}
		if (m_DebuffRow > -1)
		{
			m_EtcStatusRow = m_DebuffRow + 1;
		}
	}

	if (m_ShortStatusRow > -1)
	{
		m_ShortStatusRow = m_NormalStatusRow + 1;	
		if (m_SongDanceStatusRow > -1)
		{			
			m_ShortStatusRow = m_SongDanceStatusRow + 1;
		}
		if (m_TriggerSkillRow > -1)
		{
			m_ShortStatusRow = m_TriggerSkillRow + 1;
		}
		if (m_DebuffRow > -1)
		{
			m_ShortStatusRow = m_DebuffRow + 1;
		}
	}

	UpdateWindowSize();



	/*
	 *이전 코드.
	for (i=0; i<Max; i++)
	{
		ParseItemIDWithIndex(param, info.ID, i);
		ParseInt(param, "SkillLevel_" $ i, info.Level);
		ParseInt(param, "RemainTime_" $ i, info.RemainTime);
		ParseString(param, "Name_" $ i, info.Name);
		ParseString(param, "IconName_" $ i, info.IconName);
		ParseString(param, "Description_" $ i, info.Description);
		//debug("ID : " $ i $ "info.RemainTime : " $ info.RemainTime $ "info.Name :" $ info.Name);
		//temp1 = Asc(info.Name);
		//debug("ASCII : " $ temp1);

		// 이 이하에서는 스킬효과들의 표시 순서를 결정합니다.
		// 이제 주의할 점이 있습니다.
		// 클라이언트로부터 전해지는 데이터에 담긴 버프들의 순서는
		//	1. 일반 버프 (m_NormalStatusRow)
		//	2. 디버프	(m_DebuffRow)
		//	3. 송/댄스	(m_SongDanceStatusRow)
		//	4. 발동 버프 (m_TriggerSkillRow)
		// 입니다. 그러나, 실제 클라이언트 화면에 보여줘야 할 스킬효과들의 순서는
		//	1. 일반 버프
		//	2. 송/댄스
		//	3. 발동 버프
		//	4. 디버프
		// 입니다.
		// 따라서 스킬효과를 표시할 때 주의를 요합니다.
		// 이하 ***이 달린 주석은 위 상황을 해결하기 위한 주석이므로 참고하시면 되겠습니다.
		// - by gorillazin - 발동 버프 슬롯 분리 10.06.01.
		if (IsValidItemID(info.ID))                                                                                                             
		{
			debug( info.Name $ "IsSongDance>>>>" $ string(IsSongDance( info.ID, info.Level)) );
			if (IsSongDance( info.ID, info.Level))
			{
				debug("/////////////////songdance come in./////////////////" $ string(m_NormalStatusRow));				
				if (m_SongDanceStatusRow == -1)
				{
					m_SongDanceStatusRow = m_NormalStatusRow +1;
					StatusIcon.InsertRow(m_SongDanceStatusRow);

					if (m_DebuffRow > -1)
					{
						m_DebuffRow++;
					}
				}
				
				StatusIcon.AddCol(m_SongDanceStatusRow, info);
				debug("normalRow = " $ m_NormalStatusRow $ ", songRow = " $ m_SongDanceStatusRow $ ", triggerRow = " $ m_TriggerSkillRow $ ", debuffRow = " $ m_DebuffRow);
			}
			else if (IsTriggerSkill(info.ID, info.Level))
			{
				//debug("/////////////////trigger come in./////////////////");
				if (m_TriggerSkillRow == -1 && m_SongDanceStatusRow == -1)
				{
					m_TriggerSkillRow = m_NormalStatusRow + 1;
					StatusIcon.InsertRow(m_TriggerSkillRow);

					if (m_DebuffRow > -1)
					{
						m_DebuffRow++;
					}
				}
				else if (m_TriggerSkillRow == -1 && m_SongDanceStatusRow > -1)
				{
					m_TriggerSkillRow = m_SongDanceStatusRow +1;
					StatusIcon.InsertRow(m_TriggerSkillRow);

					if (m_DebuffRow > -1)
					{
						m_DebuffRow++;
					}
				}

				if (TriggerBuffCount == NSTATUSICON_MAXCOL)
				{
					m_TriggerSkillRow++;
					StatusIcon.InsertRow(m_TriggerSkillRow);

					if (m_DebuffRow > -1)
					{
						m_DebuffRow++;
					}
				}

				StatusIcon.AddCol(m_TriggerSkillRow, info);

				TriggerBuffCount++;
				//debug("normalRow = " $ m_NormalStatusRow $ ", songRow = " $ m_SongDanceStatusRow $ ", triggerRow = " $ m_TriggerSkillRow $ ", debuffRow = " $ m_DebuffRow);
			}
			else if (GetDebuffType( info.ID, info.Level) != 0)
			{
				// 0 디버프 아님, 1 보통의 디버프, 2 행동불능상태 디버프 
				//debug("/////////////////debuff come in./////////////////");
				if (m_DebuffRow == -1 && m_SongDanceStatusRow == -1 && m_TriggerSkillRow == -1)
				{
					m_DebuffRow = m_NormalStatusRow + 1;
					StatusIcon.InsertRow(m_DebuffRow);
				}
				else if (m_DebuffRow == -1 && m_SongDanceStatusRow > -1 && m_TriggerSkillRow == -1)
				{					
					m_DebuffRow = m_SongDanceStatusRow + 1;
					StatusIcon.InsertRow(m_DebuffRow);
				}
				else if (m_DebuffRow == -1 && m_SongDanceStatusRow == -1 && m_TriggerSkillRow > -1)
				{
					m_DebuffRow = m_TriggerSkillRow + 1;
					StatusIcon.InsertRow(m_DebuffRow);
				}
				else if (m_DebuffRow == -1 && m_SongDanceStatusRow > -1 && m_TriggerSkillRow > -1)
				{
					m_DebuffRow = m_TriggerSkillRow + 1;
					StatusIcon.InsertRow(m_DebuffRow);
				}

				if ( DeBuffCnt%NSTATUSICON_MAXCOL == 0 )
				{
					m_DebuffRow++;
					StatusIcon.InsertRow(m_DebuffRow);
				}

				StatusIcon.AddCol(m_DebuffRow, info);

				DeBuffCnt++;
				//debug("normalRow = " $ m_NormalStatusRow $ ", songRow = " $ m_SongDanceStatusRow $ ", triggerRow = " $ m_TriggerSkillRow $ ", debuffRow = " $ m_DebuffRow);
			}
			else 
			{				
				//debug("/////////////////normal come in./////////////////");
				if (BuffCnt%NSTATUSICON_MAXCOL == 0)
				{
					m_NormalStatusRow++;
					StatusIcon.InsertRow(m_NormalStatusRow);
				}
	
				StatusIcon.AddCol(m_NormalStatusRow, info);	
				
				BuffCnt++;
			}
		}		
	}
	*/
}

//Etc Status 추가 960
function HandleAddEtcStatus(string param)
{
	local int i;
	local int Max;
	local int BuffCnt;
	local int CurRow;
	local bool bNewRow;
	local StatusIconInfo info;
	
	//EtcStatus 초기화
	ClearStatus(true, false);
	//~ ClearStatus(true, true);
	//info 초기화
	info.Size = 24;
	info.BackTex = "L2UI.EtcWndBack.AbnormalBack";
	info.bShow = true;
	info.bEtcItem = true;
	info.bShortItem = false;

	//추가 시작점(Normal아이템 다음줄, Short아이템 다음 열에 추가한다)

	if (m_ShortStatusRow > -1)
	{
		bNewRow = false;
		CurRow = m_ShortStatusRow;
	}
	else 
	{
		bNewRow = true;
		CurRow = m_NormalStatusRow;
		if (m_SongDanceStatusRow > -1)
		{
			//CurRow= m_SongDanceStatusRow;
			CurRow++;
		}		
		if (m_DebuffRow > -1)
		{
			//CurRow = m_DebuffRow;
			CurRow++;
		}
		if (m_TriggerSkillRow > -1)
		{
			//CurRow = m_TriggerSkillRow;
			CurRow++;
		}
	}

	BuffCnt = 0;
	ParseInt(param, "Max", Max);
	for (i=0; i<Max; i++)
	{
		ParseItemIDWithIndex(param, info.ID, i);
		ParseInt(param, "SkillLevel_" $ i, info.Level);
		
		ParseInt(param, "RemainTime_" $ i, info.RemainTime);
		ParseString(param, "Name_" $ i, info.Name);
		ParseString(param, "IconName_" $ i, info.IconName);
		ParseString(param, "Description_" $ i, info.Description);
		
		if (IsValidItemID(info.ID))
		{
			//Etc아이템은 최대 한 행에만 표시한다.(Short아이템 뒤에...)
			if (bNewRow)
			{
				bNewRow = !bNewRow;
				CurRow++;
				StatusIcon.InsertRow(CurRow);
			}
			StatusIcon.AddCol(CurRow, info);
			m_EtcStatusRow = CurRow;
			BuffCnt++;
		}
	}
	UpdateWindowSize();
}

//Short Status 추가
function HandleAddShortStatus(string param)
{
	local int i;
	local int Max;
	local int BuffCnt;
	local int CurRow;
	local int CurCol;
	local bool bNewRow;
	local StatusIconInfo info;
	
	//ShortStatus 초기화
	ClearStatus(false, true);
	//~ ClearStatus(true, true);
	//info 초기화
	info.Size = 24;
	info.BackTex = "L2UI.EtcWndBack.AbnormalBack";
	info.bShow = true;
	info.bEtcItem = false;
	info.bShortItem = true;
	
/* 		m_DebuffRow = -1;
	m_NormalStatusRow = -1;
	m_EtcStatusRow = -1;
	m_ShortStatusRow = -1;
	m_SongDanceStatusRow = -1;
	m_bOnCurState = false;
	 */
	//추가 시작점(Normal아이템 다음줄, Etc아이템 전에 추가한다)
	CurCol = -1;
	
	if (m_EtcStatusRow>-1)
	{
		bNewRow = false;
		CurRow = m_EtcStatusRow;
	}
	else
	{
		bNewRow = true;
		CurRow = m_NormalStatusRow;
		if (m_SongDanceStatusRow > -1)
		{
			CurRow= m_SongDanceStatusRow;
		}
		if (m_TriggerSkillRow > -1)
		{
			CurRow = m_TriggerSkillRow;
		}
		if (m_DebuffRow > -1)
		{
			CurRow= m_DebuffRow;
		}
	}

	//debug("//////////////////////////test_short////////////////////////");
	//debug("normalRow = " $ m_NormalStatusRow $ ", songRow = " $ m_SongDanceStatusRow $ ", triggerRow = " $ m_TriggerSkillRow $ ", debuffRow = " $ m_DebuffRow);
	//debug("short_curRow before = " $ CurRow);
	
	//~ if (m_NormalStatusRow>-1 && m_EtcStatusRow>-1 )
	//~ {
		
		//~ bNewRow = false;
		//~ CurRow = m_EtcStatusRow;
		//~ debug ("CurRow_proc1" @ CurRow @ m_ShortStatusRow);
	//~ }
	//~ else if  (m_NormalStatusRow>-1 && m_EtcStatusRow<0)
	//~ {
		//~ bNewRow = true;
		//~ CurRow = m_EtcStatusRow;
		//~ debug ("CurRow_proc2" @ CurRow @ m_ShortStatusRow);
	//~ }
	//~ else if  (m_NormalStatusRow<0 && m_EtcStatusRow <0 )
	//~ {
		//~ bNewRow = true;
		//~ CurRow = m_EtcStatusRow;
		//~ debug ("CurRow_proc3" @ CurRow @ m_ShortStatusRow);
	//~ }
	//~ else  if  (m_NormalStatusRow<0 && m_EtcStatusRow >-1)
	//~ {
		//~ bNewRow = false;
		//~ CurRow = m_EtcStatusRow;
		//~ debug ("CurRow_proc4" @ CurRow @ m_ShortStatusRow);
	//~ }
	
	//~ debug ("CurRow" @ CurRow);
	
	BuffCnt = 0;
	ParseInt(param, "Max", Max);
	for (i=0; i<Max; i++)
	{
		ParseItemIDWithIndex(param, info.ID, i);
		ParseInt(param, "SkillLevel_" $ i, info.Level);
		ParseInt(param, "SkillSubLevel_" $ i, info.SubLevel);
		ParseInt(param, "RemainTime_" $ i, info.RemainTime);
		ParseString(param, "Name_" $ i, info.Name);
		ParseString(param, "IconName_" $ i, info.IconName);
		ParseString(param, "Description_" $ i, info.Description);
			
		if (IsValidItemID(info.ID))
		{
			//Short아이템은 최대 한 행에만 표시한다.(Etc아이템과 함께..)
			if (bNewRow)
			{
				bNewRow = !bNewRow;
				CurRow++;	
				StatusIcon.InsertRow(CurRow);
			}
			CurCol++;
			StatusIcon.InsertCol(CurRow, CurCol, info);

			//debug("short_curRow after = " $ CurRow);
			
			m_ShortStatusRow = CurRow;
			
			BuffCnt++;
		}
	}
	UpdateWindowSize();	
}

//윈도우 사이즈 갱신
function UpdateWindowSize()
{
	local int RowCount;
	local Rect rectWnd;
	
	RowCount = StatusIcon.GetRowCount();
	if (RowCount>0)
	{
		//현재 GameState가 아니면 윈도우를 보이지 않는다.
		if (m_bOnCurState && GetGameStateName() != "TRAININGROOMSTATE") //branch121212
		{
			Me.ShowWindow();			
		}
		else
		{
			Me.HideWindow();
		}
		
		//윈도우 사이즈 변경
		rectWnd = StatusIcon.GetRect();
		Me.SetWindowSize(rectWnd.nWidth + NSTATUSICON_FRAMESIZE, rectWnd.nHeight);
		
		//세로 프레임 사이즈 변경
		Me.SetFrameSize(NSTATUSICON_FRAMESIZE, rectWnd.nHeight);	
	}
	else
	{
		Me.HideWindow();
	}
}

//언어 변경 처리
function HandleLanguageChanged()
{
	local int i;
	local int j;
	local int RowCount;
	local int ColCount;
	local StatusIconInfo info;
	
	RowCount = StatusIcon.GetRowCount();
	for (i=0; i<RowCount; i++)
	{
		ColCount = StatusIcon.GetColCount(i);
		for (j=0; j<ColCount; j++)
		{
			StatusIcon.GetItem(i, j, info);
			if (IsValidItemID(info.ID))
			{
				info.Name = class'UIDATA_SKILL'.static.GetName( info.ID, info.Level, info.SubLevel );
				info.Description = class'UIDATA_SKILL'.static.GetDescription( info.ID, info.Level, info.SubLevel  );
				StatusIcon.SetItem(i, j, info);
			}
		}
	}
}

// 스킬의 클릭
function OnClickItem( string strID, int index )
{	
	local int row;
	local int col;
	local StatusIconInfo info;
	local SkillInfo skillInfo;		// 스킬 정보. 버프스킬인지 확인해야 하니까
	
	col = index / 10;
	row = index - (col * 10);
	
	StatusIcon.GetItem(row, col, info);

	// ID를 가지고 스킬의 정보를 얻어온다. 없으면 패배
	if( !GetSkillInfo( info.ID.ClassID, info.Level, info.SubLevel, skillInfo ) )
	{
		//debug("ERROR - no skill info!!");
		return;
	}	
	
	if ( InStr( strID ,"StatusIcon" ) > -1 )
	{
		//버프 취소 요청
		if (skillInfo.Debuff == 0 && skillInfo.OperateType == 1) 		
		{	
			RequestDispel(info.ServerID, info.ID, info.Level, info.SubLevel);	
		}
		//강화 스킬인 경우에만 버프 취소가 가능합니다. 
		else												
		{	
			AddSystemMessage(2318);	
		}	
	}
}
defaultproperties
{
}
