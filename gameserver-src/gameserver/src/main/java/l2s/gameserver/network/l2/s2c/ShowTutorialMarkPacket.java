/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ShowTutorialMarkPacket
extends L2GameServerPacket {
    private boolean _quest;
    private int _tutorialId;

    public ShowTutorialMarkPacket(boolean quest, int tutorialId) {
        this._quest = quest;
        this._tutorialId = tutorialId;
    }

    @Override
    protected final void writeImpl() {
        this.writeC(this._quest);
        this.writeD(this._tutorialId);
    }
}

