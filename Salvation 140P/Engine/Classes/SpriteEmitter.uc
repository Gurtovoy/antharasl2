//=============================================================================
// Emitter: An Unreal Sprite Particle Emitter.
//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class SpriteEmitter extends ParticleEmitter
	native;


enum EParticleDirectionUsage
{
	PTDU_None,
	PTDU_Up,
	PTDU_Right,
	PTDU_Forward,
	PTDU_Normal,
	PTDU_UpAndNormal,
	PTDU_RightAndNormal,
	PTDU_Scale
};


enum ESpriteRefraction//virus
{
	REF_None,
	REF_LightPerformance,
	REF_HeavyPerformanceButElaborate
};

var (Sprite)		EParticleDirectionUsage		UseDirectionAs;
var (Sprite)		vector						ProjectionNormal;
var (Sprite)		ESpriteRefraction			Refraction;//virus
var (Sprite)		float						RefrUScale;//virus
var (Sprite)		float						RefrVScale;//virus

var transient		vector						RealProjectionNormal;

defaultproperties
{
     ProjectionNormal=(Z=1.000000)
}
