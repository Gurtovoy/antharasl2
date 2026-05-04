package l2s.gameserver.model;

import gnu.trove.iterator.TIntObjectIterator;
import gnu.trove.map.hash.TIntIntHashMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.CopyOnWriteArraySet;
import java.util.concurrent.Future;
import java.util.concurrent.ScheduledFuture;
import l2s.commons.collections.LazyArrayList;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.geometry.ILocation;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.geometry.Territory;
import l2s.gameserver.instancemanager.MatchingRoomManager;
import l2s.gameserver.instancemanager.ReflectionManager;
import l2s.gameserver.model.CommandChannel;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.PlayerGroup;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.base.Experience;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.instances.MonsterInstance;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.matching.MatchingRoom;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExAskModifyPartyLooting;
import l2s.gameserver.network.l2.s2c.ExCloseMPCCPacket;
import l2s.gameserver.network.l2.s2c.ExOpenMPCCPacket;
import l2s.gameserver.network.l2.s2c.ExPartyPetWindowAdd;
import l2s.gameserver.network.l2.s2c.ExPartyPetWindowDelete;
import l2s.gameserver.network.l2.s2c.ExReplyHandOverPartyMaster;
import l2s.gameserver.network.l2.s2c.ExSetPartyLooting;
import l2s.gameserver.network.l2.s2c.ExTacticalSign;
import l2s.gameserver.network.l2.s2c.GetItemPacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.network.l2.s2c.PartyMemberPositionPacket;
import l2s.gameserver.network.l2.s2c.PartySmallWindowAddPacket;
import l2s.gameserver.network.l2.s2c.PartySmallWindowAllPacket;
import l2s.gameserver.network.l2.s2c.PartySmallWindowDeleteAllPacket;
import l2s.gameserver.network.l2.s2c.PartySmallWindowDeletePacket;
import l2s.gameserver.network.l2.s2c.PartySpelledPacket;
import l2s.gameserver.network.l2.s2c.RelationChangedPacket;
import l2s.gameserver.network.l2.s2c.SystemMessage;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.network.l2.s2c.updatetype.IUpdateTypeComponent;
import l2s.gameserver.network.l2.s2c.updatetype.NpcInfoType;
import l2s.gameserver.taskmanager.LazyPrecisionTaskManager;
import l2s.gameserver.utils.ItemFunctions;
import l2s.gameserver.utils.Log;

public class Party
implements PlayerGroup {
    public static final int MAX_SIZE = Config.MAXIMUM_MEMBERS_IN_PARTY;
    public static final int ITEM_LOOTER = 0;
    public static final int ITEM_RANDOM = 1;
    public static final int ITEM_RANDOM_SPOIL = 2;
    public static final int ITEM_ORDER = 3;
    public static final int ITEM_ORDER_SPOIL = 4;
    private final List<Player> _members = new CopyOnWriteArrayList<Player>();
    private int _partyLvl = 0;
    private int _itemDistribution = 0;
    private int _itemOrder = 0;
    private int _dimentionalRift;
    private Reflection _reflection;
    private CommandChannel _commandChannel;
    private double _rateExp;
    private double _rateSp;
    private double _rateDrop;
    private double _rateAdena;
    private double _rateSpoil;
    private double _dropChanceMod;
    private double _dropCountMod;
    private double _spoilChanceMod;
    private double _spoilCountMod;
    private ScheduledFuture<?> positionTask;
    private int _requestChangeLoot = -1;
    private long _requestChangeLootTimer = 0L;
    private Set<Integer> _changeLootAnswers = null;
    private static final int[] LOOT_SYSSTRINGS = new int[]{487, 488, 798, 799, 800};
    private static final int[] TACTICAL_SYSSTRINGS = new int[]{0, 2664, 2665, 2666, 2667};
    private Future<?> _checkTask = null;
    private TIntObjectHashMap<Creature> _tacticalTargets = new TIntObjectHashMap(4);

    public Party(Player leader, int itemDistribution) {
        this._itemDistribution = itemDistribution;
        this._members.add(leader);
        this._partyLvl = leader.getLevel();
        this._rateExp = leader.getPremiumAccount().getExpRate();
        this._rateSp = leader.getPremiumAccount().getSpRate();
        this._rateAdena = leader.getPremiumAccount().getAdenaRate();
        this._rateDrop = leader.getPremiumAccount().getDropRate();
        this._rateSpoil = leader.getPremiumAccount().getSpoilRate();
        this._dropChanceMod = leader.getPremiumAccount().getDropChanceModifier();
        this._dropCountMod = leader.getPremiumAccount().getDropCountModifier();
        this._spoilChanceMod = leader.getPremiumAccount().getSpoilChanceModifier();
        this._spoilCountMod = leader.getPremiumAccount().getSpoilCountModifier();
    }

    @Override
    public int getMemberCount() {
        return this._members.size();
    }

    public int getMemberCountInRange(Player player, int range) {
        int count = 0;
        for (Player member : this._members) {
            if (member != player && !member.isInRangeZ(player, range)) continue;
            ++count;
        }
        return count;
    }

    public List<Player> getPartyMembers() {
        return this._members;
    }

    public List<Integer> getPartyMembersObjIds() {
        ArrayList<Integer> result = new ArrayList<Integer>(this._members.size());
        for (Player member : this._members) {
            result.add(member.getObjectId());
        }
        return result;
    }

    public List<Playable> getPartyMembersWithPets() {
        ArrayList<Playable> result = new ArrayList<Playable>();
        for (Player member : this._members) {
            result.add(member);
            for (Servitor servitor : member.getServitors()) {
                result.add(servitor);
            }
        }
        return result;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private Player getNextLooterInRange(Player player, ItemInstance item, int range) {
        List<Player> list = this._members;
        synchronized (list) {
            int antiloop = this._members.size();
            while (--antiloop > 0) {
                Player ret;
                int looter = this._itemOrder++;
                if (this._itemOrder > this._members.size() - 1) {
                    this._itemOrder = 0;
                }
                if ((ret = looter < this._members.size() ? this._members.get(looter) : player) == null || ret.isDead() || !ret.isInRangeZ(player, range) || !ret.getInventory().validateCapacity(item) || !ret.getInventory().validateWeight(item)) continue;
                return ret;
            }
        }
        return player;
    }

    public boolean isLeader(Player player) {
        return this.getPartyLeader() == player;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public Player getPartyLeader() {
        List<Player> list = this._members;
        synchronized (list) {
            if (this._members.size() == 0) {
                return null;
            }
            return this._members.get(0);
        }
    }

    @Override
    public void broadCast(IBroadcastPacket ... msg) {
        for (Player member : this._members) {
            member.sendPacket(msg);
        }
    }

    public void broadcastMessageToPartyMembers(String msg) {
        this.broadCast(new SystemMessage(msg));
    }

    public void broadcastCustomMessageToPartyMembers(String address, String ... replacements) {
        for (Player member : this._members) {
            CustomMessage cm = new CustomMessage(address);
            for (String s : replacements) {
                cm.addString(s);
            }
            member.sendMessage(cm);
        }
    }

    public void broadcastToPartyMembers(Player exclude, IBroadcastPacket msg) {
        for (Player member : this._members) {
            if (exclude == member) continue;
            member.sendPacket(msg);
        }
    }

    public void broadcastToPartyMembersInRange(Player player, IBroadcastPacket msg, int range) {
        for (Player member : this._members) {
            if (!player.isInRangeZ(member, range)) continue;
            member.sendPacket(msg);
        }
    }

    public boolean containsMember(Player player) {
        return this._members.contains(player);
    }

    public int indexOf(Player player) {
        return this._members.indexOf(player);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public boolean addPartyMember(Player player, boolean force) {
        Player leader = this.getPartyLeader();
        if (leader == null) {
            return false;
        }
        List<Player> list = this._members;
        synchronized (list) {
            if (this._members.isEmpty()) {
                return false;
            }
            if (this._members.contains(player)) {
                return false;
            }
            if (!force && this._members.size() == MAX_SIZE) {
                return false;
            }
            this._members.add(player);
        }
        if (this._requestChangeLoot != -1) {
            this.finishLootRequest(false);
        }
        player.setParty(this);
        player.getListeners().onPartyInvite();
        ArrayList<L2GameServerPacket> addInfo = new ArrayList<L2GameServerPacket>(4 + this._members.size() * 4);
        ArrayList<L2GameServerPacket> pplayer = new ArrayList<L2GameServerPacket>(20);
        pplayer.add(new PartySmallWindowAllPacket(this, leader, player));
        if (!force) {
            pplayer.add(new SystemMessage(106).addName(leader));
            addInfo.add(new SystemMessage(107).addName(player));
        }
        addInfo.add(new PartySpelledPacket(player, true));
        for (Servitor servitor : player.getServitors()) {
            addInfo.add(new ExPartyPetWindowAdd(servitor));
            addInfo.add(new PartySpelledPacket(servitor, true));
        }
        RelationChangedPacket rcp = new RelationChangedPacket();
        PartyMemberPositionPacket pmp = new PartyMemberPositionPacket();
        for (Player member : this._members) {
            if (member == player) continue;
            ArrayList<L2GameServerPacket> pmember = new ArrayList<L2GameServerPacket>(addInfo.size() + 4);
            pmember.addAll(addInfo);
            pmember.add(new PartySmallWindowAddPacket(member, player));
            pmember.add(new PartyMemberPositionPacket().add(player));
            RelationChangedPacket memberrcp = new RelationChangedPacket(player, member);
            for (Servitor servitor : player.getServitors()) {
                memberrcp.add(servitor, member);
            }
            pmember.add(memberrcp);
            member.sendPacket(pmember);
            pplayer.add(new PartySpelledPacket(member, true));
            for (Servitor servitor : player.getServitors()) {
                pplayer.add(new PartySpelledPacket(servitor, true));
                servitor.broadcastCharInfoImpl(member, (IUpdateTypeComponent[])NpcInfoType.VALUES);
            }
            rcp.add(member, player);
            for (Servitor servitor : member.getServitors()) {
                rcp.add(servitor, player);
            }
            pmp.add(member);
        }
        pplayer.add(rcp);
        pplayer.add(pmp);
        if (this.isInCommandChannel()) {
            pplayer.add(ExOpenMPCCPacket.STATIC);
        }
        player.sendPacket(pplayer);
        this.startUpdatePositionTask();
        this.recalculatePartyData();
        this.sendTacticalSign(player);
        MatchingRoom currentRoom = player.getMatchingRoom();
        MatchingRoom room = leader.getMatchingRoom();
        if (currentRoom != null && currentRoom != room) {
            currentRoom.removeMember(player, false);
        }
        if (room != null && room.getType() == MatchingRoom.PARTY_MATCHING) {
            room.addMemberForce(player);
        } else {
            MatchingRoomManager.getInstance().removeFromWaitingList(player);
        }
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void dissolveParty() {
        for (Player p : this._members) {
            p.sendPacket((IBroadcastPacket)PartySmallWindowDeleteAllPacket.STATIC);
            p.setParty(null);
        }
        List<Player> list = this._members;
        synchronized (list) {
            this._members.clear();
        }
        this.setCommandChannel(null);
        this.stopUpdatePositionTask();
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public boolean removePartyMember(Player player, boolean kick, boolean force) {
        Player leader;
        MatchingRoom room;
        boolean isLeader = this.isLeader(player);
        boolean dissolve = false;
        List<Player> list = this._members;
        synchronized (list) {
            if (!this._members.remove(player)) {
                return false;
            }
            dissolve = this._members.size() == 1;
        }
        player.stopSubstituteTask();
        player.getListeners().onPartyLeave();
        player.setParty(null);
        this.recalculatePartyData();
        ArrayList<IBroadcastPacket> pplayer = new ArrayList<IBroadcastPacket>(4 + this._members.size() * 2);
        if (this.isInCommandChannel()) {
            pplayer.add(ExCloseMPCCPacket.STATIC);
        }
        if (!force) {
            if (kick) {
                pplayer.add(SystemMsg.YOU_HAVE_BEEN_EXPELLED_FROM_THE_PARTY);
            } else {
                pplayer.add(SystemMsg.YOU_HAVE_WITHDRAWN_FROM_THE_PARTY);
            }
        }
        pplayer.add(PartySmallWindowDeleteAllPacket.STATIC);
        ArrayList<L2GameServerPacket> outsInfo = new ArrayList<L2GameServerPacket>(3);
        for (Servitor servitor : player.getServitors()) {
            outsInfo.add(new ExPartyPetWindowDelete(servitor));
        }
        outsInfo.add(new PartySmallWindowDeletePacket(player));
        if (!force) {
            if (kick) {
                outsInfo.add(new SystemMessage(201).addName(player));
            } else {
                outsInfo.add(new SystemMessage(108).addName(player));
            }
        }
        RelationChangedPacket rcp = new RelationChangedPacket();
        for (Player member : this._members) {
            ArrayList<L2GameServerPacket> pmember = new ArrayList<L2GameServerPacket>(2 + outsInfo.size());
            pmember.addAll(outsInfo);
            RelationChangedPacket memberrcp = new RelationChangedPacket(player, member);
            for (Servitor servitor : player.getServitors()) {
                memberrcp.add(servitor, member);
            }
            pmember.add(memberrcp);
            member.sendPacket(pmember);
            rcp.add(member, player);
            for (Servitor servitor : member.getServitors()) {
                rcp.add(servitor, player);
            }
        }
        pplayer.add(rcp);
        player.sendPacket(pplayer);
        this.clearTacticalTargets(player);
        Reflection reflection = this.getReflection();
        if (reflection != null && player.getReflection() == reflection && reflection.getReturnLoc() != null) {
            player.teleToLocation((ILocation)reflection.getReturnLoc(), ReflectionManager.MAIN);
        }
        MatchingRoom matchingRoom = room = (leader = this.getPartyLeader()) != null ? leader.getMatchingRoom() : null;
        if (dissolve) {
            if (this.isInCommandChannel()) {
                this._commandChannel.removeParty(this);
            } else if (reflection != null && reflection.getInstancedZone() != null && reflection.getInstancedZone().isCollapseOnPartyDismiss() && reflection.getParty() == this) {
                reflection.startCollapseTimer(reflection.getInstancedZone().getTimerOnCollapse(), true);
            }
            if (room != null && room.getType() == MatchingRoom.PARTY_MATCHING) {
                if (isLeader) {
                    room.disband();
                } else {
                    room.removeMember(player, kick);
                }
            }
            this.dissolveParty();
        } else {
            if (this.isInCommandChannel() && this._commandChannel.getChannelLeader() == player) {
                this._commandChannel.setChannelLeader(leader);
            }
            if (room != null && room.getType() == MatchingRoom.PARTY_MATCHING) {
                room.removeMember(player, kick);
            }
            if (isLeader) {
                this.updateLeaderInfo();
            }
        }
        if (this._checkTask != null) {
            this._checkTask.cancel(true);
            this._checkTask = null;
        }
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public boolean changePartyLeader(Player player) {
        Player leader = this.getPartyLeader();
        List<Player> list = this._members;
        synchronized (list) {
            int index = this._members.indexOf(player);
            if (index == -1) {
                return false;
            }
            this._members.set(0, player);
            this._members.set(index, leader);
        }
        leader.sendPacket((IBroadcastPacket)ExReplyHandOverPartyMaster.FALSE);
        player.sendPacket((IBroadcastPacket)ExReplyHandOverPartyMaster.TRUE);
        this.updateLeaderInfo();
        if (this.isInCommandChannel() && this._commandChannel.getChannelLeader() == leader) {
            this._commandChannel.setChannelLeader(player);
        }
        return true;
    }

    public void updatePartyInfo() {
        Player leader = this.getPartyLeader();
        if (leader == null) {
            return;
        }
        for (Player member : this._members) {
            member.sendPacket((IBroadcastPacket)PartySmallWindowDeleteAllPacket.STATIC);
            member.sendPacket((IBroadcastPacket)new PartySmallWindowAllPacket(this, leader, member));
        }
        for (Player member : this._members) {
            this.broadcastToPartyMembers(member, new PartySpelledPacket(member, true));
            for (Servitor servitor : member.getServitors()) {
                this.broadCast(new ExPartyPetWindowAdd(servitor));
            }
        }
    }

    private void updateLeaderInfo() {
        Player leader = this.getPartyLeader();
        if (leader == null) {
            return;
        }
        SystemMessage msg = new SystemMessage(1384).addName(leader);
        for (Player member : this._members) {
            member.sendPacket((IBroadcastPacket)msg);
        }
        this.updatePartyInfo();
        MatchingRoom room = leader.getMatchingRoom();
        if (room != null && room.getType() == MatchingRoom.PARTY_MATCHING) {
            room.setLeader(leader);
        }
    }

    public Player getPlayerByName(String name) {
        for (Player member : this._members) {
            if (!name.equalsIgnoreCase(member.getName())) continue;
            return member;
        }
        return null;
    }

    public void distributeItem(Player player, ItemInstance item, NpcInstance fromNpc) {
        switch (item.getItemId()) {
            case 57: {
                this.distributeAdena(player, item, fromNpc);
                break;
            }
            default: {
                this.distributeItem0(player, item, fromNpc);
            }
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private void distributeItem0(Player player, ItemInstance item, NpcInstance fromNpc) {
        Player target = null;
        List<Player> ret = null;
        switch (this._itemDistribution) {
            case 1: 
            case 2: {
                ret = new ArrayList<Player>(this._members.size());
                for (Player member : this._members) {
                    if (!member.isInRangeZ(player, Config.ALT_PARTY_DISTRIBUTION_RANGE) || member.isDead() || !member.getInventory().validateCapacity(item) || !member.getInventory().validateWeight(item)) continue;
                    ret.add(member);
                }
                target = ret.isEmpty() ? null : (Player)ret.get(Rnd.get((int)ret.size()));
                break;
            }
            case 3: 
            case 4: {
                List<Player> list = this._members;
                synchronized (list) {
                    ret = new CopyOnWriteArrayList<Player>(this._members);
                    while (target == null && !ret.isEmpty()) {
                        Player looterPlayer;
                        int looter = this._itemOrder++;
                        if (this._itemOrder > ret.size() - 1) {
                            this._itemOrder = 0;
                        }
                        if ((looterPlayer = looter < ret.size() ? (Player)ret.get(looter) : null) == null) continue;
                        if (!looterPlayer.isDead() && looterPlayer.isInRangeZ(player, Config.ALT_PARTY_DISTRIBUTION_RANGE) && ItemFunctions.canAddItem(looterPlayer, item)) {
                            target = looterPlayer;
                            continue;
                        }
                        ret.remove(looterPlayer);
                    }
                }
                if (target != null) break;
                return;
            }
            default: {
                target = player;
            }
        }
        if (target == null) {
            target = player;
        }
        if (target.pickupItem(item, "PartyPickup")) {
            if (fromNpc == null) {
                player.broadcastPacket(new GetItemPacket(item, player.getObjectId()));
            }
            player.broadcastPickUpMsg(item);
            item.pickupMe();
            this.broadcastToPartyMembers(target, SystemMessagePacket.obtainItemsBy(item, target));
        } else {
            item.dropToTheGround(player, fromNpc);
        }
    }

    private void distributeAdena(Player player, ItemInstance item, NpcInstance fromNpc) {
        if (player == null) {
            return;
        }
        ArrayList<Player> membersInRange = new ArrayList<Player>();
        if (item.getCount() < (long)this._members.size()) {
            membersInRange.add(player);
        } else {
            for (Player member : this._members) {
                if (member.isDead() || member != player && !player.isInRangeZ(member, Config.ALT_PARTY_DISTRIBUTION_RANGE) || !ItemFunctions.canAddItem(player, item)) continue;
                membersInRange.add(member);
            }
        }
        if (membersInRange.isEmpty()) {
            membersInRange.add(player);
        }
        long totalAdena = item.getCount();
        long amount = totalAdena / (long)membersInRange.size();
        long ost = totalAdena % (long)membersInRange.size();
        for (Player member : membersInRange) {
            long count = member.equals(player) ? amount + ost : amount;
            member.getInventory().addAdena(count);
            member.sendPacket((IBroadcastPacket)SystemMessagePacket.obtainItems(57, count, 0));
        }
        if (fromNpc == null) {
            player.broadcastPacket(new GetItemPacket(item, player.getObjectId()));
        }
        item.pickupMe();
    }

    public void distributeXpAndSp(double xpReward, double spReward, Collection<Player> rewardedMembers, Creature lastAttacker, MonsterInstance monster) {
        this.recalculatePartyData();
        ArrayList<Player> mtr = new ArrayList<Player>();
        int partyLevel = lastAttacker.getLevel();
        int partyLvlSum = 0;
        for (Player player : rewardedMembers) {
            if (!monster.isInRangeZ(player, Config.ALT_PARTY_DISTRIBUTION_RANGE)) continue;
            partyLevel = Math.max(partyLevel, player.getLevel());
        }
        int maxDistributionLevelDIff = Config.ALT_PARTY_LVL_DIFF_PENALTY.length - 1;
        for (Player player : rewardedMembers) {
            if (!monster.isInRangeZ(player, Config.ALT_PARTY_DISTRIBUTION_RANGE) || player.getLevel() <= partyLevel - maxDistributionLevelDIff) continue;
            partyLvlSum += player.getLevel();
            mtr.add(player);
        }
        if (mtr.isEmpty()) {
            return;
        }
        TIntIntHashMap tIntIntHashMap = new TIntIntHashMap();
        for (Player player : mtr) {
            Clan clan = player.getClan();
            if (clan == null) continue;
            tIntIntHashMap.put(clan.getClanId(), tIntIntHashMap.get(clan.getClanId()) + 1);
        }
        double d = Config.ALT_PARTY_BONUS[Math.min(Config.ALT_PARTY_BONUS.length, mtr.size()) - 1];
        double XP = xpReward * d;
        double SP = spReward * d;
        for (Player player : mtr) {
            double lvlPenalty = Experience.penaltyModifier(monster.calculateLevelDiffForDrop(player.getLevel()), 9.0);
            int lvlDiff = partyLevel - player.getLevel();
            lvlDiff = Math.max(0, Math.min(lvlDiff, maxDistributionLevelDIff));
            double clanBonus = Config.ALT_PARTY_CLAN_BONUS[Math.min(Config.ALT_PARTY_CLAN_BONUS.length - 1, tIntIntHashMap.get(player.getClanId()))];
            double memberXp = XP * clanBonus * (lvlPenalty *= (double)Config.ALT_PARTY_LVL_DIFF_PENALTY[lvlDiff] / 100.0) * (double)player.getLevel() / (double)partyLvlSum;
            double memberSp = SP * clanBonus * lvlPenalty * (double)player.getLevel() / (double)partyLvlSum;
            memberXp = Math.min(memberXp, xpReward);
            memberSp = Math.min(memberSp, spReward);
            player.addExpAndCheckBonus(monster, (long)memberXp, (long)memberSp);
        }
        this.recalculatePartyData();
    }

    public void recalculatePartyData() {
        this._partyLvl = 0;
        double rateExp = 0.0;
        double rateSp = 0.0;
        double rateDrop = 0.0;
        double rateAdena = 0.0;
        double rateSpoil = 0.0;
        double dropChanceMod = 0.0;
        double dropCountMod = 0.0;
        double spoilChanceMod = 0.0;
        double spoilCountMod = 0.0;
        double minRateExp = Double.MAX_VALUE;
        double minRateSp = Double.MAX_VALUE;
        double minRateDrop = Double.MAX_VALUE;
        double minRateAdena = Double.MAX_VALUE;
        double minRateSpoil = Double.MAX_VALUE;
        double minDropChanceMod = Double.MAX_VALUE;
        double minDropCountMod = Double.MAX_VALUE;
        double minSpoilChanceMod = Double.MAX_VALUE;
        double minSpoilCountMod = Double.MAX_VALUE;
        double maxRateExp = 0.0;
        double maxRateSp = 0.0;
        double maxRateDrop = 0.0;
        double maxRateAdena = 0.0;
        double maxRateSpoil = 0.0;
        double maxDropChanceMod = 0.0;
        double maxDropCountMod = 0.0;
        double maxSpoilChanceMod = 0.0;
        double maxSpoilCountMod = 0.0;
        int count = 0;
        for (Player member : this._members) {
            int level = member.getLevel();
            this._partyLvl = Math.max(this._partyLvl, level);
            ++count;
            rateExp += member.getPremiumAccount().getExpRate();
            rateSp += member.getPremiumAccount().getSpRate();
            rateDrop += member.getPremiumAccount().getDropRate();
            rateAdena += member.getPremiumAccount().getAdenaRate();
            rateSpoil += member.getPremiumAccount().getSpoilRate();
            dropChanceMod += member.getPremiumAccount().getDropChanceModifier();
            dropCountMod += member.getPremiumAccount().getDropCountModifier();
            spoilChanceMod += member.getPremiumAccount().getSpoilChanceModifier();
            spoilCountMod += member.getPremiumAccount().getSpoilCountModifier();
            minRateExp = Math.min(minRateExp, member.getPremiumAccount().getExpRate());
            minRateSp = Math.min(minRateSp, member.getPremiumAccount().getSpRate());
            minRateDrop = Math.min(minRateDrop, member.getPremiumAccount().getDropRate());
            minRateAdena = Math.min(minRateAdena, member.getPremiumAccount().getAdenaRate());
            minRateSpoil = Math.min(minRateSpoil, member.getPremiumAccount().getSpoilRate());
            minDropChanceMod = Math.min(minDropChanceMod, member.getPremiumAccount().getDropChanceModifier());
            minDropCountMod = Math.min(minDropCountMod, member.getPremiumAccount().getDropCountModifier());
            minSpoilChanceMod = Math.min(minSpoilChanceMod, member.getPremiumAccount().getSpoilChanceModifier());
            minSpoilCountMod = Math.min(minSpoilCountMod, member.getPremiumAccount().getSpoilCountModifier());
            maxRateExp = Math.max(maxRateExp, member.getPremiumAccount().getExpRate());
            maxRateSp = Math.max(maxRateSp, member.getPremiumAccount().getSpRate());
            maxRateDrop = Math.max(maxRateDrop, member.getPremiumAccount().getDropRate());
            maxRateAdena = Math.max(maxRateAdena, member.getPremiumAccount().getAdenaRate());
            maxRateSpoil = Math.max(maxRateSpoil, member.getPremiumAccount().getSpoilRate());
            maxDropChanceMod = Math.max(maxDropChanceMod, member.getPremiumAccount().getDropChanceModifier());
            maxDropCountMod = Math.max(maxDropCountMod, member.getPremiumAccount().getDropCountModifier());
            maxSpoilChanceMod = Math.max(maxSpoilChanceMod, member.getPremiumAccount().getSpoilChanceModifier());
            maxSpoilCountMod = Math.max(maxSpoilCountMod, member.getPremiumAccount().getSpoilCountModifier());
        }
        switch (Config.PA_RATE_IN_PARTY_MODE) {
            case 1: {
                this._rateExp = minRateExp;
                this._rateSp = minRateSp;
                this._rateDrop = minRateDrop;
                this._rateAdena = minRateAdena;
                this._rateSpoil = minRateSpoil;
                this._dropChanceMod = minDropChanceMod;
                this._dropCountMod = minDropCountMod;
                this._spoilChanceMod = minSpoilChanceMod;
                this._spoilCountMod = minSpoilCountMod;
                break;
            }
            case 2: {
                this._rateExp = maxRateExp;
                this._rateSp = maxRateSp;
                this._rateDrop = maxRateDrop;
                this._rateAdena = maxRateAdena;
                this._rateSpoil = maxRateSpoil;
                this._dropChanceMod = maxDropChanceMod;
                this._dropCountMod = maxDropCountMod;
                this._spoilChanceMod = maxSpoilChanceMod;
                this._spoilCountMod = maxSpoilCountMod;
                break;
            }
            default: {
                this._rateExp = rateExp / (double)count;
                this._rateSp = rateSp / (double)count;
                this._rateDrop = rateDrop / (double)count;
                this._rateAdena = rateAdena / (double)count;
                this._rateSpoil = rateSpoil / (double)count;
                this._dropChanceMod = dropChanceMod / (double)count;
                this._dropCountMod = dropCountMod / (double)count;
                this._spoilChanceMod = spoilChanceMod / (double)count;
                this._spoilCountMod = spoilCountMod / (double)count;
            }
        }
    }

    public int getLevel() {
        return this._partyLvl;
    }

    public double getRateExp(Player player) {
        if (Config.PA_RATE_IN_PARTY_MODE == 3) {
            return player.getPremiumAccount().getExpRate();
        }
        return this._rateExp;
    }

    public double getRateSp(Player player) {
        if (Config.PA_RATE_IN_PARTY_MODE == 3) {
            return player.getPremiumAccount().getSpRate();
        }
        return this._rateSp;
    }

    public double getRateDrop(Player player) {
        if (Config.PA_RATE_IN_PARTY_MODE == 3) {
            return player.getPremiumAccount().getDropRate();
        }
        return this._rateDrop;
    }

    public double getRateAdena(Player player) {
        if (Config.PA_RATE_IN_PARTY_MODE == 3) {
            return player.getPremiumAccount().getAdenaRate();
        }
        return this._rateAdena;
    }

    public double getRateSpoil(Player player) {
        if (Config.PA_RATE_IN_PARTY_MODE == 3) {
            return player.getPremiumAccount().getSpoilRate();
        }
        return this._rateSpoil;
    }

    public double getDropChanceMod(Player player) {
        if (Config.PA_RATE_IN_PARTY_MODE == 3) {
            return player.getPremiumAccount().getDropChanceModifier();
        }
        return this._dropChanceMod;
    }

    public double getDropCountMod(Player player) {
        if (Config.PA_RATE_IN_PARTY_MODE == 3) {
            return player.getPremiumAccount().getDropCountModifier();
        }
        return this._dropCountMod;
    }

    public double getSpoilChanceMod(Player player) {
        if (Config.PA_RATE_IN_PARTY_MODE == 3) {
            return player.getPremiumAccount().getSpoilChanceModifier();
        }
        return this._spoilChanceMod;
    }

    public double getSpoilCountMod(Player player) {
        if (Config.PA_RATE_IN_PARTY_MODE == 3) {
            return player.getPremiumAccount().getSpoilCountModifier();
        }
        return this._spoilCountMod;
    }

    public int getLootDistribution() {
        return this._itemDistribution;
    }

    public boolean isDistributeSpoilLoot() {
        boolean rv = false;
        if (this._itemDistribution == 2 || this._itemDistribution == 4) {
            rv = true;
        }
        return rv;
    }

    public boolean isInReflection() {
        return this._reflection != null;
    }

    public void setReflection(Reflection reflection) {
        this._reflection = reflection;
    }

    public Reflection getReflection() {
        if (this._reflection != null) {
            return this._reflection;
        }
        return null;
    }

    public boolean isInCommandChannel() {
        return this._commandChannel != null;
    }

    public CommandChannel getCommandChannel() {
        return this._commandChannel;
    }

    public void setCommandChannel(CommandChannel channel) {
        this._commandChannel = channel;
    }

    public void Teleport(int x, int y, int z) {
        Party.TeleportParty(this.getPartyMembers(), new Location(x, y, z));
    }

    public void Teleport(Location dest) {
        Party.TeleportParty(this.getPartyMembers(), dest);
    }

    public void Teleport(Territory territory) {
        Party.RandomTeleportParty(this.getPartyMembers(), territory);
    }

    public void Teleport(Territory territory, Location dest) {
        Party.TeleportParty(this.getPartyMembers(), territory, dest);
    }

    public static void TeleportParty(List<Player> members, Location dest) {
        for (Player _member : members) {
            if (_member == null) continue;
            _member.teleToLocation(dest);
        }
    }

    public static void TeleportParty(List<Player> members, Territory territory, Location dest) {
        if (!territory.isInside(dest.x, dest.y)) {
            Log.add("TeleportParty: dest is out of territory", "errors");
            Thread.dumpStack();
            return;
        }
        int base_x = members.get(0).getX();
        int base_y = members.get(0).getY();
        for (Player _member : members) {
            if (_member == null) continue;
            int diff_x = _member.getX() - base_x;
            int diff_y = _member.getY() - base_y;
            Location loc = new Location(dest.x + diff_x, dest.y + diff_y, dest.z);
            while (!territory.isInside(loc.x, loc.y)) {
                diff_x = loc.x - dest.x;
                diff_y = loc.y - dest.y;
                if (diff_x != 0) {
                    loc.x -= diff_x / Math.abs(diff_x);
                }
                if (diff_y == 0) continue;
                loc.y -= diff_y / Math.abs(diff_y);
            }
            _member.teleToLocation(loc);
        }
    }

    public static void RandomTeleportParty(List<Player> members, Territory territory) {
        for (Player member : members) {
            member.teleToLocation(Territory.getRandomLoc(territory, member.getGeoIndex(), member.isFlying()));
        }
    }

    private void startUpdatePositionTask() {
        if (this.positionTask == null) {
            this.positionTask = LazyPrecisionTaskManager.getInstance().scheduleAtFixedRate(new UpdatePositionTask(), 1000L, 1000L);
        }
    }

    private void stopUpdatePositionTask() {
        if (this.positionTask != null) {
            this.positionTask.cancel(false);
        }
    }

    public void requestLootChange(byte type) {
        if (this._requestChangeLoot != -1) {
            if (System.currentTimeMillis() > this._requestChangeLootTimer) {
                this.finishLootRequest(false);
            } else {
                return;
            }
        }
        this._requestChangeLoot = type;
        int additionalTime = 45000;
        this._requestChangeLootTimer = System.currentTimeMillis() + (long)additionalTime;
        this._changeLootAnswers = new CopyOnWriteArraySet<Integer>();
        this._checkTask = ThreadPoolManager.getInstance().scheduleAtFixedRate(new ChangeLootCheck(), additionalTime + 1000, 5000L);
        this.broadcastToPartyMembers(this.getPartyLeader(), new ExAskModifyPartyLooting(this.getPartyLeader().getName(), type));
        SystemMessage sm = new SystemMessage(3135);
        sm.addSystemString(LOOT_SYSSTRINGS[type]);
        this.getPartyLeader().sendPacket((IBroadcastPacket)sm);
    }

    public synchronized void answerLootChangeRequest(Player member, boolean answer) {
        if (this._requestChangeLoot == -1) {
            return;
        }
        if (this._changeLootAnswers.contains(member.getObjectId())) {
            return;
        }
        if (!answer) {
            this.finishLootRequest(false);
            return;
        }
        this._changeLootAnswers.add(member.getObjectId());
        if (this._changeLootAnswers.size() >= this.getMemberCount() - 1) {
            this.finishLootRequest(true);
        }
    }

    private synchronized void finishLootRequest(boolean success) {
        if (this._requestChangeLoot == -1) {
            return;
        }
        if (this._checkTask != null) {
            this._checkTask.cancel(false);
            this._checkTask = null;
        }
        if (success) {
            this.broadCast(new ExSetPartyLooting(1, this._requestChangeLoot));
            this._itemDistribution = this._requestChangeLoot;
            SystemMessage sm = new SystemMessage(3138);
            sm.addSystemString(LOOT_SYSSTRINGS[this._requestChangeLoot]);
            this.broadCast(sm);
        } else {
            this.broadCast(new ExSetPartyLooting(0, 0));
            this.broadCast(new SystemMessage(3137));
        }
        this._changeLootAnswers = null;
        this._requestChangeLoot = -1;
        this._requestChangeLootTimer = 0L;
    }

    @Override
    public Player getGroupLeader() {
        return this.getPartyLeader();
    }

    @Override
    public Iterator<Player> iterator() {
        return this._members.iterator();
    }

    public void changeTacticalSign(Player player, int sign, Creature target) {
        Creature oldTarget;
        if (target == null) {
            return;
        }
        if (this._tacticalTargets.containsKey(sign) && (oldTarget = (Creature)this._tacticalTargets.get(sign)) != null) {
            this.broadCast(new ExTacticalSign(oldTarget.getObjectId(), 0));
        }
        this._tacticalTargets.put(sign, target);
        this.broadCast(new ExTacticalSign(target.getObjectId(), sign));
        SystemMessagePacket sm = new SystemMessagePacket(SystemMsg.C1_USED_S3_ON_C2);
        sm.addName(player);
        sm.addName(target);
        sm.addSysString(TACTICAL_SYSSTRINGS[sign]);
        this.broadCast(sm);
    }

    public Creature findTacticalTarget(Player player, int sign) {
        if (player == null) {
            return null;
        }
        if (!this._tacticalTargets.containsKey(sign)) {
            return null;
        }
        Creature target = (Creature)this._tacticalTargets.get(sign);
        if (player.getDistance3D(target) > 1000) {
            return null;
        }
        return target;
    }

    private void clearTacticalTargets(Player player) {
        for (Creature target : this._tacticalTargets.valueCollection()) {
            player.sendPacket((IBroadcastPacket)new ExTacticalSign(target.getObjectId(), 0));
        }
    }

    private void sendTacticalSign(Player member) {
        TIntObjectIterator iterator = this._tacticalTargets.iterator();
        while (iterator.hasNext()) {
            iterator.advance();
            Creature target = (Creature)iterator.value();
            if (target == null) continue;
            member.sendPacket((IBroadcastPacket)new ExTacticalSign(target.getObjectId(), iterator.key()));
        }
    }

    public void removeTacticalSign(Creature target) {
        TIntObjectIterator iterator = this._tacticalTargets.iterator();
        while (iterator.hasNext()) {
            iterator.advance();
            if (iterator.value() != target) continue;
            this.broadCast(new ExTacticalSign(target.getObjectId(), 0));
            this._tacticalTargets.remove(iterator.key());
            break;
        }
    }

    public void substituteMember(Player member, Player member2) {
        Location defLoc = member.getLoc();
        Location defLoc2 = member2.getLoc();
        member.teleToLocation((ILocation)defLoc2, member2.getReflection());
        member2.teleToLocation((ILocation)defLoc, member.getReflection());
        this.removePartyMember(member, false, false);
        this.addPartyMember(member2, false);
    }

    private class ChangeLootCheck
    implements Runnable {
        private ChangeLootCheck() {
        }

        @Override
        public void run() {
            if (System.currentTimeMillis() > Party.this._requestChangeLootTimer) {
                Party.this.finishLootRequest(false);
            }
        }
    }

    private class UpdatePositionTask
    implements Runnable {
        private UpdatePositionTask() {
        }

        @Override
        public void run() {
            LazyArrayList update = LazyArrayList.newInstance();
            for (Player member : Party.this._members) {
                Location loc = member.getLastPartyPosition();
                if (loc != null && member.getDistance(loc) <= 256) continue;
                member.setLastPartyPosition(member.getLoc());
                update.add(member);
            }
            if (!update.isEmpty()) {
                for (Player member : Party.this._members) {
                    PartyMemberPositionPacket pmp = new PartyMemberPositionPacket();
                    for (Player m : (LazyArrayList<Player>)update) {
                        if (m == member) continue;
                        pmp.add(m);
                    }
                    if (pmp.size() <= 0) continue;
                    member.sendPacket((IBroadcastPacket)pmp);
                }
            }
            LazyArrayList.recycle((LazyArrayList)update);
        }
    }
}

