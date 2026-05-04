/////////////////////////////////////////////////////
// 브로치 및 주얼 관련 인첸트 작업.
//		@author by y2jinc (2013. 9. 3)

class NewEnchantAPI extends UIEventManager
	native;

// 대상 아이템 대상 올리기.
native static function RequestPushOne(ItemID a_sTargetID);
native static function RequestPushTwo(ItemID a_sTargetID);

// 대상 아이템 내리기
native static function RequestRemoveOne(ItemID a_sTargetID);
native static function RequestRemoveTwo(ItemID a_sTargetID);

// 인첸트 시도
native static function RequestTryEnchant();

// 창 닫기 / 초기화 - 초기화시 해당 함수 부르고 초기화 하면 됨.
native static function RequestClose();

// #3210 합성 UI개선 - UI API / 이벤트 - y2jinc (2016. 3. 8)
// 합성 성공 후 계속하기 시도
// OneSlotItemServerID -  첫번째 올린 재료 아이템 서버 ID
// TwoSlotItemServerID -  두번째 올린 재료 아이템 서버 ID
//  성공 -  EV_ENCHANT_RETRY_TO_PUT_ITEMS_OK
//  실패 -  EV_ENCHANT_RETRY_TO_PUT_ITEMS_FAIL
native static function RequestEnchantRetryPutItems(int OneSlotItemServerID, int TwoSlotItemServerID );

// #3210 합성 UI개선 - UI API / 이벤트 - y2jinc (2016. 3. 8)
// 인벤토리에서 합성 가능 재료 아이템 리스트 얻기
// OneSlotItemClassID - 첫번째 올린 재료 아이템 (올리지 않은 상태에서는 -1 값 넣음)
// TwoSlotItemClassID - 두번째 올린 재료 아이템 (올리지 않은 상태에서는 -1 값 넣음)
// MaterialItems - 위의 재료 아이템 조건에 따른 재료 아이템 리스트
native static function int GetMaterialItemForEnchantFromInven(int OneSlotItemClassID, int TwoSlotItemClassID, out array<ItemInfo> MaterialItems);

// 장착 인벤토리에서 합성 가능 재료 아이템 리스트 얻기(상동)
native static function int GetMaterialItemForEnchantFromEquip(int OneSlotItemClassID, int TwoSlotItemClassID, out array<ItemInfo> MaterialItems);

// #3210 합성 UI개선 - UI API / 이벤트 - y2jinc (2016. 3. 8)
// 합성 성공 / 실패 시 결과 아이템 확인
//  - 서버에서 성공 / 실패시 결과 Item ClassID만 넘어오는데 합성 시도시 OneSlotItemClassID, TwoSlotItemClassID 를 이용해서 
//    ResultItemNum / FailResultItemNum 확인해서 개수 표시해준다. (개수를 직접 받을 수 도 있으나 서버에서 패킷량을 줄이기 위해서 해당 함수를 사용)
native static function bool GetResultItemForEnchant(int OneSlotItemClassID, int TwoSlotItemClassID, out int ResultItemClassID, out int ResultItemNum, out int FailResultItemClassID, out int FailResultItemNum);

// #3210 합성 UI개선 - UI API / 이벤트 - y2jinc (2016. 3. 8)	
// 합성 성공 /실패시 실패 이팩트 출력 하지 않아야 하는 경우를 확인
//	true 리턴 시 실패 이팩트 출력하지 않고 '합성으로 [아이템 이름], [수량]개를 얻었습니다.' 라는 문구 출력.
native static function bool IsNoFailResultEffectType(int OneSlotItemClassID, int TwoSlotItemClassID);
defaultproperties
{
}
