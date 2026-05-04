class BeautyShop extends GFxUIScript;
var int currentScreenWidth, currentScreenHeight;

const FLASH_XPOS = 0;
const FLASH_YPOS = 0;

function OnRegisterEvent()
{
	registerGfxEvent(EV_OpenBeautyshopWindow);
	registerGfxEvent(EV_ReceiveBeautyItemList);
	registerGfxEvent(EV_SendUserAdenaAndCoin);
	registerGfxEvent(EV_CurrentUserStyle);
	registerGfxEvent(EV_IsSuccessBuyingStyle);
	registerGfxEvent(EV_OpenBeautyshopResetWindow);
	registerGfxEvent(EV_EndSocialAction);
	registerGfxEvent(EV_OldUserStyle);
	registerGfxEvent(EV_ExitBeautyshop);
	RegisterGFxEventForLoaded(EV_ResolutionChanged);
	registerGfxEvent(EV_PurchaseItemList);  //뷰티샵 구매했던 아이템 리스트 추가 이벤트
	//registerEvent(EV_OpenBeautyshopResetWindow);
	//registerEvent(EV_OpenBeautyshopWindow);
}

function OnLoad()
{
	registerState( "BeautyShop", "BeautyShopState" );
	SetAnchor("", EAnchorPointType.ANCHORPOINT_TopLeft, EAnchorPointType.ANCHORPOINT_TopLeft, 0, 0);
}

function OnFlashLoaded()
{
	RegisterDelegateHandler(EDHandler_BeautyshopWnd);
}
defaultproperties
{
}
