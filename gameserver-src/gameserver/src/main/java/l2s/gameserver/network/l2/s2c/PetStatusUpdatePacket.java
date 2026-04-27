/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PetStatusUpdatePacket
extends L2GameServerPacket {
    private int type;
    private int obj_id;
    private int level;
    private int maxFed;
    private int curFed;
    private int maxHp;
    private int curHp;
    private int maxMp;
    private int curMp;
    private long exp;
    private long exp_this_lvl;
    private long exp_next_lvl;
    private Location _loc;
    private String title;

    public PetStatusUpdatePacket(Servitor summon) {
        this.type = summon.getServitorType();
        this.obj_id = summon.getObjectId();
        this._loc = summon.getLoc();
        this.title = summon.getVisibleName(summon.getPlayer());
        this.curHp = (int)summon.getCurrentHp();
        this.maxHp = summon.getMaxHp();
        this.curMp = (int)summon.getCurrentMp();
        this.maxMp = summon.getMaxMp();
        this.curFed = summon.getCurrentFed();
        this.maxFed = summon.getMaxFed();
        this.level = summon.getLevel();
        this.exp = summon.getExp();
        this.exp_this_lvl = summon.getExpForThisLevel();
        this.exp_next_lvl = summon.getExpForNextLevel();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this.type);
        this.writeD(this.obj_id);
        this.writeD(this._loc.x);
        this.writeD(this._loc.y);
        this.writeD(this._loc.z);
        this.writeS(this.title);
        this.writeD(this.curFed);
        this.writeD(this.maxFed);
        this.writeD(this.curHp);
        this.writeD(this.maxHp);
        this.writeD(this.curMp);
        this.writeD(this.maxMp);
        this.writeD(this.level);
        this.writeQ(this.exp);
        this.writeQ(this.exp_this_lvl);
        this.writeQ(this.exp_next_lvl);
        this.writeD(1);
    }
}

