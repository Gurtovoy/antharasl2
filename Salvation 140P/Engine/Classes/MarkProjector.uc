//=============================================================================
//	__L2 kurt
//	MarkProjector
//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class MarkProjector extends Projector
	placeable
	native;

var() vector				DesireLocation;
var() vector				OffsetDesireLocation;
var() bool					bAttachMark;
var() Actor					ProjectedActor;	


// ifdef __L2 kurt
native final function bool UpdateDesireLocation();
// endif

//
//	PostBeginPlay
//

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	Enable('Tick');
}

simulated event Destroyed()
{
	Super.Destroyed();
}
simulated function Timer()
{
	DetachProjector(true);
}
//
//	UpdateMarkProjector
//

function UpdateMarkProjector()
{
//	local vector	ShadowLocation;
//	local Plane		BoundingSphere;
//	local vector HitNormal,
//				   HitLocation,
//				   Dir;
//	local float  Distance;

	if(bAttachMark)
	{
		DetachProjector(true);
		SetCollision(false,false,false);

	//if(ShadowActor != None && !ShadowActor.bHidden)
	//{		

		FOV = 1;

		UpdateDesireLocation();
    
		//Trace(HitLocation,HitNormal,OffsetDesireLocation,DesireLocation);
		SetLocation(DesireLocation);
		//SetRotation(Rotator(Normal(-OffsetDesireLocation)));
		SetRotation(Rotator((-OffsetDesireLocation)));
		//SetRotation(Rotator(-vect(1,1,8)));
		//SetRotation(Rotator(vect(0,1,0)));
		//SetRotation(Rotator(vect(1,0,0)));
		//SetRotation(Rotator(Normal(-LightDirection)));
		SetDrawScale(0.10);

		AttachProjector();
		SetCollision(true,false,false);
		bAttachMark=false;
		SetTimer(10, false);
	}
	//}
}

//
//	Tick
//

simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
	UpdateMarkProjector();
}

simulated event Touch( Actor Other )
{
	//if( Other.bAcceptsProjectors && (ProjectTag=='' ||	Other.Tag==ProjectTag) && (bProjectStaticMesh || Other.StaticMesh == None) && (Pawn(Other) != None))
	if( Other.bAcceptsProjectors && (ProjectTag=='' ||	Other.Tag==ProjectTag) && (bProjectStaticMesh && Other.StaticMesh != None) )
		AttachActor(Other);
}
//
//	Default properties
//

defaultproperties
{
    MaterialBlendingOp=2
    FrameBufferBlendingOp=2
    bProjectBSP=False
    bProjectStaticMesh=False
    bProjectParticles=False
    bProjectActor=False
    bClipBSP=True
    bGradient=True
    bProjectOnAlpha=True
    bProjectOnParallelBSP=True
    bStatic=False
}
