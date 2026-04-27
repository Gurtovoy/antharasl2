/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class StopAllianceWar
extends L2GameServerPacket {
    private String _allianceName;
    private String _char;

    public StopAllianceWar(String alliance, String charName) {
        this._allianceName = alliance;
        this._char = charName;
    }

    @Override
    protected final void writeImpl() {
        this.writeS(this._allianceName);
        this.writeS(this._char);
    }
}

