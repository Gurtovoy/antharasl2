//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
//__L2 kurt
class NProjectile extends Emitter
	dynamicrecompile
	native;

// Motion information.
var		float   Speed;               // Initial speed of projectile.
var		float   AccSpeed;            // Limit on speed of projectile (0 means no limit)

var		Actor	TargetActor;
var		vector LastTargetLocation;
var		rotator	LastTargetRotation;	// by nonblock
var     Actor	TraceActor;

var		bool	 bTrackingCamera;

//#ifdef __L2 by nonblock
var(interpolation)		bool	 bHermiteInterpolation;
var(interpolation)		vector	 VelInitial;
var(interpolation)		vector	 VelFinal;
var(interpolation)		vector	 LocInitial;
var(interpolation)		float	 Duration;
var(interpolation)		transient	float	CurTime;
var(interpolation)		float	 Disp;
//var(interpolation)		range	DurationRange;
//var(interpolation)		float	DurationCoef;
var transient NMagicInfo     MagicInfo;
//#endif

// #ifdef __L2 // anima - єЈБцѕо °ој±
var(interpolation)		bool				bBezierCurve;
var(interpolation)		array<vector>		ControlPoints;
// #endif

//Жщ№Я»зГјё¦ А§ЗС ЗКµе
var	int				EffectPawnClassID; //ЅєЖщµЙ ЖщЕ¬·ЎЅє
var	bool			bEffectPawnIsNpc;  //NPCGRPё¦ ВьБ¶ЗТ°НАО°Ў? ѕЖґПёй АЪЅЕАЗ є№»зГјё¦ »зїл
var	name			SequenceName;	//ЗГ·№АМµЙ ѕЦґПёЮАМјЗ ЅГДцЅє
var Pawn			ProjectilePawn;
var vector			ProjectilePawnOffset;
var float			ProjectilePawnScale;
//

var transient	float	LifetimeAfterHit;

simulated event	ShotNotify();

// __L2 by nonblock
simulated event PreshotNotify(Pawn Attacker);
// #endif


defaultproperties
{
    Speed=10.00
    AccSpeed=10.00
    EffectPawnClassID=-1
    bEffectPawnIsNpc=True
    ProjectilePawnScale=1.00
    bNoDelete=False
    LifeSpan=100.00
    CollisionRadius=5.00
    CollisionHeight=5.00
}
