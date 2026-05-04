//class ReplayListWnd extends UIScript;
class ReplayListWnd extends UICommonAPI;


const REPLAY_DIR="..\\REPLAY";
const REPLAY_EXTENSION=".L2R";

const DIALOG_DEL_CONFIRM = 8889;

var Array<string> m_StrFileList;

var ListCtrlHandle m_hRecordList;
var CheckBoxHandle m_hChkCameraInst;
var CheckBoxHandle m_hChkChatData;

function OnLoad()
{	
	m_hRecordList=GetListCtrlHandle("ReplayListWnd.ReplayListCtrl");
	m_hChkCameraInst=GetCheckBoxHandle("ReplayListWnd.chkLoadCamInst");
	m_hChkChatData=GetCheckBoxHandle("ReplayListWnd.chkLoadChatData");		
}

function OnShow()
{
	InitReplayList();
}

function OnRegisterEvent()
{	
	registerEvent( EV_DialogOK );
	registerEvent( EV_DialogCancel );	
}

function InitReplayList()
{
	local Array<string> strReplayFileList;
	local int i;
	local int iLength;
	local string strFileName;

	// 있던 아이템 지워주고
	m_hRecordList.DeleteAllItem();

	// 파일 리스트 얻어와서 넣어준다
	GetFileList(strReplayFileList, REPLAY_DIR, REPLAY_EXTENSION);

	for(i=0; i<strReplayFileList.Length; ++i)
	{
		iLength=Len(strReplayFileList[i])-Len(REPLAY_EXTENSION);
		strFileName=Left(strReplayFileList[i], iLength);
		AddItem(i, strFileName);
	}
}


function OnEvent( int Event_ID, string param )
{
	switch(Event_ID)
	{
		case EV_DialogOK:		
			HandleDialogOK();
			break;
		case EV_DialogCancel:
			//HandleDialogCancle();		
			break;
	}
}

function AddItem(int iNum, string strFileName)
{
	local LVDataRecord	record;
	local LVData		data;

	data.szData = string(iNum);
	record.LVDataList[0] = data;
	data.szData = strFileName;
	record.LVDataList[1] = data;
	m_hRecordList.InsertRecord(record );
}

function string GetSelectedFileName()
{
	local int index;
	local LVDataRecord record;
	local string strFileName;

	index = m_hRecordList.GetSelectedIndex();

	if( index >= 0 )
	{
		m_hRecordList.GetRec(index, record);
		strFileName=record.LVDataList[1].szData;
	}

	return strFileName;
}

function OnDBClickListCtrlRecord( string ListCtrlID)
{
	OnOK();
}

function HandleDialogOK()
{
	local int ID;
	
	if( DialogIsMine() )
	{
		ID = DialogGetID();	
		
		if( id == DIALOG_DEL_CONFIRM )
		{
			
			OnDelete();
			InitReplayList();		
		}		
	}
}

function askDelDialog()
{
	local WindowHandle m_dialogWnd;	
	local string strFileName;
	strFileName=GetSelectedFileName();
	if(strFileName=="")
		return;

	m_dialogWnd = GetWindowHandle( "DialogBox" );
	if( !m_dialogWnd.IsShowWindow())
	{
		DialogSetID( DIALOG_DEL_CONFIRM );
		DialogShow(DialogModalType_Modal, DialogType_OKCancel, GetSystemMessage(3719), string(Self)); //메시지 바꿀 것
	}
}


function OnClickButton(string strID)
{
	switch(strID)
	{
	case "btnOK" :
		OnOK();
		break;
	case "btnDel" :
		askDelDialog();			
		break;
	case "btnCancel" :
		SetUIState("LoginState");
		break;
	
	}
}

function OnOK()
{
	local string strFileName;
	local bool bLoadCameraInst;
	local bool bLoadChatData;
	
	strFileName=GetSelectedFileName();

	if(strFileName=="")
		return;

	bLoadCameraInst=m_hChkCameraInst.IsChecked();
	bLoadChatData=m_hChkChatData.IsChecked();

	BeginReplay(strFileName, bLoadCameraInst, bLoadChatData);
}

function OnDelete()
{
	local string strFileName;

	strFileName=GetSelectedFileName();

	if(strFileName=="")
		return;

	EraseReplayFile(REPLAY_DIR$"\\"$strFileName$""$REPLAY_EXTENSION);
}
defaultproperties
{
}
