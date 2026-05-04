/**
*텍스트박스 컨트롤에 대한 함수를 정의
*/
class TextBoxHandle extends WindowHandle
	native;
/**
* 텍스트 박스의 텍스트를 가져온다

* @param
* void

* @return
* String : 텍스트 박스의 텍스트를 리턴

* @example
* var TextBoxHandle t_handle;
* t_handle = GetTextboxHandle("ChatFilterWnd.CurrentText"); //텍스트박스 컨트롤의 핸들을 가져온다
* debug(t_handle.GetText()); //텍스트를 가져와 출력해본다
*/
native final function String GetText();

/**
* 텍스트 박스의 텍스트를 변경한다

* @param
* a_Text : 변경할 텍스트

* @return
* void

* @example
* var TextBoxHandle t_handle;
* t_handle = GetTextboxHandle("ChatFilterWnd.CurrentText"); //텍스트박스 컨트롤의 핸들을 가져온다
* t_handle.SetText("Hello World"); // 텍스트를 변경한다
*/
native final function SetText( String a_Text );

/**
* 텍스트 박스의 텍스트색상을 변경한다

* @param
* a_Color : 변경할 색상

* @return
* void

* @example
* var TextBoxHandle t_handle;
* var Color TextColor;
* t_handle = GetTextboxHandle("ChatFilterWnd.CurrentText"); //텍스트박스 컨트롤의 핸들을 가져온다
* t_handle.SetText("Hello World"); // 텍스트를 변경한다
* TextColor.R = 100;
* TextColor.G = 100;
* TextColor.B = 100;
* t_handle.SetTextColor(TextColor); // 색상을 변경한다
*/
native final function SetTextColor( Color a_Color );

/**
* 텍스트 박스의 텍스트색상을 가져온다

* @param
* void

* @return
* Color : 텍스트 박스의 색상을 리턴

* @example
* var TextBoxHandle t_handle;
* var Color TextColor;
* t_handle = GetTextboxHandle("ChatFilterWnd.CurrentText"); //텍스트박스 컨트롤의 핸들을 가져온다
* TextColor = t_handle.GetTextColor(); // 색상을 가져온다
*/
native final function Color GetTextColor();

/**
* 텍스트 박스의 정렬을 변경한다

* @param
* align : 변경할 정렬상태

* @return
* void

* @example
* var TextBoxHandle t_handle;
* t_handle = GetTextboxHandle("ChatFilterWnd.CurrentText"); //텍스트박스 컨트롤의 핸들을 가져온다
* t_handle.SetAlign(TA_Left); // 왼쪽정렬로 한다

*enum ETextAlign
*{
*	TA_Undefined,
*	TA_Left, 
*	TA_Center,
*	TA_Right,
*	TA_MacroIcon,
*};
*/
native final function SetAlign(ETextAlign align);

/**
* 정수형태를 받아서 텍스트박스의 텍스트로 정한다.

* @param
* Number : 텍스트가 될 정수

* @return
* void

* @example
* var TextBoxHandle t_handle;
* t_handle = GetTextboxHandle("ChatFilterWnd.CurrentText"); //텍스트박스 컨트롤의 핸들을 가져온다
* t_handle.SetInt("10000"); // 10000 이 텍스트가 된다

*enum ETextAlign
*{
*	TA_Undefined,
*	TA_Left, 
*	TA_Center,
*	TA_Right,
*	TA_MacroIcon,
*};
*/
native final function SetInt(int Number);

/**
* 텍스트 박스의 툴팁 스트링을 정한다.

* @param
* align : 변경할 툴팁 스트링

* @return
* void

* @example
* var TextBoxHandle t_handle;
* t_handle = GetTextboxHandle("ChatFilterWnd.CurrentText"); //텍스트박스 컨트롤의 핸들을 가져온다
* t_handle.SetToolTipString("tooltip"); // 툴팁스트링을 정한다.
*/

native final function SetTooltipString(string Text);

native final function SetTextEllipsisWidth(int Width);

/**
* 폰트 변경. 폰트 이름으로 FontID를 찾아 설정한다.

* TextListBoxHandle.uc 의 것을 WindowHandle 로 옮길까 하다가
* TextListBox 에만 있어야 할 것이 있어 TextBox 버전을 새로 만들었음

* @param
* FontName : 폰트이름 ex) hs12
* //SetChild, LGType, LineGap : TextBox 버전에서는 사용하지 않음

* @return
* void

* @example
* var TextListBoxHandle t_handle;
* t_handle = GetTextListBoxHandle("ChatFilterWnd.CurrentText");
* t_handle.SetFontIDByName("hs12");
*/
native final function SetFontIDByName( string FontName, optional bool SetChild );

/**
* 텍스트 박스의 Size를 가져온다

* @param
* void

* @return
* int : 텍스트 박스의 size를 리턴
*/
native final function int GetSizeX();
native final function int GetSizeY();
defaultproperties
{
}
