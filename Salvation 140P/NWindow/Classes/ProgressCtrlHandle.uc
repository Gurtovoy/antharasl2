/**
*프로그래스(진행바)핸들에 관한 함수를 정의
*/
class ProgressCtrlHandle extends WindowHandle
	native;

/**
* 프로그래시바의 전체 진행 시간을 설정한다.

* @param
* Millitime : 프로그래스바의 전체 시간(1/1000 초단위)

* @return
* void

* @example
* var ProgressCtrlHandle	p_handle;
* p_handle = GetProgressCtrlHandle("ItemEnchantWnd.EnchantProgress"); //핸들을 가져온다
* p_handle.SetProgressTime(2000); //2초로 설정
*/	
native final function SetProgressTime(int Millitime);

/**
* 프로그래시바의 현재 시간을 정한다.

* @param
* Millitime : 프로그래스바의 현재 시간(1/1000 초단위)

* @return
* void

* @example
* var ProgressCtrlHandle	p_handle;
* p_handle = GetProgressCtrlHandle("ItemEnchantWnd.EnchantProgress"); //핸들을 가져온다
* p_handle.SetProgressTime(2000); //총시간 2초로 설정
* p_handle.SetPos(2); //2초로 시작시간 지정
*/	

native final function SetPos(int Millitime);

/**
* 프로그래시브바를 리셋한다. (멈추고 0초로 현재 시간지정)

* @param
* void

* @return
* void

* @example
* var ProgressCtrlHandle	p_handle;
* p_handle = GetProgressCtrlHandle("ItemEnchantWnd.EnchantProgress"); //핸들을 가져온다
* p_handle.SetProgressTime(2000); //총시간 2초로 설정
* p_handle.SetPos(2000); //0초로 시작시간 지정
* p_handle.Start(); //시작
* p_handle.Reset(); //리셋한다
*/	
native final function Reset();

/**
* 프로그래시브바의 진행을 멈춘다

* @param
* void

* @return
* void

* @example
* var ProgressCtrlHandle	p_handle;
* p_handle = GetProgressCtrlHandle("ItemEnchantWnd.EnchantProgress"); //핸들을 가져온다
* p_handle.SetProgressTime(2000); //총시간 2초로 설정
* p_handle.SetPos(2000); //2초로 시작시간 지정
* p_handle.Start(); //시작
* p_handle.Stop(); //멈춘다
*/	
native final function Stop();

/**
* 프로그래시브바의 멈춘진행을 진행하도록 한다

* @param
* void

* @return
* void

* @example
* var ProgressCtrlHandle	p_handle;
* p_handle = GetProgressCtrlHandle("ItemEnchantWnd.EnchantProgress"); //핸들을 가져온다
* p_handle.SetProgressTime(2000); //총시간 2초로 설정
* p_handle.SetPos(2000); //2초로 시작시간 지정
* p_handle.Start(); //시작
* p_handle.Stop(); //멈춘다
* p_handle.Resume(); //다시 움직인다
*/	
native final function Resume();

/**
* 프로그래시브바를 진행을 시작시킨다.

* @param
* void

* @return
* void

* @example
* var ProgressCtrlHandle	p_handle;
* p_handle = GetProgressCtrlHandle("ItemEnchantWnd.EnchantProgress"); //핸들을 가져온다
* p_handle.SetProgressTime(2000); //총시간 2초로 설정
* p_handle.SetPos(2000); //2초로 시작시간 지정
* p_handle.Start(); //시작
*/	
native final function Start();

native final function SetBackTex(string left, string mid, string right);
native final function SetBarTex(string left, string mid, string right);
defaultproperties
{
}
