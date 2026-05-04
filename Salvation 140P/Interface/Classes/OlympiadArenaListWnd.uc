class OlympiadArenaListWnd extends L2UIGFxScript;

function OnRegisterEvent()
{
	registerGFxEvent(EV_ReceiveOlympiadGameList);
}

function OnLoad()
{
	registerState( getCurrentWindowName(String(self)), "GAMINGSTATE" );
	SetContainerWindow( WINDOWTYPE_DECO_NORMAL, 2285);
	AddState("GAMINGSTATE");	
}

/*
function OnFlashLoaded()
{
	local float xLoc;
	local float yLoc;	

	local array<GFxValue> args;
	local GFxValue invokeResult;

	RegisterDelegateHandler(EDHandler_OlympiadArenaList);

	//창의 기본 위치 지정 및 세이브 된 창위치로 이동.
	if( IsSavedInfo() )
	{
		SetGFxFromSavedInfo();
	}
	else
	{		
		// 플래시 타입 데이타 인스턴스 생성
		AllocGFxValues(args, 2);		
		AllocGFxValue(invokeResult);

		GetAnchorPointFromWindow( xLoc, yLoc, EAnchorPointType.ANCHORPOINT_CenterCenter );

		args[0].SetInt( int(xLoc) + FLASH_XPOS );
		args[1].SetInt( int(yLoc) + FLASH_YPOS );

		Invoke( "_root.onMove", args, invokeResult );

		DeallocGFxValue( invokeResult );
		DeallocGFxValues( args );
	}
}


function OnEvent(int Event_ID, string param)
{
	//Event : EV_ReceiveOlympiadGameList
	local int gameNum;
	local int bRemain;
	local int gameIndex;
	local int arenaType, arenaState;
	local string player1Name, player2Name;
	local int i;
	local array<GFxValue> args;
	local GFxValue argArray;
	local GFxValue invokeResult;
	local GFxValue ArrayElem;
	// end
	
		
	if ( Event_ID == EV_ReceiveOlympiadGameList )
	{
		ShowWindow();
		
		AllocGFxValues(args,2);
		AllocGFxValue(argArray);
		AllocGFxValue(invokeResult);
		AllocGFxValue(ArrayElem);

		args[0].SetInt(4);

		CreateObject(args[1]);
		CreateArray(argArray);
		
		ParseInt(param,"gameNum",gameNum);
		ParseInt(param,"bRemain",bRemain);
		args[1].SetMemberBool("bRemain",bool(bRemain));
		for ( i = 0; i < gameNum; ++i )
		{
			CreateObject(ArrayElem);
			
			ParseInt(param,"num_" $ i,gameIndex);
			ArrayElem.SetMemberInt("num", gameIndex+1);
			
			ParseInt(param,"arenaType_" $ i ,arenaType);
			ArrayElem.SetMemberString("arenaType",GetArenaType(arenaType));

			ParseInt(param,"arenaState_" $ i, arenaState);
			ArrayElem.SetMemberString("arenaState",GetArenaState(arenaState));

			ParseString(param,"player1Name_" $ i,player1Name);
			ArrayElem.SetMemberString("player1Name",player1Name);
			
			ArrayElem.SetMemberInt("player1Color",1);

			ParseString(param,"player2Name_" $ i,player2Name);
			ArrayElem.SetMemberString("player2Name",player2Name);

			ArrayElem.SetMemberInt("player2Color",2);
			
			argArray.SetElement(i,ArrayElem);
			//Debug("start");
			//Debug("num=" $ gameIndex $ ",ArenaType=" $ arenaType $ ",State=" $ arenaState );
			//Debug("Name1=" $ player1Name $ ",Name2=" $ player2Name );
			//Debug("color1=" $ 1 $ ",color2=" $ 2 );
			//Debug("index=" $ i );
			//Debug("end");
		}
		//Debug("gamenum="$gameNum);
		//Debug("remain="$bRemain);
		args[1].SetMemberValue("arenaListArray", argArray);

		Invoke("_root.onEvent", args, invokeResult);
		DeallocGFxValue(argArray);
		DeallocGFxValue(ArrayElem);
		DeallocGFxValue(invokeResult);
		DeallocGFxValues(args);
	}
}
function string GetArenaType(int iType)
{
	if ( iType < 3 )
		return GetSystemString(2283-iType);
	return "";
}

function string GetArenaState(int iState)
{
	if ( iState == 1 || iState == 2 )
		return GetSystemString(1717+iState);
	else if ( iState == 0 )
		return GetSystemString(906);
	else
		return "";
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	local array<GFxValue> args;

	local GFxValue invokeResult;

	AllocGFxValues(args, 1);		
	
	Invoke("_root.onReceivedCloseUI", args, invokeResult);

	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);	
}
*/
defaultproperties
{
}
