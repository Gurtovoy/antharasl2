class HDRRenderTestWnd extends UICommonAPI;

var WindowHandle	Me;

var CheckBoxHandle	btnUse;
var CheckBoxHandle	btnPreview;

var EditBoxHandle	editExposure;
var EditBoxHandle	editGamma;
var EditBoxHandle	editAvgLumMin;
var EditBoxHandle	editAvgLumMax;

var SliderCtrlHandle	sliderExposure;
var SliderCtrlHandle	sliderGamma;
var SliderCtrlHandle	sliderAvgLumMin;
var SliderCtrlHandle	sliderAvgLumMax;

var ButtonHandle	btnOk;
var ButtonHandle	btnCancle;

// 다음 용어는 다음과 같이 사용될 수 있다.
// exposure : FinalCoef
// Gamma : GrayLum
// AvgLumMin : ClampMin
// AvgLumMax : ClampMax
var bool PreUseHDR;
var float PreExposure, PreGamma, PreAvgLumMin, PreAvgLumMax;

const TICK_INTERVAL = 10000.0f;

function OnRegisterEvent()
{
	RegisterEvent( EV_HDRRenderTestWndShow );
}

function OnLoad()
{
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();
		
	Initialize();
}
function Initialize()
{
	Me = GetWindowHandle("HDRRenderTestWnd");
	Me.SetWindowTitle("HDR Conversion");
	
	btnUse = GetCheckBoxHandle("HDRRenderTestWnd.UseCheckBox");
	btnPreview = GetCheckBoxHandle("HDRRenderTestWnd.PreviewCheckBox");
	
	editExposure	= GetEditBoxHandle("HDRRenderTestWnd.ExposureEditBox");
	editGamma		= GetEditBoxHandle("HDRRenderTestWnd.GammaEditBox");
	editAvgLumMin	= GetEditBoxHandle("HDRRenderTestWnd.AvgLumMinEditBox");
	editAvgLumMax	= GetEditBoxHandle("HDRRenderTestWnd.AvgLumMaxEditBox");
	
	sliderExposure	= GetSliderCtrlHandle("HDRRenderTestWnd.ExposureSliderCtrl");
	sliderGamma		= GetSliderCtrlHandle("HDRRenderTestWnd.GammaSliderCtrl");
	sliderAvgLumMin	= GetSliderCtrlHandle("HDRRenderTestWnd.AvgLumMinSliderCtrl");
	sliderAvgLumMax	= GetSliderCtrlHandle("HDRRenderTestWnd.AvgLumMaxSliderCtrl");
	
	btnOk		= GetButtonHandle("HDRRenderTestWnd.OkButton");
	btnCancle	= GetButtonHandle("HDRRenderTestWnd.CancleButton");	
	
	PreExposure	= 0.0f;
	PreGamma	= 0.0f;
	PreAvgLumMin	= 0.0f;
	PreAvgLumMax	= 0.0f;
}

function OnEvent(int Event_ID, String param)
{
	local int useHDR;
	local float exposure;
	local float gamma;	
	local float avgLumMin;
	local float avgLumMax;
	
	// event show HDR render
	if (Event_ID == EV_HDRRenderTestWndShow)
	{
		ParseInt( param, "UseHDR", useHDR );
		ParseFloat( param, "FinalCoef", exposure );
		ParseFloat( param, "GrayLum", gamma );
		ParseFloat( param, "ClampMin", avgLumMin );
		ParseFloat( param, "ClampMax", avgLumMax );
		
		InitHDRValue(bool(useHDR), exposure, gamma, avgLumMin, avgLumMax);
	
		btnUse.SetCheck(true);
		btnPreview.SetCheck(true);
		
		// show HDR Render Test wnd
		Me.Showwindow();
		SetUseHDRRenderEffect(true);
	}
}

// 에디트박스를 수정 완료했을 경우 이벤트
function OnCompleteEditBox( string strID )
{
	local float value;
	local int tick;
	
	//
	switch(strID)
	{
	case "ExposureEditBox":
		value = float(editExposure.GetString());
		tick = int(value*TICK_INTERVAL);
		sliderExposure.SetCurrentTick(tick);	
		break;
		
	case "GammaEditBox":
		value = float(editGamma.GetString());
		tick = int(value*TICK_INTERVAL);
		sliderGamma.SetCurrentTick(tick);	
		break;
		
	case "AvgLumMinEditBox":
		value = float(editAvgLumMin.GetString());
		tick = int(value*TICK_INTERVAL);
		sliderAvgLumMin.SetCurrentTick(tick);	
		break;
		
	case "AvgLumMaxEditBox":
		value = float(editAvgLumMax.GetString());
		tick = int(value*TICK_INTERVAL);
		sliderAvgLumMax.SetCurrentTick(tick);			
		break;
	}
	
	if(btnPreview.IsChecked())
	{
		ApplyHDRValue();
	}		
}

// 버튼을 클릭하였을 경우 이벤트
function OnClickButton( string strID )
{
	switch(strID)
	{
	case "OkButton": 
		ApplyHDRValue(); 
		Me.HideWindow();		
		break;
		
	case "CancleButton":
		RestoreHDRValue(); 
		Me.HideWindow();
		break;
	}
}

// 슬라이드 바를 움직일 경우 이벤트
function OnModifyCurrentTickSliderCtrl(string strID, int iCurrentTick)
{
	local float value;
	local string str;
	
	//
	switch(strID)
	{
	case "ExposureSliderCtrl":
		value = float(sliderExposure.GetCurrentTick())/TICK_INTERVAL;
		str = string(value);
		editExposure.SetString(str);	
		break;
		
	case "GammaSliderCtrl":
		value = float(sliderGamma.GetCurrentTick())/TICK_INTERVAL;
		str = string(value);
		editGamma.SetString(str);	
		break;
		
	case "AvgLumMinSliderCtrl":
		value = float(sliderAvgLumMin.GetCurrentTick())/TICK_INTERVAL;
		str = string(value);
		editAvgLumMin.SetString(str);	
		break;
		
	case "AvgLumMaxSliderCtrl":
		value = float(sliderAvgLumMax.GetCurrentTick())/TICK_INTERVAL;
		str = string(value);
		editAvgLumMax.SetString(str);	
		break;
	}
	
	if(btnPreview.IsChecked())
	{
		ApplyHDRValue();
	}		
}

// 체크박스를 클릭하였을 경우 이벤트
function OnClickCheckBox( string strID)
{
	switch(strID)
	{
	case "UseCheckBox": 
		SetUseHDRRenderEffect(btnUse.IsChecked());
		break;
	}
	
	if(btnPreview.IsChecked())
	{
		ApplyHDRValue();
	}		
}

function RestoreHDRValue()
{
	SetUseHDRRenderEffect(PreUseHDR);
	SetHDRRenderVal(PreExposure, PreGamma, PreAvgLumMin, PreAvgLumMax);
}

function InitHDRValue(bool useHDR, float exposure, float gamma, float avgLumMin, float avgLumMax)
{	
	//
	PreUseHDR	= useHDR;
	PreExposure	= exposure;
	PreGamma		= gamma;
	PreAvgLumMin	= avgLumMin;
	PreAvgLumMax	= avgLumMax;	
	
	editExposure.SetString( string(PreExposure) );
	editGamma.SetString( string(PreGamma) );
	editAvgLumMin.SetString( string(PreAvgLumMin) );
	editAvgLumMax.SetString( string(PreAvgLumMax));
	
	sliderExposure.SetCurrentTick(int(PreExposure*TICK_INTERVAL));	
	sliderGamma.SetCurrentTick(int(PreGamma*TICK_INTERVAL));	
	sliderAvgLumMin.SetCurrentTick(int(PreAvgLumMin*TICK_INTERVAL));	
	sliderAvgLumMax.SetCurrentTick(int(PreAvgLumMax*TICK_INTERVAL));	
}

function ApplyHDRValue()
{
	// 
	local float exposure;
	local float gamma;	
	local float avgLumMin;
	local float avgLumMax;
	
	// get HDR value
	exposure	= float(editExposure.GetString());
	gamma		= float(editGamma.GetString());
	avgLumMin	= float(editAvgLumMin.GetString());
	avgLumMax	= float(editAvgLumMax.GetString());
	
	//
	SetHDRRenderVal(exposure, gamma, avgLumMin, avgLumMax);
}
defaultproperties
{
}
