/**
*상태바에 컨트롤에 대한 함수를 정의
*/
class StatusBarHandle extends WindowHandle
	native;

/**
*스테이터스바의 값을 조절한다.
* @param
* CurrentValue : 지정할 값
* MaxValue : 최대값

* @return
*void

* @example
*var StatusBarHandle s_handle;
*s_handle = GetStatusBarHandle( "StatusWnd.CPBar" ); //핸들을 가져온다
*s_handle.SetPoint(100,1000); // 전체 100/1000 으로 표시된다
*/	
native final function SetPoint(int CurrentValue,int MaxValue);

/**
*스테이터스바의 값을 퍼센트지로 표시한다.
* @param
* CurrentValue : 지정할 값
* MinValue : 최소값
* MaxValue : 최대값

* @return
*void

* @example
*var StatusBarHandle s_handle;
*s_handle = GetStatusBarHandle( "StatusWnd.CPBar" ); //핸들을 가져온다.
*s_handle.SetPointPercent(100,1000,2000); // 90.00% 라고표시된다
*/	
native final function SetPointPercent(INT64 CurrentValue,INT64 MinValue,INT64 MaxValue);


/**
*스테이터스바의 값을 경험치 퍼센트지로 표시한다
* @param
* CurrentPercentRate : 경험치 percent rate

* @return
*void

* @example
*var StatusBarHandle s_handle;
*s_handle = GetStatusBarHandle( "StatusWnd.CPBar" ); //핸들을 가져온다.
*s_handle.SetPointExpPercentRate(30.0); // 30  퍼센트로 표시한다.
*/
native final function SetPointExpPercentRate(float CurrentPercentRate); 

/**
*스테이터스바의 값을 리젠(점점차오르는)표시한다
* @param
* duration : 리젠되는 시간
* ticks : 한번 리젠될때 소요되는 tick
* amount : 증가값

* @return
*void

* @example
*var StatusBarHandle s_handle;
*s_handle = GetStatusBarHandle( "StatusWnd.HPBar" ); //핸들을 가져온다.
*s_handle.SetRegenInfo(15,3,8); // 15초동안 8씩 차오르며 3tick 마다 차오른다. 하지만 서버에서 hp를 관리하기 때문에 실제로 차오르지는 않는다. 
*/
native final function SetRegenInfo(int duration,int ticks,float amount);
defaultproperties
{
}
