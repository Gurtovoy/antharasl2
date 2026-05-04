/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.stats;

import java.util.NoSuchElementException;

public enum StatModifierType {
    DIFF,
    PER;

    public static final StatModifierType[] VALUES;

    public static StatModifierType valueOfXml(String name) {
        String upperCaseName = name.toUpperCase();
        for (StatModifierType s : VALUES) {
            if (!s.toString().equalsIgnoreCase(upperCaseName)) continue;
            return s;
        }
        throw new NoSuchElementException("Unknown name '" + name + "' for enum Stats");
    }

    static {
        VALUES = StatModifierType.values();
    }
}

