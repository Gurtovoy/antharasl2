package l2s.gameserver.model;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import l2s.commons.collections.JoinedIterator;
import l2s.gameserver.model.Party;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.PlayerGroup;
import l2s.gameserver.model.instances.NpcFriendInstance;
import l2s.gameserver.model.matching.MatchingRoom;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExCloseMPCCPacket;
import l2s.gameserver.network.l2.s2c.ExMPCCPartyInfoUpdate;
import l2s.gameserver.network.l2.s2c.ExOpenMPCCPacket;
import l2s.gameserver.network.l2.s2c.SystemMessage;

public class CommandChannel
implements PlayerGroup {
    public static final int STRATEGY_GUIDE_ID = 8871;
    public static final int CLAN_IMPERIUM_ID = 391;
    private final List<Party> _commandChannelParties = new CopyOnWriteArrayList<Party>();
    private Player _commandChannelLeader;
    private int _commandChannelLvl;
    private MatchingRoom _matchingRoom;

    public CommandChannel(Player leader) {
        this._commandChannelLeader = leader;
        this._commandChannelParties.add(leader.getParty());
        this._commandChannelLvl = leader.getParty().getLevel();
        leader.getParty().setCommandChannel(this);
        this.broadCast(ExOpenMPCCPacket.STATIC);
    }

    public void addParty(Party party) {
        this.broadCast(new ExMPCCPartyInfoUpdate(party, 1));
        this._commandChannelParties.add(party);
        this.refreshLevel();
        party.setCommandChannel(this);
        for (Player $member : party) {
            $member.sendPacket((IBroadcastPacket)ExOpenMPCCPacket.STATIC);
            if (this._matchingRoom == null) continue;
            this._matchingRoom.broadcastPlayerUpdate($member);
        }
    }

    public void removeParty(Party party) {
        this._commandChannelParties.remove(party);
        this.refreshLevel();
        party.setCommandChannel(null);
        party.broadCast(ExCloseMPCCPacket.STATIC);
        if (this._commandChannelParties.size() < 2) {
            this.disbandChannel();
        } else {
            for (Player $member : party) {
                $member.sendPacket((IBroadcastPacket)new ExMPCCPartyInfoUpdate(party, 0));
                if (this._matchingRoom == null) continue;
                this._matchingRoom.broadcastPlayerUpdate($member);
            }
        }
    }

    public void disbandChannel() {
        this.broadCast(SystemMsg.THE_COMMAND_CHANNEL_HAS_BEEN_DISBANDED);
        for (Party party : this._commandChannelParties) {
            party.setCommandChannel(null);
            party.broadCast(ExCloseMPCCPacket.STATIC);
        }
        if (this._matchingRoom != null) {
            this._matchingRoom.disband();
        }
        this._commandChannelParties.clear();
        this._commandChannelLeader = null;
    }

    @Override
    public int getMemberCount() {
        int count = 0;
        for (Party party : this._commandChannelParties) {
            count += party.getMemberCount();
        }
        return count;
    }

    @Override
    public void broadCast(IBroadcastPacket ... gsp) {
        for (Party party : this._commandChannelParties) {
            party.broadCast(gsp);
        }
    }

    public void broadcastToChannelPartyLeaders(IBroadcastPacket gsp) {
        for (Party party : this._commandChannelParties) {
            Player leader = party.getPartyLeader();
            if (leader == null) continue;
            leader.sendPacket(gsp);
        }
    }

    public List<Party> getParties() {
        return this._commandChannelParties;
    }

    public List<Player> getMembers() {
        ArrayList<Player> members = new ArrayList<Player>(this._commandChannelParties.size());
        for (Party party : this.getParties()) {
            members.addAll(party.getPartyMembers());
        }
        return members;
    }

    @Override
    public Player getGroupLeader() {
        return this.getChannelLeader();
    }

    @Override
    public Iterator<Player> iterator() {
        ArrayList<Iterator<Player>> iterators = new ArrayList<Iterator<Player>>(this._commandChannelParties.size());
        for (Party p : this.getParties()) {
            iterators.add(p.getPartyMembers().iterator());
        }
        return new JoinedIterator(iterators);
    }

    public int getLevel() {
        return this._commandChannelLvl;
    }

    public void setChannelLeader(Player newLeader) {
        this._commandChannelLeader = newLeader;
        this.broadCast(new SystemMessage(1589).addString(newLeader.getName()));
    }

    public Player getChannelLeader() {
        return this._commandChannelLeader;
    }

    public boolean isLeaderCommandChannel(Player player) {
        return this._commandChannelLeader == player;
    }

    public boolean meetRaidWarCondition(NpcFriendInstance npc) {
        if (!npc.isRaid()) {
            return false;
        }
        int npcId = npc.getNpcId();
        switch (npcId) {
            case 29001: 
            case 29006: 
            case 29014: 
            case 29022: {
                return this.getMemberCount() > 36;
            }
            case 29020: {
                return this.getMemberCount() > 56;
            }
            case 29019: {
                return this.getMemberCount() > 225;
            }
            case 29028: {
                return this.getMemberCount() > 99;
            }
        }
        return this.getMemberCount() > 18;
    }

    private void refreshLevel() {
        this._commandChannelLvl = 0;
        for (Party pty : this._commandChannelParties) {
            if (pty.getLevel() <= this._commandChannelLvl) continue;
            this._commandChannelLvl = pty.getLevel();
        }
    }

    public static boolean checkAuthority(Player creator) {
        Party party = creator.getParty();
        if (party == null || !party.isLeader(creator)) {
            creator.sendPacket((IBroadcastPacket)SystemMsg.YOU_DO_NOT_HAVE_AUTHORITY_TO_INVITE_SOMEONE_TO_THE_COMMAND_CHANNEL);
            return false;
        }
        if (creator.getInventory().getItemByItemId(8871) == null) {
            if (creator.isClanLeader()) {
                if (creator.getSkillLevel(391) <= 0) {
                    creator.sendPacket((IBroadcastPacket)SystemMsg.YOU_CAN_NO_LONGER_SET_UP_A_COMMAND_CHANNEL);
                    return false;
                }
            } else {
                creator.sendPacket((IBroadcastPacket)SystemMsg.COMMAND_CHANNELS_CAN_ONLY_BE_FORMED_BY_A_PARTY_LEADER_WHO_IS_ALSO_THE_LEADER_OF_A_LEVEL_5_CLAN);
                return false;
            }
        }
        return true;
    }

    public MatchingRoom getMatchingRoom() {
        return this._matchingRoom;
    }

    public void setMatchingRoom(MatchingRoom matchingRoom) {
        this._matchingRoom = matchingRoom;
    }
}

