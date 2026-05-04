//=============================================================
// MeshComponent
// flagoftiger 20070221
//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class MeshComponent extends Object
	native;

enum EMeshComponentStatus
{
	MCS_None,
	MCS_FADEIN,			// ёёµйѕоБ®ј­ ЖдАМµе АОµЗґВ »уЕВ
	MCS_FADEOUT,		// »иБ¦µЗ±в АьїЎ ЖдАМµе ѕЖїфµЗґВ »уЕВ
	MCS_READYTOFADEOUT,	// ЖдАМµе ѕЖїф µЗѕоѕЯЗТ »уЕВ
	MCS_CREATED,		// ё· ёёµйѕоБш »уЕВ (·Оµщ µЗ±в Аь)
	MCS_DELETEME		// »иБ¦µЗѕоѕЯ ЗПґВ »уЕВ
};

enum EMeshSimulationType
{
	EMST_None,
	EMST_HAIR,			// ±вБёАЗ ЗмѕоЅГ№Д·№АМјЗ
	EMST_CLOTH			// »х·Оїо їК°Ё ЅГ№Д·№АМјЗ
};

enum EMeshMirrorType
{
	EMMT_NONE,
	EMMT_YZ,	// FPlane(1, 0, 0, 0)
	EMMT_ZX,	// FPlane(0, 1, 0, 0)
	EMMT_XY,	// FPlane(0, 0, 1, 0)
};

struct native constructive MeshComponentData
{
	var Name			MeshName;
	var array<Name>		TexNames;
	var Name			TexChangableName;		// TexnamesїЎј­ јіБ¤µИ NameБЯ БЯ°ЈїЎ ±іГј°Ў µЙ°жїм АМЕШЅєГі·О №ЩІо°ФµИґЩ.№ЩІрјцАЦґВ ЕШЅєГДґВ ЗПіЄ¶у°н °ЎБ¤ЗП°н UserDefineMaterial·О јіБ¤µЗѕо АЦѕоѕЯЗСґЩ.by elsacred
	var	int				BodyPart;				// ѕо¶І ѕЖАМЕЫ SlotїЎАЗЗС MeshАОБц ѕЛ±вА§ЗШ
	var bool			bAnimOwner;				// ѕЦґПёЮАМјЗА» °ЎБш ёЮЅ¬АОБц
	var int				SimulationType;				// Змѕо ЅГ№Д·№АМјЗА» ЗПґВ ёЮЅ¬АОБц
	var int				AttachType;				// Attach Type (№«±в, №жѕо±ё)
	var Name			AttachBoneName;			// AttachµЙ Bone Name
	var Vector			AttachOrigin;			// MeshАЗ »уґлАыАО Origin (ЗмѕоѕЗјј»зё®їЎ »зїл)
	var Rotator			AttachRotOrigin;		// MeshАЗ »уґлАыАО RotOrigin (ЗмѕоѕЗјј»зё®їЎ »зїл)
	var int				AttachMirrorType;		// °ЭЕх№«±в їЮјХїЎ »зїл (e_hand)
	var Vector			RenderScale;			// ·Јґхёµ ЅєДЙАП (Pawn·№АМѕоїЎј­ °и»к °ЎґЙЗС °НА» ЗШј­ іС±вАЪ)
	var Color			ColorVariationColor;
	var bool			bRender;
};

var private Actor				Owner;
var	private Mesh				Mesh;	
var	private MeshInstance		MeshInstance;
var	private array<Material>		Materials;
var MeshComponent				LastMeshComponent;
var MeshComponent				NextMeshComponent;
var MeshComponent				AnimMeshComponent;		// AnimationА» °ЎБш MeshComponentАЗ ЖчАОЕН
var MeshComponentData			MeshData;

var private	float				fAlphaFactor;
var private bool				bLoaded;
var private bool				bByResourceManager;
var private EMeshComponentStatus MeshComponentStatus;
var int							SkinnedDataIndex;
var private bool				m_bRender;

defaultproperties
{
    SkinnedDataIndex=-1
    m_bRender=True
}
