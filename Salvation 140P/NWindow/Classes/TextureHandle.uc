/**
*텍스쳐컨트롤에 대한 함수를 정의하고 있다.
*/

class TextureHandle extends WindowHandle
	native;
/**
* 텍스쳐컨트롤에 텍스쳐를 입힌다.
* @param
* a_TextureName : 텍스쳐이름

* @return
* void

* @example
*var TextureHandle	hTex; //텍스쳐 핸들 선언
*hTex = GetTextureHandle("RadarMapWnd.texZone"); //텍스쳐컨트롤의 핸들을 가져온다
*hTex.SetTexture("L2UI_CT1.radarmap_df_region_gray"); //텍스쳐를 입힌다.
*/
native final function SetTexture( String a_TextureName );

/**
* 텍스쳐컨트롤의 시작좌표의 U,V 값을 정한다.
* @param
* a_U : U(가로) 값
* a_V : V(세로) 값

* @return
* void

* @example
*var TextureHandle	hTex; //텍스쳐 핸들 선언
*hTex = GetTextureHandle("RadarMapWnd.texZone"); //텍스쳐컨트롤의 핸들을 가져온다
*hTex.SetUV(100,100); //UV 값을 100,100 으로 한다.
*/
native final function SetUV( int a_U, int a_V );

/**
* 텍스쳐컨트롤의 사이즈를 정한다.
* @param
* a_UL : 가로값
* a_VL : 세로값

* @return
* void

* @example
*var TextureHandle	hTex; //텍스쳐 핸들 선언
*hTex = GetTextureHandle("RadarMapWnd.texZone"); //텍스쳐컨트롤의 핸들을 가져온다
*hTex.SetTextureSize(100,100); //사이즈를 100,100 으로 한다.
*/
native final function SetTextureSize( int a_UL, int a_VL );

/**
* 텍스쳐컨트롤의 타입을 정한다.
* @param
* type : 텍스쳐컨트롤의 타입
*enum ETextureCtrlType
*{
*    TCT_Stretch             =0,
*    TCT_Normal              =1,
*    TCT_Tile                =2,
*    TCT_Draggable           =3,
*    TCT_Control             =4,
*    TCT_Mask                =5,
*    TCT_MAX                 =6,
*};
* @return
* void

* @example
*var TextureHandle	hTex; //텍스쳐 핸들 선언
*hTex = GetTextureHandle("RadarMapWnd.texZone"); //텍스쳐컨트롤의 핸들을 가져온다
*hTex.SetTextureCtrlType(TCT_Stretch);
*/
native final function SetTextureCtrlType(ETextureCtrlType type);

/**
* 
* @param
* clanID : 

* @return
* void

* @example
*/
native final function SetTextureWithClanCrest(int clanID);

/**
* 
* @param
* objTexture : 

* @return
* void

* @example
*/
native final function SetTextureWithObject(texture objTexture);

/**
* 텍스쳐의 이름을 가져온다.
* @param
* void

* @return
* string : 텍스쳐의 이름

* @example
*var TextureHandle	hTex; //텍스쳐 핸들 선언
*hTex = GetTextureHandle("RadarMapWnd.texZone"); //텍스쳐컨트롤의 핸들을 가져온다
*hTex.SetTexture("L2UI_CT1.radarmap_df_region_gray"); //텍스쳐를 입힌다.
*debug(hTex.GetTextureName()); // 텍스쳐의 이름을 가져와 출력한다
*/
native final function string GetTextureName();

/**
* 텍스쳐의 자동 회전 타입을 정한다.
* @param
* objTexture : 회전타입 
*enum ETextureAutoRotateType
*{
*	ETART_None,
*	ETART_Camera,
*	ETART_Pawn
*};
* @return
* void

* @example
*var TextureHandle	hTex; //텍스쳐 핸들 선언
*hTex = GetTextureHandle("RadarMapWnd.texZone"); //텍스쳐컨트롤의 핸들을 가져온다
*hTex.SetTexture("L2UI_CT1.radarmap_df_region_gray"); //텍스쳐를 입힌다.
*hTex.SetAutoRotateType(ETART_Camera);
*/
native final function SetAutoRotateType(ETextureAutoRotateType Type);

/**
* 텍스쳐의 회전방향을 정한다.
* @param
* Dir : 방향

* @return
* void

* @example
*var TextureHandle	hTex; //텍스쳐 핸들 선언
*hTex = GetTextureHandle("RadarMapWnd.texZone"); //텍스쳐컨트롤의 핸들을 가져온다
*hTex.SetTexture("L2UI_CT1.radarmap_df_region_gray"); //텍스쳐를 입힌다.
*hTex.SetAutoRotateType(ETART_Camera);
*hTex.SetAutoRotatingDirection(1); 
*/
native final function SetRotatingDirection(int Dir);

/**
* 텍스쳐의 특정 좌표의 칼라를 가져온다.
* @param
* a_U : U(가로) 값
* a_V : V(세로) 값

* @return
* Color : 색상

* @example
*var TextureHandle	hTex; //텍스쳐 핸들 선언
*var Color TexColor;
*hTex = GetTextureHandle("RadarMapWnd.texZone"); //텍스쳐컨트롤의 핸들을 가져온다
*hTex.SetTexture("L2UI_CT1.radarmap_df_region_gray"); //텍스쳐를 입힌다.
*TexColor = hTex.GetColor(10,10); // 10,10 의 색상을 가져온다.
*/
native final function Color GetColor(int a_U, int a_V);

/**
* 텍스쳐의 기본 RGB 값을 변화시킨다.
* @param
* a_ColorModift : RGB 값

* @return
* void

* @example
*var TextureHandle	hTex; //텍스쳐 핸들 선언
*var Color TexColor;
*hTex = GetTextureHandle("RadarMapWnd.texZone"); //텍스쳐컨트롤의 핸들을 가져온다
*hTex.SetTexture("L2UI_CT1.radarmap_df_region_gray"); //텍스쳐를 입힌다.
*TexColor = hTex.GetColor(10,10); // 10,10 의 색상을 가져온다.
*hTex.SetColorModify(TexColor); //가져온 색상을 기준으로하여 RGB값을 변화시킨다
*/
native final function SetColorModify(Color a_ColorModify);
defaultproperties
{
}
