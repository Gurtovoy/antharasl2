package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.components.NpcString;
import l2s.gameserver.network.l2.s2c.NpcStringContainer;

public class ExSendUIEventPacket
extends NpcStringContainer {
    private final int _objectId;
    private final int _type;
    private final int _countUp;
    private final int _startTime;
    private final int _startTime2;
    private final int _endTime;
    private final int _endTime2;

    public ExSendUIEventPacket(Player player, boolean hide, boolean increase, int startTime, int endTime, String ... params) {
        this(player, hide ? 1 : 0, increase ? 1 : 0, startTime, endTime, params);
    }

    public ExSendUIEventPacket(Player player, boolean hide, boolean increase, int startTime, int endTime, NpcString npcString, String ... params) {
        this(player, hide ? 1 : 0, increase ? 1 : 0, startTime, endTime, npcString, params);
    }

    public ExSendUIEventPacket(Player player, int type, int countUp, int startTime, int endTime, String ... params) {
        this(player, type, countUp, startTime / 60, startTime % 60, endTime / 60, endTime % 60, NpcString.NONE, params);
    }

    public ExSendUIEventPacket(Player player, int type, int countUp, int startTime, int endTime, NpcString npcString, String ... params) {
        this(player, type, countUp, startTime / 60, startTime % 60, endTime / 60, endTime % 60, npcString, params);
    }

    public ExSendUIEventPacket(Player player, int type, int countUp, int startTime, int startTime2, int endTime, int endTime2, String ... params) {
        this(player, type, countUp, startTime, startTime2, endTime, endTime2, NpcString.NONE, params);
    }

    public ExSendUIEventPacket(Player player, int type, int countUp, int startTime, int startTime2, int endTime, int endTime2, NpcString npcString, String ... params) {
        super(npcString, params);
        this._objectId = player.getObjectId();
        this._type = type;
        this._countUp = countUp;
        this._startTime = startTime;
        this._startTime2 = startTime2;
        this._endTime = endTime;
        this._endTime2 = endTime2;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._objectId);
        this.writeD(this._type);
        this.writeD(0);
        this.writeD(0);
        this.writeS(String.valueOf(this._countUp));
        this.writeS(String.valueOf(this._startTime));
        this.writeS(String.valueOf(this._startTime2));
        this.writeS(String.valueOf(this._endTime));
        this.writeS(String.valueOf(this._endTime2));
        this.writeElements();
    }
}

