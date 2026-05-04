//=============================================================================
// Emitter: An Unreal Emitter Actor.
//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class Emitter extends Actor
	native
	placeable;

#exec Texture Import File=Textures\S_Emitter.pcx  Name=S_Emitter Mips=Off MASKED=1


var()	export	editinline	array<ParticleEmitter>	Emitters;

var		(Global)	bool				AutoDestroy;
var		(Global)	bool				AutoReset;
var		(Global)	bool				DisableFogging;
var		(Global)	bool				AutoReplay;//virus
var		(Global)	bool				bRotEmitter;//virus
var		(Global)	rotator				RotPerSecond;//virus
var		(Global)	rangevector			GlobalOffsetRange;
var		(Global)	range				TimeTillResetRange;

var		(Global)	bool				bUpdate;//virus
var		(Global)	bool				bAllDead;//virus
var		(Global)	bool				bAllDisabled;//virus
var		(Global)	bool				bActorForces;//virus
var		(Global)	bool				bOnInitialDelay;//virus

var		(SpawnSound)	array<sound>	SpawnSound;//virus
var		(SpawnSound)	float			SoundDelay;//virus
var		(SpawnSound)	float			SoundPitchMin;//virus
var		(SpawnSound)	float			SoundPitchMax;//virus
var		(SpawnSound)	bool			SoundLooping;//virus
var		(SpawnSound)	float			SoundFadeInDuration;//virus
var		(SpawnSound)	float			SoundFadeOutStart;//virus
var		(SpawnSound)	float			SoundFadeOutDuration;//virus

var		transient	int					Initialized;
var		transient	box					BoundingBox;
var		transient	float				EmitterRadius;
var		transient	float				EmitterHeight;
var		transient	bool				ActorForcesEnabled;
var		transient	vector				GlobalOffset;
var		transient	float				TimeTillReset;
var		transient	bool				UseParticleProjectors;
var		transient	ParticleMaterial	ParticleMaterial;
var		transient	bool				DeleteParticleEmitters;

// shutdown the emitter and make it auto-destroy when the last active particle dies.
native function Kill();
 
simulated function UpdatePrecacheMaterials()
{
	local int i;
	for( i=0; i<Emitters.Length; i++ )
	{
		if( Emitters[i] != None )
		{
			if( Emitters[i].Texture != None )
				Level.AddPrecacheMaterial(Emitters[i].Texture);
		}
	}
}

event Trigger( Actor Other, Pawn EventInstigator )
{
	local int i;
	for( i=0; i<Emitters.Length; i++ )
	{
		if( Emitters[i] != None )
			Emitters[i].Trigger();
	}
}

defaultproperties
{
     SoundPitchMin=1.000000
     SoundPitchMax=1.000000
     DrawType=DT_Particle
     RemoteRole=ROLE_None
     bNoDelete=True
     Texture=Texture'Engine.S_Emitter'
     Style=STY_Particle
     bUnlit=True
}
