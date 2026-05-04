/**
 * 
 *  아레나 타겟
 *  
 **/
class TargetStatusWndArena extends TargetStatusWnd;


function OnEvent(int Event_ID, string param)
{
	// 아레나 서버가 아니라면 안나오게..
	if(!getInstanceUIData().getIsArenaServer()) return;

	if (Event_ID == EV_TargetUpdate)
	{
		//~ debug("2");
		if (m_rotated )
			OnRotateReset();
		else
			HandleTargetUpdate();
		
		// 만약 UI에 포커스가 없는 상태에서 ESC키를 누른 경우, 포커스를 다시 타겟에 잡고
		// 안보이게 해서 UI에 포커스를 오도록 한다. 
		// 그래서 esc 키로 열려 있는 UI를 닫을 수 있도록 하기 위해서다.
		// 엔터 채팅시 문제 발생.. api 로 해야 할듯.
		/*
		if (!Me.IsShowWindow())
		{
			Me.ShowWindow();
			Me.SetFocus();
			Me.HideWindow();				
		}
		*/

	}
	else if (Event_ID == EV_TargetHideWindow)
	{
		HandleTargetHideWindow();
	}
	else if (Event_ID == EV_ReceiveTargetLevelDiff)
	{
		//~ debug("1");
		HandleReceiveTargetLevelDiff(param);
		
	}
	else if (Event_ID == EV_UpdateHP || Event_ID == EV_UpdateMyHP)
	{
		HandleUpdateGauge(param,0);
	}
	else if (Event_ID == EV_UpdateMaxHP || Event_ID == EV_UpdateMyMaxHP)
	{
		HandleUpdateGauge(param,0);
	}
	else if (Event_ID == EV_UpdateMP || Event_ID == EV_UpdateMyMP)
	{
		HandleUpdateGauge(param,1);
	}
	else if (Event_ID == EV_UpdateMaxMP || Event_ID == EV_UpdateMyMaxMP)
	{
		HandleUpdateGauge(param,1);
	}
	//선준 추가 이벤트
	//타겟의 버프 받아옴.
	else if (Event_ID == EV_TargetSpelledList)
	{			
		HandleTargetSpelledList(param);
	}
	//타겟의 스킬 시전 정보 받아옴.
	else if(Event_ID == EV_TargetSkillInfo)
	{	
		
		HandleTargetSkillInfo(param);
	}
	//타겟의 스킬 시전 취소 정보 받아옴.
	else if( Event_ID == EV_TargetSkillCancel )
	{		
		HandleSkillCancel();
	}
	// GamingState 에서 씬 연출등으로 변경될때 타겟이 잡혀 있으면..
	else if (Event_ID == EV_GamingStateExit )
	{
		RequestTargetCancel();
	}
	else if (Event_ID == EV_GamingStateEnter )
	{
		if( bIsShowBackup)
		{		
			//Me.ShowWindow();
			if (m_TargetIDBackup > 0) RequestTargetUser(m_TargetIDBackup);
		}
	}
	else if (Event_ID == EV_GamingStatePreExit )
	{
		bIsShowBackup = Me.IsShowWindow();
		m_TargetIDBackup = m_TargetID;
	}
	else if (Event_ID == EV_Restart )
	{
		bIsShowBackup = false;
		m_TargetIDBackup = -1;
	}

}

function setJobTexture ( int nClassID )
{	
	local string userTexStr;
	userTexStr = GetClassArenaRoleIconName(nClassID) ;

//	Debug ( userTexStr @ nClassID ) ;
	if( class'UIDATA_TARGET'.static.IsNpc() )
	{
		texMark.HideWindow();
		UserName.SetWindowSizeRel( 1.0f, 0, -33, 14 );
		UserName.SetAnchor(m_WindowName , "TopLeft", "TopLeft", 18, 8 );
	}
	else
	{
		texMark.ShowWindow();

		texMark.SetTexture(userTexStr);	
		texMark.SetTooltipCustomType(MakeTooltipSimpleText(GetClassRoleName(nClassID) $ " - " $ GetClassType(nClassID)));

		UserName.SetWindowSizeRel( 1.0f, 0, -54, 14 );
		UserName.SetAnchor(m_WindowName, "TopLeft", "TopLeft", 36, 8 );
	}
}

// 아레나 직업 마크 넣기
function setChangeNameColor(userInfo info, string Name)
{	
	local Color TargetNameColor;
	
	rankName.HideWindow();

	//Debug("m_TargetID" @ m_TargetID);
	//Debug("userTexStr" @ userTexStr);

	if(class'UIDATA_TARGET'.static.IsCanBeAttacked())
	{
		//Debug("공격 가능..");
		UserName.SetNameWithColor(Name, NCT_Normal,TA_Center, getColor(255,0,0,255));
	}
	else if (class'UIDATA_TARGET'.static.IsNpc())
	{
		//Debug("npc..");
		UserName.SetNameWithColor(Name, NCT_Normal,TA_Center, getColor(235,205,0,255));
	}
	else
	{
		//Debug("아무거나..");
		//타겟 이름 색깔
		if (PartyWnd(GetScript("PartyWnd")).FindPartyID(m_TargetID) != -1)
		{
			//Debug("파티 맴버다!");
			UserName.SetNameWithColor(Name, NCT_Normal,TA_Center, getColor(2,255,2,255));
		}
		else
		{
			TargetNameColor = GetTargetNameColor(m_TargetLevel);
			UserName.SetNameWithColor(Name, NCT_Normal,TA_Center, TargetNameColor);
		}
	}
}

//타겟 정보 업데이트 처리

//타겟 정보 업데이트 처리
function HandleTargetUpdate()
{
	local Rect rectWnd;
	local string strTmp;
	
	local int		TargetID;
	local int		PlayerID;
	local int		PetID;
	local int		ClanType;
	local int		ClanNameValue;
	
	//타겟 속성 정보
	local bool		bIsServerObject;
	local bool		bIsHPShowableNPC;	//공성진지
	local bool		bIsVehicle;
	
	local string	Name;
	local string	NameRank;
	local color	TargetNameColor;
	
	//ServerObject
	local int ServerObjectNameID;
	local Actor.EL2ObjectType ServerObjectType;
	
	//Vehicle
	local Vehicle	VehicleActor;
	local string	DriverName;
	
	//HP,MP
	local bool		bShowHPBar;
	local bool		bShowMPBar;
	
	//혈맹 정보
	local bool		bShowPledgeInfo;
	local bool		bShowPledgeTex;
	local bool		bShowPledgeAllianceTex;
	local string	PledgeName;
	local string	PledgeAllianceName;
	local texture	PledgeCrestTexture;
	local texture	PledgeAllianceCrestTexture;
	local color	PledgeNameColor;
	local color	PledgeAllianceNameColor;
	
	//NPC특성
	local bool		 bShowNpcInfo;
	local Array<int>	 arrNpcInfo;
	
	//새로운Target인가?
	local bool		IsTargetChanged;
	
	local bool  WantHideName;
	
	local UserInfo	info;
	local PetInfo   petInfo;
	
	local Color WhiteColor;	//  하얀색을 설정.

	WhiteColor.R = 0;
	WhiteColor.G = 0;
	WhiteColor.B = 0;
	
	
	//타겟ID 얻어오기
	TargetID = class'UIDATA_TARGET'.static.GetTargetID();

	// Debug("타겟 갱신 " @ TargetID);

	if (TargetID<1)
	{
		if (m_rotated )
		{
			OnRotateClose();
		}
		else
		{
			// ESC 닫기 관련.
			// Me.SetFocus();
			Me.HideWindow();
		}		
		
		return;
	}

	//~ if (nMasterID>0)
	//~ {
		
	//타겟이 바뀌었는가?
	if (m_TargetID!=TargetID)
	{
		IsTargetChanged = true;	
		
	}
	m_TargetID = TargetID;
	
	GetTargetInfo(info);

	//추가될 내용.
	if( info.TacticSign == 0 )
	{		
		UserName.SetWindowSizeRel( 1.0f, 0, -33, 14 );
		UserName.SetAnchor(m_WindowName , "TopLeft", "TopLeft", 18, 8 );
		setJobTexture( info.nSubClass );
		texMark.SetWindowSize(32 ,32 ) ;
	}
	else
	{
		texMark.ShowWindow();
		texMark.SetTexture( "l2ui_Ct1.TargetStatusWnd_DF_mark_0" $ string(info.TacticSign) );
		texMark.SetWindowSize(16 ,16 ) ;
		UserName.SetWindowSizeRel( 1.0f, 0, -54, 14 );
		UserName.SetAnchor(m_WindowName, "TopLeft", "TopLeft", 36, 8 );		
	}

	WantHideName= info.WantHideName;
	
	//초기화
	rectWnd = Me.GetRect();
	PledgeName = GetSystemString(431);
	PledgeAllianceName = GetSystemString(591);
	PledgeNameColor.R = 128;
	PledgeNameColor.G = 128;
	PledgeNameColor.B = 128;
	PledgeAllianceNameColor.R = 128;
	PledgeAllianceNameColor.G = 128;
	PledgeAllianceNameColor.B = 128;
	
	//타겟 이름 색깔
	TargetNameColor = GetTargetNameColor(m_TargetLevel);
	
	bIsServerObject = class'UIDATA_TARGET'.static.IsServerObject();
	bIsVehicle = class'UIDATA_TARGET'.static.IsVehicle();
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	//StaticObject ( door 등등 )
	if (bIsServerObject)
	{
		ServerObjectType = class'UIDATA_STATICOBJECT'.static.GetServerObjectType(m_TargetID);
		
		if (ServerObjectType == EL2_AIRSHIPKEY)
		{
			Name = GetSystemString( 1966 );	//조종 키
			NameRank = "";
		}
		else if(ServerObjectType == EL2_STATUE)
		{
			Name = class'UIDATA_STATICOBJECT'.static.GetServerObjectName(m_TargetID);
			NameRank = "";
		}
		else
		{
			ServerObjectNameID = class'UIDATA_STATICOBJECT'.static.GetServerObjectNameID(m_TargetID);
			if (ServerObjectNameID>0)
			{
				Name = class'UIDATA_STATICOBJECT'.static.GetStaticObjectName(ServerObjectNameID);
				NameRank = "";
			}
		}		
		
		UserName.SetName(Name, NCT_Normal,TA_Center);
		//~ NameTxt.SetName(Name, NCT_Normal,TA_Center);
		RankName.SetName(NameRank, NCT_Normal,TA_Center);
		
		//HP표시
		if (ServerObjectType == EL2_DOOR)
		{
			if( class'UIDATA_STATICOBJECT'.static.GetStaticObjectShowHP( m_TargetID ) )
			{
				bShowHPBar = true;
				UpdateHPBar(class'UIDATA_STATICOBJECT'.static.GetServerObjectHP(m_TargetID), class'UIDATA_STATICOBJECT'.static.GetServerObjectMaxHP(m_TargetID));
			}
		}
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	//탈것인가?
	else if( bIsVehicle )
	{
		//비행선 타겟은 일단 보류한다, ttmayrin 2009.7.7
		HandleTargetHideWindow();
		return;
		
		//TO DO : 배이름, 나중에 SYSSTRING또는 서버에서 얻어오는 것으로 하자.
		UserName.SetName("AirShip", NCT_Normal,TA_Center);
		
		VehicleActor = Vehicle(class'UIDATA_TARGET'.static.GetTargetActor());
		if( VehicleActor != None )
		{
			//선장 이름
			if(VehicleActor.DriverID > 0 )
				DriverName = class'UIDATA_USER'.static.GetUserName( VehicleActor.DriverID );
			if( Len(DriverName) < 1 )
				DriverName = GetSystemString( 1967 );	// 조종사 없음
			RankName.SetName( DriverName, NCT_Normal,TA_Center );
			
			//Fuel
			//VehicleActor.MaxFuel
			//VehicleActor.CurFuel
			
			//HP
			//VehicleActor.MaxHP
			//VehicleActor.CurHP
		}		
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	//타겟ID는 있는데 이름을 알수없다면, 멀리있는 파티멤버로 가정
	else if (Len(info.Name)<1)
	{		
		Name = class'UIDATA_PARTY'.static.GetMemberVirtualName(m_TargetID);
		if ( Name == "")
		{
			Name = class'UIDATA_PARTY'.static.GetMemberName(m_TargetID);
		}
		NameRank = "";
		//debug("m_TargetID" $ m_TargetID $ ", info.Name : " $ info.Name $ ", Name : " $ Name );
		UserName.SetName(Name, NCT_Normal,TA_Center);
		//~ NameTxt.SetName(Name, NCT_Normal,TA_Center);
		RankName.SetName(NameRank, NCT_Normal,TA_Center);

		//일단 추가
		if( class'UIDATA_PARTY'.static.GetMemberTacticalSign(m_TargetID) == 0 )
		{
			texMark.HideWindow();
			UserName.SetWindowSizeRel( 1.0f, 0, -33, 14 );
			UserName.SetAnchor(m_WindowName, "TopLeft", "TopLeft", 18, 8 );
			
			//	Debug ( "각각의 클래스 ID 들 " @ info.Class@ info.nClassID @ info.nSubClass );			
			setJobTexture( info.nSubClass );
			texMark.SetWindowSize(32 ,32 ) ;
		}
		else
		{
			texMark.ShowWindow();
			texMark.SetTexture( "l2ui_Ct1.TargetStatusWnd_DF_mark_0" $ string(class'UIDATA_PARTY'.static.GetMemberTacticalSign(m_TargetID) - 1) );
			texMark.SetWindowSize(16 ,16 ) ;
			UserName.SetWindowSizeRel( 1.0f, 0, -54, 14 );
			UserName.SetAnchor(m_WindowName, "TopLeft", "TopLeft", 36, 8 );
		}
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Npc or Pc 의 경우
	else
	{
		PlayerID = class'UIDATA_PLAYER'.static.GetPlayerID();

		// 2010.7.13
		GetPetInfo(petInfo);
		PetID = info.nID; // class'UIDATA_PET'.static.GetPetID();
		
		bIsHPShowableNPC = class'UIDATA_TARGET'.static.IsHPShowableNPC();

		//if ((info.bNpc && !info.bPet && info.bCanBeAttacked ) ||	//몹의경우
		if ((info.bNpc && !info.bPet && bIsHPShowableNPC) ||	//몹의경우
			(PlayerID>0 && m_TargetID == PlayerID) ||		//나의경우
			(info.bNpc && info.bPet && m_TargetID == PetID) ||	//펫의경우
			(info.bNpc && bIsHPShowableNPC)	)		//공성진지
		{
			//일반 몹중에 항상 흰색으로 표시해 줄 필요가 있는 몬스터일 경우
			if(IsAllWhiteID(info.nClassID))
			{
				Name = info.Name;
				NameRank = "";
				//debug("m_TargetID" $ m_TargetID $ ", info.Name : " $ info.Name $ ", Name : " $ Name );
				UserName.SetName(Name, NCT_Normal,TA_Center);
				//~ NameTxt.SetName(Name, NCT_Normal,TA_Center);
				RankName.SetName(NameRank, NCT_Normal,TA_Center);
					
				//HP표시
				if(! (IsNoBarID(info.nClassID)))
				{
					bShowHPBar = true;
					UpdateHPBar(info.nCurHP, info.nMaxHP);
				}
			}
			else
			{
				Name = info.Name;
				NameRank = "";	
				UserName.SetNameWithColor(Name, NCT_Normal,TA_Center,TargetNameColor);
				//~ NameTxt.SetNameWithColor(Name, NCT_Normal,TA_Center,TargetNameColor);
				RankName.SetName(NameRank, NCT_Normal,TA_Center);
				
				//HP표시
				//branch gd35_0828
				// 대만 패킷 최적화 - gorillazin 13.10.15.
				if (info.nMaxHP > 0)
				{
					bShowHPBar = true;
					UpdateHPBar(info.nCurHP, info.nMaxHP);
				}
				//end of branch

				//MP표시
				//if (!(info.bNpc && !info.bPet && info.bCanBeAttacked))
				if (!(info.bNpc && !info.bPet))
				{
					//branch gd35_0828
					// 대만 패킷 최적화 - gorillazin 13.10.15.
					if (info.nMaxMP > 0)
					{
						bShowMPBar = true;
						UpdateMPBar(info.nCurMP, info.nMaxMP);
					}
					//end of branch
				}
				
				//공중 몬스터인지 구분할 수 있다면	-- 비행 변신체 관련 추가
				//~ if( info.bNpc && !info.bPet && bIsHPShowableNPC )
				//~ {
					//~ UpdateTargetLoc( info.Loc );
					//~ UpdateAltitudeIcon();	// 각도 체크 업데이트
					//~ UpdateDistIcon();	// 거리 체크 업데이트
				//~ }
				
			}
		}
		//Npc or Other Pc
		else
		{
			Name = info.Name;
			
			if (WantHideName)
			{
				RankName.hideWindow();					
			}
			if (info.bNpc)
			{
				NameRank = "";	
				g_NameStr = "";
			}
			else
			{
				//NameRank = GetUserRankString(info.nUserRank);
				g_NameStr = Name;
				UserName.SetName(Name, NCT_Normal,TA_Center);
			//~ NameTxt.SetName(Name, NCT_Normal,TA_Center);
			//RankName.SetName(NameRank, NCT_Normal,TA_Center);

				if (info.nMaxHP > 0)
				{
					bShowHPBar = true;
					UpdateHPBar(info.nCurHP, info.nMaxHP);
				}
				//end of branch

				//MP표시
				//if (!(info.bNpc && !info.bPet && info.bCanBeAttacked))
				if ( !info.bPet )
				{
					//branch gd35_0828
					// 대만 패킷 최적화 - gorillazin 13.10.15.
					if (info.nMaxMP > 0)
					{
						bShowMPBar = true;
						UpdateMPBar(info.nCurMP, info.nMaxMP);
					}
					//end of branch
				}
			}
			
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/// 추가 정보 표시
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		if (m_bExpand)
		{
			if (info.bNpc && 0 >= info.nMasterID)
			{
				if (class'UIDATA_NPC'.static.GetNpcProperty(info.nClassID, arrNpcInfo))
				{
					bShowNpcInfo = true;
					
					//트리컨트롤에 Npc특성아이콘 추가
					//타겟이 바뀌었을때만 정보를 갱신한다. 안그럼 HP만 갱신될 때 깜박거림
					if (IsTargetChanged)
						UpdateNpcInfoTree(arrNpcInfo);
				}				
			}
			else
			{
				bShowPledgeInfo = true;
//				debug ("nClanID.info" @ info.nClanID);
				if (info.nClanID>0)
						
	
	//~ debug ("bShowPledgeInfo" @ bShowPledgeInfo);
	//~ debug ("WantHideName" @ WantHideName);
				{
					//혈맹이름
					PledgeName = class'UIDATA_CLAN'.static.GetName(info.nClanID);
					PledgeNameColor.R = 176;
					PledgeNameColor.G = 152;
					PledgeNameColor.B = 121;
					if( PledgeName != "" && class'UIDATA_USER'.static.GetClanType( m_TargetID, ClanType ) && class'UIDATA_CLAN'.static.GetNameValue(info.nClanID, ClanNameValue) )
					{
						if( ClanType == CLAN_ACADEMY )
						{
							PledgeNameColor.R = 209;
							PledgeNameColor.G = 167;
							PledgeNameColor.B = 2;
						}
						else if( ClanNameValue > 0 )
						{
							PledgeNameColor.R = 0;
							PledgeNameColor.G = 130;
							PledgeNameColor.B = 255;
						}
						else if( ClanNameValue < 0 )
						{
							PledgeNameColor.R = 255;
							PledgeNameColor.G = 0;
							PledgeNameColor.B = 0;
						}
					}
					
					//혈맹 텍스쳐 얻어오기
					if (class'UIDATA_CLAN'.static.GetCrestTexture(info.nClanID, PledgeCrestTexture))
					{
						bShowPledgeTex = true;
						texPledgeCrest.SetTextureWithObject(PledgeCrestTexture);
					}
					else
					{
						bShowPledgeTex = false;
					}
					
					//동맹이름 및 마크
					strTmp = class'UIDATA_CLAN'.static.GetAllianceName(info.nClanID);
					if (Len(strTmp)>0)
					{
						//동맹 이름 색깔
						PledgeAllianceName = strTmp;
						PledgeAllianceNameColor.R = 176;
						PledgeAllianceNameColor.G = 155;
						PledgeAllianceNameColor.B = 121;
						
						//동맹 텍스쳐 얻어오기
						if (class'UIDATA_CLAN'.static.GetAllianceCrestTexture(info.nClanID, PledgeAllianceCrestTexture))
						{
							bShowPledgeAllianceTex = true;
							texPledgeAllianceCrest.SetTextureWithObject(PledgeAllianceCrestTexture);
						}
						else
						{
							bShowPledgeAllianceTex = false;
						}
					}
				}
			}
		}
	}
	if (!Me.IsShowWindow() && GetGameStateName() != "SPECIALCAMERASTATE" )
	{
		Me.ShowWindow();
		Me.SetFocus();
		SetExpandMode(m_bExpand, false);

		// Debug("포커스가 들어온다");
		// 타겟 아이디가 있으면 컨텍스트 메뉴를 생성한다.
	}

	if (ContextMenu(GetScript("ContextMenu")).getContextEventInfo().ID > 0)
	{
	//	Debug("우클릭 메뉴 만들어");
		ContextMenu(GetScript("ContextMenu")).makeContextMenu();
		ContextMenu(GetScript("ContextMenu")).clearInfo();
	}
	
	//HP,MP표시
	if (bShowHPBar ) // && GetGameStateName() != "SPECIALCAMERASTATE" )
	{
		barHP.ShowWindow();
	}
	else
	{
		barHP.HideWindow();
	}
	if (bShowMPBar )//&& GetGameStateName() != "SPECIALCAMERASTATE" )
	{
		barMP.ShowWindow();
	}
	else
	{
		barMP.HIdeWindow();
	}
	
	//Hide Cursed PC Name, ttmayrin
	if( info.nClanID < 0 )
		bShowPledgeInfo = false;
	
	//debug ("nClanID" @ info.nClanID);	
	//debug ("bShowPledgeInfo" @ bShowPledgeInfo);
	//debug ("WantHideName" @ WantHideName);
	
	//혈맹정보 표시
	if (bShowPledgeInfo)
	{
		 if (!WantHideName && GetGameStateName() != "SPECIALCAMERASTATE" )
		{
			txtPledge.ShowWindow();
			txtAlliance.ShowWindow();
			txtPledgeName.ShowWindow();
			txtPledgeAllianceName.ShowWindow();
			txtPledgeName.SetText(PledgeName);
			txtPledgeAllianceName.SetText(PledgeAllianceName);
			txtPledgeName.SetTextColor(PledgeNameColor);
			txtPledgeAllianceName.SetTextColor(PledgeAllianceNameColor);
		
			if (bShowPledgeTex)
			{
				texPledgeCrest.ShowWindow();
				txtPledgeName.MoveTo(rectWnd.nX + 63, rectWnd.nY + 43);
			}
			else
			{
				texPledgeCrest.HideWindow();
				txtPledgeName.MoveTo(rectWnd.nX + 45, rectWnd.nY + 43);
			}
			
			if (bShowPledgeAllianceTex)
			{
				texPledgeAllianceCrest.ShowWindow();
				txtPledgeAllianceName.MoveTo(rectWnd.nX + 63, rectWnd.nY + 59);
			}
			else
			{
				texPledgeAllianceCrest.HideWindow();
				txtPledgeAllianceName.MoveTo(rectWnd.nX + 45, rectWnd.nY + 59);
			}
		}
		
		else
		{		
			txtPledge.HideWindow();
			txtAlliance.HideWindow();
			txtPledgeName.HideWindow();
			txtPledgeAllianceName.HideWindow();
			texPledgeCrest.HideWindow();
			texPledgeAllianceCrest.HideWindow();
		}
	}
	else
	{
		txtPledge.HideWindow();
		txtAlliance.HideWindow();
		txtPledgeName.HideWindow();
		txtPledgeAllianceName.HideWindow();
		texPledgeCrest.HideWindow();
		texPledgeAllianceCrest.HideWindow();
		
	}
	
	//NPC특성 표시
	if (bShowNpcInfo && GetGameStateName() != "SPECIALCAMERASTATE")
	{
		NpcInfo.ShowWindow();
		NpcInfo.ShowScrollBar(false);
	}
	else
	{
		NpcInfo.HideWindow();
	}

	setChangeNameColor(info, Name);
}

// 아레나용 위치 수정
function OnDefaultPosition()
{	
	local string  stateName ;
	stateName = GetGameStateName() ;
	switch ( stateName ) 
	{
		case "ARENAGAMINGSTATE":
		case "ARENAPICKSTATE":
		case "ARENABATTLESTATE":
			Me.SetAnchor("", "TopCenter", "TopCenter", 0, 90 );
			Me.ClearAnchor();	
	}	
}

defaultproperties
{
    m_WindowName="TargetStatusWndArena"
}
