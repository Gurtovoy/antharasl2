/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.model.Creature;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class StatusUpdatePacket
extends L2GameServerPacket {
    public static final int CUR_HP = 9;
    public static final int MAX_HP = 10;
    public static final int CUR_MP = 11;
    public static final int MAX_MP = 12;
    public static final int CUR_LOAD = 14;
    public static final int MAX_LOAD = 15;
    public static final int PVP_FLAG = 26;
    public static final int KARMA = 27;
    public static final int CUR_CP = 33;
    public static final int MAX_CP = 34;
    private final UpdateType _updateType;
    private final int _objectId;
    private final int _receiverId;
    private final List<Attribute> _attributes = new ArrayList<Attribute>();

    public StatusUpdatePacket(UpdateType updateType, Creature creature) {
        this._updateType = updateType;
        this._objectId = creature.getObjectId();
        this._receiverId = 0;
    }

    public StatusUpdatePacket(UpdateType updateType, Creature creature, Creature receiver) {
        this._updateType = updateType;
        this._objectId = creature.getObjectId();
        this._receiverId = receiver == null ? 0 : receiver.getObjectId();
    }

    public StatusUpdatePacket addAttribute(int id, int level) {
        this._attributes.add(new Attribute(id, level));
        return this;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._objectId);
        this.writeD(this._receiverId);
        this.writeC(this._updateType.ordinal());
        this.writeC(this._attributes.size());
        for (Attribute temp : this._attributes) {
            this.writeC(temp.id);
            this.writeD(temp.value);
        }
    }

    public boolean hasAttributes() {
        return !this._attributes.isEmpty();
    }

    class Attribute {
        public final int id;
        public final int value;

        Attribute(int id, int value) {
            this.id = id;
            this.value = value;
        }
    }

    public static enum UpdateType {
        DEFAULT,
        REGEN,
        ON_PLAYER_INIT,
        CONSUME,
        UNK_4,
        UNK_5,
        DAMAGED;

    }
}

