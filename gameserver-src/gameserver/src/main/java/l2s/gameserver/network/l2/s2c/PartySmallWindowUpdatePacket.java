/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.network.l2.s2c.updatetype.PartySmallWindowUpdateType;

public class PartySmallWindowUpdatePacket
extends L2GameServerPacket {
    private int obj_id;
    private int class_id;
    private int level;
    private int curCp;
    private int maxCp;
    private int curHp;
    private int maxHp;
    private int curMp;
    private int maxMp;
    private int vitality;
    private String obj_name;
    private int _flags = 0;

    public PartySmallWindowUpdatePacket(Player member, boolean addAllFlags) {
        this.obj_id = member.getObjectId();
        this.obj_name = member.getName();
        this.curCp = (int)member.getCurrentCp();
        this.maxCp = member.getMaxCp();
        this.curHp = (int)member.getCurrentHp();
        this.maxHp = member.getMaxHp();
        this.curMp = (int)member.getCurrentMp();
        this.maxMp = member.getMaxMp();
        this.level = member.getLevel();
        this.class_id = member.getClassId().getId();
        if (addAllFlags) {
            for (PartySmallWindowUpdateType type : PartySmallWindowUpdateType.values()) {
                this.addUpdateType(type);
            }
        }
    }

    public PartySmallWindowUpdatePacket(Player member) {
        this(member, true);
    }

    public void addUpdateType(PartySmallWindowUpdateType type) {
        this._flags |= type.getMask();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this.obj_id);
        this.writeH(this._flags);
        if (PartySmallWindowUpdatePacket.containsMask(this._flags, PartySmallWindowUpdateType.CURRENT_CP)) {
            this.writeD(this.curCp);
        }
        if (PartySmallWindowUpdatePacket.containsMask(this._flags, PartySmallWindowUpdateType.MAX_CP)) {
            this.writeD(this.maxCp);
        }
        if (PartySmallWindowUpdatePacket.containsMask(this._flags, PartySmallWindowUpdateType.CURRENT_HP)) {
            this.writeD(this.curHp);
        }
        if (PartySmallWindowUpdatePacket.containsMask(this._flags, PartySmallWindowUpdateType.MAX_HP)) {
            this.writeD(this.maxHp);
        }
        if (PartySmallWindowUpdatePacket.containsMask(this._flags, PartySmallWindowUpdateType.CURRENT_MP)) {
            this.writeD(this.curMp);
        }
        if (PartySmallWindowUpdatePacket.containsMask(this._flags, PartySmallWindowUpdateType.MAX_MP)) {
            this.writeD(this.maxMp);
        }
        if (PartySmallWindowUpdatePacket.containsMask(this._flags, PartySmallWindowUpdateType.LEVEL)) {
            this.writeC(this.level);
        }
        if (PartySmallWindowUpdatePacket.containsMask(this._flags, PartySmallWindowUpdateType.CLASS_ID)) {
            this.writeH(this.class_id);
        }
        if (PartySmallWindowUpdatePacket.containsMask(this._flags, PartySmallWindowUpdateType.VITALITY_POINTS)) {
            this.writeD(0);
        }
    }
}

