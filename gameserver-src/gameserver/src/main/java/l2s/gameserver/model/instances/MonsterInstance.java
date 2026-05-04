/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.instances;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import l2s.commons.collections.MultiValueSet;
import l2s.commons.math.SafeMath;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.model.AggroList;
import l2s.gameserver.model.CommandChannel;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Party;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.PlayerGroup;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.base.Experience;
import l2s.gameserver.model.base.TeamType;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.model.quest.Quest;
import l2s.gameserver.model.quest.QuestEventType;
import l2s.gameserver.model.quest.QuestState;
import l2s.gameserver.model.reward.RewardItem;
import l2s.gameserver.model.reward.RewardList;
import l2s.gameserver.model.reward.RewardType;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExMagicAttackInfo;
import l2s.gameserver.network.l2.s2c.SocialActionPacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.templates.item.data.RewardItemData;
import l2s.gameserver.templates.npc.Faction;
import l2s.gameserver.templates.npc.NpcTemplate;
import l2s.gameserver.utils.ItemFunctions;

public class MonsterInstance
extends NpcInstance {
    private int overhitAttackerId;
    private double _overhitDamage;
    private boolean _isSpoiled;
    private int spoilerId;
    private List<RewardItem> _sweepItems;
    private boolean _sweeped;
    private final Lock sweepLock = new ReentrantLock();
    private int _isChampion;
    private final boolean _canMove = this.getParameter("canMove", true);

    public MonsterInstance(int objectId, NpcTemplate template, MultiValueSet<String> set) {
        super(objectId, template, set);
    }

    @Override
    public boolean isMovementDisabled() {
        return !this._canMove || super.isMovementDisabled();
    }

    @Override
    public boolean isLethalImmune() {
        return this._isChampion > 0 || super.isLethalImmune();
    }

    @Override
    public boolean isFearImmune() {
        return this._isChampion > 0 || super.isFearImmune();
    }

    @Override
    public boolean isParalyzeImmune() {
        return this._isChampion > 0 || super.isParalyzeImmune();
    }

    @Override
    public boolean isAutoAttackable(Creature attacker) {
        return attacker.getPlayer() != null || attacker.isDefender();
    }

    public int getChampion() {
        return this._isChampion;
    }

    public void setChampion() {
        if (this.getReflection().canChampions() && this.canChampion()) {
            double random = Rnd.nextDouble();
            if (Config.ALT_CHAMPION_CHANCE2 / 100.0 >= random) {
                this.setChampion(2);
            } else if ((Config.ALT_CHAMPION_CHANCE1 + Config.ALT_CHAMPION_CHANCE2) / 100.0 >= random) {
                this.setChampion(1);
            } else {
                this.setChampion(0);
            }
        } else {
            this.setChampion(0);
        }
    }

    public void setChampion(int level) {
        if (level == 0) {
            this.removeSkillById(4407);
            this._isChampion = 0;
        } else {
            this.addSkill(SkillEntry.makeSkillEntry(SkillEntryType.NONE, 4407, level));
            this._isChampion = level;
        }
    }

    public boolean canChampion() {
        return !this.isMinion() && this.getTemplate().rewardExp > 0L && this.getTemplate().level >= Config.ALT_CHAMPION_MIN_LEVEL && this.getTemplate().level <= Config.ALT_CHAMPION_TOP_LEVEL;
    }

    @Override
    public TeamType getTeam() {
        return this.getChampion() == 2 ? TeamType.RED : (this.getChampion() == 1 ? TeamType.BLUE : TeamType.NONE);
    }

    @Override
    protected void onDespawn() {
        this.setOverhitDamage(0.0);
        this.setOverhitAttacker(null);
        this.clearSweep();
        super.onDespawn();
    }

    @Override
    public void onSpawnMinion(NpcInstance minion) {
        if (minion.isMonster()) {
            if (this.getChampion() == 2) {
                ((MonsterInstance)minion).setChampion(1);
            } else {
                ((MonsterInstance)minion).setChampion(0);
            }
        }
        super.onSpawnMinion(minion);
    }

    @Override
    protected void onDeath(Creature killer) {
        this.calculateRewards(killer);
        super.onDeath(killer);
    }

    @Override
    protected void onReduceCurrentHp(double damage, Creature attacker, Skill skill, boolean awake, boolean standUp, boolean directHp, boolean isDot) {
        if (skill != null && skill.isOverhit()) {
            double overhitDmg = (this.getCurrentHp() - damage) * -1.0;
            if (overhitDmg <= 0.0) {
                this.setOverhitDamage(0.0);
                this.setOverhitAttacker(null);
            } else {
                this.setOverhitDamage(overhitDmg);
                this.setOverhitAttacker(attacker);
            }
        }
        super.onReduceCurrentHp(damage, attacker, skill, awake, standUp, directHp, isDot);
    }

    public void calculateRewards(Creature lastAttacker) {
        Creature topDamager = this.getAggroList().getTopDamager(lastAttacker);
        if (lastAttacker == null || !lastAttacker.isPlayable()) {
            lastAttacker = topDamager;
        }
        if (lastAttacker == null || !lastAttacker.isPlayable()) {
            return;
        }
        Player killer = lastAttacker.getPlayer();
        if (killer == null) {
            return;
        }
        Map<Playable, AggroList.HateInfo> aggroMap = this.getAggroList().getPlayableMap();
        Set<Quest> quests = this.getTemplate().getEventQuests(QuestEventType.MOB_KILLED_WITH_QUEST);
        if (quests != null && !quests.isEmpty()) {
            ArrayList<Player> players = null;
            if (this.isRaid() && Config.ALT_NO_LASTHIT) {
                players = new ArrayList<Player>();
                for (Playable playable : aggroMap.keySet()) {
                    if (playable.isDead() || !this.isInRangeZ(playable, Config.ALT_PARTY_DISTRIBUTION_RANGE) && !killer.isInRangeZ(playable, Config.ALT_PARTY_DISTRIBUTION_RANGE) || players.contains(playable.getPlayer())) continue;
                    players.add(playable.getPlayer());
                }
            } else if (killer.getParty() != null) {
                players = new ArrayList(killer.getParty().getMemberCount());
                for (Player player : killer.getParty().getPartyMembers()) {
                    if (player.isDead() || !this.isInRangeZ(player, Config.ALT_PARTY_DISTRIBUTION_RANGE) && !killer.isInRangeZ(player, Config.ALT_PARTY_DISTRIBUTION_RANGE)) continue;
                    players.add(player);
                }
            }
            for (Quest quest : quests) {
                QuestState qs;
                Object toReward = killer;
                if (quest.getPartyType() != Quest.PARTY_NONE && players != null) {
                    if (this.isRaid() || quest.getPartyType() == Quest.PARTY_ALL) {
                        for (Player player : players) {
                            QuestState qs2 = player.getQuestState(quest);
                            if (qs2 == null || qs2.isCompleted()) continue;
                            quest.notifyKill(this, qs2);
                        }
                        toReward = null;
                    } else {
                        ArrayList<Player> interested = new ArrayList<Player>(players.size());
                        for (Player pl2 : players) {
                            QuestState qs3 = pl2.getQuestState(quest);
                            if (qs3 == null || qs3.isCompleted()) continue;
                            interested.add(pl2);
                        }
                        if (interested.isEmpty()) continue;
                        toReward = (Player)interested.get(Rnd.get((int)interested.size()));
                        if (toReward == null) {
                            toReward = killer;
                        }
                    }
                }
                if (toReward == null || (qs = ((Player)toReward).getQuestState(quest)) == null || qs.isCompleted()) continue;
                quest.notifyKill(this, qs);
            }
        }
        HashMap<PlayerGroup, GroupInfo> groupsInfo = new HashMap<PlayerGroup, GroupInfo>();
        double totalDamage = 0.0;
        for (AggroList.HateInfo ai : aggroMap.values()) {
            Player player = ai.attacker.getPlayer();
            if (player == null) continue;
            PlayerGroup group = this.isRaid() ? player.getPlayerGroup() : (player.getParty() != null ? player.getParty() : player);
            GroupInfo info = (GroupInfo)groupsInfo.get(group);
            boolean addDamage = true;
            if (info == null) {
                info = new GroupInfo();
                groupsInfo.put(group, info);
                addDamage = false;
            }
            for (Player p : group) {
                if (p.isDead() || !p.isInRangeZ(this, Config.ALT_PARTY_DISTRIBUTION_RANGE)) continue;
                info.players.add(p);
                addDamage = true;
            }
            if (!addDamage) continue;
            info.damage += (double)ai.damage;
            totalDamage += (double)Math.max(0, ai.damage);
        }
        totalDamage = Math.max(totalDamage, (double)this.getMaxHp());
        for (Map.Entry groupInfo : groupsInfo.entrySet()) {
            PlayerGroup playerGroup = (PlayerGroup)groupInfo.getKey();
            GroupInfo info = (GroupInfo)groupInfo.getValue();
            double damage = info.damage;
            if (damage <= 1.0) continue;
            if (playerGroup instanceof CommandChannel) {
                CommandChannel commandChannel = (CommandChannel)playerGroup;
                HashSet<Party> rewardedParties = new HashSet<Party>();
                for (Player p : info.players) {
                    Party party = p.getParty();
                    if (party == null || !commandChannel.getParties().contains(party)) continue;
                    rewardedParties.add(party);
                }
                for (Party party : rewardedParties) {
                    HashSet<Player> rewardedMembers = new HashSet<Player>();
                    int partylevel = 1;
                    for (Player partyMember : party.getPartyMembers()) {
                        if (!info.players.remove(partyMember)) continue;
                        if (partyMember.getLevel() > partylevel) {
                            partylevel = partyMember.getLevel();
                        }
                        rewardedMembers.add(partyMember);
                    }
                    double[] xpsp = this.calculateExpAndSp(partylevel, damage / (double)rewardedParties.size(), totalDamage);
                    xpsp[0] = this.applyOverhit(killer, xpsp[0]);
                    party.distributeXpAndSp(xpsp[0], xpsp[1], rewardedMembers, lastAttacker, this);
                }
                continue;
            }
            if (playerGroup instanceof Party) {
                Party party = (Party)playerGroup;
                int partylevel = 1;
                for (Player p : info.players) {
                    if (p.getLevel() <= partylevel) continue;
                    partylevel = p.getLevel();
                }
                double[] xpsp = this.calculateExpAndSp(partylevel, damage, totalDamage);
                xpsp[0] = this.applyOverhit(killer, xpsp[0]);
                party.distributeXpAndSp(xpsp[0], xpsp[1], info.players, lastAttacker, this);
                continue;
            }
            if (!(playerGroup instanceof Player)) continue;
            Player player = (Player)playerGroup;
            double[] xpsp = this.calculateExpAndSp(player.getLevel(), damage, totalDamage);
            xpsp[0] = this.applyOverhit(killer, xpsp[0]);
            player.addExpAndCheckBonus(this, (long)xpsp[0], (long)xpsp[1]);
        }
        if (topDamager != null && topDamager.isPlayable()) {
            for (RewardList rewardList : this.getRewardLists()) {
                this.rollRewards(rewardList, lastAttacker, topDamager);
            }
            Player player = topDamager.getPlayer();
            if (player != null && Math.abs(this.getLevel() - player.getLevel()) < 9) {
                for (RewardItemData rewardItemData : player.getPremiumAccount().getRewards()) {
                    if (!Rnd.chance((double)rewardItemData.getChance())) continue;
                    ItemFunctions.addItem(player, rewardItemData.getId(), Rnd.get((long)rewardItemData.getMinCount(), (long)rewardItemData.getMaxCount()));
                }
                for (RewardItemData rewardItemData : player.getVIP().getTemplate().getRewards()) {
                    if (!Rnd.chance((double)rewardItemData.getChance())) continue;
                    ItemFunctions.addItem(player, rewardItemData.getId(), Rnd.get((long)rewardItemData.getMinCount(), (long)rewardItemData.getMaxCount()));
                }
                if (this.getChampion() > 0 && Config.SPECIAL_ITEM_ID > 0 && Config.SPECIAL_ITEM_COUNT > 0L && Math.abs(this.getLevel() - player.getLevel()) < 9 && Rnd.chance((double)Config.SPECIAL_ITEM_DROP_CHANCE)) {
                    ItemFunctions.addItem(player, Config.SPECIAL_ITEM_ID, Config.SPECIAL_ITEM_COUNT);
                }
            }
        }
    }

    @Override
    public void onRandomAnimation() {
        if (System.currentTimeMillis() - this._lastSocialAction > 10000L) {
            this.broadcastPacket(new SocialActionPacket(this.getObjectId(), 1));
            this._lastSocialAction = System.currentTimeMillis();
        }
    }

    @Override
    public void startRandomAnimation() {
    }

    @Override
    public int getKarma() {
        return 0;
    }

    public boolean isSpoiled() {
        return this._isSpoiled;
    }

    public boolean isSpoiled(Player player) {
        if (!this.isSpoiled()) {
            return false;
        }
        if (player.getObjectId() == this.spoilerId && System.currentTimeMillis() - this.getDeathTime() < 20000L) {
            return true;
        }
        if (player.isInParty()) {
            for (Player pm : player.getParty().getPartyMembers()) {
                if (pm.getObjectId() != this.spoilerId || this.getDistance(pm) >= Config.ALT_PARTY_DISTRIBUTION_RANGE) continue;
                return true;
            }
        }
        return false;
    }

    public boolean setSpoiled(Player player) {
        this.sweepLock.lock();
        try {
            if (this.isSpoiled()) {
                boolean bl = false;
                return bl;
            }
            this._isSpoiled = true;
            this.spoilerId = player.getObjectId();
        }
        finally {
            this.sweepLock.unlock();
        }
        return true;
    }

    public boolean isSweepActive() {
        this.sweepLock.lock();
        try {
            boolean bl = this._sweepItems != null && this._sweepItems.size() > 0;
            return bl;
        }
        finally {
            this.sweepLock.unlock();
        }
    }

    
    public boolean takeSweep(Player player) {
        this.sweepLock.lock();
        try {
            this._sweeped = true;
            if (this._sweepItems == null || this._sweepItems.isEmpty()) {
                this.clearSweep();
                boolean bl = false;
                return bl;
            }
            for (RewardItem item : this._sweepItems) {
                SystemMessagePacket smsg;
                ItemInstance sweep = ItemFunctions.createItem(item.itemId);
                sweep.setCount(item.count);
                if (player.isInParty() && player.getParty().isDistributeSpoilLoot()) {
                    player.getParty().distributeItem(player, sweep, null);
                    continue;
                }
                if (!player.getInventory().validateCapacity(sweep) || !player.getInventory().validateWeight(sweep)) {
                    sweep.dropToTheGround(player, this);
                    continue;
                }
                player.getInventory().addItem(sweep);
                if (item.count == 1L) {
                    smsg = new SystemMessagePacket(SystemMsg.YOU_HAVE_OBTAINED_S1);
                    smsg.addItemName(item.itemId);
                    player.sendPacket((IBroadcastPacket)smsg);
                } else {
                    smsg = new SystemMessagePacket(SystemMsg.YOU_HAVE_OBTAINED_S2_S1);
                    smsg.addItemName(item.itemId);
                    smsg.addLong(item.count);
                    player.sendPacket((IBroadcastPacket)smsg);
                }
                if (!player.isInParty()) continue;
                if (item.count == 1L) {
                    smsg = new SystemMessagePacket(SystemMsg.C1_HAS_OBTAINED_S2_BY_USING_SWEEPER);
                    smsg.addName(player);
                    smsg.addItemName(item.itemId);
                    player.getParty().getPartyLeader().sendPacket((IBroadcastPacket)smsg);
                    continue;
                }
                smsg = new SystemMessagePacket(SystemMsg.C1_HAS_OBTAINED_S3_S2_BY_USING_SWEEPER);
                smsg.addName(player);
                smsg.addItemName(item.itemId);
                smsg.addLong(item.count);
                player.getParty().getPartyLeader().sendPacket((IBroadcastPacket)smsg);
            }
            this.clearSweep();
            boolean bl = true;
            return bl;
        }
        finally {
            this.sweepLock.unlock();
        }
    }

    public boolean isSweeped() {
        return this._sweeped;
    }

    public void clearSweep() {
        this.sweepLock.lock();
        try {
            this._isSpoiled = false;
            this.spoilerId = 0;
            this._sweepItems = null;
        }
        finally {
            this.sweepLock.unlock();
        }
    }

    public void rollRewards(RewardList list, Creature lastAttacker, Creature topDamager) {
        RewardType type = list.getType();
        if (type == RewardType.SWEEP && !this.isSpoiled()) {
            return;
        }
        Creature activeChar = type == RewardType.SWEEP ? lastAttacker : topDamager;
        Player activePlayer = activeChar.getPlayer();
        if (activePlayer == null) {
            return;
        }
        double penaltyMod = Experience.penaltyModifier(this.calculateLevelDiffForDrop(topDamager.getLevel()), 9.0);
        List<RewardItem> rewardItems = list.roll(activePlayer, penaltyMod, this);
        switch (type) {
            case SWEEP: {
                this._sweepItems = rewardItems;
                break;
            }
            default: {
                for (RewardItem drop : rewardItems) {
                    if (!(Config.DROP_ONLY_THIS.isEmpty() || Config.DROP_ONLY_THIS.contains(drop.itemId) || Config.INCLUDE_RAID_DROP && this.isRaid())) {
                        return;
                    }
                    this.dropItem(activePlayer, drop.itemId, drop.count);
                }
            }
        }
    }

    private double[] calculateExpAndSp(int level, double damage, double totalDamage) {
        int diff = Math.min(Math.max(0, level - this.getLevel()), Config.MONSTER_LEVEL_DIFF_EXP_PENALTY.length - 1);
        double xp = SafeMath.mulAndLimit((double)this.getExpReward(), (double)(damage / totalDamage));
        double sp = SafeMath.mulAndLimit((double)this.getSpReward(), (double)(damage / totalDamage));
        double mod = (100.0 - (double)Config.MONSTER_LEVEL_DIFF_EXP_PENALTY[diff]) / 100.0;
        xp = SafeMath.mulAndLimit((double)xp, (double)mod);
        sp = SafeMath.mulAndLimit((double)sp, (double)mod);
        xp = Math.max(0.0, xp);
        sp = Math.max(0.0, sp);
        return new double[]{xp, sp};
    }

    private double applyOverhit(Player killer, double xp) {
        if (xp > 0.0 && killer.getObjectId() == this.overhitAttackerId) {
            int overHitExp = this.calculateOverhitExp(xp);
            killer.sendPacket((IBroadcastPacket)SystemMsg.OVERHIT);
            killer.sendPacket((IBroadcastPacket)new ExMagicAttackInfo(killer.getObjectId(), this.getObjectId(), 3));
            xp += (double)overHitExp;
        }
        return xp;
    }

    @Override
    public void setOverhitAttacker(Creature attacker) {
        this.overhitAttackerId = attacker == null ? 0 : attacker.getObjectId();
    }

    public double getOverhitDamage() {
        return this._overhitDamage;
    }

    @Override
    public void setOverhitDamage(double damage) {
        this._overhitDamage = damage;
    }

    public int calculateOverhitExp(double normalExp) {
        double overhitPercentage = this.getOverhitDamage() * 100.0 / (double)this.getMaxHp();
        if (overhitPercentage > 25.0) {
            overhitPercentage = 25.0;
        }
        double overhitExp = overhitPercentage / 100.0 * normalExp;
        this.setOverhitAttacker(null);
        this.setOverhitDamage(0.0);
        return (int)Math.round(overhitExp);
    }

    @Override
    public boolean isAggressive() {
        return (Config.ALT_CHAMPION_CAN_BE_AGGRO || this.getChampion() == 0) && super.isAggressive();
    }

    @Override
    public Faction getFaction() {
        if (this.getTemplate().isNoClan()) {
            return Faction.NONE;
        }
        return Config.ALT_CHAMPION_CAN_BE_SOCIAL || this.getChampion() == 0 ? super.getFaction() : Faction.NONE;
    }

    @Override
    public boolean isMonster() {
        return true;
    }

    @Override
    public Clan getClan() {
        return null;
    }

    @Override
    public boolean isPeaceNpc() {
        return false;
    }

    protected class GroupInfo {
        public HashSet<Player> players = new HashSet();
        public double damage = 0.0;
    }
}

