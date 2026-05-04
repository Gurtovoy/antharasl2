class HeroTowerWnd extends UICommonAPI;

// 전역변수로 영웅의 class  ID 를 받는다. 
var int m_IDofHero;

// 월드 올림피아드 인지 여부 ( 현재는 클래식인지만 확인하면 됨. )
var bool isWroldOlympiad;

var string m_WindowName;

var ListCtrlHandle	m_hLstHero;

function OnRegisterEvent()
{
	RegisterEvent( EV_HeroShowList );
	//RegisterEvent( EV_HeroRecord );
}

function OnLoad()
{
	SetClosingOnESC();	
	m_hLstHero=GetListCtrlHandle( m_WindowName$".lstHero");
}

function OnEvent(int Event_ID, string param)
{
	//해외 올림피아드용
	local int UseClassicOlympiad;

	if (Event_ID == EV_HeroShowList)
	{	
		// 월드 올림피아드는 클래식에서 버젼, 이후 일반 올림피아드와 병행 할 경우 구분 코드 필요
		isWroldOlympiad = getInstanceUIData().getIsClassicServer() ;		
		//해외 올림피아드 구분용 해외는 월드 올림 없음
		GetINIBool ( "Localize", "UseClassicOlympiad", UseClassicOlympiad, "L2.ini" );
		//Debug("UseClassicOlympiad-HeroTowerWnd-->>" @ UseClassicOlympiad @"&&"@isWroldOlympiad);

		if ( isWroldOlympiad && UseClassicOlympiad == 0 ) return;

		Clear();	
		
		//Show
		class'UIAPI_WINDOW'.static.ShowWindow(m_WindowName);
		class'UIAPI_WINDOW'.static.SetFocus(m_WindowName);
		
		//Check I am Hero
		HandleCheckAmIHero();
		
		//HandleHeroShowList
		HandleHeroShowList(param);
	}
}

//리스트항목을 더블클릭하면 영웅행적 표시
function OnDBClickListCtrlRecord( String strID )
{
	switch( strID )
	{
	case "lstHero":
		HandleShowDiary();
		break;
	}	
}

function OnClickButton( string strID )
{	
	switch( strID )
	{
	case "btnShowDiary":
		HandleShowDiary();
		break;
	case "btnReg":
		class'HeroTowerAPI'.static.RequestWriteHeroWords(class'UIAPI_EDITBOX'.static.GetString(m_WindowName$".txtDiary"));
		class'UIAPI_EDITBOX'.static.SetString(m_WindowName$".txtDiary", "");
		break;
	case "btnHistory":
		HandleShowHistory();
		break;
	}
}

//영웅의 행적 표시
function HandleShowDiary()
{
	local LVDataRecord 	record;
	local string	strTmp;
	
	m_hLstHero.GetSelectedRec(record);
	if (record.nReserved1>0)
	{
		strTmp = "_diary?class=" $ string(record.nReserved1) $ "&page=1";
		RequestBypassToServer(strTmp);
	}
}

function HandleShowHistory()
{
	local LVDataRecord 	record;

	if ( m_hLstHero.GetSelectedIndex() < 0 )  return ;

	m_hLstHero.GetSelectedRec(record) ;

	class'HeroTowerAPI'.static.RequestHeroMatchRecord( int(record.nReserved1) );	// 전적보기
}

//내가 영웅인가? (버튼, 에디트 박스 표시)
function HandleCheckAmIHero()
{
	local bool bHero;
	
	bHero = class'UIDATA_PLAYER'.static.IsHero();
	if (bHero)
	{
		class'UIAPI_WINDOW'.static.ShowWindow(m_WindowName$".txtDiary");
		class'UIAPI_WINDOW'.static.ShowWindow(m_WindowName$".btnReg");
	}
	else
	{
		class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".txtDiary");
		class'UIAPI_WINDOW'.static.HideWindow(m_WindowName$".btnReg");
	}
}

//초기화
function Clear()
{
	class'UIAPI_LISTCTRL'.static.DeleteAllItem(m_WindowName$".lstHero");
	class'UIAPI_EDITBOX'.static.SetString(m_WindowName$".txtDiary", "");
}

//영웅 리스트를 추가
function HandleHeroShowList(string param)
{
	local int		i;
	local int		nMax;
	
	local string	strName;
	local int		ClassID;
	local string	strPledgeName;
	local int		PledgeCrestId;
	local string	strAllianceName;
	local int		AllianceCrestId;
	local int		WinCount;
	
	local texture	texPledge;
	local texture	texAlliance;
	
	local LVDataRecord	record;
	local LVDataRecord	recordClear;	
	
	ParseInt( param, "Max", nMax );	
	
	for (i=0; i<nMax; i++)
	{
		strName = "";
		ClassID = 0;
		strPledgeName = "";
		PledgeCrestId = 0;
		strAllianceName = "";
		AllianceCrestId = 0;
		WinCount = 0;
		
		ParseString(param, "Name_" $ i, strName);
		ParseInt(param, "ClassId_" $ i, ClassID);
		ParseString(param, "PledgeName_" $ i, strPledgeName);
		ParseInt(param, "PledgeCrestId_" $ i, PledgeCrestId);
		ParseString(param, "AllianceName_" $ i, strAllianceName);
		ParseInt(param, "AllianceCrestId_" $ i, AllianceCrestId);
		ParseInt(param, "WinCount_" $ i, WinCount);		
		
		texPledge = GetPledgeCrestTexFromPledgeCrestID(PledgeCrestId);
		texAlliance = GetAllianceCrestTexFromAllianceCrestID(AllianceCrestId);
		
		//레코드 초기화
		record = recordClear;
		record.LVDataList.Length = 5;
		
		//이름
		record.LVDataList[0].szData = strName;
		
		//직업
		record.LVDataList[1].szData = GetClassType(ClassID);
				
		//혈맹
		record.LVDataList[2].szData = strPledgeName;
		
		//동맹 및 혈맹의 문장 텍스쳐 표시
		if (AllianceCrestId>0)
		{
			if (PledgeCrestId>0)
			{
				record.LVDataList[2].arrTexture.Length = 2;
				
				record.LVDataList[2].arrTexture[0].objTex = texAlliance;
				record.LVDataList[2].arrTexture[0].X = 10;
				record.LVDataList[2].arrTexture[0].Y = 0;
				record.LVDataList[2].arrTexture[0].Width = 8;
				record.LVDataList[2].arrTexture[0].Height = 12;
				record.LVDataList[2].arrTexture[0].U = 0;
				record.LVDataList[2].arrTexture[0].V = 4;
				
				record.LVDataList[2].arrTexture[1].objTex = texPledge;
				record.LVDataList[2].arrTexture[1].X = 18;
				record.LVDataList[2].arrTexture[1].Y = 0;
				record.LVDataList[2].arrTexture[1].Width = 16;
				record.LVDataList[2].arrTexture[1].Height = 12;
				record.LVDataList[2].arrTexture[1].U = 0;
				record.LVDataList[2].arrTexture[1].V = 4;
			}
			else
			{
				record.LVDataList[2].arrTexture.Length = 1;
				
				record.LVDataList[2].arrTexture[0].objTex = texPledge;
				record.LVDataList[2].arrTexture[0].X = 10;
				record.LVDataList[2].arrTexture[0].Y = 0;
				record.LVDataList[2].arrTexture[0].Width = 8;
				record.LVDataList[2].arrTexture[0].Height = 12;
				record.LVDataList[2].arrTexture[0].U = 0;
				record.LVDataList[2].arrTexture[0].V = 4;
			}
		}
		else
		{
			if (PledgeCrestId>0)
			{
				record.LVDataList[2].arrTexture.Length = 1;
				
				record.LVDataList[2].arrTexture[0].objTex = texPledge;
				record.LVDataList[2].arrTexture[0].X = 10;
				record.LVDataList[2].arrTexture[0].Y = 0;
				record.LVDataList[2].arrTexture[0].Width = 16;
				record.LVDataList[2].arrTexture[0].Height = 12;
				record.LVDataList[2].arrTexture[0].U = 0;
				record.LVDataList[2].arrTexture[0].V = 4;
			}
		}
		
		//동맹
		record.LVDataList[3].szData = strAllianceName;
		
		//횟수
		record.LVDataList[4].szData = string(WinCount);
		
		record.nReserved1 = ClassID;
		
		class'UIAPI_LISTCTRL'.static.InsertRecord(m_WindowName$".lstHero", record );	
	}
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( m_WindowName ).HideWindow();
}

defaultproperties
{
    m_WindowName="HeroTowerWnd"
}
