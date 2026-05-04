/**
*리스트박스컨트롤에 대한 함수를 정의한다
*/
class ListBoxHandle extends WindowHandle
	native;

/**
*리스트박스에 문자열을 추가한다

* @param
* Text : 추가할 문자열

* @return
* void

* @example
*var ListBoxHandle l_handle; //윈도우 핸들 선언
*l_handle = GetListBoxHandle("UIEditor_FileManager.lstFiles");//핸들을 가져온다
*l_handle.AddString("New Item"); //"New Item"이라는 문자열을 추가하였다
*/
native final function AddString(string Text);

/**
*리스트박스의 문자열을 모두삭제한다

* @param
* void

* @return
* void

* @example
*var ListBoxHandle l_handle; //윈도우 핸들 선언
*l_handle = GetListBoxHandle("UIEditor_FileManager.lstFiles");//핸들을 가져온다
*l_handle.Clear(); //문자열이 모두 삭제되었다
*/
native final function Clear();

/**
*리스트박스의 문자열을 추가한다. 색상과 데이터를 함께 지정한다
*그러나 실제로 이함수는 사용된적이 없고 내부에서는 AddString과 함께 하나의 함수로 오버라이딩 되어있다.
*또한 색상이 적용되지 않는다. 리스트박스를 사용해서 구현할때 두개의 정수공간을 다른용도로 사용할수있는정도로
*생각하면 되겠다(GetSelectedColor나 GetSelectedData정도의 함수가 필요하겠지만 말이다)

* @param
* Text : 추가할 문자열
* Color : 문자열의 색상
* Data : 지정할 데이타

* @return
* void

* @example
*var ListBoxHandle l_handle; //윈도우 핸들 선언
*var int itemcolor;
*var int itemdata;
*l_handle = GetListBoxHandle("UIEditor_FileManager.lstFiles"); //핸들을 가져온다
*itemcolor = 100;
*itemdata = 100;
*l_handle.AddStringWithData("New Item", tcolor, itemdata); //문자열을 추가한다
*/
native final function AddStringWithData(string Text, Color Color, int Data);

/**
*선택된 아이템의 문자열을 리턴한다.

* @param
* void

* @return
* string

* @example
*var ListBoxHandle l_handle; //윈도우 핸들 선언
*l_handle = GetListBoxHandle("UIEditor_FileManager.lstFiles"); //핸들을 가져온다
*debug(l_handle.GetSelectedString()); //선택된 스트링을 출력해본다
*/
native final function string GetSelectedString();
native final function int GetSelectedItemData();

/**
*스크롤의 위치를 결정한다

* @param
* pos : 스크롤의 위치

* @return
* string

* @example
*var ListBoxHandle l_handle; //윈도우 핸들 선언
*l_handle = GetListBoxHandle("UIEditor_FileManager.lstFiles"); //핸들을 가져온다
*l_handle.SetListBoxScrollPosition(10); //스크롤의 위치를 10(밑으로 10번 내린것)으로한다
*/
native final function SetListBoxScrollPosition(int pos);

native final function SetDrawOffset(int offsetx, int offsety);

native final function SetMaxRow(int maxrow);
defaultproperties
{
}
