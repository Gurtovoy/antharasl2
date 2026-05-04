class BR_MiniGameRankWnd extends UICommonAPI;

var WindowHandle Me;
var ListCtrlHandle 	RankingList;
var TextBoxHandle 	TextBoxRank;
var TextBoxHandle 	TextBoxMsg;

var int MyBestScore;

const	TIMER_ID1	=	2001;	
const	TIMER_ID2	= 	2002;
const	TIMER_ID3	=	2003;	
const	TIMER_ID4	= 	2004;

function OnRegisterEvent()
{
	RegisterEvent( EV_BR_MinigameMyRanking );	
	RegisterEvent( EV_BR_MinigameAllRanking );
}

function OnLoad()
{
	Initialize();		
}

function Initialize()
{
	if (CREATE_ON_DEMAND==0) {
		Me = GetHandle( "BR_MiniGameRankWnd" );
		RankingList = ListCtrlHandle(GetHandle("BR_MiniGameRankWnd.RankingList"));
		TextBoxRank = TextBoxHandle(GetHandle("BR_MiniGameRankWnd.TextBoxRank"));
		TextBoxMsg = TextBoxHandle(GetHandle("BR_MiniGameRankWnd.TextBoxMsg"));
	}
	else
	{
		Me = GetWindowHandle( "BR_MiniGameRankWnd" );
		RankingList = GetListCtrlHandle("BR_MiniGameRankWnd.RankingList");
		TextBoxRank = GetTextBoxHandle("BR_MiniGameRankWnd.TextBoxRank");
		TextBoxMsg = GetTextBoxHandle("BR_MiniGameRankWnd.TextBoxMsg");
	}
	Me.SetWindowTitle(GetSystemString(1730)$" "$GetSystemString(1320));
	MyBestScore = 0;
}

function OnEvent(int Event_ID, String param)
{
	local int MyRanking;
	local int MyScore;
	local int LastScore;
	local int Ranking;
	local String CharName;
	local int Score;
	
	switch( Event_ID )
	{			
	case EV_BR_MinigameMyRanking : 
		RankingList.DeleteAllItem();
		ParseInt( param, "MyRanking", MyRanking ); // 나의 최고 랭킹
		ParseInt( param, "MyScore", MyScore );     // 나의 최고 점수
		//ParseInt( param, "LastRanking", LastRanking );  // 현재 이 값은 사용하지 않음  
		ParseInt( param, "LastScore", LastScore );    
		SetMyRank( MyRanking, MyScore, LastScore );
		break;	
	case EV_BR_MinigameAllRanking : 
		ParseInt( param, "Ranking", Ranking );      
		ParseString( param, "CharName", CharName ); 
		ParseInt( param, "Score", Score );	
		ShowRank( Ranking, CharName, Score );
		break;
	}	
}

function SetMyRank(int MyRanking, int MyScore, int LastScore)
{
	if(MyRanking==0) { // 랭킹이 1000명 안에 들지 못한 경우
		TextBoxRank.SetText( GetSystemString(5058) $ ": " $ GetSystemString(1374) $ " (" $ MakeFullSystemMsg(GetSystemMessage(6036),String(LastScore),"") $ ")");
		TextBoxMsg.SetText( MakeFullSystemMsg(GetSystemMessage(6033),"100","1000") );	
	}
	else { // 랭킹이 1000명 안에 드는 경우
		TextBoxRank.SetText( GetSystemString(5058) $ ": " $ String(MyRanking) $ GetSystemString(1375) $ "   " $ GetSystemString(5059) $ " : " $ String(MyScore) $ GetSystemString(1442));
		TextBoxMsg.SetText( GetSystemMessage(6035) );
		if(MyBestScore==0) {
			MyBestScore=MyScore;
		}
		else if(MyScore>MyBestScore) { // 최고 점수가 갱신된 경우
			Me.SetTimer(TIMER_ID1, 200); // 텍스트를 깜빡여서 강조함
			MyBestScore=MyScore;
		}
	}
}

function ShowRank(int Ranking, String CharName, int Score)
{
	local LVDataRecord record;
	
	local LVData data1, data2, data3;
	
	local Color RankColor, BestColor;
	
	RankColor.R = 130; 	RankColor.G = 130; 	RankColor.B = 130;		
	
	data1.bUseTextColor	= True;
	data1.TextColor = RankColor;	
	if(Ranking==1) {
		BestColor.R = 255; 	BestColor.G = 255; 	BestColor.B = 51;			
		data2.bUseTextColor	= True;
		data3.bUseTextColor	= True;
		data2.TextColor = BestColor;	
		data3.TextColor = BestColor;	
	}
	else if(Ranking==2) {
		BestColor.R = 255; 	BestColor.G = 255; 	BestColor.B = 153;	
		data2.bUseTextColor	= True;
		data3.bUseTextColor	= True;
		data2.TextColor = BestColor;	
		data3.TextColor = BestColor;	
	}
	else if(Ranking==3) {
		BestColor.R = 204; 	BestColor.G = 204; 	BestColor.B = 120;	
		data2.bUseTextColor	= True;
		data3.bUseTextColor	= True;
		data2.TextColor = BestColor;	
		data3.TextColor = BestColor;	
	}	
	
	data1.szData = String(Ranking);	
	data2.szData = CharName;		
	data3.szData = String(Score);		
	
	record.LVDataList.length = 3;			
	record.LVDataList[0] = data1;
	record.LVDataList[1] = data2;
	record.LVDataList[2] = data3;	
	
	RankingList.InsertRecord(record);	
}

function OnTimer(int TimerID)
{
	if(TimerID == TIMER_ID1)
	{
		TextBoxRank.HideWindow();
		Me.KillTimer( TIMER_ID1 );
		Me.SetTimer(TIMER_ID2, 200);		
	}
	else if(TimerID == TIMER_ID2)
	{
		TextBoxRank.ShowWindow();
		Me.KillTimer( TIMER_ID2 );
		Me.SetTimer(TIMER_ID3, 200);	
	}	
	else if(TimerID == TIMER_ID3)
	{
		TextBoxRank.HideWindow();
		Me.KillTimer( TIMER_ID3 );
		Me.SetTimer(TIMER_ID4, 200);	
	}	
	else if(TimerID == TIMER_ID4)
	{
		TextBoxRank.ShowWindow();
		Me.KillTimer( TIMER_ID4 );
	}	
}
defaultproperties
{
}
