/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import java.util.HashMap;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.data.xml.holder.BuyListHolder;
import l2s.gameserver.data.xml.holder.ItemHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.items.Inventory;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ShopPreviewInfoPacket;
import l2s.gameserver.network.l2.s2c.ShopPreviewListPacket;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.templates.item.WeaponTemplate;
import l2s.gameserver.templates.npc.BuyListTemplate;
import l2s.gameserver.utils.NpcUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RequestPreviewItem
extends L2GameClientPacket {
    private static final Logger _log = LoggerFactory.getLogger(RequestPreviewItem.class);
    private int _unknow;
    private int _listId;
    private int _count;
    private int[] _items;

    @Override
    protected boolean readImpl() {
        this._unknow = this.readD();
        this._listId = this.readD();
        this._count = this.readD();
        if (this._count * 4 > this._buf.remaining() || this._count > Short.MAX_VALUE || this._count < 1) {
            this._count = 0;
            return false;
        }
        this._items = new int[this._count];
        for (int i = 0; i < this._count; ++i) {
            this._items[i] = this.readD();
        }
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null || this._count == 0) {
            return;
        }
        if (activeChar.isActionsDisabled()) {
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isInStoreMode()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.WHILE_OPERATING_A_PRIVATE_STORE_OR_WORKSHOP_YOU_CANNOT_DISCARD_DESTROY_OR_TRADE_AN_ITEM);
            return;
        }
        if (activeChar.isInTrade()) {
            activeChar.sendActionFailed();
            return;
        }
        if (!Config.ALT_GAME_KARMA_PLAYER_CAN_SHOP && activeChar.isPK() && !activeChar.isGM()) {
            activeChar.sendActionFailed();
            return;
        }
        BuyListTemplate list = null;
        NpcInstance merchant = NpcUtils.canPassPacket(activeChar, this, new Object[0]);
        if (merchant != null) {
            list = merchant.getBuyList(this._listId);
        }
        if (activeChar.isGM() && (merchant == null || list == null || merchant.getNpcId() != list.getNpcId())) {
            list = BuyListHolder.getInstance().getBuyList(this._listId);
        }
        if (list == null) {
            activeChar.sendActionFailed();
            return;
        }
        boolean slots = false;
        long totalPrice = 0L;
        HashMap<Integer, Integer> itemList = new HashMap<Integer, Integer>();
        try {
            for (int i = 0; i < this._count; ++i) {
                int paperdoll;
                int itemId = this._items[i];
                if (list.getItemByItemId(itemId) == null) {
                    activeChar.sendActionFailed();
                    return;
                }
                ItemTemplate template = ItemHolder.getInstance().getTemplate(itemId);
                if (template == null || !template.isEquipable() || (paperdoll = Inventory.getPaperdollIndexes(template.getBodyPart())[0]) < 0 || template.getItemType() == WeaponTemplate.WeaponType.CROSSBOW || template.getItemType() == WeaponTemplate.WeaponType.RAPIER || template.getItemType() == WeaponTemplate.WeaponType.ANCIENTSWORD) continue;
                if (itemList.containsKey(paperdoll)) {
                    activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CAN_NOT_TRY_THOSE_ITEMS_ON_AT_THE_SAME_TIME);
                    return;
                }
                itemList.put(paperdoll, itemId);
                totalPrice += (long)ShopPreviewListPacket.getWearPrice(template);
            }
            if (!activeChar.reduceAdena(totalPrice)) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_DO_NOT_HAVE_ENOUGH_ADENA);
                return;
            }
        }
        catch (ArithmeticException ae) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_EXCEEDED_THE_QUANTITY_THAT_CAN_BE_INPUTTED);
            return;
        }
        if (!itemList.isEmpty()) {
            activeChar.sendPacket((IBroadcastPacket)new ShopPreviewInfoPacket(itemList));
            ThreadPoolManager.getInstance().schedule(new RemoveWearItemsTask(activeChar), Config.WEAR_DELAY * 1000);
        }
    }

    private static class RemoveWearItemsTask
    implements Runnable {
        private Player _activeChar;

        public RemoveWearItemsTask(Player activeChar) {
            this._activeChar = activeChar;
        }

        @Override
        public void run() {
            this._activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_ARE_NO_LONGER_TRYING_ON_EQUIPMENT_);
            this._activeChar.sendUserInfo(true);
        }
    }
}

