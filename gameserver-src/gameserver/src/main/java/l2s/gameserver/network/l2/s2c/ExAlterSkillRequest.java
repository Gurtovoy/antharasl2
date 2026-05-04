/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExAlterSkillRequest
extends L2GameServerPacket {
    private final int _activeId;
    private final int _requestId;
    private final int _duration;

    public ExAlterSkillRequest(int requestId, int activeId, int duration) {
        this._requestId = requestId;
        this._activeId = activeId;
        this._duration = duration;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._requestId);
        this.writeD(this._activeId);
        this.writeD(this._duration);
    }
}

