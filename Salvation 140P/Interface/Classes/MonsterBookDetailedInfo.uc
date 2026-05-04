class MonsterBookDetailedInfo extends UICommonAPI;

//const DIALOGID_Gohome = 0;

var string m_WindowName;
var WindowHandle Me;
var WindowHandle dropItemWindow ;
var WindowHandle DisableMsgWnd;

var	CharacterViewportWindowHandle	m_ObjectViewport;

var TextBoxHandle DropITEMNum_txt;
var TextBoxHandle Faction_Txt;
var TextBoxHandle Local_Txt;
var TextBoxHandle MonsterLV_Txt;
var TextBoxHandle MonsterName_Txt;
var TextBoxHandle CallName_Txt;

var TextBoxHandle DisableMsg3DWnd_txt ;

var TextBoxHandle GageFrameHPNum_Txt ;
var TextBoxHandle GageFrameMPNum_Txt ;

var TextureHandle FactionPattern_Text;

var ListCtrlHandle DropItem_ListCtrl;

var TreeHandle NpcInfo;

var itemID nID;

var int nMonsterBookID;

var bool isActive;

var bool isDown ;

var int currentMonsterID;

enum AtkAnimationType
{
	ATKWAITANIMMAIN,
	ATK01ANIMNAME,
	ATK02ANIMNAME,
	ATK03ANIMNAME
};

const MONSTERID_DEACTIVE    = 19652;
const TIMER_ID_ANIMATION    = 19;
const TIMER_DELAY           = 20000;
const TIMER_ID_CLICK        = 2;
const TIMER_DELAY_CLICK     = 200;

function OnLoad()
{	
	SetClosingOnESC();
	InitializeCOD();
	dropItemWindow.HideWindow();
}

function OnRegisterEvent()
{
	
	registerEvent( EV_MonsterBookInfo );	
	// 이 윈도우 타입은 자동 로딩이 안되는 것 같음, 이벤트를 등록 해서 받
	RegisterEvent( EV_GamingStateEnter );
	//RegisterEvent( EV_GamingStatePreExit );
}

function InitializeCOD()
{
	Me = GetWindowHandle( m_WindowName );	
	//m_ObjectViewport    = GetCharacterViewportWindowHandle(m_WindowName $ ".ObjectViewport");
	m_ObjectViewport    = GetCharacterViewportWindowHandle(m_WindowName $ ".MonsterStageWnd.ObjectViewport");
	dropItemWindow      = GetWindowHandle( m_WindowName$".DropItemWND" ) ;
	DropITEMNum_txt     = GetTextBoxHandle ( m_WindowName $ ".DropITEMNum_txt" ) ;
	Faction_Txt         = GetTextBoxHandle ( m_WindowName $ ".Faction_Txt" ) ;
	Local_Txt           = GetTextBoxHandle ( m_WindowName $ ".Local_Txt" ) ;
	MonsterLV_Txt       = GetTextBoxHandle ( m_WindowName $ ".MonsterLV_Txt" ) ;
	MonsterName_Txt     = GetTextBoxHandle ( m_WindowName $ ".MonsterName_Txt" ) ;
	CallName_Txt        = GetTextBoxHandle ( m_WindowName $ ".CallName_Txt" ) ;
	GageFrameHPNum_Txt  = GetTextBoxHandle ( m_WindowName $ ".GageFrameHPNum_Txt" );
	GageFrameMPNum_Txt  = GetTextBoxHandle ( m_WindowName $ ".GageFrameMPNum_Txt" );

	FactionPattern_Text = GetTextureHandle ( m_WindowName $ ".FactionPattern_Text" );

	DisableMsg3DWnd_txt = GetTextBoxHandle ( m_WindowName $ ".MonsterStageWnd.DisableMsg3DWnd_txt" );
	DisableMsgWnd       = GetWindowHandle( m_WindowName$".DropItemWND.DisableMsgWnd" ) ;

	DropItem_ListCtrl   = GetListCtrlHandle ( m_WindowName $ ".DropItemWND.DropItem_ListCtrl"  );

	NpcInfo = GetTreeHandle ( m_WindowName $ ".MonsterStageWnd.NpcInfo" );

	DropItem_ListCtrl.SetSelectedSelTooltip(FALSE);	
	DropItem_ListCtrl.SetAppearTooltipAtMouseX(true);
	m_ObjectViewport.SetDragRotationRate(200) ;
	m_ObjectViewport.SetSpawnDuration ( 0.2 );
	m_ObjectViewport.AutoAttacking( true ) ;
}


function OnClickButton( String a_ButtonID )
{
	switch( a_ButtonID )
	{		
		case "CloseButton":
			Me.HideWindow();
			break;
		case "DropITEM_BTN" :
			if (dropItemWindow.isShowWindow() ) dropItemWindow.HideWindow();
			else dropItemWindow.ShowWindow();
			break;
	}
}


/********************************************************************
 * 서브창으로 작동을 위한 포커싱 제어
 * ********************************************************************
event OnSetFocus(WindowHandle handle, bool bFocused)
{
	Debug ( "Me Focused? " @ Me.IsFocused() );
	Debug ("OnSetFocus" @ handle.GetWindowName() @ bFocused);
}

event OnLButtonDblClick( WindowHandle a_WindowHandle, int X, int Y )
{
	Debug( "OnLButtonDblClick");
}
event OnRButtonDblClick( WindowHandle a_WindowHandle, int X, int Y )
{
	Debug( "OnLButtonDblClick");
}

event OnRButtonDown( WindowHandle a_WindowHandle, int X, int Y )
{
	// 부모 포커스를 잡는다.	
	if ( a_WindowHandle == m_ObjectViewport ) Me.SetFocus(); 
	//class'UIAPI_WINDOW'.static.SetAlwaysOnTop( param, true );
	CallGFxFunction( "MonsterBookWnd", "setFocus", "" ) ;
	
	
	// 애래로 하면, container을 잡네.
	//class'UIAPI_WINDOW'.static.SetFocus("MonsterBookWnd");
}
*/

event OnLButtonDown( WindowHandle a_WindowHandle, int X, int Y )
{		
	// 부모 포커스를 잡는다.	
	if ( a_WindowHandle == m_ObjectViewport )  
	{
		// m_ObjectViewport 선택 하면, focus 가 되지 않는다. ?????? 
		Me.SetFocus();
		Me.SetTimer ( TIMER_ID_CLICK, TIMER_DELAY_CLICK ) ;
		isDown = true;
	}
	//class'UIAPI_WINDOW'.static.SetAlwaysOnTop( param, true );
	// 포커스 제어를 위한 
	//CallGFxFunction( "MonsterBookWnd", "setFocus", "" ) ;
	// 애래로 하면, container을 잡네.
	//class'UIAPI_WINDOW'.static.SetFocus("MonsterBookWnd");
}

event OnLButtonUp( WindowHandle a_WindowHandle, int X, int Y )
{
	if ( a_WindowHandle == m_ObjectViewport )  
	{		
		if ( isDown ) 
		{
			playRandAnimation() ;
			Me.KillTimer (  TIMER_ID_ANIMATION) ;
			Me.SetTimer ( TIMER_ID_ANIMATION,TIMER_DELAY);			
		}
	}
	Me.KillTimer (  TIMER_ID_CLICK ) ;
	isDown = false;
}


function onEvent ( int eventID, string param )  
{
	switch ( eventID ) 
	{
		case EV_MonsterBookInfo :
			checkUpdate (param) ;
		break;
	}
}


function onShow () 
{	
	//local windowHandle pWnd;
	//pWnd = GetWindowHandle ( "MonsterBookWnd");;
	////getInstanceL2Util().windowMoveToSide(pWnd, Me);	
	//getInstanceL2Util().windowAnchorToSide(pWnd, Me, 2, 29);		
}

function onHide ( ) 
{
	Me.KillTimer( TIMER_ID_ANIMATION );
	currentMonsterID = - 1;
}

function onCallUCFunction ( string funcName, string param) 
{	
	//debug ( "onCallUCFunction"  @ funcName @ param) ;
		
	switch ( funcName ) 
	{
		case "showMonsterInfo" :
			setMonsterInfo( param );
			break;
		//case "inputItemID":
		//	addDropItemInfo ( int( param )) ;
		//	break;
		//case "setDropItemInfo":
		//	setDropItemInfo () ;
		//	break;
		case "bringToFront":
			Debug( "bringToFront" @ getCurrentWindowName(string(Self)) )  ;			
			//class'UIAPI_WINDOW'.static.BringToFront (getCurrentWindowName(string(Self)));			
			class'UIAPI_WINDOW'.static.BringToFront ("ContainerWindow");
			class'UIAPI_WINDOW'.static.BringToFront ("FactionWnd");
			break;
	}
}

function checkUpdate ( string param ) 
{
	local int monsterID ;
	parseInt ( param, "nMonsterBookID", monsterID );
	if ( monsterID != nMonsterBookID ) return ;
	setMonsterInfo ( param );
}

function setMonsterInfo ( string param)  
{
	local L2MonsterBookUIData monaterData;	
	
	parseInt ( param, "nMonsterBookID", nMonsterBookID );	

	GetMonsterBookData ( nMonsterBookID, monaterData ) ;
	
	setBasicInfo ( monaterData ) ;
	setViewport ( monaterData ) ;
	setItemInfo ( monaterData );
}

/***********************************************************************************************
 * 애니메이션
 * *********************************************************************************************/
function playRandAnimation() 
{
	local int aniType;
	aniType = Rand(3) +1;
	//Debug ( "OnTimer"@  aniType ) ;
	m_ObjectViewport.PlayAttackAnimation( aniType  ) ;
}

function OnTimer(int TimerID) 
{
	
	//Debug("Min" @min @ "Sec" @ Sec);
	switch ( TimerID ) 
	{
		case TIMER_ID_ANIMATION : 
			playRandAnimation() ; 
		break;
		case TIMER_ID_CLICK     : 
			Me.KillTimer (  TIMER_ID_CLICK ) ; 
			isDown = false;       
		break;
	}
}

/***********************************************************************************************
 * 정보 
 * *********************************************************************************************/
function setViewPortParams ( int monsterID, int offsetX, int offsetY, float viewSale, int rotation, int distance ) 
{
	currentMonsterID = monsterID ;
	m_ObjectViewport.SetNPCInfo( currentMonsterID ) ;
	m_ObjectViewport.SetCharacterOffsetX( offsetX ) ;
	m_ObjectViewport.setCharacterOffsetY( offsetY) ;
	m_ObjectViewport.SetCharacterScale( viewSale ) ;
	m_ObjectViewport.SetCurrentRotation( rotation ) ;
	m_ObjectViewport.SetCameraDistance( distance ) ;		
}

function setViewport ( L2MonsterBookUIData monsterData ) 
{	
	if ( isActive ) 
	{		
		if ( currentMonsterID == monsterData.nNpcID ) return;		
		setViewPortParams ( monsterData.nNpcID,  monsterData.nViewX, monsterData.nViewY, monsterData.fViewScale, monsterData.nViewRot, monsterData.nViewDist ) ;		
	}
	else 
	{
		if ( currentMonsterID == MONSTERID_DEACTIVE ) return;		
		setViewPortParams (MONSTERID_DEACTIVE,  0, 3, 1.0f, 0, 120 ) ;	
	}	
	Me.KillTimer ( TIMER_ID_ANIMATION );
	m_ObjectViewport.SpawnNPC();	

	playRandAnimation() ;
	Me.SetTimer(TIMER_ID_ANIMATION,TIMER_DELAY);
}

function setBasicInfo ( L2MonsterBookUIData monsterData ) 
{
	local string level, npcHP, npcMP;
	local ELanguageType Language;
	//local string strNpcNick, strFactionEmblem, strFactionName, strNpcName, strZoneName, strNpcLevel, strNpcHP, strNpcMP ;
	
	//parseString ( param, "strNpcName", strNpcName ) ;
	//parseString ( param, "strNpcNick", strNpcNick ) ;	
	//parseString ( param, "nNpcLevel", strNpcLevel ) ;
	//parseString ( param, "strFactionName", strFactionName ) ;
	//parseString ( param, "strZoneName", strZoneName ) ;
	//parseString ( param, "strFactionEmblem", strFactionEmblem ) ;
	//parseString ( param, "nNpcHP", strNpcHP ) ;
	//parseString ( param, "nNpcMP", strNpcMP ) ;

	isActive = monsterData.nTrophyLevel > 0 ;

	MonsterName_Txt.SetText(monsterData.strNpcName);
	CallName_Txt.SetText(monsterData.strNpcNick);	
	
	Faction_Txt.SetText(monsterData.strFactionName);
	Local_Txt.SetText(monsterData.strZoneName);

	FactionPattern_Text.SetTexture ( monsterData.strFactionEmblem $ "_small" );	

	if ( isActive ) 
	{
		DisableMsg3DWnd_txt.HideWindow();
		DisableMsgWnd.HideWindow();
		level = String(monsterData.nNpcLevel);
		npcHP = MakeCostString( String(monsterData.nNpcHP )) ;
		npcMP = MakeCostString( String(monsterData.nNpcMP )) ;
		setNpcProperty ( monsterData.nNpcID ) ;		
	}
	else 
	{
		DisableMsg3DWnd_txt.ShowWindow();
		DisableMsgWnd.ShowWindow();
		level = "???";
		npcHP = "???";
		npcMP = "???";		
		//setNpcProperty ( monsterData.nNpcID ) ;		
		NpcInfo.HideWindow();
	}

	Language = GetLanguage();
	if(Language == LANG_Russia || Language == LANG_Euro || Language == LANG_English)
		MonsterLV_Txt.SetText(getSystemString(88) $ level);
	else
		MonsterLV_Txt.SetText( getSystemString ( 88 ) $"."$ level );

	GageFrameHPNum_Txt.SetText(npcHP) ;
	GageFrameMPNum_Txt.SetText(npcMP) ;	
	
	
}

function setNpcProperty ( int NpcID) 
{
	local Array<int>	 arrNpcInfo;

	class'UIDATA_NPC'.static.GetNpcProperty(NpcID, arrNpcInfo) ;
	UpdateNpcInfoTree( arrNpcInfo );

	NpcInfo.ShowWindow();
	NpcInfo.ShowScrollBar(false);
}

//트리컨트롤에 Npc특성아이콘 추가
function UpdateNpcInfoTree(array<int> arrNpcInfo)
{
	local int i;
	local int SkillID;
	local int SkillLevel;
	
	local string				strNodeName;
	local XMLTreeNodeInfo		infNode;
	local XMLTreeNodeItemInfo	infNodeItem;
	local XMLTreeNodeInfo		infNodeClear;
	local XMLTreeNodeItemInfo	infNodeItemClear;
	
	//초기화
	NpcInfo.Clear();
	
	//루트 추가
	infNode.strName = "root";
	strNodeName = NpcInfo.InsertNode("", infNode);
	if (Len(strNodeName) < 1)
	{
		//~ debug("ERROR: Can't insert root node. Name: " $ infNode.strName);
		return;
	}
	
	for (i=0; i<arrNpcInfo.Length; i+=2)
	{
		SkillID = arrNpcInfo[i];
		SkillLevel = arrNpcInfo[i+1];
		
		//////////////////////////////////////////////////////////////////////////////////////////////////////
		//Insert Node
		infNode = infNodeClear;
		infNode.nOffSetX = ((i/2)%8)*18;
		if ((i/2)%8==0)
		{
			if (i>0)
			{
				infNode.nOffSetY = 3;
			}
			else
			{
				infNode.nOffSetY = 0;
			}
		}
		else
		{
			infNode.nOffSetY = -15;
		}
		
		infNode.strName = "" $ i/2;
		infNode.bShowButton = 0;
		//Tooltip
		infNode.ToolTip = SetNpcInfoTooltip(SkillID, SkillLevel);
		strNodeName = NpcInfo.InsertNode("root", infNode);
		if (Len(strNodeName) < 1)
		{
			Log("ERROR: Can't insert node. Name: " $ infNode.strName);
			return;
		}
		//Node Tooltip Clear
		infNode.ToolTip.DrawList.Remove(0, infNode.ToolTip.DrawList.Length);
		
		//////////////////////////////////////////////////////////////////////////////////////////////////////
		//Insert NodeItem
		infNodeItem = infNodeItemClear;
		infNodeItem.eType = XTNITEM_TEXTURE;
		infNodeItem.u_nTextureWidth = 15;
		infNodeItem.u_nTextureHeight = 15;
		infNodeItem.u_nTextureUWidth = 32;
		infNodeItem.u_nTextureUHeight = 32;
		// !문제 있는지 확인
		infNodeItem.u_strTexture = class'UIDATA_SKILL'.static.GetIconName(GetItemID(SkillID), SkillLevel, 0);
		NpcInfo.InsertNodeItem(strNodeName, infNodeItem);
	}	
	//moveNPCInfo( arrNpcInfo );
}
/*
function moveNPCInfo ( array<int> arrNpcInfo ) 
{
	local bool isTwoLine ;
	local int numOfProp, x, y ;
	isTwoLine = arrNpcInfo.Length > 8 ;  // 두줄
	if ( isTwoLine ) numOfProp = 8;
	else numOfProp = arrNpcInfo.Length % 9;

	x = ( numOfProp - 1 ) * 18 / 2  ;

	if ( isTwoLine ) y = -37;
	else y = -18;
	
	if ( isTwoLine ) y = 18* 2 ;
	else y = 18;
	NpcInfo.SetWindowSize ( 18 * numOfProp - 3, y  ) ;

	Debug ( isTwoLine @ arrNpcInfo.Length  @ numOfProp ) ;
	NpcInfo.SetAnchor ( m_windowname $ ".MonsterStageWnd" , "BottomCenter", "BottonCenter", 0 , -3 ) ;
}
*/

function CustomTooltip SetNpcInfoTooltip(int ID, int Level)
{
	local CustomTooltip Tooltip;
	local DrawItemInfo info;
	local DrawItemInfo infoClear;
	local ItemInfo Item;
	local ItemID cID;
	
	cID = GetItemID(ID);
	
	Item.Name = class'UIDATA_SKILL'.static.GetName(cID, Level, 0);
	Item.Description = class'UIDATA_SKILL'.static.GetDescription(cID, Level, 0);
	
	Tooltip.DrawList.Length = 1;
	
	//이름
	info = infoClear;
	info.eType = DIT_TEXT;
	info.t_bDrawOneLine = true;
	info.t_strText = Item.Name ;
	Tooltip.DrawList[0] = info;

	//설명
	if (Len(Item.Description)>0)
	{
		Tooltip.MinimumWidth = 144;
		Tooltip.DrawList.Length = 2;
		
		info = infoClear;
		info.eType = DIT_TEXT;
		info.nOffSetY = 6;
		info.bLineBreak = true;
		info.t_color.R = 178;
		info.t_color.G = 190;
		info.t_color.B = 207;
		info.t_color.A = 255;
		info.t_strText = Item.Description;
		Tooltip.DrawList[1] = info;	
	}
	return Tooltip;
}


function string ellipsisWidth ( string text, int maxWidth ) 
{
	local int nWidth, nHeight, i ;	
	
	GetTextSizeDefault( text $ "..."  , nWidth, nHeight);
	if ( nWidth  < maxWidth ) return text;

	for ( i = 0 ; i < 200 ; i ++ ) 
	{	
		GetTextSizeDefault( text $ "..."  , nWidth, nHeight);			
		if ( nWidth  < maxWidth ) return  text$"...";
		text = mid(text, 0, len(text) - 1);		
		//text
	}
}


/***********************************************************************************************
 * 아이템 리스트 
 * *********************************************************************************************/

function setItemInfo( L2MonsterBookUIData monsterData ) 
{
	local int i ;

	clearDropItemInfo();
	if ( isActive )  for ( i = 0 ; i < monsterData.arrDropItemID.length ; i ++ ) addDropItemInfo( monsterData.arrDropItemID[i] );
	setDropItemInfo();
}

function clearDropItemInfo () 
{	
	DropItem_ListCtrl.DeleteAllItem();
}

function addDropItemInfo (int itemID ) 
{	
	DropItem_ListCtrl.InsertRecord( makeRecord (itemID) ) ;		
}

function setDropItemInfo () 
{	
	local string strItemNum ;
	if ( isActive ) 
	{

		strItemNum = String( DropItem_ListCtrl.GetRecordCount() ) ;	
	}
	else 
	{
		strItemNum = "?";
	}

	DropITEMNum_txt.SetText( strItemNum );
}

function LVDataRecord makeRecord ( int itemID )
{
	local LVDataRecord Record;	
	local string param, additionalName, fullNameString;
	local int itemNameClass;		
	local itemInfo Info;	
	
	nID.ClassID = itemID;
	class'UIDATA_ITEM'.static.GetItemInfo(nID, Info);	

	fullNameString = info.Name;

	itemNameClass  = class'UIDATA_ITEM'.static.GetItemNameClass( info.ID );			
	additionalName = class'UIDATA_ITEM'.static.GetItemAdditionalName( info.ID );

	if (itemNameClass == 0)		 //보급형 아이템 
	{
		fullNameString = MakeFullSystemMsg(GetSystemMessage(2332), fullNameString);
	}
	else if (itemNameClass == 2) //희귀한 아이템
	{
		fullNameString = MakeFullSystemMsg(GetSystemMessage(2331), fullNameString);
	}
	if (Len(additionalName) > 0 )
	{
		fullNameString = fullNameString $ "(" $ additionalName $ ")";
	}

	// 툴팁을 저장하기 위해 param으로 분해 사용
	ItemInfoToParam(info, param);
	
	// 툴팁
	Record.szReserved = param;	
	Record.nReserved1 = Int64(info.Id.ClassID);	
	Record.nReserved2 = info.ItemNum ;
	//Record.nReserved3 = index;
	Record.LVDataList.length = 4;

	Record.LVDataList[0].szData = ellipsisWidth ( fullNameString , 280 ) ;	

	Record.LVDataList[0].hasIcon = true;
	Record.LVDataList[0].nTextureWidth=32;
	Record.LVDataList[0].nTextureHeight=32;
	Record.LVDataList[0].nTextureU=32;
	Record.LVDataList[0].nTextureV=32;
	Record.LVDataList[0].szTexture = info.IconName; 
	Record.LVDataList[0].IconPosX=10;
	Record.LVDataList[0].FirstLineOffsetX=6;
	
	// back texture 
	Record.LVDataList[0].iconBackTexName="l2ui_ct1.ItemWindow_DF_SlotBox_Default";
	Record.LVDataList[0].backTexOffsetXFromIconPosX=-2;
	Record.LVDataList[0].backTexOffsetYFromIconPosY=-1;
	Record.LVDataList[0].backTexWidth=36;
	Record.LVDataList[0].backTexHeight=36;
	Record.LVDataList[0].backTexUL=36;
	Record.LVDataList[0].backTexVL=36;

	// 아이콘 테두리 (기본 병기.pvp 무기등)
	Record.LVDataList[0].iconPanelName = info.iconPanel;
	Record.LVDataList[0].panelOffsetXFromIconPosX=0;
	Record.LVDataList[0].panelOffsetYFromIconPosY=0;
	Record.LVDataList[0].panelWidth=32;
	Record.LVDataList[0].panelHeight=32;
	Record.LVDataList[0].panelUL=32;
	Record.LVDataList[0].panelVL=32;
	
	//Record.LVDataList[1] = makeItemNumRecord( Record, getItemNumArray[index] );

	//costString = MakeCostString( String ( info.Price ) );
	Record.LVDataList[1].szData = fullNameString;
	//Record.LVDataList[1].buseTextColor = true;
	//Record.LVDataList[1].textColor = GetNumericColor( costString );
	Record.LVDataList[1].textAlignment = TA_Right;
	//Record.LVDataList[1].HiddenStringForSorting = String(info.Price);
	//Debug ( info.ConsumeType @ IsStackableItem( info.ConsumeType )) ;
	// 수량성 아이템이라면 총 가격 표시
	//if ( IsStackableItem( info.ConsumeType ) )
	//{
	//	// hasIcon = true; 두줄로 표기 하시오 
	//	Record.LVDataList[2].hasIcon = true;		
	//	Record.LVDataList[2].attrColor = getColor(170, 170, 170, 255);
	//	Record.LVDataList[2].attrStat[0] = MakeFullSystemMsg(GetSystemMessage(3657), ConvertNumToTextNoAdena(String(info.Price * info.itemNum)));
	//	Record.LVDataList[2].textAlignment=TA_Right;
	//}
	
	return record ;

}

/***********************************************************************************************
 * etc 
 * *********************************************************************************************/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( m_WindowName ).HideWindow();
}

defaultproperties
{
    m_WindowName="MonsterBookDetailedInfo"
}
