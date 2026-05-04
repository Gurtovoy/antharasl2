class MSViewerWnd extends UICommonAPI;


const SK_NORMAL=0;
const SK_BUFF=1;
const SK_DEBUFF=2;
const SK_TOGGLE=3;
const SK_SONGDANCE=4;
const SK_PASSIVE=5;
const SK_SEARCH=6;
const SK_MAX=7;

var string m_WindowName;


var ItemWindowHandle	m_hItemWnd[ SK_MAX ];
var ItemWindowHandle	selectedItemWindowHandle;

var int prevSelectedSkillID;

var WindowHandle m_hWnd;
var WindowHandle m_hProfilerWnd;

var TabHandle		m_hTabItemWnd;

var EditBoxHandle	m_hEbSkillName;
var EditBoxHandle	m_hEbSkillID;
var EditBoxHandle	m_hEbSkillVisualEffect;

var EditBoxHandle	m_hebSkillType;
var CheckBoxHandle	m_hcbSkillCursor;

var ComboBoxHandle	comboSkillLevel;
var ComboBoxHandle	comboSkillSubLevel;

var TextBoxHandle	m_hTxtFrontHairTexture;
var TextBoxHandle	m_hTxtRearHairTexture;

var EditBoxHandle		m_hEbMultiSpawnNum;
var CheckBoxHandle	m_hCbMultiSpawn;
var CheckBoxHandle	m_hCbMultiTarget;

var CheckBoxHandle	m_hCbSimpleEmitter;

function OnRegisterEvent()
{
	registerEvent(EV_MSViewerWndAddSkill);
	registerEvent(EV_MSViewerWndShow);
	registerEvent(EV_MSViewerWndDeleteAllSkill);
}

function OnLoad()
{
	InitializeHandle();
	m_hWnd.SetWindowTitle("SKILL VIEWER");
}


function InitializeHandle()
{
	m_hWnd=GetWindowHandle(m_WindowName);
	m_hProfilerWnd = GetWindowHandle("MSProfilerWnd");

	m_hTabItemWnd=GetTabHandle(m_WindowName$".SkillTab");

	m_hItemWnd[ SK_NORMAL ]=GetItemWindowHandle(m_WindowName$".ItemWndSkillNormal");
	m_hItemWnd[ SK_BUFF ]=GetItemWindowHandle(m_WindowName$".ItemWndSkillBuff");
	m_hItemWnd[ SK_DEBUFF ]=GetItemWindowHandle(m_WindowName$".ItemWndSkillDebuff");
	m_hItemWnd[ SK_TOGGLE ]=GetItemWindowHandle(m_WindowName$".ItemWndSkillToggle");
	m_hItemWnd[ SK_SONGDANCE ]=GetItemWindowHandle(m_WindowName$".ItemWndSkillSongdance");
	m_hItemWnd[ SK_PASSIVE ]=GetItemWindowHandle(m_WindowName$".ItemWndSkillPassive");
	m_hItemWnd[ SK_SEARCH ]=GetItemWindowHandle(m_WindowName$".ItemWndSkillSearch");

	m_hEbSkillName=GetEditBoxHandle(m_WindowName$".ebSkillName");
	m_hEbSkillID=GetEditBoxHandle(m_WindowName$".ebSkillID");
	m_hEbSkillVisualEffect=GetEditBoxHandle(m_WindowName$".ebVisualEffect");
	
	m_hebSkillType = GetEditBoxHandle(m_WindowName$".ebSkillType");
	m_hcbSkillCursor = GetCheckBoxHandle(m_WindowName$".cbSkillCursor");

	comboSkillLevel=GetComboBoxHandle(m_WindowName$".ComboBoxSkillLevel");
	comboSkillSubLevel=GetComboBoxHandle(m_WindowName$".ComboBoxSkillSubLevel");

	m_hEbMultiSpawnNum = GetEditBoxHandle(m_WindowName$".ebMultiSpawnNum");
	m_hCbMultiSpawn = GetCheckBoxHandle(m_WindowName$".cbMultiSpawn");
	m_hCbMultiTarget = GetCheckBoxHandle(m_WindowName$".cbMultiTarget");
	
	m_hCbSimpleEmitter = GetCheckBoxHandle(m_WindowName$".cbSimpleEmitter");

	m_hEbMultiSpawnNum.SetString("50");	

	comboSkillLevel.AddString("1");
	comboSkillLevel.SetSelectedNum(0);

	comboSkillSubLevel.AddString("0");
	comboSkillSubLevel.SetSelectedNum(0);
}

function OnEvent( int a_EventID, String Param )
{
//	debug(""$a_EventID @ Param);
	switch( a_EventID )
	{
	case EV_MSViewerWndAddSkill :
		HandleAddSkill(Param);
		break;
	case EV_MSViewerWndShow :
		m_hWnd.ShowWindow();	
		break;
	case EV_MSViewerWndDeleteAllSkill:
		HandleDeleteAllSkill();
		break;
	}
}
function HandleDeleteAllSkill()
{
	m_hItemWnd[ SK_NORMAL ].Clear();
	m_hItemWnd[ SK_BUFF ].Clear();
	m_hItemWnd[ SK_DEBUFF ].Clear();
	m_hItemWnd[ SK_TOGGLE ].Clear();
	m_hItemWnd[ SK_SONGDANCE ].Clear();
	m_hItemWnd[ SK_PASSIVE ].Clear();
	m_hItemWnd[ SK_SEARCH ].Clear();

	comboSkillLevel.Clear();
	comboSkillSubLevel.Clear();

	selectedItemWindowHandle = None;
	prevSelectedSkillID = -1;
}

function HandleAddSkill(string Param)
{
	local int Type;
	local int SkillLevel;
	local int SkillSubLevel;
	local int Lock;
	local string strIconName;
	local string strSkillName;
	local string strDescription;
	local string strEnchantName;
	local string strCommand;
	local string strIconPanel;
	
	local ItemInfo	infItem;
	
	ParseItemID(param, infItem.ID);
	ParseInt(param, "Type", Type);
	ParseInt(param, "Level", SkillLevel);
	ParseInt(param, "SubLevel", SkillSubLevel);
	ParseInt(param, "Lock", Lock);
	ParseString(param, "Name", strSkillName);
	ParseString(param, "IconName", strIconName);
	ParseString(param, "IconPanel", strIconPanel);
	ParseString(param, "Description", strDescription);
	ParseString(param, "AdditionalName", strEnchantName);
	ParseString(param, "Command", strCommand);
	
	//debug(" Type : " $ Tmp $ "SkillLevel : " $ SkillLevel $ " strSkillName : " $ strSkillName $ " Command : " $ strCommand);

	infItem.Level = SkillLevel;
	infItem.SubLevel = SkillSubLevel;
	infItem.Name = strSkillName;
	infItem.AdditionalName = strEnchantName;
	infItem.IconName = strIconName;
	infItem.IconPanel = strIconPanel;
	infItem.Description = strDescription;
	infItem.ItemSubType = int(EShortCutItemType.SCIT_SKILL);
	infItem.MacroCommand = strCommand;
	if (Lock>0)
	{
		infItem.bIsLock = true;
	}
	else
	{
		infItem.bIsLock = false;
	}

	if(type>=0 && type<SK_MAX)
		m_hItemWnd[type].AddItem(infItem);
}

function OnSelectItemWithHandle( ItemWindowHandle a_hItemWindow, int index )
{
	local itemInfo info;

	a_hItemWindow.GetItem(index, info);

	selectedItemWindowHandle = a_hItemWindow;

	if(prevSelectedSkillID != info.ID.ClassID)
	{
		RefreshSkillLevel(info.ID.ClassID);
		prevSelectedSkillID = info.ID.ClassID;
	}
}


// ItemWindow Event
function OnDBClickItemWithHandle( ItemWindowHandle a_hItemWindow, int index )
{
	OnRClickItemWithHandle(a_hItemWindow, index );
}

function OnRClickItemWithHandle( ItemWindowHandle a_hItemWindow, int index )
{
	local itemInfo info;
		
	a_hItemWindow.GetItem(index, info);
//	debug("SkillName:"$info.Name);

	ExecuteSkill(info, info.Level, info.SubLevel);
}

function ExecuteSkill(itemInfo info, int skillLevel, int skillSubLevel)
{
	if(class'UIDATA_PAWNVIEWER'.static.IsProfilingEmitter())
	{
		DialogShow( DialogModalType_Modalless,DialogType_Notice, "분석중에는 다른 스킬을 사용할 수 없습니다.", string(Self) );
	}
	else
	{
		if( m_hProfilerWnd.IsShowWindow() )
		{
			m_hProfilerWnd.ShowWindow();
			class'UIDATA_PAWNVIEWER'.static.ExecuteEmitterProfiling();
		}

		class'UIDATA_PAWNVIEWER'.static.ExecuteSkill(info.ID.ClassID, skillLevel, skillSubLevel, m_hCbMultiTarget.IsChecked() );
	}
}

function OnClickCheckBox( string strID)
{
	switch(strID)
	{
	case "cbMultiSpawn": 
		if(m_hCbMultiSpawn.IsChecked())
		{
			class'UIDATA_PAWNVIEWER'.static.SpawnDummyPawn( int(m_hEbMultiSpawnNum.GetString()) );			
		}
		else
		{
			class'UIDATA_PAWNVIEWER'.static.ClearDummyPawn();
		}
		break;
	case "cbSimpleEmitter":
		class'UIDATA_PAWNVIEWER'.static.SetSimpleEmitter( m_hCbSimpleEmitter.IsChecked() );			
		break; 
	case "cbSkillCursor":
		class'UIDATA_PAWNVIEWER'.static.SetGroundSkillCursor( m_hcbSkillCursor.IsChecked() );	
		break;
	}	
}


function OnClickButton( string strID )
{
	switch( strID )
	{
	case "btnSearchByName" :
		processBtnSearchByName();
		break;
	case "btnSearchByID" :
		processBtnSearchByID();
		break;
	case "btnSearchByVisualEffect" :
		processBtnSearchByVisualEffect();
		break;
	
	case "btnSearchByType" :
		processBtnSearchByType();
		break;
	case "btnProfiling" :
		processBtnProfiling();
		break;
	case "ButtonExecuteSkill" :
		processBtnExecuteSkill();
		break;
	}
}

function processBtnExecuteSkill()
{
	local itemInfo info;
	local int tempIValue;
	local string tempStr;
	local int skillLevel;
	local int skillSubLevel;

	if(selectedItemWindowHandle != None)
	{
		tempIValue = comboSkillLevel.GetSelectedNum();
		skillLevel = 1;
		if(tempIValue > -1)
		{
			tempStr = comboSkillLevel.GetString(tempIValue);
			skillLevel = int(tempStr);
		}

		skillSubLevel = 0;
		if(tempIValue > -1)
		{
			tempStr = comboSkillSubLevel.GetString(tempIValue);
			skillSubLevel = int(tempStr);
		}

		selectedItemWindowHandle.GetSelectedItem(info);
		ExecuteSkill(info, skillLevel, skillSubLevel);
	}
}

function processBtnProfiling()
{
	if( m_hProfilerWnd.IsShowWindow() )
	{
		class'UIDATA_PAWNVIEWER'.static.StopEmitterProfiling();
		m_hProfilerWnd.HideWindow();
	}
	else
	{
		m_hProfilerWnd.ShowWindow();
	}
}

function processBtnSearchByName()
{
	local string inputString;

	m_hItemWnd[SK_SEARCH].Clear();
	inputString=m_hEbSkillName.GetString();
	if(Len(inputString)>0)
	{
		class'UIDATA_PAWNVIEWER'.static.AddSkillByName(inputString);
		m_hTabItemWnd.SetTopOrder(6, false);
	}
}

function processBtnSearchByID()
{
	local int ID;
	m_hItemWnd[SK_SEARCH].Clear();
	ID=int(m_hEbSkillID.GetString());
	if(ID>0)
	{
		class'UIDATA_PAWNVIEWER'.static.AddSkillByID(ID);
		m_hTabItemWnd.SetTopOrder(6, false);
	}
}

function processBtnSearchByVisualEffect()
{
	local string VisualEffect;
	m_hItemWnd[SK_SEARCH].Clear();
	VisualEffect=m_hEbSkillVisualEffect.GetString();
	if(len(VisualEffect)>0)
	{
		class'UIDATA_PAWNVIEWER'.static.AddSkillByVisualEffect(VisualEffect);
		m_hTabItemWnd.SetTopOrder(6, false);
	}
}



function processBtnSearchByType()
{
	local int Type;
	m_hItemWnd[SK_SEARCH].Clear();
	Type=int(m_hebSkillType.GetString());
	if(Type>0)
	{
		class'UIDATA_PAWNVIEWER'.static.AddSkillByType(Type);
		m_hTabItemWnd.SetTopOrder(6, false);
	}
}

function OnKeyUp( WindowHandle a_WindowHandle, EInputKey nKey )
{
	if (nKey == IK_Enter )
	{
		if(m_hEbSkillName==a_WindowHandle)
			processBtnSearchByName();
		else if (m_hEbSkillID==a_WindowHandle)
			processBtnSearchByID();
		else if (m_hEbSkillVisualEffect==a_WindowHandle)
			processBtnSearchByVisualEffect();
	}
}

function RefreshSkillLevel(int SkillID)
{
	local array<int> skillLevelList;
	local array<int> skillSubLevelList;
	local int i;

	class'UIDATA_PAWNVIEWER'.static.GetSkillLevelListByID(SkillID, skillLevelList, skillSubLevelList);
	
	comboSkillLevel.Clear();
	for(i = skillLevelList.Length - 1; i >= 0 ; --i)
	{
		comboSkillLevel.AddString(string(skillLevelList[i]));
	}
	comboSkillLevel.SetSelectedNum(0);
	
	comboSkillSubLevel.Clear();
	for(i = skillSubLevelList.Length - 1; i >= 0 ; --i)
	{
		comboSkillSubLevel.AddString(string(skillSubLevelList[i]));
	}
	comboSkillSubLevel.SetSelectedNum(0);
}


defaultproperties
{
    m_WindowName="MSViewerWnd"
}
