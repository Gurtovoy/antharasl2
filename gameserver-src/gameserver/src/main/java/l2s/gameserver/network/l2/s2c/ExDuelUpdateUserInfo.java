package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExDuelUpdateUserInfo
extends L2GameServerPacket {
    private String _name;
    private int obj_id;
    private int class_id;
    private int level;
    private int curHp;
    private int maxHp;
    private int curMp;
    private int maxMp;
    private int curCp;
    private int maxCp;

    public ExDuelUpdateUserInfo(Player attacker) {
        this._name = attacker.getName();
        this.obj_id = attacker.getObjectId();
        this.class_id = attacker.getClassId().getId();
        this.level = attacker.getLevel();
        this.curHp = (int)attacker.getCurrentHp();
        this.maxHp = attacker.getMaxHp();
        this.curMp = (int)attacker.getCurrentMp();
        this.maxMp = attacker.getMaxMp();
        this.curCp = (int)attacker.getCurrentCp();
        this.maxCp = attacker.getMaxCp();
    }

    @Override
    protected final void writeImpl() {
        this.writeS(this._name);
        this.writeD(this.obj_id);
        this.writeD(this.class_id);
        this.writeD(this.level);
        this.writeD(this.curHp);
        this.writeD(this.maxHp);
        this.writeD(this.curMp);
        this.writeD(this.maxMp);
        this.writeD(this.curCp);
        this.writeD(this.maxCp);
    }
}

