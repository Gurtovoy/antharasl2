class UIEditor_FileManager extends UICommonAPI;

const XML_EXT = ".xml";
const UC_EXT = ".uc";
const PREV_DIR = "..";
const TIMER_ID_UPDATEUI = 1022345;
const DELAY_UPDATEUI = 3000;

var WindowHandle	Me;

var ListBoxHandle	lstDirs;
var ListBoxHandle	lstFiles;
var ButtonHandle	btnLoad;
var ButtonHandle	btnSave;
var ButtonHandle	btnMakeUC;
var ButtonHandle    exitButton;

var ButtonHandle    reLoadButton;
var EditBoxHandle	txtPath;


var WindowHandle    WorkSheet;
var CheckBoxHandle  AutoReloadCheckBox;


var string m_CurPath, lastLoadedFile;

var name m_PrevStateName;

function OnRegisterEvent()
{
	RegisterEvent( EV_DialogOK );
}

function OnLoad()
{	
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	//Init Handle
	InitHandle();
	
	//Init Control Item
	InitControlItem();
	
	Update();
}

function OnShow()
{
	Me.KillTimer(TIMER_ID_UPDATEUI);
	// Me.SetTimer(TIMER_ID_UPDATEUI, DELAY_UPDATEUI);
	AutoReloadCheckBox.SetCheck(false);
}

function OnHide()
{
	Me.KillTimer(TIMER_ID_UPDATEUI);
	AutoReloadCheckBox.SetCheck(false);	
}

function OnTimer(int timerID)
{
	if (timerID == TIMER_ID_UPDATEUI)
	{
		if (AutoReloadCheckBox.IsChecked()) 
		{
			// reLoadButton.SetFocus();
			//OnClickButton("reLoadButton");			
			reloadTargetXMLUI();
			
			Me.KillTimer(TIMER_ID_UPDATEUI);
			Me.SetTimer(TIMER_ID_UPDATEUI, DELAY_UPDATEUI);
		}
	}	
}

function OnEnterState( name a_PrevStateName )
{
	m_PrevStateName = a_PrevStateName;
}

function UpdateDirectory()
{
	local Array<string> DirList;
	local int idx;
	
	lstDirs.Clear();
	lstFiles.Clear();
		
	GetDirList( DirList, m_CurPath );	
	lstDirs.AddString( PREV_DIR );

	for( idx=0; idx<DirList.Length; idx++ )
	{
		lstDirs.AddString( DirList[idx] );
		txtPath.AddNameToAdditionalSearchList(m_CurPath $ DirList[idx], ESearchListType.SLT_ADDITIONAL_LIST);
	}
}

function UpdateFileList()
{
	local Array<string> FileList;
	local int idx;
	
	lstFiles.Clear();
	
	GetFileList( FileList, m_CurPath, XML_EXT );
	
	for( idx=0; idx<FileList.Length; idx++ )
	{
		lstFiles.AddString( FileList[idx] );
		txtPath.AddNameToAdditionalSearchList(m_CurPath $ FileList[idx], ESearchListType.SLT_ADDITIONAL_LIST);
	}
}

function InitHandle()
{

	Me = GetWindowHandle( "UIEditor_FileManager" );
	
	lstDirs = GetListBoxHandle(  "UIEditor_FileManager.wndFileManager.lstDirs" );
	lstFiles = GetListBoxHandle(  "UIEditor_FileManager.wndFileManager.lstFiles" );
	btnLoad = GetButtonHandle(  "UIEditor_FileManager.wndFileManager.btnLoad" );
	btnSave = GetButtonHandle(  "UIEditor_FileManager.wndFileManager.btnSave" );
	btnMakeUC = GetButtonHandle(  "UIEditor_FileManager.wndFileManager.btnMakeUC" );
	txtPath = GetEditBoxHandle (  "UIEditor_FileManager.wndFileManager.txtPath" );
	WorkSheet = GetWindowHandle( "Worksheet.Worksheet" );

	reLoadButton       = GetButtonHandle("UIEditor_FileManager.reLoadButton");
	AutoReloadCheckBox = GetCheckBoxHandle("UIEditor_FileManager.AutoReloadCheckBox");
}

function OnClickCheckBox(string strID)
{
	if (strID == "AutoReloadCheckBox")
	{
		if (AutoReloadCheckBox.IsChecked())
		{
			Me.KillTimer(TIMER_ID_UPDATEUI);			
			Me.SetTimer(TIMER_ID_UPDATEUI, DELAY_UPDATEUI);
		}		
		else
		{
			Me.KillTimer(TIMER_ID_UPDATEUI);			
		}
	}
}

function InitControlItem()
{
	//Set Title
	Me.SetWindowTitle("UIEditor - FileManager");
	
	//Interface Path
	// m_CurPath = GetOptionString( "UIEditor", "SysPath" );
	//if( Len(m_CurPath) < 1 )

	m_CurPath = GetInterfaceDir() $ "\\Default\\";
	txtPath.SetString( m_CurPath );
}

function OnEvent(int Event_ID, string param)
{
	local string FileName;
	
	if (Event_ID == EV_DialogOK)
	{
		if (DialogIsMine())
		{
			if( DialogGetID() == 98 )
			{
				FileName = DialogGetString();
				if( Len(FileName) < 1 )
					return;
					
				MakeUC( FileName );
			}	
			else if( DialogGetID() == 99 )
			{
				FileName = DialogGetString();
				if( Len(FileName) < 1 )
					return;
					
				SaveXMLFile( FileName );
			}			
		}
	}
}

function OnDBClickListBoxItem( String strID, int SelectedIndex)
{
	local string DirName;
	
	if( strID != "lstDirs" )
		return;
		
	DirName = lstDirs.GetSelectedString();
		
	if( DirName == PREV_DIR )
		m_CurPath = GetParentDirectory( m_CurPath );
	else
		m_CurPath = m_CurPath $ DirName;
		
	Update();
}

function Update()
{
	if( Right( m_CurPath, 1 ) != "\\" )
		m_CurPath = m_CurPath $ "\\";
	
	SetOptionString( "UIEditor", "SysPath", m_CurPath );
	txtPath.SetString( m_CurPath );
	txtPath.ClearAdditionalSearchList(ESearchListType.SLT_ADDITIONAL_LIST);

	UpdateDirectory();
	UpdateFileList();
}

function string GetParentDirectory( String Path )
{
	local array<String> DirList;
	local int Count;
	local int idx;
	local string NewPath;
	
	if( Len(Path) < 1 )
		return NewPath;
		
	if( Right( Path, 1 ) == "\\" )
		Path = Left( Path, Len(Path) - 1 );
	
	Count = Split( Path, "\\", DirList );
	
	if( Count == 1 )
		return Path;
	
	for( idx=0; idx<Count-1; idx++ )
		NewPath = NewPath $ DirList[idx] $ "\\";
	
	return NewPath;
}

function OnClickButton( string Name )
{
	switch( Name )
	{
		case "btnLoad":
			OnLoadClick();
			break;

		case "btnSave":
			OnSaveClick();
			break;

		case "btnMakeUC":
			OnMakeClick();
			break;

		case "exitButton" :
			Update();
			//ExecuteCommand( "///setstate gamingstate" );
			ExecuteCommand( "///setstate " $ m_PrevStateName );
			break;

		case "reLoadButton" :
			 reloadTargetXMLUI();
			 break;

	}
}

function OnCompleteEditBox( string strID )
{
	switch( strID )
	{
	case "txtPath":
		m_CurPath = txtPath.GetString();
		Update();
		break;
	}
}

function OnLoadClick()
{
	local WindowHandle NewControl;
	local string FileName;
	local string FullName;
	
	if( WorkSheet == None )
	{
		DialogShow(DialogModalType_Modalless, DialogType_OK, "Can't Find Worksheet.", string(Self));
		return;
	}
	
	FileName = lstFiles.GetSelectedString();
	if( Len(FileName) < 1 )
	{
		DialogShow(DialogModalType_Modalless, DialogType_OK, "Please Select XML File.", string(Self));
		return;
	}
	FullName = m_CurPath $ FileName;

	NewControl = WorkSheet.LoadXMLWindow( FullName );
	if( NewControl == None )
	{
		DialogShow(DialogModalType_Modalless, DialogType_OK, "Load XML Window Failed!", string(Self));
		return;
	}
	
	lastLoadedFile = FullName;

	NewControl.SetScript( "UIEditor_Worksheet" );
	NewControl.ConvertToEditable();
	NewControl.SetFocus();
}

/**
 *   해당 XML UI 재로딩 , ART 강성욱, 요청 사항
 **/
function reloadTargetXMLUI()
{
	local WindowHandle NewControl;
	local Array<WindowHandle> WindowList;
	local int i;

	if( WorkSheet == None )
	{
		DialogShow(DialogModalType_Modalless, DialogType_OK, "Can't Find Worksheet.", string(Self));
		return;
	}

	// 작업 스테이지 삭제
	//ClearTracker();
	//DeleteAttachedWindow();		

	WorkSheet.SetFocus();
	 // 해당 윈도우 자식 목록을 얻고..
	 WorkSheet.GetChildWindowList(WindowList);

	 // 목록을 검색해서 지우면 되는듯.. 
	 for(i = 0; i < WindowList.Length; i++)
	 {
		// 포커싱 후 삭제 
		WindowList[i].SetFocus();
		DeleteAttachedWindow();	
		ClearTracker();
	 }

	NewControl = WorkSheet.LoadXMLWindow( lastLoadedFile );
	if( NewControl == None )
	{
		DialogShow(DialogModalType_Modalless, DialogType_OK, "Load XML Window Failed!", string(Self));
		return;
	}
	
	NewControl.SetScript( "UIEditor_Worksheet" );
	NewControl.ConvertToEditable();
	NewControl.SetFocus();
}

function OnSaveClick()
{
	local string FileName;
	
	FileName = lstFiles.GetSelectedString();
	
	DialogSetEditBoxMaxLength(100);
	DialogSetID(99);
	DialogShow(DialogModalType_Modalless,DialogType_OKCancelInput, "Input File Name.", string(Self));
	DialogSetString( FileName );
}

function OnMakeClick()
{
	local WindowHandle TrackerWnd;
	local WindowHandle TopWnd;
	
	local string ScriptName;
	local string FileName;
	
	//Find SciptName
	TrackerWnd = GetTrackerAttachedWindow();
	if( TrackerWnd==None )
	{
		DialogShow(DialogModalType_Modalless, DialogType_OK, "Select Target Window to save.", string(Self));
		return;
	}
	TopWnd = TrackerWnd.GetTopFrameWnd();
	if( TopWnd == None )
	{
		DialogShow(DialogModalType_Modalless, DialogType_OK, "Target Window Have No XML Infomation.", string(Self));
		return;
	}
	ScriptName = TopWnd.GetScriptName();
	if( Len(ScriptName) < 1 )
	{
		DialogShow(DialogModalType_Modalless, DialogType_OK, "Target Window Have No Script Name.", string(Self));
		return;
	}
	
	FileName = ScriptName $ UC_EXT;
	DialogSetEditBoxMaxLength(100);
	DialogSetID(98);
	DialogShow(DialogModalType_Modalless,DialogType_OKCancelInput, "Input Script File Name.", string(Self));
	DialogSetString( FileName );
}

function SaveXMLFile( string FileName )
{
	local WindowHandle TrackerWnd;
	local WindowHandle TopWnd;
	
	local string FullName;
	
	if( Len(FileName) < 1 )
	{
		DialogShow(DialogModalType_Modalless, DialogType_OK, "Please Input Save File Name!", string(Self));
		return;
	}
	
	TrackerWnd = GetTrackerAttachedWindow();
	if( TrackerWnd==None )
	{
		DialogShow(DialogModalType_Modalless, DialogType_OK, "Select Target Window to save.", string(Self));
		return;
	}
	
	TopWnd = TrackerWnd.GetTopFrameWnd();
	if( TopWnd == None )
	{
		DialogShow(DialogModalType_Modalless, DialogType_OK, "Target Window Have No XML Infomation.", string(Self));
		return;
	}
	
	FullName = m_CurPath $ FileName;
	
	if( TopWnd.SaveXMLWindow( FullName ) )
		DialogShow(DialogModalType_Modalless, DialogType_OK, "Save Complete. (" $ FullName $ ")", string(Self) );
	else
		DialogShow(DialogModalType_Modalless, DialogType_OK, "Save Failed. OTL", string(Self) );
		
	Update();
}

function MakeUC( string FileName )
{
	local WindowHandle TrackerWnd;
	local WindowHandle TopWnd;
	
	local array<String> NameList;
	local int Idx;
	local int Count;
	
	local string UCName;
	local string FullName;
	
	if( Len(FileName) < 1 )
	{
		DialogShow(DialogModalType_Modalless, DialogType_OK, "Please Input Save File Name!", string(Self));
		return;
	}
	
	Count = Split( FileName, ".", NameList );
	if( ( "." $ NameList[Count-1] ) != UC_EXT )
		FileName = FileName $ UC_EXT;
	
	Count = Split( FileName, ".", NameList );
	for( idx=0; idx<Count-1; idx++ )
	{
		if( Idx > 0 )
			UCName = UCName $ ".";
		UCName = UCName $ NameList[Idx];
	}
	
	TrackerWnd = GetTrackerAttachedWindow();
	if( TrackerWnd==None )
	{
		DialogShow(DialogModalType_Modalless, DialogType_OK, "Select Target Window to save.", string(Self));
		return;
	}
	TopWnd = TrackerWnd.GetTopFrameWnd();
	if( TopWnd == None )
	{
		DialogShow(DialogModalType_Modalless, DialogType_OK, "Target Window Have No XML Infomation.", string(Self));
		return;
	}
	
	FullName = m_CurPath $ FileName;
	
	if( TopWnd.MakeBaseUC( UCName, FullName ) )
		DialogShow(DialogModalType_Modalless, DialogType_OK, "Save Complete. (" $ FullName $ ")", string(Self) );
	else
		DialogShow(DialogModalType_Modalless, DialogType_OK, "Save Failed. OTL", string(Self) );
}
defaultproperties
{
}
