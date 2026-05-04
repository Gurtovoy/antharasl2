/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ShortBuffStatusUpdatePacket
extends L2GameServerPacket {
    int _skillId;
    int _skillLevel;
    int _skillDuration;

    public ShortBuffStatusUpdatePacket(Abnormal effect) {
        this._skillId = effect.getSkill().getDisplayId();
        this._skillLevel = effect.getSkill().getDisplayLevel();
        this._skillDuration = effect.getTimeLeft();
    }

    public ShortBuffStatusUpdatePacket() {
        this._skillId = 0;
        this._skillLevel = 0;
        this._skillDuration = 0;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._skillId);
        this.writeD(this._skillLevel);
        this.writeD(this._skillDuration);
    }
}

