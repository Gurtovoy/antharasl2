/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates.agathion;

import java.util.HashMap;
import java.util.Map;
import l2s.gameserver.templates.agathion.AgathionEnchantData;

public class AgathionData {
    private final Map<Integer, AgathionEnchantData> enchants = new HashMap<Integer, AgathionEnchantData>();

    public void addEnchant(AgathionEnchantData enchant) {
        this.enchants.put(enchant.getLevel(), enchant);
    }

    public AgathionEnchantData getEnchant(int enchantLevel) {
        return this.enchants.get(enchantLevel);
    }
}

