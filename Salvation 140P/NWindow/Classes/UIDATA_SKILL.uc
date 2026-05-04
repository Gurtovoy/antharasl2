class UIDATA_SKILL extends UIDataManager
	native;

native static function ItemID GetFirstID();
native static function ItemID GetNextID();
native static function int GetDataCount();
native static function string GetIconName( ItemID ID, int level, int sublevel );
native static function string GetName( ItemID ID, int level, int sublevel );
native static function string GetDescription( ItemID ID, int level, int sublevel );
native static function string GetEnchantName( ItemID ID, int level, int sublevel );
native static function int GetEnchantSkillLevel( ItemID ID, int level, int sublevel );
native static function string GetEnchantIcon( ItemID ID, int level, int sublevel );
native static function string GetOperateType( ItemID ID, int level, int sublevel );
native static function bool IsAlchemySkill( ItemID ID, int level );	// 연금술 작업 - by y2jinc
native static function int GetHpConsume( ItemID ID, int level, int sublevel );
native static function int GetMpConsume( ItemID ID, int level, int sublevel );
native static function int GetCastRange( ItemID ID, int level, int sublevel );
native static function int GetUltimateSkillLevel( ItemID ID, int level, int sublevel );
native static function int SkillIsNewOrUp( ItemID ID );

// 내 스킬 목록 창에 있는 스킬IDs
native static function GetCurrentSkillList(out Array<ItemID> IDs);

// [N토핑 버프]클라이언트 UI 관련 이벤트 및 API 작업(#1695) - y2jinc
native static function bool IsToppingSkill(ItemID ID, int level, int sublevel);
native static function bool GetToppingSkillExtraInfo(ItemID ID, int level, int sublevel, out ToppingSkillExtraInfo info);
native static function bool GetFirstDefaultToppingSkillExtraInfo(out ToppingSkillExtraInfo info);
native static function bool GetNextDefaultToppingSkillExtraInfo(out ToppingSkillExtraInfo info);
defaultproperties
{
}
