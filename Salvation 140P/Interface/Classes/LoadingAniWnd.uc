class LoadingAniWnd extends UIScript;

var texturehandle LoadingAniTexture;

function OnRegisterEvent()
{
	RegisterEvent( EV_ResolutionChanged );
}

function OnLoad()
{
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	if(CREATE_ON_DEMAND==0)
		LoadingAniTexture = TextureHandle(GetHandle("LoadingAniWnd.LoadingAniTex"));	
	else
		LoadingAniTexture = GetTextureHandle("LoadingAniWnd.LoadingAniTex");	

	CheckResolution();	
}

function OnEvent( int a_EventID, String a_Param )
{	
	if( a_EventID == EV_ResolutionChanged)
	{
		CheckResolution();
	}
}

function CheckResolution()
{
	local int CurrentMaxWidth; 
	local int CurrentMaxHeight;
	local int RealWidth;
	local int RealHeight;	
	local float MoveY;
	
	GetCurrentResolution (CurrentMaxWidth, CurrentMaxHeight);

	RealWidth	= CurrentMaxWidth;
	RealHeight	= CurrentMaxHeight;

	if ( CurrentMaxWidth * 3 >= CurrentMaxHeight * 4 )
		RealWidth = RealHeight * 4 / 3;
	else
		RealHeight = RealWidth * 3 / 4;
	
	//~ if( RealHeight == CurrentMaxHeight )
		//~ MoveY = -30.f * (RealHeight / 768.f );
	//~ else	
		//~ MoveY = (-30.f * (RealHeight / 768.f )) + ((RealHeight - CurrentMaxHeight) / 2.f);

	//~ LoadingAniTexture.SetWindowSize( RealWidth * 15 / 100, RealHeight * 8 / 100 );
	//~ LoadingAniTexture.SetAnchor("LoadingAniWnd", "BottomCenter", "BottomCenter", 0, MoveY );	
	
	if( RealHeight == CurrentMaxHeight )
		MoveY = -23.f * (RealHeight / 768.f );
	else       
		MoveY = (-23.f * (RealHeight / 768.f )) + ((RealHeight - CurrentMaxHeight) / 2.f);

	LoadingAniTexture.SetWindowSize( RealWidth * 12.05f / 100.f, RealHeight * 5f / 100.f );
	LoadingAniTexture.SetAnchor("LoadingAniWnd", "BottomCenter", "BottomCenter", 0, MoveY );   
}
defaultproperties
{
}
