class UICommonAPI extends UIConstants;

const EV_USER_CharacterSelectionChanged = 50000;

//FileWnd FileHandler TYPE
enum _FileHandler
{
	FH_NONE,
	FH_PLEDGE_CREST_UPLOAD,
	FH_PLEDGE_EMBLEM_UPLOAD,
	FH_ALLIANCE_CREST_UPLOAD,
	FH_WEBBROWSER_FILE_UPLOAD,
	FH_MAX
	// 파일윈도우에서 파일을 처리할 함수를 정하고 싶을때 용도에 따라 추가합시다 
}; 

//파일윈도우를 보여준다. 핸들러를 지정하고, 
//FileWnd.uc의 Upload함수를 수정해서 파일등록시 실행될 함수를 지정해 주자.
function FileRegisterWndShow(_FileHandler filehandlertype) 
{
	local FileRegisterWnd script;
	script = FileRegisterWnd(GetScript("FileRegisterWnd"));
	script.ShowFileRegisterWnd(filehandlertype);
}

function AddFileRegisterWndFileExt(string str, array<string> strArray)
{
	local FileRegisterWnd script;
	script = FileRegisterWnd(GetScript("FileRegisterWnd"));
	script.AddFileExt(str, strArray);
}

function ClearFileRegisterWndFileExt()
{
	local FileRegisterWnd script;
	script = FileRegisterWnd(GetScript("FileRegisterWnd"));
	script.ClearFileExt();
}

//파일윈도우를 숨겨준다
function FileRegisterWndHide() 
{
	local FileRegisterWnd script;
	script = FileRegisterWnd(GetScript("FileRegisterWnd"));
	script.HideFileRegisterWnd();
}

//
// 다이얼로그를 보여준다. strMessage : 함께 보여줄 스트링( 예를들어 "개수를 입력해 주세요" )
// 무척 간단한 다이얼로그가 아닌 이상 DialogSetID() 같이 불러줘야 한다.
// 
//  - 다이얼로그 기능 추가 - 
//
// dialogHeight : 다이얼로그 세로 사이즈, 0 , -1 같이 0보다 작은 값을 넣으면 기본 사이즈로 세팅된다.
// bUseHtml : true 라면, strMessage 내용을 html 테그를 사용 할수 있게 된다. <html><body> .. 는 넣을 필요 없다
// 
// isXMLOKDialogShow : 현재 사용하지 않고 있음, XML 다이얼로그를 보여줄것인가?, 기존 UI들을 스케일폼 Effect UI [확인] 으로 변경 --
//
// 중국 버전에서 가져옴, param 추가 dialogWeight
static function DialogShow( EDialogModalType modalType, EDialogType dialogType, string strMessage, string strControlName, 
							optional int dialogWeight, optional int dialogHeight, optional bool bUseHtml, optional string customIconTexture)//, optional bool isXMLOKDialogShow)
{
	local DialogBox script;

	//local ConsoleWnd consoleScirpt;

	//if ((dialogType == DialogType_OK || dialogType == DialogType_Notice) &&isXMLOKDialogShow == false)
	//{
	//	consoleScirpt = ConsoleWnd(GetScript("ConsoleWnd"));
	//	consoleScirpt.popupDialogOKShow(getInstanceUIData().getNDialogType(dialogType), 5000, strMessage);
	//}
	//else
	//{
	//	script = DialogBox(GetScript("DialogBox"));
	//	script.ShowDialog(modalType, dialogType, strMessage, strControlName );
	//}

	script = DialogBox(GetScript("DialogBox"));
	script.ShowDialog(modalType, dialogType, strMessage, strControlName, dialogWeight, dialogHeight, bUseHtml);

	if (customIconTexture != "") script.setIconTexture(customIconTexture);

	//script.SetModal(true);
}

static function DialogSetCancelD(int targetCancelDialogID)
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));

	script.setDialogCancelD(targetCancelDialogID);
}

//다이얼로그 버튼 이름 수정
static function DialogSetButtonName( int indexOK, optional int indexCancel )
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	script.SetButtonName( indexOK, indexCancel );
}


//다이얼로그 버튼 가로사이즈 수정
static function DialogSetButtonWidthSize( int indexOK, optional int indexCancel )
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	script.SetButtonWidthSize( indexOK, indexCancel );
}

// 높이 변경 가능한 다이얼로그
static function DialogShowWithResize( EDialogModalType modalType, EDialogType dialogType, string strMessage, int changeWidth, int changeHeight, string strControlName)
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	script.ShowDialog(modalType, dialogType, strMessage, strControlName, changeWidth, changeHeight);
}

// 다이얼로그를 감춘다. 다이얼로그가 떠 있는 상황에서 다른 다이얼로그를 보여주려면 DialogHide() 를 먼저 호출해야한다.
static function DialogHide()
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	script.HideDialog(); 
}

// 다이얼로그가 어떤 동작을 취할지를 default 값을 정해주는 것으로 
// 한번 사용되고나면 초기화 되므로 디폴트 액션을 OK로 하고싶으면 매번 다이얼로그 띄울 때 마다 불러줘야한다.
static function DialogSetDefaultOK()
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	script.SetDefaultAction( EDefaultOK );
}
//그반대로 cancel로 인식한다
static function DialogSetDefaultCancle()
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	script.SetDefaultAction( EDefaultCancel );
}
// 엔터키 누르면 다이얼로그 동작은 무시
static function DialogSetEnterDoNothing()
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	script.SetEnterAction( EEnterDoNothing );
}
// 엔터키 누르면 다이얼로그 동작은 Ok
static function DialogSetEnterOK()
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	script.SetEnterAction( EEnterOK );
}
// 엔터키 누르면 다이얼로그 동작은 Cancel
static function DialogSetEnterCancle()
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	script.SetEnterAction( EEnterCancel );
}
// EV_DialogOK 등의 다이얼로그 이벤트가 왔을 때, 이 다이얼로그가 자신이 띄운 다이얼로그 인지를 판별할 때 쓰인다. 남이 띄운 다이얼로그라면 신경쓸 필요가 없다~
function bool DialogIsMine()
{
	local DialogBox script;

	// Debug("dialog" @ string(Self));
	script = DialogBox(GetScript("DialogBox"));
	if( script.GetTarget() == string(Self) )
		return true;
	
	return false;
}

// 다이얼로그
function bool DialogHasPreviousCancelProcess()
{
	local DialogBox script;

	// Debug("dialog" @ string(Self));
	script = DialogBox(GetScript("DialogBox"));

	return script.hasPreviousCancelProcess();
}


function bool DialogCheckCancelByID(int targetDialogID)
{
	local dialogbox script;

	// debug("dialog" @ string(self));
	script = dialogbox(getscript("dialogbox"));

	return script.checkCancelDialogID(targetDialogID);
}



// 진행바 문제로 바로전에 show 했던 다이얼로그가 어디서 불렸는지를 기억해서 사용한다.
//function bool DialogIsBeforeMine()
//{
//	local DialogBox script;
//	// Debug("GetBeforeTarget " @ string(Self));

//	script = DialogBox(GetScript("DialogBox"));
//	if( script.GetBeforeTarget() == string(Self) )
//		return true;
	
//	return false;
//}

// 다이얼로그 바가 현재 진행 중인가?
//function bool DialogIsProgressBarWorking()
//{
//	local DialogBox script;

//	script = DialogBox(GetScript("DialogBox"));
		
//	return script.isProgressBarWorking();
//}



//// UICommonAPI를 상속받지 않은 클래스에서도 사용하기 위해 추가. 예: GFx 스크립트
//static function bool DialogIsBeforeOwnedBy(string Owner)
//{
//	local DialogBox script;
//	script = DialogBox(GetScript("DialogBox"));
//	if( script.GetBeforeTarget() == Owner )
//		return true;
//	return false;	
//}

// UICommonAPI를 상속받지 않은 클래스에서도 사용하기 위해 추가. 예: GFx 스크립트
static function bool DialogIsOwnedBy(string Owner)
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	if( script.GetTarget() == Owner )
		return true;
	return false;
} 

// 한개의 uc에서 다이얼로그를 한번만 띄운다면 쓸 필요가 없겠지만, 다이얼로그를 여러 상황에서 쓴다면, 예를 들어 혈맹.uc에서  혈원아이디를 묻는데도 쓰고
// 혈원 호칭을 입력 받는 데도 사용한다면, 다이얼로그 이벤트가 왔을때 자신이 어떤 다이얼로그를 띄웠는지를 알 필요가 있다.
// 이럴 경우 다이얼로그를 띄울 때 적절하게 아무 숫자나 DialogSetID() 해 주고 이벤트 처리 부분에서 DialogGetID()를 해서 그에 맞게 코드를 짜면된다.
static function DialogSetID( int id )
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));

	// id저장
	script.SetID( id );
}

// 다이어로그의 에디트 박스의 입력 타입을 지정해 줄 수 있다. 일반 문자열, 숫자, 패스워드 등, XML 프로토콜 문서 참조.
static function DialogSetEditType( string strType )
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	script.SetEditType( strType );
}

// 다이얼로그의 에디트박스에 입력된 스트링을 받아온다
static function string DialogGetString()
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	return script.GetEditMessage();
}

// 다이얼로그의 에디트박스에 스트링을 입력한다
static function DialogSetString(string strInput)
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	script.SetEditMessage(strInput);
}

static function int DialogGetID()
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	return script.GetID();
}

//static function int DialogGetBeforeID()
//{
//	local DialogBox script;
//	script = DialogBox(GetScript("DialogBox"));
//	return script.GetBeforeID();
//}

// ParamInt는 다이얼로그의 동작과 관련된 상수들을 지정해 주는데 쓰인다. Progress의 timeup 시간, NumberPad에서 max값 등.
static function DialogSetParamInt64( int64 param )
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	script.SetParamInt64( param );
}

// ReservedXXX 값들은 다이얼로그에 넣어놨다가 다시 꺼내 볼 수 있다는 점에서 ParamXXX와는 다르다.
static function DialogSetReservedInt( int value )
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	script.SetReservedInt( value );
}

static function DialogSetReservedInt2( INT64 value )
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	script.SetReservedInt2( value );
}

static function DialogSetReservedInt3( int value )
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	script.SetReservedInt3( value );
}

static function DialogSetReservedItemID( ItemID ID )
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	script.SetReservedItemID( ID );
}
static function DialogSetReservedItemInfo( ItemInfo info)
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	script.SetReservedItemInfo( info );
}
static function int DialogGetReservedInt()
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	return script.GetReservedInt();
}

static function INT64 DialogGetReservedInt2()
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	return script.GetReservedInt2();
}

static function int DialogGetReservedInt3()
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	return script.GetReservedInt3();
}

static function ItemID DialogGetReservedItemID()
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	return script.GetReservedItemID();
}

static function DialogGetReservedItemInfo(out ItemInfo info)
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	script.GetReservedItemInfo(info);
}

static function DialogSetEditBoxMaxLength(int maxLength)
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	script.SetEditBoxMaxLength(maxLength);
}

static function DialogSetIconTexture(string iconTextureStr)
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	script.setIconTexture(iconTextureStr);
}

static function DialogSetIconCustomToolTip(customToolTip toolTipInfo)
{
	local DialogBox script;
	script = DialogBox(GetScript("DialogBox"));
	script.setIconCustomToolTip(toolTipInfo);
}
//function DialogSetHostWndScript(UIScript host)
//{
//	local DialogBox	script;
//	script = DialogBox(GetScript("DialogBox"));
//	script.SetHostWndScript(host);
//}
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

function ShowWindow( string a_ControlID )
{
	class'UIAPI_WINDOW'.static.ShowWindow( a_ControlID );
}

/** 윈도우를, 열고 닫고 하는 함수 */
function toggleWindow( string a_ControlID, optional bool bFocus , optional bool bUseOpenCloseSound)
{
	if( class'UIAPI_WINDOW'.static.IsShowWindow( a_ControlID ) )
	{
		if(bUseOpenCloseSound) PlayConsoleSound(IFST_WINDOW_CLOSE);
		class'UIAPI_WINDOW'.static.HideWindow( a_ControlID );
	}
	else
	{
		if(bUseOpenCloseSound) PlayConsoleSound(IFST_WINDOW_CLOSE);

		class'UIAPI_WINDOW'.static.ShowWindow( a_ControlID );

		if (bFocus)
		{
			class'UIAPI_WINDOW'.static.SetFocus( a_ControlID );
		}
	}
}

function ShowWindowWithFocus( string a_ControlID )
{
	class'UIAPI_WINDOW'.static.ShowWindow( a_ControlID );
	class'UIAPI_WINDOW'.static.SetFocus( a_ControlID );
}
static function string reverseString(coerce string str)
{
	local string reverseStr;
	local int i;
	for ( i = Len(str) - 1; i >= 0; --i )
	{
		reverseStr = reverseStr $ Mid(str,i,1);
	}

	return reverseStr;
}

static function string trim(string s)
{
	local int i;
	if ( Len(s) == 0 ) return s;
	i = 0;
	while ( Mid(s,i,1) == " " || Mid(s,i,1) == "\t" )		//necessary for adding tab
		++i;

	s = Right(s,Len(s)-i);
	
	if ( Len(s) == 0 ) return s;

	i = Len(s) - 1;

	while ( Mid(s,i,1) == " " || Mid(s,i,1) == "\t" )	//necessary for adding tab
		--i;

	s = Left(s,i+1);

	return s;
}


static function string deleteEnter(string s)
{
	local int i;
	if ( Len(s) == 0 ) return s;
	i = 0;

	// 코드 13, \n 값이면
	while ( Mid(s,i,1) == Chr(13) || Mid(s,i,1) == Chr(10))
		++i;

	s = Right(s,Len(s)-i);
	
	if ( Len(s) == 0 ) return s;

	i = Len(s) - 1;

	while ( Mid(s,i,1) == Chr(13) || Mid(s,i,1) == Chr(10))
		--i;

	s = Left(s,i+1);

	return s;
}

static function int InStrFromBack(string s, string t)
{
	local string reverseStr;
	local int i;
	reverseStr = reverseString(s);
	i = InStr(reverseStr, t);

	if ( i >= 0 )
		return Len(s) - 1 - i;
	else
		return i;
}


function HideWindow( string a_ControlID )
{
	class'UIAPI_WINDOW'.static.HideWindow( a_ControlID );
}

function bool IsShowWindow( string a_ControlID )
{
	return class'UIAPI_WINDOW'.static.IsShowWindow( a_ControlID );
}

function ParamToItemInfo( string param, out ItemInfo info )
{
	local int tmpInt;
	local int i, n;
	local int cnt;

	ParseItemID( param, info.ID );
	//ParseInt( param, "classID", info.ClassID );
	ParseInt( param, "level", info.Level);
	ParseString( param, "name", info.Name);
	ParseString( param, "additionalName", info.AdditionalName);
	ParseString( param, "iconName", info.IconName);
	ParseString( param, "iconPanel", info.IconPanel );
	ParseString( param, "description", info.Description);
	ParseInt( param, "itemType", info.ItemType);
	//ParseInt( param, "serverID", info.ServerID );
	ParseINT64( param, "itemNum", info.ItemNum);
	ParseInt64( param, "slotBitType", info.SlotBitType);	// INT -> INT64, Jewel 추가 - by y2jinc (2013. 9. 2)
	ParseInt( param, "enchanted", info.Enchanted);
	ParseInt( param, "blessed", info.Blessed);
	ParseInt( param, "damaged", info.Damaged);
	if( ParseInt( param, "equipped", tmpInt ) )
		info.bEquipped = bool(tmpInt);
	ParseINT64( param, "price", info.Price );
	ParseInt( param, "reserved", info.Reserved );
	ParseINT64( param, "reserved64", info.Reserved64 );
	ParseINT64( param, "defaultPrice", info.DefaultPrice );
	ParseInt( param, "refineryOp1", info.RefineryOp1 );
	ParseInt( param, "refineryOp2", info.RefineryOp2 );
	ParseInt( param, "currentDurability", info.CurrentDurability );
	ParseInt( param, "CurrentPeriod", info.CurrentPeriod);
	ParseInt( param, "disabled", info.bDisabled );
//	if( ParseInt( param, "disabled", tmpInt ) )
//		info.bDisabled = bool(tmpInt);
	
	ParseInt(param, "enchantOption1", info.EnchantOption1);
	ParseInt(param, "enchantOption2", info.EnchantOption2);
	ParseInt(param, "enchantOption3", info.EnchantOption3);
	ParseInt( param, "weight", info.Weight );
	ParseInt( param, "materialType", info.MaterialType);
	ParseInt( param, "weaponType", info.WeaponType);
	
	ParseFloat( param, "pDefense", info.pDefense);
	ParseFloat( param, "mDefense", info.mDefense);
	ParseFloat( param, "pAttack", info.pAttack);
	ParseFloat( param, "mAttack", info.mAttack);
	ParseFloat( param, "pAttackSpeed", info.pAttackSpeed);
	ParseFloat( param, "mAttackSpeed", info.mAttackSpeed);	
	ParseFloat( param, "pHitRate", info.pHitRate);
	ParseFloat( param, "mHitRate", info.mHitRate);
	ParseFloat( param, "pCriRate", info.pCriRate);
	ParseFloat( param, "mCriRate", info.mCriRate);
	ParseFloat( param, "MoveSpeed", info.MoveSpeed);
	ParseFloat( param, "ShieldDefense", info.ShieldDefense);
	ParseFloat( param, "ShieldDefenseRate", info.ShieldDefenseRate);
	ParseFloat( param, "pAvoid", info.pAvoid);
	ParseFloat( param, "mAvoid", info.mAvoid);
	ParseInt( param, "enchant_bonus", info.enchant_bonus);
	
	ParseINT64( param, "n64DefaultPriceFromScript", info.n64DefaultPriceFromScript);	// 연금술 작업 - by y2jinc (2013. 10. 8)	
		
	ParseInt( param, "durability", info.Durability);
	ParseInt( param, "crystalType", info.CrystalType);
	ParseInt( param, "randomDamage", info.RandomDamage);
	ParseInt( param, "mpConsume", info.MpConsume);
	ParseInt( param, "soulshotCount", info.SoulshotCount);
	ParseInt( param, "spiritshotCount", info.SpiritshotCount);
		
	ParseInt( param, "armorType", info.ArmorType);
	ParseInt( param, "mpBonus", info.MpBonus);
	ParseInt( param, "bodyPart", info.BodyPart); //branch 111109

	ParseInt( param, "consumeType", info.ConsumeType);
	ParseInt( param, "ItemSubType", info.ItemSubType );
	ParseString( param, "iconNameEx1", info.IconNameEx1 );
	ParseString( param, "iconNameEx2", info.IconNameEx2 );
	ParseString( param, "iconNameEx3", info.IconNameEx3 );
	ParseString( param, "iconNameEx4", info.IconNameEx4 );
	if( ParseInt( param, "arrow", tmpInt ) )
		info.bArrow = bool(tmpInt);
	if( ParseInt( param, "recipe", tmpInt ) )
		info.bRecipe = bool(tmpInt);
	//ParseInt( param, "etcItemType", info.EtcItemType);
	ParseInt( param, "AttackAttributeType", info.AttackAttributeType);
	ParseInt( param, "AttackAttributeValue", info.AttackAttributeValue);
	ParseInt( param, "DefenseAttributeValueFire", info.DefenseAttributeValueFire);
	ParseInt( param, "DefenseAttributeValueWater", info.DefenseAttributeValueWater);
	ParseInt( param, "DefenseAttributeValueWind", info.DefenseAttributeValueWind);
	ParseInt( param, "DefenseAttributeValueEarth", info.DefenseAttributeValueEarth);
	ParseInt( param, "DefenseAttributeValueHoly", info.DefenseAttributeValueHoly);
	ParseInt( param, "DefenseAttributeValueUnholy", info.DefenseAttributeValueUnholy);

	tmpInt=0;
	ParseInt( param, "RelatedQuestCnt", tmpInt);
	if(tmpInt > 0)
	{
		for(i=0; i<tmpInt; ++i)
			ParseInt(param, "RelatedQuestID"$i, info.RelatedQuestID[i]);
	}
	
	ParseInt( param, "attribution", info.Attribution);
	ParseInt( param, "propertyparams", info.propertyparams);
	
	//branch 111109
	ParseInt( param, "IsBRPremium", info.IsBRPremium);
	ParseInt( param, "BR_CurrentEnergy", info.BR_CurrentEnergy);
	ParseInt( param, "BR_MaxEnergy", info.BR_MaxEnergy);
	ParseInt( param, "LookChangeIconID", info.LookChangeIconID); //branch 111109
	//end of branch
	
	//branch 110824 무기외형변경
	ParseInt( param, "LookChangeItemID", info.LookChangeItemID);
	ParseString( param, "LookChangeItemName", info.LookChangeItemName);
	ParseString( param, "LookChangeIconPanel", info.LookChangeIconPanel);
	//end of branch

	ParseInt ( param, "Order", info.Order);
	// debug("Save Order " $ info.Order);
	ParseInt( param, "PopMsgNum", info.PopMsgNum);
	ParseString( param, "tooltipTexutre", info.tooltipTexutre);

	//// 집혼 시스템 개편 (2015-02-09 추가)
	//for(i=EIST_NORMAL; i<EIST_MAX; i++)
	//{
	//	ParseInt( param, "EnsoulOptionNum_" $ i, info.EnsoulOption[i - 1].OptionArray.Length);		

	//	cnt = info.EnsoulOption[i - EIST_NORMAL].OptionArray.Length;

	//	for(n = EISI_START; n < EISI_START + cnt; n++)
	//	{
	//      같이 func ParseInt 함수의 parameter에 Array를 직접 넣게 되면, 엔진에서 실제로 Int형 임시 변수가 생성되지만 메모리 해제시에는 FArray형 소멸자가 호출되기 때문에 크래시가 발생합니다.
	//      by 문형진 
	//		ParseInt(param, "EnsoulOptionID_" $ String(i) $ "_" $ string(n) , info.EnsoulOption[i - EIST_NORMAL].OptionArray[n - EISI_START]);
	//	}
	//}

	//Debug("param--------------" @ param);

	for(i=EIST_NORMAL; i<EIST_MAX; i++)
	{
		ParseInt( param, "EnsoulOptionNum_" $ i, cnt);
		info.EnsoulOption[i - EIST_NORMAL].OptionArray.Length = cnt;

		for(n = EISI_START; n < EISI_START + cnt; n++)
		{
			ParseInt(param, "EnsoulOptionID_" $ String(i) $ "_" $ string(n) , tmpInt);
			info.EnsoulOption[i - EIST_NORMAL].OptionArray[n - EISI_START] = tmpInt;
		}
	}

	ParseString( param, "MacroCommand", info.MacroCommand );


	
	// 봉인 시스템 
	if( ParseInt( param, "SecurityLock", tmpInt ) )
		info.bSecurityLock = bool(tmpInt);	

	if( ParseInt( param, "SecurityLockable", tmpInt ) )
		info.bSecurityLockable = bool(tmpInt);		

	//Debug ( info.bSecurityLockable   @ info.bSecurityLock );

	// 큐브 아이템
	parseInt ( param , "CurUseCount", info.CurUseCount ) ;
	parseInt ( param , "MaxUseCount", info.MaxUseCount ) ;
	ParseFloat ( param , "MaxReuseDelay", info.MaxReuseDelay ) ;		
	ParseFloat ( param , "RemainReuseDelay", info.RemainReuseDelay ) ;	
	ParseFloat ( param , "ReceivedAppSec", info.ReceivedAppSec ) ;
}



//2015-02-04 추가 
function ItemInfoToParam(ItemInfo info, out string param)
{
	local int i;

	ParamAdd(param, "ClassID" , String(info.ID.ClassID));
	ParamAdd(param, "ServerID", String(info.ID.ServerID));

	ParamAdd( param, "level", String(info.Level));
	ParamAdd( param, "name", info.Name);
	ParamAdd( param, "additionalName", info.AdditionalName);
	ParamAdd( param, "iconName", info.IconName);
	ParamAdd( param, "iconPanel", info.IconPanel );
	ParamAdd( param, "description", info.Description);
	ParamAdd( param, "itemType", String(info.ItemType));
	
	ParamAddINT64( param, "itemNum", (info.ItemNum));
	ParamAddINT64( param, "slotBitType", (info.SlotBitType));	// INT -> INT64, Jewel 추가 - by y2jinc (2013. 9. 2)
	ParamAdd( param, "enchanted", String(info.Enchanted));
	ParamAdd( param, "blessed", String(info.Blessed));
	ParamAdd( param, "damaged", String(info.Damaged));
	ParamAdd( param, "equipped", String(info.bEquipped));
		

	ParamAddINT64( param, "price", (info.Price));
	ParamAdd( param, "reserved", String(info.Reserved));
	ParamAddINT64( param, "reserved64", (info.Reserved64));
	ParamAddINT64( param, "defaultPrice", (info.DefaultPrice ));
	ParamAdd( param, "refineryOp1", String(info.RefineryOp1 ));
	ParamAdd( param, "refineryOp2", String(info.RefineryOp2 ));
	ParamAdd( param, "currentDurability", String(info.CurrentDurability ));
	ParamAdd( param, "CurrentPeriod", String(info.CurrentPeriod));
	ParamAdd( param, "disabled", String(info.bDisabled ));

	
	ParamAdd( param, "enchantOption1", String(info.EnchantOption1));
	ParamAdd( param, "enchantOption2", String(info.EnchantOption2));
	ParamAdd( param, "enchantOption3", String(info.EnchantOption3));
	ParamAdd( param, "weight", String(info.Weight ));
	ParamAdd( param, "materialType", String(info.MaterialType));
	ParamAdd( param, "weaponType", String(info.WeaponType));
	
	ParamAdd( param, "pDefense", String(info.pDefense));
	ParamAdd( param, "mDefense", String(info.mDefense));
	ParamAdd( param, "pAttack", String(info.pAttack));
	ParamAdd( param, "mAttack", String(info.mAttack));
	ParamAdd( param, "pAttackSpeed", String(info.pAttackSpeed));
	ParamAdd( param, "mAttackSpeed", String(info.mAttackSpeed));	
	ParamAdd( param, "pHitRate", String(info.pHitRate));
	ParamAdd( param, "mHitRate", String(info.mHitRate));
	ParamAdd( param, "pCriRate", String(info.pCriRate));
	ParamAdd( param, "mCriRate", String(info.mCriRate));
	ParamAdd( param, "MoveSpeed", String(info.MoveSpeed));
	ParamAdd( param, "ShieldDefense", String(info.ShieldDefense));
	ParamAdd( param, "ShieldDefenseRate", String(info.ShieldDefenseRate));
	ParamAdd( param, "pAvoid", String(info.pAvoid));
	ParamAdd( param, "mAvoid", String(info.mAvoid));
	ParamAdd( param, "enchant_bonus", String(info.enchant_bonus));
	
	ParamAddINT64( param, "n64DefaultPriceFromScript", (info.n64DefaultPriceFromScript));	// 연금술 작업 - by y2jinc (2013. 10. 8)	
		
	ParamAdd( param, "durability", String(info.Durability));
	ParamAdd( param, "crystalType", String(info.CrystalType));
	ParamAdd( param, "randomDamage", String(info.RandomDamage));
	ParamAdd( param, "mpConsume", String(info.MpConsume));
	ParamAdd( param, "soulshotCount", String(info.SoulshotCount));
	ParamAdd( param, "spiritshotCount", String(info.SpiritshotCount));
		
	ParamAdd( param, "armorType", String(info.ArmorType));
	ParamAdd( param, "mpBonus", String(info.MpBonus));
	ParamAdd( param, "bodyPart", String(info.BodyPart)); //branch 111109

	ParamAdd( param, "consumeType", String(info.ConsumeType));
	ParamAdd( param, "ItemSubType", String(info.ItemSubType ));
	ParamAdd( param, "iconNameEx1", (info.IconNameEx1 ));
	ParamAdd( param, "iconNameEx2", (info.IconNameEx2 ));
	ParamAdd( param, "iconNameEx3", (info.IconNameEx3 ));
	ParamAdd( param, "iconNameEx4", (info.IconNameEx4 ));

	ParamAdd( param, "arrow",String(info.bArrow ));

	ParamAdd( param, "recipe", String(info.bRecipe ));

	ParamAdd( param, "AttackAttributeType", String(info.AttackAttributeType));
	ParamAdd( param, "AttackAttributeValue", String(info.AttackAttributeValue));
	ParamAdd( param, "DefenseAttributeValueFire",String(info.DefenseAttributeValueFire));
	ParamAdd( param, "DefenseAttributeValueWater", String(info.DefenseAttributeValueWater));
	ParamAdd( param, "DefenseAttributeValueWind", String(info.DefenseAttributeValueWind));
	ParamAdd( param, "DefenseAttributeValueEarth", String(info.DefenseAttributeValueEarth));
	ParamAdd( param, "DefenseAttributeValueHoly", String(info.DefenseAttributeValueHoly));
	ParamAdd( param, "DefenseAttributeValueUnholy", String(info.DefenseAttributeValueUnholy));

	// 관계형 퀘스트 아이템 카운트 인듯 한데.. 없어서 안함.
	ParamAdd( param, "RelatedQuestCnt", String(MAX_RELATED_QUEST));
		
	for(i=0; i<MAX_RELATED_QUEST; ++i)
		ParamAdd(param, "RelatedQuestID"$i, String(info.RelatedQuestID[i]));
	
	ParamAdd( param, "attribution", String(info.Attribution));
	ParamAdd( param, "propertyparams", String(info.propertyparams));
	
	//branch 111109
	ParamAdd( param, "IsBRPremium", String(info.IsBRPremium));
	ParamAdd( param, "BR_CurrentEnergy", String(info.BR_CurrentEnergy));
	ParamAdd( param, "BR_MaxEnergy", String(info.BR_MaxEnergy));
	ParamAdd( param, "LookChangeIconID", String(info.LookChangeIconID)); //branch 111109
	//end of branch
	
	//branch 110824 무기외형변경
	ParamAdd( param, "LookChangeItemID", String(info.LookChangeItemID));
	ParamAdd( param, "LookChangeItemName", info.LookChangeItemName);
	ParamAdd( param, "LookChangeIconPanel", info.LookChangeIconPanel);
	//end of branch

	ParamAdd ( param, "Order", String(info.Order));
	// debug("Save Order " $ info.Order);
	ParamAdd( param, "PopMsgNum", String(info.PopMsgNum));
	ParamAdd( param, "tooltipTexutre", info.tooltipTexutre);

	//const EISI_START = 1;
	//const EISI_MAX = 2;
	// 집혼 시스템 개편 (2015-02-09 추가)

	addParamEnsoulOptionInfo(info, param);

	ParamAdd( param, "MacroCommand", info.MacroCommand );

	//for(i=EIST_NORMAL; i<EIST_MAX; i++)
	//{
	//	cnt = info.EnsoulOption[i - EIST_NORMAL].OptionArray.Length;

	//	ParamAdd(param, "EnsoulOptionNum_" $ String(i), String(cnt));

	//	for(n=EISI_START; n < EISI_START + cnt; n++)
	//	{
	//		ParamAdd(param, "EnsoulOptionNum_" $ String(i) $ "_" $ string(n) , String(info.EnsoulOption[i - EIST_NORMAL].OptionArray[n - EISI_START]));
	//	}
	//}

	ParamAdd ( param , "SecurityLockable", String (info.bSecurityLockable) ) ;
	ParamAdd ( param , "SecurityLock", String (info.bSecurityLock) ) ;

	//Debug("::"@ info.EnsoulOption[i].OptionArray.Length);
	ParamAdd ( param , "CurUseCount", String ( info.CurUseCount )) ;
	ParamAdd ( param , "MaxUseCount", String ( info.MaxUseCount )) ;
	ParamAdd ( param , "MaxReuseDelay", String ( info.MaxReuseDelay )) ;		
	ParamAdd ( param , "RemainReuseDelay", String ( info.RemainReuseDelay )) ;	
	ParamAdd ( param , "ReceivedAppSec", String ( info.ReceivedAppSec )) ;
}

function ParamToRecord( string param, out LVDataRecord record )
{
	local int idx;
	local int MaxColumn;
	
	ParseString( param, "szReserved", record.szReserved );
	ParseINT64( param, "nReserved1", record.nReserved1 );
	ParseINT64( param, "nReserved2", record.nReserved2 );
	ParseINT64( param, "nReserved3", record.nReserved3 );

	ParseInt( param, "MaxColumn", MaxColumn );
	record.LVDataList.Length = MaxColumn;
	for (idx=0; idx<MaxColumn; idx++)
	{
		ParseString( param, "szData_" $ idx, record.LVDataList[idx].szData );
		ParseString( param, "szReserved_" $ idx, record.LVDataList[idx].szReserved );
		ParseInt( param, "nReserved1_" $ idx, record.LVDataList[idx].nReserved1 );
		ParseInt( param, "nReserved2_" $ idx, record.LVDataList[idx].nReserved2 );
		ParseInt( param, "nReserved3_" $ idx, record.LVDataList[idx].nReserved3 );
	}
}

/** 
 *  12.07.05 toopTipWidth 추가 - 툴팁가로사이즈 설정, toopTipWidth 설정하면 t_bDrawOneLine true 가 false 로 설정됨 
 */
function CustomTooltip MakeTooltipSimpleText(string Text, optional int toolTipWidth)
{
	local CustomTooltip Tooltip;
	local DrawItemInfo info;
	local bool oneline;

	oneline = true;
	if( toolTipWidth > 0 ) oneline = false;
	
	Tooltip.DrawList.Length = 1;
	Tooltip.MinimumWidth = toolTipWidth;
	info.eType = DIT_TEXT;
	info.t_bDrawOneLine = oneline;
	info.t_strText = Text;	
	Tooltip.DrawList[0] = info;

	return Tooltip;
}

/** 
 *  툴팁에 칼라 적용
 */
function CustomTooltip MakeTooltipSimpleColorText(string text, color textColor, optional string fontName, optional int toolTipWidth)
{
	local CustomTooltip Tooltip;

	local bool oneline;

	oneline = true;
	if( toolTipWidth > 0 ) oneline = false;
	Tooltip.MinimumWidth = toolTipWidth;

	Tooltip.DrawList[0] = addDrawItemText(text, textColor, fontName, oneline);
	return Tooltip;
}

/** 
   멀티 라인, 커스텀 툴팁 (상하이팀에서 만든 것)
   
   
   ex )
   		SetTooltipCustomType(MakeTooltipMultiText("1 테스트 항목", getInstanceL2Util().Yellow, "HS15",false,
												  "2 테스트 항목", getInstanceL2Util().Yellow, "",true,
												  "3 테스트 항목", getInstanceL2Util().Blue, "HS12",true));
 */
function CustomTooltip MakeTooltipMultiText(string line1text, Color text1Color, optional string font1Name, optional bool bLine1Break,
										    optional string line2text, optional color text2Color, optional string font2Name,optional bool bLine2Break,
										    optional string line3text, optional color text3Color, optional string font3Name,optional bool bLine3Break, 
										    optional int toolTipWidth)
{
	local CustomTooltip Tooltip;
	local int countLength, textWidth, textHeight, maxTextWidth;
			 
	countLength = 0;

	if (font1Name == "") font1Name = "GameDefault";
	if (font2Name == "") font2Name = "GameDefault";
	if (font3Name == "") font3Name = "GameDefault";

	if (line1text != "")
	{
		countLength++; 
		GetTextSize(line1text, font1Name, textWidth, textHeight);
		if (textWidth > maxTextWidth) maxTextWidth = textWidth;
	}
	if (line2text != "")
	{
		countLength++; 
		GetTextSize(line2text, font2Name, textWidth, textHeight);
		if (textWidth > maxTextWidth) maxTextWidth = textWidth;
	}
	if (line3text != "")
	{
		countLength++; 
		GetTextSize(line3text, font3Name, textWidth, textHeight);
		if (textWidth > maxTextWidth) maxTextWidth = textWidth;
	}

	Tooltip.DrawList.Length = countLength;

	if (toolTipWidth > 0) Tooltip.MinimumWidth = toolTipWidth;
	else Tooltip.MinimumWidth = maxTextWidth + 1;	

	if (line1text != "") Tooltip.DrawList[0] = addDrawItemText(line1text, text1Color, font1Name, bLine1Break);
	if (line2text != "") Tooltip.DrawList[1] = addDrawItemText(line2text, text2Color, font2Name, bLine2Break);
	if (line3text != "") Tooltip.DrawList[2] = addDrawItemText(line3text, text3Color, font3Name, bLine3Break);
	
	return Tooltip;
}

/**
 *  툴팁 항목 추가용
 **/
function DrawItemInfo addDrawItemText(string text, Color textColor, optional string fontName, optional bool bLineBreak, optional bool OneLine, optional int offSetX, optional int offSetY)
{
	local DrawItemInfo info;

	info.eType = DIT_TEXT;
	
	info.t_color.R = textColor.R;
	info.t_color.G = textColor.G;
	info.t_color.B = textColor.B;
	info.t_color.A = textColor.A;
	info.t_strText = text;
	
	info.t_bDrawOneLine = OneLine;
	info.bLineBreak = bLineBreak;	

	info.nOffSetX = offSetX;
	info.nOffSetY = offSetY;

	// 국내 쪽에는 해당 기능이 없어서 일단 주석처리
	//if (fontName != "") info.t_strFontName = fontName;	

	return info;
}

function DrawItemInfo addDrawItemTexture( string Texture, optional bool OneLine, optional bool bLineBreak, optional int offSetX, optional int offSetY )
{
	local DrawItemInfo info;
	info.eType = DIT_TEXTURE;
	info.t_bDrawOneLine = OneLine;
	info.bLineBreak = bLineBreak;
	info.u_nTextureWidth = 16;
	info.u_nTextureHeight = 16;
	info.nOffSetX = offSetX;
	info.nOffSetY = offSetY;
	info.u_nTextureUWidth = 32;
	info.u_nTextureUHeight = 32;
	info.u_strTexture = Texture;
	
	return info;
}

//빈공간의 TooltipItem을 추가한다.
function DrawItemInfo addDrawItemBlank( int Height )
{
	local DrawItemInfo info;

	info.eType = DIT_BLANK;
	info.b_nHeight = Height;

	return info;
}

// 툴팁 DrawList 추가용  
function addToolTipDrawList(out CustomTooltip cTooltip, DrawItemInfo DrawItemInfoElement)
{
	cTooltip.DrawList[cTooltip.DrawList.Length] = DrawItemInfoElement;
}



////////////////////////////////////////////////////////////
//Function For ItemID

static function bool IsValidItemID(ItemID Id)
{
	if( Id.ClassID<1 && Id.ServerID<1 )
		return false;
	return true;
}

static function ItemID GetItemID(int ID)
{
	local ItemID cID;
	cID.ClassID = ID;
	return cID;
}

function bool ParseItemID(string param, out ItemID ID)
{
	local bool bRet1;
	local bool bRet2;
	bRet1 = ParseInt(param, "ClassID", ID.ClassID);
	bRet2 = ParseInt(param, "ServerID", ID.ServerID);
	return bRet1 || bRet2;
}

function bool ParseItemIDWithIndex(string param, out ItemID ID, int idx)
{
	local bool bRet1;
	local bool bRet2;
	bRet1 = ParseInt(param, "ClassID_" $ idx, ID.ClassID);
	bRet2 = ParseInt(param, "ServerID_" $ idx, ID.ServerID);
	return bRet1 || bRet2;
}

function ParamAddItemID(out string param, ItemID ID)
{
	if (ID.ClassID>0)
		ParamAdd(param, "ClassID", string(ID.ClassID));
	if (ID.ServerID>0)
		ParamAdd(param, "ServerID", string(ID.ServerID));
}

function ParamAddItemIDWithIndex(out string param, ItemID ID, int idx)
{
	if (ID.ClassID>0)
		ParamAdd(param, "ClassID_" $ idx, string(ID.ClassID));
	if (ID.ServerID>0)
		ParamAdd(param, "ServerID_" $ idx, string(ID.ServerID));
}

static function ClearItemID(out ItemID ID)
{
	ID.ClassID = -1;
	ID.ServerID = -1;
}

static function bool IsSameItemID(ItemID src, ItemID des)
{
	if (src.ClassID==des.ClassID && src.ServerID==des.ServerID)
		return true;
	return false;
}

static function bool IsSameClassID(ItemID src, ItemID des)
{
	if (src.ClassID==des.ClassID)
		return true;
	return false;
}

static function bool IsSameServerID(ItemID src, ItemID des)
{
	if (src.ServerID==des.ServerID)
		return true;
	return false;
}

static function bool IsAdena(ItemID ID)
{
	if (ID.ClassID==57)
		return true;
	return false;
}

//branch
function string GetPrimeItemSymbolName()
{
	return "BranchSys.ui.primeitem_symbol";
}
//end of branch

/** 
 * 
 * 윈도우 이름을 받는다.
 * 
 * getCurrentWindowName (string(Self)) 
 * 
 **/
static function string getCurrentWindowName (string targetString)
{
	local array<string>	ArrayStr;

	Split(targetString, ".", ArrayStr);

	return ArrayStr[1];
}

static function L2Util getInstanceL2Util()
{
	local L2Util script;
	script = L2Util(GetScript("L2Util"));

	return script;
}

static function InventoryViewer getInstanceInventoryViewer()
{
	local InventoryViewer script;
	script = InventoryViewer(GetScript("InventoryViewer"));

	return script;
}

static function UIData getInstanceUIData()
{
	local UIData script;
	script = UIData(GetScript("UIData"));

	return script;
}

static function NoticeWnd getInstanceNoticeWnd()
{
	local NoticeWnd script;
	script = NoticeWnd(GetScript("NoticeWnd"));

	return script;
}


static function ContextMenu getInstanceContextMenu()
{
	local ContextMenu script;
	script = ContextMenu(GetScript("ContextMenu"));

	return script;
}

// @fixme : GetClassStr() 를 GetClassRoleName() 로 수정 되었으면 합니다. - y2jinc
/*
function string GetClassStr( int ClassID )
{
	return GetClassRoleName(ClassID);
}
*/

// 롤 타입으로 아이콘 번호를 받음.
function int getRollIconNum ( EClassRoleType rollType ) 
{
	switch ( rollType  ) 
	{		
		// 나이트 ( 방패 ) 
		case ECRT_KNIGHT     :return 3 ;
		// 워리어 ( 듀얼소드 ) 
		case ECRT_WARRIOR	 :return 8 ;
		// 로그   ( 단검 ) 
		case ECRT_ROGUE	     :return 1 ;
		// 아처   ( 활 ) 
		case ECRT_ARCHOR	 :return 2 ;
		// 위자드 ( 곧은 지팡이 ) 
		case ECRT_WIZARD	 :return 5 ;
		// 서머너 ( 소환진 ) 
		case ECRT_SUMMONER   :return 7 ;
		// 힐러   ( 굽은 지팡이 ) 
		case ECRT_ENCHANTER  :return 4 ;
		// 인챈터 ( 빛나는 검 ) 
		case ECRT_SUPPORT    :return 6 ;
		// 모험가
		case ECRT_NOVICE     :return 1 ;
		default :return 1 ;
	}
}

// @fixme : GetClassRoleType() 와 GetClassTransferDegree(classID) 를 이용해서 분기 하면 됨. #3008 참고 - y2jinc
function string GetClassRoleIconName( int classID )
{
	local int degree ;	
	local EClassRoleType rollType ;
	
	rollType = GetClassRoleType( classID ) ;
	degree = GetClassTransferDegree( classID ) ;

	// 모험가
	if ( rollType == EClassRoleType.ECRT_NOVICE )  degree = 1;
	else if ( degree  > 4 ) degree = 4;

	return "L2UI_CH3.PartyWnd.party_styleicon" $ degree $ "_" $ getRollIconNum (rollType)  ;	
}

// @fixme : 이것도 통합해주세요. - y2jinc
// 현재 4차 전직용 아이콘만 들어가 있음. (아레나는 4차 전직 클래스만 사용)
// 1차 전직 모험가 아이콘도 추가 요청 함. 대기 상태에서 표시용도ㅂ
function string GetClassArenaRoleIconName( int classID )
{
	local EClassRoleType rollType;
	rollType = GetClassRoleType( classID ) ;	
	if ( rollType == EClassRoleType.ECRT_NOVICE ) return "L2UI.TheArena.party_styleicon1_1" ;	
	return "L2UI.TheArena.party_styleicon4_" $ getRollIconNum (GetClassRoleType( classID )) ;


}



// Chat Color
/*
function Color GetChatColorByType( EChatType a_Type )
{
	local Color ResultColor;

	ResultColor.A = 255;

	switch( a_Type )
	{
	case CHAT_NORMAL:
	case CHAT_PARTY_ROOM_CHAT :
	case CHAT_USER_PET :				// '^'	
		ResultColor.R = 220;
		ResultColor.G = 220;
		ResultColor.B = 220;
		break;
	case CHAT_SHOUT:					// '!'
	case CHAT_CUSTOM :
		ResultColor.R = 255;
		ResultColor.G = 114;
		ResultColor.B = 0;
		break;
	case CHAT_TELL:						// ' " '
		ResultColor.R = 255;
		ResultColor.G = 0;
		ResultColor.B = 255;
		break;
	case CHAT_PARTY:					// '#'
		ResultColor.R = 0;
		ResultColor.G = 255;
		ResultColor.B = 0;
		break;
	case CHAT_CLAN:						// '@'
		ResultColor.R = 125;
		ResultColor.G = 119;
		ResultColor.B = 255;
		break;
	case CHAT_SYSTEM :			 		// ''
		ResultColor.R = 176;
		ResultColor.G = 155;
		ResultColor.B = 121;
		break;
	case CHAT_GM_PET :					// '&'	
	case CHAT_ANNOUNCE :
		ResultColor.R = 128;
		ResultColor.G = 255;
		ResultColor.B = 255;
		break;
	case CHAT_MARKET:					// '+'
		ResultColor.R = 234;
		ResultColor.G = 165;
		ResultColor.B = 245;
		break;
	case CHAT_ALLIANCE:					// '%'	
		ResultColor.R = 119;
		ResultColor.G = 255;
		ResultColor.B = 153;
		break;
	case CHAT_COMMANDER_CHAT :
	case CHAT_SCREEN_ANNOUNCE :
		ResultColor.R = 255;
		ResultColor.G = 150;
		ResultColor.B = 149;
		break;
	case CHAT_INTER_PARTYMASTER_CHAT :
		ResultColor.R = 255;
		ResultColor.G = 248;
		ResultColor.B = 178;
		break;
	case CHAT_CRITICAL_ANNOUNCE :
		ResultColor.R = 0;
		ResultColor.G = 255;
		ResultColor.B = 255;
		break;
	case CHAT_HERO :
		ResultColor.R = 64;
		ResultColor.G = 140;
		ResultColor.B = 255;
		break;
	}

	return ResultColor;
}
*/

function color GetNumericColor( string strCommaAdena )
{
	local Color ResultColor;
	local int l, comma_num, i;

	ResultColor.R = 220; ResultColor.G = 220; ResultColor.B = 220; ResultColor.A = 255;	//Alpha가 O이면 FontDrawInfo::Color가 반영되지 않는다.

	l = Len(strCommaAdena);

	for ( i = 0; i < l; ++i )
	{
		if(Mid(strCommaAdena,i,1) == ",")
			++comma_num;
	}

	l -= comma_num;

	if(l < 5)
		return ResultColor;

	l = (l-5);
	
	switch(l)
	{
		case 0 : ResultColor.R = 105; ResultColor.G = 255; ResultColor.B = 255;	break;
		case 1 : ResultColor.R = 255; ResultColor.G = 128; ResultColor.B = 255; break;
		case 2 : ResultColor.R = 255; ResultColor.G = 255; ResultColor.B = 0; break;
		case 3 : ResultColor.R = 0; ResultColor.G = 255; ResultColor.B = 0; break;
		case 4 : ResultColor.R = 255; ResultColor.G = 140; ResultColor.B = 0; break;
		case 5 : ResultColor.R = 0; ResultColor.G = 110; ResultColor.B = 255; break;
		case 6 : ResultColor.R = 255; ResultColor.G = 0; ResultColor.B = 0; break;
		case 7 : ResultColor.R = 150; ResultColor.G = 110; ResultColor.B = 255; break;
	}

	return ResultColor;
}

//---------------------------------------------------------------------------------------------------------------
// HTML TAG , Function 
//
// L2 에서 지원하는 HTML 은 제한적임 
// WIKI 에 client Html 을 꼭 참고 하고 제작 할 것
//---------------------------------------------------------------------------------------------------------------

// m_HtmlViewer.LoadHtmlFromString("<html><body>" $ strMessage $ "</body></html>");

function string htmlSetHtmlStart(string targetHtml)
{
	return "<html><body>" $ targetHtml $ "</body></html>";
}

/**
 *  Ex) htmlAddItemButton(info.ID.ClassID, 32, 32) $ htmlAddText("테스트 테스트!","hs22", "0xFF0000") $ "<br>" $ htmlAddLineImg()
 **/

/** Tag , Item Button 버튼 아이템 속성의 버튼 테그 */
function string htmlAddItemButton(int nItemID, int nWidth, int nHeight)
{
	local string itemTexture;
	local string addItemHtml;

	local itemID cItemID;

	cItemID.ClassID = nItemID;
	itemTexture = class'UIDATA_ITEM'.static.GetItemTextureName(cItemID);

	addItemHtml =  "<button width=" $ nWidth $ " height=" $ nHeight $ " itemtooltip=\"" $ nItemID $ "\"" 
					 $ " High=\"" $ itemTexture $ "\"" $ " back=\"" $ itemTexture $ "\"" $ " fore=\"" $ itemTexture $ "\"> ";

	return addItemHtml;
}

/** 
 *  Tag , Button 버튼 
 *  
 *  Ex) htmlAddButton("하이", "event inven a=123 b=dongland", 0, 0, 15, 15);
 *  
 **/
function string htmlAddButton(string buttonText, string actionParam, optional int nWidth, optional int nHeight, 
							  optional int buttonAddWidth, optional int buttonAddHeight,
							  optional string textStyle, optional string fontName, optional string fontColor, 
							  optional string backTexture, optional string highTexture, optional string foreTexture)
{
	local string resultHtml, addHtml;
	local int textSizeWidth, textSizeHeight;

	// 텍스트 사이즈 얻기
	if (len(fontName) > 0) GetTextSize(buttonText, fontName, textSizeWidth, textSizeHeight);
	else GetTextSize(buttonText, "GameDefault", textSizeWidth, textSizeHeight);

	// 버튼 크기 자동 세팅 여부 
	if(nWidth  > 0) addHtml = addHtml $ "width="  $ nWidth  $ " ";
	else addHtml = addHtml $ "width="  $ textSizeWidth + buttonAddWidth $ " ";

	if(nHeight > 0) addHtml = addHtml $ "height=" $ nHeight $ " ";
	else addHtml = addHtml $ "height=" $ textSizeHeight + buttonAddHeight $ " ";

	// 스타일, 폰트, 칼라
	if (len(textStyle) > 0) addHtml = addHtml $ "textstyle=\"" $ textStyle $ "\" ";
	if (len(fontName)  > 0) addHtml = addHtml $ "fontName=\""  $ fontName  $ "\" ";
	if (len(fontColor) > 0) addHtml = addHtml $ "fontColor=\"" $ fontColor $ "\" ";

	// 버튼 텍스쳐 
	if (len(backTexture) > 0) addHtml = addHtml $ "back=\"" $ backTexture $ "\" ";
	else addHtml = addHtml $ "back=\"L2UI_CT1.Button_DF_Down\" ";

	if (len(highTexture) > 0) addHtml = addHtml $ "high=\"" $ highTexture $ "\" ";
	else addHtml = addHtml $ "high=\"L2UI_CT1.Button_DF_Over\" ";

	if (len(foreTexture) > 0) addHtml = addHtml $ "fore=\"" $ foreTexture $ "\" ";
	else addHtml = addHtml $ "fore=\"L2UI_CT1.Button_DF\" ";

	// EV_EVENT_BY_HTML  이벤트로 발생할 이벤트 param 지정
	if (len(actionParam) > 0) addHtml = addHtml $ "action=\"" $ actionParam $ "\" ";
	
	resultHtml =  "<button value=\"" $ buttonText $ "\" " $ addHtml $ "> ";

	return resultHtml;
}

/** Tag , Image 테그 추가 */
function string htmlAddImg(string strTexture, int nWidth, int nHeight)
{
	local string addItemHtml;

	addItemHtml = "<img src=\"" $ strTexture $  "\" width=" $ nWidth $ " height=" $ nHeight $ ">";

	return addItemHtml;
}

/** Tag , line 이미지 추가 */
function string htmlAddLineImg(optional int lineWidth)
{
	if (lineWidth > 0)
		return "<img src=\"L2UI.SquareWhite\" width=" $ lineWidth $ " height=1>";

	return "<img src=\"L2UI.SquareWhite\" width=270 height=1>";
}

/** Tag , 텍스트 font 테그 추가 , FontDefinition.xml 참고 */
function string htmlAddText(string strText, string fontName, optional string fontColor)
{
	local string targetHtml;
	local string addItemHtml;
	
	if (len(fontColor) > 0) addItemHtml = " color=\"" $ fontColor $ "\" ";

	targetHtml = "<font name=\"" $ fontName $ "\"" $ addItemHtml $ ">" $ strText $ "</font>";

	return targetHtml;
}

/** Tag , 텍스트 하이러 링크 (외부) 
 *
 * <a action="url http://lineage2.plaync.com">link text</a>
 * 
 * htmlUrlLinkText("홈페이지", "http://lineage2.plaync.com");
 * 
 **/
function string htmlUrlLinkText(string strText, string url)
{
	local string targetHtml;
		
	targetHtml = "<a action=\"url " $ url $ "\"" $ ">" $ strText $ "</a>";

	return targetHtml;
}

/**
	border  pixels  table의 경계선 굵기  
	width  pixels or %  table의 width  
	height  pixels or %  table의 height  
	bgcolor  XXXXXX  table background color : rgb(x,x,x)  
	cellpadding  pixels  space between the cell wall and the cell content  
	cellspacing  pixels  space between cells  
	background  image file name  background image  
 **/
function string htmlSetTable(out string targetHtml, int border, int width, int height, string backgroundTexture, int cellPadding, int cellspacing)
{
	targetHtml = "<table width=" $ width $ " height=" $ height $ " border=" $ border $ 
				 " cellpadding=" $ cellPadding $ " cellspacing=" $ cellspacing $ " background=\""$ backgroundTexture $ "\">" $ targetHtml $  "</table>";

	return targetHtml;
}

/** 테이블 열 추가 */
function string htmlSetTableTR(out string targetHtml)
{
	targetHtml = "<tr> " $ targetHtml $ "</tr>";
	return targetHtml;
}

/** 테이블 행 추가 */
function string htmlAddTableTD( string strText, string alignStr, string vAlignStr, int width, int height, optional string backgroundTexture, optional bool bWidthFix)
{
	local string addItemHtml;
	
	if (len(alignStr)  > 0) addItemHtml = " align="  $ alignStr  $ " ";
	if (len(vAlignStr) > 0) addItemHtml = " valign=" $ vAlignStr $ " " $ addItemHtml;

	// 고정 width , 원래는 글자에 따라서 자동으로 늘어 난다.
	if (bWidthFix)
	{
		if (width  > 0) addItemHtml = " fixwidth=" $ width $ " " $ addItemHtml;
	}
	else
	{
		if (width  > 0) addItemHtml = " width=" $ width $ " " $ addItemHtml;
	}
	if (height > 0) addItemHtml = " height=" $ height $ " " $ addItemHtml;
	
	if(len(backgroundTexture) > 0) addItemHtml = " background=\"" $ backgroundTexture $ "\" " $ addItemHtml;

	return "<td " $ addItemHtml $">" $ strText $ "</td>";
}
/*
   ex) 테이블 예제

	htmlAdd= "";

	htmlAdd = htmlAddTableTD(htmlAddText("테스트 테스트 크르릉!","hs15" , "FF0000"), "Left"  , "center", 40, 0, "", true) $
			  htmlAddTableTD(htmlAddText("테스트 테스트 크르릉!","hs8"  , "00FF00"), "center", "Bottom", 80, 0, "", true) $ 
			  htmlAddTableTD(htmlAddText("니야옹"               ,"hs9"  , "00FF43"), "Right" , "Top"   , 30, 0, "") $
			  htmlAddTableTD(htmlAddText("멍멍"                 ,"hs16" , "00FF00"), "center", "Bottom", 80, 0, "");

	htmlSetTableTR(htmlAdd);
	htmlSetTable(htmlAdd, 1, 280, 0, "FF0000", 0,0);
 
*/

//<table width=481 height=337 border=0 cellpadding=0 cellspacing=0>
//---------------------------------------------------------------------------------------------------------------

/** 퀘스트 타입에 따른 테그 스트링 */
function string getQuestTypeString(int nQuestType)
{
	local string returnStr;

	switch (nQuestType)
	{
		case 0  : returnStr = GetSystemString( 1795 ); break; // 전직
		case 1  : returnStr = GetSystemString( 7285 ); break; // 혈맹
		case 2  : returnStr = GetSystemString( 7286 ); break; // 공성
		case 3  : returnStr = GetSystemString( 7287 ); break; // 요새전
		case 4  : returnStr = GetSystemString( 7288 ); break; // 영지전
		case 5  : returnStr = GetSystemString( 7276 ); break; // 메인
		case 6  : returnStr = GetSystemString( 7277 ); break; // 서브 
		case 8  : returnStr = GetSystemString( 7278 ); break; // 반복
		case 7  : returnStr = GetSystemString( 7279 ); break; // 일일
		case 9  : returnStr = GetSystemString( 7280 ); break; // 파티
		case 10 : returnStr = GetSystemString( 7281 ); break; // 연합
		case 11 : returnStr = GetSystemString( 7282 ); break; // 월드레이드
		case 12 : returnStr = GetSystemString( 7283 ); break; // 인존
		case 13 : returnStr = GetSystemString( 7284 ); break; // Boss

		default : returnStr = ""; // 혹시[기타] 처리 할일이 있을까 해서..
	}

	return returnStr;		 
}


/** 
 *  말줄임 ... 만들기
 *  
 *  ex) makeShortString("안녕하세요!하나둘", 5, "..");  --> 안녕하세요..  문자열 리턴
 **/
function string makeShortString(string targetString, int maxChar, string dotString)
{
	local string rStr;

	if( len(targetString) > maxChar )
	{
		rStr =  mid(targetString, 0 , maxChar) $ dotString;
	}
	else
	{
		rStr = targetString;
	}

	return rStr;
}

/***
 * 픽셀을 기준으로 말줄임을 한다.
 **/
function string makeShortStringByPixel(string targetString, int maxPixel, string dotString, optional string fontName)
{
	local string fixedText, tempStr;
	local int textWidth, textHeight;
	local int dotWidth, dotHeight;
	local int i;

	if (fontName == "") fontName = "GameDefault";

	// ... 사이즈 
	GetTextSize(dotString, fontName, dotWidth, dotHeight);
	GetTextSize(targetString, fontName, textWidth, textHeight);

	if (textWidth <= maxPixel) fixedText = targetString;
	else
	{	
		fixedText = targetString;
		for (i = 0; i < len(targetString); i++)
		{
			tempStr = Mid(targetString, 0 , i);

			GetTextSize(tempStr, fontName, textWidth, textHeight);

			// .. 붙은 문자열 만들기!
			if (maxPixel < textWidth + dotWidth)
			{
				fixedText = tempStr $ dotString;
				break;
			}
		}
	}

	// Debug("fixedText" @ fixedText);
	return fixedText;
}

// 백터 값이 0.00 ...값으로 모두 들어 오면 true
function bool isVectorZero(Vector loc)
{
	if (int(loc.X) == 0 && int(loc.Y) == 0 && int(loc.Z) == 0)
	{
		return true;
	}
	else 
	{
		return false;
	}   
}


/**
 * 서버 ID를 넣으면 -> 해당 유닛에게 타겟 
 **/
function setTargetByServerID (int serverID) 
{
	local UserInfo userinfo;

	if (serverID != -1)
	{
		if (GetPlayerInfo(userinfo))
		{			
			RequestAction(serverID, userinfo.Loc); // -> HandleTargetUpdate()로 이어짐			
		}	
	} 
}

/** 숫자를 bool 로 변환 */
function bool numToBool (int bNum)
{
	if(bNum > 0) return true;
	else return false;
}

/** bool를 숫자로 변환 */
function int boolToNum (bool num)
{
	if(num) return 1;
	else return 0;
}

/** 칼라 를 리턴한다. */
function Color getColor (int r, int g, int b, int a)
{
	local Color tColor;
	tColor.R = r;
	tColor.G = g;
	tColor.B = b;	
	tColor.A = a;	

	return tColor;
}

// 이름 + AdditionalName
function string GetItemNameWithAdditional(ItemInfo info)
{
	local string fullName, addStr;

	//ensoulOptionAllName = GetEnsoulOptionNameAll(info);

	// 인챈트, 옵션, AdditionalName
	// if(info.Enchanted > 0) fullName = "+"$ String(info.Enchanted);	

	if (Len(fullName) > 0)
	{
		fullName = fullName $ " " $ info.name;
	}
	else fullName = info.name;

	if (len(info.AdditionalName) > 0) addStr = addStr $ " " $ info.AdditionalName;
	//if (len(ensoulOptionAllName) > 0) addStr = addStr $ " " $ ensoulOptionAllName;

	
	fullName = fullName $ addStr;
	
	return fullName;
}

function string GetItemNameAllBySeverID(int serverID)
{
	local ItemInfo info;
	local string itemNameStr;

	class'UIDATA_INVENTORY'.static.FindItem(serverID, info);

	itemNameStr = GetItemNameAll(info);

	Debug("itemNameStr:::::  " @ itemNameStr);
	return itemNameStr;
}

// 기본적으로 사용하는 공통된 아이템 이름을 리턴한다.
function string GetItemNameAll(ItemInfo info)
{
	local string ensoulOptionAllName, fullName, addStr;

	ensoulOptionAllName = GetEnsoulOptionNameAll(info);

	// 인챈트, 옵션, AdditionalName
	if(info.Enchanted > 0) fullName = "+"$ String(info.Enchanted);	

	if (Len(fullName) > 0)
	{
		fullName = fullName $ " " $ info.name;
	}
	else fullName = info.name;

	if (len(info.AdditionalName) > 0) addStr = addStr $ " " $ info.AdditionalName;
	if (len(ensoulOptionAllName) > 0) addStr = addStr $ " " $ ensoulOptionAllName;

	
	fullName = fullName $ addStr;
	
	return fullName;
}

// 무기에 적용된 집혼석 옵션의 이름 전체를 받아온다.
// 툴팁에서 사용하려고 일단 만듬. 
function string GetEnsoulOptionNameAll(ItemInfo weaponInfo)
{
	local EnsoulOptionUIInfo eOptionInfo;
	local int i, n, cnt, optionID;

	local string allName;

	// 집혼 시스템 개편 (2015-02-09 추가)
	for(i=EIST_NORMAL; i<EIST_MAX; i++)
	{
		cnt = weaponInfo.EnsoulOption[i - EIST_NORMAL].OptionArray.Length;

		for(n=EISI_START; n<EISI_START + cnt; n++)		
		{
			optionID = weaponInfo.EnsoulOption[i - EIST_NORMAL].OptionArray[n - EISI_START];

			// [해외 TTP 머징] - 
			// ttp71868 추출 후 optionID가 0이여도 집혼 이름이 중복되게 나오는 문제 수정. 
			if (optionID <= 0) continue;

			GetEnsoulOptionUIInfo(optionID, eOptionInfo);

			if (eOptionInfo.name != "")
			{
				if (allName == "")	
					allName = eOptionInfo.name;     
				else
					allName = allName $ "/" $ eOptionInfo.name;     
			}
		}
	}

	return allName;
}

// 집혼 옵션이 포함되어 있나?
function bool hasEnsoulOption(ItemInfo weaponInfo)
{
	local EnsoulOptionUIInfo eOptionInfo;
	local int i, n, cnt, optionID;


	// 집혼 시스템 개편 (2015-02-09 추가)
	for(i=EIST_NORMAL; i<EIST_MAX; i++)
	{
		cnt = weaponInfo.EnsoulOption[i - EIST_NORMAL].OptionArray.Length;

		for(n=EISI_START; n<EISI_START + cnt; n++)		
		{
			optionID = weaponInfo.EnsoulOption[i - EIST_NORMAL].OptionArray[n - EISI_START];

			// Debug("optionID--------------------->" @ optionID);
			GetEnsoulOptionUIInfo(optionID, eOptionInfo);
			if (eOptionInfo.name != "")
			{
				return true;
			}
		}
	}

	return false;
}

// 집혼 정보 param 형태로 추가 2015-03-18
function addParamEnsoulOptionInfo(ItemInfo info, out string param)
{
	local int i, n, cnt;
	for(i=EIST_NORMAL; i<EIST_MAX; i++)
	{
		cnt = info.EnsoulOption[i - EIST_NORMAL].OptionArray.Length;

		ParamAdd(param, "EnsoulOptionNum_" $ String(i), String(cnt));

		for(n=EISI_START; n < EISI_START + cnt; n++)
		{
			ParamAdd(param, "EnsoulOptionID_" $ String(i) $ "_" $ string(n) , String(info.EnsoulOption[i - EIST_NORMAL].OptionArray[n - EISI_START]));
		}
	}
}

// addParamEnsoulOptionInfo 반대, param String 에서 info로 정보 추가
function addEnsoulInfoToItemInfoByParamString(string param, out ItemInfo info)
{
	local int i, n, cnt, tmpInt;

	for(i=EIST_NORMAL; i<EIST_MAX; i++)
	{
		ParseInt( param, "EnsoulOptionNum_" $ i, cnt);
		info.EnsoulOption[i - EIST_NORMAL].OptionArray.Length = cnt;

		for(n = EISI_START; n < EISI_START + cnt; n++)
		{
			ParseInt(param, "EnsoulOptionID_" $ String(i) $ "_" $ string(n) , tmpInt);
			info.EnsoulOption[i - EIST_NORMAL].OptionArray[n - EISI_START] = tmpInt;
		}
	}
}

// 9999+ 같은 최대 표시를 위한 함수
//EnsoulOptionWnd_Charge3_TextBox.SetText("(" $ maxCountLimitString(InvenJamStoneInfo.ItemNum, 9999, "9999+") $ ")");
function string maxCountLimitString(Int64 count, Int64 maxCount, string returnStr)
{
	local string rValue;

	if (count > maxCount)
	{
		rValue = returnStr;
	}
	else
	{
		rValue = string(count);
	}

	return rValue;
}

// 초를 넣어서, 일 ~ 1분 미만 까지 표현 하는 함수
function string getStringDayAndTime(int tmpTime)
{
	local int tmpDay;
	local int tmpHou;
	local int tmpMin;	
	local string timeStr;
	
	
	local int minToHou;
	local int minToDay;
	
	minToHou = 60;
	minToDay = minToHou * 24;
	
	tmpMin = tmpTime/60; 

	if ( tmpMin > minToDay ) {//일 // 시간만		
		tmpHou = tmpMin/60;
		tmpDay = tmpHou/24;
		tmpHou = tmpHou - tmpDay*24;	
		if ( tmpHou != 0 ){
			timeStr = MakeFullSystemMsg( GetSystemMessage(3503), (String(tmpDay)), string (tmpHou) );
		} else {
			timeStr = MakeFullSystemMsg( GetSystemMessage(3418),  (String(tmpDay)));
		}
	} else if ( tmpMin > 60 ) {//시간 분만
		tmpHou = tmpMin/60;
		tmpMin = tmpMin - tmpHou*60;
		if( tmpMin != 0 ){
			timeStr = MakeFullSystemMsg( GetSystemMessage(3304), string(tmpHou), string (tmpMin) );
		} else {
			timeStr = MakeFullSystemMsg( GetSystemMessage(3406), string(tmpHou) );
		}
	} 
	else if (tmpTime > 60) { //분만
		timeStr = MakeFullSystemMsg( GetSystemMessage(3390), string (tmpMin));
	}
	else { // 1분 미만
		timeStr = MakeFullSystemMsg( GetSystemMessage(4360), string (1));
	}

	return timeStr;
}

// 아레나 관련 스테이지 인가?
function bool isAreaState()
{
	local string stateStr;
	local bool bReturn;

	stateStr = GetGameStateName();

	if (stateStr == "ARENAGAMINGSTATE" || stateStr == "ARENABATTLESTATE") bReturn = true;
	else bReturn = false;

	return bReturn;
}

	//DOMINION,                    //0
	//FIELD_HUNTING_ZONE_SOLO,     //1
	//FIELD_HUNTING_ZONE_PARTY,    //2
	//INSTANCE_ZONE_SOLO,          //3
	//INSTANCE_ZONE_PARTY,         //4
	//AGIT,                        //5
	//VILLAGE,                     //6
	//ETC,                         //7
	//CASTLE,                      //8
	//FORTRESS,                    //9

function string getHuntingZoneTypeString(int nHuntingZoneType)
{
	local string tmpStr;

	if (nHuntingZoneType == 0)      tmpStr = GetSystemString(1312);  //영지
	else if (nHuntingZoneType == 1) tmpStr = GetSystemString(3517);  //솔로 사냥터
	else if (nHuntingZoneType == 2) tmpStr = GetSystemString(3518);  //파티 사냥터
	else if (nHuntingZoneType == 3) tmpStr = GetSystemString(3542);  //솔로 인스턴스 존
	else if (nHuntingZoneType == 4) tmpStr = GetSystemString(3543);  //파티 인스턴스 존
	else if (nHuntingZoneType == 5) tmpStr = GetSystemString(1317);  //아지트
	else if (nHuntingZoneType == 6) tmpStr = GetSystemString(1270);  //마을
	else if (nHuntingZoneType == 7) tmpStr = GetSystemString(7299);  //기타
	else if (nHuntingZoneType == 8) tmpStr = GetSystemString(3546);  //성
	else if (nHuntingZoneType == 9) tmpStr = GetSystemString(3547);  //요새
	else if (nHuntingZoneType == 10) tmpStr = GetSystemString(3548); //솔로/파티 사냥터

	return tmpStr;
}

// 레이드 몬스터의 영지 정보를 리턴. (추후 가능하면 클라 쪽에서 돌려 달라고 하는게 좋겠음)
// 함수 이름이 좀 이상하다고 생각 됨..-_-...
function string getRaidZoneName(int search_zoneid)
{
	local string HuntingZoneName; 
	local int i;

	for(i = 0; i < 500 ; i++)
	{
		//debug( "conv_zoneName i=" $ i );
		
		if(class'UIDATA_HUNTINGZONE'.static.IsValidData(i))
		{
			// 영지와 같다면..
			if(class'UIDATA_HUNTINGZONE'.static.GetHuntingZoneType(i) == 0)
			{
				if (class'UIDATA_HUNTINGZONE'.static.GetHuntingZone(i) == search_zoneid)
				{
					HuntingZoneName = class'UIDATA_HUNTINGZONE'.static.GetHuntingZoneName(i); 
				}
			}
		}	
	}
	return HuntingZoneName;
}

// 데이타가 더 있는데 대략 이정도면 빈 구조체인지 확인 가능
function bool IsValidDataForHuntingZoneUIData(HuntingZoneUIData info)
{
	if(info.strName == "" && 
	   info.nType == 0 &&
	   info.nMinLevel == 0 &&
	   info.nMaxLevel == 0 &&
	   info.nMinLevel == 0 &&
	   info.nSearchZoneID == 0 &&
	   info.nRegionID == 0 &&
	   info.nNpcID == 0) return false;

	return true;
}

// 레벨 체크
function bool tryLevelCheck(int userLevel, int minLevel, int maxLevel)
{
	if(userLevel >= minLevel && userLevel <= maxLevel) 
	{
		return true;
	}

	return false;
}

// 벡터 값이 0인가?
function bool isVectorZeroXYZ(float x, float y, float z)
{
	if (x == 0 && y == 0 && z == 0)
	{
		return true;
	}

	return false;
}


//------------------------------------------------------------------------------------------------
// 헌팅 존 관련 함수
//------------------------------------------------------------------------------------------------
function int getHuntingZoneIndexByName(string huntingZoneName)
{
	local int i, r;

	r = -1;
	for (i = 0; i < 500; i++)
	{
		if(class'UIDATA_HUNTINGZONE'.static.IsValidData(i))
		{
			if(class'UIDATA_HUNTINGZONE'.static.GetHuntingZoneName(i) == huntingZoneName)
			{
				r = i;
				break;
			}
		}
	}

	return r;
}

// 레이드 정보 , 구조체로 받기
function RaidUIData getRaidDataByIndex(int index)
{
	local RaidUIData pRaidUIData;

	if(class'UIDATA_RAID'.static.IsValidData(index))
	{
		pRaidUIData.id = index;
		pRaidUIData.nRaidMonsterID    = class'UIDATA_RAID'.static.GetRaidMonsterID(index);			
		pRaidUIData.nRaidMonsterLevel = class'UIDATA_RAID'.static.GetRaidMonsterLevel(index);
		pRaidUIData.nRaidMonsterZone  = class'UIDATA_RAID'.static.GetRaidMonsterZone(index);

		pRaidUIData.raidDesc          = class'UIDATA_RAID'.static.GetRaidDescription(index);
		pRaidUIData.raidMonsterName   = class'UIDATA_NPC'.static.GetNPCName(pRaidUIData.nRaidMonsterID);
		pRaidUIData.nWorldLoc         = class'UIDATA_RAID'.static.GetRaidLoc(index);

		pRaidUIData.RaidMonsterZoneName  = getRaidZoneName(pRaidUIData.nRaidMonsterZone);

		class'UIDATA_RAID'.static.GetRaidRecommendLevel(index, pRaidUIData.nMinLevel, pRaidUIData.nMaxLevel);
	}

	return pRaidUIData;
}

function Vector setVector(int x, int y, int z)
{
	local Vector loc;

	loc.x = x;
	loc.y = y;
	loc.z = z;
	return loc;
}
defaultproperties
{
}
