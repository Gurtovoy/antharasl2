/**
 *    UC 파일을 기준으로 UI 열기를 하도록 하는 테스트 툴 
 *    Create By : dongland
 **/
class UIOpenToolWnd extends UICommonAPI;

var WindowHandle   Me;

var ButtonHandle   searchBtn;
var ButtonHandle   InitBtn;
var ButtonHandle   showBtn;

var EditBoxHandle  searchEditBox;
var EditBoxHandle  itemCountEditBox;
var EditBoxHandle  descViewEditBox;

var ListCtrlHandle itemListCtrl;

var Array<string> FileList;
var string m_CurPath;

const XML_EXT  = ".xml";
const UC_EXT   = ".uc";
const PREV_DIR = "..";

function OnRegisterEvent()
{
	//RegisterEvent(  );
}

function OnLoad()
{
	SetClosingOnESC(); 
	Initialize();
	Load();
}

function Initialize()
{
	Me               = GetWindowHandle( "UIOpenToolWnd" );

	// 리스트 박스
	itemListCtrl     = GetListCtrlHandle( "UIOpenToolWnd.itemListCtrl" );

	// 에디터 박스
	searchEditBox    = GetEditBoxHandle( "UIOpenToolWnd.searchEditBox" );
	itemCountEditBox = GetEditBoxHandle( "UIOpenToolWnd.itemCountEditBox" );
	descViewEditBox  = GetEditBoxHandle( "UIOpenToolWnd.descViewEditBox" );

	// 버튼
	searchBtn        = GetButtonHandle( "UIOpenToolWnd.searchBtn" );
	InitBtn          = GetButtonHandle( "UIOpenToolWnd.InitBtn" );
	showBtn          = GetButtonHandle( "UIOpenToolWnd.showBtn" );
}

function Load()
{
	//..
}

function onShow()
{
	Me.SetWindowTitle("UIOpenTool [UC Files List]");
	m_CurPath = GetInterfaceDir() $ "\\CLASSES\\";
	updateUCFiles();
}

function OnClickButton( string Name )
{
	switch( Name )
	{
		case "searchBtn":
			 OnsearchBtnClick();
			 break;

		case "InitBtn":
			 OnInitBtnClick();
			 break;

		case "showBtn":
			 OnshowBtnClick();
			 break;
	}
}

function OnsearchBtnClick()
{
	local int idx;
	local LVDataRecord recordInfo;
	
	if (searchEditBox.GetString() == "")
	{
		updateUCFiles(); 
		return;
	}

	itemListCtrl.DeleteAllItem();

	searchEditBox.ClearAdditionalSearchList(ESearchListType.SLT_ADDITIONAL_LIST);
	for( idx=0; idx < FileList.Length; idx++ )
	{

		if ( InStr( Caps(FileList[idx]), Caps(searchEditBox.GetString()) ) != -1 )
		{
			recordInfo.LVDataList.length = 3;
			recordInfo.LVDataList[0].szData = FileList[idx];

			itemListCtrl.InsertRecord(recordInfo);
			
			searchEditBox.AddNameToAdditionalSearchList(FileList[idx], ESearchListType.SLT_ADDITIONAL_LIST);

		}
		//Debug("FileList[idx]"@FileList[idx]);
	}

	descViewEditBox.SetString("Total Search Files: " $ itemListCtrl.GetRecordCount());
}

function OnInitBtnClick()
{
	searchEditBox.SetString("");
}

function OnShowBtnClick()
{
	local LVDataRecord Record;
	
	local string str;

	itemListCtrl.GetSelectedRec(Record);

	str = Record.LVDataList[0].szData;

	if( str != "" )
	{
		if ( class'UIAPI_WINDOW'.static.IsShowWindow (str) )
		{
			class'UIAPI_WINDOW'.static.HideWindow(str);
		}
		else
		{
			class'UIAPI_WINDOW'.static.ShowWindow(str);			
			class'UIAPI_WINDOW'.static.SetFocus(str);
		}
	}	
}

function OnDBClickListCtrlRecord( string ListCtrlID)
{
	if (ListCtrlID == "itemListCtrl") OnShowBtnClick();
}


function updateUCFiles()
{
	
	local int idx;

	local LVDataRecord recordInfo;
	local LVData data1;

	// local script NewWindow;
	
	itemListCtrl.DeleteAllItem();
	
	searchEditBox.ClearAdditionalSearchList(ESearchListType.SLT_ADDITIONAL_LIST);
	FileList.Remove(0, FileList.Length);
	GetFileList( FileList, m_CurPath, UC_EXT );
	
	for( idx=0; idx<FileList.Length; idx++ )
	{
		FileList[idx] = Left( FileList[idx], Len(FileList[idx]) - 3 );

		data1.szData = FileList[idx];

		recordInfo.LVDataList.length = 3;
		recordInfo.LVDataList[0] = data1;

		// Debug(""@ GetWindowHandle( data1.szData ).IsEnableWindow());

		//// 애매로 gfx 인지 uc인지 판단.. (정확하지 않을 수도..-_-..)
		//if (NewWindow.IsEnableWindow() == true)
		//{
		//	recordInfo.LVDataList[1].szData = "XML";
		//}
		//else
		//{
		//	recordInfo.LVDataList[1].szData = "GFX";
		//}

		itemListCtrl.InsertRecord(recordInfo);

		searchEditBox.AddNameToAdditionalSearchList(FileList[idx], ESearchListType.SLT_ADDITIONAL_LIST);
	}

	descViewEditBox.SetString("Total UC Files: " $ FileList.Length);
}

/** OnKeyUp */
function OnKeyUp( WindowHandle a_WindowHandle, EInputKey nKey )
{
	// local string MainKey;

	// 키보드 누름으로 체크 	
	if (searchEditBox.IsFocused())
	{	
		// txtPath
		if (nKey == IK_Enter) 
		{
			// 키보드 입력은 아무것도 입력 하지 않았을때 전체 검색을 허용하지 않는다.
			// 실수로 자꾸 누르는 경우가 있어서..
			if (trim(searchEditBox.GetString()) != "") OnsearchBtnClick();
		}
	}
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( "UIOpenToolWnd" ).HideWindow();
}
defaultproperties
{
}
