/**
*텍스트리스트박스에 대한 함수를 정의한다.
*/

class TextListBoxHandle extends WindowHandle
	native;

enum ELineGapType
{
	LG_NONE,
	LG_AUTO,
	LG_MANUAL
};

/**
* 리스트박스에 텍스트를 추가한다.

* @param
* text : 추가할 텍스트
* textColor : 텍스트의 색상

* @return
* void

* @example
* var TextListBoxHandle t_handle;
* var Color Textcolor
* t_handle = GetTextListBoxHandle("PostDetailWnd_SafetyTrade.PostContents");
* t_handle.AddString("hello world", Textcolor);
*/

native final function AddString( string text, Color textColor );

/**
* 챗윈도우에 텍스트를 추가한다.

* @param
* text : 추가할 텍스트
* textColor : 텍스트의 색상

* @return
* void

* @example
* var TextListBoxHandle t_handle;
* var Color Textcolor
* t_handle = GetTextListBoxHandle("PostDetailWnd_SafetyTrade.PostContents");
* t_handle.AddStringToChatWindow("hello world", Textcolor);
*/
native final function AddStringToChatWindow( string text, Color textColor );

/**
* 리스트를 클리어한다.

* @param
* void

* @return
* void

* @example
* var TextListBoxHandle t_handle;
* var Color Textcolor
* t_handle = GetTextListBoxHandle("PostDetailWnd_SafetyTrade.PostContents"); 
* t_handle.AddString("hello world", Textcolor);
* t_handle.Clear();
*/
native final function Clear();

/**
* 리스트의 스크롤 위치를지정한다.

* @param
* pos : 위치

* @return
* void

* @example
* var TextListBoxHandle t_handle;
* var Color Textcolor
* t_handle = GetTextListBoxHandle("PostDetailWnd_SafetyTrade.PostContents"); 
* t_handle.SetTextListBoxScrollPosition(10);
*/
native final function SetTextListBoxScrollPosition(int pos);

/**
* 폰트 변경. 폰트 이름으로 FontID를 찾아 설정한다.

* @param
* FontName : 폰트이름 ex) hs12
* SetChild : 자식들까지 설정할 것인지 여부, 기본값 TRUE
* LGType : LineGap을 바꾸지않는다 / 자동으로 바꾼다 / 수동으로 바꾼다. 기본값 LG_AUTO
* LineGap : LG_MANUAL일 때 설정값

* @return
* void

* @example
* var TextListBoxHandle t_handle;
* t_handle = GetTextListBoxHandle("PostDetailWnd_SafetyTrade.PostContents"); 
* t_handle.SetFontIDByName("hs12");
*/
native final function SetFontIDByName( string FontName, optional bool SetChild, optional ELineGapType LGType, optional int LineGap );
defaultproperties
{
}
