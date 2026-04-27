/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.pledge.SubUnit;
import l2s.gameserver.model.pledge.UnitMember;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PledgeShowMemberListUpdatePacket
extends L2GameServerPacket {
    private String _name;
    private int _lvl;
    private int _classId;
    private int _sex;
    private int _isOnline;
    private int _objectId;
    private int _pledgeType;
    private int _isApprentice;
    private int _attendance;

    public PledgeShowMemberListUpdatePacket(Player player) {
        UnitMember member;
        this._name = player.getName();
        this._lvl = player.getLevel();
        this._classId = player.getClassId().getId();
        this._sex = player.getSex().ordinal();
        this._objectId = player.getObjectId();
        this._isOnline = player.isOnline() ? 1 : 0;
        this._pledgeType = player.getPledgeType();
        SubUnit subUnit = player.getSubUnit();
        UnitMember unitMember = member = subUnit == null ? null : subUnit.getUnitMember(this._objectId);
        if (member != null) {
            this._isApprentice = member.hasSponsor() ? 1 : 0;
            this._attendance = member.getAttendanceType().ordinal();
        }
    }

    public PledgeShowMemberListUpdatePacket(UnitMember cm) {
        this._name = cm.getName();
        this._lvl = cm.getLevel();
        this._classId = cm.getClassId();
        this._sex = cm.getSex();
        this._objectId = cm.getObjectId();
        this._isOnline = cm.isOnline() ? 1 : 0;
        this._pledgeType = cm.getPledgeType();
        this._isApprentice = cm.hasSponsor() ? 1 : 0;
        this._attendance = cm.getAttendanceType().ordinal();
    }

    @Override
    protected final void writeImpl() {
        this.writeS(this._name);
        this.writeD(this._lvl);
        this.writeD(this._classId);
        this.writeD(this._sex);
        this.writeD(this._objectId);
        this.writeD(this._isOnline);
        this.writeD(this._pledgeType);
        this.writeD(this._isApprentice);
        this.writeC(this._attendance);
    }
}

