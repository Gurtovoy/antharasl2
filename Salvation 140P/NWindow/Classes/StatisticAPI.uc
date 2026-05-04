class StatisticAPI extends UIDataManager
	native;
	
native static function string GetTitleNameOfStatistic(int id);
native static function string GetContentInfo(int id);
native static function string GetTableOfContent();

native static function RequestHotLinkStatistics(int id);
native static function RequestWorldStatistics(int id);
native static function RequestUserStatistics();
defaultproperties
{
}
