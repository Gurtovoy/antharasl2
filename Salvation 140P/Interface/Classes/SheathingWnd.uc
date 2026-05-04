class SheathingWnd extends UICommonAPI;

var string m_WindowName;


var WindowHandle m_hWnd;

var WindowHandle m_hAnimBlendingWnd;

var EditBoxHandle	m_hEbLeftAttachBoneName;
var ButtonHandle	m_hBtnLeftApplyAttachBoneName;

var EditBoxHandle	m_hEbLeftRotPitch;
var EditBoxHandle	m_hEbLeftRotYaw;
var EditBoxHandle	m_hEbLeftRotRoll;
var ButtonHandle	m_hBtnLeftApplyAttachRotation;

var EditBoxHandle	m_hEbLeftOffsetX;
var EditBoxHandle	m_hEbLeftOffsetY;
var EditBoxHandle	m_hEbLeftOffsetZ;
var ButtonHandle	m_hBtnLeftApplyOffset;

var EditBoxHandle	m_hEbLeftMantleOffsetX;
var EditBoxHandle	m_hEbLeftMantleOffsetY;
var EditBoxHandle	m_hEbLeftMantleOffsetZ;
var ButtonHandle	m_hBtnLeftApplyMantleOffset;

var ComboBoxHandle	m_hCbLeftSheathingHide;


var EditBoxHandle	m_hEbRightAttachBoneName;
var ButtonHandle	m_hBtnRightApplyAttachBoneName;

var EditBoxHandle	m_hEbRightRotPitch;
var EditBoxHandle	m_hEbRightRotYaw;
var EditBoxHandle	m_hEbRightRotRoll;
var ButtonHandle	m_hBtnRightApplyAttachRotation;

var EditBoxHandle	m_hEbRightOffsetX;
var EditBoxHandle	m_hEbRightOffsetY;
var EditBoxHandle	m_hEbRightOffsetZ;
var ButtonHandle	m_hBtnRightApplyOffset;

var EditBoxHandle	m_hEbRightMantleOffsetX;
var EditBoxHandle	m_hEbRightMantleOffsetY;
var EditBoxHandle	m_hEbRightMantleOffsetZ;
var ButtonHandle	m_hBtnRightApplyMantleOffset;

var ComboBoxHandle	m_hCbRightSheathingHide;

var ButtonHandle	m_hBtnPlaySheathingAnim;



function OnRegisterEvent()
{
	RegisterEvent(EV_ShowSheathingWnd);
	RegisterEvent(EV_SheathingInfo);
}

function OnLoad()
{
	InitializeHandle();
	m_hWnd.SetWindowTitle(m_WindowName);
}

function InitializeHandle()
{
	m_hWnd=GetWindowHandle(m_WindowName);

	m_hEbLeftAttachBoneName=GetEditBoxHandle(m_WindowName$".ebLeftAttachBoneName");
	m_hBtnLeftApplyAttachBoneName=GetButtonHandle(m_WindowName$".btnLeftApplyAttachBoneName");

	m_hEbLeftRotPitch=GetEditBoxHandle(m_WindowName$".ebLeftAttachRotationPitch");
	m_hEbLeftRotYaw=GetEditBoxHandle(m_WindowName$".ebLeftAttachRotationYaw");
	m_hEbLeftRotRoll=GetEditBoxHandle(m_WindowName$".ebLeftAttachRotationRoll");
	m_hBtnLeftApplyAttachRotation=GetButtonHandle(m_WindowName$".btnLeftApplyAttachRotation");

	m_hEbLeftOffsetX=GetEditBoxHandle(m_WindowName$".ebLeftAttachOffsetX");
	m_hEbLeftOffsetY=GetEditBoxHandle(m_WindowName$".ebLeftAttachOffsetY");
	m_hEbLeftOffsetZ=GetEditBoxHandle(m_WindowName$".ebLeftAttachOffsetZ");
	m_hBtnLeftApplyOffset=GetButtonHandle(m_WindowName$".btnLeftApplyAttachOffset");

	m_hEbLeftMantleOffsetX=GetEditBoxHandle(m_WindowName$".ebLeftMantleOffsetX");
	m_hEbLeftMantleOffsetY=GetEditBoxHandle(m_WindowName$".ebLeftMantleOffsetY");
	m_hEbLeftMantleOffsetZ=GetEditBoxHandle(m_WindowName$".ebLeftMantleOffsetZ");
	m_hBtnLeftApplyMantleOffset=GetButtonHandle(m_WindowName$".btnLeftApplyMantleOffset");

	m_hCbLeftSheathingHide=GetComboBoxHandle(m_WindowName$".cbLeftHideSheathing");


	m_hEbRightAttachBoneName=GetEditBoxHandle(m_WindowName$".ebRightAttachBoneName");
	m_hBtnRightApplyAttachBoneName=GetButtonHandle(m_WindowName$".btnRightApplyAttachBoneName");

	m_hEbRightRotPitch=GetEditBoxHandle(m_WindowName$".ebRightAttachRotationPitch");
	m_hEbRightRotYaw=GetEditBoxHandle(m_WindowName$".ebRightAttachRotationYaw");
	m_hEbRightRotRoll=GetEditBoxHandle(m_WindowName$".ebRightAttachRotationRoll");
	m_hBtnRightApplyAttachRotation=GetButtonHandle(m_WindowName$".btnRightApplyAttachRotation");

	m_hEbRightOffsetX=GetEditBoxHandle(m_WindowName$".ebRightAttachOffsetX");
	m_hEbRightOffsetY=GetEditBoxHandle(m_WindowName$".ebRightAttachOffsetY");
	m_hEbRightOffsetZ=GetEditBoxHandle(m_WindowName$".ebRightAttachOffsetZ");
	m_hBtnRightApplyOffset=GetButtonHandle(m_WindowName$".btnRightApplyAttachOffset");

	m_hEbRightMantleOffsetX=GetEditBoxHandle(m_WindowName$".ebRightMantleOffsetX");
	m_hEbRightMantleOffsetY=GetEditBoxHandle(m_WindowName$".ebRightMantleOffsetY");
	m_hEbRightMantleOffsetZ=GetEditBoxHandle(m_WindowName$".ebRightMantleOffsetZ");
	m_hBtnRightApplyMantleOffset=GetButtonHandle(m_WindowName$".btnRightApplyMantleOffset");

	m_hCbRightSheathingHide=GetComboBoxHandle(m_WindowName$".cbRightHideSheathing");

	m_hBtnPlaySheathingAnim=GetButtonHandle(m_WindowName$".btnPlaySheathingAnim");
}

function OnEvent( int a_EventID, String Param )
{
//	debug(""$a_EventID @ Param);
	switch( a_EventID )
	{
	case EV_ShowSheathingWnd :
		m_hWnd.ShowWindow();
		break;
	case EV_SheathingInfo :
		HandleSheathingInfo(Param);
		break;
	}
}

function HandleSheathingInfo(string Param)
{
	local string leftBoneName;
	local int leftRotPitch;
	local int leftRotYaw;
	local int leftRotRoll;
	local float leftOffsetX;
	local float leftOffsetY;
	local float leftOffsetZ;
	local float leftMantleOffsetX;
	local float leftMantleOffsetY;
	local float leftMantleOffsetZ;
	local int	leftHideSheathing;

	local string RightBoneName;
	local int RightRotPitch;
	local int RightRotYaw;
	local int RightRotRoll;
	local float RightOffsetX;
	local float RightOffsetY;
	local float RightOffsetZ;
	local float RightMantleOffsetX;
	local float RightMantleOffsetY;
	local float RightMantleOffsetZ;
	local int	RightHideSheathing;


	ParseString(Param, "LeftBoneName", leftBoneName);
	ParseInt(Param, "LeftRotationPitch", LeftRotPitch);
	ParseInt(Param, "LeftRotationYaw", LeftRotYaw);
	ParseInt(Param, "LeftRotationRoll", LeftRotRoll);
	ParseFloat(Param, "LeftOffsetX", LeftOffsetX);
	ParseFloat(Param, "LeftOffsetY",LeftOffsetY);
	ParseFloat(Param, "LeftOffsetZ", LeftOffsetZ);
	ParseFloat(Param, "LeftMantleOffsetX", leftMantleOffsetX);
	ParseFloat(Param, "LeftMantleOffsetY", leftMantleOffsetY);
	ParseFloat(Param, "LeftMantleOffsetZ", leftMantleOffsetZ);
	ParseInt(Param, "LeftHideSheathing", leftHideSheathing);

	ParseString(Param, "RightBoneName", RightBoneName);
	ParseInt(Param, "RightRotationPitch", RightRotPitch);
	ParseInt(Param, "RightRotationYaw", RightRotYaw);
	ParseInt(Param, "RightRotationRoll", RightRotRoll);
	ParseFloat(Param, "RightOffsetX", RightOffsetX);
	ParseFloat(Param, "RightOffsetY",RightOffsetY);
	ParseFloat(Param, "RightOffsetZ", RightOffsetZ);
	ParseFloat(Param, "RightMantleOffsetX", RightMantleOffsetX);
	ParseFloat(Param, "RightMantleOffsetY", RightMantleOffsetY);
	ParseFloat(Param, "RightMantleOffsetZ", RightMantleOffsetZ);
	ParseInt(Param, "RightHideSheathing", RightHideSheathing);

	m_hEbLeftAttachBoneName.SetString(leftBoneName);

	m_hEbLeftRotPitch.SetString(string(leftROtPitch));
	m_hEbLeftRotYaw.SetString(string(leftRotYaw));
	m_hEbLeftRotRoll.SetString(string(LeftRotRoll));

	m_hEbLeftOffsetX.SetString(string(LeftOffsetX));
	m_hEbLeftOffsetY.SetString(string(LeftOffsetY));
	m_hEbLeftOffsetZ.SetString(string(LeftOffsetZ));

	m_hEbLeftMantleOffsetX.SetString(string(LeftMantleOffsetX));
	m_hEbLeftMantleOffsetY.SetString(string(LeftMantleOffsetY));
	m_hEbLeftMantleOffsetZ.SetString(string(LeftMantleOffsetZ));

	m_hCbLeftSheathingHide.SetSelectedNum(LeftHideSheathing);

	m_hEbRightAttachBoneName.SetString(RightBoneName);

	m_hEbRightRotPitch.SetString(string(RightROtPitch));
	m_hEbRightRotYaw.SetString(string(RightRotYaw));
	m_hEbRightRotRoll.SetString(string(RightRotRoll));

	m_hEbRightOffsetX.SetString(string(RightOffsetX));
	m_hEbRightOffsetY.SetString(string(RightOffsetY));
	m_hEbRightOffsetZ.SetString(string(RightOffsetZ));

	m_hEbRightMantleOffsetX.SetString(string(RightMantleOffsetX));
	m_hEbRightMantleOffsetY.SetString(string(RightMantleOffsetY));
	m_hEbRightMantleOffsetZ.SetString(string(RightMantleOffsetZ));

	m_hCbRightSheathingHide.SetSelectedNum(RightHideSheathing);
}


function OnClickButtonWithHandle(ButtonHandle a_WindowHandle)
{
	local string str1;
	local string str2;
	local string str3;

	local string str4;
	local string str5;
	local string str6;

	local float X;
	local float Y;
	local float Z;


//	debug("Name:"$a_WindowHandle.GetWindowName());

	if(a_WindowHandle==m_hBtnLeftApplyAttachBoneName)
	{
		str1=m_hEbLeftAttachBoneName.GetString();
		class'UIDATA_PAWNVIEWER'.static.ApplyLeftAttachBoneName(str1);
	}
	else if(a_WindowHandle==m_hBtnLeftApplyAttachRotation)
	{
		str1=m_hEbLeftRotPitch.GetString();
		str2=m_hEbLeftRotYaw.GetString();
		str3=m_hEbLeftRotRoll.GetString();
		class'UIDATA_PAWNVIEWER'.static.ApplyLeftRotation(int(str1), int(str2), int(str3));
	}
	else if(a_WindowHandle==m_hBtnLeftApplyOffset)
	{
		str1=m_hEbLeftOffsetX.GetString();
		str2=m_hEbLeftOffsetY.GetString();
		str3=m_hEbLeftOffsetZ.GetString();
		class'UIDATA_PAWNVIEWER'.static.ApplyLeftOffset(float(str1), float(str2), float(str3));
	}
	else if(a_WindowHandle==m_hBtnLeftApplyMantleOffset)
	{
		str1=m_hEbLeftOffsetX.GetString();
		str2=m_hEbLeftOffsetY.GetString();
		str3=m_hEbLeftOffsetZ.GetString();

		str4=m_hEbLeftMantleOffsetX.GetString();
		str5=m_hEbLeftMantleOffsetY.GetString();
		str6=m_hEbLeftMantleOffsetZ.GetString();
		X=float(str1)+float(str4);
		Y=float(str2)+float(str5);
		Z=float(str3)+float(str6);
		class'UIDATA_PAWNVIEWER'.static.ApplyLeftOffset(X, Y, Z);
	}

	// ¿À¸¥¼Õ
	else if(a_WindowHandle==m_hBtnRightApplyAttachBoneName)
	{
		str1=m_hEbRightAttachBoneName.GetString();
		class'UIDATA_PAWNVIEWER'.static.ApplyRightAttachBoneName(str1);
	}
	else if(a_WindowHandle==m_hBtnRightApplyAttachRotation)
	{
		str1=m_hEbRightRotPitch.GetString();
		str2=m_hEbRightRotYaw.GetString();
		str3=m_hEbRightRotRoll.GetString();
		debug(""$str1$", "$str2$", "$str3);
		class'UIDATA_PAWNVIEWER'.static.ApplyRightRotation(int(str1), int(str2), int(str3));
	}
	else if(a_WindowHandle==m_hBtnRightApplyOffset)
	{
		str1=m_hEbRightOffsetX.GetString();
		str2=m_hEbRightOffsetY.GetString();
		str3=m_hEbRightOffsetZ.GetString();
		debug(""$str1$", "$str2$", "$str3);
		class'UIDATA_PAWNVIEWER'.static.ApplyRightOffset(float(str1), float(str2), float(str3));
	}
	else if(a_WindowHandle==m_hBtnRightApplyMantleOffset)
	{
		str1=m_hEbRightOffsetX.GetString();
		str2=m_hEbRightOffsetY.GetString();
		str3=m_hEbRightOffsetZ.GetString();

		str4=m_hEbRightMantleOffsetX.GetString();
		str5=m_hEbRightMantleOffsetY.GetString();
		str6=m_hEbRightMantleOffsetZ.GetString();

		X=float(str1)+float(str4);
		Y=float(str2)+float(str5);
		Z=float(str3)+float(str6);
		class'UIDATA_PAWNVIEWER'.static.ApplyRightOffset(X, Y, Z);
	}

	else if(a_WindowHandle==m_hBtnPlaySheathingAnim)
	{
		ExecuteCommand("///playsheathinganim");
	}
//		m_hEbAnimName0.SetString(m_hCharAnimListBox.GetSelectedString());
}

function OnComboBoxItemSelected( String strID, int index )
{
	local bool bHide;
	switch(strID)
	{
	case "cbLeftHideSheathing" :
		bHide=bool(m_hCbLeftSheathingHide.GetSelectedNum());
		debug(""$string(bHide));
		class'UIDATA_PAWNVIEWER'.static.ApplyLeftSheathingHide(bHide);
		break;
	case "cbRightHideSheathing" :
		bHide=bool(m_hCbRightSheathingHide.GetSelectedNum());
		debug(""$string(bHide));
		class'UIDATA_PAWNVIEWER'.static.ApplyRightSheathingHide(bHide);
		break;
	}
}

function OnKeyUp( WindowHandle a_WindowHandle, EInputKey nKey )
{
	if (nKey == IK_Enter )
	{
	}
}


defaultproperties
{
    m_WindowName="SheathingWnd"
}
