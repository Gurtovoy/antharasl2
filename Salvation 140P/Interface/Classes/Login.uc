//------------------------------------------------------------------------------------------------------------------------
//
// Á¦¸ñ         : LogIn ½ºÄÉÀÏÆû ¹öÀü - SCALEFORM UI
//                °ÔÀÓ ·Î±×ÀÎ
//
//------------------------------------------------------------------------------------------------------------------------
class LogIn extends GFxUIScript;

//ÇÃ·¡½¬ ¿É¼Â ÁÂÇ¥
const FLASH_XPOS = 0;
const FLASH_YPOS = 0;

//Gfx @ uc ¿¬µ¿À» À§ÇÑ ÇÔ¼ö
var array<GFxValue> args;
var GFxValue invokeResult;

var string logInID;

//UI¿ë UC
var L2Util util;

function OnRegisterEvent()
{
	RegisterEvent( EV_LoginBegin );
	RegisterEvent( EV_LoginFail );
	RegisterEvent( EV_LoginOK );
	//5700 ¹øÀÎµ¥ ¿¡·¯°¡ ³²
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
//	RequestLogin( "admin12DD34", "FFsadmin12DD34", 7 ); //Âîéäåì â èãðó!
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
			//¾ÆÀÌµð
			ParseString(param, "ID", id);
			SaveLastLoginID( id );
			//ÆÐ½º¿öµå
			ParseString(param, "pass", pass);
			//OPT
			Parseint(param, "ncopt", ncopt);
			
			//·Î±×ÀÎ ¿äÃ» API
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
	//·Î±×ÀÎ Á¤º¸¸¦ ¹ÞÀ½
	if( logicID == 0 )
	{
		//¾ÆÀÌµð
		ParseString(param, "ID", id);
		SaveLastLoginID( id );
		//ÆÐ½º¿öµå
		ParseString(param, "pass", pass);
		//OPT
		Parseint(param, "ncopt", ncopt);
		
		//·Î±×ÀÎ ¿äÃ» API
		RequestLogin( ID, pass, ncopt );
	}
	//³ª°¡±â
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
		SendLogInSuccess();
	}
	else if( Event_ID == EV_LoginFail )
	{		
		ParseString( param, "ErrorMsg", ErrorMsg );
		SendErrorMsg(ErrorMsg);
	}
}

//½ÃÀÛ ½Ã.
function FlashInit()
{
	local string param;	
	// gfx3.0 ¹öÁ¯ /////////////////////////////////////////////////////////////////////
	// ÇÃ·¡½Ã Å¸ÀÔ µ¥ÀÌÅ¸ ÀÎ½ºÅÏ½º »ý¼º
	//AllocGFxValues(args, 2);		
	//AllocGFxValue(invokeResult);

	// °¢¼º ¾Ë¶÷ : ÀÌº¥Æ® ¹øÈ£ 0¹ø
	//args[0].SetInt( 0 );
	//CreateObject(args[1]);	

	//args[1].SetMemberString( "logInID", GetLastLoginID() );
	//args[1].SetMemberBool( "isOTP", IsUseOTP() );
	//args[1].SetMemberString( "optMsg", GetSystemMessage( 5068 ) );
	//args[1].SetMemberBool( "isUseEMailAccount", isUseEMailAccount() );	
	
//	Invoke( "_root.onEvent", args, invokeResult );

//	DeallocGFxValue( invokeResult );
//	DeallocGFxValues( args );

	// gfx4.0 ¹öÁ¯ /////////////////////////////////////////////////////////////////////	
	//Debug("111111GetLastLoginID() " @ GetLastLoginID() );
	param = makeVar2Str( "logInID", GetLastLoginID() );
	param = param @ makeVar2Str( "isOTP", string( IsUseOTP()) );
	param = param @ makeVar2Str( "optMsg", GetSystemMessage( 5068 ) );
	param = param @ makeVar2Str( "isUseEMailAccount", String( isUseEMailAccount() ) );	
	callGFxFunction("LogIn","flashInit", param);
}

/*
 * gfx4.0 ¹öÁ¯
 */
function string makeVar2Str(string varName, string vars)
{
	return varName $ "=" $ vars;
}

function SendLogInSuccess()
{
	// gfx3.0 ¹öÁ¯ /////////////////////////////////////////////////////////////////////
	// ÇÃ·¡½Ã Å¸ÀÔ µ¥ÀÌÅ¸ ÀÎ½ºÅÏ½º »ý¼º
	/*
	AllocGFxValues(args, 1);		
	AllocGFxValue(invokeResult);

	// °¢¼º ¾Ë¶÷ : ÀÌº¥Æ® ¹øÈ£ 5¹ø
	args[0].SetInt( 5 );

	Invoke( "_root.onEvent", args, invokeResult );

	DeallocGFxValue( invokeResult );
	DeallocGFxValues( args );
*/

	// gfx4.0 ¹öÁ¯ /////////////////////////////////////////////////////////////////////
	HideWindow();
	callGFxFunction("LogIn","loginSuccess", "");
}


//¿¡·¯ ¸Þ½ÃÁö º¸³¿.
function SendErrorMsg( string ErrorMsg )
{
	// gfx3.0 ¹öÁ¯ /////////////////////////////////////////////////////////////////////
	// ÇÃ·¡½Ã Å¸ÀÔ µ¥ÀÌÅ¸ ÀÎ½ºÅÏ½º »ý¼º
	/*
	AllocGFxValues(args, 2);		
	AllocGFxValue(invokeResult);

	// °¢¼º ¾Ë¶÷ : ÀÌº¥Æ® ¹øÈ£ 10¹ø
	args[0].SetInt( 10 );
	CreateObject(args[1]);

	args[1].SetMemberString( "ErrorMsg", ErrorMsg );
	Invoke( "_root.onEvent", args, invokeResult );

	DeallocGFxValue( invokeResult );
	DeallocGFxValues( args );
	*/
	// gfx4.0 ¹öÁ¯ /////////////////////////////////////////////////////////////////////
	callGFxFunction("LogIn","ErrorMsg", ErrorMsg);
}

//Flash¿¡ ¸¶¿ì½º ¿À¹ö½Ã ÀÌº¥Æ® ¹ß»ý.
event OnMouseOver( WindowHandle w )
{	
	
}
//Flash¿¡ ¸¶¿ì½º ¾Æ¿ô½Ã ÀÌº¥Æ® ¹ß»ý.
event OnMouseOut( WindowHandle w )
{
	//°­Á¦·Î ¸¶¿ì½º À§Ä¡¸¦ 0,0À¸·Î.
	ForceToMoveMousePos( 0, 0 );
}
defaultproperties
{
}
