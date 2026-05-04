class SkillTrainListWnd extends UICommonAPI;

//////////////////////////////////////////////////////////////////////////////
// CONST
//////////////////////////////////////////////////////////////////////////////
const OFFSET_X_ICON_TEXTURE=0;
const OFFSET_Y_ICON_TEXTURE=4;
const OFFSET_Y_SECONDLINE = -17;

var int m_iType;

var int m_iState;
var int m_iRootNameLength;
var bool m_bDrawBg;
var WindowHandle	m_SkillTrainListWnd;

function OnRegisterEvent()
{
	RegisterEvent( EV_SkillTrainListWndShow );
	RegisterEvent( EV_SkillTrainListWndHide );
	RegisterEvent( EV_SkillTrainListWndAddSkill );
}

function OnLoad()
{
	SetClosingOnESC();		
	m_SkillTrainListWnd= GetWindowHandle("SkillTrainListWnd.SkillTrainListTree");
}

function OnClickButton( string strItemID )
{
	local string strID_Level;
	local string strID;
	local string strLevel;
	local int iID;
	local int iLevel;
	local int iSubLevel;
	local int iIdxComma;
	local int iLength;

//#ifdef CT26P3
	iID = 0;
	iLevel = 0;
	iSubLevel = 0;
//#endif //CT26P3 - gorillazin

	strID_Level = Mid(strItemID, m_iRootNameLength+1);
	iLength=Len(strID_Level);
//	debug("원본:"$strTemp$", 길이:"$iLength);
	iIdxComma=InStr(strID_Level, ",");

	strID=Left(strID_Level, iIdxComma);
	strLevel=Right(strID_Level, iLength-iIdxComma-1);

//	debug("iIdxComma:"$iIdxComma$", iLength-iIdxComma:"$(iLength-iIdxComma));
//	debug("ID:"$int(strID)$", Level:"$int(strLevel));

	iID=int(strID);
	iLevel=int(strLevel);

//#ifdef CT26P3
	// TTP #42253 X버튼을 눌렀을 때에는 SkillInfo를 서버에 요청하지 않도록 수정 - gorillazin
	if (iID > 0 && iLevel > 0)
	{
		//switch(m_iType)
		//{
		//case ESTT_NORMAL :
		//case ESTT_FISHING :
		//case ESTT_CLAN :
			/* subLevel 분석 후 작업 필요  */
			RequestAcquireSkillInfo(iID, iLevel, iSubLevel,  m_iType);
		//	break;
		//default:
		//	break;
		//}
	}
//#else
//	RequestAcquireSkillInfo(iID, iLevel, m_iType);
//endif //CT26P3 - gorillazin
	HideWindow("SkillTrainListWnd");
	m_SkillTrainListWnd.SetScrollPosition(0); // 스크롤바 초기화
	
	m_bDrawBg = true;
}

// 트리 비우기
function Clear()
{
	class'UIAPI_TREECTRL'.static.Clear("SkillTrainListWnd.SkillTrainListTree");
}

function OnEvent(int Event_ID, string param)
{
	local int iType;

	local string strIconName;
	local string strName;
	local int iID;
	local int iLevel;
	local int iSubLevel;
	local INT64 iSPConsume;

	local string strEnchantName;
	local int totalCount;

//	 Debug("SkillTrainList Event_ID " @ Event_ID);
	// Debug("param    " @ param);

	//Debug ( "onEvent " @ Event_ID @ param );

	ParseInt(param, "Type"	, iType);

	// 140 : 연금술 타입
	if (iType == 140) return;
	
	switch(Event_ID)
	{
		case EV_SkillTrainListWndShow :
			//ParseInt(param, "Type"	, iType);
			Clear();
			m_iType=iType;

			ParseInt(param, "Count"	, totalCount);

			if(totalCount == 0)
			{
				AddSystemMessageString( getSystemMessage( 750 ) );			
				if( IsShowWindow("SkillTrainInfoWnd") ) HideWindow( "SkillTrainInfoWnd");
				return;
			}

			ShowSkillTrainListWnd(iType);
			break;

		case EV_SkillTrainListWndAddSkill :
			ParseString(param, "strIconName", strIconName); 
			ParseString(param, "strName", strName);
			ParseInt(param, "iID", iID);
			ParseInt(param, "iLevel", iLevel);			
			ParseInt(param, "iSubLevel", iSubLevel);
			
			ParseInt64(param, "iSPConsume", iSPConsume);
			ParseString(param, "strEnchantName", strEnchantName);
			
			AddSkillTrainListItem(strIconName, strName, iID, iLevel, iSubLevel, iSPConsume, strEnchantName);
			break;

		case EV_SkillTrainListWndHide :
			if(IsShowWindow("SkillTrainListWnd"))
				HideWindow("SkillTrainListWnd");
			break;
	}
}

function OnShow()
{
	ShowWindow("SkillTrainListWnd.txtSPString");
	ShowWindow("SkillTrainListWnd.txtSP");	

	if( IsShowWindow("SkillTrainInfoWnd") ) HideWindow( "SkillTrainInfoWnd");

	class'UIAPI_WINDOW'.static.SetAnchor( "SkillTrainListWnd", "SkillTrainInfoWnd", "TopLeft", "TopLeft", 0, 0 );//기본 세팅으로 되어 있으나 이상하게 이 속성이 없으면 확장 창이 드래그가 안됨.
}

// 스킬 트레이닝 윈도우 초기화 시킴
function ShowSkillTrainListWnd(int iType)
{
	local XMLTreeNodeInfo	infNode;
	local string strTmp;
	local int iWindowTitle;
	local int iSPIdx;

	local UserInfo infoPlayer;
	local INT64 iPlayerSP;

	GetPlayerInfo(infoPlayer);

	switch(m_iType)
	{
	case ESTT_CLAN :
	case ESTT_SUB_CLAN:
		iWindowTitle=1436;
		iSPIdx=1372;
		iPlayerSP=INT64(GetClanNameValue(infoPlayer.nClanID));
		break;
	//case ESTT_NORMAL :
	//case ESTT_FISHING :
	//case 4:
	//case 5:
	default:
		iWindowTitle=477;
		iSPIdx=92;
		iPlayerSP=infoPlayer.nSP;
		break;

	}

	class'UIAPI_WINDOW'.static.SetWindowTitle("SkillTrainListWnd", iWindowTitle);					// 윈도 타이틀 변경
		
	class'UIAPI_TEXTBOX'.static.SetText("SkillTrainListWnd.txtSPString", GetSystemString(iSPIdx));	// SP or 혈맹명성치 글씨
	class'UIAPI_TEXTBOX'.static.SetText("SkillTrainListWnd.txtSP", String(iPlayerSP));						// SP or 혈맹명성치

	//트리에 Root추가
	infNode.strName = "SkillTrainListRoot";
	infNode.nOffSetX = 7;
	infNode.nOffSetY = 0;
	strTmp = class'UIAPI_TREECTRL'.static.InsertNode("SkillTrainListWnd.SkillTrainListTree", "", infNode);
	if (Len(strTmp) < 1)
	{
		//debug("ERROR: Can't insert root node. Name: " $ infNode.strName);
		return;
	}

	m_iRootNameLength=Len(infNode.strName);

	class'UIAPI_WINDOW'.static.ShowWindow("SkillTrainListWnd");
	class'UIAPI_WINDOW'.static.SetFocus("SkillTrainListWnd");
}

function AddSkillTrainListItem(string strIconName, string strName, int iID, int iLevel, int iSubLevel, INT64 iSPConsume, string strEnchantName)
{
	local XMLTreeNodeInfo	infNode;
	local XMLTreeNodeItemInfo	infNodeItem;
	local XMLTreeNodeInfo	infNodeClear;
	local XMLTreeNodeItemInfo	infNodeItemClear;

	local string strRetName;
	local SkillInfo skillinfo;

	GetSkillInfo( iID , iLevel, iSubLevel, skillInfo );

	//////////////////////////////////////////////////////////////////////////////////////////////////////
	//Insert Node - with No Button
	infNode = infNodeClear;
	infNode.strName = ""$ iID $","$ iLevel;
	infNode.bShowButton = 0;

	//Expand되었을때의 BackTexture설정
	//스트레치로 그리기 때문에 ExpandedWidth는 없다. 끝에서 -2만큼 배경을 그린다.
	infNode.nTexExpandedOffSetX = -7;		//OffSet
	infNode.nTexExpandedOffSetY = 0;		//OffSet
	infNode.nTexExpandedHeight = 38;		//Height
	infNode.nTexExpandedRightWidth = 0;		//오른쪽 그라데이션부분의 길이
	infNode.nTexExpandedLeftUWidth = 32; 		//스트레치로 그릴 왼쪽 텍스쳐의 UV크기
	infNode.nTexExpandedLeftUHeight = 38;
	infNode.strTexExpandedLeft = "L2UI_CH3.etc.IconSelect2";
	
	strRetName = class'UIAPI_TREECTRL'.static.InsertNode("SkillTrainListWnd.SkillTrainListTree", "SkillTrainListRoot", infNode);
	if (Len(strRetName) < 1)
	{
		//debug("ERROR: Can't insert node. Name: " $ infNode.strName);
		return;
	}
	
	if (m_bDrawBg == true)
	{
		//Insert Node Item - 아이템 배경?
		infNodeItem = infNodeItemClear;
		infNodeItem.eType = XTNITEM_TEXTURE;
		infNodeItem.nOffSetX = 0;
		infNodeItem.nOffSetY = 0;
		infNodeItem.u_nTextureUHeight = 14;
		infNodeItem.u_nTextureWidth = 357;
		infNodeItem.u_nTextureHeight = 38;
		infNodeItem.u_strTexture = "L2UI_CH3.etc.textbackline";
		class'UIAPI_TREECTRL'.static.InsertNodeItem("SkillTrainListWnd.SkillTrainListTree", strRetName, infNodeItem);
		m_bDrawBg = false;
	}
	else
	{
		//Insert Node Item - 아이템 배경?
		infNodeItem = infNodeItemClear;
		infNodeItem.eType = XTNITEM_TEXTURE;
		infNodeItem.nOffSetX = 0;
		infNodeItem.nOffSetY = 0;
		infNodeItem.u_nTextureWidth = 357;
		infNodeItem.u_nTextureHeight = 38;
		infNodeItem.u_strTexture = "L2UI_CT1.EmptyBtn";
		class'UIAPI_TREECTRL'.static.InsertNodeItem("SkillTrainListWnd.SkillTrainListTree", strRetName, infNodeItem);
		m_bDrawBg = true;	
	}

	/*
	//Insert Node Item - 아이템 아이콘 테두리 위쪽 텍스쳐
	infNodeItem = infNodeItemClear;
	infNodeItem.eType = XTNITEM_TEXTURE;
	infNodeItem.nOffSetX = OFFSET_X_ICON_TEXTURE;
	infNodeItem.nOffSetY = OFFSET_Y_ICON_TEXTURE;
	infNodeItem.u_nTextureWidth = ;		//-4
	infNodeItem.u_nTextureHeight = 34;
	infNodeItem.u_strTexture = "l2ui_ch3.InventoryWnd.Inventory_OutLine";

	InsertNodeItem(strRetName, infNodeItem);

	//Insert Node Item - 아이템 아이콘 테두리 아래쪽 텍스쳐
	infNodeItem = infNodeItemClear;
	infNodeItem.eType = XTNITEM_TEXTURE;
	infNodeItem.nOffSetX = -33;
	infNodeItem.nOffSetY = OFFSET_Y_ICON_TEXTURE;
	infNodeItem.u_nTextureWidth = 35;
	infNodeItem.u_nTextureHeight = 35;
	infNodeItem.u_strTexture = "l2ui_ch3.InventoryWnd.Inventory_OutLine";

	InsertNodeItem(strRetName, infNodeItem);
	*/
	
	//Insert Node Item - 아이템슬롯 배경
	infNodeItem = infNodeItemClear;
	infNodeItem.eType = XTNITEM_TEXTURE;
	infNodeItem.nOffSetX = -351;		// -4 // -2
	infNodeItem.nOffSetY = 2;			// -2 // -1
	infNodeItem.u_nTextureWidth = 36;
	infNodeItem.u_nTextureHeight = 36;

	infNodeItem.u_strTexture ="L2UI_ct1.ItemWindow.ItemWindow_df_slotbox_2x2";
	InsertNodeItem( strRetName, infNodeItem);

	//Insert Node Item - 아이템 아이콘
	infNodeItem = infNodeItemClear;
	infNodeItem.eType = XTNITEM_TEXTURE;
	infNodeItem.nOffSetX = -34;
	infNodeItem.nOffSetY = OFFSET_Y_ICON_TEXTURE-1;
	infNodeItem.u_nTextureWidth = 32;
	infNodeItem.u_nTextureHeight = 32;
	infNodeItem.u_strTexture = strIconName;

	InsertNodeItem(strRetName, infNodeItem);




//---------------------IconPanel------------------------->

	infNodeItem = infNodeItemClear;
	infNodeItem.eType = XTNITEM_TEXTURE;
	infNodeItem.nOffSetX = -32;
	infNodeItem.nOffSetY = OFFSET_Y_ICON_TEXTURE-1;
	infNodeItem.u_nTextureWidth = 32;
	infNodeItem.u_nTextureHeight = 32;
	infNodeItem.u_strTexture = skillinfo.IconPanel;
//	Debug("SkillTrainListWnd>>>" $ skillinfo.IconPanel);
	InsertNodeItem(strRetName, infNodeItem);

//<----------------------------------------------------------




	//Insert Node Item - 아이템 이름
	infNodeItem = infNodeItemClear;
	infNodeItem.eType = XTNITEM_TEXT;
	infNodeItem.t_strText = strName;
	infNodeItem.t_bDrawOneLine = true;
	infNodeItem.nOffSetX = 5;
	infNodeItem.nOffSetY = 5;

	InsertNodeItem(strRetName, infNodeItem);

	//switch(m_iType)
	//{
	//case ESTT_NORMAL :
	//case ESTT_FISHING :
	//case ESTT_CLAN :
		//Insert Node Item - "Lv"
		infNodeItem = infNodeItemClear;
		infNodeItem.eType = XTNITEM_TEXT;
		infNodeItem.t_strText = GetSystemString(88);
		infNodeItem.bLineBreak = true;
		infNodeItem.t_bDrawOneLine = true;
		infNodeItem.nOffSetX = 46;
		infNodeItem.nOffSetY = OFFSET_Y_SECONDLINE ;

		infNodeItem.t_color.R = 163;
		infNodeItem.t_color.G = 163;
		infNodeItem.t_color.B = 163;
		infNodeItem.t_color.A = 255;
		InsertNodeItem(strRetName, infNodeItem);

		//Insert Node Item - 레벨
		infNodeItem = infNodeItemClear;
		infNodeItem.eType = XTNITEM_TEXT;
		infNodeItem.t_strText = string(iLevel);
		infNodeItem.nOffSetX = 2;
		infNodeItem.nOffSetY = OFFSET_Y_SECONDLINE;

		infNodeItem.t_color.R = 176;
		infNodeItem.t_color.G = 155;
		infNodeItem.t_color.B = 121;
		infNodeItem.t_color.A = 255;
		InsertNodeItem(strRetName, infNodeItem);

		//Insert Node Item - "필요SP:"
		infNodeItem = infNodeItemClear;
		infNodeItem.eType = XTNITEM_TEXT;

		switch(m_iType)
		{
		case ESTT_CLAN :
		case ESTT_SUB_CLAN:
			infNodeItem.t_strText = GetSystemString(1437)$" : ";
			break;
		//case ESTT_NORMAL :
		//case ESTT_FISHING :
		//case 4:
		default:
			infNodeItem.t_strText = GetSystemString(365)$" : ";
			break;
		}
		infNodeItem.bLineBreak = true;
		infNodeItem.nOffSetX = 83;
		infNodeItem.nOffSetY = OFFSET_Y_SECONDLINE;

		infNodeItem.t_color.R = 163;
		infNodeItem.t_color.G = 163;
		infNodeItem.t_color.B = 163;
		infNodeItem.t_color.A = 255;
		InsertNodeItem(strRetName, infNodeItem);

		//Insert Node Item - 필요SP
		infNodeItem = infNodeItemClear;
		infNodeItem.eType = XTNITEM_TEXT;
		infNodeItem.t_strText = string(iSPConsume);
		infNodeItem.nOffSetX = 0;
		infNodeItem.nOffSetY = OFFSET_Y_SECONDLINE;

		infNodeItem.t_color.R = 176;
		infNodeItem.t_color.G = 155;
		infNodeItem.t_color.B = 121;
		infNodeItem.t_color.A = 255;
		InsertNodeItem(strRetName, infNodeItem);
	//	break;
	//default:
	//	break;
	//}
}

function InsertNodeItem(string strNodeName, XMLTreeNodeItemInfo infNodeItemName)
{
	class'UIAPI_TREECTRL'.static.InsertNodeItem("SkillTrainListWnd.SkillTrainListTree", strNodeName, infNodeItemName);
}


/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( "SkillTrainListWnd" ).HideWindow();	
	m_SkillTrainListWnd.SetScrollPosition(0); // 스크롤바 초기화	
	m_bDrawBg = true;
}
defaultproperties
{
}
