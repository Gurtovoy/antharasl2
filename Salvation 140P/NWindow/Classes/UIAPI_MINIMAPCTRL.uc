class UIAPI_MINIMAPCTRL extends UIAPI_WINDOW
	native;

native static function AdjustMapView( string a_ControlID, vector Loc, optional bool a_ZoomToTownMap, optional bool a_UseGridLocation );
//native static function InitPosition( string a_ControlID );
native static function AddTarget( string a_ControlID, vector a_Loc );
native static function DeleteTarget( string a_ControlID, vector a_Loc );
native static function DeleteAllTarget( string a_ControlID );
native static function SetShowQuest( string a_ControlID, bool a_ShowQuest );

//branch EP3.0 2016.7.20 luciper3 - 데일리미션 개편
native static function SetDailyQuest(string a_ControlID,bool a_ShowRange,int a_DailyQuestIndex);
//end of branch

//native static function bool GetQuestLocation( string a_ControlID, out Vector a_QuestLocation );		uiscript.uc로 옮김 - lancelot 2006. 11. 14
native static function SetSSQStatus( string a_ControlID, int a_SSQStatus );
native static function DrawGridIcon( string a_ControlID, string a_IconName, string a_DupIconName, vector a_Loc, bool a_Refresh, optional int a_XOffset, optional int a_YOffset, optional string TooltipString );
native static function RequestReduceBtn( string a_ControlID );
native static function bool IsOverlapped( string a_ControlID, int FirstX, int FirstY, int SecondX, int SecondY);
native static function DeleteAllCursedWeaponIcon(string a_ControlID);
native static function ShowCertainLayer( string a_ControlID, int LayerNumber );
native static function ResetMinimapData( string a_ControlID );
defaultproperties
{
}
