class CleftEnterWnd extends UIScript;

const TeamA_ID =0;
const TeamB_ID =1;

var WindowHandle Me;
var TextboxHandle ARemainStaff; 
var TextboxHandle BRemainStaff;
var TextboxHandle TeamATitle;
var TextboxHandle TeamBTitle;
var TextboxHandle TeamATotalStaff;
var TextboxHandle TeamBTotalStaff;

var ListCtrlHandle TeamAList;
var ListCtrlHandle TeamBList;

var TextureHandle TeamAGroupBox;
var TextureHandle TeamBGroupBox;

var ButtonHandle btnExit;

var int m_MinMember;

var bool m_exitbool;

var int m_UserID;

function OnRegisterEvent()
{
	registerEvent( EV_CleftListStart ); //이벤트 등록
	registerEvent( EV_CleftListAdd );
	registerEvent( EV_CleftListRemove );
	registerEvent( EV_CleftListClose );
	registerEvent( EV_CleftListInfo);
}


function OnLoad()
{
	
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	if(CREATE_ON_DEMAND==0)
		Initialize();
	else
		InitializeCOD();

	Me.HideWindow();

	ResetUI();
	
	//class'TeamMatchAPI'.static.RequestExCleftAlldata();
}


function OnShow()
{
	/*local Color A;
	local Color B;
	
	A.R = 114;
	A.G = 173;
	A.B = 255;
	
	B.R = 254;
	B.G = 151;
	B.B = 66;
	
	TeamATitle.SetTextColor( A );
	TeamBTitle.SetTextColor( B );*/
	
}


function Initialize()
{
	Me = GetHandle("CleftEnterWnd");
	ARemainStaff=TextboxHandle(GetHandle("ARemainStaff"));
	BRemainStaff=TextboxHandle(GetHandle("BRemainStaff"));
	TeamATitle=TextboxHandle(GetHandle("TeamATitle"));
	TeamBTitle=TextboxHandle(GetHandle("TeamBTitle"));
	TeamATotalStaff=TextboxHandle(GetHandle("TeamATotalStaff"));
	TeamBTotalStaff=TextboxHandle(GetHandle("TeamBTotalStaff"));
	
	TeamAList=ListCtrlHandle (GetHandle("CleftEnterWnd.TeamAList"));
	TeamBList=ListCtrlHandle (GetHandle("CleftEnterWnd.TeamBList"));
	
	TeamAGroupBox=TextureHandle(GetHandle("TeamAGroupBox"));
	TeamBGroupBox=TextureHandle(GetHandle("TeamBGroupBox"));
	
	btnExit=ButtonHandle (GetHandle("btnExit"));
}

function InitializeCOD()
{
	Me = GetWindowHandle("CleftEnterWnd");
	ARemainStaff=GetTextBoxHandle("CleftEnterWnd.ARemainStaff");
	BRemainStaff=GetTextBoxHandle("CleftEnterWnd.BRemainStaff");
	TeamATitle=GetTextBoxHandle("CleftEnterWnd.TeamATitle");
	TeamBTitle=GetTextBoxHandle("CleftEnterWnd.TeamBTitle");
	TeamATotalStaff=GetTextBoxHandle("CleftEnterWnd.TeamATotalStaff");
	TeamBTotalStaff=GetTextBoxHandle("CleftEnterWnd.TeamBTotalStaff");
	
	TeamAList=GetListCtrlHandle("CleftEnterWnd.TeamAList");
	TeamBList=GetListCtrlHandle("CleftEnterWnd.TeamBList");
	
	TeamAGroupBox=GetTextureHandle("CleftEnterWnd.TeamAGroupBox");
	TeamBGroupBox=GetTextureHandle("CleftEnterWnd.TeamBGroupBox");
	
	btnExit=GetButtonHandle("CleftEnterWnd.btnExit");
	
	//RemainSecTitle=GetTextBoxHandle("RemainSecTitle");
	//RemainSec=GetTextBoxHandle("RemainSec");
}

function OnEvent( int Event_ID, String Param )
{
	//debug ("Event Receivedss" @ Event_ID @ Param);
	switch(Event_ID)
	{
		case EV_CleftListStart :
			HandleCleftListStart(Param);
			break;
		
		case EV_CleftListAdd :
			HandleCleftListAdd(Param);
			break;
		
		case EV_CleftListRemove :
			//debug ("EV_CleftListRemove" @ Param);
			HandleCleftListRemove(Param);
			break;
			
		case EV_CleftListClose :
			HandleCleftListClose();
			break;
		
		case EV_CleftListInfo :
			HandleCleftListInfo(Param);
			break;
	}
}

function ResetUI()
{
	TeamAList.DeleteAllItem();
	TeamATotalStaff.SetText("0");
	TeamBList.DeleteAllItem();
	TeamBTotalStaff.SetText("0");
}

function HandleCleftListStart(string Param)
{
	local int ShowUI;
	ParseInt(Param, "ShowUI", ShowUI );
	
	ResetUI();
	if( ShowUI != 0 )
		Me.ShowWindow();
}

function HandleCleftListAdd(string Param)
{
	//~ local int index;
	//~ local int Count;
	local int TeamID;
	local int PlayerID;
	local string PlayerName;
	
	local LVData Data1;
	local LVData Data2;
	local LVDataRecord Record1;
	local LVDataRecord Record2;
	
	local UserInfo	info;
	
	ParseInt(Param, "TeamID", TeamID );
	ParseInt(Param, "PlayerID", PlayerID);
	ParseString(Param, "PlayerName", PlayerName);
	
	if (GetMyUserInfo(info))
	{
		m_UserID = info.nID;
	}
	
	if (TeamID == TeamA_ID)
	{	
		
		//debug ("ProcData" @ PlayerName @ PlayerID @ TeamID);
		
		//Index = TeamAList.GetRecordCount();
		
		Data1.nReserved1 = TeamID;
		Data1.nReserved2 = PlayerID;
		//Data1.nReserved3 = Index;
		Data1.szData = PlayerName;
		Record1.LVDataList.length = 1;
		Record1.LVDataList[0] = Data1;
		TeamAList.InsertRecord(Record1);
		TeamATotalStaff.SetText(string(TeamAList.GetRecordCount()));
		if ( PlayerID == m_UserID)
		{
			AddSystemMessage(2416);
		}
		
		
	}
	else if (TeamID ==TeamB_ID)
	{

		//debug ("ProcData1" @ PlayerName @ PlayerID @ TeamID);
		//Index = TeamBList.GetRecordCount();
		
		Data2.nReserved1 = TeamID;
		Data2.nReserved2 = PlayerID;
		//Data2.nReserved3 = Index;
		Data2.szData = PlayerName;
		Record2.LVDataList.length = 1;
		Record2.LVDataList[0] = Data2;
		TeamBList.InsertRecord( Record2 );
		TeamBTotalStaff.SetText(string(TeamBList.GetRecordCount()));
		
		if ( PlayerID == m_UserID)
		{
			AddSystemMessage(2415);
		}

		
	}

	UpdateNeedMember();
}

function HandleCleftListRemove(string Param)
{
	local int Count;
	local int TeamID;
	local int PlayerID;
	local LVDataRecord Record1;
	local LVDataRecord Record2;
	
	ParseInt(Param, "TeamID", TeamID );
	ParseInt(Param, "PlayerID", PlayerID);
	
	//debug ("Me Hide Window" @ TeamID @ PlayerID );
	
	
	if (TeamID == TeamA_ID)
	{
		for(count = 0 ; count < TeamAList.GetRecordCount(); count++)
		{
			TeamAList.GetRec(count, Record1);
			if(PlayerID == Record1.LVDataList[0].nReserved2)
				{	
					if( count >= 0 )
					{
						TeamAList.DeleteRecord(count);
						TeamATotalStaff.SetText(string(TeamAList.GetRecordCount()));
					}
				}
		}
		

	}
	
	if (TeamID == TeamB_ID)
	{
		for(count = 0 ; count < TeamBList.GetRecordCount(); count++)
		{
			TeamBList.GetRec(count, Record2);
			if (PlayerID == Record2.LVDataList[0].nReserved2)
			{
				if(count >= 0)
				{
					TeamBList.DeleteRecord(count);
					TeamBTotalStaff.SetText(string(TeamBList.GetRecordCount()));
				}
			}
		}

	}
	
	UpdateNeedMember();
	
}

function HandleCleftListClose()
{
	m_exitbool = true;
	Me.HideWindow();
}



function HandleCleftListInfo(string Param)
{
	local int MinMemberCount ;
	local int bBalancedMatch ;
	
	ParseInt(Param, "MinMemberCount",  MinMemberCount);
	ParseInt(Param, "bBalancedMatch", bBalancedMatch);
		
	m_MinMember = MinMemberCount;
	
	UpdateNeedMember();	
}

//Update Remain Count
function UpdateNeedMember()
{
	local int Count;
	local int Remain;
	
	//Update A
	Count = TeamAList.GetRecordCount();
	if (Count >= m_MinMember)
	{
		Remain = 0;
	}
	else if ( Count < m_MinMember)
	{
		Remain = m_MinMember - Count;
	}
	ARemainStaff.SetText(string(Remain));
	
	//Update B
	Count = TeamBList.GetRecordCount();
	if (Count >= m_MinMember)
	{
		Remain = 0;
	}
	else if ( Count < m_MinMember)
	{
		Remain = m_MinMember - Count;
	}		
	BRemainStaff.SetText(string(Remain));
}

function OnLButtonUp(WindowHandle WindowHandle, int X, int Y)
//~ 특정 컴포넌트에 마우스 클릭중 다운이 들어오면 그 컴포넌트의 윈도우 핸들이름을 알아내 조건이 맞으면 팀입장 요청을 서버에 보냅니다. 일단 기획문서가 이리 되어 있으니...
//~ 한번 만들어 보고 느낌 보고 고쳐보도록 하세요. 
{
	//debug ("Request Clicked");
	switch WindowHandle
	{
		case TeamAList:
			//debug ("Request Clicked Team A");
			class'TeamMatchAPI'.static.RequestExCleftEnter(0);
			break;
			
		case TeamBList:
			//debug ("Request Clicked Team B");
			
			class'TeamMatchAPI'.static.RequestExCleftEnter(1);
			break;
		
	}
			TeamATotalStaff.SetText(string(TeamAList.GetRecordCount()));
			TeamBTotalStaff.SetText(string(TeamBList.GetRecordCount()));
}

function OnClickButton(string ButtonID)
{
	switch(ButtonID)
	{
		case "btnExit":
			//~ m_exitbool= false;
			//~ class'TeamMatchAPI'.static.RequestExCleftEnter(-1);
			//~ ResetUI();
			me.HideWindow();
			break;
	}
}


function OnHide()
{
	 if (!m_exitbool)
	 {
		
			class'TeamMatchAPI'.static.RequestExCleftEnter(-1);
			AddSystemMessage(2418);
			ResetUI();
	 }
	 m_exitbool= false;
}

function bool GetMyUserInfo( out UserInfo a_MyUserInfo )
{
	return GetPlayerInfo( a_MyUserInfo );
}
defaultproperties
{
}
