/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import java.util.Set;
import l2s.gameserver.model.Creature;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.skills.AbnormalEffect;

public class NpcInfoAbnormalVisualEffect
extends L2GameServerPacket {
    private final int _objectId;
    private final int _transformId;
    private final Set<AbnormalEffect> _abnormalEffects;

    public NpcInfoAbnormalVisualEffect(Creature npc) {
        this._objectId = npc.getObjectId();
        this._transformId = npc.getVisualTransformId();
        this._abnormalEffects = npc.getAbnormalEffects();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._objectId);
        this.writeD(this._transformId);
        this.writeH(this._abnormalEffects.size());
        for (AbnormalEffect abnormal : this._abnormalEffects) {
            this.writeH(abnormal.getId());
        }
    }
}

