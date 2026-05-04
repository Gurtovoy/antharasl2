/***
 * 
 *  UI-HTMLTOOL  Dongland 툴 작업 시리즈 3
 *  
 *  UIServerHtmlToolWnd
 *  
 *  $ShanghaiStudio/Graphic/UI작업/HtmlList2INI/  폴더를 보면, 특정 html 폴더의 리스트를 INI 로 만드는 프로그램이 있음.
 *  그걸로 serverHtmlList.ini 을 뽑아 내서 System 폴더에 카피 해서 사용 하는 형태임
 *  
 **/

class UIServerHtmlToolWnd extends UICommonAPI;
const TIME_ID    = 2001111;
const TIME_DELAY = 100;

var WindowHandle Me;
var ListCtrlHandle FileListCtrl;
var EditBoxHandle EditBoxCtrl;

var string m_fileName;

function OnLoad()
{
	SetClosingOnESC(); 
	//getInstanceUIData().addEscCloseWindow(getCurrentWindowName(string(Self)));

	Me = GetWindowHandle( "UIServerHtmlToolWnd" );
	FileListCtrl = GetListCtrlHandle("UIServerHtmlToolWnd.fileListCtrl");
	FileListCtrl.SetHeaderAlignment(0,TA_LEFT);
	FileListCtrl.SetResizable(false);

	EditBoxCtrl = GetEditBoxHandle("UIServerHtmlToolWnd.fileNameEditBox");
	// EditBoxCtrl.ClearAdditionalSearchList(ESearchListType.SLT_ADDITIONAL_LIST);

	Me.SetWindowTitle("UIPowerTools - [ ServerHtmlTool ]");
}

//function OnEvent(int Event_ID, String param)
//{
//	switch( Event_ID )
//	{
//		case EV_LostFocus: Debug(param);
//	}
//}

function int SearchFileListWithName(string s)
{
	local int i, num;
	local LVDataRecord record;
	num = FileListCtrl.GetRecordCount();

	for ( i = 0; i < num; ++i )
	{
		FileListCtrl.GetRec(i,record);
		if ( record.LVDataList[0].szData == s )
			return i;
	}
	return -1;
}


function OnDBClickListCtrlRecord( String strID )
{
	local int Idx;
	local LVDataRecord record;

	if ( strID != "fileListCtrl" )
		return;
	
	Idx = FileListCtrl.GetSelectedIndex();
	if( Idx < 0 )
		return;
		
	FileListCtrl.GetRec( Idx, record );
	
	if (record.LVDataList[0].szData != "") loadServerHtml(record.LVDataList[0].szData);

	FileListCtrl.SetFocus();
	Me.KillTimer(TIME_ID);
	Me.SetTimer(TIME_ID, TIME_DELAY);
}

function OnTimer(int TimeID)
{
	if (TimeID ==TIME_ID)
	{
		FileListCtrl.SetFocus();
		Me.KillTimer(TIME_ID);
	}
}
function OnClickListCtrlRecord( String strID )
{
	local int Idx;
	local LVDataRecord record;
	
	if( strID != "fileListCtrl" )
		return;

	Idx = FileListCtrl.GetSelectedIndex();

	if( Idx < 0 )
		return;
	
	FileListCtrl.GetRec( Idx, record );

	// Debug("record.LVDataList[0].szData" @ record.LVDataList[0].szData);	
	EditBoxCtrl.SetString(record.LVDataList[0].szData);
}

function addHtmlFileAtList(string fileName  )
{
	local LVDataRecord Record;
	
	Record.LVDataList.Length = 1;
	Record.LVDataList[0].szData = fileName;

	FileListCtrl.InsertRecord(Record);
}


function OnShow()
{	
	EditBoxCtrl.Clear();	
	FileListCtrl.InitListCtrl();
	FileListCtrl.DeleteAllItem();

	// getHtmlListInINI();
} 

function getHtmlListInINI()
{
	local string tempString;
	local int i, fileCount;	

	EditBoxCtrl.Clear();	
	FileListCtrl.DeleteAllItem();

	GetINIString("HtmlList", "totalFileCount", tempstring, "serverHtmlList.ini");

	fileCount = int(tempstring);

	for (i = 0; i < fileCount; i++)
	{
		GetINIString("HtmlList", "html" $ i, tempstring, "serverHtmlList.ini");
		addHtmlFileAtList(tempstring);
	}
}

function OnHide()
{
}


function OnClickButton( string strID )
{
	switch( strID )
	{
		case "htmlSmallViewButton" : OnDBClickListCtrlRecord("fileListCtrl"); break;
		case "refreshButton"       : getHtmlListInINI(); break; // loadServerHtml(EditBoxCtrl.GetString()); break;
	}
}

function loadServerHtml(string htmlFileName)
{
	ExecuteCommand("//loadhtml " $ htmlFileName );	

	EditBoxCtrl.AddNameToAdditionalSearchList(htmlFileName, ESearchListType.SLT_ADDITIONAL_LIST);

	//FileListCtrl.SetSelectedIndex(Idx, false);
	//if (Idx > 24) FileListCtrl.SetScrollPosition(Idx - 24);
}

/** OnKeyUp */
function OnKeyUp( WindowHandle a_WindowHandle, EInputKey nKey )
{
	// 키보드 누름으로 체크 	
	if (EditBoxCtrl.IsFocused())
	{	
		if (nKey == IK_Enter) 
		{
			Debug("EditBoxCtrl");
			loadServerHtml(EditBoxCtrl.GetString());
		}
	}
	else if (FileListCtrl.IsFocused())
	{
		if (nKey == IK_Enter) 
		{
			Debug("파일리스트");
			OnDBClickListCtrlRecord("fileListCtrl");
			
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
	GetWindowHandle( "UIServerHtmlToolWnd" ).HideWindow();
}
defaultproperties
{
}
