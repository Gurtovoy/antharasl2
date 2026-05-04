class SceneEditorAPI extends Object
	native;

native static function InitSceneEditorData();
native static function PlayScene(int SkipSceneNo, int EndSceneNo, int Option, bool bShowInfo, bool bReShow);
native static function AddScene(int Index);
native static function DeleteScene(int Index);
native static function CopyScene(int SrcIndex, int DestIndex);
native static function bool IsReloadSceneData();
native static function ReloadSceneData();
native static function LoadSceneData(string FileName);
native static function bool SaveSceneData(
	string FileName, 
	string CurPath, 
	bool bForceToPlay, 
	bool bEscapable, 
	bool bShowMyPC,
	bool bShowOtherPCs, 
	float playRate,
	optional float NearClippingPlane,
	optional float FarClippingPlane
	);
native static function GetCurSceneTimeAndDesc(int Index, out int Time, out string Desc);
native static function GetCurScenePlayRate(int Index, out float PlayRate);
native static function SaveCurSceneTimeAndDesc(int Index, int Time, string Desc, float PlayRate);
native static function SetSceneInfoAttribute(
	bool bForceToPlay, 
	bool bEscapable,
	bool bShowMyPC,
	bool bShowOtherPCs, 
	float playRate, 
	float NearClippingPlane,
	float FarClippingPlane);
defaultproperties
{
}
