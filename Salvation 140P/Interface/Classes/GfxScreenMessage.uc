//------------------------------------------------------------------------------------------------------------------------
//
// 제목        : gfxDialog  ( 스케일 폼용 다이얼로그 (커스텀 등) ) - SCALEFORM UI - 
//
// linkage 다이얼로그 목록 :
// 4차 전직 - 각성 게시 다이얼로그 : Gfx 스크린 메시지   
//------------------------------------------------------------------------------------------------------------------------
class GfxScreenMessage extends L2UIGFxScript;

function OnRegisterEvent()
{
	RegisterGFxEvent( EV_GFxScrMessage );
	//RegisterEvent( EV_GFxScrMessage );
}
	
function OnLoad()
{	
	registerState( getCurrentWindowName(String(self)), "GAMINGSTATE" );	
	registerState( getCurrentWindowName(String(self)), "ARENAPICKSTATE" );	
	registerState( getCurrentWindowName(String(self)), "ARENAGAMINGSTATE" );	
	registerState( getCurrentWindowName(String(self)), "ARENABATTLESTATE" );		
	//항상 위에
	//SetAlwaysOnTop(true);
	//항상 보임
	SetDefaultShow ( true ) ;	
	//반투명 없음
	//SetAlwaysFullAlpha( true );
	//포커스 잡지 않음
	SetHavingFocus( false );
	//클릭 되지 않음.
	//SetMsgPassThrough( true );	
	
	
}

function OnFlashLoaded()
{		
	SetAnchor("", EAnchorPointType.ANCHORPOINT_BottomRight, EAnchorPointType.ANCHORPOINT_TopLeft, 0 , 0);	

	//항상 상위에 그리도록 함.
	SetRenderOnTop(true);
	SetAlwaysFullAlpha(true);
	IgnoreUIEvent(true);
	//SetAlwaysOnTop(true);
	//Debug ("OnFlashLoaded" @ getCurrentWindowName(String(self)));
}

/*
function onEvent ( int ID, string param )
{
	local L2Util util;
	util = L2Util( GetScript( "L2Util"));
	switch ( ID ) 
	{
	case EV_GFxScrMessage :
		util.showGfxScreenMessage( "Msg는 인체에 해가 없다고 합니다." ) ;
	break;
	}
}
*/
defaultproperties
{
}
