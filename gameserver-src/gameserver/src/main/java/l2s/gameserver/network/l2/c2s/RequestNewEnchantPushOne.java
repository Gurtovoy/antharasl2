package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.data.xml.holder.SynthesisDataHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExEnchantOneFail;
import l2s.gameserver.network.l2.s2c.ExEnchantOneOK;
import l2s.gameserver.templates.item.support.SynthesisData;

public class RequestNewEnchantPushOne
extends L2GameClientPacket {
    private int _item1ObjectId;

    @Override
    protected boolean readImpl() {
        this._item1ObjectId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        ItemInstance item1 = activeChar.getInventory().getItemByObjectId(this._item1ObjectId);
        if (item1 == null) {
            activeChar.sendPacket((IBroadcastPacket)ExEnchantOneFail.STATIC);
            return;
        }
        ItemInstance item2 = activeChar.getSynthesisItem2();
        if (item1 == item2) {
            activeChar.sendPacket((IBroadcastPacket)ExEnchantOneFail.STATIC);
            return;
        }
        SynthesisData data = null;
        for (SynthesisData d : SynthesisDataHolder.getInstance().getDatas()) {
            if ((item2 == null || item2.getItemId() == d.getItem1Id()) && item1.getItemId() == d.getItem2Id()) {
                data = d;
                break;
            }
            if (item2 != null && item2.getItemId() != d.getItem2Id() || item1.getItemId() != d.getItem1Id()) continue;
            data = d;
            break;
        }
        if (data == null) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THIS_IS_NOT_A_VALID_COMBINATION);
            activeChar.sendPacket((IBroadcastPacket)ExEnchantOneFail.STATIC);
            return;
        }
        activeChar.setSynthesisItem1(item1);
        activeChar.sendPacket((IBroadcastPacket)ExEnchantOneOK.STATIC);
    }
}

