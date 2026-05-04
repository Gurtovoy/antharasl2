//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : ArchiveHotLinkWnd  ( 박물관 hotlink 스킬 ) - SCALEFORM UI
//
//------------------------------------------------------------------------------------------------------------------------
class ArchiveHotLinkWnd extends GFxUIScript;

//플래쉬 옵셋 좌표
const FLASH_XPOS = 0;
const FLASH_YPOS = -50;

var int currentScreenWidth, currentScreenHeight;
const cuttingCriteria = 1000000000 ; //10억 9자리까지 절삭
const cuttingCriteriaCipher = 9;//10억 9자리까지 절삭

function OnRegisterEvent()
{
	registerEvent(EV_StatisticHotLinkWndShow);	
	//Debug("ArchiveHotLinkWnd  OnRegisterEvent =============> ");	
}

function OnLoad()
{
	registerState( "ArchiveHotLinkWnd", "GamingState" );
	
	SetClosingOnESC();
}

function OnShow()
{
	PlayConsoleSound(IFST_MAPWND_OPEN);
}

function OnHide()
{
	PlayConsoleSound(IFST_MAPWND_CLOSE);
	dispatchEventToFlash_String(11 ,"" ) ;
}

function dispatchEventToFlash_String(int Event_ID, string argString)
{
	local array<GFxValue> args;
	local GFxValue invokeResult;

	AllocGFxValues(args, 2);
	AllocGFxValue(invokeResult);
	args[0].SetInt(Event_ID);
	CreateObject(args[1]);

//	Debug("argString"@argString);
	args[1].SetMemberString("string", argString );

	Invoke("_root.onEvent", args, invokeResult);
	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);
}

function OnFlashLoaded()
{	
	local array<GFxValue> args;
	local GFxValue invokeResult;

	local float xLoc;
	local float yLoc;	
	
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_Statistic);

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

function OnDefaultPosition()
{	
//	Debug("ArchiveHotLinkWnd.uc.onDefaultPosition()");
}
function OnCallUCLogic( int logicID, string param )
{
}

function OnFocus(bool bFlag, bool bTransparency)
{
	local array<GFxValue> args;
	local GFxValue invokeResult;

	AllocGFxValues(args,2);	
	args[0].setbool(bflag);
	args[1].setbool(bTransparency);
	AllocGFxValue(invokeResult);
		
	Invoke("_root.onFocus", args, invokeResult);

	DeallocGFxValue(invokeResult);
	DeallocGFxValues(args);	
}

// skillID=1 level=1 time=5 altFlag=1 ctrlFlag=1 shiftFlag=0 totalCoolTime=10 remainCoolTime=10 mainKey=a
// 5130
function OnEvent(int Event_ID, string param)
{
	//local int xLoc, yLoc;
	//local int skillID;

	// 실제 실행할 스킬 아이디
	// local int originalSkillID;
	//local int skillLevel;
	//local int sec;

	//local int totalCoolTime;
	//local int remainCoolTime;

	
	//local int altFlag;
	//local int ctrlFlag;
	//local int shiftFlag;

	//local string IconName;

	//local string mainKey;

	local UserInfo          userinfo;

	local int               ID;
	local string            title;
	local string            Unit;
	local int               UnitType;
	local EStatisticUnitType    Type;

	local int               m_arrow;
	local string            m_name;
	local INT64             m_number;
	local int               tmpPledgeID;
	local int               tmpPledgeCrestID;


	local string content;	

	local int i; //for for

	local int totalNum;
	local array<GFxValue> args;
	local GFxValue invokeResult;

	local GFxValue argArray_m;
	local GFxValue argArray_t;
	local GFxValue ArrayElem;

	// 스킬 텍스쳐 스트링을 받기 위한 itemID
	//local ItemID itemID;

	// 해상도 
	// local int CurrentMaxWidth; 
	// local int CurrentMaxHeight;
	// end

//	Debug("Show archiveHotLinkWnd" @ Event_ID);
//	Debug(" param : " @ param);
	
	if( Event_ID == EV_StatisticHotLinkWndShow){//5591
		if( IsShowWindow() == false )
		{
			ShowWindow();
		}
		//showFlash("archiveHotLinkWnd");
		AllocGFxValues(args,2);
		AllocGFxValue(argArray_m);//달
		AllocGFxValue(argArray_t);//총
		AllocGFxValue(invokeResult);
		AllocGFxValue(ArrayElem);

		// 번호 4번으로 결과 값 받기.
		args[0].SetInt(4);

		// 동적 객체 생성
		CreateObject(args[1]);


		// 동적 배열 생성 
		CreateArray(argArray_m);
		CreateArray(argArray_t);
		
		////////////필요한 요소 생성 끝//////////////////
		/*
		 *
		 *
title=테스트용자료  
ID=3
SizeOfMonth=5
MonthDiff_0=-1 MonthName_0=forTest3 MonthValue_0=1000 MonthPledgeID_0=690 MonthPledgeCrestID_0=690
MonthDiff_1=-1 MonthName_1=a1       MonthValue_1=1001 MonthPledgeID_1=0   MonthPledgeCrestID_1=690
MonthDiff_2=0  MonthName_2=a2       MonthValue_2=1002 MonthPledgeID_2=690 MonthPledgeCrestID_2=0
MonthDiff_3=1  MonthName_3=a3       MonthValue_3=1003 MonthPledgeID_3=0   MonthPledgeCrestID_3=0
MonthDiff_4=1  MonthName_4=a4       MonthValue_4=1004 

SizeOfTotal=5
TotalDiff_0=-1 TotalName_0=b0 TotalValue_0=8000 TotalPledgeID_0=0   TotalPledgeCrestID_0=0
TotalDiff_1=-1 TotalName_1=b1 TotalValue_1=8888 TotalPledgeID_1=690 TotalPledgeCrestID_1=0
TotalDiff_2=0  TotalName_2=b2 TotalValue_2=8889 TotalPledgeID_2=0   TotalPledgeCrestID_2=690
TotalDiff_3=1  TotalName_3=b3 TotalValue_3=8890 TotalPledgeID_3=690 TotalPledgeCrestID_3=690
TotalDiff_4=1  TotalName_4=b4 TotalValue_4=8894 
		 
ID=3 SizeOfMonth=5 MonthDiff_0=-1 MonthName_0=forTest3 MonthValue_0=1000 MonthPledgeID_0=690 MonthPledgeCrestID_0=690 MonthDiff_1=-1 MonthName_1=a1 MonthValue_1=1001 MonthPledgeID_1=0   MonthPledgeCrestID_1=690 MonthDiff_2=0  MonthName_2=a2       MonthValue_2=1002 MonthPledgeID_2=690 MonthPledgeCrestID_2=0 MonthDiff_3=1  MonthName_3=a3       MonthValue_3=1003 MonthPledgeID_3=0   MonthPledgeCrestID_3=0 MonthDiff_4=1  MonthName_4=a4       MonthValue_4=1004  SizeOfTotal=5 TotalDiff_0=-1 TotalName_0=b0 TotalValue_0=8000 TotalPledgeID_0=0   TotalPledgeCrestID_0=0 TotalDiff_1=-1 TotalName_1=b1 TotalValue_1=8888 TotalPledgeID_1=690 TotalPledgeCrestID_1=0 TotalDiff_2=0  TotalName_2=b2 TotalValue_2=8889 TotalPledgeID_2=0   TotalPledgeCrestID_2=690 TotalDiff_3=1  TotalName_3=b3 TotalValue_3=8890 TotalPledgeID_3=690 TotalPledgeCrestID_3=690 TotalDiff_4=1  TotalName_4=b4 TotalValue_4=8894 

*/
		ParseInt(param,"ID", ID);

		content = class'StatisticAPI'.static.GetContentInfo(ID);
	
		ParseInt( content, "UnitType", UnitType);
		Type = EStatisticUnitType(UnitType);
		if (Type == SUT_NONE ||  Type == SUT_RAID)
			ParseString(content, "Unit", Unit);
		else Unit = "";

		ParseString(content, "Name", title);		

		args[1].SetMemberString("title", title);
		args[1].SetMemberString("Unit",Unit);

		GetPlayerInfo( userinfo );
		args[1].SetMemberString("userName", userinfo.name);
		

		ParseInt(param,"SizeOfMonth",totalNum);
		for(i=0;i<totalNum;i++){

			CreateObject(ArrayElem);	

			ParseString(param,"MonthName_" $ i, m_name);//레전드 이름
			ArrayElem.SetMemberString("pcName", m_name);

			ParseINT64(param,"MonthValue_" $ i, m_number);//각 값들.
			//ParseInt(param,"MonthValue_" $ i, m_number);//각 값들.
			
			if (Type == SUT_NONE ||  Type == SUT_RAID)	
			{
				ArrayElem.SetMemberString("numberdata", valueNumToStr(m_number));
			}
			else 
			{
				ArrayElem.SetMemberString("numberdata", setTimeString(m_number));//시간처리 
			}

			ParseInt(param,"MonthDiff_" $ i, m_arrow);//화살표 방향
			ArrayElem.SetMemberInt("arrow", m_arrow);

/*			ParseInt(param,"m_arrow_" $ i, m_arrow);//화살표 방향
			ArrayElem.SetMemberInt("arrow", m_arrow);

			ParseString(param,"m_name_" $ i, m_name);//레전드 이름
			ArrayElem.SetMemberString("pcName", m_name);

			ParseInt(param,"m_number_" $ i, m_number);//각 값들.
			ArrayElem.SetMemberInt("numberdata", m_number);*/

			ParseInt(param, "MonthPledgeID_"$ i, tmpPledgeID);
			ArrayElem.SetMemberInt("pledgeID", tmpPledgeID);

			ParseInt(param, "MonthPledgeCrestID_"$ i, tmpPledgeCrestID);
			ArrayElem.SetMemberInt("pledgeCrestID", tmpPledgeCrestID);

			argArray_m.SetElement(i, ArrayElem);
		}
		args[1].SetMemberValue("resultListArray1", argArray_m);
		
		ParseInt(param,"SizeOfTotal",totalNum);
		for(i=0;i<totalNum;i++){

			CreateObject(ArrayElem);

			ParseString(param,"TotalName_" $ i, m_name);//레전드 이름
			ArrayElem.SetMemberString("pcName", m_name);

			ParseINT64(param,"TotalValue_" $ i, m_number);//각 값들.
			//ParseInt(param,"TotalValue_" $ i, m_number);//각 값들.
			if (Type == SUT_NONE ||  Type == SUT_RAID)			
			{
				ArrayElem.SetMemberString("numberdata", valueNumToStr(m_number) );
			}
			else {
				ArrayElem.SetMemberString("numberdata", setTimeString(m_number));//시간처리 
			}


			ParseInt(param,"TotalDiff_" $ i, m_arrow);//화살표 방향
			ArrayElem.SetMemberInt("arrow", m_arrow);

			/*ParseInt(param,"s_arrow_" $ i, m_arrow);//화살표 방향
			ArrayElem.SetMemberInt("arrow", m_arrow);

			ParseString(param,"s_name_" $ i, m_name);//레전드 이름
			ArrayElem.SetMemberString("pcName", m_name);

			ParseInt(param,"s_number_" $ i, m_number);//각 값들.
			ArrayElem.SetMemberInt("numberdata", m_number);*/

			ParseInt(param, "TotalPledgeID_"$ i, tmpPledgeID);
			ArrayElem.SetMemberInt("pledgeID", tmpPledgeID);

			ParseInt(param, "TotalPledgeCrestID_"$ i, tmpPledgeCrestID);
			ArrayElem.SetMemberInt("pledgeCrestID", tmpPledgeCrestID);

			argArray_t.SetElement(i, ArrayElem);
		}

		/*ParseInt(param,"t_arrow_" $ i, t_arrow[i]);//화살표 방향
		ParseString(param,"t_name_" $ i, t_name[i]);//레전드 이름
		ParseInt(param,"t_number_" $ i, t_number[i]);//각 값들.*/
		
		args[1].SetMemberValue("resultListArray2", argArray_t);

		Invoke("_root.onEvent", args, invokeResult);

		DeallocGFxValue(argArray_m);
		DeallocGFxValue(argArray_t);
		DeallocGFxValue(ArrayElem);
		DeallocGFxValue(invokeResult);
		DeallocGFxValues(args);
	}
}

function string setTimeString(INT64 tmpTime){
	local INT64 tmpDay;
	local INT64 tmpHou;
	local INT64 tmpMin;	
	local string timeStr;
	
	
	local int minToHou;
	local int minToDay;
	
	minToHou = 60;
	minToDay = minToHou * 24;
	
	tmpMin = tmpTime/60; 
	
	if ( tmpMin > minToDay ) {//일 // 시간만		
		tmpHou = tmpMin/60;
		tmpDay = tmpHou/24;
		tmpHou = tmpHou - tmpDay*24;	
		if ( tmpHou != 0 ){
			timeStr = MakeFullSystemMsg( GetSystemMessage(3503), MakeCostString(String(tmpDay)), string (tmpHou) );
		} else {
			timeStr = MakeFullSystemMsg( GetSystemMessage(3418), MakeCostString (String(tmpDay)));
		}
	} else if ( tmpMin > 60 ) {//시간 분만
		tmpHou = tmpMin/60;
		tmpMin = tmpMin - tmpHou*60;
		if( tmpMin != 0 ){
			timeStr = MakeFullSystemMsg( GetSystemMessage(3304), string(tmpHou), string (tmpMin) );
		} else {
			timeStr = MakeFullSystemMsg( GetSystemMessage(3406), string(tmpHou) );
		}

	} else {//분만
		timeStr = MakeFullSystemMsg( GetSystemMessage(3390), string (tmpMin));
	}

	return timeStr;
}

function string valueNumToStr(INT64 tmpValue){
	local string returnStr;	
	if( tmpValue > 0 ) {
		returnStr = getValueCuttingCriteria(tmpValue, cuttingCriteria, 0);
		returnStr = ConvertNumToTextNoAdena(returnStr);
		return returnStr;
	}
	return "0";
	//Debug("returnStr"$returnStr$"입니다.");
	
}

function string getValueCuttingCriteria(INT64 tmpValue, INT64 criteria , int num){	
	if ( num > 5){
		return "0";
	}
	if ( tmpValue > criteria ) {
		//Debug ("tmpCriteria" @ criteria);
		return getValueCuttingCriteria (tmpValue,  criteria * cuttingCriteria, num + 1 );
	}else {		
		return CeilingNum (String (tmpValue), cuttingCriteriaCipher * num  );
	}	
}



/**
 * 숫자를 넣으서 true, false 를 리턴 하게 한다.
 **/
function bool bflag(int nflag)
{
	if (nflag > 0) return true;
	else return false;
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
defaultproperties
{
}
