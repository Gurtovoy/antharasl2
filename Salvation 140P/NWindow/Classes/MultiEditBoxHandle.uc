/**
* 멀티에디트박스(여러줄쓸수있는 에디트 박스)에 대한 함수정의
*/
class MultiEditBoxHandle extends WindowHandle
	native;

/**
* 에디트박스의 스트링을 가져온다

* @param
* void

* @return
* void

* @example
* var MultiEditBoxHandle t_handle;
* t_handle = GetMultiEditBoxHandle("PostWriteWnd.PostContents"); //핸들을 가져온다
* debug(t_handle.GetString()); //스트링을 가져와 출력한다.
*/
native final function string GetString();

/**
* 에디트박스의 스트링을 변경한다

* @param
* void

* @return
* void

* @example
* var MultiEditBoxHandle t_handle;
* t_handle = GetMultiEditBoxHandle("PostWriteWnd.PostContents"); //핸들을 가져온다
* t_handle.SetString("It is so easy to see dysfunction beetween U and Me"); //텍스트를 변경한다.
*/
native final function SetString( string str );

native final function SetMaxSizeOfText(int maxSizeOfText);
native final function int GetTotalSizeOfText();
defaultproperties
{
}
