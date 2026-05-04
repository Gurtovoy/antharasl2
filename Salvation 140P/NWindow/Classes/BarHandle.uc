/**
*바컨트롤(statusbar컨트롤에 비해 컴팩트한 컨트롤)에 대한 함수를 정의
*/
class BarHandle extends WindowHandle
	native;
/**
*바의 값을 조절한다.
* @param
* a_CurValue : 지정할 값
* a_MaxValue : 최대값

* @return
*void

* @example
*var BarHandle b_handle;
*b_handle = GetBarHandle( "RecipeBuyManufactureWnd.barMp" ); //핸들을 가져온다
*b_handle.SetPoint(100,1000); // 전체 100/1000 으로 표시된다
*/	
native final function SetValue( int a_MaxValue, int a_CurValue );

/**
*바의 값을 가져온다
* @param
* a_CurValue : 지정된 값이 저장될 변수
* a_MaxValue : 최대값이 저장될 변수

* @return
*void

* @example
*var BarHandle b_handle;
*var int MaxValue;
*var int CurValue;
*b_handle = GetBarHandle( "RecipeBuyManufactureWnd.barMp" ); //핸들을 가져온다
*b_handle.GetValue(MaxValue, CurValue); //값을 가져온다
*/
native final function GetValue( out int a_MaxValue, out int a_CurValue );

/**
*바를 초기화 한다
* @param
* void

* @return
*void

* @example
*var BarHandle b_handle;
*b_handle = GetBarHandle( "RecipeBuyManufactureWnd.barMp" ); //핸들을 가져온다
*b_handle.Clear(); //초기화한다
*/
native final function Clear();


/**
*바를 텍스쳐를 변경한다.
* @param
* int : TextureIdx : 텍스쳐종류  0:ForeLeft 1:ForeTexture 2:ForeRightTexture 3:BackLeftTexture 4:BackTexture 5:BackRightTexture
* int : TexName : 텍스쳐이름

* @return
*void

* @example
*/
native final function SetTexture(int TextureIdx, string TexName);
defaultproperties
{
}
