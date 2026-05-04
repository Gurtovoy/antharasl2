class W24HzWnd extends UICommonAPI;//ldw

// 1. 배경음악 끄기 체크는 볼륨 0과 관련 됨.


var WindowHandle Me;
var ButtonHandle PlayerChangeButton;
//2. 컨트롤러 전환 버튼 
var ButtonHandle CloseButton;
//3. 닫기버튼
var ButtonHandle PlayControlButton_Next;
var ButtonHandle PlayControlButton_Pre;
//4. 곡 제어, 이전/다음
var ButtonHandle PlayControlButton;
//5. 음악 제어, 플레이 버튼
var SliderCtrlHandle W24HzVolumeSliderCtrl; 

//6. 사운드 볼륨제어 
var TextboxHandle MusicName; 
var TextureHandle PlayTypeIcon;//곡 타입
//7. 곡명
var ButtonHandle ChannelControlBtn_Pre;
var ButtonHandle ChannelControlBtn_Next;
//8. 채널 이동 버튼
var TextboxHandle ChannelName;
//9. 채널 명
var CheckBoxHandle BackGroundMusicControl;
//0. 배경음악 끄기 체크

const DIALOGID_Install24hz = 2424 ;//ldw 24hz 인스톨 여부
//const DIALOGID_NotRespond = 2425;//웹 인증 응답 없음
const DIALOGID_FullWindow = 2425;//풀창

var int IsRadiomode;// 라디오 모드 혹은, 노래 모드 

var string CurrentPlayListName;// 채널, 혹은 앨범 리스트
var int IsEnablePlayListPrevButton; // 이전 채널(리스트)이 가능 한가?
var int IsEnablePlayListNextButton; // 다음 채널(리스트)이 가능 한가?

var string CurrentPlaySongName; // 지금 나오고 있는 노래 재목
var int IsEnableSongPrevButton; // 이전 버튼 활성 여부
var int IsenableSongNextButton; // 다음 버튼 활성 여부

var int IsPlayingNow; // 재생 되고 있는가?
var int Volume; // 볼륨
var float saved_BGMVolume;//배경음악 끄기 체크 시 기존 볼륨값 저장
const defaultVolume = 0.4f;//배경음악이 0으로 설정 됐을 때 체크 박스를 풀 경우 기본 볼륨.

var bool bConnected;//커넥팅 여부

var bool bfullConfirmOK;//풀창 리사이징 컨펌 여부

var L2Util util;//bluesun커스터마이즈 툴팁

//var bool tmpFalse ;
//버튼 모음


 /*SliderCtrlHandle W24HzVolumeSliderCtrl;
 TextboxHandle MusicName;
 TextboxHandle ChannelName;
 CheckBoxHandle BackGroundMusicControl;*/


function OnLoad()
{
	//if(CREATE_ON_DEMAND==0)//과거에 불려 졌었는가?
	//{
	OnRegisterEvent();	
	Initialize();
	Load();

	//tmpFalse = true;
}

function OnRegisterEvent()
{
	RegisterEvent(EV_24HzControllerInfo);//L224hzGetInfo() 실행시 발생

	//ldw 201-01-14 추가 
	RegisterEvent(EV_24HzFileCorrupted);//웹인증 실패 -> 설치 페이지로
	RegisterEvent(EV_24HzWebCertificationNotRespond);//웹인증 응답없음 -> 24hz 서버가.........
	RegisterEvent(EV_24HzOnOff); //24hz 입력 메뉴 24hz 클릭과 동일한 효과
	RegisterEvent(EV_24HzAlreadyConnected);
	RegisterEvent( EV_24HzDisConnected );
	RegisterEvent(EV_DialogOK );


	
}

function Initialize()
{
	Me= GetWindowHandle("W24HzWnd");
	PlayerChangeButton = GetButtonHandle("W24HzWnd.PlayerChangeButton");
	CloseButton = GetButtonHandle("W24HzWnd.CloseButton");
	//GroupBox =  GetTextureHandle("W24HzWnd.GroupBox");
	PlayControlButton_Next = GetButtonHandle("W24HzWnd.PlayControlButton_Next");
	PlayControlButton_Pre = GetButtonHandle("W24HzWnd.PlayControlButton_Pre");
	PlayControlButton = GetButtonHandle("W24HzWnd.PlayControlButton");
	//W24HzVolumeSliderCtrl = GetSlierCtrlHande("W24HzWnd.W24HzVolumeSliderCtrl");
	MusicName = GetTextboxHandle("W24HzWnd.MusicName"); 
	PlayTypeIcon = GetTextureHandle("W24HzWnd.PlayTypeIcon");
	ChannelControlBtn_Pre = GetButtonHandle("W24HzWnd.ChannelControlBtn_Pre");
	ChannelControlBtn_Next = GetButtonHandle("W24HzWnd.ChannelControlBtn_Next");
	ChannelName = GetTextboxHandle("W24HzWnd.ChannelName");
	//BackGroundMusicControl = GetCheckBoxHandle("W24HzWnd.BackGroundMusicControl");
	BackGroundMusicControl = GetCheckBoxHandle("W24HzWnd.BackGroundMusicControl");

	util = L2Util(GetScript("L2Util"));//bluesun 커스터마이즈 툴팁
}




function Load()
{
	bConnected = false;
	CurrentPlaySongName = "Now loading...... " ;//임시 값 넣음
	CurrentPlayListName = "Now loading ";//임시 값 넣음	
	MusicName.SetTextEllipsisWidth(110);
	ChannelName.SetTextEllipsisWidth(94);
	setMusicName(CurrentPlaySongName);
	setChannelName(CurrentPlayListName);

}

/*function PlayControlButton_Pre_Next_tooltip(){
	PlayControlButton_Pre.SetTooltipCustomType;
	PlayControlButton_Next.SetTooltipCustomType;
}*/

function setMusicName(string song_Name){
	MusicName.SetText(song_Name);
	MusicName.SetTooltipString(song_Name);
}
function setChannelName(string channel_Name){
	ChannelName.SetText(channel_Name);
	ChannelName.SetTooltipString(channel_Name);
}
function OnEvent(int a_EventID, String a_Param )
{	
	//Debug("string"@GetSystemString(2418));
	//Debug("24hz Event" @ a_EventID);
	switch(a_EventID){
	case EV_24HzControllerInfo://정보 받음
		//Debug(a_Param);
		HandleL224hzGetInfo(a_Param);
		break;
	case EV_24HzAlreadyConnected://이미 연결 되어 있음.
		Handle24HzAlreadyConnected();
		break;
	case EV_24HzDisConnected://연결 끊어짐
		Handle24HzDisConnected();
		break;
	
	//ldw20110114
	case EV_24HzFileCorrupted://웹인증 실패 -> 설치 페이지로
		FileCorrupted();
		//Debug("EV_24HzFileCorrupted"); //5463
		break;
	case EV_24HzWebCertificationNotRespond ://웹인증 응답없음 -> 24hz 서버가.........
		//Debug("EV_24HzWebCertificationNotRespond"); //5464
		WebCertificationNotRespond();
		break;
	case EV_24HzOnOff :// /24hz 입력 메뉴 24hz 클릭과 동일한 효과
		if( Me.isShowWindow() ) {
			Me.hideWindow();
		} else {
			Me.ShowWindow();
		}
		//Debug("EV_24HzOnOff");//5465sp
		break;
	case EV_DialogOK:	
		HandleDialogOK();
		break;
	}
}	

function Handle24HzAlreadyConnected(){	
	bfullConfirmOK = false;
	bConnected = false;
	Me.HideWindow();	
	DialogSetID( 0 );
	DialogShow( DialogModalType_Modalless, DialogType_OK, GetSystemMessage( 3508 ), string(Self));	
	//이미 연결 됨.
}

function Handle24HzDisConnected(){
	bfullConfirmOK = false;
	bConnected = false;
	Me.HideWindow();	
	DialogSetID( 0 );
	DialogShow( DialogModalType_Modalless, DialogType_OK, GetSystemMessage( 3509 ), string(Self));		
	//연결 종료
}
function FileCorrupted(){
	bfullConfirmOK = false;
	bConnected = false;
	Me.HideWindow();
	//다이얼로그 상자 사용 설치 할 것인지 확인
	DialogSetID( DIALOGID_Install24hz );
	DialogSetEnterDoNothing();
	DialogShow( DialogModalType_Modalless, DialogType_OKCancel, GetSystemMessage( 3293 ), string(Self));
}

function HandleDialogOK()
{
	//Debug("HandleDialogOK"@DialogGetID());
	if( !DialogIsMine())
		return;

	switch( DialogGetID())
	{
		case DIALOGID_Install24hz: //ldw 24hz
			L224hzLeadInstall();
			break;
		case DIALOGID_FullWindow:  //풀창
			HandleSetWindowMode();
			break;
		case 0:
			break;
		}
}
function HandleSetWindowMode(){		
	bfullConfirmOK = true; //이 변수는 연결이 끊어질 때 마다. false 로 초기화 된다.
	Me.ShowWindow();
}

function WebCertificationNotRespond(){
	//DialogSetID(DIALOGID_NotRespond);
	bfullConfirmOK = false;
	bConnected = false;
	Me.HideWindow();
	DialogSetID( 0 );
	DialogShow( DialogModalType_Modalless, DialogType_Warning, GetSystemMessage( 3474 ), string(Self));// 일시적인 장애로 24Hz 서비스를 이용할 수 없습니다.
}


function onShow(){	
	if(!L224hzIsInstall()){
		bfullConfirmOK = false;
		bConnected = false;
		//다이얼로그 상자 사용 설치 할 것인지 확인
		DialogSetID( DIALOGID_Install24hz );
		DialogSetEnterDoNothing();
		DialogShow( DialogModalType_Modalless, DialogType_OKCancel, GetSystemMessage( 3293 ), string(Self));
		Me.HideWindow();
	} 
	else if( IsFullScreen()  && !bConnected  && !bfullConfirmOK)//전체 화면이면서 첫 실행일 경우 다이얼로그 창을 거치지 않은 경우
	{		
		DialogSetID( DIALOGID_FullWindow );
		DialogSetEnterDoNothing();
		DialogShow( DialogModalType_Modalless, DialogType_OKCancel, GetSystemMessage( 3665 ), string(Self)); //전체 화면일 경우 창모드로 전환됩니다.
		Me.HideWindow();			
	} 
	else if( !bConnected )
	{
		bConnected = true;
		L224hzTurnOn();// 첫 연결			
	} 
		else 
	{
		L224hzGetInfo();
	} 
	
	//Debug("onShow 24hz 실행");
	muteCheckBoxControlonShow();//보여질 대 뮤트 체크 박스 연관관계 체크
}

function TryConnect(){

}


function HandleL224hzGetInfo( String a_Param )//정보 분석
{

	ParseInt( a_Param, "IsRadiomode", IsRadiomode );// 라디오 모드 혹은, 노래 모드
	setRadioOrList();//라디오 리스트 전환 Event:isRadiomode, Button:PlayerChangeButton
	
	ParseInt( a_Param, "IsEnablePlayListPrevButton", IsEnablePlayListPrevButton ); // 이전 채널(리스트)이 가능 한가?
	ParseInt( a_Param, "IsEnablePlayListNextButton", IsEnablePlayListNextButton ); // 다음 채널(리스트)이 가능 한가?

	/*	if(IsRadiomode==1){	//이전 다음 모두 속성 값이 있으나. 기획서 내용에 따라. 모두 1로 전재함. 나중에 쓰일 수 잇으므로 주석 처리 해 둠.
		setButtonEnabledOrNot(IsEnablePlayListPrevButton,ChannelControlBtn_Pre, 2417); // 이전 목록	
		setButtonEnabledOrNot(IsEnablePlayListNextButton,ChannelControlBtn_Next, 2421);// 다음 목록	
	} else {
		setButtonEnabledOrNot(IsEnablePlayListPrevButton,ChannelControlBtn_Pre, 2415); // 이전 채널	
		setButtonEnabledOrNot(IsEnablePlayListNextButton,ChannelControlBtn_Next, 2416);// 다음 채널	
	}*/
		if(IsRadiomode==0){	//채널인지 아닌지 여부에 따라.
		setButtonEnabledOrNot(1,ChannelControlBtn_Pre, 2417); // 이전 목록	
		setButtonEnabledOrNot(1,ChannelControlBtn_Next, 2421);// 다음 목록	
	} else {
		setButtonEnabledOrNot(1,ChannelControlBtn_Pre, 2415); // 이전 채널	
		setButtonEnabledOrNot(1,ChannelControlBtn_Next, 2416);// 다음 채널	
	}
	
	ParseInt( a_Param, "IsEnableSongPrevButton", IsEnableSongPrevButton ); // 이전 버튼 활성 여부
	setButtonEnabledOrNot(IsEnableSongPrevButton, PlayControlButton_Pre, 2413);//이전곡

	ParseInt( a_Param, "IsenableSongNextButton", IsenableSongNextButton ); // 다음 버튼 활성 여부
	setButtonEnabledOrNot(IsenableSongNextButton, PlayControlButton_Next, 2414);//다음곡

	//Debug("HandleL224hzGetInfo 이벤트 발생");
	
	
	ParseString( a_Param, "CurrentPlayListName", CurrentPlayListName );// 채널, 혹은 앨범 리스트	
	setChannelName(CurrentPlayListName);

	
	ParseString( a_Param, "CurrentPlaySongName", CurrentPlaySongName ); // 지금 나오고 있는 노래 제목
	setMusicName(CurrentPlaySongName);


	ParseInt( a_Param, "IsPlayingNow", IsPlayingNow ); // 재생 되고 있는가?
	setPlayButton();

	ParseInt( a_Param, "Volume", Volume );// 볼륨 !! 외부에서 볼륨 조절시 이벤트가 발생 되지 않는다. 외부 컨트롤 할때는 게임내의 컨트롤러의 볼륨을 조절 할 수 없음.
	//Debug("Volume:"$Volume$" Event's");
	setVolumeSlider();

	

	
	//setPrevSongEnableOrNot(IsEnableSongPrevButton);

	//setNextListEnableOrNot(IsEnablePlayListNextButton);
	//setPrevListEnableOrNot(IsEnablePlayListPrevButton);	
	
	//Debug (a_Param);
	//Debug("이벤트 발생");
}

function setButtonEnabledOrNot(int tmpNum,ButtonHandle tmpBtn, int tooltipString){
	local CustomTooltip T;//bluesun 커스터마이즈 툴팁 
	util.setCustomTooltip(T);//by bluesun 커스터마이즈 툴팁 
	util.ToopTipInsertText( GetSystemString(tooltipString), true, true );//bluesun 커스터마이즈 툴팁 
	if(tmpNum==0){		
		util.ToopTipInsertText( GetSystemString(2418), true, true, util.ETooltipTextType.COLOR_GRAY );//bluesun 커스터마이즈 툴팁 text:스트리밍 상품 구입시.......
	}	
	tmpBtn.SetTooltipCustomType(util.getCustomTooltip());//bluesun 커스터마이즈 툴팁
}

function setVolumeSlider(){
	local int tmpInt;
	tmpInt=100-volume;
	if(class'UIAPI_SLIDERCTRL'.static.GetCurrentTick("W24HzWnd.W24HzVolumeSliderCtrl")!=tmpInt){
		class'UIAPI_SLIDERCTRL'.static.SetCurrentTick("W24HzWnd.W24HzVolumeSliderCtrl",tmpInt);
		//Debug("inIf");
	}
	//OnModifyCurrentTickSliderCtrl("W24HzWnd.W24HzVolumeSliderCtrl",tmpInt);
	//Debug("volume:"$volume$" setVolumeSlider");
}

function HandleW24HzVolumeSliderCtrl(int iCurrentTick){
	local int tmpInt;
	tmpInt=100-iCurrentTick;
	L224hzSetVolume(tmpInt);
	//Debug("Volume:"$tmpInt$" SliderCtrl");
}

function OnModifyCurrentTickSliderCtrl(string strID, int iCurrentTick)
{
	//local float  fVolume;
	//fVolume=GetVolumeFromSliderTick(iCurrentTick);
	switch(strID)
	{
	case "W24HzVolumeSliderCtrl" :
		HandleW24HzVolumeSliderCtrl(iCurrentTick);		
		break;
	}
}

function OnClickCheckBox( String strID )
{
	switch(strID){
	case "BackGroundMusicControl":
		BackGroundMusicControlHandle();
		//Debug("Chk BackGroundMusicControl");
		break;
	}
}

function OnClickButton( string a_Name )
{
	switch( a_Name )
	{
	case "PlayerChangeButton":
		L224hzToggleMode();//외부 함수
		//PlayerChangeButtonHandle();
		//Debug("Btn PlayerChangeButton");
		break;
	case "CloseButton":
		CloseButtonHandle();
		//Debug("Btn CloseButton");
		break;
	case "PlayControlButton_Next":
		//PlayControlButton_NextHandle();
		L224hzPlayNextSong();
		//Debug("Btn PlayControlButton_Next");
		break;
	case "PlayControlButton_Pre":
		L224hzPlayPrevSong();
		//PlayControlButton_PreHandle();
		//Debug("Btn PlayControlButton_Pre");
		break;
	case "PlayControlButton":
		PlayControlButtonHandle();		
		//Debug("Btn PlayControlButton");
		break;	
	case "ChannelControlBtn_Pre":
		//Debug("Btn ChannelControlBtn_Pre");
		L224hzPlayPrevList();
		break;
	case "ChannelControlBtn_Next":
		//Debug("Btn ChannelControlBtn_Next");
		L224hzPlayNextList();
		break;	
	}
}




function setRadioOrList(){
	local string btnString_None;
	local string btnString_Over;
	local string btnString_Down;
	local string Curr_state1;// 컨트롤러 버튼 상태
	local string Curr_state2;// 현재 재생 곡명 상태
	local int SystemString1;//컨트롤러 전환 버튼 툴팁
	local int SystemString2;//현재 재생 곡명 앞 툴팁

	//local string tmptxt;	

	if(IsRadiomode==1){
		//tmptxt = "111111111111111111111111111111111111111111111111111111111111111";
		Curr_state1 = "Player";
		Curr_state2 = "Radio";
		SystemString1 = 2403;//뮤직플레이어 전환
		SystemString2 = 2404;//라디오 곡
		//Debug("라디오 전환");
	} else {
		//tmptxt = "000000000000000000000000000000000000000000000000000000000000000";
		Curr_state1 = "Radio";
		Curr_state2 = "Player";
		SystemString1 = 2402;//라디오 전환
		SystemString2 = 2405;//뮤직플레이어 곡		
		//Debug("뮤직플레이어 전환");
	}	

	//isRadioMode 로
	PlayerChangeButton.SetTooltipCustomType(MakeTooltipSimpleText(GetSystemString(SystemString1)));
	btnString_None="L2UI_ct1.24Hz.24Hz_DF_PlayerChangeBtn_"$Curr_state1;
	btnString_Over="L2UI_ct1.24Hz.24Hz_DF_PlayerChangeBtn_"$Curr_state1$"_over";
	btnString_Down="L2UI_ct1.24Hz.24Hz_DF_PlayerChangeBtn_"$Curr_state1$"_down";
	PlayerChangeButton.SetTexture(btnString_None, btnString_Down,btnString_Over);	
	
	PlayTypeIcon.SetTooltipCustomType(MakeTooltipSimpleText(GetSystemString(SystemString2)));
	PlayTypeIcon.SetTexture("L2UI_ct1.24Hz_DF_Icon_PlayType_"$Curr_state2);// 재생 목록 앞 채널
	//L224hzToggleMode_tmp();
	//Debug("현재 재생 모드는 "$Curr_state2);
}



function setPlayButton(){
		//현 상태가 Stop 일 경우 버튼 상태는 Play 이어야 함.
	local string btnString_None;
	local string btnString_Over;
	local string btnString_Down;
	local string Curr_state;//버튼 상태
	local int SystemString;

	if(IsPlayingNow==1){
		Curr_state = "Stop";
		SystemString = 2420;//정지
	}else {
		Curr_state = "Play";
		SystemString = 2419;//재생
	}

	PlayControlButton.SetTooltipCustomType(MakeTooltipSimpleText(GetSystemString(SystemString)));
	//IsPlayingNow 로
	btnString_None="L2UI_ct1.24Hz.24Hz_DF_PlayControlBtn_"$Curr_state;
	btnString_Over="L2UI_ct1.24Hz.24Hz_DF_PlayControlBtn_"$Curr_state$"_Over";
	btnString_Down="L2UI_ct1.24Hz.24Hz_DF_PlayControlBtn_"$Curr_state$"_Down";
	PlayControlButton.SetTexture(btnString_None, btnString_Down,btnString_Over); 

	
	//Debug("현재 재생 상태는 "$Curr_state);
}
function PlayControlButtonHandle(){	
	if(IsPlayingNow==1){
		L224hzStop();
		//L22hzStop_tmp();
		//L224hzGetInfo();
		
	}else {	
		L224hzPlay();
		//L22hzPlay_tmp();
	}
}
///////////////////////////임시 값//////////////////////////////////////////
/*function L224hzToggleMode_tmp(){
	if(IsRadiomode == 1)
		IsRadiomode = 0;
	else IsRadiomode =1;
}*/

/*function L22hzStop_tmp(){
	IsPlayingNow = 0;
}*/

/*function L22hzPlay_tmp(){
	IsPlayingNow = 1;
}*/
//////////////////////////////////////////////////////////////////////////////////

function CloseButtonHandle(){
	Me.HideWindow();
}

function muteCheckBoxControlonShow(){// 이 창이 보여 질 때 볼륨이 0.005f 보다 작으면 체크, 수동적
	local float currVolume;
	currVolume = GetOptionFloat("Audio", "MusicVolume");	
	if (currVolume > 0.01f)//슬라이더의 최저 값이 0.005f이므로 0.01f를 기준으로
	{		
		//Debug("onShow 0 보다 큰 체크는 안 되는 음악볼륨 "$currVolume);
		class'UIAPI_CHECKBOX'.static.SetCheck( "W24HzWnd.BackGroundMusicControl", false);		
	} else {
		//Debug("onShow 0 이하인 체크되어야 하는 음악볼륨 "$currVolume);
		class'UIAPI_CHECKBOX'.static.SetCheck( "W24HzWnd.BackGroundMusicControl", true);
	}
}
function BackGroundMusicControlHandle(){//옵션 창의 bgm 슬라이드를 변경 하는 .....	
	local float tmpVol;
	if(class'UIAPI_CHECKBOX'.static.IsChecked( "W24HzWnd.BackGroundMusicControl"))
	{			
		PlayConsoleSound(IFST_WINDOW_CLOSE);
		saved_BGMVolume = GetOptionFloat("Audio", "MusicVolume");
		tmpVol = 0.0f;		
	} else {PlayConsoleSound(IFST_WINDOW_OPEN);
		if(saved_BGMVolume>0.01f){//슬라이더의 최저 값이 0.005f이므로 0.01f를 기준으로
			tmpVol = saved_BGMVolume;
		} else {
			tmpVol = defaultVolume;			
		}
	}
	SetOptionFloat("Audio", "MusicVolume",tmpVol);
	setVolumeSliderCtrlofOptionWnd(tmpVol);
}

function setVolumeSliderCtrlofOptionWnd(float tmpVol){// 옵션 창의 사운드 설정 변경함수.
		// 음악볼륨	- MusicVolumeSliderCtrl
		local int iMusicVolume;		
		if( 0.0f <= tmpVol && tmpVol < 0.2f )
			iMusicVolume=0;
		else if( tmpVol < 0.4f )
			iMusicVolume=1;
		else if( tmpVol < 0.6f )
			iMusicVolume=2;
		else if( tmpVol < 0.8f )
			iMusicVolume=3;
		else if( tmpVol < 1.0f )
			iMusicVolume=4;
		else if( 1.0f <= tmpVol )
			iMusicVolume=5;

		class'UIAPI_SLIDERCTRL'.static.SetCurrentTick("OptionWnd.MusicVolumeSliderCtrl", iMusicVolume);
}
defaultproperties
{
}
