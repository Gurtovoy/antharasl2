/**
*텍스트리스트박스에 대한 함수를 정의한다.
*/
class CharacterViewportWindowHandle extends WindowHandle
	native;
/**
* 뷰포트에 보이는 캐릭터를 돌게한다

* @param
* bRight : true면 오른쪽으로 false면 왼쪽으로 돈다

* @return
* void

* @example
* var CharacterViewportWindowHandle c_handle;
* c_handle = GetCharacterViewportWindowHandle("InventoryWnd.ObjectViewport"); //핸들을 가져온다
* c_handle.StartRotation(true); //오른쪽으로 돈다
*/
native final function StartRotation( bool bRight );

/**
* 뷰포트에 보이는 캐릭터의 회전을 멈추게한다

* @param
* void

* @return
* void

* @example
* var CharacterViewportWindowHandle c_handle;
* c_handle = GetCharacterViewportWindowHandle("InventoryWnd.ObjectViewport"); //핸들을 가져온다
* c_handle.StartRotation(true); // 오른쪽으로 돈다
* c_handle.EndRotation(); //멈춘다
*/
native final function EndRotation();

/**
* 뷰포트에 보이는 캐릭터를 인줌/아웃줌 한다

* @param
* bOut : true면 아웃줌 false면 인줌

* @return
* void

* @example
* var CharacterViewportWindowHandle c_handle;
* c_handle = GetCharacterViewportWindowHandle("InventoryWnd.ObjectViewport"); //핸들을 가져온다
* c_handle.StartZoom(true); //아웃줌한다
*/
native final function StartZoom( bool bOut );

/**
* 뷰포트에 보이는 캐릭터의 줌을 정지한다

* @param
* void

* @return
* void

* @example
* var CharacterViewportWindowHandle c_handle;
* c_handle = GetCharacterViewportWindowHandle("InventoryWnd.ObjectViewport"); //핸들을 가져온다
* c_handle.StartZoom(true); //아웃줌한다
* c_handle.EndZoom(); //줌을 멈춘다
*/
native final function EndZoom();

/**
* 뷰포트에 보이는 캐릭터의 스케일(크기를 조정한다)

* @param
* fCharacterScale : 스케일

* @return
* void

* @example
* var CharacterViewportWindowHandle c_handle;
* c_handle = GetCharacterViewportWindowHandle("InventoryWnd.ObjectViewport"); //핸들을 가져온다
* c_handle.SetCharacterScale(1.03f); //1.03으로 스케일한다(게임에서 실제로 1정도의 스케일을 사용하고 있다)
*/
native final function SetCharacterScale( float fCharacterScale );

/**
* 뷰포트에 보이는 캐릭터의 X 방향 위치를 조정한다

* @param
* nOffsetX : x좌표

* @return
* void

* @example
* var CharacterViewportWindowHandle c_handle;
* c_handle = GetCharacterViewportWindowHandle("InventoryWnd.ObjectViewport"); //핸들을 가져온다
* c_handle.SetCharacterOffsetX(-4); //-4 위치로 이동시킨다
*/
native final function SetCharacterOffsetX( int nOffsetX );

/**
* 뷰포트에 보이는 캐릭터의 X 방향 위치를 조정한다

* @param
* nOffsetY : y좌표

* @return
* void

* @example
* var CharacterViewportWindowHandle c_handle;
* c_handle = GetCharacterViewportWindowHandle("InventoryWnd.ObjectViewport"); //핸들을 가져온다
* c_handle.SetCharacterOffsetY(-3); //-3 위치로 이동시킨다
*/
native final function SetCharacterOffsetY( int nOffsetY );

native final function SpawnNPC();
native final function SpawnEffect(string EffectName);
native final function SetUISound(bool IsUISound);
native final function SetCharacterOffsetZ( int nOffsetZ );
native final function SetCharacterOffset(vector vCharacterOffset);

/**
* 뷰포트에 보이는 캐릭터에게 액션을 시킨다

* @param
* index : 액션의 종류

* @return
* void

* @example
* var CharacterViewportWindowHandle c_handle;
* c_handle = GetCharacterViewportWindowHandle("InventoryWnd.ObjectViewport"); //핸들을 가져온다
* c_handle.PlayAnimation(2); //인사하는 액션을 취한다
*/
native final function PlayAnimation(int index);

// 공격하는 애니메이션을 실행한다.
// index :	0 AtkWaitAnimName
//			1 Atk01AnimName
//			2 Atk02AnimName
//			3 Atk03AnimName
native final function PlayAttackAnimation(int index);

// 자동 공격 설정. 설정시 기본 WaitAnim이 AtkWaitAnim으로 변경된다.
native final function AutoAttacking(bool bAttack);

native final function ShowNPC(float Duration);
native final function HideNPC(float Duration);

// 표시되는 NPC ID를 변경. SetNPCInfo 이후 SpawnNPC() 해 줘야 변경된다. User를 NPC로 변경하는 동작은 막혀있다.
native final function SetNPCInfo(int id);

// 마우스 좌클릭 드래그로 캐릭터 회전 비율 설정. 기본값인 0으로 설정시 동작하지 않는다.
native final function SetDragRotationRate(int nRotationRate);

// 카메라 회전의 현재 값을 설정한다. StartRotation()나 마우스 좌클릭 드래그에 의해서 변경 될 수 있다.
native final function SetCurrentRotation( int nRotation );

// 카메라의 현재 거리를 설정한다. ChracterScale 조절시 Effect의 크기가 변경되지 않고, 카메라 거리를 조절하면 같이 변경된다.
native final function SetCameraDistance(int nDist);

// 캐릭터 Spawn시 알파가 적용되는 시간을 조절한다. 기본값은 2.5이다.
native final function SetSpawnDuration(float fDuration);

// NPCViewportData 스크립트에서 읽어서 세팅
native final function SetNPCViewportData( int ID );
defaultproperties
{
}
