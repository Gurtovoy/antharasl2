//=============================================================================
// Пакет перепаковал и переработал BITHACK Исправил BITHACK =)
//=============================================================================
class ColorMask extends RealtimeGenerationTexture;
	//native;

enum ColorMaskBlendType
{
   COLORMASK_AlphaBlend,
   COLORMASK_Add,
};

var() ColorMaskBlendType ColorMaskBlend;
var() Texture OrgTexture;
var() MaskTexture MaskTexture;
var() Color ModifierColor;

defaultproperties
{
}
