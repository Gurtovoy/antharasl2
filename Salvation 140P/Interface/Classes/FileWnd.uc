class FileWnd extends UICommonAPI;
var bool m_bShow;
var WindowHandle Me;
var ListCtrlHandle FileListCtrl;
var EditBoxHandle EditBoxCtrl;
var ComboBoxHandle FilePathComboBoxCtrl;
var ComboBoxHandle FileExtComboBoxCtrl;
var string m_filePath;
var string FileTextureName, FolderTextureName;
var _FileHandler FileHandler;
var bool IsIdle;
var array<string> LastPath;
var string m_fileName;
//////////////////////////////////////////////////////////////////////// jdh84 /////////////////
//                             fileWnd의 사용법.
//
// 1. filewnd를 XXX파일 등록에 사용하고싶다.
// 2. UICommonAPI의 _FileHandler 에 새로운 ENUM(TYPE) 값을 추가한다.
// 3. 파일을 등록시키는 API를 작성한다.
// 4. UploadFile함수에 그 파일 핸들러에 맞는 API를 등록한다.
// 5-1. AddFileWndFileExt 함수와 ClearFileWndFileExt 함수를 사용해 확장자 박스를 조정한다
// 5-2. FileWndShow(2번에서 지정한 타입)함수를 호출하여 활성화한다  
////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////
function ShowFileWnd(_FileHandler filehandlertype) //UICommanAPI 로 사용하기 위해 Filewnd 를 캡슐화
{
	if(m_bShow) 
	{
		return; //이미 다른 파일 파일창이 떠있다. 피드백을 넣어 줍시다
	}
	
	FileHandler = filehandlertype;
	
	switch(FileHandler)
	{
		case FH_PLEDGE_CREST_UPLOAD:
			Me.SetWindowTitle("CREST UPLOAD"); 			
			break;
		case FH_PLEDGE_EMBLEM_UPLOAD:
			Me.SetWindowTitle("EMBLEM UPLOAD"); 
			break;
		default:
			Me.SetWindowTitle("File Registeration"); 
			break;
	}
	Me.ShowWindow();
	Me.SetFocus();
}

function HideFileWnd() //UICommanAPI 로 사용하기 위해 Filewnd 를 캡슐화
{
	Me.HideWindow();
}

function AddFileExt(string str, array<string> strArray) //UICommanAPI 로 사용하기 위해 Filewnd 를 캡슐화
{
	FileExtComboBoxCtrl.AddStringWithFileExt(str,strArray);	
}

function ClearFileExt() //UICommanAPI 로 사용하기 위해 Filewnd 를 캡슐화
{
	FileExtComboBoxCtrl.Clear();
}
/////////////////////////////////////////////////////////////////////////////////////////////////////





////////////////////////////////////////////////////////////////////////////////////////////////////
function bool UploadFile(string filePath, string fileName) 
{
	local string filestr;
	filestr = filePath $ "\\" $ fileName;
	if(FileHandler >= FH_MAX) return true;
	LastPath[FileHandler] = filePath; //마지막 등록경로를 저장
	UploadFileFullPath(filestr);
}

function bool UploadFileFullPath(string path)
{
	debug(path);
	if(FileHandler >= FH_MAX) return true;
	
	switch(FileHandler)
	{
		case FH_NONE:
			return true;
		case FH_PLEDGE_CREST_UPLOAD:
			return RequestClanRegisterCrestByFilePath(path); //혈맹문장 등록
		case FH_PLEDGE_EMBLEM_UPLOAD:
			return RequestClanRegisterEmblemByFilePath(path); //혈맹문장 등록
		default:
			return true;
	}
}

function OnLoad()
{
	// hard coding
	local array<string> strArray;
	local int i;

	LastPath.Length = _FileHandler.FH_MAX;
	for(i = 0; i < _FileHandler.FH_MAX; i++)
	{
		LastPath[i] = "C:"; //최초 경로 설정
	}

	IsIdle = true; //처음에는 idle 상태(두개이상의 파일윈도우를 생성하지 않도록)
	FileHandler = FH_NONE; //초기상태는 파일 핸들러가 없음
	FileTextureName = "L2UI_CH3.BloodHoodWnd.BloodHood_Logon"; //파일의 텍스쳐
	FolderTextureName = "L2UI_CH3.BloodHoodWnd.BloodHood_Logoff"; //폴더의 텍스쳐

	if(CREATE_ON_DEMAND==0)
	{
	}
	else
	{
		Me = GetWindowHandle( "FileWnd" );
		FileListCtrl = GetListCtrlHandle("FileWnd.FLWListCtrl");
		FileListCtrl.SetHeaderAlignment(0,TA_LEFT);
		EditBoxCtrl = GetEditBoxHandle("FileWnd.FLWEditBox");
		FilePathComboBoxCtrl = GetComboBoxHandle("FileWnd.FLWComboBox");
		FileExtComboBoxCtrl = GetComboBoxHandle("FileWnd.FLWFTypeComboBox");
		
		strArray.Length = 1;
		strArray[0] = "*";
		FileExtComboBoxCtrl.AddStringWithFileExt("모든 파일", strArray);
		SetFilePathnAdjustControl("C:");
	}
	m_bShow = false;
}

function SetFilePathnAdjustControl( string s )
{
	local array<FileNameInfo> fInfoArray;
	local array<string> fExtArray;

	EditBoxCtrl.Clear();
	UpdateFilePathComboBox(s);
	
	fExtArray = FileExtComboBoxCtrl.GetFileExtInfo(FileExtComboBoxCtrl.GetSelectedNum());
	fInfoArray = GetFilesInfoList(m_filePath,fExtArray);
	EnumerateFile(fInfoArray);
}

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

function OnCompleteEditBox( String strID )
{
	local LVDataRecord record;
	local int idx;
	local string strEdit, filePath;

	if ( strID != "FLWEditBox" )
		return;

	strEdit = EditBoxCtrl.GetString();
	idx = SearchFileListWithName(strEdit);
	
	if ( idx < 0 )  //에디트박스의 파일명이 현 디렉토리에 없다면 Full path로 간주하자
	{
		UploadFileFullPath(strEdit);
		EditBoxCtrl.Clear();
		return;
	}

	FileListCtrl.GetRec(idx, record);

	m_fileName = record.LVDataList[0].szData;

	if ( record.nReserved1 == 1 ) //check
	{
		if ( UploadFile(m_filePath, m_fileName))
			Me.HideWindow();
		else
			;
	}
	else
		SetFilePathnAdjustControl(filePath);
}

function OnDBClickListCtrlRecord( String strID )
{
	local int Idx;
	local LVDataRecord record;
	local string str;
	if ( strID != "FLWListCtrl" )
		return;
	
	Idx = FileListCtrl.GetSelectedIndex();
	if( Idx < 0 )
		return;
		
	FileListCtrl.GetRec( Idx, record );
	str = record.LVDataList[0].szData;		
	
	if ( record.nReserved1 == 0 )		// case of directory
	{
		str = m_filePath $ str;
		SetFilePathnAdjustControl(str);
	}
	else
	{
		m_fileName = record.LVDataList[0].szData;
		if ( UploadFile(m_filePath, m_fileName))
			Me.HideWindow();
		else
			;
	}
}
function UpdateFilePathComboBox(String str)
{
	local int idx, i, j, k;
	local bool bComp;
	local string remainStr;
	local array<DriveInfo> arrDrvInfo;
	
	if ( Len(str) <= 0 ) return;

	FilePathComboBoxCtrl.Clear();
	m_filePath = str;
	k = -1;
	bComp = false;
	
	arrDrvInfo = GetDrivesInfoList();

	for ( j = 0; j < arrDrvInfo.Length; ++j )
	{
		if ( Left(arrDrvInfo[j].driveChar,1) != Left(m_filePath,1) )
		{
			FilePathComboBoxCtrl.AddString(Left(arrDrvInfo[j].driveChar,1) $ ":" );
			if ( !bComp ) ++k;
		}
		else
		{
			remainStr = str;

			idx = InStr(remainStr,"\\");
			if ( idx < 0 ) idx = Len(remainStr);

			str = Left(remainStr, idx);
			remainStr = Right(remainStr, Len(remainStr)-idx );
			FilePathComboBoxCtrl.AddStringWithGap(str,0);
			++k;
			i = 1;

			while (	Len(remainStr) > 0 )
			{
				remainStr = Right(remainStr,Len(remainStr)-1);
				idx = InStr( remainStr, "\\");
				if ( idx < 0 ) idx = Len(remainStr);
				str = Left(remainStr, idx);
				remainStr = Right(remainStr, Len(remainStr)-idx );

				str = "\\" $ str;

				FilePathComboBoxCtrl.AddStringWithGap(str,i);
				++i; ++k;
			}
			bComp = true;
		}
	}

	FilePathComboBoxCtrl.SetSelectedNum(k); // necessary for modifying
}

function OnClickListCtrlRecord( String strID )
{
	local int Idx;
	local LVDataRecord record;
	
	if( strID != "FLWListCtrl" )
		return;

	Idx = FileListCtrl.GetSelectedIndex();
	if( Idx < 0 )
		return;
		
	FileListCtrl.GetRec( Idx, record );
	EditBoxCtrl.SetString(record.LVDataList[0].szData);
}

function EnumerateFile( array<FileNameInfo> FList )
{
	local int k;
	local LVData Data;
	local LVDataRecord Record;
	FileListCtrl.DeleteAllItem();

	Record.LVDataList.Length = 1;

	for (k = 0; k < FList.Length; k++)
	{
		Data.szData = FList[k].fileName;
				
		Record.LVDataList[0].hasIcon = true;
		if(FList[k].bIsFile)
			Record.LVDataList[0].szTexture = FileTextureName;
		else
			Record.LVDataList[0].szTexture = FolderTextureName;
		
		Record.LVDataList[0].nTextureWidth = 14;
		Record.LVDataList[0].nTextureHeight = 14;
		Record.LVDataList[0].szData = FList[k].fileName;
		
		
		Record.nReserved1 = INT64( FList[k].bIsFile );
		FileListCtrl.InsertRecord(Record);
	}
	FileListCtrl.AdjustColumnWidth(0);
}

// function SortArray(array<FileNameInfo> FList)
// {
// 	local int i;
// 	local int j;
// 	local FileNameInfo temp;
// 	for(i = 0; i < FList.Length; i++)
// 	{
// 		for(j = 0; j < FList.Length; j++)
// 			{
// 				if(IsGreater(FList[i], FList[j], 1))
// 				{
// 					temp = FList[i];
// 					FList[i] = Flist[j];
// 					FList[j] = temp;
// 				}
// 			}	
// 	}
// 	for(i = 0; i < FList.Length; i++)
// 	{
// 		debug(FList[i].fileName);
// 	}
// }
// 
// function bool IsGreater(FileNameInfo a, FileNameInfo b,int SortingScheme) //0 : 오름차순 else: 내림차순
// {
// 	local bool m_result;
// 	if(!a.bIsFile && b.bIsFile) m_result = true; //a만 디렉토리
// 	else if(a.bIsFile && !b.bIsFile) m_result = false; //b만디렉토리
// 	else
// 	{
// 		if(a.fileName > b.fileName) m_result = true;
// 		else m_result = false;
// 	}
// 	if(SortingScheme == 0)
// 		m_result = !m_result; //내림차순
// 	return m_result;
// }

function OnShow()
{
	local array<FileNameInfo> fInfoArray;
	local array<string> fExtArray;

	EditBoxCtrl.Clear();
	FileListCtrl.InitListCtrl();
	FileExtComboBoxCtrl.SetSelectedNum(0);
	fExtArray = FileExtComboBoxCtrl.GetFileExtInfo(FileExtComboBoxCtrl.GetSelectedNum());
	
	m_filePath = LastPath[FileHandler];
	fInfoArray = GetFilesInfoList(LastPath[FileHandler],fExtArray);
	EnumerateFile(fInfoArray);

	m_bShow = true;
}

function OnHide()
{
	m_bShow = false;
}

function OnComboBoxItemSelected( String strID, int index )
{
	local string str;
	local int i, s, e;
	local array<FileNameInfo> fInfoArray;
	local array<string> fExtArray;
	if ( index < 0 ) return;

	if (strID == "FLWComboBox" )
	{
		s = getIndexOfCurrentDrive();
		e = getIndexOfCurrentFolder();
		if ( index >= s && index <= e)
		{
			for ( i = s; i <= index; ++i )
				str = str $ FilePathComboBoxCtrl.GetString(i);
		}
		else
			str = FilePathComboBoxCtrl.GetString(index);

		SetFilePathnAdjustControl(str);
	}
	else if ( strID == "FLWFTypeComboBox" )
	{
		fExtArray = FileExtComboBoxCtrl.GetFileExtInfo(FileExtComboBoxCtrl.GetSelectedNum());
		fInfoArray = GetFilesInfoList(m_filePath,fExtArray);
		EnumerateFile(fInfoArray);
	}
}

function int getIndexOfCurrentDrive()
{
	local int idx, num;
	local string rootDrive;
	idx = InStr(m_filePath,"\\");

	if ( idx >= 0 )
		rootDrive = Left(m_filePath,idx);
	else
		rootDrive = m_filePath;

	num = FilePathComboBoxCtrl.GetNumOfItems();
	for ( idx = 0; idx < num; ++idx )
		if ( rootDrive == FilePathComboBoxCtrl.GetString(idx) )
			return idx;

	return -1;
}

function int getIndexOfCurrentFolder()
{
	local int s, i;
	local string str;
	str = m_filePath;

	for ( s = getIndexOfCurrentDrive(); InStr(str,"\\") >= 0; ++s )
	{
		i = InStr(str,"\\");
		str=Right(str,Len(str) - i - 1);
		if ( Len(str) <= 0 ) break;
	}

	return s;
}

function OnClickButton( string strID )
{
	local string editStr, filePath;
	local int index;
	local LVDataRecord record;

	switch( strID )
	{
	case "FLWButtonOK" :
		
		editStr = EditBoxCtrl.GetString();
		index = SearchFileListWithName(editStr);
		if ( index < 0 )
		{
			EditBoxCtrl.Clear();
			break;
		}
		FileListCtrl.GetRec(index, record);

		if ( record.nReserved1 == 1 )
		{
			m_fileName = record.LVDataList[0].szData;
			if ( UploadFile(m_filePath, m_fileName) )
				Me.HideWindow();
			else
				;
		}
		else
		{
			filePath = m_filePath $ record.LVDataList[0].szData;
			SetFilePathnAdjustControl(filePath);
		}
		break;
	case "FLWButtonCancel":
		Me.HideWindow();
		break;
	case "FLWButtonUp":
		index = InStrFromBack(m_filePath,"\\");
		if ( index >= 0 )
		{
			editStr = Left(m_filePath,index);
			SetFilePathnAdjustControl(editStr);
		}
		break;
	}
}
defaultproperties
{
}
