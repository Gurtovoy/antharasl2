/******************************************************************************
//                                             ???? ???? UI ???? ??????                                                                    //
******************************************************************************/
class PartyWndArena extends UICommonAPI;	

//???????.  
const NSTATUSICON_MAXCOL = 12;	    // status icon?? ??? ????.
const NPARTYSTATUS_HEIGHT = 47; //46;	    // status ??????? ????????.
const NPARTYPETSTATUS_HEIGHT = 18;	// status ??????? ????????.

const SMALL_BUF_ICON_SIZE = 6;	// ?? ???? ???????? ?????? ??? ??? ?????. 

const MAX_ArrayNum = 10; // MAX_ArrayNum = MAX_PartyMemberCount + 1 -> ??? ?????? ????? ??
const MAX_BUFF_ICONTYPE = 4;//????????? ??? ???? ?????? ??? ????

struct VnameData
{
	var int ID;
	var int UseVName;
	var int DominionIDForVName;
	var string VName;
	var string SummonVName;	
};

var bool	m_bCompact;	//?????? ????????.
var bool	m_bBuff;		//???? ?????? ??????.

var int		m_arrID[MAX_ArrayNum];	// ???????? ?????? ??????? ???? ID.
var int		m_arrPetID[MAX_ArrayNum];	// ???????? ?????? ??????? ??????? ID.
var int		m_arrSummonID[MAX_ArrayNum];	// ???????? ?????? ??????? ??? ???? ID -> CT3 ???
var int		m_arrPetIDOpen[MAX_ArrayNum];	// ???????? ?????? ??????? ???? ??? ????????? ???. 1??? ????, 2??? ????. -1??? ????
var int		m_CurCount;	
var int 	m_CurBf;
var int		m_TargetID;
var int		m_LastChangeColor;

var VnameData m_Vname[MAX_ArrayNum];
var bool m_AmIRoomMaster; //????? ??????? ?????????? ?????? ???. PartyMatchRoomWnd?? ????? ??????? ?????? ?????? ??????
//Handle ?? ???.
var WindowHandle		m_wndTop;
var WindowHandle		m_PartyStatus[MAX_ArrayNum];
var WindowHandle		m_PartyOption;
var NameCtrlHandle		m_PlayerName[MAX_ArrayNum];
var TextureHandle		m_ClassIcon[MAX_ArrayNum];
var TextureHandle		m_LeaderIcon[MAX_ArrayNum];
var TextureHandle		m_VPIcon[MAX_ArrayNum];

var TextureHandle		m_IsDead[MAX_ArrayNum];


var StatusIconHandle	m_StatusIconBuff[MAX_ArrayNum];
var StatusIconHandle	m_StatusIconDeBuff[MAX_ArrayNum];
var StatusIconHandle	m_StatusIconSongDance[MAX_ArrayNum];
var StatusIconHandle	m_StatusIconTriggerSkill[MAX_ArrayNum];
var BarHandle			m_BarCP[MAX_ArrayNum];
var BarHandle			m_BarHP[MAX_ArrayNum];
var BarHandle			m_BarMP[MAX_ArrayNum];
var ButtonHandle		btnBuff;

var ButtonHandle		m_petButton[MAX_ArrayNum];
var ButtonHandle		m_petButtonTrash[MAX_ArrayNum];

var WindowHandle		m_PetPartyStatus[MAX_ArrayNum];
//var NameCtrlHandle		m_PetName[MAX_ArrayNum];
 
var StatusIconHandle	m_PetStatusIconBuff[MAX_ArrayNum];
var StatusIconHandle	m_PetStatusIconDeBuff[MAX_ArrayNum];
var StatusIconHandle	m_PetStatusIconSongDance[MAX_ArrayNum];
var StatusIconHandle	m_PetStatusIconTriggerSkill[MAX_ArrayNum];


var BarHandle			m_PetBarHP[MAX_ArrayNum];
var BarHandle			m_PetBarMP[MAX_ArrayNum];

var TextureHandle		m_PetClassIcon[MAX_ArrayNum];

// ct3 ???? ??? - ??? 
var TextureHandle m_ClassIconSummon[MAX_ArrayNum];
var TextureHandle m_ClassIconSummonNum[MAX_ArrayNum];
// var TextureHandle m_ClassIconPet[MAX_ArrayNum];


/**??????????? ???*/
//?????????????????
//var TextureHandle m_AutoPartyMatchingIcon[MAX_ArrayNum];
//??????????????
//var ButtonHandle m_AutoPartyMatchingBtn[MAX_ArrayNum];

//?????? ????? index
//var int autoPartyIndex[MAX_ArrayNum];

var int partymasteridx;

var L2Util util;

//????? ?????
var int PartyLeaderID;

// ???? ?????? ???? (????,????? ??) ??? ?????? ????????.
// 45842 TTP 
var string currentBuffButtonState;

//????? ???????? vp ???????? ???? ????? offset
const ONCLASSICFORM_OFFSET_X = 12;
const ONAREAFORM_OFFSET_X = 3;

var int iconsOffsetX ;

// ??? ??? ???
var Array<int> m_arrMatchGroupMember;	

// ??? ?????? ??
var int currentIndex, matchGroupCount, partyCount ;


function OnRegisterEvent()
{
	// ???? (???? ??? ??????????? ????) ??? ???.
	RegisterEvent( EV_ShowBuffIcon );
	
	RegisterEvent( EV_PartyAddParty);
	RegisterEvent( EV_PartyUpdateParty );
	RegisterEvent( EV_PartyDeleteParty );
	RegisterEvent( EV_PartyDeleteAllParty );
	RegisterEvent( EV_PartySpelledList );
	RegisterEvent( EV_PartyRenameMember );
	
	// ct3 ???? ??????? ?? ????
	
	RegisterEvent( EV_PartySummonAdd );
	RegisterEvent( EV_PartySummonUpdate );
	RegisterEvent( EV_PartySummonDelete );
	
	RegisterEvent( EV_PartyPetAdd );	
	RegisterEvent( EV_PartyPetUpdate );
	RegisterEvent( EV_PartyPetDelete );
	
	/*
	 *20130219 ???? ??????? ??????? ????. ????? ?????? ???????? ?????.
	 */
	RegisterEvent( EV_PetStatusSpelledList );		// ?? ?????? ??????? ????
	//RegisterEvent( EV_SummonedStatusSpelledList );	// ?????  ?????? ??????? ????
	
	RegisterEvent( EV_Restart );
	RegisterEvent( EV_TargetUpdate );	// ??? ??????? ????	

	// ?????? ??? ??? ????????
	RegisterEvent( EV_RegistPartySubstitute );
	// ?????? ??? ??? ??? ????????
	RegisterEvent( EV_DeletePartySubstitute );


	RegisterEvent( EV_PartySpelledListDelete ); //1182
	RegisterEvent( EV_PartySpelledListInsert ); //1183
	RegisterEvent( EV_PetStatusSpelledListDelete ); //1052	
	RegisterEvent( EV_PetStatusSpelledListInsert ); //1053

	RegisterEvent( EV_NeedResetUIData);

	RegisterEvent( EV_StateChanged );
	
	//RegisterEvent( EV_TargetHideWindow );
}



function checkClassicForm() 
{
	local int idx;		

	if ( getInstanceUIData().getisClassicServer())
	{
		iconsOffsetX = ONCLASSICFORM_OFFSET_X;		
	}
	else if ( getInstanceUIData().getIsArenaServer() )
	{
		iconsOffsetX = ONAREAFORM_OFFSET_X;
	}
	else 
	{		
		iconsOffsetX = 0;
	}

	for (idx=0; idx<MAX_ArrayNum; idx++)
	{	
		
		if ( getInstanceUIData().getisClassicServer() || getInstanceUIData().getIsArenaServer()) 
		{
			m_VPIcon[idx].hideWindow();
			m_ClassIconSummonNum[idx].HideWindow();
		}
		else 
		{
			m_VPIcon[idx].showWindow();
			m_ClassIconSummonNum[idx].ShowWindow();
		}

		m_LeaderIcon[idx].SetAnchor( "PartyWndArena.PartyStatusWnd"$idx , "TopLeft", "TopLeft", 30 - iconsOffsetX, 8 );			
	}
}

// ?? ?????? ??? ????? ?????? ?????? ?????
function setHideClassIconSummonNum( int idx ) 
{
	if ( getInstanceUIData().getisClassicServer() )
		m_ClassIconSummonNum[idx].HideWindow();
	else 	
		m_ClassIconSummonNum[idx].ShowWindow();
}

// ?????? ?????? ????? ???.
function OnLoad()
{
	local int idx;	// ?????? ????? int.

	util = L2Util(GetScript("L2Util"));

	InitHandleCOD();

	// ???????? ????.
	partymasteridx = -1;
	m_bCompact = false;
	m_bBuff = false;
	m_CurBf = 0;
	m_TargetID = -1;
	m_LastChangeColor = -1;
	m_AmIRoomMaster = false;
	
	//Reset Anchor	// ?????? ??????? PartyWndCompact?? anchor point?? ???????.
	for (idx=0; idx<MAX_ArrayNum; idx++)
	{
		m_StatusIconBuff[idx].SetAnchor("PartyWndArena.PartyStatusWnd" $ idx, "TopRight", "TopLeft", 0, 5);
		m_StatusIconDeBuff[idx].SetAnchor("PartyWndArena.PartyStatusWnd" $ idx, "TopRight", "TopLeft", 0, 5);
		m_StatusIconSongDance[idx].SetAnchor("PartyWndArena.PartyStatusWnd" $ idx, "TopRight", "TopLeft", 0, 5);
		m_StatusIconTriggerSkill[idx].SetAnchor("PartyWndArena.PartyStatusWnd" $ idx, "TopRight", "TopLeft", 0, 5);

		
		m_PetStatusIconBuff[idx].SetAnchor("PartyWndArena.PartyStatusSummonWnd" $ idx, "TopRight", "TopLeft", 1, 1);
		m_PetStatusIconDeBuff[idx].SetAnchor("PartyWndArena.PartyStatusSummonWnd" $ idx, "TopRight", "TopLeft", 1, 1);
		m_PetStatusIconSongDance[idx].SetAnchor("PartyWndArena.PartyStatusSummonWnd" $ idx, "TopRight", "TopLeft", 1, 1);
		m_PetStatusIconTriggerSkill[idx].SetAnchor("PartyWndArena.PartyStatusSummonWnd" $ idx, "TopRight", "TopLeft", 1, 1);

	}
	m_PartyOption.HideWindow();
	
	//Init VirtualDrag
	for (idx=0; idx<MAX_ArrayNum; idx++)
	{
		//m_PartyStatus[idx].SetVirtualDrag( true );
		m_PartyStatus[idx].SetDragOverTexture( "L2UI_CT1.ListCtrl.ListCtrl_DF_HighLight" );
	}
	
	ResetVName();
	
	m_arrMatchGroupMember.Length = 0;
	//Debug("??? ????..");
}
/*
function InitHandle()
{
	local int idx;	// ?????? ????? int.

	//Init Handle
	m_wndTop = GetHandle( "PartyWndArena" );
	m_PartyOption = GetHandle("PartyWndOption");	// ?????? ??? ????.
	for (idx=0; idx<MAX_ArrayNum; idx++)	// ???????? ?? ??? ?? ??????? ????????.
	{
		m_PartyStatus[idx] = GetHandle( "PartyWndArena.PartyStatusWnd" $ idx );
		m_PlayerName[idx] = NameCtrlHandle( GetHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".PlayerName" ) ); 
		m_ClassIcon[idx] = TextureHandle( GetHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".ClassIcon" ) );
		m_LeaderIcon[idx] = TextureHandle( GetHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".LeaderIcon" ) );
		
		m_StatusIconBuff[idx] = StatusIconHandle( GetHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".StatusIconBuff" ) );
		m_StatusIconDeBuff[idx] = StatusIconHandle( GetHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".StatusIconDeBuff" ) );
		m_StatusIconSongDance[idx] = StatusIconHandle( GetHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".StatusIconSongDance" ) );
		m_StatusIconTriggerSkill[idx] = StatusIconHandle( GetHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".StatusIconTriggerSkill" ) );

		m_BarCP[idx] = BarHandle( GetHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".barCP" ) );
		m_BarHP[idx] = BarHandle( GetHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".barHP" ) );
		m_BarMP[idx] = BarHandle( GetHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".barMP" ) );
		//if(idx != 0) // ????? ??? ????? ?????? ??? ??? ????? ???????? ?????? ????. 
		//{
		//	m_petButtonTrash[idx] = ButtonHandle( GetHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".btnSummon0") );	
		//	m_petButtonTrash[idx].HideWindow();
		//}
		m_petButton[idx] = ButtonHandle( GetHandle( "PartyWndArena.btnSummon" $ idx) );	// ?????? ???? ???		
		m_petButton[idx].HideWindow();
		
		m_PetPartyStatus[idx] = GetHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx );
		//m_PetName[idx] = NameCtrlHandle( GetHandle( 
"PartyWndArena.PartyStatusSummonWnd" $ idx $ ".SummonName" ) ); 
		m_PetClassIcon[idx] = TextureHandle( GetHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".ClassIcon" ) );
		
		m_PetStatusIconBuff[idx] = StatusIconHandle( GetHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".StatusIconBuff" ) );
		m_PetStatusIconDeBuff[idx] = StatusIconHandle( GetHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".StatusIconDebuff" ) );
		m_PetStatusIconSongDance[idx] = StatusIconHandle( GetHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".StatusIconSongDance" ) );
		m_PetStatusIconTriggerSkill[idx] = StatusIconHandle( GetHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".StatusIconTriggerSkill" ) );

		m_PetBarHP[idx] = BarHandle( GetHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".barHP" ) );
		m_PetBarMP[idx] = BarHandle( GetHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".barMP" ) );		
				
		m_arrPetIDOpen[idx] = -1;
		m_arrID[idx] = 0;
		
		if(idx == 0) //????? ??? ???????? ?????. 
		{
			m_petButton[idx].SetAnchor("PartyWndArena.PartyStatusWnd" $ idx, "TopLeft", "TopRight", 0, 32);
		}
		else
			m_petButton[idx].SetAnchor("PartyWndArena.PartyStatusWnd" $ idx, "TopLeft", "TopRight", 0, 2);
		
	}
	btnBuff = ButtonHandle( GetHandle( "PartyWndArena.btnBuff" ) );
}
*/
function InitHandleCOD()
{
	local int idx;	// ?????? ????? int.

	//Init Handle
	m_wndTop = GetWindowHandle( "PartyWndArena" );
	m_PartyOption = GetWindowHandle("PartyWndOption");	// ?????? ??? ????.

	for (idx=0; idx<MAX_ArrayNum; idx++)	// ???????? ?? ??? ?? ??????? ????????. ->  ??? ?????? ?? ????? ???? ????.
	{
		m_PartyStatus[idx] = GetWindowHandle  ( "PartyWndArena.PartyStatusWnd" $ idx );
		m_PlayerName[idx]  = GetNameCtrlHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".PlayerName" ); 
		m_ClassIcon[idx]   = GetTextureHandle ( "PartyWndArena.PartyStatusWnd" $ idx $ ".ClassIcon" );
		m_LeaderIcon[idx]  = GetTextureHandle ( "PartyWndArena.PartyStatusWnd" $ idx $ ".LeaderIcon" );
		m_VPIcon[idx]      = GetTextureHandle ( "PartyWndArena.PartyStatusWnd" $ idx $ ".PartyVPIcon" );

		m_IsDead[idx]      = GetTextureHandle ( "PartyWndArena.PartyStatusWnd" $ idx $ ".IsDeadTexture" );
		
		m_StatusIconBuff[idx]          = GetStatusIconHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".StatusIconBuff" );
		m_StatusIconDeBuff[idx]        = GetStatusIconHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".StatusIconDeBuff" );
		m_StatusIconSongDance[idx]     = GetStatusIconHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".StatusIconSongDance" );
		m_StatusIconTriggerSkill[idx]  = GetStatusIconHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".StatusIconTriggerSkill" );

		m_BarCP[idx] = GetBarHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".barCP" );
		m_BarHP[idx] = GetBarHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".barHP" );
		m_BarMP[idx] = GetBarHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".barMP" );

		m_petButton[idx] = GetButtonHandle( "PartyWndArena.btnSummon" $ idx);	// ?????? ???? ???		
		m_petButton[idx].HideWindow();
		
		m_PetPartyStatus[idx] = GetWindowHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx );

		
		m_PetStatusIconBuff[idx] = GetStatusIconHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".StatusIconBuff" );
		m_PetStatusIconDeBuff[idx] = GetStatusIconHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".StatusIconDebuff" );
		m_PetStatusIconSongDance[idx] = GetStatusIconHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".StatusIconSongDance" );
		m_PetStatusIconTriggerSkill[idx] = GetStatusIconHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".StatusIconTriggerSkill" );

		m_PetBarHP[idx] = GetBarHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".barHP" );
		m_PetBarMP[idx] = GetBarHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".barMP" );		
		

		// m_PetClassIcon[idx] = GetTextureHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".ClassIcon" );

		// ct ?? ????? ?? ????? ??????
		m_PetClassIcon[idx] = GetTextureHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".ClassIconPet" );


		// ct3 ?? ????? ??, ????? ????? (????? ??????, ????? ??, ?? ??????)
		m_ClassIconSummon[idx]    =  GetTextureHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".ClassIconSummon" );
		
		m_ClassIconSummonNum[idx] =  GetTextureHandle( "PartyWndArena.PartyStatusSummonWnd" $ idx $ ".ClassIconSummonNum" );
		
		m_arrPetIDOpen[idx] = -1;
		m_arrSummonID[idx] = -1;
		m_arrID[idx] = 0;

		//m_AutoPartyMatchingIcon[idx]    = GetTextureHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".AutoPartyMatchingIcon" );
		//m_AutoPartyMatchingBtn[idx]     = GetButtonHandle( "PartyWndArena.PartyStatusWnd" $ idx $ ".AutoPartyMatchingBtn" );
		
		if(idx == 0) //????? ??? ???????? ?????. 
		{
			m_petButton[idx].SetAnchor("PartyWndArena.PartyStatusWnd" $ idx, "TopLeft", "TopRight", 0, 32);
		}
		else
			m_petButton[idx].SetAnchor("PartyWndArena.PartyStatusWnd" $ idx, "TopLeft", "TopRight", 0, 2);
		
	}
	btnBuff = GetButtonHandle( "PartyWndArena.btnBuff" );
}

/** 
 * ????? ??? ???   
 **/
function string getSummonSortString(int typeN)
{
	local string returnV;
	
	returnV = "";

	switch(typeN)
	{
		// ?????? ?????
		case 0 : returnV = GetSystemString(2311); break;
		// ????? ?????
		case 1 : returnV = GetSystemString(2312); break;
		// ?????? ?????
		case 2 : returnV = GetSystemString(2313); break;
		// ?????? ?????
		case 3 : returnV = GetSystemString(2314); break;
		// ????? ?????
		case 4 : returnV = GetSystemString(2315); break;
	}

	return returnV;
}
function OnShow()
{
	local int i;
	local int tmpInt;

	GetINIInt ( "PartyWndArena", "a", m_CurBf, "WindowsInfo.ini");
	SetBuffButtonTooltip();
	UpdateBuff();
	GetIniInt( "PartyWndArena", "p", tmpInt, "WindowsInfo.ini");	

	for(i=0; i <MAX_PartyMemberCount ; i++)
	{
		
		if( bool ( tmpInt ) ) 	
		{
			if(m_arrPetIDOpen[i] > 0)	m_arrPetIDOpen[i] = 2;		//???? ?????? ??? ??????. 
		}
		else 
		{
			if(m_arrPetIDOpen[i] > 0)	m_arrPetIDOpen[i] = 1;		//???? ?????? ??? ???????. 			
		}	
		// ???? ?????????? ??? ????.		
	}
	//?? ???? ??? ?????? show?? ???? ??????, onShow?? ??? ???? ??? ??
	//showWindow?? ?? ???????? ?? ????
	

	//Debug ( "onShow partyWnd");
	resizeOnly() ;
	//ResizeWnd();
	//SetBuffButtonTooltip();
}

function OnHide()
{
	ResetVName();
}

function OnEnterState( name a_PreStateName )
{
	if (isAreaState() == false) return;
	
	m_bCompact = false;
	m_bBuff = false;
	// m_CurBf = 0;
	ResizeWnd();

	SetBuffButtonTooltip();
	UpdateBuff();
	
}

// ???? ??? ???.
function OnEvent(int Event_ID, string param)
{
	//Debug( "Event_ID>>>" $ string(Event_ID) $ "&&" $ param );
	//Debug("isAreaState()" @ isAreaState());
	//Debug ( "OnEvent" @  Event_ID @ param );
	if (isAreaState() == false) return;

	if (Event_ID == EV_PartyAddParty)	//??????? ?????? ????.
	{
		HandlePartyAddParty(param);
	}
	else if (Event_ID == EV_PartyUpdateParty)	//??? ???????. ???? HP ?? ?????? ?????? ????.
	{
		HandlePartyUpdateParty(param);
	}
	else if (Event_ID == EV_PartyDeleteParty)	//????? ????.
	{
		HandlePartyDeleteParty(param);
	}
	else if (Event_ID == EV_PartyDeleteAllParty)	//??? ????? ????. ????? ??????? ?????.
	{
		HandlePartyDeleteAllParty();
	}
	//20130221 ???? ??? ??????, ?? ???????? ??? ???? ??? ?????? ??? ??. ??? summon ?? ???? ????
	else if (Event_ID == EV_PartySpelledList || Event_ID == EV_PetStatusSpelledList )//|| Event_ID == EV_SummonedStatusSpelledList)	// ???? ??? ????? ???.
	{
		HandlePartySpelledList(param);
		//Debug( EV_PartySpelledList @ "EV_PartySpelledList");
	}
	else if (Event_ID == EV_ShowBuffIcon)		// ????, ?????, ????/????? ????? ??? ???.
	{
		HandleShowBuffIcon(param);
	}
	else if (Event_ID == EV_PartySummonAdd)	//??????? ??????? ??????? ???
	{
		HandlePartySummonAdd(param);
	}
	else if (Event_ID == EV_PartyPetAdd)	//??????? ???? ??????? ???
	{
		HandlePartyPetAdd(param);
	}
	else if (Event_ID == EV_PartySummonUpdate)	//????? ??????? HP?? ?? ?????..
	{
		// Debug("EV_PartySummonUpdate:" @ param);
		HandlePartySummonUpdate(param);
		
	}
	else if (Event_ID == EV_PartyPetUpdate)	// ?? ??????? HP?? ?? ?????..
	{		
		HandlePartyPetUpdate(param);
	}
	else if (Event_ID == EV_PartySummonDelete)	// ??? ????
	{
		// Debug("????? ????"@ param);
		HandlePartySummonDelete(param);
	}
	else if (Event_ID == EV_PartyPetDelete)	    // ?? ??? ????
	{
		// Debug("?? ??? ????" @ param);
		HandlePartyPetDelete(param);
	}

	else if (Event_ID == EV_Restart)
	{
		// Debug("????");
		HandleRestart();
	}
	
	else if (Event_ID == EV_TargetUpdate)
	{
		HandleCheckTarget();
	}
	else if (Event_ID == EV_PartyRenameMember)
	{
		HandlePartyRenameMember(param);
	}

	else if( Event_ID == EV_RegistPartySubstitute )
	{
		HandleRegistPartySubstitute( param );
	}
	else if( Event_ID ==  EV_DeletePartySubstitute )
	{
		HandleDeletePartySubstitute( param );
	}

	else if ( Event_ID == EV_PartySpelledListDelete	||  Event_ID == EV_PetStatusSpelledListDelete)
	{	
		HandlePartySpelledListDelete(param);		
	}
	else if  ( Event_ID == EV_PartySpelledListInsert ||  Event_ID == EV_PetStatusSpelledListInsert )
	{
		HandlePartySpelledListInsert(param);				
	}
	else if ( Event_ID == EV_NeedResetUIData ) 
	{
		checkClassicForm();
	}	
	else if ( Event_ID ==  EV_StateChanged )
	{
		if ( param == "ARENABATTLESTATE" && m_arrMatchGroupMember.Length > 0 ) 
		{
//			Debug ( "????? ??? ??????? ?????? ??? !!!" @ m_arrMatchGroupMember.Length) ;
			m_wndTop.ShowWindow();		
		}
	}
}

function onCallUCFunction ( string functionName, string param ) 
{
	
	switch ( functionName ) 
	{
		case "addGroupMember":			
			m_arrMatchGroupMember.Length = m_arrMatchGroupMember.Length + 1 ;
			m_arrMatchGroupMember[m_arrMatchGroupMember.Length-1] = int ( param );
	//		Debug ( "addGroupMember" @ m_arrMatchGroupMember.Length @ m_arrMatchGroupMember[m_arrMatchGroupMember.Length-1]) ;
		break;
		case "resetGroupMember" :
	//		Debug ( "resetGroupMember" @ m_arrMatchGroupMember.Length ) ;
			m_arrMatchGroupMember.Length = 0 ;
		break;
	}
}

function bool isMatchGroupMember ( int ID ) 
{
	local int i;
	for (i = 0 ; i < m_arrMatchGroupMember.Length ; i ++ )		
	{
		//Debug ( "isMatchGroupMember" @  m_arrMatchGroupMember[i] @ ID) ;
		if ( m_arrMatchGroupMember[i] == ID ) return true;
	}
	return false;
}

function HandlePartyRenameMember(string Param)
{
	local int idx;
	local int ID;
	local int UseVName;
	local int DominionIDForVName;
	local string VName;
	local string SummonVName;
	
	ParseInt(Param, "ID", ID);
	ParseInt(Param, "UseVName",UseVName);
	ParseInt(Param, "DominionIDForVName", DominionIDForVName);
	ParseString(Param, "VName", VName);
	ParseString(Param, "SummonVName", SummonVName);
	
	idx = GetVNameIndexByID( ID );
	if( idx > -1 )
	{
		m_Vname[idx].ID = ID;
		m_Vname[idx].UseVName = UseVName;
		m_Vname[idx].DominionIDForVName = DominionIDForVName;
		m_Vname[idx].VName = VName;
		m_Vname[idx].SummonVName = SummonVName;
		ExecuteEvent( EV_TargetUpdate);
	}	
}

// ????? ???? ???????? ???? ???? ????? ???.
function HandleCheckTarget()
{
	local int idx;
	
	idx = -1;
	
	m_TargetID = class'UIDATA_TARGET'.static.GetTargetID();
	if(m_TargetID > 0)	{	idx = FindPartyID(m_TargetID);	}
	
	// ?????? ???? ?????? ?????? ??? ???? ????
	if( m_LastChangeColor != -1) 
	{			
		m_PartyStatus[m_LastChangeColor].SetBackTexture("L2UI_CT1.Windows.Windows_DF_Small_Vertical_SizeControl_Bg_Darker");
		m_TargetID	 = -1;
		m_LastChangeColor = -1;
	}

	if(idx != -1) 
	{
		m_LastChangeColor = idx;
		m_PartyStatus[idx].SetBackTexture("L2UI_CT1.Windows.Windows_DF_Small_Vertical_SizeControl_Bg_Over");
	}
}




//???????? ??? ???????
function HandleRestart()
{
	Clear();
}

function ClearTargetHighLight () 
{
	local int i;
	for ( i = 0 ; i < MAX_ArrayNum ; i ++ ) 	
		m_PartyStatus[i].SetBackTexture("L2UI_CT1.Windows.Windows_DF_Small_Vertical_SizeControl_Bg_Darker");
	
	m_LastChangeColor = -1;
}

//????
function Clear()
{	
	local int idx;
	for (idx=0; idx<MAX_ArrayNum; idx++)
	{
		ClearStatus(idx);		// ??? ?????? ?????????. 
		ClearPetStatus(idx);
		ClearSummonStatus(idx);

		m_arrSummonID[idx] = -1;
	}

	currentIndex = 0 ;
	matchGroupCount = 0 ;
	partyCount = 0 ;

	m_CurCount = 0;
	m_TargetID	 = -1;
	m_LastChangeColor = -1;
	ResizeWnd();
	ClearTargetHighLight();

	//Debug("AutoPartyMatchingStatusWnd ????!!!!!");	
	//HideWindow( "AutoPartyMatchingStatusWnd" ); ?????? ????
}

//??????? ????
function ClearStatus(int idx)
{
	m_StatusIconBuff[idx].Clear();
	m_StatusIconDeBuff[idx].Clear();
	m_StatusIconSongDance[idx].Clear();
	m_StatusIconTriggerSkill[idx].Clear();
	m_PlayerName[idx].SetName("", NCT_Normal,TA_Left);
	m_LeaderIcon[idx].SetTexture("");
	m_ClassIcon[idx].SetTexture("");
	UpdateCPBar(idx, 0, 0);
	UpdateHPBar(idx, 0, 0);
	UpdateMPBar(idx, 0, 0);
	m_arrID[idx] = 0;
}

// ?? ??????? ????
function ClearPetStatus(int idx)
{
	m_PetStatusIconBuff[idx].Clear();
	m_PetStatusIconDeBuff[idx].Clear();
	m_PetStatusIconSongDance[idx].Clear();
	m_PetStatusIconTriggerSkill[idx].Clear();
	//m_PetName[idx].SetName("", NCT_Normal,TA_Left);
	//m_PetClassIcon[idx].SetTexture("");
	m_PetClassIcon[idx].HideWindow();
	UpdateHPBar(idx + 100, 0, 0);
	UpdateMPBar(idx + 100, 0, 0);
	
	//if(m_PetPartyStatus[idx].IsShowWindow()) m_PetPartyStatus[idx].HideWindow();	// ??? ?????
	// if(m_petButton[idx].IsShowWindow()) m_petButton[idx].HideWindow();
	m_arrPetID[idx] = -1;
	m_arrPetIDOpen[idx] = -1;
	m_arrSummonID[idx] = -1;
}

// ?? ??????? ????
function ClearSummonStatus(int idx)
{
	m_arrSummonID[idx] = -1;

	m_ClassIconSummon[idx].HideWindow();
	m_ClassIconSummonNum[idx].HideWindow();
}

//?????? ???? (?????? ??? ?????? ??????, ?????? ?????? ??????)
function CopyStatus(int DesIndex, int SrcIndex)
{
	local string	strTmp;	
	local int		MaxValue;	// CP, HP, MP?? ???S.
	local int		CurValue;	// CP, HP, MP?? ?????.
	
	local int		Width;
	local int		Height;
	
	local int		Row;
	local int		Col;
	local int		MaxRow;
	local int		MaxCol;
	local StatusIconInfo info;
	
	//Custom Tooltip
	local CustomTooltip TooltipInfo;
	local CustomTooltip TooltipInfo2;
	
	local string vpIconTextureName, vpToolTipString;

	local Color nameColor ;	

	//ServerID
	m_arrID[DesIndex] = m_arrID[SrcIndex];	
	
	//Class Texture
	m_ClassIcon[DesIndex].SetTexture(m_ClassIcon[SrcIndex].GetTextureName());
	//Class Tooltip
	m_ClassIcon[SrcIndex].GetTooltipCustomType(TooltipInfo);
	m_ClassIcon[DesIndex].SetTooltipCustomType(TooltipInfo);
	
	//????? Texture
	strTmp = m_LeaderIcon[SrcIndex].GetTextureName();
	m_LeaderIcon[DesIndex].SetTexture(strTmp);
	if (Len(strTmp)>0)
	{
		//???????? ????? ???? ??????????.
		strTmp = m_PlayerName[DesIndex].GetName();
		GetTextSizeDefault(strTmp, Width, Height);
		//?????? ?????
		//m_LeaderIcon[DesIndex].SetAnchor("PartyWndArena.PartyStatusWnd" $ DesIndex, "TopCenter", "TopLeft", -(Width/2)-18, 8);		
		//SetTypePosition
		m_LeaderIcon[DesIndex].ShowWindow();
	}
	//???? ??? ????
	m_LeaderIcon[SrcIndex].GetTooltipCustomType(TooltipInfo2);
	m_LeaderIcon[DesIndex].SetTooltipCustomType(TooltipInfo2);
	
	//CP,HP,MP
	m_BarCP[SrcIndex].GetValue(MaxValue, CurValue);
	m_BarCP[DesIndex].SetValue(MaxValue, CurValue);	
	m_BarMP[SrcIndex].GetValue(MaxValue, CurValue);
	m_BarMP[DesIndex].SetValue(MaxValue, CurValue);

	m_BarHP[SrcIndex].GetValue(MaxValue, CurValue);
	m_BarHP[DesIndex].SetValue(MaxValue, CurValue);

	// ???? ????.
	if ( CurValue == 0 ) m_IsDead[DesIndex].ShowWindow();
	else m_IsDead[DesIndex].hideWindow();

	// ??? ????? ??? ????? ???? ????
	if ( isMatchGroupMember ( m_arrID[DesIndex] ) ) 
	{
		// HP ?? ???.
		nameColor.R = 238;
		nameColor.G = 170;
		nameColor.B = 255;
		nameColor.A = 255;
	}
	else nameColor = util.White;
	//Name
	m_PlayerName[DesIndex].SetNameWithColor(m_PlayerName[SrcIndex].GetName(), NCT_Normal,TA_Left, nameColor);
//	m_PlayerName[idx].SetNameWithColor(VName, NCT_Normal,TA_Left, nameColor);

	// vp ??? 
	vpIconTextureName = m_VPIcon[DesIndex].GetTextureName();
	vpToolTipString = m_VPIcon[DesIndex].GetTooltipText();

	m_VPIcon[DesIndex].SetTexture(m_VPIcon[SrcIndex].GetTextureName());
	m_VPIcon[DesIndex].SetTooltipText(m_VPIcon[SrcIndex].GetTooltipText());

	m_VPIcon[SrcIndex].SetTexture(vpIconTextureName);
	m_VPIcon[SrcIndex].SetTooltipText(vpToolTipString);

	//BuffStatus
	m_StatusIconBuff[DesIndex].Clear();
	MaxRow = m_StatusIconBuff[SrcIndex].GetRowCount();
	for (Row=0; Row<MaxRow; Row++)
	{
		m_StatusIconBuff[DesIndex].AddRow();
		MaxCol = m_StatusIconBuff[SrcIndex].GetColCount(Row);
		for (Col=0; Col<MaxCol; Col++)
		{
			m_StatusIconBuff[SrcIndex].GetItem(Row, Col, info);
			m_StatusIconBuff[DesIndex].AddCol(Row, info);
		}
	}
	
	//DeBuffStatus
	m_StatusIconDeBuff[DesIndex].Clear();
	MaxRow = m_StatusIconDeBuff[SrcIndex].GetRowCount();
	for (Row=0; Row<MaxRow; Row++)
	{
		m_StatusIconDeBuff[DesIndex].AddRow();
		MaxCol = m_StatusIconDeBuff[SrcIndex].GetColCount(Row);
		for (Col=0; Col<MaxCol; Col++)
		{			
			m_StatusIconDeBuff[SrcIndex].GetItem(Row, Col, info);
			info.bHideRemainTime = true;
			m_StatusIconDeBuff[DesIndex].AddCol(Row, info);
		}
	}
	
	//SongDanceStatus
	m_StatusIconSongDance[DesIndex].Clear();
	MaxRow = m_StatusIconSongDance[SrcIndex].GetRowCount();
	for (Row=0; Row<MaxRow; Row++)
	{
		m_StatusIconSongDance[DesIndex].AddRow();
		MaxCol = m_StatusIconSongDance[SrcIndex].GetColCount(Row);
		for (Col=0; Col<MaxCol; Col++)
		{
			m_StatusIconSongDance[SrcIndex].GetItem(Row, Col, info);
			m_StatusIconSongDance[DesIndex].AddCol(Row, info);
		}
	}

	//TriggerSkillStatus
	m_StatusIconTriggerSkill[DesIndex].Clear();
	MaxRow = m_StatusIconTriggerSkill[SrcIndex].GetRowCount();
	for (Row=0; Row<MaxRow; Row++)
	{
		m_StatusIconTriggerSkill[DesIndex].AddRow();
		MaxCol = m_StatusIconTriggerSkill[SrcIndex].GetColCount(Row);
		for (Col=0; Col<MaxCol; Col++)
		{
			m_StatusIconTriggerSkill[SrcIndex].GetItem(Row, Col, info);
			m_StatusIconTriggerSkill[DesIndex].AddCol(Row, info);
		}
	}	
	
	// -------------------------------------------??? ??????. 
	//ServerID
	m_arrPetID[DesIndex] = m_arrPetID[SrcIndex];
	m_arrSummonID[DesIndex] = m_arrSummonID[SrcIndex];

	// ?? & ????? ???? ? ???? ????? ????
	m_arrPetIDOpen[DesIndex] = m_arrPetIDOpen[SrcIndex];;	
	
	//CP,HP,MP
	m_PetBarHP[SrcIndex].GetValue(MaxValue, CurValue);
	m_PetBarHP[DesIndex].SetValue(MaxValue, CurValue);
	m_PetBarMP[SrcIndex].GetValue(MaxValue, CurValue);
	m_PetBarMP[DesIndex].SetValue(MaxValue, CurValue);
	
	
	//BuffStatus
	m_PetStatusIconBuff[DesIndex].Clear();
	MaxRow = m_PetStatusIconBuff[SrcIndex].GetRowCount();
	for (Row=0; Row<MaxRow; Row++)
	{
		m_PetStatusIconBuff[DesIndex].AddRow();
		MaxCol = m_PetStatusIconBuff[SrcIndex].GetColCount(Row);
		for (Col=0; Col<MaxCol; Col++)
		{
			m_PetStatusIconBuff[SrcIndex].GetItem(Row, Col, info);
			m_PetStatusIconBuff[DesIndex].AddCol(Row, info);
		}
	}
	
	//DeBuffStatus
	m_PetStatusIconDeBuff[DesIndex].Clear();
	MaxRow = m_PetStatusIconDeBuff[SrcIndex].GetRowCount();
	for (Row=0; Row<MaxRow; Row++)
	{
		m_PetStatusIconDeBuff[DesIndex].AddRow();
		MaxCol = m_PetStatusIconDeBuff[SrcIndex].GetColCount(Row);
		for (Col=0; Col<MaxCol; Col++)
		{
			m_PetStatusIconDeBuff[SrcIndex].GetItem(Row, Col, info);
			info.bHideRemainTime = true;
			m_PetStatusIconDeBuff[DesIndex].AddCol(Row, info);
		}
	}

	//SongDanceStatus
	m_PetStatusIconSongDance[DesIndex].Clear();
	MaxRow = m_PetStatusIconSongDance[SrcIndex].GetRowCount();
	for (Row=0; Row<MaxRow; Row++)
	{
		m_PetStatusIconSongDance[DesIndex].AddRow();
		MaxCol = m_PetStatusIconSongDance[SrcIndex].GetColCount(Row);
		for (Col=0; Col<MaxCol; Col++)
		{
			m_PetStatusIconSongDance[SrcIndex].GetItem(Row, Col, info);
			m_PetStatusIconSongDance[DesIndex].AddCol(Row, info);
		}
	}

	//TriggerSkillStatus
	m_PetStatusIconTriggerSkill[DesIndex].Clear();
	MaxRow = m_PetStatusIconTriggerSkill[SrcIndex].GetRowCount();
	for (Row=0; Row<MaxRow; Row++)
	{
		m_PetStatusIconTriggerSkill[DesIndex].AddRow();
		MaxCol = m_PetStatusIconTriggerSkill[SrcIndex].GetColCount(Row);
		for (Col=0; Col<MaxCol; Col++)
		{
			m_PetStatusIconTriggerSkill[SrcIndex].GetItem(Row, Col, info);
			m_PetStatusIconTriggerSkill[DesIndex].AddCol(Row, info);
		}
	}

	// ????? ???
	ClearTargetHighLight();
	HandleCheckTarget();
}

function resizeOnly() 
{
	local int idx;
	local Rect rectWnd;
	local bool bOption;
	local int i;
	local int OpenPetCount;

	local  PartyMemberInfo partyMemberInfo;

	local int tmpInt;

	// SetOptionBool?? ???. ?? ?????? PartyWndOption ???? ?????
	GetINIInt( "PartyWndArena", "e", tmpInt, "Windowsinfo.ini"  ) ;
	bOption = bool ( tmpInt ) ;//GetOptionBool( "Game", "SmallPartyWnd" );
	
	// Debug("-- m_CurCount " @ m_CurCount);
	if (m_CurCount>0)
	{				
		for (idx=0; idx<MAX_ArrayNum; idx++)
		{
			if (idx<=m_CurCount-1)
			{
				if(idx >0 )	 //1 ???????? anchor?? ????????.
				{
					if(m_arrPetIDOpen[idx-1] == 1) // ?? ??????? ??????? ????????
					{
						m_PartyStatus[idx].SetAnchor("PartyWndArena.PartyStatusSummonWnd" $ idx-1, "BottomLeft", "TopLeft", 0, -4);	// ?? ?????? ?????? ????
					}
					else// ?? ??????? ??????? ???????? ??????? ??????
					{
						m_PartyStatus[idx].SetAnchor("PartyWndArena.PartyStatusWnd" $ idx-1, "BottomLeft", "TopLeft", 0, -4);	// ????? ?????? ????
					}
				}
				if(m_arrID[idx]!= 0 )
				{
					if (m_arrPetIDOpen[idx] > -1)  m_petButton[idx].showWindow();
					else	m_petButton[idx].HideWindow();

					m_PartyStatus[idx].SetVirtualDrag( true );
					m_PartyStatus[idx].ShowWindow();
				}
				// if(m_arrPetIDOpen[idx] == 1) m_PetPartyStatus[idx].ShowWindow();

				
				// ????? ????
				GetPartyMemberInfo(m_arrID[idx], partyMemberInfo);

				//Debug("RESIZE ---> partyMemberInfo.curSummonNum : "  @ partyMemberInfo.curSummonNum);
				// Debug("RESIZE ---> partyMemberInfo.curHavePet   : "  @ partyMemberInfo.curHavePet);
			
				// ??????? 1???? ??? ????, ???? ????
				// ????? ????
				if (partyMemberInfo.curSummonNum > 0 || partyMemberInfo.curHavePet)
				{
					if (m_arrPetIDOpen[idx] == -1) 
					{
						m_arrPetIDOpen[idx] = 1;
					}
					
					// ??????? ????.
					m_PetPartyStatus[idx].ShowWindow();

					// Debug("m_arrPetIDOpen[i] " @ m_arrPetIDOpen[idx]);
					// Debug("-??????? ???? " @ idx @ "  - > "  @ partyMemberInfo.curSummonNum);

					// ??????? ????? ?? ????..
					if (partyMemberInfo.curSummonNum > 0)
					{						
						m_ClassIconSummon[idx].ShowWindow();
						setHideClassIconSummonNum( idx ) ;
						//m_ClassIconSummonNum[idx].ShowWindow();
						m_ClassIconSummonNum[idx].SetTexture("L2UI_ch3.PartyWndArena.party_summmon_num" $ String(partyMemberInfo.curSummonNum));
					}
					else
					{
						// ??????? ?????..
						m_ClassIconSummon[idx].HideWindow();
						m_ClassIconSummonNum[idx].HideWindow();
					}

					// ????? ???? ??&????? ??? ??? ?????? ??? ???? ?????? ?????..
					//if (m_arrPetIDOpen[idx] != 2)

					// ???? ???? ????..
					if (partyMemberInfo.curHavePet)
					{
						m_PetBarMP[idx].ShowWindow();
						m_PetBarHP[idx].ShowWindow();
						m_PetClassIcon[idx].ShowWindow();
					}
					else
					{
						// ???? ?????..
						m_PetBarMP[idx].HideWindow();
						m_PetBarHP[idx].HideWindow();
						m_PetClassIcon[idx].HideWindow();
					}
				}
				else
				{
					// ??, ????? ????? ?????.. ????? ??? 					
					m_PetPartyStatus[idx].HideWindow();
					m_arrPetIDOpen[idx] = -1;
				}

			}
			else
			{
				//Debug("? ???---rerere " @idx);
				m_petButton[idx].HideWindow();
				m_PartyStatus[idx].SetVirtualDrag( false );
				m_PartyStatus[idx].HideWindow();
				m_PetPartyStatus[idx].HideWindow();
			}
		}

		// ??? ? ?????? ???????.
		OpenPetCount=0;
		for(i=0; i<MAX_ArrayNum; i++)
		{
			// Debug("m_arrPetIDOpen[i]==::" @ m_arrPetIDOpen[i]);
			if(m_arrPetIDOpen[i] == 1)
			{   
				OpenPetCount++;
			}
			else 	// ??????? ?????? ????..
			{
				 if(m_PetPartyStatus[i].IsShowWindow()) m_PetPartyStatus[i].HideWindow();
			}
		}

		// Debug("OpenPetCount : " @ OpenPetCount);
		
		//?????? ?????? ????
		rectWnd = m_wndTop.GetRect();
		m_wndTop.SetWindowSize(rectWnd.nWidth, NPARTYSTATUS_HEIGHT*m_CurCount + OpenPetCount * NPARTYPETSTATUS_HEIGHT);	
		// ????? ?????? ??? ?????? ???????? ???????. 
		m_wndTop.SetResizeFrameSize(10, NPARTYSTATUS_HEIGHT*m_CurCount  + OpenPetCount * NPARTYPETSTATUS_HEIGHT);
		
	}
	else	// ??????? ???????? ?????? ?? ??????? ?????? ?????.
	{
		m_wndTop.HideWindow();
	}
}


//???????? ?????? ????
function ResizeWnd()
{
	local int idx;
	local Rect rectWnd;
	local bool bOption;
	local int i;
	local int OpenPetCount;

	local  PartyMemberInfo partyMemberInfo;

	local int tmpInt;

	// SetOptionBool?? ???. ?? ?????? PartyWndOption ???? ?????
	GetINIInt( "PartyWndArena", "e", tmpInt, "Windowsinfo.ini"  ) ;
	bOption = bool ( tmpInt ) ;//GetOptionBool( "Game", "SmallPartyWnd" );
	
	// Debug("-- m_CurCount " @ m_CurCount);
	if (m_CurCount>0)
	{				
		for (idx=0; idx<MAX_ArrayNum; idx++)
		{
			if (idx<=m_CurCount-1)
			{
				if(idx >0 )	 //1 ???????? anchor?? ????????.
				{
					if(m_arrPetIDOpen[idx-1] == 1) // ?? ??????? ??????? ????????
					{
						m_PartyStatus[idx].SetAnchor("PartyWndArena.PartyStatusSummonWnd" $ idx-1, "BottomLeft", "TopLeft", 0, -4);	// ?? ?????? ?????? ????
					}
					else// ?? ??????? ??????? ???????? ??????? ??????
					{
						m_PartyStatus[idx].SetAnchor("PartyWndArena.PartyStatusWnd" $ idx-1, "BottomLeft", "TopLeft", 0, -4);	// ????? ?????? ????
					}
				}
				if(m_arrID[idx]!= 0 )
				{
					if (m_arrPetIDOpen[idx] > -1)  m_petButton[idx].showWindow();
					else	m_petButton[idx].HideWindow();

					m_PartyStatus[idx].SetVirtualDrag( true );
					m_PartyStatus[idx].ShowWindow();
				}
				// if(m_arrPetIDOpen[idx] == 1) m_PetPartyStatus[idx].ShowWindow();

				
				// ????? ????
				GetPartyMemberInfo(m_arrID[idx], partyMemberInfo);

				//Debug("RESIZE ---> partyMemberInfo.curSummonNum : "  @ partyMemberInfo.curSummonNum);
				// Debug("RESIZE ---> partyMemberInfo.curHavePet   : "  @ partyMemberInfo.curHavePet);
			
				// ??????? 1???? ??? ????, ???? ????
				// ????? ????
				if (partyMemberInfo.curSummonNum > 0 || partyMemberInfo.curHavePet)
				{
					if (m_arrPetIDOpen[idx] == -1) 
					{
						m_arrPetIDOpen[idx] = 1;
					}
					
					// ??????? ????.
					m_PetPartyStatus[idx].ShowWindow();

					// Debug("m_arrPetIDOpen[i] " @ m_arrPetIDOpen[idx]);
					// Debug("-??????? ???? " @ idx @ "  - > "  @ partyMemberInfo.curSummonNum);

					// ??????? ????? ?? ????..
					if (partyMemberInfo.curSummonNum > 0)
					{						
						m_ClassIconSummon[idx].ShowWindow();
						setHideClassIconSummonNum( idx ) ;
						//m_ClassIconSummonNum[idx].ShowWindow();
						m_ClassIconSummonNum[idx].SetTexture("L2UI_ch3.PartyWndArena.party_summmon_num" $ String(partyMemberInfo.curSummonNum));
					}
					else
					{
						// ??????? ?????..
						m_ClassIconSummon[idx].HideWindow();
						m_ClassIconSummonNum[idx].HideWindow();
					}

					// ????? ???? ??&????? ??? ??? ?????? ??? ???? ?????? ?????..
					//if (m_arrPetIDOpen[idx] != 2)

					// ???? ???? ????..
					if (partyMemberInfo.curHavePet)
					{
						m_PetBarMP[idx].ShowWindow();
						m_PetBarHP[idx].ShowWindow();
						m_PetClassIcon[idx].ShowWindow();
					}
					else
					{
						// ???? ?????..
						m_PetBarMP[idx].HideWindow();
						m_PetBarHP[idx].HideWindow();
						m_PetClassIcon[idx].HideWindow();
					}
				}
				else
				{
					// ??, ????? ????? ?????.. ????? ??? 					
					m_PetPartyStatus[idx].HideWindow();
					m_arrPetIDOpen[idx] = -1;
				}

			}
			else
			{
				//Debug("? ???---rerere " @idx);
				m_petButton[idx].HideWindow();
				m_PartyStatus[idx].SetVirtualDrag( false );
				m_PartyStatus[idx].HideWindow();
				m_PetPartyStatus[idx].HideWindow();
			}
		}

		// ??? ? ?????? ???????.
		OpenPetCount=0;
		for(i=0; i<MAX_ArrayNum; i++)
		{
			// Debug("m_arrPetIDOpen[i]==::" @ m_arrPetIDOpen[i]);
			if(m_arrPetIDOpen[i] == 1)
			{   
				OpenPetCount++;
			}
			else 	// ??????? ?????? ????..
			{
				 if(m_PetPartyStatus[i].IsShowWindow()) m_PetPartyStatus[i].HideWindow();
			}
		}

		// Debug("OpenPetCount : " @ OpenPetCount);
		
		//?????? ?????? ????
		rectWnd = m_wndTop.GetRect();
		m_wndTop.SetWindowSize(rectWnd.nWidth, NPARTYSTATUS_HEIGHT*m_CurCount + OpenPetCount * NPARTYPETSTATUS_HEIGHT);	
		// ????? ?????? ??? ?????? ???????? ???????. 
		m_wndTop.SetResizeFrameSize(10, NPARTYSTATUS_HEIGHT*m_CurCount  + OpenPetCount * NPARTYPETSTATUS_HEIGHT);

		m_wndTop.ShowWindow();

		//if (!bOption)	// ?????? ???? ??????? ?????? ???? (????) ??????? ????
		//	m_wndTop.ShowWindow();
		//else
		//	m_wndTop.HideWindow();
	}
	else	// ??????? ???????? ?????? ?? ??????? ?????? ?????.
	{
		m_wndTop.HideWindow();
	}
}

//ID?? ????? ????? ????????? ?????
function int FindPartyID(int ID)
{
	local int idx;
	for (idx=0; idx<MAX_ArrayNum; idx++)
	{
		if (m_arrID[idx] == ID)
		{
			return idx;
		}
	}
	return -1;
}

//ID?? ????? ????? ?????? ?????
function int FindPetID(int ID)
{
	local int idx;
	for (idx=0; idx<MAX_ArrayNum; idx++)
	{
		if (m_arrPetID[idx] == ID)
		{
			return idx;
		}
	}
	return -1;
}

//ID?? ????? ????? ????? ?????????? ?????
function int FindSummonMasterID(int ID)
{
	local int idx;
	for (idx=0; idx<MAX_ArrayNum; idx++)
	{
		if (m_arrSummonID[idx] == ID)
		{
			return idx;
		}
	}
	return -1;
}

//ADD	????? ???.
function HandlePartyAddParty(string param)
{
	local int ID;
	local int SummonID;
	
	local int UseVName;
	local int DominionIDForVName;
	local int SummonCount;
	local string VName;
	local string SummonVName;

	// ??? ??? ????
	local PartyMemberInfo    partyMemberInfo;
	// ??? ??? ?? ????
	local PartyMemberPetInfo partyMemberPetInfo;

	local int index, i, summonClassID;

	local int summonType, summonMAXHP, summonMAXMP, summonHP, summonMP;
		

//	debug("HandlePartyAddParty>>" $ param);

	ParseInt(param, "ID", ID);	// ID?? ??????.
	ParseInt(param, "SummonID", SummonID);
	ParseInt(Param, "UseVName",UseVName);
	ParseInt(Param, "DominionIDForVName", DominionIDForVName);
	// ParseString(Param, "VName", VName);
	ParseString(Param, "SummonVName", SummonVName);	
	
	GetPartyMemberInfo(ID, partyMemberInfo);

	// ????? ???? ?????.
	// ParseInt(Param, "SummonCount", summonCount);
	GetPartyMemberPetInfo(ID, partyMemberPetInfo);	

	if (ID>0)
	{		
		// ??? ????? ??? ??? ??? ?????.
		if ( isMatchGroupMember( ID ) )
		{
			currentIndex = matchGroupCount;
			matchGroupCount ++ ;
		}
		else 
		{		
			currentIndex = m_arrMatchGroupMember.Length + partyCount ;
			partyCount ++ ;
		}

		m_CurCount++;
		m_Vname[currentIndex].ID = ID;
		m_Vname[currentIndex].UseVName = UseVName;
		m_Vname[currentIndex].DominionIDForVName = DominionIDForVName;
		m_Vname[currentIndex].VName = VName;
		m_Vname[currentIndex].SummonVName = SummonVName;
		ExecuteEvent( EV_TargetUpdate);
	
//		Debug("HandlePartyAddParty" @ currentIndex @ matchGroupCount @ partyCount @ m_CurCount @ m_arrMatchGroupMember.Length @ isMatchGroupMember( ID )) ;
		
		m_arrID[currentIndex] = ID;
		UpdateStatus(currentIndex, param);

		//util.showGfxScreenMessage ( MakeFullSystemMsg(getSystemMessage(107), m_PlayerName[currentIndex].GetName() )) ;

		// Debug("====================> param ?? ???? " @ param);
		// Debug(":::: m_CurCount ====> " @ m_CurCount);
		// Debug("partyMemberInfo.curSummonNum: " @ partyMemberInfo.curSummonNum);
		// Debug("partyMemberInfo.curHavePet  : " @ partyMemberInfo.curHavePet);
		// if(SummonID > 0)	// ??????? ?????? ??????? ??????
		// ??????? ????
		
		// ??????? ????? ???, ??? ???? ???? ????..
		if (partyMemberInfo.curSummonNum > 0)
		{
			// ????? ?????? ID ?? ??? ????? UI ????
			PartySummonProcess(ID);

			for (i = 0; i < SummonCount; i++)
			{
				ParseInt(param, "SummonType" $ i, summonType);
				ParseInt(param, "SummonClassID" $ i, summonClassID);

				// ??????? ?????..
				if (summonType == 1)
				{
					// ?????? ?????, ????? ????? ???? ?????? ???????.
					m_ClassIconSummon[currentIndex].SetTooltipText(GetSystemString(505));//getSummonSortString(class'UIDATA_NPC'.static.GetSummonSort(summonClassID)));
					//Debug( "npc : "@ class'UIDATA_NPC'.static.GetSummonSort(summonClassID) );
					
					break;
					// ???? ??? 
				}				
			}
		}

		if ( partyMemberInfo.curHavePet == true)
		{			
			// ???? ????? ??? 
			index = FindPartyID(ID);
			// Debug("??? ??? ?? " @ index);
			// ??? hp, mp ??? ???? ??? ?????

			ParseInt(param, "SummonCount", SummonCount);

			// summonType ?? 2?? ???? ?????. ???? ????..
			// HP, MP??? ???? ?????. 
			for (i = 0; i < SummonCount; i++)
			{
				ParseInt(param, "SummonType" $ i, summonType);

				if (summonType == 2)
				{
					ParseInt(param, "SummonMaxHP" $ i, SummonMaxHP);
					ParseInt(param, "SummonMaxMP" $ i, SummonMaxMP);
					ParseInt(param, "SummonHP"    $ i, SummonHP);
					ParseInt(param, "SummonMP"    $ i, SummonMP);

					// Debug("?? ??????? -> ??? -> "@ SummonMaxHP);
					UpdateHPBar(index + 100, SummonHP, SummonMaxHP);
					UpdateMPBar(index + 100, SummonMP, SummonMaxMP);
				}				
			}

			m_arrPetID[index] = partyMemberPetInfo.petID;
			// m_arrPetIDOpen[index] = 1;			
		}		

		ResizeWnd();
	}
}


//UPDATE	??? ????? ???????.
function HandlePartyUpdateParty(string param)
{
	local int	ID;
	local int	idx;
	
	//Debug("??? :" @ param);

	ParseInt(param, "ID", ID);	

	if (ID>0)
	{
		idx = FindPartyID(ID);
		UpdateStatus(idx, param);	// ??? ???????? ????? ?????? ????
	}
}

//DELETE	??? ??????? ????.
function HandlePartyDeleteParty(string param)
{
	local int	ID;
	local int	idx;
	local int	i;
	
	//Debug("??? ??????? ???? :" @ param);
	
	ParseInt(param, "ID", ID);

	if (ID>0)
	{
		idx = FindPartyID(ID);	
		//util.showGfxScreenMessage ( MakeFullSystemMsg(getSystemMessage(108), m_PlayerName[idx].GetName() )) ;

		if (idx>-1)
		{	
			if ( isMatchGroupMember ( ID ) ) 				
				matchGroupCount --;
			else partyCount --;

			for (i=idx; i<m_CurCount-1; i++)	// ????????? ????? ????? ????????? ???????. 
			{
				CopyStatus(i, i+1);
			}
			ClearStatus(m_CurCount-1);
			ClearPetStatus(m_CurCount-1);
			m_CurCount--;
			ResizeWnd();	// ???? ??????? ????? ????? ???? ?????????? ?????.
		}
		
	}
}

//DELETE ALL	???? ??? ?????..
function HandlePartyDeleteAllParty()
{
	Clear();
}

//Set Info	??? ???????? ??????? ???? ????. ???? ????? ?????? ????? ???? ??????.

function SetMasterTooltip(int lootingtype)
{
	if(partymasteridx < MAX_ArrayNum && partymasteridx > -1)
		m_LeaderIcon[partymasteridx].SetTooltipCustomType(MakeTooltipSimpleText(GetRoutingString(lootingtype)));	
}

function UpdateStatus(int idx, string param)
{
	local string	Name;
	local string	DisplayName;
	//local int		MasterID;
	//local int		RoutingType;
	local int		ID;
	local int		CP;
	local int		MaxCP;
	local int		HP;
	local int		MaxHP;
	local int		MP;
	local int		MaxMP;
	local int		ClassID;
	local int		Level;
	local int		Vitality;
	local int       IsBRPremium;
	local string    premiumText;
	local userinfo 	TargetUser;
	//~ local int		SummonID;
	
	//local int		Width;
	//local int		Height;	
	
	local int UseVName;
	//local int DominionIDForVName;
	local string VName;
	//local string SummonVName;
	
	//????? ?? 
	local int SummonCount; 
	// ????? ???? 
	//local string SummonTooltipStr;
	// ????? ?????? 
	//local string SummonNickName; 
	
	//??????????? ?????? ???????
	local int iSubstatus;

	local Color nameColor;

	ParseInt(param, "SubStitute", iSubstatus);

	if (idx<0 || idx>=MAX_ArrayNum)
		return;
	
	ParseString(param, "Name", Name);
	ParseInt(param, "ID", ID);
	GetUserInfo(ID, TargetUser);
	
	ParseInt(param, "CurCP", CP);
	ParseInt(param, "MaxCP", MaxCP);
	ParseInt(param, "CurHP", HP);
	ParseInt(param, "MaxHP", MaxHP);
	ParseInt(param, "CurMP", MP);
	ParseInt(param, "MaxMP", MaxMP);
	ParseInt(param, "ClassID", ClassID);
	ParseInt(param, "Level", Level);
	ParseInt(param, "Vitality", Vitality);
	if (!ParseInt(param, "IsBRPremium", IsBRPremium))
	{
		if (!ParseInt(param, "isBRPremium", IsBRPremium))
		{
			if (!ParseInt(param, "Premium", IsBRPremium))
			{
				if (!ParseInt(param, "IsPremium", IsBRPremium))
					IsBRPremium = 0;
			}
		}
	}

	ParseInt(param, "SummonCount", SummonCount);

	//????? ?????.
	//ParseInt(param, "MasterID", PartyLeaderID);

	if ( isMatchGroupMember ( ID ) ) 
	{		
		nameColor.R = 238;
		nameColor.G = 170;
		nameColor.B = 255;
		nameColor.A = 255 ;	
	}		
	else nameColor = util.White;

	if ( HP == 0 ) m_IsDead[idx].ShowWindow();
	else m_IsDead[idx].hideWindow();
	
	//???? ????? 0
	/*
	for(i = 0; i < SummonCount; i++) 
	{
		ParseString (param, "SummonNickName" $i, SummonNickName);		
		ParseInt(param, "SummonID"      $ i, SummonID);		
		ParseInt(param, "SummonType"    $ i, SummonType);
		ParseInt(param, "SummonClassID" $ i, SummonClassID);		
		ParseInt(param, "SummonHP"      $ i, SummonHP);
		ParseInt(param, "SummonMaxHP"   $ i, SummonMaxHP);
		ParseInt(param, "SummonMP"      $ i, SummonMP);
		ParseInt(param, "SummonMaxMP"   $ i, SummonMaxMP);
		ParseInt(param, "SummonLevel"   $ i, SummonLevel);
		
	}
	*/

	// ??????? ???? ????..
	/*
	if (SummonCount > 0)
	{
		SummonTooltipStr = SummonNickName;
	}*/

	UseVName = m_Vname[idx].UseVName;
	//DominionIDForVName = m_Vname[idx].DominionIDForVName;
	VName = m_Vname[idx].VName;
	//SummonVName = m_Vname[idx].SummonVName;
	
	if (UseVName == 1)
		DisplayName = VName;
	else
		DisplayName = Name;

	if (IsBRPremium > 0)
	{
		DisplayName = "[PA] " $ DisplayName;
	}
	DisplayName = DisplayName $ " Lv." $ string(Level);

	m_PlayerName[idx].SetNameWithColor(DisplayName, NCT_Normal,TA_Left, nameColor);
	
	//???? ??????
	//if (ParseInt(param, "MasterID", MasterID))
	//{
	//	if (MasterID>0 && MasterID==ID)
	//	{	
	//		partymasteridx = idx;
	//		ParseInt(param, "RoutingType", RoutingType);
	//		m_LeaderIcon[idx].SetTexture("L2UI_CH3.PartyWndArena.party_leadericon");
	//		m_LeaderIcon[idx].SetTooltipCustomType(MakeTooltipSimpleText(GetRoutingString(RoutingType)));
			
	//		//???????? ????? ???? ??????????.
	//		GetTextSizeDefault(Name, Width, Height);
	//		//m_LeaderIcon[idx].SetAnchor("PartyWndArena.PartyStatusWnd" $ idx, "TopCenter", "TopLeft", -(Width/2)-18, 8);
	//		//SetTypePosition( idx, 1 );
	//	}
	//	else
	//	{
	//		m_LeaderIcon[idx].SetTexture("");
	//		m_LeaderIcon[idx].SetTooltipCustomType(MakeTooltipSimpleText(""));
	//		//SetTypePosition( idx, 0 );
	//	}
	//}
	
	if (IsBRPremium > 0)
		premiumText = "Premium: ON";
	else
		premiumText = "Premium: OFF";

	//???? ??????
	//m_ClassIcon[idx].SetTexture(GetClassRoleIconName(ClassID));	
	m_ClassIcon[idx].SetTexture(GetClassArenaRoleIconName(ClassID));
	
	m_ClassIcon[idx].SetTooltipCustomType(MakeTooltipSimpleText(GetClassRoleName(ClassID) $ " - " $ GetClassType(ClassID) $ " / Lv." $ string(Level) $ " / " $ premiumText));
	
	//???? ??????
	UpdateCPBar(idx, CP, MaxCP);
	UpdateHPBar(idx, HP, MaxHP);
	UpdateMPBar(idx, MP, MaxMP);

	//????? ????? ???? Vitality?? ????, ????? update????? ????.???
}

function HandlePartyPetAdd( string param )
{
	local int	MasterID;
	local int	ID;
	local int	i;

	// ????? 1, ?? 2
	local int   type;
	local int	MasterIndex;
	
	ParseInt(param, "Type", type);	// ?????? ID?? ??????.

	// Debug("?? ??? @" @ param);
	if (type == 2)
	{
		// ?????? ID?? ??????.
		ParseInt(param, "MasterID", MasterID);	

		// ID?? ??????.
		ParseInt(param, "ID", ID);	

		if (MasterID>0)
		{
			MasterIndex = -1;
			for(i=0; i< MAX_ArrayNum ; i++)
			{
				if(m_arrID[i] == MasterID) MasterIndex = i;
			}
			
			if(MasterIndex == -1)
			{
				//debug("HandlePartyPetAdd ERROR - Can't find master ID");
				return;
			}
						
			m_arrPetID[MasterIndex] = ID;
			m_arrPetIDOpen[MasterIndex] = 1;

			UpdatePetStatus(MasterIndex, param);
			ResizeWnd();
		}
	}
}

function HandlePartyPetUpdate( string param )
{
	local int	id;
	local int	idx;

	local int	type;
	
	//debug(" PartySummonUpdate !! ");

	// ????? 1, ?? 2 
	ParseInt(param, "Type", type);

	ParseInt(param, "ID", id);
	// Debug("?? ???????"@ param);
	
	// ?? 
	if (type == 2)
	{	
		idx = FindPetID(id);

		// Debug("idx " @ idx);
		// ??? ???????? ?? ?????? ????
		UpdatePetStatus(idx, param);	
	}
}


function HandlePartyPetDelete( string param )
{
	local int	SummonID;
	local int	idx;
	//~ local int	i;
	
	ParseInt(param, "SummonID", SummonID);
	if (SummonID>0)
	{
		idx = FindPetID(SummonID);
		if (idx>-1)
		{	
			ClearPetStatus(idx);
			ResizeWnd();	// ???? ??????? ????? ????? ???? ?????????? ?????.
		}
	}
}


function UpdatePetStatus(int idx, string param)
{
	local int		ID;			// ?? ID
	local int		ClassID;	// ?? ????
	local int		Type;		// ?? ??? 1-????? 2-??
	local int		MasterID;	// ?????? ID
	// local string	NickName;  	// ?? ???
		
	local int		HP;
	local int		MaxHP;
	local int		MP;
	local int		MaxMP;
	local int		Level;
	
	if (idx<0 || idx>=MAX_ArrayNum)
		return;
	
	ParseInt(param, "ID", ID);
	ParseInt(param, "ClassID", ClassID);
	ParseInt(param, "Type", Type);
	ParseInt(param, "MasterID", MasterID);
	ParseInt(param, "HP", HP);
	ParseInt(param, "MaxHP", MaxHP);
	ParseInt(param, "MP", MP);
	ParseInt(param, "MaxMP", MaxMP);
	ParseInt(param, "Level", Level);
	
	//????
	// m_PetClassIcon[idx].SetTexture("L2UI_CT1.Icon.ICON_DF_PETICON");
	//m_PetClassIcon[idx].SetTooltipCustomType(MakeTooltipSimpleText(m_PetName[idx].GetName()));
			
	//?? ??????
	//m_ClassIcon[idx].SetTexture(GetClassRoleIconName(SummonClassID));
	//m_ClassIcon[idx].SetTooltipCustomType(MakeTooltipSimpleText(GetClassRoleName(ClassID) $ " - " $ GetClassType(ClassID)));
	
	// debug(" idx :MaxHP" @ idx @ "__" @MaxHP);
	//???? ??????
	UpdateHPBar(idx + 100, HP, MaxHP);
	UpdateMPBar(idx + 100, MP, MaxMP);
}

/**
 *  ??????? ????? ???
 **/
function HandlePartySummonAdd( string param )
{
	local int	MasterID;
	local int	ID;
	local int	idx;

	// ????? 1, ?? 2
	local int   type;

	local SummonInfo m_SummonInfo; 

	ParseInt(param, "Type", type);	
	ParseInt(param, "MasterID", MasterID);
	ParseInt(param, "ID", ID);

	GetSummonInfo(ID, m_SummonInfo);
	// debug("class " @  m_SummonInfo.nClassID);
	// Debug("????? ??? @" @ param);

	idx = FindSummonMasterID(MasterID);
	if (idx > 0)
	{
		m_ClassIconSummon[idx].SetTooltipText(GetSystemString(505));//getSummonSortString(class'UIDATA_NPC'.static.GetSummonSort(m_SummonInfo.nClassID)));
	}

	if (type == 1)
	{		
		PartySummonProcess(MasterID);
	}
}

/**
 *  ????? ??????? ?????? ???? ????????? ??? 
 **/
function PartySummonProcess( int MasterID ) 
{
	local int	i;

	local int	MasterIndex;

	local PartyMemberInfo partyMemberInfo;
	
	if (MasterID>0)
	{
		MasterIndex = -1;
		for(i=0; i< MAX_ArrayNum ; i++)
		{
			if(m_arrID[i] == MasterID)
			{
				MasterIndex = i;
				break;
			}
		}
		
		if(MasterIndex == -1)
		{
			//debug("PartySummonProcess -> ERROR - Can't find master ID");
			return;
		}
		
		GetPartyMemberInfo(MasterID, partyMemberInfo);

		if (partyMemberInfo.curSummonNum > 0)
		{
			// ?? ????? ???? ? ????
			// ????? ?????? ID ???
			m_arrSummonID[MasterIndex] = MasterID;
		}
		else
		{
			// ???
			// ????? ?????? ID ???
			m_arrSummonID[MasterIndex] = -1;			
		}
		
		// ? ???? 
		ResizeWnd();		
	}
}

/**
 *  ??????? ????? ???????
 **/
function HandlePartySummonUpdate( string param )
{
	local int	MasterID;

	// ????? 1, ?? 2
	local int   type;

	// ??? ????? ????? ????? ???? ??? ??? ???? ????? ??? ???? ??
	// debug("????? ??????? !" @param);

	ParseInt(param, "MasterID", MasterID);
	ParseInt(param, "Type", type);	

	// ????? 
	if (type == 1)
	{	
		PartySummonProcess(MasterID);
	}
}



function HandlePartySummonDelete( string param )
{
	local int	SummonMasterID;
	local int	idx;
	local  PartyMemberInfo partyMemberInfo;

	
	ParseInt(param, "SummonMasterID", SummonMasterID);

	if (SummonMasterID>0)
	{

		// ????? ???????? index ?? ?????.
		idx = FindSummonMasterID(SummonMasterID);

		GetPartyMemberInfo(SummonMasterID, partyMemberInfo);
		// Debug("????.. ---> partyMemberInfo.curSummonNum : "  @ partyMemberInfo.curSummonNum);

		// ??????? ????? ?? ????..
		if (partyMemberInfo.curSummonNum > 0)
		{						
			m_ClassIconSummon[idx].ShowWindow();
			setHideClassIconSummonNum( idx ) ;
			//m_ClassIconSummonNum[idx].ShowWindow();
			m_ClassIconSummonNum[idx].SetTexture("L2UI_ch3.PartyWndArena.party_summmon_num" $ String(partyMemberInfo.curSummonNum));
		}
		else
		{
			// ??????? ?????..
			ClearSummonStatus(idx);
		}		
		ResizeWnd();			
	}
}

/**
 *  ????? ???? ??????? 
 **/
function UpdateSummonStatus(int idx, string param)
{
	local int		ID;			// ?? ID
	local int		ClassID;		// ?? ????
	local int		Type;		    // ?? ??? 1-????? 2-??
	local int		MasterID;	    // ?????? ID
	// local string	NickName;  	// ?? ???
		
	local int		HP;
	local int		MaxHP;
	local int		MP;
	local int		MaxMP;
	local int		Level;
	
	if (idx<0 || idx>=MAX_ArrayNum)
		return;
	
	ParseInt(param, "ID", ID);
	ParseInt(param, "ClassID", ClassID);
	ParseInt(param, "Type", Type);
	ParseInt(param, "MasterID", MasterID);
	ParseInt(param, "HP", HP);
	ParseInt(param, "MaxHP", MaxHP);
	ParseInt(param, "MP", MP);
	ParseInt(param, "MaxMP", MaxMP);
	ParseInt(param, "Level", Level);
	
	
	// debug(":MaxHP" @MaxHP);
	//???? ??????

	// ?? ??????? ???? ???? ?????? ??? ???? ???? (???? ???? ???)
	// UpdateHPBar(idx + 100, HP, MaxHP);
	// UpdateMPBar(idx + 100, MP, MaxMP);
}


//?????????????
function HandlePartySpelledList(string param)
{
	local int i;
	local int idx;
	local int ID;
	local int Max;
	
	local int BuffCnt;
	local int BuffCurRow;
	
	local int DeBuffCnt;
	local int DeBuffCurRow;
	
	//~ local int SongDanceCnt;
	//local int SongDanceCurRow;
	
	local int TriggerSkillCnt;
	local int TriggerSkillCurRow;
	
	local bool isPC;	//pc???? ?????? ????? ???
	
	local StatusIconInfo info;
	
	DeBuffCurRow = -1;
	BuffCurRow = -1;
	//SongDanceCurRow = -1;
	TriggerSkillCurRow = -1;
	isPC = false;
	
	ParseInt(param, "ID", ID);
	if (ID<1)
	{
		return;
	}
	
	idx = FindPartyID(ID);
	if(idx >=0)
	{
		//???? ????
		m_StatusIconBuff[idx].Clear();
		m_StatusIconDeBuff[idx].Clear();
		m_StatusIconSongDance[idx].Clear();
		m_StatusIconTriggerSkill[idx].Clear();
		isPC = true;
	}
	else	// ???????? ???? ??? ????
	{
		idx = FindPetID(ID);	// ??????? ?????, ?????? ????a??. 
		if(idx >= 0)
		{
			//???? ????
			m_PetStatusIconBuff[idx].Clear();
			m_PetStatusIconDeBuff[idx].Clear();
			m_PetStatusIconSongDance[idx].Clear();
			m_PetStatusIconTriggerSkill[idx].Clear();
			isPC = false;
		}
		else
		{
			return;	// ?? ??????? ????? ?? ???????
		}
	}
		
	//info ????
	if ( isPC ) 
	{
		info.Size = 16;
	}
	else 
	{
		info.Size = 10;
	}
	
	info.bShow = true;
	
	ParseInt(param, "Max", Max);
	for (i=0; i<Max; i++)
	{
		ParseItemIDWithIndex(param, info.ID, i);
		ParseInt(param, "Level_" $ i, info.Level);
		ParseInt(param, "SubLevel_" $ i, info.SubLevel);

		// ???? ?????? ??? add ???? ????.
		if ( class'UIDATA_SKILL'.static.IsToppingSkill( info.ID, info.Level, info.SubLevel) ) 
		{			
			continue ;
		}

		ParseInt(param, "Sec_" $ i, info.RemainTime);

		ParseInt(param, "SpellerID_" $ i, info.SpellerID);

		//Debug( "HandlePartySpelledList" @ idx @ info.SpellerID @ info.Level @ info.ID.ClassID @  i);

		if (IsValidItemID(info.ID))
		{
			info.IconName = class'UIDATA_SKILL'.static.GetIconName(info.ID, info.Level, info.SubLevel);
			
			if (GetDebuffType( info.ID, info.Level, info.SubLevel) != 0 )
			{
				info.bHideRemainTime = true;
				if (DeBuffCnt%NSTATUSICON_MAXCOL == 0)
				{
					DeBuffCurRow++;
					if(isPC)	
					{			
						m_StatusIconDeBuff[idx].AddRow();
					}
					else		
					{	
						m_PetStatusIconDeBuff[idx].AddRow();
					}
				}
				if(isPC)	
				{				
					m_StatusIconDeBuff[idx].AddCol(DeBuffCurRow, info);	
				}
				else 		
				{					
					m_PetStatusIconDeBuff[idx].AddCol(DeBuffCurRow, info);	
				}
				DeBuffCnt++;
			}
			else if (IsSongDance( info.ID, info.Level, info.SubLevel) == true )
			{
				//~ debug("??????????");
				//~ SongDanceCurRow++;
				if(isPC)	
				{					
					m_StatusIconSongDance[idx].AddRow();
				}
				else		
				{				
					m_PetStatusIconSongDance[idx].AddRow();
				}
				
				if(isPC)	
				{				
					m_StatusIconSongDance[idx].AddCol(0, info);	
				}
				else 		
				{				
					m_PetStatusIconSongDance[idx].AddCol(0, info);	
				}
				//~ SongDanceCurRow++;
			}
			else if (IsTriggerSkill( info.ID, info.Level, info.SubLevel) == true )
			{
				//~ debug("????????????");
				if (TriggerSkillCnt % NSTATUSICON_MAXCOL == 0)
				{
					TriggerSkillCurRow++;
					if(isPC)	
					{				
						m_StatusIconTriggerSkill[idx].AddRow();
					}
					else		
					{					
						m_PetStatusIconTriggerSkill[idx].AddRow();
					}
				}
					
				if(isPC)	
				{					
					m_StatusIconTriggerSkill[idx].AddCol(TriggerSkillCurRow, info);	
				}
				else 		
				{				
					m_PetStatusIconTriggerSkill[idx].AddCol(TriggerSkillCurRow, info);	
				}
				TriggerSkillCnt++;
			}
			else
			{
				//~ debug("??? ?????????");
				if (BuffCnt%NSTATUSICON_MAXCOL == 0)
				{
					BuffCurRow++;
					if(isPC)	
					{						
						m_StatusIconBuff[idx].AddRow();
					}
					else
					{					
						m_PetStatusIconBuff[idx].AddRow();
					}
				}
				if(isPC)	
				{					
					m_StatusIconBuff[idx].AddCol(BuffCurRow, info);	
				}
				else		
				{				
					m_PetStatusIconBuff[idx].AddCol(BuffCurRow, info);	
				}
				BuffCnt++;
			}
		}
	}
	UpdateBuff();
}



//?????????????
function HandlePartySpelledListDelete(string param)
{
	local int i;		
	local int idx;
	local int ID;
	local int Max;		
	local StatusIconInfo info;		

	local bool isPC;
	
	ParseInt(param, "ID", ID);	

	if (ID<1) return;	
	idx = FindPartyID(ID);	
	if ( idx < 0 ) 
	{
		isPC = false;
		idx = FindPetID(ID);
	} 
	else isPC = true;

	if ( idx < 0 ) return;	
		
	ParseInt(param, "Max", Max);	

	for (i=0; i<Max; i++)
	{
		//???? ?????? ??? ???? ID, Level
		ParseItemIDWithIndex(param, info.ID, i );
		ParseInt(param, "Level_" $ i, info.Level );
		ParseInt(param, "SubLevel_" $ i, info.SubLevel );

		//ttp 60079
		ParseInt(param, "SpellerID_" $ i, info.SpellerID );

		//Debug( "HandlePartySpelledListDelete"  @ idx @ info.SpellerID @ info.Level @ info.ID.ClassID @  i ) ;
		
		if (IsValidItemID(info.ID))
		{	
			//???????? 
			if (GetDebuffType( info.ID, info.Level, info.SubLevel) != 0 )
			{
				if ( isPC ) deleteBuff ( m_StatusIconDeBuff[idx], info.Level, info.ID.ClassID, info.SpellerID ); 
				else 		deleteBuff ( m_PetStatusIconDeBuff[idx], info.Level, info.ID.ClassID, info.SpellerID ); 							
			}
			//?????
			else if (IsSongDance( info.ID, info.Level, info.SubLevel) == true )
			{	
				if ( isPC ) deleteBuff ( m_StatusIconSongDance[idx], info.Level, info.ID.ClassID, info.SpellerID );
				else        deleteBuff ( m_PetStatusIconSongDance[idx], info.Level, info.ID.ClassID, info.SpellerID );
			}
			//?????
			else if (IsTriggerSkill( info.ID, info.Level, info.SubLevel) == true )
			{								
				if ( isPC ) deleteBuff ( m_StatusIconTriggerSkill[idx], info.Level, info.ID.ClassID, info.SpellerID );
				else        deleteBuff ( m_PetStatusIconTriggerSkill[idx], info.Level, info.ID.ClassID, info.SpellerID ); 
			}
			//??? ???? 
			else
			{				
				if ( isPC ) deleteBuff ( m_StatusIconBuff[idx], info.Level, info.ID.ClassID, info.SpellerID ); 
				else        deleteBuff ( m_PetStatusIconBuff[idx], info.Level, info.ID.ClassID, info.SpellerID );
			}
			
			
		}
	}
	UpdateBuff();
}

//???? ?????? ?????? ??? ???? ??? ???
//ttp 60079 ?? SpellerID ???.
function deleteBuff( StatusIconHandle tmpStatusIcon , int level, int classID, int SpellerID )
{
	local int row;	
	local int col;
	local StatusIconInfo info;	

	for ( row = 0 ; row < tmpStatusIcon.GetRowCount(); row++ )
	{
		for ( col = 0 ; col < tmpStatusIcon.GetColCount(row) ; col++)
		{
			tmpStatusIcon.GetItem(row, col, info );			
			if ( info.ID.classID == classID && info.level ==  level && info.SpellerID == SpellerID )
			{
				tmpStatusIcon.DelItem( row, col );
				refreshPostion( tmpStatusIcon , row );
				return;
			}
		}
	}
}
//?????? ?? ?? ??? ??? ??? ?????? ?? ??? ???? ??? ???
function refreshPostion ( StatusIconHandle tmpStatusIcon , int deletedRow  )
{
	local int row;
	local StatusIconInfo info;	

	for ( row = deletedRow ; row < tmpStatusIcon.GetRowCount() -1 ; row ++ )
	{
		tmpStatusIcon.GetItem (row + 1 ,   0,  info );//???? ??? ??? ?? ?? ?? ???? ???? ???? ???? 
		tmpStatusIcon.addCol( row, info);// ?? ???????? ?????? ??? ??? ???? ????
		tmpStatusIcon.DelItem( row + 1, 0 ); // ?????.
	}
}

//????????????
function HandlePartySpelledListInsert(string param)
{
	local int i;	
	local int idx;
	local int ID;
	local int Max;

	local StatusIconInfo info;
	local StatusIconHandle tmpStatusIcon;

	local bool isPC;
		
	ParseInt(param, "ID", ID);	

	if (ID<1) return;	

	idx = FindPartyID(ID);	
	if ( idx < 0 ) 
	{
		isPC = false;
		idx = FindPetID(ID);
	} 
	else isPC = true;

	if ( idx < 0 ) return;
		
	//info ????
	if ( isPC ) 
	{
		info.Size = 16;
	}
	else 
	{
		info.Size = 10;
	}
	
	info.bShow = true;	

//	Debug( "HandlePartySpelledListInsert" @ String(isPC) @ idx);
	//Max=1 ID=1209091781 ClassID_0=77 Level_0=2 Sec_0=1200
	ParseInt(param, "Max", Max);

	for (i=0; i<Max; i++)
	{
		ParseItemIDWithIndex(param, info.ID, i);
		ParseInt(param, "Level_" $ i, info.Level);
		ParseInt(param, "SubLevel_" $ i, info.SubLevel);
		
		// ???? ?????? ??? add ???? ????.
		if ( class'UIDATA_SKILL'.static.IsToppingSkill( info.ID, info.Level, info.SubLevel) ) 
		{			
			continue ;
		}

		ParseInt(param, "Sec_" $ i, info.RemainTime);

		//ttp 60079
		ParseInt(param, "SpellerID_" $ i, info.SpellerID);
		//Debug( "HandlePartySpelledListInsert"  @ idx @ info.SpellerID @ info.Level @ info.ID.ClassID @  i ) ;

		if (IsValidItemID(info.ID))
		{
			info.IconName = class'UIDATA_SKILL'.static.GetIconName(info.ID, info.Level, info.SubLevel);
			info.bHideRemainTime = true;

			//???????? 
			if (GetDebuffType( info.ID, info.Level, info.SubLevel) != 0 )
			{
				if ( isPC ) tmpStatusIcon = m_StatusIconDeBuff[idx];
				else 		tmpStatusIcon = m_PetStatusIconDeBuff[idx];				
				
			}
			//?????
			else if (IsSongDance( info.ID, info.Level, info.SubLevel) == true )
			{	
				if ( isPC ) tmpStatusIcon = m_StatusIconSongDance[idx];	
				else        tmpStatusIcon = m_PetStatusIconSongDance[idx];
			}
			//?????
			else if (IsTriggerSkill( info.ID, info.Level, info.SubLevel) == true )
			{								
				if ( isPC ) tmpStatusIcon = m_StatusIconTriggerSkill[idx];
				else        tmpStatusIcon = m_PetStatusIconTriggerSkill[idx];
			}
			//??? ???? 
			else 
			{				
				if ( isPC ) tmpStatusIcon = m_StatusIconBuff[idx];
				else        tmpStatusIcon = m_PetStatusIconBuff[idx];
			} 	
			
			//???? ????
			deleteBuff ( tmpStatusIcon, info.Level, info.ID.ClassID, info.SpellerID ); 

			//??? ????			
			if ( tmpStatusIcon.GetRowCount() == 0 || tmpStatusIcon.GetColCount( tmpStatusIcon.GetRowCount() -1 ) % NSTATUSICON_MAXCOL == 0 )
			{				
				tmpStatusIcon.AddRow();
			}
			tmpStatusIcon.AddCol( tmpStatusIcon.GetRowCount() -1 , info);
		}
	}
	UpdateBuff();
}

//?????????? ???
function HandleShowBuffIcon(string param)
{
	local int nShow;
	ParseInt(param, "Show", nShow);
	
	m_CurBf = m_CurBf + 1;
	
	
	if (m_CurBf > MAX_BUFF_ICONTYPE)
	{
		m_CurBf = 0;
	}
	
	SetINIInt ( "PartyWndArena", "a", m_CurBf, "WindowsInfo.ini");	

	SetBuffButtonTooltip();
	UpdateBuff();
	//~ switch (m_CurBf)
	//~ {
		//~ case 1:
		//~ UpdateBuff();
		//~ break;
		//~ case 2:
		//~ UpdateBuff();
		//~ break;
		//~ case 0:
		//~ m_CurBf = 0;
		//~ UpdateBuff();
	//~ }
}

// ?????? ????
function OnClickButton( string strID )
{
	local int idx;
	local PartyWndCompact script;
	script = PartyWndCompact( GetScript("PartyWndCompact") );
	
	switch( strID )
	{
	case "btnBuff":		//??????? ????? 
		OnBuffButton();
		//script.OnBuffButton();
		break;
	case "btnCompact":	// ??? ??? ?????
		OnOpenPartyWndOption();
		//OnCompactButton();
		break;	
	case "btnSummon":	// ????? ??? ?????
		//debug("ERROR - you can't enter here");	// ????? ?????? ???? -_-;
		break;
	}

	if( inStr( strID , "btnSummon") > -1 )
	{
		idx = int( Right(strID , 1));
		// Debug("idx===> " @idx);
		if(m_PetPartyStatus[idx].isShowwindow())
		{
			// Debug(" ????? ??? ????! ");
			m_PetPartyStatus[idx].HideWindow();

			m_arrPetIDOpen[idx] = 2;
		}
		else
		{
			m_PetPartyStatus[idx].ShowWindow();
			m_arrPetIDOpen[idx] = 1;
		}
		ResizeWnd();
	}
}

// ????? ????? ????? ???
function OnOpenPartyWndOption()
{
	local int i;
	local PartyWndOption script;
	script = PartyWndOption( GetScript("PartyWndOption") );
	
	// ??????? ????? ? ?????? ??? ?????? , ???? ??????? ???????. 
	for(i=0; i<MAX_ArrayNum; i++)
	{
		script.m_arrPetIDOpen[i] = m_arrPetIDOpen[i];
	}
	
	script.ShowPartyWndOption();
	m_PartyOption.SetAnchor("PartyWndArena.PartyStatusWnd0", "TopRight", "TopLeft", 5, 5);
	
	
}

// ?????? ??? ???????.  PartyWnd, PartyWndCompact, PartyWndOption ???? ??????? ????

//		function OnCompactButton()
//		{
//			local int idx;
//			local int Size;
//			
//			if (m_bCompact)
//			{
//				Size = 16;
//			}
//			else
//			{
//				Size = 10;
//			}
//			m_bCompact = !m_bCompact;
//			
//			for (idx=0; idx<MAX_ArrayNum; idx++)
//			{
//				m_StatusIconBuff[idx].SetIconSize(Size);	
//				m_StatusIconDeBuff[idx].SetIconSize(Size);	
//			}
//		}

// ????????? ?????? ??? ?????? ???
function OnBuffButton()
{
	m_CurBf = m_CurBf + 1;
	
	//3???? ??? ??????.
	if (m_CurBf > MAX_BUFF_ICONTYPE)
	{
		m_CurBf = 0;
	}

	SetINIInt ( "PartyWndArena", "a", m_CurBf, "WindowsInfo.ini");	
	
	SetBuffButtonTooltip();
	UpdateBuff();
}

// ???????, ????? ???,  ???? 3??????? ??????.
function UpdateBuff()
{
	local int idx;
	if (m_CurBf == 1)
	{
		for (idx=0; idx<MAX_ArrayNum; idx++)
		{
			m_StatusIconBuff[idx].ShowWindow();	
			m_PetStatusIconBuff[idx].ShowWindow();
			m_StatusIconDeBuff[idx].HideWindow();	
			m_PetStatusIconDeBuff[idx].HideWindow();
			m_StatusIconSongDance[idx].HideWindow();	
			m_PetStatusIconSongDance[idx].HideWindow();
			m_StatusIconTriggerSkill[idx].HideWindow();	
			m_PetStatusIconTriggerSkill[idx].HideWindow();
		}
	}
	else if (m_CurBf == 2)
	{
		for (idx=0; idx<MAX_ArrayNum; idx++)
		{
			m_StatusIconBuff[idx].HideWindow();	
			m_PetStatusIconBuff[idx].HideWindow();
			m_StatusIconDeBuff[idx].ShowWindow();	
			m_PetStatusIconDeBuff[idx].ShowWindow();
			m_StatusIconSongDance[idx].HideWindow();	
			m_PetStatusIconSongDance[idx].HideWindow();
			m_StatusIconTriggerSkill[idx].HideWindow();	
			m_PetStatusIconTriggerSkill[idx].HideWindow();			
		}
	}
	else if (m_CurBf == 3)
	{
		for (idx=0; idx<MAX_ArrayNum; idx++)
		{
			m_StatusIconBuff[idx].HideWindow();	
			m_PetStatusIconBuff[idx].HideWindow();
			m_StatusIconDeBuff[idx].HideWindow();	
			m_PetStatusIconDeBuff[idx].HideWindow();
			m_StatusIconSongDance[idx].ShowWindow();	
			m_PetStatusIconSongDance[idx].ShowWindow();
			m_StatusIconTriggerSkill[idx].HideWindow();	
			m_PetStatusIconTriggerSkill[idx].HideWindow();			
		}
	}
	else if (m_CurBf == 4)
	{
		for (idx=0; idx<MAX_ArrayNum; idx++)
		{
			m_StatusIconBuff[idx].HideWindow();	
			m_PetStatusIconBuff[idx].HideWindow();
			m_StatusIconDeBuff[idx].HideWindow();	
			m_PetStatusIconDeBuff[idx].HideWindow();
			m_StatusIconSongDance[idx].HideWindow();	
			m_PetStatusIconSongDance[idx].HideWindow();
			m_StatusIconTriggerSkill[idx].ShowWindow();	
			m_PetStatusIconTriggerSkill[idx].ShowWindow();			
		}
	}
	else
	{
		for (idx=0; idx<MAX_ArrayNum; idx++)
		{
			m_StatusIconBuff[idx].HideWindow();
			m_PetStatusIconBuff[idx].HideWindow();
			m_StatusIconDeBuff[idx].HideWindow();	
			m_PetStatusIconDeBuff[idx].HideWindow();
			m_StatusIconSongDance[idx].HideWindow();	
			m_PetStatusIconSongDance[idx].HideWindow();
			m_StatusIconTriggerSkill[idx].HideWindow();	
			m_PetStatusIconTriggerSkill[idx].HideWindow();			
		}
	}
	//m_bBuff = bShow;
}

//CP?? ????
function UpdateCPBar(int idx, int Value, int MaxValue)
{
	m_BarCP[idx].SetValue(MaxValue, Value);
}

//HP?? ????
function UpdateHPBar(int idx, int Value, int MaxValue)
{
	if(idx < 100)
		m_BarHP[idx].SetValue(MaxValue, Value);
	else
		m_PetBarHP[idx - 100].SetValue(MaxValue, Value);
}

//MP?? ????
function UpdateMPBar(int idx, int Value, int MaxValue)
{
	if(idx < 100)
		m_BarMP[idx].SetValue(MaxValue, Value);
	else 	// 100???? ??? ???? ????????..
		m_PetBarMP[idx - 100].SetValue(MaxValue, Value);
}

//????? ??? ??????..
function OnLButtonDown( WindowHandle a_WindowHandle, int X, int Y )
{
	local Rect rectWnd, rectPetClassIcon;
	local UserInfo userinfo;
	local int idx;
	//??? ??? ????? ??? ???? ????????? ???.
	//local Rect rectAutoPart;		

	rectWnd = m_wndTop.GetRect();	

	if (X > rectWnd.nX + 13 && X < rectWnd.nX + rectWnd.nWidth -10)
	{
		if (GetPlayerInfo(userinfo))
		{
			//idx = (Y-rectWnd.nY) / NPARTYSTATUS_HEIGHT;	//???????? ???? ???? ???
			idx = GetIdx( Y-rectWnd.nY );
			//debug("OnLButtonDown : " $ idx);			
			//rectAutoPart = m_AutoPartyMatchingBtn[idx].GetRect();	
/*
			//??? ??? ????? ??? ??? ???? ????.
			if( X > rectAutoPart.nX && X < rectAutoPart.nX + rectAutoPart.nWidth )
			{
				if( Y > rectAutoPart.nY && Y <  ( rectAutoPart.nY + rectAutoPart.nHeight ) )
				{					
					return;
				}
			}*/

			rectWnd = m_PetPartyStatus[idx].GetRect();
			rectPetClassIcon = m_PetClassIcon[idx].GetRect();

			if (IsPKMode())
			{
				if(idx <100)
					RequestAttack(m_arrID[idx], userinfo.Loc);
				else
				{
					
										
					if (X > rectPetClassIcon.nX && X < rectWnd.nX + rectWnd.nWidth -10)
					{
						RequestAttack(m_arrPetID[idx-100], userinfo.Loc);
					}
				}
			}
			else
			{
				if(idx < 100)
					RequestAction(m_arrID[idx], userinfo.Loc);
				else
				{
					if (X > rectPetClassIcon.nX && X < rectWnd.nX + rectWnd.nWidth -10)
					{
						RequestAction(m_arrPetID[idx-100], userinfo.Loc);
					}
				}
			}
		}
	}
}

//??????? ?????
function OnRButtonDown( WindowHandle a_WindowHandle, int X, int Y )
{
	local Rect rectWnd;
	local UserInfo userinfo;
	local int idx;
		
	rectWnd = m_wndTop.GetRect();
	if (X > rectWnd.nX + 13 && X < rectWnd.nX + rectWnd.nWidth -10)
	{
		if (GetPlayerInfo(userinfo))
		{
			//idx = (Y-rectWnd.nY) / NPARTYSTATUS_HEIGHT;	//???????? ???? ???? ???
			idx = GetIdx( Y-rectWnd.nY );
			//debug("OnRButtonUp : " $ idx);
			if(idx <100)
				RequestAssist(m_arrID[idx], userinfo.Loc);
			else
				RequestAssist(m_arrPetID[idx-100], userinfo.Loc);
		}
	}
}

// Y ????? ????? ????? ?????? ???? ?????. ???? ?????? + 100?? ??? ?????????. 
function int GetIdx(int y)
{
	local int tempY;	// ??????? ????? ?????????? ??? ???????? ???? ????????. 
	local int i;
	local int idx;
	
	idx = -1;
	tempY = y;
	
	for(i=0 ; i<MAX_ArrayNum ; i++)
	{
		tempY = tempY - NPARTYSTATUS_HEIGHT;
		
		if(tempY <0)	// 0???? ?????? ??? i?? IDX?? ???. 
		{
			idx = i;	//?????? ??????, ??????? ????????..
			return idx;
		}
		else if( m_arrPetIDOpen[i] == 1) // ??? ???????? ???? ????????
		{
			tempY = tempY - NPARTYPETSTATUS_HEIGHT;			
			if(tempY <0)	// 0???? ?????? ??? i?? IDX?? ???. 
			{
				idx = i + 100;	//???? ??? 100?? ????? ???????. 
				return idx;
			}
		}		
	}
	
	return idx;
}

// ???? ?????? ???????.
function SetBuffButtonTooltip()
{
	local int idx;
	switch (m_CurBf)
	{
		case 0:	idx = 1496;
		break;
		case 1:	idx = 1497;
		break;
		case 2:	idx = 1741;
		break;
		case 3:	idx = 2307;
		break;
		case 4: idx = 1498;
		break;
	}
	btnBuff.SetTooltipCustomType(MakeTooltipSimpleText(GetSystemString(idx)));
}

function OnDropWnd( WindowHandle hTarget, WindowHandle hDropWnd, int x, int y )
{
	local string sTargetName, sDropName ,sTargetParent;
	local int dropIdx, targetIdx, i;
	
	//local  PartyWnd script1;			// ???? ?????? ?????
	local PartyWndCompact script2;	// ???? ?????? ?????
	
	//script1 = PartyWnd( GetScript("PartyWndArena") );
	script2 = PartyWndCompact( GetScript("PartyWndCompact") );
	
	dropIdx = -1;
	targetIdx = -1;
	
	if( hTarget == None || hDropWnd == None )
		return;
	
	sTargetName = hTarget.GetWindowName();
	sDropName = hDropWnd.GetWindowName();
	sTargetParent = hTarget.GetParentWindowName();
	
	// PartyStatusWnd???? ????? ?? ????? ?? ?? ???. 
	//if(( InStr( "PartyStatusWnd", sTargetName ) == -1 ) || ( InStr( "PartyStatusWnd" ,sDropName) == -1 ))
	if( (( InStr( sTargetName , "PartyStatusWnd" ) == -1 ) && ( InStr( sTargetParent , "PartyStatusWnd" ) == -1 )   ) || ( InStr( sDropName, "PartyStatusWnd") == -1 ))
	{
		//Debug( "sTargetName: " $ sTargetName );
		//Debug( "sTargetName: " $ sDropName );
		return;
	}
	else
	{
		dropIdx = int(Right(sDropName , 1));
		
		if( InStr( sTargetName , "PartyStatusWnd" ) > -1 ) 	//??? ?????? ???? ???
			targetIdx = int(Right(sTargetName , 1));
		else									//??? ?????? ?????? ?????? ????? PartyStatusWnd ???
			targetIdx = int(Right(sTargetParent , 1));
		
		if( dropIdx <0 || targetIdx <0 )
		{
			//Debug( "ERROR IDX: " $ dropIdx $ " / " $  targetIdx);
		}
		
		// ??? ??? ???? ??????? ???
		if( dropIdx > targetIdx)
		{
			CopyStatus ( MAX_PartyMemberCount , dropIdx );		//????? ??????
			script2.CopyStatus ( MAX_PartyMemberCount , dropIdx );		//????? ??????
			
			for (i=dropIdx-1; i>targetIdx-1; i--)	// ????? ???????. 
			{
				CopyStatus(i+1, i);
				script2.CopyStatus(i+1, i);
			}
			CopyStatus ( targetIdx , MAX_PartyMemberCount  );
			script2.CopyStatus ( targetIdx , MAX_PartyMemberCount  );
		}
		else if(dropIdx < targetIdx)
		{
			CopyStatus ( MAX_PartyMemberCount, dropIdx );		//????? ??????
			script2.CopyStatus ( MAX_PartyMemberCount , dropIdx );		//????? ??????
			
			for (i=dropIdx+1; i<targetIdx+1; i++)	// ???? ???????.
			{
				CopyStatus(i-1, i);
				script2.CopyStatus(i-1, i);
			}
			CopyStatus ( targetIdx , MAX_PartyMemberCount );
			script2.CopyStatus ( targetIdx , MAX_PartyMemberCount );
		}

		ClearStatus(MAX_PartyMemberCount);
		ClearPetStatus(MAX_PartyMemberCount);
		
		//Update Client Data
		class'UIDATA_PARTY'.static.MovePartyMember( dropIdx, targetIdx );
		
		ResizeWnd();
	}
}

function int GetVNameIndexByID( int ID )
{
	local int i;
	for (i=0; i<MAX_ArrayNum; i++)
	{
		if( m_Vname[i].ID == ID )
			return i;
	}
	return -1;
}

function ResetVName()
{
	local int i;
	
	for (i=0; i<MAX_ArrayNum; i++)
	{
		m_Vname[i].ID = i;
		m_Vname[i].UseVName = 0;
		m_Vname[i].DominionIDForVName = 0;
		m_Vname[i].VName = "";
		m_Vname[i].SummonVName = "";
	}
}


function HandleRegistPartySubstitute( string param )
{
	local int iOK;
	local int iUserID;

	ParseInt( param, "OK", iOK );
	ParseInt( param, "UserID", iUserID );

	//debug( "HandleRegistPartySubstitute OK>>>" $string(iOK) );
	//debug( "HandleRegistPartySubstitute UserID>>>" $string(iUserID) );
}

function HandleDeletePartySubstitute( string param )
{
	local int iOK;
	local int iUserID;

	ParseInt( param, "OK", iOK );
	ParseInt( param, "UserID", iUserID );

	//debug( "HandleDeletePartySubstitute OK>>>" $string(iOK) );
	//debug( "HandleDeletePartySubstitute UserID>>>" $string(iUserID) );
}
defaultproperties
{
}
