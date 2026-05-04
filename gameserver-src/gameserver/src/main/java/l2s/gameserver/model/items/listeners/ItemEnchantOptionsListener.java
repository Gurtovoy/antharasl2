/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.items.listeners;

import java.util.ArrayList;
import l2s.gameserver.data.xml.holder.OptionDataHolder;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.listeners.AbstractOptionDataListener;
import l2s.gameserver.templates.OptionDataTemplate;

public final class ItemEnchantOptionsListener
extends AbstractOptionDataListener {
    private static final ItemEnchantOptionsListener _instance = new ItemEnchantOptionsListener();

    public static ItemEnchantOptionsListener getInstance() {
        return _instance;
    }

    @Override
    public int onEquip(int slot, ItemInstance item, Playable actor) {
        if (!item.isEquipable()) {
            return 0;
        }
        if (!actor.isPlayer()) {
            return 0;
        }
        Player player = actor.getPlayer();
        int flags = 0;
        ArrayList<OptionDataTemplate> addedOptionDatas = new ArrayList<OptionDataTemplate>();
        for (int i : item.getEnchantOptions()) {
            OptionDataTemplate template = OptionDataHolder.getInstance().getTemplate(i);
            if (template == null) continue;
            addedOptionDatas.add(template);
        }
        return flags |= this.refreshOptionDatas(actor, item, addedOptionDatas);
    }

    @Override
    public int onRefreshEquip(ItemInstance item, Playable actor) {
        return this.onEquip(item.getEquipSlot(), item, actor);
    }
}

