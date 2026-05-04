//------------------------------------------------------------------------------------------------------------------------
//
// Á¦¸ñ         : Ç÷¸ÍÃ¢ (¸®´º¾ó) - SCALEFORM UI
//
//------------------------------------------------------------------------------------------------------------------------
class ClanGfxWnd extends L2UIGFxScript;

function OnRegisterEvent()
{	
	// 10080
	//registerGfxEvent( EV_FactionInfo );		

	//RegisterGFxEvent( EV_ClanInfo );
	//RegisterGFxEvent( EV_ClanInfoUpdate );
	//RegisterGFxEvent( EV_ClanDeleteAllMember );
	//RegisterGFxEvent( EV_ClanAddMember );
	//RegisterGFxEvent( EV_ClanMemberInfoUpdate );
	//RegisterGFxEvent( EV_ClanAddMemberMultiple );
	//RegisterGFxEvent( EV_ClanDeleteMember );
	//RegisterGFxEvent( EV_ClanMyAuth );
	//RegisterGFxEvent( EV_ClanSubClanUpdated );

	//RegisterGFxEvent( EV_ResultJoinDominionWar );
	//RegisterGFxEvent( EV_RequestStartPledgeWar );

	//RegisterGFxEvent( EV_ClanAuthGradeList );
	//RegisterGFxEvent( EV_ClanCrestChange );
	//RegisterGFxEvent( EV_ClanAuth );
	//RegisterGFxEvent( EV_ClanAuthMember );
	//RegisterGFxEvent( EV_ClanMemberInfo );	
	//RegisterGFxEvent( EV_ClanSkillList );
	//RegisterGFxEvent( EV_ClanSkillListRenew);
	//RegisterGFxEvent( EV_ClanWarList );
	//RegisterGFxEvent( EV_ClanClearWarList );

	//RegisterGFxEvent( EV_SendIsActiveUnionInfoBtn) ; 
	//RegisterGFxEvent( EV_PledgeBonusMarkReset ); 

	// °øÇåµµ
	RegisterGFxEvent( EV_PledgeContributionRank );    //Ç÷¸Í°øÇåµµ ·©Å·
	RegisterGFxEvent( EV_PledgeContributionInfo );    //Ç÷¸Í°øÇåµµ Á¤º¸
	RegisterGFxEvent( EV_PledgeContributionReward );  //Ç÷¸Í°øÇåµµ º¸»ó

	RegisterGFxEvent( EV_PledgeLevelUp ); // = 10420;	//Ç÷¸Í ·¹º§ ¾÷
	RegisterGFxEvent( EV_PledgeShowInfoUpdate ); //	= 10430;	//Ç÷¸Í ±âº» Á¤º¸ ¾÷µ¥ÀÌÆ®

	// --- New Clan Event -- 
	RegisterGFxEvent( EV_GFX_ClanInfo ); //                 = 10450;
	RegisterGFxEvent( EV_GFX_ClanInfoUpdate ); //           = 10460;
	RegisterGFxEvent( EV_GFX_ClanDeleteAllMember ); //      = 10470;
	RegisterGFxEvent( EV_GFX_ClanAddMember ); //            = 10480;
	RegisterGFxEvent( EV_GFX_ClanAddMemberMultiple ); //    = 10490;
	RegisterGFxEvent( EV_GFX_ClanDeleteMember ); //         = 10500;
	RegisterGFxEvent( EV_GFX_ClanMemberInfoUpdate ); //     = 10510;

	RegisterGFxEvent( EV_GFX_ClanMyAuth ); //               = 10520;
	RegisterGFxEvent( EV_GFX_ClanAuth ); //                 = 10530;
	RegisterGFxEvent( EV_GFX_ClanAuthMember ); //           = 10540;
	RegisterGFxEvent( EV_GFX_ClanAuthGradeList ); //        = 10550;
	RegisterGFxEvent( EV_GFX_ClanSubClanUpdated ); //       = 10560;
	RegisterGFxEvent( EV_GFX_ResultJoinDominionWar ); //    = 10570;

	RegisterGFxEvent( EV_GFX_ClanCrestChange ); //          = 10590;
	RegisterGFxEvent( EV_GFX_ClanMemberInfo ); //           = 10600;
	RegisterGFxEvent( EV_GFX_ClanSkillList ); //            = 10610;
	RegisterGFxEvent( EV_GFX_ClanSkillListRenew ); //       = 10620;
	RegisterGFxEvent( EV_GFX_ClanWarList ); //              = 10630;
	RegisterGFxEvent( EV_GFX_ClanClearWarList ); //         = 10640;
	RegisterGFxEvent( EV_GFX_ReceivePledgeMemberList ); //  = 10650;
	RegisterGFxEvent( EV_GFX_AskStopPledgeWar  ); //        = 10660;
	RegisterGFxEvent( EV_GFX_AskStartPledgeWar );     //    = 10580;

	/// Ç÷¸Í Æ¯È­
	RegisterGFxEvent( EV_PledgeSkillInfo );           //    = 10710;
	RegisterGFxEvent( EV_PledgeSkillActivate );       //    = 10720;
	RegisterGFxEvent( EV_PledgeItemList );            //    = 10730;
	RegisterGFxEvent( EV_PledgeItemActivate );        //    = 10740;

	RegisterGFxEvent( EV_PledgeMasteryInfo );         //    = 10670;
	RegisterGFxEvent( EV_PledgeMasterySet );          //    = 10680;
	RegisterGFxEvent( EV_PledgeMasteryReset );        //    = 10690;

	RegisterGFxEvent( EV_PledgeAnnounce );            //    = 10750;
	RegisterGFxEvent( EV_PledgeAnnounceSet );         //    = 10760;

	//Ç÷¸Í ¹®Àå/¸¶Å© °ü·Ã
	RegisterGFxEvent( EV_PledgeCrestSet );            //    = 10770;
	RegisterGFxEvent( EV_PledgeEmblemSet );           //    = 10780;
	RegisterGFxEvent( EV_AllyCrestSet );              //    = 10790;

	RegisterGFxEvent( EV_DismissPledge );              //    = 10830; //Ç÷¸Í ÇØ»êµÇ´Â ¼ø°£¿¡ Á¢¼ÓÇÏ°í ÀÖ´Â Ç÷¸Í¿ø 
	RegisterGFxEvent( EV_OustPledge );                 //    = 10840; //Á¦¸í´çÇÑ ¸â¹ö
	RegisterGFxEvent( EV_WithdrawPledge );             //    = 10850; //Å»ÅðÇÑ ¸â¹ö
	

	RegisterGFxEvent( EV_GFX_ClanInfoEnd );  // 
	                               

	// Etc
	RegisterGFxEvent( EV_GamingStateEnter );
	RegisterGFxEvent( EV_GamingStateExit );
	RegisterGFxEventForLoaded( EV_Restart );	

	//registerEvent(EV_DialogOK);
	//registerEvent(EV_DialogCancel);
}

function OnLoad()
{		
	AddState( "GAMINGSTATE" );
	SetContainerWindow(WINDOWTYPE_DECO_NORMAL, 7285);
}

function OnFlashLoaded()
{
	RegisterDelegateHandler(EDelegateHandlerType.EDHandler_PledgeWnd);
}

function OnShow () 
{		
	getInstanceL2Util().checkIsPrologueGrowType ( string(self) );
}


//ÆÄÀÏÀ©µµ¿ì¸¦ º¸¿©ÁØ´Ù. ÇÚµé·¯¸¦ ÁöÁ¤ÇÏ°í, 
//FileWnd.ucÀÇ UploadÇÔ¼ö¸¦ ¼öÁ¤ÇØ¼­ ÆÄÀÏµî·Ï½Ã ½ÇÇàµÉ ÇÔ¼ö¸¦ ÁöÁ¤ÇØ ÁÖÀÚ.
/*
	FH_NONE,                    0
	FH_PLEDGE_CREST_UPLOAD,     1
	FH_PLEDGE_EMBLEM_UPLOAD,    2
	FH_ALLIANCE_CREST_UPLOAD,   3
	FH_WEBBROWSER_FILE_UPLOAD,  4 
	FH_MAX      
*/


function OnCallUCFunction( string funcName, string param )
{
	local FileRegisterWnd script;
	local string strParam;

	Debug("funcName:" @ funcName);
	Debug("param:" @ param);

	if(funcName == "FileRegisterWndShowByTypeStr")
	{
		script = FileRegisterWnd(GetScript("FileRegisterWnd"));

		script.FileRegisterWndShowByTypeStr(param);		
	}
	else if(funcName == "pledgepenalty")
	{
		ExecuteCommandFromAction("pledgepenalty");
	}
	else if(funcName == "ClanSearch")
	{
		if ( class'UIAPI_WINDOW'.static.IsShowWindow("ClanSearch") )
		{
			class'UIAPI_WINDOW'.static.HideWindow("ClanSearch");
		}
		else
		{
			class'UIAPI_WINDOW'.static.ShowWindow("ClanSearch");
			class'UIAPI_WINDOW'.static.SetFocus("ClanSearch");
		}
	}
	else if(funcName == "ClanShopWnd")
	{
		if ( class'UIAPI_WINDOW'.static.IsShowWindow("ClanShopWnd") )
		{
			class'UIAPI_WINDOW'.static.HideWindow("ClanShopWnd");
		}
		else
		{
			class'UIAPI_WINDOW'.static.ShowWindow("ClanShopWnd");
			class'UIAPI_WINDOW'.static.SetFocus("ClanShopWnd");
		}

	}
	else if(funcName == "ToDoListClanWnd")
	{
		if ( class'UIAPI_WINDOW'.static.IsShowWindow("ToDoListClanWnd") )
		{
			class'UIAPI_WINDOW'.static.HideWindow("ToDoListClanWnd");
		}
		else
		{
			class'UIAPI_WINDOW'.static.ShowWindow("ToDoListClanWnd");
			class'UIAPI_WINDOW'.static.SetFocus("ToDoListClanWnd");
		}
	}
	else if(funcName == "InviteFriend")
	{
		class'PersonalConnectionAPI'.static.RequestAddFriend(param);						
	}

	else if(funcName == "InviteParty")
	{
		RequestInviteParty(param);
	}
	else if(funcName == "ClanBoard")
	{
		strParam = "";
		ParamAdd(strParam, "Index", "3");
		ExecuteEvent(EV_ShowBBS, strParam);
	}
	else if(funcName == "ClanHelp")
	{
		ExecuteEvent(EV_ShowHelp, "147");
	}
	else if(funcName == "benefit")
	{
		ExecuteEvent(EV_ShowHelp, "153");
	}
	// ¾ÆÁöÆ® ¹öÆ°
	else if(funcName == "agit")
	{
		// ExecuteEvent(EV_ShowHelp, "153");
	}

	//--Ç÷¸Í¿ø ¸ÞÀÎ ¸®½ºÆ®
	else if(funcName == "addFriend")
	{
		class'PersonalConnectionAPI'.static.RequestAddFriend(param);						
	}
	else if(funcName == "inviteParty")
	{
		RequestInviteParty(param);
	}
	else if(funcName == "whisper")
	{
		whisperToUser(param);
	}
}

//±Ó¼Ó¸»ÇÏ±â
function whisperToUser(string userName)
{
	local ChatWnd chatWndScript;
	if (userName != "")
	{
		//callGFxFunction("ChatMessage", "sendWhisper", userName);
		//Å¬¶óÂÊ ±Ó¼Ó¸» È®ÀÎ
		chatWndScript = ChatWnd(GetScript("ChatWnd"));
		chatWndScript.setChatEditBox("\"" $ userName $ " ");
	}
}
defaultproperties
{
}
