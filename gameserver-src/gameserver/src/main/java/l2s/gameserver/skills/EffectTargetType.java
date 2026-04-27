/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.skills;

import l2s.gameserver.model.Creature;

public enum EffectTargetType {
    NORMAL{

        @Override
        public boolean checkTarget(Creature target) {
            return true;
        }
    }
    ,
    PVP{

        @Override
        public boolean checkTarget(Creature target) {
            return target.isPlayable();
        }
    }
    ,
    PVE{

        @Override
        public boolean checkTarget(Creature target) {
            return !target.isPlayable();
        }
    };

    public static final EffectTargetType[] VALUES;

    public abstract boolean checkTarget(Creature var1);

    static {
        VALUES = EffectTargetType.values();
    }
}

