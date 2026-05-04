//=============================================================================
//  Class:  XAdmin.xAdminConfigBase
//  Parent: XAdmin.xAdminBase
//
//  <Enter a description here>
//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class xAdminConfigBase extends xAdminBase;

static function bool Load(xAdminUserList Users, xAdminGroupList Groups, bool bDontAddDefaultAdmin);
static function bool Save(xAdminUserList Users, xAdminGroupList Groups);

defaultproperties
{
}
