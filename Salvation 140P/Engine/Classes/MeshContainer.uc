//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class  MeshContainer extends Object
	native;

struct MeshComponentArrayPtr { var int Ptr; };


var private Actor							Owner;
var private MeshComponent					FirstMeshComponent;				// MeshComponent ё®ЅєЖ®АЗ Г№№шВ° ЖчАОЕН
var private native MeshComponentArrayPtr	MeshComponentArray[41];			// ѕЖАМЕЫ ЅЅ·ФАЗ °№јц ST_MAX+2 ST_mAX°Ў єЇЗПёй јцБ¤ЗШБаѕЯЗСґЩ.
var private native MeshComponentArrayPtr	MeshComponentBufferArray[41];	// »х·Оїо ёЮЅ¬ДБЕЧАМіКё¦ АУЅГєё°ьЗСґЩ.

var private bool							bLoaded;

//by elsacred 
var sphere	BoundingVolume;					
var box		BoundingBox;
defaultproperties
{
}
