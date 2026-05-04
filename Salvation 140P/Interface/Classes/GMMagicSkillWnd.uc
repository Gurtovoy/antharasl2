class GMMagicSkillWnd extends MagicSkillWnd;

var bool bShow;	// GM창에서 버튼을 한번 더 누르면 사라지게 하기 위한 변수

function OnRegisterEvent()
{
	RegisterEvent( EV_GMObservingSkillListStart );
	RegisterEvent( EV_GMObservingSkillList );
}

function OnLoad()
{
	local int i;
	
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	if(CREATE_ON_DEMAND==0)
	{
		m_wndTop = GetHandle( m_WindowName );
		areaScroll = GetHandle( m_WindowName $ ".ASkillScroll" );
		areaScroll_p = GetHandle( m_WindowName $ ".PSkillScroll" );
		
		for(i=0; i<Skill_GROUP_COUNT ; i++)
		{
			m_wndName[i] = GetHandle( m_WindowName $".ASkill.ASkillName" $ i ); 
			m_wnd[i] = GetHandle( m_WindowName $ ".ASkill.ASkill" $ i ); 
			m_NameStr[i] = TextBoxHandle (GetHandle( m_WindowName $ ".ASkill.ASkillName" $  i $ ".ASkillNameStr" $ i )); 
			m_NameBtn[i] = TextureHandle(GetHandle( m_WindowName $ ".ASkill.ASkillName" $  i $ ".ASkillBtn" $ i )); 
			m_Item[i] = ItemWindowHandle (GetHandle( m_WindowName $ ".ASkill.ASkill" $  i $ ".ASkillItem" $ i )); 
			m_ItemBg[i] = TextureHandle(GetHandle( m_WindowName $ ".ASkill.ASkill" $  i $ ".ASkillSlotBg" $ i )); 
			m_HiddenBtn[i] = ButtonHandle (GetHandle( m_WindowName $ ".ASkill.ASkillName" $  i $ ".ASkillHiddenBtn" $ i )); 
			m_HiddenBtn[i].SetAlpha(255);
		}
		
		for(i=0; i<Skill_GROUP_COUNT_P ; i++)
		{
			m_wndName_p[i] = GetHandle( m_WindowName $".PSkill.PSkillName" $ i ); 
			m_wnd_p[i] = GetHandle( m_WindowName $ ".PSkill.PSkill" $ i ); 
			m_NameStr_p[i] = TextBoxHandle (GetHandle( m_WindowName $ ".PSkill.PSkillName" $  i $ ".PSkillNameStr" $ i )); 
			m_NameBtn_p[i] = TextureHandle(GetHandle( m_WindowName $ ".PSkill.PSkillName" $  i $ ".PSkillBtn" $ i )); 
			m_Item_p[i] = ItemWindowHandle (GetHandle( m_WindowName $ ".PSkill.PSkill" $  i $ ".PSkillItem" $ i )); 
			m_ItemBg_p[i] = TextureHandle(GetHandle( m_WindowName $ ".PSkill.PSkill" $  i $ ".PSkillSlotBg" $ i )); 
			m_HiddenBtn_p[i] = ButtonHandle (GetHandle( m_WindowName $ ".PSkill.PSkillName" $  i $ ".PSkillHiddenBtn" $ i )); 
			m_HiddenBtn_p[i].SetAlpha(255);
		}
	}
	else
	{
		m_wndTop = GetWindowHandle( m_WindowName );
		areaScroll = GetWindowHandle( m_WindowName $ ".ASkillScroll" );
		areaScroll_p = GetWindowHandle( m_WindowName $ ".PSkillScroll" );
		
		for(i=0; i<Skill_GROUP_COUNT ; i++)
		{
			m_wndName[i] = GetWindowHandle( m_WindowName $".ASkill.ASkillName" $ i ); 
			m_wnd[i] = GetWindowHandle( m_WindowName $ ".ASkill.ASkill" $ i ); 
			m_NameStr[i] = GetTextBoxHandle( m_WindowName $ ".ASkill.ASkillName" $  i $ ".ASkillNameStr" $ i ); 
			m_NameBtn[i] = GetTextureHandle( m_WindowName $ ".ASkill.ASkillName" $  i $ ".ASkillBtn" $ i ); 
			m_Item[i] = GetItemWindowHandle ( m_WindowName $ ".ASkill.ASkill" $  i $ ".ASkillItem" $ i ); 
			m_ItemBg[i] = GetTextureHandle( m_WindowName $ ".ASkill.ASkill" $  i $ ".ASkillSlotBg" $ i ); 
			m_HiddenBtn[i] = GetButtonHandle( m_WindowName $ ".ASkill.ASkillName" $  i $ ".ASkillHiddenBtn" $ i ); 
			m_HiddenBtn[i].SetAlpha(255);
		}
		
		for(i=0; i<Skill_GROUP_COUNT_P ; i++)
		{
			m_wndName_p[i] = GetWindowHandle( m_WindowName $".PSkill.PSkillName" $ i ); 
			m_wnd_p[i] = GetWindowHandle( m_WindowName $ ".PSkill.PSkill" $ i ); 
			m_NameStr_p[i] = GetTextBoxHandle( m_WindowName $ ".PSkill.PSkillName" $  i $ ".PSkillNameStr" $ i ); 
			m_NameBtn_p[i] = GetTextureHandle( m_WindowName $ ".PSkill.PSkillName" $  i $ ".PSkillBtn" $ i ); 
			m_Item_p[i] = GetItemWindowHandle ( m_WindowName $ ".PSkill.PSkill" $  i $ ".PSkillItem" $ i ); 
			m_ItemBg_p[i] = GetTextureHandle( m_WindowName $ ".PSkill.PSkill" $  i $ ".PSkillSlotBg" $ i ); 
			m_HiddenBtn_p[i] = GetButtonHandle( m_WindowName $ ".PSkill.PSkillName" $  i $ ".PSkillHiddenBtn" $ i ); 
			m_HiddenBtn_p[i].SetAlpha(255);
		}
	}
	
	bShow = false;	//초기화
}

function OnShow()
{
}

function OnHide()
{
}

function ShowMagicSkill( String a_Param )
{
	if( a_Param == "" )
		return;

	if(bShow)	//창이 떠있으면 지워준다.
	{
		Clear();
		m_hOwnerWnd.HideWindow();
		bShow = false;
	}
	else
	{
		class'GMAPI'.static.RequestGMCommand( GMCOMMAND_SkillInfo, a_Param );
		bShow = true;
	}
}

function OnEvent( int a_EventID, String a_Param )
{
	switch( a_EventID )
	{
	case EV_GMObservingSkillListStart:
		HadleGMObservingSkillListStart();
		break;
	case EV_GMObservingSkillList:
		HadleGMObservingSkillList( a_Param );
		break;
	}
}

function HadleGMObservingSkillListStart()
{
	Clear();
	m_hOwnerWnd.ShowWindow();
	m_hOwnerWnd.SetFocus();
}

function HadleGMObservingSkillList( String a_Param )
{
	HandleSkillList( a_Param );
	ComputeItemWndHeight();
	ComputeItemWndAnchor();
}

function OnClickItem( string strID, int index )
{
}

defaultproperties
{
    m_WindowName="GMMagicSkillWnd"
}
