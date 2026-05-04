//=============================================================================
/// UnrealScript Commandlet (command-line applet) class.
///============================================================================
/// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class Commandlet
	extends Object
	abstract
	transient
	noexport
	native;

/// Command name to show for "ucc help".
var localized string HelpCmd;

/// Command description to show for "ucc help".
var localized string HelpOneLiner;

/// Usage template to show for "ucc help".
var localized string HelpUsage;

/// Hyperlink for more info.
var localized string HelpWebLink;

/// Parameters and descriptions for "ucc help <this command>".
var localized string HelpParm[16];
var localized string HelpDesc[16];

/// Whether to redirect log output to console stdout.
var bool LogToStdout;

/// Whether to load objects required in server, client, and editor context.
var bool IsServer, IsClient, IsEditor;

/// Whether to load objects immediately, or only on demand.
var bool LazyLoad;

/// Whether to show standard error and warning count on exit.
var bool ShowErrorCount;

/// Whether to show Unreal banner on startup.
var bool ShowBanner;

/// Entry point.
native event int Main( string Parms );

defaultproperties
{
     LogToStdout=True
     IsServer=True
     IsClient=True
     IsEditor=True
     LazyLoad=True
     ShowBanner=True
}
