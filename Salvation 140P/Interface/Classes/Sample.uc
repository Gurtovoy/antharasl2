class Sample extends GFxUIScript;

//테스트용 변수
var string testMember;
var Sample	sampleWnd;

function OnRegisterEvent()
{
	
	RegisterGFxEvent(77777);
}

function OnLoad()
{	

	testMember = "testMember uc 데이타";
	//해당 함수는 
	SetClosingOnESC();

	registerState( "Sample", "GamingState" );	

	// 어느 콘테이너에 넣을 건지 선언
	SetContainer( "ContainerWindow" ); 

	//함수 실행 시 onStateOut, onStateIn 함수를 invoke 로 받음 
	SetStateChangeNotification();

	//선언하면 처음 부터 보여지고 시작 함
	//SetDefaultShow(true);

	//SetAnchor("", EAnchorPointType.ANCHORPOINT_CenterCenter, EAnchorPointType.ANCHORPOINT_CenterCenter, 0 , 0);	

	//테스트용 코드
	sampleWnd = Sample(GetScript("Sample"));
}

//테스트용 함수
function onCallUCFunction( string functionName, string param )
{
	Debug("sampe's onCallUCFunction" @ functionName @ param);
	switch ( functionName ) 
	{
		case "ouputCheck" :
			ouputCheck( param );
		break;
	}
}

//GetVariable 테스트용 함수 
function ouputCheck( string param )
{
	local GFxValue obj;
	local string    test1;
	local int       test2;
	local Float     test3;
	local Bool      test4;

	local string    data1;
	local string    data2;
	local string    data3;
	local string    data4;

	PlayConsoleSound(IFST_MAPWND_OPEN);
	
	AllocGFxValue(obj);
	
	ParseString( param, "d1", data1 );
	ParseString( param, "d2", data2 );
	ParseString( param, "d3", data3 );
	ParseString( param, "d4", data4 );

	Debug ( "sample.GetVariable" @  sampleWnd.GetVariable(obj, "getValTest1") ) ;
	test1 = obj.getString();
	Debug ( "sample.GetVariable" @  sampleWnd.GetVariable(obj, "getValTest2") ) ;
	test2 = obj.getInt();
	Debug ( "sample.GetVariable" @  sampleWnd.GetVariable(obj, "getValTest3") ) ;
	test3 = obj.getFloat();
	Debug ( "sample.GetVariable" @  sampleWnd.GetVariable(obj, "getValTest4") ) ;
	test4 = obj.getBool();
	
	Debug("ouputCheck" @ data1 @ test1 @ data2 @ test2  @ data3 @ test3 @data4 @ test4);

	DeallocGFxValue(obj);
}
defaultproperties
{
}
