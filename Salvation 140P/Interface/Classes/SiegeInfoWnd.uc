class SiegeInfoWnd extends UICommonAPI;

var bool	m_bShow;

var int		m_CastleID;
var string	m_CastleName;
var int		m_PlayerClanID;
var bool	m_IsCastleOwner;
var int		m_SiegeTime;
var array<int> m_SelectableTimeArray;

var bool	m_IsExistMyClanIDinAttackSide;
var bool	m_IsExistMyClanIDinDefenseSide;

var int		m_AcceptedClan;
var int		m_WaitingClan;

//For DialogBox
var int		m_DialogClanID;
//var int		m_DialogSelectedTimeID; 일정 주기 형식으로 변경 12.07

//Handle List
var WindowHandle	m_wndTop;
var TabHandle		TabCtrl;

//MainInfo
var TextBoxHandle	txtCastleName;
var TextBoxHandle	txtOwnerName;
var TextBoxHandle	txtClanName;
var TextBoxHandle	txtAllianceName;
var TextureHandle	texClan;
var TextureHandle	texAlliance;

//Date Tab
var TextBoxHandle	txtCurTime;
var TextBoxHandle	txtSiegeTime;
//var ComboBoxHandle	cboTime;

//Attack Tab
var ListCtrlHandle	lstAttackClan;
var TextBoxHandle	txtAttackCount;
var ButtonHandle	btnAttackApply;
var ButtonHandle	btnAttackCancel;

//Defense Tab
var ListCtrlHandle	lstDefenseClan;
var TextBoxHandle	txtDefenseCount;
var ButtonHandle	btnDefenseApply;
var ButtonHandle	btnDefenseCancel;
var ButtonHandle	btnDefenseReject;
var ButtonHandle	btnDefenseConfirm;

var TextureHandle   tabLineBgTail;


function OnRegisterEvent()
{
	RegisterEvent( EV_DialogOK );
	
	RegisterEvent( EV_SiegeInfo );
	RegisterEvent( EV_SiegeInfoClanListStart );
	RegisterEvent( EV_SiegeInfoClanList );
	RegisterEvent( EV_SiegeInfoClanListEnd );
	RegisterEvent( EV_SiegeInfoSelectableTime );
}

function OnLoad()
{
	SetClosingOnESC();
	
	m_bShow = false;
	m_CastleID = 0;
	m_CastleName = "";
	m_SiegeTime = 0;
	m_AcceptedClan = 0;
	m_WaitingClan = 0;
	
	m_wndTop = GetWindowHandle( "SiegeInfoWnd" );
	TabCtrl = GetTabHandle( "SiegeInfoWnd.TabCtrl" );
	
	//MainInfo
	txtCastleName = GetTextBoxHandle( "SiegeInfoWnd.txtCastleName" );
	txtOwnerName = GetTextBoxHandle( "SiegeInfoWnd.txtOwnerName" );
	txtClanName = GetTextBoxHandle( "SiegeInfoWnd.txtClanName" );
	txtAllianceName = GetTextBoxHandle( "SiegeInfoWnd.txtAllianceName" );
	texClan = GetTextureHandle( "SiegeInfoWnd.texClan" );
	texAlliance = GetTextureHandle( "SiegeInfoWnd.texAlliance" );
	
	//Date Tab
	txtCurTime = GetTextBoxHandle( "SiegeInfoWnd.SiegeInfoWnd_Date.txtCurTime" );
	txtSiegeTime = GetTextBoxHandle( "SiegeInfoWnd.SiegeInfoWnd_Date.txtSiegeTime" );
	//cboTime = GetComboBoxHandle( "SiegeInfoWnd.SiegeInfoWnd_Date.cboTime" );
	
	//Attack Tab
	lstAttackClan = GetListCtrlHandle( "SiegeInfoWnd.SiegeInfoWnd_Party1.lstClan" );
	txtAttackCount = GetTextBoxHandle( "SiegeInfoWnd.SiegeInfoWnd_Party1.txtCount" );
	btnAttackApply = GetButtonHandle( "SiegeInfoWnd.SiegeInfoWnd_Party1.btnAttackApply" );
	btnAttackCancel = GetButtonHandle( "SiegeInfoWnd.SiegeInfoWnd_Party1.btnAttackCancel" );
	
	//Attack Tab
	lstDefenseClan = GetListCtrlHandle( "SiegeInfoWnd.SiegeInfoWnd_Party2.lstClan" );
	txtDefenseCount = GetTextBoxHandle( "SiegeInfoWnd.SiegeInfoWnd_Party2.txtCount" );
	btnDefenseApply = GetButtonHandle( "SiegeInfoWnd.SiegeInfoWnd_Party2.btnDefenseApply" );
	btnDefenseCancel = GetButtonHandle( "SiegeInfoWnd.SiegeInfoWnd_Party2.btnDefenseCancel" );
	btnDefenseReject = GetButtonHandle( "SiegeInfoWnd.SiegeInfoWnd_Party2.btnDefenseReject" );
	btnDefenseConfirm = GetButtonHandle( "SiegeInfoWnd.SiegeInfoWnd_Party2.btnDefenseConfirm" );

	tabLineBgTail = GetTextureHandle ( "SiegeInfoWnd.tabLineBgTail");

	UpdateAttackCount();
	UpdateDefenseCount();

	
}

// 수정 없는 공성전인지를 받는 함수
function bool getDefenceTabVisibleByCastleID ( ) 
{	
	switch ( m_CastleID )
	{
	case 1 : // 글루디오 성
		return !getInstanceUIData().getIsClassicServer();
		break;
	}
	return true;
}

// 수성 정보 탭 끄고 키는 함수
function toggleDefenceTabVisible ( bool visible) 
{
	if ( visible )
	{		
		TabCtrl.SetButtonName(2, getSystemString (587));
		TabCtrl.SetDisable(2, false);		

		tabLineBgTail.SetWindowSize( 36 , 23);
	}
	else 
	{			
		TabCtrl.SetButtonDisableTexture(2, "L2UI_ct1.Misc_DF_Blank");
		TabCtrl.SetDisable(2, true);
		TabCtrl.SetButtonName(2, "");
		tabLineBgTail.SetWindowSize( 111 , 23);		
	}
}

function OnShow()
{		
	m_bShow = true;
}

function OnHide()
{
	m_bShow = false;
}

function OnEnterState( name a_PreStateName )
{
}

function OnEvent(int Event_ID, string param)
{
	if (Event_ID == EV_SiegeInfo)
	{
		HandleSiegeInfo(param);
	}
	else if (Event_ID == EV_SiegeInfoClanListStart)
	{
		HandleSiegeInfoClanListStart(param);
	}
	else if (Event_ID == EV_SiegeInfoClanList)
	{
		HandleSiegeInfoClanList(param);
	}
	else if (Event_ID == EV_SiegeInfoClanListEnd)
	{
		HandleSiegeInfoClanListEnd(param);
	}
	/*else if (Event_ID == EV_SiegeInfoSelectableTime) //일정 주기 형식으로 변경
	{
		HandleSiegeInfoSelectableTime(param);
	}*/
	else if (Event_ID == EV_DialogOK)
	{
		if (DialogIsMine())
		{
			//공성참가신청
			if (DialogGetID()==1)
			{
				class'SiegeAPI'.static.RequestJoinCastleSiege(m_CastleID, 1, 1);
			}
			//공성참가취소
			else if (DialogGetID()==2)
			{
				class'SiegeAPI'.static.RequestJoinCastleSiege(m_CastleID, 1, 0);
			}
			//수성참가신청
			else if (DialogGetID()==3)
			{
				class'SiegeAPI'.static.RequestJoinCastleSiege(m_CastleID, 0, 1);
			}
			//수성참가취소
			else if (DialogGetID()==4)
			{
				class'SiegeAPI'.static.RequestJoinCastleSiege(m_CastleID, 0, 0);
			}
			//수성참가거부
			else if (DialogGetID()==5)
			{
				if (m_DialogClanID>0)
				{
					class'SiegeAPI'.static.RequestConfirmCastleSiegeWaitingList(m_CastleID, m_DialogClanID, 0);
					m_DialogClanID = 0;
				}
			}
			//수성참가승인
			else if (DialogGetID()==6)
			{
				if (m_DialogClanID>0)
				{
					class'SiegeAPI'.static.RequestConfirmCastleSiegeWaitingList(m_CastleID, m_DialogClanID, 1);
					m_DialogClanID = 0;
				}
			}
			//공성시간 등록
			/* 일정 주기 형식으로 변경 12.07
			else if (DialogGetID()==7)
			{
				if (m_DialogSelectedTimeID>0)
				{
					class'SiegeAPI'.static.RequestSetCastleSiegeTime(m_CastleID, m_DialogSelectedTimeID);
					m_DialogSelectedTimeID = 0;
				}
			}*/
		}
	}
}

//공성시간 선택
/*function OnComboBoxItemSelected( String strID, int index ) //자동 시간 예정
{
	if (strID=="cboTime")
	{
		if (index>0)
		{
			m_DialogSelectedTimeID = m_SelectableTimeArray[index-1];
			DialogShow(DialogModalType_Modalless,DialogType_OKCancel, MakeFullSystemMsg(GetSystemMessage(663), cboTime.GetString(index), ""), string(Self));
			DialogSetID(7);
		}
	}
}*/

//초기화
function ClearInfo()
{
	local Rect rectWnd;
	rectWnd = m_wndTop.GetRect();
	
	m_CastleID = 0;
	m_CastleName = "";
	m_IsCastleOwner = false;
	m_SiegeTime = 0;
	
	txtCurTime.SetText("");
	txtSiegeTime.SetText("");
	txtCastleName.SetText("");
	txtOwnerName.SetText(GetSystemString(595));
	txtClanName.SetText("");
	txtAllianceName.SetText("");
	texClan.SetTexture("");
	texAlliance.SetTexture("");
	txtClanName.MoveTo(rectWnd.nX + 80, rectWnd.nY + 86);
	txtAllianceName.MoveTo(rectWnd.nX + 80, rectWnd.nY + 102);
	
	TabCtrl.SetTopOrder(0, true);
	
//	ClearTimeCombo();
}

function OnClickButton( string strID )
{
	switch( strID )
	{
	case "btnAttackApply":
		OnAttackApplyClick();
		break;
	case "btnAttackCancel":
		OnAttackCancelClick();
		break;
	case "btnDefenseApply":
		OnDefenseApplyClick();
		break;
	case "btnDefenseCancel":
		OnDefenseCancelClick();
		break;
	case "btnDefenseReject":
		OnDefenseRejectClick();
		break;
	case "btnDefenseConfirm":
		OnDefenseConfirmClick();
		break;
	/* 일정 시간 형식으로 변경 12.07
	 *case "TabCtrl0": 
		OnTabCtrl0Click();*/
	case "TabCtrl1":
		OnTabCtrl1Click();
		break;
	case "TabCtrl2":
		OnTabCtrl2Click();
		break;
	}
}

//공성참가신청
function OnAttackApplyClick()
{
	DialogShow(DialogModalType_Modalless,DialogType_OKCancel, MakeFullSystemMsg(GetSystemMessage(667), m_CastleName, ""), string(Self));
	DialogSetID(1);
}

//공성참가취소
function OnAttackCancelClick()
{
	DialogShow(DialogModalType_Modalless,DialogType_OKCancel, MakeFullSystemMsg(GetSystemMessage(669), m_CastleName, ""), string(Self));
	DialogSetID(2);
}

//수성참가신청
function OnDefenseApplyClick()
{
	DialogShow(DialogModalType_Modalless,DialogType_OKCancel, MakeFullSystemMsg(GetSystemMessage(668), m_CastleName, ""), string(Self));
	DialogSetID(3);
}

//수성참가취소
function OnDefenseCancelClick()
{
	DialogShow(DialogModalType_Modalless,DialogType_OKCancel, MakeFullSystemMsg(GetSystemMessage(669), m_CastleName, ""), string(Self));
	DialogSetID(4);
}

//수성참가거부
function OnDefenseRejectClick()
{
	local int		idx;
	local int		ClanID;
	local string	ClanName;
	local int		Status;
	local ECastleSiegeDefenderType DefenderType;
	local LVDataRecord record;
	
	idx = lstDefenseClan.GetSelectedIndex();
	if (idx>-1)
	{
		lstDefenseClan.GetRec(idx, record);
		ClanID = int(record.nReserved1);
		Status = int(record.nReserved2);
		DefenderType = ECastleSiegeDefenderType(Status);
		if (ClanID>0)
		{
			if (DefenderType==CSDT_WAITING_CONFIRM || DefenderType==CSDT_APPROVED)
			{
				ClanName = class'UIDATA_CLAN'.static.GetName(ClanID);
				m_DialogClanID = ClanID;
				DialogShow(DialogModalType_Modalless,DialogType_OKCancel, MakeFullSystemMsg(GetSystemMessage(670), ClanName, ""), string(Self));
				DialogSetID(5);
			}			
		}
	}
}

//수성참가승인
function OnDefenseConfirmClick()
{
	local int		idx;
	local int		ClanID;
	local string	ClanName;
	local int		Status;
	local ECastleSiegeDefenderType DefenderType;
	local LVDataRecord record;
	
	idx = lstDefenseClan.GetSelectedIndex();
	if (idx>-1)
	{
		lstDefenseClan.GetRec(idx, record);
		ClanID = int(record.nReserved1);
		Status = int(record.nReserved2);
		DefenderType = ECastleSiegeDefenderType(Status);
		if (ClanID>0)
		{
			if (DefenderType==CSDT_WAITING_CONFIRM)
			{
				ClanName = class'UIDATA_CLAN'.static.GetName(ClanID);
				m_DialogClanID = ClanID;
				DialogShow(DialogModalType_Modalless,DialogType_OKCancel, MakeFullSystemMsg(GetSystemMessage(671), ClanName, ""), string(Self));
				DialogSetID(6);
			}			
		}
	}
}

//공성일시 클릭
/*일정 시간 형식으로 변경 12.07
 *function OnTabCtrl0Click()
{
	UpdateTimeCombo();
}*/

//공성탭 클릭
function OnTabCtrl1Click()
{
	ClearAttackButton();
	class'SiegeAPI'.static.RequestCastleSiegeAttackerList(m_CastleID);
}

//수성탭 클릭
function OnTabCtrl2Click()
{
	ClearDefenseButton();
	class'SiegeAPI'.static.RequestCastleSiegeDefenderList(m_CastleID);
}

//공성 기본 정보
function HandleSiegeInfo(string param)
{
	local Rect rectWnd;
	
	local int		CastleID;
	local int		IsOwner;
	local string	OwnerName;
	local int		ClanID;
	local string	ClanName;
	local int		AllianceID;
	local string	AllianceName;
	local int		NowTime;
	local int		SiegeTime;
	
	local string	CastleName;
	local Texture	ClanCrestTexture;
	local Texture	AllianceCrestTexture;
	
	ClearInfo();
	rectWnd = m_wndTop.GetRect();
	
	ParseInt(param, "CastleID" ,CastleID);
	ParseInt(param, "IsOwner" ,IsOwner);
	if (IsOwner==1)
		m_IsCastleOwner = true;
	ParseString(param, "OwnerName" ,OwnerName);
	ParseInt(param, "ClanID" ,ClanID);
	ParseString(param, "ClanName" ,ClanName);
	ParseInt(param, "AllianceID" ,AllianceID);
	ParseString(param, "AllianceName" ,AllianceName);
	ParseInt(param, "NowTime" ,NowTime);
	ParseInt(param, "SiegeTime" ,SiegeTime);
	m_SiegeTime = SiegeTime;
	
	CastleName = GetCastleName(CastleID);
	m_CastleID = CastleID;
	m_CastleName = CastleName;
	
	//기본 정보 셋팅
	txtCastleName.SetText(CastleName);
	if (Len(OwnerName)>0)
		txtOwnerName.SetText(OwnerName);
	if (Len(ClanName)>0)
		txtClanName.SetText(ClanName);
	if (Len(AllianceName)>0)
		txtAllianceName.SetText(AllianceName);
	else
	{
		if (Len(ClanName)>0)
			txtAllianceName.SetText(GetSystemString(591));
	}
	
	//혈맹 텍스쳐 얻어오기
	if (ClanID>0)
	{
		if (class'UIDATA_CLAN'.static.GetCrestTexture(ClanID, ClanCrestTexture))
		{
			texClan.SetTextureWithObject(ClanCrestTexture);
			txtClanName.MoveTo(rectWnd.nX + 100, rectWnd.nY + 86);
		}
	}
	
	//동맹 텍스쳐 얻어오기
	if (AllianceID>0)
	{
		if (class'UIDATA_CLAN'.static.GetAllianceCrestTexture(ClanID, AllianceCrestTexture))
		{
			texAlliance.SetTextureWithObject(AllianceCrestTexture);
			txtAllianceName.MoveTo(rectWnd.nX + 100, rectWnd.nY + 102);
		}
	}
	
	//공성시간 정보
	if (NowTime>0)
		txtCurTime.SetText(ConvertTimetoStr(NowTime));
	if (SiegeTime>0)
		txtSiegeTime.SetText(ConvertTimetoStr(SiegeTime));
	else
	{
		if (!m_IsCastleOwner)
			txtSiegeTime.SetText(GetSystemString(584));
	}
	
	toggleDefenceTabVisible ( getDefenceTabVisibleByCastleID () );

	m_wndTop.ShowWindow();
	m_wndTop.SetFocus();
	
	//UpdateTimeCombo();//일정 시간 형식으로 변경
}

//공성 혈맹 리스트
function HandleSiegeInfoClanListStart(string param)
{
	local int Type;
	local UserInfo infUser;
	
	//일단 여기서 플레이어의 혈맹ID를 취득하장
	m_PlayerClanID = 0;
	if (GetPlayerInfo(infUser))
		m_PlayerClanID = infUser.nClanID;
	
	if (ParseInt(param, "Type", Type))
	{
		//Attacker
		if (Type==0)
		{
			lstAttackClan.DeleteAllItem();
			m_IsExistMyClanIDinAttackSide = false;
			UpdateAttackCount();
			ClearAttackButton();
		}
		//Defender
		else if (Type==1)
		{
			lstDefenseClan.DeleteAllItem();
			m_IsExistMyClanIDinDefenseSide = false;
			m_AcceptedClan = 0;
			m_WaitingClan = 0;
			UpdateDefenseCount();
			ClearDefenseButton();
		}
	}
}

function HandleSiegeInfoClanList(string param)
{
	local int Type;
	
	local int		ClanID;
	local string	ClanName;
	local string	AllianceName;
	local int		AllianceID;
	
	local int		Status;
	local ECastleSiegeDefenderType DefenderType;
	
	local LVDataRecord	record;
	local texture		texClan;
	local texture		texAlliance;
	
	record.LVDataList.length = 2;
	
	if (ParseInt(param, "Type", Type))
	{	
		ParseInt(param, "ClanID", ClanID);
		ParseString(param, "ClanName", ClanName);
		ParseInt(param, "AllianceID", AllianceID);
		ParseString(param, "AllianceName", AllianceName);
		ParseInt(param, "Status", Status);
		
		//Check Data
		if (ClanID<1)
			return;
		
		//Attacker
		if (Type==0)
		{
			//Check My ClanID
			if (m_PlayerClanID>0 && ClanID==m_PlayerClanID)
				m_IsExistMyClanIDinAttackSide = true;
				
			//Set Clan Info
			record.LVDataList[0].szData = ClanName;
			if (class'UIDATA_CLAN'.static.GetCrestTexture(ClanID, texClan))
			{
				record.LVDataList[0].arrTexture.Length = 1;
				record.LVDataList[0].arrTexture[0].objTex = texClan;
				record.LVDataList[0].arrTexture[0].X = 6;
				record.LVDataList[0].arrTexture[0].Y = 0;
				record.LVDataList[0].arrTexture[0].Width = 16;
				record.LVDataList[0].arrTexture[0].Height = 12;
				record.LVDataList[0].arrTexture[0].U = 0;
				record.LVDataList[0].arrTexture[0].V = 4;
			}
			
			//Set Alliance Info
			record.LVDataList[1].szData = AllianceName;
			if (AllianceID>0)
			{
				if (class'UIDATA_CLAN'.static.GetAllianceCrestTexture(ClanID, texAlliance))
				{
					record.LVDataList[1].arrTexture.Length = 1;
					record.LVDataList[1].arrTexture[0].objTex = texAlliance;
					record.LVDataList[1].arrTexture[0].X = 6;
					record.LVDataList[1].arrTexture[0].Y = 0;
					record.LVDataList[1].arrTexture[0].Width = 8;
					record.LVDataList[1].arrTexture[0].Height = 12;
					record.LVDataList[1].arrTexture[0].U = 0;
					record.LVDataList[1].arrTexture[0].V = 4;
				}
			}
			
			lstAttackClan.InsertRecord(record);
			UpdateAttackCount();
		}
		//Defender
		else if (Type==1)
		{
			//Check My ClanID
			if (m_PlayerClanID>0 && ClanID==m_PlayerClanID)
				m_IsExistMyClanIDinDefenseSide = true;
				
			//Set Record Info
			record.nReserved1 = ClanID;
			record.nReserved2 = Status;
				
			record.LVDataList[0].szData = ClanName;
			if (class'UIDATA_CLAN'.static.GetCrestTexture(ClanID, texClan))
			{
				record.LVDataList[0].arrTexture.Length = 1;
				record.LVDataList[0].arrTexture[0].objTex = texClan;
				record.LVDataList[0].arrTexture[0].X = 6;
				record.LVDataList[0].arrTexture[0].Y = 0;
				record.LVDataList[0].arrTexture[0].Width = 16;
				record.LVDataList[0].arrTexture[0].Height = 12;
				record.LVDataList[0].arrTexture[0].U = 0;
				record.LVDataList[0].arrTexture[0].V = 4;
			}
			
			DefenderType = ECastleSiegeDefenderType(Status);
			switch( DefenderType )
			{
			case CSDT_CASTLE_OWNER:
				record.LVDataList[1].szData = GetSystemString(588);
				m_WaitingClan++;
				break;
			case CSDT_WAITING_CONFIRM: 
				record.LVDataList[1].szData = GetSystemString(568);
				m_WaitingClan++;
				break;
			case CSDT_APPROVED: 
				record.LVDataList[1].szData = GetSystemString(567);
				m_AcceptedClan++;
				break;
			case CSDT_REJECTED: 
				record.LVDataList[1].szData = GetSystemString(579);
				break;
			}
			lstDefenseClan.InsertRecord(record);
			UpdateDefenseCount();
		}
	}
}

function HandleSiegeInfoClanListEnd(string param)
{
	local int Type;
	
	if (ParseInt(param, "Type", Type))
	{
		//Attacker
		if (Type==0)
		{
			UpdateAttackButton();
		}
		//Defender
		else if (Type==1)
		{
			UpdateDefenseButton();
		}
	}
}

//공성 가능 시간(성주일때만 날라온다)
/*일정 주기로 수정 12.07
function HandleSiegeInfoSelectableTime(string param)
{
	local int		TimeID;
	local string	TimeString;
	
	if (ParseInt(param, "TimeID", TimeID))
	{
		if (TimeID>0)
		{
			TimeString = ConvertTimetoStr(TimeID);
			cboTime.AddString(TimeString);
			m_SelectableTimeArray.Insert(m_SelectableTimeArray.Length, 1);
			m_SelectableTimeArray[m_SelectableTimeArray.Length-1] = TimeID;
		}
	}
}*/

function UpdateAttackCount()
{
	txtAttackCount.SetText(GetSystemString(576) $ " : " $ lstAttackClan.GetRecordCount());
}

function UpdateDefenseCount()
{
	txtDefenseCount.SetText(GetSystemString(577) $ "/" $ GetSystemString(578) $ " : " $ m_AcceptedClan $ "/" $ m_WaitingClan);
}

/*일정 주기 형식으로 변경 12.07
function UpdateTimeCombo()
{
	if (m_IsCastleOwner && m_SiegeTime<1)
		cboTime.ShowWindow();
	else
		cboTime.HideWindow();
}
*/

function UpdateAttackButton()
{
	if (!m_IsCastleOwner)
	{
		if (m_IsExistMyClanIDinAttackSide)
		{
			btnAttackCancel.ShowWindow();
		}
		else
		{
			btnAttackApply.ShowWindow();
		}
	}
}

function UpdateDefenseButton()
{
	//~ debug("성주정보:"@ m_IsCastleOwner);
	if (!m_IsCastleOwner)
	{
		if (m_IsExistMyClanIDinDefenseSide)
		{
			btnDefenseCancel.ShowWindow();
		}
		else
		{
			btnDefenseApply.ShowWindow();
		}
	}
	else
	{
		//~ debug("성주정보:"@ m_IsCastleOwner);
		btnDefenseReject.ShowWindow();
		btnDefenseConfirm.ShowWindow();
	}	
}

/* 일정 주기 형식으로 변경 12.07
function ClearTimeCombo()
{
	m_SelectableTimeArray.Remove(0, m_SelectableTimeArray.Length);
	cboTime.Clear();
	cboTime.SYS_AddString(585);
	cboTime.SetSelectedNum(0);
	cboTime.HideWindow();
}*/

function ClearAttackButton()
{
	btnAttackApply.HideWindow();
	btnAttackCancel.HideWindow();
}

function ClearDefenseButton()
{
	btnDefenseApply.HideWindow();
	btnDefenseCancel.HideWindow();
	btnDefenseReject.HideWindow();
	btnDefenseConfirm.HideWindow();
}


/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	OnHide();
	class'UIAPI_WINDOW'.static.HideWindow("SiegeInfoWnd");		
}
defaultproperties
{
}
