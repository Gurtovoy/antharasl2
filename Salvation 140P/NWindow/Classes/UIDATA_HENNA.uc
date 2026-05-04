class UIDATA_HENNA extends UIDataManager
	native;

native static function bool GetItemCheck( int a_ID ); //branch121212
native static function string GetItemNameS( int a_ID );
native static function string GetDescriptionS( int a_ID );
native static function string GetIconTexS( int a_ID );

//branch GD35_0828 2014-1-9 luciper3 - 헤나의 추가 정보도 얻어갈수있도록 만든 함수
native static function string GetAddtionNameS( int a_ID );
//end of branch

native static function bool GetItemName( int a_ID, out String a_ItemName );
native static function bool GetDescription( int a_ID, out String a_Description );
native static function bool GetIconTex( int a_ID, out String a_IconTex );
defaultproperties
{
}
