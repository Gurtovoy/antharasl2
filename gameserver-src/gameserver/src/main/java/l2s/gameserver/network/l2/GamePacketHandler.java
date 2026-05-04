/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2;

import java.nio.BufferUnderflowException;
import java.nio.ByteBuffer;
import l2s.commons.net.nio.impl.IClientFactory;
import l2s.commons.net.nio.impl.IMMOExecutor;
import l2s.commons.net.nio.impl.IPacketHandler;
import l2s.commons.net.nio.impl.MMOConnection;
import l2s.commons.net.nio.impl.ReceivablePacket;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.Action;
import l2s.gameserver.network.l2.c2s.AddTradeItem;
import l2s.gameserver.network.l2.c2s.AnswerCoupleAction;
import l2s.gameserver.network.l2.c2s.AnswerJoinPartyRoom;
import l2s.gameserver.network.l2.c2s.AnswerPartyLootModification;
import l2s.gameserver.network.l2.c2s.AnswerTradeRequest;
import l2s.gameserver.network.l2.c2s.Appearing;
import l2s.gameserver.network.l2.c2s.AttackRequest;
import l2s.gameserver.network.l2.c2s.AuthLogin;
import l2s.gameserver.network.l2.c2s.BypassUserCmd;
import l2s.gameserver.network.l2.c2s.CannotMoveAnymore;
import l2s.gameserver.network.l2.c2s.CharacterCreate;
import l2s.gameserver.network.l2.c2s.CharacterDelete;
import l2s.gameserver.network.l2.c2s.CharacterRestore;
import l2s.gameserver.network.l2.c2s.CharacterSelected;
import l2s.gameserver.network.l2.c2s.ConfirmDlg;
import l2s.gameserver.network.l2.c2s.EnterWorld;
import l2s.gameserver.network.l2.c2s.ExPCCafeRequestOpenWindowWithoutNPC;
import l2s.gameserver.network.l2.c2s.ExRequestVipInfo;
import l2s.gameserver.network.l2.c2s.ExSendClientINI;
import l2s.gameserver.network.l2.c2s.ExSendSelectedQuestZoneID;
import l2s.gameserver.network.l2.c2s.FinishRotatingC;
import l2s.gameserver.network.l2.c2s.GotoLobby;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.c2s.Logout;
import l2s.gameserver.network.l2.c2s.MoveBackwardToLocation;
import l2s.gameserver.network.l2.c2s.MoveWithDelta;
import l2s.gameserver.network.l2.c2s.NetPing;
import l2s.gameserver.network.l2.c2s.NewCharacter;
import l2s.gameserver.network.l2.c2s.NotifyExitBeautyshop;
import l2s.gameserver.network.l2.c2s.NotifyStartMiniGame;
import l2s.gameserver.network.l2.c2s.NotifyTrainingRoomEnd;
import l2s.gameserver.network.l2.c2s.PetitionVote;
import l2s.gameserver.network.l2.c2s.ProtocolVersion;
import l2s.gameserver.network.l2.c2s.ReplyGameGuardQuery;
import l2s.gameserver.network.l2.c2s.RequestAcceptWaitingSubstitute;
import l2s.gameserver.network.l2.c2s.RequestActionUse;
import l2s.gameserver.network.l2.c2s.RequestAddExpandQuestAlarm;
import l2s.gameserver.network.l2.c2s.RequestAllAgitInfo;
import l2s.gameserver.network.l2.c2s.RequestAllCastleInfo;
import l2s.gameserver.network.l2.c2s.RequestAllyCrest;
import l2s.gameserver.network.l2.c2s.RequestAllyInfo;
import l2s.gameserver.network.l2.c2s.RequestAnswerJoinAlly;
import l2s.gameserver.network.l2.c2s.RequestAnswerJoinParty;
import l2s.gameserver.network.l2.c2s.RequestAnswerJoinPledge;
import l2s.gameserver.network.l2.c2s.RequestAquireSkill;
import l2s.gameserver.network.l2.c2s.RequestAquireSkillInfo;
import l2s.gameserver.network.l2.c2s.RequestAskJoinPartyRoom;
import l2s.gameserver.network.l2.c2s.RequestAutoSoulShot;
import l2s.gameserver.network.l2.c2s.RequestBBSwrite;
import l2s.gameserver.network.l2.c2s.RequestBR_MiniGameInsertScore;
import l2s.gameserver.network.l2.c2s.RequestBR_MiniGameLoadScores;
import l2s.gameserver.network.l2.c2s.RequestBR_NewIConCashBtnWnd;
import l2s.gameserver.network.l2.c2s.RequestBlock;
import l2s.gameserver.network.l2.c2s.RequestBlockMemoInfo;
import l2s.gameserver.network.l2.c2s.RequestBookMarkSlotInfo;
import l2s.gameserver.network.l2.c2s.RequestBuyItem;
import l2s.gameserver.network.l2.c2s.RequestBypassToServer;
import l2s.gameserver.network.l2.c2s.RequestCastleSiegeAttackerList;
import l2s.gameserver.network.l2.c2s.RequestCastleSiegeDefenderList;
import l2s.gameserver.network.l2.c2s.RequestChangeAttributeCancel;
import l2s.gameserver.network.l2.c2s.RequestChangeAttributeItem;
import l2s.gameserver.network.l2.c2s.RequestChangeBookMarkSlot;
import l2s.gameserver.network.l2.c2s.RequestChangeNicknameColor;
import l2s.gameserver.network.l2.c2s.RequestChangePetName;
import l2s.gameserver.network.l2.c2s.RequestCharacterNameCreatable;
import l2s.gameserver.network.l2.c2s.RequestConfirmCancelItem;
import l2s.gameserver.network.l2.c2s.RequestConfirmCastleSiegeWaitingList;
import l2s.gameserver.network.l2.c2s.RequestConfirmGemStone;
import l2s.gameserver.network.l2.c2s.RequestConfirmRefinerItem;
import l2s.gameserver.network.l2.c2s.RequestConfirmTargetItem;
import l2s.gameserver.network.l2.c2s.RequestCreatePledge;
import l2s.gameserver.network.l2.c2s.RequestCrystallizeEstimate;
import l2s.gameserver.network.l2.c2s.RequestCrystallizeItem;
import l2s.gameserver.network.l2.c2s.RequestCrystallizeItemCancel;
import l2s.gameserver.network.l2.c2s.RequestDeleteBookMarkSlot;
import l2s.gameserver.network.l2.c2s.RequestDeleteMacro;
import l2s.gameserver.network.l2.c2s.RequestDeletePartySubstitute;
import l2s.gameserver.network.l2.c2s.RequestDestroyItem;
import l2s.gameserver.network.l2.c2s.RequestDismissAlly;
import l2s.gameserver.network.l2.c2s.RequestDismissParty;
import l2s.gameserver.network.l2.c2s.RequestDismissPartyRoom;
import l2s.gameserver.network.l2.c2s.RequestDispel;
import l2s.gameserver.network.l2.c2s.RequestDivideAdena;
import l2s.gameserver.network.l2.c2s.RequestDivideAdenaCancel;
import l2s.gameserver.network.l2.c2s.RequestDivideAdenaStart;
import l2s.gameserver.network.l2.c2s.RequestDropItem;
import l2s.gameserver.network.l2.c2s.RequestDuelAnswerStart;
import l2s.gameserver.network.l2.c2s.RequestDuelStart;
import l2s.gameserver.network.l2.c2s.RequestDuelSurrender;
import l2s.gameserver.network.l2.c2s.RequestEnchantItem;
import l2s.gameserver.network.l2.c2s.RequestEquipItem;
import l2s.gameserver.network.l2.c2s.RequestEx2ndPasswordCheck;
import l2s.gameserver.network.l2.c2s.RequestEx2ndPasswordReq;
import l2s.gameserver.network.l2.c2s.RequestEx2ndPasswordVerify;
import l2s.gameserver.network.l2.c2s.RequestExAddEnchantScrollItem;
import l2s.gameserver.network.l2.c2s.RequestExAddPostFriendForPostBox;
import l2s.gameserver.network.l2.c2s.RequestExAutoFish;
import l2s.gameserver.network.l2.c2s.RequestExBR_BuyProduct;
import l2s.gameserver.network.l2.c2s.RequestExBR_EventRankerList;
import l2s.gameserver.network.l2.c2s.RequestExBR_GamePoint;
import l2s.gameserver.network.l2.c2s.RequestExBR_LectureMark;
import l2s.gameserver.network.l2.c2s.RequestExBuySellUIClose;
import l2s.gameserver.network.l2.c2s.RequestExCancelEnchantItem;
import l2s.gameserver.network.l2.c2s.RequestExCancelSentPost;
import l2s.gameserver.network.l2.c2s.RequestExCancelShapeShiftingItem;
import l2s.gameserver.network.l2.c2s.RequestExChangeName;
import l2s.gameserver.network.l2.c2s.RequestExCleftEnter;
import l2s.gameserver.network.l2.c2s.RequestExDeletePostFriendForPostBox;
import l2s.gameserver.network.l2.c2s.RequestExDeleteReceivedPost;
import l2s.gameserver.network.l2.c2s.RequestExDeleteSentPost;
import l2s.gameserver.network.l2.c2s.RequestExDismissMpccRoom;
import l2s.gameserver.network.l2.c2s.RequestExDominionInfo;
import l2s.gameserver.network.l2.c2s.RequestExEndScenePlayer;
import l2s.gameserver.network.l2.c2s.RequestExEscapeScene;
import l2s.gameserver.network.l2.c2s.RequestExEventMatchObserverEnd;
import l2s.gameserver.network.l2.c2s.RequestExFriendListForPostBox;
import l2s.gameserver.network.l2.c2s.RequestExJoinDominionWar;
import l2s.gameserver.network.l2.c2s.RequestExJoinMpccRoom;
import l2s.gameserver.network.l2.c2s.RequestExJump;
import l2s.gameserver.network.l2.c2s.RequestExListMpccWaiting;
import l2s.gameserver.network.l2.c2s.RequestExMPCCAcceptJoin;
import l2s.gameserver.network.l2.c2s.RequestExMPCCAskJoin;
import l2s.gameserver.network.l2.c2s.RequestExMPCCShowPartyMembersInfo;
import l2s.gameserver.network.l2.c2s.RequestExMagicSkillUseGround;
import l2s.gameserver.network.l2.c2s.RequestExManageMpccRoom;
import l2s.gameserver.network.l2.c2s.RequestExMpccPartymasterList;
import l2s.gameserver.network.l2.c2s.RequestExOlympiadObserverEnd;
import l2s.gameserver.network.l2.c2s.RequestExOustFromMPCC;
import l2s.gameserver.network.l2.c2s.RequestExOustFromMpccRoom;
import l2s.gameserver.network.l2.c2s.RequestExPostItemList;
import l2s.gameserver.network.l2.c2s.RequestExReceivePost;
import l2s.gameserver.network.l2.c2s.RequestExRefundItem;
import l2s.gameserver.network.l2.c2s.RequestExRejectPost;
import l2s.gameserver.network.l2.c2s.RequestExRemoveEnchantSupportItem;
import l2s.gameserver.network.l2.c2s.RequestExRemoveItemAttribute;
import l2s.gameserver.network.l2.c2s.RequestExRequestReceivedPost;
import l2s.gameserver.network.l2.c2s.RequestExRequestReceivedPostList;
import l2s.gameserver.network.l2.c2s.RequestExRequestSentPost;
import l2s.gameserver.network.l2.c2s.RequestExRequestSentPostList;
import l2s.gameserver.network.l2.c2s.RequestExRqItemLink;
import l2s.gameserver.network.l2.c2s.RequestExSendPost;
import l2s.gameserver.network.l2.c2s.RequestExSetPledgeCrestLargeFirstPart;
import l2s.gameserver.network.l2.c2s.RequestExShowNewUserPetition;
import l2s.gameserver.network.l2.c2s.RequestExShowPostFriendListForPostBox;
import l2s.gameserver.network.l2.c2s.RequestExShowStepThree;
import l2s.gameserver.network.l2.c2s.RequestExShowStepTwo;
import l2s.gameserver.network.l2.c2s.RequestExTryToPutEnchantSupportItem;
import l2s.gameserver.network.l2.c2s.RequestExTryToPutEnchantTargetItem;
import l2s.gameserver.network.l2.c2s.RequestExTryToPutShapeShiftingEnchantSupportItem;
import l2s.gameserver.network.l2.c2s.RequestExTryToPutShapeShiftingTargetItem;
import l2s.gameserver.network.l2.c2s.RequestExWithdrawMpccRoom;
import l2s.gameserver.network.l2.c2s.RequestExitPartyMatchingWaitingRoom;
import l2s.gameserver.network.l2.c2s.RequestFirstPlayStart;
import l2s.gameserver.network.l2.c2s.RequestFriendAddReply;
import l2s.gameserver.network.l2.c2s.RequestFriendDel;
import l2s.gameserver.network.l2.c2s.RequestFriendDetailInfo;
import l2s.gameserver.network.l2.c2s.RequestFriendInfoList;
import l2s.gameserver.network.l2.c2s.RequestFriendInvite;
import l2s.gameserver.network.l2.c2s.RequestGMCommand;
import l2s.gameserver.network.l2.c2s.RequestGetItemFromPet;
import l2s.gameserver.network.l2.c2s.RequestGetOffShuttle;
import l2s.gameserver.network.l2.c2s.RequestGetOffVehicle;
import l2s.gameserver.network.l2.c2s.RequestGetOnShuttle;
import l2s.gameserver.network.l2.c2s.RequestGetOnVehicle;
import l2s.gameserver.network.l2.c2s.RequestGiveItemToPet;
import l2s.gameserver.network.l2.c2s.RequestGiveNickName;
import l2s.gameserver.network.l2.c2s.RequestGmList;
import l2s.gameserver.network.l2.c2s.RequestGoodsInventoryInfo;
import l2s.gameserver.network.l2.c2s.RequestHandOverPartyMaster;
import l2s.gameserver.network.l2.c2s.RequestHardWareInfo;
import l2s.gameserver.network.l2.c2s.RequestHennaEquip;
import l2s.gameserver.network.l2.c2s.RequestHennaItemInfo;
import l2s.gameserver.network.l2.c2s.RequestHennaList;
import l2s.gameserver.network.l2.c2s.RequestHennaUnequip;
import l2s.gameserver.network.l2.c2s.RequestHennaUnequipInfo;
import l2s.gameserver.network.l2.c2s.RequestHennaUnequipList;
import l2s.gameserver.network.l2.c2s.RequestInzoneWaitingTime;
import l2s.gameserver.network.l2.c2s.RequestItemAuctionStatus;
import l2s.gameserver.network.l2.c2s.RequestItemEnsoul;
import l2s.gameserver.network.l2.c2s.RequestItemList;
import l2s.gameserver.network.l2.c2s.RequestJoinAlly;
import l2s.gameserver.network.l2.c2s.RequestJoinCastleSiege;
import l2s.gameserver.network.l2.c2s.RequestJoinParty;
import l2s.gameserver.network.l2.c2s.RequestJoinPledge;
import l2s.gameserver.network.l2.c2s.RequestJoinPledgeByName;
import l2s.gameserver.network.l2.c2s.RequestKeyMapping;
import l2s.gameserver.network.l2.c2s.RequestLinkHtml;
import l2s.gameserver.network.l2.c2s.RequestListPartyMatchingWaitingRoom;
import l2s.gameserver.network.l2.c2s.RequestLuckyGamePlay;
import l2s.gameserver.network.l2.c2s.RequestLuckyGameStartInfo;
import l2s.gameserver.network.l2.c2s.RequestMagicSkillList;
import l2s.gameserver.network.l2.c2s.RequestMagicSkillUse;
import l2s.gameserver.network.l2.c2s.RequestMakeMacro;
import l2s.gameserver.network.l2.c2s.RequestModifyBookMarkSlot;
import l2s.gameserver.network.l2.c2s.RequestMoveToLocationInShuttle;
import l2s.gameserver.network.l2.c2s.RequestMoveToLocationInVehicle;
import l2s.gameserver.network.l2.c2s.RequestMultiSellChoose;
import l2s.gameserver.network.l2.c2s.RequestNewEnchantClose;
import l2s.gameserver.network.l2.c2s.RequestNewEnchantPushOne;
import l2s.gameserver.network.l2.c2s.RequestNewEnchantPushTwo;
import l2s.gameserver.network.l2.c2s.RequestNewEnchantRemoveOne;
import l2s.gameserver.network.l2.c2s.RequestNewEnchantRemoveTwo;
import l2s.gameserver.network.l2.c2s.RequestNewEnchantTry;
import l2s.gameserver.network.l2.c2s.RequestObserverEnd;
import l2s.gameserver.network.l2.c2s.RequestOlympiadMatchList;
import l2s.gameserver.network.l2.c2s.RequestOlympiadObserverEnd;
import l2s.gameserver.network.l2.c2s.RequestOneDayRewardReceive;
import l2s.gameserver.network.l2.c2s.RequestOustAlly;
import l2s.gameserver.network.l2.c2s.RequestOustFromPartyRoom;
import l2s.gameserver.network.l2.c2s.RequestOustPartyMember;
import l2s.gameserver.network.l2.c2s.RequestOustPledgeMember;
import l2s.gameserver.network.l2.c2s.RequestPCCafeCouponUse;
import l2s.gameserver.network.l2.c2s.RequestPVPMatchRecord;
import l2s.gameserver.network.l2.c2s.RequestPackageSend;
import l2s.gameserver.network.l2.c2s.RequestPackageSendableItemList;
import l2s.gameserver.network.l2.c2s.RequestPartyLootModification;
import l2s.gameserver.network.l2.c2s.RequestPartyMatchConfig;
import l2s.gameserver.network.l2.c2s.RequestPartyMatchDetail;
import l2s.gameserver.network.l2.c2s.RequestPartyMatchList;
import l2s.gameserver.network.l2.c2s.RequestPartyMatchingHistory;
import l2s.gameserver.network.l2.c2s.RequestPetGetItem;
import l2s.gameserver.network.l2.c2s.RequestPetUseItem;
import l2s.gameserver.network.l2.c2s.RequestPetition;
import l2s.gameserver.network.l2.c2s.RequestPetitionCancel;
import l2s.gameserver.network.l2.c2s.RequestPledgeBonusOpen;
import l2s.gameserver.network.l2.c2s.RequestPledgeBonusReward;
import l2s.gameserver.network.l2.c2s.RequestPledgeBonusRewardList;
import l2s.gameserver.network.l2.c2s.RequestPledgeCrest;
import l2s.gameserver.network.l2.c2s.RequestPledgeCrestLarge;
import l2s.gameserver.network.l2.c2s.RequestPledgeDraftListApply;
import l2s.gameserver.network.l2.c2s.RequestPledgeDraftListSearch;
import l2s.gameserver.network.l2.c2s.RequestPledgeExtendedInfo;
import l2s.gameserver.network.l2.c2s.RequestPledgeInfo;
import l2s.gameserver.network.l2.c2s.RequestPledgeJoinSys;
import l2s.gameserver.network.l2.c2s.RequestPledgeMemberInfo;
import l2s.gameserver.network.l2.c2s.RequestPledgeMemberList;
import l2s.gameserver.network.l2.c2s.RequestPledgeMemberPowerInfo;
import l2s.gameserver.network.l2.c2s.RequestPledgePower;
import l2s.gameserver.network.l2.c2s.RequestPledgePowerGradeList;
import l2s.gameserver.network.l2.c2s.RequestPledgeRecruitApplyInfo;
import l2s.gameserver.network.l2.c2s.RequestPledgeRecruitBoardAccess;
import l2s.gameserver.network.l2.c2s.RequestPledgeRecruitBoardDetail;
import l2s.gameserver.network.l2.c2s.RequestPledgeRecruitBoardSearch;
import l2s.gameserver.network.l2.c2s.RequestPledgeRecruitInfo;
import l2s.gameserver.network.l2.c2s.RequestPledgeReorganizeMember;
import l2s.gameserver.network.l2.c2s.RequestPledgeSetAcademyMaster;
import l2s.gameserver.network.l2.c2s.RequestPledgeSetMemberPowerGrade;
import l2s.gameserver.network.l2.c2s.RequestPledgeSignInForOpenJoiningMethod;
import l2s.gameserver.network.l2.c2s.RequestPledgeWaitingApplied;
import l2s.gameserver.network.l2.c2s.RequestPledgeWaitingApply;
import l2s.gameserver.network.l2.c2s.RequestPledgeWaitingList;
import l2s.gameserver.network.l2.c2s.RequestPledgeWaitingUser;
import l2s.gameserver.network.l2.c2s.RequestPledgeWaitingUserAccept;
import l2s.gameserver.network.l2.c2s.RequestPledgeWarList;
import l2s.gameserver.network.l2.c2s.RequestPreviewItem;
import l2s.gameserver.network.l2.c2s.RequestPrivateStoreBuy;
import l2s.gameserver.network.l2.c2s.RequestPrivateStoreBuyManage;
import l2s.gameserver.network.l2.c2s.RequestPrivateStoreBuySellList;
import l2s.gameserver.network.l2.c2s.RequestPrivateStoreList;
import l2s.gameserver.network.l2.c2s.RequestPrivateStoreQuitBuy;
import l2s.gameserver.network.l2.c2s.RequestPrivateStoreQuitSell;
import l2s.gameserver.network.l2.c2s.RequestQuestAbort;
import l2s.gameserver.network.l2.c2s.RequestQuestList;
import l2s.gameserver.network.l2.c2s.RequestRaidBossSpawnInfo;
import l2s.gameserver.network.l2.c2s.RequestRaidServerInfo;
import l2s.gameserver.network.l2.c2s.RequestRecipeBookOpen;
import l2s.gameserver.network.l2.c2s.RequestRecipeItemDelete;
import l2s.gameserver.network.l2.c2s.RequestRecipeItemMakeInfo;
import l2s.gameserver.network.l2.c2s.RequestRecipeItemMakeSelf;
import l2s.gameserver.network.l2.c2s.RequestRecipeShopListSet;
import l2s.gameserver.network.l2.c2s.RequestRecipeShopMakeDo;
import l2s.gameserver.network.l2.c2s.RequestRecipeShopMakeInfo;
import l2s.gameserver.network.l2.c2s.RequestRecipeShopManageCancel;
import l2s.gameserver.network.l2.c2s.RequestRecipeShopManageQuit;
import l2s.gameserver.network.l2.c2s.RequestRecipeShopMessageSet;
import l2s.gameserver.network.l2.c2s.RequestRecipeShopSellList;
import l2s.gameserver.network.l2.c2s.RequestRefine;
import l2s.gameserver.network.l2.c2s.RequestRefineCancel;
import l2s.gameserver.network.l2.c2s.RequestRegistPartySubstitute;
import l2s.gameserver.network.l2.c2s.RequestRegistWaitingSubstitute;
import l2s.gameserver.network.l2.c2s.RequestReload;
import l2s.gameserver.network.l2.c2s.RequestRemainTime;
import l2s.gameserver.network.l2.c2s.RequestReplyStartPledgeWar;
import l2s.gameserver.network.l2.c2s.RequestReplyStopPledgeWar;
import l2s.gameserver.network.l2.c2s.RequestReplySurrenderPledgeWar;
import l2s.gameserver.network.l2.c2s.RequestResetNickname;
import l2s.gameserver.network.l2.c2s.RequestRestart;
import l2s.gameserver.network.l2.c2s.RequestRestartPoint;
import l2s.gameserver.network.l2.c2s.RequestSEKCustom;
import l2s.gameserver.network.l2.c2s.RequestSSQStatus;
import l2s.gameserver.network.l2.c2s.RequestSaveBookMarkSlot;
import l2s.gameserver.network.l2.c2s.RequestSaveInventoryOrder;
import l2s.gameserver.network.l2.c2s.RequestSaveKeyMapping;
import l2s.gameserver.network.l2.c2s.RequestSellItem;
import l2s.gameserver.network.l2.c2s.RequestSendL2FriendSay;
import l2s.gameserver.network.l2.c2s.RequestSendMsnChatLog;
import l2s.gameserver.network.l2.c2s.RequestSetAllyCrest;
import l2s.gameserver.network.l2.c2s.RequestSetCastleSiegeTime;
import l2s.gameserver.network.l2.c2s.RequestSetPledgeCrest;
import l2s.gameserver.network.l2.c2s.RequestShapeShiftingItem;
import l2s.gameserver.network.l2.c2s.RequestShortCutDel;
import l2s.gameserver.network.l2.c2s.RequestShortCutReg;
import l2s.gameserver.network.l2.c2s.RequestShowAgitSiegeInfo;
import l2s.gameserver.network.l2.c2s.RequestShowBoard;
import l2s.gameserver.network.l2.c2s.RequestShowMiniMap;
import l2s.gameserver.network.l2.c2s.RequestSiegeInfo;
import l2s.gameserver.network.l2.c2s.RequestSkillCoolTime;
import l2s.gameserver.network.l2.c2s.RequestSkillList;
import l2s.gameserver.network.l2.c2s.RequestStartPledgeWar;
import l2s.gameserver.network.l2.c2s.RequestStatus;
import l2s.gameserver.network.l2.c2s.RequestStopMove;
import l2s.gameserver.network.l2.c2s.RequestStopPledgeWar;
import l2s.gameserver.network.l2.c2s.RequestSurrenderPledgeWar;
import l2s.gameserver.network.l2.c2s.RequestSwapAgathionSlotItems;
import l2s.gameserver.network.l2.c2s.RequestTargetActionMenu;
import l2s.gameserver.network.l2.c2s.RequestTargetCanceld;
import l2s.gameserver.network.l2.c2s.RequestTeleport;
import l2s.gameserver.network.l2.c2s.RequestTeleportBookMark;
import l2s.gameserver.network.l2.c2s.RequestTimeCheck;
import l2s.gameserver.network.l2.c2s.RequestTodoList;
import l2s.gameserver.network.l2.c2s.RequestTodoListHTML;
import l2s.gameserver.network.l2.c2s.RequestTryEnSoulExtraction;
import l2s.gameserver.network.l2.c2s.RequestTutorialClientEvent;
import l2s.gameserver.network.l2.c2s.RequestTutorialLinkHtml;
import l2s.gameserver.network.l2.c2s.RequestTutorialPassCmdToServer;
import l2s.gameserver.network.l2.c2s.RequestTutorialQuestionMark;
import l2s.gameserver.network.l2.c2s.RequestUnEquipItem;
import l2s.gameserver.network.l2.c2s.RequestUpdateBlockMemo;
import l2s.gameserver.network.l2.c2s.RequestUpdateFriendMemo;
import l2s.gameserver.network.l2.c2s.RequestUserBanInfo;
import l2s.gameserver.network.l2.c2s.RequestVipAttendanceCheck;
import l2s.gameserver.network.l2.c2s.RequestVipAttendanceItemList;
import l2s.gameserver.network.l2.c2s.RequestVipLuckyGameBonus;
import l2s.gameserver.network.l2.c2s.RequestVipLuckyGameInfo;
import l2s.gameserver.network.l2.c2s.RequestVipLuckyGameItemList;
import l2s.gameserver.network.l2.c2s.RequestVipProductList;
import l2s.gameserver.network.l2.c2s.RequestVoteNew;
import l2s.gameserver.network.l2.c2s.RequestWithDrawalParty;
import l2s.gameserver.network.l2.c2s.RequestWithdrawAlly;
import l2s.gameserver.network.l2.c2s.RequestWithdrawPartyRoom;
import l2s.gameserver.network.l2.c2s.RequestWithdrawalPledge;
import l2s.gameserver.network.l2.c2s.RequestWriteHeroWords;
import l2s.gameserver.network.l2.c2s.Say2C;
import l2s.gameserver.network.l2.c2s.SendBypassBuildCmd;
import l2s.gameserver.network.l2.c2s.SendChangeAttributeTargetItem;
import l2s.gameserver.network.l2.c2s.SendWareHouseDepositList;
import l2s.gameserver.network.l2.c2s.SendWareHouseWithDrawList;
import l2s.gameserver.network.l2.c2s.SetPrivateStoreBuyList;
import l2s.gameserver.network.l2.c2s.SetPrivateStoreMsgBuy;
import l2s.gameserver.network.l2.c2s.SetPrivateStoreMsgSell;
import l2s.gameserver.network.l2.c2s.SetPrivateStoreSellList;
import l2s.gameserver.network.l2.c2s.SetPrivateStoreWholeMsg;
import l2s.gameserver.network.l2.c2s.SnoopQuit;
import l2s.gameserver.network.l2.c2s.StartRotatingC;
import l2s.gameserver.network.l2.c2s.TradeDone;
import l2s.gameserver.network.l2.c2s.TradeRequest;
import l2s.gameserver.network.l2.c2s.UseItem;
import l2s.gameserver.network.l2.c2s.ValidatePosition;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class GamePacketHandler
implements IPacketHandler<GameClient>,
IClientFactory<GameClient>,
IMMOExecutor<GameClient> {
    private static final Logger _log = LoggerFactory.getLogger(GamePacketHandler.class);

    public ReceivablePacket<GameClient> handlePacket(ByteBuffer buf, GameClient client) {
        int id = buf.get() & 0xFF;
        L2GameClientPacket msg = null;
        try {
            int id2 = 0;
            block1 : switch (client.getState()) {
                case CONNECTED: {
                    switch (id) {
                        case 0: {
                            msg = new RequestStatus();
                            break block1;
                        }
                        case 14: {
                            msg = new ProtocolVersion();
                            break block1;
                        }
                        case 31: {
                            break block1;
                        }
                        case 43: {
                            msg = new AuthLogin();
                            break block1;
                        }
                        case 203: {
                            msg = new ReplyGameGuardQuery();
                            break block1;
                        }
                        case 208: {
                            int id3 = buf.getShort() & 0xFFFF;
                            switch (id3) {
                                case 260: {
                                    msg = new ExSendClientINI();
                                    break block1;
                                }
                            }
                            client.onUnknownPacket();
                            _log.warn("Unknown client packet! State: CONNECTED, packet ID: " + Integer.toHexString(id).toUpperCase() + ":" + Integer.toHexString(id3).toUpperCase());
                            break block1;
                        }
                    }
                    client.onUnknownPacket();
                    _log.warn("Unknown client packet! State: CONNECTED, packet ID: " + Integer.toHexString(id).toUpperCase());
                    break;
                }
                case AUTHED: {
                    switch (id) {
                        case 0: {
                            msg = new Logout();
                            break block1;
                        }
                        case 12: {
                            msg = new CharacterCreate();
                            break block1;
                        }
                        case 13: {
                            msg = new CharacterDelete();
                            break block1;
                        }
                        case 18: {
                            msg = new CharacterSelected();
                            break block1;
                        }
                        case 19: {
                            msg = new NewCharacter();
                            break block1;
                        }
                        case 123: {
                            msg = new CharacterRestore();
                            break block1;
                        }
                        case 203: {
                            msg = new ReplyGameGuardQuery();
                            break block1;
                        }
                        case 208: {
                            int id3 = buf.getShort() & 0xFFFF;
                            switch (id3) {
                                case 1: {
                                    break block1;
                                }
                                case 33: {
                                    msg = new RequestKeyMapping();
                                    break block1;
                                }
                                case 51: {
                                    msg = new GotoLobby();
                                    break block1;
                                }
                                case 58: {
                                    break block1;
                                }
                                case 166: {
                                    msg = new RequestEx2ndPasswordCheck();
                                    break block1;
                                }
                                case 167: {
                                    msg = new RequestEx2ndPasswordVerify();
                                    break block1;
                                }
                                case 168: {
                                    msg = new RequestEx2ndPasswordReq();
                                    break block1;
                                }
                                case 169: {
                                    msg = new RequestCharacterNameCreatable();
                                    break block1;
                                }
                                case 209: {
                                    msg = new RequestBR_NewIConCashBtnWnd();
                                    break block1;
                                }
                                case 259: {
                                    break block1;
                                }
                                case 260: {
                                    msg = new ExSendClientINI();
                                    break block1;
                                }
                                case 285: {
                                    msg = new RequestTodoList();
                                    break block1;
                                }
                                case 312: {
                                    msg = new RequestUserBanInfo();
                                    break block1;
                                }
                                case 350: {
                                    break block1;
                                }
                            }
                            client.onUnknownPacket();
                            _log.warn("Unknown client packet! State: AUTHED, packet ID: " + Integer.toHexString(id).toUpperCase() + ":" + Integer.toHexString(id3).toUpperCase());
                            break block1;
                        }
                    }
                    client.onUnknownPacket();
                    _log.warn("Unknown client packet! State: AUTHE, packet ID: " + Integer.toHexString(id).toUpperCase());
                    break;
                }
                case IN_GAME: {
                    switch (id) {
                        case 0: {
                            msg = new Logout();
                            break block1;
                        }
                        case 1: {
                            msg = new AttackRequest();
                            break block1;
                        }
                        case 2: {
                            break block1;
                        }
                        case 3: {
                            msg = new RequestStartPledgeWar();
                            break block1;
                        }
                        case 4: {
                            msg = new RequestReplyStartPledgeWar();
                            break block1;
                        }
                        case 5: {
                            msg = new RequestStopPledgeWar();
                            break block1;
                        }
                        case 6: {
                            msg = new RequestReplyStopPledgeWar();
                            break block1;
                        }
                        case 7: {
                            msg = new RequestSurrenderPledgeWar();
                            break block1;
                        }
                        case 8: {
                            msg = new RequestReplySurrenderPledgeWar();
                            break block1;
                        }
                        case 9: {
                            msg = new RequestSetPledgeCrest();
                            break block1;
                        }
                        case 10: {
                            break block1;
                        }
                        case 11: {
                            msg = new RequestGiveNickName();
                            break block1;
                        }
                        case 12: {
                            break block1;
                        }
                        case 13: {
                            break block1;
                        }
                        case 15: {
                            msg = new MoveBackwardToLocation();
                            break block1;
                        }
                        case 16: {
                            break block1;
                        }
                        case 17: {
                            msg = new EnterWorld();
                            break block1;
                        }
                        case 18: {
                            break block1;
                        }
                        case 20: {
                            msg = new RequestItemList();
                            break block1;
                        }
                        case 21: {
                            msg = new RequestEquipItem();
                            break block1;
                        }
                        case 22: {
                            msg = new RequestUnEquipItem();
                            break block1;
                        }
                        case 23: {
                            msg = new RequestDropItem();
                            break block1;
                        }
                        case 24: {
                            break block1;
                        }
                        case 25: {
                            msg = new UseItem();
                            break block1;
                        }
                        case 26: {
                            msg = new TradeRequest();
                            break block1;
                        }
                        case 27: {
                            msg = new AddTradeItem();
                            break block1;
                        }
                        case 28: {
                            msg = new TradeDone();
                            break block1;
                        }
                        case 29: {
                            break block1;
                        }
                        case 30: {
                            break block1;
                        }
                        case 31: {
                            msg = new Action();
                            break block1;
                        }
                        case 32: {
                            break block1;
                        }
                        case 33: {
                            break block1;
                        }
                        case 34: {
                            msg = new RequestLinkHtml();
                            break block1;
                        }
                        case 35: {
                            msg = new RequestBypassToServer();
                            break block1;
                        }
                        case 36: {
                            msg = new RequestBBSwrite();
                            break block1;
                        }
                        case 37: {
                            msg = new RequestCreatePledge();
                            break block1;
                        }
                        case 38: {
                            msg = new RequestJoinPledge();
                            break block1;
                        }
                        case 39: {
                            msg = new RequestAnswerJoinPledge();
                            break block1;
                        }
                        case 40: {
                            msg = new RequestWithdrawalPledge();
                            break block1;
                        }
                        case 41: {
                            msg = new RequestOustPledgeMember();
                            break block1;
                        }
                        case 42: {
                            break block1;
                        }
                        case 44: {
                            msg = new RequestGetItemFromPet();
                            break block1;
                        }
                        case 45: {
                            break block1;
                        }
                        case 46: {
                            msg = new RequestAllyInfo();
                            break block1;
                        }
                        case 47: {
                            msg = new RequestCrystallizeItem();
                            break block1;
                        }
                        case 48: {
                            break block1;
                        }
                        case 49: {
                            msg = new SetPrivateStoreSellList();
                            break block1;
                        }
                        case 50: {
                            break block1;
                        }
                        case 51: {
                            msg = new RequestTeleport();
                            break block1;
                        }
                        case 52: {
                            break block1;
                        }
                        case 53: {
                            break block1;
                        }
                        case 54: {
                            break block1;
                        }
                        case 55: {
                            msg = new RequestSellItem();
                            break block1;
                        }
                        case 56: {
                            msg = new RequestMagicSkillList();
                            break block1;
                        }
                        case 57: {
                            msg = new RequestMagicSkillUse();
                            break block1;
                        }
                        case 58: {
                            msg = new Appearing();
                            break block1;
                        }
                        case 59: {
                            if (!Config.ALLOW_WAREHOUSE) break block1;
                            msg = new SendWareHouseDepositList();
                            break block1;
                        }
                        case 60: {
                            msg = new SendWareHouseWithDrawList();
                            break block1;
                        }
                        case 61: {
                            msg = new RequestShortCutReg();
                            break block1;
                        }
                        case 62: {
                            break block1;
                        }
                        case 63: {
                            msg = new RequestShortCutDel();
                            break block1;
                        }
                        case 64: {
                            msg = new RequestBuyItem();
                            break block1;
                        }
                        case 65: {
                            break block1;
                        }
                        case 66: {
                            msg = new RequestJoinParty();
                            break block1;
                        }
                        case 67: {
                            msg = new RequestAnswerJoinParty();
                            break block1;
                        }
                        case 68: {
                            msg = new RequestWithDrawalParty();
                            break block1;
                        }
                        case 69: {
                            msg = new RequestOustPartyMember();
                            break block1;
                        }
                        case 70: {
                            msg = new RequestDismissParty();
                            break block1;
                        }
                        case 71: {
                            msg = new CannotMoveAnymore();
                            break block1;
                        }
                        case 72: {
                            msg = new RequestTargetCanceld();
                            break block1;
                        }
                        case 73: {
                            msg = new Say2C();
                            break block1;
                        }
                        case 74: {
                            id2 = buf.get() & 0xFF;
                            switch (id2) {
                                case 0: {
                                    break block1;
                                }
                                case 1: {
                                    break block1;
                                }
                                case 2: {
                                    break block1;
                                }
                                case 3: {
                                    break block1;
                                }
                            }
                            client.onUnknownPacket();
                            _log.warn("Unknown client packet! State: IN_GAME, packet ID: " + Integer.toHexString(id).toUpperCase() + ":" + Integer.toHexString(id2).toUpperCase());
                            break block1;
                        }
                        case 75: {
                            break block1;
                        }
                        case 76: {
                            break block1;
                        }
                        case 77: {
                            msg = new RequestPledgeMemberList();
                            break block1;
                        }
                        case 78: {
                            break block1;
                        }
                        case 79: {
                            break block1;
                        }
                        case 80: {
                            msg = new RequestSkillList();
                            break block1;
                        }
                        case 81: {
                            break block1;
                        }
                        case 82: {
                            msg = new MoveWithDelta();
                            break block1;
                        }
                        case 83: {
                            msg = new RequestGetOnVehicle();
                            break block1;
                        }
                        case 84: {
                            msg = new RequestGetOffVehicle();
                            break block1;
                        }
                        case 85: {
                            msg = new AnswerTradeRequest();
                            break block1;
                        }
                        case 86: {
                            msg = new RequestActionUse();
                            break block1;
                        }
                        case 87: {
                            msg = new RequestRestart();
                            break block1;
                        }
                        case 88: {
                            msg = new RequestSiegeInfo();
                            break block1;
                        }
                        case 89: {
                            msg = new ValidatePosition();
                            break block1;
                        }
                        case 90: {
                            msg = new RequestSEKCustom();
                            break block1;
                        }
                        case 91: {
                            msg = new StartRotatingC();
                            break block1;
                        }
                        case 92: {
                            msg = new FinishRotatingC();
                            break block1;
                        }
                        case 93: {
                            break block1;
                        }
                        case 94: {
                            msg = new RequestShowBoard();
                            break block1;
                        }
                        case 95: {
                            msg = new RequestEnchantItem();
                            break block1;
                        }
                        case 96: {
                            msg = new RequestDestroyItem();
                            break block1;
                        }
                        case 97: {
                            break block1;
                        }
                        case 98: {
                            msg = new RequestQuestList();
                            break block1;
                        }
                        case 99: {
                            msg = new RequestQuestAbort();
                            break block1;
                        }
                        case 100: {
                            break block1;
                        }
                        case 101: {
                            msg = new RequestPledgeInfo();
                            break block1;
                        }
                        case 102: {
                            msg = new RequestPledgeExtendedInfo();
                            break block1;
                        }
                        case 103: {
                            msg = new RequestPledgeCrest();
                            break block1;
                        }
                        case 104: {
                            break block1;
                        }
                        case 105: {
                            break block1;
                        }
                        case 106: {
                            msg = new RequestFriendInfoList();
                            break block1;
                        }
                        case 107: {
                            msg = new RequestSendL2FriendSay();
                            break block1;
                        }
                        case 108: {
                            msg = new RequestShowMiniMap();
                            break block1;
                        }
                        case 109: {
                            msg = new RequestSendMsnChatLog();
                            break block1;
                        }
                        case 110: {
                            msg = new RequestReload();
                            break block1;
                        }
                        case 111: {
                            msg = new RequestHennaEquip();
                            break block1;
                        }
                        case 112: {
                            msg = new RequestHennaUnequipList();
                            break block1;
                        }
                        case 113: {
                            msg = new RequestHennaUnequipInfo();
                            break block1;
                        }
                        case 114: {
                            msg = new RequestHennaUnequip();
                            break block1;
                        }
                        case 115: {
                            msg = new RequestAquireSkillInfo();
                            break block1;
                        }
                        case 116: {
                            msg = new SendBypassBuildCmd();
                            break block1;
                        }
                        case 117: {
                            msg = new RequestMoveToLocationInVehicle();
                            break block1;
                        }
                        case 118: {
                            msg = new CannotMoveAnymore.Vehicle();
                            break block1;
                        }
                        case 119: {
                            msg = new RequestFriendInvite();
                            break block1;
                        }
                        case 120: {
                            msg = new RequestFriendAddReply();
                            break block1;
                        }
                        case 121: {
                            break block1;
                        }
                        case 122: {
                            msg = new RequestFriendDel();
                            break block1;
                        }
                        case 124: {
                            msg = new RequestAquireSkill();
                            break block1;
                        }
                        case 125: {
                            msg = new RequestRestartPoint();
                            break block1;
                        }
                        case 126: {
                            msg = new RequestGMCommand();
                            break block1;
                        }
                        case 127: {
                            msg = new RequestPartyMatchConfig();
                            break block1;
                        }
                        case 128: {
                            msg = new RequestPartyMatchList();
                            break block1;
                        }
                        case 129: {
                            msg = new RequestPartyMatchDetail();
                            break block1;
                        }
                        case 130: {
                            msg = new RequestPrivateStoreList();
                            break block1;
                        }
                        case 131: {
                            msg = new RequestPrivateStoreBuy();
                            break block1;
                        }
                        case 132: {
                            break block1;
                        }
                        case 133: {
                            msg = new RequestTutorialLinkHtml();
                            break block1;
                        }
                        case 134: {
                            msg = new RequestTutorialPassCmdToServer();
                            break block1;
                        }
                        case 135: {
                            msg = new RequestTutorialQuestionMark();
                            break block1;
                        }
                        case 136: {
                            msg = new RequestTutorialClientEvent();
                            break block1;
                        }
                        case 137: {
                            msg = new RequestPetition();
                            break block1;
                        }
                        case 138: {
                            msg = new RequestPetitionCancel();
                            break block1;
                        }
                        case 139: {
                            msg = new RequestGmList();
                            break block1;
                        }
                        case 140: {
                            msg = new RequestJoinAlly();
                            break block1;
                        }
                        case 141: {
                            msg = new RequestAnswerJoinAlly();
                            break block1;
                        }
                        case 142: {
                            msg = new RequestWithdrawAlly();
                            break block1;
                        }
                        case 143: {
                            msg = new RequestOustAlly();
                            break block1;
                        }
                        case 144: {
                            msg = new RequestDismissAlly();
                            break block1;
                        }
                        case 145: {
                            msg = new RequestSetAllyCrest();
                            break block1;
                        }
                        case 146: {
                            msg = new RequestAllyCrest();
                            break block1;
                        }
                        case 147: {
                            msg = new RequestChangePetName();
                            break block1;
                        }
                        case 148: {
                            msg = new RequestPetUseItem();
                            break block1;
                        }
                        case 149: {
                            msg = new RequestGiveItemToPet();
                            break block1;
                        }
                        case 150: {
                            msg = new RequestPrivateStoreQuitSell();
                            break block1;
                        }
                        case 151: {
                            msg = new SetPrivateStoreMsgSell();
                            break block1;
                        }
                        case 152: {
                            msg = new RequestPetGetItem();
                            break block1;
                        }
                        case 153: {
                            msg = new RequestPrivateStoreBuyManage();
                            break block1;
                        }
                        case 154: {
                            msg = new SetPrivateStoreBuyList();
                            break block1;
                        }
                        case 155: {
                            break block1;
                        }
                        case 156: {
                            msg = new RequestPrivateStoreQuitBuy();
                            break block1;
                        }
                        case 157: {
                            msg = new SetPrivateStoreMsgBuy();
                            break block1;
                        }
                        case 158: {
                            break block1;
                        }
                        case 159: {
                            msg = new RequestPrivateStoreBuySellList();
                            break block1;
                        }
                        case 160: {
                            msg = new RequestTimeCheck();
                            break block1;
                        }
                        case 161: {
                            break block1;
                        }
                        case 162: {
                            break block1;
                        }
                        case 163: {
                            break block1;
                        }
                        case 164: {
                            break block1;
                        }
                        case 165: {
                            break block1;
                        }
                        case 166: {
                            msg = new RequestSkillCoolTime();
                            break block1;
                        }
                        case 167: {
                            msg = new RequestPackageSendableItemList();
                            break block1;
                        }
                        case 168: {
                            msg = new RequestPackageSend();
                            break block1;
                        }
                        case 169: {
                            msg = new RequestBlock();
                            break block1;
                        }
                        case 170: {
                            break block1;
                        }
                        case 171: {
                            msg = new RequestCastleSiegeAttackerList();
                            break block1;
                        }
                        case 172: {
                            msg = new RequestCastleSiegeDefenderList();
                            break block1;
                        }
                        case 173: {
                            msg = new RequestJoinCastleSiege();
                            break block1;
                        }
                        case 174: {
                            msg = new RequestConfirmCastleSiegeWaitingList();
                            break block1;
                        }
                        case 175: {
                            msg = new RequestSetCastleSiegeTime();
                            break block1;
                        }
                        case 176: {
                            msg = new RequestMultiSellChoose();
                            break block1;
                        }
                        case 177: {
                            msg = new NetPing();
                            break block1;
                        }
                        case 178: {
                            msg = new RequestRemainTime();
                            break block1;
                        }
                        case 179: {
                            msg = new BypassUserCmd();
                            break block1;
                        }
                        case 180: {
                            msg = new SnoopQuit();
                            break block1;
                        }
                        case 181: {
                            msg = new RequestRecipeBookOpen();
                            break block1;
                        }
                        case 182: {
                            msg = new RequestRecipeItemDelete();
                            break block1;
                        }
                        case 183: {
                            msg = new RequestRecipeItemMakeInfo();
                            break block1;
                        }
                        case 184: {
                            msg = new RequestRecipeItemMakeSelf();
                            break block1;
                        }
                        case 185: {
                            break block1;
                        }
                        case 186: {
                            msg = new RequestRecipeShopMessageSet();
                            break block1;
                        }
                        case 187: {
                            msg = new RequestRecipeShopListSet();
                            break block1;
                        }
                        case 188: {
                            msg = new RequestRecipeShopManageQuit();
                            break block1;
                        }
                        case 189: {
                            msg = new RequestRecipeShopManageCancel();
                            break block1;
                        }
                        case 190: {
                            msg = new RequestRecipeShopMakeInfo();
                            break block1;
                        }
                        case 191: {
                            msg = new RequestRecipeShopMakeDo();
                            break block1;
                        }
                        case 192: {
                            msg = new RequestRecipeShopSellList();
                            break block1;
                        }
                        case 193: {
                            msg = new RequestObserverEnd();
                            break block1;
                        }
                        case 194: {
                            break block1;
                        }
                        case 195: {
                            msg = new RequestHennaList();
                            break block1;
                        }
                        case 196: {
                            msg = new RequestHennaItemInfo();
                            break block1;
                        }
                        case 197: {
                            break block1;
                        }
                        case 198: {
                            msg = new ConfirmDlg();
                            break block1;
                        }
                        case 199: {
                            msg = new RequestPreviewItem();
                            break block1;
                        }
                        case 200: {
                            msg = new RequestSSQStatus();
                            break block1;
                        }
                        case 201: {
                            msg = new PetitionVote();
                            break block1;
                        }
                        case 202: {
                            break block1;
                        }
                        case 203: {
                            msg = new ReplyGameGuardQuery();
                            break block1;
                        }
                        case 204: {
                            msg = new RequestPledgePower();
                            break block1;
                        }
                        case 205: {
                            msg = new RequestMakeMacro();
                            break block1;
                        }
                        case 206: {
                            msg = new RequestDeleteMacro();
                            break block1;
                        }
                        case 207: {
                            break block1;
                        }
                        case 208: {
                            int id3 = buf.getShort() & 0xFFFF;
                            switch (id3) {
                                case 0: {
                                    break block1;
                                }
                                case 1: {
                                    break block1;
                                }
                                case 2: {
                                    break block1;
                                }
                                case 3: {
                                    break block1;
                                }
                                case 4: {
                                    break block1;
                                }
                                case 5: {
                                    msg = new RequestWriteHeroWords();
                                    break block1;
                                }
                                case 6: {
                                    msg = new RequestExMPCCAskJoin();
                                    break block1;
                                }
                                case 7: {
                                    msg = new RequestExMPCCAcceptJoin();
                                    break block1;
                                }
                                case 8: {
                                    msg = new RequestExOustFromMPCC();
                                    break block1;
                                }
                                case 9: {
                                    msg = new RequestOustFromPartyRoom();
                                    break block1;
                                }
                                case 10: {
                                    msg = new RequestDismissPartyRoom();
                                    break block1;
                                }
                                case 11: {
                                    msg = new RequestWithdrawPartyRoom();
                                    break block1;
                                }
                                case 12: {
                                    msg = new RequestHandOverPartyMaster();
                                    break block1;
                                }
                                case 13: {
                                    msg = new RequestAutoSoulShot();
                                    break block1;
                                }
                                case 14: {
                                    break block1;
                                }
                                case 15: {
                                    int type = buf.getInt();
                                    switch (type) {
                                        case 0: {
                                            break block1;
                                        }
                                        case 1: {
                                            break block1;
                                        }
                                        case 2: {
                                            break block1;
                                        }
                                        case 3: {
                                            break block1;
                                        }
                                        case 4: {
                                            break block1;
                                        }
                                    }
                                    client.onUnknownPacket();
                                    _log.warn("Unknown client packet! State: IN_GAME, packet ID: " + Integer.toHexString(id).toUpperCase() + ":" + Integer.toHexString(id3).toUpperCase() + ":" + Integer.toHexString(type).toUpperCase());
                                    break block1;
                                }
                                case 16: {
                                    msg = new RequestPledgeCrestLarge();
                                    break block1;
                                }
                                case 17: {
                                    msg = new RequestExSetPledgeCrestLargeFirstPart();
                                    break block1;
                                }
                                case 18: {
                                    msg = new RequestPledgeSetAcademyMaster();
                                    break block1;
                                }
                                case 19: {
                                    msg = new RequestPledgePowerGradeList();
                                    break block1;
                                }
                                case 20: {
                                    msg = new RequestPledgeMemberPowerInfo();
                                    break block1;
                                }
                                case 21: {
                                    msg = new RequestPledgeSetMemberPowerGrade();
                                    break block1;
                                }
                                case 22: {
                                    msg = new RequestPledgeMemberInfo();
                                    break block1;
                                }
                                case 23: {
                                    msg = new RequestPledgeWarList();
                                    break block1;
                                }
                                case 24: {
                                    break block1;
                                }
                                case 25: {
                                    msg = new RequestPCCafeCouponUse();
                                    break block1;
                                }
                                case 26: {
                                    break block1;
                                }
                                case 27: {
                                    msg = new RequestDuelStart();
                                    break block1;
                                }
                                case 28: {
                                    msg = new RequestDuelAnswerStart();
                                    break block1;
                                }
                                case 29: {
                                    msg = new RequestTutorialClientEvent();
                                    break block1;
                                }
                                case 30: {
                                    msg = new RequestExRqItemLink();
                                    break block1;
                                }
                                case 31: {
                                    msg = new CannotMoveAnymore.AirShip();
                                    break block1;
                                }
                                case 32: {
                                    break block1;
                                }
                                case 33: {
                                    msg = new RequestKeyMapping();
                                    break block1;
                                }
                                case 34: {
                                    msg = new RequestSaveKeyMapping();
                                    break block1;
                                }
                                case 35: {
                                    msg = new RequestExRemoveItemAttribute();
                                    break block1;
                                }
                                case 36: {
                                    msg = new RequestSaveInventoryOrder();
                                    break block1;
                                }
                                case 37: {
                                    msg = new RequestExitPartyMatchingWaitingRoom();
                                    break block1;
                                }
                                case 38: {
                                    msg = new RequestConfirmTargetItem();
                                    break block1;
                                }
                                case 39: {
                                    msg = new RequestConfirmRefinerItem();
                                    break block1;
                                }
                                case 40: {
                                    msg = new RequestConfirmGemStone();
                                    break block1;
                                }
                                case 41: {
                                    msg = new RequestOlympiadObserverEnd();
                                    break block1;
                                }
                                case 42: {
                                    break block1;
                                }
                                case 43: {
                                    break block1;
                                }
                                case 44: {
                                    msg = new RequestPledgeReorganizeMember();
                                    break block1;
                                }
                                case 45: {
                                    msg = new RequestExMPCCShowPartyMembersInfo();
                                    break block1;
                                }
                                case 46: {
                                    msg = new RequestExOlympiadObserverEnd();
                                    break block1;
                                }
                                case 47: {
                                    msg = new RequestAskJoinPartyRoom();
                                    break block1;
                                }
                                case 48: {
                                    msg = new AnswerJoinPartyRoom();
                                    break block1;
                                }
                                case 49: {
                                    msg = new RequestListPartyMatchingWaitingRoom();
                                    break block1;
                                }
                                case 50: {
                                    break block1;
                                }
                                case 51: {
                                    break block1;
                                }
                                case 53: {
                                    break block1;
                                }
                                case 54: {
                                    break block1;
                                }
                                case 55: {
                                    break block1;
                                }
                                case 56: {
                                    msg = new RequestExChangeName();
                                    break block1;
                                }
                                case 57: {
                                    msg = new RequestAllCastleInfo();
                                    break block1;
                                }
                                case 58: {
                                    break block1;
                                }
                                case 59: {
                                    msg = new RequestAllAgitInfo();
                                    break block1;
                                }
                                case 60: {
                                    break block1;
                                }
                                case 61: {
                                    break block1;
                                }
                                case 62: {
                                    msg = new RequestRefine();
                                    break block1;
                                }
                                case 63: {
                                    msg = new RequestConfirmCancelItem();
                                    break block1;
                                }
                                case 64: {
                                    msg = new RequestRefineCancel();
                                    break block1;
                                }
                                case 65: {
                                    msg = new RequestExMagicSkillUseGround();
                                    break block1;
                                }
                                case 66: {
                                    msg = new RequestDuelSurrender();
                                    break block1;
                                }
                                case 67: {
                                    break block1;
                                }
                                case 69: {
                                    break block1;
                                }
                                case 70: {
                                    msg = new RequestPVPMatchRecord();
                                    break block1;
                                }
                                case 71: {
                                    msg = new SetPrivateStoreWholeMsg();
                                    break block1;
                                }
                                case 72: {
                                    msg = new RequestDispel();
                                    break block1;
                                }
                                case 73: {
                                    msg = new RequestExTryToPutEnchantTargetItem();
                                    break block1;
                                }
                                case 74: {
                                    msg = new RequestExTryToPutEnchantSupportItem();
                                    break block1;
                                }
                                case 75: {
                                    msg = new RequestExCancelEnchantItem();
                                    break block1;
                                }
                                case 76: {
                                    msg = new RequestChangeNicknameColor();
                                    break block1;
                                }
                                case 77: {
                                    msg = new RequestResetNickname();
                                    break block1;
                                }
                                case 78: {
                                    int id4 = buf.getInt();
                                    switch (id4) {
                                        case 0: {
                                            msg = new RequestBookMarkSlotInfo();
                                            break block1;
                                        }
                                        case 1: {
                                            msg = new RequestSaveBookMarkSlot();
                                            break block1;
                                        }
                                        case 2: {
                                            msg = new RequestModifyBookMarkSlot();
                                            break block1;
                                        }
                                        case 3: {
                                            msg = new RequestDeleteBookMarkSlot();
                                            break block1;
                                        }
                                        case 4: {
                                            msg = new RequestTeleportBookMark();
                                            break block1;
                                        }
                                        case 5: {
                                            msg = new RequestChangeBookMarkSlot();
                                            break block1;
                                        }
                                    }
                                    client.onUnknownPacket();
                                    _log.warn("Unknown client packet! State: IN_GAME, packet ID: " + Integer.toHexString(id).toUpperCase() + ":" + Integer.toHexString(id3).toUpperCase() + ":" + Integer.toHexString(id4).toUpperCase());
                                    break block1;
                                }
                                case 79: {
                                    break block1;
                                }
                                case 80: {
                                    msg = new RequestExJump();
                                    break block1;
                                }
                                case 81: {
                                    break block1;
                                }
                                case 82: {
                                    break block1;
                                }
                                case 83: {
                                    msg = new NotifyStartMiniGame();
                                    break block1;
                                }
                                case 84: {
                                    msg = new RequestExJoinDominionWar();
                                    break block1;
                                }
                                case 85: {
                                    msg = new RequestExDominionInfo();
                                    break block1;
                                }
                                case 86: {
                                    msg = new RequestExCleftEnter();
                                    break block1;
                                }
                                case 87: {
                                    break block1;
                                }
                                case 88: {
                                    msg = new RequestExEndScenePlayer();
                                    break block1;
                                }
                                case 89: {
                                    break block1;
                                }
                                case 90: {
                                    msg = new RequestExListMpccWaiting();
                                    break block1;
                                }
                                case 91: {
                                    msg = new RequestExManageMpccRoom();
                                    break block1;
                                }
                                case 92: {
                                    msg = new RequestExJoinMpccRoom();
                                    break block1;
                                }
                                case 93: {
                                    msg = new RequestExOustFromMpccRoom();
                                    break block1;
                                }
                                case 94: {
                                    msg = new RequestExDismissMpccRoom();
                                    break block1;
                                }
                                case 95: {
                                    msg = new RequestExWithdrawMpccRoom();
                                    break block1;
                                }
                                case 96: {
                                    break block1;
                                }
                                case 97: {
                                    msg = new RequestExMpccPartymasterList();
                                    break block1;
                                }
                                case 98: {
                                    msg = new RequestExPostItemList();
                                    break block1;
                                }
                                case 99: {
                                    msg = new RequestExSendPost();
                                    break block1;
                                }
                                case 100: {
                                    msg = new RequestExRequestReceivedPostList();
                                    break block1;
                                }
                                case 101: {
                                    msg = new RequestExDeleteReceivedPost();
                                    break block1;
                                }
                                case 102: {
                                    msg = new RequestExRequestReceivedPost();
                                    break block1;
                                }
                                case 103: {
                                    msg = new RequestExReceivePost();
                                    break block1;
                                }
                                case 104: {
                                    msg = new RequestExRejectPost();
                                    break block1;
                                }
                                case 105: {
                                    msg = new RequestExRequestSentPostList();
                                    break block1;
                                }
                                case 106: {
                                    msg = new RequestExDeleteSentPost();
                                    break block1;
                                }
                                case 107: {
                                    msg = new RequestExRequestSentPost();
                                    break block1;
                                }
                                case 108: {
                                    msg = new RequestExCancelSentPost();
                                    break block1;
                                }
                                case 109: {
                                    msg = new RequestExShowNewUserPetition();
                                    break block1;
                                }
                                case 110: {
                                    msg = new RequestExShowStepTwo();
                                    break block1;
                                }
                                case 111: {
                                    msg = new RequestExShowStepThree();
                                    break block1;
                                }
                                case 112: {
                                    break block1;
                                }
                                case 113: {
                                    break block1;
                                }
                                case 114: {
                                    msg = new RequestExRefundItem();
                                    break block1;
                                }
                                case 115: {
                                    msg = new RequestExBuySellUIClose();
                                    break block1;
                                }
                                case 116: {
                                    msg = new RequestExEventMatchObserverEnd();
                                    break block1;
                                }
                                case 117: {
                                    msg = new RequestPartyLootModification();
                                    break block1;
                                }
                                case 118: {
                                    msg = new AnswerPartyLootModification();
                                    break block1;
                                }
                                case 119: {
                                    msg = new AnswerCoupleAction();
                                    break block1;
                                }
                                case 120: {
                                    msg = new RequestExBR_EventRankerList();
                                    break block1;
                                }
                                case 121: {
                                    break block1;
                                }
                                case 122: {
                                    msg = new RequestAddExpandQuestAlarm();
                                    break block1;
                                }
                                case 123: {
                                    msg = new RequestVoteNew();
                                    break block1;
                                }
                                case 124: {
                                    msg = new RequestGetOnShuttle();
                                    break block1;
                                }
                                case 125: {
                                    msg = new RequestGetOffShuttle();
                                    break block1;
                                }
                                case 126: {
                                    msg = new RequestMoveToLocationInShuttle();
                                    break block1;
                                }
                                case 127: {
                                    msg = new CannotMoveAnymore.Shuttle();
                                    break block1;
                                }
                                case 128: {
                                    int id5 = buf.getInt();
                                    switch (id5) {
                                        case 1: {
                                            break block1;
                                        }
                                        case 2: {
                                            break block1;
                                        }
                                        case 3: {
                                            break block1;
                                        }
                                        case 4: {
                                            break block1;
                                        }
                                        case 5: {
                                            break block1;
                                        }
                                        case 7: {
                                            break block1;
                                        }
                                        case 8: {
                                            break block1;
                                        }
                                        case 9: {
                                            break block1;
                                        }
                                        case 16: {
                                            break block1;
                                        }
                                        case 17: {
                                            break block1;
                                        }
                                        case 18: {
                                            break block1;
                                        }
                                        case 19: {
                                            break block1;
                                        }
                                        case 20: {
                                            break block1;
                                        }
                                        case 13: {
                                            break block1;
                                        }
                                        case 14: {
                                            break block1;
                                        }
                                        case 15: {
                                            break block1;
                                        }
                                        case 10: {
                                            break block1;
                                        }
                                    }
                                    client.onUnknownPacket();
                                    _log.warn("Unknown client packet! State: IN_GAME, packet ID: " + Integer.toHexString(id).toUpperCase() + ":" + Integer.toHexString(id3).toUpperCase() + ":" + Integer.toHexString(id5).toUpperCase());
                                    break block1;
                                }
                                case 129: {
                                    msg = new RequestExAddPostFriendForPostBox();
                                    break block1;
                                }
                                case 130: {
                                    msg = new RequestExDeletePostFriendForPostBox();
                                    break block1;
                                }
                                case 131: {
                                    msg = new RequestExShowPostFriendListForPostBox();
                                    break block1;
                                }
                                case 132: {
                                    msg = new RequestExFriendListForPostBox();
                                    break block1;
                                }
                                case 133: {
                                    msg = new RequestOlympiadMatchList();
                                    break block1;
                                }
                                case 134: {
                                    msg = new RequestExBR_GamePoint();
                                    break block1;
                                }
                                case 135: {
                                    break block1;
                                }
                                case 136: {
                                    break block1;
                                }
                                case 137: {
                                    msg = new RequestExBR_BuyProduct();
                                    break block1;
                                }
                                case 138: {
                                    break block1;
                                }
                                case 139: {
                                    msg = new RequestBR_MiniGameLoadScores();
                                    break block1;
                                }
                                case 140: {
                                    msg = new RequestBR_MiniGameInsertScore();
                                    break block1;
                                }
                                case 141: {
                                    msg = new RequestExBR_LectureMark();
                                    break block1;
                                }
                                case 142: {
                                    msg = new RequestCrystallizeEstimate();
                                    break block1;
                                }
                                case 143: {
                                    msg = new RequestCrystallizeItemCancel();
                                    break block1;
                                }
                                case 144: {
                                    msg = new RequestExEscapeScene();
                                    break block1;
                                }
                                case 145: {
                                    break block1;
                                }
                                case 146: {
                                    break block1;
                                }
                                case 147: {
                                    byte id6 = buf.get();
                                    switch (id6) {
                                        case 2: {
                                            break block1;
                                        }
                                        case 3: {
                                            break block1;
                                        }
                                        case 4: {
                                            break block1;
                                        }
                                    }
                                    client.onUnknownPacket();
                                    _log.warn("Unknown client packet! State: IN_GAME, packet ID: " + Integer.toHexString(id).toUpperCase() + ":" + Integer.toHexString(id3).toUpperCase() + ":" + Integer.toHexString(id6).toUpperCase());
                                    break block1;
                                }
                                case 148: {
                                    msg = new RequestFriendDetailInfo();
                                    break block1;
                                }
                                case 149: {
                                    msg = new RequestUpdateFriendMemo();
                                    break block1;
                                }
                                case 150: {
                                    msg = new RequestUpdateBlockMemo();
                                    break block1;
                                }
                                case 151: {
                                    break block1;
                                }
                                case 152: {
                                    break block1;
                                }
                                case 153: {
                                    break block1;
                                }
                                case 154: {
                                    break block1;
                                }
                                case 155: {
                                    break block1;
                                }
                                case 156: {
                                    break block1;
                                }
                                case 157: {
                                    break block1;
                                }
                                case 158: {
                                    break block1;
                                }
                                case 159: {
                                    break block1;
                                }
                                case 160: {
                                    break block1;
                                }
                                case 161: {
                                    break block1;
                                }
                                case 162: {
                                    break block1;
                                }
                                case 163: {
                                    break block1;
                                }
                                case 164: {
                                    break block1;
                                }
                                case 165: {
                                    msg = new RequestRegistPartySubstitute();
                                    break block1;
                                }
                                case 166: {
                                    msg = new RequestDeletePartySubstitute();
                                    break block1;
                                }
                                case 167: {
                                    msg = new RequestRegistWaitingSubstitute();
                                    break block1;
                                }
                                case 168: {
                                    msg = new RequestAcceptWaitingSubstitute();
                                    break block1;
                                }
                                case 169: {
                                    break block1;
                                }
                                case 170: {
                                    msg = new RequestGoodsInventoryInfo();
                                    break block1;
                                }
                                case 171: {
                                    int id7 = buf.getInt();
                                    switch (id7) {
                                        case 0: {
                                            break block1;
                                        }
                                        case 1: {
                                            break block1;
                                        }
                                    }
                                    client.onUnknownPacket();
                                    _log.warn("Unknown client packet! State: IN_GAME, packet ID: " + Integer.toHexString(id).toUpperCase() + ":" + Integer.toHexString(id7).toUpperCase());
                                    break block1;
                                }
                                case 172: {
                                    msg = new RequestFirstPlayStart();
                                    break block1;
                                }
                                case 173: {
                                    break block1;
                                }
                                case 174: {
                                    msg = new RequestHardWareInfo();
                                    break block1;
                                }
                                case 176: {
                                    msg = new SendChangeAttributeTargetItem();
                                    break block1;
                                }
                                case 177: {
                                    msg = new RequestChangeAttributeItem();
                                    break block1;
                                }
                                case 178: {
                                    msg = new RequestChangeAttributeCancel();
                                    break block1;
                                }
                                case 179: {
                                    break block1;
                                }
                                case 180: {
                                    break block1;
                                }
                                case 181: {
                                    break block1;
                                }
                                case 182: {
                                    break block1;
                                }
                                case 183: {
                                    break block1;
                                }
                                case 184: {
                                    break block1;
                                }
                                case 185: {
                                    msg = new RequestJoinPledgeByName();
                                    break block1;
                                }
                                case 186: {
                                    msg = new RequestInzoneWaitingTime();
                                    break block1;
                                }
                                case 187: {
                                    break block1;
                                }
                                case 188: {
                                    break block1;
                                }
                                case 189: {
                                    break block1;
                                }
                                case 190: {
                                    break block1;
                                }
                                case 191: {
                                    break block1;
                                }
                                case 192: {
                                    break block1;
                                }
                                case 193: {
                                    break block1;
                                }
                                case 194: {
                                    break block1;
                                }
                                case 195: {
                                    break block1;
                                }
                                case 196: {
                                    msg = new RequestExTryToPutShapeShiftingTargetItem();
                                    break block1;
                                }
                                case 197: {
                                    msg = new RequestExTryToPutShapeShiftingEnchantSupportItem();
                                    break block1;
                                }
                                case 198: {
                                    msg = new RequestExCancelShapeShiftingItem();
                                    break block1;
                                }
                                case 199: {
                                    msg = new RequestShapeShiftingItem();
                                    break block1;
                                }
                                case 200: {
                                    break block1;
                                }
                                case 201: {
                                    break block1;
                                }
                                case 202: {
                                    break block1;
                                }
                                case 203: {
                                    break block1;
                                }
                                case 204: {
                                    break block1;
                                }
                                case 205: {
                                    break block1;
                                }
                                case 206: {
                                    break block1;
                                }
                                case 207: {
                                    break block1;
                                }
                                case 208: {
                                    break block1;
                                }
                                case 209: {
                                    msg = new RequestBR_NewIConCashBtnWnd();
                                    break block1;
                                }
                                case 210: {
                                    break block1;
                                }
                                case 211: {
                                    msg = new RequestPledgeRecruitInfo();
                                    break block1;
                                }
                                case 212: {
                                    msg = new RequestPledgeRecruitBoardSearch();
                                    break block1;
                                }
                                case 213: {
                                    msg = new RequestPledgeRecruitBoardAccess();
                                    break block1;
                                }
                                case 214: {
                                    msg = new RequestPledgeRecruitBoardDetail();
                                    break block1;
                                }
                                case 215: {
                                    msg = new RequestPledgeWaitingApply();
                                    break block1;
                                }
                                case 216: {
                                    msg = new RequestPledgeWaitingApplied();
                                    break block1;
                                }
                                case 217: {
                                    msg = new RequestPledgeWaitingList();
                                    break block1;
                                }
                                case 218: {
                                    msg = new RequestPledgeWaitingUser();
                                    break block1;
                                }
                                case 219: {
                                    msg = new RequestPledgeWaitingUserAccept();
                                    break block1;
                                }
                                case 220: {
                                    msg = new RequestPledgeDraftListSearch();
                                    break block1;
                                }
                                case 221: {
                                    msg = new RequestPledgeDraftListApply();
                                    break block1;
                                }
                                case 222: {
                                    msg = new RequestPledgeRecruitApplyInfo();
                                    break block1;
                                }
                                case 223: {
                                    msg = new RequestPledgeJoinSys();
                                    break block1;
                                }
                                case 224: {
                                    break block1;
                                }
                                case 225: {
                                    msg = new NotifyExitBeautyshop();
                                    break block1;
                                }
                                case 226: {
                                    break block1;
                                }
                                case 227: {
                                    msg = new RequestExAddEnchantScrollItem();
                                    break block1;
                                }
                                case 228: {
                                    msg = new RequestExRemoveEnchantSupportItem();
                                    break block1;
                                }
                                case 229: {
                                    break block1;
                                }
                                case 230: {
                                    msg = new RequestDivideAdenaStart();
                                    break block1;
                                }
                                case 231: {
                                    msg = new RequestDivideAdenaCancel();
                                    break block1;
                                }
                                case 232: {
                                    msg = new RequestDivideAdena();
                                    break block1;
                                }
                                case 233: {
                                    break block1;
                                }
                                case 234: {
                                    break block1;
                                }
                                case 235: {
                                    break block1;
                                }
                                case 236: {
                                    break block1;
                                }
                                case 237: {
                                    msg = new RequestStopMove();
                                    break block1;
                                }
                                case 238: {
                                    break block1;
                                }
                                case 239: {
                                    break block1;
                                }
                                case 240: {
                                    msg = new ExPCCafeRequestOpenWindowWithoutNPC();
                                    break block1;
                                }
                                case 241: {
                                    msg = new RequestLuckyGameStartInfo();
                                    break block1;
                                }
                                case 242: {
                                    msg = new RequestLuckyGamePlay();
                                    break block1;
                                }
                                case 243: {
                                    msg = new NotifyTrainingRoomEnd();
                                    break block1;
                                }
                                case 244: {
                                    msg = new RequestNewEnchantPushOne();
                                    break block1;
                                }
                                case 245: {
                                    msg = new RequestNewEnchantRemoveOne();
                                    break block1;
                                }
                                case 246: {
                                    msg = new RequestNewEnchantPushTwo();
                                    break block1;
                                }
                                case 247: {
                                    msg = new RequestNewEnchantRemoveTwo();
                                    break block1;
                                }
                                case 248: {
                                    msg = new RequestNewEnchantClose();
                                    break block1;
                                }
                                case 249: {
                                    msg = new RequestNewEnchantTry();
                                    break block1;
                                }
                                case 250: {
                                    break block1;
                                }
                                case 251: {
                                    break block1;
                                }
                                case 252: {
                                    break block1;
                                }
                                case 253: {
                                    break block1;
                                }
                                case 254: {
                                    msg = new RequestTargetActionMenu();
                                    break block1;
                                }
                                case 255: {
                                    msg = new ExSendSelectedQuestZoneID();
                                    break block1;
                                }
                                case 256: {
                                    break block1;
                                }
                                case 257: {
                                    break block1;
                                }
                                case 258: {
                                    break block1;
                                }
                                case 259: {
                                    break block1;
                                }
                                case 260: {
                                    msg = new ExSendClientINI();
                                    break block1;
                                }
                                case 261: {
                                    msg = new RequestExAutoFish();
                                    break block1;
                                }
                                case 262: {
                                    msg = new RequestVipAttendanceItemList();
                                    break block1;
                                }
                                case 263: {
                                    msg = new RequestVipAttendanceCheck();
                                    break block1;
                                }
                                case 264: {
                                    msg = new RequestItemEnsoul();
                                    break block1;
                                }
                                case 265: {
                                    break block1;
                                }
                                case 266: {
                                    msg = new RequestVipProductList();
                                    break block1;
                                }
                                case 267: {
                                    msg = new RequestVipLuckyGameInfo();
                                    break block1;
                                }
                                case 268: {
                                    msg = new RequestVipLuckyGameItemList();
                                    break block1;
                                }
                                case 269: {
                                    msg = new RequestVipLuckyGameBonus();
                                    break block1;
                                }
                                case 270: {
                                    msg = new ExRequestVipInfo();
                                    break block1;
                                }
                                case 271: {
                                    break block1;
                                }
                                case 272: {
                                    break block1;
                                }
                                case 273: {
                                    msg = new RequestPledgeSignInForOpenJoiningMethod();
                                    break block1;
                                }
                                case 274: {
                                    break block1;
                                }
                                case 275: {
                                    break block1;
                                }
                                case 276: {
                                    break block1;
                                }
                                case 277: {
                                    break block1;
                                }
                                case 278: {
                                    break block1;
                                }
                                case 279: {
                                    break block1;
                                }
                                case 280: {
                                    break block1;
                                }
                                case 281: {
                                    break block1;
                                }
                                case 282: {
                                    break block1;
                                }
                                case 283: {
                                    break block1;
                                }
                                case 284: {
                                    msg = new RequestPartyMatchingHistory();
                                    break block1;
                                }
                                case 285: {
                                    break block1;
                                }
                                case 286: {
                                    msg = new RequestTodoList();
                                    break block1;
                                }
                                case 287: {
                                    msg = new RequestTodoListHTML();
                                    break block1;
                                }
                                case 288: {
                                    msg = new RequestOneDayRewardReceive();
                                    break block1;
                                }
                                case 289: {
                                    break block1;
                                }
                                case 290: {
                                    msg = new RequestPledgeBonusOpen();
                                    break block1;
                                }
                                case 291: {
                                    msg = new RequestPledgeBonusRewardList();
                                    break block1;
                                }
                                case 292: {
                                    msg = new RequestPledgeBonusReward();
                                    break block1;
                                }
                                case 293: {
                                    break block1;
                                }
                                case 294: {
                                    break block1;
                                }
                                case 295: {
                                    msg = new RequestBlockMemoInfo();
                                    break block1;
                                }
                                case 296: {
                                    msg = new RequestTryEnSoulExtraction();
                                    break block1;
                                }
                                case 297: {
                                    msg = new RequestRaidBossSpawnInfo();
                                    break block1;
                                }
                                case 298: {
                                    msg = new RequestRaidServerInfo();
                                    break block1;
                                }
                                case 299: {
                                    msg = new RequestShowAgitSiegeInfo();
                                    break block1;
                                }
                                case 300: {
                                    msg = new RequestItemAuctionStatus();
                                    break block1;
                                }
                                case 301: {
                                    break block1;
                                }
                                case 302: {
                                    break block1;
                                }
                                case 303: {
                                    break block1;
                                }
                                case 304: {
                                    break block1;
                                }
                                case 305: {
                                    break block1;
                                }
                                case 306: {
                                    break block1;
                                }
                                case 307: {
                                    break block1;
                                }
                                case 308: {
                                    break block1;
                                }
                                case 309: {
                                    break block1;
                                }
                                case 310: {
                                    break block1;
                                }
                                case 311: {
                                    break block1;
                                }
                                case 312: {
                                    break block1;
                                }
                                case 313: {
                                    break block1;
                                }
                                case 314: {
                                    break block1;
                                }
                                case 315: {
                                    break block1;
                                }
                                case 316: {
                                    break block1;
                                }
                                case 317: {
                                    msg = new RequestSwapAgathionSlotItems();
                                    break block1;
                                }
                                case 318: {
                                    break block1;
                                }
                                case 319: {
                                    break block1;
                                }
                                case 320: {
                                    break block1;
                                }
                                case 321: {
                                    break block1;
                                }
                                case 322: {
                                    break block1;
                                }
                                case 323: {
                                    break block1;
                                }
                                case 324: {
                                    break block1;
                                }
                                case 325: {
                                    break block1;
                                }
                                case 326: {
                                    break block1;
                                }
                                case 327: {
                                    break block1;
                                }
                                case 328: {
                                    break block1;
                                }
                                case 329: {
                                    break block1;
                                }
                                case 330: {
                                    break block1;
                                }
                                case 331: {
                                    break block1;
                                }
                                case 332: {
                                    break block1;
                                }
                                case 333: {
                                    break block1;
                                }
                                case 334: {
                                    break block1;
                                }
                                case 335: {
                                    break block1;
                                }
                                case 336: {
                                    break block1;
                                }
                                case 337: {
                                    break block1;
                                }
                                case 338: {
                                    break block1;
                                }
                                case 339: {
                                    break block1;
                                }
                                case 340: {
                                    break block1;
                                }
                                case 341: {
                                    break block1;
                                }
                                case 342: {
                                    break block1;
                                }
                                case 343: {
                                    break block1;
                                }
                                case 344: {
                                    break block1;
                                }
                                case 345: {
                                    break block1;
                                }
                                case 346: {
                                    break block1;
                                }
                                case 347: {
                                    break block1;
                                }
                                case 348: {
                                    break block1;
                                }
                                case 349: {
                                    break block1;
                                }
                                case 350: {
                                    break block1;
                                }
                            }
                            client.onUnknownPacket();
                            _log.warn("Unknown client packet! State: IN_GAME, packet ID: " + Integer.toHexString(id).toUpperCase() + ":" + Integer.toHexString(id3).toUpperCase());
                            break block1;
                        }
                    }
                    client.onUnknownPacket();
                }
            }
        }
        catch (BufferUnderflowException e) {
            client.onPacketReadFail();
        }
        return msg;
    }

    public GameClient create(MMOConnection<GameClient> con) {
        return new GameClient(con);
    }

    public void execute(Runnable r) {
        ThreadPoolManager.getInstance().execute(r);
    }
}

