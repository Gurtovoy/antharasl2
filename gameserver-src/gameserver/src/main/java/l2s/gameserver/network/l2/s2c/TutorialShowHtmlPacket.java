package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class TutorialShowHtmlPacket
extends L2GameServerPacket {
    public static int NORMAL_WINDOW = 1;
    public static int LARGE_WINDOW = 2;
    private int _windowType;
    private String _html;

    public TutorialShowHtmlPacket(int windowType, String html) {
        this._windowType = windowType;
        this._html = html;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._windowType);
        this.writeS(this._html);
    }
}

