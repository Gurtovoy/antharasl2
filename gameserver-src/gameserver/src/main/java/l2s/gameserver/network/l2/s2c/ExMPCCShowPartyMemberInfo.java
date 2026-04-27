/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.model.Party;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExMPCCShowPartyMemberInfo
extends L2GameServerPacket {
    private List<PartyMemberInfo> members = new ArrayList<PartyMemberInfo>();

    public ExMPCCShowPartyMemberInfo(Party party) {
        for (Player _member : party.getPartyMembers()) {
            this.members.add(new PartyMemberInfo(_member.getName(), _member.getObjectId(), _member.getClassId().getId()));
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this.members.size());
        for (PartyMemberInfo member : this.members) {
            this.writeS(member.name);
            this.writeD(member.object_id);
            this.writeD(member.class_id);
        }
        this.members.clear();
    }

    static class PartyMemberInfo {
        public String name;
        public int object_id;
        public int class_id;

        public PartyMemberInfo(String _name, int _object_id, int _class_id) {
            this.name = _name;
            this.object_id = _object_id;
            this.class_id = _class_id;
        }
    }
}

