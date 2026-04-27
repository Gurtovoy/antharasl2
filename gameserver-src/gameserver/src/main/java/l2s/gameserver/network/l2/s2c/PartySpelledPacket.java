/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import l2s.gameserver.model.Playable;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.utils.AbnormalsComparator;

public class PartySpelledPacket
extends L2GameServerPacket {
    private final int _type;
    private final int _objId;
    private final List<Abnormal> _effects;

    public PartySpelledPacket(Playable activeChar, boolean full) {
        this._objId = activeChar.getObjectId();
        this._type = activeChar.isPet() ? 1 : (activeChar.isSummon() ? 2 : 0);
        this._effects = new ArrayList<Abnormal>();
        if (full) {
            l2s.gameserver.model.actor.instances.creature.Abnormal[] effects = activeChar.getAbnormalList().toArray();
            Arrays.sort(effects, AbnormalsComparator.getInstance());
            for (l2s.gameserver.model.actor.instances.creature.Abnormal effect : effects) {
                if (effect == null) continue;
                effect.addPartySpelledIcon(this);
            }
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._type);
        this.writeD(this._objId);
        this.writeD(this._effects.size());
        for (Abnormal temp : this._effects) {
            this.writeD(temp._skillId);
            this.writeH(temp._level);
            this.writeD(temp._abnormalType);
            this.writeOptionalD(temp._duration);
        }
    }

    public void addPartySpelledEffect(int skillId, int level, int abnormalType, int duration) {
        this._effects.add(new Abnormal(skillId, level, abnormalType, duration));
    }

    static class Abnormal {
        final int _skillId;
        final int _level;
        final int _abnormalType;
        final int _duration;

        public Abnormal(int skillId, int level, int abnormalType, int duration) {
            this._skillId = skillId;
            this._level = level;
            this._abnormalType = abnormalType;
            this._duration = duration;
        }
    }
}

