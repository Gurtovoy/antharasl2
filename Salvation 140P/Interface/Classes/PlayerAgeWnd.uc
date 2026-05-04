/**
 *  클래식 서버 용, 게임이용등급 표시 윈도우
 **/

class PlayerAgeWnd extends UIScript;

function OnLoad()
{
	SetClosingOnESC();
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( "PlayerAgeWnd" ).HideWindow();
}
defaultproperties
{
}
