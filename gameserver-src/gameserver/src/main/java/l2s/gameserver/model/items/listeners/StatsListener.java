package l2s.gameserver.model.items.listeners;

import l2s.gameserver.listener.inventory.OnEquipListener;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.stats.funcs.Func;

public final class StatsListener
implements OnEquipListener {
    private static final StatsListener _instance = new StatsListener();

    public static StatsListener getInstance() {
        return _instance;
    }

    @Override
    public int onEquip(int slot, ItemInstance item, Playable actor) {
        Func[] funcs = item.getStatFuncs();
        if (funcs.length > 0) {
            actor.getStat().addFuncs(funcs);
            return 1;
        }
        return 0;
    }

    @Override
    public int onUnequip(int slot, ItemInstance item, Playable actor) {
        if (item.getStatFuncs().length > 0) {
            actor.getStat().removeFuncsByOwner(item);
            return 1;
        }
        return 0;
    }

    @Override
    public int onRefreshEquip(ItemInstance item, Playable actor) {
        return 0;
    }
}

