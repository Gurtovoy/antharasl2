/**
*버튼컨트롤에 대한 함수를 정의
*/
class ButtonHandle extends WindowHandle
	native;
/**
* 버튼의 텍스트를 가져온다

* @param
* void

* @return
* String : 버튼의 텍스트

* @example
* var ButtonHandle b_handle;
* b_handle = GetButtonHandle("PartyMatchWnd.RefreshBtn"); //핸들을 가져온다
* debug(b_handle.GetButtonName()); //"목록갱신" 이 출력되었다
*/
native final function String GetButtonName();

/**
* 버튼의 텍스트를 변경한다. 이때 시스템스트링의 인덱스를 주어 텍스트를 선택한다

* @param
* a_NameID : 시스템스트릉의 인덱스

* @return
* void

* @example
* var ButtonHandle b_handle;
* b_handle = GetButtonHandle("PartyMatchWnd.RefreshBtn"); //핸들을 가져온다
* b_handle.SetButtonName(1); // "인벤토리"로 바뀌었다
*/
native final function SetButtonName( int a_NameID );

/**
* 버튼의 텍스트를 변경한다. 

* @param
* a_NameID : 변경할 텍스트

* @return
* void

* @example
* var ButtonHandle b_handle;
* b_handle = GetButtonHandle("PartyMatchWnd.RefreshBtn"); //핸들을 가져온다
* b_handle.SetNameText("sohee"); //버튼의 텍스트를 변경한다
*/
native final function SetNameText( string NameText );

/**
* 버튼의 텍스쳐를 변경한다

* @param
* sForeTexture : 평상시 텍스쳐
* sBackTexture : 눌렀을시 텍스쳐
* sHighlightTexture : 마우스 오버시 텍스쳐

* @return
* void

* @example
* var ButtonHandle b_handle;
* b_handle = GetButtonHandle("PartyMatchWnd.RefreshBtn"); //핸들을 가져온다
* b_handle.SetTexture("L2UI_CH3.Msn.chatting_msn5", "L2UI_CH3.Msn.chatting_msn5_down", "L2UI_CH3.Msn.chatting_msn5_over"); //텍스쳐를 변경하였다. 엠에센 버튼텍스쳐를 파티매칭윈도우 쪽 버튼에 씌워보았다
*/
native final function SetTexture( string sForeTexture, string sBackTexture, string sHighlightTexture );


/**
* 버튼이 mouse over상태인지 확인한다.

* @param
* void

* @return
* int

* @example
* var ButtonHandle b_handle;
* b_handle = GetButtonHandle("PartyMatchWnd.RefreshBtn"); //핸들을 가져온다
* b_handle.IsMouseOver();
*/
native final function bool IsMouseOver();


//branch120516
native final function int GetButtonValue();
native final function SetButtonValue(int value);
//end of branch

//branch120703
native final function SetEnable(bool bEnable);
//end of branch
defaultproperties
{
}
