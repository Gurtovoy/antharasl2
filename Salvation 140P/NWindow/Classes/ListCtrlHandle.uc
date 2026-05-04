/**
*리스트컨트롤에 대한 함수를 정의한다
*/
class ListCtrlHandle extends WindowHandle
	native;

/**
*레코드를 삽입한다

* @param
*Record : 삽입할 레코드

* @return
*void

* @example
*var ListCtrlHandle l_handle; //윈도우 핸들 선언
*var LVDataRecord newrec;
*newrec.LVDataList.length = 5; //하나의 레코드에 몇개의 데이터로 이루어져있나. 미리 맞춰줘야한다
*newrec.LVDataList[0].szData = "hi";
*newrec.LVDataList[1].szData = "mam";
*newrec.LVDataList[2].szData = "what's";
*newrec.LVDataList[3].szData = "up";
*newrec.LVDataList[4].szData = "?";
*l_handle = GetListCtrlHandle( "PartyMatchWnd.UnionMatchListCtrl" );
*l_handle.InsertRecord(newrec); //새로운 레코드를 삽입한다.

*struct native constructive LVDataRecord
*{	
*	var array<LVData> LVDataList;
*	var string szReserved;
*	var INT64 nReserved1;
*	var INT64 nReserved2;
*	var INT64 nReserved3;
*};

*struct native constructive LVData
*{
*	var string szData;
*	var string szReserved;

*	var bool bUseTextColor;
*	var Color TextColor;

*	var int nReserved1;
*	var int nReserved2;
*	var int nReserved3;
	
*	//Main Texture(텍스쳐 하나만 설정할때, Centeralign된다)
*	var string szTexture;
*	var int nTextureWidth;
*	var int nTextureHeight;
	
*	//Texture Array
*	var array<LVTexture> arrTexture;
*};
*/
native final function InsertRecord(LVDataRecord Record);

/**
*모든 레코드를 삭제한다

* @param
*Record : 삽입할 레코드

* @return
*void

* @example
*var ListCtrlHandle l_handle; //윈도우 핸들 선언
*l_handle = GetListCtrlHandle( "PartyMatchWnd.UnionMatchListCtrl" );
*l_handle.DeleteAllItem();
*/
native final function DeleteAllItem();

/**
*특정 레코드를 삭제한다

* @param
*index : 삭제될 레코드의 인덱스

* @return
*void

* @example
*var ListCtrlHandle l_handle; //윈도우 핸들 선언
*l_handle = GetListCtrlHandle( "PartyMatchWnd.UnionMatchListCtrl" );
*l_handle.DeleteRecord(0); //제일 위의 레코드를 지운다
*/
native final function DeleteRecord(int index);

/**
*레코드의 수를 리턴한다.

* @param
* void

* @return
* int : 레코드의 수

* @example
*var ListCtrlHandle l_handle; //윈도우 핸들 선언
*var int recnum;
*l_handle = GetListCtrlHandle( "PartyMatchWnd.UnionMatchListCtrl" );
*recnum = l_handle.GetRecordCount(); //레코드의 수를 리턴
*/
native final function int GetRecordCount();

/**
*선택된 레코드의 인덱스를 리턴한다.(아무것도 선택안했을때는 -1)

* @param
* void

* @return
* int : 선택된 레코드의 인덱스 (아무것도 선택안했을때는 -1)

* @example
*var ListCtrlHandle l_handle; //윈도우 핸들 선언
*var int recindex;
*l_handle = GetListCtrlHandle( "PartyMatchWnd.UnionMatchListCtrl" );
*recindex = l_handle.GetSelectedIndex(); //선택된 레코드의 인덱스를 리턴
*/
native final function int GetSelectedIndex();

/**
*지정된 인덱스의 레코드를 선택한다.

* @param
* index : 선택할 레코드의 인덱스
* bMoveToRow : true면 레코드로 이동, false면 이동안함

* @return
* void

* @example
*var ListCtrlHandle l_handle; //윈도우 핸들 선언
*l_handle = GetListCtrlHandle( "PartyMatchWnd.UnionMatchListCtrl" );
*l_handle.SetSelectedIndex(0,true); //첫레코드를 선택하고 레코드로 이동한다
*/
native final function SetSelectedIndex( int index, bool bMoveToRow);

/**
*스크롤바를 보이게 하거나 안보이게한다

* @param
* bShow : true면 보임 false면 안보임

* @return
* void

* @example
*var ListCtrlHandle l_handle; //윈도우 핸들 선언
*l_handle = GetListCtrlHandle( "PartyMatchWnd.UnionMatchListCtrl" );
*l_handle.ShowScrollBar(false); 스크롤바를 안보이게 한다
*/
native final function ShowScrollBar( bool bShow);

/**
*지정된 인덱스의 레코드를 수정한다.

* @param
* index : 수정할 레코드의 인덱스
* Record : 새로 들어갈 레코드

* @return
* void

* @example
*var ListCtrlHandle l_handle; //윈도우 핸들 선언
*var LVDataRecord rec;
*rec.LVDataList.length = 5; //하나의 레코드에 몇개의 데이터로 이루어져있나. 미리 맞춰줘야한다
*newrec.LVDataList[0].szData = "hi";
*newrec.LVDataList[1].szData = "mam";
*newrec.LVDataList[2].szData = "what's";
*newrec.LVDataList[3].szData = "up";
*newrec.LVDataList[4].szData = "?";
*l_handle = GetListCtrlHandle( "PartyMatchWnd.UnionMatchListCtrl" );
*l_handle.ModifyRecord(0,newrec); //첫 레코드를 newrec로 교체한다

*struct native constructive LVDataRecord
*{	
*	var array<LVData> LVDataList;
*	var string szReserved;
*	var INT64 nReserved1;
*	var INT64 nReserved2;
*	var INT64 nReserved3;
*};

*struct native constructive LVData
*{
*	var string szData;
*	var string szReserved;

*	var bool bUseTextColor;
*	var Color TextColor;

*	var int nReserved1;
*	var int nReserved2;
*	var int nReserved3;
	
*	//Main Texture(텍스쳐 하나만 설정할때, Centeralign된다)
*	var string szTexture;
*	var int nTextureWidth;
*	var int nTextureHeight;
	
*	//Texture Array
*	var array<LVTexture> arrTexture;
*};
*/
native final function bool ModifyRecord(int index, LVDataRecord Record);

/**
*선택된 인덱스의 레코드를 가져온다

* @param
* record : 레코드를 가져올 변수

* @return
* void

* @example
*var ListCtrlHandle l_handle; //윈도우 핸들 선언
*var LVDataRecord rec;
*rec.LVDataList.length = 5; //하나의 레코드에 몇개의 데이터로 이루어져있나. 미리 맞춰줘야한다
*l_handle = GetListCtrlHandle( "PartyMatchWnd.UnionMatchListCtrl" );
*GetSelectedRec(rec); // 선택된 레코드를 rec에 가져온다. 선택된게 없다면 none

*struct native constructive LVDataRecord
*{	
*	var array<LVData> LVDataList;
*	var string szReserved;
*	var INT64 nReserved1;
*	var INT64 nReserved2;
*	var INT64 nReserved3;
*};

*struct native constructive LVData
*{
*	var string szData;
*	var string szReserved;

*	var bool bUseTextColor;
*	var Color TextColor;

*	var int nReserved1;
*	var int nReserved2;
*	var int nReserved3;
	
*	//Main Texture(텍스쳐 하나만 설정할때, Centeralign된다)
*	var string szTexture;
*	var int nTextureWidth;
*	var int nTextureHeight;
	
*	//Texture Array
*	var array<LVTexture> arrTexture;
*};
*/
native final function GetSelectedRec(out LVDataRecord record);

/**
*지정된 인덱스의 레코드를 가져온다

* @param
* index : 지정할 인덱스
* record : 레코드를 가져올 변수

* @return
* void

* @example
*var ListCtrlHandle l_handle; //윈도우 핸들 선언
*var LVDataRecord rec;
*rec.LVDataList.length = 5; //하나의 레코드에 몇개의 데이터로 이루어져있나. 미리 맞춰줘야한다
*l_handle = GetListCtrlHandle( "PartyMatchWnd.UnionMatchListCtrl" );
*GetRec(0,rec); // 첫 레코드를 rec에 가져온다. 

*struct native constructive LVDataRecord
*{	
*	var array<LVData> LVDataList;
*	var string szReserved;
*	var INT64 nReserved1;
*	var INT64 nReserved2;
*	var INT64 nReserved3;
*};

*struct native constructive LVData
*{
*	var string szData;
*	var string szReserved;

*	var bool bUseTextColor;
*	var Color TextColor;

*	var int nReserved1;
*	var int nReserved2;
*	var int nReserved3;
	
*	//Main Texture(텍스쳐 하나만 설정할때, Centeralign된다)
*	var string szTexture;
*	var int nTextureWidth;
*	var int nTextureHeight;
	
*	//Texture Array
*	var array<LVTexture> arrTexture;
*};
*/
native final function GetRec( int index, out LVDataRecord record );

/**
*리스트컨트롤을 초기화한다. 사용전에 호출해주자

* @param
* void

* @return
* void

* @example
*var ListCtrlHandle l_handle; //윈도우 핸들 선언
*var LVDataRecord rec;
*l_handle = GetListCtrlHandle( "PartyMatchWnd.UnionMatchListCtrl" );
*L_handle.InitListCtrl(); // 초기화한다
*/
native final function InitListCtrl();

/**
*리스트컨트롤의 지정된 열의 넓이를 아이템에 맞춰서 자동조정한다. (최소값을 지정할수 있다. 그이상 작아지지 않는다)

* @param
* col : 지정할 열

* @return
* void

* @example
*var ListCtrlHandle l_handle; //윈도우 핸들 선언
*var LVDataRecord rec;
*l_handle = GetListCtrlHandle( "PartyMatchWnd.UnionMatchListCtrl" );
*L_handle.AdjustColumnWidth(0); //0열의 넓이를 조정한다.
*/
native final function AdjustColumnWidth(int col);

/**
*리스트컨트롤의 지정된 열의 헤더의 텍스트 정렬을 지정한다

* @param
* col : 지정할 열
* align : 정렬 (TA_LEFT, TA_CENTER, TA_RIGHT)

* @return
* void

* @example
*var ListCtrlHandle l_handle; //윈도우 핸들 선언
*var LVDataRecord rec;
*l_handle = GetListCtrlHandle( "PartyMatchWnd.UnionMatchListCtrl" );
*L_handle.SetHeaderAlignment(0,TA_LEFT); //0열의 헤더의 텍스트를 왼쪽 정렬한다.
*/
native final function SetHeaderAlignment(int col, ETextAlign align);

/**
*리스트컨트롤의 헤더의 텍스트 앞에 오프셋을 준다

* @param
* col : 지정할 열
* align : 정렬 (TA_LEFT, TA_CENTER, TA_RIGHT)

* @return
* void

* @example
*var ListCtrlHandle l_handle; //윈도우 핸들 선언
*var LVDataRecord rec;
*l_handle = GetListCtrlHandle( "PartyMatchWnd.UnionMatchListCtrl" );
*L_handle.SetHeaderAlignment(0,TA_LEFT); //0열의 헤더의 텍스트를 왼쪽 정렬한다.
*/
native final function SetHeaderTextOffset(int col, int offset);

native final function SetResizable(bool b);

native final function SetColumnWidth(int Index, int Width);

native final function EnablePageBrowser(bool Enable);

/**
*리스트컨트롤의 툴팁 표시시에 선택한 셀만 표시하도록 함.

* @param
* bFlag : TRUE / FALSE - 선택된 셀에만 툴팁 표시될지 말지 선택.

* @return
* void
*/
native final function SetSelectedSelTooltip(bool bFlag);

/**
*리스트컨트롤의 툴팁 표시시에 선택한 셀만 표시하도록 함.

* @param
* bFlag : TRUE / FALSE - 선택된 셀에만 툴팁 표시될지 말지 선택.

* @return
* void
*/
native final function SetAppearTooltipAtMouseX(bool bFlag);

/**
*리스트컨트롤의 칼럼 스트링을 변경함

* @param
* Index : 칼럼 인덱스
* StrIndex : 칼럼에 교체 할 시스템 스트링 인덱스

* @return
* void
*/
native final function SetColumnString(int Index, int StrIndex);

/**
*리스트컨트롤의 칼럼 너비를 스트링보다 작게 조절하지 못하도록한다.

* @param
* bFlag : true 해당기능 사용

* @return
* void
*/
native final function SetColumnMinimumWidth(bool bFlag);
defaultproperties
{
}
