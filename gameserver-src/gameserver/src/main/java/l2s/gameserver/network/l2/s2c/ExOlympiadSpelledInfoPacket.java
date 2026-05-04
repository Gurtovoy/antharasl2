/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExOlympiadSpelledInfoPacket
extends L2GameServerPacket {
    private int char_obj_id = 0;
    private List<Abnormal> _effects = new ArrayList<Abnormal>();

    public void addEffect(int skillId, int dat, int abnormalType, int duration) {
        this._effects.add(new Abnormal(skillId, dat, abnormalType, duration));
    }

    public void addSpellRecivedPlayer(Player cha) {
        if (cha != null) {
            this.char_obj_id = cha.getObjectId();
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this.char_obj_id);
        this.writeD(this._effects.size());
        for (Abnormal temp : this._effects) {
            this.writeD(temp.skillId);
            this.writeH(temp.dat);
            this.writeD(temp.abnormalType);
            this.writeOptionalD(temp.duration);
        }
    }

    class Abnormal {
        int skillId;
        int dat;
        int abnormalType;
        int duration;

        public Abnormal(int skillId, int dat, int abnormalType, int duration) {
            this.skillId = skillId;
            this.dat = dat;
            this.abnormalType = abnormalType;
            this.duration = duration;
        }
    }
}

