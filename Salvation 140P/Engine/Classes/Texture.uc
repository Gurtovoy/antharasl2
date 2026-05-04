//=============================================================================
// Texture: An Unreal texture map.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class Texture extends BitmapMaterial
	safereplace
	native
	noteditinlinenew
	dontcollapsecategories
	noexport;

// Palette.
var(Texture) palette Palette;

// Detail texture.
var(Texture) Material Detail;
var(Texture) float DetailScale;

// Internal info.
var const color MipZero;
var const color MaxColor;
var const int   InternalTime[2];

// Deprecated stuff.
var deprecated texture DetailTexture;	// Detail texture to apply.
var deprecated texture EnvironmentMap;	// Environment map for this texture
var deprecated enum EEnvMapTransformType 
{
	EMTT_ViewSpace,
	EMTT_WorldSpace,
	EMTT_LightSpace,
} EnvMapTransformType;
var deprecated float Specular;		// Specular lighting coefficient.


// Texture flags.
var(Surface)			bool bMasked;
var(Surface)			bool bAlphaTexture;
var(Surface)			bool bTwoSided;
var(Quality) private	bool bHighColorQuality;   // High color quality hint.
var(Quality) private	bool bHighTextureQuality; // High color quality hint.
var private				bool bRealtime;           // Texture changes in realtime.
var private				bool bParametric;         // Texture data need not be stored.
var private transient	bool bRealtimeChanged;    // Changed since last render.
var const editconst private  bool bHasComp;		//!!OLDVER Whether a compressed version exists.

var(Split9)				bool bSplit9Texture;
var(Split9)				int Split9X1;
var(Split9)				int Split9X2;
var(Split9)				int Split9X3;
var(Split9)				int Split9Y1;
var(Split9)				int Split9Y2;
var(Split9)				int Split9Y3;
var						int	pSplit9TexCacheMap;
var(Texture) bool	bGammaCorrection;
// Level of detail set
var() enum ELODSet
{
	LODSET_None,
	LODSET_World,
	LODSET_PlayerSkin,
	LODSET_WeaponSkin,
	LODSET_Terrain,
	LODSET_Interface,
	LODSET_RenderMap,
	LODSET_Lightmap,
} LODSet;

var() int NormalLOD;
var int MinLOD;
var transient int MaxLOD;

// Animation.
var(Animation) texture AnimNext;
var transient  texture AnimCurrent;
var(Animation) byte    PrimeCount;
var transient  byte    PrimeCurrent;
var(Animation) float   MinFrameRate, MaxFrameRate;
//#ifdef	__L2 Hunter
var(Animation) int	   TotalFrameNum;
//#endif
//#ifdef	__L2 jumper
var(Animation) bool		OneTimeAnimLoop;
var transient  bool		LoopFlag;
//#endif
var transient  float   Accumulator;
var transient  float   SurplusTime;

// Mipmaps.
var private native const array<int> Mips;
var const editconst ETextureFormat CompFormat; //!!OLDVER

var const transient int	RenderInterface;
var const transient int	__LastUpdateTime[2];

defaultproperties
{
    DetailScale=8.00
    MipZero=(R=64,G=128,B=64,A=0),
    MaxColor=(R=255,G=255,B=255,A=255),
    LODSet=1
}
