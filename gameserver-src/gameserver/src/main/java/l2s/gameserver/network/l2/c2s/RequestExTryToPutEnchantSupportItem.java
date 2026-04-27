/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.PcInventory;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExPutEnchantSupportItemResult;
import l2s.gameserver.utils.ItemFunctions;

public class RequestExTryToPutEnchantSupportItem
extends L2GameClientPacket {
    private int _itemId;
    private int _catalystId;

    @Override
    protected boolean readImpl() {
        this._catalystId = this.readD();
        this._itemId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        ItemInstance catalyst;
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        PcInventory inventory = activeChar.getInventory();
        ItemInstance itemToEnchant = inventory.getItemByObjectId(this._itemId);
        if (ItemFunctions.getEnchantStone(itemToEnchant, catalyst = inventory.getItemByObjectId(this._catalystId)) != null) {
            activeChar.sendPacket((IBroadcastPacket)new ExPutEnchantSupportItemResult(1));
        } else {
            activeChar.sendPacket((IBroadcastPacket)new ExPutEnchantSupportItemResult(0));
        }
    }
}

