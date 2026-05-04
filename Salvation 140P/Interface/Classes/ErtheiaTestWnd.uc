class ErtheiaTestWnd extends UICommonAPI;

var WindowHandle	Me;

var WindowHandle	armorEnchantWindowHandle;

var ButtonHandle	btnHide;
var ButtonHandle	btnShowEdgeEffectWnd;

var EditBoxHandle	editBlendingTime;
var EditBoxHandle	editAlpha;
var EditBoxHandle	editGray;

var SliderCtrlHandle	sliderAlpha;
var SliderCtrlHandle	sliderGray;

var EditBoxHandle	editOffsetPercentage;

var SliderCtrlHandle	sliderOffsetPercentage;

var EditBoxHandle	editFistScale;
var SliderCtrlHandle	sliderFistScale;

var ButtonHandle	btnApply;
var ButtonHandle	btnCancel;

var string ini;

var bool loadedINI;

var bool bHidden;

var string sectionEdgeEffect;
var string sectionWeapon;

function OnRegisterEvent()
{
}

function OnLoad()
{
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();
		
	Initialize();
}
function Initialize()
{
	ini = "ErtheiaTestConfig.ini";
	loadedINI = false;
	
	bHidden = false;
	
	sectionEdgeEffect = "EdgeEffect";
	sectionWeapon = "Weapon";

	Me = GetWindowHandle("ErtheiaTestWnd");
	Me.SetWindowTitle("Ertheia Test");
	
	armorEnchantWindowHandle = GetWindowHandle("ArmorEnchantEffectTestWnd");
	
	btnHide = GetButtonHandle("ErtheiaTestWnd.ButtonHide");
	btnShowEdgeEffectWnd = GetButtonHandle("ErtheiaTestWnd.ButtonShowEdgeEffectWnd");
	
	editBlendingTime = GetEditBoxHandle("ErtheiaTestWnd.EditBoxBlendingTime");
	editAlpha = GetEditBoxHandle("ErtheiaTestWnd.EditBoxAlpha");
	editGray = GetEditBoxHandle("ErtheiaTestWnd.EditBoxGray");
	
	sliderAlpha = GetSliderCtrlHandle("ErtheiaTestWnd.SliderCtrlAlpha");
	sliderGray = GetSliderCtrlHandle("ErtheiaTestWnd.SliderCtrlGray");
	
	editOffsetPercentage = GetEditBoxHandle("ErtheiaTestWnd.EditBoxOffsetPercentage");	
	sliderOffsetPercentage = GetSliderCtrlHandle("ErtheiaTestWnd.SliderCtrlOffsetPercentage");
	
	editFistScale= GetEditBoxHandle("ErtheiaTestWnd.EditBoxFistScale");	
	sliderFistScale = GetSliderCtrlHandle("ErtheiaTestWnd.SliderCtrlFistScale");
	
	btnApply	= GetButtonHandle("ErtheiaTestWnd.ApplyButton");
	btnCancel	= GetButtonHandle("ErtheiaTestWnd.CancelButton");	
	
	InitValue();
}

function OnEvent(int Event_ID, String param)
{
}

// 에디트박스를 수정 완료했을 경우 이벤트
function OnCompleteEditBox( string strID )
{
	local int ivalue;
	
	//
	switch(strID)
	{	
	case "EditBoxAlpha":
		ivalue = int(editAlpha.GetString());
		sliderAlpha.SetCurrentTick(ivalue);			
		break;
		
	case "EditBoxGray":
		ivalue = int(editGray.GetString());
		sliderGray.SetCurrentTick(ivalue);					
		break;
		
	case "EditBoxOffsetPercentage":
		ivalue = int(editOffsetPercentage.GetString());
		sliderOffsetPercentage.SetCurrentTick(ivalue);			
		break;
		
	case "EditBoxFistScale":
		ivalue = float(editFistScale.GetString()) * 100;
		sliderFistScale.SetCurrentTick(ivalue);
		break;
	}
	
	ApplyValue();	
}

// 버튼을 클릭하였을 경우 이벤트
function OnClickButton( string strID )
{
	switch(strID)
	{
	case "ButtonHide":
		if(bHidden)
		{
			bHidden = false;
			btnHide.SetNameText("은신");
			ExecuteCommand("///da type=116");
		}
		else
		{
			bHidden = true;
			btnHide.SetNameText("은신 해제");
			ExecuteCommand("///aa type=116");
		}
		
		break;
		
	case "ButtonShowEdgeEffectWnd":
		if(armorEnchantWindowHandle.isShowWindow())
		{
			armorEnchantWindowHandle.HideWindow();
		}
		else
		{
			armorEnchantWindowHandle.ShowWindow();
		}
		break;
	
	case "ApplyButton": 
		ApplyValue();		
		break;
		
	case "CancelButton":
		Me.HideWindow();
		break;
	}
}

// 슬라이드 바를 움직일 경우 이벤트
function OnModifyCurrentTickSliderCtrl(string strID, int iCurrentTick)
{
	local int ivalue;
	local float fvalue;
	local string str;

	if(loadedINI == false)
		return;
	
	//
	switch(strID)
	{
	case "SliderCtrlAlpha":
		ivalue = sliderAlpha.GetCurrentTick();
		str = string(ivalue);
		editAlpha.SetString(str);	
		break;
		
	case "SliderCtrlGray":
		ivalue = sliderGray.GetCurrentTick();
		str = string(ivalue);
		editGray.SetString(str);	
		break;
		
	case "SliderCtrlOffsetPercentage":
		ivalue = sliderOffsetPercentage.GetCurrentTick();
		str = string(ivalue);
		editOffsetPercentage.SetString(str);	
		break;
		
	case "SliderCtrlFistScale":
		fvalue = sliderFistScale.GetCurrentTick() / 100.0;
		str = string(fvalue);
		editFistScale.SetString(str);	
		break;
	}
	
	ApplyValue();
	
}

function OnShow()
{
}

function InitValue()
{
	local int ivalue;
	local float fvalue;
	
	RefreshINI(ini);
	
	GetINIFloat(sectionEdgeEffect, "BlendingTime", fvalue, ini);
	editBlendingTime.SetString( string(fvalue) );
		
	GetINIInt(sectionEdgeEffect, "Alpha", ivalue, ini);
	editAlpha.SetString( string(ivalue) );
	GetINIInt(sectionEdgeEffect, "Gray", ivalue, ini);
	editGray.SetString( string(ivalue) );
	
	ivalue = int(editAlpha.GetString());
	sliderAlpha.SetCurrentTick(ivalue);
	ivalue = int(editGray.GetString());
	sliderGray.SetCurrentTick(ivalue);
	
	
	if(!GetINIInt(sectionWeapon, "OffsetPercentage", ivalue, ini))
	{
		ivalue = 45;
	}
	editOffsetPercentage.SetString( string(ivalue) );
	
	ivalue = int(editOffsetPercentage.GetString());
	sliderOffsetPercentage.SetCurrentTick(ivalue);
	
	
	if(!GetINIFloat(sectionWeapon, "FistScale", fvalue, ini))
	{
		fvalue = 1.f;
	}
	editFistScale.SetString( string(fvalue) );
	
	ivalue = float(editFistScale.GetString()) * 100;
	sliderFistScale.SetCurrentTick(ivalue);
		
	loadedINI = true;
}

function ApplyValue()
{
	// 
	local float blendingTime;
	
	local int alphaValue;
	local int grayValue;
	
	local int staffOffsetPercentage;
	
	local float fistScale;
	
	if(loadedINI == false)
		return;
	
	// get value
	blendingTime	= float(editBlendingTime.GetString());
	alphaValue		= int(editAlpha.GetString());
	grayValue		= int(editGray.GetString());
	
	staffOffsetPercentage	= int(editOffsetPercentage.GetString());
	
	fistScale = float(editFistScale.GetString());

	
	// set ini	
	SetINIFloat(sectionEdgeEffect, "BlendingTime", blendingTime, ini);	
	SetINIInt(sectionEdgeEffect, "Alpha", alphaValue, ini);
	SetINIInt(sectionEdgeEffect, "Gray", grayValue, ini);
	
	SetINIInt(sectionWeapon, "OffsetPercentage", staffOffsetPercentage, ini);
	
	SetINIFloat(sectionWeapon, "FistScale", fistScale, ini);
	
	RefreshINI(ini);
}
defaultproperties
{
}
