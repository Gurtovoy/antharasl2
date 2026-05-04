class HtmlHandle extends WindowHandle
	native;

native final function LoadHtml( string FileName );
native final function LoadHtmlFromString( string HtmlString );
native final function Clear();
native final function int GetFrameMaxHeight();
native final function EControlReturnType ControllerExecution( string strBypass );

//BBSÀü¿ë
native final function SetHtmlBuffData( string strData);
native final function SetPageLock( bool bLock);
native final function bool IsPageLock();
defaultproperties
{
}
