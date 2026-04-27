/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExNoticePostArrived
extends L2GameServerPacket {
    public static final L2GameServerPacket STATIC_TRUE = new ExNoticePostArrived(1);
    public static final L2GameServerPacket STATIC_FALSE = new ExNoticePostArrived(0);
    private int _anim;

    public ExNoticePostArrived(int useAnim) {
        this._anim = useAnim;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._anim);
    }
}

