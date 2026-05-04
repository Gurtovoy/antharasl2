class RefineryWnd extends UICommonAPI;

const DIALOGID_GemstoneCount = 0;

const C_ANIMLOOPCOUNT = 1;
const C_ANIMLOOPCOUNT1 = 1;
const C_ANIMLOOPCOUNT2 = 1;
const C_ANIMLOOPCOUNT3 = 1;

var bool IsResult;
var bool procedure1stat;
var bool procedure2stat;
var bool procedure3stat;
var bool procedure4stat;

var ItemInfo RefineItemInfo;
var ItemInfo RefinerItemInfo;
var ItemInfo GemstoneItemInfo;
var ItemInfo RefinedITemInfo;

var WindowHandle m_RefineryWnd_Main;
var WindowHandle m_RefineResultBackPattern;
var WindowHandle m_Highlight1;
var WindowHandle m_Highlight2;
var WindowHandle m_Highlight3;
var WindowHandle m_SeletedItemHighlight1;
var WindowHandle m_SeletedItemHighlight2;
var WindowHandle m_SeletedItemHighlight3;
var WindowHandle m_DragBox1;
var WindowHandle m_DragBox2;
var WindowHandle m_DragBox3;
var WindowHandle m_DragBoxResult;
var WindowHandle m_RefineAnimation;
var WindowHandle m_ResultAnimation1;
var WindowHandle m_ResultAnimation2;
var WindowHandle m_ResultAnimation3;

var AnimTextureHandle m_RefineAnim;
var AnimTextureHandle m_ResultAnim1;
var AnimTextureHandle m_ResultAnim2;
var AnimTextureHandle m_ResultAnim3;

var ButtonHandle m_OkBtn;
var ButtonHandle m_RefineryBtn;

var ItemWindowHandle m_DragboxItem1;
var ItemWindowHandle m_DragBoxItem2;
var ItemWindowHandle m_DragBoxItem3;
var ItemWindowHandle m_ResultBoxItem;

var TextBoxHandle m_InstructionText;
var TextBoxHandle m_hGemstoneNameTextBox;
var TextBoxHandle m_hGemstoneCountTextBox;

//제련 대상 무기 ID
var ItemID m_TargetItemID;
//제련 아이템 ID
var ItemID m_RefineItemID;
//젬스톤 아이디
var ItemID m_GemStoneItemID;
//젬스톤 수량 카운트
var INT64 m_NecessaryGemstoneCount;
var INT64 m_GemstoneCount;
var string m_GemstoneName;

var InventoryWnd InventoryWndScript;
var WindowHandle InventoryWnd;


var ProgressCtrlHandle m_hRefineryWndRefineryProgress;

function OnRegisterEvent()
{
	RegisterEvent( EV_Restart );                      //리스타트 이벤트를 추가함. (2009.12.2)
	RegisterEvent( EV_ShowRefineryInteface );
	RegisterEvent( EV_RefineryConfirmTargetItemResult );
	RegisterEvent( EV_RefineryConfirmRefinerItemResult );
	RegisterEvent( EV_RefineryConfirmGemStoneResult );
	RegisterEvent( EV_RefineryRefineResult );
	RegisterEvent( EV_DialogOK );
}

function OnLoad()
{
	SetClosingOnESC();
	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();

	if(CREATE_ON_DEMAND==0)
		InitHandle();
	else
		InitHandleCOD();
	IsResult = false;
	procedure1stat = false;
    procedure2stat = false;
	procedure3stat = false;
	procedure4stat = false;
	
// 에니메이션 텍스쳐들에 루프 횟수를 지정한다.
	m_RefineAnim.SetLoopCount( C_ANIMLOOPCOUNT );
	m_ResultAnim1.SetLoopCount( C_ANIMLOOPCOUNT1 );
	m_ResultAnim2.SetLoopCount( C_ANIMLOOPCOUNT2 );
	m_ResultAnim3.SetLoopCount( C_ANIMLOOPCOUNT3 );
	m_hRefineryWndRefineryProgress.SetProgressTime(1900);

	// 완성 후 아래 부분은 지울것. 제련창을 무조건 띄움.
	//m_RefineryWnd_Main.ShowWindow();
	//debug("실행중");
	//ResetReady();
	InventoryWndScript = InventoryWnd( GetScript( "InventoryWnd" ) );
}

function InitHandle()
{
	m_RefineryWnd_Main = GetHandle( "RefineryWnd" );
	m_RefineResultBackPattern = GetHandle( "RefineryWnd.BackPattern");
    m_Highlight1 = GetHandle( "RefineryWnd.ItemDragBox1Wnd.DropHighlight");
    m_Highlight2 = GetHandle( "RefineryWnd.ItemDragBox2Wnd.DropHighlight");
    m_Highlight3 = GetHandle( "RefineryWnd.ItemDragBox3Wnd.DropHighlight");
	m_SeletedItemHighlight1 = GetHandle( "RefineryWnd.ItemDragBox1Wnd.SelectedItemHighlight");
    m_SeletedItemHighlight2 = GetHandle( "RefineryWnd.ItemDragBox2Wnd.SelectedItemHighlight");
    m_SeletedItemHighlight3 = GetHandle( "RefineryWnd.ItemDragBox3Wnd.SelectedItemHighlight");
    m_DragBox1 = GetHandle( "RefineryWnd.ItemDragBox1Wnd");
    m_DragBox2 = GetHandle( "RefineryWnd.ItemDragBox2Wnd");
    m_DragBox3 = GetHandle( "RefineryWnd.ItemDragBox3Wnd");
	m_DragBoxResult = GetHandle( "RefineryWnd.ItemDragBoxResultWnd");
    m_RefineAnimation = GetHandle( "RefineryWnd.RefineLoadingAnimation");
    m_ResultAnimation1 = GetHandle( "RefineryWnd.RefineResultAnimation01");
    m_ResultAnimation2 = GetHandle( "RefineryWnd.RefineResultAnimation02");
    m_ResultAnimation3 = GetHandle( "RefineryWnd.RefineResultAnimation03");

    m_RefineAnim = AnimTextureHandle ( GetHandle( "RefineryWnd.RefineLoadingAnimation.RefineLoadingAnim") );
    m_ResultAnim1 = AnimTextureHandle ( GetHandle( "RefineryWnd.RefineResultAnimation01.RefineResult1") );
    m_ResultAnim2 = AnimTextureHandle ( GetHandle( "RefineryWnd.RefineResultAnimation02.RefineResult2") );
    m_ResultAnim3 = AnimTextureHandle ( GetHandle( "RefineryWnd.RefineResultAnimation03.RefineResult3") );

	m_DragboxItem1 = ItemWindowHandle ( GetHandle( "RefineryWnd.ItemDragBox1Wnd.ItemDragBox1") );
	m_DragBoxItem2 = ItemWindowHandle ( GetHandle( "RefineryWnd.ItemDragBox2Wnd.ItemDragBox2") );
	m_DragBoxItem3 = ItemWindowHandle ( GetHandle( "RefineryWnd.ItemDragBox3Wnd.ItemDragBox3") );
	m_ResultBoxItem = ItemWindowHandle ( GetHandle( "RefineryWnd.ItemDragBoxResultWnd.ItemRefined") );

	m_RefineryBtn = ButtonHandle ( GetHandle ("RefineryWnd.btnRefine") );
	m_OkBtn= ButtonHandle ( GetHandle ("RefineryWnd.btnClose") );

	m_InstructionText = TextBoxHandle ( GetHandle ("RefineryWnd.txtInstruction") );
	m_hGemstoneNameTextBox = TextBoxHandle( GetHandle( "txtGemstoneName" ) );
	m_hGemstoneCountTextBox = TextBoxHandle( GetHandle( "txtGemstoneCount" ) );

	InventoryWnd = GetHandle("InventoryWnd");
}

function InitHandleCOD()
{
	m_RefineryWnd_Main = GetWindowHandle( "RefineryWnd" );
	m_RefineResultBackPattern = GetWindowHandle( "RefineryWnd.BackPattern");
    m_Highlight1 = GetWindowHandle( "RefineryWnd.ItemDragBox1Wnd.DropHighlight");
    m_Highlight2 = GetWindowHandle( "RefineryWnd.ItemDragBox2Wnd.DropHighlight");
    m_Highlight3 = GetWindowHandle( "RefineryWnd.ItemDragBox3Wnd.DropHighlight");
	m_SeletedItemHighlight1 = GetWindowHandle( "RefineryWnd.ItemDragBox1Wnd.SelectedItemHighlight");
    m_SeletedItemHighlight2 = GetWindowHandle( "RefineryWnd.ItemDragBox2Wnd.SelectedItemHighlight");
    m_SeletedItemHighlight3 = GetWindowHandle( "RefineryWnd.ItemDragBox3Wnd.SelectedItemHighlight");
    m_DragBox1 = GetWindowHandle( "RefineryWnd.ItemDragBox1Wnd");
    m_DragBox2 = GetWindowHandle( "RefineryWnd.ItemDragBox2Wnd");
    m_DragBox3 = GetWindowHandle( "RefineryWnd.ItemDragBox3Wnd");
	m_DragBoxResult = GetWindowHandle( "RefineryWnd.ItemDragBoxResultWnd");
    m_RefineAnimation = GetWindowHandle( "RefineryWnd.RefineLoadingAnimation");
    m_ResultAnimation1 = GetWindowHandle( "RefineryWnd.RefineResultAnimation01");
    m_ResultAnimation2 = GetWindowHandle( "RefineryWnd.RefineResultAnimation02");
    m_ResultAnimation3 = GetWindowHandle( "RefineryWnd.RefineResultAnimation03");

    m_RefineAnim = GetAnimTextureHandle( "RefineryWnd.RefineLoadingAnimation.RefineLoadingAnim");
    m_ResultAnim1 = GetAnimTextureHandle( "RefineryWnd.RefineResultAnimation01.RefineResult1");
    m_ResultAnim2 = GetAnimTextureHandle( "RefineryWnd.RefineResultAnimation02.RefineResult2");
    m_ResultAnim3 = GetAnimTextureHandle( "RefineryWnd.RefineResultAnimation03.RefineResult3");

	m_DragboxItem1 = GetItemWindowHandle( "RefineryWnd.ItemDragBox1Wnd.ItemDragBox1");
	m_DragBoxItem2 = GetItemWindowHandle( "RefineryWnd.ItemDragBox2Wnd.ItemDragBox2");
	m_DragBoxItem3 = GetItemWindowHandle( "RefineryWnd.ItemDragBox3Wnd.ItemDragBox3");
	m_ResultBoxItem = GetItemWindowHandle( "RefineryWnd.ItemDragBoxResultWnd.ItemRefined");

	m_RefineryBtn = GetButtonHandle ( "RefineryWnd.btnRefine");
	m_OkBtn= GetButtonHandle ( "RefineryWnd.btnClose");

	m_InstructionText = GetTextBoxHandle("RefineryWnd.txtInstruction");
	m_hGemstoneNameTextBox = GetTextBoxHandle( "txtGemstoneName" );
	m_hGemstoneCountTextBox = GetTextBoxHandle( "txtGemstoneCount" );

	InventoryWnd = GetWindowHandle("InventoryWnd");

	m_hRefineryWndRefineryProgress=GetProgressCtrlHandle("RefineryWnd.RefineryProgress");
}

function OnShow()
{
	ResetReady();

	//if (!InventoryWnd.IsShowWindow())
	//{
	//	ExecuteEvent(EV_InventoryToggleWindow);	
	//}

	// 지정한 윈도우를 제외한 닫기 기능 
	getInstanceL2Util().ItemRelationWindowHide(getCurrentWindowName(String(self)), "InventoryWnd,UnrefineryWnd");

	// TT 74585, 74586
	class'UIAPI_WINDOW'.static.HideWindow( "PetWnd");
 
	//~ ExecuteEvent(EV_InventoryOpenWindow);
	//~ InventoryWndScript.OpenWindow();
}

function ResetBools()
{
	procedure1stat = false;
	procedure2stat = false;
	procedure3stat = false;
	procedure4stat = false;
	m_RefineAnim.Stop();
	m_ResultAnim1.Stop();
	m_ResultAnim2.Stop();
	m_ResultAnim3.Stop();
	m_hRefineryWndRefineryProgress.Reset();
}

// 초기화 
function ResetReady()
{
	m_RefineryBtn.SetNameText(GetSystemstring(1477));
	IsResult = false;
	procedure1stat = false;
	procedure2stat = false;
	procedure3stat = false;
	procedure4stat = false;
	m_GemstoneName = "";
	m_RefineryWnd_Main.ShowWindow();
	m_RefineResultBackPattern.HideWindow();
	m_Highlight1.ShowWindow();
	m_Highlight2.HideWindow();
	m_Highlight3.HideWindow();
	m_SeletedItemHighlight1.HideWindow();
	m_SeletedItemHighlight2.HideWindow();
	m_SeletedItemHighlight3.HideWindow();
	m_DragBox1.ShowWindow();
	m_DragBox2.ShowWindow();
	m_DragBox3.ShowWindow();
	m_DragBoxResult.HideWindow();
	m_RefineAnimation.HideWindow();
	m_ResultAnimation1.HideWindow();
	m_ResultAnimation2.HideWindow();
	m_ResultAnimation3.HideWindow();
	m_RefineAnim.Stop();
	m_ResultAnim1.Stop();
	m_ResultAnim2.Stop();
	m_ResultAnim3.Stop();
	// ResetProgressBar
	m_InstructionText.SetText(GetSystemMessage(1957));
	m_hGemstoneNameTextBox.SetText( "" );
	m_hGemstoneCountTextBox.SetText( "" );
	m_hGemstoneCountTextBox.SetTooltipString( "" );
	m_DragBoxItem1.Clear();
	m_DragBoxItem2.Clear();
	m_DragBoxItem3.Clear();
	m_RefineryBtn.DisableWindow();
	m_hRefineryWndRefineryProgress.Reset();
	MoveItemBoxes( true );
	m_DragBoxItem1.EnableWindow();
	m_DragBoxItem2.DisableWindow();
	m_DragBoxItem3.DisableWindow();
	Playsound("ItemSound2.smelting.Smelting_dragin");
	m_OkBtn.EnableWindow();
}      
       

// Restart 시 초기화 , show, sound 재생 안함. 
function ResetReadyForRestart()
{
	m_RefineryBtn.SetNameText(GetSystemstring(1477));
	IsResult = false;
	procedure1stat = false;
	procedure2stat = false;
	procedure3stat = false;
	procedure4stat = false;
	m_GemstoneName = "";
	m_RefineResultBackPattern.HideWindow();
	m_Highlight1.ShowWindow();
	m_Highlight2.HideWindow();
	m_Highlight3.HideWindow();
	m_SeletedItemHighlight1.HideWindow();
	m_SeletedItemHighlight2.HideWindow();
	m_SeletedItemHighlight3.HideWindow();
	m_DragBox1.ShowWindow();
	m_DragBox2.ShowWindow();
	m_DragBox3.ShowWindow();
	m_DragBoxResult.HideWindow();
	m_RefineAnimation.HideWindow();
	m_ResultAnimation1.HideWindow();
	m_ResultAnimation2.HideWindow();
	m_ResultAnimation3.HideWindow();
	m_RefineAnim.Stop();
	m_ResultAnim1.Stop();
	m_ResultAnim2.Stop();
	m_ResultAnim3.Stop();
	// ResetProgressBar
	m_InstructionText.SetText(GetSystemMessage(1957));
	m_hGemstoneNameTextBox.SetText( "" );
	m_hGemstoneCountTextBox.SetText( "" );
	m_hGemstoneCountTextBox.SetTooltipString( "" );
	m_DragBoxItem1.Clear();
	m_DragBoxItem2.Clear();
	m_DragBoxItem3.Clear();
	m_RefineryBtn.DisableWindow();
	m_hRefineryWndRefineryProgress.Reset();
	MoveItemBoxes( true );
	m_DragBoxItem1.EnableWindow();
	m_DragBoxItem2.DisableWindow();
	m_DragBoxItem3.DisableWindow();
	m_OkBtn.EnableWindow();
}  

// 제련 대상 확인 결과 후 처리할 것들
function OnRefineryConfirmTargetItemResult()
{
	m_RefineResultBackPattern.HideWindow();
	m_Highlight1.HideWindow();
	m_Highlight2.ShowWindow();
	m_Highlight3.HideWindow();
	m_SeletedItemHighlight1.ShowWindow();
	m_SeletedItemHighlight2.HideWindow();
	m_SeletedItemHighlight3.HideWindow();
	m_DragBox1.ShowWindow();
	m_DragBox2.ShowWindow();
	m_DragBox3.ShowWindow();
	m_DragBoxResult.HideWindow();
	m_RefineAnimation.HideWindow();
	m_ResultAnimation1.HideWindow();
	m_ResultAnimation2.HideWindow();
	m_ResultAnimation3.HideWindow();
	procedure1stat = true;
	procedure2stat = false;
	procedure3stat = false;
	procedure4stat = false;
	m_InstructionText.SetText(GetSystemMessage(1958));
	m_hGemstoneNameTextBox.SetText( "" );
	m_hGemstoneCountTextBox.SetText( "" );
	m_hGemstoneCountTextBox.SetTooltipString( "" );
	m_DragBoxItem1.EnableWindow();
	m_DragBoxItem2.EnableWindow();
	m_DragBoxItem3.DisableWindow();
	m_RefineryBtn.DisableWindow();
}      

// 제련 아이템 확인 후 처리할 것들
function OnRefineryConfirmRefinerItemResult()
{
	local String GemstoneName;
	local String Instruction;

	m_RefineResultBackPattern.HideWindow();
	m_Highlight1.HideWindow();
	m_Highlight2.HideWindow();
	m_Highlight3.ShowWindow();
	m_SeletedItemHighlight1.ShowWindow();
	m_SeletedItemHighlight2.ShowWindow();
	m_SeletedItemHighlight3.HideWindow();
	m_DragBox1.ShowWindow();
	m_DragBox2.ShowWindow();
	m_DragBox3.ShowWindow();
	m_DragBoxResult.HideWindow();
	m_RefineAnimation.HideWindow();
	m_ResultAnimation1.HideWindow();
	m_ResultAnimation2.HideWindow();
	m_ResultAnimation3.HideWindow();
	
	procedure1stat = true;
	procedure2stat = true;
	procedure3stat = false;
	procedure4stat = false;

	GemstoneName = class'UIDATA_ITEM'.static.GetItemName( m_GemStoneItemID );
	m_GemstoneName = GemstoneName;
	Instruction = MakeFullSystemMsg( GetSystemMessage( 1959 ), GemstoneName, String( m_NecessaryGemstoneCount ) );
	m_InstructionText.SetText( Instruction );
	m_hGemstoneNameTextBox.SetText( GemstoneName );
	m_hGemstoneCountTextBox.SetText( MakeCostString( String( m_NecessaryGemstoneCount ) ) );
	m_hGemstoneCountTextBox.SetTooltipString( ConvertNumToTextNoAdena( String( m_NecessaryGemstoneCount ) ) );
	
	m_DragBoxItem1.EnableWindow();
	m_DragBoxItem2.EnableWindow();
	m_DragBoxItem3.EnableWindow();
	m_RefineryBtn.DisableWindow();
}      

// 제련 아이템 젬스톤 결과 확인 후 처리할 것들
function OnRefineryConfirmGemStoneResult()
{
	m_RefineResultBackPattern.HideWindow();
	m_Highlight1.HideWindow();
	m_Highlight2.HideWindow();
	m_Highlight3.HideWindow();
	m_SeletedItemHighlight1.ShowWindow();
	m_SeletedItemHighlight2.ShowWindow();
	m_SeletedItemHighlight3.ShowWindow();
	m_DragBox1.ShowWindow();
	m_DragBox2.ShowWindow();
	m_DragBox3.ShowWindow();
	m_DragBoxResult.HideWindow();
	m_RefineAnimation.HideWindow();
	m_ResultAnimation1.HideWindow();
	m_ResultAnimation2.HideWindow();
	m_ResultAnimation3.HideWindow();
	
	procedure1stat = true;
	procedure2stat = true;
	procedure3stat = true;
	procedure4stat = false;
	
	m_InstructionText.SetText(GetSystemMessage(1984));
	m_hGemstoneNameTextBox.SetText( "" );
	m_hGemstoneCountTextBox.SetText( "" );
	m_hGemstoneCountTextBox.SetTooltipString( "" );
	m_RefineryBtn.EnableWindow();
	m_hGemstoneCountTextBox.SetTooltipString( "" );
	//m_DragBoxItem3.SetTooltip(m_GemstoneName @ "(" @m_NecessaryGemstoneCount @ ")");
	
}	

// 제련 결과 후 처리할 것들
function OnRefineryRefineResult()
{
	m_RefineResultBackPattern.HideWindow();
	m_Highlight1.HideWindow();
	m_Highlight2.HideWindow();
	m_Highlight3.HideWindow();
	m_DragBox1.HideWindow();
	m_DragBox2.HideWindow();
	m_DragBox3.HideWindow();
	MoveItemBoxes( true );
	m_DragBoxResult.ShowWindow();
	m_RefineAnimation.HideWindow();
	m_ResultAnimation1.HideWindow();
	m_ResultAnimation2.HideWindow();
	m_ResultAnimation3.HideWindow();
	procedure1stat = true;
	procedure2stat = true;
	procedure3stat = true;
	procedure4stat = true;
	m_InstructionText.SetText(GetSystemMessage(1962));
	m_hGemstoneNameTextBox.SetText( "" );
	m_hGemstoneCountTextBox.SetText( "" );
	m_hGemstoneCountTextBox.SetTooltipString( "" );
}

//Event
function OnEvent( int a_EventID, String a_Param )
{
	switch( a_EventID )
	{
	// Refinery Window Open
	case EV_ShowRefineryInteface:
		if (procedure1stat == false)
		{
			ShowRefineryInterface();
		}
		break;
	// Target Item Validation Result
	case EV_RefineryConfirmTargetItemResult:
		Playsound("ItemSound2.smelting.Smelting_dragin");
		OnTargetItemValidationResult( a_Param );
		break;
	// Refiner Item Validation Result
	case EV_RefineryConfirmRefinerItemResult:
		Playsound("ItemSound2.smelting.Smelting_dragin");
		OnRefinerItemValidationResult( a_Param );
		break;
	// Gemstone Validation Result
	case EV_RefineryConfirmGemStoneResult:
		Playsound("ItemSound2.smelting.Smelting_dragin");
		OnGemstoneValidationResult( a_Param );
		break;
	// Final Refine Result
	case EV_RefineryRefineResult:
		
		OnRefineDoneResult( a_Param );
		break;
	case EV_DialogOK:
		HandleDialogOK();
		break;
	case EV_Restart :                  // 옵션>리스타트 할 경우에도
		ResetReadyForRestart();        // 초기화시킨다.
		break;

	default:
		break;
	}	
}

// 제련창 보여주는 함수 
function ShowRefineryInterface()
{
	ResetReady();
}

// 아이템을 올려 놓을 경우 분기
function OnDropItem( String a_WindowID, ItemInfo a_ItemInfo, int X, int Y)
{
	if (a_ItemInfo.ItemSubType == EShortCutItemType.SCIT_MACRO) return;

	switch (a_WindowID)
	{
		case "ItemDragBox1":
			//debug("드래그 박스 1에 아이템 올려 놓았음." @ procedure1stat @ procedure2stat @ procedure3stat);
			if (procedure1stat == false && procedure2stat == false && procedure3stat == false)
				ValidateFirstItem( a_ItemInfo );
			
		break;
		case "ItemDragBox2":
			//debug("드래그 박스 2에 아이템 올려 놓았음." @ procedure1stat @ procedure2stat @ procedure3stat);
			if(procedure1stat == true && procedure2stat == false && procedure3stat == false)
				ValidateSecondItem( a_ItemInfo );
		break;
		case "ItemDragBox3":
			//debug("드래그 박스 3에 아이템 올려 놓았음." @ procedure1stat @ procedure2stat @ procedure3stat);
			if(procedure1stat == true && procedure2stat == true && procedure3stat == false )
			ValidateGemstoneItem( a_ItemInfo);
		break;
	}
}

// 제련할  아이템의 검증요청
function ValidateFirstItem(ItemInfo a_ItemInfo)
{
	RefineItemInfo = a_ItemInfo;
	m_TargetItemID = a_ItemInfo.ID;

	class'RefineryAPI'.static.ConfirmTargetItem( m_TargetItemID );
}

//제련할 아이템을 수락받을지 결정
function OnTargetItemValidationResult(string a_Param)
{
	local int ItemValidationResult1;
	local ItemID scID;
	
	ParseItemID(a_Param, scID);
	ParseInt(a_Param, "Result", ItemValidationResult1);
	
	switch (ItemValidationResult1)
	{
	//Case Granted
	case 1:
		if (IsSameServerID(scID, RefineItemInfo.ID))
		{
			if( !m_DragBoxItem1.SetItem( 0, RefineItemInfo ) )
				m_DragBoxItem1.AddItem( RefineItemInfo );

			OnRefineryConfirmTargetItemResult();
		}
		break;
	//Case Declined
	case 0:
		break;
	}	
}

//연마제 검증 요청
function ValidateSecondItem(ItemInfo a_ItemInfo)
{
	RefinerItemInfo = a_ItemInfo;
	m_RefineItemID = a_ItemInfo.ID;
	class'RefineryAPI'.static.ConfirmRefinerItem( m_TargetItemID, m_RefineItemID );
}

//연마제를 수락 받을 지 결정
function OnRefinerItemValidationResult(string a_Param)
{
	local ItemID scID;
	local ItemID GemstoneID;
	local int ItemValidationResult2;
	local INT64 RequiredGemstoneAmount;
	
	//debug ("두번째 이벤트 받음:제련제");
	
	ParseItemID(a_Param, scID);
	ParseItemIDWithIndex(a_Param, GemstoneID, 1);
	ParseInt(a_Param, "Result", ItemValidationResult2);
	ParseINT64(a_Param, "GemStoneCount", RequiredGemstoneAmount);
	
	m_GemStoneItemID = GemstoneID;
	m_NecessaryGemstoneCount = RequiredGemstoneAmount;
	
	switch( ItemValidationResult2 )
	{
	case 1:
		if (IsSameServerID(scID, RefinerItemInfo.ID))
		{
			RefinerItemInfo.ItemNum = 1;
			if( !m_DragBoxItem2.SetItem( 0, RefinerItemInfo ) )
				m_DragBoxItem2.AddItem( RefinerItemInfo );
			OnRefineryConfirmRefinerItemResult();
		}
		break;
	case 0:
		break;
	}
	
	//branch121212
	//이벤트시 잼스톤 카운트가 0이다
	if(m_NecessaryGemstoneCount <= 0 )
	{
		OnRefineryConfirmGemStoneResult();
	}	
	//end of branch
}

//젬스톤 검증요청
function ValidateGemstoneItem(ItemInfo a_ItemInfo)
{
	GemstoneItemInfo = a_ItemInfo;
	m_GemStoneItemID = a_ItemInfo.ID;
	debug( string(a_ItemInfo.AllItemCount ));
//	if( a_ItemInfo.AllItemCount > 0 )
	if( a_ItemInfo.itemNum > 0 )
	{
		if(m_NecessaryGemstoneCount <= a_ItemInfo.itemNum)
		{
			m_GemstoneCount = m_NecessaryGemstoneCount;
		}
		else
		{
			m_GemstoneCount = a_ItemInfo.itemNum;
		}
		class'RefineryAPI'.static.ConfirmGemStone( m_TargetItemID, m_RefineItemID, m_GemStoneItemID, m_GemstoneCount );
	}
	else												// 숫자를 물어볼 것인가
	{
		DialogSetID( DIALOGID_GemstoneCount );
		DialogSetParamInt64( a_ItemInfo.ItemNum );
		DialogShow(DialogModalType_Modalless, DialogType_NumberPad, MakeFullSystemMsg( GetSystemMessage( 72 ), a_ItemInfo.Name, "" ), string(Self) );
	}	
}      

//젬스톤을 수락 받을 지 결정
function OnGemstoneValidationResult(String a_Param)
{
	local ItemID scID;
	local int ItemValidationResult3;
	local INT64 RequiredMoreGemstoneAmount;
	local INT64 GemstoneAmountChecked;
	
	//debug ("세번째 이벤트 받음:젬스톤");
	
	ParseItemID(a_Param, scID);
	ParseInt(a_Param, "Result", ItemValidationResult3);
	ParseINT64(a_Param, "NecessaryGemStoneCount", RequiredMoreGemstoneAmount);
	ParseINT64(a_Param, "GemStoneCount", GemstoneAmountChecked);
	
	m_GemStoneItemID = scID;
	
	m_NecessaryGemstoneCount = GemstoneAmountChecked + RequiredMoreGemstoneAmount;
	
	
	switch (ItemValidationResult3)
	{
	case 1:
		if (IsSameServerID(scID, GemstoneItemInfo.ID))
		{
			if( !m_DragBoxItem3.SetItem( 0, GemstoneItemInfo ) )
			{
				GemstoneItemInfo.ItemNum = GemstoneAmountChecked;
				m_DragBoxItem3.AddItem( GemstoneItemInfo );	
			}

			OnRefineryConfirmGemStoneResult();
			
		}
		break;
	case 0:
		break;
	}	
}

// 클래식 서버에서만 아이템을 등록 하도록 코드 추가 ---------------
function checkClassicSupportItem () 
{
	local ItemWindowHandle InventoryItem ;	
	local int index;
   
	// 아이템 등록 재 요청	
	ValidateFirstItem(RefineItemInfo); 

	InventoryItem = GetItemWindowHandle( "InventoryWnd.InventoryItem");
	index = InventoryItem.FindItem( RefinerItemInfo.ID );
	if( InventoryItem.GetItem(index, RefinerItemInfo) )
	{
		ValidateSecondItem(RefinerItemInfo);

		index = InventoryItem.FindItem( GemstoneItemInfo.ID );
		
		if( InventoryItem.GetItem(index, GemstoneItemInfo) )
		{
			if ( GemstoneItemInfo.ItemNum >= m_NecessaryGemstoneCount )
				ValidateGemstoneItem(GemstoneItemInfo);
		}
	}
}

// 버튼을 눌렀을때
function OnClickButton( string strID )
{
	switch (strID)
	{
		case "btnRefine":
			if(IsResult) //결과 화면일때
			{
				OnClickCancelButton();
				ShowRefineryInterface();
				//if(getInstanceUIData().getIsClassicServer()) checkClassicSupportItem();

				if(getInstanceUIData().getIsClassicServer())
				{
					checkClassicSupportItem();
				}
				else
				{
					// 라이브 라면..
					//Debug("RefineItemInfo.Id.ClassID:" @ RefineItemInfo.Id.ClassID);

					// 해외 라이브 :  엘모아덴의 망토, 아덴의 망토, 엘모어의 망토, 페리오스의 망토.. 전설 
					// 만 자동 추가 
					switch(RefineItemInfo.Id.ClassID)
					{
					case 28585:
					case 28586:
					case 28587:
					case 28588:
					case 28589:
					case 28590:
					case 28591:
					case 28592:
						checkClassicSupportItem();
						break;
					}
				}
			}
			else //제련 화면일때
			{
				//debug("Button 눌렸음");
				Playsound("Itemsound2.smelting.smelting_loding");
				OnClickRefineButton();
			}
			break;
		case "btnClose":
			OnClickCancelButton();
			break;
	}
}


// 창닫기 버튼을 눌렀을 때 처리 할 것 들.
function OnClickCancelButton()
{
	m_RefineryWnd_Main.HideWindow();
	Playsound("Itemsound2.smelting.smelting_dragout");
	m_hRefineryWndRefineryProgress.Stop();
	m_RefineAnim.Stop();
	m_RefineAnim.SetLoopCount( C_ANIMLOOPCOUNT );
	
	procedure1stat = false;
        procedure2stat = false;
	procedure3stat = false;
	procedure4stat = false;
}

// 제련 버튼을 눌렀을 때 처리할 것들
function OnClickRefineButton()
{
	m_RefineResultBackPattern.HideWindow();
	m_Highlight1.HideWindow();
	m_Highlight2.HideWindow();
	m_Highlight3.HideWindow();
	m_DragBoxResult.HideWindow();
	m_RefineAnimation.ShowWindow();
	m_ResultAnimation1.HideWindow();
	m_ResultAnimation2.HideWindow();
	m_ResultAnimation3.HideWindow();
	m_RefineryBtn.DisableWindow();
	m_OkBtn.DisableWindow();
	//~ procedure1stat = true;
	//~ procedure2stat = true;
	//~ procedure3stat = true;
	//~ procedure4stat = true;
	PlayRefineAnimation();
	MoveItemBoxes( false );
}      

function PlayRefineAnimation()
{
	m_InstructionText.SetText("");
	m_RefineAnim.Stop();
	m_RefineAnim.SetLoopCount( C_ANIMLOOPCOUNT );
	m_RefineAnim.Play();
	//debug("smelting_loding");
//	Playsound("Itemsound2.smelting.smelting_loding");
//	Playsound("ItemSound2.smelting.smelting_loding");
	m_hRefineryWndRefineryProgress.Start();

}

//연출 이펙트 애니메이션의 종료 확인 및 제련 요청
function OnTextureAnimEnd( AnimTextureHandle a_WindowHandle )
{
	switch ( a_WindowHandle )
	{
	case m_RefineAnim:
		//m_RefineAnim.Stop();
		m_RefineAnimation.HideWindow();
		m_DragBox1.HideWindow();
		m_DragBox2.HideWindow();
		m_DragBox3.HideWindow();
		OnRefineRequest();
		break;
	case m_ResultAnim1:
	case m_ResultAnim2:
	case m_ResultAnim3:
		OnResultAnimEnd();
		break;
	}
}

function OnResultAnimEnd()
{
	//m_ResultAnim1.Stop();
	m_ResultAnimation1.HideWindow();
	//m_ResultAnim2.Stop();
	m_ResultAnimation2.HideWindow();
	//m_ResultAnim3.Stop();
	m_ResultAnimation3.HideWindow();
}

// 서버에 제련을 요청하는 함수 
function OnRefineRequest()
{
	if (procedure1stat && procedure2stat && procedure3stat && !procedure4stat)
	{
		class'RefineryAPI'.static.RequestRefine( m_TargetItemID, m_RefineItemID, m_GemStoneItemID, m_NecessaryGemstoneCount);
		procedure1stat = true;
		procedure2stat = true;
		procedure3stat = true;
		procedure4stat = true;
	}
}

//제련 완료에 따른 결과 확인 
function OnRefineDoneResult(string a_Param)
{
	local int Option1;
	local int Option2;
	local int RefineResult;
	local int Quality;
	
	//debug ("제련완료: 결과 확인");
	ParseInt(a_Param, "Option1", Option1);
	ParseInt(a_Param, "Option2", Option2);
	ParseInt(a_Param, "Result", RefineResult);
	
	m_hRefineryWndRefineryProgress.SetPos(0);
	//~ progFATIGUE.SetPos(RemainTime);
	
	m_OkBtn.EnableWindow();
	
	switch (RefineResult)
	{
	case 1:
		//제련 성공 옵션에 따라 아이템 업데이트하고 에니메이션 수행
		// 버튼을 활성화 시키는 코딩
		// 적절한 스테이트로 UI를 변경 할 것.?
		RefineItemInfo.RefineryOp1 = Option1;
		RefineItemInfo.RefineryOp2 = Option2;

		if( !m_ResultBoxItem.SetItem( 0, RefineItemInfo ) )
			m_ResultBoxItem.AddItem( RefineItemInfo );

		OnRefineryRefineResult();

		Quality = class'UIDATA_REFINERYOPTION'.static.GetQuality( Option2 );
		if( 0 >= Quality )
			Quality = 1;
		else if( 4 < Quality )
			Quality = 4;

		m_RefineResultBackPattern.ShowWindow();
		m_RefineResultBackPattern.SetAlpha( 0 );
		m_RefineResultBackPattern.SetAlpha( 255, 1.f );
		PlayResultAnimation( Quality );
		m_RefineryBtn.SetNameText(GetSystemstring(1731));
		m_RefineryBtn.EnableWindow();
		IsResult = true;
		break;
		
	case 0:
		OnClickCancelButton();
		break;
	}	
}

function HandleDialogOK()
{
	local int ID;

	if( DialogIsMine() )
	{
		ID = DialogGetID();

		switch( ID )
		{
		case DIALOGID_GemstoneCount:
			m_GemstoneCount = INT64( DialogGetString() );
			class'RefineryAPI'.static.ConfirmGemStone( m_TargetItemID, m_RefineItemID, m_GemStoneItemID, m_GemstoneCount );
			break;
		}		
	}
}

// 제련 완료 애니메이션 재생
function PlayResultAnimation(int Grade)
{
	m_ResultAnim1.SetLoopCount( C_ANIMLOOPCOUNT1 );
	m_ResultAnim2.SetLoopCount( C_ANIMLOOPCOUNT2 );
	m_ResultAnim3.SetLoopCount( C_ANIMLOOPCOUNT3 );
	switch(Grade)
	{
	case 1:
		m_ResultAnimation1.ShowWindow();
		Playsound("ItemSound2.smelting.smelting_finalB");
		m_ResultAnim1.Play();
		break;
	case 2:
		m_ResultAnimation2.ShowWindow();
		Playsound("ItemSound2.smelting.smelting_finalC");
		m_ResultAnim2.Play();
		break;
	case 3:
		m_ResultAnimation3.ShowWindow();
		Playsound("ItemSound2.smelting.smelting_finalD");
		m_ResultAnim3.Play();
		break;
	case 4:
		m_ResultAnimation1.ShowWindow();
		m_ResultAnimation2.ShowWindow();
		m_ResultAnimation3.ShowWindow();
		Playsound("ItemSound2.smelting.smelting_finalD");
		m_ResultAnim1.Play();
		m_ResultAnim2.Play();
		m_ResultAnim3.Play();
		break;
	
	}
}

function MoveItemBoxes( bool a_Origin )
{
	local Rect Item1Rect;
	local Rect Item2Rect;
	local Rect Item3Rect;
	local Rect ResultRect;

	if( a_Origin )
	{
		m_DragBox1.SetAnchor( "RefineryWnd", "TopLeft", "TopLeft", 77, 51 );
		m_DragBox1.ClearAnchor();
		m_DragBox2.SetAnchor( "RefineryWnd", "TopLeft", "TopLeft", 157, 51 );
		m_DragBox2.ClearAnchor();
		m_DragBox3.SetAnchor( "RefineryWnd", "TopLeft", "TopLeft", 117, 91 );
		m_DragBox3.ClearAnchor();
	}
	else
	{
		Item1Rect = m_DragBox1.GetRect();
		Item2Rect = m_DragBox2.GetRect();
		Item3Rect = m_DragBox3.GetRect();
		ResultRect = m_DragBoxResult.GetRect();

		m_DragBox1.Move( ResultRect.nX - Item1Rect.nX, ResultRect.nY - Item1Rect.nY, 1.5f );
		m_DragBox2.Move( ResultRect.nX - Item2Rect.nX, ResultRect.nY - Item2Rect.nY, 1.5f );
		m_DragBox3.Move( ResultRect.nX - Item3Rect.nX, ResultRect.nY - Item3Rect.nY, 1.5f );
	}
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	OnClickCancelButton();
}
defaultproperties
{
}
