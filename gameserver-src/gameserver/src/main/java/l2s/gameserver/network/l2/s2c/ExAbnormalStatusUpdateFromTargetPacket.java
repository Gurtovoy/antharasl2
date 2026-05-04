/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExAbnormalStatusUpdateFromTargetPacket
extends L2GameServerPacket {
    public static final int INFINITIVE_EFFECT = -1;
    private List<Abnormal> _effects;
    private int _objectId;

    public ExAbnormalStatusUpdateFromTargetPacket(int objId) {
        this._objectId = objId;
        this._effects = new ArrayList<Abnormal>();
    }

    public void addEffect(int effectorObjectId, int skillId, int skillLvl, int abnormalType, int duration) {
        this._effects.add(new Abnormal(effectorObjectId, skillId, skillLvl, abnormalType, duration));
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._objectId);
        this.writeH(this._effects.size());
        for (Abnormal temp : this._effects) {
            this.writeD(temp.skillId);
            this.writeH(temp.skillLvl);
            this.writeH(temp.abnormalType);
            this.writeOptionalD(temp.duration);
            this.writeD(temp.effectorObjectId);
        }
    }

    private static class Abnormal {
        public int effectorObjectId;
        public int skillId;
        public int skillLvl;
        public int abnormalType;
        public int duration;

        public Abnormal(int effectorObjectId, int skillId, int skillLvl, int abnormalType, int duration) {
            this.effectorObjectId = effectorObjectId;
            this.skillId = skillId;
            this.skillLvl = skillLvl;
            this.abnormalType = abnormalType;
            this.duration = duration;
        }
    }
}

