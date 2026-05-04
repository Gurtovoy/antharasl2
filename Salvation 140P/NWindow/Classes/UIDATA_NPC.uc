class UIDATA_NPC extends UIDataManager
	native;

native static function int GetFirstID();
native static function int GetNextID();
native static function bool IsValidData(int id);
native static function string GetNPCName(int id);
native static function bool GetNpcProperty(int id, out Array<int> arrProperty);
native static function int	GetSummonSort(int id);
native static function int	GetSummonMaxCount(int id);
native static function int	GetSummonGrade(int id);
native static function string GetNPCIconName(int id);
native static function int GetMentoringNPCId();

native static function string GetNPCMesh( int id );
native static function string GetNPCTexture( int id, int texIndex );
defaultproperties
{
}
