//------------------------------------------------------------------------------------------------------------------------
//
// ùùùù         : LogIn ùùùùùùùù ùùùù - SCALEFORM UI
//                ùùùù ù?ùùù
//
//------------------------------------------------------------------------------------------------------------------------
class LogIn extends GFxUIScript;

//ùùùùù ù?ù ùù?
const FLASH_XPOS = 0;
const FLASH_YPOS = 0;

//Gfx @ uc ùùùùùù ùùùù ù?ù
var array<GFxValue> args;
var GFxValue invokeResult;

var string logInID;
var string m_LastTryID;
var string m_LastTryPass;

const EASYLOGIN_INI_FILE     = "EasyLogin.ini";
const EASYLOGIN_XOR_KEY      = "L2Salvation";
const MAX_LOGIN_COUNT        = 15;

//UIùù UC
var L2Util util;

function OnRegisterEvent()
{
	RegisterEvent( EV_LoginBegin );
	RegisterEvent( EV_LoginFail );
	RegisterEvent( EV_LoginOK );
	//5700 ùùù?ù ùùùùùù ùù
	RegisterEvent( EV_LoginUIGetFocus );
}

function OnLoad()
{	
	registerState( "LogIn", "LoginState" );	

	SetContainer( "ContainerHUD" ); 	
	//SetDefaultShow(true);
	setHUD();
	//SetFixedPositionRate( 0.5f, 0.59f );
	
	SetAlwaysOnTop(true);	
	logInID = "";
	HasTextField(false);

	SetAnchor("", EAnchorPointType.ANCHORPOINT_BottomRight, EAnchorPointType.ANCHORPOINT_TopLeft, 0, 0 );	
}

function OnShow(){
//	RequestLogin( "admin12DD34", "FFsadmin12DD34", 7 ); //ùùùùùù ù ùùùù!
 }
function OnFlashLoaded(){}	
function OnHide()
{
	//RestartFlash();
}

/*
 * gfx4.x
 */
function onCallUCFunction( String funcName , string param ) 
{
	local string id;
	local string pass;
	local int ncopt;
	
	local string delString;
	local int i ;

	local string url;
	//debug ( "onCallUCFunction" @ funcName @ param );
	
	switch (funcName ) 
	{
		case "setLogin":
			//ùùù?ù
			ParseString(param, "ID", id);
			SaveLastLoginID( id );
			m_LastTryID = id;
			//ù?ùùùùù
			ParseString(param, "pass", pass);
			if (pass == "")
			{
				ParseString(param, "pw", pass);
			}
			m_LastTryPass = pass;
			SetINIString("EASYLOGIN", "pendingID", m_LastTryID, EASYLOGIN_INI_FILE);
			SetINIString("EASYLOGIN", "pendingPWEnc", EncryptPassword(m_LastTryPass), EASYLOGIN_INI_FILE);
			//OPT
			Parseint(param, "ncopt", ncopt);
			
			//ù?ùùù ùùù API
			RequestLogin( ID, pass, ncopt );
			
			delString = "";
			for ( i = 0 ; i < Len(param ) ; i ++ ) 
			{
				delString = delString $ "*";	
			}
			param = delString;

			delString = "";
			for ( i = 0 ; i < Len( pass ) ; i ++ ) 
			{
				delString = delString $ "*";				
			}
			pass = delString;

			delString = "";
			for ( i = 0 ; i < Len( id ) ; i ++ ) 
			{
				delString = delString $ "*";				
			}
			id = delString;

			delString = "";
			for ( i = 0 ; i < Len( ncopt ) ; i ++ ) 
			{
				delString = delString $ "0";		
			}
			ncopt = int ( delString ) ;
			
			param = "";
			id = "";
			pass = "";
			ncopt = -1;

			//Debug ( "login" @ param @ id @ pass @ ncopt) ;
			//Debug ( "login" @ param.Length @ id.Length @ pass.Length @ ncopt.Length );
			
		break;
		case "out":
			RefuseLogin();
		break;
		case "openURL":
			url = getSystemString( 5192 ) ;
			OpenGivenURL( url );
		break;
	}
}

/*
 * gfx3.x
function OnCallUCLogic( int logicID, string param )
{
	local string id;
	local string pass;
	local int ncopt;
	
	Debug("OnCallUCLogic" @ logicID @ param);
	//ù?ùùù ùùùùùù ùùùù
	if( logicID == 0 )
	{
		//ùùù?ù
		ParseString(param, "ID", id);
		SaveLastLoginID( id );
		//ù?ùùùùù
		ParseString(param, "pass", pass);
		//OPT
		Parseint(param, "ncopt", ncopt);
		
		//ù?ùùù ùùù API
		RequestLogin( ID, pass, ncopt );
	}
	//ùùùùùù
	else if( logicID == 1 )
	{		
		
		RefuseLogin();
	}
}
 */

function OnEvent(int Event_ID, string param)
{	
	local string ErrorMsg;

	//Debug("uc onEvent" @ Event_ID);

	if( Event_ID == EV_LoginBegin )
	{
		//Debug("OnEvent EV_LoginBegin" @ IsShowWindow() );
		if( IsShowWindow() == false )
		{
			ShowWindow();
			FlashInit();
			SendErrorMsg("");
		}
	}
	else if( Event_ID == EV_LoginOK )
	{		
		SaveLastSuccessfulLogin();
		SendLogInSuccess();
	}
	else if( Event_ID == EV_LoginFail )
	{		
		ParseString( param, "ErrorMsg", ErrorMsg );
		SendErrorMsg(ErrorMsg);
	}
}

//ùùùù ùù.
function FlashInit()
{
	local string param;	
	// gfx3.0 ùùùù /////////////////////////////////////////////////////////////////////
	// ùùùùù ùùù ùùùùù ù?ùù?ù ùùùù
	//AllocGFxValues(args, 2);		
	//AllocGFxValue(invokeResult);

	// ùùùù ù?ù : ù?ù? ùù? 0ùù
	//args[0].SetInt( 0 );
	//CreateObject(args[1]);	

	//args[1].SetMemberString( "logInID", GetLastLoginID() );
	//args[1].SetMemberBool( "isOTP", IsUseOTP() );
	//args[1].SetMemberString( "optMsg", GetSystemMessage( 5068 ) );
	//args[1].SetMemberBool( "isUseEMailAccount", isUseEMailAccount() );	
	
//	Invoke( "_root.onEvent", args, invokeResult );

//	DeallocGFxValue( invokeResult );
//	DeallocGFxValues( args );

	// gfx4.0 ùùùù /////////////////////////////////////////////////////////////////////	
	//Debug("111111GetLastLoginID() " @ GetLastLoginID() );
	param = makeVar2Str( "logInID", GetLastLoginID() );
	param = param @ makeVar2Str( "logInPW", GetLastSuccessfulPassword() );
	param = param @ makeVar2Str( "isOTP", string( IsUseOTP()) );
	param = param @ makeVar2Str( "optMsg", GetSystemMessage( 5068 ) );
	param = param @ makeVar2Str( "isUseEMailAccount", String( isUseEMailAccount() ) );	
	callGFxFunction("LogIn","flashInit", param);
}

/*
 * gfx4.0 ùùùù
 */
function string makeVar2Str(string varName, string vars)
{
	return varName $ "=" $ vars;
}

function SaveLastSuccessfulLogin()
{
	local string pendingID;
	local string pendingPWEnc;

	if (m_LastTryID == "" || m_LastTryPass == "")
	{
		GetINIString("EASYLOGIN", "pendingID", pendingID, EASYLOGIN_INI_FILE);
		GetINIString("EASYLOGIN", "pendingPWEnc", pendingPWEnc, EASYLOGIN_INI_FILE);
		if (m_LastTryID == "")
			m_LastTryID = pendingID;
		if (m_LastTryPass == "" && pendingPWEnc != "")
			m_LastTryPass = DecryptPassword(pendingPWEnc);
	}

	if (m_LastTryID != "" && m_LastTryPass != "")
	{
		SetINIString("EASYLOGIN", "lastSuccessID", m_LastTryID, EASYLOGIN_INI_FILE);
		SetINIString("EASYLOGIN", "lastSuccessPWEnc", EncryptPassword(m_LastTryPass), EASYLOGIN_INI_FILE);
		SyncAutoLoginList(m_LastTryID, m_LastTryPass);
		SetINIString("EASYLOGIN", "pendingID", "", EASYLOGIN_INI_FILE);
		SetINIString("EASYLOGIN", "pendingPWEnc", "", EASYLOGIN_INI_FILE);
	}
}

function SyncAutoLoginList(string accountID, string plainPW)
{
	local int i;
	local int emptyIdx;
	local string curID;
	local string enc;

	enc = EncryptPassword(plainPW);
	emptyIdx = -1;

	for (i = 1; i <= MAX_LOGIN_COUNT; i++)
	{
		GetINIString("EASYLOGIN", "id" $ i, curID, EASYLOGIN_INI_FILE);
		if (curID == accountID)
		{
			SetINIString("EASYLOGIN", "pwEnc" $ i, enc, EASYLOGIN_INI_FILE);
			SetINIString("EASYLOGIN", "pw" $ i, "", EASYLOGIN_INI_FILE);
			SetINIString("EASYLOGIN", "lastLoginIndex", String(i - 1), EASYLOGIN_INI_FILE);
			return;
		}

		if (emptyIdx < 0 && curID == "")
		{
			emptyIdx = i;
		}
	}

	if (emptyIdx > 0)
	{
		SetINIString("EASYLOGIN", "id" $ emptyIdx, accountID, EASYLOGIN_INI_FILE);
		SetINIString("EASYLOGIN", "pwEnc" $ emptyIdx, enc, EASYLOGIN_INI_FILE);
		SetINIString("EASYLOGIN", "pw" $ emptyIdx, "", EASYLOGIN_INI_FILE);
		SetINIString("EASYLOGIN", "server" $ emptyIdx, "", EASYLOGIN_INI_FILE);
		SetINIString("EASYLOGIN", "char" $ emptyIdx, "", EASYLOGIN_INI_FILE);
		SetINIString("EASYLOGIN", "lastLoginIndex", String(emptyIdx - 1), EASYLOGIN_INI_FILE);
	}
}

function string GetLastSuccessfulPassword()
{
	local string enc;
	GetINIString("EASYLOGIN", "lastSuccessPWEnc", enc, EASYLOGIN_INI_FILE);
	if (enc == "")
		return "";
	return DecryptPassword(enc);
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

function SendLogInSuccess()
{
	// gfx3.0 ùùùù /////////////////////////////////////////////////////////////////////
	// ùùùùù ùùù ùùùùù ù?ùù?ù ùùùù
	/*
	AllocGFxValues(args, 1);		
	AllocGFxValue(invokeResult);

	// ùùùù ù?ù : ù?ù? ùù? 5ùù
	args[0].SetInt( 5 );

	Invoke( "_root.onEvent", args, invokeResult );

	DeallocGFxValue( invokeResult );
	DeallocGFxValues( args );
*/

	// gfx4.0 ùùùù /////////////////////////////////////////////////////////////////////
	HideWindow();
	callGFxFunction("LogIn","loginSuccess", "");
}


//ùùùù ù?ùùù ùùùù.
function SendErrorMsg( string ErrorMsg )
{
	// gfx3.0 ùùùù /////////////////////////////////////////////////////////////////////
	// ùùùùù ùùù ùùùùù ù?ùù?ù ùùùù
	/*
	AllocGFxValues(args, 2);		
	AllocGFxValue(invokeResult);

	// ùùùù ù?ù : ù?ù? ùù? 10ùù
	args[0].SetInt( 10 );
	CreateObject(args[1]);

	args[1].SetMemberString( "ErrorMsg", ErrorMsg );
	Invoke( "_root.onEvent", args, invokeResult );

	DeallocGFxValue( invokeResult );
	DeallocGFxValues( args );
	*/
	// gfx4.0 ùùùù /////////////////////////////////////////////////////////////////////
	callGFxFunction("LogIn","ErrorMsg", ErrorMsg);
}

//Flashùù ùùù? ùùùùùù ù?ù? ù?ù.
event OnMouseOver( WindowHandle w )
{	
	
}
//Flashùù ùùù? ù?ùùù ù?ù? ù?ù.
event OnMouseOut( WindowHandle w )
{
	//ùùùùùù ùùù? ùù?ùù 0,0ùùùù.
	ForceToMoveMousePos( 0, 0 );
}
defaultproperties
{
}
