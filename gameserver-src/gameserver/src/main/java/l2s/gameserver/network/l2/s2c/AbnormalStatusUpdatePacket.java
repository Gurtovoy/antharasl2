/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class AbnormalStatusUpdatePacket
extends L2GameServerPacket {
    public static final int INFINITIVE_EFFECT = -1;
    private List<Abnormal> _effects = new ArrayList<Abnormal>();

    public void addEffect(int skillId, int dat, int abnormalType, int duration) {
        this._effects.add(new Abnormal(skillId, dat, abnormalType, duration));
    }

    @Override
    protected final void writeImpl() {
        this.writeH(this._effects.size());
        for (Abnormal temp : this._effects) {
            this.writeD(temp.skillId);
            this.writeH(temp.dat);
            this.writeD(temp.abnormalType);
            this.writeOptionalD(temp.duration);
        }
    }

    class Abnormal {
        int skillId;
        int dat;
        int abnormalType;
        int duration;

        public Abnormal(int skillId, int dat, int abnormalType, int duration) {
            this.skillId = skillId;
            this.dat = dat;
            this.abnormalType = abnormalType;
            this.duration = duration;
        }
    }
}

