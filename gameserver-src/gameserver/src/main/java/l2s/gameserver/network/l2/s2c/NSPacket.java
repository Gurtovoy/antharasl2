package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.network.l2.components.ChatType;
import l2s.gameserver.network.l2.components.NpcString;
import l2s.gameserver.network.l2.s2c.NpcStringContainer;

public class NSPacket
extends NpcStringContainer {
    private int _objId;
    private int _type;
    private int _id;

    public NSPacket(NpcInstance npc, ChatType chatType, String text) {
        this(npc, chatType, NpcString.NONE, text);
    }

    public NSPacket(NpcInstance npc, ChatType chatType, NpcString npcString, String ... params) {
        super(npcString, params);
        this._objId = npc.getObjectId();
        this._id = npc.getTemplate().displayId > 0 ? npc.getTemplate().displayId : npc.getNpcId();
        this._type = chatType.ordinal();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._objId);
        this.writeD(this._type);
        this.writeD(1000000 + this._id);
        this.writeElements();
    }
}

