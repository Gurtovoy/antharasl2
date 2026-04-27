/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.napile.primitive.pair.IntObjectPair
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.network.l2.c2s;

import java.util.Iterator;
import java.util.List;
import l2s.gameserver.Announcements;
import l2s.gameserver.Config;
import l2s.gameserver.dao.MailDAO;
import l2s.gameserver.data.htm.HtmCache;
import l2s.gameserver.data.xml.holder.ResidenceHolder;
import l2s.gameserver.instancemanager.CoupleManager;
import l2s.gameserver.instancemanager.OfflineBufferManager;
import l2s.gameserver.instancemanager.PetitionManager;
import l2s.gameserver.instancemanager.PlayerMessageStack;
import l2s.gameserver.listener.actor.player.OnAnswerListener;
import l2s.gameserver.listener.actor.player.impl.ReviveAnswerListener;
import l2s.gameserver.listener.hooks.ListenerHook;
import l2s.gameserver.listener.hooks.ListenerHookType;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Party;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.World;
import l2s.gameserver.model.actor.CreatureSkillCast;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.model.entity.residence.Castle;
import l2s.gameserver.model.mail.Mail;
import l2s.gameserver.network.authcomm.AuthServerCommunication;
import l2s.gameserver.network.authcomm.gs2as.ChangeAllowedHwid;
import l2s.gameserver.network.authcomm.gs2as.ChangeAllowedIp;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.HtmlMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ChangeWaitTypePacket;
import l2s.gameserver.network.l2.s2c.ConfirmDlgPacket;
import l2s.gameserver.network.l2.s2c.DiePacket;
import l2s.gameserver.network.l2.s2c.EtcStatusUpdatePacket;
import l2s.gameserver.network.l2.s2c.ExAdenaInvenCount;
import l2s.gameserver.network.l2.s2c.ExBR_NewIConCashBtnWnd;
import l2s.gameserver.network.l2.s2c.ExBR_PremiumStatePacket;
import l2s.gameserver.network.l2.s2c.ExBasicActionList;
import l2s.gameserver.network.l2.s2c.ExCastleState;
import l2s.gameserver.network.l2.s2c.ExChangeMPCost;
import l2s.gameserver.network.l2.s2c.ExConnectedTimeAndGettableReward;
import l2s.gameserver.network.l2.s2c.ExEnterWorldPacket;
import l2s.gameserver.network.l2.s2c.ExGetBookMarkInfoPacket;
import l2s.gameserver.network.l2.s2c.ExLightingCandleEvent;
import l2s.gameserver.network.l2.s2c.ExNoticePostArrived;
import l2s.gameserver.network.l2.s2c.ExOpenMPCCPacket;
import l2s.gameserver.network.l2.s2c.ExPCCafePointInfoPacket;
import l2s.gameserver.network.l2.s2c.ExPeriodicHenna;
import l2s.gameserver.network.l2.s2c.ExPledgeCount;
import l2s.gameserver.network.l2.s2c.ExReceiveShowPostFriend;
import l2s.gameserver.network.l2.s2c.ExSetCompassZoneCode;
import l2s.gameserver.network.l2.s2c.ExStorageMaxCountPacket;
import l2s.gameserver.network.l2.s2c.ExUnReadMailCount;
import l2s.gameserver.network.l2.s2c.ExUserInfoAbnormalVisualEffect;
import l2s.gameserver.network.l2.s2c.ExUserInfoCubic;
import l2s.gameserver.network.l2.s2c.ExUserInfoEquipSlot;
import l2s.gameserver.network.l2.s2c.ExUserInfoInvenWeight;
import l2s.gameserver.network.l2.s2c.ExWorldChatCnt;
import l2s.gameserver.network.l2.s2c.HennaInfoPacket;
import l2s.gameserver.network.l2.s2c.MagicAndSkillList;
import l2s.gameserver.network.l2.s2c.MagicSkillLaunchedPacket;
import l2s.gameserver.network.l2.s2c.MagicSkillUse;
import l2s.gameserver.network.l2.s2c.MyPetSummonInfoPacket;
import l2s.gameserver.network.l2.s2c.PartySmallWindowAllPacket;
import l2s.gameserver.network.l2.s2c.PartySpelledPacket;
import l2s.gameserver.network.l2.s2c.PledgeSkillListPacket;
import l2s.gameserver.network.l2.s2c.QuestListPacket;
import l2s.gameserver.network.l2.s2c.ReciveVipInfo;
import l2s.gameserver.network.l2.s2c.RelationChangedPacket;
import l2s.gameserver.network.l2.s2c.RidePacket;
import l2s.gameserver.network.l2.s2c.ShortCutInitPacket;
import l2s.gameserver.network.l2.s2c.UIPacket;
import l2s.gameserver.network.l2.s2c.updatetype.IUpdateTypeComponent;
import l2s.gameserver.network.l2.s2c.updatetype.NpcInfoType;
import l2s.gameserver.skills.AbnormalEffect;
import l2s.gameserver.skills.SkillCastingType;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.stats.triggers.TriggerType;
import l2s.gameserver.utils.GameStats;
import l2s.gameserver.utils.HtmlUtils;
import l2s.gameserver.utils.TradeHelper;
import org.napile.primitive.pair.IntObjectPair;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class EnterWorld
extends L2GameClientPacket {
    private static final Object _lock = new Object();
    private static final Logger _log = LoggerFactory.getLogger(EnterWorld.class);

    @Override
    protected boolean readImpl() {
        return true;
    }

    @Override
    protected void runImpl() {
        GameClient client = (GameClient)this.getClient();
        Player activeChar = client.getActiveChar();
        if (activeChar == null) {
            client.closeNow(false);
            return;
        }
        GameStats.incrementPlayerEnterGame();
        EnterWorld.onEnterWorld(activeChar);
    }

    public static void onEnterWorld(Player activeChar) {
        Object castingSkillEntry;
        boolean first = activeChar.entering;
        activeChar.sendPacket((IBroadcastPacket)ExLightingCandleEvent.DISABLED);
        activeChar.sendPacket((IBroadcastPacket)new ExEnterWorldPacket());
        if (Config.EX_USE_TO_DO_LIST) {
            activeChar.sendPacket((IBroadcastPacket)ExConnectedTimeAndGettableReward.STATIC);
        }
        activeChar.sendPacket((IBroadcastPacket)new ExPeriodicHenna(activeChar));
        activeChar.sendPacket((IBroadcastPacket)new HennaInfoPacket(activeChar));
        List<Castle> castleList = ResidenceHolder.getInstance().getResidenceList(Castle.class);
        for (Castle c : castleList) {
            activeChar.sendPacket((IBroadcastPacket)new ExCastleState(c));
        }
        activeChar.sendSkillList();
        activeChar.sendPacket((IBroadcastPacket)new EtcStatusUpdatePacket(activeChar));
        activeChar.sendPacket((IBroadcastPacket)new UIPacket(activeChar));
        activeChar.sendPacket((IBroadcastPacket)new ExUserInfoInvenWeight(activeChar));
        activeChar.sendPacket((IBroadcastPacket)new ExUserInfoEquipSlot(activeChar));
        activeChar.sendPacket((IBroadcastPacket)new ExUserInfoCubic(activeChar));
        activeChar.sendPacket((IBroadcastPacket)new ExUserInfoAbnormalVisualEffect(activeChar));
        activeChar.sendPacket((IBroadcastPacket)SystemMsg.WELCOME_TO_THE_WORLD_OF_LINEAGE_II);
        double mpCostDiff = activeChar.getMPCostDiff(Skill.SkillMagicType.PHYSIC);
        if (mpCostDiff != 0.0) {
            activeChar.sendPacket((IBroadcastPacket)new ExChangeMPCost(Skill.SkillMagicType.PHYSIC, mpCostDiff));
        }
        if ((mpCostDiff = activeChar.getMPCostDiff(Skill.SkillMagicType.MAGIC)) != 0.0) {
            activeChar.sendPacket((IBroadcastPacket)new ExChangeMPCost(Skill.SkillMagicType.MAGIC, mpCostDiff));
        }
        if ((mpCostDiff = activeChar.getMPCostDiff(Skill.SkillMagicType.MUSIC)) != 0.0) {
            activeChar.sendPacket((IBroadcastPacket)new ExChangeMPCost(Skill.SkillMagicType.MUSIC, mpCostDiff));
        }
        activeChar.sendPacket((IBroadcastPacket)new QuestListPacket(activeChar));
        activeChar.initActiveAutoShots();
        activeChar.sendPacket((IBroadcastPacket)new ExGetBookMarkInfoPacket(activeChar));
        activeChar.sendItemList(false);
        activeChar.sendPacket((IBroadcastPacket)new ExAdenaInvenCount(activeChar));
        activeChar.sendPacket((IBroadcastPacket)new ShortCutInitPacket(activeChar));
        activeChar.sendPacket((IBroadcastPacket)new ExBasicActionList(activeChar));
        activeChar.getMacroses().sendMacroses();
        Announcements.getInstance().showAnnouncements(activeChar);
        if (first) {
            activeChar.setOnlineStatus(true);
            if (activeChar.getPlayerAccess().GodMode && !Config.SHOW_GM_LOGIN && !Config.EVERYBODY_HAS_ADMIN_RIGHTS) {
                activeChar.setGMInvisible(true);
                activeChar.startAbnormalEffect(AbnormalEffect.STEALTH);
            }
            activeChar.setNonAggroTime(Long.MAX_VALUE);
            activeChar.setNonPvpTime(System.currentTimeMillis() + Config.NONPVP_TIME_ONTELEPORT);
            if (activeChar.isInBuffStore()) {
                activeChar.setPrivateStoreType(0);
            } else if (activeChar.isInStoreMode() && !TradeHelper.validateStore(activeChar)) {
                activeChar.setPrivateStoreType(0);
                activeChar.storePrivateStore();
            }
            activeChar.setRunning();
            activeChar.standUp();
            activeChar.spawnMe();
            activeChar.startTimers();
        }
        activeChar.sendPacket((IBroadcastPacket)new ExBR_PremiumStatePacket(activeChar, activeChar.hasPremiumAccount()));
        activeChar.sendPacket((IBroadcastPacket)new ExSetCompassZoneCode(activeChar));
        activeChar.sendPacket((IBroadcastPacket)new MagicAndSkillList(activeChar, 3503292, 730502));
        activeChar.sendPacket((IBroadcastPacket)new ExStorageMaxCountPacket(activeChar));
        activeChar.getAttendanceRewards().onEnterWorld();
        activeChar.sendPacket((IBroadcastPacket)new ExReceiveShowPostFriend(activeChar));
        if (Config.ALLOW_WORLD_CHAT) {
            activeChar.sendPacket((IBroadcastPacket)new ExWorldChatCnt(activeChar));
        }
        if (Config.EX_USE_PRIME_SHOP) {
            activeChar.sendPacket((IBroadcastPacket)new ExBR_NewIConCashBtnWnd(activeChar));
            activeChar.sendPacket((IBroadcastPacket)new ReciveVipInfo(activeChar));
        }
        EnterWorld.checkNewMail(activeChar);
        if (first) {
            activeChar.getListeners().onEnter();
        }
        activeChar.checkAndDeleteOlympiadItems();
        if (activeChar.getClan() != null) {
            activeChar.getClan().loginClanCond(activeChar, true);
            activeChar.sendPacket(activeChar.getClan().listAll());
            activeChar.sendPacket((IBroadcastPacket)new PledgeSkillListPacket(activeChar.getClan()));
        } else {
            activeChar.sendPacket((IBroadcastPacket)new ExPledgeCount(0));
        }
        if (first && Config.ALLOW_WEDDING) {
            CoupleManager.getInstance().engage(activeChar);
            CoupleManager.getInstance().notifyPartner(activeChar);
        }
        if (first) {
            activeChar.getFriendList().notifyFriends(true);
        }
        activeChar.checkHpMessages(activeChar.getMaxHp(), activeChar.getCurrentHp());
        activeChar.checkDayNightMessages();
        if (Config.SHOW_HTML_WELCOME) {
            String html = HtmCache.getInstance().getHtml("welcome.htm", activeChar);
            HtmlMessage msg = new HtmlMessage(5);
            msg.setHtml(HtmlUtils.bbParse(html));
            activeChar.sendPacket((IBroadcastPacket)msg);
        }
        if (Config.PETITIONING_ALLOWED) {
            PetitionManager.getInstance().checkPetitionMessages(activeChar);
        }
        if (!first) {
            long animationEndTime;
            Creature castingTarget;
            CreatureSkillCast skillCast = activeChar.getSkillCast(SkillCastingType.NORMAL);
            if (skillCast.isCastingNow()) {
                castingTarget = skillCast.getTarget();
                castingSkillEntry = skillCast.getSkillEntry();
                animationEndTime = skillCast.getAnimationEndTime();
                if (castingSkillEntry != null && !((SkillEntry)castingSkillEntry).getTemplate().isNotBroadcastable() && castingTarget != null && castingTarget.isCreature() && animationEndTime > 0L) {
                    activeChar.sendPacket((IBroadcastPacket)new MagicSkillUse(activeChar, castingTarget, ((SkillEntry)castingSkillEntry).getId(), ((SkillEntry)castingSkillEntry).getLevel(), (int)(animationEndTime - System.currentTimeMillis()), 0L, SkillCastingType.NORMAL));
                }
            }
            if ((skillCast = activeChar.getSkillCast(SkillCastingType.NORMAL_SECOND)).isCastingNow()) {
                castingTarget = skillCast.getTarget();
                castingSkillEntry = skillCast.getSkillEntry();
                animationEndTime = skillCast.getAnimationEndTime();
                if (castingSkillEntry != null && !((SkillEntry)castingSkillEntry).getTemplate().isNotBroadcastable() && castingTarget != null && castingTarget.isCreature() && animationEndTime > 0L) {
                    activeChar.sendPacket((IBroadcastPacket)new MagicSkillUse(activeChar, castingTarget, ((SkillEntry)castingSkillEntry).getId(), ((SkillEntry)castingSkillEntry).getLevel(), (int)(animationEndTime - System.currentTimeMillis()), 0L, SkillCastingType.NORMAL_SECOND));
                }
            }
            if (activeChar.isInBoat()) {
                activeChar.sendPacket((IBroadcastPacket)activeChar.getBoat().getOnPacket(activeChar, activeChar.getInBoatPosition()));
            }
            if (activeChar.getMovement().isMoving() || activeChar.getMovement().isFollow()) {
                activeChar.sendPacket((IBroadcastPacket)activeChar.movePacket());
            }
            if (activeChar.getMountNpcId() != 0) {
                activeChar.sendPacket((IBroadcastPacket)new RidePacket(activeChar));
            }
            if (activeChar.isFishing()) {
                activeChar.getFishing().stop();
            }
        }
        activeChar.entering = false;
        if (activeChar.isSitting()) {
            activeChar.sendPacket((IBroadcastPacket)new ChangeWaitTypePacket(activeChar, 0));
        }
        if (activeChar.isInStoreMode()) {
            activeChar.sendPacket((IBroadcastPacket)activeChar.getPrivateStoreMsgPacket(activeChar));
        }
        activeChar.unsetVar("offline");
        activeChar.unsetVar("offlinebuff");
        activeChar.unsetVar("offlinebuff_price");
        activeChar.unsetVar("offlinebuff_skills");
        activeChar.unsetVar("offlinebuff_title");
        OfflineBufferManager.getInstance().getBuffStores().remove(activeChar.getObjectId());
        activeChar.sendActionFailed();
        if (first && activeChar.isGM() && Config.SAVE_GM_EFFECTS && activeChar.getPlayerAccess().CanUseGMCommand) {
            if (activeChar.getVarBoolean("gm_silence")) {
                activeChar.setMessageRefusal(true);
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.MESSAGE_REFUSAL_MODE);
            }
            if (activeChar.getVarBoolean("gm_invul")) {
                activeChar.getFlags().getInvulnerable().start();
                activeChar.getFlags().getDebuffImmunity().start();
                activeChar.startAbnormalEffect(AbnormalEffect.INVINCIBILITY);
                activeChar.sendMessage(activeChar.getName() + " is now immortal.");
            }
            if (activeChar.getVarBoolean("gm_undying")) {
                activeChar.setGMUndying(true);
                activeChar.sendMessage("Undying state has been enabled.");
            }
            activeChar.setGmSpeed(activeChar.getVarInt("gm_gmspeed", 0));
        }
        PlayerMessageStack.getInstance().CheckMessages(activeChar);
        IntObjectPair<OnAnswerListener> entry = activeChar.getAskListener(false);
        if (entry != null && entry.getValue() instanceof ReviveAnswerListener) {
            activeChar.sendPacket((IBroadcastPacket)((ConfirmDlgPacket)new ConfirmDlgPacket(SystemMsg.C1_IS_MAKING_AN_ATTEMPT_TO_RESURRECT_YOU_IF_YOU_CHOOSE_THIS_PATH_S2_EXPERIENCE_WILL_BE_RETURNED_FOR_YOU, 0).addString("Other player")).addString("some"));
        }
        if (!first) {
            Object party;
            Player leader;
            if (activeChar.isInObserverMode()) {
                if (activeChar.getObserverMode() == 2) {
                    activeChar.returnFromObserverMode();
                } else {
                    activeChar.leaveObserverMode();
                }
            } else if (activeChar.isVisible()) {
                World.showObjectsToPlayer(activeChar);
            }
            List<Servitor> servitors = activeChar.getServitors();
            Iterator<Servitor> castingSkillEntry2 = servitors.iterator();
            while (castingSkillEntry2.hasNext()) {
                Servitor servitor = castingSkillEntry2.next();
                activeChar.sendPacket((IBroadcastPacket)new MyPetSummonInfoPacket(servitor));
            }
            if (activeChar.isInParty() && (leader = ((Party)(party = activeChar.getParty())).getPartyLeader()) != null) {
                activeChar.sendPacket((IBroadcastPacket)new PartySmallWindowAllPacket((Party)party, leader, activeChar));
                RelationChangedPacket rcp = new RelationChangedPacket();
                for (Player member : ((Party)party).getPartyMembers()) {
                    Servitor servitor2;
                    if (member == activeChar) continue;
                    activeChar.sendPacket((IBroadcastPacket)new PartySpelledPacket(member, true));
                    Iterator<Servitor> iterator2 = servitors.iterator();
                    while (iterator2.hasNext()) {
                        servitor2 = iterator2.next();
                        activeChar.sendPacket((IBroadcastPacket)new PartySpelledPacket(servitor2, true));
                    }
                    rcp.add(member, activeChar);
                    for (Servitor servitor3 : member.getServitors()) {
                        rcp.add(servitor3, activeChar);
                    }
                    iterator2 = servitors.iterator();
                    while (iterator2.hasNext()) {
                        servitor2 = iterator2.next();
                        servitor2.broadcastCharInfoImpl(activeChar, (IUpdateTypeComponent[])NpcInfoType.VALUES);
                    }
                }
                activeChar.sendPacket((IBroadcastPacket)rcp);
                if (((Party)party).isInCommandChannel()) {
                    activeChar.sendPacket((IBroadcastPacket)ExOpenMPCCPacket.STATIC);
                }
            }
            activeChar.sendActiveAutoShots();
            for (Abnormal e : activeChar.getAbnormalList()) {
                if (!e.getSkill().isToggle() || e.getSkill().isNotBroadcastable()) continue;
                activeChar.sendPacket((IBroadcastPacket)new MagicSkillLaunchedPacket(activeChar.getObjectId(), e.getSkill().getId(), e.getSkill().getLevel(), activeChar, SkillCastingType.NORMAL));
            }
            activeChar.broadcastCharInfo();
        }
        if (activeChar.isDead()) {
            activeChar.sendPacket((IBroadcastPacket)new DiePacket(activeChar));
        }
        activeChar.updateAbnormalIcons();
        activeChar.updateStats();
        if (Config.ALT_PCBANG_POINTS_ENABLED && (!Config.ALT_PCBANG_POINTS_ONLY_PREMIUM || activeChar.hasPremiumAccount())) {
            activeChar.sendPacket((IBroadcastPacket)new ExPCCafePointInfoPacket(activeChar, 0, 1, 2, 12));
        }
        activeChar.checkLevelUpReward(true);
        if (first) {
            GameClient client;
            activeChar.useTriggers(activeChar, TriggerType.ON_ENTER_WORLD, null, null, 0.0);
            for (ListenerHook hook : ListenerHook.getGlobalListenerHooks(ListenerHookType.PLAYER_ENTER_GAME)) {
                hook.onPlayerEnterGame(activeChar);
            }
            if (Config.ALLOW_IP_LOCK && Config.AUTO_LOCK_IP_ON_LOGIN) {
                AuthServerCommunication.getInstance().sendPacket(new ChangeAllowedIp(activeChar.getAccountName(), activeChar.getIP()));
            }
            if (Config.ALLOW_HWID_LOCK && Config.AUTO_LOCK_HWID_ON_LOGIN && (client = activeChar.getNetConnection()) != null) {
                AuthServerCommunication.getInstance().sendPacket(new ChangeAllowedHwid(activeChar.getAccountName(), client.getHWID()));
            }
        }
        activeChar.getInventory().checkItems();
    }

    private static void checkNewMail(Player activeChar) {
        activeChar.sendPacket((IBroadcastPacket)new ExUnReadMailCount(activeChar));
        for (Mail mail : MailDAO.getInstance().getReceivedMailByOwnerId(activeChar.getObjectId())) {
            if (!mail.isUnread()) continue;
            activeChar.sendPacket((IBroadcastPacket)ExNoticePostArrived.STATIC_FALSE);
            break;
        }
    }
}

