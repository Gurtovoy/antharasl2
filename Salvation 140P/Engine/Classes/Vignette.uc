//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class Vignette extends Actor
    abstract
    transient
    native;

var() String MapName;

simulated event Init();
simulated event DrawVignette( Canvas C, float Progress );

defaultproperties
{
     DrawType=DT_None
     RemoteRole=ROLE_None
     bNetTemporary=True
     bUnlit=True
     bGameRelevant=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
