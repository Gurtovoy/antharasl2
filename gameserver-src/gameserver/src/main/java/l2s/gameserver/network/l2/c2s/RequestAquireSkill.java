/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.data.xml.holder.SkillAcquireHolder;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.SkillLearn;
import l2s.gameserver.model.base.AcquireType;
import l2s.gameserver.model.base.ClassId;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.instances.VillageMasterPledgeBypasses;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.model.pledge.SubUnit;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.templates.item.data.ItemData;
import l2s.gameserver.utils.ItemFunctions;
import l2s.gameserver.utils.MulticlassUtils;

public class RequestAquireSkill
extends L2GameClientPacket {
    private AcquireType _type;
    private int _id;
    private int _level;
    private int _subUnit;

    @Override
    protected boolean readImpl() {
        this._id = this.readD();
        this._level = this.readD();
        this._type = AcquireType.getById(this.readD());
        if (this._type == AcquireType.SUB_UNIT) {
            this._subUnit = this.readD();
        }
        return true;
    }

    @Override
    protected void runImpl() {
        SkillEntry skillEntry;
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null || player.isTransformed() || this._type == null) {
            return;
        }
        NpcInstance trainer = player.getLastNpc();
        if (!(trainer != null && player.checkInteractionDistance(trainer) || player.isGM())) {
            trainer = null;
        }
        if ((skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, this._id, this._level)) == null) {
            return;
        }
        ClassId selectedMultiClassId = player.getSelectedMultiClassId();
        if (this._type == AcquireType.MULTICLASS) {
            if (selectedMultiClassId == null) {
                return;
            }
        } else {
            selectedMultiClassId = null;
        }
        if (!SkillAcquireHolder.getInstance().isSkillPossible(player, selectedMultiClassId, skillEntry.getTemplate(), this._type)) {
            return;
        }
        SkillLearn skillLearn = SkillAcquireHolder.getInstance().getSkillLearn(player, selectedMultiClassId, this._id, this._level, this._type);
        if (skillLearn == null) {
            return;
        }
        if (skillLearn.getMinLevel() > player.getLevel()) {
            return;
        }
        if (!RequestAquireSkill.checkSpellbook(player, this._type, skillLearn)) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_DO_NOT_HAVE_THE_NECESSARY_MATERIALS_OR_PREREQUISITES_TO_LEARN_THIS_SKILL);
            return;
        }
        switch (this._type) {
            case NORMAL: {
                RequestAquireSkill.learnSimpleNextLevel(player, this._type, skillLearn, skillEntry, true);
                break;
            }
            case FISHING: {
                if (trainer == null) break;
                RequestAquireSkill.learnSimpleNextLevel(player, this._type, skillLearn, skillEntry, false);
                NpcInstance.showFishingSkillList(player);
                break;
            }
            case CLAN: {
                if (trainer == null) break;
                RequestAquireSkill.learnClanSkill(player, skillLearn, trainer, skillEntry);
                break;
            }
            case SUB_UNIT: {
                if (trainer == null) break;
                RequestAquireSkill.learnSubUnitSkill(player, skillLearn, trainer, skillEntry, this._subUnit);
                break;
            }
            case MULTICLASS: {
                RequestAquireSkill.learnSimpleNextLevel(player, this._type, skillLearn, skillEntry, true);
                MulticlassUtils.showMulticlassAcquireList(player, selectedMultiClassId);
                break;
            }
            case CUSTOM: {
                player.getListeners().onLearnCustomSkill(skillLearn);
            }
        }
    }

    private static void learnSimpleNextLevel(Player player, AcquireType type, SkillLearn skillLearn, SkillEntry skillEntry, boolean normal) {
        int skillLevel = player.getSkillLevel(skillLearn.getId(), 0);
        if (skillLevel != skillLearn.getLevel() - 1) {
            return;
        }
        RequestAquireSkill.learnSimple(player, type, skillLearn, skillEntry, normal);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private static void learnSimple(Player player, AcquireType type, SkillLearn skillLearn, SkillEntry skillEntry, boolean normal) {
        if (player.getSp() < (long)skillLearn.getCost()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_DO_NOT_HAVE_ENOUGH_SP_TO_LEARN_THIS_SKILL);
            return;
        }
        player.getInventory().writeLock();
        try {
            for (ItemData item : skillLearn.getRequiredItemsForLearn(type)) {
                if (ItemFunctions.haveItem(player, item.getId(), item.getCount())) continue;
                return;
            }
            for (ItemData item : skillLearn.getRequiredItemsForLearn(type)) {
                ItemFunctions.deleteItem((Playable)player, item.getId(), item.getCount(), true);
            }
        }
        finally {
            player.getInventory().writeUnlock();
        }
        player.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.YOU_HAVE_EARNED_S1_SKILL).addSkillName(skillEntry.getId(), skillEntry.getLevel()));
        player.setSp(player.getSp() - (long)skillLearn.getCost());
        player.addSkill(skillEntry, true);
        if (normal) {
            player.rewardSkills(false);
        }
        player.sendUserInfo();
        player.updateStats();
        player.sendSkillList(skillEntry.getId());
        player.updateSkillShortcuts(skillEntry.getId(), skillEntry.getLevel());
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private static void learnClanSkill(Player player, SkillLearn skillLearn, NpcInstance trainer, SkillEntry skillEntry) {
        if (!player.isClanLeader()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.ONLY_THE_CLAN_LEADER_IS_ENABLED);
            return;
        }
        Clan clan = player.getClan();
        int skillLevel = clan.getSkillLevel(skillLearn.getId(), 0);
        if (skillLevel != skillLearn.getLevel() - 1) {
            return;
        }
        if (clan.getReputationScore() < skillLearn.getCost()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.THE_CLAN_REPUTATION_SCORE_IS_TOO_LOW);
            return;
        }
        player.getInventory().writeLock();
        try {
            for (ItemData item : skillLearn.getRequiredItemsForLearn(AcquireType.CLAN)) {
                if (ItemFunctions.haveItem(player, item.getId(), item.getCount())) continue;
                return;
            }
            for (ItemData item : skillLearn.getRequiredItemsForLearn(AcquireType.CLAN)) {
                ItemFunctions.deleteItem((Playable)player, item.getId(), item.getCount(), true);
            }
        }
        finally {
            player.getInventory().writeUnlock();
        }
        clan.incReputation(-skillLearn.getCost(), false, "AquireSkill: " + skillLearn.getId() + ", lvl " + skillLearn.getLevel());
        clan.addSkill(skillEntry, true);
        clan.broadcastToOnlineMembers(new IBroadcastPacket[]{new SystemMessagePacket(SystemMsg.THE_CLAN_SKILL_S1_HAS_BEEN_ADDED).addSkillName(skillEntry.getTemplate())});
        VillageMasterPledgeBypasses.showClanSkillList(trainer, player);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private static void learnSubUnitSkill(Player player, SkillLearn skillLearn, NpcInstance trainer, SkillEntry skillEntry, int id) {
        Clan clan = player.getClan();
        if (clan == null) {
            return;
        }
        SubUnit sub = clan.getSubUnit(id);
        if (sub == null) {
            return;
        }
        if ((player.getClanPrivileges() & 0x200) != 512) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_ARE_NOT_AUTHORIZED_TO_DO_THAT);
            return;
        }
        int lvl = sub.getSkillLevel(skillLearn.getId(), 0);
        if (lvl >= skillLearn.getLevel()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.THIS_SQUAD_SKILL_HAS_ALREADY_BEEN_ACQUIRED);
            return;
        }
        if (lvl != skillLearn.getLevel() - 1) {
            player.sendPacket((IBroadcastPacket)SystemMsg.THE_PREVIOUS_LEVEL_SKILL_HAS_NOT_BEEN_LEARNED);
            return;
        }
        if (clan.getReputationScore() < skillLearn.getCost()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.THE_CLAN_REPUTATION_SCORE_IS_TOO_LOW);
            return;
        }
        player.getInventory().writeLock();
        try {
            for (ItemData item : skillLearn.getRequiredItemsForLearn(AcquireType.SUB_UNIT)) {
                if (ItemFunctions.haveItem(player, item.getId(), item.getCount())) continue;
                return;
            }
            for (ItemData item : skillLearn.getRequiredItemsForLearn(AcquireType.SUB_UNIT)) {
                ItemFunctions.deleteItem((Playable)player, item.getId(), item.getCount(), true);
            }
        }
        finally {
            player.getInventory().writeUnlock();
        }
        clan.incReputation(-skillLearn.getCost(), false, "AquireSkill2: " + skillLearn.getId() + ", lvl " + skillLearn.getLevel());
        sub.addSkill(skillEntry, true);
        player.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.THE_CLAN_SKILL_S1_HAS_BEEN_ADDED).addSkillName(skillEntry.getTemplate()));
        if (trainer != null) {
            NpcInstance.showSubUnitSkillList(player);
        }
    }

    private static boolean checkSpellbook(Player player, AcquireType type, SkillLearn skillLearn) {
        for (ItemData item : skillLearn.getRequiredItemsForLearn(type)) {
            if (ItemFunctions.haveItem(player, item.getId(), item.getCount())) continue;
            return false;
        }
        return true;
    }
}

