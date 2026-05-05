/******************************************************************************
//                                             ???? ???? UI ???? ??????                                                                    //
******************************************************************************/
class PartyWndCompact extends UICommonAPI;
	
struct VnameData
{
	var int ID;
	var int UseVName;
	var int DominionIDForVName;
	var string VName;
	var string SummonVName;
};


// ??? ????.
const NSTATUSICON_MAXCOL = 12;		//status icon?? ??? ????.
const NPARTYSTATUS_HEIGHT = 26;		//status ??????? ????????.	// ?????? 46
const NPARTYPETSTATUS_HEIGHT = 18;		//status ??????? ????????.	// ?????? 32
const FIRSTWND_ADD_HEIGHT = 4;		//???????? ????????? ?????? ????

const MAX_ArrayNum = 10; // MAX_ArrayNum = MAX_PartyMemberCount + 1 -> ??? ?????? ????? ??

var bool	m_bCompact;
var bool	m_bBuff;
var bool	m_partyleader;
var int 	m_arrID[MAX_ArrayNum];	// ???????? ?????? ??????? ???? ID.
var int 	m_arrPetID[MAX_ArrayNum];	// ???????? ?????? ??????? ??????? ID.
var int		m_arrSummonID[MAX_ArrayNum];	// ???????? ?????? ??????? ??? ???? ID -> CT3 ???
var int	    m_arrPetIDOpen[MAX_ArrayNum];	// ???????? ?????? ??????? ???? ??? ????????? ???. 1??? ????, 2??? ????. -1??? ????
var int	    m_CurCount;
var int 	m_CurBf;
var int     m_MasterID;

var VnameData m_Vname[MAX_ArrayNum];

//Handle	????
var WindowHandle	m_wndTop;			// ???? ??????
var WindowHandle	m_PartyOption;		// ??? ??????
var WindowHandle	m_PartyStatus[MAX_ArrayNum];	// ??????? ?????? (?????? ????? ?????????)
//var NameCtrlHandle		m_PlayerName[MAX_ArrayNum];
var TextureHandle	m_ClassIcon[MAX_ArrayNum];		//????? ?????? ?????.
var StatusIconHandle	m_StatusIconBuff[MAX_ArrayNum];	//?????????? ???
var StatusIconHandle	m_StatusIconDeBuff[MAX_ArrayNum];	//??????????? ???
var BarHandle		m_BarCP[MAX_ArrayNum];
var BarHandle		m_BarHP[MAX_ArrayNum];
var BarHandle		m_BarMP[MAX_ArrayNum];
var ButtonHandle	btnBuff;

var ButtonHandle			m_petButton[MAX_ArrayNum];
var ButtonHandle			m_petButtonTrash[MAX_ArrayNum];

var WindowHandle		m_PetPartyStatus[MAX_ArrayNum];
//var NameCtrlHandle		m_PetName[MAX_ArrayNum];
var StatusIconHandle		m_PetStatusIconBuff[MAX_ArrayNum];
var StatusIconHandle		m_PetStatusIconDeBuff[MAX_ArrayNum];
var TextureHandle		m_PetClassIcon[MAX_ArrayNum];
var BarHandle			m_PetBarHP[MAX_ArrayNum];
var BarHandle			m_PetBarMP[MAX_ArrayNum];

// ct3 ???? ??? - ??? 
var TextureHandle m_ClassIconSummon[MAX_ArrayNum];
var TextureHandle m_ClassIconSummonNum[MAX_ArrayNum];

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
	
	RegisterEvent( EV_PetStatusSpelledList );		// ?? ?????? ??????? ????
	//RegisterEvent( EV_SummonedStatusSpelledList );	// ?????  ?????? ??????? ????
	
	RegisterEvent( EV_Restart );	
	//RegisterEvent( EV_TargetUpdate );	// ??? ??????? ????

	RegisterEvent( EV_PartySpelledListDelete ); //1182
	RegisterEvent( EV_PartySpelledListInsert ); //1183
	RegisterEvent( EV_PetStatusSpelledListDelete ); //1052	
	RegisterEvent( EV_PetStatusSpelledListInsert ); //1053

	RegisterEvent( EV_NeedResetUIData ); //8000
	
}

// ??????? ??????? ????? ???.
function OnLoad()
{
	local int idx;

	InitHandleCOD();

	m_bCompact = false;
	m_bBuff = false;	
	m_CurBf = 0;
	m_MasterID = 0;
	
	//Reset Anchor	// ?????? ??????? PartyWndCompact?? anchor point?? ???????.
	for (idx=0; idx<MAX_ArrayNum; idx++)
	{
		m_StatusIconBuff[idx].SetAnchor("PartyWndCompact.PartyStatusWnd" $ idx, "TopRight", "TopLeft", 1, 3);
		m_StatusIconDeBuff[idx].SetAnchor("PartyWndCompact.PartyStatusWnd" $ idx, "TopRight", "TopLeft", 1, 3);
		m_PetStatusIconBuff[idx].SetAnchor("PartyWndCompact.PartyStatusSummonWnd" $ idx, "TopRight", "TopLeft", 1, 3);
		m_PetStatusIconDeBuff[idx].SetAnchor("PartyWndCompact.PartyStatusSummonWnd" $ idx, "TopRight", "TopLeft", 1, 3);
	}
	
	//Set ClassIcon0 Position
	m_ClassIcon[0].Move(0, 7);
	
	
	m_PartyOption.HideWindow();
	
	//Init VirtualDrag
	for (idx=0; idx<MAX_ArrayNum; idx++)
	{
		//m_PartyStatus[idx].SetVirtualDrag( true );
		m_PartyStatus[idx].SetDragOverTexture( "L2UI_CT1.ListCtrl.ListCtrl_DF_HighLight" );
	}
	ResetVName();
}


function OnHide()
{
	ResetVName();
}


function checkClassicForm() 
{
	local int idx;	

	for (idx=0; idx<MAX_ArrayNum; idx++)
	{	
		if ( getInstanceUIData().getisClassicServer()  ) 
		{			
			m_ClassIconSummonNum[idx].HideWindow();
		}
		else 
		{		
			m_ClassIconSummonNum[idx].ShowWindow();
		}
	}
}

// ?? ?????? ??? ????? ?????? ?????? ?????
function setHideClassIconSummonNum( int idx ) 
{
	if (  getInstanceUIData().getisClassicServer()  ) 	
		m_ClassIconSummonNum[idx].HideWindow();
	else 	
		m_ClassIconSummonNum[idx].ShowWindow();
}

function InitHandleCOD()
{
	local int idx;
	local Rect rectWnd;
	
	//Init Handle
	m_wndTop = GetWindowHandle( "PartyWndCompact" );
	m_PartyOption = GetWindowHandle("PartyWndOption");		// ?????? ??? ????.
	for (idx=0; idx<MAX_ArrayNum; idx++)		// ???????? ?? ??? ?? ??????? ????????. ->  ??? ?????? ?? ????? ???? ????.
	{
		m_PartyStatus[idx] = GetWindowHandle( "PartyWndCompact.PartyStatusWnd" $ idx );
		m_ClassIcon[idx] = GetTextureHandle( "PartyWndCompact.PartyStatusWnd" $ idx $ ".ClassIcon" );
		m_StatusIconBuff[idx] = GetStatusIconHandle( "PartyWndCompact.PartyStatusWnd" $ idx $ ".StatusIconBuff" );
		m_StatusIconDeBuff[idx] = GetStatusIconHandle( "PartyWndCompact.PartyStatusWnd" $ idx $ ".StatusIconDebuff" );
		m_BarCP[idx] = GetBarHandle( "PartyWndCompact.PartyStatusWnd" $ idx $ ".barCP" );
		m_BarHP[idx] = GetBarHandle( "PartyWndCompact.PartyStatusWnd" $ idx $ ".barHP" );
		m_BarMP[idx] = GetBarHandle( "PartyWndCompact.PartyStatusWnd" $ idx $ ".barMP" );
		
		m_petButton[idx] = GetButtonHandle( "PartyWndCompact.btnSummon" $ idx);	
		m_petButton[idx].HideWindow();
		
		m_PetPartyStatus[idx] = GetWindowHandle( "PartyWndCompact.PartyStatusSummonWnd" $ idx );

		m_PetClassIcon[idx] = GetTextureHandle( "PartyWndCompact.PartyStatusSummonWnd" $ idx $ ".ClassIcon" );
		m_PetStatusIconBuff[idx] = GetStatusIconHandle( "PartyWndCompact.PartyStatusSummonWnd" $ idx $ ".StatusIconBuff" );
		m_PetStatusIconDeBuff[idx] = GetStatusIconHandle( "PartyWndCompact.PartyStatusSummonWnd" $ idx $ ".StatusIconDebuff" );
		m_PetBarHP[idx] = GetBarHandle( "PartyWndCompact.PartyStatusSummonWnd" $ idx $ ".barHP" );
		m_PetBarMP[idx] = GetBarHandle( "PartyWndCompact.PartyStatusSummonWnd" $ idx $ ".barMP" );		
				
		m_arrPetIDOpen[idx] = -1;
		m_arrSummonID[idx] = -1;
		m_arrID[idx] = 0;

		// ct ?? ????? ?? ????? ??????
		m_PetClassIcon[idx] = GetTextureHandle( "PartyWndCompact.PartyStatusSummonWnd" $ idx $ ".ClassIconPet" );

		// ct3 ?? ????? ??, ????? ????? (????? ??????, ????? ??, ?? ??????)
		m_ClassIconSummon[idx]    =  GetTextureHandle( "PartyWndCompact.PartyStatusSummonWnd" $ idx $ ".ClassIconSummon" );
		m_ClassIconSummonNum[idx] =  GetTextureHandle( "PartyWndCompact.PartyStatusSummonWnd" $ idx $ ".ClassIconSummonNum" );

		
		if(idx == 0) //????? ??? ???????? ?????. 
		{
			rectWnd = m_PartyStatus[idx].GetRect();
			m_PartyStatus[idx].SetWindowSize(rectWnd.nWidth, rectWnd.nHeight + FIRSTWND_ADD_HEIGHT);
			
			m_petButton[idx].SetAnchor("PartyWndCompact.PartyStatusWnd" $ idx, "TopLeft", "TopRight", 0, 15);			
		}
		else
			m_petButton[idx].SetAnchor("PartyWndCompact.PartyStatusWnd" $ idx, "TopLeft", "TopRight", 0, 2);
	}
	btnBuff = GetButtonHandle( "PartyWndCompact.btnBuff" );
}

function OnShow()
{
	local int i;
	local int tmpInt;
	
	GetINIInt ( "PartyWndCompact", "a", m_CurBf, "WindowsInfo.ini");
	SetBuffButtonTooltip();
	UpdateBuff();
	//SwapBigandSmall
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

	Debug ( "onShow partyWndCompact");
	ResizeOnlyWnd();
	//ResizeWnd();
	//SetBuffButtonTooltip();
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
	else if (Event_ID == EV_PartySpelledList || Event_ID == EV_PetStatusSpelledList )//|| Event_ID == EV_SummonedStatusSpelledList)	// ???? ??? ????? ???.
	{
		HandlePartySpelledList(param);
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
		HandleRestart();
	}
	else if (Event_ID == EV_PartyRenameMember)
	{
		HandlePartyRenameMember(param);
	}

	else if ( Event_ID == EV_PartySpelledListDelete	||  Event_ID == EV_PetStatusSpelledListDelete)
	{	
		HandlePartySpelledListDelete(param);
//		Debug("onEvent" @ Event_ID @ param);
	}
	else if  ( Event_ID == EV_PartySpelledListInsert ||  Event_ID == EV_PetStatusSpelledListInsert )
	{
		HandlePartySpelledListInsert(param);		
//		Debug( "onEvent" @  Event_ID @ param );
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
	}	
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
	for (idx=0; idx<MAX_ArrayNum ; idx++)
	{
		ClearStatus(idx);		// ??? ?????? ?????????. 
		ClearPetStatus(idx);
		ClearSummonStatus(idx);

		m_arrSummonID[idx] = -1;
	}
	m_CurCount = 0;
	ResizeWnd();
}

//??????? ????
function ClearStatus(int idx)
{
	m_StatusIconBuff[idx].Clear();
	m_StatusIconDeBuff[idx].Clear();
	//m_PlayerName[idx].SetName("", NCT_Normal,TA_Center);
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
	//m_PetName[idx].SetName("", NCT_Normal,TA_Center);
	// m_PetClassIcon[idx].SetTexture("");
	UpdateHPBar(idx + 100, 0, 0);
	UpdateMPBar(idx + 100, 0, 0);
	
	m_petButton[idx].HideWindow();
	
	m_arrPetID[idx] = -1;
	m_arrPetIDOpen[idx] = -1;
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
	local int		MaxValue;
	local int		CurValue;
	
	local int		Row;
	local int		Col;
	local int		MaxRow;
	local int		MaxCol;
	
	local StatusIconInfo info;
	
	//Custom Tooltip
	local CustomTooltip TooltipInfo;
	local CustomTooltip TooltipInfo2;
	local string summonToolTipStr1, summonToolTipStr2;
	local string summonTextureName;
	
	//ServerID
	m_arrID[DesIndex] = m_arrID[SrcIndex];
	
	//Name
	//m_PlayerName[DesIndex].SetName(m_PlayerName[SrcIndex].GetName(), NCT_Normal,TA_Center);
	
	//Window Tooltip
	m_PartyStatus[SrcIndex].GetTooltipCustomType(TooltipInfo);
	m_PartyStatus[DesIndex].SetTooltipCustomType(TooltipInfo);
	
	//Class Texture
	m_ClassIcon[DesIndex].SetTexture(m_ClassIcon[SrcIndex].GetTextureName());
	//Class Tooltip
	m_ClassIcon[SrcIndex].GetTooltipCustomType(TooltipInfo2);
	m_ClassIcon[DesIndex].SetTooltipCustomType(TooltipInfo2);

	//CP,HP,MP
	m_BarCP[SrcIndex].GetValue(MaxValue, CurValue);
	m_BarCP[DesIndex].SetValue(MaxValue, CurValue);
	m_BarHP[SrcIndex].GetValue(MaxValue, CurValue);
	m_BarHP[DesIndex].SetValue(MaxValue, CurValue);
	m_BarMP[SrcIndex].GetValue(MaxValue, CurValue);
	m_BarMP[DesIndex].SetValue(MaxValue, CurValue);
	
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
			m_StatusIconDeBuff[DesIndex].AddCol(Row, info);
		}
	}
	
	// -------------------------------------------??? ??????. 
	//ServerID
	m_arrPetID[DesIndex] = m_arrPetID[SrcIndex];
	m_arrSummonID[DesIndex] = m_arrSummonID[SrcIndex];
	
	m_arrPetID[DesIndex] = m_arrPetID[SrcIndex];	
	m_arrPetIDOpen[DesIndex] = m_arrPetIDOpen[SrcIndex];;	
	
	// ????? ???
	summonTextureName = m_ClassIconSummon[DesIndex].GetTextureName();
	m_ClassIconSummon[DesIndex].SetTexture(m_ClassIconSummon[SrcIndex].GetTextureName());
	m_ClassIconSummon[SrcIndex].SetTexture(summonTextureName);

	// ????
	summonToolTipStr1 = m_ClassIconSummon[SrcIndex].GetTooltipText();	
	summonToolTipStr2 = m_ClassIconSummon[DesIndex].GetTooltipText();	
		
	m_ClassIconSummon[SrcIndex].SetTooltipText(summonToolTipStr2);
	m_ClassIconSummon[DesIndex].SetTooltipText(summonToolTipStr1);
	
	//Name
	//m_PetName[DesIndex].SetName(m_PetName[SrcIndex].GetName(), NCT_Normal,TA_Center);

	
	//Class Texture
	m_PetClassIcon[DesIndex].SetTexture(m_PetClassIcon[SrcIndex].GetTextureName());
	//Class Tooltip
	m_PetClassIcon[SrcIndex].GetTooltipCustomType(TooltipInfo);
	m_PetClassIcon[DesIndex].SetTooltipCustomType(TooltipInfo);
	
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
			m_PetStatusIconDeBuff[DesIndex].AddCol(Row, info);
		}
	}
}


//???????? ?????? ????
function ResizeOnlyWnd()
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
						m_PartyStatus[idx].SetAnchor("PartyWndCompact.PartyStatusSummonWnd" $ idx-1, "BottomLeft", "TopLeft", 0, -4);	// ?? ?????? ?????? ????
					}
					else// ?? ??????? ??????? ???????? ??????? ??????
					{
						m_PartyStatus[idx].SetAnchor("PartyWndCompact.PartyStatusWnd" $ idx-1, "BottomLeft", "TopLeft", 0, -4);	// ????? ?????? ????
					}
				}
				if(m_arrID[idx]!= 0 )
				{
					if (m_arrPetIDOpen[idx] > -1)  m_petButton[idx].showWindow();
					else	m_petButton[idx].HideWindow();
					m_PartyStatus[idx].SetVirtualDrag( true );
					m_PartyStatus[idx].ShowWindow();
				}
				if(m_arrPetIDOpen[idx] == 1) m_PetPartyStatus[idx].ShowWindow();

				
				// ????? ????
				GetPartyMemberInfo(m_arrID[idx], partyMemberInfo);

				// Debug("RESIZE ---> partyMemberInfo.curSummonNum : "  @ partyMemberInfo.curSummonNum);
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
					m_petButton[idx].ShowWindow();
					// Debug("m_arrPetIDOpen[i] " @ m_arrPetIDOpen[idx]);
					//  Debug("-??????? ???? " @ idx @ "  - > "  @ partyMemberInfo.curSummonNum);
				}
				else
				{
					// ??, ????? ????? ?????.. ????? ??? 					
					m_petButton[idx].HideWindow();
					m_PetPartyStatus[idx].HideWindow();					
					m_arrPetIDOpen[idx] = -1;

				}
				// ??????? ????? ?? ????..
				if (partyMemberInfo.curSummonNum > 0)
				{
					m_ClassIconSummon[idx].ShowWindow();
					//m_ClassIconSummonNum[idx].ShowWindow();
					setHideClassIconSummonNum(idx);
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
				m_petButton[idx].HideWindow();
				m_PartyStatus[idx].SetVirtualDrag( false );
				m_PartyStatus[idx].HideWindow();
				m_PetPartyStatus[idx].HideWindow();
			}
		}

		OpenPetCount=0;
		for(i=0; i<MAX_ArrayNum ; i++)
		{
			if(m_arrPetIDOpen[i] == 1) OpenPetCount++;
			else 	// ??????? ?????? ????..
			{
				 if(m_PetPartyStatus[i].IsShowWindow()) m_PetPartyStatus[i].HideWindow();
			}
		}		
		
		//?????? ?????? ????
		rectWnd = m_wndTop.GetRect();
		
		m_wndTop.SetWindowSize(rectWnd.nWidth, NPARTYSTATUS_HEIGHT*m_CurCount  + OpenPetCount * NPARTYPETSTATUS_HEIGHT + FIRSTWND_ADD_HEIGHT);
		// ????? ?????? ??? ?????? ???????? ???????. 
		m_wndTop.SetResizeFrameSize(10, NPARTYSTATUS_HEIGHT*m_CurCount  + OpenPetCount * NPARTYPETSTATUS_HEIGHT + FIRSTWND_ADD_HEIGHT);		
	}
	else	// ??????? ???????? ?????? ?? ??????? ?????? ?????.
	{
		m_wndTop.HideWindow();
		m_PetPartyStatus[idx].HideWindow();
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
						m_PartyStatus[idx].SetAnchor("PartyWndCompact.PartyStatusSummonWnd" $ idx-1, "BottomLeft", "TopLeft", 0, -4);	// ?? ?????? ?????? ????
					}
					else// ?? ??????? ??????? ???????? ??????? ??????
					{
						m_PartyStatus[idx].SetAnchor("PartyWndCompact.PartyStatusWnd" $ idx-1, "BottomLeft", "TopLeft", 0, -4);	// ????? ?????? ????
					}
				}
				if(m_arrID[idx]!= 0 )
				{
					if (m_arrPetIDOpen[idx] > -1)  m_petButton[idx].showWindow();
					else	m_petButton[idx].HideWindow();
					m_PartyStatus[idx].SetVirtualDrag( true );
					m_PartyStatus[idx].ShowWindow();
				}
				if(m_arrPetIDOpen[idx] == 1) m_PetPartyStatus[idx].ShowWindow();

				
				// ????? ????
				GetPartyMemberInfo(m_arrID[idx], partyMemberInfo);

				// Debug("RESIZE ---> partyMemberInfo.curSummonNum : "  @ partyMemberInfo.curSummonNum);
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
					m_petButton[idx].ShowWindow();
					// Debug("m_arrPetIDOpen[i] " @ m_arrPetIDOpen[idx]);
					//  Debug("-??????? ???? " @ idx @ "  - > "  @ partyMemberInfo.curSummonNum);
				}
				else
				{
					// ??, ????? ????? ?????.. ????? ??? 					
					m_petButton[idx].HideWindow();
					m_PetPartyStatus[idx].HideWindow();					
					m_arrPetIDOpen[idx] = -1;

				}
				// ??????? ????? ?? ????..
				if (partyMemberInfo.curSummonNum > 0)
				{
					m_ClassIconSummon[idx].ShowWindow();
					//m_ClassIconSummonNum[idx].ShowWindow();
					setHideClassIconSummonNum(idx);
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
				m_petButton[idx].HideWindow();
				m_PartyStatus[idx].SetVirtualDrag( false );
				m_PartyStatus[idx].HideWindow();
				m_PetPartyStatus[idx].HideWindow();
			}
		}

		OpenPetCount=0;
		for(i=0; i<MAX_ArrayNum ; i++)
		{
			if(m_arrPetIDOpen[i] == 1) OpenPetCount++;
			else 	// ??????? ?????? ????..
			{
				 if(m_PetPartyStatus[i].IsShowWindow()) m_PetPartyStatus[i].HideWindow();
			}
		}		
		
		//?????? ?????? ????
		rectWnd = m_wndTop.GetRect();
		
		m_wndTop.SetWindowSize(rectWnd.nWidth, NPARTYSTATUS_HEIGHT*m_CurCount  + OpenPetCount * NPARTYPETSTATUS_HEIGHT + FIRSTWND_ADD_HEIGHT);
		// ????? ?????? ??? ?????? ???????? ???????. 
		m_wndTop.SetResizeFrameSize(10, NPARTYSTATUS_HEIGHT*m_CurCount  + OpenPetCount * NPARTYPETSTATUS_HEIGHT + FIRSTWND_ADD_HEIGHT);
		if (bOption)	// ?????? ???? ????????? ???? (Compact) ??????? ????
			m_wndTop.ShowWindow();
		else
			m_wndTop.HideWindow();
	}
	else	// ??????? ???????? ?????? ?? ??????? ?????? ?????.
	{
		m_wndTop.HideWindow();
		m_PetPartyStatus[idx].HideWindow();
	}
}

//ID?? ????? ????? ????????? ?????
function int FindPartyID(int ID)
{
	local int idx;
	for (idx=0; idx<MAX_ArrayNum ; idx++)
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
	// local int SummonID;
	
	local int UseVName;
	local int DominionIDForVName;
	local int SummonCount;
	local string VName;
	local string SummonVName;


	// ??? ??? ????
	local PartyMemberInfo    partyMemberInfo;
	// ??? ??? ?? ????
	local PartyMemberPetInfo partyMemberPetInfo;

	local int index, i;

	local int summonType, summonMAXHP, summonMAXMP, summonHP, summonMP;
	local int summonClassID;
	
	//debug("????? ???" @ param);

	ParseInt(param, "ID", ID);	// ID?? ??????.
	// ParseInt(param, "SummonID", SummonID);
	ParseInt(Param, "UseVName",UseVName);
	ParseInt(Param, "DominionIDForVName", DominionIDForVName);
	ParseString(Param, "VName", VName);
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
		//		m_Vname[m_CurCount].SummonVName = SummonVName;
		ExecuteEvent( EV_TargetUpdate);
	
		m_CurCount++;	
		
		m_arrID[m_CurCount-1] = ID;
		UpdateStatus(m_CurCount-1, param);
		
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
					 m_ClassIconSummon[m_CurCount - 1].SetTooltipText(GetSystemString(505)); //getSummonSortString(class'UIDATA_NPC'.static.GetSummonSort(summonClassID)));
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
				// ??????..
				if (summonType == 2)
				{
					ParseInt(param, "SummonMaxHP" $ i, SummonMaxHP);
					ParseInt(param, "SummonMaxMP" $ i, SummonMaxMP);
					ParseInt(param, "SummonHP"    $ i, SummonHP);
					ParseInt(param, "SummonMP"    $ i, SummonMP);
					ParseString(param, "SummonVName" $ i, SummonVName);

					// Debug("?? ??????? -> ??? -> "@ SummonMaxHP);
					UpdateHPBar(index + 100, SummonHP, SummonMaxHP);
					UpdateMPBar(index + 100, SummonMP, SummonMaxMP);

					m_Vname[m_CurCount].SummonVName = SummonVName;
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
function UpdateStatus(int idx, string param)
{
	local string	Name;
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
	local int		MasterID;
	local int		IsBRPremium;
	local string    premiumText;
	local userinfo 	TargetUser;
	
	//Custom Tooltip
	local CustomTooltip TooltipInfo;
	local CustomTooltip TooltipInfo2;
	
	local int UseVName;
	local int DominionIDForVName;
	local string VName;
	local string SummonVName;
		
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

		
	UseVName = m_Vname[idx].UseVName;
	DominionIDForVName = m_Vname[idx].DominionIDForVName;
	VName = m_Vname[idx].VName;
	SummonVName = m_Vname[idx].SummonVName;
	
	//?????????????? ????? ?????? ????????.
	if (ParseInt(param, "MasterID", MasterID))
		m_MasterID = MasterID;
	
	//Window Tooltip
	TooltipInfo.DrawList.length = 1;
	TooltipInfo.DrawList[0].eType = DIT_TEXT;
	TooltipInfo.DrawList[0].t_bDrawOneLine = true;
	if (m_MasterID >0 && m_MasterID==ID)
	{	
		if (TargetUser.WantHideName && TargetUser.RealName != "")
		{
			TooltipInfo.DrawList[0].t_strText =  TargetUser.Name $ "(" $ GetSystemString(408) $ ")";
		}
		else
		{
			TooltipInfo.DrawList[0].t_strText =  Name $ "(" $ GetSystemString(408) $ ")";
		}
	}
	else
	{
		if (UseVName == 1)
		{
			TooltipInfo.DrawList[0].t_strText = VName;
		}
		else
		{
			TooltipInfo.DrawList[0].t_strText = Name;
		}
	}
	if (IsBRPremium > 0)
	{
		TooltipInfo.DrawList[0].t_strText = "[PA] " $ TooltipInfo.DrawList[0].t_strText;
	}
	TooltipInfo.DrawList[0].t_strText = TooltipInfo.DrawList[0].t_strText $ " Lv." $ string(Level);
	m_PartyStatus[idx].SetTooltipCustomType(TooltipInfo);
	
	//???? ??????
	m_ClassIcon[idx].SetTexture(GetClassRoleIconName(ClassID));
	
	//Custom Tooltip
	TooltipInfo2.DrawList.length = 2;
	TooltipInfo2.DrawList[0].eType = DIT_TEXT;
	TooltipInfo2.DrawList[0].t_bDrawOneLine = true;
	if (m_MasterID >0 && m_MasterID==ID)
	{	
		if (TargetUser.WantHideName && TargetUser.RealName != "")
			TooltipInfo2.DrawList[0].t_strText =  TargetUser.Name $ "(" $ GetSystemString(408) $ ")";
		else
			TooltipInfo2.DrawList[0].t_strText =  Name $ "(" $ GetSystemString(408) $ ")";
	}
	else
	{
		if (TargetUser.WantHideName && TargetUser.RealName != "")
			TooltipInfo2.DrawList[0].t_strText = TargetUser.Name;
		else
			TooltipInfo2.DrawList[0].t_strText = Name;
	}
	
	TooltipInfo2.DrawList[1].eType = DIT_TEXT;
	TooltipInfo2.DrawList[1].nOffSetY = 2;
	TooltipInfo2.DrawList[1].t_bDrawOneLine = true;
	TooltipInfo2.DrawList[1].bLineBreak = true;
	
	if (IsBRPremium > 0)
		premiumText = "Premium: ON";
	else
		premiumText = "Premium: OFF";

	TooltipInfo2.DrawList[1].t_strText = GetClassRoleName(ClassID) $ " - " $ GetClassType(ClassID) $ " / Lv." $ string(Level) $ " / " $ premiumText;
	TooltipInfo2.DrawList[1].t_color.R = 128;
	TooltipInfo2.DrawList[1].t_color.G = 128;
	TooltipInfo2.DrawList[1].t_color.B = 128;
	TooltipInfo2.DrawList[1].t_color.A = 255;
	m_ClassIcon[idx].SetTooltipCustomType(TooltipInfo2);
	
	//???? ??????
	UpdateCPBar(idx, CP, MaxCP);
	UpdateHPBar(idx, HP, MaxHP);
	UpdateMPBar(idx, MP, MaxMP);
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
				debug("HandlePartyPetAdd ERROR - Can't find master ID");
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
		 m_ClassIconSummon[idx].SetTooltipText(GetSystemString(505)); //getSummonSortString(class'UIDATA_NPC'.static.GetSummonSort(m_SummonInfo.nClassID)));
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
		for(i=0; i< MAX_ArrayNum; i++)
		{
			if(m_arrID[i] == MasterID)
			{
				MasterIndex = i;
				break;
			}
		}
		
		if(MasterIndex == -1)
		{
			debug("PartySummonProcess -> ERROR - Can't find master ID");
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
			setHideClassIconSummonNum(idx);
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
	
	local bool isPC;	//pc???? ?????? ????? ???
	
	local StatusIconInfo info;
	
	DeBuffCurRow = -1;
	BuffCurRow = -1;
	
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
			isPC = false;
		}
		else
		{
			return;	// ?? ??????? ????? ?? ???????
		}
	}
	
	//info ????
	info.Size = 10;
	info.bShow = true;
		
	ParseInt(param, "Max", Max);
	
	for (i=0; i<Max; i++)
	{
		ParseItemIDWithIndex(param, info.ID, i);
		ParseInt(param, "Level_" $ i, info.Level);
		ParseInt(param, "SubLevel_" $ i, info.SubLevel);
		//ttp 60079

		// ???? ?????? ??? add ???? ????.
		if ( class'UIDATA_SKILL'.static.IsToppingSkill( info.ID, info.Level, info.SubLevel) ) 
		{			
			continue ;
		}

		ParseInt(param, "SpellerID_" $ i, info.SpellerID);
		
		if (IsValidItemID(info.ID))
		{
			info.IconName = class'UIDATA_SKILL'.static.GetIconName(info.ID, info.Level, info.SubLevel);
			
			if (GetDebuffType( info.ID, info.Level, info.SubLevel) != 0 )
			{
				if (DeBuffCnt%NSTATUSICON_MAXCOL == 0)
				{
					DeBuffCurRow++;
					if(isPC)	m_StatusIconDeBuff[idx].AddRow();
					else		m_PetStatusIconDeBuff[idx].AddRow();
				}
				if(isPC)	m_StatusIconDeBuff[idx].AddCol(DeBuffCurRow, info);	
				else 		m_PetStatusIconDeBuff[idx].AddCol(DeBuffCurRow, info);		
				DeBuffCnt++;
			}
			else
			{
				if (BuffCnt%NSTATUSICON_MAXCOL == 0)
				{
					BuffCurRow++;
					if(isPC)	m_StatusIconBuff[idx].AddRow();
					else		m_PetStatusIconBuff[idx].AddRow();
				}
				if(isPC)	m_StatusIconBuff[idx].AddCol(BuffCurRow, info);	
				else		m_PetStatusIconBuff[idx].AddCol(BuffCurRow, info);	
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
		ParseItemIDWithIndex(param, info.ID, i);
		ParseInt(param, "Level_" $ i, info.Level);
		ParseInt(param, "SubLevel_" $ i, info.SubLevel );

		ParseInt(param, "SpellerID_" $ i, info.SpellerID);
		
		if (IsValidItemID(info.ID))
		{	
			//???????? 
			if (GetDebuffType( info.ID, info.Level, info.SubLevel) != 0 )
			{
				if ( isPC ) deleteBuff( m_StatusIconDeBuff[idx], info.Level, info.ID.ClassID, info.SpellerID);
				else 		deleteBuff( m_PetStatusIconDeBuff[idx], info.Level, info.ID.ClassID, info.SpellerID );							
			}			
			//??? ???? 
			else
			{				
				if ( isPC ) deleteBuff( m_StatusIconBuff[idx], info.Level, info.ID.ClassID, info.SpellerID);
				else        deleteBuff( m_PetStatusIconBuff[idx], info.Level, info.ID.ClassID, info.SpellerID);
			}
		}
	}
	UpdateBuff();
}


//???? ?????? ?????? ??? ???? ??? ???
//ttp 60079 ?? spellerID ???
function deleteBuff( StatusIconHandle tmpStatusIcon , int level, int classID, int spellerID )
{
	local int row;	
	local int col;
	local StatusIconInfo info;	

	for ( row = 0 ; row < tmpStatusIcon.GetRowCount(); row++ )
	{
		for ( col = 0 ; col < tmpStatusIcon.GetColCount(row) ; col++)
		{
			tmpStatusIcon.GetItem(row, col, info );		
			if ( info.ID.classID == classID && info.level ==  level && info.SpellerID == spellerID)
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
	info.Size = 10;	
	info.bShow = true;	

	//Debug( "HandlePartySpelledListInsert" @ String(isPC) @ idx);
	//Max=1 ID=1209091781 ClassID_0=77 Level_0=2 Sec_0=1200
	ParseInt(param, "Max", Max);
	for (i=0; i<Max; i++)
	{
		ParseItemIDWithIndex(param, info.ID, i);
		ParseInt(param, "Level_" $ i, info.Level);
		ParseInt(param, "SubLevel_" $ i, info.SubLevel);
		ParseInt(param, "Sec_" $ i, info.RemainTime);

		// ???? ?????? ??? add ???? ????.
		if ( class'UIDATA_SKILL'.static.IsToppingSkill( info.ID, info.Level, info.SubLevel) ) 
		{			
			continue ;
		}

		//ttp 60079
		ParseInt(param, "SpellerID_" $ i, info.SpellerID);

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
			//??? ???? 
			else
			{				
				if ( isPC ) tmpStatusIcon = m_StatusIconBuff[idx];
				else        tmpStatusIcon = m_PetStatusIconBuff[idx];
			}
		
			//???? ????
			deleteBuff ( tmpStatusIcon, info.Level, info.ID.ClassID, info.SpellerID );
			
			//Debug("buffRow" @ tmpStatusIcon.GetRowCount() - 1 @ tmpStatusIcon.GetColCount( tmpStatusIcon.GetRowCount() -1 ));
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
	
	
	if (m_CurBf > 2)
	{
		m_CurBf = 0;
	}
	
	SetINIInt ( "PartyWndCompact", "a", m_CurBf, "WindowsInfo.ini");

	SetBuffButtonTooltip();
	
	switch (m_CurBf)
	{
		case 1:
		UpdateBuff();
		break;
		case 2:
		UpdateBuff();
		break;
		case 0:
		m_CurBf = 0;
		UpdateBuff();
	}
}

// ?????? ????
function OnClickButton( string strID )
{
	local int idx;
	local PartyWnd script;
	script = PartyWnd( GetScript("PartyWnd") );
	switch( strID )
	{
	case "btnBuff":		//??????? ????? 
		OnBuffButton();
		//script.OnBuffButton();
		break;
	case "btnOption":	// ??? ??? ?????
		OnOpenPartyWndOption();
		break;
	case "btnSummon":	// ????? ??? ?????
		//debug("ERROR - you can't enter here");	// ????? ?????? ???? -_-;
		break;
	}
	
	//debug("btnSummon strID-->@@" @ strID);
	//debug("-------------@@@@@@" @ inStr( strID , "btnSummon"));
	if(  inStr( strID , "btnSummon") > -1)
	{
		//debug("btnSummon strID-->@@" @ strID);
		//Debug("idx:" @ idx);
		
		idx = int( Right(strID , 1));
		if(m_PetPartyStatus[idx].isShowwindow())
		{
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
	// ??????? ????? ? ?????? ??? ??????? ???????. 
	for(i=0; i<MAX_ArrayNum; i++)
	{	
		script.m_arrPetIDOpen[i] = m_arrPetIDOpen[i];
	}
	
	script.ShowPartyWndOption();
	m_PartyOption.SetAnchor("PartyWndCompact.PartyStatusWnd0", "TopRight", "TopLeft", 5, 5);
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
	if (m_CurBf > 2)
	{
		m_CurBf = 0;
	}

	SetINIInt ( "PartyWndCompact", "a", m_CurBf, "WindowsInfo.ini");	
	
	// ???????
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
			
		}
	}
	else if (m_CurBf == 2)
	{
		for (idx=0; idx<MAX_ArrayNum ; idx++)
		{
			m_StatusIconBuff[idx].HideWindow();	
			m_PetStatusIconBuff[idx].HideWindow();
			m_StatusIconDeBuff[idx].ShowWindow();	
			m_PetStatusIconDeBuff[idx].ShowWindow();
			
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
		}
	}
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
	
	rectWnd = m_wndTop.GetRect();
	if (X > rectWnd.nX + 30)
	{
		if (GetPlayerInfo(userinfo))
		{
			//idx = (Y-rectWnd.nY) / NPARTYSTATUS_HEIGHT;
			idx = GetIdx(Y-rectWnd.nY);
			//debug("OnLButtonDown : " $ idx);
			//RequestTargetUser(m_arrID[idx]);	// ???? ?? ??????? ???????? ????? ??????

			rectWnd = m_PetPartyStatus[idx].GetRect();
			rectPetClassIcon = m_PetClassIcon[idx].GetRect();

			if (IsPKMode())
			{
				if(idx <100)
					RequestAttack(m_arrID[idx], userinfo.Loc);
				else
				{
					if (X > rectPetClassIcon.nX && X < rectWnd.nX + rectWnd.nWidth -10)	RequestAttack(m_arrPetID[idx-100], userinfo.Loc);
				}
			}
			else
			{
				if(idx < 100)
					RequestAction(m_arrID[idx], userinfo.Loc);
				else
					if (X > rectPetClassIcon.nX && X < rectWnd.nX + rectWnd.nWidth -10) RequestAction(m_arrPetID[idx-100], userinfo.Loc);
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
	if (X > rectWnd.nX + 30)
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
	
	for(i=0 ; i<MAX_ArrayNum; i++)
	{
		tempY = tempY - NPARTYSTATUS_HEIGHT;
		if(i == 0) tempY = tempY - FIRSTWND_ADD_HEIGHT;	// ????? ??? ??? ?? ??????? ???? ?? ?????. 
		
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
		case 2:	idx = 1498;
		break;
	}	
	btnBuff.SetTooltipCustomType(MakeTooltipSimpleText(GetSystemString(idx)));
}


function OnDropWnd( WindowHandle hTarget, WindowHandle hDropWnd, int x, int y )
{
	local string sTargetName, sDropName,sTargetParent;
	local int dropIdx, targetIdx,i;
	
	local  PartyWnd script1;			// ???? ?????? ?????
	//local PartyWndCompact script2;	// ???? ?????? ?????
	
	script1 = PartyWnd( GetScript("PartyWnd") );
	//script2 = PartyWndCompact( GetScript("PartyWndCompact") );
	
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
			script1.CopyStatus ( MAX_PartyMemberCount , dropIdx );		//????? ??????
			
			for (i=dropIdx-1; i>targetIdx-1; i--)	// ????? ???????. 
			{
				CopyStatus(i+1, i);
				script1.CopyStatus(i+1, i);
			}
			CopyStatus ( targetIdx , MAX_PartyMemberCount  );
			script1.CopyStatus ( targetIdx , MAX_PartyMemberCount  );
		}
		else if(dropIdx < targetIdx)
		{
			CopyStatus ( MAX_PartyMemberCount , dropIdx );		//????? ??????
			script1.CopyStatus ( MAX_PartyMemberCount , dropIdx );		//????? ??????
			
			for (i=dropIdx+1; i<targetIdx+1; i++)	// ???? ???????.
			{
				CopyStatus(i-1, i);
				script1.CopyStatus(i-1, i);
			}
			CopyStatus ( targetIdx , MAX_PartyMemberCount  );
			script1.CopyStatus ( targetIdx , MAX_PartyMemberCount  );
		}
		ClearStatus(MAX_PartyMemberCount);
		ClearPetStatus(MAX_PartyMemberCount);
		
		//Update Client Data
		class'UIDATA_PARTY'.static.MovePartyMember( dropIdx, targetIdx );
		
		//CopyStatus ( 8 , targetIdx );		//????? ??????
		//CopyStatus ( targetIdx , dropIdx  );
		//CopyStatus ( dropIdx ,  8  );
		//ClearStatus(8);
		//ClearPetStatus(8);
		
		//script1.CopyStatus ( 8 , targetIdx );		//????? ??????
		//script1.CopyStatus ( targetIdx , dropIdx  );
		//script1.CopyStatus ( dropIdx ,  8  );
		//script1.ClearPetStatus(8);
		//script1.ClearStatus(8);
		
		ResizeWnd();
	}
	
	
	//hTarget.
	
	//m_PartyStatus[idx].SetAnchor("PartyWnd.PartyStatusSummonWnd" $ idx-1, "BottomLeft", "TopLeft", 0, 0);	// ?? ?????? ?????? ????
	
	//?????? ?????????. 
		
	//Debug( "DropTargetWindow: " $ hTarget.GetWindowName() );
	//Debug( "DropWindow: " $ hDropWnd.GetWindowName() );
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

/** 
 * ????? ??? ???   
 * -> ??? ???????? ?? ??? ??????? ????
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
defaultproperties
{
}
