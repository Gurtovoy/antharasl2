//=============================================================================
// Emitter: An Unreal VertMesh Particle Emitter.
//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class VertMeshEmitter extends ParticleEmitter	
	noexport
	native;

var	transient array<int>							VertexStreams;
var	transient array<int>							IndexBuffer;
var transient array<float>							AnimFrame;	

var (VertMesh) array<float>				AnimRate;
var (VertMesh) array<float>				StartAnimFrame;
var	(VertMesh) Mesh						VertexMesh;

var (VertMesh)		bool				UseMeshBlendMode;
var (VertMesh)		bool				RenderTwoSided;
var (VertMesh)		bool				UseParticleColor;

var	transient		vector				MeshExtent;
var transient		array<MeshInstance> MeshInstance;

defaultproperties
{
     UseMeshBlendMode=True
     RenderTwoSided=True
     StartSizeRange=(X=(Min=0.000000,Max=0.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
}
