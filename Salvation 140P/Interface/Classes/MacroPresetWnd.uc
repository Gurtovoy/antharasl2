//------------------------------------------------------------------------------------------------------------
// 
//   제목 : 매크로 개선, 복사, 붙이기 기능, 프리셋 기능 추가 - 2015-11-03
//
//------------------------------------------------------------------------------------------------------------
class MacroPresetWnd extends UICommonAPI;

const MACROCOMMAND_MAX_COUNT = 12;

var WindowHandle Me;

var ItemWindowHandle MacroItem_ItemWnd;

var HtmlHandle    PresetViewer_Html;

var ButtonHandle  MacroCopy_Btn;
var ButtonHandle  Close_Btn;

var TextureHandle SlotGroupBoxBg_Tex;

var array<int> macroPresetIDArray;

//------------------------------------------------------------------------------------------------------------
// Init  
//------------------------------------------------------------------------------------------------------------
function OnRegisterEvent()
{
	//RegisterEvent(  );
}

function OnLoad()
{
	SetClosingOnESC();
	Initialize();
}

function OnShow()
{
	Debug("Show updateMacroPreset");
	updateMacroPreset();
}

// 창을 열였을때 정보를 매크로 스크립트 데이터를 가져와 갱신한다.
function updateMacroPreset()
{
	local int i;
	local MacroPresetInfo mPresetInfo;

	local ItemInfo	infItem;
	
	macroPresetIDArray.Length = 0;
	class'UIDATA_MACRO'.static.GetMacroPresetIDs(macroPresetIDArray);

	Debug("macroPresetIDArray" @ macroPresetIDArray.Length);

	MacroItem_ItemWnd.Clear();

	for(i = 0; i < macroPresetIDArray.Length; i++)
	{
		class'UIDATA_MACRO'.static.GetMacroPresetInfo(macroPresetIDArray[i], mPresetInfo);
		infItem.Name = mPresetInfo.Name;
		infItem.AdditionalName = mPresetInfo.IconName;
		infItem.Id.ClassID  = mPresetInfo.Id;

		infItem.Description = mPresetInfo.Description;

		infItem.IconName = mPresetInfo.IconTextureName;
		infItem.ItemSubType = int(EShortCutItemType.SCIT_MACRO);

		// 임시로 html 정보 넣기.
		infItem.IconNameEx4 = mPresetInfo.PresetDescription;

		infItem.MacroCommand = macroCommandArrayToString(mPresetInfo);

		MacroItem_ItemWnd.AddItem(infItem);

		// 첫번째를 무조건 선택되도록.. (최초에)
		if (i == 0 && mPresetInfo.PresetDescription != "")
		{
			MacroItem_ItemWnd.SetSelectedNum(0);
			Debug("html open :" @ "..\\L2text\\" $ mPresetInfo.PresetDescription);

			PresetViewer_Html.LoadHtml("..\\L2text\\" $ mPresetInfo.PresetDescription);
		}
	}
}

// 초기화
function Initialize()
{
	Me = GetWindowHandle( "MacroPresetWnd" );

	MacroItem_ItemWnd = GetItemWindowHandle( "MacroPresetWnd.MacroItem_ItemWnd" );
	PresetViewer_Html = GetHtmlHandle( "MacroPresetWnd.PresetViewer_Html" );

	Close_Btn     = GetButtonHandle( "MacroPresetWnd.Close_Btn" );
	MacroCopy_Btn = GetButtonHandle( "MacroPresetWnd.MacroCopy_Btn" );
}

//------------------------------------------------------------------------------------------------------------
// 컨트롤 핸들러  
//------------------------------------------------------------------------------------------------------------
function OnClickButton( string Name )
{
	switch( Name )
	{
		case "MacroCopy_Btn":
		 	 OnMacroCopy_BtnClick();
			 break;

		case "Close_Btn":
			 OnClose_BtnClick();
			 break;
	}
}

// 프리셋 매크로 카피 
function OnMacroCopy_BtnClick(optional int gfxSystemMessageNum)
{
	local int selectedNum;
	local ItemInfo info;

	selectedNum = MacroItem_ItemWnd.GetSelectedNum();

	if (selectedNum > -1)
	{
		MacroItem_ItemWnd.GetItem(selectedNum, info);

		// 프리셋
		if (info.MacroCommand != "")
		{
			if (gfxSystemMessageNum > 0)
			{
				AddSystemMessage(gfxSystemMessageNum);
			}
			else
			{
				// 4399    매크로 내용이 클립보드로 복사되었습니다
				AddSystemMessage(4399);
			}

			ClipboardCopy(info.MacroCommand);
			Debug("클립보드 카피:" @ info.MacroCommand);
		}
		else
		{
			Debug("클립보드 카피할게 없어..");
		}
	}
}

// 닫기
function OnClose_BtnClick()
{
	Me.HideWindow();
}

// 프리셋 아이템 윈도우 클릭
function OnClickItem( String strID, int index )
{
	local ItemInfo info;

	if (strID == "MacroItem_ItemWnd")
	{
		if (index > -1)
		{
			MacroItem_ItemWnd.SetSelectedNum(index);

			MacroItem_ItemWnd.GetItem(index, info);
			
			// IconNameEx4에 임시로 html 경로를 넣어 두었음.
			if (info.IconNameEx4 != "")
			{

				if ( getInstanceUIData().getIsClassicServer() ) 
				{
					PresetViewer_Html.LoadHtml("..\\l2text_classic\\" $ info.IconNameEx4);
				}
				else
				{
					PresetViewer_Html.LoadHtml("..\\L2text\\" $ info.IconNameEx4);
				}
			}
		}
	}
}

// 프리셋 아이템 더블 클릭
// QA쪽이랑 이야기 하다가 넣어 주면 좋을 기능으로 넣었음. 해보고 불편하면 빼면 됨.
function OnDBClickItem( String strID, int index )
{
	local ItemInfo info;

	if (strID == "MacroItem_ItemWnd")
	{
		if (GetWindowHandle("MacroEditWnd").IsShowWindow())
		{
			// 매크로 카피 및 붙이기, 4401 은 붙이기 했다는 시스템 메세지
			OnMacroCopy_BtnClick(4401);

			// 클립 보드 붙이기
			MacroItem_ItemWnd.GetItem(index, info);

			// MacroEditWnd(GetScript("MacroEditWnd")).removeAllEditBox();

			// 매크로 에디터, 이름, 짧은이름, 아이콘 프리셋 정보로 갱신.
			MacroEditWnd(GetScript("MacroEditWnd")).setEditMacroInfo(info.Name, info.IconName);

			// 붙이기
			MacroEditWnd(GetScript("MacroEditWnd")).pastByClipboard(false);
			Debug("전체 프리셋 붙이기 시도");
		}
		else
		{
			Debug("에디터 창이 닫혀 있어서 붙이기 안함.");
		}
	}
}

//------------------------------------------------------------------------------------------------------------
// 유틸 
//------------------------------------------------------------------------------------------------------------
// 매크로 구조체를 받아서, 안에 들어 있는 매크로 경보를 \n 값으로 나누어 하나의 문자열로 만든다.
function string macroCommandArrayToString(out MacroPresetInfo mPresetInfo)
{
	local string commandString;
	local int i;

	for(i = 0; i < MACROCOMMAND_MAX_COUNT; i++)
	{
		if (mPresetInfo.CommandList[i] != "") 
		{
			commandString = commandString $ mPresetInfo.CommandList[i] $ Chr(13);
		}
	}

	// 마지막 \n 코드 삭제
	if (Len(commandString) > 0)
	{
		commandString = Left(commandString, Len(commandString) - 1);
	}

	return commandString;
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( getCurrentWindowName(string(Self))).HideWindow();
}
defaultproperties
{
}
