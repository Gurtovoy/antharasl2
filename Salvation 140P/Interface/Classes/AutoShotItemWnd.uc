/**
 * 
 *   자동 숏컷 시스템 (상하이팀에서 데리고 와서, 스팀 버전을 위한 기능 변경 및 추가 버전)
 *   
 **/
class AutoShotItemWnd extends UICommonAPI;

const ITEM_ADD      =  1;
const ITEM_SET      =  2;
const ITEM_CLEAR    =  3;

const TIME_ID     = 30021;
const TIME_DELAY  = 5000;

var WindowHandle  Me;

var WindowHandle AutoShotItemSubWnd;

// 펫(펫, 컴페니언), 소환수, 0과 같거나 작으면 소환 안된 상태
var int PetID, SummonID;

//var WindowHandle  AutoShotNoticeWnd;
//var TextBoxHandle AutoShotNotice_TextBox;

var TextureHandle petIconTexture;

// 무기를 소유 했나?
var bool hasWeapon;

// 소환수, 펫, 컴페니언 활성화 여부
var bool bSummon, bPet, bBeforeSummon, bBeforePet;


// 탄이 없다고 메세지를 보여 줄 것인가?
// 알림을 보여줄 카운트 
var int showNoticeNum;

// 현재 선택된 윈도우 번호 플레이어1,2   ,팻 3,4
var int currentSelectSoulShotWndIndex;


var ItemInfo weaponItemInfo, beforeWeaponInfo;

var ShortcutWnd ShortcutWndScript;

struct slotData
{
	var bool    bNoticeShow;
	var string  toolTipStr;
};

// 각 4가지 슬롯의 상태를 기억 , PC정령탄1, PC마정탄2, 팻야수정령탄3, 팻야수마정탄4
var array<slotData> slotArray;

/**
 *  OnRegisterEvent
 **/ 
function OnRegisterEvent()
{
	RegisterEvent( EV_SoulShotUpdate );
	
	RegisterEvent( EV_BeginSoulShotUpdate );

	RegisterEvent( EV_AdenaInvenCount );

	RegisterEvent( EV_Restart );

	RegisterEvent( EV_ShortcutkeyassignChanged );

	RegisterEvent(EV_GameStart); //최초 접속 시 오는 이벤트로 교체 TT#73058
}

/**
 *  OnLoad
 **/ 
function OnLoad()
{
	Initialize();
}

/**
 *  Initialize
 **/
function Initialize()
{
	Me      = GetWindowHandle ( "AutoShotItemWnd" );

	AutoShotItemSubWnd = GetWindowHandle( "AutoShotItemWnd.AutoShotItemSubWnd" );
	ShortcutWndScript  = ShortcutWnd(GetScript("ShortcutWnd"));
	init();
}

function CustomTooltip SetTooltip(string Text)
{
	local CustomTooltip Tooltip;
	local DrawItemInfo info;
	
	Tooltip.MinimumWidth = 144;
	Tooltip.DrawList.Length = 1;
	
	info.eType = DIT_TEXT;
	info.t_color.R = 178;
	info.t_color.G = 190;
	info.t_color.B = 207;
	info.t_color.A = 255;
	info.t_strText = Text;
	Tooltip.DrawList[0] = info;

	return Tooltip;
}

/**
 * 데이타 초기화
 **/
function init()
{
	local int i;
	local ItemInfo tempInfo;

	slotArray.Length = 4;

	for (i = 1; i < 5; i++)
	{
		GetItemWindowHandle( "AutoShotItemWnd.AutoShotItemWnd_HorWnd.ShotItemSlot" $ i).Clear();
		GetItemWindowHandle( "AutoShotItemWnd.AutoShotItemWnd_VerWnd.ShotItemSlot" $ i).Clear();

		// 플레이어
		if (i == 1 || i == 2)
		{
			GetItemWindowHandle( "AutoShotItemWnd.AutoShotItemWnd_HorWnd.ShotItemSlot" $ i).SetTooltipText(GetSystemMessage(6828));
			GetItemWindowHandle( "AutoShotItemWnd.AutoShotItemWnd_VerWnd.ShotItemSlot" $ i).SetTooltipText(GetSystemMessage(6828));

		}
		// 펫 
		else
		{
			GetItemWindowHandle( "AutoShotItemWnd.AutoShotItemWnd_HorWnd.ShotItemSlot" $ i).SetTooltipText(GetSystemMessage(6829));
			GetItemWindowHandle( "AutoShotItemWnd.AutoShotItemWnd_VerWnd.ShotItemSlot" $ i).SetTooltipText(GetSystemMessage(6829));
		}

		slotArray[i - 1].bNoticeShow = false;
		slotArray[i - 1].toolTipStr = "";
	}

	PetID     = 0;
	SummonID  = 0;
	showNoticeNum = 0;

	hasWeapon = false;
	bBeforeSummon = false;
	bBeforePet    = false;

	beforeWeaponInfo = tempInfo;
	weaponItemInfo   = tempInfo;

	// 캐릭터 무기
	GetWindowHandle(getSlotPath(false, 1)).HideWindow();
	GetWindowHandle(getSlotPath(true , 1)).HideWindow();

	// 펫 
	GetWindowHandle(getSlotPath(false, 3)).HideWindow();
	GetWindowHandle(getSlotPath(true , 3)).HideWindow();

	// 보조창 숨기기
	HideWindow("AutoShotItemWnd.AutoShotItemSubWnd");	

	// 기본창 숨기기
	Me.HideWindow();

	Me.KillTimer(TIME_ID);

	//Debug("---------> 자동 정탄 초기화");

	// 혹시 있을 타이머 초기화
	//Me.KillTimer(TIME_ID);
	//checkSlotShowState();
	// 알림윈도우 텍스트 필드 초기화
	//AutoShotNotice_TextBox.SetText("");
	// 무기 장비 슬롯 초기화 
	//GetItemWindowHandle("AutoShotItemWnd.slot_weapon").Clear();
	// 펫,소환수 아이콘 초기화
	//petIconTexture.HideWindow();
	// 알림 부분 안보이게
	//AutoShotNoticeWnd.HideWindow();
	// 알림 배치 , 숏컷 위치에 따라 초기화
	// windowPositionAutoMove();
}

function onShow()   
{
	windowPositionAutoMove();
}

function OnDefaultPosition()
{
	windowPositionAutoMove();
	checkSlotShowState();
}

/** 고정 위치로 자동 이동 */
function windowPositionAutoMove()
{
	//Debug("GetGameStateName()" @ GetGameStateName());

	if (!IsUseAutoEquipSoulShot() || GetGameStateName() != "GAMINGSTATE") 
	{
		return;
	}

	//Debug("windowPositionAutoMove"@ GetGameStateName());

	GetWindowHandle("AutoShotItemWnd").ClearAnchor();
	
	// 다 숨겨 놓고..
	//GetWindowHandle("AutoShotItemWnd.AutoShotItemWnd_VerWnd").HideWindow();
	//GetWindowHandle("AutoShotItemWnd.AutoShotItemWnd_HorWnd").HideWindow();

	// 세로로 숏컷창이 배치 되어 있나?
	if (IsVertical())
	{
		GetWindowHandle("AutoShotItemWnd").SetAnchor("ShortcutWnd.ShortcutWndVertical" $ getShortcutIndexStr(), "TopLeft", "TopRight", -1, 17);
		
		//if (GetGameStateName() == "GAMINGSTATE") GetWindowHandle("AutoShotItemWnd.AutoShotItemWnd_VerWnd").ShowWindow();
	}
	else
	{
		GetWindowHandle("AutoShotItemWnd").SetAnchor("ShortcutWnd.ShortcutWndHorizontal" $ getShortcutIndexStr(), "TopLeft", "BottomLeft", 16, -1);		

		// if (GetGameStateName() == "GAMINGSTATE") GetWindowHandle("AutoShotItemWnd.AutoShotItemWnd_HorWnd").ShowWindow(); 
	}

	AutoShotItemSubWnd.HideWindow();
	//checkSlotShowState();
}

// 숏컷 확장 슬롯의 현재 상태에 따라 뒤에 붙는 최종 슬롯 수 string을 리턴
function string getShortcutIndexStr()
{
	local int nIndex;
	local string rValue;

	nIndex = ShortcutWndScript.getExpandNum();

	if (nIndex <= 0) rValue = "";
	else rValue = "_" $ nIndex;

	return rValue;
}
/**
 * OnEvent 
 **/
function OnEvent(int Event_ID, string param)
{	
	if ( getInstanceUIData().getIsArenaServer() ) return;

	// 클래식 서버만 사용하도록..
	//if ( !getInstanceUIData().getIsClassicServer() ) return;
	
	// Debug("--자동정탄-- " @ Event_ID);
	// Debug("--param    " @ param);	

	switch( Event_ID )
	{	
		case EV_GameStart           : checkSlotShowState(); windowPositionAutoMove(); break;
		case EV_BeginSoulShotUpdate : beginSoulShotUpdateHandle(param);  break;
	    case EV_SoulShotUpdate      : soulShotUpdateHandle(param);       break;

	    case EV_AdenaInvenCount     : updateSoulShotSelectWindow();      break;
		case EV_Restart             : init();                            break;
		case EV_ResolutionChanged   : windowPositionAutoMove(); Me.SetTimer(TIME_ID, TIME_DELAY);   break;

		case EV_ShortcutkeyassignChanged : windowPositionAutoMove();     break;
	}
}

/**
 *  정탄, 마정탄 정보 추가 시작!
 **/
function beginSoulShotUpdateHandle(string param)
{
	local int i;

	ParamToItemInfo(param, weaponItemInfo);

	// 알림을 보여줘야 하는 정탄, 마정탄의 수, 초기화
	showNoticeNum = 0;

	//Debug("-->"@ weaponItemInfo.ID.ClassID);
	//Debug("-> beginSoulShotUpdateHandle" @ param);

	// 무기 업데이트
	updateSlotWeapon(weaponItemInfo);

	for(i = 0; i < 4; i++)
	{
		slotArray[i].bNoticeShow = false;
		slotArray[i].toolTipStr = "";

		showTextureCounter(false, true, i + 1);
		showTextureCounter(false, false, i + 1);
	}
	
	windowPositionAutoMove();

	//checkSlotShowState();
}

// 무기나 팻 소환 상태에 따라 정탄 슬롯 윈도우를 보이게, 안보이게
function checkSlotShowState()
{
	//Debug("GetGameStateName()" @ GetGameStateName());
	if (!IsUseAutoEquipSoulShot() || GetGameStateName() != "GAMINGSTATE") 
	{
		return;
	}

	//	// 무기가 없다면 플레이어 정탄 슬롯 윈도우를 안보이게, 슬롯 번호에 1을 넣은 건, 1,2가 무기 정탄 슬롯
	//if (hasWeapon) 
	//{
	//	GetWindowHandle(getSlotPath(IsVertical(), 1)).ShowWindow();
	//}
	//else
	//{
	//	GetWindowHandle(getSlotPath(false, 1)).HideWindow();
	//	GetWindowHandle(getSlotPath(true , 1)).HideWindow();
	//	HideWindow("AutoShotItemWnd.AutoShotItemSubWnd");	
	//}
	// Debug("-->checkSlotShowState 다시 실행");

	if (IsUseAutoEquipSoulShot())
	{
		if(!Me.IsShowWindow()) Me.ShowWindow();
	}
	else
	{
		if(Me.IsShowWindow()) 
		{
			Me.HideWindow();
			return;
		}
	}

	//GetWindowHandle("AutoShotItemWnd.AutoShotItemWnd_VerWnd").HideWindow();
	//GetWindowHandle("AutoShotItemWnd.AutoShotItemWnd_HorWnd").HideWindow();

	//Debug("end -->checkSlotShowState");

	GetWindowHandle(getSlotPath(false, 1)).HideWindow();
	GetWindowHandle(getSlotPath(true , 1)).HideWindow();
	GetWindowHandle(getSlotPath(false, 3)).HideWindow();
	GetWindowHandle(getSlotPath(true , 3)).HideWindow();

	GetWindowHandle(getSlotPath(IsVertical(), 1)).ShowWindow();

	// 무기가 없으면 슬롯 초기화
	if (hasWeapon == false) 
	{
		showTextureCounter(false, true, 1);
		showTextureCounter(false, true, 2);
		//showTextureCounter(false, true, 3);
		//showTextureCounter(false, true, 4);

		showTextureCounter(false, false, 1);
		showTextureCounter(false, false, 2);
		//showTextureCounter(false, false, 3);
		//showTextureCounter(false, false, 4);

		HideWindow("AutoShotItemWnd.AutoShotItemSubWnd");	
	}

	// 소환수, 팻 둘 중 하나라도 있으면..
	if (bBeforeSummon || bBeforePet)
	{
		GetWindowHandle(getSlotPath(IsVertical(), 3)).ShowWindow();
		//if(IsVertical())
		//{
		//	showTextureCounter(true, true, 3);
		//	showTextureCounter(true, true, 4);
		//}
		//else
		//{
		//	showTextureCounter(true, false, 3);
		//	showTextureCounter(true, false, 4);
		//}
	}
	else
	{
		GetWindowHandle(getSlotPath(false, 3)).HideWindow();
		GetWindowHandle(getSlotPath(true , 3)).HideWindow();
		HideWindow("AutoShotItemWnd.AutoShotItemSubWnd");	
	}
}

/**
 *  정탄, 마정탄 정보 완료!
 **/
function endSoulShotUpdateHandle()
{
	local UserInfo a_UserInfo;

	if (showNoticeNum  > 0) GetPlayerInfo( a_UserInfo ); 

	bBeforeSummon = numToBool(class'UIDATA_PET'.static.GetSummonNum());
	bBeforePet    = class'UIDATA_PET'.static.IsHavePet();

	beforeWeaponInfo = weaponItemInfo;
}

/** 
 * soulShotUpdateHandle 
 * 
 * int type : 1.정령탄, 2.마법탄, 3.야수정령탄, 4.야수 마법탄 
 * int have : 0 없다,1 있다. 
 * int activate : 0 비활성화 1.활성화 
 * ItemInfo itemInfo : 아이템 정보. 
 *  
 **/
function soulShotUpdateHandle(string param)
{
	// 1~4번 슬롯 , 정령 마정탄을 소유 했나?
	local int nType, nHave;

	// 활성화 여부 (정령, 마정탄)
	local int nActivate;

	// String
	local string itemCountStr, toolTipStr, gradeName;
	local int nToolTipStringMessage;

	// 정령, 마정탄 정보, 착용한 무기정보
	local ItemInfo targetItemInfo, beforeTargetItemInfo;

	// 아이템 주변을 반짝이는 효과 보여 줄지 여부
	local bool bTwinkleEffect;

	// 아이템 ID 임시저장용
	local ItemID tempItemID;
	local string gradeString, effectPath;

	// local string meiYouEffectUIParam;

	//bShowNotice = false;

	ParseInt  (param, "type", nType);
	ParseInt  (param, "have", nHave);
	ParseInt  (param, "activate", nActivate);
	
	ParamToItemInfo(param, targetItemInfo);

	// debug("->" @ targetItemInfo.Name @ " " @ targetItemInfo.AdditionalName @ " " @ targetItemInfo.ItemNum);

	//Debug("----------AutoShotItemWnd-----------------------------");
	//Debug("nType"      @ nType);
	//Debug("have"       @ nHave);
	//Debug("nActivate"  @ nActivate);
	//Debug("ItemClassID"@ targetItemInfo.ID.ClassID);
	//Debug("무기착용여부 "@ hasWeapon);

	//Debug("-> "@ class'UIDATA_PET'.static.GetSummonNum());		
	//Debug("-> "@ class'UIDATA_PET'.static.IsHavePet());

	bSummon = numToBool(class'UIDATA_PET'.static.GetSummonNum());		
	bPet    = class'UIDATA_PET'.static.IsHavePet();

	//  아이템 윈도우에 추가
	if (nType > -1)
	{
		bTwinkleEffect = true;

		// 활성, 비활성 토글
		if(nActivate == 1 || nActivate == 3)
		{
			targetItemInfo.IsToggle = true;
		}
		else
		{
			targetItemInfo.IsToggle = false;
		}
		//targetItemInfo.IsToggle = (nActivate == 1 || nActivate == 3) ? true : false; //numToBool(nActivate);
		
		// 아이템 슬롯에 뭔가 있으면..
		if (getShotItemSlot(false, nType).GetItem(0, beforeTargetItemInfo))
		{
			// 새로 들어온 정보와 이전 아이템 정보의 ClassID 가 같다면..반짝이면 안된다.
			if (beforeTargetItemInfo.ID.ClassID == targetItemInfo.ID.ClassID)
			{
				if (targetItemInfo.ItemNum > 0) bTwinkleEffect = false;
			}
			else
			{
				// Debug("bTwinkleEffect" @ bTwinkleEffect);
				// 아이템 삭제
				//GetItemWindowHandle( "AutoShotItemWnd.ShotItemSlot" $ nType).Clear();
				setItemSlot(nType, ITEM_CLEAR);
			}			
		}
		else
		{
			if (targetItemInfo.ItemNum <= 0) bTwinkleEffect = false;
		}

		// 정령탄, 마정탄 없다면..
		if (nHave <= 0)
		{
			// pc
			if (nType == 1 || nType == 2)
			{
				if (hasWeapon)
				{
					// 8 == R , 9 = R95, 10 = R999
					if (weaponItemInfo.CrystalType >= 8)
					{						
						if (nType == 1) nToolTipStringMessage = 7388;
						else nToolTipStringMessage = 7389;
					}
					else
					{
						if (nType == 1) nToolTipStringMessage = 7384;
						else nToolTipStringMessage = 7386;
					}

					gradeString = getInstanceL2Util().getItemGradeSystemString(weaponItemInfo.CrystalType);

					// S80, S84 -> S,  R95, R99 -> R
					switch(gradeString)
					{
						case "S80" : 
						case "R84" : gradeString = GetSystemString(2617);  break;

						case "R95" : 
						case "R99" : gradeString = GetSystemString(2618); break;
					}

					//$s1그레이드 정령탄이 없습니다. 잡화 상점에서 구매하시기 바랍니다.
					toolTipStr = MakeFullSystemMsg(GetSystemMessage(nToolTipStringMessage), gradeString); 

					// bShowNotice = true;
					showNoticeNum++;
					if (beforeTargetItemInfo.ItemNum <= 0 && targetItemInfo.ItemNum <= 0) 
					{
						// 무기가 바뀐 시점이면. 알림을 보여준다.
						if (beforeWeaponInfo.ID.ClassID != weaponItemInfo.ID.ClassID)
						{
							slotArray[nType - 1].bNoticeShow = true;
						}
						else
						{
							slotArray[nType - 1].bNoticeShow = false;
						}
					}
					else slotArray[nType - 1].bNoticeShow = true;
					
					slotArray[nType - 1].toolTipStr = toolTipStr;

					//GetTextureHandle("AutoShotItemWnd.meiyou" $ nType).ShowWindow();
					//GetTextureHandle("AutoShotItemWnd.meiyou" $ nType).SetTooltipCustomType(MakeTooltipSimpleText(toolTipStr, 160));
				}
				else
				{
					//GetTextureHandle("AutoShotItemWnd.meiyou" $ nType).HideWindow();
					// 인벤토리 정탄 슬롯 초기화
					//GetItemWindowHandle( "InventoryWnd.ShotItem1").Clear();
					///GetItemWindowHandle( "InventoryWnd.ShotItem2").Clear();

				
				}
			}
			// 펫, 컴페니언, 소환수
			else if (nType == 3 || nType == 4)
			{
				// 아무거나 하나라도 존재 한다면..
				if (bSummon || bPet)
				{
					// 야수 정령탄, 마정탄 아이템 아이디
					if (nType == 3) tempItemID.ClassID = 20332;
					else tempItemID.ClassID = 20333;
					
					// 아이템 이름을 얻음(야수 마정탄, 야수 정령탄)
					gradeName = class'UIDATA_ITEM'.static.GetItemName(tempItemID);
					toolTipStr = MakeFullSystemMsg(GetSystemMessage(7385), gradeName); 

					//bShowNotice = true;
					if (beforeTargetItemInfo.ItemNum <= 0 && targetItemInfo.ItemNum <= 0)
					{
						if (bBeforeSummon == false && bBeforePet == false)
						{
							slotArray[nType - 1].bNoticeShow = true;
						}
						else
						{
							slotArray[nType - 1].bNoticeShow = false;
						}
					}
					else slotArray[nType - 1].bNoticeShow = true;
				

					slotArray[nType - 1].toolTipStr = toolTipStr;

					showNoticeNum++;
					//GetTextureHandle("AutoShotItemWnd.meiyou" $ nType).ShowWindow();
					//GetTextureHandle("AutoShotItemWnd.meiyou" $ nType).SetTooltipCustomType(MakeTooltipSimpleText (toolTipStr , 160 ));	
				}
				else
				{
					//GetTextureHandle("AutoShotItemWnd.meiyou" $ nType).HideWindow();
				}
			}
		}
		// 정령탄, 마정탄 가지고 있다면..
		else
		{
			//GetTextureHandle("AutoShotItemWnd.meiyou" $ nType).HideWindow();

			// pc
			if (nType == 1 || nType == 2)
			{
				if (hasWeapon)
				{
					if (targetItemInfo.ID.ClassID > 0) 
					{
						if (beforeTargetItemInfo.ID.ClassID == targetItemInfo.ID.ClassID)
						{
							setItemSlot(nType, ITEM_SET, targetItemInfo);
						}
						else
						{
							setItemSlot(nType, ITEM_ADD, targetItemInfo);
							
							// 새로 장착 될때 반짝 거리는 효과
							effectPath = "AutoShotItemWnd.EffectSlot" $ nType;
							if(IsVertical()) effectPath = effectPath $ "_ver_AniTex";
							else effectPath = effectPath $ "_hor_AniTex";
							GetAnimTextureHandle(effectPath).Stop();
							GetAnimTextureHandle(effectPath).Play();
						}						
					}
				}
				else
				{
					bTwinkleEffect = false;
				}
			}
			// 펫, 컴페니언, 소환수
			else if (nType == 3 || nType == 4)
			{
				// 아무거나 하나라도 존재 한다면..
				if (bSummon || bPet)
				{					
					if (targetItemInfo.ID.ClassID > 0) 
					{
						// 정탄 , 마정탄 변경 여부에 따라서..
						if (beforeTargetItemInfo.ID.ClassID == targetItemInfo.ID.ClassID)
						{
							setItemSlot(nType, ITEM_SET, targetItemInfo);
						}
						else
						{
							setItemSlot(nType, ITEM_ADD, targetItemInfo);

							// 새로 장착 될때 반짝 거리는 효과
							effectPath = "AutoShotItemWnd.EffectSlot" $ nType;
							if(IsVertical()) effectPath = effectPath $ "_ver_AniTex";
							else effectPath = effectPath $ "_hor_AniTex";
							GetAnimTextureHandle(effectPath).Stop();
							GetAnimTextureHandle(effectPath).Play();
						}							
					}
					else
					{
						setItemSlot(nType, ITEM_CLEAR);
					}
				}
				else
				{
					bTwinkleEffect = false;

					// 펫, 소환수가 없다면.. 값과 관계 없이 슬롯도 비운다.
					setItemSlot(nType, ITEM_CLEAR);
				}
			}
		}

		// 99개 이상 인 경우 경우와 이하인 경우의 수량 표기
		if (GetItemWindowHandle( "AutoShotItemWnd.ShotItemSlot" $ nType).GetItemNum() > 0)
		{
			if (targetItemInfo.ItemNum > 99) 
			{
				itemCountStr = "99+";
			}
			else
			{
				itemCountStr = String(targetItemInfo.ItemNum);
			}
		}
	}
	
	endSoulShotUpdateHandle();

	checkSlotShowState();
}

/**
 * 인벤토리, 정탄, 마정탄 슬롯에 추가, 삭제, 갱신
 * ITEM_ADD, ITEM_SET, ITEM_CLEAR
 **/
function setItemSlot(int nType, int nItemCommand, optional ItemInfo info)
{
	if (nItemCommand == ITEM_ADD)
	{		
		getShotItemSlot(false, nType).AddItem(info);
		getShotItemSlot(true, nType).AddItem(info);
		
		setTextureCounter( true, nType, info.ItemNum);
		setTextureCounter(false, nType, info.ItemNum);

		if (info.ItemNum <= 0) 
		{
			showTextureCounter(false, true, nType);
			showTextureCounter(false, false, nType);
		}
	}
	else if (nItemCommand == ITEM_SET)
	{
		getShotItemSlot(false, nType).SetItem(0, info);
		getShotItemSlot(true, nType).SetItem(0, info);

		setTextureCounter(true , nType, info.ItemNum);
		setTextureCounter(false, nType, info.ItemNum);

		if (info.ItemNum <= 0) 
		{
			showTextureCounter(false, true, nType);
			showTextureCounter(false, false, nType);
		}
	}
	else if (nItemCommand == ITEM_CLEAR)
	{
		getShotItemSlot(true , nType).Clear();
		getShotItemSlot(false, nType).Clear();

		showTextureCounter(false, false, nType);
		showTextureCounter(false, true, nType);
	}
}

/**
 * 
 * OnTimer
 * 
 **/
function OnTimer(int timerID)
{
	// 해상도 조절이 후 문제가 생긴다고 해서 이벤트 오는 타이밍이 문제일 확율이 
	// 높아 보여서 타이머로 보정 처리를 하도록 추가 했다.
	if (timerID == TIME_ID)
	{
		windowPositionAutoMove();		
		Me.KillTimer(TIME_ID);		
	}	
}

/** 무기 갱신 */
function updateSlotWeapon(itemInfo info)
{ 
	weaponItemInfo = info;
	// Debug("무기 info" @ info.ID.ClassID);
	if (info.ID.ClassID > 0) hasWeapon = true;
	else hasWeapon = false;
}

//function OnSetFocus(WindowHandle handle, bool bFocused)
//{
//	if (handle == none) { Debug("------> None"); return; }

//	if (handle.GetWindowName() == "") return;

//	Debug("OnSetFocus :" @ handle.GetParentWindowName());
//	Debug("OnSetFocus :" @ handle.GetWindowName());
//	Debug("bFocused: " @ bFocused);

//	if(handle.GetWindowName() == "AutoShotItemSubWnd" && bFocused == false)
//	{
//		Debug("닫아");
//		HideWindow("AutoShotItemWnd.AutoShotItemSubWnd");	
//	}

//	//if (handle.GetWindowName() == "AutoShotItemSubWnd")
//	//{
//	//	if(bFocused == false) handle.HideWindow();
//	//}

//	//HideWindow("AutoShotItemWnd.AutoShotItemSubWnd");
//}

function OnClickItem( string strID, int index )
{	
	local ItemInfo infItem, selectItemInfo;
	local array<ItemInfo> itemInfoArray;
	local int i, wndIndex;

	// Debug("strID" @ strID);
	// 정탄 슬롯 1~4 중 하나 클릭
	if (Left(strID, 12)  == "ShotItemSlot")
	{
		// Debug("mm: " @ int(Right(strID, 1)));

		wndIndex = int(Right(strID, 1));

		// clickShotcutItem(a_WindowHandle, X, Y);
		// Debug("정탄 슬롯 index" @ wndIndex);
		
		// 방금 열었던 슬롯을 또 클릭 했다면 닫는다.
		if (currentSelectSoulShotWndIndex == wndIndex && IsShowWindow("AutoShotItemWnd.AutoShotItemSubWnd")) 
		{
			currentSelectSoulShotWndIndex = -1;
			HideWindow("AutoShotItemWnd.AutoShotItemSubWnd");
			return;
		}

		//ShotItemSlot1~4
		currentSelectSoulShotWndIndex = wndIndex;
		
		// 1~4 인 경우만 창을 연다.
		if (currentSelectSoulShotWndIndex > 0 && currentSelectSoulShotWndIndex < 5)
		{
			GetAutoEquipShotList(currentSelectSoulShotWndIndex, itemInfoArray);
			//toggleWindow("AutoShotItemWnd.AutoShotItemSubWnd", true);
			ShowWindowWithFocus("AutoShotItemWnd.AutoShotItemSubWnd");

			// 세로
			if (IsVertical())
			{
				GetWindowHandle("AutoShotItemWnd.AutoShotItemSubWnd.ArrowHor_Texture_SubWnd").HideWindow();
				GetWindowHandle("AutoShotItemWnd.AutoShotItemSubWnd.ArrowVer_Texture_SubWnd").ShowWindow();
				GetWindowHandle("AutoShotItemWnd.AutoShotItemSubWnd").SetAnchor(getSlotPath(IsVertical(), wndIndex) $ ".ShotItemSlot" $ wndIndex, "TopRight", "TopLeft", -135, 0);
			}
			// 가로 
			else
			{
				GetWindowHandle("AutoShotItemWnd.AutoShotItemSubWnd.ArrowHor_Texture_SubWnd").ShowWindow();
				GetWindowHandle("AutoShotItemWnd.AutoShotItemSubWnd.ArrowVer_Texture_SubWnd").HideWindow();
				GetWindowHandle("AutoShotItemWnd.AutoShotItemSubWnd").SetAnchor(getSlotPath(IsVertical(), wndIndex) $ ".ShotItemSlot" $ wndIndex, "TopLeft", "TopLeft", -62, -95);
			}
		}
		else
		{
			currentSelectSoulShotWndIndex = -1;
			HideWindow("AutoShotItemWnd.AutoShotItemSubWnd");
		}

		// Debug("itemInfoArray Len : " @ itemInfoArray.Length);

		if (itemInfoArray.Length > 0)
		{
			// 현재 슬롯에 꼽혀 있는 정탄 아이템 정보 얻기
			if(getShotItemSlot(false, wndIndex).GetItemNum() > 0)
				getShotItemSlot(false, wndIndex).GetItem(0, infItem);
				

			GetItemWindowHandle("AutoShotItemWnd.AutoShotItemSubWnd.AutoShotItem_ItemWnd_SubWnd").Clear();
			for (i = 0; i < itemInfoArray.Length; i++)
			{
				// 현재 정탄 슬롯에 꼽혀 있는 것이 아닌 경우 목록에 넣는다.
				if (infItem.Id.ClassId != itemInfoArray[i].Id.ClassID)
					GetItemWindowHandle("AutoShotItemWnd.AutoShotItemSubWnd.AutoShotItem_ItemWnd_SubWnd").AddItem(itemInfoArray[i]);
			}
		}
	}
	// 정탄 선택 아이템 윈도우 클릭
	else if(strID == "AutoShotItem_ItemWnd_SubWnd")
	{
		// Debug("getShotItemSlot(false, wndIndex).GetItemNum()" @ getShotItemSlot(false, currentSelectSoulShotWndIndex).GetItemNum());

		GetItemWindowHandle("AutoShotItemWnd.AutoShotItemSubWnd.AutoShotItem_ItemWnd_SubWnd").GetItem(index, selectItemInfo);

		if (selectItemInfo.ID.ClassID > 0 && currentSelectSoulShotWndIndex != -1) 
		{
			// Debug("슬롯 " @ currentSelectSoulShotWndIndex);
			// Debug("정탄 장착 ClassID " @ infItem.ID.ClassID);
			SoulShotSlotSelected(currentSelectSoulShotWndIndex, selectItemInfo.ID.ClassID);  
			HideWindow("AutoShotItemWnd.AutoShotItemSubWnd");
		}
	}		
}


///** 클릭 */
//function OnLButtonUp( WindowHandle a_WindowHandle, int X, int Y )
//{
//	local array<ItemInfo> itemInfoArray;
//	local int i;

//	// clickShotcutItem(a_WindowHandle, X, Y);
//	Debug("무기 선택 윈도우 열기 닫기" @ a_WindowHandle.GetWindowName());
	
//	//ShotItemSlot1~4
//	currentSelectSoulShotWndIndex = -1;

//	switch(a_WindowHandle.GetWindowName())
//	{
//		case "ShotItemSlot1" : currentSelectSoulShotWndIndex = 1; GetAutoEquipShotList(1, itemInfoArray); Debug("1"); break;
//		case "ShotItemSlot2" : currentSelectSoulShotWndIndex = 2; GetAutoEquipShotList(2, itemInfoArray); Debug("2"); break;
//		case "ShotItemSlot3" : currentSelectSoulShotWndIndex = 3; GetAutoEquipShotList(3, itemInfoArray); Debug("3"); break;
//		case "ShotItemSlot4" : currentSelectSoulShotWndIndex = 4; GetAutoEquipShotList(4, itemInfoArray); Debug("4"); break;
//	}

//	// 1~4 인 경우만 창을 연다.
//	if (currentSelectSoulShotWndIndex > 0 && currentSelectSoulShotWndIndex < 5)
//	{
//		//toggleWindow("AutoShotItemWnd.AutoShotItemSubWnd", true);
//		ShowWindowWithFocus("AutoShotItemWnd.AutoShotItemSubWnd");
//	}
//	else
//	{
//		HideWindow("AutoShotItemWnd.AutoShotItemSubWnd");
//	}

//	Debug("itemInfoArray Len : " @ itemInfoArray.Length);

//	if (itemInfoArray.Length > 0)
//	{
//		GetItemWindowHandle("AutoShotItemWnd.AutoShotItemSubWnd.AutoShotItem_ItemWnd_SubWnd").Clear();
//		for (i = 0; i < itemInfoArray.Length; i++)
//		{
//			GetItemWindowHandle("AutoShotItemWnd.AutoShotItemSubWnd.AutoShotItem_ItemWnd_SubWnd").AddItem(itemInfoArray[i]);
//		}
//	}
//}

// 정탄, 마정탄등이 사용되거나 변경되는 수량이 때라 정탄 선택 창이 열려 있을때 업데이트 되도록 한다.
function updateSoulShotSelectWindow()
{
	local array<ItemInfo> itemInfoArray;
	local int i;
	local ItemInfo infItem;

	if(IsShowWindow("AutoShotItemWnd.AutoShotItemSubWnd"))
	{
		if (currentSelectSoulShotWndIndex > 0 && currentSelectSoulShotWndIndex < 5)
		{
			GetAutoEquipShotList(currentSelectSoulShotWndIndex, itemInfoArray);

			// 현재 슬롯에 꼽혀 있는 정탄 아이템 정보 얻기
			if(getShotItemSlot(false, currentSelectSoulShotWndIndex).GetItemNum() > 0)
				getShotItemSlot(false, currentSelectSoulShotWndIndex).GetItem(0, infItem);
		}
	}
	
	//ShotItemSlot1~4
	switch(currentSelectSoulShotWndIndex)
	{
		case 1 : GetAutoEquipShotList(1, itemInfoArray); break;
		case 2 : GetAutoEquipShotList(2, itemInfoArray); break;
		case 3 : GetAutoEquipShotList(3, itemInfoArray); break;
		case 4 : GetAutoEquipShotList(4, itemInfoArray); break;
	}

	// Debug("itemInfoArray Len : " @ itemInfoArray.Length);

	if (itemInfoArray.Length > 0)
	{
		GetItemWindowHandle("AutoShotItemWnd.AutoShotItemSubWnd.AutoShotItem_ItemWnd_SubWnd").Clear();
		for (i = 0; i < itemInfoArray.Length; i++)
		{
			// 현재 정탄 슬롯에 꼽혀 있는 것이 아닌 경우 목록에 넣는다.
			if (infItem.Id.ClassId != itemInfoArray[i].Id.ClassID)
				GetItemWindowHandle("AutoShotItemWnd.AutoShotItemSubWnd.AutoShotItem_ItemWnd_SubWnd").AddItem(itemInfoArray[i]);
		}
	}
}


function OnRButtonUp( WindowHandle a_WindowHandle, int X, int Y )
{
	clickShotcutItem(a_WindowHandle, X, Y);
}

/**
 *  정령탄, 마정탄 활성화, 비활성 처리
 **/
function clickShotcutItem( WindowHandle a_WindowHandle, int X, int Y )
{
	local string targetStr, targetID;
	local itemInfo targetItemInfo;

	targetStr = a_WindowHandle.GetWindowName();
	targetID = Mid(targetStr, len(targetStr) -1, len(targetStr));

	switch (targetID)
	{
		case "1" : 
		case "2" : 
		case "3" : 
		case "4" : if(GetItemWindowHandle( "AutoShotItemWnd.ShotItemSlot" $ targetID).GetItem(0, targetItemInfo)) 
				   {
					  SoulShotSlotClicked(int(targetID), targetItemInfo.ID.ClassID);  
					  //Me.SetFocus();
				   }				   
				   break;
	}
}

// 정탄 아이템 윈도우 얻기
function ItemWindowHandle getShotItemSlot(bool IsShortcutWndVertical, int slotIndex)
{
	local ItemWindowHandle itemWnd;

	// 1,2 
	if(IsShortcutWndVertical)
	{
		// 펫
		if (slotIndex > 2)
		{
			itemWnd = GetItemWindowHandle( "AutoShotItemWnd.AutoShotItemWnd_VerWnd.PetSlotGroupWnd_VerWnd.ShotItemSlot" $ slotIndex);
		}
		// 무기 (플레이어)
		else
		{
			itemWnd = GetItemWindowHandle( "AutoShotItemWnd.AutoShotItemWnd_VerWnd.WeaponSlotGroupWnd_VerWnd.ShotItemSlot" $ slotIndex);
		}
	}
	else
	{
		// 펫
		if (slotIndex > 2)
		{
			itemWnd = GetItemWindowHandle( "AutoShotItemWnd.AutoShotItemWnd_HorWnd.PetSlotGroupWnd_HorWnd.ShotItemSlot" $ slotIndex);
		}
		// 무기 (플레이어)
		else
		{
			itemWnd = GetItemWindowHandle( "AutoShotItemWnd.AutoShotItemWnd_HorWnd.WeaponSlotGroupWnd_HorWnd.ShotItemSlot" $ slotIndex);
		}
	}

	return itemWnd;
}

// 정탄 수량 보여주는 텍스쳐 show, hide
function setTextureCounter(bool IsShortcutWndVertical, int slotIndex, INT64 count)
{
	local string tempStr, valueStr;

	if (count > 99) valueStr = "99+";
	else valueStr = String(count);

	showTextureCounter(false, IsShortcutWndVertical, slotIndex);

	tempStr = getSlotPath(IsShortcutWndVertical, slotIndex);

	switch(Len(valueStr))
	{
		// 99+
		case 3 : showTextureCounter(true, IsShortcutWndVertical, slotIndex);
				 GetTextureHandle(tempStr $ "." $ "counter100_slot" $ slotIndex $ "_texture").SetTexture("l2UI_CT1.AutoShotItemWnd.ItemCountNum_9");
				 GetTextureHandle(tempStr $ "." $ "counter10_slot" $ slotIndex $ "_texture").SetTexture("l2UI_CT1.AutoShotItemWnd.ItemCountNum_9");
				 GetTextureHandle(tempStr $ "." $ "counter1_slot" $ slotIndex $ "_texture").SetTexture("l2UI_CT1.AutoShotItemWnd.ItemCountNum_Plus");
				 break;

		// 10자리
		case 2 : GetTextureHandle(tempStr $ "." $ "counter10_slot" $ slotIndex $ "_texture").ShowWindow();
				 GetTextureHandle(tempStr $ "." $ "counter10_slot" $ slotIndex $ "_texture").SetTexture("l2UI_CT1.AutoShotItemWnd.ItemCountNum_" $ Left(valueStr, 1));

		// 1자리
		case 1 : GetTextureHandle(tempStr $ "." $ "counter1_slot" $ slotIndex $ "_texture").ShowWindow();
				 GetTextureHandle(tempStr $ "." $ "counter1_slot" $ slotIndex $ "_texture").SetTexture("l2UI_CT1.AutoShotItemWnd.ItemCountNum_" $ Right(valueStr, 1));
	}
}

// 정탄 수량 보여주는 텍스쳐 show, hide
function showTextureCounter(bool bShow, bool IsShortcutWndVertical, int slotIndex)
{
	local string tempStr;

	tempStr = getSlotPath(IsShortcutWndVertical, slotIndex);

	if (bShow)
	{
		GetTextureHandle(tempStr $ "." $ "counter1_slot" $ slotIndex $ "_texture").ShowWindow();
		GetTextureHandle(tempStr $ "." $ "counter10_slot" $ slotIndex $ "_texture").ShowWindow();
		GetTextureHandle(tempStr $ "." $ "counter100_slot" $ slotIndex $ "_texture").ShowWindow();
	}
	else
	{
		GetTextureHandle(tempStr $ "." $ "counter1_slot" $ slotIndex $ "_texture").HideWindow();
		GetTextureHandle(tempStr $ "." $ "counter10_slot" $ slotIndex $ "_texture").HideWindow();
		GetTextureHandle(tempStr $ "." $ "counter100_slot" $ slotIndex $ "_texture").HideWindow();
	}
}


// 정탄 슬롯 경로를 조합하여 스트링을 리턴
function string getSlotPath(bool IsShortcutWndVertical, int slotIndex)
{
	local string tempStr;

	tempStr = "AutoShotItemWnd";

	if(IsShortcutWndVertical)
	{
		tempStr = tempStr $ ".AutoShotItemWnd_VerWnd";

		if (slotIndex > 2)
			tempStr = tempStr $ ".PetSlotGroupWnd_VerWnd";
		else
			tempStr = tempStr $ ".WeaponSlotGroupWnd_VerWnd";
	}
	else
	{
		tempStr = tempStr $ ".AutoShotItemWnd_HorWnd";

		if (slotIndex > 2)
			tempStr = tempStr $ ".PetSlotGroupWnd_HorWnd";
		else
			tempStr = tempStr $ ".WeaponSlotGroupWnd_HorWnd";
	}

	return tempStr;
}

function bool IsVertical()
{
	return ShortcutWndScript.IsVertical();
}
defaultproperties
{
}
