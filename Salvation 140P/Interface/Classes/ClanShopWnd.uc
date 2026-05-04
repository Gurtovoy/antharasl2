class ClanShopWnd extends UICommonAPI;

var WindowHandle Me;
var TextureHandle EditBtnImg_texture;
var ButtonHandle ClanShopEdit_Button;
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
var EditBoxHandle ItemCount_EditBox;
var TextureHandle ItemInfoBg_Texture;
var TextureHandle NeededItemBg_Texture;
var TextureHandle ExchangeItemBg_Texture;
var TextureHandle ExchangeItemBg_Divider1;
var TextureHandle ExchangeItemBg_Divider2;
var ButtonHandle Clear_Button;
var ButtonHandle ExChange_Button;
var ButtonHandle MultiSell_Up_Button;
var ButtonHandle MultiSell_Down_Button;
var ButtonHandle MultiSell_Input_Button;
var WindowHandle DisableWnd;
var WindowHandle DescriptionMsgWnd;
var TextBoxHandle DescriptionMsg_Text;
var ButtonHandle Refresh_Button;
var ButtonHandle Close_Button;
var TextBoxHandle ItemNum_TextBox;

var WindowHandle ClanShopConfirm_ResultWnd;
var WindowHandle ClanShopSuccess_ResultWnd;
var WindowHandle ClanShopFails_ResultWnd;

const DIALOG_ASK_PRICE                         = 10111;		

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
const TIMER_CLICK       = 99902;
//목록 갱신용 타이머 딜레이 3초
const TIMER_DELAYC       = 3000;




function OnRegisterEvent()
{
	RegisterEvent( EV_PledgeItemList );
	RegisterEvent( EV_PledgeItemInfo );
	RegisterEvent( EV_PledgeItemBuy );
	registerEvent( EV_DialogOK );
	registerEvent( EV_DialogCancel );   
}

function OnLoad()
{
	Initialize();
	Load();
	SetClosingOnESC(); 
}

function Initialize()
{
	local ButtonHandle OK_Button;

	OK_Button = GetButtonHandle( "ClanShopWnd.ClanShopConfirm_ResultWnd.OK_Button");
	OK_Button.SetNameText( GetSystemString( 2517 ) );

	Me = GetWindowHandle( "ClanShopWnd" );
	EditBtnImg_texture = GetTextureHandle( "ClanShopWnd.EditBtnImg_texture" );
	ClanShopEdit_Button = GetButtonHandle( "ClanShopWnd.ClanShopEdit_Button" );
	ClanShopListWnd = GetWindowHandle( "ClanShopWnd.ClanShopListWnd" );
	LockVeiw_checkBox = GetCheckBoxHandle( "ClanShopWnd.ClanShopListWnd.LockVeiw_checkBox" );
	ClanShopListListDeco_texture = GetTextureHandle( "ClanShopWnd.ClanShopListWnd.ClanShopListListDeco_texture" );
	ClanShop_ListCtrl = GetListCtrlHandle( "ClanShopWnd.ClanShopListWnd.ClanShop_ListCtrl" );
	ClanShopListWndBG_Texture = GetTextureHandle( "ClanShopWnd.ClanShopListWnd.ClanShopListWndBG_Texture" );
	ClanShopListBG_Texture = GetTextureHandle( "ClanShopWnd.ClanShopListWnd.ClanShopListBG_Texture" );
	ClanShopItemInfoWnd = GetWindowHandle( "ClanShopWnd.ClanShopItemInfoWnd" );
	ItemInfo_Text = GetTextBoxHandle( "ClanShopWnd.ClanShopItemInfoWnd.ItemInfo_Text" );
	NeedItem_Text = GetTextBoxHandle( "ClanShopWnd.ClanShopItemInfoWnd.NeedItem_Text" );
	ExchangeNum_Text = GetTextBoxHandle( "ClanShopWnd.ClanShopItemInfoWnd.ExchangeNum_Text" );
	ClanItemName_text = GetTextBoxHandle( "ClanShopWnd.ClanShopItemInfoWnd.ClanItemName_text" );
	ClanItemDescription_text = GetTextBoxHandle( "ClanShopWnd.ClanShopItemInfoWnd.ClanItemDescription_text" );
	NeededItem_Wnd = GetWindowHandle( "ClanShopWnd.ClanShopItemInfoWnd.NeededItem_Wnd" );
	NeededItem_SlotBg1_Texture = GetTextureHandle( "ClanShopWnd.ClanShopItemInfoWnd.NeededItem_Wnd.NeededItem_SlotBg1_Texture" );
	NeededItem_SlotBg2_Texture = GetTextureHandle( "ClanShopWnd.ClanShopItemInfoWnd.NeededItem_Wnd.NeededItem_SlotBg2_Texture" );
	NeededItem_Item1_ItemWnd = GetItemWindowHandle( "ClanShopWnd.ClanShopItemInfoWnd.NeededItem_Wnd.NeededItem_Item1_ItemWnd" );
	NeededItem_Item2_ItemWnd = GetItemWindowHandle( "ClanShopWnd.ClanShopItemInfoWnd.NeededItem_Wnd.NeededItem_Item2_ItemWnd" );
	NeededItem_Item1Title_text = GetTextBoxHandle( "ClanShopWnd.ClanShopItemInfoWnd.NeededItem_Wnd.NeededItem_Item1Title_text" );
	NeededItem_Item1Num_text = GetTextBoxHandle( "ClanShopWnd.ClanShopItemInfoWnd.NeededItem_Wnd.NeededItem_Item1Num_text" );
	NeededItem_Item1MyNum_text = GetTextBoxHandle( "ClanShopWnd.ClanShopItemInfoWnd.NeededItem_Wnd.NeededItem_Item1MyNum_text" );
	NeededItem_Item2Title_text = GetTextBoxHandle( "ClanShopWnd.ClanShopItemInfoWnd.NeededItem_Wnd.NeededItem_Item2Title_text" );
	NeededItem_Item2Num_text = GetTextBoxHandle( "ClanShopWnd.ClanShopItemInfoWnd.NeededItem_Wnd.NeededItem_Item2Num_text" );
	NeededItem_Item2MyNum_text = GetTextBoxHandle( "ClanShopWnd.ClanShopItemInfoWnd.NeededItem_Wnd.NeededItem_Item2MyNum_text" );
	ItemCount_EditBox = GetEditBoxHandle( "ClanShopWnd.ClanShopItemInfoWnd.ItemCount_EditBox" );
	ItemInfoBg_Texture = GetTextureHandle( "ClanShopWnd.ClanShopItemInfoWnd.ItemInfoBg_Texture" );
	NeededItemBg_Texture = GetTextureHandle( "ClanShopWnd.ClanShopItemInfoWnd.NeededItemBg_Texture" );
	ExchangeItemBg_Texture = GetTextureHandle( "ClanShopWnd.ClanShopItemInfoWnd.ExchangeItemBg_Texture" );
	ExchangeItemBg_Divider1 = GetTextureHandle( "ClanShopWnd.ClanShopItemInfoWnd.ExchangeItemBg_Divider1" );
	ExchangeItemBg_Divider2 = GetTextureHandle( "ClanShopWnd.ClanShopItemInfoWnd.ExchangeItemBg_Divider2" );
	Clear_Button = GetButtonHandle( "ClanShopWnd.ClanShopItemInfoWnd.Clear_Button" );
	ExChange_Button = GetButtonHandle( "ClanShopWnd.ClanShopItemInfoWnd.ExChange_Button" );
	MultiSell_Up_Button = GetButtonHandle( "ClanShopWnd.ClanShopItemInfoWnd.MultiSell_Up_Button" );
	MultiSell_Down_Button = GetButtonHandle( "ClanShopWnd.ClanShopItemInfoWnd.MultiSell_Down_Button" );
	MultiSell_Input_Button = GetButtonHandle( "ClanShopWnd.ClanShopItemInfoWnd.MultiSell_Input_Button" );
	DisableWnd = GetWindowHandle( "ClanShopWnd.DisableWnd" );
	DescriptionMsgWnd = GetWindowHandle( "ClanShopWnd.DescriptionMsgWnd" );
	DescriptionMsg_Text = GetTextBoxHandle( "ClanShopWnd.DescriptionMsgWnd.DescriptionMsg_Text" );
	Refresh_Button = GetButtonHandle( "ClanShopWnd.Refresh_Button" );
	Close_Button = GetButtonHandle( "ClanShopWnd.Close_Button" );

	ClanShopConfirm_ResultWnd = GetWindowHandle( "ClanShopWnd.ClanShopConfirm_ResultWnd" );
	ItemNum_TextBox = GetTextBoxHandle( "ClanShopWnd.ClanShopConfirm_ResultWnd.ItemNum_TextBox" );



	ClanShopSuccess_ResultWnd = GetWindowHandle( "ClanShopWnd.ClanShopSuccess_ResultWnd" );
	ClanShopFails_ResultWnd = GetWindowHandle( "ClanShopWnd.ClanShopFails_ResultWnd" );

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
	ItemCount_EditBox.SetString("1");
}
function OnHide()
{
	ClearAll();
}
function OnEvent(int Event_ID, string param)
{
	local int nResult;
	Debug( "debuftest OnEvent------>>>>> " @ Event_ID);	
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
	//아이템 구매 결과 이벤트
	else if( Event_ID == EV_PledgeItemBuy )
	{
		Debug( "debuftest OnEvent " @ Event_ID  @ param);
		ParseInt( param, "nResult", nResult );
		if( nResult == 0 )
		{			
			SetSuccessWnd();				
		}
		else
		{
			SetFailWnd( nResult );
			
		}
	}
	else if( Event_ID == EV_DialogOK )
	{
		HandleDialogOK(true);
	}
	else if( Event_ID == EV_DialogCancel )
	{
		HandleDialogOK(false);
	}
}

function SetSuccessWnd()
{
	local ItemWindowHandle Result_ItemWnd;
	local TextBoxHandle	ItemName_TextBox, Discription_TextBox;

	Result_ItemWnd = GetItemWindowHandle( "ClanShopWnd.ClanShopSuccess_ResultWnd.Result_ItemWnd" );
	ItemName_TextBox = GetTextBoxHandle( "ClanShopWnd.ClanShopSuccess_ResultWnd.ItemName_TextBox" );
	Discription_TextBox = GetTextBoxHandle( "ClanShopWnd.ClanShopSuccess_ResultWnd.Discription_TextBox" );

	Result_ItemWnd.Clear();
	Result_ItemWnd.AddItem( SelectItemInfo );
	ItemName_TextBox.SetText( GetItemNameAll ( SelectItemInfo ) );
	Discription_TextBox.SetText( GetSystemMessage( 4570 ) );

	ClanShopSuccess_ResultWnd.ShowWindow();
}

function SetFailWnd( int n )
{
	local TextBoxHandle Discription_TextBox;

	Discription_TextBox = GetTextBoxHandle( "ClanShopWnd.ClanShopFails_ResultWnd.Discription_TextBox" );

	if( n == 2 )
	{
		//해당 권한이 없습니다.
		Discription_TextBox.SetText( GetSystemMessage( 3721 ) );
	}
	else if( n == -2  || n == 3 )
	{
		//구입 비용이 부족합니다.
		Discription_TextBox.SetText( GetSystemMessage( 4692 ) );
	}
	else if(  n == 4 )
	{
		//재고가 부족합니다
		Discription_TextBox.SetText( GetSystemMessage( 1285 ) );
	}
	else	
	//if( n == 1 || n == -1 || n == -3 )
	{
		//시스템 오류로 진행할 수 없습니다. 잠시 후 다시 시도해 주세요.
		Discription_TextBox.SetText( GetSystemMessage( 4559 ) );
	}
	ClanShopFails_ResultWnd.ShowWindow();
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
	ItemCount_EditBox.showWindow();
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

//아이템 인덱스 찾기
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
		//
		Record.LVDataList[0].attrColor = util.DRed;
		//활성화 필요
		Record.LVDataList[0].attrStat[0] = GetSystemMessage( 4564 );
	}
	else
	{
		//밝은 흰색(아이템 이름)
		Record.LVDataList[0].TextColor = util.BWhite;
		//활성화
		Record.LVDataList[0].attrColor = util.DRed;
		if( RemainActivateTime <= 0 )
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


/**  
 *   리스트 클릭
 **/
function OnClickListCtrlRecord( string ListCtrlID )
{
	local string param;
	local string ActivatePledgeLevel;
	local itemInfo Info;
	
	local int SellNameValue, ActivateNameValue, ActivateMasteryID;	

	local UserInfo infoPlayer;
	local int64 ActivatePrice, SellPrice;

	local int Status;

	GetPlayerInfo(infoPlayer);
		
	param = getParam();
	Debug(param);
	ParamToItemInfo( param, info );
	SelectItemInfo = info;
	
	ParseInt(param, "SellNameValue", SellNameValue);
	ParseInt(param, "ActivateMasteryID", ActivateMasteryID);
	ParseInt(param, "ActivateNameValue", ActivateNameValue );
	ParseInt64( param, "ActivatePrice", ActivatePrice );
	ParseInt64( param, "SellPrice", SellPrice );
	ParseInt(param, "Status", Status );
	ParseString( param, "ActivatePledgeLevel", ActivatePledgeLevel );

	class'UIAPI_MULTISELLITEMINFO'.static.Clear("ClanShopWnd.multiSellItemInfo");
	if( param != "" )
	{
		class'UIAPI_MULTISELLITEMINFO'.static.SetItemInfo( "ClanShopWnd.multiSellItemInfo", 0, info );
	}
	
	//구매 개인 명성치
	NeededItem_Item1Num_text.SetText( "x" @ MakeCostString( string(SellNameValue) ) );
	//가지고 있는 개인 명성치
	NeededItem_Item1MyNum_text.SetTextColor( util.BLUE01 );
	NeededItem_Item1MyNum_text.SetText( "(" $ MakeCostString( string(infoPlayer.PvPPoint) ) $ ")" );

	//구매 아데나
	NeededItem_Item2Num_text.SetText( "x" @ MakeCostString( string(SellPrice) ) );
	//내가 가진 아데나
	NeededItem_Item2MyNum_text.SetTextColor( util.BLUE01 );
	NeededItem_Item2MyNum_text.SetText( "(" $ MakeCostString( GetAdenaStr() ) $ ")" );	
	
	setEditStateItemCount();
	itemCountTextEditEnable( IsStackableItem( info.ConsumeType ) );	

	updateListData();
}


function updateListData()
{
	local CustomTooltip T;
	local string param;
	local int Status;
	local int SellNameValue;	
	local int64 SellPrice;
	local UserInfo infoPlayer;
	local bool bLine;

	bLine = false;

	GetPlayerInfo(infoPlayer);

	param = getParam();
	ParseInt(param, "SellNameValue", SellNameValue);
	ParseInt64( param, "SellPrice", SellPrice );
	ParseInt(param, "Status", Status );

	util.setCustomTooltip(T);//bluesun 커스터마이즈 툴팁	
	util.ToopTipMinWidth(10);

	if( Status == 2 )
	{
		ExChange_Button.EnableWindow();
	}
	else if( Status == 1 )
	{
		util.ToopTipInsertText( GetSystemString(3753), true, false, util.ETooltipTextType.COLOR_YELLOW03 );
		bLine = true;
		ExChange_Button.disableWindow();
		itemCountTextEditEnable( false );
	}
	else if( Status == 0 )
	{
		util.ToopTipInsertText( GetSystemString(3754), true, false, util.ETooltipTextType.COLOR_YELLOW03 );
		bLine = true;
		ExChange_Button.disableWindow();
		itemCountTextEditEnable( false );
	}

	if( SellNameValue * int( ItemCount_EditBox.GetString() ) > infoPlayer.PvPPoint )
	{		
		NeededItem_Item1MyNum_text.SetTextColor( util.DRed );
		if( bLine )
		{
			util.TooltipInsertItemBlank(2);	
			util.TooltipInsertItemLine();
			util.TooltipInsertItemBlank(4);
			bLine = false;
		}
		util.ToopTipInsertText( GetSystemString(3672) $ " ", true, true, util.ETooltipTextType.COLOR_GRAY );
		util.ToopTipInsertText( MakeCostString( String( (SellNameValue * int( ItemCount_EditBox.GetString() ) ) - infoPlayer.PvPPoint ) ) @ GetSystemString(3752), true, false, util.ETooltipTextType.COLOR_RED );
	}
	else
	{
		NeededItem_Item1MyNum_text.SetTextColor( util.BLUE01 );
	}

	if( (SellPrice * int( ItemCount_EditBox.GetString() ) ) > GetAdena() )
	{
		NeededItem_Item2MyNum_text.SetTextColor( util.DRed );
		if( bLine )
		{
			util.TooltipInsertItemBlank(2);	
			util.TooltipInsertItemLine();
			util.TooltipInsertItemBlank(4);
			bLine = false;
		}
		util.ToopTipInsertText( GetSystemString(469) $ " ", true, true, util.ETooltipTextType.COLOR_GRAY );
		util.ToopTipInsertText( MakeCostString( String( ( SellPrice * int( ItemCount_EditBox.GetString() ) ) - GetAdena() ) ) @ GetSystemString(3752), true, false, util.ETooltipTextType.COLOR_RED );
	}
	else
	{
		NeededItem_Item2MyNum_text.SetTextColor( util.BLUE01 );
	}
	ExChange_Button.SetTooltipCustomType(util.getCustomTooltip());
}

// 수량 입력 에디터 , 활성 비활성
function itemCountTextEditEnable(bool bEnable)
{
	if (bEnable)
	{
		ItemCount_EditBox.EnableWindow();

		MultiSell_Up_Button.EnableWindow();
		MultiSell_Down_Button.EnableWindow();
		MultiSell_Input_Button.EnableWindow();
		Clear_Button.EnableWindow();
	}
	else
	{
		ItemCount_EditBox.DisableWindow();

		MultiSell_Up_Button.DisableWindow();
		MultiSell_Down_Button.DisableWindow();
		MultiSell_Input_Button.DisableWindow();
		Clear_Button.DisableWindow();
	}
}

// 아이템 
function setEditStateItemCount()
{
	ItemCount_EditBox.SetString("1");	
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
		//혈맹 상점 관리창 열기
		case "ClanShopEdit_Button":
			OnClanShopEdit_ButtonClick();   
			break;
		//계산기 클릭 시
		case "MultiSell_Input_Button":
			OnPriceEditBtnHandler();
			break;	
		//UP 클릭 시
		case "MultiSell_Up_Button":
			OnMultiSell_Up_ButtonClick();
			break;
		//UP 클릭 시
		case "MultiSell_Down_Button":
			OnMultiSell_Down_ButtonClick();
			break;

		case "Clear_Button":
			ItemCount_EditBox.SetString("1");
			updateCost();
			break;
	}
}

//구매 버튼 클릭
function OnExChange_ButtonClick()
{
	DisableWnd.ShowWindow();
	DisableWnd.SetFocus();

	ClanShopConfirm_ResultWnd.ShowWindow();
	setResultWnd();
	ItemCount_EditBox.HideWindow();
}

function setResultWnd()
{
	local String param, fullNameString;
	local ItemInfo info;
	local ItemWindowHandle Result_ItemWnd;
	local TextBoxHandle	ItemName_TextBox, FameNum_TextBox, AdenaNum_TextBox, Discription_TextBox, FameTitle_TextBox;
	local int SellNameValue;	
	local int64  SellPrice;

	param = getParam();
	ParamToItemInfo( param, info );
	ParseInt(param, "SellNameValue", SellNameValue );
	ParseInt64( param, "SellPrice", SellPrice );

	fullNameString = GetItemNameAll ( info );

	Result_ItemWnd = GetItemWindowHandle( "ClanShopWnd.ClanShopConfirm_ResultWnd.Result_ItemWnd" );
	ItemName_TextBox = GetTextBoxHandle( "ClanShopWnd.ClanShopConfirm_ResultWnd.ItemName_TextBox" );
	FameNum_TextBox = GetTextBoxHandle( "ClanShopWnd.ClanShopConfirm_ResultWnd.FameNum_TextBox" );
	AdenaNum_TextBox = GetTextBoxHandle( "ClanShopWnd.ClanShopConfirm_ResultWnd.AdenaNum_TextBox" );
	Discription_TextBox = GetTextBoxHandle( "ClanShopWnd.ClanShopConfirm_ResultWnd.Discription_TextBox" );
	FameTitle_TextBox = GetTextBoxHandle( "ClanShopWnd.ClanShopConfirm_ResultWnd.FameTitle_TextBox" );

	Result_ItemWnd.Clear();
	Result_ItemWnd.AddItem( info );
	ItemName_TextBox.SetText( fullNameString );
	FameNum_TextBox.SetText( MakeCostString( string( SellNameValue * int( ItemCount_EditBox.GetString() ) ) ) );
	AdenaNum_TextBox.SetText( MakeCostString( string( SellPrice * int( ItemCount_EditBox.GetString() ) ) ) );
	FameTitle_TextBox.SetText( GetSystemString( 3672 ) );
	Discription_TextBox.SetText( GetSystemMessage( 4569 ) );
	ItemNum_TextBox.SetText( "x" $ ItemCount_EditBox.GetString() );
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

	//구매하자
	Debug( "구매하자---->" @ ItemCount_EditBox.GetString() );	
	RequestPledgeItemBuy( info.Id.ClassID, int( ItemCount_EditBox.GetString() ) );
	ClanShopConfirm_ResultWnd.hideWindow();
}

function OnCancel_ButtonClick()
{
	DisableWnd.hideWindow();
	ItemCount_EditBox.showWindow();
	ClanShopConfirm_ResultWnd.hideWindow();	

}
function OnSuccess_ButtonClick()
{
	DisableWnd.hideWindow();
	ClanShopSuccess_ResultWnd.hideWindow();
	ItemCount_EditBox.showWindow();
	RequestPledgeItemList();
}

function OnFail_ButtonClick()
{
	DisableWnd.hideWindow();
	ClanShopFails_ResultWnd.hideWindow();
	ItemCount_EditBox.showWindow();
	RequestPledgeItemList();
}

function OnClanShopEdit_ButtonClick()
{
	//GetWindowHandle( getCurrentWindowName(string(Self))).HideWindow();
	ShowWindow("ClanShopEditWnd");
	GetWindowHandle("ClanShopEditWnd").SetFocus();
	
}

function OnMultiSell_Up_ButtonClick()
{
	local string numStr;
	local int count;

	numStr = ItemCount_EditBox.GetString();
	count = int(numStr);

	if (checkEnableExchange(count + 1))
	{
		// 추가 가능여부 체크해야함		
		count++;
		ItemCount_EditBox.SetString(String(count));
		updateCost();
	}
}

function OnMultiSell_Down_ButtonClick()
{
	local string numStr;
	local int count;

	numStr = ItemCount_EditBox.GetString();
	count = int(numStr);

	if (count > 1)
	{
		count--;
		ItemCount_EditBox.SetString(String(count));
		updateCost();
	}	
}

// 교환 가능한 수량 인가? 
function bool checkEnableExchange(int tryExchangeCount)
{
	local bool bHasItem;
	/*
	local int i, index;
	local bool bHasItem;

	local ItemInfo rItemInfo, info;

	getCurrentSelectedItemInfo(rItemInfo);

	index = rItemInfo.Reserved;

	// 특정 아이템을 선택되지 않았다.
	if (index <= -1) return false;

	bHasItem = true;

	if( index >= 0 && index < m_MultiSellInfoList.Length )
	{
		for( i=0 ; i < m_MultiSellInfoList[index].InputItemInfoList.Length ; i++ )
		{
			info = m_MultiSellInfoList[index].InputItemInfoList[i];
			
			if (info.ItemNum * tryExchangeCount > getHasItemOrPointCount(m_MultiSellInfoList[index].InputItemInfoList[i]))
			{
				bHasItem = false;
			}
		}
	}*/
	bHasItem = true;
	return bHasItem;
}


/** 개당 판매 가격 입력 계산기 */
function OnPriceEditBtnHandler()
{
	local ItemInfo info;
	
	DisableWnd.ShowWindow();
	DisableWnd.SetFocus();
	// Ask price
	DialogSetID( DIALOG_ASK_PRICE );
	
	DialogSetEditBoxMaxLength(6);
	DialogSetCancelD(DIALOG_ASK_PRICE);
	DialogSetReservedItemID( info.ID );				// ServerID
	//DialogSetReservedInt3( int(bAllItem) );		// 전체이동이면 개수 묻는 단계를 생략한다
	DialogSetEditType("number");
	DialogSetParamInt64( -1 );
	DialogSetDefaultOK();
	// 구매개수를 입력해주세요.
	DialogShow(DialogModalType_Modalless, DialogType_NumberPad, GetSystemMessage(4362), string(Self) );
}

//-----------------------------------------------------------------------------------------------------------
// HandleDialogOK
//-----------------------------------------------------------------------------------------------------------
function HandleDialogOK(bool bOK)
{
	local int id;
	local INT64 inputNum;
		
	if( DialogIsMine() )
	{
		DisableWnd.HideWindow();
		
		id = DialogGetID();
		// ok를 눌렀을때 
		if (bOK)
		{
			if (id == DIALOG_ASK_PRICE)
			{
				inputNum = INT64( DialogGetString() );
				// 0은 입력 못하도록..
				if (inputNum <= 0) inputNum = 1;
				ItemCount_EditBox.SetString(String(inputNum));
				updateCost();
			}
		}
		else
		{
			DisableWnd.HideWindow();
		}
	}
}

//-----------------------------------------------------------------------------------------------------------
// OnKeyUp
//-----------------------------------------------------------------------------------------------------------
function OnKeyUp( WindowHandle a_WindowHandle, EInputKey nKey )
{
    if (ItemCount_EditBox.IsFocused())
	{	
		if (ItemCount_EditBox.GetString() == "0") 
		{
			ItemCount_EditBox.SetString("1");
		}
		updateCost();
	}
}

/**
 * 선택된 List 값의 Record 리턴
 **/
function LVDataRecord getSelectRecord()
{
	local LVDataRecord Record;	
	ClanShop_ListCtrl.GetSelectedRec(Record);
	return Record;
}
/**
 *  선택된 List 값의 Param 리턴
 **/
function String getParam()
{
	local LVDataRecord Record;
	local string param;
	Record = getSelectRecord();			
	param = Record.szReserved;
	return param;
}

/**
 * 구입 비용 계산
 **/
function updateCost()
{
	local string param;
	local int SellNameValue;
	local int64  SellPrice;

	param = getParam();

	ParseInt(param, "SellNameValue", SellNameValue);
	ParseInt64(param, "SellPrice", SellPrice );

	//구매 개인 명성치
	NeededItem_Item1Num_text.SetText( "x" @ MakeCostString( string(SellNameValue * int( ItemCount_EditBox.GetString() ) ) ) );

	//구매 아데나
	NeededItem_Item2Num_text.SetText( "x" @ MakeCostString( string(SellPrice * int( ItemCount_EditBox.GetString() ) ) ) );

	updateListData();
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
