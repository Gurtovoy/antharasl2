/**
*에디트박스컨트롤에 대한 함수를 정의
*/
class EditBoxHandle extends WindowHandle
	native;

/**
* 에디트박스의 텍스트를 가져온다

* @param
* void

* @return
* string

* @example
*var EditBoxHandle e_handle; //윈도우 핸들 선언
*e_handle = GetEditBoxHandle( "ChatWnd.ChatEditBox" ); //핸들을 가져온다
*debug(e_handle.GetString()); //채팅창의 스트링을 찍어준다
*/
native final function string GetString();

/**
* 에디트박스의 텍스트를 설정한다

* @param
* str : 설정할 텍스트

* @return
* void

* @example
*var EditBoxHandle e_handle; //윈도우 핸들 선언
*e_handle = GetEditBoxHandle( "ChatWnd.ChatEditBox" ); //핸들을 가져온다
*e_handle.SetString("hihi"); //텍스트를 변경하였다.
*/
native final function SetString( string str );

/**
* 에디트박스의 텍스트를 덧붙인다

* @param
* str : 덧붙일 텍스트

* @return
* void

* @example
*var EditBoxHandle e_handle; //윈도우 핸들 선언
*e_handle = GetEditBoxHandle( "ChatWnd.ChatEditBox" ); //핸들을 가져온다
*e_handle.SetString("hihi"); //텍스트를 변경하였다.
*e_handle.AddString("hihi"); //텍스트를 덧붙였다. 이제 "hihihihi" 가 된다
*/
native final function AddString( string str );

/**
* 에디트박스의 텍스트를 한칸지운다

* @param
* void

* @return
* void

* @example
*var EditBoxHandle e_handle; //윈도우 핸들 선언
*e_handle = GetEditBoxHandle( "ChatWnd.ChatEditBox" ); //핸들을 가져온다
*e_handle.SetString("hihi"); //텍스트를 변경하였다. "hihi"가 된다
*e_handle.SimulateBackspace(); //한칸지웠다 "hih"가 된다
*/
native final function SimulateBackspace();

/**
* 에디트박스의 텍스트를 모두 지운다

* @param
* void

* @return
* void

* @example
*var EditBoxHandle e_handle; //윈도우 핸들 선언
*e_handle = GetEditBoxHandle( "ChatWnd.ChatEditBox" ); //핸들을 가져온다
*e_handle.SetString("hihi"); //텍스트를 변경하였다.
*e_handle.Clear(); //텍스트를 모두 지웠다
*/
native final function Clear();

/**
* 에디트박스의 타입을 변경한다

* @param
* Type : 타입 (normal, number, password)  가 있다
* normal : 일반모드
* number : 숫자만 입력됨
* password : 입력이 모두 * 로 표시됨

* @return
* void

* @example
*var EditBoxHandle e_handle; //윈도우 핸들 선언
*e_handle = GetEditBoxHandle( "ChatWnd.ChatEditBox"); //핸들을 가져온다
*e_handle.SetEditType("password"); //패스워드 타입으로 변경

*참고: 타입을 처리하는 cpp 부분
*if( Type == FString(TEXT("normal")) ) 
*	pWnd->SetType( NC_EDIT_DEFAULT);
*else if( Type == FString(TEXT("number")) )
*	pWnd->SetType( NC_EDIT_NUMBER );
*else if( Type == FString(TEXT("password")) )
*	pWnd->SetType( NC_EDIT_PASSWORD );
*/
native final function SetEditType( string Type );

/**
* 에디트박스에 하이라이트(색깔밝아짐) 효과를 주거나 취소한다

* @param
* bHighLight : true 면 효과줌, false면 취소

* @return
* void

* @example
*var EditBoxHandle e_handle; //윈도우 핸들 선언
*e_handle = GetEditBoxHandle( "ChatWnd.ChatEditBox" ); //핸들을 가져온다
*e_handle.SetHighLighting(true); //하이라이트 효과를 줌
*/
native final function SetHighLight( bool bHighlight);

/**
* 에디트박스의 텍스트의 길이를 제한한다.(한글,영어,숫자 모두 똑같이 1 캐릭터가 길이1이다)

* @param
* maxLength : 최대길이

* @return
* void

* @example
*var EditBoxHandle e_handle; //윈도우 핸들 선언
*e_handle = GetEditBoxHandle( "ChatWnd.ChatEditBox" ); //핸들을 가져온다
*e_handle.SetMaxLength(10); //10자로 제한
*/
native final function SetMaxLength( int maxLength );

/**
* 에디트박스의 텍스트의 최대길이를 리턴한다

* @param
* void

* @return
* int : 최대길이

* @example
*var EditBoxHandle e_handle; //윈도우 핸들 선언
*e_handle = GetEditBoxHandle( "ChatWnd.ChatEditBox" ); //핸들을 가져온다
*e_handle.SetMaxLength(10); //10자로 제한
*debug(string(e_handle.GetMaxLength())); // 10 이출력된다
*/
native final function int GetMaxLength();

/**
* 에디트박스의 텍스트의 링크기능을 부여하거나 제거한다

* @param
* bEnable

* @return
* void

* @example
*var EditBoxHandle e_handle; //윈도우 핸들 선언
*e_handle = GetEditBoxHandle( "ChatWnd.ChatEditBox" ); //핸들을 가져온다
*e_handle.SetEnableTextLink(true); //텍스트링크 가능
*/
native final function SetEnableTextLink( bool bEnable );
/**
* 에디트박스의 자동완성 히스토리를 제거한다.

* @param
* void

* @return
* void

* @example
*var EditBoxHandle e_handle; //윈도우 핸들 선언
*e_handle = GetEditBoxHandle( "ChatWnd.ChatEditBox" ); //핸들을 가져온다
*e_handle.ClearHistory(); //자동완성 히스토리를 삭제한다.
*/
native final function ClearHistory();
/**
* 에디트박스의 자동완성용 탐색 리스트에 이름을 추가한다.

* @param
* string

* @return
* bool

* @example
* var EditBoxHandle e_handle; //윈도우 핸들 선언
* var string name;
* e_handle = GetEditBoxHandle( "ChatWnd.ChatEditBox" ); //핸들을 가져온다
* e_handle.AddNameToAdditionalSearchList(name, type); //자동완성 친구 탐색 리스트에 이름을 추가한다.
*/

/**
* 에디트박스의 모든 텍스트를 선택한ㅌ다.

* @param
* void

* @return
* void

* @example
*var EditBoxHandle e_handle; //윈도우 핸들 선언
*e_handle = GetEditBoxHandle( "ChatWnd.ChatEditBox" ); //핸들을 가져온다
*e_handle.AllSelect(); //모든 텍스트를 선택하였다.
*/
native final function AllSelect();

native final function bool AddNameToAdditionalSearchList(string name, ESearchListType listType);
native final function bool FillAdditionalSearchList(out array<string> stringArr, ESearchListType listType);
native final function bool ClearAdditionalSearchList(ESearchListType listType);
native final function bool DeleteNameFromAdditionalSearchList(string name, ESearchListType listType);

native final function bool AddItemToAutoCompleteHistory(string name);
native final function SetDownList(bool bDownList);

native final function bool IsShowCandidateBox(); //branch121212

/**
 에디트 박스에 EnableCopyNPaste="event"로 설정시 Paste 동작을 수행하면 EV_Paste 이벤트가 발생한다.
 Paste 동작시 기존에 선택 중인 텍스트를 지우고 Clipboard의 텍스트로 채워야 한다.

 에디트 박스의 기본 Paste 동작 방식은 아래와 같다.
 string str = ClipboardPaste();
 if(Len(str) > 0)
 {
	 DeleteClipboard();
	 AddString(str);
 }
*/
native final function bool DeleteClipBoard();
defaultproperties
{
}
