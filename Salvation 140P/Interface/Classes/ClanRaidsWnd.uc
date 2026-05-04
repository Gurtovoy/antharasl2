class ClanRaidsWnd extends L2UIGFxScript;

function OnRegisterEvent()
{	
	RegisterGfxEvent(EV_PledgeRaidInfo);
	RegisterGfxEvent(EV_PledgeRaidRank);

	//RegisterEvent(EV_PledgeRaidInfo);
	//RegisterEvent(EV_PledgeRaidRank);
	//RegisterGFxEvent(EV_Test_9);
	//RegisterGFxEvent(EV_Test_1);
	//RegisterEvent(EV_Test_1);
}

function OnLoad()
{	
	SetClosingOnESC();	
	SetContainerWindow( WINDOWTYPE_DECO_NORMAL, 3646);
	AddState("GAMINGSTATE");
	
	//선언하면 처음 부터 보여지고 시작 함
	//SetDefaultShow(true);
	//SetRenderOnTop(true);
	//SetAlwaysOnTop(true);
	//SetHavingFocus( false );
}

//function onEvent ( int ID, string param ) 
//{
//	Debug ( "onEvent" @ ID @ param ) ;
//}
defaultproperties
{
}
