/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Creature;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExFishingStartCombatPacket
extends L2GameServerPacket {
    int _time;
    int _hp;
    int _lureType;
    int _deceptiveMode;
    int _mode;
    private int char_obj_id;

    public ExFishingStartCombatPacket(Creature character, int time, int hp, int mode, int lureType, int deceptiveMode) {
        this.char_obj_id = character.getObjectId();
        this._time = time;
        this._hp = hp;
        this._mode = mode;
        this._lureType = lureType;
        this._deceptiveMode = deceptiveMode;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this.char_obj_id);
        this.writeD(this._time);
        this.writeD(this._hp);
        this.writeC(this._mode);
        this.writeC(this._lureType);
        this.writeC(this._deceptiveMode);
    }
}

