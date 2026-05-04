//=============================================================================
// GameEngine: The game subsystem.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class GameEngine extends Engine
	native
	noexport
	transient;

// URL structure.
struct URL
{
	var string			Protocol,	// Protocol, i.e. "unreal" or "http".
						Host;		// Optional hostname, i.e. "204.157.115.40" or "unreal.epicgames.com", blank if local.
	var int				Port;		// Optional host port.
	var string			Map;		// Map name, i.e. "SkyCity", default is "Index".
	var array<string>	Op;			// Options.
	var string			Portal;		// Portal to enter through, default is "".
	var bool			Valid;
};

var Level			GLevel,
					GEntry;
var PendingLevel	GPendingLevel;
var URL				LastURL;
var config array<string>	ServerActors,
					ServerPackages;

var array<object> DummyArray;	// Do not modify	

// gam ---
var config String MainMenuClass;			// Menu that appears when you first start
var config String ConnectingMenuClass;		// Menu that appears when you are connecting
var config String DisconnectMenuClass;		// Menu that appears when you are disconnected
// --- gam

defaultproperties
{
     ServerActors(0)="IpDrv.MasterServerUplink"
     ServerActors(1)="UWeb.WebServer"
     ServerPackages(0)="Core"
     ServerPackages(1)="Engine"
     ServerPackages(2)="Fire"
     ServerPackages(3)="Editor"
     ServerPackages(4)="IpDrv"
     ServerPackages(5)="UWeb"
     ServerPackages(6)="GamePlay"
     MainMenuClass="XInterface.UT2MainMenu"
     ConnectingMenuClass="XInterface.MenuConnecting"
     CacheSizeMegs=32
}
