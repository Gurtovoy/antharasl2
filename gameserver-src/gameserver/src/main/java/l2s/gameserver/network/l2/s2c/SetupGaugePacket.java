package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Creature;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class SetupGaugePacket
extends L2GameServerPacket {
    private int _charId;
    private int _color;
    private int _time;
    private int _lostTime;

    public SetupGaugePacket(Creature character, Colors color, int time) {
        this(character, color, time, time);
    }

    public SetupGaugePacket(Creature character, Colors color, int time, int lostTime) {
        this._charId = character.getObjectId();
        this._color = color.ordinal();
        this._time = time;
        this._lostTime = lostTime;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._charId);
        this.writeD(this._color);
        this.writeD(this._lostTime);
        this.writeD(this._time);
    }

    public static enum Colors {
        NONE,
        RED,
        BLUE,
        GREEN;

    }
}

