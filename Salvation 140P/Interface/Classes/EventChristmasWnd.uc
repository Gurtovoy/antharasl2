class EventChristmasWnd extends GFxUIScript;

function OnRegisterEvent()
{	
	RegisterGFxEvent( EV_ShowEventChristmasWnd ); //9650
}

function OnLoad()
{	
	registerState( "EventChristmasWnd", "GamingState" );	
	// 어느 콘테이너에 넣을 건지 선언
	SetContainer( "ContainerWindow" );
	//setDefaultShow(true);
}

function onCallUCFunction( string functionName, string param )
{	
	//switch ( functionName ) 
}
defaultproperties
{
}
