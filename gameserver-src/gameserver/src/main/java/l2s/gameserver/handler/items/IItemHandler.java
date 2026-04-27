/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.handler.items;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.templates.item.ItemTemplate;

public interface IItemHandler {
    public void attachSkill(ItemTemplate var1, Skill var2);

    public boolean forceUseItem(Playable var1, ItemInstance var2, boolean var3);

    public boolean useItem(Playable var1, ItemInstance var2, boolean var3);

    public void dropItem(Player var1, ItemInstance var2, long var3, Location var5);

    public boolean pickupItem(Playable var1, ItemInstance var2);

    public void onRestoreItem(Playable var1, ItemInstance var2);

    public void onAddItem(Playable var1, ItemInstance var2);

    public void onRemoveItem(Playable var1, ItemInstance var2);

    public boolean isAutoUse();

    public SystemMsg checkCondition(Playable var1, ItemInstance var2);
}

