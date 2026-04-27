/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.utils.PledgeBonusUtils;

public class ExPledgeBonusList
extends L2GameServerPacket {
    @Override
    protected final void writeImpl() {
        this.writeC(0);
        this.writeD(PledgeBonusUtils.ATTENDANCE_REWARDS.get(1));
        this.writeD(PledgeBonusUtils.ATTENDANCE_REWARDS.get(2));
        this.writeD(PledgeBonusUtils.ATTENDANCE_REWARDS.get(3));
        this.writeD(PledgeBonusUtils.ATTENDANCE_REWARDS.get(4));
        this.writeC(1);
        this.writeD(PledgeBonusUtils.HUNTING_REWARDS.get(1));
        this.writeD(PledgeBonusUtils.HUNTING_REWARDS.get(2));
        this.writeD(PledgeBonusUtils.HUNTING_REWARDS.get(3));
        this.writeD(PledgeBonusUtils.HUNTING_REWARDS.get(4));
    }
}

