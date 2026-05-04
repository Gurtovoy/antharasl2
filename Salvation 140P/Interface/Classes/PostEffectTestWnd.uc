class PostEffectTestWnd extends UICommonAPI;

var WindowHandle Me;
var SliderCtrlHandle	YCOR1Ctrl;
var SliderCtrlHandle	CbCOR1Ctrl;
var SliderCtrlHandle	CrCOR1Ctrl;
var SliderCtrlHandle	YCOR2Ctrl;
var SliderCtrlHandle	CbCOR2Ctrl;
var SliderCtrlHandle	CrCOR2Ctrl;

var SliderCtrlHandle	HCOR1Ctrl;
var SliderCtrlHandle	SCOR1Ctrl;
var SliderCtrlHandle	VCOR1Ctrl;
var SliderCtrlHandle	HCOR2Ctrl;
var SliderCtrlHandle	SCOR2Ctrl;
var SliderCtrlHandle	VCOR2Ctrl;

var SliderCtrlHandle	RCOR1Ctrl;
var SliderCtrlHandle	GCOR1Ctrl;
var SliderCtrlHandle	BCOR1Ctrl;
var SliderCtrlHandle	RCOR2Ctrl;
var SliderCtrlHandle	GCOR2Ctrl;
var SliderCtrlHandle	BCOR2Ctrl;


var TextBoxHandle txtYCOR1;
var TextBoxHandle txtCbCOR1;
var TextBoxHandle txtCrCOR1;
var TextBoxHandle txtYCOR2;
var TextBoxHandle txtCbCOR2;
var TextBoxHandle txtCrCOR2;

var TextBoxHandle txtHCOR1;
var TextBoxHandle txtSCOR1;
var TextBoxHandle txtVCOR1;
var TextBoxHandle txtHCOR2;
var TextBoxHandle txtSCOR2;
var TextBoxHandle txtVCOR2;

var TextBoxHandle txtRCOR1;
var TextBoxHandle txtGCOR1;
var TextBoxHandle txtBCOR1;
var TextBoxHandle txtRCOR2;
var TextBoxHandle txtGCOR2;
var TextBoxHandle txtBCOR2;

var CheckBoxHandle btnOnlyYChange;
var CheckBoxHandle btnOnlySVChange;

var CheckBoxHandle btnYCbCrShow;
var CheckBoxHandle btnHSVShow;
var CheckBoxHandle btnRGBShow;
var CheckBoxHandle btnColorGradingShow;

var ButtonHandle btnYCbCrCOR1DefaultSet;
var ButtonHandle btnHSVCOR1DefaultSet;
var ButtonHandle btnRGBCOR1DefaultSet;
var ButtonHandle btnYCbCrCOR2DefaultSet;
var ButtonHandle btnHSVCOR2DefaultSet;
var ButtonHandle btnRGBCOR2DefaultSet;

var CheckBoxHandle btnYcbCrRealtime;
var ButtonHandle btnYCbCrAdjust;
var EditBoxHandle editYCbCrTime;

var CheckBoxHandle btnHSVRealtime;
var ButtonHandle btnHSVAdjust;
var EditBoxHandle editHSVTime;

var CheckBoxHandle btnRGBRealtime;
var ButtonHandle btnRGBAdjust;
var EditBoxHandle editRGBTime;



var ButtonHandle btnColorGradingAdjust;
var EditBoxHandle editColorGradingTime;
var EditBoxHandle editColorGradingColor1;
var EditBoxHandle editColorGradingColor2;

var EditBoxHandle editEffectID;
var ButtonHandle btnEffectPlay;

var ComboBoxHandle YCbCrColorOptionComboBox;
var ComboBoxHandle HSVColorOptionComboBox;
var ComboBoxHandle RGBColorOptionComboBox;
var ComboBoxHandle ColorGradingOptionComboBox;

var int YCOR1,CbCOR1,CrCOR1,HCOR1,SCOR1,VCOR1,RCOR1,GCOR1,BCOR1;
var int YCOR2,CbCOR2,CrCOR2,HCOR2,SCOR2,VCOR2,RCOR2,GCOR2,BCOR2;
var float fyCOR1, fcbCOR1, fcrCOR1, fhCOR1, fsCOR1, fvCOR1, frCOR1, fgCOR1, fbCOR1;
var float fyCOR2, fcbCOR2, fcrCOR2, fhCOR2, fsCOR2, fvCOR2, frCOR2, fgCOR2, fbCOR2;
var float YCbCrConsumingTime, HSVConsumingTime, RGBConsumingTime, ColorGradingConsumingTime;

const YCbCr_BAR_LENGTH = 100000.0f;
const YCbCr_YCBCR_LENGTH = 20000.0f;

var float	OnlyY;
var float	OnlySV;

function OnRegisterEvent()
{
	RegisterEvent( EV_PostEffectShow );
}
function Initialize()
{
	if(CREATE_ON_DEMAND==0)
	{
		OnRegisterEvent();
	}

	Me = GetWindowHandle("PostEffectTestWnd");
	CrCOR1Ctrl = GetSliderCtrlHandle("PostEffectTestWnd.CrCOR1SliderCtrl");
	YCOR1Ctrl = GetSliderCtrlHandle("PostEffectTestWnd.YCOR1SliderCtrl");
	CbCOR1Ctrl = GetSliderCtrlHandle("PostEffectTestWnd.CbCOR1SliderCtrl");
	HCOR1Ctrl = GetSliderCtrlHandle("PostEffectTestWnd.HCOR1SliderCtrl");
	SCOR1Ctrl = GetSliderCtrlHandle("PostEffectTestWnd.SCOR1SliderCtrl");
	VCOR1Ctrl = GetSliderCtrlHandle("PostEffectTestWnd.VCOR1SliderCtrl");
	RCOR1Ctrl = GetSliderCtrlHandle("PostEffectTestWnd.RCOR1SliderCtrl");
	GCOR1Ctrl = GetSliderCtrlHandle("PostEffectTestWnd.GCOR1SliderCtrl");
	BCOR1Ctrl = GetSliderCtrlHandle("PostEffectTestWnd.BCOR1SliderCtrl");

	CrCOR2Ctrl = GetSliderCtrlHandle("PostEffectTestWnd.CrCOR2SliderCtrl");
	YCOR2Ctrl = GetSliderCtrlHandle("PostEffectTestWnd.YCOR2SliderCtrl");
	CbCOR2Ctrl = GetSliderCtrlHandle("PostEffectTestWnd.CbCOR2SliderCtrl");
	HCOR2Ctrl = GetSliderCtrlHandle("PostEffectTestWnd.HCOR2SliderCtrl");
	SCOR2Ctrl = GetSliderCtrlHandle("PostEffectTestWnd.SCOR2SliderCtrl");
	VCOR2Ctrl = GetSliderCtrlHandle("PostEffectTestWnd.VCOR2SliderCtrl");
	RCOR2Ctrl = GetSliderCtrlHandle("PostEffectTestWnd.RCOR2SliderCtrl");
	GCOR2Ctrl = GetSliderCtrlHandle("PostEffectTestWnd.GCOR2SliderCtrl");
	BCOR2Ctrl = GetSliderCtrlHandle("PostEffectTestWnd.BCOR2SliderCtrl");

	txtYCOR1 = GetTextBoxHandle ( "PostEffectTestWnd.YCOR1TextBox" );
	txtCbCOR1 = GetTextBoxHandle ( "PostEffectTestWnd.CbCOR1TextBox" );
	txtCrCOR1 = GetTextBoxHandle ( "PostEffectTestWnd.CrCOR1TextBox" );
	txtHCOR1 = GetTextBoxHandle ( "PostEffectTestWnd.HCOR1TextBox" );
	txtSCOR1 = GetTextBoxHandle ( "PostEffectTestWnd.SCOR1TextBox" );
	txtVCOR1 = GetTextBoxHandle ( "PostEffectTestWnd.VCOR1TextBox" );
	txtRCOR1 = GetTextBoxHandle ( "PostEffectTestWnd.RCOR1TextBox" );
	txtGCOR1 = GetTextBoxHandle ( "PostEffectTestWnd.GCOR1TextBox" );
	txtBCOR1 = GetTextBoxHandle ( "PostEffectTestWnd.BCOR1TextBox" );

	txtYCOR2 = GetTextBoxHandle ( "PostEffectTestWnd.YCOR2TextBox" );
	txtCbCOR2 = GetTextBoxHandle ( "PostEffectTestWnd.CbCOR2TextBox" );
	txtCrCOR2 = GetTextBoxHandle ( "PostEffectTestWnd.CrCOR2TextBox" );
	txtHCOR2 = GetTextBoxHandle ( "PostEffectTestWnd.HCOR2TextBox" );
	txtSCOR2 = GetTextBoxHandle ( "PostEffectTestWnd.SCOR2TextBox" );
	txtVCOR2 = GetTextBoxHandle ( "PostEffectTestWnd.VCOR2TextBox" );
	txtRCOR2 = GetTextBoxHandle ( "PostEffectTestWnd.RCOR2TextBox" );
	txtGCOR2 = GetTextBoxHandle ( "PostEffectTestWnd.GCOR2TextBox" );
	txtBCOR2 = GetTextBoxHandle ( "PostEffectTestWnd.BCOR2TextBox" );

	btnOnlyYChange = GetCheckBoxHandle("PostEffectTestWnd.OnlyYChangeCheckBox");
	btnOnlySVChange = GetCheckBoxHandle("PostEffectTestWnd.OnlySVChangeCheckBox");
	btnYCbCrShow = GetCheckBoxHandle("PostEffectTestWnd.YCbCrShowCheckBox");
	btnHSVShow = GetCheckBoxHandle("PostEffectTestWnd.HSVShowCheckBox");
	btnRGBShow = GetCheckBoxHandle("PostEffectTestWnd.RGBShowCheckBox");
	btnColorGradingShow = GetCheckBoxHandle("PostEffectTestWnd.ColorGradingShowCheckBox");

	btnYCbCrCOR1DefaultSet = GetButtonHandle("PostEffectTestWnd.YCbCrCOR1DefaultSetButton");
	btnHSVCOR1DefaultSet = GetButtonHandle("PostEffectTestWnd.HSVCOR1DefaultSetButton");
	btnRGBCOR1DefaultSet = GetButtonHandle("PostEffectTestWnd.RGBCOR1DefaultSetButton");

	btnYcbCrRealtime = GetCheckBoxHandle("PostEffectTestWnd.YCbCrAdjustCheckBox");
	btnYCbCrAdjust = GetButtonHandle("PostEffectTestWnd.YCbCrAdjustButton");
	editYCbCrTime = GetEditBoxHandle("PostEffectTestWnd.YCbCrTimeEditBox");

	btnHSVRealtime = GetCheckBoxHandle("PostEffectTestWnd.HSVAdjustCheckBox");
	btnHSVAdjust = GetButtonHandle("PostEffectTestWnd.HSVAdjustButton");
	editHSVTime = GetEditBoxHandle("PostEffectTestWnd.HSVTimeEditBox");


	btnRGBRealtime = GetCheckBoxHandle("PostEffectTestWnd.RGBAdjustCheckBox");
	btnRGBAdjust = GetButtonHandle("PostEffectTestWnd.RGBAdjustButton");
	editRGBTime = GetEditBoxHandle("PostEffectTestWnd.RGBTimeEditBox");

	btnColorGradingAdjust = GetButtonHandle("PostEffectTestWnd.ColorGradingAdjustButton");
	editColorGradingTime = GetEditBoxHandle("PostEffectTestWnd.ColorGradingTimeEditBox");
	editColorGradingColor1 = GetEditBoxHandle("PostEffectTestWnd.ColorGrading1EditBox");
	editColorGradingColor2 = GetEditBoxHandle("PostEffectTestWnd.ColorGrading2EditBox");

	editEffectID = GetEditBoxHandle("PostEffectTestWnd.EffectIDEditBox");
	btnEffectPlay = GetButtonHandle("PostEffectTestWnd.PostEffectPlayButton");


	YCbCrColorOptionComboBox = GetComboBoxHandle("PostEffectTestWnd.YCbCrColorOptionComboBox");
	HSVColorOptionComboBox = GetComboBoxHandle("PostEffectTestWnd.HSVColorOptionComboBox");
	RGBColorOptionComboBox = GetComboBoxHandle("PostEffectTestWnd.RGBColorOptionComboBox");
	ColorGradingOptionComboBox = GetComboBoxHandle("PostEffectTestWnd.ColorGradingOptionComboBox");

	YCbCrColorOptionComboBox.AddString("0: Cor1TOCor2");
	YCbCrColorOptionComboBox.AddString("1: OrgTOCor2");
	YCbCrColorOptionComboBox.AddString("2: Cor1TOOrg");

	HSVColorOptionComboBox.AddString("1: OrgTOCor2");
	HSVColorOptionComboBox.AddString("2: Cor1TOOrg");

	RGBColorOptionComboBox.AddString("0: Cor1TOCor2");
	RGBColorOptionComboBox.AddString("1: OrgTOCor2");
	RGBColorOptionComboBox.AddString("2: Cor1TOOrg");

	ColorGradingOptionComboBox.AddString("0: Cor1TOCor2");
	ColorGradingOptionComboBox.AddString("1: OrgTOCor2");
	ColorGradingOptionComboBox.AddString("2: Cor1TOOrg");


	YCOR1 = int(YCbCr_YCBCR_LENGTH);
	YCOR2 = int(YCbCr_YCBCR_LENGTH);
	CbCOR1 = int(YCbCr_YCBCR_LENGTH);
	CbCOR2 = int(YCbCr_YCBCR_LENGTH);
	CrCOR1 = int(YCbCr_YCBCR_LENGTH);
	CrCOR2 = int(YCbCr_YCBCR_LENGTH);

	HCOR1 = int((YCbCr_BAR_LENGTH+YCbCr_YCBCR_LENGTH)/2);
	HCOR2 = int((YCbCr_BAR_LENGTH+YCbCr_YCBCR_LENGTH)/2);
	SCOR1 = int(YCbCr_YCBCR_LENGTH);
	SCOR2 = int(YCbCr_YCBCR_LENGTH);
	VCOR1 = int(YCbCr_YCBCR_LENGTH);
	VCOR2 = int(YCbCr_YCBCR_LENGTH);

	RCOR1 = int(YCbCr_YCBCR_LENGTH);
	RCOR2 = int(YCbCr_YCBCR_LENGTH);
	GCOR1 = int(YCbCr_YCBCR_LENGTH);
	GCOR2 = int(YCbCr_YCBCR_LENGTH);
	BCOR1 = int(YCbCr_YCBCR_LENGTH);
	BCOR2 = int(YCbCr_YCBCR_LENGTH);

	fyCOR1 = 1.0f;
	fyCOR2 = 1.0f;
	fcbCOR1 = 1.0f;
	fcbCOR2 = 1.0f;
	fcrCOR1 = 1.0f;
	fcrCOR2 = 1.0f;

	fhCOR1 = 1.0f;
	fhCOR2 = 1.0f;
	fsCOR1 = 1.0f;
	fsCOR2 = 1.0f;
	fvCOR1 = 1.0f;
	fvCOR2 = 1.0f;

	frCOR1 = 1.0f;
	frCOR2 = 1.0f;
	fgCOR1 = 1.0f;
	fgCOR2 = 1.0f;
	fbCOR1 = 1.0f;
	fbCOR2 = 1.0f;

	YCbCrConsumingTime = 0.f;
	HSVConsumingTime = 0.f;
	RGBConsumingTime = 0.f;
	ColorGradingConsumingTime = 0.f;

	OnlyY = 0.f;
	OnlySV = 0.f;

	YCbCrCOR1DefaultSet();
	HSVCOR1DefaultSet();
	RGBCOR1DefaultSet();

	YCbCrCOR2DefaultSet();
	HSVCOR2DefaultSet();
	RGBCOR2DefaultSet();


	///HSV Disable....
	///Pixel shader 2.0의 명령어개수 제한때문에 HSV는 추가 기능 제외.
//	HCOR2Ctrl.DisableWindow();
//	SCOR2Ctrl.DisableWindow();
//	VCOR2Ctrl.DisableWindow();
//	HCOR2Ctrl.HideWindow();
//	SCOR2Ctrl.HideWindow();
//	VCOR2Ctrl.HideWindow();
//	txtHCOR2.HideWindow();
//	txtSCOR2.HideWindow();
//	txtVCOR2.HideWindow();

}
function OnLoad()
{
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();
	Initialize();

}
function OnClickButton( string strID )
{
	switch(strID)
	{

	case "YCbCrCOR1DefaultSetButton": // default set
		YCbCrCOR1DefaultSet();
		break;
	case "HSVCOR1DefaultSetButton":
		HSVCOR1DefaultSet();
		break;
	case "RGBCOR1DefaultSetButton":
		RGBCOR1DefaultSet();
		break;
	case "YCbCrCOR2DefaultSetButton": // default set
		YCbCrCOR2DefaultSet();
		break;
	case "HSVCOR2DefaultSetButton":
		HSVCOR2DefaultSet();
		break;
	case "RGBCOR2DefaultSetButton":
		RGBCOR2DefaultSet();
		break;
	case "YCbCrAdjustButton":
		YCbCrAdjust();
		break;
	case "HSVAdjustButton":
		HSVAdjust();
		break;
	case "RGBAdjustButton":
		RGBAdjust();
		break;
	case "ColorGradingAdjustButton":
		ColorGradingAdjust();
		break;
	case "PostEffectPlayButton":
		EffectPlay();
		break;
	case "AllDeleteButton":
		DeleteAllEffect();
		break;
	
	}
}
// 체크박스를 클릭하였을 경우 이벤트
function OnClickCheckBox( string strID)
{
	switch(strID)
	{
	case "OnlyYChangeCheckBox": 
		AdjustOnlyY();
		break;
	case "OnlySVChangeCheckBox": 
		AdjustOnlySV();
		break;
	case "YCbCrShowCheckBox": // show
		YCbCrShow();		
		break;
	case "HSVShowCheckBox":
		HSVShow();
		break;
	case "RGBShowCheckBox":
		RGBShow();
		break;
	case "ColorGradingShowCheckBox":
		ColorGradingShow();
		break;
	}

}
function AdjustOnlyY()
{
	
	if (btnOnlyYChange.IsChecked())
	{
		OnlyY = 1.f;
	}
	else
	{
		OnlyY = 0.f;
	}
}
function AdjustOnlySV()
{
	if (btnOnlySVChange.IsChecked())
	{			
		OnlySV = 1.f;
	}
	else
	{
		OnlySV = 0.f;
	}
}
function OnModifyCurrentTickSliderCtrl(string strID, int iCurrentTick)
{	
	
	debug(strID);
	switch(strID)
	{
	case "YCOR1SliderCtrl": //y
		YCbCrYCOR1Set();
		break;
	case "CbCOR1SliderCtrl" : //cb
		YCbCrCBCOR1Set();	
		break;
	case "CrCOR1SliderCtrl" : //cr
		YCbCrCRCOR1Set();			
		break;

	case "YCOR2SliderCtrl": //y
		YCbCrYCOR2Set();
		break;
	case "CbCOR2SliderCtrl" : //cb
		YCbCrCBCOR2Set();	
		break;
	case "CrCOR2SliderCtrl" : //cr
		YCbCrCRCOR2Set();			
		break;

	case "HCOR1SliderCtrl": //h
		HSVHCOR1Set();
		break;
	case "SCOR1SliderCtrl" : //S
		HSVSCOR1Set();	
		break;
	case "VCOR1SliderCtrl" : //V
		HSVVCOR1Set();
		break;
	case "HCOR2SliderCtrl": //h
		HSVHCOR2Set();
		break;
	case "SCOR2SliderCtrl" : //S
		HSVSCOR2Set();	
		break;
	case "VCOR2SliderCtrl" : //V
		HSVVCOR2Set();
		break;

	case "RCOR1SliderCtrl": //r
		RGBRCOR1Set();
		break;
	case "GCOR1SliderCtrl" : //g
		RGBGCOR1Set();	
		break;
	case "BCOR1SliderCtrl" : //b
		RGBBCOR1Set();
		break;
	case "RCOR2SliderCtrl": //r
		RGBRCOR2Set();
		break;
	case "GCOR2SliderCtrl" : //g
		RGBGCOR2Set();	
		break;
	case "BCOR2SliderCtrl" : //b
		RGBBCOR2Set();
		break;


	}

}
function YCbCrShow()
{
	RequestSetYCbCrConversionEffect(btnYCbCrShow.IsChecked());
}
function HSVShow()
{
	RequestSetHSVConversionEffect(btnHSVShow.IsChecked());
}
function RGBShow()
{
	RequestSetRGBConversionEffect(btnRGBShow.IsChecked());
}
function ColorGradingShow()
{
	RequestSetColorGradingEffect(btnColorGradingShow.IsChecked());
}
function YCbCrYCOR1Set()
{
	YCOR1 = YCOR1Ctrl.GetCurrentTick();
	fyCOR1 = float(YCOR1)/YCbCr_YCBCR_LENGTH;
	txtYCOR1.SetText( fyCOR1 @"배");

	

	if ( btnYcbCrRealtime.IsChecked())
	{
		RequestSetYCbCrVal(OnlyY, YCbCrColorOptionComboBox.GetSelectedNum(), fyCOR1, fcbCOR1, fcrCOR1, fyCOR2, fcbCOR2, fcrCOR2, 0.f);
	}
}
function YCbCrYCOR2Set()
{
	YCOR2 = YCOR2Ctrl.GetCurrentTick();
	fyCOR2 = float(YCOR2)/YCbCr_YCBCR_LENGTH;
	txtYCOR2.SetText( fyCOR2 @"배");

	if ( btnYcbCrRealtime.IsChecked())
	{
		RequestSetYCbCrVal(OnlyY, YCbCrColorOptionComboBox.GetSelectedNum(), fyCOR1, fcbCOR1, fcrCOR1, fyCOR2, fcbCOR2, fcrCOR2, 0.f);
	}
}
function HSVHCOR1Set()
{
	HCOR1 = HCOR1Ctrl.GetCurrentTick();
	fhCOR1 = float(HCOR1) / YCbCr_BAR_LENGTH;
	txtHCOR1.SetText(fhCOR1@"H");
	if ( btnHSVRealtime.IsChecked())
	{
		RequestSetHSVVal(OnlySV, HSVColorOptionComboBox.GetSelectedNum()+1, fhCOR1,fsCOR1,fvCOR1, fhCOR2,fsCOR2,fvCOR2, 0.f);
	}
}
function HSVHCOR2Set()
{
	HCOR2 = HCOR2Ctrl.GetCurrentTick();
	fhCOR2 = float(HCOR2) / YCbCr_BAR_LENGTH;
	txtHCOR2.SetText(fhCOR2@"H");
	if ( btnHSVRealtime.IsChecked())
	{
		RequestSetHSVVal(OnlySV, HSVColorOptionComboBox.GetSelectedNum()+1, fhCOR1,fsCOR1,fvCOR1, fhCOR2,fsCOR2,fvCOR2, 0.f);
	}
}
function RGBRCOR1Set()
{
	RCOR1 = RCOR1Ctrl.GetCurrentTick();
	frCOR1 = float(RCOR1)/YCbCr_YCBCR_LENGTH;
	txtRCOR1.SetText(frCOR1@"배");
	if ( btnRGBRealtime.IsChecked())
	{
		RequestSetRGBVal(RGBColorOptionComboBox.GetSelectedNum() ,frCOR1,fgCOR1,fbCOR1, frCOR2,fgCOR2,fbCOR2, 0.f);
	}
}
function RGBRCOR2Set()
{
	RCOR2 = RCOR2Ctrl.GetCurrentTick();
	frCOR2 = float(RCOR2)/YCbCr_YCBCR_LENGTH;
	txtRCOR2.SetText(frCOR2@"배");
	if ( btnRGBRealtime.IsChecked())
	{
		RequestSetRGBVal(RGBColorOptionComboBox.GetSelectedNum(), frCOR1,fgCOR1,fbCOR1, frCOR2,fgCOR2,fbCOR2, 0.f);
	}
}

function YCbCrCBCOR1Set()
{
	CbCOR1 = CbCOR1Ctrl.GetCurrentTick();
		
	fcbCOR1 = float(CbCOR1)/YCbCr_BAR_LENGTH  - 0.5;	// -0.5 ~ 0.5
	txtCbCOR1.SetText(fcbCOR1@"Cb");
	
	if ( btnYcbCrRealtime.IsChecked())
	{
		RequestSetYCbCrVal(OnlyY, YCbCrColorOptionComboBox.GetSelectedNum(), fyCOR1, fcbCOR1, fcrCOR1, fyCOR2, fcbCOR2, fcrCOR2,0.f);
	}

}
function YCbCrCBCOR2Set()
{
	CbCOR2 = CbCOR2Ctrl.GetCurrentTick();
		
	fcbCOR2 = float(CbCOR2)/YCbCr_BAR_LENGTH  - 0.5;	// -0.5 ~ 0.5
	txtCbCOR2.SetText(fcbCOR2@"Cb");
	
	if ( btnYcbCrRealtime.IsChecked())
	{
		RequestSetYCbCrVal(OnlyY, YCbCrColorOptionComboBox.GetSelectedNum(), fyCOR1, fcbCOR1, fcrCOR1, fyCOR2, fcbCOR2, fcrCOR2,0.f);
	}

}
function HSVSCOR1Set()
{
	SCOR1 = SCOR1Ctrl.GetCurrentTick();
	fsCOR1 = float(SCOR1)/YCbCr_YCBCR_LENGTH;
	txtSCOR1.SetText(fsCOR1@"배");
	if ( btnHSVRealtime.IsChecked())
	{
		RequestSetHSVVal(OnlySV, HSVColorOptionComboBox.GetSelectedNum()+1, fhCOR1,fsCOR1,fvCOR1, fhCOR2,fsCOR2,fvCOR2,0.f);
	}
}
function HSVSCOR2Set()
{
	SCOR2 = SCOR2Ctrl.GetCurrentTick();
	fsCOR2 = float(SCOR2)/YCbCr_YCBCR_LENGTH;
	txtSCOR2.SetText(fsCOR2@"배");
	if ( btnHSVRealtime.IsChecked())
	{
		RequestSetHSVVal(OnlySV, HSVColorOptionComboBox.GetSelectedNum()+1, fhCOR1,fsCOR1,fvCOR1, fhCOR2,fsCOR2,fvCOR2,0.f);
	}
}

function RGBGCOR1Set()
{
	GCOR1 = GCOR1Ctrl.GetCurrentTick();
	fgCOR1 = float(GCOR1)/YCbCr_YCBCR_LENGTH;
	txtGCOR1.SetText(fgCOR1@"배");
	if ( btnRGBRealtime.IsChecked())
	{
		RequestSetRGBVal(RGBColorOptionComboBox.GetSelectedNum(), frCOR1,fgCOR1,fbCOR1, frCOR2,fgCOR2,fbCOR2, 0.f);
	}
}

function RGBGCOR2Set()
{
	GCOR2 = GCOR2Ctrl.GetCurrentTick();
	fgCOR2 = float(GCOR2)/YCbCr_YCBCR_LENGTH;
	txtGCOR2.SetText(fgCOR2@"배");
	if ( btnRGBRealtime.IsChecked())
	{
		RequestSetRGBVal(RGBColorOptionComboBox.GetSelectedNum(), frCOR1,fgCOR1,fbCOR1, frCOR2,fgCOR2,fbCOR2, 0.f);
	}
}

function YCbCrCRCOR1Set()
{
	CrCOR1 = CrCOR1Ctrl.GetCurrentTick();
			
	fcrCOR1 = float(CrCOR1)/ YCbCr_BAR_LENGTH  - 0.5; // -0.5 ~ 0.5
	txtCrCOR1.SetText(fcrCOR1@"Cr");

	if ( btnYcbCrRealtime.IsChecked())
	{
		RequestSetYCbCrVal(OnlyY, YCbCrColorOptionComboBox.GetSelectedNum(), fyCOR1, fcbCOR1, fcrCOR1, fyCOR2, fcbCOR2, fcrCOR2,0.f);
	}
}
function YCbCrCRCOR2Set()
{
	CrCOR2 = CrCOR2Ctrl.GetCurrentTick();
			
	fcrCOR2 = float(CrCOR2)/ YCbCr_BAR_LENGTH  - 0.5; // -0.5 ~ 0.5
	txtCrCOR2.SetText(fcrCOR2@"Cr");

	if ( btnYcbCrRealtime.IsChecked())
	{
		RequestSetYCbCrVal(OnlyY, YCbCrColorOptionComboBox.GetSelectedNum(), fyCOR1, fcbCOR1, fcrCOR1, fyCOR2, fcbCOR2, fcrCOR2,0.f);
	}
}
function HSVVCOR1Set()
{
	VCOR1 = VCOR1Ctrl.GetCurrentTick();
	fvCOR1 = float(VCOR1)/YCbCr_YCBCR_LENGTH;
	txtVCOR1.SetText(fvCOR1@"배");
	if ( btnHSVRealtime.IsChecked())
	{
		RequestSetHSVVal(OnlySV,  HSVColorOptionComboBox.GetSelectedNum()+1, fhCOR1,fsCOR1,fvCOR1, fhCOR2,fsCOR2,fvCOR2, 0.f);
	}
}
function HSVVCOR2Set()
{
	VCOR2 = VCOR2Ctrl.GetCurrentTick();
	fvCOR2 = float(VCOR2)/YCbCr_YCBCR_LENGTH;
	txtVCOR2.SetText(fvCOR2@"배");
	if ( btnHSVRealtime.IsChecked())
	{
		RequestSetHSVVal(OnlySV,  HSVColorOptionComboBox.GetSelectedNum()+1, fhCOR1,fsCOR1,fvCOR1, fhCOR2,fsCOR2,fvCOR2, 0.f);
	}
}
function RGBBCOR1Set()
{
	BCOR1 = BCOR1Ctrl.GetCurrentTick();
	fbCOR1 = float(BCOR1)/YCbCr_YCBCR_LENGTH;
	txtBCOR1.SetText(fbCOR1@"배");
	if ( btnRGBRealtime.IsChecked())
	{
		RequestSetRGBVal(RGBColorOptionComboBox.GetSelectedNum(), frCOR1,fgCOR1,fbCOR1, frCOR2,fgCOR2,fbCOR2,0.f);
	}
}
function RGBBCOR2Set()
{
	BCOR2 = BCOR2Ctrl.GetCurrentTick();
	fbCOR2 = float(BCOR2)/YCbCr_YCBCR_LENGTH;
	txtBCOR2.SetText(fbCOR2@"배");
	if ( btnRGBRealtime.IsChecked())
	{
		RequestSetRGBVal(RGBColorOptionComboBox.GetSelectedNum(), frCOR1,fgCOR1,fbCOR1, frCOR2,fgCOR2,fbCOR2,0.f);
	}
}
function YCbCrCOR1DefaultSet()
{

	fyCOR1 = 1.0f;
	fcbCOR1 = 0.0f;
	fcrCOR1 = 0.0f;
	

	YCOR1Ctrl.SetCurrentTick(int(YCbCr_YCBCR_LENGTH));
	CbCOR1Ctrl.SetCurrentTick(int(YCbCr_BAR_LENGTH/2));
 	CrCOR1Ctrl.SetCurrentTick(int(YCbCr_BAR_LENGTH/2));

	YCbCrYCOR1Set();
	YCbCrCBCOR1Set();
	YCbCrCRCOR1Set();

}
function YCbCrCOR2DefaultSet()
{

	fyCOR2 = 1.0f;
	fcbCOR2 = 0.0f;
	fcrCOR2 = 0.0f;
	

	YCOR2Ctrl.SetCurrentTick(int(YCbCr_YCBCR_LENGTH));
	CbCOR2Ctrl.SetCurrentTick(int(YCbCr_BAR_LENGTH/2));
 	CrCOR2Ctrl.SetCurrentTick(int(YCbCr_BAR_LENGTH/2));

	YCbCrYCOR2Set();
	YCbCrCBCOR2Set();
	YCbCrCRCOR2Set();

}
function HSVCOR1DefaultSet()
{
	fhCOR1 = 0.0f;
	fsCOR1 = 1.0f;
	fvCOR1 = 1.0f;

	HCOR1Ctrl.SetCurrentTick(int((YCbCr_BAR_LENGTH+YCbCr_YCBCR_LENGTH)/2));
	SCOR1Ctrl.SetCurrentTick(int(YCbCr_YCBCR_LENGTH));
 	VCOR1Ctrl.SetCurrentTick(int(YCbCr_YCBCR_LENGTH));

	HSVHCOR1Set();
	HSVSCOR1Set();
	HSVVCOR1Set();
}
function HSVCOR2DefaultSet()
{
	fhCOR2 = 0.0f;
	fsCOR2 = 1.0f;
	fvCOR2 = 1.0f;

	HCOR2Ctrl.SetCurrentTick(int((YCbCr_BAR_LENGTH+YCbCr_YCBCR_LENGTH)/2));
	SCOR2Ctrl.SetCurrentTick(int(YCbCr_YCBCR_LENGTH));
 	VCOR2Ctrl.SetCurrentTick(int(YCbCr_YCBCR_LENGTH));

	HSVHCOR2Set();
	HSVSCOR2Set();
	HSVVCOR2Set();
}
function RGBCOR1DefaultSet()
{
	frCOR1 = 1.0f;
	fgCOR1 = 1.0f;
	fbCOR1 = 1.0f;

	RCOR1Ctrl.SetCurrentTick(int(YCbCr_YCBCR_LENGTH));
	GCOR1Ctrl.SetCurrentTick(int(YCbCr_YCBCR_LENGTH));
 	BCOR1Ctrl.SetCurrentTick(int(YCbCr_YCBCR_LENGTH));

	RGBRCOR1Set();
	RGBGCOR1Set();
	RGBBCOR1Set();
}
function RGBCOR2DefaultSet()
{
	frCOR2 = 1.0f;
	fgCOR2 = 1.0f;
	fbCOR2 = 1.0f;

	RCOR2Ctrl.SetCurrentTick(int(YCbCr_YCBCR_LENGTH));
	GCOR2Ctrl.SetCurrentTick(int(YCbCr_YCBCR_LENGTH));
 	BCOR2Ctrl.SetCurrentTick(int(YCbCr_YCBCR_LENGTH));

	RGBRCOR2Set();
	RGBGCOR2Set();
	RGBBCOR2Set();
}


function YCbCrAdjust()
{
	//
	YCbCrConsumingTime = float(editYCbCrTime.GetString());
	if( !btnYcbCrRealtime.IsChecked() )
	{
		RequestSetYCbCrVal(OnlyY,YCbCrColorOptionComboBox.GetSelectedNum(), fyCOR1, fcbCOR1, fcrCOR1, fyCOR2, fcbCOR2, fcrCOR2, YCbCrConsumingTime);	
		if (YCbCrConsumingTime != 0 && YCbCrColorOptionComboBox.GetSelectedNum() == 2)
		{
			btnYCbCrShow.SetCheck(false);
		}
	}
}
function HSVAdjust()
{
	//
	HSVConsumingTime = float(editHSVTime.GetString());
	if( !btnHSVRealtime.IsChecked() )
	{
		RequestSetHSVVal(OnlySV, HSVColorOptionComboBox.GetSelectedNum()+1, fhCOR1, fsCOR1, fvCOR1, fhCOR2, fsCOR2, fvCOR2, HSVConsumingTime);	

		if (HSVConsumingTime != 0 && HSVColorOptionComboBox.GetSelectedNum()+1 == 2)
		{	
			btnHSVShow.SetCheck(false);
		}

	}
}
function RGBAdjust()
{
	//
	RGBConsumingTime = float(editRGBTime.GetString());
	if( !btnRGBRealtime.IsChecked() )
	{
		RequestSetRGBVal(RGBColorOptionComboBox.GetSelectedNum(), frCOR1, fgCOR1, fbCOR1, frCOR2, fgCOR2, fbCOR2, RGBConsumingTime);	
		if (RGBConsumingTime != 0 && RGBColorOptionComboBox.GetSelectedNum() == 2)
		{
			btnRGBShow.SetCheck(false);
		}
	}
}
function ColorGradingAdjust()
{
	ColorGradingConsumingTime =  float(editColorGradingTime.GetString());
	RequestSetColorGradingVal(ColorGradingOptionComboBox.GetSelectedNum(), editColorGradingColor1.GetString(), editColorGradingColor2.GetString(), ColorGradingConsumingTime);
	if (ColorGradingConsumingTime != 0 && ColorGradingOptionComboBox.GetSelectedNum() == 2)
	{
		btnColorGradingShow.SetCheck(false);
	}
	
}
function EffectPlay()
{
	local int effectid;
	effectid = int(editEffectID.GetString());
	if (effectid >= 0)
		RequestSetPostEffect(true, effectid);
}
function DeleteAllEffect()
{
	btnYCbCrShow.SetCheck(false);
	btnHSVShow.SetCheck(false);
	btnRGBShow.SetCheck(false);
	btnColorGradingShow.SetCheck(false);

	RequestSetYCbCrConversionEffect(btnYCbCrShow.IsChecked());
	RequestSetHSVConversionEffect(btnHSVShow.IsChecked());
	RequestSetRGBConversionEffect(btnRGBShow.IsChecked());
	RequestSetColorGradingEffect(btnColorGradingShow.IsChecked());
	SetMotionBlurAlpha(255.0f);
}

function OnShow()
{

}

function OnHide()
{

}

function OnEvent(int Event_ID, String param)
{
	//debug("debug@" @ Event_ID);
	if (Event_ID == EV_PostEffectShow)
	{
		Me.Showwindow();
	}
}
defaultproperties
{
}
