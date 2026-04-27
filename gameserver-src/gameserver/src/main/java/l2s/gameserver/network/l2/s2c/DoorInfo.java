/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.instances.DoorInstance;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class DoorInfo
extends L2GameServerPacket {
    private int obj_id;
    private int door_id;
    private int view_hp;

    public DoorInfo(DoorInstance door) {
        this.obj_id = door.getObjectId();
        this.door_id = door.getDoorId();
        this.view_hp = door.isHPVisible() ? 1 : 0;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this.obj_id);
        this.writeD(this.door_id);
        this.writeD(this.view_hp);
    }
}

