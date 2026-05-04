class PVPDetailedWnd extends UIScript;

var WindowHandle Me;
var TextboxHandle CountA;
var TextboxHandle CountB;
var TextboxHandle PartyNameA;
var TextboxHandle PartyNameB;
//파티의 이름을 삽입하는 곳
var TextboxHandle PartyNameADesktop;
var TextboxHandle PartyNameBDesktop;
var ListCtrlHandle PKListA;
var ListCtrlHandle PKListB;
var ButtonHandle btnClose;
var TextureHandle ResultA;
var TextureHandle ResultB;
var TextureHandle ResultBWin;
var TextureHandle PKListAGroupBox;
var TextureHandle PKListBGroupBox;
var TextboxHandle TimerCountTitle;
var TextboxHandle TimerCount;

//~ var TextureHandle PKListADECO;
//~ var TextureHandle PKListBDECO;

var int TotalCountA;
var int TotalCountB;

function OnRegisterEvent()
{
    registerEvent( EV_PVPMatchRecord );
	registerEvent( EV_PVPMatchRecordEachUserInfo );
	registerEvent( EV_PVPMatchUserDie );
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
}

function OnShow()
{
	local Color A;
	local Color B;
	local Color Gold;
	
	A.R = 114;
	A.G = 173;
	A.B = 255;
	
	B.R = 254;
	B.G = 151;
	B.B = 66;
	
	Gold.R = 176;
	Gold.G = 153;
	Gold.B  = 121;
	
	
	CountA.SetTextColor( A );
	CountB.SetTextColor( B );
	
	PartyNameA.SetTextColor (Gold);
	PartyNameB.SetTextColor (Gold);
	
}

//~ function OnShow()
//~ {
	//~ RequestPVPMatchRecord();
//~ }

function Initialize()
{
	Me = GetHandle("PVPDetailedWnd");
	CountA=TextboxHandle(GetHandle("CountA"));
	CountB=TextboxHandle(GetHandle("CountB"));
	PartyNameA=TextboxHandle(GetHandle("PartyNameA"));
	PartyNameB=TextboxHandle(GetHandle("PartyNameB"));
	PKListA=ListCtrlHandle (GetHandle("PKListA"));
	PKListB=ListCtrlHandle (GetHandle("PKListB"));
	btnClose=ButtonHandle (GetHandle("btnClose"));
	ResultA=TextureHandle(GetHandle("ResultA"));
	ResultB=TextureHandle(GetHandle("ResultB"));
	ResultBWin =TextureHandle(GetHandle("ResultBWin"));
	PKListAGroupBox=TextureHandle(GetHandle("PKListAGroupBox"));
	PKListBGroupBox=TextureHandle(GetHandle("PKListBGroupBox"));
	//~ PKListADECO=TextureHandle(GetHandle("PKListADECO"));
	//~ PKListBDECO=TextureHandle(GetHandle("PKListBDECO"));
	PartyNameADesktop = TextboxHandle(GetHandle("PVPCounter.PartyNameA"));
	PartyNameBDesktop = TextboxHandle(GetHandle("PVPCounter.PartyNameB"));
	TimerCountTitle=TextboxHandle(GetHandle("TimerCountTitle"));
	TimerCount=TextboxHandle(GetHandle("TimerCount"));
}

function InitializeCOD()
{
	Me = GetWindowHandle("PVPDetailedWnd");
	CountA=GetTextBoxHandle("CountA");
	CountB=GetTextBoxHandle("CountB");
	PartyNameA=GetTextBoxHandle("PartyNameA");
	PartyNameB=GetTextBoxHandle("PartyNameB");
	PKListA=GetListCtrlHandle("PKListA");
	PKListB=GetListCtrlHandle("PKListB");
	btnClose=GetButtonHandle("btnClose");
	ResultA=GetTextureHandle("ResultA");
	ResultB=GetTextureHandle("ResultB");
	ResultBWin =GetTextureHandle("ResultBWin");
	PKListAGroupBox=GetTextureHandle("PKListAGroupBox");
	PKListBGroupBox=GetTextureHandle("PKListBGroupBox");
	PartyNameADesktop = GetTextBoxHandle("PVPCounter.PartyNameA");
	PartyNameBDesktop = GetTextBoxHandle("PVPCounter.PartyNameB");
	TimerCountTitle=GetTextBoxHandle("TimerCountTitle");
	TimerCount=GetTextBoxHandle("TimerCount");
}

function OnEvent( int a_EventID, String a_Param )
{
	switch( a_EventID )
	{
	case EV_PVPMatchRecord:
		HandlePVPMatchRecord(a_Param);
		break;
	case EV_PVPMatchRecordEachUserInfo:
		HandlePVPMatchRecordEachUserInfo(a_Param);
		break;
	case EV_PVPMatchUserDie:
		HandlePVPMatchUserDie(a_Param);
		break;
	}
}

function HandlePVPMatchRecord(string Param)
{
	local int CurrentState;
	local int BlueTeamTotalKillCnt;
	local int RedTeamTotalKillCnt;
	local int WinnerIndex;
	local int LoserIndex;
	
	ParseInt(Param, "CurrentState", CurrentState );
	ParseInt(Param, "BlueTeamTotalKillCnt", BlueTeamTotalKillCnt);
	ParseInt(Param, "RedTeamTotalKillCnt", RedTeamTotalKillCnt);
	ParseInt(Param, "WinnerIndex", WinnerIndex);
	ParseInt(Param, "LoserIndex", LoserIndex);
	
	TotalCountA = 0;
	TotalCountB = 0;
	
	switch (CurrentState)
	{
		case 0:
			//경기시작
			ResetUI();
			PKListA.DeleteAllItem();
			PKListB.DeleteAllItem();
			break;
		case 1:
			//경기 중
			CountA.SetText(String(BlueTeamTotalKillCnt));
			CountB.SetText(String(RedTeamTotalKillCnt));
			PKListA.DeleteAllItem();
			PKListB.DeleteAllItem();
			break;
		case 2:
			//경기종료
			PKListA.DeleteAllItem();
			PKListB.DeleteAllItem();
			CountA.SetText(String(BlueTeamTotalKillCnt));
			CountB.SetText(String(RedTeamTotalKillCnt));
			Me.ShowWindow(); 
			FinalCount(WinnerIndex, LoserIndex);
			break;
	}
}


function HandlePVPMatchRecordEachUserInfo(string Param)
{
	local int Team;
	local String PlayerName;
	local int KillCnt;
	local int DeathCnt;
	
	local LVDataRecord Record;
	local LVData data1;
	local LVData data2;
	local LVData data3;
	//~ local LVData data4;
	//~ local LVData data5;
	//~ local LVData data6;
	
	ParseInt(Param, "Team", Team);
	ParseInt(Param, "KillCnt", KillCnt);
	ParseInt(Param, "DeathCnt", DeathCnt);
	ParseString(Param, "PlayerName", PlayerName);
	
	//debug (Param);
	if (Team == 1)
	{	
		if (TotalCountA == 0 )
		{
			PartyNameADesktop.SetText(MakefullSystemMsg(GetSystemMessage(2277),PlayerName,""));
			PartyNameA.SetText(PlayerName);
		}
		
		data1.nReserved1 = TotalCountA;
		data1.szData = PlayerName;
		data2.szData = String(KillCnt);
		data3.szData = String(DeathCnt);
		Record.LVDataList[0] = data1;
		Record.LVDataList[1] = data2;
		Record.LVDataList[2] = data3;
		
		PKListA.InsertRecord( Record );
		
		TotalCountA = TotalCountA +1;
	}
	else if (Team == 2)
	{
		if (TotalCountB == 0 )
		{
			PartyNameBDesktop.SetText(MakefullSystemMsg(GetSystemMessage(2277),PlayerName,""));
			PartyNameB.SetText(PlayerName);
		}
		//~ .DeleteAllItem();
		data1.nReserved1 = TotalCountB;
		data1.szData = PlayerName;
		data2.szData = String(KillCnt);
		data3.szData = String(DeathCnt);
		Record.LVDataList[0] = data1;
		Record.LVDataList[1] = data2;
		Record.LVDataList[2] = data3;
		PKListB.InsertRecord( Record );
		
		TotalCountB = TotalCountB +1;
	}
	
	
}

function HandlePVPMatchUserDie(string Param)
{
	local int BlueTeamKillCnt;
	local int RedTeamKillCnt;
	
	ParseInt(Param, "BlueTeamKillCnt", BlueTeamKillCnt);
	ParseInt(Param, "RedTeamKillCnt", RedTeamKillCnt );
	
	UpdateCurrentStat(BlueTeamKillCnt, RedTeamKillCnt);
	
	RequestPVPMatchRecord();
	/*
	if (Me.IsShowWindow())
	{
		RequestPVPMatchRecord();
	}*/
}

function OnClickButton( string Name )
{
	//debug ("Button Clicked1");
	switch( Name )
	{
		case "btnClose": 
			Me.HideWindow();
			break;
	}
}


function ResetUI()
{
	//~ CountA.SetText("0");
	//~ CountB.SetText("0");
	PartyNameA.SetText("");
	PartyNameB.SetText("");
	//~ PKListA=ListCtrlHandle (GetHandle("PKListA"));
	//~ PKListB=ListCtrlHandle (GetHandle("PKListB"));
	PKListA.DeleteAllItem();
	PKListB.DeleteAllItem();
	//~ btnClose=ButtonHandle (GetHandle("btnClose"));
	ResultA.HideWindow();
	ResultB.HideWindow();
	ResultBWin.HideWindow();
	//~ PKListAGroupBox.HideWindow();
	//~ PKListBGroupBox.HideWindow();
	//~ PKListADECO.HideWindow();
	//~ PKListBDECO.HideWindow();
	PartyNameADesktop.SetText("");
	PartyNameBDesktop.SetText("");
}

function FinalCount(int WinnerIndex, int LoserIndex)
{
	//~ PKListADECO.ShowWindow();
	//~ PKListBDECO.ShowWindow();
	//debug ("승패확인A =" @ WinnerIndex @ "B=" @ LoserIndex);
	
	TimerCountTitle.HideWindow();
	TimerCount.HideWindow();
	
	if (WinnerIndex == 1 && LoserIndex  == 2)
	{
		//~ ResultA.SetTextureSize(121,58);
		//~ ResultB.SetTextureSize(159,58);
		
		
		
		//~ ResultA.SetWindowSize(121, 58);
		//~ ResultB.SetWindowSize(159, 58);
		
		ResultA.SetTexture("L2UI_CT1.PVP_DF_Result_Win");
		ResultB.SetTexture("L2UI_CT1.PVP_DF_Result_Lose");
		//~ ResultA.ClearAnchor();
		//~ ResultB.ClearAnchor();
		
		//~ ResultA.SetAnchor( "Me", "TopLeft", "TopLeft", 9, 38 );
		//~ ResultB.SetAnchor( "Me", "TopLeft", "TopLeft", 392, 38 );
		
		
		ResultA.ShowWindow();
		ResultB.ShowWindow();
		
		//~ ResultA.MoveTo(9, 38);
		//~ ResultB.MoveTo(430, 38);
	}
	else if (WinnerIndex == 2 && LoserIndex  == 1)
	{
		//~ ResultA.SetTextureSize(159,58);
		//~ ResultB.SetTextureSize(121,58);
		//~ ResultB.ClearAnchor();
		//~ ResultB.ClearAnchor();
		
		//~ ResultA.SetAnchor( "Me", "TopLeft", "TopLeft", 9, 38 );
		//~ ResultB.SetAnchor( "Me", "TopRight", "TopRight", 430, 38 );
		
		//~ ResultA.MoveTo(9, 38);
		//~ ResultB.MoveTo(392, 38);
		
		//~ ResultA.SetWindowSize(121, 58);
		//~ ResultB.SetWindowSize(159, 58);
		
		ResultA.SetTexture("L2UI_CT1.PVP_DF_Result_Lose");
		ResultBWin.SetTexture("L2UI_CT1.PVP_DF_Result_Win");
		//~ ResultB.ClearAnchor();
		//~ ResultB.ClearAnchor();
		
		ResultA.ShowWindow();
		//~ ResultB.ShowWindow();
		ResultBWin.ShowWindow();
		//~ ResultA.MoveTo(9, 38);
		//~ ResultB.MoveTo(392, 38);
	}
	else if (WinnerIndex == 0 && LoserIndex  == 0)
	{
		ResultA.HideWindow();
		ResultB.HideWindow();
		ResultBWin.HideWindow();
	}
	
}


function UpdateCurrentStat(int BlueCountInt, int RedCountInt)
{
	CountA.SetText(String(BlueCountInt));
	CountB.SetText(String(RedCountInt));
}
defaultproperties
{
}
