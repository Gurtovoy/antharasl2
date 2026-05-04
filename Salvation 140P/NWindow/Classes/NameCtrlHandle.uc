/**
*네임컨트롤에 대한 함수를 정의
*/
class NameCtrlHandle extends WindowHandle
	native;
	
/**
* 표시되는 이름을 변경한다

* @param
* Name : 변경할 이름
* Type : 컨트롤의 타입
* Align : 컨트롤의 정렬상태

* @return
* void

* @example
* var NameCtrlHandle NameCtrl;
* NameCtrl = GetNameCtrlHandle ("StatusWnd.UserName"); //핸들을 가져온다
* NameCtrl.SetName("Hello",NCT_Normal,TA_Center); //hello를 표시한다. 노말컨트롤. 가운데 정렬
* }

*enum ENameCtrlType
*{
*	NCT_Normal,
*	NCT_Item
*};

*enum ETextAlign
*{
*	TA_Undefined,
*	TA_Left, 
*	TA_Center,
*	TA_Right,
*	TA_MacroIcon,
*};
*/
native final function SetName(string Name,ENameCtrlType Type,ETextAlign Align);

/**
* 표시되는 이름을 변경한다(색깔과 함께)

* @param
* Name : 변경할 이름
* Type : 컨트롤의 타입
* Align : 컨트롤의 정렬상태
* NameColor : 색상

* @return
* void

* @example
* var NameCtrlHandle NameCtrl;
* var Color tcolor;
* tcolor.R = 255;
* tcolor.G = 0;
* tcolor.B = 0;
* tcolor.A = 255;
* NameCtrl = GetNameCtrlHandle ("StatusWnd.UserName"); //핸들을 가져온다
* NameCtrl.SetNameWithColor("Hello",NCT_Normal,TA_Center, tcolor); //hello를 표시한다. 노말컨트롤. 가운데 정렬,붉은색
* }

*enum ENameCtrlType
*{
*	NCT_Normal,
*	NCT_Item
*};

*enum ETextAlign
*{
*	TA_Undefined,
*	TA_Left, 
*	TA_Center,
*	TA_Right,
*	TA_MacroIcon,
*};
*/
native final function SetNameWithColor(string Name,ENameCtrlType Type,ETextAlign Align,Color NameColor);

/**
* 컨트롤에 표시되는 이름을 가져온다

* @param
* void

* @return
* string : 이름

* @example
* var NameCtrlHandle NameCtrl;
* NameCtrl = GetNameCtrlHandle ("StatusWnd.UserName"); //핸들을 가져온다
* debug(NameCtrl.GetName()); //이름을 가져와 출력한다.
* }
*/
native final function string GetName();


	
/**
* 표시되는 이름을 변경한다 (아이템 정보를 이용하여)
*/
native final function SetNameUsingItem(out ItemInfo info , ENameCtrlType Type,ETextAlign Align);
defaultproperties
{
}
