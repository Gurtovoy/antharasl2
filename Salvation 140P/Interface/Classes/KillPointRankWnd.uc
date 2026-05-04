class KillPointRankWnd extends UIScript;

struct native constructive KillPointWndData
{
	var String			Name;		
	var Int			KillPoint;
};

var KillPointWndData	m_KillPointData[25];
var WindowHandle 	Me;
var TextBoxHandle 	TopRatedPCName, 	TopRatedKillPC;
var ListCtrlHandle 	RankingListLeft, 		RankingListRight;
var NameCtrlHandle	NameCtrl;
var int 			m_Count;


function OnRegisterEvent()
{
	RegisterEvent( EV_CRATaECUBERECORDBEGIN );
	RegisterEvent( EV_CrataeCubeRecordItem );
	RegisterEvent( EV_CrataeCubeRecordEnd );
	RegisterEvent ( EV_CrataeCubeRecordMyItem );
	RegisterEvent( EV_CrataeCubeRecordRetire );
}

function OnLoad()
{
	if(CREATE_ON_DEMAND==0)
	{
		Me = GetHandle("KillPointRankWnd");
		TopRatedPCName = TextBoxHandle(GetHandle("KillPointRankWnd.TopRatedPCName"));
		TopRatedKillPC = TextBoxHandle(GetHandle("KillPointRankWnd.TopRatedKillPC"));
		RankingListLeft = ListCtrlHandle(GetHandle("KillPointRankWnd.RankingListLeft"));
		RankingListRight = ListCtrlHandle(GetHandle("KillPointRankWnd.RankingListRight"));
		NameCtrl = NameCtrlHandle (GetHandle("StatusWnd.UserName"));
		
	}
	else
	{
		Me = GetWindowHandle("KillPointRankWnd");
		TopRatedPCName = GetTextBoxHandle("KillPointRankWnd.TopRatedPCName");
		TopRatedKillPC = GetTextBoxHandle("KillPointRankWnd.TopRatedKillPC");
		RankingListLeft = GetListCtrlHandle("KillPointRankWnd.RankingListLeft");
		RankingListRight = GetListCtrlHandle("KillPointRankWnd.RankingListRight");
		NameCtrl = GetNameCtrlHandle ("StatusWnd.UserName");
	}
	//~ RegisterEvent( EV_CRATaECUBERECORDBEGIN );
	//~ RegisterEvent( EV_CrataeCubeRecordItem );
	//~ RegisterEvent( EV_CrataeCubeRecordEnd );
	//~ RegisterEvent ( EV_CrataeCubeRecordMyItem );
	//~ RegisterEvent( EV_CrataeCubeRecordRetire );
}

function OnShow()
{
	RequestStartShowCrataeCubeRank();
}

function OnEvent(int Event_ID, string param)
{
	local int StatusInt;
	local string Name;
	local int KillPoint;
	debug ("Event_ID" @ Event_ID);
	switch(Event_ID)
	{
		case EV_CrataeCubeRecordMyItem:
			if (!Me.IsShowWindow())
			{
				//~ Me.ShowWindow();
			}
			
		break;
		case EV_CrataeCubeRecordItem:
			debug("update list" @ param);
			ParseString( param, "Name", Name);
			ParseInt( param, "KillPoint", KillPoint);
			m_KillPointData[m_Count].Name = Name;
			m_KillPointData[m_Count].KillPoint = KillPoint;
			m_Count ++;
		break;
		//~ case EV_CRATaECUBERECORDBEGIN:
		case	EV_CrataeCubeRecordBegin:
			debug ("EV_CrataeCubeRecordItem" @ Param);
			ParseInt( param, "Status", StatusInt);
			m_Count = 0;
			debug("update start");
			switch (StatusInt)
			{
				case 0:
					Me.ShowWindow();
				break;
				case 1:
					m_Count = 0;
					debug("update start");
				break;
				case 2:
					Me.ShowWindow();
				break;
			}
		break;
		case EV_CrataeCubeRecordEnd:
			InsertKillPoint();
			break;
		case EV_CrataeCubeRecordRetire:
			Me.HideWindow();
		break;
	}
}

function OnClickButton( string Name )
{
	if (Name == "btnClose")
	{
		Me.HideWindow();
	}
}

function OnHide()
{
	RequestStopShowCrataeCubeRank();
}

function InsertKillPoint()
{
	local int i;
	local LVDataRecord Record;
	local LVData data1;
	local LVData data2;
	local LVData data3;
	//~ local string temp;

	//~ NameCtrl = NameCtrlHandle (GetHandle("StatusWnd.UserName"));
	RankingListLeft.DeleteAllItem();
	RankingListRight.DeleteAllItem();
	//branch
	TopRatedPCName.SetText("1" @ GetSystemString(1375) @ " " @ m_KillPointData[0].Name);
	//end of branch
	TopRatedKillPC.SetText("Kill Point : " @ string(m_KillPointData[0].KillPoint));
	for (i=1; i<13; i++)
	{
		//~ data1.nReserved1 = TotalCountA;
		data1.szData = String(i+1);
		data2.szData = m_KillPointData[i].Name;
		if (m_KillPointData[i].KillPoint < 9999 && m_KillPointData[i].Name != "")
		{
			data3.szData = string(m_KillPointData[i].KillPoint);
		}
		else
		{
			data3.szData = "";
		}
		Record.LVDataList[0] = data1;
		Record.LVDataList[1] = data2;
		Record.LVDataList[2] = data3;
		RankingListLeft.InsertRecord( Record );
		if (m_KillPointData[i].Name == NameCtrl.GetName() )
		{
			RankingListLeft.SetSelectedIndex( i-1, true);
		}
	}
	for (i=13; i<25; i++)
	{
		//~ data1.nReserved1 = TotalCountA;
		data1.szData = String(i+1);
		data2.szData = m_KillPointData[i].Name;
		if (m_KillPointData[i].KillPoint < 9999 && m_KillPointData[i].Name != "")
		{
			data3.szData = string(m_KillPointData[i].KillPoint);
		}
		else
		{
			data3.szData = "";
		}
		Record.LVDataList[0] = data1;
		Record.LVDataList[1] = data2;
		Record.LVDataList[2] = data3;
		RankingListRight.InsertRecord( Record );
		if (m_KillPointData[i].Name == NameCtrl.GetName())
		{
			RankingListRight.SetSelectedIndex( i-13, true);
		}
		
	}
	for (i=0; i<25; i++)
	{
		m_KillPointData[i].Name = "";
		m_KillPointData[i].KillPoint = 9999;
	}
	m_Count= 0;
}
defaultproperties
{
}
