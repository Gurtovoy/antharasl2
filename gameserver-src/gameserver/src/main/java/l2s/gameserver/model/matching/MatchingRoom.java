/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.matching;

import java.util.Collection;
import java.util.Iterator;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArraySet;
import l2s.gameserver.instancemanager.MatchingRoomManager;
import l2s.gameserver.listener.actor.player.OnPlayerPartyInviteListener;
import l2s.gameserver.listener.actor.player.OnPlayerPartyLeaveListener;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.PlayerGroup;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;

public abstract class MatchingRoom
implements PlayerGroup {
    public static int PARTY_MATCHING = 0;
    public static int CC_MATCHING = 1;
    public static int WAIT_PLAYER = 0;
    public static int ROOM_MASTER = 1;
    public static int PARTY_MEMBER = 2;
    public static int UNION_LEADER = 3;
    public static int UNION_PARTY = 4;
    public static int WAIT_PARTY = 5;
    public static int WAIT_NORMAL = 6;
    private final int _id;
    private int _minLevel;
    private int _maxLevel;
    private int _maxMemberSize;
    private int _lootType;
    private String _topic;
    private final PartyListenerImpl _listener = new PartyListenerImpl();
    protected Player _leader;
    protected Set<Player> _members = new CopyOnWriteArraySet<Player>();

    public MatchingRoom(Player leader, int minLevel, int maxLevel, int maxMemberSize, int lootType, String topic) {
        this._leader = leader;
        this._id = MatchingRoomManager.getInstance().addMatchingRoom(this);
        this._minLevel = minLevel;
        this._maxLevel = maxLevel;
        this._maxMemberSize = maxMemberSize;
        this._lootType = lootType;
        this._topic = topic;
        this.addMember0(leader, null, true);
    }

    public boolean addMember(Player player) {
        if (this._members.contains(player)) {
            return true;
        }
        if (player.getLevel() < this.getMinLevel() || player.getLevel() > this.getMaxLevel() || this.getPlayers().size() >= this.getMaxMembersSize()) {
            player.sendPacket((IBroadcastPacket)this.notValidMessage());
            return false;
        }
        return this.addMember0(player, (L2GameServerPacket)new SystemMessagePacket(this.enterMessage()).addName(player), true);
    }

    public boolean addMemberForce(Player player) {
        if (this._members.contains(player)) {
            return true;
        }
        if (this.getPlayers().size() >= this.getMaxMembersSize()) {
            player.sendPacket((IBroadcastPacket)this.notValidMessage());
            return false;
        }
        return this.addMember0(player, (L2GameServerPacket)new SystemMessagePacket(this.enterMessage()).addName(player), false);
    }

    private boolean addMember0(Player player, L2GameServerPacket p, boolean sendInfo) {
        if (!this._members.isEmpty()) {
            player.addListener(this._listener);
        }
        this._members.add(player);
        player.setMatchingRoom(this);
        for (Player $member : this) {
            if ($member == player || !$member.isMatchingRoomWindowOpened()) continue;
            $member.sendPacket(p, this.addMemberPacket($member, player));
        }
        MatchingRoomManager.getInstance().removeFromWaitingList(player);
        if (sendInfo) {
            player.setMatchingRoomWindowOpened(true);
            player.sendPacket(this.infoRoomPacket(), this.membersPacket(player));
        }
        player.sendChanges();
        return true;
    }

    public void removeMember(Player member, boolean oust) {
        if (!this._members.remove(member)) {
            return;
        }
        member.removeListener(this._listener);
        member.setMatchingRoom(null);
        if (this._members.isEmpty()) {
            this.disband();
        } else {
            L2GameServerPacket infoPacket = this.infoRoomPacket();
            SystemMsg exitMessage0 = this.exitMessage(true, oust);
            IBroadcastPacket exitMessage = exitMessage0 != null ? new SystemMessagePacket(exitMessage0).addName(member) : null;
            for (Player player : this) {
                if (!player.isMatchingRoomWindowOpened()) continue;
                player.sendPacket(infoPacket, this.removeMemberPacket(player, member), exitMessage);
            }
        }
        member.sendPacket(this.closeRoomPacket(), this.exitMessage(false, oust));
        member.setMatchingRoomWindowOpened(false);
        member.sendChanges();
    }

    public void broadcastPlayerUpdate(Player player) {
        for (Player $member : this) {
            if (!$member.isMatchingRoomWindowOpened()) continue;
            $member.sendPacket((IBroadcastPacket)this.updateMemberPacket($member, player));
        }
    }

    public void disband() {
        for (Player player : this) {
            player.removeListener(this._listener);
            if (player.isMatchingRoomWindowOpened()) {
                player.sendPacket((IBroadcastPacket)this.closeRoomMessage());
                player.sendPacket((IBroadcastPacket)this.closeRoomPacket());
            }
            player.setMatchingRoom(null);
            player.sendChanges();
        }
        this._members.clear();
        MatchingRoomManager.getInstance().removeMatchingRoom(this);
    }

    public void setLeader(Player leader) {
        this._leader = leader;
        if (!this._members.contains(leader)) {
            this.addMember0(leader, null, true);
        } else {
            if (!leader.isMatchingRoomWindowOpened()) {
                leader.setMatchingRoomWindowOpened(true);
                leader.sendPacket(this.infoRoomPacket(), this.membersPacket(leader));
            }
            SystemMsg changeLeaderMessage = this.changeLeaderMessage();
            for (Player $member : this) {
                if (!$member.isMatchingRoomWindowOpened()) continue;
                $member.sendPacket(this.updateMemberPacket($member, leader), changeLeaderMessage);
            }
        }
    }

    public abstract SystemMsg notValidMessage();

    public abstract SystemMsg enterMessage();

    public abstract SystemMsg exitMessage(boolean var1, boolean var2);

    public abstract SystemMsg closeRoomMessage();

    public abstract SystemMsg changeLeaderMessage();

    public abstract L2GameServerPacket closeRoomPacket();

    public abstract L2GameServerPacket infoRoomPacket();

    public abstract L2GameServerPacket addMemberPacket(Player var1, Player var2);

    public abstract L2GameServerPacket removeMemberPacket(Player var1, Player var2);

    public abstract L2GameServerPacket updateMemberPacket(Player var1, Player var2);

    public abstract L2GameServerPacket membersPacket(Player var1);

    public abstract int getType();

    public abstract int getMemberType(Player var1);

    @Override
    public void broadCast(IBroadcastPacket ... arg) {
        for (Player player : this) {
            player.sendPacket(arg);
        }
    }

    public int getId() {
        return this._id;
    }

    public int getMinLevel() {
        return this._minLevel;
    }

    public int getMaxLevel() {
        return this._maxLevel;
    }

    public String getTopic() {
        return this._topic;
    }

    public int getMaxMembersSize() {
        return this._maxMemberSize;
    }

    public int getLocationId() {
        return MatchingRoomManager.getInstance().getLocation(this._leader);
    }

    public Player getLeader() {
        return this._leader;
    }

    public Collection<Player> getPlayers() {
        return this._members;
    }

    public int getLootType() {
        return this._lootType;
    }

    @Override
    public int getMemberCount() {
        return this.getPlayers().size();
    }

    @Override
    public Player getGroupLeader() {
        return this.getLeader();
    }

    @Override
    public Iterator<Player> iterator() {
        return this._members.iterator();
    }

    public void setMinLevel(int minLevel) {
        this._minLevel = minLevel;
    }

    public void setMaxLevel(int maxLevel) {
        this._maxLevel = maxLevel;
    }

    public void setTopic(String topic) {
        this._topic = topic;
    }

    public void setMaxMemberSize(int maxMemberSize) {
        this._maxMemberSize = maxMemberSize;
    }

    public void setLootType(int lootType) {
        this._lootType = lootType;
    }

    private class PartyListenerImpl
    implements OnPlayerPartyInviteListener,
    OnPlayerPartyLeaveListener {
        private PartyListenerImpl() {
        }

        @Override
        public void onPartyInvite(Player player) {
            MatchingRoom.this.broadcastPlayerUpdate(player);
        }

        @Override
        public void onPartyLeave(Player player) {
            MatchingRoom.this.broadcastPlayerUpdate(player);
        }
    }
}

