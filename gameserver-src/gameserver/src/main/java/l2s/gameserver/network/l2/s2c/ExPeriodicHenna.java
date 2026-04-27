/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.Henna;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExPeriodicHenna
extends L2GameServerPacket {
    private final Henna _henna;
    private final boolean _active;

    public ExPeriodicHenna(Player player) {
        this._henna = player.getHennaList().getPremiumHenna();
        this._active = this._henna != null && player.getHennaList().isActive(this._henna);
    }

    @Override
    protected void writeImpl() {
        if (this._henna != null) {
            this.writeD(this._henna.getTemplate().getSymbolId());
            this.writeD(this._henna.getLeftTime());
            this.writeD(this._active);
        } else {
            this.writeD(0);
            this.writeD(0);
            this.writeD(0);
        }
    }
}

