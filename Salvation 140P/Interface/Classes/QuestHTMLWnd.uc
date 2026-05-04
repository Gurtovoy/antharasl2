/**
 *  퀘스트 대화창 (보상)
 *  
 *  강아름, 최초 제작 된 걸 수정 (중국 상해 버전)
 *  
 **/

class QuestHTMLWnd extends UICommonAPI;


const HTML_WIDTH    = 400;
const TABLEBG_WIDTH = 272;

var WindowHandle 	Me;
var HtmlHandle		m_hHtmlViewer;
var bool			m_bDrawBg;

//
var bool			m_bPressCloseButton;
var bool			m_bReShowWndMode;
var bool			m_bReShowQuestHtmlWnd;	

var string          htmlString;
var int             htmlWidth;


var int bicIconLen; 

function OnRegisterEvent()
{
	RegisterEvent(EV_QuestHtmlWndShow);
	RegisterEvent(EV_QuestHtmlWndHide);
//	RegisterEvent(EV_NPCDialogWndHide);
	RegisterEvent(EV_QuestHtmlWndLoadHtmlFromString);
	RegisterEvent(EV_QuestIDWndLoadHtmlFromString);
	
	// register gamingstate enter/exit event 
	// - 등록하지 않으면, 처음 호출될때 OnEnter와 OnExit가 호출되지 않음.
	RegisterEvent(EV_GamingStateEnter);
	RegisterEvent(EV_GamingStateExit);
} 

function OnLoad()
{
	SetClosingOnESC(); 
	//getInstanceUIData().addEscCloseWindow(getCurrentWindowName(string(Self)));

	OnRegisterEvent();

	Me=GetWindowHandle("QuestHTMLWnd");
	m_hHtmlViewer=GetHtmlHandle("QuestHTMLWnd.HtmlViewer");
}

function onShow ()
{
	getInstanceL2Util().syncWindowLoc(getCurrentWindowName(string(Self)), "QuestHTMLWnd,NPCDialogWnd");
}

function OnHide()
{
	ProcCloseQuestHTMLWnd();
	getInstanceL2Util().syncWindowLocAuto("QuestHTMLWnd,NPCDialogWnd");
}

function OnDefaultPosition()
{
	// empty
}

function OnEvent(int Event_ID, String param)
{
	switch(Event_ID)
	{
		case EV_QuestHtmlWndShow :
			ShowQuestHtmlWnd();
			break;
			
		case EV_QuestHtmlWndHide :	
			HideQuestHtmlWnd();
			break;
			
		case EV_QuestHtmlWndLoadHtmlFromString :
			Me.SetWindowTitle(GetSystemString(444));	 //타이틀을 "대화"로 바꿔준다. 
			HandleLoadHtmlFromString(param);
			break;
			
		case EV_QuestIDWndLoadHtmlFromString:
			HandleQuestIDLoadHtmlFromString(param);
			break;

			// 19
		case EV_Test_9:
			m_hHtmlViewer.LoadHtmlFromString( param);
			break;

	}
}

// 미국 xp 표현을 위해서..
function int getLanguageNumber()
{
	local ELanguageType Language;	
	local int languageNum;

	Language = GetLanguage();
		
	switch( Language )
	{	
		case LANG_Korean:
			languageNum = 0;
			break;	
		case LANG_English:
			languageNum = 1;
			break;
		case LANG_Japanese:
			languageNum = 2;
			break;
		case LANG_Taiwan:
			languageNum = 3;
			break;
		case LANG_Chinese:	
			languageNum = 4;
			break;
		case LANG_Thai:		
			languageNum = 5;
			break;
		case LANG_Philippine:
			languageNum = 6;
			break;
		case LANG_Indonesia:
			languageNum = 7;
			break;
		case LANG_Russia:	
			languageNum = 8;
			break;
		case LANG_Euro:	
			languageNum = 9;
			break;
		case LANG_Germany:	
			languageNum = 10;
			break;
		case LANG_France:	
			languageNum = 11;
			break;
		case LANG_Poland:	
			languageNum = 12;
			break;
		case LANG_Turkey:	
			languageNum = 13;
			break;
		//end of branch
		default:
			languageNum = 0;
			break;
	}	

	return languageNum;		

}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 2.3 보상수정
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function HandleQuestIDLoadHtmlFromString(string param)
{
	local int QuestID;
	local Array<int> rewardIDList;
	local Array<INT64> rewardNumList;
		
	local int i;
	local string addItemHtml, iconName, itemText, itemName;

	local string rewardSmallIconHtml, rewardMsgHtml, rewardEndMsgHtml;

	local int tableIndex, smallIconIndex;

	ParseInt(param, "QuestID", QuestID);
	
	class'UIDATA_QUEST'.static.GetQuestReward(QuestID, 1, rewardIDList, rewardNumList);

	tableIndex = 0;
	smallIconIndex = 0;
	bicIconLen = 0;

	rewardSmallIconHtml = "<table width=278 border=0 cellpadding=0 cellspacing=1 background=L2UI_CT1.HtmlWnd.HTMLWnd_GroupBox_DF_Center>";
	

	for ( i = 0 ; i < rewardIDList.Length ; i++ )
	{
		if ( rewardIDList[i] != 57 && rewardIDList[i] != 15623 && rewardIDList[i] != 15624 && rewardIDList[i] != 47130)
		{
			bicIconLen++;
		}
	}
	
	if (bicIconLen == 1)
	{
		rewardMsgHtml = "<table width=278 border=0 cellpadding=0 cellspacing=1 background=L2UI_CT1.HtmlWnd.HTMLWnd_GroupBox_DF_Center>";
	}
	else
	{
		rewardMsgHtml = "<table width=278 border=0 cellpadding=0 cellspacing=1 background=L2UI_CT1.HtmlWnd.HTMLWnd_GroupBox_DF_Center>";
	}

	if ( rewardIDList.length > 0 )
	{
		for( i = 0 ; i < rewardIDList.Length ; i++ )
		{

			if( i == 0 )
			{
				//addItemHtml = htmlTableAdd( "L2UI_CT1.HtmlWnd.HTMLWnd_GroupBox_DF_Up" ) $ 
				//			  "<font color=\"d4af6f\" name=name=GameDefault>" $ GetSystemString(1127) $ "</font>" $ 
				//			  "<br1><img src=L2UI_CT1.Divider.Divider_DF_Ver width=286 height=2><br1></td></tr></table>"; // 보상

				addItemHtml = // htmlTableAdd( "L2UI_CT1.HtmlWnd.HTMLWnd_GroupBox_DF_Up" ) $ 
							  "<br>" $
							  htmlTableAdd( "L2UI_CT1.GroupBox.GroupBox_DF" ) $ 					
							  "<font color=\"ffcc00\" name=chatFontSize10>" $ GetSystemString(2006) $ "</font>" $ "</td></tr></table>"; // 보상 아이템
			}
							  
							  //"<br1><img src=L2UI_CT1.Divider.Divider_DF_Ver width=274 height=2><br></td></tr></table>"; // 보상


			switch (rewardIDList[i])
			{
				case 57: // 아데나 iconName = class'UIDATA_ITEM'.static.GetItemTextureName(GetItemID(57));	
				case 15623: // 경험치
				case 15624: // sp, 스킬포인트
				case 47130: // 우호도 포인트
					itemName = class'UIDATA_ITEM'.static.GetItemName(GetItemID(rewardIDList[i]));
					if( rewardIDList[i] == 57 )
					{
						iconName = "L2UI_CT1.HtmlWnd.HTMLWnd_adena";
						itemName = GetSystemString(469);
					}
					else if( rewardIDList[i] == 15623 )
					{
						if (getLanguageNumber() == 1)
						{
							// 미국 
							// 추후에 xp 아이콘으로 대체 하면 될듯..
						}

						iconName = "L2UI_CT1.HtmlWnd.HTMLWnd_EXP";
					}
					else if(  rewardIDList[i] == 15624 )
					{
						iconName = "L2UI_CT1.HtmlWnd.HTMLWnd_SP";
					}

					// 2015-11-23 FP 추가 (작은 아이콘)
					else if(  rewardIDList[i] == 47130 )
					{
						iconName = "L2UI_CT1.HtmlWnd.HTMLWnd_FP";
					}


					//미정
					if (rewardNumList[i] == 0)
					{
						itemText = GetSystemString(584);
					}
					else
					{
						// SP 인 경우 
						if (rewardIDList[i] == 15624)
						{
							//itemText = string(getInstanceUIData().getSPChangedValue(rewardNumList[i]));
							itemText = (MakeCostString(String(rewardNumList[i])));
							// Debug("sp rewardNumList[i]" @ rewardNumList[i]);
						}
						// 그외
						else
						{
							itemText = (MakeCostString(String(rewardNumList[i])));
						}
					}

					//$ " itemtooltip=\"" $ rewardIDList[i] $ "\"" 
					//rewardSmallIconHtml = rewardSmallIconHtml $ "<tr><td width=38 height=22 align=center valign=center><button width=32 height=16"											  
					//					  $	" back=\"" $ iconName $ "\"" $ " high=\"" $ iconName $ "\"" $ " fore=\"" $ iconName $ "\"></td><td height=22 width=246><font color=ba8860>" 
					//					  $ itemText $"</font>" @ htmlfontAdd(itemName) $ "</td></tr>";

					rewardSmallIconHtml = rewardSmallIconHtml $ "<tr><td width=38 height=22 align=center valign=center><Img width=32 height=16"											  
										  $	" src=\"" $ iconName $ "\"" $ "></td><td height=22 width=236><font color=ba8860>" 
										  $ itemText $"</font>" @ htmlfontAdd(itemName) $ "</td></tr>";

					smallIconIndex = smallIconIndex + 1;
					break;

				default:
					iconName = class'UIDATA_ITEM'.static.GetItemTextureName(GetItemID(rewardIDList[i]));
					itemName = class'UIDATA_ITEM'.static.GetItemName(GetItemID(rewardIDList[i]));

					// Debug("iconName" @ iconName);
					// Debug("rewardIDList[i]"  @ rewardIDList[i]);

					//아이템 개수
					if (rewardNumList[i] == 0)
					{
						itemText = htmlfontAdd( GetSystemString(584), "ba8860" ); // 미정
					}
					else
					{
						// 아래에 해당하는 경우 몇 "개" 표시가 안되어야 한다.
						if (rewardIDList[i] == 15623 ||   // 경험치  
							rewardIDList[i] == 15624 ||   // 스킬 포인트
							rewardIDList[i] == 15625 ||   // 물음표        
							rewardIDList[i] == 15626 ||   // 활력 포인트
							rewardIDList[i] == 15627 ||   // 혈맹 포인트
							rewardIDList[i] == 15628 ||   // 랜덤 보상
							rewardIDList[i] == 15629 ||   // 정산형 보상
							rewardIDList[i] == 15630 ||   // 추가 보상
							rewardIDList[i] == 15631 ||   // 서브 클래스 권한 획득
							rewardIDList[i] == 15632 ||   // PK 카운트 하락 
							rewardIDList[i] == 15633)
						{
							itemText = htmlfontAdd((MakeCostString(string(rewardNumList[i]))), "ba8860");
						}
						else
						{    
							// $1개
							itemText =MakeFullSystemMsg(htmlfontAdd(GetSystemMessage(1983)), htmlfontAdd((MakeCostString(string(rewardNumList[i]))),"ba8860"),"");
						}
					}

					// 한국과 같다면.. 두칸으로 보상 아이템
					if (getLanguageNumber() == 0)
					{
						// 큰사이즈 아이콘이 하나일때 말줄임표 안되게 
						if( bicIconLen == 1 )
						{
							//rewardMsgHtml = rewardMsgHtml $ "<tr><td align=center valign=center width=1 height=32></td>" 
							rewardMsgHtml = rewardMsgHtml $ "<tr>" 
											$ "<td width=2 height=32></td><td align=center valign=center width=32 height=32><button width=32 height=32" 
											$ " itemtooltip=\"" $ rewardIDList[i] $ "\"" $ " back=\"" $ iconName $ "\"" $ " high=\"" $ iconName 
											$ "\"" $  " fore=\"" $ iconName $ "\"></button></td><td width=1 height=32></td><td width=234 height=32>" $ htmlfontAdd(itemName) 
											$ "<br1>"$ itemText $ "</td></tr>";
						}
						else
						{
							if( rewardIDList.Length > 0 && len(itemName) > 8 )
							{
								itemName = mid(itemName, 0 , 8) $ "..";
							}

							if( tableIndex % 2 > 0 ) // 첫번째 
							{
								rewardMsgHtml = mid(rewardMsgHtml, 0 , len(rewardMsgHtml)-5);
								rewardMsgHtml = rewardMsgHtml
												$ "<td align=center valign=center width=32 height=32><button width=32 height=32" 
												$ " itemtooltip=\"" $ rewardIDList[i] $ "\"" $ " back=\"" $ iconName $ "\"" $ " high=\"" $ iconName 
												$ "\"" $  " fore=\"" $ iconName $ "\"></td><td width=110 height=32></button>" $ htmlfontAdd(itemName) 												
												$ "<br1>"$ itemText $ "<br1>" $"</td></tr>";
							}
							else 
							{
								// 간격 조정은 htmlTableTrAdd 함수 에서..
								rewardMsgHtml = rewardMsgHtml $ htmlTableTrAdd() $  "<tr><td align=center valign=center width=32 height=32><button width=32 height=32" 
												$ " itemtooltip=\"" $ rewardIDList[i] $ "\"" $ " back=\"" $ iconName $ "\"" $ " high=\"" $ iconName 
												$ "\"" $  " fore=\"" $ iconName $ "\"></button></td><td width=110 height=32>" $ htmlfontAdd(itemName) 
												$ "<br1>"$ itemText $ "</td></tr>";
							}
						}
					}
					else
					{
						// 해외는 한줄로 보상 아이템이 나오도록 변경
						itemName = makeShortStringByPixel(itemName, 230, "..");
						rewardMsgHtml = rewardMsgHtml $ "<tr>" 
										$ "<td width=2 height=32></td><td align=center valign=center width=32 height=32><button width=32 height=32" 
										$ " itemtooltip=\"" $ rewardIDList[i] $ "\"" $ " back=\"" $ iconName $ "\"" $ " high=\"" $ iconName 
										$ "\"" $  " fore=\"" $ iconName $ "\"></button></td><td width=1 height=32></td><td width=234 height=32>" $ htmlfontAdd(itemName) 
										$ "<br1>"$ itemText $ "</td></tr>";
					}

					/// Debug("iconName" @ iconName);
					tableIndex = tableIndex + 1;
			}
			// tableIndex = tableIndex + 1;
			
		}

		///////// 리스트 없을 경우 삭제////////////////////////////////////
		if( tableIndex > 0 )
		{
			rewardMsgHtml = rewardMsgHtml $ "</table>";
		}
		else
		{
			rewardMsgHtml = "";
		}

		if( smallIconIndex > 0 )
		{
			rewardSmallIconHtml = rewardSmallIconHtml $ "</table>";
		}
		else
		{
			rewardSmallIconHtml = "";
		}
		/////////////////////////////////////////////////////////////////////
		
		htmlString = mid(htmlString, 6, len(htmlString)); //<html> 테그 삭제
		htmlString = mid(htmlString, 0, len(htmlString) - 7); //</html> 테그 삭제
		
		if (bicIconLen == 1)
			rewardEndMsgHtml = "<table width=277 border=0 cellpadding=0 cellspacing=1 background=L2UI_CT1.HtmlWnd.HTMLWnd_GroupBox_DF_Down><tr><td width=277></td></tr></table>";
		else		
			rewardEndMsgHtml = "<table width=277 border=0 cellpadding=0 cellspacing=1 background=L2UI_CT1.HtmlWnd.HTMLWnd_GroupBox_DF_Down><tr><td width=277></td></tr></table>";
		//rewardEndMsgHtml = "<table width=290 border=0 cellpadding=0 cellspacing=3 background=L2UI_Ct1_Cn.Deco.TitleBaseBarMini_HtmlTableDown><tr><td width=290></td></tr></table>";

		addItemHtml = htmlString $ addItemHtml $ rewardSmallIconHtml $ rewardMsgHtml $ rewardEndMsgHtml;

		addItemHtml =  "<html><body>" $ addItemHtml $ "</body></html>";
		//addItemHtml =  "<html><body>" $ addItemHtml $ "<br><table border=0 cellpadding=0 cellspacing=3 width=288 ><tr><td height=15 align=center valign=center><img src=L2UI_CT1_CN.Deco.Horizontal_Deco width=286 height=8></td></tr><tr><td></td></tr></table></body></html>";
		//addItemHtml =  "<html><body>" $ addItemHtml $ "<br><table border=0 cellpadding=0 cellspacing=2 width=274 ><tr></tr><tr><td></td></tr></table></body></html>";
		//addItemHtml =  "<html><body>" $ addItemHtml $ "<br><table border=0 cellpadding=0 cellspacing=3 width=288 ><tr><td height=15 align=center valign=center></td></tr><tr><td></td></tr></table></body></html>";

		m_hHtmlViewer.LoadHtmlFromString( addItemHtml);
	}	

	Me.ShowWindow();
	Me.SetFocus();
}

function string htmlTableAdd( optional string backgroundUrl )
{
	local string htmlStr;

	if( backgroundUrl == "" ) 
		htmlStr = "<table width=278 cellpadding=0 border=0 cellspacing=1" $ "><tr><td width=278>";
	else 
		htmlStr = "<table width=278 cellpadding=0 border=0 cellspacing=1 background="$ backgroundUrl $"><tr><td width=272>";
		// backgroundUrl = "L2UI_Ct1_Cn.Deco.TitleBaseBarMini";

	return htmlStr;
}

function string htmlTableTrAdd()
{
	return "<tr><td width=46 ></td><td width=115 ></td><td width=46 ></td><td width=115 ></td></tr>";
}

function string htmlfontAdd( string strText, optional string fontColor )
{
	local string targetHtml;
	if( fontColor == "" ) fontColor = "d3c5ae";
	
	targetHtml = "<font color=\"" $ fontColor $ "\"" $ ">" $ strText $ "</font>";

	return targetHtml;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function OnHtmlMsgHideWindow(HtmlHandle a_HtmlHandle)
{
	if(a_HtmlHandle==m_hHtmlViewer)
	{
		HideQuestHTMLWnd();
	}
}

function HandleLoadHtmlFromString(string param)
{
	
	ParseString(param, "HTMLString", htmlString);

	m_hHtmlViewer.LoadHtmlFromString(htmlString);
	
	// Debug("HandleLoadHtmlFromString ----- " $ htmlString);
}


function ShowQuestHTMLWnd()
{
	ExecuteEvent(EV_NPCDialogWndHide);
	Me.ShowWindow();
	Me.SetFocus();
	m_bReShowQuestHTMLWnd = true;
}

function HideQuestHTMLWnd()
{			
	Me.HideWindow();
	m_bReShowQuestHTMLWnd = false;
}

function OnClickButton( string Name )
{
	PressCloseButton();
}


function OnExitState( name a_NextStateName )
{
	
	if( a_NextStateName == 'NpcZoomCameraState')
	{
		Clear();
		m_bReShowWndMode = true;
	}
}

function OnEnterState( name a_PreStateName )
{		
	
	if( a_PreStateName == 'NpcZoomCameraState' )
	{
		ReShowQuestHTMLWnd();
		Clear();	
	}
}

function Clear()
{
	//
	m_bReShowWndMode	= false;	
	m_bPressCloseButton = false;
	m_bReShowQuestHtmlWnd = false;
}

function PressCloseButton()
{
	// press close button
	if( m_bReShowWndMode )
	{
		m_bPressCloseButton = true;
	}
}

function ProcCloseQuestHTMLWnd()
{	
	if( m_bPressCloseButton && m_bReShowWndMode && m_bReShowQuestHTMLWnd)
	{
		// must first m_bReShowQuestHTMLWnd be false because calling recursive function.
		m_bReShowWndMode = false;		
		RequestFinishNPCZoomCamera();		
	}
}

function ReShowQuestHTMLWnd()
{
	if( m_bReShowWndMode && m_bReShowQuestHTMLWnd )
	{
		ShowQuestHTMLWnd();			
	}	
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	PressCloseButton();
	GetWindowHandle( "QuestHTMLWnd" ).HideWindow();
}
defaultproperties
{
}
