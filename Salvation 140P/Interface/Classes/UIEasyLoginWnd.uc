/*****************************************************************************************************************************
   제목 : System폴더 UIDEV.ini 을 만들고, 아래와 같은 식으로 추가를 하면 작동 한다.
 - 개발망에서만 작동 하도록 한다 - 

[EASYLOGIN]
use=1
id1=ui1@a.a
pw1=aaaa1111
id2=ui2@a.a
pw2=aaaa1111
id3=ui3@a.a

use=1 로 하면 개발망에서 작동 하도록 세팅 하는 것 
예제와 같이 아이디, 암호를 넣어 두고.. 최대 50개 까지 저장 가능.


lastLoginIndex 마지막 로그인한 아이디 위치를 기억 시킨다. 

Ctrl 를 누르면 로그인으로 들어감
 
 ****************************************************************************************************************************/
class UIEasyLoginWnd extends UICommonAPI;

const TIMER_ID_CHANGETEXT    = 10234599;
const TIMER_ID               = 10234510;

var WindowHandle Me;
var ListCtrlHandle idList;
var ButtonHandle loginButton, addButton, delButton, managerButton;
var TextBoxHandle descTxt;
var EditBoxHandle idEditBox, pwEditBox, serverEditBox, charEditBox;
var string lastKeyValue;
var bool isEditMode;

function OnRegisterEvent()
{
	RegisterEvent( EV_LoginBegin );
}

function OnLoad()
{
	registerState( "LogIn", "LoginState" );	

	SetClosingOnESC();
	Initialize();
}

function OnShow()
{
	local ELanguageType Language;	

	Me.KillTimer(TIMER_ID_CHANGETEXT);
	Me.SetTimer(TIMER_ID_CHANGETEXT, 4000);

	Me.KillTimer(TIMER_ID);
	Me.SetTimer(TIMER_ID, 100);

	Language = GetLanguage();

	if( Language == LANG_Korean) descTxt.SetText("편한 로그인 툴!");
}

function AddList (string id, string pw, string server, string character)
{
	local LVDataRecord record;
	
	record.LVDataList.Length = 3;
	record.LVDataList[0].szData = id;
	record.LVDataList[0].szReserved = pw;
	
	record.LVDataList[1].szData = server;
	record.LVDataList[2].szData = character;

	// 리스트에 추가 
	idList.InsertRecord(record);
}

function GetSelectedRecord()
{
	local LVDataRecord record;
	
	idList.GetSelectedRec(record);

	idEditBox.SetString(record.LVDataList[0].szData);
	pwEditBox.SetString(record.LVDataList[0].szReserved);
	serverEditBox.SetString(record.LVDataList[1].szData);
	charEditBox.SetString(record.LVDataList[2].szData);
}

function OnEvent(int Event_ID, string param)
{	
	if( Event_ID == EV_LoginBegin )
	{
		// 개발망만 작동 하도록..
		switch ( GetReleaseMode() ) 
		{
			case RM_DEV :
			if( Me.IsShowWindow() == false )
			{
				checkAndShowEasyLogin();
			}
		}
	}
}

function Initialize()
{
	Me = GetWindowHandle( "UIEasyLoginWnd" );
	idList = GetListCtrlHandle( "UIEasyLoginWnd.idList" );

	loginButton   = GetButtonHandle( "UIEasyLoginWnd.loginButton" );
	addButton     = GetButtonHandle( "UIEasyLoginWnd.addButton" );
	delButton     = GetButtonHandle( "UIEasyLoginWnd.delButton" );
	managerButton = GetButtonHandle( "UIEasyLoginWnd.managerButton" );

	descTxt = GetTextBoxHandle("UIEasyLoginWnd.descTxt");

	idEditBox = GetEditBoxHandle("UIEasyLoginWnd.idEditBox");
	pwEditBox = GetEditBoxHandle("UIEasyLoginWnd.pwEditBox");
	serverEditBox = GetEditBoxHandle("UIEasyLoginWnd.serverEditBox");
	charEditBox = GetEditBoxHandle("UIEasyLoginWnd.charEditBox");
	
	Me.SetWindowTitle("UITools - EasyLogin");
}

function OnHide()
{
	Me.KillTimer(TIMER_ID_CHANGETEXT);
	Me.KillTimer(TIMER_ID);
}

function OnTimer(int TimerID)
{
	local ELanguageType Language;	

	if (TimerID == TIMER_ID_CHANGETEXT)
	{
		Language = GetLanguage();

		if( Language == LANG_Korean)
		{	
			switch(Rand(8))
			{
				case  1 : descTxt.SetText("- 리지니2 System폴더에 UIDEV.ini 파일에서, [EASYLOGIN] 항목을 직접 편집하여도 된니다."); break;
				case  2 : descTxt.SetText("- 버그나 요청이 있으면 dongland@ncsoft.com 으로 메일주세요."); break;
				case  3 : descTxt.SetText("- dongland에게 Donation 하셔도 됩니다. -_-"); break;
				case  4 : descTxt.SetText("- (-_-)/~~~~이 글은 한글 버전에서만 보입니다~ "); break;
				case  5 : descTxt.SetText("- 로그인과 암호를 매번 넣기 힘들어서 만든 로그인 툴입니다."); break;
				case  6 : descTxt.SetText("- 최대 50개의 아이디 암호를 저장 할 수 있습니다."); break;
				case  7 : descTxt.SetText("- Server와 Char(캐릭터 선택)는 숫자로 입력 해야 됩니다."); break;
				default : descTxt.SetText("- 추가 기능이 꼭 필요하면 알려주세요. "); break;
			}
		}
	}
	else if( TimerID == TIMER_ID)
	{
		if(IsKeyDown(IK_Home) || IsKeyDown(EInputKey.IK_RightMouse))
		{
			OnLoginButtonClickHandler();
		}
	}
}

function OnClickButton( string Name )
{
	switch( Name )
	{
		case "loginButton":
			  OnLoginButtonClickHandler();
			  break;

		case "addButton":
			  OnAddButtonClickHandler();
			  break;

		case "delButton":
			  OnDelButtonClickHandler();
			  break;

		case "managerButton":			  
			  OnManagerButtonClickHandler();
			  break;
	}
}

function OnAddButtonClickHandler()
{
	local int nMax;
	
	if (idEditBox.GetString() != "" && pwEditBox.GetString() != "")
	{
		nMax = idList.GetRecordCount();
		SetINIString("EASYLOGIN", "id"  $ nMax + 1, idEditBox.GetString() , "UIDEV.ini");
		SetINIString("EASYLOGIN", "pw"  $ nMax + 1, pwEditBox.GetString() , "UIDEV.ini");
		SetINIString("EASYLOGIN", "server"  $ nMax + 1, serverEditBox.GetString() , "UIDEV.ini");
		SetINIString("EASYLOGIN", "char"  $ nMax + 1, charEditBox.GetString() , "UIDEV.ini");

		AddList(idEditBox.GetString(), pwEditBox.GetString(), serverEditBox.GetString(), charEditBox.GetString());
	}
}

function OnDelButtonClickHandler()
{
	local int idx;
	local string id, pw, server, character;
	local int i;
	local string oldid;

	local LVDataRecord	record;	

	idx = idList.GetSelectedIndex();
	 
	if (idx > -1) 
	{
		idList.DeleteRecord(idx);
		SetINIString("EASYLOGIN", "id"  $ idx + 1, "" , "UIDEV.ini");
		SetINIString("EASYLOGIN", "pw"  $ idx + 1, "" , "UIDEV.ini");
		SetINIString("EASYLOGIN", "server"  $ idx + 1, "" , "UIDEV.ini");
		SetINIString("EASYLOGIN", "char"  $ idx + 1, "" , "UIDEV.ini");

		// ini 에 정리하여 저장하기 
		for (i = 1; i < 51; i++)
		{
			if (idList.GetRecordCount() >= i)
			{
				idList.GetRec(i - 1, record);
				id = record.LVDataList[0].szData;
				pw = record.LVDataList[0].szReserved;
				server = record.LVDataList[1].szData;
				character = record.LVDataList[2].szData;
			}
			else
			{
				id = "";
				pw = "";
				server = "";
				character = "";
			}

			if(id == "")
				GetINIString("EASYLOGIN", "id" $ i, oldid, "UIDEV.ini");
				
			if(id != "" || oldid != "")
			{
				SetINIString("EASYLOGIN", "id" $ i, id, "UIDEV.ini");
				SetINIString("EASYLOGIN", "pw" $ i, pw, "UIDEV.ini");
				SetINIString("EASYLOGIN", "server" $ i, server, "UIDEV.ini");
				SetINIString("EASYLOGIN", "char" $ i, character, "UIDEV.ini");
			}
		}
	}
}

// 매니저 버튼을 누르면 윈도우 폭을 늘리고 줄이고 하여, 아이디, 암호를 넣는 곳을 보였다 안보였다 한다.
function OnManagerButtonClickHandler(optional bool bUseBasicUI)
{
	local int w, h;

	Me.GetWindowSize(w, h);

	if (w > 400 || bUseBasicUI)
	{
		Me.SetWindowSize(240, 340);

		descTxt.HideWindow();
		addButton.HideWindow();
		delButton.HideWindow();		
		idEditBox.HideWindow();
		pwEditBox.HideWindow();
		serverEditBox.HideWindow();
		charEditBox.HideWindow();

		GetTextBoxHandle("UIEasyLoginWnd.addTxt").HideWindow();		
		GetTextBoxHandle("UIEasyLoginWnd.idTxt").HideWindow();
		GetTextBoxHandle("UIEasyLoginWnd.pwTxt").HideWindow();
		GetTextBoxHandle("UIEasyLoginWnd.serverTxt").HideWindow();
		GetTextBoxHandle("UIEasyLoginWnd.charTxt").HideWindow();
		GetTextBoxHandle("UIEasyLoginWnd.delTxt").HideWindow();
		GetTextBoxHandle("UIEasyLoginWnd.descTxt").HideWindow();

		GetTextureHandle("UIEasyLoginWnd.ListBG1").HideWindow();
		
		isEditMode = false;
	}
	else 
	{
		Me.SetWindowSize(580, 340);

		descTxt.ShowWindow();
		addButton.ShowWindow();
		delButton.ShowWindow();		
		idEditBox.ShowWindow();
		pwEditBox.ShowWindow();
		serverEditBox.ShowWindow();
		charEditBox.ShowWindow();

		GetTextBoxHandle("UIEasyLoginWnd.addTxt").ShowWindow();		
		GetTextBoxHandle("UIEasyLoginWnd.idTxt").ShowWindow();
		GetTextBoxHandle("UIEasyLoginWnd.pwTxt").ShowWindow();
		GetTextBoxHandle("UIEasyLoginWnd.serverTxt").ShowWindow();
		GetTextBoxHandle("UIEasyLoginWnd.charTxt").ShowWindow();
		GetTextBoxHandle("UIEasyLoginWnd.delTxt").ShowWindow();		
		GetTextBoxHandle("UIEasyLoginWnd.descTxt").ShowWindow();
		
		GetTextureHandle("UIEasyLoginWnd.ListBG1").ShowWindow();
		
		isEditMode = true;
	}
}

//레코드를 더블클릭하면....
function OnDBClickListCtrlRecord( string ListCtrlID )
{
	switch(ListCtrlID)
	{
		case "idList" :
			if(isEditMode)
				GetSelectedRecord();
			else
				OnLoginButtonClickHandler();
			 break;
	}
}

// 로그인시 해당 UI를 나오게 할 것인지를 정한다.
function setUseEasyLogin(bool flag)
{
	SetINIString("EASYLOGIN", "use", String(boolToNum(flag)) , "UIDEV.ini");
}

// 로그인시 해당 UI를 나오게 할 것인지를 정한다.
function bool getUseEasyLogin()
{
	local string stringValue;
	GetINIString("EASYLOGIN", "use", stringValue, "UIDEV.ini");

	return numToBool(int(stringValue));
}

// 로그인 시도
function OnLoginButtonClickHandler()
{
	local LVDataRecord	record;	
	local int serverNum;
	local int characterNum;
	
	idList.GetSelectedRec( record );

	if (record.LVDataList[0].szData != "")
	{
		LogIn(GetScript("LogIn")).onCallUCFunction("setLogin", 
 													"ID=" $ record.LVDataList[0].szData $ " " $
 													"pass=" $ record.LVDataList[0].szReserved);

		// 로그인한 항목의 인덱스를 저장 
		SetINIString("EASYLOGIN", "lastLoginIndex", String(idList.GetSelectedIndex()) , "UIDEV.ini");
		
		// 서버와 캐릭터 자동 로그인
		if(record.LVDataList[1].szData != "")
		{
			serverNum = int(record.LVDataList[1].szData);

			if (record.LVDataList[2].szData != "")
				characterNum = int(record.LVDataList[2].szData);
			else
				characterNum = -1;

			AutoLogin(serverNum, characterNum);
		}
	}
}

function checkAndShowEasyLogin()
{
	local string stringValue;
	GetINIString("EASYLOGIN", "use", stringValue, "UIDEV.ini");

	if (int(stringValue) > 0)
	{		
		OnManagerButtonClickHandler(true);
		Me.ShowWindow();
		loadListByINI();
	}
}

function loadListByINI()
{
	local string id, pw, server, character, listIndex;
	local int i;

	
	idList.DeleteAllItem();
	for (i = 1; i < 51; i++)
	{
		id = "";
		pw = "";
		server = "";
		character = "";
		GetINIString("EASYLOGIN", "id" $ i, id, "UIDEV.ini");
		GetINIString("EASYLOGIN", "pw" $ i, pw, "UIDEV.ini");
		GetINIString("EASYLOGIN", "server" $ i, server, "UIDEV.ini");
		GetINIString("EASYLOGIN", "char" $ i, character, "UIDEV.ini");

		if (id != "")
			AddList(id, pw, server, character);
	}

	// 마지막에 로그인한 항목으로 리스트 선택
	GetINIString("EASYLOGIN", "lastLoginIndex", listIndex , "UIDEV.ini");
	idList.SetSelectedIndex(int(listIndex), true);

}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( getCurrentWindowName(string(Self))).HideWindow();
}
defaultproperties
{
}
