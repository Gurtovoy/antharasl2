/*****************************************************************************************************************************
   ???? : System???? UIDEV.ini ?? ?????, ????? ???? ?????? ????? ??? ??? ???.
 - ??????????? ??? ????? ??? - 

[EASYLOGIN]
use=1
id1=ui1@a.a
pw1=aaaa1111
id2=ui2@a.a
pw2=aaaa1111
id3=ui3@a.a

use=1 ?? ??? ????????? ??? ????? ???? ??? ?? 
?????? ???? ?????, ????? ??? ???.. ??? 50?? ???? ???? ????.


lastLoginIndex ?????? ???????? ????? ????? ??? ?????. 

Ctrl ?? ?????? ?????????? ???
 
 ****************************************************************************************************************************/
class UIEasyLoginWnd extends UICommonAPI;

const TIMER_ID_CHANGETEXT    = 10234599;
const TIMER_ID               = 10234510;
const TIMER_ID_LOGIN_SYNC    = 10234511;
const MAX_LOGIN_COUNT        = 15;
const EASYLOGIN_INI_FILE     = "EasyLogin.ini";
const EASYLOGIN_XOR_KEY      = "L2Salvation";

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
	RegisterEvent( EV_LoginOK );
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

	if( Language == LANG_Korean) descTxt.SetText("???? ?????? ??!");
}

function AddList (string id, string pw, string server, string character)
{
	local LVDataRecord record;
	
	record.LVDataList.Length = 3;
	record.LVDataList[0].szData = id;
	record.LVDataList[0].szReserved = pw;
	
	record.LVDataList[1].szData = server;
	record.LVDataList[2].szData = character;

	// ??????? ??? 
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
		if( Me.IsShowWindow() == false )
		{
			checkAndShowEasyLogin();
		}
	}
	else if (Event_ID == EV_LoginOK)
	{
		// Login.uc can write success credentials slightly after EV_LoginOK dispatch.
		// Defer sync to reliably read freshly saved values from EasyLogin.ini.
		Me.KillTimer(TIMER_ID_LOGIN_SYNC);
		Me.SetTimer(TIMER_ID_LOGIN_SYNC, 200);
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
	
	Me.SetWindowTitle("AutoLogin");
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
				case  1 : descTxt.SetText("- ??????2 System?????? UIDEV.ini ???????, [EASYLOGIN] ????? ???? ????????? ????."); break;
				case  2 : descTxt.SetText("- ????? ????? ?????? dongland@ncsoft.com ???? ?????????."); break;
				case  3 : descTxt.SetText("- dongland???? Donation ???? ????. -_-"); break;
				case  4 : descTxt.SetText("- (-_-)/~~~~?? ???? ??? ?????????? ??????~ "); break;
				case  5 : descTxt.SetText("- ??????? ????? ??? ??? ????? ???? ?????? ??????."); break;
				case  6 : descTxt.SetText("- ??? 50???? ????? ????? ???? ?? ?? ??????."); break;
				case  7 : descTxt.SetText("- Server?? Char(?????? ????)?? ????? ??? ??? ????."); break;
				default : descTxt.SetText("- ??? ????? ?? ?????? ????????. "); break;
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
	else if (TimerID == TIMER_ID_LOGIN_SYNC)
	{
		Me.KillTimer(TIMER_ID_LOGIN_SYNC);
		SyncLastSuccessAccount();
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
	local string encPw;
	
	if (idEditBox.GetString() != "" && pwEditBox.GetString() != "")
	{
		nMax = idList.GetRecordCount();
		if (nMax >= MAX_LOGIN_COUNT)
			return;

		encPw = EncryptPassword(pwEditBox.GetString());

		SetINIString("EASYLOGIN", "id"  $ nMax + 1, idEditBox.GetString(), EASYLOGIN_INI_FILE);
		SetINIString("EASYLOGIN", "pwEnc"  $ nMax + 1, encPw, EASYLOGIN_INI_FILE);
		SetINIString("EASYLOGIN", "pw"  $ nMax + 1, "", EASYLOGIN_INI_FILE);
		SetINIString("EASYLOGIN", "server"  $ nMax + 1, serverEditBox.GetString(), EASYLOGIN_INI_FILE);
		SetINIString("EASYLOGIN", "char"  $ nMax + 1, charEditBox.GetString(), EASYLOGIN_INI_FILE);

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
		SetINIString("EASYLOGIN", "id"  $ idx + 1, "", EASYLOGIN_INI_FILE);
		SetINIString("EASYLOGIN", "pwEnc"  $ idx + 1, "", EASYLOGIN_INI_FILE);
		SetINIString("EASYLOGIN", "pw"  $ idx + 1, "", EASYLOGIN_INI_FILE);
		SetINIString("EASYLOGIN", "server"  $ idx + 1, "", EASYLOGIN_INI_FILE);
		SetINIString("EASYLOGIN", "char"  $ idx + 1, "", EASYLOGIN_INI_FILE);

		// ini ?? ??????? ??????? 
		for (i = 1; i <= MAX_LOGIN_COUNT; i++)
		{
			if (idList.GetRecordCount() >= i)
			{
				idList.GetRec(i - 1, record);
				id = record.LVDataList[0].szData;
				pw = EncryptPassword(record.LVDataList[0].szReserved);
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
				GetINIString("EASYLOGIN", "id" $ i, oldid, EASYLOGIN_INI_FILE);
				
			if(id != "" || oldid != "")
			{
				SetINIString("EASYLOGIN", "id" $ i, id, EASYLOGIN_INI_FILE);
				SetINIString("EASYLOGIN", "pwEnc" $ i, pw, EASYLOGIN_INI_FILE);
				SetINIString("EASYLOGIN", "pw" $ i, "", EASYLOGIN_INI_FILE);
				SetINIString("EASYLOGIN", "server" $ i, server, EASYLOGIN_INI_FILE);
				SetINIString("EASYLOGIN", "char" $ i, character, EASYLOGIN_INI_FILE);
			}
		}
	}
}

// ????? ????? ?????? ?????? ???? ?????? ????? ???, ?????, ????? ??? ???? ?????? ??????? ???.
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

//????? ??????????....
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

// ???????? ??? UI?? ?????? ?? ???????? ?????.
function setUseEasyLogin(bool flag)
{
	SetINIString("EASYLOGIN", "use", String(boolToNum(flag)), EASYLOGIN_INI_FILE);
}

// ???????? ??? UI?? ?????? ?? ???????? ?????.
function bool getUseEasyLogin()
{
	local string stringValue;
	GetINIString("EASYLOGIN", "use", stringValue, EASYLOGIN_INI_FILE);

	return numToBool(int(stringValue));
}

// ?????? ???
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

		// ???????? ????? ???????? ???? 
		SetINIString("EASYLOGIN", "lastLoginIndex", String(idList.GetSelectedIndex()), EASYLOGIN_INI_FILE);
		
		// ?????? ?????? ??? ??????
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
	GetINIString("EASYLOGIN", "use", stringValue, EASYLOGIN_INI_FILE);
	if (stringValue == "")
	{
		stringValue = "1";
		SetINIString("EASYLOGIN", "use", stringValue, EASYLOGIN_INI_FILE);
	}

	if (int(stringValue) > 0)
	{		
		OnManagerButtonClickHandler(true);
		Me.ShowWindow();
		loadListByINI();
	}
}

function loadListByINI()
{
	local string id, pw, pwEnc, server, character, listIndex;
	local int i;

	
	idList.DeleteAllItem();
	for (i = 1; i <= MAX_LOGIN_COUNT; i++)
	{
		id = "";
		pw = "";
		pwEnc = "";
		server = "";
		character = "";
		GetINIString("EASYLOGIN", "id" $ i, id, EASYLOGIN_INI_FILE);
		GetINIString("EASYLOGIN", "pwEnc" $ i, pwEnc, EASYLOGIN_INI_FILE);
		GetINIString("EASYLOGIN", "pw" $ i, pw, EASYLOGIN_INI_FILE);
		GetINIString("EASYLOGIN", "server" $ i, server, EASYLOGIN_INI_FILE);
		GetINIString("EASYLOGIN", "char" $ i, character, EASYLOGIN_INI_FILE);

		if (id != "")
		{
			if (pwEnc != "")
			{
				pw = DecryptPassword(pwEnc);
			}
			else
			{
				// Backward compatibility with legacy plain-text entries.
				SetINIString("EASYLOGIN", "pwEnc" $ i, EncryptPassword(pw), EASYLOGIN_INI_FILE);
				SetINIString("EASYLOGIN", "pw" $ i, "", EASYLOGIN_INI_FILE);
			}

			AddList(id, pw, server, character);
		}
	}

	// ???????? ???????? ??????? ????? ????
	GetINIString("EASYLOGIN", "lastLoginIndex", listIndex, EASYLOGIN_INI_FILE);
	idList.SetSelectedIndex(int(listIndex), true);

}

function int FindAccountIndexByID(string accountID)
{
	local int i;
	local LVDataRecord record;

	for (i = 0; i < idList.GetRecordCount(); i++)
	{
		idList.GetRec(i, record);
		if (record.LVDataList.Length > 0 && record.LVDataList[0].szData == accountID)
			return i;
	}

	return -1;
}

function SyncLastSuccessAccount()
{
	local string id, pwEnc, pw;
	local int idx;
	local LVDataRecord record;

	GetINIString("EASYLOGIN", "lastSuccessID", id, EASYLOGIN_INI_FILE);
	GetINIString("EASYLOGIN", "lastSuccessPWEnc", pwEnc, EASYLOGIN_INI_FILE);

	if (id == "" || pwEnc == "")
		return;

	pw = DecryptPassword(pwEnc);
	idx = FindAccountIndexByID(id);

	if (idx >= 0)
	{
		idList.GetRec(idx, record);
		record.LVDataList[0].szReserved = pw;
		idList.ModifyRecord(idx, record);
		SetINIString("EASYLOGIN", "pwEnc" $ string(idx + 1), pwEnc, EASYLOGIN_INI_FILE);
		SetINIString("EASYLOGIN", "pw" $ string(idx + 1), "", EASYLOGIN_INI_FILE);
		SetINIString("EASYLOGIN", "lastLoginIndex", String(idx), EASYLOGIN_INI_FILE);
	}
	else if (idList.GetRecordCount() < MAX_LOGIN_COUNT)
	{
		AddList(id, pw, "", "");
		SetINIString("EASYLOGIN", "id" $ string(idList.GetRecordCount()), id, EASYLOGIN_INI_FILE);
		SetINIString("EASYLOGIN", "pwEnc" $ string(idList.GetRecordCount()), pwEnc, EASYLOGIN_INI_FILE);
		SetINIString("EASYLOGIN", "pw" $ string(idList.GetRecordCount()), "", EASYLOGIN_INI_FILE);
		SetINIString("EASYLOGIN", "server" $ string(idList.GetRecordCount()), "", EASYLOGIN_INI_FILE);
		SetINIString("EASYLOGIN", "char" $ string(idList.GetRecordCount()), "", EASYLOGIN_INI_FILE);
		SetINIString("EASYLOGIN", "lastLoginIndex", String(idList.GetRecordCount() - 1), EASYLOGIN_INI_FILE);
	}
}

function string EncryptPassword(string plain)
{
	local int i, keyLen, ch, keyCh;
	local string out;

	keyLen = Len(EASYLOGIN_XOR_KEY);
	if (keyLen <= 0)
		return plain;

	out = "";
	for (i = 0; i < Len(plain); i++)
	{
		ch = Asc(Mid(plain, i, 1));
		keyCh = Asc(Mid(EASYLOGIN_XOR_KEY, i % keyLen, 1));
		out = out $ ByteToHex((ch ^ keyCh) & 255);
	}

	return out;
}

function string DecryptPassword(string enc)
{
	local int i, keyLen, ch, keyCh;
	local string out, cur;

	keyLen = Len(EASYLOGIN_XOR_KEY);
	if (keyLen <= 0)
		return enc;

	out = "";
	for (i = 0; i + 1 < Len(enc); i += 2)
	{
		cur = Mid(enc, i, 2);
		ch = HexToByte(cur);
		keyCh = Asc(Mid(EASYLOGIN_XOR_KEY, (i / 2) % keyLen, 1));
		out = out $ Chr((ch ^ keyCh) & 255);
	}

	return out;
}

function string ByteToHex(int v)
{
	local string digits;
	digits = "0123456789ABCDEF";
	return Mid(digits, (v / 16) & 15, 1) $ Mid(digits, v & 15, 1);
}

function int HexToByte(string hexPair)
{
	local string digits;
	local int hi, lo;

	digits = "0123456789ABCDEF";
	hi = InStr(digits, Caps(Mid(hexPair, 0, 1)));
	lo = InStr(digits, Caps(Mid(hexPair, 1, 1)));
	if (hi < 0 || lo < 0)
		return 0;

	return hi * 16 + lo;
}

/**
 * ?????? ESC ??? ??? ??? 
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
