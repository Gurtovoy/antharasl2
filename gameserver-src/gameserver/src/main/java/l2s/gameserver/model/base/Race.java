/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.base;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.components.CustomMessage;

public enum Race {
    HUMAN,
    ELF,
    DARKELF,
    ORC,
    DWARF;

    public static final Race[] VALUES;

    public final String getName(Player player) {
        return new CustomMessage("l2s.gameserver.model.base.Race.name." + this.ordinal()).toString(player);
    }

    static {
        VALUES = Race.values();
    }
}

