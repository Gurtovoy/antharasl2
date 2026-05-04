class GMQuestWnd extends QuestTreeWnd;

var bool bShow;	// GM창에서 버튼을 한번 더 누르면 사라지게 하기 위한 변수

function OnRegisterEvent()
{
	RegisterEvent( EV_GMObservingQuestListStart );
	RegisterEvent( EV_GMObservingQuestList );
	RegisterEvent( EV_GMObservingQuestListEnd );
	RegisterEvent( EV_GMObservingQuestItem );
}

function OnLoad()
{
	super.OnLoad();
	bShow = false;	//초기화
}

function OnShow()
{
	super.OnShow();
//	class'UIAPI_WINDOW'.static.HideWindow( m_WindowName$".btnClose" );
	chkNpcPosBox.HideWindow();
}	

function ShowQuest( String a_Param )
{
	if( a_Param == "" )
		return;

	if(bShow)	//창이 떠있으면 지워준다.
	{
		m_hOwnerWnd.HideWindow();
		bShow = false;
	}
	else
	{
		class'GMAPI'.static.RequestGMCommand( GMCOMMAND_QuestInfo, a_Param );
		bShow = true;
	}
}

function OnEvent( int a_EventID, String a_Param )
{
	switch( a_EventID )
	{
	case EV_GMObservingQuestListStart:
		HandleGMObservingQuestListStart();
		break;
	case EV_GMObservingQuestList:
		HandleGMObservingQuestList( a_Param );
		break;
	case EV_GMObservingQuestListEnd:
		HandleGMObservingQuestListEnd();
		break;
	case EV_GMObservingQuestItem:
		HandleGMObservingQuestItem( a_Param );
		break;
	}
}

function HandleGMObservingQuestListStart()
{
	m_hOwnerWnd.ShowWindow();
	m_hOwnerWnd.SetFocus();
	HandleQuestListStart();
}

function HandleGMObservingQuestList( String a_Param )
{
	HandleQuestList( a_Param );
}

function HandleGMObservingQuestListEnd()
{
	//UpdateQuestCount();
	//UpdateItemCount( 0, -1 );
	HandleQuestListEnd();
	//InsertQuestTrackList();
}

function HandleGMObservingQuestItem( String a_Param )
{
	local int ClassID;
	local INT64 ItemCount;
	local QuestAlarmWnd sc;

	sc = QuestAlarmWnd( GetScript("QuestAlarmWnd") );

	ParseInt( a_Param, "ClassID", ClassID );
	ParseINT64( a_Param, "ItemCount", ItemCount );

	sc.UpdateItemCount( ClassID, ItemCount );
}

defaultproperties
{
    m_WindowName="GMQuestWnd"
}
