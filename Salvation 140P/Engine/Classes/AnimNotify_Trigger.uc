//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class AnimNotify_Trigger extends AnimNotify_Scripted;

var() name EventName;

event Notify( Actor Owner )
{
	Owner.TriggerEvent( EventName, Owner, Pawn(Owner) );
}

defaultproperties
{
}
