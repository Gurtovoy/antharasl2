package l2s.gameserver.model.items.listeners;

import l2s.gameserver.listener.inventory.OnEquipListener;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.templates.item.WeaponTemplate;

public final class BowListener
implements OnEquipListener {
    private static final BowListener _instance = new BowListener();

    public static BowListener getInstance() {
        return _instance;
    }

    @Override
    public int onEquip(int slot, ItemInstance item, Playable actor) {
        ItemInstance bolt;
        ItemInstance arrow;
        if (!item.isEquipable() || slot != 7) {
            return 0;
        }
        if (!actor.isPlayer()) {
            return 0;
        }
        Player player = actor.getPlayer();
        if (item.getItemType() == WeaponTemplate.WeaponType.BOW && (arrow = player.getInventory().findArrowForBow(item.getTemplate())) != null) {
            player.getInventory().setPaperdollItem(8, arrow);
        }
        if ((item.getItemType() == WeaponTemplate.WeaponType.CROSSBOW || item.getItemType() == WeaponTemplate.WeaponType.TWOHANDCROSSBOW) && (bolt = player.getInventory().findArrowForCrossbow(item.getTemplate())) != null) {
            player.getInventory().setPaperdollItem(8, bolt);
        }
        return 0;
    }

    @Override
    public int onUnequip(int slot, ItemInstance item, Playable actor) {
        return 0;
    }

    @Override
    public int onRefreshEquip(ItemInstance item, Playable actor) {
        return 0;
    }
}

