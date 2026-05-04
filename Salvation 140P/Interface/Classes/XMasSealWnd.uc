class XMasSealWnd extends UICommonAPI;


var string m_WindowName;

var WindowHandle	m_hXMasSealWnd;
var TextureHandle	m_hTexItem;

function OnRegisterEvent()
{
	RegisterEvent(EV_ToggleXMasSealWndShowHide);
}

function OnLoad()
{
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	if(CREATE_ON_DEMAND==0)
	{
		m_hXmasSealWnd=GetHandle(m_WindowName);
		m_hTexItem=TextureHandle(GetHandle(m_WindowName$".texItem"));
	}
	else
	{
		m_hXmasSealWnd=GetWindowHandle(m_WindowName);
		m_hTexItem=GetTextureHandle(m_WindowName$".texItem");
	}
}

function OnEvent(int Event_ID, String param)
{
	switch(Event_ID)
	{
	case EV_ToggleXMasSealWndShowHide :
		HandleToggleXMasSealWndShowHide(param);
		break;
	}
}

function HandleToggleXMasSealWndShowHide(string param)
{
	local ItemID ID;
	local string TextureName;

	ParseItemID(param, ID);

	TextureName=class'UIDATA_ITEM'.static.GetEtcItemTextureName(ID);

	m_hTexItem.SetTexture(TextureName);


	if(m_hXMasSealWnd.IsShowWindow())
	{
		m_hXMasSealWnd.HideWindow();
	}
	else
	{
		m_hXMasSealWnd.ShowWindow();
		m_hXMasSealWnd.SetFocus();
	}
}

defaultproperties
{
    m_WindowName="XMasSealWnd"
}
