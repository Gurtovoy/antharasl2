class MacroListWnd extends UICommonAPI;

const MACRO_MAX_COUNT = 48;
const MACROCOMMAND_MAX_COUNT = 12;

var string m_WindowName;
var bool	m_bShow;
var ItemID	m_DeleteItemID;
var int	m_Max;
var WindowHandle		m_hMacroListWnd; //branch 111109

function OnRegisterEvent()
{
	RegisterEvent( EV_DialogOK );
	
	RegisterEvent(EV_MacroShowListWnd);
	RegisterEvent(EV_MacroUpdate);
	RegisterEvent(EV_MacroList);
}

function OnLoad()
{
	SetClosingOnESC();

	
	m_hMacroListWnd=GetWindowHandle(m_WindowName);	

	m_bShow = false;
	ClearItemID(m_DeleteItemID);
}

function OnEnterState( name a_PreStateName )
{
	class'MacroAPI'.static.RequestMacroList();
}

function OnShow()
{
	m_bShow = true;	
}
	
function OnHide()
{
	m_bShow = false;
	// 2011-12-05 수정 (정우균) "MacroListWnd"가 숨겨질때 "MacroEditWnd"가 같이 숨겨지게 함
	class'UIAPI_WINDOW'.static.HideWindow("MacroEditWnd");

	// 매크로 창이 닫힐 떄 같이 닫힘.
	if (GetWindowHandle("MacroPresetWnd").IsShowWindow())
	{
		GetWindowHandle("MacroPresetWnd").HideWindow();
	}
}

function OnClickButton( string strID )
{	
	switch( strID )
	{
	case "btnHelp":
		OnClickHelp();
		break;
	case "btnAdd":
		OnClickAdd();
		break;
	}
}

function OnEvent(int Event_ID, String param)
{
	if (Event_ID == EV_MacroShowListWnd)
	{
		HandleMacroShowListWnd();
	}
	else if (Event_ID == EV_MacroUpdate)
	{
		HandleMacroUpdate();
	}
	else if (Event_ID == EV_MacroList)
	{
		HandleMacroList(param);
	}
	else if (Event_ID == EV_DialogOK)
	{
		if (DialogIsMine())
		{
			if (IsValidItemID(m_DeleteItemID))
			{
				class'MacroAPI'.static.RequestDeleteMacro(m_DeleteItemID);
				//debug("what?");
				ClearItemID(m_DeleteItemID);
				if(m_Max == 1)	//하나남은 것을 지울 경우 0이 되므로 한번 갱신해준다. 
				{
					HandleMacroList("");// 창을 한번 갱신해준다. //0일경우에만 갱신해주면 됨.
				}
			}
			
		}
	}
}

//매크로의 클릭
function OnClickItem( string strID, int index )
{
	local ItemInfo 	infItem;
	
	if (strID == "MacroItem" && index>-1)
	{
		if (class'UIAPI_ITEMWINDOW'.static.GetItem("MacroListWnd.MacroItem", index, infItem))
			class'MacroAPI'.static.RequestUseMacro(infItem.ID);
	}
}

//도움말
function OnClickHelp()
{
	local string strParam;

	// 클래식과 라이브에 다른 도움말 사용
	if ( getInstanceUIData().getIsClassicServer() ) 
	{
		ParamAdd(strParam, "FilePath", "..\\l2text_classic\\help_general_control_macro.htm");
		ExecuteEvent(EV_ShowHelp, strParam);
	}
	else
	{
		//ParamAdd(strParam, "FilePath", "..\\l2text\\help_general_control_macro.htm");
		ExecuteEvent(EV_ShowHelp, "37");
	}
}

//추가
function OnClickAdd()
{	
	// 2011-12-05 수정 (정우균) "MacroEditWnd"가 화면에 보이지 않을때만 보이게 함
	if(!class'UIAPI_WINDOW'.static.IsShowWindow("MacroEditWnd"))
	{
		class'UIAPI_WINDOW'.static.ShowWindow("MacroEditWnd");
	}
	ExecuteEvent(EV_MacroShowEditWnd, "");
}

function HandleMacroUpdate()
{
	class'MacroAPI'.static.RequestMacroList();
}

function HandleMacroShowListWnd()
{
	if (m_bShow)
	{
		PlayConsoleSound(IFST_WINDOW_CLOSE);
		m_hMacroListWnd.HideWindow();
	}
	/*else if ( class'UIAPI_WINDOW'.static.IsShowWindow ( "MacroEditWnd") )//한창 가기 용

	{
		PlayConsoleSound(IFST_WINDOW_CLOSE);
		class'UIAPI_WINDOW'.static.HideWindow("MacroEditWnd");
	}*/
	else
	{		
		PlayConsoleSound(IFST_WINDOW_OPEN);	
		m_hMacroListWnd.ShowWindow();
		m_hMacroListWnd.SetFocus();
		//SetFocus();
		//class'UIAPI_WINDOW'.static.SetFocus("MacroListWnd");
	}
}

function Clear()
{
	class'UIAPI_ITEMWINDOW'.static.Clear("MacroListWnd.MacroItem");
}

function HandleMacroList(string param)
{
	local int Idx;
	local int Max;
	

	
	
	local string strIconName;
	local string strMacroName;
	local string strDescription;
	local string strTexture;
	local string strTmp;
	
	local ItemInfo	infItem;
	//초기화
	Clear();

	//Debug("HandleMacroList"@ param);
	
	ParseInt(param, "Max", Max);
	m_Max = Max;	//글로벌 맥스를 설정 -_-;;
	for (Idx=0; Idx<Max; Idx++)
	{
		strIconName = "";
		strMacroName = "";
		strDescription = "";
		strTexture = "";
		
		ParseItemIDWithIndex(param, infItem.ID, idx);
		ParseString(param, "IconName_" $ Idx, strIconName);
		ParseString(param, "MacroName_" $ Idx, strMacroName);
		ParseString(param, "Description_" $ Idx, strDescription);
		ParseString(param, "TextureName_" $ Idx, strTexture);


		//Debug("-> strTexture" @ strTexture);
	
		infItem.Name = strMacroName;
		infItem.AdditionalName = strIconName;
		infItem.IconName = strTexture;
		infItem.Description = strDescription;
		infItem.ItemSubType = int(EShortCutItemType.SCIT_MACRO);
		
		//MacroItem에 추가
		class'UIAPI_ITEMWINDOW'.static.AddItem("MacroListWnd.MacroItem", infItem);
	}
	
	//매크로 갯수표시
	if (Max<10)
	{
		strTmp = strTmp $ "0";
	}
	strTmp = strTmp $ Max;
	strTmp = "(" $ strTmp $ "/" $ MACRO_MAX_COUNT $ ")";
	class'UIAPI_TEXTBOX'.static.SetText("MacroListWnd.txtCount", strTmp);
}

//Trash아이콘으로의 DropITem
function OnDropItem( string strID, ItemInfo infItem, int x, int y)
{
	switch( strID )
	{
	case "btnTrash":
		DeleteMacro(infItem);
		break;
	case "btnEdit":
		EditMacro(infItem);
		break;
	}
}

//매크로 삭제
function DeleteMacro(ItemInfo infItem)
{
	local string strMsg;
	
	//매크로가 아니면 패스
	if (infItem.ItemSubType != int(EShortCutItemType.SCIT_MACRO))		
		return;			
	
	strMsg = MakeFullSystemMsg(GetSystemMessage(828), infItem.Name, "");
	m_DeleteItemID = infItem.ID;
	DialogShow(DialogModalType_Modalless,DialogType_Warning, strMsg, string(Self));
}

//매크로 편집
function EditMacro(ItemInfo infItem)
{
	local string param;
	
	Debug("------------------ > ");
	Debug("infItem Name" @  infItem.Name);

	//매크로가 아니면 패스
	if (infItem.ItemSubType != int(EShortCutItemType.SCIT_MACRO))
		return;

	Debug("------------EShortCutItemType ------ > " @ String(EShortCutItemType.SCIT_MACRO));
	
	ParamAddItemID(param, infItem.ID);
	ExecuteEvent(EV_MacroShowEditWnd, param);
	class'UIAPI_WINDOW'.static.ShowWindow("MacroEditWnd");

	Debug("쇼쇼쇼 " @ param);
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	m_hMacroListWnd.HideWindow();	
}

defaultproperties
{
    m_WindowName="MacroListWnd"
}
