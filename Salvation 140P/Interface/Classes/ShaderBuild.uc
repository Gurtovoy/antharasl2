/*****************************************************************
 * 쉐이더 옵션 변경 시 저사양 PC를 위해 
 * 스태이트를 변경, ShaderState 상태에서 
 * 옵션 적용을 함.
 * 저사양 PC가 없을 거라 예상되어
 * 사용하지 않음.
 * ***************************************************************/

class ShaderBuild extends UIScript;

//var OptionWnd m_OptionWndScript;
//var String m_PreStateName;
////var int m_StartBuild;

////var int m_OrgAntialiasing;

//var WindowHandle GametipWnd;
//var WindowHandle LoadingWnd;

//function OnRegisterEvent()
//{
//	//RegisterEvent( EV_ResetDevice );
//}

//function OnLoad()
//{
//	if(CREATE_ON_DEMAND==0)
//		OnRegisterEvent();

//	if(CREATE_ON_DEMAND==0)
//	{
//		m_OptionWndScript = OptionWnd( GetScript( "OptionWnd" ) );
//		GametipWnd = GetHandle("GametipWnd");
//		LoadingWnd = GetHandle("LoadingWnd");
//	}
//	else
//	{
//		m_OptionWndScript = OptionWnd( GetScript( "OptionWnd" ) );
//		GametipWnd = GetWindowHandle("GametipWnd");
//		LoadingWnd = GetWindowHandle("LoadingWnd");
//	}

//	m_hOwnerWnd.EnableTick();
//}

//function OnEnterState( name a_PreStateName )
//{
//	m_PreStateName = String( a_PreStateName );
//	LoadingWnd.ShowWindow();
//	GametipWnd.ShowWindow();
//	//m_StartBuild = 1;
//}

//function OnTick()
//{
//	//local int OrgAntialiasing;

//	//20121203 m_StartBuild 나 OrgAntialiasing==0 이 필요 없다고 하므로 삭제

//	/*
//	switch( m_StartBuild )
//	{
//	case 0:	// Do nothing
//		break;
//	case 1:	// Wait one tick to show LoadingWnd
//		// Set AA 0 to reset device before showing loading screen
//		m_OrgAntialiasing = GetOptionInt( "Video", "AntiAliasing" );
//		if( 0 == OrgAntialiasing )
//		{
//			SetOptionInt( "Video", "AntiAliasing", 0 );
//			m_StartBuild++;
//		}
//		else
//			m_StartBuild = 3;
//		break;
//	case 2:	// If device is reset wait one more tick for precache
//		m_StartBuild++;
//		break;
//	case 3:
//		m_StartBuild = 0;
		
//		//SetAA 이런 함수가 필요함, 지금은 옵션에 저장 하면 바로 적용 하는 방식 임
//		//SetAA (m_OptionWndScript.m_AntiAliasing ) ;

//		SetHDR (m_OptionWndScript.m_PostProc ) ;

//		//추가 했음
//		SetShaderWaterEffect( m_OptionWndScript.m_bShaderWater );
//		SetDepthBufferShadow( m_OptionWndScript.m_bDepthBufferShadow );
//		SetDOF( m_OptionWndScript.m_bDOF );
//		SetL2Shader( m_OptionWndScript.m_bL2Shader );
//		// recover original AA value after shader is on.
//		SetOptionInt( "Video", "AntiAliasing", m_OrgAntialiasing );
//		LoadingWnd.HideWindow();
//		GametipWnd.HideWindow();
//		SetUIState( m_PreStateName );
//		break;
//	}*/
//		//m_StartBuild = 0;
		
//		//SetAA 이런 함수가 필요함, 지금은 옵션에 저장 하면 바로 적용 하는 방식 임
//		//SetAA (m_OptionWndScript.m_AntiAliasing ) ;

//		SetHDR (m_OptionWndScript.m_PostProc );

//		//추가 했음
//		SetAntialiasing( m_OptionWndScript.m_AntiAliasing );

//		SetShaderWaterEffect( m_OptionWndScript.m_bShaderWater );
//		//SetDepthBufferShadow( m_OptionWndScript.m_bDepthBufferShadow );
//		SetDOF( m_OptionWndScript.m_bDOF );
//		SetL2Shader( m_OptionWndScript.m_bL2Shader );
//		// recover original AA value after shader is on.
//		//SetOptionInt( "Video", "AntiAliasing", m_OrgAntialiasing );
//		LoadingWnd.HideWindow();
//		GametipWnd.HideWindow();

//		SetUIState( m_PreStateName );
////		break;
//}

/*
function OnEvent( int a_EventID, String a_Param )
{
	if( a_EventID == EV_ResetDevice )
	{
	}
}
*/
defaultproperties
{
}
