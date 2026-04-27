/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c.updatetype;

import l2s.gameserver.network.l2.s2c.updatetype.IUpdateTypeComponent;

public enum PartySmallWindowUpdateType implements IUpdateTypeComponent
{
    CURRENT_CP(1),
    MAX_CP(2),
    CURRENT_HP(4),
    MAX_HP(8),
    CURRENT_MP(16),
    MAX_MP(32),
    LEVEL(64),
    CLASS_ID(128),
    VITALITY_POINTS(256);

    private final int _mask;

    private PartySmallWindowUpdateType(int mask) {
        this._mask = mask;
    }

    @Override
    public int getMask() {
        return this._mask;
    }
}

