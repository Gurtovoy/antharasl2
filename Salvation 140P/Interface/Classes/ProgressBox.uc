class ProgressBox extends UICommonAPI;

var WindowHandle Me;
var ButtonHandle btnCancle;
var ButtonHandle btnOK;
var TextBoxHandle txtProgress;
var ItemWindowHandle EnchantAttributeSlot;
var ItemWindowHandle EnchantItemSlot;

var bool		m_bInUse;
var string		m_strTargetScript;		// 해당 프로그레스 박스를 호출한 스크립트를 저장한다. 
var string		m_strEditMessage;		// 프로그레스 박스의 코멘트
var string      _message, _target;
var int         _time;
var ItemInfo    _infoAttribute, _item;


var ProgressCtrlHandle m_hProgressBoxprogressCtrl;

function OnRegisterEvent()
{
	RegisterEvent(EV_SystemMessage);
}

function OnLoad()
{
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();	

	Initialize();
	Load();

}

function Initialize()
{
	m_strTargetScript = "";
	m_bInUse = false;

	if(CREATE_ON_DEMAND==0)
	{
		Me = GetHandle( "ProgressBox" );
		btnCancle = ButtonHandle ( GetHandle( "ProgressBox.btnCancle" ) );
		btnOK = ButtonHandle ( GetHandle( "ProgressBox.btnOK" ) );
		txtProgress = TextBoxHandle ( GetHandle( "ProgressBox.txtProgress" ) );
		EnchantAttributeSlot = ItemWindowHandle ( GetHandle( "ProgressBox.EnchantAttributeSlot" ) );
		EnchantItemSlot = ItemWindowHandle ( GetHandle( "ProgressBox.EnchantItemSlot" ) );
	}
	else
	{
		Me = GetWindowHandle( "ProgressBox" );
		btnCancle = GetButtonHandle ( "ProgressBox.btnCancle" );
		btnOK = GetButtonHandle ( "ProgressBox.btnOK" );
		txtProgress = GetTextBoxHandle ( "ProgressBox.txtProgress" );
		EnchantAttributeSlot = GetItemWindowHandle ( "ProgressBox.EnchantAttributeSlot" );
		EnchantItemSlot = GetItemWindowHandle ( "ProgressBox.EnchantItemSlot" );

		m_hProgressBoxprogressCtrl=GetProgressCtrlHandle("ProgressBox.progressCtrl");
	}
	
}

function Load()
{
}

function OnClickButton( string Name )
{
	switch( Name )
	{
	case "btnCancle":
		OnbtnCancleClick();
		break;
	case "btnOK":
		OnbtnOKClick();
		break;
	}
}

function OnbtnOKClick()
{
	m_hProgressBoxprogressCtrl.Start();	
	m_bInUse = true;
}

function OnbtnCancleClick()
{	
	local AttributeEnchantWnd scriptAttributeEnchant;

	/* // 아이템 인챈트 상황일 경우
	if(m_strTargetScript == "ItemEnchantWnd")
	{				
		class'UIAPI_PROGRESSCTRL'.static.Reset("ProgressBox.progressCtrl");
		Me.HideWindow();
		m_bInUse = false;
		ShowWindow("ItemEnchantWnd");
	}
	else 
		 */
	if (m_strTargetScript == "AttributeEnchantWnd")
	{
		m_hProgressBoxprogressCtrl.Reset();
		Me.HideWindow();
		m_bInUse = false;
		ShowWindow("AttributeEnchantWnd");
	}
	scriptAttributeEnchant = AttributeEnchantWnd( GetScript("AttributeEnchantWnd"));
	scriptAttributeEnchant.DisableCurrentWindow(false);
}

// 해당 프로그레스 박스를 부르는 함수
function ShowDialog( string message, string target, int time, ItemInfo infoAttribute, ItemInfo item )
{
	if( m_bInUse )
	{
		//debug("Error!! ProgressBox in Use");
		return;
	}
	
	// 프로그레스 타임이 없으면 안된다는거..
	if( time == 0)
	{
		//debug("Error!! Need Progress Time");
		return;
	}

	_message = message;
	_target = target;
	_time = time;
	_infoAttribute = infoAttribute;
	_item = item;
	
	EnchantAttributeSlot.Clear();
	EnchantItemSlot.Clear();

	EnchantAttributeSlot.SetItem( 0, _infoAttribute );
	EnchantAttributeSlot.AddItem( _infoAttribute );
	EnchantItemSlot.SetItem( 0, _item );
	EnchantItemSlot.AddItem( _item );

	// 프로그레스 바를 설정 및 초기화.
	m_hProgressBoxprogressCtrl.SetProgressTime( _time );
	m_hProgressBoxprogressCtrl.Reset();
		
	// 윈도우를 보여준다. 
	Me.ShowWindow();
	Me.SetFocus();
	SetMessage( _message );
	m_strTargetScript = target;

	/*
	EnchantAttributeSlot.Clear();
	EnchantItemSlot.Clear();

	EnchantAttributeSlot.SetItem( 0, infoAttribute );
	EnchantAttributeSlot.AddItem( infoAttribute );
	EnchantItemSlot.SetItem( 0, item );
	EnchantItemSlot.AddItem( item );

	// 프로그레스 바를 설정 및 초기화.
	m_hProgressBoxprogressCtrl.SetProgressTime( time );
	m_hProgressBoxprogressCtrl.Reset();
		
	// 윈도우를 보여준다. 
	Me.ShowWindow();
	m_hProgressBoxprogressCtrl.Start();
	SetMessage( message );
	
	Me.SetFocus();

	
	m_bInUse = true;*/
}

// 다이얼로그의 시간이 다했음
function OnProgressTimeUp( string strID )
{
	//~ local ItemEnchantWnd scriptItemEnchant;
	local AttributeEnchantWnd scriptAttributeEnchant;
	
	//시간이 다되면 캔슬 버튼은 확인 버튼이 된다. 
	//class'UIAPI_BUTTON'.static.SetButtonName("ProgressBox.btnCancle", 1337);
	
	if( strID == "progressCtrl" )
	{
		//HandleCancel();
		
		/* if(m_strTargetScript == "ItemEnchantWnd")
		{
			scriptItemEnchant = ItemEnchantWnd( GetScript("ItemEnchantWnd") );
	
			Me.HideWindow();
			Initialize();	
			scriptItemEnchant.OnOKClick();			
		}
		else  */
			
		
		if (m_strTargetScript == "AttributeEnchantWnd")
		{
			scriptAttributeEnchant = AttributeEnchantWnd( GetScript("AttributeEnchantWnd") );
			scriptAttributeEnchant.DisableCurrentWindow(false);
			Me.HideWindow();
			Initialize();	
			scriptAttributeEnchant.OnOKClick();	
		}
	}
}

function SetMessage( string strMessage )
{
	class'UIAPI_TEXTBOX'.static.SetText( "ProgressBox.txtProgress", strMessage );
}

function OnEvent( int a_EventID, String a_Param )
{
	local int SystemMsgIndex;
	local string ParamString1;
	local string ParamString2;
	
	if( a_EventID == EV_SystemMessage )
	{
		ParseInt ( a_Param, "Index", SystemMsgIndex );
		ParseString ( a_Param, "Param1", ParamString1 );
		ParseString ( a_Param, "Param2", ParamString2 );
		
		if (SystemMsgIndex > 61 && SystemMsgIndex < 66)
		{
			DialogShow(DialogModalType_Modalless, DialogType_Notice, MakeFullSystemMsg( GetSystemMessage( SystemMsgIndex ), ParamString1, ParamString2 ), string(Self) );
		}
	}
}
defaultproperties
{
}
