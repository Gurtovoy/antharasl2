class CalculatorWnd extends UICommonAPI;

const MAX_NUMERIC_LENGTH = 17	;

enum EOperator
{
	OP_None,
	OP_PLUS,
	OP_MINUS,
	OP_MULTIPLY,
	OP_DIVIDE,
};

var INT64 m_Operand1;
var EOperator m_Operator;

var EditBoxHandle m_ResultEditBox;

function OnRegisterEvent()
{
	RegisterEvent( EV_CalculatorWndShowHide );
}

function OnLoad()
{
	SetClosingOnESC();

	if(CREATE_ON_DEMAND==0)
		OnRegisterEvent();
	m_ResultEditBox = GetEditBoxHandle("CalculatorWnd.editBoxCalculate");
	m_ResultEditBox.DisableWindow();
}

function OnShow()
{
	InitCalculator();
}

function InitCalculator()
{
	m_Operand1 = 0;
	SetOperator(OP_None);
	GotoState('Operand1');
	CE();
}

function CE()
{
	SetNumeric(0);
}

function SetOperand1(INT64 a_Operand)
{
	m_Operand1 = a_Operand;
}

function SetOperator(EOperator op)
{
	m_Operator = op;
}

function AddString(string str)
{
	m_ResultEditBox.AddString(str);
}

function SetString(string str)
{
	m_ResultEditBox.SetString(str);
}

function string GetString()
{
	return m_ResultEditBox.GetString();
}

function INT64 GetOperand()
{
//	SetCommaStr();
	local string str;
	str=GetString();

	if(Len(str)>0) 
		return INT64(str);
	else 
		return 0;
}

function INT64 Calc(INT64 A, INT64 B, EOperator op)
{
	local INT64 nResult;
		
	switch(op)
	{
	case OP_PLUS: 
		nResult = A+B;
		break;
	case OP_MINUS: 
		nResult = A-B;
		break;
	case OP_MULTIPLY:
		nResult = A*B;
		break;
	case OP_DIVIDE: 
		if(B == 0)
			nResult = 0;
		else
			nResult = A/B;
		break;
	case OP_None:
		nResult = 0;
		break;
	}

	return nResult;
}

function BackSpace()
{
	local string strTemp;
	local string strResult;
	local int iLength;

	strTemp=GetString();

	iLength=Len(strTemp)-1;

//	debug("BackSpace:"$strTemp$", "$iLength);

	if(iLength>0)
	{
		strResult=Left(strTemp, iLength);
		SetString(strResult);
	}
	else
	{
		CE();
	}
}


function OnEvent( int Event_ID, string param )
{
	switch( Event_ID )
	{
	case EV_CalculatorWndShowHide :
		ShowWindowWithFocus("CalculatorWnd");
		break;
	}
}

function AddNumeric(int a_Number)
{
	local string currentNumeric;
	currentNumeric = GetString();
	if(currentNumeric == "0")
		SetNumeric(a_Number);
	else if(Len(currentNumeric) < MAX_NUMERIC_LENGTH)
		AddString(string(a_Number));
}

function SetNumeric(INT64 a_Number)
{
	local DialogBox script;
	local string newNumeric;
	
	script = DialogBox( GetScript("DialogBox") );	
	newNumeric = string(a_Number);

	if(Len(newNumeric) <= MAX_NUMERIC_LENGTH)
		SetString(newNumeric);
	else
	{
		script.ShowDialog(DialogModalType_Modalless,DialogType_Notice,GetSYSTEMMessage(3093),"CalculatorWnd");
		CE();
	}
}

function ProcessNumeric(int a_Number);
function ProcessOperator(EOperator a_Operator);
function ProcessEqual();

auto state Operand1
{
	ignores ProcessEqual;

	function ProcessNumeric(int a_Number)
	{
		AddNumeric(a_Number);
	}

	function ProcessOperator(EOperator a_Operator)
	{
		SetOperator(a_Operator);
		SetOperand1(GetOperand());
		GotoState('ReadyForOperand2');
	}
}

state ReadyForOperand2
{
	function ProcessNumeric(int a_Number)
	{
		SetNumeric(a_Number);
		GotoState('Operand2');
	}

	function ProcessOperator(EOperator a_Operator)
	{
		SetOperator(a_Operator);
		SetOperand1(GetOperand());
	}

	function ProcessEqual()
	{
		SetNumeric(Calc(m_Operand1, GetOperand(), m_Operator));
	}
}

state Operand2
{
	function ProcessNumeric(int a_Number)
	{
		AddNumeric(a_Number);
	}

	function ProcessOperator(EOperator a_Operator)
	{
		local INT64 result;
		result = Calc(m_Operand1, GetOperand(), m_Operator);
		SetNumeric(result);
		SetOperand1(result);
		SetOperator(a_Operator);
		GotoState('ReadyForOperand2');
	}

	function ProcessEqual()
	{
		local INT64 operand2;
		operand2 = GetOperand();
		SetNumeric(Calc(m_Operand1, operand2, m_Operator));
		SetOperand1(operand2);
		GotoState('ReadyForOperand1');
	}
}

state ReadyForOperand1
{
	function ProcessNumeric(int a_Number)
	{
		SetNumeric(a_Number);
		GotoState('Operand1');
	}

	function ProcessOperator(EOperator a_Operator)
	{
		//~ local int result;
		SetOperand1(GetOperand());
		SetOperator(a_Operator);
		GotoState('ReadyForOperand2');
	}

	function ProcessEqual()
	{
		SetNumeric(Calc(GetOperand(), m_Operand1, m_Operator));
	}
}

function ProcessBtn(EInputKey iValue)
{
	local int inputNumeric;
	local EOperator inputOperator;

	// 숫자키일 경우의 처리
 	if(EInputKey.IK_0 <= iValue && iValue <= EInputKey.IK_9
		|| EInputKey.IK_NumPad0 <= iValue && iValue <= EInputKey.IK_NumPad9)
	{
		if(EInputKey.IK_0 <= iValue && iValue <= EInputKey.IK_9)
			inputNumeric = iValue - EInputKey.IK_0;
		else
			inputNumeric = iValue - EInputKey.IK_NumPad0;
		ProcessNumeric(inputNumeric);
	}
	else if(iValue == IK_GreyStar || iValue == IK_GreyPlus || iValue == IK_GreyMinus || iValue == IK_Minus || iValue == IK_GreySlash)
	{
		switch(iValue)
		{
		case IK_GreyStar:
			inputOperator = OP_MULTIPLY;
			break;
		case IK_GreyPlus:
			inputOperator = OP_PLUS;
			break;
		case IK_GreyMinus:
		case IK_Minus:
			inputOperator = OP_MINUS;
			break;
		case IK_GreySlash:
			inputOperator = OP_DIVIDE;
			break;
		default:
			inputOperator = OP_None;
			break;
		}
		ProcessOperator(inputOperator);
	}
	else if(iValue == IK_Enter || iValue == IK_Equals)
		ProcessEqual();
	else if(iValue == IK_Escape)
		InitCalculator();
	else if(iValue == IK_Backspace)
		BackSpace();
}


function OnClickButton(string strID)
{
	switch(strID)
	{
	case "btn0": 
		ProcessBtn(IK_0); 
		break;
	case "btn1": 
		ProcessBtn(IK_1); 
		break;
	case "btn2": 
		ProcessBtn(IK_2); 
		break;
	case "btn3": 
		ProcessBtn(IK_3); 
		break;
	case "btn4": 
		ProcessBtn(IK_4); 
		break;
	case "btn5": 
		ProcessBtn(IK_5); 
		break;
	case "btn6": 
		ProcessBtn(IK_6); 
		break;
	case "btn7": 
		ProcessBtn(IK_7); 
		break;
	case "btn8": 
		ProcessBtn(IK_8); 
		break;
	case "btn9": 
		ProcessBtn(IK_9);
		break;
	case "btnAdd": 
		ProcessBtn(IK_GreyPlus);
		break;
	case "btnCE":
		CE();
		break;	
	case "btnSub": 
		ProcessBtn(IK_GreyMinus);
		break;
	case "btnC":
		ProcessBtn(IK_Escape);
		break;
	case "btnMul":
		ProcessBtn(IK_GreyStar);
		break;
	case "btnBS": 
		ProcessBtn(IK_Backspace);
		break;		
	case "btn00": 
		ProcessBtn(IK_0);
		ProcessBtn(IK_0);
		break;
	case "btnDiv": 
		ProcessBtn(IK_GreySlash); 
		break;
	case "btnEQ": 
		ProcessBtn(IK_Enter); 
		break;
	case "btnClose":
		class'UIAPI_WINDOW'.static.HideWindow("CalculatorWnd");
		break;
	}
}


function onKeyUp( WindowHandle a_WindowHandle, EInputKey Key )
{
	// 키보드 입력 처리 
	ProcessBtn(Key);
}

/**
 * 윈도우 ESC 키로 닫기 처리 
 * "Esc" Key
 ***/
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( "CalculatorWnd" ).HideWindow();
}
defaultproperties
{
}
