//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : CharacterCreateMenuWndWnd  - SCALEFORM UI
//
//------------------------------------------------------------------------------------------------------------------------
class CharacterCreateMenuWnd extends L2UIGFxScript;

//const FLASH_WIDTH  = 800;
//const FLASH_HEIGHT = 600;

var L2Util util;
var LoginSystemMessageWnd systemMessage; // 시스템 메시지 관련 내용 L2Util에 넣으려 했으나, 로그인 쪽에만 구현되는데다, 현재로써는 케릭터 선택에만 잇고, 

const DLG_ID_CREATE = 3300;

const MAX_RACE  = 7;
var string RACE_STR[MAX_RACE];

//const MAX_JOB   = 2;

const MAX_GENDER= 2;

// default character
/* 기본 적인 종족 갯수 공식 드워프, 카마엘 예외 처리 
 * race*(job_max * gender_max) + job*gender_max + gender ; 
 */
const MAX_CHARACTER  = 24;

var bool m_bZoomed;

var int race;
var int job;
var int gender;
var int HairType;
var int HairColor;
var int FaceType;

var String Name;	

var bool IsCreate ; // 이름 중복 이벤트를 받은 뒤 생성인지, 확인인지 구분 할 때 씀.
//var array<int> RACE_START_NUM[MAX_RACE];//MAX_RACE

// 각종 type 값.... 수동으로 받고 있으나 서버에서 받을 수 있길.......
//var array<int> MAX_HAIRTYPE[MAX_CHARACTER];
//var array<int> MAX_HAIRCOLOR[MAX_CHARACTER];
//var array<int> MAX_FACETYPE[MAX_CHARACTER];

// 툴팁 
//var toolTipWnd toolTipWndGFXScript;

var int ID;

/*************************************************************************************************************
 * 데이타
 * ***********************************************************************************************************/
//머리 스타일 남자 5, 여자 7 이고 카마엘, 아르테이아 머리 색상이 3인거 빼고는 나머지는 같다.
function int getFaceTypeMaxNum () 
{
	return 3;
}

function int getHairColorMaxNum ()
{
	if ( RACE_STR[race] == "KAMAEL" || RACE_STR[race] == "ERTHEIA" 	) return 3; 
	return 4; 
}

function int getHairTypeMaxNum () 
{
	if (  gender == 1 || RACE_STR[race] == "ERTHEIA" ) return 7 ;
	return 5;
}

function setRandomTypes(int ID){
	HairType  = Rand(getHairTypeMaxNum());
	HairColor = Rand(getHairColorMaxNum());
	FaceType  = Rand(getFaceTypeMaxNum());	
	SetCharacterStyle(ID, HairType, HairColor, FaceType);
}

function InitString()
{
	// Race string
	RACE_STR[0]="HUMAN";
	RACE_STR[1]="ELF";
	RACE_STR[2]="DARKELF";
	RACE_STR[3]="ORC";
	RACE_STR[4]="DWARF";
	//신종족-solasys
	RACE_STR[5]="KAMAEL";
	RACE_STR[6]="ERTHEIA";
}

/*************************************************************************************************************
 * On ~ 
 * ***********************************************************************************************************/

function OnRegisterEvent()
{
	registerEvent(EV_CharacterCreateSetClassDesc);		
	
	RegisterEvent(EV_CharacterNameCreatable);

	RegisterEvent( EV_StateChanged );	
	RegisterEvent ( EV_DialogOK );
	RegisterEvent ( EV_DialogCancel );
}

function OnLoad()
{	
	SetContainerHUD( WINDOWTYPE_NONE, 0 );
	AddState( "CHARACTERCREATESTATE" ) ;	
	SetAlwaysOnTop(true);
	HasTextField(true);	
	InitString();
	SetAnchor( "", EAnchorPointType.ANCHORPOINT_BottomRight, EAnchorPointType.ANCHORPOINT_TopLeft, 0, 0 );	
	util = L2Util(GetScript("L2Util"));
	systemMessage = LoginSystemMessageWnd(GetScript("LoginSystemMessageWnd"));		
	//etRaceStartIndex(); //종족 시작 값 설정
	//setMaxTypes();	 //캐릭터 별 커스터마이즈 최대 값.
}

function OnHide()
{
	UnsetRotateCursor();
	callGFxFunction( "CharacterCreateMenuWnd", "EXIT", "0");
}

function OnEvent(int Event_ID, string param)
{	
	if (Event_ID == EV_StateChanged ) {
		if (param == "CHARACTERCREATESTATE")
		{
			// fade 처리를 위해 캐릭터 생성 스테이트에 들어왔을 때 race를 초기화 시켜 줌.
			race = -1;
			callGFxFunction( "CharacterCreateMenuWnd", "ENTER", "0");
			
		}
		else callGFxFunction( "CharacterCreateMenuWnd", "EXIT", "0");
	} 		
	else if ( Event_ID == EV_CharacterNameCreatable)
	{ //5618
		//이 이벤트는 GMPCManagerWnd 에서도 사용 하므로 스테이트 검사 필요 
		if ( GetGameStateName() == "CHARACTERCREATESTATE" ) 
			HandlecharacterNameCreatable(param);
	}
	else if ( Event_ID == EV_DialogOK )
	{	
		HandleDialogResult(true);
	}
	else if ( Event_ID == EV_DialogCancel )
	{
		HandleDialogResult(false);
	}
	// 3210 설명을 param 으로 받음
	/*
	else if(Event_ID == EV_CharacterCreateSetClassDesc)
	{ 
	
		//race = -1;
		//!!!!!!!!!!!!!!!!  아리트이아 종족이 우선 선택 되어 있도록 수정 2013.11.04  아중에 삭제 할 것
		//if ( getInstanceUIData().getIsClassicServer() )
		//{
		//	tmpRace = Rand( MAX_RACE - 2);
		//}
		//else
		//{
		//	tmpRace = Rand( MAX_RACE );
		//}
		//job = Rand( getMaxJob( tmpRace ));
		//gender = Rand( MAX_GENDER );
		//setStep1Handle(tmpRace, job, gender);
		
	/*}else if (Event_ID == EV_MessageWndString){ //581
		parseString(param, "Message", msg);	
		handleShowMessage(msg);*/
	//} else if (Event_ID == EV_CharacterCreateEnableRotate ){ //3260 로테이션 풀때// 필요 없음.
		//HandleEnableRotate(a_param);
		//ShowOnlyOneDefaultCharacter(5);
	//} else if ( Event_ID == EV_CharacterCreateClearSetupWnd ){ // 주어진 설정 지우기.

	} */
}

function OnCallUCFunction( string logicID, string param )
{

	local string btnName;	
	local string targetName;
	ParseString(param, "btnName", btnName);

	//Debug( "btnName" @ btnName @ "logicID"@ logicID  );

	switch (btnName){
		case "exit" :			
			RequestPrevState();
			break;
		case "confirm" :
			IsCreate = false;
			ParseString(param, "Name", Name);
			handleNameConfirm() ;				
			//RequestCharacterNameCreatable(Name); //사용중인 이름인지 확인 	 EV_CharacterNameCreatable{ //5618 발생 -> HandlecharacterNameCreatable 실행
			break;		
		case "left":
			handleTurnLeft(int(logicID));
			break;
		case "right":
			handleTurnRight(int(logicID));
			break;
		case "zoom":
			//debug("logicID:>" @ logicID);
			if(logicID == "1" ) zoomIn(); 
			else zoomOut();
			//if (!m_bZoomed) zoomIn(); else  zoomOut();
			break;
		case "race":
			setStep1Handle(int(logicID), job, gender);
			break;
		case "gender" :
			setStep1Handle(race, job, int(logicID));
			break;
		case "job" :			
			setStep1Handle(race, int(logicID), gender);
			break;
		case "faceType":
			FaceType = int(logicID);	
			handleSetCharacterStyle();
			break;
		case "hairType":
			HairType = int(logicID);	
			handleSetCharacterStyle();
			break;
		case "hairColor":
			HairColor = int(logicID);	
			handleSetCharacterStyle();
			break;
		case "create" : 
			IsCreate = true;
			ParseString(param, "Name", Name);
			handleNameConfirm()	;		
			//RequestCharacterNameCreatable(Name); //사용중인 이름인지 확인 	 EV_CharacterNameCreatable{ //5618 발생 -> HandlecharacterNameCreatable 실행 - > 111107 대석시 요청으로 handleNameConfirm 사용 
			break;
		case "class" :
			ParseString(param, "targetName", targetName);
			classDescription(int(logicID), targetName);
			break;
		case "dragPoint" :			
			handleDragCharacter(int(logicID), param);
			break;
		case "ID" : 
			ID = int(logicID);
			break;
		case "setRandom" :
			setRandom ( logicID ) ;
			break;
	}	
}

/***********************************************************************************************************
 * 케릭터 변경
 * *********************************************************************************************************/
// 입장 시 랜덤 값 설정
function setRandom( String param ) 
{
	local int nextRace, nextGender, nextJob;
//	Debug ( "setRandom" @ param ) ;
	parseInt ( param, "randRace", nextRace ) ;
	parseInt ( param, "randGender", nextGender ) ;
	parseInt ( param, "randJob", nextJob ) ;
	setStep1Handle (nextRace, nextJob, nextGender ) ;
}

function handleSetCharacterStyle()
{	
	SetCharacterStyle(ID, HairType, HairColor, FaceType);
}

function setStep2Handle()
{	
	local string result;
	result = "";
		
	handleSetCharacterStyle();	

	paramAdd(result, "faceType",String(FaceType));
	paramAdd(result, "hairType",String(HairType));
	paramAdd(result, "hairColor",String(HairColor));
	
	callGFxFunction( "CharacterCreateMenuWnd", "STEP_CHANGED_2", result);	
}


function setStep1Handle(int nextRace, int nextJob, int nextGender)//
{	
	local string result;	
	local Array<int> initialStat;       //초기 스탯 값
	local bool isRaceChange;		
	
	isRaceChange = race != nextRace;
	result = "";

//	Debug ( "setStep1Handle" @ nextRace @  nextJob @ nextGender ) ;

	ShowDefaultCharacter(ID, isRaceChange);

	if ( isRaceChange ) // 종족이 바뀜
	{
		//valRaceChange = 1;
		m_bZoomed = false; //종족이 바뀌면 줌인아웃 상태가 줌 아웃 상태로 초기화 됨
		fadeInOut( nextRace ) ;
	}	

	race    = nextRace;
	job     = nextJob;
	gender  = nextGender;

	//아르테이아는 여성 하나만 존재
	//if ( RACE_STR[race] == "ERTHEIA" )  gender  = 1;
	//else gender  = nextGender;

	/* 
	 * 초기 스탯 받기
	 */
	
	// 발터스 기사단 성장 이면 
	if ( job > 1 ) 
		initialStat = GetClassInitialStatEx ( job, race, gender );
	else if (RACE_STR[race] == "KAMAEL") //카마엘 일 경우 옵션은 젠더 임
		initialStat = GetClassInitialStat( util.getInitClassID(race, gender) );
	else 	
		initialStat = GetClassInitialStat( util.getInitClassID(race, job) );

	paramAdd(result, "STR",String(initialStat[0]) );
	paramAdd(result, "DEX",String(initialStat[1]) );
	paramAdd(result, "CON",String(initialStat[2]) );
	paramAdd(result, "INT",String(initialStat[3]) );
	paramAdd(result, "WIT",String(initialStat[4]) );
	paramAdd(result, "MEN",String(initialStat[5]) );		
	paramAdd(result, "LUC",String(initialStat[6]) );
	paramAdd(result, "CHA",String(initialStat[7]) );	
	
	paramAdd(result, "race", String(race));
	paramAdd(result, "gender",String(gender));
	paramAdd(result, "job", String(job ));
	
	paramAdd(result,  "max_faceType",  String(getFaceTypeMaxNum()));
	paramAdd(result,  "max_hairType",  String(getHairTypeMaxNum()));
	paramAdd(result,  "max_hairColor", String(getHairColorMaxNum()));	

	callGFxFunction( "CharacterCreateMenuWnd", "STEP_CHANGED_1", result);	
	// 종족, 직업, 성별이 바뀔 때 케릭터 랜덤 설정
	setRandomTypes(ID);
	// 커스터마이즈 설정
	setStep2Handle();  
}


function classDescription ( int classID , string targetName )
{
	local string result;
	result = "";
	paramAdd(result, "classID", String( classID));
	paramAdd(result, "classType", GetClassType( classID ) );
	paramAdd(result, "desc", GetClassDescription( classID ) );
	paramAdd(result, "targetName", targetName);

	callGFxFunction( "CharacterCreateMenuWnd", "NAME_CHECK_RESULT", result);
}


/***********************************************************************************************************
 * 케릭터 조작
 * *********************************************************************************************************/
// 종족 변경 시 페이드 인 아웃
function fadeInOut ( int nextRace ) 
{
	if( race == -1 ) //첫 시작은 fadein만
	{
		ExecLobbyEvent(RACE_STR[nextRace]$"_FadeIn");
	} 
	else 
	{	
		ExecLobbyEvent(RACE_STR[race]$"_FadeOut");
		ExecLobbyNextEvent(RACE_STR[race]$"_FadeOut", RACE_STR[nextRace]$"_FadeIn");
	}
}

function handleDragCharacter(int speed, string  param){
	//local int ID;
	local string type;
	local int maxSpeed;
	maxSpeed = 10000;
//	Debug(param);
	//ID = GetDefaultCharacterIndex(race, job, gender);
	parseString(param, "type", type);
	//Debug("handleDragCharacter" @speed);
	if (type == "rollOver" || type == "press" || type == "click")
	{		
		SetRotateCursor();
	} 
	else if ( type =="releaseOutside" || type == "rollOut")
	{
		UnsetRotateCursor();
	} else if(speed != 0)
	{		
		speed = speed * 400;		
		if (speed >  maxSpeed ) speed =  maxSpeed;
		else 
		if (speed < -maxSpeed ) speed = -maxSpeed;
		 DefaultCharacterMouseTurn(ID, speed);
	} 
}

function handleTurnLeft(int logicID)
{	
	if(logicID==3){
		DefaultCharacterTurn(ID, 6.0f);
	} else DefaultCharacterStop(ID);	
}

function handleTurnRight(int logicID)
{	
	if(logicID==3){
		DefaultCharacterTurn(ID, -6.0f);
	} else DefaultCharacterStop(ID);
}

function zoomIn ()
{
//	Debug("ZoomIn");
	ExecLobbyEvent( RACE_STR[race] $ "_ZoomIn");
	m_bZoomed = true;
}

function zoomOut()
{	
//	Debug("ZoomOut");
	ExecLobbyEvent( RACE_STR[race] $ "_ZoomOut");
	m_bZoomed = false;
}


/***********************************************************************************************************
 * 케릭터 생성
 * *********************************************************************************************************/
function HandleCreateCharacter(bool bOk)
{
	local int ClassID;

	if( bOk ) 
	{
		if ( job > 2 ) ClassID = job ;
		else ClassID = CharacterCreateGetClassType(race, job, gender);		
		RequestCreateCharacter(Name, race, ClassID, gender, HairType, HairColor, FaceType);
	}
}

function HandlecharacterNameCreatable (string a_param){
	local int CreateFailType;
	local array<int> systemStringArr[8];
	
	parseInt(a_param, "CreateFailType", CreateFailType );
	if( CreateFailType == -1) {
		if(IsCreate) { //생성 버튼이라면 
			ShowCreateDialog(); /// 생성 다이얼로그 뜸.
		} else { //이름 체크 라면			
			systemMessage.handleShowMessage(GetSYSTEMMessage(3539)); // 사용 가능한 이름입니다.
		}
	} else  {		
		systemStringArr[0] =  128; //캐릭터 생성에 실패했습니다.
		systemStringArr[1] =   77; //이제는 더 만들 수 없습니다. 이미 잇는 캐릭터를 지우고 다시 시도해 주십시오.
		systemStringArr[2] =   79; //이미 존재하는 이름입니다.
		systemStringArr[3] =   80; //한글 1자 이상 8자 이내, 영문 1자 이상 16자 이내로 정해주십시오.
		systemStringArr[4] =  204; //잘못된 이름입니다. 다시 입력해 주세요.
		systemStringArr[5] = 1882; //현재 이 서버에서는 캐릭터를 생성할 수 없습니다.
		systemStringArr[6] = 2037; //캐릭터를 생성할 수 없습니다. 해당 서버는 예전에 생성한........
		systemStringArr[7] = 6074; //영문을 섞을 수 없습니다......

		systemMessage.handleShowMessage(GetSYSTEMMessage( systemStringArr[CreateFailType] )); // 이 이름들은 여러가지 이유로 사용 할 수 없습니다.
	}
}


function ShowCreateDialog()
{	
	class'UICommonAPI'.static.DialogSetID( DLG_ID_CREATE );	
	class'UICommonAPI'.static.DialogShow(DialogModalType_Modal, DialogType_OKCancel, GetSystemMessage( 3533 ), string(Self) );	
}

function handleNameConfirm() 
{
	//Debug("handleNameConfirm nameConfirm" @ tmpName);
	//Debug(String(Len(tmpName)) @ !CheckNameLength(tmpName) @ !CheckValidName(tmpName));
	
	if ( Len(Name) == 0 || !CheckNameLength(Name)) //글자수 체크
	{
		//Debug("error 1");		
		systemMessage.handleShowMessage(GetSYSTEMMessage(80));
		return ;
	} 

	else if(!CheckValidName(Name)) //NPC 이름과 중복 되는 것을 확인함.
	{   //Debug("not Name");		
		//Debug("error 2");
		systemMessage.handleShowMessage(GetSYSTEMMessage(204));  //잘못된 이름입니다. 다시 입력해 주세요.
		return ;
	} 
	RequestCharacterNameCreatable(Name);//사용중인 이름인지 확인 	 EV_CharacterNameCreatable{ //5618 발생 -> HandlecharacterNameCreatable 실행	 
}

function HandleDialogResult(bool bOk)
{
	local int    DlgID;	
	if(!class'UICommonAPI'.static.DialogIsOwnedBy( string(Self) ))
		return;	
	
	DlgID = class'UICommonAPI'.static.DialogGetID();
	//Reserved = class'UICommonAPI'.static.DialogGetReservedInt();
	switch(DlgID)
	{
	case DLG_ID_CREATE :
		HandleCreateCharacter(bOk);
		break;
	}
}


/*************************************************************************************************************
 * 데이타 들 
 * ***********************************************************************************************************/
//function int getMaxJob(int tmpRace){	
//	if(RACE_STR[tmpRace] == "DWARF" || RACE_STR[tmpRace] == "KAMAEL" ){	
//		return 1 ;
//	}
//	return MAX_JOB;	
//}


//function setRandAtt() //랜덤 종족, 직업, 성별설정
//{
//	race = Rand(MAX_RACE);	
//	job = Rand(getMaxJob(race));
//	gender = Rand(MAX_GENDER);
//}

/*************************************************************************************************************
 * addParam 을 쓰기전 사용
 * ***********************************************************************************************************/
//function string setParamString(string paramName, string vars)
//{
//	local string result;
//	result = paramName $ "=" $ vars;
//	return result;
//}

//function string setParamInt(string paramName, int vars)
//{
//	local string result;
//	result = paramName $ "=" $ vars;
//	return result;
//}

/*************************************************************************************************************
 * setMaxTypes 을 위해 필요한 함수
 * ***********************************************************************************************************/
////인덱스로 종족 구하기
//function string getRaceByDefaultIdx(int tmpIdx){
//	local int i;
//	for(i = 1 ; i < MAX_RACE ; i++ ) {
//		//Debug ("getRaceByDefaultIdx" @ tmpIdx @  RACE_START_NUM[i]  @     RACE_START_NUM[5]   );
//		if (tmpIdx < RACE_START_NUM [i] ){
//			return RACE_STR[i-1];
//		}
//	}
//	return RACE_STR[MAX_RACE-1];
//}

//function setMaxTypes(){	
//	local int tmp_max_Hairtype;
//	local int tmp_max_HairColor;
//	local int tmp_max_FaceType;

//	//공식화 해 보면......머리 스타일 남자 5, 여자 7 이고 카마엘, 아르테이아 머리 색상이 3인거 빼고는 나머지는 같다.
//	local int i;
//	tmp_max_FaceType = 3;
//	for (i=0 ; i < MAX_CHARACTER ; i++ ) {	

//		if( i%2 == 0 ) tmp_max_Hairtype = 5;		
//		else tmp_max_Hairtype = 7;
		
//		if(  getRaceByDefaultIdx(i) == "KAMAEL" || getRaceByDefaultIdx( i ) == "ERTHEIA"  )
//		{
//			tmp_max_HairColor = 3;
//		}
//		else 
//		{
//			tmp_max_HairColor = 4;
//		}		
		
//		MAX_HAIRTYPE[i]  = tmp_max_Hairtype;
//		MAX_HAIRCOLOR[i] = tmp_max_HairColor;
//		MAX_FACETYPE[i]  = tmp_max_FaceType;
//	}
//}



////종족별 인덱스 시작 값 구하기. 할 때마다 구하기에는 과부하 걸릴 것 같음.
//function setRaceStartIndex(){
//	local int i;
//	RACE_START_NUM[0] = 0;
//	for( i = 1 ; i < MAX_RACE ; i++)
//	{
//		if ( RACE_STR[i] == "KAMAEL" )
//		{
//			RACE_START_NUM[i] = RACE_START_NUM[i-1] + MAX_GENDER;
//		}
//		else if  ( RACE_STR[i] == "ERTHEIA" )
//		{
//			//뉴 타입의 전은 카마엘로써, 직업이 1이다.
//			RACE_START_NUM[i] = RACE_START_NUM[i-1] + MAX_GENDER;
//		}
//		else {
//			RACE_START_NUM[i] = RACE_START_NUM[i-1] + MAX_JOB * MAX_GENDER;
//		}
//	}
//}

defaultproperties
{
}
