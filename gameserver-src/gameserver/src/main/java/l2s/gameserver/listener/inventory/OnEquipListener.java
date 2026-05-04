package l2s.gameserver.listener.inventory;

import l2s.commons.listener.Listener;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.items.ItemInstance;

public interface OnEquipListener
extends Listener<Playable> {
    public int onEquip(int var1, ItemInstance var2, Playable var3);

    public int onUnequip(int var1, ItemInstance var2, Playable var3);

    public int onRefreshEquip(ItemInstance var1, Playable var2);
}

