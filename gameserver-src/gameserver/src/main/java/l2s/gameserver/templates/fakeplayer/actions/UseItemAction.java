/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.dom4j.Element
 */
package l2s.gameserver.templates.fakeplayer.actions;

import l2s.gameserver.ai.FakeAI;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.templates.fakeplayer.actions.AbstractAction;
import l2s.gameserver.utils.ItemFunctions;
import org.dom4j.Element;

public class UseItemAction
extends AbstractAction {
    private final int _itemId;

    public UseItemAction(int itemId, double chance) {
        super(chance);
        this._itemId = itemId;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    public boolean performAction(FakeAI ai) {
        Player player = ai.getActor();
        player.getInventory().writeLock();
        try {
            ItemInstance item = player.getInventory().getItemByItemId(this._itemId);
            if (item == null) {
                ItemFunctions.addItem(player, this._itemId, 1L, true);
                item = player.getInventory().getItemByItemId(this._itemId);
                if (item == null) {
                    player.sendActionFailed();
                    boolean bl = false;
                    return bl;
                }
            }
            boolean bl = player.useItem(item, false, true);
            return bl;
        }
        finally {
            player.getInventory().writeUnlock();
        }
    }

    @Override
    public boolean checkCondition(FakeAI ai, boolean force) {
        return !ai.getActor().isUseItemDisabled();
    }

    public static UseItemAction parse(Element element) {
        int itemId = Integer.parseInt(element.attributeValue("id"));
        double chance = element.attributeValue("chance") == null ? 100.0 : Double.parseDouble(element.attributeValue("chance"));
        return new UseItemAction(itemId, chance);
    }
}

