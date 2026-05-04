class Tooltip extends UICommonAPI;

const TOOLTIP_MINIMUM_WIDTH = 154;
const TOOLTIP_MINIMUM_SETITEM_WIDTH = 200;

const TOOLTIP_SETITEM_MAX = 3;

// 툴팁간의 줄간격
const TOOLTIP_LINE_HGAP = 6;

const ATTRIBUTE_FIRE 	= 0;
const ATTRIBUTE_WATER 	= 1;
const ATTRIBUTE_WIND 	= 2;
const ATTRIBUTE_EARTH 	= 3;
const ATTRIBUTE_HOLY 	= 4;
const ATTRIBUTE_UNHOLY 	= 5;


//const MACRO_ICONANME = "L2UI.MacroWnd.MACRO_ICON";
const MACROCOMMAND_MAX_COUNT = 12;

var CustomTooltip m_Tooltip;
var DrawItemInfo m_Info;

var Array<int> AttackAttLevel;
var Array<int> AttackAttCurrValue;
var Array<int> AttackAttMaxValue; //모든 공격 속성의 레벨, 현재레벨에서의 값, 현재레벨에서의 최대값을 여기에 저장한다.

var Array<int> DefAttLevel;
var Array<int> DefAttCurrValue;
var Array<int> DefAttMaxValue; //모든 방어 속성의 레벨, 현재레벨에서의 값, 현재레벨에서의 최대값을 여기에 저장한다.

var int NowAttrLv;
var int NowMaxValue;
var int NowValue;

var bool BoolSelect;

//세트 아이템일 경우 최소 Width값 TOOLTIP_MINIMUM_SETITEM_WIDTH으로 수정.
var bool BSetItem;

//방어구 및 망토 6개 속성에 대한 툴팁 가로선 한개로 만들기 위한 변수
var bool BLine;

var TextBoxHandle ItemCountText;
var L2Util util;

function OnRegisterEvent()
{
	RegisterEvent( EV_RequestTooltipInfo );
}

function OnLoad()
{
	// 숏컷 툴팁 켜기/끄기 기본값을 켜기로(TTP#41925) 2010.8.23 - winkey
	BoolSelect = true;
	// 세트 아이템 구분.
	BSetItem = false; 

	util = L2Util(GetScript("L2Util"));
}

function OnEvent(int Event_ID, string param)
{
	switch( Event_ID )
	{
	case EV_RequestTooltipInfo:
		//debug("툴팁이벤트 넘어오냐");
		HandleRequestTooltipInfo(param);
		break;
	}
}

function setBoolSelect( bool b )
{
	BoolSelect = b;
}

function HandleRequestTooltipInfo(string param)
{
	local String TooltipType;
	local int SourceType;
	local ETooltipSourceType eSourceType;
	
	ClearTooltip();	

	if (!ParseString(param, "TooltipType", TooltipType))
		return;
		
	if (!ParseInt(param, "SourceType", SourceType))
		return;

	eSourceType = ETooltipSourceType(SourceType);

	//////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////// Normal Tooltip /////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////
	//debug("Tooltip타입:"$TooltipType);
	if (TooltipType == "Text")
	{
		ReturnTooltip_NTT_TEXT(param, eSourceType, false);
	}
	else if (TooltipType == "Description")
	{
		ReturnTooltip_NTT_TEXT(param, eSourceType, true);
	}
	//////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////// ItemWnd Tooltip ////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////
	else if (TooltipType == "Action")
	{
		ReturnTooltip_NTT_ACTION(param, eSourceType);
	}
	else if (TooltipType == "Macro")
	{
		ReturnTooltip_NTT_MACRO(param, eSourceType);
	}
	else if (TooltipType == "Skill")
	{
		ReturnTooltip_NTT_SKILL(param, eSourceType);
	}
	else if (TooltipType == "NormalItem")
	{
		ReturnTooltip_NTT_NORMALITEM(param, eSourceType);
	}
	else if (TooltipType == "PremiumNormalItem") //branch121212
	{
		ReturnTooltip_NTT_PREMIUMNORMALITEM(param, eSourceType);
	}
	else if (TooltipType == "Shortcut")
	{
		ReturnTooltip_NTT_SHORTCUT(param, eSourceType);
	}
	else if (TooltipType == "AbnormalStatus")
	{
		ReturnTooltip_NTT_ABNORMALSTATUS(param, eSourceType);
	}
	else if (TooltipType == "RecipeManufacture")
	{
		ReturnTooltip_NTT_RECIPE_MANUFACTURE(param, eSourceType);
	}
	else if (TooltipType == "Recipe")
	{
		ReturnTooltip_NTT_RECIPE(param, eSourceType, false);
	}
	else if (TooltipType == "RecipePrice")
	{
		ReturnTooltip_NTT_RECIPE(param, eSourceType, true);
	}
	else if (TooltipType == "Inventory"
			|| TooltipType == "InventoryPrice1"
			|| TooltipType == "InventoryPrice2"
			|| TooltipType == "InventoryPrice1HideEnchant"
			|| TooltipType == "InventoryPrice1HideEnchantStackable"
			|| TooltipType == "InventoryPrice2PrivateShop"
			|| TooltipType == "InventoryWithIcon"
			|| TooltipType == "InventoryPawnViewer" // PawnViewer용 추가 - lancelot 2007. 10. 16.
			|| TooltipType == "HtmlViewer" // Html 툴팁용 추가 - y2jinc 2011. 11. 16.
			|| TooltipType == "InventoryPet"// 펫 용 툴팁 추가 ( 속성 값이 보이지 않도록 처리 )			
			|| TooltipType == "EnsoulSlot" // 신규 집혼 슬롯. 툴팁을 무시 하는 속성을 추가하기 위해서.. - 조희영 때문

			)		
	{		
		ReturnTooltip_NTT_ITEM(param, TooltipType, eSourceType);
	}
	//////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////// ListCtrl Tooltip ///////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////
	//선준 수정(2010.02.22 ~ 03.08) 완료
	else if ( TooltipType == "RoomList" )
	{
		ReturnTooltip_NTT_ROOMLIST(param, eSourceType);
	}	
	else if ( TooltipType == "UserList" )
	{
		ReturnTooltip_NTT_USERLIST(param, eSourceType);
	}
	else if (TooltipType == "PartyMatch")
	{
		ReturnTooltip_NTT_PARTYMATCH(param, eSourceType);
	}
	else if (TooltipType == "UnionList")
	{
		ReturnTooltip_NTT_UNIONLIST(param, eSourceType);
	}
	else if (TooltipType == "QuestInfo")
	{
		ReturnTooltip_NTT_QUESTINFO(param, eSourceType);
	}
	else if (TooltipType == "QuestList")
	{
		ReturnTooltip_NTT_QUESTLIST(param, eSourceType);
	}
	else if (TooltipType == "RaidList")
	{
		ReturnTooltip_NTT_RAIDLIST(param, eSourceType);
	}
	else if (TooltipType == "ClanInfo")
	{
		ReturnTooltip_NTT_CLANINFO(param, eSourceType);
	}
	else if (TooltipType == "FriendInfo")
	{
		// 인맥관리 에서 friendList  BlockList 
		ReturnTooltip_NTT_FRIENDINFO(param, eSourceType);
	}
	// 10.09.20 혈맹전 리스트 툴팁 추가 by Dongland		
	else if (TooltipType == "ClanWarInfo")
	{
		ReturnTooltip_NTT_CLANWARINFO(param, eSourceType);
	}
	else if (TooltipType == "SellItemList")
	{
		// 판매 대행 
		ReturnTooltip_NTT_SellItemList(param, eSourceType);
	}
	else if (TooltipType == "EnsoulOptionType")
	{
		// 집혼 옵션 - 2015-03-02 추가
		ReturnTooltip_NTT_EnsoulOptionList(param, eSourceType);
	}
	else if (TooltipType == "AgitDecoListType")
	{
		// 아지트 데코 리스트 (2015-08-04 추가)
		ReturnTooltip_NTT_AgitDecoList(param, eSourceType);
	}
	

	//선준 수정( 10.03.30 ) 완료
	//우편함에 툴팁 추가.
	else if (TooltipType == "PostInfo")
	{
		ReturnTooltip_NTT_POSTINFO(param, eSourceType);
	}
	/////////////////////////////////////////////////////
	// MANOR
	else if (TooltipType == "ManorSeedInfo"
			|| TooltipType == "ManorCropInfo"
			|| TooltipType == "ManorSeedSetting"
			|| TooltipType == "ManorCropSetting"
			|| TooltipType == "ManorDefaultInfo"
			|| TooltipType == "ManorCropSell")
	{
		ReturnTooltip_NTT_MANOR(param, TooltipType, eSourceType);
	}
	// [퀘스트 아이템 툴팁 추가]
	else if (TooltipType == "QuestItem")
	{
		ReturnTooltip_NTT_QUESTREWARDS(param, eSourceType);
	}
	else if(TooltipType == "GFxCardItem")
	{
		ReturnTooltip_NTT_GFXCARD(param, eSourceType);
	}
	//채팅 사기방지 툴팁 추가
	else if(TooltipType == "UserFakeInfo")
	{
		ReturnTooltip_NTT_CHAT_USERFAKEINFO(param, eSourceType);
	}
	else if(TooltipType == "LookChangeItem")
	{
		//ReturnTooltip_NTT_NORMALITEM(param);
		ReturnTooltip_NTT_LOOCKCHANGEITEM(param);
	// 개인상점 수량성 개별 가격과 총가격 보여주기 2015.1.20
	}
	else if ( TooltipType == "InventoryStackableUnitPrice" )
	{
		//개인 상점 툴팁과 같게 보이도록 eSourceType을 아이템 타입으로 바꿔 보내줄 것.
		ReturnTooltip_NTT_ITEM(param, TooltipType, NTST_ITEM);
	}
	// 월드맵 툴팁
	else if ( TooltipType == "RegionInfo")
	{
		ReturnTooltip_NTT_MAP_REGIONINFO(param, eSourceType);
	}
	else if ( TooltipType == "GfxCustomTooltip" ) 
	{
		//Gfx에서 보내는 커스텀 툴팁 
		ReturnTooltip_NTT_GFxTooltip( param );		
	}
	else if ( TooltipType == "privateShopHistory" ) 
	{
		ReturnTooltip_NTT_PrivateShopHistory ( param ) ;
	}
}


/////////////////////////////////////////////////////////////////////////////////
// Gfx에서 보내는 커스텀 툴팁 
function ReturnTooltip_NTT_GFxTooltip (string param )
{
	//local string tooltipInfo ;
	local string text ;
	local int count, i, R, G, B, A, minWidth, w, h, uw, uh, offsetX, offsetY, lineBreak, oneLine ;
	local int DrawItemType ;
	//local int lineBreak, oneLine;
	
	parseInt ( param , "count", count ) ;
	parseInt ( param , "min", minWidth ) ;
	m_Tooltip.MinimumWidth = minWidth;
	
	//Debug ( param );	
	for ( i = 0 ; i < count ; i ++ ) 
	{	
		parseInt ( param , "t_" $ i, DrawItemType ) ;
		
		switch ( EDrawItemType ( DrawItemType ) ) 
		{
			case EDrawItemType.DIT_BLANK :
				parseString ( param , "txt_" $ i, text );		
				AddTooltipItemBlank( int ( text ) );
			break;
			case EDrawItemType.DIT_TEXT :
				parseString ( param , "txt_" $ i, text );
				parseInt ( param , "R_" $ i, R ) ;
				parseInt ( param , "G_" $ i, G ) ;
				parseInt ( param , "B_" $ i, B ) ;
				parseInt ( param , "A_" $ i, A ) ;
				parseInt ( param , "oX_" $ i, offsetX );
				parseInt ( param , "oY_" $ i, offsetY );
				parseInt ( param , "lb_" $ i, lineBreak ) ;
				parseInt ( param , "ol_" $ i, oneLine ) ;			
//				Debug ( lineBreak @ oneLine );
				AddTooltipColorText ( text ,  getColor(R, G, B, A), bool( lineBreak )  , bool ( oneLine)  , i == 0, "", offsetX, offsetY );
			break;
			case EDrawItemType.DIT_TEXTURE :
				parseString ( param , "textu_" $ i, text );
				parseInt ( param , "w_" $ i, w );
				parseInt ( param , "h_" $ i, h );
				parseInt ( param , "uw_" $ i, uw );
				parseInt ( param , "uh_" $ i, uh );
				parseInt ( param , "oX_" $ i, offsetX );
				parseInt ( param , "oY_" $ i, offsetY );
				parseInt ( param , "lb_" $ i, lineBreak ) ;
				parseInt ( param , "ol_" $ i, oneLine ) ;
				addTooltipTexture(text, w, h, uw, uh, bool(lineBreak), bool( oneLine), offsetX, offsetY) ;
			break;
			case EDrawItemType.DIT_SPLITLINE :
				AddCrossLine();
			break;
			case EDrawItemType.DIT_TEXTLINK :
			break;
		}
	}	

	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// 월드맵 지도 툴팁
function ReturnTooltip_NTT_MAP_REGIONINFO(string param, ETooltipSourceType eSourceType)
{
//	local ItemInfo Item;
	local L2FactionUIData factionData;
	local int nType, nHuntingZoneType;
  //	local int nType, nID, nHuntingZoneType;

	local HuntingZoneUIData huntingZoneData;
	local string tmpStr, textStr, seedMessage, addStr;
	
	local string CastleName, OwnerClanName, OwnerClanNameToolTip, NextSiegeTime, SiegeState, CastleType, TaxRate;
	local string DateTotal, AgitName, OwnerClanMasterName, LocationName;
	local string tooltipString;
	local int index;
	local int nActive, i;
	local int nFactionID, nFactionLevel;

	local RaidUIData pRaidUIData;
	local ELanguageType Language;
	
	if (eSourceType == NTST_TEXT)
	{
		ParseInt( param, "Type", nType);
		//ParseInt( param, "HuntingZoneIndex", nHuntingZoneIndex);
		ParseInt( param, "Index", index);
		ParseInt( param, "Active", nActive);
		ParseString( param, "Text", textStr);
		
		//ParseInt( param, "RegionID", mRegionID);

		m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH;
		/*if(textStr != "" && index == 0) 
		{   
			AddTooltipColorText(textStr, getInstanceL2Util().White, true, true, true);
		}
		else */

		// Debug("--> nType" @ nType);

		if (nType == EMinimapRegionType.MRT_Castle)
		{
			ParseString(param, "CastleName", CastleName);               // 성이름 

			ParseString(param, "OwnerClanNameToolTip", OwnerClanNameToolTip);  // xx 혈맹 소유 중
			ParseString(param, "OwnerClanName", OwnerClanName);         // 소유 혈맹명
			ParseString(param, "NextSiegeTime", NextSiegeTime);         // 다음 공성전 시간
			ParseString(param, "SiegeState", SiegeState);               // 평화상태, 공성중
			ParseString(param, "CastleType", CastleType);               // 없음, 빛, 어둠
			ParseString(param, "TaxRate", TaxRate);                     // 세율
			
			AddTooltipColorText(CastleName, getInstanceL2Util().White, false, false, true); // 성 이름
			//CastleType = "테스트";
			if (CastleType != "") AddTooltipColorText(" (" $ CastleType $ ")", getInstanceL2Util().ColorLightBrown, false, false, true); // 빛, 어둠

			AddCrossLine(); 
			AddTooltipColorText(GetSystemString(1607) $ " : " $ OwnerClanName, getInstanceL2Util().ColorYellow, true, true, false);  // 소유 혈맹
			AddTooltipColorText(GetSystemString(1612) $ " : " $ SiegeState, getInstanceL2Util().ColorYellow, true, true, false);     // 현황: 전쟁중, 평화
			AddTooltipColorText(GetSystemString(1608) $ " : " $ TaxRate, getInstanceL2Util().ColorYellow, true, true, false);        // 세금
			AddTooltipColorText(GetSystemString(1609) $ " : " $ NextSiegeTime, getInstanceL2Util().ColorYellow, true, true, false);  // 다음 공성일

			// 라인 텍스쳐를 최종 툴팁 가로 사이즈에 맞도록 보정
			setTooltipMinimumWidth ();
		}
		// 요새
		else if (nType == EMinimapRegionType.MRT_Fortress)
		{
			ParseString(param, "CastleName", CastleName);               // 성(요새) 이름 
			ParseString(param, "OwnerClanName", OwnerClanName);         // 소유 혈맹명
			ParseString(param, "SiegeState", SiegeState);               // 평화상태, 전쟁 중
			ParseString(param, "DateTotal", DateTotal);                 // 점령 시간
			ParseString(param, "LocationName", LocationName);           // 소속영지
				
			AddTooltipColorText(CastleName $ " | " $ MakeFullSystemMsg( GetSystemMessage(4436), LocationName), getInstanceL2Util().White, true, true, true); // 성이름
			AddCrossLine();
			AddTooltipColorText(GetSystemString(1607) $ " : " $ OwnerClanName, getInstanceL2Util().ColorYellow, true, true, false); // 소유 혈맹
			AddTooltipColorText(GetSystemString(1612) $ " : " $ SiegeState, getInstanceL2Util().ColorYellow, true, true, false);    // 현황: 전쟁중, 평화
			if (DateTotal != "") AddTooltipColorText(GetSystemString(1615) $ " : " $ DateTotal, getInstanceL2Util().ColorYellow, true, true, false); // 점령 시간
			
			// 라인 텍스쳐를 최종 툴팁 가로 사이즈에 맞도록 보정
			setTooltipMinimumWidth ();
		}
		// 아지트
		else if (nType == EMinimapRegionType.MRT_Agit)
		{  
			ParseString(param, "AgitName", AgitName);                           // 아지트 이름 
			ParseString(param, "OwnerClanName", OwnerClanName);                 // 소유 혈맹명
			ParseString(param, "OwnerClanMasterName", OwnerClanMasterName);     // 소유주
			ParseString(param, "NextSiegeTime", NextSiegeTime);                 // 다음 아지트 전
			ParseString(param, "LocationName", LocationName);           // 소속영지

			AddTooltipColorText(AgitName $ " | " $ MakeFullSystemMsg( GetSystemMessage(4436), LocationName), getInstanceL2Util().White, true, true, true); // 성이름
			AddCrossLine();

			// 점령 혈맹			
			if (OwnerClanName == "") OwnerClanName = GetSystemString(27);
			AddTooltipColorText(GetSystemString(1607) $ " : " $ OwnerClanName, getInstanceL2Util().ColorYellow, true, true, false); 

			// 혈맹주 342
			if (OwnerClanMasterName != "") AddTooltipColorText(GetSystemString(342) $ " : " $ OwnerClanMasterName, getInstanceL2Util().ColorYellow, true, true, false); 

			//OwnerClanMasterName

			if (NextSiegeTime != "") 
			{
				// 다음 아지트전 정보
				AddTooltipColorText(GetSystemString(3545)$ " : " $ NextSiegeTime, getInstanceL2Util().ColorYellow, true, true, false); 
			}

			// 라인 텍스쳐를 최종 툴팁 가로 사이즈에 맞도록 보정
			setTooltipMinimumWidth ();
		}
		// 사냥터 
		else if (nType == EMinimapRegionType.MRT_HuntingZone_Base || nType == EMinimapRegionType.MRT_HuntingZone_Mission)
		{
			ParseString( param, "SeedMessage", seedMessage);

			// 사냥터 정보를 가져온다.
			class'UIDATA_HUNTINGZONE'.static.GetHuntingZoneData(index, huntingZoneData);
			
			tmpStr = class'UIDATA_HUNTINGZONE'.static.GetHuntingZoneName(huntingZoneData.nSearchZoneID);

			AddTooltipColorText(huntingZoneData.strName $ " | " $ tmpStr, getInstanceL2Util().White, true, true, true);

			AddCrossLine();

			// 진멸의 씨앗 상태
			if(seedMessage != "") 
				AddTooltipColorText(seedMessage, getColor(255,204,0,255), true, true, false);

			//Debug("huntingZoneData.nMinLevel:" @ huntingZoneData.nMinLevel);
			//Debug("huntingZoneData.nMaxLevel:" @ huntingZoneData.nMaxLevel);
			// 추천레벨 : xx~xx
			if (huntingZoneData.nMinLevel != 0 && huntingZoneData.nMaxLevel != 0)
				AddTooltipColorText(GetSystemString(922) $ " : "$ huntingZoneData.nMinLevel $ "~" $ huntingZoneData.nMaxLevel, getColor(255,204,0,255), true, true, false);

			nHuntingZoneType = huntingZoneData.nType;
			//nHuntingZoneType = class'UIDATA_HUNTINGZONE'.static.GetHuntingZoneType(index);

			// 사냥터 유형
			tmpStr = getHuntingZoneTypeString(nHuntingZoneType); 
			if (tmpStr != "") AddTooltipColorText(tmpStr, getColor(255,204,0,255), true, true, false);
		
			// 라인 텍스쳐를 최종 툴팁 가로 사이즈에 맞도록 보정
			setTooltipMinimumWidth ();
		}
		//// 사냥터 깃발 (추천 사냥터라고만 찍음)
		//else if (nType == EMinimapRegionType.MRT_HuntingZone_Mission)
		//{
		//	// 추천 사냥터
		//	m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH / 4;
		//	AddTooltipColorText(GetSystemString(3544), getInstanceL2Util().White, true, true, true);
		//}
		// 세력 아이콘
		else if (nType == EMinimapRegionType.MRT_Faction)
		{
			ParseInt( param, "nFactionID", nFactionID);
			ParseInt( param, "nFactionLevel", nFactionLevel);
			
			GetFactionData(nFactionID, factionData);

			AddTooltipColorText(factionData.strFactionName, getInstanceL2Util().White, true, true, true);

			AddCrossLine();

			Language = GetLanguage();
			if(Language == LANG_Russia || Language == LANG_Euro || Language == LANG_English)
				AddTooltipColorText(GetSystemString(3521) $ " : "$ GetSystemString(1328) $ " " $ nFactionLevel,getColor(255,204,0,255),true,true,false);
			else
				AddTooltipColorText(GetSystemString(3521) $ " : "$ nFactionLevel $ GetSystemString(1328), getColor(255,204,0,255), true, true, false);

			if (factionData.arrFactionAreaName.Length > 0)
			{
				AddTooltipColorText(GetSystemString(3449) $ " : ", getColor(255,204,0,255), true, true, false);

				for (i = 0; i < factionData.arrFactionAreaName.Length; i++)
				{
					//Debug("factionData.arrFactionAreaName[i]" @ factionData.arrFactionAreaName[i]);
					AddTooltipColorText(factionData.arrFactionAreaName[i], getColor(255,204,0,255), false, true, false);

					if (i < factionData.arrFactionAreaName.Length - 1) AddTooltipColorText(", ", getColor(255,204,0,255), false, true, false);
				}
			}
		}

		// 레이드 
		else if (nType == EMinimapRegionType.MRT_Raid)
		{
			//pRaidUIData = getInstanceUIData().getRaidUIDataByIndex(index);
			pRaidUIData = getRaidDataByIndex(index);

			AddTooltipColorText(pRaidUIData.raidMonsterName $ " | " $ pRaidUIData.RaidMonsterZoneName, getInstanceL2Util().White, true, true, true);
			AddCrossLine();

			// xx 레벨 레이드 몬스터 
			Language = GetLanguage();
			if(Language == LANG_Russia || Language == LANG_Euro || Language == LANG_English)
				AddTooltipColorText(MakeFullSystemMsg(GetSystemMessage(4425),GetSystemString(537) $ " " $ pRaidUIData.nRaidMonsterLevel),getColor(255,204,0,255),true,true,false);
			else
				AddTooltipColorText(MakeFullSystemMsg(GetSystemMessage(4425), pRaidUIData.nRaidMonsterLevel $ GetSystemString(537)), getColor(255,204,0,255), true, true, false);
			// 리젠 상태)
			if (nActive > 0)
			{
				tmpStr = GetSystemString(3525);
			}
			else
			{
				tmpStr = GetSystemString(3526);
			}
			
			// 현재 상태 : 리젠 or 대기중 
			AddTooltipColorText(GetSystemString(3524) $ " : " $ tmpStr, getColor(255,204,0,255), true, true, false);
		
			// 라인 텍스쳐를 최종 툴팁 가로 사이즈에 맞도록 보정
			setTooltipMinimumWidth ();
		}

		// 인스턴스 존 
		else if (nType == EMinimapRegionType.MRT_InstantZone)
		{
			ParseInt( param, "Active", nActive);

			// 사냥터 정보를 가져온다.
			class'UIDATA_HUNTINGZONE'.static.GetHuntingZoneData(index, huntingZoneData);

			tmpStr = class'UIDATA_HUNTINGZONE'.static.GetHuntingZoneName(huntingZoneData.nSearchZoneID);
			
			AddTooltipColorText(huntingZoneData.strName $ " | " $ tmpStr, getInstanceL2Util().White, true, true, true);
			//AddTooltipColorText(huntingZoneData.strName $ addStr $ " | " $ tmpStr, getInstanceL2Util().White, true, true, true);

			AddCrossLine();

			// 사냥터 유형			
			nHuntingZoneType = huntingZoneData.nType;
			//nHuntingZoneType = class'UIDATA_HUNTINGZONE'.static.GetHuntingZoneType(index);

			tmpStr = getHuntingZoneTypeString(nHuntingZoneType); 
			if (tmpStr != "") AddTooltipColorText(tmpStr, getColor(255,204,0,255), true, true, false);

			// 추천레벨 : xx~xx
			if (huntingZoneData.nMinLevel != 0 && huntingZoneData.nMaxLevel != 0)
				AddTooltipColorText(GetSystemString(922) $ " : "$ huntingZoneData.nMinLevel $ "~" $ huntingZoneData.nMaxLevel, getColor(255,204,0,255), true, true, false);

			// 공략 목표
			AddTooltipColorText(GetSystemString(3522) $ " : " $ class'UIDATA_HUNTINGZONE'.static.GetHuntingDescription(index), getColor(255,204,0,255), true, true, false);
			
			// 관련 퀘스트
			if (huntingZoneData.arrQuestIDs.Length > 0)
			{
				AddTooltipColorText(GetSystemString(3523) $ " : ", getColor(255,204,0,255), true, true, false);

				for (i = 0; i < huntingZoneData.arrQuestIDs.Length; i++)
				{
					addStr = class'UIDATA_QUEST'.static.GetQuestName( huntingZoneData.arrQuestIDs[i] );
					AddTooltipColorText(addStr, getColor(255,204,0,255), false, true, false);

					if (i < huntingZoneData.arrQuestIDs.Length - 1) AddTooltipColorText(", ", getColor(255,204,0,255), false, true, false);
				}
			}

			// 이용 불가
			if(nActive <= 0) 
			{
				// 현재 현황 : 이용 불가 
				AddTooltipColorText(GetSystemString(3524) $ " : " $GetSystemString(5099) , getColor(255,204,0,255), true, true, false);
			}

			// 라인 텍스쳐를 최종 툴팁 가로 사이즈에 맞도록 보정
			setTooltipMinimumWidth ();		
		}
		else if (nType == EMinimapRegionType.MRT_Etc) 
		{
			m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH / 4;
			parseString ( param , "tooltipString", tooltipString );

			if (tooltipString != "") AddTooltipText( tooltipString, false, true, true ) ;
		}
		
		//struct native constructive HuntingZoneUIData
		//{
		//	var string		strName;
		//	var int			nType;
		//	var int			nMinLevel;
		//	var int			nMaxLevel;
		//	var vector		nWorldLoc;
		//	var	int			nSearchZoneID;
		//	var int			nRegionID;
		//	var int			nNpcID;
		//	var array<int>	arrQuestIDs;
		//	var int			nInstantZoneID;
		//};
		//Debug("맵 툴팁" @ param);

		////설명
		//if (Len(Item.Description)>0)
		//{
		//	StartItem();
		//	m_Info.eType = DIT_TEXT;
		//	m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
		//	m_Info.bLineBreak = true;
		//	m_Info.t_color.R = 178;
		//	m_Info.t_color.G = 190;
		//	m_Info.t_color.B = 207;
		//	m_Info.t_color.A = 255;
		//	m_Info.t_strText = Item.Description;
		//	EndItem();	
		//}
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// TEXT
function ReturnTooltip_NTT_TEXT(string param, ETooltipSourceType eSourceType, bool bDesc)
{
	local string strText;
	local int ID;
	
	if (eSourceType == NTST_TEXT)
	{
		if (ParseString( param, "Text", strText))
		{
			if (Len(strText)>0)
			{
				if (bDesc)
				{
					m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH;
					
					StartItem();
					m_Info.eType = DIT_TEXT;
					m_Info.t_color.R = 178;
					m_Info.t_color.G = 190;
					m_Info.t_color.B = 207;
					m_Info.t_color.A = 255;
					m_Info.t_strText = strText;
					EndItem();
				}
				else
				{
					StartItem();
					m_Info.eType = DIT_TEXT;
					m_Info.t_bDrawOneLine = true;
					m_Info.t_strText = strText;
					EndItem();	
				}
			}
		}
		else if (ParseInt( param, "ID", ID))
		{
			if (ID>0)
			{
				StartItem();
				m_Info.eType = DIT_TEXT;
				m_Info.t_bDrawOneLine = true;
				m_Info.t_ID = ID;
				EndItem();
			}
		}
	}
	else
	{
		return;
	}

	ReturnTooltipInfo(m_Tooltip);
}

function bool addItemIcon(ItemInfo Item, string ForeTexture) //, optional int nOffSetX, optional int nOffSetX )
{
	// 아이콘 이미지
	// ParseString(param, "iconPanel", iconPanel);

	if (Item.IconName == "") return false;

	// 뒷 아이콘 배경
	StartItem();
	m_Info.eType = DIT_TEXTURE;
	m_Info.u_nTextureWidth   = 34;
	m_Info.u_nTextureHeight  = 34;
	m_Info.u_nTextureUWidth  = 34;
	m_Info.u_nTextureUHeight = 34;
	
	//m_Info.u_strTexture = "L2UI_CT1_CN.tooltip_itemframe";
	m_Info.u_strTexture = "l2ui_ct1.ItemWindow_DF_SlotBox_Default";
	EndItem();

	StartItem();
	m_Info.eType = DIT_TEXTURE;
	m_Info.u_nTextureWidth   = 32;
	m_Info.u_nTextureHeight  = 32;
	m_Info.u_nTextureUWidth  = 32;
	m_Info.u_nTextureUHeight = 32;
	m_Info.nOffSetX          = -33;
	m_Info.nOffSetY          = 1;
	
	m_Info.u_strTexture = Item.IconName;
	EndItem();

	// 아이콘 패널 (기본 병기등 상단 패널)
	StartItem();
	m_Info.eType = DIT_TEXTURE;
	m_Info.u_nTextureWidth   = 32;
	m_Info.u_nTextureHeight  = 32;
	m_Info.u_nTextureUWidth  = 32;
	m_Info.u_nTextureUHeight = 32;
	m_Info.nOffSetX          = -32;
	m_Info.nOffSetY          = 1;
	//if (iconPanel == "") m_Info.u_strTexture = "l2ui_ct1.ItemWindow_DF_SlotBox_Default";
	m_Info.u_strTexture = Item.iconPanel;
	EndItem();

	// 장착 중인 아이템 패널 같은 최상위 패널
	if (ForeTexture != "")
	{
		StartItem();
		m_Info.eType = DIT_TEXTURE;
		m_Info.u_nTextureWidth   = 32;
		m_Info.u_nTextureHeight  = 32;
		m_Info.u_nTextureUWidth  = 32;
		m_Info.u_nTextureUHeight = 32;
		m_Info.nOffSetX          = -32;
		m_Info.nOffSetY          = 1;
		//if (iconPanel == "") m_Info.u_strTexture = "l2ui_ct1.ItemWindow_DF_SlotBox_Default";
		m_Info.u_strTexture = ForeTexture;
		EndItem();
	}
	
	if ( Item.bSecurityLock ) 
	{
		// 아이템 lock 상태 체크
		StartItem();
		m_Info.eType = DIT_TEXTURE;
		m_Info.u_nTextureWidth   = 32;
		m_Info.u_nTextureHeight  = 32;
		m_Info.u_nTextureUWidth  = 32;
		m_Info.u_nTextureUHeight = 32;
		m_Info.nOffSetX          = -32;
		m_Info.nOffSetY          = 1;
		//if (iconPanel == "") m_Info.u_strTexture = "l2ui_ct1.ItemWindow_DF_SlotBox_Default";
		m_Info.u_strTexture = "Icon.Icon_panel.ItemLock_Panel";
		EndItem();
		
	}

	return true;
}

function addItemIconSmallType(ItemInfo Item, string ForeTexture) //, optional int nOffSetX, optional int nOffSetX )
{
	StartItem();
	m_Info.eType = DIT_TEXTURE;
	m_Info.u_nTextureWidth   = 16;
	m_Info.u_nTextureHeight  = 16;
	m_Info.u_nTextureUWidth  = 32;
	m_Info.u_nTextureUHeight = 32;
	m_Info.nOffSetX          = 4;
	m_Info.nOffSetY          = 2;
	
	m_Info.u_strTexture = Item.IconName;
	EndItem();

	// 아이콘 패널 (기본 병기등 상단 패널)
	StartItem();
	m_Info.eType = DIT_TEXTURE;
	m_Info.u_nTextureWidth   = 16;
	m_Info.u_nTextureHeight  = 16;
	m_Info.u_nTextureUWidth  = 32;
	m_Info.u_nTextureUHeight = 32;
	m_Info.nOffSetX          = -16;
	m_Info.nOffSetY          = 2;
	//if (iconPanel == "") m_Info.u_strTexture = "l2ui_ct1.ItemWindow_DF_SlotBox_Default";
	m_Info.u_strTexture = Item.iconPanel;
	EndItem();

	// 장착 중인 아이템 패널 같은 최상위 패널
	if (ForeTexture != "")
	{
		StartItem();
		m_Info.eType = DIT_TEXTURE;
		m_Info.u_nTextureWidth   = 14;
		m_Info.u_nTextureHeight  = 14;
		m_Info.u_nTextureUWidth  = 32;
		m_Info.u_nTextureUHeight = 32;
		m_Info.nOffSetX          = -20;
		m_Info.nOffSetY          = 2;
		//if (iconPanel == "") m_Info.u_strTexture = "l2ui_ct1.ItemWindow_DF_SlotBox_Default";
		m_Info.u_strTexture = ForeTexture;
		EndItem();
	}
}

function addTexture(string IconName, int u_nTextureWidth, int u_nTextureHeight, int u_nTextureUWidth, int u_nTextureUHeight, optional int nOffSetX, optional int nOffSetY )
{
	StartItem();
	m_Info.eType = DIT_TEXTURE;
	m_Info.u_nTextureWidth   = u_nTextureWidth;
	m_Info.u_nTextureHeight  = u_nTextureHeight;
	m_Info.u_nTextureUWidth  = u_nTextureUWidth;
	m_Info.u_nTextureUHeight = u_nTextureUHeight;
	m_Info.nOffSetX          = nOffSetX;
	m_Info.nOffSetY          = nOffSetY;
	
	m_Info.u_strTexture = IconName;
	EndItem();
}

// 창 / 양손, 갑옷 같은 장비 아이템의 타입을 리턴한다.
function string getSlotTypeWithItemTypeString(ItemInfo Item)
{
	local string SlotString, strTmp;
	local EItemType eItemType;

	eItemType = EItemType(Item.ItemType);
	SlotString = GetSlotTypeString(Item.ItemType, Item.SlotBitType, Item.ArmorType);

	if (eItemType == ITEM_WEAPON)
	{
		strTmp = GetWeaponTypeString(Item.WeaponType);
		if (Len(strTmp)>0)
		{
			SlotString = strTmp $ " / " $ SlotString;
		}
	}

	return SlotString;
}

/////////////////////////////////////////////////////////////////////////////////
// INVENTORY Etc
function ReturnTooltip_NTT_ITEM(string param, String TooltipType, ETooltipSourceType eSourceType)
{
	local ItemInfo Item;
	
	local EItemType eItemType;
	local EEtcItemType eEtcItemType;
	
	local string SlotString;
//	local string strTmp;
	local int    nTmp;


	local string ItemName;
	local int ItemNameClass;
	
	//아데나읽어주기
	local string strAdena;
	local string strAdenaComma;
	local color	 AdenaColor;	
	
	//인첸트용.
	local ItemEnchantBonusValue rValue; 
	
	// [EP3019]
	// 무기 인챈트 개선 작업
	local bool  bMagicWeapon;
	local float fSoulShotPower, fSpiritShotPower;

	// 무기 추가 대미지
	local int   nEnchantedPhysicalDamageBonus, nEnchantedMagicalDamageBonus;

	// 방어구 추가 방어, 마법방어(저항)
	local int   nEnchantedMagicalDefenseBonus, nEnchantedPhysicalDefenseBonus, nEnchantedShieldDefenseBonus;

	// 인벤토리 뷰어 장착 된 아이템 패널 표시
	local string ForeTexture;

	//  아이템 슬롯, 아이템 타입
	local string ItemSlotWithItemTypeStr;

	// 아이템 비교
	local int IsCompareItem, IsComparingEquip;

	local int nEnchantValueTextGap, nSimpleLineCountAdd;

	local int bMainIconGap;
	
	if (eSourceType == NTST_ITEM)
	{
		//Debug("param" @ param);
		ParamToItemInfo(param, Item);	

		parseInt ( param, "IsCompareItem", IsCompareItem); 		
		parseInt ( param, "IsComparingEquip", IsComparingEquip); 		
		
		//Debug("IsCompareItem : " @ IsCompareItem);
		//Debug("IsComparingEquip : " @ IsComparingEquip);

		//if (IsCompareItem == 1) Debug("비교 아이템이다 " @ Item.Name) ;
		//if (IsComparingEquip == 1) Debug("장착한 아이템이다 " @ Item.Name) ;
		//if (IsComparingEquip == 1 && IsCompareItem == 1) Debug("==== 장착한 비교 아이템이다 " @ Item.Name) ;

		// 집혼 슬롯 옵션으로 더미 아이템을 넣을때, 툴팁이 안나오도록 하기 위해서.. EnsoulWnd에서 사용.
		if (TooltipType == "EnsoulSlot") 
		{
			if (Item.Id.ClassID <= 0) return;
		}
		
		GetItemBonusEnchantValue( item.ID.ClassID, item.CrystalType, item.Enchanted, Item.Attribution, rValue );

		eItemType = EItemType(Item.ItemType);
		eEtcItemType = EEtcItemType(Item.ItemSubType);
		
		// 인챈트에 따른 방패, 물리, 마법방어(저항), 보너스 수치 
		nEnchantedShieldDefenseBonus   = GetEnchantedShieldDefenseBonus  (Item.CrystalType, Item.Enchanted, Item.Attribution);		
		nEnchantedMagicalDefenseBonus  = GetEnchantedMagicalDefenseBonus (Item.CrystalType, Item.Enchanted, Item.Attribution);
		nEnchantedPhysicalDefenseBonus = GetEnchantedPhysicalDefenseBonus(Item.CrystalType, Item.Enchanted, Item.Attribution);

		// 인챈트된 물리 공격력 추가 수치
		nEnchantedPhysicalDamageBonus   = GetEnchantedPhysicalDamageBonus(Item.WeaponType, Item.SlotBitType, Item.CrystalType, Item.Enchanted, Item.Attribution);

		// 인챈트된 물리 공격력 추가 수치
		nEnchantedMagicalDamageBonus    = GetEnchantedMagicalDamageBonus(Item.WeaponType, Item.SlotBitType, Item.CrystalType, Item.Enchanted, Item.Attribution);
		
		//아이템 이름 취득
		ItemName = class'UIDATA_ITEM'.static.GetRefineryItemName( Item.Name, Item.RefineryOp1, Item.RefineryOp2 );
		ItemNameClass = class'UIDATA_ITEM'.static.GetItemNameClass( Item.ID );
		
		// 인벤토리 뷰어의 "[장착중]" 표시	
		// ParamToItemInfo 으로는 해당 param 을 따지 않는다.
		parseString ( param, "ForeTexture", ForeTexture ) ;
		if ( ForeTexture == "L2UI_CT1.Icon.WearPanel" || IsCompareItem == 1) 
		{
			if (IsComparingEquip == 1 || ForeTexture == "L2UI_CT1.Icon.WearPanel")
			{	
				// 장착 아이템
				AddTooltipColorText("[" $ GetSystemString(3556) $ "]", getColor(255,204,0,255),true, true, true);
				nSimpleLineCountAdd = 2;
				AddTooltipItemBlank(0);
				AddCrossLine();
			}
			else
			{
				// 선택 아이템
				AddTooltipColorText("[" $ GetSystemString(3555) $ "]", getColor(153,153,153,255), true, true, true);				
				nSimpleLineCountAdd = 2;
				AddTooltipItemBlank(0);
				AddCrossLine();
			}
		}

		// 아이템 아이콘을 찍는다.
		if(addItemIcon(Item, ForeTexture))
		{
			bMainIconGap = 3;
		}

		// 해외용? "P" 프리미엄 아이템 아이콘
		AddPrimeItemSymbol(Item, true);

		//인첸트 표시 ex) "+10"		
		if (TooltipType != "InventoryPrice1HideEnchant" && TooltipType != "InventoryPrice1HideEnchantStackable") 
		{
			AddTooltipItemEnchant(Item, true, "chatFontSize11", 6, 1);	
			nEnchantValueTextGap = 3;
		}
		
		//아이템 이름
		AddTooltipItemName(ItemName, Item, ItemNameClass, "chatFontSize11", bMainIconGap + nEnchantValueTextGap, 1);

		//아이템 갯수
		if (TooltipType != "InventoryPrice1HideEnchantStackable")
		{
			// 퀘스트 보상 아이템 타입이면 아이템 개수를 표기 하지 않는다.
			if (TooltipType != "QuestReward") if( Item.ItemNum > 0 ) AddTooltipItemCount(Item, 0, 1);
		}

		//Grade Mark
		AddTooltipItemGrade(Item, 0, 1);

		// 아이템 타입 , ex) 창 / 양손
		ItemSlotWithItemTypeStr = getSlotTypeWithItemTypeString(Item);
		if(ItemSlotWithItemTypeStr != "")
		{
			// SimpleLineCount 은 인벤토리 등에 간략화 툴팁, 보여 줄 라인수
			m_Tooltip.SimpleLineCount = 2 + nSimpleLineCountAdd;
			AddTooltipItemBlank(1);
			AddTooltipColorText(ItemSlotWithItemTypeStr, getColor(176,155,121,255), false, true, false, "", 38, -19);
		}

		//Debug("nSimpleLineCountAdd" @ nSimpleLineCountAdd);
		//Debug("m_Tooltip.SimpleLineCount" @ m_Tooltip.SimpleLineCount);

		//아이템이 아데나면, 읽어주기 스트링 (4만 4000아데나 같이 읽어주는 문자열로)
		if (IsAdena(Item.ID) && Item.ItemNum > 0)
		{
			//SimpleTooltip을 읽어주기스트링까지 보여준다.
			m_Tooltip.SimpleLineCount = 3 + nSimpleLineCountAdd;
			AddTooltipText("(" $ ConvertNumToText(String(Item.ItemNum)) $ ")", true, true);
		}
		
		// 개인상점 등에서 개별 아이템의 가격과 총 가격을 보여줄때 사용
		if (TooltipType == "InventoryStackableUnitPrice" && !Item.bEquipped )
		{
			// Debug ( " 개인 상점 InventoryStackableUnitPrice" ) ;
			strAdena = String(Item.Price);
			strAdenaComma = MakeCostString(strAdena);
			AdenaColor = GetNumericColor(strAdenaComma);
			
			// 수량성 아이템이고, 아이템이 1보다 크다면 개당 가격으로 표시
			if (IsStackableItem(Item.ConsumeType) && Item.ItemNum > 1)
			{
				//1개당 x 아데나 : xxx,xxx,xxx
				// AddTooltipItemOption2(2511, 468, true, true, false);
				AddTooltipItemBlank(TOOLTIP_LINE_HGAP);
				AddTooltipColorText(GetSystemString(2511) $ " : ", getColor(255,180,0,255), true, true, false);
				AddTooltipColorText(strAdenaComma $ " " $ GetSystemString(469), AdenaColor, false, true, ,"", 0, 0);
				//SetTooltipItemColor(AdenaColor.R, AdenaColor.G, AdenaColor.B, 0);
				////"아데나"
				//AddTooltipColorText(GetSystemString(469), AdenaColor, false, true, false, "", 0, 0);
			}
			else
			{
				//가격 : xxx,xxx,xxx
				AddTooltipItemOption(322, strAdenaComma $ " " $ GetSystemString(469), true, true, false,,,,,AdenaColor);
			}
			
			// 총 판매가격 
			if (IsStackableItem(Item.ConsumeType) && Item.ItemNum > 1)
			{
				strAdena = string(Item.Price * Item.ItemNum);
				strAdenaComma = MakeCostString(strAdena);
				AdenaColor = GetNumericColor(strAdenaComma);

				AddTooltipItemOption(2595, strAdenaComma $ " " $ GetSystemString(469), true, true, false,,,,,AdenaColor);

				//SetTooltipItemColor(AdenaColor.R, AdenaColor.G, AdenaColor.B, 0);
				//"아데나"
				//AddTooltipColorText(GetSystemString(469), AdenaColor, false, true);
			}

			//SimpleTooltip을 가격까지 보여준다.
			//m_Tooltip.SimpleLineCount++
			
			//읽어주기 스트링
			if (Item.Price>0)
			{
				// m_Tooltip.SimpleLineCount = 3;
				AddTooltipItemOption(0, "(" $ ConvertNumToText(strAdena) $ ")", false, true, false);
				SetTooltipItemColor(AdenaColor.R, AdenaColor.G, AdenaColor.B, 0);
			}
		}	
		
		//InventoryPrice1 타입
		if ((TooltipType == "InventoryPrice1" || TooltipType == "InventoryPrice1HideEnchant" || TooltipType == "InventoryPrice1HideEnchantStackable") && !Item.bEquipped)
		{
			strAdena = String(Item.Price);
			strAdenaComma = MakeCostString(strAdena);
			AdenaColor = GetNumericColor(strAdenaComma);
			
			//가격 : xxx,xxx,xxx
			AddTooltipItemOption(322, strAdenaComma $ " " $ GetSystemString(469), true, true, false);
			//SetTooltipItemColor(AdenaColor.R, AdenaColor.G, AdenaColor.B, 0);
			
			//"아데나"
			//AddTooltipColorText(GetSystemString(469), AdenaColor, false, true);

			//SimpleTooltip을 가격까지 보여준다.
			m_Tooltip.SimpleLineCount = 3 + nSimpleLineCountAdd;
			
			//읽어주기 스트링
			if (Item.Price>0)
			{
				m_Tooltip.SimpleLineCount = 4 + nSimpleLineCountAdd;
				AddTooltipItemOption(0, "(" $ ConvertNumToText(strAdena) $ ")", false, true, false);
				SetTooltipItemColor(AdenaColor.R, AdenaColor.G, AdenaColor.B, 0);
			}
		}
		

		//InventoryPrice2 타입, 개인상점 구매등
		if (TooltipType == "InventoryPrice2"
			|| TooltipType == "InventoryPrice2PrivateShop")
		{
			strAdena = String(Item.Price);
			strAdenaComma = MakeCostString(strAdena);
			AdenaColor = GetNumericColor(strAdenaComma);
			
			//가격 : 1개당
			AddTooltipItemOption2(322, 468, true, true, false);
			SetTooltipItemColor(AdenaColor.R, AdenaColor.G, AdenaColor.B, 0);
			
			//"아데나"
			//"xxx,xxx,xxx "
			AddTooltipColorText(" " $ strAdenaComma $ " " $ GetSystemString(469), AdenaColor, false, true,,,,TOOLTIP_LINE_HGAP);
			
			//SimpleTooltip을 가격까지 보여준다.
			m_Tooltip.SimpleLineCount = 3 + nSimpleLineCountAdd;
			
			//읽어주기 스트링
			if (Item.Price>0)
			{
				m_Tooltip.SimpleLineCount = 4 + nSimpleLineCountAdd;
				//"("
				AddTooltipColorText("(", AdenaColor, true, true);
				//"1개당"
				AddTooltipColorText(GetSystemString(468), AdenaColor, false, true);
				//")"
				AddTooltipColorText(" " $ ConvertNumToText(strAdena) $ ")", AdenaColor, false, true);
			}
		}
		
		//InventoryPrice2PrivateShop 타입
		if (TooltipType == "InventoryPrice2PrivateShop")
		{
			if (IsStackableItem(Item.ConsumeType) && Item.Reserved64 > 0)
			{
				//"구매개수 : xx"
				AddTooltipItemOption(808, String(Item.Reserved64), true, true, false);
			}
		}


		// 아이템 봉인 상태 
		if ( item.bSecurityLock )
		{
			AddTooltipColorText(GetSystemString(3775),  getInstanceL2Util().HotPink, true, true,,"chatFontSize12",,TOOLTIP_LINE_HGAP);
		}

		/////////////////////////////////////////////////////////////////////////////////////////
		// 아이템에 따른 각종 정보
		SlotString = ""; //branch 111109
		SlotString = GetSlotTypeString(Item.ItemType, Item.SlotBitType, Item.ArmorType);
		//Debug(">>>>" $ string(eItemType) $ "::" $ ItemName @ SlotString);
		switch (eItemType)
		{
		// 1. WEAPON
		case ITEM_WEAPON:
			//Slot Type
			//strTmp = GetWeaponTypeString(Item.WeaponType);
			//if (Len(strTmp)>0)
			//{
			//	AddTooltipItemOption(0, strTmp $ " / " $ SlotString, false, true, false);
			//}
			
			//빈공간
			//AddTooltipItemBlank(6);
			
			//"[무기 제원]"
			//AddTooltipItemOption(1489, "", true, false, false);
			// SetTooltipItemColor(255, 255, 255, 0);			

			//setTooltipItemInfo( ItemValue, item, eItemType );

			//Physical Damage
			//AddTooltipItemOption(94, String(GetPhysicalDamage(Item.WeaponType, Item.SlotBitType, Item.CrystalType, Item.Enchanted, Item.pAttack, Item.Attribution)), true, true, false);
			//공격력(:10)

			if( rValue.PhysicalDamage != 0 )
			{					
				AddTooltipItemOption( 94, string( GetPhysicalDamage(Item.WeaponType, Item.SlotBitType, Item.CrystalType, Item.Enchanted, Item.pAttack, Item.Attribution) + rValue.PhysicalDamage),
										  true, true, false, "chatFontSize12", 0, 0, getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);
	
				// (50 + 54)    <-- (기본공격력 + 인챈트보너스공격력)
				AddTooltipItemBonus(Item.pAttack, nEnchantedPhysicalDamageBonus, 0, 7);
			}
			else
			{
				//공격력[물리 데미지]
				if( Item.pAttack != 0 )
				{
					AddTooltipItemOption(94, string( GetPhysicalDamage(Item.WeaponType, Item.SlotBitType, Item.CrystalType, Item.Enchanted, Item.pAttack, Item.Attribution) ), true, true, false, "chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);

					// (50 + 54)    <-- (기본공격력 + 인챈트보너스공격력)
					AddTooltipItemBonus(Item.pAttack, nEnchantedPhysicalDamageBonus, 0, 7);
				}
			}

			//Masical Damage
			//AddTooltipItemOption(98, String(GetMagicalDamage(Item.WeaponType, Item.SlotBitType, Item.CrystalType, Item.Enchanted, Item.mAttack, Item.Attribution)), true, true, false);						
			//마법 공격력(  : 10 )

			if( rValue.MagicalDamage != 0 )
			{	
				//AddTooltipItemOption( 98, string( Item.mAttack + rValue.MagicalDamage ), true, true, false);
				AddTooltipItemOption( 98, string( GetMagicalDamage(Item.WeaponType, Item.SlotBitType, Item.CrystalType, 
																   Item.Enchanted, Item.mAttack, Item.Attribution) + rValue.MagicalDamage ), true, true, false, "chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);
								
				AddTooltipItemBonus(Item.mAttack, nEnchantedMagicalDamageBonus, 0, 7);
			}
			else
			{
				//마법력[마법 데이지]
				if( Item.mAttack != 0 )
				{
					AddTooltipItemOption(98, string( GetMagicalDamage(Item.WeaponType, Item.SlotBitType, Item.CrystalType, Item.Enchanted, Item.mAttack, Item.Attribution) ), true, true, false, "chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);
					AddTooltipItemBonus(Item.mAttack, nEnchantedMagicalDamageBonus, 0, 7);
				}
			}

			//Attack Speed
			AddTooltipItemOption(111, GetAttackSpeedString(Item.pAttackSpeed), true, true, false);
 
			//추가!!!!!!!!!!!!!!!!!!
			//방어력[물리방어]			
			if( Item.pDefense > 0 )
			{
				AddTooltipItemOption(54, string( Item.pDefense ), true, true, false, "chatFontSize12",0, 0, getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);
			}
				
			//마법방어[마법저항]
			if( Item.mDefense > 0 )	
			{
				AddTooltipItemOption(99, string( Item.mDefense ), true, true, false);
			}

			//명중
			if( Item.pHitRate + rValue.PhysicalHitRate != 0 )
				AddTooltipItemOption(96, string( Item.pHitRate + rValue.PhysicalHitRate ), true, true, false);
				//물리명중
				//AddTooltipItemOption(2360, string( Item.pHitRate + rValue.PhysicalHitRate ), true, true, false);

			//크리티컬
			if( Item.pCriRate + rValue.PhysicalCriRate > 0 )
				AddTooltipItemOption(113, string( Item.pCriRate + rValue.PhysicalCriRate ), true, true, false);
				//물리크리티컬
				//AddTooltipItemOption(2362, string( Item.pCriRate + rValue.PhysicalCriRate ), true, true, false);

			//이동속도
			if( Item.MoveSpeed + rValue.MoveSpeed != 0 )
				AddTooltipItemOption(432, string( Item.MoveSpeed + rValue.MoveSpeed ), true, true, false);

			//방어력(방패)			
			if( Item.ShieldDefense > 0 )
			{
				AddTooltipItemOption(95, string( Item.ShieldDefense ), true, true, false, "chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);
			}

			//방어성공
			if( Item.ShieldDefenseRate > 0 )
				AddTooltipItemOption(317, string( Item.ShieldDefenseRate ), true, true, false);

			//물리회피
			if( Item.pAvoid + rValue.PhysicalAvoid > 0 )
				AddTooltipItemOption(2361, string( Item.pAvoid + rValue.PhysicalAvoid ), true, true, false);

			//마법회피
			if( Item.mAvoid + rValue.MagicalAvoid > 0 )
				AddTooltipItemOption(2364, string( Item.mAvoid + rValue.MagicalAvoid ), true, true, false);

			//TTP 48614로 제거.
			//공격속도[물리공격속도] 
			//if( Item.pAttackSpeed + rValue.PhysicalAttackSpeed > 0 )
			//	AddTooltipItemOption(111, string( Item.pAttackSpeed + rValue.PhysicalAttackSpeed ), true, true, false);
			//마법적중[마법명중]
			//if( Item.mHitRate + rValue.MagicalHitRate > 0 )
			//	AddTooltipItemOption(2363, string( Item.mHitRate + rValue.MagicalHitRate ), true, true, false);
			//마법크리티컬
			//if( Item.mCriRate + rValue.MagicalCriRate > 0 )
			//	AddTooltipItemOption(2365, string( Item.mCriRate ), true, true, false);

			//마법속도[마법공격속도]
			if( Item.mAttackSpeed + rValue.MagicalAttackSpeed > 0 )
				AddTooltipItemOption(112, string( Item.mAttackSpeed + rValue.MagicalAttackSpeed ), true, true, false);

			// 마법 무기인가?
			bMagicWeapon = class'UIDATA_ITEM'.static.IsMagicWeapon(Item.ID);

			//SoulShot Count, 정령탄소모
			if (Item.SoulshotCount>0) AddTooltipItemOption(404, "X" $ String(Item.SoulshotCount), true, true, false);
			//SpiritShot Count, 마정탄소모
			if (Item.SpiritShotCount>0) AddTooltipItemOption(496, "X" $ String(Item.SpiritshotCount), true, true, false);

			//if ((Item.SoulshotCount>0 || Item.SpiritShotCount>0 ) && !getInstanceUIData().getIsClassicServer() ) 
			if ((Item.SoulshotCount>0 || Item.SpiritShotCount>0 )) 
			{
				// 정령탄 증폭 효과 수치(float)
				fSoulShotPower   = GetSoulShotPower(Item.CrystalType, Item.Enchanted, Item.weaponType, bMagicWeapon);   
				// 마정탄 증폭 효과 수치(float)
				fSpiritShotPower = GetSpiritShotPower(Item.CrystalType, Item.Enchanted, Item.weaponType, bMagicWeapon);  
				
				// 정령탄, 마정탄 추가 대미지가 같다면 하나로 표현
				if (fSoulShotPower == fSpiritShotPower)
				{
					// 0이면 기본칼라, 0보다 크면 강조
					if (fSoulShotPower > 0)
					{
						AddTooltipItemBlank(TOOLTIP_LINE_HGAP);
						AddTooltipColorText(GetSystemMessage(4297) $ " : ", getColor(163, 163, 163, 255), true, true);	
						AddTooltipColorText("+" $ string(fSoulShotPower) $ "%", getColor(238, 170, 34, 255), false, true);							
					}
				}
				// 정령탄, 마정탄 추가 대미지가 다르면 1.4%, 3%  "," 로 구분해서..
				else
				{
					AddTooltipItemBlank(TOOLTIP_LINE_HGAP);
					AddTooltipColorText(GetSystemMessage(4297) $ " : ", getColor(163, 163, 163, 255), true, true);	
					AddTooltipColorText("+" $ string(fSoulShotPower) $ "%" $ ", " $ string(fSpiritShotPower) $ "%", getColor(238, 170, 34, 255), false, true);	
				}
			}		
			
			//Weight
			if (Item.Weight==0)
				AddTooltipItemOption(52, " 0 ", true, true, false);
			else
				AddTooltipItemOption(52, String(Item.Weight), true, true, false);
			//AddTooltipItemOption(52, String(Item.Weight), true, true, false);
			
			//MP Consume
			if (Item.MpConsume != 0)
			{
				AddTooltipItemOption(320, String(Item.MpConsume), true, true, false);
			}
			
			//제련효과 설명
			AddTooltipRefinery(Item);

		break;
		
		// 2. ARMOR
		case ITEM_ARMOR:
			//if (Len(SlotString)>0)
			//	AddTooltipItemOption(0, SlotString, false, true, false);

			//setTooltipItemInfo( ItemValue, item, eItemType );
			//Debug("아머" @ Item.SlotBitType @ IsMagicalArmor(Item.ID));
			
			// Sheild
			if ( Item.SlotBitType == 256 && Item.ArmorType == 4 ) // ArmorType == 4 is sigil.. 
			{
				//if (Len(SlotString)>0)
				//	AddTooltipItemOption(0, SlotString, false, true, false);
	
				//방어력[물리방어]
				if (Item.pDefense != 0)
				{
					AddTooltipItemOption(95, String(GetPhysicalDefense(Item.CrystalType, Item.Enchanted, Item.pDefense, Item.Attribution)), true, true, false,"chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);
					AddTooltipItemBonus(Item.pDefense, nEnchantedPhysicalDefenseBonus, 0, 7);
				}

				//Avoid Modify
				//물리회피( 물리회피 : 10 )
				if( rValue.PhysicalAvoid != 0 )
				{	
					AddTooltipItemOption( 2361, string( Item.pAvoid + rValue.PhysicalAvoid ), true, true, false);
				}
				else
				{
					//물리회피
					if( Item.pAvoid != 0 )
						AddTooltipItemOption(2361, string( Item.pAvoid ), true, true, false);
				}
				//추가!!!!
				//공격력[물리 데미지]
				if( Item.pAttack + rValue.PhysicalDamage > 0 )
					AddTooltipItemOption(94, string( Item.pAttack + rValue.PhysicalDamage ), true, true, false);		
				//마법력[마법 데이지]
				if( Item.mAttack + rValue.MagicalDamage > 0 )
					AddTooltipItemOption(98, string( Item.mAttack + rValue.MagicalDamage ), true, true, false);	
				//마법속도[마법공격속도]
				if( Item.mAttackSpeed + rValue.MagicalAttackSpeed > 0 )
					AddTooltipItemOption(112, string( Item.mAttackSpeed + rValue.MagicalAttackSpeed ), true, true, false);
				//물리명중
				if( Item.pHitRate + rValue.PhysicalHitRate > 0 )
					AddTooltipItemOption(2360, string( Item.pHitRate + rValue.PhysicalHitRate ), true, true, false);
				//마법적중[마법명중]
				if( Item.mHitRate + rValue.MagicalHitRate > 0 )
					AddTooltipItemOption(2363, string( Item.mHitRate + rValue.MagicalHitRate ), true, true, false);
				//물리크리티컬
				if( Item.pCriRate + rValue.PhysicalCriRate > 0 )
					AddTooltipItemOption(2362, string( Item.pCriRate + rValue.PhysicalCriRate ), true, true, false);
				//마법크리티컬
				if( Item.mCriRate + rValue.MagicalCriRate > 0 )
					AddTooltipItemOption(2365, string( Item.mCriRate + rValue.MagicalCriRate ), true, true, false);
				//이동속도
				if( Item.MoveSpeed + rValue.MoveSpeed != 0 )
					AddTooltipItemOption(432, string( Item.MoveSpeed + rValue.MoveSpeed ), true, true, false);

				//방어력
				if( Item.ShieldDefense > 0 )
				{
					AddTooltipItemOption(95, string( Item.ShieldDefense ), true, true, false,"chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);	
				}
				//방어성공
				if( Item.ShieldDefenseRate > 0 )
					AddTooltipItemOption(317, string( Item.ShieldDefenseRate ), true, true, false);
				//물리회피
				if( Item.pAvoid + rValue.PhysicalAvoid > 0 )
					AddTooltipItemOption(2361, string( Item.pAvoid + rValue.PhysicalAvoid ), true, true, false);
				//마법회피
				if( Item.mAvoid + rValue.MagicalAvoid > 0 )
					AddTooltipItemOption(2364, string( Item.mAvoid + rValue.MagicalAvoid ), true, true, false);
				//마법방어[마법저항]
				
				if( Item.mDefense > 0 )			
					AddTooltipItemOption(99, string( int ( Item.mDefense ) ), true, true, false);

				//TTP 48614로 제거.
				//공격속도[물리공격속도]
				//if( Item.pAttackSpeed + rValue.PhysicalAttackSpeed > 0 )
				//	AddTooltipItemOption(111, string( Item.pAttackSpeed + rValue.PhysicalAttackSpeed ), true, true, false);

				//Weight
				if (Item.Weight != 0)
					AddTooltipItemOption(52, String(Item.Weight), true, true, false);
			}
			// 장갑
			else if (Item.SlotBitType == 256 || Item.SlotBitType == 128)	//SBT_LHAND or SBT_RHAND
			{
				//if (Len(SlotString)>0)
				//	AddTooltipItemOption(0, SlotString, false, true, false);

				//Shield Defense
				//방어력
				if( Item.ShieldDefense != 0 )
				{
					AddTooltipItemOption(95, string( GetShieldDefense(Item.CrystalType, Item.Enchanted, Item.ShieldDefense, Item.Attribution) ), true, true, false,"chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);
					AddTooltipItemBonus(Item.ShieldDefense, nEnchantedShieldDefenseBonus, 0, 7);
				}
				//Avoid Modify
				//if (Item.pAvoid != 0)
				//AddTooltipItemOption(97, String(Item.pAvoid), true, true, false);
				//물리회피( 물리회피 : 10 )
				if( rValue.PhysicalAvoid != 0 )
				{	
					AddTooltipItemOption( 2361, string( Item.pAvoid + rValue.PhysicalAvoid ), true, true, false);
				}
				else
				{
					//물리회피
					if( Item.pAvoid != 0 )
						AddTooltipItemOption(2361, string( Item.pAvoid ), true, true, false);
				}
				//추가!!!!
				//방어력[물리방어]
				if( Item.pDefense >0 )
				{
					AddTooltipItemOption(54, string( Item.pDefense ), true, true, false,"chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);	
				}
				//마법방어[마법저항]
				if( Item.mDefense > 0 )
				{
					AddTooltipItemOption(99, string( int ( Item.mDefense )), true, true, false);
				}
				//공격력[물리 데미지]
				if( Item.pAttack + rValue.PhysicalDamage > 0 )
					AddTooltipItemOption(94, string( Item.pAttack + rValue.PhysicalDamage ), true, true, false);		
				//마법력[마법 데이지]
				if( Item.mAttack + rValue.MagicalDamage > 0 )
					AddTooltipItemOption(98, string( Item.mAttack + rValue.MagicalDamage ), true, true, false);	
				//마법속도[마법공격속도]
				if( Item.mAttackSpeed + rValue.MagicalAttackSpeed > 0 )
					AddTooltipItemOption(112, string( Item.mAttackSpeed + rValue.MagicalAttackSpeed ), true, true, false);
				//물리명중
				if( Item.pHitRate + rValue.PhysicalHitRate > 0 )
					AddTooltipItemOption(2360, string( Item.pHitRate + rValue.PhysicalHitRate ), true, true, false);
				//마법적중[마법명중]
				if( Item.mHitRate + rValue.MagicalHitRate > 0 )
					AddTooltipItemOption(2363, string( Item.mHitRate + rValue.MagicalHitRate ), true, true, false);
				//물리크리티컬
				if( Item.pCriRate + rValue.PhysicalCriRate > 0 )
					AddTooltipItemOption(2362, string( Item.pCriRate + rValue.PhysicalCriRate ), true, true, false);
				//마법크리티컬
				if( Item.mCriRate + rValue.MagicalCriRate > 0 )
					AddTooltipItemOption(2365, string( Item.mCriRate + rValue.MagicalCriRate ), true, true, false);
				//이동속도
				if( Item.MoveSpeed + rValue.MoveSpeed != 0 )
					AddTooltipItemOption(432, string( Item.MoveSpeed + rValue.MoveSpeed ), true, true, false);
				//방어성공
				if( Item.ShieldDefenseRate > 0 )
					AddTooltipItemOption(317, string( Item.ShieldDefenseRate ), true, true, false);
				//물리회피
				if( Item.pAvoid + rValue.PhysicalAvoid > 0 )
					AddTooltipItemOption(2361, string( Item.pAvoid + rValue.PhysicalAvoid ), true, true, false);
				//마법회피
				if( Item.mAvoid + rValue.MagicalAvoid > 0 )
					AddTooltipItemOption(2364, string( Item.mAvoid + rValue.MagicalAvoid ), true, true, false);
				//TTP 48614로 제거.
				//공격속도[물리공격속도]
				//if( Item.pAttackSpeed + rValue.PhysicalAttackSpeed > 0 )
				//	AddTooltipItemOption(111, string( Item.pAttackSpeed + rValue.PhysicalAttackSpeed ), true, true, false);

				//Weight
				if (Item.Weight != 0)
					AddTooltipItemOption(52, String(Item.Weight), true, true, false);
			}
			
			// Magical Armor
			else if (IsMagicalArmor(Item.ID))
			{
				// Debug("IsMagicalArmor" @ Item.mDefense);
				//Slot Type
				//if (Len(SlotString)>0)
				//	AddTooltipItemOption(0, SlotString, false, true, false);
				
				//MP Bonus
				if (Item.MpBonus > 0)
					AddTooltipItemOption(388, String(Item.MpBonus), true, true, false,"chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);
				
				//Physical Defense
				if (Item.SlotBitType == 65536 || Item.SlotBitType == 524288 || Item.SlotBitType == 262144 ) //슬롯 비트 타입이 헤어 악세사리 윗, 둘다, 아래 일 경우 
				{
					//헤어 악세사리 인첸트 된 방어력 표시
					if ( GetPhysicalDefense(Item.CrystalType, Item.Enchanted, Item.pDefense, Item.Attribution) != 0 )
					{
						AddTooltipItemOption(95, String(GetPhysicalDefense(Item.CrystalType, Item.Enchanted, Item.pDefense, Item.Attribution)), true, true, false,"chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);					
						AddTooltipItemBonus(Item.pDefense, nEnchantedPhysicalDefenseBonus, 0, 7);
					}
				}
				else
				{
					//방어력[물리방어]
					if (Item.pDefense != 0)
					{
						// Debug("물리방어 "@ String(GetPhysicalDefense(Item.CrystalType, Item.Enchanted, Item.pDefense, Item.Attribution)));
						AddTooltipItemOption(95, String(GetPhysicalDefense(Item.CrystalType, Item.Enchanted, Item.pDefense, Item.Attribution)), true, true, false,"chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);	
						AddTooltipItemBonus(Item.pDefense, nEnchantedPhysicalDefenseBonus, 0, 7);
					}
					//마법방어[마법저항]
					if( Item.mDefense > 0 )
					{
						// Debug("마법저항 "@ String(GetMagicalDefense(Item.CrystalType, Item.Enchanted, Item.mDefense, Item.Attribution)));
						AddTooltipItemOption(99, string( int ( Item.mDefense )), true, true, false,"chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);
					}
					//추가!!!!
					//공격력[물리 데미지]
					if( Item.pAttack + rValue.PhysicalDamage > 0 )
						AddTooltipItemOption(94, string( Item.pAttack + rValue.PhysicalDamage ), true, true, false);		
					//마법력[마법 데이지]
					if( Item.mAttack + rValue.MagicalDamage > 0 )
						AddTooltipItemOption(98, string( Item.mAttack + rValue.MagicalDamage ), true, true, false);	
					//마법속도[마법공격속도]
					if( Item.mAttackSpeed + rValue.MagicalAttackSpeed > 0 )
						AddTooltipItemOption(112, string( Item.mAttackSpeed + rValue.MagicalAttackSpeed ), true, true, false);
					//물리명중
					if( Item.pHitRate + rValue.PhysicalHitRate > 0 )
						AddTooltipItemOption(2360, string( Item.pHitRate + rValue.PhysicalHitRate ), true, true, false);
					//마법적중[마법명중]
					if( Item.mHitRate + rValue.MagicalHitRate > 0 )
						AddTooltipItemOption(2363, string( Item.mHitRate + rValue.MagicalHitRate ), true, true, false);
					//물리크리티컬
					if( Item.pCriRate + rValue.PhysicalCriRate > 0 )
						AddTooltipItemOption(2362, string( Item.pCriRate + rValue.PhysicalCriRate ), true, true, false);
					//마법크리티컬
					if( Item.mCriRate + rValue.MagicalCriRate > 0 )
						AddTooltipItemOption(2365, string( Item.mCriRate + rValue.MagicalCriRate ), true, true, false);
					//이동속도
					if( Item.MoveSpeed + rValue.MoveSpeed != 0 )
						AddTooltipItemOption(432, string( Item.MoveSpeed + rValue.MoveSpeed ), true, true, false);
					//방어성공
					if( Item.ShieldDefenseRate > 0 )
						AddTooltipItemOption(317, string( Item.ShieldDefenseRate ), true, true, false);
					//물리회피
					if( Item.pAvoid + rValue.PhysicalAvoid > 0 )
						AddTooltipItemOption(2361, string( Item.pAvoid + rValue.PhysicalAvoid ), true, true, false);
					//마법회피
					if( Item.mAvoid + rValue.MagicalAvoid > 0 )
						AddTooltipItemOption(2364, string( Item.mAvoid + rValue.MagicalAvoid ), true, true, false);
					//방어력
					if( Item.ShieldDefense > 0 )
					{
						AddTooltipItemOption(95, string( Item.ShieldDefense ), true, true, false);
					}

					//방어성공
					if( Item.ShieldDefenseRate > 0 )
						AddTooltipItemOption(317, string( Item.ShieldDefenseRate ), true, true, false);
					//TTP 48614로 제거.
					//공격속도[물리공격속도]
					//if( Item.pAttackSpeed + rValue.PhysicalAttackSpeed > 0 )
					//	AddTooltipItemOption(111, string( Item.pAttackSpeed + rValue.PhysicalAttackSpeed ), true, true, false);
				}

				//Weight
				if (Item.Weight != 0)
					AddTooltipItemOption(52, String(Item.Weight), true, true, false);				
			}
			
			// Physical Armor
			else
			{
				//Slot Type
				
				//if (Len(SlotString)>0)
				//	AddTooltipItemOption(0, SlotString, false, true, false);
				
				//Physical Defense
				if (Item.SlotBitType == 65536 || Item.SlotBitType == 524288 || Item.SlotBitType == 262144 ) //슬롯 비트 타입이 헤어 악세사리 윗, 둘다, 아래 일 경우 
				{
					//헤어 악세사리 인첸트 된 방어력 표시
					if ( GetPhysicalDefense(Item.CrystalType, Item.Enchanted, Item.pDefense, Item.Attribution) != 0 )					
					{
						AddTooltipItemOption(95, String(GetPhysicalDefense(Item.CrystalType, Item.Enchanted, Item.pDefense, Item.Attribution)), true, true, false,"chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);					
						AddTooltipItemBonus(Item.pDefense, nEnchantedPhysicalDefenseBonus, 0, 7);
					}
				}				
				else
				{
					//방어력[물리방어]
					if (Item.pDefense != 0)
					{
						AddTooltipItemOption(95, String(GetPhysicalDefense(Item.CrystalType, Item.Enchanted, Item.pDefense, Item.Attribution)), true, true, false,"chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);
						AddTooltipItemBonus(Item.pDefense, nEnchantedPhysicalDefenseBonus, 0, 7);
					}
					//마법방어[마법저항]
					if( Item.mDefense > 0 )
					{
						AddTooltipItemOption(99, string( int (Item.mDefense) ), true, true, false,"chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);
					}

					//추가!!!!
					//공격력[물리 데미지]
					if( Item.pAttack + rValue.PhysicalDamage > 0 )
						AddTooltipItemOption(94, string( Item.pAttack + rValue.PhysicalDamage ), true, true, false);		
					//마법력[마법 데이지]
					if( Item.mAttack + rValue.MagicalDamage > 0 )
						AddTooltipItemOption(98, string( Item.mAttack + rValue.MagicalDamage ), true, true, false);	
					//마법속도[마법공격속도]
					if( Item.mAttackSpeed + rValue.MagicalAttackSpeed > 0 )
						AddTooltipItemOption(112, string( Item.mAttackSpeed + rValue.MagicalAttackSpeed ), true, true, false);
					//물리명중
					if( Item.pHitRate + rValue.PhysicalHitRate > 0 )
						AddTooltipItemOption(2360, string( Item.pHitRate + rValue.PhysicalHitRate ), true, true, false);
					//마법적중[마법명중]
					if( Item.mHitRate + rValue.MagicalHitRate > 0 )
						AddTooltipItemOption(2363, string( Item.mHitRate + rValue.MagicalHitRate ), true, true, false);
					//물리크리티컬
					if( Item.pCriRate + rValue.PhysicalCriRate > 0 )
						AddTooltipItemOption(2362, string( Item.pCriRate + rValue.PhysicalCriRate ), true, true, false);
					//마법크리티컬
					if( Item.mCriRate + rValue.MagicalCriRate > 0 )
						AddTooltipItemOption(2365, string( Item.mCriRate + rValue.MagicalCriRate ), true, true, false);
					//이동속도
					if( Item.MoveSpeed + rValue.MoveSpeed != 0 )
						AddTooltipItemOption(432, string( Item.MoveSpeed + rValue.MoveSpeed ), true, true, false);
					//방어성공
					if( Item.ShieldDefenseRate > 0 )
						AddTooltipItemOption(317, string( Item.ShieldDefenseRate ), true, true, false);
					//물리회피
					if( Item.pAvoid + rValue.PhysicalAvoid > 0 )
						AddTooltipItemOption(2361, string( Item.pAvoid + rValue.PhysicalAvoid ), true, true, false);
					//마법회피
					if( Item.mAvoid + rValue.MagicalAvoid > 0 )
						AddTooltipItemOption(2364, string( Item.mAvoid + rValue.MagicalAvoid ), true, true, false);
					//방어력
					if( Item.ShieldDefense > 0 )
					{
						AddTooltipItemOption(95, string( Item.ShieldDefense ), true, true, false);	
					}
					//방어성공
					if( Item.ShieldDefenseRate > 0 )
						AddTooltipItemOption(317, string( Item.ShieldDefenseRate ), true, true, false);
					//TTP 48614로 제거.
					//공격속도[물리공격속도]
					//if( Item.pAttackSpeed + rValue.PhysicalAttackSpeed > 0 )
					//	AddTooltipItemOption(111, string( Item.pAttackSpeed + rValue.PhysicalAttackSpeed ), true, true, false);
				}
				//Weight
				if (Item.Weight != 0)
					AddTooltipItemOption(52, String(Item.Weight), true, true, false);
			}			

			//제련효과 설명, 방어구는 제련이 현재 안되는 걸로 알고 있음, 코드가 기존에 있었어서 남겨놓음.
			AddTooltipRefinery(Item);
		break;
		
		// 3. ACCESSARY
		case ITEM_ACCESSARY:
			//Debug(  "ITEM_ACCESSARY" @ Item.SlotBitType ) ;
			//Slot Type
			//if (Len(SlotString)>0)
			//	AddTooltipItemOption(0, SlotString, false, true, false);

			if ( Item.SlotBitType == int64("206158430208") )
			{				
				AddAgathionSkillTooltip ( item ) ;				
			}
		
			//Magical Defense
			// 탈리스만은 아이템 마방을 보여주지 않는다.
			// 왼팔찌 오른팔찌도 마방을 보여주지 않는다. 
			// 쥬얼도 마방을 보여주지 않는다.
			//Debug( Item.CrystalType @  String(GetMagicalDefense(Item.CrystalType, Item.Enchanted, Item.mDefense, Item.Attribution) ));
			//클래식 
			// ttp 72362, 클래식 이소정 요청 (브로치 아이템 툴팁, 마법 저항이 표시 안되게)
			// 아가시온 아이템들은 마법 저항이 표시 안 되게  201612월 버젼
			if ( getInstanceUIData().getIsClassicServer() ) 
			{
				// (Item.SlotBitType != int64("206158430208")) &&
				if(  ( Item.SlotBitType != 536870912) && (Item.SlotBitType != 1073741824 ) &&  (Item.SlotBitType != 4194304 ) && (Item.SlotBitType != 1048576 ) && (Item.SlotBitType != 2097152 ) ) //&& Item.CrystalType > 0) //branch 111109 > 해외 팀이 수정 했으나, 무급 아이템 방어력이 표시 되지 않으므로 수정
				{
					// 마법 저항력이 0보다 큰 경우만 표시 
					if ( GetMagicalDefense(Item.CrystalType, Item.Enchanted, Item.mDefense, Item.Attribution) > 0 )  AddTooltipItemOption(99, String(GetMagicalDefense(Item.CrystalType, Item.Enchanted, Item.mDefense, Item.Attribution)), true, true, false,"chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);				
					AddTooltipItemBonus(Item.mDefense, nEnchantedMagicalDefenseBonus, 0, 7);
				}
			}
			else
			{
				//(Item.SlotBitType != int64("206158430208")) &&
				if(  (Item.SlotBitType != 1073741824 ) &&  (Item.SlotBitType != 4194304 ) && (Item.SlotBitType != 1048576 ) && (Item.SlotBitType != 2097152 ) ) //&& Item.CrystalType > 0) //branch 111109 > 해외 팀이 수정 했으나, 무급 아이템 방어력이 표시 되지 않으므로 수정
				{
					// 마법 저항력이 0보다 큰 경우만 표시 
					if ( GetMagicalDefense(Item.CrystalType, Item.Enchanted, Item.mDefense, Item.Attribution) > 0 )  AddTooltipItemOption(99, String(GetMagicalDefense(Item.CrystalType, Item.Enchanted, Item.mDefense, Item.Attribution)), true, true, false,"chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);				
					AddTooltipItemBonus(Item.mDefense, nEnchantedMagicalDefenseBonus, 0, 7);
				}
			}
			
			if (Item.Weight == 0)
				AddTooltipItemOption(52, " 0 ", true, true, false);
			else 
				AddTooltipItemOption(52, String(Item.Weight), true, true, false);
			
			//제련효과
			AddTooltipRefinery(Item);
			break;
		
		// 4. QUEST
		case ITEM_QUESTITEM:
			//Slot Type
			//if (Len(SlotString)>0)
			//	AddTooltipItemOption(0, SlotString, false, true, false);
			break;
		
		// 5. ETC
		case ITEM_ETCITEM:
			// 카드이벤트 정우균 추가(2013.01.28)

			//Debug ( "ITEM_ETCITEM" @ eEtcItemType  )  ;
			if(eEtcItemType == ITEME_CARD_EVENT)
			{
				CardEventImgTooltip(Item, "inventory");
			}
			
			else if (eEtcItemType == ITEME_PET_COLLAR)
			{
				//Pet Name
				if (Item.Damaged == 0)
					nTmp = 971;
				else
					nTmp = 970;
				AddTooltipItemOption2(969, nTmp, true, true, false);
				
				//Pet Level
				AddTooltipItemOption(88, String(Item.Enchanted), true, true, false);
			}
			else if (eEtcItemType == ITEME_TICKET_OF_LORD)
			{
				AddTooltipItemOption(972, String(Item.Enchanted), true, true, false);
			}
			else if (eEtcItemType == ITEME_LOTTO)
			{
				// 복권에서는 bless가 회차, 몬스터레이스에서는 Enchant가 회차입니다. 주의하세요! - lancelot 2008. 11. 11.
				// 회차
				AddTooltipItemOption(670, String(Item.Blessed), true, true, false);
				
				//branch GD35_0828 2013-12-18 luciper3 - 패킷 최적화 작업으로 인하여 인챈트와 데미지 변수에 값이 잘못온다.. 
				//                                       소라씨가 무기외형정보 변수에 넣어서 보내줌으로써 변경됨.
				// 선택번호
				//AddTooltipItemOption(671, GetLottoString(Item.Enchanted, Item.Damaged), true, true, false);
				AddTooltipItemOption(671, GetLottoString(Item.LookChangeItemID), true, true, false);
				//end of branch
			}
			else if (eEtcItemType == ITEME_RACE_TICKET)
			{
				// 회차
				AddTooltipItemOption(670, String(Item.Enchanted), true, true, false);
				
				// 선택번호
				AddTooltipItemOption(671, GetRaceTicketString(Item.Blessed), true, true, false);
				
				//Money
				AddTooltipItemOption(744, String(Item.Damaged*100), true, true, false);
			}
			//Weight
			//~ if (Item.Price!=0)

			// 사용 가능 회수가 0 보다 큰 경우 
			else if ( item.MaxUseCount > 0 ) 
			{
				AddCrossLine();
		        AddTooltipItemBlank(0);

				// 큐브 아이템
				AddTooltipText("<" $ GetSystemString (3801)  $ ">", true, true);
				
				// 재사용 시간
				AddTooltipItemBlank(0);
				addTexture("l2ui_ct1.SkillWnd_DF_ListIcon_use", 12, 11, 12, 11, 3, 7);
				// 남은 시간 
				AddTooltipColorText(GetSystemString(2378) $ " : ", getColor(163,163,163,255), false, true, false, "", 0, TOOLTIP_LINE_HGAP);
				// ParamAdd 부분 때문에 그대로 나둠.


				StartItem();
				m_Info.eType = DIT_TEXT;
				m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
				m_Info.bLineBreak = false;
				m_Info.t_bDrawOneLine = true;
				m_Info.t_color = getColor(176,155,121,255);
				/*
				m_Info.t_color.R = 176;
				m_Info.t_color.G = 155;
				m_Info.t_color.B = 207;
				m_Info.t_color.A = 255;*/
				

				//Debug ( Item.RemainReuseDelay @ Item.MaxReuseDelay ) ;
				// MaxReuseDelay가 -1이면, 남은 시간을 출력하지 않고 "1일 1회 사용(매일 오전 6:30 초기화) 고정 문자열을 출력)

				//Debug ( Item.RemainReuseDelay $ Item.MaxReuseDelay ) ;
				if (Item.MaxReuseDelay < 0) m_Info.t_strText = GetSystemString ( 3804 ) ;
				else 
				{				
					// Condition Type을 "ReuseDelay" 설정하면 클라에서 매 프레임마다 남은 시간을 계산해서 m_Info.t_strText에 넣어서 출력
					if ( Item.RemainReuseDelay == 0 )  m_Info.t_strText = GetSystemString ( 3537 ) ;
					else 
					{
						m_Info.t_strText = MakeTimeStr(Item.RemainReuseDelay);
						ParamAdd(m_Info.Condition, "Type", "ReuseDelay");
					}
				}
				
				EndItem();

				// 사용 가능 횟수
				AddTooltipItemBlank(0);
				addTexture("l2ui_ct1.Icon.Tooltip_CubeIcon", 12, 11, 12, 11, 3, 7);
				AddTooltipColorText(GetSystemString(3802) $ " : ", getColor(163,163,163,255), false, true, false, "", 0, TOOLTIP_LINE_HGAP);
				AddTooltipColorText((item.MaxUseCount - item.CurUseCount)$"/"$item.MaxUseCount , getColor(176,155,121,255), false, true, false, "", 0, TOOLTIP_LINE_HGAP);
//				AddTooltipItemOption(3802, item.CurUseCount$"/"$item.MaxUseCount, false, true, false);
				
				// 아이템 소멸 안내
				AddTooltipColorText("  ("$ GetSystemString (3803) $")", getColor(238,170,34,255), true, true);

				AddCrossLine();
		        AddTooltipItemBlank(0);
			}
			
			if( eEtcItemType != ITEME_CARD_EVENT) 
			{
				if (Item.Weight==0)
					AddTooltipItemOption(52, " 0 ", true, true, false);
				else
					AddTooltipItemOption(52, String(Item.Weight), true, true, false);
			}
			
			break;			
		}

		//------------------------------------------------------------------------------------
		//  추가 아이템 정보들
		//------------------------------------------------------------------------------------
		
		// 칠월칠석, 방어구 각인 (<인챈트 효과> 및 설명)
		AddTooltipEventSeventhdayOfSeventhMonth(Item);

		// 투영병기 표시, 내구도 아이템
		AddTooltipItemDurability(Item);
		
		//에너지 정보
		AddTooltipBR_MaxEnergy(Item);

		// 아이템 설명 
		if (Len(Item.Description)>0) 
		{
			AddCrossLine();
			AddTooltipItemBlank(TOOLTIP_LINE_HGAP);

			AddTooltipColorText(Item.Description, getColor(178,190,207,255), true, false);
		}	
		
		// 셋트 아이템 정보
		addSetitemTooltip( Item );
		
		//퀘스트 정보를 표시한다.
		AddTooltipItemQuestList(Item);
		
		//집혼효과 툴팁 (2015-03-11)
		AddWeaponEnsoulOption(Item);

		// 아이템 봉인 상태 
		if ( item.bSecurityLock ) 
		{
			AddCrossLine();
			AddTooltipItemOption(3805, "", true, true, false,,,,getColor(230, 230, 230, 255));
			AddTooltipColorText(GetSystemString (3806 ) ,   getColor(178,190,207,255), true, true,,,,TOOLTIP_LINE_HGAP);			
		}

		// 속성 게이지를 그려준다. 펫 인벤토리에서는 그리지 않는다.
		if ( TooltipType != "InventoryPet") AddTooltipItemAttributeGage(Item);
		
		// 무기외형변경넣기
		AddTooltipItemWeaponLookChange(Item); //branch 110824
		
		// 기간제 아이템, 기간제 가공 
		AddTooltipItemCurrentPeriod(Item);		
	}
	else
	{
		return;		
	}

	// PawnViewer용 추가 - lancelot 2007. 10. 16.
	if(TooltipType == "InventoryPawnViewer") AddTooltipText("ID : "$string(Item.Id.classID), true, true);

	// 아데나만, 최소 사이즈를 적용하지 않고, 나머지들은 최소 사이즈를 적용 시킨다.
	// 아데나만 불가표시를 사용하지 않음
	if (!IsAdena(Item.ID)) 
	{
		// 불가표시 사용하고, 타이틀 길이가 짧다면, 최소 폭을 일정 길이로 유지 시키다.
		addForbidItemDesc(Item.ID);
		m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH;
	}

	//기간제 아이템이 있는 경우 기간제 아이템에 맞춰 최소 넓이 값을 일단 잡아 줌.
	if ( item.CurrentPeriod > 0 ) setMakeTimeStrMaxWidth();
	setTooltipMinimumWidth ();
	
	//if ( item.ID.classID == 49032 ) Debug ( "getMaxWidth" @ getMaxWidth( item.ID.classID == 49032 )) ;

	ReturnTooltipInfo(m_Tooltip);
}   


function setTooltipMinimumWidth ()
{
	m_Tooltip.MinimumWidth = getMaxWidth(); //기간제 아이템 ID
	toolTipLineWidthRefresh();
}


function toolTipLineWidthRefresh()
{  
	local int i;

	for (i = 0; i < m_Tooltip.DrawList.Length; i++)
	{
		if ( m_Tooltip.DrawList[i].eType == DIT_SPLITLINE ) 		
		{
			m_Info.u_nTextureWidth = m_Tooltip.MinimumWidth;
		}
	}
}
 
function int getMaxWidth (  ) 
{	
	local int i;
	local int Width, Height, MaxWidth, tmpWidth;

	 // Debug ("getMaxWidth" @  m_Tooltip.MinimumWidth );

	MaxWidth = m_Tooltip.MinimumWidth;

	for ( i = 0 ; i < m_Tooltip.DrawList.Length ; i ++ )
	{
		//Debug( "getMaxWidth" @ i @ m_Tooltip.DrawList[i].eType );
		
		if ( m_Tooltip.DrawList[i].eType == DIT_TEXT || m_Tooltip.DrawList[i].eType == DIT_TEXTLINK) 
		{		
			//한 줄일 때 만 출력 그 외에는 자동 들여쓰기 기능으로 처리 됨.
			if ( m_Tooltip.DrawList[i].t_bDrawOneLine )
			{
				GetTextSizeDefault ( m_Tooltip.DrawList[i].t_strText , Width, Height ) ;

				//bLineBreak 처리 되지 않는 경우 다음 줄로 넘어가지 않음.
				if ( !m_Tooltip.DrawList[i].bLineBreak ) 
				{
					Width = Width + tmpWidth;
				}				
				//Debug ( "getMaxWidth2" @ Width @  m_Tooltip.DrawList[i].t_strText );
			}			
		}
		else if ( m_Tooltip.DrawList[i].eType == DIT_TEXTURE || m_Tooltip.DrawList[i].eType == DIT_SPLITLINE) 
		{		
			if (  m_Tooltip.DrawList[i].t_bDrawOneLine )
			{
				Width = m_Tooltip.DrawList[i].u_nTextureWidth;
				if ( !m_Tooltip.DrawList[i].bLineBreak ) 
				{
					Width = tmpWidth + Width;
				}
			}
		}

		Width = Width + m_Tooltip.DrawList[i].nOffSetX;

		if ( Width > MaxWidth ) MaxWidth = Width;

		tmpWidth = Width;
	}	

	return  MaxWidth ;
}

//----------------------------------------------------------------------------------------------------------------------------------------------------
// 컨텐츠와 연관 된 함수들 모음
//----------------------------------------------------------------------------------------------------------------------------------------------------

// 아이템 금지 사항, 가능 사항, 표기 
// EP1.0 [0319] 추가
function bool addForbidItemDesc(ItemID pItemID)
{
	local string forbidItemDesc, enableItemDesc;
	local bool flag;

	//클래식 서버 일 경우 덧붙이지 않는다.
	if ( getInstanceUIData().getIsClassicServer() ) return false;

	flag = false;
	
	// 불가표시, 가능 표시 스트링을 얻는다
	class'UIDATA_ITEM'.static.GetItemDescriptionAdditionData(pItemID, forbidItemDesc, enableItemDesc);
	//enableItemDesc = "개인/혈맹 창고 가능"; // class'UIDATA_ITEM'.static.GetItemDescriptionAdditionData(pItemID);
	
	if (forbidItemDesc != "" || enableItemDesc != "")
	{
		AddCrossLine();

		AddTooltipItemBlank(TOOLTIP_LINE_HGAP);

		// 가능한 목록 
		if (enableItemDesc != "")
		{
			AddTooltipColorText(enableItemDesc, getColor(158, 127, 87, 255), true, false);
		}

		//getColor(138, 47, 47, 255)
		// 창고, 혈맹창고, 교환, 드랍 불가 같은 것을 출력.
		if (forbidItemDesc != "")
		{
			AddTooltipColorText(forbidItemDesc, getColor(152, 83, 45, 200), true, false);
		}

		// AddTooltipItemBlank(3);
		flag = true;
	}

	return flag;
}

function CardEventImgTooltip(ItemInfo Item, optional string sender)
{
	StartItem();
	m_Tooltip.SimpleLineCount = 1;
	EndItem();

	StartItem();
	m_Info.eType = DIT_TEXTURE;
	m_Info.u_nTextureWidth = 242;
	m_Info.u_nTextureHeight = 344;
	m_Info.u_strTexture = Item.tooltipTexutre;
	EndItem();
	
	/*______10주년 이벤트 카드__________
	 * | 38915 | 38916 | 38917 | 38918 |
	 * ---------------------------------
	 * | 38919 | 38920 | 38921 | 38922 |
	 * ---------------------------------
	 * 
	 * * 아르테이아 조각
	 * _________________________________
	 * | 38907 | 38908 | 38909 | 38910 |
	 * ---------------------------------
	 * | 38911 | 38912 | 38913 | 38914 |
	 */
	// *더블클릭하면 상세 페이지가 뜬다는 설명을 넣어주기 위한 예외처리
	if(sender == "inventory")
	{
		if(Item.ID.ClassID >= 38907 && Item.ID.ClassID <= 38922)
		{
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.t_bDrawOneLine = true;
			m_Info.bLineBreak = true;
			m_Info.t_color.R = 255;
			m_Info.t_color.G = 255;
			m_Info.t_color.B = 255;
			m_Info.t_color.A = 255;
			m_Info.t_strText = GetSystemString(3218);
			EndItem();
		}
	}

	ReturnTooltipInfo(m_Tooltip);
}

//카드이벤트 gfx용 툴팁 표시  정우균 추가 2013.01.29
function ReturnTooltip_NTT_GFXCARD(string param, ETooltipSourceType eSourceType)
{
	local ItemInfo Item;
	local string ItemName;
	local int ItemNameClass;
	//Debug( "ReturnTooltip_NTT_GFXCARD" @ ItemName );
	if (eSourceType == NTST_ITEM)
	{
		ParamToItemInfo(param, Item);
		
		//아이템 이름 취득
		ItemName = class'UIDATA_ITEM'.static.GetRefineryItemName( Item.Name, Item.RefineryOp1, Item.RefineryOp2 );
		ItemNameClass = class'UIDATA_ITEM'.static.GetItemNameClass( Item.ID );

		AddTooltipItemName(ItemName, Item, ItemNameClass);		
		
		CardEventImgTooltip(Item);
	}
}

//사기방지 유저 툴팁 정보
function ReturnTooltip_NTT_CHAT_USERFAKEINFO(string param, ETooltipSourceType eSourceType)
{
	if (eSourceType == NTST_TEXT)
	{
		ChatUserFakeInfoTooltip(param);
	}
}

function ChatUserFakeInfoTooltip(String param)
{
	local string charName;
	local int isFriend, isGM, isPledge, isAlliance, isMentoring;	

	ParseString(param, "CharName",      charName);
	ParseInt( param,   "IsFriend",		isFriend );
	ParseInt( param,   "IsPledge",		isPledge );
	ParseInt( param,   "IsMentoring",   isMentoring );
	ParseInt( param,   "IsAlliance",    isAlliance );
	ParseInt( param,   "IsGM",          isGM );
	
	//친구
	if(isFriend != 0)
	{
		AddTooltipItemColorOption(2273, GetSystemString(3175), 77, 255, 99, true, true, true);
	}
	else
	{
		AddTooltipItemColorOption(2273, GetSystemString(3176), 255, 66, 66, true, true, true);
	}
	
	//혈맹
	if(isPledge != 0)
	{
		AddTooltipItemColorOption(314, GetSystemString(3179), 77, 255, 99, true, true, false);
	}
	
	else
	{
		AddTooltipItemColorOption(314, GetSystemString(3180), 255, 66, 66, true, true, false);
	}
		

	
	//멘토, 클래식 서버에서는 노출 되면 안됨.
	if(isMentoring != 0 && !getInstanceUIData().getIsClassicServer() )
	{
		AddTooltipItemColorOption(2767, GetSystemString(3177), 77, 255, 99, true, true, false);
	}
	else if ( !getInstanceUIData().getIsClassicServer() ) 
	{
		AddTooltipItemColorOption(2767, GetSystemString(3178), 255, 66, 66, true, true, false);
	}
		
	//동맹
	if(isAlliance != 0)
	{
		AddTooltipItemColorOption(490, GetSystemString(3181), 77, 255, 99, true, true, false);
	}
	else
	{
		AddTooltipItemColorOption(490, GetSystemString(3182), 255, 66, 66, true, true, false);
	}
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// Macro , 2015-10-26, 매크로 개편, 매크로 커멘드 모두 툴팁에 보이도록 추가
function ReturnTooltip_NTT_MACRO(string param, ETooltipSourceType eSourceType, optional bool bUseUserMacro)
{
	local ItemInfo Item;
	local MacroInfo macroInfo;
	local int idx;
	local array<String> commandArray;

	local bool bCustomMacro;
	
	if (eSourceType == NTST_ITEM)
	{
		// Debug("param"  @ param);
		ParamToItemInfo(param, Item);

		bCustomMacro = class'UIDATA_MACRO'.static.GetMacroInfo(Item.Id, macroInfo);

		// Debug("macroInfo.IconSkillId: " @ macroInfo.IconSkillId);
		// Debug("macroInfo.IconName: " @ macroInfo.IconName);
		// Debug("macroInfo.IconTextureName: " @ macroInfo.IconTextureName);

		if(macroInfo.IconSkillId > 0)
		{
			Item.IconName = class'UIDATA_SKILL'.static.GetIconName(GetItemID(macroInfo.IconSkillId), 1, 0);
		}

		//Item.IconName = macroInfo.IconName;

		// 아이템 아이콘을 찍는다.
		addItemIcon(Item, "");

		m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH;
		// 이름
		AddTooltipText(Item.Name, false, true, true, "chatFontSize11", 5, 1);
		
		//설명
		// 아이템 설명 
		if (Len(Item.Description) > 0) AddTooltipColorText(Item.Description, getColor(178,190,207,255), true, false);

		// Debug("Item.MacroCommand" @ Item.MacroCommand);

		// 프리셋
		if (Item.MacroCommand != "" && !bUseUserMacro)
		{
			//Split(Item.MacroCommand, "\n", commandArray);
			StringIntoArray(Item.MacroCommand, Chr(13), commandArray);

			for (idx = 0; idx < commandArray.Length; idx++)
			{
				// Debug("commandArray : " @ commandArray[idx]);
				if (commandArray[idx] != "") AddTooltipColorText(commandArray[idx], getColor(176,155,121,255), true, true);
			}
		}
		// 유저가 정의한 매크로
		else
		{			
			// 매크로 목록
			if (bCustomMacro)
			{
				for (idx = 0; idx < MACROCOMMAND_MAX_COUNT; idx++)
				{
					if (trim(macroInfo.CommandList[idx]) != "")
					{
						// 너무 길어 지면 .. 처리 (유저가 정의한 매크로 스트링만 적용)
						AddTooltipColorText(makeShortStringByPixel(macroInfo.CommandList[idx], 300, ".."), getColor(176,155,121,255), true, true);
					}
				}
			}
		}
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}


/////////////////////////////////////////////////////////////////////////////////
// ACTION
function ReturnTooltip_NTT_ACTION(string param, ETooltipSourceType eSourceType)
{
	local ItemInfo Item;
	
	if (eSourceType == NTST_ITEM)
	{
		//ParseString( param, "Name", Item.Name);
		//ParseString( param, "Description", Item.Description);
		ParamToItemInfo(param, Item);
		
		// 아이템 아이콘을 찍는다.
		addItemIcon(Item, "");

		//액션 이름
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine    = true;
		m_Info.t_strFontName     = "chatFontSize11";
		m_Info.nOffSetX          = 5;
		m_Info.nOffSetY          = 0;
		m_Info.t_strText         = Item.Name;
		EndItem();
		
		AddTooltipItemBlank(TOOLTIP_LINE_HGAP);

		//액션 설명
		if (Len(Item.Description)>0)
		{
			m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH;
			
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
			m_Info.t_bDrawOneLine = false;
			m_Info.bLineBreak = true;
			m_Info.t_color.R = 178;
			m_Info.t_color.G = 190;
			m_Info.t_color.B = 207;
			m_Info.t_color.A = 255;
			m_Info.t_strText = Item.Description;
			EndItem();
		}		
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// SKILL
function ReturnTooltip_NTT_SKILL(string param, ETooltipSourceType eSourceType)
{
	
	local ItemInfo Item;
	
	local EItemParamType eItemParamType;
	//local EShortCutItemType eShortCutType;
	local int nTmp;
	local int SkillLevel;

	local SkillInfo skillinfo;
	
	if (eSourceType == NTST_ITEM)
	{
		ParseItemID( param, Item.ID );
		ParseString( param, "Name", Item.Name);
		ParseString( param, "AdditionalName", Item.AdditionalName);
		ParseString( param, "Description", Item.Description);
		ParseInt( param, "Level", Item.Level);
		ParseInt( param, "SubLevel", Item.SubLevel);

		//Debug ( "인챈트 내용을 뿌려주는 곳은 이곳" @  Item.AdditionalName @ Item.Level );

		GetSkillInfo( Item.ID.ClassID , Item.Level, Item.SubLevel, skillInfo );

		Item.IconName = skillInfo.TexName;
		
		//eShortCutType = EShortCutItemType(Item.ItemSubType);
		eItemParamType = EItemParamType(Item.ItemType);
		SkillLevel = Item.Level;
		
		m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH;
		
		//아이콘 추가 
		addItemIcon(Item, "");

		//아이템 이름
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = true;
		m_Info.nOffSetX = 5;
		m_Info.t_strText = Item.Name;
		m_Info.t_strFontName = "chatFontSize11";
		EndItem();
		
		// 인챈트시 변환된 레벨을 원래 레벨로 변환시켜준다. 
		/*
		if (Len(Item.AdditionalName)>0)
		{			
			SkillLevel = class'UIDATA_SKILL'.static.GetEnchantSkillLevel( Item.ID, Item.Level, item.SubLevel );
		}*/
		
		//ex) " Lv "
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_strFontName = "chatFontSize11";
		m_Info.t_strText = " ";
		EndItem();
		
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_color.R = 163;
		m_Info.t_color.G = 163;
		m_Info.t_color.B = 163;
		m_Info.t_color.A = 255;
		m_Info.t_strFontName = "chatFontSize11";
		m_Info.t_ID = 88;
		EndItem();
		
		//스킬 레벨
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_color.R = 176;
		m_Info.t_color.G = 155;
		m_Info.t_color.B = 121;
		m_Info.t_color.A = 255;
		m_Info.t_strFontName = "chatFontSize11";
		m_Info.t_strText = " " $ SkillLevel;
		EndItem();

		// 인챈트 내용을 뿌려주는 곳은 이곳

		
		if (Len(Item.AdditionalName)>0)
		{
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetX = 5;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_color.R = 255;
			m_Info.t_color.G = 217;
			m_Info.t_color.B = 105;
			m_Info.t_color.A = 255;
			m_Info.t_strFontName = "chatFontSize11";
			m_Info.t_strText = Item.AdditionalName;
			EndItem();
		}
				
		//Operate Type
		AddTooltipItemBlank(1);
		AddTooltipColorText(class'UIDATA_SKILL'.static.GetOperateType( Item.ID, Item.Level, Item.SubLevel ), getColor(176,155,121,255), true, true, false, "", 38, -19);

		//소모HP
		nTmp = class'UIDATA_SKILL'.static.GetHpConsume( Item.ID, Item.Level, item.SubLevel );
		if (nTmp>0)
		{			
			AddTooltipItemOption(1195, string(nTmp), true, true, false);//, "chatFontSize12", 0, 0, getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);
		}
		
		//소모MP
		nTmp = class'UIDATA_SKILL'.static.GetMpConsume( Item.ID, Item.Level, Item.SubLevel );
		if (nTmp>0)
		{
			AddTooltipItemOption(320, String(nTmp), true, true, false, "chatFontSize12", 0, 0, getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);
		}
		
		//유효거리
		nTmp = class'UIDATA_SKILL'.static.GetCastRange( Item.ID, Item.Level, Item.SubLevel );
		if (nTmp >= 0)
		{
			AddTooltipItemOption(321, String(nTmp), true, true, false);
		}

		////스킬 시전 시간
		if ((skillInfo.HitTime + skillInfo.CoolTime) > 0)
		{
			// luciper3 - 스킬배우기와 같이 소수점도 표시한다.
			//AddTooltipItemOption(2377, MakeBuffTimeStr(int(skillInfo.HitTime + skillInfo.CoolTime)), true, true, false);
			AddTooltipItemOption(2377,util.MakeTimeString(skillInfo.HitTime,skillInfo.CoolTime),true,true,false);
		}
		
		////스킬 재사용 시간
		if (skillInfo.ReuseDelay > 0)
		{
			AddTooltipItemOption(2378, MakeBuffTimeStr(int(skillInfo.ReuseDelay)), true, true, false);
		}
		
		//설명
		if (Len(Item.Description) > 0) 
		{
			AddCrossLine();
			AddTooltipItemBlank(TOOLTIP_LINE_HGAP);
			AddTooltipColorText(Item.Description, getColor(178,190,207,255), true, false);
		}

		// 2014.08.04 스킬인챈트 전체 개편에 따른 툴팁 추가
		// 스킬 인챈트 정보 표시
		if (Len(item.AdditionalName)>0) 
		{
			AddCrossLine();
			AddTooltipItemBlank(TOOLTIP_LINE_HGAP);
			// 강화 효과 

			AddTooltipColorText(GetSystemString(3350) $ " : ", getColor(163,163,163,255), true, false);			
			AddTooltipColorText(item.AdditionalName, getColor(255,217,105,255), false, true);
			AddTooltipColorText(skillInfo.EnchantDesc, getColor(178,190,207,255), true, false);

			// 라인 텍스쳐를 최종 툴팁 가로 사이즈에 맞도록 보정
			setTooltipMinimumWidth ();
		}
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// ABNORMALSTATUS
function ReturnTooltip_NTT_ABNORMALSTATUS(string param, ETooltipSourceType eSourceType)
{
	local ItemInfo Item;
	local int ShowLevel;
	
	local EItemParamType eItemParamType;
	//local EShortCutItemType eShortCutType;
	local skillInfo skillInfo;

	local bool isToppingSkill;	
	
	//Debug ( "ReturnTooltip_NTT_ABNORMALSTATUS" @ param );
	if (eSourceType == NTST_ITEM)
	{
		ParseItemID( param, Item.ID );
		ParseString( param, "Name", Item.Name);
		ParseString( param, "AdditionalName", Item.AdditionalName);
		ParseString( param, "Description", Item.Description);
		ParseInt( param, "Level", Item.Level);
		ParseInt( param, "SubLevel", Item.SubLevel);
		ParseInt( param, "Reserved", Item.Reserved);

		isToppingSkill = class'UIDATA_SKILL'.static.IsToppingSkill( Item.ID, Item.Level, Item.SubLevel)	;

		GetSkillInfo( Item.ID.ClassID , Item.Level, Item.SubLevel, skillInfo );
		
		//eShortCutType = EShortCutItemType(Item.ItemSubType);
		eItemParamType = EItemParamType(Item.ItemType);
		
		m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH;
		
		//아이템 이름
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_strText = Item.Name;
		EndItem();
		
		ShowLevel = Item.Level;		
		
		//ex) " Lv "
		// 토핑 서비스일 경우 레벨 표시를 하지 않는다. 
		if ( !isToppingSkill )
		{
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_strText = " ";
			EndItem();
			
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_color.R = 163;
			m_Info.t_color.G = 163;
			m_Info.t_color.B = 163;
			m_Info.t_color.A = 255;
			m_Info.t_ID = 88;
			EndItem();
			
			//스킬 레벨		
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_color.R = 176;
			m_Info.t_color.G = 155;
			m_Info.t_color.B = 121;
			m_Info.t_color.A = 255;
			m_Info.t_strText = " " $ ShowLevel;
			EndItem();
		}

		if (Len(Item.AdditionalName)>0)
		{
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetX = 5;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_color.R = 255;
			m_Info.t_color.G = 217;
			m_Info.t_color.B = 105;
			m_Info.t_color.A = 255;
			m_Info.t_strText = Item.AdditionalName;
			EndItem();
			
			//ShowLevel = class'UIDATA_SKILL'.static.GetEnchantSkillLevel( Item.ID, Item.Level, Item.SubLevel );
		}
		
		//남은시간
		// ct3 소환수 관련 - 수정
		//if ((GetDebuffType(Item.ID, Item.Level) == 0) && Item.Reserved>=0)
		//디버프일때 수정.
		if (Item.Reserved >= 0 )
		{
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
			m_Info.bLineBreak = true;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_color.R = 163;
			m_Info.t_color.G = 163;
			m_Info.t_color.B = 163;
			m_Info.t_color.A = 255;
			m_Info.t_ID = 1199;
			EndItem();
			
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_color.R = 163;
			m_Info.t_color.G = 163;
			m_Info.t_color.B = 163;
			m_Info.t_color.A = 255;
			m_Info.t_strText = " : ";
			EndItem();
			
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_color.R = 176;
			m_Info.t_color.G = 155;
			m_Info.t_color.B = 121;
			m_Info.t_color.A = 255;			


			//Debug ( "ToppingSkill " @ isToppingSkill  @  Item.ID.classID @  Item.Level@ Item.SubLevel );
			if ( isToppingSkill ) 
			{
				m_Info.t_strText = MakeToppingBuffTimeStr ( Item.Reserved ) ;	
				// 타입을 ToppingRemainTime, RemainTime 으로 설정해 놓으면, 클라이언트에서 시간을 체크 타임 스트링을 조합 함.
				//Debug ( "ToppingRemainTime 로 type 설정");
				ParamAdd(m_Info.Condition, "Type", "ToppingRemainTime");
			}
			else
			{
				m_Info.t_strText = MakeBuffTimeStr(Item.Reserved);
				ParamAdd(m_Info.Condition, "Type", "RemainTime");
			}			
			
			EndItem();
		}
		
		//설명
		if (Len(Item.Description)>0)
		{
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
			m_Info.bLineBreak = true;
			m_Info.t_color.R = 178;
			m_Info.t_color.G = 190;
			m_Info.t_color.B = 207;
			m_Info.t_color.A = 255;
			m_Info.t_strText = Item.Description;
			EndItem();	
		}		

		// 2014.08.04 스킬인챈트 전체 개편에 따른 툴팁 추가
		// 스킬 인챈트 정보 표시
		if (Len(item.AdditionalName)>0) 
		{
			AddCrossLine();
			// 강화 효과 

			AddTooltipColorText(GetSystemString(3350) $ " : ", getColor(163,163,163,255), true, false);			
			AddTooltipColorText(item.AdditionalName, getColor(255,217,105,255), false, true);
			AddTooltipColorText(skillInfo.EnchantDesc, getColor(178,190,207,255), true, false);

			// 라인 텍스쳐를 최종 툴팁 가로 사이즈에 맞도록 보정
			setTooltipMinimumWidth ();
		}
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}


/////////////////////////////////////////////////////////////////////////////////
// LOOCKCHANGEITEM 외형 변경용 툴팁 
function ReturnTooltip_NTT_LOOCKCHANGEITEM(string param )
{
	local String Name;
	
	ParseString( param, "Name", Name);		
	StartItem();
	m_Info.eType = DIT_TEXT;
	m_Info.t_strText = Name;
	EndItem();
		
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// NORMALITEM
function ReturnTooltip_NTT_NORMALITEM(string param, ETooltipSourceType eSourceType)
{
	local ItemInfo Item;	
	if (eSourceType == NTST_ITEM)
	{
		ParseString( param, "Name", Item.Name);
		ParseString( param, "Description", Item.Description);
		ParseString( param, "AdditionalName", Item.AdditionalName);
		ParseInt( param, "CrystalType", Item.CrystalType);
		
		//아이템 이름
		AddTooltipItemName(Item.Name, Item, 1);
		
		//Grade Mark
		AddTooltipItemGrade(Item);
		
		//설명
		if (Len(Item.Description)>0)
		{
			m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH;
			
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
			m_Info.bLineBreak = true;
			m_Info.t_color.R = 178;
			m_Info.t_color.G = 190;
			m_Info.t_color.B = 207;
			m_Info.t_color.A = 255;
			m_Info.t_strText = Item.Description;
			EndItem();	
		}		
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

//branch121212
/////////////////////////////////////////////////////////////////////////////////
// NORMALITEM
function ReturnTooltip_NTT_PREMIUMNORMALITEM(string param, ETooltipSourceType eSourceType)
{
	local ItemInfo Item;	
	if (eSourceType == NTST_ITEM)
	{
		ParseString( param, "Name", Item.Name);
		ParseString( param, "Description", Item.Description);
		ParseString( param, "AdditionalName", Item.AdditionalName);
		ParseInt( param, "CrystalType", Item.CrystalType);
		ParseInt( param, "CurrentPeriod", Item.CurrentPeriod);
		
		//아이템 이름
		AddTooltipItemName(Item.Name, Item, 1);
		
		//Grade Mark
		AddTooltipItemGrade(Item);
				
		//설명
		if (Len(Item.Description)>0)
		{
			m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH;
			
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
			m_Info.bLineBreak = true;
			m_Info.t_color.R = 178;
			m_Info.t_color.G = 190;
			m_Info.t_color.B = 207;
			m_Info.t_color.A = 255;
			m_Info.t_strText = Item.Description;
			EndItem();	
		}		
		
		if ( Item.CurrentPeriod > 0)
		{			
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
			m_Info.bLineBreak = true;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_color.R = 163;
			m_Info.t_color.G = 163;
			m_Info.t_color.B = 163;
			m_Info.t_color.A = 255;
			m_Info.t_ID = 1199;
			EndItem();
			
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_color.R = 163;
			m_Info.t_color.G = 163;
			m_Info.t_color.B = 163;
			m_Info.t_color.A = 255;
			m_Info.t_strText = " : ";
			EndItem();
			
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
			m_Info.bLineBreak = true;
			m_Info.t_color.R = 178;
			m_Info.t_color.G = 190;
			m_Info.t_color.B = 207;
			m_Info.t_color.A = 255;
			m_Info.t_strText = "" $ MakeTimeStr(Item.CurrentPeriod);
			ParamAdd(m_Info.Condition, "Type", "PeriodTime");
			EndItem();
		}		
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}


//end of branch

/////////////////////////////////////////////////////////////////////////////////
// RECIPE
function ReturnTooltip_NTT_RECIPE(string param, ETooltipSourceType eSourceType, bool bShowPrice)
{
	local ItemInfo Item;
	
	local string strAdena;
	local string strAdenaComma;
	local color	 AdenaColor;
	
	if (eSourceType == NTST_ITEM)
	{
		ParseString( param, "Name", Item.Name);
		ParseString( param, "Description", Item.Description);
		ParseString( param, "AdditionalName", Item.AdditionalName);
		ParseInt( param, "CrystalType", Item.CrystalType);
		ParseInt( param, "Weight", Item.Weight);
		ParseINT64( param, "Price", Item.Price);
		
		//아이템 이름
		AddTooltipItemName(Item.Name, Item, 1);
		
		//Grade Mark
		AddTooltipItemGrade(Item);
		
		//가격
		if (bShowPrice)
		{
			strAdena = String(Item.Price);
			strAdenaComma = MakeCostString(strAdena);
			AdenaColor = GetNumericColor(strAdenaComma);
			
			//가격 : xxx,xxx,xxx
			AddTooltipItemOption(641, strAdenaComma $ " ", true, true, false);
			SetTooltipItemColor(AdenaColor.R, AdenaColor.G, AdenaColor.B, 0);
			
			//"아데나"
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_color = AdenaColor;
			m_Info.t_ID= 469;
			EndItem();
			
			//읽어주기 스트링
			if  (strAdena != "")
			{
				AddTooltipItemOption(0, "(" $ ConvertNumToText(strAdena) $ ")", false, true, false);
				SetTooltipItemColor(AdenaColor.R, AdenaColor.G, AdenaColor.B, 0);
			}
		}
		
		//Weight
		AddTooltipItemOption(52, String(Item.Weight), true, true, false);
		
		//설명
		if (Len(Item.Description)>0)
		{
			m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH;
			
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
			m_Info.bLineBreak = true;
			m_Info.t_color.R = 178;
			m_Info.t_color.G = 190;
			m_Info.t_color.B = 207;
			m_Info.t_color.A = 255;
			m_Info.t_strText = Item.Description;
			EndItem();	
		}		
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// SHORTCUT
function ReturnTooltip_NTT_SHORTCUT(string param, ETooltipSourceType eSourceType)
{
	local ItemInfo Item;
	
	local EItemParamType eItemParamType;
	local EShortCutItemType eShortCutType;
	local string ItemName;
	local ShortcutCommandItem commandItem;
	local int shortcutID;
	local string strShort;	

	local OptionWnd Script;


	Script = OptionWnd( GetScript( "OptionWnd" ) );

	strShort = "<" $ GetSystemString(1523) $ ": ";

	if (eSourceType == NTST_ITEM)
	{   
		if( BoolSelect )
		{
			ParseInt( param, "ItemSubType", Item.ItemSubType);
			ParseString( param, "Name", Item.Name);
			ParseInt( param, "RefineryOp1", Item.RefineryOp1);
			ParseInt( param, "RefineryOp2", Item.RefineryOp2);
			eShortCutType = EShortCutItemType(Item.ItemSubType);
			//아이템 이름 취득
			ItemName = class'UIDATA_ITEM'.static.GetRefineryItemName( Item.Name, Item.RefineryOp1, Item.RefineryOp2 );
			switch (eShortCutType)
			{
			case SCIT_ITEM:
				ReturnTooltip_NTT_ITEM(param, "inventory", eSourceType);
				break;
			case SCIT_SKILL:
			case SCIT_ATTRIBUTE:
				ReturnTooltip_NTT_SKILL(param, eSourceType);
				break;
			case SCIT_ACTION:
			case SCIT_MACRO:

				ReturnTooltip_NTT_MACRO(param, eSourceType, true);
				/*
				if (eSourceType == NTST_ITEM)
				{
					ParseString( param, "Name", Item.Name);
					ParseString( param, "Description", Item.Description);
					
					m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH;

					//액션 이름
					StartItem();
					m_Info.eType = DIT_TEXT;
					m_Info.t_bDrawOneLine = true;
					m_Info.t_strText = Item.Name;
					EndItem();
					
					//액션 설명
					if (Len(Item.Description)>0)
					{						
						StartItem();
						m_Info.eType = DIT_TEXT;
						m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
						m_Info.t_bDrawOneLine = false;
						m_Info.bLineBreak = true;
						m_Info.t_color.R = 178;
						m_Info.t_color.G = 190;
						m_Info.t_color.B = 207;
						m_Info.t_color.A = 255;
						m_Info.t_strText = Item.Description;
						EndItem();
					}		
				}
				else
				{
					return;
				}
					
				ReturnTooltipInfo(m_Tooltip);
				*/
				break;
			case SCIT_RECIPE:
			case SCIT_BOOKMARK:
				//아이템 이름
				m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH;
				StartItem();
				m_Info.eType = DIT_TEXT;
				//m_Info.bLineBreak = true;
				m_Info.t_bDrawOneLine = true;
				m_Info.t_strText = ItemName;
				EndItem();
				break;
			default:
				break;
			}
			ParseINT(param, "ShortcutID", shortcutID);			
			
			if( GetChatFilterBool ( "Global", "EnterChatting") ) //GetOptionBool( "CommunIcation", "EnterChatting" ) )
			{
				class'ShortcutAPI'.static.GetAssignedKeyFromCommand("TempStateShortcut", "UseShortcutItem Num=" $ shortcutID, commandItem);
			}
			else
			{
				class'ShortcutAPI'.static.GetAssignedKeyFromCommand("GamingStateShortcut", "UseShortcutItem Num=" $ shortcutID, commandItem);
			}
			
			
			//단축키 설명...
			if( commandItem.subkey1 != "" )
			{
				strShort = strShort $ Script.GetUserReadableKeyName( commandItem.subkey1 ) $ "+";
			}
			if( commandItem.subkey2 != "" )
			{
				strShort = strShort $ Script.GetUserReadableKeyName( commandItem.subkey2 ) $ "+";
			}
			if( commandItem.Key != "" )
			{
				strShort = strShort $ Script.GetUserReadableKeyName( commandItem.Key ) $ ">";
			}

			if( commandItem.subkey1 == "" && commandItem.subkey2 == "" && commandItem.Key == "" )
			{
				strShort = strShort $ GetSystemString(27) $ ">";
			}
			
			//줄추가~
			AddTooltipItemBlank(6);		

			StartItem();
			m_Info.eType = DIT_SPLITLINE;
			m_Info.u_nTextureWidth = TOOLTIP_MINIMUM_WIDTH;			
			m_Info.u_nTextureHeight = 1;
			m_Info.u_strTexture ="L2ui_ch3.tooltip_line";
			EndItem();

			if( ItemName != "" )
			{
				AddTooltipItemBlank(5);
				
				StartItem();
				m_Info.eType = DIT_TEXT;
				m_Info.t_strText = strShort;
				EndItem();
				
				AddTooltipItemBlank(1);
				
				ReturnTooltipInfo(m_Tooltip);				
			}
			return;
		}
		else
		{
			ParseItemID( param, Item.ID );
			ParseString( param, "Name", Item.Name);
			ParseString( param, "AdditionalName", Item.AdditionalName);
			ParseInt( param, "Level", Item.Level);
			ParseInt( param, "SubLevel", Item.SubLevel);
			ParseInt( param, "Reserved", Item.Reserved);
			ParseInt( param, "Enchanted", Item.Enchanted);
			ParseInt( param, "ItemType", Item.ItemType);
			ParseInt( param, "ItemSubType", Item.ItemSubType);
			ParseInt( param, "CrystalType", Item.CrystalType);
			ParseInt( param, "ConsumeType", Item.ConsumeType);
			ParseInt( param, "RefineryOp1", Item.RefineryOp1);
			ParseInt( param, "RefineryOp2", Item.RefineryOp2);
			ParseINT64( param, "ItemNum", Item.ItemNum);
			ParseInt( param, "MpConsume", Item.MpConsume);
			//branch
			ParseInt ( param, "IsBRPremium", Item.IsBRPremium);
			//end of branch

			eShortCutType = EShortCutItemType(Item.ItemSubType);
			eItemParamType = EItemParamType(Item.ItemType);

			//아이템 이름 취득
			ItemName = class'UIDATA_ITEM'.static.GetRefineryItemName( Item.Name, Item.RefineryOp1, Item.RefineryOp2 );

			switch (eShortCutType)
			{
			case SCIT_ITEM:
				//branch
				AddPrimeItemSymbol(Item);
				//end of branch
				//인첸트 ex) "+10"
				AddTooltipItemEnchant(Item);

				//아이템 이름
				AddTooltipItemName(ItemName, Item, 1);

				//Grade Mark
				AddTooltipItemGrade(Item);

				//아이템 갯수
				AddTooltipItemCount(Item);
				break;
			case SCIT_SKILL:
			case SCIT_ATTRIBUTE:
				//아이템 이름
				StartItem();
				m_Info.eType = DIT_TEXT;
				m_Info.t_bDrawOneLine = true;
				m_Info.t_strText = ItemName;
				EndItem();

				//ex) " Lv "
				StartItem();
				m_Info.eType = DIT_TEXT;
				m_Info.t_bDrawOneLine = true;
				m_Info.t_strText = " ";
				EndItem();

				StartItem();
				m_Info.eType = DIT_TEXT;
				m_Info.t_bDrawOneLine = true;
				m_Info.t_color.R = 163;
				m_Info.t_color.G = 163;
				m_Info.t_color.B = 163;
				m_Info.t_color.A = 255;
				m_Info.t_ID = 88;
				EndItem();

				//스킬 레벨
				/*
				if (Len(Item.AdditionalName) > 0)
					Item.Level = class'UIDATA_SKILL'.static.GetEnchantSkillLevel( Item.ID, Item.Level, Item.SubLevel );
				*/

				StartItem();
				m_Info.eType = DIT_TEXT;
				m_Info.t_bDrawOneLine = true;
				m_Info.t_color.R = 176;
				m_Info.t_color.G = 155;
				m_Info.t_color.B = 121;
				m_Info.t_color.A = 255;
				m_Info.t_strText = " " $ Item.Level;
				EndItem();

				if (Len(Item.AdditionalName) > 0)
				{
					StartItem();
					m_Info.eType = DIT_TEXT;
					m_Info.nOffSetX = 5;
					m_Info.t_bDrawOneLine = true;
					m_Info.t_color.R = 255;
					m_Info.t_color.G = 217;
					m_Info.t_color.B = 105;
					m_Info.t_color.A = 255;
					m_Info.t_strText = Item.AdditionalName;
					EndItem();
				}

				//AddTooltipItemBlank(1);
				//MP소모량
				StartItem();
				m_Info.eType = DIT_TEXT;
				m_Info.nOffSetX = -4;
				m_Info.bLineBreak = true;
				m_Info.t_bDrawOneLine = true;
				m_Info.t_strText = " (";
				EndItem();

				StartItem();
				m_Info.eType = DIT_TEXT;
				m_Info.t_bDrawOneLine = true;
				m_Info.t_ID = 91;
				EndItem();

				StartItem();
				m_Info.eType = DIT_TEXT;
				m_Info.t_bDrawOneLine = true;
				m_Info.t_strText = ":" $ Item.MpConsume $ ")";
				EndItem();
				break;

			case SCIT_ACTION:
			case SCIT_MACRO:
			case SCIT_RECIPE:
			case SCIT_BOOKMARK:
				//아이템 이름
				StartItem();
				m_Info.eType = DIT_TEXT;
				m_Info.t_bDrawOneLine = true;
				m_Info.t_strText = ItemName;
				EndItem();
				break;
			}
		}
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// RECIPE_MANUFACTURE
function ReturnTooltip_NTT_RECIPE_MANUFACTURE(string param, ETooltipSourceType eSourceType)
{
	local ItemInfo Item;
	
	if (eSourceType == NTST_ITEM)
	{
		ParseString( param, "Name", Item.Name);
		ParseString( param, "Description", Item.Description);
		ParseString( param, "AdditionalName", Item.AdditionalName);
		ParseINT64( param, "Reserved64", Item.Reserved64);
		ParseInt( param, "CrystalType", Item.CrystalType);
		ParseINT64( param, "ItemNum", Item.ItemNum);
		
		m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH;
		
		//아이템 이름
		AddTooltipItemName(Item.Name, Item, 1);
		
		//Grade Mark
		AddTooltipItemGrade(Item);
		
		//ex) "필요수 : 2"
		AddTooltipItemOption(736, String(Item.Reserved64), true, true, false);
		
		//ex) "보유수 : 0"
		AddTooltipItemOption(737, String(Item.ItemNum), true, true, false);
		
		//설명
		if (Len(Item.Description)>0)
		{
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
			m_Info.bLineBreak = true;
			m_Info.t_color.R = 178;
			m_Info.t_color.G = 190;
			m_Info.t_color.B = 207;
			m_Info.t_color.A = 255;
			m_Info.t_strText = Item.Description;
			EndItem();	
		}
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// FRIENDINFO
function ReturnTooltip_NTT_FRIENDINFO(string param, ETooltipSourceType eSourceType)
{
	local LVDataRecord record;
		
	if (eSourceType == NTST_LIST)
	{
		ParamToRecord( param, record );
		
		//ex) "직업 : 엘븐메이지"
		AddTooltipItemOption(391, GetClassType(int(record.LVDataList[2].szData)), true, true, true);
		// 메모 출력 
		//ex) "메모 : 너는 나쁜 놈이야! " 
		if (record.szReserved != "")
		{
			AddTooltipItemOption(403, record.szReserved, true, true, true);
		}
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// PLEDGEINFO
function ReturnTooltip_NTT_CLANINFO(string param, ETooltipSourceType eSourceType)
{
	local LVDataRecord record;
	
	if (eSourceType == NTST_LIST)
	{
		ParamToRecord( param, record );
		
		//ex) "직업 : 엘븐메이지"
		AddTooltipItemOption(391, GetClassType(int(record.LVDataList[2].szData)), true, true, true);
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

function ReturnTooltip_NTT_AgitDecoList (string param, ETooltipSourceType eSourceType)
{
	local LVDataRecord record;
	local int nUse, totalCnt, i, nItemID, period;
	local string toolTipParam, desc;
	local INT64 nItemCount;

	if (eSourceType == NTST_LIST)
	{
		m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH + 30;

		// Debug("tool param " @ param);
		ParamToRecord( param, record );


		// 사용 안 함
		if (record.LVDataList[0].szData == GetSystemString(869))
		{
			// 사용 안하는 설명을 넣는다.
			addToolTipDrawList(m_Tooltip, addDrawItemText(GetSystemString(3440), getInstanceL2Util().White, "", false));
			ReturnTooltipInfo(m_Tooltip);
			return;
		}

		toolTipParam = param;

		//ParseString(param, "szReserved", toolTipParam);

		//Debug("-------------------------------");

		//Debug("tool param " @ toolTipParam);

		ParseInt(toolTipParam, "totalCnt", totalCnt);
		ParseInt(toolTipParam, "period", period);
		ParseString(toolTipParam, "desc", desc);

		// 배치 중 (사용 중)
		nUse = record.LVDataList[0].nReserved2;

		if (nUse > 0)
		{
			//addToolTipDrawList(m_Tooltip, addDrawItemText("", getInstanceL2Util().White, "", false,,4,2));

			addToolTipDrawList(m_Tooltip, addDrawItemText(record.LVDataList[0].szData, getInstanceL2Util().BrightWhite, "", false, true));
		}
		else
		{
			addToolTipDrawList(m_Tooltip, addDrawItemText(record.LVDataList[0].szData, getInstanceL2Util().White, "", false, true));
		}

		AddCrossLine();
		//desc

		// 기능
		addToolTipDrawList(m_Tooltip, addDrawItemText(GetSystemString(3430), getInstanceL2Util().Yellow, "", true));

		// 설명 desc 
		addToolTipDrawList(m_Tooltip, addDrawItemText(desc, getInstanceL2Util().ColorDesc, "", true));
		AddTooltipItemBlank(10);

		// 배치 비용
		addToolTipDrawList(m_Tooltip, addDrawItemText(GetSystemString(3442), getInstanceL2Util().ColorYellow, "", true, true));

		// 배치 비용, 주로 아데나 또는 토큰
		for (i = 0; i < totalCnt; i++)
		{			
			ParseInt(toolTipParam, "item_"  $ String(i), nItemID);
			ParseINT64(toolTipParam, "count_" $ String(i), nItemCount);

			addToolTipDrawList(m_Tooltip, addDrawItemBlank(5));
			addToolTipDrawList(m_Tooltip, addDrawItemText(class'UIDATA_ITEM'.static.GetItemName( GetItemID(nItemID) ), getInstanceL2Util().White, "", true, true));
			addToolTipDrawList(m_Tooltip, addDrawItemText("x" @ MakeCostString(String(nItemCount)), getInstanceL2Util().White, "", true, true));
			//Debug("툴팁비용 nItemID " @ nItemID);
			//Debug("툴팁비용 nItemCount" @ nItemCount);
		}
		if (totalCnt <= 0)
		{
			addToolTipDrawList(m_Tooltip, addDrawItemText(GetSystemString(27), getInstanceL2Util().White, "", true, true));
		}

		addToolTipDrawList(m_Tooltip, addDrawItemBlank(10));

		// 배치 기간
		addToolTipDrawList(m_Tooltip, addDrawItemText(GetSystemString(3431), getInstanceL2Util().ColorYellow, "", true));
		addToolTipDrawList(m_Tooltip, addDrawItemText(MakeFullSystemMsg(GetSystemMessage(3418), String(period)), getInstanceL2Util().White, "", true));

		//addToolTipDrawList(m_Tooltip, addDrawItemText(getStringDayAndTime(period), getInstanceL2Util().White, "", true));
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// 집혼 옵션 - 리스트 - 옵션 타입 nReserved1 에 저장된걸 이용해서 리스트의 툴팁을 보여줌.
function ReturnTooltip_NTT_EnsoulOptionList (string param, ETooltipSourceType eSourceType)
{	
	local EnsoulOptionUIInfo optionInfo;
	local LVDataRecord record;
	local int optionID;

	if (eSourceType == NTST_LIST)
	{
		ParamToRecord( param, record );

		optionID   = record.LVDataList[0].nReserved2;

		if (optionID > 0)
		{
			GetEnsoulOptionUIInfo(optionID, optionInfo);

			addToolTipDrawList(m_Tooltip, addDrawItemTexture(optionInfo.IconPanelTex, false, false, 2));
			addToolTipDrawList(m_Tooltip, addDrawItemTexture(optionInfo.IconTex, false, false, -16));
			addToolTipDrawList(m_Tooltip, addDrawItemText("", getInstanceL2Util().White, "", false,,4,2));

			if (optionInfo.OptionStep > 0)
			{
				addToolTipDrawList(m_Tooltip, addDrawItemText(MakeFullSystemMsg(GetSystemMessage(4347), 
															  optionInfo.Name, string(optionInfo.OptionStep)), 
															  getInstanceL2Util().White, "", false));
			}
			else

			{
				addToolTipDrawList(m_Tooltip, addDrawItemText(optionInfo.Name, getInstanceL2Util().White, "", false));
			}

			addToolTipDrawList(m_Tooltip, addDrawItemText(" : ", getInstanceL2Util().White , "", false));
			addToolTipDrawList(m_Tooltip, addDrawItemText(optionInfo.desc, getInstanceL2Util().ColorDesc , "", false));
			addToolTipDrawList(m_Tooltip, addDrawItemBlank(1));
		}
		else
		{
			addToolTipDrawList(m_Tooltip, addDrawItemText(record.LVDataList[0].szData, getInstanceL2Util().White, "", false,,4,2));
		}
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// 판매 대행 - 리스트 아이템 툴팁 
function ReturnTooltip_NTT_SellItemList (string param, ETooltipSourceType eSourceType)
{
	if (eSourceType == NTST_LIST)
	{
		// 판매 리스트에서 인벤토리 형태의 툴팁을 보여준다	
		ReturnTooltip_NTT_ITEM(param, "SellItemList", NTST_ITEM);		
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// PLEDGEINFO
function ReturnTooltip_NTT_CLANWARINFO(string param, ETooltipSourceType eSourceType)
{
	local LVDataRecord record;
	
	local int Width1;
	local int Width2;
	local int Height;
	local int toolTipLineCount;

	toolTipLineCount = 0;

	if (eSourceType == NTST_LIST)
	{
		ParamToRecord( param, record );
		//m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH;
		//Width결정!

		GetTextSizeDefault(getWarSituationString(record.LVDataList[2].nReserved1), Width1, Height);
		GetTextSizeDefault(GetSystemString(2968) $ record.LVDataList[4].nReserved1, Width2, Height);
		if (Width2>Width1)
			Width1 = Width2;
		if (TOOLTIP_MINIMUM_WIDTH>Width1)
			Width1 = TOOLTIP_MINIMUM_WIDTH;
		m_Tooltip.MinimumWidth = Width1;

		

		// 전쟁 조건이 있을때만
		if(record.LVDataList[5].nReserved1 > 0)
		{
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.bLineBreak = true;	
			//남은 시간
			m_Info.t_strText = GetSystemString(1108) $ ":" $ getSecToDateStr(record.LVDataList[6].nReserved1, false);
			EndItem();
			toolTipLineCount++;
		
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.bLineBreak = true;	
			//전쟁 조건
			m_Info.t_strText = GetSystemString(2986) $ ":" $ record.LVDataList[5].nReserved1 $ GetSystemString(1013);
			EndItem();
			toolTipLineCount++;
		}
		else
		{		
			// 0,1,2,3,4 
			// 전쟁 상황 , 매우 우세, 열세 같은.. 값이 없다면 툴팁 표현 안함
			if (record.LVDataList[2].nReserved1 < 5)
			{
				StartItem();
				m_Info.eType = DIT_TEXT;
				m_Info.bLineBreak = true;		
				m_Info.t_color.R = 220;
				m_Info.t_color.G = 220;
				m_Info.t_color.B = 220;
				m_Info.t_color.A = 255;
				m_Info.t_strText = getWarSituationString(record.LVDataList[2].nReserved1);
				EndItem();
				toolTipLineCount++;
			}
			
			// 남은시간 -> 점수표시
			if (record.LVDataList[3].nReserved1 > -500)
			{
				StartItem();
				m_Info.eType = DIT_TEXT;
				m_Info.bLineBreak = true;
				m_Info.t_color.R = 175;
				m_Info.t_color.G = 152;
				m_Info.t_color.B = 120;
				m_Info.t_color.A = 255;
				//최근점수변동:점수
				m_Info.t_strText = GetSystemString(2968) $ record.LVDataList[4].nReserved1;
				EndItem();
				toolTipLineCount++;
			}
		}
		// 툴팁을 만들지 않았다면.. 나오지 않는다
		if (toolTipLineCount == 0)
		{
			return;
		}
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

//선준 수정(2010.03.30) 완료
function ReturnTooltip_NTT_POSTINFO(string param, ETooltipSourceType eSourceType)
{
	local LVDataRecord record;
	
	if (eSourceType == NTST_LIST)
	{
		ParamToRecord( param, record );

		//ex) "직업 : 엘븐메이지"
		AddTooltipItemOption(391, GetClassType(int(record.LVDataList[1].szData)), true, true, true);
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}


//선준 수정(2010.02.22 ~ 03.08) 완료
/////////////////////////////////////////////////////////////////////////////////
// ROOMLIST
function ReturnTooltip_NTT_ROOMLIST(string param, ETooltipSourceType eSourceType)
{
	local int i;
	local LVDataRecord record;
	local int len;
	
	m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH + 30;

	if (eSourceType == NTST_LIST)
	{
		ParamToRecord( param, record );
		
		len = int( record.LVDataList[5].szData );

		for( i = 0 ; i < len ; i++ )
		{
			StartItem();
			m_Info.eType = DIT_TEXTURE;
			m_Info.u_nTextureWidth = 11;
			m_Info.u_nTextureHeight = 11;
			m_Info.u_strTexture = GetClassRoleIconName( record.LVDataList[7 + i].nReserved1 );
			EndItem();

			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.t_bDrawOneLine = false;
			m_Info.t_color.R = 163;
			m_Info.t_color.G = 163;
			m_Info.t_color.B = 163;
			m_Info.t_color.A = 255;
			m_Info.t_strText = " " $ record.LVDataList[7 + i].szData;
			EndItem();
			if( i != len - 1 )
			{
				AddTooltipItemBlank(2);
			}
		}

		//ex) "직업 : 엘븐메이지"
		//AddTooltipItemOption(391, GetClassType(int(record.LVDataList[2].szData)), true, true, true);
	}
	else
	{
		return;
	}

	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// PrivateShopHistory
function ReturnTooltip_NTT_PrivateShopHistory(string param )
{
	local LVDataRecord record;
	
	//m_Tooltip.MinimumWidth = 440;
	
	ParamToRecord( param, record );		
	
	if ( record.szReserved == "" ) return;
	//ex)귀속 지역 : 
	StartItem();
	m_Info.eType = DIT_TEXT;
	m_Info.t_color.R = int (Record.nReserved1);
	m_Info.t_color.G = int (Record.nReserved2);
	m_Info.t_color.B = int (Record.nReserved3);
	m_Info.t_color.A = 255 ;
	
	//Debug ("ReturnTooltip_NTT_PrivateShopHistory" @ m_Info.t_color.R @ m_Info.t_color.G @ m_Info.t_color.B);
	//m_Info.t_color = Record.LVDataList[0].textColor ;
	//Debug ( "ReturnTooltip_NTT_PrivateShopHistory" @ m_Info.t_color @ Record.LVDataList[0].textColor ) ;
	m_Info.t_strText = record.szReserved ;
	EndItem();
	
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// USERLIST
function ReturnTooltip_NTT_USERLIST(string param, ETooltipSourceType eSourceType)
{
	local LVDataRecord record;
	
	m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH + 70;

	if (eSourceType == NTST_LIST)
	{
		ParamToRecord( param, record );
		
		//ex) "직업 : 엘븐메이지"
		AddTooltipItemOption(391, GetClassType(int(record.LVDataList[1].szData)), true, true, true);
		
		AddTooltipItemBlank(0);
		//ex)귀속 지역 : 
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_color.R = 163;
		m_Info.t_color.G = 163;
		m_Info.t_color.B = 163;
		m_Info.t_color.A = 255;
		m_Info.t_strText = GetSystemString( 2276 ) $ " : ";
		EndItem();
		
		//설명
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_color.R = 176;
		m_Info.t_color.G = 155;
		m_Info.t_color.B = 121;
		m_Info.t_color.A = 255;
		if( record.LVDataList[4].szData == "" )
		{			
			m_Info.t_strText = GetSystemString( 27 );
		}
		else
		{			
			m_Info.t_strText = record.LVDataList[4].szData;
		}
		EndItem();
		
		
	}
	else
	{
		return;
	}
	
	
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// PARTYMATCH
function ReturnTooltip_NTT_PARTYMATCH(string param, ETooltipSourceType eSourceType)
{
	local LVDataRecord record;
	
	m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH + 70;

	if (eSourceType == NTST_LIST)
	{
		ParamToRecord( param, record );
		
		//ex) "직업 : 엘븐메이지"
		AddTooltipItemOption(391, GetClassType(int(record.LVDataList[1].szData)), true, true, true);
		
		//선준 수정(2010.02.22 ~ 03.08) 완료
		//ex)현재 위치 : 글루디오
		//AddTooltipItemOption(471, GetZoneNameWithZoneID(int(record.LVDataList[3].szData)), true, true, true);
		
		/*
		AddTooltipItemBlank(0);
		//귀속지역
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = false;
		m_Info.t_color.R = 163;
		m_Info.t_color.G = 163;
		m_Info.t_color.B = 163;
		m_Info.t_color.A = 255;
		m_Info.t_strText = GetSystemString( 2276 ) @ ":";
		EndItem();		
		
		//설명
		
		StartItem();
		m_Info.eType = DIT_TEXT;		
		m_Info.t_color.R = 176;
		m_Info.t_color.G = 155;
		m_Info.t_color.B = 121;
		m_Info.t_color.A = 255;
		if( record.LVDataList[4].szData == "" )
		{
			//m_Info.bLineBreak = true;
			m_Info.t_strText = "" @ GetSystemString( 27 );
		}
		else
		{
			m_Info.bLineBreak = true;
			m_Info.t_strText = record.LVDataList[4].szData;
		}
		EndItem();
		*/

		
		AddTooltipItemBlank(0);
		//ex)귀속 지역 : 
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_color.R = 163;
		m_Info.t_color.G = 163;
		m_Info.t_color.B = 163;
		m_Info.t_color.A = 255;
		m_Info.t_strText = GetSystemString( 2276 ) $ " : ";
		//m_Info.t_strText = "귀속 지역 : ";
		EndItem();
		
		//설명
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_color.R = 176;
		m_Info.t_color.G = 155;
		m_Info.t_color.B = 121;
		m_Info.t_color.A = 255;
		if( record.LVDataList[3].szData == "" )
		{			
			m_Info.t_strText = GetSystemString( 27 );
		}
		else
		{			
			m_Info.t_strText = record.LVDataList[3].szData;
		}
		EndItem();
		
		
	}
	else
	{
		return;
	}
	
	
	ReturnTooltipInfo(m_Tooltip);
}

//선준 추가 UNION 예전 직업만 나오는 경우.
/////////////////////////////////////////////////////////////////////////////////
// UINONLIST
function ReturnTooltip_NTT_UNIONLIST(string param, ETooltipSourceType eSourceType)
{
	local LVDataRecord record;
	
	if (eSourceType == NTST_LIST)
	{
		ParamToRecord( param, record );
		
		//ex) "직업 : 엘븐메이지"
		AddTooltipItemOption(391, GetClassType(int(record.LVDataList[1].szData)), true, true, true);
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}


/////////////////////////////////////////////////////////////////////////////////
// QUESTLIST
function ReturnTooltip_NTT_QUESTLIST(string param, ETooltipSourceType eSourceType)
{
	local LVDataRecord record;
	
	local int nTmp;
	
	if (eSourceType == NTST_LIST)
	{
		ParamToRecord( param, record );
		
		//퀘스트 이름
		AddTooltipItemOption(1200, record.LVDataList[0].szData, true, true, true);
		
		//반복성
		switch(record.LVDataList[3].nReserved1)
		{
		case 0:
		case 2:
			nTmp = 861;
			break;
		case 1:
		case 3:
			nTmp = 862;
			break;
		}
		AddTooltipItemOption2(1202, nTmp, true, true, false);
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// RAIDLIST
function ReturnTooltip_NTT_RAIDLIST(string param, ETooltipSourceType eSourceType)
{
	local LVDataRecord record;
	
	if (eSourceType == NTST_LIST)
	{
		ParamToRecord( param, record );
		
		if (Len(record.szReserved)<1)
			return;
		
		m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH;
		
		//레이드 설명
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = false;
		m_Info.t_color.R = 178;
		m_Info.t_color.G = 190;
		m_Info.t_color.B = 207;
		m_Info.t_color.A = 255;
		m_Info.t_strText = record.szReserved;
		EndItem();
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// QUESTINFO
function ReturnTooltip_NTT_QUESTINFO(string param, ETooltipSourceType eSourceType)
{
	local LVDataRecord record;
	
	local int nTmp;
	local int Width1;
	local int Width2;
	local int Height;
		
	if (eSourceType == NTST_LIST)
	{
		ParamToRecord( param, record );
		
		//퀘스트 이름
		AddTooltipItemOption(1200, record.LVDataList[0].szData, true, true, true);
		
		//수행조건
		AddTooltipItemOption(1201, record.LVDataList[1].szData, true, true, false);
		
		//Width결정!
		GetTextSizeDefault(GetSystemString(1200) $ " : " $ record.LVDataList[0].szData, Width1, Height);
		GetTextSizeDefault(GetSystemString(1201) $ " : " $ record.LVDataList[1].szData, Width2, Height);
		if (Width2>Width1)
			Width1 = Width2;
		if (TOOLTIP_MINIMUM_WIDTH>Width1)
			Width1 = TOOLTIP_MINIMUM_WIDTH;
		m_Tooltip.MinimumWidth = Width1 + 30;
		
		//추천레벨
		AddTooltipItemOption(922, record.LVDataList[2].szData, true, true, false);
		
		//반복성
		switch(record.LVDataList[3].nReserved1)
		{
		case 0:
		case 2:
			nTmp = 861;
			break;
		case 1:
		case 3:
			nTmp = 862;
			break;
		}
		AddTooltipItemOption2(1202, nTmp, true, true, false);
		
		//퀘스트설명
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
		m_Info.t_bDrawOneLine = false;
		m_Info.bLineBreak = true;
		m_Info.t_color.R = 178;
		m_Info.t_color.G = 190;
		m_Info.t_color.B = 207;
		m_Info.t_color.A = 255;
		m_Info.t_strText = record.szReserved;
		EndItem();
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// MANOR
function ReturnTooltip_NTT_MANOR(string param, string TooltipType, ETooltipSourceType eSourceType)
{
	local LVDataRecord record;
	
	local int idx1;
	local int idx2;
	local int idx3;
	
	if (eSourceType == NTST_LIST)
	{
		ParamToRecord( param, record );
		
		if (TooltipType == "ManorSeedInfo")
		{
			idx1 = 4;
			idx2 = 5;
			idx3 = 6;
		}
		else if (TooltipType == "ManorCropInfo")
		{
			idx1 = 5;
			idx2 = 6;
			idx3 = 7;
		}
		else if (TooltipType == "ManorSeedSetting")
		{
			idx1 = 7;
			idx2 = 8;
			idx3 = 9;
		}
		else if (TooltipType == "ManorCropSetting")
		{
			idx1 = 9;
			idx2 = 10;
			idx3 = 11;
		}
		else if (TooltipType == "ManorDefaultInfo")
		{
			idx1 = 1;
			idx2 = 4;
			idx3 = 5;
		}
		else if (TooltipType == "ManorCropSell")
		{
			idx1 = 7;
			idx2 = 8;
			idx3 = 9;
		}
		
		// 씨앗 or 작물 이름
		AddTooltipItemOption(0, record.LVDataList[0].szData, false, true, true);
		
		// 레벨
		AddTooltipItemOption(537, record.LVDataList[idx1].szData, true, true, false);

		// 보상 타입1
		AddTooltipItemOption(1134, record.LVDataList[idx2].szData, true, true, false);
		
		// 보상 타입2
		AddTooltipItemOption(1135, record.LVDataList[idx3].szData, true, true, false);
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

// [퀘스트 아이템 툴팁 추가]
function ReturnTooltip_NTT_QUESTREWARDS(string param, ETooltipSourceType eSourceType)
{
	// [퀘스트 아이템 툴팁 추가] 이 부분에 퀘스트 아이템 툴팁에 걸맞는 코드가 들어가면 될 것 같습니다.
	// 2009.10.14
	// ReturnTooltip_NTT_ITEM(param, "Inventoty", eSourceType);
	ReturnTooltip_NTT_ITEM(param, "QuestReward", eSourceType);
}

//아이템의 색상을 다시 설정해준다.
function SetTooltipItemColor(int R, int G, int B, int Offset)
{
	local int idx;
	idx = m_Tooltip.DrawList.Length-1-Offset;
	m_Tooltip.DrawList[idx].t_color.R = R;
	m_Tooltip.DrawList[idx].t_color.G = G;
	m_Tooltip.DrawList[idx].t_color.B = B;
	m_Tooltip.DrawList[idx].t_color.A = 255;
}

//인첸트(선준 색상 변경)
function int AddTooltipItemEnchant(ItemInfo Item, optional bool bFirstLineWidthCount, optional string fontName, optional int offsetX, optional int offsetY)
{
	local int nSumWidth, sizeWidth, sizeHeight;
	local EItemParamType eItemParamType;
	
	eItemParamType = EItemParamType(Item.ItemType);
	if (Item.Enchanted>0 && IsEnchantableItem(eItemParamType))
	{
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = true;
		//m_Info.t_color.R = 176;
		//m_Info.t_color.G = 155;
		//m_Info.t_color.B = 121;
		//m_Info.t_color.A = 255;
		m_Info.t_color.R = 170;
		m_Info.t_color.G = 110;
		m_Info.t_color.B = 230;
		m_Info.t_color.A = 255;
		m_Info.t_strText = "+" $ Item.Enchanted;//$ " ";

		m_Info.nOffSetX = m_Info.nOffSetX + offsetX;
		m_Info.nOffSetY = m_Info.nOffSetY + offsetY;
		m_Info.t_strFontName = fontName;

		EndItem();

		GetTextSizeDefault(m_Info.t_strText, sizeWidth, sizeHeight);
		nSumWidth = nSumWidth + sizeWidth; 
	}	

	return nSumWidth;
}

//아이템 이름 + AdditionalName
function AddTooltipItemName(string Name, ItemInfo Item, int AddTooltipItemName, optional string fontName, optional int offsetX, optional int offsetY)
{
	local string tmStr;

	StartItem();
	m_Info.eType = DIT_TEXT;
	m_Info.t_bDrawOneLine = true;
	switch (AddTooltipItemName)
	{
		case 0: //회색
		m_Info.t_color.R = 137;
		m_Info.t_color.G = 137;
		m_Info.t_color.B = 137;
		m_Info.t_color.A = 255;
		break;
		case 1: //흰색
		m_Info.t_color.R = 255;
		m_Info.t_color.G = 255;
		m_Info.t_color.B = 255;
		m_Info.t_color.A = 255;
		break;
		case 2: //노랑
		m_Info.t_color.R = 255;
		m_Info.t_color.G = 251;
		m_Info.t_color.B = 4;
		m_Info.t_color.A = 255;
		break;
		case 3: //빨강
		m_Info.t_color.R = 240;
		m_Info.t_color.G = 68;
		m_Info.t_color.B = 68;
		m_Info.t_color.A = 255;
		break;
		case 4: //파랑
		m_Info.t_color.R = 33;
		m_Info.t_color.G = 164;
		m_Info.t_color.B = 255;
		m_Info.t_color.A = 255;
		break;
		case 5: //보라
		m_Info.t_color.R = 255;
		m_Info.t_color.G = 0;
		m_Info.t_color.B = 255;
		m_Info.t_color.A = 255;
		break;
	}

	m_Info.nOffSetX = m_Info.nOffSetX + offsetX;
	m_Info.nOffSetY = m_Info.nOffSetY + offsetY;

	m_Info.t_strText = Name;
	m_Info.t_strFontName = fontName;

	EndItem();
	
	//Additional Name
	if (Len(Item.AdditionalName)>0)
	{
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_color.R = 255;
		m_Info.t_color.G = 217;
		m_Info.t_color.B = 105;
		m_Info.t_color.A = 255;
		m_Info.nOffSetX = m_Info.nOffSetX + offsetX;
		m_Info.nOffSetY = m_Info.nOffSetY + offsetY;

		m_Info.t_strFontName = fontName;
		m_Info.t_strText = " " $ Item.AdditionalName;
		EndItem();
	}

	// 집혼 이름 
	tmStr = GetEnsoulOptionNameAll(Item);

	if (Len(tmStr) > 0)
	{
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_color.R = 255;
		m_Info.t_color.G = 217;
		m_Info.t_color.B = 105;
		m_Info.t_color.A = 255;
		m_Info.nOffSetX = m_Info.nOffSetX + offsetX;
		m_Info.nOffSetY = m_Info.nOffSetY + offsetY;
		m_Info.t_strFontName = fontName;
		m_Info.t_strText = " " $ tmStr;
		EndItem();		
	}
}

//Grade Mark
function AddTooltipItemGrade(ItemInfo Item, optional int offsetX, optional int offsetY)
{
	local string TextureName;

	TextureName = GetItemGradeTextureName(Item.CrystalType);
	//debug ("TextureName" @ TextureName);
	//debug ("---->>>   " $ TextureName @  Item.CrystalType @ GetItemGradeTextureName(Item.CrystalType));
	if( Len(TextureName) > 0 )
	{
		StartItem();

		m_Info.eType = DIT_TEXTURE;
		m_Info.u_strTexture = TextureName;

		m_Info.nOffSetX = m_Info.nOffSetX + offsetX + 8;
		m_Info.nOffSetY = m_Info.nOffSetY + offsetY;

		//m_Info.nOffSetX = 8;
		//m_Info.nOffSetY = 0;
		
		// S80 그레이드일 경우에 한해 아이콘 텍스쳐 크기를 2배로 늘린다. 6, 7
		// R95, R99 그레이드일 경우에 한해 아이콘 텍스쳐 크기를 2배로 늘린다. 9, 10
		m_Info.u_nTextureHeight = 16;
		m_Info.u_nTextureUHeight = 16;
		if( Item.CrystalType == CrystalType.CRT_S80 || Item.CrystalType == CrystalType.CRT_S84 || Item.CrystalType == CrystalType.CRT_R95 || Item.CrystalType == CrystalType.CRT_R99 )
		{
			m_Info.u_nTextureWidth = 32;
			m_Info.u_nTextureUWidth = 32;
		}
		else
		{	
			m_Info.u_nTextureWidth = 16;
			m_Info.u_nTextureUWidth = 16;
		}

		EndItem();

//		nSumWidth = nSumWidth + m_Info.nOffSetX + m_Info.u_nTextureWidth; 쓰이지 않는 것 같아 삭제
	}

//	return nSumWidth;
}

//Stackable Count
function AddTooltipItemCount(ItemInfo Item, optional int offsetX, optional int offsetY)
{
	if (IsStackableItem(Item.ConsumeType))
	{
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_strText = " (" $ MakeCostString(String(Item.ItemNum)) $ ")";
		m_Info.nOffSetX = m_Info.nOffSetX + offsetX;
		m_Info.nOffSetY = m_Info.nOffSetY + offsetY;
		m_Info.t_color.R = 176;
		m_Info.t_color.G = 155;
		m_Info.t_color.B = 121;
		m_Info.t_color.A = 255;
		EndItem();
	}	
}

//제련 색상
function GetRefineryColor(int Quality, out int R, out int G, out int B)
{
	switch (Quality)
	{
		case 1:
			R = 187;
			G = 181;
			B = 138;
		break;
		case 2:
			R = 132;
			G = 174;
			B = 216;
		break;
		case 3:
			R = 193;
			G = 112;
			B = 202;
		break;
		case 4:
			R = 225;
			G = 109;
			B = 109;
		break;
		default:
			R = 187;
			G = 181;
			B = 138;
		break;
	}
}

//속성 게이지 그려주기
function AddTooltipItemAttributeGage(ItemInfo Item)
{
	local int i;
	//local int highAttrValue[6];
	local Array<string> textureName, tooltipStr;
	
	for(i = 0; i < 6; i++)
	{
		textureName[i] = "";
		tooltipStr[i] = "";
	}
	
	NowAttrLv =0;
	NowMaxValue =0;
	NowValue =0;

	//Debug ( " !! Attribute "  @ Item.AttackAttributeValue );
	// 공격 아이템 속성
	if (Item.AttackAttributeValue  > 0)
	{	
		AddCrossLine();
		SetAttackAttribute(Item.AttackAttributeValue,ATTRIBUTE_FIRE);
		SetAttackAttribute(Item.AttackAttributeValue,ATTRIBUTE_WATER);
		SetAttackAttribute(Item.AttackAttributeValue,ATTRIBUTE_WIND);
		SetAttackAttribute(Item.AttackAttributeValue,ATTRIBUTE_EARTH);
		SetAttackAttribute(Item.AttackAttributeValue,ATTRIBUTE_HOLY);
		SetAttackAttribute(Item.AttackAttributeValue,ATTRIBUTE_UNHOLY); //레벨과 현제값등을 구한다.		

		switch(Item.AttackAttributeType)
		{
			case ATTRIBUTE_FIRE:
				//AddCrossLine();
				textureName[ATTRIBUTE_FIRE] = "L2UI_CT1.Gauges.Gauge_DF_Attribute_FIRE";
				tooltipStr[ATTRIBUTE_FIRE] =GetSystemString(1622) $ " Lv " $ String(AttackAttLevel[ATTRIBUTE_FIRE]) $ " ("$ GetSystemString(1622) $ " " $ GetSystemString(55) $ " " $ String(Item.AttackAttributeValue) $")";
				break;
			case ATTRIBUTE_WATER:
				//AddCrossLine();
				textureName[ATTRIBUTE_WATER] = "L2UI_CT1.Gauges.Gauge_DF_Attribute_WATER";
				tooltipStr[ATTRIBUTE_WATER] =GetSystemString(1623) $ " Lv " $ String(AttackAttLevel[ATTRIBUTE_WATER]) $ " ("$ GetSystemString(1623) $ " " $ GetSystemString(55) $ " " $String(Item.AttackAttributeValue) $ ")";
				break;
			case ATTRIBUTE_WIND:
				//AddCrossLine();
				textureName[ATTRIBUTE_WIND] = "L2UI_CT1.Gauges.Gauge_DF_Attribute_WIND";
				tooltipStr[ATTRIBUTE_WIND] =GetSystemString(1624) $ " Lv " $ String(AttackAttLevel[ATTRIBUTE_WIND]) $ " ("$ GetSystemString(1624) $ " " $ GetSystemString(55) $ " " $String(Item.AttackAttributeValue) $ ")";
				break;
			case ATTRIBUTE_EARTH:
				//AddCrossLine();
				textureName[ATTRIBUTE_EARTH] = "L2UI_CT1.Gauges.Gauge_DF_Attribute_EARTH";
				tooltipStr[ATTRIBUTE_EARTH] =GetSystemString(1625) $ " Lv " $ String(AttackAttLevel[ATTRIBUTE_EARTH]) $ " ("$ GetSystemString(1625) $ " " $ GetSystemString(55) $ " " $ String(Item.AttackAttributeValue) $")";
				break;
			case ATTRIBUTE_HOLY:
				//AddCrossLine();
				textureName[ATTRIBUTE_HOLY] = "L2UI_CT1.Gauges.Gauge_DF_Attribute_DIVINE";
				tooltipStr[ATTRIBUTE_HOLY] =GetSystemString(1626) $ " Lv " $ String(AttackAttLevel[ATTRIBUTE_HOLY]) $ " ("$ GetSystemString(1626) $ " " $ GetSystemString(55) $ " " $String(Item.AttackAttributeValue) $ ")";
				break;
			case ATTRIBUTE_UNHOLY:
				//AddCrossLine();
				textureName[ATTRIBUTE_UNHOLY] = "L2UI_CT1.Gauges.Gauge_DF_Attribute_DARK";
				tooltipStr[ATTRIBUTE_UNHOLY] =GetSystemString(1627) $ " Lv " $ String(AttackAttLevel[ATTRIBUTE_UNHOLY]) $ " ("$ GetSystemString(1627) $ " " $ GetSystemString(55) $ " " $String(Item.AttackAttributeValue) $ ")";
				break;
		}
	}
	else	// 방어 아이템 속성
	{
		SetDefAttribute(Item.DefenseAttributeValueFire,ATTRIBUTE_FIRE);
		SetDefAttribute(Item.DefenseAttributeValueWater,ATTRIBUTE_WATER);
		SetDefAttribute(Item.DefenseAttributeValueWind,ATTRIBUTE_WIND);
		SetDefAttribute(Item.DefenseAttributeValueEarth,ATTRIBUTE_EARTH);
		SetDefAttribute(Item.DefenseAttributeValueHoly,ATTRIBUTE_HOLY);
		SetDefAttribute(Item.DefenseAttributeValueUnholy,ATTRIBUTE_UNHOLY); //레벨과 현제값등을 구한다.

		if(Item.DefenseAttributeValueFire != 0) //파이어 속성 툴팁 그리기
		{
			if( BLine == false )
			{
				AddCrossLine();
				BLine = true;
			}
			textureName[ATTRIBUTE_FIRE] = "L2UI_CT1.Gauges.Gauge_DF_Attribute_FIRE";
			tooltipStr[ATTRIBUTE_FIRE] =GetSystemString(1623) $ " Lv " $ String(DefAttLevel[ATTRIBUTE_FIRE]) $ " ("$ GetSystemString(1622) $ " " $ GetSystemString(54) $ " " $ String(Item.DefenseAttributeValueFire) $")";
		}
		if(Item.DefenseAttributeValueWater != 0) //물 속성 툴팁 그리기
		{
			if( BLine == false )
			{
				AddCrossLine();
				BLine = true;
			}
			textureName[ATTRIBUTE_WATER] = "L2UI_CT1.Gauges.Gauge_DF_Attribute_WATER";
			tooltipStr[ATTRIBUTE_WATER] =GetSystemString(1622) $ " Lv " $ String(DefAttLevel[ATTRIBUTE_WATER]) $ " ("$ GetSystemString(1623) $ " " $ GetSystemString(54) $ " " $String(Item.DefenseAttributeValueWater) $ ")";
		}
		if(Item.DefenseAttributeValueWind != 0) //바람 속성 툴팁 그리기
		{
			if( BLine == false )
			{
				AddCrossLine();
				BLine = true;
			}
			textureName[ATTRIBUTE_WIND] = "L2UI_CT1.Gauges.Gauge_DF_Attribute_WIND";
			tooltipStr[ATTRIBUTE_WIND] =GetSystemString(1625) $ " Lv " $ String(DefAttLevel[ATTRIBUTE_WIND]) $ " ("$ GetSystemString(1624) $ " " $ GetSystemString(54) $ " " $String(Item.DefenseAttributeValueWind) $")";
		}
		if(Item.DefenseAttributeValueEarth != 0) //땅 속성 툴팁 그리기
		{
			if( BLine == false )
			{
				AddCrossLine();
				BLine = true;
			}
			textureName[ATTRIBUTE_EARTH] = "L2UI_CT1.Gauges.Gauge_DF_Attribute_EARTH";
			tooltipStr[ATTRIBUTE_EARTH] =GetSystemString(1624) $ " Lv " $ String(DefAttLevel[ATTRIBUTE_EARTH]) $ " ("$ GetSystemString(1625) $ " " $ GetSystemString(54) $ " " $String(Item.DefenseAttributeValueEarth) $ ")";
		}
		if(Item.DefenseAttributeValueHoly != 0) //신성 속성 툴팁 그리기
		{
			if( BLine == false )
			{
				AddCrossLine();
				BLine = true;
			}
			textureName[ATTRIBUTE_HOLY] = "L2UI_CT1.Gauges.Gauge_DF_Attribute_DIVINE";
			tooltipStr[ATTRIBUTE_HOLY] =GetSystemString(1627) $ " Lv " $ String(DefAttLevel[ATTRIBUTE_HOLY]) $ " ("$ GetSystemString(1626) $ " " $ GetSystemString(54) $ " " $ String(Item.DefenseAttributeValueHoly) $")";
		}
		if(Item.DefenseAttributeValueUnholy != 0) //암흑 속성 툴팁 그리기
		{
			if( BLine == false )
			{
				AddCrossLine();
				BLine = true;
			}
			textureName[ATTRIBUTE_UNHOLY] = "L2UI_CT1.Gauges.Gauge_DF_Attribute_DARK";
			tooltipStr[ATTRIBUTE_UNHOLY] =GetSystemString(1626) $ " Lv " $ String(DefAttLevel[ATTRIBUTE_UNHOLY]) $ " ("$ GetSystemString(1627) $ " " $ GetSystemString(54) $ " " $String(Item.DefenseAttributeValueUnholy) $ ")";
		}
		// 방어 아이템 속성
		BLine = false;
	}

	if (Item.AttackAttributeValue  > 0)//공격속성일경우
	{
		for(i = 0; i < 6; i++)
		{
			if(tooltipStr[i] == "") continue;			
			StartItem();
			m_Info.eType = DIT_TEXT;
			if (i == 0) m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
			else m_Info.nOffSetY = 10;
			m_Info.bLineBreak = true;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_strText = tooltipStr[i];
			EndItem();
			
			// 속성 아이콘 
			//addTooltipTexture(GetAttributeIcon(i),16,16, 13,13, true, false, 2,2);

			//텍스쳐 두장을 겹쳐 그려야 한다. 
			StartItem();
			m_Info.eType = DIT_TEXTURE;
			m_Info.bLineBreak = true;
			m_Info.t_bDrawOneLine = true;
			m_Info.nOffSetX = 0;
			m_Info.nOffSetY = 2;
			m_Info.u_nTextureWidth = 140;
			m_Info.u_nTextureHeight = 7;
			m_Info.u_strTexture = textureName[i] $ "_BG";
			EndItem();
			
			StartItem();
			m_Info.eType = DIT_TEXTURE;
			m_Info.bLineBreak = true;
			m_Info.t_bDrawOneLine = true;
			m_Info.nOffSetX = 0;
			m_Info.nOffSetY = -7;
			m_Info.u_nTextureWidth = AttackAttCurrValue[i] * 140 / AttackAttMaxValue[i] ;
			if( m_Info.u_nTextureWidth > 140) m_Info.u_nTextureWidth = 140;	//넘어가면 걍 140이라는.. ㅋ
			m_Info.u_nTextureHeight = 7;
			m_Info.u_strTexture = textureName[i];
			EndItem();
		}
	
	}
	else{ //방어 속성일 경우
		for(i = 0; i < 6; i++)
		{
			if(tooltipStr[i] == "") continue;			
			StartItem();
			m_Info.eType = DIT_TEXT;
			if (i == 0) m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
			else m_Info.nOffSetY = 10;

			m_Info.bLineBreak = true;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_strText = tooltipStr[i];
			EndItem();
			
			//텍스쳐 두장을 겹쳐 그려야 한다. 
			StartItem();
			m_Info.eType = DIT_TEXTURE;
			m_Info.bLineBreak = true;
			m_Info.t_bDrawOneLine = true;
			m_Info.nOffSetX = 0;
			m_Info.nOffSetY = 2;
			m_Info.u_nTextureWidth = 140;
			m_Info.u_nTextureHeight = 7;
			m_Info.u_strTexture = textureName[i] $ "_BG";
			EndItem();
			
			StartItem();
			m_Info.eType = DIT_TEXTURE;
			m_Info.bLineBreak = true;
			m_Info.t_bDrawOneLine = true;
			m_Info.nOffSetX = 0;
			m_Info.nOffSetY = -7;
			
			m_Info.u_nTextureWidth = DefAttCurrValue[i] * 140 / DefAttMaxValue[i] ;
			if( m_Info.u_nTextureWidth > 140) m_Info.u_nTextureWidth = 140;	//넘어가면 걍 140이라는.. ㅋ
			m_Info.u_nTextureHeight = 7;
			m_Info.u_strTexture = textureName[i];
			EndItem();
		}
	}	
}


// 기간제 아이템, 기간제 가공 
function  AddTooltipItemCurrentPeriod(ItemInfo Item)
{
	// 기간제 아이템
	if ( Item.CurrentPeriod > 0)
	{
		//빈공간
		AddCrossLine();
		AddTooltipItemBlank(0);
		
		//<기간제 가공>
		//branch120516
		if(Item.LookChangeItemID > 0 && Item.Id.ClassID != 4442) //branch GD35_0828 2013-12-18 luciper3 - 복권이 아닌경우..
		{
			// 기간제 가공
			AddTooltipItemOption(5144, "", true, false, false);
		}
		else
		{
			// <기간제 아이템>
			AddTooltipItemOption(1739, "", true, false, false,);
		}			
		SetTooltipItemColor(255, 255, 255, 0);
		//end of branch
		
		AddTooltipItemBlank(0);
		addTexture("l2ui_ct1.SkillWnd_DF_ListIcon_use", 12, 11, 12, 11, 3, 7);
		// 남은 시간 
		AddTooltipColorText(GetSystemString(1199) $ " : ", getColor(163,163,163,255), false, true, false, "", 0, TOOLTIP_LINE_HGAP);
		
		// ParamAdd 부분 때문에 그대로 나둠.
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
		m_Info.bLineBreak = false;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_color.R = 178;
		m_Info.t_color.G = 190;
		m_Info.t_color.B = 207;
		m_Info.t_color.A = 255;
		m_Info.t_strText = MakeTimeStr(Item.CurrentPeriod);
		
		// 이걸 넣으면 툴팁 시간이 갱신 되게 되는데 문제는 bDrawOneLine을 설정 해놓아도 툴팁 가로폭에 대한 
		// 업데이트가 안되는 버그가 있다. 
		ParamAdd(m_Info.Condition, "Type", "PeriodTime");
		EndItem();
		
	}
}

// 기간제 아이템 남은 기간 : 22일 22시간 22분 기준으로 툴팁 사이즈를 설정
function setMakeTimeStrMaxWidth()
{
	local string timeStr;
	local int Width, Height ;

	//AddTooltipColorText(GetSystemString(1199) $ " : ", getColor(163,163,163,255), true, true);
	timeStr = GetSystemString(1199) $ " : " $ MakeTimeStr( 1981320 );
	
	GetTextSizeDefault(timeStr, Width, Height);

	//Debug ("setMakeTimeStrMaxWidth" @ timeStr @ Width) ;

	if ( m_Tooltip.MinimumWidth < Width )  m_Tooltip.MinimumWidth = Width;
}

//branch 110824
function AddTooltipItemWeaponLookChange(ItemInfo Item)
{
	local ItemInfo tmpInfo;

 	if(Item.LookChangeItemID > 0 && Item.Id.ClassID != 4442 ) //branch GD35_0828 2013-12-18 luciper3 - 복권이 아닌경우..
 	{
		//빈공간
		AddCrossLine();
		
		//<기간제 아이템>
		//branch 111109

		//SetTooltipTextColor( 230, 230, 230, 255 );
		//getColor(230, 230, 230, 255)
				
		if(Item.BodyPart == 25 || Item.BodyPart == 26 || Item.BodyPart == 10 ) //헤어악세서리
		{
			AddTooltipItemOption(5115, "", true, false, false,,,,getColor(230, 230, 230, 255));
		}
		else if(EItemType(Item.ItemType) == ITEM_ARMOR)
		{
			AddTooltipItemOption(5101, "", true, false, false,,,,getColor(230, 230, 230, 255));
		}		
		else
		{
			AddTooltipItemOption(5082, "", true, false, false,,,,getColor(230, 230, 230, 255));
		}		

		AddTooltipItemBlank(0);
		class'UIDATA_ITEM'.static.GetItemInfo(GetItemID(Item.LookChangeItemID), tmpInfo );		
		addItemIconSmallType(tmpInfo, "");

		AddTooltipColorText(Item.LookChangeItemName, getColor(0, 255, 0, 255), false, true, false, "", 3, 3);

		//SetTooltipItemColor(255, 255, 255, 0);
		//AddTooltipItemOption(0, Item.LookChangeItemName, false, true, false);
		//SetTooltipItemColor(0, 255, 0, 0);
	}
}
//end of branch

// function StartItem()
// {
// 	local DrawItemInfo infoClear;
// 	m_Info = infoClear;
// }
// 
// function EndItem()
// {
// 	m_Tooltip.DrawList.Length = m_Tooltip.DrawList.Length + 1;
// 	m_Tooltip.DrawList[m_Tooltip.DrawList.Length-1] = m_Info;
// }

//퀘스트 아이템의 퀘스트 이름 표시
function AddTooltipItemQuestList(ItemInfo Item)
{
	local int i, count, questType;
	local string questTypeStr;
	
	for(i = 0 ; i < MAX_RELATED_QUEST ; i++)
	{	
		// Debug("Item.RelatedQuestID[i]" @Item.RelatedQuestID[i]);
		// Debug("Item.GetQuestName[i]" @ class'UIDATA_QUEST'.static.GetQuestName(Item.RelatedQuestID[i]));
		if(Item.RelatedQuestID[i] > 0)
		{
			questTypeStr = "";
			//퀘스트 타입 (솔로, 파티, 일일, 반복 구분)			
			switch (Class'UIDATA_QUEST'.static.GetQuestIscategory( Item.RelatedQuestID[i], 1 ))
			{
				case 0:
					questTypeStr = GetSystemString(862);
					break;

				case 1:
					questType = class'UIDATA_QUEST'.static.GetQuestType(Item.RelatedQuestID[i], 1);
					if ( questType == 4 || questType == 5 )
						questTypeStr = GetSystemString( 2788 ); //일일 퀘스트 
					else 
						questTypeStr = GetSystemString(861);

					break;

				case 2: 
					questTypeStr = GetSystemString(1998);
					break;

				case 3:
					questTypeStr = GetSystemString(1999);
					break;

				case 4:
					questTypeStr = GetSystemString(2000);
					break;
			}

			if (questTypeStr != "")
			{
				questTypeStr = "[" $ questTypeStr $ "]";
			}

			if (class'UIDATA_QUEST'.static.GetQuestName(Item.RelatedQuestID[i]) != "")
			{
				//<관련 퀘스트>
				if(count == 0)
				{
					StartItem();
					m_Info.eType = DIT_TEXT;
					m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
					m_Info.bLineBreak = true;
					m_Info.t_bDrawOneLine = true;
					m_Info.t_strText = GetSystemString(1721);
					EndItem();
				}
				count++;

				AddTooltipColorText(questTypeStr @ class'UIDATA_QUEST'.static.GetQuestName(Item.RelatedQuestID[i]), getColor(163, 163, 163, 255), true, true, false,"",0, TOOLTIP_LINE_HGAP);
			}
		}
	}
}


// 속성의 레벨값을 전역변수에 저장	//자료가 많아서 전역변수에 집어넣는다. 

function SetAttackAttribute(int Attvalue, int type)
{
	if( AttValue >= 375)	// 9렙	375 ~ 450
	{
		AttackAttLevel[type] = 9;
		AttackAttMaxValue[type] = 75;
		AttackAttCurrValue[type] = AttValue - 375;
	}
	else if( AttValue >= 325)	// 8렙	325 ~ 375
	{
		AttackAttLevel[type] = 8;
		AttackAttMaxValue[type] = 50;
		AttackAttCurrValue[type] = AttValue - 325;
	}
	else if( AttValue >= 300)	// 7렙	300 ~ 325
	{
		AttackAttLevel[type] = 7;
		AttackAttMaxValue[type] = 25;
		AttackAttCurrValue[type] = AttValue - 300;
	}
	else if( AttValue >= 225)	// 6렙	225 ~ 300
	{
		AttackAttLevel[type] = 6;
		AttackAttMaxValue[type] = 75;
		AttackAttCurrValue[type] = AttValue - 225;
	}
	else if( AttValue >= 175)	// 5렙	175 ~ 225
	{
		AttackAttLevel[type] = 5;
		AttackAttMaxValue[type] = 50;
		AttackAttCurrValue[type] = AttValue - 175;
	}
	else if( AttValue >= 150)	// 4렙	150 ~ 175
	{
		AttackAttLevel[type] = 4;
		AttackAttMaxValue[type] = 25;
		AttackAttCurrValue[type] = AttValue - 150;
	}
	else if( AttValue >= 75)	// 3렙	75 ~ 150
	{
		AttackAttLevel[type] = 3;
		AttackAttMaxValue[type] = 75;
		AttackAttCurrValue[type] = AttValue - 75;
	}
	else if( AttValue >= 25)	// 2렙	25~ 75
	{
		AttackAttLevel[type] = 2;
		AttackAttMaxValue[type] = 50;
		AttackAttCurrValue[type] = AttValue - 25;
	}
	else	// else 0~ 25
	{
		AttackAttLevel[type] = 1;
		AttackAttMaxValue[type] = 25;
		AttackAttCurrValue[type] = AttValue;
	}	
}
// 속성의 레벨값을 전역변수에 저장	//자료가 많아서 전역변수에 집어넣는다. 


function SetDefAttribute(int Defvalue, int type)
{
	if( DefValue >= 150)	// 9렙		150~180
	{
		DefAttLevel[type] = 9;
		DefAttMaxValue[type] = 30;
		DefAttCurrValue[type] = DefValue - 150;
	}
	else if( DefValue >= 132)	// 8렙	132 ~ 150
	{
		DefAttLevel[type] = 8;
		DefAttMaxValue[type] = 18;
		DefAttCurrValue[type] = DefValue - 132;
	}
	else if( DefValue >= 120)	// 7렙	120 ~ 132
	{
		DefAttLevel[type] = 7;
		DefAttMaxValue[type] = 12;
		DefAttCurrValue[type] = DefValue - 120;
	}
	else if( DefValue >= 90)	// 6렙	90 ~ 120
	{
		DefAttLevel[type] = 6;
		DefAttMaxValue[type] = 30;
		DefAttCurrValue[type] = DefValue - 90;
	}
	else if( DefValue >= 72)	// 5렙	72 ~ 90
	{
		DefAttLevel[type] = 5;
		DefAttMaxValue[type] = 18;
		DefAttCurrValue[type] = DefValue - 72;
	}
	else if( DefValue >= 60)	// 4렙	60 ~ 72
	{
		DefAttLevel[type] = 4;
		DefAttMaxValue[type] = 12;
		DefAttCurrValue[type] = DefValue - 60;
	}
	else if( DefValue >= 30)	// 3렙	30 ~ 60
	{
		DefAttLevel[type] = 3;
		DefAttMaxValue[type] = 30;
		DefAttCurrValue[type] = DefValue - 30;
	}
	else if( DefValue >= 12)	// 2렙	// 12 ~ 30
	{
		DefAttLevel[type] = 2;
		DefAttMaxValue[type] = 18;
		DefAttCurrValue[type] = DefValue - 12;
	}
	else	// else				// 0~ 12
	{
		DefAttLevel[type] = 1;
		DefAttMaxValue[type] = 12;
		DefAttCurrValue[type] = DefValue;
	}	
}

// BR 에너지 정보
function AddTooltipBR_MaxEnergy(ItemInfo item)
{
	//에너지 정보
	if (Item.BR_MaxEnergy > 0)
	{
		//빈공간
		AddTooltipItemBlank(TOOLTIP_LINE_HGAP);
		//<에너지 정보>
		AddTooltipItemOption(5065, "", true, false, false);
		SetTooltipItemColor(255, 255, 255, 0);

		AddTooltipColorText(GetSystemString(5066), getColor(163,163,163,255), true, true);
		
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = true;
		m_Info.bLineBreak = true;
		if ( Item.BR_CurrentEnergy==0 || (Item.BR_MaxEnergy / Item.BR_CurrentEnergy > 10) )
		{
			m_Info.t_color.R = 255;
			m_Info.t_color.G = 0;
			m_Info.t_color.B = 0;
		}
		else
		{
			m_Info.t_color.R = 176;
			m_Info.t_color.G = 155;
			m_Info.t_color.B = 121;
		}
		m_Info.t_color.A = 255;
		//m_Info.t_strText = "  " $ Item.BR_CurrentEnergy $ "/" $ Item.BR_MaxEnergy;
		m_Info.t_strText = " " ;
		ParamAdd(m_Info.Condition, "Type", "CurrentEnergy");
		EndItem();
	}
}

// 제련 효과 
function AddTooltipRefinery(ItemInfo item)
{
	local string strDesc1, strDesc2, strDesc3;
	local int ColorR, ColorG, ColorB, Quality;	
	
	//제련효과
	if (Item.RefineryOp1 != 0 || Item.RefineryOp2 != 0)
	{
		//빈공간
		AddTooltipItemBlank(2);
		
		//"[제련효과]"
		//AddSectionTitleBoader();
		AddTooltipItemOption(1490, "", true, false, false);
		SetTooltipItemColor(255, 255, 255, 0);
		AddTooltipItemBlank(2);
		
		//컬러값 취득
		if(Item.SlotBitType == 8192)
		{
			Quality = class'UIDATA_REFINERYOPTION'.static.GetQuality(Item.RefineryOp1);
			GetRefineryColor(Quality,ColorR,ColorG,ColorB);
		}
		else
		{
			Quality = class'UIDATA_REFINERYOPTION'.static.GetQuality(Item.RefineryOp2);
			GetRefineryColor(Quality,ColorR,ColorG,ColorB);
		}
		
		if (Item.RefineryOp1 != 0)
		{
			strDesc1 = "";
			strDesc2 = "";
			strDesc3 = "";
			if (class'UIDATA_REFINERYOPTION'.static.GetOptionDescription( Item.RefineryOp1, strDesc1, strDesc2, strDesc3 ))
			{	
				if (Len(strDesc1)>0)
				{
					AddTooltipColorText(strDesc1, getColor(ColorR, ColorG, ColorB, 255), true, false, false);
					//AddTooltipItemOption(0, strDesc1, false, true, false);
					//SetTooltipItemColor(ColorR, ColorG, ColorB, 0);
				}
				if (Len(strDesc2)>0)
				{
					AddTooltipColorText(strDesc2, getColor(ColorR, ColorG, ColorB, 255), true, false, false);
					//AddTooltipItemOption(0, strDesc2, false, true, false);
					//SetTooltipItemColor(ColorR, ColorG, ColorB, 0);
				}
				if (Len(strDesc3)>0)
				{
					AddTooltipColorText(strDesc3, getColor(ColorR, ColorG, ColorB, 255), true, false, false);
					//AddTooltipItemOption(0, strDesc3, false, true, false);
					//SetTooltipItemColor(ColorR, ColorG, ColorB, 0);
				}
			}
		}	
		
		if(Item.SlotBitType == 8192) // 망토는 색을 다르게 지정할수도 있게 수정..
		{
			Quality = class'UIDATA_REFINERYOPTION'.static.GetQuality(Item.RefineryOp2);
			GetRefineryColor(Quality,ColorR,ColorG,ColorB);
		}

		if (Item.RefineryOp2 != 0)
		{
			strDesc1 = "";
			strDesc2 = "";
			strDesc3 = "";
			if (class'UIDATA_REFINERYOPTION'.static.GetOptionDescription( Item.RefineryOp2, strDesc1, strDesc2, strDesc3 ))
			{
				if (Len(strDesc1)>0)
				{
					AddTooltipColorText(strDesc1, getColor(ColorR, ColorG, ColorB, 255), true, false, false);
					//AddTooltipItemOption(0, strDesc1, false, true, false);
					//SetTooltipItemColor(ColorR, ColorG, ColorB, 0);
					
				}
				if (Len(strDesc2)>0)
				{
					AddTooltipColorText(strDesc2, getColor(ColorR, ColorG, ColorB, 255), true, false, false);
					//AddTooltipItemOption(0, strDesc2, false, true, false);
					//SetTooltipItemColor(ColorR, ColorG, ColorB, 0);
				}
				if (Len(strDesc3)>0)
				{
					AddTooltipColorText(strDesc3, getColor(ColorR, ColorG, ColorB, 255), true, false, false);
					//AddTooltipItemOption(0, strDesc3, false, true, false);
					//SetTooltipItemColor(ColorR, ColorG, ColorB, 0);
				}
			}
		}

		//"라이브에서는 교환/드롭 불가"
		//"망토는 드랍 가능 여부 판별 해야 함.
		if(!getInstanceUIData().getIsClassicServer() && Item.SlotBitType != 8192)
		{
			AddTooltipItemOption(1491, "", true, false, false);
			SetTooltipItemColor(ColorR, ColorG, ColorB, 0);
		}

		//빈공간
		AddTooltipItemBlank(2);
	}	
}

// 집혼 효과 추가 (2015-03-11)
function AddWeaponEnsoulOption(ItemInfo weaponInfo)
{
	local EnsoulOptionUIInfo optionInfo;
	local int i, n, cnt, optionID;
	local bool bUseTitle;

	if (weaponInfo.itemType != EItemType.ITEM_WEAPON) return;

	bUseTitle = true;
	// 집혼 시스템 개편 (2015-02-09 추가)
	for(i=EIST_NORMAL; i<EIST_MAX; i++)
	{
		cnt = weaponInfo.EnsoulOption[i - EIST_NORMAL].OptionArray.Length;

		for(n=EISI_START; n<EISI_START + cnt; n++)		
		{
			optionID = weaponInfo.EnsoulOption[i - EIST_NORMAL].OptionArray[n - EISI_START];

			// Debug("optionID--------------------->" @ optionID);

			if (optionID > 0)
			{
				if (bUseTitle)
				{
					//빈공간
					AddTooltipItemBlank(6);
					AddCrossLine();
					AddTooltipItemBlank(5);
					
					AddTooltipItemOption(3394, "", true, false, false);
					SetTooltipItemColor(255, 255, 255, 0);
					bUseTitle = false;
				}

				GetEnsoulOptionUIInfo(optionID, optionInfo);
				addToolTipDrawList(m_Tooltip, addDrawItemBlank(3));
				
				addToolTipDrawList(m_Tooltip, addDrawItemTexture(optionInfo.IconPanelTex, false, true, 2));
				addToolTipDrawList(m_Tooltip, addDrawItemTexture(optionInfo.IconTex, false, false, -16));

				addToolTipDrawList(m_Tooltip, addDrawItemText("", getInstanceL2Util().White, "", false,,4,2));

				//addToolTipDrawList(m_Tooltip, addDrawItemText(MakeFullSystemMsg(GetSystemMessage(4347), 
				//											  optionInfo.Name, string(optionInfo.OptionStep)), 
				//											  getInstanceL2Util().ColorYellow, "", false));

				if (optionInfo.OptionStep > 0)
				{
					addToolTipDrawList(m_Tooltip, addDrawItemText(MakeFullSystemMsg(GetSystemMessage(4347), 
																  optionInfo.Name, string(optionInfo.OptionStep)), 
																  getInstanceL2Util().ColorYellow, "", false));
				}
				else

				{
					addToolTipDrawList(m_Tooltip, addDrawItemText(optionInfo.Name, getInstanceL2Util().ColorYellow, "", false));
				}

				
				addToolTipDrawList(m_Tooltip, addDrawItemText(optionInfo.desc, getInstanceL2Util().ColorGray , "", true));
				addToolTipDrawList(m_Tooltip, addDrawItemBlank(3));
			}
		}
	}
}

// <인챈트효과> ,(<인챈트 효과> 및 설명),  (칠월칠석, 방어구 각인등) 
function AddTooltipEventSeventhdayOfSeventhMonth(ItemInfo item)
{
	//local string strDesc1, strDesc2, strDesc3;
	//local int ColorR, ColorG, ColorB;
	local int useHeadTitle;
	
	// [칠월칠석, 방어구 각인] item enchant option - by jin 09/08/05
	if (Item.EnchantOption1 != 0 || Item.EnchantOption2 != 0 || Item.EnchantOption3 != 0)
	{
		addDescEventSeventhday(Item.EnchantOption1, useHeadTitle);
		addDescEventSeventhday(Item.EnchantOption2, useHeadTitle);
		addDescEventSeventhday(Item.EnchantOption3, useHeadTitle);
	}
}

// <인챈트효과>, AddTooltipEventSeventhdayOfSeventhMonth 부속 함수, 
// useHeadTitle 는 <인챈트 효과> 툴팁 헤드를 출력한 상태면 다시 안하려고.
// 기존 중복 코드 제거 및 인챈트 효과가 없어도 글씨 나오는 문제 수정
function addDescEventSeventhday(int nEnchantOption, out int useHeadTitle)
{
	local string strDesc1, strDesc2, strDesc3;
	local int ColorR, ColorG, ColorB;

	if (nEnchantOption != 0)
	{
		strDesc1 = "";
		strDesc2 = "";
		strDesc3 = "";
		if (class'UIDATA_REFINERYOPTION'.static.GetOptionDescription( nEnchantOption, strDesc1, strDesc2, strDesc3 ))
		{	
			if (Len(strDesc1) > 0 || Len(strDesc2) > 0 || Len(strDesc3) > 0)
			{
				if (useHeadTitle == 0)
				{
					useHeadTitle = 1;
					AddTooltipItemBlank(TOOLTIP_LINE_HGAP);
					
					//"[인챈트효과]"
					AddTooltipItemOption(2214, "", true, false, false);
					SetTooltipItemColor(255, 255, 255, 0);
					AddTooltipItemBlank(TOOLTIP_LINE_HGAP);
				}
			}

			//컬러값 취득
			if (nEnchantOption != 0)
			{
				// [칠월칠석, 방어구각인] 각인 효과는 일단 무조건 1번 색상을 사용. - by jin 09/08/06
				GetRefineryColor(1, ColorR, ColorG, ColorB);
			}

			if (Len(strDesc1)>0)
			{
				AddTooltipColorText(strDesc1, getColor(ColorR, ColorG, ColorB, 255), true, false, false);
			}
			if (Len(strDesc2)>0)
			{
				AddTooltipColorText(strDesc2, getColor(ColorR, ColorG, ColorB, 255), true, false, false);
			}
			if (Len(strDesc3)>0)
			{
				AddTooltipColorText(strDesc3, getColor(ColorR, ColorG, ColorB, 255), true, false, false);
			}
		}
	}	
}

// 투영병기, 내구도
function AddTooltipItemDurability(ItemInfo item)
{
	local Color tempColor;

	// 투영병기 표시, 내구도 아이템, 함수로 빼면 됨
	if (Item.CurrentDurability >= 0 && Item.Durability > 0)
	{
		//빈공간
		AddTooltipItemBlank(TOOLTIP_LINE_HGAP);
		
		//<투영 병기 정보>
		AddTooltipItemOption(1492, "", true, false, false);
		SetTooltipItemColor(255, 255, 255, 0);
		
		// 잔존마력/총마력:
		AddTooltipColorText(GetSystemString(1493), getColor(163,163,163,255), true, true);

		if (Item.CurrentDurability+1 <= 5)
			tempColor = getColor(255,0,0,255);
		else
			tempColor = getColor(176,155,121,255);
		// 잔존마력/총마력   <- 수치
		AddTooltipColorText(" " $ Item.CurrentDurability $ "/" $ Item.Durability, tempColor, false, true);
		AddTooltipItemBlank(TOOLTIP_LINE_HGAP);

		//"교환/드롭 불가"
		// AddTooltipItemOption(1491, "", true, false, false);
		
		//빈공간
		//if (Len(Item.Description)>0) AddTooltipItemBlank(12);
	}
}


//branch, p마크 13 x 13 심볼, 해외 쪽 캐쉬 아이템에 붙는 듯.
function int AddPrimeItemSymbol(ItemInfo Item, optional bool bFirstLineWidthCount)
{
	local int nSumWidth;
	local string TextureName;

	if (Item.IsBRPremium != 2)
		return nSumWidth;

	TextureName = GetPrimeItemSymbolName();
	if (Len(TextureName)>0)
	{
		StartItem();
		m_Info.eType = DIT_TEXTURE;
		m_Info.nOffSetX = 4;
		m_Info.nOffSetY = 1;
		
		m_Info.u_nTextureWidth = 14;
		m_Info.u_nTextureHeight = 14;
			
		m_Info.u_nTextureUWidth = 14;
		m_Info.u_nTextureUHeight = 14;

		m_Info.u_strTexture = TextureName;
		EndItem();
		
		nSumWidth = nSumWidth + m_Info.u_nTextureUWidth + m_Info.nOffSetX; 
	}
	return nSumWidth;
}
//end of branch


//세트 아이템.
function addSetitemTooltip( ItemInfo Item )
{
	local int i;
	local int j;
	local string strTmp;
	local ItemID tmpItemID;
	local int SetID;
	//총 세트 아이템 개수
	local int totalNum;

	local bool IsSigil;	
	local ItemInfo tmpInfo;
	
	//아이템인지 확인.
	if( IsValidItemID(Item.ID) )
	{
		SetItemLineInsert( Item.ID, 0 );
		AddTooltipItemBlank(4);
		//AddCrossLine();

		//TOOLTIP_SETITEM_MAX 총 3종류의 setitem이 존재 함.
		//0 -> 5세트로 만들어진 아이템 (헬멧, 각반, 흉갑, 건틀렛, 부츠)
		//1 -> 쉴드, 시길이 추가된 세트
		//2 -> ?? 있는지 모름. 나중을 위해 만들어진듯.

		for ( i = 0; i < TOOLTIP_SETITEM_MAX ; i++ )
		{
			//세트아이템 리스트
			//GetSetItemNum 각 셋트 아이템의 개수.
			
			for ( SetID = 0 ; SetID < class'UIDATA_ITEM'.static.GetSetItemNum(Item.ID, i) ; SetID++ ) //0,1,2번 세트아이템효과 에 대해서 각각 몇가지의 세트가 완비되야하나..
			{ 					
				tmpItemID.classID = class'UIDATA_ITEM'.static.GetSetItemFirstID( Item.ID, i, SetID );
				
				//세트아이템의 종류 추가 및 작용한 세트 아이템 클라이언트에서 확인.
				if (tmpItemID.classID > 0)
				{
					strTmp = class'UIDATA_ITEM'.static.GetItemName(tmpItemID);
					class'UIDATA_ITEM'.static.GetItemInfo( tmpItemID, tmpInfo );
					//AddTooltipItemBlank(1);

					addItemIconSmallType(tmpInfo, "");

					StartItem();
					m_Info.eType = DIT_TEXT;
					//m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
					m_Info.nOffSetY   = 4;
					m_Info.bLineBreak = false;
					m_Info.t_bDrawOneLine = false;						
					SetTooltipTextColor( 100, 100, 65, 255 );

					//0 -> 5세트로 만들어진 아이템 (헬멧, 각반, 흉갑, 건틀렛, 부츠)
					if( i == 0 )
					{
						//m_Info.t_strText = "- "$strTmp;
						m_Info.t_strText = " "$strTmp;
						ParamAdd(m_info.Condition, "SetItemNum", string(i));
						ParamAdd(m_Info.Condition, "Type", "Equip");
						ParamAddItemID(m_Info.Condition, Item.ID);
						ParamAdd(m_Info.Condition, "CurTypeID", string(SetID));		//비교할 아이템의 Type 예(0번:흉갑 1번:각반 2번:헬멧 3번:팔 4번 다리 ..ItemName.txt에 들어있는순서
						ParamAdd(m_Info.Condition, "NormalColor", "100,100,65");
						ParamAdd(m_Info.Condition, "EnableColor", "255,250,160");
						totalNum = SetID;
					}
					//1 -> 쉴드, 시길이 추가된 세트
					else if( i == 1 )
					{
						m_Info.t_strText = "- (+) "$strTmp;
						ParamAdd(m_info.Condition, "SetItemNum", string(i));
						ParamAdd(m_Info.Condition, "Type", "Equip");
						ParamAddItemID(m_Info.Condition, Item.ID);						
						ParamAdd(m_Info.Condition, "CurTypeID", string(SetID));		//비교할 아이템의 Type 예(0번:흉갑 1번:각반 2번:헬멧 3번:팔 4번 다리 ..ItemName.txt에 들어있는순서
						ParamAdd(m_Info.Condition, "NormalColor", "100,70,0");
						ParamAdd(m_Info.Condition, "EnableColor", "255,180,0");
						IsSigil = IsSigilArmor(tmpItemID);
					}
					EndItem();
					AddTooltipItemBlank(1);
				}
			}
		}

		for ( i = 0; i < TOOLTIP_SETITEM_MAX ; i++ )
		{	
			//셋트효과			
			for( j = 0; j < class'UIDATA_ITEM'.static.GetSetItemPeaceEffectNum( Item.ID, i ) ; j++ )
			{
				StartItem();
				m_Info.eType = DIT_TEXT;
				m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
				m_Info.bLineBreak = true;
				m_Info.t_bDrawOneLine = true;
				SetTooltipTextColor( 100, 70, 0, 255 );
				//0 -> 5세트로 만들어진 아이템 (헬멧, 각반, 흉갑, 건틀렛, 부츠)
				if( i == 0 )
				{
					m_Info.t_strText = string( j+2 ) $ GetSystemString(2345) $ " : ";
				}
				//1 -> 쉴드, 시길이 추가된 세트
				else if( i == 1 )
				{	
					//branch 110824
					if( IsSigil == true )
					{
						m_Info.t_strText = string( totalNum + 1 ) $ GetSystemString(2345)$ "+" $ GetSystemString(1987) $ ": ";
					}
					else 
					{
						m_Info.t_strText = string( totalNum + 1 ) $ GetSystemString(2345)$ "+" $ GetSystemString(2346) $ ": ";
					}
					//end of branch
				}
				ParamAdd(m_Info.Condition, "Type", "SetEffect");
				ParamAddItemID(m_Info.Condition, Item.ID);
				ParamAdd(m_Info.Condition, "EffectID", string(i));
				ParamAdd(m_Info.Condition, "SetEffectIndex", String(j));
				ParamAdd(m_Info.Condition, "NormalColor", "100,70,0");
				ParamAdd(m_Info.Condition, "EnableColor", "255,180,0");
				EndItem();
				
				strTmp = class'UIDATA_ITEM'.static.GetSetItemPeaceEffectDescription( Item.ID, i, j );
				StartItem();
				m_Info.eType = DIT_TEXT;
				m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
				SetTooltipTextColor( 68, 68, 68, 255 );
				m_Info.t_strText = strTmp;
				ParamAdd(m_Info.Condition, "Type", "SetEffect");
				ParamAddItemID(m_Info.Condition, Item.ID);
				ParamAdd(m_Info.Condition, "EffectID", String(i));
				ParamAdd(m_Info.Condition, "SetEffectIndex", String(j));
				ParamAdd(m_Info.Condition, "NormalColor", "68,68,68");
				ParamAdd(m_Info.Condition, "EnableColor", "170,170,170");
				EndItem();	
			}
		}

		for( j = 0; j < class'UIDATA_ITEM'.static.GetItemSetEnchantEffectNum( Item.ID ) ; j++ )
		{
			//인첸트 셋트효과
			strTmp = class'UIDATA_ITEM'.static.GetSetItemEnchantEffectDescription(Item.ID, j);
			if (Len(strTmp) > 0)
			{
				StartItem();
				m_Info.eType = DIT_TEXT;
				m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
				m_Info.bLineBreak = true;
				m_Info.t_color.R = 110;
				m_Info.t_color.G = 140;
				m_Info.t_color.B = 170;
				m_Info.t_color.A = 255;
				m_Info.t_strText = strTmp;
				ParamAdd(m_Info.Condition, "Type", "EnchantEffect");
				ParamAddItemID(m_Info.Condition, Item.ID);
				
				ParamAdd(m_Info.Condition, "NormalColor", "74,92,104");
				ParamAdd(m_Info.Condition, "EnableColor", "110,140,170");
				ParamAdd(m_Info.Condition, "SetEnchantEffectIndex", string(j));  //추가됨 2013.01.23 정우균

				EndItem();
			}
		}
	}
}

function SetItemLineInsert( ItemID id, int setID )
{
	//세트 아이템인지 확인..
	if( class'UIDATA_ITEM'.static.GetSetItemPeaceEffectNum( Id, setID ) != 0 )
	{
		// Debug( string ( class'UIDATA_ITEM'.static.GetSetItemPeaceEffectNum( Id, setID ) ) );

		BSetItem = true;

		//AddSectionTitleBoader();
		//AddTooltipItemBlank(1);
		////AddTooltipItemOption(2347, "", true, false, false,"", 0, -24);
		//AddTooltipColorText(GetSystemString(2347), getColor(163, 163, 163, 255), true, true, false, "", 0, -24);			
		//SetTooltipItemColor(255, 255, 255, 0);
		//AddTooltipItemBlank(1);

		AddCrossLine();
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
		m_Info.bLineBreak = true;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_strText = GetSystemString(2347);
		SetTooltipTextColor( 230, 230, 230, 255 );
		EndItem();
	}
	else
	{
		BSetItem = false;
	}
}

/**
 * 혈맹전쟁 용 
 * 초를 넣어서 1일/11:33 같은 스트링 타입으로 반환
 **/
function string getSecToDateStr(int sec, bool onlyDayFlag)
{
	// 86400
	// 1109
	local string returnStr;
	local int remainSec;
	local int m_timeDay;
	local int m_timeHour;
	local int m_timeMin;
	//local int m_timeSec;

	// (일 day)
	m_timeDay = sec / 86400;
	remainSec = sec % 86400;
	
	m_timeHour = (remainSec / 60 / 60);		// 시
	m_timeMin = (remainSec / 60) % 60;		// 분
	// m_timeSec = remainSec % 60;	// 초

	// debug(" m_timeHour : " $ m_timeHour $ "m_timeMin : "  $ m_timeMin$ "m_timeSec : "  $ m_timeSec);	
	returnStr = "";
	if (m_timeDay > 0)
	{
		returnStr = String(m_timeDay) $ GetSystemString(1109); // $ "/";
	}

	if (onlyDayFlag == false)
	{
		// 일 day 이 없다면 / 을 해주지 않는다. 
		if (returnStr != "") returnStr = returnStr $ "/";

		// 시를 그려준다.
		if(m_timeHour > 0)
		{
			if (m_timeHour < 10 ) returnStr = returnStr $ "0" $ string( m_timeHour );
			else returnStr = returnStr $ string( m_timeHour );
		}
		else
		{
			returnStr = returnStr $ "00";
		}

		// 분
		if(m_timeMin > 0)
		{
			if (m_timeMin < 10 ) returnStr =  returnStr $ ":0" $ string( m_timeMin );
			else returnStr = returnStr $ ":" $ string( m_timeMin );
		}
		else
		{
			returnStr = returnStr $ ":00";
		}
	}

	return returnStr;
}

/**
 * 전쟁 상태에 따른 스트링 리턴 
 * 0, 1, 2, 3, 4  (매우열세, 열세, 대응, 우세, 매우강세)
 **/
function string getWarSituationString(int warSituation)
{
	local string returnStr;
	
	switch (warSituation)
	{
		case 0 : returnStr = returnStr $ GetSystemString(2355); break;
		case 1 : returnStr = returnStr $ GetSystemString(2354); break;
		case 2 : returnStr = returnStr $ GetSystemString(2353); break;
		case 3 : returnStr = returnStr $ GetSystemString(2352); break;
		case 4 : returnStr = returnStr $ GetSystemString(2351); break;

	}

	return returnStr;
}

//----------------------------------------------------------------------------------------------------------------------------------------------------
//  툴팁 조건 검사 함수들 모음 
//----------------------------------------------------------------------------------------------------------------------------------------------------

function bool IsEnchantableItem(EItemParamType Type)
{
	return (Type == ITEMP_WEAPON || Type == ITEMP_ARMOR || Type == ITEMP_ACCESSARY || Type == ITEMP_SHIELD);
}

//----------------------------------------------------------------------------------------------------------------------------------------------------
//  툴팁 생성, 기본 함수 (가장 기본이 되는 것들만 넣을 것)
//----------------------------------------------------------------------------------------------------------------------------------------------------

function ClearTooltip()
{
	m_Tooltip.SimpleLineCount = 0;
	m_Tooltip.MinimumWidth = 0;
	m_Tooltip.DrawList.Remove(0, m_Tooltip.DrawList.Length);
}

function StartItem()
{
	local DrawItemInfo infoClear;
	m_Info = infoClear;
}

function EndItem()
{
	m_Tooltip.DrawList.Length = m_Tooltip.DrawList.Length + 1;
	m_Tooltip.DrawList[m_Tooltip.DrawList.Length-1] = m_Info;
}


//툴팁 Text 색상 변경.
function SetTooltipTextColor( int R, int G, int B, int A )
{
	m_Info.t_color.R = R;
	m_Info.t_color.G = G;
	m_Info.t_color.B = B;
	m_Info.t_color.A = A;
}

//툴팁 Text 
function SetTooltipText( string strDesc, bool bLineBreak, bool t_bDrawOneLine, optional bool isFirstLine)
{
	m_Info.eType = DIT_TEXT;
	if (!isFirstLine) m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
	m_Info.t_strText = strDesc;
	m_Info.bLineBreak = bLineBreak;	
	m_Info.t_bDrawOneLine = t_bDrawOneLine;
}

// 줄 그리기, 최소 사이즈를 지정 가능하도록 수정 (2016-04)
function AddCrossLine(optional int minimum_width)
{
	AddTooltipItemBlank(4);

	StartItem();
	m_Info.eType = DIT_SPLITLINE;

	if(minimum_width > 0) 
		m_Info.u_nTextureWidth = minimum_width;			
	else
		m_Info.u_nTextureWidth = TOOLTIP_MINIMUM_WIDTH;			

	m_Info.u_nTextureHeight = 1;
	m_Info.u_strTexture ="L2ui_ch3.tooltip_line";
	EndItem();
	AddTooltipItemBlank(4);
}

////
//function AddSectionTitleBoader(optional int minimum_width)
//{
//	AddTooltipItemBlank(2);

//	StartItem();
//	m_Info.eType = DIT_SPLITLINE;

//	if(minimum_width > 0) 
//		m_Info.u_nTextureWidth = minimum_width;			
//	else
//		m_Info.u_nTextureWidth = TOOLTIP_MINIMUM_WIDTH;			

//	m_Info.u_nTextureHeight = 20;
//	m_Info.u_strTexture ="L2UI_CT1.ToolTip.TooltipSection_title";
//	EndItem();
//	AddTooltipItemBlank(2);
//}


// 기본적인 텍스트를 넣습니다. 
function AddTooltipText(string strDesc, bool bLineBreak, bool t_bDrawOneLine, optional bool isFirstLine, optional string fontName, optional int offSetX, optional int offSetY)
{
	StartItem();
	m_Info.eType = DIT_TEXT;
	if (!isFirstLine) m_Info.nOffSetY = TOOLTIP_LINE_HGAP;

	m_Info.nOffSetX = m_Info.nOffSetX + offsetX;
	m_Info.nOffSetY = m_Info.nOffSetY + offsetY;
	m_Info.t_strFontName = fontName;
	m_Info.t_strText = strDesc;
	m_Info.bLineBreak = bLineBreak;	
	m_Info.t_bDrawOneLine = t_bDrawOneLine;
	EndItem();
}

// 기본적인 칼라 텍스트를 넣습니다.
function AddTooltipColorText(string strDesc, Color textColor, bool bLineBreak, bool t_bDrawOneLine, optional bool isFirstLine, optional string fontName, optional int offSetX, optional int offSetY)
{
	StartItem();
	m_Info.eType = DIT_TEXT;
	if (!isFirstLine) m_Info.nOffSetY = TOOLTIP_LINE_HGAP;	
	m_Info.bLineBreak = bLineBreak;
	m_Info.t_bDrawOneLine = t_bDrawOneLine;
	m_Info.nOffSetX = m_Info.nOffSetX + offsetX;
	m_Info.nOffSetY = m_Info.nOffSetY + offsetY;
	m_Info.t_strFontName = fontName;
	m_Info.t_color = textColor;
	m_Info.t_strText = strDesc;

	m_Info.nOffsetX = offSetX;
	m_Info.nOffsetY = offSetY;
	EndItem();
}

// 아가시온 스킬 툴팁
function AddAgathionSkillTooltip ( itemInfo info ) 
{
	local array<SkillInfo> mainSkillList, subSkillList ;	
	local int i ;
	local color titleColor, descColor;	
	
	GetAgathionMainSkillList(info.ID.classID, info.Enchanted, mainSkillList ) ;	
	//Debug ( "아가시온 아이템 메인 " @  mainSkillList.Length ) ;//getAgathionIndex ( info.ID ) @ info.Enchanted);		

	GetAgathionSubSkillList(info.ID.classID, info.Enchanted, subSkillList) ;
	//Debug ( "아가시온 아이템 서브 " @ subSkillList.Length ) ;
	
	// 해당 아이템이 메인 인 경우 메인과 서브 모두 활성화 컬러 		

	if ( mainSkillList.Length > 0 )
	{   		
		if ( getAgathionIndex ( info.ID ) == 0 )  
		{			
			titleColor.R = 255 ;
			titleColor.G = 153 ;
			titleColor.B = 153 ;
			titleColor.A = 255 ;
			descColor.R = 153;
			descColor.G = 153;
			descColor.B = 153;
			descColor.A = 255;
		}
		else 
		{
			titleColor.R = 100 ;
			titleColor.G = 70 ;
			titleColor.B = 70 ;
			titleColor.A = 255 ;
			descColor.R = 68;
			descColor.G = 68;
			descColor.B = 68;
			descColor.A = 255;
		}
		AddTooltipItemBlank( 4);
		AddTooltipColorText( GetSystemString(3640), titleColor, true, false ) ;
		AddTooltipItemBlank( 2);
		for ( i = 0 ; i < mainSkillList.Length ; i ++ ) 
		{				
			AddTooltipColorText(" - " ,descColor, true, false ) ;
			AddTooltipColorText(mainSkillList[i].SkillDesc ,descColor, false, false ) ;
			AddTooltipItemBlank( 2);
		}
	}

	if ( subSkillList.Length > 0  ) 
	{   
		if ( getAgathionIndex ( info.ID )  > 0  ||  getAgathionIndex ( info.ID ) == 0 )  
		{			
			titleColor.R = 255 ;
			titleColor.G = 153 ;
			titleColor.B = 153 ;
			titleColor.A = 255 ;
			descColor.R = 153;
			descColor.G = 153;
			descColor.B = 153;
			descColor.A = 255;
		}
		else 
		{
			titleColor.R = 100 ;
			titleColor.G = 70 ;
			titleColor.B = 70 ;
			titleColor.A = 255 ;
			descColor.R = 68;
			descColor.G = 68;
			descColor.B = 68;
			descColor.A = 255;
		}

		AddTooltipItemBlank( 4);
		AddTooltipColorText( GetSystemString(3641), titleColor, true, false ) ;
		AddTooltipItemBlank( 2);
		for ( i = 0 ; i < subSkillList.Length ; i ++ ) 
		{
			AddTooltipColorText(" - " ,descColor, true, false ) ;
			AddTooltipColorText( subSkillList[i].SkillDesc ,descColor, false, false ) ;
			AddTooltipItemBlank( 2);

		}
	}
}


//빈공간 (높이) 를 생성 한다.
function AddTooltipItemBlank(int Height)
{
	StartItem();
	m_Info.eType = DIT_BLANK;
	m_Info.b_nHeight = Height;
	EndItem();
}

// 기본 텍스트 추가 
function AddTooltipSimpleText(string strText, optional int offsetX, optional int offsetY)
{
	StartItem();
	m_Info.eType = DIT_TEXT;
	m_Info.t_bDrawOneLine = true;

	m_Info.t_strText = strText;
	m_Info.nOffSetX = m_Info.nOffSetX + offsetX;
	m_Info.nOffSetY = m_Info.nOffSetY + offsetY;

	EndItem();
}


//"XXX : YYYY" 형태의 TooltipItem을 편하게 추가해 준다
function AddTooltipItemOption(int TitleID, string Content, bool bTitle, bool bContent, bool isFirstLine, optional string fontName, optional int offsetX, optional int offsetY, optional Color titleTextColor, optional Color contentTextColor)//, optional string addIconStr)
{
	//if (addIconStr != "")
	//{
	//	AddTooltipItemBlank(0);
	//	addTexture(addIconStr, 12, 11, 11,12, 4, 8);
	//}

	if (bTitle)
	{
		StartItem();
		m_Info.eType = DIT_TEXT;
		if (!isFirstLine) m_Info.nOffSetY = TOOLTIP_LINE_HGAP; // 툴팁 첫번째 라인이 아니라면, 세로 간격을 6픽셀 준다.(기본적으로 일정하게 쓰는 GAP)
		//if (addIconStr == "") m_Info.bLineBreak = true;
		m_Info.bLineBreak = true;
		m_Info.t_bDrawOneLine = true;

		if (titleTextColor.R == 0 && titleTextColor.G == 0 && titleTextColor.B == 0 && titleTextColor.A == 0)
		{
			m_Info.t_color.R = 163;
			m_Info.t_color.G = 163;
			m_Info.t_color.B = 163;
			m_Info.t_color.A = 255;
		}
		else
		{
			m_Info.t_color = titleTextColor;
		}
		m_Info.nOffSetX = m_Info.nOffSetX + offsetX;
		m_Info.nOffSetY = m_Info.nOffSetY + offsetY;
		m_Info.t_strFontName = fontName;

		m_Info.t_ID = TitleID;
		EndItem();	
	}
	
	if (Content != "0")
	{
		if (bContent)
		{
			if (bTitle)
			{
				StartItem();
				m_Info.eType = DIT_TEXT;
				if (!isFirstLine) m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
				m_Info.t_bDrawOneLine = true;
				if (titleTextColor.R == 0 && titleTextColor.G == 0 && titleTextColor.B == 0 && titleTextColor.A == 0)
				{
					m_Info.t_color.R = 163;
					m_Info.t_color.G = 163;
					m_Info.t_color.B = 163;
					m_Info.t_color.A = 255;
				}
				else
				{
					m_Info.t_color = titleTextColor;
				}
				m_Info.nOffSetX = m_Info.nOffSetX + offsetX;
				m_Info.nOffSetY = m_Info.nOffSetY + offsetY;
				m_Info.t_strFontName = fontName;
				m_Info.t_strText = " : ";
				EndItem();
			}
			
			StartItem();
			m_Info.eType = DIT_TEXT;
			if (!isFirstLine) m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
			if (!bTitle) m_Info.bLineBreak = true;
			m_Info.t_bDrawOneLine = true;

			if (contentTextColor.R == 0 && contentTextColor.G == 0 && contentTextColor.B == 0 && contentTextColor.A == 0)
			{
				m_Info.t_color.R = 176;
				m_Info.t_color.G = 155;
				m_Info.t_color.B = 121;
				m_Info.t_color.A = 255;
			}
			else
			{
				m_Info.t_color = contentTextColor;
			}

			m_Info.nOffSetX = m_Info.nOffSetX + offsetX;
			m_Info.nOffSetY = m_Info.nOffSetY + offsetY;
			m_Info.t_strFontName = fontName;
			m_Info.t_strText = Content;
			EndItem();
		}
	}
}


//"XXX : YYYY" 형태의 TooltipItem을 편하게 추가해 준다
function AddTooltipItemOptionString(string TitleContent, string Content, bool bTitle, bool bContent, bool isFirstLine)
{
	if (bTitle)
	{
		StartItem();
		m_Info.eType = DIT_TEXT;
		if (!isFirstLine) m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
		m_Info.bLineBreak = true;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_color.R = 163;
		m_Info.t_color.G = 163;
		m_Info.t_color.B = 163;
		m_Info.t_color.A = 255;
		m_Info.t_strText = TitleContent;
		EndItem();	
	}
	
	if (Content != "0")
	{
		if (bContent)
		{
			if (bTitle)
			{
				StartItem();
				m_Info.eType = DIT_TEXT;
				if (!isFirstLine) m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
				m_Info.t_bDrawOneLine = true;
				m_Info.t_color.R = 163;
				m_Info.t_color.G = 163;
				m_Info.t_color.B = 163;
				m_Info.t_color.A = 255;
				m_Info.t_strText = " : ";
				EndItem();
			}
			
			StartItem();
			m_Info.eType = DIT_TEXT;
			if (!isFirstLine) m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
			if (!bTitle) m_Info.bLineBreak = true;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_color.R = 176;
			m_Info.t_color.G = 155;
			m_Info.t_color.B = 121;
			m_Info.t_color.A = 255;
			m_Info.t_strText = Content;
			EndItem();
		}
	}
}

//"XXX : YYYY" 형태의 TooltipItem을 편하게 추가해 준다.
//SYSSTRING : SYSSTRING
function AddTooltipItemOption2(int TitleID, int ContentID, bool bTitle, bool bContent, bool isFirstLine)
{
	if (bTitle)
	{
		StartItem();
		m_Info.eType = DIT_TEXT;
		if (!isFirstLine) m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
		m_Info.bLineBreak = true;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_color.R = 163;
		m_Info.t_color.G = 163;
		m_Info.t_color.B = 163;
		m_Info.t_color.A = 255;
		m_Info.t_ID = TitleID;
		EndItem();
	}
	
	if (bContent)
	{	
		if (bTitle)
		{
			StartItem();
			m_Info.eType = DIT_TEXT;
			if (!isFirstLine) m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_color.R = 163;
			m_Info.t_color.G = 163;
			m_Info.t_color.B = 163;
			m_Info.t_color.A = 255;
			m_Info.t_strText = " : ";
			EndItem();
		}		
		
		StartItem();
		m_Info.eType = DIT_TEXT;
		if (!isFirstLine) m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
		if (!bTitle) m_Info.bLineBreak = true;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_color.R = 176;
		m_Info.t_color.G = 155;
		m_Info.t_color.B = 121;
		m_Info.t_color.A = 255;
		m_Info.t_ID = ContentID;
		EndItem();
	}
}

//"XXX : YYYY" 형태의 TooltipItem을 편하게 추가해 준다. 색깔 조정 가능( 타이틀과 컨텐츠 색깔이 다른 경우에 사용. 귓속말에 쓰고있음)
function AddTooltipItemColorOption(int TitleID, string Content, int r, int g, int b, bool bTitle, bool bContent, bool isFirstLine)
{
	if (bTitle)
	{
		StartItem();
		m_Info.eType = DIT_TEXT;
		if (!isFirstLine) m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
		m_Info.bLineBreak = true;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_color.R = 163;
		m_Info.t_color.G = 163;
		m_Info.t_color.B = 163;
		m_Info.t_color.A = 255;
		m_Info.t_ID = TitleID;
		EndItem();
	}
	
	if (Content != "0")
	{
		if (bContent)
		{
			if (bTitle)
			{
				StartItem();
				m_Info.eType = DIT_TEXT;
				if (!isFirstLine) m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
				m_Info.t_bDrawOneLine = true;
				m_Info.t_color.R = r;
				m_Info.t_color.G = g;
				m_Info.t_color.B = b;
				m_Info.t_color.A = 255;
				m_Info.t_strText = " : ";
				EndItem();
			}
			
			StartItem();
			m_Info.eType = DIT_TEXT;
			if (!isFirstLine) m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
			if (!bTitle) m_Info.bLineBreak = true;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_color.R = r;
			m_Info.t_color.G = g;
			m_Info.t_color.B = b;
			m_Info.t_color.A = 255;
			m_Info.t_strText = Content;
			EndItem();
		}
	}
}

// nBasic 기본값, 인챈트 보너스 값 nBonus   (100+50)  <- 이런식 표현 (칼라 다르게)
function AddTooltipItemBonus(int nBasic, int nBonus, optional int offSetX, optional int offSetY)
{
	//클래식 서버 일 경우 덧붙이지 않는다.
	//if (nBonus > 0 && !getInstanceUIData().getIsClassicServer())
	if (nBonus > 0)
	{					
		AddTooltipColorText(" (" $ String(nBasic) $ " ", getColor(176, 155, 121, 255), false, true, false, "", offSetX, offSetY);
		AddTooltipColorText("+" $ String(nBonus), getColor(238, 170, 34, 255), false, true, false, "", offSetX, offSetY);
		AddTooltipColorText(")", getColor(176, 155, 121, 255), false, true, false, "", offSetX, offSetY);
	}
}

function addTooltipTexture ( string Texture, int width, int height, int uWidth, int uHeight, optional bool OneLine, optional bool bLineBreak, optional int offSetX, optional int offSetY  ) 
{
	StartItem();
	m_Info.eType = DIT_TEXTURE;
	m_Info.t_bDrawOneLine = OneLine;
	m_Info.bLineBreak = bLineBreak;
	m_Info.u_nTextureWidth = width;
	m_Info.u_nTextureHeight = height;
	m_Info.nOffSetX = offSetX;
	m_Info.nOffSetY = offSetY;
	m_Info.u_nTextureUWidth = uWidth;
	m_Info.u_nTextureUHeight = uHeight;
	m_Info.u_strTexture = Texture;
	EndItem();
}

// 속성, 물, 불, 바람,등등 속성 아이콘
function string GetAttributeIcon(int nAttributeType)
{
	local string rStr;

	switch(nAttributeType)
	{
		case ATTRIBUTE_FIRE   : rStr = "L2UI_CT1.ToolTip.Tooltip_AttributeIcon_fire";   break;
		case ATTRIBUTE_WATER  : rStr = "L2UI_CT1.ToolTip.Tooltip_AttributeIcon_water";  break;
		case ATTRIBUTE_WIND   : rStr = "L2UI_CT1.ToolTip.Tooltip_AttributeIcon_wind";   break;
		case ATTRIBUTE_EARTH  : rStr = "L2UI_CT1.ToolTip.Tooltip_AttributeIcon_earth";  break;
		case ATTRIBUTE_HOLY   : rStr = "L2UI_CT1.ToolTip.Tooltip_AttributeIcon_Sacred"; break;
		case ATTRIBUTE_UNHOLY : rStr = "L2UI_CT1.ToolTip.Tooltip_AttributeIcon_dark";   break;
	}

	return rStr;
}


// 테스트중..
//function int getToolTipWidthMaxSize()
//{
//	local int i, widthSize, textSizeW, textSizeH, maxWidthSize;

//	for (i = 0; i < m_Tooltip.DrawList.Length; i++)
//	{
//		if (m_Tooltip.DrawList[i].t_strText != "")
//			GetTextSizeDefault(m_Tooltip.DrawList[i].t_strText, textSizeW, textSizeH);

//		if (m_Tooltip.DrawList[i].t_ID > 0) 
//			GetTextSizeDefault(GetSystemString(m_Tooltip.DrawList[i].t_ID), textSizeW, textSizeH);
		
//		widthSize = m_Tooltip.DrawList[i].nOffSetX + m_Tooltip.DrawList[i].u_nTextureWidth + textSizeW;

//		if (maxWidthSize < widthSize) maxWidthSize = widthSize;
//	}

//	return maxWidthSize;
//}

//function string toolTipLineWidthRefresh()
//{  
//	local int maxWidth, i;

//	maxWidth = getToolTipWidthMaxSize();

//	//Debug("maxWidth:" @ maxWidth);

//	for (i = 0; i < m_Tooltip.DrawList.Length; i++)
//	{
//		if (m_Tooltip.DrawList[i].u_strTexture == "L2ui_ch3.tooltip_line")
//		{
//			m_Info.u_nTextureWidth = maxWidth;
//		}
//	}
//}



// t_bDrawOneLine  : 한줄로 그려 줄때 (자동으로 툴팁 width가 커진다)
// bLineBreak      : 줄 내림 

//------------------------------------------------------------------------------------------------------------------------
// 툴팁 아이템 구성 관련 유틸
//------------------------------------------------------------------------------------------------------------------------	

//// 무기에 적용된 집혼석 옵션의 이름 전체를 받아온다.
//function string GetEnsoulOptionNameAll(ItemInfo weaponInfo)
//{
//	local EnsoulOptionUIInfo eOptionInfo;
//	local int i, n, cnt, optionID;

//	local string allName;

//	// 집혼 시스템 개편 (2015-02-09 추가)
//	for(i=EIST_NORMAL; i<EIST_MAX; i++)
//	{
//		cnt = weaponInfo.EnsoulOption[i - EIST_NORMAL].OptionArray.Length;

//		for(n=EISI_START; n<EISI_START + cnt; n++)		
//		{
//			optionID = weaponInfo.EnsoulOption[i - EIST_NORMAL].OptionArray[n - EISI_START];

//			// Debug("optionID--------------------->" @ optionID);
//			GetEnsoulOptionUIInfo(optionID, eOptionInfo);
//			if (eOptionInfo.name != "")
//			{
//				if (allName == "")	
//					allName = eOptionInfo.name;     
//				else
//					allName = allName $ "/" $ eOptionInfo.name;     
//			}
//		}
//	}

//	return allName;
//}
defaultproperties
{
}
