/**
* 챗윈도우 핸들에 대한 함수를 정의한다. 보다시피 TextListBoxHandle를 상속받았으므로 TextListBoxHandle.uc의 함수를 지원한다

*/
class ChatWindowHandle extends TextListBoxHandle native;

/**
* 챗 윈도우의 텍스쳐를 보이게하거나 안보이게한다
* 지금의 챗팅창은 텍스쳐를 보이지 않게 되어있다. 챗윈도우에서 전체적으로 텍스쳐를 입히고
* 하위 컨트롤인 NormalChat 컨트롤에서는 그 텍스쳐가 보이지 않게 해주기 위해서이다

* @param
* bVlaue : true면 사용 false면 사용안함

* @return
* void

* @example
* var ChatWindowHandle c_handle;
* c_handle = GetChatWindowHandle( "ChatWnd.NormalChat" ); //핸들을 가져옴
* c_handle.EnableTexture(true); //텍스쳐를 보이게 해보자
*/
native final function EnableTexture( bool bValue );

/**
* 챗 윈도우가 스크롤 다운 가능한 상태인가?
* 채팅이 몇 개 없는 상태, 스크롤 끝까지 내린 상태는 false

* @param
* void

* @return
* bool

* @example
* var ChatWindowHandle c_handle;
* c_handle = GetChatWindowHandle( "ChatWnd.NormalChat" ); //핸들을 가져옴
* if( c_handle.ISScrollable() ) ...
*/
native final function bool ISScrollable();
defaultproperties
{
}
