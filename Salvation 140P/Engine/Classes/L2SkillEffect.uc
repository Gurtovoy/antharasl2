//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class L2SkillEffect extends Object
	native
	dynamicrecompile		
	hidecategories(Object);

	
////////////////////////////////////////////////////////////////////////////////
// general
////////////////////////////////////////////////////////////////////////////////
var(general)		string		Desc;				// Skill Description
var(general)		int			SkillID;			// Skill ID


////////////////////////////////////////////////////////////////////////////////
// visual
////////////////////////////////////////////////////////////////////////////////
var(visual)	array<editinlinenotify L2EffectEmitter>		CastingAction;
var(visual)	array<editinlinenotify L2EffectEmitter>		ChannelingAction;
var(visual)	array<editinlinenotify L2EffectEmitter>		PreshotAction;
var(visual)	array<editinlinenotify L2EffectEmitter>		ShotAction;
var(visual)	array<editinlinenotify L2EffectEmitter>		ExplosionAction;
var(visual)	array<editinlinenotify L2EffectEmitter>		UnionTargetAction;

var(visual)		float		FlyingTime;
var(visual)		float		TotalScaleSize;

var		bool bHideRightHandMesh;
var		bool bHideLeftHandMesh;

var		bool bShowCameraEffectOnlyMe;
var		class CastingCameraEffectInfoClass;
var		class ShotCameraEffectInfoClass;
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

defaultproperties
{
    bShowCameraEffectOnlyMe=True
}
