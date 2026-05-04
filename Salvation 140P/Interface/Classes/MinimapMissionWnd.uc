/***
 * *
 *   ?? ???? ????, ???? ???? ??
 *
 **/
class MinimapMissionWnd extends UICommonAPI;

var WindowHandle Me;
var TextBoxHandle TxtMission_Title;

// ????
var WindowHandle MissionTab;
var ButtonHandle BTN_Huntingzone;
var ButtonHandle BTN_Inzone;
var ButtonHandle BTN_Raid;
var ListCtrlHandle Mission_ListCtrl;

// ????
var WindowHandle LocalInfoTab;
var ListCtrlHandle LocalInfo_ListCtrl;
var TabHandle TabCtrl;

var MinimapWnd miniMapWndScript;

// ???? ????
var bool bShowHuntingZone, bShowInzone, bShowRaid;

var LVDataRecord lastSelectListRecord;

struct  MapListInfo
{
	var string      sortingKey;
	var int			index;
};

function OnRegisterEvent()
{
	RegisterEvent( EV_Restart );

	registerEvent( EV_InzoneWaitingInfo );
	RegisterEvent( EV_RaidBossSpawnInfo );
}

function OnLoad()
{
	Initialize();
	Load();
}

function Initialize()
{
	Me               = GetWindowHandle( "MinimapMissionWnd" );
	TxtMission_Title = GetTextBoxHandle( "MinimapMissionWnd.TxtMission_Title" );

	// ????
	MissionTab       = GetWindowHandle( "MinimapMissionWnd.MissionTab" );
	BTN_Huntingzone  = GetButtonHandle( "MinimapMissionWnd.MissionTab.BTN_Huntingzone" );
	BTN_Inzone       = GetButtonHandle( "MinimapMissionWnd.MissionTab.BTN_Inzone" );
	BTN_Raid         = GetButtonHandle( "MinimapMissionWnd.MissionTab.BTN_Raid" );
	Mission_ListCtrl = GetListCtrlHandle( "MinimapMissionWnd.MissionTab.Mission_ListCtrl" );

	// ????
	LocalInfoTab        = GetWindowHandle( "MinimapMissionWnd.LocalInfoTab" );
	LocalInfo_ListCtrl  = GetListCtrlHandle( "MinimapMissionWnd.LocalInfoTab.LocalInfo_ListCtrl" );
	TabCtrl             = GetTabHandle( "MinimapMissionWnd.TabCtrl" );

	miniMapWndScript    = MinimapWnd(GetScript("MinimapWnd"));

	//class'UIAPI_WINDOW'.static.SetAlwaysOnTop( "MinimapMissionWnd", true );
}

function OnShow()
{
	updateOptionSave();
	refresh();
}

function Load()
{
	init();
}

function init()
{
	bShowRaid = true;
	bShowInzone = true;
	bShowHuntingZone = true;

	LocalInfo_ListCtrl.DeleteAllItem();
	Mission_ListCtrl.DeleteAllItem();
}

//---------------------------------------------------------------------------------------------------
// Button Click
//---------------------------------------------------------------------------------------------------
function OnClickButton( string Name )
{
	switch( Name )
	{
		case "BTN_Raid":
		case "BTN_Inzone":
		case "BTN_Huntingzone":
			 toggleButtonClick(Name);
			 break;

		case "TabCtrl0" :
		case "TabCtrl1" :
			 break;

		case "CloseButton" : miniMapWndScript.OnClickButton("OpenGuideWnd");
		     break;

	}
}

// ???? ???? ????
function toggleButtonClick(string buttonName)
{
	switch( buttonName )
	{
		case "BTN_Raid":
			 bShowRaid = !bShowRaid;
			 miniMapWndScript.showRegionIcon(EMinimapRegionType.MRT_Raid, bShowRaid);
			 SetINIBool ( "MinimapMissionWnd", "a", bShowRaid, "WindowsInfo.ini") ;

			 Debug(buttonName @ ": " @ bShowRaid);
			 break;

		case "BTN_Inzone":
			 bShowInzone = !bShowInzone;
			 miniMapWndScript.showRegionIcon(EMinimapRegionType.MRT_InstantZone, bShowInzone);
			 SetINIBool ( "MinimapMissionWnd", "e", bShowInzone, "WindowsInfo.ini") ;
			 break;

		case "BTN_Huntingzone":
			 bShowHuntingZone = !bShowHuntingZone;
			 miniMapWndScript.showRegionIcon(EMinimapRegionType.MRT_HuntingZone_Mission, bShowHuntingZone);
			 SetINIBool ( "MinimapMissionWnd", "p", bShowHuntingZone, "WindowsInfo.ini");
			 break;
	}

	refresh();
}

function updateOptionSave()
{
	local int nHunt, nInzone, nRaid, nFirstRun;

	GetINIBool( "MinimapMissionWnd", "l", nFirstRun  , "WindowsInfo.ini");
	GetINIBool( "MinimapMissionWnd", "a", nRaid  , "WindowsInfo.ini");
	GetINIBool( "MinimapMissionWnd", "e", nInzone, "WindowsInfo.ini");
	GetINIBool( "MinimapMissionWnd", "p", nHunt  , "WindowsInfo.ini");

	// ???? ?????? ???? ????????..
	if (nFirstRun == 0)
	{
		bShowRaid = true;
		bShowInzone = true;
		bShowHuntingZone = true;
		SetINIBool ( "MinimapMissionWnd", "a", bShowRaid, "WindowsInfo.ini") ;
		SetINIBool ( "MinimapMissionWnd", "e", bShowInzone, "WindowsInfo.ini") ;
		SetINIBool ( "MinimapMissionWnd", "p", bShowHuntingZone, "WindowsInfo.ini");

		SetINIBool ( "MinimapMissionWnd", "l", true, "WindowsInfo.ini");
	}
	else
	{
		// false ???? ??????.. ???? ???? ?????? ???????? false, 0????.. ???? ?? ????.
		bShowRaid        = numToBool(nRaid);
		bShowInzone      = numToBool(nInzone);
		bShowHuntingZone = numToBool(nHunt);
	}

	miniMapWndScript.showRegionIcon(EMinimapRegionType.MRT_Raid, bShowRaid);
	miniMapWndScript.showRegionIcon(EMinimapRegionType.MRT_InstantZone, bShowInzone);
	miniMapWndScript.showRegionIcon(EMinimapRegionType.MRT_HuntingZone_Mission, bShowHuntingZone);
}

function updateToggleButton()
{
	// ??????
	if(bShowRaid)
		BTN_Raid.SetTexture("L2UI_CT1.Button.Button_DF_Small", "L2UI_CT1.Button.Button_DF_Small", "L2UI_CT1.Button.Button_DF_Small_Over");
	else
		BTN_Raid.SetTexture("L2UI_CT1.Button.Button_DF_Small_Toggle", "L2UI_CT1.Button.Button_DF_Small_Toggle_Down", "L2UI_CT1.Button.Button_DF_Small_Toggle_Over");


	// ??????
	if(bShowHuntingZone)
		BTN_Huntingzone.SetTexture("L2UI_CT1.Button.Button_DF_Small", "L2UI_CT1.Button.Button_DF_Small", "L2UI_CT1.Button.Button_DF_Small_Over");
	else
		BTN_Huntingzone.SetTexture("L2UI_CT1.Button.Button_DF_Small_Toggle", "L2UI_CT1.Button.Button_DF_Small_Toggle_Down", "L2UI_CT1.Button.Button_DF_Small_Toggle_Over");


	// ?????? ???????? ????.
	// ?????? ???????? ?????? ????.
	if(getInstanceUIData().getIsClassicServer())
	{
		bShowInzone = false;

		// ?????? ??????, ?????? ???? ?????? ????.
		BTN_Inzone.HideWindow();
		GetTextureHandle("MinimapMissionWnd.MissionTab.BTNICON_Inzone_Tex").HideWindow();

		BTN_Raid.ClearAnchor();
		BTN_Raid.SetAnchor( "MinimapMissionWnd.MissionTab.BTN_Huntingzone", "TopLeft", "TopLeft", 107, 0 );

		GetTextureHandle("MinimapMissionWnd.MissionTab.BTNICON_Raid_Tex").ClearAnchor();
		GetTextureHandle("MinimapMissionWnd.MissionTab.BTNICON_Raid_Tex").SetAnchor( "MinimapMissionWnd.MissionTab.BTN_Raid", "TopLeft", "TopLeft", 6, 5 );
	}
	else
	{
		BTN_Raid.ClearAnchor();
		BTN_Raid.SetAnchor( "MinimapMissionWnd.MissionTab.BTN_Huntingzone", "TopLeft", "TopLeft", 254, 0 );

		GetTextureHandle("MinimapMissionWnd.MissionTab.BTNICON_Raid_Tex").ClearAnchor();
		GetTextureHandle("MinimapMissionWnd.MissionTab.BTNICON_Raid_Tex").SetAnchor( "MinimapMissionWnd.MissionTab.BTN_Raid", "TopLeft", "TopLeft", 6, 5 );

		BTN_Inzone.ShowWindow();
		GetTextureHandle("MinimapMissionWnd.MissionTab.BTNICON_Inzone_Tex").ShowWindow();

		if(bShowInzone)
			BTN_Inzone.SetTexture("L2UI_CT1.Button.Button_DF_Small", "L2UI_CT1.Button.Button_DF_Small", "L2UI_CT1.Button.Button_DF_Small_Over");
		else
			BTN_Inzone.SetTexture("L2UI_CT1.Button.Button_DF_Small_Toggle", "L2UI_CT1.Button.Button_DF_Small_Toggle_Down", "L2UI_CT1.Button.Button_DF_Small_Toggle_Over");
	}

	//Debug("bShowRaid" @ bShowRaid);
	//Debug("bShowInzone" @ bShowInzone);
	//Debug("bShowHuntingZone" @ bShowHuntingZone);
}

function bool isShowRaid()
{
	return bShowRaid;
}

function bool isShowInzone()
{
	return bShowInzone;
}

function bool isShowHuntingZone()
{
	return bShowHuntingZone;
}

// ????
function refresh()
{
	// ???? ????????
	updateToggleButton();

	addMissionList();

	addLocalList();
}

// ???? ???? ??????
function addMissionList()
{
	local int i;
	local Array<MapListInfo> nHuntingArray, nInzoneArray;
	local UserInfo pUserInfo;
	local HuntingZoneUIData huntingZoneData;

	GetPlayerInfo ( pUserInfo );

	// ???? ???? ???? ????
	Mission_ListCtrl.DeleteAllItem();

	nHuntingArray.Remove(0, nHuntingArray.Length);
	nInzoneArray.Remove(0, nInzoneArray.Length);

	// ???????? ???? ????
	for (i = 0; i < 500 ; i++)
	{
		if(class'UIDATA_HUNTINGZONE'.static.IsValidData(i) == false) continue;

		class'UIDATA_HUNTINGZONE'.static.GetHuntingZoneData(i, huntingZoneData);

		if(huntingZoneData.nType == HuntingZoneType.FIELD_HUNTING_ZONE_SOLO ||
		   huntingZoneData.nType == HuntingZoneType.FIELD_HUNTING_ZONE_PARTY ||
		   huntingZoneData.nType == HuntingZoneType.FIELD_HUNTING_ZONE_PARTYWITH_SOLO)
		{
			if (bShowHuntingZone)
			{
				//if (huntingZoneData.nRegionID <= 0) continue;

				if(tryLevelCheck(pUserInfo.nLevel, huntingZoneData.nMinLevel, huntingZoneData.nMaxLevel) == false) continue;

				nHuntingArray.Insert(nHuntingArray.Length, 1);
				nHuntingArray[nHuntingArray.Length - 1].index = i;
				nHuntingArray[nHuntingArray.Length - 1].sortingKey = getInstanceL2Util().makeZeroString(4, huntingZoneData.nMinLevel);

				//nHuntingArray.Sort(OnSortCompare);
			}
		}
		else if(huntingZoneData.nType == HuntingZoneType.INSTANCE_ZONE_SOLO ||
			    huntingZoneData.nType == HuntingZoneType.INSTANCE_ZONE_PARTY)
		{
			if (bShowInzone)
			{
				if(tryLevelCheck(pUserInfo.nLevel, huntingZoneData.nMinLevel, huntingZoneData.nMaxLevel) == false) continue;

				nInzoneArray.Insert(nInzoneArray.Length, 1);
				nInzoneArray[nInzoneArray.Length - 1].index = i;
				nInzoneArray[nInzoneArray.Length - 1].sortingKey = getInstanceL2Util().makeZeroString(4, huntingZoneData.nMinLevel);

				//nInzoneArray.Sort(OnSortCompare);

			}
		}
	}

	makeMapList(Mission_ListCtrl, nHuntingArray, GetSystemString(1296), true, "L2UI_CT1.Minimap.Mission_huntingzone", false);  // ??????
	makeMapList(Mission_ListCtrl, nInzoneArray, GetSystemString(2668), true, "L2UI_CT1.Minimap.Mission_inzone", true);        // ????

	if(bShowInzone) RequestInzoneWaitingTime(false);
	if(bShowRaid) makeRaidList();

	missionListBeforeSelect();
}

function missionListBeforeSelect()
{
	local int i;
	local int nInstantZoneID, index, nFactionID, npcID;
	local int selectedInstantZoneID, selectedIndex, selectedNFactionID, selectedNpcID;
	local LVDataRecord Record;

	//Debug("-->missionListBeforeSelect run" @ Mission_ListCtrl.GetRecordCount());

	for (i = 0; i <	Mission_ListCtrl.GetRecordCount(); i++)
	{
		Mission_ListCtrl.GetRec(i, Record);

		//Debug("-->Record" @ Record.LVDataList.Length);
		//Debug("-->lastSelectListRecord" @ lastSelectListRecord.LVDataList.Length);

		if (Record.LVDataList.Length == 0) continue;

		parseInt (Record.LVDataList[0].szReserved, "instantZoneID", nInstantZoneID);
		parseInt (Record.LVDataList[0].szReserved, "nFactionID", nFactionID);
		parseInt (Record.LVDataList[0].szReserved, "index", index);
		parseInt (Record.LVDataList[0].szReserved, "npcID", npcID);

		if (lastSelectListRecord.LVDataList.Length == 0) continue;

		parseInt (lastSelectListRecord.LVDataList[0].szReserved, "instantZoneID", selectedInstantZoneID);
		parseInt (lastSelectListRecord.LVDataList[0].szReserved, "nFactionID", selectedNFactionID);
		parseInt (lastSelectListRecord.LVDataList[0].szReserved, "index", selectedIndex);
		parseInt (lastSelectListRecord.LVDataList[0].szReserved, "npcID", selectedNpcID);

		// ?????? ?????? ?????? ??????.
		if ((nInstantZoneID + nFactionID + index + npcID) <= 0) continue;

		// ?????? ???? ?????? ?????? ????
		if(nInstantZoneID == selectedInstantZoneID && selectedNFactionID == nFactionID &&  selectedIndex == index ||
			(selectedNpcID == npcID) && selectedNpcID > 0)
		{
			Mission_ListCtrl.SetSelectedIndex(i, true);
			break;
		}
	}
}

function makeMapList(ListCtrlHandle list, Array<MapListInfo> targetMapListInfo, string headerString, bool bLevelLimitView, string headerIcon, optional bool bInstanceZoneID)
{
	local int n, i;
	local string addStr, backStr, szReserved;
	local HuntingZoneUIData huntingZoneData;

	// ??
	for (n = 0; n < targetMapListInfo.Length ; n++)
	{
		addStr = "";
		szReserved = "";

		// ?????? ?????????? index
		i = targetMapListInfo[n].index;
		class'UIDATA_HUNTINGZONE'.static.GetHuntingZoneData(i, huntingZoneData);

		// ???? ????
		if (n == 0) addListItemHead(list, headerString $ " (" $ targetMapListInfo.Length $")", headerIcon); // ?? ????
		ParamAdd(szReserved, "index", String(i));
		if (bInstanceZoneID)
			ParamAdd(szReserved, "instantZoneID", String(huntingZoneData.nInstantZoneID));

		if(bLevelLimitView) addStr = getLevelRangeString(i);

		backStr = "";
		// ??????, ?????? 0???? "???? ????" ?? ?? ?? ???? ???????? ?????? ?????????? ??????.
		if (huntingZoneData.nInstantZoneID == 0 && bInstanceZoneID == true)
		{
			backStr = "(" $ GetSystemString(3554) $ ")";  // ???? ????
		}

		addListItem(list, makeListLvDataText(addStr $ huntingZoneData.strName $ backStr, getInstanceL2Util().Gold, huntingZoneData.nWorldLoc, szReserved));
	}
}

// ???? ???? ??????
function addLocalList()
{
	local int i;
	local Array<MapListInfo> nCastlevilleArray, nFortressArray, nAgitCountArray, nHuntingZoneArray, nFactionArray;
	local HuntingZoneUIData huntingZoneData;

	// ???? ???? ???????? ?????? ?????? ????????. ???? ?????? ???????? ???????? ???????? ???? ????????
	if (LocalInfo_ListCtrl.GetRecordCount() <= 0)
	{
		// ???? ???? ???? ????
		LocalInfo_ListCtrl.DeleteAllItem();

		nCastlevilleArray.Remove(0, nCastlevilleArray.Length);
		nFortressArray.Remove(0, nFortressArray.Length);
		nAgitCountArray.Remove(0, nAgitCountArray.Length);
		nHuntingZoneArray.Remove(0, nHuntingZoneArray.Length);
		nFactionArray.Remove(0, nFactionArray.Length);

		// ???????? ???? ????
		for (i = 0; i < 500 ; i++)
		{
			if(class'UIDATA_HUNTINGZONE'.static.IsValidData(i) == false) continue;

			class'UIDATA_HUNTINGZONE'.static.GetHuntingZoneData(i, huntingZoneData);

			if(huntingZoneData.nType == HuntingZoneType.CASTLE)
			{
				nCastlevilleArray.Insert(nCastlevilleArray.Length, 1);
				nCastlevilleArray[nCastlevilleArray.Length - 1].index = i;
				nCastlevilleArray[nCastlevilleArray.Length - 1].sortingKey = huntingZoneData.strName;
				//nCastlevilleArray.Sort(OnSortCompare);
			}
			else if(huntingZoneData.nType == HuntingZoneType.FORTRESS)
			{
				nFortressArray.Insert(nFortressArray.Length, 1);
				nFortressArray[nFortressArray.Length - 1].index = i;
				nFortressArray[nFortressArray.Length - 1].sortingKey = huntingZoneData.strName;
				//nFortressArray.Sort(OnSortCompare);
			}
			else if(huntingZoneData.nType == HuntingZoneType.AGIT)
			{
				nAgitCountArray.Insert(nAgitCountArray.Length, 1);
				nAgitCountArray[nAgitCountArray.Length - 1].index = i;
				nAgitCountArray[nAgitCountArray.Length - 1].sortingKey = huntingZoneData.strName;
				//nAgitCountArray.Sort(OnSortCompare);
			}
			else if(huntingZoneData.nType == HuntingZoneType.FIELD_HUNTING_ZONE_SOLO ||
					huntingZoneData.nType == HuntingZoneType.FIELD_HUNTING_ZONE_PARTY ||
					huntingZoneData.nType == HuntingZoneType.FIELD_HUNTING_ZONE_PARTYWITH_SOLO)
			{
				nHuntingZoneArray.Insert(nHuntingZoneArray.Length, 1);
				nHuntingZoneArray[nHuntingZoneArray.Length - 1].index = i;
				nHuntingZoneArray[nHuntingZoneArray.Length - 1].sortingKey = getInstanceL2Util().makeZeroString(4, huntingZoneData.nMinLevel);
				//nHuntingZoneArray.Sort(OnSortCompare);
			}
		}

		makeMapList(LocalInfo_ListCtrl, nCastlevilleArray, GetSystemString(3529), false, "L2UI_CT1.EmptyBtn");  // ??
		makeMapList(LocalInfo_ListCtrl, nFortressArray, GetSystemString(1605), false, "L2UI_CT1.EmptyBtn");     // ????
		makeMapList(LocalInfo_ListCtrl, nAgitCountArray, GetSystemString(1616), false, "L2UI_CT1.EmptyBtn");    // ??????
		makeMapList(LocalInfo_ListCtrl, nHuntingZoneArray, GetSystemString(1296), true, "L2UI_CT1.EmptyBtn");  // ??????

		makeFactionList(); // ???? ???? ????
	}
}

// ???? ???? ???? ???? ??????
function makeFactionList()
{
	local array<L2UserFactionUIInfo>  factionInfoListArray;
	local UserInfo pUserInfo;
	local int i;
	local string szReserved;

	local L2FactionUIData factionData;

	local MinimapRegionIconData iconData;
	local Vector loc;

	// local RaidUIData nRaidUIData;

	GetPlayerInfo(pUserInfo);

	GetUserFactionInfoList(pUserInfo.nID, factionInfoListArray);

	// ?????? ???? ?????? ???? ???? ???????? ?????? ???? ?????? ???? ???? ???? ?????? ???? ???????? ???????? ?????? ????.
	for(i = 0; i < factionInfoListArray.Length; i++)
	{
		// Debug("factionInfoListArray[i].nFactionID:" @ factionInfoListArray[i].nFactionID);
		GetFactionData(factionInfoListArray[i].nFactionID, factionData);

		//Debug("-------------------------------------------------------");
		//Debug("???? ???? : " @ factionData.strFactionName);

		//for(n = 0; n < factionData.arrFactionAreaZoneID.Length; n++)
		//{
		//	Debug("factionData.arrFactionAreaZoneID" @ factionData.arrFactionAreaZoneID[n]);
		//}
		//for(n = 0; n < factionData.arrFactionAreaName.Length; n++)
		//{
		//	Debug("factionData.arrFactionAreaName" @ factionData.arrFactionAreaName[n]);
		//}

		if(GetMinimapRegionIconData(factionData.nRegionID, iconData))
		{
			loc.x = iconData.nWorldLocX;
			loc.y = iconData.nWorldLocY;
			loc.z = iconData.nWorldLocZ;
		}

		// ???? ???? , 3443 ????
		if (i == 0) addListItemHead(LocalInfo_ListCtrl, GetSystemString(3443) $ " (" $ factionInfoListArray.Length $")", "L2UI_CT1.EmptyBtn"); // ???? ????

		szReserved = "";
		//ParamAdd(szReserved, "index", String(i));
		ParamAdd(szReserved, "nFactionID", String(factionData.nFactionID));

		addListItem(LocalInfo_ListCtrl, makeListLvDataText(factionData.strFactionName, getInstanceL2Util().Gold, loc, szReserved));
	}
}

function makeRaidList()
{
	local UserInfo pUserInfo;
	local int i, raidCount;
	//local bool bAddList;
	local array<int> raidNpcIDArray;

	local string addStr;
	local string textStr;

	local array<RaidUIData> raidUIDataArray;
	local RaidUIData raidData;

	local string szReserved;

	GetPlayerInfo ( pUserInfo );

	// ?????? ???? ?? ????,
	//m_MiniMap.EraseRegionInfoByType(EMinimapRegionType.MRT_Raid);

    for (i = 0; i < 500; i++)
	{
		raidData = getRaidDataByIndex(i);

		//Debug("	raidData.raidMonsterName " @ raidData.raidMonsterName);
		//Debug("	raidData.id " @ raidData.id);
		addStr = "";
		// 0, 0, 0 ???? ?????? ???? 0???? ?????????? ???????? ???? ???? ???????? ???? ???? ??????.
		if(raidData.nWorldLoc.x == 0 && raidData.nWorldLoc.y == 0 && raidData.nWorldLoc.z == 0) continue;

		//miniMapWndScript.drawMinimapRegionInfo(EMinimapRegionType.MRT_Raid, raidData.id, false);

		if(tryLevelCheck(pUserInfo.nLevel, raidData.nMinLevel,  raidData.nMaxLevel) == false) continue;

		raidData.sortingKey = getInstanceL2Util().makeZeroString(4, raidData.nRaidMonsterLevel);
		raidUIDataArray[raidUIDataArray.Length] = raidData;
	}

	//raidUIDataArray.Sort(OnSortCompareForRaid);

	for (i = 0; i < raidUIDataArray.Length; i++)
	{
		// ??????
		if (raidCount == 0) addListItemHead(Mission_ListCtrl, GetSystemString(1297) $ " (" $ raidUIDataArray.Length $")", "L2UI_CT1.Minimap.Mission_raid");
		raidCount++;
		//bAddList = true;

		raidData = raidUIDataArray[i];

		szReserved = "";
		ParamAdd(szReserved, "npcID", String(raidData.nRaidMonsterID));
		ParamAdd(szReserved, "index", String(raidData.id)); //String(i));

		// List ???? ????
		//			if (raidData.nMinLevel != 0 && raidData.nMinLevel != 0)
		//	addStr = "[Lv." $ raidData.nMinLevel $ "~"$ raidData.nMaxLevel $"] ";
		addStr = "[Lv." $ raidData.nRaidMonsterLevel $ "] ";

		ParamAdd(szReserved, "addStr", addStr);
		// ?????? ???? ?????? ?????? ???? ??????.
		raidNpcIDArray[raidNpcIDArray.Length] = raidData.nRaidMonsterID;
		// ??????????(???? ????) ???? ?????? ?????? , ???????? ????
		if(GetLanguage() == ELanguageType.LANG_Russia || GetLanguage() == ELanguageType.LANG_Euro)
			textStr = addStr $ raidData.raidMonsterName $ " (" $ GetSystemString(3526) $ ")";
		else
			textStr = addStr $ raidData.raidMonsterName $ " (" $ GetSystemString(1718) $ ")";
		addListItem(Mission_ListCtrl,makeListLvDataText(textStr, getInstanceL2Util().ColorGray, raidData.nWorldLoc, szReserved));
	}

	// ?????? ?????? ???????? ?????? ???? ????.
	if (raidNpcIDArray.Length > 0)
	{
		class'MiniMapAPI'.static.RequestRaidBossSpawnInfo(raidNpcIDArray);
		//Debug("[API Call] class'MiniMapAPI'.static.RequestRaidBossSpawnInfo --> " @ raidNpcIDArray.Length $ "ArrayLength");

		//for(i = 0; i < raidNpcIDArray.Length; i++)
		//{
		//	Debug("raidNpcIDArray :" @ i @ "-->" @ raidNpcIDArray[i]);
		//}
	}
}

// ??????
function addListItem(ListCtrlHandle list, LVData lData)
{
	//local LVData Data;
	local LVDataRecord Record;

	Record.LVDataList.length = 1;

	Record.LVDataList[0] = lData;

	list.InsertRecord(Record);
}

// ???? ???? ???????? ???? ????.
function addListItemHead(ListCtrlHandle list, string textStr,  string iconName)
{
	//local LVData Data;
	local LVDataRecord Record;

	Record.LVDataList.length = 1;

	Record.LVDataList[0].hasIcon = true;
	Record.LVDataList[0].szData = " " $ textStr;

	Record.LVDataList[0].nTextureWidth=15;
	Record.LVDataList[0].nTextureHeight=15;
	Record.LVDataList[0].nTextureU=15;
	Record.LVDataList[0].nTextureV=15;
	Record.LVDataList[0].szTexture = iconName;

	// back texture
	Record.LVDataList[0].iconBackTexName="L2UI_CT1.List_HeadLineFrame";
	Record.LVDataList[0].backTexOffsetXFromIconPosX=-6;
	Record.LVDataList[0].backTexOffsetYFromIconPosY=0;
	Record.LVDataList[0].backTexWidth=354;
	Record.LVDataList[0].backTexHeight=19;

	Record.LVDataList[0].backTexUL=32;
	Record.LVDataList[0].backTexVL=19;

	//Record.FirstLineOffsetX=0;
	list.InsertRecord(Record);
}

function OnClickListCtrlRecord( String strID )
{
	local int Idx, nInstantZoneID, nFactionID, index, npcID;
	local LVDataRecord record;

	local HuntingZoneUIData huntingZoneData;
	//local MinimapRegionInfo regionInfoForMapIcon;
	local MinimapRegionIconData iconData;
	local L2FactionUIData factionData;

	local Vector loc;

	if( strID == "Mission_ListCtrl")
	{
		Idx = Mission_ListCtrl.GetSelectedIndex();
		Mission_ListCtrl.GetRec( Idx, record );
	}
	else if (strID == "LocalInfo_ListCtrl")
	{
		Idx = LocalInfo_ListCtrl.GetSelectedIndex();
		LocalInfo_ListCtrl.GetRec( Idx, record );
	}

	// Debug("OnClickListCtrlRecord" @ strID);
	//record.LVDataList[0].szData
	loc.x = record.LVDataList[0].nReserved1;
	loc.y = record.LVDataList[0].nReserved2;
	loc.z = record.LVDataList[0].nReserved3;

	parseInt (Record.LVDataList[0].szReserved, "instantZoneID", nInstantZoneID);
	parseInt (Record.LVDataList[0].szReserved, "index", index);
	parseInt (Record.LVDataList[0].szReserved, "nFactionID", nFactionID);
	parseInt (Record.LVDataList[0].szReserved, "npcID", npcID);

	Debug("OnClickListCtrlRecord szReserved: " @ record.LVDataList[0].szReserved);
	Debug("OnClickListCtrlRecord 1:" @ record.LVDataList[0].nReserved1);
	Debug("OnClickListCtrlRecord 2:" @ record.LVDataList[0].nReserved2);
	Debug("OnClickListCtrlRecord 3:" @ record.LVDataList[0].nReserved3);

	// ???? ???? ???? ???? ???? ??????..
	lastSelectListRecord = record;

	// npc ???? ?????? ??????
	if (npcID > 0)
	{
		loc.x = record.LVDataList[0].nReserved1;
		loc.y = record.LVDataList[0].nReserved2;
		loc.z = record.LVDataList[0].nReserved3;
	}
	// ?????? index
	else if (index > 0)
	{
		class'UIDATA_HUNTINGZONE'.static.GetHuntingZoneData(index, huntingZoneData);
		GetMinimapRegionIconData(huntingZoneData.nRegionID, iconData);

		if (huntingZoneData.nRegionID > 0)
		{
			loc.x =  iconData.nWorldLocX;
			loc.y =  iconData.nWorldLocY;
			loc.z =  iconData.nWorldLocZ;
		}
		else
		{
			loc = huntingZoneData.nWorldLoc;
		}
	}
	// ????
	else if (nFactionID > 0)
	{
		GetFactionData(nFactionID, factionData);

		if(GetMinimapRegionIconData(factionData.nRegionID, iconData))
		{
			loc.x = iconData.nWorldLocX;
			loc.y = iconData.nWorldLocY;
			loc.z = iconData.nWorldLocZ;
		}
	}

	if (isVectorZero(loc) == false)
	{
		// ???? ?? ????.
		miniMapWndScript.SetLocContinent(loc);
		miniMapWndScript.mapIconHighlight(loc, iconData);

		class'UIAPI_MINIMAPCTRL'.static.AdjustMapView("MinimapWnd.Minimap", loc, false);
	}

	if( strID == "Mission_ListCtrl")
	{
		Mission_ListCtrl.SetFocus();
	}
	else if (strID == "LocalInfo_ListCtrl")
	{
		LocalInfo_ListCtrl.SetFocus();
	}
}

/** ???????? ???? ????. */
function LVData makeListLvDataText(string textStr, Color pColor, Vector loc, optional string szReserved)
{
	local LVData lData;

	lData.buseTextColor = True;
	lData.TextColor = pColor;
	lData.szData = textStr;

	// ???? ???? ????
	lData.nReserved1 = loc.x;
	lData.nReserved2 = loc.y;
	lData.nReserved3 = loc.z;
	lData.szReserved = szReserved;

	return lData;
}

//---------------------------------------------------------------------------------------------------
// Event
//---------------------------------------------------------------------------------------------------
function OnEvent(int Event_ID, string param)
{
	//Debug( "MinimapMissionWnd OnEvent " @ Event_ID ) ;

	if (Event_ID == EV_Restart)
	{
		init();
	}
	// 10181 NpcCount=1 NpcID_0=29001   (???????? ??????) 35??????..
	else if (Event_ID == EV_RaidBossSpawnInfo)
	{
		// Debug("EV_RaidBossSpawnInfo" @ param);
		updateRaidNpc(param);
	}
	// 5860
	else if (Event_ID == EV_InzoneWaitingInfo)
	{
		// Debug("EV_InzoneWaitingInfo" @ param);
		handleInzoneWaitingInfo(param);
	}
}

// ???? ?????? ???? ????
function string handleInzoneWaitingInfo(string param)
{
	//local int currentInzoneID;
	local int sizeOfBlockedInzone ;
	local int blockedInzoneID ;

	local int i, m, nInstantZoneID, index, nDataSystemMessage;//, nCount;
	local int nShowWindow;
	local string addStr;

	local LVDataRecord Record;

	//Debug("???? ?????? " @param);
	//parseInt (param, "currentInzoneID" , currentInzoneID );
	parseInt (param, "ShowWindow" , nShowWindow );
	parseInt (param, "sizeOfBlockedInzone" , sizeOfBlockedInzone );

	if(nShowWindow <= 0)
	{
		for (i = 0 ; i <  sizeOfBlockedInzone ; i++ )
		{
			parseInt (param, "blockedInzoneID_" $ i, blockedInzoneID);

			for (m = 0; m < Mission_ListCtrl.GetRecordCount(); m++)
			{
				Mission_ListCtrl.GetRec(m, Record);

				if (Record.LVDataList[0].szReserved != "")
				{
					//Debug("Record.LVDataList[0].szData" @ Record.LVDataList[0].szData);
					//Debug("Record.LVDataList[0].szReserved" @ Record.LVDataList[0].szReserved);

					parseInt (Record.LVDataList[0].szReserved, "instantZoneID", nInstantZoneID);
					parseInt (Record.LVDataList[0].szReserved, "index", index);

					// ???????? ?????? ???????? ???? ??????..
					if (nInstantZoneID == blockedInzoneID)
					{
						addStr = getLevelRangeString(index);
						Record.LVDataList[0].buseTextColor = True;
						Record.LVDataList[0].TextColor = getInstanceL2Util().ColorGray;
						Record.LVDataList[0].szData = addStr $ GetInZoneNameWithZoneID(nInstantZoneID)  $ " (" $ GetSystemString(5099) $ ")";
						Mission_ListCtrl.ModifyRecord(m, Record);

						// ?? ?????? ???? ????, ???????? (?????? ?????? ???? ????)
						miniMapWndScript.drawMinimapRegionInfo(EMinimapRegionType.MRT_InstantZone, index, false, true);
						//nCount++;
						break;

						//Debug("???? ???????? ???? ???? ????????: " @Record.LVDataList[0].szData @ "- id - " @ nInstantZoneID @ ", index " @ index);
						//if(nCount == sizeOfBlockedInzone) break;
					}
				}
			}
		}

		//-------------------------------------------------------------------------------------------------------------------
		// *** ???????? : (?????? ????: ??????) ***
		for (m = 0; m < Mission_ListCtrl.GetRecordCount(); m++)
		{
			Mission_ListCtrl.GetRec(m, Record);

			if (Record.LVDataList[0].szReserved != "")
			{
				index = 0;
				nInstantZoneID = 0;

				parseInt (Record.LVDataList[0].szReserved, "instantZoneID", nInstantZoneID);
				parseInt (Record.LVDataList[0].szReserved, "index", index);

				// ?????? ??????..
				if (nInstantZoneID > 0)
				{
					nDataSystemMessage = miniMapWndScript.getServerNData(MapServerInfoType.DEFENSEWARFARE);

					// Debug("nDataSystemMessage : " @ nDataSystemMessage);
					// Debug("nInstantZoneID : " @ nInstantZoneID);

					// ???????? ???? ????, ????, ???????? ?????? ???????? ???? ?????? ???? 4432, 4434, 4435 ?? ???? ?????? ????????
					if ((nInstantZoneID == 265 || nInstantZoneID == 266) &&
						(nDataSystemMessage == 4432 || nDataSystemMessage == 4434 || nDataSystemMessage == 4435))
					{
						addStr = getLevelRangeString(index);
						Record.LVDataList[0].buseTextColor = True;
						Record.LVDataList[0].TextColor = getInstanceL2Util().ColorGray;
						Record.LVDataList[0].szData = addStr $ GetInZoneNameWithZoneID(nInstantZoneID)  $ " (" $ GetSystemString(5099) $ ")";
						Mission_ListCtrl.ModifyRecord(m, Record);

						miniMapWndScript.drawMinimapRegionInfo(EMinimapRegionType.MRT_InstantZone, index, false, true);
						//Debug("???????? ???? ???? ???? ????" @ nInstantZoneID);
					}
				}
			}
		}
	}
      return "";
}

function updateRaidNpc(string param)
{
	local int npcCount, i, npcID;

	//Debug("updateRaidNpc + param:" @ param);
	// ???????? ?? ??????npc
	ParseInt(param, "NpcCount", npcCount);

	for (i = 0; i < NpcCount; i++)
	{
		ParseInt(param, "NpcId_" $ i, npcID);
		if (npcID > 0) updateRaidListRecord(npcID);
	}
}

function updateRaidListRecord(int npcID)
{
	local LVDataRecord Record;
	local int i, currentNpcID, index;
	local string addStr;

	//Debug("???? ???? ?????? ?????? id " @ npcID);
	for (i = 0; i < Mission_ListCtrl.GetRecordCount(); i++)
	{
		Mission_ListCtrl.GetRec(i, Record);

		if (Record.LVDataList[0].szReserved != "")
		{
			//Debug("Record.LVDataList[0].szData" @ Record.LVDataList[0].szData);
			//Debug("Record.LVDataList[0].szReserved" @ Record.LVDataList[0].szReserved);

			parseInt (Record.LVDataList[0].szReserved, "npcID", currentNpcID);
			parseInt (Record.LVDataList[0].szReserved, "index", index);
			parseString (Record.LVDataList[0].szReserved, "addStr", addStr);

			if (currentNpcID == npcID)
			{
				// npc ???? ?????? ?????? ??????, ???????? ???????? ????
				Record.LVDataList[0].buseTextColor = True;
				Record.LVDataList[0].TextColor = getInstanceL2Util().Gold;
				Record.LVDataList[0].szData = addStr $ class'UIDATA_NPC'.static.GetNPCName(npcID);
				Mission_ListCtrl.ModifyRecord(i, Record);

				// ?? ?????? ???? ????, ??????
				miniMapWndScript.drawMinimapRegionInfo(EMinimapRegionType.MRT_Raid, index, true, true);

				//Debug("--------------------");
				//Debug("???? ???????? ?????? ???? ????????: " @Record.LVDataList[0].szData);
				//Debug("index" @ index);
				//Debug("addStr" @ addStr);
				break;
			}
		}
	}
}

function string getLevelRangeString(int i)
{
	local string addStr;
	local HuntingZoneUIData huntingZoneData;

	class'UIDATA_HUNTINGZONE'.static.GetHuntingZoneData(i, huntingZoneData);

	if (huntingZoneData.nMinLevel != 0 && huntingZoneData.nMinLevel != 0)
	addStr = "[Lv." $ huntingZoneData.nMinLevel $ "~"$ huntingZoneData.nMaxLevel $"] ";

	return addStr;

}

delegate int OnSortCompare( MapListInfo a, MapListInfo b )
{
    if (a.sortingKey > b.sortingKey) // ???? ????. ???????? < ???? ????????.
    {
        return -1;  // ?????? ?????????? -1?? ???? ???? ??.
    }
    else
    {
        return 0;
    }
}

delegate int OnSortCompareForRaid( RaidUIData a, RaidUIData b )
{
    if (a.sortingKey > b.sortingKey) // ???? ????. ???????? < ???? ????????.
    {
        return -1;  // ?????? ?????????? -1?? ???? ???? ??.
    }
    else
    {
        return 0;
    }
}


//// ?????? ???? ?????? ???? ???? ????
//function array<MapListInfo> sortForMapList( array<MapListInfo> itemList )
//{
//	local int len;
//	local MapListInfo temp;
//	local int i;
//	local int j;
//	len = itemList.Length;
//	for (i = 0; i < len; ++i)
//	{
//		for (j = 0; j < len - i; ++j)
//		{
//			if (j < len - 1)
//			{
//				if (itemList[j].sortingKey > itemList[j + 1].sortingKey)
//				{
//					temp = itemList[j];
//					itemList[j] = itemList[j + 1];
//					itemList[j + 1] = temp;
//				}
//			}
//		}
//	}
//	return itemList;
//}

////  RegionType ?? ?????????? ????
//function string EMinimapRegionTypeToString(int nRegionType)
//{
//	local string ZoneTypeStr;
//	switch(nRegionType)
//	{
//		case EMinimapRegionType.MRT_Castle:
//		ZoneTypeStr = GetSystemString(1313);
//		break;
//		case HUNTING_ZONE_DUNGEON:
//		ZoneTypeStr = GetSystemString(1314);
//		break;
//		case HUNTING_ZONE_CASTLEVILLE:
//		ZoneTypeStr = GetSystemString(1315);
//		break;
//		case HUNTING_ZONE_HARBOR:
//		ZoneTypeStr = GetSystemString(1316);
//		break;
//		case HUNTING_ZONE_Agit:
//		ZoneTypeStr = GetSystemString(1317);
//		break;
//		case HUNTING_ZONE_COLOSSEUM:
//		ZoneTypeStr = GetSystemString(1318);
//		break;
//		case HUNTING_ZONE_ETCERA:
//		ZoneTypeStr = GetSystemString(1319);
//		break;
//	}
//	return ZoneTypeStr;
//}
