class CampaignTopContributorListWnd extends UICommonAPI;

var WindowHandle Me;

var TextBoxHandle CampaignTitle;

var ListCtrlHandle CampaignTopContributorList;

function OnRegisterEvent()
{
	RegisterEvent( EV_CampaignResult );
}

function OnLoad()
{
	OnRegisterEvent();
	Me = GetWindowHandle("CampaignTopContributorListWnd");

	CampaignTitle = GetTextBoxHandle("CampaignTopContributorListWnd.CampaignTitle");

	CampaignTopContributorList = GetListCtrlHandle("CampaignTopContributorListWnd.CampaignTopContributorList");
}

function OnEvent( int Event_ID, string param )
{
	switch( Event_ID )
	{		
		//존퀘스트 왔을 때
		case EV_CampaignResult :
			//Debug("EV_CampaignResult");
			CampaignResult( param );
			break;
	}
}

function CampaignResult( string param )
{
	//5301
	//ID=1 STEP=1 ListCnt=7 Name_0=aa Name_1=aa1 Name_2=aa2 Name_3=aa3 Name_4=aa4 Name_5=aa5 Name_6=aa6
	local LVDataRecord Record;

	local int i;
	local int ID;
	local int STEP;
	local int ListCnt;
	local string Name;

	local DynamicContentInfo info;

	local Color c;

	c.R = 222;
	c.G = 196;
	c.B = 126;

	CampaignTopContributorList.DeleteAllItem();

	Record.LVDataList.length = 1;

	ParseInt(param, "ID", ID);
	ParseInt(param, "STEP", STEP);
	ParseInt(param, "ListCnt", ListCnt);

	GetDynamicContentInfo( ID, STEP, info );
/*
	Debug( "ID-->" $ string( ID ) );
	Debug( "STEP-->" $ string( STEP ) );
	Debug( "ListCnt-->" $ string( ListCnt ) );
*/	
	CampaignTitle.SetText( info.Title );
	CampaignTitle.SetTextColor( c );

	//<TextColor R="222" G="196" B="126"/>

	for( i = 0 ; i < ListCnt ; i++ )
	{
		ParseString(param, "Name_"$i , Name);		

		Record.LVDataList[0].szData = Name;

		CampaignTopContributorList.InsertRecord( Record );
	}
	Me.ShowWindow();
}

// 버튼클릭 이벤트
function OnClickButton( string strID )
{
	//Debug("strID>>>" $ strID );

	if( strID == "btnExit" )
	{
		Me.HideWindow();
	}
}
defaultproperties
{
}
