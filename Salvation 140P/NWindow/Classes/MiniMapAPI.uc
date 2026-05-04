class MiniMapAPI extends Object
	native;

native static function RequestCursedWeaponList();
native static function RequestCursedWeaponLocation();
// 시드주기 - elsacred 2008.10.16
native static function RequestSeedPhase();

// 월드맵 개선(#3328) - moonhj
native static function RequestRaidBossSpawnInfo(array<int> arrNpcIDs);
native static function RequestItemAuctionStatus();
native static function RequestRaidServerInfo();
native static function RequestShowAgitSiegeInfo();
defaultproperties
{
}
