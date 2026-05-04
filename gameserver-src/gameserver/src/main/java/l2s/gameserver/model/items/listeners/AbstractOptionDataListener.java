package l2s.gameserver.model.items.listeners;

import java.util.List;
import l2s.gameserver.listener.inventory.OnEquipListener;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.templates.OptionDataTemplate;
import org.napile.primitive.maps.IntObjectMap;

public abstract class AbstractOptionDataListener
implements OnEquipListener {
    @Override
    public int onUnequip(int slot, ItemInstance item, Playable actor) {
        return this.removeOptionDatas(actor, item.removeEquippedOptionDatas(this));
    }

    protected int refreshOptionDatas(Playable actor, ItemInstance item, List<OptionDataTemplate> optionDatas) {
        if (!actor.isPlayer()) {
            return 0;
        }
        Player player = actor.getPlayer();
        int flags = 0;
        IntObjectMap<OptionDataTemplate> removedOptionDatas = item.removeEquippedOptionDatas(this);
        for (OptionDataTemplate optionData : optionDatas) {
            if (player.addOptionData(optionData) != optionData) {
                flags |= 1;
                if (!optionData.getSkills().isEmpty()) {
                    flags |= 3;
                }
            }
            item.addEquippedOptionData(this, optionData);
            if (removedOptionDatas == null) continue;
            removedOptionDatas.remove(optionData.getId());
        }
        return flags |= this.removeOptionDatas(actor, removedOptionDatas);
    }

    protected int removeOptionDatas(Playable actor, IntObjectMap<OptionDataTemplate> optionDataMap) {
        if (optionDataMap == null) {
            return 0;
        }
        if (!actor.isPlayer()) {
            return 0;
        }
        Player player = actor.getPlayer();
        int flags = 0;
        for (OptionDataTemplate optionData : optionDataMap.valueCollection()) {
            OptionDataTemplate template = player.removeOptionData(optionData.getId());
            if (template == null) continue;
            flags |= 1;
            if (template.getSkills().isEmpty()) continue;
            flags |= 3;
        }
        return flags;
    }
}

