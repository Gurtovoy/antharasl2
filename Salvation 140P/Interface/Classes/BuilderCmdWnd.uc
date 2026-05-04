class BuilderCmdWnd extends UICommonAPI;

//const DIALOGID_Gohome = 0;

var string m_WindowName;
var WindowHandle Me;

var ButtonHandle collision_button;
var ButtonHandle npcinfo_button;
var ButtonHandle stat_button;
var ButtonHandle rmode_button;
var ButtonHandle bonename_button;
var ButtonHandle init_button;

var ComboBoxHandle Reload_ComboBox;
var ButtonHandle Reload_button;

var ButtonHandle AVE_button;
var ButtonHandle NpcSummon_Button;
var ButtonHandle UseSkill_button;
var ButtonHandle DefaultNpc_button;
var ButtonHandle ComeOn_button;
var ButtonHandle KillNpc_button;
var ButtonHandle SetParam_button;
var ButtonHandle Ride_button;
var ButtonHandle SetSpeed_button;
var ButtonHandle SetRace_button;
var ButtonHandle Clone_button;
var ButtonHandle JobTree_button;
var ButtonHandle Search_button;

var ComboBoxHandle Race_ComboBox;
var ComboBoxHandle Sex_ComboBox;
var EditBoxHandle AveId_EditBox;
var EditBoxHandle NpcId_EditBox;
var EditBoxHandle SkillId_EditBox;
var EditBoxHandle Param_EditBox;
var EditBoxHandle RideId_EditBox;
var EditBoxHandle Speed_EditBox;

var SliderCtrlHandle sliderSetTime;
var TextBoxHandle txtSetTime;
var CheckBoxHandle checkBoxSetTime;

function OnLoad()
{
	SetClosingOnESC();

	Me = GetWindowHandle( "BuilderCmdWnd" );
	Me.SetWindowTitle("BuilderCommand");
	collision_button = GetButtonHandle( "BuilderCmdWnd.Group1.collision_button" );
	npcinfo_button = GetButtonHandle( "BuilderCmdWnd.Group1.npcinfo_button" );
	stat_button = GetButtonHandle( "BuilderCmdWnd.Group1.stat_button" );
	rmode_button = GetButtonHandle( "BuilderCmdWnd.Group1.rmode_button" );
	bonename_button = GetButtonHandle( "BuilderCmdWnd.Group1.bonename_button" );
	init_button = GetButtonHandle( "BuilderCmdWnd.Group1.init_button" );

	Reload_ComboBox = GetComboBoxHandle( "BuilderCmdWnd.Group2.Reload_ComboBox" );
	Reload_ComboBox.AddString("AdditionalEffect");
	Reload_ComboBox.AddString("ArmorGrp");
	Reload_ComboBox.AddString("WeaponGrp");
	Reload_ComboBox.AddString("EtcItemGrp");
	Reload_ComboBox.AddString("SkillGrp");
	Reload_ComboBox.AddString("NpcGrp");
	Reload_ComboBox.AddString("HairExGrp");
	Reload_ComboBox.AddString("FaceExGrp");
	Reload_ComboBox.AddString("----------------");
	Reload_ComboBox.AddString("Skill_Data");
	Reload_ComboBox.AddString("Item_Data");
	Reload_ComboBox.AddString("Npc_Data");
	Reload_ComboBox.AddString("----------------");
	Reload_ComboBox.AddString("Effect");
	Reload_ComboBox.AddString("SkillEffect");
	Reload_ComboBox.AddString("LineageNpc*");
	Reload_ComboBox.AddString("LineageMonster*");
	Reload_ComboBox.AddString("LineageWarrior");

	AVE_button = GetButtonHandle( "BuilderCmdWnd.Group3.AVE_button" );
	AveId_EditBox = GetEditBoxHandle( "BuilderCmdWnd.Group3.AveId_EditBox" );
	AveId_EditBox.SetString("68");

	NpcSummon_Button = GetButtonHandle( "BuilderCmdWnd.Group4.NpcSummon_Button" );
	NpcId_EditBox = GetEditBoxHandle( "BuilderCmdWnd.Group4.NpcId_EditBox" );
	NpcId_EditBox.SetString("18002");
	UseSkill_button = GetButtonHandle( "BuilderCmdWnd.Group4.UseSkill_button" );
	SkillId_EditBox = GetEditBoxHandle( "BuilderCmdWnd.Group4.SkillId_EditBox" );
	SkillId_EditBox.SetString("129 1 0");
	DefaultNpc_button = GetButtonHandle( "BuilderCmdWnd.Group4.DefaultNpc_button" );
	ComeOn_button = GetButtonHandle( "BuilderCmdWnd.Group4.ComeOn_button" );
	KillNpc_button = GetButtonHandle( "BuilderCmdWnd.Group4.KillNpc_button" );
	Ride_button = GetButtonHandle( "BuilderCmdWnd.Group5.Ride_button" );
	SetParam_button = GetButtonHandle( "BuilderCommand.Group5.SetParam_button" );
	SetSpeed_button = GetButtonHandle( "BuilderCmdWnd.Group5.SetSpeed_button" );
	search_button = GetButtonHandle( "BuilderCmdWnd.Group5.search_button" );
	Race_ComboBox = GetComboBoxHandle( "BuilderCmdWnd.Group5.Race_ComboBox" );
	Race_ComboBox.AddString(getSystemString ( 170 ) $ getSystemString ( 175 ));
	Race_ComboBox.AddString(getSystemString ( 170 ) $ getSystemString ( 176 ));
	Race_ComboBox.AddString(getSystemString ( 171 ) $ getSystemString ( 175 ));
	Race_ComboBox.AddString(getSystemString ( 171 ) $ getSystemString ( 176 ));
	Race_ComboBox.AddString(getSystemString ( 172 ) $ getSystemString ( 175 ));
	Race_ComboBox.AddString(getSystemString ( 172 ) $ getSystemString ( 176 ));
	Race_ComboBox.AddString(getSystemString ( 173 ) $ getSystemString ( 175 ));
	Race_ComboBox.AddString(getSystemString ( 173 ) $ getSystemString ( 176 ));
	Race_ComboBox.SYS_AddString(174);
	Race_ComboBox.SYS_AddString(1544);
	Race_ComboBox.AddString(getSystemString ( 3273 ) $ getSystemString ( 175 ));
	Race_ComboBox.AddString(getSystemString ( 3273 ) $ getSystemString ( 176 ));

	Sex_ComboBox = GetComboBoxHandle( "BuilderCmdWnd.Group5.Sex_ComboBox" );
	Sex_ComboBox.SYS_AddString(177);
	Sex_ComboBox.SYS_AddString(178);

	RideId_EditBox = GetEditBoxHandle( "BuilderCmdWnd.Group5.RideId_EditBox" );
	RideId_EditBox.SetString("13522");
	Param_EditBox = GetEditBoxHandle( "BuilderCmdWnd.Group5.Param_EditBox" );
	Param_EditBox.SetString("lv 80");
	Speed_EditBox = GetEditBoxHandle( "BuilderCmdWnd.Group5.Speed_EditBox" );
	Speed_EditBox.SetString("10");

	Clone_button = GetButtonHandle("BuilderCmdWnd.Group6.Clone_button");
	JobTree_button = GetButtonHandle("BuilderCmdWnd.Group6.JobTree_button");
	sliderSetTime = GetSliderCtrlHandle("BuilderCmdWnd.Group6.sliderSetTime");
	txtSetTime  =  GetTextBoxHandle ( "BuilderCmdWnd.Group6.txtSetTime" );
	checkBoxSetTime = GetCheckBoxHandle( "BuilderCmdWnd.Group6.checkBoxSetTime" );
}

function OnClickReloadButton()
{
	local int selected;
	selected = Reload_ComboBox.GetSelectedNum();
	switch(selected)
	{
		case 0:
			ExecuteCommand("///additionaleffect_reload");
			break;
		case 1:
			ExecuteCommand("///armorgrp_reload");
			break;
		case 2:
			ExecuteCommand("///weapongrp_reload");
			break;
		case 3:
			ExecuteCommand("///etcitemgrp_reload");
			break;
		case 4:
			ExecuteCommand("///skillgrp_reload");
			break;
		case 5:
			ExecuteCommand("///npcgrp_reload");
			break;
		case 6:
			ExecuteCommand("///hairexgrp_reload");
			break;
		case 7:
			ExecuteCommand("///faceexgrp_reload");
			break;
		case 8:
			break;
		case 9:
			ExecuteCommand("//reload_skill_data");
			break;
		case 10:
			ExecuteCommand("//reload_item_data");
			break;
		case 11:
			ExecuteCommand("//reload_npc_data");
			break;
		case 12:
			break;
		case 13:
			ExecuteCommand("///reloade");
			break;
		case 14:
			ExecuteCommand("///reloadse");
			break;
		case 15:
			ExecuteCommand("///reloadnpc");
			break;
		case 16:
			ExecuteCommand("///reloadmonster");
			break;
		case 17:
			ExecuteCommand("///reloadwarrior");
			break;
	}
}
function OnClickButton( String a_ButtonID )
{
	switch( a_ButtonID )
	{
		case "Reload_button":
			OnClickReloadButton();
			break;

		case "collision_button":
			ExecuteCommand("///show radii");
			break;

		case "npcinfo_button":
			ExecuteCommand("//debug .");
			break;

		case "nameTag_button":
			ExecuteCommand("///show name");
			break;

		case "stat_button":
			ExecuteCommand("///stat l2");
			break;

		case "rmode_button":
			if( rmode_button.GetButtonName() == "Wireframe" )
			{
				ExecuteCommand("///rmode 1");
				rmode_button.SetNameText( "Lighting" );
			}
			else
			{
				ExecuteCommand("///rmode 5");
				rmode_button.SetNameText( "Wireframe" );
			}
			break;

		case "bonename_button":
			ExecuteCommand("///rend bone");
			ExecuteCommand("///rend bonename");
			break;

		case "init_button":
			ExecuteCommand("//hide off");
			ExecuteCommand("//undying on");
			ExecuteCommand("//set_skill_all_me");
			ExecuteCommand("//skill_master on");
			ExecuteCommand("//item_master on");
			ExecuteCommand("///autocom");
			break;

		//etc
		case "AVE_button":
			if( AVE_button.GetButtonName() == "Show" )
			{
				ExecuteCommand("///aa type=" @ AveId_EditBox.GetString());
				AVE_button.SetNameText( "Hide" );
				break;
			}
			else
			{
				ExecuteCommand("///aa type=none");
				AVE_button.SetNameText( "Show" );
				break;
			}

		case "NpcSummon_Button":
			ExecuteCommand("//summon 10" $ NpcId_EditBox.GetString());
			break;

		case "UseSkill_Button":
			ExecuteCommand("//npc_use_skill" @ SkillId_EditBox.GetString());
			break;

		case "DefaultNpc_button":
			ExecuteCommand("//setai default_npc");
			break;

		case "ComeOn_Button":
			ExecuteCommand("//come_to_me 1");
			break;

		case "KillNpc_Button":
			ExecuteCommand("//killnpc");
			break;

		case "SetParam_button":
			ExecuteCommand("//setparam " @ Param_EditBox.GetString());
			break;

		case "Ride_button":
			if( Ride_button.GetButtonName() == "Ride" )
			{
				ExecuteCommand("///ride id=" @ RideId_EditBox.GetString());
				Ride_button.SetNameText( "Unride" );
				break;
			}
			else
			{
				ExecuteCommand( "///unride" );
				Ride_button.SetNameText( "Ride" );
				break;
			}

		case "SetSpeed_button":
			ExecuteCommand("//gmspeed" @ Speed_EditBox.GetString());
			break;

		case "Clone_button":
			ExecuteCommand("///spawnpc copy num=1");
			break;

		case "JobTree_button":
			ExecuteCommand("/target %self");
			ShowWindow("JobTreeWnd");
			break;

		case "Search_button":
			ExecuteCommand("///searchobject");
			break;
	}
}

function OnModifyCurrentTickSliderCtrl(string strID, int iCurrentTick)
{
	local float ftime;
	switch(strID)
	{
	case "sliderSetTime":
		if (checkBoxSetTime.IsChecked())
		{
			ftime = float(sliderSetTime.GetCurrentTick()) / 10.f;
			SetEnvTime(ftime);
			txtSetTime.SetText(string(ftime));
		}
		break;
	}
}
function OnComboBoxItemSelected(string StrID, int IndexID)
{
	switch(StrID)
	{
		case "Race_ComboBox":
			switch(IndexID)
			{
				case 0:
					ExecuteCommand("/target %self");
					ExecuteCommand("//setparam race 0 0");
					break;
				case 1:
					ExecuteCommand("/target %self");
					ExecuteCommand("//setparam race 0 1");
					break;
				case 2:
					ExecuteCommand("/target %self");
					ExecuteCommand("//setparam race 1 0");
					break;
				case 3:
					ExecuteCommand("/target %self");
					ExecuteCommand("//setparam race 1 1");
					break;
				case 4:
					ExecuteCommand("/target %self");
					ExecuteCommand("//setparam race 2 0");
					break;
				case 5:
					ExecuteCommand("/target %self");
					ExecuteCommand("//setparam race 2 1");
					break;
				case 6:
					ExecuteCommand("/target %self");
					ExecuteCommand("//setparam race 3 0");
					break;
				case 7:
					ExecuteCommand("/target %self");
					ExecuteCommand("//setparam race 3 1");
					break;
				case 8:
					ExecuteCommand("/target %self");
					ExecuteCommand("//setparam race 4 0");
					break;
				case 9:
					ExecuteCommand("/target %self");
					ExecuteCommand("//setparam race 5 0");
					break;
				case 10:
					ExecuteCommand("/target %self");
					Sex_ComboBox.SetSelectedNum(1);
					ExecuteCommand("//setparam sex 1");
					ExecuteCommand("//setparam race 6 0");
					break;
				case 11:
					ExecuteCommand("/target %self");
					Sex_ComboBox.SetSelectedNum(1);
					ExecuteCommand("//setparam sex 1");
					ExecuteCommand("//setparam race 6 1");
					break;
			}
		break;
		case "Sex_ComboBox":
			switch(IndexID)
			{
				case 0:
					ExecuteCommand("/target %self");
					ExecuteCommand("//setparam sex 0");
					break;
				case 1:
					ExecuteCommand("/target %self");
					ExecuteCommand("//setparam sex 1");
					break;
			}
		break;
	}
}
function OnReceivedCloseUI()
{
	PlayConsoleSound(IFST_WINDOW_CLOSE);
	GetWindowHandle( m_WindowName ).HideWindow();
}

defaultproperties
{
    m_WindowName="BuilderCmdWnd"
}
