class HelpWnd extends UICommonAPI;

var WindowHandle  Me;
var TreeHandle    MainTree;
var HtmlHandle    HtmlViewer;

var string ROOTNAME;
var string TREENAME;

var int bodyCount;
var int currentID;
var int bodyCountCurrent;
var string expenedNode;

var buttonHandle btnNext ;
var buttonHandle btnPrev ;
var TextBoxHandle txtNumber;

var bool indexLoaded;

const ERRORMESSAGEID = 99;

function OnRegisterEvent()
{
	RegisterEvent( EV_ShowHelp );
	RegisterEvent( EV_TutorialShowID );
	//RegisterEvent( EV_Restart );
}


function OnLoad()
{
	SetClosingOnESC(); 	
	registerState(getCurrentWindowName(string(Self)), "GamingState" );		
	registerState(getCurrentWindowName(string(Self)), "LoginState" );	
	
	Initialize();
}

function Initialize()
{
	Me                       = GetWindowHandle( "HelpWnd" );
	MainTree                 = GetTreeHandle( "HelpWnd.MainTree" );
	HtmlViewer               = GetHtmlHandle( "HelpWnd.HtmlViewer" );

	btnNext                 = GetButtonHandle( "HelpWnd.btnNext");
	btnPrev                 = GetButtonHandle( "HelpWnd.btnPrev");

	txtNumber               = GetTextBoxHandle ( "HelpWnd.txtNumber");

	ROOTNAME = "root";
	TREENAME = "HelpWnd.MainTree";

	bodyCountCurrent = 1;
	bodyCount = 1;
	setButtonState();
}

function onEvent ( int eventID, string param )
{
	if ( GetGameStateName() == "SERVERLISTSTATE"  ) return;
	else if ( getInstanceUIData().getIsClassicServer() ) return;
	
	switch ( eventID )
	{	
		// 메뉴 등지에서 열 때
		case EV_ShowHelp         : openHelp( param );    break;
		//case EV_Restart          : indexLoaded = false;     break;
		// 서버 에서 열 때
		case EV_TutorialShowID   : handleTutorialShow( param ) ;   break;
	}
}

/** onShow */
function OnShow()
{		
	PlayConsoleSound(IFST_WINDOW_OPEN);	
}

function OnHide()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	//removeDataArray();
}


function OnClickButton( string Name )
{
	switch( Name )
	{
		case "btnNext" :
			bodyCountCurrent ++ ;
			setButtonState () ;
			loadHtml();
			break;
		case "btnPrev" :
			bodyCountCurrent -- ;	
			setButtonState () ;
			loadHtml();
			break;
		default : clickTreeNode( Name );
			setButtonState () ;
			loadHtml();
			MainTree.SetFocus();
			break;
	}
}

/***************************************************************************************************************
 * 트리 클릭할때
 * *************************************************************************************************************/
function clickTreeNode( string Name )
{
	//Tree용 변수
	local Array<string> Result, bodyInfo;

	//Debug( "clickTreeList > " @ Name @ nodeNameByID ( 23 ) == Name  @ expenedNode == Name);	
	
	// 같은 노드 클릭 시 처리하지 말아라.
	if ( expenedNode == Name  ) 
	{
		MainTree.SetExpandedNode( expenedNode, true );
		return;
	}

	// 마지막 노드가 아니면 진행 하지 말아라.
	Split( Name, ".", Result );
	if ( Result.Length < 3 )  return;
	
	
	// 이전에 확장했던 노드를 닫음
	if ( expenedNode != "" ) MainTree.SetExpandedNode( expenedNode, false );
	expenedNode = Name;	

	Split ( Result[2], ",", bodyInfo) ;

//	Debug (  "clickTreeNode" @ bodyInfo[0] @ bodyInfo[1]  );
	
	// ID
	currentID = int (bodyInfo[0]);
	// count;
	bodyCount = int (bodyInfo[1]) ;
	bodyCountCurrent = 1;

	

	// 트리에 포커스가 붙는 것 방지
}

/** 전체 노드 열기, 닫기 */
//function allNodeExpanded( bool bOpen )
//{
	
//	local array<string>	arrSplit;	
//	local string strChildList;
//	local int i;

//	Debug ( "allNodeExpanded" );
//	strChildList = MainTree.GetChildNode( ROOTNAME );

//	Split(strChildList, "|", arrSplit);

//	// 열기 
//	for ( i = 0; i < arrSplit.length; i++)  MainTree.SetExpandedNode( arrSplit[i], bOpen);
//}


function setButtonState () 
{
	txtNumber.setText (( bodyCountCurrent ) $"/"$ bodyCount ); 
	if ( bodyCountCurrent == 1 ) btnPrev.DisableWindow ( ) ;
	else btnPrev.EnableWindow ( ) ;
	if ( bodyCountCurrent == bodyCount ) btnNext.DisableWindow ( ) ; 
	else btnNext.EnableWindow () ;
}

function handleTutorialShow ( string param ) 
{
	local int ID ;
	parseInt ( param , "ID", ID ) ;
	if ( ID > 0 ) 
	{
		if ( !indexLoaded ) 
		{
			helpIndexLoad();
			indexLoaded = true;
		}
		setExpandedNodeByID( ID ) ;
		Me.ShowWindow();
	}	
	HtmlViewer.SetFocus();
}


function openHelp( string param )
{		
	//local string nodeName;
	//param = "23";	
	if( Me.IsShowWindow() )
	{
		Me.HideWindow();
	}
	else
	{		
		if ( !indexLoaded ) {
			helpIndexLoad();
			indexLoaded = true;
		}

		if ( param != "" ) 
		{			
			setExpandedNodeByID( int ( param) ) ;
		}

		Me.ShowWindow();
	}

	HtmlViewer.SetFocus();
}

/******************************************************************************************************************************
 * 데이터 받아 오는 곳 
 * ****************************************************************************************************************************/

/*sort*/
//delegate int OnSortCompareCategroy( TutorialIndex a, TutorialIndex b )
//{
//    if (a.Category > b.Category) // 오름 차순. 조건문에 < 이면 내림차순.
//        return -1;  // 자리를 바꿔야할때 -1를 리턴 하게 함.
//    else
//        return 0;
//}

delegate int OnSortCompareOrder( TutorialIndex a, TutorialIndex b )
{
    if (a.Order > b.Order) // 오름 차순. 조건문에 < 이면 내림차순.
        return -1;  // 자리를 바꿔야할때 -1를 리턴 하게 함.
    else
        return 0;
}


/* 노드 데이타 받아 와 정렬 */
function helpIndexLoad()
{
	local array<TutorialIndex> TutorialIndexs;
	GetTutorialIndices( TutorialIndexs );
	//TutorialIndexs.sort ( OnSortCompareOrder );
	//TutorialIndexs.sort ( OnSortCompareCategroy );	
	setHelpCategroyTreeNode(TutorialIndexs);
}

function setExpandedNodeByID ( int id ) 
{
	local array<TutorialIndex> TutorialIndexs;
	local int i;
	local string nodeName, categoryNodeName;

	GetTutorialIndices( TutorialIndexs ); 	

	for ( i = 0 ; i< TutorialIndexs.Length ; i ++ ) 
	{
		if ( TutorialIndexs[i].ID == id )
		{
			categoryNodeName = ROOTNAME $ "." $ TutorialIndexs[i].Category;
			nodeName = categoryNodeName $"."$TutorialIndexs[i].ID$","$TutorialIndexs[i].LevelCount ;		
			MainTree.SetExpandedNode( categoryNodeName, true ) ;
			MainTree.SetExpandedNode( nodeName, true ) ;
			clickTreeNode ( nodeName );
			setButtonState () ;
			loadHtml();
			return;
		}
	}

}

//function setEcptionMsg () 
//{
//	local TutorialBody body;

//	GetTutorialBody ( ERRORMESSAGEID, 1 , body ); 	
//	//Debug ( "loadHtml" @  body.Description );
//	htmlViewer.LoadHtmlFromString(htmlSetHtmlStart(body.Description));
//	//MainTree.SetFocus();
//	HtmlViewer.SetFocus();
//}



/******************************************************************************************************************************
 * 노드 생성 하는 곳 
 * ****************************************************************************************************************************/
function setHelpCategroyTreeNode( array<TutorialIndex> TutorialIndexs ) 
{
	local int i, categoryIndex ;
	local string strRetName, subTreeName ;//, setTreeName;			
	
	//Debug ( "setHelpCategroyTreeNode2" @ MainTree );

	MainTree.Clear();

	//Root 노드 생성.			
	getInstanceL2Util().TreeInsertRootNode( TREENAME, ROOTNAME, "", 0, 0 );

	categoryIndex = -1 ;

	for ( i = 0; i < TutorialIndexs.Length ; i++ )
	{
		// 트리 노드에 Text 아이템 추가
		// 노드 추가할 Tree 네임, 노드 네임, Text, x, y, 색상 ETreeItemTextType
		if ( categoryIndex != TutorialIndexs[i].Category )  // 테스트 이 후 주석을 풀어야 함. && TutorialIndexs[i].Category != 0 ) 
		{
			categoryIndex = TutorialIndexs[i].Category ;
			
			strRetName = insertExpandNode ( string(categoryIndex ), ROOTNAME) ;

			//// 노드 추가할 Tree, 노드 네임, 텍스쳐 이름, w, h,  x, y
			getInstanceL2Util().TreeInsertTextureNodeItem( TREENAME, strRetName, "L2UI_CT1.EmptyBtn", 190, 30, 0, -5 ) ;
			
			getInstanceL2Util().TreeInsertTextNodeItem( TREENAME, strRetName, GetSystemString ( categoryIndex ), -188, 9, getInstanceL2Util().ETreeItemTextType.COLOR_DEFAULT ) ;
		}
		
		subTreeName = insertNode ( makeNodeName ( TutorialIndexs[i] ), strRetName) ;

		if ( i % 2 == 0 ) 
			getInstanceL2Util().TreeInsertTextureNodeItem( TREENAME, subTreeName , "L2UI_CT1.EmptyBtn", 192, 20);
		else 
			getInstanceL2Util().TreeInsertTextureNodeItem( TREENAME, subTreeName , "L2UI_CH3.etc.textbackline", 192, 20, , , , , 14 );


		/* 말풍선 */
		getInstanceL2Util().TreeInsertTextureNodeItem( TREENAME, subTreeName, "L2UI_CT1.BTN_Icon_Normal", 16, 16, 9 - 192 , 2 );
		getInstanceL2Util().TreeInsertTextNodeItem( TREENAME, subTreeName, TutorialIndexs[i].Name, 3, 4, getInstanceL2Util().ETreeItemTextType.COLOR_GOLD );

		/* 닷 */
		//getInstanceL2Util().TreeInsertTextureNodeItem( TreeName, subTreeName, "L2UI_CT1.BTN_Icon_dot", 6, 6, 9 - 192 , 8 );
		//getInstanceL2Util().TreeInsertTextNodeItem( TreeName, subTreeName, TutorialIndexs[i].Name, 6, 4, getInstanceL2Util().ETreeItemTextType.COLOR_GOLD );
		
		/* 온니 텍스트 */
		//getInstanceL2Util().TreeInsertTextNodeItem( TreeName, subTreeName, TutorialIndexs[i].Name, 4, 4, getInstanceL2Util().ETreeItemTextType.COLOR_GOLD );		 
	}
}

// 튜토리얼 바디에 필요한 데이타로 이름을 만듬 
function string makeNodeName ( TutorialIndex tutorialIndex ) 
{
	return tutorialIndex.ID $"," $ tutorialIndex.LevelCount; 
}

// 두 번째 뎁스 노드 생성
function string insertNode  ( string NodeName, string ParentName) 
{
	local XMLTreeNodeInfo		infNode;	
	local XMLTreeNodeInfo		infNodeClear;	
	
	infNode = infNodeClear ;

	infNode.bShowButton = 0;	
	infNode.strName = NodeName ;
	infNode.bFollowCursor = true ;
	infNode.nOffsetX = 2;	
	
	//Expand되었을때의 BackTexture설정
	//스트레치로 그리기 때문에 ExpandedWidth는 없다. 끝에서 -2만큼 배경을 그린다.
	
	infNode.nTexExpandedOffSetX = 0 ;
	infNode.nTexExpandedOffSetY = 0 ;
	infNode.nTexExpandedHeight = 20 ;	
	infNode.nTexExpandedRightWidth = 0 ;
	infNode.nTexExpandedLeftUWidth = 1 ;
	infNode.nTexExpandedLeftUHeight = 15 ;

	infNode.strTexExpandedLeft = "L2UI_CH3.etc.IconSelect2";

	return class'UIAPI_TREECTRL'.static.InsertNode(TREENAME, ParentName, infNode);
}

// 첫 번째 뎁스 노드 생성
function string insertExpandNode ( string NodeName, string ParentName) 
{
	local XMLTreeNodeInfo		infNode;	
	local XMLTreeNodeInfo		infNodeClear;

	infNode = infNodeClear ;
	infNode.strName = NodeName ;//"" $ ProductID ;
	//infNode.Tooltip = MakeTooltipSimpleText(strTmp) ;
	infNode.bFollowCursor = true ;	

	infNode.bShowButton = 1;
	
	infNode.nTexBtnOffSetY = 8;
	infNode.nTexBtnWidth = 15;
	infNode.nTexBtnHeight = 15;
	infNode.strTexBtnExpand = "l2ui_ch3.QuestWnd.QuestWndPlusBtn";
	infNode.strTexBtnCollapse = "l2ui_ch3.QuestWnd.QuestWndMinusBtn";	

	return class'UIAPI_TREECTRL'.static.InsertNode(TREENAME, ParentName, infNode);
	//class'UIAPI_TREECTRL'.static.InsertNode( TreeName, ParentName, infNode );
}


/******************************************************************************************************************************
 * desc를 불러 오는 곳
 * ****************************************************************************************************************************/
function loadHtml ( )
{
	local TutorialBody body;
	GetTutorialBody ( currentID, bodyCountCurrent , body ); 
	//Debug ( "loadHtml" @  body.Description );
	htmlViewer.LoadHtmlFromString(htmlSetHtmlStart(body.Description));

	// MainTree에서 포커스 잡히는 경우 MainTree를 포커스 해야 하고, 
	//MainTree.SetFocus();
	// 이벤트로 열리는 경우 htmlViewer 를 포커스 한다.
}


//function string htmlSetHtmlStart(string targetHtml)
//{
//	return "<html><body scroll='no'><body>" $ targetHtml $ "</body></html>";
//}


/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{	
	GetWindowHandle(getCurrentWindowName (string(Self))).HideWindow();
}
defaultproperties
{
}
