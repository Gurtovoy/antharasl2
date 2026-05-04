class UIDATA_PAWNVIEWER extends UIDataManager
	native;

// PawnViewer
native static function RequestLoadAllItem();
native static function float GetPawnFrameCount();
native static function float GetPawnCurrentFrame();

native static function bool LoadSelectedCharacter(int index);
native static function bool AddAnimationList(bool ChkAction);

// HairMeshWnd
native static function int GetSelectedCharacterHairColor(int index);
native static function int GetSelectedCharacterHairStyle(int index);
native static function int GetSelectedCharacterFaceStyle(int index);
native static function bool SetSelectedCharacterFaceStyle(int index, int NewFaceStyle);

native static function bool SetPawnResourceSelectedCharacter(int index);


native static function bool AddHairMeshToComboBox(int helmNo);

native static function bool IsNPCPawn();
native static function int GetMaxHairMesh();
native static function int GetFrontHairUserData(int index);
native static function int GetRearHairUserData(int index);
native static function int GetIndexFrontHairMeshUserData(int value); 
native static function int GetIndexRearHairMeshUserData(int value); 
native static function string GetFrontHairTextureString(int SelectedFrontHair, int HairColor, int Helm);
native static function string GetRearHairTextureString(int SelectedRearHair, int HairColor, int Helm);
native static function bool UpdateHairMeshAndTextureInfo(string FrontHairMeshName, string FrontHairTexture, string RearHairMeshName,  string RearHairTexture);

native static function bool AddFaceTextureToComboBox();

native static function bool CreateTestPawn(float ArrowCharacterPercent);
native static function bool ReCreateTestPawn(int index, float ArrowCharacterPercent);
native static function bool DestroyTestPawn(int index);
native static function bool ReserveTestPawn(int count);

native static function bool UseSkill(int index, int CharactorCnt, float Factor);
native static function bool StopSkill(int index, float Factor);
native static function bool DeletePC(int index, float Factor);


native static function bool EquipItem(int SelectedCharacter, ItemID Id, int SlotType);
native static function string GetItemMeshName(int CharacterMeshType, ItemID Id);
native static function string GetItemTextureName(int CharacterMeshType, ItemID Id, int TextureIndex);


native static function bool SummonNewCharacter(int SelectedCharacter);
native static function bool ToggleAttackMode();
native static function bool AttackTarget();
native static function int ChangeCharacter();
native static function bool RotateFace(bool bRotate);

native static function bool ExecuteCommand(string Command);
native static function bool IsL2Seamless();
native static function bool L2Teleport(int MapX, int MapY);
native static function bool StopTime(bool bStop);
native static function bool UnlimitZoom(bool bUnlimit);



native static function int GetSelectedAnimationState(string AniName, float AnimationRate);
native static function PlayAnimation(string AniName, float AnimationRate, bool bLoop);
native static function ResumeAnimation(string AniName, float AnimationRate);
native static function PauseAnimation(string AniName, float AnimationRate);
native static function bool IsPlayingAnimation();
native static function StopAnimation();
native static function bool BeginMixedAnimation(string AniName1, string AniName2, string AniName3, float HitTime);

// Character List
native static function PlayBlendingAnim(string AnimName0, string AnimName1, string StartBoneName1, float BlendAlpha, float InRate, bool bGlobalPose);


// MSViewer
native static function ExecuteSkill(INT SkillID, INT SkillLevel, INT SkillSubLevel, bool multiTarget);
native static function AddSkillByName(string Name);
native static function AddSkillByID(int id);
native static function AddSkillByVisualEffect(string visualEffect);
native static function AddSkillByType(int type);

native static function SpawnDummyPawn( int num );
native static function ClearDummyPawn();

native static function SetSimpleEmitter(bool use);
native static function SetGroundSkillCursor(bool use);

native static function ExecuteEmitterProfiling();
native static function StopEmitterProfiling();
native static function UpdateEmitterProfiling();
native static function bool IsProfilingEmitter();
native static function GetSkillLevelListByID(int skillID, array<int> skillLevelList, array<int> skillSubLevelList);


// SheathingWnd
native static function ApplyLeftAttachBoneName(string BoneName);
native static function ApplyLeftRotation(int Pitch, int Yaw, int Roll);
native static function ApplyLeftOffset(float X, float Y, float Z);
native static function ApplyLeftSheathingHide(bool bHide);

native static function ApplyRightAttachBoneName(string BoneName);
native static function ApplyRightRotation(int Pitch, int Yaw, int Roll);
native static function ApplyRightOffset(float X, float Y, float Z);
native static function ApplyRightSheathingHide(bool bHide);
defaultproperties
{
}
