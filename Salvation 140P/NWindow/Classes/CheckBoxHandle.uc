/**
*체크박스에 관한 함수를 정의
*/
class CheckBoxHandle extends WindowHandle
	native;
/**
* 타이틀의 텍스트(체크칸 옆의 텍스트)를 변경한다

* @param
* Title : 변경할 타이틀 텍스트

* @return
* void

* @example
*var CheckBoxHandle c_handle; //윈도우 핸들 선언
*c_handle = GetCheckBoxHandle ( "RadarOptionWnd.checkPartyView" ); //핸들을 가져온다
*c_handle.SetTitle("check me!!!!!!!!"); //타이틀 변경
*/
native final function SetTitle(string Title);

/**
* 체크박스의 체크상태를 변경한다

* @param
* bCheck : true면 체크, false 면 uncheck

* @return
* void

* @example
*var CheckBoxHandle c_handle; //윈도우 핸들 선언
*c_handle = GetCheckBoxHandle ( "RadarOptionWnd.checkPartyView" ); //핸들을 가져온다
*c_handle.SetCheck(true); //체크한다
*/
native final function SetCheck(bool bCheck);

/**
* 체크박스의 체크상태를 검사한다

* @param
* void

* @return
* bool : true 면 체크 false면 uncheck

* @example
*var CheckBoxHandle c_handle; //윈도우 핸들 선언
*c_handle = GetCheckBoxHandle ( "RadarOptionWnd.checkPartyView" ); //핸들을 가져온다
*if(c_handle.IsChecked()) c_handle.SetCheck(false); //체크되어있으면 체크를 해제한다
*/
native final function bool IsChecked();

/**
* 체크박스가 비활성화 상태인지 검사한다

* @param
* void

* @return
* bool : true 면 비활성화  false면 활성화

* @example
*var CheckBoxHandle c_handle; //윈도우 핸들 선언
*c_handle = GetCheckBoxHandle ( "RadarOptionWnd.checkPartyView" ); //핸들을 가져온다
*if(c_handle.IsDisable()) c_handle.SetDisable(false); // 비활성화 되어있으면 활성화 시킨다
*/
native final function bool IsDisable();

/**
* 체크박스를 비활성화 시키거나 해제한다

* @param
* bDisable : true 면 비활성화 false면 활성화

* @return
* void

* @example
*var CheckBoxHandle c_handle; //윈도우 핸들 선언
*c_handle = GetCheckBoxHandle ( "RadarOptionWnd.checkPartyView" ); //핸들을 가져온다
*if(c_handle.IsDisable()) c_handle.SetDisable(false); // 비활성화 되어있으면 활성화 시킨다
*/
native final function SetDisable(bool bDisable);

/**
* 체크박스를 비활성화 상태를 토글한다(활성화 -> 비활성화 -> 활성화...........)

* @param
* void

* @return
* void

* @example
*var CheckBoxHandle c_handle; //윈도우 핸들 선언
*c_handle = GetCheckBoxHandle ( "RadarOptionWnd.checkPartyView" ); //핸들을 가져온다
*c_handle.ToggleDisable(); // 활성화상태를 토글한다
*/
native final function ToggleDisable();
defaultproperties
{
}
