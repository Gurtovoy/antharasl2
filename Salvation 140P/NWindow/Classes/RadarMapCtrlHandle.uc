/**
*레이더맵컨트롤에 관한 함수를 정의
*/
class RadarMapCtrlHandle extends WindowHandle
	native;
/**
* 레이더에 표시되는 객체를 추가한다. 레이더 컨트롤은 내부에 Tarray로 된 객체(NCRadarObjectCtrl) 리스트를 유지하는데
* 여기에 레이더에 표시될 객체의 배열을 유지한다. 

* @param
* ID : 객체의 ID 
* Type : 객체의 type (현재 "PartyMember", "Monster", "Target", "Quest", "Clan" 이 있다)
* Name : 객체의 이름(레이더 맵에 툴팁으로 표시된다)
* locX : 객체의 월드 x좌표. 객체의 위치는 물론 서버에 존재한다. GetTargetInfo(UIScript.uc 참조) 와 같이 미리 구현된 API를 사용하거나 필요여하에 따라 새로운 API를 작성하도록 하자.
* locY : 객체의 월드 y좌표
* locZ : 객체의 월드 z좌표
*
* @return
* void

* @example
* var RadarMapCtrlHandle r_handle;
* r_handle = GetRadarMapCtrlHandle("RadarMapWnd.RadarMapCtrl"); //핸들을 가져온다
* r_handle.AddObject(100,"PartyMember", "Sohee", -93365, 238772, -3510); //(-93365,238772,-3510)의 WC에 우리 소희를 파티멤버로 표시하도록 추가한다
*/
native final function AddObject( int ID, string Type, string Name, int locX, int locY, int locZ );

/**
* 레이더에 표시되는 객체를 삭제한다.

* @param
* ID : 삭제될 객체의 ID

* @return
* void

* @example
* var RadarMapCtrlHandle r_handle;
* r_handle = GetRadarMapCtrlHandle("RadarMapWnd.RadarMapCtrl"); //핸들을 가져온다
* r_handle.AddObject(100,"PartyMember", "Sohee", -93365, 238772, -3510); //(-93365,238772,-3510)의 WC에 우리 소희를 파티멤버로 표시하도록 추가한다
* r_handle.DeleteObject(100); //슬프지만 우리 소희를 삭제하였다
*/
native final function DeleteObject( int ObjectID );

/**
* 레이더에 표시되는 객체의 위치를 변경한다.

* @param
* ID : 변경할 객체의 ID
* locX : 객체의 월드 x좌표. 객체의 위치는 물론 서버에 존재한다. GetTargetInfo(UIScript.uc 참조) 와 같이 미리 구현된 API를 사용하거나 필요여하에 따라 새로운 API를 작성하도록 하자.
* locY : 객체의 월드 y좌표
* locZ : 객체의 월드 z좌표

* @return
* void

* @example
* var RadarMapCtrlHandle r_handle;
* r_handle = GetRadarMapCtrlHandle("RadarMapWnd.RadarMapCtrl"); //핸들을 가져온다
* r_handle.AddObject(100,"PartyMember", "Sohee", -93365, 238772, -3510); //(-93365,238772,-3510)의 WC에 우리 소희를 파티멤버로 표시하도록 추가한다
* r_handle.DeleteObject(100, -100000, 238772, -3510); //객체의 위치를 변경한다
*/
native final function UpdateObject(int ID, int WorldX, int WorldY, int WorldZ);

/**
* 자신 주변의 정보를 요청한다. CPP단에서는 객체주변의 정보를 얻어와 그 갯수만큼 EV_NotifyObject를 발생시키며 동시에 parameter로 type, ID, name, x, y, z정보를 넘겨준다.
* 따라서 이함수는 정보를 요청할뿐 레이더에 표시하지는 않는다.
* 따라서 레이더에 표시를 원한다면 EV_NotifyObject에 대한 핸들러를 등록하여 Addobject등을 사용하여 처리해주자

* @param
* ObjectType : 요청할 객체의 타입(OBJ_TYPE_MONSTER : 몬스터정보만 얻어온다
* 몬스터정보 : 1
* 파티멤버정보 : 2
* 클랜원정보 : 3
* 얼라이언스정보 : 4
* 아이템정보 : 5
* 아데나정보 : 6 

* DistanceLimitXY : 좌우범위
* DistanceLimitZ : 상하범위

* @return
* void

* @example
* var RadarMapCtrlHandle r_handle;
* r_handle = GetRadarMapCtrlHandle("RadarMapWnd.RadarMapCtrl"); //핸들을 가져온다
* r_handle.RequestObjectAround(OBJ_TYPE_MONSTER, 100,100); //상하좌우 100범위 안의 몬스터정보를 요청한다.
* //RadarMapWnd.uc 에는 EV_NotifyObject에 대한 핸들러가 존재하여 이를 레이더에 표시해준다
*/
native final function RequestObjectAround(int ObjectType, int DistanceLimitXY, int DistanceLimitZ);

/**
* 축적을 변경한다.

* @param
* newMag : 변경할 축적

* @return
* void

* @example
* var RadarMapCtrlHandle r_handle;
* r_handle = GetRadarMapCtrlHandle("RadarMapWnd.RadarMapCtrl"); //핸들을 가져온다
* r_handle.SetMagnification(1); // 축적을 100으로 변경
*/
native final function SetMagnification(float newMag);

/**
* Rotation 여부를 결정한다

* @param
* bEnable : true면 허용, false 면 불가

* @return
* void

* @example
* var RadarMapCtrlHandle r_handle;
* r_handle = GetRadarMapCtrlHandle("RadarMapWnd.RadarMapCtrl"); //핸들을 가져온다
* r_handle.SetEnableRotation(false); // 돌지않게 한다.
*/
native final function SetEnableRotation(bool bEnable);

/**
* 컨트롤이 보일지 여부를 결정한다.

* @param
* bEnable : true면 허용, false 면 불가

* @return
* void

* @example
* var RadarMapCtrlHandle r_handle;
* r_handle = GetRadarMapCtrlHandle("RadarMapWnd.RadarMapCtrl"); //핸들을 가져온다
* r_handle.SetMapInvisible(true); // 보이지않게 한다.
*/
native final function SetMapInvisible(bool bInvisible);

native final function SwitchSingleMeshMode(bool bUse);
defaultproperties
{
}
