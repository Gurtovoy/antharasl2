/**
*콤보박스에 대한 함수를 정의한다
*/
class ComboBoxHandle extends WindowHandle
	native;



/**
* 콤보박스에 스트링을 추가한다

* @param
* str : 추가할 스트링

* @return
* void

* @example
*var ComboBoxHandle c_handle; //윈도우 핸들 선언
*c_handle = GetComboBoxHandle( "PartyMatchWnd.LevelFilterComboBox" );//핸들을 가져온다
*c_handle.AddString("new item"); //새로운 스트링을 추가한다.
*/
native final function AddString(string str);

/**
* 콤보박스에 스트링을 추가하되 앞에 갭을 둔다

* @param
* str : 추가할 스트링
* gap_mode : 갭, 갭1당 4칸이 앞쪽에 띄워진다

* @return
* void

* @example
*var ComboBoxHandle c_handle; //윈도우 핸들 선언
*c_handle = GetComboBoxHandle( "PartyMatchWnd.LevelFilterComboBox" );//핸들을 가져온다
*c_handle.AddStringWithGap("new item",1); //새로운 스트링을 추가한다. 앞을 네칸띄운다
*/
native final function AddStringWithGap(string str, optional int gap_mode);

/**
* 콤보박스에 시스템 스트링을 추가한다

* @param
* index : 추가할 시스템스트링의 번호

* @return
* void

* @example
*var ComboBoxHandle c_handle; //윈도우 핸들 선언
*c_handle = GetComboBoxHandle( "PartyMatchWnd.LevelFilterComboBox" );//핸들을 가져온다
*c_handle.SYS_AddString(0); //빈칸이 추가되었다
*c_handle.SYS_AddString(1); //"인벤토리"이 추가되었다
*c_handle.SYS_AddString(2); //"아이템"이 추가되었다
*c_handle.SYS_AddString(3); //"소중한것"이 추가되었다
*c_handle.SYS_AddString(4); //"청동"이 추가되었다
*c_handle.SYS_AddString(5); //"철"이 추가되었다
*c_handle.SYS_AddString(6); //"나무"이 추가되었다
*c_handle.SYS_AddString(7); //"뼈"이 추가되었다 //보다시피 어떤의미인지는 알기힘들었다
*/
native final function SYS_AddString(int index);

/**
* 콤보박스에 스트링을 추가함가 동시에 그 스트링에 추가데이터(int형)을 저장해놓는다

* @param
* str : 추가할 스트링
* reserved : 보관할데이터

* @return
* void

* @example
*var ComboBoxHandle c_handle; //윈도우 핸들 선언
*var int c_reserved;
*c_handle = GetComboBoxHandle( "PartyMatchWnd.LevelFilterComboBox" );//핸들을 가져온다
*c_handle.Clear();//모두 지운다
*c_handle.AddStringWithReserved("has100", 100); // "has100"이라는 스트링이 추가되었고 100이라는 데이터를 보관한다
*c_handle.AddStringWithReserved("has1000", 1000); // "has100"이라는 스트링이 추가되었고 1000이라는 데이터를 보관한다
*c_reserved = c_handle.GetReserved(0); // 100 을가져온다
*c_reserved = c_handle.GetReserved(1); // 1000 을가져온다
*/
native final function AddStringWithReserved(string str,int reserved);

/**
* 콤보박스에 시스템 스트링을 추가함가 동시에 그 스트링에 추가데이터(int형)을 저장해놓는다

* @param
* index : 추가할 시스템스트링의 번호
* reserved : 보관할데이터

* @return
* void

* @example
*var ComboBoxHandle c_handle; //윈도우 핸들 선언
*var int c_reserved;
*c_handle = GetComboBoxHandle( "PartyMatchWnd.LevelFilterComboBox" );//핸들을 가져온다
*c_handle.Clear();//모두 지운다
*c_handle.SYS_AddStringWithReserved(1, 100); // "인벤토리"이라는 스트링이 추가되었고 100이라는 데이터를 보관한다
*c_handle.SYS_AddStringWithReserved(2, 1000); // "아이템"이라는 스트링이 추가되었고 1000이라는 데이터를 보관한다
*c_reserved = c_handle.GetReserved(0); // 100 을가져온다
*c_reserved = c_handle.GetReserved(1); // 1000 을가져온다
*/
native final function SYS_AddStringWithReserved(int index,int reserved);

/**
* 콤보박스의 지정된 인덱스의 스트링을 가져온다

* @param
* num : 가져올 인덱스

* @return
* string : 지정된 인덱스의 스트링

* @example
*var ComboBoxHandle c_handle; //윈도우 핸들 선언
*c_handle = GetComboBoxHandle( "PartyMatchWnd.LevelFilterComboBox" );//핸들을 가져온다
*debug(c_handle.GetString(0)); // 제일 위의 스트링을 출력한다
*/
native final function string GetString(int num);

/**
* 스트링에 저장해 두었던 reserved 데이터를 반환한다.

* @param
* num : 데이터를 가져올 인덱스

* @return
* int : 저장해 두었던 reserved 데이터

* @example
*var ComboBoxHandle c_handle; //윈도우 핸들 선언
*var int c_reserved;
*c_handle = GetComboBoxHandle( "PartyMatchWnd.LevelFilterComboBox" );//핸들을 가져온다
*c_handle.Clear();//모두 지운다
*c_handle.AddStringWithReserved("has100", 100); // "has100"이라는 스트링이 추가되었고 100이라는 데이터를 보관한다
*c_handle.AddStringWithReserved("has1000", 1000); // "has100"이라는 스트링이 추가되었고 1000이라는 데이터를 보관한다
*c_reserved = c_handle.GetReserved(0); // 100 을가져온다
*c_reserved = c_handle.GetReserved(1); // 1000 을가져온다
*/
native final function int GetReserved(int num);

/**
* 선택된 아이템의 인덱스를 리턴한다

* @param
* void

* @return
* int : 선택된 아이템의 인덱스

* @example
*var ComboBoxHandle c_handle; //윈도우 핸들 선언
*c_handle = GetComboBoxHandle( "PartyMatchWnd.LevelFilterComboBox" );//핸들을 가져온다
*c_handle.SetSelectedNum(0); //0번째를 선택
*debug(string(c_handle.GetSelectedNum())); // 0이출력된다
*/
native final function int GetSelectedNum();

/**
* 지정한 인덱스의 아이템을 선택한다.

* @param
* num : 인덱스

* @return
* void

* @example
*var ComboBoxHandle c_handle; //윈도우 핸들 선언
*c_handle = GetComboBoxHandle( "PartyMatchWnd.LevelFilterComboBox" );//핸들을 가져온다
*c_handle.SetSelectedNum(0); //0번째를 선택
*debug(string(c_handle.GetSelectedNum())); // 0이출력된다
*/
native final function SetSelectedNum(int num);

/**
* 예상하시는대로 모든 아이템을 지운다

* @param
* num : 인덱스

* @return
* void

* @example
*var ComboBoxHandle c_handle; //윈도우 핸들 선언
*c_handle = GetComboBoxHandle( "PartyMatchWnd.LevelFilterComboBox" );//핸들을 가져온다
*c_handle.Clear();//다 지운다
*/
native final function Clear();

/**
* 아이템의 총수를 리턴한다.

* @param
* void

* @return
* int : 총 아이템수

* @example
*var ComboBoxHandle c_handle; //윈도우 핸들 선언
*var int totalnum;
*c_handle = GetComboBoxHandle( "PartyMatchWnd.LevelFilterComboBox" );//핸들을 가져온다
*totalnum = c_handle.GetNumOfItems();//아이템의 수를 가져온다
*/
native final function int GetNumOfItems();

/**
* 스트링을 색상지정하여 추가한다.

* @param
* str : 추가할 스트링
* Col : 지정할 색상

* @return
* void

* @example
*var ComboBoxHandle c_handle; //윈도우 핸들 선언
*var color textcolor;
*textcolor.R = 255;
*textcolor.G = 0;
*textcolor.B = 0;
*textcolor.A = 255;
*c_handle = GetComboBoxHandle( "PartyMatchWnd.LevelFilterComboBox" );//핸들을 가져온다
*c_handle.AddStringWithColor("Red item", textcolor); //"Red item"을 빨간색으로 추가한다
*/
native final function int AddStringWithColor(string str, color Col);

/**
* 함수 AddStringWithFileExt() 를 먼저참조하자. 지정한 인덱스의 아이템에 달아두었던 정보를 가져온다.

* @param
* num : 아이템의 인덱스

* @return
* array<string>

* @example
*var ComboBoxHandle FileExtComboBoxCtrl; //윈도우 핸들 선언
*var array<string> strArray;
*FileExtComboBoxCtrl = GetComboBoxHandle( "FileListWnd.FLWFTypeComboBox" );//핸들을 가져온다
*FileExtComboBoxCtrl.Clear();
*strArray.Length = 1;
*strArray[0] = "*";
*FileExtComboBoxCtrl.AddStringWithFileExt("모든 파일", strArray);
*strArray.Length = 2;
*strArray[0] = "txt";
*strArray[1] = "doc";
*FileExtComboBoxCtrl.AddStringWithFileExt("텍스트 파일", strArray);
*strArray.Length = 1;
*strArray[0] = "log";
*FileExtComboBoxCtrl.AddStringWithFileExt("로그 파일", strArray); //파일 필터용으로 쓰려는 듯하다
*strArray = FileExtComboBoxCtrl.GetFileExtInfo(1); //저장된것을 불러온다
*/
native final function array<string> GetFileExtInfo(int num);

/**
* 스트링을 추가하되 그 스트링에 해당하는 파일의 확장자를 달아준다
* 먼소린가 싶을테지만 예제를 봐주세요

* @param
* str : 추가할 스트링
* strArray : 해당하는 확장자 어레이

* @return
* void

* @example
*var ComboBoxHandle FileExtComboBoxCtrl; //윈도우 핸들 선언
*var array<string> strArray;
*FileExtComboBoxCtrl = GetComboBoxHandle( "FileListWnd.FLWFTypeComboBox" );//핸들을 가져온다
*FileExtComboBoxCtrl.Clear();
*strArray.Length = 1;
*strArray[0] = "*";
*FileExtComboBoxCtrl.AddStringWithFileExt("모든 파일", strArray);
*strArray.Length = 2;
*strArray[0] = "txt";
*strArray[1] = "doc";
*FileExtComboBoxCtrl.AddStringWithFileExt("텍스트 파일", strArray);
*strArray.Length = 1;
*strArray[0] = "log";
*FileExtComboBoxCtrl.AddStringWithFileExt("로그 파일", strArray); //파일 필터용으로 쓰려는 듯하다
*/
native final function AddStringWithFileExt(string str, array<string> strArray);

/**
* 콤보박스에 스트링을 추가하되 아이콘을 단다.

* @param
* str : 추가할 스트링

* @return
* void

* @example
*var ComboBoxHandle c_handle; //윈도우 핸들 선언
*c_handle = GetComboBoxHandle( "PartyMatchWnd.LevelFilterComboBox" );//핸들을 가져온다
*c_handle.AddString("new item"); //새로운 스트링을 추가한다.
*/
native final function AddStringWithIcon(string str, string Icontex);

/**
* 콤보박스에 스트링을 추가하되 아이콘을 달면서 갭을준다

* @param
* str : 추가할 스트링

* @return
* void

* @example
*var ComboBoxHandle c_handle; //윈도우 핸들 선언
*c_handle = GetComboBoxHandle( "PartyMatchWnd.LevelFilterComboBox" );//핸들을 가져온다
*c_handle.AddString("new item"); //새로운 스트링을 추가한다.
*/
native final function AddStringWithIconWithGap(string str, string Icontex, optional int gap_mode);

native final function AddStringWithIconWithStr(string str, string Icontex , string additionalstr);

native final function AddStringWithIconWithGapWithStr(string str, string Icontex, int gap_mode, string additionalstr);
native final function string GetAdditionalString(int num);
defaultproperties
{
}
