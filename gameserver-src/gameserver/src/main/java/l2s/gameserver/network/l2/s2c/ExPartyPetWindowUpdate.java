/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Servitor;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExPartyPetWindowUpdate
extends L2GameServerPacket {
    private int owner_obj_id;
    private int npc_id;
    private int _type;
    private int curHp;
    private int maxHp;
    private int curMp;
    private int maxMp;
    private int level;
    private int obj_id = 0;
    private String _name;

    public ExPartyPetWindowUpdate(Servitor summon) {
        this.obj_id = summon.getObjectId();
        this.owner_obj_id = summon.getPlayer().getObjectId();
        this.npc_id = summon.getNpcId() + 1000000;
        this._type = summon.getServitorType();
        this._name = summon.getName();
        this.curHp = (int)summon.getCurrentHp();
        this.maxHp = summon.getMaxHp();
        this.curMp = (int)summon.getCurrentMp();
        this.maxMp = summon.getMaxMp();
        this.level = summon.getLevel();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this.obj_id);
        this.writeD(this.npc_id);
        this.writeD(this._type);
        this.writeD(this.owner_obj_id);
        this.writeS(this._name);
        this.writeD(this.curHp);
        this.writeD(this.maxHp);
        this.writeD(this.curMp);
        this.writeD(this.maxMp);
        this.writeD(this.level);
    }
}

