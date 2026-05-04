/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExSubPledgetSkillAdd
extends L2GameServerPacket {
    private int _type;
    private int _id;
    private int _level;

    public ExSubPledgetSkillAdd(int type, int id, int level) {
        this._type = type;
        this._id = id;
        this._level = level;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._type);
        this.writeD(this._id);
        this.writeD(this._level);
    }
}

