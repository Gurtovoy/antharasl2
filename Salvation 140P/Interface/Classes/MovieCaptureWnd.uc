class MovieCaptureWnd extends UICommonAPI;//ldw 동영상 캡쳐 용

/*
 *2010.10월 제작
 *적용 파일 MovieCaptureWnd.xml
 *관련 파일 MovieCapture_Expand.uc, MovieCaptureWnd_Expand.xml
 *오브젝트 설명
	aBtn : 캡쳐 시작 버튼
	bBtn : 폴더 열기 버튼
	cBtn : 캡쳐 중지 버튼
	ComboBox1 : 해상도 콤보 박스 기본 값은 640*480
*/


var WindowHandle Me;
var WindowHandle m_hExpandWnd;
var ComboBoxHandle ComboBox1;
//var ComboBoxHandle ComboBox2;//품질이 생기면 관련 내용을 풀어 줄 것.
//var TextBoxHandle NCTextBox1;
//var TextBoxHandle NCTextBox2;
var ButtonHandle aBtn;
var ButtonHandle bBtn;
var ButtonHandle CloseButton;
var TextureHandle backgroundtex1;
var TextBoxHandle NCTextBox;


const DIALOGID_OpenFolder = 7063;//다이얼 로그 폴더 열기
const DIALOGID_Diskisfull = 7064;//다이얼 로그 꽉 찬 디스크 


var Array<int>  ResolutionW; //캡쳐 W 셋팅[640, 480]
var Array<int>  ResolutionH; //캡쳐 H 셋팅[480, 320] 480*320으로 바꿈 2011-03-10
//var Array<string>  Quality; //캡쳐 Q 셋팅[High, Low]

//var bool IsCapturingFlag;//캡쳐 되고 있는가? IsNowMovieCapturing()로 대체 할 것.

function OnLoad()
{
	if(CREATE_ON_DEMAND==0)//과거에 불려 졌었는가?
	{
		OnRegisterEvent();
	}
	Initialize();
	Load();
}

function OnRegisterEvent()
{
	RegisterEvent(EV_MovieCaptureStarted);//캡쳐가 시작 되었음
	RegisterEvent(EV_MovieCaptureEnded);//캡쳐가 시작 되었음
	RegisterEvent(EV_MovieCaptureFailDiskSpace);//용량 부족으로 캡쳐 시작 실패 혹은 캡쳐 도중 중단
	registerEvent(EV_DialogOK);//DialogOK 이벤트
	registerEvent(EV_DialogCancel);//DiaglogCancel 이벤트
	RegisterEvent( EV_Restart );//Restart 이벤트
}



function Initialize()
{	
	Me = GetWindowHandle( "MovieCaptureWnd" );
	m_hExpandWnd = GetWindowHandle( "MovieCaptureWnd_Expand" );
	ComboBox1 = GetComboBoxHandle( "MovieCaptureWnd.ComboBox1" );
	//ComboBox2 = GetComboBoxHandle( "MovieCaptureWnd.ComboBox2" );
	//NCTextBox1 = GetTextBoxHandle( "MovieCaptureWnd.NCTextBox1" );
	//NCTextBox2 = GetTextBoxHandle( "MovieCaptureWnd.NCTextBox2" );
	CloseButton = GetButtonHandle( "MovieCaptureWnd.CloseButton" );
	aBtn = GetButtonHandle( "MovieCaptureWnd.aBtn" );
	bBtn = GetButtonHandle( "MovieCaptureWnd.bBtn" );
	//cBtn = GetButtonHandle( "MovieCaptureWnd_Expand.cBtn" );
	backgroundtex1 = GetTextureHandle( "MovieCaptureWnd.backgroundtex1" );
	NCTextBox = GetTextBoxHandle( "MovieCaptureWnd.NCTextBox" );
}
////////////GetDisplayWidth, GetDisplayHeight 가 안되서 임시 사용
/*function int GetDisplayWidt(){
	return 1280;	
}
function int GetDisplayHeigh(){		
	return 1024;
}*/

function Load()
{	
	//IsCapturingFlag = false;	
	local string Resolution1;
	local string Resolution2;

	ResolutionW[0] = GetDisplayWidth();	
	ResolutionH[0] = GetDisplayHeight();
	ResolutionW[1] = ResolutionW[0]/2;
	ResolutionH[1] = ResolutionH[0]/2;

	ResolutionW[2] = 640;
	ResolutionH[2] = 480;

	ResolutionW[3] = 480;
	ResolutionH[3] = 320;

	SetMovieCaptureHighQuality();//셑잉하고 default = "High"시작 하자.
	SetMovieCaptureResolution(640, 480);//셑잉하고 default = "640*480" 시작 하자.	


	class'UIAPI_COMBOBOX'.static.AddString( "MovieCaptureWnd.ComboBox1",GetSystemString(2452));//현재 해상도
	class'UIAPI_COMBOBOX'.static.AddString( "MovieCaptureWnd.ComboBox1",GetSystemString(2453));//절반 해상도 

	Resolution1 = String(ResolutionW[2])$"X"$String(ResolutionH[2]);
	Resolution2 = String(ResolutionW[3])$"X"$String(ResolutionH[3]);	
	class'UIAPI_COMBOBOX'.static.AddString( "MovieCaptureWnd.ComboBox1",Resolution1);//640X480
	class'UIAPI_COMBOBOX'.static.AddString( "MovieCaptureWnd.ComboBox1",Resolution2);//480X320 
	
	//class'UIAPI_COMBOBOX'.static.AddString( "comboBox1",GetSystemString(2454));//640X480
	//class'UIAPI_COMBOBOX'.static.AddString( "comboBox1",GetSystemString(2455));//320X240
	class'UIAPI_COMBOBOX'.static.SetSelectedNum( "MovieCaptureWnd.ComboBox1", 2);//해상도 세팅 d=640*480	
}

function OnClickButton( string Name )
{
	switch( Name )
	{
	case "aBtn":
		if(!IsNowMovieCapturing()){//녹화 되지 않을 경우			
			MovieCaptureToggle();
		}
		break;
	case "bBtn":	//폴더 열기
		//Debug("저장 폴더 열기");
		OpenTheFolder();
		break;
	case "CloseButton":
		Me.HideWindow();
	}
}

function HandleDialogOK()
{
	local int dialogID;
	if(DialogIsMine())
	{
		dialogID = DialogGetID();
		switch (dialogID){
		case DIALOGID_OpenFolder:
			OpenMovieCaptureDir();
			break;
		case DIALOGID_Diskisfull:			
			break;
		}
	}
}

function OpenTheFolder()
{
	DialogSetID( DIALOGID_OpenFolder );
	DialogShow( DialogModalType_Modalless, DialogType_OKCancel, GetSystemMessage( 3312 ), string(Self) );//메시지받아서 처리 할 것
}

function DiskFullMessage()
{
	local string msg;
	msg = MakeFullSystemMsg(GetSystemMessage(3310), GetL2Path()$"/screenshot");
	DialogSetID( DIALOGID_Diskisfull );	
	//DialogShow( DialogModalType_Modalless, DialogType_OK, GetSystemMessage( 3310 ), string(Self) );//메시지받아서 처리 할 것
	DialogShow( DialogModalType_Modalless, DialogType_OK, msg, string(Self) );//메시지받아서 처리 할 것
}


function OnComboBoxItemSelected( string sName, int index )
{
	//Debug("index="$index);
	switch (sName){
		case "ComboBox1": //해상도
			//Debug("해상도 세팅"$(index)$" "$ResolutionW[index]$", "$ResolutionH[index]);
			SetMovieCaptureResolution(ResolutionW[index], ResolutionH[index]);//해상도를 추가 하거나 수정 해야 한다면 onLoad에서 수정 할 것
			break;
		/*case "ComboBox2": //품  질
			Debug("품질 세팅"$(index));
			SetQuality(index);
			break;*/
	}
}
/*
function SetQuality(int index){
	switch (index){
		case 0 :
			SetMovieCaptureHighQuality();//고 퀄리티
			break;
		case 1:
			SetMovieCaptureLowQuality();//저 퀄리티
			break;
	}
}*/


function OnEvent(int a_EventID, String a_Param )
{		
	switch( a_EventID )
	{
		case EV_MovieCaptureStarted:
			//IsCapturingFlag = true;
			CaptureOnOff();
			AddSystemMessage(3309);//동영상 녹화를 시작합니다. Alt+H로 UI를 숨기실 수 있습니다.		
			//Debug("캡쳐 시작 이벤트");
			break;
		case EV_MovieCaptureFailDiskSpace:			
			//IsCapturingFlag = false;
			CaptureOnOff();
			DiskFullMessage();			
			AddSystemMessageString(MakeFullSystemMsg(GetSystemMessage(3310), GetL2Path()$"/screenshot"));//하드디스크에 용량이 부족하여 녹화를 종료합니다. 지금까지 녹화 된 영상은 $s1의 경로에 자동 저장 됩니다.		
			//Debug("용량 없음 이벤트");
			break;
		case EV_MovieCaptureEnded:
			//IsCapturingFlag = false;
			CaptureOnOff();				
			AddSystemMessageString(MakeFullSystemMsg(GetSystemMessage(3311), GetL2Path()$"/screenshot"));
			//Debug("캡쳐 완료 이벤트");
			break;		
		case EV_DialogOK:
			//Debug("DialogType_OK Event");
			HandleDialogOK();
			break;
		case EV_Restart: 
			HandleRestart();
			break;
	}
}

function HandleRestart(){
	//if(IsCapturingFlag){
	if(	IsNowMovieCapturing()){
		MovieCaptureToggle();
	}
	//Debug("Restart");
}

function CaptureOnOff(){//윈도우 전환 토글 스위치 둘이 붙어 다님.	
	if(	IsNowMovieCapturing()){
		Me.HideWindow();
		m_hExpandWnd.showWindow();		
		//Debug("IsNowMovieCapturing");
		class'UIAPI_WINDOW'.static.SetAnchor( "MovieCaptureWnd", "MovieCaptureWnd_Expand", "TopLeft", "TopLeft", 0, 0 );//기본 세팅으로 되어 있으나 이상하게 이 속성이 없으면 확장 창이 드래그가 안됨.
		m_hExpandWnd.SetFocus();
	} else {		
		m_hExpandWnd.HideWindow();
		Me.showWindow();
		class'UIAPI_WINDOW'.static.SetAnchor( "MovieCaptureWnd_Expand", "MovieCaptureWnd", "TopLeft", "TopLeft", 0, 0 );
		Me.SetFocus();
	}
}
defaultproperties
{
}
