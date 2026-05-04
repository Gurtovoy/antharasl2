//아데나 분배 창
class AdenaDistributionWnd extends L2UIGFxScript;

var ItemWindowHandle InventoryItem;

const DIALOG_ADENADISTRIBUTTE = 200001;		// 아데나 요청

function OnRegisterEvent()
{	
	//아데나 업데이트를 받기 위한 
	RegisterGFxEvent( EV_UpdateUserInfo );
	RegisterGFxEvent( EV_Restart );
	RegisterGFxEvent( EV_AdenaInvenCount );	

	//추가된 분배 관련 함수 들
	RegisterGFxEvent( EV_DivideAdenaStart );
	RegisterGFxEvent( EV_DivideAdenaCancel );	
	RegisterGFxEvent( EV_DivideAdenaDone );

	//연합장 변경 관련 이벤트
	//아데나 변경 이벤트
	RegisterGFxEvent( EV_HandOverPartyMaster ); //4918 파티장을 양도함 
	RegisterGFxEvent( EV_CommandChannelInfo );  //1380 연합 채널을 받음 > 필요 없을 듯
	RegisterGFxEvent( EV_BecamePartyMaster );   //파티장이됨
	RegisterGFxEvent( EV_RecvPartyMaster );     //파티장을 이양받음
	RegisterGFxEvent( EV_PartyDeleteAllParty ); //모든 파티원 삭제
	RegisterGFxEvent( EV_PartyAddParty );       //파티 더해짐
	RegisterGFxEvent( EV_PartyDeleteParty );    //파티 삭제 됨

	RegisterGFxEvent( EV_CommandChannelEnd );   //채널 끝
	RegisterGFxEvent( EV_CommandChannelStart ); //채널 시작	

	//테스트 용
	//RegisterGFxEvent( 9997 );	
	//RegisterGFxEvent( 9998 );	
	//RegisterGFxEvent( 9999 );

	//RegisterEvent( 9997 );

	RegisterEvent(EV_DialogOK);          //1710
	RegisterEvent(EV_DialogCancel);      //1720
}

function OnLoad()
{	
	registerState( "AdenaDistributionWnd", "GamingState" );	
	SetContainerWindow( WINDOWTYPE_DECO_NORMAL, 0 );	
	//SetAnchor("", EAnchorPointType.ANCHORPOINT_CenterCenter, EAnchorPointType.ANCHORPOINT_CenterCenter, 0 , 0);	

	//열렸을 때 포커스가 잡히지 않도록 함( 컨테이너에 포커스가 가야 함 ! ) 
	//SetHavingFocus( false );
	
	InventoryItem = GetItemWindowHandle( "InventoryWnd.InventoryItem");	
}

function onShow()
{
	// 지정한 윈도우를 제외한 닫기 기능 
	local L2Util util;
	util = L2Util(GetScript("L2Util"));	
	util.ItemRelationWindowHide( "AdenaDistributionWnd" );	
}


function onEvent( int a_EventID, String a_Param )
{

	switch ( a_EventID )
	{	
		case EV_DialogOK:
			HandleDialogOK();
		break;

		case EV_DialogCancel:
			HandleDialogCancel();
		break;	
	//case 9997:
	//	ShowWindow();
	//	break;
	}
}

function onCallUCFunction( string functionName, string param )
{
	local int index ;
	local ItemInfo	info;
	//local ItemInfo	info;


	//Debug("onCallUCFunction"@ functionName );
	switch (functionName)
	{
	case "openDialogNumpad" :
		openDialogNumpad(int64 (param) );
	break;
	
	case "getAdenaServerID":	
	//아데나 서버 아이뒤 받기
	info.ID.classID = 57;
	index = InventoryItem.FindItem( info.ID );	
	
	if( InventoryItem.GetItem(index, info) )
		callGfxFunction("AdenaDistributionWnd", "AdenaServerID", String( info.ID.serverID ));
	break;
	case "RequestCommandChannelInfo": 
		class'CommandChannelAPI'.static.RequestCommandChannelInfo();
	break;	
	}
}

function openDialogNumpad(int64 adena)
{
	// Ask price
	class'UICommonAPI'.static.DialogSetID( DIALOG_ADENADISTRIBUTTE );
	//DialogSetReservedItemID( info.ID );				// ServerID
	//DialogSetReservedInt3( int(bAllItem) );		// 전체이동이면 개수 묻는 단계를 생략한다
	class'UICommonAPI'.static.DialogSetEditType("number");
	class'UICommonAPI'.static.DialogSetParamInt64( adena );
	class'UICommonAPI'.static.DialogSetDefaultOK();
	class'UICommonAPI'.static.DialogShow(DialogModalType_Modalless, DialogType_NumberPad, getSystemString( 3138 ), string(Self) );	
}


/** Desc : 다이얼로그 윈도우를 열고 Cancel 버튼 누른 경우 */
function HandleDialogCancel() //파티루팅변경 동의창 
{

}

/** Desc : 다이얼로그 윈도우를 열고 OK 버튼 누른 경우 */
function HandleDialogOK()
{	
	//local ItemInfo scInfo;
	local INT64 inputNum;
	local int id;

	if(!class'UICommonAPI'.static.DialogIsOwnedBy( string(Self) ))	return;	

	id = class'UICommonAPI'.static.DialogGetID();
	
	if ( id == DIALOG_ADENADISTRIBUTTE )
	{
		inputNum = INT64( class'UICommonAPI'.static.DialogGetString() );
		CallGFxFunction ( "AdenaDistributionWnd", "HandleDialogOK", String(inputNum));
	}	
} 
defaultproperties
{
}
