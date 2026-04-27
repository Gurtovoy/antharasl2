/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.pledge.UnitMember;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PledgeReceiveMemberInfo
extends L2GameServerPacket {
    private UnitMember _member;

    public PledgeReceiveMemberInfo(UnitMember member) {
        this._member = member;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._member.getPledgeType());
        this.writeS(this._member.getName());
        this.writeS(this._member.getTitle());
        this.writeD(this._member.getPowerGrade());
        this.writeS(this._member.getSubUnit().getName());
        this.writeS(this._member.getRelatedName());
    }
}

