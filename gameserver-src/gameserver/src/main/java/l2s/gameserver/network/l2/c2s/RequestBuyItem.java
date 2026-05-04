package l2s.gameserver.network.l2.c2s;

import java.util.ArrayList;
import java.util.List;
import l2s.commons.math.SafeMath;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.BuyListHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.residence.Castle;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.items.PcInventory;
import l2s.gameserver.model.items.TradeItem;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExBuySellListPacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.templates.npc.BuyListTemplate;
import l2s.gameserver.utils.NpcUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RequestBuyItem
extends L2GameClientPacket {
    private static final Logger _log = LoggerFactory.getLogger(RequestBuyItem.class);
    private int _listId;
    private int _count;
    private int[] _items;
    private long[] _itemQ;

    @Override
    protected boolean readImpl() {
        this._listId = this.readD();
        this._count = this.readD();
        if (this._count * 12 > this._buf.remaining() || this._count > Short.MAX_VALUE || this._count < 1) {
            this._count = 0;
            return false;
        }
        this._items = new int[this._count];
        this._itemQ = new long[this._count];
        for (int i = 0; i < this._count; ++i) {
            this._items[i] = this.readD();
            this._itemQ[i] = this.readQ();
            if (this._itemQ[i] >= 1L) continue;
            this._count = 0;
            break;
        }
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null || this._count == 0) {
            return;
        }
        if (activeChar.getBuyListId() != this._listId) {
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
        if (activeChar.isFishing()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_DO_THAT_WHILE_FISHING);
            return;
        }
        if (activeChar.isInTrainingCamp()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_TAKE_OTHER_ACTION_WHILE_ENTERING_THE_TRAINING_CAMP);
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
        int slots = 0;
        long weight = 0L;
        long totalPrice = 0L;
        long tax = 0L;
        double buyTaxRate = 0.0;
        double sellTaxRate = 0.0;
        Castle castle = null;
        if (merchant != null && (castle = merchant.getCastle(activeChar)) != null) {
            buyTaxRate = castle.getBuyTaxRate();
            sellTaxRate = castle.getSellTaxRate();
        }
        ArrayList<TradeItem> buyList = new ArrayList<TradeItem>(this._count);
        List<TradeItem> tradeList = list.getItems();
        PcInventory inventory = activeChar.getInventory();
        inventory.writeLock();
        activeChar.getRefund().writeLock();
        try {
            block9: for (int i = 0; i < this._count; ++i) {
                int itemId = this._items[i];
                long count = this._itemQ[i];
                long price = 0L;
                boolean limited = false;
                for (TradeItem ti : tradeList) {
                    if (ti.getItemId() != itemId) continue;
                    if (ti.isCountLimited() && ti.getCurrentValue() < count) continue block9;
                    limited = ti.isCountLimited();
                    price = ti.getOwnersPrice();
                }
                if (!(limited || price != 0L || activeChar.isGM() && activeChar.getPlayerAccess().UseGMShop)) {
                    activeChar.sendActionFailed();
                    return;
                }
                totalPrice = SafeMath.addAndCheck((long)totalPrice, (long)SafeMath.mulAndCheck((long)count, (long)price));
                TradeItem ti = new TradeItem();
                ti.setItemId(itemId);
                ti.setCount(count);
                ti.setOwnersPrice(price);
                weight = SafeMath.addAndCheck((long)weight, (long)SafeMath.mulAndCheck((long)count, (long)ti.getItem().getWeight()));
                if (!ti.getItem().isStackable() || inventory.getItemByItemId(itemId) == null) {
                    ++slots;
                }
                buyList.add(ti);
            }
            tax = (long)((double)totalPrice * sellTaxRate);
            totalPrice = SafeMath.addAndCheck((long)totalPrice, (long)tax);
            if (!inventory.validateWeight(weight)) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_EXCEEDED_THE_WEIGHT_LIMIT);
                return;
            }
            if (!inventory.validateCapacity(slots)) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOUR_INVENTORY_IS_FULL);
                return;
            }
            if (!activeChar.reduceAdena(totalPrice)) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_DO_NOT_HAVE_ENOUGH_ADENA);
                return;
            }
            for (TradeItem ti : buyList) {
                inventory.addItem(ti.getItemId(), ti.getCount());
            }
            list.updateItems(buyList);
            if (castle != null && tax > 0L && castle.getOwnerId() > 0 && activeChar.getReflection().isMain()) {
                castle.addToTreasury(tax, true);
            }
        }
        catch (ArithmeticException ae) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_EXCEEDED_THE_QUANTITY_THAT_CAN_BE_INPUTTED);
            return;
        }
        finally {
            inventory.writeUnlock();
            activeChar.getRefund().writeUnlock();
        }
        this.sendPacket((L2GameServerPacket)new ExBuySellListPacket.SellRefundList(activeChar, true, buyTaxRate));
        activeChar.sendChanges();
    }
}

