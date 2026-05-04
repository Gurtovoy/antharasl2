class RecipeTreeWnd extends UICommonAPI;

const CRYSTAL_TYPE_WIDTH = 14;
const CRYSTAL_TYPE_HEIGHT = 14;

var TreeHandle mainTree;

var array<INT64> itemNeedCount;

function OnRegisterEvent()
{
	RegisterEvent( EV_RecipeShowRecipeTreeWnd );
	RegisterEvent( EV_InventoryAddItem );
	RegisterEvent( EV_InventoryUpdateItem );
}

function OnLoad()
{
	SetClosingOnESC();	

	mainTree = GetTreeHandle( "RecipeTreeWnd.MainTree") ;
}

function OnEvent(int Event_ID, String param)
{
	local int RecipeID;	

	if (Event_ID == EV_RecipeShowRecipeTreeWnd)
	{
		ParseInt( param, "RecipeID", RecipeID );
		StartRecipeTreeWnd( RecipeID );
	}
	else if( Event_ID == EV_InventoryAddItem || Event_ID == EV_InventoryUpdateItem )
	{
		HandleInventoryItem(param);
	}
}

function OnClickButton( string strID )
{
	switch( strID )
	{
		case "btnClose":
			CloseWindow();
		break;
	}
}

//윈도우 닫기
function CloseWindow()
{
	Clear();
	class'UIAPI_WINDOW'.static.HideWindow("RecipeTreeWnd");
	PlayConsoleSound(IFST_WINDOW_CLOSE);
}

//초기화
function Clear()
{
	class'UIAPI_TREECTRL'.static.Clear("RecipeTreeWnd.MainTree");
}

//Start Function
function StartRecipeTreeWnd(int RecipeID)
{
	//Show
	class'UIAPI_WINDOW'.static.ShowWindow("RecipeTreeWnd");
	class'UIAPI_WINDOW'.static.SetFocus("RecipeTreeWnd");
	
	Clear();
	SetRecipeInfo(RecipeID);
}

//레시피 정보 셋팅
function SetRecipeInfo(int RecipeID)
{
	local string		strTmp;
	local string		strTmp2;
	local int			nTmp;
	local XMLTreeNodeInfo	infNode;
	
	local int			ProductID;
	local Rect          txtNameRect;

	local ItemInfo      newItem;
	
	//레시피 아이콘 텍스쳐
	//strTmp = class'UIDATA_RECIPE'.static.GetRecipeIconName(RecipeID);
	//레시피 이름
	ProductID = class'UIDATA_RECIPE'.static.GetRecipeProductID(RecipeID);
	
	class'UIDATA_ITEM'.static.GetItemInfo ( GetItemID(ProductID) , newItem  );
	
	class'UIAPI_ITEMWINDOW'.static.Clear( "RecipeTreeWnd.texItem" );
	class'UIAPI_ITEMWINDOW'.static.AddItem( "RecipeTreeWnd.texItem" , newItem ) ;
	
	//class'UIAPI_TEXTURECTRL'.static.SetTexture("RecipeManufactureWnd.texItem", strTmp);
/*
	if (Len(strTmp)>0)
	{
		class'UIAPI_TEXTURECTRL'.static.SetTexture("RecipeTreeWnd.texIcon", strTmp);
	}
	else
	{
		class'UIAPI_TEXTURECTRL'.static.SetTexture("RecipeTreeWnd.texIcon", "Default.BlackTexture");
	}
*/
	
	
	strTmp = MakeFullItemName(ProductID);
	
	//Crystal Type(Grade Emoticon출력)
	nTmp = class'UIDATA_RECIPE'.static.GetRecipeCrystalType(RecipeID);
	strTmp2 = GetItemGradeTextureName(nTmp);

	class'UIAPI_TEXTURECTRL'.static.SetTexture("RecipeTreeWnd.texGrade", strTmp2);
	
	class'UIAPI_TEXTBOX'.static.SetText("RecipeTreeWnd.txtName", strTmp);

	// txtName 폭을 구하고, ... 처리 여부를 지정한다.
	txtNameRect = GetTextBoxHandle("RecipeTreeWnd.txtName").GetRect();

	if ( txtNameRect.nWidth > 150 ) 
	{  
		// 강제로 ... 을 넣고 텍스트 사이즈를 줄여서 UI안에 들어 오도록 하드 코딩, TTP:47441 해결을 위해;
		GetTextBoxHandle("RecipeTreeWnd.txtName").SetWindowSize(141, txtNameRect.nHeight);		
		GetTextBoxHandle("RecipeTreeWnd.txtName").SetTextEllipsisWidth(141);
	}
	else 
	{  
		// ...  넣는 기능 캔슬 
		GetTextBoxHandle("RecipeTreeWnd.txtName").SetTextEllipsisWidth(-1);
	}

	GetTextBoxHandle("RecipeTreeWnd.txtName").SetTooltipType("Text");
	GetTextBoxHandle("RecipeTreeWnd.txtName").SetTooltipText(strTmp);

	// S80 그레이드일 경우에 한해 아이콘 텍스쳐 크기를 2배로 늘린다. 6, 7
	// R95, R99 그레이드일 경우에 한해 아이콘 텍스쳐 크기를 2배로 늘린다. 9, 10
	// EVENT 그레이드일 경우에 2배로 늘리는 곳이 있고 아닌 곳이 있다. 왜그런지 모르니까 일단은 냅둠 11
	if( nTmp == CrystalType.CRT_S80 || nTmp == CrystalType.CRT_S84 || nTmp == CrystalType.CRT_R95 || nTmp == CrystalType.CRT_R99 || nTmp == CrystalType.CRT_EVENT )
	{
		class'UIAPI_WINDOW'.static.SetWindowSize( "RecipeTreeWnd.texGrade", CRYSTAL_TYPE_WIDTH * 2, CRYSTAL_TYPE_HEIGHT );
	}
	else
	{
		class'UIAPI_WINDOW'.static.SetWindowSize( "RecipeTreeWnd.texGrade", CRYSTAL_TYPE_WIDTH, CRYSTAL_TYPE_HEIGHT );
	}
	
	//MP소비량
	nTmp = class'UIDATA_RECIPE'.static.GetRecipeMpConsume(RecipeID);
	class'UIAPI_TEXTBOX'.static.SetText("RecipeTreeWnd.txtMPConsume", "" $ nTmp);
	
	//성공확률
	nTmp = class'UIDATA_RECIPE'.static.GetRecipeSuccessRate(RecipeID);
	class'UIAPI_TEXTBOX'.static.SetText("RecipeTreeWnd.txtSuccessRate", nTmp $ "%");
	
	//레시피 레벨
	nTmp = class'UIDATA_RECIPE'.static.GetRecipeLevel(RecipeID);
	class'UIAPI_TEXTBOX'.static.SetText("RecipeTreeWnd.TxtForgeLevelValue", string(nTmp));
	
	//옵션부여 여부
	if (bool(class'UIDATA_RECIPE'.static.GetRecipeIsMultipleProduct(RecipeID)))
		class'UIAPI_TEXTBOX'.static.SetText("RecipeTreeWnd.txtOption", GetSystemMessage(2320));
	else
		class'UIAPI_TEXTBOX'.static.SetText("RecipeTreeWnd.txtOption", "");

	
	//트리에 Root추가
	infNode.strName = "root";
	infNode.nOffSetX = 1;
	infNode.nOffSetY = 5;
	strTmp = class'UIAPI_TREECTRL'.static.InsertNode("RecipeTreeWnd.MainTree", "", infNode);
	if (Len(strTmp) < 1)
	{
		//debug("ERROR: Can't insert root node. Name: " $ infNode.strName);
		return;
	}
	
	itemNeedCount.Remove(0, itemNeedCount.Length);
	//Debug ( "itemNeedCount 길이 " @ itemNeedCount.Length );
	//트리 작성
	AddRecipeItem(RecipeID, ProductID, 0, "root");
}

/*
 * 인벤토리 아이템 갱신 이벤트 
 */

function HandleInventoryItem ( string param ) 
{
	//local int idx;
	//local ItemInfo infItem;	
	//local int64 invenItemCount;

	local itemID cID ;

	//아이템 필요 수 
	//local int64 needNum ;
//  local string type ;

	//findItem( cID.classID, "root" ) ;
	if (!GetWindowHandle("RecipeTreeWnd").IsShowWindow()) return;

	if (ParseItemID( param, cID ))
	{
		//needNum = 0;
		//재료는 이벤트로 받은 아이템의 serverID 값이 0이다.
		//cID.serverID = 0;

		//class'UIAPI_TREECTRL'.static.IsNodeNameExist("RecipeTreeWnd.MainTree", "nodeName");
		findNFixItem( cID.classID, "root", -1 );//$ "." $ 17290 $ "." $ 36732 ) ;

	//
	//FindItemByClassID( cID );	// ClassID
/*
		ParseString( param, "type", type );

		if( type == "update" )
		{
			
		}
		else if( type == "delete" )
		{
			
		}
		//add인 경우는 필요 없음
		else if( type == "add" )
		{
		}	
*/
	}
}


/* 
 * 레시피의 리스트에서 아이템을 찾아 카운트를 갱신 해 줌. 
 */
function int findNFixItem (  int cID , string strNodeName, int index )
{
	local string strChildList;
	local array<string> ChildList, itemList;
	local string textureName ;

	//local XMLTreeNodeItemInfo	infNodeItem, infNodeItemClear;
	//local XMLTreeNodeInfo	infNode;

	local int i ;
	
	local INT64 nTmp ;
	//strChildList = GetChildNode( "RecipeTreeWnd.MainTree", strNodeName);

	//if ( strNodeName == "root" ) 
//		Debug ( "findItem root");	
	
	strChildList = mainTree.GetChildNode(strNodeName);
	 
	// child 노드를 받아서 배열로 쪼갠 후.
	Split ( strChildList , "|", ChildList );	

	if ( cID <= 0 ) return -1 ;

	//Debug ( "findItem index : " @ index @ cID @ ChildList.Length);

	for ( i = 0 ; i < ChildList.Length ; i ++ ) 
	{	
		if ( ChildList[i] != "" ) 
		{
			index ++ ;
			//Debug ( "findItem" @  index @ "="@ itemNeedCount[index] );			
			// root에 바로 있는 아이템은 내가 만들려고 하는 아이템이며, 보유량이나 필요양이 없으므로 아이템 수량 갱신이 필요 없음
			if ( strNodeName != "root" ) 
			{		
				// 맨 뒤 아이템 ID 만으로 cID 랑 비교 한다.
				Split ( ChildList[ i ], ".", itemList);

				//Debug ( i @ ChildList.Length @ ChildList[i] @ itemList[itemList.Length - 1] @ cID);
				if ( int ( itemList[itemList.Length - 1] ) == cID ) 
				{					
					//인벤토리의 해당 아이템의 갯수
					nTmp = GetInventoryItemCount(GetItemID(cID));
					//Debug ( "findItem" @ ChildList[ i ] @ index @ itemNeedCount[index] );

					mainTree.SetNodeItemText(ChildList[ i ], 1, "("$nTmp$"/"$itemNeedCount[index]$")" );

					//재료가 다 안모아진 경우라면 흐릿하게 표시 그게 아니라면 텍스쳐를 보이지 않게 함.
					if (nTmp < itemNeedCount[index])
					{
						//Debug ( "적다 텍스쳐를 바꿔야 함 " @ ChildList[ i ]  );
						textureName = "Default.ChatBack";
					}	
		
					mainTree.SetNodeItemTexture ( ChildList[ i ], 2 ,textureName,  0, 0, 0);
					class'UIAPI_TREECTRL'.static.SetNodeItemTexture ( "RecipeTreeWnd.MainTree",ChildList[ i ], 2, textureName , 0, 0, 0);
				}				
			}
			
			index = findNFixItem ( cID, ChildList[i], index);
		}
	}

	return index ; 
}

static function int Split( string strInput, string delim, out array<string> arrToken )
{
	local int arrSize;
	
	while ( InStr(strInput, delim)>0 )
	{
		arrToken.Insert(arrToken.Length, 1);
		arrToken[arrToken.Length-1] = Left(strInput, InStr(strInput, delim));
		strInput = Mid(strInput, InStr(strInput, delim)+1);
		arrSize = arrSize + 1;
	}
	arrToken.Insert(arrToken.Length, 1);
	arrToken[arrToken.Length-1] = strInput;
	arrSize = arrSize + 1;
	
	return arrSize;
}

function AddRecipeItem(int RecipeID, int ProductID, INT64 NeedCount, string NodeName)
{
	local int		i;
	local int		nMax;
	local INT64		nTmp;

	local bool		bIamRoot;

	local string	strTmp;
	local string	strTmp2;
	local string	param;
	local string	strRetName;

	local array<int>	arrMatID;
	local array<INT64>	arrMatNeedCount;
	local array<int>	arrMatRecipeID;

	local XMLTreeNodeInfo		infNode;
	local XMLTreeNodeItemInfo	infNodeItem;
	local XMLTreeNodeInfo		infNodeClear;
	local XMLTreeNodeItemInfo	infNodeItemClear;

	local L2util util;
	local itemInfo newItem;

	util = L2Util(GetScript("L2Util"));


	//레시피 이름
	strTmp = class'UIDATA_ITEM'.static.GetItemName(GetItemID(ProductID));


	//Child 레시피들의 추가
	param = class'UIDATA_RECIPE'.static.GetRecipeMaterialItem(RecipeID);
	ParseInt(param, "Count", nMax);
	
	//나중에 Recursive호출하는 부분이 있으므로, Static인 Param을 일단 완전히 뽑아야(?)한다.
	arrMatID.Length = nMax;
	arrMatNeedCount.Length = nMax;
	arrMatRecipeID.Length = nMax;

	for (i=0; i<nMax; i++)
	{
		ParseInt(param, "ID_" $ i, arrMatID[i]);
		ParseINT64(param, "NeededNum_" $ i, arrMatNeedCount[i]);
		ParseInt(param, "RecipeID_" $ i, arrMatRecipeID[i]);	
	}


	if (NodeName == "root")
	{
		bIamRoot = true;
	}
	else
	{
		bIamRoot = false;
	}

		
	//////////////////////////////////////////////////////////////////////////////////////////////////////
	//Insert Node - with Button
	infNode = infNodeClear;
	infNode.strName = "" $ ProductID;
	infNode.Tooltip = MakeTooltipSimpleText(strTmp);
	infNode.bFollowCursor = true;
	
	if(nMax>0) //Child가 있는 레시피
	{
		infNode.bShowButton = 1;

		if (!bIamRoot)
		{
			infNode.nOffSetX = 13;
		}
		infNode.nTexBtnOffSetY = 8;

		infNode.nTexBtnWidth = 15;
		infNode.nTexBtnHeight = 15;
		infNode.strTexBtnExpand = "l2ui_ch3.QuestWnd.QuestWndPlusBtn";
		infNode.strTexBtnCollapse = "l2ui_ch3.QuestWnd.QuestWndMinusBtn";
	}
	
	else
	{
		infNode.bShowButton = 0;
		infNode.nOffsetX = 30;
	}

	strRetName = class'UIAPI_TREECTRL'.static.InsertNode("RecipeTreeWnd.MainTree", NodeName, infNode);

	//Debug ( "nodeName" @ strRetName ) ;
	if (Len(strRetName) < 1)
	{
		Log("ERROR: Can't insert node. Name: " $ infNode.strName);
		return;
	}
	
	//레시피 아이콘 이름
	class'UIDATA_ITEM'.static.GetItemInfo ( GetItemID(ProductID) , newItem  );
	strTmp2 = newItem.iconName;
	//strTmp2 = class'UIDATA_ITEM'.static.GetItemTextureName(GetItemID(ProductID));

	if (Len(strTmp2)<1)
	{
		strTmp2 = "Default.BlackTexture";
	}
	
	//Insert Node Item - 레시피 아이콘
	infNodeItem = infNodeItemClear;
	infNodeItem.eType = XTNITEM_TEXTURE;
	if(nMax>0)
	{
		//Insert Node Item - 아이템슬롯 배경
		util.TreeInsertTextureNodeItem( "RecipeTreeWnd.MainTree", strRetName, "L2UI_ct1.ItemWindow.ItemWindow_df_slotbox_2x2", 36, 36, 0, -2 );
		infNodeItem.nOffSetX = -34;
		// 원래는 2여씀
	}
	else
	{
		//Insert Node Item - 아이템슬롯 배경
		util.TreeInsertTextureNodeItem( "RecipeTreeWnd.MainTree", strRetName, "L2UI_ct1.ItemWindow.ItemWindow_df_slotbox_2x2", 36, 36, -2, -2 );
		infNodeItem.nOffsetX = -34;
	}
	// 기존 0
	infNodeItem.nOffSetY = 0;
	infNodeItem.u_nTextureWidth = 32;
	infNodeItem.u_nTextureHeight = 32;
	infNodeItem.u_strTexture = strTmp2;
	class'UIAPI_TREECTRL'.static.InsertNodeItem("RecipeTreeWnd.MainTree", strRetName, infNodeItem );
	
	//Debug  (  "strRetName"  @ infNodeItem.nOffSetX );

	util.TreeInsertTextureNodeItem( "RecipeTreeWnd.MainTree", strRetName, newItem.iconPanel, 32, 32,  -32);	
	
	//Insert Node Item - 레시피 아이콘(테두리)
	infNodeItem = infNodeItemClear;
	infNodeItem.eType = XTNITEM_TEXTURE;
	infNodeItem.nOffSetX = -32;
	infNodeItem.nOffSetY = 0;
	infNodeItem.u_nTextureWidth = 32;
	infNodeItem.u_nTextureHeight = 32;
	if(nMax>0)
	{
		infNodeItem.u_strTexture = "L2UI.RecipeWnd.RecipeTreeIconBack";
		infNodeItem.u_strTextureExpanded = "L2UI.RecipeWnd.RecipeTreeIconBack_click";
	}
	else
	{
		//infNodeItem.u_strTexture = "L2UI.RecipeWnd.RecipeTreeIconDisableBack";
	}
	
	class'UIAPI_TREECTRL'.static.InsertNodeItem("RecipeTreeWnd.MainTree", strRetName, infNodeItem);
	
	if (!bIamRoot)
	{
		//인벤토리의 해당 아이템의 갯수
		nTmp = GetInventoryItemCount(GetItemID(ProductID));
		
		//재료가 다 안모아진 경우라면 흐릿하게 표시
		//Insert Node Item - 흐릿 텍스쳐
		infNodeItem = infNodeItemClear;
		infNodeItem.eType = XTNITEM_TEXTURE;
		infNodeItem.nOffSetX = -32;
		infNodeItem.nOffSetY = 0;
		infNodeItem.u_nTextureWidth = 32;
		infNodeItem.u_nTextureHeight = 32;
		infNodeItem.t_nTextID = 2;
		if (nTmp < NeedCount)
		{			
			infNodeItem.u_strTexture = "Default.ChatBack";
		}	
		class'UIAPI_TREECTRL'.static.InsertNodeItem("RecipeTreeWnd.MainTree", strRetName, infNodeItem);
	}
	
	//Insert Node Item - 레시피 이름
	infNodeItem = infNodeItemClear;
	infNodeItem.eType = XTNITEM_TEXT;
	infNodeItem.t_strText = strTmp;
	infNodeItem.t_bDrawOneLine = true;
	infNodeItem.nOffSetX = 5;
	infNodeItem.nOffSetY = 3;
	class'UIAPI_TREECTRL'.static.InsertNodeItem("RecipeTreeWnd.MainTree", strRetName, infNodeItem);
	
	if (!bIamRoot)
	{
		//Insert Node Item - 재료 갯수
		infNodeItem = infNodeItemClear;
		infNodeItem.eType = XTNITEM_TEXT;
		infNodeItem.t_nTextID = 1 ;
		infNodeItem.t_strText = "(" $ string(nTmp) $ "/" $ string(NeedCount) $ ")";
		infNodeItem.bLineBreak = true;
		if(nMax>0)
		{
			infNodeItem.nOffSetX = 51;
		}
		else
		{
			infNodeItem.nOffsetX = 37;
		}
		infNodeItem.nOffSetY = -14;
		class'UIAPI_TREECTRL'.static.InsertNodeItem("RecipeTreeWnd.MainTree", strRetName, infNodeItem);
	}

	itemNeedCount.Length = itemNeedCount.Length +1 ;
	itemNeedCount[ itemNeedCount.Length -1 ] = NeedCount ;
//	Debug ( "addItem index " @ itemNeedCount.Length @ "=" @ itemNeedCount[ itemNeedCount.Length -1 ] );

	
	//Insert Node Item - Blank
	infNodeItem = infNodeItemClear;
	infNodeItem.eType = XTNITEM_BLANK;
	infNodeItem.bStopMouseFocus = true;
	if(nMax>0)
	{
		infNodeItem.b_nHeight = 6;
	}
	else
	{
		infNodeItem.b_nHeight = 4;
	}
	class'UIAPI_TREECTRL'.static.InsertNodeItem("RecipeTreeWnd.MainTree", strRetName, infNodeItem);


	for (i=0; i<nMax; i++)
	{
		//Recursive
		AddRecipeItem(arrMatRecipeID[i],arrMatID[i], arrMatNeedCount[i], strRetName);
	}
}


/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	CloseWindow();
}
defaultproperties
{
}
