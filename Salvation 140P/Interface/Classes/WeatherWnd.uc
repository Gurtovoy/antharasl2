class WeatherWnd extends UICommonAPI;


var WindowHandle WindowHandle;
var ComboBoxHandle WeatherSortCombo;
var ComboBoxHandle SortCombo;
var ComboBoxHandle EmitterPosCombo;
var TextBoxHandle  EmitterPosText;
var EditBoxHandle  ParticleWeightEdit;
var EditBoxHandle  ParticleSpeedEdit;

var TextBoxHandle	ParticleEmitterNumText;
var TextBoxHandle	ParticleEmitterNum1Text;
var	EditBoxHandle	ParticleEmitterNumEdit;

var ButtonHandle	SetButton;
var ButtonHandle	InitializeButton;
var ButtonHandle	DeleteButton;

var	int				WeatherType; //0번 Rain //1번 Snow //2번 Rain + Snow
var	int				MethodType;	//0번 Emitter //1번 Mesh //2번 Emitter + Mesh

function OnLoad()
{

	InitHandle();



	WeatherSortCombo.clear();
	WeatherSortCombo.AddStringWithReserved("비",0);
	WeatherSortCombo.AddStringWithReserved("눈",1);
	WeatherSortCombo.AddStringWithReserved("비+눈",2);

	SortCombo.clear();
	SortCombo.AddStringWithReserved("파티클",0);
	SortCombo.AddStringWithReserved("매쉬",1);
	SortCombo.AddStringWithReserved("파티클+매쉬",2);

	EmitterPosCombo.clear();
	EmitterPosCombo.AddStringWithReserved("캐릭터에 Attach",0);
	EmitterPosCombo.AddStringWithReserved("카메라에 Attach",1);

	ParticleWeightEdit.SetString("1");
	ParticleSpeedEdit.SetString("1");
	ParticleEmitterNumEdit.SetString("1");

	WeatherSortCombo.SetSelectedNum(0);
	SortCombo.SetSelectedNum(0);
	EmitterPosCombo.SetSelectedNum(0);

	WeatherType = 0;
	MethodType = 0;	

}


function InitHandle()
{	
	WindowHandle = GetWindowHandle( "WeatherWnd" );
	WeatherSortCombo = GetComboBoxHandle("WeatherWnd.WeatherSortCombo");
	SortCombo = GetComboBoxHandle("WeatherWnd.SortCombo");
	EmitterPosCombo = GetComboBoxHandle("WeatherWnd.EmitterPosCombo");
	EmitterPosText = GetTextBoxHandle("WeatherWnd.EmitterPosText");

	ParticleWeightEdit = GetEditBoxHandle("WeatherWnd.ParticleWeightEdit");
	ParticleSpeedEdit = GetEditBoxHandle("WeatherWnd.ParticleSpeedEdit");
	ParticleEmitterNumEdit = GetEditBoxHandle("WeatherWnd.ParticleEmitterNumEdit");

	ParticleEmitterNumText = GetTextBoxHandle("WeatherWnd.ParticleEmitterNumText");
	ParticleEmitterNum1Text = GetTextBoxHandle("WeatherWnd.ParticleEmitterNum1Text");

	SetButton = GetButtonHandle("WeatherWnd.SetButton");
	InitializeButton = GetButtonHandle("WeatherWnd.InitializeButton");
	DeleteButton = GetButtonHandle("WeatherWnd.DeleteButton");
}

function OnRegisterEvent()
{
	RegisterEvent(EV_ShowWeatherWnd);
}

function OnEvent( int a_EventID, String a_Param )
{
	switch( a_EventID )
	{
	case EV_ShowWeatherWnd:
		WindowHandle.ShowWindow();
		break;
	}
}
function OnComboBoxItemSelected( String a_ControlID, INT a_SelectedIndex )
{
	if( a_ControlID == "WeatherSortCombo" )
	{
		WeatherType = a_SelectedIndex;
	}
	else if ( a_ControlID == "SortCombo" )
	{	
		MethodType = a_SelectedIndex;	
		if (a_SelectedIndex == 0)
		{
			ParticleEmitterNumEdit.ShowWindow();
			ParticleEmitterNumText.ShowWindow();
			ParticleEmitterNum1Text.ShowWindow();

			EmitterPosText.ShowWindow();
			EmitterPosCombo.ShowWindow();
		}
		else if (a_SelectedIndex == 1)
		{
			ParticleEmitterNumEdit.HideWindow();
			ParticleEmitterNumText.HideWindow();
			ParticleEmitterNum1Text.HideWindow();

			EmitterPosText.HideWindow();
			EmitterPosCombo.HideWindow();

		}
		else if (a_SelectedIndex == 2)
		{
			ParticleEmitterNumEdit.ShowWindow();
			ParticleEmitterNumText.ShowWindow();
			ParticleEmitterNum1Text.ShowWindow();

			EmitterPosText.ShowWindow();
			EmitterPosCombo.ShowWindow();
		}
	}
}
function OnClickButton( String a_ControlID )
{
	switch( a_ControlID )
	{
	case "SetButton" :
		SetWeatherButton();
		
		break;
	case "InitializeButton" :
		RequestDeleteRainEffect();
		RequestDeleteSnowEffect();
		break;
	case "DeleteButton" :
		break;
	}
}

function SetWeatherButton()
{
	if (WeatherType == 0)		//비
	{
		RequestDeleteRainEffect();
		RequestCreateRainEffect(MethodType, EmitterPosCombo.GetSelectedNum());
		RequestSetRainWeight(float( ParticleWeightEdit.GetString() ));	
		RequestSetRainSpeed(float( ParticleSpeedEdit.GetString() ));
		if (MethodType == 0 || MethodType == 2)
		{
			RequestSetRainEmitterParticleNum(float(ParticleEmitterNumEdit.GetString()) );
		}
	}
	else if (WeatherType == 1)	//눈
	{
		RequestDeleteSnowEffect();
		RequestCreateSnowEffect(MethodType, EmitterPosCombo.GetSelectedNum());
		RequestSetSnowWeight(float( ParticleWeightEdit.GetString() ));	
		RequestSetSnowSpeed(float( ParticleSpeedEdit.GetString() ));
		if (MethodType == 0 || MethodType == 2)
		{
			RequestSetSnowEmitterParticleNum(float(ParticleEmitterNumEdit.GetString()) );
		}
	}
	else if (WeatherType == 2)	//비+눈
	{
		RequestDeleteRainEffect();
		RequestCreateRainEffect(MethodType, EmitterPosCombo.GetSelectedNum());
		RequestSetRainWeight(float( ParticleWeightEdit.GetString() ));	
		RequestSetRainSpeed(float( ParticleSpeedEdit.GetString() ));
		if (MethodType == 0 || MethodType == 2)
		{
			RequestSetRainEmitterParticleNum(float(ParticleEmitterNumEdit.GetString()) );
		}
		RequestDeleteSnowEffect();
		RequestCreateSnowEffect(MethodType, EmitterPosCombo.GetSelectedNum());
		RequestSetSnowWeight(float( ParticleWeightEdit.GetString() ));	
		RequestSetSnowSpeed(float( ParticleSpeedEdit.GetString() ));
		if (MethodType == 0 || MethodType == 2)
		{
			RequestSetSnowEmitterParticleNum(float(ParticleEmitterNumEdit.GetString()) );
		}
	}
}
defaultproperties
{
}
