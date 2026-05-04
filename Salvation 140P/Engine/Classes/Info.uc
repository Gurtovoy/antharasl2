//=============================================================================
// Info, the root of all information holding classes.
//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class Info extends Actor
	abstract
	hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force)
	native;

// mc: Fill a PlayInfoData structure to allow easy access to 
static function FillPlayInfo(PlayInfo PlayInfo)
{
	PlayInfo.AddClass(default.Class);
}

static event bool AcceptPlayInfoProperty(string PropertyName)
{
	return true;
}

defaultproperties
{
     RemoteRole=ROLE_None
     bHidden=True
     bSkipActorPropertyReplication=True
     bOnlyDirtyReplication=True
     NetUpdateFrequency=10.000000
}
