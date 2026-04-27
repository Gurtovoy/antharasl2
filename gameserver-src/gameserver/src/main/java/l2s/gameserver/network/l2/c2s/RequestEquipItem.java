/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.Inventory;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestEquipItem
extends L2GameClientPacket {
    private long _slot;

    @Override
    protected boolean readImpl() {
        this.readC();
        this._slot = this.readQ();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        activeChar.setActive();
        int paperdollIndex = Inventory.getPaperdollIndex(this._slot);
        if (paperdollIndex == -1) {
            activeChar.sendActionFailed();
            return;
        }
        ItemInstance item = activeChar.getInventory().getPaperdollItem(paperdollIndex);
        if (item == null) {
            activeChar.sendActionFailed();
            return;
        }
        if (item.isEquipped() || !item.isEquipable()) {
            activeChar.sendActionFailed();
            return;
        }
        activeChar.useItem(item, false, true);
    }
}

