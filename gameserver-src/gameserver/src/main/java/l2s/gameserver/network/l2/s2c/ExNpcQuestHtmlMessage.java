package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExNpcQuestHtmlMessage
extends L2GameServerPacket {
    private int _npcObjId;
    private CharSequence _html;
    private int _questId;

    public ExNpcQuestHtmlMessage(int npcObjId, CharSequence html, int questId) {
        this._npcObjId = npcObjId;
        this._html = html;
        this._questId = questId;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._npcObjId);
        this.writeS(this._html);
        this.writeD(this._questId);
    }
}

