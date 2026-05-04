class SSAOWnd extends UICommonAPI;

var WindowHandle Me;
var ComboBoxHandle cboLevel;
var ComboBoxHandle cboBlend;
var SliderCtrlHandle barStrength;
var SliderCtrlHandle barMaxIntensity;
var SliderCtrlHandle barFadeFront;
var SliderCtrlHandle barDepth;
var SliderCtrlHandle barNoise;
var SliderCtrlHandle barDistance;
var SliderCtrlHandle barBlur;
var SliderCtrlHandle barBlurDepth;
var SliderCtrlHandle barBlurNormal;
var EditBoxHandle txtStrength;
var EditBoxHandle txtMaxIntensity;
var EditBoxHandle txtFadeFront;
var EditBoxHandle txtDepth;
var EditBoxHandle txtDistance;
var EditBoxHandle txtNoise;
var EditBoxHandle txtBlur;
var EditBoxHandle txtBlurDepth;
var EditBoxHandle txtBlurNormal;

var int m_OldLevel;

function OnRegisterEvent()
{
	//RegisterEvent(  );
}

function OnLoad()
{
	Initialize();
	Load();
}

function Initialize()
{
	Me = GetWindowHandle( "SSAOWnd" );
	cboLevel = GetComboBoxHandle( "SSAOWnd.cboLevel" );
	cboBlend = GetComboBoxHandle( "SSAOWnd.cboBlend" );
	barNoise = GetSliderCtrlHandle( "SSAOWnd.barNoise" );
	barMaxIntensity = GetSliderCtrlHandle( "SSAOWnd.barMaxIntensity" );
	barStrength = GetSliderCtrlHandle( "SSAOWnd.barStrength" );
	barFadeFront = GetSliderCtrlHandle( "SSAOWnd.barFadeFront" );
	barDepth = GetSliderCtrlHandle( "SSAOWnd.barDepth" );
	barDistance = GetSliderCtrlHandle( "SSAOWnd.barDistance" );
	barBlur = GetSliderCtrlHandle( "SSAOWnd.barBlur" );
	barBlurDepth = GetSliderCtrlHandle( "SSAOWnd.barBlurDepth" );
	barBlurNormal = GetSliderCtrlHandle( "SSAOWnd.barBlurNormal" );
	txtStrength = GetEditBoxHandle( "SSAOWnd.txtStrength" );
	txtMaxIntensity = GetEditBoxHandle( "SSAOWnd.txtMaxIntensity" );
	txtFadeFront = GetEditBoxHandle( "SSAOWnd.txtFadeFront" );
	txtDepth = GetEditBoxHandle( "SSAOWnd.txtDepth" );
	txtDistance = GetEditBoxHandle( "SSAOWnd.txtDistance" );
	txtNoise = GetEditBoxHandle( "SSAOWnd.txtNoise" );
	txtBlur = GetEditBoxHandle( "SSAOWnd.txtBlur" );
	txtBlurDepth = GetEditBoxHandle( "SSAOWnd.txtBlurDepth" );
	txtBlurNormal = GetEditBoxHandle( "SSAOWnd.txtBlurNormal" );
	
	Me.SetWindowTitle( "SSAO" );
	m_OldLevel = 0;
}

function Load()
{
	OnbtnInitClick();
}

function OnClickButton( string Name )
{
	switch( Name )
	{
	case "btnInit":
		OnbtnInitClick();
		break;
	case "btnOnOff":
		OnbtnOnOffClick();
		break;
	}
}

function OnComboBoxItemSelected( string Name, int index )
{
	switch( Name )
	{
	case "cboLevel":
		SetL2Shader( true );
		class'SSAOAPI'.static.SSAO_Level( index );
		m_OldLevel = index;
		break;
	case "cboBlend":
		class'SSAOAPI'.static.SSAO_Blend( index );
		break;
	}	
}

function OnModifyCurrentTickSliderCtrl( string Name, int step )
{
	switch( Name )
	{
	case "barStrength" :
		ApplyStrength( step );
		break;
	case "barMaxIntensity" :
		ApplyMaxIntensity( step );
		break;
	case "barFadeFront" :
		ApplyFadeFront( step );
		break;
	case "barDepth" :
		ApplyDepth( step );
		break;
	case "barNoise" :
		ApplyNoise( step );
		break;
	case "barDistance" :
		ApplyDistance( step );
		break;
	case "barBlur" :
		ApplyBlur( step );
		break;
	case "barBlurDepth" :
		ApplyBlurDepth( step );
		break;
	case "barBlurNormal" :
		ApplyBlurNormal( step );
		break;
	}
}

function OnCompleteEditBox( string Name )
{
	local string text;
	
	switch( Name )
	{
	case "txtStrength":
		text = txtStrength.GetString();
		class'SSAOAPI'.static.SSAO_Strength( float(text) );
		break;
	case "txtMaxIntensity":
		text = txtMaxIntensity.GetString();
		class'SSAOAPI'.static.SSAO_MaxIntensity( float(text) );
		break;
	case "txtFadeFront":
		text = txtFadeFront.GetString();
		class'SSAOAPI'.static.SSAO_FadeFront( float(text) );
		break;
	case "txtDepth":
		text = txtDepth.GetString();
		class'SSAOAPI'.static.SSAO_DepthDifference( float(text) );
		break;
	case "txtNoise":
		text = txtNoise.GetString();
		class'SSAOAPI'.static.SSAO_NoiseScale( float(text) );
		break;
	case "txtDistance":
		text = txtDistance.GetString();
		class'SSAOAPI'.static.SSAO_SampleDistance( float(text) );
		break;
	case "txtBlur":
		text = txtBlur.GetString();
		class'SSAOAPI'.static.SSAO_BlurIntensity( float(text) );
		break;
	case "txtBlurDepth":
		text = txtBlurDepth.GetString();
		class'SSAOAPI'.static.SSAO_BlurDepthDifference( float(text) );
		break;
	case "txtBlurNormal":
		text = txtBlurNormal.GetString();
		class'SSAOAPI'.static.SSAO_BlurNormalDifference( float(text) );
		break;
	}
}

function OnbtnInitClick()
{
	barStrength.SetCurrentTick( 5 );
	barMaxIntensity.SetCurrentTick( 5 );
	barFadeFront.SetCurrentTick( 5 );
	barDepth.SetCurrentTick( 5 );
	barNoise.SetCurrentTick( 5 );
	barDistance.SetCurrentTick( 5 );
	barBlur.SetCurrentTick( 5 );
	barBlurDepth.SetCurrentTick( 5 );
	barBlurNormal.SetCurrentTick( 5 );
}

function OnbtnOnOffClick()
{
	local int index;
	
	index = cboLevel.GetSelectedNum();
	if( index == 0 && m_OldLevel > 0 )
	{
		SetL2Shader( true );
		cboLevel.SetSelectedNum( m_OldLevel );
		class'SSAOAPI'.static.SSAO_Level( m_OldLevel );
	}
	else
	{
		cboLevel.SetSelectedNum( 0 );
		class'SSAOAPI'.static.SSAO_Level( 0 );
	}
}

function ApplyStrength( int step )
{
	local float value;
	value = float(step) / 5.f;
	class'SSAOAPI'.static.SSAO_Strength( value );
	
	txtStrength.SetString( string( value ) );
}

function ApplyMaxIntensity( int step )
{
	local float value;
	switch( step )
	{
	case 0:  value = 0.1f; break;
	case 1:  value = 0.2f; break;
	case 2:  value = 0.3f; break;
	case 3:  value = 0.4f; break;
	case 4:  value = 0.5f; break;
	case 5:  value = 0.6f; break;
	case 6:  value = 0.65f; break;
	case 7:  value = 0.7f; break;
	case 8:  value = 0.8f; break;
	case 9:  value = 0.9f; break;
	case 10: value = 1.0f; break;
	}
	class'SSAOAPI'.static.SSAO_MaxIntensity( value );
	
	txtMaxIntensity.SetString( string( value ) );
}

function ApplyFadeFront( int step )
{
	local float value;
	switch( step )
	{
	case 0:  value = 1.f; break;
	case 1:  value = 256.f; break;
	case 2:  value = 512.f; break;
	case 3:  value = 768.f; break;
	case 4:  value = 1024.f; break;
	case 5:  value = 1280.f; break;
	case 6:  value = 2000.f; break;
	case 7:  value = 3000.f; break;
	case 8:  value = 4000.f; break;
	case 9:  value = 5000.f; break;
	case 10: value = 6000.f; break;
	}
	class'SSAOAPI'.static.SSAO_FadeFront( value );
	
	txtFadeFront.SetString( string( value ) );
}

function ApplyDepth( int step )
{
	local float value;
	local string str;
	switch( step )
	{
	case 0:  value = 0.00001f; str = "0.00001"; break;
	case 1:  value = 0.00005.f; str = "0.00005"; break;
	case 2:  value = 0.0001f; str = "0.0001"; break;
	case 3:  value = 0.0005f; str = "0.0005"; break;
	case 4:  value = 0.001f; str = "0.001"; break;
	case 5:  value = 0.005f; str = "0.005"; break;
	case 6:  value = 0.01.f; str = "0.01"; break;
	case 7:  value = 0.05.f; str = "0.05"; break;
	case 8:  value = 0.1f; str = "0.1"; break;
	case 9:  value = 0.25f; str = "0.25"; break;
	case 10: value = 0.5f; str = "0.5"; break;
	}
	class'SSAOAPI'.static.SSAO_DepthDifference( value );
	
	txtDepth.SetString( str );
}

function ApplyNoise( int step )
{
	local float value;
	switch( step )
	{
	case 0:  value = 10.f; break;
	case 1:  value = 15.f; break;
	case 2:  value = 20.f; break;
	case 3:  value = 40.f; break;
	case 4:  value = 60.f; break;
	case 5:  value = 80.f; break;
	case 6:  value = 100.f; break;
	case 7:  value = 120.f; break;
	case 8:  value = 150.f; break;
	case 9:  value = 180.f; break;
	case 10: value = 200.f; break;
	}
	class'SSAOAPI'.static.SSAO_NoiseScale( value );
	
	txtNoise.SetString( string( value ) );
}

function ApplyDistance( int step )
{
	local float value;
	switch( step )
	{
	case 0:  value = 0.1f; break;
	case 1:  value = 0.3f; break;
	case 2:  value = 0.5f; break;
	case 3:  value = 0.7f; break;
	case 4:  value = 0.9f; break;
	case 5:  value = 1.f; break;
	case 6:  value = 1.2f; break;
	case 7:  value = 1.5.f; break;
	case 8:  value = 2.f; break;
	case 9:  value = 3.f; break;
	case 10: value = 5.f; break;
	}
	class'SSAOAPI'.static.SSAO_SampleDistance( value );
	
	txtDistance.SetString( string( value ) );
}

function ApplyBlur( int step )
{
	local float value;
	switch( step )
	{
	case 0:  value = 1.f; break;
	case 1:  value = 1.2f; break;
	case 2:  value = 1.5f; break;
	case 3:  value = 2.f; break;
	case 4:  value = 2.5f; break;
	case 5:  value = 3.f; break;
	case 6:  value = 5.f; break;
	case 7:  value = 7.f; break;
	case 8:  value = 8.f; break;
	case 9:  value = 9.f; break;
	case 10: value = 10.f; break;
	}
	class'SSAOAPI'.static.SSAO_BlurIntensity( value );
	
	txtBlur.SetString( string( value ) );
}

function ApplyBlurDepth( int step )
{
	local float value;
	switch( step )
	{
	case 0:  value = 0.5f; break;
	case 1:  value = 1.f; break;
	case 2:  value = 2.f; break;
	case 3:  value = 4.f; break;
	case 4:  value = 6.f; break;
	case 5:  value = 8.f; break;
	case 6:  value = 20.f; break;
	case 7:  value = 50.f; break;
	case 8:  value = 100.f; break;
	case 9:  value = 200.f; break;
	case 10: value = 500.f; break;
	}
	class'SSAOAPI'.static.SSAO_BlurDepthDifference( value );
	
	txtBlurDepth.SetString( string( value ) );
}

function ApplyBlurNormal( int step )
{
	local float value;
	switch( step )
	{
	case 0:  value = 0.f; break;
	case 1:  value = 0.05f; break;
	case 2:  value = 0.1f; break;
	case 3:  value = 0.15f; break;
	case 4:  value = 0.2f; break;
	case 5:  value = 0.3f; break;
	case 6:  value = 0.5f; break;
	case 7:  value = 0.7f; break;
	case 8:  value = 0.8f; break;
	case 9:  value = 0.9f; break;
	case 10: value = 1.f; break;
	}
	class'SSAOAPI'.static.SSAO_BlurNormalDifference( value );
	
	txtBlurNormal.SetString( string( value ) );
}
defaultproperties
{
}
