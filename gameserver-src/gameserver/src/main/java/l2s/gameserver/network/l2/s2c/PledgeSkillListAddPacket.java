/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PledgeSkillListAddPacket
extends L2GameServerPacket {
    private int _skillId;
    private int _skillLevel;

    public PledgeSkillListAddPacket(int skillId, int skillLevel) {
        this._skillId = skillId;
        this._skillLevel = skillLevel;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._skillId);
        this.writeD(this._skillLevel);
    }
}

