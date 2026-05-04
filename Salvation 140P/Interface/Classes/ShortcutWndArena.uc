/**
 *   디 아레나, 전용 숏컷 , 2015-09-04 부터, 
 *   
 *   기존 숏컷에서 기능 삭제 위주로 정리 하여 만든 버전.
 *   
 **/
class ShortcutWndArena extends UICommonAPI;

const MAX_Page = 2;
const MAX_ShortcutPerPage = 12;

var WindowHandle Me;

var AnimTextureHandle SlotEffect_Ani;
var AnimTextureHandle PlusEffect_Ani;

var array<int> skillShortIDs;
var array<int> skillClassIDs;

var int currentUpgraeSkillID ;
var string upgradeSkillShortcutName ;

const SKILLID_NONE      = 0;
const SKILLID_ADD       = 1;
const SKILLID_UPDATE    = 2;
const SKILLID_REMOVE    = 3;


function OnRegisterEvent()
{
	RegisterEvent( EV_ShortcutUpdate );
	RegisterEvent( EV_ShortcutPageUpdate );

	RegisterEvent( EV_ShortcutClear );
	RegisterEvent( EV_ShortcutCommandSlot );

	RegisterEvent( EV_ShortcutkeyassignChanged );
	
	RegisterEvent( EV_SetEnterChatting );
	RegisterEvent( EV_UnSetEnterChatting );
}

function OnLoad()
{
	local Tooltip Script;

	if ( !getInstanceUIData().getIsArenaServer() ) return;

	Script = Tooltip( GetScript( "Tooltip" ) );
	Script.setBoolSelect( true );

	Me = GetWindowHandle( "ShortcutWndArena" );
	
	SlotEffect_Ani  = GetAnimTextureHandle( "ShortcutWndArena.SlotEffect_Ani" );
	PlusEffect_Ani  = GetAnimTextureHandle( "ShortcutWndArena.PlusEffect_Ani" );
}


function OnEvent( int a_EventID, String a_Param )
{	
	// 아레나 에서만 처리
	if ( !getInstanceUIData().getIsArenaServer() ) return;

	switch( a_EventID )
	{
		case EV_ShortcutCommandSlot:
			ExecuteShortcutCommandBySlot(a_Param);
			break;
			//첫번째숏컷창의 페이지가 새로 설정되었을 때 날라오는 이벤트
		case EV_ShortcutPageUpdate:					
			HandleShortcutPageUpdate( a_Param );
			break;
		case EV_ShortcutUpdate:
			HandleShortcutUpdate( a_Param );			
			break;
		case EV_ShortcutClear:
			HandleShortcutClear();
			class'ShortcutAPI'.static.SetShortcutPage( 0 );
			class'ShortcutAPI'.static.SetShortcutPage( 1 );
			break;

		case EV_ShortcutkeyassignChanged:		
		case EV_SetEnterChatting:
		case EV_UnSetEnterChatting:
			ClearAllShortcutItemTooltip();
			class'ShortcutAPI'.static.SetShortcutPage( 0 );
			class'ShortcutAPI'.static.SetShortcutPage( 1 );
			break;	
	}
}


function onCallUCFunction ( string id, string param)
{	
	handleSkillUpgrade( int (param) );
}

/*************************************************************************************************************
* 스킬 업그레이드 관련 함수 
*************************************************************************************************************/
function skillUpgradeHide() 
{	
	SlotEffect_Ani.HideWindow();
	PlusEffect_Ani.HideWindow();
}

function skillUpgradeShow( string shortcutName) 
{
	SlotEffect_Ani.ShowWindow();
	PlusEffect_Ani.ShowWindow();	
	
	setAnchorShortcut( shortcutName ) ;	
	upgradeSkillShortcutName = shortcutName;
}

// 스킬 업그레이드 이벤트 
function handleSkillUpgrade ( int classID) 
{
	local int idx ;

	currentUpgraeSkillID = classID;	

	idx = getSkillShortcutIdxByClassID ( currentUpgraeSkillID );

	if ( currentUpgraeSkillID == -1 || idx == -1  ) 
		skillUpgradeHide();
	else 
		skillUpgradeShow( handleGetShortcutName ( skillShortIDs[idx] ) ) ;
}

/*************************************************************************************************************
* 스킬 붙이기
*************************************************************************************************************/

// 스킬 업그레이드 활성화 및 붙이기
function setAnchorShortcut( string shortcutName )
{
	SlotEffect_Ani.Play();
	PlusEffect_Ani.SetLoopCount( 999 );
	PlusEffect_Ani.Play();
	
	SlotEffect_Ani.SetAnchor( shortcutName, "CenterCenter", "CenterCenter", 0, 0 );
	PlusEffect_Ani.SetAnchor( shortcutName, "CenterCenter", "CenterCenter", 0, 0 );
}


// nShortcutID로 스킬 이름 가져 오기 
function String handleGetShortcutName ( int nShortcutID )
{
	local string shortcutName ;
	local int shortcutLine, nShortcutNum;

	nShortcutNum = ( nShortcutID % MAX_ShortcutPerPage ) + 1;
	shortcutLine = nShortcutID / MAX_ShortcutPerPage ;
	shortcutName = getShortcutPathName( shortcutLine ) $ nShortcutNum;	
	return shortcutName ;
	//return GetTextBoxHandle ( shortcutName );
}

// 숏컷 까지의 패스 네임 받기
function String getShortcutPathName ( int shortcutLine ) 
{
	return "ShortcutWndArena.ShortcutWndHorizontalArena_"$shortcutLine$".Shortcut" ; 
}



/*************************************************************************************************************
* 스킬 배열 관리 함수  
*************************************************************************************************************/
function int getSkillShortcutHandleType(int idx, EShortCutItemType ShortcutType ) 
{
	local bool isSkillID;
	isSkillID = EShortCutItemType.SCIT_SKILL == ShortcutType;	
	// 추가 : 스킬인데 인덱스가 없는 경우 추가
	if ( isSkillID && (idx == -1) ) return SKILLID_ADD;
	// 갱신 : 스킬인 경우
	if ( isSkillID ) return SKILLID_UPDATE;
	// 삭제 : 스킬 아닌데 인덱스 남아 있는 경우 
	if ( (idx != -1) ) return SKILLID_REMOVE;
	return SKILLID_NONE;	
}

// 스킬 업데이트 시 배열 관리, 업그렝드 이팩트 변경
function setSkillID ( String param, int nShortcutID, String shortcutName) 
{
	local int ClassID, idx, ShortcutType, type ;
	local bool isUpgradeSkill ;	

	parseInt ( param, "ShortcutType", ShortcutType ) ;
	
	idx =  getSkillArrIndexByShortcutID( nShortcutID ) ;

	type = getSkillShortcutHandleType( idx, EShortCutItemType(ShortcutType) );	

	parseInt ( param, "ClassID", ClassID ) ; 

	isUpgradeSkill = currentUpgraeSkillID == ClassID  ;

	//Debug ("setSkillID" @ type @ idx @ nShortcutID @ ClassID @ currentUpgraeSkillID @ isUpgradeSkill ) ;

	switch ( type ) 
	{
		case SKILLID_ADD :			
			skillIDAdd(nShortcutID,ClassID );			
			if ( isUpgradeSkill ) skillUpgradeShow( shortcutName );
		break;
		case SKILLID_UPDATE :			
			skillIDUpdate( nShortcutID, ClassID, idx );
			if ( isUpgradeSkill ) skillUpgradeShow( shortcutName );
		break;
		case SKILLID_REMOVE:			
			skillIDRemove( idx ) ;
		break;
	}
}


// 스킬 배열 중 classID로 index 검색
function int getSkillShortcutIdxByClassID(int classID) 
{
	local int i ;
	for ( i = 0 ; i < skillClassIDs.Length ; i ++ ) 
	{
		if ( skillClassIDs[i] == classID ) return i;
	}
	return -1;
}


// 스킬 배열 중 shortcutID 를 키 값으로 index 검색
function int getSkillArrIndexByShortcutID ( int ShortcutID) 
{
	local int i ;
	for ( i = 0 ; i < skillShortIDs.Length ; i ++ ) 
	{
		if ( skillShortIDs[i] == ShortcutID  ) return i;
	}
	return -1;
}

/// 스킬 배열 관리 3종 함수 
function skillIDRemove ( int idx ) 
{
	local bool isUpgradeSkill, isMineSkill;

	isUpgradeSkill = skillClassIDs[idx] == currentUpgraeSkillID;
	isMineSkill = upgradeSkillShortcutName == handleGetShortcutName ( skillShortIDs[idx] );

	skillClassIDs.Remove( idx, 1 );
	skillShortIDs.Remove( idx, 1 );

	// 배열에서 업그레이드 스킬 삭제 시 같은 스킬이 하나 더 있다면 거기로 옮김
	if ( isUpgradeSkill ) 
	{
		idx = getSkillShortcutIdxByClassID ( currentUpgraeSkillID ) ;
		// 업그레이드할 스킬이 없다면 숨김 
		if ( idx == -1 ) skillUpgradeHide();
		// idx 위에 스킬 업그레이드가 있다면 다른 곳으로 옮긴다. 
		else if ( isMineSkill ) skillUpgradeShow( handleGetShortcutName ( skillShortIDs[idx] ));
	}
	//Debug ( "skillIDRremove2" @ idx  @ skillClassIDs[idx] @ skillShortIDs[ idx ] @ skillClassIDs.Length );
}

function skillIDUpdate ( int ShortcutID, int ClassID, int idx  )
{
	skillShortIDs[idx] = ShortcutID;
	skillClassIDs[idx] = ClassID;
}
function skillIDAdd( int ShortcutID, int ClassID ) 
{
	local int idx;
	idx = skillClassIDs.Length;
	skillShortIDs.Length = idx + 1 ;
	skillClassIDs.Length = skillShortIDs.Length;	
	skillShortIDs[ idx ] = ShortcutID;
	skillClassIDs[ idx ] = ClassID;		
}

/*************************************************************************************************************
* 업데이트
*************************************************************************************************************/

function ClearAllShortcutItemTooltip()
{
	Me.ClearAllChildShortcutItemTooltip();
}

function HandleShortcutPageUpdate(string param)
{
	local int i;
	local int nstartShortcutID;
	local int ShortcutPage;
	local string shortcutPath ;

	if( ParseInt(param, "ShortcutPage", ShortcutPage) )
	{
		if( 0 > ShortcutPage || MAX_Page <= ShortcutPage )
			return;
		
		shortcutPath = getShortcutPathName( ShortcutPage );
		nstartShortcutID = ShortcutPage * MAX_ShortcutPerPage;
		for( i = 0; i < MAX_ShortcutPerPage; ++i )
		{
			class'UIAPI_SHORTCUTITEMWINDOW'.static.UpdateShortcut( shortcutPath $ ( i + 1 ), nstartShortcutID + i );			
		}
	}
}


function HandleShortcutUpdate(string param)
{
	local int nShortcutID ;
	//local Rect rectWnd;
	local string shortcutName;
	
	ParseInt(param, "ShortcutID", nShortcutID);

	if ( nShortcutID < 0 || nShortcutID >= MAX_ShortcutPerPage * 2 ) return;

	shortcutName = handleGetShortcutName ( nShortcutID );
	
	class'UIAPI_SHORTCUTITEMWINDOW'.static.UpdateShortcut( shortcutName, nShortcutID );

	setSkillID( param, nShortcutID, shortcutName ) ;	
}

function HandleShortcutClear()
{
	local int i;
	
	skillClassIDs.Length = 0;
	skillShortIDs.Length = 0;
	currentUpgraeSkillID = -1;
	skillUpgradeHide();

	for( i=0 ; i < MAX_ShortcutPerPage ; ++i )
	{
		class'UIAPI_SHORTCUTITEMWINDOW'.static.Clear( "ShortcutWndArena.ShortcutWndHorizontalArena_0.Shortcut" $ (i+1) );
		class'UIAPI_SHORTCUTITEMWINDOW'.static.Clear( "ShortcutWndArena.ShortcutWndHorizontalArena_1.Shortcut" $ (i+1) );		
	}
}

function ExecuteShortcutCommandBySlot(string param)
{
	local int slot;	
	ParseInt(param, "Slot", slot);
	//debug ("현재 슬롯넘버" @ slot);	
	if(Me.isShowwindow())		// 창이 보여질 때만 수행하도록 처리.
		class'ShortcutAPI'.static.ExecuteShortcutBySlot( slot );
		//slotpage = slot / MAX_ShortcutPerPage ;

		//class'ShortcutAPI'.static.ExecuteShortcutBySlot( CurrentShortcutPage3*MAX_ShortcutPerPage + slot - MAX_ShortcutPerPage2);

		//class'ShortcutAPI'.static.ExecuteShortcutBySlot( MAX_ShortcutPerPage / slot * MAX_ShortcutPerPage + slot);
	
}
defaultproperties
{
}
