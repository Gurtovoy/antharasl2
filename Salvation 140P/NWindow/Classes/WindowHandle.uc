/**
*윈도우에대한 함수를 정의한다(윈도우의 좌표에 관한 것들이 자주나오는데 주의할것은 좌표계가 흔히 생각하는 실수평면이 아니라 화면좌표계 라는 것이다. 즉 최좌상단 이 (0,0) 이가 증가방향은 오른쪽, 아래쪽이다)
*/

class WindowHandle extends UIEventManager
	native;

var Object m_pTargetWnd;
var string m_WindowNameWithFullPath;

/**
*윈도우의 타이틀을 변경한다.

* @param
*a_Title : 변경할 타이틀

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.SetWindowTitle("Sohee JJang!!"); // 윈도우의 타이틀을 변경한다.
*Hwnd_Party.ShowWindow();//윈도우를 보여준다
*/
native final function SetWindowTitle( String a_Title );

/**
*타이틀의 위치를 조정한다.

* @param
*OffsetX : X좌표(가로) 
*OffsetY : Y좌표(세로) 

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.SetTitlePosOffset(10,10); //타이틀의 위치를 조정한다.
*Hwnd_Party.ShowWindow();//윈도우를 보여준다
*/
native final function SetTitlePosOffset(int OffsetX, int OffsetY);

/**
*윈도우를 보여준다(반대:HideWindow())

* @param
*void

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.ShowWindow();//윈도우를 보여준다
*/
native final function ShowWindow();

/**
*윈도우를 숨긴다(반대:ShowWindow())

* @param
*void

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.HideWindow();//윈도우를 숨겨준다.
*/
native final function HideWindow();

/**
*윈도우의 Show 여부를 리턴한다.

* @param
*void

* @return
*bool : Show상태이면 true, Hide상태이면 false

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*if(Hwnd_Party.IsShowWindow()) Hwnd_Party.HideWindow();//윈도우가 보여지고있으면 윈도우를 숨겨준다
*else Hwnd_Party.ShowWindow(); //반대로 숨겨져 있다면 보여준다. 간단히 Toggle 기능이 구현된다.
*/
native final function bool IsShowWindow();

/**
*윈도우가 최소화 상태인지를 판단한다.

* @param
*void

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*if(Hwnd_Party.IsMinimizedWindow()) debug("minimized"); //윈도우가 최소화 상태라면 출력된다
*/
native final function bool IsMinimizedWindow();

/**
*윈도우의 이름을 리턴한다.

* @param
*void

* @return
*string : 윈도우의 이름

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*var string WndName;
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*WndName = Hwnd_Party.GetWindowName();//윈도우의 이름을 가져온다
*debug(WndName); //"PartyMatchWnd" 가 출력된다.
*/
native final function String GetWindowName();

/**
*부모윈도우의 이름을 리턴한다.

* @param
*void

* @return
*string : 부모 윈도우의 이름

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*var string WndName;
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*WndName = Hwnd_Party.GetParentWindowName();//부모 윈도우의 이름을 가져온다
*debug(WndName); //"Console"이 출력된다.
*/
native final function String GetParentWindowName();

/**
*부모 윈도우를 변경한다.

* @param
*a_hNeweParentWnd : 새로운 부모윈도우

* @return
*bool : 성공시 true, 실패시 false

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*var WindowHandle Hwnd_Party_Parent; //부모윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party_Parent = GetWindowHandle("ActionWnd"); // ActionWnd.uc로 만들어진 윈도우의 핸들을 가져온다.
*Hwnd_Party.ChangeParentWindow(Hwnd_Party_Parent); //partyMatchwnd의 Parent를 console에서 ActionWnd 로 변경한다.
*/
native final function bool ChangeParentWindow( WindowHandle a_hNewParentWnd );

/**
*부모 윈도우의 핸들을 리턴한다.

* @param
*void

* @return
*WindowHandle : 부모의 윈도우 핸들

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*var WindowHandle Hwnd_Party_Parent; //부모윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party_Parent = Hwnd_Party.GetParentWindowHandle(); // PartyMatchWnd의 부모핸들(console)을 가져온다.
*/
native final function WindowHandle GetParentWindowHandle();

/**
*자식 윈도우의 배열을 얻어온다.

* @param
*array<WindowHandle> : 자식들이 담길 윈도우 핸들 배열.

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*var array<WindowHandle> Hwnd_Party_Childs; //윈도우핸들 배열 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.GetChildWindowList(Hwnd_Party_Childs); //Hwnd_Party_Childs 에 자식 윈도우들이 담긴다.
*/
native final function GetChildWindowList( array<WindowHandle> a_ChildList );

/**
*자신이 파라미터 핸들윈도우의 자식윈도우 인지 여부를 리턴한다.

* @param
*WindowHandle a_hParentWnd : 부모로 의심되는 윈도우 핸들

* @return
*bool : 자식이 맞다면 true, 아니면 false

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*var WindowHandle Hwnd_Party_Parent; //부모윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party_Parent = GetWindowHandle("ActionWnd"); // ActionWnd.uc로 만들어진 윈도우의 핸들을 가져온다.
*if(Hwnd_Party.IsChildOf(Hwnd_Party_Parent)) debug("yes"); //출력되지 않는다.
*else debug("no"); //출력된다.
*/
native final function bool IsChildOf( WindowHandle a_hParentWnd );

/**
*최상위 프레임의 윈도우 핸들을 리턴한다.

* @param
*void

* @return
*WindowHandle : 최상위 프레임의 윈도우 핸들

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*var WindowHandle Hwnd_Party_Top;
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party_Top = Hwnd_Party.GetTopFrameWnd(); // PartyMatchWnd윈도우의 최상위 프레임 윈도우를 가져온다.
*debug(string(Hwnd_Party_Top)); //"Transient.WindowHandle911" 이 출력되었다. 이유는 차차 알아보자
*/
native final function WindowHandle GetTopFrameWnd();

/**
*윈도우의 알파값을 가져온다.

* @param
*void

* @return
*int : 윈도우의 알파값

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*var int Alpha; // 알파값을 담을 정수
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Alpha = Hwnd_Party.GetAlpha(); // 알파값을 가져온다.
*debug(string(Alpha)); //255(완전히 보임) 이 출력되었다.
*/
native final function int GetAlpha();

/**
*윈도우의 알파값을 지정한다.

* @param
*a_Alpha : 알파값
*a_Seconds(optional) : 몇초안에 변할것인가

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.SetAlpha(0); // 알파값을 0으로 바꾼다.
*Hwnd_Party.SetAlpha(255,10); // 알파값을 255로 10초만에 바꾼다.
*/
native final function SetAlpha( int a_Alpha, optional float a_Seconds );

/**
*윈도우의 UC 스크립트를 가져온다(UC파일이라기보다는 실제 바이너리지만 그냥 UC라고 생각하면 될듯하다)
*각각 윈도우의 UC 스크립트는 XML파일에 정의되어있다. 

* @param
*void

* @return
*UIScript : 윈도우의 UC 스크립트

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*var PartyMatchWnd Hwnd_Party_Script; //PartymatchWnd 스크립트를 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party_Script = PartyMatchWnd(Hwnd_Party.GetScript()); //스크립트를 가져온다. 캐스팅이 필요하다.
*Hwnd_Party_Script.HandlePartyToggle(); // PartymatchWnd 의 멤버함수의 사용이 가능하다.
*/
native final function UIScript GetScript();

/**
*윈도우의 UC 스크립트의 이름을 가져온다. 

* @param
*void

* @return
*string : UC 스크립트의 이름

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*var string ScriptName;
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*ScriptName = Hwnd_Party.GetScriptName(); //스크립트의 이름을 가져온다.
*/
native final function String GetScriptName();

//Style

/**
*윈도우가 Virtual 스타일(인풋 이벤트를 dispatch 할수없는, 그러나 child는 가능)인지 알아본다.

* @param
*void

* @return
*bool

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*if(Hwnd_Party.IsVirtual()) debug("virtual style"); //버추얼 스타일이면 출력
*else debug("Not Virtual style"); //버추얼 스타일이 아니면 출력
*/
native final function bool IsVirtual();

/**
*윈도우가 언제나 최상위에 있는지 알아본다. 

* @param
*void

* @return
*bool

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*if(Hwnd_Party.IsAlwaysOnTop()) debug("Top");
*else debug("No Top");
*/
native final function bool IsAlwaysOnTop();

/**
*윈도우가 언제나 제일 뒤에 있는지 알아본다. 

* @param
*void

* @return
*bool

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*if(Hwnd_Party.IsAlwaysOnBack()) debug("Back");
*else debug("No Back");
*/
native final function bool IsAlwaysOnBack();

/**
*윈도우의 폰트 색상을 정한다. 

* @param
*a_FontColor : 색상

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*var color TextColor;
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*TextColor= GetNumericColor("83,473"); 
*Hwnd_Party.SetFontColor( TextColor ); //색을 설정한다.
*/
native final function SetFontColor( color a_FontColor );

/**
*윈도우의 알파값을 언제나 최대로 한다. 혹은 해제한다.

* @param
*a_AlwaysFullAlpha : true면 알파값 최대. false 면 해제

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.SetAlwaysFullAlpha(true);
*/
native final function SetAlwaysFullAlpha(bool a_AlwaysFullAlpha);

/**
*윈도우를 모달윈도우(윈도우 활성화시 부모윈도우로의 입력을 막는다)로 하거나 해제한다.

* @param
*a_Modal : true면 설정. false 면 해제

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.SetModal(true);// 모달형태의 윈도우로 한다.
*/
native final function SetModal(bool a_Modal);

//Size&Position

/**
*윈도우의 사이즈를 Rect형태로 리턴한다.

* @param
*void

* @return
*Rect : 윈도우의 사이즈를 지닌 Rect

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Rect WindowRect;
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*WindowRect = Hwnd_Party.GetRect();
*/
native final function Rect GetRect();

/**
*윈도우의 사이즈를 증가시킨다.

* @param
*a_DeltaWidth : 넓이조정값 
*a_DeltaHeight : 상하조정값

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*HWnd_Party.AddWindowSize(10,10); // 10,10 만큼 윈도우 사이즈가 증가한다.
*/
native final function AddWindowSize( int a_DeltaWidth, int a_DeltaHeight );

/**
*윈도우의 사이즈를 변경한다.

* @param
*a_Width : 넓이값
*a_Height : 높이값

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*HWnd_Party.SetWindowSize(10,10); // 10,10크기로 윈도우를 변경한다.
*/
native final function SetWindowSize( int a_Width, int a_Height );

/**
*윈도우의 사이즈를 알아낸다.

* @param
*a_Width : 넓이값이 저장될 변수
*a_Height : 높이값이 저장될 변수

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*var int w;
*var int h;
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*HWnd_Party.GetWindowSize(w,h); // 윈도우의 사이즈를 알아낸다.
*/
native final function GetWindowSize( out int a_Width, out int a_Height );

/**
*윈도우의 사이즈를 상대적으로 변경한다. (잘 모름 실제로는 SetWindowSizeRel43 의 래퍼이더군요)

* @param
*fWidthRate : 넓이 비율
*fHeightRate : 높이 비율
*nOffsetWidth : ??? 아시는분 연락좀
*nOffsetHeight : ??? 아시는분 연락좀

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*HWnd_Party.SetWindowSizeRel(0.5,0.5,0,0); //오프셋은 무엇일까요??? 아시는분 연락좀
*/
native final function SetWindowSizeRel( float fWidthRate, float fHeightRate, int nOffsetWidth, int nOffsetHeight );

/**
*윈도우의 상대적인 크기비율을 알아낸다.(잘 모름)

* @param
*fWidthRate : 넓이 비율
*fHeightRate : 높이 비율
*nOffsetWidth : ??? 아시는분 연락좀
*nOffsetHeight : ??? 아시는분 연락좀

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*var float fw;
*var float fh;
*var int w;
*var int h;
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*HWnd_Party.GetWindowSizeRel(fw,fh,w,h); // 구현이 덜된듯 합니다. 0.0, 0.0, 0, 0 이 나오더군요 
*/
native final function GetWindowSizeRel( out float fWidthRate, out float fHeightRate, out int nOffsetWidth, out int nOffsetHeight );

/**
*윈도우의 사이즈를 상대적으로 변경한다. (잘 모름)

* @param
*fWidthRate : 넓이 비율
*fHeightRate : 높이 비율
*nOffsetWidth : ??? 아시는분 연락좀
*nOffsetHeight : ??? 아시는분 연락좀

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*HWnd_Party.SetWindowSizeRel43(0.5,0.5,0,0); // 반으로 줄듯하지만 반으로 줄지 않더군요
*/
native final function SetWindowSizeRel43( float fWidthRate, float fHeightRate, int nOffsetWidth, int nOffsetHeight);	//solasys

/**
*윈도우의 사이즈가 상대모드인지를 판단한다.

* @param
*void

* @return
*bool : 상대모드이면 true 아니면 false

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*var bool IsRelative;
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*IsRelative = Hwnd_Party.IsRelativeSize(); // 상대크기인지 알아낸다
*/
native final function bool IsRelativeSize();

/**
*윈도우를 변화량 만큼 이동시킨다.

* @param
*a_nDeltaX : X방향 변화량
*a_nDeltaY : Y방향 변화량
*a_Seconds(optional) : 이동할 시간

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.Move(10,10); // 오른쪽으로 10 아래로 10 만큼 이동한다.
*Hwnd_Party.Move(10,10, 10); // 오른쪽으로 10 아래로 10 만큼 10초간 이동한다.
*/
native final function Move( int a_nDeltaX, int a_nDeltaY, optional float a_Seconds );

/**
*윈도우를 지정된 좌표로 이동시킨다.

* @param
*a_nDeltaX : X좌표
*a_nDeltaY : Y좌표
*a_Seconds(optional) : 이동할 시간

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.MoveTo(10,10); // (10,10) 의 위치로 윈도우를 이동한다.
*/
native final function MoveTo( int a_nX, int a_nY );

/**
*윈도우를 현재위치에서 이동시킨다.

* @param
*a_nX : X좌표 변화량
*a_nY : Y좌표 변화량

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.MoveTo(10,10); // 현재위치에서(10,10)만큼 윈도우를 이동한다.
*/
native final function MoveEx( int a_nX, int a_nY );

native final function MoveC( int a_nX, int a_nY ); //branch121212

/**
*윈도우를 현재위치에서 주어진 시간동안 이동시킨다.

* @param
*a_nX : X좌표 변화량
*a_nY : Y좌표 변화량
*a_Seconds : 이동할 시간

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.MoveEx(10,10,10); // 현재위치에서(10,10)만큼 윈도우를 10초간 이동한다.
*/
native final function MoveExWithTime( int a_nX, int a_nY, float a_Seconds );

/**
*윈도우를 랜덤한 방향(8방위)으로 이동시킨다(함수이름은 마치 흔들듯 하지만 아니다. 이함수를 연속으로 호출하면 흔들는 듯한 효과가 난다)
*바운더리 개념이 없어서 계속 흔들다보면 멀어져가는 윈도우를 볼수 있다.(추가하면 좋을듯)

* @param
*a_nRange : 움직일 거리
*a_nSet : 0을 넣어야 랜덤하게 움직인다. 다른수를 넣으면 무조건 위로 움직인다(왜 있는지 잘모르겠..)
*a_Seconds(optional) : 움직일 시간

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.MoveShake(10,0,0.1); // 10만큼 윈도우를 0.1초만에 랜덤하게 이동시킨다.
*/
native final function MoveShake( int a_nRange, int a_nSet, optional float a_Seconds );	//solasys

// Tick
/**
*윈도우가 Tick에 반응하게 만든다.

* @param
*void

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.EnableTick(); // Tick에 반응한다. 따라서 PatcyMatchWnd.uc 에 Ontick함수를 정의하면 Tick마다 실행된다.
*/
native final function EnableTick();

/**
*윈도우가 Tick에 반응하지 않게 만든다.

* @param
*void

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.EnableTick(); // Tick에 반응하지 않는다. 따라서 PatcyMatchWnd.uc 에 Ontick함수를 정의해도 무시된다.
*/
native final function DisableTick();

//Anchor

/**
*윈도우에 Anchor를 설정한다.(즉 언제나 붙어다니는 윈도우를 설정한다)
*주의할점은 두 윈도우 모두 Show 된 상태에서만 적용이 된다는 것이다. 따라서 먼저 show를 해주고 anchor를 설정하자

* @param
*AnchorWindowName : 자신을 따라다닐 윈도우의 이름
*RelativePoint : 자신을 따라다닐 윈도우의 접점 포인트
*AnchorPoint : 자신의 Anchor(접점)포인트
*offsetX : RelativePoint 에서 Anchor포인트로의 X방향 offset
*offsetY : RelativePoint 에서 Anchor포인트로의 Y방향 offset

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*var WindowHandle Hwnd_Party2; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party2 = GetWindowHandle("InventoryWnd"); // Inventory.uc로 만들어진 윈도우의 핸들을 가져온다.
*Hwnd_Party.ShowWindow();
*Hwnd_Party2.ShowWindow();
*Hwnd_Party.SetAnchor("InventoryWnd", "TopLeft", "BottomRight", 100,0); //파티윈도우의 오른쪽 아래와 인벤윈도우의 왼쪽위가 접점이 되어 붙는다. 인벤윈도우의 왼쪽위에서 X방향으로 100만큼 간 곳에 붙는다
*/
native final function SetAnchor( string AnchorWindowName, string RelativePoint, string AnchorPoint, int offsetX, int offsetY );

/**
*윈도우에 Anchor를 해제한다.

* @param
*void

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*var WindowHandle Hwnd_Party2; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party2 = GetWindowHandle("InventoryWnd"); // Inventory.uc로 만들어진 윈도우의 핸들을 가져온다.
*Hwnd_Party.ShowWindow();
*Hwnd_Party2.ShowWindow();
*Hwnd_Party.SetAnchor("InventoryWnd", "TopLeft", "BottomRight", 100,0); //파티윈도우의 오른쪽 아래와 인벤윈도우의 왼쪽위가 접점이 되어 붙는다. 인벤윈도우의 왼쪽위에서 X방향으로 100만큼 간 곳에 붙는다
*Hwnd_Party.ClearAnchor(); //엥커가 해제되었다
*/
native final function ClearAnchor();

/**
*윈도우에 Anchor가 있는지 여부를 리턴한다.

* @param
*void

* @return
*bool : Anchor가 있으면 true 없으면 false

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*var WindowHandle Hwnd_Party2; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party2 = GetWindowHandle("InventoryWnd"); // Inventory.uc로 만들어진 윈도우의 핸들을 가져온다.
*Hwnd_Party.ShowWindow();
*Hwnd_Party2.ShowWindow();
*Hwnd_Party.SetAnchor("InventoryWnd", "TopLeft", "BottomRight", 100,0); //파티윈도우의 오른쪽 아래와 인벤윈도우의 왼쪽위가 접점이 되어 붙는다. 인벤윈도우의 왼쪽위에서 X방향으로 100만큼 간 곳에 붙는다
*debug(string(Hwnd_Party.IsAnchored())); // PartyMatchWnd는 엥커가 있으므로 true 가 출력된다
*debug(string(Hwnd_Party2.IsAnchored())); // InventoryWnd는 엥커를 당한것 뿐이므로 false가 출력된다.
*/
native final function bool IsAnchored();

//Draggable

/**
*윈도우가 드래그 가능한지 알아본다.

* @param
*void

* @return
*bool : 드래그 가능하면 true 아니면 false

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*var bool draggable;
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*draggable = Hwnd_Party.IsDraggable();
*/
native final function bool IsDraggable();

/**
*윈도우가 드래그 가능하도록(혹은 불가능하도록)한다 (구현이 안된듯하다)

* @param
*a_Draggable : true면 드래그 가능 false면 불가능

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.SetDraggable(true); //드래그 가능
*Hwnd_Party.SetDraggable(false); //드래그 불가능
*/
native final function SetDraggable( bool a_Draggable );

// Style
/**
*윈도우가 stuck(다른 윈도우 곁에 달라붙는것)이 가능하도록(혹은 불가능하도록)한다 
*stuckable 한 윈도우끼리는 곁에 가면 달라붙는다

* @param
*a_Stuckable : true면 stuck 가능 false면 불가능

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.SetStuckable(true); //Stuck 가능
*Hwnd_Party.SetStuckable(false); //Stuck 불가능
*/
native final function SetStuckable(bool a_Stuckable);

//VirtualDrag, ttmayrin
/**
*윈도우가 VirtualDrag(VirtualBox를 표시하면서, 윈도우를 Drag&Drop시킬 수 있다.)한지를 리턴한다.
*구현이 되었는지 모르겠다. window의 style인 NWS_VIRTUALDRAG가 코드에서 사용되지 않았다.
* @param
*void 

* @return
*bool : true면 VirtualDrag 가능 false면 불가능

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*var VDrag;
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*VDrag = Hwnd_Party.IsVirtualDrag();
*/
native final function bool IsVirtualDrag();

/**
*윈도우가 VirtualDrag(VirtualBox를 표시하면서, 윈도우를 Drag&Drop시킬 수 있다.)하거나 안하도록 설정한다.
*구현이 되었는지 모르겠다. window의 style인 NWS_VIRTUALDRAG가 코드에서 사용되지 않았다.
* @param
*a_bFlag : true면 설정 false면 해제

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.SetVirtualDrag(true); // virtualdraggable 설정
*Hwnd_Party.SetVirtualDrag(false); // virtualdraggable 해제
*/
native final function SetVirtualDrag( bool a_bFlag );

/**
*윈도우가 드래그오버 될때(윈도우에 드래그 되어 들어올때)의 텍스쳐를 설정한다.
* @param
*a_TextureName : 텍스쳐 이름

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.SetDragOverTexture( "L2UI_CT1.ListCtrl.ListCtrl_DF_HighLight" ); //텍스쳐를 설정한다
*/
native final function SetDragOverTexture( string a_TextureName );

//Enable&Disable

/**
*윈도우를 Enable상태로 한다. 
* @param
*void

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.EnableWindow();
*/

native final function EnableWindow();

/**
*윈도우를 Disable상태로 한다.
* @param
*void

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.DisableWindow();
*/
native final function DisableWindow();

/**
*윈도우를 Enable상태를 리턴한다.
* @param
*void

* @return
*bool : Enable 이면 true Disable 이면 false

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*if (Hwnd_Party.IsEnableWindow()) debug("Enabled window"); //Enable 상태를 판단해 출력한다.
*else debug("Disabled window");
*/
native final function bool IsEnableWindow();

//Focus
/**
*윈도우에 포커스를 맞춘다.(활성화, 입력대기 상태가 된다)
* @param
*void

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.ShowWindow();
*Hwnd_Party.SetFocus(); //포커스를 맞춘다.
*/
native final function SetFocus();

/**
*윈도우의 포커스 여부를 리턴한다.
* @param
*void

* @return
*bool : 포커싱되어있으면 true 아니면 false

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.ShowWindow();
*Hwnd_Party.SetFocus(); //포커스를 맞춘다.
*if(Hwnd_Party.IsFoucus()) debug("Focused");
*else debug("Defocused");
*/
native final function bool IsFocused();

/**
*윈도우의 포커스를 해제한다.
* @param
*void

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.ShowWindow();
*Hwnd_Party.SetFocus(); //포커스를 맞춘다.
*Hwnd_Party.ReleaseFocus(); //포커스를 맞춘다.
*/
native final function ReleaseFocus();

// 창 순서를 맨 앞으로 가져온다
native final function BringToFront();


//Timer

/**
*윈도우에 타이머를 설정한다.
* @param
*a_TimerID : 타이머의 아이디
*a_DelayMiliseconds : 설정될 딜레이 (1/1000 초)

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.SetTimer(1,1000); //ID=1, 딜레이=1초 로 타이머를 셋팅한다.

*function OnTimer(int TimerID) //OnTiemr 함수에서 타이머를 잡아준다.
*{
*	if(TimerID == 1) //위에서 ID가 1이었으므로
*	{
		debug("Tiemr 1 has expired"); //원하는 행동을 취한다
*	}
*}
*/
native final function SetTimer( int a_TimerID, int a_DelayMiliseconds );

/**
*윈도우에 타이머를 해제한다.
* @param
*a_TimerID : 타이머의 아이디

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.SetTimer(1,1000); //ID=1, 딜레이=1초 로 타이머를 셋팅한다.

*function OnTimer(int TimerID) //OnTiemr 함수에서 타이머를 잡아준다.
*{
*	if(TimerID == 1) //위에서 ID가 1이었으므로
*	{
		debug("Tiemr 1 has expired"); //원하는 행동을 취한다
		Hwnd_Party.KillTimer(1); // 타이머를 해제한다. 따라서 1번 타이머는 1회만 반응하고 해제된다
*	}
*}
*/
native final function KillTimer( int a_TimerID );

/**
*최소화된 윈도우 아이콘을 깜박이게 해준다.
* @param
*void

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.SetTimer(1,1000); //ID=1, 딜레이=1초 로 타이머를 셋팅한다.

*function OnTimer(int TimerID) //OnTiemr 함수에서 타이머를 잡아준다.
*{
*	if(TimerID == 1) //위에서 ID가 1이었으므로
*	{
		Hwnd_Party.NotifyAlarm(); // 최소화 되어있다면 깜박이게 한다.
*	}
*}
*/
native final function NotifyAlarm();

//Tooltip

/**
*윈도우 툴팁의 텍스트를 설정한다.
* @param
*Text : 텍스트

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.SetToolTipText("This is PartymatchWnd");
*/
native final function SetTooltipText( string Text );

/**
*윈도우 툴팁의 텍스트를 리턴한다.
* @param
*void

* @return
*string : 윈도우의 툴팁 텍스트

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*var string ToolTipTxt;
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.SetToolTipText("This is PartymatchWnd");
*ToolTipTxt = Hwnd_party.GetToolTipText();
*/
native final function string GetTooltipText();

/**
*윈도우 툴팁의 타입을 정한다.
* @param
*ToolTipType : 툴팁의 타입

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.SetToolTipType("PartyMatchWnd");
*/
native final function SetTooltipType( string TooltipType );

/**
*윈도우 툴팁에 커스텀타입을 적용한다.
* @param
*Info : 적용할 커스텀타입

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*var string ToolTipTxt;
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.SetTooltipCustomType(MakeTooltipSimpleText("")); //커스텀 타입중 심플텍스트를 적용한다.
*/
native final function SetTooltipCustomType( CustomTooltip Info );

/**
*윈도우 툴팁의 커스텀타입을 얻어온다.
* @param
*Info : 커스텀타입 저장할 변수

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*var CustomToolTip info;
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.SetTooltipCustomType(MakeTooltipSimpleText(""));//커스텀 타입중 심플텍스트를 적용한다.
*Hwnd_Party.GetToolTipCustomType(info);//심플텍스트 타입을 info에 얻어온다
*/
native final function GetTooltipCustomType( out CustomTooltip Info );


native final function ClearTooltip();
native final function ClearAllChildShortcutItemTooltip();
//Frame

/**
*윈도우 프레임의 크기를 조정한다.
* @param
*nWindth : 넓이
*nHeight : 높이

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd"); // PartyMatchWnd 윈도우의 핸들을 가져온다.
*Hwnd_Party.SetFrameSize(100,100); //프레임 사이즈를 변경하였다
*/
native final function SetFrameSize(int nWidth, int nHeight);
native final function SetResizeFrameSize(int nWidth, int nHeight);

//Scroll

/**
*윈도우 스크롤바의 위치를 지정해준다
* @param
*X : 스크롤바컨트롤 위치의 x좌표
*Y : 스크롤바컨트롤 위치의 y좌표
*HeightOffset : 스크롤내의 스크롤이 차지하는 크기를 의미한다. 0으로하면 스크롤은 크기를 차지하지 않는다.

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("InventoryWnd.InventoryItem");
*Hwnd_Party.SetScrollBarPosition(0,50,0);//인벤토리의 아이템스크롤바의 위치를 수정해보았다. 내려간것을 확인해 볼수있다
*/
native function SetScrollBarPosition(int X, int Y, int HeightOffset);

/**
*윈도우 스크롤바내의 스크롤의 위치를 지정해준다
* @param
*pos : 스크롤의 위치


* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("InventoryWnd.InventoryItem");
*Hwnd_Party.SetScrollPosition(0);//인벤토리의 스크롤바내의 스크롤의 위치를 초기화 하였다.
*/
native final function SetScrollPosition(int pos);

/**
*윈도우 스크롤바내의 스크롤의 크기를 지정해준다
* @param
*Height : 크기


* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("InventoryWnd.InventoryItem");
*Hwnd_Party.SetScrollHeight(1000);//인벤토리의 스크롤바내의 스크롤의 크기를 변경하였다.
*/
native final function SetScrollHeight(int Height);

//branch121212
/**
*윈도우 스크롤바내의 스크롤의 오프셋의 위치를 불러준다
* @param
*Height : 크기


* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("InventoryWnd.InventoryItem");
*Hwnd_Party.GetScrollHeight();//현재 스크롤바위치를 가져온다
*/

native final function int GetScrollHeight(); 
/**
*윈도우 스크롤바내의 스크롤의 한번 이동값 수정
* @param
*Height : 크기


* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("InventoryWnd.InventoryItem");
*Hwnd_Party.SetScrollUnit(1000);//스크롤바의 한번 이동값 수정
*/

native final function SetScrollUnit(int Unit, bool clear); 
//end of branch

/**
*부모를 움직여도 자식윈도우는 영향을 받지않도록 한다.ex)Split된 챗윈도우를 리사이즈 할때 안되게함
* @param
*bFlag : true면 고정 false면 해제


* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd");
*Hwnd_Party.SetSettledWnd(true);
*/
native final function SetSettledWnd( bool bFlag );

/**
*윈도우를 회전시킨다? (구현이 잘못됬다. 실행하면 러닝타임 에러가 발생)
* @param
*bWithCapture(optional) : 
*RotationTime(optional) :
*direction(optional) :
*BeginAlpha(optional) :
*EndAlpha(optional) :
*bCW(optional) :
*RotationConstant(optional) :


* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd");
*Hwnd_Party.Rotate(); //에러발생
*/
native final function Rotate(optional bool bWithCapture, optional INT RotationTime, optional vector direction, optional INT BeginAlpha, optional INT EndAlpha, optional bool bCW, optional float RotationConstant);

/**
*윈도우를 회전을 중지시킨다 (사용된 부분이없음)
* @param
*void

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd");
*Hwnd_Party.ClearRotation(); //회전을 정지시킨다.
*/
native final function ClearRotation();

/**
*InitRotation중이라면 true 아니면 false (사용된적 없음)
* @param
*void

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd");
*Hwnd_Party.IsFront(); //윈도우 프레임의 m_bFront멤버를 리턴한다.
*/

native final function IsFront();
/**
*윈도우를 회전시킬듯 하지만 시키지 않는다. 짜다 만듯. 왜그런지 알아볼 필요가 있다.(사용된적 없음)
* @param
*void

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd");
*Hwnd_Party.InitRotation();
*/
native final function InitRotation();

// For UIEditor

/**
*윈도우를 회전시킬듯 하지만 시키지 않는다. 짜다 만듯. 왜그런지 알아볼 필요가 있다.(사용된적 없음)
* @param
*void

* @return
*void

* @example
*var WindowHandle Hwnd_Party; //윈도우 핸들 선언
*Hwnd_Party = GetWindowHandle("PartyMatchWnd");
*Hwnd_Party.InitRotation();
*/
native final function SetEditable( bool bEnable );

native final function WindowHandle AddChildWnd( EXMLControlType ChildType );
native final function String GetClassName();
native final function DeleteChildWnd( string ChildName );
native final function SetBackTexture( string TextureName );
native final function SetScript( string ScriptName );
native final function bool IsControlContainer();
native final function EXMLControlType GetControlType();
native final function WindowHandle LoadXMLWindow( string FilePathName );
native final function bool SaveXMLWindow( string FilePathName );
native final function GetXMLDocumentInfo( out string Comment, out string NameSpace, out string XSI, out string SchemaLocation );
native final function SetXMLDocumentInfo( string Comment, string NameSpace, string XSI, string SchemaLocation );
native final function ConvertToEditable();
native final function bool MakeBaseUC( string UCName, string FilePathName );
native final function ChangeControlOrder( EControlOrderWay WayType );
native final function EnterState();
native final function ExitState();
native final function bool IsCurrentState();

native final function SetShowAndHideAnimType( bool bShow, int Direction, float Time );

//branch120516
native final function SetTooltipCalculateSize(int MinimumWidth);
native final function InsertTooltipDrawItem(DrawItemInfo infDrawItem);
native final function WindowHandle GetChildWindow(string ChildName); //Hwnd_Party_Childs 에 자식 윈도우를 가져온다
//end of branch


/**
* 마우스를 올렸을 때에만 텍스쳐를 보이게 하는 기능

* @param
* bEnableue : true 면 마우스오버 아닐 때 투명도 사용
* Alpha : 0 ~ 255

* @return
* void

* @example
* var ChatWindowHandle c_handle;
* c_handle = GetChatWindowHandle( "ChatWnd.NormalChat" ); //핸들을 가져옴
*
* // 평소엔 Alpha=50, 마우스 오버 시에 255로(3초에걸쳐서) 보이게 하고 싶으면
* c_handle.EnableDynamicAlpha(true);
* onMouseOver( WindowHandle w )
* {
*     c_handle.SetAlpha(255, 3.0);
* }
* onMouseOut( WindowHandle w )
* {
*     c_handle.SetAlpha(50, 3.0);
* }
*/
native final function EnableDynamicAlpha( bool bEnable );

/**
* SetWindowSize 시에 이 함수를 호출하여 리사이즈의 기준점을 삼도록 한다.
* 기준점으로부터 MaxIncrease 만큼 리사이즈 가능하게 된다.

* @param
* StartWidth, StartHeight : 기준점의 width, height

* @return
* void

* @example
* var ChatWindowHandle c_handle;
* c_handle = GetWindowHandle( "ChatWnd" ); //핸들을 가져옴
* c_handle.SetResizeFrameOffset(348, 150);
*/
native final function SetResizeFrameOffset( int StartWidth, int StartHeight );

/**
* 현재 Window를 Scene Play 중에 보이게 할지 설정.

* @param
* bShowDuringScene : Scene Play 중에 보여줄 것인가

* @return
* void

*/
native final function SetCanBeShownDuringScene(bool bCanBeShownDuringScene);

/**
* 현재 Window가 무조건 Show 상태를 유지해야되는가?

* @param
* bValue : Show 상태 유지 할 것인가?

* @return
* void

*/
native final function SetUnConditionalShow(bool bValue);

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
defaultproperties
{
}
