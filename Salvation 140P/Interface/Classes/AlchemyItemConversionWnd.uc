class AlchemyItemConversionWnd extends L2UIGFxScript;

function OnRegisterEvent()
{	
	RegisterGFxEvent(EV_AlchemySkillInfoFromScript); //9900
	RegisterGFxEvent(EV_AlchemySkillList);           //9870
	RegisterGFxEvent(EV_AlchemyConversion);          //9890
	RegisterGFxEvent(EV_InventoryUpdateItem);        //2610
	//RegisterGFxEvent(EV_SkillTrainInfoWndAddExtendInfo);        //2051;

	//RegisterGFxEvent( EV_SkillTrainListWndShow );// 2010;
	//RegisterGFxEvent( EV_SkillTrainListWndHide	)	;// 2020;
	//RegisterGFxEvent( EV_SkillTrainListWndAddSkill)	;// 2030;
	//RegisterGFxEvent( EV_SkillTrainInfoWndShow	)	;// 2040;
	//RegisterGFxEvent( EV_SkillTrainInfoWndHide	)	;// 2050;
	//RegisterGFxEvent( EV_SkillTrainInfoWndAddExtendInfo) ;//2051
	// 스킬 습득 변경 - lancelot 2010. 10. 23.
	//RegisterGFxEvent( EV_SkillLearningTabAddSkillBegin);//2055
	//RegisterGFxEvent( EV_SkillLearningTabAddSkillItem);//2056
	RegisterGFxEvent( EV_SkillLearningTabAddSkillEnd);//2057
	//RegisterGFxEvent( EV_SkillLearningDetailInfo);//2058
	//RegisterGFxEvent( EV_SkillLearningNewArrival);//2059	
}

function OnLoad()
{	
	
	//registerState( "AlchemyItemConversionWnd", "GamingState" );
	// 어느 콘테이너에 넣을 건지 선언
	//SetContainer( "ContainerWindow" );
	
	SetContainerWindow(WINDOWTYPE_DECO_NORMAL, 3266);
	AddState("GAMINGSTATE");
	
	//setDefaultShow(true);
	//SetAnchor("", EAnchorPointType.ANCHORPOINT_CenterCenter, EAnchorPointType.ANCHORPOINT_CenterCenter, 0 , 0);

}

function onShow ()
{
	// 지정한 윈도우를 제외한 닫기 기능 
	local L2Util util;
	util = L2Util(GetScript("L2Util"));
	util.ItemRelationWindowHide("AlchemyItemConversionWnd");
}

function onCallUCFunction( string functionName, string param )
{
}
defaultproperties
{
}
