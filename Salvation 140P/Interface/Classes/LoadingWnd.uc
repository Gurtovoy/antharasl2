class LoadingWnd extends UICommonAPI;

//var string LoadingTexture15;
var string LoadingTexture18;
var string LoadingTextureFree;

// 각 팁별로 포함된 이미지 경로
var string tipImgTexture;

var texturehandle blackbillboard;
var texturehandle loadingtexture;
var TextureHandle reviewTexture;

var string defaultBackgroundTextureStr;
var string defaultBackgroundTextureStr_Classic;
var string defaultBackgroundTextureStr_Arena;

function OnRegisterEvent()
{
	RegisterEvent( EV_ServerAgeLimitChange );
	RegisterEvent( EV_ResolutionChanged );
	RegisterEvent( EV_NeedResetUIData );
}

function OnLoad()
{
	blackbillboard = GetTextureHandle("LoadingWnd.BlackBackTex");
	loadingtexture = GetTextureHandle("LoadingWnd.BackTex");
	reviewTexture  = GetTextureHandle("LoadingWnd.ReviewTex");	
	
	// 19, 15, free 등급 텍스쳐 //한국에서 15 등급 삭제 12.06.18
	reviewTexture.SetTexture(LoadingTextureFree);	

	// 배경 
//	loadingtexture.SetTexture(defaultBackgroundTextureStr);	

	// 해상도에 따른 크기 조절 
	CheckResolution();	
}

function OnEvent( int a_EventID, String a_Param )
{
	local int ServerAgeLimitInt;
	local EServerAgeLimit ServerAgeLimit;
	if( a_EventID == EV_ServerAgeLimitChange )
	{
		// Debug("서버-------------------------------------------------" @ a_Param); 
		if( ParseInt( a_Param, "ServerAgeLimit", ServerAgeLimitInt ) )
		{
			ServerAgeLimit = EServerAgeLimit( ServerAgeLimitInt );
			switch( ServerAgeLimit )
			{
				/*
				case SERVER_AGE_LIMIT_15:
					debug( "LoadingTexture15=" $ LoadingTexture15 );
					reviewTexture.SetTexture(LoadingTexture15 );
					break;*/
				case SERVER_AGE_LIMIT_18:
					//debug( "LoadingTexture18=" $ LoadingTexture18 );
					reviewTexture.SetTexture( LoadingTexture18 );
					break;
				case SERVER_AGE_LIMIT_Free:
					//debug( "LoadingTextureFree=" $ LoadingTextureFree );
				default:
					reviewTexture.SetTexture(LoadingTextureFree );
					break;
			}
		}
	}
	
	else if( a_EventID == EV_ResolutionChanged)
	{
		CheckResolution();
	}

	else if (a_EventID == EV_NeedResetUIData )
	{
		if ( getInstanceUIData().getIsClassicServer() ) 		
			loadingtexture.SetTexture( defaultBackgroundTextureStr_Classic );		
		else if ( getInstanceUIData().getIsArenaServer() )
			loadingtexture.SetTexture( defaultBackgroundTextureStr_Arena ); 
		else 
			loadingtexture.SetTexture( defaultBackgroundTextureStr );		
	}
}

/** 외부에서(gameTipWnd) 배경 텍스쳐를 변경 할때 사용 */
function setBackgroundTextureStr(string changeTextureStr)
{	
	if (changeTextureStr == "")
	{
		if ( getInstanceUIData().getIsClassicServer() ) 
			loadingtexture.SetTexture( defaultBackgroundTextureStr_Classic );
		else if ( getInstanceUIData().getIsArenaServer() )
			loadingtexture.SetTexture( defaultBackgroundTextureStr_Arena ); 
		else
			loadingtexture.SetTexture( defaultBackgroundTextureStr );
	}
	else 
	{
		loadingtexture.SetTexture( changeTextureStr );
	}
}

/** 해상도에 따른 사이즈 변경 */
function CheckResolution()
{
	local int CurrentMaxWidth; 
	local int CurrentMaxHeight;

	GetCurrentResolution (CurrentMaxWidth, CurrentMaxHeight);
	blackbillboard.SetWindowSize(CurrentMaxWidth, CurrentMaxHeight);
	loadingtexture.SetWindowSize(CurrentMaxWidth, CurrentMaxHeight);
	loadingtexture.SetAnchor("LoadingWnd", "CenterCenter", "CenterCenter", 0, 0 );
	loadingtexture.SetWindowSizeRel43(1.f,1.f,0,0);

	reviewTexture.SetWindowSize(CurrentMaxWidth, CurrentMaxHeight);
	reviewTexture.SetAnchor("LoadingWnd", "CenterCenter", "CenterCenter", 0, 0 );
	reviewTexture.SetWindowSizeRel43(1.f,1.f,0,0);
}

defaultproperties
{
    LoadingTexture18="L2Font.skins.loading04-k"
    LoadingTextureFree="L2Font.skins.loading02-k"
    defaultBackgroundTextureStr="L2Font.Loading_Default_0000_001"
    defaultBackgroundTextureStr_Classic="L2Font.Loading_Default_0000_C001"
    defaultBackgroundTextureStr_Arena="L2Font.Loading_Default_0000_A001"
}
