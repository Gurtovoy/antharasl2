class QuestTutorialWnd extends UICommonAPI; //ldw 2010.11.15 튜토리얼 퀘스트용 튜토리얼 uc

var HtmlHandle m_hQuestTutorialViewerWndHtmlQuestTutorialViewer;
var int index;
//var int curNum;
//const fileName = "test";
//var string fileName;
//const folderName = "../L2text/";

function OnRegisterEvent()
{
	RegisterEvent( EV_TutorialViewerWndShow );
	RegisterEvent( EV_TutorialViewerWndHide );
	RegisterEvent( EV_TutorialViewerWndShowHtmlFile );
}

function OnLoad()
{
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	m_hQuestTutorialViewerWndHtmlQuestTutorialViewer=GetHtmlHandle("QuestTutorialWnd.HtmlViewer");
	//curNum = 0;
}

function OnClickButton( String a_ButtonID )
{	
	switch( a_ButtonID )
	{
		case "CloseBtn":
		HandleCloseBtn();
		break;
	/*case "NextBtn":
		HandleNextBtn();
		break;
	case "PreBtn":
		HandlePreBtn();
		break;*/
	}
}


/*function HandleNextBtn(){
	
	curNum = curNum+1;
	//Debug("nextBtn:"$curNum);
	htmLoad(curNum);
}

function HandlePreBtn(){
	curNum = curNum-1;
	//Debug("prevBtn:"$curNum);
	htmLoad(curNum);
}*/

function HandleCloseBtn(){
	HideWindow("QuestTutorialWnd");
}

function OnEvent( int Event_ID, string param )
{	
	local string HtmlFile;
	//local Rect rect;
	local int ViewerType;

	//local int HtmlHeight;
	//local string tmpStr;

	switch( Event_ID )
	{
	case EV_TutorialViewerWndShowHtmlFile :
		//Debug("튜토리얼 이벤트 param="$param);
		ParseString(param, "HtmlFile", HtmlFile);
		ParseInt(param, "ViewerType", ViewerType);

	//	getFileName(HtmlFile);
		
		if(ViewerType == 2){
			/*Debug(HtmlFile);
			tmpStr = Right(HtmlFile, 6);
			tmpStr = left(tmpStr,2);			
			curNum = int(tmpStr);*/
			m_hQuestTutorialViewerWndHtmlQuestTutorialViewer.LoadHtml(HtmlFile);
			ShowWindowWithFocus("QuestTutorialWnd");
		}
		break;
	case EV_TutorialViewerWndHide :	
		HideWindow("QuestTutorialWnd");
		break;
	}
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnKeyDown( WindowHandle a_WindowHandle, EInputKey Key )
{
	if( Key == IK_Escape )
	{
		PlayConsoleSound(IFST_WINDOW_CLOSE);
		GetWindowHandle( "QuestTutorialWnd" ).HideWindow();
	}
}



/*function getFileName(string tmpStr){
	local int length;
	length = Len(tmpStr)-6;//"88.htm" 을 뺀 길이
	fileName = Left(tmpStr,length );
}

function htmLoad(int tmpNum){

	local string tmpStr;
	
	tmpStr = folderName $ fileName $ itoStr(curNum)$".htm";
	Debug("loadfile:" $ tmpStr);
	m_hQuestTutorialViewerWndHtmlQuestTutorialViewer.LoadHtml(tmpStr);
}*/


/*function string itoStr(int tmpNum){
	local string tmpStr;
	if(tmpNum<10) tmpStr = "0"$string(tmpNum);
	else tmpStr = string(tmpNum);
	return tmpStr;
}*/
defaultproperties
{
}
