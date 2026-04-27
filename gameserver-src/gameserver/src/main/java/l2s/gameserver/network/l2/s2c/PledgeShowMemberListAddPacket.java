/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.pledge.UnitMember;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PledgeShowMemberListAddPacket
extends L2GameServerPacket {
    private PledgePacketMember _member;

    public PledgeShowMemberListAddPacket(UnitMember member) {
        this._member = new PledgePacketMember(member);
    }

    @Override
    protected final void writeImpl() {
        this.writeS(this._member._name);
        this.writeD(this._member._level);
        this.writeD(this._member._classId);
        this.writeD(this._member._sex);
        this.writeD(this._member._race);
        this.writeD(this._member._online);
        this.writeD(this._member._pledgeType);
        this.writeC(this._member._attendance);
    }

    private class PledgePacketMember {
        private String _name;
        private int _level;
        private int _classId;
        private int _sex;
        private int _race;
        private int _online;
        private int _pledgeType;
        private int _attendance;

        public PledgePacketMember(UnitMember m) {
            this._name = m.getName();
            this._level = m.getLevel();
            this._classId = m.getClassId();
            this._sex = m.getSex();
            this._race = 0;
            this._online = m.isOnline() ? m.getObjectId() : 0;
            this._pledgeType = m.getPledgeType();
            this._attendance = m.getAttendanceType().ordinal();
        }
    }
}

