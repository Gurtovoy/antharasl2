class Tooltip extends UICommonAPI;

const TOOLTIP_MINIMUM_WIDTH = 154;
const TOOLTIP_MINIMUM_SETITEM_WIDTH = 200;

const TOOLTIP_SETITEM_MAX = 3;

// ???????? ?????
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
var Array<int> AttackAttMaxValue; //??? ???? ????? ????, ???????????? ??, ???????????? ??“S?? ???? ???????.

var Array<int> DefAttLevel;
var Array<int> DefAttCurrValue;
var Array<int> DefAttMaxValue; //??? ??? ????? ????, ???????????? ??, ???????????? ??“S?? ???? ???????.

var int NowAttrLv;
var int NowMaxValue;
var int NowValue;

var bool BoolSelect;

//??? ???????? ??? ??? Width?? TOOLTIP_MINIMUM_SETITEM_WIDTH???? ????.
var bool BSetItem;

//??? ?? ???? 6?? ????? ???? ???? ???¥ì? ????? ????? ???? ????
var bool BLine;

var TextBoxHandle ItemCountText;
var L2Util util;

function OnRegisterEvent()
{
	RegisterEvent( EV_RequestTooltipInfo );
}

function OnLoad()
{
	// ???? ???? ???/???? ?????? ????(TTP#41925) 2010.8.23 - winkey
	BoolSelect = true;
	// ??? ?????? ????.
	BSetItem = false; 

	util = L2Util(GetScript("L2Util"));
}

function OnEvent(int Event_ID, string param)
{
	switch( Event_ID )
	{
	case EV_RequestTooltipInfo:
		//debug("???????? ??????");
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
	//debug("Tooltip???:"$TooltipType);
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
			|| TooltipType == "InventoryPawnViewer" // PawnViewer?? ??? - lancelot 2007. 10. 16.
			|| TooltipType == "HtmlViewer" // Html ?????? ??? - y2jinc 2011. 11. 16.
			|| TooltipType == "InventoryPet"// ?? ?? ???? ??? ( ??? ???? ?????? ????? ??? )			
			|| TooltipType == "EnsoulSlot" // ??? ??? ????. ?????? ???? ??? ????? ?????? ?????.. - ???? ????

			)		
	{		
		ReturnTooltip_NTT_ITEM(param, TooltipType, eSourceType);
	}
	//////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////// ListCtrl Tooltip ///////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////
	//???? ????(2010.02.22 ~ 03.08) ???
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
		// ?¥è???? ???? friendList  BlockList 
		ReturnTooltip_NTT_FRIENDINFO(param, eSourceType);
	}
	// 10.09.20 ?????? ????? ???? ??? by Dongland		
	else if (TooltipType == "ClanWarInfo")
	{
		ReturnTooltip_NTT_CLANWARINFO(param, eSourceType);
	}
	else if (TooltipType == "SellItemList")
	{
		// ??? ???? 
		ReturnTooltip_NTT_SellItemList(param, eSourceType);
	}
	else if (TooltipType == "EnsoulOptionType")
	{
		// ??? ??? - 2015-03-02 ???
		ReturnTooltip_NTT_EnsoulOptionList(param, eSourceType);
	}
	else if (TooltipType == "AgitDecoListType")
	{
		// ????? ???? ????? (2015-08-04 ???)
		ReturnTooltip_NTT_AgitDecoList(param, eSourceType);
	}
	

	//???? ????( 10.03.30 ) ???
	//??????? ???? ???.
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
	// [????? ?????? ???? ???]
	else if (TooltipType == "QuestItem")
	{
		ReturnTooltip_NTT_QUESTREWARDS(param, eSourceType);
	}
	else if(TooltipType == "GFxCardItem")
	{
		ReturnTooltip_NTT_GFXCARD(param, eSourceType);
	}
	//??? ?????? ???? ???
	else if(TooltipType == "UserFakeInfo")
	{
		ReturnTooltip_NTT_CHAT_USERFAKEINFO(param, eSourceType);
	}
	else if(TooltipType == "LookChangeItem")
	{
		//ReturnTooltip_NTT_NORMALITEM(param);
		ReturnTooltip_NTT_LOOCKCHANGEITEM(param);
	// ???¥ë??? ?????? ???? ????? ????? ??????? 2015.1.20
	}
	else if ( TooltipType == "InventoryStackableUnitPrice" )
	{
		//???? ???? ?????? ???? ??????? eSourceType?? ?????? ??????? ??? ?????? ??.
		ReturnTooltip_NTT_ITEM(param, TooltipType, NTST_ITEM);
	}
	// ????? ????
	else if ( TooltipType == "RegionInfo")
	{
		ReturnTooltip_NTT_MAP_REGIONINFO(param, eSourceType);
	}
	else if ( TooltipType == "GfxCustomTooltip" ) 
	{
		//Gfx???? ?????? ¨¨???? ???? 
		ReturnTooltip_NTT_GFxTooltip( param );		
	}
	else if ( TooltipType == "privateShopHistory" ) 
	{
		ReturnTooltip_NTT_PrivateShopHistory ( param ) ;
	}
}


/////////////////////////////////////////////////////////////////////////////////
// Gfx???? ?????? ¨¨???? ???? 
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
// ????? ???? ????
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
			ParseString(param, "CastleName", CastleName);               // ????? 

			ParseString(param, "OwnerClanNameToolTip", OwnerClanNameToolTip);  // xx ???? ???? ??
			ParseString(param, "OwnerClanName", OwnerClanName);         // ???? ?????
			ParseString(param, "NextSiegeTime", NextSiegeTime);         // ???? ?????? ?©£?
			ParseString(param, "SiegeState", SiegeState);               // ???????, ??????
			ParseString(param, "CastleType", CastleType);               // ????, ??, ???
			ParseString(param, "TaxRate", TaxRate);                     // ????
			
			AddTooltipColorText(CastleName, getInstanceL2Util().White, false, false, true); // ?? ???
			//CastleType = "????";
			if (CastleType != "") AddTooltipColorText(" (" $ CastleType $ ")", getInstanceL2Util().ColorLightBrown, false, false, true); // ??, ???

			AddCrossLine(); 
			AddTooltipColorText(GetSystemString(1607) $ " : " $ OwnerClanName, getInstanceL2Util().ColorYellow, true, true, false);  // ???? ????
			AddTooltipColorText(GetSystemString(1612) $ " : " $ SiegeState, getInstanceL2Util().ColorYellow, true, true, false);     // ???: ??????, ???
			AddTooltipColorText(GetSystemString(1608) $ " : " $ TaxRate, getInstanceL2Util().ColorYellow, true, true, false);        // ????
			AddTooltipColorText(GetSystemString(1609) $ " : " $ NextSiegeTime, getInstanceL2Util().ColorYellow, true, true, false);  // ???? ??????

			// ???? ????©§? ???? ???? ???? ?????? ????? ????
			setTooltipMinimumWidth ();
		}
		// ???
		else if (nType == EMinimapRegionType.MRT_Fortress)
		{
			ParseString(param, "CastleName", CastleName);               // ??(???) ??? 
			ParseString(param, "OwnerClanName", OwnerClanName);         // ???? ?????
			ParseString(param, "SiegeState", SiegeState);               // ???????, ???? ??
			ParseString(param, "DateTotal", DateTotal);                 // ???? ?©£?
			ParseString(param, "LocationName", LocationName);           // ??????
				
			AddTooltipColorText(CastleName $ " | " $ MakeFullSystemMsg( GetSystemMessage(4436), LocationName), getInstanceL2Util().White, true, true, true); // ?????
			AddCrossLine();
			AddTooltipColorText(GetSystemString(1607) $ " : " $ OwnerClanName, getInstanceL2Util().ColorYellow, true, true, false); // ???? ????
			AddTooltipColorText(GetSystemString(1612) $ " : " $ SiegeState, getInstanceL2Util().ColorYellow, true, true, false);    // ???: ??????, ???
			if (DateTotal != "") AddTooltipColorText(GetSystemString(1615) $ " : " $ DateTotal, getInstanceL2Util().ColorYellow, true, true, false); // ???? ?©£?
			
			// ???? ????©§? ???? ???? ???? ?????? ????? ????
			setTooltipMinimumWidth ();
		}
		// ?????
		else if (nType == EMinimapRegionType.MRT_Agit)
		{  
			ParseString(param, "AgitName", AgitName);                           // ????? ??? 
			ParseString(param, "OwnerClanName", OwnerClanName);                 // ???? ?????
			ParseString(param, "OwnerClanMasterName", OwnerClanMasterName);     // ??????
			ParseString(param, "NextSiegeTime", NextSiegeTime);                 // ???? ????? ??
			ParseString(param, "LocationName", LocationName);           // ??????

			AddTooltipColorText(AgitName $ " | " $ MakeFullSystemMsg( GetSystemMessage(4436), LocationName), getInstanceL2Util().White, true, true, true); // ?????
			AddCrossLine();

			// ???? ????			
			if (OwnerClanName == "") OwnerClanName = GetSystemString(27);
			AddTooltipColorText(GetSystemString(1607) $ " : " $ OwnerClanName, getInstanceL2Util().ColorYellow, true, true, false); 

			// ?????? 342
			if (OwnerClanMasterName != "") AddTooltipColorText(GetSystemString(342) $ " : " $ OwnerClanMasterName, getInstanceL2Util().ColorYellow, true, true, false); 

			//OwnerClanMasterName

			if (NextSiegeTime != "") 
			{
				// ???? ??????? ????
				AddTooltipColorText(GetSystemString(3545)$ " : " $ NextSiegeTime, getInstanceL2Util().ColorYellow, true, true, false); 
			}

			// ???? ????©§? ???? ???? ???? ?????? ????? ????
			setTooltipMinimumWidth ();
		}
		// ????? 
		else if (nType == EMinimapRegionType.MRT_HuntingZone_Base || nType == EMinimapRegionType.MRT_HuntingZone_Mission)
		{
			ParseString( param, "SeedMessage", seedMessage);

			// ????? ?????? ?????¢¥?.
			class'UIDATA_HUNTINGZONE'.static.GetHuntingZoneData(index, huntingZoneData);
			
			tmpStr = class'UIDATA_HUNTINGZONE'.static.GetHuntingZoneName(huntingZoneData.nSearchZoneID);

			AddTooltipColorText(huntingZoneData.strName $ " | " $ tmpStr, getInstanceL2Util().White, true, true, true);

			AddCrossLine();

			// ?????? ???? ????
			if(seedMessage != "") 
				AddTooltipColorText(seedMessage, getColor(255,204,0,255), true, true, false);

			//Debug("huntingZoneData.nMinLevel:" @ huntingZoneData.nMinLevel);
			//Debug("huntingZoneData.nMaxLevel:" @ huntingZoneData.nMaxLevel);
			// ??????? : xx~xx
			if (huntingZoneData.nMinLevel != 0 && huntingZoneData.nMaxLevel != 0)
				AddTooltipColorText(GetSystemString(922) $ " : "$ huntingZoneData.nMinLevel $ "~" $ huntingZoneData.nMaxLevel, getColor(255,204,0,255), true, true, false);

			nHuntingZoneType = huntingZoneData.nType;
			//nHuntingZoneType = class'UIDATA_HUNTINGZONE'.static.GetHuntingZoneType(index);

			// ????? ????
			tmpStr = getHuntingZoneTypeString(nHuntingZoneType); 
			if (tmpStr != "") AddTooltipColorText(tmpStr, getColor(255,204,0,255), true, true, false);
		
			// ???? ????©§? ???? ???? ???? ?????? ????? ????
			setTooltipMinimumWidth ();
		}
		//// ????? ??? (??? ????????? ????)
		//else if (nType == EMinimapRegionType.MRT_HuntingZone_Mission)
		//{
		//	// ??? ?????
		//	m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH / 4;
		//	AddTooltipColorText(GetSystemString(3544), getInstanceL2Util().White, true, true, true);
		//}
		// ???? ??????
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

		// ????? 
		else if (nType == EMinimapRegionType.MRT_Raid)
		{
			//pRaidUIData = getInstanceUIData().getRaidUIDataByIndex(index);
			pRaidUIData = getRaidDataByIndex(index);

			AddTooltipColorText(pRaidUIData.raidMonsterName $ " | " $ pRaidUIData.RaidMonsterZoneName, getInstanceL2Util().White, true, true, true);
			AddCrossLine();

			// xx ???? ????? ???? 
			Language = GetLanguage();
			if(Language == LANG_Russia || Language == LANG_Euro || Language == LANG_English)
				AddTooltipColorText(MakeFullSystemMsg(GetSystemMessage(4425),GetSystemString(537) $ " " $ pRaidUIData.nRaidMonsterLevel),getColor(255,204,0,255),true,true,false);
			else
				AddTooltipColorText(MakeFullSystemMsg(GetSystemMessage(4425), pRaidUIData.nRaidMonsterLevel $ GetSystemString(537)), getColor(255,204,0,255), true, true, false);
			// ???? ????)
			if (nActive > 0)
			{
				tmpStr = GetSystemString(3525);
			}
			else
			{
				tmpStr = GetSystemString(3526);
			}
			
			// ???? ???? : ???? or ????? 
			AddTooltipColorText(GetSystemString(3524) $ " : " $ tmpStr, getColor(255,204,0,255), true, true, false);
		
			// ???? ????©§? ???? ???? ???? ?????? ????? ????
			setTooltipMinimumWidth ();
		}

		// ?¥í???? ?? 
		else if (nType == EMinimapRegionType.MRT_InstantZone)
		{
			ParseInt( param, "Active", nActive);

			// ????? ?????? ?????¢¥?.
			class'UIDATA_HUNTINGZONE'.static.GetHuntingZoneData(index, huntingZoneData);

			tmpStr = class'UIDATA_HUNTINGZONE'.static.GetHuntingZoneName(huntingZoneData.nSearchZoneID);
			
			AddTooltipColorText(huntingZoneData.strName $ " | " $ tmpStr, getInstanceL2Util().White, true, true, true);
			//AddTooltipColorText(huntingZoneData.strName $ addStr $ " | " $ tmpStr, getInstanceL2Util().White, true, true, true);

			AddCrossLine();

			// ????? ????			
			nHuntingZoneType = huntingZoneData.nType;
			//nHuntingZoneType = class'UIDATA_HUNTINGZONE'.static.GetHuntingZoneType(index);

			tmpStr = getHuntingZoneTypeString(nHuntingZoneType); 
			if (tmpStr != "") AddTooltipColorText(tmpStr, getColor(255,204,0,255), true, true, false);

			// ??????? : xx~xx
			if (huntingZoneData.nMinLevel != 0 && huntingZoneData.nMaxLevel != 0)
				AddTooltipColorText(GetSystemString(922) $ " : "$ huntingZoneData.nMinLevel $ "~" $ huntingZoneData.nMaxLevel, getColor(255,204,0,255), true, true, false);

			// ???? ???
			AddTooltipColorText(GetSystemString(3522) $ " : " $ class'UIDATA_HUNTINGZONE'.static.GetHuntingDescription(index), getColor(255,204,0,255), true, true, false);
			
			// ???? ?????
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

			// ??? ???
			if(nActive <= 0) 
			{
				// ???? ??? : ??? ??? 
				AddTooltipColorText(GetSystemString(3524) $ " : " $GetSystemString(5099) , getColor(255,204,0,255), true, true, false);
			}

			// ???? ????©§? ???? ???? ???? ?????? ????? ????
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
		//Debug("?? ????" @ param);

		////????
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
	// ?????? ?????
	// ParseString(param, "iconPanel", iconPanel);

	if (Item.IconName == "") return false;

	// ?? ?????? ???
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

	// ?????? ?¬Ô? (?? ????? ??? ?¬Ô?)
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

	// ???? ???? ?????? ?¬Ô? ???? ????? ?¬Ô?
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
		// ?????? lock ???? ??
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

	// ?????? ?¬Ô? (?? ????? ??? ?¬Ô?)
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

	// ???? ???? ?????? ?¬Ô? ???? ????? ?¬Ô?
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

// ? / ???, ???? ???? ??? ???????? ????? ???????.
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
	
	//??????¬à????
	local string strAdena;
	local string strAdenaComma;
	local color	 AdenaColor;	
	
	//??©­???.
	local ItemEnchantBonusValue rValue; 
	
	// [EP3019]
	// ???? ??©¡? ???? ???
	local bool  bMagicWeapon;
	local float fSoulShotPower, fSpiritShotPower;

	// ???? ??? ?????
	local int   nEnchantedPhysicalDamageBonus, nEnchantedMagicalDamageBonus;

	// ??? ??? ???, ???????(????)
	local int   nEnchantedMagicalDefenseBonus, nEnchantedPhysicalDefenseBonus, nEnchantedShieldDefenseBonus;

	// ?¥ê??? ??? ???? ?? ?????? ?¬Ô? ???
	local string ForeTexture;

	//  ?????? ????, ?????? ???
	local string ItemSlotWithItemTypeStr;

	// ?????? ??
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

		//if (IsCompareItem == 1) Debug("?? ????????? " @ Item.Name) ;
		//if (IsComparingEquip == 1) Debug("?????? ????????? " @ Item.Name) ;
		//if (IsComparingEquip == 1 && IsCompareItem == 1) Debug("==== ?????? ?? ????????? " @ Item.Name) ;

		// ??? ???? ??????? ???? ???????? ??????, ?????? ????????? ??? ?????.. EnsoulWnd???? ???.
		if (TooltipType == "EnsoulSlot") 
		{
			if (Item.Id.ClassID <= 0) return;
		}
		
		GetItemBonusEnchantValue( item.ID.ClassID, item.CrystalType, item.Enchanted, Item.Attribution, rValue );

		eItemType = EItemType(Item.ItemType);
		eEtcItemType = EEtcItemType(Item.ItemSubType);
		
		// ??©¡??? ???? ????, ????, ???????(????), ????? ??? 
		nEnchantedShieldDefenseBonus   = GetEnchantedShieldDefenseBonus  (Item.CrystalType, Item.Enchanted, Item.Attribution);		
		nEnchantedMagicalDefenseBonus  = GetEnchantedMagicalDefenseBonus (Item.CrystalType, Item.Enchanted, Item.Attribution);
		nEnchantedPhysicalDefenseBonus = GetEnchantedPhysicalDefenseBonus(Item.CrystalType, Item.Enchanted, Item.Attribution);

		// ??©¡??? ???? ????? ??? ???
		nEnchantedPhysicalDamageBonus   = GetEnchantedPhysicalDamageBonus(Item.WeaponType, Item.SlotBitType, Item.CrystalType, Item.Enchanted, Item.Attribution);

		// ??©¡??? ???? ????? ??? ???
		nEnchantedMagicalDamageBonus    = GetEnchantedMagicalDamageBonus(Item.WeaponType, Item.SlotBitType, Item.CrystalType, Item.Enchanted, Item.Attribution);
		
		//?????? ??? ???
		ItemName = class'UIDATA_ITEM'.static.GetRefineryItemName( Item.Name, Item.RefineryOp1, Item.RefineryOp2 );
		ItemNameClass = class'UIDATA_ITEM'.static.GetItemNameClass( Item.ID );
		
		// ?¥ê??? ????? "[??????]" ???	
		// ParamToItemInfo ???¥ä? ??? param ?? ???? ??¢¥?.
		parseString ( param, "ForeTexture", ForeTexture ) ;
		if ( ForeTexture == "L2UI_CT1.Icon.WearPanel" || IsCompareItem == 1) 
		{
			if (IsComparingEquip == 1 || ForeTexture == "L2UI_CT1.Icon.WearPanel")
			{	
				// ???? ??????
				AddTooltipColorText("[" $ GetSystemString(3556) $ "]", getColor(255,204,0,255),true, true, true);
				nSimpleLineCountAdd = 2;
				AddTooltipItemBlank(0);
				AddCrossLine();
			}
			else
			{
				// ???? ??????
				AddTooltipColorText("[" $ GetSystemString(3555) $ "]", getColor(153,153,153,255), true, true, true);				
				nSimpleLineCountAdd = 2;
				AddTooltipItemBlank(0);
				AddCrossLine();
			}
		}

		// ?????? ???????? ??¢¥?.
		if(addItemIcon(Item, ForeTexture))
		{
			bMainIconGap = 3;
		}

		// ????? "P" ??????? ?????? ??????
		AddPrimeItemSymbol(Item, true);

		//??©­? ??? ex) "+10"		
		if (TooltipType != "InventoryPrice1HideEnchant" && TooltipType != "InventoryPrice1HideEnchantStackable") 
		{
			AddTooltipItemEnchant(Item, true, "chatFontSize11", 6, 1);	
			nEnchantValueTextGap = 3;
		}
		
		//?????? ???
		AddTooltipItemName(ItemName, Item, ItemNameClass, "chatFontSize11", bMainIconGap + nEnchantValueTextGap, 1);

		//?????? ????
		if (TooltipType != "InventoryPrice1HideEnchantStackable")
		{
			// ????? ???? ?????? ?????? ?????? ?????? ??? ???? ??¢¥?.
			if (TooltipType != "QuestReward") if( Item.ItemNum > 0 ) AddTooltipItemCount(Item, 0, 1);
		}

		//Grade Mark
		AddTooltipItemGrade(Item, 0, 1);

		// ?????? ??? , ex) ? / ???
		ItemSlotWithItemTypeStr = getSlotTypeWithItemTypeString(Item);
		if(ItemSlotWithItemTypeStr != "")
		{
			// SimpleLineCount ?? ?¥ê??? ?? ????? ????, ???? ?? ???¥ì?
			m_Tooltip.SimpleLineCount = 2 + nSimpleLineCountAdd;
			AddTooltipItemBlank(1);
			AddTooltipColorText(ItemSlotWithItemTypeStr, getColor(176,155,121,255), false, true, false, "", 38, -19);
		}

		//Debug("nSimpleLineCountAdd" @ nSimpleLineCountAdd);
		//Debug("m_Tooltip.SimpleLineCount" @ m_Tooltip.SimpleLineCount);

		//???????? ???????, ?¬à???? ????? (4?? 4000????? ???? ?¬à???? ???????)
		if (IsAdena(Item.ID) && Item.ItemNum > 0)
		{
			//SimpleTooltip?? ?¬à??????????? ???????.
			m_Tooltip.SimpleLineCount = 3 + nSimpleLineCountAdd;
			AddTooltipText("(" $ ConvertNumToText(String(Item.ItemNum)) $ ")", true, true);
		}
		
		// ???¥ë??? ???? ???? ???????? ????? ?? ?????? ??????? ???
		if (TooltipType == "InventoryStackableUnitPrice" && !Item.bEquipped )
		{
			// Debug ( " ???? ???? InventoryStackableUnitPrice" ) ;
			strAdena = String(Item.Price);
			strAdenaComma = MakeCostString(strAdena);
			AdenaColor = GetNumericColor(strAdenaComma);
			
			// ?????? ?????????, ???????? 1???? ???? ???? ???????? ???
			if (IsStackableItem(Item.ConsumeType) && Item.ItemNum > 1)
			{
				//1???? x ????? : xxx,xxx,xxx
				// AddTooltipItemOption2(2511, 468, true, true, false);
				AddTooltipItemBlank(TOOLTIP_LINE_HGAP);
				AddTooltipColorText(GetSystemString(2511) $ " : ", getColor(255,180,0,255), true, true, false);
				AddTooltipColorText(strAdenaComma $ " " $ GetSystemString(469), AdenaColor, false, true, ,"", 0, 0);
				//SetTooltipItemColor(AdenaColor.R, AdenaColor.G, AdenaColor.B, 0);
				////"?????"
				//AddTooltipColorText(GetSystemString(469), AdenaColor, false, true, false, "", 0, 0);
			}
			else
			{
				//???? : xxx,xxx,xxx
				AddTooltipItemOption(322, strAdenaComma $ " " $ GetSystemString(469), true, true, false,,,,,AdenaColor);
			}
			
			// ?? ?????? 
			if (IsStackableItem(Item.ConsumeType) && Item.ItemNum > 1)
			{
				strAdena = string(Item.Price * Item.ItemNum);
				strAdenaComma = MakeCostString(strAdena);
				AdenaColor = GetNumericColor(strAdenaComma);

				AddTooltipItemOption(2595, strAdenaComma $ " " $ GetSystemString(469), true, true, false,,,,,AdenaColor);

				//SetTooltipItemColor(AdenaColor.R, AdenaColor.G, AdenaColor.B, 0);
				//"?????"
				//AddTooltipColorText(GetSystemString(469), AdenaColor, false, true);
			}

			//SimpleTooltip?? ??????? ???????.
			//m_Tooltip.SimpleLineCount++
			
			//?¬à???? ?????
			if (Item.Price>0)
			{
				// m_Tooltip.SimpleLineCount = 3;
				AddTooltipItemOption(0, "(" $ ConvertNumToText(strAdena) $ ")", false, true, false);
				SetTooltipItemColor(AdenaColor.R, AdenaColor.G, AdenaColor.B, 0);
			}
		}	
		
		//InventoryPrice1 ???
		if ((TooltipType == "InventoryPrice1" || TooltipType == "InventoryPrice1HideEnchant" || TooltipType == "InventoryPrice1HideEnchantStackable") && !Item.bEquipped)
		{
			strAdena = String(Item.Price);
			strAdenaComma = MakeCostString(strAdena);
			AdenaColor = GetNumericColor(strAdenaComma);
			
			//???? : xxx,xxx,xxx
			AddTooltipItemOption(322, strAdenaComma $ " " $ GetSystemString(469), true, true, false);
			//SetTooltipItemColor(AdenaColor.R, AdenaColor.G, AdenaColor.B, 0);
			
			//"?????"
			//AddTooltipColorText(GetSystemString(469), AdenaColor, false, true);

			//SimpleTooltip?? ??????? ???????.
			m_Tooltip.SimpleLineCount = 3 + nSimpleLineCountAdd;
			
			//?¬à???? ?????
			if (Item.Price>0)
			{
				m_Tooltip.SimpleLineCount = 4 + nSimpleLineCountAdd;
				AddTooltipItemOption(0, "(" $ ConvertNumToText(strAdena) $ ")", false, true, false);
				SetTooltipItemColor(AdenaColor.R, AdenaColor.G, AdenaColor.B, 0);
			}
		}
		

		//InventoryPrice2 ???, ???¥ë??? ?????
		if (TooltipType == "InventoryPrice2"
			|| TooltipType == "InventoryPrice2PrivateShop")
		{
			strAdena = String(Item.Price);
			strAdenaComma = MakeCostString(strAdena);
			AdenaColor = GetNumericColor(strAdenaComma);
			
			//???? : 1????
			AddTooltipItemOption2(322, 468, true, true, false);
			SetTooltipItemColor(AdenaColor.R, AdenaColor.G, AdenaColor.B, 0);
			
			//"?????"
			//"xxx,xxx,xxx "
			AddTooltipColorText(" " $ strAdenaComma $ " " $ GetSystemString(469), AdenaColor, false, true,,,,TOOLTIP_LINE_HGAP);
			
			//SimpleTooltip?? ??????? ???????.
			m_Tooltip.SimpleLineCount = 3 + nSimpleLineCountAdd;
			
			//?¬à???? ?????
			if (Item.Price>0)
			{
				m_Tooltip.SimpleLineCount = 4 + nSimpleLineCountAdd;
				//"("
				AddTooltipColorText("(", AdenaColor, true, true);
				//"1????"
				AddTooltipColorText(GetSystemString(468), AdenaColor, false, true);
				//")"
				AddTooltipColorText(" " $ ConvertNumToText(strAdena) $ ")", AdenaColor, false, true);
			}
		}
		
		//InventoryPrice2PrivateShop ???
		if (TooltipType == "InventoryPrice2PrivateShop")
		{
			if (IsStackableItem(Item.ConsumeType) && Item.Reserved64 > 0)
			{
				//"??????? : xx"
				AddTooltipItemOption(808, String(Item.Reserved64), true, true, false);
			}
		}


		// ?????? ???? ???? 
		if ( item.bSecurityLock )
		{
			AddTooltipColorText(GetSystemString(3775),  getInstanceL2Util().HotPink, true, true,,"chatFontSize12",,TOOLTIP_LINE_HGAP);
		}

		/////////////////////////////////////////////////////////////////////////////////////////
		// ??????? ???? ???? ????
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
			
			//?????
			//AddTooltipItemBlank(6);
			
			//"[???? ????]"
			//AddTooltipItemOption(1489, "", true, false, false);
			// SetTooltipItemColor(255, 255, 255, 0);			

			//setTooltipItemInfo( ItemValue, item, eItemType );

			//Physical Damage
			//AddTooltipItemOption(94, String(GetPhysicalDamage(Item.WeaponType, Item.SlotBitType, Item.CrystalType, Item.Enchanted, Item.pAttack, Item.Attribution)), true, true, false);
			//?????(:10)

			if( rValue.PhysicalDamage != 0 )
			{					
				AddTooltipItemOption( 94, string( GetPhysicalDamage(Item.WeaponType, Item.SlotBitType, Item.CrystalType, Item.Enchanted, Item.pAttack, Item.Attribution) + rValue.PhysicalDamage),
										  true, true, false, "chatFontSize12", 0, 0, getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);
	
				// (50 + 54)    <-- (??????? + ??©¡???????????)
				AddTooltipItemBonus(Item.pAttack, nEnchantedPhysicalDamageBonus, 0, 7);
			}
			else
			{
				//?????[???? ??????]
				if( Item.pAttack != 0 )
				{
					AddTooltipItemOption(94, string( GetPhysicalDamage(Item.WeaponType, Item.SlotBitType, Item.CrystalType, Item.Enchanted, Item.pAttack, Item.Attribution) ), true, true, false, "chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);

					// (50 + 54)    <-- (??????? + ??©¡???????????)
					AddTooltipItemBonus(Item.pAttack, nEnchantedPhysicalDamageBonus, 0, 7);
				}
			}

			//Masical Damage
			//AddTooltipItemOption(98, String(GetMagicalDamage(Item.WeaponType, Item.SlotBitType, Item.CrystalType, Item.Enchanted, Item.mAttack, Item.Attribution)), true, true, false);						
			//???? ?????(  : 10 )

			if( rValue.MagicalDamage != 0 )
			{	
				//AddTooltipItemOption( 98, string( Item.mAttack + rValue.MagicalDamage ), true, true, false);
				AddTooltipItemOption( 98, string( GetMagicalDamage(Item.WeaponType, Item.SlotBitType, Item.CrystalType, 
																   Item.Enchanted, Item.mAttack, Item.Attribution) + rValue.MagicalDamage ), true, true, false, "chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);
								
				AddTooltipItemBonus(Item.mAttack, nEnchantedMagicalDamageBonus, 0, 7);
			}
			else
			{
				//??????[???? ??????]
				if( Item.mAttack != 0 )
				{
					AddTooltipItemOption(98, string( GetMagicalDamage(Item.WeaponType, Item.SlotBitType, Item.CrystalType, Item.Enchanted, Item.mAttack, Item.Attribution) ), true, true, false, "chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);
					AddTooltipItemBonus(Item.mAttack, nEnchantedMagicalDamageBonus, 0, 7);
				}
			}

			//Attack Speed
			AddTooltipItemOption(111, GetAttackSpeedString(Item.pAttackSpeed), true, true, false);
 
			//???!!!!!!!!!!!!!!!!!!
			//????[???????]			
			if( Item.pDefense > 0 )
			{
				AddTooltipItemOption(54, string( Item.pDefense ), true, true, false, "chatFontSize12",0, 0, getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);
			}
				
			//???????[????????]
			if( Item.mDefense > 0 )	
			{
				AddTooltipItemOption(99, string( Item.mDefense ), true, true, false);
			}

			//????
			if( Item.pHitRate + rValue.PhysicalHitRate != 0 )
				AddTooltipItemOption(96, string( Item.pHitRate + rValue.PhysicalHitRate ), true, true, false);
				//????????
				//AddTooltipItemOption(2360, string( Item.pHitRate + rValue.PhysicalHitRate ), true, true, false);

			//??????
			if( Item.pCriRate + rValue.PhysicalCriRate > 0 )
				AddTooltipItemOption(113, string( Item.pCriRate + rValue.PhysicalCriRate ), true, true, false);
				//??????????
				//AddTooltipItemOption(2362, string( Item.pCriRate + rValue.PhysicalCriRate ), true, true, false);

			//??????
			if( Item.MoveSpeed + rValue.MoveSpeed != 0 )
				AddTooltipItemOption(432, string( Item.MoveSpeed + rValue.MoveSpeed ), true, true, false);

			//????(????)			
			if( Item.ShieldDefense > 0 )
			{
				AddTooltipItemOption(95, string( Item.ShieldDefense ), true, true, false, "chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);
			}

			//?????
			if( Item.ShieldDefenseRate > 0 )
				AddTooltipItemOption(317, string( Item.ShieldDefenseRate ), true, true, false);

			//???????
			if( Item.pAvoid + rValue.PhysicalAvoid > 0 )
				AddTooltipItemOption(2361, string( Item.pAvoid + rValue.PhysicalAvoid ), true, true, false);

			//???????
			if( Item.mAvoid + rValue.MagicalAvoid > 0 )
				AddTooltipItemOption(2364, string( Item.mAvoid + rValue.MagicalAvoid ), true, true, false);

			//TTP 48614?? ????.
			//??????[??????????] 
			//if( Item.pAttackSpeed + rValue.PhysicalAttackSpeed > 0 )
			//	AddTooltipItemOption(111, string( Item.pAttackSpeed + rValue.PhysicalAttackSpeed ), true, true, false);
			//????????[????????]
			//if( Item.mHitRate + rValue.MagicalHitRate > 0 )
			//	AddTooltipItemOption(2363, string( Item.mHitRate + rValue.MagicalHitRate ), true, true, false);
			//??????????
			//if( Item.mCriRate + rValue.MagicalCriRate > 0 )
			//	AddTooltipItemOption(2365, string( Item.mCriRate ), true, true, false);

			//???????[??????????]
			if( Item.mAttackSpeed + rValue.MagicalAttackSpeed > 0 )
				AddTooltipItemOption(112, string( Item.mAttackSpeed + rValue.MagicalAttackSpeed ), true, true, false);

			// ???? ????????
			bMagicWeapon = class'UIDATA_ITEM'.static.IsMagicWeapon(Item.ID);

			//SoulShot Count, ????????
			if (Item.SoulshotCount>0) AddTooltipItemOption(404, "X" $ String(Item.SoulshotCount), true, true, false);
			//SpiritShot Count, ????????
			if (Item.SpiritShotCount>0) AddTooltipItemOption(496, "X" $ String(Item.SpiritshotCount), true, true, false);

			//if ((Item.SoulshotCount>0 || Item.SpiritShotCount>0 ) && !getInstanceUIData().getIsClassicServer() ) 
			if ((Item.SoulshotCount>0 || Item.SpiritShotCount>0 )) 
			{
				// ????? ???? ??? ???(float)
				fSoulShotPower   = GetSoulShotPower(Item.CrystalType, Item.Enchanted, Item.weaponType, bMagicWeapon);   
				// ????? ???? ??? ???(float)
				fSpiritShotPower = GetSpiritShotPower(Item.CrystalType, Item.Enchanted, Item.weaponType, bMagicWeapon);  
				
				// ?????, ????? ??? ??????? ????? ????? ???
				if (fSoulShotPower == fSpiritShotPower)
				{
					// 0??? ?????, 0???? ??? ????
					if (fSoulShotPower > 0)
					{
						AddTooltipItemBlank(TOOLTIP_LINE_HGAP);
						AddTooltipColorText(GetSystemMessage(4297) $ " : ", getColor(163, 163, 163, 255), true, true);	
						AddTooltipColorText("+" $ string(fSoulShotPower) $ "%", getColor(238, 170, 34, 255), false, true);							
					}
				}
				// ?????, ????? ??? ??????? ????? 1.4%, 3%  "," ?? ???????..
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
			
			//??????? ????
			AddTooltipRefinery(Item);

		break;
		
		// 2. ARMOR
		case ITEM_ARMOR:
			//if (Len(SlotString)>0)
			//	AddTooltipItemOption(0, SlotString, false, true, false);

			//setTooltipItemInfo( ItemValue, item, eItemType );
			//Debug("???" @ Item.SlotBitType @ IsMagicalArmor(Item.ID));
			
			// Sheild
			if ( Item.SlotBitType == 256 && Item.ArmorType == 4 ) // ArmorType == 4 is sigil.. 
			{
				//if (Len(SlotString)>0)
				//	AddTooltipItemOption(0, SlotString, false, true, false);
	
				//????[???????]
				if (Item.pDefense != 0)
				{
					AddTooltipItemOption(95, String(GetPhysicalDefense(Item.CrystalType, Item.Enchanted, Item.pDefense, Item.Attribution)), true, true, false,"chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);
					AddTooltipItemBonus(Item.pDefense, nEnchantedPhysicalDefenseBonus, 0, 7);
				}

				//Avoid Modify
				//???????( ??????? : 10 )
				if( rValue.PhysicalAvoid != 0 )
				{	
					AddTooltipItemOption( 2361, string( Item.pAvoid + rValue.PhysicalAvoid ), true, true, false);
				}
				else
				{
					//???????
					if( Item.pAvoid != 0 )
						AddTooltipItemOption(2361, string( Item.pAvoid ), true, true, false);
				}
				//???!!!!
				//?????[???? ??????]
				if( Item.pAttack + rValue.PhysicalDamage > 0 )
					AddTooltipItemOption(94, string( Item.pAttack + rValue.PhysicalDamage ), true, true, false);		
				//??????[???? ??????]
				if( Item.mAttack + rValue.MagicalDamage > 0 )
					AddTooltipItemOption(98, string( Item.mAttack + rValue.MagicalDamage ), true, true, false);	
				//???????[??????????]
				if( Item.mAttackSpeed + rValue.MagicalAttackSpeed > 0 )
					AddTooltipItemOption(112, string( Item.mAttackSpeed + rValue.MagicalAttackSpeed ), true, true, false);
				//????????
				if( Item.pHitRate + rValue.PhysicalHitRate > 0 )
					AddTooltipItemOption(2360, string( Item.pHitRate + rValue.PhysicalHitRate ), true, true, false);
				//????????[????????]
				if( Item.mHitRate + rValue.MagicalHitRate > 0 )
					AddTooltipItemOption(2363, string( Item.mHitRate + rValue.MagicalHitRate ), true, true, false);
				//??????????
				if( Item.pCriRate + rValue.PhysicalCriRate > 0 )
					AddTooltipItemOption(2362, string( Item.pCriRate + rValue.PhysicalCriRate ), true, true, false);
				//??????????
				if( Item.mCriRate + rValue.MagicalCriRate > 0 )
					AddTooltipItemOption(2365, string( Item.mCriRate + rValue.MagicalCriRate ), true, true, false);
				//??????
				if( Item.MoveSpeed + rValue.MoveSpeed != 0 )
					AddTooltipItemOption(432, string( Item.MoveSpeed + rValue.MoveSpeed ), true, true, false);

				//????
				if( Item.ShieldDefense > 0 )
				{
					AddTooltipItemOption(95, string( Item.ShieldDefense ), true, true, false,"chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);	
				}
				//?????
				if( Item.ShieldDefenseRate > 0 )
					AddTooltipItemOption(317, string( Item.ShieldDefenseRate ), true, true, false);
				//???????
				if( Item.pAvoid + rValue.PhysicalAvoid > 0 )
					AddTooltipItemOption(2361, string( Item.pAvoid + rValue.PhysicalAvoid ), true, true, false);
				//???????
				if( Item.mAvoid + rValue.MagicalAvoid > 0 )
					AddTooltipItemOption(2364, string( Item.mAvoid + rValue.MagicalAvoid ), true, true, false);
				//???????[????????]
				
				if( Item.mDefense > 0 )			
					AddTooltipItemOption(99, string( int ( Item.mDefense ) ), true, true, false);

				//TTP 48614?? ????.
				//??????[??????????]
				//if( Item.pAttackSpeed + rValue.PhysicalAttackSpeed > 0 )
				//	AddTooltipItemOption(111, string( Item.pAttackSpeed + rValue.PhysicalAttackSpeed ), true, true, false);

				//Weight
				if (Item.Weight != 0)
					AddTooltipItemOption(52, String(Item.Weight), true, true, false);
			}
			// ??
			else if (Item.SlotBitType == 256 || Item.SlotBitType == 128)	//SBT_LHAND or SBT_RHAND
			{
				//if (Len(SlotString)>0)
				//	AddTooltipItemOption(0, SlotString, false, true, false);

				//Shield Defense
				//????
				if( Item.ShieldDefense != 0 )
				{
					AddTooltipItemOption(95, string( GetShieldDefense(Item.CrystalType, Item.Enchanted, Item.ShieldDefense, Item.Attribution) ), true, true, false,"chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);
					AddTooltipItemBonus(Item.ShieldDefense, nEnchantedShieldDefenseBonus, 0, 7);
				}
				//Avoid Modify
				//if (Item.pAvoid != 0)
				//AddTooltipItemOption(97, String(Item.pAvoid), true, true, false);
				//???????( ??????? : 10 )
				if( rValue.PhysicalAvoid != 0 )
				{	
					AddTooltipItemOption( 2361, string( Item.pAvoid + rValue.PhysicalAvoid ), true, true, false);
				}
				else
				{
					//???????
					if( Item.pAvoid != 0 )
						AddTooltipItemOption(2361, string( Item.pAvoid ), true, true, false);
				}
				//???!!!!
				//????[???????]
				if( Item.pDefense >0 )
				{
					AddTooltipItemOption(54, string( Item.pDefense ), true, true, false,"chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);	
				}
				//???????[????????]
				if( Item.mDefense > 0 )
				{
					AddTooltipItemOption(99, string( int ( Item.mDefense )), true, true, false);
				}
				//?????[???? ??????]
				if( Item.pAttack + rValue.PhysicalDamage > 0 )
					AddTooltipItemOption(94, string( Item.pAttack + rValue.PhysicalDamage ), true, true, false);		
				//??????[???? ??????]
				if( Item.mAttack + rValue.MagicalDamage > 0 )
					AddTooltipItemOption(98, string( Item.mAttack + rValue.MagicalDamage ), true, true, false);	
				//???????[??????????]
				if( Item.mAttackSpeed + rValue.MagicalAttackSpeed > 0 )
					AddTooltipItemOption(112, string( Item.mAttackSpeed + rValue.MagicalAttackSpeed ), true, true, false);
				//????????
				if( Item.pHitRate + rValue.PhysicalHitRate > 0 )
					AddTooltipItemOption(2360, string( Item.pHitRate + rValue.PhysicalHitRate ), true, true, false);
				//????????[????????]
				if( Item.mHitRate + rValue.MagicalHitRate > 0 )
					AddTooltipItemOption(2363, string( Item.mHitRate + rValue.MagicalHitRate ), true, true, false);
				//??????????
				if( Item.pCriRate + rValue.PhysicalCriRate > 0 )
					AddTooltipItemOption(2362, string( Item.pCriRate + rValue.PhysicalCriRate ), true, true, false);
				//??????????
				if( Item.mCriRate + rValue.MagicalCriRate > 0 )
					AddTooltipItemOption(2365, string( Item.mCriRate + rValue.MagicalCriRate ), true, true, false);
				//??????
				if( Item.MoveSpeed + rValue.MoveSpeed != 0 )
					AddTooltipItemOption(432, string( Item.MoveSpeed + rValue.MoveSpeed ), true, true, false);
				//?????
				if( Item.ShieldDefenseRate > 0 )
					AddTooltipItemOption(317, string( Item.ShieldDefenseRate ), true, true, false);
				//???????
				if( Item.pAvoid + rValue.PhysicalAvoid > 0 )
					AddTooltipItemOption(2361, string( Item.pAvoid + rValue.PhysicalAvoid ), true, true, false);
				//???????
				if( Item.mAvoid + rValue.MagicalAvoid > 0 )
					AddTooltipItemOption(2364, string( Item.mAvoid + rValue.MagicalAvoid ), true, true, false);
				//TTP 48614?? ????.
				//??????[??????????]
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
				if (Item.SlotBitType == 65536 || Item.SlotBitType == 524288 || Item.SlotBitType == 262144 ) //???? ??? ????? ??? ????õê ??, ???, ??? ?? ??? 
				{
					//??? ????õê ??©­? ?? ???? ???
					if ( GetPhysicalDefense(Item.CrystalType, Item.Enchanted, Item.pDefense, Item.Attribution) != 0 )
					{
						AddTooltipItemOption(95, String(GetPhysicalDefense(Item.CrystalType, Item.Enchanted, Item.pDefense, Item.Attribution)), true, true, false,"chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);					
						AddTooltipItemBonus(Item.pDefense, nEnchantedPhysicalDefenseBonus, 0, 7);
					}
				}
				else
				{
					//????[???????]
					if (Item.pDefense != 0)
					{
						// Debug("??????? "@ String(GetPhysicalDefense(Item.CrystalType, Item.Enchanted, Item.pDefense, Item.Attribution)));
						AddTooltipItemOption(95, String(GetPhysicalDefense(Item.CrystalType, Item.Enchanted, Item.pDefense, Item.Attribution)), true, true, false,"chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);	
						AddTooltipItemBonus(Item.pDefense, nEnchantedPhysicalDefenseBonus, 0, 7);
					}
					//???????[????????]
					if( Item.mDefense > 0 )
					{
						// Debug("???????? "@ String(GetMagicalDefense(Item.CrystalType, Item.Enchanted, Item.mDefense, Item.Attribution)));
						AddTooltipItemOption(99, string( int ( Item.mDefense )), true, true, false,"chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);
					}
					//???!!!!
					//?????[???? ??????]
					if( Item.pAttack + rValue.PhysicalDamage > 0 )
						AddTooltipItemOption(94, string( Item.pAttack + rValue.PhysicalDamage ), true, true, false);		
					//??????[???? ??????]
					if( Item.mAttack + rValue.MagicalDamage > 0 )
						AddTooltipItemOption(98, string( Item.mAttack + rValue.MagicalDamage ), true, true, false);	
					//???????[??????????]
					if( Item.mAttackSpeed + rValue.MagicalAttackSpeed > 0 )
						AddTooltipItemOption(112, string( Item.mAttackSpeed + rValue.MagicalAttackSpeed ), true, true, false);
					//????????
					if( Item.pHitRate + rValue.PhysicalHitRate > 0 )
						AddTooltipItemOption(2360, string( Item.pHitRate + rValue.PhysicalHitRate ), true, true, false);
					//????????[????????]
					if( Item.mHitRate + rValue.MagicalHitRate > 0 )
						AddTooltipItemOption(2363, string( Item.mHitRate + rValue.MagicalHitRate ), true, true, false);
					//??????????
					if( Item.pCriRate + rValue.PhysicalCriRate > 0 )
						AddTooltipItemOption(2362, string( Item.pCriRate + rValue.PhysicalCriRate ), true, true, false);
					//??????????
					if( Item.mCriRate + rValue.MagicalCriRate > 0 )
						AddTooltipItemOption(2365, string( Item.mCriRate + rValue.MagicalCriRate ), true, true, false);
					//??????
					if( Item.MoveSpeed + rValue.MoveSpeed != 0 )
						AddTooltipItemOption(432, string( Item.MoveSpeed + rValue.MoveSpeed ), true, true, false);
					//?????
					if( Item.ShieldDefenseRate > 0 )
						AddTooltipItemOption(317, string( Item.ShieldDefenseRate ), true, true, false);
					//???????
					if( Item.pAvoid + rValue.PhysicalAvoid > 0 )
						AddTooltipItemOption(2361, string( Item.pAvoid + rValue.PhysicalAvoid ), true, true, false);
					//???????
					if( Item.mAvoid + rValue.MagicalAvoid > 0 )
						AddTooltipItemOption(2364, string( Item.mAvoid + rValue.MagicalAvoid ), true, true, false);
					//????
					if( Item.ShieldDefense > 0 )
					{
						AddTooltipItemOption(95, string( Item.ShieldDefense ), true, true, false);
					}

					//?????
					if( Item.ShieldDefenseRate > 0 )
						AddTooltipItemOption(317, string( Item.ShieldDefenseRate ), true, true, false);
					//TTP 48614?? ????.
					//??????[??????????]
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
				if (Item.SlotBitType == 65536 || Item.SlotBitType == 524288 || Item.SlotBitType == 262144 ) //???? ??? ????? ??? ????õê ??, ???, ??? ?? ??? 
				{
					//??? ????õê ??©­? ?? ???? ???
					if ( GetPhysicalDefense(Item.CrystalType, Item.Enchanted, Item.pDefense, Item.Attribution) != 0 )					
					{
						AddTooltipItemOption(95, String(GetPhysicalDefense(Item.CrystalType, Item.Enchanted, Item.pDefense, Item.Attribution)), true, true, false,"chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);					
						AddTooltipItemBonus(Item.pDefense, nEnchantedPhysicalDefenseBonus, 0, 7);
					}
				}				
				else
				{
					//????[???????]
					if (Item.pDefense != 0)
					{
						AddTooltipItemOption(95, String(GetPhysicalDefense(Item.CrystalType, Item.Enchanted, Item.pDefense, Item.Attribution)), true, true, false,"chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);
						AddTooltipItemBonus(Item.pDefense, nEnchantedPhysicalDefenseBonus, 0, 7);
					}
					//???????[????????]
					if( Item.mDefense > 0 )
					{
						AddTooltipItemOption(99, string( int (Item.mDefense) ), true, true, false,"chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);
					}

					//???!!!!
					//?????[???? ??????]
					if( Item.pAttack + rValue.PhysicalDamage > 0 )
						AddTooltipItemOption(94, string( Item.pAttack + rValue.PhysicalDamage ), true, true, false);		
					//??????[???? ??????]
					if( Item.mAttack + rValue.MagicalDamage > 0 )
						AddTooltipItemOption(98, string( Item.mAttack + rValue.MagicalDamage ), true, true, false);	
					//???????[??????????]
					if( Item.mAttackSpeed + rValue.MagicalAttackSpeed > 0 )
						AddTooltipItemOption(112, string( Item.mAttackSpeed + rValue.MagicalAttackSpeed ), true, true, false);
					//????????
					if( Item.pHitRate + rValue.PhysicalHitRate > 0 )
						AddTooltipItemOption(2360, string( Item.pHitRate + rValue.PhysicalHitRate ), true, true, false);
					//????????[????????]
					if( Item.mHitRate + rValue.MagicalHitRate > 0 )
						AddTooltipItemOption(2363, string( Item.mHitRate + rValue.MagicalHitRate ), true, true, false);
					//??????????
					if( Item.pCriRate + rValue.PhysicalCriRate > 0 )
						AddTooltipItemOption(2362, string( Item.pCriRate + rValue.PhysicalCriRate ), true, true, false);
					//??????????
					if( Item.mCriRate + rValue.MagicalCriRate > 0 )
						AddTooltipItemOption(2365, string( Item.mCriRate + rValue.MagicalCriRate ), true, true, false);
					//??????
					if( Item.MoveSpeed + rValue.MoveSpeed != 0 )
						AddTooltipItemOption(432, string( Item.MoveSpeed + rValue.MoveSpeed ), true, true, false);
					//?????
					if( Item.ShieldDefenseRate > 0 )
						AddTooltipItemOption(317, string( Item.ShieldDefenseRate ), true, true, false);
					//???????
					if( Item.pAvoid + rValue.PhysicalAvoid > 0 )
						AddTooltipItemOption(2361, string( Item.pAvoid + rValue.PhysicalAvoid ), true, true, false);
					//???????
					if( Item.mAvoid + rValue.MagicalAvoid > 0 )
						AddTooltipItemOption(2364, string( Item.mAvoid + rValue.MagicalAvoid ), true, true, false);
					//????
					if( Item.ShieldDefense > 0 )
					{
						AddTooltipItemOption(95, string( Item.ShieldDefense ), true, true, false);	
					}
					//?????
					if( Item.ShieldDefenseRate > 0 )
						AddTooltipItemOption(317, string( Item.ShieldDefenseRate ), true, true, false);
					//TTP 48614?? ????.
					//??????[??????????]
					//if( Item.pAttackSpeed + rValue.PhysicalAttackSpeed > 0 )
					//	AddTooltipItemOption(111, string( Item.pAttackSpeed + rValue.PhysicalAttackSpeed ), true, true, false);
				}
				//Weight
				if (Item.Weight != 0)
					AddTooltipItemOption(52, String(Item.Weight), true, true, false);
			}			

			//??????? ????, ????? ?????? ???? ???? ??? ??? ????, ??? ?????? ????? ???????.
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
			// ????????? ?????? ?????? ???????? ??¢¥?.
			// ?????? ???????? ?????? ???????? ??¢¥?. 
			// ??? ?????? ???????? ??¢¥?.
			//Debug( Item.CrystalType @  String(GetMagicalDefense(Item.CrystalType, Item.Enchanted, Item.mDefense, Item.Attribution) ));
			//????? 
			// ttp 72362, ????? ????? ??? (???? ?????? ????, ???? ?????? ??? ????)
			// ?????? ????????? ???? ?????? ??? ?? ???  201612?? ????
			if ( getInstanceUIData().getIsClassicServer() ) 
			{
				// (Item.SlotBitType != int64("206158430208")) &&
				if(  ( Item.SlotBitType != 536870912) && (Item.SlotBitType != 1073741824 ) &&  (Item.SlotBitType != 4194304 ) && (Item.SlotBitType != 1048576 ) && (Item.SlotBitType != 2097152 ) ) //&& Item.CrystalType > 0) //branch 111109 > ??? ???? ???? ??????, ???? ?????? ?????? ??? ???? ??????? ????
				{
					// ???? ??????? 0???? ? ??¯I ??? 
					if ( GetMagicalDefense(Item.CrystalType, Item.Enchanted, Item.mDefense, Item.Attribution) > 0 )  AddTooltipItemOption(99, String(GetMagicalDefense(Item.CrystalType, Item.Enchanted, Item.mDefense, Item.Attribution)), true, true, false,"chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);				
					AddTooltipItemBonus(Item.mDefense, nEnchantedMagicalDefenseBonus, 0, 7);
				}
			}
			else
			{
				//(Item.SlotBitType != int64("206158430208")) &&
				if(  (Item.SlotBitType != 1073741824 ) &&  (Item.SlotBitType != 4194304 ) && (Item.SlotBitType != 1048576 ) && (Item.SlotBitType != 2097152 ) ) //&& Item.CrystalType > 0) //branch 111109 > ??? ???? ???? ??????, ???? ?????? ?????? ??? ???? ??????? ????
				{
					// ???? ??????? 0???? ? ??¯I ??? 
					if ( GetMagicalDefense(Item.CrystalType, Item.Enchanted, Item.mDefense, Item.Attribution) > 0 )  AddTooltipItemOption(99, String(GetMagicalDefense(Item.CrystalType, Item.Enchanted, Item.mDefense, Item.Attribution)), true, true, false,"chatFontSize12",0,0,getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);				
					AddTooltipItemBonus(Item.mDefense, nEnchantedMagicalDefenseBonus, 0, 7);
				}
			}
			
			if (Item.Weight == 0)
				AddTooltipItemOption(52, " 0 ", true, true, false);
			else 
				AddTooltipItemOption(52, String(Item.Weight), true, true, false);
			
			//???????
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
			// ??????? ????? ???(2013.01.28)

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
				// ????????? bless?? ???, ?????????????? Enchant?? ???????. ?????????! - lancelot 2008. 11. 11.
				// ???
				AddTooltipItemOption(670, String(Item.Blessed), true, true, false);
				
				//branch GD35_0828 2013-12-18 luciper3 - ??? ????? ??????? ????? ??©¡??? ?????? ?????? ???? ????¢¥?.. 
				//                                       ???? ??????????? ?????? ??? ?????????¥í? ?????.
				// ??????
				//AddTooltipItemOption(671, GetLottoString(Item.Enchanted, Item.Damaged), true, true, false);
				AddTooltipItemOption(671, GetLottoString(Item.LookChangeItemID), true, true, false);
				//end of branch
			}
			else if (eEtcItemType == ITEME_RACE_TICKET)
			{
				// ???
				AddTooltipItemOption(670, String(Item.Enchanted), true, true, false);
				
				// ??????
				AddTooltipItemOption(671, GetRaceTicketString(Item.Blessed), true, true, false);
				
				//Money
				AddTooltipItemOption(744, String(Item.Damaged*100), true, true, false);
			}
			//Weight
			//~ if (Item.Price!=0)

			// ??? ???? ????? 0 ???? ? ??? 
			else if ( item.MaxUseCount > 0 ) 
			{
				AddCrossLine();
		        AddTooltipItemBlank(0);

				// ??? ??????
				AddTooltipText("<" $ GetSystemString (3801)  $ ">", true, true);
				
				// ???? ?©£?
				AddTooltipItemBlank(0);
				addTexture("l2ui_ct1.SkillWnd_DF_ListIcon_use", 12, 11, 12, 11, 3, 7);
				// ???? ?©£? 
				AddTooltipColorText(GetSystemString(2378) $ " : ", getColor(163,163,163,255), false, true, false, "", 0, TOOLTIP_LINE_HGAP);
				// ParamAdd ?¥ê? ?????? ???? ????.


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
				// MaxReuseDelay?? -1???, ???? ?©£??? ??????? ??? "1?? 1? ???(???? ???? 6:30 ????) ???? ??????? ???)

				//Debug ( Item.RemainReuseDelay $ Item.MaxReuseDelay ) ;
				if (Item.MaxReuseDelay < 0) m_Info.t_strText = GetSystemString ( 3804 ) ;
				else 
				{				
					// Condition Type?? "ReuseDelay" ??????? ???? ?? ????????? ???? ?©£??? ?????? m_Info.t_strText?? ??? ???
					if ( Item.RemainReuseDelay == 0 )  m_Info.t_strText = GetSystemString ( 3537 ) ;
					else 
					{
						m_Info.t_strText = MakeTimeStr(Item.RemainReuseDelay);
						ParamAdd(m_Info.Condition, "Type", "ReuseDelay");
					}
				}
				
				EndItem();

				// ??? ???? ???
				AddTooltipItemBlank(0);
				addTexture("l2ui_ct1.Icon.Tooltip_CubeIcon", 12, 11, 12, 11, 3, 7);
				AddTooltipColorText(GetSystemString(3802) $ " : ", getColor(163,163,163,255), false, true, false, "", 0, TOOLTIP_LINE_HGAP);
				AddTooltipColorText((item.MaxUseCount - item.CurUseCount)$"/"$item.MaxUseCount , getColor(176,155,121,255), false, true, false, "", 0, TOOLTIP_LINE_HGAP);
//				AddTooltipItemOption(3802, item.CurUseCount$"/"$item.MaxUseCount, false, true, false);
				
				// ?????? ??? ???
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
		//  ??? ?????? ??????
		//------------------------------------------------------------------------------------
		
		// ??????, ??? ???? (<??©¡? ???> ?? ????)
		AddTooltipEventSeventhdayOfSeventhMonth(Item);

		// ???????? ???, ?????? ??????
		AddTooltipItemDurability(Item);
		
		//?????? ????
		AddTooltipBR_MaxEnergy(Item);

		// ?????? ???? 
		if (Len(Item.Description)>0) 
		{
			AddCrossLine();
			AddTooltipItemBlank(TOOLTIP_LINE_HGAP);

			AddTooltipColorText(Item.Description, getColor(178,190,207,255), true, false);
		}	
		
		// ??? ?????? ????
		addSetitemTooltip( Item );
		
		//????? ?????? ??????.
		AddTooltipItemQuestList(Item);
		
		//?????? ???? (2015-03-11)
		AddWeaponEnsoulOption(Item);

		// ?????? ???? ???? 
		if ( item.bSecurityLock ) 
		{
			AddCrossLine();
			AddTooltipItemOption(3805, "", true, true, false,,,,getColor(230, 230, 230, 255));
			AddTooltipColorText(GetSystemString (3806 ) ,   getColor(178,190,207,255), true, true,,,,TOOLTIP_LINE_HGAP);			
		}

		// ??? ???????? ??????. ?? ?¥ê????????? ????? ??¢¥?.
		if ( TooltipType != "InventoryPet") AddTooltipItemAttributeGage(Item);
		
		// ?????????????
		AddTooltipItemWeaponLookChange(Item); //branch 110824
		
		// ???? ??????, ???? ???? 
		AddTooltipItemCurrentPeriod(Item);		
	}
	else
	{
		return;		
	}

	if (TooltipType == "Inventory" && IsBuilderPC())
	{
		AddTooltipText("ID : "$string(Item.Id.classID), true, true);
	}

	// ???????, ??? ?????? ???????? ???, ?????????? ??? ?????? ???? ?????.
	// ??????? ?????©ª? ??????? ????
	if (!IsAdena(Item.ID)) 
	{
		// ?????? ??????, ???? ????? ¨£???, ??? ???? ???? ????? ???? ?????.
		addForbidItemDesc(Item.ID);
		m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH;
	}

	//???? ???????? ??? ??? ???? ??????? ???? ??? ???? ???? ??? ??? ??.
	if ( item.CurrentPeriod > 0 ) setMakeTimeStrMaxWidth();
	setTooltipMinimumWidth ();
	
	//if ( item.ID.classID == 49032 ) Debug ( "getMaxWidth" @ getMaxWidth( item.ID.classID == 49032 )) ;

	ReturnTooltipInfo(m_Tooltip);
}   


function setTooltipMinimumWidth ()
{
	m_Tooltip.MinimumWidth = getMaxWidth(); //???? ?????? ID
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
			//?? ???? ?? ?? ??? ?? ????? ??? ?????? ??????? ??? ??.
			if ( m_Tooltip.DrawList[i].t_bDrawOneLine )
			{
				GetTextSizeDefault ( m_Tooltip.DrawList[i].t_strText , Width, Height ) ;

				//bLineBreak ??? ???? ??? ??? ???? ??? ????? ????.
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
// ???????? ???? ?? ????? ????
//----------------------------------------------------------------------------------------------------------------------------------------------------

// ?????? ???? ????, ???? ????, ??? 
// EP1.0 [0319] ???
function bool addForbidItemDesc(ItemID pItemID)
{
	local string forbidItemDesc, enableItemDesc;
	local bool flag;

	//????? ???? ?? ??? ???????? ??¢¥?.
	if ( getInstanceUIData().getIsClassicServer() ) return false;

	flag = false;
	
	// ??????, ???? ??? ??????? ??¢¥?
	class'UIDATA_ITEM'.static.GetItemDescriptionAdditionData(pItemID, forbidItemDesc, enableItemDesc);
	//enableItemDesc = "????/???? ??? ????"; // class'UIDATA_ITEM'.static.GetItemDescriptionAdditionData(pItemID);
	
	if (forbidItemDesc != "" || enableItemDesc != "")
	{
		AddCrossLine();

		AddTooltipItemBlank(TOOLTIP_LINE_HGAP);

		// ?????? ??? 
		if (enableItemDesc != "")
		{
			AddTooltipColorText(enableItemDesc, getColor(158, 127, 87, 255), true, false);
		}

		//getColor(138, 47, 47, 255)
		// ???, ???????, ???, ??? ??? ???? ???? ???.
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
	
	/*______10??? ???? ???__________
	 * | 38915 | 38916 | 38917 | 38918 |
	 * ---------------------------------
	 * | 38919 | 38920 | 38921 | 38922 |
	 * ---------------------------------
	 * 
	 * * ???????? ????
	 * _________________________________
	 * | 38907 | 38908 | 38909 | 38910 |
	 * ---------------------------------
	 * | 38911 | 38912 | 38913 | 38914 |
	 */
	// *?????????? ?? ???????? ???? ?????? ?????? ???? ???????
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

//??????? gfx?? ???? ???  ????? ??? 2013.01.29
function ReturnTooltip_NTT_GFXCARD(string param, ETooltipSourceType eSourceType)
{
	local ItemInfo Item;
	local string ItemName;
	local int ItemNameClass;
	//Debug( "ReturnTooltip_NTT_GFXCARD" @ ItemName );
	if (eSourceType == NTST_ITEM)
	{
		ParamToItemInfo(param, Item);
		
		//?????? ??? ???
		ItemName = class'UIDATA_ITEM'.static.GetRefineryItemName( Item.Name, Item.RefineryOp1, Item.RefineryOp2 );
		ItemNameClass = class'UIDATA_ITEM'.static.GetItemNameClass( Item.ID );

		AddTooltipItemName(ItemName, Item, ItemNameClass);		
		
		CardEventImgTooltip(Item);
	}
}

//?????? ???? ???? ????
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
	
	//???
	if(isFriend != 0)
	{
		AddTooltipItemColorOption(2273, GetSystemString(3175), 77, 255, 99, true, true, true);
	}
	else
	{
		AddTooltipItemColorOption(2273, GetSystemString(3176), 255, 66, 66, true, true, true);
	}
	
	//????
	if(isPledge != 0)
	{
		AddTooltipItemColorOption(314, GetSystemString(3179), 77, 255, 99, true, true, false);
	}
	
	else
	{
		AddTooltipItemColorOption(314, GetSystemString(3180), 255, 66, 66, true, true, false);
	}
		

	
	//????, ????? ?????????? ???? ??? ???.
	if(isMentoring != 0 && !getInstanceUIData().getIsClassicServer() )
	{
		AddTooltipItemColorOption(2767, GetSystemString(3177), 77, 255, 99, true, true, false);
	}
	else if ( !getInstanceUIData().getIsClassicServer() ) 
	{
		AddTooltipItemColorOption(2767, GetSystemString(3178), 255, 66, 66, true, true, false);
	}
		
	//????
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
// Macro , 2015-10-26, ????? ????, ????? ¨¨??? ??? ?????? ??????? ???
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

		// ?????? ???????? ??¢¥?.
		addItemIcon(Item, "");

		m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH;
		// ???
		AddTooltipText(Item.Name, false, true, true, "chatFontSize11", 5, 1);
		
		//????
		// ?????? ???? 
		if (Len(Item.Description) > 0) AddTooltipColorText(Item.Description, getColor(178,190,207,255), true, false);

		// Debug("Item.MacroCommand" @ Item.MacroCommand);

		// ??????
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
		// ?????? ?????? ?????
		else
		{			
			// ????? ???
			if (bCustomMacro)
			{
				for (idx = 0; idx < MACROCOMMAND_MAX_COUNT; idx++)
				{
					if (trim(macroInfo.CommandList[idx]) != "")
					{
						// ??? ??? ???? .. ??? (?????? ?????? ????? ??????? ????)
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
		
		// ?????? ???????? ??¢¥?.
		addItemIcon(Item, "");

		//??? ???
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine    = true;
		m_Info.t_strFontName     = "chatFontSize11";
		m_Info.nOffSetX          = 5;
		m_Info.nOffSetY          = 0;
		m_Info.t_strText         = Item.Name;
		EndItem();
		
		AddTooltipItemBlank(TOOLTIP_LINE_HGAP);

		//??? ????
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

		//Debug ( "??©¡? ?????? ?????? ???? ???" @  Item.AdditionalName @ Item.Level );

		GetSkillInfo( Item.ID.ClassID , Item.Level, Item.SubLevel, skillInfo );

		Item.IconName = skillInfo.TexName;
		
		//eShortCutType = EShortCutItemType(Item.ItemSubType);
		eItemParamType = EItemParamType(Item.ItemType);
		SkillLevel = Item.Level;
		
		m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH;
		
		//?????? ??? 
		addItemIcon(Item, "");

		//?????? ???
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = true;
		m_Info.nOffSetX = 5;
		m_Info.t_strText = Item.Name;
		m_Info.t_strFontName = "chatFontSize11";
		EndItem();
		
		// ??©¡??? ????? ?????? ???? ?????? ??????????. 
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
		
		//??? ????
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

		// ??©¡? ?????? ?????? ???? ???

		
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

		//???HP
		nTmp = class'UIDATA_SKILL'.static.GetHpConsume( Item.ID, Item.Level, item.SubLevel );
		if (nTmp>0)
		{			
			AddTooltipItemOption(1195, string(nTmp), true, true, false);//, "chatFontSize12", 0, 0, getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);
		}
		
		//???MP
		nTmp = class'UIDATA_SKILL'.static.GetMpConsume( Item.ID, Item.Level, Item.SubLevel );
		if (nTmp>0)
		{
			AddTooltipItemOption(320, String(nTmp), true, true, false, "chatFontSize12", 0, 0, getInstanceL2Util().BrightWhite, getInstanceL2Util().ColorYellow);
		}
		
		//??????
		nTmp = class'UIDATA_SKILL'.static.GetCastRange( Item.ID, Item.Level, Item.SubLevel );
		if (nTmp >= 0)
		{
			AddTooltipItemOption(321, String(nTmp), true, true, false);
		}

		////??? ???? ?©£?
		if ((skillInfo.HitTime + skillInfo.CoolTime) > 0)
		{
			// luciper3 - ???????? ???? ??????? ??????.
			//AddTooltipItemOption(2377, MakeBuffTimeStr(int(skillInfo.HitTime + skillInfo.CoolTime)), true, true, false);
			AddTooltipItemOption(2377,util.MakeTimeString(skillInfo.HitTime,skillInfo.CoolTime),true,true,false);
		}
		
		////??? ???? ?©£?
		if (skillInfo.ReuseDelay > 0)
		{
			AddTooltipItemOption(2378, MakeBuffTimeStr(int(skillInfo.ReuseDelay)), true, true, false);
		}
		
		//????
		if (Len(Item.Description) > 0) 
		{
			AddCrossLine();
			AddTooltipItemBlank(TOOLTIP_LINE_HGAP);
			AddTooltipColorText(Item.Description, getColor(178,190,207,255), true, false);
		}

		// 2014.08.04 ?????©¡? ??? ?????? ???? ???? ???
		// ??? ??©¡? ???? ???
		if (Len(item.AdditionalName)>0) 
		{
			AddCrossLine();
			AddTooltipItemBlank(TOOLTIP_LINE_HGAP);
			// ??? ??? 

			AddTooltipColorText(GetSystemString(3350) $ " : ", getColor(163,163,163,255), true, false);			
			AddTooltipColorText(item.AdditionalName, getColor(255,217,105,255), false, true);
			AddTooltipColorText(skillInfo.EnchantDesc, getColor(178,190,207,255), true, false);

			// ???? ????©§? ???? ???? ???? ?????? ????? ????
			setTooltipMinimumWidth ();
		}
	}
	else
	{
		return;
	}

	if (IsBuilderPC())
	{
		AddTooltipText("Skill ID : "$string(Item.Id.classID), true, true);
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
		
		//?????? ???
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_strText = Item.Name;
		EndItem();
		
		ShowLevel = Item.Level;		
		
		//ex) " Lv "
		// ???? ?????? ??? ???? ??©ª? ???? ??¢¥?. 
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
			
			//??? ????		
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
		
		//?????©£?
		// ct3 ????? ???? - ????
		//if ((GetDebuffType(Item.ID, Item.Level) == 0) && Item.Reserved>=0)
		//???????? ????.
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
				// ????? ToppingRemainTime, RemainTime ???? ?????? ??????, ??????????? ?©£??? ?? ??? ??????? ???? ??.
				//Debug ( "ToppingRemainTime ?? type ????");
				ParamAdd(m_Info.Condition, "Type", "ToppingRemainTime");
			}
			else
			{
				m_Info.t_strText = MakeBuffTimeStr(Item.Reserved);
				ParamAdd(m_Info.Condition, "Type", "RemainTime");
			}			
			
			EndItem();
		}
		
		//????
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

		// 2014.08.04 ?????©¡? ??? ?????? ???? ???? ???
		// ??? ??©¡? ???? ???
		if (Len(item.AdditionalName)>0) 
		{
			AddCrossLine();
			// ??? ??? 

			AddTooltipColorText(GetSystemString(3350) $ " : ", getColor(163,163,163,255), true, false);			
			AddTooltipColorText(item.AdditionalName, getColor(255,217,105,255), false, true);
			AddTooltipColorText(skillInfo.EnchantDesc, getColor(178,190,207,255), true, false);

			// ???? ????©§? ???? ???? ???? ?????? ????? ????
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
// LOOCKCHANGEITEM ???? ????? ???? 
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
		
		//?????? ???
		AddTooltipItemName(Item.Name, Item, 1);
		
		//Grade Mark
		AddTooltipItemGrade(Item);
		
		//????
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
		
		//?????? ???
		AddTooltipItemName(Item.Name, Item, 1);
		
		//Grade Mark
		AddTooltipItemGrade(Item);
				
		//????
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
		
		//?????? ???
		AddTooltipItemName(Item.Name, Item, 1);
		
		//Grade Mark
		AddTooltipItemGrade(Item);
		
		//????
		if (bShowPrice)
		{
			strAdena = String(Item.Price);
			strAdenaComma = MakeCostString(strAdena);
			AdenaColor = GetNumericColor(strAdenaComma);
			
			//???? : xxx,xxx,xxx
			AddTooltipItemOption(641, strAdenaComma $ " ", true, true, false);
			SetTooltipItemColor(AdenaColor.R, AdenaColor.G, AdenaColor.B, 0);
			
			//"?????"
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_color = AdenaColor;
			m_Info.t_ID= 469;
			EndItem();
			
			//?¬à???? ?????
			if  (strAdena != "")
			{
				AddTooltipItemOption(0, "(" $ ConvertNumToText(strAdena) $ ")", false, true, false);
				SetTooltipItemColor(AdenaColor.R, AdenaColor.G, AdenaColor.B, 0);
			}
		}
		
		//Weight
		AddTooltipItemOption(52, String(Item.Weight), true, true, false);
		
		//????
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
			//?????? ??? ???
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

					//??? ???
					StartItem();
					m_Info.eType = DIT_TEXT;
					m_Info.t_bDrawOneLine = true;
					m_Info.t_strText = Item.Name;
					EndItem();
					
					//??? ????
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
				//?????? ???
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
			
			
			//????? ????...
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
			
			//?????~
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

			//?????? ??? ???
			ItemName = class'UIDATA_ITEM'.static.GetRefineryItemName( Item.Name, Item.RefineryOp1, Item.RefineryOp2 );

			switch (eShortCutType)
			{
			case SCIT_ITEM:
				//branch
				AddPrimeItemSymbol(Item);
				//end of branch
				//??©­? ex) "+10"
				AddTooltipItemEnchant(Item);

				//?????? ???
				AddTooltipItemName(ItemName, Item, 1);

				//Grade Mark
				AddTooltipItemGrade(Item);

				//?????? ????
				AddTooltipItemCount(Item);
				break;
			case SCIT_SKILL:
			case SCIT_ATTRIBUTE:
				//?????? ???
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

				//??? ????
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
				//MP???
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
				//?????? ???
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
		
		//?????? ???
		AddTooltipItemName(Item.Name, Item, 1);
		
		//Grade Mark
		AddTooltipItemGrade(Item);
		
		//ex) "???? : 2"
		AddTooltipItemOption(736, String(Item.Reserved64), true, true, false);
		
		//ex) "?????? : 0"
		AddTooltipItemOption(737, String(Item.ItemNum), true, true, false);
		
		//????
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
		
		//ex) "???? : ?????????"
		AddTooltipItemOption(391, GetClassType(int(record.LVDataList[2].szData)), true, true, true);
		// ??? ??? 
		//ex) "??? : ??? ???? ?????! " 
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
		
		//ex) "???? : ?????????"
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


		// ??? ?? ??
		if (record.LVDataList[0].szData == GetSystemString(869))
		{
			// ??? ????? ?????? ??¢¥?.
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

		// ??? ?? (??? ??)
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

		// ???
		addToolTipDrawList(m_Tooltip, addDrawItemText(GetSystemString(3430), getInstanceL2Util().Yellow, "", true));

		// ???? desc 
		addToolTipDrawList(m_Tooltip, addDrawItemText(desc, getInstanceL2Util().ColorDesc, "", true));
		AddTooltipItemBlank(10);

		// ??? ???
		addToolTipDrawList(m_Tooltip, addDrawItemText(GetSystemString(3442), getInstanceL2Util().ColorYellow, "", true, true));

		// ??? ???, ??? ????? ??? ???
		for (i = 0; i < totalCnt; i++)
		{			
			ParseInt(toolTipParam, "item_"  $ String(i), nItemID);
			ParseINT64(toolTipParam, "count_" $ String(i), nItemCount);

			addToolTipDrawList(m_Tooltip, addDrawItemBlank(5));
			addToolTipDrawList(m_Tooltip, addDrawItemText(class'UIDATA_ITEM'.static.GetItemName( GetItemID(nItemID) ), getInstanceL2Util().White, "", true, true));
			addToolTipDrawList(m_Tooltip, addDrawItemText("x" @ MakeCostString(String(nItemCount)), getInstanceL2Util().White, "", true, true));
			//Debug("??????? nItemID " @ nItemID);
			//Debug("??????? nItemCount" @ nItemCount);
		}
		if (totalCnt <= 0)
		{
			addToolTipDrawList(m_Tooltip, addDrawItemText(GetSystemString(27), getInstanceL2Util().White, "", true, true));
		}

		addToolTipDrawList(m_Tooltip, addDrawItemBlank(10));

		// ??? ??
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
// ??? ??? - ????? - ??? ??? nReserved1 ?? ?????? ?????? ??????? ?????? ??????.
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
// ??? ???? - ????? ?????? ???? 
function ReturnTooltip_NTT_SellItemList (string param, ETooltipSourceType eSourceType)
{
	if (eSourceType == NTST_LIST)
	{
		// ??? ????????? ?¥ê??? ?????? ?????? ???????	
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
		//Width????!

		GetTextSizeDefault(getWarSituationString(record.LVDataList[2].nReserved1), Width1, Height);
		GetTextSizeDefault(GetSystemString(2968) $ record.LVDataList[4].nReserved1, Width2, Height);
		if (Width2>Width1)
			Width1 = Width2;
		if (TOOLTIP_MINIMUM_WIDTH>Width1)
			Width1 = TOOLTIP_MINIMUM_WIDTH;
		m_Tooltip.MinimumWidth = Width1;

		

		// ???? ?????? ????????
		if(record.LVDataList[5].nReserved1 > 0)
		{
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.bLineBreak = true;	
			//???? ?©£?
			m_Info.t_strText = GetSystemString(1108) $ ":" $ getSecToDateStr(record.LVDataList[6].nReserved1, false);
			EndItem();
			toolTipLineCount++;
		
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.bLineBreak = true;	
			//???? ????
			m_Info.t_strText = GetSystemString(2986) $ ":" $ record.LVDataList[5].nReserved1 $ GetSystemString(1013);
			EndItem();
			toolTipLineCount++;
		}
		else
		{		
			// 0,1,2,3,4 
			// ???? ??? , ??? ?±r, ???? ????.. ???? ????? ???? ??? ????
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
			
			// ?????©£? -> ???????
			if (record.LVDataList[3].nReserved1 > -500)
			{
				StartItem();
				m_Info.eType = DIT_TEXT;
				m_Info.bLineBreak = true;
				m_Info.t_color.R = 175;
				m_Info.t_color.G = 152;
				m_Info.t_color.B = 120;
				m_Info.t_color.A = 255;
				//???????????:????
				m_Info.t_strText = GetSystemString(2968) $ record.LVDataList[4].nReserved1;
				EndItem();
				toolTipLineCount++;
			}
		}
		// ?????? ?????? ?????.. ?????? ??¢¥?
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

//???? ????(2010.03.30) ???
function ReturnTooltip_NTT_POSTINFO(string param, ETooltipSourceType eSourceType)
{
	local LVDataRecord record;
	
	if (eSourceType == NTST_LIST)
	{
		ParamToRecord( param, record );

		//ex) "???? : ?????????"
		AddTooltipItemOption(391, GetClassType(int(record.LVDataList[1].szData)), true, true, true);
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}


//???? ????(2010.02.22 ~ 03.08) ???
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

		//ex) "???? : ?????????"
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
	//ex)??? ???? : 
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
		
		//ex) "???? : ?????????"
		AddTooltipItemOption(391, GetClassType(int(record.LVDataList[1].szData)), true, true, true);
		
		AddTooltipItemBlank(0);
		//ex)??? ???? : 
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_color.R = 163;
		m_Info.t_color.G = 163;
		m_Info.t_color.B = 163;
		m_Info.t_color.A = 255;
		m_Info.t_strText = GetSystemString( 2276 ) $ " : ";
		EndItem();
		
		//????
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
		
		//ex) "???? : ?????????"
		AddTooltipItemOption(391, GetClassType(int(record.LVDataList[1].szData)), true, true, true);
		
		//???? ????(2010.02.22 ~ 03.08) ???
		//ex)???? ??? : ?????
		//AddTooltipItemOption(471, GetZoneNameWithZoneID(int(record.LVDataList[3].szData)), true, true, true);
		
		/*
		AddTooltipItemBlank(0);
		//???????
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = false;
		m_Info.t_color.R = 163;
		m_Info.t_color.G = 163;
		m_Info.t_color.B = 163;
		m_Info.t_color.A = 255;
		m_Info.t_strText = GetSystemString( 2276 ) @ ":";
		EndItem();		
		
		//????
		
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
		//ex)??? ???? : 
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_color.R = 163;
		m_Info.t_color.G = 163;
		m_Info.t_color.B = 163;
		m_Info.t_color.A = 255;
		m_Info.t_strText = GetSystemString( 2276 ) $ " : ";
		//m_Info.t_strText = "??? ???? : ";
		EndItem();
		
		//????
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

//???? ??? UNION ???? ?????? ?????? ???.
/////////////////////////////////////////////////////////////////////////////////
// UINONLIST
function ReturnTooltip_NTT_UNIONLIST(string param, ETooltipSourceType eSourceType)
{
	local LVDataRecord record;
	
	if (eSourceType == NTST_LIST)
	{
		ParamToRecord( param, record );
		
		//ex) "???? : ?????????"
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
		
		//????? ???
		AddTooltipItemOption(1200, record.LVDataList[0].szData, true, true, true);
		
		//?????
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
		
		//????? ????
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
		
		//????? ???
		AddTooltipItemOption(1200, record.LVDataList[0].szData, true, true, true);
		
		//????????
		AddTooltipItemOption(1201, record.LVDataList[1].szData, true, true, false);
		
		//Width????!
		GetTextSizeDefault(GetSystemString(1200) $ " : " $ record.LVDataList[0].szData, Width1, Height);
		GetTextSizeDefault(GetSystemString(1201) $ " : " $ record.LVDataList[1].szData, Width2, Height);
		if (Width2>Width1)
			Width1 = Width2;
		if (TOOLTIP_MINIMUM_WIDTH>Width1)
			Width1 = TOOLTIP_MINIMUM_WIDTH;
		m_Tooltip.MinimumWidth = Width1 + 30;
		
		//???????
		AddTooltipItemOption(922, record.LVDataList[2].szData, true, true, false);
		
		//?????
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
		
		//?????????
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
		
		// ???? or ??? ???
		AddTooltipItemOption(0, record.LVDataList[0].szData, false, true, true);
		
		// ????
		AddTooltipItemOption(537, record.LVDataList[idx1].szData, true, true, false);

		// ???? ???1
		AddTooltipItemOption(1134, record.LVDataList[idx2].szData, true, true, false);
		
		// ???? ???2
		AddTooltipItemOption(1135, record.LVDataList[idx3].szData, true, true, false);
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

// [????? ?????? ???? ???]
function ReturnTooltip_NTT_QUESTREWARDS(string param, ETooltipSourceType eSourceType)
{
	// [????? ?????? ???? ???] ?? ?¥ê¬á? ????? ?????? ?????? ??¢¥? ??? ????? ?? ?? ???????.
	// 2009.10.14
	// ReturnTooltip_NTT_ITEM(param, "Inventoty", eSourceType);
	ReturnTooltip_NTT_ITEM(param, "QuestReward", eSourceType);
}

//???????? ?????? ??? ?????????.
function SetTooltipItemColor(int R, int G, int B, int Offset)
{
	local int idx;
	idx = m_Tooltip.DrawList.Length-1-Offset;
	m_Tooltip.DrawList[idx].t_color.R = R;
	m_Tooltip.DrawList[idx].t_color.G = G;
	m_Tooltip.DrawList[idx].t_color.B = B;
	m_Tooltip.DrawList[idx].t_color.A = 255;
}

//??©­?(???? ???? ????)
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

//?????? ??? + AdditionalName
function AddTooltipItemName(string Name, ItemInfo Item, int AddTooltipItemName, optional string fontName, optional int offsetX, optional int offsetY)
{
	local string tmStr;

	StartItem();
	m_Info.eType = DIT_TEXT;
	m_Info.t_bDrawOneLine = true;
	switch (AddTooltipItemName)
	{
		case 0: //???
		m_Info.t_color.R = 137;
		m_Info.t_color.G = 137;
		m_Info.t_color.B = 137;
		m_Info.t_color.A = 255;
		break;
		case 1: //???
		m_Info.t_color.R = 255;
		m_Info.t_color.G = 255;
		m_Info.t_color.B = 255;
		m_Info.t_color.A = 255;
		break;
		case 2: //???
		m_Info.t_color.R = 255;
		m_Info.t_color.G = 251;
		m_Info.t_color.B = 4;
		m_Info.t_color.A = 255;
		break;
		case 3: //????
		m_Info.t_color.R = 240;
		m_Info.t_color.G = 68;
		m_Info.t_color.B = 68;
		m_Info.t_color.A = 255;
		break;
		case 4: //???
		m_Info.t_color.R = 33;
		m_Info.t_color.G = 164;
		m_Info.t_color.B = 255;
		m_Info.t_color.A = 255;
		break;
		case 5: //????
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

	// ??? ??? 
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
		
		// S80 ???????? ??Äî ???? ?????? ????? ??? 2??? ?©ª???. 6, 7
		// R95, R99 ???????? ??Äî ???? ?????? ????? ??? 2??? ?©ª???. 9, 10
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

//		nSumWidth = nSumWidth + m_Info.nOffSetX + m_Info.u_nTextureWidth; ?????? ??? ?? ???? ????
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

//???? ????
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

//??? ?????? ??????
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
	// ???? ?????? ???
	if (Item.AttackAttributeValue  > 0)
	{	
		AddCrossLine();
		SetAttackAttribute(Item.AttackAttributeValue,ATTRIBUTE_FIRE);
		SetAttackAttribute(Item.AttackAttributeValue,ATTRIBUTE_WATER);
		SetAttackAttribute(Item.AttackAttributeValue,ATTRIBUTE_WIND);
		SetAttackAttribute(Item.AttackAttributeValue,ATTRIBUTE_EARTH);
		SetAttackAttribute(Item.AttackAttributeValue,ATTRIBUTE_HOLY);
		SetAttackAttribute(Item.AttackAttributeValue,ATTRIBUTE_UNHOLY); //?????? ?????????? ?????.		

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
	else	// ??? ?????? ???
	{
		SetDefAttribute(Item.DefenseAttributeValueFire,ATTRIBUTE_FIRE);
		SetDefAttribute(Item.DefenseAttributeValueWater,ATTRIBUTE_WATER);
		SetDefAttribute(Item.DefenseAttributeValueWind,ATTRIBUTE_WIND);
		SetDefAttribute(Item.DefenseAttributeValueEarth,ATTRIBUTE_EARTH);
		SetDefAttribute(Item.DefenseAttributeValueHoly,ATTRIBUTE_HOLY);
		SetDefAttribute(Item.DefenseAttributeValueUnholy,ATTRIBUTE_UNHOLY); //?????? ?????????? ?????.

		if(Item.DefenseAttributeValueFire != 0) //????? ??? ???? ?????
		{
			if( BLine == false )
			{
				AddCrossLine();
				BLine = true;
			}
			textureName[ATTRIBUTE_FIRE] = "L2UI_CT1.Gauges.Gauge_DF_Attribute_FIRE";
			tooltipStr[ATTRIBUTE_FIRE] =GetSystemString(1623) $ " Lv " $ String(DefAttLevel[ATTRIBUTE_FIRE]) $ " ("$ GetSystemString(1622) $ " " $ GetSystemString(54) $ " " $ String(Item.DefenseAttributeValueFire) $")";
		}
		if(Item.DefenseAttributeValueWater != 0) //?? ??? ???? ?????
		{
			if( BLine == false )
			{
				AddCrossLine();
				BLine = true;
			}
			textureName[ATTRIBUTE_WATER] = "L2UI_CT1.Gauges.Gauge_DF_Attribute_WATER";
			tooltipStr[ATTRIBUTE_WATER] =GetSystemString(1622) $ " Lv " $ String(DefAttLevel[ATTRIBUTE_WATER]) $ " ("$ GetSystemString(1623) $ " " $ GetSystemString(54) $ " " $String(Item.DefenseAttributeValueWater) $ ")";
		}
		if(Item.DefenseAttributeValueWind != 0) //??? ??? ???? ?????
		{
			if( BLine == false )
			{
				AddCrossLine();
				BLine = true;
			}
			textureName[ATTRIBUTE_WIND] = "L2UI_CT1.Gauges.Gauge_DF_Attribute_WIND";
			tooltipStr[ATTRIBUTE_WIND] =GetSystemString(1625) $ " Lv " $ String(DefAttLevel[ATTRIBUTE_WIND]) $ " ("$ GetSystemString(1624) $ " " $ GetSystemString(54) $ " " $String(Item.DefenseAttributeValueWind) $")";
		}
		if(Item.DefenseAttributeValueEarth != 0) //?? ??? ???? ?????
		{
			if( BLine == false )
			{
				AddCrossLine();
				BLine = true;
			}
			textureName[ATTRIBUTE_EARTH] = "L2UI_CT1.Gauges.Gauge_DF_Attribute_EARTH";
			tooltipStr[ATTRIBUTE_EARTH] =GetSystemString(1624) $ " Lv " $ String(DefAttLevel[ATTRIBUTE_EARTH]) $ " ("$ GetSystemString(1625) $ " " $ GetSystemString(54) $ " " $String(Item.DefenseAttributeValueEarth) $ ")";
		}
		if(Item.DefenseAttributeValueHoly != 0) //??? ??? ???? ?????
		{
			if( BLine == false )
			{
				AddCrossLine();
				BLine = true;
			}
			textureName[ATTRIBUTE_HOLY] = "L2UI_CT1.Gauges.Gauge_DF_Attribute_DIVINE";
			tooltipStr[ATTRIBUTE_HOLY] =GetSystemString(1627) $ " Lv " $ String(DefAttLevel[ATTRIBUTE_HOLY]) $ " ("$ GetSystemString(1626) $ " " $ GetSystemString(54) $ " " $ String(Item.DefenseAttributeValueHoly) $")";
		}
		if(Item.DefenseAttributeValueUnholy != 0) //???? ??? ???? ?????
		{
			if( BLine == false )
			{
				AddCrossLine();
				BLine = true;
			}
			textureName[ATTRIBUTE_UNHOLY] = "L2UI_CT1.Gauges.Gauge_DF_Attribute_DARK";
			tooltipStr[ATTRIBUTE_UNHOLY] =GetSystemString(1626) $ " Lv " $ String(DefAttLevel[ATTRIBUTE_UNHOLY]) $ " ("$ GetSystemString(1627) $ " " $ GetSystemString(54) $ " " $String(Item.DefenseAttributeValueUnholy) $ ")";
		}
		// ??? ?????? ???
		BLine = false;
	}

	if (Item.AttackAttributeValue  > 0)//??????????
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
			
			// ??? ?????? 
			//addTooltipTexture(GetAttributeIcon(i),16,16, 13,13, true, false, 2,2);

			//????? ?????? ???? ????? ???. 
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
			if( m_Info.u_nTextureWidth > 140) m_Info.u_nTextureWidth = 140;	//????? ?? 140????.. ??
			m_Info.u_nTextureHeight = 7;
			m_Info.u_strTexture = textureName[i];
			EndItem();
		}
	
	}
	else{ //??? ????? ???
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
			
			//????? ?????? ???? ????? ???. 
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
			if( m_Info.u_nTextureWidth > 140) m_Info.u_nTextureWidth = 140;	//????? ?? 140????.. ??
			m_Info.u_nTextureHeight = 7;
			m_Info.u_strTexture = textureName[i];
			EndItem();
		}
	}	
}


// ???? ??????, ???? ???? 
function  AddTooltipItemCurrentPeriod(ItemInfo Item)
{
	// ???? ??????
	if ( Item.CurrentPeriod > 0)
	{
		//?????
		AddCrossLine();
		AddTooltipItemBlank(0);
		
		//<???? ????>
		//branch120516
		if(Item.LookChangeItemID > 0 && Item.Id.ClassID != 4442) //branch GD35_0828 2013-12-18 luciper3 - ?????? ?????..
		{
			// ???? ????
			AddTooltipItemOption(5144, "", true, false, false);
		}
		else
		{
			// <???? ??????>
			AddTooltipItemOption(1739, "", true, false, false,);
		}			
		SetTooltipItemColor(255, 255, 255, 0);
		//end of branch
		
		AddTooltipItemBlank(0);
		addTexture("l2ui_ct1.SkillWnd_DF_ListIcon_use", 12, 11, 12, 11, 3, 7);
		// ???? ?©£? 
		AddTooltipColorText(GetSystemString(1199) $ " : ", getColor(163,163,163,255), false, true, false, "", 0, TOOLTIP_LINE_HGAP);
		
		// ParamAdd ?¥ê? ?????? ???? ????.
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
		
		// ??? ?????? ???? ?©£??? ???? ??? ???? ?????? bDrawOneLine?? ???? ?????? ???? ???????? ???? 
		// ????????? ???? ????? ???. 
		ParamAdd(m_Info.Condition, "Type", "PeriodTime");
		EndItem();
		
	}
}

// ???? ?????? ???? ?? : 22?? 22?©£? 22?? ???????? ???? ?????? ????
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

 	if(Item.LookChangeItemID > 0 && Item.Id.ClassID != 4442 ) //branch GD35_0828 2013-12-18 luciper3 - ?????? ?????..
 	{
		//?????
		AddCrossLine();
		
		//<???? ??????>
		//branch 111109

		//SetTooltipTextColor( 230, 230, 230, 255 );
		//getColor(230, 230, 230, 255)
				
		if(Item.BodyPart == 25 || Item.BodyPart == 26 || Item.BodyPart == 10 ) //?????????
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

//????? ???????? ????? ??? ???
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
			//????? ??? (???, ???, ????, ??? ????)			
			switch (Class'UIDATA_QUEST'.static.GetQuestIscategory( Item.RelatedQuestID[i], 1 ))
			{
				case 0:
					questTypeStr = GetSystemString(862);
					break;

				case 1:
					questType = class'UIDATA_QUEST'.static.GetQuestType(Item.RelatedQuestID[i], 1);
					if ( questType == 4 || questType == 5 )
						questTypeStr = GetSystemString( 2788 ); //???? ????? 
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
				//<???? ?????>
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


// ????? ???????? ?????????? ????	//??? ????? ?????????? ?????¢¥?. 

function SetAttackAttribute(int Attvalue, int type)
{
	if( AttValue >= 375)	// 9??	375 ~ 450
	{
		AttackAttLevel[type] = 9;
		AttackAttMaxValue[type] = 75;
		AttackAttCurrValue[type] = AttValue - 375;
	}
	else if( AttValue >= 325)	// 8??	325 ~ 375
	{
		AttackAttLevel[type] = 8;
		AttackAttMaxValue[type] = 50;
		AttackAttCurrValue[type] = AttValue - 325;
	}
	else if( AttValue >= 300)	// 7??	300 ~ 325
	{
		AttackAttLevel[type] = 7;
		AttackAttMaxValue[type] = 25;
		AttackAttCurrValue[type] = AttValue - 300;
	}
	else if( AttValue >= 225)	// 6??	225 ~ 300
	{
		AttackAttLevel[type] = 6;
		AttackAttMaxValue[type] = 75;
		AttackAttCurrValue[type] = AttValue - 225;
	}
	else if( AttValue >= 175)	// 5??	175 ~ 225
	{
		AttackAttLevel[type] = 5;
		AttackAttMaxValue[type] = 50;
		AttackAttCurrValue[type] = AttValue - 175;
	}
	else if( AttValue >= 150)	// 4??	150 ~ 175
	{
		AttackAttLevel[type] = 4;
		AttackAttMaxValue[type] = 25;
		AttackAttCurrValue[type] = AttValue - 150;
	}
	else if( AttValue >= 75)	// 3??	75 ~ 150
	{
		AttackAttLevel[type] = 3;
		AttackAttMaxValue[type] = 75;
		AttackAttCurrValue[type] = AttValue - 75;
	}
	else if( AttValue >= 25)	// 2??	25~ 75
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
// ????? ???????? ?????????? ????	//??? ????? ?????????? ?????¢¥?. 


function SetDefAttribute(int Defvalue, int type)
{
	if( DefValue >= 150)	// 9??		150~180
	{
		DefAttLevel[type] = 9;
		DefAttMaxValue[type] = 30;
		DefAttCurrValue[type] = DefValue - 150;
	}
	else if( DefValue >= 132)	// 8??	132 ~ 150
	{
		DefAttLevel[type] = 8;
		DefAttMaxValue[type] = 18;
		DefAttCurrValue[type] = DefValue - 132;
	}
	else if( DefValue >= 120)	// 7??	120 ~ 132
	{
		DefAttLevel[type] = 7;
		DefAttMaxValue[type] = 12;
		DefAttCurrValue[type] = DefValue - 120;
	}
	else if( DefValue >= 90)	// 6??	90 ~ 120
	{
		DefAttLevel[type] = 6;
		DefAttMaxValue[type] = 30;
		DefAttCurrValue[type] = DefValue - 90;
	}
	else if( DefValue >= 72)	// 5??	72 ~ 90
	{
		DefAttLevel[type] = 5;
		DefAttMaxValue[type] = 18;
		DefAttCurrValue[type] = DefValue - 72;
	}
	else if( DefValue >= 60)	// 4??	60 ~ 72
	{
		DefAttLevel[type] = 4;
		DefAttMaxValue[type] = 12;
		DefAttCurrValue[type] = DefValue - 60;
	}
	else if( DefValue >= 30)	// 3??	30 ~ 60
	{
		DefAttLevel[type] = 3;
		DefAttMaxValue[type] = 30;
		DefAttCurrValue[type] = DefValue - 30;
	}
	else if( DefValue >= 12)	// 2??	// 12 ~ 30
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

// BR ?????? ????
function AddTooltipBR_MaxEnergy(ItemInfo item)
{
	//?????? ????
	if (Item.BR_MaxEnergy > 0)
	{
		//?????
		AddTooltipItemBlank(TOOLTIP_LINE_HGAP);
		//<?????? ????>
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

// ???? ??? 
function AddTooltipRefinery(ItemInfo item)
{
	local string strDesc1, strDesc2, strDesc3;
	local int ColorR, ColorG, ColorB, Quality;	
	
	//???????
	if (Item.RefineryOp1 != 0 || Item.RefineryOp2 != 0)
	{
		//?????
		AddTooltipItemBlank(2);
		
		//"[???????]"
		//AddSectionTitleBoader();
		AddTooltipItemOption(1490, "", true, false, false);
		SetTooltipItemColor(255, 255, 255, 0);
		AddTooltipItemBlank(2);
		
		//?¡À??? ???
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
		
		if(Item.SlotBitType == 8192) // ????? ???? ????? ????????? ??? ????..
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

		//"????…Z???? ???/??? ???"
		//"????? ??? ???? ???? ??? ??? ??.
		if(!getInstanceUIData().getIsClassicServer() && Item.SlotBitType != 8192)
		{
			AddTooltipItemOption(1491, "", true, false, false);
			SetTooltipItemColor(ColorR, ColorG, ColorB, 0);
		}

		//?????
		AddTooltipItemBlank(2);
	}	
}

// ??? ??? ??? (2015-03-11)
function AddWeaponEnsoulOption(ItemInfo weaponInfo)
{
	local EnsoulOptionUIInfo optionInfo;
	local int i, n, cnt, optionID;
	local bool bUseTitle;

	if (weaponInfo.itemType != EItemType.ITEM_WEAPON) return;

	bUseTitle = true;
	// ??? ????? ???? (2015-02-09 ???)
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
					//?????
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

// <??©¡????> ,(<??©¡? ???> ?? ????),  (??????, ??? ???¥å?) 
function AddTooltipEventSeventhdayOfSeventhMonth(ItemInfo item)
{
	//local string strDesc1, strDesc2, strDesc3;
	//local int ColorR, ColorG, ColorB;
	local int useHeadTitle;
	
	// [??????, ??? ????] item enchant option - by jin 09/08/05
	if (Item.EnchantOption1 != 0 || Item.EnchantOption2 != 0 || Item.EnchantOption3 != 0)
	{
		addDescEventSeventhday(Item.EnchantOption1, useHeadTitle);
		addDescEventSeventhday(Item.EnchantOption2, useHeadTitle);
		addDescEventSeventhday(Item.EnchantOption3, useHeadTitle);
	}
}

// <??©¡????>, AddTooltipEventSeventhdayOfSeventhMonth ?¥ì? ???, 
// useHeadTitle ?? <??©¡? ???> ???? ??? ????? ???¢¬? ??? ???????.
// ???? ??? ??? ???? ?? ??©¡? ????? ???? ??? ?????? ???? ????
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
					
					//"[??©¡????]"
					AddTooltipItemOption(2214, "", true, false, false);
					SetTooltipItemColor(255, 255, 255, 0);
					AddTooltipItemBlank(TOOLTIP_LINE_HGAP);
				}
			}

			//?¡À??? ???
			if (nEnchantOption != 0)
			{
				// [??????, ???????] ???? ????? ??? ?????? 1?? ?????? ???. - by jin 09/08/06
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

// ????????, ??????
function AddTooltipItemDurability(ItemInfo item)
{
	local Color tempColor;

	// ???????? ???, ?????? ??????, ????? ???? ??
	if (Item.CurrentDurability >= 0 && Item.Durability > 0)
	{
		//?????
		AddTooltipItemBlank(TOOLTIP_LINE_HGAP);
		
		//<???? ???? ????>
		AddTooltipItemOption(1492, "", true, false, false);
		SetTooltipItemColor(255, 255, 255, 0);
		
		// ????????/?????:
		AddTooltipColorText(GetSystemString(1493), getColor(163,163,163,255), true, true);

		if (Item.CurrentDurability+1 <= 5)
			tempColor = getColor(255,0,0,255);
		else
			tempColor = getColor(176,155,121,255);
		// ????????/?????   <- ???
		AddTooltipColorText(" " $ Item.CurrentDurability $ "/" $ Item.Durability, tempColor, false, true);
		AddTooltipItemBlank(TOOLTIP_LINE_HGAP);

		//"???/??? ???"
		// AddTooltipItemOption(1491, "", true, false, false);
		
		//?????
		//if (Len(Item.Description)>0) AddTooltipItemBlank(12);
	}
}


//branch, p??? 13 x 13 ???, ??? ?? ©¦?? ??????? ??? ??.
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


//??? ??????.
function addSetitemTooltip( ItemInfo Item )
{
	local int i;
	local int j;
	local string strTmp;
	local ItemID tmpItemID;
	local int SetID;
	//?? ??? ?????? ????
	local int totalNum;

	local bool IsSigil;	
	local ItemInfo tmpInfo;
	
	//?????????? ???.
	if( IsValidItemID(Item.ID) )
	{
		SetItemLineInsert( Item.ID, 0 );
		AddTooltipItemBlank(4);
		//AddCrossLine();

		//TOOLTIP_SETITEM_MAX ?? 3?????? setitem?? ???? ??.
		//0 -> 5????? ??????? ?????? (???, ????, ??, ?????, ????)
		//1 -> ????, ????? ????? ???
		//2 -> ?? ????? ??. ?????? ???? ?????????.

		for ( i = 0; i < TOOLTIP_SETITEM_MAX ; i++ )
		{
			//????????? ?????
			//GetSetItemNum ?? ??? ???????? ????.
			
			for ( SetID = 0 ; SetID < class'UIDATA_ITEM'.static.GetSetItemNum(Item.ID, i) ; SetID++ ) //0,1,2?? ???????????? ?? ????? ???? ?????? ????? ????????..
			{ 					
				tmpItemID.classID = class'UIDATA_ITEM'.static.GetSetItemFirstID( Item.ID, i, SetID );
				
				//??????????? ???? ??? ?? ????? ??? ?????? ??????????? ???.
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

					//0 -> 5????? ??????? ?????? (???, ????, ??, ?????, ????)
					if( i == 0 )
					{
						//m_Info.t_strText = "- "$strTmp;
						m_Info.t_strText = " "$strTmp;
						ParamAdd(m_info.Condition, "SetItemNum", string(i));
						ParamAdd(m_Info.Condition, "Type", "Equip");
						ParamAddItemID(m_Info.Condition, Item.ID);
						ParamAdd(m_Info.Condition, "CurTypeID", string(SetID));		//???? ???????? Type ??(0??:?? 1??:???? 2??:??? 3??:?? 4?? ??? ..ItemName.txt?? ?????¨ù???
						ParamAdd(m_Info.Condition, "NormalColor", "100,100,65");
						ParamAdd(m_Info.Condition, "EnableColor", "255,250,160");
						totalNum = SetID;
					}
					//1 -> ????, ????? ????? ???
					else if( i == 1 )
					{
						m_Info.t_strText = "- (+) "$strTmp;
						ParamAdd(m_info.Condition, "SetItemNum", string(i));
						ParamAdd(m_Info.Condition, "Type", "Equip");
						ParamAddItemID(m_Info.Condition, Item.ID);						
						ParamAdd(m_Info.Condition, "CurTypeID", string(SetID));		//???? ???????? Type ??(0??:?? 1??:???? 2??:??? 3??:?? 4?? ??? ..ItemName.txt?? ?????¨ù???
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
			//??????			
			for( j = 0; j < class'UIDATA_ITEM'.static.GetSetItemPeaceEffectNum( Item.ID, i ) ; j++ )
			{
				StartItem();
				m_Info.eType = DIT_TEXT;
				m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
				m_Info.bLineBreak = true;
				m_Info.t_bDrawOneLine = true;
				SetTooltipTextColor( 100, 70, 0, 255 );
				//0 -> 5????? ??????? ?????? (???, ????, ??, ?????, ????)
				if( i == 0 )
				{
					m_Info.t_strText = string( j+2 ) $ GetSystemString(2345) $ " : ";
				}
				//1 -> ????, ????? ????? ???
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
			//??©­? ??????
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
				ParamAdd(m_Info.Condition, "SetEnchantEffectIndex", string(j));  //????? 2013.01.23 ?????

				EndItem();
			}
		}
	}
}

function SetItemLineInsert( ItemID id, int setID )
{
	//??? ?????????? ???..
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
 * ???????? ?? 
 * ??? ??? 1??/11:33 ???? ????? ??????? ???
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

	// (?? day)
	m_timeDay = sec / 86400;
	remainSec = sec % 86400;
	
	m_timeHour = (remainSec / 60 / 60);		// ??
	m_timeMin = (remainSec / 60) % 60;		// ??
	// m_timeSec = remainSec % 60;	// ??

	// debug(" m_timeHour : " $ m_timeHour $ "m_timeMin : "  $ m_timeMin$ "m_timeSec : "  $ m_timeSec);	
	returnStr = "";
	if (m_timeDay > 0)
	{
		returnStr = String(m_timeDay) $ GetSystemString(1109); // $ "/";
	}

	if (onlyDayFlag == false)
	{
		// ?? day ?? ????? / ?? ?????? ??¢¥?. 
		if (returnStr != "") returnStr = returnStr $ "/";

		// ?©ª? ??????.
		if(m_timeHour > 0)
		{
			if (m_timeHour < 10 ) returnStr = returnStr $ "0" $ string( m_timeHour );
			else returnStr = returnStr $ string( m_timeHour );
		}
		else
		{
			returnStr = returnStr $ "00";
		}

		// ??
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
 * ???? ???¢¯? ???? ????? ???? 
 * 0, 1, 2, 3, 4  (??³d??, ????, ????, ?±r, ??ªE??)
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
//  ???? ???? ??? ????? ???? 
//----------------------------------------------------------------------------------------------------------------------------------------------------

function bool IsEnchantableItem(EItemParamType Type)
{
	return (Type == ITEMP_WEAPON || Type == ITEMP_ARMOR || Type == ITEMP_ACCESSARY || Type == ITEMP_SHIELD);
}

//----------------------------------------------------------------------------------------------------------------------------------------------------
//  ???? ????, ?? ??? (???? ???? ??? ??? ???? ??)
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


//???? Text ???? ????.
function SetTooltipTextColor( int R, int G, int B, int A )
{
	m_Info.t_color.R = R;
	m_Info.t_color.G = G;
	m_Info.t_color.B = B;
	m_Info.t_color.A = A;
}

//???? Text 
function SetTooltipText( string strDesc, bool bLineBreak, bool t_bDrawOneLine, optional bool isFirstLine)
{
	m_Info.eType = DIT_TEXT;
	if (!isFirstLine) m_Info.nOffSetY = TOOLTIP_LINE_HGAP;
	m_Info.t_strText = strDesc;
	m_Info.bLineBreak = bLineBreak;	
	m_Info.t_bDrawOneLine = t_bDrawOneLine;
}

// ?? ?????, ??? ?????? ???? ????????? ???? (2016-04)
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


// ?????? ?????? ??????. 
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

// ?????? ??? ?????? ??????.
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

// ?????? ??? ????
function AddAgathionSkillTooltip ( itemInfo info ) 
{
	local array<SkillInfo> mainSkillList, subSkillList ;	
	local int i ;
	local color titleColor, descColor;	
	
	GetAgathionMainSkillList(info.ID.classID, info.Enchanted, mainSkillList ) ;	
	//Debug ( "?????? ?????? ???? " @  mainSkillList.Length ) ;//getAgathionIndex ( info.ID ) @ info.Enchanted);		

	GetAgathionSubSkillList(info.ID.classID, info.Enchanted, subSkillList) ;
	//Debug ( "?????? ?????? ???? " @ subSkillList.Length ) ;
	
	// ??? ???????? ???? ?? ??? ????? ???? ??? ???? ?¡À? 		

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


//????? (????) ?? ???? ???.
function AddTooltipItemBlank(int Height)
{
	StartItem();
	m_Info.eType = DIT_BLANK;
	m_Info.b_nHeight = Height;
	EndItem();
}

// ?? ???? ??? 
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


//"XXX : YYYY" ?????? TooltipItem?? ????? ????? ???
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
		if (!isFirstLine) m_Info.nOffSetY = TOOLTIP_LINE_HGAP; // ???? ???¡Æ ?????? ?????, ???? ?????? 6??? ???.(???????? ??????? ???? GAP)
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


//"XXX : YYYY" ?????? TooltipItem?? ????? ????? ???
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

//"XXX : YYYY" ?????? TooltipItem?? ????? ????? ???.
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

//"XXX : YYYY" ?????? TooltipItem?? ????? ????? ???. ???? ???? ????( ?????? ?????? ?????? ??? ??Äî ???. ?????? ????????)
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

// nBasic ????, ??©¡? ????? ?? nBonus   (100+50)  <- ????? ??? (??? ?????)
function AddTooltipItemBonus(int nBasic, int nBonus, optional int offSetX, optional int offSetY)
{
	//????? ???? ?? ??? ???????? ??¢¥?.
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

// ???, ??, ??, ???,??? ??? ??????
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


// ??????..
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



// t_bDrawOneLine  : ????? ??? ??? (??????? ???? width?? ¨¨????)
// bLineBreak      : ?? ???? 

//------------------------------------------------------------------------------------------------------------------------
// ???? ?????? ???? ???? ???
//------------------------------------------------------------------------------------------------------------------------	

//// ???? ????? ????? ????? ??? ????? ???¢¥?.
//function string GetEnsoulOptionNameAll(ItemInfo weaponInfo)
//{
//	local EnsoulOptionUIInfo eOptionInfo;
//	local int i, n, cnt, optionID;

//	local string allName;

//	// ??? ????? ???? (2015-02-09 ???)
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
