class HairshopWnd extends UICommonAPI;

const NUMCOLORSPACE = 2; // 그럴일은 없겠지만 colorspace 수 증가하면 필요함
						 // 0 : RGB, 1 : HSV
var WindowHandle Me;
var SliderCtrlHandle RHColorCtrl[NUMCOLORSPACE];
var SliderCtrlHandle GSColorCtrl[NUMCOLORSPACE];
var SliderCtrlHandle BVColorCtrl[NUMCOLORSPACE];

var int colorspaceIndex;
var ComboBoxHandle ColorspaceBox;
var ComboBoxHandle hairTypeBox;

var CheckBoxHandle NewHairUseBox;
var CheckBoxHandle HairColorUseBox;

var ButtonHandle btnClose;
var EditBoxHandle RHColorBox;
var EditBoxHandle GSColorBox;
var EditBoxHandle BVColorBox;

var bool bUseNewHair;
var bool bUseHairColor;
var int gHairtype;
var int nColorRH[2];// hue
var int nColorGS[2];// saturation
var int nColorBV[2]; // value(brightness)

var int savedHairtype;
function OnRegisterEvent()
{
	RegisterEvent( EV_UpdateHairColorData );
}

function OnLoad()
{
	SetClosingOnESC();
	Initialize();

	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();
}

function Initialize()
{
	local int i;
	Me = GetWindowHandle( "HairshopWnd" );
	
	RHColorCtrl[0] = GetSliderCtrlHandle( "HairshopWnd.RColorCtrl" );
	GSColorCtrl[0] = GetSliderCtrlHandle( "HairshopWnd.GColorCtrl" );
	BVColorCtrl[0] = GetSliderCtrlHandle( "HairshopWnd.BColorCtrl" );

	RHColorCtrl[1] = GetSliderCtrlHandle( "HairshopWnd.HColorCtrl" );
	GSColorCtrl[1] = GetSliderCtrlHandle( "HairshopWnd.SColorCtrl" );
	BVColorCtrl[1] = GetSliderCtrlHandle( "HairshopWnd.VColorCtrl" );

	ColorspaceBox = GetComboBoxHandle( "HairshopWnd.ColorspaceBox" );
	hairTypeBox = GetComboBoxHandle( "HairshopWnd.hairTypeBox" );

	NewHairUseBox = GetCheckBoxHandle( "HairshopWnd.NewHairUseBox" );
	HairColorUseBox = GetCheckBoxHandle( "HairshopWnd.HairColorUseBox" );
	btnClose = GetButtonHandle( "HairshopWnd.btnClose" );
	
	RHColorBox = GetEditBoxHandle( "HairshopWnd.RColorBox" );
	GSColorBox = GetEditBoxHandle( "HairshopWnd.GColorBox" );
	BVColorBox = GetEditBoxHandle( "HairshopWnd.BColorBox" );

	colorspaceIndex = 0;
	gHairtype = 0;
	
	updateHairColorData();

	for( i=0; i<NUMCOLORSPACE; i++)
	{
		hideAllSliderBar(i);
	}
	for(i=0; i<gHairType; i++)
	{
		hairTypeBox.AddString(ConvertNumToTextNoAdena(string(i)));
	}
	showAllSliderBar(colorspaceIndex);
	setRGBTextBox(nColorRH[colorspaceIndex], nColorGS[colorspaceIndex], nColorBV[colorspaceIndex]);

	savedHairtype = 0;
}

function OnEvent(int Event_ID, string param)
{
	switch(Event_ID)
	{
	case EV_UpdateHairColorData:
		handleHairColorData(param);
		break;
	}
}
function OnClickCheckBox( String strID )
{
	applyData();
}

function OnClickButton( string Name )
{
	switch( Name )
	{
	case "btnClose":
		OnbtnCloseClick();
		break;
	}
}
function OnComboBoxItemSelected( String strID, int index )
{
	local int i;
	if( strID == "ColorspaceBox")
	{
		colorspaceIndex = index;

		for(i = 0; i < NUMCOLORSPACE; i++)
		{
			if( i == index)
				showAllSliderBar(i);
			else
				hideAllSliderBar(i);
		}
		setRGBTextBox(nColorRH[colorspaceIndex], nColorGS[colorspaceIndex], nColorBV[colorspaceIndex]);
	}
	else if( strID == "hairTypeBox")
	{
		class'HairshopAPI'.static.ApplyHairType(index);
		savedhairtype = index;
	}

}
function showAllSliderBar(int idx)
{
	RHColorCtrl[idx].ShowWindow();
	GSColorCtrl[idx].ShowWindow();
	BVColorCtrl[idx].ShowWindow();
}
function hideAllSliderBar(int idx)
{
	RHColorCtrl[idx].HideWindow();
	GSColorCtrl[idx].HideWindow();
	BVColorCtrl[idx].HideWindow();
}
function OnbtnCloseClick()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	Me.HideWindow();	
}
function OnModifyCurrentTickSliderCtrl(string strID, int iCurrentTick)
{
	switch(strID)
	{
	case "RColorCtrl":
	case "GColorCtrl":
	case "BColorCtrl":
	case "HColorCtrl":
	case "SColorCtrl":
	case "VColorCtrl":
		applyData();	
		setRGBTextBox(nColorRH[colorspaceIndex], nColorGS[colorspaceIndex], nColorBV[colorspaceIndex]);
		break;
	}
}
function applyData()
{
		nColorRH[colorspaceIndex] = RHColorCtrl[colorspaceIndex].GetCurrentTick();
		nColorGS[colorspaceIndex] = GSColorCtrl[colorspaceIndex].GetCurrentTick();
		nColorBV[colorspaceIndex] = BVColorCtrl[colorspaceIndex].GetCurrentTick();
	
		if(colorspaceIndex == 0)
			RGBtoHSV(nColorRH[0], nColorGS[0], nColorBV[0]);
		else if(colorspaceIndex == 1)
			HSVtoRGB(float(nColorRH[1]), float(nColorGS[1]), float(nColorBV[1]));

	bUseNewHair = NewHairUseBox.IsChecked();
	bUseHairColor = HairColorUseBox.IsChecked();
	class'HairshopAPI'.static.ApplyCharHairInfo(bUseNewHair, savedHairtype, bUseHairColor, nColorRH[0], nColorGS[0], nColorBV[0]);
}
function updateHairColorData()
{
	class'HairshopAPI'.static.UpdateCharHairInfo();
}
function handleHairColorData( string param )
{
	local int i;
	local int tempUseHairCol;
	ParseInt(param, "bUseCustomHair", tempUseHairCol);
	ParseInt(param, "maxHairNum", gHairtype);
	ParseInt(param, "colorR",		  nColorRH[0]);
	ParseInt(param, "colorG",		  nColorGS[0]);
	ParseInt(param, "colorB",		  nColorBV[0]);

	bUseNewHair = bool(tempUseHairCol);
	RGBtoHSV(nColorRH[0], nColorGS[0], nColorBV[0]);


	for(i = 0; i < NUMCOLORSPACE; i++)
	{
		RHColorCtrl[i].SetCurrentTick(nColorRH[i]);
		GSColorCtrl[i].SetCurrentTick(nColorGS[i]);
		BVColorCtrl[i].SetCurrentTick(nColorBV[i]);
	}

	setRGBTextBox(nColorRH[colorspaceIndex], nColorGS[colorspaceIndex], nColorBV[colorspaceIndex]);
}
function setRGBTextBox(int rh, int gs, int bv)
{
		RHColorBox.SetString(string(rh));
		GSColorBox.SetString(string(gs));
		BVColorBox.SetString(string(bv));
}

// r,g,b values are from 0 to 1 
// h = [0,360], s = [0,1], v = [0,1] 
// if s == 0, then h = -1 (undefined)

function float __min_channel(float r, float g, float b)
{
    local float t;
	if(r < g)
	{
		t = r;
	}
	else
	{
		t = g;
	}
    if(t > b)
	{
		t = b;
	}
    return t;
}

function float __max_channel(float r, float g, float b)
{
    local float t;
	if(r > g)
	{
		t = r;
	}
	else 
	{
		t = g;
	}
    if(t < b)
	{
		t = b;
	}
    return t;
}

function RGBtoHSV( int inr, int ing, int inb )
{
	local float r;
	local float g;
	local float b;

	local float minVal;
    local float maxVal;
	local float deltaVal;

	r = inr / 255.f;
	g = ing / 255.f;
	b = inb / 255.f;
    
	minVal = __min_channel(r, g, b);
    maxVal = __max_channel(r, g, b);
   
	nColorBV[1] = maxVal * 100.f;                          // v
    deltaVal = maxVal - minVal;
    if( maxVal != 0 )
    {
        nColorGS[1] = int(deltaVal / maxVal * 100.f);            // s
    }
    else 
    {								// rgbcol.r = rgbcol.g = rgbcol.b = 0          // s = 0, v is undefined
       nColorGS[1] = -1;
       return;
    }
    if( r == maxVal )  
    {        
		nColorRH[1] = int(( g - b ) / deltaVal);     // between yellow & magenta
    }
    else if( g == maxVal )  
	{
		nColorRH[1] = int(2.f + ( b - r ) / deltaVal); // between cyan & yellow
	}
    else
    {
        nColorRH[1] = int(4.f + ( r - g ) / deltaVal); // between magenta & cyan
    }
    nColorRH[1] = 60;                                                  // degrees
    
    if( nColorRH[1] < 0 )
    {
        nColorRH[1] = 360;
    }
}

function HSVtoRGB( float h, float s, float v )
{

	local int i;
	local float f, q, p, t;
	local float floatR, floatG, floatB;
    if( s == 0 ) 
	{// achromatic (grey)
        nColorRH[0] = int(v/100.f * 255.f);
		nColorGS[0] = nColorRH[0];
		nColorBV[0] = nColorRH[0];
        return;
    }
    h /= 60.f;                     // sector 0 to 5
    i = int(h + 0.5f);
    f = h - float(i);          // factorial part of h
    p = v/100.f * ( 1 - s/100.f );
    q = v/100.f * ( 1 - s/100.f * f );
    t = v/100.f * ( 1 - s/100.f * ( 1 - f ) );
    switch( i ) 
	{
        case 0:
			floatR = v/100.f; floatG = t; floatB = p;
			break;
        case 1: 
			floatR = q; floatG = v/100.f; floatB = p; 
			break;
        case 2: 
			floatR = p; floatG = v/100.f; floatB = t; 
			break;
        case 3: 
			floatR = p; floatG = q; floatB = v/100.f; 
			break;
        case 4: 
			floatR = t; floatG = p; floatB = v/100.f; 
			break;
        default: //case=5;
			floatR = v/100.f; floatG = p; floatB = q;
			break;  
    } 
	nColorRH[0] = int(floatR * 255.f);
	nColorGS[0] = int(floatG * 255.f);
	nColorBV[0] = int(floatB * 255.f);
}
defaultproperties
{
}
