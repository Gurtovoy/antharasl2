class FlightTeleportWnd extends UIScript;

// 디파인
const ICON_FLAG = "L2ui_CT1.MiniMap.Minimap_df_flagicon_yellow";
const ICON_LOC = "L2ui_CT1.MiniMap.Minimap_df_icn_Shield";
const ICON_LOC_DISABLE = "L2ui_CT1.MiniMap.Minimap_df_icn_Shield_disable";

const FLAG_ID = 10001;	//깃발의 아이디를 강제로 지정해버린다.


// 각종 핸들들
var WindowHandle Me;
var WindowHandle FlightShipCtrlWnd;
var MinimapCtrlHandle FlightMap;

var ButtonHandle btnMyPos;
var ButtonHandle btnGo;
var ButtonHandle btnCancle;

var TextBoxHandle TargetTxt;
var TextBoxHandle CostTxt;

//전역 변수들
var int		 i;					// 반복문을 위한 전역변수

var int 		selectID;				// 현재 선택된 텔레포트 ID
var int 		m_airportID;			// 현재 선착장의 아이디를 받아오는 전역변수

var array<int>		m_arrTelID;			// 텔레포트 아이디
var array<int>		m_arrAirportID;		// 에어포트 아이디
var array<int>		m_arrFuel;			// 소모 EP량
var array<int>		m_arrX;			// x, y, z
var array<int>		m_arrY;
var array<int>		m_arrZ;

//-----------------------------------------  아래 함수가 일종의 스크립트 역할을 합니다 -----------------------------------------------
//-----------------------------------------  선착장 및 텔레포트 ID 는 airship.txt 서버 스크립트를 확인하여야 합니다. -----------------
//---------------------------------------------------------------------------------------------- by innowind --------------------------
function int FindSystemStrByID(int ID, int AirportID )
{
	switch(AirportID)
	{
		case 100:	// 크세르스 요새
			switch(ID)
			{
				case -1:		return 1973;	//크세르스 선착장 방면
				case 0:		return 1974;	// 불멸 방면
				case 1:		return 1975;	// 파멸 방면
			    case 2:		return 2242;	// 진멸 방면
			}
			break;
		case 101:	// 불멸의 씨앗
			switch(ID)
			{
				case -1:		return 1974;	// 불멸 방면
				case 0:		return 1973;	//크세르스 선착장 방면
			}
			break;
		case 102:	// 파멸의 씨앗
			switch(ID)
			{
				case -1:		return 1975;	// 파멸 방면
				case 0:		return 1973;	//크세르스 선착장 방면
			}
			break;
		case 103:	// 진멸의 씨앗 (CT26P1 추가)
			switch(ID)
			{
				case -1:		return 2242;	// 진멸 방면
				case 0:		return 1973;	//크세르스 선착장 방면
			}
			break;
	}
}

function OnRegisterEvent()
{
	RegisterEvent( EV_AirShipTeleportListStart );		// 팝업 이벤트
	RegisterEvent( EV_AirShipTeleportList );			// 텔레포트 리스트가 날라온다.
	RegisterEvent( EV_MinimapRegionInfoBtnClick );	// 클릭할 경우
}

function OnLoad()
{
	if(CREATE_ON_DEMAND==0)
	{
		Initialize();
		OnRegisterEvent();
	}
	else
	{
		InitializeCOD();
	}
	
	FlightMap.SetContinent(1);	// 무조건 그레시아를 디폴트로 맞춰준다. -_-
	clear();
}


function Initialize()
{
	Me = GetHandle( "FlightTeleportWnd" );
	FlightShipCtrlWnd = GetHandle( "FlightShipCtrlWnd" );
	FlightMap = MinimapCtrlHandle ( GetHandle( "FlightTeleportWnd.FlightMap" ));

	btnMyPos = ButtonHandle( GetHandle( "FlightTeleportWnd.btnMyPos" ));
	btnGo = ButtonHandle( GetHandle( "FlightTeleportWnd.btnGo" ));
	btnCancle = ButtonHandle(GetHandle( "FlightTeleportWnd.btnCancle" ));
	
	TargetTxt = TextBoxHandle( GetHandle( "FlightTeleportWnd.TargetTxt" ));
	CostTxt = TextBoxHandle( GetHandle( "FlightTeleportWnd.CostTxt" ));
}

function InitializeCOD()
{
	Me = GetWindowHandle( "FlightTeleportWnd" );
	FlightShipCtrlWnd = GetWindowHandle( "FlightShipCtrlWnd" );
	FlightMap = GetMinimapCtrlHandle( "FlightTeleportWnd.FlightMap" );

	btnMyPos = GetButtonHandle( "FlightTeleportWnd.btnMyPos" );
	btnGo = GetButtonHandle( "FlightTeleportWnd.btnGo" );
	btnCancle = GetButtonHandle( "FlightTeleportWnd.btnCancle" );
	
	TargetTxt = GetTextBoxHandle( "FlightTeleportWnd.TargetTxt" );
	CostTxt = GetTextBoxHandle( "FlightTeleportWnd.CostTxt" );
}

//각종 초기화를 다룬다.
function Clear()
{
	FlightMap.EraseAllRegionInfo();
	
	m_arrTelID.Remove(0, m_arrTelID.Length);	// 텔레포트 배열 초기화
	m_arrFuel.Remove(0, m_arrFuel.Length);
	m_arrX.Remove(0, m_arrX.Length);
	m_arrY.Remove(0, m_arrY.Length);
	m_arrZ.Remove(0, m_arrZ.Length);
	
	
		
	selectID = -72;	//그냥 초기화전인지 확인
}

function OnEvent( int a_EventID, String a_Param )
{
	switch( a_EventID )
	{
	case EV_AirShipTeleportListStart:	// 윈도우를 팝업시키라는 이벤트!
		OnAirShipTeleportListStart( a_Param );
		break;
	case EV_AirShipTeleportList:		// 텔레포트 리스트가 날라온다.
		OnAirShipTeleportList( a_Param );
		break;
	case EV_MinimapRegionInfoBtnClick:		// 맵 위에 버튼 클릭시 날라옵니다.
		OnMinimapRegionInfoBtnClick( a_Param );
		break;
	default:
		break;
	}
}

// 윈도우를 보여주고, 이것저것 초기화
function OnAirShipTeleportListStart( String a_Param )
{	
	ParseInt(a_Param, "AirportID", m_airportID);	//에어포트 아이디를 받아온다.
	
	Clear();
	SetMeCenter();
	if(FlightShipCtrlWnd.isShowWindow())	// 조종 Ui가 보여질 때만 가능하다.
	{
		if(!Me.isShowWindow())
		{
			Me.ShowWindow();	//팝업
			Me.SetFocus();
		}
	}
	else
	{
		AddSystemMessage(2786);	// "출발" 액션은 비행정을 조종하고 있는 경우에만 사용이 가능합니다.
	}
}

// 리스트 추가. 미니맵에 보여주기
function OnAirShipTeleportList( String a_Param )
{	
	local int ID;
	local int FuelConsume;	
	local int X;
	local int Y;
	local int Z;
	
	
	ParseInt(a_Param, "ID", ID);
	ParseInt(a_Param, "FuelConsume", FuelConsume);	
	ParseInt(a_Param, "X", X);
	ParseInt(a_Param, "Y", Y);
	ParseInt(a_Param, "Z", Z);
	
	// 배열에 추가한다. 
	m_arrTelID.Insert(0,1);		m_arrTelID[0] = ID;
	m_arrAirportID.Insert(0,1);	m_arrAirportID[0] = m_airportID;
	m_arrFuel.Insert(0,1);		m_arrFuel[0] = FuelConsume;
	m_arrX.Insert(0,1);		m_arrX[0] = X;
	m_arrY.Insert(0,1);		m_arrY[0] = Y;
	m_arrZ.Insert(0,1);		m_arrZ[0] = Z;
	
	// 가능 지역 위치 표시
	SetLoc(ID);
	
	SelectLoc(ID, false);	// 기본적으로 선택된 상태. 최초에 리전을 생성해야 한다.
	
	if(ID == -1)	// 티폴트 위치이기 때문에 무조건 -1 이 있어야 한다. 
	{
		//생성 없이 디폴트 위치를 선택한 상태.
		selectID = -1;
		SelectLoc(-1, true);	
	}
}

function OnMinimapRegionInfoBtnClick( String a_Param )
{
	local int ID;
	
	ParseInt(a_Param, "Index", ID);
	
	// 모든 깃발의 텍스쳐를 없애준다.
	for(i =0; i<m_arrTelID.Length; i++)
	{
		UnSelectLoc( m_arrTelID[i]);	
	}
	
	if( ID < 9800)	
	{
		SelectLoc(ID, true);	// 깃발 업데이트 한다.	//여기서는 업데이트만
	}
	else //깃발이 클릭되었을 경우
	{
		SelectLoc(ID - FLAG_ID, true);	// 깃발 업데이트 한다.	//여기서는 업데이트만
	}
	
	selectID = ID;	//전역 변수에 해당 아이디를 저장한다.	
}

function OnClickButton( string Name )
{
	switch( Name )
	{
	case "btnMyPos":
		OnBtnMyPos();
		break;
	case "btnGo":
		OnBtnGo();
		break;
	case "btnCancle":
		if(Me.isShowWindow()) Me.HideWindow();	//창닫기
		Clear();
		SetMeCenter();
		break;
	}
}

// 내 위치 버튼 클릭시
function OnBtnMyPos()
{
	SetMeCenter();	// 내 위치를 가운데로 하고
	
	// 0원짜리 텔레포트 위치로 자동 세팅해준다. 
}

// 출발 버튼을 눌렀을 때 조건을 충족한다면 가도록 한다.
function OnBtnGo()
{
	if(selectID != -72)
	{
		if(selectID >= 9000) selectID = selectID - 10000;
		class'VehicleAPI'.static.RequestExAirShipTeleport( selectID );
		if(Me.isShowWindow()) Me.HideWindow();	//창닫기
		Clear();
		SetMeCenter();
	}
}

// 내 위치를 중심에 놓기
function SetMeCenter()
{
	local vector loc;
	loc = GetPlayerPosition();
	
	FlightMap.AdjustMapView(loc);	// 내 위치를 중심으로다가 옮겨줌
}

// 현재 선택한 텔레포트 지역 업데이트
function SelectLoc(int ID , bool isUpdate)
{	
	local int arrIdx;
	local int AirportID;
	local int FuelConsume;	
	local int X;
	local int Y;
	local int Z;
	
	local int AirPortNameID;
	local string DataforMap;
	
	arrIdx = FindArrIdxByID(ID);	
	if(arrIdx == -1 )
	{ 
		//debug("ERROR!! Array Index Error! -- SelectLoc");
		return; 
	}
	
	AirportID = m_arrAirportID[arrIdx];
	FuelConsume = m_arrFuel[arrIdx];
	X = m_arrX[arrIdx];
	Y = m_arrY[arrIdx];
	Z = m_arrZ[arrIdx];
	
	AirPortNameID = FindSystemStrByID( ID, AirportID);	// 아이디들로 텔레포트 위치의 이름을 가져온다.
	
	ParamAdd(DataforMap, "Index", String(ID + FLAG_ID));
	ParamAdd(DataforMap, "WorldX", string(X));
	ParamAdd(DataforMap, "WorldY", string(Y - 4500));

	ParamAdd(DataforMap, "BtnWidth", string(32));
	ParamAdd(DataforMap, "BtnHeight", string(32));
	ParamAdd(DataforMap, "Description", "");
	ParamAdd(DataforMap, "DescOffsetX", "0");
	ParamAdd(DataforMap, "DescOffsetY", "0");
	ParamAdd(DataforMap, "Tooltip", "");
	
	if(isUpdate == true)	// 업데이트만 원할 경우에는 업데이트만 한다.
	{
		ParamAdd(DataforMap, "BtnTexNormal", ICON_FLAG);
		ParamAdd(DataforMap, "BtnTexPushed", ICON_FLAG);
		ParamAdd(DataforMap, "BtnTexOver", ICON_FLAG );
		
		FlightMap.UpdateRegionInfo(ID + FLAG_ID  , DataforMap);

		// 텍스트의 셋팅은 업데이트 일 경우에만 한다.
		// 택스트 박스 셋팅
		TargetTxt.SetText( "" $ GetSystemString( AirPortNameID ) );	
			
		// 연료 소모 비용 셋팅	
		CostTxt.SetText( string(FuelConsume) $ " EP" );
	}
	else
	{
		ParamAdd(DataforMap, "BtnTexNormal", "");
		ParamAdd(DataforMap, "BtnTexPushed", "");
		ParamAdd(DataforMap, "BtnTexOver", "");
		
		FlightMap.AddRegionInfo(DataforMap);
	}
}

// 선택 텍스쳐를 초기화해준다.
function UnSelectLoc(int ID)
{	
	local int arrIdx;
	local int X;
	local int Y;
	local int Z;
	
	local string DataforMap;
	
	if(ID > FLAG_ID - 100)
	{
		arrIdx = FindArrIdxByID(ID - FLAG_ID);	
	}
	if(arrIdx == -1 )
	{ 
		//debug("ERROR!! Array Index Error! -- SelectLoc");
		return; 
	}
	
	X = m_arrX[arrIdx];
	Y = m_arrY[arrIdx];
	Z = m_arrZ[arrIdx];
	
	ParamAdd(DataforMap, "Index", String(ID + FLAG_ID));
	ParamAdd(DataforMap, "WorldX", string(X));
	ParamAdd(DataforMap, "WorldY", string(Y - 4500));

	ParamAdd(DataforMap, "BtnWidth", string(32));
	ParamAdd(DataforMap, "BtnHeight", string(32));
	ParamAdd(DataforMap, "Description", "");
	ParamAdd(DataforMap, "DescOffsetX", "0");
	ParamAdd(DataforMap, "DescOffsetY", "0");
	ParamAdd(DataforMap, "BtnTexNormal", "L2UI_CT1.EmptyBtn");
	ParamAdd(DataforMap, "BtnTexPushed", "L2UI_CT1.EmptyBtn");
	ParamAdd(DataforMap, "BtnTexOver", "L2UI_CT1.EmptyBtn");
	ParamAdd(DataforMap, "Tooltip", "");
	FlightMap.UpdateRegionInfo(ID + FLAG_ID  , DataforMap);
}

// 텔레포트 가능 지역
function SetLoc(int ID)
{
	//연료가 부족할 경우 디스에이블 텍스쳐로 뿌려준다. (추후에 -_-);;
	
	local int arrIdx;
	local int AirportID;
	local int FuelConsume;	
	local int X;
	local int Y;
	local int Z;
	
	local string DataforMap;
	
	arrIdx = FindArrIdxByID(ID);	
	if(arrIdx == -1 )
	{ 
		//debug("ERROR!! Array Index Error! -- SetLoc");
		return; 
	}	
	AirportID = m_arrAirportID[arrIdx];
	FuelConsume = m_arrFuel[arrIdx];
	X = m_arrX[arrIdx];
	Y = m_arrY[arrIdx];
	Z = m_arrZ[arrIdx];

	
	ParamAdd(DataforMap, "Index", String(ID) );
	ParamAdd(DataforMap, "WorldX", string(X));
	ParamAdd(DataforMap, "WorldY", string(Y));
	ParamAdd(DataforMap, "BtnTexNormal", ICON_LOC);
	ParamAdd(DataforMap, "BtnTexPushed", ICON_LOC);
	ParamAdd(DataforMap, "BtnTexOver", ICON_LOC );
	ParamAdd(DataforMap, "BtnWidth", string(32));
	ParamAdd(DataforMap, "BtnHeight", string(32));
	ParamAdd(DataforMap, "Description", "");
	ParamAdd(DataforMap, "DescOffsetX", "0");
	ParamAdd(DataforMap, "DescOffsetY", "0");
	ParamAdd(DataforMap, "Tooltip", "");
	FlightMap.AddRegionInfo(DataforMap);	
}

function int FindArrIdxByID(int ID)
{
	local int Value;
	
	Value = -1;	//	 -1은 실패라는거
	
	for(i =0; i<m_arrTelID.Length; i++)
	{
		if(m_arrTelID[i] == ID ) return i;
	}
	
	return Value;	
}
defaultproperties
{
}
