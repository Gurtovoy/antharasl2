class MSProfilerWnd extends UICommonAPI;

var string m_WindowName;

var WindowHandle Me;
var MSViewerWnd m_scriptMSViewerWnd;

var TextBoxHandle	m_hTxtFrameRate;
var TextBoxHandle	m_hTxtMaxEmitterNum;
var TextBoxHandle	m_hTxtMaxEmitterParticleNum;

var ListCtrlHandle	m_hListEmitterCycle;
var Color Gold;
var Color Red;
var Color Orange;
var Color Green;
var Color White;

function OnLoad()
{
	Me = GetWindowHandle(m_WindowName);
	m_scriptMSViewerWnd = MSViewerWnd(GetScript("MSViewerWnd"));
	
	m_hTxtFrameRate=GetTextBoxHandle(m_WindowName$".txtFrameRate");
	m_hTxtMaxEmitterNum=GetTextBoxHandle(m_WindowName$".txtMaxEmitterNum");
	m_hTxtMaxEmitterParticleNum=GetTextBoxHandle(m_WindowName$".txtMaxEmitterParticleNum");

	m_hListEmitterCycle=GetListCtrlHandle(m_WindowName $ ".listEmitterCycle");

	Gold.R = 176;
	Gold.G = 153;
	Gold.B  = 121;

	Red.R = 255;
	Red.G = 0;
	Red.B  = 0;

	Orange.R = 255;
	Orange.G = 127;
	Orange.B  = 39;

	Green.R = 0;
	Green.G = 255;
	Green.B  = 0;

	White.R = 255;
	White.G = 255;
	White.B  = 255;

	m_hOwnerWnd.EnableTick();
}

function OnRegisterEvent()
{	
	RegisterEvent( EV_MSProfilingResult);	
	RegisterEvent( EV_MSProfilingClear);	
}

function ComputeFrameRateOverload(float frameRate, int targetNum)
{
	local float overload;
	local float stableload;

	overload = 0.2 + (0.1*targetNum);
	stableload = 0.1 + (0.05*targetNum);	

	if(frameRate > overload)
	{
		m_hTxtFrameRate.SetTextColor(Red);
	}
	else if(frameRate > stableload)
	{
		m_hTxtFrameRate.SetTextColor(Orange);
	}
	else
	{
		m_hTxtFrameRate.SetTextColor(Green);
	}
}

function OnEvent(int Event_ID, string param)
{
	local float frameRate;
	local int maxEmitterNum;
	local int maxEmitterParticleNum;
	local int targetNum;

	local int emitterNum;
	local int i;
	
	local string emitterName;
	local int	emitterParticleNum;
	local float emitterAvgFrameRate;
	local float emitterMaxFrameRate;

	local LVDataRecord record;
	record.LVDataList.Length = 4;

	if( Event_ID == EV_MSProfilingResult )
	{
		ParseFloat(Param, "FrameRate", frameRate);
		ParseInt(Param, "TargetNum", targetNum);
		m_hTxtFrameRate.SetText(string(frameRate));
		ComputeFrameRateOverload(frameRate, targetNum);		

		ParseInt(Param, "MaxEmitterNum", maxEmitterNum);
		m_hTxtMaxEmitterNum.SetText(string(maxEmitterNum));

		ParseInt(Param, "MaxEmitterParticleNum", maxEmitterParticleNum);
		m_hTxtMaxEmitterParticleNum.SetText(string(maxEmitterParticleNum));

		ParseInt(Param, "EmitterNum", emitterNum);
		for(i=0; i<emitterNum; ++i)
		{
			ParseString(Param, "EmitterName_"$string(i), emitterName);
			ParseInt(Param, "EmitterParticleNum_"$string(i), emitterParticleNum);
			ParseFloat(Param, "AvgEmitterFrameRate_"$string(i), emitterAvgFrameRate);
			ParseFloat(Param, "MaxEmitterFrameRate_"$string(i), emitterMaxFrameRate);

			record.LVDataList[0].buseTextColor = True;
			record.LVDataList[0].szData = emitterName;
			record.LVDataList[0].TextColor = Gold;
			record.LVDataList[1].szData= string(emitterParticleNum);
			record.LVDataList[1].TextColor = Gold;
			if(frameRate>0)
			{
				record.LVDataList[2].szData= string(emitterAvgFrameRate)$"("$string(int(emitterAvgFrameRate/frameRate*100.0))$"%)";
			}
			else
			{
				record.LVDataList[2].szData= string(emitterAvgFrameRate)$"(##%)";
			}
			record.LVDataList[2].TextColor = Gold;

			record.LVDataList[3].szData= string(emitterMaxFrameRate);
			record.LVDataList[3].TextColor = Gold;

			m_hListEmitterCycle.InsertRecord(record);			
		}
	}

	if( Event_ID == EV_MSProfilingClear )
	{
		ClearProfilingData();
	}
}

function ClearProfilingData()
{
	m_hTxtFrameRate.SetText("분석중");
	m_hTxtFrameRate.SetTextColor(White);
	m_hTxtMaxEmitterNum.SetText("분석중");
	m_hTxtMaxEmitterNum.SetTextColor(White);
	m_hTxtMaxEmitterParticleNum.SetText("분석중");
	m_hTxtMaxEmitterParticleNum.SetTextColor(White);

	m_hListEmitterCycle.DeleteAllItem();
}

function OnShow()
{
	ClearProfilingData();
}

function OnTick()
{
	if( Me.IsShowWindow() )
	{
		class'UIDATA_PAWNVIEWER'.static.UpdateEmitterProfiling();
	}
}

defaultproperties
{
    m_WindowName="MSProfilerWnd"
}
