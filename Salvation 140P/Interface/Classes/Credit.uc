//------------------------------------------------------------------------------------------------------------------------
//
// 力格         : Credit  ( 农饭调 ) - SCALEFORM UI
//
//------------------------------------------------------------------------------------------------------------------------
class Credit extends L2UIGFxScript;

const FLASH_WIDTH  = 800;
const FLASH_HEIGHT = 600;

var int currentScreenWidth, currentScreenHeight;

function OnRegisterEvent()
{
	RegisterGFxEventForLoaded (EV_ResolutionChanged);
	RegisterGFxEvent(EV_CreditXMLString);  // param 昏力 凳. 
}

function OnLoad()
{	
	registerState("Credit", "CreditState" );
	setDefaultShow(true);
}

function OnFlashLoaded()
{
	SetAnchor("", EAnchorPointType.ANCHORPOINT_TopLeft, EAnchorPointType.ANCHORPOINT_TopLeft, 0, 0 );	
}

function onCallUCFunction( string functionName, string param )
{
	//local string strParam;
	// Debug("sampe's onCallUCFunction" @ functionName @ param);
	//switch ( functionName ) 
	//{
	//	case "OpenHelpHTML" :
	//		ParamAdd(strParam, "FilePath", "..\\L2text\\"$param);
	//		ExecuteEvent(EV_ShowHelp, strParam);
	//	break;
		
	//}
}


function OnCallUCLogic( int logicID, string param )
{
	if (logicID == 1)
	{
		if (param == "exit")
		{
			// 辆丰
			EndCredit();
		}
	}
}
defaultproperties
{
}
