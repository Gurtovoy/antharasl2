package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExRegenMaxPacket
extends L2GameServerPacket {
    private double _max;
    private int _count;
    private int _time;
    public static final int POTION_HEALING_GREATER = 16457;
    public static final int POTION_HEALING_MEDIUM = 16440;
    public static final int POTION_HEALING_LESSER = 16416;

    public ExRegenMaxPacket(double max, int count, int time) {
        this._max = max * 0.66;
        this._count = count;
        this._time = time;
    }

    @Override
    protected void writeImpl() {
        this.writeD(1);
        this.writeD(this._count);
        this.writeD(this._time);
        this.writeF(this._max);
    }
}

