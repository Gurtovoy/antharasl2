// 상해 버전과 머징 하여 Html 기능 및 상하폭 조절 기능 개선
/*
	htmlStr = htmlStr $"<br1>" $ htmlAddText("1니야옹 설명을 어쩌구 어쩌구sdfsadlkfjasdflkjasdlkfjasdlkfjaslkfjasfasfsdafasdfsafasdfdasasfsadfasdfasdfsad", "hs9", "F0FF43") $ "<br1>" $
				  htmlAddText("2니야옹 설명을 어쩌구 어쩌구", "hs9", "F0FF43") $ htmlUrlLinkText("고객지원","http://70.2.1.96/wiki/moin.cgi/clienthtml") $ 
				  htmlUrlLinkText("고객지원abcde","70.2.1.96/wiki/moin.cgi/clienthtml") $ 
				  "<br>test1234 <a action=\"url http://lineage2.plaync.com\"> link text</a><br>" $
				  "<br><a link=\"..\L2text\pet_help_suggest.htm\">뒤로</a><br>" $
				  htmlAddButton("하이", "url www.naver.com", 0, 0, 15, 15) $
				  htmlAddButton("하이", "url http://www.naver.com", 0, 0, 15, 15);


	//htmlStr = "<br1><font name='hs9' color='FFDF4C'>아인하사드</font> <font name=\"hs9\" color='00DF4C'>크론비스트</font>의 힘을 받았다. 가공할 명중력과 공격력으로 그들의 적에게 공포를 주었고 특히, 그들의 가공할 연사 속도는 적들이 접근하기 전에 그들을 영원한 안식에 들게 했다.";

	htmlStr = "<font name=\"hs9\" color=\"FFDF4C\">아인하사드</font>";

	DialogHide();
	DialogSetID( 123456 );	
	
	DialogShow(DialogModalType_Modalless,DialogType_Warning, htmlStr $ "<br>" $ htmlAddLineImg(), string(Self), 400, 300, true);
*/

/*------------------------------------------------------------------------------------------------------------------------------------------------------------
  - 특이 사항 
   프로그레시브 다이얼로그 박스의 경우 이전 dialogID와 target 값을 저장 시키고, 프로그레시브 다이얼로그가 진행 중일때 다른 다이얼로그 창이 열리면
   해당 다이얼로그 박스의 캔슬을 해주는 부분을 추가 했다.

	관련 TTP (p4 히스토리) 2014.10.2
	[qa필요]ttp66530, 66531 교환, 결투, 멘티초대, 커플 액션, 파티 아이템 습득 변경, 블럭 체커 투표가 해당 TTP와 동일한 문제가 있는 것을 수정했습니다.
	UI, XML 로 제작된 다이얼로그 진행바 UI가 나와 있는 상태에서 리스타트나 닫기 등 다른 XML 다이얼로그 박스가 나오면 이전에 있던 다이얼로그 박스가
	사라지면서, 진행 중 이라는 상태를 취소가 안되는 문제 입니다.

	따라서 XML로 제작된 진행바가 달린 다이얼로그 전체에 대해서 수정을 했습니다. 
------------------------------------------------------------------------------------------------------------------------------------------------------------*/



class DialogBox	extends UICommonAPI;

const INPUT_DEFAULT_MAXLENGTH = 64;


//선준 수정(2010.03.03)
// 12.07.23 전체길이 수정할수 있게 변경 
var int INPUT_NUMBERPAD_MAXLENGTH; //= 14;

var WindowHandle	m_dialogBody;
var WindowHandle	m_dialogHandle;
var ButtonHandle	m_okHandle;
var ButtonHandle	m_cancelHandle;
var ButtonHandle	m_centerHandle;
var EditBoxHandle	m_editHandle;
var TextBoxHandle	m_textHandle;
//var UIScript	m_hostWndScript;

var string		m_strTargetScript;
var string		m_strEditMessage;
var EDialogType	m_type;
var int			m_id;
//var bool		m_bInUse;
var INT64		m_paramInt;
var int			m_reservedInt;
var INT64		m_reservedInt2;
var int			m_reservedInt3;
var ItemID		m_reservedItemID;
var ItemInfo	m_reservedItemInfo;
var string      m_reservedString;
var int			m_editMaxLength;					// editbox의 maxLength를 지정해 준다(일회용). 새 다이얼로그를 띄우면 xml에서 지정한 기본으로 돌아감. -1이 아니라면 값이 세팅된 것이다.
var int			m_editMaxLength_prev;				// 이전 길이를 기억해 주기 위한 변수.

var int         buttonWidth_prev;                   // 이전 버튼 가로 사이즈
var int         buttonHeight_prev;                  // 이전 버튼 세로 사이즈

var int         NumberPad_DefaultValue;
var int64       NumberPad_Value;

var DialogDefaultAction		m_defaultAction;			// Which action to take, when "Enter" key is pressed.
var DialogEnterAction		m_enterAction;

var ProgressCtrlHandle	m_hDialogBoxDialogProgress;

var bool		m_bGlobalIME; //branch121212

var TextureHandle m_exclamationImage;
var HtmlHandle   m_HtmlViewer;

// 최초 다이얼로그 사이즈
var Rect defaultBodyRect;


// 다이얼로그에서 캐슬할 프로그레스바가 있다면 해당 ID를 저장해서, ok, cancel 할때 초기화
// 열때 tryCancelDialogID가 -1 보다 크다면 초기화
var int tryCancelDialogID;
var int saveCancelDialogID;
//var bool bSaveCancelDialogID;

//public
//		only public functions should be exposed to other scripts.
//		Functions in DialogBox.uc should not be used directly by other scripts. They should use them through UICommonAPI.
//

/**
 *  용두 관련 하드 코딩 : 담당 기획자 이신희 
 *  
 *  추후에 html 테그를 검색해서, 자동으로 html모드인지, text 필드 인지 구분 하는 것도 괜찮을듯..
 *  현재는 새로 폭 때문에 일단 하드 코딩으로 처리 
 *  
 **/ 
function bool isHardCodingSystemMessage(string message)
{
	local array<string>	ArrayStr;
	local string targetString;
	local int i;
	
	// 관련 아이템 번호
	// 41878
	//	~
	// 41913

	// 중국 버전 하드코딩이라 주석처리
	// 운명의 xx 용두상 같은 것들..
	// targetString = "7447,7448,7449,7450";

	Split(targetString, ",", ArrayStr);

	for (i = 0; i < ArrayStr.Length; i++)
	{
		// Debug("GetSystemMessage(int(arrayStr[i]))" @ int(arrayStr[i]));
		if (GetSystemMessage(int(arrayStr[i])) == message)
		{
			return true;
		}
	}

	return false;
}

function OnEnterState( name a_PreStateName )
{
	// 연출씬이 나올때 다이얼로그는 ok, cancel이 안되고 그냥 하이드가 된다. 그래서 문제가 발생하는데..
	// 연출씬이 끝나고 들어 올때 캔슬을 해주는 방법밖에는 현재 없다. 
	if (tryCancelDialogID > -1) 
	{
		HideDialog();
	}
}

function setDialogCancelD(int targetCancelDialogID)
{
	//tryCancelDialogID = targetCancelDialogID;

	saveCancelDialogID = targetCancelDialogID;
}

// bUseHtml 를 true 로 하면 message에 htmlViewer 쪽으로 값을 넣도록 처리 한다.
function ShowDialog( EDialogModalType modalType, EDialogType style, string message, string target, optional int widthSizeChangeValue, optional int heightSizeChangeValue, optional bool bUseHtml)
{
	local ELanguageType Language;	 //branch121212

	// 기획자 : 이신희 
	// OpenGivenURL( Url );	
	if (isHardCodingSystemMessage(message))
	{
		// 용두상은 html 로 보이도록 세팅 
		bUseHtml = true;
		heightSizeChangeValue = 186;
	}
		
	//if( m_bInUse )
	//{
	//	debug("Error!! DialogBox in Use");
	//	return;
	//}
	if (modalType == DialogModalType_Modal)
	{
		m_dialogHandle.SetModal(true);
	}
	else if (modalType == DialogModalType_Modalless)
	{
		m_dialogHandle.SetModal(false);
	}

	if (tryCancelDialogID > -1)
	{
		HandleCancel();
	}

	// 프로그레시브바 다이얼로그 박스를 열거라면.. 저장
	//if (style == DialogType_Progress)
	//{		
	//}
	
	// 이거 일단 주석
	if(saveCancelDialogID > -1) 
	{
		tryCancelDialogID = saveCancelDialogID;
		saveCancelDialogID = -1;
	}

	//bProgressBarWorking = false;
	m_dialogHandle.ShowWindow();
	SetWindowStyle( style );

	//// HTML 이면 bUseHtml , true, 아니면 일반 텍스트 
	//SetMessage( message , bUseHtml);

	m_dialogHandle.SetFocus();

	if( m_editHandle.IsShowWindow() )
	{
		m_editHandle.SetString("");
		m_editHandle.SetFocus();
		if( m_editMaxLength != -1 )
		{
			m_editMaxLength_prev = m_editHandle.GetMaxLength();
			m_editHandle.SetMaxLength(m_editMaxLength);
		}
		else
			m_editHandle.SetMaxLength(INPUT_DEFAULT_MAXLENGTH);
	}

	m_strTargetScript = target;
	
	// 0 보다 커야 작동 하도록, 0보다 같거나 작으면 기본 사이즈를 지정하게 한다.
	if (widthSizeChangeValue > 0  && heightSizeChangeValue > 0) 
	{
		m_dialogHandle.SetWindowSize( widthSizeChangeValue, heightSizeChangeValue);
		m_dialogBody.SetWindowSize  ( widthSizeChangeValue, heightSizeChangeValue);

		// m_HtmlViewer.SetWindowSize  ( widthSizeChangeValue, heightSizeChangeValue);
		//m_textHandle.SetWindowSize  ( widthSizeChangeValue, heightSizeChangeValue);
	}
	else 
	{
		if (widthSizeChangeValue > 0)
		{
			m_dialogHandle.SetWindowSize( widthSizeChangeValue, defaultBodyRect.nHeight);
			m_dialogBody.SetWindowSize  ( widthSizeChangeValue, defaultBodyRect.nHeight);
		}
		else if (heightSizeChangeValue > 0)
		{
			m_dialogHandle.SetWindowSize( defaultBodyRect.nWidth, heightSizeChangeValue);
			m_dialogBody.SetWindowSize  ( defaultBodyRect.nWidth, heightSizeChangeValue);
		}
	}
	// HTML 이면 bUseHtml , true, 아니면 일반 텍스트 
	SetMessage( message , bUseHtml);
	
	//branch121212
	m_bGlobalIME = false;
	Language = GetLanguage();
	if( Language == LANG_Japanese || Language == LANG_Taiwan )
	{
		m_bGlobalIME = true;
	}
}

// 진행바로 실행 했던 다이얼로그 값을 기억
//function int getProgressCancelDialogID()
//{
//	return tryCancelDialogID;
//}


// 이전 캔슬을 할 것이 있다면..
function bool hasPreviousCancelProcess()
{
	return (tryCancelDialogID > -1);
}

function bool checkCancelDialogID(int taregetDialogID)
{
	return (tryCancelDialogID > -1) && (tryCancelDialogID == taregetDialogID);
}

function HideDialog()
{
	//Debug("HideDialog");
	
	/*
	if ( m_bInUse ) {
	//  디폴트 값 실행
		if( m_type == DialogType_Progress )
			DoDefaultAction();
	}
	*/	
	if (tryCancelDialogID > -1)
	{
		HandleCancel();
	}

	NumberPad_DefaultValue = 0;
	INPUT_NUMBERPAD_MAXLENGTH = 15;
	SetButtonName( 1337, 1342 );
	m_dialogHandle.HideWindow();
	Initialize();

	
	// 다이얼로그 텍스쳐 아이콘 초기화, 이미지 초기화, 툴팁 초기화 
	setIconTexture("");
	m_exclamationImage.ShowWindow();
}

function SetDefaultAction( DialogDefaultAction defaultAction )
{
	//debug("DialogBox SetDefaultAction " $ defaultAction );
//	if( m_bInUse ) return;
	m_defaultAction = defaultAction;
}
function SetEnterAction( DialogEnterAction enterAction )
{
	m_enterAction = enterAction;
}
function string GetTarget()
{
	//debug("Dialog::GetTarget() returns: " $ m_strTargetScript );
	return m_strTargetScript;
}

//function string GetBeforeTarget()
//{
//	//debug("Dialog::GetTarget() returns: " $ m_strTargetScript );
//	return beforeStrTargetScript;
//}



function string GetEditMessage()
{
	//debug("Dialog::GetEditMessage() returns: " $ m_strEditMessage );
	return m_strEditMessage;
}

function SetEditMessage(string strMsg)
{
	//if( m_bInUse ) return;
	m_editHandle.SetString( strMsg );
}

function int GetID()
{
	return m_id;
}

function SetID( int id )
{
	//debug("DialogBox SetID " $ id );
	//if( m_bInUse ) return;

	// 이전 다이얼로그 ID를 기억 (진행바 취소등에 사용할 용도)
	//beforeDialogID = m_id;
	m_id = id;
}

//function int GetBeforeID()
//{
//	return beforeDialogID;
//}


function SetEditType( string strType )
{
//	if( m_bInUse ) return;
	m_editHandle.SetEditType( strType );
}

function SetParamInt64( INT64 param )
{
	//if( m_bInUse ) return;
	m_paramInt = param;
}

function SetReservedInt( int value )
{
//	if( m_bInUse ) return;
	m_reservedInt = value;
	//debug("DialogBox SetReservedInt to " $ value);
}

function SetReservedInt2( INT64 value )
{
	//if( m_bInUse ) return;
	m_reservedInt2 = value;
	//debug("DialogBox SetReservedInt2 to " $ value);
}

function SetReservedInt3( int value )
{
//	if( m_bInUse ) return;
	m_reservedInt3 = value;
	//debug("DialogBox SetReservedInt to " $ value);
}

function SetReservedItemID( ItemID ID )
{
	//if( m_bInUse ) return;
	m_reservedItemID = ID;
}

function SetReservedItemInfo( ItemInfo info)
{
//	if( m_bInUse ) return;
	m_reservedItemInfo = info;
}

function SetReservedString( string str)
{
//	if( m_bInUse ) return;
	m_reservedString = str;
}

function string GetReservedString()
{
	//if( m_bInUse ) return;
	return m_reservedString;
}

function INT64 GetReservedParamInt64()
{
	//if( m_bInUse ) return;
	return m_paramInt;
}

function int GetReservedInt()
{
	return m_reservedInt;
}

function INT64 GetReservedInt2()
{
	return m_reservedInt2;
}

function int GetReservedInt3()
{
	return m_reservedInt3;
}

function ItemID GetReservedItemID()
{
	return m_reservedItemID;
}

function GetReservedItemInfo(out ItemInfo info)
{
	info = m_reservedItemInfo;
}

function SetEditBoxMaxLength(int maxLength)
{
	//if( m_bInUse ) return;
	if( maxLength >= 0 )
		m_editMaxLength = maxLength;
}

function SetNumberPadDefaultValue( int value )
{
	NumberPad_DefaultValue = value;
}

/**
 *  새로운 다이얼로그 아이콘 텍스쳐를 적용 시킨다.
 **/
function setIconTexture(string texturePath)
{
	if (texturePath == "")	
	{ 
		m_exclamationImage.SetTexture("L2UI_ct1.Icon.ICON_DF_Exclamation");  // 기본 텍스쳐 "!" 표시
		m_exclamationImage.ClearTooltip();
	}
	else 
	{ 
		m_exclamationImage.SetTexture(texturePath);	      // 사용자 커스텀 아이콘		
	}
}

/**
 *  새로운 다이얼로그 커스텀 아이콘 툴팁을 적용 시킨다.
 *  
 *  ex )  DialogSetIconCustomToolTip(getInstanceL2Util().getItemToolTip(info.ID.classID));
 *  
 **/
function setIconCustomToolTip (customToolTip toolTipInfo)
{
	m_exclamationImage.SetTooltipType("text");
	m_exclamationImage.SetTooltipCustomType(toolTipInfo);
}

function OnLoad()
{
	INPUT_NUMBERPAD_MAXLENGTH = 15;
	SetClosingOnESC();

	//DialogReadingText = TextBoxHandle ( GetHandle ( "DialogBox.DialogReadingText" ) );
	//m_dialogEdit = EditBoxHandle( GetHandle("DialogBox.DialogBoxEdit") );
	m_dialogBody   = GetWindowHandle("DialogBox.DialogBody");
	m_dialogHandle = GetWindowHandle("DialogBox");
	m_okHandle	   =  GetButtonHandle("DialogBox.OKButton");
	m_cancelHandle = GetButtonHandle("DialogBox.CancelButton");
	m_centerHandle = GetButtonHandle("DialogBox.CenterOKButton");
	m_editHandle   = GetEditBoxHandle("DialogBox.DialogBoxEdit");
	m_textHandle   = GetTextBoxHandle ("DialogBox.DialogReadingText");

	// 다이얼로그 아이콘
	m_exclamationImage         = GetTextureHandle("DialogBox.DialogBody.ExclamationImage");

	// 신규 추가된 html 타입용
	m_HtmlViewer               = GetHtmlHandle("DialogBox.DialogBody.HtmlViewer");

	m_hDialogBoxDialogProgress = GetProgressCtrlHandle("DialogBox.DialogProgress");

	
	Initialize();
	SetButtonName( 1337, 1342 );
	SetMessage("Message uninitialized");

	// 기본 xml상의 body 사이즈 저장해놓음
	defaultBodyRect = class'UIAPI_WINDOW'.static.GetRect( "DialogBox.DialogBody" );

	NumberPad_DefaultValue = 0;
	tryCancelDialogID = -1;
	
    // 버튼 사이즈 기본으로 조절
	if( buttonWidth_prev != 0 )
	{
		m_okHandle.SetWindowSize( buttonWidth_prev, buttonHeight_prev );
		m_centerHandle.SetWindowSize( buttonWidth_prev, buttonHeight_prev );
		m_cancelHandle.SetWindowSize( buttonWidth_prev, buttonHeight_prev );
	}
}

//function SetHostWndScript(UIScript host)
//{
//	m_hostWndScript = host;
//}

function OnClickButton( string strID )
{
	switch( strID )
	{
	case "OKButton":
	case "CenterOKButton":
		HandleOK();
		break;
	case "CancelButton":
		HandleCancel();
		break;
	case "num0":
	case "num1":
	case "num2":
	case "num3":
	case "num4":
	case "num5":
	case "num6":
	case "num7":
	case "num8":
	case "num9":
	case "numAll":
	case "numBS":
	case "numC":
		HandleNumberClick( strID );
		break;
	default:
		break;
	}
}

function OnHide()
{
	if( m_type == DialogType_Progress )
		m_hDialogBoxDialogProgress.Stop();

	SetEditType( "normal" );
	//debug("에디트메시지 삭제 " @ class'UIAPI_EDITBOX'.static.GetString( "DialogBox.DialogBoxEdit" ));
	SetEditMessage("");
	//debug("에디트메시지 삭제 " @ class'UIAPI_EDITBOX'.static.GetString( "DialogBox.DialogBoxEdit" ));

	// EditBox의 maxLength를 원래 대로 돌려주자.
	if( m_editMaxLength != -1 )
	{
		m_editMaxLength = -1;
		m_editHandle.SetMaxLength(m_editMaxLength_prev);
	}

	//m_bInUse = false;

	m_editHandle.Clear();
	NumberPad_DefaultValue = 0;
	SetButtonName( 1337, 1342 );

	// 기본값으로
	INPUT_NUMBERPAD_MAXLENGTH = 15;
}

//function OnCompleteEditBox( String strID )
//{
//	if( strID == "DialogBoxEdit" )
//	{
//		debug("DialogBox OnCompleteEditBox");
//		HandleOK();
//	}
//}

function OnChangeEditBox( String strID )
{
	local string strInput;
	local string strComma;
	local color TextColor;
	
	if( strID == "DialogBoxEdit" )
	{
		if( m_type == DialogType_NumberPad )
		{
			//선준 수정(2010.03.03)
			m_textHandle.SetText("");
			if (m_editMaxLength == -1) m_editHandle.SetMaxLength( INPUT_NUMBERPAD_MAXLENGTH );
			
			strInput = m_editHandle.GetString();
			if(Len(strInput)>0)
			{
				//Set Comma String
				strComma = MakeCostString( strInput );
				if( NumberPad_DefaultValue != 0 ) strInput = String( NumberPad_Value * NumberPad_DefaultValue ); // 기본값이 있을때 2012.02.22
				m_textHandle.SetText( ConvertNumToTextNoAdena( strInput ) );
				
				//Set Numeric Color
				TextColor= GetNumericColor( strComma );
				m_editHandle.SetFontColor( TextColor );
			}
		}
		else
		{
			//넘버패드가 아닐 경우에 기본 색으로
			TextColor= GetNumericColor( MakeCostString( "1" ) );
			m_editHandle.SetFontColor( TextColor );	
		}
	}
}

function Initialize()
{
	m_strTargetScript = "";
	//m_bInUse = false;
	SetEditType( "normal" );
	m_paramInt = 0;
	m_reservedInt = 0;
	m_reservedInt2 = 0;
	m_editMaxLength = -1;
//	m_hostWndScript	= None;
	// tryCancelDialogID = -1;
	SetDefaultAction( EDefaultNone );
	SetEnterAction( EEnterNone );
	//SetDefaultAction( EDefaultOK ); // 2012.03.14 
	// Debug("Initialize() -----------");
}

function HideAll()
{
//	debug("HideAll");
	m_editHandle.HideWindow();
	m_okHandle.HideWindow();
	m_cancelHandle.HideWindow();
	m_centerHandle.HideWindow();
	class'UIAPI_WINDOW'.static.HideWindow("DialogBox.NumberPad");
	class'UIAPI_WINDOW'.static.HideWindow("DialogBox.DialogProgress");
	setIconTexture( "" );
}

function SetWindowStyle( EDialogType style )
{
	local Rect bodyRect, numpadRect;
//	Debug("SetWindowStyle");
	HideAll();

	// 변경 되었을지 모르는 사이즈 다시 복구 
	bodyRect = defaultBodyRect; //class'UIAPI_WINDOW'.static.GetRect( "DialogBox.DialogBody" );
	m_dialogBody.SetWindowSize( bodyRect.nWidth, bodyRect.nHeight);

	numpadRect = class'UIAPI_WINDOW'.static.GetRect( "DialogBox.NumberPad" );

	m_type = style;

	switch( style )
	{
		case DialogType_OKCancel:
			m_okHandle.ShowWindow();
			m_cancelHandle.ShowWindow();
			m_dialogHandle.SetWindowSize( bodyRect.nWidth, bodyRect.nHeight);		
			break;
		case DialogType_OK:
			m_centerHandle.ShowWindow();
			m_dialogHandle.SetWindowSize( bodyRect.nWidth, bodyRect.nHeight );
			break;
		case DialogType_OKCancelInput:		// two Button(ok, cancel), and a EditBox
			m_editHandle.ShowWindow();
			m_textHandle.SetText( "" );
			m_okHandle.ShowWindow();
			m_cancelHandle.ShowWindow();
			m_dialogHandle.SetWindowSize( bodyRect.nWidth, bodyRect.nHeight );
			break;
		case DialogType_OKInput:			// one Button(ok), and a EditBox
			m_editHandle.ShowWindow();
			m_textHandle.SetText( "" );
			m_centerHandle.ShowWindow();
			m_dialogHandle.SetWindowSize( bodyRect.nWidth, bodyRect.nHeight );
			break;
		case DialogType_Warning:
			m_okHandle.ShowWindow();
			m_cancelHandle.ShowWindow();
			m_dialogHandle.SetWindowSize( bodyRect.nWidth, bodyRect.nHeight );
			break;
		case DialogType_Notice:
			m_centerHandle.ShowWindow();
			m_dialogHandle.SetWindowSize( bodyRect.nWidth, bodyRect.nHeight );
			break;
		case DialogType_NumberPad:
			m_editHandle.ShowWindow();
			m_textHandle.SetText( "" );
			m_okHandle.ShowWindow();
			m_cancelHandle.ShowWindow();
			ShowWindow("DialogBox.NumberPad");
			m_dialogHandle.SetWindowSize( bodyRect.nWidth + numpadRect.nWidth, bodyRect.nHeight );

			SetEditType("number");
			break;
		case DialogType_Progress:
			m_okHandle.ShowWindow();
			m_cancelHandle.ShowWindow();
			ShowWindow("DialogBox.DialogProgress");
			m_dialogHandle.SetWindowSize( bodyRect.nWidth, bodyRect.nHeight );
			if( m_paramInt == 0 )
			{
				//debug("DialogBox Error!! DialogType_Progress needs parameter");
			}
			else
			{
				m_hDialogBoxDialogProgress.SetProgressTime( INT(m_paramInt) );
				m_hDialogBoxDialogProgress.Reset();
				m_hDialogBoxDialogProgress.Start();

				// 프로그레스바가 작업 시작 했다고 기억 했다가, 중간에 다이얼로그가 교체 될때 각종 취소 처리를 수행해야한다.
				//bProgressBarWorking = true;
			}
			break;
		}

		if( style == DialogType_Progress )
		{
			m_dialogHandle.SetAnchor( "", "BottomCenter", "BottomCenter", 0, 0 );
		}
		else
		{
			m_dialogHandle.SetAnchor( "", "CenterCenter", "CenterCenter", 0, 0 );
		}
}

function bool isProgressBarWorking()
{
	return (tryCancelDialogID > -1);
}


function SetMessage( string strMessage, optional bool bUseHtml )
{
	if (bUseHtml) 
	{
		m_exclamationImage.HideWindow();
		m_HtmlViewer.LoadHtmlFromString(htmlSetHtmlStart(strMessage));
		m_HtmlViewer.ShowWindow();
		class'UIAPI_TEXTBOX'.static.SetText( "DialogBox.DialogText", "");
	}
	else 
	{ 
		m_exclamationImage.ShowWindow();
		m_HtmlViewer.HideWindow();
		m_HtmlViewer.LoadHtmlFromString("");
		class'UIAPI_TEXTBOX'.static.SetText( "DialogBox.DialogText", strMessage );		
	}
	//class'UIAPI_TEXTBOX'.static.
}

/*
 * 버튼 이름 수정, int indexCancel  - > optional int indexCancel 로 수정
 */
function SetButtonName( int indexOK, optional int indexCancel )
{
	m_okHandle.SetButtonName( indexOK );
	m_centerHandle.SetButtonName( indexOK );
	if( indexCancel != 0 ) m_cancelHandle.SetButtonName( indexCancel );
}

/*
 * 버튼 가로사이즈 조절 ??
 */
function SetButtonWidthSize( int indexOK, optional int indexCancel )
{
	m_okHandle.GetWindowSize( buttonWidth_prev, buttonHeight_prev );
	m_okHandle.SetWindowSize( indexOK, buttonHeight_prev );

	m_centerHandle.SetWindowSize( indexOK, buttonHeight_prev );

	if( indexCancel != 0 )
	{
		m_cancelHandle.SetWindowSize( indexCancel, buttonHeight_prev );
	}
}

function HandleOK()
{	
	if( m_editHandle.IsShowWindow() )
		m_strEditMessage = m_editHandle.GetString();
	else
		m_strEditMessage = "";

	tryCancelDialogID = -1;

	//다이얼로그를 연속으로 띄우기 위해서는 Clear를 하지말고 이벤트를 젤 마지막에 보낸다.
	m_dialogHandle.HideWindow();
	//m_bInUse = false;
//	ExecuteEvent( EV_DialogOK );
	ExecuteEvent( EV_DialogOK, Mid( m_strTargetScript, InStr( m_strTargetScript, "." ) + 1 ) );	// FixedHandleDialogOKEvent_moonhj 2012. 10. 16
		
	//if (bProgressBarWorking) bProgressBarWorking = false;
//	if ( m_hostWndScript == None )
//		ExecuteEvent( EV_DialogOK );
//	else
//		m_hostWndScript.OnEvent(EV_DialogOK,"");

	//Debug ( " HandleOK "  @ m_bInUse);
}

function HandleCancel()
{
	m_dialogHandle.HideWindow();
	//m_bInUse = false;

	ExecuteEvent( EV_DialogCancel );

	//bProgressBarWorking = false;

	tryCancelDialogID = -1;
//	if ( m_hostWndScript == None )
//		ExecuteEvent( EV_DialogCancel );
//	else
//		m_hostWndScript.OnEvent( EV_DialogCancel,"" );
}

function HandleNumberClick( string strID )
{
	local int i;
	local string sumStr, sumStrWithoutComma;

	switch( strID )
	{
	case "num0":
		//선준 수정(2010.03.03)
		if( m_editHandle.GetString() != "" )
		{
			m_editHandle.AddString( "0" );
		}
		break;
	case "num1":
		m_editHandle.AddString( "1" );
		break;
	case "num2":
		m_editHandle.AddString( "2" );
		break;
	case "num3":
		m_editHandle.AddString( "3" );
		break;
	case "num4":
		m_editHandle.AddString( "4" );
		break;
	case "num5":
		m_editHandle.AddString( "5" );
		break;
	case "num6":
		m_editHandle.AddString( "6" );
		break;
	case "num7":
		m_editHandle.AddString( "7" );
		break;
	case "num8":
		m_editHandle.AddString( "8" );
		break;
	case "num9":
		m_editHandle.AddString( "9" );
		break;
	case "numAll":
		if( m_paramInt >= 0 )
		{
			m_editHandle.SetString( string(m_paramInt) );
			// debug("===값:m_paramInt: " @ m_paramInt);
			sumStr = "";

			// , 도 카운트로 센다.
			for (i = 0; i < m_editMaxLength; i++)
			{
				if  ((i % 4 == 3) && i != 0) sumStr = "," $ sumStr;
				else  { sumStr = "9" $ sumStr ; sumStrWithoutComma = "9" $ sumStrWithoutComma; }
			}
			if (sumStr != "")
			{
				// debug("날 실행?-->" @ sumStr);
				if (int(sumStrWithoutComma) < m_paramInt)
				{
					// debug("날 실행?" @ sumStr);
					m_editHandle.SetString( sumStrWithoutComma );
				}
			}
			
		}
		break;
	case "numBS":
		m_editHandle.SimulateBackspace();
		break;
	case "numC":
		//선준 수정(2010.03.03)
		m_editHandle.SetString( "" );
		break;
	default:
		break;
	}
}

// 다이얼로그의 시간이 다했음
function OnProgressTimeUp( string strID )
{
	if( strID == "DialogProgress" )
	{
		DoDefaultAction();
		//bProgressBarWorking = false;
	}
}

function DoDefaultAction()
{
	//debug("DialogBox DoDefaultAction");
	switch( m_defaultAction )
	{
	case EDefaultOK:
		HandleOK();
		break;
	case EDefaultCancel:
		HandleCancel();
		break;
	case EDefaultNone:
		HandleCancel();
		break;
	default:
		break;
	};

	SetDefaultAction( EDefaultNone );			// 다이얼로그를 띄울 때 이전 다이얼로그의 디폴트 액션의 영향을 받지 않아야 하므로 한번 하고나면 초기화 해 준다.
}
function DoEnterAction()
{
	switch ( m_enterAction )
	{
	case EEnterOK:
		HandleOK();
		break;
	case EEnterCancel:
		HandleCancel();
		break;
	case EEnterDoNothing:	 
		break;
	case EEnterNone:
		DoDefaultAction();
		break;
	default:
		break;
	};
}
function OnKeyUp( WindowHandle a_WindowHandle, EInputKey nKey )
{
	// 기본 엔터키 처리  ,  다이얼로그 처리 
	//Debug("dilogBox" @ a_WindowHandle.name);//== GetWindowHandle ("W24HzWnd"));
	if (nKey == IK_Enter )
	{
		if ( !chkIDEnterKey() ) 
		{				
			DoEnterAction();
		}
	}
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	//Debug("닫기 시도 ");
	// 클라이언트 쪽 다이얼로그 박스들도 있고 순간 잘못 누를 소지가 있으므로 esc 지원 안하도록 한다.
	if( m_type != DialogType_Progress ) 
	{							
		HandleCancel();
	}
}


function bool chkIDEnterKey() //엔터키 관련 예외사항 하드코딩 기타 필요한 예외 사항 관련 하드 코딩은 여기에 추가 하시면 됩니다.
{
	
	local bool isshowcand;	 //branch121212
	/*
	switch ( DialogGetID() ) {
	case 2424://2011.05027 추가 정동현 요청 | W24HzWnd 의 DIALOGID_Install24hz
		return true;	
	case 2425://2011.05031 기능 추가 | W24HzWnd 의 DIALOGID_FullWindow
		return true; 
	case 323://TradeWnd 의 DIALOG_ID_TRADE_REQUEST
			return true;
	}
	*/
	//branch121212
	
	if( m_bGlobalIME )
	{
		if( m_editHandle.IsShowWindow() ) 
		{
			isshowcand = m_editHandle.IsShowCandidateBox();
			debug("DialogBox isshowcand"$ isshowcand);
			return isshowcand;
		}
	}

	//end of branch
	
	return false;

}


// 입력창이나와있는경우
// 다이얼로그아무영역이나클릭했으면포커스가잡히도록
event OnLButtonUp( WindowHandle a_WindowHandle, int X, int Y )
{
    if (m_editHandle.IsShowWindow() == false) return;

    if (a_WindowHandle != none && m_editHandle.IsFocused() == false)
    {
		m_editHandle.SetFocus();
    }
}



// 12.07.23 길이 수정할수 있게 
function setInputNumberpadMaxLenght( int len )
{
	INPUT_NUMBERPAD_MAXLENGTH = len;
}
defaultproperties
{
}
