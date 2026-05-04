class GMFindTreeWnd extends UICommonAPI;

var WindowHandle  Me;
//var array<String> m_ComboList;
var String m_WindowName;
//var bool bSummon;
var bool bShow;	// GM창에서 버튼을 한번 더 누르면 사라지게 하기 위한 변수
var Color Gold;

var ListCtrlHandle	m_hFindTreeList;

//var EditBoxHandle	m_hEdSummonCnt;

var EditBoxHandle	m_hEditBox;

var ComboBoxHandle  m_hComboBox;

var ButtonHandle    m_hBtnSummon;

const ASK_SUMMON_NUMBER = 10000;

enum EListType
{
	LISTTYPE_ITEM,
	LISTTYPE_NPC,
	LISTTYPE_QUEST,
	LISTTYPE_SKILL,	
	LISTTYPE_CLASS,	
	LISTTYPE_SYSTEMSTRING,		
	LISTTYPE_SYSTEMMESSAGE,		
};

var EListType       curListType;

/*
enum ESummontype
{
	SUMMONTYPE_None,
	SUMMONTYPE_SKill,
	SUMMONTYPE_Quest,
	SUMMONTYPE_SYSTEMSTRING,
	SUMMONTYPE_SYSTEMMESSAGE,
};
*/

//var ESummontype SummonType;


function OnRegisterEvent()
{	
	RegisterEvent( EV_DialogOK );
	RegisterEvent( EV_DialogCancel );
}

function OnLoad()
{
	SetClosingOnESC();
	Me = GetWindowHandle("GMFindTreeWnd");
	m_hFindTreeList = GetListCtrlHandle(m_WindowName $ ".ListFindWnd");
//	m_hEdSummonCnt = GetEditBoxHandle(m_WindowName$".edSummonCnt");
	
	m_hEditBox = GetEditBoxHandle(m_WindowName$".EditBox");
	
	m_hComboBox = GetComboBoxHandle (m_WindowName$".ComboBox" );

	m_hBtnSummon = GetButtonHandle (m_WindowName$".btnSummon" );

	// 상해에서 만든 api , 툴팁을 클릭 롤 오버만 해도 보이도록
	m_hFindTreeList.SetSelectedSelTooltip(false);	
	m_hFindTreeList.SetAppearTooltipAtMouseX(true);

	//bSummon = false;
	//SummonType = SUMMONTYPE_None;
	bShow = false;

	Gold.R = 176;
	Gold.G = 153;
	Gold.B  = 121;

	FillOutComboBoxHandle();
}

function FillOutComboBoxHandle()
{
	m_hComboBox.Clear();
	m_hComboBox.AddStringWithReserved(GetSystemString( 691 ),   EListType.LISTTYPE_ITEM );
	m_hComboBox.AddStringWithReserved(GetSystemString( 690 ),   EListType.LISTTYPE_NPC );
	m_hComboBox.AddStringWithReserved(GetSystemString( 699 ),   EListType.LISTTYPE_QUEST );
	m_hComboBox.AddStringWithReserved(GetSystemString( 692 ),   EListType.LISTTYPE_SKILL );
	m_hComboBox.AddStringWithReserved(GetSystemString( 2290 ),  EListType.LISTTYPE_CLASS );		
	m_hComboBox.AddStringWithReserved("SystemString",           EListType.LISTTYPE_SYSTEMSTRING );
	m_hComboBox.AddStringWithReserved("SystemMessage",          EListType.LISTTYPE_SYSTEMMESSAGE );
}

/*
function onShow()
{
	//m_hBtnSummon.EnableWindow();
}*/

function OnComboBoxItemSelected(string StrID, int IndexID)
{	
	local string EditBoxString;

	EditBoxString = m_hEditBox.GetString();
	//Debug( "OnComboBoxItemSelected" @ EListType ( IndexID ) );
	switch(strID)
	{
		case "ComboBox" :			
			ShowList( EditBoxString , EListType( IndexID ));			
		break;
	}
}


function OnEvent( int a_EventID, String a_Param )
{
	switch( a_EventID )
	{
		case EV_DialogOK  :
			HandleDialogOK();
		break;
		case EV_DialogCancel :
		break;
	}
}

function ShowList ( String a_Param, EListType listType)
{	
	Me.HideWindow();

	curListType = listType ;
	m_hEditBox.SetString ( a_Param );

	m_hComboBox.SetSelectedNum(curListType);

	m_hBtnSummon.DisableWindow(); 

	switch (curListType) 
	{
	case LISTTYPE_ITEM:
		FindAllItem( a_Param );
		//SummonType = SUMMONTYPE_None ;		
		//bSummon = true;
		//m_hBtnSummon.EnableWindow();
		break;
	case LISTTYPE_QUEST:		
		FindAllQuest( a_Param );	
		//SummonType = SUMMONTYPE_Quest;
		//bSummon = true;
		//m_hBtnSummon.DisableWindow();
		break;
	case LISTTYPE_NPC:		
		FindAllNPC( a_Param );
		//SummonType = SUMMONTYPE_None;
		//bSummon = true;
		//m_hBtnSummon.EnableWindow();
		break;
	case LISTTYPE_SKILL:	
		FindAllSkill( a_Param );		
		//SummonType = SUMMONTYPE_Skill;
		//bSummon = true;
		//m_hBtnSummon.DisableWindow();
		break;	
	case LISTTYPE_CLASS :
		FindAllCLASS( a_Param );
		break;
	case LISTTYPE_SYSTEMSTRING:
		FindAllSystemString( a_Param );
		//SummonType = SUMMONTYPE_SYSTEMSTRING;
		//bSummon = false;
		//m_hBtnSummon.DisableWindow();
		break;
	case LISTTYPE_SYSTEMMESSAGE :
		FindAllSystemMessage( a_Param );
		//SummonType = SUMMONTYPE_SYSTEMMESSAGE;
		//bSummon = false;
//		m_hBtnSummon.DisableWindow();
		break;
	}	
	
	Me.ShowWindow();
	Me.SetFocus();
}

function FindAllCLASS( string a_Param) 
{
	local int classIndex;
	local String fullNameString;

	ClearList();

	for ( classIndex = 0 ; classIndex < 500 ; classIndex++ )
	{
		fullNameString = GetSystemString ( class'UIDataManager'.static.GetClassnameSysstringIndexByClassIndex( classIndex ));

		if ( fullNameString != "" ) 
		{			
			if ( InsertRecordFindTreeList ( fullNameString, a_Param, classIndex, GetClassRoleIconName ( classIndex ) ) == 1000 )
			{
				AddSystemMessage(3489);	
				return;		
			}
		}
	}	
}

function FindAllSystemString( string a_Param) 
{
	local int i;
	local String fullNameString;

	ClearList();

	for ( i = 0 ; i < 10000 ; i++ )
	{
		fullNameString = GetSystemString ( i ) ;	

		if ( fullNameString != "" ) 
		{			
			if ( InsertRecordFindTreeList ( fullNameString, a_Param, i, "" ) == 1000 )
			{
				AddSystemMessage(3489);	
				return;		
			}
		}
	}	
}

function FindAllSystemMessage( string a_Param) 
{
	local int i;
	local String fullNameString;

	ClearList();

	for ( i = 0 ; i < 7000 ; i++ )
	{
		fullNameString = GetSystemMessage ( i ) ;
		
		if ( fullNameString != "" )
		{	
			//Debug( "FindAllSystemMessage" @ fullNameString );
			if ( InsertRecordFindTreeList ( fullNameString, a_Param, i, "" ) == 1000 ) 
			{
				AddSystemMessage(3489);	
				return;		
			}
		}
	}	
}


function FindAllQuest( String a_Param )
{
	local int ID;
	local String fullNameString;
	local string IconName;
	local int QuestType;
	
	ClearList();
	
	for( ID = class'UIDATA_QUEST'.static.GetFirstID(); -1 != ID ; ID = class'UIDATA_QUEST'.static.GetNextID() )
	{
		fullNameString  = class'UIDATA_QUEST'.static.GetQuestName( ID );
		QuestType = class'UIDATA_QUEST'.static.GetQuestType(ID, 1);

		switch( QuestType )
		{
		case 0:
		case 2:
			IconName = "L2UI_CH3.QUESTWND.QuestWndInfoIcon_1";
			break;
		case 1:
		case 3:
			IconName = "L2UI_CH3.QUESTWND.QuestWndInfoIcon_2";
			break;

		case 4:		
			//Debug("일일 파티");		
		case 5:
			IconName = "L2UI_CH3.QUESTWND.QuestWndInfoIcon_3";
			//Debug("일일 솔로");
			break;
		}
		if ( InsertRecordFindTreeList ( fullNameString, a_Param, ID, IconName ) == 1000 ) 
		{
			AddSystemMessage(3489);	
			return;		
		}
	}
}

function FindAllSkill( String a_Param )
{
	local ItemID cID;
	local String fullNameString;
	local String IconName;
	
	ClearList();

	for ( cID = class'UIDATA_SKILL'.static.GetFirstID(); IsValidItemID(cID); cID = class'UIDATA_SKILL'.static.GetNextID() )
	{
		// !문제 있는지 확인
		fullNameString = class'UIDATA_SKILL'.static.GetName( cID, 1, 0 );
		IconName = class'UIDATA_SKILL'.static.GetIconName( cID, 1, 0 );
		
		if ( InsertRecordFindTreeList ( fullNameString, a_Param, cID.ClassID, IconName ) == 1000 ) 
		{
			AddSystemMessage(3489);	
			return;		
		}
	}	
}

function FindAllNPC( String a_Param )
{
	local int ID;
	local String fullNameString;
	
	ClearList();
	
	for( ID = class'UIDATA_NPC'.static.GetFirstID(); -1 != ID ; ID = class'UIDATA_NPC'.static.GetNextID() )
	{
		fullNameString  = class'UIDATA_NPC'.static.GetNPCName( ID );		
		
		if ( InsertRecordFindTreeList ( fullNameString, a_Param, ID + 1000000, ""  ) == 1000 ) 
		{
			AddSystemMessage(3489);	
			return;		
		}
	}
}

function FindAllItem( String a_Param )
{
	local ItemID cID;
	local String fullNameString;
	local String additionalName;
	local int itemNameClass;

	local string IconName;

	ClearList();

	m_hFindTreeList.SetTooltipType("SellItemList");
		
	for ( cID = class'UIDATA_ITEM'.static.GetFirstID(); IsValidItemID(cID); cID = class'UIDATA_ITEM'.static.GetNextID() )
	{
		fullNameString  = class'UIDATA_ITEM'.static.GetItemName( cID );

		itemNameClass = class'UIDATA_ITEM'.static.GetItemNameClass( cID);

		additionalName = class'UIDATA_ITEM'.static.GetItemAdditionalName( cID );

		IconName = class'UIDATA_ITEM'.static.GetItemTextureName( cID );

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



		if ( InsertRecordFindTreeList ( fullNameString, a_Param, cID.ClassID, IconName ) == 1000 ) 
		{
			AddSystemMessage(3489);	
			return;		
		}
	}
}

//스킬에 레벨 붙여 소환 하도록 작업
function int makeSkillLevel ( int id )
{
	local LVDataRecord preRecord;
	local int recordCount;

	preRecord.LVDataList.Length = 2;

	recordCount = m_hFindTreeList.GetRecordCount();
	
	//입력이 한개도 없는 첫 입력 이라면
	if ( recordCount == 0 ) return 1;

	m_hFindTreeList.GetRec( (recordCount -1) , preRecord );				

	//이전 ID 와 같으면 이전 보다 높은 레벨을 리턴
	if ( preRecord.LVDataList[1].szData == String ( id ) )
	{						
		return preRecord.LVDataList[1].nReserved1 + 1 ;	
	}
	// 다르면 새로운 스킬이므로 1레벨	

	return 1;
}

function LVDataRecord InsertIconData(LVDataRecord record, string iconName)
{
	local int nTextureWH;
	local int nTextureUV;

	record.LVDataList[0].hasIcon = true;

	switch ( curListType )
		{
		case LISTTYPE_ITEM:
			nTextureWH = 18;
			nTextureUV = 32;
			
			break;
		case LISTTYPE_SKILL:
			nTextureWH = 18;
			nTextureUV = 32;
	
		break;
		case LISTTYPE_CLASS:
			nTextureWH = 16;
			nTextureUV = 16;
			break;

		case LISTTYPE_QUEST:
			nTextureWH = 16;
			nTextureUV = 16;			
		break;
		default:
			nTextureWH = 16;
			nTextureUV = 16;
			
		break;
		}			

		record.LVDataList[0].nTextureWidth  = nTextureWH;
		record.LVDataList[0].nTextureHeight = nTextureWH;
		record.LVDataList[0].nTextureU = nTextureUV;
		record.LVDataList[0].nTextureV = nTextureUV;
		
		record.LVDataList[0].szTexture = iconName; 
		record.LVDataList[0].IconPosX= 2 ;
		record.LVDataList[0].FirstLineOffsetX= 2;

	return record;
}

function int InsertRecordFindTreeList( string fullNameString , string a_param, int id, string iconName) 
{
	local  string modifiedString, itemParam;
	local LVDataRecord record;		
	
	record.LVDataList.Length = 2;
	
	modifiedString = Substitute(fullNameString, " ", "", FALSE);

	if ( findMatchString ( modifiedString, a_Param ) != -1 || a_Param == "" || a_Param == String ( id ) )
	{	
		record.LVDataList[0].buseTextColor = True;		
		record.LVDataList[0].TextColor = Gold;		

		if (curListType ==LISTTYPE_ITEM)
		{
			// 해당 아이템 정보 리스트에 넣을때꺼내올수 있도록 기억  <- 중국쪽에서 만든 api
			class'UIDATA_ITEM'.static.GetItemInfoString(id, itemParam);  
			Record.szReserved = itemParam;
			Record.nReserved1 = Int64(id);
		}
		else if ( curListType == LISTTYPE_SKILL) 
		{				
			record.LVDataList[1].nReserved1 = makeSkillLevel( id );
			fullNameString = fullNameString @ "Lv" $ record.LVDataList[1].nReserved1 ; 		
		}			
		
		if ( iconName != "" ) record = InsertIconData(record, iconName);

		record.LVDataList[0].szData = fullNameString;

		record.LVDataList[1].szData= string( id );
		record.LVDataList[1].TextColor = Gold;	
		
		m_hFindTreeList.InsertRecord(record);

		return m_hFindTreeList.GetRecordCount();
	}
}

function int findMatchString( string modifiedString, string a_Param )
{
	//local array <string> modifiedParamArr;
	//local int i ;
	local string delim;
	//local int _inStr;

	//branch GD35_0828 2013-11-13 luciper3 - 미국에서 지엠명령어 대소문 구분없이 사용가능하도록 수정해달라고함.
	//local bool bIsUsa;
	//local string strTemp1;
	//local string strTemp2;
	//end of branch

	delim  = " ";
	
	if (StringMatching(modifiedString, a_Param, delim))
		return 1;
	else
		return -1;

	/* StringMatching으로 대체
	//Split( a_Param, " ", modifiedParamArr);	 <- 이건 delim 이 두개가 들어가면 정상 작동 되지 않음 !!! 쓰이고 있는 곳이 많아서 코드 자체를 들여 옴 ldw
	_inStr = InStr(a_Param, delim);
	while ( _inStr > -1  )
	{
		modifiedParamArr.Insert(modifiedParamArr.Length, 1);
		modifiedParamArr[modifiedParamArr.Length-1] = Left(a_Param, _inStr );		
		a_Param = Mid(a_Param, _inStr + 1);
		_inStr = InStr(a_Param, delim);
	}

	modifiedParamArr.Insert(modifiedParamArr.Length, 1);
	modifiedParamArr[modifiedParamArr.Length-1] = a_Param;

	bIsUsa = GetLanguageCustom() == 1; //branch GD35_0828 2013-11-14 luciper3 - 커스텀 뺀 함수가 있긴한데.. 그거쓰면 크래쉬남 리턴타입문제인듯해서 int리턴하는걸로 바꿈.
	for ( i = 0 ; i < modifiedParamArr.Length ; i++ )
	{	
		//branch GD35_0828 2013-11-13 luciper3 - 미국에서 지엠명령어 대소문 구분없이 사용가능하도록 수정해달라고함.
		if( bIsUsa )
		{
			strTemp1 = Caps(modifiedString);
			strTemp2 = Caps(modifiedParamArr[i]);
			if ( InStr( strTemp1, strTemp2 ) == -1 && modifiedParamArr[i] != " " ) 
				return -1;
		}
		else if ( InStr( modifiedString, modifiedParamArr[i] ) == -1 && modifiedParamArr[i] != " " )
		{
			return -1;
		}
		//end of branch
	}
	*/

	return 1;
}


function OnDBClickListCtrlRecord( string ListCtrlID)
{
	summon(1);
}

function Summon(Int64 cnt)
{
	local LVDataRecord record;
	record.LVDataList.Length = 2;

	//if ( !bSummon )  return; 

	if( GetSelectedListCtrlItem( record ) )
	{
		if ( record.LVDataList[1].szData != "")
		{
			switch( curListType )
			{
				case LISTTYPE_ITEM:
				case LISTTYPE_NPC:
					ProcessChatMessage("//summon"@record.LVDataList[1].szData @ cnt, 0);
					break;
				case LISTTYPE_SKILL:				
					ProcessChatMessage("//setskill"@record.LVDataList[1].szData @ record.LVDataList[1].nReserved1 @ 0, 0);
					break;
				case LISTTYPE_CLASS:				
					ProcessChatMessage("//setclass" @record.LVDataList[1].szData, 0);
					break;
				case LISTTYPE_QUEST:
					ProcessChatMessage("//setquest"@record.LVDataList[1].szData @ 0, 0);
					break;
				case LISTTYPE_SYSTEMSTRING:
					ProcessChatMessage("///ss"@record.LVDataList[1].szData, 0);
					break;
				case LISTTYPE_SYSTEMMESSAGE:
					ProcessChatMessage("///sm"@record.LVDataList[1].szData, 0);
					break;
			}
		}
	}
}

function OnClickListCtrlRecord( String strID )
{
	m_hBtnSummon.EnableWindow();
}

function OnClickButton( string strID )
{
	//local string summonCnt;

	switch( strID )
	{
	case "btnSummon":
		switch ( curListType )
		{
			case LISTTYPE_ITEM:			
				openDialogNumpad(1);
				break;
			case LISTTYPE_QUEST:					
				summon(1);
				break;
			case LISTTYPE_NPC:					
				openDialogNumpad(1);
				break;
			case LISTTYPE_SKILL:		
				summon(1);
				break;	
			case LISTTYPE_SYSTEMSTRING:			
				summon(1);
				break;
			case LISTTYPE_SYSTEMMESSAGE :			
				summon(1);
				break;
		}			
		//summonCnt=m_hEdSummonCnt.GetString();
		//Summon(int(summonCnt));
		break;
	case "btnFind":
		handleFind();		
		break;
	}
}

function handleFind()
{
	local string EditBoxString;
	EditBoxString = m_hEditBox.GetString();	
	ShowList(EditBoxString , curListType );
}



function bool GetSelectedListCtrlItem(out LVDataRecord record)
{
	local int index;

	index = m_hFindTreeList.GetSelectedIndex();
	if( index >= 0 )
	{
		m_hFindTreeList.GetRec(index, record);
		return true;
	}
	return false;
}

// List related operations
function ClearList()
{
	m_hFindTreeList.DeleteAllItem();
	m_hFindTreeList.ClearTooltip();
	m_hFindTreeList.SetTooltipType("");
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( m_WindowName ).HideWindow();
}

/** Desc : 다이얼로그 윈도우를 열고 OK 버튼 누른 경우 */
function HandleDialogOK()
{	
	//local ItemInfo scInfo;
	local INT64 inputNum;
	local int id;

	if(!class'UICommonAPI'.static.DialogIsOwnedBy( string(Self) ))	return;	

	id = class'UICommonAPI'.static.DialogGetID();
	
	if ( id == ASK_SUMMON_NUMBER )
	{
		inputNum = INT64( class'UICommonAPI'.static.DialogGetString() );
		//summonCnt=m_hEdSummonCnt.GetString();
		Summon( inputNum );		
	}	
} 

function openDialogNumpad(int64 num)
{
	// Ask price
	class'UICommonAPI'.static.DialogSetID( ASK_SUMMON_NUMBER );
	//DialogSetReservedItemID( info.ID );				// ServerID
	//DialogSetReservedInt3( int(bAllItem) );		// 전체이동이면 개수 묻는 단계를 생략한다
	class'UICommonAPI'.static.DialogSetEditType("number");
	class'UICommonAPI'.static.DialogSetParamInt64( num );
	class'UICommonAPI'.static.DialogSetDefaultOK();
	class'UICommonAPI'.static.DialogShow(DialogModalType_Modalless, DialogType_NumberPad, getSystemString( 1543 ) @ getSystemString( 192 ), string(Self) );	
}



/** OnKeyUp */
function OnKeyUp( WindowHandle a_WindowHandle, EInputKey nKey )
{
	// 키보드 누름으로 체크 	
	if ( m_hEditBox.IsFocused() )
	{	
		// txtPath
		if (nKey == IK_Enter) 
		{
			// 키보드 입력은 아무것도 입력 하지 않았을때 전체 검색을 허용하지 않는다.
			// 실수로 자꾸 누르는 경우가 있어서..
			if (trim( m_hEditBox.GetString()) != "") handleFind();
		}
	}
}
defaultproperties
{
    m_WindowName="GMFindTreeWnd"
}
