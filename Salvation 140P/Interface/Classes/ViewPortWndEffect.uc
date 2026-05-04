class ViewPortWndEffect extends ViewPortWndBase;

function OnLoad()
{		
	super.OnLoad();
	m_ObjectViewport.SetNPCInfo( EFFECT_MONSTER_ID ) ;
	m_ObjectViewport.SetUISound( true ) ;
	m_ObjectViewport.SpawnNPC( ) ;
}

/***********************************************************************************************
 * etc 
 * *********************************************************************************************/

//defaultproperties
//{
//	m_WindowName = "ViewPortWndEffect";
//}
defaultproperties
{
}
