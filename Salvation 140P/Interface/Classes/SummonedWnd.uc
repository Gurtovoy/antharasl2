/************************************************************************************************************************
 * 
 * 다중 소환 컨트롤 윈도우 
 * 
 ************************************************************************************************************************/
class SummonedWnd extends UICommonAPI;

var WindowHandle Me;
var WindowHandle SummonedWnd_Status;
var TextBoxHandle txtLvHead;
var TextBoxHandle txtLvName;
var TextBoxHandle txtHeadFight;
var TextBoxHandle txtHeadPhysicalAttack;
var TextBoxHandle txtHeadPhysicalDefense;
var TextBoxHandle txtHeadHitRate;
var TextBoxHandle txtHeadPhysicalAvoid;
var TextBoxHandle txtHeadCriticalRate;
var TextBoxHandle txtHeadPhysicalAttackSpeed;
var TextBoxHandle txtHeadMovingSpeed;
var TextBoxHandle txtHeadSoulShot;
var TextBoxHandle txtHeadMagicalAttack;
var TextBoxHandle txtHeadMagicDefense;
var TextBoxHandle txtHeadMagicHit;
var TextBoxHandle txtHeadMagicAvoid;
var TextBoxHandle txtHeadMagicCritical;
var TextBoxHandle txtHeadMagicCastingSpeed;
var TextBoxHandle txtHeadSoulShotCosume1;
var TextBoxHandle txtHeadSoulShotCosume2;
var TextBoxHandle txtPhysicalAttack;
var TextBoxHandle txtPhysicalDefense;
var TextBoxHandle txtHitRate;
var TextBoxHandle txtPhysicalAvoid;
var TextBoxHandle txtCriticalRate;
var TextBoxHandle txtPhysicalAttackSpeed;
var TextBoxHandle txtMovingSpeed;
var TextBoxHandle txtMagicalAttack;
var TextBoxHandle txtMagicDefense;
var TextBoxHandle txtMagicHit;
var TextBoxHandle txtMagicAvoid;
var TextBoxHandle txtMagicCritical;
var TextBoxHandle txtMagicCastingSpeed;
var TextBoxHandle txtSoulShotCosume1;
var TextBoxHandle txtSoulShotCosume2;
var TextureHandle BackTex1;
var TextureHandle BackTex2;
var TextureHandle BackTex3;
var TextureHandle DividerLine;
var TextureHandle DividerLine2;
var TextureHandle SummonedFace;
var TextureHandle SummonedSlotOutline;
var WindowHandle SummonedWnd_Action;
var WindowHandle SummonedWnd_Action1;
var ItemWindowHandle SummonedActionWnd_Before;
var TextureHandle BackTexAction1_Before;

var WindowHandle SummonedWnd_Action2;
var TextBoxHandle txtHeadDirect;
var TextBoxHandle txtHeadPolicy;
var TextBoxHandle txtHeadSkill;
var ItemWindowHandle SummonedActionWnd;
var ItemWindowHandle SummonedActionWnd2;
var ItemWindowHandle SummonedActionWnd3;
var TextureHandle BackTexAction1;
var TextureHandle BackTexAction2;
var TextureHandle BackTexAction3;

var BarHandle barHP_1;
var BarHandle barHP_2;
var BarHandle barHP_3;
var BarHandle barHP_4;
var BarHandle barMP_1;
var BarHandle barMP_2;
var BarHandle barMP_3;
var BarHandle barMP_4;

var StatusBarHandle barSummonPoint;

var TextureHandle SummonedGroupBox1;
var TextureHandle SummonedGroupBox2;
var TextureHandle SummonedGroupBox3;
var TextureHandle SummonedGroupBox4;
var TextureHandle SummonedGroupBox5;
var TextureHandle SummonedSlotNone1;
var TextureHandle SummonedSlotNone2;
var TextureHandle SummonedSlotNone3;
var TextureHandle SummonedSlotNone4;
var TextureHandle SummonedSlotBlank1;
var TextureHandle SummonedSlotBlank2;
var TextureHandle SummonedSlotBlank3;
var TextureHandle SummonedSlotBlank4;
var TextureHandle SummonedFace1;
var TextureHandle SummonedFace2;
var TextureHandle SummonedFace3;
var TextureHandle SummonedFace4;
var TextureHandle SummonedSlotOutline1;
var TextureHandle SummonedSlotOutline2;
var TextureHandle SummonedSlotOutline3;
var TextureHandle SummonedSlotOutline4;

var ButtonHandle btnBar_1;
var ButtonHandle btnBar_2;
var ButtonHandle btnBar_3;
var ButtonHandle btnBar_4;
var TextBoxHandle txtHeadSummonPoint;
var TabHandle TabCtrl;
var TextureHandle TabLineTop;
var TextureHandle tabBg1;


//var int usedSummonPoint;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Struct 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 소환수 UI 각 슬롯별 정보 1~4
struct summonedSlot
{
	var string  name;      // 이름
	var int		serverID;  // 서버 아이디
	var int		classID;   // 클래스 ID (역활)
	var int		level;     // 레벨
};


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 관련 변수
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
var L2Util           util;

var int summonServerID;

// 4차 전직 상태인가?
var bool bAwakeStateFlag;

//소환수 최대 수
const summonMaxNum = 4;
const summonpintMinPoint = 2;

//선택 되어 있는 정보 번호.
var int selectedSlotIndex;

// 소환수 슬롯 1~4 정보 보관용
var summonedSlot summonedSlotArray[summonMaxNum];

var int currentSummonPolicy;//소환 몹의 공격 정책, 0:방어

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 초기화 관련 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function OnRegisterEvent()
{
	RegisterEvent( EV_UpdateSummonInfo );
	RegisterEvent( EV_SummonedWndShow );
	RegisterEvent( EV_SummonedStatusClose );
	
	RegisterEvent( EV_ActionListNew );
	RegisterEvent( EV_ActionSummonedCommonListStart );
	RegisterEvent( EV_ActionSummonedCommonList );

	RegisterEvent( EV_SummonedStatusRemainTime);//자꾸 1120 이벤트가 날라와서.....

	//RegisterEvent( EV_SummonedStatusSpelledList );
	
	RegisterEvent( EV_LanguageChanged );

	RegisterEvent( EV_BR_Die_EnableNPC );

	RegisterEvent( EV_Restart );

	RegisterEvent( EV_TargetUpdate );

	RegisterEvent( EV_ActionSummonedAllSkillListStart );

	RegisterEvent( EV_ActionSummonedAllSkillList );

	RegisterEvent( EV_SummonedDelete );

	RegisterEvent( EV_UpdateHP ); //hp 변경이 있을 경우 

	RegisterEvent( EV_UpdateMP ); //mp 변경이 있을 경우 

	
}

function OnEvent(int Event_ID, string param)
{
	local int serverID;
	local int CurrentHP;
	local int CurrentMP;
	local int slotIndex;
	
	if(DebugConditions(Event_ID)){
		//Debug("소환수 창 EventID: " @ Event_ID @  param);
//		Debug("param            : " @ param);
	}
	
	//if (Event_ID == EV_SummonedStatusSpelledList ){ // 1110. 버프 관련
	//	ParseInt( param, "ServerID", serverID );
		//Debug("EV_SummonedStatusSpelledList EventID" @ param);
		//Debug("serverID  -> " @ serverID);
		//if (serverID != 0)
		//{
		//	HandleSummonInfoUpdate(serverID);
		//}
	//}

	if (Event_ID == EV_TargetUpdate ){ //980
		HandleTargetUpdate();
	}
	else if (Event_ID == EV_BR_Die_EnableNPC) //ldw 9140 이로운게 죽었을 시. 
	{
		

	}else if (Event_ID == EV_ActionSummonedAllSkillListStart)  //ldw 1351 -> 개별 스킬 요청 시작 이벤트.
	{
		//Debug("EV_ActionSummonedAllSkillListStart P:" @ param);
	}

	else if (Event_ID == EV_ActionSummonedCommonListStart)//ldw 1340 공통 스킬시작 이벤트
	{
//		Debug("EV_ActionSummonedCommonListStart" @ param);
		// 전체 액션 등 아이템 윈도우 요소를 삭제한다.
		//ClearActionWnd();
	}
	else if (Event_ID == EV_ActionSummonedAllSkillList)  //ldw 1352 -> 소환몹 고유 스킬
	{
		//Debug("EV_ActionSummonedAllSkillList" @ param);
		HandleActionSummonedList(param);
	}
	else if (Event_ID == EV_ActionSummonedCommonList)//ldw 1350
	{
		//Debug("EV_ActionSummonedCommonList" @ param);
		HandleActionSummonedList(param);
	}
	else if (Event_ID == EV_UpdateSummonInfo )//ldw 251
	{
		//ttp60822 수정 정우균
		if(GetGameStateName()!="GAMINGSTATE")
			return;

		ParseInt( param, "ServerID", serverID );
		//Debug("EV_UpdateSummonInfo EventID" @ param);	
		if (serverID != 0)
		{
			HandleSummonInfoUpdate(serverID);		
		}
	}
	else if (Event_ID == EV_UpdateHP ) 
	{	
		ParseInt( param, "ServerID", serverID );
		ParseInt( param, "CurrentHP", CurrentHP );
		//Debug("EV_UpdateHP EventID" @ param);	
		if (serverID != 0)
		{
			slotIndex = GetIsSummonedSlotIndex( serverID ) ;//같은 슬롯이 있나 확인.
			if ( slotIndex == -1 ) return ;

			setStatusBarHP( slotIndex, CurrentHP, serverID);
			
		}
	}
	else if (Event_ID == EV_UpdateMP )
	{
		ParseInt( param, "ServerID", serverID );
		ParseInt( param, "CurrentMP", CurrentMP );
		//Debug("EV_UpdateMP EventID" @ param);
		if (serverID != 0)
		{
			slotIndex = GetIsSummonedSlotIndex( serverID ) ;//같은 슬롯이 있나 확인.
			if ( slotIndex == -1 ) return ;		

			setStatusBarMP( slotIndex, CurrentMP, serverID);
		}	
	}
	else if (Event_ID == EV_SummonedStatusRemainTime )//ldw 1120
	{
		//Debug("EV_SummonedStatusRemainTime"); 소환 시간
	}

	else if (Event_ID == EV_SummonedStatusClose ) //ldw 1131 소환해제
	{
		 HandleSummonedStatusClose();//창에서 뺌.
	}
	else if (Event_ID == EV_SummonedWndShow)//ldw 1090 소환수를 더블 클릭 했을 때, 이벤트 날라 옴.
	{
//		Debug("EV_SummonedWndShow");
		//ParseInt( param, "serverID", summonServerID );
		HandleSummonShow();
		
	}
	else if ( Event_ID == EV_LanguageChanged )
	{
		// HandleLanguageChanged();
	}
	else if( Event_ID == EV_ActionListNew )//ldw 1311 맨 처음 발생......파라메타 없음. 정보를 갱신 하기 전에 이벤트가 받아짐.
	{		
//		Debug("EV_ActionListNew EventID" @ param);	//param 없음.
	}
	else if (Event_ID == EV_Restart)
	{
		 reStart();
	}	
	else if (Event_ID == EV_SummonedDelete ){ //1132 시체 삭제 시
		HandleSummonedDelete(param);
	}
}

function OnLoad()
{
	local int i;

	SetClosingOnESC();

	if(CREATE_ON_DEMAND==0)
	{
		OnRegisterEvent();
	}

	// util 초기화 
	util = L2Util(GetScript("L2Util"));
	Initialize();

	//usedSummonPoint = 0;
	currentSummonPolicy = -1;

	for( i = 1 ; i <= summonMaxNum ; i ++ ) 
	{
		GetTextureHandle( "SummonedWnd.SummonedSlotOutline" $ i ).HideWindow();
		GetBarHandle( "SummonedWnd.barHP_" $ i ).HideWindow();
		GetBarHandle( "SummonedWnd.barMP_" $ i ).HideWindow();
	}

	txtHeadSoulShotCosume1.SetText(GetSystemString(404));// 404 정령탄 소모	
	txtHeadSoulShotCosume2.SetText(GetSystemString(496));// 496 마정탄 소모
}

function Initialize()
{
	Me = GetWindowHandle( "SummonedWnd" );
	SummonedWnd_Status = GetWindowHandle( "SummonedWnd.SummonedWnd_Status" );
	txtLvHead = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtLvHead" );
	txtLvName = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtLvName" );
	txtHeadFight = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtHeadFight" );
	txtHeadPhysicalAttack = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtHeadPhysicalAttack" );
	txtHeadPhysicalDefense = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtHeadPhysicalDefense" );
	txtHeadHitRate = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtHeadHitRate" );
	txtHeadPhysicalAvoid = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtHeadPhysicalAvoid" );
	txtHeadCriticalRate = GetTextBoxHandle( "SummonedWnd.1.txtHeadCriticalRate" );
	txtHeadPhysicalAttackSpeed = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtHeadPhysicalAttackSpeed" );
	txtHeadMovingSpeed = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtHeadMovingSpeed" );
	txtHeadSoulShot = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtHeadSoulShot" );
	txtHeadMagicalAttack = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtHeadMagicalAttack" );
	txtHeadMagicDefense = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtHeadMagicDefense" );
	txtHeadMagicHit = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtHeadMagicHit" );
	txtHeadMagicAvoid = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtHeadMagicAvoid" );
	txtHeadMagicCritical = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtHeadMagicCritical" );
	txtHeadMagicCastingSpeed = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtHeadMagicCastingSpeed" );
	txtHeadSoulShotCosume1 = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtHeadSoulShotCosume1" );
	txtHeadSoulShotCosume2 = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtHeadSoulShotCosume2" );
	txtPhysicalAttack = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtPhysicalAttack" );
	txtPhysicalDefense = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtPhysicalDefense" );
	txtHitRate = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtHitRate" );
	txtPhysicalAvoid = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtPhysicalAvoid" );
	txtCriticalRate = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtCriticalRate" );
	txtPhysicalAttackSpeed = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtPhysicalAttackSpeed" );
	txtMovingSpeed = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtMovingSpeed" );
	txtMagicalAttack = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtMagicalAttack" );
	txtMagicDefense = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtMagicDefense" );
	txtMagicHit = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtMagicHit" );
	txtMagicAvoid = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtMagicAvoid" );
	txtMagicCritical = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtMagicCritical" );
	txtMagicCastingSpeed = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtMagicCastingSpeed" );
	txtSoulShotCosume1 = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtSoulShotCosume1" );
	txtSoulShotCosume2 = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Status.txtSoulShotCosume2" );
	BackTex1 = GetTextureHandle( "SummonedWnd.SummonedWnd_Status.BackTex1" );
	BackTex2 = GetTextureHandle( "SummonedWnd.SummonedWnd_Status.BackTex2" );
	BackTex3 = GetTextureHandle( "SummonedWnd.SummonedWnd_Status.BackTex3" );
	DividerLine = GetTextureHandle( "SummonedWnd.SummonedWnd_Status.DividerLine" );
	DividerLine2 = GetTextureHandle( "SummonedWnd.SummonedWnd_Status.DividerLine2" );
	SummonedFace = GetTextureHandle( "SummonedWnd.SummonedWnd_Status.SummonedFace" );
	SummonedSlotOutline = GetTextureHandle( "SummonedWnd.SummonedWnd_Status.SummonedSlotOutline" );
	SummonedWnd_Action = GetWindowHandle( "SummonedWnd.SummonedWnd_Action" );
	SummonedWnd_Action1 = GetWindowHandle( "SummonedWnd.SummonedWnd_Action.SummonedWnd_Action1" );
	
	BackTexAction1_Before = GetTextureHandle( "SummonedWnd.SummonedWnd_Action.SummonedWnd_Action1.BackTexAction1_Before" );
	SummonedWnd_Action2 = GetWindowHandle( "SummonedWnd.SummonedWnd_Action.SummonedWnd_Action2" );
	txtHeadDirect = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Action.SummonedWnd_Action2.txtHeadDirect" );
	txtHeadPolicy = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Action.SummonedWnd_Action2.txtHeadPolicy" );
	txtHeadSkill = GetTextBoxHandle( "SummonedWnd.SummonedWnd_Action.SummonedWnd_Action2.txtHeadSkill" );

	SummonedActionWnd_Before = GetItemWindowHandle( "SummonedWnd.SummonedWnd_Action.SummonedWnd_Action1.SummonedActionWnd_Before" );
	SummonedActionWnd  = GetItemWindowHandle( "SummonedWnd.SummonedWnd_Action.SummonedWnd_Action2.SummonedActionWnd" );
	SummonedActionWnd2 = GetItemWindowHandle( "SummonedWnd.SummonedWnd_Action.SummonedWnd_Action2.SummonedActionWnd2" );
	SummonedActionWnd3 = GetItemWindowHandle( "SummonedWnd.SummonedWnd_Action.SummonedWnd_Action2.SummonedActionWnd3" );

	BackTexAction1 = GetTextureHandle( "SummonedWnd.SummonedWnd_Action.SummonedWnd_Action2.BackTexAction1" );
	BackTexAction2 = GetTextureHandle( "SummonedWnd.SummonedWnd_Action.SummonedWnd_Action2.BackTexAction2" );
	BackTexAction3 = GetTextureHandle( "SummonedWnd.SummonedWnd_Action.SummonedWnd_Action2.BackTexAction3" );
	barHP_1 = GetBarHandle( "SummonedWnd.barHP_1" );
	barHP_2 = GetBarHandle( "SummonedWnd.barHP_2" );
	barHP_3 = GetBarHandle( "SummonedWnd.barHP_3" );
	barHP_4 = GetBarHandle( "SummonedWnd.barHP_4" );
	barMP_1 = GetBarHandle( "SummonedWnd.barMP_1" );
	barMP_2 = GetBarHandle( "SummonedWnd.barMP_2" );
	barMP_3 = GetBarHandle( "SummonedWnd.barMP_3" );
	barMP_4 = GetBarHandle( "SummonedWnd.barMP_4" );	
	SummonedGroupBox1 = GetTextureHandle( "SummonedWnd.SummonedGroupBox1" );
	SummonedGroupBox2 = GetTextureHandle( "SummonedWnd.SummonedGroupBox2" );
	SummonedGroupBox3 = GetTextureHandle( "SummonedWnd.SummonedGroupBox3" );
	SummonedGroupBox4 = GetTextureHandle( "SummonedWnd.SummonedGroupBox4" );
	SummonedGroupBox5 = GetTextureHandle( "SummonedWnd.SummonedGroupBox5" );
	SummonedSlotNone1 = GetTextureHandle( "SummonedWnd.SummonedSlotNone1" );
	SummonedSlotNone2 = GetTextureHandle( "SummonedWnd.SummonedSlotNone2" );
	SummonedSlotNone3 = GetTextureHandle( "SummonedWnd.SummonedSlotNone3" );
	SummonedSlotNone4 = GetTextureHandle( "SummonedWnd.SummonedSlotNone4" );
	SummonedSlotBlank1 = GetTextureHandle( "SummonedWnd.SummonedSlotBlank1" );
	SummonedSlotBlank2 = GetTextureHandle( "SummonedWnd.SummonedSlotBlank2" );
	SummonedSlotBlank3 = GetTextureHandle( "SummonedWnd.SummonedSlotBlank3" );
	SummonedSlotBlank4 = GetTextureHandle( "SummonedWnd.SummonedSlotBlank4" );
	SummonedFace1 = GetTextureHandle( "SummonedWnd.SummonedFace1" );
	SummonedFace2 = GetTextureHandle( "SummonedWnd.SummonedFace2" );
	SummonedFace3 = GetTextureHandle( "SummonedWnd.SummonedFace3" );
	SummonedFace4 = GetTextureHandle( "SummonedWnd.SummonedFace4" );
	SummonedSlotOutline1 = GetTextureHandle( "SummonedWnd.SummonedSlotOutline1" );
	SummonedSlotOutline2 = GetTextureHandle( "SummonedWnd.SummonedSlotOutline2" );
	SummonedSlotOutline3 = GetTextureHandle( "SummonedWnd.SummonedSlotOutline3" );
	SummonedSlotOutline4 = GetTextureHandle( "SummonedWnd.SummonedSlotOutline4" );
	btnBar_1 = GetButtonHandle( "SummonedWnd.btnBar_1" );
	btnBar_2 = GetButtonHandle( "SummonedWnd.btnBar_2" );
	btnBar_3 = GetButtonHandle( "SummonedWnd.btnBar_3" );
	btnBar_4 = GetButtonHandle( "SummonedWnd.btnBar_4" );
	txtHeadSummonPoint = GetTextBoxHandle( "SummonedWnd.txtHeadSummonPoint" );
	TabCtrl = GetTabHandle( "SummonedWnd.TabCtrl" );
	TabLineTop = GetTextureHandle( "SummonedWnd.TabLineTop" );
	tabBg1 = GetTextureHandle( "SummonedWnd.tabBg1" );

	barSummonPoint = GetStatusBarHandle( "SummonedWnd.barSummonPoint" );
	//barSummonPoint = StatusBarHandle ( GetHandle( "SummonedWnd.barSummonPoint" ) );

	bAwakeStateFlag = false;
	initSlot();
}

/***
 * 소환수 상태 정보 슬롯을 초기화 한다.
 * 
 **/ 
function initSlot()
{
	local int i;
	for (i = 0; i < summonMaxNum; i++) 
	{   
		summonedSlotArray[i].serverID = -1;

		GetBarHandle( "SummonedWnd.barHP_" $ (i + 1)).SetValue(0, 0);
		GetBarHandle( "SummonedWnd.barMP_" $ (i + 1)).SetValue(0, 0);
		
		// 스킬 아이콘 텍스쳐를 얻어서 텍스쳐 적용 시키는 부분 넣어야함.
		// GetTextureHandle( "SummonedWnd.SummonedFace" $ (i + 1) ).SetTexture(..);

		// 툴팁			
		//GetButtonHandle( "SummonedWnd.btnBar_" $ (i + 1)).SetTooltipCustomType(setHpMpToolTips(MaxHP, HP, MaxMP, MP));
	}

	// 각 슬롯 초기화 코드 추가 해야함..
}


function OnShow()
{
	// 공통 액션 리스트를 요청 한다.
	// class'ActionAPI'.static.RequestSummonedCommonActionList(summonServerID);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 이벤트 -> 해당 이벤트 처리 핸들러
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


function Bool DebugConditions(int Event_ID){//ldw 디버그받고 싶지 않은 이벤트들
	local Array<int> conditoins;
	local int i;

	conditoins[0]=EV_SummonedStatusRemainTime;
	conditoins[1]=EV_ActionSummonedCommonList;

	for(i=0 ;i < conditoins.Length ; i++){		
		if(conditoins[i] == Event_ID){
			return false;
		}
	}
	return true;
}




function reStart(){
	local int i;
	for(i=0 ; i < summonMaxNum ; i++){
		summonedSlotArray[i].serverID = -1;	
	}
}

//액션클릭
function OnClickItem( string strID, int index )
{
	local ItemInfo infItem;
//	Debug ("OnClickItem:"$strID $ ", " $ index) ;
	if(index>-1){
		switch (strID){
		case "SummonedActionWnd_Before" :
			if (SummonedActionWnd_Before.GetItem(index, infItem))
				DoAction(infItem.ID);
			break;
		case "SummonedActionWnd" :
			if (SummonedActionWnd.GetItem(index, infItem))			
				DoAction(infItem.ID);
			break;
		case "SummonedActionWnd2" ://이건 토글임
			if (SummonedActionWnd2.GetItem(index, infItem)){
				Debug("index" @ index);
				Debug("currentSummonPolicy" @ currentSummonPolicy);

				//SummonedActionWnd2.SetToggle(index, true);
				//SummonedActionWnd2.SetToggle(currentSummonPolicy, false);
				if ( index != currentSummonPolicy ){
					SummonedActionWnd2.SetToggleEffect(index, true);
					SummonedActionWnd2.SetToggleEffect(currentSummonPolicy, false);

					currentSummonPolicy = index;
					DoAction(infItem.ID);	
				}

			}
			break;
		case "SummonedActionWnd3" :
			if (SummonedActionWnd3.GetItem(index, infItem))	
				DoAction(infItem.ID);
			break;
		}	
		
	}


//////////////////////////////////////////////////
	/*if (strID == "ActionBasicItem" && index>-1)
	{
		if (!class'UIAPI_ITEMWINDOW'.static.GetItem("ActionWnd.ActionBasicItem", index, infItem))
			return;

		class'UIAPI_ITEMWINDOW'.static.SetItem( "ActionWnd.ActionBasicItem", index, infItem );
	}
	else if (strID == "ActionPartyItem" && index>-1)
	{
		if (!class'UIAPI_ITEMWINDOW'.static.GetItem("ActionWnd.ActionPartyItem", index, infItem))
			return;
	}
	else if (strID == "ActionMarkItem" && index>-1)
	{
		if (!class'UIAPI_ITEMWINDOW'.static.GetItem("ActionWnd.ActionMarkItem", index, infItem))
			return;
	}
	else if (strID == "ActionSocialItem" && index>-1)
	{
		if (!class'UIAPI_ITEMWINDOW'.static.GetItem("ActionWnd.ActionSocialItem", index, infItem))
			return;
	}
	

	DoAction(infItem.ID);*/



}

/**
 * 소환수를 선택 할 때 -> 해당 소환수를 타겟으로 지정, 셋 인포.
 **/
function HandleTargetUpdate(){
	//local SummonInfo info;
	//GetSummonInfo(info);	
	local int serverID ;	
	serverID  = class'UIDATA_TARGET'.static.GetTargetID() ;
	if(GetIsSummonedSlotIndex(serverID)!=-1){
		setInformation(serverID);
		setbtnBarSelection(serverID);
	}
}


/**
 * UI 버튼을 눌렀을 때 -> 해당 소환수를 타겟으로 지정
 **/
function setTargetSummon (int num) // 타겟을 직접 선택 하는 것과 겹치는 듯.
{
	local UserInfo userinfo;
	local int serverID;

	serverID = summonedSlotArray[num].serverID;

	if (serverID != -1)
	{
		if (GetPlayerInfo(userinfo))
		{			
//			Debug("클릭 타겟====> "@summonedSlotArray[num].serverID);
			RequestAction(serverID, userinfo.Loc);//HandleTargetUpdate()로 이어짐			
			//setInformation(serverID);
			//setbtnBarSelection(serverID);
		}	
	} 
	//return userinfo.nID;
}

function HandleSummonedStatusClose(){
	local int usedSummonPoint;
	local int SummonablePoint;
	local int i;

	PlayConsoleSound(IFST_WINDOW_CLOSE);
	Me.HideWindow();
//	Debug("소환해제");	
	for(i = 0 ;i < summonMaxNum ; i++){
		deleteSlotbyIndex(i);
	}
	GetSummonPoint(usedSummonPoint, SummonablePoint);
	barSummonPoint.SetPoint(SummonablePoint-usedSummonPoint, SummonablePoint);
	ClearActionWnd();
	setInformation(-1);
	setbtnBarSelection(-1);
	currentSummonPolicy = -1;
}


/**
 *  소환수 창을 열어 준다. 1~3차 와 4차 이후의 윈도우 형태는 약간 다르다. 
 *  (가변적으로 속성을 조작하여 모양을 다르게 해준다)
 **/
function HandleSummonShow()
{
//	Debug("HandleSummonShow");
	// 사운드 
	PlayConsoleSound(IFST_WINDOW_OPEN);
	
	//class'ActionAPI'.static.RequestSummonedCommonActionList(summonServerID); // 새로 소환 했을 때. 요청 해야 함.  -> EV_ActionSummonedCommonList 호출	
	// 열고 , 포커스 잡기
	if ( !getInstanceUIData().getIsClassicServer() ) 
	{
		Me.ShowWindow();
		Me.SetFocus();
	}	
}

/**
 *  소환수 
 **/

function HandleSummonedDelete (string param){
	local int serverID;
	local int slotIndex;	
	local int nextSlotIndex;
	local int usedSummonPoint;
	local int SummonablePoint;	
	ParseInt(param, "serverID", serverID);
	if (bAwakeStateFlag){ // 4차 전직 이전은 소환해제로 해결 함. 4차 전직 이후는 3번 고유 스킬 내용을 삭제 한 뒤 다시 받음.
		slotIndex = GetIsSummonedSlotIndex( serverID ) ;//같은 슬롯이 있나 확인.
		
		nextSlotIndex = getNextSummonedSlotIndex(slotIndex);
		if( nextSlotIndex != -1 )// 아직  차 있는 슬롯이 있다면 해당 슬롯의 정보를 보여 줌. 소환 해제로 처리 됨
		{	
			SummonedActionWnd3.Clear();// 개별 액션을 지우고 다시 받아야 함.
			class'ActionAPI'.static.RequestSummonedAllSkillActionList();//->         개별 스킬 1351 이벤트 발생 -> 1352 이벤트 파라메타로 스킬이 들어옴. 소환수 개수가 달라 질 때 갱신			

			setInformation( summonedSlotArray[nextSlotIndex].serverID);// 다음 슬롯의 정보가 보임
			setbtnBarSelection( summonedSlotArray[nextSlotIndex].serverID );//다음 슬롯을 셀렉션

			GetSummonPoint(usedSummonPoint, SummonablePoint);
			barSummonPoint.SetPoint(SummonablePoint-usedSummonPoint, SummonablePoint);
			deleteSlotbyIndex(slotIndex);
			setSummonedSlotNone(false);
		}
	}
}


function bool isLock(){//소환 포인트가 잠겼는지 열렸는지 확인.
	local int usedSummonPoint;
	local int SummonablePoint;
	GetSummonPoint(usedSummonPoint, SummonablePoint);
	if(SummonablePoint - usedSummonPoint < summonpintMinPoint || usedSummonPoint == 0) return true;
	return false;
}



function setSummonedSlotNone(bool lock){
	//local string texture;
	local string hidePath;
	local string showPath;
	local int i;
	if(lock){
		hidePath = "SummonedWnd.SummonedSlotBlank";
		showPath = "SummonedWnd.SummonedSlotNone" ;
		//texture = "L2UI_ct1.Summoned.Summoned_DF_SummonedSlot0";//닫힘 //텍스쳐를 바꾸면 안되고. HideWindow()  .ShowWindow() 로 
	} else {
		hidePath = "SummonedWnd.SummonedSlotNone" ;
		showPath = "SummonedWnd.SummonedSlotBlank";
		//texture = "L2UI_ct1.Summoned.Summoned_DF_SummonedSlot1";//열림
	}
	//for(i = 1; i <= 4 ; i++) GetTextureHandle( "SummonedWnd.SummonedSlotNone" $ i ).SetTexture(texture);
	for(i = 1; i <= 4 ; i++) 
	{
		GetTextureHandle( hidePath $ i ).HideWindow();
		GetTextureHandle( showPath $ i ).ShowWindow();
	}

}



function deleteSlotbyIndex(int slotIndex){
	//각종 정보 공란 처리 후....
	local TextureHandle SummonedFace;
	//GetBarHandle( "SummonedWnd.barHP_" $ (slotIndex + 1)).SetValue(0, 0);
	//GetBarHandle( "SummonedWnd.barMP_" $ (slotIndex + 1)).SetValue(0, 0);
	GetButtonHandle( "SummonedWnd.btnBar_" $ (slotIndex + 1)).ClearTooltip();
	summonedSlotArray[slotIndex].serverID = -1;

	SummonedFace = GetTextureHandle( "SummonedWnd.SummonedFace" $ (slotIndex + 1) );
	SummonedFace.SetTexture("");
	GetTextureHandle( "SummonedWnd.SummonedSlotOutline" $ (slotIndex + 1) ).HideWindow();
	GetBarHandle( "SummonedWnd.barHP_" $ (slotIndex + 1)).HideWindow();
	GetBarHandle( "SummonedWnd.barMP_" $ (slotIndex + 1)).HideWindow();
}


function HandleSummonInfoUpdate(int serverID)
{		
	local int       HP;
	local int		MaxHP;
	local int		MP;
	local int		MaxMP;

	local int       ClassID;

	local string	Name;
	local int		Level;

	local int       SummonablePoint;//ldw 
	local int       usedSummonPoint;	
	
	local SummonInfo info;

	// 정탄 표현 카운트
	// 상태 정보 슬롯 index
	local int slotIndex;	

	local TextureHandle SummonedFace;

		if (GetSummonInfo(serverID, info))
		{
			ClassID = info.nClassID;
			Name  = info.Name;
			Level = info.nLevel;
			HP    = info.nCurHP;
			MaxHP = info.nMaxHP;
			MP    = info.nCurMP;
			MaxMP = info.nMaxMP;
			
			//branch 110824
			if( ClassID <= 0 ) return; //class가 0으로 넘어올때가 있어서 아이콘이 안나옴 

			slotIndex = GetIsSummonedSlotIndex(serverID); //같은 슬롯 검사.			

			if (slotIndex == -1){ //같은 슬롯 없으면 신규 등록
				slotIndex = getSummonedSlotIndex();
				// 스킬 아이콘 텍스쳐를 얻어서 텍스쳐 적용 시키는 부분 넣어야함.
				
				
				/*enum ETextureCtrlType
				*{
				*    TCT_Stretch             =0,
				*    TCT_Normal              =1,
				*    TCT_Tile                =2,
				*    TCT_Draggable           =3,
				*    TCT_Control             =4,
				*    TCT_Mask                =5,
				};
				*/

				SummonedFace = GetTextureHandle( "SummonedWnd.SummonedFace" $ (slotIndex + 1) );
				
				
				
				//SummonedFace.SetTexture("icon.skill11256");
				SummonedFace.SetTexture( class'UIDATA_NPC'.static.GetNPCIconName(ClassID) );
				SummonedFace.SetTextureSize(32,32);

				GetTextureHandle( "SummonedWnd.SummonedSlotOutline" $ (slotIndex + 1) ).ShowWindow();

				GetBarHandle( "SummonedWnd.barHP_" $ (slotIndex + 1)).ShowWindow();
				GetBarHandle( "SummonedWnd.barMP_" $ (slotIndex + 1)).ShowWindow();
//				Debug("ClassID = "$ClassID);

				summonedSlotArray[slotIndex].serverID = serverID;			

				class'ActionAPI'.static.RequestSummonedCommonActionList(serverID);// ->  공통 스킬 1340 이벤트 발생 -> 1350 이벤트 파라메타로 스킬이 들어옴. 소환수 개수가 달라 질 때 갱신
				class'ActionAPI'.static.RequestSummonedAllSkillActionList();//->         개별 스킬 1351 이벤트 발생 -> 1352 이벤트 파라메타로 스킬이 들어옴. 소환수 개수가 달라 질 때 갱신			
				
				//setInformation(serverID); //
				//setbtnBarSelection(serverID); //셀렉션 처리
			}
			
			if( slotIndex == selectedSlotIndex  )// 지금 선택 되어 있는 정보의 ID가 serverID라면.
			{
				setInformation(serverID);
			}

			GetSummonPoint(usedSummonPoint, SummonablePoint);
			barSummonPoint.SetPoint(SummonablePoint-usedSummonPoint, SummonablePoint);
			setSummonedSlotNone(isLock());


			GetBarHandle( "SummonedWnd.barHP_" $ (slotIndex + 1)).SetValue(MaxHP, HP);
			GetBarHandle( "SummonedWnd.barMP_" $ (slotIndex + 1)).SetValue(MaxMP, MP);  
			GetButtonHandle( "SummonedWnd.btnBar_" $ (slotIndex + 1)).SetTooltipCustomType(setHpMpToolTips(  Level, Name,  MaxHP, HP, MaxMP, MP));	
	}	
}

function setStatusBarHP(int slotIndex, int curHP , int serverID) 
{	
	local SummonInfo info;
	local string	Name;
	local int		Level;
	local int		MaxHP;	
	local int		MP;	
	local int		MaxMP;	

	if (GetSummonInfo(serverID, info))
	{		
		MaxHP = info.nMaxHP;
		MaxMP = info.nMaxMP;
		MP = info.nCurMP;
		Name  = info.Name;
		Level = info.nLevel;

		GetBarHandle( "SummonedWnd.barHP_" $ (slotIndex + 1)).SetValue(MaxHP, curHP);
		GetBarHandle( "SummonedWnd.barMP_" $ (slotIndex + 1)).SetValue(MaxMP, MP);  
		GetButtonHandle( "SummonedWnd.btnBar_" $ (slotIndex + 1)).SetTooltipCustomType(setHpMpToolTips(  Level, Name,  MaxHP, curHP, MaxMP, MP));	
	}
}

function setStatusBarMP(int slotIndex, int curMP, int serverID ) 
{
	local SummonInfo info;
	local string	Name;
	local int		Level;
	local int		MaxHP;	
	local int		HP;	
	local int		MaxMP;	

	if (GetSummonInfo(serverID, info))
	{		
		MaxHP = info.nMaxHP;
		MaxMP = info.nMaxMP;
		HP = info.nCurHP;
		Name  = info.Name;
		Level = info.nLevel;

		GetBarHandle( "SummonedWnd.barHP_" $ (slotIndex + 1)).SetValue(MaxHP, HP);
		GetBarHandle( "SummonedWnd.barMP_" $ (slotIndex + 1)).SetValue(MaxMP, curMP);  
		GetButtonHandle( "SummonedWnd.btnBar_" $ (slotIndex + 1)).SetTooltipCustomType(setHpMpToolTips(  Level, Name,  MaxHP, HP, MaxMP, curMP));	
	}
}





function setbtnBarSelection(int serverID){ //셀렉션 처리 도구.
	
	local ButtonHandle btnBAr;
	local string btnString_None;
	local string btnString_Over;
	local string btnString_Down;
	local int slotIndex;
	local int i;	
	
	btnString_None="L2UI_ct1.Summoned.Summoned_DF_SelectBtn";
	btnString_Over="L2UI_ct1.Summoned.Summoned_DF_SelectBtn_Over";
	btnString_Down="L2UI_ct1.Summoned.Summoned_DF_SelectBtn_Down";	
	
	selectedSlotIndex = -1;
	for( i = 1; i <= summonMaxNum ; i++){
		btnBAr = GetButtonHandle("SummonedWnd.btnBar_" $ i);
		btnBAr.SetTexture(btnString_None, btnString_Down,btnString_Over);
	}
	if(serverID > 0 ){
		slotIndex = GetIsSummonedSlotIndex(serverID);
		btnBAr = GetButtonHandle("SummonedWnd.btnBar_" $ (slotIndex + 1));		
		btnString_None="L2UI_ct1.Summoned.Summoned_DF_SelectBtn_Down";		
		btnBAr.SetTexture(btnString_None, btnString_Down,btnString_Over);
		selectedSlotIndex = slotIndex;
	}	
}



/**
 *  현재 추가 해야할 슬롯 배열의 index 번호를 리턴 받는다.
 **/

function int getNextSummonedSlotIndex(int slotIndex)//앞에서 부터 차 있는 이전 슬롯을 찾음 없으면 에서 부터 찾음
{
	local int i;	
	for(i = 0 ; i < summonMaxNum ; i++){
		slotIndex++;
		if(slotIndex == summonMaxNum ){
			slotIndex = 0;
		}
		if( summonedSlotArray[slotIndex].serverID != -1 )
			return slotIndex;
	}
	return -1;
}


function int getSummonedSlotIndex()//앞에서 부터 빈 슬롯을 찾음ui
{
	local int i;
	for (i = 0; i < summonMaxNum; i++)
	{
		// 빈 슬롯이 있다면..
		if (summonedSlotArray[i].serverID == -1) 
		{
			return i; //빈 번호
		}		
	}
	return -1; //빈 번호 없음.
}

function int GetIsSummonedSlotIndex(int serverID){
// 해당 서버아이디가 이미 슬롯에 있다면 해당 슬롯 번호를 리턴
	local int i;
	for(i=0 ; i < summonMaxNum ; i++){
		if (summonedSlotArray[i].serverID == serverID) 
		{			
			return i; //같은게 있음.	
		}
	}
	return -1; //같은게 없음.
}



/**
 *  전체 액션 아이템 윈도우 삭제 
 **/
function ClearActionWnd()
{
	SummonedActionWnd.Clear();
	SummonedActionWnd2.Clear();
	SummonedActionWnd3.Clear();

	SummonedActionWnd_Before.Clear();
}

/**
 *  소환수 액션 윈도우를 채운다 
 *  
 **/
function HandleActionSummonedList(string param)
{
	local UserInfo userinfo;
	
	local int tmpID;
	local int Tmp;
	local EActionCategory Type;
	local string strActionName;
	local string strIconName;
	local string strDescription;
	local string strCommand;
	
	local ItemInfo	infItem;

	local int usedSummonPoint;
	local int SummonablePoint;
	
	ParseItemID(param, infItem.ID);

	//infItem.ID 메뉴 창에 스킬이 없을 경우 추가 아래 부분

	ParseInt(param, "Type", Tmp);
	ParseString(param, "Name", strActionName);
	ParseString(param, "IconName", strIconName);
	ParseString(param, "Description", strDescription);
	ParseString(param, "Command", strCommand);
	

//	Debug("hAction:" @ param);

	infItem.Name = strActionName;
	infItem.IconName = strIconName;
	infItem.Description = strDescription;
	infItem.ItemSubType = int(EShortCutItemType.SCIT_ACTION);
	infItem.MacroCommand = strCommand;
	infItem.ReuseDelayShareGroupID = -1;
	
	GetPlayerInfo( userinfo );

	
	
	GetSummonPoint(usedSummonPoint, SummonablePoint);

	//if (GetClassTransferDegree(userinfo.Class) > 3 )//ldw 소환수의 소환 포인트를 기준도 추가 -> || SummonedPoint  ,SummonablePoint 
	
	if (usedSummonPoint>0){
		//Debug("새로운 4차 전직 소환수");
		SummonedWnd_Action2.ShowWindow();
		SummonedWnd_Action1.HideWindow();
		bAwakeStateFlag = true;
	} else
	{
		//Debug("기존의 1~3차 고전 소환수 ");
		SummonedWnd_Action1.ShowWindow();
		SummonedWnd_Action2.HideWindow();
		bAwakeStateFlag = false;
	}
	
	// Type enum
	//
	//enum EActionCategory
	//{

		//0  ACTION_NONE,
		//1  ACTION_BASIC,
		//2  ACTION_PARTY,
		//3  ACTION_TACTICALSIGN,
		//4  ACTION_SOCIAL,
		//5  ACTION_PET,
		//6  ACTION_SUMMON,  //예전 것
		//7  ACTION_SUMMON_DIRECT,  //기본 명령
		//8  ACTION_SUMMON_AI, //인공 지능
		//9  ACTION_SUMMON_REACT, //없어짐
		//10 ACTION_SUMMON_SKILL, //스킬
	//};	

			
	Type = EActionCategory(Tmp);
	
	// 1~3차, 한마리 소환
	
	
	
	if (bAwakeStateFlag == false)
	{		
		tmpID = SummonedActionWnd_Before.FindItem(infItem.ID);
		if (Type==ACTION_SUMMON)
		{		
			if( tmpID < 0 ){
				//Debug("step 2:"$  Type $ ", " $ infItem.MacroCommand);
				SummonedActionWnd_Before.AddItem(infItem);
			}
		}
	}
	// 각성 이후, 1~4마리 소환
	else
	{
		//Debug("각성");
	    if (Type==ACTION_SUMMON_DIRECT) //type = 7
		{
			// 명령
			//Debug("type:"$string(Type));		
			tmpID = SummonedActionWnd.FindItem(infItem.ID);
			if( tmpID < 0 ) {   SummonedActionWnd.AddItem(infItem);
				//Debug(Type $ "에 " $ tmpID);//스킬이 더해 짐
			}
		}
		else if (Type==ACTION_SUMMON_AI)
		{
			// 방침
			//Debug("type:"$string(Type));		
			tmpID =	SummonedActionWnd2.FindItem(infItem.ID);
			if( tmpID < 0 ) SummonedActionWnd2.AddItem(infItem);
			if(currentSummonPolicy == -1){//첫 방침 초기화 수정적이 온 로드 방침임.
				if(SummonedActionWnd2.GetItem(0, infItem)){
					currentSummonPolicy = 0;
					SummonedActionWnd2.SetToggleEffect(currentSummonPolicy, true);
					//SummonedActionWnd2.SetToggle(currentSummonPolicy, true);
					//Debug(Type $ "에 " $ tmpID);//스킬이 더해 짐
				}
			}
		}
		else if (Type==ACTION_SUMMON_SKILL)
		{   
			//스킬
			//Debug("type:"$string(Type));		
			tmpID =	SummonedActionWnd3.FindItem(infItem.ID);
			if( tmpID < 0 ) {   SummonedActionWnd3.AddItem(infItem);
				//Debug(Type $ "에 " $ tmpID);//스킬이 더해 짐
			}
		}
	}
}


/*function bool skillConditionCheck(int tmpID, string tmpCommand){
	if( tmpID < 0 )
		//if(tmpCommand != "/(null)")
			return true;
	else Debug("tmpID:"$tmpID $ ", tmpCommand:" $ tmpCommand );
	return false;
}*/

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 클릭 이벤트
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function OnClickButton( string Name )
{
//	Debug("OnClickButton: " @ Name);

	switch( Name )
	{
		case "btnBar_1":
			setTargetSummon(0);
			
			break;
		case "btnBar_2":
			setTargetSummon(1);
			
			break;
		case "btnBar_3":
			setTargetSummon(2);
			
			break;
		case "btnBar_4":
			setTargetSummon(3);			
			break;
	}
}

function setInformation(int serverID){
	local string	Name;	
	local int		Level;
	local int       ClassID;
	local int		PhysicalAttack;
	local int		PhysicalDefense;
	local int		HitRate;
	local int		CriticalRate;
	local int		PhysicalAttackSpeed;
	local int		MagicalAttack;
	local int		MagicDefense;
	local int		PhysicalAvoid;
	local int		MovingSpeed;
	local int		MagicCastingSpeed;
	local int		SoulShotCosume;
	local int		SpiritShotConsume;

	local int       MagicalHitRate;
	local int       MagicalAvoid;
	local int       MagicalCritical;

	// 정탄 표현 카운트 
	//local int cosumeCount;
	local SummonInfo info;
	
	if (GetSummonInfo(serverID, info))
	{		
		Name  = info.Name;
		Level = info.nLevel;

		ClassID             = info.nClassID;
		PhysicalAttack		= info.nPhysicalAttack;
		PhysicalDefense		= info.nPhysicalDefense;
		HitRate				= info.nHitRate;
		CriticalRate		= info.nCriticalRate;
		PhysicalAttackSpeed	= info.nPhysicalAttackSpeed;
		MagicalAttack		= info.nMagicalAttack;
		MagicDefense		= info.nMagicDefense;
		PhysicalAvoid		= info.nPhysicalAvoid;
		MovingSpeed			= info.nMovingSpeed;
		MagicCastingSpeed	= info.nMagicCastingSpeed;
		SoulShotCosume		= info.nSoulShotCosume;
		SpiritShotConsume	= info.nSpiritShotConsume;

		MagicalHitRate      = info.nMagicalHitRate;
		MagicalAvoid        = info.nMagicalAvoid;
		MagicalCritical     = info.nMagicalCritical;

		//cosumeCount = 1;
		/*
		ing(   SummonablePoint    ) );*/
		//펫 상세 정보 탭

		SummonedFace.SetTexture( class'UIDATA_NPC'.static.GetNPCIconName(ClassID) );
		SummonedFace.SetTextureSize(32,32);

		txtLvName.SetText(Level $ " " $ Name);
		txtPhysicalAttack.SetText(string(PhysicalAttack));
		txtPhysicalDefense.SetText(string(PhysicalDefense));
		txtHitRate.SetText(string(HitRate));
		txtCriticalRate.SetText(string(CriticalRate));
		txtPhysicalAttackSpeed.SetText(string(PhysicalAttackSpeed));
		txtMagicalAttack.SetText(string(MagicalAttack));
		txtMagicDefense.SetText(string(MagicDefense));
		txtPhysicalAvoid.SetText(string(PhysicalAvoid));
		txtMovingSpeed.SetText(string(MovingSpeed));
		txtMagicCastingSpeed.SetText(string(MagicCastingSpeed));
		txtMagicHit.SetText(string(MagicalHitRate));
		txtMagicAvoid.SetText(string(MagicalAvoid));
		txtMagicCritical.SetText(string(MagicalCritical));			
		//if (SoulShotCosume > 0)
		//{
			//GetTextBoxHandle("SummonedWnd.txtHeadSoulShotCosume1").SetText(GetSystemString(404));// 404 정령탄 소모
		txtSoulShotCosume1.SetText(String(SoulShotCosume));
			/*
			GetTextBoxHandle("SummonedWnd.txtHeadSoulShotCosume" $ string(cosumeCount)).SetText(GetSystemString(404));// 404 정령탄 소모
			GetTextBoxHandle("SummonedWnd.txtSoulShotCosume" $ string(cosumeCount)).SetText(String(SoulShotCosume));
			cosumeCount++;*/
		//}
		
		//if (SpiritShotConsume > 0){
			//GetTextBoxHandle("SummonedWnd.txtHeadSoulShotCosume2").SetText(GetSystemString(496));// 496 마정탄 소모
		txtSoulShotCosume2.SetText(String(SpiritShotConsume));			
			//cosumeCount++;
		//}

	} else {
		//cosumeCount = 1;
		SoulShotCosume = 0;
		SpiritShotConsume = 0;

		txtLvName.SetText("");
		txtPhysicalAttack.SetText("");
		txtPhysicalDefense.SetText("");
		txtHitRate.SetText("");
		txtCriticalRate.SetText("");
		txtPhysicalAttackSpeed.SetText("");
		txtMagicalAttack.SetText("");
		txtMagicDefense.SetText("");
		txtPhysicalAvoid.SetText("");
		txtMovingSpeed.SetText("");
		txtMagicCastingSpeed.SetText("");		
		//if (SoulShotCosume > 0)
		//{
			//GetTextBoxHandle("SummonedWnd.txtHeadSoulShotCosume1" ).SetText(GetSystemString(404));// 404 정령탄 소모
		txtSoulShotCosume1.SetText(String(SoulShotCosume));
			//cosumeCount++;
		//}		
		//if (SpiritShotConsume > 0){
			//GetTextBoxHandle("SummonedWnd.txtHeadSoulShotCosume2" ).SetText(GetSystemString(496));// 496 마정탄 소모
		txtSoulShotCosume2.SetText(String(SpiritShotConsume));			
			//cosumeCount++;
		//}
	}
}



/**
 *  툴팁 hp, mp 보이도록 
 **/
function CustomTooltip setHpMpToolTips (int Level, string Name, int maxHP, int currentHP, int maxMP, int currentMP)
{
	local CustomTooltip m_Tooltip;
	
	m_Tooltip.DrawList.Length = 8;
	
	m_Tooltip.DrawList[0].t_bDrawOneLine = true;
	m_Tooltip.DrawList[0].eType = DIT_TEXT;
	m_Tooltip.DrawList[0].t_strText = "Lv ";		

	m_Tooltip.DrawList[1].t_bDrawOneLine = true;
	m_Tooltip.DrawList[1].eType = DIT_TEXT;//level
	m_Tooltip.DrawList[1].t_color.R = 175;
	m_Tooltip.DrawList[1].t_color.G = 152;
	m_Tooltip.DrawList[1].t_color.B = 120;
	m_Tooltip.DrawList[1].t_color.A = 255;
	m_Tooltip.DrawList[1].t_strText = String(level) $ " " $ name;//name
	
	m_Tooltip.DrawList[2].t_bDrawOneLine = true;
	m_Tooltip.DrawList[2].eType = DIT_TEXT;
	m_Tooltip.DrawList[2].bLineBreak = true;	
	m_Tooltip.DrawList[2].t_strText = "HP: ";	
	
	m_Tooltip.DrawList[3].t_bDrawOneLine = true;
	m_Tooltip.DrawList[3].eType = DIT_TEXT;
	m_Tooltip.DrawList[3].t_color.R = 175;
	m_Tooltip.DrawList[3].t_color.G = 152;
	m_Tooltip.DrawList[3].t_color.B = 120;
	m_Tooltip.DrawList[3].t_color.A = 255;
	
	m_Tooltip.DrawList[3].t_strText = String(currentHP);//h
	
	m_Tooltip.DrawList[4].t_bDrawOneLine = true; //한 줄로 적을 것.
	m_Tooltip.DrawList[4].eType = DIT_TEXT;	
	m_Tooltip.DrawList[4].t_strText = " / " $ maxHP $ "  ";		
	
	m_Tooltip.DrawList[5].eType = DIT_TEXT;
	m_Tooltip.DrawList[5].bLineBreak = true;
	m_Tooltip.DrawList[5].t_strText = "MP: ";

	m_Tooltip.DrawList[6].t_bDrawOneLine = true;
	m_Tooltip.DrawList[6].eType = DIT_TEXT;	
	m_Tooltip.DrawList[6].t_color.R = 175;
	m_Tooltip.DrawList[6].t_color.G = 152;
	m_Tooltip.DrawList[6].t_color.B = 120;
	m_Tooltip.DrawList[6].t_color.A = 255;
	m_Tooltip.DrawList[6].t_strText = String(currentMP);


	m_Tooltip.DrawList[7].t_bDrawOneLine = true;
	m_Tooltip.DrawList[7].eType = DIT_TEXT;
	m_Tooltip.DrawList[7].t_strText = " / " $ maxMP;//mp	

	return m_Tooltip;
}


/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( "SummonedWnd" ).HideWindow();
}
defaultproperties
{
}
