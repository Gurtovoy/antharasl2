/**
 *   UI 데이타 관리 
 *   
 *   중국 상하이 팀에서 사용 하던 UI 공용 데이타 공간, 
 *   대부분 삭제 하고 한국에서 추가 할 필요가 있을때 추가 하길..
 *   
 **/
class UIData extends UICommonAPI;

// 해상도
var int currentScreenWidth;
var int currentScreenHeight;
//var bool isClassicServer;

var string roleTypeStr;
var string classDescription;

// 레벨업 체크를 위한 변수들
var userinfo prevUserInfo, currUserInfo;

// 한 파티창에 들어갈수 있는 최대 파티원의 수.
const               NEW_PARTY_MAXCOUNT = 7;
var int             MAXLV ;
const               MAXLV2DISPLAY = 199;


const               HUNTINGZONE_MAXCOUNT = 500;
const               RAID_MAXCOUNT = 500;

//역활 수 최대 개수
const               ROLETYPEMAX = 9;

// 소유하고 있는 아데나 수량
var Int64 adenaCount;

// pc방 포인트
var int   pcCafePoint;

// 혈맹 포인트
var int clanNameValue;

// getUCProperty 로 여러 값을 가져오기 위한 임시 값
var int tmpDataInt;
var string tmpDataString;
var bool tmpDataBoolean;

function onLoad()
{
	// 해상도 갱신
	updateCurrentResolution ();
	MAXLV = GetMaxLevel();
}

//  script 에서 인식하는 수는 int 까지 이므로, 999999999999을 쓰는 경우 int 로 변환 된다.
function int64 getMaxAdena () 
{
	return  int64("999999999999"); // 9999억 대
}

function OnRegisterEvent()
{
	RegisterEvent(EV_ResolutionChanged);
	RegisterEvent(EV_NeedResetUIData);

	RegisterEvent(EV_PCCafePointInfo);	
	RegisterEvent(EV_UpdateUserInfo);
	RegisterEvent(EV_ClanInfo);	
	RegisterEvent(EV_PreUpdateUserInfo);	
	
}

//어떤 형식이 되던 나중에 한번에 바꿀 수 있도록 
function bool getIsLiveServer()
{	
	return ( GetServerType() == 1);
}

//어떤 형식이 되던 나중에 한번에 바꿀 수 있도록 
function bool getIsClassicServer()
{	
	// isClassicServer 이 삭제 되어 GetServer 로 교체 
	return ( GetServerType() == 2);	
}

//어떤 형식이 되던 나중에 한번에 바꿀 수 있도록 
function bool getIsArenaServer()
{	
	return ( GetServerType() == 3);
}


/** onEvent */
function OnEvent(int Event_ID, string param)
{	
	// Debug("Event_ID " @ Event_ID);
	// Debug("param    " @ param);	
	
	switch( Event_ID )
	{
		case EV_ResolutionChanged :
			 updateCurrentResolution();
			 break;

		case EV_NeedResetUIData :
			 MAXLV = GetMaxLevel();
			 clanNameValue = 0;
			 pcCafePoint = 0;

			 break;

		case EV_PCCafePointInfo :
			 pcCafePointInfoHandler(param);
			 break;

		case EV_ClanInfo :
			 updateClanInfoHandler(param);
			 break;
		// PreUpdateUserInfo 로 바꿀 것.
		case EV_PreUpdateUserInfo :
			 swapPrevUserInfo() ;
		 break;

			 /*
		case EV_Test:
			isClassicServer = !isClassicServer;
			 Debug( "Debug( getIsClassicServer()) ;" @ isClassicServer ) ;
*/


	}
}

// 이전 유저 정보와 지금 유저 정보를 교체 하는 함수
function swapPrevUserInfo()
{
	prevUserInfo = currUserInfo;
	GetPlayerInfo ( currUserInfo ) ;	
}

// 변신인지 아닌지 파악하는 함수 
function bool isPawnChanged ()
{
//	Debug ( "현재 정보 " @ currUserInfo.m_bPawnChanged  @ currUserInfo.nTransformID);
	return prevUserInfo.m_bPawnChanged != currUserInfo.m_bPawnChanged ;
}

// 탈 것 
function bool isMount() 
{
	// 변신인 경우 
	if ( currUserInfo.m_bPawnChanged ) return false;
	return ( prevUserInfo.nTransformID == 0 && currUserInfo.nTransformID > 0 ) ;
}

// 내리는 경우
function bool isDismoust() 
{
	// 변신인 경우
	if ( currUserInfo.m_bPawnChanged ) return false;
	return ( prevUserInfo.nTransformID > 0 && currUserInfo.nTransformID == 0 ) ;
}

// 레벨업인지 아닌지 파악하는 함수.
function bool isLevelUP () 
{	
	return prevUserInfo.nLevel < currUserInfo.nLevel ;
}

function updateClanInfoHandler(string param)
{
	ParseInt( param, "ClanNameValue", clanNameValue );   // 혈맹포인트
}

function pcCafePointInfoHandler(string param)
{
	ParseInt( param, "TotalPoint", pcCafePoint );
}

function int getCurrentClanNameValue()
{
	return clanNameValue;
}

function int getCurrentPcCafePoint()
{
	return pcCafePoint;
}

function setPcCafePoint(int point)
{
	pcCafePoint = point;
}

function setCurrentClanNameValue(int point)
{
	clanNameValue = point;
}



/** 해상도 */
function updateCurrentResolution ()
{	
	GetCurrentResolution (currentScreenWidth, currentScreenHeight);
}

function int getScreenWidth ()
{	
	// 값이 제대로 안넣어진 상태인걸로 간주 하고 업데이트 
	if (currentScreenWidth <= 0) updateCurrentResolution ();

	return currentScreenWidth;
}

function int getScreenHeight ()
{	
	// 값이 제대로 안넣어진 상태인걸로 간주 하고 업데이트 
	if (currentScreenWidth <= 0) updateCurrentResolution ();

	return currentScreenHeight;
}

function setRoleTypeStr( int classID )
{
	roleTypeStr = GetClassRoleName(classID) ;
	//local L2Util util;
	//util = L2Util(GetScript("L2Util"));	
	//roleTypeStr = util.GetClassStr( classID );
}

function onCallUCFunction ( string id, string param)
{
	switch ( id ) 
	{
		case "setRoleTypeStr" :			
			setRoleTypeStr( int( param ) );
			break;
		case "GetClassDescription" :
			classDescription = GetClassDescription( int (param) );
			break;
		case "setUCData" :
			tmpDataString = param ;
			break;
		case "getUCData" :
			getData( param ) ;
			break;		
	}
}

function getData ( String dataName )
{	
	switch ( dataName ) 
	{
		case "GameStateName":
			tmpDataString = GetGameStateName();
		break;
		case "nNobless":
			tmpDataInt = getMyNobless() ;
		break;
		case "bHero":
			tmpDataBoolean = getbHero();
		break;
		case "roleIconName":						
			tmpDataString = GetClassRoleIconName ( int ( tmpDataString ) ) ;	
		break;
		case "arenaRoleIconName":			
			tmpDataString = GetClassArenaRoleIconName ( int (tmpDataString) ) ;
		break;
		case "ClassRoleNameByRole":
			tmpDataString = GetClassRoleNameByRole ( EClassRoleType (int(tmpDataString)) ) ;
		break;
		case "GetUserName" :
			//Debug ("GetUserName" @ tmpDataString  @  class'UIDATA_USER'.static.GetUserName( int ( tmpDataString ) ));
			tmpDataString = class'UIDATA_USER'.static.GetUserName( int ( tmpDataString ) ) ;
		break;
		case "GetPartyMemberLocationWithID":
			setGetPartyMemberLocationWithID( int(tmpDataString) ) ;
		break;
		case "GetItemNameAllBySeverID":
			tmpDataString = GetItemNameAllBySeverID(int(tmpDataString));
		break;

		case "GetItemGradeTextureName":
			tmpDataString = GetItemGradeTextureName(int(tmpDataString));
		break;

		case "GetIsFriend":
			tmpDataBoolean = isFriend( tmpDataString ) ;
		break;
		case "GetUIUserPremiumLevel" :
			tmpDataInt = GetUIUserPremiumLevel() ;
		break;
	}
}

// 친구 인지 
function bool isFriend( string Name )
{
	local PersonalConnectionsWnd personalConnectionsWndScript;
	local L2Util l2utilScript;

	personalConnectionsWndScript = PersonalConnectionsWnd(getScript("PersonalConnectionsWnd"));
	l2utilScript = L2Util( GetScript("L2Util"));	

	return  ( l2utilScript.ctrlListSearchByName(personalConnectionsWndScript.FriendList, Name) != -1 ) ;
}

// 바로 파티를 맺자 마자 정보 값을 받을 수 없다. 
function setGetPartyMemberLocationWithID( int a_PartyMemberSID )
{
	local Vector a_Location ;	
	
	if ( GetPartyMemberLocationWithID( int (tmpDataString), a_Location ) )
	{		
		tmpDataString = "";
		ParamAdd(tmpDataString, "x", String ( a_Location.X ) );
		ParamAdd(tmpDataString, "y", String ( a_Location.Y ) );
		ParamAdd(tmpDataString, "z", String ( a_Location.Z ) );
	}
}

function int getMyNobless () 
{
	local UserInfo info ;

	if ( !GetPlayerInfo(info) ) return -1 ;

	return info.nNobless ;
}

function bool getbHero () 
{
	local UserInfo info ;

	if ( !GetPlayerInfo(info) ) return false ;

	return info.bHero ;
}
defaultproperties
{
}
