class ViewPortWndBase extends UICommonAPI;

var string m_WindowName;
var WindowHandle Me;
var	CharacterViewportWindowHandle	m_ObjectViewport ;

const EFFECT_MONSTER_ID        = 19671 ;

function onLoad ( ) 
{
	m_WindowName = getCurrentWindowName( string(self) ) ;
	InitializeCOD() ;
	registerState( "ViewPortWndBase", "CHARACTERSELECTSTATE" );

//	Debug( "onLoad" @ m_WindowName );
}

function InitializeCOD()
{		
	Me = GetWindowHandle( m_WindowName );		
	m_ObjectViewport    = GetCharacterViewportWindowHandle(m_WindowName $ ".EffectStageWnd.ObjectViewport");			
	m_ObjectViewport.SetSpawnDuration ( 0.2 );	
	Me.DisableWindow();
}

function SetNPCViewportData ( int ID ) 
{
	m_ObjectViewport.SetNPCViewportData( ID ) ;
}

function SpawnEffect ( string effectname )
{
	m_ObjectViewport.SpawnEffect( effectname ) ;
}

function SpawnNPC ( )
{
	m_ObjectViewport.SpawnNPC( ) ;
}

function PlayAnimation ( int index )
{
	m_ObjectViewport.PlayAnimation( index ) ;
}

function StartRotation ( bool isRight )
{
	m_ObjectViewport.StartRotation( isRight ) ;
}

function EndRotation ( )
{
	m_ObjectViewport.EndRotation( ) ;
}

function SetNPCInfo ( int index ) 
{
	m_ObjectViewport.SetNPCInfo( index ) ;
}

function StartZoom ( bool isZoomOut ) 
{
	m_ObjectViewport.StartZoom( isZoomOut ) ;
}

function EndZoom ( ) 
{
	m_ObjectViewport.EndZoom();
}

function SetCharacterScale ( float scale ) 
{
	m_ObjectViewport.SetCharacterScale( scale );
}


function SetCharacterOffsetX ( int position ) 
{
	m_ObjectViewport.SetCharacterOffsetX( position );
}

function SetCharacterOffsetY ( int position ) 
{
	m_ObjectViewport.SetCharacterOffsetY( position );
}


function SetCharacterOffsetZ ( int position ) 
{
	m_ObjectViewport.SetCharacterOffsetZ( position );
}

function SetCharacterOffset ( int x, int y, int  z ) 
{
	m_ObjectViewport.SetCharacterOffset( setVector(x, y, z) );	
}

function PlayAttackAnimation ( int index ) 
{
	m_ObjectViewport.PlayAttackAnimation( index );	
}

function AutoAttacking ( bool isAutoAttack ) 
{
	m_ObjectViewport.AutoAttacking( isAutoAttack );	
}


function ShowNPC ( float  duration ) 
{
	m_ObjectViewport.ShowNPC( duration );	
}

function HideNPC ( float  duration ) 
{
	m_ObjectViewport.HideNPC( duration );	
}

function SetDragRotationRate ( int  rate ) 
{	
	m_ObjectViewport.SetDragRotationRate( rate );	
}

function SetCurrentRotation ( int rotation  ) 
{
	m_ObjectViewport.SetCurrentRotation( rotation  );	
}


function SetCameraDistance ( int distance ) 
{
	m_ObjectViewport.SetCameraDistance(distance ); //nDist
}

function SetSpawnDuration ( float  duration ) 
{
	m_ObjectViewport.SetSpawnDuration( duration); //fDuration	
}

function SetUISound ( bool isSound ) 
{
	m_ObjectViewport.SetUISound( isSound ); //IsUISound	
}

//테스트용 함수
function onCallUCFunction( string functionName, string param )
{	
	//Debug("sampe's onCallUCFunction" @ m_WindowName @ functionName @ param);
	switch ( functionName ) 
	{		
		// 이펙트를 교체
		case "SpawnEffect" :
			SpawnEffect( param ) ;
			//m_ObjectViewport.PlayAnimation( int( param )   ) ;			
		break;
		// 소환 된 몬스터 교체
		case "SpawnNPC" : 
			SpawnNPC();									
			break;
		case "PlayAnimation" :
			PlayAnimation( int( param )   ) ;					
		break;
		case "StartRotation" :
			StartRotation( bool (param) ); //bRight
		break;
		case "EndRotation" :
			EndRotation();
		break;
		case "StartZoom" :
			StartZoom( bool (param)  ); //bOut
		break;
		case "EndZoom" :
			EndZoom();
		break;
		case "SetCharacterScale" :
			SetCharacterScale( float (param)  ); //fCharacterScale
		break;
		case "SetCharacterOffsetX" :
			SetCharacterOffsetX( int (param)  ); //nOffsetX
		break;
		case "SetCharacterOffsetY" :
			SetCharacterOffsetY( int (param)  ); //nOffsetY
		break;
		case "SetCharacterOffsetZ" :
			SetCharacterOffsetZ( int ( param ) );	// nOffsetZ
		break;
		case "SetCharacterOffset" :
			handleSetCharacterOffset ( param ) ;        // vCharacterOffset
		break;		
		case "PlayAttackAnimation" :
			PlayAttackAnimation(int (param) ); //index
		break;
		case "AutoAttacking" :
			AutoAttacking(bool (param) ); //bAttack
		break;
		case "ShowNPC" :
			ShowNPC( float (param) ); //Duration
		break;
		case "HideNPC" :
			HideNPC( float (param) ); //Duration
		break;
		case "SetNPCInfo" :
			SetNPCInfo(int (param) ); //id
		break;
		case "SetDragRotationRate" :
			SetDragRotationRate(int (param) ); //nRotationRate
		break;
		case "SetCurrentRotation" :
			SetCurrentRotation( int (param)  ); //nRotation
		break;		
		case "SetCameraDistance" :
			SetCameraDistance(int (param) ); //nDist
		break;
		case "SetSpawnDuration" :
			SetSpawnDuration(float (param) ); //fDuration
		break;		
		case "SetUISound" :
			SetUISound( bool ( param ) ); //IsUISound
		break;

		
	}
	Me.BringToFront( ) ;
}

function handleSetCharacterOffset ( string param ) 
{	
	local int x, y, z;
//	local Vector loc;

	ParseInt(Param, "x", x);  
	ParseInt(Param, "y", y);
	ParseInt(Param, "z", z);
	//Debug ( "handleSetCharacterOffset" @ x @ y @ z  @ setVector(x, y, z)) ; 
	SetCharacterOffset( x, y, z );	
}


/***********************************************************************************************
 * etc 
 * *********************************************************************************************/

defaultproperties
{
    m_WindowName="ViewPortWndBase"
}
