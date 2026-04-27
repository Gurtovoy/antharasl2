/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Creature;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class NpcInfoState
extends L2GameServerPacket {
    private static final int IS_DEAD = 1;
    private static final int IS_IN_COMBAT = 2;
    private static final int IS_RUNNING = 4;
    private final int _objectId;
    private int _state;

    public NpcInfoState(Creature npc) {
        this._objectId = npc.getObjectId();
        if (npc.isAlikeDead()) {
            this._state |= 1;
        }
        if (npc.isInCombat()) {
            this._state |= 2;
        }
        if (npc.isRunning()) {
            this._state |= 4;
        }
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._objectId);
        this.writeC(this._state);
    }
}

