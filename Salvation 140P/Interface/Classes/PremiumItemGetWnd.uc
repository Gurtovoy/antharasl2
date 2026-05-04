class PremiumItemGetWnd extends UICommonAPI;

const OFFSET_Y_1ST_LINE = 4;	// 첫번째 줄 오프셋
const OFFSET_Y_SECONDLINE = -17;


//-------------------------------------------------------------------------------------------------
// 전역변수
//-------------------------------------------------------------------------------------------------

var int m_iItemNameLength;			// 각 노드의 이름의 길이

var int m_clickedID;				// 선택된 ID	-1이면 아무것도 선택되지 않은 것
var int m_clickedItemNum;			// 선택된 ID의 아이템 구매 갯수 저장
var int m_maxCount;				// 받을 수 있는 아이템 수의 글로벌 변수

var bool m_bDrawBg;				// 배경에 흰 테두리를 번갈아가며 그려주기 위한 변수

var WindowHandle	Me;			//그냥 메인 윈도우 핸들

var ButtonHandle		btnRecieve;	// 받기 버튼
var ButtonHandle		btnCancle;		// 취소 버튼
var TreeHandle		PremiumItemListTree;	//트리 컨트롤

var EditBoxHandle	GetnumEdit;	//수량 에디트박스 컨트롤


//-------------------------------------------------------------------------------------------------
// 로딩시 처리
//-------------------------------------------------------------------------------------------------

function OnRegisterEvent()
{
	RegisterEvent( EV_PremiumItemList );		// 임시
}

function OnLoad()
{	
	SetClosingOnESC();

	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	if(CREATE_ON_DEMAND==0)
	{
		Me = GetHandle( "PremiumItemGetWnd" ); // 메인 윈도우 핸들 가져오기
		btnRecieve = ButtonHandle( GetHandle( "PremiumItemGetWnd.btnRecieve" ) ); 
		btnCancle = ButtonHandle( GetHandle( "PremiumItemGetWnd.btnCancle" ) ); 
		PremiumItemListTree = TreeHandle( GetHandle( "PremiumItemGetWnd.PremiumItemListTree" ) ); 
		
		GetNumEdit = EditBoxHandle( GetHandle( "PremiumItemGetWnd.GetNumEdit" ) ); 
	}
	else
	{
		Me = GetWindowHandle( "PremiumItemGetWnd" ); // 메인 윈도우 핸들 가져오기
		btnRecieve = GetButtonHandle( "PremiumItemGetWnd.btnRecieve" ); 
		btnCancle = GetButtonHandle( "PremiumItemGetWnd.btnCancle" ); 
		PremiumItemListTree = GetTreeHandle( "PremiumItemGetWnd.PremiumItemListTree" ); 
		
		GetNumEdit = GetEditBoxHandle( "PremiumItemGetWnd.GetNumEdit" ); 
	}
	clear();
}

function onShow()
{
	// 지정한 윈도우를 제외한 닫기 기능 
	getInstanceL2Util().ItemRelationWindowHide(getCurrentWindowName(String(self)));
} 


function clear()
{
	m_bDrawBg = true;
	m_clickedID = -1;
	m_clickedItemNum = -1;
	btnRecieve.DisableWindow();	//디스에이블
	GetnumEdit.clear();
}

function createTreeRoot()
{
	local XMLTreeNodeInfo	infNode;	
	local string strTmp;
	
	//트리에 Root추가	// 루트는 로딩시 한번만 만든다. 
	infNode.strName = "PremiumItemListTreeRoot";
	infNode.nOffSetX = 0;
	infNode.nOffSetY = 0;
	strTmp = PremiumItemListTree.InsertNode("", infNode);
	if (Len(strTmp) < 1)
	{
		//debug("ERROR: Can't insert root node. Name: " $ infNode.strName);
		return;
	}	
}

// 버튼 클릭 이벤트들
function OnClickButton( string strID )
{	
	local int nowClickedID;
	local int nowClickedItemNum;
	local int nowEditBoxNum;
	local string removeRootStr;
	local int iLength;
	local int SplitCount;
	local array<string>	arrSplit;
	
	iLength = Len(strID) - Len("PremiumItemListTreeRoot."); // 트리의 이름이 "PremiumItemListTreeRoot.ID" 형태로 붙게 되므로
	removeRootStr = Right(strID, iLength);

	switch( strID )
	{
	case "btnRecieve":
		if(m_clickedID != -1)	//선택된 노드가 있을 경우에만
		{
			nowEditBoxNum = int(GetnumEdit.GetString());
			//debug ("m_clickedID = " $ m_clickedID $ "nowEditBoxNum = " $ nowEditBoxNum);	//디벅
			
			// 서버에 받기를 요청하는 API 함수
			RequestWithDrawPremiumItem(m_clickedID, nowEditBoxNum);
			
			if(m_maxCount == 1)	// 하나 남은 것을 받은 후에는 창을 자동으로 닫아줌
			{
				Me.HideWindow();
			}
			return;
		}
		break;
		
	case "btnCancle":
		Me.HideWindow();
		return;
		break;
	}
	
	// 위 두 경우에 해당하지 않으면, 트리 노드가 클릭된 것이다.
	//노드에서 정보 뽑아내기
	SplitCount = Split(removeRootStr, ".", arrSplit);	// "ID.수량" 형태를 구분
	
	if(splitCount <0 || splitCount >2)	// "ID.수량" 형태가 아니면 버그다.
	{
		//debug ("ERROR wrong button name!!");
		return;
	}
	
	//debug("SplitCount = " $ SplitCount);
	nowClickedID = int(arrSplit[0]);
	nowClickedItemNum = int(arrSplit[1]);
	
	if(m_clickedID == nowClickedID)
	{
		m_clickedID = -1;	// 좀전에 클릭했던 거라면 선택 해제
		m_clickedItemNum = 1;
		btnRecieve.DisableWindow();	//디스에이블 처리
		GetnumEdit.clear();
	}
	else
	{
		m_clickedID = nowClickedID;
		m_clickedItemNum = nowClickedItemNum;
		GetnumEdit.SetString("" $ nowClickedItemNum);
		btnRecieve.EnableWindow();	//인에이블 처리
	}	
}

// 이벤트 메세지 처리
function OnEvent(int Event_ID, string param)
{	
	switch(Event_ID)
	{
		
	case EV_PremiumItemList :
		clearInfo();	//초기화
		PremiumItemListTree.Clear();	//초기화
		if(!IsShowWindow("PremiumItemGetWnd"))	//창이 안떠잇으면 띄워준다.
			ShowWindowWithFocus("PremiumItemGetWnd");
		
		HandlePremiumItemList(param);
		break;
	}
	
}

function HandlePremiumItemList(string param)
{
	local int 	i ;			//루프를 위한 변수
	local int	iItemCount ;	//리스트의 아이템 수
	local int	iGift ;			//선물인가
	local int	iItemClassID;	//아이템의 클래스 아이디
	local INT64	iItemAmount;	//아이템 수량
	local string senderCharacter;	//보낸이
	
	clear();			// 잡데이터 초기화
	createTreeRoot();	//루트 생성
	
	//------------- 데이터 파싱----------
	iItemCount = 0;
	ParseInt(param,"ItemCount", iItemCount);
	
	m_maxCount = iItemCount;	//전역변수에 총 아이템 리스트 수를 넣어준다. 
	
	for(i = 0; i<iItemCount ; i++)
	{
		ParseInt(param,"Gift_" $ i , iGift);
		ParseInt(param,"ItemClassID_" $ i , iItemClassID);
		ParseInt64(param,"ItemAmount_" $ i , iItemAmount);		
		ParseString(param,"SenderCharacter_" $ i , senderCharacter);	
		AddPremiumListItem( iGift, iItemClassID, iItemAmount, senderCharacter, i);
	}
}

function AddPremiumListItem(int iGift ,  int iItemClassID , INT64 iItemAmount , string senderCharacter , int iIndexID)
{
	local XMLTreeNodeInfo	infNode;
	local XMLTreeNodeItemInfo	infNodeItem;
	local XMLTreeNodeInfo	infNodeClear;
	local XMLTreeNodeItemInfo	infNodeItemClear;

	local string strRetName;
	local ItemID mItemID;
	local string strIconName;
	local string strName;
	
	local UserInfo myInfo;

	//////////////////////////////////////////////////////////////////////////////////////////////////////
	//버튼없는 노드 추가
	infNode = infNodeClear;
	infNode.strName = ""$ iIndexID $"." $iItemAmount;
	infNode.bShowButton = 0;
	
	GetPlayerInfo( myInfo );
	
	mItemID.ClassID = iItemClassID;
	strIconName = class'UIDATA_ITEM'.static.GetItemTextureName( mItemID );
	strName = class'UIDATA_ITEM'.static.GetItemName( mItemID );

	//Expand되었을때의 BackTexture설정
	//스트레치로 그리기 때문에 ExpandedWidth는 없다. 끝에서 -2만큼 배경을 그린다.
	infNode.nTexExpandedOffSetX = 0;		//OffSet
	infNode.nTexExpandedOffSetY = 0;		//OffSet
	infNode.nTexExpandedHeight = 38;		//Height
	infNode.nTexExpandedRightWidth = 0;		//오른쪽 그라데이션부분의 길이
	infNode.nTexExpandedLeftUWidth = 30; 		//스트레치로 그릴 왼쪽 텍스쳐의 UV크기
	infNode.nTexExpandedLeftUHeight = 38;
	infNode.strTexExpandedLeft = "L2UI_CH3.etc.IconSelect2";
	
	strRetName = PremiumItemListTree.InsertNode("PremiumItemListTreeRoot", infNode);
	if (Len(strRetName) < 1)
	{
		//debug("ERROR: Can't insert node. Name: " $ infNode.strName);
		return;
	}
	
	//번갈아가면서 배경 그려주기
	if (m_bDrawBg == true)
	{
		infNodeItem = infNodeItemClear;
		infNodeItem.eType = XTNITEM_TEXTURE;
		infNodeItem.nOffSetX = 0;
		infNodeItem.nOffSetY = 0;
		infNodeItem.u_nTextureUHeight = 14;
		infNodeItem.u_nTextureWidth = 341;
		infNodeItem.u_nTextureHeight = 38;
		infNodeItem.u_strTexture = "L2UI_CH3.etc.textbackline";
		PremiumItemListTree.InsertNodeItem(strRetName, infNodeItem);
		m_bDrawBg = false;
	}
	else
	{
		infNodeItem = infNodeItemClear;
		infNodeItem.eType = XTNITEM_TEXTURE;
		infNodeItem.nOffSetX = 0;
		infNodeItem.nOffSetY = 0;
		infNodeItem.u_nTextureWidth = 341;
		infNodeItem.u_nTextureHeight = 38;
		infNodeItem.u_strTexture = "L2UI_CT1.EmptyBtn";
		PremiumItemListTree.InsertNodeItem(strRetName, infNodeItem);
		m_bDrawBg = true;	
	}

	//Insert Node Item - 아이템 아이콘 테두리 텍스쳐
	infNodeItem = infNodeItemClear;
	infNodeItem.eType = XTNITEM_TEXTURE;
	infNodeItem.nOffSetX = -341 +1;	
	infNodeItem.nOffSetY = 2;
	infNodeItem.u_nTextureWidth = 36;
	infNodeItem.u_nTextureHeight = 36;
	infNodeItem.u_strTexture ="L2UI_ct1.ItemWindow.ItemWindow_df_slotbox_2x2";
	PremiumItemListTree.InsertNodeItem(strRetName, infNodeItem);

	//Insert Node Item - 아이템 아이콘
	infNodeItem = infNodeItemClear;
	infNodeItem.eType = XTNITEM_TEXTURE;
	infNodeItem.nOffSetX = -36 + 2;
	infNodeItem.nOffSetY = 3;
	infNodeItem.u_nTextureWidth = 32;
	infNodeItem.u_nTextureHeight = 32;
	infNodeItem.u_strTexture = strIconName;
	PremiumItemListTree.InsertNodeItem(strRetName, infNodeItem);

	//Insert Node Item - 아이템 이름
	infNodeItem = infNodeItemClear;
	infNodeItem.eType = XTNITEM_TEXT;
	infNodeItem.t_strText = strName $ " X " $ iItemAmount;
	infNodeItem.t_bDrawOneLine = true;
	infNodeItem.nOffSetX = 7;
	infNodeItem.nOffSetY = 5;
	PremiumItemListTree.InsertNodeItem(strRetName, infNodeItem);
	
	//Insert Node Item - 보낸사람
	//보낸 사람 정보가 있고, 내 이름과 동일하지 않다면 보낸사람 정보를 보여준다. 
	if( (iGift != 0) && ( Len(senderCharacter) > 0 ) && ( InStr( senderCharacter , myInfo.name ) < 0 ) )
	{
		infNodeItem = infNodeItemClear;
		infNodeItem.eType = XTNITEM_TEXT;
		infNodeItem.t_strText = "["$ GetSystemString(1740) $ " " $ senderCharacter $ "]";
		infNodeItem.bLineBreak = true;
		infNodeItem.t_bDrawOneLine = true;
		infNodeItem.nOffSetX = 43;
		infNodeItem.nOffSetY = - 38 + 21;
		infNodeItem.t_color.R = 163;
		infNodeItem.t_color.G = 163;
		infNodeItem.t_color.B = 163;
		infNodeItem.t_color.A = 255;
		PremiumItemListTree.InsertNodeItem(strRetName, infNodeItem);
	}
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);		
	class'UIAPI_WINDOW'.static.HideWindow("PremiumItemGetWnd");		
}



//각종 정보 초기화
function clearInfo()
{
	m_bDrawBg = true;
}
defaultproperties
{
}
