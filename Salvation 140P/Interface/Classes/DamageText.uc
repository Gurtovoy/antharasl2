//------------------------------------------------------------------------------------------------------------------------
//
// 제목        : DamageText  ( 데미지텍스트) - SCALEFORM UI - 
//
//------------------------------------------------------------------------------------------------------------------------
class DamageText extends GFxUIScript;

const FLASH_WIDTH  = 800;
const FLASH_HEIGHT = 600;

var int currentScreenWidth, currentScreenHeight;

enum EDamageTextType
{
	NOMAKE,                 // 없을때 
	NormalAttack,           // 기본 공격
	ConsecutiveAttack,      // 연속 공격 (연속 데미지, 도트 데미지)
	Critical,               // 크리티컬
	OverHit,                // 오버히트
	RecoverHP,              // 회복 HP
	RecoverMP,              // 회복 MP
	GetSP,                  // SP 받기 
	GetExp,                 // 경험치 받기
	MagicDefiance,          // 마법 저항 
	ShieldGuard,            // 방패 막기
	Dodge,                  // 회피
	Immune,                 // 면역
	SkillHit,               // 스킬 히트
	Etc                     // 기타
};

function OnRegisterEvent()
{
	// 데미지 텍스트 생성, 좌표 업데이트 
	RegisterEvent(EV_DamageTextCreate);
	RegisterEvent(EV_DamageTextUpdate);

	// 시스템 메세지를 후킹하기 위한 이벤트
	// RegisterEvent(EV_SystemMessage);		
}

function OnLoad()
{
	registerState( "DamageText", "GamingState" );
	// class'UIAPI_WINDOW'.static.SetAnchor( "", "DamageText", "TopLeft", "BottomLeft", 0, 0 );
	SetAnchor("", EAnchorPointType.ANCHORPOINT_TopLeft, EAnchorPointType.ANCHORPOINT_TopLeft, 0, 0);
}

function OnShow()
{
	// Debug("DamageText!!!! onShow");
}

function OnFlashLoaded()
{
	RegisterDelegateHandler(EDHandler_DamageText);
	SetAlwaysFullAlpha(true);
	IgnoreUIEvent(true);
}

function OnHide()
{
}

function OnCallUCLogic( int logicID, string param )
{
}

// 5370
// clipName=테스트111 unitType=1 valueType=1 value=500000 x=400 y=400 
// clipName=테스트111 unitType=2 bCritical=1 valueType=1 value=500000 x=400 y=400 
// clipName=테스트111 unitType=2 bCritical=0 valueType=1 value=500000 x=400 y=400  
// clipName=테스트111 unitType=2 bImmune bCritical=0 value=500000 x=400 y=400  
//

function OnEvent(int Event_ID, string param)
{		
	local string clipName;

	local int    unitType;	
	local int    xLoc, yLoc;

	local int    valueType, value, bCritical, bOverHit, 
				 bMagicDefense, bShieldDefense, bMiss, bContinuousAttack, bImmune, bSkillHit;

	local array<GFxValue> args;

	local GFxValue invokeResult;

	//  고유 npc 또는 캐릭터 아이디
	local int nID;
	
	// debug("ConsecutiveAttack: " @ EDamageTextType.ConsecutiveAttack);

	// 현재 해상도를 얻는다.
	GetCurrentResolution (currentScreenWidth, currentScreenHeight);	

	// 데미지 텍스트 생성
	if ( Event_ID == EV_DamageTextCreate)
	{	
		// Debug(" 시스템 메세지 EV DamageText" @ Event_ID);
		// Debug(" Param : " @ param);

		ShowWindow();		
		
		// 해당 텍스트의 인스턴스 네임 
		// ParseString(param, "clipName"   , clipName);
		ParseInt(param, "clipName"   , nID);
		clipName = string(nID);


		//1 pc, 2 npc(target), 3 pet	// 해결
		ParseInt(param, "unitType"   , unitType);

		ParseInt(param, "valueType"        , valueType);
		ParseInt(param, "value"            , value);
		ParseInt(param, "bCritical"        , bCritical);
		ParseInt(param, "bOverHit"         , bOverHit);
		ParseInt(param, "bMagicDefense"    , bMagicDefense);
		ParseInt(param, "bShieldDefense"   , bShieldDefense);
		ParseInt(param, "bMiss"            , bMiss);
		ParseInt(param, "bContinuousAttack", bContinuousAttack);
		
		// 면역 
		ParseInt(param, "bImmune"          , bImmune);

		// 스킬히트 (한번의 데미지를 받지만.. 연속적으로 다다다다닥 때릴때 각 타격때 마다 hit가 뜨도록 하는것)
		ParseInt(param, "bSkillHit", bSkillHit);


		// 발생 시킬 x, y 좌표
		ParseInt(param, "x"         , xLoc);
		ParseInt(param, "y"         , yLoc);

		// 조건에 따라 뎀텍 출력 
		conditionalDamageText(clipName, unitType, xLoc, yLoc, 
							  valueType, value, bCritical, bOverHit, bMagicDefense, bShieldDefense, bMiss, bContinuousAttack, bImmune, bSkillHit);

		// Debug("Damage Text param: " @ param);

	}
	else if  ( Event_ID == EV_DamageTextUpdate )	
	{
		// Debug(" 시스템 업데이트 EV DamageText" @ Event_ID);
		// Debug(" Param : " @ param);
		// case 2 : updateMotion(data.clipName, data.x, data.y); break; 
		ShowWindow();
		// 해당 데미지 텍스트의 인스턴스 네임, 3d상에서 뷰포인트를 이동 했을때 갱신 되는 x, y 좌표 업데이트를 위해..
		// 
		// ParseString(param, "clipName"   , clipName);
		ParseInt(param, "clipName"   , nID);
		
		clipName = string(nID);

		// 좌표 업데이트
		ParseInt(param, "x"  , xLoc);
		ParseInt(param, "y"  , yLoc);

		// 플래시 타입 데이타 인스턴스 생성
		AllocGFxValues(args, 2);		
		AllocGFxValue(invokeResult);

		// 데미지 텍스트 생성, 이벤트 번호 1번
		args[0].SetInt(2);
			
		CreateObject(args[1]);
					
		args[1].SetMemberString("clipName", clipName);

		// args[1].SetMemberInt    ("x", xLoc - ((currentScreenWidth - FLASH_WIDTH) / 2));
		// args[1].SetMemberInt    ("y", yLoc - ((currentScreenHeight - FLASH_HEIGHT) / 2));

		args[1].SetMemberInt    ("x", xLoc);
		args[1].SetMemberInt    ("y", yLoc);

		Invoke("_root.onEvent", args, invokeResult);

		DeallocGFxValue(invokeResult);
		DeallocGFxValues(args);
	}
}

/*
// 텍스트 타입 (리턴값)
// 표현 타입, 일반공격, 연쇄, 오버히트 같은..
// 1:일반 공격//해결, 2:연속 공격(도트 데미지), 3:크리티컬//해결, 4:오버히트, 5:HP회복, 6:MP회복
// 7:SP 얻음,   8:Exp 경험치 얻음, 9:마법 방어, 10:방패 방어// 해결, 11:회피, 12:면역, 13:스킬 히트
// 정보들을 바탕으로 어떤 타입의 텍스트를 보여 줄 것인지를 리턴한다.
*/
function makeDamageText(string clipName, int unitType, int textType, int xLoc, int yLoc, string messageStr)
{
	local array<GFxValue> args;
	local GFxValue invokeResult;

	if (textType != -1)
	{
		// 플래시 타입 데이타 인스턴스 생성
		AllocGFxValues(args, 2);		
		AllocGFxValue(invokeResult);

		// 데미지 텍스트 생성, 이벤트 번호 1번
		args[0].SetInt(1);
			
		CreateObject(args[1]);
					
		args[1].SetMemberString("clipName", clipName);
		args[1].SetMemberInt   ("unitType", unitType);
		args[1].SetMemberInt   ("textType", textType);

		args[1].SetMemberInt    ("x", xLoc);
		args[1].SetMemberInt    ("y", yLoc);

		args[1].SetMemberString("messageStr", messageStr);

		Invoke("_root.onEvent", args, invokeResult);

		DeallocGFxValue(invokeResult);
		DeallocGFxValues(args);
	}
}

// 조건에 따라 데미지 출력
//
// 표현 타입, 일반공격, 연쇄, 오버히트 같은..
// 1:일반 공격//해결, 2:연속 공격(도트 데미지), 3:크리티컬//해결, 4:오버히트, 5:HP회복, 6:MP회복
// 7:SP 얻음,   8:Exp 경험치 얻음, 9:마법 저항, 10:방패 방어// 해결, 11:회피, 12:면역
function conditionalDamageText(string clipName, int unitType, int xLoc, int yLoc, 
							   int valueType, int value, int bCritical, int bOverHit, int bMagicDefense, 
							   int bShieldDefense, int bMiss, int bContinuousAttack, int bImmune, int bSkillHit)
{
	local int damageTextType;

	damageTextType = -1;

	// ValueType  
	// 0:None, 아무것도 없음, 1:sp, 2:exp, 3:hp, 4:mp

	// hp , + 되면 회복, - 되면 공격 받음 
	if (valueType == 3)
	{		
		if (value >= 0)
		{
			// 회복 
			damageTextType = EDamageTextType.RecoverHP; // 5
		}
		else
		{
			// 일반 공격
			damageTextType = EDamageTextType.NormalAttack; // 1
		}	
		
		// 회복, 데미지 받음 뎀텍 출력
		if (value != 0) makeDamageText(clipName, unitType, damageTextType, xLoc, yLoc, string(value));
	}
	// mp 회복
	else if (valueType == 4)
	{
		damageTextType = EDamageTextType.RecoverMP; // 6;
	}
	// sp 얻음
	else if (valueType == 1)
	{
		damageTextType = EDamageTextType.GetSP; // 7
	}
	// exp 얻음
	else if (valueType == 2)
	{
		damageTextType = EDamageTextType.GetExp;  // 8			
	}

	// 0보다 큰 값이 들어 와야 템텍 출력, hp 관련 내용은 위에서 출력 했으니까 제외
	if (value > 0 && valueType != 3) makeDamageText(clipName, unitType, damageTextType, xLoc, yLoc, string(value) );


	// 개별 텍스트 처리

	// 연쇄공격
	if (bContinuousAttack == 1)
	{
		damageTextType = EDamageTextType.ConsecutiveAttack;
		makeDamageText(clipName, unitType, damageTextType, xLoc, yLoc, string(value) );
	}
	// 오버히트
	if (bOverHit == 1)
	{
		damageTextType = EDamageTextType.OverHit;
		makeDamageText(clipName, unitType, damageTextType, xLoc, yLoc, string(value) );
	}
	// 크리티컬
	if (bCritical == 1)
	{
		damageTextType = EDamageTextType.Critical;
		makeDamageText(clipName, unitType, damageTextType, xLoc, yLoc, string(value) );
	}
	// 마법 저항
	if (bMagicDefense == 1)
	{
		damageTextType = EDamageTextType.MagicDefiance; // 9;
		makeDamageText(clipName, unitType, damageTextType, xLoc, yLoc, string(value) );
	}
	// 방패 방어
	if (bShieldDefense == 1)
	{
		damageTextType = EDamageTextType.ShieldGuard; // 10;
		makeDamageText(clipName, unitType, damageTextType, xLoc, yLoc, string(value) );
	}
	// 회피
	if (bMiss == 1)
	{
		damageTextType = EDamageTextType.Dodge; // 11		
		makeDamageText(clipName, unitType, damageTextType, xLoc, yLoc, string(value) );
	}
	// 면역 
	if (bImmune == 1)
	{
		damageTextType = EDamageTextType.Immune; // 12
		makeDamageText(clipName, unitType, damageTextType, xLoc, yLoc, string(value) );
	}
	// 히트 (연속기 타격)
	if (bSkillHit != 0)
	{
		damageTextType = EDamageTextType.SkillHit; // 13
		makeDamageText(clipName, unitType, damageTextType, xLoc, yLoc, string(value) );
	}

}
defaultproperties
{
}
