/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.base;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.components.CustomMessage;

public enum ClassType {
    FIGHTER,
    MYSTIC;

    public static final ClassType[] VALUES;

    public boolean isMagician() {
        return this != FIGHTER;
    }

    public final String getName(Player player) {
        return new CustomMessage("l2s.gameserver.model.base.ClassType.name." + this.ordinal()).toString(player);
    }

    static {
        VALUES = ClassType.values();
    }
}

