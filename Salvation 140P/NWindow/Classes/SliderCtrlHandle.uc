class SliderCtrlHandle extends WindowHandle
	native;

native final function int GetCurrentTick();
native final function SetCurrentTick(int iCurrTick);
native final function int GetTotalTickCount();
native final function SetTotalTickCount(int a_TotalTickCount);
native final function bool IsMouseScrolling();
defaultproperties
{
}
