class BR_EventFireWnd extends UICommonAPI;

var int BuffOnOff;
var int Today;
var int Per;

var WindowHandle Me;
var ButtonHandle EventFireBtn1;
var ButtonHandle EventFireBtn2;
var TextureHandle NCTextureRed;
var TextureHandle NCTextureBack;
var WindowHandle GaugeToolTip;

var TextBoxHandle EventFireTitle;

function OnRegisterEvent()
{
	RegisterEvent( EV_BR_FireEventStateInfo );
	RegisterEvent( EV_BR_FireEventTimeInfo );
}

function OnLoad()
{
	Initialize();
	Load();
}

function Initialize()
{
	if (CREATE_ON_DEMAND==0) {
		Me = GetHandle( "BR_EventFireWnd" );
		EventFireBtn1 = ButtonHandle ( GetHandle( "BR_EventFireWnd.EventFireBtn1" ) );
		EventFireBtn2 = ButtonHandle ( GetHandle( "BR_EventFireWnd.EventFireBtn2" ) );
		NCTextureRed = TextureHandle ( GetHandle( "BR_EventFireWnd.NCTextureRed" ) );
		//NCTextureBack = TextureHandle ( GetHandle( "BR_EventFireWnd.NCTextureBack" ) );
		GaugeToolTip = GetHandle( "BR_EventFireWnd.GaugeToolTip" );
		//EventFireTitle = TextBoxHandle( GetHandle( "BR_EventFireWnd.EventFireTitle" ) );
	}
	else {
		Me = GetWindowHandle( "BR_EventFireWnd" );
		EventFireBtn1 = GetButtonHandle( "BR_EventFireWnd.EventFireBtn1" );
		EventFireBtn2 = GetButtonHandle( "BR_EventFireWnd.EventFireBtn2" );
		NCTextureRed = GetTextureHandle( "BR_EventFireWnd.NCTextureRed" );
		//NCTextureBack = GetTextureHandle( "BR_EventFireWnd.NCTextureBack" );
		GaugeToolTip = GetWindowHandle( "BR_EventFireWnd.GaugeToolTip" );
		//EventFireTitle = GetTextBoxHandle( "BR_EventFireWnd.EventFireTitle" );		
	}
	BuffOnOff=0;
	Today=0;
	Per=0;
}

function Load()
{
	
}

function OnEvent( int a_EventID, String a_Param )
{
	local int eState;
	local int day;
	local int percent;
	
	local int type;
	local int value;
	local int bstate;
	local int endtime;	

	switch( a_EventID )
	{
	case EV_BR_FireEventStateInfo:		
		ParseInt(a_param, "EventState", eState);
		ParseInt(a_param, "Day", day);
		ParseInt(a_param, "Percent", percent);
                FireEventWndShow(eState, day, percent);					
		break;
	case EV_BR_FireEventTimeInfo:		
		ParseInt(a_param, "Type", type);
		ParseInt(a_param, "Value", value);
		ParseInt(a_param, "State", bstate);
		ParseInt(a_param, "Endtime", endtime);			
		FireEventBuff(type, value, bstate, endtime);	
		break;
	}
}

function FireEventBuff(int type, int value, int bstate, int endtime)
{	
	//local ItemID giftitem; //giftitem.ClassID = value; //class'UIDATA_ITEM'.static.GetItemName(giftitem) // Item Name이 필요할 때
	local String ParamString;

	if(bstate==1)
	{		
		BuffOnOff=1;
		EventFireBtn1.SetTexture("BranchSys.UI.present_normal",
                             "BranchSys.UI.present_normal","BranchSys.UI.present_normal");
		if(type==1)
			EventFireBtn1.SetTooltipCustomType(SetTooltip(MakeFullSystemMsg( 			
                        	  GetSystemMessage(6014), MakeFullSystemMsg(GetSystemMessage(6012),string(value),"%"), ConvertTimetoStr(endtime) )));		  		  
		else if(type==2)
		{
			if(value==20573)	
				EventFireBtn1.SetTooltipCustomType(SetTooltip(MakeFullSystemMsg(GetSystemMessage(6015), ConvertTimetoStr(endtime), GetSystemString(5024))));
			else if(value==20574)	
				EventFireBtn1.SetTooltipCustomType(SetTooltip(MakeFullSystemMsg(GetSystemMessage(6015), ConvertTimetoStr(endtime), GetSystemString(5025))));
			else if(value==20575)	
				EventFireBtn1.SetTooltipCustomType(SetTooltip(MakeFullSystemMsg(GetSystemMessage(6015), ConvertTimetoStr(endtime), GetSystemString(5026))));				
		}  
		ParamAdd(ParamString, "Type", string(int(ESystemMsgParamType.SMPT_STRING)));
		ParamAdd(ParamString, "param1", string(Today));
		AddSystemMessageParam(ParamString);
		EndSystemMessageParam(6017, false);
	}
	else if(bstate==0) 
	{		
		if(BuffOnOff==1)
		{
			ParamAdd(ParamString, "Type", string(int(ESystemMsgParamType.SMPT_STRING)));
			ParamAdd(ParamString, "param1", string(Today));
			AddSystemMessageParam(ParamString);
			EndSystemMessageParam(6018, false);	
		}
		BuffOnOff=0;
		EventFireBtn1.SetTexture("BranchSys.UI.present_disable","BranchSys.UI.present_disable","BranchSys.UI.present_disable");
		if(Per==100)
			EventFireBtn1.SetTooltipCustomType(SetTooltip(MakeFullSystemMsg(GetSystemMessage(6018), string(Today), "" )));
		else
			FireEventButton();		
	}
}

function FireEventWndShow(int eState, int day, int percent)
{
	if(eState==0)
	{		
		if(Me.isShowWindow()){Me.HideWindow();}			
	}
	else
	{		
		if(!Me.isShowWindow()){Me.ShowWindow();}
		Per=percent;
                if(Today==0) 
		{
			Today = day; // 수정
			GaugeToolTip.SetTooltipCustomType(SetTooltip(MakeFullSystemMsg(GetSystemMessage(6016), string(Today),"" )));
			if(BuffOnOff==0) FireEventButton(); 			
		}		
                if(percent==0)  //로그인or날짜바뀔때
		{
			Today = day;			
			GaugeToolTip.SetTooltipCustomType(SetTooltip(MakeFullSystemMsg(GetSystemMessage(6016), string(Today),"" )));	
			if(BuffOnOff==0) FireEventButton();
		}
		FireEventGauge(percent);	
	}
}

function FireEventButton()
{
	local int addexp;

	//if(Today==6 || Today==10 || Today==14)        
	if(Today==6)	
		EventFireBtn1.SetTooltipCustomType(SetTooltip(MakeFullSystemMsg(GetSystemMessage(6013), GetSystemString(5024),"" )));
	else if(Today==10)	
		EventFireBtn1.SetTooltipCustomType(SetTooltip(MakeFullSystemMsg(GetSystemMessage(6013), GetSystemString(5025),"" )));
	else if(Today==14)	
		EventFireBtn1.SetTooltipCustomType(SetTooltip(MakeFullSystemMsg(GetSystemMessage(6013), GetSystemString(5026),"" )));      
        else 
        {
		if(Today==1 || Today==2 || Today==3)	addexp=10;
		else if(Today==4)	addexp=15;
		else if(Today==5 || Today==7)	addexp=20;
		else if(Today==8 || Today==9)	addexp=25;
		else if(Today==11 || Today==12)	addexp=30;
		else if(Today==13)	addexp=40;			
		EventFireBtn1.SetTooltipCustomType(SetTooltip(MakeFullSystemMsg( 			
                          GetSystemMessage(6013), MakeFullSystemMsg(GetSystemMessage(6012),string(addexp),"%"), "" )));
        }	
}

function FireEventGauge(int percent)
{	
	if(percent<0) percent=0;
        else if(percent>100) percent=100;	
	
	if(percent==0 || percent==100)
		NCTextureRed.SetWindowSize(percent,14);
	else
		NCTextureRed.SetWindowSize((percent/10)*9+3,14);
}

function CustomTooltip SetTooltip(string Text)
{
	local CustomTooltip Tooltip;
	local DrawItemInfo info;
	
	Tooltip.MinimumWidth = 144;
	
	Tooltip.DrawList.Length = 1;
	info.eType = DIT_TEXT;
	info.t_bDrawOneLine = true;
	info.t_color.R = 178;
	info.t_color.G = 190;
	info.t_color.B = 207;
	info.t_color.A = 255;
	info.t_strText = Text;
	Tooltip.DrawList[0] = info;

	return Tooltip;
}

function OnClickButton( string Name )
{
	switch( Name )
	{
	case "EventFireBtn1":
		OnEventFireBtn1Click();
		break;
	case "EventFireBtn2":
		OnEventFireBtn2Click();
		break;
	}
}

function OnEventFireBtn1Click()
{
}

function OnEventFireBtn2Click()
{
	local string strParam;	

	if(IsShowWindow("BR_EventHtmlWndA"))
	{
		HideWindow("BR_EventHtmlWndA");		
	}
	else
	{
		ShowWindowWithFocus("BR_EventHtmlWndA");		
		ParamAdd(strParam, "FilePath", "..\\L2text\\br_eventfire_help.htm");
		ParamAdd(strParam, "Title", GetSystemString(5023));
		ExecuteEvent(EV_BR_EventCommonHtml1, strParam);
	}
}
defaultproperties
{
}
