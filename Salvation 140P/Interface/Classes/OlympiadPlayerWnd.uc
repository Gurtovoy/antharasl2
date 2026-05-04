class OlympiadPlayerWnd extends UICommonAPI;

const MAX_OLYMPIAD_USER_NUM = 3;
const MAX_OLYMPIAD_TEAM_NUM = 2;
//const MAX_OLYMPIAD_ALL_USER_NUM = MAX_OLYMPIAD_USER_NUM * MAX_OLYMPIAD_TEAM_NUM;  6
const MAX_OLYMPIAD_SKILL_MSG = 5;
const MAX_OLYMPIAD_ALLSKILL_MSG = 15; //MAX_OLYMPIAD_USER_NUM * MAX_OLYMPIAD_SKILL_MSG

const CONTRACT_HEIGHT = 44;
const EXPAND_HEIGHT = 124;

const NSTATUSICON_FRAMESIZE = 12;
const NSTATUSICON_MAXCOL = 12;

var WindowHandle Me;
var ButtonHandle btnExpand;
var ButtonHandle btnContract;

var WindowHandle m_StatusWnd[MAX_OLYMPIAD_USER_NUM];
var WindowHandle	m_MsgWnd[MAX_OLYMPIAD_USER_NUM];	//메시지윈도우
var NameCtrlHandle		m_PlayerName[MAX_OLYMPIAD_USER_NUM];
var TextureHandle		m_ClassIcon[MAX_OLYMPIAD_USER_NUM];
var BarHandle	m_BarCP[MAX_OLYMPIAD_USER_NUM];
var BarHandle	m_BarHP[MAX_OLYMPIAD_USER_NUM];

var TextBoxHandle m_TextBoxHandle[MAX_OLYMPIAD_ALLSKILL_MSG]; //TextBoxHandle
var string		m_Msg[MAX_OLYMPIAD_ALLSKILL_MSG];

var StatusIconHandle	StatusIcon[MAX_OLYMPIAD_USER_NUM]; 

var int			m_PlayerNum;
var string		m_WindowName;
var string		m_BuffWindowName;
var bool		m_Expand;
var int 		m_TotalCount;
var int			m_MyTeamCount;

var int		m_MsgStartLine[MAX_OLYMPIAD_USER_NUM];
var int		m_MsgNextStartLine[MAX_OLYMPIAD_USER_NUM];

var int		m_MyTeamNum;
var int 		m_IsPlayer;

var bool mFound ;

//선준 수정(10.04.01) 완료
var Color Red;
var Color Blue;

struct native constructive OlympiadUserInfo
{
	var int		m_TeamID;
	var int		m_ID;
	var string		m_Name;
	var int		m_ClassID;
	var int		m_MaxHP;
	var int		m_CurHP;
	var int		m_MaxCP;
	var int		m_CurCP;
	var int		m_MsgWnd;	//메시지윈도우
	
};

var OlympiadUserInfo BIT_UserInfo[MAX_OLYMPIAD_USER_NUM];


function SetPlayerNum(int PlayerNum)
{
	m_PlayerNum = PlayerNum;
	m_WindowName = "OlympiadPlayer" $ m_PlayerNum $ "Wnd";
	m_BuffWindowName = "OlympiadBuff" $ m_PlayerNum $ "Wnd";
}

function OnRegisterEvent()
{
	RegisterEvent( EV_OlympiadUserInfo );
	RegisterEvent( EV_OlympiadMatchEnd );
	RegisterEvent( EV_ReceiveMagicSkillUse );
	RegisterEvent( EV_ReceiveAttack );

	RegisterEvent( EV_OlympiadBuffShow );
	RegisterEvent( EV_OlympiadBuffInfo );
}

function OnLoad()
{
	local int i,j;
	
	mFound = true;
	
	Me = GetWindowHandle( m_WindowName );
	for (i=0;i<MAX_OLYMPIAD_USER_NUM;i++) //3
	{
		m_StatusWnd[i] = GetWindowHandle(m_WindowName $".TargetWnd"$ i);
		m_MsgWnd[i] = GetWindowHandle(m_WindowName $".TargetWnd"$i $".SysMsgWnd");		//메시지윈도우
		for(j =0; j < MAX_OLYMPIAD_SKILL_MSG; j++) //5
		{
			m_TextBoxHandle[i*MAX_OLYMPIAD_SKILL_MSG + j] = GetTextBoxHandle( m_WindowName $".TargetWnd"$i $".SysMsgWnd"$".txtMsg"$j);
		}
		m_PlayerName[i] = GetNameCtrlHandle(m_WindowName $".TargetWnd"$ i $ ".PlayerName" ); 
		m_ClassIcon[i] = GetTextureHandle(m_WindowName $".TargetWnd"$ i $ ".ClassIcon" );			
		m_BarCP[i] = GetBarHandle(m_WindowName $".TargetWnd"$ i $".barCP");
		m_BarHP[i] = GetBarHandle(m_WindowName $".TargetWnd"$ i $".barHP");
		StatusIcon[i] = GetStatusIconHandle( m_WindowName $".TargetWnd"$ i $".BuffWnd" );			
		//debug("m_StatusWnd[i]"$m_StatusWnd[i]);
		//debug("m_MsgWnd[i]"$m_MsgWnd[i]);			//메시지윈도우
		//debug("m_PlayerName[i]"$m_PlayerName[i]);
		//debug("m_ClassIcon[i]"$m_ClassIcon[i]);
		//debug("m_BarCP[i]"$m_BarCP[i]);
		//debug("m_BarHP[i]"$m_BarHP[i]);
	}
	
	btnExpand = GetButtonHandle (m_WindowName $ ".btnExpand" );
	btnContract= GetButtonHandle (m_WindowName $ ".btnContract" );
	
	for (i=0;i<MAX_OLYMPIAD_USER_NUM;i++) //3
	{
		StatusIcon[i].SetAnchor(m_WindowName$".TargetWnd"$i, "TopRight", "TopLeft", 1, 1);
	}
	SetExpandMode(false);
	SetColor();
}

//선준 수정(10.04.01) 완료
function SetColor()
{
	Red.R = 238;
	Red.G = 119;
	Red.B = 119;
	Red.A = 255;
	
	Blue.R = 102;
	Blue.G = 170;
	Blue.B = 238;
	Blue.A = 255;
}

function OnEnterState( name a_PreStateName )
{
	//Clear();
	//SetExpandMode(false);
	//SetExpandMode(m_Expand);
}

function OnEvent(int Event_ID, string param)
{
	/*
	if ( Event_ID != EV_OlympiadUserInfo ||  Event_ID != EV_OlympiadBuffInfo)
	{
		Debug("playerWnd" @ Event_ID @ param);
	}
*/
	if (Event_ID == EV_OlympiadUserInfo)
	{
		HandleUserInfo(param);
		//UpdateStatus();
	}
	else if (Event_ID == EV_ReceiveMagicSkillUse)
	{
		//debug("스킬사용이안됨!!!");
		HandleMagicSkillUse(param);
	}
	else if (Event_ID == EV_ReceiveAttack)
	{
		HandleAttack(param);
	}
	else if (Event_ID == EV_OlympiadBuffShow)
	{
	//	HandleBuffShow(param);
	}
	else if (Event_ID == EV_OlympiadBuffInfo)
	{
		HandleBuffInfo(param);
	}
	else if (Event_ID == EV_OlympiadMatchEnd)
	{
		Clear();
	}
	
	
	
}

//초기화
function Clear()
{
	local int i;
	
	//~ var int		m_ID[5];
	//~ var string		m_Name[5];
	//~ var int		m_ClassID[5];
	//~ var int		m_MaxHP[5];
	//~ var int		m_CurHP[5];
	//~ var int		m_MaxCP[5];
	//~ var int		m_CurCP[5];
	
	
	for (i=0; i<MAX_OLYMPIAD_USER_NUM; i++)
	{

		BIT_UserInfo[i].m_TeamID = 0;		
		BIT_UserInfo[i].m_ID = 0;
		BIT_UserInfo[i].m_Name = "";
		BIT_UserInfo[i].m_ClassID = 0;
		BIT_UserInfo[i].m_MaxHP = 0;
		BIT_UserInfo[i].m_CurHP = 0;
		BIT_UserInfo[i].m_MaxCP = 0;
		BIT_UserInfo[i].m_CurCP = 0;		
		BIT_UserInfo[i].m_MsgWnd = 0;		//메시지윈도우

		StatusIcon[i].Clear();
//		StatusIcon[i].HideWindow();
	}
	
	
	for (i=0; i<MAX_OLYMPIAD_ALLSKILL_MSG; i++)
	{
		m_Msg[i] = "";
	}
	
//	UpdateStatus();
	for (i = 0; i < MAX_OLYMPIAD_USER_NUM; i++ )
		UpdateMsg(i, "");
	me.hidewindow();
}
function initialize()
{
	local int i;
		

	
	
	for (i=0; i<MAX_OLYMPIAD_USER_NUM; i++)
	{

		BIT_UserInfo[i].m_TeamID = 0;		
		BIT_UserInfo[i].m_ID = 0;
		BIT_UserInfo[i].m_Name = "";
		BIT_UserInfo[i].m_ClassID = 0;
		BIT_UserInfo[i].m_MaxHP = 0;
		BIT_UserInfo[i].m_CurHP = 0;
		BIT_UserInfo[i].m_MaxCP = 0;
		BIT_UserInfo[i].m_CurCP = 0;		
		BIT_UserInfo[i].m_MsgWnd = 0;		//메시지윈도우

		StatusIcon[i].Clear();
		m_MsgStartLine[i] = MAX_OLYMPIAD_ALLSKILL_MSG *i;

	}
	
	
	for (i=0; i<MAX_OLYMPIAD_ALLSKILL_MSG; i++)
	{
		m_Msg[i] = "";
	}
	
//	UpdateStatus();
	for (i = 0; i < MAX_OLYMPIAD_USER_NUM; i++ )
		UpdateMsg(i, "");

	

}
function OnShow()
{
	initialize();
}
/*//BuffWnd 초기화
function HandleBuffShow(string param)
{
	local int PlayerNum;
	
	//나의 플레이어(1 or 2)가 아니면 패스
	ParseInt(param, "PlayerNum", PlayerNum);
	if (m_PlayerNum != PlayerNum || PlayerNum<1)
	{
		return;
	}
	ParseInt(param, "PlayerID", m_PlayerID);
}
*/
//BuffInfo설정
function HandleBuffInfo(string param)
{
	local int ID;
	
	local int i,j;
	local int Max;
	local int CurRow;
	local StatusIconInfo info;
	local int numOfBuff;
		
	//나의 플레이어ID가 아니면 패스
	ParseInt(param, "PlayerID", ID); //내 서버측 ID

	for (i=0; i<m_MyTeamCount ; i++)
	{
		if (ID<1 || ID==BIT_UserInfo[i].m_ID)
		{
			break;
		}
	}

/*	if (m_PlayerID != PlayerID || PlayerID<1)
	{
		return;
	}
*/	
	if (i != m_MyTeamCount)
	{
		//초기화
	//	Clear();
		StatusIcon[i].Clear();
		CurRow = -1;
		
		ParseInt(param, "Max", Max);

		numOfBuff = 0;
		for (j=0; j<Max; j++)
		{
			ParseItemIDWithIndex(param, info.ID, j);
			ParseInt(param, "SkillLevel_" $ j, info.Level);
			ParseInt(param, "SkillSubLevel_" $ j, info.SubLevel);

			// 토핑 버프인 경우 add 하지 않음.
			if ( class'UIDATA_SKILL'.static.IsToppingSkill( info.ID, info.Level, info.SubLevel) ) 
			{			
				continue ;
			}

			//한줄에 NSTATUSICON_MAXCOL만큼 표시한다.
			if (numOfBuff%NSTATUSICON_MAXCOL == 0)
			{
				StatusIcon[i].AddRow();
//				class'UIAPI_STATUSICONCTRL'.static.AddRow(m_WindowName $ ".StatusIcon");
				CurRow++;
			}			

			ParseInt(param, "RemainTime_" $ j, info.RemainTime);

			ParseInt(param, "SpellerID_" $ j, info.SpellerID);

			ParseString(param, "Name_" $ j, info.Name);
			ParseString(param, "IconName_" $ j, info.IconName);
			ParseString(param, "Description_" $ j, info.Description);
			info.Size = 16;
			info.BackTex = "L2UI.EtcWndBack.AbnormalBack";
			info.bShow = true;
			
//			class'UIAPI_STATUSICONCTRL'.static.AddCol(m_WindowName $ ".StatusIcon", CurRow, info);
//			debug("마법Add" $ j$" "$i);
			StatusIcon[i].AddCol(CurRow, info);
			numOfBuff ++;
		}
		
		if (Max>0)
		{
//			class'UIAPI_WINDOW'.static.ShowWindow(m_WindowName);
			
			//윈도우 사이즈 변경
//			rectWnd = class'UIAPI_WINDOW'.static.GetRect(m_WindowName $ ".StatusIcon");
//			StatusIcon[i].GetRect();
//			class'UIAPI_WINDOW'.static.SetWindowSize(m_WindowName, rectWnd.nWidth + NSTATUSICON_FRAMESIZE, rectWnd.nHeight);
//			StatusIcon[i].SetWindowSize(rectWnd.nWidth + NSTATUSICON_FRAMESIZE, rectWnd.nHeight);			
			//세로 프레임 사이즈 변경
//			class'UIAPI_WINDOW'.static.SetFrameSize(m_WindowName, NSTATUSICON_FRAMESIZE, rectWnd.nHeight);	
//			StatusIcon[i].SetFrameSize(NSTATUSICON_FRAMESIZE, rectWnd.nHeight);
		}
	}
}

function HandleUserInfo(string Param)
{
	local int i;
	//~ local int playNum;

	local int teamID;
	local int PlayerID;
	local int m_ClassID;
	local string m_Name;
	local int m_MaxHP;
	local int m_CurHP;
	local int m_MaxCP;
	local int m_CurCP;
	local int m_MsgWnd;			//메시지윈도우
	local int m_UserInfoIdx;
	//~ local int myTeamID;
	
	//~ local string FakeEventParam;
		
	//~ local int PlayerNum;

	
	//Observer모드에서의 플레이어 정보가 아니면 패스
	ParseInt(param, "IsPlayer", m_IsPlayer);
	//debug("M_ISPlayer" $m_IsPlayer);
	if (m_IsPlayer != 1)
		return;

	ParseInt(param, "TotalCount", m_TotalCount); //플레이어 숫자

	m_MyTeamCount = m_TotalCount / 2;			// 우리팀 사람수
//	ParseInt(param, "MyTeamNum", m_MyTeamNum);
	
	
//	debug("!!!m_MyTeamNum"$m_MyTeamNum);

	//플레이어가 참가하고 있으면 IsPlayer 이 1이다 

	//여기서 토탈 카운터가 2인지 아니면 2 이상인지 체크 해야 한다 

	if ((m_TotalCount == 2) || (m_TotalCount == 6))
	{
		m_UserInfoIdx = 0;
	//	debug("!!!m_TotalCount"$m_TotalCount);
		for(i = 0; i <m_TotalCount ; i++)
		{
			
			ParseInt(param, "PlayerNum_" $ string (i) , teamID);  //현재 플레이어의 팀정보 1팀 2팀

	//		debug("PlayerNum_" $i$"ㅎㅎ"$ teamID);
			if (teamID != m_PlayerNum)  //내팀이 아니면넘어가자
				continue;
			
			ParseInt(param, "ID_" $ string (i), PlayerID);
			ParseString(param, "Name_" $ string (i), m_Name);
			ParseInt(param, "ClassID_" $ string (i), m_ClassID);
			ParseInt(param, "MaxHP_" $ string (i), m_MaxHP);
			ParseInt(param, "CurHP_" $ string (i), m_CurHP);
			ParseInt(param, "MaxCP_" $ string (i), m_MaxCP);
			ParseInt(param, "CurCP_" $ string (i), m_CurCP);
			ParseInt(param, "SysMsg_" $ string (i), m_MsgWnd);		//메시지윈도우
			
			BIT_UserInfo[m_UserInfoIdx].m_TeamID = teamID;
			BIT_UserInfo[m_UserInfoIdx].m_ID =PlayerID;
			BIT_UserInfo[m_UserInfoIdx].m_Name = m_Name;
			BIT_UserInfo[m_UserInfoIdx].m_ClassID = m_ClassID;
			BIT_UserInfo[m_UserInfoIdx].m_MaxHP = m_MaxHP;
			BIT_UserInfo[m_UserInfoIdx].m_CurHP =m_CurHP;
			BIT_UserInfo[m_UserInfoIdx].m_MaxCP =m_MaxCP;
			BIT_UserInfo[m_UserInfoIdx].m_CurCP =m_CurCP;	
			BIT_UserInfo[m_UserInfoIdx].m_MsgWnd =m_MsgWnd;			//메시지윈도우

			m_UserInfoIdx++;
	//		debug("후덜덜" $ m_UserInfoIdx);
			
		}
		
//		Debug("Resize" $m_TotalCount/2);
		Resize(m_TotalCount/2);
			
		
			
		UpdateUsersInfo();

	}	
}

//MagicSkill정보 처리
function HandleMagicSkillUse(string param)
{
	local int ID;
	local int SkillID;
	local int i;
	local string paramsend;
	local string strMsg;
	//debug("param->" $ param);
	if( !Me.IsShowWindow() )
	{//jylee, 실제로 사용할 때 아니면 바로 종료
		//debug( "OlympiadPlayerWnd is immediately returned" );
		return;
	}
	
	ParseInt(param, "AttackerID", ID);

	for (i=0; i<m_MyTeamCount ; i++)
	{
		if (ID<1 || ID==BIT_UserInfo[i].m_ID)
		{
			break;
		}
	}
	if (i != m_MyTeamCount)
	{
		ParseInt(param, "SkillID", SkillID);

		if ( !isSkill ( SkillID ) )
		{
			return;
		}		
	
		//메세지를 만들어서, 갱신함
		ParamAdd(paramsend, "Type", string(int(ESystemMsgParamType.SMPT_SKILLID)));
		ParamAdd(paramsend, "param1", string(SkillID));
		ParamAdd(paramsend, "param2", "1");
		AddSystemMessageParam(paramsend);
		strMsg = EndSystemMessageParam(46, true);
//		debug("스킬메세지" $ strMsg);
		UpdateMsg(i, strMsg);
	}
}

function bool isSkill( int SkillID )
{	
	//4차 각성 전 스킬
	if ( SkillID > 0 && SkillID < 1900 )
	{
		return true;
	}
	//4ck 각성 후 스킬
	else if ( SkillID > 10000 && SkillID < 12000 )
	{
		return true;
	}
	
	return false;	
}

//Attackl정보 처리
function HandleAttack(string param)
{
	local int		AttackerID;
	local string		AttackerName;
	local int		DefenderID;
	local int		Critical;
	local int		Miss;
	local int		ShieldDefense;
	local int 		i;
	local string		paramsend;
	local string		strMsg;
	
	ParseInt(param, "AttackerID", AttackerID);
	ParseString(param, "AttackerName", AttackerName);
	ParseInt(param, "DefenderID", DefenderID);
	ParseInt(param, "Critical", Critical);
	ParseInt(param, "Miss", Miss);
	ParseInt(param, "ShieldDefense", ShieldDefense);
	
	
	for (i=0; i< m_MyTeamCount ; i++)
	{
	//	debug("AttackerID"$AttackerID $"UserInfoID"$ BIT_UserInfo[i].m_ID); 
		if (AttackerID > 0 && AttackerID == BIT_UserInfo[i].m_ID)
		//~ if (AttackerID > 0 )
		{
			if (Critical>0)
			{
	//			debug("표시가되야되죠"$i $"  " $Critical);
				UpdateMsg(i, GetSystemMessage(44));
		//고치자		UpdateMsg(GetSystemMessage(44));
			}
		}
		else if (DefenderID>0 && DefenderID==BIT_UserInfo[i].m_ID)
		//~ else if (DefenderID>0 )
		{
			if (Miss>0)
			{

		//		debug("표시가되야되죠~~"$i $"  "$ Miss);
				//메세지를 만들어서, 갱신함
				ParamAdd(paramsend, "Type", string(int(ESystemMsgParamType.SMPT_STRING)));
				ParamAdd(paramsend, "param1", AttackerName);
				AddSystemMessageParam(paramsend);
				strMsg = EndSystemMessageParam(42, true);

				UpdateMsg(i, strMsg);
				
//고치자				UpdateMsg(strMsg);
			}
			else if (ShieldDefense>0)
			{
				UpdateMsg(i, GetSystemMessage(111));
//고치자				UpdateMsg(GetSystemMessage(111));
			}
		}
	}
}

//Update Message

function UpdateMsg(int Userindex, string strMsg)
{
	local int i;
	local int CurPos;
	local int BoxPos;
	
	m_MsgStartLine[Userindex] = (Userindex * MAX_OLYMPIAD_SKILL_MSG) + (m_MsgNextStartLine[Userindex] % MAX_OLYMPIAD_SKILL_MSG);
	m_Msg[m_MsgStartLine[Userindex]] = strMsg;
	m_MsgNextStartLine[Userindex] = m_MsgStartLine[Userindex] + 1;
	
//	debug("StartLine"$m_MsgStartLine[Userindex]);
	for (i=0; i<MAX_OLYMPIAD_SKILL_MSG; i++)
	{
		CurPos = Userindex * MAX_OLYMPIAD_SKILL_MSG + ((m_MsgStartLine[Userindex] + i) % MAX_OLYMPIAD_SKILL_MSG);
//		class'UIAPI_TEXTBOX'.static.SetText( m_WindowName $ ".txtMsg" $ MAX_OLYMPIAD_SKILL_MSG-1-i, m_Msg[CurPos]);

		BoxPos = Userindex * MAX_OLYMPIAD_SKILL_MSG + MAX_OLYMPIAD_SKILL_MSG-1-i;
		m_TextBoxHandle[BoxPos].SetText(m_Msg[CurPos]);
//		debug("BoxPos"$BoxPos $"CurPos"$CurPos$" "$m_Msg[CurPos]);
	}
}

//Update Message
/*
function UpdateMsg(int Userindex, string strMsg)
{
	local int i;
	local int CurPos;
	local int BoxPos;
	

	m_Msg[m_MsgStartLine[Userindex]] = strMsg;
	m_MsgStartLine[Userindex] =m_MsgStartLine[Userindex] + 1;
	if (m_MsgStartLine[Userindex] % MAX_OLYMPIAD_SKILL_MSG == 0)
		m_MsgStartLine[Userindex] =  MAX_OLYMPIAD_SKILL_MSG * Userindex;
	




	for (i=0; i<MAX_OLYMPIAD_SKILL_MSG; i++)
	{
		CurPos = Userindex * MAX_OLYMPIAD_SKILL_MSG + (m_MsgStartLine[Userindex] + i) % MAX_OLYMPIAD_SKILL_MSG;
//		class'UIAPI_TEXTBOX'.static.SetText( m_WindowName $ ".txtMsg" $ MAX_OLYMPIAD_SKILL_MSG-1-i, m_Msg[CurPos]);
//		debug("야야야야!여기찍혀야되");
		BoxPos = Userindex * MAX_OLYMPIAD_SKILL_MSG + MAX_OLYMPIAD_SKILL_MSG-1-i;
		m_TextBoxHandle[BoxPos].SetText(m_Msg[CurPos]);
		debug("BoxPos"$BoxPos $"CurPos"$CurPos$" "$m_Msg[CurPos]);
	}
}*/
function UpdateUsersInfo()
{
	local int i;
	//local int j;
	
	//j = 0;
	
//	debug("m_MyTeamCount"$m_MyTeamCount);
	for(i = 0; i <m_MyTeamCount; i++)
	{
/*		if (m_IsPlayer == 0 ) 	//직접 참여자
		{
			if (BIT_UserInfo[i].m_TeamID != m_MyTeamNum)	//다른팀 
			{				
				Updateuserinfo(j,i);
	//			debug("idx"$i);
				j++;
			
			}			
		}
*/
//		if (m_IsPlayer == 1) // 관전자 
//		{
//		if (BIT_UserInfo[i].m_TeamID == m_PlayerNum)	//같은 팀 
//		{
		Updateuserinfo(i);
//			j++;
			
//		}			
//		}
	}
	me.showwindow();

}

function Updateuserinfo(int index)
{
	//선준 수정(10.04.01) 완료
	//이름
	if( m_PlayerNum == 1 )
	{
		//m_PlayerName[index].SetName(BIT_UserInfo[index].m_Name, NCT_Normal,TA_Center);
		m_PlayerName[index].SetNameWithColor( BIT_UserInfo[index].m_Name, NCT_Normal,TA_Center, Blue );
	}
	else
	{
		//m_PlayerName[index].SetName(BIT_UserInfo[index].m_Name, NCT_Normal,TA_Center);
		m_PlayerName[index].SetNameWithColor( BIT_UserInfo[index].m_Name, NCT_Normal,TA_Center, Red );
	}
	//CP
	if (BIT_UserInfo[index].m_MaxCP>0)
	{
		m_BarCP[index].SetValue (BIT_UserInfo[index].m_MaxCP , BIT_UserInfo[index].m_CurCP);
	}
	else
	{
		m_BarCP[index].SetValue ( 0 , 0);
	}
	
	// HP
	if (BIT_UserInfo[index].m_MaxHP>0)
	{
		m_BarHP[index].SetValue (BIT_UserInfo[index].m_MaxHP , BIT_UserInfo[index].m_CurHP);
	}
	else
	{
		m_BarHP[index].SetValue ( 0 , 0);
	}
	

}

function OnClickButton( string strID )
{
	switch( strID )
	{
		case "btnExpand":
			SetExpandMode(false);
			break;
		case "btnContract":
			SetExpandMode(true);
			break;
	}
}


//Expand상태에 따른 여러가지 처리
function SetExpandMode(bool bExpand)
{
	local Rect 	rectWnd;
	local Rect 	rectBuffWnd;
	
	local int nWndWidth, nWndHeight;	// 윈도우 사이즈 받기 변수
	
	Me.GetWindowSize(nWndWidth, nWndHeight);
	
	if (bExpand)
	{
		class'UIAPI_WINDOW'.static.HideWindow(m_WindowName $ ".BackTex");
		class'UIAPI_WINDOW'.static.ShowWindow(m_WindowName $ ".SysMsgWnd");
		btnExpand.ShowWindow();
		btnContract.HideWindow();
		Me.SetWindowSize(nWndWidth, EXPAND_HEIGHT);
	}
	else
	{
		class'UIAPI_WINDOW'.static.HideWindow(m_WindowName $ ".SysMsgWnd");
		class'UIAPI_WINDOW'.static.ShowWindow(m_WindowName $ ".BackTex");
		btnExpand.HideWindow();
		btnContract.ShowWindow();
		Me.SetWindowSize(nWndWidth, CONTRACT_HEIGHT);
	}
	
	//Buff윈도우를 이동시켜 준다
	rectWnd = class'UIAPI_WINDOW'.static.GetRect(m_WindowName);
	rectBuffWnd = class'UIAPI_WINDOW'.static.GetRect(m_BuffWindowName);
	
	if (!bExpand)
	{	
		//Stuckable속성때문에 이상하게 움직일 수 있으므로 MoveEx를 사용
		if ( rectWnd.nY + 46 == rectBuffWnd.nY || rectWnd.nY + 47 == rectBuffWnd.nY )
		{
			class'UIAPI_WINDOW'.static.MoveEx(m_BuffWindowName, 0, 80);
		}
	}
	else
	{
		//Stuckable속성때문에 이상하게 움직일 수 있으므로 MoveEx를 사용
		if ( rectWnd.nY + 126 == rectBuffWnd.nY || rectWnd.nY + 127 == rectBuffWnd.nY )
		{
			class'UIAPI_WINDOW'.static.MoveEx(m_BuffWindowName, 0, -80);
		}
	}
}


function Resize( int count )
{
	//메시지윈도우 어떻게든 띄워보자-_-a
	local Rect entireRect, statusWndRect, msgWndRect;
	entireRect = me.GetRect();
	statusWndRect = m_StatusWnd[0].GetRect();
	msgWndRect = m_msgWnd[0].GetRect();

	//debug("count"$count);
	//debug("entireRect.nWidth"$entireRect.nWidth$"statusWndRect.nHeight"$ statusWndRect.nHeight);
	me.SetWindowSize( entireRect.nWidth, (statusWndRect.nHeight + msgWndRect.nHeight - 8) *count );
	me.SetResizeFrameSize( 10, (statusWndRect.nHeight + msgWndRect.nHeight - 8) *count );



	if (m_TotalCount == 2)
	{
		m_StatusWnd[0].Showwindow();
		m_StatusWnd[1].Hidewindow();
		m_StatusWnd[2].Hidewindow();
		m_MsgWnd[0].Showwindow();
		m_MsgWnd[1].Hidewindow();
		m_MsgWnd[2].Hidewindow();
	//	StatusIcon[0].ShowWindow();
	//	StatusIcon[1].HideWindow();
	//	StatusIcon[2].HideWindow();
		

	/*	m_TextBoxHandle[0].ShowWindow();
		m_TextBoxHandle[1].ShowWindow();
		m_TextBoxHandle[2].ShowWindow();
		m_TextBoxHandle[3].ShowWindow();
		m_TextBoxHandle[4].ShowWindow();
		m_TextBoxHandle[5].hideWindow();
		m_TextBoxHandle[6].hideWindow();
		m_TextBoxHandle[7].hideWindow();
		m_TextBoxHandle[8].hideWindow();
		m_TextBoxHandle[9].hideWindow();
		m_TextBoxHandle[10].hideWindow();
		m_TextBoxHandle[11].hideWindow();
		m_TextBoxHandle[12].hideWindow();
		m_TextBoxHandle[13].hideWindow();
		m_TextBoxHandle[14].hideWindow();

*/


	}
	else if (m_TotalCount == 6)
	{
		m_StatusWnd[0].Showwindow();
		m_StatusWnd[1].Showwindow();
		m_StatusWnd[2].Showwindow();
		m_MsgWnd[0].Showwindow();
		m_MsgWnd[1].Showwindow();
		m_MsgWnd[2].Showwindow();
	//	StatusIcon[0].ShowWindow();
	//	StatusIcon[1].Showwindow();
	//	StatusIcon[2].Showwindow();

	/*	m_TextBoxHandle[0].ShowWindow();
		m_TextBoxHandle[1].ShowWindow();
		m_TextBoxHandle[2].ShowWindow();
		m_TextBoxHandle[3].ShowWindow();
		m_TextBoxHandle[4].ShowWindow();
		m_TextBoxHandle[5].ShowWindow();
		m_TextBoxHandle[6].ShowWindow();
		m_TextBoxHandle[7].ShowWindow();
		m_TextBoxHandle[8].ShowWindow();
		m_TextBoxHandle[9].ShowWindow();
		m_TextBoxHandle[10].ShowWindow();
		m_TextBoxHandle[11].ShowWindow();
		m_TextBoxHandle[12].ShowWindow();
		m_TextBoxHandle[13].ShowWindow();
		m_TextBoxHandle[14].ShowWindow();
*/		
	}

}
defaultproperties
{
}
