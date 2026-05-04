class QuestBtnWnd extends UICommonAPI;

/**
 * 알림아이콘 통합으로 사용되지 않음.
 */

var BOOL	m_bArriveShowQuest;
var INT		m_iEffectNumber;

function OnRegisterEvent()
{
	//RegisterEvent( EV_ArriveShowQuest );
}

function OnLoad()
{
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();
}

function OnEvent( int Event_ID, string param )
{
	ParseInt(param, "QuestID", m_iEffectNumber);

	switch( Event_ID )
	{
	case EV_ArriveShowQuest :
		ShowWindowWithFocus("QuestBtnWnd");
		class'UIAPI_WINDOW'.static.ShowWindow("QuestBtnWnd.btnQuest");
		class'UIAPI_EFFECTBUTTON'.static.BeginEffect("QuestBtnWnd.btnQuest", m_iEffectNumber);
		
		m_bArriveShowQuest = true;
		break;
	}
}

function OnEnterState( name a_PreStateName )
{
	if( m_bArriveShowQuest && a_PreStateName == 'NpcZoomCameraState')
	{
		// re-show QuestBntWnd
		ShowWindowWithFocus("QuestBtnWnd");
		class'UIAPI_WINDOW'.static.ShowWindow("QuestBtnWnd.btnQuest");	
	}
	
	// clear
	m_bArriveShowQuest	= false;
	m_iEffectNumber		= 0;
}


function OnClickButton(string strID)
{
	switch(strID)
	{
	case "btnQuest" :
		HideWindow("QuestBtnWnd");
		m_bArriveShowQuest = false;
		break;
	}
}
defaultproperties
{
}
