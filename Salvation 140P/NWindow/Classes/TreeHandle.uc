/**
*트리형태의 컨트롤들의 기본적 기능(노드삽입, 삭제, travelsal 등)을 정의(퀘스트 트리등에 사용된바 있다.)
*/

class TreeHandle extends WindowHandle
	native;

/**
*트리에  infNode정보를 지니는 새로운 노드를 삽입한다.
*infNode는 구조체로써 strName이라는 멤버을 지니는데 이로써 Identification을 한다
*strParentName을 strName으로 가지는 노드의 하위노드로써 새로운 노드가 생성된다
*동일한 이름의 노드가 있으면 실패한다.
*strParentName이 빈 스트링("") 인경우 새로생성된 노드가 Root가 된다.
* @param
*strParentName 부모노드의 이름
*infNode 생성할 노드의 정보를 담은 구조체

* @return
*string
*노드 생성 성공시 새로생긴 노드의 strName을 리턴(pull path로 리턴 ex:root.child1.child2)
*노드 생성 실패시 NULL을 리턴

* @example
*var TreeHandle	MainTree;
*var XMLTreeNodeInfo infNode;
*var string strRetName;

*MainTree = GetTreeHandle("QuestTreeWnd.MainTree1");
*infNode.strName = "root";
*strRetName = MainTree.InsertNode("", infNode); //1st param이 "" 이므로 루트노드가 된다
*infNode.strName = "child1";
*strRetName = MainTree.InsertNode("root", infNode); //앞서서 생성된 "root"노드의 child 노드가 된다. 리턴값은 "root.child1" 이된다
*/
	
native final function string InsertNode(string strParentName, XMLTreeNodeInfo infNode);

/**
*NodeName을 이름으로 가지는 노드에 아이템을 삽입한다.(노드는 아이템리스트를 각각 유지한다)
* @param
*NodeName : 아이템을 담을 노드의 이름
*infNodeItem : 노드에 저장할 아이템

* @return
*void

* @example
*var TreeHandle	MainTree; // 트리선언
*var XMLTreeNodeInfo infNode;
*var string strRetName;
*var XMLTreeNodeItemInfo infNodeItem;

*MainTree = GetTreeHandle("QuestTreeWnd.MainTree1");
*infNode.strName = "root";
*strRetName = MainTree.InsertNode("", infNode); //root 노드를 삽입한다.
*infNodeItem.t_nTextID = 0;
*infNodeItem.eType = XTNITEM_TEXT;
*infNodeItem.t_strText = strRetName;
*........								//아이템을 셋팅한다. 아이템의 ID=0, 타입은 text, str은 root
*........
*MainTree.InsertNodeItem("root", infNodeItem); // root노드에 아이템을 단다
*/

native final function InsertNodeItem(string NodeName, XMLTreeNodeItemInfo infNodeItem);

/**
*트리를 클리어하고 모든 메모리를 해지한다.
* @param
*void

* @return
*void

* @example
*var TreeHandle	MainTree; // 트리선언
*MainTree = GetTreeHandle("QuestTreeWnd.MainTree1");
*.... // 계속 트리를 마음대로 사용하다가
*....
*MainTree.Clear(); // 트리를 다시 초기화

*/
native final function Clear();

/**
*노드의 expanded상태(펼침)을 설정한다.
* @param
*void

* @return
*void

* @example
*var TreeHandle	MainTree;
*var XMLTreeNodeInfo infNode;
*var string strRetName;

*MainTree = GetTreeHandle("QuestTreeWnd.MainTree1");
*infNode.strName = "root";
*strRetName = MainTree.InsertNode("", infNode);//root 노드를 삽입한다.
*infNode.strName = "child1";
*strRetName = MainTree.InsertNode("root", infNode); // root에 child1을 달았다
*infNode.strName = "child2";
*strRetName = MainTree.InsertNode("root.child2", infNode); // root.child1에 child2를 달았다
*MainTree.SetExpandedNode("root.child1", true); // 펼친다. child2가 열린다.
*MainTree.SetExpandedNode("root.child1", false); // 닫는다. child2가 닫힌다.
*/

native final function SetExpandedNode(string NodeName, bool bExpanded);

/**
*노드의 expanded된 child들의 이름을 반환한다.
* @param
*NodeName : 검색할 노드의 이름

* @return
*string : expanded 된 child들의 이름(여러개일 경우 "|" 로 이어진다);

* @example
*var TreeHandle	MainTree;
*var XMLTreeNodeInfo infNode;
*var string strRetName;

*MainTree = GetTreeHandle("QuestTreeWnd.MainTree1");
*infNode.strName = "root";
*strRetName = MainTree.InsertNode("", infNode);
*infNode.strName = "child1";
*strRetName = MainTree.InsertNode("root", infNode); // root에 child1을 달았다
*infNode.strName = "child2";
*strRetName = MainTree.InsertNode("root.child2", infNode); // root.child1에 child2를 달았다
*MainTree.SetExpandedNode("root.child1", true); // 펼친다. child2가 열린다.
*strRetName = MainTree.GetExpandedNode("root", false); // "root.child1" 이 리턴된다(열었기 때문)
*/

native final function string GetExpandedNode(string NodeName);

/**
* 지정된 이름의 노드를 삭제한다.(이름이 Full Path라는 것에 주의하자. child1을 root에 달면 "root.child1"이라는 이름으로 지워야한다)
* @param
* NodeName : 지울 노드의 이름

* @return
* void

* @example
*var TreeHandle	MainTree;
*var XMLTreeNodeInfo infNode;
*var string strRetName;

*MainTree = GetTreeHandle("QuestTreeWnd.MainTree1");
*infNode.strName = "root";
*strRetName = MainTree.InsertNode("", infNode);//root 노드를 삽입한다.
*infNode.strName = "child1";
*strRetName = MainTree.InsertNode("root", infNode); // root에 child1을 달았다
*MainTree.DeleteNode("root.child1"); // 지운다
*/

native final function bool DeleteNode(string NodeName);

/**
* 지정된 이름을 지닌 노드가 존재하는지 여부를 리턴한다
* @param
* NodeName : 존재 여부를 판단할 이름

* @return
* bool : 존재한다면 true 없다면 false

* @example
*var TreeHandle	MainTree;
*var XMLTreeNodeInfo infNode;
*var string strRetName;

*MainTree = GetTreeHandle("QuestTreeWnd.MainTree1");
*infNode.strName = "root";
*strRetName = MainTree.InsertNode("", infNode); //root 노드를 삽입한다.
*infNode.strName = "child1";
*strRetName = MainTree.InsertNode("root", infNode); // root에 child1을 달았다
*if(MainTree.IsNodeNameExist("root.child1")) debug("Exist Node"); //root.child1이라는 노드가 있다면 출력한다.
*else debug("Never reach"); //없다면 출력한다. (위에서 child1을 달았으므로 출력되지 않는다)
*/

native final function bool IsNodeNameExist(string NodeName);

/**
* 지정된 이름의 노드가 Expanded(펼쳐짐) 된 여부를 리턴한다.
* @param
* NodeName : Expanded(펼쳐짐) 여부를 판단할 노드의 이름

* @return
* bool : Expanded(펼쳐짐)되어 있다면 true 없다면 false

* @example
*var TreeHandle	MainTree;
*var XMLTreeNodeInfo infNode;
*var string strRetName;

*MainTree = GetTreeHandle("QuestTreeWnd.MainTree1");
*infNode.strName = "root";
*strRetName = MainTree.InsertNode("", infNode);//root 노드를 삽입한다. root 는 기본 셋팅이 expanded 이다.
*if(IsExpandedNode("root")) debug("root is always opened."); //root는 expanded 되어있으므로 출력된다.
*else debug("Nerver reach") //출력되지 않는다.
*/

native final function bool IsExpandedNode(string NodeName);

/**
* 지정된 노드의 자식노드들의 이름을 리턴한다. 자식이 여러개일 경우 "|" 로 이어진다.
* @param
* NodeName :자식들을 살펴볼 노드의 이름

* @return
* string : 자식노드들의 이름. 자식이 여러개일 경우 "|" 로 이어진다.

* @example
*var TreeHandle	MainTree;
*var XMLTreeNodeInfo infNode;
*var string strRetName;

*MainTree = GetTreeHandle("QuestTreeWnd.MainTree1");
*infNode.strName = "root";
*strRetName = MainTree.InsertNode("", infNode);//root 노드를 삽입한다.
*infNode.strName = "child1";
*strRetName = MainTree.InsertNode("root", infNode); // root에 child1을 달았다
*infNode.strName = "child2";
*strRetName = MainTree.InsertNode("root", infNode); // root에 child2를 달았다
*strRetName = MainTree.GetChildNode("root"); // root의 자식노드들을 얻는다
*debug(strRetName); // root.child1|root.child2 가 출력된다.
*/

native final function string GetChildNode(string NodeName);

/**
* 지정된 노드의 부모노드의 이름을 리턴한다.
* @param
* NodeName :부모를 살펴볼 노드의 이름

* @return
* string : 부모노드의 이름.

* @example
*var TreeHandle	MainTree;
*var XMLTreeNodeInfo infNode;
*var string strRetName;

*MainTree = GetTreeHandle("QuestTreeWnd.MainTree1");
*infNode.strName = "root";
*strRetName = MainTree.InsertNode("", infNode);//root 노드를 삽입한다.
*infNode.strName = "child1";
*strRetName = MainTree.InsertNode("root", infNode); // root에 child1을 달았다
*strRetName = MainTree.GetParentNode("root.child1"); // root.child1 의 부모노드를 얻는다
*debug(strRetName); // root 가 출력된다.
*/

native final function string GetParentNode(string NodeName);

/**
* 스크롤바의 show 여부를 셋팅한다.
* @param
* bShow : true면 show, false면 hide

* @return
* void

* @example
*var TreeHandle	MainTree;
*var XMLTreeNodeInfo infNode;
*var string strRetName;

*MainTree = GetTreeHandle("QuestTreeWnd.MainTree1");
*infNode.strName = "root";
*strRetName = MainTree.InsertNode("", infNode);//root 노드를 삽입한다.
*MainTree.ShowScrollBar(true); //스크롤바를 보여준다
*MainTree.ShowScrollBar(false); //스크롤바를 숨긴다
*/

native final function ShowScrollBar(bool bShow);
 
//For Text Item

/**
* 노드에 달려있는 아이템의 텍스트를 수정한다.
* @param
* NodeName : 노드의 이름
* nTextID : 아이템의 ID
* strText : 아이템의 텍스트

* @return
* void

* @example
*var TreeHandle	MainTree; // 트리선언
*var XMLTreeNodeInfo infNode;
*var string strRetName;
*var XMLTreeNodeItemInfo infNodeItem;

*MainTree = GetTreeHandle("QuestTreeWnd.MainTree1");
*infNode.strName = "root";
*strRetName = MainTree.InsertNode("", infNode); //root 노드를 삽입한다.
*infNodeItem.t_nTextID = 0;
*infNodeItem.eType = XTNITEM_TEXT;
*infNodeItem.t_strText = strRetName;	
*........								//아이템을 셋팅한다. 아이템의 ID=0, 타입은 text, str은 root
*........
*MainTree.InsertNodeItem("root", infNodeItem); // root노드에 아이템을 단다
*MainTree.SetNodeItemText("root", 0, "rootroot"); // root노드의 아이템중 0번 아이템의 str을 rootroot로 수정한다.
*/

native final function SetNodeItemText(string NodeName, int nTextID, string strText);

// nType 0: Texture, 1:MouseOnTexture, 2:ExpandedTexture
native final function SetNodeItemTexture(string NodeName, int nTextID, string strTexture, int nWidth, int nHeight, int nType);
defaultproperties
{
}
