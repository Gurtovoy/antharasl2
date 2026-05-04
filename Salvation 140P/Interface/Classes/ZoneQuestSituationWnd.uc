class ZoneQuestSituationWnd extends UICommonAPI;

var WindowHandle Me;

var TextBoxHandle ZoneQuestTitle;

var ListCtrlHandle ZoneQuestTopContributorList;

var TextBoxHandle mMyRanking;
var TextBoxHandle mMyName;
var TextBoxHandle mMyBasicContributeScore;
var TextBoxHandle mMyAdditionContributeScore;
var TextBoxHandle mMyTotalContributeScore;

var TextBoxHandle Time;
var TextBoxHandle ParticipantsCounter;


function OnRegisterEvent()
{
	RegisterEvent( EV_ZoneQuestResult );
}

function OnLoad()
{
	OnRegisterEvent();
	Me = GetWindowHandle("ZoneQuestSituationWnd");

	ZoneQuestTitle = GetTextBoxHandle("ZoneQuestSituationWnd.ZoneQuestTitle");

	ZoneQuestTopContributorList = GetListCtrlHandle("ZoneQuestSituationWnd.ZoneQuestTopContributorList");

	mMyRanking = GetTextBoxHandle("ZoneQuestSituationWnd.MyRanking");
	mMyName = GetTextBoxHandle("ZoneQuestSituationWnd.MyName");
	mMyBasicContributeScore = GetTextBoxHandle("ZoneQuestSituationWnd.MyBasicContributeScore");
	mMyAdditionContributeScore = GetTextBoxHandle("ZoneQuestSituationWnd.MyAdditionContributeScore");
	mMyTotalContributeScore = GetTextBoxHandle("ZoneQuestSituationWnd.MyTotalContributeScore");

	Time = GetTextBoxHandle("ZoneQuestSituationWnd.Time");
	ParticipantsCounter = GetTextBoxHandle("ZoneQuestSituationWnd.ParticipantsCounter");	
}


function OnEvent( int Event_ID, string param )
{
	switch( Event_ID )
	{		
		//존퀘스트 왔을 때
		case EV_ZoneQuestResult :
			//Debug("EV_ZoneQuestResult");
			ZoneQuestResult( param );
			break;
	}
}

function ZoneQuestResult( string param )
{
	//5302
	//ID=1 STEP=1 ListCnt=7 MyRanking=3676 MyName=두두두두 MyStandardPoint=678 MyExtraPoint=56 MyTotalPoint=5677 Name_0=aa Name_1=aa1 Name_2=aa2 Name_3=aa3 Name_4=aa4 Name_5=aa5 Name_6=aa6 StandardPoint_0=10 StandardPoint_1=9 StandardPoint_2=8 StandardPoint_3=7 ExtraPoint_0=10 ExtraPoint_1=10 ExtraPoint_2=10 ExtraPoint_3=10 TotalPoint_0=20 TotalPoint_1=19 TotalPoint_2=18 TotalPoint_3=17
	local LVDataRecord Record;

	local int i;
	local int ID;
	local int STEP;
	local int ListCnt;

	local int MyRanking;
	local string MyName;
	local int MyStandardPoint;
	local int MyExtraPoint;
	local int MyTotalPoint;

	local string Name;
	local int StandardPoint;
	local int ExtraPoint;
	local int TotalPoint;

	local DynamicContentInfo info;

	local Color c;

	c.R = 222;
	c.G = 196;
	c.B = 126;

	ZoneQuestTopContributorList.DeleteAllItem();

	Record.LVDataList.length = 5;

	ParseInt(param, "ID", ID);
	ParseInt(param, "STEP", STEP);
	ParseInt(param, "ListCnt", ListCnt);

	ParseInt(param, "MyRanking", MyRanking);
	ParseString(param, "MyName", MyName);
	ParseInt(param, "MyStandardPoint", MyStandardPoint);
	ParseInt(param, "MyExtraPoint", MyExtraPoint);
	ParseInt(param, "MyTotalPoint", MyTotalPoint);

	GetDynamicContentInfo( ID, STEP, info );

	//Debug("param---->>" $ param);
	//Debug( "ID-->" $ string( ID ) );
	//Debug( "STEP-->" $ string( STEP ) );
	//Debug( "ListCnt-->" $ string( ListCnt ) );
 
	//MyName.SetText( MyName );
	mMyRanking.SetText( string(MyRanking) );
	mMyName.SetText( MyName );
	mMyBasicContributeScore.SetText( string(MyStandardPoint) );
	mMyAdditionContributeScore.SetText( string(MyExtraPoint) );
	mMyTotalContributeScore.SetText( string(MyTotalPoint) );
	
	ZoneQuestTitle.SetText( info.Title );
	ZoneQuestTitle.SetTextColor( c );

	for( i = 0 ; i < ListCnt ; i++ )
	{
		ParseString(param, "Name_"$i , Name);
		Parseint(param, "StandardPoint_"$i, StandardPoint);
		Parseint(param, "ExtraPoint_"$i, ExtraPoint);
		Parseint(param, "TotalPoint_"$i, TotalPoint);
		
		Record.LVDataList[0].szData = string( i + 1 );
		Record.LVDataList[1].szData = Name;
		Record.LVDataList[2].szData = string(StandardPoint);
		Record.LVDataList[3].szData = string(ExtraPoint);
		Record.LVDataList[4].szData = string(TotalPoint);

		ZoneQuestTopContributorList.InsertRecord( Record );
	}	
}

/**
 * 시간, 참여 인원 넣어 주기.
 */
function showTimeCounter( string strTime, string strCounter )
{
	Time.SetText( strTime );
	ParticipantsCounter.SetText( strCounter );
}

// 버튼클릭 이벤트
function OnClickButton( string strID )
{
	local ZoneQuestAlarmWnd script;

	script = ZoneQuestAlarmWnd(GetScript("ZoneQuestAlarmWnd"));

	if( strID == "CloseBtn" )
	{
		Me.HideWindow();
	}
	else if( strID == "RewardInfoBtn" )
	{
		//Debug( "mID-->" $ string( script.getZoneQuestID() ) );
		//Debug( "mSTEP-->" $ string( script.getZoneQuestSTEP() ) );
		RequestDynamicContentHtml( script.getZoneQuestID(), script.getZoneQuestSTEP() );
	}
}
defaultproperties
{
}
