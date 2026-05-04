class ActionWnd extends UICommonAPI;

var bool m_bShow;

function OnRegisterEvent()
{
	RegisterEvent(EV_ActionListNew);
	RegisterEvent(EV_ActionListStart);
	RegisterEvent(EV_ActionList);
	RegisterEvent(EV_LanguageChanged);
	RegisterEvent(EV_NeedResetUIData);
}

function OnLoad()
{
	SetClosingOnESC();

	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	m_bShow = false;
	
	//ItemWnd의 스크롤바 Hide
	HideScrollBar();
}

function OnShow()
{
	class'ActionAPI'.static.RequestActionList();
	m_bShow = true;
}

function OnHide()
{
	m_bShow = false;
}

function OnEvent(int Event_ID, String param)
{
	//debug("debug@" @ Event_ID);
	if (Event_ID == EV_ActionListStart)
	{
		//debug("ActionListStart:" );
		HandleActionListStart();
	}
	else if (Event_ID == EV_ActionList)
	{
		//debug("EV_ActionList:" @ param);
		HandleActionList(param);
	}
	else if (Event_ID == EV_LanguageChanged)
	{
		//debug("EV_LanguageChanged:");
		HandleLanguageChanged();
	}
	else if( Event_ID == EV_ActionListNew )
	{
		//debug("EV_ActionListNew");
		HandleActionListNew();
	}
	else if( Event_ID == EV_NeedResetUIData )
	{
		//debug("EV_ActionListNew");
		checkClassicForm();
	}	
}

function checkClassicForm () 
{
	local WindowHandle Me;
	local TextBoxHandle txtMark;	
	local TextureHandle SlotMark_01;
	local TextureHandle SlotMark_02;
	local ItemWindowHandle ActionMarkItem;

	local TextBoxHandle txtSocial;	
	local TextureHandle SlotSocial_01;
	local TextureHandle SlotSocial_02;		
	local ItemWindowHandle ActionSocialItem;

	Me = GetWindowHandle("ActionWnd");

	txtSocial = GetTextBoxHandle ( "ActionWnd.txtSocial" );
	SlotSocial_01 = GetTextureHandle( "ActionWnd.SlotSocial_01" );
	SlotSocial_02 = GetTextureHandle( "ActionWnd.SlotSocial_02" );	
	ActionSocialItem = GetItemWindowHandle ( "ActionWnd.ActionSocialItem" );
	
	txtMark = GetTextBoxHandle ( "ActionWnd.txtMark" );
	SlotMark_01 = GetTextureHandle( "ActionWnd.SlotMark_01" );
	SlotMark_02 = GetTextureHandle( "ActionWnd.SlotMark_01" );	
	ActionMarkItem = GetItemWindowHandle ( "ActionWnd.ActionMarkItem" );

	if ( false && getInstanceUIData().getIsClassicServer() ) //branch EP1.0 2015-11-2 luciper3 - 해외 클래식에서 징표 사용함.. 일단 이런식으로 막는다.
	{
		SlotMark_01.HideWindow();
		SlotMark_02.HideWindow();
		txtMark.HideWindow();
		ActionMarkItem.HideWindow();
		
		txtSocial.SetAnchor( "ActionWnd", "TopLeft", "TopLeft", 15, 298 );
		SlotSocial_01.SetAnchor( "ActionWnd", "TopLeft", "TopLeft", 6, 314 );
		SlotSocial_02.SetAnchor( "ActionWnd", "TopLeft", "TopLeft", 258, 314 );		
		ActionSocialItem.SetAnchor( "ActionWnd", "TopLeft", "TopLeft", 7, 314 );
		Me.SetWindowSize (300, 430);
	}
	else 
	{
		SlotMark_01.ShowWindow();
		SlotMark_02.ShowWindow();
		txtMark.ShowWindow();
		ActionMarkItem.ShowWindow();

		txtSocial.SetAnchor( "ActionWnd", "TopLeft", "TopLeft", 15, 395 );
		SlotSocial_01.SetAnchor( "ActionWnd", "TopLeft", "TopLeft", 6, 411 );
		SlotSocial_02.SetAnchor( "ActionWnd", "TopLeft", "TopLeft", 258, 411 );		
		ActionSocialItem.SetAnchor( "ActionWnd", "TopLeft", "TopLeft", 7, 411 );
		
		Me.SetWindowSize (300, 527);
	}

}

//액션의 클릭
function OnClickItem( string strID, int index )
{
	local ItemInfo 	infItem;
	
	if (strID == "ActionBasicItem" && index>-1)
	{
		if (!class'UIAPI_ITEMWINDOW'.static.GetItem("ActionWnd.ActionBasicItem", index, infItem))
			return;

		class'UIAPI_ITEMWINDOW'.static.SetItem( "ActionWnd.ActionBasicItem", index, infItem );
	}
	else if (strID == "ActionPartyItem" && index>-1)
	{
		//Debug(string(index));
		if (!class'UIAPI_ITEMWINDOW'.static.GetItem("ActionWnd.ActionPartyItem", index, infItem))
			return;

		//월래 자동 파티 매칭용 하드 코딩.
		/*
		if( index == 7 )
		{
			//debug( string(infItem.IconIndex) );
			if (infItem.IconIndex == 0)
			{
				class'UIAPI_ITEMWINDOW'.static.SetIconIndex( "ActionWnd.ActionPartyItem", index, 1);
				//class'UIAPI_ITEMWINDOW'.static.SetToggleEffect("ActionWnd.ActionPartyItem", index, true);
			}
			else if ( infItem.IconIndex == 1)
			{
				class'UIAPI_ITEMWINDOW'.static.SetIconIndex( "ActionWnd.ActionPartyItem", index, 0);
				//class'UIAPI_ITEMWINDOW'.static.SetToggleEffect("ActionWnd.ActionPartyItem", index, false);
			}
		}*/
	}
	else if (strID == "ActionMarkItem" && index>-1)
	{
		if (!class'UIAPI_ITEMWINDOW'.static.GetItem("ActionWnd.ActionMarkItem", index, infItem))
			return;
	}
	else if (strID == "ActionSocialItem" && index>-1)
	{
		if (!class'UIAPI_ITEMWINDOW'.static.GetItem("ActionWnd.ActionSocialItem", index, infItem))
			return;
	}
	

	DoAction(infItem.ID);

	
}

function HideScrollBar()
{
	class'UIAPI_ITEMWINDOW'.static.ShowScrollBar("ActionWnd.ActionBasicItem", false);
	class'UIAPI_ITEMWINDOW'.static.ShowScrollBar("ActionWnd.ActionPartyItem", false);
	class'UIAPI_ITEMWINDOW'.static.ShowScrollBar("ActionWnd.ActionMarkItem", false);
	class'UIAPI_ITEMWINDOW'.static.ShowScrollBar("ActionWnd.ActionSocialItem", false);
}

function HandleLanguageChanged()
{
	class'ActionAPI'.static.RequestActionList();
}

function HandleActionListStart()
{
	Clear();
}

function Clear()
{
	class'UIAPI_ITEMWINDOW'.static.Clear("ActionWnd.ActionBasicItem");
	class'UIAPI_ITEMWINDOW'.static.Clear("ActionWnd.ActionPartyItem");
	class'UIAPI_ITEMWINDOW'.static.Clear("ActionWnd.ActionMarkItem");
	class'UIAPI_ITEMWINDOW'.static.Clear("ActionWnd.ActionSocialItem");
	//~ class'ActionAPI'.static.RequestActionList();
}

function HandleActionList(string param)
{
	local string WndName;
	
	local int Tmp;
	local EActionCategory Type;
	local string strActionName;
	local string strIconName;
	local string strIconNameEx1;
	local string strDescription;
	local string strCommand;
	
	local ItemInfo	infItem;
	
	ParseItemID(param, infItem.ID);
	ParseInt(param, "Type", Tmp);
	ParseString(param, "Name", strActionName);
	ParseString(param, "IconName", strIconName);
	ParseString(param, "IconNameEx1", strIconNameEx1);
	ParseString(param, "Description", strDescription);
	ParseString(param, "Command", strCommand);

	infItem.Name = strActionName;
	infItem.IconName = strIconName;
	infItem.IconNameEx1 = strIconNameEx1;
	infItem.Description = strDescription;
	infItem.ItemSubType = int(EShortCutItemType.SCIT_ACTION);
	infItem.MacroCommand = strCommand;
	
	//ItemWnd에 추가
	Type = EActionCategory(Tmp);
	if (Type==ACTION_BASIC)
	{
		WndName = "ActionBasicItem";
	}
	else if (Type==ACTION_PARTY)
	{
		WndName = "ActionPartyItem";
	}
	else if (Type==ACTION_TACTICALSIGN)
	{
		WndName = "ActionMarkItem";
	}
	else if (Type==ACTION_SOCIAL)
	{
		WndName = "ActionSocialItem";
	}
	else
	{
		return;
	}
	class'UIAPI_ITEMWINDOW'.static.AddItem("ActionWnd." $ WndName, infItem);
}

function HandleActionListNew()		// Request new data
{
	class'ActionAPI'.static.RequestActionList();
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( "ActionWnd" ).HideWindow();
}
defaultproperties
{
}
