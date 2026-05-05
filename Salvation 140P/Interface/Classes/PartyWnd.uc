/******************************************************************************
//                                             ???? ???? UI ???? ??????                                                                    //
******************************************************************************/
class PartyWnd extends UICommonAPI;	

//???????.  
const NSTATUSICON_MAXCOL = 12;	    // status icon?? ??? ????.
const NPARTYSTATUS_HEIGHT = 46;	    // status ??????? ????????.
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
var int iconsOffsetX ;

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
	//RegisterEvent( EV_TargetUpdate );	// ??? ??????? ????	

	// ?????? ??? ??? ????????
	RegisterEvent( EV_RegistPartySubstitute );
	// ?????? ??? ??? ??? ????????
	RegisterEvent( EV_DeletePartySubstitute );


	RegisterEvent( EV_PartySpelledListDelete ); //1182
	RegisterEvent( EV_PartySpelledListInsert ); //1183
	RegisterEvent( EV_PetStatusSpelledListDelete ); //1052	
	RegisterEvent( EV_PetStatusSpelledListInsert ); //1053

	RegisterEvent( EV_NeedResetUIData);
}



function checkClassicForm() 
{
	local int idx;		

	if ( getInstanceUIData().getisClassicServer()  )
	{
		iconsOffsetX = ONCLASSICFORM_OFFSET_X;		
	}
	else 
	{		
		iconsOffsetX = 0;
	}

	for (idx=0; idx<MAX_ArrayNum; idx++)
	{	
		if ( getInstanceUIData().getisClassicServer() ) 
		{
			m_VPIcon[idx].hideWindow();
			m_ClassIconSummonNum[idx].HideWindow();
		}
		else 
		{
			m_VPIcon[idx].showWindow();
			m_ClassIconSummonNum[idx].ShowWindow();
		}

		m_LeaderIcon[idx].SetAnchor( "PartyWnd.PartyStatusWnd"$idx , "TopLeft", "TopLeft", 30 - iconsOffsetX, 8 );			
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
		m_StatusIconBuff[idx].SetAnchor("PartyWnd.PartyStatusWnd" $ idx, "TopRight", "TopLeft", 0, 5);
		m_StatusIconDeBuff[idx].SetAnchor("PartyWnd.PartyStatusWnd" $ idx, "TopRight", "TopLeft", 0, 5);
		m_StatusIconSongDance[idx].SetAnchor("PartyWnd.PartyStatusWnd" $ idx, "TopRight", "TopLeft", 0, 5);
		m_StatusIconTriggerSkill[idx].SetAnchor("PartyWnd.PartyStatusWnd" $ idx, "TopRight", "TopLeft", 0, 5);

		
		m_PetStatusIconBuff[idx].SetAnchor("PartyWnd.PartyStatusSummonWnd" $ idx, "TopRight", "TopLeft", 1, 1);
		m_PetStatusIconDeBuff[idx].SetAnchor("PartyWnd.PartyStatusSummonWnd" $ idx, "TopRight", "TopLeft", 1, 1);
		m_PetStatusIconSongDance[idx].SetAnchor("PartyWnd.PartyStatusSummonWnd" $ idx, "TopRight", "TopLeft", 1, 1);
		m_PetStatusIconTriggerSkill[idx].SetAnchor("PartyWnd.PartyStatusSummonWnd" $ idx, "TopRight", "TopLeft", 1, 1);

	}
	m_PartyOption.HideWindow();
	
	//Init VirtualDrag
	for (idx=0; idx<MAX_ArrayNum; idx++)
	{
		//m_PartyStatus[idx].SetVirtualDrag( true );
		m_PartyStatus[idx].SetDragOverTexture( "L2UI_CT1.ListCtrl.ListCtrl_DF_HighLight" );
	}
	
	ResetVName();
	ResetAutoParty();
	
	//Debug("??? ????..");
}
/*
function InitHandle()
{
	local int idx;	// ?????? ????? int.

	//Init Handle
	m_wndTop = GetHandle( "PartyWnd" );
	m_PartyOption = GetHandle("PartyWndOption");	// ?????? ??? ????.
	for (idx=0; idx<MAX_ArrayNum; idx++)	// ???????? ?? ??? ?? ??????? ????????.
	{
		m_PartyStatus[idx] = GetHandle( "PartyWnd.PartyStatusWnd" $ idx );
		m_PlayerName[idx] = NameCtrlHandle( GetHandle( "PartyWnd.PartyStatusWnd" $ idx $ ".PlayerName" ) ); 
		m_ClassIcon[idx] = TextureHandle( GetHandle( "PartyWnd.PartyStatusWnd" $ idx $ ".ClassIcon" ) );
		m_LeaderIcon[idx] = TextureHandle( GetHandle( "PartyWnd.PartyStatusWnd" $ idx $ ".LeaderIcon" ) );
		
		m_StatusIconBuff[idx] = StatusIconHandle( GetHandle( "PartyWnd.PartyStatusWnd" $ idx $ ".StatusIconBuff" ) );
		m_StatusIconDeBuff[idx] = StatusIconHandle( GetHandle( "PartyWnd.PartyStatusWnd" $ idx $ ".StatusIconDeBuff" ) );
		m_StatusIconSongDance[idx] = StatusIconHandle( GetHandle( "PartyWnd.PartyStatusWnd" $ idx $ ".StatusIconSongDance" ) );
		m_StatusIconTriggerSkill[idx] = StatusIconHandle( GetHandle( "PartyWnd.PartyStatusWnd" $ idx $ ".StatusIconTriggerSkill" ) );

		m_BarCP[idx] = BarHandle( GetHandle( "PartyWnd.PartyStatusWnd" $ idx $ ".barCP" ) );
		m_BarHP[idx] = BarHandle( GetHandle( "PartyWnd.PartyStatusWnd" $ idx $ ".barHP" ) );
		m_BarMP[idx] = BarHandle( GetHandle( "PartyWnd.PartyStatusWnd" $ idx $ ".barMP" ) );
		//if(idx != 0) // ????? ??? ????? ?????? ??? ??? ????? ???????? ?????? ????. 
		//{
		//	m_petButtonTrash[idx] = ButtonHandle( GetHandle( "PartyWnd.PartyStatusWnd" $ idx $ ".btnSummon0") );	
		//	m_petButtonTrash[idx].HideWindow();
		//}
		m_petButton[idx] = ButtonHandle( GetHandle( "PartyWnd.btnSummon" $ idx) );	// ?????? ???? ???		
		m_petButton[idx].HideWindow();
		
		m_PetPartyStatus[idx] = GetHandle( "PartyWnd.PartyStatusSummonWnd" $ idx );
		//m_PetName[idx] = NameCtrlHandle( GetHandle( 
"PartyWnd.PartyStatusSummonWnd" $ idx $ ".SummonName" ) ); 
		m_PetClassIcon[idx] = TextureHandle( GetHandle( "PartyWnd.PartyStatusSummonWnd" $ idx $ ".ClassIcon" ) );
		
		m_PetStatusIconBuff[idx] = StatusIconHandle( GetHandle( "PartyWnd.PartyStatusSummonWnd" $ idx $ ".StatusIconBuff" ) );
		m_PetStatusIconDeBuff[idx] = StatusIconHandle( GetHandle( "PartyWnd.PartyStatusSummonWnd" $ idx $ ".StatusIconDebuff" ) );
		m_PetStatusIconSongDance[idx] = StatusIconHandle( GetHandle( "PartyWnd.PartyStatusSummonWnd" $ idx $ ".StatusIconSongDance" ) );
		m_PetStatusIconTriggerSkill[idx] = StatusIconHandle( GetHandle( "PartyWnd.PartyStatusSummonWnd" $ idx $ ".StatusIconTriggerSkill" ) );

		m_PetBarHP[idx] = BarHandle( GetHandle( "PartyWnd.PartyStatusSummonWnd" $ idx $ ".barHP" ) );
		m_PetBarMP[idx] = BarHandle( GetHandle( "PartyWnd.PartyStatusSummonWnd" $ idx $ ".barMP" ) );		
				
		m_arrPetIDOpen[idx] = -1;
		m_arrID[idx] = 0;
		
		if(idx == 0) //????? ??? ???????? ?????. 
		{
			m_petButton[idx].SetAnchor("PartyWnd.PartyStatusWnd" $ idx, "TopLeft", "TopRight", 0, 32);
		}
		else
			m_petButton[idx].SetAnchor("PartyWnd.PartyStatusWnd" $ idx, "TopLeft", "TopRight", 0, 2);
		
	}
	btnBuff = ButtonHandle( GetHandle( "PartyWnd.btnBuff" ) );
}
*/
function InitHandleCOD()
{
	local int idx;	// ?????? ????? int.

	//Init Handle
	m_wndTop = GetWindowHandle( "PartyWnd" );
	m_PartyOption = GetWindowHandle("PartyWndOption");	// ?????? ??? ????.

	for (idx=0; idx<MAX_ArrayNum; idx++)	// ???????? ?? ??? ?? ??????? ????????. ->  ??? ?????? ?? ????? ???? ????.
	{
		m_PartyStatus[idx] = GetWindowHandle  ( "PartyWnd.PartyStatusWnd" $ idx );
		m_PlayerName[idx]  = GetNameCtrlHandle( "PartyWnd.PartyStatusWnd" $ idx $ ".PlayerName" ); 
		m_ClassIcon[idx]   = GetTextureHandle ( "PartyWnd.PartyStatusWnd" $ idx $ ".ClassIcon" );
		m_LeaderIcon[idx]  = GetTextureHandle ( "PartyWnd.PartyStatusWnd" $ idx $ ".LeaderIcon" );
		m_VPIcon[idx]      = GetTextureHandle ( "PartyWnd.PartyStatusWnd" $ idx $ ".PartyVPIcon" );
		
		m_StatusIconBuff[idx]          = GetStatusIconHandle( "PartyWnd.PartyStatusWnd" $ idx $ ".StatusIconBuff" );
		m_StatusIconDeBuff[idx]        = GetStatusIconHandle( "PartyWnd.PartyStatusWnd" $ idx $ ".StatusIconDeBuff" );
		m_StatusIconSongDance[idx]     = GetStatusIconHandle( "PartyWnd.PartyStatusWnd" $ idx $ ".StatusIconSongDance" );
		m_StatusIconTriggerSkill[idx]  = GetStatusIconHandle( "PartyWnd.PartyStatusWnd" $ idx $ ".StatusIconTriggerSkill" );

		m_BarCP[idx] = GetBarHandle( "PartyWnd.PartyStatusWnd" $ idx $ ".barCP" );
		m_BarHP[idx] = GetBarHandle( "PartyWnd.PartyStatusWnd" $ idx $ ".barHP" );
		m_BarMP[idx] = GetBarHandle( "PartyWnd.PartyStatusWnd" $ idx $ ".barMP" );

		m_petButton[idx] = GetButtonHandle( "PartyWnd.btnSummon" $ idx);	// ?????? ???? ???		
		m_petButton[idx].HideWindow();
		
		m_PetPartyStatus[idx] = GetWindowHandle( "PartyWnd.PartyStatusSummonWnd" $ idx );

		
		m_PetStatusIconBuff[idx] = GetStatusIconHandle( "PartyWnd.PartyStatusSummonWnd" $ idx $ ".StatusIconBuff" );
		m_PetStatusIconDeBuff[idx] = GetStatusIconHandle( "PartyWnd.PartyStatusSummonWnd" $ idx $ ".StatusIconDebuff" );
		m_PetStatusIconSongDance[idx] = GetStatusIconHandle( "PartyWnd.PartyStatusSummonWnd" $ idx $ ".StatusIconSongDance" );
		m_PetStatusIconTriggerSkill[idx] = GetStatusIconHandle( "PartyWnd.PartyStatusSummonWnd" $ idx $ ".StatusIconTriggerSkill" );

		m_PetBarHP[idx] = GetBarHandle( "PartyWnd.PartyStatusSummonWnd" $ idx $ ".barHP" );
		m_PetBarMP[idx] = GetBarHandle( "PartyWnd.PartyStatusSummonWnd" $ idx $ ".barMP" );		
		

		// m_PetClassIcon[idx] = GetTextureHandle( "PartyWnd.PartyStatusSummonWnd" $ idx $ ".ClassIcon" );

		// ct ?? ????? ?? ????? ??????
		m_PetClassIcon[idx] = GetTextureHandle( "PartyWnd.PartyStatusSummonWnd" $ idx $ ".ClassIconPet" );


		// ct3 ?? ????? ??, ????? ????? (????? ??????, ????? ??, ?? ??????)
		m_ClassIconSummon[idx]    =  GetTextureHandle( "PartyWnd.PartyStatusSummonWnd" $ idx $ ".ClassIconSummon" );
		
		m_ClassIconSummonNum[idx] =  GetTextureHandle( "PartyWnd.PartyStatusSummonWnd" $ idx $ ".ClassIconSummonNum" );
		
		m_arrPetIDOpen[idx] = -1;
		m_arrSummonID[idx] = -1;
		m_arrID[idx] = 0;

		//m_AutoPartyMatchingIcon[idx]    = GetTextureHandle( "PartyWnd.PartyStatusWnd" $ idx $ ".AutoPartyMatchingIcon" );
		//m_AutoPartyMatchingBtn[idx]     = GetButtonHandle( "PartyWnd.PartyStatusWnd" $ idx $ ".AutoPartyMatchingBtn" );
		
		if(idx == 0) //????? ??? ???????? ?????. 
		{
			m_petButton[idx].SetAnchor("PartyWnd.PartyStatusWnd" $ idx, "TopLeft", "TopRight", 0, 32);
		}
		else
			m_petButton[idx].SetAnchor("PartyWnd.PartyStatusWnd" $ idx, "TopLeft", "TopRight", 0, 2);
		
	}
	btnBuff = GetButtonHandle( "PartyWnd.btnBuff" );
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

	GetINIInt ( "PartyWnd", "a", m_CurBf, "WindowsInfo.ini");
	SetBuffButtonTooltip();
	UpdateBuff();
	GetIniInt( "PartyWnd", "p", tmpInt, "WindowsInfo.ini");	

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
	

	Debug ( "onShow partyWnd");
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
	/*
	else if (Event_ID == EV_TargetUpdate)
	{
		HandleCheckTarget();
	}*/
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
	//~ local int idx;
	
	//~ idx = -1;
	
	//~ m_TargetID = class'UIDATA_TARGET'.static.GetTargetID();
	//~ if(m_TargetID > 0)	{	idx = FindPartyID(m_TargetID);	}
	
	//~ if(idx == -1) 
	//~ {
		//~ if( m_LastChangeColor != -1) // ?????? ???? ?????? ?????? ??? ???? ????
		//~ {	
			//~ debug("qkRudigka");
			//~ m_PartyStatus[m_LastChangeColor].SetBackTexture("L2UI_CT1.Windows.Windows_DF_Small_Vertical_SizeControl_Bg_Darker");
			//~ m_TargetID	 = -1;
			//~ m_LastChangeColor = -1;			
		//~ }
	//~ }
	//~ else
	//~ {
		//~ m_LastChangeColor = idx;
		//~ m_PartyStatus[idx].SetBackTexture("L2UI_CT1.ListCtrl.ListCtrl_DF_HighLight");
	//~ }
}

//???????? ??? ???????
function HandleRestart()
{
	Clear();
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
	m_CurCount = 0;
	m_TargetID	 = -1;
	m_LastChangeColor = -1;
	ResizeWnd();

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
	//ServerID
	m_arrID[DesIndex] = m_arrID[SrcIndex];
	
	//Name
	m_PlayerName[DesIndex].SetName(m_PlayerName[SrcIndex].GetName(), NCT_Normal,TA_Left);
	
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
		//m_LeaderIcon[DesIndex].SetAnchor("PartyWnd.PartyStatusWnd" $ DesIndex, "TopCenter", "TopLeft", -(Width/2)-18, 8);		
		//SetTypePosition
		m_LeaderIcon[DesIndex].ShowWindow();
	}
	//???? ??? ????
	m_LeaderIcon[SrcIndex].GetTooltipCustomType(TooltipInfo2);
	m_LeaderIcon[DesIndex].SetTooltipCustomType(TooltipInfo2);
	
	//CP,HP,MP
	m_BarCP[SrcIndex].GetValue(MaxValue, CurValue);
	m_BarCP[DesIndex].SetValue(MaxValue, CurValue);
	m_BarHP[SrcIndex].GetValue(MaxValue, CurValue);
	m_BarHP[DesIndex].SetValue(MaxValue, CurValue);
	m_BarMP[SrcIndex].GetValue(MaxValue, CurValue);
	m_BarMP[DesIndex].SetValue(MaxValue, CurValue);

	// vp ??? 
	vpIconTextureName = m_VPIcon[DesIndex].GetTextureName();
	vpToolTipString = m_VPIcon[DesIndex].GetTooltipText();

	m_VPIcon[DesIndex].SetTexture(m_VPIcon[SrcIndex].GetTextureName());
	m_VPIcon[DesIndex].SetTooltipText(m_VPIcon[SrcIndex].GetTooltipText());

	m_VPIcon[SrcIndex].SetTexture(vpIconTextureName);
	m_VPIcon[SrcIndex].SetTooltipText(vpToolTipString);


	//??? ??? ??? ???.
	if( AmILeader() )
	{	/*	
		if( autoPartyIndex[DesIndex] == 0 )
		{
			//???? ???? ????
			//m_AutoPartyMatchingBtn[SrcIndex].SetTexture( "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_Off", "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_On", "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_Off" );		
		}
		else
		{
			//?????? ????????
			//m_AutoPartyMatchingBtn[SrcIndex].SetTexture( "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_On", "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_On", "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_On" );					
		}
			
		if( autoPartyIndex[SrcIndex] == 0 )
		{
			//???? ???? ????
			//m_AutoPartyMatchingBtn[DesIndex].SetTexture( "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_Off", "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_On", "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_Off" );
		}
		else
		{
			//?????? ????????
			//m_AutoPartyMatchingBtn[DesIndex].SetTexture( "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_On", "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_On", "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_On" );					
		}*/
		SetTypePositionLeader( DesIndex );
		SetTypePositionLeader( SrcIndex );
	}
	else
	{
		SetTypePosition( DesIndex, 0 );
		
		/*
		if( autoPartyIndex[DesIndex] == 0 )
		{
			//???? ???? ????
			//m_AutoPartyMatchingIcon[SrcIndex].HideWindow();
			SetTypePosition( SrcIndex, 0 );
		}
		else
		{
			//?????? ????????
			//m_AutoPartyMatchingIcon[SrcIndex].ShowWindow();
			//m_AutoPartyMatchingIcon[SrcIndex].SetTexture( "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_On" );
			SetTypePosition( SrcIndex, 1 );
		}
			
		if( autoPartyIndex[SrcIndex] == 0 )
		{
			//???? ???? ????
			//m_AutoPartyMatchingIcon[DesIndex].HideWindow();
			SetTypePosition( DesIndex, 0 );
		}
		else
		{
			//?????? ????????
			//m_AutoPartyMatchingIcon[DesIndex].ShowWindow();
			//m_AutoPartyMatchingIcon[DesIndex].SetTexture( "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_On" );
			SetTypePosition( DesIndex, 1 );
		}*/
	}
/*
	intTmp = autoPartyIndex[SrcIndex];
	autoPartyIndex[SrcIndex] = autoPartyIndex[DesIndex];
	autoPartyIndex[DesIndex] = intTmp;
*/

	/*
	if( AmILeader() )
	{		
		//??????? ??? ???.
		//?????? ???? ????
		if( iSubstatus == 0 )
		{
			m_AutoPartyMatchingBtn[idx].SetTexture( "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_Off", "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_On", "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_Off" );
		}
		//?????? ????????
		else
		{
			m_AutoPartyMatchingBtn[idx].SetTexture( "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_On", "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_On", "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_On" );					
		}
		m_AutoPartyMatchingBtn[idx].ShowWindow();
		m_AutoPartyMatchingIcon[idx].HideWindow();

		SetTypePositionLeader( idx );
		//??? ??? ??? ??????
		//???? ??? ??? ???????.. ??????? ?????? ?????..;;
		FindAllUserParty();		
	}
	else
	{					
		//????? ??? ???.		
		//?????? ???? ????
		if( iSubstatus == 0 )
		{
			m_AutoPartyMatchingIcon[idx].HideWindow();
			SetTypePosition( idx, 0 );
			//m_AutoPartyMatchingIcon[idx].SetTexture( "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_Off" );
		}
		//?????? ????????
		else
		{
			m_AutoPartyMatchingIcon[idx].ShowWindow();
			m_AutoPartyMatchingIcon[idx].SetTexture( "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_On" );
			SetTypePosition( idx, 1 );
		}
		m_AutoPartyMatchingBtn[idx].HideWindow();
		//m_AutoPartyMatchingIcon[idx].ShowWindow();
	}*/


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
	GetINIInt( "PartyWnd", "e", tmpInt, "Windowsinfo.ini"  ) ;
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
						m_PartyStatus[idx].SetAnchor("PartyWnd.PartyStatusSummonWnd" $ idx-1, "BottomLeft", "TopLeft", 0, -4);	// ?? ?????? ?????? ????
					}
					else// ?? ??????? ??????? ???????? ??????? ??????
					{
						m_PartyStatus[idx].SetAnchor("PartyWnd.PartyStatusWnd" $ idx-1, "BottomLeft", "TopLeft", 0, -4);	// ????? ?????? ????
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
						m_ClassIconSummonNum[idx].SetTexture("L2UI_ch3.PARTYWND.party_summmon_num" $ String(partyMemberInfo.curSummonNum));
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
	GetINIInt( "PartyWnd", "e", tmpInt, "Windowsinfo.ini"  ) ;
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
						m_PartyStatus[idx].SetAnchor("PartyWnd.PartyStatusSummonWnd" $ idx-1, "BottomLeft", "TopLeft", 0, -4);	// ?? ?????? ?????? ????
					}
					else// ?? ??????? ??????? ???????? ??????? ??????
					{
						m_PartyStatus[idx].SetAnchor("PartyWnd.PartyStatusWnd" $ idx-1, "BottomLeft", "TopLeft", 0, -4);	// ????? ?????? ????
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
						m_ClassIconSummonNum[idx].SetTexture("L2UI_ch3.PARTYWND.party_summmon_num" $ String(partyMemberInfo.curSummonNum));
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
		if (!bOption)	// ?????? ???? ??????? ?????? ???? (????) ??????? ????
			m_wndTop.ShowWindow();
		else
			m_wndTop.HideWindow();
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
		m_Vname[m_CurCount].ID = ID;
		m_Vname[m_CurCount].UseVName = UseVName;
		m_Vname[m_CurCount].DominionIDForVName = DominionIDForVName;
		m_Vname[m_CurCount].VName = VName;
		m_Vname[m_CurCount].SummonVName = SummonVName;
		ExecuteEvent( EV_TargetUpdate);
	
		m_CurCount++;	
		
		m_arrID[m_CurCount-1] = ID;
		UpdateStatus(m_CurCount-1, param);

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
					m_ClassIconSummon[m_CurCount - 1].SetTooltipText(GetSystemString(505));//getSummonSortString(class'UIDATA_NPC'.static.GetSummonSort(summonClassID)));
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
		if (idx>-1)
		{	
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
	local int		MasterID;
	local int		RoutingType;
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
	
	local int		Width;
	local int		Height;
	
	
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
	ParseInt(param, "MasterID", PartyLeaderID);
	

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
	{
		DisplayName = VName;
	}
	else
	{
		DisplayName = Name;
	}

	// Show premium marker and level in party row.
	if (IsBRPremium > 0)
	{
		DisplayName = "[PA] " $ DisplayName;
	}
	DisplayName = DisplayName $ " Lv." $ string(Level);
	m_PlayerName[idx].SetName(DisplayName, NCT_Normal,TA_Left);
	
	//???? ??????
	if (ParseInt(param, "MasterID", MasterID))
	{
		if (MasterID>0 && MasterID==ID)
		{	
			partymasteridx = idx;
			ParseInt(param, "RoutingType", RoutingType);
			m_LeaderIcon[idx].SetTexture("L2UI_CH3.PartyWnd.party_leadericon");
			m_LeaderIcon[idx].SetTooltipCustomType(MakeTooltipSimpleText(GetRoutingString(RoutingType)));
			
			//???????? ????? ???? ??????????.
			GetTextSizeDefault(Name, Width, Height);
			//m_LeaderIcon[idx].SetAnchor("PartyWnd.PartyStatusWnd" $ idx, "TopCenter", "TopLeft", -(Width/2)-18, 8);
			//SetTypePosition( idx, 1 );
		}
		else
		{
			m_LeaderIcon[idx].SetTexture("");
			m_LeaderIcon[idx].SetTooltipCustomType(MakeTooltipSimpleText(""));
			//SetTypePosition( idx, 0 );
		}
	}
	
	if (IsBRPremium > 0)
		premiumText = "Premium: ON";
	else
		premiumText = "Premium: OFF";

	//???? ??????
	m_ClassIcon[idx].SetTexture(GetClassRoleIconName(ClassID));
	m_ClassIcon[idx].SetTooltipCustomType(MakeTooltipSimpleText(GetClassRoleName(ClassID) $ " - " $ GetClassType(ClassID) $ " / Lv." $ string(Level) $ " / " $ premiumText));
	
	//???? ??????
	UpdateCPBar(idx, CP, MaxCP);
	UpdateHPBar(idx, HP, MaxHP);
	UpdateMPBar(idx, MP, MaxMP);

	//????? ????? ???? Vitality?? ????, ????? update????? ????.???
	UpdateVpIcon(idx, Vitality, GetMaxVitality());
	SetPartyAutoStatus( idx, iSubstatus );
}


/** 
 *    ????? ??? ???????
 *    idx : ????
 *    vp : ??? ??
 *    MaxVP : ??? ??? ??
 **/ 
function UpdateVpIcon(int idx, int vp, int MaxVP)
{	
	/*
	local int time, vpStep;
	local int per;
	local string vpString;

	// ??? vp (72000 == 20????, 3600?? == 1????,  5? ??????)
	per = MaxVP / 3600 / 5;

	time = vpSec / 3600;
	vpStep = (time / per);
	
	//  ???? ??? 
	if (vpStep >= 5) vpStep = 4;
	else if (vpStep == 0 && vpSec > 0) vpStep = 1;
	else if (vpSec <= 0) vpStep = 0;
	else 
	{
		vpStep = vpStep + 1;
	}
	
	// ??? ??? 0 ~ 4 ????? ????
	m_VPIcon[idx].SetTexture("L2UI_Ct1.PartyStatusWnd_DF_VPIcon_" $ vpStep);	

	vpString = util.getTimeStringBySec(vpSec, true);

	// 0???? ????? ???? ??????? ??? ?????.. 
	// if     "????? ?? ????????????" ??? ??????? ???????? ???.
	// else   "$1 ????" ("1???? ????" ???? ???)
	if (MakeFullSystemMsg(GetSystemMessage(3407 ), "0") == vpString) vpString = GetSystemMessage(2317);
	else vpString = MakeFullSystemMsg(GetSystemMessage(3360 ), vpString);
	// ???? ???? 
	m_VPIcon[idx].SetTooltipCustomType(MakeTooltipSimpleText( vpString ));
	*/
	local int vpStep;
	local int division;
	local string vpString;

	division = MaxVP / 4;

	//105000 ????? ??? ~ 140000 ????? : ?? ? ???
	if( vp > MaxVP - division )
	{
		vpStep = 4;
	}
	//70000 ????? ??? ~ 105000 ????? ???? : ?? ? ???
	else if( vp <= MaxVP - division && vp > MaxVP - ( division * 2 ) )
	{
		vpStep = 3;
	}
	//35000 ????? ??? ~ 70000 ????? ???? : ?? ? ???
	else if( vp <= MaxVP - (division * 2) && vp > MaxVP - ( division * 3 ) )
	{
		vpStep = 2;
	}
	//0????? ??? ~ 35000 ????? ???? : ?? ? ???
	else if( vp <= MaxVP - (division * 3) && vp > MaxVP - ( division * 4 ) )
	{
		vpStep = 1;
	}
	//0 ?? ??? 0?
	else
	{
		vpStep = 0;
	}

	m_VPIcon[idx].SetTexture("L2UI_Ct1.PartyStatusWnd_DF_VPIcon_" $ vpStep);

	//??? 0?? ???
	if (vp <= 0)
	{
		vpString = GetSystemString(2496);		
	} else 
	{		
		vpString = GetSystemString(2495);
	}

	m_VPIcon[idx].SetTooltipCustomType(MakeTooltipSimpleText( vpString ));
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
			m_ClassIconSummonNum[idx].SetTexture("L2UI_ch3.PARTYWND.party_summmon_num" $ String(partyMemberInfo.curSummonNum));
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
	
	SetINIInt ( "PartyWnd", "a", m_CurBf, "WindowsInfo.ini");	

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

function OnClickButtonWithHandle( ButtonHandle a_ButtonHandle )
{
	return; 
	/*
	local int idx;
	local string btnName;
	local string parentName;

	local PartyMemberInfo info;	

	local int i;

	btnName = a_ButtonHandle.GetWindowName();
	parentName = a_ButtonHandle.GetParentWindowName();	

	if( btnName == "AutoPartyMatchingBtn" )
	{
		idx = int( Right(parentName , 1));		

		/*
		debug(parentName);
		Debug("AutoPartyMatchingBtn Click ["$string(idx)$"]");
		Debug("m_Vname[idx].ID>>" $ string(m_Vname[idx].ID) );
		Debug("m_Vname[idx].VName>>" $ m_Vname[idx].VName );

		Debug("m_Vname[0].ID>>" $ string(m_Vname[0].ID) );
		Debug("m_Vname[1].ID>>" $ string(m_Vname[1].ID) );
		Debug("m_Vname[2].ID>>" $ string(m_Vname[2].ID) );
		*/

		//??? ????? ??? ??? ??? ???.
		if( FindAutoParty(idx) )
		{
			//??? ????? ???? ???.
			//debug( "??? ????? ???? ???" );
			RequestDeletePartySubstitute( m_arrID[idx] );
		}
		//??? ????? ??? ??? ???.
		else
		{
			//??? ????? ??????.
			//debug( "??? ????? ??????" );
			RequestRegistPartySubstitute( m_arrID[idx] );
			GetPartyMemberInfo( m_arrID[idx], info);
			//Debug( info.Name );
		}		
	}*/
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
	m_PartyOption.SetAnchor("PartyWnd.PartyStatusWnd0", "TopRight", "TopLeft", 5, 5);
	
	
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

	SetINIInt ( "PartyWnd", "a", m_CurBf, "WindowsInfo.ini");	
	
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
	
	//script1 = PartyWnd( GetScript("PartyWnd") );
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

/**
 * ?????? ???? ???? ???? ?? ???? ????.
 */

function SetPartyAutoStatus( int idx, int iSubstatus )
{
	//autoPartyIndex[idx] = iSubstatus;

	//debug( "m_PlayerName[idx]" $ m_PlayerName[idx].GetName() );
	//Debug( "??????????" $ string( AmILeader() ) );
	if( AmILeader() )
	{		
		//??????? ??? ???.
		//?????? ???? ????
		if( iSubstatus == 0 )
		{
			//m_AutoPartyMatchingBtn[idx].SetTexture( "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_Off", "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_On", "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_Off" );
		}
		//?????? ????????
		else
		{
			//m_AutoPartyMatchingBtn[idx].SetTexture( "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_On", "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_On", "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_On" );					
		}
		//m_AutoPartyMatchingBtn[idx].ShowWindow();
		//m_AutoPartyMatchingIcon[idx].HideWindow();

		SetTypePositionLeader( idx );
		//??? ??? ??? ??????
		//???? ??? ??? ???????.. ??????? ?????? ?????..;;
		//FindAllUserParty();		
	}
	else
	{					
		//????? ??? ???.		
		//?????? ???? ????
		if( iSubstatus == 0 )
		{
			//m_AutoPartyMatchingIcon[idx].HideWindow();
			SetTypePosition( idx, 0 );
			//m_AutoPartyMatchingIcon[idx].SetTexture( "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_Off" );
		}
		//?????? ????????
		else
		{
			//m_AutoPartyMatchingIcon[idx].ShowWindow();
			//m_AutoPartyMatchingIcon[idx].SetTexture( "l2ui_ct1.AutoPartyMatchingWnd_DF_StatusWndMatchingBtn_On" );
			SetTypePosition( idx, 1 );
		}
		//m_AutoPartyMatchingBtn[idx].HideWindow();
		//m_AutoPartyMatchingIcon[idx].ShowWindow();
	}
}

/*

function bool FindAllUserParty()
{
	local int i;

	for (i=0; i < MAX_ArrayNum; i++)
	{
		//Debug( "autoPartyIndex[i]>>>" $ string(autoPartyIndex[i]) );
		if ( autoPartyIndex[i] == 1 )
		{
			//ShowWindow( "AutoPartyMatchingStatusWnd" ); ?????? ????
			return true;
			//return false;
		}
	}
	//HideWindow( "AutoPartyMatchingStatusWnd" ); ?????? ????
	return false;
}
*/

/**
 * ??? ????? ????? ????? ???
 */
/*
function bool FindAutoParty( int idx )
{
	local int i;

	for (i=0; i < MAX_ArrayNum; i++)
	{
		//debug( "autoPartyIndex[idx]>>"$string(i)$">>"$string(autoPartyIndex[idx]) );
	}

	if ( autoPartyIndex[idx] == 0 )
	{
		return false;
	}
	else
	{
		return true;
	}
}
*/
//??? ??? ????
/*
function SetAutoParty( int num )
{
	local int i;	
	debug( "num>>" $ string(num) );

	for( i = 0 ; i < MAX_ArrayNum ; i++ )
	{
		//debug( string(autoPartyIndex[i]) );
		if( i == num )
		{
			autoPartyIndex[i] = 1;
			//m_AutoPartyMatchingBtn
		}
		else
		{
			autoPartyIndex[i] = 0;
		}
	}
}
*/

//????? ??????? ??? ??? ??? ??? ????? ????.
function SetTypePositionLeader( int idx )
{
	m_PlayerName[idx].SetWindowSizeRel( 1.0f, 0, - 48 + iconsOffsetX, 14 );
	m_PlayerName[idx].SetAnchor( "PartyWnd.PartyStatusWnd" $ idx, "TopLeft", "TopLeft", 30 - iconsOffsetX, 8 );	
}


//????? ??????? ??? ???.
function SetTypePosition( int idx, int iauto )
{
	if(m_LeaderIcon[idx].GetTextureName() != "")
	{
		//?????? ?????? ???? ???? ??? ?????? ????
		m_PlayerName[idx].SetWindowSizeRel( 1.0f, 0, -48 + iconsOffsetX, 14 );
		m_PlayerName[idx].SetAnchor( "PartyWnd.PartyStatusWnd" $ idx, "TopLeft", "TopLeft", 42 - iconsOffsetX, 8 );	
	}
	else
	{
		if( iauto == 0 )
		{
			m_PlayerName[idx].SetWindowSizeRel( 1.0f, 0, -38, 14 );
			m_PlayerName[idx].SetAnchor( "PartyWnd.PartyStatusWnd" $ idx, "TopLeft", "TopLeft", 30 - iconsOffsetX, 8 );
		}
		else
		{
			m_PlayerName[idx].SetWindowSizeRel( 1.0f, 0, -52, 14 );
			m_PlayerName[idx].SetAnchor( "PartyWnd.PartyStatusWnd" $ idx, "TopLeft", "TopLeft", 30 - iconsOffsetX, 8 );	
		}
	}
}

/*
 	if( iauto == 0 )
	{
		//????? O, ??? ??? ??? X
		if(m_LeaderIcon[idx].GetTextureName() != "")
		{
			m_PlayerName[idx].SetWindowSizeRel( 1.0f, 0, -48, 14 );
			m_PlayerName[idx].SetAnchor( "PartyWnd.PartyStatusWnd" $ idx, "TopLeft", "TopLeft", 40, 8 );		
		}
		//????? X, ??? ??? ??? X
		else
		{
			m_PlayerName[idx].SetWindowSizeRel( 1.0f, 0, -38, 14 );
			m_PlayerName[idx].SetAnchor( "PartyWnd.PartyStatusWnd" $ idx, "TopLeft", "TopLeft", 30, 8 );
		}
	}
	else
	{
		//????? O, ??? ??? ??? O
		if(m_LeaderIcon[idx].GetTextureName() != "")
		{

		}
		//????? X, ??? ??? ??? O
		else
		{
			m_PlayerName[idx].SetWindowSizeRel( 1.0f, 0, -52, 14 );
			m_PlayerName[idx].SetAnchor( "PartyWnd.PartyStatusWnd" $ idx, "TopLeft", "TopLeft", 30, 8 );	
		}
	}
*/



//
function ResetAutoParty()
{/*
	local int i;

	for( i = 0 ; i < MAX_ArrayNum ; i++ )
	{
		autoPartyIndex[i] = 0;
	}*/
}
defaultproperties
{
}
