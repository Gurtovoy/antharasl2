class FlashCtrlHandle extends WindowHandle
	native;

native final function Play();
native final function Pause();
native final function Stop();
native final function int GetTotalFrameCnt();
native final function int GetCurrentFrame();
native final function GotoFrame(int a_FrameNumber);
native final function bool SetFlashFile(string a_FlashFile);
native final function bool Invoke(string a_Command, ParamMap a_Param);
defaultproperties
{
}
