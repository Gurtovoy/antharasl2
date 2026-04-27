/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.items.listeners;

import java.util.ArrayList;
import l2s.gameserver.data.xml.holder.OptionDataHolder;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.listeners.AbstractOptionDataListener;
import l2s.gameserver.templates.OptionDataTemplate;

public final class ItemAugmentationListener
extends AbstractOptionDataListener {
    private static final ItemAugmentationListener _instance = new ItemAugmentationListener();

    public static ItemAugmentationListener getInstance() {
        return _instance;
    }

    @Override
    public int onEquip(int slot, ItemInstance item, Playable actor) {
        if (!item.isEquipable()) {
            return 0;
        }
        if (!item.isAugmented()) {
            return 0;
        }
        if (!actor.isPlayer()) {
            return 0;
        }
        Player player = actor.getPlayer();
        int flags = 0;
        ArrayList<OptionDataTemplate> addedOptionDatas = new ArrayList<OptionDataTemplate>();
        if (item.getTemplate().getType2() != 0 || player.getWeaponsExpertisePenalty() == 0) {
            int[] stats;
            for (int i : stats = new int[]{item.getVariation1Id(), item.getVariation2Id()}) {
                OptionDataTemplate template = OptionDataHolder.getInstance().getTemplate(i);
                if (template == null) continue;
                addedOptionDatas.add(template);
            }
        }
        return flags |= this.refreshOptionDatas(actor, item, addedOptionDatas);
    }

    @Override
    public int onRefreshEquip(ItemInstance item, Playable actor) {
        return this.onEquip(item.getEquipSlot(), item, actor);
    }
}

