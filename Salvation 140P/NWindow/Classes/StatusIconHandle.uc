/**
*스테이터스 아이콘에 대한 함수를 정의. 2차원배열처럼 스테이터스아이콘의 공간을 관리하면서 작동한다
*/
class StatusIconHandle extends WindowHandle
	native;

/**
* 행을추가한다.(버프보면 여러줄이지요?)
* 행을 추가하는 행동은 실제 공간을 확보하지는 않는다. 행에 열을 추가해야 비로소 공간이 확보된다

* @param
* void
*
* @return
* void

* @example
* var StatusIconHandle s_handle;
* s_handle = GetStatusIconHandle("AbnormalStatusWnd.StatusIcon"); //핸들을 가져온다
* s_handle.AddRow(); // 행을 추가한다.
*/
native final function AddRow();

/**
* 열을추가한다. (버프보면 여러칸이지요?) 이때 무조건 아이템을 같이 넣어줘야 하는데 아마도 이유없이 열을 늘리는 것을 방지하기 위함인듯한다.

* @param
* a_Row : 열을 추가할 행
* a_Info : 장착할 아이콘정보
*
* @return
* void

* @example
* var StatusIconHandle s_handle;
* var StatusIconInfo s_item;
* s_handle = GetStatusIconHandle("AbnormalStatusWnd.StatusIcon"); //핸들을 가져온다
* s_handle.AddRow(); //행을 추가한다(공간을 확보했다)
* s_handle.AddCol(0,s_item); // 확보된 공간에 열과 아이템을 추가한다.

*struct native constructive StatusIconInfo
*{
*	var string	Name;
*	var string	IconName;
*	var int		Size;
*	var string	Description;
*	var string  BackTex;

*	var int		RemainTime;
*	var ItemID	Id;
*	var int		Level;
	
*	var bool	bShow;
*	var bool	bShortItem;
*	var bool	bEtcItem;
*	var bool	bDeBuff;
*};
*/

native final function AddCol( int a_Row, StatusIconInfo a_Info );

/**
* 행을 지정한 행에 원래의 행들은 밀려난다.(버프보면 여러줄이지요?)
* 행을 추가하는 행동은 실제 공간을 확보하지는 않는다. 행에 열을 추가해야 비로소 공간이 확보된다

* @param
* a_Row : 행을 삽입할 위치
*
* @return
* void

* @example
* var StatusIconHandle s_handle;
* var StatusIconInfo s_item;
* s_handle = GetStatusIconHandle("AbnormalStatusWnd.StatusIcon"); //핸들을 가져온다
* s_handle.AddRow(); // 행을 추가한다.
* s_handle.AddCol(0,s_item); // 확보된 공간에 열과 아이템을 추가한다.
* s_InsertRow(0); //행을 삽입한다. 원래의 0행은 이제 1행이 되었다.
* s_Addcol(0,s_item); //삽입을 해보면 원래의 0행이 1행으로 밀려나고 0행에 아이템이 추가된다
*/
native final function InsertRow( int a_Row );

/**
* 열을 지정한 열에 추가한다. 원래의 열들은 밀려난다(버프보면 여러칸이지요?)

* @param
* a_Row : 지정할 행
* a_Col : 삽입할 열
* a_Info : 장착할 아이콘정보
*
* @return
* void

* @example
* var StatusIconHandle s_handle;
* var StatusIconInfo s_item;
* s_handle = GetStatusIconHandle("AbnormalStatusWnd.StatusIcon"); //핸들을 가져온다
* s_handle.AddRow(); // 행을 추가한다.
* s_handle.AddCol(0,s_item); // 확보된 공간에 열과 아이템을 추가한다.
* s_handle.InsertCol(0,0,s_item); // 열을 삽입한다. 원래의 아이템들은 밀려난다.

*struct native constructive StatusIconInfo
*{
*	var string	Name;
*	var string	IconName;
*	var int		Size;
*	var string	Description;
*	var string  BackTex;

*	var int		RemainTime;
*	var ItemID	Id;
*	var int		Level;
	
*	var bool	bShow;
*	var bool	bShortItem;
*	var bool	bEtcItem;
*	var bool	bDeBuff;
*};
*/

native final function InsertCol( int a_Row, int a_Col, StatusIconInfo a_Info );

/**
* 행수를 리턴한다 (버프보면 여러줄이지요?)


* @param
* void
*
* @return
* void

* @example
* var StatusIconHandle s_handle;
* var int rowcount;
* s_handle = GetStatusIconHandle("AbnormalStatusWnd.StatusIcon"); //핸들을 가져온다
* rowcount = s_handle.GetRowCount(); // 행수를 가져온다.
*/
native final function int GetRowCount();

/**
* 지정된 행의 열수를 리턴한다 (버프보면 여러칸이지요?)

* @param
* a_Row : 열수를 가져올 행
*
* @return
* void

* @example
* var StatusIconHandle s_handle;
* s_handle = GetStatusIconHandle("AbnormalStatusWnd.StatusIcon"); //핸들을 가져온다
* s_handle.GetRowCount(3); // 3행의 열수를 가져온다.
*/
native final function int GetColCount( int a_Row );

/**
* 지정된 행과열의 아이템을 리턴한다. (마치 2차원 배열처럼)

* @param
* a_Row : 행
* a_Col : 열
* a_Info : 아이템을 담을 변수
*
* @return
* void

* @example
* var StatusIconHandle s_handle;
* var StatusIconInfo s_item;
* s_handle = GetStatusIconHandle("AbnormalStatusWnd.StatusIcon"); //핸들을 가져온다
* s_handle.GetItem(0,0,s_item); // 0행 0열 의 아이템을 가져온다

*struct native constructive StatusIconInfo
*{
*	var string	Name;
*	var string	IconName;
*	var int		Size;
*	var string	Description;
*	var string  BackTex;

*	var int		RemainTime;
*	var ItemID	Id;
*	var int		Level;
	
*	var bool	bShow;
*	var bool	bShortItem;
*	var bool	bEtcItem;
*	var bool	bDeBuff;
*};
*/
native final function GetItem( int a_Row, int a_Col, out StatusIconInfo a_Info );

/**
* 지정된 행과열의 아이템을 설정한다. (마치 2차원 배열처럼)

* @param
* a_Row : 행
* a_Col : 열
* a_Info : 설정할 아이템
*
* @return
* void

* @example
* var StatusIconHandle s_handle;
* var StatusIconInfo s_item;
* s_handle = GetStatusIconHandle("AbnormalStatusWnd.StatusIcon"); //핸들을 가져온다
* s_handle.SetItem(0,0,s_item); // 0행 0열 의 아이템을 설정한다

*struct native constructive StatusIconInfo
*{
*	var string	Name;
*	var string	IconName;
*	var int		Size;
*	var string	Description;
*	var string  BackTex;

*	var int		RemainTime;
*	var ItemID	Id;
*	var int		Level;
	
*	var bool	bShow;
*	var bool	bShortItem;
*	var bool	bEtcItem;
*	var bool	bDeBuff;
*};
*/
native final function SetItem( int a_Row, int a_Col, StatusIconInfo a_Info );

/**
* 지정된 행과열의 아이템을 지운다. (마치 2차원 배열처럼)

* @param
* a_Row : 행
* a_Col : 열
*
* @return
* void

* @example
* var StatusIconHandle s_handle;
* s_handle = GetStatusIconHandle("AbnormalStatusWnd.StatusIcon"); //핸들을 가져온다
* s_handle.DelItem(0,0); // 0행 0열 의 아이템을 지운다
*/
native final function DelItem( int a_Row, int a_Col );

/**
* 아이콘의 사이즈를 조절한다.

* @param
* a_Size : 사이즈
*
* @return
* void

* @example
* var StatusIconHandle s_handle;
* s_handle = GetStatusIconHandle("AbnormalStatusWnd.StatusIcon"); //핸들을 가져온다
* s_handle.SetIconSize(30); // 아이콘 사이즈를 30으로 한다
*/
native final function SetIconSize( int a_Size );

/**
* 싹지우고 초기화한다

* @param
* void
*
* @return
* void

* @example
* var StatusIconHandle s_handle;
* s_handle = GetStatusIconHandle("AbnormalStatusWnd.StatusIcon"); //핸들을 가져온다
* s_handle.Clear(); 초기화 되었다.
*/
native final function Clear();
defaultproperties
{
}
