//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class NCubics extends Emitter	
	dynamicrecompile
	native;

var enum ESummonCubicType
{
	CUBIC_DO_NOT_EXIST,	
	CUBIC_DD,
	CUBIC_DRAIN,
	CUBIC_HEAL,
	CUBIC_POISON,
	CUBIC_DEBUF,
	CUBIC_PARALYZE,
	CUBIC_WATER_DOT,
	CUBIC_SHOCK,
	CUBIC_ATTRACT,
	CUBIC_TEMPLEK_SMART,
	CUBIC_SHILLIENK_SMART,
	CUBIC_WARLOCK_SMART,
	CUBIC_ELEMENTALS_SMART,
	CUBIC_PHANTOMS_SMART,
	CUBIC_AVENGE,
	CUBIC_KNIGHT,
	CUBIC_HEALER,
	CUBIC_SIGEL_LIFE,
	CUBIC_SIGEL_MIND,
	CUBIC_SIGEL_VAMPIRIC,
	CUBIC_SIGEL_HEX,
	CUBIC_SIGEL_GUARDIAN,
} CubicType;

var enum ECubicMovementType
{
	ECMT_FOLLOW,
	ECMT_FLOAT,
	ECMT_SKILLUSE,
	ECMT_BUFF,
	ECMT_FLOATSTART,
	ECMT_ONVEHICLE,

} CubicMovementType;

var vector	DestLocation;
var int		CubicIndex;
var int		SkillID;
var	pawn	TargetPawn;
var float	SkillActiveTime;
//var	rotator	RotPerSecond;
var transient NMagicInfo     MagicInfo;

defaultproperties
{
    CubicIndex=-1
    SkillID=-1
    NoCheatCollision=True
    bNoDelete=False
    bAlwaysRelevant=True
    NetUpdateFrequency=8.00
    NetPriority=1.40
    CollisionRadius=0.10
    CollisionHeight=0.10
    bFixedRotationDir=True
}
