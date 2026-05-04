/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import java.util.Set;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.skills.AbnormalEffect;

public class ExUserInfoAbnormalVisualEffect
extends L2GameServerPacket {
    private final int _objectId;
    private final int _transformId;
    private final Set<AbnormalEffect> _abnormalEffects;

    public ExUserInfoAbnormalVisualEffect(Player player) {
        this._objectId = player.getObjectId();
        this._transformId = player.getVisualTransformId();
        this._abnormalEffects = player.getAbnormalEffects();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._objectId);
        this.writeD(this._transformId);
        this.writeD(this._abnormalEffects.size());
        for (AbnormalEffect abnormal : this._abnormalEffects) {
            this.writeH(abnormal.getId());
        }
    }
}

