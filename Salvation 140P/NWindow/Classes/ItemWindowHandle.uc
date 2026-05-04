/**
*아이템윈도우 핸들에 대한 함수를 정의한다
*/
class ItemWindowHandle extends WindowHandle native;

/**
* 선택된 아이템의 번호(컨트롤에서의 위치번호)를 리턴한다

* @param
* void

* @return
* void

* @example
*var ItemWindowHandle i_handle; //윈도우 핸들 선언
*i_handle = GetItemWindowHandle("InventoryWnd.InventoryItem");
*debug(string(i_handle.GetSelectedNum())); //선택된 아이템의 번호를 출력한다
*/
native final function int GetSelectedNum();

/**
*아이템윈도우 컨트롤의 총 아이템슬롯수를 리턴한다.

* @param
* void

* @return
* void

* @example
*var ItemWindowHandle i_handle; //윈도우 핸들 선언
*i_handle = GetItemWindowHandle("InventoryWnd.InventoryItem");
*debug(string(i_handle.GetItemNum())); //아이템윈도우 컨트롤의 총슬롯 수를 출력한다(인벤의 경우 80이었다)
*/
native final function int GetItemNum();

/**
*아이템선택을 취소한다

* @param
* void

* @return
* void

* @example
*var ItemWindowHandle i_handle; //윈도우 핸들 선언
*i_handle = GetItemWindowHandle("InventoryWnd.InventoryItem");
*i_handle.ClearSelect(); //선택을 취소한다
*/
native final function ClearSelect();

/**
*아이템을 추가한다

* @param
* info : 추가할 아이템의 정보구조체

* @return
* void

* @example
*var ItemWindowHandle i_handle; //윈도우 핸들 선언
*var ItemInfo info;
*i_handle = GetItemWindowHandle("InventoryWnd.InventoryItem");
*i_handle.GetItem(0, info); //0번 아이템을 가져온다
*I_handle.AddItem(info); //0번아이템을 하나더 추가한다. 

*struct native constructive ItemInfo
*{
*	var ItemID Id;
*	var string Name;
*	var string AdditionalName;
*	var string IconName;
*	var string IconNameEx1;
*	var string IconNameEx2;
*	var string IconNameEx3;
*	var string IconNameEx4;
*	var string ForeTexture;
*	var string Description;
*	var string DragSrcName;
*	var string IconPanel;
*	var int DragSrcReserved;
*	var string MacroCommand;
*	var int ItemType;
*	var int ItemSubType;
*	var INT64 ItemNum;
*	var INT64 Price;
*	var int Level;
*	var int SlotBitType;
*	var int Weight;
*	var int MaterialType;
*	var int WeaponType;
*	var int PhysicalDamage;
*	var int MagicalDamage;
*	var int PhysicalDefense;
*	var int MagicalDefense;
*	var int ShieldDefense;
*	var int ShieldDefenseRate;
*	var int Durability; 
*	var int CrystalType;
*	var int RandomDamage;
*	var int Critical;
*	var int HitModify;
*	var int AttackSpeed;
*	var int MpConsume;
*	var int ArmorType;
*	var int AvoidModify;
*	var int Damaged;
*	var int Enchanted;
*	var int MpBonus;
*	var int SoulshotCount;
*	var int SpiritshotCount;
*	var int PopMsgNum;
*	var int BodyPart;
*	var int RefineryOp1;
*	var int RefineryOp2;
*	var int CurrentDurability;
*	var int CurrentPeriod;
*	// [칠월칠석, 방어구 각인] item enchant option - by jin 09/08/05
*	var int EnchantOption1;
*	var int EnchantOption2;
*	var int EnchantOption3;
*	//
*	var int Reserved;
*	var INT64 Reserved64;
*	var INT64 DefaultPrice;
*	var int ConsumeType;
*	var int Blessed;
*	var INT64 AllItemCount;
*	var int IconIndex;
*	var bool bEquipped;
*	var bool bRecipe;  
*	var bool bArrow; 
*	var bool bShowCount;
*	var bool bDisabled;
*	var bool bIsLock;
*	var int AttackAttributeType;		// 속성 - lancelot 2007. 4.27.
*	var int AttackAttributeValue;
*	var int DefenseAttributeValueFire;
*	var int DefenseAttributeValueWater;
*	var int DefenseAttributeValueWind;
*	var int DefenseAttributeValueEarth;
*	var int DefenseAttributeValueHoly;
* 	var int DefenseAttributeValueUnholy;
*	var int RelatedQuestID[MAX_RELATED_QUEST];
*};
*/
native final function AddItem(ItemInfo info);

native final function AddItemWithFaded(ItemInfo info);
/**
*아이템을 해당 인덱스에 추가한다.

* @param
* index : 인덱스
* info : 아이템의 정보 구조체

* @return
* void

* @example
*var ItemWindowHandle i_handle; //윈도우 핸들 선언
*var ItemInfo info;
*i_handle = GetItemWindowHandle("InventoryWnd.InventoryItem");
*i_handle.GetItem(0, info); //0번 아이템을 가져온다
*I_handle.SetItem(1, info); //0번아이템을 1번 슬롯에 하나더 추가한다. 
*/
native final function bool SetItem(int index, ItemInfo info);

/**
*해당 인덱스의 아이템을 지운다

* @param
* index : 인덱스
* info : 아이템의 정보 구조체

* @return
* void

* @example
*var ItemWindowHandle i_handle; //윈도우 핸들 선언
*var ItemInfo info;
*i_handle = GetItemWindowHandle("InventoryWnd.InventoryItem");
*i_handle.DeleteItem(0); // 0번 인덱스의 아이템을 지운다
*/
native final function DeleteItem(int index);

/**
*선택된 아이템의 정보를 가져온다

* @param
* info : 아이템의 정보를 담아올 구조체

* @return
* void

* @example
*var ItemWindowHandle i_handle; //윈도우 핸들 선언
*var ItemInfo info;
*i_handle = GetItemWindowHandle("InventoryWnd.InventoryItem");
*i_handle.GetSelectedItem(info); //info에 선택된 아이템의 정보가 넘어온다
*/
native final function bool GetSelectedItem(out ItemInfo info);

/**
*지정된 인덱스의 아이템의 정보를 가져온다

* @param
* index : 아이템 인덱스(좌상단부터 0번)
* info : 아이템의 정보를 담아올 구조체

* @return
* void

* @example
*var ItemWindowHandle i_handle; //윈도우 핸들 선언
*var ItemInfo info;
*i_handle = GetItemWindowHandle("InventoryWnd.InventoryItem");
*i_handle.GetItem(0,info); //info에 최좌상단의 아이템의 정보가 넘어온다
*/
native final function bool GetItem(int index, out ItemInfo info);

native final function GetItemIdLevel(int index, out int Id, out int level, out int sublevel);
native final function int GetItemSkillDisabled(int index);
native final function SetItemSkillDisabled(int index, int SkillDisabled);


/**
*아이템을 모두지운다

* @param
* void

* @return
* void

* @example
*var ItemWindowHandle i_handle; //윈도우 핸들 선언
*var ItemInfo info;
*i_handle = GetItemWindowHandle("InventoryWnd.InventoryItem");
*i_handle.Clear(); //모두지움
*/
native final function Clear();

/**
*아이템을 아이디를 통해 찾아 인덱스를 리턴한한다(없으면 -1)
*아이디(ItemID sdID)는 서버아이디와 클래스아이디로 이루어진 구조체(struct native constructive ItemID)인데 둘다 셋팅하면 둘다 일치하는 것을 찾고
*둘중 하나만 셋하고 나머지는 0으로 두면 그 하나만 같은것을 찾는다.

* @param
* scID : 아이디 구조체

* @return
* int : 아이템의 인덱스

* @example
*var ItemWindowHandle i_handle; //윈도우 핸들 선언
*var int index;
*var ItemID item_id;
*item_id.ServerID = 100; //모든아이템마다 고유한 아이디
*item_id.ClassID = 100; //같은이름의 아이템이 공유하는 아이디

*i_handle = GetItemWindowHandle("InventoryWnd.InventoryItem");
*index = i_handle.Finditem(item_id); //아이템을 아이디를 통해 찾는다. 인덱스를 리턴한다

*struct native constructive ItemID
*{
*	var int ClassID;
*	var int ServerID;
*};
*/
native final function int FindItem( ItemID scID );

/**
*아이템을 주어진 아이템정보와 비교해 같은것을 찾아 인덱스를 리턴한한다(없으면 -1)
*모든정보와 비교할듯한 이름이지만 사실 그렇지는 않다. 예제 가장밑의 코드를 참조하자
*정보(iteminfo)안에 존재하는 멤버중 아이디(ItemID Id)는 서버아이디와 클래스아이디로 이루어진 구조체인데 둘다 셋팅하면 둘다 일치하는 것을 찾고
*둘중 하나만 셋하고 나머지는 0으로 두면 그 하나만 같은것을 찾는다.
*개인상점에서 사용된바있다. 개인상점에서 물건을 구매하려 들때 자신이 가진 아이템만 활성화되는데 그때 사용한듯 하다

* @param
* info : 아이템정보

* @return
* int : 아이템의 인덱스

* @example
*var ItemWindowHandle i_handle; //윈도우 핸들 선언
*var int index;
*var ItemInfo info;
*i_handle = GetItemWindowHandle("InventoryWnd.InventoryItem");
*index = i_handle.FinditemWithAllProperty(info); //아이템을 정보를 통해 찾는다. 인덱스를 리턴한다

*struct native constructive ItemID
*{
*	var int ClassID;
*	var int ServerID;
*};

*struct native constructive ItemInfo
*{
*	var ItemID Id; 
*	var string Name;
*	var string AdditionalName;
*	var string IconName;
*	var string IconNameEx1;
*	var string IconNameEx2;
*	var string IconNameEx3;
*	var string IconNameEx4;
*	var string ForeTexture;
*	var string Description;
*	var string DragSrcName;
*	var string IconPanel;
*	var int DragSrcReserved;
*	var string MacroCommand;
*	var int ItemType;
*	var int ItemSubType;
*	var INT64 ItemNum;
*	var INT64 Price;
*	var int Level;
*	var int SlotBitType;
*	var int Weight;
*	var int MaterialType;
*	var int WeaponType;
*	var int PhysicalDamage;
*	var int MagicalDamage;
*	var int PhysicalDefense;
*	var int MagicalDefense;
*	var int ShieldDefense;
*	var int ShieldDefenseRate;
*	var int Durability; 
*	var int CrystalType;
*	var int RandomDamage;
*	var int Critical;
*	var int HitModify;
*	var int AttackSpeed;
*	var int MpConsume;
*	var int ArmorType;
*	var int AvoidModify;
*	var int Damaged;
*	var int Enchanted;
*	var int MpBonus;
*	var int SoulshotCount;
*	var int SpiritshotCount;
*	var int PopMsgNum;
*	var int BodyPart;
*	var int RefineryOp1;
*	var int RefineryOp2;
*	var int CurrentDurability;
*	var int CurrentPeriod;
*	// [칠월칠석, 방어구 각인] item enchant option - by jin 09/08/05
*	var int EnchantOption1;
*	var int EnchantOption2;
*	var int EnchantOption3;
*	//
*	var int Reserved;
*	var INT64 Reserved64;
*	var INT64 DefaultPrice;
*	var int ConsumeType;
*	var int Blessed;
*	var INT64 AllItemCount;
*	var int IconIndex;
*	var bool bEquipped;
*	var bool bRecipe;  
*	var bool bArrow; 
*	var bool bShowCount;
*	var bool bDisabled;
*	var bool bIsLock;
*	var int AttackAttributeType;		// 속성 - lancelot 2007. 4.27.
*	var int AttackAttributeValue;
*	var int DefenseAttributeValueFire;
*	var int DefenseAttributeValueWater;
*	var int DefenseAttributeValueWind;
*	var int DefenseAttributeValueEarth;
*	var int DefenseAttributeValueHoly;
* 	var int DefenseAttributeValueUnholy;
*	var int RelatedQuestID[MAX_RELATED_QUEST];
*};

*참고로 비교하는 부분의 코드는 다음과같다(이것은 서버아이디만 세팅한경우)
*if( pWnd->GetItem(i)->m_iServerID==itemInfo->Id.ServerID &&  pWnd->GetItem(i)->m_iEnchanted == itemInfo->Enchanted
*					&& pWnd->GetItem(i)->m_Attribute.AttackType == (SHORT)itemInfo->AttackAttributeType && pWnd->GetItem(i)->m_Attribute.AttackValue == (SHORT)itemInfo->AttackAttributeValue
*					&& pWnd->GetItem(i)->m_Attribute.DefenseValue[ATTRT_FIRE] == (SHORT)itemInfo->DefenseAttributeValueFire && pWnd->GetItem(i)->m_Attribute.DefenseValue[ATTRT_WATER] == (SHORT)itemInfo->DefenseAttributeValueWater
*					&& pWnd->GetItem(i)->m_Attribute.DefenseValue[ATTRT_WIND] == (SHORT)itemInfo->DefenseAttributeValueWind && pWnd->GetItem(i)->m_Attribute.DefenseValue[ATTRT_EARTH] == (SHORT)itemInfo->DefenseAttributeValueEarth
*					&& pWnd->GetItem(i)->m_Attribute.DefenseValue[ATTRT_HOLY] == (SHORT)itemInfo->DefenseAttributeValueHoly && pWnd->GetItem(i)->m_Attribute.DefenseValue[ATTRT_UNHOLY]== (SHORT)itemInfo->DefenseAttributeValueUnholy)
*/
native final function int FindItemWithAllProperty(ItemInfo info);

/**
*아이템을 m_iReserved라는 변수를 사용하여 찾는다(인덱스를 리턴한다)
*m_iReserved는 NCitem클래스(아이템을 나타내는 클래스)의 멤버로 다음과같이 설명되어있다
*INT  m_iReserved;  //when user (deposit, withdraw) item, temporary used for DB ID 
*즉, 창고에 맞기거나 되찾을때 아이템에 부여되는 지니게 되는 고유번호라 할수있겠다
*그러나 실제로 사용된 부분은 없다

* @param
* Reserved : 아이템이 지니게되는 일시적 DB아이디

* @return
* void

* @example
*var ItemWindowHandle i_handle; //윈도우 핸들 선언
*var int index;
*i_handle = GetItemWindowHandle("WarehouseWnd.TopList"); //개인창고의 핸들
*index = i_handle.FindItemWithReserved(125); //125번을 찾는다
*/
native final function int FindItemWithReserved(int Reserved);

/**
* 전체 아이템윈도우 컨트롤을 음영지게 한다.(혹은 취소한다)

* @param
* bOn : true면 음영, false 면 음영없음

* @return
* void

* @example
*var ItemWindowHandle i_handle; //윈도우 핸들 선언
*i_handle = GetItemWindowHandle("InventoryWnd.InventoryItem");
*i_handle.SetFaded(true);//음영지게한다
*/
native final function SetFaded( bool bOn );

/**
* 스크롤바를 보여주거나 없앤다

* @param
* bShow : true면 보여줌, false 면 안보여줌

* @return
* void

* @example
*var ItemWindowHandle i_handle; //윈도우 핸들 선언
*i_handle = GetItemWindowHandle("InventoryWnd.InventoryItem");
*i_handle.ShowScrollBar(true);//스크롤바를 보여준다 
*/
native final function ShowScrollBar(bool bShow);

/**
* 아이템 두개를 스왑(맞바꿈)한다

* @param
* index1 : 바뀔아이템1 인덱스
* index2 : 바뀔아이템2 인덱스

* @return
* void

* @example
*var ItemWindowHandle i_handle; //윈도우 핸들 선언
*i_handle = GetItemWindowHandle("InventoryWnd.InventoryItem");
*i_handle.SwapItems(0,1); //0번과 1번아이템을 스왑한다 
*/
native final function SwapItems(int index1, int index2);

/**
* 지정한 위치와 오프셋이 위치하는 곳의 아이템칸의 인덱스를 리턴한다.

* @param
* x : x위치 (윈도우에서의 위치가 아닌 전체화면의 좌표계이다)
* y : y위치
* offsetX : x방향 오프셋
* offsetY : y방향 오프셋

* @return
* int : 아이템칸의 인덱스

* @example
*var ItemWindowHandle i_handle; //윈도우 핸들 선언
*i_handle = GetItemWindowHandle("InventoryWnd.InventoryItem");
*debug(string(GetIndexAt(1000,10000,0,0))); // (1000,1000) + (0,0) 의위치의 인덱스를 출력한다.
*/
native final function int	GetIndexAt( int x, int y, int offsetX, int offsetY );

/**
* 지정한 위치와 오프셋이 위치하는 곳의 아이템칸의 인덱스를 리턴한다.

* @param
* x : x위치 (윈도우에서의 위치가 아닌 전체화면의 좌표계이다)
* y : y위치
* offsetX : x방향 오프셋
* offsetY : y방향 오프셋

* @return
* int : 아이템칸의 인덱스

* @example
*var ItemWindowHandle i_handle; //윈도우 핸들 선언
*i_handle = GetItemWindowHandle("InventoryWnd.InventoryItem");
*debug(string(GetIndexAt(1000,10000,0,0))); // (1000,1000) + (0,0) 의위치의 인덱스를 출력한다.
*/
native final function SetDisableTex( String a_DisableTex );

/**
* 아이템윈도우 컨트롤의 행을 변경한다.

* @param
* a_Row : 행수

* @return
* void

* @example
*var ItemWindowHandle i_handle; //윈도우 핸들 선언
*i_handle = GetItemWindowHandle("InventoryWnd.InventoryItem");
*i_handle.SetRow(1); //행을 1행으로 변경한다
*/
native final function SetRow( int a_Row );

/**
* 아이템윈도우 컨트롤의 열을 변경한다.

* @param
* a_Col : 열수

* @return
* void

* @example
*var ItemWindowHandle i_handle; //윈도우 핸들 선언
*i_handle = GetItemWindowHandle("InventoryWnd.InventoryItem");
*i_handle.SetCol(1); //열을 1열으로 변경한다
*/
native final function SetCol( int a_Col );

/**
* 기본아이템윈도우의 슬롯 이외에 추가적인 슬롯을 늘려준다
* 아이템윈도우컨트롤은 m_ExpandItemArray 이라는 것을 유지하는데 여기에 정보가 매달린다.
* m_ExpandItemArray의 멤버와 index를 비교하는데 그 멤버가 고정되어 있어서 index는 0만 가능하다.
* 무슨의도인지는 알수없지만 실제로 사용된 부분도 index가 0인 것밖에 없다.
* 게임상에서 추가인벤이 생기는 방식이 한가지뿐인가? 여튼 그런듯하다. 게임은 잘몰라서..

* @param
* index : 추가슬롯의 인덱스(0만 되더라)
* num : 인덱스당 늘어날 아이템 슬롯

* @return
* void

* @example
*var ItemWindowHandle i_handle; //윈도우 핸들 선언
*i_handle = GetItemWindowHandle("InventoryWnd.InventoryItem");
*i_handle.SetExpandItemNum(0,3); //3개의 추가슬롯을 생성. m_ExpandItemArray의 0번째 인덱스에 그 정보를 유지한다
*/
native final function SetExpandItemNum(int index, int num);

/**
*?????
*/
native final function SetItemUsability();

/**
* 아이템의 컨트롤내의 인덱스를 classID를 통해 찾는다(쓰인적없음)

* @param
* scID : 아이디정보

* @return
* int : 아이템의 인덱스

* @example
*var ItemWindowHandle i_handle; //윈도우 핸들 선언
*var int index;
*var ItemId id;
*id.ClassID = 1000;
*i_handle = GetItemWindowHandle("InventoryWnd.InventoryItem");
*index = i_handle.FindItemByClassID(id); //클래스id가 1000인 아이템의 컨트롤내의 인덱스를 찾는다

*struct native constructive ItemID
*{
*	var int ClassID;
*	var int ServerID;
*};
*/
native final function int FindItemByClassID(ItemID scID);

/**
* 아이템의 컨트롤을 만들때 xml에서 type을 sidebuttontype으로하면 prev next버튼이 있는 페이지를 travel할수있는 컨트롤이 생긴다
* 그때 전체 페이지수를 리턴한다. 즉 아이템이 100개인데 한번에 보여지는게 20이면 5가 리턴된다

* @param
* void 

* @return
* int : 총페이지수

* @example
*var ItemWindowHandle i_handle; //윈도우 핸들 선언
*var pagenum;
*i_handle = GetItemWindowHandle("PostWriteWnd.InventoryItem");
*pagenum = i_handle.GetSideTypePageNum(); //총 페이지수 리턴
*/
native final function int GetSideTypePageNum();

/**
* 아이템의 컨트롤을 만들때 xml에서 type을 sidebuttontype으로하면 prev next버튼이 있는 페이지를 travel할수있는 컨트롤이 생긴다
* 그때 현재 페이지 위치를 리턴한다.

* @param
* void 

* @return
* int : 현재페이지수

* @example
*var ItemWindowHandle i_handle; //윈도우 핸들 선언
*var pagenum;
*i_handle = GetItemWindowHandle("PostWriteWnd.InventoryItem");
*pagenum = i_handle.GetSideTypeCurPage(); //현재페이지 위치를 리턴
*/
native final function int GetSideTypeCurPage();

/**
* 아이템의 컨트롤을 만들때 xml에서 type을 sidebuttontype으로하면 prev next버튼이 있는 페이지를 travel할수있는 컨트롤이 생긴다
* 그때 prev버튼을 누른다

* @param
* void 

* @return
* int : 현재페이지수

* @example
*var ItemWindowHandle i_handle; //윈도우 핸들 선언
*i_handle = GetItemWindowHandle("PostWriteWnd.InventoryItem");
*i_handle.PushSideTypePrevBtn(); // 앞페이지로 이동
*/
native final function PushSideTypePrevBtn();

/**
* 아이템의 컨트롤을 만들때 xml에서 type을 sidebuttontype으로하면 prev next버튼이 있는 페이지를 travel할수있는 컨트롤이 생긴다
* 그때 next버튼을 누른다

* @param
* void 

* @return
* int : 현재페이지수

* @example
*var ItemWindowHandle i_handle; //윈도우 핸들 선언
*i_handle = GetItemWindowHandle("PostWriteWnd.InventoryItem");
*i_handle.PushSideTypeNextBtn(); // 뒷페이지로 이동
*/
native final function PushSideTypeNextBtn();

native final function SetSelectedNum(int idx);

native final function ResizeScrollBar();
	
native final function SetToggleEffect(int index, bool bToggle); //토글이펙트를 on/off
native final function SetIconIndex(int index, int IconIndex);   //아이콘의 모양을 여러개사용가능

native final function SetIconDrawType(EItemWindowIconDrawType drawType);
defaultproperties
{
}
