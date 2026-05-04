class ClanShopEditWnd extends UICommonAPI;

var WindowHandle Me;
var TextureHandle EditBtnImg_texture;
var WindowHandle ClanShopListWnd;
var CheckBoxHandle LockVeiw_checkBox;
var TextureHandle ClanShopListListDeco_texture;
var ListCtrlHandle ClanShop_ListCtrl;
var TextureHandle ClanShopListWndBG_Texture;
var TextureHandle ClanShopListBG_Texture;
var WindowHandle ClanShopItemInfoWnd;
var TextBoxHandle ItemInfo_Text;
var TextBoxHandle NeedItem_Text;
var TextBoxHandle ExchangeNum_Text;
var TextBoxHandle ClanItemName_text;
var TextBoxHandle ClanItemDescription_text;
var WindowHandle LockCancel_Wnd;
var TextBoxHandle clanLVTitle_text;
var TextBoxHandle clanLVNum_text;
var TextBoxHandle clanAttributeTitle_text;
var TextBoxHandle clanAttributeNum_text;
var WindowHandle NeededItem_Wnd;
var TextureHandle NeededItem_SlotBg1_Texture;
var TextureHandle NeededItem_SlotBg2_Texture;
var ItemWindowHandle NeededItem_Item1_ItemWnd;
var ItemWindowHandle NeededItem_Item2_ItemWnd;
var TextBoxHandle NeededItem_Item1Title_text;
var TextBoxHandle NeededItem_Item1Num_text;
var TextBoxHandle NeededItem_Item1MyNum_text;
var TextBoxHandle NeededItem_Item2Title_text;
var TextBoxHandle NeededItem_Item2Num_text;
var TextBoxHandle NeededItem_Item2MyNum_text;
var TextureHandle ItemInfoBg_Texture;
var TextureHandle LockCancelBg_Texture;
var TextureHandle NeededItemBg_Texture;
var ButtonHandle ExChange_Button;
var WindowHandle DisableWnd;
var WindowHandle DescriptionMsgWnd;
var TextBoxHandle DescriptionMsg_Text;
var ButtonHandle Refresh_Button;
var ButtonHandle Close_Button;

var WindowHandle ClanShopConfirm_ResultWnd;
var WindowHandle ClanShopSuccess_ResultWnd;
var WindowHandle ClanShopFails_ResultWnd;

//리스트 총 개수
var int listTotalCount;
//리스트 끝나는 이벤트 계산
var int endCount;

//정렬을 위한 struct 값 sort0, sort1로 정렬함.
struct ClanItemInfo
{
	var LVDataRecord        record;
	var int			        sort0;
	var int			        sort1;	
};

//리스트 저장 배열
var array<ClanItemInfo> itemListArray;

var L2Util util;

var ItemInfo SelectItemInfo;


//목록 갱신용 타이머 ID
const TIMER_CLICK       = 99904;
//목록 갱신용 타이머 딜레이 3초
const TIMER_DELAYC       = 3000;

function OnRegisterEvent()
{
	RegisterEvent( EV_PledgeItemList );
	RegisterEvent( EV_PledgeItemInfo );
	RegisterEvent( EV_PledgeItemActivate );
}

function OnLoad()
{
	Initialize();
	Load();
	SetClosingOnESC(); 
}

function Initialize()
{
	Me = GetWindowHandle( "ClanShopEditWnd" );
	EditBtnImg_texture = GetTextureHandle( "ClanShopEditWnd.EditBtnImg_texture" );
	ClanShopListWnd = GetWindowHandle( "ClanShopEditWnd.ClanShopListWnd" );
	LockVeiw_checkBox = GetCheckBoxHandle( "ClanShopEditWnd.ClanShopListWnd.LockVeiw_checkBox" );
	ClanShopListListDeco_texture = GetTextureHandle( "ClanShopEditWnd.ClanShopListWnd.ClanShopListListDeco_texture" );
	ClanShop_ListCtrl = GetListCtrlHandle( "ClanShopEditWnd.ClanShopListWnd.ClanShop_ListCtrl" );
	ClanShopListWndBG_Texture = GetTextureHandle( "ClanShopEditWnd.ClanShopListWnd.ClanShopListWndBG_Texture" );
	ClanShopListBG_Texture = GetTextureHandle( "ClanShopEditWnd.ClanShopListWnd.ClanShopListBG_Texture" );
	ClanShopItemInfoWnd = GetWindowHandle( "ClanShopEditWnd.ClanShopItemInfoWnd" );
	ItemInfo_Text = GetTextBoxHandle( "ClanShopEditWnd.ClanShopItemInfoWnd.ItemInfo_Text" );
	NeedItem_Text = GetTextBoxHandle( "ClanShopEditWnd.ClanShopItemInfoWnd.NeedItem_Text" );
	ExchangeNum_Text = GetTextBoxHandle( "ClanShopEditWnd.ClanShopItemInfoWnd.ExchangeNum_Text" );
	ClanItemName_text = GetTextBoxHandle( "ClanShopEditWnd.ClanShopItemInfoWnd.ClanItemName_text" );
	ClanItemDescription_text = GetTextBoxHandle( "ClanShopEditWnd.ClanShopItemInfoWnd.ClanItemDescription_text" );
	LockCancel_Wnd = GetWindowHandle( "ClanShopEditWnd.ClanShopItemInfoWnd.LockCancel_Wnd" );
	clanLVTitle_text = GetTextBoxHandle( "ClanShopEditWnd.ClanShopItemInfoWnd.LockCancel_Wnd.clanLVTitle_text" );
	clanLVNum_text = GetTextBoxHandle( "ClanShopEditWnd.ClanShopItemInfoWnd.LockCancel_Wnd.clanLVNum_text" );
	clanAttributeTitle_text = GetTextBoxHandle( "ClanShopEditWnd.ClanShopItemInfoWnd.LockCancel_Wnd.clanAttributeTitle_text" );
	clanAttributeNum_text = GetTextBoxHandle( "ClanShopEditWnd.ClanShopItemInfoWnd.LockCancel_Wnd.clanAttributeNum_text" );
	NeededItem_Wnd = GetWindowHandle( "ClanShopEditWnd.ClanShopItemInfoWnd.NeededItem_Wnd" );
	NeededItem_SlotBg1_Texture = GetTextureHandle( "ClanShopEditWnd.ClanShopItemInfoWnd.NeededItem_Wnd.NeededItem_SlotBg1_Texture" );
	NeededItem_SlotBg2_Texture = GetTextureHandle( "ClanShopEditWnd.ClanShopItemInfoWnd.NeededItem_Wnd.NeededItem_SlotBg2_Texture" );
	NeededItem_Item1_ItemWnd = GetItemWindowHandle( "ClanShopEditWnd.ClanShopItemInfoWnd.NeededItem_Wnd.NeededItem_Item1_ItemWnd" );
	NeededItem_Item2_ItemWnd = GetItemWindowHandle( "ClanShopEditWnd.ClanShopItemInfoWnd.NeededItem_Wnd.NeededItem_Item2_ItemWnd" );
	NeededItem_Item1Title_text = GetTextBoxHandle( "ClanShopEditWnd.ClanShopItemInfoWnd.NeededItem_Wnd.NeededItem_Item1Title_text" );
	NeededItem_Item1Num_text = GetTextBoxHandle( "ClanShopEditWnd.ClanShopItemInfoWnd.NeededItem_Wnd.NeededItem_Item1Num_text" );
	NeededItem_Item1MyNum_text = GetTextBoxHandle( "ClanShopEditWnd.ClanShopItemInfoWnd.NeededItem_Wnd.NeededItem_Item1MyNum_text" );
	NeededItem_Item2Title_text = GetTextBoxHandle( "ClanShopEditWnd.ClanShopItemInfoWnd.NeededItem_Wnd.NeededItem_Item2Title_text" );
	NeededItem_Item2Num_text = GetTextBoxHandle( "ClanShopEditWnd.ClanShopItemInfoWnd.NeededItem_Wnd.NeededItem_Item2Num_text" );
	NeededItem_Item2MyNum_text = GetTextBoxHandle( "ClanShopEditWnd.ClanShopItemInfoWnd.NeededItem_Wnd.NeededItem_Item2MyNum_text" );
	ItemInfoBg_Texture = GetTextureHandle( "ClanShopEditWnd.ClanShopItemInfoWnd.ItemInfoBg_Texture" );
	LockCancelBg_Texture = GetTextureHandle( "ClanShopEditWnd.ClanShopItemInfoWnd.LockCancelBg_Texture" );
	NeededItemBg_Texture = GetTextureHandle( "ClanShopEditWnd.ClanShopItemInfoWnd.NeededItemBg_Texture" );
	ExChange_Button = GetButtonHandle( "ClanShopEditWnd.ClanShopItemInfoWnd.ExChange_Button" );
	DisableWnd = GetWindowHandle( "ClanShopEditWnd.DisableWnd" );
	DescriptionMsgWnd = GetWindowHandle( "ClanShopEditWnd.DescriptionMsgWnd" );
	DescriptionMsg_Text = GetTextBoxHandle( "ClanShopEditWnd.DescriptionMsgWnd.DescriptionMsg_Text" );
	Refresh_Button = GetButtonHandle( "ClanShopEditWnd.Refresh_Button" );
	Close_Button = GetButtonHandle( "ClanShopEditWnd.Close_Button" );
	
	ClanShopConfirm_ResultWnd = GetWindowHandle( "ClanShopEditWnd.ClanShopConfirm_ResultWnd" );
	ClanShopSuccess_ResultWnd = GetWindowHandle( "ClanShopEditWnd.ClanShopSuccess_ResultWnd" );
	ClanShopFails_ResultWnd = GetWindowHandle( "ClanShopEditWnd.ClanShopFails_ResultWnd" );

	util                       = L2Util(GetScript("L2Util"));

	ClanShop_ListCtrl.SetSelectedSelTooltip(FALSE);	
	ClanShop_ListCtrl.SetAppearTooltipAtMouseX(true);
}

function Load()
{
}

function OnShow()
{
	RequestPledgeItemList();	
}
function OnHide()
{
	ClearAll();
}
function OnEvent(int Event_ID, string param)
{
	//Debug( "debuftest OnEvent " @ Event_ID  @ param);
	local int nResult;
	//상점 아이템 리스트 개수 들어옴
	if( Event_ID == EV_PledgeItemList )
	{
		ClearAll();
		ParseInt( param, "nCount", listTotalCount );			
	}
	//상점 아이템 정보
	else if (Event_ID == EV_PledgeItemInfo)
	{
		ItemListInfo( param );		
	}
	//아이템 활성화 결과 이벤트
	else if( Event_ID == EV_PledgeItemActivate )
	{
		Debug( "debuftest OnEvent " @ Event_ID  @ param);
		ParseInt( param, "nResult", nResult );
		if( nResult == 0 )
		{
			Debug("성공!~~~~~~~~~~~~~~~~~~~~~~~!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!");
			SetSuccessWnd();				
		}
		else
		{
			SetFailWnd( nResult );
			ClanShopFails_ResultWnd.ShowWindow();
		}
	}
}

function SetSuccessWnd()
{
	local ItemWindowHandle Result_ItemWnd;
	local TextBoxHandle	ItemName_TextBox, Discription_TextBox;

	Result_ItemWnd = GetItemWindowHandle( "ClanShopEditWnd.ClanShopSuccess_ResultWnd.Result_ItemWnd" );
	ItemName_TextBox = GetTextBoxHandle( "ClanShopEditWnd.ClanShopSuccess_ResultWnd.ItemName_TextBox" );
	Discription_TextBox = GetTextBoxHandle( "ClanShopEditWnd.ClanShopSuccess_ResultWnd.Discription_TextBox" );

	Result_ItemWnd.Clear();
	Result_ItemWnd.AddItem( SelectItemInfo );
	ItemName_TextBox.SetText( GetItemNameAll ( SelectItemInfo ) );
	Discription_TextBox.SetText( GetSystemMessage( 4568 ) );

	ClanShopSuccess_ResultWnd.ShowWindow();
}

function SetFailWnd( int n )
{
	local TextBoxHandle Discription_TextBox;
	Discription_TextBox = GetTextBoxHandle( "ClanShopEditWnd.ClanShopFails_ResultWnd.Discription_TextBox" );
	
	if( n == 3 )
	{
		//스킬 시전 중에는 해당 기능을 사용할 수 없습니다.
		Discription_TextBox.SetText( GetSystemMessage( 4690 ) );
	}
	else if( n == 4)
	{
		//해당 권한이 없습니다.
		Discription_TextBox.SetText( GetSystemMessage( 3721 ) );
	}
	else if( n == -3 || n == -4 )
	{
		//활성화 비용이 부족합니다.
		Discription_TextBox.SetText( GetSystemMessage( 4691 ) );
	}
	else
	{
		//1, -1, -2, -5, 2
		//시스템 오류로 진행할 수 없습니다. 잠시 후 다시 시도해 주세요.
		Discription_TextBox.SetText( GetSystemMessage( 4559 ) );
	}
}

function ClearAll()
{
	endCount = 0;
	itemListArray.Remove(0, itemListArray.Length);
	ClanShop_ListCtrl.DeleteAllItem();
	ClanShopConfirm_ResultWnd.hideWindow();
	ClanShopSuccess_ResultWnd.hideWindow();
	ClanShopFails_ResultWnd.hideWindow();	
	DisableWnd.hideWindow();
}

/**
 * 상점 아이템 정보
 * ItemInfo (skip...)
 * int Status  //(0: locked, 1: inactivated, 2: activated)
 * int64 SellPrice // 구매 가격(adena)
 * int SellNameValue // 구매 개인 명성치
 * int ActivatePledgeLevel // 활성화 필요 혈맹 레벨
 * int ActivateMasteryID //활성화 필요 특성
 * int64 ActivatePrice // 활성화 가격(adena)
 * int ActivateNameValue //활성화 명성치
 * int RemainActivateTime //활성화 남은 시간 (초)
 * int RemainResetTime //수량 초기화 남은 시간 (초)
 * int MaxQuantity // 최대 수량
 */
function ItemListInfo( string param )
{	
	makeRecord( param );
	endCount++;
	if( endCount == listTotalCount )
	{
		ItemListInfoEnd();
	}
}

/**
 *  일일 미션 리스트 받음 완료
 **/
function ItemListInfoEnd()
{
	local int i;
	local int n;

	ClanShop_ListCtrl.DeleteAllItem();

	//정렬 상태 기준
	//itemListArray.Sort( OnSortCompare );

	for( i = 0 ; i < itemListArray.Length ; i++ )
	{
		//"전체 미션 보기" 체크 시 전부 보여줌
		if( LockVeiw_checkBox.IsChecked() )
		{	
			ClanShop_ListCtrl.InsertRecord( itemListArray[ i ].record );
		}
		//"전체 미션 보기" 해제 시 잠금 상태 보여 주지 않음
		else
		{
			if( itemListArray[i].sort0 != 0 )
			{
				ClanShop_ListCtrl.InsertRecord( itemListArray[ i ].record );
			}
		}
	}
	//이전에 선택된 것이 있다면 선택
	n = findItemIndex( SelectItemInfo );

	if( n > 0 )
	{
		ClanShop_ListCtrl.SetSelectedIndex( n, true );
	}
	else
	{
		ClanShop_ListCtrl.SetSelectedIndex( 0, true );
	}
	OnClickListCtrlRecord("ClanShop_ListCtrl");
}

function int findItemIndex( ItemInfo info )
{
	local int i, n;
	n = -1;
	for( i = 0 ; i < itemListArray.Length ; i++ )
	{
		if( info.Id.ServerID == itemListArray[ i ].record.nReserved1 )
		{
			n = i;
		}		
	}
	return n;
}

//리스트를 만들어 봅시다..ㅋㅋ
function makeRecord( string param )
{
	local LVDataRecord Record;
	local string fullNameString;
	local itemInfo Info;

	local string MaxQuantity;
	local int RemainQuantity;
	local int RemainResetTime;
	local int Status;
	local int RemainActivateTime; 

	ParseString( param, "MaxQuantity", MaxQuantity);
	ParseInt( param, "RemainQuantity", RemainQuantity);
	ParseInt( param, "RemainResetTime", RemainResetTime);
	ParseInt( param, "RemainActivateTime", RemainActivateTime);
	//Debug(param);
	ParseInt( param, "Status", Status);

	ParamToItemInfo( param, info );

	fullNameString = GetItemNameAll ( info );

	// 툴팁을 저장하기 위해 param으로 분해 사용
	ItemInfoToParam(info, param);
	
	// 툴팁 정보
	Record.szReserved = param;	
	// 아이템 서버 아이디
	Record.nReserved1 = Int64(info.Id.ServerID);
	// 아이템 최대 값
	Record.nReserved2 = info.ItemNum;
	// 아이템 정보의 index 값
	//Record.nReserved3 = index;

	Record.LVDataList.length = 4;

	Record.LVDataList[0].szData = fullNameString;

	Record.LVDataList[0].hasIcon = true;
	Record.LVDataList[0].nTextureWidth=32;
	Record.LVDataList[0].nTextureHeight=32;
	Record.LVDataList[0].nTextureU=32;
	Record.LVDataList[0].nTextureV=32;
	Record.LVDataList[0].szTexture = info.IconName; 
	Record.LVDataList[0].IconPosX=10;
	Record.LVDataList[0].FirstLineOffsetX=6;
	Record.LVDataList[0].HiddenStringForSorting = string( Status );

	// back texture 
	Record.LVDataList[0].iconBackTexName="l2ui_ct1.ItemWindow_DF_SlotBox_Default";
	Record.LVDataList[0].backTexOffsetXFromIconPosX=-2;
	Record.LVDataList[0].backTexOffsetYFromIconPosY=-1;
	Record.LVDataList[0].backTexWidth=36;
	Record.LVDataList[0].backTexHeight=36;
	Record.LVDataList[0].backTexUL=36;
	Record.LVDataList[0].backTexVL=36;

	// 아이콘 테두리 (기본 병기.pvp 무기등)
	Record.LVDataList[0].iconPanelName = info.iconPanel;
	Record.LVDataList[0].panelOffsetXFromIconPosX=0;
	Record.LVDataList[0].panelOffsetYFromIconPosY=0;
	Record.LVDataList[0].panelWidth=32;
	Record.LVDataList[0].panelHeight=32;
	Record.LVDataList[0].panelUL=32;
	Record.LVDataList[0].panelVL=32;	

	Record.LVDataList[0].bUseTextColor = true;	

	Record.LVDataList[0].attrIconTexArray.Length=1;
	Record.LVDataList[0].attrIconTexArray[0].X=0;
	Record.LVDataList[0].attrIconTexArray[0].Y=2;
	Record.LVDataList[0].attrIconTexArray[0].Width=14;
	Record.LVDataList[0].attrIconTexArray[0].Height=14;
	Record.LVDataList[0].attrIconTexArray[0].U=0;
	Record.LVDataList[0].attrIconTexArray[0].V=0;
	Record.LVDataList[0].attrIconTexArray[0].UL=14;
	Record.LVDataList[0].attrIconTexArray[0].VL=14;

	//시계 아이콘
	Record.LVDataList[0].attrIconTexArray[0].objTex = GetTexture("L2UI_CT1.SkillWnd.SkillWnd_DF_ListIcon_Use");

	if( Status == 0)
	{
		//어두운 회색(아이템 이름)
		Record.LVDataList[0].TextColor = util.DarkGray;		

		//회색 getColor(153, 153, 153, 255 );
		Record.LVDataList[0].attrColor = util.ColorGray;
		//잠김
		Record.LVDataList[0].attrStat[0] = GetSystemMessage( 4566 );
		Record.LVDataList[0].foreTextureName = "L2UI_CT1.Icon.ItemLock";
	}
	else if( Status == 1)
	{
		//어두운 회색(아이템 이름)
		Record.LVDataList[0].TextColor = util.DarkGray;

		Record.LVDataList[0].attrColor = getColor(255, 102, 102, 255 );
		//활성화 필요
		Record.LVDataList[0].attrStat[0] = GetSystemMessage( 4564 );
	}
	else
	{
		//밝은 흰색(아이템 이름)
		Record.LVDataList[0].TextColor = util.BWhite;
		//활성화
		Record.LVDataList[0].attrColor = util.DRed;
		if( RemainActivateTime == 0 )
		{
			Record.LVDataList[0].attrColor = getColor(119, 255, 178, 255 );
			Record.LVDataList[0].attrStat[0] = GetSystemMessage( 4565 );
		}
		else
		{
			Record.LVDataList[0].attrColor = util.Yellow03;
			Record.LVDataList[0].attrStat[0] = getTimeStringBySec( RemainActivateTime );
		}
	}
	
	Record.LVDataList[1].hasIcon = true;
	Record.LVDataList[1].bUseTextColor = true;

	Record.LVDataList[1].TextColor = util.DarkGray;
	Record.LVDataList[1].attrColor = util.DarkGray;

	if( MaxQuantity == "0" )
	{
		if( Status == 2 )
		{
			Record.LVDataList[1].TextColor = getColor(119, 255, 178, 255 );			
			Record.LVDataList[1].attrColor = getColor(211, 211, 211, 255 );
		}

		//"제한없음";
		Record.LVDataList[1].szData = GetSystemMessage( 4565 );
		
		Record.LVDataList[1].attrStat[0] = "-";
	}
	else
	{
		if( Status == 2 )
		{
			Record.LVDataList[1].TextColor = getColor(170, 153, 119, 255 );
			Record.LVDataList[1].attrColor = getColor(211, 211, 211, 255 );
		}
		
		Record.LVDataList[1].szData = string(RemainQuantity) $ "/" $ MaxQuantity;
		
		Record.LVDataList[1].attrStat[0] = getTimeStringBySec2(RemainResetTime);
	}
	
	//아이콘 넣기
	Record.LVDataList[1].attrIconTexArray.Length=1;	

	Record.LVDataList[1].attrIconTexArray[0].X=0;
	Record.LVDataList[1].attrIconTexArray[0].Y=2;
	Record.LVDataList[1].attrIconTexArray[0].Width=14;
	Record.LVDataList[1].attrIconTexArray[0].Height=14;
	Record.LVDataList[1].attrIconTexArray[0].U=0;
	Record.LVDataList[1].attrIconTexArray[0].V=0;
	Record.LVDataList[1].attrIconTexArray[0].UL=14;
	Record.LVDataList[1].attrIconTexArray[0].VL=14;
	Record.LVDataList[1].attrIconTexArray[0].objTex = GetTexture("L2UI_CT1.SkillWnd.SkillWnd_DF_ListIcon_Reuse");	

	//정렬을 위해 배열에 insert
	itemListArray.Insert( itemListArray.Length, 1 );
	itemListArray[ itemListArray.Length - 1].record = record;
	itemListArray[ itemListArray.Length - 1].sort0 = Status;
}

/*
function array<itemInfo> pushItemInfoArray( array<itemInfo> itemList, ItemInfo pushList )
{
	//local int i ;
	local int itemListRen;
	itemListRen = itemList.Length;
	itemList.Length = itemListRen + 1;
	
	itemList[ itemListRen ] = pushList;
	
	return itemList;
}*/


/**  
 *   리스트 클릭
 **/
function OnClickListCtrlRecord( string ListCtrlID )
{
	local LVDataRecord Record;
	local string param;
	local string ActivatePledgeLevel;
	local itemInfo Info;
	
	local int SellPrice, SellNameValue, ActivateNameValue, ActivateMasteryID;	

	local UserInfo infoPlayer;
	local int64 iPlayerSP, ActivatePrice;

	local int Status;

	GetPlayerInfo(infoPlayer);

	iPlayerSP = INT64(GetClanNameValue(infoPlayer.nClanID));

	ClanShop_ListCtrl.GetSelectedRec(Record);
		
	param = Record.szReserved;

	debug(param);

	ParamToItemInfo( param, info );
	SelectItemInfo = info;
	
	ParseInt(param, "SellPrice", SellPrice);
	ParseInt(param, "SellNameValue", SellNameValue);
	ParseInt(param, "ActivateMasteryID", ActivateMasteryID);
	ParseInt(param, "ActivateNameValue", ActivateNameValue );
	ParseInt64( param, "ActivatePrice", ActivatePrice );
	ParseInt(param, "Status", Status );
	ParseString( param, "ActivatePledgeLevel", ActivatePledgeLevel );	

	class'UIAPI_MULTISELLITEMINFO'.static.Clear("ClanShopEditWnd.multiSellItemInfo");
	if( param != "" )
	{
		class'UIAPI_MULTISELLITEMINFO'.static.SetItemInfo( "ClanShopEditWnd.multiSellItemInfo", 0, info );
	}

	//활성화 필요 혈맹 레벨
	clanLVNum_text.SetText( ActivatePledgeLevel @ GetSystemString(859) );
	//활성화 필요 특성
	if( ActivateMasteryID == 0 )
	{
		//조건없음
		clanAttributeNum_text.SetText( GetSystemString(3744) );
	}
	else
	{
		//??특화 Lv ? 이상
		clanAttributeNum_text.SetText( GetPledgeMasteryName( ActivateMasteryID ) @ GetSystemString(859) );
	}

	//구매 혈맹 명성치
	NeededItem_Item1Num_text.SetText( "x" @ MakeCostString( string(ActivateNameValue) ) );
	//구매 아데나
	NeededItem_Item2Num_text.SetText( "x" @ MakeCostString( string(ActivatePrice) ) );

	if( Status == 1 )
	{
		ExChange_Button.EnableWindow();
	}
	else
	{
		ExChange_Button.disableWindow();
	}

}

/** 
 *  체크 박스 클릭 시
 **/
function OnClickCheckBox( String strID )
{
	switch( strID )
	{
		//"전체 미션 보기" 체크 박스 클릭 시
		case "LockVeiw_checkBox": 
			ItemListInfoEnd();
			break;
	}
}

function OnClickButton( string Name )
{
	Debug( "name--->"$ Name );
	switch( Name )
	{
		//활성화 버튼 클릭
		case "ExChange_Button":
			OnExChange_ButtonClick();
			break;
		case "Refresh_Button":
			OnRefresh_ButtonClick();
			break;
		case "Close_Button":
			OnClose_ButtonClick();
			break;
		//활성화 팝업
		case "OK_Button":
			OnOK_ButtonClick();
			break;
		case "Cancel_Button":
			OnCancel_ButtonClick();
			break;
		//성공 팝업 버튼
		case "Success_Button":
			OnSuccess_ButtonClick();
			break;
		//성공 팝업 버튼
		case "Fail_Button":
			OnFail_ButtonClick();
			break;

			
	}
}

//활성화 버튼 클릭
function OnExChange_ButtonClick()
{
	DisableWnd.ShowWindow();
	DisableWnd.SetFocus();

	ClanShopConfirm_ResultWnd.ShowWindow();
	setResultWnd();
}



function setResultWnd()
{
	local String param, fullNameString;
	local LVDataRecord Record;
	local ItemInfo info;
	local ItemWindowHandle Result_ItemWnd;
	local TextBoxHandle	ItemName_TextBox, FameNum_TextBox, AdenaNum_TextBox, Discription_TextBox;
	local int ActivateNameValue;	
	local int64  ActivatePrice;

	//RequestPledgeItemActivate(int nItemClassId);
	ClanShop_ListCtrl.GetSelectedRec( Record );

	param = Record.szReserved;
	ParamToItemInfo( param, info );
	ParseInt(param, "ActivateNameValue", ActivateNameValue );
	ParseInt64( param, "ActivatePrice", ActivatePrice );

	fullNameString = GetItemNameAll ( info );

	Result_ItemWnd = GetItemWindowHandle( "ClanShopEditWnd.ClanShopConfirm_ResultWnd.Result_ItemWnd" );
	ItemName_TextBox = GetTextBoxHandle( "ClanShopEditWnd.ClanShopConfirm_ResultWnd.ItemName_TextBox" );
	FameNum_TextBox = GetTextBoxHandle( "ClanShopEditWnd.ClanShopConfirm_ResultWnd.FameNum_TextBox" );
	AdenaNum_TextBox = GetTextBoxHandle( "ClanShopEditWnd.ClanShopConfirm_ResultWnd.AdenaNum_TextBox" );
	Discription_TextBox = GetTextBoxHandle( "ClanShopEditWnd.ClanShopConfirm_ResultWnd.Discription_TextBox" );

	Result_ItemWnd.Clear();
	Result_ItemWnd.AddItem( info );
	ItemName_TextBox.SetText( fullNameString );
	FameNum_TextBox.SetText( MakeCostString( string(ActivateNameValue) ) );
	AdenaNum_TextBox.SetText( MakeCostString( string(ActivatePrice) ) );
	Discription_TextBox.SetText( GetSystemMessage( 4567 ) );	
}							 

function OnRefresh_ButtonClick()
{
	RequestPledgeItemList();
	//목록 갱신용 타이머 시작
	Me.SetTimer( TIMER_CLICK, TIMER_DELAYC );
	//버튼 비활성
	Refresh_Button.DisableWindow();
}

/**
 * 시간 타이머 && 목록 갱신 타이머 이벤트
 ***/
function OnTimer(int TimerID) 
{
	//목록갱신 버튼 활성화
	if( TimerID == TIMER_CLICK )
	{
		Refresh_Button.EnableWindow();
		Me.KillTimer( TIMER_CLICK );
	}
}

function OnClose_ButtonClick()
{
	OnReceivedCloseUI();
}

function OnOK_ButtonClick()
{
	local ItemInfo info;
	local LVDataRecord Record;
	local String param;

	ClanShop_ListCtrl.GetSelectedRec( Record );

	param = Record.szReserved;
	ParamToItemInfo( param, info );

	RequestPledgeItemActivate( info.Id.ClassID );
	ClanShopConfirm_ResultWnd.hideWindow();
}

function OnCancel_ButtonClick()
{
	DisableWnd.hideWindow();
	ClanShopConfirm_ResultWnd.hideWindow();	

}
function OnSuccess_ButtonClick()
{
	DisableWnd.hideWindow();
	ClanShopSuccess_ResultWnd.hideWindow();	
	RequestPledgeItemList();
}

function OnFail_ButtonClick()
{
	DisableWnd.hideWindow();
	ClanShopFails_ResultWnd.hideWindow();	
	RequestPledgeItemList();
}

/**
 * 일/시간/분 || 시간/분 || //분 || //1분미만 으로 시간 바꿔줌
 **/
function string getTimeStringBySec(int sec)
{
	local int timeTemp, timeTemp0, timeTemp1;
	local string returnStr;

	if( sec < 0 ) sec = 0;

	returnStr = "";
	timeTemp = ((sec / 60) / 60 / 24);
	timeTemp0 = ((sec / 60) / 60);
	timeTemp1 = ((sec / 60));

	if( timeTemp > 0 )
	{
		//일/시간/분
		returnStr =  MakeFullSystemMsg(GetSystemMessage(4466), string(timeTemp), string(int( (sec / 60) / 60 % 24 ) ), string(int((sec / 60) % 60)));
	}
	else if( timeTemp0 > 0 )
	{
		//시간/분
		returnStr = MakeFullSystemMsg(GetSystemMessage(3304), string(timeTemp0), string(int((sec / 60) % 60)));
	}
	else if( timeTemp1 > 0 )
	{
		//분
		returnStr = MakeFullSystemMsg(GetSystemMessage(3390), string(timeTemp1));
	}
	else
	{
		//1분미만
		returnStr = MakeFullSystemMsg( GetSystemMessage(4360), string (1) );
	}
	return returnStr;	 
}

function string getTimeStringBySec2(int sec )
{
	local int timeTemp, timeTemp0;
	local string returnStr;

	if( sec < 0 ) sec = 0;

	returnStr = "";

	timeTemp = ((sec / 60) / 60);
	timeTemp0 = ((sec / 60));


	 if( timeTemp > 0 )
	{
		//시간/분
		returnStr = MakeFullSystemMsg(GetSystemMessage(3304), string(timeTemp), string(int((sec / 60) % 60)));
	}
	else if( timeTemp0 > 0 )
	{
		//분
		returnStr = MakeFullSystemMsg(GetSystemMessage(3390), string(timeTemp0));
	}
	else
	{
		//1분미만
		returnStr = MakeFullSystemMsg( GetSystemMessage(4360), string (1) );
	}
	return returnStr;	 
}



/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( getCurrentWindowName(string(Self))).HideWindow();
}

delegate int OnSortCompare( ClanItemInfo a, ClanItemInfo b )
{
    if (a.sort0 < b.sort0) // 오름 차순. 조건문에 < 이면 내림차순.
    {
        return -1;  // 자리를 바꿔야할때 -1를 리턴 하게 함.
    }
    else
    {
        return 0;
    }
}
defaultproperties
{
}
