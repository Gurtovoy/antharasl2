/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExOlympiadUserInfoPacket
extends L2GameServerPacket {
    private int _side;
    private int class_id;
    private int curHp;
    private int maxHp;
    private int curCp;
    private int maxCp;
    private int obj_id = 0;
    private String _name;

    public ExOlympiadUserInfoPacket(Player player, int side) {
        this._side = side;
        this.obj_id = player.getObjectId();
        this.class_id = player.getClassId().getId();
        this._name = player.getName();
        this.curHp = (int)player.getCurrentHp();
        this.maxHp = player.getMaxHp();
        this.curCp = (int)player.getCurrentCp();
        this.maxCp = player.getMaxCp();
    }

    @Override
    protected final void writeImpl() {
        this.writeC(this._side);
        this.writeD(this.obj_id);
        this.writeS(this._name);
        this.writeD(this.class_id);
        this.writeD(this.curHp);
        this.writeD(this.maxHp);
        this.writeD(this.curCp);
        this.writeD(this.maxCp);
    }
}

