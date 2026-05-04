class MysteriousMansionMenuWnd extends UICommonAPI;

//var WindowHandle Me;
//var WindowHandle m_MainMenu;
//var WindowHandle m_RadarMapWnd;

const DIALOG_LEAVE_MYSTERIOUSMANSION = 99001;

var bool bChecked2;
var bool bChecked3;
var bool bChecked4;
var bool bChecked5;


function OnLoad()
{
	Initialize();
	Load();
}

function Initialize()
{
	if(CREATE_ON_DEMAND==0)
	{
		OnRegisterEvent();
	}
/*
	if(CREATE_ON_DEMAND==0)
	{
		Me = GetHandle( "MysteriousMansionMenuWnd" );
		//m_RadarMapWnd = GetHandle( "RadarMapWnd" );
		//m_MainMenu = GetHandle( "MainMenu" );
		
	}
	else
	{
		Me = GetWindowHandle( "MysteriousMansionMenuWnd" );
		//m_RadarMapWnd = GetWindowHandle( "RadarMapWnd" );
		//m_MainMenu = GetWindowHandle( "MainMenu" );
		
	}*/
}

function Load()
{
}

function OnRegisterEvent()
{	
	
	RegisterEvent( EV_DialogOK );
	RegisterEvent( EV_DialogCancel );
	RegisterEvent( EV_CuriousHouseEnter ); //9320
	RegisterEvent( EV_CuriousHouseLeave ); //9330

	RegisterEvent( EV_Restart );
}


function OnEvent( int Event_ID, String Param )
{

	//Debug ( "onEvent "  @ Event_ID @ Param ) ;
	switch(Event_ID)
	{
	case EV_CuriousHouseEnter :	
		handleCuriousHouseEnter() ;
		break;	
	case EV_CuriousHouseLeave :
		handleCuriousHouseLeave() ;
		break;	
	case  EV_DialogOK :	
		HandleDialogOK() ;
		break;
	case EV_DialogCancel :
		break;
	}
}


function handleCuriousHouseEnter()
{

	//local OptionWnd o_script;


	setShow("MysteriousMansionMenuWnd");
	setHide("RadarMapWnd");
	setHide("Menu");	

	//옵션 비활 성화//다른 플레이어, 혈맹, 파티, 일반
	//o_script = OptionWnd( GetScript( "OptionWnd" ) );
	//o_script.isShowMysteriousMansionEnterLeave(true);


	bChecked2 =  GetOptionBool( "ScreenInfo", "GroupName" );
	bChecked3 =  GetOptionBool( "ScreenInfo", "PledgeMemberName" ); 
	bChecked4 =  GetOptionBool( "ScreenInfo", "PartyMemberName" );
	bChecked5 =  GetOptionBool( "ScreenInfo", "OtherPCName" );

	SetOptionBool( "ScreenInfo", "GroupName", true );
	SetOptionBool( "ScreenInfo", "PledgeMemberName", true );
	SetOptionBool( "ScreenInfo", "PartyMemberName", true );
	SetOptionBool( "ScreenInfo", "OtherPCName", true );

	/*
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.NameBox2", true );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.NameBox3", true );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.NameBox4", true );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.NameBox5", true );

	class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.NameBox2" );
	class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.NameBox3" );
	class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.NameBox4" );
	class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.NameBox5" );*/

}

function handleCuriousHouseLeave()
{
	//local OptionWnd o_script;
	setHide("MysteriousMansionMenuWnd");
	setShow("RadarMapWnd");
	setShow("Menu");

	// 다른PC이름 - NameBox2
	SetOptionBool( "ScreenInfo", "GroupName", bChecked2 );
		//원래 설정으로 돌림
	// 혈맹이름 - NameBox3
	SetOptionBool( "ScreenInfo", "PledgeMemberName", bChecked3 );

	// 파티이름	- NameBox4
	SetOptionBool( "ScreenInfo", "PartyMemberName", bChecked4 );

	// 일반이름	- NameBox5
	SetOptionBool( "ScreenInfo", "OtherPCName", bChecked5 );

	//o_script = OptionWnd( GetScript( "OptionWnd" ) );
	//o_script.isShowMysteriousMansionEnterLeave(false);

	/*
	class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.NameBox2" );

	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.NameBox2", bChecked2 );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.NameBox3", bChecked3 );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.NameBox4", bChecked4 );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.NameBox5", bChecked5 );	

	//원래 설정으로 돌림
	// 혈맹이름 - NameBox3	
	SetOptionBool( "Game", "PledgeMemberName", bChecked3 );

	// 파티이름	- NameBox4	
	SetOptionBool( "Game", "PartyMemberName", bChecked4 );

	// 일반이름	- NameBox5	
	SetOptionBool( "Game", "OtherPCName", bChecked5 );

	// 다른PC이름 - NameBox2
	// 다른 이름 관련 옵션이 모두 적용되고 나서 덮어써야 하므로, 제일 나중에 해야한다.	
	SetOptionBool( "Game", "GroupName", bChecked2 );

	if (bChecked2)
	{	
		class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.NameBox3" );
		class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.NameBox4" );
		class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.NameBox5" );
	}
*/
}

	

function setShow(string WindowName)
{
	if ( !class'UIAPI_WINDOW'.static.IsShowWindow(WindowName) ) //gfx 형 윈도우 때문에 이와 같은 형태로 수정
		class'UIAPI_WINDOW'.static.ShowWindow(WindowName);
}

function setHide(string WindowName)
{
	if ( class'UIAPI_WINDOW'.static.IsShowWindow(WindowName) )
		class'UIAPI_WINDOW'.static.HideWindow(WindowName);
}

/** 다이얼로그 박스 OK 클릭시 */
function HandleDialogOK()
{
	if (DialogIsMine())
	{
		if( DialogGetID() == DIALOG_LEAVE_MYSTERIOUSMANSION )
		{
			RequestLeaveCuriousHouse();
		}
	}
}


function OnClickButton(string strID)
{	
	switch (strID)
	{
		case "btnQuit" :
			DialogSetID( DIALOG_LEAVE_MYSTERIOUSMANSION );
			DialogShow (DialogModalType_Modalless, DialogType_OKCancel, GetSystemMessage(3756), string(Self) );			
			break;		
	}
}
defaultproperties
{
}
