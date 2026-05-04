/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Servitor;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExPartyPetWindowAdd
extends L2GameServerPacket {
    private final int ownerId;
    private final int npcId;
    private final int type;
    private final int curHp;
    private final int maxHp;
    private final int curMp;
    private final int maxMp;
    private final int level;
    private final int summonId;
    private final String name;

    public ExPartyPetWindowAdd(Servitor summon) {
        this.summonId = summon.getObjectId();
        this.ownerId = summon.getPlayer().getObjectId();
        this.npcId = summon.getNpcId() + 1000000;
        this.type = summon.getServitorType();
        this.name = summon.getName();
        this.curHp = (int)summon.getCurrentHp();
        this.maxHp = summon.getMaxHp();
        this.curMp = (int)summon.getCurrentMp();
        this.maxMp = summon.getMaxMp();
        this.level = summon.getLevel();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this.summonId);
        this.writeD(this.npcId);
        this.writeD(this.type);
        this.writeD(this.ownerId);
        this.writeS(this.name);
        this.writeD(this.curHp);
        this.writeD(this.maxHp);
        this.writeD(this.curMp);
        this.writeD(this.maxMp);
        this.writeD(this.level);
    }
}

