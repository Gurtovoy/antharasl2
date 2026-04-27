/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class NpcHtmlMessagePacket
extends L2GameServerPacket {
    private final int _npcObjId;
    private final int _itemId;
    private final CharSequence _html;
    private final boolean _playVoice;

    public NpcHtmlMessagePacket(int npcObjId, int itemId, boolean playVoice, CharSequence html) {
        this._npcObjId = npcObjId;
        this._itemId = itemId;
        this._playVoice = playVoice;
        this._html = html;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._npcObjId);
        this.writeS(this._html);
        this.writeD(this._itemId);
        this.writeD(!this._playVoice);
    }
}

