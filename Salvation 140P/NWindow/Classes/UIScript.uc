class UIScript extends UIEventManager
	dynamicrecompile
	native;

var WindowHandle m_hOwnerWnd;
var bool m_bCreated;

enum EventNotificationCondition
{
	NotifyEvent_Always,
	NotifyEvent_Visible,
};

enum PawnType
{
	PT_NONE,
	PT_NPC,
	PT_PC,
	PT_PET,
};

// Dialog API
enum EDialogType
{
	DialogType_OKCancel,
	DialogType_OK,
	DialogType_OKCancelInput,
	DialogType_OKInput,
	DialogType_Warning,
	DialogType_Notice,
	DialogType_NumberPad,
	DialogType_Progress,
};
enum EDialogModalType
{
	DialogModalType_Modal,
	DialogModalType_Modalless,
};

enum DialogDefaultAction
{
	EDefaultNone,
	EDefaultOK,
	EDefaultCancel,
};

enum DialogEnterAction
{
	EEnterNone,
	EEnterOK,
	EEnterCancel,
	EEnterDoNothing,
};

enum PetitionMethod
{
	PetitionMethod_Default,
	PetitionMethod_New,
	PetitionMethod_Web,
};

enum ReleaseMode
{
	RM_DEV,
	RM_RC,
	RM_TEST,
	RM_LIVE,
};

// Console State
native function bool IsPKMode();

native function bool IsFullScreen();
// Client To Server API
native function RequestExit();
native function RequestAuthCardKeyLogin( int uid, string value);
native function RequestSelfTarget();
native function RequestTargetCancel();
native function RequestSkillList();
native function RequestRaidRecord();
native function RequestTradeDone( bool bDone );
native function RequestStartTrade( int targetID );
native function RequestAddTradeItem( ItemID sID, INT64 num );
native function AnswerTradeRequest( bool bOK );
native function RequestSellItem( string param );
native function RequestBuyItem( string param );
native function NotifyFriendRejectState();

native function RequestBuySeed( string param );
//native function RequestProcureCrop( string param );
native function RequestSetSeed( string param );
native function RequestSetCrop( string param );

native function RequestAttack( int ServerID, vector Loc );
native function RequestAction( int ServerID, vector Loc );
native function RequestAssist( int ServerID, vector Loc );
native function RequestTargetUser( int ServerID );
native function RequestWarehouseDeposit( string param );
native function RequestWarehouseWithdraw( string param );
native function RequestChangePetName( string Name );
native function RequestPackageSendableItemList( int targetID );
native function RequestPackageSend( string param );
native function RequestPreviewItem( string param );
native function RequestBBSBoard();
native function RequestMultiSellChoose( string param );
native function RequestRestartPoint( ERestartPointType Type );
//branch
//native function RequestRestartPoint( ERestartPointType Type , optional int NpcItem ); //branch - NpcItem 추가
native function BR_RequestRestartPoint( int Type , optional int NpcItem ); //branch버전 유지 때문에 변수타입을 달리 할 수 밖에 없음. enum 통합 후 삭제한다.
//end of branch
native function RequestUseItem( ItemID sID );
native function RequestDestroyItem( ItemID sID, INT64 num );
native function RequestDropItem( ItemID sID, INT64 num, Vector location );
native function RequestUnequipItem( ItemID sID, INT64 slotBitType );
native function RequestCrystallizeItem( ItemID sID, INT64 number );
native function RequestCrystallizeItemCancel();
native function RequestItemList();		// Ivnetory Item request
native function RequestDuelStart( string sTargetName, int duelType );				// 결투 신청
native function RequestDuelAnswerStart( int duelType, int option, int answer );		// 결투 신청에 대한 응답. option은 결투 수락 가능 옵션의 값. 0 이면 answer는 더미.
native function RequestDuelSurrender();												// 현재 진행 중인 결투에서 항복(패배 인정).
native function RequestDispel(int ServerID, ItemID sID, int SkillLevel, int SkillSubLevel);							// 버프 삭제 요청

// PrivateShop
native function RequestQuitPrivateShop(string type);			// type : "sell", "buy", "sellList", "buyList"	 PrivateShopWnd.uc 참조
native function SendPrivateShopList(string type, string param);

// Party
native function int GetPartyMemberCount();
native function bool GetPartyMemberLocation( int a_PartyMemberIndex, out Vector a_Location );
native function bool GetPartyMemberLocationWithID( int a_PartyMemberSID, out Vector a_Location );


// clan
native function RequestClanMemberInfo( int type, string name );
native function RequestClanGradeList();
native function RequestClanChangeGrade( string sName, int grade );
native function RequestClanAssignPupil( string sMaster, string sPupil );
native function RequestClanDeletePupil( string sMaster, string sPupil );
native function RequestClanLeave(string ClanName, int clanType);
native function RequestClanExpelMember( int clanType, string sName );
native function RequestClanAskJoin( int ID, int clanType );
native function RequestClanAskJoinByName( string sName, int clanType );
native function RequestClanDeclareWar();								// 혈맹 이름 입력창이 뜨고 거기서 이름을 넣는다
native function RequestClanDeclareWarWithUserID( int ID );				// 유저의 ID로 그 유저의 혈맹에 전쟁 선포
native function RequestClanDeclareWarWithClanName( string sName );		// 혈맹 이름으로 전쟁 선포
native function RequestClanWithdrawWar();								// 혈맹 이름 입력창이 뜨고 거기서 이름을 넣는다
native function RequestClanWithdrawWarWithClanName( string sClanName );
native function RequestClanReorganizeMember( int type, string memberName, int clanType, string targetMemberName );

native function bool RequestClanRegisterCrestByFilePath(string FilePath); //혈맹문장등록
native function RequestClanRegisterCrest();
native function RequestClanUnregisterCrest();
native function bool RequestClanRegisterEmblemByFilePath(string FilePath); //혈맹휘장등록
native function RequestClanRegisterEmblem();
native function RequestClanUnregisterEmblem();
//To register alliance crest file
native function bool RequestAllianceRegisterCrestByFilePath(string FilePath); //동맹문장등록

native function RequestClanChangeNickName( string sName, string sNickName );
native function RequestClanWarList( int page, int state );						// state 0:선포 1: 피선포
native function RequestClanAuth( int gradeID );
native function RequestEditClanAuth( int gradeID, array<int> powers );
native function RequestClanMemberAuth( int clanType, string sName );

native function RequestPCCafeCouponUse( string a_CouponKey );

native function string GetCastleName( int castleID );
// 월드맵 개선(#3328) - moonhj
native function int GetCastleRegionID(int castleID);
native function string GetCastleLocationName(int castleID);

native function bool	HasClanCrest();			// 혈맹 문장을 가지고 있는지를 리턴
native function bool	HasClanEmblem();		// 혈맹 휘장을 가지고 있는지를 리턴

native function RequestInviteParty( string sName );
native function RequestInviteMpcc( string Name);

// ClassInfo
native final function string GetClassType( int ClassID ); 
native final function EClassIconType GetClassIndex(int ClassID ); // @deprecate - 작업 이후 삭제 할 것. - y2jinc
native function int	GetClassLevel(int classID);					  // @deprecate - 작업 이후 삭제 할 것. - y2jinc
native function EClassRoleType	GetClassRoleType(int classID);
native final function string	GetClassRoleName( int ClassID ); 
native final function string	GetClassRoleNameByRole( int ClassRole); 
native final function int		GetClassTransferDegree(int ClassID);

// UserInfo
native function bool GetPlayerInfo( out UserInfo a_UserInfo );
native function bool GetTargetInfo( out UserInfo a_UserInfo );
native function bool GetUserInfo( int userID, out UserInfo a_UserInfo );
native function bool GetPetInfo( out PetInfo a_PetInfo );
native function bool GetSummonInfo(int serverID, out SummonInfo a_SummonInfo );
native function GetSummonPoint(out int nSummonedPoint, out int nSummonablePoint);
native function bool GetSkillInfo( int a_SkillID, int a_SkillLevel, int a_SkillSubLevel, out SkillInfo a_SkillInfo );
native function bool GetAccessoryItemID( out ItemID a_LEar, out ItemID a_REar, out ItemID a_LFinger, out ItemID a_RFinger );
native function int GetDecoIndex(ItemID DecoID);
native function int GetJewelIndex(ItemID JewelID);	// ItemID.ServerID 인덱스를 리턴해준다(0~5). JEWEL 추가 - by y2jinc
native function int GetAgathionIndex(ItemID AgathionID);	// Agathion 리뉴얼 : 아가시온 슬롯의 인덱스를 리턴해준다. - sksl93
native function int GetClassStep( int a_ClassID );
native function bool IsBuilderPC();
native function bool IsPlayerStand();




native function string GetClanName( int clanID );
native final function int GetClanNameValue(int iClanID);			// 혈맹 명성치 얻어온다

native final function INT64 GetAdena();								// 현재 인벤토리에 갖고 있는 아데나 카운트를 리턴
native final function string GetAdenaStr();							// 현재 인벤토리에 갖고 있는 아데나 카운트를 String으로 리턴
native final function int GetTeleportBookMarkCount();				// 현재 인벤토리에 갖고 있는 북마크 아이템 카운트를 리턴
//branch
native final function int GetTeleportFlagCount();				// 현재 인벤토리에 갖고 있는 북마크 아이템 카운트를 리턴
//end of branch
//PartyInfo
////MultiSummon by elsacred
native function bool GetPartyMemberInfo(int userID, out PartyMemberInfo partyMemberInfo);
native function bool GetPartyMemberPetInfo(int userID, out PartyMemberPetInfo partyMemberPetInfo);
native function bool GetPartyMemberSummonedInfo(int userID, int summonedID, out PartyMemberSummonedInfo partyMemberSummonedInfo);
////

// Util API
native final function string MakeBuffTimeStr( int Time );
native final function string MakeToppingBuffTimeStr( int Time );
native final function string MakeTimeStr( int Time );
native final function string GetTimeString();
native static function float GetAppSeconds();
native final function GetTimeStruct(int IntTime, out L2UITime UITimeStruct);
native final function string ConvertTimetoStr( int Time );
native final function Debug( string strMsg );
native final function bool IsKeyDown( EInputKey Key );
native final function string GetSystemString(int id);
native final function string GetSystemMessage(int id);
native final function GetSystemMsgInfo(int id, out SystemMsgData SysMsgData);		// lancelot 2006. 10. 11.
native final function string GetSystemMessageWithParamNumber(int id, int param);
native final function string GetNpcString(int id);

native static function UIScript GetScript( string window );
native final function string MakeFullSystemMsg( string sMsg, string sArg1, optional string sArg2, optional string sArg3, optional string sArg4, optional string sArg5 );

native final function GetTextSizeDefault( string strInput, out int nWidth, out int nHeight);
native final function GetTextSize( string strInput, string sFontName, out int nWidth, out int nHeight);
native final function string DivideStringWithWidth(string strInput, int nWidth);
native final function string NextStringWithWidth(int nWidth);

native final function string MakeFullItemName(int id);
native final function string GetItemGradeString(int nCrystalType);
native final function string GetItemGradeTextureName( int nCrystalType );
native final function string MakeCostStringINT64( INT64 a_Input );
native final function string MakeCostString( string strInput );
native final function string ConvertNumToText( string strInput );
native final function string ConvertNumToTextNoAdena( string strInput );
native final function string CeilingNum(string strInput, int positionalNum);
// time(초)를 24시간 이상은 일로, 1시간 이상은 시간으로 1시간 미만은 분으로 반환하는 함수 
native final function string ConvertTimeToString(float time);	
native final function PlayConsoleSound(EInterfaceSoundType eType);
native final function EIMEType GetCurrentIMELang();
native final function texture GetPledgeCrestTexFromPledgeCrestID( int PledgeCrestID );
native final function texture GetAllianceCrestTexFromAllianceCrestID( int AllianceCrestID );
native final function RequestBypassToServer( string strPass );
native final function String GetUserRankString( int Rank );
native final function String GetRoutingString( int RoutingType );
//MultiSummon by elsacred
native final function INT GetDebuffType( ItemID cID, int SkillLevel, int SkillSubLevel );
native final function bool IsSongDance( ItemID cID, int SkillLevel, int SkillSubLevel );
native final function bool IsTriggerSkill( ItemID cID, int SkillLevel, int SkillSubLevel );
native final function bool CheckItemLimit( ItemID cID, INT64 Count );
native function Vector GetClickLocation();

//branch EP1.0 2014-4-29 luciper3 - 국가별로 PC방 포인트 아이템의 아이콘을 변경할때 사용한다.
native function String GetPcCafeItemIconPackageName();
//end of branch

native final function GetCurrentResolution(out int ScreenWidth, out int ScreenHeight);
native final function int GetMaxLevel();

// PrivateStore
native function SetPrivateShopMessage( string type, string message );		// type : "buy" or "sell"
native function string GetPrivateShopMessage( string type );				// type : "buy" or "sell"

//System Message
native final function AddSystemMessage( int Index );
native final function AddSystemMessageString(string msg);
native final function AddSystemMessageParam( string strParam );
native final function string EndSystemMessageParam( int MsgNum, bool bGetMsg );

//Restart & Quit
native final function ExecRestart();
native final function ExecQuit();

//About Server
native final function EServerAgeLimit GetServerAgeLimit();
native final function int GetServerNo();
//native final function int GetServerType();

// Option API
native final function bool CanUseAudio();
native final function bool CanUseJoystick();
native final function bool CanUseHDR();
native final function bool IsEnableEngSelection();
native final function bool IsUseKeyCrypt();
native final function bool IsCheckKeyCrypt();
native final function bool IsEnableKeyCrypt();
native final function ELanguageType GetLanguage();
native final function int GetLanguageCustom(); //branch GD35_0828 2013-11-14 luciper3 - 위함수에서 값리턴받을때 크래쉬남 리턴타입의 문제같음.
native final function GetResolutionList( out Array<ResolutionInfo> a_ResolutionList );
native final function GetRefreshRateList( out Array<int> a_RefreshRateList, optional int a_nWidth, optional int a_nHeight );
native final function SetResolution( int a_nResolutionIndex, int a_nRefreshRateIndex );
native final function int GetMultiSample();
native final function int GetResolutionIndex();
native final function GetShaderVersion( out int a_nPixelShaderVersion, out int a_nVertexShaderVersion );
native final function SetDefaultPosition();
native final function SetKeyCrypt( bool a_bOnOff );
native final function SetTextureDetail( int a_nTextureDetail );
native final function SetModelingDetail( int a_nModelingDetail );
native final function SetMotionDetail( int a_nMotionDetail );
native final function SetEffectDetail( int detail );
native final function SetShadow( bool a_bShadow );
native final function SetBackgroundEffect( bool a_bBackgroundEffect );
native final function SetTerrainClippingRange( int a_nTerrainClippingRange );
native final function SetPawnClippingRange( int a_nPawnClippingRange );
native final function SetReflectionEffect( int a_nReflectionEffect );
native final function SetAntialiasing( int a_nAntialiasing );
native final function SetHDR( int a_nHDR );
native final function SetWeatherEffect( int a_nWeatherEffect );
native final function SetL2Shader( bool a_bShader);
native final function SetDOF( bool a_bDof);
native final function SetDepthBufferShadow( bool a_bShadow);
native final function SetShaderWaterEffect( bool a_bWater);
native final function SetRenderCharacterCount(int a_NewLimitAcotor);	// 옵션에서 "캐릭터 표시제한"셋팅 - lancelot 2007. 11. 15.
native final function SetIgnorePartyInviting(bool a_bIgnore);
native final function SetIgnoreFriendInviting(bool a_bIgnore); //branch 110824 친구신청 거부
native final function SetFixedDefaultCamera(bool a_bFixed);

// Common API
native final function ExecuteCommand( String a_strCmd );
native final function ExecuteCommandFromAction( String strCmd, optional String Param  );
native final function DoAction( ItemID cID );
native final function UseSkill( ItemID cID, int itemSubType );
native final function bool IsStackableItem( int consumeType );
native final function StopMacro();

// Option API
native final function SetOptionBool( string a_strSection, string a_strName, bool a_bValue );
native final function SetOptionInt( string a_strSection, string a_strName, int a_nValue );
native final function SetOptionFloat( string a_strSection, string a_strName, float a_fValue );
native final function SetOptionString( string a_strSection, string a_strName, string a_strValue );
native final function bool GetOptionBool( string a_strSection, string a_strName );
native final function int GetOptionInt( string a_strSection, string a_strName );
native final function float GetOptionFloat( string a_strSection, string a_strName );
native final function string GetOptionString( string a_strSection, string a_strName );

native final function SetChatFilterBool( string a_strSection, string a_strName, bool a_bValue );
native final function bool GetChatFilterBool( string a_strSection, string a_strName );

native final function ApplyOptionToDamageText();

// Inventory Item API
native final function INT64 GetInventoryItemCount( ItemID cID );
native final function string GetSlotTypeString( int ItemType, INT64 SlotBitType, int ArmorType );   // JEWEL 추가 - by y2jinc (2013. 9. 2)
native final function string GetWeaponTypeString( int WeaponType );
native final function int GetPhysicalDamage( int WeaponType, INT64 SlotBitType, int CrystalType, int Enchanted, int PhysicalDamage, int Attribution );  // JEWEL 추가 - by y2jinc (2013. 9. 2)
native final function int GetMagicalDamage( int WeaponType, INT64 SlotBitType, int CrystalType, int Enchanted, int MagicalDamage, int Attribution );    // JEWEL 추가 - by y2jinc (2013. 9. 2)
native final function int GetEnchantedPhysicalDamageBonus( int WeaponType, INT64 SlotBitType, int CrystalType, int Enchanted, int Attribution ); 
native final function int GetEnchantedMagicalDamageBonus( int WeaponType, INT64 SlotBitType, int CrystalType, int Enchanted, int Attribution );  
// JEWEL 추가 - by y2jinc (2013. 9. 2)
native final function bool GetArmorBonusEnchantValue(INT64 SlotBitType, int CrystalType, int Enchanted, int Attribution, out ArmorEnchantBonusValue Value ); //R그레이드 아머에는 보너스 인첸트 값이있다. 혹시모르니 전그레이드에서 사용가능하게 통일해둔다. 0이면 없는거 

native final function bool GetItemBonusEnchantValue( int ClassID, int CrystalType, int Enchanted, int Attribution, out ItemEnchantBonusValue Value ); //R그레이드 템에는 보너스 인첸트 값이 존재. 혹시모르니 전그레이드에서 사용가능하게 통일해둔다. 0이면 없는거

native final function string GetAttackSpeedString( int AttackSpeed );
native final function int GetShieldDefense( int CrystalType, int Enchanted, int ShieldDefense, int Attribution );
native final function int GetEnchantedShieldDefenseBonus( int CrystalType, int Enchanted, int Attribution );
native final function int GetPhysicalDefense( int CrystalType, int Enchanted, int PhysicalDefense, int Attribution );
native final function int GetEnchantedPhysicalDefenseBonus(int CrystalType, int Enchanted, int Attribution );
native final function int GetMagicalDefense( int CrystalType, int Enchanted, int MagicalDefense, int Attribution );
native final function int GetEnchantedMagicalDefenseBonus( int CrystalType, int Enchanted, int Attribution );

native final function float GetSoulShotPower( int crystalType, int enchanted, int weaponType, bool magicWeapon);
native final function float GetSpiritShotPower(  int crystalType, int enchanted, int weaponType, bool magicWeapon);

native final function bool IsMagicalArmor( ItemID cID );
native final function bool IsSigilArmor( ItemID ID );
//branch GD35_0828 2013-12-18 luciper3 - 인자 변경됨
//native final function string GetLottoString( int Enchanted, int Damaged);
native final function string GetLottoString( int nLookChangeItemID);
//end of branch
native final function string GetRaceTicketString( int Blessed );
native final function RequestSaveInventoryOrder( array<ItemID> a_IDList, array<int> a_OrderList );

// INI file option
native final function RefreshINI( String a_INIFileName );
native final function bool GetINIBool( string section, string key, out int value, string file );
native final function bool GetINIInt( string section, string key, out int value, string file );
native final function bool GetINIFloat( string section, string key, out float value, string file );
native final function bool GetINIString( string section, string key, out string value, string file );

native final function SetINIBool( string section, string key, bool value, string file );
native final function SetINIInt( string section, string key, int value, string file );
native final function SetINIFloat( string section, string key, float value, string file );
native final function SetINIString( string section, string key, string value, string file );

// Constant API
native final function bool GetConstantInt( int a_nID, out int a_nValue );
native final function bool GetConstantString( int a_nID, out String a_strValue );
native final function bool GetConstantBool( int a_nID, out int a_bValue );
native final function bool GetConstantFloat( int a_nID, out float a_fValue );

// Audio API
native final function SetSoundVolume( float a_fVolume );
native final function SetEffectVolume( float a_fVolume );
native final function SetAmbientVolume( float a_fVolume );
native final function SetMusicVolume( float a_fVolume );
native final function SetNpcVoiceVolume( float a_fVolume );
native final function SetSystemVoiceVolume( float a_fVolume );
native final function float GetMusicVolume();
native final function TutorialVoiceOff();
native final function TutorialVoiceOn();

// Tooltip API
native final function ReturnTooltipInfo( CustomTooltip Info );

// TextLink API
native final function SetItemTextLink( ItemID a_ID, String a_ItemName );

// 4차 전직
native final function RequestShowVisionMovie(); //branch 무료계정 비전영상 출력
native final function RequestCallToChangeClass();
native final function RequestChangeToAwakenedClass(int bYes);

// Default Events
event OnLoad();
event OnTick();
event OnShow();
event OnHide();
event OnEvent( int a_EventID, String a_Param );
event OnEventWithParamMap(int a_EventID, ParamMap a_ParamMap);
event OnTimer( int TimerID );
event OnMinimize();
event OnEnterState( name a_PreStateName );	//GFx에서는 사용 불가.
event OnExitState( name a_NextStateName );	//GFx에서는 사용 불가.
event OnSendPacketWhenHiding();
//event OnFrameExpandClick( bool bIsExpand );
event OnDefaultPosition();

event OnDrawerShowFinished();
event OnDrawerHideFinished();

// state
event OnRegisterEvent();

// events
event OnSetFocus( WindowHandle a_WindowHandle, bool bFocused );

// Keyboard events
event OnKeyDown( WindowHandle a_WindowHandle, EInputKey Key );
event OnKeyUp( WindowHandle a_WindowHandle, EInputKey Key );
event OnReceivedCloseUI();

// Mouse events
event OnLButtonDown( WindowHandle a_WindowHandle, int X, int Y );
event OnLButtonUp( WindowHandle a_WindowHandle, int X, int Y );
event OnLButtonDblClick( WindowHandle a_WindowHandle, int X, int Y );
event OnRButtonDown( WindowHandle a_WindowHandle, int X, int Y );
event OnRButtonUp( WindowHandle a_WindowHandle, int X, int Y );
event OnRButtonDblClick( WindowHandle a_WindowHandle, int X, int Y );
event OnMButtonDown( WindowHandle a_WindowHandle, int X, int Y );
event OnMButtonUp( WindowHandle a_WindowHandle, int X, int Y );
event OnMouseOver( WindowHandle a_WindowHandle );
event OnMouseOut( WindowHandle a_WindowHandle );
event OnMouseMove( WindowHandle a_WindowHandle, int X, int Y );

// Drag&Drop event
event OnDropItem( String strID, ItemInfo infItem, int x, int y );
event OnDragItemStart( String strID, ItemInfo infItem );
event OnDragItemEnd( String strID );
event OnDropItemSource( String strTarget, ItemInfo infItem );				// 아이템을 드랍했을 경우 드래그를 시작한 윈도우에 불린다.
event OnDropItemWithHandle( WindowHandle hTarget, ItemInfo infItem, int x, int y );
event OnDropWnd( WindowHandle hTarget, WindowHandle hDropWnd, int x, int y );	// 윈도우를 드랍했을 경우

// Button,Tab events
event OnClickButton( String strID );
event OnClickButtonWithHandle( ButtonHandle a_ButtonHandle );
event OnRClickButton( String strID );
event OnButtonTimer( bool bExpired );
event OnTabSplit( string sName );										// 탭윈도우에서 윈도우가 분리될때 보내진다.
event OnTabMerge( string sName );										// 탭윈도우에서 윈도우가 분리되었다가 합쳐질 때 보내진다.

// Editbox events
event OnCompleteEditBox( String strID );
event OnChangeEditBox( String strID );
event OnChatMarkedEditBox( String strID );

// ListCtrl events
event OnClickListCtrlRecord( String strID );
event OnDBClickListCtrlRecord( String strID );

// ListBox events
event OnLButtonClickListBoxItem( String strID, int SelectedIndex );
event OnRButtonClickListBoxItem( String strID, int SelectedIndex );
event OnDBClickListBoxItem( String strID, int SelectedIndex );

// check box events
event OnClickCheckBox( String strID );

// ItemWnd event
event OnClickItem( String strID, int index );
event OnDBClickItem( String strID, int index );
event OnRClickItem( String strID, int index );
event OnRDBClickItem( String strID, int index );
event OnRClickItemWithHandle( ItemWindowHandle a_hItemWindow, int a_Index );
event OnDBClickItemWithHandle( ItemWindowHandle a_hItemWindow, int a_Index );
event OnSelectItemWithHandle( ItemWindowHandle a_hItemWindow, int a_Index );

// ProgressCtrl
event OnProgressTimeUp( String strID );

// combobox event
event OnComboBoxItemSelected( String strID, int index );

// AnimTexture event
event OnTextureAnimEnd( AnimTextureHandle a_AnimTextureHandle );

// PropertyController
event OnPropertyControllerResize( PropertyControllerHandle a_PropertyHandle, int a_Height );

// Html ctrl
event OnHtmlMsgHideWindow(HtmlHandle a_HtmlHandle);

// FlashCtrl event
event OnFlashCtrlMsg(FlashCtrlHandle a_FlashCtrlHandle, String a_Param);

event OnCallUCFunction(string functionName, string param );

// API for MainWnd. This is temporary measure
//native final function SetTabStatusWnd(int x, int y);	2006.8 ttmayrin
//native final function SetTabSkillWnd(int x, int y);	2006.9.27 ttmayrin
//native final function SetTabActionWnd(int x, int y);	2006.9.27 ttmayrin
//native final function SetTabQuestWnd(int x, int y);	2006.7 ttmayrin

// Sound API for MenuWnd - lancelot 2006. 5. 10.
native final function PlaySound( String strSoundName);
native final function PlaySoundUntilEnd( String strSoundName);
native final function StopSound( String a_SoundName );

// MenuWnd API - lancelot 2006. 5. 11.
native final function RequestOpenMinimap();

// Slider control - lancelot 2006. 6. 13.
event OnModifyCurrentTickSliderCtrl(String strID, int iCurrentTick);

// Returns zone name with given zone ID - NeverDie 2006/06/26
native final function string GetCurrentZoneName();
native final function int GetCurrentZoneID();

// same function but using for inzone - jdh84
native final function string GetInZoneNameWithZoneID(int inzoneID);
 
// Henna - lancelot 2006 .6. 29.
native final function RequestHennaItemInfo(int iHennaID);	// 문양새기기 윈도에서 염료 클릭했을때 염료정보 요청
native final function RequestHennaItemList();				// 문양새기기 - 염료정보 윈도에서 "<이전" 버튼 클릭시 이전화면으로
native final function RequestHennaEquip(int iHennaID);				// 문양새기기 - 염료정보 윈도에서 "확인" 버튼 클릭시 문신요청

native final function RequestHennaUnEquipInfo(int iHennaID);	// 문양지우기 윈도에서 문신 클릭했을때 문신정보 요청
native final function RequestHennaUnEquipList();				// 문양 지우기 윈도에서 "<이전"버튼 눌렀을때
native final function RequestHennaUnEquip(int iHennaID);		// 문양 지우기 윈도에서 "확인"버튼 눌렀을때

native final function Vector GetPlayerPosition();
native final function Actor GetCharacterSelectionActor(int a_CharIndex);

// Replay - lancelot 2006. 7. 10.
native final function string GetSystemDir();
native final function GetFileList(out Array<string> FileList, string strDir, string strExtention);
native final function GetDirList(out Array<string> DirList, string strDir);
native final function BeginReplay(string strFileName, bool bLoadCameraInst, bool bLoadChatData);
native final function EraseReplayFile(string strFileName);
// BenchMark- lancelot 2006. 7. 18.
native final function BeginPlay();
native final function BeginBenchMark();

// Skill Train - lancelot 2006. 8. 1.
// 스킬 목록창에서 스킬 정보요청
native final function RequestAcquireSkillInfo(int iID, int iLevel, int iSubLevel, int iType);
// 스킬정보 창에서 스킬 배우기 요청
native final function RequestAcquireSkill(int iID, int iLevel, int iSubLevel, int iType);
native final function RequestAcquireSkillSubClan(int iID, int iLevel, int iType, int iSubClan);

//인챈트 정보 요청
native final function RequestExEnchantSkillInfo(int iID, int iLevel, int iSubLevel);
//인챈트 세부정보 요청
native final function RequestExEnchantSkillInfoDetail(int type, int iID, int iLevel, int iSublevel);
// 인챈트 요청
native final function RequestExEnchantSkill(int type, int iID, int iLevel, int iSublevel);

// ObserverMode
native final function RequestObserverModeEnd();

native final function WindowHandle GetHandle( String a_ControlID, optional WindowHandle a_ParentWnd, optional int a_CloneID );	//Not used anymore
native final function WindowHandle FindHandle( String a_ControlID, optional WindowHandle a_ParentWnd, optional int a_CloneID );	//For UIEditor, ttmayrin

native final function AnimTextureHandle GetAnimTextureHandle( String a_ControlID );
native final function BarHandle GetBarHandle( String a_ControlID );
native final function ButtonHandle GetButtonHandle( String a_ControlID );
native final function ChatWindowHandle GetChatWindowHandle( String a_ControlID );
native final function CheckBoxHandle GetCheckBoxHandle( String a_ControlID );
native final function ComboBoxHandle GetComboBoxHandle( String a_ControlID );
native final function DrawPanelHandle GetDrawPanelHandle( String a_ControlID );
native final function EditBoxHandle GetEditBoxHandle( String a_ControlID );
native final function MultiEditBoxHandle GetMultiEditBoxHandle( String a_ControlID );
native final function HtmlHandle GetHtmlHandle( String a_ControlID );
native final function ItemWindowHandle GetItemWindowHandle( String a_ControlID );
native final function ListBoxHandle GetListBoxHandle( String a_ControlID );
native final function ListCtrlHandle GetListCtrlHandle( String a_ControlID );
native final function MinimapCtrlHandle GetMinimapCtrlHandle( String a_ControlID );
native final function NameCtrlHandle GetNameCtrlHandle( String a_ControlID );
native final function ProgressCtrlHandle GetProgressCtrlHandle( String a_ControlID );
native final function PropertyControllerHandle GetPropertyControllerHandle( String a_ControlID );
native final function RadarMapCtrlHandle GetRadarMapCtrlHandle( String a_ControlID );
native final function SliderCtrlHandle GetSliderCtrlHandle( String a_ControlID );
native final function StatusBarHandle GetStatusBarHandle( String a_ControlID );
native final function StatusIconHandle GetStatusIconHandle( String a_ControlID );
native final function TabHandle GetTabHandle( String a_ControlID );
native final function TextBoxHandle GetTextBoxHandle( String a_ControlID );
native final function TextListBoxHandle GetTextListBoxHandle( String a_ControlID );
native final function TextureHandle GetTextureHandle( String a_ControlID );
native final function TreeHandle GetTreeHandle( String a_ControlID );
//#ifdef USE_DSHOW
//native final function VideoPlayerCtrlHandle GetVideoPlayerCtrlHandle( String a_ControlID );
//#endif
native final function WindowHandle GetWindowHandle( String a_ControlID );
native final function CharacterViewportWindowHandle GetCharacterViewportWindowHandle( String a_ControlID );
native final function SceneCameraCtrlHandle GetSceneCameraCtrlHandle( String a_ControlID );
native final function SceneCameraCtrlHandle GetSceneNpcCtrlHandle( String a_ControlID );
native final function SceneCameraCtrlHandle GetScenePcCtrlHandle( String a_ControlID );
native final function SceneCameraCtrlHandle GetSceneScreenCtrlHandle( String a_ControlID );
native final function SceneCameraCtrlHandle GetSceneMusicCtrlHandle( String a_ControlID );
native final function WebBrowserHandle		GetWebBrowserHandle(string controlID);

// FishViewport
native final function RequestFishRanking();
native final function InitFishViewportWnd(bool Event);
native final function FishFinalAction();

//manor
native final function RequestProcureCropList(string param);
native final function int GetManorCount();
native final function int GetManorIDInManorList(int index);
native final function string GetManorNameInManorList(int index);

// minimap
native final function bool GetQuestLocation(Vector Location);

// LoginMenuWnd
native final function ShowMessageInLogin(string Message);
native final function InitCreditState();

//////////////////////////////////////////////////////////////////////////////////////////////////
// UIEdit
native final function String GetInterfaceDir();
native final function String GetXMLControlString( EXMLControlType type );
native final function EXMLControlType GetXMLControlIndex( String type );
native final function ShowVirtualWindowBackground( bool bShow );
native final function ShowExampleAnimation( bool bShow );

//Tracker
native final function GetTrackerAttachedWindowList( array<WindowHandle> a_WindowList );
native final function WindowHandle GetTrackerAttachedWindow();
native final function ClearTracker();
native final function DeleteAttachedWindow();
native final function ExecuteAlign( ETrackerAlignType Type );
native final function ShowEnableTrackerBox( bool bShow );

// Lobby
native final function CreateNewCharacter();
native final function GotoLogin();
native final function StartGame(int SelectedCharacter);
native final function RequestCharacterSelect(int index);
native function bool GetSelectedCharacterInfo(int index, out UserInfo a_UserInfo);
native final function RequestRestoreCharacter(int index);
native final function RequestDeleteCharacter(int index);
native final function ResetCharacterPosition();
native function bool IsScheduledToDeleteCharacter(int index);
native function bool IsDisciplineCharacter(int index);
native final function SetSelectedCharacter(int index);

//branch
// 듀얼요금제 - F2P 시스템 활성 캐릭터 수 제한 - gorillazin 11.09.15.
//#ifdef DUAL_BILLING_SYSTEM
native function bool IsActivateCharacter(int index);
//#endif
//end of branch

// CharacterCreate
native final function RequestCreateCharacter(string Name, int Race, int Job, int Sex, int HairType, int HairColor, int FaceType);
native final function RequestPrevState();
native final function SetDefaultCharacter();

native final function ClearDefaultCharacterInfo();
native final function ExecLobbyEvent(string EventName, optional bool bReverse);
native final function ExecLobbyNextEvent(string CurEventName, string NextEventName, optional bool bReverse);
native function string GetClassDescription(int index);
native function array<int> GetClassInitialStat(int index);
native function array<int> GetClassInitialStatEx(int ClassType, int Race, int Sex); // 프롤로그 성장 타입의 캐릭터의 스탯 정보를 얻어는 함수(#4606)
native final function ShowDefaultCharacter(int index, optional bool bRaceChanged);
native final function SetCharacterStyle(int index, int HairType, int HairColor, int FaceType);
native final function DefaultCharacterMouseTurn(int index, float Ratio);
native final function DefaultCharacterTurn(int index, float Ratio);
native final function DefaultCharacterStop(int index);
native function bool CheckNameLength(string Name);
native function bool CheckValidName(string Name);
native function int CharacterCreateGetClassType(int Race, int Job, int sex);

// 영지정보관련
native final function RequestAllCastleInfo();
native final function RequestAllFortressInfo();
native final function RequestAllAgitInfo();
native final function RequestFortressSiegeInfo();
native final function RequestFortressMapInfo(int FortressID);

// 지하콜로세움PVP 관련
native final function RequestPVPMatchRecord();




// 닉네임&닉컬러 변경
native final function RequestChangeNicknameNColor(int ColorIndex, string Nickname, ItemID ID);
native final function int GetMaxNicknameColorIndexCnt();
native final function color GetNicknameColorWithIndex(int ColorIndex);

// Premium Item 
native final function RequestWithDrawPremiumItem(int index, INT64 amount);

// Cratae cube - lancelot 2008. 6. 16.
native final function RequestStartShowCrataeCubeRank();
native final function RequestStopShowCrataeCubeRank();

// 영지전 - lancelot 2008. 8. 22.
native final function RequestJoinDominionWar(int DominionID, int Clan, int Join, int JoinID);
native final function RequestDominionInfo();
native final function texture GetDominionFlagIconTex(int DominionID);

// 재매입 추가 - jin 2009.03.18
native function RequestRefundItem( string param );

// 우편 시스템 추가 - elsacred 09.03.19
native final function RequestSendPost(string receivedPerson, int safeMail, string title, string contents, array<RequestItem> itemIDList, INT64 nAdena);
native final function RequestRequestReceivedPostList();
native final function RequestDeleteReceivedPost(array<int> deleteMailList);
native final function RequestRequestReceivedPost(int mailID);
native final function RequestReceivePost(int mailID);
native final function RequestRejectPost(int mailID);
native final function RequestRequestSentPostList();
native final function RequestDeleteSentPost(array<int> deleteMailList);
native final function RequestRequestSentPost(int mailID);
native final function RequestCancelSentPost(int mailID);
native final function RequestPostItemList();

// 진정 개선 - jin 2009.03.30.
native final function RequestShowNewUserPetition();
native final function RequestShowStepTwo(int categoryId);
native final function RequestShowStepThree(int categoryId);
native final function bool GetUseNewPetitionBool();

native final function PetitionMethod GetPetitionMethod();
native final function RequestShowPetitionAsMethod();

// 재매입 통합 - by jin 2009.05.11
native final function RequestBuySellUIClose();
native final function string GetGameStateName();

// For halloween event - lancelot 2009. 10. 7
native function RequestBR_EventRankerList(int iEventID, int iDay, int iRanking); //branch sr : HalloweenEvent

// Weather Editor Tool - by elsacred 2009.07.31
//#ifdef L2_WEATHER_SYSTEM
native final function RequestCreateRainEffect(int imode, int iEmitterposition);
native final function RequestDeleteRainEffect();
native final function RequestSetWeatherEffect(int itype);
native final function RequestSetRainWeight(float fmul);
native final function RequestSetRainEmitterParticleNum(float fmul);
native final function RequestSetRainSpeed(float fmul);
native final function RequestSetRainMeshScale(vector mul);

native final function RequestCreateSnowEffect(int imode, int iEmitterposition);
native final function RequestDeleteSnowEffect();
native final function RequestSetSnowWeight(float fmul);
native final function RequestSetSnowEmitterParticleNum(float fmul);
native final function RequestSetSnowSpeed(float fmul);
native final function RequestSetSnowMeshScale(vector mul);

native final function RequestChangeParticleEmitter(string emitterName);
native final function RequestChangeDiamondMesh(string meshName);
//#endif
// [private market] - by jin 2009.08.18.
native final function ClearAllPrivateMarketInfo();
native final function RefreshPrivateMarketInfo();
native final function RequestMoveToMerchant(int merchantId);

// To access file system for getting file list. jdh84 2009. 10.13
native final function array<FileNameInfo> GetFilesInfoList(string filePath, array<string> arrFilExt);
native final function array<DriveInfo> GetDrivesInfoList();

// couple action - lancelot 2009. 10. 14.
native final function AnswerCoupleAction(int ActionID, int bOk, int requestUserID);

// To get Special directory path -jdh84. 2009.10.19
native final function string GetMydocumentPath(); 
native final function string GetDesktopPath();
native final function string GetMyComputerPath(); //작동안됨
// This is for font testing
//native final function int FontGetLineGap();
//native final function FontSetLineGap( int gap );

//To Modify party looting scheme
native final function RequestPartyLootingModify(int scheme);
native final function RequestPartyLootingModifyAgreement(int agree);

//To know my membership type
native final function RequestAskMemberShip();

native final function RequestAddExpandQuestAlarm(int questId);

native final function RadioButtonHandle GetRadioButtonHandle( String a_ControlID );

// To Make webpage linkage - jdh84. 2010. 1. 4
native final function OpenGivenURL( String URL);
native final function OpenL2Home();

// For YCbCr Effect - elsacred 2010.1.13
native final function RequestSetYCbCrConversionEffect(bool enable);
native final function RequestSetYCbCrVal(float fixCbCr, int playType, float yCOR1, float cbCOR1, float crCOR1, float yCOR2, float cbCOR2, float crCOR2, float YCbCrConsumingTime);

native final function RequestSetHSVConversionEffect(bool enable);
native final function RequestSetHSVVal(float fixHS, int playType, float hCOR1, float sCOR1, float vCOR1, float hCOR2, float sCOR2, float vCOR2, float HSVConsumingTime);

native final function RequestSetRGBConversionEffect(bool enable);
native final function RequestSetRGBVal(int playType, float rCOR1, float gCOR1, float bCOR1, float rCOR2, float gCOR2, float bCOR2, float RGBConsumingTime);

native final function RequestSetColorGradingEffect(bool enable);
native final function RequestSetColorGradingVal(int playType, string COR1, string COR2, float RGBConsumingTime);


native final function RequestSetPostEffect(bool enable, int postEffectID);

native final function RequestPartyMatchWaitList(int a_Page, int a_MinLevel, int a_MaxLevel, int ClassRole, String Name);

native final function RequestMenteeWaitingList(int page, int MinLevel, int MaxLevel);

//For motion blur - jdh84
native final function SetMotionBlurUse(bool bIsUse);
native final function SetMotionBlurAlpha(byte alphavalue);

//toggle recording
native final function ToggleReplayRec();

// For NPC Zoom Camera mode
native final function RequestFinishNPCZoomCamera();

// For HDR Render effect
native final function SetHDRRenderVal(float FinalCoef, float GrayLum, float ClampMin, float ClampMax);
native final function SetUseHDRRenderEffect(bool UseHDREffect);

// For Nature Render
native final function RequestNatureRenderTime(float Time);
native final function RequestNatureRenderIntensity(float Intensity);
native final function RequestNatureRenderRayleigh(float Rayleigh);
native final function RequestNatureRenderMie(float Mie);
native final function RequestNatureRenderTurbidity(float Turbidity);
native final function RequestNatureRenderDir(float Dir);
native final function RequestNatureRenderBlendingRate(float BlendingRate);

// For ultimate skill
native final function int GetActivityUltimateSkillLevel();

native final function texture GetTexture(string name);

//////////////////////////////////////////////////////////////////////////////////////////////////
//branch !! Edited by Overseas Branch : Enyheid

// CashShop API : 
native function RequestBR_CashShopNewICon();		// branch120516
native function RequestBR_GamePoint();		// Cash Item for Russia request
native function RequestBR_ProductList(EBR_CashShopProduct ProductType);		// Cash Item for Russia request branch120516
native function RequestBR_ProductInfo(int iProductID,bool bPresent);//branch120516
native function RequestBR_BuyProduct(int iProductID, int iAmount);
native function RequestBR_RecentProductList();

//branch120516 장바구니
native function RequestBR_AddBasketProductInfo(int iProductID);
native function RequestBR_DeleteBasketProductInfo(int iProductID);
//end of branch

//branch 110824 인게임샵선물하기
native function RequestBR_PresentBuyProduct(int iProductID, int iAmount,string strCharname,string strContent);
native function bool IsBr_CashShopCateory();
native function bool RequestBr_CashShopCateoryIndex();
native function bool IsBr_CashShopPresent();
native function bool IsBr_CashShopCoinToMoney();
native function float GetBr_CashShopCoinToMoneyValue();
//end of branch

native function bool IsBr_CashShopMainDisable(); //branch120703

//native function RequestBR_EventRankerList(int iEventID, int iDay, int iRanking); //branch sr : HalloweenEvent
native function RequestBR_MinigameLoadScores(); //branch sr
native function RequestBR_MinigameInsertScore(int iScore); //branch sr

native function ShowCashChargeWebSite();
native function IsUsingPrimeShop();
native function int BR_GetShowEventUI();

// Util
native final function string BR_ConvertTimeToStr(int time, int bOnlyDay);
native final function int BR_GetDayType(int time, int type);
//end of branch !! Edited by Overseas Branch : Enyheid
//////////////////////////////////////////////////////////////////////////////////////////////////

native final function string GetFormattedTimeStrMMHH(int hour, int minute);		//CT26P4_0323

// NEW_GOODS_INVENTORY : 상품 인벤토리 - 2010.11.3 winkey
native final function RequestGoodsInventoryItemList();					// 상품 인벤토리 아이템 리스트 받기
native final function RequestGoodsInventoryItemDesc( int index );		// 서랍창 정보 받기
native final function RequestUseGoodsInventoryItem( int index );		// 상품 받기
native final function string GetGoodsIconName( int index );				// 상품아이콘 pathname 얻기
native final function bool IsUseGoodsInvnentory();

// SECONDARY_AUTH : 2차 비밀번호 - 2010.11.6 winkey
native final function RequestSecondaryAuthCreate( string password );
native final function RequestSecondaryAuthVerify( string password );
native final function RequestSecondaryAuthModify( string password, string newPassword );
native final function bool IsUseSecondaryAuth();

// NP_ACCOUNT_EXT : NP계정 사용여부
native final function bool IsUseEMailAccount();

native final function RequestCharacterNameCreatable( string charName );


//for request Crystalizing estimation
native final function RequestCrystallizeEstimate(ItemID itemID, INT64 itemCount);

native final function GetShortcutString(int shortcutNum, out ShortcutCommandItem commandItem);

//added for pledge war dialog box
native final function RequestPledgeWar(string PledgeName);
native final function RequestSurrenderPledgeWar(string sPledgeName);

native final function bool IsL2NetLoginState();

native final function bool GetDynamicContentInfo(INT ID, INT Step, out DynamicContentInfo Info);

native final function RequestDynamicQuestProgressInfo(INT ID, INT Step);
native final function RequestDynamicQuestScoreInfo(INT ID, INT Step);

native final function RequestDynamicContentHtml(INT ID, INT Step);
native final function int GetSkillAvailability(int ID, int level, int sublevel);
native final function PawnType GetPawnType(int serverID);
native final function string GetPawnNameFromServerID(int serverID);
native final function vector GetPawnLocFromServerID(int serverID);

native final function RequestTutorialQuestionMarkPressed(int iQuestionID); // deleted
native final function RequestTutorialMarkPressed(int type, int ID);	

native final function RequestAutoLogin();

//l2 동영상 캡쳐
native final function bool IsNowMovieCapturing();
native final function SetMovieCaptureResolution(int w, int h);
native final function MovieCaptureToggle();
native final function SetMovieCaptureHighQuality();
native final function SetMovieCaptureLowQuality();
native final function OpenMovieCaptureDir();

native final function int GetDisplayHeight();
native final function int GetDisplayWidth();

//24hz
native final function bool L224hzIsInstall();
native final function L224hzLeadInstall();
native final function L224hzTurnOn();
native final function L224hzTurnOff();
native final function L224hzGetInfo();
native final function L224hzToggleMode();
native final function L224hzPlay();
native final function L224hzStop();
native final function L224hzPlayPrevSong();
native final function L224hzPlayNextSong();
native final function L224hzPlayPrevList();
native final function L224hzPlayNextList();
native final function L224hzSetVolume(int vol);

native final function string GetL2Path();

native final function int GetMaxVitality();

native final function RequestRegistPartySubstitute(int userID);
native final function RequestDeletePartySubstitute(int userID);
native final function RequestRegistWaitingSubstitute(int admission);
native final function RequestAcceptWaitingSubstitute(int admission, int partyID, int userID);
native final function RequestExchangeSubstitute( int partyMasterServerID, int partyChangeMemberServerID, int waitingPlayerServerID);

native final function float ExpFloat(float a, int exp);
native final function int ExpInt(int a, int exp);

native final function RequestLogin(string s_ID, string s_PassWD, int s_NCOTP);
native final function RequestLoginServer(int serverID);
native final function RequestSecurityCardLogin(string SecurityNum);
native final function RequestGoogleOtpLogin(string SecurityNum);
native final function EulaAgree(bool IsAgree);
native final function RequestSortedServerInfo();
native final function bool IsUseOTP();
native final function RefuseLogin();
native final function StopLogin();

native final function AutoLogin(int server, int character);

native final function SaveLastLoginID(string ID);
native final function string GetLastLoginID();

native final function FullScreenMovieStart();
native final function FullScreenMovieEnd();

native final function RequestFlyMoveStart();	// 점프 아이콘이 나타나서 클릭 했을 때

native final function RequestCardKeyLogin(string Pass);
native final function RequestCardKeyLoginCancel();

native final function bool IsChinaClient();
native final function string GetChinaPkString(); 

native final function StartCredit();
native final function EndCredit();

//For Test Env.. by elsacred
native final function SetTestTerrainAmbientColor(color ambient);
native final function SetTestActorAmbientColor(color ambient);
native final function SetTestStaticMeshAmbientColor(color ambient);
native final function SetTestBspAmbientColor(color ambient);
native final function SetTestSkyBoxColor(color col);
native final function SetTestSkyBspAmbientColor(color ambient);
native final function SetTestHsvActorLightColor(color LightColor);
native final function SetTestHsvStaticMeshLightColor(color LightColor);
native final function SetTestHsvTerrainLightColor(color LightColor);
native final function SetTestGammaSetting(float Brightness, float Contrast, float Gamma);

native final function SetEnableTerrainAmbient(bool bEnable);
native final function SetEnableActorAmbient(bool bEnable);
native final function SetEnableStaticMeshAmbient(bool bEnable);
native final function SetEnableBspAmbient(bool bEnable);
native final function SetEnableSkyBoxColor(bool bEnable);
native final function SetEnableSkyBspAmbient(bool bEnable);
native final function SetEnableHsvActorLight(bool bEnable);
native final function SetEnableHsvStaticMeshLight(bool bEnable);
native final function SetEnableHsvTerrainLight(bool bEnable);
native final function SetEnableGammaSetting(bool bEnable);
native final function SetEnableWindowDefaultGamma(bool bEnable);
native final function SetEnableGammaCorrection(bool bEnable);
native final function SetEnableLightMapIntensity(bool bEnable);
native final function SetEnvTime(float time);
native final function SetTestBeastLightMapIntensity(float Intensity1, float Intensity2);

native final function SetTestGodRayOption(float GodRaySize, float GodRayBrightness, float GodRayEmit);
native final function SetEnableGodRay(bool bEnable);


////
native final function SelectChangeAttributeItem(int groupID, int serverID);
native final function RequestChangeAttributeItem(int groupID, int serverID, int changeAttribute);
native final function RequestChangeAttributeCancel();

native function SetClosingOnESC();
native final function bool HasStackableItemInWareHouse(int Type, int itemID);
native final function bool HasStackableItemInInventory(int Type, int itemID);

native final function RequestInzoneWaitingTime(optional bool bShowWindow);	// 월드맵 개선(#3325) - moonhj

//branch 110824
native final function bool IsNative();
native final function string ToUpper(string text); //branch 111109
native final function string ToLower(string text);
//end of branch

native final function RequestJoinCuriousHouse();
native final function RequestCancelCuriousHouse();
native final function RequestLeaveCuriousHouse();
native final function RequestCuriousHouseHtml();

native final function RequestObservingListCuriousHouse();
native final function RequestObservingCuriousHouse(int HouseID);
native final function RequestLeaveObservingCuriousHouse();

native final function bool IsActivedZoneQuestExist();
native final function bool IsActivedCampaignExist();

native final function bool AmILeader();

native final function SetAlwaysOnBack(bool bAlwaysOnBack);
native final function CallGFxFunction(string windowName, string functionName, string param);

//branch120516
native final function string ConvertBRCashShopDayWeek(int iDayWeek);

native final function bool IsActivedBRCampaignExist();
native final function bool GetEventContentInfo(INT ID, INT Step, INT GoalGroupID, out EventContentInfo Info);
native final function RequestEventCampaignProgressInfo(INT ID, INT Step, INT GoalGroupID);
native final function RequestEventCampaignScoreInfo(INT ID, INT Step, INT GoalGroupID);
native final function RequestEventCampaignHtml(INT ID, INT Step, INT GoalGroupID);

//end of branch

native final function int GetUIUserPremiumLevel(); //branch 유저 프리미엄 레벨

native final function ResponsePetitionAlarm();

native final function int AddTimeData(string Name);
native final function MeasureTimeOn(int id);
native final function MeasureTimeOff(int id);
native final function MeasureTimeStart(int id);
native final function MeasureTimeEnd(int id);

native final function bool IsPlayerOnWorldRaidServer();

native final function ReleaseMode GetReleaseMode();

/////***** CHATTING *****/////
// ithing 2013.05.03
native final function EnableChatWndResizing(bool bEnable);

// lancelot 2008. 8. 23.
native final function color GetChatColorByType(int type);

native final function int ChatNotificationFilter( out string processedMsg, string orignalMsg, string keyword0, string keyword1, string keyword2, string keyword3 );
native final function SetChatMessage( String a_Message, optional bool IsAppend );
native final function ProcessChatMessage( string chatMessage, int type, optional bool bStopMacro );

//Chat Prefix
native function string GetChatPrefix(EChatType type);
native function bool IsSameChatPrefix(EChatType type, string InputPrefix);

// Petition Chat - NeverDie 2006/07/18
native final function ProcessPetitionChatMessage( string a_strChatMsg );

// PartyMatch Chat - NeverDie 2006/07/04
native final function ProcessPartyMatchChatMessage(EChatType ChatType, string a_strChatMsg );

// CommandChannel Chat - ttmayrin 2006/10/10
native final function ProcessCommandChatMessage( string a_strChatMsg );
native final function ProcessCommandInterPartyChatMessage( string a_strChatMsg );
/////***** end of CHATTING *****/////

native final function SwitchSingleMeshMode(bool bUse);

// 연금술 작업 - 연금술 스킬 습득한 리스트 요청
native final function RequestAlchemySkillList();
// 연금술 작업 - 연금술 스킬 등급 알려주는 함수.( 하(1), 중(2), 상(3), 마스터(4), 정보를 찾을수 없는경우(-1) )
native final function int GetAlchemySkillGradeType(int SkillID, int SkillLevel);

//#ifdef ARENA
native final function int GetServerType();
//#else
//native final function bool IsClassicServer();
//#endif

//branch EP1.0 2014.11.24 luciper3 <http://wallis-devsub/redmine/issues/1217>
// #define RECIPE_OFFERING_ENABLE
native final function int RefreshRecipeOfferingRate(INT64 TotalDP, bool bIsShop);
//end of branch

//branch EP1.0 2014.11.3 luciper3 <http://wallis-devsub/redmine/issues/1134>
// 출석부
// #ifdef VIP_ATTENDANCE_ENABLE
native final function RequestAttendanceCheck();
native final function RequestAttendanceWndOpen();
native final function bool IsAttendanceSystemEnable();
//end of branch

//branch EP2.0 2015-2-24 luciper3 <http://wallis-devsub/redmine/issues/1344>
native final function texture GetCaptchaImageTex();
native final function RequestRefreshCaptchaImage(INT64 ID);
native final function RequestCaptchaAnswer(INT64 ID, int AnswerCode);
//end of branch

//branch EP2.0 2015.6.10 luciper3 - 개인상점 이용중인지 체크한다.
native final function bool IsUsePrivateStore();
//end of branch

//branch EP2.0 2015.7.31 luciper3 - Todo_List 오늘의 할 일
native final function RequestTodoListRecommand(bool allLevel); // allLevel : 전체레벨정보여부
native final function RequestTodoListInzone(bool allLevel); // allLevel : 전체레벨정보여부
native final function RequestTodoListHTML(int listType, string typeID); // listType : 목록타입(1:추천, 2:인존), typeID : 해당항목ID(서버에서 받은대로)
native final function RequestOneDayRewardReceive(int serverID); // 보상ID // 수령버튼 누를때
native final function RequestOneDayRewardItemList(int rewardID); // 보상ID // 보상 아이템 리스트 요청API
native final function string RequestOneDayRewardDesc(int rewardID); // 보상ID // 보상 조건 요청API
native final function string RequestOneDayRewardPeriod(int rewardID); // 보상ID // 보상 시간 요청API
native final function RequestTodoListOneDayReward(); // 일일보상창탭 클릭시
native final function bool IsUseToDoList();
//end of branch

//branch EP2.0 2015.6.29 luciper3 - 특화서버 - 공성전 시즌 정보와 보상받기
native final function RequestCastleWarSeasonReward(int SeasonCastleID);
//end of branch

// Faction System(#2029) - moonhj
native final function RequestUserFactionInfo( EFactionRequsetType eType, int nUserServerID );
native final function GetUserFactionInfoList( int nUserServerID, out array<L2UserFactionUIInfo> arrFactionInfoList );
native final function GetFactionData( int nFactionID, out L2FactionUIData FactionData );

// 몬스터 도감(#3471) - sunrice
native final function GetMonsterBookIDs(out array<INT> MonsterBookIDs);	// ID 전체 목록
native final function GetMonsterBookData( int nMonsterBookID, out L2MonsterBookUIData MonsterData );
// 생략, GFx 사용
//native final funtion RequestMonsterBookOpen();
//native final funtion RequestMonsterBookClose();
//native final funtion RequestMonsterBookReward( int MonsterBookID );

// clipboard for copy & paste
native final function ClipboardCopy(string str);
native final function string ClipboardPaste();

// string util
native final function StringIntoArray(string str, string delim, out array<string> tokens);
native final function bool StringMatching(string str, string pattern, string delim);

//branch EP1.0 2015-8-28 luciper3 - UI 요청으로 추가함
native function int appRound(float Value);
native function int appFloor(float Value);
native function int appCeil(float Value);
native function float appFractional(float Value);
//end of branch

//branch EP2.0 2015.8.3 luciper3 - AutoEquip_SoulShot
native final function SoulShotSlotSelected(int type, int iClassID);
native final function SoulShotSlotClicked(int type, int iClassID);
native final function GetAutoEquipShotList(int type, out array<ItemInfo> arrShotItemList);
native final function bool IsUseAutoEquipSoulShot();
//end of branch

//branch EP1.0 2015-8-5 luciper3 - 스팀을 통한 접속인가? GL2UseSteam
native final function bool IsUseSteam();
native final function bool IsUseTokenLogin();
native final function bool CashShopCoinChargeForSteam();
//end of branch

//branch EP2.0 2015.8.19 luciper3 - 혈맹 보너스
native final function PledgeBonusOpen();
native final function PledgeBonusReward(int Type_);
native final function PledgeBonusRewardList();
native final function bool IsUsePledgeBonus();
//end of branch

//branch EP2.5 2015.10.26 luciper3 - 대기열 로그인 기능 추가
native final function CancelWaitingQueueTicket();
//end of branch

//branch EP3.0 2016.9.1 luciper3 - RMT 스팸 차단 리스트
native final function RequestBlockListForAD(string CharName, string ChatMsg);
//end of branch

// 월드맵 개선(#3328) - moonhj
native final function bool GetMinimapRegionIconData(int nRegionId, out MinimapRegionIconData iconData);


// 이벤트 알림(#3898)
native final function int GetEventAlarmDataCount();
native final function GetEventAlarmDataByIndex(int Index, out EventAlarmUIData EventData);

// 출석 체크(#4287)
native final function RequestAccountAttendanceReward(byte cRewardType);
native final function RequestAccountAttendanceInfo();

// 카드 이벤트(#4287)
native final function RequestEntireCardRewardList();
native final function RequestCardReward(int ID);

//branch 2017-4-17 luciper3 - Ban 유저에 대한 코멘트 관련
native final function RequestUserBanInfo(int UserID);

// 숫자 카드 게임(#4288)
native final function CardUpdownGamePickNumber( int nNumber );
native final function CardUpdownGameRewardRequest();
native final function CardUpdownGameRetry();
native final function CardUpdownGameQuit();

// Agathion 리뉴얼
native final function int GetAgathionMainSkillList(int a_iClassID, int a_iEnchanted, out array<SkillInfo> mainSkillList);
native final function int GetAgathionSubSkillList(int a_iClassID, int a_iEnchanted, out array<SkillInfo> subSkillList);
native final function RequestSwapAgathionSlotItems(INT64 SrcSlotBitType, ItemID SrcID, INT64 DesSlotBitType, ItemID DesID);

// 도움말 개선(#4620)
native final function GetTutorialIndices(out array<TutorialIndex> arrTutorialIndices);
native final function bool GetTutorialBody(int id, int level, out TutorialBody outBody);

// 혈맹 미션 시스템(#4596) - by moonhj
native final function bool GetPledgeMissionData(int nMissionID, out PledgeMissionUIData pledgeMissionData);
native final function RequestPledgeMissionInfo();
native final function RequestPledgeMissionReward(int nMissionID);

// 혈맹 창설 UI 개선(#4736)
native final function RequestCreatePledge(string name);

// 혈맹 개편 (상점#4610)
native final function RequestPledgeItemList();
native final function RequestPledgeItemInfo(int nItemClassID);
native final function RequestPledgeItemActivate(int nItemClassId);
native final function RequestPledgeItemBuy(int nItemClassID, int nAmount);
native final function string GetPledgeMasteryName(int nPledgeMasteryID);

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
defaultproperties
{
}
