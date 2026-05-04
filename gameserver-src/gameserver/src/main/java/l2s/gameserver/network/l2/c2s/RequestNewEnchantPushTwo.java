/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.data.xml.holder.SynthesisDataHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExEnchantTwoFail;
import l2s.gameserver.network.l2.s2c.ExEnchantTwoOK;
import l2s.gameserver.templates.item.support.SynthesisData;

public class RequestNewEnchantPushTwo
extends L2GameClientPacket {
    private int _item2ObjectId;

    @Override
    protected boolean readImpl() {
        this._item2ObjectId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        ItemInstance item2 = activeChar.getInventory().getItemByObjectId(this._item2ObjectId);
        if (item2 == null) {
            activeChar.sendPacket((IBroadcastPacket)ExEnchantTwoFail.STATIC);
            return;
        }
        ItemInstance item1 = activeChar.getSynthesisItem1();
        if (item1 == item2 && item1.getCount() <= 1L) {
            activeChar.sendPacket((IBroadcastPacket)ExEnchantTwoFail.STATIC);
            return;
        }
        SynthesisData data = null;
        for (SynthesisData d : SynthesisDataHolder.getInstance().getDatas()) {
            if ((item1 == null || item1.getItemId() == d.getItem1Id()) && item2.getItemId() == d.getItem2Id()) {
                data = d;
                break;
            }
            if (item1 != null && item1.getItemId() != d.getItem2Id() || item2.getItemId() != d.getItem1Id()) continue;
            data = d;
            break;
        }
        if (data == null) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THIS_IS_NOT_A_VALID_COMBINATION);
            activeChar.sendPacket((IBroadcastPacket)ExEnchantTwoFail.STATIC);
            return;
        }
        activeChar.setSynthesisItem2(item2);
        activeChar.sendPacket((IBroadcastPacket)ExEnchantTwoOK.STATIC);
    }
}

