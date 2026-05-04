class WebBrowserHandle extends WindowHandle
	native;

////// Awesomium ver 1.6.6 사용 시. CEF 교체 후 삭제할 것. /////////////////////////////////

native final function WithWebSession();
native final function WithoutWebSession();	// NP 서버로 부터 토큰 값을 받고나서 세션생성을 위한 파람을 넘기는 행위를 하지 않는다.
native final function BeginParam(string charset);
native final function PushParam(string key, string value);

native final function NavigateAsPost(string url);
native final function NavigateAsGet(string url);
native final function NavigateAsGetJson(string url);  // Get 방식인데 헤더에 Application/json을 선택해서 페이지 요청함.

native final function GoToHistoryOffset(int offset);//branch121212

native final function bool ExecuteJavaScriptWithStringResult(string command, out string value);
native final function bool ExecuteJavaScriptWithIntegerResult(string command, out int value);
native final function bool ExecuteJavaScriptWithFloatResult(string command, out float value);

native final function string GetURLEncodedAsUTF8(string url);

////// Awesomium ver 1.6.6 사용 시. CEF 교체 후 삭제할 것. /////////////////////////////////

native final function string GetUrl();

native final function bool ExecuteJavaScript(string command);

native final function string GetCookie(string url, string key);
native final function bool SetCookie(string url, string key, string value);

native final function Navigate(WebRequestInfo requestInfo);
defaultproperties
{
}
