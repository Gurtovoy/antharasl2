class DominionWarInfoWnd extends UICommonAPI;

var string ClanTexList[17];

var WindowHandle Me;
var WindowHandle DeclaredWarInfo;
var ListCtrlHandle ListCtrlTerritoryWarList;
//~ var TextureHandle tabLineBg;
var TextBoxHandle txtCurrentTerritory;
var TextBoxHandle txtLordNameTitle;
var TextBoxHandle txtLordName;
var TextBoxHandle txtClanNameTitle;
var TextBoxHandle txtClanName;
var TextBoxHandle txtAlleyNameTitle;
var TextBoxHandle txtAlleyName;
var TabHandle TabCtrl;
//~ var TextureHandle tabLineBg;
var TextBoxHandle txtTerritoryWarTimeTitle;
var TextBoxHandle txtCurrentTimeTitle;
var TextBoxHandle txtTerritoryWarTime;
var ButtonHandle btnClose;
var TextBoxHandle txtCurrentTime;
var ButtonHandle btnApplyMachinery;
var ButtonHandle btnClanApplyBtn;
var WindowHandle AttendeeInfo;
var ListCtrlHandle ListCtrlClanList;
var ButtonHandle btnAcceptClan;
var TextBoxHandle txtTotalClanCountHead;
var TextBoxHandle txtTotalMachineryCountHead;
var TextBoxHandle txtTotalClanCount;
var TextBoxHandle txtTotalMachineryCount;
//~ var TextureHandle tabLineBg1;
var TextureHandle GroupBoxBg3;
var TextureHandle GroupBoxBg1;
var TextureHandle GroupBoxBg2;

var int 	m_DominionID;
var String  m_DominionName;
var bool 	m_ClanBtnBool;
var bool	m_MachineryBtnBool;

function InitClanTexName()
{
	ClanTexList[0] = "L2UI_CT1.CLAN_DF_TERRITORYWARICON_ADEN";
	ClanTexList[1] = "L2UI_CT1.CLAN_DF_TERRITORYWARICON_DION";
	ClanTexList[2] = "L2UI_CT1.CLAN_DF_TERRITORYWARICON_GIRAN";
	ClanTexList[3] = "L2UI_CT1.CLAN_DF_TERRITORYWARICON_GLUDIO";
	ClanTexList[4] = "L2UI_CT1.CLAN_DF_TERRITORYWARICON_GODARD";
	ClanTexList[5] = "L2UI_CT1.CLAN_DF_TERRITORYWARICON_INNADRIL";
	ClanTexList[6] = "L2UI_CT1.CLAN_DF_TERRITORYWARICON_OREN";
	ClanTexList[7] = "L2UI_CT1.CLAN_DF_TERRITORYWARICON_RUNE";
	ClanTexList[8] = "L2UI_CT1.CLAN_DF_TERRITORYWARICON_SCHUTTGART";

}

function OnLoad()
{
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	if(CREATE_ON_DEMAND==0)
		InitHandle();
	else
		InitHandleCOD();		

	Load();
	m_ClanBtnBool = true;
	m_MachineryBtnBool = true;
	btnClanApplyBtn.SetButtonName(1957);
	btnApplyMachinery.SetButtonName(1958);
	Me.SetWindowTitle(GetSystemString(1776));
}


function OnRegisterEvent()
{
	registerEvent( EV_ShowDominionWarJoinListStart );
	registerEvent( EV_ResultJoinDominionWar   );
	//~ registerEvent( EV_DominionInfoCnt  );
	//~ registerEvent( EV_DominionInfo );
	//~ registerEvent( EV_DominionsOwnPos   );
	registerEvent( EV_ShowDominionWarJoinListEnemyDominionInfo );
	registerEvent( EV_ShowDominionWarJoinListEnd );
}

function InitHandle()
{
	
	Me = GetHandle( "DominionWarInfoWnd" );
	DeclaredWarInfo = GetHandle( "DominionWarInfoWnd.DeclaredWarInfo" );
	ListCtrlTerritoryWarList = ListCtrlHandle ( GetHandle( "DominionWarInfoWnd.DeclaredWarInfo.ListCtrlTerritoryWarList" ) );
	//~ tabLineBg = TextureHandle ( GetHandle( "DominionWarInfoWnd.DeclaredWarInfo.tabLineBg" ) );
	txtCurrentTerritory = TextBoxHandle ( GetHandle( "DominionWarInfoWnd.txtCurrentTerritory" ) );
	txtLordNameTitle = TextBoxHandle ( GetHandle( "DominionWarInfoWnd.txtLordNameTitle" ) );
	txtLordName = TextBoxHandle ( GetHandle( "DominionWarInfoWnd.txtLordName" ) );
	txtClanNameTitle = TextBoxHandle ( GetHandle( "DominionWarInfoWnd.txtClanNameTitle" ) );
	txtClanName = TextBoxHandle ( GetHandle( "DominionWarInfoWnd.txtClanName" ) );
	txtAlleyNameTitle = TextBoxHandle ( GetHandle( "DominionWarInfoWnd.txtAlleyNameTitle" ) );
	txtAlleyName = TextBoxHandle ( GetHandle( "DominionWarInfoWnd.txtAlleyName" ) );
	TabCtrl = TabHandle ( GetHandle( "DominionWarInfoWnd.TabCtrl" ) );
	//~ tabLineBg = TextureHandle ( GetHandle( "DominionWarInfoWnd.tabLineBg" ) );
	txtTerritoryWarTimeTitle = TextBoxHandle ( GetHandle( "DominionWarInfoWnd.txtTerritoryWarTimeTitle" ) );
	txtCurrentTimeTitle = TextBoxHandle ( GetHandle( "DominionWarInfoWnd.txtCurrentTimeTitle" ) );
	txtTerritoryWarTime = TextBoxHandle ( GetHandle( "DominionWarInfoWnd.txtTerritoryWarTime" ) );
	btnClose = ButtonHandle ( GetHandle( "DominionWarInfoWnd.btnClose" ) );
	txtCurrentTime = TextBoxHandle ( GetHandle( "DominionWarInfoWnd.txtCurrentTime" ) );
	btnApplyMachinery = ButtonHandle ( GetHandle( "DominionWarInfoWnd.btnApplyMachinery" ) );
	btnClanApplyBtn = ButtonHandle ( GetHandle( "DominionWarInfoWnd.btnClanApplyBtn" ) );
	AttendeeInfo = GetHandle( "DominionWarInfoWnd.AttendeeInfo" );
	ListCtrlClanList = ListCtrlHandle ( GetHandle( "DominionWarInfoWnd.AttendeeInfo.ListCtrlClanList" ) );
	btnAcceptClan = ButtonHandle ( GetHandle( "DominionWarInfoWnd.AttendeeInfo.btnAcceptClan" ) );
	txtTotalClanCountHead = TextBoxHandle ( GetHandle( "DominionWarInfoWnd.AttendeeInfo.txtTotalClanCountHead" ) );
	txtTotalMachineryCountHead = TextBoxHandle ( GetHandle( "DominionWarInfoWnd.AttendeeInfo.txtTotalMachineryCountHead" ) );
	txtTotalClanCount = TextBoxHandle ( GetHandle( "DominionWarInfoWnd.AttendeeInfo.txtTotalClanCount" ) );
	txtTotalMachineryCount = TextBoxHandle ( GetHandle( "DominionWarInfoWnd.AttendeeInfo.txtTotalMachineryCount" ) );
	//~ tabLineBg1 = TextureHandle ( GetHandle( "DominionWarInfoWnd.AttendeeInfo.tabLineBg1" ) );
	GroupBoxBg3 = TextureHandle ( GetHandle( "DominionWarInfoWnd.GroupBoxBg3" ) );
	GroupBoxBg1 = TextureHandle ( GetHandle( "DominionWarInfoWnd.GroupBoxBg1" ) );
	GroupBoxBg2 = TextureHandle ( GetHandle( "DominionWarInfoWnd.GroupBoxBg2" ) );
}

function InitHandleCOD()
{
	
	Me = GetWindowHandle( "DominionWarInfoWnd" );
	DeclaredWarInfo = GetWindowHandle( "DominionWarInfoWnd.DeclaredWarInfo" );
	ListCtrlTerritoryWarList = GetListCtrlHandle (  "DominionWarInfoWnd.DeclaredWarInfo.ListCtrlTerritoryWarList"  );
	//~ tabLineBg = GetTextureHandle (  "DominionWarInfoWnd.DeclaredWarInfo.tabLineBg"  );
	txtCurrentTerritory = GetTextBoxHandle (  "DominionWarInfoWnd.txtCurrentTerritory"  );
	txtLordNameTitle = GetTextBoxHandle (  "DominionWarInfoWnd.txtLordNameTitle"  );
	txtLordName = GetTextBoxHandle (  "DominionWarInfoWnd.txtLordName"  );
	txtClanNameTitle = GetTextBoxHandle (  "DominionWarInfoWnd.txtClanNameTitle"  );
	txtClanName = GetTextBoxHandle (  "DominionWarInfoWnd.txtClanName"  );
	txtAlleyNameTitle = GetTextBoxHandle (  "DominionWarInfoWnd.txtAlleyNameTitle"  );
	txtAlleyName = GetTextBoxHandle (  "DominionWarInfoWnd.txtAlleyName"  );
	TabCtrl = GetTabHandle (  "DominionWarInfoWnd.TabCtrl"  );
	//~ tabLineBg = GetTextureHandle (  "DominionWarInfoWnd.tabLineBg"  );
	txtTerritoryWarTimeTitle = GetTextBoxHandle (  "DominionWarInfoWnd.txtTerritoryWarTimeTitle"  );
	txtCurrentTimeTitle = GetTextBoxHandle (  "DominionWarInfoWnd.txtCurrentTimeTitle"  );
	txtTerritoryWarTime = GetTextBoxHandle (  "DominionWarInfoWnd.txtTerritoryWarTime"  );
	btnClose = GetButtonHandle (  "DominionWarInfoWnd.btnClose"  );
	txtCurrentTime = GetTextBoxHandle (  "DominionWarInfoWnd.txtCurrentTime"  );
	btnApplyMachinery = GetButtonHandle (  "DominionWarInfoWnd.btnApplyMachinery"  );
	btnClanApplyBtn = GetButtonHandle (  "DominionWarInfoWnd.btnClanApplyBtn"  );
	AttendeeInfo = GetWindowHandle( "DominionWarInfoWnd.AttendeeInfo" );
	ListCtrlClanList = GetListCtrlHandle (  "DominionWarInfoWnd.AttendeeInfo.ListCtrlClanList"  );
	btnAcceptClan = GetButtonHandle (  "DominionWarInfoWnd.AttendeeInfo.btnAcceptClan"  );
	txtTotalClanCountHead = GetTextBoxHandle (  "DominionWarInfoWnd.AttendeeInfo.txtTotalClanCountHead"  );
	txtTotalMachineryCountHead = GetTextBoxHandle (  "DominionWarInfoWnd.AttendeeInfo.txtTotalMachineryCountHead"  );
	txtTotalClanCount = GetTextBoxHandle (  "DominionWarInfoWnd.AttendeeInfo.txtTotalClanCount"  );
	txtTotalMachineryCount = GetTextBoxHandle (  "DominionWarInfoWnd.AttendeeInfo.txtTotalMachineryCount"  );
	//~ tabLineBg1 = GetTextureHandle (  "DominionWarInfoWnd.AttendeeInfo.tabLineBg1"  );
	GroupBoxBg3 = GetTextureHandle (  "DominionWarInfoWnd.GroupBoxBg3"  );
	GroupBoxBg1 = GetTextureHandle (  "DominionWarInfoWnd.GroupBoxBg1"  );
	GroupBoxBg2 = GetTextureHandle (  "DominionWarInfoWnd.GroupBoxBg2"  );
}


function Load()
{
}

function OnClickButton( string Name )
{
	switch( Name )
	{
	//~ case "btnClose":
		//~ OnbtnCloseClick();
		//~ break;
	case "btnApplyMachinery":
		OnbtnApplyMachineryClick();
		break;
	case "btnClanApplyBtn":
		OnbtnClanApplyBtnClick();
		break;
	case "btnAcceptClan":
		OnbtnAcceptClanClick();
		break;
	}
}

//~ function OnbtnCloseClick()
//~ {
	
//~ }

function OnbtnApplyMachineryClick()
{
	local int PlayerID;
	//~ PlayerID = GetPlayerID();

	
	PlayerID = class'UIDATA_PLAYER'.static.GetPlayerID();
	debug("영지 ID" $m_MachineryBtnBool $"     "$m_DominionID $"     " $PlayerID);
	if (m_MachineryBtnBool)
	{
		debug("이프" $m_MachineryBtnBool $"     "$m_DominionID $"     " $PlayerID);
		RequestJoinDominionWar(m_DominionID, 0, 1, PlayerID);
		
	}
	else 
	{
		debug("엘스" $m_MachineryBtnBool $"     "$m_DominionID $"     " $PlayerID);
		RequestJoinDominionWar(m_DominionID, 0, 0, PlayerID);
		
	}
}

function OnbtnClanApplyBtnClick()
{
	local UserInfo TempUserInfo;
	local int ClanID;

	GetPlayerInfo(TempUserInfo);
	ClanID = TempUserInfo.nClanID;
	if (m_ClanBtnBool)
	{
		RequestJoinDominionWar(m_DominionID, 1, 1, ClanID);
		
	}
	
	else
	{
		RequestJoinDominionWar(m_DominionID, 1, 0, ClanID);
		
	}
}

function OnbtnAcceptClanClick()
{
}

function OnEvent(int Event_ID, string Param)
{
	debug("Dominion Event ID" $Event_ID);
	switch (Event_ID)
	{
		case EV_ShowDominionWarJoinListStart:
			ListCtrlTerritoryWarList.DeleteAllItem();
			HandleShowDominionWarJoinList(Param);
			break;
		case EV_ResultJoinDominionWar:
			HandleResultJoinDominionWar(Param);
			break;
		case EV_DominionInfoCnt:
			HandleDominionInfoCnt(Param);
			break;
		case EV_DominionInfo:
			HandleDominionInfo(Param);
			break;
		//~ case EV_DominionsOwnPos:
			//~ HandleDominionsOwnPos(Param);
			//~ break;
		
		//~ case EV_ShowDominionWarJoinListStart:
			//~ ListCtrlTerritoryWarList.DeleteAllItem();
			//~ break;
		
		case EV_ShowDominionWarJoinListEnemyDominionInfo:
			HandleShowDominionWarJoinListEnemyDominionInfo(Param);
			break;
		
		case EV_ShowDominionWarJoinListEnd:
			HandleShowDominionWarJoisnListEnd();
			break;
		
		//~ case Ev_showDominionWarJoinListStart:
			//~ HandleDominionWarJoinList(Param);
			//~ break;
	}
}

function HandleShowDominionWarJoinListEnemyDominionInfo(string Param)
/* 
enemyDominionID”  INT 적영지ID
HaveOwnthingDominionID숫자”  INT, 숫자자리에는 1-9 
*/
{
	local int i;
	//~ local int j;
	local int enemyDominionID;
	local int HaveOwnthingDominionID[9];
	local LVDataRecord Record;
	local LVData data1;
	local LVData data2;
	local texture DominionFlagTex;
	local texture DominionFlagTexreset;
	//~ local LVData data3;
	
	ParseInt (Param, "enemyDominionID", enemyDominionID);
	
	data2.arrTexture.Length = 9;
		
	for (i=1; i<10; i++)
	{
		ParseInt (Param, "HaveOwnthingDominionID" $ i , HaveOwnthingDominionID[i]);
		
		//~ debug ("DominionsOwnName" @  DominionsOwnName[i]);
		DominionFlagTex = DominionFlagTexreset;
		DominionFlagTex = GetDominionFlagIconTex(HaveOwnthingDominionID[i]);
		data2.arrTexture[i-1].objTex = DominionFlagTex;
		data2.arrTexture[i-1].Width = 12;
		data2.arrTexture[i-1].Height =12;
		data2.arrTexture[i-1].X = (i*12);
		data2.arrTexture[i-1].Y = 0;
		data2.arrTexture[i-1].U = 32;
		data2.arrTexture[i-1].V = 32;
	}
	
	data1.szData = GetCastleName(enemyDominionID);
	Record.LVDataList[0] = data1;
	Record.LVDataList[1] = data2;
	ListCtrlTerritoryWarList.InsertRecord(Record);
}

function	HandleShowDominionWarJoisnListEnd()
{
	
}


function HandleShowDominionWarJoinList(string Param)
//~ DominionID”       영지ID : INT    -> 영지 ID에 80을 빼면 성이름이 된답니다.   성이름은 castlename.txt에 있으니까 그거로 만들어서 사용하시면될 듯(이부분 규칙은 바뀌거나 새로 정해질수도있습니다.)
 //~ ClanName”       혈맹이름 : string
//~ ClanMasterName”           혈맹주이름 : string
//~ AllianceName”   동맹이름 : string
//~ JoinedClanCnt”  참여 혈맹수 : int
//~ JoinedUserCnt” 참여 유저수 : int
//~ NextDominionWarDate”   다음 영지전 시각 : int
//~ CurrentDate”      현재시각 : int
//~ EnemyDominionCnt”        적 영지 개수
{
	//~ local string ClanName;
	//~ local string ClanMasterName;
	//~ local string AllianceName;
	local int DominionID;
	local string ClanName;
	local string ClanMasterName;
	local string AllianceName;
	local string MyClanJoinDominionID;
	local string UserJoinDominionID;
	
	local int JoinedClanCnt;
	local int JoinedUserCnt;
	local int NextDominionWarDate;
	local int CurrentDate;
	local int EnemyDominionCnt;
	Me.ShowWindow();
	ParseInt	(Param, "DominionID",  DominionID);
	ParseInt	(Param, "JoinedClanCnt",  JoinedClanCnt);
	ParseInt	(Param, "JoinedUserCnt",  JoinedUserCnt);
	ParseInt	(Param, "NextDominionWarDate",  NextDominionWarDate);
	ParseInt	(Param, "CurrentDate",  CurrentDate);
	ParseInt	(Param, "EnemyDominionCnt",  EnemyDominionCnt);
	ParseString (Param, "ClanName", ClanName);
	ParseString (Param, "ClanMasterName", ClanMasterName);
	ParseString (Param, "AllianceName", AllianceName);
	ParseString (Param, "MyClanJoinDominionID", MyClanJoinDominionID); //내 혈맹 영지전 참여 영지 id (없으면0)
	ParseString (Param, "UserJoinDominionID", UserJoinDominionID); //내 개인 영지전 참여 영지 id( 없으면 0)
	//~ record.LVDataList.length = EnemyDominionCnt;
	//~ for (i=0;i<= EnemyDominionCnt; i++)
	//~ {
		//~ ParseString	(Param, "EnemyDominion"$ string(i+1),  EnemyDominion[i]);
		//~ data1.szData = EnemyDominion[i];
		//~ record.LVDataList[0].szData = EnemyDominion[i];
		//~ record.LVDataList[1].szTexture = ClanTexList[i];
		//~ record.LVDataList[1].nTextureWidth = 8;
		//~ record.LVDataList[1].nTextureHeight = 12;
	//~ }
	//~ ParseString	(Param, "ClanName", ClanName  );
	//~ ParseString	(Param, "ClanMasterName", ClanMasterName  );
	//~ ParseString	(Param, "AllianceName", AllianceName );
	m_DominionID = DominionID;
	m_DominionName= GetCastleName(DominionID);
	//~ debug ("CurrentDate" @ CurrentDate);
	
	debug ("MyClanJoinDominionID" @ MyClanJoinDominionID @ "UserJoinDominionID" @UserJoinDominionID);
	
	if ( int(MyClanJoinDominionID) > 0)
	{
		btnClanApplyBtn.SetButtonName(1959);
		m_ClanBtnBool = false;
		
	}
	
	else if (int(MyClanJoinDominionID) == 0)
	{
		btnClanApplyBtn.SetButtonName(1957);
		m_ClanBtnBool = true;
		
	}
	
	if ( int(UserJoinDominionID) > 0)
	{
		btnApplyMachinery.SetButtonName(1960);
		m_MachineryBtnBool = false;
		
	}
	
	else if ( int(UserJoinDominionID) == 0)
	{
		btnApplyMachinery.SetButtonName(1958);
		m_MachineryBtnBool = true;
		
	}
	
	txtCurrentTerritory.SetText(GetCastleName(DominionID));
	txtLordName.SetText(ClanMasterName);
	txtClanName.SetText(ClanName);
	txtAlleyName.SetText(AllianceName);
	txtTerritoryWarTime.SetText(ConvertTimetoStr(NextDominionWarDate));
	txtCurrentTime.SetText(ConvertTimetoStr(CurrentDate));
	txtTotalClanCount.SetText(String(JoinedClanCnt));
	txtTotalMachineryCount.SetText(String(JoinedUserCnt));
	//~ Record.LVDataList[0] = data1;
	//~ ListCtrlTerritoryWarList.InsertRecord(Record);
}

function HandleResultJoinDominionWar(string Param)
/* 
“DominionID” 		영지 ID : INT
“Clan” 			혈맹여부 : INT 1은 혈맹 / 0은 개인
“Join” 			참가/취소 여부 : INT  1은 참가 / 0은 취소
“Success” 		성공/실패 여부 : INT  1은 성공/ 0은 실패
여기에 추가로

“ClanCnt”  : INT

“UserCnt” : INT 
 */
{
	local int DominionID;
	local int Clan;
	local int Join;
	local int Success;
	local int ClanCnt;
	local int UserCnt;
	

	
	debug ("HandleResultJoinDominionWar" @ Param);
	
	ParseInt	(Param, "DominionID", DominionID );
	ParseInt	(Param, "Clan", Clan );
	ParseInt	(Param, "Join", Join );
	ParseInt	(Param, "Success", Success );
	ParseInt	(Param, "ClanCnt", ClanCnt );
	ParseInt	(Param, "UserCnt", UserCnt );
	
	if (m_DominionID == DominionID)
	{
		if (Clan == 1)
		{ 
			// 버튼 이름 혈맹 취소로 바꾸기
			if (Join == 1 && Success == 1)
			{

				
				btnClanApplyBtn.SetButtonName(1959);
				m_ClanBtnBool = false;
				txtTotalClanCount.SetText(MakeFullSystemMsg(GetSystemMessage(2781),String(Clancnt)));
			}
			else
			{

				
				btnClanApplyBtn.SetButtonName(1957);
				m_ClanBtnBool = true;
				txtTotalClanCount.SetText(MakeFullSystemMsg(GetSystemMessage(2781),String(Clancnt)));
			}
		}
		else
		{
			// 버튼이름 개인 취소로 바꾸기 
			if (Join == 1 && Success == 1)
			{

				
				btnApplyMachinery.SetButtonName(1960);
				m_MachineryBtnBool = false;
				txtTotalMachineryCount.SetText(MakeFullSystemMsg(GetSystemMessage(2782),String(UserCnt)));
				//~ txtTotalMachineryCount.SetText(String(UserCnt) $ "명")
			}
			else
			{

				
				btnApplyMachinery.SetButtonName(1958);
				m_MachineryBtnBool = true;
				txtTotalMachineryCount.SetText(MakeFullSystemMsg(GetSystemMessage(2782),String(UserCnt)));
				//~ txtTotalMachineryCount.SetText(String(UserCnt) $ "명")
			}
		}
	}
}

function HandleDominionInfoCnt(string Param)
/* 
“DominionInfoCnt”             영지 정보 개수 : int
 */
{
	local int DominionInfoCnt;
	
	debug ("HandleDominionInfoCnt" @ Param);
	
	ParseInt	(Param, "DominionInfoCnt", DominionInfoCnt );
	
}

function HandleDominionInfo(string Param)

/* 
“DominionID”       				영지ID : INT
“DominionName” 				영지이름 : string -> 영지 ID에 80을 빼면 성이름이 된답니다.   성이름은 castlename.txt에 있으니까 그거로 만들어서 사용하시면될 듯(이부분 규칙은 바뀌거나 새로 정해질수도있습니다.)
“ClanName”         				혈맹이름 : string
“DominionsOwnCnt”  			고유물 개수 : INT
“DominionsOwnName숫자”  		고유물 이름 (숫자는 개수만큼 반복)  -> 고유물은 나중에 classID가 넘어오게 됩니다. ClassID가지고 이름을 찾아내세요.
“NextDate”           				다음 영지전 시각 : INT
 */
{
	local int DominionID;
	local string DominionName;
	local string ClanName;
	local int DominionsOwnCnt;
	local string DominionsOwnName[8];  		
	local int NextDate;
	local int i;
	
	debug ("HandleDominionInfoCnt" @ Param);
	
	
	ParseInt	(Param, "DominionID", DominionID );
	ParseInt	(Param, "DominionsOwnCnt", DominionsOwnCnt );
	//~ ParseInt	(Param, "DominionsOwnName", DominionsOwnName );
	
	
	ParseInt	(Param, "NextDate", NextDate );
	ParseString	(Param, "DominionName", DominionName );
	ParseString	(Param, "ClanName", ClanName );
	
	for (i=0;i<= DominionsOwnCnt; i++)
	{
		ParseString	(Param, "DominionsOwnName"$ string(i+1),  DominionsOwnName[i]);
	}
}

//~ function HandleDominionsOwnPos(string Param)
/* 
“DominionsOwnName	고유물이름 : string     -> 고유물은 나중에 classID가 넘어오게 됩니다. ClassID가지고 이름을 찾아내세요.
“PosX”  				X :INT
“PosY”   				Y : INT
“PosZ”   				Z : INT
 */
//~ { 
	//~ local string DominionsOwnName;
	//~ local vector MapLocation;
	//~ local int x;
	//~ local int y;
	//~ local int z;

	//~ debug ("HandleDominionsOwnPos" @ Param);
	
	//~ ParseString	(Param, "DominionsOwnName", DominionsOwnName );
	//~ ParseInt	(Param, "PosX", x );
	//~ ParseInt	(Param, "PosY", y);
	//~ ParseInt	(Param, "PosZ", z );
	
//~ }
       
function HandleDominionWarJoinList(string Param)
/* 
MyClanJoinDominionID 	: INT   	자기 혈맹이 등록되어있을 경우 영지의 ID
UserJoinDominionID  	: INT	자기가 등록되어있을경우 영지의 ID
ImMaster  			: INT	자기가 혈맹주이면 1 아니면 0 
 */
{
	local int MyClanJoinDominionID;
	local int UserJoinDominionID;
	local int ImMaster;

	debug ("HandleDominionsOwnPos" @ Param);
	
	ParseInt	(Param, "MyClanJoinDominionID", MyClanJoinDominionID );
	ParseInt	(Param, "UserJoinDominionID", UserJoinDominionID);
	ParseInt	(Param, "ImMaster", ImMaster );
	
	if (MyClanJoinDominionID > 0 )
	{
		btnApplyMachinery.SetButtonName(1959);
		m_ClanBtnBool = false;
	}
	else
	{
		btnClanApplyBtn.SetButtonName(1957);
		m_ClanBtnBool = true;
	}
	if (UserJoinDominionID > 0 )
	{
		btnApplyMachinery.SetButtonName(1960);
		m_MachineryBtnBool = false;
	}
	else
	{
		btnApplyMachinery.SetButtonName(1958);
		m_MachineryBtnBool = true;
	}
	if (ImMaster == 0 )
	{
		btnApplyMachinery.DisableWindow();
		btnClanApplyBtn.DisableWindow();
	}
	else
	{
		btnApplyMachinery.EnableWindow();
		btnClanApplyBtn.EnableWindow();
	}
}
defaultproperties
{
}
