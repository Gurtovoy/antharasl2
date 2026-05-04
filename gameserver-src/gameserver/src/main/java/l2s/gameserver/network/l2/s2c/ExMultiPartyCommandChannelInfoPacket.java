package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.model.CommandChannel;
import l2s.gameserver.model.Party;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExMultiPartyCommandChannelInfoPacket
extends L2GameServerPacket {
    private String ChannelLeaderName;
    private int MemberCount;
    private List<ChannelPartyInfo> parties;

    public ExMultiPartyCommandChannelInfoPacket(CommandChannel channel) {
        this.ChannelLeaderName = channel.getChannelLeader().getName();
        this.MemberCount = channel.getMemberCount();
        this.parties = new ArrayList<ChannelPartyInfo>();
        for (Party party : channel.getParties()) {
            Player leader = party.getPartyLeader();
            if (leader == null) continue;
            this.parties.add(new ChannelPartyInfo(leader.getName(), leader.getObjectId(), party.getMemberCount()));
        }
    }

    @Override
    protected void writeImpl() {
        this.writeS(this.ChannelLeaderName);
        this.writeD(0);
        this.writeD(this.MemberCount);
        this.writeD(this.parties.size());
        for (ChannelPartyInfo party : this.parties) {
            this.writeS(party.Leader_name);
            this.writeD(party.Leader_obj_id);
            this.writeD(party.MemberCount);
        }
    }

    static class ChannelPartyInfo {
        public String Leader_name;
        public int Leader_obj_id;
        public int MemberCount;

        public ChannelPartyInfo(String _Leader_name, int _Leader_obj_id, int _MemberCount) {
            this.Leader_name = _Leader_name;
            this.Leader_obj_id = _Leader_obj_id;
            this.MemberCount = _MemberCount;
        }
    }
}

