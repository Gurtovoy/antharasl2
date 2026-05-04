/**
*미니맵(지도) 컨트롤에 대한 함수입니다
*/
class MinimapCtrlHandle extends WIndowHandle
	native;

/**
* 맵의 관찰자의 위치를 바꾼다

* @param
* Loc : 관찰자의 위치(벡터)
* a_ZoomToTownMap(optional) : 마을지도로 줌한다.
* a_UserGridLocation(optional) : GridLocation을 사용한다??

* @return
* void

* @example
* var  MinimapCtrlHandle t_handle;
* var vector Location;
* Location.x = -86916;
* Location.y = 222183;
* Location.z = -4656;
* t_handle = GetMinimapCtrlHandle( "MinimapWnd.Minimap" ); //핸들을 가져온다
* t_handle.AdjustMapView(Location); // (-86916, 222183, -4656) 위치의 월드맵을 본다
*/
native final function AdjustMapView( vector Loc, optional bool a_ZoomToTownMap, optional bool a_UseGridLocation );
//native final function InitPosition();

/**
* 맵위에 타겟을 추가한다.(깃발이 꼽혀서 표시된다)

* @param
* Loc : 타겟의 위치(벡터)

* @return
* void

* @example
* var  MinimapCtrlHandle t_handle;
* var vector Location;
* Location.x = -86916;
* Location.y = 222183;
* Location.z = -4656;
* t_handle = GetMinimapCtrlHandle( "MinimapWnd.Minimap" ); //핸들을 가져온다
* t_handle.AddTarget(Location); // (-86916, 222183, -4656) 위치에 타겟을 추가한다
*/
native final function AddTarget( vector a_Loc );

/**
* 맵위의 타겟을 제거한다.

* @param
* Loc : 타겟의 위치(벡터)

* @return
* void

* @example
* var  MinimapCtrlHandle t_handle;
* var vector Location;
* Location.x = -86916;
* Location.y = 222183;
* Location.z = -4656;
* t_handle = GetMinimapCtrlHandle( "MinimapWnd.Minimap" ); //핸들을 가져온다
* t_handle.AddTarget(Location); // (-86916, 222183, -4656) 위치에 타겟을 추가한다
* t_handle.DeleteTarget(Location); // 방금추가한 타겟을 지운다
*/
native final function DeleteTarget(  vector a_Loc );

/**
* 맵위의 모든 타겟을 제거한다.

* @param
* void

* @return
* void

* @example
* var  MinimapCtrlHandle t_handle;
* var vector Location;
* Location.x = -86916;
* Location.y = 222183;
* Location.z = -4656;
* t_handle = GetMinimapCtrlHandle( "MinimapWnd.Minimap" ); //핸들을 가져온다
* t_handle.AddTarget(Location); // (-86916, 222183, -4656) 위치에 타겟을 추가한다
* t_handle.DeleteAllTarget(); // 맵상의 모든 타겟을 (방금 추가한 것을 포함하여) 지운다
*/
native final function DeleteAllTarget();

/**
* 맵상에 퀘스트 표시를 보여줄지 여부를 설정한데

* @param
* a_ShowQuest : true 면 보여줌, false면 안보여줌

* @return
* void

* @example
* var  MinimapCtrlHandle t_handle;
* var vector Location;
* Location.x = -86916;
* Location.y = 222183;
* Location.z = -4656;
* t_handle = GetMinimapCtrlHandle( "MinimapWnd.Minimap" ); //핸들을 가져온다
* t_handle.SetShowQuest(true); //퀘스트 표시를 보여준다
*/
native final function SetShowQuest( bool a_ShowQuest );

/**
* 세븐사인퀘스트를 진행하고 있도록 셋팅한다 

* @param
* a_SSQStatus :  

* @return
* void

* @example
* var  MinimapCtrlHandle t_handle;
* t_handle = GetMinimapCtrlHandle( "MinimapWnd.Minimap" ); //핸들을 가져온다
* t_handle.SetSSQStatus(0); // 셋팅한다(숫자의 의미는?)
*/
native final function SetSSQStatus( int a_SSQStatus );
native final function DrawGridIcon( string a_IconName, string a_DupIconName, vector a_Loc, bool a_Refresh, optional int a_XOffset, optional int a_YOffset, optional string TooltipString );
native final function RequestReduceBtn();
native final function bool IsOverlapped( int FirstX, int FirstY, int SecondX, int SecondY);
native final function DeleteAllCursedWeaponIcon();
native final function AddRegionInfo( string RegionInfo );
native final function UpdateRegionInfo( int idx, string RegionInfo );
native final function EraseAllRegionInfo();
native final function EraseRegionInfo(int index);
native final function SetContinent(int Continent);
native final function int GetContinent(vector worldLoc);	// 월드맵 개선(#3602) - moonhj

//JYLee, 2011. 11. 23.
//그레시아 지역 인던의 exception data 처리 수정을 위한 함수
native final function int GetPlayerContinent();
native final function RegisterQuestIcon(int questID, int worldX, int worldY, int worldZ, string typeName);
native final function EraseQuestIcon(int questID);

native static function SetDrawTeleportPath(bool bDraw);

native static function SetDirIconDest(EMinimapTargetIcon index, vector DestLoc, string tooltip);
native static function DisableDirIcon(EMinimapTargetIcon index);

// 월드맵 개선(#3328) - moonhj
native final function AddRegionInfoCtrl(MinimapRegionInfo regionInfo);
native final function UpdateRegionInfoCtrl(MinimapRegionInfo regionInfo);
native final function EraseRegionInfoCtrl(EMinimapRegionType eType, int nIndex);
native final function EraseRegionInfoByType(EMinimapRegionType eType);
native final function SetShowRegionInfoByType(EMinimapRegionType eType, bool bShow);
defaultproperties
{
}
