class ChatAlertMessage extends GFxUIScript;

//플래쉬 옵셋 좌표
const FLASH_XPOS = 0;
const FLASH_YPOS = -137;

function OnRegisterEvent()
{
	RegisterGFxEvent( EV_ChatMessage );
}

function OnLoad()
{
	registerState( "ChatAlertMessage", "GamingState" );
	//SetFixedPositionRate( 0.5f, 0.59f );
	//위치 잡기
	//SetAnchor( "", EAnchorPointType.ANCHORPOINT_TopCenter, EAnchorPointType.ANCHORPOINT_TopCenter, FLASH_XPOS, FLASH_YPOS );
	SetAnchor( "", EAnchorPointType.ANCHORPOINT_BottomRight, EAnchorPointType.ANCHORPOINT_BottomRight, FLASH_XPOS, FLASH_YPOS );
	//반투명 없음
	SetAlwaysFullAlpha( true );
	//포커스 잡지 않음
	SetHavingFocus( false );
	//클릭 되지 않음.
	SetMsgPassThrough( true );	
}
defaultproperties
{
}
