//=============================================================================
// Ambient sound -- Extended to support random interval sound emitters (gam).
// Copyright 2001 Digital Extremes - All Rights Reserved.
// Confidential.
//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class AmbientSound extends Keypoint
	native
	//
	hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force,Wind,Display);

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

#exec Texture Import File=Textures\Ambient.pcx Name=S_Ambient Mips=Off MASKED=1

// Sound will trigger every EmitInterval +/- Rand(EmitVariance) seconds.

struct SoundEmitter
{
    var() float EmitInterval;
    var() float EmitVariance;
    
    var transient float EmitTime;

    var() Sound EmitSound; // Manually re-order because Dan turned off property sorting and broke binary compatibility.
};

var(Sound) Array<SoundEmitter> SoundEmitters;
var globalconfig float AmbientVolume;		// ambient volume multiplier (scaling)

defaultproperties
{
     AmbientVolume=0.250000
     RemoteRole=ROLE_None
     bStatic=False
     bNoDelete=True
     Texture=Texture'Engine.S_Ambient'
     SoundRadius=100.000000
     SoundVolume=100.000000
}
