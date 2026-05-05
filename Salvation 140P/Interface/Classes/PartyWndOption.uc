/******************************************************************************
//                                                파티창  옵션 관련 UI 스크립트                                                                    //
******************************************************************************/
class PartyWndOption extends UIScript;
	
//const MAX_PartyMemberCount = 9;		//한 파티창에 들어갈수 있는 최대 파티원의 수.

// 전역변수 선언
var bool	m_OptionShow;	// 현재 옵션창이 보여지고 있는지 체크하는 함수.
					// true이면 보임. false  이면 보이지 않음.
var int	m_arrPetIDOpen[MAX_PartyMemberCount];	// 인덱스에 해당하는 파티원의 펫의 창이 열려있는지 확인. 1이면 오픈, 2이면 닫힘. -1이면 없음

// 이벤트 핸들 선언
var WindowHandle	m_PartyOption;
var WindowHandle 	m_PartyWndBig;
var WindowHandle	m_PartyWndSmall;

var CheckBoxHandle	m_CheckShowAllPet;
var CheckBoxHandle	m_CheckHideAllPet;
var CheckBoxHandle  m_showSmallPartyWndChek;

// 윈도우 생성시 로드되는 함수
function OnLoad()
{
	m_OptionShow = false;	// 디폴트는 false 
	// Force big(main) party window by default.
	SetINIInt( "PartyWnd", "e", 0, "Windowsinfo.ini" );


	
	m_PartyOption = GetWindowHandle("PartyWndOption");
	m_PartyWndBig = GetWindowHandle("PartyWnd");	
	m_PartyWndSmall = GetWindowHandle("PartyWndCompact");
		
	//m_CheckShowAllPet = GetCheckBoxHandle("PartyWndOption.showAllPet");
	m_CheckHideAllPet = GetCheckBoxHandle("PartyWndOption.removeAllPet");

	m_showSmallPartyWndChek = GetCheckBoxHandle("PartyWndOption.ShowSmallPartyWndCheck");
}
       
// 윈도우가 보여질때마다 호출되는 함수
function OnShow()
{	
	//local int i;
	//local int open, hide;
	local int tmpInt;
	GetINIInt( "PartyWnd", "e", tmpInt, "Windowsinfo.ini" );
	m_showSmallPartyWndChek.SetCheck( bool ( tmpInt ) );
	//class'UIAPI_CHECKBOX'.static.SetCheck("ShowSmallPartyWndCheck", GetOptionBool( "Game", "SmallPartyWnd" ));
	class'UIAPI_WINDOW'.static.SetFocus("PartyWndOption");
	m_OptionShow = true;

	GetINIInt ( "PartyWnd", "p", tmpInt, "Windowsinfo.ini");
	m_CheckHideAllPet.SetCheck( bool ( tmpInt ) );

	/*
	open  = 0;
	hide  = 0;	
	
	// 현재 펫의 상태에 따라 모두 보여주기 / 모두 감추기의 체크를 처리한다. 
	for(i=0; i<MAX_PartyMemberCount ; i++)
	{
		if(m_arrPetIDOpen[i] == 1) open++;
		else if(m_arrPetIDOpen[i] == 2) hide++;
	}	
	*/
	/*
	if( open == 0 )	// 모두 닫혀있다는 뜻. 모두 닫기의 체크를 자동으로 해준다. 
	{
		m_CheckHideAllPet.SetCheck(true);
	}
	else if( hide == 0)	// 제로섬. open, hide 가 동시에 0이 될 수 없다. 
	{
		m_CheckHideAllPet.SetCheck(false);
	}
	else	// 펼쳐진것도 잇고 아닌것도 있으면 둘다 체크 해제
	{
		m_CheckHideAllPet.SetCheck(false);		
	}	
	*/

	
		
}

// 체크박스를 클릭하였을 경우 이벤트
function OnClickCheckBox( string CheckBoxID)
{
	switch( CheckBoxID )
	{
		case "ShowSmallPartyWndCheck":
			 break;

		case "removeAllPet":
			 // 토글 
			 // Debug("클릭!" @ m_CheckHideAllPet.IsChecked());
			 break;
	}
}

// 확장된 파티창과 축소된 파티창을 교환
function SwapBigandSmall()
{
	local int i;
	//~ local int open, hide;
	
	local  PartyWnd script1;			// 확장된 파티창의 클래스
	local PartyWndCompact script2;	// 축소된 파티창의 클래스
	
	script1 = PartyWnd( GetScript("PartyWnd") );
	script2 = PartyWndCompact( GetScript("PartyWndCompact") );
	
	class'UIAPI_WINDOW'.static.SetAnchor("PartyWndCompact", "PartyWnd", "TopLeft", "TopLeft", 0, 0 );	// 이거하나면 양쪽 창이 링크됨. 굿!
	
	for(i=0; i <MAX_PartyMemberCount ; i++)
	{
		if( m_CheckHideAllPet.IsChecked()) 	
		{
			if(m_arrPetIDOpen[i] > 0)	m_arrPetIDOpen[i] = 2;		//펫이 있을때 모두 닫아준다. 
		}
		else 
		{
			if(m_arrPetIDOpen[i] > 0)	m_arrPetIDOpen[i] = 1;		//펫이 있을때 모두 열어준다. 			
		}
		
		script1.m_arrPetIDOpen[i] = m_arrPetIDOpen[i];
		script2.m_arrPetIDOpen[i] = m_arrPetIDOpen[i];
		// 양쪽 스크립트에게 모두 전달.		
	}
	// 각 스크립트의 ResizeWnd()는 옵션의 활성화에 따라 자신의 윈도우를 HIDE할지 활성화할지 결정한다. 
	script1.ResizeWnd();
	script2.ResizeWnd();
}

// 버튼이 눌렸을 경우 실행
function OnClickButton( string strID )
{
	//local PartyWnd script1;
	//local PartyWndCompact script2;
	//script1 = PartyWnd( GetScript("PartyWnd") );
	//script2 = PartyWndCompact( GetScript("PartyWndCompact") );
	
	switch( strID )
	{
		case "okbtn":	// OK 버튼을 누르면
			//switch (class'UIAPI_CHECKBOX'.static.IsChecked("ShowSmallPartyWndCheck"))
			SetINIInt( "PartyWnd", "e", int( m_showSmallPartyWndChek.IsChecked()), "Windowsinfo.ini" );
			SetINIInt ( "PartyWnd", "p", int ( m_CheckHideAllPet.IsChecked() ) , "Windowsinfo.ini");
			/*
			switch (m_showSmallPartyWndChek.IsChecked() )
			{ 
			case true:
				//SetOptionBool("Game", ... ) 은 게임의 Option ->게임항목에서 사용할수 있는 bool 변수를 사용할 수 있다.	
				//기존에 등록되지 않은 변수를 사용하면 자동으로 클라이언트에서 알아서 저장함.
				// 추후 사용된 변수에 대한 Documentation 이 필요!
				// GetOptionBool과 페어.
				
				
				break;
			case false:
				SetOptionBool( "PartyWnd", "SmallPartyWnd", false);
				break;
			}
*/
			SwapBigandSmall();		// 상황에 따라 파티창의 크기를 스왑해준다.
			m_PartyOption.HideWindow();	// 현재의 윈도우를 숨기고
			//script1.m_OptionShow = false;
			//script2.m_OptionShow = false;
			m_OptionShow = false;
			break;
	}
}

// PartyWnd나 PartyWndCompact 에서 호출하는 함수.
function ShowPartyWndOption()
{
	// 닫혀있으면 열고
	if (m_OptionShow == false)
	{ 
		m_PartyOption.ShowWindow();
		m_OptionShow = true;
	}
	else	// 열려있으면 닫는다. 
	{
		m_PartyOption.HideWindow();
		m_OptionShow = false;
	}
}
defaultproperties
{
}
