//----------------------------------------------------------------------------------------------------------------------------------------------------------
//  제목 : 공성전 현황 (특화서버) UI
// 
// 47번 서버
// 10070 SeasonMaxCount=4 nChoiceSeason=0 SeasonWinPledgeName="니야옹" SeasonWinPledgeID=1 SeasonWinAllianceID=1 SeasonCount=3 
//----------------------------------------------------------------------------------------------------------------------------------------------------------
class SiegeReportWnd extends UICommonAPI;

const TIME_ID    = 2001114;
const TIME_DELAY = 1000;

var WindowHandle  Me;
var TextureHandle GroupBoxBg1_Texture;
var TextureHandle GroupBoxBg2_Texture;
var TextBoxHandle SiegeReportDiscription_text;

var WindowHandle  MonthRankingNo1Wnd;
var TextBoxHandle MonthRankingNo1Wnd_Title_text;
var TextBoxHandle MonthRankingNo1Wnd_Name_text;
var TextureHandle MonthWnd_PledgeCrest_texture;
var TextureHandle MonthWnd_PledgeAllianceCrest_texture;

// 지난 달 랭킹 윈도우
var WindowHandle LastMonthRankingNo1Wnd;
var TextBoxHandle LastMonthRankingNo1Wnd_Title_text;
var TextBoxHandle LastMonthRankingNo1Wnd_Name_text;
var TextureHandle LastMonthWnd_PledgeCrest_texture;
var TextureHandle LastMonthWnd_PledgeAllianceCrest_texture;
var TextureHandle LastMonthWnd_Deco_texture;

// 문장 윈도우 
var WindowHandle EmblemRankingWnd;
var TextureHandle EmblemRankingWnd_texture;

// 랭킹 
var WindowHandle WeekRankingWnd;

var TextBoxHandle n1WeekRanking_Title_text;
var TextBoxHandle n1WeekRanking_Name_text;
var TextureHandle n1WeekRanking_PledgeCrest_texture;
var TextureHandle n1WeekRanking_PledgeAllianceCrest_texture;
var TextureHandle n1WeekRanking_GroupBox_texture;
var TextureHandle n1WeekRanking_Divider_Texture;
var TextureHandle n1WeekRanking_Block_texture;

var TextBoxHandle n2WeekRanking_Title_text;
var TextBoxHandle n2WeekRanking_Name_text;
var TextureHandle n2WeekRanking_PledgeCrest_texture;
var TextureHandle n2WeekRanking_PledgeAllianceCrest_texture;
var TextureHandle n2WeekRanking_GroupBox_texture;
var TextureHandle n2WeekRanking_Divider_Texture;
var TextureHandle n2WeekRanking_Block_texture;

var TextBoxHandle n3WeekRanking_Title_text;
var TextBoxHandle n3WeekRanking_Name_text;
var TextureHandle n3WeekRanking_PledgeCrest_texture;
var TextureHandle n3WeekRanking_PledgeAllianceCrest_texture;
var TextureHandle n3WeekRanking_GroupBox_texture;
var TextureHandle n3WeekRanking_Divider_Texture;
var TextureHandle n3WeekRanking_Block_texture;

var TextBoxHandle n4WeekRanking_Title_text;
var TextBoxHandle n4WeekRanking_Name_text;
var TextureHandle n4WeekRanking_PledgeCrest_texture;
var TextureHandle n4WeekRanking_PledgeAllianceCrest_texture;
var TextureHandle n4WeekRanking_GroupBox_texture;
var TextureHandle n4WeekRanking_Block_texture;

var TextBoxHandle n5WeekRanking_Title_text;
var TextBoxHandle n5WeekRanking_Name_text;
var TextureHandle n5WeekRanking_PledgeCrest_texture;
var TextureHandle n5WeekRanking_PledgeAllianceCrest_texture;
var TextureHandle n5WeekRanking_GroupBox_texture;
var TextureHandle n5WeekRanking_Block_texture;
var TextureHandle n5WeekRanking_Divider_Texture;

var TextureHandle n5WeekRanking_Flag_texture;

var ButtonHandle CloseButton;
var ButtonHandle GetButton;

var int nSeasonCastleID;  // 성ID
var int nChoiceSeason;    // 0:이번달, 1: 지난달

var string refreshCastleWarSeasonResultStr;

//----------------------------------------------------------------------------------------------------------------------------
// OnRegisterEvent, OnLoad
//----------------------------------------------------------------------------------------------------------------------------
function OnRegisterEvent()
{
	RegisterEvent( EV_CastleWarSeasonResult );  // 10071
	RegisterEvent( EV_CastleWarSeasonReward ); // 10070
}

function OnLoad()
{
	Initialize();
}

function OnHide()
{
	Me.KillTimer( TIME_ID );
}

//----------------------------------------------------------------------------------------------------------------------------
// Initialize
//----------------------------------------------------------------------------------------------------------------------------
function Initialize()
{
	Me = GetWindowHandle( "SiegeReportWnd" );

	GroupBoxBg1_Texture = GetTextureHandle( "SiegeReportWnd.GroupBoxBg1_Texture" );
	GroupBoxBg2_Texture = GetTextureHandle( "SiegeReportWnd.GroupBoxBg2_Texture" );

	SiegeReportDiscription_text = GetTextBoxHandle( "SiegeReportWnd.SiegeReportDiscription_text" );

	MonthRankingNo1Wnd = GetWindowHandle( "SiegeReportWnd.MonthRankingNo1Wnd" );
	MonthRankingNo1Wnd_Title_text = GetTextBoxHandle( "SiegeReportWnd.MonthRankingNo1Wnd.MonthRankingNo1Wnd_Title_text" );
	MonthRankingNo1Wnd_Name_text = GetTextBoxHandle( "SiegeReportWnd.MonthRankingNo1Wnd.MonthRankingNo1Wnd_Name_text" );
	MonthWnd_PledgeCrest_texture = GetTextureHandle( "SiegeReportWnd.MonthRankingNo1Wnd.MonthWnd_PledgeCrest_texture" );
	MonthWnd_PledgeAllianceCrest_texture = GetTextureHandle( "SiegeReportWnd.MonthRankingNo1Wnd.MonthWnd_PledgeAllianceCrest_texture" );

	LastMonthRankingNo1Wnd = GetWindowHandle( "SiegeReportWnd.LastMonthRankingNo1Wnd" );
	LastMonthRankingNo1Wnd_Title_text = GetTextBoxHandle( "SiegeReportWnd.LastMonthRankingNo1Wnd.LastMonthRankingNo1Wnd_Title_text" );
	LastMonthRankingNo1Wnd_Name_text = GetTextBoxHandle( "SiegeReportWnd.LastMonthRankingNo1Wnd.LastMonthRankingNo1Wnd_Name_text" );
	LastMonthWnd_PledgeCrest_texture = GetTextureHandle( "SiegeReportWnd.LastMonthRankingNo1Wnd.LastMonthWnd_PledgeCrest_texture" );
	LastMonthWnd_PledgeAllianceCrest_texture = GetTextureHandle( "SiegeReportWnd.LastMonthRankingNo1Wnd.LastMonthWnd_PledgeAllianceCrest_texture" );
	LastMonthWnd_Deco_texture = GetTextureHandle( "SiegeReportWnd.LastMonthRankingNo1Wnd.LastMonthWnd_Deco_texture" );

	EmblemRankingWnd = GetWindowHandle( "SiegeReportWnd.EmblemRankingWnd" );
	EmblemRankingWnd_texture = GetTextureHandle( "SiegeReportWnd.EmblemRankingWnd.EmblemRankingWnd_texture" );
	WeekRankingWnd  = GetWindowHandle( "SiegeReportWnd.WeekRankingWnd" );

	// 1~5주차 
	n1WeekRanking_Title_text = GetTextBoxHandle( "SiegeReportWnd.WeekRankingWnd.n1WeekRanking_Title_text" );
	n1WeekRanking_Name_text = GetTextBoxHandle( "SiegeReportWnd.WeekRankingWnd.n1WeekRanking_Name_text" );
	n1WeekRanking_PledgeCrest_texture = GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n1WeekRanking_PledgeCrest_texture" );
	n1WeekRanking_PledgeAllianceCrest_texture = GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n1WeekRanking_PledgeAllianceCrest_texture" );
	n1WeekRanking_GroupBox_texture = GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n1WeekRanking_GroupBox_texture" );
	n1WeekRanking_Divider_Texture = GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n1WeekRanking_Divider_Texture" );
	n1WeekRanking_Block_texture = GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n1WeekRanking_Block_texture" );

	n2WeekRanking_Title_text = GetTextBoxHandle( "SiegeReportWnd.WeekRankingWnd.n2WeekRanking_Title_text" );
	n2WeekRanking_Name_text = GetTextBoxHandle( "SiegeReportWnd.WeekRankingWnd.n2WeekRanking_Name_text" );
	n2WeekRanking_PledgeCrest_texture = GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n2WeekRanking_PledgeCrest_texture" );
	n2WeekRanking_PledgeAllianceCrest_texture = GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n2WeekRanking_PledgeAllianceCrest_texture" );
	n2WeekRanking_GroupBox_texture = GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n2WeekRanking_GroupBox_texture" );
	n2WeekRanking_Divider_Texture = GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n2WeekRanking_Divider_Texture" );
	n2WeekRanking_Block_texture = GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n2WeekRanking_Block_texture" );

	n3WeekRanking_Title_text = GetTextBoxHandle( "SiegeReportWnd.WeekRankingWnd.n3WeekRanking_Title_text" );
	n3WeekRanking_Name_text = GetTextBoxHandle( "SiegeReportWnd.WeekRankingWnd.n3WeekRanking_Name_text" );
	n3WeekRanking_PledgeCrest_texture = GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n3WeekRanking_PledgeCrest_texture" );
	n3WeekRanking_PledgeAllianceCrest_texture = GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n3WeekRanking_PledgeAllianceCrest_texture" );
	n3WeekRanking_GroupBox_texture = GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n3WeekRanking_GroupBox_texture" );
	n3WeekRanking_Divider_Texture = GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n3WeekRanking_Divider_Texture" );
	n3WeekRanking_Block_texture = GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n3WeekRanking_Block_texture" );

	n4WeekRanking_Title_text = GetTextBoxHandle( "SiegeReportWnd.WeekRankingWnd.n4WeekRanking_Title_text" );
	n4WeekRanking_Name_text = GetTextBoxHandle( "SiegeReportWnd.WeekRankingWnd.n4WeekRanking_Name_text" );
	n4WeekRanking_PledgeCrest_texture = GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n4WeekRanking_PledgeCrest_texture" );
	n4WeekRanking_PledgeAllianceCrest_texture = GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n4WeekRanking_PledgeAllianceCrest_texture" );
	n4WeekRanking_GroupBox_texture = GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n4WeekRanking_GroupBox_texture" );
	n4WeekRanking_Block_texture = GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n4WeekRanking_Block_texture" );

	n5WeekRanking_Title_text = GetTextBoxHandle( "SiegeReportWnd.WeekRankingWnd.n5WeekRanking_Title_text" );
	n5WeekRanking_Name_text = GetTextBoxHandle( "SiegeReportWnd.WeekRankingWnd.n5WeekRanking_Name_text" );
	n5WeekRanking_PledgeCrest_texture = GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n5WeekRanking_PledgeCrest_texture" );
	n5WeekRanking_PledgeAllianceCrest_texture = GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n5WeekRanking_PledgeAllianceCrest_texture" );
	n5WeekRanking_GroupBox_texture = GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n5WeekRanking_GroupBox_texture" );
	n5WeekRanking_Block_texture = GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n5WeekRanking_Block_texture" );
	n5WeekRanking_Divider_Texture = GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n5WeekRanking_Flag_texture" );
	n5WeekRanking_Flag_texture = GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n5WeekRanking_Flag_texture" );

	// 버튼 
	CloseButton = GetButtonHandle( "SiegeReportWnd.CloseButton" );
	GetButton = GetButtonHandle( "SiegeReportWnd.GetButton" );
}

//----------------------------------------------------------------------------------------------------------------------------
// Event, Click Handler
//----------------------------------------------------------------------------------------------------------------------------
function OnTimer( int TimerID )
{	
	if(TimerID == TIME_ID)
	{
		CastleWarSeasonResultHandler(refreshCastleWarSeasonResultStr, true);
		Me.KillTimer( TIME_ID );
	}
}

function OnEvent(int Event_ID, String param)
{
	if (Event_ID == EV_CastleWarSeasonResult)
	{		
		refreshCastleWarSeasonResultStr = param;
		CastleWarSeasonResultHandler(param);
		Debug("EV_CastleWarSeasonResult:" @ param);
	}
	else if (Event_ID == EV_CastleWarSeasonReward)
	{
		CastleWarSeasonRewardHandler(param);
		Debug("EV_CastleWarSeasonReward:" @ param);
	}
}

// 시즌 정보 보여주기
function CastleWarSeasonResultHandler(string param, optional bool bIgnoreTexUpdate)
{
	local string seasonWinPledgeName;

	local int seasonCount, n, nWeek, nButtonType, nSeasonWinPledgeID, nSeasonWinAllianceID, nSeasonMaxCount;

	local bool bShowEmble;

	nSeasonCastleID = 0;

	ParseInt(param, "SeasonMaxCount", nSeasonMaxCount);  // 0:이번달, 1:지난달 
	
	// 4, 5주 보여주는 상황에 따라 윈도우 사이즈 조절
	if (nSeasonMaxCount <= 4 && nSeasonMaxCount > 0) 
	{
		// 4주만 보이게..
		Me.SetWindowSize(328, 473 - 69);
		showLastWeekGroup(false);
	}
	else 
	{
		// 5주만 보이게.. 0주나 잘못된 값이 들어와도 5주로 보이도록 한다(디폴트)
		Me.SetWindowSize(328, 477);
		showLastWeekGroup(true);
	}

	//------------------------------------
	// 현재 또는 지난달 1등 정보 입력
	//------------------------------------
	ParseInt(param, "ChoiceSeason", nChoiceSeason);  // 0:이번달, 1:지난달 

	ParseString(param, "SeasonWinPledgeName", seasonWinPledgeName);  // 우승 혈맹명
	ParseInt(param, "SeasonWinPledgeID"     , nSeasonWinPledgeID);   // 우승 혈맹ID
	ParseInt(param, "SeasonWinAllianceID"   , nSeasonWinAllianceID); // 우승 동맹ID
	
	setMonthlyWinnerInfo(seasonWinPledgeName, nSeasonWinPledgeID, nSeasonWinAllianceID, bIgnoreTexUpdate);

	//------------------------------------
	// 1~5주 카운트
	//------------------------------------
	ParseInt   (param, "SeasonCount"  , seasonCount); // 승리 혈맹 수 카운트(3이면 3주치 이런식..)

	bShowEmble = true;
	for (n = 1; n <= nSeasonMaxCount; n++)
	{  
		ParseString(param, "WeekWinPledgeName_" $ n, seasonWinPledgeName); // n 주차 우승 혈맹명

		ParseInt(param, "WeekNum_" $ n          , nWeek);                  // n 주차		
		ParseInt(param, "WeekWinPledgeID_" $ n  , nSeasonWinPledgeID);     // n 주차 우승 혈맹ID
		ParseInt(param, "WeekWinAllianceID_" $ n, nSeasonWinAllianceID);   // n 주차 우승 동맹ID
		
		setWeekWinnerInfo(n, seasonWinPledgeName, nSeasonWinPledgeID, nSeasonWinAllianceID, (seasonCount < n), bIgnoreTexUpdate);

		if (seasonWinPledgeName != "") bShowEmble = false;
	}

	ParseInt(param, "ButtonType"     , nButtonType);     // 0:닫기, 1:보상받기
	ParseInt(param, "SeasonCastleID" , nSeasonCastleID); // 시즌 성 번호 (혈맹 하나가 하나 이상의 성을 차지 했을때 구분을 위해서..)


	if(nChoiceSeason > 0) 
	{
		// 지난 달 공성전 현황
		Me.SetWindowTitle(GetSystemString(3408));
	}
	else
	{
		// 이번 달 공성전 현황
		Me.SetWindowTitle(GetSystemString(3407));
	}

	// 닫기, 보상받기 버튼 
	if (nButtonType == 0) 
	{
		CloseButton.ShowWindow();
		GetButton.HideWindow();
	}
	else 
	{
		CloseButton.HideWindow();
		GetButton.ShowWindow();
	}

	// 엠블렘 보여주기 여부
	if(bShowEmble) 
	{
		// 이번 달만 : 공성전이 진행될 예정입니다.. 뭐 이런 설명을 보여준다.
		if (nChoiceSeason == 0)
		{
			SiegeReportDiscription_text.ShowWindow();
			MonthRankingNo1Wnd.HideWindow();
			LastMonthRankingNo1Wnd.HideWindow();
		}
		else 
		{
			SiegeReportDiscription_text.HideWindow();
		}

		EmblemRankingWnd.ShowWindow();
		WeekRankingWnd.HideWindow();
	}
	else 
	{		
		SiegeReportDiscription_text.HideWindow();
		EmblemRankingWnd.HideWindow();
		WeekRankingWnd.ShowWindow();
	}

	Me.ShowWindow();
	Me.SetFocus();

	if (!bIgnoreTexUpdate)
	{
		// 1초후에 전체를 리플레시 하여, 동맹, 혈맹 아이콘이 다운되었으면 갱신되도록 한다.
		// 1초후에도 안들어 오면 어쩔 수 없다. 무시
		Me.KillTimer( TIME_ID );
		Me.SetTimer(TIME_ID, TIME_DELAY);
	}
}

// 매주 승리 혈맹 정보 입력
// bIgnoreTexUpdate 이 true이면 혈맹, 동맹 텍스쳐 업데이트를 하지 않는다.
function setWeekWinnerInfo(int nWeek, string winnerName, int pledgeCrestId, int allianceCrestId, bool showBlock, optional bool bIgnoreTexUpdate)
{
	local texture texPledge;
	local texture texAlliance;

	local bool bPledge, bAlliance;
	
	if (nWeek <= 0 || nWeek > 5) { Debug("SigeReportWnd : nWeek가 1~5 값이 아닙니다." @ nWeek); return; }

	// 혈맹이 없다면 덥개를 닫는다.
	if (showBlock) GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n" $ String(nWeek) $ "WeekRanking_Block_texture" ).ShowWindow();
	else GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n" $ String(nWeek) $ "WeekRanking_Block_texture" ).HideWindow();

	// 혈맹명 
	if (winnerName == "") 
	{
		GetTextBoxHandle( "SiegeReportWnd.WeekRankingWnd.n" $ String(nWeek) $ "WeekRanking_Name_text" ).SetText(GetSystemString(3416)); // 승리 혈맹 없음
		return;
	}
	else
	{
		GetTextBoxHandle( "SiegeReportWnd.WeekRankingWnd.n" $ String(nWeek) $ "WeekRanking_Name_text" ).SetText(winnerName);
	}

	// 로컬에서 동맹, 혈맹 텍스쳐를 가져 와서 있으면 그대로 사용, 없으면 요청 할 것이다.
	bPledge   = class'UIDATA_CLAN'.static.GetCrestTexture(pledgeCrestId, texPledge);
	bAlliance = class'UIDATA_CLAN'.static.GetAllianceCrestTexture(pledgeCrestId, texAlliance);

	// ---  혈맹, 동맹 텍스쳐가 있다면 적용, 없다면 서버에 요청 ---
	// 혈맹
	if(bPledge) GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n" $ String(nWeek) $ "WeekRanking_PledgeCrest_texture" ).SetTextureWithObject(texPledge);
	else 
	{
		if(!bIgnoreTexUpdate) texPledge = GetPledgeCrestTexFromPledgeCrestID(pledgeCrestId);
	}

	// 동맹
	if(bAlliance) GetTextureHandle( "SiegeReportWnd.WeekRankingWnd.n" $ String(nWeek) $ "WeekRanking_PledgeAllianceCrest_texture" ).SetTextureWithObject(texAlliance);
	else 
	{
		if(!bIgnoreTexUpdate) texAlliance = GetAllianceCrestTexFromAllianceCrestID(allianceCrestId);
	}
}

function showLastWeekGroup(bool bShow)
{
	if (bShow)
	{
		n5WeekRanking_Title_text.ShowWindow();
		n5WeekRanking_Name_text.ShowWindow();
		n5WeekRanking_PledgeCrest_texture.ShowWindow();
		n5WeekRanking_PledgeAllianceCrest_texture.ShowWindow();
		n5WeekRanking_GroupBox_texture.ShowWindow();
		n5WeekRanking_Block_texture.ShowWindow();
		n5WeekRanking_Divider_Texture.ShowWindow();
		n5WeekRanking_Flag_texture.ShowWindow();
	}
	else
	{
		n5WeekRanking_Title_text.HideWindow();
		n5WeekRanking_Name_text.HideWindow();
		n5WeekRanking_PledgeCrest_texture.HideWindow();
		n5WeekRanking_PledgeAllianceCrest_texture.HideWindow();
		n5WeekRanking_GroupBox_texture.HideWindow();
		n5WeekRanking_Block_texture.HideWindow();
		n5WeekRanking_Divider_Texture.HideWindow();
		n5WeekRanking_Flag_texture.HideWindow();
	}
}


// 매달 우승자 정보 입력
function setMonthlyWinnerInfo(string winnerName, int pledgeCrestId, int allianceCrestId, optional bool bIgnoreTexUpdate)
{
	local texture texPledge;
	local texture texAlliance;

	local bool bPledge, bAlliance;

	// 로컬에서 동맹, 혈맹 텍스쳐를 가져 와서 있으면 그대로 사용, 없으면 요청 할 것이다.
	bPledge   = class'UIDATA_CLAN'.static.GetCrestTexture(pledgeCrestId, texPledge);
	bAlliance = class'UIDATA_CLAN'.static.GetAllianceCrestTexture(pledgeCrestId, texAlliance);

	// 이번 달
	if (nChoiceSeason == 0)
	{
		MonthRankingNo1Wnd.ShowWindow();
		LastMonthRankingNo1Wnd.HideWindow();

		if (winnerName == "")
			MonthRankingNo1Wnd_Name_text.SetText(GetSystemString(3416)); // 승리혈맹 없음
		else
			MonthRankingNo1Wnd_Name_text.SetText(winnerName);

		// ---  혈맹, 동맹 텍스쳐가 있다면 적용, 없다면 서버에 요청 ---
		// 혈맹
		if(bPledge) MonthWnd_PledgeCrest_texture.SetTextureWithObject(texPledge);
		else 
		{
			if(!bIgnoreTexUpdate) texPledge = GetPledgeCrestTexFromPledgeCrestID(pledgeCrestId);
		}
		// 동맹
		if(bAlliance) MonthWnd_PledgeAllianceCrest_texture.SetTextureWithObject(texAlliance);
		else
		{
			if(!bIgnoreTexUpdate) texAlliance = GetAllianceCrestTexFromAllianceCrestID(allianceCrestId);
		}
	}
	// 지난 달 
	else
	{
		MonthRankingNo1Wnd.HideWindow();
		LastMonthRankingNo1Wnd.ShowWindow();

		if (winnerName == "")
			LastMonthRankingNo1Wnd_Name_text.SetText(GetSystemString(3416)); // 승리혈맹 없음
		else
			LastMonthRankingNo1Wnd_Name_text.SetText(winnerName);

		// ---  혈맹, 동맹 텍스쳐가 있다면 적용, 없다면 서버에 요청 ---
		// 혈맹
		if(bPledge) LastMonthWnd_PledgeCrest_texture.SetTextureWithObject(texPledge);
		else 
		{
			if(!bIgnoreTexUpdate) texPledge = GetPledgeCrestTexFromPledgeCrestID(pledgeCrestId);
		}
		// 동맹
		if(bAlliance) LastMonthWnd_PledgeAllianceCrest_texture.SetTextureWithObject(texAlliance);
		else 
		{
			if(!bIgnoreTexUpdate) texAlliance = GetAllianceCrestTexFromAllianceCrestID(allianceCrestId);
		}
	}
}


// 보상 받기 결과  
function CastleWarSeasonRewardHandler(string paramStr)
{
	local int nResult;

	//ParseString
	ParseInt(paramStr, "Result", nResult);

	//Me.HideWindow();

}

function OnClickButton( string Name )
{
	switch( Name )
	{
		case "CloseButton":
			 OnCloseButtonClick();
			 break;

		case "GetButton":
			 OnGetButtonClick();
			 break;
	}
}

function OnCloseButtonClick()
{
	Me.HideWindow();
}

function OnGetButtonClick()
{
	if (nSeasonCastleID > 0) RequestCastleWarSeasonReward(nSeasonCastleID);
	else Debug("nSeasonCastleID 정보가 0과 같거나 작습니다.");

	Me.HideWindow();
}


//----------------------------------------------------------------------------------------------------------------------------
// UI Process
//----------------------------------------------------------------------------------------------------------------------------
defaultproperties
{
}
