class MacroEditWnd extends UICommonAPI;

var string m_WindowName;
const MACRO_MAX_COUNT = 48;
const MACROCOMMAND_MAX_COUNT = 12;
const MACROICON_MAX_COUNT = 104;

const DEFAULT_MACROICON_ID = 105; // 2015-11-04 범용 매크로 아이콘 번호

const MACRO_ICONANME = "L2UI.MacroWnd.MACRO_ICON";

var bool	m_bShow;
var int		m_CurIconNum;
var int     m_CurSkillID;
var ItemID	m_CurMacroItemID;
var string  m_CurFocusedBoxName;
var int     m_CurFocusedBoxIndex;

//var WindowHandle	m_MacroEditWnd;
var WindowHandle    MacroEditWnd_Input;
var WindowHandle    MacroEditWnd_IconList;
var WindowHandle    MacroListWnd;
var WindowHandle    Me;


var ButtonHandle m_EditUpButton;
var ButtonHandle m_EditDownButton;

var MultiEditBoxHandle MacroDesc_MultiEdit;

function OnRegisterEvent()
{
	RegisterEvent( EV_DialogOK );
	
	RegisterEvent( EV_MacroShowEditWnd );
	RegisterEvent( EV_MacroDeleted );

	RegisterEvent( EV_Restart );

	RegisterEvent( EV_Paste );
}

function OnLoad()
{
	SetClosingOnESC();
	//if(CREATE_ON_DEMAND==0)
	
	OnRegisterEvent();

	Me = GetWindowHandle("MacroEditWnd");
	//m_MacroEditWnd= GetWindowHandle("MacroEditWnd.areaEdit");
	MacroEditWnd_Input = GetWindowHandle("MacroEditWnd.MacroEditWnd_Input");
	MacroEditWnd_IconList = GetWindowHandle("MacroEditWnd.MacroEditWnd_IconList");
	MacroListWnd = GetWindowHandle("MacroListWnd");

	m_EditUpButton = GetButtonHandle("MacroEditWnd.BtnEditUp");
	m_EditDownButton = GetButtonHandle("MacroEditWnd.BtnEditDown");

	MacroDesc_MultiEdit = GetMultiEditBoxHandle("MacroEditWnd.MacroDesc_MultiEdit");

	m_bShow = false;
	m_CurIconNum = 1;
	ClearItemID(m_CurMacroItemID);
	
	InitTabOrder();

	// 기본 아이콘 초기화
	class'UIAPI_TEXTURECTRL'.static.SetTexture( "MacroEditWnd.texMacro", MACRO_ICONANME $ DEFAULT_MACROICON_ID );

	//초기화
	Clear();

	//HandleMacroList();	
}

function OnShow()
{
	HandleMacroList();

	if (MacroEditWnd_IconList.IsShowWindow())
	{
		swapWindow();
	}

	m_bShow = true;	
}

function OnHide()
{
	m_bShow = false;	
}

// 같은 아이콘이 있는지 체크
function bool hasIconInArray(string targetIconName)
{
	local int idx, itemLen;
	local bool flag;
	local ItemInfo ItemInfo;
	
	itemLen = GetItemWindowHandle("MacroEditWnd.MacroEditWnd_IconList.MacroItem").GetItemNum();

	for(idx = 0; idx < itemLen; idx++)
	{
		GetItemWindowHandle("MacroEditWnd.MacroEditWnd_IconList.MacroItem").GetItem(idx, ItemInfo);

		if(targetIconName == ItemInfo.IconName)
		{
			flag = true;
			break;
		}
	}

	return flag;
}

function HandleMacroList( )
{
	local int Idx;
	local ItemInfo	infItem, nullItemInfo;
	local array<ItemId> mySkillIDArray;
	local string iconStr;
	local SkillInfo tempSkillInfo;

	//class'UIAPI_TEXTURECTRL'.static.SetTexture( "MacroEditWnd.texMacro", MACRO_ICONANME $ DEFAULT_MACROICON_ID );

	//// 기본 ? 아이콘 
	////class'UIAPI_TEXTURECTRL'.static.SetTexture( "MacroEditWnd.texMacro", "L2UI_CT1.Icon.Icon_MacroDF" );

	////초기화
	//Clear();

	GetItemWindowHandle("MacroEditWnd.MacroItem").Clear();

	// 범용 매크로 ? 아이콘 추가
	infItem.IconName = MACRO_ICONANME $ DEFAULT_MACROICON_ID;
	infItem.ItemSubType = int(EShortCutItemType.SCIT_MACRO);
	class'UIAPI_ITEMWINDOW'.static.AddItem("MacroEditWnd.MacroEditWnd_IconList.MacroItem", infItem);

	// 매크로 아이콘 추가
	for (Idx=0; Idx < 7; Idx++)
	{	
		infItem.IconName = MACRO_ICONANME $ (Idx + 1);
		infItem.ItemSubType = int(EShortCutItemType.SCIT_MACRO);
		
		//MacroItem에 추가
		class'UIAPI_ITEMWINDOW'.static.AddItem("MacroEditWnd.MacroEditWnd_IconList.MacroItem", infItem);
	}	
		
	// 내 스킬 아이콘 추가
	class'UIDATA_SKILL'.static.GetCurrentSkillList(mySkillIDArray);

	for(idx = 0; Idx < mySkillIDArray.Length; idx++)
	{
		// 스킬 정보를 읽고
		if(GetSkillInfo(mySkillIDArray[idx].ClassID, 1, 0, tempSkillInfo))
		{
			infItem = nullItemInfo;
			// 액티브 스킬 이고, 얼터 스킬이 아닌 경우 추가
			if(isActiveSkill(tempSkillInfo)  && tempSkillInfo.MagicType != EMixMagicType.MIXMAGICTYPE_ALTERSKILL)
			{
//				Debug("mySkillIDArray:" @ mySkillIDArray[idx].ClassID);
				iconStr = class'UIDATA_SKILL'.static.GetIconName(mySkillIDArray[idx], 1, 0);

				//Debug("----------------------------------------------------------------");
				//Debug("Skill Icon:" @ tempSkillInfo.SkillName);
				//Debug("Skill Icon:" @ iconStr);
				//Debug("Skill IconType:" @ tempSkillInfo.IconType);
				//Debug("Skill OperateType:" @ tempSkillInfo.OperateType);

				if (iconStr != "")
				{
					// 같은 아이콘이 없다면 넣는다.
					if (!hasIconInArray(iconStr))
					{
						infItem.Name = tempSkillInfo.SkillName;
						infItem.IconName = iconStr;
						infItem.ItemSubType = int(EShortCutItemType.SCIT_MACRO);

						// 임시로 스킬 ID를 기억 시킨다.
						infItem.Level = mySkillIDArray[idx].ClassID;
						class'UIAPI_ITEMWINDOW'.static.AddItem("MacroEditWnd.MacroEditWnd_IconList.MacroItem", infItem);
					}
				}
			}
		}
	}

	// 액션 아이콘 추가 7~ 64 까지가 액션 아이콘
	for (Idx = 7; Idx < 64; Idx++)
	{	
		infItem = nullItemInfo;
		infItem.IconName = MACRO_ICONANME $ (Idx + 1);
		infItem.ItemSubType = int(EShortCutItemType.SCIT_MACRO);
		
		//MacroItem에 추가
		class'UIAPI_ITEMWINDOW'.static.AddItem("MacroEditWnd.MacroEditWnd_IconList.MacroItem", infItem);
	}	

	// 아이템 윈도우 스크롤을 바로 할 수 있게..
	//GetItemWindowHandle("MacroEditWnd.MacroItem").SetFocus();
	// MacroEditWnd_IconList.SetFocus();
}

function OnClickButton( string strID )
{	
	// Debug("strID" @ strID);

	switch( strID )
	{
		//case "btnInfo":		
		//	OnClickInfo();
		//	break;
		case "btnHelp":
			OnClickHelp();
			break;
		case "btnCancel":
			OnClickCancel();
			break;
	/*	case "btnLeft":
			OnClickLeft();
			break;
		case "btnRight":
			OnClickRight();
			break;*/
		case "btnSave":
			OnClickSave();
			break;
		//case "texMacro":		
		case "btnIconChange":
			onClickIconChange();
			break;

		//추가기능  스왑, 삽입, 삭제
		case "BtnEditUp":
			LineSwap("up");
			break;
		case "BtnEditDown":
			LineSwap("down");
			break;
		case "BtnEditdel":
			CurClearLine();
			break;
		case "BtnEditAdd":
			CurInsertLine();
			break;

		case "Preset_Btn":
			toggleWindow("MacroPresetWnd", true);
			break;

		case "MacroCopy_Btn" :
			macroTotalCopy();
			break;

		case "MacroPaste_Btn" :
			macroTotalPaste();
			break;

		case "BtnEditAlldel" :
			clearAllMacrocommandEditbox();
			break;
	}
}

// 매크로 전체 카피
function macroTotalCopy()
{
	local int idx;
	local string commandString;

	// 각 0~11 에디터 박스 스트링을 엔터 값으로 구분해서 하나의 스트링으로 만든다.
	for(idx = 0; idx < MACROCOMMAND_MAX_COUNT; idx++)
	{
		if (GetEditBoxHandle("MacroEditWnd.txtEdit" $ idx).GetString() != "")
		{
			commandString = commandString $ GetEditBoxHandle("MacroEditWnd.txtEdit" $ idx).GetString() $ Chr(13);
		}
	}

	// 마지막 \n 코드 삭제
	if (Len(commandString) > 0)
	{
		commandString = Left(commandString, Len(commandString) - 1);
	}

	Debug("클립 보드에 카피 되었습니다.:" @ commandString);
	// 4399    매크로 내용이 클립보드로 복사되었습니다
	AddSystemMessage(4399);

	ClipboardCopy(commandString);
}
	
// 매크로 전체 카피
function macroTotalPaste()
{
	pastByClipboard(true);
}

function onClickIconChange()
{
	swapWindow();
}

function swapWindow()
{
	local ButtonHandle btnIconChange ;

	btnIconChange = GetButtonHandle("MacroEditWnd.btnIconChange");

	if (MacroEditWnd_Input.IsShowWindow()) 
	{   
		btnIconChange.SetButtonName( 2817 );//매크로 내용
		MacroEditWnd_Input.HideWindow();
		MacroEditWnd_IconList.ShowWindow();

		// 아이템 윈도우 스크롤을 바로 할 수 있게..
		MacroEditWnd_IconList.SetFocus();
	
	}
	else 
	{
		btnIconChange.SetButtonName( 2815 );//아이콘 변경
		MacroEditWnd_Input.ShowWindow();
		MacroEditWnd_IconList.HideWindow();
	}
}

function OnClickItem( string strID, int index )
{
	local int strLen;
	local ItemInfo 	infItem;
	
	if (strID == "MacroItem" && index>-1)
	{		
		if (class'UIAPI_ITEMWINDOW'.static.GetItem("MacroEditWnd.MacroItem", index, infItem))
		{	
			class'UIAPI_TEXTURECTRL'.static.SetTexture( "MacroEditWnd.texMacro", infItem.IconName);

			// infItem.Level 은 임시로 스킬 아이디를 넣어둔 공간. 0이 아니면 스킬 아이디, 스킬아이콘을 사용한다.
			if (infItem.Level > 0)
			{
				m_CurSkillID = infItem.Level;
			}
			else
			{
				m_CurSkillID = 0;
				strLen = Len(infItem.IconName) - Len( MACRO_ICONANME ) ;
				m_CurIconNum = int(Right(infItem.IconName, strLen));
			}

			Debug("스킬 Name" @ infItem.Name);
			Debug("스킬 ID" @ infItem.Level);
			Debug("m_CurIconNum : " @ m_CurIconNum);


			///m_CurIconNum = index + 1;
			//class'UIAPI_TEXTURECTRL'.static.SetTexture( "MacroEditWnd.texMacro", MACRO_ICONANME $ ( m_CurIconNum ) );						

			swapWindow();
		}
	}
}

function OnEvent(int Event_ID, String param)
{
	if (Event_ID == EV_MacroShowEditWnd)
	{
		HandleMacroShowEditWnd(param);
	}
	else if (Event_ID == EV_MacroDeleted)
	{
		HandleMacroDeleted(param);		
	}
	else if (Event_ID == EV_DialogOK)
	{
		if (DialogIsMine())
		{
			ProcessInsertLine();
		}
	}
	else if (Event_ID == EV_DialogCancel)
	{	
	}
	else if (Event_ID == EV_Paste)
	{	
		pastByClipboard(true);
	}
	else if (Event_ID == EV_Restart)
	{
		Clear();
	}
}

// 외부에서 매크로 정보를 갱신 할떄 사용, 프리셋에서..
function setEditMacroInfo(string macroName, string IconTextureName)
{
	local int strLen;

	// 아이콘이름
	GetEditBoxHandle("MacroEditWnd.txtName").SetString(macroName);

	//짧은 이름
	GetTextBoxHandle("MacroEditWnd.txtMacroName").SetText(Left(macroName, 4));
 
	// 프리셋에서는 스킬 아이콘 사용 못한다. 
	m_CurSkillID = 0;

	strLen = Len(IconTextureName) - Len( MACRO_ICONANME ) ;
	m_CurIconNum = int(Right(IconTextureName, strLen));

	// 아이콘 갱신 
	class'UIAPI_TEXTURECTRL'.static.SetTexture( "MacroEditWnd.texMacro", MACRO_ICONANME $ m_CurIconNum );
}

function pastByClipboard(bool bLastEditBoxFocus)
{
	local string clipboardstr;
	local int idx;

	clipboardstr = clipboardpaste();

	// debug("m_curfocusedboxname"@ m_curfocusedboxname);
	// debug(":gettextboxhandle(m_curfocusedboxname).isfocused()" @ GetEditBoxHandle(m_curfocusedboxname).isfocused());
	// Debug("clipboardstr" @ clipboardstr);
	if(len(clipboardstr) > 0)
	{
		if(GetEditBoxHandle(m_curfocusedboxname).IsFocused())
		{   
			idx = GetCurTextBoxIndex(m_CurFocusedBoxName);
			pasteMacroEdit(idx, clipboardstr, bLastEditBoxFocus);
			Debug("현재 위치 부터" @ idx);
		}
		else
		{
			// 포커스가 없다면 전체 첫번째 줄 부터 붙이기
			pasteMacroEdit(0, clipboardstr, bLastEditBoxFocus);
			Debug("첫줄 부터");
		}
	}
}

// 에디터 박스 0~11 라인, 붙이기 bLastEditBoxFocus는 멀티라인 붙이기 일때 마지막에 포커스 주기
// onelineOverwrite 한줄 붙이기를 할때다 지우기
function pasteMacroEdit(int nEditLine, string commandStr, optional bool bLastEditBoxFocus, optional bool onelineOverwrite)
{
	local array<string> commandArray;
	local int idx;
	local string pasteString;

	//Split(commandStr, "\n", commandArray);

	// Debug("commandStr : " @ commandStr);
	Split(commandStr, Chr(13), commandArray);

	Debug("Length : " @ commandArray.Length);
	
	// \n 엔터 값이 있나? 있으면 멀티라인..
	if(InStr( commandStr ,Chr(13) ) != -1)
	{
		for (idx = 0; idx < commandArray.Length; idx++)
		{
			if (nEditLine + idx < MACROCOMMAND_MAX_COUNT)
			{
				pasteString = deleteEnter(commandArray[idx]);

				class'UIAPI_EDITBOX'.static.SetString( "MacroEditWnd.txtEdit" $ (nEditLine + idx), pasteString);

				Debug("여러줄  넣기" @ nEditLine + idx @ ": " @ commandArray[idx]);
				Debug("여러줄  pasteString:" @ nEditLine + idx @ ": " @ pasteString);

				if (bLastEditBoxFocus)
				{
					// 붙이기 마지막 다음 칸에 포커스 주기
					if (nEditLine + idx < 11)					
						GetEditBoxHandle("MacroEditWnd.txtEdit" $ (nEditLine + idx + 1)).SetFocus();
				}
			}
		}
	}
	// 한줄 넣기
	else
	{
		// 스킬이나 액션등을 드래그 하여 넣은 경우
		if (onelineOverwrite)
		{
			GetEditBoxHandle("MacroEditWnd.txtEdit" $ (nEditLine)).SetString(commandStr);
		}
		else
		{
			Debug("한줄 넣기" @ commandStr);
			GetEditBoxHandle("MacroEditWnd.txtEdit" $ (nEditLine)).DeleteClipBoard();
			GetEditBoxHandle("MacroEditWnd.txtEdit" $ (nEditLine)).AddString(commandStr);
		}

	}
}

function InitTabOrder()
{
	local int idx;
	
	class'UIAPI_WINDOW'.static.SetTabOrder("MacroEditWnd", "MacroEditWnd.txtName", "MacroEditWnd.MacroDesc_MultiEdit");
	class'UIAPI_WINDOW'.static.SetTabOrder("MacroEditWnd.txtName", "MacroEditWnd.MacroDesc_MultiEdit", "MacroEditWnd");
	class'UIAPI_WINDOW'.static.SetTabOrder("MacroEditWnd.MacroDesc_MultiEdit", "MacroEditWnd.txtEdit0", "MacroEditWnd.txtName");

	for (idx=0; idx<MACROCOMMAND_MAX_COUNT; idx++)
	{
		if (idx==0)
			class'UIAPI_WINDOW'.static.SetTabOrder("MacroEditWnd.txtEdit0", "MacroEditWnd.txtEdit1", "MacroEditWnd.MacroDesc_MultiEdit");
		else if (idx==MACROCOMMAND_MAX_COUNT-1)
			class'UIAPI_WINDOW'.static.SetTabOrder("MacroEditWnd.txtEdit11", "MacroEditWnd.txtName", "MacroEditWnd.txtEdit10");
		else
			class'UIAPI_WINDOW'.static.SetTabOrder("MacroEditWnd.txtEdit" $ idx, "MacroEditWnd.txtEdit" $ idx+1, "MacroEditWnd.txtEdit" $ idx-1);
	}
}

//////////////////////////////////////////////////////////////////////////////////
//도움말 버튼
function OnClickHelp()
{
	local string strParam;
	ParamAdd(strParam, "FilePath", "..\\L2text\\help_general_control_macro.htm");	
	ExecuteEvent(EV_ShowHelp, strParam);
}

//////////////////////////////////////////////////////////////////////////////////
//취소 버튼
function OnClickCancel()
{
	class'UIAPI_WINDOW'.static.HideWindow("MacroEditWnd");
}


//////////////////////////////////////////////////////////////////////////////////
//저장 버튼
function OnClickSave()
{
	SaveMacro();
}

//////////////////////////////////////////////////////////////////////////////////
// Drag & Drop
function OnDropItem( String strID, ItemInfo infItem, int x, int y )
{
	local int nEditLine;
	//local array<String> commandArray;

	if (Len(strID)<1)
		return;
		
	if (Left(strID, 7) != "txtEdit")
		return;
		
	class'UIAPI_EDITBOX'.static.SetHighLight( "MacroEditWnd." $ strID, FALSE);

	nEditLine = int(Mid(strID, Len("txtEdit"), Len(strID)));

	// 붙여 넣기
	pasteMacroEdit(nEditLine, infItem.MacroCommand, false, true);
}

function OnDragItemStart( String strID, ItemInfo infItem )
{
	if (Len(strID)<1)
		return;
		
	if (Left(strID, 7) != "txtEdit")
		return;
		
	class'UIAPI_EDITBOX'.static.SetHighLight( "MacroEditWnd." $ strID, TRUE);
}

function OnDragItemEnd( String strID )
{
	if (Len(strID)<1)
		return;
		
	if (Left(strID, 7) != "txtEdit")
		return;
		
	class'UIAPI_EDITBOX'.static.SetHighLight( "MacroEditWnd." $ strID, FALSE);
}

//////////////////////////////////////////////////////////////////////////////////
// Macro Icon

function OnChangeEditBox( String strID )
{
	switch( strID )
	{
		case "txtName" :
			 UpdateIconName();
 			 break;
	}
}

function UpdateIcon()
{
	local string iconStr;

	// 스킬아이콘을 사용 했다면..
	if (m_CurSkillID > 0)
	{
		iconStr = class'UIDATA_SKILL'.static.GetIconName(GetItemID(m_CurSkillID), 1, 0);
		class'UIAPI_TEXTURECTRL'.static.SetTexture( "MacroEditWnd.texMacro", iconStr);
	}
	// 기존 Macro Icon
	else
	{
		class'UIAPI_TEXTURECTRL'.static.SetTexture( "MacroEditWnd.texMacro", MACRO_ICONANME $ m_CurIconNum);
	}
}

function UpdateIconName()
{
	local string strShortName;
	
	strShortName = Left(class'UIAPI_EDITBOX'.static.GetString( "MacroEditWnd.txtName"), 4 );

	//Debug("strShortName : " @ strShortName);
	class'UIAPI_TEXTBOX'.static.SetText( "MacroEditWnd.txtMacroName", strShortName);
}

//////////////////////////////////////////////////////////////////////////////////
// Clear
function Clear()
{
	//m_CurIconNum = 1
	m_CurSkillID = 0;
	m_CurIconNum = DEFAULT_MACROICON_ID;
	
	class'UIAPI_EDITBOX'.static.SetString( "MacroEditWnd.txtName", "");
	//class'UIAPI_EDITBOX'.static.SetString( "MacroEditWnd.txtShortName", "");
	MacroDesc_MultiEdit.SetString("");

	clearAllMacrocommandEditbox();
	UpdateIcon();
	UpdateIconName();
//	m_MacroEditWnd.SetScrollPosition(0); // 스크롤바 초기화
}

// 매크로 박스를 삭제한다.
function clearAllMacrocommandEditbox()
{
	local int idx;

	for (idx=0; idx<MACROCOMMAND_MAX_COUNT; idx++)
	{
		class'UIAPI_EDITBOX'.static.SetString( "MacroEditWnd.txtEdit" $ idx, "");
	}
}

//현재 보여지고 있는 매크로가 삭제되었다면 Hide시킨다.
function HandleMacroDeleted(string param)
{
	local ItemID cID;
	ParseItemID(param, cID);
	
	if(m_bShow)
	{
		Clear();
		ClearItemID(m_CurMacroItemID);
	}
}

function HandleMacroShowEditWnd(string param)
{
	local int MacroCount;
	local color TextColor;
	
	Clear();
	ClearItemID(m_CurMacroItemID);
	
	Debug("param" @ param);

	//편집모드
	if (ParseItemID(param, m_CurMacroItemID))
	{
		SetMacroID(m_CurMacroItemID);
		if (!m_bShow)
		{
			PlayConsoleSound(IFST_WINDOW_OPEN);
			class'UIAPI_WINDOW'.static.ShowWindow("MacroEditWnd");			
		}

		// 새로 열렸을때 에디터 첫번째 줄에 포커싱 했다가, 제목 쪽으로 다시포커싱
		// 이렇게 하는 이유는 붙이기 버튼을 눌렀을때 창이 열리면 첫번째 에디터박스에 포커싱이 가 있도록 하기 위해서
		GetEditBoxHandle("MacroEditWnd.txtEdit0").SetFocus();
		class'UIAPI_WINDOW'.static.SetFocus("MacroEditWnd.txtName");
	}
	//추가모드
	else
	{
		if (m_bShow)
		{
			//PlayConsoleSound(IFST_WINDOW_CLOSE);
			//class'UIAPI_WINDOW'.static.HideWindow("MacroEditWnd");
		}
		else
		{
			//Check Macro Count
			MacroCount = class'UIDATA_MACRO'.static.GetMacroCount();
			if (MacroCount>=MACRO_MAX_COUNT)
			{
				TextColor.R = 176;
				TextColor.G = 155;
				TextColor.B = 121;
				TextColor.A = 255;
				DialogShow(DialogModalType_Modalless,DialogType_Notice, GetSystemMessage(797), string(Self));
				DialogSetID(0);	
				//AddSystemMessage(GetSystemMessage(797), TextColor);
				return;
			}
			
			PlayConsoleSound(IFST_WINDOW_OPEN);
			class'UIAPI_WINDOW'.static.ShowWindow("MacroEditWnd");
			
			// 새로 열렸을때 에디터 첫번째 줄에 포커싱 했다가, 제목 쪽으로 다시포커싱
			// 이렇게 하는 이유는 붙이기 버튼을 눌렀을때 창이 열리면 첫번째 에디터박스에 포커싱이 가 있도록 하기 위해서
			GetEditBoxHandle("MacroEditWnd.txtEdit0").SetFocus();			
			class'UIAPI_WINDOW'.static.SetFocus("MacroEditWnd.txtName");
		}
	}
}

//////////////////////////////////////////////////////////////////////////////////
// 해당 MacroID로 화면 표시
function SetMacroID(ItemID cID)
{
	local int idx;
	local MacroInfo info;
	local int strLen;
	
	if (!IsValidItemID(cID))
		return;
		
	if (class'UIDATA_MACRO'.static.GetMacroInfo(cID, info))
	{
		//이름
		class'UIAPI_EDITBOX'.static.SetString( "MacroEditWnd.txtName", info.Name);
		//단축이름
		//class'UIAPI_EDITBOX'.static.SetString( "MacroEditWnd.txtShortName", info.IconName);
		//아이콘
		
		if (info.IconSkillId > 0)
		{
			m_CurSkillID = info.IconSkillId;
			m_CurIconNum = DEFAULT_MACROICON_ID;
		}
		else
		{
			strLen = Len(info.IconTextureName) - Len( MACRO_ICONANME ) ;			
			m_CurIconNum = int(Right(info.IconTextureName, strLen));
		}

		//Debug("strLen" @ strLen @ m_CurIconNum @ info.IconTextureName @ info.IconTextureName) ; 
		if (m_CurIconNum<1)
			m_CurIconNum = DEFAULT_MACROICON_ID;
		UpdateIcon();

		//설명
		MacroDesc_MultiEdit.SetString(info.Description);

		//커맨드12개
		for (idx=0; idx<MACROCOMMAND_MAX_COUNT; idx++)
		{
			class'UIAPI_EDITBOX'.static.SetString( "MacroEditWnd.txtEdit" $ idx, info.CommandList[idx]);
		}
	}
}

//////////////////////////////////////////////////////////////////////////////////
// 매크로 저장
function SaveMacro()
{
	local int idx, saveIdx;
	
	local string		Name;
	//local string		IconName;
	local string		Description;
	local string		Command;
	local array<string> CommandList;
	
	Name = class'UIAPI_EDITBOX'.static.GetString( "MacroEditWnd.txtName");
	//IconName = class'UIAPI_EDITBOX'.static.GetString( "MacroEditWnd.txtShortName");
	Description = MacroDesc_MultiEdit.GetString();

	for (idx=0; idx<MACROCOMMAND_MAX_COUNT; idx++)
	{
		Command = class'UIAPI_EDITBOX'.static.GetString( "MacroEditWnd.txtEdit" $ idx);
		if(Command != "")
		{
			CommandList.Insert(CommandList.Length, 1);
			CommandList[CommandList.Length-1] = Command;
		}
	}
	
	//나머지 칸을 채워줌
	for (saveIdx = CommandList.Length; saveIdx<MACROCOMMAND_MAX_COUNT; saveIdx++)
	{
		CommandList.Insert(CommandList.Length, 1);
		CommandList[CommandList.Length-1] = "";
	}
		
	//if (class'MacroAPI'.static.RequestMakeMacro(m_CurMacroItemID, Name, GetTextureHandle("MacroEditWnd.texMacro").GetTextureName(), m_CurIconNum-1, 0, Description, CommandList))

	Debug("------> Call RequestMakeMacro,  m_CurIconNum: " @ m_CurIconNum - 1);

	if (class'MacroAPI'.static.RequestMakeMacro(m_CurMacroItemID, Name, Left(Name, 4), m_CurIconNum - 1, m_CurSkillID, Description, CommandList))
	//if (class'MacroAPI'.static.RequestMakeMacro(m_CurMacroItemID, Name, IconName, m_CurIconNum-1, Description, CommandList))
	{
		//MacroListWnd.ShowWindow();
		//class'UIAPI_WINDOW'.static.SetAnchor( "MacroListWnd", "MacroEditWnd", "TopLeft", "TopLeft", 0, 0 );
		class'UIAPI_WINDOW'.static.HideWindow("MacroEditWnd");
	}	
}

/*
 *매크로 추가기능 구현
 *텍스트를 위, 아래로 이동시켜 편집할 수 있는 기능
 *라인 삽입, 삭제 기능
 *저장 시 빈칸 알아서 삭제 후 저장해주는 기능
 */

//현재 라인을 빈칸으로 만들고 밑에서부터 당겨올림.
function CurClearLine()
{
	local int idx, i;
	local string nextString;
	local string curString;
	local array<string> list;

	idx = GetCurTextBoxIndex(m_CurFocusedBoxName);
	list.Remove(0, list.Length);

	//라인을 빈칸으로 만든다.
	class'UIAPI_EDITBOX'.static.SetString( "MacroEditWnd.txtEdit" $ (idx), "");

	for (i = idx + 1; i < MACROCOMMAND_MAX_COUNT; i++)
	{
		curString = class'UIAPI_EDITBOX'.static.GetString( "MacroEditWnd.txtEdit" $ i);
		class'UIAPI_EDITBOX'.static.SetString( "MacroEditWnd.txtEdit" $ (i), "");
		list.Insert(list.Length, 1);
		list[list.Length-1] = curString;
	}

	for (i = idx; i < list.Length+idx; i++)
	{	
		nextString = list[i-idx];		
		class'UIAPI_EDITBOX'.static.SetString( "MacroEditWnd.txtEdit" $ (i), nextString);
	}

	class'UIAPI_WINDOW'.static.SetFocus("MacroEditWnd.txtEdit" $ idx);
}


// 매크로 0~11 에디터 박스를 모두 지운다.
function removeAllEditBox()
{
	local int i;

	for (i = 0; i < MACROCOMMAND_MAX_COUNT; i++)
	{
		class'UIAPI_EDITBOX'.static.SetString( "MacroEditWnd.txtEdit" $ i, "");
	}
}

//현재라인을 빈칸으로 만들고 한칸씩 밑으로 내림
function CurInsertLine()
{
	m_CurFocusedBoxIndex = GetCurTextBoxIndex(m_CurFocusedBoxName);
	//마지막 라인이 빈칸이 아니면 경고를 띄우고 빠져나옴
	if(class'UIAPI_EDITBOX'.static.GetString( "MacroEditWnd.txtEdit" $ MACROCOMMAND_MAX_COUNT-1) != "")
	{
		DialogShow(DialogModalType_Modal,DialogType_OKCancel, GetSystemMessage(4208), string(Self));
		DialogSetID(0);
		return;
	}
	ProcessInsertLine();
}

function ProcessInsertLine()
{
	local int idx, i, id;
	local string nextString;
	local string curString;

	local array<string> list;
	
	idx = m_CurFocusedBoxIndex;

	//선택된 칸의 인덱스부터 끝까지 배열에 저장한다.
	for (i = idx; i < MACROCOMMAND_MAX_COUNT; i++)
	{
		curString = class'UIAPI_EDITBOX'.static.GetString( "MacroEditWnd.txtEdit" $ i);
		list.Insert(list.Length, 1);
		list[list.Length-1] = curString;
	}

	for (i = idx; i < MACROCOMMAND_MAX_COUNT; i++)
	{
		id = i - idx;
		if(id >= 0)
		{
			nextString = list[id];
			
			if((i+1) < MACROCOMMAND_MAX_COUNT)
			{
				class'UIAPI_EDITBOX'.static.SetString( "MacroEditWnd.txtEdit" $ (i+1), nextString);
			}
		}
	}

	//라인을 빈칸으로 만든다.
	class'UIAPI_EDITBOX'.static.SetString( "MacroEditWnd.txtEdit" $ (idx), "");
	class'UIAPI_WINDOW'.static.SetFocus("MacroEditWnd.txtEdit" $ idx);
}

function LineSwap(string strType)
{	
	local int idx;

	idx = GetCurTextBoxIndex(m_CurFocusedBoxName);

	if(strType == "up")
	{
		// 현재 선택한 인덱스가 최대 라인 개수보다 작고 -1보다 클 때만 위에꺼랑 스왑 함
		if(idx > 0)
		{
			SwapString(idx, idx-1);
		}
	}
	else if(strType == "down")
	{
		if(idx < MACROCOMMAND_MAX_COUNT-1)
		{
			SwapString(idx, idx+1);
		}
	}
}

//에디트박스의 first 인덱스와 last 인덱스 글씨를 바꿔준다aasd
function SwapString(int firstID, int lastID)
{
	local string lastString;
	local string curString;

	curString = class'UIAPI_EDITBOX'.static.GetString( "MacroEditWnd.txtEdit" $ firstID);
	lastString = class'UIAPI_EDITBOX'.static.GetString( "MacroEditWnd.txtEdit" $ lastID);

	class'UIAPI_EDITBOX'.static.SetString( "MacroEditWnd.txtEdit" $ firstID, lastString);
	class'UIAPI_EDITBOX'.static.SetString( "MacroEditWnd.txtEdit" $ lastID, curString);

	//마지막 인덱스에 포커스 준다.
	class'UIAPI_WINDOW'.static.SetFocus("MacroEditWnd.txtEdit" $ lastID);
}


/*
 * 포커스된 텍스트박스의 인덱스를 리턴한다
 * txtEdit0~11
 */
function int GetCurTextBoxIndex(string boxName)
{
	local string str;
	local int idx;
	if(Left(boxName, 7) == "txtEdit")
	{
		str = Right(boxName, 2);
		
		//0~9 까지
		if( Left(str, 1) == "t")
		{
			idx = int(Right(boxName, 1));
		}
		//10~12 까지
		else
		{
			idx = int(Right(str, 2));
		}
	}
	return idx;
}

// 포커싱
function OnSetFocus(WindowHandle handle, bool bFocused)
{
	local int idx;
	//현재 텍스트박스의 이름을 저장
	if(String(handle.name) == "EditBoxHandle")
	{
		m_CurFocusedBoxName = handle.GetWindowName();

		idx = GetCurTextBoxIndex(m_CurFocusedBoxName);

		m_EditUpButton.EnableWindow();
		m_EditDownButton.EnableWindow();

		m_EditUpButton.SetTexture("L2UI_CT1.Button.BtnEditUp", "" , "");
		m_EditDownButton.SetTexture("L2UI_CT1.Button.BtnEditDown", "" , "");

		if(idx == 0)
		{
			m_EditUpButton.DisableWindow();
			m_EditUpButton.SetTexture("L2UI_CT1.Button.BtnEditUp_disable", "" , "");
		}
		else if(idx == (MACROCOMMAND_MAX_COUNT - 1))
		{
			m_EditDownButton.DisableWindow();
			m_EditDownButton.SetTexture("L2UI_CT1.Button.BtnEditDown_disable", "" , "");
		}
	}
}

// 상하 방향키로 매크로 내용, 에디터 박스 포커스 이동
function onKeyUp( WindowHandle a_WindowHandle, EInputKey Key )
{
	local int nEditLine;

	// 키보드 입력 처리 

	if (Key == IK_Up || Key == IK_Down)
	{
		nEditLine = int(Mid(m_CurFocusedBoxName, Len("txtEdit"), Len(m_CurFocusedBoxName)));

		// txtEdit0~11 에 포커싱이 안되어 있으면 상하 키보드 안씀.
		if (!GetEditBoxHandle("MacroEditWnd.txtEdit" $ nEditLine).IsFocused())
		{
			nEditLine = -1;
//			Debug("포커싱 안되어 있음.");
			return;
		}
	}

	switch(Key)
	{
		case IK_Up:
		    if(nEditLine > 0) 
			{
				nEditLine--;
				GetEditBoxHandle("MacroEditWnd.txtEdit" $ nEditLine).SetFocus();
			}
			break;

		case IK_Down :
			if(nEditLine < 11)
			{
				nEditLine++;
				GetEditBoxHandle("MacroEditWnd.txtEdit" $ nEditLine).SetFocus();
			}
			break;
	}
}

// 액티브 스킬 인지 체크
function bool isActiveSkill( SkillInfo info )
{
	local bool b;

	switch ( info.IconType )
	{
		//------------------ 액티브
		case 0:
		case 1:
		case 2:
		case 3:
		case 4:
		case 5:
		case 6:	// 토글 스킬
		case 7:
		case 8:	// 마법 속성 아이콘
			b = true;
			break;
	}

	return b;
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

defaultproperties
{
    m_WindowName="MacroEditWnd"
}
