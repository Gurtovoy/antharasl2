//------------------------------------------------------------------------------------------------------------------------
//
// 제목         : 인게임샾 - SCALEFORM UI
//
//------------------------------------------------------------------------------------------------------------------------
class FactionWnd extends L2UIGFxScript;

const TYPE_FACTION_START_NPC = 2;

function OnRegisterEvent()
{	
	// 10080
	registerGfxEvent( EV_FactionInfo );		
	registerGfxEvent( EV_FactionInfoRewardIcon );	
}

function OnLoad()
{		
	AddState( "GAMINGSTATE" );
	SetContainerWindow(WINDOWTYPE_DECO_NORMAL, 3443);
}

function onHide ()
{
	eraseStartNpcRegioninfo ();
}

function onCallUCFunction ( string functionName, string param ) 
{	
	switch  ( functionName ) 
	{
		case "showStartNPC" : 
			showStartNpc ( param ) ;
		break;
		case "hideStartNPC":
			eraseStartNpcRegioninfo();
		break;
	}
}

// 시작 NPC 위치 보여주기 
function showStartNpc ( string param ) 
{
	local Vector XYZ;
	local int x, y, z;
	local string  npcName;
	local MinimapCtrlHandle m_MiniMap;
	local MinimapWnd mapScript ;
	local MinimapRegionInfo regionInfoForMapIcon;

	mapScript = MinimapWnd( GetScript( "MinimapWnd"));

	m_MiniMap = GetMinimapCtrlHandle( "MinimapWnd.Minimap" );

	if (!GetWindowHandle("MinimapWnd").IsShowWindow()) GetWindowHandle("MinimapWnd").ShowWindow();

	parseString ( param, "npcName", npcName );
	parseInt ( param, "StartNpcX", x );
	parseInt ( param, "StartNpcY", y );
	parseInt ( param, "StartNpcZ", z );
	
	XYZ.x = x ;
	XYZ.y = y ;
	XYZ.z = z ;
	
	// 위치 이동
	mapScript.SetContinent(m_MiniMap.GetContinent(XYZ));	
	class'UIAPI_MINIMAPCTRL'.static.AdjustMapView( "MinimapWnd.Minimap", XYZ, false );
	
	m_MiniMap.SetShowRegionInfoByType(EMinimapRegionType.MRT_Etc, true);

	regionInfoForMapIcon = makeRegionInfo (npcName, XYZ);
	m_MiniMap.EraseRegionInfoCtrl(EMinimapRegionType.MRT_Etc, TYPE_FACTION_START_NPC) ;
	m_MiniMap.AddRegionInfoCtrl(regionInfoForMapIcon);	
}

// 시작 NPC 위치 삭제 
function eraseStartNpcRegioninfo () 
{
	local MinimapCtrlHandle m_MiniMap;	
	m_MiniMap = GetMinimapCtrlHandle( "MinimapWnd.Minimap" );
	m_MiniMap.EraseRegionInfoCtrl(EMinimapRegionType.MRT_Etc, TYPE_FACTION_START_NPC) ;
}

// 시작 NPC 위치 아이콘 만들기
function MinimapRegionInfo makeRegionInfo( string tooltipString,  Vector pLoc )
{
	local MinimapRegionInfo regionInfoForMapIcon;
	local MinimapRegionIconData iconData;
	local string toolTipParam;

	toolTipParam = "";	
	ParamAdd(toolTipParam, "tooltipString", tooltipString);
	ParamAdd(toolTipParam, "Type", String ( int ( EMinimapRegionType.MRT_Etc )));	
	regionInfoForMapIcon.strTooltip = toolTipParam;

	regionInfoForMapIcon.eType = EMinimapRegionType.MRT_Etc;
	regionInfoForMapIcon.nIndex = TYPE_FACTION_START_NPC; //huntingZoneData.nSearchZoneID;
	//regionInfoForMapIcon.strDesc = tooltipString;

	iconData.nWidth = 32;
	iconData.nHeight = 32;
	iconData.nWorldLocX = pLoc.x;// - iconData.nIconOffsetX; // 3197;  // - 3197 은 기획(조중곤), 16픽셀에 해당하는값.
	iconData.nWorldLocY = pLoc.y;// - iconData.nIconOffsetY; // 3197;
	iconData.nWorldLocZ = pLoc.z;
	iconData.nIconOffsetX = -3;
    iconData.nIconOffsetY = -20;

	iconData.strIconNormal = "L2UI_CT1.Minimap.Minimap_DF_Icon_Pin_Campaign_Over";
	iconData.strIconOver   = "L2UI_CT1.Minimap.Minimap_DF_Icon_Pin_Campaign";
	iconData.strIconPushed = "L2UI_CT1.Minimap.Minimap_DF_Icon_Pin_Campaign_Over";		

	regionInfoForMapIcon.iconData = IconData ;
	return regionInfoForMapIcon ;
}
defaultproperties
{
}
