class BlockEnterWnd extends UICommonAPI;

const TeamRed_ID =1;
const TeamBlue_ID =0;
const TIMER_ID=1026;
const TIMER_DELAY=1000;
const DIALOG_ID_VOTE_REQUEST = 0;

var WindowHandle Me;
var TextboxHandle TeamRed;
var TextboxHandle TeamBlue;
var TextboxHandle TeamRedTotal;
var TextboxHandle TeamBlueTotal;
var TextboxHandle RemainSecTitle;
var TextboxHandle RemainSec;
var TextboxHandle TeamRedTotalTitle;
var TextboxHandle TeamBlueTotalTitle;

var ListCtrlHandle TeamRedList;
var ListCtrlHandle TeamBlueList;

var TextureHandle CountGroupBox;
var TextureHandle TeamRedListGroupBox;
var TextureHandle TeamBlueListGroupBox;
var TextureHandle TeamRedListBDECO;
var TextureHandle TeamBlueListBDECO;


var ButtonHandle btnExit;


 
var int RoomNumber;
var int RemainStartSec;
var bool ShowTime;


function OnRegisterEvent()
{
	registerEvent( EV_BlockListStart ); //이벤트 등록
	registerEvent( EV_BlockListAdd );
	registerEvent( EV_BlockListRemove );
	registerEvent( EV_BlockListClose );
	registerEvent( EV_BlockRemainTime );
	registerEvent( EV_BlockListVote );
	registerEvent( EV_BlockListTimeUpSet );
	registerEvent( EV_DialogOK );
	registerEvent( EV_DialogCancel );
}


function OnLoad()
{
	
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	if(CREATE_ON_DEMAND==0)
		Initialize();
	else
		InitializeCOD();

	RoomNumber = 0;
	RemainStartSec = 10;


	ResetUI();
}


function OnShow()
{
	local Color A;
	local Color B;
	
	B.R = 114;
	B.G = 173;
	B.B = 255;
	
	A.R = 254;
	A.G = 114;
	A.B = 66;
	
	TeamRed.SetTextColor( A );
	TeamBlue.SetTextColor( B );
	Me.SetTimer(TIMER_ID,TIMER_DELAY);
	class'UIAPI_WINDOW'.static.SetWindowTitleByText("BlockEnterWnd", string(RoomNumber+1) $GetSystemString(2016));
	
	ShowTime = false;
	
}
function OnHide()
{
	Me.KillTimer(TIMER_ID);
	class'TeamMatchAPI'.static.RequestExBlockGameEnter(RoomNumber,-1);
	ResetUI();
}
//~ function OnShow()
//~ {
	//~ RequestPVPMatchRecord();
//~ }

function Initialize()
{
	Me = GetHandle("BlockEnterWnd");
	TeamRed=TextboxHandle(GetHandle("TeamRed"));
	TeamBlue=TextboxHandle(GetHandle("TeamBlue"));
	TeamRedTotal=TextboxHandle(GetHandle("TeamRedTotal"));
	TeamBlueTotal=TextboxHandle(GetHandle("TeamBlueTotal"));
	RemainSecTitle=TextboxHandle(GetHandle("RemainSecTitle"));
	RemainSec=TextboxHandle(GetHandle("RemainSec"));
	TeamRedTotalTitle=TextboxHandle(GetHandle("TeamRedTotalTitle"));
	TeamBlueTotalTitle=TextboxHandle(GetHandle("TeamBlueTotalTitle"));
	
	TeamRedList=ListCtrlHandle (GetHandle("TeamRedList"));
	TeamBlueList=ListCtrlHandle (GetHandle("TeamBlueList"));
	
	CountGroupBox=TextureHandle(GetHandle("CountGroupBox"));
	TeamRedListGroupBox=TextureHandle(GetHandle("TeamRedListGroupBox"));
	TeamBlueListGroupBox=TextureHandle(GetHandle("TeamBlueListGroupBox"));
	TeamRedListBDECO=TextureHandle(GetHandle("TeamRedListBDECO"));
	TeamBlueListBDECO=TextureHandle(GetHandle("TeamBlueListBDECO"));	
	
	btnExit=ButtonHandle (GetHandle("btnExit"));
	//class'TeamMatchAPI'.static.RequestBlockGameAlldata();
}

function InitializeCOD()
{
	Me = GetWindowHandle("BlockEnterWnd");

	TeamRed=GetTextboxHandle("BlockEnterWnd.TeamRed");
	TeamBlue=GetTextboxHandle("BlockEnterWnd.TeamBlue");
	TeamRedTotal=GetTextboxHandle("BlockEnterWnd.TeamRedTotal");
	TeamBlueTotal=GetTextboxHandle("BlockEnterWnd.TeamBlueTotal");
	RemainSecTitle=GetTextboxHandle("BlockEnterWnd.RemainSecTitle");
	RemainSec=GetTextboxHandle("BlockEnterWnd.RemainSec");
	TeamRedTotalTitle=GetTextboxHandle("BlockEnterWnd.TeamRedTotalTitle");
	TeamBlueTotalTitle=GetTextboxHandle("BlockEnterWnd.TeamBlueTotalTitle");
	
	TeamRedList=GetListCtrlHandle ("BlockEnterWnd.TeamRedList");
	TeamBlueList=GetListCtrlHandle ("BlockEnterWnd.TeamBlueList");
	
	CountGroupBox=GetTextureHandle("BlockEnterWnd.CountGroupBox");
	TeamRedListGroupBox=GetTextureHandle("BlockEnterWnd.TeamRedListGroupBox");
	TeamBlueListGroupBox=GetTextureHandle("BlockEnterWnd.TeamBlueListGroupBox");
	TeamRedListBDECO=GetTextureHandle("BlockEnterWnd.TeamRedListBDECO");
	TeamBlueListBDECO=GetTextureHandle("BlockEnterWnd.TeamBlueListBDECO");	
	
	btnExit=GetButtonHandle("btnExit");
	
	//RemainSecTitle=GetTextBoxHandle("RemainSecTitle");
	//RemainSec=GetTextBoxHandle("RemainSec");
	//class'TeamMatchAPI'.static.RequestBlockGameAlldata();
}

function OnEvent( int Event_ID, String Param )
{
//	debug ("Event Receivedss" @ Event_ID @ Param);
	switch(Event_ID)
	{
		case EV_BlockListStart :
			HandleBlockListStart(Param);
			break;				
		case EV_BlockListAdd :			
			HandleBlockListAdd(Param);
			break;
		
		case EV_BlockListRemove :
			//debug ("EV_CleftListRemove" @ Param);
			HandleBlockListRemove(Param);
			break;
		case EV_BlockListClose :
			HandleBlockListClose();
			break;
		case EV_BlockRemainTime :			
			HandleBlockRemainTime(Param);
			break;
		case EV_BlockListVote  :
			HandleStartVote();			
			break;
		case EV_BlockListTimeUpSet:			
			ShowTime = true ;
			break;
		case EV_DialogOK:
			HandleDialogOK();
			break;
		case EV_DialogCancel:
			HandleDialogCancel();
			break;
			
		
	}
}

function ResetUI()
{
	TeamRedList.DeleteAllItem();
	TeamRedTotal.SetText("0");
	TeamBlueList.DeleteAllItem();
	TeamBlueTotal.SetText("0");
}

function HandleBlockListStart(string Param )
{
	
	ParseInt(Param, "RoomNumber", RoomNumber );
	
	
	if (!me.IsShowWindow())
	{
		me.Showwindow();
		me.SetFocus();
	}

	ResetUI();

}

function HandleBlockListAdd(string Param)
{
	local int TeamID;
	local int PlayerID;
	local string PlayerName;
	
//	local int index ;
	
	local LVData Data1;
	local LVData Data2;
	local LVDataRecord Record1;
	local LVDataRecord Record2;
	
	ParseInt(Param, "TeamID", TeamID );
	ParseInt(Param, "PlayerID", PlayerID);
	ParseString(Param, "PlayerName", PlayerName);
	
	if (TeamID == TeamRED_ID)
	{	
		 
		/*if (TeamATotalCount == 0 )
		{
			PartyNameADesktop.SetText(MakefullSystemMsg(GetSystemMessage(2277),PlayerName,""));
			PartyNameA.SetText(PlayerName);
		}*/
		
	//	debug ("ProcData" @ PlayerName @ PlayerID @ TeamID);
		
	//	Index = TeamRedList.GetRecordCount();
		
		Data1.nReserved1 = TeamID;
		Data1.nReserved2 = PlayerID;
	//	Data1.nReserved3 = Index;
		Data1.szData = PlayerName;
		Record1.LVDataList[0] = Data1;
		TeamRedList.InsertRecord(Record1);
		TeamRedTotal.SetText(string(TeamRedList.GetRecordCount()));
		
		
	}
	else if (TeamID ==TeamBlue_ID)
	{
		/*if (TeamATotalCount == 0 )
		{
			PartyNameADesktop.SetText(MakefullSystemMsg(GetSystemMessage(2277),PlayerName,""));
			PartyNameA.SetText(PlayerName);
		}*/
		//debug ("ProcData1" @ PlayerName @ PlayerID @ TeamID);
		
//		Index = TeamBlueList.GetRecordCount();
		
		Data2.nReserved1 = TeamID;
		Data2.nReserved2 = PlayerID;
	//	Data2.nReserved3 = Index;
		Data2.szData = PlayerName;
		Record2.LVDataList[0] = Data2;
		TeamBlueList.InsertRecord( Record2 );
		TeamBlueTotal.SetText(string(TeamBlueList.GetRecordCount()));
		
		

		
	}
	

}

function HandleBlockListRemove(string Param)
{
	local int TeamID;
	local int PlayerID;
	local int count;
	local LVDataRecord Record1;
	local LVDataRecord Record2;
	
	ParseInt(Param, "TeamID", TeamID );
	ParseInt(Param, "PlayerID", PlayerID);	

	//debug ("Me Hide Window" @ TeamID @ PlayerID );
	
	if (TeamID == TeamRED_ID)
	{
		for(count = 0 ; count < TeamRedList.GetRecordCount(); count++)
		{
			TeamRedList.GetRec(count, Record1);
			if(PlayerID == Record1.LVDataList[0].nReserved2)
			{
				if(count >= 0)
				{
					TeamRedList.DeleteRecord(count);
					TeamRedTotal.SetText(string(TeamRedList.GetRecordCount()));
				}				
				//TeamRedTotal.SetText(string(TeamAList.GetRecordCount()));
				break;
			}
		}		
	}
	
	if (TeamID == TeamBlue_ID)
	{
		for(count = 0 ; count < TeamBlueList.GetRecordCount(); count++)
		{
			TeamBlueList.GetRec(count, Record2);
			if(PlayerID == Record2.LVDataList[0].nReserved2)
			{	
				if(count >= 0)
				{
					TeamBlueList.DeleteRecord(count);
					TeamBlueTotal.SetText(string(TeamBlueList.GetRecordCount()));
				}							
				//TeamBlueTotal.SetText(string(TeamAList.GetRecordCount()));
				break;
			}
		}	
	}
}

function HandleBlockListClose()
{
	local String InSecStr;
	InSecStr = " ";
//	debug("Timer : " @ secStr @ RemainStartSec);
	RemainSec.SetText(InSecStr);
	
	Me.HideWindow();
	ResetUI();
	ShowTime = false;
}

function HandleBlockRemainTime(String Param)
{
	ParseInt(Param, "RemainTime", RemainStartSec );
}

function OnLButtonUp(WindowHandle WindowHandle, int X, int Y)
//~ 특정 컴포넌트에 마우스 클릭중 다운이 들어오면 그 컴포넌트의 윈도우 핸들이름을 알아내 조건이 맞으면 팀입장 요청을 서버에 보냅니다. 일단 기획문서가 이리 되어 있으니...
//~ 한번 만들어 보고 느낌 보고 고쳐보도록 하세요. 
{
	//debug ("Request Clicked");
	switch (WindowHandle)
	{
		case TeamBlueList:
			//debug ("Request Clicked Team A");
		
			class'TeamMatchAPI'.static.RequestExBlockGameEnter(RoomNumber, 0);

			break;
			
		case TeamRedList:
			//debug ("Request Clicked Team B");
			
			class'TeamMatchAPI'.static.RequestExBlockGameEnter(RoomNumber,1);
			
			break;
		
	}

}

function OnClickButton(string ButtonID)
{
	switch(ButtonID)
	{
		case "btnExit":			
			if (Me.IsShowWindow())
				Me.HideWindow();
			
			class'TeamMatchAPI'.static.RequestExBlockGameEnter(RoomNumber,-1);
			//HandleCleftListClose();
			//테스트를 위해서 초기화 상태 설정
		break;		

	}
}

function OnTimer(int TimerID)
{	
//	debug ("OnTimer0 " @ShowTime @RemainStartSec);
	if(TimerID == TIMER_ID)
	{
//		debug ("OnTimer1 " @ShowTime @RemainStartSec);	
		if (ShowTime)
		{		
//			debug ("OnTimer2 " @ShowTime @RemainStartSec);	
			if ( RemainStartSec > 0 )
			{
//				debug ("OnTimer3 " @ShowTime @RemainStartSec);
				RemainStartSec--;
				UpdateTimerCount();
			}
		}
	}
}
function HandleStartVote()
{
	// 다이얼로그가 열려 있으면 무조건 취소를 누른 것과 같도록 한다.
	if ( IsShowWindow("DialogBox"))
	{
		class'TeamMatchAPI'.static.RequestExBlockGameVote(RoomNumber ,0);
		return;
	}

	DialogSetID( DIALOG_ID_VOTE_REQUEST );
	DialogSetCancelD(DIALOG_ID_VOTE_REQUEST);
	DialogSetParamInt64( 10*1000 );	// 10 seconds
	DialogSetDefaultOK();
	DialogShow(DialogModalType_Modalless, DialogType_Progress, GetSystemMessage(2467), string(Self));	
}

function HandleDialogOK()
{
	if(DialogIsMine())
	{
		if( DialogGetID() == DIALOG_ID_VOTE_REQUEST)
		{
	//		debug("Vote Ok");
			class'TeamMatchAPI'.static.RequestExBlockGameVote(RoomNumber ,1);		
		}
	}
}

function HandleDialogCancel()
{
	if(DialogIsMine())
	{
		if( DialogCheckCancelByID(DIALOG_ID_VOTE_REQUEST))
		{
			//	debug("Vote Cancle");
			class'TeamMatchAPI'.static.RequestExBlockGameVote(RoomNumber ,0);
		}
	}	
}

function UpdateTimerCount()
{
	local String SecStr;
//	debug ("OnTimer4 " @ShowTime @RemainStartSec);
	SecStr = String(RemainStartSec);
	
	if (RemainStartSec < 10)
		SecStr = "0" $ SecStr $ GetSystemString(2001);
//	debug("Timer : " @ secStr @ RemainStartSec);
	RemainSec.SetText(SecStr);
}
/*
function HandleCleftStateTeam(string Param)
{
	local int TeamID;
	local int TeamPoint;
	local int CATID;
	local int RemainSec;
	local int CurrentState;
	
	
	local int BlueTeamTotalKillCnt;
	local int RedTeamTotalKillCnt;
	local int WinnerIndex;
	local int LoserIndex;
	
	ParseInt(Param, "TeamID", TeamID );
	ParseInt(Param, "TeamPoint", TeamPoint);
	ParseInt(Param, "CATID", CATID);
	ParseInt(Param, "RemainSec", RemainSec);
	
	TotalCountA = 0;
	TotalCountB = 0;
	
	
	RemainSec.SetText(String(RemainSec));
	
	switch (TeamID)
	{
		case 1:
		CountA.SetText(String(TeamPoint));
		CATA.SetText(String()) 케릭터 아이디 받아서 플레이어의 이름을 날려줌
		CleftListA.DeleteAllItem();
		break;
		
		case 2:
		CountB.SetText(String(TeamPoint));
		CATB.SetText(String()); 케릭터 아이디 받아서 플레이어의 이름을 날려줌1
		CleftListB.DeleteAllItem();
		break;
	
		
	}*/
	
defaultproperties
{
}
