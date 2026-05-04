class HennaInfoPremiumWnd extends UICommonAPI;

// 문양 정보 윈도우의 상태
const HENNA_EQUIP=1;		// 문양새기기
const HENNA_UNEQUIP=2;		// 문양지우기

var int m_iState;
var int m_iHennaID;

function OnRegisterEvent()
{
	RegisterEvent( EV_HennaInfoWndShowHidePremiumEquip);
	RegisterEvent( EV_HennaInfoWndShowHidePremiumUnEquip);
}

function OnLoad()
{
	SetClosingOnESC();

	if(CREATE_ON_DEMAND==0)
	{
		OnRegisterEvent();
	}
}

function OnClickButton( string strID )
{
	class'UIAPI_WINDOW'.static.HideWindow("HennaInfoPremiumWnd");

	switch( strID )
	{
	case "btnPrev" :
		if(m_iState==HENNA_EQUIP)
			RequestHennaItemList();
		else if(m_iState==HENNA_UNEQUIP)
			RequestHennaUnEquipList();
		break;
	case "btnOK" :
		if(m_iState==HENNA_EQUIP)
			RequestHennaEquip(m_iHennaID);
		else if(m_iState==HENNA_UNEQUIP)
			RequestHennaUnEquip(m_iHennaID);
		break;
	}
}

function OnShow()
{
	// 상태에 따라 윈도를 보여주고 숨겨줍니다
	if(m_iState==HENNA_EQUIP)
	{
		// 타이틀 - 문양새기기
		class'UIAPI_WINDOW'.static.SetWindowTitleByText("HennaInfoPremiumWnd", GetSystemString(651));
	}
	else if(m_iState==HENNA_UNEQUIP)
	{
		// 타이틀 - 문양지우기
		class'UIAPI_WINDOW'.static.SetWindowTitleByText("HennaInfoPremiumWnd", GetSystemString(652));
	}
	else
	{
		//debug("에러에러 이상이상~~");
	}
}


function OnEvent(int Event_ID, string param)
{

	switch(Event_ID)
	{
	case EV_HennaInfoWndShowHidePremiumEquip :
		m_iState=HENNA_EQUIP;		// 상태를 "문양새기기"로 바꿉니다.
		ShowHennaInfoPremiumWnd(param);
		break;
	case EV_HennaInfoWndShowHidePremiumUnEquip :
		m_iState=HENNA_UNEQUIP;		// 상태를 "문양지우기"로 바꿉니다.
		ShowHennaInfoPremiumWnd(param);
		break;
	}
}

function ShowHennaInfoPremiumWnd(string param)
{
	local string strAdenaComma;

	local INT64 iAdena;
	local string strDyeName;			// 염료
	local string strDyeIconName;
	local int iHennaID;
	local int iClassID;
	local INT64 iNum;
	local INT64 iFee;

	local string strTattooName;			// 문양
	local string strTattooAddName;		// 문양
	local string strTattooIconName;
	local string Description;

	local int iINTnow;
	local int iINTchange;
	local int iSTRnow;
	local int iSTRchange;
	local int iCONnow;
	local int iCONchange;
	local int iMENnow;
	local int iMENchange;
	local int iDEXnow;
	local int iDEXchange;
	local int iWITnow;
	local int iWITchange;

	local color col;
	
	ParseINT64(param, "Adena", iAdena);						// 아데나
	ParseString(param, "DyeIconName", strDyeIconName);		// 염료 Icon 이름
	ParseString(param, "DyeName", strDyeName);				// 염료이름
	ParseInt(param, "HennaID", iHennaID);				 
	ParseInt(param, "ClassID", iClassID);
	ParseINT64(param, "NumOfItem", iNum);
	ParseINT64(param, "Fee", iFee);

	ParseString(param, "TattooIconName", strTattooIconName);	// 문양아이콘이름
	ParseString(param, "TattooName", strTattooName);		// 문양이름
	ParseString(param, "TattooAddName", strTattooAddName);	// 문양정보 - 수치변동텍스트 

	ParseInt(param, "INTnow", iINTnow);
	ParseInt(param, "INTchange", iINTchange);
	ParseInt(param, "STRnow", iSTRnow);
	ParseInt(param, "STRchange", iSTRchange);
	ParseInt(param, "CONnow", iCONnow);
	ParseInt(param, "CONchange", iCONchange);
	ParseInt(param, "MENnow", iMENnow);
	ParseInt(param, "MENchange", iMENchange);
	ParseInt(param, "DEXnow", iDEXnow);
	ParseInt(param, "DEXchange", iDEXchange);
	ParseInt(param, "WITnow", iWITnow);
	ParseInt(param, "WITchange", iWITchange);
	
	ParseString(param, "Description", Description);


	m_iHennaID=iHennaID;		// 문양을 새기거나 제거할때 필요하므로 ID를 저장해둡니다
	
	// 염료
	class'UIAPI_TEXTBOX'.static.SetText("HennaInfoPremiumWnd.txtDyeInfo", GetSystemString(638));			// "염료정보"
	class'UIAPI_TEXTURECTRL'.static.SetTexture("HennaInfoPremiumWnd.textureDyeIconName", strDyeIconName);	// 염료 Icon
	class'UIAPI_TEXTBOX'.static.SetText("HennaInfoPremiumWnd.txtDyeName", strDyeName);						// 염료이름

	col.R=168;
	col.G=168;
	col.B=168;
	class'UIAPI_TEXTBOX'.static.SetText("HennaInfoPremiumWnd.txtFee", GetSystemString(637) $ " : ");		// "수수료 : "
	class'UIAPI_TEXTBOX'.static.SetTextColor("HennaInfoPremiumWnd.txtFee", col);		

	strAdenaComma = MakeCostString(string(iFee));
	col= GetNumericColor(strAdenaComma);
	class'UIAPI_TEXTBOX'.static.SetText("HennaInfoPremiumWnd.txtAdena", strAdenaComma);		// 수수료 아데나 숫자
	class'UIAPI_TEXTBOX'.static.SetTextColor("HennaInfoPremiumWnd.txtAdena", col);

	col.R=255;
	col.G=255;
	col.B=0;
	class'UIAPI_TEXTBOX'.static.SetText("HennaInfoPremiumWnd.txtAdenaString", GetSystemString(469));		// "아데나"
	class'UIAPI_TEXTBOX'.static.SetTextColor("HennaInfoPremiumWnd.txtAdenaString", col);		


	// 문양
	class'UIAPI_TEXTBOX'.static.SetText("HennaInfoPremiumWnd.txtTattooInfo", GetSystemString(639));		// "문양정보"
	class'UIAPI_TEXTURECTRL'.static.SetTexture("HennaInfoPremiumWnd.textureTattooIconName", strTattooIconName);	// 문양 Icon
	class'UIAPI_TEXTBOX'.static.SetText("HennaInfoPremiumWnd.txtTattooName", strTattooName);		// 문양이름
	class'UIAPI_TEXTBOX'.static.SetText("HennaInfoPremiumWnd.txtTattooAddName", strTattooAddName);		// 문양부가정보
	
	
	//아데나(,)
	strAdenaComma = MakeCostString(string(iAdena));
	col = GetNumericColor(strAdenaComma);
	class'UIAPI_TEXTBOX'.static.SetText("HennaInfoPremiumWnd.txtHaveAdena", strAdenaComma);		// 아데나 숫자
	class'UIAPI_TEXTBOX'.static.SetTooltipString("HennaInfoPremiumWnd.txtHaveAdena", ConvertNumToText(string(iAdena)));

	class'UIAPI_WINDOW'.static.HideWindow("HennaListWnd");

	class'UIAPI_WINDOW'.static.ShowWindow("HennaInfoPremiumWnd");
	class'UIAPI_WINDOW'.static.SetFocus("HennaInfoPremiumWnd");
	
	class'UIAPI_TEXTBOX'.static.SetText("HennaInfoPremiumWnd.HennaDescTextBox", Description);		// 아데나 숫자
			
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( "HennaInfoPremiumWnd" ).HideWindow();
}
defaultproperties
{
}
