class SceneEditorWnd extends UICommonAPI;

const UC_EXT = ".uc";
const PREV_DIR = "..";

var WindowHandle Me;

var ListBoxHandle lstFiles;
var EditBoxHandle editPath;

var EditBoxHandle editNear;
var EditBoxHandle editFar;
var EditBoxHandle editPlayRate;
var EditBoxHandle editVoiceOption;
var EditBoxHandle editSkipTo;
var EditBoxHandle editPlayTo;

var CheckBoxHandle	ForcePlayCheckBox;
var CheckBoxHandle	EscapableCheckBox;

var CheckBoxHandle	ShowMyPCCheckBox;
var CheckBoxHandle	ShowOtherPCsCheckBox;

/**** SCENEDATAEDIT ****/

var TextBoxHandle txtSceneDataFile;
var TextBoxHandle txtSceneDataIndex;

var EditBoxHandle editSceneTime;
var EditBoxHandle editScenePlayRate;
var EditBoxHandle editSceneDesc;


/**** SDE - PROPERTY ****/

var WindowHandle				CAMERA;
var WindowHandle				NPC;
var WindowHandle				PC;
var WindowHandle				MUSIC;
var WindowHandle				SCREEN;
var WindowHandle				CurrentData;

var PropertyControllerHandle	ctlPropertyCAMERA;
var PropertyControllerHandle	ctlPropertyNPC;
var PropertyControllerHandle	ctlPropertyPC;
var PropertyControllerHandle	ctlPropertyMUSIC;
var PropertyControllerHandle	ctlPropertySCREEN;

var WindowHandle			SceneCameraWnd;
var WindowHandle			SceneNpcWnd;
var WindowHandle			ScenePcWnd;
var WindowHandle			SceneScreenWnd;
var WindowHandle			SceneMusicWnd;

var SceneCameraCtrlHandle	SceneCameraCtrl;
var SceneNpcCtrlHandle		SceneNpcCtrl;
var ScenePcCtrlHandle		ScenePcCtrl;
var SceneScreenCtrlHandle	SceneScreenCtrl;
var SceneMusicCtrlHandle	SceneMusicCtrl;



/**** TIMELINE ****/

var array<WindowHandle> TimeLineItem;
var array<TextBoxHandle> TimeLineItem_Index;
var array<TextBoxHandle> TimeLineItem_Time;
var array<TextBoxHandle> TimeLineItem_Desc;
var array<TextureHandle> TimeLineItem_Outline;

var EditBoxHandle editAddSceneNo;
var EditBoxHandle editDeleteSceneNo;
var EditBoxHandle editSrcSceneNo;
var EditBoxHandle editDestSceneNo;



////

var string	m_CurPath;
var	string	m_CurFileName;

var int		m_CurIndex;
var int		m_ShowStartIndex;
var int		m_NumOfScene;

var array<string> TimeLineIndex;
var array<string> TimeLineTime;
var array<string> TimeLineDesc;


function OnRegisterEvent()
{
	RegisterEvent( EV_DialogOK );
	RegisterEvent( EV_SceneListUpdate );
	RegisterEvent( EV_UpdateSceneTreeData );
}

function OnLoad()
{
	if( CREATE_ON_DEMAND == 0 )
		OnRegisterEvent();

	if( CREATE_ON_DEMAND == 0 )
		Initialize();
	else
		InitializeCOD();

	InitValue();
	InitControlItem();
	UpdatePath();

	// 빈거 하나 New 해줌;
	class'SceneEditorAPI'.static.InitSceneEditorData();
	class'SceneEditorAPI'.static.AddScene(-1);
	txtSceneDataFile.SetText( "New File" );
	SetSceneDataIndex();
}

function OnShow()
{
	SceneFileModifyCheck();
}

function SceneFileModifyCheck( optional bool ShowNoNeedMsg )
{
	local bool isReload;
	isReload = class'SceneEditorAPI'.static.IsReloadSceneData();

	if( isReload )
	{
		DialogSetID(3003);
		DialogSetDefaultOK();
		DialogShow( DialogModalType_Modalless, DialogType_OKCancel, "Scene files has been modified.       Do you wanna reload LineageSceneInfo.u?", string(Self) );
	}
	else if( ShowNoNeedMsg )
	{
		DialogSetID(3333);
		DialogSetDefaultOK();
		DialogShow( DialogModalType_Modalless, DialogType_OK, "바뀐 파일이 없습니다.", string(Self) );
	}
}

function Initialize()
{
	local int i;

	Me = GetHandle( "SceneEditorWnd" );

	lstFiles			= ListBoxHandle ( GetHandle( "SceneEditorWnd.FileManager.lstFiles" ) );
	editPath			= EditBoxHandle ( GetHandle( "SceneEditorWnd.FileManager.editPath" ) );

	/**** PLAYMANAGER ****/

	ForcePlayCheckBox	= CheckBoxHandle (	GetHandle( "SceneEditorWnd.PlayManager.PlayModeBox" ) );
	EscapableCheckBox	= CheckBoxHandle (	GetHandle( "SceneEditorWnd.PlayManager.EscapableBox" ) );
	
	ShowMyPCCheckBox	= CheckBoxHandle (	GetHandle( "SceneEditorWnd.PlayManager.ShowMyPCBox" ) );
	ShowOtherPCsCheckBox= CheckBoxHandle (	GetHandle( "SceneEditorWnd.PlayManager.ShowOtherPCsBox" ) );
	
	editPlayRate		= EditBoxHandle (	GetHandle( "SceneEditorWnd.PlayManager.editPlayRate" ) );
	editNear			= EditBoxHandle ( GetHandle( "SceneEditorWnd.PlayManager.editNear" ) );
	editFar				= EditBoxHandle ( GetHandle( "SceneEditorWnd.PlayManager.editFar" ) );
	editVoiceOption		= EditBoxHandle (	GetHandle( "SceneEditorWnd.PlayManager.editVoiceOption" ) );
	editSkipTo			= EditBoxHandle (	GetHandle( "SceneEditorWnd.PlayManager.editSkipTo" ) );
	editPlayTo			= EditBoxHandle (	GetHandle( "SceneEditorWnd.PlayManager.editPlayTo" ) );


	/**** SCENEDATAEDIT ****/
	
	txtSceneDataFile	= TextBoxHandle( GetHandle( "SceneEditorWnd.SceneDataEdit.txtSceneDataFile" ) );
	txtSceneDataIndex	= TextBoxHandle( GetHandle( "SceneEditorWnd.SceneDataEdit.txtSceneDataIndex" ) );

	editSceneTime		= EditBoxHandle( GetHandle( "SceneEditorWnd.SceneDataEdit.editSceneTime" ) );
	editScenePlayRate	= EditBoxHandle( GetHandle( "SceneEditorWnd.SceneDataEdit.editScenePlayRate" ) );
	editSceneDesc		= EditBoxHandle( GetHandle( "SceneEditorWnd.SceneDataEdit.editSceneDesc" ) );

	/**** SDE - PROPERTY ****/

	CAMERA				= GetHandle( "SceneEditorWnd.SceneDataEdit.CAMERA" );
	NPC					= GetHandle( "SceneEditorWnd.SceneDataEdit.NPC" );
	PC					= GetHandle( "SceneEditorWnd.SceneDataEdit.PC" );
	MUSIC				= GetHandle( "SceneEditorWnd.SceneDataEdit.MUSIC" );
	SCREEN				= GetHandle( "SceneEditorWnd.SceneDataEdit.SCREEN" );

	ctlPropertyCAMERA	= PropertyControllerHandle( GetHandle( "SceneEditorWnd.SceneDataEdit.CAMERA.ctlPropertyCAMERA" ) );
	ctlPropertyNPC		= PropertyControllerHandle( GetHandle( "SceneEditorWnd.SceneDataEdit.NPC.ctlPropertyNPC" ) );
	ctlPropertyPC		= PropertyControllerHandle( GetHandle( "SceneEditorWnd.SceneDataEdit.PC.ctlPropertyPC" ) );
	ctlPropertyMUSIC	= PropertyControllerHandle( GetHandle( "SceneEditorWnd.SceneDataEdit.MUSIC.ctlPropertyMUSIC" ) );
	ctlPropertySCREEN	= PropertyControllerHandle( GetHandle( "SceneEditorWnd.SceneDataEdit.SCREEN.ctlPropertySCREEN" ) );


	/**** TIMELINE ****/

	for( i = 0; i < 5; ++i)
	{
		TimeLineItem[i]			= GetHandle( "SceneEditorWnd.TimeLine.TimeLineItem" $ i );
		TimeLineItem_Index[i]	= TextBoxHandle( GetHandle( "SceneEditorWnd.TimeLine.TimeLineItem" $ i $ ".Index" ) );
		TimeLineItem_Time[i]	= TextBoxHandle( GetHandle( "SceneEditorWnd.TimeLine.TimeLineItem" $ i $ ".Time" ) );
		TimeLineItem_Desc[i]	= TextBoxHandle( GetHandle( "SceneEditorWnd.TimeLine.TimeLineItem" $ i $ ".Desc" ) );
		TimeLineItem_Outline[i]	= TextureHandle( GetHandle( "SceneEditorWnd.TimeLine.TimeLineItem" $ i $ ".BackTex_Outline" ) );
	}

	editAddSceneNo		= EditBoxHandle ( GetHandle( "SceneEditorWnd.TimeLine.editAddSceneNo" ) );
	editDeleteSceneNo	= EditBoxHandle ( GetHandle( "SceneEditorWnd.TimeLine.editDeleteSceneNo" ) );
	editSrcSceneNo		= EditBoxHandle ( GetHandle( "SceneEditorWnd.TimeLine.editSrcSceneNo" ) );
	editDestSceneNo		= EditBoxHandle ( GetHandle( "SceneEditorWnd.TimeLine.editDestSceneNo" ) );
}

function InitializeCOD()
{
	local int i;

	Me					= GetWindowHandle( "SceneEditorWnd" );

	lstFiles			= GetListBoxHandle( "SceneEditorWnd.FileManager.lstFiles" );
	editPath			= GetEditBoxHandle( "SceneEditorWnd.FileManager.editPath" );

	/**** PLAYMANAGER ****/

	ForcePlayCheckBox	= GetCheckBoxHandle( "SceneEditorWnd.PlayModeBox" );
	EscapableCheckBox	= GetCheckBoxHandle( "SceneEditorWnd.EscapableBox" );
	
	ShowMyPCCheckBox	= GetCheckBoxHandle( "SceneEditorWnd.ShowMyPCBox" ) ;
	ShowOtherPCsCheckBox= GetCheckBoxHandle( "SceneEditorWnd.ShowOtherPCsBox" ) ;
	
	
	editPlayRate		= GetEditBoxHandle( "SceneEditorWnd.PlayManager.editPlayRate" );
	editNear			= GetEditBoxHandle( "SceneEditorWnd.PlayManager.editNear" );
	editFar				= GetEditBoxHandle( "SceneEditorWnd.PlayManager.editFar" );	
	editVoiceOption		= GetEditBoxHandle( "SceneEditorWnd.PlayManager.editVoiceOption" );
	editSkipTo			= GetEditBoxHandle( "SceneEditorWnd.PlayManager.editSkipTo" );	
	editPlayTo			= GetEditBoxHandle( "SceneEditorWnd.PlayManager.editPlayTo" );


	/**** SCENEDATAEDIT ****/

	txtSceneDataFile	= GetTextBoxHandle( "SceneEditorWnd.SceneDataEdit.txtSceneDataFile" );
	txtSceneDataIndex	= GetTextBoxHandle( "SceneEditorWnd.SceneDataEdit.txtSceneDataIndex" );

	editSceneTime		= GetEditBoxHandle( "SceneEditorWnd.SceneDataEdit.editSceneTime" );
	editScenePlayRate	= GetEditBoxHandle( "SceneEditorWnd.SceneDataEdit.editScenePlayRate" );
	editSceneDesc		= GetEditBoxHandle( "SceneEditorWnd.SceneDataEdit.editSceneDesc" );

	/**** SDE - PROPERTY ****/

	CAMERA				= GetWindowHandle( "SceneEditorWnd.SceneDataEdit.CAMERA" );
	NPC					= GetWindowHandle( "SceneEditorWnd.SceneDataEdit.NPC" );
	PC					= GetWindowHandle( "SceneEditorWnd.SceneDataEdit.PC" );
	MUSIC				= GetWindowHandle( "SceneEditorWnd.SceneDataEdit.MUSIC" );
	SCREEN				= GetWindowHandle( "SceneEditorWnd.SceneDataEdit.SCREEN" );

	ctlPropertyCAMERA	= GetPropertyControllerHandle( "SceneEditorWnd.SceneDataEdit.CAMERA.ctlPropertyCAMERA" );
	ctlPropertyNPC		= GetPropertyControllerHandle( "SceneEditorWnd.SceneDataEdit.NPC.ctlPropertyNPC" );
	ctlPropertyPC		= GetPropertyControllerHandle( "SceneEditorWnd.SceneDataEdit.PC.ctlPropertyPC" );
	ctlPropertyMUSIC	= GetPropertyControllerHandle( "SceneEditorWnd.SceneDataEdit.MUSIC.ctlPropertyMUSIC" );
	ctlPropertySCREEN	= GetPropertyControllerHandle( "SceneEditorWnd.SceneDataEdit.SCREEN.ctlPropertySCREEN" );


	/**** TIMELINE ****/

	for( i = 0; i < 5; ++i)
	{
		TimeLineItem[i]			= GetWindowHandle( "SceneEditorWnd.TimeLine.TimeLineItem" $ i );
		TimeLineItem_Index[i]	= GetTextBoxHandle( "SceneEditorWnd.TimeLine.TimeLineItem" $ i $ ".Index" );
		TimeLineItem_Time[i]	= GetTextBoxHandle( "SceneEditorWnd.TimeLine.TimeLineItem" $ i $ ".Time" );
		TimeLineItem_Desc[i]	= GetTextBoxHandle( "SceneEditorWnd.TimeLine.TimeLineItem" $ i $ ".Desc" );
		TimeLineItem_Outline[i]	= GetTextureHandle( "SceneEditorWnd.TimeLine.TimeLineItem" $ i $ ".BackTex_Outline" );
	}

	editAddSceneNo		= GetEditBoxHandle( "SceneEditorWnd.TimeLine.editAddSceneNo" );
	editDeleteSceneNo	= GetEditBoxHandle( "SceneEditorWnd.TimeLine.editDeleteSceneNo" );
	editSrcSceneNo		= GetEditBoxHandle( "SceneEditorWnd.TimeLine.editSrcSceneNo" );
	editDestSceneNo		= GetEditBoxHandle( "SceneEditorWnd.TimeLine.editDestSceneNo" );
}

function ResetIndex()
{
	m_CurIndex = -1;
	m_ShowStartIndex = 0;
}

function int GetRealIndex( int ShowIndex )
{
	return ( ShowIndex + m_ShowStartIndex );
}
function int GetShowIndex( int RealIndex )
{
	return ( RealIndex - m_ShowStartIndex );
}

function SetShowStartIndex( int Index )
{
	local int OldIndex;
	OldIndex = m_ShowStartIndex;

	m_ShowStartIndex = Index;
	
	if( (m_ShowStartIndex + 4) >= m_NumOfScene )
	{
		m_ShowStartIndex = m_NumOfScene - 5;
	}

	if( m_ShowStartIndex < 0 )
	{
		m_ShowStartIndex = 0;
	}

	if( m_ShowStartIndex != OldIndex )
	{
		SetTimeLineItemText();
		SetOutlineTexture( GetShowIndex( m_CurIndex ) );
	}
}

function SetTimeLineItemText()
{
	local int i;
	local int RealIndex;
	RealIndex = m_ShowStartIndex;

	for( i = 0; i < 5; ++i )
	{
		if( RealIndex >= m_NumOfScene )
		{
			TimeLineItem_Index[i].SetText( "..." );
			TimeLineItem_Time[i].SetText( "..." );
			TimeLineItem_Desc[i].SetText( "..." );
		}
		else
		{
			TimeLineItem_Index[i].SetText( TimeLineIndex[RealIndex] );
			TimeLineItem_Time[i].SetText( TimeLineTime[RealIndex] );
			TimeLineItem_Desc[i].SetText( TimeLineDesc[RealIndex] );
		}
		++RealIndex;
	}
}

function InitValue()
{		
	local int PathLength;

	editPlayRate.SetString( string(1.f) );

	editNear.SetString( string(-1.f) );
	editFar.SetString( string(-1.f) );

	m_NumOfScene = 0;
	ResetIndex();

	// Set Title
	Me.SetWindowTitle("Scene Editor");

	// Path
	m_CurPath = GetOptionString( "ScenePlayer", "DefaultPath" );
	if( Len(m_CurPath) < 1 )
	{
		m_CurPath = GetSystemDir();
		PathLength = Len( m_CurPath );
		m_CurPath = Left( m_CurPath, PathLength - 6 ); // System 6글자
		m_CurPath = m_CurPath $ "LineageSceneInfo\\Classes\\";

	}
	editPath.SetString( m_CurPath );
}

function InitControlItem()
{
	// Camera Ctrl
	SceneCameraWnd = Me.AddChildWnd( XCT_FrameWnd );
	SceneCameraWnd.SetWindowSize( 0, 0 );
	SceneCameraWnd.SetBackTexture("");

	SceneCameraCtrl = SceneCameraCtrlHandle(SceneCameraWnd.AddChildWnd( XCT_SceneCameraCtrl ));
	if( SceneCameraCtrl != None )
	{
		SceneCameraCtrl.SetWindowSize( 0, 0 );

		ctlPropertyCAMERA.SetProperty( SceneCameraCtrl.GetControlType(), SceneCameraCtrl );
		ctlPropertyCAMERA.SetGroupVisible( "DefaultProperty", false );
		CAMERA.SetScrollHeight( ctlPropertyCAMERA.GetPropertyHeight() );
		CAMERA.SetScrollPosition( 0 );
	}

	// Npc Ctrl
	SceneNpcWnd = Me.AddChildWnd( XCT_FrameWnd );
	SceneNpcWnd.SetWindowSize( 0, 0 );
	SceneNpcWnd.SetBackTexture("");

	SceneNpcCtrl = SceneNpcCtrlHandle(SceneNpcWnd.AddChildWnd( XCT_SceneNpcCtrl ));
	if( SceneNpcCtrl != None )
	{
		SceneNpcCtrl.SetWindowSize( 0, 0 );

		ctlPropertyNPC.SetProperty( SceneNpcCtrl.GetControlType(), SceneNpcCtrl );
		ctlPropertyNPC.SetGroupVisible( "DefaultProperty", false );
		NPC.SetScrollHeight( ctlPropertyNPC.GetPropertyHeight() );
		NPC.SetScrollPosition( 0 );
	}

	// Pc Ctrl
	ScenePcWnd = Me.AddChildWnd( XCT_FrameWnd );
	ScenePcWnd.SetWindowSize( 0, 0 );
	ScenePcWnd.SetBackTexture("");

	ScenePcCtrl = ScenePcCtrlHandle(ScenePcWnd.AddChildWnd( XCT_ScenePcCtrl ));
	if( ScenePcCtrl != None )
	{
		ScenePcCtrl.SetWindowSize( 0, 0 );

		ctlPropertyPC.SetProperty( ScenePcCtrl.GetControlType(), ScenePcCtrl );
		ctlPropertyPC.SetGroupVisible( "DefaultProperty", false );
		PC.SetScrollHeight( ctlPropertyPC.GetPropertyHeight() );
		PC.SetScrollPosition( 0 );
	}

	// Music Ctrl
	SceneMusicWnd = Me.AddChildWnd( XCT_FrameWnd );
	SceneMusicWnd.SetWindowSize( 0, 0 );
	SceneMusicWnd.SetBackTexture("");

	SceneMusicCtrl = SceneMusicCtrlHandle(SceneMusicWnd.AddChildWnd( XCT_SceneMusicCtrl ));
	if( SceneMusicCtrl != None )
	{
		SceneMusicCtrl.SetWindowSize( 0, 0 );

		ctlPropertyMUSIC.SetProperty( SceneMusicCtrl.GetControlType(), SceneMusicCtrl );
		ctlPropertyMUSIC.SetGroupVisible( "DefaultProperty", false );
		MUSIC.SetScrollHeight( ctlPropertyMUSIC.GetPropertyHeight() );
		MUSIC.SetScrollPosition( 0 );
	}

	// Screen Ctrl
	SceneScreenWnd = Me.AddChildWnd( XCT_FrameWnd );
	SceneScreenWnd.SetWindowSize( 0, 0 );
	SceneScreenWnd.SetBackTexture("");

	SceneScreenCtrl = SceneScreenCtrlHandle(SceneScreenWnd.AddChildWnd( XCT_SceneScreenCtrl ));
	if( SceneScreenCtrl != None )
	{
		SceneScreenCtrl.SetWindowSize( 0, 0 );

		ctlPropertySCREEN.SetProperty( SceneScreenCtrl.GetControlType(), SceneScreenCtrl );
		ctlPropertySCREEN.SetGroupVisible( "DefaultProperty", false );
		SCREEN.SetScrollHeight( ctlPropertySCREEN.GetPropertyHeight() );
		SCREEN.SetScrollPosition( 0 );
	}
}

function OnPropertyControllerResize( PropertyControllerHandle a_PropertyHandle, int a_Height )
{
	a_Height += 50;

	if( a_PropertyHandle == ctlPropertyCAMERA )
	{
		CAMERA.SetScrollHeight( a_Height  );
	}
	else if( a_PropertyHandle == ctlPropertyNPC )
	{
		NPC.SetScrollHeight( a_Height );
	}
	else if( a_PropertyHandle == ctlPropertyPC )
	{
		PC.SetScrollHeight( a_Height );
	}
	else if( a_PropertyHandle == ctlPropertyMUSIC )
	{
		MUSIC.SetScrollHeight( a_Height );
	}
	else if( a_PropertyHandle == ctlPropertySCREEN )
	{
		SCREEN.SetScrollHeight( a_Height );
	}
}

function OnEvent(int Event_ID, String param)
{
	local string FileName;
	local bool Success;
	local bool bForceToPlay;
	local bool bEscapable;
	
	local bool bShowMyPC;
	local bool bShowOtherPCs;
	
	local float NearPlane;
	local float FarPlane;

	if( Event_ID == EV_SceneListUpdate )
	{
		HandleSceneListUpdate(param);
	}
	else if( Event_ID == EV_UpdateSceneTreeData )
	{
		UpdateTimeLine(param);
	}
	else if ( Event_ID == EV_DialogOK )
	{
		if( DialogIsMine() )
		{
			if( DialogGetID() == 1001 ) // LOAD
			{
				FileName = DialogGetString();
				if( Len(FileName) < 1 )
					return;

				class'SceneEditorAPI'.static.InitSceneEditorData();
				class'SceneEditorAPI'.static.LoadSceneData(FileName);

				ResetIndex();
				SetOutlineTexture(-1);
				m_CurFileName = FileName;
				txtSceneDataFile.SetText( FileName );
				SetSceneDataIndex();

				UpdatePath();
			}
			else if( DialogGetID() == 2002 ) // SAVE
			{
				FileName = DialogGetString();
				if( Len(FileName) < 1 )
					return;
				bForceToPlay = class'UIAPI_CHECKBOX'.static.IsChecked( "SceneEditorWnd.PlayModeBox" );
				bEscapable = class'UIAPI_CHECKBOX'.static.IsChecked( "SceneEditorWnd.EscapableBox" );
				
				bShowMyPC = class'UIAPI_CHECKBOX'.static.IsChecked( "SceneEditorWnd.ShowMyPCBox" );
				bShowOtherPCs = class'UIAPI_CHECKBOX'.static.IsChecked( "SceneEditorWnd.ShowOtherPCsBox" );
				
				NearPlane = float( editNear.GetString() );
				FarPlane = float( editFar.GetString() );
					
				Success = class'SceneEditorAPI'.static.SaveSceneData(FileName, m_CurPath, bForceToPlay, bEscapable, bShowMyPC, bShowOtherPCs, 1.0f, NearPlane, FarPlane);
				
				if( Success )
				{	
					DialogSetID(2222);
					DialogSetDefaultOK();
					DialogShow( DialogModalType_Modalless, DialogType_OK, "저장 성공 - " $ FileName, string(Self) );
					m_CurFileName = FileName;
				}
				else
				{
					DialogSetID(2222);
					DialogSetDefaultOK();
					DialogShow( DialogModalType_Modalless, DialogType_OK, "저장 실패 - " $ FileName, string(Self) );
				}
			}
			else if( DialogGetID() == 3003 )
			{
				class'SceneEditorAPI'.static.ReloadSceneData();
			}
			else if( DialogGetID() == 4004 ) // NEW
			{
					class'SceneEditorAPI'.static.InitSceneEditorData();
					class'SceneEditorAPI'.static.AddScene(-1);

					ResetIndex();
					SetOutlineTexture(-1);
					m_CurFileName = "";
					txtSceneDataFile.SetText( "New File" );
					SetSceneDataIndex();
			}
		}
	}
}

function UpdateTimeLine( string param )
{
	local int ShowIndex;
	local int Index;
	local int Time;
	local string Desc;
	local float PlayRate;

	ParseInt(param, "Index", Index);
	ParseInt(param, "Time", Time);
	ParseString(param, "Desc", Desc);
	ParseFloat(param, "PlayRate", PlayRate);

	TimeLineIndex[Index] = string(Index);
	TimeLineTime[Index] = string(Time);
	TimeLineDesc[Index] = Desc;

	ShowIndex = GetShowIndex( Index );
	if( 0 <= ShowIndex && ShowIndex < 5 )
	{
//		TimeLineItem_Index[ShowIndex].SetText( string(Index) );
		TimeLineItem_Time[ShowIndex].SetText( string(Time) );
		TimeLineItem_Desc[ShowIndex].SetText( Desc );
	}
}

function SetOutlineTexture( int Index )
{
	local int i;
	for( i = 0; i < 5; ++i )
	{
		if( i == Index )
		{
			TimeLineItem_Outline[i].SetTexture( "L2UI_ch3.Etc.Menu_Outline_Over" );
		}
		else
		{
			TimeLineItem_Outline[i].SetTexture( "L2UI_ch3.Etc.Menu_Outline" );
		}
	}
}

function OnLButtonDown(WindowHandle a_WindowHandle, int X, int Y)
{
	local int i;
	local int ShowIndex;

//	if(a_WindowHandle.GetParentWindowHandle() == TimeLineItem[1] )
//	TextBox 는 부모로 LButtonDown 을 넘기기 때문에 굳이 이렇게 안해도 됨

	ShowIndex = -1;
	for( i = 0; i < 5; ++i )
	{
		if( a_WindowHandle == TimeLineItem[i] )
		{
			ShowIndex = i;
			break;
		}
	}

	if( ShowIndex < 0 )
		return;

	if( GetRealIndex( ShowIndex ) >= m_NumOfScene )
		return;

	SceneDataSave();

	SetOutlineTexture( ShowIndex );

	m_CurIndex = GetRealIndex( ShowIndex );
	SceneDataUpdate();
}

function OnClickButton( string Name )
{
	switch( Name )
	{
	case "btnGo":
		OnbtnGoClick();
		break;
	case "btnNew":
		OnbtnNewClick();
		break;
	case "btnLoad":
		OnbtnLoadClick();
		break;
	case "btnReload":
		OnbtnReloadClick();
		break;
	case "btnSave":
		OnbtnSaveClick();
		break;
	case "btnPlay":
		OnbtnPlayClick();
		break;
	case "btnAdd":
		OnbtnAddClick();
		break;
	case "btnDelete":
		OnbtnDeleteClick();
		break;
	case "btnCopy":
		OnbtnCopyClick();
		break;
	case "btnTimeLinePre":
		SetShowStartIndex( m_ShowStartIndex - 1);
		break;
	case "btnTimeLineNext":
		SetShowStartIndex( m_ShowStartIndex + 1 );
		break;
	case "btnTimeLineFirst":
		SetShowStartIndex( 0 );
		break;
	case "btnTimeLineLast":
		SetShowStartIndex( m_NumOfScene - 4 );
		break;
	}
}

function OnCompleteEditBox( String strID )
{
	switch( strID )
	{	
	case "editSceneTime":
	case "editSceneDesc":
	case "editScenePlayRate":
		SceneDataSave();
		break;

	case "editPath":
		OnbtnGoClick();
		break;
	}
}

function OnbtnGoClick()
{
	m_CurPath = editPath.GetString();
	UpdatePath();
}

function OnbtnNewClick()
{
	DialogSetID(4004);
	DialogSetDefaultOK();
	DialogShow( DialogModalType_Modalless, DialogType_OKCancel, "현재 수정중인 사항이 사라집니다. 계속하시겠습니까?", string(Self) );
}

function OnbtnLoadClick()
{
	local string FileName;
	FileName = lstFiles.GetSelectedString();
	FileName = Left( FileName, Len(FileName)-3 );

	DialogSetEditBoxMaxLength(100);
	DialogSetID(1001);
	DialogSetDefaultOK();
	DialogShow( DialogModalType_Modalless, DialogType_OKCancelInput, "Input Scene Name.", string(Self) );
	DialogSetString( FileName );
}

function OnbtnReloadClick()
{
	SceneFileModifyCheck( true );
}

function OnbtnSaveClick()
{
	SceneDataSave();
	
	DialogSetEditBoxMaxLength(100);
	DialogSetID(2002);
	DialogSetDefaultOK();
	DialogShow( DialogModalType_Modalless, DialogType_OKCancelInput, "Input Scene Name.", string(Self) );
	DialogSetString( m_CurFileName );
}

function OnbtnPlayClick()
{
	local String Tmp;
	local int SkipTo;
	local int PlayTo;
	local int VoiceOption;
	local bool bShowInfo;
	local bool bReShow;

	local bool bForceToPlay;
	local bool bEscapable;
	
	local bool bShowMyPC;
	local bool bShowOtherPCs;
	
	local float playRate;
	local float NearClippingPlane;
	local float FarClippingPlane;

	SceneDataSave();

	Tmp = editSkipTo.GetString();
	if( Len(Tmp) > 0 )
		SkipTo = int( Tmp );
	else
		SkipTo = -1;

	Tmp = editPlayTo.GetString();
	if( Len(Tmp) > 0 )
		PlayTo = int( Tmp );
	else
		PlayTo = -1;

	if( PlayTo < 0 )
	{
		DialogShow( DialogModalType_Modalless, DialogType_OK, "어디까지 플레이 하실 건가여?", string(Self) );
		return;
	}

	Tmp = editVoiceOption.GetString();
	if( Len(Tmp) > 0 )
		VoiceOption = int( Tmp );
	else
		VoiceOption = -1;
	
	bForceToPlay = class'UIAPI_CHECKBOX'.static.IsChecked( "SceneEditorWnd.PlayModeBox" );
	bEscapable = class'UIAPI_CHECKBOX'.static.IsChecked( "SceneEditorWnd.EscapableBox" );
	
	bShowMyPC = class'UIAPI_CHECKBOX'.static.IsChecked( "SceneEditorWnd.ShowMyPCBox" );
	bShowOtherPCs = class'UIAPI_CHECKBOX'.static.IsChecked( "SceneEditorWnd.ShowOtherPCsBox" );
	
	playRate = float( editPlayRate.GetString() );
	NearClippingPlane = float( editNear.GetString() );
	FarClippingPlane = float( editFar.GetString() );
	
	class'SceneEditorAPI'.static.SetSceneInfoAttribute(
		bForceToPlay, 
		bEscapable, 
		bShowMyPC,
		bShowOtherPCs,
		playRate,
		NearClippingPlane, 
		FarClippingPlane
		);

	bShowInfo = class'UIAPI_CHECKBOX'.static.IsChecked( "SceneEditorWnd.PlayManager.InfoBox" );
	bReShow = class'UIAPI_CHECKBOX'.static.IsChecked( "SceneEditorWnd.PlayManager.ReShow" );
	class'SceneEditorAPI'.static.PlayScene( SkipTo, PlayTo, VoiceOption, bShowInfo, bReShow );
}

function OnbtnAddClick()
{
	local String Tmp;
	local int Index;
	local int OldNumOfScene;
	local int OldCurIndex;

	OldNumOfScene = m_NumOfScene;

	SceneDataSave();
	
	Tmp = editAddSceneNo.GetString();
	if( Len(Tmp) > 0 )
		Index = int( Tmp );
	else
		Index = -1;

	class'SceneEditorAPI'.static.AddScene(Index);

	if( m_NumOfScene == OldNumOfScene ) // Add Failed !!!
		return;

	OldCurIndex = m_CurIndex;

	if( Index == -1 )
	{
		m_CurIndex = m_NumOfScene - 1;
	}
	else
	{
		m_CurIndex = Index;
	}

	SceneDataUpdate();

	if( m_CurIndex < m_ShowStartIndex || ( m_ShowStartIndex + 4 ) < m_CurIndex )
	{
		SetShowStartIndex( m_CurIndex );
	}
	else if( m_CurIndex != OldCurIndex )
	{
		SetOutlineTexture( GetShowIndex( m_CurIndex ) );
	}
}

function OnbtnDeleteClick()
{
	local String Tmp;
	local int Index;

	SceneDataSave();

	Tmp = editDeleteSceneNo.GetString();
	if( Len(Tmp) > 0 )
		Index = int( Tmp );
	else
		return;
	
	class'SceneEditorAPI'.static.DeleteScene(Index);

	if( Index < m_CurIndex )
	{
		--m_CurIndex;
	}
	if( m_CurIndex >= m_NumOfScene )
	{
		m_CurIndex = m_NumOfScene - 1;
		SetOutlineTexture( GetShowIndex( m_CurIndex ) );
	}

	if( Index < m_ShowStartIndex )
	{
		SetShowStartIndex( m_ShowStartIndex - 1 );
	}
	else
	{
		SetShowStartIndex( m_ShowStartIndex );
	}
	SceneDataUpdate();
}

function OnBtnCopyClick()
{
	local String Tmp;
	local int SrcIndex;
	local int DestIndex;
	local int OldNumOfScene;
	local int OldCurIndex;

	OldNumOfScene = m_NumOfScene;

	SceneDataSave();

	Tmp = editSrcSceneNo.GetString();
	if( Len(Tmp) > 0 )
		SrcIndex = int( Tmp );
	else
		return;

	Tmp = "";
	Tmp = editDestSceneNo.GetString();
	if( Len(Tmp) > 0 )
		DestIndex = int( Tmp );
	else
		return;
	if( DestIndex > m_NumOfScene )
		DestIndex = m_NumOfScene;

	class'SceneEditorAPI'.static.CopyScene( SrcIndex, DestIndex );

	if( m_NumOfScene == OldNumOfScene ) // Copy Failed !!!
		return;

	OldCurIndex = m_CurIndex;
	m_CurIndex = DestIndex;

	SceneDataUpdate();

	if( m_CurIndex < m_ShowStartIndex || ( m_ShowStartIndex + 4 ) < m_CurIndex )
	{
		SetShowStartIndex( m_CurIndex );
	}
	else if( m_CurIndex != OldCurIndex )
	{
		SetOutlineTexture( GetShowIndex( m_CurIndex ) );
	}
}

function UpdatePath()
{
	if( Len( m_CurPath) > 0 && Right( m_CurPath, 1 ) != "\\" )
		m_CurPath = m_CurPath $ "\\";
	
	SetOptionString( "ScenePlayer", "DefaultPath", m_CurPath );
	editPath.SetString( m_CurPath );

	UpdateFileList();
}

function UpdateFileList()
{
	local int idx;
	local Color c;

	local Array<string> FileList;
	local Array<string> DirList;
	local array<DriveInfo> DriveList;	

	lstFiles.Clear();

	// Directory Color
	c.R = 255;
	c.G = 255;
	c.B = 150;

	if( Len( m_CurPath ) < 1 )
	{
		DriveList = GetDrivesInfoList();

		for( idx = 0; idx < DriveList.Length; ++idx )
		{
			DirList[idx] = DriveList[idx].driveChar;
		}
	}
	else
	{
		lstFiles.AddStringWithData( PREV_DIR, c, 1 );
		GetDirList( DirList, m_CurPath );
	}

	// Directory
	for( idx = 0; idx < DirList.Length; ++idx )
	{
		lstFiles.AddStringWithData( DirList[idx], c, 1 );
	}

	// Files
	GetFileList( FileList, m_CurPath, UC_EXT );	
	for( idx = 0; idx < FileList.Length; ++idx )
	{
		if( FileList[idx] == (m_CurFileName $ UC_EXT) )
		{
			c.R = 255;
			c.G = 0;
			c.B = 0;
		}
		else
		{
			c.R = 220;
			c.G = 220;
			c.B = 220;
		}
		lstFiles.AddStringWithData( FileList[idx], c, 0 );
	}
}

function OnDBClickListBoxItem( String strID, int SelectedIndex )
{
	local string DirName;
	local int IsDir;
	
	switch( strID )
	{
	case "lstFiles":

		IsDir = lstFiles.GetSelectedItemData();
		if( IsDir == 1 )
		{
			DirName = lstFiles.GetSelectedString();
			
			if(	DirName == PREV_DIR )
				m_CurPath = GetParentDirectory( m_CurPath );
			else
				m_CurPath = m_CurPath $ DirName;

			UpdatePath();
		}
		else if( IsDir == 0 )
		{
			OnbtnLoadClick();
		}
		break;
	}
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
	{
		return "";
	}
	
	for( idx = 0; idx < Count - 1; ++idx )
		NewPath = NewPath $ DirList[idx] $ "\\";

	return NewPath;
}

function HandleSceneListUpdate( String param )
{
	local int TotalCount;	
	local int Index;
	local int Time;
	local string Desc;
	local string ParamString;

	local int i;
	local int bNew;
	local int ForceToPlay;
	local int Escapable;
	
	local int ShowMyPC;
	local int ShowOtherPCs;
	
	local float PlayRate;
	local float SceneItemPlayRate;
	local float NearClippingPlane;
	local float FarClippingPlane;
	local string tempStr;
	
	ParseInt( param, "IsNew", bNew );
	if( bNew > 0 )
	{
		ParseInt( param, "IsForceToPlay", ForceToPlay );
		if ( ForceToPlay > 0 )
			ForcePlayCheckBox.SetCheck(true);
		else
			ForcePlayCheckBox.SetCheck(false);

		ParseInt( param, "IsEscapable", Escapable );
		if ( Escapable > 0 )
			EscapableCheckBox.SetCheck(true);
		else
			EscapableCheckBox.SetCheck(false);
			
		
		ParseInt( param, "IsShowMyPC", ShowMyPC );
		if ( ShowMyPC > 0 )
			ShowMyPCCheckBox.SetCheck(true);
		else
			ShowMyPCCheckBox.SetCheck(false);
		
		ParseInt( param, "IsShowOtherPCs", ShowOtherPCs );		
		if ( ShowOtherPCs > 0 )
			ShowOtherPCsCheckBox.SetCheck(true);
		else
			ShowOtherPCsCheckBox.SetCheck(false);

		ParseFloat( Param, "PlayRate", PlayRate );
		if( PlayRate <= 0.f)
			PlayRate = 1.f;
		tempStr = string(PlayRate);
		editPlayRate.SetString(tempStr);

		ParseFloat( Param, "NearClippingPlane", NearClippingPlane );
		tempStr = string(NearClippingPlane);
		editNear.SetString(tempStr);

		ParseFloat( Param, "FarClippingPlane", FarClippingPlane );
		tempStr = string(FarClippingPlane);
		editFar.SetString(tempStr);
	}

	ParseInt( Param, "TotalCount", TotalCount );
	if( TotalCount < 1 )
		return;	
	m_NumOfScene = TotalCount;


	TimeLineIndex.Length = m_NumOfScene;
	TimeLineTime.Length = m_NumOfScene;
	TimeLineDesc.Length = m_NumOfScene;
	for( i = 0; i < m_NumOfScene; ++i )
	{
		TimeLineIndex[i] = "";
		TimeLineTime[i] = "";
		TimeLineDesc[i] = "";
	}

	for( i = 0; i < TotalCount; ++i )
	{
		Index = i;

		Time = 0;
		ParamString = "Time" $ String(i);
		ParseInt(Param, ParamString, Time);

		Desc = "";
		ParamString = "Desc" $ String(i);
		ParseString(Param, ParamString, Desc);

		ParamString = "SceneItemPlayRate" $ String(i);
		ParseFloat(Param, ParamString, SceneItemPlayRate);

		TimeLineIndex[i] = string(Index);
		TimeLineTime[i] = string(Time);
		TimeLineDesc[i] = Desc;
	}

	SetTimeLineItemText();

	editPlayTo.SetString( string(m_NumOfScene - 1) );
}

function SetSceneDataIndex()
{
	local string InfoText;
	local Color c;

	if( m_CurIndex < 0 )
	{
		InfoText = "No Scene Selected";
		c.R = 255;
		c.G = 0;
		c.B = 0;
	}
	else
	{
		InfoText = "Scene " $ m_CurIndex;
		c.R = 255;
		c.G = 255;
		c.B = 255;
	}
	txtSceneDataIndex.SetTextColor( c );
	txtSceneDataIndex.SetText( InfoText );
}

function SceneDataUpdate()
{
	local int Time;
	local string Desc;
	local float PlayRate;

	SetSceneDataIndex();

	if( m_CurIndex < 0 )
	{
		editSceneTime.SetString( "N/A" );
		editSceneDesc.SetString( "N/A" );
		editScenePlayRate.SetString( "N/A" );

		// SceneCameraCtrl 시리즈 Clear 해주는게 필요한거 같은데... 쩜쩜쩜
		return;
	}

	class'SceneEditorAPI'.static.GetCurSceneTimeAndDesc( m_CurIndex, Time, Desc );
	editSceneTime.SetString( string(Time) );
	editSceneDesc.SetString( Desc );

	class'SceneEditorAPI'.static.GetCurScenePlayRate( m_CurIndex, PlayRate );
	editScenePlayRate.SetString( string(PlayRate) );

	// Camera Ctrl
	if( SceneCameraCtrl != None )
	{
		SceneCameraCtrl.UpdateCameraData(m_CurIndex);

		ctlPropertyCAMERA.SetProperty( SceneCameraCtrl.GetControlType(), SceneCameraCtrl );
		ctlPropertyCAMERA.SetGroupVisible( "DefaultProperty", false );
		CAMERA.SetScrollHeight( ctlPropertyCAMERA.GetPropertyHeight() );
		CAMERA.SetScrollPosition( 0 );
	}

	// Npc Ctrl
	if( SceneNpcCtrl != None )
	{
		SceneNpcCtrl.UpdateNpcData(m_CurIndex);

		ctlPropertyNPC.SetProperty( SceneNpcCtrl.GetControlType(), SceneNpcCtrl );
		ctlPropertyNPC.SetGroupVisible( "DefaultProperty", false );
		NPC.SetScrollHeight( ctlPropertyNPC.GetPropertyHeight() );
		NPC.SetScrollPosition( 0 );
	}
	
	// Pc Ctrl
	if( ScenePcCtrl != None )
	{
		ScenePcCtrl.UpdatePcData(m_CurIndex);

		ctlPropertyPC.SetProperty( ScenePcCtrl.GetControlType(), ScenePcCtrl );
		ctlPropertyPC.SetGroupVisible( "DefaultProperty", false );
		PC.SetScrollHeight( ctlPropertyPC.GetPropertyHeight() );
		PC.SetScrollPosition( 0 );
	}

	// Music Ctrl
	if( SceneMusicCtrl != None )
	{
		SceneMusicCtrl.UpdateMusicData(m_CurIndex);

		ctlPropertyMUSIC.SetProperty( SceneMusicCtrl.GetControlType(), SceneMusicCtrl );
		ctlPropertyMUSIC.SetGroupVisible( "DefaultProperty", false );
		MUSIC.SetScrollHeight( ctlPropertyMUSIC.GetPropertyHeight() );
		MUSIC.SetScrollPosition( 0 );
	}

	// Screen Ctrl		
	if( SceneScreenCtrl != None )
	{
		SceneScreenCtrl.UpdateScreenData(m_CurIndex);

		ctlPropertySCREEN.SetProperty( SceneScreenCtrl.GetControlType(), SceneScreenCtrl );
		ctlPropertySCREEN.SetGroupVisible( "DefaultProperty", false );
		SCREEN.SetScrollHeight( ctlPropertySCREEN.GetPropertyHeight() );
		SCREEN.SetScrollPosition( 0 );
	}
}

function SceneDataSave()
{
	local int Time, OldTime, DeltaTime;
	local string tempStr;
	local string Desc;	
	local float PlayRate;

	if( m_CurIndex < 0 )
		return;
		
	// get delta time
	class'SceneEditorAPI'.static.GetCurSceneTimeAndDesc( m_CurIndex, OldTime, Desc );

	// Time, PlayRate, Desc
	tempStr = editSceneTime.GetString();
	Time = int(tempStr);
	tempStr	= editScenePlayRate.GetString();
	PlayRate = float(tempStr);
	Desc = editSceneDesc.GetString();
	class'SceneEditorAPI'.static.SaveCurSceneTimeAndDesc( m_CurIndex, Time, Desc, PlayRate );
		
	// all scene time update
	DeltaTime = (Time -  OldTime);
	AllSceneTimeUpdate(DeltaTime);

	// Camera Ctrl
	if( SceneCameraCtrl != None )
		SceneCameraCtrl.SaveCameraData(m_CurIndex);

	// Npc Ctrl
	if( SceneNpcCtrl != None )
		SceneNpcCtrl.SaveNpcData(m_CurIndex);
		
	// Pc Ctrl
	if( ScenePcCtrl != None )
		ScenePcCtrl.SavePcData(m_CurIndex);

	// Music Ctrl
	if( SceneMusicCtrl != None )
		SceneMusicCtrl.SaveMusicData(m_CurIndex);

	// Screen Ctrl		
	if( SceneScreenCtrl!=None )
		SceneScreenCtrl.SaveScreenData(m_CurIndex);
}

// 예를들어 3번 Scene 의 Time 을 2000 -> 2500 으로 바꾸면 뒤에꺼들도 전부 +500씩 되게 함
function AllSceneTimeUpdate( int DeltaTime )
{
	local int Time;
	local string Desc;
	local int index;
	local float PlayRate;

	for( index = m_CurIndex+1; index < m_NumOfScene; ++index )
	{
		class'SceneEditorAPI'.static.GetCurScenePlayRate( index, PlayRate );
		class'SceneEditorAPI'.static.GetCurSceneTimeAndDesc( index, Time, Desc );
		Time += DeltaTime;		
		class'SceneEditorAPI'.static.SaveCurSceneTimeAndDesc( index, Time, Desc, PlayRate );		
	}
}
defaultproperties
{
}
