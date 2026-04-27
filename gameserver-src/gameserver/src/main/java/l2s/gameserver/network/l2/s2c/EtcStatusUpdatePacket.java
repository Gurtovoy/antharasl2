/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class EtcStatusUpdatePacket
extends L2GameServerPacket {
    private static final int NO_CHAT_FLAG = 1;
    private static final int DANGER_AREA_FLAG = 2;
    private static final int CHARM_OF_COURAGE_FLAG = 4;
    private int _increasedForce;
    private int _weightPenalty;
    private int _weaponPenalty;
    private int _armorPenalty;
    private int _flags;

    public EtcStatusUpdatePacket(Player player) {
        this._increasedForce = player.getIncreasedForce();
        this._weightPenalty = player.getWeightPenalty();
        this._weaponPenalty = player.getWeaponsExpertisePenalty();
        this._armorPenalty = player.getArmorsExpertisePenalty();
        if (player.getMessageRefusal() || player.getNoChannel() != 0L || player.isBlockAll()) {
            this._flags |= 1;
        }
        if (player.isInDangerArea()) {
            this._flags |= 2;
        }
        if (player.isCharmOfCourage()) {
            this._flags |= 4;
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeC(this._increasedForce);
        this.writeD(this._weightPenalty);
        this.writeC(this._weaponPenalty);
        this.writeC(this._armorPenalty);
        this.writeC(0);
        this.writeC(0);
        this.writeC(this._flags);
    }
}

