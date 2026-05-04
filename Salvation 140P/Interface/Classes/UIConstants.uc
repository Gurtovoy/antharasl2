/*
 * UIConstants
 *  
 *  @desc : Interface uc 코드내에서만 사용될 struct, const, enum 을 모아두는 곳.
 *
 */

class UIConstants extends UIScript;

//사용 안하는듯 해서 주석 처리
//const MAX_USER_LEVEL                   = 99;

enum CrystalType
{
//	CRT_INVALID = -1,
	CRT_NONE,
	CRT_D,
	CRT_C,
	CRT_B,
	CRT_A,
	CRT_S,
	CRT_S80,
	CRT_S84,
	CRT_R,
	CRT_R95,
	CRT_R99,
	CRT_EVENT
};

enum HuntingZoneType
{
	DOMINION,                     //0
	FIELD_HUNTING_ZONE_SOLO,      //1
	FIELD_HUNTING_ZONE_PARTY,     //2
	INSTANCE_ZONE_SOLO,           //3
	INSTANCE_ZONE_PARTY,          //4
	AGIT,                         //5
	VILLAGE,                      //6
	ETC,                          //7
	CASTLE,                       //8
	FORTRESS,                     //9
	FIELD_HUNTING_ZONE_PARTYWITH_SOLO,//10
	FIELD_HUNTING_ZONE_OUT_OF_USE,//11
	MAX
};

// 맵에서 사용할 서버 정보 타입
enum MapServerInfoType
{
	SIEGEWARFARE,               // 공성전
	SIEGEWARFARE_DIMENSION,     // 차원 공성전
	RAID_DIMENSION,             // 차원 레이드
	CURSEDWEAPON_MAGICAL,       // 마검 자리체
	CURSEDWEAPON_BLOOD,         // 혈검 자리체
	AUCTION,                    // 경매
	DEFENSEWARFARE,             // 크세르스 동맹 연합기지 방어전
	MAX
};

// 맵 서버 정보
struct MapServerInfo
{
	// 현재 사용 중인가?
	var bool bUse; 

	// 맵 왼쪽에 나타나는 버튼, 텍스쳐 정보
	var string normalTex;
	var string pushedTex;
	var string highlightTex;

	// 서버 정보 타입
	var int nServerInfoType;

	// 툴팁, 설명
	var string toolTipString;
	var string descString;

	// 필요 할때 사용
	var string szReserved;

	// 사용 중인 버튼 이름
	var string buttonName;

	// 맵포커싱 하일라이트 텍스쳐를 출력하기 위한 좌표 정보를 얻으려고..
	var int nRegionID;

	var int nData;

	// 클릭 후 이동 위치
	//var Vector clickedLoc;
	var array<Vector> clickedLocArray;
	var int clickedLocClickCount;
};

struct  RaidUIData
{
	var string		raidMonsterName;
	var string		raidDesc;

	var int			nRaidMonsterID;
	var int			nRaidMonsterLevel;
	var int			nRaidMonsterZone;
	var string		RaidMonsterZoneName;	

	var string		sortingKey;	

	var int			nMinLevel;
	var int			nMaxLevel;
	var int			id;
	var vector		nWorldLoc;	
};

// 낚시, 혈맹, 연금술등 스킬 배우기에서 사용하는 타입
struct SkillTrainInfo
{
	var string strIconName;
	var string strName;
	var string strEnchantName;

	var int id;
	var int level;
	var int sublevel;
	var int requiredLevel;
	var INT64 spConsume;
};


// - 집혼석 정보
// 해당 api를 통해서 얻음, bool GetEnsoulStoneUIInfo( ItemID Id, out string EnsoulStoneUIInfo )
struct EnsoulStoneUIInfo
{
	var int SlotType;
	var array<int> OptionId_Array;
};


// - 집혼 옵션 ID별 옵션 정보
// 해당 api를 통해서 얻음, bool GetEnsoulOptionUIInfo( int optionId, out string optionInfo )
struct EnsoulOptionUIInfo
{
	var int optionID;
	var int OptionStep;
	var int optionType;
	var string name;
	var string desc;
	var string IconTex;
	var string IconPanelTex;
	var int ExtractionItemID;  // 룬해제(집혼추출) 추출시 얻게될 아이템 ID입니다. 이 값이 0이면 추출 불가입니다.- 해외 2016-1-14추가
};


// - 집혼 수수료 정보
struct EnsoulFeeUIInfo
{
	var int    nID;
	var INT64  ItemCount;
};


// 집혼석 정보 :EnsoulStoneUIInfo 
function GetEnsoulStoneUIInfo(ItemID IdInfo, out EnsoulStoneUIInfo eStoneInfo)
{
	local string EnsoulStoneUIInfoParam;
	local int  numOfOption, optionId;
	local int i;

	// 집혼석 정보 얻기
	class'UIDATA_ENSOUL'.static.GetEnsoulStoneInfo(IdInfo, EnsoulStoneUIInfoParam); 

	parseInt(EnsoulStoneUIInfoParam, "SlotType", eStoneInfo.SlotType);
	parseInt(EnsoulStoneUIInfoParam, "NumOfOption", numOfOption);

	// Debug("EnsoulStoneUIInfoParam" @ EnsoulStoneUIInfoParam);

	for (i = 0; i < numOfOption; i++)
	{
		parseInt(EnsoulStoneUIInfoParam, "OptionId_" $ String(i), optionId);

		eStoneInfo.OptionId_Array.Length = eStoneInfo.OptionId_Array.Length + 1;
		eStoneInfo.OptionId_Array[eStoneInfo.OptionId_Array.Length - 1 ] = optionId;
	}
}

// 집혼 옵션 정보 :EnsoulOptionUIInfo
function GetEnsoulOptionUIInfo(int nEnsoulOptionID, out EnsoulOptionUIInfo eOptionInfo)
{
	local string ensoulOptioEachParam;

	if (nEnsoulOptionID > 0)
	{
		// 집혼 옵션 정보 얻기
		class'UIDATA_ENSOUL'.static.GetEnsoulOptionInfo(nEnsoulOptionID, ensoulOptioEachParam); 

		// Debug("EnsoulStoneUIInfoParam" @ ensoulOptioEachParam);

		ParseInt   (ensoulOptioEachParam, "OptionType"  , eOptionInfo.optionType);
		ParseInt   (ensoulOptioEachParam, "OptionStep"  , eOptionInfo.OptionStep);
		ParseString(ensoulOptioEachParam, "OptionName"  , eOptionInfo.name);
		ParseString(ensoulOptioEachParam, "OptionDesc"  , eOptionInfo.desc);
		ParseString(ensoulOptioEachParam, "IconTex"     , eOptionInfo.IconTex);
		ParseString(ensoulOptioEachParam, "IconPanelTex", eOptionInfo.IconPanelTex);

		// 해외 2016-1-14 추가 (룬해제)
		ParseInt(ensoulOptioEachParam, "ExtractionItemID", eOptionInfo.ExtractionItemID);

		eOptionInfo.optionID = nEnsoulOptionID;
	}
	else
	{
		Debug("Error : GetEnsoulOptionUIInfo  ->  ensoulID is wrong");
	}
}

// 집혼 가격과 필요 아이템 수 리턴
function GetEnsoulFeeUIInfo(int crystalType, bool bIsRefee, int slotType, int slotIndex, out EnsoulFeeUIInfo feeInfo)
{
	local string ensoulFeeInfoParam;

	// 0,1, 
	class'UIDATA_ENSOUL'.static.GetEnsoulFeeInfo(crystalType, bIsRefee, slotType, slotIndex, ensoulFeeInfoParam);

	ParseInt   (ensoulFeeInfoParam, "ItemID"     , feeInfo.nID);
	ParseINT64 (ensoulFeeInfoParam, "ItemCount"  , feeInfo.ItemCount);

	// Debug("EnsoulStoneUIInfoParam" @ ensoulFeeInfoParam);
}
defaultproperties
{
}
