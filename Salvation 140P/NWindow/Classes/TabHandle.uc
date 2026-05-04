/**
*탭컨트롤에 필요한 함수를 정의
*/
class TabHandle extends WindowHandle
	native;

//tab 컨트롤 초기화 onshow에서 호출 해줘야한다.

/**
* tab 컨트롤 초기화 onshow에서 호출 해줘야한다.

* @param
* void

* @return
* void

* @example
* var TabHandle t_handle;
* t_handle = GetTabHandle("QuestTreeWnd.QuestTreeTab"); //핸들을 가져온다
* function OnShow(){
*	t_handle.InitTabCtrl(); //onshow에서 초기화 해준다
*   ..............
* }
*/
native final function InitTabCtrl();

/**
* 선택된 tab 을 바꾼다.

* @param
* index : 선택될 탭의 인덱스
* bSendMessage : WM_NWND_MSG 메시지를 상위 윈도우에서 dispatch할지를 결정한다. 같이전달되는 param은 index 이다. true면 보냄.

* @return
* void

* @example
* var TabHandle t_handle;
* t_handle = GetTabHandle("QuestTreeWnd.QuestTreeTab"); //핸들을 가져온다
* t_handle.SetTopOrder(1,false); //1번탭을 선택한다.(0번부터 시작)
*/
native final function SetTopOrder(int index, bool bSendMessage);

/**
* 선택된 tab의 인덱스를 가져온다

* @param
* void

* @return
* int : 선택된 tab의 인덱스

* @example
* var TabHandle t_handle;
* var int index;
* t_handle = GetTabHandle("QuestTreeWnd.QuestTreeTab"); //핸들을 가져온다
* t_handle.SetTopOrder(1,false); //1번탭을 선택한다.(0번부터 시작)
* index = t_handle.GetTopIndex(); // 1을가져온다
*/
native final function int GetTopIndex();

/**
* tab컨트롤의 탭을 비활성화 한다.

* @param
* index : 비활성화 할 탭의 인덱스
* bDisable : true 면 비활성화 false면 활성화
*
* @return
* void

* @example
* var TabHandle t_handle;
* var int index;
* t_handle = GetTabHandle("QuestTreeWnd.QuestTreeTab"); //핸들을 가져온다
* t_handle.SetDisable(2,true); //2번탭을 비활성화 한다
*/
native final function SetDisable(int index, bool bDisable);

/**
* tab버튼을 tab 컨트롤에 붙인다.

* @param
* index : 붙일 탭의 인덱스
*
* @return
* void

* @example
* var TabHandle t_handle;
* var int index;
* t_handle = GetTabHandle("QuestTreeWnd.QuestTreeTab"); //핸들을 가져온다
* t_handle.MergeTab(0); //0번탭을 붙인다.
* t_handle.MergeTab(1); //1번탭을 붙인다.
*/
native final function MergeTab(int index);

/**
* tab컨트롤의 탭의 텍스트를 바꾼다

* @param
* index : 이름을 바꿀 탭의 인덱스
* NewName : 바꿀 텍스트
*
* @return
* void

* @example
* var TabHandle t_handle;
* var int index;
* t_handle = GetTabHandle("QuestTreeWnd.QuestTreeTab"); //핸들을 가져온다
* t_handle.SetButtonName(3,"3t"); 3번째 탭의 텍스트를 3t 로 바꾼다
*/
native final function SetButtonName(int index, string NewName);

native final function SetButtonBlink(int index, bool Enable);
native final function SetButtonDisableTexture(int index, string TextureName); // branch 110824

native final function RemoveTabControl(int index);

native final function SetTabControlTexture(int index, string NewForeTexName, optional string NewBackTexName, optional string NewHighLightTexName);
defaultproperties
{
}
