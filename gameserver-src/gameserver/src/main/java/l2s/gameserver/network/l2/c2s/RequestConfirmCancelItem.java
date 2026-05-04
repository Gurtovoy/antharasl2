package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExPutItemResultForVariationCancel;

public class RequestConfirmCancelItem
extends L2GameClientPacket {
    int _itemId;

    @Override
    protected boolean readImpl() {
        this._itemId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (!Config.ALLOW_AUGMENTATION) {
            activeChar.sendActionFailed();
            return;
        }
        ItemInstance item = activeChar.getInventory().getItemByObjectId(this._itemId);
        if (item == null) {
            activeChar.sendActionFailed();
            return;
        }
        if (!item.isAugmented()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.AUGMENTATION_REMOVAL_CAN_ONLY_BE_DONE_ON_AN_AUGMENTED_ITEM);
            return;
        }
        activeChar.sendPacket((IBroadcastPacket)new ExPutItemResultForVariationCancel(item));
    }
}

